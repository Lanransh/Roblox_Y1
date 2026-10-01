local FX, FC = _G.FX, _G.FC
local Input = game:GetService("UserInputService")
local Touch = FX.Class("FCTouchObjectClass")
FC.TouchObjectClass = Touch
--- 同时支持鼠标和触摸；已被 GUI 消费的输入不会触发场景使用道具。
function Touch:Ctor()
    self._connections, self._active = {}, {}
    self.currentTouchPos, self.isTouching = { x = 0, y = 0 }, false
    self._connections[1] = Input.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if
            input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1
        then
            return
        end
        self._active[input] = true
        self:OnTouchStarted(input.Position.X, input.Position.Y, input)
    end)
    self._connections[2] = Input.InputChanged:Connect(function(input)
        if self._active[input] then
            self:OnTouchMoved(input.Position.X, input.Position.Y, input)
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            for active in pairs(self._active) do
                if active.UserInputType == Enum.UserInputType.MouseButton1 then
                    self:OnTouchMoved(input.Position.X, input.Position.Y, active)
                end
            end
        end
    end)
    self._connections[3] = Input.InputEnded:Connect(function(input)
        if not self._active[input] then
            return
        end
        self._active[input] = nil
        self:OnTouchEnded(input.Position.X, input.Position.Y, input)
    end)
end
--- @param startedCallback function 开始回调。
--- @param movedCallback function 移动回调。
--- @param endedCallback function 结束回调。
function Touch:SetCallbacks(startedCallback, movedCallback, endedCallback)
    self._Started, self._Moved, self._Ended = startedCallback, movedCallback, endedCallback
end
for _, name in ipairs({ "Started", "Moved", "Ended" }) do
    --- @param self table 当前输入对象。
    --- @param callback function 接收像素坐标和 InputObject。
    Touch["SetTouch" .. name .. "Callback"] = function(self, callback)
        self["_" .. name] = callback
    end
    --- @param self table 当前输入对象。
    --- @param x number 屏幕 X。
    --- @param y number 屏幕 Y。
    --- @param input InputObject 输入身份；多指不会互相覆盖。
    Touch["OnTouch" .. name] = function(self, x, y, input)
        self.currentTouchPos = { x = x, y = y }
        self.isTouching = next(self._active) ~= nil
        if self["_" .. name] then
            self["_" .. name](x, y, input)
        end
    end
end
--- 释放全局输入监听。
function Touch:Dtor()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    table.clear(self._active)
    self.isTouching = false
end
Touch.Unregister = Touch.Dtor
return Touch
