-- Roblox 系统菜单背后的挽留礼包，领取复用福利组件和服务端去重。
local FX = _G.FX
local FXLoader = FX.Loader
local GuiService = game:GetService("GuiService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Welfare = FXLoader:RequireShared("Scripts/Game/Shared/Welfare")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CMenuRetentionUICompClass", "FCUICompClass")
local Templates = {
    ["MenuRetention.Offline"] = "You can earn up to {amount} Strength while offline!",
    ["MenuRetention.OnlineCountdown"] = "Your next online reward is available in {time}!",
    ["MenuRetention.Ready"] = "Your online reward is ready to claim!",
    ["MenuRetention.Complete"] = "You have claimed all of today's online rewards!",
    ["MenuRetention.Stay"] = "Don't leave yet! A gift is ready for you!",
    ["MenuRetention.Available"] = "Reward ready! Claim now!",
    ["MenuRetention.Resume"] = "Close the Roblox menu to claim your gift.",
}

--- 创建礼包文字；动态文案统一使用项目本地化入口。
--- @param parent Instance 本组件拥有的容器。
--- @param name string 节点名。
--- @param position UDim2 容器内位置。
--- @param size UDim2 文字区域。
--- @return TextLabel 文字节点。
local function CreateGiftText(parent, name, position, size)
    local text = Instance.new("TextLabel")
    text.Name = name
    text.BackgroundTransparency = 1
    text.Position, text.Size = position, size
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled, text.TextWrapped = true, true
    text.AutoLocalize = false
    text.Text = ""
    text.Parent = parent
    local limit = Instance.new("UITextSizeConstraint")
    limit.MaxTextSize = 28
    limit.Parent = text
    return text
end

--- 独立创建普通礼包界面，透过半透明系统菜单可见，菜单关闭后可点击。
function Component:CreateGiftPanel()
    local rewardButton = FXLoader:PlayerGui("MainUI/LeftCenter/RewardBtn")
    self._sideText = CreateGiftText(rewardButton, "RetentionHint", UDim2.fromScale(1.08, 0), UDim2.fromScale(2, 1))
    self._sideText.BackgroundTransparency = 0.15
    self._sideText.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
    self._sideText.Visible = false
    local panel = Instance.new("Frame")
    panel.Name = "GiftPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromScale(0.38, 0.58)
    panel.BackgroundColor3 = Color3.fromRGB(30, 24, 55)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = self._rootNode
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0.06, 0)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color, stroke.Thickness = Color3.fromRGB(255, 204, 77), 3
    self._giftPanel = panel
    self._commonUI:RegisterTrainingClickModal(panel)
    self._giftTitle = CreateGiftText(panel, "Title", UDim2.fromScale(0.07, 0.04), UDim2.fromScale(0.8, 0.18))
    local image = Instance.new("ImageLabel")
    image.Name = "Gift"
    image.BackgroundTransparency = 1
    image.Position, image.Size = UDim2.fromScale(0.25, 0.23), UDim2.fromScale(0.5, 0.38)
    image.Image = FXLoader:Here(rewardButton, "IconImg").Image
    image.ScaleType = Enum.ScaleType.Fit
    image.Parent = panel
    self._giftReward = CreateGiftText(panel, "Reward", UDim2.fromScale(0.05, 0.61), UDim2.fromScale(0.9, 0.12))
    self._giftHint = CreateGiftText(panel, "MenuHint", UDim2.fromScale(0.05, 0.9), UDim2.fromScale(0.9, 0.08))
    local claim = Instance.new("TextButton")
    claim.Name = "Claim"
    claim.Position, claim.Size = UDim2.fromScale(0.18, 0.76), UDim2.fromScale(0.64, 0.13)
    claim.BackgroundColor3 = Color3.fromRGB(53, 177, 72)
    claim.Text = ""
    claim.Parent = panel
    Instance.new("UICorner", claim)
    self._giftClaimText = CreateGiftText(claim, "Label", UDim2.fromScale(0.05, 0.05), UDim2.fromScale(0.9, 0.9))
    self._giftClaim = claim
    self:TrackConnection(claim.Activated:Connect(function()
        if self:IsGiftAvailable() and not GuiService.MenuIsOpen then
            self._welfare:OnUIAction("Claim", {kind = "online", rewardId = self._rewardId})
            self:RefreshGift()
        end
    end))
    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Position, close.Size = UDim2.fromScale(0.89, 0.02), UDim2.fromScale(0.09, 0.1)
    close.BackgroundTransparency = 1
    close.Text, close.TextScaled = "×", true
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Parent = panel
    self:TrackConnection(close.Activated:Connect(function()
        self._offerOpen = false
        self:RefreshGift()
    end))
end

--- 仅提示服务端确认已达门槛且尚未领取的配置奖励，不额外创建奖励资格。
--- @return boolean 当前礼包是否可以领取。
function Component:IsGiftAvailable()
    local state = self:GetTable(Fields.WelfareState)
    -- OnReady 遍历顺序不固定；福利展示状态建立后才开放礼包入口。
    local entry = self._welfare.State and self._welfare.State.entries.online[self._rewardId]
    return state.ready and state.onlineSeconds >= self._retention.TriggerMinutes * 60
        and state.onlineSeconds >= self._rewardConfig.TargetMinutes * 60
        and not state.onlineClaimed[self._rewardId] and entry ~= nil and entry.status == "Claimable"
end

