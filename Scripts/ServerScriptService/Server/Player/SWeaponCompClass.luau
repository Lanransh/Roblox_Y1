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
    if not data.owned["101"] then
        self:SetTable(Fields.WeaponData, data)
        assert(self:RequireComponent("FSRewardComp"):AddRewards({
            {Type = "Unlock", Kind = "Weapon", Id = 101, Count = 1},
        }), "Default weapon reward failed")
        data = self:GetTable(Fields.WeaponData)
    end
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
        local costs = config.Price > 0 and {{Type = "Money", Currency = "Money", Count = config.Price}} or {}
        if not self:RequireComponent("FSRewardComp"):ExchangeRewards(costs, {
            {Type = "Unlock", Kind = "Weapon", Id = weaponId, Count = 1},
        }) then
            return {success = false, key = "Weapon.NotEnoughCoins"}
        end
        local previousRate = Weapon.GetEquippedConfig(data).TrainingRate
        data = self:GetTable(Fields.WeaponData)
        if config.TrainingRate > previousRate then
            data.equippedId = weaponId
        end
    else
        if data.owned[id] ~= true then
            return {success = false, key = "Weapon.NotOwned"}
        end
        data.equippedId = weaponId
    end
    self:SetTable(Fields.WeaponData, data)
    if action == "Buy" then
        self:RequireComponent("SAnalyticsComp"):Sink("Money", config.Price,
            self:GetNumber(Fields.Money), "Weapon:" .. id)
    end
    return {success = true, data = data, coins = self:GetNumber(Fields.Money)}
end

--- 离服后拒绝继续处理购买和装备。
function Component:OnPlayerLogout()
    self._ready = false
end

return Component
