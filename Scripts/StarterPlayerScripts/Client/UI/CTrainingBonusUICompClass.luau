local FX, FC = _G.FX, _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local TranslationTexts = Text.Define("TrainingBonus", {
    Multiplier = "×{rate}",
})
local Fields = _G.PlayerDataConfig
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Colors = {Color3.fromRGB(47, 203, 255), Color3.fromRGB(232, 65, 136), Color3.fromRGB(255, 172, 39)}
local Component = FX.Class("CTrainingBonusUICompClass", "FCUICompClass")

--- 返回挂机随机倍率气泡的协作名。
--- @return string 组件名称。
function Component:GetCompName()
    return "CTrainingBonusUIComp"
end

--- 创建随屏幕短边缩放的气泡、倒计时圆环与全屏边缘光；服务端属性决定实际加成。
function Component:OnReady()
    self._commonUI = self:RequireComponent("FCCommonUIComp")
    self._random = Random.new()
    local root = Instance.new("ScreenGui")
    root.Name = "TrainingBonusUI"
    root.ResetOnSpawn = false
    root.DisplayOrder = 15
    self._rootNode = root
    self:CreateEdgeGlow()

    local flash = Instance.new("Frame")
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.Parent = root
    self._flash = flash

    local speedLines = Instance.new("Frame")
    speedLines.Name = "AccelerationSpeedLines"
    speedLines.Size = UDim2.fromScale(1, 1)
    speedLines.BackgroundTransparency = 1
    speedLines.ClipsDescendants = true
    speedLines.Visible = false
    speedLines.Parent = root
    self._speedLines = speedLines
    self._lines = {}
    for index = 1, 24 do
        local angle = (index - 1) / 24 * math.pi * 2
        local line = Instance.new("Frame")
        line.Name = "SpeedLine" .. index
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        line.Parent = speedLines
        local gradient = Instance.new("UIGradient")
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0),
            NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = line
        self._lines[index] = {Node = line, Direction = Vector2.new(math.cos(angle), math.sin(angle)),
            Phase = self._random:NextNumber(), Speed = self._random:NextNumber(1.5, 2.4)}
    end

    local bubbleAnchor = Instance.new("Frame")
    bubbleAnchor.Name = "BubbleAnchor"
    bubbleAnchor.Size = UDim2.fromOffset(0, 0)
    bubbleAnchor.BackgroundTransparency = 1
    bubbleAnchor.Parent = root
    self._bubbleAnchor = bubbleAnchor
    self._responsiveScale = Instance.new("UIScale", bubbleAnchor)

    local button = Instance.new("TextButton")
    button.Name = "MultiplierBubble"
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Size = UDim2.fromOffset(160, 160)
    button.AutoLocalize = false
    button.Text = ""
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextStrokeTransparency = 0.35
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 60
    button.Visible = false
    button:SetAttribute("BlocksTrainingClick", true)
    button.Parent = bubbleAnchor
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 3
    stroke.Parent = button
    self._bubble = button
    self._scale = Instance.new("UIScale", button)
    self._scale.Scale = 0.6

    self._ringSegments = {}
    for index = 1, 96 do
        local angle = (index - 1) / 96 * math.pi * 2 - math.pi / 2
        local segment = Instance.new("Frame")
        segment.Name = "CountdownSegment" .. index
        segment.AnchorPoint = Vector2.new(0.5, 0.5)
        segment.Size = UDim2.fromOffset(6, 8)
        segment.Position = UDim2.new(0.5, math.cos(angle) * 88, 0.5, math.sin(angle) * 88)
        segment.Rotation = math.deg(angle) + 90
        segment.BackgroundColor3 = Color3.new(1, 1, 1)
        segment.BorderSizePixel = 0
        segment.Parent = button
        self._ringSegments[index] = segment
    end

    root.Parent = FXLoader:Player("PlayerGui")
    self:TrackConnection(button.Activated:Connect(function()
        local offerId = self:GetPlayerNode():GetAttribute("TrainingBonusOfferId")
        if offerId and offerId == self._offerId and self._pendingId ~= offerId
            and not self._commonUI:IsTrainingClickBlocked() then
            self._pendingId = offerId
            button.Visible = false
            FX.Network:SendMsgToServer("C2S_ClaimTrainingBonus", offerId)
        end
    end))
    self:TrackConnection(RunService.RenderStepped:Connect(function(deltaTime)
        self:RefreshBonus(deltaTime)
    end))
