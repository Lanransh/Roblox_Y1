-- 钻石商店结算不 yield，顺序、余额和奖励只从服务器数据读取。
local FX = _G.FX
local Shop = FX.Loader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Fields = _G.PlayerDataConfig
local Service = {}

--- 升级同组只能买下一档，力量包允许逐次购买；价格和实际收益均由服务端重算。
--- @param player table 引擎认证身份对应的已就绪玩家对象。
--- @param goodsId any 客户端提交的钻石商品 ID。
--- @return table 结果 Key 与权威商店状态。
function Service.Buy(player, goodsId)
    if type(goodsId) ~= "number" or goodsId % 1 ~= 0 then
        return {success = false, key = "CurrencyShop.Invalid"}
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
        return {success = false, key = "CurrencyShop.Invalid"}
    end
    local gain = isTrainingPack and Shop.GetTrainingPackGain(player, goodsId) or 0
    if isTrainingPack and gain <= 0 then
        return {success = false, key = "Main.TrainingFull"}
    end
    local diamonds = player:GetNumber(Fields.Diamonds)
    if diamonds < goods.Price then
        return {success = false, key = "CurrencyShop.NeedDiamonds"}
    end
    local key, arguments
    local rewards
    if isTrainingPack then
        rewards = {{Type = "Money", Currency = "RockTrainingValue", Count = gain}}
        key, arguments = "CurrencyShop.TrainingReceived", {value = gain}
    elseif goods.BuyHandler == "TrainingRateLevel" then
        rewards = {{Type = "ShopUpgrade", Kind = "TrainingRate", Count = 1}}
        key = "CurrencyShop.RateUpgraded"
    elseif goods.BuyHandler == "ExpandableBackpack" then
        rewards = {{Type = "ShopUpgrade", Kind = "Capacity", Count = goods.NumberArray[1]}}
        key, arguments = "CurrencyShop.CapacityUpgraded", {count = goods.NumberArray[1]}
    else
        return {success = false, key = "CurrencyShop.Invalid"}
    end
    local costs = goods.Price > 0 and {{Type = "Money", Currency = "Diamonds", Count = goods.Price}} or {}
    if not player:RequireComponent("FSRewardComp"):ExchangeRewards(costs, rewards) then
        return {success = false, key = "CurrencyShop.Invalid"}
    end
    data = player:GetTable(Fields.CurrencyShopData)
    data.gemBought[tostring(goodsId)] = true
    player:SetTable(Fields.CurrencyShopData, data)
    if isTrainingPack then
        player:RequireComponent("SMiscComp"):RefreshProgress()
        FX.Network:SendMsgToClient(player:GetPlayerId(), "S2C_TrainingEffect", gain, true)
    elseif goods.BuyHandler == "TrainingRateLevel" then
        arguments = {rate = Shop.GetTrainingRate(data)}
    end
    return {success = true, key = key, arguments = arguments, data = data}
end

return Service
