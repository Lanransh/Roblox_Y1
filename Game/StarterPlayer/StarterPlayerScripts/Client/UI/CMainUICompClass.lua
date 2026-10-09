local FX = _G.FX
local FXLoader = FX.Loader
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Fields = _G.PlayerDataConfig
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local GameUtility = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.GameUtility)
local Component = FX.Class("CMainUICompClass", "FCUICompClass")

--- 返回主界面业务组件名，供项目组件协作使用。
--- @return string 主界面组件名。
function Component:GetCompName()
    return "CMainUIComp"
end

--- 服务端就绪后绑定并显示长生命周期主界面，初始同步不播放收益动画。
function Component:OnReady()
    self._playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    self._rootNode = FXLoader:Here(self._playerGui, "MainUI")
    self._rootNode.ResetOnSpawn = false
    local top = FXLoader:Here(self._rootNode, "TopCenter")
    self._bar = FXLoader:Here(top, "LevelProgressBar")
    self._strength = FXLoader:Here(top, "Strength/Value")
    self._rebirthBadge = FXLoader:Here(self._rootNode, "LeftCenter/RebirthButton/Badge")
    self._rebirthBadge.AutoLocalize = false
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._localization = self._commonUI.Localization
    self._strength.AutoLocalize = false
    self._bar.ProgressLabel.AutoLocalize = false
    --- 翻译就绪或语言切换时刷新主界面，出售界面自行监听语言变化。
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    self._leftDown = FXLoader:Here(self._rootNode, "LeftDown")
    self._effects = {}
    self._lastClick = -math.huge
    -- 复用 Rojo 管理的 ScreenGui，飘字直属该节点，不受 Canvas 缩放影响。
    self._effectGui = FXLoader:Here(self._playerGui, "ScreenGui")
    self._pulseScale = Instance.new("UIScale")
    self._pulseScale.Parent = self._strength
    self:BindButtons()
    --- 走路及击打按服务端结算播放，点击图标由本地输入立即播放。
    --- @param gain number 服务端确认的走路及击打收益。
    FX.Network:RegServerMsgCallback("S2C_TrainingEffect", function(gain)
        self:ShowTrainingEffect(gain)
    end)
    self:WatchDataChanged(Fields.RockTrainingValue, self.RefreshProgress, self)
    self:WatchDataChanged(Fields.RebirthCount, function()
        self:RefreshProgress(self:GetNumber(Fields.RockTrainingValue))
    end, self)
    self:WatchDataChanged(Fields.Coins, self.RefreshCoins, self)
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirthCount, self)
    self:WatchDataChanged(Fields.Diamonds, self.RefreshDiamonds, self)
    self:WatchDataChanged(Fields.LootSellEntries, self.RefreshLoot, self)
    --- 鼠标只在未被按钮、背包等 UI 消耗时播放点击图标。
    --- @param input InputObject 本次输入。
    --- @param processed boolean 是否已被引擎 UI 消耗。
    self:TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            self:ShowClickTrainingEffect(Vector2.new(input.Position.X, input.Position.Y))
        end
    end))
    --- 触屏只为世界轻触播放点击图标，忽略摇杆拖动和界面点击。
    --- @param position Vector2 引擎提供的轻触位置，作为图标飞行起点。
    --- @param processed boolean 是否被界面消耗。
    self:TrackConnection(UserInputService.TouchTapInWorld:Connect(function(position, processed)
        if not processed then
            self:ShowClickTrainingEffect(position)
        end
    end))
    self:Show()
end

--- 只按显式禁点标记判断 UI 占用，弹窗状态由通用 UI 统一查询。
--- @param position Vector2 本次点击或轻触的屏幕像素坐标。
--- @return boolean 是否为可点击的主界面空白区域。
function Component:IsBlankMainArea(position)
    if not self._rootNode.Enabled or self._commonUI:IsTrainingClickBlocked() then
        return false
    end
    for index, node in ipairs(self._playerGui:GetGuiObjectsAtPosition(position.X, position.Y)) do
        local visible = true
        local blocked = false
        local ancestor = node
        while ancestor and ancestor ~= self._playerGui do
            if self._effects[ancestor]
                or (ancestor:IsA("GuiObject") and not ancestor.Visible)
                or (ancestor:IsA("ScreenGui") and not ancestor.Enabled) then
                visible = false
                break
            end
            if ancestor:GetAttribute("BlocksTrainingClick") == true then
                blocked = true
            end
            ancestor = ancestor.Parent
        end
        if visible and blocked then
            return false
        end
    end
    return true
