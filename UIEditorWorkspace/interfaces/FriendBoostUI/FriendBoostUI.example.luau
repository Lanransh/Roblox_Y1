local FX = _G.FX
local CFriendBoostPreview = FX.Class("CFriendBoostPreview", "CFriendBoostView")

--- 使用两位同服好友的示例展示当前加成。
--- @param owner table 编辑器提供的组件宿主。
function CFriendBoostPreview:Ctor(owner)
    CFriendBoostPreview.Super.Ctor(self, owner)
    self.Config = {
        perFriendRate = 0.25,
        maxFriends = 4,
    }
    self.State = {
        bonusRate = 0.5,
        invitePending = false,
    }
end

--- 绑定完成后显示示例倍率和计入规则。
function CFriendBoostPreview:OnReady()
    CFriendBoostPreview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

--- 记录预览邀请动作，关闭时隐藏窗口。
--- @param action string Invite 或 Close。
--- @param payload table 两个动作均不包含业务参数。
function CFriendBoostPreview:OnUIAction(action, payload)
    if action == "Close" then
        self:Hide()
    elseif action == "Invite" then
        print("Friend Boost preview: Invite")
    end
end

return CFriendBoostPreview
