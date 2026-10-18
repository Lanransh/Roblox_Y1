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

--- 创建独立于业务界面的引导层，供任意界面绑定目标，不拦截点击。
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
    self._image = Instance.new("ImageLabel")
    self._image.Name = "Arrow"
    self._image.AnchorPoint = Vector2.new(0.5, 0.5)
    self._image.Size = UDim2.fromOffset(52, 37)
    self._image.BackgroundTransparency = 1
    self._image.Image = "rbxassetid://124911070183024"
    self._image.ImageRectOffset = Vector2.new(12, 15)
    self._image.ImageRectSize = Vector2.new(62, 44)
    self._image.ImageColor3 = Color3.fromRGB(255, 255, 0)
    self._image.ScaleType = Enum.ScaleType.Fit
    self._image.Active = false
    self._image.Visible = false
    self._image.ZIndex = 100
    self._image.Parent = self._root
    self._shadow = self._image:Clone()
    self._shadow.Name = "Outline"
    self._shadow.ImageColor3 = Color3.new(0, 0, 0)
    self._shadow.Size = UDim2.fromOffset(57, 42)
    self._shadow.ZIndex = 99
    self._shadow.Parent = self._root
    return self
end

--- 跟随目标，以往复位移和轻微缩放强化指向；隐藏、禁用或滚出裁剪区的目标不显示箭头。
function UIGuideArrow:_Update()
    local target = self._target
    self._image.Visible = false
    self._shadow.Visible = false
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
    local pulse = (1 + math.sin(os.clock() * 4)) / 2
    local width = 52 + 3 * pulse
    local height = width * 44 / 62
    local gap = 4 + 9 * pulse
    local position = center - self._root.AbsolutePosition + direction * (halfTarget + width / 2 + gap)
    self._image.Size = UDim2.fromOffset(width, height)
    self._image.Position = UDim2.fromOffset(position.X, position.Y)
    self._image.Rotation = side.Rotation
    self._image.Visible = true
    self._shadow.Size = UDim2.fromOffset(width + 5, height + 5)
    self._shadow.Position = UDim2.fromOffset(position.X, position.Y + 1.5)
    self._shadow.Rotation = side.Rotation
    self._shadow.Visible = true
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

--- 退出步骤时隐藏箭头并释放逐帧更新，之后仍可绑定其他目标。
function UIGuideArrow:Hide()
    self._target = nil
    self._image.Visible = false
    self._shadow.Visible = false
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
