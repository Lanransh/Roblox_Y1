local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local TranslationTexts = Text.Define("TrainingHUD", {
    Strength = "{rate}x Strength",
})
local CollectionService = game:GetService("CollectionService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CTrainingHUDCompClass", "FCPlayerCompClass")

--- 提供训练基地悬浮显示组件的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CTrainingHUDComp"
end

--- 仅翻译服务器挂载的 HUD，兼容场景节点按需加载。
--- @return nil
function Component:OnReady()
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self:TrackConnection(CollectionService:GetInstanceAddedSignal("TrainingHUDStrength"):Connect(function(label)
        self:RefreshLabel(label)
    end))
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    self:RefreshLocalization()
end

--- 按当前玩家语言显示倍率，节点及数值由服务器创建。
--- @param label TextLabel 服务器标记的训练倍率文本。
--- @return nil
function Component:RefreshLabel(label)
    label.Text = Text.Tr(TranslationTexts.Strength, {
        rate = GameUtility.NumberToText(label:GetAttribute("TrainingRate")),
    })
end

--- 刷新当前已复制到客户端的场景 HUD。
--- @return nil
function Component:RefreshLocalization()
    for index, label in ipairs(CollectionService:GetTagged("TrainingHUDStrength")) do
        self:RefreshLabel(label)
    end
end

return Component
