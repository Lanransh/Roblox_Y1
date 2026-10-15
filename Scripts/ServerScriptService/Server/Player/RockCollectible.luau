local Collectible = {}

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

--- 在原掉落尺寸上统一放大 25%，客户端背景光芒按模型尺寸同步放大，再焊接为单个装配。
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
    model:ScaleTo(model:GetScale() * 1.25)
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

return Collectible
