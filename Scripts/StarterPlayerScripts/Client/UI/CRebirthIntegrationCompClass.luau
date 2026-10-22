local FX = _G.FX
local FC = _G.FC
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Rebirth", {
    CompleteNotice = "Rebirth complete!  {previous:int} → {current:int}",
    MaxCount = "You have reached the rebirth limit.",
    InDevelopment = "Coming soon.",
    Unknown = "Something went wrong. Please try again.",
    RequiredLevel = "Reach level {level:int} to rebirth.",
})
FXLoader:RequireFromParent(script, "Generated/CRebirthUICompClass")
local Fields = _G.PlayerDataConfig
local MarketplaceService = game:GetService("MarketplaceService")
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CRebirthIntegrationCompClass", "CRebirthUICompClass")

function Component:GetCompName()
    return "CRebirthUIComp"
end

--- 创建紧凑且不拦截输入的重生提示横幅，沿用界面中的重生图标。
--- @param root ScreenGui 重生界面的根节点。
--- @return ScreenGui 提示横幅所在的界面。
function Component:CreateRebirthNotice(root)
    local noticeGui = Instance.new("ScreenGui")
    noticeGui.Name = "RebirthNoticeUI"
    noticeGui.ResetOnSpawn = false
    noticeGui.DisplayOrder = 101
    noticeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    noticeGui.Parent = root.Parent

    local group = Instance.new("CanvasGroup")
    group.Name = "RebirthNotice"
    group.AnchorPoint = Vector2.new(0.5, 0)
    group.Position = UDim2.fromScale(0.5, 0.08)
    group.Size = UDim2.new(0.9, 0, 0, 42)
    group.Active = false
    group.Interactable = false
    group.Selectable = false
    group.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    group.BackgroundTransparency = 0.35
    group.Visible = false
    group.ZIndex = 10
    group.Parent = noticeGui
    self._rebirthNoticeGroup = group

    local maxSize = Instance.new("UISizeConstraint")
    maxSize.MaxSize = Vector2.new(360, 42)
    maxSize.Parent = group

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = group

    local rebirthIcon = FXLoader:Here(root, "TitleBox.RebirthIconImg")
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Position = UDim2.fromOffset(6, 5)
    icon.Size = UDim2.fromOffset(32, 32)
    icon.Active = false
    icon.Interactable = false
    icon.Selectable = false
    icon.BackgroundTransparency = 1
    icon.Image = rebirthIcon.Image
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 11
    icon.Parent = group

    local text = Instance.new("TextLabel")
    text.Name = "Message"
    text.Position = UDim2.fromOffset(46, 0)
    text.Size = UDim2.new(1, -56, 1, 0)
    text.Active = false
    text.Interactable = false
    text.Selectable = false
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextColor3 = Color3.fromHex("#FFD744")
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.TextSize = 18
    text.TextScaled = true
    text.TextWrapped = false
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.AutoLocalize = false
    text.ZIndex = 11
    text.Parent = group
    self._rebirthNoticeText = text

    local textSizeLimit = Instance.new("UITextSizeConstraint")
    textSizeLimit.MinTextSize = 12
    textSizeLimit.MaxTextSize = 18
    textSizeLimit.Parent = text

    return noticeGui
end

--- 按当前玩家语言刷新显示中的重生成功文案。
function Component:RefreshRebirthNotice()
    if self._rebirthNoticePrevious == nil then
        return
    end
    self._rebirthNoticeText.Text = Text.Tr(TranslationTexts.CompleteNotice, {
        previous = self._rebirthNoticePrevious, current = self._rebirthNoticeCurrent,
    })
end

--- 按屏幕缩小成功横幅，显示服务端确认的重生次数变化后淡出。
--- @param previousCount number 请求前的重生次数。
--- @param currentCount number 服务端确认的新重生次数。
function Component:ShowRebirthNotice(previousCount, currentCount)
    local viewport = self._rebirthNoticeGui.AbsoluteSize
    local scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.65, 1)
    local group = self._rebirthNoticeGroup
    local text = self._rebirthNoticeText
    group.Size = UDim2.new(0.9, 0, 0, 42 * scale)
    group:FindFirstChildOfClass("UISizeConstraint").MaxSize = Vector2.new(360 * scale, 42 * scale)
    group:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 6 * scale)
    group.Icon.Position = UDim2.fromOffset(6 * scale, 5 * scale)
    group.Icon.Size = UDim2.fromOffset(32 * scale, 32 * scale)
    text.Position = UDim2.fromOffset(46 * scale, 0)
    text.Size = UDim2.new(1, -56 * scale, 1, 0)
    text.TextSize = math.round(18 * scale)
    text:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = math.round(18 * scale)
    self._rebirthNoticePrevious = previousCount
    self._rebirthNoticeCurrent = currentCount
    self:RefreshRebirthNotice()

    self._rebirthNoticeGeneration += 1
    local generation = self._rebirthNoticeGeneration
    FC.UIAnim:StopProgress(self._rebirthNoticeGroup)
    self._rebirthNoticeGroup.GroupTransparency = 0
    self._rebirthNoticeGroup.Visible = true
    FC.UIAnim:FadeOut(self._rebirthNoticeGroup, function()
        if self._rebirthNoticeGeneration == generation then
            self._rebirthNoticeGroup.Visible = false
        end
    end, 0.2, 2.8)
end

