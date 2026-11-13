-- Roblox 系统菜单背后的一次性挽留礼包，由服务端永久记录领取状态。
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local TranslationTexts = Text.Define("MenuRetention", {
    GiftTitle = "Don't leave yet! A gift is ready for you!",
    GiftHint = "Close the Roblox menu to claim your gift.",
    OnlineCountdown = "Your next online reward is available in {time}!",
    Unknown = "Something went wrong. Please try again.",
    Diamonds = "{value} Diamonds",
    ItemReward = "{item} ×{value}",
    Pending = "Claiming...",
    Claim = "Claim",
    Offline = "You can earn up to {amount} Strength while offline!",
    Complete = "You have claimed all of today's online rewards!",
    Ready = "Your online reward is ready to claim!",
})
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIGuideArrow = FXLoader:RequireFromParent(script, "UIGuideArrow")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Welfare = FXLoader:RequireShared("Scripts/Game/Shared/Welfare")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CMenuRetentionUICompClass", "FCUICompClass")

--- 创建居中的粗体礼包文字；动态文案统一使用项目本地化入口。
--- @param parent Instance 本组件拥有的容器。
--- @param name string 节点名。
--- @param position UDim2 容器内位置。
--- @param size UDim2 文字区域。
--- @param maxTextSize number? 字号上限，按标题、奖励和按钮区分层级。
--- @return TextLabel 文字节点。
local function CreateGiftText(parent, name, position, size, maxTextSize)
    local text = Instance.new("TextLabel")
    text.Name = name
    text.BackgroundTransparency = 1
    text.Position, text.Size = position, size
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.TextStrokeColor3 = Color3.fromRGB(20, 12, 36)
    text.TextStrokeTransparency = 0.45
    text.TextScaled, text.TextWrapped = true, true
    text.AutoLocalize = false
    text.Text = ""
    text.Parent = parent
    local limit = Instance.new("UITextSizeConstraint")
    limit.MaxTextSize = maxTextSize or 28
    limit.Parent = text
    return text
end

--- 用四条透明渐变形成受伤式红色边缘，中心保持通透且不拦截输入。
function Component:CreateExitWarning()
    self._exitWarning = Instance.new("Frame")
    self._exitWarning.Name = "ExitWarning"
    self._exitWarning.Size = UDim2.fromScale(1, 1)
    self._exitWarning.BackgroundTransparency = 1
    self._exitWarning.Visible = false
    self._exitWarning.ZIndex = 0
    self._exitWarning.Parent = self._rootNode
    self._warningTweens = {}
    for index, edge in ipairs({
        {name = "Left", position = Vector2.zero, size = Vector2.new(0.12, 1), rotation = 0},
        {name = "Right", position = Vector2.new(0.88, 0), size = Vector2.new(0.12, 1), rotation = 180},
        {name = "Top", position = Vector2.zero, size = Vector2.new(1, 0.16), rotation = 90},
        {name = "Bottom", position = Vector2.new(0, 0.84), size = Vector2.new(1, 0.16), rotation = -90},
    }) do
        local frame = Instance.new("Frame")
        frame.Name = edge.name
        frame.Position = UDim2.fromScale(edge.position.X, edge.position.Y)
        frame.Size = UDim2.fromScale(edge.size.X, edge.size.Y)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.fromRGB(225, 25, 42)
        frame.BackgroundTransparency = 0.25
        frame.Parent = self._exitWarning
        local gradient = Instance.new("UIGradient", frame)
        gradient.Rotation = edge.rotation
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.35, 0.5),
            NumberSequenceKeypoint.new(1, 1),
        })
        self._warningTweens[index] = TweenService:Create(frame,
            TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.65})
    end
end

