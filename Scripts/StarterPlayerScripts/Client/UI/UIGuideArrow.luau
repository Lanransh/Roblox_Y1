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

--- 箭头和可选方形亮区跟随目标可见范围；按祖先裁切收紧亮区，避免照亮滚动列表外的内容。
function UIGuideArrow:_Update()
    local target = self._target
    self._arrow.Visible = false
    if self._spotlight then
        self._spotlight.Visible = false
    end
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
    local visibleMin = target.AbsolutePosition
    local visibleMax = visibleMin + size
    local node = target
    while node and node ~= self._playerGui do
        if node:IsA("GuiObject") then
            if not node.Visible then
                return
            end
            if node.ClipsDescendants then
                local clipMin = node.AbsolutePosition
                local clipMax = clipMin + node.AbsoluteSize
                visibleMin = Vector2.new(math.max(visibleMin.X, clipMin.X), math.max(visibleMin.Y, clipMin.Y))
                visibleMax = Vector2.new(math.min(visibleMax.X, clipMax.X), math.min(visibleMax.Y, clipMax.Y))
                if visibleMax.X <= visibleMin.X or visibleMax.Y <= visibleMin.Y then
                    return
                end
            end
        elseif node:IsA("ScreenGui") and not node.Enabled then
            return
        end
        node = node.Parent
    end
    size = visibleMax - visibleMin
    local center = (visibleMin + visibleMax) / 2
    local localCenter = center - self._root.AbsolutePosition
    local viewport = self._root.AbsoluteSize
    if localCenter.X < 0 or localCenter.Y < 0 or localCenter.X > viewport.X or localCenter.Y > viewport.Y then
        return
    end
    local spotlightPadding = 0
    if self._showSpotlight then
        spotlightPadding = math.clamp(math.min(viewport.X, viewport.Y) * 0.012, 5, 12)
        self:_UpdateSpotlight(localCenter, size + Vector2.one * spotlightPadding * 2, viewport)
    end
    local side = self._side
    local direction = side.Direction
    local halfTarget = (math.abs(direction.X) * size.X + math.abs(direction.Y) * size.Y) / 2
    local height = math.round(math.clamp(math.min(size.X, size.Y) * 0.48, 26, 36))
    self._scale.Scale = height / 40
    local width = 62 * self._scale.Scale
    local pulse = (1 + math.sin(os.clock() * 3.5)) / 2
    local gap = 3 + 4 * pulse
    local distance = halfTarget + spotlightPadding + width / 2 + gap
    -- 窄屏或边缘按钮优先把箭头放到留白最多的一侧，避免箭头落到屏幕外。
    if self._showSpotlight then
        local spaces = {
            Left = localCenter.X, Right = viewport.X - localCenter.X,
            Top = localCenter.Y, Bottom = viewport.Y - localCenter.Y,
        }
        local preferred = direction.X < 0 and spaces.Left or direction.X > 0 and spaces.Right
            or direction.Y < 0 and spaces.Top or spaces.Bottom
        if preferred < distance + width / 2 then
            local bestSpace = -1
            for name, space in pairs(spaces) do
                if space > bestSpace then
                    side = Sides[name]
                    bestSpace = space
                end
            end
            direction = side.Direction
            halfTarget = (math.abs(direction.X) * size.X + math.abs(direction.Y) * size.Y) / 2
            distance = halfTarget + spotlightPadding + width / 2 + gap
        end
    end
    local position = localCenter + direction * distance
    if self._showSpotlight then
        local halfWidth = (direction.X == 0 and height or width) / 2
        local halfHeight = (direction.X == 0 and width or height) / 2
        position = Vector2.new(math.clamp(position.X, halfWidth, math.max(halfWidth, viewport.X - halfWidth)),
            math.clamp(position.Y, halfHeight, math.max(halfHeight, viewport.Y - halfHeight)))
    end
    self._arrow.Position = UDim2.fromOffset(math.round(position.X), math.round(position.Y))
    self._arrow.Rotation = side.Rotation
    self._arrow.Visible = true
