-- 协议使用有序榜单索引，时长榜索引为 1；分数单位为秒，由业务调用排行榜 API 写入。
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
        unit = 1,
    },
}