--- 侧边文字使用自身背景避免子节点遮挡字面，复用通用红箭头引导领取。
function Component:CreateGiftPanel()
    local rewardButton = FXLoader:PlayerGui("MainUI/LeftCenter/RewardBtn")
    self._sideTexts = {}
    self._sideArrows = {}
    for index, side in ipairs({"Left", "Right"}) do
        local text = CreateGiftText(self._rootNode, side .. "RetentionHint",
            UDim2.fromScale(index == 1 and 0.025 or 0.805, 0.42), UDim2.fromScale(0.17, 0.13), 48)
        text.TextColor3 = Color3.new(1, 1, 1)
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        text.TextStrokeTransparency = 0
        text.Visible = false
        text.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
        text.BackgroundTransparency = 0.08
        text.BorderSizePixel = 0
        Instance.new("UICorner", text).CornerRadius = UDim.new(0.08, 0)
        local border = Instance.new("UIStroke", text)
        border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        border.Color = Color3.fromRGB(255, 198, 76)
        border.Transparency = 0.25
        border.Thickness = 2
        local padding = Instance.new("UIPadding", text)
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0.06, 0), UDim.new(0.06, 0)
        padding.PaddingTop, padding.PaddingBottom = UDim.new(0.06, 0), UDim.new(0.06, 0)
        local arrowTarget = Instance.new("Frame", text)
        arrowTarget.Name = "ArrowTarget"
        arrowTarget.BackgroundTransparency = 1
        arrowTarget.Position = UDim2.fromScale(index == 1 and 1 or -0.25, 1.1)
        arrowTarget.Size = UDim2.fromScale(0.25, 0.8)
        self._sideArrows[index] = {controller = UIGuideArrow.New(self._rootNode.Parent), target = arrowTarget, side = side}
        self._sideTexts[index] = text
    end
    local panel = Instance.new("Frame")
    panel.Name = "GiftPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromScale(0.36, 0.55)
    panel.BackgroundColor3 = Color3.new(1, 1, 1)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = self._rootNode
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 24)
    local panelGradient = Instance.new("UIGradient", panel)
    panelGradient.Rotation = 90
    panelGradient.Color = ColorSequence.new(Color3.fromRGB(42, 74, 116), Color3.fromRGB(15, 25, 46))
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color, stroke.Thickness = Color3.fromRGB(255, 204, 77), 2
    self._giftPanel = panel
    self._commonUI:RegisterTrainingClickModal(panel)
    self._giftTitle = CreateGiftText(panel, "Title", UDim2.fromScale(0.08, 0.06), UDim2.fromScale(0.84, 0.16), 34)
    local titleGradient = Instance.new("UIGradient", self._giftTitle)
    titleGradient.Rotation = 90
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 249, 207)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 220, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 35)),
    })
    local image = Instance.new("ImageLabel")
    image.Name = "Gift"
    image.BackgroundTransparency = 1
    image.Position, image.Size = UDim2.fromScale(0.28, 0.25), UDim2.fromScale(0.44, 0.34)
    local reward = self._retention.MenuRetentionReward
    image.Image = reward.Type == "Aura"
        and "rbxassetid://" .. Aura.GetConfig(reward.Id).Img
        or FXLoader:Here(rewardButton, "IconImg").Image
    image.ScaleType = Enum.ScaleType.Fit
    image.Parent = panel
    self._giftReward = CreateGiftText(panel, "Reward", UDim2.fromScale(0.08, 0.61), UDim2.fromScale(0.84, 0.1), 30)
    local rewardGradient = Instance.new("UIGradient", self._giftReward)
    rewardGradient.Rotation = 90
    rewardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 253, 234)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 235, 163)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 200, 100)),
    })
    self._giftHint = CreateGiftText(panel, "MenuHint", UDim2.fromScale(0.08, 0.9), UDim2.fromScale(0.84, 0.07), 20)
    self._giftHint.TextColor3 = Color3.fromRGB(202, 219, 240)
    local claim = Instance.new("TextButton")
    claim.Name = "Claim"
    claim.Position, claim.Size = UDim2.fromScale(0.12, 0.75), UDim2.fromScale(0.76, 0.13)
    claim.BackgroundColor3 = Color3.new(1, 1, 1)
    claim.BorderSizePixel = 0
    claim.Text = ""
    claim.Parent = panel
    Instance.new("UICorner", claim).CornerRadius = UDim.new(0, 12)
    local claimGradient = Instance.new("UIGradient", claim)
    claimGradient.Rotation = 90
    claimGradient.Color = ColorSequence.new(Color3.fromRGB(116, 229, 74), Color3.fromRGB(36, 157, 62))
    local claimStroke = Instance.new("UIStroke", claim)
    claimStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    claimStroke.Color = Color3.fromRGB(16, 80, 36)
    claimStroke.Thickness = 2
    self._giftClaimText = CreateGiftText(claim, "Label", UDim2.fromScale(0.05, 0.05), UDim2.fromScale(0.9, 0.9), 36)
    self._giftClaim = claim
    self:TrackConnection(claim.Activated:Connect(function()
        self:ClaimGift()
    end))
    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Position, close.Size = UDim2.fromScale(0.89, 0.02), UDim2.fromScale(0.09, 0.1)
    close.BackgroundTransparency = 1
    close.AutoLocalize = false
    close.Text, close.TextScaled = "×", true
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Parent = panel
    self:TrackConnection(close.Activated:Connect(function()
        self._offerOpen = false
        self:RefreshGift()
    end))
