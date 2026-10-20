-- Roblox 系统菜单背后的一次性挽留礼包，由服务端永久记录领取状态。
local FX = _G.FX
local FXLoader = FX.Loader
local TranslationTexts = {
    ["MenuRetention.OnlineCountdown"] = { Key = "MenuRetention.OnlineCountdown", Source = "Your next online reward is available in {time}!" },
    ["MenuRetention.Available"] = { Key = "MenuRetention.Available", Source = "Reward ready! Claim now!" },
    ["Common.Unknown"] = { Key = "CMenuRetentionUICompClass.Common.Unknown", Source = "Something went wrong. Please try again." },
    ["Welfare.Diamonds"] = { Key = "CMenuRetentionUICompClass.Welfare.Diamonds", Source = "{value} Diamonds" },
    ["Welfare.ItemReward"] = { Key = "CMenuRetentionUICompClass.Welfare.ItemReward", Source = "{item} ×{value}" },
    ["Welfare.Pending"] = { Key = "CMenuRetentionUICompClass.Welfare.Pending", Source = "Claiming..." },
    ["Welfare.Claim"] = { Key = "CMenuRetentionUICompClass.Welfare.Claim", Source = "Claim" },
    ["MenuRetention.Offline"] = { Key = "CMenuRetentionUICompClass.MenuRetention.Offline", Source = "You can earn up to {amount} Strength while offline!" },
    ["MenuRetention.Complete"] = { Key = "CMenuRetentionUICompClass.MenuRetention.Complete", Source = "You have claimed all of today's online rewards!" },
    ["MenuRetention.Ready"] = { Key = "CMenuRetentionUICompClass.MenuRetention.Ready", Source = "Your online reward is ready to claim!" },
}
local GuiService = game:GetService("GuiService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Welfare = FXLoader:RequireShared("Scripts/Game/Shared/Welfare")
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CMenuRetentionUICompClass", "FCUICompClass")

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

--- 创建礼包和两侧提示；光环奖励使用配置图标，其他奖励保留礼物图标，菜单关闭后可领取。
function Component:CreateGiftPanel()
    local rewardButton = FXLoader:PlayerGui("MainUI/LeftCenter/RewardBtn")
    self._sideTexts = {}
    for index, side in ipairs({"Left", "Right"}) do
        local text = CreateGiftText(self._rootNode, side .. "RetentionHint",
            UDim2.fromScale(index == 1 and 0.015 or 0.875, 0.38), UDim2.fromScale(0.11, 0.24))
        text.Font = Enum.Font.GothamBlack
        text.TextStrokeColor3 = Color3.fromRGB(20, 12, 36)
        text.TextStrokeTransparency = 0.2
        text.Visible = false
        local background = Instance.new("Frame", text)
        background.Name = "Background"
        background.Size = UDim2.fromScale(1, 1)
        background.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
        background.BackgroundTransparency = 0.12
        background.BorderSizePixel = 0
        background.ZIndex = text.ZIndex - 1
        Instance.new("UICorner", background).CornerRadius = UDim.new(0.08, 0)
        local border = Instance.new("UIStroke", background)
        border.Color = Color3.fromRGB(193, 126, 255)
        border.Transparency = 0.25
        border.Thickness = 2
        local gradient = Instance.new("UIGradient", text)
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 240, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(193, 126, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 137, 210)),
        })
        local padding = Instance.new("UIPadding", text)
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0.06, 0), UDim.new(0.06, 0)
        padding.PaddingTop, padding.PaddingBottom = UDim.new(0.06, 0), UDim.new(0.06, 0)
        -- 使用图形构造粗箭头，避免字体缺失箭头字符时显示方框。
        local arrow = Instance.new("Frame", text)
        arrow.Name = "InwardArrow"
        arrow.BackgroundTransparency = 1
        arrow.Position = UDim2.fromScale(0.05, 1.04)
        arrow.Size = UDim2.fromScale(0.9, 0.75)
        Instance.new("UIAspectRatioConstraint", arrow).AspectRatio = 1
        arrow.Rotation = index == 1 and 0 or 180
        for partIndex, segment in ipairs({
            {position = Vector2.new(0.42, 0.5), size = Vector2.new(0.7, 0.16), rotation = 0},
            {position = Vector2.new(0.68, 0.365), size = Vector2.new(0.45, 0.16), rotation = 45},
            {position = Vector2.new(0.68, 0.635), size = Vector2.new(0.45, 0.16), rotation = -45},
        }) do
            local part = Instance.new("Frame", arrow)
            part.Name = "Segment" .. partIndex
            part.AnchorPoint = Vector2.new(0.5, 0.5)
            part.Position = UDim2.fromScale(segment.position.X, segment.position.Y)
            part.Size = UDim2.fromScale(segment.size.X, segment.size.Y)
            part.Rotation = segment.rotation
            part.BorderSizePixel = 0
            part.BackgroundColor3 = Color3.fromRGB(193, 126, 255)
        end
        self._sideTexts[index] = text
    end
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
    local reward = self._retention.Reward
    image.Image = reward.Type == "Aura"
        and "rbxassetid://" .. Aura.GetConfig(reward.Id).Img
        or FXLoader:Here(rewardButton, "IconImg").Image
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
        self:ClaimGift()
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

