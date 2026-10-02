---
name: roblox-engine-nodes
description: 使用 Roblox Instance、BasePart、Model、Humanoid 等非 UI 节点 API，实现克隆、移动、销毁、属性和接触逻辑。纯 UI 节点操作由 roblox-ui-components 负责。
---

# Roblox 非 UI 节点

节点路径先按 roblox-node-tree-reader 确认。按需要读取：
- 属性、移动、接触事件：[reference-cheatsheet.md](reference-cheatsheet.md)。
- 类型、所有权、物理边界和清理：[reference-rules.md](reference-rules.md)。
- 克隆与接触代码：[reference-examples.md](reference-examples.md)。

先确认具体 ClassName，再选 API。Model、BasePart、Humanoid 和 Actor 职责不同；
Roblox Actor 是并行脚本容器，不是玩家角色。
新代码使用 Roblox 原生服务和已授权资源；不照搬 MiniStudio Transform、SandboxNode 或 ModelId。
需要本地资料未覆盖的 API 时查 Roblox 官方文档，不猜接口。
