local FX, FS = _G.FX, _G.FS
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
local TranslationTexts = Text.Define("Misc", {
    InDevelopment = "Coming soon.",
    RebirthRequiredLevel = "Reach level {level:int} to rebirth.",
    Unknown = "Something went wrong. Please try again.",
    WorldRequiredLevel = "Reach a best level of {level:int} to unlock this world.",
    TrainingCardGained = "Gained {value} Strength.",
    TrainingRequiredRebirths = "Requires {count:int} rebirths to train here.",
    RebirthReady = "Rebirth is ready! Rebirth to keep growing stronger.",
    NeedDiamonds = "Not enough diamonds.",
    RebirthOfferChanged = "This rebirth offer has changed. Please try again.",
})
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local TrainingFields = FXLoader:RequireFromParent(script, "TrainingFields")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local RankingTypes = {}
for index, config in ipairs(_G.RankingDataConfig) do
    RankingTypes[config.Name] = config
end
local Component = FX.Class("SMiscCompClass", "FSPlayerCompClass")

--- 持有训练结算状态，通过服务端关卡事件接收有效击打。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._lastGrowth = os.clock()
    self._hit = false
    self:SubscribeEvent("RockTrainingHit", self.RecordTrainingHit)
    self:SubscribeEvent("RockRoundReset", self.ClearTrainingHit)
    self:SubscribeEvent("RockAttackReset", self.ClearTrainingHit)
end

--- 集中承接不需要独立系统组件的简单玩家业务。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SMiscComp"
end

--- 普通重生执行次数增加与训练重置，调用方负责资格校验。
function Component:ApplyRebirth()
    self:AddNumber(Fields.RebirthCount, 1)
    self:SetNumber(Fields.RockTrainingValue, 0)
    self:ResetTrainingProgress()
end

--- 等级和次数只取服务端数据；重置后重复请求无法再次满足门槛。
--- @return table 重生是否成功。
function Component:HandleRebirth()
    if not self._levelStat then
        return {success = false}
    end
    local player = self:GetPlayerObject()
    local count = self:GetNumber(Fields.RebirthCount)
    if count >= Rebirth.MaxCount then
        player:ShowLocalizedTips(TranslationTexts.InDevelopment)
        return {success = false}
    end
    local required = Rebirth.GetRequiredLevel(count)
    if self:GetNumber(Fields.RockTrainingLevel) < required then
        player:ShowLocalizedTips(TranslationTexts.RebirthRequiredLevel, {level = required})
        return {success = false}
    end
    self:ApplyRebirth()
    return {success = true}
end

--- 钻石跳过沿用原付费效果，保留力量和等级；客户端只提交看到的次数以拒绝重复旧请求。
--- @param expectedCount any 客户端请求前看到的重生次数，不接受客户端价格。
--- @return table 权威结算结果、余额不足原因与成功后的重生次数。
function Component:HandleSkipRebirth(expectedCount)
    if not self._levelStat then
        return {success = false}
    end
    local player = self:GetPlayerObject()
    local count = self:GetNumber(Fields.RebirthCount)
    local goods = Rebirth.GetSkipGoods(count)
    if expectedCount ~= count or not goods then
        player:ShowLocalizedTips(TranslationTexts.RebirthOfferChanged)
        return {success = false}
    end
    if self:GetNumber(Fields.Diamonds) < goods.Price then
        player:ShowLocalizedTips(TranslationTexts.NeedDiamonds)
        return {success = false, reason = "NeedDiamonds"}
    end
    -- 事务内不 yield、不发送提示，扣款与重生次数必须一起提交或回滚。
    local success = player:RunDataTransaction(function()
        player:AddNumber(Fields.Diamonds, -goods.Price)
        player:AddNumber(Fields.RebirthCount, 1)
        return true
    end)
    if not success then
        player:ShowLocalizedTips(TranslationTexts.Unknown)
        return {success = false}
    end
    self:RequireComponent("SAnalyticsComp"):Sink("Diamonds", goods.Price,
        self:GetNumber(Fields.Diamonds), "SkipRebirth:" .. goods.GemGoodsId)
    return {success = true, count = count + 1}
