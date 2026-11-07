local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
-- 进入游戏时使用横屏，并允许根据设备朝向左右翻转。
Players.LocalPlayer:WaitForChild("PlayerGui").ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

require(ReplicatedStorage:WaitForChild("Scripts"):WaitForChild("GameInit"))
local FC = _G.FC
local FX = _G.FX
local FXLoader = FX.Loader
local Localization = FXLoader:RequireFromParent(script, "Localization")
FC.Localization = Localization.New(Players.LocalPlayer)
FXLoader:RequireFromParent(script, "PickupPrompt").Init()

FC.GiftDrop = FXLoader:RequireFromParent(script, "GiftDrop")
FC.GiftDrop.Init()
FXLoader:RequireFromParent(script, "Player/CSoundCompClass")
FXLoader:RequireFromParent(script, "Player/CFriendInviteCompClass")
FXLoader:RequireFromParent(script, "Player/CRockLevelCompClass")
FXLoader:RequireFromParent(script, "Player/CTutorialGuideCompClass")
FXLoader:RequireFromParent(script, "UI/CMainUICompClass")
FXLoader:RequireFromParent(script, "UI/CTrainingHUDCompClass")
FXLoader:RequireFromParent(script, "UI/CTrainingBonusUICompClass")
FXLoader:RequireFromParent(script, "UI/CLeaderboardUICompClass")
FXLoader:RequireFromParent(script, "UI/CRebirthIntegrationCompClass")
FXLoader:RequireFromParent(script, "UI/CCollectionUICompClass")
FXLoader:RequireFromParent(script, "UI/CLootSellUICompClass")
FXLoader:RequireFromParent(script, "UI/CAuraShopUICompClass")
FXLoader:RequireFromParent(script, "UI/CWeaponShopUICompClass")
FXLoader:RequireFromParent(script, "UI/CCurrencyShopUICompClass")
FXLoader:RequireFromParent(script, "UI/CShopPurchaseUICompClass")
FXLoader:RequireFromParent(script, "UI/CWelfareUICompClass")
FXLoader:RequireFromParent(script, "UI/CMenuRetentionUICompClass")
FXLoader:RequireFromParent(script, "UI/CWorldTeleportUICompClass")
FXLoader:RequireFromParent(script, "UI/CSettingsUICompClass")
FXLoader:RequireFromParent(script, "UI/CGMIntegrationCompClass")
FXLoader:RequireFromParent(script, "UI/CCommonUICompClass")
local PlayerClass = FXLoader:RequireFromParent(script, "Player/CPlayerObjectClass")

FC.PlayerObject = PlayerClass.New(Players.LocalPlayer.UserId)

-- 在此添加项目客户端组件；UI 子类提供自己的原生节点和模板。
FC.WaitServerReady()
