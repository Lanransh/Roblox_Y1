-- 通用界面引导箭头：绑定实际 UI 节点，跟随布局和显隐，不拦截点击。
local RunService = game:GetService("RunService")
local UIGuideArrow = {}
UIGuideArrow.__index = UIGuideArrow

local Sides = {
    Left = {Direction = Vector2.new(-1, 0), Rotation = 0},
    Right = {Direction = Vector2.new(1, 0), Rotation = 180},
    Top = {Direction = Vector2.new(0, -1), Rotation = 90},
    Bottom = {Direction = Vector2.new(0, 1), Rotation = -90},
}

--- 用矩形和两个对角透明遮罩绘制原生箭头，不依赖低分辨率贴图或旋转裁剪。
--- @param parent Frame 箭头的独立容器。
--- @param name string 当前轮廓层名称。
--- @param position Vector2 当前层的像素偏移。
--- @param size Vector2 当前层的像素尺寸，箭头头部为等腰直角三角形。
--- @param shaftHeight number 箭杆的像素高度。
--- @param colors table 顶部、正面和底部三种颜色。
--- @return Frame 拥有三个图形节点的轮廓层。
local function CreateArrowLayer(parent, name, position, size, shaftHeight, colors)
    local layer = Instance.new("Frame")
    layer.Name = name
    layer.Position = UDim2.fromOffset(position.X, position.Y)
    layer.Size = UDim2.fromOffset(size.X, size.Y)
    layer.BackgroundTransparency = 1
    layer.Active = false
    layer.Parent = parent
    local headSize = size.Y / 2
    local headX = size.X - headSize
    local parts = {
        {Name = "Shaft", X = 0, Y = (size.Y - shaftHeight) / 2,
            Width = headX + 1, Height = shaftHeight, Rotation = 90},
        {Name = "UpperHead", X = headX, Y = 0,
            Width = headSize, Height = headSize, Rotation = -45},
        {Name = "LowerHead", X = headX, Y = headSize,
            Width = headSize, Height = headSize, Rotation = 45},
    }
    for index, part in ipairs(parts) do
        local node = Instance.new("Frame")
        node.Name = part.Name
        node.Position = UDim2.fromOffset(part.X, part.Y)
        node.Size = UDim2.fromOffset(part.Width, part.Height)
        node.BackgroundColor3 = Color3.new(1, 1, 1)
        node.BorderSizePixel = 0
        node.Active = false
        node.Parent = layer
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = part.Rotation
        if index == 1 then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 3)
            corner.Parent = node
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, colors[1]),
                ColorSequenceKeypoint.new(0.45, colors[2]),
                ColorSequenceKeypoint.new(1, colors[3]),
            })
        else
            gradient.Color = ColorSequence.new(colors[index - 1], colors[index])
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.499, 0),
                NumberSequenceKeypoint.new(0.501, 1), NumberSequenceKeypoint.new(1, 1),
            })
        end
        gradient.Parent = node
    end
    return layer
end

