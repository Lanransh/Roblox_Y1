local FX = _G.FX
local FXLoader = FX.Loader
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local Curves = _G.NumericalConfig.rebirthCurves
local Rebirth = {MaxCount = Curves.input.max}

--- 按当前重生次数选择跳过商品；没有配置的区间不开放购买。
--- @param count number 已完成的重生次数。
--- @return table? 区间包含当前次数的商品配置。
function Rebirth.GetSkipGoods(count)
    if count >= Rebirth.MaxCount then
        return nil
    end
    for goodsId, goods in pairs(_G.GoodsConfig.GoodsData) do
        if goods.BuyHandler == "SkipRebirth" then
            local range = goods.KVTable
            if count >= range.MinRebirth and count <= range.MaxRebirth then
                return goods
            end
        end
    end
    return nil
end

--- 两端共用原项目重生门槛，次数封顶后仍允许训练到最终等级。
--- @param count number 已完成的重生次数。
--- @return number 本阶段最高等级及下一次重生门槛。
function Rebirth.GetRequiredLevel(count)
    return math.max(1, math.floor(FX.CurveSampler:SampleCurveGroupColumnFormula(
        Curves, "requiredLevel", math.min(count, Rebirth.MaxCount))))
end

--- 读取原项目永久训练倍率，实际训练与界面预览共用。
--- @param count number 已完成的重生次数。
--- @return number 训练倍率。
function Rebirth.GetTrainingRate(count)
    return FX.CurveSampler:SampleCurveGroupColumnFormula(Curves, "trainingMultiplierReward", count)
end

--- 读取原项目金币倍率，供重生收益预览及金币结算使用。
--- @param count number 已完成的重生次数。
--- @return number 金币倍率。
function Rebirth.GetMoneyRate(count)
    return FX.CurveSampler:SampleCurveGroupColumnFormula(Curves, "goldMultiplierReward", count)
end

--- 累计经验最多填满阶段最高等级，最终等级不超出等级曲线。
--- @param count number 已完成的重生次数。
--- @return number 当前阶段经验上限。
function Rebirth.GetMaxTrainingValue(count)
    return RockLevel.GetTrainingValueByLevel(Rebirth.GetRequiredLevel(count) + 1)
end

--- 追赶额外经验只填至上一次重生门槛，再按本阶段经验上限截断。
--- @param value number 当前累计经验。
--- @param baseGain number 尚未包含重生加成的基础训练收益。
--- @param count number 已完成的重生次数。
--- @return number 实际可增加的经验。
function Rebirth.GetTrainingGain(value, baseGain, count)
    local gain = baseGain * Rebirth.GetTrainingRate(count)
    if count > 0 then
        local target = RockLevel.GetTrainingValueByLevel(Rebirth.GetRequiredLevel(count - 1))
        local catchUpRate = FX.CurveSampler:SampleCurveGroupColumnFormula(Curves, "catchUpMultiplier", count)
        gain += math.min(gain * (catchUpRate - 1), math.max(0, target - value - gain))
    end
    return math.max(0, math.min(gain, Rebirth.GetMaxTrainingValue(count) - value))
end

--- 力量卡、力量包及离线按可消耗训练份额分段追赶，达到目标后剩余份额恢复正常倍率。
--- @param value number 当前累计经验。
--- @param baseGain number 全部份额在尚未包含重生倍率时的收益。
--- @param count number 已完成的重生次数。
--- @return number 分段结算并限制在当前阶段剩余经验内的收益。
function Rebirth.GetAccumulatedTrainingGain(value, baseGain, count)
    local gain = baseGain * Rebirth.GetTrainingRate(count)
    if count > 0 then
        local target = RockLevel.GetTrainingValueByLevel(Rebirth.GetRequiredLevel(count - 1))
        local catchUpRate = FX.CurveSampler:SampleCurveGroupColumnFormula(Curves, "catchUpMultiplier", count)
        local catchUpBaseGain = math.min(gain, math.max(0, target - value) / catchUpRate)
        gain = catchUpBaseGain * catchUpRate + (gain - catchUpBaseGain)
    end
    return math.max(0, math.min(gain, Rebirth.GetMaxTrainingValue(count) - value))
end

return Rebirth
