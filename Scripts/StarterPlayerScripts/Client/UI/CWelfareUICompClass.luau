local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Welfare", {
    OfflineEmpty = "No offline rewards available.",
    NotReady = "This reward is not available yet.",
    AlreadyClaimed = "You have already claimed this reward.",
    OnlineRequired = "Stay online for {minutes:int} more minute(s) to claim this reward.",
    LoginRequired = "Log in on {days:int} days to claim this reward.",
    TaskIncomplete = "Complete this task before claiming ({current:int}/{target:int}).",
    Unknown = "Something went wrong. Please try again.",
})
FXLoader:RequireFromParent(script, "Generated/CWelfareView")
local Welfare = FXLoader:RequireShared("Scripts/Game/Shared/Welfare")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CWelfareUICompClass", "CWelfareView")
--- 业务子类独立挂载，展示父类不重复创建。
--- @return string 福利组件协作名。
function Component:GetCompName()
    return "CWelfareUIComp"
end

--- 按现有配置构造在线、签到和每日任务的完整展示契约。
function Component:OnReady()
    Component.Super.OnReady(self)
    self.Root.ResetOnSpawn = false
    self.Root.DisplayOrder = 10
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(self.Root)
    self._localization = self._commonUI.Localization
    self._mainRewardDot = FXLoader:Here(self:GetPlayerNode():WaitForChild("PlayerGui"),
        "MainUI/LeftCenter/RewardBtn/RedDotImg")
    self._mainRewardDot.Visible = false
    local offlineConfig = _G.GameConfig.CommonConfig.OfflineReward
    self.Config = {
        groups = {
            {kind = "online", page = "OnlineBox", columns = 3, gapX = 20, gapY = 16, items = {}},
            {kind = "signin", page = "SignInBox", columns = 3, gapX = 12, gapY = 16, items = {}},
            {kind = "task", page = "TasksBox", columns = 1, gapX = 0, gapY = 12, items = {}},
        },
        diamonds = {rewardId = "daily_diamonds", passes = {},
            loginAmount = _G.GameConfig.CommonConfig.LoginData.GemCount},
        offline = {rewardId = "", boostMultiplier = offlineConfig.VIPRate / offlineConfig.Rate},
        allowUnavailableAction = true,
    }
    for index, config in ipairs(_G.ActivityConfig.OnlineRewardData) do
        table.insert(self.Config.groups[1].items, {
            id = tostring(config.Index), minutes = config.TargetMinutes,
            reward = Welfare.ToDisplayReward(config.Reward),
        })
    end
    for index, config in ipairs(_G.ActivityConfig.LoginMilestoneData) do
        table.insert(self.Config.groups[2].items, {
            id = tostring(config.Index), day = config.LoginDays,
            reward = Welfare.ToDisplayReward(config.Reward),
            featured = config.LoginDays == 7,
            badge = "Weekly Reward",
            color = {102, 80, 25},
        })
    end
    for index, config in ipairs(_G.ActivityConfig.DailyTaskConfig) do
        table.insert(self.Config.groups[3].items, {
            id = tostring(config.Index), target = config.Target, taskType = config.Type,
            title = config.Desc,
            reward = Welfare.ToDisplayReward(config.Rewards[1]),
        })
    end
    self._firstSnapshot = true
    self._claimQueue = {}
    self:Hide()
    --- 云端译文加载或语言切换时刷新现有福利，不再次自动打开。
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshWelfare()
    end))
    self:BindUIData()
end

--- 监听立即回放当前快照；训练值和重生次数变化时同步刷新离线奖励的经验上限。
function Component:BindUIData()
    self:WatchDataChanged(Fields.WelfareState, self.RefreshWelfare, self)
    for index, field in ipairs({Fields.RockTrainingValue, Fields.RebirthCount}) do
        self:WatchDataChanged(field, function()
            self:RefreshWelfare()
        end)
    end
end

