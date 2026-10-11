local FX = _G.FX
local Fields = _G.PlayerDataConfig
local Weapon = FX.Loader:RequireShared("Scripts/Game/Shared/Weapon")
local Component = FX.Class("SWeaponCompClass", "FSPlayerCompClass")

--- 武器解锁与装备由服务端统一管理。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SWeaponComp"
end

--- 保留旧解锁记录，保证默认木镐已拥有且当前装备合法。
function Component:OnPlayerLogin()
    local data = self:GetTable(Fields.WeaponData)
    if type(data.owned) ~= "table" then
        data.owned = {}
    end
    data.owned["101"] = true
    data.equippedId = Weapon.GetEquippedConfig(data).ToolId
    self:SetTable(Fields.WeaponData, data)
    self._ready = true
end

--- 权威结算不让出执行，购买更高训练倍率的武器时自动装备，重复购买不扣款。
--- @param action string 只允许 Buy 或 Equip。
--- @param weaponId number 客户端提供的稳定 ToolId。
--- @return table 失败 Key 或完整权威装备状态与余额。
function Component:RequestWeapon(action, weaponId)
    local config = Weapon.GetConfig(weaponId)
    if not self._ready or not config or (action ~= "Buy" and action ~= "Equip") then
        return {success = false, key = "Common.Unknown"}
    end
    local data = self:GetTable(Fields.WeaponData)
    local id = tostring(config.ToolId)
    if action == "Buy" then
        if data.owned[id] == true then
            return {success = false, key = "Weapon.AlreadyOwned"}
        end
        if self:GetNumber(Fields.Coins) < config.Price
            or (config.Price > 0 and not self:SubNumber(Fields.Coins, config.Price)) then
            return {success = false, key = "Weapon.NotEnoughCoins"}
        end
        data.owned[id] = true
        if config.TrainingRate > Weapon.GetEquippedConfig(data).TrainingRate then
            data.equippedId = weaponId
        end
    else
        if data.owned[id] ~= true then
            return {success = false, key = "Weapon.NotOwned"}
        end
        data.equippedId = weaponId
    end
    self:SetTable(Fields.WeaponData, data)
    return {success = true, data = data, coins = self:GetNumber(Fields.Coins)}
end

--- 离服后拒绝继续处理购买和装备。
function Component:OnPlayerLogout()
    self._ready = false
end

return Component
