local FX = _G.FX
local FXLoader = FX.Loader
local CollectionService = game:GetService("CollectionService")
local TrainingFields = FXLoader:Require(script.Parent.Parent.Player, "TrainingFields")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local Text = FX.Text
local TranslationTexts = Text.Define("TrainingHUD", {
    Strength = "{rate}x Strength",
})
local Service = {}

--- 服务器初始化时按配置挂载场景 HUD，随训练台一起复制到客户端。
--- @return nil
function Service.Init()
    local template = FXLoader:Shared("Nodes/TrainingHUD")
    for index, field in ipairs(TrainingFields.GetFields()) do
        local platform = field.Platform
        local model = InstancePath.Find(field.Config.Node)
        local bounds, size = model:GetBoundingBox()
        local hud = template:Clone()
        hud.Name = "TrainingHUD"
        hud.Adornee = platform
        hud.StudsOffsetWorldSpace = Vector3.new(0,
            bounds.Position.Y + size.Y / 2 - platform.Position.Y + 5, 0)
        FXLoader:Here(hud, "Frame/Requirement/Count").Text = tostring(field.Config.NeedRebirhLevel)
        local strength = FXLoader:Here(hud, "Frame/Strength")
        strength.AutoLocalize = false
        strength:SetAttribute("TrainingRate", field.Config.TrainingRate)
        -- 服务端只填英文兜底，玩家语言由客户端翻译。
        strength.Text = string.gsub(TranslationTexts.Strength.Source, "{rate}",
            GameUtility.NumberToText(field.Config.TrainingRate))
        hud.Parent = platform
        CollectionService:AddTag(strength, "TrainingHUDStrength")
    end
end

return Service
