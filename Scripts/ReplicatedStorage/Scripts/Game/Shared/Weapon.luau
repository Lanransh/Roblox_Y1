local GameConfig = _G.GameConfig
local Weapon = {}

--- 只按稳定 ID 查找配置，客户端不能指定价格、倍率或资源路径。
--- @param weaponId number 请求或存档中的 ToolId。
--- @return table? 对应配置，未知 ID 返回 nil。
function Weapon.GetConfig(weaponId)
    if type(weaponId) ~= "number" then
        return nil
    end
    for index, config in ipairs(GameConfig.ToolConfig) do
        if config.ToolId == weaponId then
            return config
        end
    end
    return nil
end

--- 无效旧装备回退默认木镐，未解锁装备不能贡献倍率。
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
