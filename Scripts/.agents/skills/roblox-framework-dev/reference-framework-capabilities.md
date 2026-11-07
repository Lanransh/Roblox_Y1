# 框架能力复用索引

本页回答“是否已有这个能力”；项目落位见 [项目文件职责](reference-template-extension.md)。框架路径以 `ReplicatedStorage/Scripts/Framework/` 为基准，项目路径以工作区为基准。只读本次功能相关实现，签名、返回值和挂载状态以当前源码为准。

| 需求 | 优先复用与扩展方式 | 源码定位 |
| --- | --- | --- |
| 道具效果 | 项目 ItemHandlers 接入道具上下文，消耗和回滚按背包调用流程处理 | `Shared/FXItemProcessor.luau` |
| 购买效果和平台支付 | 项目 BuyHandlers 实现效果，收据去重、保存与重试沿用 ShopService | `Shared/FXBuyProcessor.luau`、`Server/Modules/FSShopService.luau` |
| 奖励、消耗和交换 | 复用 FSRewardComp 预检、容量和余额校验，内置奖励不能表达时才扩展 RewardHandlers | `Server/Player/FSRewardCompClass.luau` |
| 堆叠、容量与库存 | 项目子类提供 GetConfig，复用背包算法及原生 Tool 接入 | `Server/Player/FSInventoryCompClass.luau`、`Client/FCNativeBackpack.luau` |
| 玩家存档和生命周期 | 继承玩家及管理器基类，复用 KV，不另建保存循环、会话锁或 Ready 握手 | `Server/Player/FSPlayerObjectClass.luau`、`Server/Player/FSPlayerObjectManagerClass.luau`、`Server/PlayerKV/FSPlayerKVDataManager.luau` |
| 同步和订阅 | 玩家字段走 PlayerDataConfig 与 WatchDataChanged，共享状态走 FXSyncManager | `Client/Player/FCPlayerObjectClass.luau`、`Shared/FXSyncManager.luau` |
| 网络消息和 GM | 使用 FX.Network；先查框架及项目协议，GM 由项目管理器注册与鉴权 | `Shared/Core/FXNetwork.luau`、`FrameworkInit.luau`；项目 `ServerScriptService/Server/Player/SPlayerObjectManagerClass.luau` |
| 排行榜 | 项目提供榜单定义与权威分数，复用存储、查询及 UI 基类 | `Server/Ranking/FSRankingManager.luau`、`Server/Modules/FSRankingServiceClass.luau`、`Client/Player/FCRankingUICompClass.luau` |
| 好友和邀请 | 复用缓存及好友组件；邀请不在每个 UI 单独查询 | `Server/Modules/FSFriendService.luau`、`Client/Player/FCFriendCompClass.luau`；项目 `StarterPlayerScripts/Client/Player/CFriendInviteCompClass.luau` |
| 新手引导 | 项目提供定义、字段和业务事件，复用两端引导基类 | `Server/Player/FSTutorialGuideCompClass.luau`、`Client/Player/FCTutorialGuideCompClass.luau` |
| UI 显隐和动画 | 普通组件继承 FCUICompClass，动画使用 FC.UIAnim；Generated 按对应技能接入 | `Client/Player/FCUICompClass.luau`、`Client/FCUIAnim.luau` |
| 提示、确认框和道具说明 | 复用通用 UI 基类与项目接入，不新建第二套提示协议或展示 | `Client/Player/FCCommonUICompClass.luau`；项目 `StarterPlayerScripts/Client/UI/CCommonUICompClass.luau`、`UI/ToolDescription.luau` |
| 翻译和按钮悬停 | 沿用项目 Text、FC.Localization 和 CCommonUICompClass 持有的悬停实例 | 项目 `ReplicatedStorage/Scripts/Game/Shared/Text.luau`、`StarterPlayerScripts/Client/Localization.luau`、`UI/ButtonHover.luau` |
| 自定义交互提示 | 沿用项目 PickupPrompt，业务资格仍在服务端校验 | 项目 `StarterPlayerScripts/Client/PickupPrompt.luau` |
| 声音、BGM 和音效池 | 项目子类提供曲目与触发，复用声音基类的播放、池和清理 | `Client/Player/FCSoundCompClass.luau` |
| 按键和长按 | 复用输入对象，不为每个按钮复制计时逻辑 | `Client/FCKeyObjectClass.luau`、`Client/FCHoldUIObjectClass.luau` |
| 统计上报 | 项目定义事件口径，平台接入复用 FS.AnalyticsManager | `Server/Modules/FSAnalyticsManager.luau` |
| 节点、任务和通用计算 | 先查 Core 的节点、任务、数学、曲线、表和时间工具；数量文案用 GameUtility.NumberToText | `Shared/Core/FXLoader.luau`、`FXTask.luau`、`FXMath.luau`、`FXCurveSampler.luau`、`FXTable.luau`、`FXTime.luau` |

存在类或协议不代表功能已启用。先核对注册、配置、挂载及生命周期，不复制实现来绕过缺失步骤。实现前确定复用入口与项目扩展位置，确需新增基础能力时说明现有缺口，不自动清理任务以外的历史重复代码。

完整接法按 [game-examples](../game-examples/SKILL.md) 路由；本页不维护第二份实现示例。
