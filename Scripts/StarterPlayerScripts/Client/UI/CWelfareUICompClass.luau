local FX = _G.FX
local FXLoader = FX.Loader
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
            badge = self._localization:FormatByKey("Welfare.WeeklyReward"),
            color = {102, 80, 25},
        })
    end
    for index, config in ipairs(_G.ActivityConfig.DailyTaskConfig) do
        table.insert(self.Config.groups[3].items, {
            id = tostring(config.Index), target = config.Target, taskType = config.Type,
            title = self._localization:FormatByKey("Welfare.Task." .. config.Type, {target = config.Target}),
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

--- 将服务端快照转换为完整条目状态，pending 只代表当前网络请求。
--- @param data table? 数据订阅或 RPC 提供的快照，省略时读取框架数据。
function Component:RefreshWelfare(data)
    data = data or self:GetTable(Fields.WelfareState)
    if self._snapshot and self._snapshot.revision > data.revision then
        data = self._snapshot
    end
    self._snapshot = data
    self.State = {
        onlineMinutes = math.floor(data.onlineSeconds / 60),
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
        local entry = self._pending.kind == "diamonds" and self.State.diamonds
            or self.State.entries[self._pending.kind][self._pending.id]
        entry.pending = true
    end
    if self._failure then
        local entry = self._failure.kind == "diamonds" and self.State.diamonds
            or self.State.entries[self._failure.kind][self._failure.id]
        if entry.status == "Claimed" then
            self._failure = nil
        else
            entry.error = self._localization:FormatByKey(self._failure.key)
        end
    end
    self:RefreshUI()
    if data.ready and self._firstSnapshot then
        self._firstSnapshot = false
        if data.dailyAmount > 0 then
            self:Show()
            self.ActiveTab = "diamonds"
            self:RefreshUI()
        end
    end
end

--- 奖励身份读取真实配置，Egg 展示槽用来放道具实际图标。
--- @param reward table 展示契约中的奖励类型和 ID。
--- @return table 本地化名称和展示槽。
function Component:GetRewardDisplay(reward)
    if reward.type == "Gem" then
        return {name = "Diamonds", icon = "Gem"}
    end
    return {name = self._localization:FormatByKey("Welfare.Item." .. reward.id), icon = "Egg"}
end

--- 仅格式化数量文案，原始数值仍用于服务端结算。
--- @param name string 已本地化的奖励名称。
--- @param amount number 原始奖励数量。
--- @return string 奖励说明。
function Component:FormatReward(name, amount)
    return self._localization:FormatByKey("Welfare.ItemReward", {item = name, value = GameUtility.NumberToText(amount)})
end

--- 动态文本关闭自动本地化，使用项目现有翻译入口。
--- @param root Instance 已核对的界面节点。
--- @param path string 相对文本节点路径。
--- @param key string 稳定文案 Key。
--- @param arguments table? 原始或统一格式化后的参数。
function Component:SetText(root, path, key, arguments)
    local node = FXLoader:Here(root, path)
    node.AutoLocalize = false
    node.Text = self._localization:FormatByKey(key, arguments)
end

--- 保留父类按钮配色及禁用逻辑，只把父类英文状态映射到稳定 Key。
--- @param button GuiButton 展示父类提供的按钮。
--- @param label string 父类状态文案或已本地化文本。
--- @param enabled boolean 当前是否允许点击。
function Component:RenderButton(button, label, enabled)
    local keys = {Claim = "Welfare.Claim", ["Check In"] = "Welfare.Claim", Claimed = "Welfare.Claimed",
        ["Checked In"] = "Welfare.Claimed", Locked = "Welfare.Locked", ["Claiming..."] = "Welfare.Pending",
        Retry = "Welfare.Retry", ["Online\nRewards"] = "Welfare.Online", ["Daily Login"] = "Welfare.SignIn",
        Diamonds = "Welfare.Daily", Tasks = "Welfare.Tasks", ["In Progress"] = "Welfare.InProgress"}
    Component.Super.RenderButton(self, button, keys[label] and self._localization:FormatByKey(keys[label]) or label, enabled)
    FXLoader:Here(button, "ButtonTxt").AutoLocalize = false
end

--- 复用列表和布局，主界面红点汇总全部可领取奖励，钻石和道具使用实际图片。
--- @param state table 当前完整福利展示状态。
function Component:Render(state)
    for index, config in ipairs(self.Config.groups[3].items) do
        config.title = self._localization:FormatByKey("Welfare.Task." .. config.taskType, {target = config.target})
    end
    Component.Super.Render(self, state)
    local hasClaimable = state.diamonds.status == "Claimable" and not state.diamonds.pending
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
    self:SetText(self.Root, "PopupPanelImg/TasksBox/HeadingTxt", "Welfare.Tasks")
    self:SetText(self.Root, "PopupPanelImg/TasksBox/SubtitleTxt", "Welfare.TaskRule")
    self:SetText(self.Root, "PopupPanelImg/TasksBox/FooterTxt", "Welfare.TaskRule")
    self:SetText(self.Root, "TitleBox/TitleTxt", "Welfare.Title")
    self:SetText(self.Root, "PopupPanelImg/OnlineBox/HeadingTxt", "Welfare.Online")
    self:SetText(self.Root, "PopupPanelImg/OnlineBox/SubtitleTxt", "Welfare.OnlineTime", {minutes = state.onlineMinutes})
    self:SetText(self.Root, "PopupPanelImg/OnlineBox/FooterTxt", "Welfare.OnlineRule")
    self:SetText(self.Root, "PopupPanelImg/SignInBox/HeadingTxt", "Welfare.LoginDay", {day = state.signInDay})
    self:SetText(self.Root, "PopupPanelImg/SignInBox/SubtitleTxt", "Welfare.SignIn")
    self:SetText(self.Root, "PopupPanelImg/SignInBox/FooterTxt", "Welfare.SignInRule")
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
        self:SetText(root, "TaskNameTxt", "Welfare.Task." .. config.taskType, {target = config.target})
        local reward = config.reward
        local label = FXLoader:Here(root, "RewardTxt")
        label.AutoLocalize = false
        label.Text = reward.type == "Gem"
            and self._localization:FormatByKey("Welfare.Diamonds", {value = GameUtility.NumberToText(reward.amount)})
            or self:FormatReward(self:GetRewardDisplay(reward).name, reward.amount)
        FXLoader:Here(root, "ProgressBarImg/ProgressTxt").AutoLocalize = false
        return
    end
    self:SetText(root, kind == "online" and "TimeTxt" or "DayTxt",
        kind == "online" and "Welfare.Minute" or "Welfare.Day",
        kind == "online" and {minutes = config.minutes} or {day = config.day})
    local reward = config.reward
    local label = FXLoader:Here(root, "RewardTxt")
    label.AutoLocalize = false
    label.TextScaled = true
    label.Text = reward.type == "Gem"
        and self._localization:FormatByKey("Welfare.Diamonds", {value = GameUtility.NumberToText(reward.amount)})
        or self:FormatReward(self:GetRewardDisplay(reward).name, reward.amount)
    if config.featured then
        self:SetText(root, "WeeklyTxt", "Welfare.WeeklyReward")
    end
    self:_RenderRewardIcon(root, reward, config.featured)
end

--- 复用已有图片节点，按普通奖励或精选奖励尺寸展示真实图标。
--- @param root GuiObject 奖励行根节点。
--- @param reward table 展示契约中的奖励类型和 ID。
--- @param featured boolean? 是否使用精选奖励尺寸。
function Component:_RenderRewardIcon(root, reward, featured)
    if reward.type ~= "Item" and reward.type ~= "Gem" then
        return
    end
    local box = FXLoader:Here(root, reward.type == "Gem" and "GemIconBox" or "EggIconBox")
    local placeholder = FXLoader:Here(box, "RewardIconImg")
    ResizeRewardIcon(placeholder, featured and FeaturedRewardIconSize or NormalRewardIconSize)
    placeholder.Visible = false
    if reward.type == "Item" then
        local mark = FXLoader:Here(box, "IconMarkTxt")
        mark.Position, mark.Size = placeholder.Position, placeholder.Size
        mark.Visible = false
    end
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
    image.Image = reward.type == "Gem" and "rbxassetid://116061018286803"
        or _G.ItemConfig.Display[tonumber(reward.id)].IconId
end

--- 将原有加成说明槽展示为两种周卡；只有服务端金额决定领取按钮。
--- @param state table 今日金额、状态与请求标记。
function Component:RenderDiamonds(state)
    local page = FXLoader:Here(self.Root, "PopupPanelImg/DiamondsBox")
    page.Visible = self.ActiveTab == "diamonds"
    self:SetText(page, "HeadingTxt", "Welfare.Daily")
    self:SetText(page, "SubtitleTxt", "Welfare.DailySubtitle")
    self:SetText(page, "AvailableTxt", "Welfare.Available")
    self:SetText(page, "AmountTxt", "Welfare.Diamonds", {value = GameUtility.NumberToText(state.amount)})
    self:SetText(page, "FooterTxt", "Welfare.DailyRule")
    self:SetText(page, "LoginBonusImg/TitleTxt", "Welfare.LoginBonus")
    self:SetText(page, "LoginBonusImg/AmountTxt", "Welfare.DailyAmount", {value = GameUtility.NumberToText(_G.GameConfig.CommonConfig.LoginData.GemCount)})
    self:SetText(page, "LoginBonusImg/HintTxt", "Welfare.Daily")
    for index, info in ipairs({{id = 101, path = "PremiumBonusImg"}, {id = 102, path = "FriendsBonusImg"}}) do
        local box = FXLoader:Here(page, info.path)
        local config = _G.ItemConfig.Data[info.id].KVTable
        local card = self._snapshot.cards[tostring(info.id)]
        self:SetText(box, "TitleTxt", "Welfare.Item." .. info.id)
        self:SetText(box, "AmountTxt", "Welfare.DailyAmount", {value = GameUtility.NumberToText(config.DurationDays)})
        if card and card.remaining > 0 then
            local status = self._localization:FormatByKey(card.lastClaimDay == self._snapshot.day and "Welfare.PassTomorrow" or "Welfare.Ready")
            self:SetText(box, "HintTxt", "Welfare.PassRemaining", {days = card.remaining, status = status})
        else
            self:SetText(box, "HintTxt", "Welfare.PassInactive")
        end
    end
    local label = state.pending and "Claiming..." or state.status == "Claimed" and "Claimed"
        or state.status == "Claimable" and (state.error and "Retry" or "Claim") or "Locked"
    self:RenderButton(FXLoader:Here(page, "ClaimBtn"), label, state.status == "Claimable" and not state.pending)
    local statusKey = state.pending and "Welfare.Pending" or state.status == "Claimed" and "Welfare.Tomorrow"
        or state.status == "Claimable" and "Welfare.Ready" or "Welfare.NotReady"
    self:SetText(page, "StatusTxt", self._failure and self._failure.kind == "diamonds" and self._failure.key or statusKey)
    local tab = FXLoader:Here(self.Root, "TabsBox/DiamondsTabBtn")
    self:RenderButton(tab, "Diamonds", true)
    FXLoader:Here(tab, "RedDotImg").Visible = state.status == "Claimable" and not state.pending
    if self.ActiveTab ~= "diamonds" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        FXLoader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

--- 客户端只提交类别和稳定 ID，失败恢复按钮，成功以服务端快照刷新。
--- @param action string 展示层的 Claim 或 ClaimDiamonds。
--- @param payload table 稳定 rewardId 及可选 kind。
function Component:OnUIAction(action, payload)
    if self._requestTask or not self._snapshot.ready then
        return
    end
    local kind = action == "ClaimDiamonds" and "diamonds" or payload.kind
    self._pending = {kind = kind, id = payload.rewardId}
    self._failure = nil
    self:RefreshWelfare()
    --- 异步等待只发生在客户端，服务端结算不依赖窗口是否仍然打开。
    self._requestTask = task.defer(function()
        --- 网络拒绝会抛错，保留英文错误提示及重试能力。
        --- @return table 服务端领取结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_ClaimWelfareReward", kind, payload.rewardId)
        end)
        self._requestTask = nil
        self._pending = nil
        if ok and type(result) == "table" and result.success then
            self._commonUI:ShowLocalizedTips(result.key)
        else
            local key = ok and type(result) == "table" and result.key or "Common.Unknown"
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
