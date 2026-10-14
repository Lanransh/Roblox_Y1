local FX = _G.FX
local Fields = _G.PlayerDataConfig
local Welfare = FX.Loader:RequireShared("Scripts/Game/Shared/Welfare")
local Rebirth = FX.Loader:RequireShared("Scripts/Game/Shared/Rebirth")
local Component = FX.Class("SActivityCompClass", "FSPlayerCompClass")
local Players = game:GetService("Players")

--- 返回玩家内协作名，供道具使用与福利协议定位。
--- @return string 活动组件名。
function Component:GetCompName()
    return "SActivityComp"
end

--- 读档后记录登录日及离线批次；当天领取记录与尚未领取的批次重登保留。
function Component:OnPlayerLogin()
    self._lastTime = os.time()
    self._nextSync = self._lastTime + 10
    local data = self:GetTable(Fields.WelfareData)
    local day = math.floor(self._lastTime / 86400)
    if data.day ~= day or data.offline.training <= 0 then
        local config = _G.GameConfig.CommonConfig.OfflineReward
        local seconds = data.lastSeenAt > 0 and math.clamp(self._lastTime - data.lastSeenAt, 0, config.Time) or 0
        data.offline = {
            id = tostring(self._lastTime), seconds = seconds,
            training = self:RequireComponent("SMiscComp"):GetTrainingCardGain(seconds * config.Rate),
        }
    end
    -- 旧福利存档没有任务字段，仅补入本次新增结构。
    data.taskProgress = data.taskProgress or {}
    data.taskClaimed = data.taskClaimed or {}
    data.taskFriends = data.taskFriends or {}
    if data.lastLoginDay ~= day then
        data.lastLoginDay = day
        data.loginDays = math.min(data.loginDays + 1, #_G.ActivityConfig.LoginMilestoneData)
    end
    -- 离线批次在登录时生成；UpdateTime 跨日时不会清掉刚生成的新批次。
    self._loggingIn = true
    self:SetTable(Fields.WelfareData, data)
    self:UpdateTime(self._lastTime)
    self._loggingIn = nil
    self:PublishState()
end

--- 使用服务端实际经过时间累计；跨 UTC 日仅计入今日部分并清空在线领取记录。
--- @param now number 服务端 Unix 时间戳，单位秒。
function Component:UpdateTime(now)
    local data = self:GetTable(Fields.WelfareData)
    local day = math.floor(now / 86400)
    local startTime = self._lastTime or now
    if data.day ~= day then
        data.day = day
        data.onlineSeconds = 0
        data.onlineClaimed = {}
        data.taskProgress = {}
        data.taskClaimed = {}
        data.taskFriends = {}
        if not self._loggingIn then
            data.offline = {id = "", seconds = 0, training = 0}
        end
        startTime = math.max(startTime, day * 86400)
    end
    data.onlineSeconds += math.max(0, now - startTime)
    data.lastSeenAt = now
    self._lastTime = now
    self:SetTable(Fields.WelfareData, data)
end

--- 统一计算基础登录与尚未领取的周卡钻石，不接受客户端金额。
--- @return number 今日尚可领取的钻石。
function Component:GetDailyAmount()
    local data = self:GetTable(Fields.WelfareData)
    local amount = data.lastClaimDay ~= data.day and _G.GameConfig.CommonConfig.LoginData.GemCount or 0
    for id, card in pairs(data.cards) do
        if card.remaining > 0 and card.lastClaimDay ~= data.day then
            amount += card.dailyAmount
        end
    end
    return amount
end

--- 私有存档只同步福利所需快照，日期和每日金额均来自服务端。
function Component:PublishState()
    local data = self:GetTable(Fields.WelfareData)
    self._revision = (self._revision or 0) + 1
    self:SetTable(Fields.WelfareState, {
        ready = true, revision = self._revision, day = data.day, onlineSeconds = data.onlineSeconds, loginDays = data.loginDays,
        onlineClaimed = FX.Table:DeepCopy(data.onlineClaimed),
        signInClaimed = FX.Table:DeepCopy(data.signInClaimed),
        taskProgress = FX.Table:DeepCopy(data.taskProgress),
        taskClaimed = FX.Table:DeepCopy(data.taskClaimed),
        dailyAmount = self:GetDailyAmount(), cards = FX.Table:DeepCopy(data.cards),
        offline = {
            id = data.offline.id,
            seconds = data.offlineClaimDay == data.day and 0 or data.offline.seconds,
            training = data.offlineClaimDay == data.day and 0 or data.offline.training,
            status = data.offlineClaimDay == data.day and "Claimed"
                or (data.offline.training > 0 and "Claimable" or "Locked"),
        },
    })
end

--- 每秒累计但每十秒同步一次；跨日立即刷新领取资格。
--- @param serverTime number 框架提供的服务器时间戳。
function Component:OnUpdate(serverTime)
    if not self._lastTime then
        return
    end
    local now = serverTime
    local oldDay = self:GetTable(Fields.WelfareData).day
    self:UpdateTime(now)
    if oldDay ~= math.floor(now / 86400) or now >= self._nextSync then
        self._nextSync = now + 10
        self:PublishState()
        self:CheckFriends()
    end
end

--- 保存前结清当前会话在线时长，重进当天继续累计。
function Component:OnPlayerLogout()
    if self._friendTask then
        task.cancel(self._friendTask)
        self._friendTask = nil
    end
    if self._lastTime then
        self:UpdateTime(os.time())
        self._lastTime = nil
    end
end

--- 成功拾取后累计当天件数，不将发奖或 GM 添加道具计入任务。
function Component:RecordPickup()
    self:UpdateTime(os.time())
    local data = self:GetTable(Fields.WelfareData)
    data.taskProgress.GetItem = (data.taskProgress.GetItem or 0) + 1
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
end

--- 小狗拾取单独累计 GetDog，不计入普通道具 GetItem；跨日重置后再记录。
function Component:RecordDogPickup()
    self:UpdateTime(os.time())
    local data = self:GetTable(Fields.WelfareData)
    data.taskProgress.GetDog = (data.taskProgress.GetDog or 0) + 1
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
end

--- 平台好友查询允许 yield；按本次同服快照累计不同好友，每位好友每天只计一次。
function Component:CheckFriends()
    if self._friendTask then
        return
    end
    local player = Players:GetPlayerByUserId(self:GetPlayerId())
    if not player then
        return
    end
    local day = self:GetTable(Fields.WelfareData).day
    local presentPlayers = Players:GetPlayers()
    self._friendTask = task.defer(function()
        local friends = {}
        for index, other in ipairs(presentPlayers) do
            if other ~= player then
                --- 查询失败时不增加任务进度，后续同步周期重试。
                --- @return boolean 平台确认的好友关系。
                local ok, isFriend = pcall(function()
                    return player:IsFriendsWithAsync(other.UserId)
                end)
                if ok and isFriend then
                    table.insert(friends, other)
                end
            end
        end
        self._friendTask = nil
        if not self._lastTime or player.Parent ~= Players then
            return
        end
        self:UpdateTime(os.time())
        local data = self:GetTable(Fields.WelfareData)
        if data.day ~= day then
            return
        end
        local count = 0
        for id in pairs(data.taskFriends) do
            count += 1
        end
        local changed = count ~= (data.taskProgress.ForFriendPlay or 0)
        for index, friend in ipairs(friends) do
            local id = tostring(friend.UserId)
            -- 同服事实来自查询前的快照；好友在平台响应前离开也应计入。
            if not data.taskFriends[id] then
                data.taskFriends[id] = true
                count += 1
                changed = true
            end
        end
        if changed then
            data.taskProgress.ForFriendPlay = count
            self:SetTable(Fields.WelfareData, data)
            self:PublishState()
        end
    end)
end

--- 在线任务以分钟为单位，其余任务读取服务端累计值。
--- @param config table 当日任务配置。
--- @return number 当前任务进度。
function Component:GetTaskProgress(config)
    local data = self:GetTable(Fields.WelfareData)
    return config.Type == "OnlineTime" and math.floor(data.onlineSeconds / 60)
        or (data.taskProgress[config.Type] or 0)
end

--- 销毁组件时取消平台查询，防止后台任务继续持有玩家对象。
function Component:Dtor()
    if self._friendTask then
        task.cancel(self._friendTask)
        self._friendTask = nil
    end
    Component.Super.Dtor(self)
end

--- 使用前由统一奖励接口验证即时钻石，避免先消耗卡片再拒绝发奖。
--- @param itemId number 服务端道具上下文提供的配置 ID。
--- @return boolean 当前是否允许激活。
function Component:CanActivateWeekCard(itemId)
    local config = _G.ItemConfig.Data[itemId]
    if not self._lastTime or not config or config.Type ~= "WeekCard" then
        return false
    end
    return self:RequireComponent("FSRewardComp"):CanAddRewards({
        {Type = "Money", Currency = "Diamonds", Count = config.KVTable.InstantGemCount},
    })
end

--- 即时发奖并增加后续领取次数；首次激活次日可领，续卡保留当天领取记录。
--- @param itemId number 服务端已校验并消耗的周卡道具 ID。
--- @return boolean 是否激活成功。
function Component:ActivateWeekCard(itemId)
    if not self:CanActivateWeekCard(itemId) then
        return false
    end
    self:UpdateTime(os.time())
    local config = _G.ItemConfig.Data[itemId].KVTable
    if not self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "Money", Currency = "Diamonds", Count = config.InstantGemCount},
    }) then
        return false
    end
    local data = self:GetTable(Fields.WelfareData)
    local key = tostring(itemId)
    local card = data.cards[key] or {remaining = 0, lastClaimDay = -1}
    if card.remaining <= 0 then
        card.lastClaimDay = data.day
    end
    card.dailyAmount = config.DurationDays
    card.remaining += config.DayTime
    data.cards[key] = card
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
    local player = self:GetPlayerObject()
    local notified, message = pcall(player.ShowLocalizedTips, player,
        "Welfare.PassActivated", {value = config.InstantGemCount})
    if not notified then
        warn("[WeekCard] activation notification failed", message)
    end
    return true
