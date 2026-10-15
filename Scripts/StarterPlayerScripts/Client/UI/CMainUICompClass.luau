local FX = _G.FX
local FXLoader = FX.Loader
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Fields = _G.PlayerDataConfig
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local RockLevel = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.RockLevel)
local GameUtility = require(game:GetService("ReplicatedStorage").Scripts.Game.Shared.GameUtility)
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local StrengthPacks = {StrengthPack1Button = 301, StrengthPack2Button = 302}
local Component = FX.Class("CMainUICompClass", "FCUICompClass")

--- 返回主界面业务组件名，供项目组件协作使用。
--- @return string 主界面组件名。
function Component:GetCompName()
    return "CMainUIComp"
end

--- 服务端就绪后绑定并显示长生命周期主界面，初始同步不播放收益动画。
function Component:OnReady()
    self._playerGui = self:GetPlayerNode():WaitForChild("PlayerGui")
    self._rootNode = FXLoader:Here(self._playerGui, "MainUI")
    self._rootNode.ResetOnSpawn = false
    local top = FXLoader:Here(self._rootNode, "TopCenter")
    self._bar = FXLoader:Here(top, "LevelProgressBar")
    self._barLayout = {
        Position = self._bar.Position,
        Size = self._bar.Size,
        AnchorPoint = self._bar.AnchorPoint,
        LevelPosition = self._bar.LevelLabel.Position,
        LevelSize = self._bar.LevelLabel.Size,
        LevelAlignment = self._bar.LevelLabel.TextXAlignment,
    }
    self._homeButton = FXLoader:Here(top, "HomeButton")
    self._homeButton.Size = UDim2.fromOffset(160, 54)
    self._homeButton.TextScaled = false
    self._homeButton.TextSize = 32
    self._homeButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    self._homeButton.TextStrokeTransparency = 0
    self._areas = RockLevel.GetAreas()
    self._strength = FXLoader:Here(top, "Strength/Value")
    self._rebirthBadge = FXLoader:Here(self._rootNode, "LeftCenter/RebirthButton/Badge")
    self._rebirthBadge.AutoLocalize = false
    self._commonUI = self:GetPlayerObject():RequireComponent("FCCommonUIComp")
    self._localization = self._commonUI.Localization
    self._trainingStatus = Instance.new("TextLabel")
    self._trainingStatus.Name = "TrainingStatus"
    self._trainingStatus.AnchorPoint = Vector2.new(0.5, 0)
    self._trainingStatus.Position = UDim2.new(0.5, 0, 0, 150)
    self._trainingStatus.Size = UDim2.fromOffset(360, 32)
    self._trainingStatus.BackgroundTransparency = 1
    self._trainingStatus.Font = Enum.Font.GothamBold
    self._trainingStatus.TextSize = 22
    self._trainingStatus.TextColor3 = Color3.fromRGB(255, 225, 90)
    self._trainingStatus.TextStrokeTransparency = 0.3
    self._trainingStatus.AutoLocalize = false
    self._trainingStatus.Visible = false
    self._trainingStatus.Parent = self._rootNode
    self._strength.AutoLocalize = false
    self._bar.ProgressLabel.AutoLocalize = false
    self._homeButton.AutoLocalize = false
    self._homeButton.Text = self._localization:FormatByKey("Main.Home")
    --- 翻译就绪或语言切换时刷新主界面，出售界面自行监听语言变化。
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshLocalization()
    end))
    self._leftDown = FXLoader:Here(self._rootNode, "LeftDown")
    self._backpackBoost = self._rootNode:FindFirstChild("BackpackBoost")
    self._ownsBackpackBoost = self._backpackBoost == nil
    if self._ownsBackpackBoost then
        self._backpackBoost = self._leftDown.BackpackStat:Clone()
        self._backpackBoost.Name = "BackpackBoost"
        self._backpackBoost.Parent = self._rootNode
    end
    self:ConfigureBackpackBoostLayout()
    self._backpackBoost.Visible = false
    self._effects = {}
    self._pickupEffects = {}
    self._rainEffects = {}
    self._lastClick = -math.huge
    -- 复用 Rojo 管理的 ScreenGui，飘字直属该节点，不受 Canvas 缩放影响。
    self._effectGui = FXLoader:Here(self._playerGui, "ScreenGui")
    self._pulseScale = Instance.new("UIScale")
    self._pulseScale.Parent = self._strength
    self:BindButtons()
    self:RefreshHomeButton()
    --- 跟随角色进出关卡及重生切换入口，不重复注册按钮事件。
    self._homeTimer = FX.Task:Interval(0.1, function()
        self:RefreshHomeButton()
        self:RefreshGMButton()
        self:RefreshLootCapacity()
    end)
    --- 普通训练沿用飞行图标，力量卡成功结算后改为力量图标雨。
    --- @param gain number 服务端确认的训练收益。
    --- @param rewardRain boolean? 是否来自力量卡结算。
    --- @param position Vector2? 点击结算的屏幕飘字起点。
    FX.Network:RegServerMsgCallback("S2C_TrainingEffect", function(gain, rewardRain, position)
        if rewardRain then
            self:ShowRewardRain(self._bar.StrengthIcon)
            self:PulseStrength()
        else
            self:ShowTrainingEffect(gain, position)
        end
    end)
    self:WatchDataChanged(Fields.RockTrainingValue, self.RefreshProgress, self)
    --- 仅在礼盒金币由服务端发放成功后，复用拾取奖励表现。
    --- @param amount number 服务端确认的实际金币奖励。
    FX.Network:RegServerMsgCallback("S2C_GiftDropOpened", function(amount, currency)
        self:ShowPickupEffect({MoneyAmount = amount, Currency = currency})
    end)
    self:WatchDataChanged(Fields.TrainingFieldIndex, self.RefreshTrainingStatus, self)
    self:WatchDataChanged(Fields.RebirthCount, function()
        self:RefreshProgress(self:GetNumber(Fields.RockTrainingValue))
    end, self)
    self:WatchDataChanged(Fields.Money, self.RefreshCoins, self)
    self:WatchDataChanged(Fields.RebirthCount, self.RefreshRebirthCount, self)
    self:WatchDataChanged(Fields.Diamonds, self.RefreshDiamonds, self)
    self:WatchDataChanged(Fields.RockLoot, self.RefreshLoot, self)
    for index, field in ipairs({Fields.CurrencyShopData, Fields.RockTrainingValue, Fields.RebirthCount,
        Fields.CollectionEntries, Fields.AuraData, Fields.WeaponData}) do
        self:WatchDataChanged(field, function()
            self:RefreshStrengthOffers()
        end)
    end
    --- 鼠标只在未被按钮、背包等 UI 消耗时请求点击训练。
    --- @param input InputObject 本次输入。
    --- @param processed boolean 是否已被引擎 UI 消耗。
    self:TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            self:ShowClickTrainingEffect(Vector2.new(input.Position.X, input.Position.Y))
        end
    end))
    --- 触屏只为世界轻触请求点击训练，忽略摇杆拖动和界面点击。
    --- @param position Vector2 引擎提供的轻触位置，作为图标飞行起点。
    --- @param processed boolean 是否被界面消耗。
    self:TrackConnection(UserInputService.TouchTapInWorld:Connect(function(position, processed)
        if not processed then
            self:ShowClickTrainingEffect(position)
        end
    end))
    self:Show()