end

--- 服务端起点已扣除历次在线时长，仅在累计在线未达配置期限时提示一次性礼包。
--- @return boolean 当前礼包是否可以领取。
function Component:IsGiftAvailable()
    local state = self:GetTable(Fields.WelfareState)
    local retention = self:GetTable(Fields.MenuRetentionData)
    return state.ready and not self._claimed and not retention.claimed
        and workspace:GetServerTimeNow() - state.retentionStartedAt < self._retention.MenuRetentionTriggerMinutes * 60
end

--- 先关闭 Main 以外的游戏弹窗，关闭完成且仍在提示期限内时才显示礼包。
function Component:OpenGift()
    if self._openTask or not self:IsGiftAvailable() then
        return
    end
    self._offerOpen = false
    self:RefreshGift()
    self._openTask = task.defer(function()
        self:GetPlayerObject():CloseOtherUI(self)
        self._openTask = nil
        self._offerOpen = self:IsGiftAvailable()
        self:RefreshText()
    end)
end

--- 请求独立的一次性礼包，服务端校验提示期限并永久去重；失败可重试。
function Component:ClaimGift()
    if self._requestTask or GuiService.MenuIsOpen or not self:IsGiftAvailable() then
        return
    end
    self._requestTask = task.defer(function()
        --- 网络失败保留礼包，不在客户端推断发奖成功。
        --- @return table 服务端领取结果。
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_ClaimWelfareReward", "retention", "once")
        end)
        self._requestTask = nil
        if ok and type(result) == "table" and result.success then
            self._claimed = true
            self:GetPlayerObject():RequireComponent("CSoundComp"):PlayRewardSound()
            self._commonUI:ShowLocalizedTips(result.key)
        else
            local key = ok and type(result) == "table" and result.key or TranslationTexts.Unknown
            self._commonUI:ShowLocalizedTips(key)
        end
        self:RefreshGift()
    end)
    self:RefreshGift()
end

