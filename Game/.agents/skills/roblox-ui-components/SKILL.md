---
name: roblox-ui-components
description: 在 Roblox_Y1 的 FCUICompClass 中开发原生 ScreenGui、GuiObject、按钮、列表和界面动画，处理节点路径与事件清理。新增或修改 UI 组件及交互时使用。
---

# Roblox UI 组件

需要读取 UI 节点时，按 Game/AGENTS.md 的 Roblox MCP 规则查询实际路径、ClassName、层级和属性；区分 StarterGui 模板与客户端 PlayerGui 界面。按当前任务读取：
- 节点属性、按钮事件、列表：[reference-ui-node-access.md](reference-ui-node-access.md)。
- 组件结构与生命周期：[reference-rules.md](reference-rules.md)。
- 常用接法：[reference-cheatsheet.md](reference-cheatsheet.md)。
- 完整组件骨架：[reference-examples.md](reference-examples.md)。

项目 UI 使用原生 Roblox 节点；默认背包使用 CoreGui Backpack 与服务端 Tool。
按钮和数据订阅只注册一次，重复 Show 不重复绑定。
付费 UI 通过 `FC.PlayerObject:RequireComponent("FCCommonUIComp"):ShowDeveloperBuyUI(productId)`，
该入口执行 C2S_BuyCheck；实际发奖由服务端 FSShopService 的 ProcessReceipt 完成。
不得把关闭购买窗口、客户端成功消息当发奖证据。
