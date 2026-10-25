local GameConfig = _G.GameConfig
local GameEnum = _G.GameEnum
local Weapon = {}

--- 仅按稳定 ID 返回已开放的武器配置，统一限制购买、奖励、装备和倍率。
--- @param weaponId number 请求或存档中的 ToolId。
--- @return table? 对应配置，未知或未开放 ID 返回 nil。
function Weapon.GetConfig(weaponId)
    if type(weaponId) ~= "number" then
        return nil
    end
    for index, config in ipairs(GameConfig.ToolConfig) do
        if index > GameEnum.WeaponLimit then
            break
        end
        if config.ToolId == weaponId then
            return config
        end
    end
    return nil
end

--- 无效或未开放的旧装备回退默认木镐，未解锁装备不能贡献倍率。
--- @param data table 武器解锁字典与装备 ID。
--- @return table 当前合法装备配置。
function Weapon.GetEquippedConfig(data)
    local config = Weapon.GetConfig(data.equippedId)
    if config and data.owned[tostring(config.ToolId)] == true then
        return config
    end
    return Weapon.GetConfig(101)
end

return Weapon
