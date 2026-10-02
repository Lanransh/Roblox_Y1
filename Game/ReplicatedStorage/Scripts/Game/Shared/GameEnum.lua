-- 沿用当前 Roblox 项目的容量，避免恢复文件时改变已有背包格数。
return {
    PlayerKV = { "PlayerData", "DynamicData", "StaticData", "ActivityData" },
    RankingDataStore = "ActivityData",
    PlayerShortcutCapacity = 8,
    PlayerInventoryCapacity = 50,
}
