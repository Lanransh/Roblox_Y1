-- 本地用卡表现：举高停顿、快速前推与彩色冲击，不创建服务端特效。
local RunService = game:GetService("RunService")
local CardUseEffect = {}
local CardColors = {
    WeekCard = Color3.fromRGB(15, 145, 255),
    DoubleSaleCard = Color3.fromRGB(255, 165, 10),
    ExpandableBackpackCard = Color3.fromRGB(10, 210, 100),
    TrainingCard = Color3.fromRGB(255, 70, 20),
    NoobCard = Color3.fromRGB(185, 75, 255),
}

--- 创建仅供本地显示的无碰撞特效片，所有节点由同一容器统一回收。
--- @param parent Instance 本次表现容器。
--- @param name string 节点用途。
--- @param color Color3 卡片主色。
--- @return Part 已挂载的本地特效片。
local function CreatePart(parent, name, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 1
    part.Parent = parent
    return part
end

--- 动画计算后覆写右臂姿势，兼容 Motor6D 与新版 AnimationConstraint。
--- @param character Model 当前角色。
--- @param partName string R15 关节所在部位。
--- @param jointName string R15 关节名称。
--- @param legacyName string? R6 躯干关节名称。
--- @return Instance? 可设置 Transform 的角色关节。
local function FindJoint(character, partName, jointName, legacyName)
    local part = character:FindFirstChild(partName)
    local torso = character:FindFirstChild("Torso")
    local joint = part and part:FindFirstChild(jointName)
        or (legacyName and torso and torso:FindFirstChild(legacyName))
    if joint and (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then
        return joint
    end
    return nil
end

--- 在本地举高卡片后向前推出；连续使用、死亡或换角色时由返回函数中止。
--- @param character Model? 当前本地角色。
--- @param config table 已成功使用的道具配置。
--- @param onPush function 推出瞬间播放音效的回调。
--- @return function? 可重复调用的清理函数；角色不可用时返回 nil。
function CardUseEffect.Play(character, config, onPush)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
    if not root or not hand or not humanoid or humanoid.Health <= 0 then
        return nil
    end
    local color = CardColors[config.Type] or Color3.fromRGB(65, 125, 255)
    local hiddenParts = {}
    local hiddenImages = {}
    --- 原道具可能尚未销毁或自动切回武器，只在本地隐藏以免遮住展示卡。
    --- @param tool Instance 角色新装备或当前持有的节点。
    local function HideHeldTool(tool)
        if not tool:IsA("Tool") then
            return
        end
        for index, node in ipairs(tool:GetDescendants()) do
            if node:IsA("BasePart") then
                if hiddenParts[node] == nil then
                    hiddenParts[node] = node.LocalTransparencyModifier
                end
                node.LocalTransparencyModifier = 1
            elseif node:IsA("SurfaceGui") then
                if hiddenImages[node] == nil then
                    hiddenImages[node] = node.Enabled
                end
                node.Enabled = false
            end
        end
    end
    for index, child in ipairs(character:GetChildren()) do
        HideHeldTool(child)
    end
    local toolConnection = character.ChildAdded:Connect(HideHeldTool)
    local effects = Instance.new("Folder")
    effects.Name = "LocalCardUseEffect"
    effects.Parent = workspace
    local card = CreatePart(effects, "UsingCard", color)
    card.Size = Vector3.new(1.5, 1.5, 0.08)
    local images = {}
    for index, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
        local surface = Instance.new("SurfaceGui")
        surface.Name = "CardImage" .. index
        surface.Face = face
        surface.CanvasSize = Vector2.new(256, 256)
        surface.LightInfluence = 0
        surface.Brightness = 0.8
        surface.Parent = card
        local image = Instance.new("ImageLabel")
        image.Size = UDim2.fromScale(1, 1)
        image.BackgroundTransparency = 1
        image.Image = _G.ItemConfig.Display[config.Id].IconId
        image.ScaleType = Enum.ScaleType.Fit
        image.Parent = surface
        table.insert(images, image)
    end
    local edge0 = Instance.new("Attachment")
    edge0.Position = Vector3.new(-0.6, 0, 0)
    edge0.Parent = card
    local edge1 = Instance.new("Attachment")
    edge1.Position = Vector3.new(0.6, 0, 0)
    edge1.Parent = card
    local trail = Instance.new("Trail")
    trail.Attachment0 = edge0
    trail.Attachment1 = edge1
    trail.Color = ColorSequence.new(color)
    trail.LightEmission = 0.35
    trail.Lifetime = 0.16
    trail.Transparency = NumberSequence.new(0.45, 1)
    trail.Parent = card

    local joints = {}
    local jointSpecs = {
        {"RightUpperArm", "RightShoulder", "Right Shoulder", CFrame.Angles(math.rad(170), 0, math.rad(15)), CFrame.Angles(math.rad(90), 0, math.rad(-5))},
        {"RightLowerArm", "RightElbow", nil, CFrame.Angles(math.rad(-25), 0, 0), CFrame.new()},
        {"RightHand", "RightWrist", nil, CFrame.new(), CFrame.new()},
    }
    for index, spec in ipairs(jointSpecs) do
        local joint = FindJoint(character, spec[1], spec[2], spec[3])
        if joint then
            table.insert(joints, {Node = joint, Original = joint.Transform, Raised = spec[4], Pushed = spec[5]})
        end
    end
    local rings = {}
    for ringIndex = 1, 2 do
        for segment = 1, 20 do
            table.insert(rings, {
                Part = CreatePart(effects, "PushRing", color),
                Ring = ringIndex,
                Angle = (segment - 1) * math.pi * 2 / 20,
            })
        end
    end
    local streaks = {}
    for index = 1, 10 do
        table.insert(streaks, CreatePart(effects, "PushStreak", color))
    end
    local started = os.clock()
    local releasedFrame
    local pushed = false
    local cleaned = false
    local poseConnection
    local renderConnection
    --- 中止本次本地表现，并释放关节控制以恢复角色原有动画。
    local function Cleanup()
        if cleaned then
            return
        end
        cleaned = true
        poseConnection:Disconnect()
        renderConnection:Disconnect()
        toolConnection:Disconnect()
        for part, transparency in pairs(hiddenParts) do
            if part.Parent then
                part.LocalTransparencyModifier = transparency
            end
        end
        for surface, enabled in pairs(hiddenImages) do
            if surface.Parent then
                surface.Enabled = enabled
            end
        end
        for index, joint in ipairs(joints) do
            if joint.Node.Parent then
                joint.Node.Transform = joint.Original
            end
        end
        effects:Destroy()
    end
    poseConnection = RunService.PreSimulation:Connect(function()
        local elapsed = os.clock() - started
        for index, joint in ipairs(joints) do
            if joint.Node.Parent then
                local pose
                if elapsed < 0.32 then
                    local alpha = math.clamp(elapsed / 0.32, 0, 1)
                    pose = joint.Original:Lerp(joint.Raised, 1 - (1 - alpha) ^ 3)
                elseif elapsed < 0.8 then
                    pose = joint.Raised
                elseif elapsed < 0.98 then
                    local alpha = math.clamp((elapsed - 0.8) / 0.18, 0, 1)
                    pose = joint.Raised:Lerp(joint.Pushed, 1 - (1 - alpha) ^ 3)
                else
                    local alpha = math.clamp((elapsed - 1.15) / 0.35, 0, 1)
                    pose = joint.Pushed:Lerp(joint.Original, alpha * alpha * (3 - 2 * alpha))
                end
                joint.Node.Transform = pose
            end
        end
    end)
    renderConnection = RunService.RenderStepped:Connect(function()
        if not character:IsDescendantOf(workspace) or not hand:IsDescendantOf(character) or humanoid.Health <= 0 then
            Cleanup()
            return
        end
        local elapsed = os.clock() - started
        if elapsed >= 1.6 then
            Cleanup()
            return
        end
        if elapsed < 0.98 then
            -- 图片朝角色前方，中心略高于手掌，突出举卡和前推的轮廓。
            card.CFrame = CFrame.new(hand.Position + root.CFrame.UpVector * 0.55) * root.CFrame.Rotation
        else
            releasedFrame = releasedFrame or card.CFrame
            local alpha = math.clamp((elapsed - 0.98) / 0.4, 0, 1)
            card.CFrame = releasedFrame * CFrame.new(0, 0, -1.8 * alpha)
            for index, image in ipairs(images) do
                image.ImageTransparency = alpha
            end
            trail.Enabled = alpha < 0.6
        end
        if elapsed >= 0.8 and not pushed then
            pushed = true
            onPush()
        end
        if elapsed >= 0.98 then
            local alpha = math.clamp((elapsed - 0.98) / 0.55, 0, 1)
            for index, ring in ipairs(rings) do
                local radius = 0.55 + alpha * (1.8 + ring.Ring * 0.45)
                local angle = ring.Angle + alpha * (ring.Ring == 1 and 0.5 or -0.5)
                ring.Part.Size = Vector3.new(0.055, radius * 0.31, 0.055)
                ring.Part.CFrame = releasedFrame * CFrame.new(math.cos(angle) * radius, math.sin(angle) * radius, -alpha * ring.Ring * 1.4)
                    * CFrame.Angles(0, 0, angle)
                ring.Part.Transparency = 0.35 + alpha * 0.65
            end
            for index, streak in ipairs(streaks) do
                local angle = index * math.pi * 2 / #streaks
                local radius = 0.35 + alpha * 1.2
                streak.Size = Vector3.new(0.045, 0.045, 0.3 + (1 - alpha) * 0.9)
                streak.CFrame = releasedFrame * CFrame.new(math.cos(angle) * radius, math.sin(angle) * radius, -0.3 - alpha * 4)
                streak.Transparency = 0.3 + alpha * 0.7
            end
        end
    end)
    return Cleanup
end

return CardUseEffect
