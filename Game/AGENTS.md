# Roblox_Y1 Game 工作区指南

## 角色

你是一名 Roblox 游戏开发者。
该项目使用 Luau 和 Rojo，沿用已迁移的 FX/FC/FS 组件框架。
本文件中的相对路径以 `Game/` 为基准；Git 仓库根目录是它的上级目录。

## 重要目录
- `default.project.json`：Rojo 服务映射
- `ReplicatedStorage/Framework/`：公共框架；`ReplicatedStorage/Shared/`：公共配置与模块
- `ServerScriptService/Server/`：服务端业务及框架
- `StarterPlayer/StarterPlayerScripts/Client/`：客户端业务及框架
- `Docs/功能验收清单.md`：当前已实现功能及其验收状态
- `Workspace/`、`ServerStorage/`、`StarterGui/`：场景、服务器模板和 UI 源节点
- `../Docs/框架迁移.md`：已迁移能力、业务接入与历史验证记录
- `Tests/`、`Tools/`、`Build/`：测试、辅助工具和构建产物，不加入 Rojo 服务映射

## 共享技能
在编写代码之前，先读取并遵循与当前任务匹配的技能文档：
- `.agents/skills/roblox-luau-standards/SKILL.md`
- `.agents/skills/roblox-framework-dev/SKILL.md`
- `.agents/skills/roblox-ui-components/SKILL.md`
- `.agents/skills/roblox-node-tree-reader/SKILL.md`
- `.agents/skills/roblox-engine-nodes/SKILL.md`
- `.agents/skills/game-examples/SKILL.md`
- `.agents/skills/server-code-critical-review/SKILL.md`
- `.agents/skills/maintain-acceptance-checklist/SKILL.md`
- `.agents/skills/integrate-feature-branch/SKILL.md`（仅允许用户显式调用）

## 何时读取 Skill

- 进行 Lua 编码、重构、风格修复或普通代码审查时，使用 `roblox-luau-standards`
- 涉及框架结构、玩家数据、服务端逻辑、客户端玩家组件、协议链路或组件协作时，使用 `roblox-framework-dev`；纯 UI 表现修改不触发该 Skill
- 修改客户端 UI 时，使用 `roblox-ui-components`
- 涉及任何地图树、场景节点、存储节点或 UI 节点访问时，使用 `roblox-node-tree-reader`
- 涉及非 UI 引擎节点 API，例如 `Instance`、`BasePart`、`Model:PivotTo`、`Clone`、`Destroy` 或场景节点属性访问时，使用 `roblox-engine-nodes`；纯 UI 节点属性和事件由 `roblox-ui-components` 负责
- 涉及框架类用法示例、组件内交互接法、交互生命周期清理时，使用 `game-examples`，并以该 Skill 自身的路由规则为唯一 reference 入口
- 审查服务端安全漏洞、权限绕过、严重逻辑缺陷、崩溃风险或高危遗漏时，以 `server-code-critical-review` 为主；除非用户同时要求风格审查，否则不输出普通风格问题
- 只有用户显式调用 `$integrate-feature-branch` 并要求集成已测试通过的 feature 时，才使用 `integrate-feature-branch`

- 完成或修改玩法系统、代码或配置改动影响玩法行为或数值结果时，以及盘点玩法或记录验收结果时，使用 `maintain-acceptance-checklist`，按玩法系统维护 `Docs/功能验收清单.md` 的系统功能和数值两部分；纯框架整理、日志等不影响玩法的改动不列项

## Skill 选择优先级

- 专用 Skill 优先于通用 Skill。例如背包拖拽先读取 `game-examples` 的背包 reference 确认当前原生 Tool 接法，再按需要读取原生拖拽 reference；不假设已有定制背包类。
- UI 任务由 `roblox-ui-components` 负责 UI API；只有同时操作非 UI 场景节点时才追加 `roblox-engine-nodes`。
- `roblox-node-tree-reader` 只负责确认节点路径、层级和类型，不重复规定 UI 生命周期或引擎 API。
- `roblox-luau-standards` 负责通用 Lua 规范；服务端安全审查的结论范围由 `server-code-critical-review` 决定。

## Skill 渐进读取与内容复用

