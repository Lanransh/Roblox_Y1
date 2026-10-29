local FX = _G.FX
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

--- 创建本人专属气泡与倒计时圆环；服务端属性决定可领取凭据和实际加成。
function Component:OnReady()
    self._commonUI = self:RequireComponent("FCCommonUIComp")
    self._random = Random.new()
    local root = Instance.new("ScreenGui")
    root.Name = "TrainingBonusUI"
    root.ResetOnSpawn = false
    root.DisplayOrder = 15
    self._rootNode = root

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
    button.Parent = root
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 3
    stroke.Parent = button
    self._bubble = button
    self._scale = Instance.new("UIScale", button)

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

--- 随机选择安全画面位置并弹入；重复刷新同一个凭据不重新移动。
function Component:ShowBubble()
    self._remainingSegments = nil
    self._position = Vector2.new(self._random:NextNumber(0.25, 0.75), self._random:NextNumber(0.3, 0.65))
    self._scale.Scale = 0.1
    if self._popTween then
        self._popTween:Cancel()
    end
    self._popTween = TweenService:Create(self._scale,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    self._popTween:Play()
end

--- 为本地角色创建上冲光粒和手部短拖尾，不更改角色颜色或接管原挥镐特效。
--- @param character Model 当前存活角色。
--- @param color Color3 本次倍率的主题色。
function Component:StartAccelerationEffect(character, color)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        return
    end
    local effect = {Character = character, Humanoid = humanoid, Nodes = {}, Strength = 0,
        StartedAt = os.clock(), BaseOffset = humanoid.CameraOffset}
    self._acceleration = effect
    local camera = workspace.CurrentCamera
    if camera and camera.CameraType == Enum.CameraType.Custom and camera.CameraSubject == humanoid then
        effect.Camera = camera
        effect.BaseFov = camera.FieldOfView
    end
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
    local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
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

--- 只恢复本组件最后写入的镜头值，并释放本地角色特效，避免覆盖其他镜头接管。
function Component:ClearAccelerationEffect()
    local effect = self._acceleration
    if not effect then
        return
    end
    if effect.Camera and effect.Camera.Parent and effect.Camera.FieldOfView == effect.LastFov then
        effect.Camera.FieldOfView = effect.BaseFov
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

--- 服务端确认后同步爆发镜头、边缘速度线和人物特效；结束时平滑衰减，不改变人物轮廓。
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
    local camera = effect.Camera
    if camera and camera.CameraType == Enum.CameraType.Custom and camera.CameraSubject == effect.Humanoid then
        if effect.LastFov and math.abs(camera.FieldOfView - effect.LastFov) > 0.001 then
            effect.BaseFov = camera.FieldOfView
        end
        camera.FieldOfView = math.clamp(effect.BaseFov + 12 * effect.Strength, 1, 120)
        effect.LastFov = camera.FieldOfView
        if effect.LastOffset and effect.Humanoid.CameraOffset ~= effect.LastOffset then
            effect.BaseOffset = effect.Humanoid.CameraOffset
        end
        local shake = math.max(0, 1 - elapsed / 0.25) * effect.Strength * 0.12
        effect.Humanoid.CameraOffset = effect.BaseOffset
            + Vector3.new(math.sin(elapsed * 85), math.cos(elapsed * 71), 0) * shake
        effect.LastOffset = effect.Humanoid.CameraOffset
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

--- 圆环按服务器期限递减，到期隐藏气泡；弹窗期间隐藏，气泡点击不触发普通训练点击。
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
        self._bubble.BackgroundColor3 = color
        self._bubble.Text = Text.Tr(TranslationTexts.Multiplier, {rate = GameUtility.NumberToText(rate)})
        self._bubble.Position = UDim2.new(self._position.X, 0, self._position.Y, math.sin(now * 3) * 6)
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
    self:RefreshEffect(active and not blocked, color, deltaTime)
end

--- 清除气泡、镜头偏移和人物特效，连接交由父类释放。
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
    Component.Super.Dtor(self)
end

return Component
