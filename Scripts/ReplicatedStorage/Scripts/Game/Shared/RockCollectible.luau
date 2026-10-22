-- 掉落表现由拥有者客户端本地创建，模型与 HUD 样式在客户端和服务端共享。
local FX = _G.FX
local FXLoader = FX.Loader
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local Collectible = {}

-- 按现有 1～35 品质编号提供独立 HUD 配色，不改变配置中的品质或掉落规则。
local QualityColors = {
    "C5CAD8", "76E65A", "42ADFF", "BA79FF", "FFD34E",
    "FF963F", "FF5555", "FF80C8", "4DE5DD", "A3B6FF",
    "D9EEFF", "B7F58A", "74D3FF", "DBA5FF", "FFF18A",
    "FFBC78", "FF8F9D", "FFACE8", "98FFF0", "C2A7FF",
    "88A7C4", "36D69A", "5987FF", "E45DFF", "E5B53C",
    "FF713D", "F13D82", "ED6EB6", "22BDD5", "8F79FF",
    "E8EAF5", "D2FF52", "44F2FF", "FF54DD", "FFE5B4",
}

Collectible.PickupDistance = 10
Collectible.DropLifetime = 10
Collectible.DropRevealDuration = 1 -- 黑色候选轮转时长，客户端表现与服务端拾取等待共用。

--- 按 GameConfig 的稳定展示路径读取道具模型，不通过道具 ID 猜模型下标。
--- @param displayModelId string GameConfig.ItemData 中的完整实例路径。
--- @return Model|nil 具有 PrimaryPart 的展示模型模板。
function Collectible.ResolveModel(displayModelId)
    local instance = InstancePath.Find(displayModelId)
    if not instance or not instance:IsA("Model") or not instance.PrimaryPart then
        return nil
    end
    return instance
end

--- 过小模板先归一到 2.4 studs，再整体放大 1.2 倍；较大模板按原尺寸放大，再焊接为单个装配。
--- @param template Model 已导入的收藏品模板。
--- @return Model 以 PrimaryPart 为锚点、无碰撞的收藏品副本。
function Collectible.CreateModel(template)
    local model = template:Clone()
    model:PivotTo(CFrame.new())
    local size = model:GetExtentsSize()
    local longestSide = math.max(size.X, size.Y, size.Z)
    if longestSide < 2.4 then
        model:ScaleTo(model:GetScale() * 2.4 / longestSide)
    end
    model:ScaleTo(model:GetScale() * 1.2)
    local root = model.PrimaryPart
    for index, node in ipairs(model:GetDescendants()) do
        if node:IsA("BasePart") then
            node.Anchored = node == root
            node.CanCollide = false
            node.CanTouch = false
            node.CanQuery = false
            node.Massless = true
            if node ~= root then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = root
                weld.Part1 = node
                weld.Parent = root
            end
        end
    end
    return model
end

--- 用模型包围盒顶部定位 HUD；四行统一字号并保留垂直间距，随距离自然缩放。
--- @param hud BillboardGui 本次掉落独有的 HUD 副本。
--- @param model Model 已完成缩放及摆放的掉落模型。
--- @param quality number 配置中的道具品质编号。
function Collectible.StyleHUD(hud, model, quality)
    local box, size = model:GetBoundingBox()
    hud.Size = UDim2.fromScale(6.5, 3.5)
    hud.StudsOffsetWorldSpace = box.Position - model.PrimaryPart.Position
        + Vector3.new(0, size.Y / 2 + 3.5, 0)
    local frame = hud.Frame
    frame.Timer.AnchorPoint = Vector2.new(0.5, 0)
    frame.Timer.Position = UDim2.new(0.5, 0, 0.05, 0)
    frame.Timer.Size = UDim2.fromScale(0.3, 0.21)
    frame.Timer.TextXAlignment = Enum.TextXAlignment.Center
    frame.ItemName.Position = UDim2.new(0.5, 0, 0.28, 0)
    frame.ItemName.Size = UDim2.fromScale(0.95, 0.21)
    frame.ItemName.TextColor3 = Color3.new(1, 1, 1)
    frame.Rarity.Position = UDim2.new(0.5, 0, 0.51, 0)
    frame.Rarity.Size = UDim2.fromScale(0.84, 0.21)
    local qualityColor = Color3.fromHex(QualityColors[quality] or "C5CAD8")
    -- UIGradient 与文字底色相乘，白色底色才能保留各品质的完整渐变色。
    frame.Rarity.TextColor3 = Color3.new(1, 1, 1)
    local gradient = frame.Rarity:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    gradient.Name = "QualityGradient"
    gradient.Enabled = true
    gradient.Rotation = 90
    gradient.Offset = Vector2.zero
    gradient.Transparency = NumberSequence.new(0)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, qualityColor:Lerp(Color3.new(1, 1, 1), 0.35)),
        ColorSequenceKeypoint.new(0.45, qualityColor),
        ColorSequenceKeypoint.new(1, qualityColor:Lerp(Color3.new(0, 0, 0), 0.22)),
    })
    gradient.Parent = frame.Rarity
    frame.Price.Position = UDim2.new(0.5, 0, 0.74, 0)
    frame.Price.Size = UDim2.fromScale(0.9, 0.21)
    frame.Price.TextColor3 = Color3.fromRGB(86, 255, 101)
    frame.LuckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.LuckIcon.Position = UDim2.new(0.04, 0, 0.845, 0)
    frame.LuckIcon.Size = UDim2.fromScale(0.09, 0.16)
    for index, label in ipairs({frame.ItemName, frame.Rarity, frame.Price, frame.Timer}) do
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 18
        -- TextWrapped 会重置 TextScaled，必须先关闭换行再启用缩放。
        label.TextWrapped = false
        label.TextScaled = true
        label.TextOutline.Color = Color3.fromRGB(12, 12, 16)
        label.TextOutline.Thickness = 2
    end
end

return Collectible
