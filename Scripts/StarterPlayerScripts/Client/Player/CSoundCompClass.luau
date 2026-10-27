local FX = _G.FX
local FXLoader = FX.Loader
local CardUseEffect = FXLoader:RequireFromParent(script, "CardUseEffect")
local Fields = _G.PlayerDataConfig
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UPGRADE_SOUND_ID = "rbxassetid://97430098988000"
local ADD_MONEY_SOUND_ID = "rbxassetid://99533862853751"
local PICKUP_SOUND_ID = "rbxassetid://88292715815889"
local REWARD_SOUND_ID = "rbxassetid://92949680432490"

---@class CSoundCompClass: FCSoundCompClass
local CSoundCompClass = FX.Class("CSoundCompClass", "FCSoundCompClass")

--- 轮播授权音乐，并监听服务端确认的升级、金币收益和拾取变化。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function CSoundCompClass:Ctor(owner)
    local musicRoot = FXLoader:Shared("Assets/Sounds")
    self._bgmSoundConfigList = {
        { bgmId = FXLoader:Here(musicRoot, "Time To Relax").SoundId, volume = 0.5 },
        { bgmId = FXLoader:Here(musicRoot, "Waltzing Flutes").SoundId, volume = 0.5 },
    }
    CSoundCompClass.Super.Ctor(self, owner, 4)
    self:WatchDataChanged(Fields.RockTrainingLevel, self.OnTrainingLevelChanged, self)
    self:WatchDataChanged(Fields.Money, self.OnCoinsChanged, self)
    self:WatchDataChanged(Fields.RockLoot, self.OnRockLootChanged, self)
    FX.Network:RegServerMsgCallback("S2C_NoobPickedUp", self.PlayPickupItemSound, self)
    FX.Network:RegServerMsgCallback("S2C_CardActivated", self.OnCardActivated, self)
end

--- 释放升级特效、拾取与卡片激活通知，再由声音基类释放音乐和短音效池。
function CSoundCompClass:Dtor()
    if self._trainingEffectCleanup then
        self._trainingEffectCleanup()
    end
    if self._cardEffectCleanup then
        self._cardEffectCleanup()
    end
    FX.Network:UnRegServerMsgCallback("S2C_NoobPickedUp")
    FX.Network:UnRegServerMsgCallback("S2C_CardActivated")
    CSoundCompClass.Super.Dtor(self)
end

--- 提供业务声音入口，复用框架的播放与生命周期管理。
--- @return string 组件协作名称。
function CSoundCompClass:GetCompName()
    return "CSoundComp"
end

--- 返回轮播曲目，末尾回到第一首的行为由声音基类处理。
--- @return table 按播放顺序排列的音频资源与音量。
function CSoundCompClass:GetBGMSoundIdList()
    return self._bgmSoundConfigList
end

--- 仅在训练等级实际上升时突出升级音效并暂时压低音乐，跳过首次同步和重生重置。
--- @param level number 服务端同步的当前训练等级。
--- @param oldLevel number? 变化前等级，首次同步为空。
function CSoundCompClass:OnTrainingLevelChanged(level, oldLevel)
    if oldLevel == nil or level <= oldLevel then
        return
    end
    self:PlayEffectSoundWithBGMDuck(UPGRADE_SOUND_ID, 2, 0.2)
    self:PlayTrainingUpgradeEffect()
end

