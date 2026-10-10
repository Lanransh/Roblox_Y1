local FX = _G.FX
local FXLoader = FX.Loader
local Collectible = {}
local GameConfig = _G.GameConfig
local CollectibleText = FXLoader:RequireShared("Scripts/Game/Shared/CollectibleText")
local English = FXLoader:Shared("Shared/Localization"):GetTranslator("en-us")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")

Collectible.ItemId = 1003
Collectible.PickupDistance = 10
Collectible.DropLifetime = 10

--- 按 GameConfig 的稳定展示路径读取道具模型，不通过道具 ID 猜模型下标。
--- @param displayModelId string GameConfig.ItemData 中的完整实例路径。
--- @return Model|nil 具有 PrimaryPart 的展示模型模板。
function Collectible.ResolveModel(displayModelId)
    local path = type(displayModelId) == "string" and string.match(displayModelId, "^game%.(.+)$")
    if not path then
        return nil
    end
    local instance = game
    for name in string.gmatch(path, "[^%.]+") do
        instance = instance:FindFirstChild(name)
        if not instance then
            return nil
        end
    end
    if not instance:IsA("Model") or not instance.PrimaryPart then
        return nil
    end
    return instance
end

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
    local template
    if type(extraData.ItemId) == "number" then
        local itemData = GameConfig.ItemData[extraData.ItemId]
        if itemData and (not extraData.DisplayModelId or extraData.DisplayModelId == itemData.DisplayModelId) then
            template = Collectible.ResolveModel(itemData.DisplayModelId)
        end
    else
        template = FXLoader:Shared("Assets/Models/Collectibles167"):FindFirstChild(extraData.TemplateName)
    end
    if not template or not template:IsA("Model") or not template.PrimaryPart then
        return nil
    end
    local model = Collectible.CreateModel(template)
    local tool = Instance.new("Tool")
    local nameKey = CollectibleText.GetNameKey(template.Name)
    tool.Name = English:FormatByKey(nameKey)
    local priceText = GameUtility.NumberToText(extraData.Price)
    if extraData.IsLucky == true then
        tool.ToolTip = English:FormatByKey("Loot.LuckyTooltip", {item = tool.Name,
            price = priceText, rate = GameUtility.NumberToText(extraData.LuckRate or 1)})
    else
        tool.ToolTip = English:FormatByKey("Loot.Tooltip", {item = tool.Name, price = priceText})
    end
    tool:SetAttribute("DisplayNameKey", nameKey)
    tool.CanBeDropped = false
    tool:SetAttribute("Price", extraData.Price)
    tool:SetAttribute("CollectibleTemplate", template.Name)
    tool:SetAttribute("ItemId", extraData.ItemId)
    tool:SetAttribute("DisplayModelId", extraData.DisplayModelId)
    tool:SetAttribute("IsLucky", extraData.IsLucky == true)
    tool:SetAttribute("LuckRate", extraData.IsLucky == true and (extraData.LuckRate or 1) or 1)
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
