-- 处理器名与 ItemConfig.Data[itemId].UseHandler 对应，仅由服务端加载。
local ItemHandlers = {}

local TrainingCardHandler = {}
local BackpackBoostCardHandler = {}
local WeekCardHandler = {}
local NoobCardHandler = {}

--- 每次只消耗一张菜鸟卡，活动组件未就绪时不扣卡。
---@param context FXItemContextClass 服务端道具使用上下文。
---@return boolean 是否可以使用菜鸟卡。
function NoobCardHandler:CanUse(context)
    context.consumeCount = 1
    return context.playerObject:GetComponent("SActivityComp") ~= nil
end

--- 复用菜鸟任务计数入口，每次使用只增加一次 GetNoob 进度。
---@param context FXItemContextClass 已通过背包归属校验的上下文。
---@return boolean 是否完成任务进度结算。
function NoobCardHandler:Use(context)
    context.playerObject:RequireComponent("SActivityComp"):RecordNoobPickup()
    return true
end

ItemHandlers.NoobCard = NoobCardHandler

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

--- 力量卡使用前按不含好友加成的收益检查；封顶时保留卡片并提醒重生。
---@param context FXItemContextClass 当前服务端道具使用上下文。
---@return boolean 是否可以使用力量卡。
function TrainingCardHandler:CanUse(context)
    local player = context.playerObject
    if not player:GetComponent("SMiscComp") then
        return false
    end
    local gain = player:RequireComponent("SMiscComp"):GetTrainingCardGain(context.itemDataConfig.KVTable.Time)
    if gain <= 0 then
        player:RequireComponent("SMiscComp"):ShowRebirthReminder()
        return false
    end
    return player:RequireComponent("FSRewardComp"):CanAddRewards({
        {Type = "Money", Currency = "RockTrainingValue", Count = gain},
    })
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
    local config = context.itemDataConfig.KVTable
    return context.playerObject:GetComponent("SRockLevelComp") ~= nil
        and context.playerObject:RequireComponent("FSRewardComp"):CanAddRewards({
            {Type = "LootCapacityBoost", Count = config.Count or 1, Duration = config.Time},
        })
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