end

--- 读档后建立排行榜和公开头顶力量显示，并按原频率检查每秒结算条件。
function Component:OnPlayerLogin()
    self:SetNumber(Fields.TrainingFriendCount, FS.FriendService:GetFriendCountInRoom(self:GetPlayerId()) or 0)
    TrainingFields.GetFields()
    local player = self:GetPlayerNode()
    -- 当前唯一启用的出生点位于世界 1；新角色出生时同步重置世界，恢复原世界传送资格。
    self:TrackConnection(player.CharacterAdded:Connect(function()
        self:SetNumber(Fields.WorldIndex, 1)
    end))
    self._stats = player:FindFirstChild("leaderstats")
    self._ownsStats = self._stats == nil
    if self._ownsStats then
        self._stats = Instance.new("Folder")
        self._stats.Name = "leaderstats"
        self._stats.Parent = player
    end
    self._levelStat = Instance.new("IntValue")
    self._levelStat.Name = "Level"
    self._levelStat.Parent = self._stats
    self._strengthStat = Instance.new("NumberValue")
    self._strengthStat.Name = "Strength"
    self._strengthStat.Parent = self._stats
    self._rankingScores = {}
    self:RefreshProgress()
    self:TrackConnection(player.CharacterAdded:Connect(function(character)
        self:BindStrengthCharacter(character)
    end))
    self:TrackConnection(player.CharacterRemoving:Connect(function(character)
        if character == self._strengthCharacter then
            self:BindStrengthCharacter(nil)
        end
    end))
    self:BindStrengthCharacter(player.Character)
    self._timer = FX.Task:Interval(0.1, function()
        self:TickTraining()
    end)
end

--- 每秒刷新同服好友人数与真实榜单分数；在线时长复用分析组件的服务端累计记账。
--- @param serverTime number 框架每秒更新传入的服务器时间，本组件不使用。
function Component:OnUpdate(serverTime)
    self:SetNumber(Fields.TrainingFriendCount, FS.FriendService:GetFriendCountInRoom(self:GetPlayerId()) or 0)
    self:RefreshRankingScores()
end

--- 只将服务端权威值写入总榜；保留历史最高力量，重生清零不撤销已有成绩。
function Component:RefreshRankingScores()
    if not self._rankingScores then
        return
    end
    local scores = {
        Strength = self._strengthStat.Value,
        Rebirth = self:GetNumber(Fields.RebirthCount),
        Playtime = self:GetNumber(Fields.TrainingPlaytime),
    }
    local player = self:GetPlayerObject()
    for name, score in pairs(scores) do
        local config = RankingTypes[name]
        -- 使用整数原始分数；重进服务器时也不让尚未加载的云榜缓存覆盖持久最高分。
        score = math.max(math.floor(score), player:GetRankingScore(config) or config.DefaultValue)
        if self._rankingScores[name] ~= score then
            player:UpdateRankingScore(config, score)
            self._rankingScores[name] = score
        end
    end
end

--- 付费倍率加当前同服好友额外倍率；不使用每日任务累计人数。
--- @param excludeFriendRate boolean? 离线奖励传 true，不计当前同服好友。
--- @return number 本次结算的付费及好友综合倍率。
function Component:GetTrainingBonusRate(excludeFriendRate)
    return CurrencyShop.GetTrainingRate(self:GetTable(Fields.CurrencyShopData))
        + (excludeFriendRate and 0 or CurrencyShop.GetFriendTrainingRate(self:GetPlayerObject()))
end

--- 更换角色时清理旧显示；头部尚未加载时监听其到达，不阻塞登录。
--- @param character Model? 当前角色，nil 表示移除或离服。
function Component:BindStrengthCharacter(character)
    if self._strengthHeadConnection then
        self._strengthHeadConnection:Disconnect()
        self._strengthHeadConnection = nil
    end
    if self._strengthBillboard then
        self._strengthBillboard:Destroy()
        self._strengthBillboard = nil
        self._strengthText = nil
    end
    self._strengthCharacter = character
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        self:CreateStrengthBillboard(head)
    else
        self._strengthHeadConnection = character.ChildAdded:Connect(function(child)
            if child.Name == "Head" and child:IsA("BasePart") then
                self._strengthHeadConnection:Disconnect()
                self._strengthHeadConnection = nil
                self:CreateStrengthBillboard(child)
            end
        end)
    end
