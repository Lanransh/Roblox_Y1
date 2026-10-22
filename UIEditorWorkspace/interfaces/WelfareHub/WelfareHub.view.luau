--[[
福利中心统一接入契约（离线 / 每日钻石 / 签到 / 在线 / 任务）

【一、公共约定与完整数据结构】
  Config、State 均为完整表，以下标为必填的字段无默认值。
  Status = "Locked" | "Claimable" | "Claimed"，分别为未满足 / 可领取 / 已领取。
  View 只展示业务提供的 status，不从进度或奖励数量推导真实资格。
  所有金额/时长均为原始数值，不传拼接后的数量文案；名称/提示为原文，
  View 内按 Text.TrSource 或 Text.Tr 查询。ID 不翻译。

【二、Config：完整配置】
  offline: table，必填。
    rewardId: string，必填；稳定离线奖励批次 ID，不是奖励物品 ID。
  diamonds: table，必填。
    rewardId: string，必填；稳定每日钻石奖励业务 ID。
    loginAmount: number，必填；登录奖励钻石数量。
    premiumAmount: number，必填；会员加成钻石数量。
    friendAmount: number，必填；每位好友加成钻石数量。
    friendCap: number，必填；好友加成上限，单位钻石，不是好友人数。
    上述数值仅用于说明卡，View 不据此计算可领数量或资格。
  groups: {Group}，必填有序连续数组；online/signin/task 各一组，kind 不重复。
    Group.kind: "online" | "signin" | "task"，必填；分组稳定标识。
    Group.page: string，必填；与 kind 固定对应
      online="OnlineBox"、signin="SignInBox"、task="TasksBox"。
    Group.columns: number，必填；正整数列数，task 使用 1。
    Group.gapX / Group.gapY: number，均必填；横/纵间距，单位逻辑像素。
    Group.items: {Item}，必填有序连续数组，可为空 {}。
      Item.id: string，必填；组内唯一稳定奖励/任务条目 ID。
      Item.reward: Reward，必填；不是条目自身的身份。
        Reward.type: string，必填；游戏奖励类型，由接入查询方法解释。
        Reward.id: string，必填；该 type 下的物品/货币配置 ID。
        Reward.amount: number，必填；原始奖励数量，单位由 type/id 决定；
          任务数量按整数显示，业务须提供与奖励规则一致的数量。
      online 项另必填 minutes: number，正数，在线门槛，单位分钟。
      signin 项另必填 day: number，正整数，第几天。
      task 项另必填 title: string，任务名称原文；
        target: number，目标值；单位由任务定义，<=0 显示空条与 —。
      featured: boolean，可选，省略 false；仅签到使用的双行大奖。
        true 时还必填 badge: string（标记原文）、color: {number, number, number}
        （RGB 三个分量，各 0..255）；当前布局只有一个大奖槽，至多一项。

【三、State：Render 的完整输入】
  offline: table，必填；以下 seconds/training/status 必填，无默认值。
    seconds: number，非负离线秒数；显示小时及两位分钟，秒向下取整到分钟。
    training: number，非负，可领基础训练值，不含双倍加成。
    status: Status；Claimed 时显示时长/训练值为零并隐藏领取按钮。
    pending: boolean，可选，省略 false；禁用单倍和双倍领取。
    error: string，可选，省略 nil；提示原文；Claimed 的已领提示优先于错误。
    仅 status=Claimable 且 training>0 才显示两种领取按钮；
    请求中仍显示但禁用；无 error 且不可领时显示无奖励/已领提示。
  diamonds: table，必填。
    amount: number，必填；服务端确认的本日可领钻石数，单位钻石。
    status: Status，必填；不由 amount 推导，0 不自动禁用 Claimable。
    pending: boolean，可选，省略 false；禁用领取。
    error: string，可选，省略 nil；仅 Claimable 且非 pending 时显示，
      按钮为 Retry；Locked/Claimed 使用各自提示。
  onlineMinutes: number，必填；在线分钟数，允许小数分钟。
  signInDay: number，必填；当前签到天序号，单位天。
  entries: {[kind: string]: {[entryId: string]: Entry}}，必填两层字典。
    kind 对应 groups[].kind，entryId 对应同组 items[].id，
    不是 reward.id；所有配置分组及其条目必须有状态，不自动当作 Locked。
    Entry.status: Status，必填。
    Entry.current: number，task 必填；当前进度，与 Item.target 同单位。
    Entry.pending: boolean，可选，省略 false；禁用本条领取。
    Entry.error: string，可选，省略 nil；Claimable 且非 pending 时按钮为 Retry，
      但列表条目不显示错误原文。
    Entry.label: string，可选，省略 nil；仅 Locked 时作为自定义按钮原文。
      不传时 task 显示 In Progress、online 显示剩余 mm:ss、
      signin 按 day-signInDay 显示 Tomorrow / In N days / Locked。
  error/label 的空字符串在 Luau 中仍有效；要恢复默认行为应设 nil。
  空组须同时提供 items={} 与 entries[kind]={}；即使页面未打开也须有完整数据。
  没有全局 open/loading 字段；异步未就绪时延后 BindUIData/Show。

【四、最小完整数据（接入 Ctor 调用父构造之后）】
  self.Config = {
      offline = { rewardId = "offline_session_1" },
      diamonds = { rewardId = "daily_diamonds", loginAmount = 100,
          premiumAmount = 50, friendAmount = 10, friendCap = 100 },
      groups = {
          { kind = "online", page = "OnlineBox", columns = 3,
            gapX = 20, gapY = 16, items = {} },
          { kind = "signin", page = "SignInBox", columns = 3,
            gapX = 12, gapY = 16, items = {} },
          { kind = "task", page = "TasksBox", columns = 1, gapX = 0, gapY = 12,
            items = { { id = "collect", title = "Collect Cash", target = 100,
                reward = { type = "Currency", id = "Gold", amount = 20 } } } },
      },
  }
  self.State = {
      offline = { seconds = 9000, training = 1500, status = "Claimable" },
      diamonds = { amount = 100, status = "Claimable" },
      onlineMinutes = 0, signInDay = 1,
      entries = { online = {}, signin = {},
          task = { collect = { status = "Claimable", current = 100 } } },
  }

【初始化与刷新】
  游戏接入类继承 CWelfareView。
  接入 Ctor(owner) 先调用自身类的 Super.Ctor(self, owner)，再准备下例数据。
  接入 OnReady() 先调用自身类的 Super.OnReady(self)，再依次
  self:BindUIData()、self:Show()；父 OnReady 负责绑定节点，OnShow 会刷新。
  GetUIConfig() 默认返回 self.Config；GetUIState() 默认返回 self.State。
  RefreshUI() 调用 Render(GetUIState())，输入是完整快照，不合并增量，
  不自动补齐业务字段。可修改已有表或替换整表，但每次刷新须满足完整契约。
  后续先更新 Config/State，再 self:RefreshUI()；异步未就绪按本页规则处理。
  无需覆写 Render 或手动重复调用 OnReady；业务类覆写生命周期时须保留父调用。

【五、必需/可选覆写与动作】
  必需 GetRewardDisplay(reward: Reward) -> { name: string, icon: string }。
    name 为奖励名称原文；icon 只能 "Coin" | "Gem" | "Egg"，表示设计图标类别，
    不是 Roblox 资源地址。例如 Currency/Gold -> { name="Cash", icon="Coin" }。
    游戏按 type/id 查询真实配置；查询缺失应明确报错，不返回上一奖励结果。
  可选 FormatReward(name: string, amount: number) -> string。
    默认返回已翻译的 名称 ×数量，保留原始数量；覆写也须返回最终展示文本。
    Coin 使用独立 +$金额节点，任务另有数量节点，不全部由此方法控制。
  必需 OnUIAction(action: string, payload: table)，无返回值；默认报错。
    Claim -> { kind: "online" | "signin" | "task", rewardId: string }；
      rewardId 对应该组 Item.id，不是 Item.reward.id。
    ClaimDiamonds -> { rewardId: string }；对应 Config.diamonds.rewardId。
    ClaimOffline -> { rewardId: string, multiplier: number }；
      rewardId 对应 Config.offline.rewardId，multiplier 仅为 1 或 2。
    没有 Close 或 SelectTab 动作；关闭直接 Hide，页签切换由 View 本地处理。
  无其他页面专用必需覆写；父类默认 GetUIConfig/GetUIState 已可读取上述数据。
  请求前将对应 Entry / diamonds / offline 的 pending=true、error=nil 并刷新；
  成功后 pending=false、status="Claimed"；离线还同步 seconds=0、training=0。
  失败 pending=false、保留最新真实数值及可重试状态，设置 error，再刷新。
  真实业务重新校验日期、批次、资格、倍数及领取幂等，并执行发放/持久化。
  钻石与离线状态跨打开/重建须保持当天真实结果，不能每次 Show 重置可领取；
  跨天由业务更新新一天完整状态。双倍离线未内置支付或广告流程。

【六、页签、列表与计时】
  每次 Show 默认 offline；当天 offline.status=Claimed 时隐藏离线页签，
  默认 diamonds；本次打开领取后保留当前页，下次 Show 才重新决定页签显隐。
  签到仅在 Show 时检查：非空组的全部配置项均 Claimed 才隐藏该页签；
  空组不算完成，不能只检查 signInDay 或最后一天状态。
  页签红点只读完整状态：存在配置项 Claimable 且非 pending 才显示；
  离线另要求 training>0；浏览不清红点，状态变化后 RefreshUI 更新。
  Templates 始终隐藏；分组首次访问时克隆，以 kind/Item.id 复用和清理。
  非当前分组不执行 SyncItems，配置增删在下次访问该分组时同步。
  运行期保持 groups 的 kind/page 及已存在条目的原型分档稳定：
  minutes/day 跨颜色档改变但 ID 不变时不会自动重建原型；featured 改变会重建。
  在线卡按 minutes <15 / <45 / <60 / >=60 分档；
  普通签到按 day <3 / <6 / >=6 分档，大签到使用独立双行原型。
  在线总进度取大于 onlineMinutes 的最小门槛，全部达成则用最大门槛；
  空组显示 No rewards；进度宽度截断，原始数据不变。
  无本地倒计时器，游戏须更新 onlineMinutes 并刷新，不能只初始化一次。

【七、资源边界】
  Coin 使用项目钞票图，Gem 使用设计钻石图，Egg 使用设计占位；
  GetRewardDisplay 返回 icon 类别不会加载真实道具图，返回额外图片字段也不消费。
  任务 EggIconBox.RewardIconImg、在线/签到 EggIconBox 的正式贴图
  尚无本 View 数据字段绑定；当前仍用原型占位，不承诺按 reward.id 自动替换。
  若需不同道具各自的图片，应另行实现明确图片绑定接口，不能仅填一个未读取字段。
  ScreenGui 实际名为 WelfareUI，现有类名 CWelfareView 不随文档目录改名。
  真实业务、资源权限及设备显示需在 Roblox 中另行验证。
]]
local FX = _G.FX
local Loader = FX.Loader
local Text = Loader:RequireShared("Scripts/Game/Shared/Text")
local CWelfareView = FX.Class("CWelfareView", "CUIView")

