local FX = _G.FX
local TweenService = game:GetService("TweenService")
local Reminder = {}
Reminder.__index = Reminder

--- 在对应小屋上方创建醒目的大号立体感叹号，抬高位置保持屋顶间距，不参与碰撞或交互。
--- @param hut Model 已确认的商店小屋。
--- @return table 由商店组件持有并释放的提醒对象。
function Reminder.New(hut)
    local self = setmetatable({}, Reminder)
    self._container = FX.Loader:Workspace("Decorations")
    self._model = Instance.new("Model")
    self._model.Name = hut.Name .. "ShopReminder"
    self._visible = false
    self._parts = {}
    local bounds, size = hut:GetBoundingBox()
    local center = bounds:PointToWorldSpace(Vector3.new(0, size.Y * 0.5, 0))
        + Vector3.new(0, 5, 0)
    local shapes = {
        {name = "Stem", size = Vector3.new(1.8, 5.2, 1.8), offset = 1.4, shape = Enum.PartType.Block},
        {name = "Dot", size = Vector3.new(1.8, 1.8, 1.8), offset = -2.8, shape = Enum.PartType.Ball},
    }
    for index, shape in ipairs(shapes) do
        local part = Instance.new("Part")
        part.Name = shape.name
        part.Shape = shape.shape
        part.Size = shape.size
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 40, 40)
        local position = center + Vector3.new(0, shape.offset, 0)
        part.Position = position
        part.Parent = self._model
        local tween = TweenService:Create(part,
            TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Position = position + Vector3.new(0, 2, 0)})
        table.insert(self._parts, {part = part, position = position, tween = tween})
    end
    return self
end

--- 有买得起的未解锁商品或更强的已拥有商品未装备时提醒，窗口关闭也持续更新。
--- @param items table 商店完整配置，包含 id、price 和 strength。
--- @param state table 服务端派生的 owned、equippedId 与 coins 状态。
function Reminder:Refresh(items, state)
    local canBuy = false
    local equippedStrength = 0
    local bestOwnedStrength = 0
    for index, item in ipairs(items) do
        if item.id == state.equippedId then
            equippedStrength = item.strength
        end
        if state.owned[item.id] == true then
            bestOwnedStrength = math.max(bestOwnedStrength, item.strength)
        elseif state.coins >= item.price then
            canBuy = true
        end
    end
    local visible = canBuy or bestOwnedStrength > equippedStrength
    if visible == self._visible then
        return
    end
    self._visible = visible
    for index, entry in ipairs(self._parts) do
        entry.tween:Cancel()
        entry.part.Position = entry.position
        if visible then
            entry.tween:Play()
        end
    end
    self._model.Parent = visible and self._container or nil
end

--- 取消无限往返动画并释放本对象创建的模型，不修改小屋或其他玩家状态。
function Reminder:Destroy()
    for index, entry in ipairs(self._parts) do
        entry.tween:Cancel()
        entry.tween:Destroy()
    end
    self._model:Destroy()
end

return Reminder
