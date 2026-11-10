# 目录、命名与启动

以下路径相对 `Scripts/`。

## 目录与脚本归属

| 归属 | 路径 | 手写模块前缀 |
| --- | --- | --- |
| 项目客户端 | `StarterPlayerScripts/Client/`；Studio 中为 `StarterPlayer.StarterPlayerScripts.Client` | `C`，如 `CMainUICompClass` |
| 框架客户端 | `ReplicatedStorage/Scripts/Framework/Client/` | `FC` |
| 项目服务端 | `ServerScriptService/Server/` | `S`，如 `SPlayerObjectClass` |
| 框架服务端 | `ReplicatedStorage/Scripts/Framework/Server/` | `FS` |
| 框架共享 | `ReplicatedStorage/Scripts/Framework/Shared/` | `FX` |
| 项目公共配置与模块 | `ReplicatedStorage/Scripts/Game/Shared/`、生成配置 `Game/Configs/` | 不强加端专属前缀 |

- 文件名、注册类名及组件协作名保持同一归属前缀；类注册名与组件协作名仍按各自接口约定命名。
- `Main`、`GameInit`、`FClient/FServer/FShared/FrameworkInit` 等固定引导名称沿用既有名称；不为执行命名规则批量重命名已有模块；Generated 名称由生成工具维护，不手工重命名。
- `FShared/FClient/FServer/FrameworkInit` 位于框架根目录；服务端框架仅由服务器初始化。通用框架模块不得反向依赖 `Game/` 或项目客户端模块，项目差异经 Provider、回调或子类接入。
- 配置由 `ReplicatedStorage/Scripts/SetupProvider.luau` 接入；私有配置放 `ServerScriptService/Server/Config`，不暴露到公共目录。生成配置按来源回源：XLSX 使用 [XLSX 游戏配置](../roblox-external-tools/references/game-config.md)，`NumericalConfig.luau` 使用 [模拟器协作](../roblox-external-tools/references/simulator.md)。

## 入口、模块与协议

- 客户端唯一执行入口为 `StarterPlayerScripts/Client/Main.local.luau`（LocalScript）。
- 服务端唯一执行入口为 `ServerScriptService/Server/Main.server.luau`（Script，RunContext 为 Server）。
- 其余业务类、组件、配置和工具均为 `.luau` ModuleScript，由 `require` 加载，不另建执行入口；每个模块返回有效结果。
- 业务模块显式声明 `_G.FX/_G.FC/_G.FS` 中实际使用的变量，如 `local FX, FC = _G.FX, _G.FC`；使用 Roblox 原生服务、节点 API 和有效资源 URI。
- 项目协议在 `ReplicatedStorage/Scripts/Game/Shared/NetworkProtocol.luau` 的 `ClientMsgID/ServerMsgID` 声明，框架协议在 `ReplicatedStorage/Scripts/Framework/FrameworkInit.luau` 声明。
- 脚本通过 Script Sync 同步；场景、存储和 UI 非脚本实例在 Studio 中维护，节点与同步核验使用 [Studio 操作](../roblox-studio-operations/SKILL.md)。

## 启动顺序

1. Main 加载 GameInit，SetupProvider 在 FrameworkInit 前加载；FrameworkInit 自动加载当前端 FServer/FClient。
2. 框架基类注册后 require 业务类，再实例化或 AddComponent；业务类不会被自动遍历加载。
3. FServer 初始化存档、排行榜、支付和好友服务。服务端 Main 按依赖初始化项目服务；握手前必需的服务先于玩家管理器创建。管理器登记到 FS.PlayerManager 并开放 Ready，无握手依赖的扩展入口可在其后初始化。
4. 客户端创建玩家对象后调用 FC.WaitServerReady()，等待服务注册和初始数据同步。服务端握手会核对存档加载状态。

FClient 自动启动 FC.NativeBackpack，具体配置行为见 [背包参考](../game-examples/references/reference-inventory-component.md)。

本项目的翻译仍由客户端 Main 初始化 `FC.Localization`，文案入口为 `Game/Shared/Text`；拾取提示由 Main 调用 `PickupPrompt.Init()`，按钮悬停由项目 `CCommonUICompClass` 持有。好友邀请为项目 `CFriendInviteCompClass`。不要照搬其他项目的 `FX.Text`、`FC.ButtonHover` 或 `FCFriendInviteCompClass` 接法，先核对本仓库的初始化和持有者。
