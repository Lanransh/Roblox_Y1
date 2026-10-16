-- 项目公共枚举；背包与快捷栏容量由 SetupProvider 返回。
return {
    NewPlayerTrainingExtraRate = 3, -- 与购买训练倍率相加。
    NewPlayerTrainingDuration = 45 * 60, -- 累计在线秒数，不计离线时间。
    RankingDataStore = "ActivityData",
    -- 小狗 NPC 配置：只在已存在的刷新标记中生成；增加世界时追加对应路径组。
    DogNpcConfig = {
        TemplatePath = "Assets/Decorations/dog",
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
        HoverHeight = 1, -- 模型底部离地高度，单位 studs。
        PickupDistance = 10,
        HoldDuration = 0.5,
        RotationSpeed = 15, -- 每秒原地旋转角度；24 秒转一圈，设为 0 可停止旋转。
        UpdateInterval = 0.1,
        OutlineColor = Color3.fromRGB(255, 215, 0),
        OutlineTransparency = 0,
        FillTransparency = 1,
        ParticleTexture = "rbxasset://textures/particles/sparkles_main.dds",
        ParticleColor = Color3.fromRGB(255, 215, 0),
        ParticleRate = 12, -- 每秒发射的金色闪光数量，设为 0 可停用。
    },
    -- 世界传送列表：Id 为稳定业务 ID，Name 为英文显示名，NeedTrainingLevel 为解锁所需历史最高等级，
    -- Position 为出生垫板上方的传送落点；PortalPath 为场景入口，数组顺序即界面显示顺序。
    WorldTransferConfig = {
        {
            Id = "world_1",
            Name = "World 1",
            NeedTrainingLevel = 0,
            Position = Vector3.new(1, 2, 0),
            PortalPath = "BlockMeshs/World1Root/金色传送门",
        },
        {
            Id = "world_2",
            Name = "World 2",
            NeedTrainingLevel = 195,
            Position = Vector3.new(581, 2, 0),
            PortalPath = "BlockMeshs/World2Root/世界2/金色传送门",
        },
        {
            Id = "world_3",
            Name = "World 3",
            NeedTrainingLevel = 390,
            Position = Vector3.new(1161, 2, 0),
            PortalPath = "BlockMeshs/World3Root/世界3/金色传送门",
        },
    },
}
