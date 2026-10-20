local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Welfare", {
    ItemReward = "{item} ×{value}",
    Claim = "Claim",
    Claimed = "Claimed",
    Locked = "Locked",
    Pending = "Claiming...",
    Retry = "Retry",
    InProgress = "In Progress",
    LoginDay = "Total login days: {day:int}",
    Diamonds = "{value} Diamonds",
    Minute = "{minutes:int} min",
    Day = "Day {day:int}",
    OfflineTime = "Offline Time: {hours:int}h {minutes:int}m {seconds:int}s",
    OfflineTraining = "Training: {value}",
    OfflineEmpty = "No offline rewards available.",
    OfflineClaim = "Claim ×{multiplier:int}",
    DailyAmount = "+{value} Diamonds per day",
    PassTomorrow = "Next claim tomorrow",
    Ready = "Ready to claim",
    PassRemaining = "{days:int} claims left · {status}",
    PassInactive = "Use this pass from your backpack to activate it.",
    Tomorrow = "Today's rewards claimed · Come back tomorrow",
    NotReady = "This reward is not available yet.",
    AlreadyClaimed = "You have already claimed this reward.",
    OnlineRequired = "Stay online for {minutes:int} more minute(s) to claim this reward.",
    LoginRequired = "Log in on {days:int} days to claim this reward.",
    TaskIncomplete = "Complete this task before claiming ({current:int}/{target:int}).",
    Unknown = "Something went wrong. Please try again.",
})
FXLoader:RequireFromParent(script, "Generated/CWelfareView")
local Welfare = FXLoader:RequireShared("Scripts/Game/Shared/Welfare")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CWelfareUICompClass", "CWelfareView")
local NormalRewardIconSize = 76
local FeaturedRewardIconSize = 160

--- 模板可能尚未同步到 Studio，运行时按目标尺寸放大奖励真实图片。
--- @param placeholder GuiObject 编辑器导出的占位图。
--- @param size number 目标边长。
local function ResizeRewardIcon(placeholder, size)
    local centerX = placeholder.Position.X.Offset + placeholder.Size.X.Offset / 2
    local centerY = placeholder.Position.Y.Offset + placeholder.Size.Y.Offset / 2
    placeholder.Position = UDim2.fromOffset(centerX - size / 2, centerY - size / 2)
    placeholder.Size = UDim2.fromOffset(size, size)
end

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
    self.Config = {
        groups = {
            {kind = "online", page = "OnlineBox", columns = 3, gapX = 20, gapY = 16, items = {}},
            {kind = "signin", page = "SignInBox", columns = 3, gapX = 12, gapY = 16, items = {}},
            {kind = "task", page = "TasksBox", columns = 1, gapX = 0, gapY = 12, items = {}},
        },
        diamonds = {rewardId = "daily_diamonds"},
        offline = {rewardId = ""},
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
            title = Text.TrSource(config.Desc),
            reward = Welfare.ToDisplayReward(config.Rewards[1]),
        })
    end
    self._firstSnapshot = true
    self:Hide()
    --- 云端译文加载或语言切换时刷新现有福利，不再次自动打开。
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshWelfare()
    end))
    self:BindUIData()
end

--- 监听立即回放当前快照，不额外请求初始数据或重复绑定按钮。
function Component:BindUIData()
    self:WatchDataChanged(Fields.WelfareState, self.RefreshWelfare, self)
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
    self.State = {
        offline = table.clone(data.offline),
        onlineMinutes = (data.onlineSeconds + math.max(0, os.time() - self._snapshotTime)) / 60,
        signInDay = data.loginDays,
        entries = {online = {}, signin = {}, task = {}},
        diamonds = {
            amount = data.dailyAmount,
            status = data.ready and (data.dailyAmount > 0 and "Claimable" or "Claimed") or "Locked",
        },
    }
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
    end
    if self._failure then
        local entry = self._failure.kind == "offline" and self.State.offline
            or self._failure.kind == "diamonds" and self.State.diamonds
            or self.State.entries[self._failure.kind][self._failure.id]
        if entry.status == "Claimed" then
            self._failure = nil
        else
            entry.error = Text.Tr(self._failure.key)
        end
    end
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