end

--- 边缘光越过设备安全区覆盖完整视口，四边向画面中心渐隐，不拦截点击。
function Component:CreateEdgeGlow()
    local root = Instance.new("ScreenGui")
    root.Name = "TrainingBonusEdgeGlow"
    root.ResetOnSpawn = false
    root.ScreenInsets = Enum.ScreenInsets.None
    root.ClipToDeviceSafeArea = false
    root.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
    root.DisplayOrder = 14
    local group = Instance.new("CanvasGroup")
    group.Name = "EdgeGlow"
    group.Size = UDim2.fromScale(1, 1)
    group.BackgroundTransparency = 1
    group.GroupTransparency = 1
    group.Visible = false
    group.Parent = root
    self._edgeGlow = group
    self._edgeGlowStrength = 0
    self._glowEdges = {}
    for index, layout in ipairs({
        {Name = "Top", Position = Vector2.new(0, 0), Rotation = 90},
        {Name = "Bottom", Position = Vector2.new(0, 1), Rotation = 270},
        {Name = "Left", Position = Vector2.new(0, 0), Rotation = 0},
        {Name = "Right", Position = Vector2.new(1, 0), Rotation = 180},
    }) do
        local edge = Instance.new("Frame")
        edge.Name = layout.Name
        edge.AnchorPoint = layout.Position
        edge.Position = UDim2.fromScale(layout.Position.X, layout.Position.Y)
        edge.BorderSizePixel = 0
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = layout.Rotation
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.35, 0.6),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = edge
        edge.Parent = group
        self._glowEdges[index] = edge
    end
    root.Parent = FXLoader:Player("PlayerGui")
    self._edgeGlowRoot = root
end

--- 四边厚度统一按视口短边计算；加成期间呼吸发光，结束后淡出。
--- @param active boolean 服务端确认的加成是否生效。
--- @param color Color3 当前倍率主题色。
--- @param deltaTime number 本帧间隔。
function Component:RefreshEdgeGlow(active, color, deltaTime)
    local strength = math.clamp(self._edgeGlowStrength + deltaTime * (active and 4 or -3), 0, 1)
    self._edgeGlowStrength = strength
    self._edgeGlow.Visible = strength > 0
    self._edgeGlow.GroupTransparency = 1 - strength * (0.8 + math.sin(os.clock() * 3) * 0.1)
    local size = self._edgeGlow.AbsoluteSize
    local thickness = math.min(size.X, size.Y) * 0.1
    for index, edge in ipairs(self._glowEdges) do
        edge.Size = index <= 2 and UDim2.new(1, 0, 0, thickness) or UDim2.new(0, thickness, 1, 0)
        edge.BackgroundColor3 = color
    end
end

--- 随机选择安全画面位置并弹入至 0.6 倍缩放，保证倍率文字和点击区域清晰；重复刷新同一个凭据不重新移动。
function Component:ShowBubble()
    self._remainingSegments = nil
    self._position = Vector2.new(self._random:NextNumber(0.25, 0.75), self._random:NextNumber(0.3, 0.65))
    self._scale.Scale = 0.2
    if self._popTween then
        self._popTween:Cancel()
    end
    self._popTween = TweenService:Create(self._scale,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0.6})
    self._popTween:Play()
end