end

--- 主界面空白区域本地限速后播放点击图标，仅做表现，不发送请求或增加训练值。
--- @param position Vector2 本次点击或轻触的屏幕像素坐标。
function Component:ShowClickTrainingEffect(position)
    local now = os.clock()
    if UserInputService:GetFocusedTextBox() or now - self._lastClick < RockLevel.ClickInterval
        or not self:IsBlankMainArea(position) then
        return
    end
    self._lastClick = now
    self:ShowTrainingEffect(RockLevel.ClickEffectValue, position)
end

--- 标记主界面实际内容区域；图鉴交给独立 UI 组件，重生模板缺失时显示开发中。
function Component:BindButtons()
    for index, path in ipairs({"TopCenter/LevelProgressBar", "TopCenter/Strength",
        "LeftDown/RebirthStat", "LeftDown/BackpackStat", "LeftDown/CashStat", "LeftDown/DiamondStat"}) do
        FXLoader:Here(self._rootNode, path):SetAttribute("BlocksTrainingClick", true)
    end
    for index, node in ipairs(self._rootNode:GetDescendants()) do
        if node:IsA("GuiButton") then
            node:SetAttribute("BlocksTrainingClick", true)
            self:TrackConnection(node.Activated:Connect(function()
                if node.Name == "CollectionBtn" then
                    self:GetPlayerObject():RequireComponent("CCollectionUIComp"):Show()
                else
                    self:ShowDeveloping()
                end
            end))
        end
    end
end

--- 语言变化只刷新当前数据显示，不播放训练收益动画或重新打开已关闭弹窗。
function Component:RefreshLocalization()
    self:RefreshProgress(self:GetNumber(Fields.RockTrainingValue))
end

--- 未实现的入口统一走现有通用提示，不伪造购买或奖励成功。
function Component:ShowDeveloping()
    self._commonUI:ShowLocalizedTips("Common.InDevelopment")
end

--- 金币余额随服务端同步刷新，保留货币前缀并统一使用数量格式。
--- @param value number 同步后的金币余额。
function Component:RefreshCoins(value)
    FXLoader:Here(self._leftDown, "CashStat/Value").Text = "$" .. GameUtility.NumberToText(value)
end

--- 重生次数随持久字段刷新，按次数语义显示整数。
--- @param value number 同步后的累计重生次数。
function Component:RefreshRebirthCount(value)
    FXLoader:Here(self._leftDown, "RebirthStat/Value").Text = string.format("%d", value)
end

--- 钻石读取持久字段并使用通用数量格式，默认 500 由服务端字段定义提供。
--- @param value number 同步后的钻石数量。
function Component:RefreshDiamonds(value)
    FXLoader:Here(self._leftDown, "DiamondStat/Value").Text = GameUtility.NumberToText(value)
end

--- 背包计数与出售列表使用同一正式库存快照，出售后同步腾出容量。
--- @param loot table 正式背包中的可出售收藏品。
function Component:RefreshLoot(loot)
    self._leftDown.BackpackStat.Value.Text = string.format("%d/%d", #loot,
        _G.Provider:GetNativeBackpackConfig().InventoryCapacity)
end

--- 刷新经验、力量与整数重生百分比；经验条以 0.3 秒 Quad Out 平滑填充。
--- @param value number 同步后的累计训练值。
--- @param oldValue number? 上一次训练值，首次回放为 nil。
function Component:RefreshProgress(value, oldValue)
    local rebirthRequiredLevel = Rebirth.GetRequiredLevel(self:GetNumber(Fields.RebirthCount))
    local level, strength, progressValue, required = RockLevel.GetProgress(value, rebirthRequiredLevel)
    self._rebirthBadge.Text = string.format("%d%%", math.floor(math.clamp(level / rebirthRequiredLevel, 0, 1) * 100))
    local progress = math.clamp(progressValue / required, 0, 1)
    self._bar.LevelLabel.Text = string.format("Lv.%d", level)
    self._bar.ProgressLabel.Text = string.format("%s/%s",
        GameUtility.NumberToText(math.min(progressValue, required)), GameUtility.NumberToText(required))
    self._strength.Text = self._localization:FormatByKey("Main.Strength", {value = GameUtility.NumberToText(strength)})
    if level >= RockLevel.MaxLevel then
        progress = 1
        self._bar.ProgressLabel.Text = self._localization:FormatByKey("Main.MaxLevel")
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

