local FX = _G.FX
local FXLoader = FX.Loader
local Text = FX.Text
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local InstancePath = FXLoader:RequireShared("Scripts/Game/Shared/InstancePath")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local RouteConfig = _G.TutorialGuideConfig.SecondRebirthGuide
local TranslationTexts = Text.Define("Tutorial", {
    Collect = "Head into World 1's first stage! During this step, every rock there breaks in one swing and drops loot. Pick up 1 piece of loot.",
    Deposit = "Return to your base to store your loot. You can also use HOME.",
    Sell = "Visit the merchant and sell your stored loot for coins!",
    Rate = "Use your 30 welcome diamonds to buy the training multiplier on the right!",
    Weapon = "You earned 100 coins! Visit the weapon shop and equip a better pickaxe.",
    AutomaticTraining = "Train here automatically, even while AFK! Rebirth to unlock training areas with higher multipliers.",
    Done = "Keep getting stronger and discover more valuable loot!",
    Rewards = "Claim your rewards from the Rewards button!",
    Aura = "You're doing great! You can now buy an aura!",
    UpgradeWeapon = "Buy a stronger pickaxe!",
    UpgradeAura = "Buy a stronger aura!",
    RouteTraining = "Follow the arrows to the training base and train until Level {level:int}!",
    RouteCollect = "Follow the arrows on the ground to the mining area. Collect loot to earn coins!",
    RouteWeapon = "Visit the weapon shop. Buy and equip {weapon} for {price} coins!",
    RouteRebirth = "Click Rebirth, then confirm to complete rebirth {count:int}!",
    QuestTraining = "Get stronger!",
    QuestRebirth = "Time to rebirth!",
    QuestCollect = "Collect loot!",
    QuestDeposit = "Return to base!",
    QuestSell = "Sell your loot!",
    QuestWeapon = "Upgrade your pickaxe!",
})

-- 保留引导业务 textId，通过显式映射引用本文件的翻译定义。
local GuideTexts = {
    ["Tutorial.Collect"] = TranslationTexts.Collect,
    ["Tutorial.Deposit"] = TranslationTexts.Deposit,
    ["Tutorial.Sell"] = TranslationTexts.Sell,
    ["Tutorial.Rate"] = TranslationTexts.Rate,
    ["Tutorial.Weapon"] = TranslationTexts.Weapon,
    ["Tutorial.AutomaticTraining"] = TranslationTexts.AutomaticTraining,
    ["Tutorial.Done"] = TranslationTexts.Done,
    ["Tutorial.Rewards"] = TranslationTexts.Rewards,
    ["Tutorial.Aura"] = TranslationTexts.Aura,
    ["Upgrade.Weapon"] = TranslationTexts.UpgradeWeapon,
    ["Upgrade.Aura"] = TranslationTexts.UpgradeAura,
    ["Route.Training"] = TranslationTexts.RouteTraining,
    ["Route.Collect"] = TranslationTexts.RouteCollect,
    ["Route.Weapon"] = TranslationTexts.RouteWeapon,
    ["Route.Rebirth"] = TranslationTexts.RouteRebirth,
    ["Quest.Training"] = TranslationTexts.QuestTraining,
    ["Quest.Rebirth"] = TranslationTexts.QuestRebirth,
    ["Quest.Collect"] = TranslationTexts.QuestCollect,
    ["Quest.Deposit"] = TranslationTexts.QuestDeposit,
    ["Quest.Sell"] = TranslationTexts.QuestSell,
    ["Quest.Weapon"] = TranslationTexts.QuestWeapon,
}
local UIGuideArrow = FXLoader:Require(script.Parent.Parent, "UI/UIGuideArrow")
local RunService = game:GetService("RunService")
local Fields = _G.PlayerDataConfig
local Guide = FX.Class("CTutorialGuideCompClass", "FCTutorialGuideCompClass")

--- 使用现有同步字段，不向服务端发送完成请求。
--- @return string 组件协作名称。
function Guide:GetCompName()
    return "CTutorialGuideComp"
end

--- 两端共用步骤语义。
--- @return table 引导配置。
function Guide:GetGuideConfig()
    return _G.TutorialGuideConfig
end

