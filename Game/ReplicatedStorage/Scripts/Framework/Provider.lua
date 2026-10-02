-- 项目配置和框架之间的唯一入口；服务端处理器由服务端注册，永不复制给客户端。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("FrameworkConfig"))
local Provider = { ItemHandlers = {}, BuyHandlers = {} }

--- @return table 客户端可发送的项目协议名。
function Provider:GetClientMsgID()
    return Config.ClientMessages
end

--- @return table 服务端可发送的项目协议名。
function Provider:GetServerMsgID()
    return Config.ServerMessages
end

--- @return table 玩家持久化数据域。
function Provider:GetPlayerKVEnum()
    return Config.PlayerKV
end

--- @return table 项目排行榜列表。
function Provider:GetRankingEnum()
    return Config.Rankings
end

--- @return string 排行榜本地分数数据域。
function Provider:GetRankingDataStore()
    return Config.RankingDataStore
end

--- @return table 玩家字段定义与默认值。
function Provider:GetPlayerDataConfig()
    return Config.PlayerData
end

--- @return table 快捷栏手持与原生背包面板配置，不删除服务端背包数据。
function Provider:GetNativeBackpackConfig()
    return Config.NativeBackpack
end

--- @return table 存档版本字段。
function Provider:GetPlayerDataVersionVariantEnum()
    return Config.PlayerData.DataVersion
end

--- @param itemId number 道具配置 ID。
--- @return table 道具定义；未注册返回 nil。
function Provider:GetItemDataConfig(itemId)
    return Config.Items[itemId]
end

--- @param itemType string 道具类型。
--- @return table 附加属性定义。
function Provider:GetItemExtraDataSchema(itemType)
    return Config.ItemSchemas[itemType]
end

--- @param handlerType string 已注册处理器名。
--- @return table 权威道具处理器。
function Provider:GetItemHandler(handlerType)
    return self.ItemHandlers[handlerType]
end

--- @param productId number Roblox Developer Product ID。
--- @return table 商品定义。
function Provider:GetGoodsConfig(productId)
    return Config.Goods[productId]
end

--- @param handlerType string 已注册处理器名。
--- @return table 权威购买处理器。
function Provider:GetBuyHandler(handlerType)
    return self.BuyHandlers[handlerType]
end

return Provider
