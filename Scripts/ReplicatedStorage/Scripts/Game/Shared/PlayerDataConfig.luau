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
    -- 金币余额。
    Coins = {
        Type = "number",
        Key = "Coins",
        DefVal = 0,
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 累计重生次数。
    RebirthCount = {
        Type = "number",
        Key = "RebirthCount",
        DefVal = 0,
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 钻石余额，新玩家默认拥有 500 钻石。
    Diamonds = {
        Type = "number",
        Key = "Diamonds",
        DefVal = 500,
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 当前携带且尚未返回基地存入正式背包的战利品。
    RockLoot = {
        Type = "table",
        Key = "RockLoot",
        DefVal = {},
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 正式背包中可出售收藏品的临时展示快照；实际库存仍为服务端私有字段。
    LootSellEntries = {
        Type = "table",
        Key = "LootSellEntries",
        DefVal = {},
        Sync = true,
    },
    -- 成功入库后永久激活的道具 ID；普通和幸运版本共用一条记录。
    CollectionEntries = {
        Type = "table",
        Key = "CollectionEntries",
        DefVal = {},
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 光环永久解锁与单件装备状态；字典键为字符串 AuraId，0 表示未装备。
    AuraData = {
        Type = "table",
        Key = "AuraData",
        DefVal = {owned = {}, equippedId = 0},
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 累计训练值，用于计算训练等级和力量。
    RockTrainingValue = {
        Type = "number",
        Key = "RockTrainingValue",
        DefVal = 0,
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 由累计训练值计算的当前训练等级，不单独存档。
    RockTrainingLevel = {
        Type = "number",
        Key = "RockTrainingLevel",
        DefVal = 1,
        Sync = true,
    },
    -- 玩家存档版本号，用于检查和迁移旧存档。
    DataVersion = {
        Type = "number",
        DefVal = 0,
        Key = "DataVersion",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = false,
    },
    -- 正式背包的道具存档数据，仅供服务端读取。
    Inventory = {
        Type = "table",
        DefVal = {},
        Key = "Inventory",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = false,
    },
    -- 玩家引导状态，包含当前引导、引导进度和目标。
    Guide = {
        Type = "table",
        DefVal = {
            activeGuideId = "",
            guideMap = {},
            target = {
                type = "None",
            },
        },
        Key = "Guide",
        KVTable = PlayerKVEnum.ePlayerData,
        Sync = true,
    },
    -- 商品购买记录，保存在静态数据域。
    GoodsBuyInfo = {
        Type = "table",
        DefVal = {},
        Key = "GoodsBuyInfo",
        KVTable = PlayerKVEnum.eStaticData,
        Sync = false,
    },
    -- 当前手持道具的背包格索引，-1 表示未选中。
    HandItemGridIndex = {
        Type = "number",
        DefVal = -1,
        Key = "HandItemGridIndex",
        Sync = true,
    },
    -- 首次登录标记，默认 true，保存在静态数据域。
    FirstLogin = {
        Type = "boolean",
        DefVal = true,
        Key = "FirstLogin",
        KVTable = PlayerKVEnum.eStaticData,
        Sync = true,
    },
}
