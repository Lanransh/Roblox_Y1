local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("LootSell", {
    Unknown = "Something went wrong. Please try again.",
    Changed = "Your items have changed. Please try again.",
    Empty = "You have no items to sell.",
    NeedDoubleCard = "You need a Double Sell Value Card to sell for double value.",
    NeedDiamonds = "Not enough diamonds.",
    NeedVip = "Unlock VIP to use free double selling.",
    Success = "Items sold!",
})
local HttpService = game:GetService("HttpService")
local Fields = _G.PlayerDataConfig
local GameConfig = _G.GameConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Component = FX.Class("SLootSellCompClass", "FSPlayerCompClass")

--- 基地收藏品由玩家 KV 保存，出售不依赖正式背包。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SLootSellComp"
end

--- 服务端订阅只监听后续变化，登录时需先生成一次出售快照。
function Component:OnPlayerLogin()
    self:WatchDataChanged(Fields.StoredLoot, self.RefreshEntries, self)
    self:WatchDataChanged(Fields.Inventory, self.RefreshCards, self)
    self:RefreshCards()
    self:RefreshEntries()
end

--- 背包变化时只同步出售卡数量，不向客户端公开库存存档。
function Component:RefreshCards()
    self:SetNumber(Fields.DoubleSaleCards, self:RequireComponent("FSInventoryComp"):GetItemCountById(103))
end

--- 给 KV 收藏品补唯一持久 ID，同名同价也不会混淆出售目标。
--- @return table 当前 KV 中配置及价格有效的可出售收藏品快照。
function Component:RefreshEntries()
    local data = self:GetTable(Fields.StoredLoot)
    local entries = {}
    local changed = false
    local ids = {}
    for index, extra in ipairs(data) do
        if type(extra) == "table" then
            if type(extra.SellId) ~= "string" or extra.SellId == "" or ids[extra.SellId] then
                extra.SellId = HttpService:GenerateGUID(false)
                changed = true
            end
            ids[extra.SellId] = true
            if GameConfig.ItemData[extra.ItemId]
                and type(extra.Price) == "number" and extra.Price >= 0 and extra.Price < math.huge then
                table.insert(entries, {
                    id = extra.SellId, itemId = extra.ItemId, price = extra.Price,
                    isLucky = extra.IsLucky == true, luckRate = extra.LuckRate or 1,
                })
            end
        end
    end
    if changed then
        self:SetTable(Fields.StoredLoot, data)
    end
    self:SetTable(Fields.LootSellEntries, entries)
    return entries
end

--- 全部目标校验通过才扣 KV 记录；无让出执行的结算防止重复请求重复到账。
--- @param entryIds table 客户端展示的稳定实例 ID 数组，不接受格号或金额。
--- @param multiplier number 客户端预览倍率，实际倍率由服务端资格决定。
--- @param method string? Card / Gems / Vip；普通出售省略。
--- @return table 出售是否成功、文案 Key、实际收益与最新展示快照。
function Component:SellLoot(entryIds, multiplier, method)
    local isVip = self:GetFlag(Fields.Vip)
    local saleMultiplier = 1
    local cost = {}
    local costFailure = TranslationTexts.Unknown
    if method == "Card" then
        saleMultiplier = isVip and 4 or 2
        cost = {{Type = "Item", ItemId = 103, Count = 1}}
        costFailure = TranslationTexts.NeedDoubleCard
    elseif method == "Gems" then
        saleMultiplier = isVip and 4 or 2
        cost = {{Type = "Money", Currency = "Diamonds", Count = _G.GoodsConfig.GemGoodsData[311].Price}}
        costFailure = TranslationTexts.NeedDiamonds
    elseif method == "Vip" then
        if not isVip then
            return {success = false, key = TranslationTexts.NeedVip}
        end
        saleMultiplier = 2
    elseif method ~= nil then
        return {success = false, key = TranslationTexts.Unknown}
    end
    if type(entryIds) ~= "table" or multiplier ~= saleMultiplier then
        return {success = false, key = TranslationTexts.Unknown}
    end
    local data = self:GetTable(Fields.StoredLoot)
    local capacity = #data
    local count = 0
    local requested = {}
    for index, id in pairs(entryIds) do
        count += 1
        if count > capacity or type(index) ~= "number" or index % 1 ~= 0
            or index < 1 or index > capacity or type(id) ~= "string" or requested[id] then
            return {success = false, key = TranslationTexts.Changed}
        end
        requested[id] = true
    end
    if count == 0 then
        return {success = false, key = TranslationTexts.Empty}
    end
    for index = 1, count do
        if entryIds[index] == nil then
            return {success = false, key = TranslationTexts.Changed}
        end
    end
    local remaining = {}
    local amount = 0
    for index, extra in ipairs(data) do
        if type(extra) == "table" and requested[extra.SellId] then
            if not GameConfig.ItemData[extra.ItemId]
                or type(extra.Price) ~= "number" or not (extra.Price >= 0 and extra.Price < math.huge) then
                return {success = false, key = TranslationTexts.Changed}
            end
            requested[extra.SellId] = nil
            amount += extra.Price
        else
            table.insert(remaining, extra)
        end
    end
    if next(requested) then
        return {success = false, key = TranslationTexts.Changed}
    end
    -- Price 已包含幸运倍率，不重复乘 LuckRate；图鉴激活记录始终保留。
    amount *= Rebirth.GetMoneyRate(self:GetNumber(Fields.RebirthCount)) * saleMultiplier
    if not (amount >= 0 and amount < math.huge)
        or self:GetNumber(Fields.Money) + amount >= math.huge then
        return {success = false, key = TranslationTexts.Unknown}
    end
    local rewardComp = self:RequireComponent("FSRewardComp")
    if not rewardComp:CanConsumeRewards(cost) then
        return {success = false, key = costFailure}
    end
    local rewards = amount > 0 and {{Type = "Money", Currency = "Money", Count = amount}} or {}
    if not rewardComp:ExchangeRewards(cost, rewards) then
        return {success = false, key = TranslationTexts.Unknown}
    end
    self:SetTable(Fields.StoredLoot, remaining)
    self:RequireComponent("TutorialGuide"):RecordSale()
    return {
        success = true, key = TranslationTexts.Success, count = count, amount = amount,
        entries = self:RefreshEntries(),
    }
end

return Component
