-- Roblox 系统菜单的上下黑边提示，不接管系统菜单和奖励领取。
local FX = _G.FX
local FXLoader = FX.Loader
local GuiService = game:GetService("GuiService")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Fields = _G.PlayerDataConfig
local Component = FX.Class("CMenuRetentionUICompClass", "FCUICompClass")
local Templates = {
    ["MenuRetention.Offline"] = "You can earn up to {amount} Strength while offline!",
    ["MenuRetention.Online"] = "Your next online reward is available in {time}!",
    ["MenuRetention.Ready"] = "Your online reward is ready to claim!",
    ["MenuRetention.Complete"] = "You have claimed all of today's online rewards!",
}

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
    self._localization = self:GetPlayerObject():RequireComponent("FCCommonUIComp").Localization
    self._sourceKeys = {}
    for index, entry in ipairs(FXLoader:Shared("Shared/Localization"):GetEntries()) do
        self._sourceKeys[entry.Key] = true
    end
    self._rootNode = Instance.new("ScreenGui")
    self._rootNode.Name = "MenuRetentionUI"
    self._rootNode.ResetOnSpawn = false
    self._rootNode.ScreenInsets = Enum.ScreenInsets.None
    self._rootNode.DisplayOrder = 100
    self._rootNode.Enabled = false
    self._topText = self:CreateBanner("TopBar", false)
    self._bottomText = self:CreateBanner("BottomBar", true)
    self._rootNode.Parent = FXLoader:Player("PlayerGui")
    self:WatchDataChanged(Fields.WelfareState, self.OnWelfareChanged, self)
    self:TrackConnection(GuiService.MenuOpened:Connect(function()
        self:RefreshText()
        self:Show()
    end))
    self:TrackConnection(GuiService.MenuClosed:Connect(function()
        self:Hide()
    end))
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshText()
    end))
    if GuiService.MenuIsOpen then
        self:RefreshText()
        self:Show()
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
        or remaining == 0 and "MenuRetention.Ready" or "MenuRetention.Online"
    local elapsed = math.floor(os.clock() - self._snapshotReceivedAt)
    local seconds = math.max(0, math.ceil((remaining or 0) - elapsed))
    self._bottomText.Text = self:FormatText(key, {
        time = string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60),
    })
end

--- 菜单打开时随框架秒更新刷新，关闭时不计算文案。
--- @param serverTime number 框架服务器时间；显示计时使用快照接收后的本地经过时间。
function Component:OnUpdate(serverTime)
    if self._rootNode and self._rootNode.Enabled then
        self:RefreshText()
    end
end

--- 只销毁本组件拥有的黑边，系统菜单及其他界面保持原有生命周期。
function Component:Dtor()
    if self._rootNode then
        self._rootNode:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