--- 同步屏幕两侧提示和中央礼包，领取后永久隐藏，与每日福利状态独立。
function Component:RefreshGift()
    local available = self:IsGiftAvailable()
    if not available then
        self._offerOpen = false
    end
    local sideText = self:FormatText(TranslationTexts.GiftTitle)
    local showReminder = available and GuiService.MenuIsOpen
    for index, text in ipairs(self._sideTexts) do
        text.Visible = showReminder
        text.Text = sideText
        local arrow = self._sideArrows[index]
        if showReminder and not self._reminderVisible then
            arrow.controller:Show(arrow.target, arrow.side)
        elseif not showReminder and self._reminderVisible then
            arrow.controller:Hide()
        end
    end
    self._reminderVisible = showReminder
    if self._exitWarning.Visible ~= GuiService.MenuIsOpen then
        self._exitWarning.Visible = GuiService.MenuIsOpen
        for index, tween in ipairs(self._warningTweens) do
            if GuiService.MenuIsOpen then
                tween:Play()
            else
                tween:Cancel()
            end
        end
    end
    self._giftPanel.Visible = available and self._offerOpen == true
    self._giftTitle.Text = Text.Tr(TranslationTexts.GiftTitle)
    self._giftHint.Text = Text.Tr(TranslationTexts.GiftHint)
    self._giftHint.Visible = GuiService.MenuIsOpen
    local reward = Welfare.ToDisplayReward(self._retention.MenuRetentionReward)
    if reward.type == "Gem" then
        self._giftReward.Text = Text.Tr(TranslationTexts.Diamonds, {value = GameUtility.NumberToText(reward.amount)})
    else
        local rewardName = reward.type == "Aura"
            and Text.TrSource(Aura.GetConfig(self._retention.MenuRetentionReward.Id).Name)
            or Text.TrSource(_G.ItemConfig.Display[self._retention.MenuRetentionReward.Id].Name)
        self._giftReward.Text = Text.Tr(TranslationTexts.ItemReward, {
            item = rewardName,
            value = GameUtility.NumberToText(reward.amount),
        })
    end
    local pending = self._requestTask ~= nil
    self._giftClaim.Interactable = available and not pending and not GuiService.MenuIsOpen
    self._giftClaimText.Text = Text.Tr(pending and TranslationTexts.Pending or TranslationTexts.Claim)
end

--- 返回菜单提示组件的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CMenuRetentionUIComp"
end

--- 创建贴边黑底白字提示，使用黑色描边保持系统菜单压暗后的对比度。
--- @param name string 黑边节点名称。
--- @param bottom boolean 是否贴住屏幕底部。
--- @return TextLabel 黑边内的文字节点。
function Component:CreateBanner(name, bottom)
    local banner = Instance.new("Frame")
    banner.Name = name
    banner.BorderSizePixel = 0
    banner.BackgroundColor3 = Color3.new(0, 0, 0)
    banner.Size = UDim2.fromScale(1, 0.085)
    banner.AnchorPoint = Vector2.new(0, bottom and 1 or 0)
    banner.Position = UDim2.fromScale(0, bottom and 1 or 0)
    banner.Parent = self._rootNode
    local text = Instance.new("TextLabel")
    text.Name = "Message"
    text.BackgroundTransparency = 1
    text.Position = UDim2.fromScale(0.13, 0.12)
    text.Size = UDim2.fromScale(0.74, 0.76)
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.TextWrapped = true
    text.AutoLocalize = false
    text.Text = ""
    text.Parent = banner
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MaxTextSize = 48
    constraint.Parent = text
    if not bottom then
        local icon = Instance.new("ImageLabel")
        icon.Name = "StrengthIcon"
        icon.BackgroundTransparency = 1
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0.5, 6, 0.5, 0)
        icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
        icon.Size = UDim2.fromScale(1.4, 1.4)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Image = FXLoader:PlayerGui("MainUI/TopCenter/LevelProgressBar/StrengthIcon").Image
        icon.Parent = text
        --- 按居中文字的实际宽度贴住句末，随翻译、数值和屏幕尺寸重新定位。
        self:TrackConnection(text:GetPropertyChangedSignal("TextBounds"):Connect(function()
            icon.Position = UDim2.new(0.5, text.TextBounds.X / 2 + 6, 0.5, 0)
        end))
    end
    return text
end

