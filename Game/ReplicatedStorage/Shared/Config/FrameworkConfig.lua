-- 只包含通用框架配置。Items/Goods/Rankings/GuideGroups 由具体项目填写。
return {
    ClientMessages = {},
    ServerMessages = {},
    PlayerKV = { "PlayerData" },
    RankingDataStore = "PlayerData",
    DataVersion = 1,
    PlayerData = {
        DataVersion = { Type = "number", DefVal = 0, Key = "DataVersion", KVTable = "PlayerData", Sync = false },
        Inventory = { Type = "table", DefVal = {}, Key = "Inventory", KVTable = "PlayerData", Sync = false },
        Guide = {
            Type = "table",
            DefVal = { activeGuideId = "", guideMap = {}, target = { type = "None" } },
            Key = "Guide",
            KVTable = "PlayerData",
            Sync = true,
        },
    },
    ShortcutCapacity = 8,
    InventoryCapacity = 50,
    Items = {},
    ItemSchemas = {},
    -- 货币名 -> PlayerData 字段名，例如 Money = "Coins"；不预设游戏货币。
    RewardCurrencies = {},
    Goods = {},
    Rankings = {},
    GuideGroups = {},
    DeveloperUserIds = {},
}
