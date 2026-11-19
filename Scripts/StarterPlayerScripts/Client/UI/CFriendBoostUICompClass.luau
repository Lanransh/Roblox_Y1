local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
FXLoader:RequireFromParent(script, "Generated/CFriendBoostView")
local Component = FX.Class("CFriendBoostUICompClass", "CFriendBoostView")

--- 返回主界面打开好友加成窗口使用的协作名。
--- @return string 好友加成组件名。
function Component:GetCompName()
    return "CFriendBoostUIComp"
end

--- 绑定同服好友人数、邀请状态和语言变化，初始保持好友加成窗口关闭。
function Component:OnReady()
    Component.Super.OnReady(self)
    self:Hide()
    local config = _G.GameConfig.CommonConfig.InviteFriendData
    self.Config = {
        perFriendRate = config.AddRate,
        maxFriends = config.MaxCount,
    }
    self.State = {
        bonusRate = 0,
        invitePending = self:RequireComponent("CFriendInviteComp"):IsInvitePending(),
    }
    self:SubscribeEvent("FriendInvitePendingChanged", self.OnInvitePendingChanged)
    local player = self:GetPlayerObject()
    local commonUI = player:RequireComponent("FCCommonUIComp")
    commonUI:RegisterTrainingClickModal(self:GetRootNode())
    self:WatchDataChanged(Fields.TrainingFriendCount, function()
        self.State.bonusRate = CurrencyShop.GetFriendTrainingRate(player)
        self:RefreshUI()
    end)
    self:TrackConnection(commonUI.Localization.Changed:Connect(function()
        self:RefreshUI()
    end))
end

--- 将弹窗动作转为原生好友邀请或关闭窗口。
--- @param action string Invite 或 Close。
--- @param payload table 两种动作均无参数。
function Component:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
    elseif action == "Invite" then
        self:RequireComponent("CFriendInviteComp"):PromptInvite()
    end
end

--- 将共享邀请请求状态交给 View，两个入口发起请求时均禁止点击。
--- @param pending boolean 是否正在处理邀请请求。
function Component:OnInvitePendingChanged(pending)
    self.State.invitePending = pending
    self:RefreshUI()
end

return Component