--- 创建修长箭杆、细黑边和柔和亮面的红箭头，独立引导层不拦截点击。
--- @param playerGui PlayerGui 所属玩家的界面容器。
--- @return table 可绑定、隐藏和销毁的箭头控制器。
function UIGuideArrow.New(playerGui)
    local self = setmetatable({}, UIGuideArrow)
    self._playerGui = playerGui
    self._screen = Instance.new("ScreenGui")
    self._screen.Name = "UIGuideArrowUI"
    self._screen.ResetOnSpawn = false
    self._screen.DisplayOrder = 100
    self._screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._screen.Parent = playerGui
    self._root = Instance.new("Frame")
    self._root.Name = "UIGuideArrowLayer"
    self._root.Size = UDim2.fromScale(1, 1)
    self._root.BackgroundTransparency = 1
    self._root.Active = false
    self._root.ZIndex = 100
    self._root.Parent = self._screen
    self._arrow = Instance.new("Frame")
    self._arrow.Name = "Arrow"
    self._arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    self._arrow.Size = UDim2.fromOffset(62, 40)
    self._arrow.BackgroundTransparency = 1
    self._arrow.Active = false
    self._arrow.Visible = false
    self._arrow.ZIndex = 100
    self._arrow.Parent = self._root
    self._scale = Instance.new("UIScale")
    self._scale.Parent = self._arrow

    local ink = Color3.fromRGB(35, 17, 25)
    local side = Color3.fromRGB(171, 35, 51)
    local outline = CreateArrowLayer(self._arrow, "Outline", Vector2.zero,
        Vector2.new(62, 40), 22, {ink, ink, ink})
    outline.ZIndex = 1
    local bevel = CreateArrowLayer(self._arrow, "DarkRedSide", Vector2.new(3, 5),
        Vector2.new(56, 32), 16, {side, side, side})
    bevel.ZIndex = 2
    local face = CreateArrowLayer(self._arrow, "RedFace", Vector2.new(3, 3),
        Vector2.new(56, 32), 16, {
            Color3.fromRGB(255, 99, 91), Color3.fromRGB(249, 65, 64), Color3.fromRGB(230, 46, 57),
        })
    face.ZIndex = 3

    local highlight = Instance.new("Frame")
    highlight.Name = "SoftHighlight"
    highlight.Position = UDim2.fromOffset(3, 10)
    highlight.Size = UDim2.fromOffset(30, 2)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 190, 174)
    highlight.BackgroundTransparency = 0.35
    highlight.BorderSizePixel = 0
    highlight.Active = false
    highlight.ZIndex = 2
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0.5, 0)
    highlightCorner.Parent = highlight
    highlight.Parent = face
    return self
end

--- 按目标短边约一半适配尺寸，仅轻微往复移动；隐藏或不可交互的目标不显示箭头。
function UIGuideArrow:_Update()
    local target = self._target
    self._arrow.Visible = false
    if not target or not target:IsDescendantOf(self._playerGui) then
        return
    end
    if target:IsA("GuiButton") and not target.Interactable then
        return
    end
    local size = target.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then
        return
    end
    local center = target.AbsolutePosition + size / 2
    local node = target
    while node and node ~= self._playerGui do
        if node:IsA("GuiObject") then
            if not node.Visible then
                return
            end
            if node.ClipsDescendants then
                local relative = center - node.AbsolutePosition
                if relative.X < 0 or relative.Y < 0
                    or relative.X > node.AbsoluteSize.X or relative.Y > node.AbsoluteSize.Y then
                    return
                end
            end
        elseif node:IsA("ScreenGui") and not node.Enabled then
            return
        end
        node = node.Parent
    end
    local side = self._side
    local direction = side.Direction
    local halfTarget = (math.abs(direction.X) * size.X + math.abs(direction.Y) * size.Y) / 2
    local height = math.round(math.clamp(math.min(size.X, size.Y) * 0.48, 26, 36))
    self._scale.Scale = height / 40
    local width = 62 * self._scale.Scale
    local pulse = (1 + math.sin(os.clock() * 3.5)) / 2
    local gap = 3 + 4 * pulse
    local position = center - self._root.AbsolutePosition + direction * (halfTarget + width / 2 + gap)
    self._arrow.Position = UDim2.fromOffset(math.round(position.X), math.round(position.Y))
    self._arrow.Rotation = side.Rotation
    self._arrow.Visible = true
end

--- 绑定任意界面节点；方向表示箭头位于目标哪一侧，箭头始终朝向目标。
--- @param target GuiObject 需要指向的实际界面节点。
--- @param side string? Left、Right、Top 或 Bottom，默认位于左侧。
function UIGuideArrow:Show(target, side)
    self._target = target
    self._side = assert(Sides[side or "Left"], "Invalid UI guide arrow side")
    if not self._connection then
        self._connection = RunService.RenderStepped:Connect(function()
            self:_Update()
        end)
    end
    self:_Update()
end

--- 退出步骤时隐藏整个原生箭头并释放逐帧更新，之后仍可绑定其他目标。
function UIGuideArrow:Hide()
    self._target = nil
    self._arrow.Visible = false
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
end

--- 释放控制器拥有的节点和连接，不销毁调用方的界面或目标。
function UIGuideArrow:Destroy()
    self:Hide()
    self._screen:Destroy()
end

return UIGuideArrow