--- 为本地角色创建上冲光粒和手部短拖尾；镜头由逐帧刷新在可用时绑定。
--- @param character Model 当前存活角色。
--- @param color Color3 本次倍率的主题色。
function Component:StartAccelerationEffect(character, color)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = FXLoader:Find(character, "HumanoidRootPart")
    if not humanoid or not root then
        return
    end
    local effect = {Character = character, Humanoid = humanoid, Nodes = {}, Strength = 0,
        StartedAt = os.clock(), BaseOffset = humanoid.CameraOffset}
    self._acceleration = effect
    local attachment = Instance.new("Attachment")
    attachment.Name = "TrainingAccelerationParticles"
    attachment.Position = Vector3.new(0, -1.5, 0)
    attachment.Parent = root
    table.insert(effect.Nodes, attachment)
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.4))
    particles.Rate = 25
    particles.Lifetime = NumberRange.new(0.2, 0.35)
    particles.Speed = NumberRange.new(8, 13)
    particles.SpreadAngle = Vector2.new(25, 25)
    particles.Acceleration = Vector3.new(0, 10, 0)
    particles.LightEmission = 0.8
    particles.Size = NumberSequence.new(0.22, 0)
    particles.Transparency = NumberSequence.new(0.25, 1)
    particles.Parent = attachment
    particles:Emit(10)
    effect.Particles = particles
    local hand = FXLoader:Find(character, "RightHand") or FXLoader:Find(character, "Right Arm")
    if hand and hand:IsA("BasePart") then
        local edges = {}
        for index = 1, 2 do
            local edge = Instance.new("Attachment")
            edge.Name = "TrainingAccelerationTrail" .. index
            edge.Position = Vector3.new(0, (index - 1.5) * 0.7, 0)
            edge.Parent = hand
            edges[index] = edge
            table.insert(effect.Nodes, edge)
        end
        local trail = Instance.new("Trail")
        trail.Attachment0 = edges[1]
        trail.Attachment1 = edges[2]
        trail.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
        trail.Lifetime = 0.12
        trail.MinLength = 0.05
        trail.LightEmission = 0.7
        trail.Transparency = NumberSequence.new(0.55, 1)
        trail.Parent = edges[1]
        effect.Trail = trail
    end
end

--- 只释放本次加速的视野增量及角色特效，保留弹窗等其他效果的镜头状态。
function Component:ClearAccelerationEffect()
    local effect = self._acceleration
    if not effect then
        return
    end
    if effect.Camera then
        FC.UIAnim:SetCameraFovOffset(effect.Camera, effect, 0)
    end
    if effect.Humanoid.Parent and effect.Humanoid.CameraOffset == effect.LastOffset then
        effect.Humanoid.CameraOffset = effect.BaseOffset
    end
    for index, node in ipairs(effect.Nodes) do
        node:Destroy()
    end
    self._speedLines.Visible = false
    self._acceleration = nil
end

--- 服务端确认后同步镜头与角色特效；镜头归还后补绑，接管时释放视野和震动偏移。
--- @param active boolean 是否仍在已确认的加成期间。
--- @param color Color3 本次倍率的主题色。
--- @param deltaTime number 本帧间隔，用于保持不同帧率下相同的淡入淡出速度。
function Component:RefreshEffect(active, color, deltaTime)
    if active and not self._effectActive then
        if self._flashTween then
            self._flashTween:Cancel()
        end
        self._flash.BackgroundColor3 = color
        self._flash.BackgroundTransparency = 0.8
        self._flashTween = TweenService:Create(self._flash, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        self._flashTween:Play()
    end
    self._effectActive = active
    local character = self:GetPlayerCharacter()
    local effect = self._acceleration
    if effect and (effect.Character ~= character or (effect.Camera and effect.Camera ~= workspace.CurrentCamera)) then
        self:ClearAccelerationEffect()
        effect = nil
    end
    if active and not effect and character then
        self:StartAccelerationEffect(character, color)
        effect = self._acceleration
    end
    if not effect then
        return
    end
    effect.Strength = math.clamp(effect.Strength + deltaTime * (active and 8 or -5), 0, 1)
    effect.Particles.Enabled = active
    if effect.Trail then
        effect.Trail.Enabled = active
    end
    if effect.Strength == 0 then
        self:ClearAccelerationEffect()
        return
    end
    local elapsed = os.clock() - effect.StartedAt
    local camera = workspace.CurrentCamera
    if camera and camera.CameraType == Enum.CameraType.Custom and camera.CameraSubject == effect.Humanoid then
        effect.Camera = camera
        FC.UIAnim:SetCameraFovOffset(camera, effect, 12 * effect.Strength)
        if not effect.LastOffset or effect.Humanoid.CameraOffset ~= effect.LastOffset then
            effect.BaseOffset = effect.Humanoid.CameraOffset
        end
        local shake = math.max(0, 1 - elapsed / 0.25) * effect.Strength * 0.12
        effect.Humanoid.CameraOffset = effect.BaseOffset
            + Vector3.new(math.sin(elapsed * 85), math.cos(elapsed * 71), 0) * shake
        effect.LastOffset = effect.Humanoid.CameraOffset
    else
        if effect.Camera then
            FC.UIAnim:SetCameraFovOffset(effect.Camera, effect, 0)
        end
        if effect.Humanoid.CameraOffset == effect.LastOffset then
            effect.Humanoid.CameraOffset = effect.BaseOffset
        end
        effect.LastOffset = nil
    end
    self._speedLines.Visible = true
    local size = self._speedLines.AbsoluteSize
    local scale = math.min(size.X, size.Y) / 720
    for index, line in ipairs(self._lines) do
        local phase = (elapsed * line.Speed + line.Phase) % 1
        local direction = line.Direction
        local edge = 0.5 / math.max(math.abs(direction.X), math.abs(direction.Y))
        local distance = edge * (0.72 + phase * 0.5)
        line.Node.Position = UDim2.fromScale(0.5 + direction.X * distance, 0.5 + direction.Y * distance)
        line.Node.Size = UDim2.fromOffset((28 + phase * 75) * scale, 2 * scale)
        line.Node.Rotation = math.deg(math.atan2(direction.Y * size.Y, direction.X * size.X))
        line.Node.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.7)
        line.Node.BackgroundTransparency = 1 - math.sin(phase * math.pi) * effect.Strength * 0.65
    end