- 每轮对话中，当用户明确指定某个 Skill，或当前任务与其 `description` 匹配时，选择完成任务所需的最小 Skill 集合。
- 首次使用某个 Skill 时，必须在执行依赖该 Skill 的操作之前，按精确文件路径完整读取其 `SKILL.md`，直到文件末尾。
- 不要读取当前任务未选中的 Skill。
- 对 `SKILL.md` 引用的文件，遵循该 Skill 中的路由要求，只读取当前任务实际需要的文件。除非 `SKILL.md` 明确要求，否则不要批量读取整个 `references/` 目录。
- 同一轮中，如果相同文件路径的完整正文仍在当前上下文中，可以直接复用；无法确认完整时重新读取。
- 不创建额外的 Skill 缓存文件或已读取文件清单。

## 明确的禁止(必须遵守)
- 禁止一次性读取 `ReplicatedStorage/Shared/Config/` 整个目录；先使用 `rg` 定位目标配置和行号，再只读取完成任务所需的最小文件片段。


## 补充说明
- 如果任务涉及场景或 UI 节点，先检查 `default.project.json`、对应模型源文件与动态创建代码；当前项目没有 `MapTree/`，不要依赖 `.maptree`。
- `.agents/`、`AGENTS.md`、`Docs/`、`Tests/`、`Tools/` 和 `Build/` 是开发资料或产物，不加入 Rojo 的服务映射。
- 业务模块显式声明 `local FX, FC, FS = _G.FX, _G.FC, _G.FS` 中实际用到的变量；每个 ModuleScript 返回有效结果。
- 项目协议声明在 `ReplicatedStorage/Shared/Config/FrameworkConfig.lua` 的 `ClientMessages/ServerMessages`；框架协议在 `ReplicatedStorage/Framework/FrameworkInit.lua`。
- 新代码直接用 Roblox 服务名称；不使用 MiniStudio 节点 API 或资源 URI。

## PowerShell 命令安全规范
- 运行 PowerShell 命令时，始终使用 PowerShell 安全语法，避免解析错误。
- 对正则/模式/glob 参数优先使用单引号，例如：`-g '*.lua'`、`'GetNumber\(|WatchDataChanged\('`。
- 不要在类似正则的参数中留下未加引号的 `|`、`*`、`(`、`)` 或 `"`；应显式加引号或转义。
- 在 PowerShell 中使用 `rg` 时，优先采用这种形式：`rg -n --max-count 200 -g '*.lua' 'pattern1|pattern2|pattern3' <path>`。
- 使用 `rg` 检索时，先只用 `-n` 精确定位行号；禁止默认使用 `-C`/`--context` 输出上下文。
- 必须限制返回量：优先加 `--max-count`，或先限定到更小的路径/文件段后再检索。
- 不要无范围地使用 `rg -u`、`rg -uu`、`rg -uuu`；确需检查隐藏或被忽略文件时，必须同时限定到明确目录和文件类型。
- 如果命令仍然会被 PowerShell 错误解析，在合适情况下使用 `--%` 来停止 PowerShell 的参数解析。

## 编码建议
- 只实现用户明确要求的最小功能。
- 不要主动引入额外功能、额外抽象或面向未来的扩展，除非用户明确提出。
- 如果你判断额外功能确实有必要或有明显收益，先告知用户，再等待确认后再添加。

## 注释硬规则
- 新增或修改 Lua 函数时，必须补充与实际签名一致的 JSDoc3 注释：有形参时逐一写 `@param`，有返回值时写 `@return`；不要为不存在的参数或返回值虚构标签。
- 注释必须说明业务意图或约束，不要只重复代码字面语义。

## Luau 验证规则
- 默认沿用源工作区的验证限制：新增或修改 Luau 后只做编译/语法验证及相关 Rojo 构建，不自行运行 Lua 脚本或启动游戏。用户明确要求运行测试或试玩时，以该授权为准，并在结果中区分编译、构建与实际运行验证。
- 编译器先检查 PATH 和 `Build/luau/luau-compile.exe` 等实际本地位置，不假设已安装；缺失时报告未完成语法验证。构建命令（在 Game 中）为 `rojo build default.project.json -o Build/Roblox_Y1.rbxlx`，先确认输出目录存在。
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
