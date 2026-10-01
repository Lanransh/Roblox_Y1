local FX, FC = _G.FX, _G.FC
local Input = game:GetService("UserInputService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local GuiService = game:GetService("GuiService")
local Drag = FX.Class("FCDragObjectClass")
FC.DragObjectClass = Drag
--- @param draggingParent GuiObject 拖拽视觉层；支持 ScreenGui。
function Drag:Ctor(draggingParent)
    self._parent, self._enabled = draggingParent, true
    self._sources, self._destinations = {}, {}
    self._offset = Vector2.zero
    self._move = Input.InputChanged:Connect(function(input)
        if self._input and (input == self._input or input.UserInputType == Enum.UserInputType.MouseMovement) then
            self:_OnMove(input.Position.X, input.Position.Y)
        end
    end)
    self._release = Input.InputEnded:Connect(function(input)
        if input == self._input then
            self:_OnDragEnd()
        end
    end)
end
--- @param enabled boolean 禁用时立即取消拖拽。
function Drag:SetEnabled(enabled)
    self._enabled = enabled
    if not enabled then
        self:Reset()
    end
end
--- @param enabled boolean 是否输出调试信息。
function Drag:SetDebugMode(enabled)
    self._debug = enabled
end
--- @param x number 水平像素偏移。
--- @param y number 垂直像素偏移。
function Drag:SetDragOffset(x, y)
    self._offset = Vector2.new(x, y)
end
--- @param callback function 接收源节点、目标节点和双方业务数据。
function Drag:SetDragFinished(callback)
    self._finished = callback
end
--- @param node GuiObject 可拖拽按钮或图像。
--- @param userData any 业务身份，通常为真实背包格号。
function Drag:SetDraggable(node, userData)
    self:ClearDraggable(node)
    self._sources[node] = node.InputBegan:Connect(function(input)
        if not self._enabled or self._input then
            return
        end
        if
            input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end
        self._input, self._source, self._data = input, node, userData
        self._start = Vector2.new(input.Position.X, input.Position.Y)
        self._position = self._start
    end)
end
--- @param node GuiObject 释放位置的候选目标。
--- @param userData any 目标业务数据。
function Drag:SetDestination(node, userData)
    self._destinations[node] = { data = userData }
end
--- @param node GuiObject 需要解除拖拽的节点。
function Drag:ClearDraggable(node)
    if self._sources[node] then
        self._sources[node]:Disconnect()
    end
    self._sources[node] = nil
    if self._source == node then
        self:Reset()
    end
end
--- @param node GuiObject 需要解除的目标。
function Drag:ClearDestination(node)
    self._destinations[node] = nil
end
--- @param x number 屏幕像素 X。
--- @param y number 屏幕像素 Y。
function Drag:_OnMove(x, y)
    self._position = Vector2.new(x, y)
    if not self._ghost and (self._position - self._start).Magnitude < 6 then
        return
    end
    if not self._ghost then
        self._ghost = self._source:Clone()
        self._ghost.AnchorPoint = Vector2.zero
        self._ghost.Size = UDim2.fromOffset(self._source.AbsoluteSize.X, self._source.AbsoluteSize.Y)
        self._ghost.ZIndex = 100
        self._ghost.Active = false
        self._ghost.Parent = self._parent
    end
    local origin = Vector2.zero
    if self._parent:IsA("GuiObject") then
        origin = self._parent.AbsolutePosition
    else
        if not self._parent.IgnoreGuiInset then
            origin = GuiService:GetGuiInset()
        end
    end
    local localPosition = self._position - origin + self._offset
    self._ghost.Position = UDim2.fromOffset(localPosition.X, localPosition.Y)
end
--- 只认顶层可见 GUI 命中链，保留触摸释放到空背包区的语义。
function Drag:_OnDragEnd()
    local source, data, target, targetData = self._source, self._data, nil, nil
    if self._ghost then
        self._ghost.Visible = false
        local hits = PlayerGui:GetGuiObjectsAtPosition(self._position.X, self._position.Y)
        for _, hit in ipairs(hits) do
            local current = hit
            while current and current ~= PlayerGui do
                if self._destinations[current] then
                    target, targetData = current, self._destinations[current].data
                    break
                end
                current = current.Parent
            end
            if target then
                break
            end
        end
    end
    self:Reset()
    if target and self._finished then
        self._finished(source, target, data, targetData)
    end
end
--- 取消当前手势，保留已登记源和目标。
function Drag:Reset()
    if self._ghost then
        self._ghost:Destroy()
    end
    self._ghost, self._input, self._source, self._data = nil, nil, nil, nil
end
--- 清理 GUI 和全局输入监听。
function Drag:Dtor()
    self:Reset()
    self._move:Disconnect()
    self._release:Disconnect()
    for _, connection in pairs(self._sources) do
        connection:Disconnect()
    end
    table.clear(self._sources)
    table.clear(self._destinations)
end
return Drag
