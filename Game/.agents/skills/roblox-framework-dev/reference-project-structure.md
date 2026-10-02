# 当前项目目录与启动

下表以 Game 为根；运行时路径没有 Game 前缀。

| 源目录 | 用途 |
| --- | --- |
| `ReplicatedStorage/Scripts/Framework/` | FrameworkInit、Provider、FShared/FClient/FServer；Shared/Client/Server 分层与 Network 实例 |
| `ReplicatedStorage/Shared/Config/FrameworkConfig.lua` | PlayerData、PlayerKV、Items、Goods、Rankings、GuideGroups、项目协议白名单 |
| `ReplicatedStorage/Shared/` | 两端公共模块、配置、纯公式；不放服务端处理器或秘密 |
| `ServerScriptService/Server/Main.server.lua` | require FrameworkInit 与项目类、先实例化业务服务，再创建玩家管理器 |
| `ServerScriptService/Server/Player/` | 项目服务端玩家对象、管理器与组件 |
| `ServerScriptService/Server/Service/` | 项目跨玩家服务；沿用当前实际目录 Service |
| `ReplicatedStorage/Scripts/Framework/Server/` | FS 框架、KV、奖励、排行榜、支付和好友 |
| `ServerScriptService/Server/Config/StorageConfig.lua` | 仅服务器可见的存档配置 |
| `StarterPlayer/StarterPlayerScripts/Client/Main.client.lua` | require FrameworkInit 与项目类、创建玩家对象、Tool 输入、调用 FC.WaitServerReady |
| `StarterPlayer/StarterPlayerScripts/Client/Player/` | 客户端玩家对象和原生背包适配 |
| `StarterPlayer/StarterPlayerScripts/Client/UI/` | 项目 UI 组件 |
| `ReplicatedStorage/Scripts/Framework/Client/` | FC 玩家、UI、商店、声音、输入等框架 |
| `StarterGui/` | 随玩家复制到 PlayerGui 的 UI 模板 |
| `Workspace/`、`ServerStorage/Assets/Maps/` | 场景与服务端地图模板 |

`default.project.json` 明确映射服务，`Game/Shared/` 当前没有服务映射。公共新模块放到 `ReplicatedStorage/Shared/`，不要凭目录名猜同步关系。
`Docs/` 和 `.agents/` 属于开发资料；`Tests/`、`Tools/`、`Build/` 不在默认构建中。

FrameworkInit 在公共层加载完成后自动 require 当前端的 FServer/FClient，Main 不再分别加载端框架。
MiniStudio 的 MainStorage 对应 Roblox 的 ReplicatedStorage；框架沿用 Scripts/Framework 层级，端入口放在框架根目录。FS 框架仅在服务器初始化，私有存档配置保留在 ServerScriptService。
FC 框架统一放在 ReplicatedStorage/Scripts/Framework/Client；项目开发不直接修改 FC 框架代码，只通过 StarterPlayerScripts/Client 下的项目子类继承和覆写接入。
FServer 加载时直接初始化 KV、排行榜、支付和好友服务，绑定玩家进出、存档失败和关服保存，并处理已在线玩家的存档加载。
服务端 Main 先实例化业务服务，再创建玩家管理器；框架玩家管理器自动登记到 FS.PlayerManager 并开放 Ready。客户端握手时检查当前存档加载状态，补接先于管理器创建完成的加载结果。
客户端 require 项目类并创建玩家对象后调用 FC.WaitServerReady()，由框架等待服务注册、发送 Ready，并等待服务端初始同步完成。
业务 ModuleScript 返回有效结果。新类的 require 必须发生在 FX/FC/FS 基类注册之后、实例化之前。
完整迁移说明位于 `../Docs/框架迁移.md`。