--- 奖励身份读取真实配置，Egg 展示槽用来放道具实际图标。
--- @param reward table 展示契约中的奖励类型和 ID。
--- @return table 本地化名称和展示槽。
function Component:GetRewardDisplay(reward)
    if reward.type == "Gem" then
        return {name = Text.TrSource("Diamonds"), icon = "Gem"}
    end
    return {name = Text.TrSource(_G.ItemConfig.Display[tonumber(reward.id)].Name), icon = "Egg"}
end

--- 仅格式化数量文案，原始数值仍用于服务端结算。
--- @param name string 已本地化的奖励名称。
--- @param amount number 原始奖励数量。
--- @return string 奖励说明。
function Component:FormatReward(name, amount)
    return Text.Tr(TranslationTexts.ItemReward, {item = name, value = GameUtility.NumberToText(amount)})
end

--- 动态文本关闭自动本地化，使用项目现有翻译入口。
--- @param root Instance 已核对的界面节点。
--- @param path string 相对文本节点路径。
--- @param key table Key/Source 文案定义。
--- @param arguments table? 原始或统一格式化后的参数。
function Component:SetText(root, path, key, arguments)
    local node = FXLoader:Here(root, path)
    node.AutoLocalize = false
    node.Text = Text.Tr(key, arguments)
end

--- 保留父类状态配色；不可领取的按钮允许点击解释原因，请求期间仍禁用。
--- @param button GuiButton 展示父类提供的按钮。
--- @param label string 父类状态文案或已本地化文本。
--- @param enabled boolean 当前是否允许点击。
function Component:RenderButton(button, label, enabled)
    local keys = {Claim = TranslationTexts.Claim, ["Check In"] = TranslationTexts.Claim, Claimed = TranslationTexts.Claimed,
        ["Checked In"] = TranslationTexts.Claimed, Locked = TranslationTexts.Locked, ["Claiming..."] = TranslationTexts.Pending,
        Retry = TranslationTexts.Retry, ["In Progress"] = TranslationTexts.InProgress}
    Component.Super.RenderButton(self, button, keys[label] and Text.Tr(keys[label]) or label, enabled)
    self:SetButtonEnabled(button, enabled or (not self._requestTask and not self._pending))
    FXLoader:Here(button, "ButtonTxt").AutoLocalize = button.Parent == FXLoader:Here(self.Root, "TabsBox")
end

--- 复用列表和布局，主界面红点汇总全部可领取奖励，钻石和道具使用实际图片。
--- @param state table 当前完整福利展示状态。
function Component:Render(state)
    for index, config in ipairs(self.Config.groups[3].items) do
        config.title = Text.TrSource(_G.ActivityConfig.DailyTaskConfig[tonumber(config.id)].Desc)
    end
    Component.Super.Render(self, state)
    local hasClaimable = state.offline.status == "Claimable" and not state.offline.pending
        or state.diamonds.status == "Claimable" and not state.diamonds.pending
    for index, group in ipairs(self.Config.groups) do
        for itemIndex, config in ipairs(group.items) do
            local entry = state.entries[group.kind][config.id]
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
    FXLoader:Here(self.Root, "TabsBox/TasksTabBtn").Visible = true
    self:SetText(self.Root, "PopupPanelImg/SignInBox/HeadingTxt", TranslationTexts.LoginDay, {day = state.signInDay})
    for kind, rows in pairs(self.Rows) do
        for id, row in pairs(rows) do
            self:_RenderRewardRow(kind, row)
        end
    end
end

