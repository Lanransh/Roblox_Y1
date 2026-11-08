-- 关卡与血量读取 LevelConfig，成长曲线读取 NumericalConfig；100 原单位 = 4 studs。
local NumericalConfig = _G.NumericalConfig
local FX = _G.FX
local FXLoader = FX.Loader
local CurveSampler = FX.CurveSampler
local GameEnum = _G.GameEnum
local RockLevel = {
    CellSize = 8, -- 每块石头占原来的 2×2 格。
    LoadDistance = 64,
    HideDistance = 72,
    -- 当前统一使用金色光效；列表至少保留一项，可调整 RGB。
    HitEffectColors = {
        Color3.fromRGB(255, 205, 35), -- 金。
    },
    MaxLevel = NumericalConfig.levelCurves.input.max,
    Worlds = {},
    Stages = {},
    WalkTraining = NumericalConfig.trainingSettlementsPerSecond,
    ClickInterval = 0.2,
    LootCapacity = 3, -- 尚未回基地存放的战利品基础携带上限。
    StoredLootCapacity = 12, -- 已存收藏品与随身战利品共用的 KV 存储容量。
    HP = {},
}
-- 配置使用全局关卡编号；场景中的 Level_N 则按各世界从 1 开始编号。
for key, config in pairs(_G.GameConfig.LevelConfig) do
    local world, index = string.match(key, "^World(%d+)%.Level_(%d+)$")
    world, index = tonumber(world), tonumber(index)
    RockLevel.HP[index] = config.StoneHP
    RockLevel.Stages[index] = {World = world}
end
for index, stage in ipairs(RockLevel.Stages) do
    local world = RockLevel.Worlds[stage.World]
    if not world then
        world = {Name = "World" .. stage.World, Stages = {}}
        RockLevel.Worlds[stage.World] = world
    end
    table.insert(world.Stages, index)
    stage.LocalIndex = #world.Stages
end
local thresholds = {0}

--- 缓存达到指定等级的累计经验，供重生封顶与追赶结算共用。
--- @param level number 目标等级。
--- @return number 达到目标等级需要的累计经验。
function RockLevel.GetTrainingValueByLevel(level)
    level = math.clamp(level, 1, RockLevel.MaxLevel)
    for index = #thresholds, level - 1 do
        thresholds[index + 1] = thresholds[index] + RockLevel.GetNextExperience(index)
    end
    return thresholds[level]
end

--- 沿用原曲线的区间插值和四舍五入，区间外使用端点。
--- @param level number 当前训练等级。
--- @return number 升到下一级需要的训练值。
function RockLevel.GetNextExperience(level)
    return CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "nextLevelExperience", level)
end

--- 按整数等级读取基础攻击力，并按本级训练进度插值；满级不采样越界的下一级。
--- @param level number 当前训练等级。
--- @param value number 当前阶段累计训练值。
--- @return number 与面板显示一致的基础攻击力。
function RockLevel.GetAttackPower(level, value)
    local attack = CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "attackPower", level)
    if level >= RockLevel.MaxLevel then
        return attack
    end
    local threshold = RockLevel.GetTrainingValueByLevel(level)
    local progress = (value - threshold) / RockLevel.GetNextExperience(level)
    local nextAttack = CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "attackPower", level + 1)
    return attack + (nextAttack - attack) * progress
end

--- 累计训练值决定等级和进度，独立攻击力曲线决定显示力量。
--- @param value number 服务端持久化的累计训练值。
--- @param maxLevel number? 当前重生阶段允许达到的等级。
--- @return number 训练等级。
--- @return number 基础攻击力，同级训练平滑增长，重生恢复为 1 级曲线值。
--- @return number 当前等级内的训练进度。
--- @return number 当前等级升级需求。
function RockLevel.GetProgress(value, maxLevel)
    local level = 1
    while level < (maxLevel or RockLevel.MaxLevel) do
        if thresholds[level + 1] == nil then
            thresholds[level + 1] = thresholds[level] + RockLevel.GetNextExperience(level)
        end
        if value < thresholds[level + 1] then
            break
        end
        level += 1
    end
    return level, RockLevel.GetAttackPower(level, value),
        value - thresholds[level], RockLevel.GetNextExperience(level)
end

