local FX, FS = _G.FX, _G.FS
local Config = require(game.ReplicatedStorage.Shared.Config.FrameworkConfig)
local Reward = FX.Class("FSRewardCompClass", "FSPlayerCompClass")
FS.RewardCompClass = Reward
local MAX_INTEGER = 9007199254740991

local function Integer(value)
    return type(value) == "number" and value >= 0 and value <= MAX_INTEGER and value % 1 == 0
end

function Reward:GetCompName()
    return "FSRewardComp"
end

-- 服务端入口。先汇总整批货币并检查整个背包容量，再执行；没有客户端领奖协议。
-- Type = Item / Money；保留 Y3 的 ItemId/Count 和 itemId/count 写法。
function Reward:_Prepare(rewards, consume)
    if type(rewards) ~= "table" then
        return nil
    end
    local items, money, length = {}, {}, 0
    local inventory = self:GetComponent("FSInventoryComp")
    for key in pairs(rewards) do
        if not Integer(key) or key < 1 then
            return nil
        end
        length += 1
    end
    for index = 1, length do
        local entry = rewards[index]
        if type(entry) ~= "table" then
            return nil
        end
        local count = entry.Count or entry.count
        if not Integer(count) or count == 0 then
            return nil
        end
        if entry.Type == "Item" then
            local id = entry.ItemId or entry.itemId
            local extra = entry.ExtraData or entry.extraData
            local item = Config.Items[id]
            if not inventory or not item or not Integer(item.MaxStack) or item.MaxStack < 1 then
                return nil
            end
            -- 扣除按 ItemId 汇总，不支持按词条选择；防止调用方误扣其他词条物品。
            if extra ~= nil and (consume or type(extra) ~= "table") then
                return nil
            end
            if extra then
                local schema = Config.ItemSchemas[item.Type]
                if not schema then
                    return nil
                end
                for key in pairs(extra) do
                    if schema[key] == nil then
                        return nil
                    end
                end
            end
            local maxStack = extra and 1 or item.MaxStack
            if count / maxStack > inventory:GetTotalCapacity() then
                return nil
            end
            while count > 0 do
                local stack = math.min(count, maxStack)
                table.insert(items, FS.ItemClass.New(id, stack, extra and FX.Table:DeepCopy(extra)))
                count -= stack
            end
        elseif entry.Type == "Money" then
            local fieldName = Config.RewardCurrencies[entry.Currency or "Money"]
            local field = fieldName and Config.PlayerData[fieldName]
            if not field or field.Type ~= "number" then
                return nil
            end
            money[field] = (money[field] or 0) + count
            if not Integer(money[field]) then
                return nil
            end
        else
            return nil
        end
    end
    local balances = {}
    for field, count in pairs(money) do
        local current = self:GetNumber(field)
        if not Integer(current) then
            return nil
        end
        local value = current + (consume and -count or count)
        if not Integer(value) then
            return nil
        end
        balances[field] = value
    end
    if #items > 0 then
        local check = consume and inventory.CanRemoveItems or inventory.CanAddItems
        if not check(inventory, items) then
            return nil
        end
    end
    return { items = items, balances = balances, inventory = inventory }
end

function Reward:CanAddRewards(rewards)
    return self:_Prepare(rewards, false) ~= nil
end

function Reward:CanConsumeRewards(rewards)
    return self:_Prepare(rewards, true) ~= nil
end

function Reward:_Apply(rewards, consume)
    local plan = self:_Prepare(rewards, consume)
    if not plan then
        return false
    end
    if #plan.items > 0 then
        local apply = consume and plan.inventory.RemoveItems or plan.inventory.AddItems
        if not apply(plan.inventory, plan.items) then
            return false
        end
    end
    for field, value in pairs(plan.balances) do
        self:SetNumber(field, value)
    end
    return true
end

function Reward:AddRewards(rewards)
    return self:_Apply(rewards, false)
end

function Reward:ConsumeRewards(rewards)
    return self:_Apply(rewards, true)
end

return Reward
