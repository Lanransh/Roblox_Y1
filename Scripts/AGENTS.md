# Roblox_Y1 Game 工作区指南

## 角色

你是一名 Roblox 游戏开发者。
该项目使用 Luau 和 Roblox Studio 内置 Script Sync，沿用已迁移的 FX/FC/FS 组件框架。
本文件中的相对路径以当前 `Scripts/` 工作区为基准。Git 仓库根目录通过 `git rev-parse --show-toplevel` 确认，不假设当前目录就是仓库根。
当前工作区不使用 Rojo 维护、同步或构建。技能与历史文档中的 Rojo 命令、服务映射、`.meta.json` 和旧文件后缀不能作为当前操作依据，以本文件的 Script Sync 规则为准。
技能示例中的 `Game/AGENTS.md` 指当前工作区 `AGENTS.md`；本地 `StarterPlayer/StarterPlayerScripts/` 路径改按 `StarterPlayerScripts/` 定位，历史 `.lua` 模块路径先核对现有 `.luau` 文件。旧 `Main.client.lua` 不作为新文件命名模板，当前客户端入口为 `StarterPlayerScripts/Client/Main.local.luau`；已有服务端入口按实际文件与 Studio 属性核对。

## 重要目录
- `ReplicatedStorage/Scripts/Framework/`：FX/FC/FS 框架，沿用 MiniStudio 的 Shared/Client/Server 分层；`ReplicatedStorage/Scripts/Game/Shared/`：公共配置与模块
- `ServerScriptService/Server/`：服务端业务入口、项目类和私有配置
- `StarterPlayerScripts/Client/`：客户端业务入口、玩家对象与项目组件；对应 Studio 的 `StarterPlayer.StarterPlayerScripts.Client`
- `Docs/功能验收清单.md`：当前已实现功能及其验收状态
- `Workspace`、`ServerStorage`、`StarterGui`：Studio 中的场景、服务器模板和 UI 节点；不假设当前本地目录包含这些非脚本实例
- `../Docs/框架迁移.md`：已迁移能力、业务接入与历史验证记录
- `Tests/`、`Tools/`、`Build/`：需要时使用的测试、辅助工具和编译产物目录，不作为游戏脚本同步根

## Script Sync 文件创建与同步（必须遵守）

- 创建文件前明确实例类型、运行上下文和目标同步目录；不能仅按代码运行在服务端或客户端来选择后缀。组件类、配置和工具模块即使只用于某一端，也使用 ModuleScript 的 `.luau` 后缀。

| 本地文件名 | Studio 实例类型与运行上下文 |
| --- | --- |
| `Name.luau` | `ModuleScript`，通过 `require` 加载 |
| `Name.server.luau` | `Script`，`RunContext = Server` |
| `Name.client.luau` | `Script`，`RunContext = Client`；不是 `LocalScript` |
| `Name.local.luau` | `LocalScript` |
| `Name.legacy.luau` | `Script`，`RunContext = Legacy`；不是代码版本标记 |
| `Name.plugin.luau` | `Script`，`RunContext = Plugin` |
| `Name/init.*.luau` | 带子节点的脚本实例，类型按上述后缀确定；ModuleScript 使用 `Name/init.luau` |