--- 将奖励行接入项目文案，图标适配与文字刷新分别处理。
--- @param kind string 在线、签到或任务奖励分组。
--- @param row table 展示父类管理的奖励行。
function Component:_RenderRewardRow(kind, row)
    local config = row.Config
    local root = row.Root
    if kind == "task" then
        local taskName = FXLoader:Here(root, "TaskNameTxt")
        taskName.AutoLocalize = false
        taskName.Text = config.title
        local reward = config.reward
        local label = FXLoader:Here(root, "RewardTxt")
        label.AutoLocalize = false
        label.Text = reward.type == "Gem"
            and Text.Tr(TranslationTexts.Diamonds, {value = GameUtility.NumberToText(reward.amount)})
            or self:FormatReward(self:GetRewardDisplay(reward).name, reward.amount)
        FXLoader:Here(root, "ProgressBarImg/ProgressTxt").AutoLocalize = false
        -- 导出新任务原型前，旧模板仍只包含文字；避免同步顺序导致等待缺失节点。
        local iconBoxName = reward.type == "Gem" and "GemIconBox" or "EggIconBox"
        if FXLoader:Find(root, iconBoxName) then
            self:_RenderRewardIcon(root, reward)
        end
        return
    end
    self:SetText(root, kind == "online" and "TimeTxt" or "DayTxt",
        kind == "online" and TranslationTexts.Minute or TranslationTexts.Day,
        kind == "online" and {minutes = config.minutes} or {day = config.day})
    local reward = config.reward
    local label = FXLoader:Here(root, "RewardTxt")
    label.AutoLocalize = false
    label.TextScaled = true
    label.Text = reward.type == "Gem"
        and Text.Tr(TranslationTexts.Diamonds, {value = GameUtility.NumberToText(reward.amount)})
        or self:FormatReward(self:GetRewardDisplay(reward).name, reward.amount)
    local size = kind == "signin" and (config.featured and FeaturedRewardIconSize or NormalRewardIconSize) or nil
    self:_RenderRewardIcon(root, reward, size)
end

--- 复用已有图片节点；在线页保留新版模板尺寸，签到页沿用原有图标尺寸。
--- @param root GuiObject 奖励行根节点。
--- @param reward table 展示契约中的奖励类型和 ID。
--- @param size number? 签到图标边长，在线图标使用模板尺寸。
function Component:_RenderRewardIcon(root, reward, size)
    if reward.type ~= "Item" and reward.type ~= "Gem" then
        return
    end
    local box = FXLoader:Here(root, reward.type == "Gem" and "GemIconBox" or "EggIconBox")
    local placeholder = FXLoader:Here(box, "RewardIconImg")
    if size then
        ResizeRewardIcon(placeholder, size)
    end
    placeholder.Visible = false
    local imageName = reward.type .. "Image"
    local image = box:FindFirstChild(imageName)
    if not image then
        image = Instance.new("ImageLabel")
        image.Name = imageName
        image.BackgroundTransparency = 1
        image.ScaleType = Enum.ScaleType.Fit
        image.Parent = box
    end
    image.Position, image.Size, image.ZIndex = placeholder.Position, placeholder.Size, placeholder.ZIndex
    image.Image = reward.type == "Gem" and "rbxassetid://123110249883616"
        or _G.ItemConfig.Display[tonumber(reward.id)].IconId
end

--- 离线训练使用服务端批次，页签本地化刷新后按当前选中状态恢复配色。
--- @param state table 离线秒数、训练值、领取状态与请求标记。
function Component:RenderOffline(state)
    Component.Super.RenderOffline(self, state)
    local page = FXLoader:Here(self.Root, "PopupPanelImg/OfflineBox")
    local seconds = state.status == "Claimed" and 0 or state.seconds
    local training = state.status == "Claimed" and 0 or state.training
    self:SetText(page, "TimeTxt", TranslationTexts.OfflineTime, {
        hours = math.floor(seconds / 3600), minutes = math.floor(seconds % 3600 / 60),
        seconds = math.floor(seconds % 60),
    })
    self:SetText(page, "AmountTxt", TranslationTexts.OfflineTraining, {value = GameUtility.NumberToText(training)})
    local statusKey = state.status == "Claimed" and TranslationTexts.Claimed or TranslationTexts.OfflineEmpty
    self:SetText(page, "StatusTxt", self._failure and self._failure.kind == "offline" and self._failure.key or statusKey)
    for multiplier, name in ipairs({"SingleClaimBtn", "DoubleClaimBtn"}) do
        local label = state.pending and Text.Tr(TranslationTexts.Pending)
            or Text.Tr(TranslationTexts.OfflineClaim, {multiplier = multiplier})
        self:RenderButton(FXLoader:Here(page, name), label, state.status == "Claimable" and not state.pending)
    end
    local tab = FXLoader:Here(self.Root, "TabsBox/OfflineTabBtn")
    self:RenderButton(tab, "Offline Rewards", true)
    if self.ActiveTab ~= "offline" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        FXLoader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

