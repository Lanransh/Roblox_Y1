-- 放在 ScreenGui 下缩放直属 UI 分组；顶部按宽度适配，避免横屏高度压缩文字。
local guiService = game:GetService("GuiService")
local screen = script.Parent
local referenceSize = Vector2.new(1100, 600)
-- 大屏相对设计尺寸的最大放大倍数；不影响小屏缩小。
local maxScale = 1.1
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
    groups[child] = { scale = uiScale, baseScale = baseScale }
    uiScale.Scale = baseScale * currentScale
end

--[[
 * 分组移出当前界面时恢复原始缩放，避免重新加入后累积缩小。
 * @param child Instance 离开 ScreenGui 的节点。
 ]]
local function UnregisterGroup(child)
    local entry = groups[child]
    if entry then
        entry.scale.Scale = entry.baseScale
        groups[child] = nil
    end
end

--[[
 * 双向等比缩放并限制大屏放大倍数；顶部同时受菜单宽度和剩余高度限制。
 ]]
local function Resize()
    local size = screen.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then
        return
    end
    currentScale = math.min(maxScale, size.X / referenceSize.X, size.Y / referenceSize.Y)
    for group, entry in pairs(groups) do
        if group.Name == "TopCenter" then
            local topbar = guiService:GetInsetArea(Enum.ScreenInsets.TopbarSafeInsets)
            local originX = screen.AbsolutePosition.X
            local leftEdge = math.max(0, topbar.Min.X - originX) + 12
            local rightEdge = math.min(size.X, topbar.Max.X - originX) - 12
            -- 顶栏初始化或菜单变化时可能暂时没有可用空间，等待下一次布局更新。
            if rightEdge <= leftEdge then
                continue
            end
            local width = group.Size.X.Offset
            local topY = size.Y * group.Position.Y.Scale + group.Position.Y.Offset
            local availableHeight = math.max(0, size.Y - topY - 12)
            local scale = math.min(entry.baseScale * maxScale, entry.baseScale * size.X / referenceSize.X,
                (rightEdge - leftEdge) / width, availableHeight / group.Size.Y.Offset)
            entry.scale.Scale = scale
            local halfWidth = width * scale / 2
            local centerX = math.min(rightEdge - halfWidth,
                math.max(size.X / 2, leftEdge + halfWidth))
            group.AnchorPoint = Vector2.new(0.5, 0)
            group.Position = UDim2.new(0, centerX, group.Position.Y.Scale, group.Position.Y.Offset)
        else
            entry.scale.Scale = entry.baseScale * currentScale
        end
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

--[[
 * 界面销毁时释放监听和分组引用，避免残留旧界面连接。
 ]]
local function Cleanup()
    addedConnection:Disconnect()
    removedConnection:Disconnect()
    resizeConnection:Disconnect()
    topbarConnection:Disconnect()
    table.clear(groups)
end

script.Destroying:Once(Cleanup)
Resize()
