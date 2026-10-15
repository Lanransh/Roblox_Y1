-- 普通背包道具的手持图片与使用成功表现。
local Debris = game:GetService("Debris")
local ItemToolVisual = {}

--- 复用道具图标制作双面卡片，透明握柄不遮挡图片，也不参与角色碰撞。
--- @param tool Tool 尚未放入背包的原生道具。
--- @param icon string ItemConfig.Display 中的图片 URI。
function ItemToolVisual.AddImageHandle(tool, icon)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1.5, 1.5, 0.08)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Massless = true
    handle.Parent = tool
    tool.RequiresHandle = true
    tool.Grip = CFrame.new(0, -0.55, 0)

    for index, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
        local surface = Instance.new("SurfaceGui")
        surface.Name = "CardImage" .. index
        surface.Face = face
        surface.CanvasSize = Vector2.new(256, 256)
        surface.LightInfluence = 0
        surface.Parent = handle

        local image = Instance.new("ImageLabel")
        image.Name = "Icon"
        image.BackgroundTransparency = 1
        image.Size = UDim2.fromScale(1, 1)
        image.Image = icon
        image.ScaleType = Enum.ScaleType.Fit
        image.Parent = surface
    end
end

--- 使用成功后分层播放外散大星芒与缓慢上飘的小星点，不依赖已消耗的 Tool。
--- @param character Model? 玩家当前角色；离场或尚未生成时跳过表现。
function ItemToolVisual.PlayUseEffect(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        return
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "ItemUseStars"
    local stars = Instance.new("ParticleEmitter")
    stars.Name = "Stars"
    stars.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    stars.Color = ColorSequence.new(Color3.fromRGB(255, 219, 87), Color3.fromRGB(255, 247, 199))
    stars.LightEmission = 1
    stars.Lifetime = NumberRange.new(0.8, 1.2)
    stars.Speed = NumberRange.new(5, 8)
    stars.SpreadAngle = Vector2.new(180, 180)
    stars.Acceleration = Vector3.new(0, 1.5, 0)
    stars.Drag = 2
    stars.Rotation = NumberRange.new(0, 360)
    stars.RotSpeed = NumberRange.new(-120, 120)
    stars.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25, 0.1),
        NumberSequenceKeypoint.new(0.2, 0.65, 0.2),
        NumberSequenceKeypoint.new(1, 0),
    })
    stars.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.6, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    stars.Rate = 45
    stars.Parent = attachment

    -- 小星点从身体周围错落出现，与大星芒共用贴图但使用独立的速度和生命周期。
    local motes = stars:Clone()
    motes.Name = "RisingStarPoints"
    motes.Lifetime = NumberRange.new(1.2, 1.8)
    motes.Speed = NumberRange.new(0.8, 1.6)
    motes.EmissionDirection = Enum.NormalId.Top
    motes.SpreadAngle = Vector2.new(20, 20)
    motes.Acceleration = Vector3.new(0, 0.8, 0)
    motes.Drag = 0.5
    motes.RotSpeed = NumberRange.new(-45, 45)
    motes.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08, 0.03),
        NumberSequenceKeypoint.new(0.25, 0.2, 0.07),
        NumberSequenceKeypoint.new(1, 0),
    })
    motes.Shape = Enum.ParticleEmitterShape.Box
    motes.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
    motes.Rate = 55
    local pointVolume = Instance.new("Part")
    pointVolume.Name = "ItemUseStarVolume"
    pointVolume.Size = Vector3.new(3, 3, 2)
    pointVolume.Transparency = 1
    pointVolume.CanCollide = false
    pointVolume.CanTouch = false
    pointVolume.CanQuery = false
    pointVolume.Massless = true
    pointVolume.CFrame = root.CFrame
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = pointVolume
    weld.Parent = pointVolume
    motes.Parent = pointVolume
    pointVolume.Parent = character
    attachment.Parent = root
    Debris:AddItem(attachment, 2.5)
    Debris:AddItem(pointVolume, 2.5)
    task.delay(0.5, function()
        if stars.Parent then
            stars.Enabled = false
        end
        if motes.Parent then
            motes.Enabled = false
        end
    end)
end

return ItemToolVisual
