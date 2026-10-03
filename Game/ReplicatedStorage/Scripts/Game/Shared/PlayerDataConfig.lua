-- 保留 Roblox 已有字段的存档 Key 和数据域，补入 MiniStudio 的通用玩家字段。
-- GoodsBuyInfo/FirstLogin 使用 StaticData；手持格索引为同步到客户端的临时字段。
_G.PlayerKVEnum = {
    ePlayerData = "PlayerData",
    eDynamicData = "DynamicData",
    eStaticData = "StaticData",
    eActivityData = "ActivityData",
}
local PlayerKVEnum = _G.PlayerKVEnum

return {
    RockTrainingValue = {
        Type = "number", Key = "RockTrainingValue", DefVal = 0,
        KVTable = PlayerKVEnum.ePlayerData, Sync = true,
    },
    RockTrainingLevel = {
        Type = "number", Key = "RockTrainingLevel", DefVal = 1, Sync = true,
    },
    RockHealth = {
        Type = "table", Key = "RockHealth", DefVal = {}, Sync = true,
    },
    DataVersion = {
        Type = "number",
        DefVal = 0,
        Key = "DataVersion",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = false
    },
    Inventory = {
        Type = "table",
        DefVal = {},
        Key = "Inventory",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = false
    },
    Guide = {
        Type = "table",
        DefVal = {
            activeGuideId = "",
            guideMap = {},
            target = {
                type = "None"
            }
        },
        Key = "Guide",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true
    },
    GoodsBuyInfo = {
        Type = "table",
        DefVal = {},
        Key = "GoodsBuyInfo",
        KVTable = PlayerKVEnum.eStaticData,
        Sync = false
    },
    HandItemGridIndex = {
        Type = "number",
        DefVal = -1,
        Key = "HandItemGridIndex",
        Sync = true
    },
    FirstLogin = {
        Type = "boolean",
        DefVal = true,
        Key = "FirstLogin",
        KVTable = PlayerKVEnum.eStaticData,
        Sync = true
    },
}
