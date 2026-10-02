# Roblox_Y1

`Game` 是整个 Roblox 同步项目的根目录，包含脚本、模型、UI 和场景节点。原始素材与完整 Studio 场景另行保存。

已迁入 MiniStudio 通用框架；模块位置、业务接入和验证方式见 [框架迁移说明](Docs/框架迁移.md)。Studio 默认使用仅本次试玩有效的内存存档。

Studio 试玩时，空背包会获得一个可重复使用的测试方块和三个可消耗的测试球。它们显示在 Roblox 默认背包中；点击使用由服务端校验并写入框架背包数据。停止试玩后内存存档会清空，正式服务器不会自动发放测试道具。

原生背包由客户端框架自动启动，项目入口无需手动调用。`Provider:GetNativeBackpackConfig()` 返回 `Game/ReplicatedStorage/Shared/Config/FrameworkConfig.lua` 中的 `NativeBackpack` 配置表，包含默认均为 `true` 的 `ShortcutEnabled` 和 `InventoryEnabled`。

`ShortcutEnabled = false` 时服务端不再生成框架手持 Tool，并关闭客户端 Tool 使用绑定及服务端 ActivateTool 入口，玩家无法手持框架道具；背包数据、发放和服务端直接调用 `UseItem` 的能力保留。`InventoryEnabled` 控制原生背包界面显示，不删除数据。Roblox 原生面板与快捷栏共用显示接口，任一字段为 `false` 时两者都隐藏，只关闭面板时输出限制警告，无法独立隐藏其中一个。配置修改后需重新进入试玩或启动新服务器。

## 开始开发

直接用 VS Code 打开 `F:\MiniGame\Roblox_Y1\Game`。
工作区规则位于 `Game/AGENTS.md`，项目技能位于 `Game/.agents/skills/`；提示词的 Roblox 适配范围见 [提示词迁移检查](Game/Docs/提示词迁移检查.md)。
Rojo 配置位于 `Game/default.project.json`，所有 `$path` 均指向 Game 内部。
按 Ctrl+Shift+P 运行 `Rojo: Open Menu` 启动同步，或者在 Game 目录执行：

```powershell
rojo serve
```

在 Studio 的 Rojo 插件中连接 `localhost:34872`，检查同步预览后同步。
如果正在使用旧配置启动的服务，先停止并重新启动。

在 Game 目录构建：

```powershell
New-Item -ItemType Directory -Path Build -Force | Out-Null
rojo build -o Build/Roblox_Y1.rbxlx
```

若终端位于仓库根目录，执行 `rojo serve Game/default.project.json`。
Git 仓库仍位于 Roblox_Y1 根目录。

## 同步目录

```text
Game/
├─ default.project.json
├─ Workspace/                         # 场景中的节点、模型
├─ ReplicatedStorage/
│  ├─ Shared/                         # 公共模块、配置、协议
│  ├─ Scripts/
│  │  └─ Framework/                  # FX/FC/FS 框架，Shared/Client/Server 分层
│  └─ Assets/                         # Models、Effects、UI 模板
├─ ServerScriptService/
│  └─ Server/                         # Main.server.lua、服务端模块
├─ ServerStorage/
│  └─ Assets/Maps/                    # 待生成的地图模板
├─ StarterGui/                        # 随玩家生成的 UI
└─ StarterPlayer/
   └─ StarterPlayerScripts/
      └─ Client/                     # Main.client.lua、客户端模块
```

服务目录在本地和 Studio 中对应。框架目录沿用 MiniStudio 的 `MainStorage/Scripts/Framework` 结构，以 `ReplicatedStorage` 对应 `MainStorage`；`FShared/FClient/FServer/FrameworkInit` 放在框架根目录，模块按 `Shared/Client/Server` 分层。服务端框架仅在服务器初始化，私有配置保留在 `ServerScriptService`。
`FC` 开头的框架代码放在 `ReplicatedStorage/Scripts/Framework/Client`；项目通过 `StarterPlayerScripts/Client` 下的子类继承和覆写接入，不直接修改 FC 框架代码。
Workspace 和 StarterGui 目前为空，等待加入实际节点。
当前只映射上述服务；新增其他服务或 StarterCharacterScripts 时，需要在配置中添加对应映射。

## 如何存放节点

- 脚本：`.server.lua`、`.client.lua`、普通 `.lua` 分别对应 Script、LocalScript、ModuleScript。
- 模型和 UI：从 Studio 导出的 `.rbxm` / `.rbxmx` 放到其目标服务目录中。
- 简单节点：使用 `.model.json` 描述 Part、RemoteEvent 等对象。
- 普通目录默认生成 Folder；若目录需要表示 Model、ScreenGui 等类型，使用 `init.meta.json` 设置 className。

例如场景模型放 `Game/Workspace`；公共模型模板放 `Game/ReplicatedStorage/Assets/Models`；开局界面放 `Game/StarterGui`；动态加载的 UI 模板放 `Game/ReplicatedStorage/Assets/UI`。

ReplicatedStorage 和 ServerStorage 中的模型是模板，需要代码克隆到 Workspace 才出现在场景中。UI 模板需要克隆到 PlayerGui。
Shared 的内容客户端可见，存档和发奖校验等放在 ServerScriptService。

## 同步边界

已映射服务容器设置 `$ignoreUnknownInstances: true`，保留 Studio 中不在本地配置内的直接子节点。此设置不递归保护下级目录；本地管理的子树以磁盘文件为准，同名对象也会被同步。
普通 `rojo serve` 不会自动把 Studio 修改保存回磁盘。编辑模型后，主动导出覆盖对应本地文件。
`rojo build` 仅包含 Game 中映射的内容，不会合并 Studio 中额外的地图、Terrain 或 UI。网格、Terrain 等存在实时同步限制，具体见资源工作流。
空目录使用 `.gitkeep` 纳入 Git，占位文件不会同步成节点。

## Game 内的开发辅助目录

以下目录统一放在 `Game` 内，未加入 `default.project.json` 的服务映射，不会同步到 Studio 或包含在默认构建中。

| 目录 | 用途 |
| --- | --- |
| Game/Tests | 框架测试脚本、测试夹具和历史测试结果 |
| Game/Tools | Python 测试运行工具：拼接框架源码与测试脚本，再调用本地 Luau CLI |
| Game/Build | Rojo 场景构建、sourcemap 和测试工具生成的临时脚本，Git 忽略 |

测试工具从自身位置定位 Game，可从任意目录调用；以下命令在 Game 目录执行：

```powershell
python Tools/run_framework_pure_tests.py --luau <luau.exe 的本地路径>
python Tools/run_framework_addon_tests.py --luau <luau.exe 的本地路径>
```

## 仓库其他目录

| 目录 | 用途 |
| --- | --- |
| ArtSource | OBJ、FBX、原始图片和音频，不直接同步 |
| Places | Studio 保存的完整场景源文件 |
| Docs | 设计文档与资源工作流 |

## 开发工具

使用 PATH 中的 Rojo 7.7.0，当前开发机位于 `F:\Tools\Rojo\rojo.exe`。VS Code 使用 `evaera.vscode-rojo` 扩展。
Studio 端需要 Rojo 7 插件。CLI 安装命令为 `rojo plugin install`；若提示找不到注册表，可按官方说明手动安装插件。

- https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0
- https://rojo.space/docs/v7/getting-started/installation/
- https://rojo.space/docs/v7/project-format/
- https://rojo.space/docs/v7/sync-details/

资源导入细节见 `Docs/资源工作流.md`。
