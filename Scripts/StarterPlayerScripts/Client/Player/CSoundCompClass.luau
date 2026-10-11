local FX = _G.FX
local FXLoader = FX.Loader
local Fields = _G.PlayerDataConfig
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
    self:WatchDataChanged(Fields.Coins, self.OnCoinsChanged, self)
    self:WatchDataChanged(Fields.RockLoot, self.OnRockLootChanged, self)
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

--- 供后续领奖系统在服务端确认领取成功后调用，不在点击请求时提前播放。
function CSoundCompClass:PlayRewardSound()
    self:PlayEffectSound(REWARD_SOUND_ID, 0.7)
end

return CSoundCompClass
