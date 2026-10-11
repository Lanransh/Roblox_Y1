local FX = _G.FX
local FXLoader = FX.Loader

---@class CSoundCompClass: FCSoundCompClass
local CSoundCompClass = FX.Class("CSoundCompClass", "FCSoundCompClass")

--- 使用共享资源中的两首授权音乐，按固定顺序以一半音量轮播。
--- @param owner CPlayerObjectClass 当前客户端玩家对象。
function CSoundCompClass:Ctor(owner)
    local musicRoot = FXLoader:Shared("Assets/Sounds")
    self._bgmSoundConfigList = {
        { bgmId = FXLoader:Here(musicRoot, "Time To Relax").SoundId, volume = 0.5 },
        { bgmId = FXLoader:Here(musicRoot, "Waltzing Flutes").SoundId, volume = 0.5 },
    }
    CSoundCompClass.Super.Ctor(self, owner, 1)
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

return CSoundCompClass
