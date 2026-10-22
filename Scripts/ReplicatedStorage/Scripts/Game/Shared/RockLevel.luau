-- 关卡与血量读取 LevelConfig，成长曲线读取 NumericalConfig；100 原单位 = 4 studs。
local NumericalConfig = _G.NumericalConfig
local FX = _G.FX
local FXLoader = FX.Loader
local CurveSampler = FX.CurveSampler
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

--- 累计配置中的升级门槛；力量直接使用当前阶段累计训练值，不再按等级采样曲线。
--- @param value number 服务端持久化的累计训练值。
--- @param maxLevel number? 当前重生阶段允许达到的等级。
--- @return number 训练等级。
--- @return number 已累计的力量，与训练值同步增长并在重生时归零。
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
    return level, value,
        value - thresholds[level], RockLevel.GetNextExperience(level)
end

--- 沿用 Studio_Y3 等级差减伤：低于推荐等级每级减伤 7%，差 15 级起伤害为零；升级后重算，无计时惩罚。
--- @param level number 玩家训练等级。
--- @param index number 配置中的全局关卡序号。
--- @param strength number 当前阶段累计训练值，与显示力量一致。
--- @return number 单次击打伤害。
function RockLevel.GetDamage(level, index, strength)
    local recommendedLevel = CurveSampler:SampleCurveGroupColumn(NumericalConfig.stageCurves, "grassLevel", index)
    return strength * math.max(0, 1 - math.max(0, recommendedLevel - level) * 0.07)
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

--- 只检测角色水平朝向前方 3 studs 的格子，空格不继续向远处搜索。
--- @param area table 关卡边界。
--- @param position Vector3 服务端角色位置。
--- @param look Vector3 角色朝向。
--- @return table 最多包含一个近身格子编号，越界或无水平朝向时为空。
function RockLevel.GetFrontCells(area, position, look)
    local forward = Vector3.new(look.X, 0, look.Z)
    if forward.Magnitude < 0.01 then
        return {}
    end
    local target = position + forward.Unit * 3
    local column = math.floor((target.X - area.MinX) / RockLevel.CellSize)
    local row = math.floor((target.Z - area.MinZ) / RockLevel.CellSize)
    if column < 0 or column >= area.Columns or row < 0 or row >= area.Rows then
        return {}
    end
    return {tostring(area.Index) .. ":" .. tostring(row * area.Columns + column + 1)}
end

return RockLevel
