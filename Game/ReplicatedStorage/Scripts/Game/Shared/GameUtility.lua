-- 迁入 MiniStudio 的通用查询、数值和概率工具；源项目训练场/哑铃业务依赖未迁入。
local Provider = _G.Provider
local GoodsConfig = _G.GoodsConfig
local GameUtility = {}

--- 道具数据和显示属性在 Roblox 项目中由同一份 ItemConfig.Data 提供。
--- @param itemId number 道具配置 ID。
--- @return table 道具定义，未配置时返回 nil。
function GameUtility.GetItemDataConfig(itemId)
    return Provider:GetItemDataConfig(itemId)
end

--- 读取原生 Tool 使用的名称、形状和颜色配置。
--- @param itemId number 道具配置 ID。
--- @return table 道具显示定义，未配置时返回 nil。
function GameUtility.GetItemDisplayConfig(itemId)
    return Provider:GetItemDataConfig(itemId)
end

--- 读取道具类型对应的额外属性定义。
--- @param itemType string 道具类型。
--- @return table 附加属性定义，未配置时返回 nil。
function GameUtility.GetItemExtraDataSchema(itemType)
    return Provider:GetItemExtraDataSchema(itemType)
end

--- 以 Roblox Developer Product ID 查询商品。
--- @param goodsId number 开发者商品 ID。
--- @return table 商品定义，未配置时返回 nil。
function GameUtility.GetGoodsConfig(goodsId)
    return Provider:GetGoodsConfig(goodsId)
end

--- 按购买处理器和可选业务条件查找商品。
--- @param buyHandler string 购买处理器名。
--- @param condFunc function 可选的商品筛选条件。
--- @return table 首个符合条件的商品，未找到时返回 nil。
function GameUtility.FindGoodsConfig(buyHandler, condFunc)
    for productId, goodsConfig in pairs(GoodsConfig.GoodsData) do
        if goodsConfig.BuyHandler == buyHandler and (not condFunc or condFunc(goodsConfig)) then
            return goodsConfig
        end
    end
    return nil
end

local units = {
    { 1e36, "涧" }, { 1e32, "沟" }, { 1e28, "穰" }, { 1e24, "秭" }, { 1e20, "垓" },
    { 1e16, "京" }, { 1e12, "兆" }, { 1e8, "亿" }, { 1e4, "万" },
}

--- 按 MiniStudio 的中文数量单位显示数值，大单位保留两位小数。
--- @param number number 待显示数值，nil 按零处理。
--- @return string 数值文本。
function GameUtility.NumberToText(number)
    number = number or 0
    local absNumber = math.abs(number)
    if absNumber < 1e4 then
        return tostring(math.floor(number))
    end
    for index, entry in ipairs(units) do
        local value, unit = entry[1], entry[2]
        if absNumber >= value then
            return string.format("%.2f%s", number / value, unit)
        end
    end
    return tostring(number)
end

--- 沿用源项目显示规则：换算后不足 100 保留小数，否则向下取整。
--- @param number number 待显示数值，nil 按零处理。
--- @return string 数值文本。
function GameUtility.NumberToTextFloor(number)
    number = number or 0
    local absNumber = math.abs(number)
    if absNumber < 1e4 then
        return tostring(math.floor(number))
    end
    for index, entry in ipairs(units) do
        local value, unit = entry[1], entry[2]
        if absNumber >= value then
            local unitValue = number / value
            unitValue = unitValue < 100 and unitValue or math.floor(unitValue)
            return string.format("%.2f%s", unitValue, unit)
        end
    end
    return tostring(math.floor(number))
end

--- 为数值文本的整数部分插入千分位分隔符。
--- @param number number 待显示数值，nil 按零处理。
--- @return string 带逗号的数值文本。
function GameUtility.NumberToCommaText(number)
    local result = tostring(number or 0)
    local count
    repeat
        result, count = result:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until count == 0
    return result
end

--- 按源项目的 BaseExp/Power 曲线类型计算数值。
--- @param x number 自变量。
--- @param curveData table 曲线配置，包含 Type 和可选的 B、M、P。
--- @return number 曲线结果。
function GameUtility.CalcCurveValue(x, curveData)
    local base = curveData.B or 0
    local multiplier = curveData.M or 1
    local power = curveData.P or 1
    if curveData.Type == "BaseExp" then
        return base + multiplier * power ^ x
    end
    if curveData.Type == "Power" then
        return base + multiplier * x ^ power
    end
    error("Invalid CurveData")
end

--- 按源项目舍入规则保留指定小数位。
--- @param value number 待舍入数值。
--- @param decimalPlaces number 小数位数，默认两位。
--- @return number 舍入后的数值。
function GameUtility.RoundToDecimalPlaces(value, decimalPlaces)
    local multiplier = 10 ^ (decimalPlaces or 2)
    return math.floor(value * multiplier + 0.5) / multiplier
end

--- 按源项目赔率倍率模型提高标记项的权重，不修改输入配置。
--- @param probabilityList table 包含 Weight 和倍率标记的概率数组。
--- @param betterItemMultiplier number 高档项相对低档项的目标赔率倍率。
--- @return table 调整权重后的概率数组副本。
function GameUtility.CalcNewProbabilityListByBetterItemMultiplier(probabilityList, betterItemMultiplier)
    --- 优先使用高档项标记，兼容源项目的幸运标记。
    --- @param probabilityData table 单项概率配置。
    --- @return boolean 是否受倍率影响。
    local function IsAffected(probabilityData)
        if probabilityData.IsAffectByBetterItemMultiplier ~= nil then
            return probabilityData.IsAffectByBetterItemMultiplier == true
        end
        return probabilityData.IsAffectByLucky == true
    end

    local affectedWeightSum, unaffectedWeightSum = 0, 0
    for index, probabilityData in ipairs(probabilityList) do
        if probabilityData.Weight > 0 then
            if IsAffected(probabilityData) then
                affectedWeightSum += probabilityData.Weight
            else
                unaffectedWeightSum += probabilityData.Weight
            end
        end
    end

    local affectedWeightScale = 1
    if betterItemMultiplier > 1 and affectedWeightSum > 0 and unaffectedWeightSum > 0 then
        local probability = affectedWeightSum / (affectedWeightSum + unaffectedWeightSum)
        local targetProbability = betterItemMultiplier * probability / (1 - probability + betterItemMultiplier * probability)
        local targetWeightSum = unaffectedWeightSum * targetProbability / (1 - targetProbability)
        affectedWeightScale = targetWeightSum / affectedWeightSum
    end

    local result = {}
    for index, probabilityData in ipairs(probabilityList) do
        local entry = table.clone(probabilityData)
        if probabilityData.Weight > 0 and IsAffected(probabilityData) then
            entry.Weight = math.max(1, math.floor(probabilityData.Weight * affectedWeightScale + 0.5))
        end
        result[index] = entry
    end
    return result
end

--- 将配置颜色转换为 Roblox Color3，缺省或非法值沿用源项目的白色回退。
--- @param hexColor string 可选的 #RRGGBB 颜色字符串。
--- @return Color3 可用于原生节点的颜色。
function GameUtility.HexColorToColor3(hexColor)
    local red, green, blue = string.match(hexColor or "", "^#(%x%x)(%x%x)(%x%x)$")
    if not red then
        return Color3.fromRGB(255, 255, 255)
    end
    return Color3.fromRGB(tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16))
end

return GameUtility
