local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local TranslationTexts = Text.Define("TrainingHUD", {
    Strength = "{rate}x Strength",
})
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local Component = FX.Class("CTrainingHUDCompClass", "FCPlayerCompClass")

--- 提供训练基地悬浮显示组件的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CTrainingHUDComp"
end

--- 按完整配置路径克隆 HUD；监听后续复制的旧预览，避免初始化后出现重复标牌。
--- @return nil
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self._huds = {}
    self._previews = {}
    local template = FXLoader:Shared("Nodes/TrainingHUD")
    local playerGui = FXLoader:Here(self:GetPlayerNode(), "PlayerGui", math.huge)
    --- 旧预览可能晚于组件复制到客户端，只隐藏预览目录中带标记的标牌。
    --- @param preview Instance 新复制或已存在的场景节点。
    local function hidePreview(preview)
        if not preview:IsA("BillboardGui") or not preview:GetAttribute("TrainingHUDPreview") then
            return
        end
        local previews = FXLoader:Find(workspace, "Decorations/TrainingHUDs")
        if previews and preview:IsDescendantOf(previews) then
            if self._previews[preview] == nil then
                self._previews[preview] = preview.Enabled
            end
            preview.Enabled = false
        end
    end
    self:TrackConnection(workspace.DescendantAdded:Connect(hidePreview))
    local previews = FXLoader:Find(workspace, "Decorations/TrainingHUDs")
    if previews then
        for previewIndex, preview in ipairs(previews:GetDescendants()) do
            hidePreview(preview)
        end
    end
    for index, config in ipairs(_G.GameConfig.TrainingFieldData) do
        local field = InstancePath.Wait(config.Node)
        local platform = field:FindFirstChild("彩色训练台", true)
        -- 模型根先复制到客户端时，其嵌套训练台可能尚未到达。
        while not platform do
            field.DescendantAdded:Wait()
            platform = field:FindFirstChild("彩色训练台", true)
        end
        assert(platform and platform:IsA("BasePart"), "Missing training platform: " .. field:GetFullName())
        local bounds, size = field:GetBoundingBox()
        local hud = template:Clone()
        hud.Name = "TrainingHUDClient"
        hud.ResetOnSpawn = false
        hud.Adornee = platform
        hud.StudsOffsetWorldSpace = Vector3.new(0,
            bounds.Position.Y + size.Y / 2 - platform.Position.Y + 5, 0)
        FXLoader:Here(hud, "Frame/Requirement/Count").Text = tostring(config.NeedRebirhLevel)
        hud.Parent = playerGui
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
        FXLoader:Here(entry.Node, "Frame/Strength").Text = Text.Tr(TranslationTexts.Strength, {
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