--- 同步左侧提示和中央礼包，两个入口共享福利领取状态。
function Component:RefreshGift()
    local available = self:IsGiftAvailable()
    if not available then
        self._offerOpen = false
    end
    self._sideText.Visible = available
    self._sideText.Text = self:FormatText("MenuRetention.Available")
    self._giftPanel.Visible = available and self._offerOpen == true
    self._giftTitle.Text = self:FormatText("MenuRetention.Stay")
    self._giftHint.Text = self:FormatText("MenuRetention.Resume")
    self._giftHint.Visible = GuiService.MenuIsOpen
    local reward = Welfare.ToDisplayReward(self._rewardConfig.Reward)
    self._giftReward.Text = reward.type == "Gem"
        and self._localization:FormatByKey("Welfare.Diamonds", {value = GameUtility.NumberToText(reward.amount)})
        or self._localization:FormatByKey("Welfare.ItemReward", {
            item = self._localization:FormatByKey("Welfare.Item." .. reward.id),
            value = GameUtility.NumberToText(reward.amount),
        })
    local entry = self._welfare.State and self._welfare.State.entries.online[self._rewardId]
    local pending = entry ~= nil and entry.pending == true
    self._giftClaim.Interactable = available and not pending and not GuiService.MenuIsOpen
    self._giftClaimText.Text = self._localization:FormatByKey(pending and "Welfare.Pending" or "Welfare.Claim")
end

--- 返回菜单提示组件的协作名称。
--- @return string 组件名称。
function Component:GetCompName()
    return "CMenuRetentionUIComp"
end

--- 创建贴边黑底文字，避开左上角系统按钮区域。
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
    text.TextScaled = true
    text.TextWrapped = true
    text.AutoLocalize = false
    text.Text = ""
    text.Parent = banner
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MaxTextSize = 38
    constraint.Parent = text
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 224, 240)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(158, 83, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 155)),
    })
    gradient.Parent = text
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
    self._welfare = self:GetPlayerObject():RequireComponent("CWelfareUIComp")
    self._retention = _G.ActivityConfig.MenuRetentionConfig
    self._rewardId = tostring(self._retention.OnlineRewardId)
    self._rewardConfig = assert(Welfare.GetReward("online", self._rewardId), "Invalid retention online reward ID")
    self._sourceKeys = {}
    for index, entry in ipairs(FXLoader:Shared("Shared/Localization"):GetEntries()) do
        self._sourceKeys[entry.Key] = true
    end
    self._rootNode = Instance.new("ScreenGui")
    self._rootNode.Name = "MenuRetentionUI"
    self._rootNode.ResetOnSpawn = false
    self._rootNode.ScreenInsets = Enum.ScreenInsets.None
    self._rootNode.DisplayOrder = 100
    self._rootNode.Enabled = true
    self._topText = self:CreateBanner("TopBar", false)
    self._bottomText = self:CreateBanner("BottomBar", true)
    self._rootNode.Parent = FXLoader:Player("PlayerGui")
    self:CreateGiftPanel()
    self:WatchDataChanged(Fields.WelfareState, self.OnWelfareChanged, self)
    self:TrackConnection(GuiService.MenuOpened:Connect(function()
        self._offerOpen = self:IsGiftAvailable()
        self:RefreshText()
    end))
    self:TrackConnection(GuiService.MenuClosed:Connect(function()
        self:RefreshText()
    end))
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshText()
    end))
    if GuiService.MenuIsOpen then
        self._offerOpen = self:IsGiftAvailable()
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
    if self._sourceKeys[key] then
        return self._localization:FormatByKey(key, arguments)
    end
    local text = string.gsub(Templates[key], "{(%w+)}", arguments or {})
    return text
end

--- 使用与服务端离线奖励一致的永久倍率和阶段上限，展示普通领取的最大收益。
--- @return number 当前玩家离线收益上限。
function Component:GetOfflineMaximum()
    local rebirthCount = self:GetNumber(Fields.RebirthCount)
    local highestRate = 0
    for index, config in ipairs(_G.GameConfig.TrainingFieldData) do
        if rebirthCount >= config.NeedRebirhLevel then
            highestRate = math.max(highestRate, config.TrainingRate)
        end
    end
    local config = _G.GameConfig.CommonConfig.OfflineReward
    local gain = _G.NumericalConfig.trainingSettlementsPerSecond * config.Time * config.Rate * highestRate
    gain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    gain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    gain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    gain *= CurrencyShop.GetTrainingRate(self:GetTable(Fields.CurrencyShopData))
    gain *= Rebirth.GetTrainingRate(rebirthCount)
    return math.clamp(gain, 0, math.max(0,
        Rebirth.GetMaxTrainingValue(rebirthCount) - self:GetNumber(Fields.RockTrainingValue)))
end

--- 快照间逐秒递减显示时间；可领取状态仍以服务端同步的奖励资格为准。
function Component:RefreshText()
    self:RefreshGift()
    self._topText.Parent.Visible = GuiService.MenuIsOpen
    self._bottomText.Parent.Visible = GuiService.MenuIsOpen
    self._topText.Text = self:FormatText("MenuRetention.Offline", {
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
    local key = remaining == nil and "MenuRetention.Complete"
        or remaining == 0 and "MenuRetention.Ready" or "MenuRetention.OnlineCountdown"
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

--- 只销毁本组件拥有的黑边、礼包和左侧提示。
function Component:Dtor()
    if self._sideText then
        self._sideText:Destroy()
    end
    if self._rootNode then
        self._rootNode:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