--- 复用框架持久进度。
--- @return table 引导字段。
function Guide:GetGuideStorage()
    return Fields.Guide
end

--- 创建无点击遮挡的等比提示层；世界目标按当前世界动态查询，角色重生不销毁提示层。
function Guide:OnReady()
    self._localization = self:RequireComponent("FCCommonUIComp").Localization
    self._screen = Instance.new("ScreenGui")
    self._screen.Name = "TutorialGuideUI"
    self._screen.ResetOnSpawn = false
    self._screen.DisplayOrder = 101
    self._screen.RootLocalizationTable = FXLoader:Shared("Shared/Localization")
    self._label = Instance.new("TextLabel")
    self._label.Name = "Instruction"
    self._label.AnchorPoint = Vector2.new(0.5, 0)
    self._label.Position = UDim2.fromScale(0.5, 0.13)
    self._label.Size = UDim2.fromOffset(1024, 48)
    self._label.BackgroundTransparency = 1
    self._label.Font = Enum.Font.GothamBold
    self._label.TextSize = 32
    self._label.TextScaled = true
    self._label.TextWrapped = true
    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MinTextSize = 12
    textSizeConstraint.MaxTextSize = 32
    textSizeConstraint.Parent = self._label
    self._label.TextColor3 = Color3.fromRGB(255, 223, 75)
    self._label.TextStrokeTransparency = 1
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = self._label
    self._label.AutoLocalize = false
    self._label.Text = ""
    self._label.Parent = self._screen
    local scale = Instance.new("UIScale")
    scale.Parent = self._label
    local topCenter = FXLoader:PlayerGui("MainUI/TopCenter")
    local strength = FXLoader:Here(topCenter, "Strength")
    local levelBar = FXLoader:Here(topCenter, "LevelProgressBar")
    --- 与其他界面使用相同设计分辨率，并让提示始终贴在当前顶部 HUD 下方。
    local function updateScale()
        local size = self._screen.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then
            return
        end
        scale.Scale = math.min(size.X / 1280, size.Y / 720)
        local header = strength.Visible and strength or levelBar
        local headerBottom = header.AbsolutePosition.Y + header.AbsoluteSize.Y
        self._label.Position = UDim2.fromScale(0.5, (headerBottom + 8 * scale.Scale) / size.Y)
    end
    self:TrackConnection(self._screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale))
    for index, node in ipairs({strength, levelBar}) do
        self:TrackConnection(node:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateScale))
        self:TrackConnection(node:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale))
    end
    self:TrackConnection(strength:GetPropertyChangedSignal("Visible"):Connect(updateScale))
    self._screen.Parent = FXLoader:Here(self:GetPlayerNode(), "PlayerGui", math.huge)
    updateScale()
    self._uiArrow = UIGuideArrow.New(self._screen.Parent)
    self._rateButton = FXLoader:PlayerGui("MainUI/RightCenter/DoubleStrengthButton")
    self._homeButton = FXLoader:PlayerGui("MainUI/TopCenter/HomeButton")
    self._rewardButton = FXLoader:PlayerGui("MainUI/LeftCenter/RewardBtn")
    self._purchaseScreen = FXLoader:PlayerGui("ShopPurchaseUI")
    self._questPanel = FXLoader:PlayerGui("MainUI/QuestPanel")
    self._questTitle = FXLoader:Here(self._questPanel, "GoalTxt")
    self._questDescription = FXLoader:Here(self._questPanel, "DescriptionTxt")
    self._questProgress = FXLoader:Here(self._questPanel, "ProgressTxt")
    self._questTitle.AutoLocalize = false
    self._questDescription.AutoLocalize = false
    self._questProgress.AutoLocalize = false
    self._questPanel.Visible = false
    self:TrackConnection(self._localization.Changed:Connect(function()
        self:RefreshText()
    end))
    Guide.Super.OnReady(self)
    self:WatchDataChanged(Fields.Money, self.RefreshUpgradeHint, self)
    self:WatchDataChanged(Fields.WeaponData, self.RefreshUpgradeHint, self)
    self:WatchDataChanged(Fields.AuraData, self.RefreshUpgradeHint, self)
    for index, field in ipairs({Fields.RockTrainingLevel, Fields.RebirthCount, Fields.Money,
        Fields.RockLoot, Fields.CurrencyShopData, Fields.RockLootCapacityBoost}) do
        self:WatchDataChanged(field, self.RefreshQuestProgress, self)
    end
    local elapsed = 0
    self:TrackConnection(RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= 0.25 then
            elapsed = 0
            self:RefreshUpgradeHint()
            self:RefreshTarget()
        end
    end))
