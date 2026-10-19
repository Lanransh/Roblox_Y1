local FX = _G.FX
local Player = FX.Class("CPlayerObjectClass", "FCPlayerObjectClass")
_G.CPlayerObjectClass = Player

--- 构建客户端玩家对象并挂载当前项目的通用组件。
--- @param playerId number 当前玩家的 Roblox UserId。
function Player:Ctor(playerId)
    Player.Super.Ctor(self, playerId)
    self:AddComponent("CSoundCompClass")
    self:AddComponent("CCommonUICompClass")
    if FX.IsDeveloper(playerId) then
        self:AddComponent("CGMIntegrationCompClass"):OnReady()
    end
    self:AddComponent("CTrainingHUDCompClass")
    self:AddComponent("CLeaderboardUICompClass")
    self:AddComponent("FCFriendCompClass")
    self:AddComponent("CRockLevelCompClass")
    self:AddComponent("CRebirthIntegrationCompClass")
    self:AddComponent("CCollectionUICompClass")
    self:AddComponent("CLootSellUICompClass")
    self:AddComponent("CAuraShopUICompClass")
    self:AddComponent("CWeaponShopUICompClass")
    self:AddComponent("CCurrencyShopUICompClass")
    self:AddComponent("CShopPurchaseUICompClass")
    self:AddComponent("CWelfareUICompClass")
    self:AddComponent("CMenuRetentionUICompClass")
    self:AddComponent("CWorldTeleportUICompClass")
    self:AddComponent("CSettingsUICompClass")
    self:AddComponent("CMainUICompClass")
    self:AddComponent("CTutorialGuideCompClass")
end

--- 礼包显示前通过业务关闭入口收起其他弹窗，等待关闭动画及 OnHide 完成。
--- @param retainedComponent table 本次保留的礼包组件；主界面始终保留。
function Player:CloseOtherUI(retainedComponent)
    self:RequireComponent("FCCommonUIComp"):HideTooltips()
    self:RequireComponent("CLeaderboardUIComp"):ExitView()
    local closing = {}
    for className, component in pairs(self._components) do
        if component ~= retainedComponent and component:IsA("FCUICompClass")
            and component:GetCompName() ~= "CMainUIComp" then
            local root = component:GetRootNode()
            if root:IsA("ScreenGui") and root.Enabled then
                component:Hide()
                table.insert(closing, root)
            end
        end
    end
    for index, root in ipairs(closing) do
        while root.Parent and root.Enabled do
            task.wait()
        end
    end
end

return Player
