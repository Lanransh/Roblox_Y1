-- 项目公共枚举；背包与快捷栏容量由 SetupProvider 返回。
return {
    RankingDataStore = "ActivityData",
    -- 石头关卡：玩家等级低于推荐等级时，每低 1 级的伤害衰减比例。
    RockLevelDamageDecayPerLevel = 0.05,
    -- 关卡头顶幸运牌：按 LevelConfig 加载的区域创建，倍率由 RockLevel.GetLuck 计算。
    LevelLuckDisplay = {
        Icon = "rbxassetid://99859137989503",
        Height = 26, -- 相对区域中心的悬空高度，单位 studs。
    },
    -- 菜鸟 NPC 配置：在区域内循环巡逻；增加世界时追加对应路径组。
    NoobNpcConfig = {
        TemplatePath = "Assets/Decorations/Noob",
        WorldAreaPaths = {
            {
                "GameLevelList/World1/Level_1",
                "GameLevelList/World1/Level_2",
                "GameLevelList/World1/Level_3",
                "GameLevelList/World1/Level_4",
                "GameLevelList/World1/Level_5",
            },
        },
        SpawnCount = 3, -- 每个世界每批数量，不能超过对应区域数量。
        RefreshInterval = 180, -- 秒；到期清理旧 NPC，拾取后不提前补刷。
        AreaScale = 0.8, -- 使用刷新区域中心 80% 的水平范围。
        ModelHeight = 6, -- 克隆后的模型高度，单位 studs；不改变原模板。
        HoverHeight = 0, -- 模型双脚贴地。
        PickupDistance = 10,
        HoldDuration = 0.5,
        PatrolPointCount = 4, -- 与 Studio_Y3 一致，循环经过四个随机巡逻点。
        WalkSpeed = 6, -- 水平巡逻速度，单位 studs/秒。
        ArriveDistance = 1,
        UpdateInterval = 0.05,
        OutlineColor = Color3.fromRGB(255, 215, 0),
        OutlineTransparency = 0,
        FillTransparency = 1,
        ParticleTexture = "rbxasset://textures/particles/sparkles_main.dds",
        ParticleColor = Color3.fromRGB(255, 215, 0),
        ParticleRate = 12, -- 每秒发射的金色闪光数量，设为 0 可停用。
    },
    -- 世界传送列表：Id 为稳定业务 ID，Name 为英文显示名，NeedTrainingLevel 为解锁所需历史最高等级，
    -- Position 为世界传送落点，SpawnPath 为回家出生垫路径；PortalPath 为场景入口，数组顺序即界面显示顺序。
    WorldTransferConfig = {
        {
            Id = "world_1",
            Name = "World 1",
            NeedTrainingLevel = 0,
            Position = Vector3.new(1, 2, 0),
            SpawnPath = "Decorations/World1Decorations/SpawnLocation",
            PortalPath = "BlockMeshs/World1Root/金色传送门",
        },
        {
            Id = "world_2",
            Name = "World 2",
            NeedTrainingLevel = 195,
            Position = Vector3.new(581, 2, 0),
            SpawnPath = "Decorations/World2Decorations/World2SpawnPad",
            PortalPath = "BlockMeshs/World2Root/世界2/金色传送门",
        },
        {
            Id = "world_3",
            Name = "World 3",
            NeedTrainingLevel = 390,
            Position = Vector3.new(1161, 2, 0),
            SpawnPath = "Decorations/World3Decorations/World3SpawnPad",
            PortalPath = "BlockMeshs/World3Root/世界3/金色传送门",
        },
    },
}
