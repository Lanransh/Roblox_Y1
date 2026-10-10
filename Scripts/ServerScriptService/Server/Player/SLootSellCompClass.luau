local FX = _G.FX
local FXLoader = FX.Loader
local HttpService = game:GetService("HttpService")
local Fields = _G.PlayerDataConfig
local GameConfig = _G.GameConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collectible = FXLoader:RequireFromParent(script, "RockCollectible")
local Component = FX.Class("SLootSellCompClass", "FSPlayerCompClass")

--- 正式库存出售由独立组件承接，不操作尚未入库的 RockLoot。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SLootSellComp"
end

--- 库存已加载后生成展示快照；监听服务端私有库存的新增、移动及删除。
function Component:OnPlayerLogin()
    self._inventory = self:GetPlayerObject():RequireComponent("FSInventoryComp")
    self:WatchDataChanged(Fields.Inventory, self.RefreshEntries, self)
    self:RefreshEntries()
end

--- 给新旧收藏品补持久实例 ID，换格或同名同价也不会混淆出售目标。
--- @return table 当前正式库存的可出售收藏品快照。
function Component:RefreshEntries()
    local data = self:GetTable(Fields.Inventory)
    local entries = {}
    local changed = false
    local ids = {}
    for grid = 1, self._inventory:GetTotalCapacity() do
        local item = data[tostring(grid)]
        local extra = item and item.extraData
        if item and item.itemId == Collectible.ItemId and extra
            and GameConfig.ItemData[extra.ItemId]
            and type(extra.Price) == "number" and extra.Price >= 0 and extra.Price < math.huge then
            if type(extra.SellId) ~= "string" or extra.SellId == "" or ids[extra.SellId] then
                extra.SellId = HttpService:GenerateGUID(false)
                changed = true
            end
            ids[extra.SellId] = true
            table.insert(entries, {
                id = extra.SellId, itemId = extra.ItemId, price = extra.Price,
                isLucky = extra.IsLucky == true, luckRate = extra.LuckRate or 1,
            })
        end
    end
    if changed then
        self:SetTable(Fields.Inventory, data)
    end
    self:SetTable(Fields.LootSellEntries, entries)
    return entries
end

--- 全部目标校验通过才扣库存；无让出执行的结算防止重复请求重复到账。
--- @param entryIds table 客户端展示的稳定实例 ID 数组，不接受格号或金额。
--- @param multiplier number 仅允许 1 或 2；双倍暂不要求付费资格。
--- @return table 出售是否成功、文案 Key、实际收益与最新展示快照。
function Component:SellLoot(entryIds, multiplier)
    if not self._inventory or type(entryIds) ~= "table" or (multiplier ~= 1 and multiplier ~= 2) then
        return {success = false, key = "Common.Unknown"}
    end
    local capacity = self._inventory:GetTotalCapacity()
    local count = 0
    local requested = {}
    for index, id in pairs(entryIds) do
        count += 1
        if count > capacity or type(index) ~= "number" or index % 1 ~= 0
            or index < 1 or index > capacity or type(id) ~= "string" or requested[id] then
            return {success = false, key = "LootSell.Changed"}
        end
        requested[id] = true
    end
    if count == 0 then
        return {success = false, key = "LootSell.Empty"}
    end
    for index = 1, count do
        if entryIds[index] == nil then
            return {success = false, key = "LootSell.Changed"}
        end
    end
    local data = self:GetTable(Fields.Inventory)
    local grids = {}
    local amount = 0
    for grid = 1, capacity do
        local item = data[tostring(grid)]
        local extra = item and item.extraData
        if item and item.itemId == Collectible.ItemId and extra and requested[extra.SellId] then
            if not GameConfig.ItemData[extra.ItemId] or item.stackCount ~= 1
                or type(extra.Price) ~= "number" or not (extra.Price >= 0 and extra.Price < math.huge) then
                return {success = false, key = "LootSell.Changed"}
            end
            requested[extra.SellId] = nil
            table.insert(grids, grid)
            amount += extra.Price
        end
    end
    if next(requested) then
        return {success = false, key = "LootSell.Changed"}
    end
    -- Price 已包含幸运倍率，不重复乘 LuckRate；图鉴激活记录始终保留。
    amount *= Rebirth.GetMoneyRate(self:GetNumber(Fields.RebirthCount)) * multiplier
    if not (amount >= 0 and amount < math.huge)
        or self:GetNumber(Fields.Coins) + amount >= math.huge then
        return {success = false, key = "Common.Unknown"}
    end
    for index, grid in ipairs(grids) do
        data[tostring(grid)] = nil
    end
    self:SetTable(Fields.Inventory, data)
    self:AddNumber(Fields.Coins, amount)
    return {
        success = true, key = "LootSell.Success", count = count, amount = amount,
        entries = self:RefreshEntries(),
    }
end

return Component
