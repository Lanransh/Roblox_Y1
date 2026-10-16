local GameConfig = _G.GameConfig
local Aura = {}

--- 按数值 ID 查配置，不接受客户端提供的价格、倍率或模型路径。
--- @param auraId number 客户端请求或存档中的光环 ID。
--- @return table? 对应光环配置，未知 ID 返回 nil。
function Aura.GetConfig(auraId)
    if type(auraId) ~= "number" then
        return nil
    end
    for index, config in ipairs(GameConfig.AuraConfig) do
        if config.AuraId == auraId then
            return config
        end
    end
    return nil
end

--- 未装备、配置已移除或没有解锁记录时不提供训练加成。
--- @param data table 持久光环数据，解锁字典使用字符串 ID。
--- @return number 当前单件光环的训练倍率，未装备为 1。
function Aura.GetTrainingRate(data)
    local config = Aura.GetConfig(data.equippedId)
    if not config or data.owned[tostring(config.AuraId)] ~= true then
        return 1
    end
    return config.TrainingRate
end

return Aura