end

--- 由服务端创建按世界尺寸缩放的头顶显示，图标与数字整体居中。
--- @param head BasePart 当前角色头部，兼容 R6 和 R15。
function Component:CreateStrengthBillboard(head)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "StrengthBillboard"
    billboard.Adornee = head
    billboard.Size = UDim2.fromScale(1, 0.9)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100

    local icon = Instance.new("ImageLabel")
    icon.Name = "StrengthIcon"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromScale(1, 1)
    icon.Image = "rbxassetid://123326023432901"
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = billboard

    local text = Instance.new("TextLabel")
    text.Name = "StrengthText"
    text.BackgroundTransparency = 1
    text.AnchorPoint = Vector2.new(0, 0.5)
    text.Position = UDim2.fromScale(0, 0.5)
    text.Size = UDim2.fromScale(1, 28 / 44)
    text.Font = Enum.Font.GothamBlack
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.AutoLocalize = false
    text.Parent = billboard

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = text

    self._strengthBillboard = billboard
    self._strengthText = text
    self:RefreshStrengthBillboard()
    billboard.Parent = head
end

--- 显示当前累积力量而非等级曲线攻击力，并按数字宽度保持整组居中。
function Component:RefreshStrengthBillboard()
    local text = self._strengthText
    local value = GameUtility.NumberToText(self:GetNumber(Fields.RockTrainingValue))
    local textWidth = TextService:GetTextSize(value, 28, text.Font, Vector2.new(1000, 44)).X + 4
    local width = 44 + 6 + textWidth
    self._strengthBillboard.Size = UDim2.fromScale(width / 44 * 0.9, 0.9)
    self._strengthBillboard.StrengthIcon.Size = UDim2.fromScale(44 / width, 1)
    text.Position = UDim2.fromScale(50 / width, 0.5)
    text.Size = UDim2.fromScale(textWidth / width, 28 / 44)
    text.Text = value
end

--- 校验世界序号与历史最高等级后，把角色移动到配置落点并同步当前世界。
--- @param index any 客户端请求的世界传送序号，从 1 开始。
--- @return table 权威结果；失败时给出客户端提示 Key 与参数。
function Component:HandleTransferWorld(index)
    local worldConfig = _G.GameEnum.WorldTransferConfig
    if type(index) ~= "number" or index ~= math.floor(index)
        or index < 1 or index > #worldConfig
    then
        return {success = false, key = TranslationTexts.Unknown}
    end
    local world = worldConfig[index]
    if self:GetNumber(Fields.MaxTrainingLevel) < world.NeedTrainingLevel then
        return {
            success = false,
            key = TranslationTexts.WorldRequiredLevel,
            arguments = {level = world.NeedTrainingLevel},
        }
    end
    local character = self:GetPlayerCharacter()
    if character == nil then
        return {success = false, key = TranslationTexts.Unknown}
    end
    -- 落点只取服务端配置，离场后训练基地按新位置自动结算。
    character:PivotTo(CFrame.new(world.Position))
    self:SetNumber(Fields.WorldIndex, index)
    return {success = true, index = index}
end

--- 将持久训练值派生为同步等级，并同步排行榜、玩家属性与头顶力量。
function Component:RefreshProgress()
    local count = self:GetNumber(Fields.RebirthCount)
    local value = math.min(self:GetNumber(Fields.RockTrainingValue), Rebirth.GetMaxTrainingValue(count))
    self:SetNumber(Fields.RockTrainingValue, value)
    local level, strength = RockLevel.GetProgress(value, Rebirth.GetRequiredLevel(count))
    self:SetNumber(Fields.RockTrainingLevel, level)
    if level > self:GetNumber(Fields.MaxTrainingLevel) then
        self:SetNumber(Fields.MaxTrainingLevel, level)
    end
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingLevel", level)
    player:SetAttribute("Strength", strength)
    self._levelStat.Value = level
    self._strengthStat.Value = strength
    self:RefreshRankingScores()
    if self._strengthText then
        self:RefreshStrengthBillboard()
    end
