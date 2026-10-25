-- 项目奖励只准备独立数据副本，由 FSRewardComp 整批校验后统一提交；处理器不得 yield。
local FX = _G.FX
local Fields = _G.PlayerDataConfig
local Weapon = FX.Loader:RequireShared("Scripts/Game/Shared/Weapon")
local Aura = FX.Loader:RequireShared("Scripts/Game/Shared/Aura")
local Collection = FX.Loader:RequireShared("Scripts/Game/Shared/Collection")
local RockLevel = FX.Loader:RequireShared("Scripts/Game/Shared/RockLevel")
local Handlers = {}

--- 离散奖励数量与 ID 必须为正安全整数。
--- @param value any 待检查数值。
--- @return boolean 是否有效。
local function Integer(value)
    return type(value) == "number" and value > 0 and value <= 9007199254740991 and value % 1 == 0
end

--- 同一批次复用计划副本，避免多项同字段奖励互相覆盖。
--- @param reward table 奖励组件。
--- @param tables table 当前批次的表字段计划。
--- @param name string 受支持的玩家字段名称。
--- @return table 待提交的数据副本。
local function Data(reward, tables, name)
    if not tables[name] then
        tables[name] = reward:GetTable(Fields[name])
    end
    return tables[name]
end

--- 永久武器或光环解锁；自动装备仍由购买业务选择。
--- @param reward table 奖励组件。
--- @param entry table Kind=Weapon/Aura、Id、Count=1。
--- @param tables table 本批次计划。
--- @return boolean 是否可完整解锁。
function Handlers.Unlock(reward, entry, tables)
    if entry.Count ~= 1 or not Integer(entry.Id) then
        return false
    end
    local name, config
    if entry.Kind == "Weapon" then
        name, config = "WeaponData", Weapon.GetConfig(entry.Id)
    elseif entry.Kind == "Aura" then
        name, config = "AuraData", Aura.GetConfig(entry.Id)
    else
        return false
    end
    if not config then
        return false
    end
    local data = Data(reward, tables, name)
    local id = tostring(entry.Id)
    if data.owned[id] then
        return false
    end
    data.owned[id] = true
    return true
end

--- 商店升级仅增加当前已支持的训练档位或永久容量。
--- @param reward table 奖励组件。
--- @param entry table Kind=TrainingRate/Capacity 和整数 Count。
--- @param tables table 本批次计划。
--- @return boolean 是否可准备升级。
function Handlers.ShopUpgrade(reward, entry, tables)
    if not Integer(entry.Count) then
        return false
    end
    local key = entry.Kind == "TrainingRate" and "trainingLevel" or entry.Kind == "Capacity" and "capacity"
    if not key then
        return false
    end
    local data = Data(reward, tables, "CurrencyShopData")
    local value = data[key] + entry.Count
    if not Integer(value) then
        return false
    end
    data[key] = value
    return true
end

--- 容量卡续期保留原格数取最大值的规则，不重复叠加格数。
--- @param reward table 奖励组件。
--- @param entry table 整数 Count 与正有限 Duration 秒。
--- @param tables table 本批次计划。
--- @return boolean 是否可准备扩容效果。
function Handlers.LootCapacityBoost(reward, entry, tables)
    if not Integer(entry.Count) or type(entry.Duration) ~= "number"
        or not (entry.Duration > 0 and entry.Duration < math.huge) then
        return false
    end
    local now = workspace:GetServerTimeNow()
    local boost = Data(reward, tables, "RockLootCapacityBoost")
    local active = boost.expiresAt > now
    local expiresAt = (active and boost.expiresAt or now) + entry.Duration
    if not (expiresAt < math.huge) then
        return false
    end
    tables.RockLootCapacityBoost = {
        count = math.max(active and boost.count or 0, entry.Count), expiresAt = expiresAt,
    }
    return true
end

--- 仅允许拾取已开放收藏品，使用独立类型并整批累计检查随身及总存储容量。
--- @param reward table 奖励组件。
--- @param entry table Count=1 与服务端签发的 Data 收藏品记录。
--- @param tables table 本批次计划。
--- @return boolean 是否可完整拾取。
function Handlers.Loot(reward, entry, tables)
    local value = entry.Data
    if entry.Count ~= 1 or type(value) ~= "table" or not Integer(value.ItemId)
        or not Collection.GetConfig(value.ItemId) or type(value.Price) ~= "number"
        or not (value.Price >= 0 and value.Price < math.huge) then
        return false
    end
    local loot = Data(reward, tables, "RockLoot")
    if #loot >= reward:RequireComponent("SRockLevelComp"):GetLootCapacity()
        or #loot + #reward:GetTable(Fields.StoredLoot) >= RockLevel.StoredLootCapacity then
        return false
    end
    table.insert(loot, FX.Table:DeepCopy(value))
    return true
end

return Handlers