--- 用蓝金双层冲击环、上冲光束和星芒爆发强调升级，先保留亮度再收尾，连续升级不叠加。
function CSoundCompClass:PlayTrainingUpgradeEffect()
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        return
    end

    if self._trainingEffectCleanup then
        self._trainingEffectCleanup()
    end
    local effects = Instance.new("Folder")
    effects.Name = "TrainingUpgradeEffect"
    effects.Parent = Workspace
    local attachment = Instance.new("Attachment")
    attachment.Name = "TrainingUpgradeGlow"
    attachment.Position = Vector3.new(0, -1, 0)
    attachment.Parent = root
    self._trainingEffectCleanup = function()
        effects:Destroy()
        attachment:Destroy()
    end
    Debris:AddItem(effects, 1.4)
    Debris:AddItem(attachment, 1.4)

    local highlight = Instance.new("Highlight")
    highlight.Name = "TrainingUpgradeHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 225, 140)
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(120, 235, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = effects
    TweenService:Create(highlight, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.1), {
        FillTransparency = 1,
        OutlineTransparency = 1,
    }):Play()

    local light = Instance.new("PointLight")
    light.Name = "TrainingUpgradeLight"
    light.Color = Color3.fromRGB(255, 220, 130)
    light.Brightness = 2.5
    light.Range = 12
    light.Shadows = false
    light.Parent = attachment
    TweenService:Create(light, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Brightness = 0,
    }):Play()

    local sparkles = Instance.new("ParticleEmitter")
    sparkles.Name = "UpgradeSparkles"
    sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 237, 180), Color3.fromRGB(255, 190, 75))
    sparkles.LightEmission = 1
    sparkles.LightInfluence = 0
    sparkles.Rate = 0
    sparkles.Lifetime = NumberRange.new(0.8, 1.2)
    sparkles.Speed = NumberRange.new(8, 13)
    sparkles.Drag = 3
    sparkles.Acceleration = Vector3.new(0, -3, 0)
    sparkles.SpreadAngle = Vector2.new(80, 80)
    sparkles.Rotation = NumberRange.new(0, 360)
    sparkles.RotSpeed = NumberRange.new(-60, 60)
    sparkles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.12, 0.75),
        NumberSequenceKeypoint.new(0.6, 0.4),
        NumberSequenceKeypoint.new(1, 0),
    })
    sparkles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.65, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    sparkles.Parent = attachment
    sparkles:Emit(36)

    local burstFrame = CFrame.new(root.Position)
    for index = 1, 8 do
        local angle = (index - 1) * math.pi / 4
        local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local streak = Instance.new("Part")
        streak.Name = "UpgradeEnergyStreak"
        streak.Anchored = true
        streak.CanCollide = false
        streak.CanTouch = false
        streak.CanQuery = false
        streak.CastShadow = false
        streak.Material = Enum.Material.Neon
        streak.Color = index % 2 == 0 and Color3.fromRGB(80, 220, 255) or Color3.fromRGB(255, 225, 140)
        streak.Size = Vector3.new(0.14, 2.8, 0.14)
        streak.CFrame = burstFrame * CFrame.new(direction * 1.6 + Vector3.new(0, -0.5, 0))
        streak.Parent = effects
        TweenService:Create(streak, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            CFrame = burstFrame * CFrame.new(direction * 2.8 + Vector3.new(0, 4.5 + index % 3, 0)),
            Size = Vector3.new(0.04, 0.6, 0.04),
        }):Play()
        TweenService:Create(streak, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.15), {
            Transparency = 1,
        }):Play()
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }
    raycastParams.IgnoreWater = true
    local floor = Workspace:Raycast(root.Position, Vector3.new(0, -12, 0), raycastParams)
    if not floor then
        return
    end
    local floorCenter = floor.Position + floor.Normal * 0.08
    local floorFrame = CFrame.lookAt(floorCenter, floorCenter + floor.Normal, Vector3.xAxis)
    local segmentCount = 32
    local segmentLength = 2 * math.tan(math.pi / segmentCount)
    for ringIndex = 1, 2 do
        local startRadius = ringIndex == 1 and 1.5 or 0.9
        local endRadius = ringIndex == 1 and 7 or 4.8
        local width = ringIndex == 1 and 0.22 or 0.32
        local color = ringIndex == 1 and Color3.fromRGB(80, 220, 255) or Color3.fromRGB(255, 220, 110)
        local delayTime = (ringIndex - 1) * 0.1
        local info = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, delayTime)
        for index = 1, segmentCount do
            local angle = (index - 1) * math.pi * 2 / segmentCount
            local direction = Vector3.new(math.cos(angle), math.sin(angle), 0)
            local rotation = CFrame.Angles(0, 0, angle + math.pi / 2)
            local segment = Instance.new("Part")
            segment.Name = "UpgradeRingSegment"
            segment.Anchored = true
            segment.CanCollide = false
            segment.CanTouch = false
            segment.CanQuery = false
            segment.CastShadow = false
            segment.Material = Enum.Material.Neon
            segment.Color = color
            segment.Transparency = 0
            segment.Size = Vector3.new(startRadius * segmentLength, width, 0.06)
            segment.CFrame = floorFrame * CFrame.new(direction * startRadius) * rotation
            segment.Parent = effects
            TweenService:Create(segment, info, {
                CFrame = floorFrame * CFrame.new(direction * endRadius) * rotation,
                Size = Vector3.new(endRadius * segmentLength, width * 0.35, 0.06),
            }):Play()
            TweenService:Create(segment, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, delayTime + 0.2), {
                Transparency = 1,
            }):Play()
        end
    end
end

--- 金币到账时突出收益音效并暂时压低音乐，首次同步、消费和重置不播放。
--- @param coins number 服务端同步的当前金币余额。
--- @param oldCoins number? 变化前余额，首次同步为空。
function CSoundCompClass:OnCoinsChanged(coins, oldCoins)
    if oldCoins == nil or coins <= oldCoins then
        return
    end
    self:PlayEffectSoundWithBGMDuck(ADD_MONEY_SOUND_ID, 2, 0.2)
end

--- 战利品实际入袋后反馈，拾取失败、回基地转存和首次同步不播放。
--- @param loot table 服务端同步的随身战利品列表。
--- @param oldLoot table? 变化前列表，首次同步为空。
function CSoundCompClass:OnRockLootChanged(loot, oldLoot)
    if oldLoot == nil or #loot <= #oldLoot then
        return
    end
    self:PlayPickupItemSound()
end

--- 提供拾取成功音效入口，复用短音效池以保持背景音乐连续。
function CSoundCompClass:PlayPickupItemSound()
    self:PlayEffectSound(PICKUP_SOUND_ID, 1)
end

--- 服务端确认使用成功后，仅在本地播放举卡前推和对应颜色的特效。
--- @param itemId number 已使用的道具配置 ID。
function CSoundCompClass:OnCardActivated(itemId)
    local config = _G.ItemConfig.Data[itemId]
    if not config then
        return
    end
    if self._cardEffectCleanup then
        self._cardEffectCleanup()
    end
    self._cardEffectCleanup = CardUseEffect.Play(self:GetPlayerCharacter(), config, function()
        self:PlayRewardSound()
    end)
end

--- 卡片推出或领奖时复用奖励音，音量遵守现有音效分组设置。
function CSoundCompClass:PlayRewardSound()
    self:PlayEffectSound(REWARD_SOUND_ID, 0.7)
end

return CSoundCompClass