end

--- 原新手教学使用顶部文字，后续固定任务只更新右上角任务面板；数值和标题均从配置读取。
function Guide:RefreshText()
    local target = self._activeTarget
    self._label.AutoLocalize = false
    local parameters
    if target and self._routeGuideRunning then
        local weapon = Weapon.GetConfig(RouteConfig.weaponId)
        parameters = {
            level = target.level, count = target.count or RouteConfig.lootCount,
            world = RouteConfig.worldIndex, stage = RouteConfig.stageIndex,
            weapon = Text.TrSource(weapon.Name), price = GameUtility.NumberToText(weapon.Price),
        }
    end
    local instruction = target and Text.Tr(GuideTexts[target.textId], parameters) or ""
    local showQuest = self._routeGuideRunning and target ~= nil
    self._questPanel.Visible = showQuest == true
    self._questTitle.Text = showQuest and Text.Tr(GuideTexts[self._questTitleTextId]) or ""
    self._questDescription.Text = showQuest and instruction or ""
    self._label.Text = not showQuest and instruction or ""
    self:RefreshQuestProgress()
end

--- 按任务配置显示黄色数字进度；金币只统计已到账余额，不把未出售战利品当作现金。
function Guide:RefreshQuestProgress()
    local target = self._questStep
    local kind = target and target.progress
    local current, required
    if self._activeTarget and kind == "Level" then
        current, required = self:GetNumber(Fields.RockTrainingLevel), target.level
    elseif self._activeTarget and kind == "Rebirth" then
        current, required = self:GetNumber(Fields.RebirthCount), target.count
    elseif self._activeTarget and kind == "Loot" then
        current = #self:GetTable(Fields.RockLoot)
        local capacity = RockLevel.LootCapacity + self:GetTable(Fields.CurrencyShopData).capacity
        local boost = self:GetTable(Fields.RockLootCapacityBoost)
        if boost.expiresAt > workspace:GetServerTimeNow() then
            capacity += boost.count
        end
        required = math.min(RouteConfig.lootCount, capacity)
    elseif self._activeTarget and kind == "Money" then
        current = GameUtility.NumberToText(self:GetNumber(Fields.Money))
        required = GameUtility.NumberToText(Weapon.GetConfig(RouteConfig.weaponId).Price)
    end
    self._questProgress.Text = current ~= nil and tostring(current) .. "/" .. tostring(required) or ""
    self._questProgress.Visible = current ~= nil
end

--- 首轮完成后展示服务端固定路线；路线结束才恢复普通装备升级提醒。
--- @param guideData table 服务端同步的引导进度。
function Guide:OnGuideDataChanged(guideData)
    local first = guideData.guideMap and guideData.guideMap.FirstLootGuide
    self._mainGuideFinished = first ~= nil and first.state == "Finished"
    self._routeGuideRunning = guideData.activeGuideId == "SecondRebirthGuide"
    local route = guideData.guideMap and guideData.guideMap.SecondRebirthGuide
    self._questStep = self._routeGuideRunning and RouteConfig.steps[route.stepIndex].target or nil
    -- 标题来自当前配置，不依赖旧存档目标中是否已经保存了新增展示字段。
    self._questTitleTextId = self._routeGuideRunning and RouteConfig.steps[route.stepIndex].target.titleTextId or nil
    self._routeGuideFinished = route ~= nil and route.state == "Finished"
    if self._mainGuideFinished and not self._routeGuideRunning then
        Guide.Super.OnGuideDataChanged(self, {target = {type = "None"}})
        self:RefreshUpgradeHint()
    else
        Guide.Super.OnGuideDataChanged(self, guideData)
    end
end

--- 与主界面共用购买资格、开放上限和提醒优先级，避免箭头与文案指向不同目标。
--- @return string? 可购买升级的商店类型。
function Guide:GetAffordableUpgradeType()
    local reminder, trainingConfig, shopType = self:RequireComponent("CMainUIComp"):GetPriorityReminder()
    return shopType
