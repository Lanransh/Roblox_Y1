local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage:WaitForChild("Scripts"):WaitForChild("GameInit"))
local FC = _G.FC
local FX = _G.FX
local FXLoader = FX.Loader
local Localization = FXLoader:RequireFromParent(script, "Localization")
FC.Localization = Localization.New(Players.LocalPlayer)

--- 以英文原文为 Key 复用当前玩家的翻译对象，供代码和配置显示统一调用。
--- @param source string 英文原文或原生参数模板。
--- @param arguments table? 原生模板参数。
--- @return string 当前玩家语言的文案，缺少译文时使用英文。
function FC.Tr(source, arguments)
    return FC.Localization:Tr(source, arguments)
end
FC.GiftDrop = require(script.Parent.GiftDrop)
FC.GiftDrop.Init()
require(script.Parent.Player.CSoundCompClass)
require(script.Parent.Player.CRockLevelCompClass)
require(script.Parent.Player.CTutorialGuideCompClass)
require(script.Parent.UI.CMainUICompClass)
require(script.Parent.UI.CTrainingHUDCompClass)
require(script.Parent.UI.CLeaderboardUICompClass)
require(script.Parent.UI.CRebirthIntegrationCompClass)
require(script.Parent.UI.CCollectionUICompClass)
require(script.Parent.UI.CLootSellUICompClass)
require(script.Parent.UI.CAuraShopUICompClass)
require(script.Parent.UI.CWeaponShopUICompClass)
require(script.Parent.UI.CCurrencyShopUICompClass)
require(script.Parent.UI.CShopPurchaseUICompClass)
require(script.Parent.UI.CWelfareUICompClass)
require(script.Parent.UI.CMenuRetentionUICompClass)
require(script.Parent.UI.CWorldTeleportUICompClass)
require(script.Parent.UI.CSettingsUICompClass)
require(script.Parent.UI.CGMIntegrationCompClass)
require(script.Parent.UI.CCommonUICompClass)
local PlayerClass = require(script.Parent.Player.CPlayerObjectClass)

FC.PlayerObject = PlayerClass.New(Players.LocalPlayer.UserId)

-- 在此添加项目客户端组件；UI 子类提供自己的原生节点和模板。
FC.WaitServerReady()
