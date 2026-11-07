local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")

--- 三个世界的地面引导沿各自装饰分组的局部坐标移动。
local Component = FX.Class("CGroundGuideArrowsCompClass", "FCPlayerCompClass")

--- 记录动画状态，帧连接交由组件基类统一释放。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._arrows = {}
    self._elapsed = 0
end

--- 提供玩家对象内唯一的组件名称。
--- @return string 地面引导组件名称。
function Component:GetCompName()
    return "CGroundGuideArrowsComp"
end

--- 服务端就绪后收集原有三个世界的箭头，不创建额外执行入口。
function Component:OnReady()
    local guides = {
        FXLoader:Workspace("Decorations/World1Decorations/GroundGuideArrows"),
        FXLoader:Workspace("Decorations/World2Decorations/World2GroundGuideArrows"),
        FXLoader:Workspace("Decorations/World3Decorations/World3GroundGuideArrows"),
    }
    for guideIndex, guide in ipairs(guides) do
        for arrowIndex, arrow in ipairs(guide:GetChildren()) do
            if arrow:IsA("Model") then
                table.insert(self._arrows, {
                    guide = guide,
                    model = arrow,
                    phase = arrow:GetAttribute("Phase"),
                    parts = arrow:GetChildren(),
                })
            end
        end
    end
    self:TrackConnection(RunService.RenderStepped:Connect(function(deltaTime)
        self:UpdateArrows(deltaTime)
    end))
end

--- 保留原有循环移动和淡入淡出效果，位置随装饰模型移动。
--- @param deltaTime number 引擎渲染帧间隔，单位秒。
function Component:UpdateArrows(deltaTime)
    self._elapsed += deltaTime
    for arrowIndex, arrow in ipairs(self._arrows) do
        local start = arrow.guide:GetAttribute("StartOffset")
        local length = arrow.guide:GetAttribute("TravelLength")
        local speed = arrow.guide:GetAttribute("Speed")
        local distance = (arrow.phase + self._elapsed * speed) % length
        arrow.model:PivotTo(arrow.guide:GetPivot() * start * CFrame.new(0, 0, distance))
        local opacity = math.clamp(math.min(distance, length - distance) / 3, 0, 1)
        for partIndex, part in ipairs(arrow.parts) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1 - opacity
            end
        end
    end
end

return Component