end

--- 每次主界面布局刷新时恢复 GM 按钮的右上角位置，避免响应式布局重置到旧位置。
function Component:RefreshGMButton()
    self._gmButton.AnchorPoint = Vector2.new(1, 0)
    self._gmButton.Position = UDim2.new(1, -68, 0, 10)
end

--- 只按显式禁点标记判断 UI 占用，弹窗状态由通用 UI 统一查询。
--- @param position Vector2 本次点击或轻触的屏幕像素坐标。
--- @return boolean 是否为可点击的主界面空白区域。
function Component:IsBlankMainArea(position)
    if not self._rootNode.Enabled or self._commonUI:IsTrainingClickBlocked() then
        return false
    end
    for index, node in ipairs(self._playerGui:GetGuiObjectsAtPosition(position.X, position.Y)) do
        local visible = true
        local blocked = false
        local ancestor = node
        while ancestor and ancestor ~= self._playerGui do
            if self._effects[ancestor]
                or (ancestor:IsA("GuiObject") and not ancestor.Visible)
                or (ancestor:IsA("ScreenGui") and not ancestor.Enabled) then
                visible = false
                break
            end
            if ancestor:GetAttribute("BlocksTrainingClick") == true then
                blocked = true
            end
            ancestor = ancestor.Parent
        end
        if visible and blocked then
            return false
        end
    end
    return true
end

--- 主界面空白区域本地限速后请求真实训练收益，服务端确认后才播放飘字。
--- @param position Vector2 本次点击或轻触的屏幕像素坐标。
function Component:ShowClickTrainingEffect(position)
    local now = os.clock()
    if UserInputService:GetFocusedTextBox() or now - self._lastClick < RockLevel.ClickInterval
        or not self:IsBlankMainArea(position) then
        return
    end
    self._lastClick = now
    FX.Network:SendMsgToServer("C2S_TrainingClick", position)
end