--- 仅在本次进服后的配置分钟数之内提示永久未领取的一次性礼包。
--- @return boolean 当前礼包是否可以领取。
function Component:IsGiftAvailable()
    local state = self:GetTable(Fields.WelfareState)
    local retention = self:GetTable(Fields.MenuRetentionData)
    return state.ready and not self._claimed and not retention.claimed
        and workspace:GetServerTimeNow() - state.retentionStartedAt < self._retention.TriggerMinutes * 60
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
            local key = ok and type(result) == "table" and result.key or TranslationTexts["Common.Unknown"]
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
    local sideText = self:FormatText(TranslationTexts["MenuRetention.Available"])
    for index, text in ipairs(self._sideTexts) do
        text.Visible = available and GuiService.MenuIsOpen
        text.Text = sideText
    end
    self._giftPanel.Visible = available and self._offerOpen == true
    self._giftTitle.AutoLocalize = true
    self._giftTitle.Text = "Don't leave yet! A gift is ready for you!"
    self._giftHint.AutoLocalize = true
    self._giftHint.Text = "Close the Roblox menu to claim your gift."
    self._giftHint.Visible = GuiService.MenuIsOpen
    local reward = Welfare.ToDisplayReward(self._retention.Reward)
    local rewardName = reward.type == "Aura"
        and Text.TrSource(Aura.GetConfig(self._retention.Reward.Id).Name)
        or Text.TrSource(_G.ItemConfig.Display[reward.id].Name)
    self._giftReward.Text = reward.type == "Gem"
        and Text.Tr(TranslationTexts["Welfare.Diamonds"], {value = GameUtility.NumberToText(reward.amount)})
        or Text.Tr(TranslationTexts["Welfare.ItemReward"], {
            item = rewardName,
            value = GameUtility.NumberToText(reward.amount),
        })
    local pending = self._requestTask ~= nil
    self._giftClaim.Interactable = available and not pending and not GuiService.MenuIsOpen
    self._giftClaimText.Text = Text.Tr(pending and TranslationTexts["Welfare.Pending"] or TranslationTexts["Welfare.Claim"])
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
    self._retention = _G.ActivityConfig.MenuRetentionConfig
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
    self._topText.Text = self:FormatText(TranslationTexts["MenuRetention.Offline"], {
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
    local key = remaining == nil and TranslationTexts["MenuRetention.Complete"]
        or remaining == 0 and TranslationTexts["MenuRetention.Ready"] or TranslationTexts["MenuRetention.OnlineCountdown"]
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

--- 只销毁本组件拥有的黑边、礼包和两侧提示。
function Component:Dtor()
    if self._openTask then
        task.cancel(self._openTask)
        self._openTask = nil
    end
    if self._requestTask then
        task.cancel(self._requestTask)
        self._requestTask = nil
    end
    if self._rootNode then
        self._rootNode:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
