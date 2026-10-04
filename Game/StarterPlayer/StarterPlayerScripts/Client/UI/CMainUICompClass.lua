local FX = _G.FX
local Fields = _G.PlayerDataConfig
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local Component = FX.Class("CMainUICompClass", "FCUICompClass")

--- 返回主界面业务组件名，供项目组件协作使用。
--- @return string 主界面组件名。
function Component:GetCompName()
    return "CMainUIComp"
end

--- 服务端就绪后绑定一次长生命周期界面，初始同步不播放收益动画。
function Component:OnReady()
    self._playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    self._rootNode = self._playerGui:WaitForChild("MainUI")
    self._rootNode.ResetOnSpawn = false
    local top = self._rootNode:WaitForChild("TopCenter")
    self._bar = top:WaitForChild("LevelProgressBar")
    self._strength = top:WaitForChild("Strength"):WaitForChild("Value")
    self._leftDown = self._rootNode:WaitForChild("LeftDown")
    self._effects = {}
    self._lastClick = -math.huge
    -- 特效单独放在屏幕坐标层，避免主界面的分组缩放脚本改变飞行终点。
    self._effectGui = Instance.new("ScreenGui")
    self._effectGui.Name = "TrainingEffects"
    self._effectGui.ResetOnSpawn = false
    self._effectGui.IgnoreGuiInset = true
    self._effectGui.ScreenInsets = Enum.ScreenInsets.None
    self._effectGui.DisplayOrder = self._rootNode.DisplayOrder + 1
    self._effectGui.Parent = self._playerGui
    self._pulseScale = Instance.new("UIScale")
    self._pulseScale.Parent = self._strength
    self:BindButtons()
    --- 使用收益来源决定动画路线，不从合并后的训练值变化猜测点击。
    --- @param gain number 服务端确认的收益。
    --- @param position Vector2? 点击的原始屏幕坐标，自动收益为空。
    FX.Network:RegServerMsgCallback("S2C_TrainingEffect", function(gain, position)
        self:ShowTrainingEffect(gain, position)
    end)
    self:WatchDataChanged(Fields.RockTrainingValue, self.RefreshProgress, self)
    self:WatchDataChanged(Fields.Diamonds, self.RefreshDiamonds, self)
    self:WatchDataChanged(Fields.RockLoot, self.RefreshLoot, self)
    --- 鼠标只在未被按钮、背包等 UI 消耗时触发训练。
    --- @param input InputObject 本次输入。
    --- @param processed boolean 是否已被引擎 UI 消耗。
    self:TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            self:RequestTraining(Vector2.new(input.Position.X, input.Position.Y))
        end
    end))
    --- 触屏只处理世界轻触，不把摇杆拖动和界面点击当训练。
    --- @param position Vector2 引擎提供的轻触位置，作为图标飞行起点。
    --- @param processed boolean 是否被界面消耗。
    self:TrackConnection(UserInputService.TouchTapInWorld:Connect(function(position, processed)
        if not processed then
            self:RequestTraining(position)
        end
    end))
end

--- 本地限速减少无效请求，奖励和实际限速仍由服务端决定。
--- @param position Vector2 本次点击或轻触的屏幕像素坐标。
function Component:RequestTraining(position)
    local now = os.clock()
    if UserInputService:GetFocusedTextBox() or now - self._lastClick < RockLevel.ClickInterval then
        return
    end
    self._lastClick = now
    FX.Network:SendMsgToServer("C2S_ClickTraining", position)
end

--- 所有现有主界面按钮均有响应；已存在重生界面可打开，其余显示开发中。
function Component:BindButtons()
    local rebirth = self._playerGui:WaitForChild("RebirthUI")
    rebirth.ResetOnSpawn = false
    rebirth.Enabled = false
    for index, node in ipairs(rebirth:GetDescendants()) do
        if node:IsA("GuiButton") then
            self:TrackConnection(node.Activated:Connect(function()
                if node.Name == "CloseBtn" then
                    rebirth.Enabled = false
                else
                    self:ShowDeveloping()
                end
            end))
        end
    end
    for index, node in ipairs(self._rootNode:GetDescendants()) do
        if node:IsA("GuiButton") then
            self:TrackConnection(node.Activated:Connect(function()
                if node.Name == "RebirthButton" then
                    rebirth.Enabled = true
                else
                    self:ShowDeveloping()
                end
            end))
        end
    end
    local lootButton = Instance.new("TextButton")
    lootButton.Name = "OpenLoot"
    lootButton.Text = ""
    lootButton.BackgroundTransparency = 1
    lootButton.Size = UDim2.fromScale(1, 1)
    lootButton.ZIndex = 10
    lootButton.Parent = self._leftDown:WaitForChild("BackpackStat")
    self._lootButton = lootButton
    self:TrackConnection(lootButton.Activated:Connect(function()
        local lines = {"战利品背包（返回基地自动存放）"}
        for index, entry in ipairs(self:GetTable(Fields.RockLoot)) do
            table.insert(lines, string.format("%s  $%d", entry.DisplayName, entry.Price))
        end
        if #lines == 1 then
            table.insert(lines, "暂无战利品")
        end
        self:GetPlayerObject():RequireComponent("FCCommonUIComp"):ShowTooltips({
            Desc = table.concat(lines, "\n"), ConfirmBtnTxt = "关闭",
        })
    end))
