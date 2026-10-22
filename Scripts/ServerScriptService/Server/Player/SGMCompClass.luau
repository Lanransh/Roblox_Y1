local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("GM", {
    InvalidItemInput = "Enter a valid item ID and a positive whole-number quantity.",
    InvalidItem = "Unknown item ID.",
    ItemFull = "Not enough inventory space.",
    ItemAdded = "Item added.",
    InvalidValue = "Enter a valid whole number within the allowed range.",
    LevelLimit = "The current level limit is {level:int}.",
    Success = "Operation completed.",
    Forbidden = "Only developers can use these controls.",
    Unknown = "Something went wrong. Please try again.",
    Busy = "An operation is in progress. Please try again shortly.",
    SaveFailed = "Save failed. Please try again.",
})
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
        return {success = false, key = TranslationTexts.InvalidItemInput}
    end
    if not _G.ItemConfig.Data[itemId] then
        return {success = false, key = TranslationTexts.InvalidItem}
    end
    local reward = self:GetPlayerObject():RequireComponent("FSRewardComp")
    if not reward:AddRewards({{Type = "Item", ItemId = itemId, Count = count}}) then
        return {success = false, key = TranslationTexts.ItemFull}
    end
    return {success = true, key = TranslationTexts.ItemAdded}
end

--- 恢复配置默认值和默认武器拥有权，撤销旧掉落及命中凭据，完成后重新开启新手引导。
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
    player:RequireComponent("SWeaponComp"):OnPlayerLogin()
    player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    player:RequireComponent("FSInventoryComp"):OnAllChanged()
    player:RequireComponent("SLootSellComp"):RefreshEntries()
    player:RequireComponent("SAuraComp"):RefreshEffects()
    player:PublishEvent("Tutorial.Login")
end

--- 修改持久源字段，再沿用现有训练组件刷新等级、力量和排行榜显示。
--- @param action string 已确认的 GM 数值动作。
--- @param value any 客户端提交值。
--- @return table 权威校验与操作结果。
function Component:SetValue(action, value)
    local player = self:GetPlayerObject()
    if not IsValidNumber(value) then
        return {success = false, key = TranslationTexts.InvalidValue}
    end
    if action == "SetLevel" then
        local maxLevel = math.min(RockLevel.MaxLevel, Rebirth.GetRequiredLevel(player:GetNumber(Fields.RebirthCount)))
        if value % 1 ~= 0 or value < 1 or value > RockLevel.MaxLevel then
            return {success = false, key = TranslationTexts.InvalidValue}
        end
        if value > maxLevel then
            return {success = false, key = TranslationTexts.LevelLimit, arguments = {level = maxLevel}}
        end
        player:SetNumber(Fields.RockTrainingValue, RockLevel.GetTrainingValueByLevel(value))
        player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    elseif action == "SetRebirth" then
        if value % 1 ~= 0 or value > Rebirth.MaxCount then
            return {success = false, key = TranslationTexts.InvalidValue}
        end
        player:SetNumber(Fields.RebirthCount, value)
        player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    elseif action == "SetMoney" then
        player:SetNumber(Fields.Money, value)
    elseif action == "SetDiamonds" then
        player:SetNumber(Fields.Diamonds, value)
    else
        return {success = false, key = TranslationTexts.InvalidValue}
    end
    return {success = true, key = TranslationTexts.Success}
end

--- 按本人最新重生次数计算本阶段等级门槛，把训练等级提升到该门槛；不执行重生，已达标时保持不变。
--- @return table 权威校验与操作结果。
function Component:ReachRebirthLevel()
    local player = self:GetPlayerObject()
    local targetValue = RockLevel.GetTrainingValueByLevel(
        Rebirth.GetRequiredLevel(player:GetNumber(Fields.RebirthCount)))
    if player:GetNumber(Fields.RockTrainingValue) >= targetValue then
        return {success = true, key = TranslationTexts.Success}
    end
    player:SetNumber(Fields.RockTrainingValue, targetValue)
    player:RequireComponent("SMiscComp"):ResetTrainingProgress()
    return {success = true, key = TranslationTexts.Success}
end

--- 为当前开发者登记全部图鉴 ID；不写入背包或发放任何道具。
--- @return boolean 图鉴配置完整且已提交图鉴字段时为 true。
function Component:UnlockAllCollections()
    local itemData = _G.GameConfig.ItemData
    local entries = self:GetTable(Fields.CollectionEntries)
    local itemCount = 0
    for itemId, item in pairs(itemData) do
        if type(itemId) ~= "number" or type(item) ~= "table"
            or not IsValidNumber(item.Id) or item.Id < 1 or itemData[item.Id] ~= item then
            return false
        end
        entries[tostring(item.Id)] = true
        itemCount += 1
    end
    if itemCount == 0 then
        return false
    end
    self:SetTable(Fields.CollectionEntries, entries)
    return true
end

--- 权限按协议转发得到的所属玩家检查，客户端不能指定目标玩家或任意字段。
--- @param action string 允许的面板动作。
--- @param value any 数值动作的目标值或添加道具的配置 ID，重置和保存不使用。
--- @param count any 添加道具数量，其他动作不使用。
--- @return table 操作结果及客户端提示标识。
function Component:Request(action, value, count)
    local userId = self:GetPlayerId()
    if not FX.IsDeveloper(userId) then
        return {success = false, key = TranslationTexts.Forbidden}
    end
    local player = self:GetPlayerObject()
    local db = FS.PlayerKVDataManager._playerDBMap[userId]
    local misc = player and player:GetComponent("SMiscComp")
    local aura = player and player:GetComponent("SAuraComp")
    if not player or not db or not db:IsLoadFinished() or db._leaving
        or not misc or not misc._levelStat or not aura or not aura._ready then
        return {success = false, key = TranslationTexts.Unknown}
    end
    local now = os.clock()
    if self._busy or db._saving or now < self._nextRequest then
        return {success = false, key = TranslationTexts.Busy}
    end
    self._nextRequest = now + 0.2
    if action == "AddItem" then
        return self:AddItem(value, count)
    end
    if action == "ReachRebirthLevel" then
        return self:ReachRebirthLevel()
    end
    if action ~= "ResetData" and action ~= "SaveNow" and action ~= "UnlockAllCollections" then
        return self:SetValue(action, value)
    end
    if now < self._nextSave then
        return {success = false, key = TranslationTexts.Busy}
    end
    self._busy = true
    self._nextSave = now + 5
    -- 保存是实际异步边界；异常也释放 GM 锁，避免后续请求永久卡住。
    --- 重置或图鉴解锁在不让出执行的阶段完成，再保存整份权威 KV 快照。
    local previousEntries
    --- @return boolean 数据库是否成功保存此次快照。
    local ok, saved = pcall(function()
        if action == "ResetData" then
            self:ResetData()
        elseif action == "UnlockAllCollections" then
            previousEntries = player:GetTable(Fields.CollectionEntries)
            assert(self:UnlockAllCollections(), "Incomplete item config")
        end
        return db:Save(false)
    end)
    self._busy = false
    if not ok then
        warn("[GM] Save/reset/unlock failed", userId, saved)
    end
    if (not ok or not saved) and previousEntries then
        player:SetTable(Fields.CollectionEntries, previousEntries)
    end
    if not ok or not saved then
        return {success = false, key = TranslationTexts.SaveFailed}
    end
    return {success = true, key = TranslationTexts.Success}
end

return Component