--- 落后推荐等级 15 级以内全额伤害，15–30 级线性降低，30 级及以上保留 1%。
--- @param level number 玩家训练等级。
--- @param index number 配置中的全局关卡序号。
--- @param trainingValue number 当前阶段累计训练值，用于派生基础攻击力。
--- @return number 单次击打伤害。
function RockLevel.GetDamage(level, index, trainingValue)
    local strength = RockLevel.GetAttackPower(level, trainingValue)
    local recommendedLevel = CurveSampler:SampleCurveGroupColumn(NumericalConfig.stageCurves, "grassLevel", index)
    local levelGap = recommendedLevel - level
    local points = GameEnum.RockLevelDamagePoints
    if levelGap <= points[1].LevelGap then
        return strength
    end
    for pointIndex = 2, #points do
        local point = points[pointIndex]
        if levelGap <= point.LevelGap then
            local previous = points[pointIndex - 1]
            local alpha = (levelGap - previous.LevelGap) / (point.LevelGap - previous.LevelGap)
            return strength * (previous.DamageMultiplier + (point.DamageMultiplier - previous.DamageMultiplier) * alpha)
        end
    end
    return strength * points[#points].DamageMultiplier
end

--- 本关幸运倍率：相对全局第一关期望道具价格向上取整，用于关卡头顶展示。
--- @param world number 从 1 开始的世界序号。
--- @param index number 本世界从 1 开始的关卡序号。
--- @return number 相对第一关的幸运倍率。
function RockLevel.GetLuck(world, index)
    local stage = RockLevel.Worlds[world].Stages[index]
    local price = CurveSampler:SampleCurveGroupColumnFormula(
        NumericalConfig.stageCurves, "expectedItemPrice", stage)
    local firstPrice = CurveSampler:SampleCurveGroupColumnFormula(
        NumericalConfig.stageCurves, "expectedItemPrice", 1)
    return math.ceil(price / firstPrice)
end

--- 关卡标记位于 Persistent 模型内，不受距离流出影响；等待初始复制完成后读取边界。
--- @return table 按关卡顺序排列的区域。
function RockLevel.GetAreas()
    local areas = {}
    for index, stage in ipairs(RockLevel.Stages) do
        local worldName = RockLevel.Worlds[stage.World].Name
        local node = FXLoader:Workspace("GameLevelList/" .. worldName .. "/Level_" .. stage.LocalIndex)
        areas[index] = {
            Node = node,
            Index = index,
            World = stage.World,
            LocalIndex = stage.LocalIndex,
            Columns = math.floor(node.Size.X / RockLevel.CellSize),
            Rows = math.floor(node.Size.Z / RockLevel.CellSize),
            MinX = node.Position.X - node.Size.X / 2,
            MinZ = node.Position.Z - node.Size.Z / 2,
            FloorY = node.Position.Y - node.Size.Y / 2,
        }
    end
    return areas
end

--- 客户端显示回家入口与服务端传送校验共用关卡边界，不把基地或关卡外算作关卡。
--- @param areas table 已加载的关卡边界。
--- @param position Vector3 当前角色根节点位置。
--- @param padding number? 向区域外扩展的判定容差，默认 0。
--- @return boolean 是否位于任一关卡区域。
--- @return table? 所在关卡区域，关卡外为空。
function RockLevel.IsInArea(areas, position, padding)
    padding = padding or 0
    for index, area in ipairs(areas) do
        if position.X >= area.MinX - padding
            and position.X < area.MinX + area.Columns * RockLevel.CellSize + padding
            and position.Z >= area.MinZ - padding
            and position.Z < area.MinZ + area.Rows * RockLevel.CellSize + padding
            and math.abs(position.Y - area.FloorY) < 12 + padding then
            return true, area
        end
    end
    return false
end

--- 锁定目标必须仍在脚下或周围八格，且角色到格子边界的水平距离不超过半格。
--- @param area table 关卡边界。
--- @param position Vector3 角色根节点位置。
--- @param cell number 从一开始的目标格号，调用方已校验关卡及格号范围。
--- @param tolerance number? 服务端位置复制容差，客户端选目标及落锤时不提供。
--- @return boolean 目标是否仍在近身攻击范围，不受朝向及最近目标变化影响。
function RockLevel.CanHitCell(area, position, cell, tolerance)
    local size = RockLevel.CellSize
    local column, row = (cell - 1) % area.Columns, math.floor((cell - 1) / area.Columns)
    local x, z = (position.X - area.MinX) / size, (position.Z - area.MinZ) / size
    if math.abs(column - math.floor(x)) > 1 or math.abs(row - math.floor(z)) > 1 then
        return false
    end
    local dx = math.max(math.abs(x - column - 0.5) - 0.5, 0)
    local dz = math.max(math.abs(z - row - 0.5) - 0.5, 0)
    local reach = 0.5 + (tolerance or 0) / size
    return dx * dx + dz * dz <= reach * reach
end

--- 脚下格优先，其余八格按中心距离从近到远排列；只返回近身候选，调用方跳过已碎石头。
--- @param area table 关卡边界。
--- @param position Vector3 角色根节点位置。
--- @return table 脚下格及附近八格中可攻击的格号数组。
function RockLevel.GetNearbyCells(area, position)
    local size = RockLevel.CellSize
    local x, z = (position.X - area.MinX) / size, (position.Z - area.MinZ) / size
    local column, row = math.floor(x), math.floor(z)
    local candidates = {}
    for candidateRow = math.max(0, row - 1), math.min(area.Rows - 1, row + 1) do
        for candidateColumn = math.max(0, column - 1), math.min(area.Columns - 1, column + 1) do
            local cell = candidateRow * area.Columns + candidateColumn + 1
            if RockLevel.CanHitCell(area, position, cell) then
                table.insert(candidates, {
                    Cell = cell,
                    Current = candidateColumn == column and candidateRow == row,
                    Distance = (x - candidateColumn - 0.5) ^ 2 + (z - candidateRow - 0.5) ^ 2,
                })
            end
        end
    end
    table.sort(candidates, function(left, right)
        if left.Current ~= right.Current then
            return left.Current
        end
        if left.Distance ~= right.Distance then
            return left.Distance < right.Distance
        end
        return left.Cell < right.Cell
    end)
    local cells = {}
    for index, candidate in ipairs(candidates) do
        cells[index] = area.Index .. ":" .. candidate.Cell
    end
    return cells
end

return RockLevel
