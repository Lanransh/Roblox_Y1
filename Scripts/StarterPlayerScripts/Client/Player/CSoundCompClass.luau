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
local REWARD_SOUND_ID = "rbxassetid://119465514998302"

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
    FX.Network:RegServerMsgCallback("S2C_DogPickedUp", self.PlayPickupItemSound, self)
    FX.Network:RegServerMsgCallback("S2C_CardActivated", self.OnCardActivated, self)
end

--- 释放拾取与卡片激活通知，再由声音基类释放音乐和短音效池。
function CSoundCompClass:Dtor()
    if self._cardEffectCleanup then
        self._cardEffectCleanup()
    end
    FX.Network:UnRegServerMsgCallback("S2C_DogPickedUp")
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

--- 升级时角色短暂镀金，脚下白色空心方框沿环向外扩开后淡出。
function CSoundCompClass:PlayTrainingUpgradeEffect()
    local character = self:GetPlayerCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TrainingUpgradeHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 210, 55)
    highlight.FillTransparency = 0.08
    highlight.OutlineColor = Color3.fromRGB(255, 249, 205)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character
    TweenService:Create(highlight, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0.05), {
        FillTransparency = 1,
        OutlineTransparency = 1,
    }):Play()
    Debris:AddItem(highlight, 0.55)

    local light = Instance.new("PointLight")
    light.Name = "TrainingUpgradeLight"
    light.Color = Color3.fromRGB(255, 220, 130)
    light.Brightness = 0.7
    light.Range = 6
    light.Shadows = false
    light.Parent = root
    TweenService:Create(light, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Brightness = 0,
    }):Play()
    Debris:AddItem(light, 0.55)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }
    raycastParams.IgnoreWater = true
    local floor = Workspace:Raycast(root.Position, Vector3.new(0, -12, 0), raycastParams)
    local floorY = root.Position.Y - humanoid.HipHeight - root.Size.Y / 2 + 0.04
    if floor then
        floorY = floor.Position.Y + 0.04
    end
    local floorCenter = Vector3.new(root.Position.X, floorY, root.Position.Z)
    local effects = Instance.new("Folder")
    effects.Name = "TrainingUpgradeEffect"
    effects.Parent = Workspace
    local barHeight = 0.05
    local barWidth = 0.045
    local edges = {
        { Offset = Vector3.new(0, 0, -1), AlongX = true },
        { Offset = Vector3.new(0, 0, 1), AlongX = true },
        { Offset = Vector3.new(-1, 0, 0), AlongX = false },
        { Offset = Vector3.new(1, 0, 0), AlongX = false },
    }
    local squareCount = 10
    for index = 1, squareCount do
        local angle = (index - 1) * math.pi * 2 / squareCount + math.random(-20, 20) / 100
        local startRadius = 1.1 + math.random(0, 65) / 100
        local endRadius = startRadius + 2 + math.random(0, 75) / 100
        local startSide = 0.5 + math.random(0, 35) / 100
        local endSide = startSide * 1.25
        local yaw = math.random() * math.pi
        local startFrame = CFrame.new(floorCenter + Vector3.new(math.cos(angle) * startRadius, 0, math.sin(angle) * startRadius))
            * CFrame.Angles(0, yaw, 0)
        local endFrame = CFrame.new(floorCenter + Vector3.new(math.cos(angle) * endRadius, 0, math.sin(angle) * endRadius))
            * CFrame.Angles(0, yaw, 0)
        local info = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        for edgeIndex, edge in ipairs(edges) do
            local startSize = edge.AlongX and Vector3.new(startSide, barHeight, barWidth)
                or Vector3.new(barWidth, barHeight, startSide)
            local endSize = edge.AlongX and Vector3.new(endSide, barHeight, barWidth)
                or Vector3.new(barWidth, barHeight, endSide)
            local bar = Instance.new("Part")
            bar.Name = "UpgradeSquareBar" .. edgeIndex
            bar.Anchored = true
            bar.CanCollide = false
            bar.CanTouch = false
            bar.CanQuery = false
            bar.CastShadow = false
            bar.Material = Enum.Material.Neon
            bar.Color = Color3.fromRGB(255, 255, 255)
            bar.Transparency = 0.05
            bar.Size = startSize
            bar.CFrame = startFrame * CFrame.new(edge.Offset * (startSide / 2))
            bar.Parent = effects
            TweenService:Create(bar, info, {
                CFrame = endFrame * CFrame.new(edge.Offset * (endSide / 2)),
                Size = endSize,
                Transparency = 1,
            }):Play()
        end
    end
    Debris:AddItem(effects, 0.7)
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
