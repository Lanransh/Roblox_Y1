# 节点约束

- 玩家身份从 Players:GetPlayerFromCharacter 或已认证协议调用者取得；接触事件给的是 Part，不能直接当 Player。
- 角色可能重生、玩家可能离服，异步回调返回时确认当前 Character/会话。
- 接触可能由多个身体部件重复触发；涉及发奖或传送时按实际需求检查状态、冷却和归属。
- 网络所有权和客户端物理使接触不能独自证明付费、领奖或伤害资格；权威结果需服务端业务校验。
- Model 用 PivotTo，Part 用 CFrame；单位使用 Roblox stud，不能沿用原项目数值尺度。
- Clone/Destroy 前确认操作端和拥有者；只销毁本组件创建或明确接管的节点。
- TrackConnection 持有组件连接；任务、自建实例在 Dtor 清理。
- UI 属性与事件按 roblox-ui-components，不在这里重复。