end

--- 固定路线结束后才允许普通购买提醒接管箭头，避免打断当前教学步骤。
function Guide:RefreshUpgradeHint()
    if not self._mainGuideFinished or not self._routeGuideFinished then
        return
    end
    local shopType = self:GetAffordableUpgradeType()
    if (self._activeTarget and self._activeTarget.type) == shopType then
        return
    end
    self:OnExitGuide(self._activeTarget)
    if shopType then
        self:OnEnterGuide({type = shopType, textId = "Upgrade." .. shopType, upgrade = true})
    end
end

--- 进入步骤时展示服务端目标，定期恢复角色重生后的箭头。
--- @param target table 服务端同步的目标。
function Guide:OnEnterGuide(target)
    self._activeTarget = target
    self:RefreshText()
    self:RefreshTarget()
end

--- 退出步骤清理世界箭头、界面箭头与旧提示。
--- @param target table 刚结束的目标，由框架提供。
function Guide:OnExitGuide(target)
    self._activeTarget = nil
    self._uiGuideButton = nil
    self:HideGuideArrow()
    self._uiArrow:Hide()
    self:RefreshText()
end

--- 商店尚未就绪时等待下一次刷新；就绪后优先装备，再推荐买得起的升级。
--- @param target table 当前主引导或持续升级提醒目标。
--- @return GuiButton? 当前可执行操作的按钮。
function Guide:GetShopGuideButton(target)
    local isWeapon = target.type == "Weapon"
    local shop = self:RequireComponent(isWeapon and "CWeaponShopUIComp" or "CAuraShopUIComp")
    if not shop.Root or not shop.State or not shop.Root.Enabled or not shop.State.open or shop._requestTask then
        return nil
    end
    local items = isWeapon and shop.Config.weapons or shop.Config.auras
    if self._routeGuideRunning and isWeapon then
        local goal = Weapon.GetConfig(RouteConfig.weaponId)
        local selectedId = tostring(goal.ToolId)
        local selectedStrength = goal.TrainingRate
        for index, item in ipairs(items) do
            if shop.State.owned[item.id] and item.strength >= selectedStrength then
                selectedId, selectedStrength = item.id, item.strength
            end
        end
        local entry = shop.Rows[selectedId]
        return entry and entry.button
    end
    local strongest = 1
    for index, item in ipairs(items) do
        if shop.State.owned[item.id] then
            strongest = math.max(strongest, item.strength)
        end
    end
    local selected
    if not target.upgrade then
        for index, item in ipairs(items) do
            if shop.State.owned[item.id] and item.strength > 1 and item.id ~= shop.State.equippedId
                and (not selected or item.strength > selected.strength) then
                selected = item
            end
        end
    end
    if not selected then
        for index, item in ipairs(items) do
            if not shop.State.owned[item.id] and item.strength > strongest and item.price <= shop.State.coins
                and (not selected or item.price < selected.price) then
                selected = item
            end
        end
    end
    local entry = selected and shop.Rows[selected.id]
    return entry and entry.button
end

--- 按当前步骤选择按钮；倍率已到账或确认页已购买时不再高亮旧按钮。
--- @param target table 当前引导目标。
--- @return GuiButton? 当前可见界面中需要操作的按钮。
function Guide:GetUIGuideButton(target)
    if target.textId == "Tutorial.Rate" then
        local purchase = self:RequireComponent("CShopPurchaseUIComp")
        local product = purchase._product
        local isTrainingRate = product and _G.GoodsConfig.GemGoodsData[product.goodsId].BuyHandler == "TrainingRateLevel"
        if self:GetTable(Fields.CurrencyShopData).trainingLevel > 0 then
            return nil
        end
        if self._purchaseScreen.Enabled then
            if isTrainingRate and purchase.State.status == "Ready" and not purchase.State.pending then
                return purchase.BuyBtn
            end
        elseif not self:RequireComponent("FCCommonUIComp"):IsTrainingClickBlocked() then
            return self._rateButton
        end
    elseif target.type == "Base" then
        if not self:RequireComponent("FCCommonUIComp"):IsTrainingClickBlocked() and self._homeButton.Visible then
            return self._homeButton
        end
    elseif target.type == "Rewards" then
        if not self:RequireComponent("FCCommonUIComp"):IsTrainingClickBlocked() then
            return self._rewardButton
        end
    elseif target.type == "Sell" then
        local sell = self:RequireComponent("CLootSellUIComp")
        if sell.State and sell:GetRootNode().Enabled and sell.State.isOpen and not sell.State.pending and #sell.State.items > 0 then
            return sell.SellAllBtn
        end
    elseif target.type == "Weapon" or target.type == "Aura" then
        return self:GetShopGuideButton(target)
    end
    return nil
