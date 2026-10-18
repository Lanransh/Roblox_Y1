-- 左侧页签单选；每次 Show 默认 offline，当天已领取则选 diamonds。红点读取完整状态。
-- 仅配置内存在 status="Claimable" 且 pending 不为 true 的奖励时显示；
-- 已领取、锁定、空组与请求中不显示。浏览页签不清除红点，状态变化后 RefreshUI 更新。
--[[
每日钻石子页补充契约：
Config.diamonds 必填（无默认值）：
  rewardId: string，稳定每日奖励业务 ID；
  loginAmount / premiumAmount / friendAmount / friendCap: number，单位钻石，
  分别为登录奖励、会员加成、每位好友加成及好友加成上限，仅用于说明。
State.diamonds 必填完整状态（无默认值）：
  amount: number，服务端确认的本日可领取钻石数量，View 不计算资格或叠加加成；
  status: "Locked" | "Claimable" | "Claimed"；
  pending: boolean 可选，缺省 false；error: string 可选，缺省 nil。
  pending 禁用按钮；失败时显示 error 并在 Claimable 下允许重试。
最小数据示例（与原有 groups / entries 同时提供）：
self.Config.diamonds = {
    rewardId = "daily_diamonds", loginAmount = 100, premiumAmount = 50,
    friendAmount = 10, friendCap = 100,
}
self.State.diamonds = { amount = 250, status = "Claimable" }
动作 ClaimDiamonds，payload = { rewardId: string }，对应 Config.diamonds.rewardId。
原 OnUIAction 必需覆写现在也须处理该动作，返回值无；
真实业务负责每日重置、资格校验、发奖及 pending/成功/失败刷新。
OnReady 先调父方法，再 BindUIData、Show；数据更新后 RefreshUI。
固定说明卡直接更新已有节点，不克隆；不新增图片占位。
]]