end

--- 用四块全屏遮罩围出直角矩形亮区，不复制按钮，也不拦截按钮和触屏输入。
function UIGuideArrow:_CreateSpotlight()
    self._screen.ScreenInsets = Enum.ScreenInsets.None
    local spotlight = Instance.new("Frame")
    spotlight.Name = "TutorialSpotlight"
    spotlight.Size = UDim2.fromScale(1, 1)
    spotlight.BackgroundTransparency = 1
    spotlight.Active = false
    spotlight.ZIndex = 1
    spotlight.Parent = self._root
    self._spotlight = spotlight
    self._shadeParts = {}
    for index = 1, 4 do
        local shade = Instance.new("Frame")
        shade.Name = "Shade" .. index
        shade.BackgroundColor3 = Color3.new(0, 0, 0)
        shade.BackgroundTransparency = 0.3
        shade.BorderSizePixel = 0
        shade.Active = false
        shade.Parent = spotlight
        self._shadeParts[index] = shade
    end
    local ring = Instance.new("Frame")
    ring.Name = "TargetRing"
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.Active = false
    ring.ZIndex = 2
    ring.Parent = spotlight
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 223, 75)
    stroke.Thickness = 2
    stroke.Parent = ring
    self._ring = ring
end

--- 依据目标矩形刷新亮区；几何不变时只恢复显示，避免逐帧重写全部遮罩。
--- @param center Vector2 目标中心在全屏层中的像素位置。
--- @param size Vector2 包含按钮及边距的矩形尺寸。
--- @param viewport Vector2 当前全屏层的实际像素尺寸。
function UIGuideArrow:_UpdateSpotlight(center, size, viewport)
    self._spotlight.Visible = true
    if self._spotlightCenter == center and self._spotlightSize == size and self._spotlightViewport == viewport then
        return
    end
    self._spotlightCenter, self._spotlightSize, self._spotlightViewport = center, size, viewport
    --- 将遮罩矩形裁到屏幕内并对齐整数像素，各片共用边界，避免小数像素漏缝或重复叠黑。
    --- @param index number 遮罩片序号。
    --- @param left number 左侧像素坐标。
    --- @param top number 顶部像素坐标。
    --- @param right number 右侧像素坐标。
    --- @param bottom number 底部像素坐标。
    local function SetShade(index, left, top, right, bottom)
        left, right = math.round(math.clamp(left, 0, viewport.X)), math.round(math.clamp(right, 0, viewport.X))
        top, bottom = math.round(math.clamp(top, 0, viewport.Y)), math.round(math.clamp(bottom, 0, viewport.Y))
        local shade = self._shadeParts[index]
        shade.Position = UDim2.fromOffset(left, top)
        shade.Size = UDim2.fromOffset(right - left, bottom - top)
    end
    local left, top = center.X - size.X / 2, center.Y - size.Y / 2
    local right, bottom = center.X + size.X / 2, center.Y + size.Y / 2
    SetShade(1, 0, 0, viewport.X, top)
    SetShade(2, 0, bottom, viewport.X, viewport.Y)
    SetShade(3, 0, top, left, bottom)
    SetShade(4, right, top, viewport.X, bottom)
    self._ring.Position = UDim2.fromOffset(center.X, center.Y)
    self._ring.Size = UDim2.fromOffset(size.X, size.Y)
end

--- 绑定任意界面节点；方向表示箭头位于目标哪一侧，箭头始终朝向目标。
--- @param target GuiObject 需要指向的实际界面节点。
--- @param side string? Left、Right、Top 或 Bottom，默认位于左侧。
--- @param spotlight boolean? 显示全屏压暗与方形亮区，供新手引导及首次重生等提示复用，默认关闭。
function UIGuideArrow:Show(target, side, spotlight)
    self._showSpotlight = spotlight == true
    if self._showSpotlight and not self._spotlight then
        self:_CreateSpotlight()
    end
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
    if self._spotlight then
        self._spotlight.Visible = false
    end
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