end

--- 原新手 UI 操作恢复遮罩（奖励提醒除外）；后续任务仅用箭头，进入矿区后指向附近未碎藏宝石头。
function Guide:RefreshTarget()
    local target = self._activeTarget
    local worldIndex = self:GetNumber(Fields.WorldIndex)
    local trainingConfig
    local portalWorld
    if self._mainGuideFinished and self._routeGuideFinished then
        local reminder, field, shopType, world = self:RequireComponent("CMainUIComp"):GetPriorityReminder()
        trainingConfig = field
        portalWorld = world
    end
    if target and target.type == "Training" then
        trainingConfig = GameUtility.GetBestTrainingField(worldIndex, self:GetNumber(Fields.RebirthCount))
    end
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if (not target and not trainingConfig and not portalWorld) or not humanoid or humanoid.Health <= 0 then
        self._uiGuideButton = nil
        self:HideGuideArrow()
        self._uiArrow:Hide()
        return
    end
    if portalWorld then
        self._uiGuideButton = nil
        self._uiArrow:Hide()
        local portal = FXLoader:Find(workspace, portalWorld.PortalPath)
        if portal then
            local center, size = portal:GetBoundingBox()
            self:ShowGuideArrowToPosition(center.Position - Vector3.new(0, size.Y / 2 - 3, 0))
        else
            self:HideGuideArrow()
        end
        return
    end
    if trainingConfig then
        self._uiGuideButton = nil
        self._uiArrow:Hide()
        local field = InstancePath.Find(trainingConfig.Node)
        local platform = field and field:FindFirstChild("彩色训练台", true)
        if platform and platform:IsA("BasePart") then
            self:ShowGuideArrowToPosition(platform.Position)
        else
            self:HideGuideArrow()
        end
        return
    end
    local button = self:GetUIGuideButton(target)
    if button then
        -- 切换商品时将目标滚入视野；同一目标不反复改动玩家的滚动位置。
        if self._uiGuideButton ~= button then
            local list = button:FindFirstAncestorWhichIsA("ScrollingFrame")
            if list then
                local offset = button.AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y
                local maximum = math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)
                list.CanvasPosition = Vector2.new(list.CanvasPosition.X,
                    math.clamp(offset - (list.AbsoluteWindowSize.Y - button.AbsoluteSize.Y) / 2, 0, maximum))
            end
        end
        self._uiGuideButton = button
        self._uiArrow:Show(button, target.type == "Rewards" and "Right" or "Left",
            not self._mainGuideFinished and target.type ~= "Rewards")
        self:HideGuideArrow()
        return
    end
    self._uiGuideButton = nil
    self._uiArrow:Hide()
    local position
    if target.type == "NearestItem" then
        local coordinates = target.position
        position = coordinates and Vector3.new(coordinates[1], coordinates[2], coordinates[3])
    elseif target.type == "Base" then
        position = _G.GameEnum.WorldTransferConfig[worldIndex].Position
    elseif target.type == "Mining" then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            position = self:RequireComponent("CRockLevelComp"):GetMiningGuidePosition(root.Position,
                RouteConfig.worldIndex, RouteConfig.stageIndex)
        end
    else
        local names = {Sell = "Shop", Weapon = "PurpleHut", Aura = "BlueHut"}
        local name = names[target.type]
        local shopPath = "Decorations/World" .. worldIndex .. "Decorations/"
        if worldIndex > 1 then
            shopPath ..= "World" .. worldIndex .. "Shops/"
        end
        local trigger = name and FXLoader:Find(workspace, shopPath .. name .. "/Trigger")
        position = trigger and trigger.Position
    end
    if position then
        self:ShowGuideArrowToPosition(position)
    else
        self:HideGuideArrow()
    end
