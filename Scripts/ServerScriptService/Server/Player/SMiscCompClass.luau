local FX, FS = _G.FX, _G.FS
local TextService = game:GetService("TextService")
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
local TrainingFields = FXLoader:RequireFromParent(script, "TrainingFields")
local CurrencyShop = FXLoader:RequireShared("Scripts/Game/Shared/CurrencyShop")
local Component = FX.Class("SMiscCompClass", "FSPlayerCompClass")

--- 计算当前重生次数可用的最高训练场倍率，不要求玩家当前站在训练场内。
---@param rebirthCount number 当前重生次数。
---@return number 最高已解锁训练场倍率。
function Component:GetHighestTrainingRate(rebirthCount)
    local highestRate = 0
    for _, config in ipairs(_G.GameConfig.TrainingFieldData) do
        if rebirthCount >= config.NeedRebirhLevel then
            highestRate = math.max(highestRate, config.TrainingRate)
        end
    end
    return highestRate
end

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

--- 普通重生与已支付跳过共用无等待结算，调用方负责资格校验。
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
        player:ShowLocalizedTips("Common.InDevelopment")
        return {success = false}
    end
    local required = Rebirth.GetRequiredLevel(count)
    if self:GetNumber(Fields.RockTrainingLevel) < required then
        player:ShowLocalizedTips("Rebirth.RequiredLevel", {level = required})
        return {success = false}
    end
    self:ApplyRebirth()
    player:ShowLocalizedTips("Rebirth.Success")
    return {success = true}
end

--- 读档后建立排行榜和公开头顶力量显示，并按原频率检查每秒结算条件。
function Component:OnPlayerLogin()
    self._playtimeClock = os.clock()
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

--- 每秒提交累计在线时长，供自动保存和客户端状态同步使用。
--- @param serverTime number 框架每秒更新传入的服务器时间；计时使用单调时钟。
function Component:OnUpdate(serverTime)
    self:UpdateTrainingPlaytime()
    self:SetNumber(Fields.TrainingFriendCount, FS.FriendService:GetFriendCountInRoom(self:GetPlayerId()) or 0)
end

--- 只累计本次已登录会话的在线时间，离服时补齐不足一秒的尾差。
function Component:UpdateTrainingPlaytime()
    if self._playtimeClock then
        local now = os.clock()
        self:AddNumber(Fields.TrainingPlaytime, now - self._playtimeClock)
        self._playtimeClock = now
    end
end

--- 购买倍率与新手加成相加，再乘当前同服好友倍率；不使用每日任务累计人数。
--- @param includeNewPlayerRate boolean 是否为在线训练，力量道具和离线收益不计新手倍率。
--- @param excludeFriendRate boolean? 离线奖励传 true，不计当前同服好友。
--- @return number 本次结算的购买、新手及好友综合倍率。
function Component:GetTrainingBonusRate(includeNewPlayerRate, excludeFriendRate)
    local playtime = self:GetNumber(Fields.TrainingPlaytime)
    if self._playtimeClock then
        playtime += os.clock() - self._playtimeClock
    end
    local newPlayerRate = includeNewPlayerRate and playtime < _G.GameEnum.NewPlayerTrainingDuration
        and _G.GameEnum.NewPlayerTrainingExtraRate or 0
    return (CurrencyShop.GetTrainingRate(self:GetTable(Fields.CurrencyShopData)) + newPlayerRate)
        * (excludeFriendRate and 1 or CurrencyShop.GetFriendTrainingRate(self:GetPlayerObject()))
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

--- 按格式化数字的实际宽度调整整组世界尺寸，保持不同位数的力量显示居中。
function Component:RefreshStrengthBillboard()
    local text = self._strengthText
    local value = GameUtility.NumberToText(self._strengthStat.Value)
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
        return {success = false, key = "Common.Unknown"}
    end
    local world = worldConfig[index]
    if self:GetNumber(Fields.MaxTrainingLevel) < world.NeedTrainingLevel then
        return {
            success = false,
            key = "World.RequiredLevel",
            arguments = {level = world.NeedTrainingLevel},
        }
    end
    local character = self:GetPlayerCharacter()
    if character == nil then
        return {success = false, key = "Common.Unknown"}
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
    if self._strengthText then
        self:RefreshStrengthBillboard()
    end
