-- 处理器名与 ItemConfig.Data[itemId].UseHandler 对应，仅由服务端加载。
local Rebirth = _G.FX.Loader:RequireShared("Scripts/Game/Shared/Rebirth")
local ItemHandlers = {}

local TrainingCardHandler = {}
local BackpackBoostCardHandler = {}
local WeekCardHandler = {}

--- 先确认活动组件与即时奖励可用，框架随后才消耗一张周卡。
---@param context FXItemContextClass 服务端道具使用上下文。
---@return boolean 是否允许使用周卡。
function WeekCardHandler:CanUse(context)
    local activity = context.playerObject:GetComponent("SActivityComp")
    return activity ~= nil and activity:CanActivateWeekCard(context.itemDataConfig.Id)
end

--- 使用服务端道具 ID 激活，不允许客户端指定即时奖励或后续次数。
---@param context FXItemContextClass 已通过背包归属校验的上下文。
---@return boolean 是否完成周卡激活。
function WeekCardHandler:Use(context)
    return context.playerObject:RequireComponent("SActivityComp"):ActivateWeekCard(context.itemDataConfig.Id)
end

ItemHandlers.WeekCard = WeekCardHandler

--- 力量卡使用前确认玩家仍有可增加的训练值，避免先扣道具再发现已满级。
---@param context FXItemContextClass 当前服务端道具使用上下文。
---@return boolean 是否可以使用力量卡。
function TrainingCardHandler:CanUse(context)
    local player = context.playerObject
    local fields = _G.PlayerDataConfig
    if not player:GetComponent("SMiscComp") then
        return false
    end
    local count = player:GetNumber(fields.RebirthCount)
    return player:GetNumber(fields.RockTrainingValue) < Rebirth.GetMaxTrainingValue(count)
end

--- 按最高已解锁训练场的速率一次性结算卡片时长，并沿用现有永久倍率。
---@param context FXItemContextClass 当前服务端道具使用上下文。
---@return boolean 是否完成训练值结算。
function TrainingCardHandler:Use(context)
    local player = context.playerObject
    local config = context.itemDataConfig
    local misc = player:GetComponent("SMiscComp")
    if not misc then
        return false
    end
    return misc:ApplyTrainingCard(config.KVTable.Time)
end

ItemHandlers.TrainingCard = TrainingCardHandler

--- 检查玩家有可用的关卡随身容量卡效果存档。
---@param context FXItemContextClass 当前服务端道具使用上下文。
---@return boolean 是否可以使用背包扩容卡。
function BackpackBoostCardHandler:CanUse(context)
    return context.playerObject:GetComponent("SRockLevelComp") ~= nil
end

--- 增加 1 格关卡随身容量，并在重复使用时从当前到期时间继续延长。
---@param context FXItemContextClass 当前服务端道具使用上下文。
---@return boolean 是否完成扩容卡效果结算。
function BackpackBoostCardHandler:Use(context)
    local rockLevel = context.playerObject:GetComponent("SRockLevelComp")
    local config = context.itemDataConfig
    if not rockLevel or not config.KVTable or type(config.KVTable.Time) ~= "number" then
        return false
    end
    return rockLevel:ApplyLootCapacityBoost(config.KVTable.Count or 1, config.KVTable.Time)
end

ItemHandlers.ExpandableBackpackCard = BackpackBoostCardHandler

return ItemHandlers