--- 将 GM 入口固定在右上角并标记主界面实际内容区域，弹窗入口交给对应业务组件。
function Component:BindButtons()
    self._gmButton = FXLoader:Here(self._rootNode, "GMButton")
    self:RefreshGMButton()
    self._gmButton.Visible = FX.IsDeveloper(self:GetPlayerNode().UserId)
    for index, path in ipairs({"TopCenter/LevelProgressBar", "TopCenter/Strength",
        "LeftDown/RebirthStat", "LeftDown/BackpackStat", "LeftDown/CashStat", "LeftDown/DiamondStat",
        "BackpackBoost"}) do
        FXLoader:Here(self._rootNode, path):SetAttribute("BlocksTrainingClick", true)
    end
    for index, node in ipairs(self._rootNode:GetDescendants()) do
        if node:IsA("GuiButton") then
            node:SetAttribute("BlocksTrainingClick", true)
            self:TrackConnection(node.Activated:Connect(function()
                if node.Name == "GMButton" then
                    if FX.IsDeveloper(self:GetPlayerNode().UserId) then
                        self:GetPlayerObject():RequireComponent("CGMUIComp"):Show()
                    end
                elseif node.Name == "CollectionBtn" then
                    self:GetPlayerObject():RequireComponent("CCollectionUIComp"):Show()
                elseif node.Name == "RebirthButton" then
                    self:GetPlayerObject():RequireComponent("CRebirthUIComp"):Show()
                elseif node.Name == "RewardBtn" then
                    self:GetPlayerObject():RequireComponent("CWelfareUIComp"):Show()
                elseif node.Name == "ShopBtn" then
                    self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp"):Show()
                elseif node.Name == "SettingsButton" then
                    self:GetPlayerObject():RequireComponent("CSettingsUIComp"):Show()
                elseif node == self._homeButton then
                    FX.Network:SendMsgToServer("C2S_ReturnHome")
                elseif node.Name == "DoubleStrengthButton" or StrengthPacks[node.Name] then
                    self:OpenStrengthOffer(node.Name)
                else
                    self:ShowDeveloping()
                end
            end))
        end
    end
end

--- 下一档倍率与力量包只展示真实配置；满级仍允许点击查看不可购买原因。
function Component:RefreshStrengthOffers()
    local right = FXLoader:Here(self._rootNode, "RightCenter")
    right.StrengthPack3Button.Visible = false
    local data = self:GetTable(Fields.CurrencyShopData)
    local nextItem = CurrencyShop.GetNextGemGoods(1, data)
    local rateButton = right.DoubleStrengthButton
    rateButton.Interactable = true
    rateButton.Price.AutoLocalize = false
    rateButton.Background.Label.AutoLocalize = false
    rateButton.PriceDiamond.Visible = nextItem ~= nil
    if nextItem then
        rateButton.Price.Text = self._localization:FormatByKey("Main.OfferPrice", {
            value = GameUtility.NumberToText(_G.GoodsConfig.GemGoodsData[nextItem.GemGoodsId].Price),
        })
        rateButton.Background.Label.Text = self._localization:FormatByKey("Main.StrengthRate", {
            rate = GameUtility.NumberToText(_G.GameConfig.TrainingRateConfig[data.trainingLevel + 1].Rate),
        })
    else
        rateButton.Price.Text = self._localization:FormatByKey("CurrencyShop.SoldOut")
        rateButton.Background.Label.Text = self._localization:FormatByKey("Main.StrengthRate", {
            rate = GameUtility.NumberToText(CurrencyShop.GetTrainingRate(data)),
        })
    end
    for name, goodsId in pairs(StrengthPacks) do
        local button = right[name]
        local gain = CurrencyShop.GetTrainingPackGain(self:GetPlayerObject(), goodsId)
        button.Interactable = true
        button.Price.AutoLocalize = false
        button.Amount.AutoLocalize = false
        button.Price.Text = self._localization:FormatByKey("Main.OfferPrice", {
            value = GameUtility.NumberToText(_G.GoodsConfig.GemGoodsData[goodsId].Price),
        })
        button.Amount.Text = "+" .. GameUtility.NumberToText(gain)
    end
end

--- 主界面快捷入口复用钻石单件确认页，仅服务端确认后扣款发奖。
--- @param name string 已绑定的右侧按钮名称。
function Component:OpenStrengthOffer(name)
    local shop = self:GetPlayerObject():RequireComponent("CCurrencyShopUIComp")
    local product
    if name == "DoubleStrengthButton" then
        shop:BuildProducts()
        for index, candidate in ipairs(shop.Config.products) do
            if candidate.id == "group_1" and not candidate.soldOut then
                product = candidate
                break
            end
        end
        if not product then
            self._commonUI:ShowLocalizedTips("CurrencyShop.RateMaxed")
            return
        end
    else
        local goodsId = StrengthPacks[name]
        local gain = CurrencyShop.GetTrainingPackGain(self:GetPlayerObject(), goodsId)
        if gain <= 0 then
            self._commonUI:ShowLocalizedTips("Main.TrainingFull")
            return
        end
        local button = self._rootNode.RightCenter[name]
        product = {goodsId = goodsId, currency = "Diamond", icon = button.Icon.Image,
            price = _G.GoodsConfig.GemGoodsData[goodsId].Price,
            title = self._localization:FormatByKey("Main.TrainingPack"),
            description = self._localization:FormatByKey("Main.TrainingPackDesc", {
                value = GameUtility.NumberToText(gain),
            })}
    end
    if product then
        self:GetPlayerObject():RequireComponent("CShopPurchaseUIComp"):OpenProduct(product)
    end
