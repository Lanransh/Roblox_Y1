-- 世界终点文字沿用通用渐变特效；英文静态文案留在场景中供翻译工具采集。
local FX = _G.FX
local FXLoader = FX.Loader
local AnimatedText = FXLoader:Require(script.Parent.Parent, "UI/CAnimatedText")
local Component = FX.Class("CWorldCompletionSignCompClass", "FCPlayerCompClass")

--- 异步等待终点文字复制，避免阻塞其他玩家组件初始化。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._effects = {}
    self._initTask = task.defer(function()
        for worldIndex = 1, 2 do
            local label = FXLoader:Workspace(string.format(
                "Decorations/World%dDecorations/WorldCompletionSign/CompletionSurfaceGui/Message",
                worldIndex), math.huge)
            table.insert(self._effects, AnimatedText.Attach(label))
        end
        self._initTask = nil
    end)
end

--- 提供玩家对象内唯一的组件协作名称。
--- @return string 世界终点文字组件名称。
function Component:GetCompName()
    return "CWorldCompletionSignComp"
end

--- 取消复制等待并释放通用文字动画，保留场景持有的文字节点。
function Component:Dtor()
    if self._initTask then
        task.cancel(self._initTask)
    end
    for effectIndex, effect in ipairs(self._effects) do
        effect:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
