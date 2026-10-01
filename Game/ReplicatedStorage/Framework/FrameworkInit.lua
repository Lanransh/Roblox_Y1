-- 两端只初始化公共层；服务端实现保留在 ServerScriptService。
local RunService = game:GetService("RunService")
local FX = {}
_G.FX, _G.FC, _G.FS = FX, {}, {}
_G.MS = {
    Players = game:GetService("Players"),
    RunService = RunService,
    MainStorage = game:GetService("ReplicatedStorage"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = workspace,
}
FX.FrameworkClientMsgID = {
    "C2S_ClientReady",
    "C2S_SetHeldGridIndex",
    "C2S_CanUseItem",
    "C2S_UseItem",
    "C2S_SwapGrid",
    "C2S_BuyCheck",
    "C2S_GetServerTime",
    "C2S_RankingData",
    "C2S_GetFriendState",
}
FX.FrameworkServerMsgID = {
    "S2C_ServerReady",
    "S2C_PlayerStateSync",
    "S2C_ServerSyncData",
    "S2C_ShowTips",
    "S2C_ShowDeveloperBuyUI",
    "S2C_InventoryData",
    "S2C_InventoryGridsChanged",
    "S2C_FriendState",
}
_G.Provider = require(script.Parent:WaitForChild("Provider"))
require(script.Parent:WaitForChild("FShared"))
return FX
