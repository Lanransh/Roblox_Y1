# Roblox_Y1

`Scripts` 是当前工程的同步根目录：Roblox Studio 通过内置 Script Sync 与其中的 `.luau` 文件同步脚本，场景、模型、UI 和本地化表仍在 Studio 内维护，本地没有对应副本。

工程已迁入 MiniStudio 通用框架，沿用 FX/FC/FS 的 Shared/Client/Server 分层。开发前先读 [工作区指南](Scripts/AGENTS.md)：同步规则、文件后缀和编码要求以该文件为准。系统功能与验收结论见 [功能验收清单](Scripts/Docs/功能验收清单.md)，迁移历史见 [提示词迁移检查](Scripts/Docs/提示词迁移检查.md)。

存档按运行环境隔离：Studio 试玩使用 `Roblox_Y1_Player_Studio_v1`，正式服务器使用 `Roblox_Y1_Player_v1`，配置见 [StorageConfig.luau](Scripts/ServerScriptService/Server/Config/StorageConfig.luau)。

原生背包由客户端框架自动启动，项目入口无需手动调用。`Provider:GetNativeBackpackConfig()` 返回 [SetupProvider.luau](Scripts/ReplicatedStorage/Scripts/SetupProvider.luau) 中的 `ShortcutEnabled` 与 `InventoryCapacity`；快捷栏与正式背包共用总容量，快捷栏最多占用其中 10 格。`InventoryCapacity = 0` 时关闭 Roblox 原生背包界面；`ShortcutEnabled = false` 时服务端不再生成框架手持 Tool，并关闭客户端 Tool 使用绑定与服务端 ActivateTool 入口，玩家无法手持框架道具，背包数据、发放和服务端直接调用 `UseItem` 的能力保留。Roblox 原生面板与快捷栏共用显示接口，无法独立隐藏其中一个，任一开关关闭都会同时隐藏两者。修改配置后需重新启动服务器或重新进入试玩。

## 开始开发

1. 用 VS Code 打开仓库根目录下的 `Scripts`。工作区规则在 [Scripts/AGENTS.md](Scripts/AGENTS.md)，项目技能在 `Scripts/.agents/skills/`。
2. 在 Studio 中打开该 Place，用 Studio 自带的 Script Sync（资源管理器中右键目标容器 → `Sync to...`）把本地目录指向目标实例；映射关系保存在 Studio 侧，本地目录结构不等于完整 DataModel。
3. 直接编辑本地 `.luau` 文件，Studio 中的脚本实例随保存更新。工程不使用 Rojo，不维护 `default.project.json`，也没有构建或 sourcemap 步骤。

Git 仓库位于 Roblox_Y1 根目录，`Scripts` 是仓库中的一个目录。

## 同步目录

```text
Scripts/
├─ AGENTS.md                         # 工作区规则，不同步
├─ .agents/skills/                   # 项目技能，不同步
├─ Docs/                             # 开发资料与验收清单，不同步
├─ ReplicatedStorage/
│  └─ Scripts/
│     ├─ GameInit.luau               # 两端共同入口：配置、Provider、框架、公共模块
│     ├─ SetupProvider.luau          # 项目配置与框架之间的唯一入口
│     ├─ Framework/                  # FX/FC/FS 框架，Shared/Client/Server 分层
│     └─ Game/
│        ├─ Configs/                 # 数值与表格配置
│        └─ Shared/                  # 公共模块、协议、玩家数据定义
├─ ServerScriptService/
│  └─ Server/                        # Main.server.luau、玩家组件、Handler、私有配置
└─ StarterPlayerScripts/
   └─ Client/                        # Main.local.luau、玩家对象与 UI 组件
```

`Workspace`、`StarterGui`、`ServerStorage` 以及 `ReplicatedStorage` 下的模型、UI、本地化表等非脚本实例没有本地目录，直接在 Studio 中维护，不通过 Script Sync 导入。

## 文件命名与实例类型

Script Sync 按文件名后缀决定实例类型和 RunContext；同步后的实例名不含后缀，例如 `Main.server.luau` 在 Studio 中名为 `Main`，代码仍按 `Main` 查找节点。组件类、配置和工具模块即使只用于某一端，也使用 ModuleScript 的 `.luau` 后缀。

| 本地文件名 | Studio 实例类型与运行上下文 |
| --- | --- |
| `Name.luau` | `ModuleScript`，通过 `require` 加载 |
| `Name.server.luau` | `Script`，`RunContext = Server` |
| `Name.client.luau` | `Script`，`RunContext = Client` |
| `Name.local.luau` | `LocalScript` |
| `Name.legacy.luau` | `Script`，`RunContext = Legacy` |
| `Name.plugin.luau` | `Script`，`RunContext = Plugin` |
| `Name/init.luau` | 带子节点的 `ModuleScript` |

- 服务端执行入口使用 `.server.luau`；当前客户端入口为 [Main.local.luau](Scripts/StarterPlayerScripts/Client/Main.local.luau)，即 `LocalScript`。
- 修改已有脚本时保留其路径、后缀和类型；本地后缀与 Studio 属性不一致时先核对 ClassName、RunContext 和同步状态，不猜测、不批量重命名。

## 同步边界

- Script Sync 只同步脚本和受支持的文本文件，不把本地模型、UI、CSV 或元数据导入为对应实例。
- 本地保存成功不等于 Studio 已同步；同步状态、ClassName 和 RunContext 以 Studio 侧实际节点为准，发现冲突先核对再改。
- 只有已在 Studio 中配置过同步的目录才会生效，新增同步根前先在 `Sync to...` 中确认映射。
- 场景与模型的改动直接在 Studio 中保存，不进入 Git。

## 仓库其他目录

| 目录 | 用途 |
| --- | --- |
| ArtSource | OBJ、FBX、原始图片和音频素材，不直接同步 |
| 配置文档 | 商品表、数值设计等策划表（xlsx），与 `ReplicatedStorage/Scripts/Game/Configs` 中的配置同名对应 |
| BlockEditorWorkspace | 地图块编辑器工作区：`.blockmodel.json` 与场景设施数据 |
| GameKitWorkspace | StudioGameToolkit 工作区，用于资源上传与场景工具 |
| UIEditorWorkspace | UIEditor 工作区：`interfaces` 与 `styles` |

## 开发工具

- Studio 内置 Script Sync，官方说明见 [Script Sync — sync rules](https://create.roblox.com/docs/scripting/sync#sync-rules)。
- 本地语法验证需要 Luau 编译器：先检查 PATH 中的 `luau-compile` 或 `Build/luau/luau-compile.exe`，缺失时报告验证未完成；运行测试与试玩需要用户明确授权。
