local RockWeaponTool = {}

-- 指根与掌侧同时偏移，让柄轴落在弯曲手指围成的握持区，而非穿过掌背。
local TOOL_GRIP = CFrame.new(0.2, 0, -0.15) * CFrame.Angles(0, math.rad(90), 0)

--- 以手柄为缩放中心放大整件装备，保留握持位置并同步缩放焊接与附件。
--- @param tool Tool 尚未挂载到角色的装备。
local function enlargeTool(tool)
    local grip = tool.Grip
    local container = Instance.new("Model")
    container.WorldPivot = tool.Handle.CFrame
    tool.Parent = container
    container:ScaleTo(1.5)
    -- 握点属于角色手部空间，不能随武器放大，否则会滑出手指。
    tool.Grip = grip
    tool.Parent = nil
    container:Destroy()
end

--- 克隆已配置握点的 Tool，或将柄底为原点的模型组装为右手装备。
--- @param template Model|Tool 导出武器模型，或已配置 Handle、Grip 和焊接的 Tool。
--- @param giantPickaxe boolean 是否将当前基础尺寸放大至 1.5 倍。
--- @return Tool 已修正握点、朝向和物理属性的未挂载装备。
--- @return Model 装备中的可见模型，供调用方布置镐头拖尾。
function RockWeaponTool.Build(template, giantPickaxe)
    -- AI 工具已按角色尺寸配置；重复缩放和创建手柄会将握点移到工具头部。
    if template:IsA("Tool") then
        local tool = template:Clone()
        tool.CanBeDropped = false
        tool.ManualActivationOnly = true
        tool.Grip = TOOL_GRIP
        if giantPickaxe then
            enlargeTool(tool)
        end
        return tool, tool.Visual
    end
    local model = template:Clone()
    model:ScaleTo(0.4)
    model:PivotTo(CFrame.new())
    local tool = Instance.new("Tool")
    tool.Name = template.Name
    tool.CanBeDropped = false
    tool.ManualActivationOnly = true
    -- 镐的局部 -X 尖端朝人物前方，所有武器采用相同的指根握点。
    tool.Grip = TOOL_GRIP
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
                local widthScale = 0.7 / (giantPickaxe and 1.5 or 1)
                part.Size = Vector3.new(part.Size.X * widthScale, part.Size.Y, part.Size.Z * widthScale)
                local position = part.Position
                part.CFrame = CFrame.new(position.X * widthScale, position.Y, position.Z * widthScale) * part.CFrame.Rotation
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
    if giantPickaxe then
        enlargeTool(tool)
    end
    return tool, model
end

return RockWeaponTool
