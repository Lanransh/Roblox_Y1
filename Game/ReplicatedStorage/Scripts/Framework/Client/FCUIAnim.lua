local TweenService = game:GetService("TweenService")
local Anim = { _active = setmetatable({}, { __mode = "k" }) }
_G.FC.UIAnim = Anim

--- @param node GuiObject 动画根节点。
--- @return UIScale 统一缩放节点。
local function Scale(node)
    local scale = node:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale", node)
    end

    return scale
end

--- @param node Instance 被插值的对象。
--- @param goals table 目标属性。
--- @param duration number 秒数。
--- @param callback function 可选的成功完成回调。
--- @param info TweenInfo 可选的插值参数。
--- @return Tween 可取消的原生动画。
function Anim:_Play(node, goals, duration, callback, info)
    self:StopProgress(node)
    local tween = TweenService:Create(node, info or TweenInfo.new(duration or 0.2), goals)
    self._active[node] = tween
    tween.Completed:Once(function(state)
        if self._active[node] == tween then
            self._active[node] = nil
        end

        tween:Destroy()
        if state == Enum.PlaybackState.Completed and callback then
            callback()
        end
    end)

    tween:Play()
    return tween
end

--- @param node GuiObject 面板。
--- @param duration number 可选秒数。
--- @param callback function 可选完成回调。
--- @return Tween 打开动画。
function Anim:Open(node, duration, callback)
    local scale = Scale(node)
    scale.Scale = 0.7
    return self:_Play(
        scale,
        { Scale = 1 },
        duration,
        callback,
        TweenInfo.new(duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    )
end

--- @param node GuiObject 面板。
--- @param callback function 在动画后隐藏面板的回调。
--- @param duration number 可选秒数。
--- @return Tween 关闭动画。
function Anim:Close(node, callback, duration)
    local scale = Scale(node)
    return self:_Play(scale, { Scale = 0.8 }, duration, function()
        if callback then
            callback()
        end

        scale.Scale = 1
    end)
end

--- @param node GuiObject 面板。
--- @param duration number 可选秒数。
--- @param callback function 可选完成回调。
--- @param offset Vector2 可选滑入像素偏移。
--- @return Tween 滑入动画。
function Anim:Show1(node, duration, callback, offset)
    offset = offset or Vector2.new(1200, 0)
    local origin = node.Position
    node.Position = origin - UDim2.fromOffset(offset.X, offset.Y)
    return self:_Play(node, { Position = origin }, duration, callback)
end

--- @param node GuiObject 面板。
--- @param callback function 完成后隐藏节点的回调。
--- @param duration number 可选秒数。
--- @param offset Vector2 可选滑出偏移。
--- @return Tween 滑出动画。
function Anim:Close1(node, callback, duration, offset)
    offset = offset or Vector2.new(1200, 0)
    local origin = node.Position
    return self:_Play(node, { Position = origin + UDim2.fromOffset(offset.X, offset.Y) }, duration, function()
        if callback then
            callback()
        end

        node.Position = origin
    end)
end

--- @param node GuiObject 面板。
--- @param offset Vector2 像素位移。
--- @param duration number 秒数。
--- @param callback function 完成回调。
--- @return Tween 移动动画。
function Anim:Move(node, offset, duration, callback)
    return self:_Play(node, { Position = node.Position + UDim2.fromOffset(offset.X, offset.Y) }, duration, callback)
end

--- @param node CanvasGroup 淡入需要原生 CanvasGroup 以覆盖子节点。
--- @param duration number 秒数。
--- @param callback function 完成回调。
--- @return Tween 淡入动画。
function Anim:FadeIn(node, duration, callback)
    node.GroupTransparency = 1
    return self:_Play(node, { GroupTransparency = 0 }, duration, callback)
end

--- @param node CanvasGroup 淡出根节点。
--- @param callback function 完成后隐藏节点的回调。
--- @param duration number 秒数。
--- @return Tween 淡出动画。
function Anim:FadeOut(node, callback, duration)
    return self:_Play(node, { GroupTransparency = 1 }, duration, callback)
end

--- @param node GuiObject 抖动节点。
--- @param intensity number 像素振幅。
--- @param duration number 总秒数。
--- @param shakes number 往返次数。
--- @return Tween 抖动动画。
function Anim:Shake(node, intensity, duration, shakes)
    local origin = node.Position
    return self:_Play(
        node,
        { Position = origin + UDim2.fromOffset(intensity or 5, 0) },
        duration,
        function()
            node.Position = origin
        end,
        TweenInfo.new(
            (duration or 0.3) / ((shakes or 3) * 2),
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            (shakes or 3) - 1,
            true
        )
    )
end

--- @param node GuiObject 脉冲节点。
--- @param scalePercent number 相对放大量，例如 0.1。
--- @param repeatCount number 往返次数。
--- @param duration number 单程秒数。
--- @return Tween 脉冲动画。
function Anim:Pulse(node, scalePercent, repeatCount, duration)
    local scale = Scale(node)
    return self:_Play(
        scale,
        { Scale = 1 + (scalePercent or 0.1) },
        duration,
        nil,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, (repeatCount or 1) - 1, true)
    )
end

--- @param node Instance 需要停止的插值对象。
function Anim:StopProgress(node)
    local tween = self._active[node]
    if tween then
        self._active[node] = nil
        tween:Cancel()
        tween:Destroy()
    end
end

--- @param node GuiObject 进度填充节点，水平 Size.Scale 表示进度。
--- @param progress number 0 到 1。
--- @param duration number 秒数。
--- @param callback function 完成回调。
--- @return Tween 进度动画。
function Anim:Progress(node, progress, duration, callback)
    return self:_Play(
        node,
        { Size = UDim2.new(math.clamp(progress, 0, 1), 0, node.Size.Y.Scale, node.Size.Y.Offset) },
        duration,
        callback
    )
end

return Anim
