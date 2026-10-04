-- 放在 ScreenGui 下，按下面的配置缩放和避让直属 UI 分组。
local guiService = game:GetService("GuiService")
local screen = script.Parent
-- 主界面统一按 1280×720 设计；现有分组直接按新基准缩放。
local referenceSize = Vector2.new(1280, 720)
-- 大屏相对设计尺寸的最大放大倍数；不影响小屏缩小。
local maxScale = 1.25
-- 与 Roblox 原生顶栏及屏幕边缘之间保留的间距，单位为 UI 像素。
local topbarPadding = 12

-- 自定义枚举：只选择避让方向，不改变 UI 内部排版。
local TopbarAvoidance = {
    None = "None", -- 不避让。
    Right = "Right", -- 向右避让原生顶栏。
    Down = "Down", -- 向下避让原生顶栏。
}

-- 两种模式都对 UI 的宽、高使用同一个倍数，不会单独拉宽或拉高。
local ScaleMode = {
    FitScreen = "FitScreen", -- 取“可用宽度/1280”和“可用高度/720”中较小的比例。
    MatchWidth = "MatchWidth", -- 主要按“可用宽度/1280”计算，适合顶部；仍受可用空间限制。
}

-- 配置键填写 ScreenGui 直属分组的名称，不填写子孙节点路径。
-- 只列出需要特殊处理的分组，一般只需配置顶部。
-- avoidTopbar 从 TopbarAvoidance 中选择，省略默认为 None；碰到顶栏占用区域时才移动。
-- scaleMode 从 ScaleMode 中选择，省略默认为 FitScreen；所有模式都受 maxScale 放大上限限制。
-- 未列出的分组默认 None + FitScreen。每组只选一个避让方向。
-- 分组使用固定 Offset 尺寸，AnchorPoint 和 Position 保留设计值；不要由父级 Layout 控制。
local groupLayouts = {
    TopCenter = { avoidTopbar = TopbarAvoidance.Right, scaleMode = ScaleMode.MatchWidth },
    -- 例如让顶部下移：将 TopCenter 的 avoidTopbar 改为 TopbarAvoidance.Down。
}
local groups = {}
local currentScale = 1

--[[
 * 注册直属 UI 分组，复用已有缩放节点，避免给子孙节点重复缩放。
 * @param child Instance 新加入 ScreenGui 的节点。
 ]]
local function RegisterGroup(child)
    if not child:IsA("GuiObject") then
        return
    end
    local uiScale = child:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Name = "ResponsiveScale"
        uiScale.Parent = child
    end
    local baseScale = uiScale.Scale
    groups[child] = { scale = uiScale, baseScale = baseScale, basePosition = child.Position }
    uiScale.Scale = baseScale * currentScale
end

--[[
 * 分组移出当前界面时恢复设计位置和缩放，避免重新加入后累积偏移或缩小。
 * @param child Instance 离开 ScreenGui 的节点。
 ]]
local function UnregisterGroup(child)
    local entry = groups[child]
    if entry then
        entry.scale.Scale = entry.baseScale
        child.Position = entry.basePosition
        groups[child] = nil
    end
end

--[[
 * 默认按宽高等比缩放且不避让；有配置时按设计位置检测顶栏重叠并沿指定方向避让。
 * @param group GuiObject 当前 ScreenGui 的直属 UI 分组。
 * @param entry table 分组的原始位置、原始缩放和缩放节点。
 * @param size Vector2 当前 ScreenGui 安全区内的可用尺寸。
 * @param topbar Rect 已转换到当前 ScreenGui 坐标系的顶栏可用区域。
 ]]
