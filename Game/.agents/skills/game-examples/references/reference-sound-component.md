# 声音组件

基类：`ReplicatedStorage/Scripts/Framework/Client/Player/FCSoundCompClass.lua`，
已由 FClient require，但当前 CPlayerObjectClass 没有挂载声音组件。

需要声音时新增项目子类，覆盖 GetCompName/GetBGMSoundIdList，require 后挂载。
当前 Ctor(owner, effectSoundPoolCount) 创建 SoundService 下的独立音频池。
常用方法：
- PlayBGMByIndex(index)/PlayNextBGM()
- PlayEffectSound(soundId, volume)
- PlayExclusiveEffectSound(soundId, volume)
- PlayEffectSoundWithBGMDuck(soundId, volume, bgmVolumeScale)
- PlayEffectSoundWithBGMPause(soundId, volume)

soundId 必须是体验可使用的 Roblox 音频资源 URI。没有授权 ID 时明确缺少资源，
不捏造 ID，不把 sandboxId:// 音频路径直接传给 Roblox。
默认音量和池大小以当前代码为准；没有需求不创建额外配置层。
覆盖 Dtor 调 Super，释放池和连接；世界定位音效按需求另用真实 Sound/Attachment，
不要假设当前池已经有三维定位支持。
