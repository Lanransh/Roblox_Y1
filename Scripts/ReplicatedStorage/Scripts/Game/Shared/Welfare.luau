-- 活动配置沿用现有业务 ID 和数值，展示与发奖在边界转换旧字段。
local Welfare = {}

Welfare.Sources = {
    ["Welfare.Tasks"] = "Daily Tasks",
    ["Welfare.TaskRule"] = "Progress and rewards reset daily at 00:00 UTC.",
    ["Welfare.InProgress"] = "In Progress",
    ["Welfare.Task.GetItem"] = "Collect {target:int} items",
    ["Welfare.Task.GetDog"] = "Pick up {target:int} dogs",
    ["Welfare.Task.OnlineTime"] = "Play for {target:int} minutes",
    ["Welfare.Task.ForFriendPlay"] = "Play with {target:int} friends in the same server",
    ["Welfare.Title"] = "REWARDS",
    ["Welfare.Online"] = "Online Rewards",
    ["Welfare.SignIn"] = "7-Day Login",
    ["Welfare.Daily"] = "Daily Diamonds",
    ["Welfare.OnlineTime"] = "Online: {minutes:int} min · Resets daily",
    ["Welfare.LoginDay"] = "Total login days: {day:int}",
    ["Welfare.Minute"] = "{minutes:int} min",
    ["Welfare.Day"] = "Day {day:int}",
    ["Welfare.WeeklyReward"] = "Weekly Reward",
    ["Welfare.ItemReward"] = "{item} ×{value}",
    ["Welfare.Claim"] = "Claim",
    ["Welfare.Claimed"] = "Claimed",
    ["Welfare.Locked"] = "Locked",
    ["Welfare.Pending"] = "Claiming...",
    ["Welfare.Retry"] = "Retry",
    ["Welfare.NotReady"] = "This reward is not available yet.",
    ["Welfare.AlreadyClaimed"] = "You have already claimed this reward.",
    ["Welfare.InventoryFull"] = "Not enough inventory space. Your reward is still available.",
    ["Welfare.Success"] = "Reward claimed!",
    ["Welfare.DailySubtitle"] = "Daily login reward and active weekly passes",
    ["Welfare.Available"] = "Available today",
    ["Welfare.Ready"] = "Ready to claim",
    ["Welfare.Tomorrow"] = "Today's rewards claimed · Come back tomorrow",
    ["Welfare.LoginBonus"] = "Daily Login",
    ["Welfare.DailyAmount"] = "+{value} Diamonds per day",
    ["Welfare.PassRemaining"] = "{days:int} claims left · {status}",
    ["Welfare.PassInactive"] = "Use this pass from your backpack to activate it.",
    ["Welfare.PassTomorrow"] = "Next claim tomorrow",
    ["Welfare.PassActivated"] = "Weekly pass activated! +{value} Diamonds",
    ["Welfare.OnlineRule"] = "Online time adds up throughout the day. Each reward can be claimed once per day.",
    ["Welfare.SignInRule"] = "Log in on 7 different days. Missing a day does not reset your progress.",
    ["Welfare.DailyRule"] = "New passes start their daily rewards tomorrow. Unclaimed pass rewards do not expire.",
}

-- 英文物品源文案复用配置，不维护另一套物品名称。
for id, display in pairs(_G.ItemConfig.Display) do
    Welfare.Sources["Welfare.Item." .. id] = display.Name
end

--- 按稳定字符串 ID 查找配置，不把客户端传入的奖励数量用于结算。
--- @param kind string online、signin 或 task。
--- @param rewardId string 配置 Index 的字符串形式。
--- @return table? 匹配的档位配置。
function Welfare.GetReward(kind, rewardId)
    local list = kind == "online" and _G.ActivityConfig.OnlineRewardData
        or kind == "signin" and _G.ActivityConfig.LoginMilestoneData
        or kind == "task" and _G.ActivityConfig.DailyTaskConfig
    if not list then
        return nil
    end
    for index, config in ipairs(list) do
        if tostring(config.Index) == rewardId then
            return config
        end
    end
    return nil
end

--- 将活动奖励转换为展示契约，配置内的 ID 和数量保持不变。
--- @param reward table ActivityConfig 中的单项奖励。
--- @return table 展示用 type、id 和 amount。
function Welfare.ToDisplayReward(reward)
    return {type = reward.Type, id = tostring(reward.Id or "Diamonds"), amount = reward.Count}
end

return Welfare