end

--- 未实现的入口统一走现有通用提示，不伪造购买或奖励成功。
function Component:ShowDeveloping()
    self:GetPlayerObject():RequireComponent("FCCommonUIComp"):ShowTips("开发中")
end

--- 钻石从持久字段显示，默认 500 由服务端字段定义提供。
--- @param value number 同步后的钻石数量。
function Component:RefreshDiamonds(value)
    self._leftDown:WaitForChild("DiamondStat"):WaitForChild("Value").Text = tostring(value)
end

--- 战利品与原生背包分别显示，拾取后可以直接确认当前携带数量。
--- @param loot table 当前尚未回基地存放的道具。
function Component:RefreshLoot(loot)
    self._leftDown.BackpackStat.Value.Text = string.format("%d/%d", #loot, RockLevel.LootCapacity)
end

--- 沿用累计经验减当前等级门槛的进度算法，以及 0.3 秒 Quad Out 平滑填充。
--- @param value number 同步后的累计训练值。
--- @param oldValue number? 上一次训练值，首次回放为 nil。
function Component:RefreshProgress(value, oldValue)
    local level, strength, progressValue, required = RockLevel.GetProgress(value)
    local progress = math.clamp(progressValue / required, 0, 1)
    self._bar.LevelLabel.Text = string.format("Lv.%d", level)
    self._bar.ProgressLabel.Text = string.format("%d/%d", math.min(progressValue, required), required)
    self._strength.Text = string.format("力量:%s", tostring(strength))
    if level >= RockLevel.MaxLevel then
        progress = 1
        self._bar.ProgressLabel.Text = "已满级"
    end
    local size = UDim2.new(progress, 0, 1, 0)
    if self._progressTween then
        self._progressTween:Cancel()
        self._progressTween:Destroy()
    end
    if oldValue == nil then
        self._bar.Fill.Size = size
    else
        self._progressTween = TweenService:Create(self._bar.Fill,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = size})
        self._progressTween:Play()
    end
end

--- 点击收益从原点击位置直飞屏幕中央，自动收益保留中心散开后飞向力量栏。
--- @param gain number 本次服务器确认增加的训练值。
--- @param position Vector2? 点击起点，自动训练收益不传。
function Component:ShowTrainingEffect(gain, position)
    local count = position and 1 or math.random(2, 3)
    for index = 1, count do
        local icon = self._bar.StrengthIcon:Clone()
        icon.Name = "TrainingGain"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = position and UDim2.fromOffset(position.X, position.Y) or UDim2.fromScale(0.5, 0.58)
        icon.Size = UDim2.fromOffset(42, 42)
        icon.Visible = true
        icon.Parent = self._effectGui
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromOffset(100, 30)
        label.Position = UDim2.new(0.5, -50, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 24
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.3
        label.Text = "+" .. tostring(gain)
        label.Parent = icon
        local effect = {}
        self._effects[icon] = effect
        effect.Task = task.spawn(function()
            if not position then
                effect.Tween = TweenService:Create(icon,
                    TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.5, math.random(-150, 150), 0.58, math.random(-120, 20)),
                        Size = UDim2.fromOffset(45, 45),
                    })
                effect.Tween:Play()
                effect.Tween.Completed:Wait()
                effect.Tween:Destroy()
            end
            local target = self._strength.AbsolutePosition + self._strength.AbsoluteSize / 2
            effect.Tween = TweenService:Create(icon,
                TweenInfo.new(0.62, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = position and UDim2.fromScale(0.5, 0.5) or UDim2.fromOffset(target.X, target.Y),
                    Size = UDim2.fromOffset(25, 25), ImageTransparency = 0.8,
                })
            effect.Tween:Play()
            effect.Tween.Completed:Wait()
            effect.Tween:Destroy()
            self._effects[icon] = nil
            icon:Destroy()
            if not position then
                self:PulseStrength()
            end
        end)
    end
end

--- 到账时轻微放大力量文字再复原，连续动画不累加缩放。
function Component:PulseStrength()
    if self._pulseTween then
        self._pulseTween:Cancel()
        self._pulseTween:Destroy()
    end
    self._pulseScale.Scale = 1
    self._pulseTween = TweenService:Create(self._pulseScale,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Scale = 1.1})
    self._pulseTween:Play()
end

--- 释放界面自建节点和未结束动画，基类负责取消数据及按钮监听。
function Component:Dtor()
    FX.Network:UnRegServerMsgCallback("S2C_TrainingEffect")
    for icon, effect in pairs(self._effects or {}) do
        task.cancel(effect.Task)
        effect.Tween:Cancel()
        effect.Tween:Destroy()
        icon:Destroy()
    end
    for name, tween in pairs({Progress = self._progressTween, Pulse = self._pulseTween}) do
        tween:Cancel()
        tween:Destroy()
    end
    for name, node in pairs({Effects = self._effectGui, Pulse = self._pulseScale, Loot = self._lootButton}) do
        node:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