- 新增服务端执行入口默认使用 `.server.luau`；当前 `StarterPlayerScripts/Client/` 下的客户端入口使用 `.local.luau`。只有明确需要 Client RunContext 的 Script 时才用 `.client.luau`，明确需要 Legacy 行为时才用 `.legacy.luau`。
- 新文件统一使用 `.luau`，不照搬 Rojo 的 `.server.lua`、`.client.lua`、`init.lua` 或通过 `.meta.json` 设置脚本类型的方式。同步后的实例名不包含类型后缀，例如 `Main.server.luau` 对应实例 `Main`，代码查找节点时仍使用 `Main`。
- 修改已有脚本保留其路径、后缀和类型；遇到本地后缀与 Studio 属性不一致，先通过 Roblox MCP 核对 ClassName、RunContext 与同步状态，不猜测，也不顺手批量重命名。文件重命名、移动、删除可能同步改变 Studio 实例，执行前检查引用及同名文件。
- 新文件放在已确认启用 Script Sync 的目录中。当前本地目录结构不等于完整 DataModel；新增同步根或无法确认目录映射时，说明需要在 Studio 的 `Sync to...` 中确认，不能假设新建本地目录就会同步。
- Script Sync 同步脚本和受支持文件，不负责将本地模型、UI、CSV 或 Rojo 元数据自动导入为对应非脚本实例。场景、模型、UI 和 LocalizationTable 在 Studio 中维护，通过 Roblox MCP 查询和核对。
- 官方命名依据：[Roblox Script Sync — Sync rules](https://create.roblox.com/docs/scripting/sync#sync-rules)。

## 共享技能
在编写代码之前，先读取并遵循与当前任务匹配的技能文档：
- `.agents/skills/roblox-luau-standards/SKILL.md`
- `.agents/skills/roblox-framework-dev/SKILL.md`
- `.agents/skills/roblox-ui-components/SKILL.md`
- `.agents/skills/roblox-engine-nodes/SKILL.md`
- `.agents/skills/game-examples/SKILL.md`
- `.agents/skills/server-code-critical-review/SKILL.md`
- `.agents/skills/maintain-acceptance-checklist/SKILL.md`
- `.agents/skills/integrate-feature-branch/SKILL.md`（仅允许用户显式调用）

## 何时读取 Skill

- 进行 Lua 编码、重构、风格修复或普通代码审查时，使用 `roblox-luau-standards`
- 涉及框架结构、玩家数据、服务端逻辑、客户端玩家组件、协议链路或组件协作时，使用 `roblox-framework-dev`；纯 UI 表现修改不触发该 Skill
- 修改客户端 UI 时，使用 `roblox-ui-components`；先检查目标界面是否有 UIEditor 导出的展示类。有对应生成类时，业务子类继承该类并复用展示与交互，不直接继承 FCUICompClass 重写；具体接入与不匹配处理见该技能的 reference-rules.md。
- 涉及非 UI 引擎节点 API，例如 `Instance`、`BasePart`、`Model:PivotTo`、`Clone`、`Destroy` 或场景节点属性访问时，使用 `roblox-engine-nodes`；纯 UI 节点属性和事件由 `roblox-ui-components` 负责
- 涉及框架类用法示例、组件内交互接法、交互生命周期清理时，使用 `game-examples`，并以该 Skill 自身的路由规则为唯一 reference 入口
- 审查服务端安全漏洞、权限绕过、严重逻辑缺陷、崩溃风险或高危遗漏时，以 `server-code-critical-review` 为主；除非用户同时要求风格审查，否则不输出普通风格问题
- 只有用户显式调用 `$integrate-feature-branch` 并要求集成已测试通过的 feature 时，才使用 `integrate-feature-branch`

- 新增或移除系统、改变系统核心流程、玩法规则或核心数值，以及用户要求整理系统验收清单或记录验收结论时，使用 `maintain-acceptance-checklist`。`Docs/功能验收清单.md` 按系统保留关键功能和核心数值，不记录小细节调整和普通 bug 修复，也不因此自动取消勾选；核心规则变化或原系统验收结论失效时才更新相关项。

## Skill 选择优先级

- 专用 Skill 优先于通用 Skill。例如背包拖拽先读取 `game-examples` 的背包 reference 确认当前原生 Tool 接法，再按需要读取原生拖拽 reference；不假设已有定制背包类。
- UI 任务由 `roblox-ui-components` 负责 UI API；只有同时操作非 UI 场景节点时才追加 `roblox-engine-nodes`。
- 场景、存储和 UI 节点的路径、层级、ClassName 与属性直接通过 Roblox MCP 查询；UI 生命周期和引擎 API 仍由对应 Skill 负责。
- `roblox-luau-standards` 负责通用 Lua 规范；服务端安全审查的结论范围由 `server-code-critical-review` 决定。

## Skill 渐进读取与内容复用

- 每轮对话中，当用户明确指定某个 Skill，或当前任务与其 `description` 匹配时，选择完成任务所需的最小 Skill 集合。
- 首次使用某个 Skill 时，必须在执行依赖该 Skill 的操作之前，按精确文件路径完整读取其 `SKILL.md`，直到文件末尾。
- 不要读取当前任务未选中的 Skill。
- 对 `SKILL.md` 引用的文件，遵循该 Skill 中的路由要求，只读取当前任务实际需要的文件。除非 `SKILL.md` 明确要求，否则不要批量读取整个 `references/` 目录。
- 同一轮中，如果相同文件路径的完整正文仍在当前上下文中，可以直接复用；无法确认完整时重新读取。
- 不创建额外的 Skill 缓存文件或已读取文件清单。

## 明确的禁止(必须遵守)
- 禁止一次性读取 `ReplicatedStorage/Scripts/Game/Configs/` 和 `ReplicatedStorage/Scripts/Game/Shared/` 整个目录；先使用 `rg` 定位目标配置和行号，再只读取完成任务所需的最小文件片段。
- 手工或 AI 制作的模型禁止放入 `game.Workspace.BlockMeshs` 和 `game.ReplicatedStorage.Assets.BlockMeshs`，包括它们的子目录；这两个目录专供地图块编辑器管理，对应本地目录也不得用于保存此类模型。

## 制作模型的存放规则

- 场景中直接摆放的模型统一放入 `game.Workspace.Decorations`。
- 供运行时克隆的可复用模型模板统一放入 `game.ReplicatedStorage.Assets.Decorations`。
- 模型与上述容器在 Studio 中维护，不通过 Script Sync 创建非脚本实例。确需保存本地模型副本时明确导出与导入步骤，不把本地保存当作 Studio 已更新；不得将模型放进 BlockMeshs。

## 补充说明
- 需要读取场景、存储或 UI 节点时，直接使用 Roblox MCP：先用 `list_roblox_studios` 确定目标 Studio，再用 `get_studio_state` 确认当前模式和可用 DataModel。
- 用 `search_game_tree` 查询目标子树，按需要限定路径、类型、深度和结果数量；用 `inspect_instance` 获取具体节点的属性、Attributes 和子节点。节点名称、完整路径、层级和 ClassName 以 MCP 返回结果为准，不猜测。
- 编辑态查询使用 `Edit`；已有试玩中的运行时查询按目标使用 `Client` 或 `Server`。UI 模板查 `StarterGui`，玩家实际界面在客户端 DataModel 中查目标玩家的 `PlayerGui`，不要把模板当作运行时界面。
- 只读节点查询直接进行；需要的运行时 DataModel 尚未开启时，说明待确认范围，按既有测试或试玩授权决定是否启动游戏。
- MCP 不可用时说明当前实例结构尚未确认；本地同步脚本、模型副本和动态创建代码可用于分析预期结构，但不能作为当前 Studio 或运行时节点已存在、同步已完成的证据。
- `.agents/`、`AGENTS.md`、`Docs/`、`Tests/`、`Tools/` 和 `Build/` 是开发资料或产物，不作为游戏脚本同步根。
- 业务模块显式声明 `local FX, FC, FS = _G.FX, _G.FC, _G.FS` 中实际用到的变量；每个 ModuleScript 返回有效结果。
- 项目协议声明在 `ReplicatedStorage/Scripts/Game/Shared/NetworkProtocol.luau` 的 `ClientMsgID/ServerMsgID`；框架协议在 `ReplicatedStorage/Scripts/Framework/FrameworkInit.luau`。
- `FC` 开头的代码属于框架，统一放在 `ReplicatedStorage/Scripts/Framework/Client/`；项目开发不直接修改这些框架代码，只通过项目子类继承和覆写接入，子类放在本地 `StarterPlayerScripts/Client/`。
- 目录尽量对齐 `F:/MiniGame/Studio_Y3/Code`：MiniStudio 的 `MainStorage` 对应 Roblox 的 `ReplicatedStorage`；保留 `Scripts/Framework/Shared`、`Client`、`Server` 分层，`FShared/FClient/FServer/FrameworkInit` 放在框架根目录。服务端框架仅由服务器初始化，私有配置仍放在 `ServerScriptService`。
- 新代码直接用 Roblox 服务名称；不使用 MiniStudio 节点 API 或资源 URI。

## PowerShell 命令安全规范
- 运行 PowerShell 命令时，始终使用 PowerShell 安全语法，避免解析错误。
- 对正则/模式/glob 参数优先使用单引号，例如：`-g '*.luau'`、`'GetNumber\(|WatchDataChanged\('`。
- 不要在类似正则的参数中留下未加引号的 `|`、`*`、`(`、`)` 或 `"`；应显式加引号或转义。
- 在 PowerShell 中使用 `rg` 时，优先采用这种形式：`rg -n --max-count 200 -g '*.luau' 'pattern1|pattern2|pattern3' <path>`。
- 使用 `rg` 检索时，先只用 `-n` 精确定位行号；禁止默认使用 `-C`/`--context` 输出上下文。
- 必须限制返回量：优先加 `--max-count`，或先限定到更小的路径/文件段后再检索。
- 不要无范围地使用 `rg -u`、`rg -uu`、`rg -uuu`；确需检查隐藏或被忽略文件时，必须同时限定到明确目录和文件类型。
- 如果命令仍然会被 PowerShell 错误解析，在合适情况下使用 `--%` 来停止 PowerShell 的参数解析。

## 编码建议
- 只实现用户明确要求的最小功能。
- 不要主动引入额外功能、额外抽象或面向未来的扩展，除非用户明确提出。
- 如果你判断额外功能确实有必要或有明显收益，先告知用户，再等待确认后再添加。

## FXLoader 节点与模块加载

- 框架初始化完成后的业务代码，加载必需的固定路径节点或模块时，优先使用 `FX.Loader` 简化连续 `WaitForChild` 和 `require(...:WaitForChild(...))`；不要再封装一套路径加载工具。具体 API 与示例见 `.agents/skills/roblox-luau-standards/reference-rules.md` 的 FXLoader 章节。
- 使用 `local FX = _G.FX`（或合并进已有 FX/FC/FS 声明）和 `local FXLoader = FX.Loader`；不要把 `require(FXLoader 模块)` 的返回值当作加载器，该模块返回 `true`。
- FXLoader 仍逐层等待复制节点，默认每层超时 10 秒，缺失会报错。框架初始化前、需要无限等待或超时返回 `nil` 的调用保留原生 `WaitForChild`；可选或动态节点使用 `FindFirstChild` 或 `FXLoader:Find` 并处理缺失。不要机械替换或借此修改无关代码。

## 数值文案显示

- 力量、货币、经验、价格、收益等数量文案，统一调用 `ReplicatedStorage/Scripts/Game/Shared/GameUtility.luau` 的 `GameUtility.NumberToText`；不要在各 UI 中重复实现单位换算或小数格式化。
- 大数使用该方法定义的 `K/M/B/T/Qa/...` 英文缩写；小数沿用通用方法的两位小数规则，例如 `2/3` 显示为 `0.67`。明确需要取整显示时使用 `NumberToTextFloor`。
- 等级、序号、背包件数/容量、时间和百分比按各自语义显示，不强制使用数量缩写。
- 格式化仅用于文案；计算、比较、存档和服务端发奖始终使用原始数值。均分收益先计算再格式化，不使用格式化后的字符串参与计算。

## 英文文案与 Roblox 自动翻译（编码必查）

- 游戏主要面向海外玩家。新增或修改玩家可见文案时，必须使用自然、简洁的英文作为源文案和默认显示，包括 UI、提示、弹窗按钮、物品名称、品质及交互提示；代码注释和开发文档继续使用中文。
- 项目只维护英文，其他语言交给 Roblox 云端自动翻译；不要新增本地中文或其他语言字典、语言分支或自建机器翻译接口。确需修正译文时，在 Roblox 云端翻译门户维护。
- 编码前先定位当前项目已有的翻译入口和英文文案表并复用，不为每个组件创建 Translator 或重复封装。纯净框架或新项目尚无翻译模块时，不假设业务模块和文档存在，只按当前需求接入最小的 Roblox 原生本地化能力。
- 固定 UI 英文文案使用 Roblox 自动本地化，确认显示节点的 `AutoLocalize` 设置；动态数量、物品名称等文案使用稳定 Key 和原生参数模板，例如 `Strength: {value}`、`Loot stored: {count:int}`。禁止先拼接完整句子再翻译；同一条文案不能因数值变化生成不同 Key。
- 带业务参数的提示由服务端发送 Key 和原始业务参数，客户端按玩家语言格式化；需要数量缩写时沿用当前项目已有的统一数值格式化方法，再作为字符串参数传入。译文和格式化字符串不参与计算、存档或发奖。
- 脚本翻译的显示顺序为 Roblox 云端译文 → 本地英文源文案；英文玩家直接显示英文。云端未加载、加载失败、条目或译文缺失时必须保留英文显示，不能让界面空白或显示 Key；本地英文兜底随项目发布，不依赖网络。
- 脚本写入已翻译文本的节点关闭 `AutoLocalize`，避免二次翻译；玩家游戏内切换语言后刷新已显示的动态文案，连接和后台任务按组件生命周期清理。
- 新增或修改 Key 时同步维护英文源文案和参数示例，并检查 Key 唯一、参数名及格式标签一致。动态 Key 需要导入 Roblox 云端翻译表，不能只依赖自动文本采集；交付时明确尚未完成的上传或云端设置，不把本地构建成功当作自动翻译已生效。
- 新增或修改需要本地化的提示、UI 或其他玩家可见文案时，AI 必须通过 Roblox MCP 在 Studio 编辑态维护现有 `game.ReplicatedStorage.Shared.Localization`（`LocalizationTable`，源语言 `en-us`），不要默认要求用户反复导出、修改和导入 CSV。先按上述 MCP 流程确认目标 Studio、编辑态和实例类型，再读取现有条目，仅更新当前任务涉及的 Key、英文源文案、英文值和参数示例，保留其他条目及已有译文；修改后重新读取并核对结果。
- 本地化表的编辑态读取和写入可使用 Roblox MCP 的 `execute_luau` 调用原生 `LocalizationTable` API；这是文案数据维护，不属于启动试玩或运行游戏测试，不执行业务模块或启动游戏。Script Sync 不同步该表，不能把本地 CSV 或脚本保存成功当作表已更新。MCP 不可用或目标实例无法确认时，明确报告未完成的本地表更新，再说明 CSV 导入的替代步骤。
- 通过 MCP 更新本地 `LocalizationTable` 不会自动更新 Roblox 云端翻译表；交付时分别说明本地表更新及核对结果、云端待上传的 Key 和文案。CSV 用于需要时的云端上传或本地备份，不作为日常 AI 修改本地表的必经步骤。
- 原生 Tool、默认排行榜和图片内文字不能假设自动文本采集会覆盖；按实际显示入口处理。模型名、节点路径、物品 ID 和存档标识保持稳定，不能直接翻译用于代码查找的名称；需要本地化显示名时先将显示文字与业务识别分开。
- 完成涉及文案的代码修改前，检查英文默认显示、动态参数替换及英文兜底；实际试玩仍遵循本工作区的验证授权。仅迁移当前任务触及的文案，不顺带全量改写历史中文内容。

## 注释硬规则
- 新增或修改 Lua 函数时，必须补充与实际签名一致的 JSDoc3 注释：有形参时逐一写 `@param`，有返回值时写 `@return`；不要为不存在的参数或返回值虚构标签。
- 注释必须说明业务意图或约束，不要只重复代码字面语义。

## Luau 验证规则
- 默认沿用源工作区的验证限制：新增或修改 Luau 后只做编译/语法验证，以及通过 Roblox MCP 只读核对同步后的脚本类型、RunContext 和内容，不自行运行 Lua 脚本或启动游戏。用户明确要求运行测试或试玩时，以该授权为准，并在结果中区分语法、同步核对与实际运行验证。
- 通过 Roblox MCP 只读查询当前场景或 UI 节点属于开发信息读取，可直接执行；这不等于启动试玩或运行游戏测试。
- 编译器先检查 PATH 和 `Build/luau/luau-compile.exe` 等实际本地位置，不假设已安装；缺失时报告未完成语法验证。不运行 `rojo build` 或 `rojo sourcemap`，不为验证创建 `default.project.json`。Script Sync 无法确认或发生冲突时报告待核对范围，不把磁盘保存成功当作同步成功。
- `git diff --check` 从仓库根执行。不要把历史验收记录当作本次结果。

## 编码与文本处理规范
1. 所有文本操作默认使用 UTF-8，并显式写 `-Encoding UTF8`
2. 读取文本时使用 `Get-Content -Encoding UTF8`；编辑现有文件优先使用 `apply_patch`，不要用整文件覆盖代替小范围修改
3. 禁止使用 `>` 和 `>>` 写入文本；确需由命令生成新文件时使用明确的 UTF-8 编码参数
4. 搜索文本如果使用 `Select-String`，以及处理 CSV 时使用 `Import/Export-Csv`，都必须带 `-Encoding UTF8`
5. 不依赖系统默认编码，不假设文件编码正确



## Worktree 任务生命周期

- 本节仅适用于经 Git 确认的 Codex-managed linked worktree。若当前任务直接运行在
    本地 checkout（非 linked worktree），不应用本节关于主分支、任务外未提交修改、
    自动建分支及任务完成提交的限制；按用户当前请求完成修改和验证即可。

- 在 Codex-managed worktree 中直接使用当前 checkout 完成实现和验证；任务完成
    前不要为了提交而提前创建或切换分支。
- 实现和验证全部完成后，再从 Git 检查当前任务是否处于 Codex-managed linked
    worktree，不要根据路径名或先前对话猜测。
- 若当前是 detached HEAD，根据任务生成简短 kebab-case `<task-slug>`，创建第一
    个未占用的 `codex/<task-slug>`、`codex/<task-slug>-2` 等分支；若已经处于当前
    任务的 feature 分支则复用。若处于 `main` 或无法确认是当前任务分支，停止并
    请用户处理，不要静默切换或覆盖分支。
- 只用显式文件路径暂存当前任务文件，检查暂存 diff 后提交；若存在任务外改动、
    未知暂存内容或验证失败，停止且不要提交或丢弃改动。
- 提交后报告 feature 分支、完整 commit SHA 和验证命令及结果，然后结束任务。
    此阶段不 rebase、不合并 `main`、不 push，也不删除分支或 worktree。
- feature 分支的后续集成不属于任务完成提交；只有用户明确确认当前 feature 已
    测试通过并显式调用 `$integrate-feature-branch` 要求集成时，才按该 skill 执行。



## 编码原则

## 1. 编码前先思考

**不要假设。不要掩盖困惑。明确说出权衡。**

实现之前：

- 明确说明你的假设。如果不确定，就提问。
- 如果存在多种理解，列出来，不要默默选择一种。
- 如果有更简单的做法，说出来。必要时提出反对意见。
- 如果有不清楚的地方，停下来。指出困惑点并提问。

## 2. 简单优先

**用最少的代码解决问题。不做 speculative 的扩展。**

- 不添加需求之外的功能。
- 不为一次性代码创建抽象。
- 不添加未被要求的“灵活性”或“可配置性”。
- 不为不可能发生的场景写错误处理。
- 如果你写了 200 行，而其实 50 行就够，就重写。

问自己：“资深工程师会不会觉得这太复杂了？”如果会，就简化。

## 3. 精准修改

**只改必须改的地方。只清理你自己造成的问题。**

编辑现有代码时：

- 不要“顺手改进”相邻代码、注释或格式。
- 不要重构没有坏掉的东西。
- 匹配现有风格，即使你个人会用另一种写法。
- 如果发现无关的死代码，提出来，不要删除。

当你的修改产生遗留内容时：

- 删除由你的修改导致不再使用的 import、变量或函数。
- 不要删除原本就存在的死代码，除非用户要求。

检验标准：每一行修改都应能直接对应到用户请求。
