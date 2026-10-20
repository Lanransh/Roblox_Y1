-- 钻石商店结算不 yield，顺序、余额和奖励只从服务器数据读取。
local FX = _G.FX
local TranslationTexts = {
    ["CurrencyShop.Invalid"] = { Key = "CurrencyShop.CurrencyShop.Invalid", Source = "This offer has changed. Please select the next upgrade." },
    ["Main.TrainingFull"] = { Key = "CurrencyShop.Main.TrainingFull", Source = "Training XP is full. Rebirth before buying a training pack." },
    ["CurrencyShop.NeedDiamonds"] = { Key = "CurrencyShop.CurrencyShop.NeedDiamonds", Source = "Not enough diamonds." },
    ["CurrencyShop.TrainingReceived"] = { Key = "CurrencyShop.CurrencyShop.TrainingReceived", Source = "Purchase complete! +{value} training XP." },
    ["CurrencyShop.RateUpgraded"] = { Key = "CurrencyShop.CurrencyShop.RateUpgraded", Source = "Purchase complete! Training multiplier upgraded to x{rate}." },
    ["CurrencyShop.CapacityUpgraded"] = { Key = "CurrencyShop.CurrencyShop.CapacityUpgraded", Source = "Purchase complete! Backpack capacity +{count:int}." },
}
local GameUtility = FX.Loader:RequireShared("Scripts/Game/Shared/GameUtility")
local Shop = FX.Loader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Fields = _G.PlayerDataConfig
local Service = {}

--- 升级同组只能买下一档，力量包允许逐次购买；价格和实际收益均由服务端重算。
--- @param player table 引擎认证身份对应的已就绪玩家对象。
--- @param goodsId any 客户端提交的钻石商品 ID。
--- @return table 结果 Key 与权威商店状态。
function Service.Buy(player, goodsId)
    if type(goodsId) ~= "number" or goodsId % 1 ~= 0 then
        return {success = false, key = TranslationTexts["CurrencyShop.Invalid"]}
    end
    local data = player:GetTable(Fields.CurrencyShopData)
    local goods = _G.GoodsConfig.GemGoodsData[goodsId]
    local isTrainingPack = goods and goods.BuyHandler == "BuyTrainingValue"
    local selected
    for index, item in ipairs(_G.ShopConfig.GemCoinData) do
        if item.GemGoodsId == goodsId then
            selected = item
            break
        end
    end
    local nextItem = selected and Shop.GetNextGemGoods(selected.Group, data)
    if not isTrainingPack and (not nextItem or nextItem.GemGoodsId ~= goodsId) then
        return {success = false, key = TranslationTexts["CurrencyShop.Invalid"]}
    end
    local gain = isTrainingPack and Shop.GetTrainingPackGain(player, goodsId) or 0
    if isTrainingPack and gain <= 0 then
        return {success = false, key = TranslationTexts["Main.TrainingFull"]}
    end
    local diamonds = player:GetNumber(Fields.Diamonds)
    if diamonds < goods.Price then
        return {success = false, key = TranslationTexts["CurrencyShop.NeedDiamonds"]}
    end
    local key, arguments
    local rewards
    if isTrainingPack then
        rewards = {{Type = "Money", Currency = "RockTrainingValue", Count = gain}}
        key, arguments = TranslationTexts["CurrencyShop.TrainingReceived"], {value = GameUtility.NumberToText(gain)}
    elseif goods.BuyHandler == "TrainingRateLevel" then
        rewards = {{Type = "ShopUpgrade", Kind = "TrainingRate", Count = 1}}
        key = TranslationTexts["CurrencyShop.RateUpgraded"]
    elseif goods.BuyHandler == "ExpandableBackpack" then
        rewards = {{Type = "ShopUpgrade", Kind = "Capacity", Count = goods.NumberArray[1]}}
        key, arguments = TranslationTexts["CurrencyShop.CapacityUpgraded"], {count = goods.NumberArray[1]}
    else
        return {success = false, key = TranslationTexts["CurrencyShop.Invalid"]}
    end
    local costs = goods.Price > 0 and {{Type = "Money", Currency = "Diamonds", Count = goods.Price}} or {}
    if not player:RequireComponent("FSRewardComp"):ExchangeRewards(costs, rewards) then
        return {success = false, key = TranslationTexts["CurrencyShop.Invalid"]}
    end
    data = player:GetTable(Fields.CurrencyShopData)
    data.gemBought[tostring(goodsId)] = true
    player:SetTable(Fields.CurrencyShopData, data)
    player:RequireComponent("SAnalyticsComp"):Sink("Diamonds", goods.Price,
        player:GetNumber(Fields.Diamonds), "GemGoods:" .. goodsId)
    if isTrainingPack then
        player:RequireComponent("SMiscComp"):RefreshProgress()
        FX.Network:SendMsgToClient(player:GetPlayerId(), "S2C_TrainingEffect", gain, true)
    elseif goods.BuyHandler == "TrainingRateLevel" then
        arguments = {rate = GameUtility.NumberToText(Shop.GetTrainingRate(data))}
    end
    return {success = true, key = key, arguments = arguments, data = data}
end

return Service
