local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Text = FX.Text
local TranslationTexts = Text.Define("Activity", {
    PassActivated = "Gained {value} Diamonds and activated a {days:int}-day weekly pass!",
    NotReady = "This reward is not available yet.",
    AlreadyClaimed = "You have already claimed this reward.",
    InventoryFull = "Not enough inventory space. Your reward is still available.",
    Success = "Reward claimed!",
    NeedDiamonds = "Not enough diamonds.",
    NoBoostGain = "The boosted reward would not add any extra Strength. Claim the normal reward instead.",
    JoinGroup = "Join the group to claim this reward!",
    GroupCheckFailed = "Unable to check group membership. Please try again.",
})
local GameUtility = FX.Loader:RequireShared("Scripts/Game/Shared/GameUtility")
local Fields = _G.PlayerDataConfig
local Welfare = FX.Loader:RequireShared("Scripts/Game/Shared/Welfare")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Component = FX.Class("SActivityCompClass", "FSPlayerCompClass")
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local RewardGroupId = 771149851 -- Oddlet Studio

--- 平台查询前后均校验到三个世界任一宝箱的距离，拒绝远程伪造或查询期间离开的请求。
--- @param playerNode Player 已认证的玩家实例。
--- @return boolean 玩家是否存活且位于任一世界的宝箱交互范围内。
local function IsNearGroupChest(playerNode)
    local character = playerNode.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return false
    end
    for worldIndex = 1, 3 do
        local chestRoot = FXLoader:Find(workspace,
            string.format("Decorations/World%dDecorations/GroupRewardChest/Root", worldIndex))
        if chestRoot and (root.Position - chestRoot.Position).Magnitude <= 12 then
            return true
        end
    end
    return false
end

--- 服务端通过群组列表核实入群，避开 IsInGroupAsync 的会话缓存；发奖与永久标记共同提交。
--- @return table 权威领取结果；未入群时附带固定群组 ID，供客户端展示平台入群弹窗。
function Component:ClaimGroupReward()
    if not self._lastTime or self._groupRewardBusy then
        return {success = false, key = TranslationTexts.NotReady}
    end
    if self:GetFlag(Fields.GroupRewardClaimed) then
        return {success = false, key = TranslationTexts.AlreadyClaimed}
    end
    local player = self:GetPlayerObject()
    local playerNode = self:GetPlayerNode()
    local userId = self:GetPlayerId()
    local storage = FS.PlayerKVDataManager
    local session = storage:GetSessionToken(userId)
    if not session or not IsNearGroupChest(playerNode) then
        return {success = false, key = TranslationTexts.NotReady}
    end
    self._groupRewardBusy = true
    local ok, isMember = pcall(function()
        local groups = GroupService:GetGroupsAsync(userId)
        for index, group in ipairs(groups) do
            if group.Id == RewardGroupId then
                return true
            end
        end
        return false
    end)
    self._groupRewardBusy = nil
    -- 平台查询允许 yield，旧会话或旧 Player 的结果不能写入重进后的档案。
    if not self._lastTime or FS.PlayerManager:GetPlayerObject(userId) ~= player
        or not storage:IsSessionActive(userId, session) or not IsNearGroupChest(playerNode) then
        return {success = false, key = TranslationTexts.NotReady}
    end
    if not ok then
        warn("[GroupReward] membership check failed", userId, isMember)
        return {success = false, key = TranslationTexts.GroupCheckFailed}
    end
    if not isMember then
        return {success = false, key = TranslationTexts.JoinGroup, groupId = RewardGroupId}
    end
    local reward = _G.ActivityConfig.CommonConfig.GroupRewardChestReward
    local success = player:RunDataTransaction(function()
        if self:GetFlag(Fields.GroupRewardClaimed) or not self:GrantRewards({reward}) then
            return false
        end
        return self:SetFlag(Fields.GroupRewardClaimed, true)
    end)
    return {success = success, key = success and TranslationTexts.Success or TranslationTexts.NotReady,
        amount = success and reward.Count or nil}
end

--- 返回玩家内协作名，供道具使用与福利协议定位。
--- @return string 活动组件名。
function Component:GetCompName()
    return "SActivityComp"
end

