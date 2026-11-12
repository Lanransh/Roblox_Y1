-- 重生业务接入：成功后显示次数横幅与屏幕彩纸礼炮。
local RunService = game:GetService("RunService")
local FX = _G.FX
local FC = _G.FC
local FXLoader = FX.Loader
local Text = FX.Text
local TranslationTexts = Text.Define("Rebirth", {
    CompleteNotice = "Rebirth complete!  {previous:int} → {current:int}",
    MaxCount = "You have reached the rebirth limit.",
    InDevelopment = "Coming soon.",
    Unknown = "Something went wrong. Please try again.",
    RequiredLevel = "Reach level {level:int} to rebirth.",
})
FXLoader:RequireFromParent(script, "Generated/CRebirthUICompClass")
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local Component = FX.Class("CRebirthIntegrationCompClass", "CRebirthUICompClass")

function Component:GetCompName()
    return "CRebirthUIComp"
end

--- 创建下移避开顶部力量显示且不拦截输入的重生提示横幅，沿用界面中的重生图标。
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
    group.Position = UDim2.fromScale(0.5, 0.16)
    group.Size = UDim2.new(0.9, 0, 0, 56)
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
    maxSize.MaxSize = Vector2.new(440, 56)
    maxSize.Parent = group

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = group

    local rebirthIcon = FXLoader:Here(root, "TitleBox.RebirthIconImg")
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Position = UDim2.fromOffset(8, 7)
    icon.Size = UDim2.fromOffset(42, 42)
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
    text.Position = UDim2.fromOffset(60, 0)
    text.Size = UDim2.new(1, -72, 1, 0)
    text.Active = false
    text.Interactable = false
    text.Selectable = false
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextColor3 = Color3.fromHex("#FFD744")
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.TextSize = 26
    text.TextScaled = true
    text.TextWrapped = false
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.AutoLocalize = false
    text.ZIndex = 11
    text.Parent = group
    self._rebirthNoticeText = text

    local textSizeLimit = Instance.new("UITextSizeConstraint")
    textSizeLimit.MinTextSize = 12
    textSizeLimit.MaxTextSize = 26
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

--- 结束或替换礼炮时断开更新并销毁彩纸，不影响成功横幅。
function Component:StopRebirthConfetti()
    if self._rebirthConfettiConnection then
        self._rebirthConfettiConnection:Disconnect()
        self._rebirthConfettiConnection = nil
    end
    if self._rebirthConfettiLayer then
        self._rebirthConfettiLayer:Destroy()
        self._rebirthConfettiLayer = nil
    end
end