--- 点击显示一个全额图标，走路及击打在角色周围独立随机显示三个均分图标，飞向中心时最小缩至 50%。
--- @param gain number 点击时为配置的表现数值，走路及击打时为服务器确认的收益。
--- @param position Vector2? 点击起点，走路及击打收益不传。
function Component:ShowTrainingEffect(gain, position)
    -- 完整屏幕与角色投影都转换到共用 ScreenGui 的局部坐标，避免安全区造成偏移。
    local origin = self._effectGui.AbsolutePosition
    local screenArea = GuiService:GetInsetArea(Enum.ScreenInsets.None)
    local target = (screenArea.Min + screenArea.Max) / 2 - origin
    local spawnCenter = target
    if not position then
        local character = self:GetPlayerNode().Character
        local camera = workspace.CurrentCamera
        if character and camera then
            local projected, onScreen = camera:WorldToScreenPoint(character:GetPivot().Position)
            if onScreen then
                spawnCenter = Vector2.new(projected.X, projected.Y) - origin
            end
        end
    end
    local count = position and 1 or 3
    -- 先均分实际收益再统一格式化，仅改变客户端文案，不改变服务端奖励。
    local gainText = GameUtility.NumberToText(gain / count)
    for index = 1, count do
        local startPosition
        if position then
            startPosition = position - origin
        else
            -- 每个图标独立选择方向和距离，避免同批图标呈固定三角形分布。
            local angle = math.random() * math.pi * 2
            local radius = math.random(180, 300)
            startPosition = spawnCenter + Vector2.new(math.cos(angle), math.sin(angle)) * radius
        end
        local initialDistance = math.max((startPosition - target).Magnitude, 1)
        local icon = self._bar.StrengthIcon:Clone()
        icon.Name = "TrainingGain"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromOffset(startPosition.X, startPosition.Y)
        icon.Size = UDim2.fromOffset(80, 80)
        icon.Visible = true
        icon.Parent = self._effectGui
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromOffset(100, 30)
        label.Position = UDim2.new(0.5, -50, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 28
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.3
        label.Text = "+" .. gainText
        label.Parent = icon
        local effect = {}
        self._effects[icon] = effect
        --- 按实际剩余路程计算图标尺寸，抵达中心时仍保留初始大小的一半。
        local function UpdateSize()
            local currentPosition = Vector2.new(icon.Position.X.Offset, icon.Position.Y.Offset)
            local remaining = math.clamp((currentPosition - target).Magnitude / initialDistance, 0, 1)
            local size = 80 * (0.5 + 0.5 * remaining)
            icon.Size = UDim2.fromOffset(size, size)
        end
        effect.SizeConnection = icon:GetPropertyChangedSignal("Position"):Connect(UpdateSize)
        UpdateSize()
        --- 动画结束后释放本次飘字与尺寸监听，走路及击打收益保留力量栏到账反馈。
        effect.Task = task.spawn(function()
            effect.Tween = TweenService:Create(icon,
                TweenInfo.new(0.62, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.fromOffset(target.X, target.Y), ImageTransparency = 0.8,
                })
            effect.Tween:Play()
            effect.Tween.Completed:Wait()
            effect.SizeConnection:Disconnect()
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

--- 释放自建节点和未结束动画，保留共用 ScreenGui；基类负责取消数据及按钮监听。
function Component:Dtor()
    FX.Network:UnRegServerMsgCallback("S2C_TrainingEffect")
    for icon, effect in pairs(self._effects or {}) do
        task.cancel(effect.Task)
        effect.SizeConnection:Disconnect()
        effect.Tween:Cancel()
        effect.Tween:Destroy()
        icon:Destroy()
    end
    for name, tween in pairs({Progress = self._progressTween, Pulse = self._pulseTween}) do
        tween:Cancel()
        tween:Destroy()
    end
    for name, node in pairs({Pulse = self._pulseScale}) do
        node:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
