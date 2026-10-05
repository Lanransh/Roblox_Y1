-- 项目配置和框架之间的唯一入口；服务端处理器由服务端注册，永不复制给客户端。
local PlayerDataConfig, ServerDataConfig = _G.PlayerDataConfig, _G.ServerDataConfig
local NetworkProtocol, RankingDataConfig = _G.NetworkProtocol, _G.RankingDataConfig
local ItemConfig, GoodsConfig = _G.ItemConfig, _G.GoodsConfig
local Provider = { ItemHandlers = {}, BuyHandlers = {} }

--- @return table 客户端可发送的项目协议名。
function Provider:GetClientMsgID()
    return NetworkProtocol.ClientMsgID
end

--- @return table 服务端可发送的项目协议名。
function Provider:GetServerMsgID()
    return NetworkProtocol.ServerMsgID
end

--- @return table 玩家持久化数据域。
function Provider:GetPlayerKVEnum()
    return _G.PlayerKVEnum
end

--- @return table 项目排行榜列表。
function Provider:GetRankingEnum()
    return RankingDataConfig
end

--- @return string 排行榜本地分数数据域。
function Provider:GetRankingDataStore()
    return _G.PlayerKVEnum.eActivityData
end

--- @return table 玩家字段定义与默认值。
function Provider:GetPlayerDataConfig()
    return PlayerDataConfig
end

--- @return table 供共享数据同步器使用的服务器字段定义。
function Provider:GetServerDataConfig()
    return ServerDataConfig
end

--- 快捷栏与正式背包共用总容量，快捷栏最多占用其中 10 格，不删除已有存档。
--- @return table 快捷栏开关与正式背包总容量（非负整数，0 关闭）。
function Provider:GetNativeBackpackConfig()
    return {
        ShortcutEnabled = true,
        InventoryCapacity = 12, -- 正式背包总容量，包含快捷栏占用的格子。
    }
end

--- @return table 存档版本字段。
function Provider:GetPlayerDataVersionVariantEnum()
    return PlayerDataConfig.DataVersion
end

--- @param itemId number 道具配置 ID。
--- @return table 道具定义；未注册返回 nil。
function Provider:GetItemDataConfig(itemId)
    return ItemConfig.Data[itemId]
end

--- @param itemType string 道具类型。
--- @return table 附加属性定义。
function Provider:GetItemExtraDataSchema(itemType)
    return ItemConfig.ExtraDataSchema[itemType]
end

--- @param handlerType string 已注册处理器名。
--- @return table 权威道具处理器。
function Provider:GetItemHandler(handlerType)
    return self.ItemHandlers[handlerType]
end

--- @param productId number Roblox Developer Product ID。
--- @return table 商品定义。
function Provider:GetGoodsConfig(productId)
    return GoodsConfig.GoodsData[productId]
end

--- @param handlerType string 已注册处理器名。
--- @return table 权威购买处理器。
function Provider:GetBuyHandler(handlerType)
    return self.BuyHandlers[handlerType]
end

_G.Provider = Provider
return Provider