--- 初始化重生界面、成功提示横幅和数据监听。
function Component:OnReady()
    Component.Super.OnReady(self)
    local root = self:GetRootNode()
    root.ResetOnSpawn = false
    root.DisplayOrder = 10
    self._rebirthNoticeGeneration = 0
    self._rebirthNoticeGui = self:CreateRebirthNotice(root)
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._commonUI:RegisterTrainingClickModal(root)
    self._localization = self._commonUI.Localization
    self.Config = {allowIneligibleAction = true}
    self.State = {Open = false, Completed = false, Pending = false}
    --- 平台弹窗关闭只恢复交互，重生奖励仍由服务端收据处理。
    --- @param userId number 平台回传的玩家 ID。
    --- @param productId number 平台 Developer Product ID。
    --- @param purchased boolean 平台支付结果，不作为发奖依据。
    self:TrackConnection(MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, purchased)
        if userId == self:GetPlayerNode().UserId and productId == self._promptProductId then
            self._promptProductId = nil
            self.State.Pending = false
            self:RefreshRebirth()
        end
    end))
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshRebirth()
        self:RefreshRebirthNotice()
    end))
    self:WatchDataChanged(Fields.RockTrainingLevel, self.RefreshRebirth, self)
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirth, self)
    self:RefreshRebirth()
end

-- 倍率和门槛与服务端共用曲线，不使用设计稿示例数值。
function Component:RefreshRebirth()
    local count = self:GetNumber(Fields.RebirthCount)
    local nextCount = math.min(count + 1, Rebirth.MaxCount)
    self.State.Level = self:GetNumber(Fields.RockTrainingLevel)
    self.State.RequiredLevel = Rebirth.GetRequiredLevel(count)
    self.State.CurrentStrengthMultiplier = Rebirth.GetTrainingRate(count)
    self.State.NextStrengthMultiplier = Rebirth.GetTrainingRate(nextCount)
    self.State.CurrentMoneyMultiplier = Rebirth.GetMoneyRate(count)
    self.State.NextMoneyMultiplier = Rebirth.GetMoneyRate(nextCount)
    self.State.AtMax = count >= Rebirth.MaxCount
    local goods = Rebirth.GetSkipGoods(count)
    local productId = goods and goods.RobloxProductId
    self.State.SkipAvailable = type(productId) == "number" and productId > 0 and productId % 1 == 0
    self:RefreshUI()
end

--- 重生倍率展示沿用项目格式，等级与次数由展示类按整数处理。
--- @param value number 原始倍率。
--- @return string 展示倍率。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 按当前次数选择真实平台商品，复用服务端预检和平台购买窗口。
function Component:RequestSkip()
    local goods = Rebirth.GetSkipGoods(self:GetNumber(Fields.RebirthCount))
    local productId = goods and goods.RobloxProductId
    if type(productId) ~= "number" or productId <= 0 or productId % 1 ~= 0 then
        self._commonUI:ShowLocalizedTips(TranslationTexts.InDevelopment)
        return
    end
    self.State.Pending = true
    self._promptProductId = productId
    self:RefreshUI()
    self._rebirthTask = task.defer(function()
        local ok, result = pcall(function()
            return self._commonUI:ShowDeveloperBuyUI(productId)
        end)
        self._rebirthTask = nil
        if not ok or not result then
            self._promptProductId = nil
            self.State.Pending = false
            self._commonUI:ShowLocalizedTips(TranslationTexts.Unknown)
        end
        self:RefreshRebirth()
    end)
end

function Component:OnShow()
    self.State.Open = true
    self:RefreshRebirth()
end

function Component:OnHide()
    self.State.Open = false
end

--- 处理重生界面请求；仅服务端确认成功后显示次数变化。
--- @param action string 重生界面操作名称。
--- @param payload table 展示层传入的操作参数。
function Component:OnUIAction(action, payload)
    if action == "CloseRebirth" then
        self:Hide()
        return
    end
    if self.State.Pending then
        return
    end
    if self:GetNumber(Fields.RebirthCount) >= Rebirth.MaxCount then
        self._commonUI:ShowLocalizedTips(TranslationTexts.MaxCount)
        return
    end
    if action == "RequestSkip" then
        self:RequestSkip()
        return
    end
    assert(action == "RequestRebirth", "Unsupported rebirth action: " .. tostring(action))
    local required = Rebirth.GetRequiredLevel(self:GetNumber(Fields.RebirthCount))
    if self:GetNumber(Fields.RockTrainingLevel) < required then
        self._commonUI:ShowLocalizedTips(TranslationTexts.RequiredLevel, {level = required})
        return
    end
    local previousRebirthCount = self:GetNumber(Fields.RebirthCount)
    self.State.Pending = true
    self:RefreshUI()
    self._rebirthTask = task.defer(function()
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_Rebirth")
        end)
        self._rebirthTask = nil
        self.State.Pending = false
        if not ok or type(result) ~= "table" then
            self._commonUI:ShowLocalizedTips(TranslationTexts.Unknown)
        elseif result.success == true then
            self:ShowRebirthNotice(previousRebirthCount, previousRebirthCount + 1)
        end
        -- 成败提示由服务端发送；后续门槛与倍率由正式数据同步刷新。
        self:RefreshRebirth()
    end)
end

--- 停止本组件拥有的重生请求与提示动画，并释放提示界面。
function Component:Dtor()
    if self._rebirthTask then
        task.cancel(self._rebirthTask)
        self._rebirthTask = nil
    end
    self._rebirthNoticeGeneration += 1
    if self._rebirthNoticeGroup then
        FC.UIAnim:StopProgress(self._rebirthNoticeGroup)
    end
    if self._rebirthNoticeGui then
        self._rebirthNoticeGui:Destroy()
        self._rebirthNoticeGui = nil
    end
    Component.Super.Dtor(self)
end

return Component
