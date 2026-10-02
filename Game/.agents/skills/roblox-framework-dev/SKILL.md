---
name: roblox-framework-dev
description: 在 Roblox_Y1 已迁移的 FX/FC/FS 框架中接入玩家组件、玩家数据、服务和网络协议，确认目录与启动顺序。纯 UI 样式修改不触发。
---

# Roblox 框架开发

先查当前同类实现、配置和启动入口，按任务只读相关参考：

- 目录、模块加载、Server/Client/Shared 落位：[reference-project-structure.md](reference-project-structure.md)。
- 数据、组件、网络 API：[reference-cheatsheet.md](reference-cheatsheet.md)。
- 玩家同步、组件生命周期、任务调度：[reference-rules.md](reference-rules.md)。
- 数据同步的具体接法：[reference-examples.md](reference-examples.md)。
- 新增协议或组件的骨架：按 `game-examples/SKILL.md` 路由。

核心约束：

- 服务端拥有权威状态；公共目录只放允许复制到客户端的配置与模块。
- 默认值来自 `FrameworkConfig.PlayerData`，不要在每个组件重新补默认结构。
- 新业务协议加到 `FrameworkConfig.ClientMessages/ServerMessages`；框架协议才修改 `FrameworkInit.lua`。声明在网络层首次 require 时读取，不能在启动后临时追加。
- 模块通过 require 注册类，之后才用 AddComponent。当前工程没有自动遍历加载全部业务类。
- 玩家组件每秒更新可用 `OnUpdate(serverTime)`；独立轮询需持有任务句柄，析构时取消。
- `WatchDataChanged` 会立即回放当前值；不要另写一份相同的初始 UI 更新。