local TranslationTexts = Text.Define("WelfareHub", {
    Minutes = "{minutes} min",
    Day = "Day {day}",
    TaskProgress = "{current} / {target}",
    Locked = "Locked",
    Claiming = "Claiming...",
    CheckedIn = "Checked In",
    Claimed = "Claimed",
    Retry = "Retry",
    CheckIn = "Check In",
    Claim = "Claim",
    InProgress = "In Progress",
    Tomorrow = "Tomorrow",
    DaysUntil = "In {days:int} days",
    Countdown = "{minutes}:{seconds}",
    DiamondAmount = "×{amount} Diamonds",
    DiamondBonus = "+{amount} Diamonds",
    DiamondPerFriend = "+{amount} per friend",
    DiamondCap = "Up to +{amount} Diamonds",
    NoDiamonds = "No diamonds available today",
    ConfirmingReward = "Confirming your reward...",
    DiamondsClaimed = "Today's diamonds claimed · Come back tomorrow",
    ReadyToClaim = "Ready to claim",
    DailyLogin = "Daily Login · Day {day}",
    NoRewards = "No rewards",
    AllMilestones = "All milestones reached!",
    OnlineProgress = "{current} / {target} min",
    NoOnlineRewards = "No online rewards available",
    NextReward = "Next reward in {time}",
    AwayDuration = "You were away for {hours:int}h {minutes}m",
    ClaimRewards = "Claim Rewards!",
    DoubleRewards = "2× Rewards!",
    NoOfflineRewards = "No offline rewards",
    RewardAmount = "{name} ×{amount}",
    TaskQuantity = "x{amount:int}",
    MoneyAmount = "+${amount}",
    TrainingAmount = "+{amount}",
})

