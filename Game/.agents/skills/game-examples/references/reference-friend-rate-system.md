# 好友基础与倍率需求

文件名保留原参考入口；内容适配当前 Roblox 好友基础能力。
当前没有好友收益倍率、InviteFriendData、eFriendExtraRate、邀请 UI 或客户端上传好友列表协议。

现有服务：
- `ServerScriptService/Server/Framework/Modules/FSFriendService.lua`，
  服务实例 FS.FriendService：GetFriendIds(userId)/IsFriend(userId, otherId)/GetFriendCountInRoom(userId)/GetState(userId)。
- `StarterPlayer/StarterPlayerScripts/Client/Framework/Player/FCFriendCompClass.lua`，
  已挂载组件 FC.PlayerObject:RequireComponent("FCFriendComp")，GetState/GetFriendCountInRoom。
- C2S_GetFriendState 与 S2C_FriendState 只传服务器验证的同服快照。
- state 为 {ids, status, revision}，status 为 Loading/Ready/Unavailable。
  失败保留旧展示快照，不能当当前已验证关系；非 Ready 的人数返回 nil。
- 服务端分页读完平台好友列表才提交，当前每 120 秒刷新；异步结果检查玩家会话。
- FriendStateChanged 由玩家组件发布，晚订阅 UI 先 GetState 取当前快照。

如果明确要求好友倍率，先从需求确认适用收益、公式、上限与失败状态策略，
再把计算接到服务端真实收益入口。不信任客户端好友 ID 或倍率，不猜测加成参数。

若明确要求邀请按钮，客户端先调用 SocialService:CanSendGameInviteAsync 并处理失败，
允许时 PromptGameInvite；邀请弹窗本身不证明好友加入，更不能作为领奖依据。
调用引擎内置邀请 UI 仍按用户要求执行，不在本次迁移中实际邀请或发送通知。

依据：[Player invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts)。