--- 将服务端快照转换为完整条目状态；主引导未完成时跳过首次自动弹窗，手动领取不受影响。
--- @param data table? 数据订阅或 RPC 提供的快照，省略时读取框架数据。
function Component:RefreshWelfare(data)
    data = data or self:GetTable(Fields.WelfareState)
    if self._snapshot and self._snapshot.revision > data.revision then
        data = self._snapshot
    end
    if not self._snapshot or self._snapshot.revision ~= data.revision then
        self._snapshotTime = os.time()
    end
    self._snapshot = data
    self.Config.offline.rewardId = data.offline.id
    self.Config.diamonds.passes = {}
    for index, itemId in ipairs({101, 102}) do
        local config = _G.ItemConfig.Data[itemId].KVTable
        local card = data.cards[tostring(itemId)]
        table.insert(self.Config.diamonds.passes, {
            name = _G.ItemConfig.Display[itemId].Name,
            amount = config.DurationDays,
            remaining = card and card.remaining or 0,
            claimedToday = card ~= nil and card.lastClaimDay == data.day,
        })
    end
    self.State = {
        busy = self._pending ~= nil,
        offline = table.clone(data.offline),
        onlineMinutes = (data.onlineSeconds + math.max(0, os.time() - self._snapshotTime)) / 60,
        signInDay = data.loginDays,
        entries = {online = {}, signin = {}, task = {}},
        diamonds = {
            amount = data.dailyAmount,
            status = data.ready and (data.dailyAmount > 0 and "Claimable" or "Claimed") or "Locked",
        },
    }
    local remaining = math.max(0, Rebirth.GetMaxTrainingValue(self:GetNumber(Fields.RebirthCount))
        - self:GetNumber(Fields.RockTrainingValue))
    self.State.offline.training = math.min(data.offline.training, remaining)
    self.State.offline.boostedTraining = math.min(data.offline.training * self.Config.offline.boostMultiplier, remaining)
    self.State.offline.boostAvailable = self.State.offline.boostedTraining > self.State.offline.training
    self.State.offline.boostPrice = _G.GoodsConfig.GemGoodsData[1].Price
    self.State.offline.boostCurrency = "Gem"
    for index, group in ipairs(self.Config.groups) do
        for itemIndex, config in ipairs(group.items) do
            local current = group.kind == "task" and (config.taskType == "OnlineTime"
                and math.floor(data.onlineSeconds / 60) or ((data.taskProgress or {})[config.taskType] or 0)) or 0
            local claimed = group.kind == "online" and data.onlineClaimed
                or group.kind == "task" and (data.taskClaimed or {}) or data.signInClaimed
            local eligible = group.kind == "online" and data.onlineSeconds >= config.minutes * 60
                or group.kind == "signin" and data.loginDays >= config.day
                or group.kind == "task" and current >= config.target
            self.State.entries[group.kind][config.id] = {
                status = claimed[config.id] and "Claimed" or (data.ready and eligible and "Claimable" or "Locked"),
                current = current,
            }
        end
    end
    if self._pending then
        local entry = self._pending.kind == "offline" and self.State.offline
            or self._pending.kind == "diamonds" and self.State.diamonds
            or self.State.entries[self._pending.kind][self._pending.id]
        entry.pending = true
        if self._pending.kind == "offline" then
            entry.pendingMultiplier = self._pending.multiplier
        end
    end
    if self._failure then
        local entry = self._failure.kind == "offline" and self.State.offline
            or self._failure.kind == "diamonds" and self.State.diamonds
            or self.State.entries[self._failure.kind][self._failure.id]
        if entry.status == "Claimed" then
            self._failure = nil
        else
            entry.errorText = Text.Tr(self._failure.key)
        end
    end
    local hasClaimable = self.State.offline.status == "Claimable" and not self.State.offline.pending
        or self.State.diamonds.status == "Claimable" and not self.State.diamonds.pending
    for index, group in ipairs(self.Config.groups) do
        for itemIndex, config in ipairs(group.items) do
            local entry = self.State.entries[group.kind][config.id]
            if entry.status == "Claimable" and not entry.pending then
                hasClaimable = true
                break
            end
        end
        if hasClaimable then
            break
        end
    end
    self._mainRewardDot.Visible = hasClaimable
    self:RefreshUI()
    if data.ready and self._firstSnapshot then
        self._firstSnapshot = false
        local guide = self:GetTable(Fields.Guide)
        local first = guide.guideMap and guide.guideMap.FirstLootGuide
        if first and first.state == "Finished"
            and (data.offline.status == "Claimable" or data.dailyAmount > 0) then
            self:Show()
        end
    end
end

--- 在线页每秒插值展示倒计时，领取资格仍只使用服务端快照。
--- @param serverTime number 框架提供的当前秒级时间戳。
function Component:OnUpdate(serverTime)
    if not self._snapshot or not self._snapshot.ready or not self.Root.Enabled or self.ActiveTab ~= "online" then
        return
    end
    self.State.onlineMinutes = (self._snapshot.onlineSeconds + math.max(0, serverTime - self._snapshotTime)) / 60
    self:RefreshUI()
