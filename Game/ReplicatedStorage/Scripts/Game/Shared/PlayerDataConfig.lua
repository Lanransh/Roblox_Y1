-- 保留 Roblox 已有字段的存档 Key 和数据域，补入 MiniStudio 的通用玩家字段。
-- GoodsBuyInfo/FirstLogin 使用 StaticData；手持格索引为同步到客户端的临时字段。
return {
    DataVersion = { Type = "number", DefVal = 0, Key = "DataVersion", KVTable = "PlayerData", Sync = false },
    Inventory = { Type = "table", DefVal = {}, Key = "Inventory", KVTable = "PlayerData", Sync = false },
    Guide = {
        Type = "table",
        DefVal = { activeGuideId = "", guideMap = {}, target = { type = "None" } },
        Key = "Guide",
        KVTable = "PlayerData",
        Sync = true,
    },
    GoodsBuyInfo = { Type = "table", DefVal = {}, Key = "GoodsBuyInfo", KVTable = "StaticData", Sync = false },
    HandItemGridIndex = { Type = "number", DefVal = -1, Key = "HandItemGridIndex", Sync = true },
    FirstLogin = { Type = "boolean", DefVal = true, Key = "FirstLogin", KVTable = "StaticData", Sync = true },
}
