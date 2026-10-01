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
    Items = {
        [1001] = {
            Id = 1001, Type = "DemoTool", MaxStack = 1, UseHandler = "DemoTool",
            Name = "测试方块", ToolShape = "Block", ToolColor = Color3.fromRGB(49, 160, 255),
        },
        [1002] = {
            Id = 1002, Type = "DemoTool", MaxStack = 10, UseHandler = "DemoTool",
            Name = "测试球", ToolShape = "Ball", ToolColor = Color3.fromRGB(255, 178, 55),
        },
    },
    ItemSchemas = {},

    -- 货币名 -> PlayerData 字段名，例如 Money = "Coins"；不预设游戏货币。
    RewardCurrencies = {},
    Goods = {},
    Rankings = {},
    GuideGroups = {},
    DeveloperUserIds = {},
}