end

--- 关卡内显示无棋格的紧凑经验条；离开或死亡时恢复带棋格的完整经验条及力量。
function Component:RefreshHomeButton()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local inArea = root ~= nil and humanoid ~= nil and humanoid.Health > 0
        and RockLevel.IsInArea(self._areas, root.Position)
    self._homeButton.Visible = inArea
    self._strength.Parent.Visible = not inArea
    if self._inLevelArea == inArea then
        return
    end
    self._inLevelArea = inArea
    local layout = self._barLayout
    self._bar.Visible = true
    self._bar.AnchorPoint = inArea and Vector2.new(0.5, 0) or layout.AnchorPoint
    self._bar.Position = inArea and UDim2.new(0.5, 0, 0, 72) or layout.Position
    self._bar.Size = inArea and UDim2.fromOffset(160, 26) or layout.Size
    FXLoader:Here(self._bar, "ToolkitUIStyle"):SetAttribute("Stud", not inArea)
    FXLoader:Here(self._bar, "Fill/ToolkitUIStyle"):SetAttribute("Stud", not inArea)
    self._bar.LevelLabel.Position = inArea and UDim2.fromScale(0, 0) or layout.LevelPosition
    self._bar.LevelLabel.Size = inArea and UDim2.fromScale(1, 1) or layout.LevelSize
    self._bar.LevelLabel.TextXAlignment = inArea and Enum.TextXAlignment.Center or layout.LevelAlignment
    self._bar.ProgressLabel.Visible = not inArea
    self._bar.StrengthIcon.Visible = not inArea
end

--- 语言变化只刷新当前数据显示，不播放训练收益动画或重新打开已关闭弹窗。
function Component:RefreshLocalization()
    self._homeButton.Text = self._localization:FormatByKey("Main.Home")
    self:RefreshProgress(self:GetNumber(Fields.RockTrainingValue))
    self:RefreshTrainingStatus(self:GetNumber(Fields.TrainingFieldIndex))
    self:RefreshStrengthOffers()
end

--- 仅显示服务端确认的已解锁训练基地，不凭客户端位置授予训练资格。
--- @param index number 同步的训练基地序号，0 表示场外。
function Component:RefreshTrainingStatus(index)
    local config = _G.GameConfig.TrainingFieldData[index]
    self._trainingStatus.Visible = config ~= nil
    if config then
        self._trainingStatus.Text = self._localization:FormatByKey("Training.Active", {
            rate = GameUtility.NumberToText(config.TrainingRate),
        })
    end
end

--- 未实现的入口统一走现有通用提示，不伪造购买或奖励成功。
function Component:ShowDeveloping()
    self._commonUI:ShowLocalizedTips("Common.InDevelopment")
end

--- 金币余额随服务端同步刷新，保留货币前缀并统一使用数量格式。
--- @param value number 同步后的金币余额。
function Component:RefreshCoins(value)
    FXLoader:Here(self._leftDown, "CashStat/Value").Text = "$" .. GameUtility.NumberToText(value)
end

--- 重生次数随持久字段刷新，按次数语义显示整数。
--- @param value number 同步后的累计重生次数。
function Component:RefreshRebirthCount(value)
    FXLoader:Here(self._leftDown, "RebirthStat/Value").Text = string.format("%d", value)
end

--- 钻石读取持久字段并使用通用数量格式，默认 500 由服务端字段定义提供。
--- @param value number 同步后的钻石数量。
function Component:RefreshDiamonds(value)
    FXLoader:Here(self._leftDown, "DiamondStat/Value").Text = GameUtility.NumberToText(value)
end

--- 刷新随身战利品数量，仅为服务端确认新增的道具播放 UI 拾取表现。
--- @param loot table 当前携带且尚未回基地入库的战利品。
--- @param oldLoot table? 变化前的战利品，首次同步为空且不播放动画。
function Component:RefreshLoot(loot, oldLoot)
    self:RefreshLootCapacity(loot)
    if oldLoot == nil or #loot <= #oldLoot then
        return
    end
    for index = #oldLoot + 1, #loot do
        self:ShowPickupEffect(loot[index])
    end
end

