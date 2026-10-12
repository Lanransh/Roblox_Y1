-- 项目公共枚举；背包与快捷栏容量由 SetupProvider 返回。
return {
    RankingDataStore = "ActivityData",
    -- 世界传送列表：Id 为稳定业务 ID，Name 为英文显示名，NeedRebirthCount 为解锁所需重生次数，
    -- Position 为传送落点；数组顺序即界面显示顺序，世界 2 及之后的场景落地后按同一结构补充。
    WorldTransferConfig = {
        {
            Id = "world_1",
            Name = "World 1",
            NeedRebirthCount = 0,
            Position = Vector3.new(1, 2, 0),
        },
    },
}