end

--- 统一转换活动配置并整批发放，任一项不满足时保留全部领取资格。
--- @param rewards table 服务端配置中的奖励列表。
--- @return boolean 是否发放成功。
function Component:GrantRewards(rewards)
    local batch = {}
    for index, reward in ipairs(rewards) do
        if reward.Type == "Gem" then
            table.insert(batch, {Type = "Money", Currency = "Diamonds", Count = reward.Count})
        else
            table.insert(batch, {Type = "Item", ItemId = reward.Id, Count = reward.Count})
        end
    end
    return self:RequireComponent("FSRewardComp"):AddRewards(batch)
end

--- RPC 只领取本人配置档位；全程不 yield，发奖失败保留领取资格。
--- @param kind any 客户端类别，仅接受 online、signin、task、diamonds、offline。
--- @param rewardId any 稳定字符串 ID，不接受客户端金额或玩家身份。
--- @param multiplier any 离线领取方式，仅接受数值 1 或 2；双倍暂时免费。
--- @return table 成功标记、提示 Key 和最新权威快照。
function Component:Claim(kind, rewardId, multiplier)
    if not self._lastTime or type(kind) ~= "string" or type(rewardId) ~= "string" or #rewardId > 32 then
        return {success = false, key = "Welfare.NotReady"}
    end
    self:UpdateTime(os.time())
    local data = self:GetTable(Fields.WelfareData)
    local key = "Welfare.NotReady"
    local success = false
    if kind == "offline" then
        if data.offlineClaimDay == data.day then
            key = "Welfare.AlreadyClaimed"
        elseif rewardId == data.offline.id and data.offline.training > 0 and (multiplier == 1 or multiplier == 2) then
            local config = _G.GameConfig.CommonConfig.OfflineReward
            local rate = multiplier == 2 and config.VIPRate or config.Rate
            local remaining = Rebirth.GetMaxTrainingValue(self:GetNumber(Fields.RebirthCount))
                - self:GetNumber(Fields.RockTrainingValue)
            local gain = math.max(0, math.min(data.offline.training * rate / config.Rate, remaining))
            if gain > 0 and self:RequireComponent("FSRewardComp"):AddRewards({
                {Type = "Money", Currency = "RockTrainingValue", Count = gain},
            }) then
                -- 发奖和批次消费不 yield，重复请求只能命中已领取状态。
                data.offlineClaimDay = data.day
                data.offline.seconds = 0
                data.offline.training = 0
                self:SetTable(Fields.WelfareData, data)
                self:RequireComponent("SMiscComp"):RefreshProgress()
                FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain, true)
                success = true
            end
        end
    elseif kind == "diamonds" and rewardId == "daily_diamonds" then
        local amount = self:GetDailyAmount()
        if amount > 0 and self:GrantRewards({{Type = "Gem", Count = amount}}) then
            data.lastClaimDay = data.day
            for id, card in pairs(data.cards) do
                if card.remaining > 0 and card.lastClaimDay ~= data.day then
                    card.remaining -= 1
                    card.lastClaimDay = data.day
                end
            end
            success = true
        elseif amount <= 0 then
            key = "Welfare.AlreadyClaimed"
        end
    else
        local config = Welfare.GetReward(kind, rewardId)
        if config then
            local claimed = kind == "online" and data.onlineClaimed
                or kind == "task" and data.taskClaimed or data.signInClaimed
            local eligible = kind == "online" and data.onlineSeconds >= config.TargetMinutes * 60
                or kind == "signin" and data.loginDays >= config.LoginDays
                or kind == "task" and self:GetTaskProgress(config) >= config.Target
            if claimed[rewardId] then
                key = "Welfare.AlreadyClaimed"
            elseif eligible then
                if kind == "task" then
                    success = self:GrantRewards(config.Rewards)
                else
                    success = self:GrantRewards({config.Reward})
                end
                if success then
                    claimed[rewardId] = true
                else
                    key = "Welfare.InventoryFull"
                end
            end
        end
    end
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
    return {success = success, key = success and "Welfare.Success" or key, state = self:GetTable(Fields.WelfareState)}
end

return Component
