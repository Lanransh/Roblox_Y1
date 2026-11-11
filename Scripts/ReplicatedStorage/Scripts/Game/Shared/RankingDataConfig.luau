-- 协议使用有序榜单索引，保留时长榜索引 1；三个榜按月切换存储，沿用玩家历史最高成绩，由服务端写入。
return {
    {
        Name = "Playtime",
        DisplayName = "Playtime",
        ResetType = "Monthly",
        ScoreFormat = "Duration",
        Ascending = false,
        MaxCount = 100,
        DefaultValue = 0,
        UseHistoricalHighScore = true,
    },
    {
        Name = "Strength",
        DisplayName = "Strength",
        ResetType = "Monthly",
        ScoreFormat = "Number",
        Ascending = false,
        MaxCount = 100,
        DefaultValue = 0,
        UseHistoricalHighScore = true,
    },
    {
        Name = "Rebirth",
        DisplayName = "Rebirths",
        ResetType = "Monthly",
        ScoreFormat = "Number",
        Ascending = false,
        MaxCount = 100,
        DefaultValue = 0,
        UseHistoricalHighScore = true,
    },
}
