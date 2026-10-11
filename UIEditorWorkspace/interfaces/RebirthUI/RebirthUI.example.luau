local FX = _G.FX
local Preview = FX.Class("CRebirthPreviewCompClass", "CRebirthUICompClass")

-- 父构造后准备符合展示契约的模拟数据。
-- @param owner table 编辑器组件宿主
function Preview:Ctor(owner)
    Preview.Super.Ctor(self, owner)
    self.State = {
        Open = true,
        Level = 317,
        RequiredLevel = 325,
        Completed = false,
        CurrentStrengthMultiplier = 7,
        NextStrengthMultiplier = 7.5,
        CurrentMoneyMultiplier = 3.4,
        NextMoneyMultiplier = 3.6,
    }
end

-- 先绑定节点，再绑定完整数据并显示界面。
function Preview:OnReady()
    Preview.Super.OnReady(self)
    self:BindUIData()
    self:Show()
end

-- 模拟即时成功；拒绝隐藏、未就绪、请求中及完成后的业务动作。
-- @param action string CloseRebirth / RequestSkip / RequestRebirth
-- @param payload table 空表，与展示���约一致
function Preview:OnUIAction(action, payload)
    if action == "CloseRebirth" then
        self.State.Open = false
    elseif action == "RequestSkip" or action == "RequestRebirth" then
        if not self.State.Open or self.State.RequiredLevel <= 0 or self.State.Completed or self.State.Pending then
            return
        end
        if action == "RequestSkip" then
            self.State.Level = self.State.RequiredLevel
            print("模拟 Skip：满足等级条件，未执行支付")
        elseif self.State.Level >= self.State.RequiredLevel then
            -- 仅模拟现有差值成长；真实倍率须由游戏业务提供。
            local strengthIncrease = self.State.NextStrengthMultiplier - self.State.CurrentStrengthMultiplier
            local moneyIncrease = self.State.NextMoneyMultiplier - self.State.CurrentMoneyMultiplier
            self.State.CurrentStrengthMultiplier = self.State.NextStrengthMultiplier
            self.State.CurrentMoneyMultiplier = self.State.NextMoneyMultiplier
            self.State.NextStrengthMultiplier = self.State.CurrentStrengthMultiplier + strengthIncrease
            self.State.NextMoneyMultiplier = self.State.CurrentMoneyMultiplier + moneyIncrease
            self.State.Level = 0
            self.State.Completed = true
            print("模拟重生：力量重置，未修改游戏数据")
        end
    else
        error("Unsupported rebirth action: " .. tostring(action))
    end
    self:RefreshUI()
end

return Preview
