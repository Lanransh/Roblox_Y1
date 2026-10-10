local FX = _G.FX
local FXLoader = FX.Loader
FXLoader:RequireFromParent(script, "Generated/CRebirthUICompClass")
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Component = FX.Class("CRebirthIntegrationCompClass", "CRebirthUICompClass")

function Component:GetCompName()
    return "CRebirthUIComp"
end

function Component:OnReady()
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(root)
    self._localization = self._commonUI.Localization
    root.AutoLocalize = true
    for _, node in ipairs(root:GetDescendants()) do
        if node:IsA("GuiObject") then
            node.AutoLocalize = true
        end
    end
    self.State = {Open = false, Completed = false, Pending = false}
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshRebirth()
    end))
    self:WatchDataChanged(Fields.RockTrainingLevel, self.RefreshRebirth, self)
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirth, self)
    self:RefreshRebirth()
end

-- 倍率和门槛与服务端共用曲线，不使用设计稿示例数值。
function Component:RefreshRebirth()
    local count = self:GetNumber(Fields.RebirthCount)
    local nextCount = math.min(count + 1, Rebirth.MaxCount)
    self.State.Level = self:GetNumber(Fields.RockTrainingLevel)
    self.State.RequiredLevel = Rebirth.GetRequiredLevel(count)
    self.State.CurrentStrengthMultiplier = Rebirth.GetTrainingRate(count)
    self.State.NextStrengthMultiplier = Rebirth.GetTrainingRate(nextCount)
    self.State.CurrentMoneyMultiplier = Rebirth.GetMoneyRate(count)
    self.State.NextMoneyMultiplier = Rebirth.GetMoneyRate(nextCount)
    self:RefreshUI()
end

function Component:Render(state)
    Component.Super.Render(self, state)
    -- 灰色表达未达标，但保留点击以显示门槛；请求中才禁用。
    self:SetButtonEnabled(self.RebirthBtn, state.Open and not state.Pending)
    self:SetButtonEnabled(self.SkipBtn, state.Open and not state.Pending)
    self.ProgressTxt.Text = self._localization:FormatByKey("Rebirth.Progress", {
        level = state.Level, required = state.RequiredLevel,
    })
    self.WarningTxt.Text = self._localization:FormatByKey("Rebirth.ResetWarning")
    if self:GetNumber(Fields.RebirthCount) >= Rebirth.MaxCount then
        self.RebirthBtn.BackgroundColor3 = Color3.fromHex("#B7B7B7")
        self.RebirthGradient.Enabled = true
        self.WarningTxt.Text = self._localization:FormatByKey("Rebirth.MaxCount")
    end
end

function Component:OnShow()
    self.State.Open = true
    self:RefreshRebirth()
end

function Component:OnHide()
    self.State.Open = false
end

function Component:OnUIAction(action, payload)
    if action == "CloseRebirth" then
        self:Hide()
        return
    end
    if self.State.Pending then return end
    if self:GetNumber(Fields.RebirthCount) >= Rebirth.MaxCount then
        self._commonUI:ShowLocalizedTips("Rebirth.MaxCount")
        return
    end
    if action == "RequestSkip" then
        self._commonUI:ShowLocalizedTips("Common.InDevelopment")
        return
    end
    assert(action == "RequestRebirth", "Unsupported rebirth action: " .. tostring(action))
    local required = Rebirth.GetRequiredLevel(self:GetNumber(Fields.RebirthCount))
    if self:GetNumber(Fields.RockTrainingLevel) < required then
        self._commonUI:ShowLocalizedTips("Rebirth.RequiredLevel", {level = required})
        return
    end
    self.State.Pending = true
    self:RefreshUI()
    self._rebirthTask = task.defer(function()
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_Rebirth")
        end)
        self._rebirthTask = nil
        self.State.Pending = false
        if not ok or type(result) ~= "table" then
            self._commonUI:ShowLocalizedTips("Common.Unknown")
        end
        -- 成败提示由服务端发送；后续门槛与倍率由正式数据同步刷新。
        self:RefreshRebirth()
    end)
end

function Component:Dtor()
    if self._rebirthTask then
        task.cancel(self._rebirthTask)
        self._rebirthTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
