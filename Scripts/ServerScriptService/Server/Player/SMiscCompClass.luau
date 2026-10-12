local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local Collection = FXLoader:RequireShared("Scripts/Game/Shared/Collection")
local Aura = FXLoader:RequireShared("Scripts/Game/Shared/Aura")
local Weapon = FXLoader:RequireShared("Scripts/Game/Shared/Weapon")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local TrainingFields = FXLoader:RequireFromParent(script, "TrainingFields")
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

--- 等级和次数只取服务端数据；重置后重复请求无法再次满足门槛。
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
    self:AddNumber(Fields.RebirthCount, 1)
    self:SetNumber(Fields.RockTrainingValue, 0)
    self:ResetTrainingProgress()
    player:ShowLocalizedTips("Rebirth.Success")
    return {success = true}
end

--- 读档后建立训练数据显示，并按原频率检查每秒结算条件。
function Component:OnPlayerLogin()
    TrainingFields.GetFields()
    local player = self:GetPlayerNode()
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
    self._timer = FX.Task:Interval(0.1, function()
        self:TickTraining()
    end)
end

--- 校验世界序号与解锁重生次数后，把角色移动到配置落点并同步当前世界。
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
    if self:GetNumber(Fields.RebirthCount) < world.NeedRebirthCount then
        return {
            success = false,
            key = "World.RequiredRebirths",
            arguments = {count = world.NeedRebirthCount},
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

--- 将持久训练值派生为同步等级，并暴露原生玩家属性便于检查。
function Component:RefreshProgress()
    local count = self:GetNumber(Fields.RebirthCount)
    local value = math.min(self:GetNumber(Fields.RockTrainingValue), Rebirth.GetMaxTrainingValue(count))
    self:SetNumber(Fields.RockTrainingValue, value)
    local level, strength = RockLevel.GetProgress(value, Rebirth.GetRequiredLevel(count))
    self:SetNumber(Fields.RockTrainingLevel, level)
    local player = self:GetPlayerNode()
    player:SetAttribute("TrainingLevel", level)
    player:SetAttribute("Strength", strength)
    self._levelStat.Value = level
    self._strengthStat.Value = strength
end

--- 重生结算后刷新派生等级，并清除上一轮尚未结算的训练收益。
function Component:ResetTrainingProgress()
    self:RefreshProgress()
    self._hit = false
    self._lastGrowth = os.clock()
end

--- 立即结算力量卡时长，复用训练基础速率、永久倍率和当前阶段经验上限。
---@param seconds number 力量卡提供的训练秒数。
---@return boolean 是否实际增加了训练值。
function Component:ApplyTrainingCard(seconds)
    if type(seconds) ~= "number" or seconds <= 0 or seconds == math.huge or seconds ~= seconds then
        return false
    end
    local rebirthCount = self:GetNumber(Fields.RebirthCount)
    local currentValue = self:GetNumber(Fields.RockTrainingValue)
    local maxValue = Rebirth.GetMaxTrainingValue(rebirthCount)
    if currentValue >= maxValue then
        return false
    end
    local baseGain = _G.NumericalConfig.trainingSettlementsPerSecond * seconds
        * self:GetHighestTrainingRate(rebirthCount)
    baseGain *= Collection.GetTrainingRate(self:GetTable(Fields.CollectionEntries))
    baseGain *= Aura.GetTrainingRate(self:GetTable(Fields.AuraData))
    baseGain *= Weapon.GetEquippedConfig(self:GetTable(Fields.WeaponData)).TrainingRate
    local gain = math.min(baseGain * Rebirth.GetTrainingRate(rebirthCount), maxValue - currentValue)
    if gain <= 0 then
        return false
    end
    self:AddNumber(Fields.RockTrainingValue, gain)
    self:RefreshProgress()
    FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain)
    return true
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

--- 场内按秒自动训练，替代走路与击打；统一应用装备、图鉴、重生、追赶和经验封顶。
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
    local gain = Rebirth.GetTrainingGain(self:GetNumber(Fields.RockTrainingValue), baseGain,
        self:GetNumber(Fields.RebirthCount))
    if gain > 0 then
        self:AddNumber(Fields.RockTrainingValue, gain)
        self:RefreshProgress()
        FX.Network:SendMsgToClient(self:GetPlayerId(), "S2C_TrainingEffect", gain)
    end
    -- 不按积压秒数补发，避免卡顿恢复时把无法确认的移动时长算作走路收益。
    self._lastGrowth = now
    self._hit = false
end

--- 离服停止训练结算，避免继续读写离线玩家数据。
function Component:OnPlayerLogout()
    FX.Task:Cancel(self._timer)
    self._timer = nil
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