--[[
福利界面接入契约（完整状态刷新，非增量）
Config.groups: 必填有序数组，含 online/signin/task 三组；items 数量可变，允许空数组。
每组必填 kind: "online" | "signin" | "task"，分别对应 page:
"OnlineBox" / "SignInBox" / "TasksBox"；columns: 正整数列数（task 为 1）；
gapX/gapY: number，条目间距，单位像素；items: 有序配置数组。
items 每项必填 id: string，组内唯一稳定奖励/任务 ID；
reward: { type: string, id: string, amount: number }，游戏奖励类型、物品 ID 和数量。
online 项必填 minutes: number（分钟）；signin 项必填 day: number（天序号）；
task 项必填 title: string、target: number（目标，<=0 显示空进度）。
signin 项可选 featured: boolean，默认 false；true 时必填 badge: string、
color: {number, number, number}（RGB 0–255），显示双行大奖。
previewValue: number 仅模拟层读取，缺省 0，不属于游戏必需配置。

State 必填 onlineMinutes: number（分钟）、signInDay: number（当前签到天）、
entries: 按 kind 再按 Config.items.id 索引的字典；
entries[kind][id] 必填 status: "Locked" | "Claimable" | "Claimed"；
task 项必填 current: number，单位与 target 相同。
可选 pending: boolean（缺省 false）、error: string（缺省 nil，可领取时显示 Retry）、
label: string（缺省 nil，Locked 时自定义按钮文字）。
空组使用 items={}、entries[kind]={}；缺失配置对应状态会报错，不自动补齐。
登录奖励页签仅在打开时判断：非空 signin 配置的全部条目状态均为 Claimed
才隐藏（7 日配置对应全部 7 天已领取），不能只用 signInDay 或第 7 天判断。
本次打开期间完成最后一次签到仍保留页签，下次 Show 才隐藏；空组不算已签完。
接入层提供并保存每个配置 ID 的领取状态，列表自动补位，不新增完成标记字段。
Templates 永远隐藏；首次访问页签才克隆该页，按 ID 更新、移除及排序；
任务数量不固定，CanvasSize 随实际内容计算，超出视口垂直滚动。

初始化：接入 Ctor 先调父构造，再准备 Config/State；OnReady 先调父 OnReady，
再 BindUIData()、Show()。GetUIConfig/GetUIState 默认读取 self.Config/self.State；
数据变化后 self:RefreshUI()，Render 只读数据。异步加载完成前不 Show。
最小完整示例：
self.Config = { groups = {
    { kind="online", page="OnlineBox", columns=3, gapX=20, gapY=16, items={} },
    { kind="signin", page="SignInBox", columns=3, gapX=12, gapY=16, items={} },
    { kind="task", page="TasksBox", columns=1, gapX=0, gapY=12, items={
        { id="collect", title="Collect Cash", target=100,
          reward={ type="Currency", id="Gold", amount=20 } }
    } }
} }
self.State = { onlineMinutes=0, signInDay=1, entries={
    online={}, signin={}, task={ collect={ status="Claimable", current=100 } }
} }

必需覆写 GetRewardDisplay(reward)，返回 {name: string, icon: "Coin"|"Gem"|"Egg"}；
Coin 类奖励使用项目钞票图片与 +$金额；Gem/Egg 图标仍为几何占位，不作为物品身份。
必需覆写 OnUIAction(action, payload)，无返回值：
action="Claim"，payload={kind: string, rewardId: string}，rewardId 对应 items.id。
资格校验及发奖由游戏接入负责；请求期间 pending=true，成功改 Claimed，
失败保留 Claimable 并设置 error；每次更新后 RefreshUI。
可选覆写 FormatReward(name, amount)，默认返回名称与原始数量。
模拟接入仅更新模拟状态，不实际发奖。
]]
--[[
离线奖励补充契约（与现有 Config/State 同时提供）：
Config.offline.rewardId: string，必填，稳定离线奖励批次业务 ID，无默认值。
State.offline: 必填完整状态；seconds: number，离线秒数；training: number，
可领基础训练值；status: "Locked" | "Claimable" | "Claimed"，均必填。
pending: boolean 可选，缺省 false；error: string 可选，缺省 nil。
Claimed 时显示离线时间 0s、训练值 0，隐藏两种领取按钮；
status 表示当天状态：仅在每次 Show 时根据 Claimed 隐藏整个离线页签，
后续页签由列表自动补位；本次打开期间领取成功不隐藏页签、不切换页面。
接入层须持久保存当天领取结果，重新创建界面或重新登录时先读取当天状态，
不可在每次打开时重置为 Claimable；跨天由游戏业务更新为新一天的完整状态。
当天已领取时再次 Show 默认选钻石；当前离线页领取成功仍保留零值展示。
Locked 或无训练值时也隐藏按钮，pending 时禁用，失败显示 error 并允许重试。
示例：self.Config.offline = { rewardId = "offline_session_1" }
self.State.offline = { seconds = 9000, training = 1500, status = "Claimable" }
首次 Show 前准备数据；接入层更新完整 State 后 RefreshUI，不由 View 计算奖励。
必需 OnUIAction 新增 ClaimOffline，无返回值；payload = {
  rewardId: string，与 Config.offline.rewardId 对应；multiplier: number，只能为 1 或 2。
}
游戏接入负责校验批次、倍数资格及发奖；请求前 pending=true，成功后
seconds=0、training=0、status="Claimed"、pending=false，再 RefreshUI。
失败保留数值及 Claimable，pending=false、error=提示后刷新。
模拟立即成功，双倍仅模拟两倍训练值；没有添加支付或广告流程。
]]
local FX = _G.FX
local Loader = FX.Loader
local CWelfareView = FX.Class("CWelfareView", "CUIView")

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
    Loader:Here(moneyBox, "AmountTxt").Text = "+$" .. tostring(config.reward.amount)
    local rewardLabel = Loader:Here(root, "RewardTxt")
    rewardLabel.Visible = not isMoney
    rewardLabel.Text = self.Kind == "task" and ("Reward: " .. rewardText) or rewardText
    if self.Kind == "task" then
        Loader:Here(root, "TaskNameTxt").Text = config.title
        local bar = Loader:Here(root, "ProgressBarImg")
        local target = config.target
        local ratio = 0
        if target > 0 then
            ratio = math.clamp(state.current / target, 0, 1)
        end
        Loader:Here(bar, "ProgressFillImg").Size = UDim2.fromScale(ratio, 1)
        Loader:Here(bar, "ProgressTxt").Text = target > 0 and (state.current .. " / " .. target) or "—"
    else
        local text = self.Kind == "online" and (config.minutes .. " min") or ("Day " .. config.day)
        Loader:Here(root, self.Kind == "online" and "TimeTxt" or "DayTxt").Text = text
        assert(display.icon == "Coin" or display.icon == "Gem" or display.icon == "Egg", "Unsupported reward icon: " .. tostring(display.icon))
        for _, icon in ipairs({ "Coin", "Gem", "Egg" }) do
            Loader:Here(root, icon .. "IconBox").Visible = display.icon == icon and not isMoney
        end
    end
    local label = "Locked"
    if state.pending then
        label = "Claiming..."
    elseif state.status == "Claimed" then
        label = self.Kind == "signin" and "Checked In" or "Claimed"
    elseif state.status == "Claimable" then
        label = state.error and "Retry" or (self.Kind == "signin" and "Check In" or "Claim")
    elseif state.status == "Locked" then
        label = state.label or (self.Kind == "task" and "In Progress" or "Locked")
    else
        error("Unknown reward status: " .. tostring(state.status))
    end
    self.View:RenderButton(self.Button, label, state.status == "Claimable" and not state.pending)
