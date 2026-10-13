-- 货币商店共享规则；客户端仅用于展示，服务端重新检查同一购买顺序。
local Shop = {}

--- 返回一个商品组的下一档；训练倍率按当前版本上限截断。
--- @param group number ShopConfig 中的商品组。
--- @param data table 玩家 CurrencyShopData。
--- @return table? 下一档商店配置；全部购买后返回 nil。
function Shop.GetNextGemGoods(group, data)
    for index, item in ipairs(_G.ShopConfig.GemCoinData) do
        if item.Group == group then
            local goods = _G.GoodsConfig.GemGoodsData[item.GemGoodsId]
            if goods.BuyHandler == "TrainingRateLevel" then
                local nextRate = _G.GameConfig.TrainingRateConfig[data.trainingLevel + 1]
                if data.trainingLevel < _G.GoodsConfig.MaxTrainingRateLevel
                    and nextRate and nextRate.GemGoodsId == item.GemGoodsId then
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

return Shop
