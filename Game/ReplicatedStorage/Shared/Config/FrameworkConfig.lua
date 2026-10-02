-- 独立项目配置在此聚合，现有框架与组件继续使用同一份配置表。
local root = script.Parent
local Protocol = require(root:WaitForChild("NetworkProtocol"))
local GameEnum = require(root:WaitForChild("GameEnum"))

return {
    ClientMessages = Protocol.ClientMsgID,
    ServerMessages = Protocol.ServerMsgID,
    -- PlayerData 保留已有 Roblox 存档；其余数据域沿用 MiniStudio 分层。
    PlayerKV = { "PlayerData", "DynamicData", "StaticData", "ActivityData" },
    RankingDataStore = "ActivityData",
    DataVersion = 1,
    PlayerData = require(root:WaitForChild("PlayerDataConfig")),
    ServerData = require(root:WaitForChild("ServerDataConfig")),

    -- 快捷栏关闭后，框架背包数据不再生成手持 Tool；仍可通过服务端背包 API 使用物品。
    -- 原生背包面板与快捷栏共用显示接口；关闭面板时原生快捷栏也会隐藏。
    NativeBackpack = {
        ShortcutEnabled = true,
        InventoryEnabled = true,
    },
    ShortcutCapacity = GameEnum.PlayerShortcutCapacity,
    InventoryCapacity = GameEnum.PlayerInventoryCapacity,
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
    Rankings = require(root:WaitForChild("RankingDataConfig")),
    GuideGroups = require(root:WaitForChild("TutorialGuideConfig")),
    DeveloperUserIds = {},
}
