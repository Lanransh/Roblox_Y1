# 源目录到实例树

| 域 | 本地来源 | 运行时 |
| --- | --- | --- |
| 场景 | Workspace/ | Workspace |
| 共享模块和模板 | ReplicatedStorage/ | ReplicatedStorage |
| 服务端模板 | ServerStorage/ | ServerStorage，仅服务端 |
| UI 模板 | StarterGui/ | 初始源在 StarterGui，玩家实际操作对象在 LocalPlayer.PlayerGui |
| 客户端脚本 | StarterPlayer/StarterPlayerScripts/ | LocalPlayer.PlayerScripts |

以上路径以 Game 为根，映射需再检查 default.project.json。

- .model.json：读取 name/className/children，根名可能由文件名确定。
- .rbxmx：读取 XML 的 Item class 与 Name。
- .rbxm：使用现有解析工具或 Studio，不能从文件名猜子节点。
- 文件夹、init.lua、.server.lua、.client.lua、普通 .lua 的映射不同；先核对源和 Rojo 规则。
- 代码创建的 UI 或物体，读取 Instance.new、Name 与 Parent 赋值。
- 需要构建树索引时，在 Game 中用 `rojo sourcemap default.project.json --include-non-scripts --output Build/Roblox_Y1.sourcemap.json`；先创建 Build。sourcemap 不能证明动态实例已生成或客户端复制已完成。

依据：[Rojo Sync Details](https://rojo.space/docs/v7/sync-details/)、
[Project Format](https://rojo.space/docs/v7/project-format/)。
