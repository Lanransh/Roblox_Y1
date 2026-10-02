# 当前项目目录与启动

下表以 Game 为根；运行时路径没有 Game 前缀。

| 源目录 | 用途 |
| --- | --- |
| `ReplicatedStorage/Framework/` | FrameworkInit、Provider、FShared、FX 公共框架与 Network 实例 |
| `ReplicatedStorage/Shared/Config/FrameworkConfig.lua` | PlayerData、PlayerKV、Items、Goods、Rankings、GuideGroups、项目协议白名单 |
| `ReplicatedStorage/Shared/` | 两端公共模块、配置、纯公式；不放服务端处理器或秘密 |
| `ServerScriptService/Server/Main.server.lua` | require 项目类、实例化服务、启动玩家管理器 |
| `ServerScriptService/Server/Player/` | 项目服务端玩家对象、管理器与组件 |
| `ServerScriptService/Server/Service/` | 项目跨玩家服务；沿用当前实际目录 Service |
| `ServerScriptService/Server/Framework/` | FS 框架、KV、奖励、排行榜、支付和好友 |
| `ServerScriptService/Server/Config/StorageConfig.lua` | 仅服务器可见的存档配置 |
| `StarterPlayer/StarterPlayerScripts/Client/Main.client.lua` | require 客户端类、创建玩家对象、Tool 输入与 Ready 握手 |
| `StarterPlayer/StarterPlayerScripts/Client/Player/` | 客户端玩家对象和原生背包适配 |
| `StarterPlayer/StarterPlayerScripts/Client/UI/` | 项目 UI 组件 |
| `StarterPlayer/StarterPlayerScripts/Client/Framework/` | FC 玩家、UI、商店、声音、输入等框架 |
| `StarterGui/` | 随玩家复制到 PlayerGui 的 UI 模板 |
| `Workspace/`、`ServerStorage/Assets/Maps/` | 场景与服务端地图模板 |

`default.project.json` 明确映射服务，`Game/Shared/` 当前没有服务映射。公共新模块放到 `ReplicatedStorage/Shared/`，不要凭目录名猜同步关系。
`Docs/` 和 `.agents/` 属于开发资料；`Tests/`、`Tools/`、`Build/` 不在默认构建中。

服务端公共层 -> FServer -> 注册业务类与服务 -> 加载档案 -> 客户端 Ready -> 玩家对象与组件 -> 初始同步。
客户端公共层 -> FClient -> require 项目类 -> 创建玩家对象 -> 等待服务注册 -> 发送 Ready。
业务 ModuleScript 返回有效结果。新类的 require 必须发生在 FX/FC/FS 基类注册之后、实例化之前。
完整迁移说明位于 `../Docs/框架迁移.md`。