end

-- 释放条目拥有的事件与克隆根；不删除页面设计模板。
function RewardRow:Destroy()
    self.Connection:Disconnect()
    self.Root:Destroy()
end

-- 绑定设计节点；页签和关闭由展示层维护，不发送业务请求。
function CWelfareView:OnReady()
    self.Root = Loader:PlayerGui("WelfareUI")
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

-- 游戏与模拟接入都必须提供奖励展示查询。
-- @param reward table 原始奖励类型、ID 与数量
-- @return table name 和当前模板支持的 icon（Coin/Gem/Egg）
function CWelfareView:GetRewardDisplay(reward)
    error("Welfare integration must implement GetRewardDisplay")
end

-- 可选覆写的数量显示格式，不修改原始奖励数据。
-- @param name string 奖励名称
-- @param amount number 原始数量
-- @return string 显示文本
function CWelfareView:FormatReward(name, amount)
    return name .. " ×" .. tostring(amount)
end

-- 领取动作必须由游戏或模拟接入实现。
-- @param action string 动作名称
-- @param payload table kind 和 rewardId
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
            local root = template:Clone()
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

-- 沿用设计模板的双行大奖布局。
-- @param row Instance 克隆条目
-- @param config table 大奖外观配置
function CWelfareView:StyleFeatured(row, config)
    row.BackgroundColor3 = Color3.fromRGB(config.color[1], config.color[2], config.color[3])
    local label = Loader:Here(row, "WeeklyTxt")
    label.Visible, label.Text = true, config.badge
    local width = row.Size.X.Offset
    for _, iconType in ipairs({ "Coin", "Gem", "Egg" }) do
        local box = Loader:Here(row, iconType .. "IconBox")
        local icon = Loader:Here(box, "RewardIconImg")
        icon.Position = UDim2.fromOffset((width - 112) / 2, 84)
        icon.Size = UDim2.fromOffset(112, 112)
        for _, child in ipairs(box:GetChildren()) do
            if child.Name == "IconMarkTxt" then
                child.Position, child.Size = icon.Position, icon.Size
            end
        end
    end
    Loader:Here(row, "MoneyRewardBox").Position = UDim2.fromOffset(0, 208)
    local reward = Loader:Here(row, "RewardTxt")
    reward.Position, reward.Size = UDim2.fromOffset(0, 208), UDim2.fromOffset(width, 48)
    local button = Loader:Here(row, "ClaimBtn")
    button.Position = UDim2.fromOffset(button.Position.X.Offset, row.Size.Y.Offset - 48)
end

-- 保留风格按钮表面，只更新状态。
-- @param button Instance 点击节点
-- @param label string 显示文字
-- @param enabled boolean 是否允许操作
function CWelfareView:RenderButton(button, label, enabled)
    self:SetButtonEnabled(button, enabled)
    button.BackgroundColor3 = enabled and Color3.fromRGB(103, 237, 20) or Color3.fromRGB(99, 128, 121)
    Loader:Here(button, "ButtonTxt").Text = label
    Loader:Here(button, "BottomEdgeImg").BackgroundColor3 = enabled and Color3.fromRGB(34, 90, 7) or Color3.fromRGB(38, 62, 54)
end