end

--- 重生结算后刷新派生等级，并清除上一轮尚未结算的训练收益。
function Component:ResetTrainingProgress()
    self:ClearTrainingBonus()
    self:RefreshProgress()
    self._hit = false
    self._lastGrowth = os.clock()
end

--- 力量卡与离线共用两端一致的分段追赶结算，不计好友。
--- @param seconds number 服务端提供的有效训练秒数。
--- @return number 当前阶段经验上限内的训练收益。
function Component:GetTrainingCardGain(seconds)
    return CurrencyShop.GetTrainingCardGain(self:GetPlayerObject(), seconds)
end

--- 主动点击不计场地与追赶，保留付费加好友以及其他通用倍率。
--- @return number 当前阶段经验上限内的单次点击收益。
function Component:GetTrainingClickGain()
    local rebirthCount = self:GetNumber(Fields.RebirthCount)
    local currentValue = self:GetNumber(Fields.RockTrainingValue)
    local maxValue = Rebirth.GetMaxTrainingValue(rebirthCount)
    if currentValue >= maxValue then
        return 0
    end
    local baseGain = _G.NumericalConfig.trainingSettlementsPerSecond
    baseGain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    baseGain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    baseGain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    baseGain *= self:GetTrainingBonusRate()
    return math.min(baseGain * Rebirth.GetTrainingRate(rebirthCount), maxValue - currentValue)
end

--- 等级达到界面 100% 门槛时提醒重生，连续点击和用卡共用提示间隔。
function Component:ShowRebirthReminder()
    local count = self:GetNumber(Fields.RebirthCount)
    if count >= Rebirth.MaxCount or self:GetNumber(Fields.RockTrainingLevel) < Rebirth.GetRequiredLevel(count) then
        return
    end
    local now = os.clock()
    if self._lastRebirthReminder and now - self._lastRebirthReminder < 3 then
        return
    end
    self._lastRebirthReminder = now
    self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.RebirthReady)
end

--- 立即结算力量卡时长，计最高已解锁场地倍率与分段追赶，不计好友，达标后提醒重生。
---@param seconds number 力量卡提供的训练秒数。
---@return boolean 是否实际增加了训练值。
function Component:ApplyTrainingCard(seconds)
    if type(seconds) ~= "number" or seconds <= 0 or seconds == math.huge or seconds ~= seconds then
        return false
    end
    local gain = self:GetTrainingCardGain(seconds)
    if gain <= 0 then
        return false
    end
    if not self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "Money", Currency = "RockTrainingValue", Count = gain},
    }) then
        return false
    end
    self:RefreshProgress()
    local notified, message = pcall(FX.Network.SendMsgToClient, FX.Network,
        self:GetPlayerId(), "S2C_TrainingEffect", gain, true)
    if not notified then
        warn("[TrainingCard] reward notification failed", message)
    end
    self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.TrainingCardGained, {value = GameUtility.NumberToText(gain)})
    self:ShowRebirthReminder()
    return true
end

--- 点击只应用通用训练倍率，不享受场地与追赶加成；服务端限速并检查存活状态，达标后提醒重生。
--- @param position Vector2 客户端飘字起点，仅用于表现。
function Component:HandleTrainingClick(position)
    if typeof(position) ~= "Vector2" or position.X ~= position.X or position.Y ~= position.Y
        or math.abs(position.X) == math.huge or math.abs(position.Y) == math.huge then
        return
    end
    local now = os.clock()
    if self._lastTrainingClick and now - self._lastTrainingClick < RockLevel.ClickInterval then
        return
    end
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end
    self._lastTrainingClick = now
    local gain = self:GetTrainingClickGain()
    if gain > 0 and self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "Money", Currency = "RockTrainingValue", Count = gain},
    }) then
        self:RefreshProgress()
        FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain, false, position)
    end
    self:ShowRebirthReminder()