end

--- 两片薄楔形拼出尖端朝向目标的三角形，避免纹理透明度和朝向影响识别。
--- @param position Vector3 世界目标。
function Guide:ShowGuideArrowToPosition(position)
    self._worldTargetPosition = position
    if not self._arrowTrans then
        local decorations = FXLoader:Workspace("Decorations")
        local arrow = Instance.new("Part")
        arrow.Name = "TutorialGuideArrow"
        arrow.Size = Vector3.new(0.1, 0.1, 0.1)
        arrow.Anchored = true
        arrow.CanCollide, arrow.CanTouch, arrow.CanQuery = false, false, false
        arrow.Transparency = 1
        arrow.CastShadow = false
        self._arrowTriangles = {}
        arrow.Parent = decorations
        self._arrowTrans = arrow
        self._renderSteppedConn = RunService.RenderStepped:Connect(function()
            self:UpdateGuideArrow()
        end)
    end
    self:UpdateGuideArrow()
end

--- 固定间距与滚动周期，移动时只增减末端三角；箭头平铺在水平面并平滑隐藏首尾。
function Guide:UpdateGuideArrow()
    local character = self:GetPlayerCharacter()
    local root = character and FXLoader:Find(character, "HumanoidRootPart")
    if not self._arrowTrans then
        return
    end
    local camera = workspace.CurrentCamera
    local origin = root and root.Position - Vector3.new(0, 2.5, 0)
    local target = self._worldTargetPosition and self._worldTargetPosition + Vector3.new(0, 0.5, 0)
    local direction = origin and target and target - origin
    local distance = direction and direction.Magnitude or 0
    local spacing = 4
    local count = root and camera and math.min(32, math.max(0, math.ceil((distance - 3.1) / spacing))) or 0
    local now = os.clock()
    local forward, side, normal, flatForward
    local flatDirection = direction and Vector3.new(direction.X, 0, direction.Z)
    local flatDistance = flatDirection and flatDirection.Magnitude or 0
    if count > 0 and flatDistance > 0.01 then
        forward = direction.Unit
        flatForward = flatDirection / flatDistance
        side = Vector3.new(0, 1, 0):Cross(flatForward)
        normal = Vector3.new(0, 1, 0)
    else
        count = 0
    end
    for index = 1, math.max(count, #self._arrowTriangles) do
        local triangle = self._arrowTriangles[index]
        if not triangle then
            triangle = {}
            for half = 1, 2 do
                local wedge = Instance.new("WedgePart")
                wedge.Name = "Triangle" .. index .. "Half" .. half
                wedge.Size = Vector3.new(0.04, 1, 2.2)
                wedge.Anchored = true
                wedge.CanCollide, wedge.CanTouch, wedge.CanQuery = false, false, false
                wedge.CastShadow = false
                wedge.Material = Enum.Material.Neon
                wedge.Parent = self._arrowTrans
                triangle[half] = wedge
            end
            self._arrowTriangles[index] = triangle
        end
        local along = index <= count and 2 + (index - 1) * spacing + (now * 1.5) % spacing
        local visible = along and along < distance - 1.1
        for half, wedge in ipairs(triangle) do
            local visibility = visible and math.clamp(math.min(along - 2, distance - 1.1 - along) / 0.6, 0, 1) or 0
            wedge.Transparency = 1 - 0.95 * visibility
            if visible then
                local sign = half == 1 and 1 or -1
                local center = origin + forward * along + side * (sign * 0.5)
                wedge.CFrame = CFrame.fromMatrix(center, normal * sign, side * sign, -flatForward)
                wedge.Color = Color3.fromHSV((along / distance - now * 0.2) % 1, 0.85, 1)
            end
        end
    end
end

--- 清理提示层、刷新连接与全部箭头实例。
function Guide:Dtor()
    if self._screen then
        self:OnExitGuide(self._activeTarget)
        self._uiArrow:Destroy()
        self._screen:Destroy()
    end
    Guide.Super.Dtor(self)
end

return Guide
