-- Studio 编辑态一次性更新粒子模板；不创建运行脚本或光束线条。
local folder = game.ReplicatedStorage.Assets.Effects.Aura
local themes = {
    {"20_Inferno", Color3.fromRGB(255, 55, 8), Color3.fromRGB(255, 200, 45)},
    {"21_Storm", Color3.fromRGB(35, 100, 255), Color3.fromRGB(155, 235, 255)},
    {"22_Solar", Color3.fromRGB(255, 145, 8), Color3.fromRGB(255, 240, 140)},
    {"24_Prismatic", Color3.fromRGB(255, 30, 170), Color3.fromRGB(20, 215, 255)},
    {"25_Astral", Color3.fromRGB(115, 35, 255), Color3.fromRGB(105, 205, 255)},
}
local smoke = "rbxasset://textures/particles/smoke_main.dds"
local sparkle = "rbxasset://textures/particles/sparkles_main.dds"
local fire = "rbxasset://textures/particles/fire_main.dds"

--- 每层独立定位和随机运动，随根 Attachment 一起克隆到身体。
--- @param root Attachment 特效根节点。
--- @param position Vector3 相对躯干的位置。
--- @param texture string 内置透明粒子贴图。
--- @param colors ColorSequence 生命周期颜色。
--- @param size number 粒子中段尺寸。
--- @param rate number 每秒发射量。
--- @param lifetime number 最长寿命。
--- @return ParticleEmitter 待定制运动的粒子层。
local function AddLayer(root, position, texture, colors, size, rate, lifetime)
    local anchor = Instance.new("Attachment")
    anchor.Position = position
    anchor.Parent = root
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = texture
    emitter.Color = colors
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.Rate = rate
    emitter.Lifetime = NumberRange.new(lifetime * 0.6, lifetime)
    emitter.Speed = NumberRange.new(0.8, 2)
    emitter.SpreadAngle = Vector2.new(35, 35)
    emitter.Rotation = NumberRange.new(-180, 180)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    emitter.VelocityInheritance = 0.25
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size * 0.2), NumberSequenceKeypoint.new(0.3, size, size * 0.2), NumberSequenceKeypoint.new(1, 0)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0.2), NumberSequenceKeypoint.new(0.6, 0.5), NumberSequenceKeypoint.new(1, 1)})
    emitter.Parent = anchor
    return emitter
end

for themeIndex, theme in ipairs(themes) do
    local model = folder:FindFirstChild(theme[1])
    assert(model, "Missing aura " .. theme[1])
    for index, name in ipairs({"PrestigeContour", "PrestigeParticles"}) do
        local old = model.Torso:FindFirstChild(name)
        if old then
            old:Destroy()
        end
    end
    local root = Instance.new("Attachment")
    root.Name = "PrestigeParticles"
    local primary, accent = theme[2], theme[3]
    local colors = ColorSequence.new(primary, accent)
    local wisps = AddLayer(root, Vector3.new(0, -1.4, 0), smoke, colors, themeIndex == 5 and 4 or 2.7, 9, 1.8)
    wisps.Name = "FlowingMist"
    wisps.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.88), NumberSequenceKeypoint.new(1, 1)})
    wisps.Acceleration = Vector3.new(0, 1.5, 0)
    for index = 0, 7 do
        local angle = index / 8 * math.pi * 2
        local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
        local position = radial * (themeIndex == 5 and 3 or 2.2) + Vector3.new(0, -1.8 + index % 3 * 0.4, 0)
        local layerColors = colors
        if themeIndex == 4 then
            layerColors = ColorSequence.new(Color3.fromHSV(index / 8, 0.9, 1), Color3.fromHSV((index / 8 + 0.18) % 1, 0.65, 1))
        end
        local layer = AddLayer(root, position, themeIndex == 1 and fire or sparkle, layerColors, themeIndex == 1 and 1.8 or 0.65, 7, themeIndex == 5 and 2.2 or 1.3)
        layer.Name = "Spiral" .. index
        layer.Parent.CFrame = CFrame.lookAt(position, position + tangent + Vector3.new(0, 0.45, 0))
        layer.EmissionDirection = Enum.NormalId.Front
        layer.Acceleration = -radial * 1.2 + Vector3.new(0, 2, 0)
        if themeIndex == 1 then
            layer.Speed = NumberRange.new(2, 4)
            layer.Acceleration = Vector3.new(0, 5, 0)
        elseif themeIndex == 2 then
            layer.Lifetime = NumberRange.new(0.12, 0.3)
            layer.Speed = NumberRange.new(8, 15)
            layer.Squash = NumberSequence.new(-0.75)
            layer.Orientation = Enum.ParticleOrientation.VelocityParallel
        elseif themeIndex == 3 then
            layer.Texture = fire
            layer.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(0.3, 1.5), NumberSequenceKeypoint.new(1, 0)})
            layer.Speed = NumberRange.new(3, 5)
            layer.Acceleration = radial * 2 + Vector3.new(0, 1, 0)
        elseif themeIndex == 4 then
            layer.RotSpeed = NumberRange.new(90, 180)
            layer.Speed = NumberRange.new(2, 4)
        else
            layer.Speed = NumberRange.new(1, 2)
            layer.Rate = 5
            layer.Drag = 0.6
        end
    end
    local motes = AddLayer(root, Vector3.new(0, -2, 0), sparkle, colors, 0.25, 12, 2)
    motes.Name = "RisingMotes"
    motes.Speed = NumberRange.new(2, 4)
    motes.SpreadAngle = Vector2.new(50, 50)
    if themeIndex == 2 then
        local flash = AddLayer(root, Vector3.zero, sparkle, ColorSequence.new(accent), 2.8, 2, 0.18)
        flash.Name = "ElectricFlash"
        flash.Speed = NumberRange.new(0)
    elseif themeIndex == 5 then
        local nebula = AddLayer(root, Vector3.new(0, 1, 0), smoke, ColorSequence.new(accent, primary), 5, 5, 2.8)
        nebula.Name = "Nebula"
        nebula.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.9), NumberSequenceKeypoint.new(1, 1)})
        nebula.RotSpeed = NumberRange.new(35, 65)
    end
    root.Parent = model.Torso
    task.wait()
end
return {themes = #themes, style = "Layered particles without beams"}