end

--- 同一结算周期多次有效命中只计一份基础击打收益。
function Component:RecordTrainingHit()
    self._hit = true
end

--- 凭据或轮次失效时撤销尚未结算的击打，不影响正常走路结算。
function Component:ClearTrainingHit()
    self._hit = false
end

--- 场地切换重新计时；未解锁只在进入时提示，解锁条件每次检查均取服务端存档。
--- @param config table? 当前所在训练基地配置。
--- @param now number 当前单调时间。
--- @return number 已解锁场地倍率，场外或未解锁时为 0。
function Component:RefreshTrainingField(config, now)
    local fieldIndex = config and config.Index or 0
    local unlocked = config and self:GetNumber(Fields.RebirthCount) >= config.NeedRebirhLevel
    local activeIndex = unlocked and fieldIndex or 0
    if fieldIndex ~= self._trainingFieldIndex and config and not unlocked then
        self:GetPlayerObject():ShowLocalizedTips(TranslationTexts.TrainingRequiredRebirths, {count = config.NeedRebirhLevel})
    end
    self._trainingFieldIndex = fieldIndex
    if activeIndex ~= self:GetNumber(Fields.TrainingFieldIndex) then
        self:ClearTrainingBonus()
        self:SetNumber(Fields.TrainingFieldIndex, activeIndex)
        self._lastGrowth = now
        self._hit = false
    end
    return unlocked and config.TrainingRate or 0
end

--- 训练场会话变化时撤销气泡和加成；未领取气泡从消失时进入冷却，已有冷却跨场地保留。
function Component:ClearTrainingBonus()
    if self._trainingBonusOffer then
        self._nextTrainingBonus = math.min(workspace:GetServerTimeNow(), self._trainingBonusOffer.ExpiresAt)
            + _G.GameConfig.TrainingBonusConfig.Cooldown
    end
    self._trainingBonusOffer = nil
    self._trainingBonusUntil = nil
    local player = self:GetPlayerNode()
    if player then
        player:SetAttribute("TrainingBonusOfferId", nil)
        player:SetAttribute("TrainingBonusUntil", nil)
    end
end

--- 场内无冷却立即按权重发放气泡；未领取时从展示到期开始冷却，展示期间不提前计时。
--- @param now number 当前服务器时间。
function Component:TickTrainingBonus(now)
    local config = _G.GameConfig.TrainingBonusConfig
    if self._trainingBonusUntil and now >= self._trainingBonusUntil then
        self._trainingBonusUntil = nil
        self:GetPlayerNode():SetAttribute("TrainingBonusUntil", nil)
    end
    if self._trainingBonusOffer then
        if now < self._trainingBonusOffer.ExpiresAt then
            return
        end
        self._nextTrainingBonus = self._trainingBonusOffer.ExpiresAt + config.Cooldown
        self._trainingBonusOffer = nil
        self:GetPlayerNode():SetAttribute("TrainingBonusOfferId", nil)
    end
    if self._nextTrainingBonus and now < self._nextTrainingBonus then
        return
    end
    local totalWeight = 0
    for index, weight in ipairs(config.Weights) do
        totalWeight += weight
    end
    local roll = Random.new():NextNumber(0, totalWeight)
    local selected = #config.Multipliers
    for index, weight in ipairs(config.Weights) do
        roll -= weight
        if roll < 0 then
            selected = index
            break
        end
    end
    local offer = {Id = HttpService:GenerateGUID(false), Rate = config.Multipliers[selected],
        ExpiresAt = now + config.OfferLifetime}
    self._trainingBonusOffer = offer
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingBonusRate", offer.Rate)
    player:SetAttribute("TrainingBonusOfferUntil", offer.ExpiresAt)
    player:SetAttribute("TrainingBonusOfferId", offer.Id)
end

