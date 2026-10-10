local RockWeaponTool = {}

--- 将当前 20 款导出武器克隆为可装备的右手 Tool，模板仍由地图块编辑器管理。
--- @param template Model 原点在柄底、柄沿局部 Y 轴的导出武器。
--- @return Tool 已修正握点、朝向和物理属性的未挂载装备。
--- @return Model 装备中的可见模型，供调用方布置镐头拖尾。
function RockWeaponTool.Build(template)
    local model = template:Clone()
    model:ScaleTo(0.4)
    model:PivotTo(CFrame.new())
    local tool = Instance.new("Tool")
    tool.Name = template.Name
    tool.CanBeDropped = false
    tool.ManualActivationOnly = true
    -- 镐的局部 -X 尖端朝人物前方，握柄向指尖偏移以避开掌心。
    tool.Grip = CFrame.new(0.1, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.33, 0.33, 0.33)
    handle.Transparency = 1
    handle.CFrame = CFrame.new(0, 1, 0)
    handle.CanCollide = false
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Massless = true
    handle.Parent = tool
    for index, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            -- 握柄、包覆和六棱柄的组成片同时收窄，避免外层包覆仍穿入手掌。
            if part.Name == "连续方木柄" or part.Name == "木柄侧面"
                or part.Name == "方木柄" or part.Name == "红棕方木柄"
                or part.Name == "握持包覆下" or part.Name == "握持包覆上"
                or part.Name == "平整握持包覆"
                or string.match(part.Name, "^六棱柄%d+$") then
                part.Size = Vector3.new(part.Size.X * 0.7, part.Size.Y, part.Size.Z * 0.7)
                local position = part.Position
                part.CFrame = CFrame.new(position.X * 0.7, position.Y, position.Z * 0.7) * part.CFrame.Rotation
            end
            part.Anchored = false
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Massless = true
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = part
            weld.Parent = part
        end
    end
    model.Parent = tool
    return tool, model
end

return RockWeaponTool
