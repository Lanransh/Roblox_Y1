local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("TrainingHUD", {
    Strength = "Training ×{rate}",
})
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CTrainingHUDCompClass", "FCPlayerCompClass")

--- 提供训练基地悬浮显示组件的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CTrainingHUDComp"
end

--- 克隆共享模板，按训练配置挂载；编辑态预览仅在本客户端隐藏。
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self._huds = {}
    self._previews = {}
    local template = FXLoader:Shared("Nodes/TrainingHUD")
    for index, config in ipairs(_G.GameConfig.TrainingFieldData) do
        local worldName, fieldName = GameUtility.ParseTrainingFieldNode(config.Node)
        assert(worldName and fieldName, "Invalid training field Node: " .. config.Node)
        local field = FXLoader:Workspace("BlockMeshs/" .. worldName .. "/TrainingCenter/" .. fieldName)
        local platform = field:FindFirstChild("彩色训练台", true)
        assert(platform and platform:IsA("BasePart"), "Missing training platform: " .. field:GetFullName())
        local preview = field:FindFirstChild("TrainingHUD")
        if preview and preview:GetAttribute("TrainingHUDPreview") then
            self._previews[preview] = preview.Enabled
            preview.Enabled = false
        end
        local bounds, size = field:GetBoundingBox()
        local hud = template:Clone()
        hud.Name = "TrainingHUDClient"
        hud.Adornee = platform
        hud.StudsOffsetWorldSpace = Vector3.new(0,
            bounds.Position.Y + size.Y / 2 - platform.Position.Y + 5, 0)
        hud.Frame.Requirement.Count.Text = tostring(config.NeedRebirhLevel)
        hud.Parent = field
        self._huds[index] = {Node = hud, Config = config}
    end
    self:RefreshLocalization()
    --- 语言切换和云端翻译就绪后重新赋值，保留稳定参数 Key。
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
end

--- 数量沿用通用格式化，英文兜底由现有本地化入口提供。
function Component:RefreshLocalization()
    for index, entry in ipairs(self._huds) do
        entry.Node.Frame.Strength.Text = Text.Tr(TranslationTexts.Strength, {
            rate = GameUtility.NumberToText(entry.Config.TrainingRate),
        })
    end
end

--- 销毁本客户端克隆并恢复预览，语言订阅由父类解除。
function Component:Dtor()
    for index, entry in ipairs(self._huds or {}) do
        entry.Node:Destroy()
    end
    for preview, enabled in pairs(self._previews or {}) do
        if preview.Parent then
            preview.Enabled = enabled
        end
    end
    Component.Super.Dtor(self)
end

return Component
