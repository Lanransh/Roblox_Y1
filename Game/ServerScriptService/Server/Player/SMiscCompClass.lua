local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
local Rebirth = FXLoader:RequireShared("Scripts/Game/Shared/Rebirth")
local RockLevel = FXLoader:RequireShared("Scripts/Game/Shared/RockLevel")
local Component = FX.Class("SMiscCompClass", "FSPlayerCompClass")

--- 持有训练结算状态，通过服务端关卡事件接收有效击打。
--- @param owner FSPlayerObjectClass 已加载的玩家对象。
function Component:Ctor(owner)
    Component.Super.Ctor(self, owner)
    self._lastGrowth = os.clock()
    self._hit = false
    self:SubscribeEvent("RockTrainingHit", self.RecordTrainingHit)
    self:SubscribeEvent("RockRoundReset", self.ClearTrainingHit)
end

--- 集中承接不需要独立系统组件的简单玩家业务。
--- @return string 玩家内协作名称。
function Component:GetCompName()
    return "SMiscComp"
end

--- 等级和次数只取服务端数据；重置后重复请求无法再次满足门槛。
function Component:HandleRebirth()
    if not self._levelStat then
        return
    end
    local player = self:GetPlayerObject()
    local count = self:GetNumber(Fields.RebirthCount)
    if count >= Rebirth.MaxCount then
        player:ShowLocalizedTips("Common.InDevelopment")
        return
    end
    local required = Rebirth.GetRequiredLevel(count)
    if self:GetNumber(Fields.RockTrainingLevel) < required then
        player:ShowLocalizedTips("Rebirth.RequiredLevel", {level = required})
        return
    end
    self:AddNumber(Fields.RebirthCount, 1)
    self:SetNumber(Fields.RockTrainingValue, 0)
    self:ResetTrainingProgress()
    player:ShowLocalizedTips("Rebirth.Success")
end

--- 读档后建立训练数据显示，并按原频率检查每秒结算条件。
function Component:OnPlayerLogin()
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

--- 同一结算周期多次有效命中只计一份基础击打收益。
function Component:RecordTrainingHit()
    self._hit = true
end

--- 关卡轮次恢复时撤销尚未结算的击打，不影响正常走路结算。
function Component:ClearTrainingHit()
    self._hit = false
end

--- 独立结算走路和击打收益，关卡组件不持有经验或成长计时状态。
function Component:TickTraining()
    local character = self:GetPlayerCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
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
    if now - self._lastGrowth < 1 then
        return
    end
    -- 按服务端观察到的水平速度判断移动，站立、腾空和坐下均不发走路收益。
    local velocity = root.AssemblyLinearVelocity
    local walking = humanoid.FloorMaterial ~= Enum.Material.Air and not humanoid.Sit
        and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.5
    local baseGain = (walking and RockLevel.WalkTraining or 0) + (self._hit and 2 or 0)
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
