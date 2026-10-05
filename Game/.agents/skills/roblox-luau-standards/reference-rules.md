# Lua 规范细则

## 注释规范

- 注释解释“原因和约束”，不重复显见语义。
- 函数/类/模块注释使用 JSDoc3 标签（`@class/@param/@return/...`）。
- 项目注释统一中文。
- 禁止“预留参数（当前未使用）/预留点击参数”这类空描述；参数未使用时要说明来源与保留原因。
- 禁止将函数参数名或遍历变量命名为 `_`；未使用参数也需使用可读命名并在注释中说明来源。

## 结构规范

- 优先 early return 降低嵌套。
- 避免超长函数，复杂流程拆分子函数。
- 禁止单行 `if ... then ... end`。

## 命名规范

- 私有成员使用 `_` 前缀。
- 方法名使用 PascalCase。
- 术语命名前后一致。

## FXLoader 节点与模块加载

- 实现依据是 `ReplicatedStorage/Scripts/Framework/Shared/Core/FXLoader.lua`。FShared 加载它后注册到 `_G.FX.Loader`；业务代码在框架初始化完成后使用，不为了使用加载器提前或重复初始化框架。
- 声明 `local FX = _G.FX`（已有 FX/FC/FS 声明则复用），再声明 `local FXLoader = FX.Loader`。FXLoader 模块返回 `true`，不能通过 `local FXLoader = require(...)` 获取加载器。
- 必需固定路径优先使用下表 API，替代连续 `WaitForChild` 和包裹等待链的 `require`；均使用冒号调用，路径支持 `.` 或 `/` 分隔。路径从指定根节点的子节点开始，不包含根节点名称；`Parent` 不表示父级跳转。

| 需求 | API |
| --- | --- |
| ReplicatedStorage 下的节点 / 模块 | `FXLoader:Shared(path, timeout)` / `FXLoader:RequireShared(path, timeout)` |
| ServerStorage 下的节点 / 模块（仅服务端） | `FXLoader:ServerStorage(path, timeout)` / `FXLoader:RequireServerStorage(path, timeout)` |
| 指定实例下的节点 / 模块 | `FXLoader:Here(instance, path, timeout)` / `FXLoader:Require(instance, path, timeout)` |
| 当前脚本父节点下的模块 | `FXLoader:RequireFromParent(script, path, timeout)` |
| Workspace 下的节点 | `FXLoader:Workspace(path, timeout)` |
| 当前玩家 / PlayerGui 下的节点（仅客户端） | `FXLoader:Player(path, timeout)` / `FXLoader:PlayerGui(path, timeout)` |
| 可选节点，不等待，缺失返回 nil | `FXLoader:Find(instance, path)` 或原生 `FindFirstChild` |

例如，框架已初始化的业务模块中：

```lua
local FX = _G.FX
local FXLoader = FX.Loader

-- 替代 require(ReplicatedStorage:WaitForChild("Scripts"):WaitForChild("Game"):WaitForChild("Shared"):WaitForChild("GameUtility"))
local GameUtility = FXLoader:RequireShared("Scripts/Game/Shared/GameUtility")
-- 已持有根节点时，用相对路径简化其子节点等待链。
local closeButton = FXLoader:Here(rootNode, "Panel/CloseBtn")
```

- FXLoader 是等待链的简化，不是取消复制等待或缓存节点。底层默认每层等待 10 秒，缺失时抛错；`PlayerGui` 方法对 PlayerGui 根节点仍使用原生无限等待。替换前确认原调用的超时和缺失处理语义；需要无限等待或超时返回 `nil` 时保留原生 `WaitForChild`，不要用 `pcall` 掩盖差异。
- 框架初始化前的引导加载保留原生 `WaitForChild`。可选或动态节点不使用会报错的必需路径加载 API；路径名称包含 `.` 或 `/` 时使用原生节点 API，避免被当作路径分隔符。
- 不为单个原生等待强行改写，不新增重复加载工具，不批量改动任务范围外的等待代码。节点实际路径仍按项目要求通过 Roblox MCP 核对。
