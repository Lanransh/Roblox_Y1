-- Canvas 内的 UI 按 1280×720 排版，由父级统一等比缩放。
local screen = script.Parent
local canvas = screen:WaitForChild("Canvas")
local uiScale = canvas:WaitForChild("ResponsiveScale")
local referenceSize = Vector2.new(1280, 720)

--[[
 * 将设计画布完整放入 ScreenGui 安全区，保持子节点的宽高比例。
 ]]
local function Resize()
    local size = screen.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then
        return
    end
    uiScale.Scale = math.min(size.X / referenceSize.X, size.Y / referenceSize.Y)
end

local resizeConnection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)

--[[
 * 适配脚本销毁时解除尺寸监听，避免保留旧画布引用。
 ]]
local function Cleanup()
    resizeConnection:Disconnect()
end

script.Destroying:Once(Cleanup)
Resize()
