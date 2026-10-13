local FX = _G.FX
local ShopReminder = FX.Loader:RequireFromParent(script, "ShopReminder")
local ShopAreas = {}
ShopAreas.__index = ShopAreas

--- 三个世界共用商店入口，远处小屋未流入时不阻塞 UI 初始化。
--- @param hutName string 同类商店的小屋名称。
--- @param withReminders boolean 是否显示购买与装备提醒。
--- @return table 由商店组件持有的区域集合。
function ShopAreas.New(hutName, withReminders)
    return setmetatable({
        _hutName = hutName, _withReminders = withReminders, _reminders = {},
    }, ShopAreas)
end

--- 只获取当前已加载的小屋；流出后释放提醒，流入后按最新存档重新创建。
--- @param position Vector3? 存活角色的位置，省略时只同步提醒。
--- @return boolean 角色是否位于任一同类商店触发盒内。
function ShopAreas:IsInside(position)
    local huts = {}
    local original = workspace:FindFirstChild(self._hutName)
    if original then
        table.insert(huts, original)
    end
    local decorations = workspace:FindFirstChild("Decorations")
    for worldId = 2, 3 do
        local group = decorations and decorations:FindFirstChild("World" .. worldId .. "Shops")
        local hut = group and group:FindFirstChild(self._hutName)
        if hut then
            table.insert(huts, hut)
        end
    end
    local loaded = {}
    local inside = false
    for index, hut in ipairs(huts) do
        loaded[hut] = true
        local trigger = hut:FindFirstChild("Trigger")
        if trigger and trigger:IsA("BasePart") then
            if self._withReminders and self._state and not self._reminders[hut] then
                local reminder = ShopReminder.New(hut)
                reminder:Refresh(self._items, self._state)
                self._reminders[hut] = reminder
            end
            if position then
                local point = trigger.CFrame:PointToObjectSpace(position)
                local half = trigger.Size * 0.5
                inside = inside or (math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y
                    and math.abs(point.Z) <= half.Z)
            end
        end
    end
    for hut, reminder in pairs(self._reminders) do
        if not loaded[hut] then
            reminder:Destroy()
            self._reminders[hut] = nil
        end
    end
    return inside
end

--- 同一份权威状态刷新所有已加载世界的小屋提醒。
--- @param items table 对应商店的完整配置。
--- @param state table 权威数据派生的拥有、装备和金币状态。
function ShopAreas:Refresh(items, state)
    self._items = items
    self._state = state
    self:IsInside(nil)
    for hut, reminder in pairs(self._reminders) do
        reminder:Refresh(items, state)
    end
end

--- 释放本组件创建的全部世界提醒，不修改场景小屋。
function ShopAreas:Destroy()
    for hut, reminder in pairs(self._reminders) do
        reminder:Destroy()
    end
    table.clear(self._reminders)
end

return ShopAreas