-- 局部条目只管理自身克隆与连接，不执行整屏适配。
local RewardRow = {}
RewardRow.__index = RewardRow

-- 绑定一个条目；点击时读取最新配置中的稳定业务 ID。
-- @param view table 所属页面
-- @param group table 分组配置
-- @param root Instance 页面创建的克隆节点
-- @return table 条目展示对象
function RewardRow.Attach(view, group, root)
    local row = setmetatable({ View = view, Kind = group.kind, Root = root }, RewardRow)
    row.Button = Loader:Here(root, "ClaimBtn")
    row.Connection = row.Button.Activated:Connect(function()
        view:EmitUIAction("Claim", { kind = row.Kind, rewardId = row.Config.id })
    end)
    return row
end

-- 使用项目查询结果展示奖励，按业务状态控制按钮，不判断真实领取资格。
-- @param config table 当前条目配置
-- @param state table 当前条目状态
function RewardRow:Update(config, state)
    self.Config = config
    local root = self.Root
    local display = self.View:GetRewardDisplay(config.reward)
    local rewardText = self.View:FormatReward(display.name, config.reward.amount)
    local isMoney = display.icon == "Coin"
    local moneyBox = Loader:Here(root, "MoneyRewardBox")
    moneyBox.Visible = isMoney
    Loader:Here(moneyBox, "AmountTxt").Text = Text.Tr(TranslationTexts.MoneyAmount, {
        amount = config.reward.amount,
    })
    local rewardLabel = Loader:Here(root, "RewardTxt")
    rewardLabel.Visible = not isMoney
    rewardLabel.Text = rewardText
    if self.Kind == "task" then
        Loader:Here(root, "QuantityTxt").Text = Text.Tr(TranslationTexts.TaskQuantity, {
            amount = config.reward.amount,
        })
        Loader:Here(root, "GemIconBox").Visible = display.icon == "Gem"
        Loader:Here(root, "EggIconBox").Visible = display.icon == "Egg"
        Loader:Here(root, "TaskNameTxt").Text = Text.TrSource(config.title)
        local bar = Loader:Here(root, "ProgressBarImg")
        local target = config.target
        local ratio = 0
        if target > 0 then
            ratio = math.clamp(state.current / target, 0, 1)
        end
        Loader:Here(bar, "ProgressFillImg").Size = UDim2.fromScale(ratio, 1)
        local progressTxt = Loader:Here(bar, "ProgressTxt")
        if target > 0 then
            progressTxt.Text = Text.Tr(TranslationTexts.TaskProgress, {
                current = state.current,
                target = target,
            })
        else
            progressTxt.Text = "—"
        end
    else
        local text
        if self.Kind == "online" then
            text = Text.Tr(TranslationTexts.Minutes, {
                minutes = config.minutes,
            })
        else
            text = Text.Tr(TranslationTexts.Day, {
                day = config.day,
            })
        end
        local timeTxt = Loader:Here(root, self.Kind == "online" and "TimeTxt" or "DayTxt")
        timeTxt.Text = text
        assert(display.icon == "Coin" or display.icon == "Gem" or display.icon == "Egg", "Unsupported reward icon: " .. tostring(display.icon))
        for _, icon in ipairs({ "Coin", "Gem", "Egg" }) do
            Loader:Here(root, icon .. "IconBox").Visible = display.icon == icon and not isMoney
        end
    end
    local label = Text.Tr(TranslationTexts.Locked)
    if state.pending then
        label = Text.Tr(TranslationTexts.Claiming)
    elseif state.status == "Claimed" then
        if self.Kind == "signin" then
            label = Text.Tr(TranslationTexts.CheckedIn)
        else
            label = Text.Tr(TranslationTexts.Claimed)
        end
    elseif state.status == "Claimable" then
        if state.error then
            label = Text.Tr(TranslationTexts.Retry)
        elseif self.Kind == "signin" then
            label = Text.Tr(TranslationTexts.CheckIn)
        else
            label = Text.Tr(TranslationTexts.Claim)
        end
    elseif state.status == "Locked" then
        if state.label then
            label = Text.TrSource(state.label)
        elseif self.Kind == "task" then
            label = Text.Tr(TranslationTexts.InProgress)
        end
        if self.Kind == "online" and not state.label then
            local seconds = math.max(0, math.ceil((config.minutes - self.View:GetUIState().onlineMinutes) * 60))
            label = Text.Tr(TranslationTexts.Countdown, {
                minutes = string.format("%02d", math.floor(seconds / 60)),
                seconds = string.format("%02d", seconds % 60),
            })
        elseif self.Kind == "signin" and not state.label then
            local days = config.day - self.View:GetUIState().signInDay
            if days == 1 then
                label = Text.Tr(TranslationTexts.Tomorrow)
            elseif days > 1 then
                label = Text.Tr(TranslationTexts.DaysUntil, {
                    days = days,
                })
            end
        end
    else
        error("Unknown reward status: " .. tostring(state.status))
    end
    self.View:RenderButton(self.Button, label, state.status == "Claimable" and not state.pending)
    if self.Kind == "online" or self.Kind == "signin" then
        local claimed = state.status == "Claimed"
        local claimable = state.status == "Claimable" and not state.pending
        Loader:Here(root, "ClaimedTxt").Visible = claimed
        local isGrand = config.featured == true
        if self.Kind == "online" then
            isGrand = config.minutes >= 60
            Loader:Here(root, "BadgeTxt").Visible = isGrand and not claimed
        end
        local stroke = Loader:Here(root, "UIStroke")
        stroke.Color = Color3.fromRGB(15, 29, 36)
        stroke.Thickness = 2
        if isGrand then
            stroke.Color = Color3.fromRGB(255, 207, 101)
            stroke.Thickness = 3
        end
        if claimable then
            stroke.Color = Color3.fromRGB(145, 255, 90)
            stroke.Thickness = 3
        elseif claimed then
            self.Button.BackgroundColor3 = Color3.fromRGB(84, 100, 105)
            Loader:Here(self.Button, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(36, 48, 54)
        else
            self.Button.BackgroundColor3 = Color3.fromRGB(63, 91, 112)
            Loader:Here(self.Button, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(25, 46, 63)
        end
    end
end

-- 释放条目拥有的事件与克隆根；不删除页面设计模板。
function RewardRow:Destroy()
    self.Connection:Disconnect()
    self.Root:Destroy()
end

-- 绑定设计节点；页签和关闭由展示层维护，不发送业务请求。
function CWelfareView:OnReady()
    self.Root = Loader:PlayerGui("WelfareUI")
    -- 仅关闭主动翻译的具体动态文本；原型克隆继承设置，静态节点保持自动本地化。
    self.Rows = {}
    self.ActiveTab = "offline"
    local tabs = { { "offline", "OfflineTabBtn" }, { "diamonds", "DiamondsTabBtn" }, { "signin", "SignInTabBtn" }, { "online", "OnlineTabBtn" }, { "task", "TasksTabBtn" } }
    for _, tab in ipairs(tabs) do
        self:TrackConnection(Loader:Here(self.Root, "TabsBox." .. tab[2]).Activated:Connect(function()
            self.ActiveTab = tab[1]
            self:RefreshUI()
        end))
    end
    for multiplier, name in ipairs({ "SingleClaimBtn", "DoubleClaimBtn" }) do
        local button = Loader:Here(self.Root, "PopupPanelImg.OfflineBox." .. name)
        self:TrackConnection(button.Activated:Connect(function()
            -- 单倍与双倍领取使用同一稳定批次 ID，业务层确认倍数资格。
            self:EmitUIAction("ClaimOffline", {
                rewardId = self:GetUIConfig().offline.rewardId,
                multiplier = multiplier,
            })
        end))
    end
    self:TrackConnection(Loader:Here(self.Root, "PopupPanelImg.DiamondsBox.ClaimBtn").Activated:Connect(function()
        -- 点击发送稳定奖励 ID，数量与资格由业务层确认。
        self:EmitUIAction("ClaimDiamonds", { rewardId = self:GetUIConfig().diamonds.rewardId })
    end))
    self:TrackConnection(Loader:Here(self.Root, "TitleBox.CloseSurfaceImg").Activated:Connect(function()
        self:Hide()
    end))
end

-- 打开时确定本次页签显隐；领取后的刷新保留当前页，下次打开才隐藏。
function CWelfareView:OnShow()
    local state = self:GetUIState()
    local showOffline = state.offline.status ~= "Claimed"
    Loader:Here(self.Root, "TabsBox.OfflineTabBtn").Visible = showOffline
    local allSignInClaimed = false
    for _, group in ipairs(self:GetUIConfig().groups) do
        if group.kind == "signin" then
            allSignInClaimed = #group.items > 0
            for _, config in ipairs(group.items) do
                local entry = assert(state.entries.signin[config.id], "Missing sign-in state: " .. config.id)
                if entry.status ~= "Claimed" then
                    allSignInClaimed = false
                    break
                end
            end
        end
    end
    Loader:Here(self.Root, "TabsBox.SignInTabBtn").Visible = not allSignInClaimed
    self.ActiveTab = "offline"
    if not showOffline then
        self.ActiveTab = "diamonds"
    end
    self:RefreshUI()
end

-- 游戏接入必须提供奖励展示查询。
-- @param reward table 原始奖励类型、ID 与数量
-- @return table name 和当前模板支持的 icon（Coin/Gem/Egg）
function CWelfareView:GetRewardDisplay(reward)
    error("Welfare integration must implement GetRewardDisplay")
end

-- 可选覆写的数量显示格式，不修改原始奖励数据；name 为配置原文，返回已翻译文本。
-- @param name string 奖励名称
-- @param amount number 原始数量
-- @return string 显示文本
function CWelfareView:FormatReward(name, amount)
    return Text.Tr(TranslationTexts.RewardAmount, {
        name = Text.TrSource(name),
        amount = amount,
    })
end

-- 领取动作必须由游戏接入实现。
-- @param action string Claim、ClaimDiamonds 或 ClaimOffline
-- @param payload table Claim 为 kind/rewardId；钻石为 rewardId；离线为 rewardId/multiplier，见文件头
function CWelfareView:OnUIAction(action, payload)
    error("Welfare integration must implement OnUIAction")
end

-- 按稳定 ID 增删、排序和更新条目；未变化条目保留节点与连接。
-- @param group table 分组、布局和有序条目
-- @param states table 以业务 ID 索引的展示状态
function CWelfareView:SyncItems(group, states)
    local page = Loader:Here(self.Root, "PopupPanelImg." .. group.page)
    local template = Loader:Here(self.Root, "Templates." .. group.page .. "TemplateImg")
    local container = Loader:Here(page, "ItemsBox")
    template.Visible = false
    local rows = self.Rows[group.kind] or {}
    self.Rows[group.kind] = rows
    local keep = {}
    local width, height = template.Size.X.Offset, template.Size.Y.Offset
    local normalIndex, bottom = 0, 0
    for index, config in ipairs(group.items) do
        assert(not keep[config.id], "Duplicate reward ID: " .. config.id)
        keep[config.id] = true
        local row = rows[config.id]
        if row and row.Featured ~= (config.featured == true) then
            row.Release()
            rows[config.id] = nil
            row = nil
        end
        if not row then
            local itemTemplate = template
            if group.kind == "online" then
                local templateName = "OnlineBoxTemplateImg"
                if config.minutes >= 60 then
                    templateName = "OnlineGrandTemplateImg"
                elseif config.minutes >= 45 then
                    templateName = "OnlinePurpleTemplateImg"
                elseif config.minutes >= 15 then
                    templateName = "OnlineBlueTemplateImg"
                end
                itemTemplate = Loader:Here(self.Root, "Templates." .. templateName)
            elseif group.kind == "signin" then
                local templateName = "SignInBoxTemplateImg"
                if config.featured then
                    templateName = "SignInGrandTemplateImg"
                elseif config.day >= 6 then
                    templateName = "SignInPurpleTemplateImg"
                elseif config.day >= 3 then
                    templateName = "SignInBlueTemplateImg"
                end
                itemTemplate = Loader:Here(self.Root, "Templates." .. templateName)
            end
            local root = itemTemplate:Clone()
            root.Name = "Item_" .. config.id .. "Img"
            root.Parent = container
            root.Visible = true
            row = RewardRow.Attach(self, group, root)
            row.Featured = config.featured == true
            row.Release = self:TrackCleanup(function()
                row:Destroy()
            end)
            rows[config.id] = row
        end
        local root = row.Root
        local x = (normalIndex % group.columns) * (width + group.gapX)
        local y = math.floor(normalIndex / group.columns) * (height + group.gapY)
        if config.featured then
            x, y = group.columns * (width + group.gapX), 0
            root.Size = UDim2.fromOffset(width, height * 2 + group.gapY)
            self:StyleFeatured(root, config)
        else
            normalIndex = normalIndex + 1
        end
        root.Position = UDim2.fromOffset(x + 2, y + 2)
        root.LayoutOrder = index
        bottom = math.max(bottom, y + root.Size.Y.Offset)
        row:Update(config, assert(states[config.id], "Missing reward state: " .. group.kind .. "/" .. config.id))
    end
    for id, row in pairs(rows) do
        if not keep[id] then
            row.Release()
            rows[id] = nil
        end
    end
    container.CanvasSize = UDim2.fromOffset(container.Size.X.Offset - container.ScrollBarThickness, bottom + 4)
    local maxScroll = math.max(0, bottom + 4 - container.Size.Y.Offset)
    container.CanvasPosition = Vector2.new(0, math.min(container.CanvasPosition.Y, maxScroll))
end

-- 大奖布局保存在独立设计原型，只更新配置指定的颜色与标记。
-- @param row Instance 克隆条目
-- @param config table 大奖外观配置
function CWelfareView:StyleFeatured(row, config)
    row.BackgroundColor3 = Color3.fromRGB(config.color[1], config.color[2], config.color[3])
    local label = Loader:Here(row, "WeeklyTxt")
    label.Visible, label.Text = true, Text.TrSource(config.badge)
end

-- 保留风格按钮表面，只更新状态。
-- @param button Instance 点击节点
-- @param label string? 已翻译的动态文字；nil 保留静态节点文案
-- @param enabled boolean 是否允许操作
function CWelfareView:RenderButton(button, label, enabled)
    self:SetButtonEnabled(button, enabled)
    button.BackgroundColor3 = enabled and Color3.fromRGB(103, 237, 20) or Color3.fromRGB(99, 128, 121)
    local buttonTxt = Loader:Here(button, "ButtonTxt")

    if label then
        buttonTxt.Text = label
    end
    Loader:Here(button, "BottomEdgeImg").BackgroundColor3 = enabled and Color3.fromRGB(34, 90, 7) or Color3.fromRGB(38, 62, 54)
end

-- 每日钻石使用服务端完整状态；说明卡不参与奖励结算。
-- @param state table amount、status 及可选 pending/error
function CWelfareView:RenderDiamonds(state)
    local config = self:GetUIConfig().diamonds
    local page = Loader:Here(self.Root, "PopupPanelImg.DiamondsBox")
    page.Visible = self.ActiveTab == "diamonds"
    local amountTxt = Loader:Here(page, "AmountTxt")
    local loginAmountTxt = Loader:Here(page, "LoginBonusImg.AmountTxt")
    local premiumAmountTxt = Loader:Here(page, "PremiumBonusImg.AmountTxt")
    local friendAmountTxt = Loader:Here(page, "FriendsBonusImg.AmountTxt")
    local friendHintTxt = Loader:Here(page, "FriendsBonusImg.HintTxt")
    local statusTxt = Loader:Here(page, "StatusTxt")
    amountTxt.Text = Text.Tr(TranslationTexts.DiamondAmount, {
        amount = state.amount,
    })
    loginAmountTxt.Text = Text.Tr(TranslationTexts.DiamondBonus, {
        amount = config.loginAmount,
    })
    premiumAmountTxt.Text = Text.Tr(TranslationTexts.DiamondBonus, {
        amount = config.premiumAmount,
    })
    friendAmountTxt.Text = Text.Tr(TranslationTexts.DiamondPerFriend, {
        amount = config.friendAmount,
    })
    friendHintTxt.Text = Text.Tr(TranslationTexts.DiamondCap, {
        amount = config.friendCap,
    })
    local label = Text.Tr(TranslationTexts.Locked)
    local hint = Text.Tr(TranslationTexts.NoDiamonds)
    if state.pending then
        label = Text.Tr(TranslationTexts.Claiming)
        hint = Text.Tr(TranslationTexts.ConfirmingReward)
    elseif state.status == "Claimed" then
        label = Text.Tr(TranslationTexts.Claimed)
        hint = Text.Tr(TranslationTexts.DiamondsClaimed)
    elseif state.status == "Claimable" then
        label = Text.Tr(TranslationTexts.Claim)
        hint = Text.Tr(TranslationTexts.ReadyToClaim)
        if state.error then
            label = Text.Tr(TranslationTexts.Retry)
            hint = Text.TrSource(state.error)
        end
    elseif state.status ~= "Locked" then
        error("Unknown diamond status: " .. tostring(state.status))
    end
    statusTxt.Text = hint
    self:RenderButton(Loader:Here(page, "ClaimBtn"), label, state.status == "Claimable" and not state.pending)
    local tab = Loader:Here(self.Root, "TabsBox.DiamondsTabBtn")
    Loader:Here(tab, "RedDotImg").Visible = state.status == "Claimable" and not state.pending
    self:RenderButton(tab, nil, true)
    if self.ActiveTab ~= "diamonds" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        Loader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

-- 接入提供状态，View 只组织页面和条目展示，不改根节点的显隐。
-- @param state table 完整 State：offline、diamonds、entries、onlineMinutes、signInDay，见文件头
function CWelfareView:Render(state)
    self:RenderOffline(state.offline)
    self:RenderDiamonds(state.diamonds)
    local tabs = { online = "OnlineTabBtn", signin = "SignInTabBtn", task = "TasksTabBtn" }
    for _, group in ipairs(self:GetUIConfig().groups) do
        Loader:Here(self.Root, "PopupPanelImg." .. group.page).Visible = self.ActiveTab == group.kind
        local button = Loader:Here(self.Root, "TabsBox." .. tabs[group.kind])
        local hasClaimable = false
        local entries = assert(state.entries[group.kind], "Missing group state: " .. group.kind)
        for _, config in ipairs(group.items) do
            local entry = assert(entries[config.id], "Missing reward state: " .. group.kind .. "/" .. config.id)
            if entry.status == "Claimable" and not entry.pending then
                hasClaimable = true
                break
            end
        end
        Loader:Here(button, "RedDotImg").Visible = hasClaimable
        self:RenderButton(button, nil, true)
        if self.ActiveTab ~= group.kind then
            button.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
            Loader:Here(button, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
        end
        if self.ActiveTab == group.kind then
            self:SyncItems(group, assert(state.entries[group.kind], "Missing group state: " .. group.kind))
        end
    end
    for _, group in ipairs(self:GetUIConfig().groups) do
        if group.kind == "online" then
            self:RenderOnlineProgress(group, state)
        end
    end
    local signInHeadingTxt = Loader:Here(self.Root, "PopupPanelImg.SignInBox.HeadingTxt")
    signInHeadingTxt.Text = Text.Tr(TranslationTexts.DailyLogin, {
        day = state.signInDay,
    })
end

-- 下一档按分钟阈值查询，不依赖配置顺序；空组与全部达成都有明确展示。
-- @param group table 在线奖励配置分组
-- @param state table 完整福利状态，onlineMinutes 单位为分钟
function CWelfareView:RenderOnlineProgress(group, state)
    local page = Loader:Here(self.Root, "PopupPanelImg.OnlineBox")
    local bar = Loader:Here(page, "ProgressBarImg")
    local nextMinutes = nil
    local lastMinutes = 0
    for _, config in ipairs(group.items) do
        lastMinutes = math.max(lastMinutes, config.minutes)
        if config.minutes > state.onlineMinutes and (not nextMinutes or config.minutes < nextMinutes) then
            nextMinutes = config.minutes
        end
    end
    local target = nextMinutes or lastMinutes
    local ratio = 0
    if target > 0 then
        ratio = math.clamp(state.onlineMinutes / target, 0, 1)
    end
    Loader:Here(bar, "ProgressFillImg").Size = UDim2.fromScale(ratio, 1)
    local progress = Text.Tr(TranslationTexts.NoRewards)
    local hint = Text.Tr(TranslationTexts.AllMilestones)
    if target > 0 then
        progress = Text.Tr(TranslationTexts.OnlineProgress, {
            current = math.floor(state.onlineMinutes),
            target = target,
        })
    else
        hint = Text.Tr(TranslationTexts.NoOnlineRewards)
    end
    if nextMinutes then
        local seconds = math.max(0, math.ceil((nextMinutes - state.onlineMinutes) * 60))
        hint = Text.Tr(TranslationTexts.NextReward, {
            time = string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60),
        })
    end
    local progressTxt = Loader:Here(bar, "ProgressTxt")
    local subtitleTxt = Loader:Here(page, "SubtitleTxt")
    progressTxt.Text = progress
    subtitleTxt.Text = hint
end

-- 离线奖励只展示业务状态；领取后显示零值并隐藏按钮，不修改业务数据或在线时长。
-- @param state table State.offline：seconds、training、status 及可选 pending/error，见文件头
function CWelfareView:RenderOffline(state)
    local page = Loader:Here(self.Root, "PopupPanelImg.OfflineBox")
    page.Visible = self.ActiveTab == "offline"
    local seconds = state.seconds
    local training = state.training
    if state.status == "Claimed" then
        seconds = 0
        training = 0
    end
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    local timeTxt = Loader:Here(page, "TimeTxt")
    timeTxt.Text = Text.Tr(TranslationTexts.AwayDuration, {
        hours = hours,
        minutes = string.format("%02d", minutes),
    })
    Loader:Here(page, "AmountTxt").Text = Text.Tr(TranslationTexts.TrainingAmount, {
        amount = training,
    })
    local claimable = state.status == "Claimable" and training > 0
    local single = Loader:Here(page, "SingleClaimBtn")
    local double = Loader:Here(page, "DoubleClaimBtn")
    single.Visible = claimable
    double.Visible = claimable
    self:RenderButton(single, Text.Tr(TranslationTexts.ClaimRewards), claimable and not state.pending)
    self:RenderButton(double, Text.Tr(TranslationTexts.DoubleRewards), claimable and not state.pending)
    if claimable and not state.pending then
        single.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        double.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Loader:Here(double, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(176, 101, 0)
    end
    local status = Loader:Here(page, "StatusTxt")
    status.Visible = not claimable or state.error ~= nil
    status.Text = state.error and Text.TrSource(state.error) or Text.Tr(TranslationTexts.NoOfflineRewards)
    if state.status == "Claimed" then
        status.Text = Text.Tr(TranslationTexts.Claimed)
    end
    local tab = Loader:Here(self.Root, "TabsBox.OfflineTabBtn")
    Loader:Here(tab, "RedDotImg").Visible = claimable and not state.pending
    self:RenderButton(tab, nil, true)
    if self.ActiveTab ~= "offline" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        Loader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

return CWelfareView