--- 离线超过五分钟才结算；未领取时只保留最长的一段离线收益，不累加批次。
--- @return nil
function Component:OnPlayerLogin()
    self._lastTime = os.time()
    self._friendEntries = Players:GetPlayers()
    self._friendAddedConnection = Players.PlayerAdded:Connect(function(player)
        table.insert(self._friendEntries, player)
    end)
    self:TrackConnection(self._friendAddedConnection)
    self._retentionStartedAt = workspace:GetServerTimeNow() - self:GetNumber(Fields.TrainingPlaytime)
    self._nextSync = self._lastTime + 10
    local data = self:GetTable(Fields.WelfareData)
    local day = math.floor(self._lastTime / 86400)
    local config = _G.GameConfig.CommonConfig.OfflineReward
    local seconds = data.lastSeenAt > 0 and math.clamp(self._lastTime - data.lastSeenAt, 0, config.Time) or 0
    if seconds <= 300 then
        seconds = 0
    end
    if data.offline.claimed or data.offline.training <= 0 or data.offline.seconds <= 300
        or seconds > data.offline.seconds then
        data.offline = {
            id = tostring(self._lastTime), seconds = seconds, claimed = false,
            training = self:RequireComponent("SMiscComp"):GetTrainingCardGain(seconds * config.Rate),
            boostedTraining = self:RequireComponent("SMiscComp"):GetTrainingCardGain(seconds * config.VIPRate),
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
    self:SetTable(Fields.WelfareData, data)
    self:UpdateTime(self._lastTime)
    self:PublishState()
end

--- 使用服务端实际经过时间累计；跨 UTC 日重置每日活动，保留当前离线奖励批次。
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
        self._friendEntries = Players:GetPlayers()
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

--- 按当前经验与倍率刷新离线预览，领取状态仅取当前批次标记。
function Component:PublishState()
    local data = self:GetTable(Fields.WelfareData)
    local config = _G.GameConfig.CommonConfig.OfflineReward
    local misc = self:RequireComponent("SMiscComp")
    self._revision = (self._revision or 0) + 1
    self:SetTable(Fields.WelfareState, {
        ready = true, revision = self._revision, day = data.day, onlineSeconds = data.onlineSeconds, loginDays = data.loginDays,
        retentionStartedAt = self._retentionStartedAt,
        onlineClaimed = FX.Table:DeepCopy(data.onlineClaimed),
        signInClaimed = FX.Table:DeepCopy(data.signInClaimed),
        taskProgress = FX.Table:DeepCopy(data.taskProgress),
        taskClaimed = FX.Table:DeepCopy(data.taskClaimed),
        dailyAmount = self:GetDailyAmount(), cards = FX.Table:DeepCopy(data.cards),
        offline = {
            id = data.offline.id,
            seconds = data.offline.seconds,
            training = data.offline.claimed and 0
                or misc:GetTrainingCardGain(data.offline.seconds * config.Rate),
            boostedTraining = data.offline.claimed and 0
                or misc:GetTrainingCardGain(data.offline.seconds * config.VIPRate),
            status = data.offline.claimed and "Claimed"
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

--- 离服时停止记录好友进服，并在保存前结清在线时长，重进当天继续累计。
function Component:OnPlayerLogout()
    if self._friendAddedConnection then
        self._friendAddedConnection:Disconnect()
        self._friendAddedConnection = nil
    end
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

--- 菜鸟拾取单独累计 GetNoob，不计入普通道具 GetItem；跨日重置后再记录。
function Component:RecordNoobPickup()
    self:UpdateTime(os.time())
    local data = self:GetTable(Fields.WelfareData)
    data.taskProgress.GetNoob = (data.taskProgress.GetNoob or 0) + 1
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
end

--- 平台好友查询允许 yield；每次进服独立计数，持续同服不因轮询重复增加。
function Component:CheckFriends()
    if self._friendTask then
        return
    end
    local player = Players:GetPlayerByUserId(self:GetPlayerId())
    if not player then
        return
    end
    local day = self:GetTable(Fields.WelfareData).day
    local entries = self._friendEntries
    self._friendEntries = {}
    self._friendTask = task.defer(function()
        local friends = {}
        local retries = {}
        for index, other in ipairs(entries) do
            if other ~= player then
                --- 查询失败时不增加任务进度，后续同步周期重试。
                --- @return boolean 平台确认的好友关系。
                local ok, isFriend = pcall(function()
                    return player:IsFriendsWithAsync(other.UserId)
                end)
                if ok and isFriend then
                    table.insert(friends, other)
                elseif not ok and other.Parent == Players then
                    table.insert(retries, other)
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
        for index, other in ipairs(retries) do
            table.insert(self._friendEntries, other)
        end
        -- 进服记录保留同服事实，查询返回前离开也计入；同一用户重进可再次增加。
        if #friends > 0 then
            data.taskProgress.ForFriendPlay = (data.taskProgress.ForFriendPlay or 0) + #friends
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
        TranslationTexts.PassActivated, {value = GameUtility.NumberToText(config.InstantGemCount), days = config.DayTime})
    if not notified then
        warn("[WeekCard] activation notification failed", message)
    end
    return true
end

--- 统一转换活动配置并整批发放；已拥有的永久光环不重复解锁，其余失败保留领取资格。
--- @param rewards table 服务端配置中的奖励列表。
--- @return boolean 是否发放成功。
function Component:GrantRewards(rewards)
    local batch = {}
    for index, reward in ipairs(rewards) do
        if reward.Type == "Gem" then
            table.insert(batch, {Type = "Money", Currency = "Diamonds", Count = reward.Count})
        elseif reward.Type == "Aura" then
            if reward.Count ~= 1 then
                return false
            end
            if not self:GetTable(Fields.AuraData).owned[tostring(reward.Id)] then
                table.insert(batch, {Type = "Unlock", Kind = "Aura", Id = reward.Id, Count = reward.Count})
            end
        else
            table.insert(batch, {Type = "Item", ItemId = reward.Id, Count = reward.Count})
        end
    end
    return self:RequireComponent("FSRewardComp"):AddRewards(batch)
end

--- RPC 只领取本人配置档位；离线按批次限领，礼包按累计在线时间限领并装备赠送光环。
--- @param kind any 客户端类别，仅接受 online、signin、task、diamonds、offline、retention。
--- @param rewardId any 稳定字符串 ID，不接受客户端金额或玩家身份。
--- @param multiplier any 离线领取方式，仅接受 1 或配置 VIPRate/Rate；加成领取消耗配置商品的钻石。
--- @return table 成功标记、提示 Key 和最新权威快照。
function Component:Claim(kind, rewardId, multiplier)
    if not self._lastTime or type(kind) ~= "string" or type(rewardId) ~= "string" or #rewardId > 32 then
        return {success = false, key = TranslationTexts.NotReady}
    end
    self:UpdateTime(os.time())
    local data = self:GetTable(Fields.WelfareData)
    local key = TranslationTexts.NotReady
    local success = false
    local reason = nil
    if kind == "retention" and rewardId == "once" then
        local retention = self:GetTable(Fields.MenuRetentionData)
        local config = _G.ActivityConfig.CommonConfig
        if retention.claimed then
            key = TranslationTexts.AlreadyClaimed
        elseif self:RequireComponent("SAnalyticsComp"):AccountTime() < config.MenuRetentionTriggerMinutes * 60 then
            if self:GrantRewards({config.MenuRetentionReward}) then
                local auraData = self:GetTable(Fields.AuraData)
                if config.MenuRetentionReward.Type == "Aura"
                    and (auraData.equippedId == 0
                        or Aura.GetTrainingRate(auraData) <= Aura.GetConfig(config.MenuRetentionReward.Id).TrainingRate) then
                    auraData.equippedId = config.MenuRetentionReward.Id
                    self:SetTable(Fields.AuraData, auraData)
                end
                -- 发奖与永久标记均不 yield，重复请求不能再次进入发奖分支。
                retention.claimed = true
                self:SetTable(Fields.MenuRetentionData, retention)
                success = true
            else
                key = TranslationTexts.InventoryFull
            end
        end
    elseif kind == "offline" then
        local config = _G.GameConfig.CommonConfig.OfflineReward
        local boostMultiplier = config.VIPRate / config.Rate
        if data.offline.claimed then
            key = TranslationTexts.AlreadyClaimed
        elseif rewardId == data.offline.id and data.offline.training > 0
            and (multiplier == 1 or multiplier == boostMultiplier) then
            local price = multiplier ~= 1 and _G.GoodsConfig.GemGoodsData[1].Price or 0
            local costs = price > 0 and {{Type = "Money", Currency = "Diamonds", Count = price}} or {}
            local misc = self:RequireComponent("SMiscComp")
            local normalGain = misc:GetTrainingCardGain(data.offline.seconds * config.Rate)
            local gain = multiplier == 1 and normalGain
                or misc:GetTrainingCardGain(data.offline.seconds * config.VIPRate)
            if multiplier ~= 1 and gain <= normalGain then
                key = TranslationTexts.NoBoostGain
            elseif self:GetNumber(Fields.Diamonds) < price then
                key = TranslationTexts.NeedDiamonds
                reason = "NeedDiamonds"
            elseif gain > 0 and self:RequireComponent("FSRewardComp"):ExchangeRewards(costs, {
                {Type = "Money", Currency = "RockTrainingValue", Count = gain},
            }) then
                -- 发奖和批次消费不 yield，重复请求只能命中已领取状态。
                data.offline.claimed = true
                data.offline.seconds = 0
                data.offline.training = 0
                data.offline.boostedTraining = 0
                self:SetTable(Fields.WelfareData, data)
                self:RequireComponent("SMiscComp"):RefreshProgress()
                FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain, true)
                if price > 0 then
                    self:RequireComponent("SAnalyticsComp"):Sink("Diamonds", price,
                        self:GetNumber(Fields.Diamonds), "GemGoods:1")
                end
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
            key = TranslationTexts.AlreadyClaimed
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
                key = TranslationTexts.AlreadyClaimed
            elseif eligible then
                if kind == "task" then
                    success = self:GrantRewards(config.Rewards)
                else
                    success = self:GrantRewards({config.Reward})
                end
                if success then
                    claimed[rewardId] = true
                else
                    key = TranslationTexts.InventoryFull
                end
            end
        end
    end
    self:SetTable(Fields.WelfareData, data)
    self:PublishState()
    return {success = success, key = success and TranslationTexts.Success or key, reason = reason,
        state = self:GetTable(Fields.WelfareState)}
end

return Component
