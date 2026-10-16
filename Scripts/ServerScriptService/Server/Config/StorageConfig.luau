local RunService = game:GetService("RunService")

return {
    -- Studio 使用独立云存档，避免测试和重置影响正式玩家数据。
    DataStoreName = RunService:IsStudio() and "Roblox_Y1_Player_Studio_v1" or "Roblox_Y1_Player_v1",
    AutoSaveSeconds = RunService:IsStudio() and 60 or 20,
    SessionLockEnabled = not RunService:IsStudio(),
    SessionLeaseSeconds = 60,
}