--- 右下角扩容 buff：图标居中，上方显示额外格数，下方显示剩余时间。
function Component:ConfigureBackpackBoostLayout()
    local frame = self._backpackBoost
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.Position = UDim2.new(1, -12, 1, -12)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromOffset(72, 88)
    frame.ClipsDescendants = false
    for index, child in ipairs(frame:GetChildren()) do
        if child:IsA("UICorner") or child:IsA("UIGradient") or child:IsA("UIStroke") then
            child:Destroy()
        end
    end
    local icon = frame.Icon
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0, 38)
    icon.Size = UDim2.fromOffset(56, 56)
    local countLabel = frame:FindFirstChild("Count")
    if not countLabel then
        countLabel = Instance.new("TextLabel")
        countLabel.Name = "Count"
        countLabel.Parent = frame
    end
    countLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    countLabel.Position = UDim2.new(0.5, 12, 0, 10)
    countLabel.Size = UDim2.fromOffset(44, 22)
    countLabel.BackgroundTransparency = 1
    countLabel.FontFace = frame.Value.FontFace
    countLabel.TextScaled = true
    countLabel.TextColor3 = Color3.new(1, 1, 1)
    countLabel.TextStrokeColor3 = frame.Value.TextStrokeColor3
    countLabel.TextStrokeTransparency = 0
    countLabel.TextXAlignment = Enum.TextXAlignment.Center
    countLabel.TextYAlignment = Enum.TextYAlignment.Center
    countLabel.AutoLocalize = false
    countLabel.ZIndex = 2
    self._backpackBoostCount = countLabel
    local value = frame.Value
    value.AnchorPoint = Vector2.new(0.5, 0.5)
    value.Position = UDim2.new(0.5, 0, 1, -10)
    value.Size = UDim2.fromOffset(72, 22)
    value.TextXAlignment = Enum.TextXAlignment.Center
    value.TextScaled = false
    value.TextSize = 18
    value.AutoLocalize = false
    value.Text = ""
end

--- @param remaining number 剩余秒数。
--- @return string 与右下角 buff 一致的倒计时文案。
function Component:FormatBackpackBoostCountdown(remaining)
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    local seconds = remaining % 60
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
    return string.format("%02d:%02d", minutes, seconds)
end

