---
name: game-examples
description: Roblox_Y1 框架的协议、玩家组件、原生背包、商店、排行榜、好友、引导、声音和输入接入参考。明确需要这些接法或生命周期示例时使用，按任务读取最具体的参考。
---

# Roblox 项目接入示例

先查当前类、协议、字段与模型。只打开最具体的主参考；需要直接依赖时再追加。
示例中的 Example、Coins 和演示节点需要按任务新增，不能当作项目现状。

| 任务 | 参考 |
| --- | --- |
| 新增 C2S/S2C | [how-to-add-network-protocol.md](references/how-to-add-network-protocol.md) |
| 客户端玩家组件 | [how-to-add-client-component.md](references/how-to-add-client-component.md) |
| 服务端玩家组件 | [how-to-add-server-component.md](references/how-to-add-server-component.md) |
| 背包、Tool、道具使用 | [reference-inventory-component.md](references/reference-inventory-component.md) |
| 商店 UI 与 Developer Product | [reference-shop-framework.md](references/reference-shop-framework.md) |
| 排行榜 UI | [reference-ranking-component.md](references/reference-ranking-component.md) |
| 好友、邀请与好友倍率需求 | [reference-friend-rate-system.md](references/reference-friend-rate-system.md) |
| 新手引导 | [reference-tutorial-guide.md](references/reference-tutorial-guide.md) |
| 声音与 BGM | [reference-sound-component.md](references/reference-sound-component.md) |
| 动画、Timeline 迁移 | [reference-timeline.md](references/reference-timeline.md) |
| 鼠标与触摸输入 | [reference-touch-object.md](references/reference-touch-object.md) |
| UI 拖拽 | [reference-drag-object.md](references/reference-drag-object.md) |
| UI / 键盘长按 | [reference-hold-ui-object.md](references/reference-hold-ui-object.md) |

背包、触摸、拖拽、Timeline 参考已按 Roblox 改写；原 MiniStudio 同名类并非都已迁入。
好友倍率与邀请 UI 也不是当前已有玩法。按明确需求补最小实现，不自动移植原项目业务。
代码遵循 roblox-luau-standards；UI 按 roblox-ui-components；需要读取场景或 UI 节点时，按 Game/AGENTS.md 的 Roblox MCP 规则直接查询。