--- 只接受当前训练会话的有效凭据；领取时同时开始加成和冷却，重复领取不会刷新期限。
--- @param offerId string 客户端提交的气泡凭据，不接受客户端倍率。
function Component:ClaimTrainingBonus(offerId)
    local offer = self._trainingBonusOffer
    if type(offerId) ~= "string" or not offer or offer.Id ~= offerId then
        return
    end
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local field = root and TrainingFields.GetAtPosition(root.Position)
    local now = workspace:GetServerTimeNow()
    if now >= offer.ExpiresAt or character ~= self._character or not humanoid or humanoid.Health <= 0
        or not field or field.Index ~= self:GetNumber(Fields.TrainingFieldIndex)
        or self:GetNumber(Fields.RebirthCount) < field.NeedRebirhLevel then
        return
    end
    self._trainingBonusOffer = nil
    self._nextTrainingBonus = now + _G.GameConfig.TrainingBonusConfig.Cooldown
    self._trainingBonusUntil = now + _G.GameConfig.TrainingBonusConfig.Duration
    self._trainingBonusRate = offer.Rate
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingBonusOfferId", nil)
    player:SetAttribute("TrainingBonusUntil", self._trainingBonusUntil)
end

--- 场内按秒自动训练，替代走路与击打；统一应用装备、图鉴、付费与好友倍率、重生、追赶和经验封顶。
function Component:TickTraining()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:ClearTrainingBonus()
        self:RefreshTrainingField(nil, os.clock())
        self._lastGrowth = os.clock()
        self._hit = false
        return
    end
    local now = os.clock()
    if self._character ~= character then
        self:ClearTrainingBonus()
        self._character = character
        self._lastGrowth = now
        self._hit = false
    end
    local fieldRate = self:RefreshTrainingField(TrainingFields.GetAtPosition(root.Position), now)
    if fieldRate > 0 then
        self:TickTrainingBonus(workspace:GetServerTimeNow())
    end
    if now - self._lastGrowth < 1 then
        return
    end
    -- 按服务端观察到的水平速度判断移动，站立、腾空和坐下均不发走路收益。
    local velocity = root.AssemblyLinearVelocity
    local walking = humanoid.FloorMaterial ~= Enum.Material.Air and not humanoid.Sit
        and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.5
    local baseGain = (walking and RockLevel.WalkTraining or 0) + (self._hit and 1 or 0)
    if fieldRate > 0 then
        baseGain = _G.NumericalConfig.trainingSettlementsPerSecond * fieldRate
        if self._trainingBonusUntil and workspace:GetServerTimeNow() < self._trainingBonusUntil then
            baseGain *= self._trainingBonusRate
        end
    end
    baseGain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    baseGain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    baseGain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    baseGain *= self:GetTrainingBonusRate()
    local gain = Rebirth.GetTrainingGain(self:GetNumber(Fields.RockTrainingValue), baseGain,
        self:GetNumber(Fields.RebirthCount))
    if gain > 0 and self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "Money", Currency = "RockTrainingValue", Count = gain},
    }) then
        self:RefreshProgress()
        FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain)
    end
    -- 不按积压秒数补发，避免卡顿恢复时把无法确认的移动时长算作走路收益。
    self._lastGrowth = now
    self._hit = false
end

--- 先停止训练，再提交分析组件已补齐的最终榜单分数，避免离服结算期间定时器访问玩家。
function Component:OnPlayerLogout()
    FX.Task:Cancel(self._timer)
    self._timer = nil
    self:RefreshRankingScores()
    self._rankingScores = nil
    self:ClearTrainingBonus()
    self:BindStrengthCharacter(nil)
end

--- 释放自身建立的等级和力量节点，保留其他系统拥有的排行榜目录。
function Component:Dtor()
    self:OnPlayerLogout()
    if self._ownsStats then
        self._stats:Destroy()
    else
        if self._levelStat then
            self._levelStat:Destroy()
        end
        if self._strengthStat then
            self._strengthStat:Destroy()
        end
    end
    Component.Super.Dtor(self)
end

return Component