--- 显示基础容量与永久扩容；临时扩容卡仅在有效期内额外增加容量。
---@param loot table? 当前携带的战利品；省略时读取已同步字段。
function Component:RefreshLootCapacity(loot)
    loot = loot or self:GetTable(Fields.RockLoot)
    local boost = self:GetTable(Fields.RockLootCapacityBoost)
    local now = workspace:GetServerTimeNow()
    local activeBoost = type(boost) == "table" and (boost.expiresAt or 0) > now
    local capacity = RockLevel.LootCapacity + self:GetTable(Fields.CurrencyShopData).capacity
    if activeBoost then
        capacity += math.max(0, math.floor(boost.count or 0))
    end
    self._leftDown.BackpackStat.Value.Text = string.format("%d/%d", #loot, capacity)
    self._backpackBoost.Visible = activeBoost
    if activeBoost then
        local remaining = math.max(0, math.ceil(boost.expiresAt - now))
        local extraSlots = math.max(1, math.floor(boost.count or 1))
        self._backpackBoostCount.Text = string.format("+%d", extraSlots)
        self._backpackBoost.Value.Text = self:FormatBackpackBoostCountdown(remaining)
    end
end

--- 在屏幕中央展示道具或金币与放射光芒，再一起缩小飞向对应统计图标。
--- @param entry table 服务端确认的道具 DisplayModelId 或礼盒金币 MoneyAmount。
function Component:ShowPickupEffect(entry)
    local path = type(entry.DisplayModelId) == "string" and string.match(entry.DisplayModelId, "^game%.(.+)$")
    local template = path and FXLoader:Find(game, path)
    local isMoney = entry.MoneyAmount ~= nil
    local currencyPath = entry.Currency == "Diamonds" and "DiamondStat/Icon" or "CashStat/Icon"
    if not isMoney and (not template or not template:IsA("Model")) then
        return
    end
    local effect = Instance.new("Frame")
    effect.Name = "PickupItemEffect"
    effect.AnchorPoint = Vector2.new(0.5, 0.5)
    effect.BackgroundTransparency = 1
    effect.ZIndex = 20
    local glow = Instance.new("CanvasGroup")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.Size = UDim2.fromScale(1.65, 1.65)
    glow.BackgroundTransparency = 1
    glow.ZIndex = 1
    glow.Parent = effect
    for index = 1, 12 do
        local angle = (index - 1) * math.pi / 6
        local ray = Instance.new("Frame")
        ray.Name = "Ray" .. index
        ray.AnchorPoint = Vector2.new(0.5, 0.5)
        ray.Position = UDim2.fromScale(0.5 + math.cos(angle) * 0.24, 0.5 + math.sin(angle) * 0.24)
        ray.Size = UDim2.fromScale(0.46, 0.055)
        ray.Rotation = math.deg(angle)
        ray.BackgroundColor3 = Color3.fromRGB(255, 243, 196)
        ray.BorderSizePixel = 0
        local gradient = Instance.new("UIGradient")
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(0.25, 0.55),
            NumberSequenceKeypoint.new(0.6, 0.7),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = ray
        ray.Parent = glow
    end
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "Item"
    viewport.Size = UDim2.fromScale(1, 1)
    viewport.BackgroundTransparency = 1
    viewport.BorderSizePixel = 0
    viewport.ZIndex = 2
    viewport.Parent = effect
    viewport.Ambient = Color3.fromRGB(200, 200, 200)
    viewport.LightColor = Color3.new(1, 1, 1)
    viewport.LightDirection = Vector3.new(-1, -1, -1)
    local model
    local pivot
    local moneyIcon
    local moneyText
    if isMoney then
        viewport.Visible = false
        moneyIcon = FXLoader:Here(self._leftDown, currencyPath):Clone()
        moneyIcon.Name = "Money"
        moneyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        moneyIcon.Position = UDim2.fromScale(0.5, 0.5)
        moneyIcon.Size = UDim2.fromScale(0.75, 0.75)
        moneyIcon.BackgroundTransparency = 1
        moneyIcon.ImageTransparency = 0
        moneyIcon.Visible = true
        moneyIcon.ZIndex = 2
        moneyIcon.Parent = effect
        moneyText = Instance.new("TextLabel")
        moneyText.Name = "RewardAmount"
        moneyText.AnchorPoint = Vector2.new(0.5, 0)
        moneyText.Position = UDim2.fromScale(0.5, 0.95)
        moneyText.Size = UDim2.fromScale(1.5, 0.22)
        moneyText.BackgroundTransparency = 1
        moneyText.Font = Enum.Font.GothamBold
        moneyText.TextScaled = true
        moneyText.TextColor3 = Color3.new(1, 1, 1)
        moneyText.Text = entry.Currency == "Diamonds" and GameUtility.NumberToText(entry.MoneyAmount)
            or GameUtility.NumberToText(entry.MoneyAmount) .. "元"
        moneyText.AutoLocalize = false
        moneyText.ZIndex = 3
        moneyText.Parent = effect
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 248, 185)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 210, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 135, 20)),
        })
        gradient.Parent = moneyText
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 2
        stroke.Parent = moneyText
    else
        model = template:Clone()
        for index, node in ipairs(model:GetDescendants()) do
            if node:IsA("BasePart") then
                node.Anchored = true
                node.CanCollide = false
                node.CanTouch = false
                node.CanQuery = false
            end
        end
        local bounds, size = model:GetBoundingBox()
        pivot = model:GetPivot() - bounds.Position
        model:PivotTo(pivot)
        model.Parent = viewport
        local camera = Instance.new("Camera")
        camera.FieldOfView = 35
        local distance = size.Magnitude * 0.6 / math.sin(math.rad(camera.FieldOfView / 2))
        camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, distance), Vector3.zero)
        camera.Parent = viewport
        viewport.CurrentCamera = camera
    end
    local elapsed = 0
    local connection
    --- 奖励与光芒共用屏幕位置和缩放，按奖励种类飞向背包或金币图标。
    --- @param deltaTime number 本次渲染帧间隔秒数。
    local function animate(deltaTime)
        elapsed += deltaTime
        if elapsed >= 1.3 then
            connection:Disconnect()
            self._pickupEffects[effect] = nil
            effect:Destroy()
            return
        end
        local origin = self._effectGui.AbsolutePosition
        local screenArea = GuiService:GetInsetArea(Enum.ScreenInsets.None)
        local center = (screenArea.Min + screenArea.Max) / 2 - origin
        local icon = self._leftDown.BackpackStat.Icon
        if isMoney then
            icon = FXLoader:Here(self._leftDown, currencyPath)
        end
        local target = icon.AbsolutePosition + icon.AbsoluteSize / 2 - origin
        local fly = math.clamp((elapsed - 0.85) / 0.45, 0, 1)
        local position = center:Lerp(target, fly ^ 2)
        local pop = math.clamp(elapsed / 0.18, 0, 1)
        local scale = (0.25 + 0.75 * (1 - (1 - pop) ^ 3)) * (1 - 0.9 * fly)
        local diameter = math.min(self._effectGui.AbsoluteSize.X, self._effectGui.AbsoluteSize.Y) * 0.30 * scale
        effect.Position = UDim2.fromOffset(position.X, position.Y)
        effect.Size = UDim2.fromOffset(diameter, diameter)
        glow.Rotation = elapsed * 25
        glow.GroupTransparency = 1 - pop * (1 - fly)
        viewport.ImageTransparency = fly
        if isMoney then
            moneyIcon.Rotation = elapsed * 90
            moneyIcon.ImageTransparency = fly
            moneyText.TextTransparency = fly
            moneyText.UIStroke.Transparency = fly
        else
            model:PivotTo(CFrame.Angles(0, elapsed * math.pi * 2, 0) * pivot)
        end
    end
    animate(0)
    effect.Parent = self._effectGui
    connection = RunService.RenderStepped:Connect(animate)
    self._pickupEffects[effect] = connection
