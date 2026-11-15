local FX = _G.FX
local Text = FX.Text
local UserInputService = game:GetService("UserInputService")
local Fields = _G.PlayerDataConfig
local TranslationTexts = Text.Define("TrainingRejoin", {
    Enabled = "Anti-AFK Mode: ON",
    Disabled = "Anti-AFK Mode: OFF",
})

--- 只处理训练重进状态和真实输入；按钮、布局与翻译刷新统一交给主界面。
local Component = FX.Class("CTrainingRejoinCompClass", "FCPlayerCompClass")

--- 提供主界面使用的业务组件名称，不注册独立界面。
--- @return string 组件协作名称。
function Component:GetCompName()
    return "CTrainingRejoinComp"
end

--- 订阅权威状态和真实输入，不创建 ScreenGui，也不模拟玩家操作。
function Component:OnReady()
    self._lastInput = os.clock()
    self:WatchDataChanged(Fields.TrainingRejoinEnabled, function()
        self._pending = false
        self:NotifyState()
    end)
    self:WatchDataChanged(Fields.TrainingFieldIndex, function()
        if self:GetNumber(Fields.TrainingFieldIndex) == 0 and self._requested then
            self:RecordInput()
        end
        self:NotifyState()
    end)
    local player = self:GetPlayerNode()
    self:TrackConnection(player:GetAttributeChangedSignal("TrainingRejoinStatus"):Connect(function()
        self:NotifyState()
    end))
    self:TrackConnection(player.Idled:Connect(function()
        -- 平台事件只确认空闲，不将回调参数或次数当作真实空闲时长。
        self._idled = true
    end))
    self:TrackConnection(UserInputService.InputBegan:Connect(function()
        self:RecordInput()
    end))
    self:TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.MouseWheel
            or input.UserInputType == Enum.UserInputType.Touch
            or (input.UserInputType.Name:find("Gamepad") and input.Position.Magnitude > 0.2) then
            self:RecordInput()
        end
    end))
end

--- 首次读取不依赖 OnReady 顺序；仅展示开启/关闭，内部等待状态只用于防止重复点击。
--- @return table enabled、pending、status、visible 和未翻译的 definition。
function Component:GetState()
    local enabled = self:GetFlag(Fields.TrainingRejoinEnabled)
    local status = self:GetPlayerNode():GetAttribute("TrainingRejoinStatus") or "Idle"
    local definition = enabled and TranslationTexts.Enabled or TranslationTexts.Disabled
    return {enabled = enabled, pending = self._pending == true, status = status,
        visible = self:GetNumber(Fields.TrainingFieldIndex) > 0, definition = definition}
end

--- 通过玩家已有事件分发通知主界面，避免持有或重复创建 UI 节点。
function Component:NotifyState()
    self:PublishEvent("TrainingRejoinChanged")
end

--- 真实输入开始新的空闲周期，只取消尚未开始的任务或失败后的重试。
function Component:RecordInput()
    self._lastInput = os.clock()
    self._idled = false
    if self._requested then
        self._requested = false
        FX.Network:SendMsgToServer("C2S_TrainingRejoin", "Cancel")
    end
end

--- 主界面只调用此入口；开关防重与按钮等待状态一起更新。
function Component:Toggle()
    local state = self:GetState()
    if state.pending or state.status == "Teleporting" then
        return
    end
    self:RecordInput()
    self._pending = true
    self._toggleDeadline = os.clock() + 5
    self:NotifyState()
    FX.Network:SendMsgToServer("C2S_TrainingRejoin", "SetEnabled", not state.enabled)
end

--- 复用框架每秒更新，保持原有空闲阈值、单轮请求与开关超时恢复。
--- @param serverTime number 框架传入的时间；空闲时长使用单调时钟。
function Component:OnUpdate(serverTime)
    local now = os.clock()
    if self._pending and now >= self._toggleDeadline then
        self._pending = false
        self:NotifyState()
    end
    if self._idled and not self._requested and not self._pending
        and self:GetFlag(Fields.TrainingRejoinEnabled) and self:GetNumber(Fields.TrainingFieldIndex) > 0
        and now - self._lastInput >= 15 * 60 then
        self._requested = true
        FX.Network:SendMsgToServer("C2S_TrainingRejoin", "Request")
    end
end

return Component
