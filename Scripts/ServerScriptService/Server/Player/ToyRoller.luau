-- 服务端玩具奖池：按 CommonConfig 分配世界道具、关卡候选和价格区间，幸运另行加价。
local FX = _G.FX
local NumericalConfig = _G.NumericalConfig
local CommonConfig = _G.GameConfig.CommonConfig
local ToyRoller = {}

--- 按关卡进度移动配置的候选范围；每种对应独立价格区间，刷新件数由玩家组件配置控制。
--- @param world number 从 1 开始的世界序号，每个世界使用全新的一批道具。
--- @param level number 本世界从 1 开始的关卡序号。
--- @return table 等概率候选道具及基础价格倍率区间，单件价格由玩家组件独立抽取。
--- @return number 本关普通道具期望价格。
--- @return number 相对本世界第一关的区域幸运，仅供展示，不重复乘价格。
function ToyRoller.CreatePool(world, level)
    local firstStage = (world - 1) * NumericalConfig.worldStageCount + 1
    local stage = firstStage + level - 1
    local itemCount = NumericalConfig.worldStageCount * CommonConfig.ToyItemsPerStage
    local count = math.min(CommonConfig.ToyCandidateCount, itemCount)
    local priceRateMin, priceRateMax = CommonConfig.ToyPriceRateRange[1], CommonConfig.ToyPriceRateRange[2]
    assert(priceRateMin > 0 and priceRateMin <= priceRateMax
        and math.abs(priceRateMin + priceRateMax - 2) < 0.000001,
        "Toy price rate bounds must be positive, ordered, and average to 1")
    local priceRateStep = (priceRateMax - priceRateMin) / count
    local progress = 0
    if NumericalConfig.worldStageCount > 1 then
        progress = (level - 1) / (NumericalConfig.worldStageCount - 1)
    end
    local firstId = (world - 1) * itemCount + 1 + math.floor(progress * (itemCount - count) + 0.5)
    local averagePrice = FX.CurveSampler:SampleCurveGroupColumnFormula(
        NumericalConfig.stageCurves, "expectedItemPrice", stage)
    local firstAveragePrice = FX.CurveSampler:SampleCurveGroupColumnFormula(
        NumericalConfig.stageCurves, "expectedItemPrice", firstStage)
    assert(averagePrice > 0 and averagePrice < math.huge, "Expected item price must be finite and positive")
    assert(firstAveragePrice > 0 and firstAveragePrice < math.huge, "First expected item price must be finite and positive")

    local pool = {}
    -- 等分配置区间，候选等概率且各区间均匀抽价时，整体基础倍率期望为 1。
    for index = 1, count do
        pool[index] = {
            ItemId = firstId + index - 1,
            PriceRateMin = priceRateMin + (index - 1) * priceRateStep,
            PriceRateMax = priceRateMin + index * priceRateStep,
        }
    end
    return pool, averagePrice, averagePrice / firstAveragePrice
end

return ToyRoller
