local FX = _G.FX
local FXLoader = FX.Loader
local Collectible = {}

Collectible.ItemId = 1003
Collectible.DropChance = 0.5
Collectible.MinPrice = 10
Collectible.MaxPrice = 1000
Collectible.PickupDistance = 10
Collectible.DropLifetime = 10

--- 将静态收藏品焊接为单个装配，供掉落补间和背包手持共用。
--- @param template Model 已导入的收藏品模板。
--- @return Model 以 PrimaryPart 为锚点、无碰撞的收藏品副本。
function Collectible.CreateModel(template)
    local model = template:Clone()
    model:PivotTo(CFrame.new())
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

--- 按存档模板名从公共模型目录重建收藏品，随机价格不在重生或重登时重抽。
--- @param extraData table 背包保存的 TemplateName 和 Price。
--- @return Tool|nil 模板仍有效时返回收藏品 Tool。
function Collectible.CreateTool(extraData)
    if type(extraData) ~= "table" or type(extraData.TemplateName) ~= "string"
        or type(extraData.Price) ~= "number" then
        return nil
    end
    local template = FXLoader:Shared("Assets/Models/Collectibles167"):FindFirstChild(extraData.TemplateName)
    if not template or not template:IsA("Model") or not template.PrimaryPart then
        return nil
    end
    local model = Collectible.CreateModel(template)
    local tool = Instance.new("Tool")
    tool.Name = template:GetAttribute("DisplayName")
    tool.ToolTip = string.format("%s · $%d", tool.Name, extraData.Price)
    tool.CanBeDropped = false
    tool:SetAttribute("Price", extraData.Price)
    tool:SetAttribute("CollectibleTemplate", template.Name)
    local root = model.PrimaryPart
    root.Name = "Handle"
    root.Anchored = false
    root.Parent = tool
    for index, node in ipairs(model:GetChildren()) do
        node.Parent = tool
    end
    model:Destroy()
    return tool
end

return Collectible