end

--- 刷新经验、力量与整数重生百分比；经验条以 0.3 秒 Quad Out 平滑填充。
--- @param value number 同步后的累计训练值。
--- @param oldValue number? 上一次训练值，首次回放为 nil。
function Component:RefreshProgress(value, oldValue)
    local rebirthRequiredLevel = Rebirth.GetRequiredLevel(self:GetNumber(Fields.RebirthCount))
    local level, strength, progressValue, required = RockLevel.GetProgress(value, rebirthRequiredLevel)
    self._rebirthBadge.Text = string.format("%d%%", math.floor(math.clamp(level / rebirthRequiredLevel, 0, 1) * 100))
    local progress = math.clamp(progressValue / required, 0, 1)
    self._bar.LevelLabel.Text = string.format("Lv.%d", level)
    self._bar.ProgressLabel.Text = string.format("%s/%s",
        GameUtility.NumberToText(math.min(progressValue, required)), GameUtility.NumberToText(required))
    self._strength.Text = self._localization:FormatByKey("Main.Strength", {value = GameUtility.NumberToText(strength)})
    if level >= RockLevel.MaxLevel then
        progress = 1
        self._bar.ProgressLabel.Text = self._localization:FormatByKey("Main.MaxLevel")
    end
    local size = UDim2.new(progress, 0, 1, 0)
    if self._progressTween then
        self._progressTween:Cancel()
        self._progressTween:Destroy()
    end
    if oldValue == nil then
        self._bar.Fill.Size = size
    else
        self._progressTween = TweenService:Create(self._bar.Fill,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = size})
        self._progressTween:Play()
    end
end