--- 将原有加成说明槽展示为两种周卡；只有服务端金额决定领取按钮。
--- @param state table 今日金额、状态与请求标记。
function Component:RenderDiamonds(state)
    local page = FXLoader:Here(self.Root, "PopupPanelImg/DiamondsBox")
    page.Visible = self.ActiveTab == "diamonds"
    self:SetText(page, "AmountTxt", TranslationTexts.Diamonds, {value = GameUtility.NumberToText(state.amount)})
    self:SetText(page, "LoginBonusImg/AmountTxt", TranslationTexts.DailyAmount, {value = GameUtility.NumberToText(_G.GameConfig.CommonConfig.LoginData.GemCount)})
    for index, info in ipairs({{id = 101, path = "PremiumBonusImg"}, {id = 102, path = "FriendsBonusImg"}}) do
        local box = FXLoader:Here(page, info.path)
        local config = _G.ItemConfig.Data[info.id].KVTable
        local card = self._snapshot.cards[tostring(info.id)]
        local title = FXLoader:Here(box, "TitleTxt")
        title.AutoLocalize = false
        title.Text = Text.TrSource(_G.ItemConfig.Display[info.id].Name)
        self:SetText(box, "AmountTxt", TranslationTexts.DailyAmount, {value = GameUtility.NumberToText(config.DurationDays)})
        if card and card.remaining > 0 then
            local status = Text.Tr(card.lastClaimDay == self._snapshot.day and TranslationTexts.PassTomorrow or TranslationTexts.Ready)
            self:SetText(box, "HintTxt", TranslationTexts.PassRemaining, {days = card.remaining, status = status})
        else
            self:SetText(box, "HintTxt", TranslationTexts.PassInactive)
        end
    end
    local label = state.pending and "Claiming..." or state.status == "Claimed" and "Claimed"
        or state.status == "Claimable" and (state.error and "Retry" or "Claim") or "Locked"
    self:RenderButton(FXLoader:Here(page, "ClaimBtn"), label, state.status == "Claimable" and not state.pending)
    local statusKey = state.pending and TranslationTexts.Pending or state.status == "Claimed" and TranslationTexts.Tomorrow
        or state.status == "Claimable" and TranslationTexts.Ready or TranslationTexts.NotReady
    self:SetText(page, "StatusTxt", self._failure and self._failure.kind == "diamonds" and self._failure.key or statusKey)
    local tab = FXLoader:Here(self.Root, "TabsBox/DiamondsTabBtn")
    self:RenderButton(tab, "Diamonds", true)
    FXLoader:Here(tab, "RedDotImg").Visible = state.status == "Claimable" and not state.pending
    if self.ActiveTab ~= "diamonds" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        FXLoader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

--- 条件不足只提示具体原因；服务端确认领取成功后播放奖励音，并以权威快照刷新。
--- @param action string 展示层的 Claim、ClaimDiamonds 或 ClaimOffline。
--- @param payload table 稳定 rewardId 及可选 kind、multiplier。
function Component:OnUIAction(action, payload)
    if self._requestTask then
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
    self._pending = {kind = kind, id = payload.rewardId}
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