--- 绑定系统菜单信号；自建界面随组件销毁，不影响其他游戏界面。
function Component:OnReady()
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._localization = self._commonUI.Localization
    self._retention = _G.ActivityConfig.CommonConfig
    self._rootNode = Instance.new("ScreenGui")
    self._rootNode.Name = "MenuRetentionUI"
    self._rootNode.ResetOnSpawn = false
    self._rootNode.ScreenInsets = Enum.ScreenInsets.None
    self._rootNode.DisplayOrder = 100
    self._rootNode.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._rootNode.Enabled = true
    self:CreateExitWarning()
    self._topText = self:CreateBanner("TopBar", false)
    self._bottomText = self:CreateBanner("BottomBar", true)
    self._rootNode.Parent = FXLoader:Player("PlayerGui")
    self:CreateGiftPanel()
    self:WatchDataChanged(Fields.WelfareState, self.OnWelfareChanged, self)
    self:WatchDataChanged(Fields.MenuRetentionData, self.RefreshGift, self)
    self:TrackConnection(GuiService.MenuOpened:Connect(function()
        self:OpenGift()
        self:RefreshText()
    end))
    self:TrackConnection(GuiService.MenuClosed:Connect(function()
        self:RefreshText()
    end))
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshText()
    end))
    if GuiService.MenuIsOpen then
        self:OpenGift()
        self:RefreshText()
    end
end

--- 收到服务端快照时校准显示计时，菜单关闭期间也保留计时起点。
function Component:OnWelfareChanged()
    self._snapshotReceivedAt = os.clock()
    self:RefreshText()
end

--- 本地表尚未同步新条目时仍保留英文提示；已有条目通过项目翻译入口显示。
--- @param key string 稳定本地化 Key。
--- @param arguments table? 原生模板参数。
--- @return string 当前语言文案或英文兜底。
function Component:FormatText(key, arguments)
    return Text.Tr(key, arguments)
end

--- 与服务端共用排除好友、按训练份额分段追赶的离线结算，展示普通领取的最大收益。
--- @return number 当前玩家离线收益上限。
function Component:GetOfflineMaximum()
    local config = _G.GameConfig.CommonConfig.OfflineReward
    return CurrencyShop.GetTrainingCardGain(self:GetPlayerObject(), config.Time * config.Rate)
end

--- 快照间逐秒递减显示时间；可领取状态仍以服务端同步的奖励资格为准。
function Component:RefreshText()
    self:RefreshGift()
    self._topText.Parent.Visible = GuiService.MenuIsOpen
    self._bottomText.Parent.Visible = GuiService.MenuIsOpen
    self._topText.Text = self:FormatText(TranslationTexts.Offline, {
        amount = GameUtility.NumberToText(self:GetOfflineMaximum()),
    })
    local state = self:GetTable(Fields.WelfareState)
    self._bottomText.Visible = state.ready
    if not state.ready then
        return
    end
    local remaining
    for index, config in ipairs(_G.ActivityConfig.OnlineRewardData) do
        if not state.onlineClaimed[tostring(config.Index)] then
            local seconds = math.max(0, config.TargetMinutes * 60 - state.onlineSeconds)
            remaining = remaining and math.min(remaining, seconds) or seconds
        end
    end
    local key = remaining == nil and TranslationTexts.Complete
        or remaining == 0 and TranslationTexts.Ready or TranslationTexts.OnlineCountdown
    local elapsed = math.floor(os.clock() - self._snapshotReceivedAt)
    local seconds = math.max(0, math.ceil((remaining or 0) - elapsed))
    self._bottomText.Text = self:FormatText(key, {
        time = string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60),
    })
end

--- 每秒刷新礼包资格和请求状态，菜单关闭后仍保留可领取礼包。
--- @param serverTime number 框架服务器时间；显示计时使用快照接收后的本地经过时间。
function Component:OnUpdate(serverTime)
    if self._rootNode and self._rootNode.Enabled then
        self:RefreshText()
    end
end

--- 释放红色边缘动画、通用箭头与本组件拥有的礼包节点。
function Component:Dtor()
    if self._openTask then
        task.cancel(self._openTask)
        self._openTask = nil
    end
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    for index, tween in ipairs(self._warningTweens or {}) do
        tween:Cancel()
    end
    for index, arrow in ipairs(self._sideArrows or {}) do
        arrow.controller:Destroy()
    end
    if self._rootNode then
        self._rootNode:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
