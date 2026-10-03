-- 从 Studio_Y3 的世界 1 关卡和 NumericalConfig.levelCurves 迁入；100 原单位 = 4 studs。
local NumericalConfig = _G.NumericalConfig
local CurveSampler = _G.FX.CurveSampler
local RockLevel = {
    CellSize = 8, -- 每块石头占原来的 2×2 格。
    LoadDistance = 64,
    HideDistance = 72,
    MaxLevel = NumericalConfig.levelCurves.input.max,
    HP = {29, 122, 520, 2176, 9101, 38000, 159000, 664000, 2770000, 11600000, 48400000, 202000000, 844000000},
}
local thresholds = {0}

--- 沿用原曲线的区间插值和四舍五入，区间外使用端点。
--- @param level number 当前训练等级。
--- @return number 升到下一级需要的训练值。
function RockLevel.GetNextExperience(level)
    return CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "nextLevelExperience", level)
end

--- 累计配置中的升级门槛，力量使用同一份 levelCurves 采样。
--- @param value number 服务端持久化的累计训练值。
--- @return number 训练等级。
--- @return number 对应力量。
function RockLevel.GetProgress(value)
    local level = 1
    while level < RockLevel.MaxLevel do
        if thresholds[level + 1] == nil then
            thresholds[level + 1] = thresholds[level] + RockLevel.GetNextExperience(level)
        end
        if value < thresholds[level + 1] then
            break
        end
        level += 1
    end
    return level, CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "strength", level)
end

--- 从 stageCurves 读取推荐等级，保留等级差减伤规则。
--- @param level number 玩家训练等级。
--- @param index number 世界 1 的关卡序号。
--- @return number 单次击打伤害。
function RockLevel.GetDamage(level, index)
    local strength = CurveSampler:SampleCurveGroupColumnFormula(NumericalConfig.levelCurves, "strength", level)
    local recommendedLevel = CurveSampler:SampleCurveGroupColumn(NumericalConfig.stageCurves, "grassLevel", index)
    return strength * math.max(0, 1 - math.max(0, recommendedLevel - level) * 0.07)
end

--- 关卡标记位于 Persistent 模型内，不受距离流出影响；等待初始复制完成后读取边界。
--- @return table 按关卡顺序排列的区域。
function RockLevel.GetAreas()
    local world = workspace:WaitForChild("GameLevelList"):WaitForChild("World1")
    local areas = {}
    for index = 1, #RockLevel.HP do
        local node = world:WaitForChild("Level_" .. index)
        areas[index] = {
            Node = node,
            Index = index,
            Columns = math.floor(node.Size.X / RockLevel.CellSize),
            Rows = math.floor(node.Size.Z / RockLevel.CellSize),
            MinX = node.Position.X - node.Size.X / 2,
            MinZ = node.Position.Z - node.Size.Z / 2,
            FloorY = node.Position.Y - node.Size.Y / 2,
        }
    end
    return areas
end

--- 对齐 Roblox 的 +Z 行方向；直向覆盖脚下和前方五格，斜向覆盖九格。
--- @param area table 关卡边界。
--- @param position Vector3 服务端角色位置。
--- @param look Vector3 角色朝向。
--- @return table 区域内有效格子的唯一编号。
function RockLevel.GetFrontCells(area, position, look)
    local column = math.floor((position.X - area.MinX) / RockLevel.CellSize)
    local row = math.floor((position.Z - area.MinZ) / RockLevel.CellSize)
    local threshold = math.sin(math.rad(22.5))
    local dx = math.abs(look.X) > threshold and math.sign(look.X) or 0
    local dz = math.abs(look.Z) > threshold and math.sign(look.Z) or 0
    local offsets = {{0, 0}}
    if dx ~= 0 and dz ~= 0 then
        for x = 0, 2 do
            for z = 0, 2 do
                if x ~= 0 or z ~= 0 then
                    table.insert(offsets, {dx * x, dz * z})
                end
            end
        end
    elseif dx ~= 0 or dz ~= 0 then
        for depth = 1, 2 do
            for width = 0, 1 do
                table.insert(offsets, {dx * depth - dz * width, dz * depth + dx * width})
            end
        end
    end
    local cells = {}
    for index = 1, #offsets do
        local x, z = column + offsets[index][1], row + offsets[index][2]
        if x >= 0 and x < area.Columns and z >= 0 and z < area.Rows then
            table.insert(cells, tostring(area.Index) .. ":" .. tostring(z * area.Columns + x + 1))
        end
    end
    return cells
end

return RockLevel