end

--- 重生结算后刷新派生等级，并清除上一轮尚未结算的训练收益。
function Component:ResetTrainingProgress()
    self:RefreshProgress()
    self._hit = false
    self._lastGrowth = os.clock()
end

--- 力量卡与离线奖励共用训练速率；离线显式排除好友，点击可启用新手加成。
--- @param seconds number 服务端提供的有效训练秒数。
--- @param includeNewPlayerRate boolean? 仅在线点击传 true。
--- @param excludeFriendRate boolean? 仅离线奖励传 true。
--- @return number 当前阶段经验上限内的训练收益。
function Component:GetTrainingCardGain(seconds, includeNewPlayerRate, excludeFriendRate)
    local rebirthCount = self:GetNumber(Fields.RebirthCount)
    local currentValue = self:GetNumber(Fields.RockTrainingValue)
    local maxValue = Rebirth.GetMaxTrainingValue(rebirthCount)
    if currentValue >= maxValue then
        return 0
    end
    local baseGain = _G.NumericalConfig.trainingSettlementsPerSecond * seconds
        * self:GetHighestTrainingRate(rebirthCount)
    baseGain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    baseGain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    baseGain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    baseGain *= self:GetTrainingBonusRate(includeNewPlayerRate == true, excludeFriendRate)
    return math.min(baseGain * Rebirth.GetTrainingRate(rebirthCount), maxValue - currentValue)
end

--- 立即结算力量卡时长，复用训练基础速率、永久倍率和当前阶段经验上限。
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
    self:GetPlayerObject():ShowLocalizedTips("Welfare.TrainingCardGained", {value = gain})
    return true
end

--- 点击复用真实训练速率与永久倍率；服务端限速并检查存活状态，不接受客户端收益。
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
    local gain = self:GetTrainingCardGain(1, true)
    if gain > 0 and self:RequireComponent("FSRewardComp"):AddRewards({
        {Type = "Money", Currency = "RockTrainingValue", Count = gain},
    }) then
        self:RefreshProgress()
        FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain, false, position)
    end
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
        self:GetPlayerObject():ShowLocalizedTips("Training.RequiredRebirths", {count = config.NeedRebirhLevel})
    end
    self._trainingFieldIndex = fieldIndex
    if activeIndex ~= self:GetNumber(Fields.TrainingFieldIndex) then
        self:SetNumber(Fields.TrainingFieldIndex, activeIndex)
        self._lastGrowth = now
        self._hit = false
    end
    return unlocked and config.TrainingRate or 0
end

--- 场内按秒自动训练，替代走路与击打；统一应用装备、图鉴、商店倍率、重生、追赶和经验封顶。
function Component:TickTraining()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:RefreshTrainingField(nil, os.clock())
        self._lastGrowth = os.clock()
        self._hit = false
        return
    end
    local now = os.clock()
    if self._character ~= character then
        self._character = character
        self._lastGrowth = now
        self._hit = false
    end
    local fieldRate = self:RefreshTrainingField(TrainingFields.GetAtPosition(root.Position), now)
    if now - self._lastGrowth < 1 then
        return
    end
    -- 按服务端观察到的水平速度判断移动，站立、腾空和坐下均不发走路收益。
    local velocity = root.AssemblyLinearVelocity
    local walking = humanoid.FloorMaterial ~= Enum.Material.Air and not humanoid.Sit
        and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.5
    local baseGain = (walking and RockLevel.WalkTraining or 0) + (self._hit and 2 or 0)
    if fieldRate > 0 then
        baseGain = _G.NumericalConfig.trainingSettlementsPerSecond * fieldRate
    end
    baseGain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    baseGain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    baseGain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    baseGain *= self:GetTrainingBonusRate(true)
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

--- 离服停止训练结算并清理头顶显示，避免继续持有旧角色。
function Component:OnPlayerLogout()
    self:UpdateTrainingPlaytime()
    self._playtimeClock = nil
    FX.Task:Cancel(self._timer)
    self._timer = nil
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
