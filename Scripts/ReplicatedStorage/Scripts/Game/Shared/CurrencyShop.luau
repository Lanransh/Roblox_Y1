-- 货币商店共享规则；客户端仅用于展示，服务端重新检查同一购买顺序。
local Shop = {}
local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local Fields = _G.PlayerDataConfig

--- 返回一个商品组的下一档；训练倍率以 TrainingRateConfig 中存在的下一档为准。
--- @param group number ShopConfig 中的商品组。
--- @param data table 玩家 CurrencyShopData。
--- @return table? 下一档商店配置；全部购买后返回 nil。
function Shop.GetNextGemGoods(group, data)
    for index, item in ipairs(_G.ShopConfig.GemCoinData) do
        if item.Group == group then
            local goods = _G.GoodsConfig.GemGoodsData[item.GemGoodsId]
            if goods.BuyHandler == "TrainingRateLevel" then
                local nextRate = _G.GameConfig.TrainingRateConfig[data.trainingLevel + 1]
                if nextRate and nextRate.GemGoodsId == item.GemGoodsId then
                    return item
                end
            elseif not data.gemBought[tostring(item.GemGoodsId)] then
                return item
            end
        end
    end
    return nil
end

--- 永久训练倍率与现有训练加成相乘，未购买时为 1。
--- @param data table 玩家 CurrencyShopData。
--- @return number 已购买档位的训练倍率。
function Shop.GetTrainingRate(data)
    if data.trainingLevel == 0 then
        return 1
    end
    return _G.GameConfig.TrainingRateConfig[data.trainingLevel].Rate
end

--- 服务端读取即时同服好友，客户端使用同步人数预览；平台未就绪时不发好友加成。
--- @param player table 当前玩家对象。
--- @return number 最多按配置人数计算的好友训练倍率。
function Shop.GetFriendTrainingRate(player)
    local count = player:GetNumber(Fields.TrainingFriendCount)
    if game:GetService("RunService"):IsServer() then
        count = FS.FriendService:GetFriendCountInRoom(player:GetPlayerId()) or 0
    end
    local config = _G.GameConfig.CommonConfig.InviteFriendData
    return 1 + math.min(count, config.MaxCount) * config.AddRate
end

--- 两端共用力量包预览与结算，沿用 Studio_Y3 每份基础 1 点及最高已解锁场地，不计在线追赶。
--- @param player table 客户端或服务端玩家对象，读取永久加成及当前同服好友。
--- @param goodsId number 已配置的力量包商品 ID。
--- @return number 当前重生阶段经验上限内可增加的训练值。
function Shop.GetTrainingPackGain(player, goodsId)
    local count = player:GetNumber(Fields.RebirthCount)
    local highestRate = 1
    for index, config in ipairs(_G.GameConfig.TrainingFieldData) do
        if count >= config.NeedRebirhLevel then
            highestRate = math.max(highestRate, config.TrainingRate)
        end
    end
    local gain = _G.GoodsConfig.GemGoodsData[goodsId].NumberArray[1] * highestRate
        * Rebirth.GetTrainingRate(count)
        * Shop.GetTrainingRate(player:GetTable(Fields.CurrencyShopData))
        * Shop.GetFriendTrainingRate(player)
        * Collection.GetTrainingRate(player:GetTable(Fields.CollectionEntries))
        * Aura.GetTrainingRate(player:GetTable(Fields.AuraData))
        * Weapon.GetEquippedConfig(player:GetTable(Fields.WeaponData)).TrainingRate
    return math.max(0, math.min(gain,
        Rebirth.GetMaxTrainingValue(count) - player:GetNumber(Fields.RockTrainingValue)))
end

return Shop