-- 每日钻石使用服务端完整状态；说明卡不参与奖励结算。
-- @param state table amount、status 及可选 pending/error
function CWelfareView:RenderDiamonds(state)
    local config = self:GetUIConfig().diamonds
    local page = Loader:Here(self.Root, "PopupPanelImg.DiamondsBox")
    page.Visible = self.ActiveTab == "diamonds"
    Loader:Here(page, "AmountTxt").Text = "×" .. tostring(state.amount) .. " Diamonds"
    Loader:Here(page, "LoginBonusImg.AmountTxt").Text = "+" .. tostring(config.loginAmount) .. " Diamonds"
    Loader:Here(page, "PremiumBonusImg.AmountTxt").Text = "+" .. tostring(config.premiumAmount) .. " Diamonds"
    Loader:Here(page, "FriendsBonusImg.AmountTxt").Text = "+" .. tostring(config.friendAmount) .. " per friend"
    Loader:Here(page, "FriendsBonusImg.HintTxt").Text = "Up to +" .. tostring(config.friendCap) .. " Diamonds"
    local label = "Locked"
    local hint = "No diamonds available today"
    if state.pending then
        label = "Claiming..."
        hint = "Confirming your reward..."
    elseif state.status == "Claimed" then
        label = "Claimed"
        hint = "Today's diamonds claimed · Come back tomorrow"
    elseif state.status == "Claimable" then
        label = "Claim"
        hint = "Ready to claim"
        if state.error then
            label = "Retry"
            hint = state.error
        end
    elseif state.status ~= "Locked" then
        error("Unknown diamond status: " .. tostring(state.status))
    end
    Loader:Here(page, "StatusTxt").Text = hint
    self:RenderButton(Loader:Here(page, "ClaimBtn"), label, state.status == "Claimable" and not state.pending)
    local tab = Loader:Here(self.Root, "TabsBox.DiamondsTabBtn")
    Loader:Here(tab, "RedDotImg").Visible = state.status == "Claimable" and not state.pending
    self:RenderButton(tab, "Diamonds", true)
    if self.ActiveTab ~= "diamonds" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        Loader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

-- 接入提供状态，View 只组织页面和条目展示，不改根节点的显隐。
-- @param state table entries、onlineMinutes 与 signInDay
function CWelfareView:Render(state)
    self:RenderOffline(state.offline)
    self:RenderDiamonds(state.diamonds)
    local tabs = { online = "OnlineTabBtn", signin = "SignInTabBtn", task = "TasksTabBtn" }
    local labels = { online = "Online\nRewards", signin = "Daily Login", task = "Tasks" }
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
        self:RenderButton(button, labels[group.kind], true)
        if self.ActiveTab ~= group.kind then
            button.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
            Loader:Here(button, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
        end
        if self.ActiveTab == group.kind then
            self:SyncItems(group, assert(state.entries[group.kind], "Missing group state: " .. group.kind))
        end
    end
    Loader:Here(self.Root, "PopupPanelImg.OnlineBox.SubtitleTxt").Text = "Online: " .. state.onlineMinutes .. " min · Resets daily"
    Loader:Here(self.Root, "PopupPanelImg.SignInBox.HeadingTxt").Text = "Daily Login · Day " .. state.signInDay
end

-- 离线奖励只展示业务状态；领取后清零并隐藏按钮，不重置在线时长。
-- @param state table seconds、training、status 及可选 pending/error，见离线契约
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
    Loader:Here(page, "TimeTxt").Text = string.format("You were away for %dh %02dm", hours, minutes)
    Loader:Here(page, "AmountTxt").Text = "+" .. tostring(training)
    local claimable = state.status == "Claimable" and training > 0
    local single = Loader:Here(page, "SingleClaimBtn")
    local double = Loader:Here(page, "DoubleClaimBtn")
    single.Visible = claimable
    double.Visible = claimable
    self:RenderButton(single, "Claim Rewards!", claimable and not state.pending)
    self:RenderButton(double, "2× Rewards!", claimable and not state.pending)
    if claimable and not state.pending then
        single.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        double.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Loader:Here(double, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(176, 101, 0)
    end
    local status = Loader:Here(page, "StatusTxt")
    status.Visible = not claimable or state.error ~= nil
    status.Text = state.error or "No offline rewards"
    if state.status == "Claimed" then
        status.Text = "Claimed"
    end
    local tab = Loader:Here(self.Root, "TabsBox.OfflineTabBtn")
    Loader:Here(tab, "RedDotImg").Visible = claimable and not state.pending
    self:RenderButton(tab, "Offline\nRewards", true)
    if self.ActiveTab ~= "offline" then
        tab.BackgroundColor3 = Color3.fromRGB(99, 128, 121)
        Loader:Here(tab, "BottomEdgeImg").BackgroundColor3 = Color3.fromRGB(38, 62, 54)
    end
end

return CWelfareView
