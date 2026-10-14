local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Component = FX.Class("SGMCompClass", "FSPlayerCompClass")

--- GM 请求状态随所属玩家会话创建，不使用独立服务保存玩家状态。
--- @param owner SPlayerObjectClass 当前玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._nextRequest = 0
    self._nextSave = 0
    self._busy = false
end

--- 提供玩家管理器协议转发使用的组件名。
--- @return string 玩家内 GM 组件名。
function Component:GetCompName()
    return "SGMComp"
end

--- 面板契约中的数值必须为非负安全整数。
--- @param value any 客户端提交的数值。
--- @return boolean 是否可以写入数值字段。
local function IsValidNumber(value)
    return type(value) == "number" and value == value and value >= 0
        and value <= 9007199254740991 and value % 1 == 0
end

--- 沿用正式奖励入口整批添加，容量不足时不发放部分道具。
--- @param itemId any 客户端提交的道具配置 ID。
--- @param count any 客户端提交的添加数量。
--- @return table 权威校验与发放结果。
function Component:AddItem(itemId, count)
    if not IsValidNumber(itemId) or itemId < 1 or not IsValidNumber(count) or count < 1 then
        return {success = false, key = "GM.InvalidItemInput"}
    end
    if not _G.ItemConfig.Data[itemId] then
        return {success = false, key = "GM.InvalidItem"}
    end
    local reward = self:GetPlayerObject():RequireComponent("FSRewardComp")
    if not reward:AddRewards({{Type = "Item", ItemId = itemId, Count = count}}) then
        return {success = false, key = "GM.ItemFull"}
    end
    return {success = true, key = "GM.ItemAdded"}
end

--- 恢复配置默认值，并撤销尚未领取的掉落及上一轮命中凭据。
function Component:ResetData()
    local player = self:GetPlayerObject()
    player:RequireComponent("SRockLevelComp"):RestoreRocks()
    for fieldName, field in pairs(Fields) do
        if field.Type == "number" then
            player:SetNumber(field, field.DefVal)
        elseif field.Type == "boolean" then
            player:SetFlag(field, field.DefVal)
        elseif field.Type == "table" then
            player:SetTable(field, nil)
        end
    end
    player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    player:RequireComponent("FSInventoryComp"):OnAllChanged()
    player:RequireComponent("SLootSellComp"):RefreshEntries()
    player:RequireComponent("SAuraComp"):RefreshEffects()
end

--- 修改持久源字段，再沿用现有训练组件刷新等级、力量和排行榜显示。
--- @param action string 已确认的 GM 数值动作。
--- @param value any 客户端提交值。
--- @return table 权威校验与操作结果。
function Component:SetValue(action, value)
    local player = self:GetPlayerObject()
    if not IsValidNumber(value) then
        return {success = false, key = "GM.InvalidValue"}
    end
    if action == "SetLevel" then
        local maxLevel = math.min(RockLevel.MaxLevel, Rebirth.GetRequiredLevel(player:GetNumber(Fields.RebirthCount)))
        if value % 1 ~= 0 or value < 1 or value > RockLevel.MaxLevel then
            return {success = false, key = "GM.InvalidValue"}
        end
        if value > maxLevel then
            return {success = false, key = "GM.LevelLimit", arguments = {level = maxLevel}}
        end
        player:SetNumber(Fields.RockTrainingValue, RockLevel.GetTrainingValueByLevel(value))
        player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    elseif action == "SetRebirth" then
        if value % 1 ~= 0 or value > Rebirth.MaxCount then
            return {success = false, key = "GM.InvalidValue"}
        end
        player:SetNumber(Fields.RebirthCount, value)
        player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    elseif action == "SetMoney" then
        player:SetNumber(Fields.Money, value)
    elseif action == "SetDiamonds" then
        player:SetNumber(Fields.Diamonds, value)
    else
        return {success = false, key = "GM.InvalidValue"}
    end
    return {success = true, key = "GM.Success"}
end

--- 权限按协议转发得到的所属玩家检查，客户端不能指定目标玩家或任意字段。
--- @param action string 七种允许的面板动作。
--- @param value any 数值动作的目标值或添加道具的配置 ID，重置和保存不使用。
--- @param count any 添加道具数量，其他动作不使用。
--- @return table 操作结果及客户端提示标识。
function Component:Request(action, value, count)
    local userId = self:GetPlayerId()
    if not FX.IsDeveloper(userId) then
        return {success = false, key = "GM.Forbidden"}
    end
    local player = self:GetPlayerObject()
    local db = FS.PlayerKVDataManager._playerDBMap[userId]
    local misc = player and player:GetComponent("SMiscComp")
    local aura = player and player:GetComponent("SAuraComp")
    if not player or not db or not db:IsLoadFinished() or db._leaving
        or not misc or not misc._levelStat or not aura or not aura._ready then
        return {success = false, key = "Common.Unknown"}
    end
    local now = os.clock()
    if self._busy or db._saving or now < self._nextRequest then
        return {success = false, key = "GM.Busy"}
    end
    self._nextRequest = now + 0.2
    if action == "AddItem" then
        return self:AddItem(value, count)
    end
    if action ~= "ResetData" and action ~= "SaveNow" then
        return self:SetValue(action, value)
    end
    if now < self._nextSave then
        return {success = false, key = "GM.Busy"}
    end
    self._busy = true
    self._nextSave = now + 5
    -- 保存是实际异步边界；异常也释放 GM 锁，避免后续请求永久卡住。
    --- 重置在不让出执行的阶段完成，再保存整份权威 KV 快照。
    --- @return boolean 数据库是否成功保存此次快照。
    local ok, saved = pcall(function()
        if action == "ResetData" then
            self:ResetData()
        end
        return db:Save(false)
    end)
    self._busy = false
    if not ok then
        warn("[GM] Save/reset failed", userId, saved)
    end
    if not ok or not saved then
        return {success = false, key = "GM.SaveFailed"}
    end
    return {success = true, key = "GM.Success"}
end

return Component
