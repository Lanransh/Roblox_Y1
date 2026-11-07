-- 三个世界的箭头随各自装饰分组移动，动画起点使用模型局部坐标。
local FX = _G.FX
local FXLoader = FX.Loader
local RunService = game:GetService("RunService")
local Component = FX.Class("CGroundGuideArrowsCompClass", "FCPlayerCompClass")

--- 异步等待场景复制，不阻塞玩家对象及其他组件创建。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
--- @return nil
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._arrows = {}
    self._elapsed = 0
    self._initTask = task.defer(function()
        self:InitArrows()
        self._initTask = nil
    end)
end

--- 提供组件协作名称。
--- @return string 地面引导箭头组件名称。
function Component:GetCompName()
    return "CGroundGuideArrowsComp"
end

--- 复制完成后记录原始外观，并由组件持有渲染连接。
--- @return nil
function Component:InitArrows()
    local decorations = FXLoader:Workspace("Decorations", math.huge)
    local guides = {
        FXLoader:Here(decorations, "World1Decorations/GroundGuideArrows", math.huge),
        FXLoader:Here(decorations, "World2Decorations/World2GroundGuideArrows", math.huge),
        FXLoader:Here(decorations, "World3Decorations/World3GroundGuideArrows", math.huge),
    }
    for guideIndex, guide in ipairs(guides) do
        for arrowIndex, arrow in ipairs(guide:GetChildren()) do
            if arrow:IsA("Model") then
                local parts = {}
                for partIndex, part in ipairs(arrow:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(parts, {part = part, transparency = part.LocalTransparencyModifier})
                    end
                end
                table.insert(self._arrows, {
                    guide = guide,
                    model = arrow,
                    rest = arrow:GetPivot(),
                    phase = arrow:GetAttribute("Phase"),
                    parts = parts,
                })
            end
        end
    end
    self:TrackConnection(RunService.RenderStepped:Connect(function(dt)
        self:UpdateArrows(dt)
    end))
end

--- 三个世界复用原有的循环移动和淡入淡出效果。
--- @param dt number 平台渲染回调提供的帧间隔（秒）。
--- @return nil
function Component:UpdateArrows(dt)
    self._elapsed += dt
    for arrowIndex, arrow in ipairs(self._arrows) do
        local start = arrow.guide:GetAttribute("StartOffset")
        local length = arrow.guide:GetAttribute("TravelLength")
        local speed = arrow.guide:GetAttribute("Speed")
        local distance = (arrow.phase + self._elapsed * speed) % length
        arrow.model:PivotTo(arrow.guide:GetPivot() * start * CFrame.new(0, 0, distance))
        local opacity = math.clamp(math.min(distance, length - distance) / 3, 0, 1)
        for partIndex, entry in ipairs(arrow.parts) do
            entry.part.LocalTransparencyModifier = 1 - opacity
        end
    end
end

--- 取消复制等待、断开渲染并还原组件接管的箭头外观。
--- @return nil
function Component:Dtor()
    if self._initTask then
        task.cancel(self._initTask)
    end
    Component.Super.Dtor(self)
    for arrowIndex, arrow in ipairs(self._arrows) do
        arrow.model:PivotTo(arrow.rest)
        for partIndex, entry in ipairs(arrow.parts) do
            entry.part.LocalTransparencyModifier = entry.transparency
        end
    end
end

return Component