--- 点击显示一个全额图标，走路及击打在角色周围独立随机显示三个均分图标，飞向中心时最小缩至 50%。
--- @param gain number 服务器确认的实际训练收益。
--- @param position Vector2? 点击起点，走路及击打收益不传。
function Component:ShowTrainingEffect(gain, position)
    -- 完整屏幕与角色投影都转换到共用 ScreenGui 的局部坐标，避免安全区造成偏移。
    local origin = self._effectGui.AbsolutePosition
    local screenArea = GuiService:GetInsetArea(Enum.ScreenInsets.None)
    local target = (screenArea.Min + screenArea.Max) / 2 - origin
    local spawnCenter = target
    if not position then
        local character = self:GetPlayerNode().Character
        local camera = workspace.CurrentCamera
        if character and camera then
            local projected, onScreen = camera:WorldToScreenPoint(character:GetPivot().Position)
            if onScreen then
                spawnCenter = Vector2.new(projected.X, projected.Y) - origin
            end
        end
    end
    local count = position and 1 or 3
    -- 先均分实际收益再统一格式化，仅改变客户端文案，不改变服务端奖励。
    local gainText = GameUtility.NumberToText(gain / count)
    for index = 1, count do
        local startPosition
        if position then
            startPosition = position - origin
        else
            -- 每个图标独立选择方向和距离，避免同批图标呈固定三角形分布。
            local angle = math.random() * math.pi * 2
            local radius = math.random(180, 300)
            startPosition = spawnCenter + Vector2.new(math.cos(angle), math.sin(angle)) * radius
        end
        local initialDistance = math.max((startPosition - target).Magnitude, 1)
        local icon = self._bar.StrengthIcon:Clone()
        icon.Name = "TrainingGain"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromOffset(startPosition.X, startPosition.Y)
        icon.Size = UDim2.fromOffset(80, 80)
        icon.Visible = true
        icon.Parent = self._effectGui
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromOffset(100, 30)
        label.Position = UDim2.new(0.5, -50, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 28
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.3
        label.Text = "+" .. gainText
        label.Parent = icon
        local effect = {}
        self._effects[icon] = effect
        --- 按实际剩余路程计算图标尺寸，抵达中心时仍保留初始大小的一半。
        local function UpdateSize()
            local currentPosition = Vector2.new(icon.Position.X.Offset, icon.Position.Y.Offset)
            local remaining = math.clamp((currentPosition - target).Magnitude / initialDistance, 0, 1)
            local size = 80 * (0.5 + 0.5 * remaining)
            icon.Size = UDim2.fromOffset(size, size)
        end
        effect.SizeConnection = icon:GetPropertyChangedSignal("Position"):Connect(UpdateSize)
        UpdateSize()
        --- 动画结束后释放本次飘字与尺寸监听，走路及击打收益保留力量栏到账反馈。
        effect.Task = task.spawn(function()
            effect.Tween = TweenService:Create(icon,
                TweenInfo.new(0.62, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.fromOffset(target.X, target.Y), ImageTransparency = 0.8,
                })
            effect.Tween:Play()
            effect.Tween.Completed:Wait()
            effect.SizeConnection:Disconnect()
            effect.Tween:Destroy()
            self._effects[icon] = nil
            icon:Destroy()
            if not position then
                self:PulseStrength()
            end
        end)
    end
end

--- 出售弹窗退场后复用主界面金币图标播放金币雨。
function Component:ShowMoneyRain()
    self:ShowRewardRain(FXLoader:Here(self._leftDown, "CashStat/Icon"))
end

--- 迁移 Studio_Y3 的 24 枚错落旋转下坠图标，按当前屏幕尺寸适配轨迹。
--- @param template ImageLabel 当前项目的金币或力量图标模板。
function Component:ShowRewardRain(template)
    self:ClearRewardRain()
    local origin = self._effectGui.AbsolutePosition
    local screenArea = GuiService:GetInsetArea(Enum.ScreenInsets.None)
    local screenSize = screenArea.Max - screenArea.Min
    local scale = math.min(screenSize.X / 1280, screenSize.Y / 720)
    for index = 1, 24 do
        local icon = template:Clone()
        icon.Name = "RewardRain"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        local start = screenArea.Min - origin + Vector2.new(
            math.random() * (screenSize.X - 80 * scale) + 40 * scale,
            -math.random(60, 420) * scale)
        icon.Position = UDim2.fromOffset(start.X, start.Y)
        local size = 64 * scale * math.random(65, 115) / 100
        icon.Size = UDim2.fromOffset(size, size)
        icon.Rotation = math.random(-45, 45)
        icon.ImageTransparency = 0
        icon.Active = false
        icon.Visible = true
        icon.ZIndex = 20
        icon.Parent = self._effectGui
        local tween = TweenService:Create(icon,
            TweenInfo.new(math.random(150, 250) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.fromOffset(start.X + math.random(-100, 100) * scale,
                    screenArea.Max.Y - origin.Y + 100 * scale),
                Rotation = icon.Rotation + math.random(-240, 240),
            })
        local effect = {Tween = tween}
        self._rainEffects[icon] = effect
        --- 下坠完成即释放克隆节点和补间，取消时由统一清理方法处理。
        effect.Connection = tween.Completed:Connect(function()
            self._rainEffects[icon] = nil
            effect.Connection:Disconnect()
            tween:Destroy()
            icon:Destroy()
        end)
        tween:Play()
    end
end

--- 连续奖励与组件销毁时停止上一轮图标雨，不保留临时节点或回调。
function Component:ClearRewardRain()
    for icon, effect in pairs(self._rainEffects) do
        effect.Connection:Disconnect()
        effect.Tween:Cancel()
        effect.Tween:Destroy()
        icon:Destroy()
    end
    table.clear(self._rainEffects)
end

--- 到账时轻微放大力量文字再复原，连续动画不累加缩放。
function Component:PulseStrength()
    if self._pulseTween then
        self._pulseTween:Cancel()
        self._pulseTween:Destroy()
    end
    self._pulseScale.Scale = 1
    self._pulseTween = TweenService:Create(self._pulseScale,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Scale = 1.1})
    self._pulseTween:Play()
end

--- 释放自建节点和未结束动画，保留共用 ScreenGui；基类负责取消数据及按钮监听。
function Component:Dtor()
    if self._rainEffects then
        self:ClearRewardRain()
    end
    if self._trainingStatus then
        self._trainingStatus:Destroy()
    end
    if self._ownsBackpackBoost and self._backpackBoost then
        self._backpackBoost:Destroy()
    end
    FX.Task:Cancel(self._homeTimer)
    FX.Network:UnRegServerMsgCallback("S2C_TrainingEffect")
    FX.Network:UnRegServerMsgCallback("S2C_GiftDropOpened")
    for viewport, connection in pairs(self._pickupEffects or {}) do
        connection:Disconnect()
        viewport:Destroy()
    end
    for icon, effect in pairs(self._effects or {}) do
        task.cancel(effect.Task)
        effect.SizeConnection:Disconnect()
        effect.Tween:Cancel()
        effect.Tween:Destroy()
        icon:Destroy()
    end
    for name, tween in pairs({Progress = self._progressTween, Pulse = self._pulseTween}) do
        tween:Cancel()
        tween:Destroy()
    end
    for name, node in pairs({Pulse = self._pulseScale}) do
        node:Destroy()
    end
    Component.Super.Dtor(self)
end

return Component