local function LayoutGroup(group, entry, size, topbar)
    local layout = groupLayouts[group.Name]
    local scaleMode = layout and layout.scaleMode or ScaleMode.FitScreen
    local avoidance = layout and layout.avoidTopbar or TopbarAvoidance.None
    local position = entry.basePosition
    local anchor = group.AnchorPoint
    local width, height = group.Size.X.Offset, group.Size.Y.Offset
    local anchorX = size.X * position.X.Scale + position.X.Offset
    local anchorY = size.Y * position.Y.Scale + position.Y.Offset
    local scale = entry.baseScale * currentScale
    if scaleMode == ScaleMode.MatchWidth then
        scale = entry.baseScale * math.min(maxScale, size.X / referenceSize.X)
        if height > 0 and anchor.Y < 1 then
            local availableHeight = math.max(0, size.Y - anchorY - topbarPadding)
            scale = math.min(scale, availableHeight / (height * (1 - anchor.Y)))
        end
    end
    -- 每次从设计位置计算，避免窗口切换后保留或累加上一次的偏移。
    group.Position = position
    entry.scale.Scale = scale
    if avoidance == TopbarAvoidance.None then
        return
    end
    if width <= 0 or height <= 0 or topbar.Height <= 0 then
        return
    end
    local left = anchorX - width * scale * anchor.X
    local top = anchorY - height * scale * anchor.Y
    local leftEdge = math.max(0, topbar.Min.X) + topbarPadding
    local rightEdge = math.min(size.X, topbar.Max.X) - topbarPadding
    local bottomEdge = topbar.Max.Y + topbarPadding
    if top >= bottomEdge or top + height * scale <= topbar.Min.Y then
        return
    end
    if left >= leftEdge and left + width * scale <= rightEdge then
        return
    end

    local offsetX, offsetY = 0, 0
    if avoidance == TopbarAvoidance.Right then
        if rightEdge <= leftEdge then
            return
        end
        scale = math.min(scale, (rightEdge - leftEdge) / width)
        local targetX = math.min(rightEdge - width * scale * (1 - anchor.X),
            math.max(anchorX, leftEdge + width * scale * anchor.X))
        offsetX = targetX - anchorX
    elseif avoidance == TopbarAvoidance.Down then
        local availableHeight = size.Y - bottomEdge - topbarPadding
        if availableHeight <= 0 then
            return
        end
        scale = math.min(scale, availableHeight / height)
        offsetY = math.max(0, bottomEdge + height * scale * anchor.Y - anchorY)
    end
    entry.scale.Scale = scale
    group.Position = UDim2.new(position.X.Scale, position.X.Offset + offsetX,
        position.Y.Scale, position.Y.Offset + offsetY)
end

--[[
 * 安全区或顶栏变化时重新计算各组布局，不把设备刘海区域计入可用空间。
 ]]
local function Resize()
    local size = screen.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then
        return
    end
    currentScale = math.min(maxScale, size.X / referenceSize.X, size.Y / referenceSize.Y)
    -- GetInsetArea 的结果统一相对于 CoreUISafeInsets，先转换到当前 ScreenGui 的原点。
    local origin = guiService:GetInsetArea(screen.ScreenInsets).Min
    local topbarArea = guiService:GetInsetArea(Enum.ScreenInsets.TopbarSafeInsets)
    local topbar = Rect.new(topbarArea.Min - origin, topbarArea.Max - origin)
    for group, entry in pairs(groups) do
        LayoutGroup(group, entry, size, topbar)
    end
end

for childIndex, child in ipairs(screen:GetChildren()) do
    RegisterGroup(child)
end

--[[
 * 新加入或重新挂载的分组立即应用完整布局，不依赖窗口再次变化。
 * @param child Instance 加入当前界面的直属节点。
 ]]
local function OnChildAdded(child)
    if not child:IsA("GuiObject") then
        return
    end
    RegisterGroup(child)
    Resize()
end

local addedConnection = screen.ChildAdded:Connect(OnChildAdded)
local removedConnection = screen.ChildRemoved:Connect(UnregisterGroup)
local resizeConnection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
local topbarConnection = guiService:GetPropertyChangedSignal("TopbarInset"):Connect(Resize)
local insetConnection = screen:GetPropertyChangedSignal("ScreenInsets"):Connect(Resize)

--[[
 * 界面销毁时释放监听和分组引用，避免残留旧界面连接。
 ]]
local function Cleanup()
    addedConnection:Disconnect()
    removedConnection:Disconnect()
    resizeConnection:Disconnect()
    topbarConnection:Disconnect()
    insetConnection:Disconnect()
    table.clear(groups)
end

script.Destroying:Once(Cleanup)
Resize()