end

--- 奖励名称原文由展示类翻译，真实图片通过契约交给展示类管理。
--- @param reward table 奖励类型和配置 ID。
--- @return table 原文名称、展示类别和图片资源。
function Component:GetRewardDisplay(reward)
    if reward.type == "Gem" then
        return {name = "Diamonds", icon = "Gem", image = "rbxassetid://123110249883616"}
    end
    local item = _G.ItemConfig.Display[tonumber(reward.id)]
    return {name = item.Name, icon = "Egg", image = item.IconId}
end

--- 福利数量统一沿用项目数值格式。
--- @param value number 原始奖励数量。
--- @return string 展示数量。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 条件不足提示原因；同页批量领取顺序排队，服务端逐项确认后刷新权威快照。
--- @param action string 展示层的 Claim、ClaimDiamonds 或 ClaimOffline。
--- @param payload table 稳定 rewardId 及可选 kind、multiplier。
function Component:OnUIAction(action, payload)
    if self._requestTask then
        if action == "Claim" and (payload.kind == "online" or payload.kind == "signin")
            and self._pending.kind == payload.kind then
            table.insert(self._claimQueue, {kind = payload.kind, rewardId = payload.rewardId})
        end
        return
    end
    if not self._snapshot.ready then
        self._commonUI:ShowLocalizedTips(TranslationTexts.NotReady)
        return
    end
    local kind = action == "ClaimOffline" and "offline"
        or action == "ClaimDiamonds" and "diamonds" or payload.kind
    local entry = kind == "offline" and self.State.offline
        or kind == "diamonds" and self.State.diamonds or self.State.entries[kind][payload.rewardId]
    if entry.status ~= "Claimable" then
        local key, arguments = TranslationTexts.AlreadyClaimed, nil
        if kind == "offline" and entry.status ~= "Claimed" then
            key = TranslationTexts.OfflineEmpty
        elseif kind == "diamonds" and entry.status == "Locked" then
            key = TranslationTexts.NotReady
        elseif entry.status == "Locked" then
            local config = self.Rows[kind][payload.rewardId].Config
            if kind == "online" then
                key, arguments = TranslationTexts.OnlineRequired, {
                    minutes = math.ceil((config.minutes * 60 - self._snapshot.onlineSeconds) / 60),
                }
            elseif kind == "signin" then
                key, arguments = TranslationTexts.LoginRequired, {days = config.day}
            else
                key, arguments = TranslationTexts.TaskIncomplete, {current = entry.current, target = config.target}
            end
        end
        self._commonUI:ShowLocalizedTips(key, arguments)
        return
    end
    self._pending = {kind = kind, id = payload.rewardId, multiplier = payload.multiplier}
    self._failure = nil
    self:RefreshWelfare()
    --- 异步等待只发生在客户端，服务端结算不依赖窗口是否仍然打开。
    self._requestTask = task.defer(function()
        --- 网络拒绝会抛错，保留英文错误提示及重试能力。
        --- @return table 服务端领取结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_ClaimWelfareReward", kind, payload.rewardId, payload.multiplier)
        end)
        self._requestTask = nil
        self._pending = nil
        if ok and type(result) == "table" and result.success then
            self:GetPlayerObject():RequireComponent("CSoundComp"):PlayRewardSound()
            self._commonUI:ShowLocalizedTips(result.key)
        else
            local key = ok and type(result) == "table" and result.key or TranslationTexts.Unknown
            self._failure = {kind = kind, id = payload.rewardId, key = key}
            self._commonUI:ShowLocalizedTips(key)
        end
        -- 回包立即恢复权威按钮；revision 避免稍后到达的旧同步覆盖新状态。
        self:RefreshWelfare(ok and type(result) == "table" and result.state or nil)
        while #self._claimQueue > 0 do
            local nextClaim = table.remove(self._claimQueue, 1)
            if self.State.entries[nextClaim.kind][nextClaim.rewardId].status == "Claimable" then
                self:OnUIAction("Claim", nextClaim)
                break
            end
        end
    end)
end

--- 取消尚未完成的领取请求，父类负责销毁行节点及数据、按钮订阅。
function Component:Dtor()
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    Component.Super.Dtor(self)
end

return Component
