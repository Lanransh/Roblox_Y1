# 挥镐动作修改前备份

备份日期：2026-10-05。备份在修改动作代码之前建立。

- `CRockLevelCompClass.before.lua`：原客户端完整脚本，本次实际修改的文件。
  SHA-256：`DDC05B987D21BAB952839DDBBE8634A31CC4D58D078101AF769A9D414EC3368E`
- `SRockLevelCompClass.before.lua`：当时服务端完整脚本，仅供核对动画配置；包含任务开始前已有的用户修改，本任务未修改该文件。
  SHA-256：`CBACD76E6930FCB4DE6EA728FE20ECD0C41736D28B5769B2A7755A18A9599FA8`
- `reference.mp4`：用户提供的动作参考视频。
- `reference.png`：参考视频抽帧。

原 R15 动画：`rbxassetid://2850678159`，优先级 Action，非循环，速度 1.25，淡入 0.08 秒；0.2 秒打开拖尾，0.4 秒命中，0.46 秒关闭拖尾，0.72 秒开始淡出。本次保留原动画资源，不覆盖或重新发布资源。

## 恢复

停止 Studio 试玩。在 Game 目录执行以下 PowerShell 命令，然后通过当前 Rojo 连接同步并重新试玩：

```powershell
Copy-Item -LiteralPath 'Build/pickaxe-backup-20261005-164129/CRockLevelCompClass.before.lua' -Destination 'StarterPlayer/StarterPlayerScripts/Client/Player/CRockLevelCompClass.lua'
```

仅客户端文件需要恢复。不要覆盖服务端脚本，以免覆盖后续其他功能修改。如果客户端脚本已有后续修改，仅从备份恢复 `SwingPickaxe`、`PoseSwing`、`StopSwing` 三个函数。