end

--- 气泡、文字和圆环整体适配屏幕短边；按服务器期限隐藏，弹窗期间不接受点击。
--- @param deltaTime number 本帧间隔，用于加速表现的渐变。
function Component:RefreshBonus(deltaTime)
    local player = self:GetPlayerNode()
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local eligible = humanoid ~= nil and humanoid.Health > 0 and self:GetNumber(Fields.TrainingFieldIndex) > 0
    local now = workspace:GetServerTimeNow()
    local rate = player:GetAttribute("TrainingBonusRate") or 1
    local colorIndex = table.find(_G.GameConfig.TrainingBonusConfig.Multipliers, rate) or 1
    local color = Colors[(colorIndex - 1) % #Colors + 1]
    local offerId = player:GetAttribute("TrainingBonusOfferId")
    if offerId ~= self._offerId then
        self._offerId = offerId
        self._pendingId = nil
        if offerId then
            self:ShowBubble()
        end
    end
    local activeUntil = player:GetAttribute("TrainingBonusUntil") or 0
    local active = eligible and activeUntil > now
    local blocked = self._commonUI:IsTrainingClickBlocked()
    self._bubble.Visible = eligible and not blocked and offerId ~= nil and self._pendingId ~= offerId
        and now < (player:GetAttribute("TrainingBonusOfferUntil") or 0)
    if self._bubble.Visible then
        local size = self._speedLines.AbsoluteSize
        local scale = math.min(size.X, size.Y, 720) / 720
        self._responsiveScale.Scale = scale
        self._bubble.BackgroundColor3 = color
        self._bubble.Text = Text.Tr(TranslationTexts.Multiplier, {rate = GameUtility.NumberToText(rate)})
        self._bubbleAnchor.Position = UDim2.new(self._position.X, 0, self._position.Y, math.sin(now * 3) * 6 * scale)
        local remaining = (player:GetAttribute("TrainingBonusOfferUntil") - now)
            / _G.GameConfig.TrainingBonusConfig.OfferLifetime
        local count = math.ceil(math.clamp(remaining, 0, 1) * #self._ringSegments)
        if count ~= self._remainingSegments then
            self._remainingSegments = count
            for index, segment in ipairs(self._ringSegments) do
                segment.BackgroundTransparency = index <= count and 0 or 0.85
            end
        end
    end
    self:RefreshEdgeGlow(active, color, deltaTime)
    self:RefreshEffect(active and not blocked, color, deltaTime)
end

--- 清除气泡、全屏边缘光、镜头偏移和人物特效，连接交由父类释放。
function Component:Dtor()
    self:ClearAccelerationEffect()
    if self._popTween then
        self._popTween:Cancel()
    end
    if self._flashTween then
        self._flashTween:Cancel()
    end
    if self._rootNode then
        self._rootNode:Destroy()
    end
    if self._edgeGlowRoot then
        self._edgeGlowRoot:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
