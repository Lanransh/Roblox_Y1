local RunService = game:GetService("RunService")

return {
    -- Studio 使用独立云存档，避免测试和重置影响正式玩家数据。
    DataStoreName = RunService:IsStudio() and "Roblox_Y1_Player_Studio_v1" or "Roblox_Y1_Player_v1",
    AutoSaveSeconds = 60,
    SessionLeaseSeconds = 180,
}