--- 从屏幕两侧喷出宽片彩纸，缓慢翻转且保留厚度；连续重生替换上一轮，限制节点数量。
function Component:PlayRebirthConfetti()
    self:StopRebirthConfetti()
    local layer = Instance.new("Frame")
    layer.Name = "RebirthConfetti"
    layer.Size = UDim2.fromScale(1, 1)
    layer.BackgroundTransparency = 1
    layer.Active = false
    layer.Interactable = false
    layer.Selectable = false
    layer.ClipsDescendants = true
    layer.ZIndex = 1
    layer.Parent = self._rebirthNoticeGui
    self._rebirthConfettiLayer = layer

    local colors = {
        Color3.fromRGB(255, 211, 64), Color3.fromRGB(255, 94, 120),
        Color3.fromRGB(78, 209, 255), Color3.fromRGB(117, 239, 139),
        Color3.fromRGB(190, 128, 255), Color3.fromRGB(255, 155, 67),
    }
    local random = Random.new()
    local viewport = self._rebirthNoticeGui.AbsoluteSize
    local scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.65, 1)
    local particles = {}
    for index = 1, 84 do
        local fromLeft = index % 2 == 0
        local width = random:NextNumber(18, 28) * scale
        local height = width * random:NextNumber(0.7, 1)
        local piece = Instance.new("Frame")
        piece.Name = "Confetti"
        piece.AnchorPoint = Vector2.new(0.5, 0.5)
        piece.Size = UDim2.fromOffset(width, height)
        piece.BackgroundColor3 = colors[random:NextInteger(1, #colors)]
        piece.BorderSizePixel = 0
        piece.Active = false
        piece.Interactable = false
        piece.Selectable = false
        piece.Visible = false
        piece.Parent = layer
        particles[index] = {
            Node = piece, Width = width, Height = height,
            OriginX = fromLeft and 0.08 or 0.92,
            VelocityX = random:NextNumber(0.15, 0.65) * (fromLeft and 1 or -1),
            VelocityY = random:NextNumber(-1.85, -1.1),
            Rotation = random:NextNumber(0, 360),
            Spin = random:NextNumber(-540, 540),
            Flutter = random:NextNumber(4, 7),
            Delay = random:NextNumber(0, 0.22),
            Lifetime = random:NextNumber(2.4, 3.1),
        }
    end

    local elapsed = 0
    self._rebirthConfettiConnection = RunService.RenderStepped:Connect(function(deltaTime)
        elapsed += deltaTime
        local active = false
        for index = 1, #particles do
            local particle = particles[index]
            local age = elapsed - particle.Delay
            local piece = particle.Node
            piece.Visible = age >= 0 and age < particle.Lifetime
            if age < particle.Lifetime then
                active = true
            end
            if piece.Visible then
                local x = particle.OriginX + particle.VelocityX * age
                local y = 1.05 + particle.VelocityY * age + 0.8 * age * age
                piece.Position = UDim2.fromScale(x, y)
                piece.Rotation = particle.Rotation + particle.Spin * age
                piece.Size = UDim2.fromOffset(particle.Width,
                    particle.Height * math.max(0.55, math.abs(math.cos(age * particle.Flutter))))
                piece.BackgroundTransparency = math.clamp((age - particle.Lifetime + 0.6) / 0.6, 0, 1)
            end
        end
        if not active then
            self:StopRebirthConfetti()
        end
    end)
end

--- 播放成功礼炮并按屏幕缩小横幅，显示服务端确认的重生次数变化后淡出。
--- @param previousCount number 请求前的重生次数。
--- @param currentCount number 服务端确认的新重生次数。
function Component:ShowRebirthNotice(previousCount, currentCount)
    self:PlayRebirthConfetti()
    local viewport = self._rebirthNoticeGui.AbsoluteSize
    local scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.65, 1)
    local group = self._rebirthNoticeGroup
    local text = self._rebirthNoticeText
    group.Size = UDim2.new(0.9, 0, 0, 56 * scale)
    group:FindFirstChildOfClass("UISizeConstraint").MaxSize = Vector2.new(440 * scale, 56 * scale)
    group:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 6 * scale)
    local icon = FXLoader:Here(group, "Icon")
    icon.Position = UDim2.fromOffset(8 * scale, 7 * scale)
    icon.Size = UDim2.fromOffset(42 * scale, 42 * scale)
    text.Position = UDim2.fromOffset(60 * scale, 0)
    text.Size = UDim2.new(1, -72 * scale, 1, 0)
    text.TextSize = math.round(26 * scale)
    text:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = math.round(26 * scale)
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
    self:Hide()
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshRebirth()
        self:RefreshRebirthNotice()
    end))
    self:WatchDataChanged(Fields.RockTrainingLevel, self.RefreshRebirth, self)
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirth, self)
    self:RefreshRebirth()
end

--- 倍率和门槛与服务端共用曲线，跳过价格读取钻石商品配置。
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
    self.State.SkipCost = goods and goods.Price or 0
    self.State.SkipAvailable = goods ~= nil
    self:RefreshUI()
end

--- 重生倍率展示沿用项目格式，等级与次数由展示类按整数处理。
--- @param value number 原始倍率。
--- @return string 展示倍率。
function Component:FormatNumber(value)
    return GameUtility.NumberToText(value)
end

--- 请求按服务端当前档位消耗钻石，余额不足时打开商店 Robux 页；pending 防连点。
function Component:RequestSkip()
    local previousCount = self:GetNumber(Fields.RebirthCount)
    if not Rebirth.GetSkipGoods(previousCount) then
        self._commonUI:ShowLocalizedTips(TranslationTexts.InDevelopment)
        return
    end
    self.State.Pending = true
    self:RefreshUI()
    self._rebirthTask = task.defer(function()
        local ok, result = pcall(function()
            return FX.Network:InvokeServer("C2S_SkipRebirth", previousCount)
        end)
        self._rebirthTask = nil
        self.State.Pending = false
        if not ok or type(result) ~= "table" then
            self._commonUI:ShowLocalizedTips(TranslationTexts.Unknown)
        elseif result.success == true then
            self:ShowRebirthNotice(previousCount, result.count)
        elseif result.reason == "NeedDiamonds" then
            self:Hide()
            local shop = self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp")
            shop.State.tab = "Robux"
            shop:Show()
            shop:RefreshUI()
        end
        self:RefreshRebirth()
    end)
end

--- 打开时读取当前服务端同步的档位和钻石价格。
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

--- 停止本组件拥有的重生请求、提示动画与礼炮，并释放提示界面。
function Component:Dtor()
    self:StopRebirthConfetti()
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
