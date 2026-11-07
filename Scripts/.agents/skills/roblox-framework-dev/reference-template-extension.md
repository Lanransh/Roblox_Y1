# 项目文件职责与扩展位置

路径相对 `Scripts/`。本项目已有完整业务，不把其他仓库的空模板、默认配置或停用状态当作当前事实；挂载与签名以当前源码为准。

## 服务端扩展

以下路径位于 `ServerScriptService/Server/`。

| 文件 | 职责与添加位置 |
| --- | --- |
| `Main.server.luau` | 唯一服务端入口，负责初始化、处理器注册、类加载和实例创建，不写玩法结算或协议实现。 |
| `Player/SPlayerObjectClass.luau` | 挂载组件、存档版本迁移及必要的玩家级协作；持久化和 Ready 握手沿用框架。 |
| `Player/SPlayerObjectManagerClass.luau` | 项目协议注册一次，按认证身份查玩家并转发业务；本项目 GM 由 `RegGMMsg` 注册，不能再在框架或每个玩家中重复注册。 |
| `Player/SMiscCompClass.luau` | 按当前职责维护已有逻辑；新的独立玩法和生命周期放对应 `SXXXCompClass`，不持续堆积到杂项组件。 |
| `Handlers/BuyHandlers.luau` | 提供 `CanBuy/Buy` 处理器，经 Provider 接入购买上下文，不另建平台收据结算流程。 |
| `Handlers/ItemHandlers.luau` | 提供 `CanUse/Use` 处理器，由道具上下文调用，不建立客户端直接发奖入口。 |
| `Handlers/RewardHandlers.luau` | Item/Money 无法表达时扩展奖励 Type，遵循奖励组件预检与提交契约。 |
| `Player/SGMCompClass.luau` | 已登录开发者本人的调试操作；新增命令明确权限、参数及范围，不开放任意字段或代码执行。 |
| `Handlers/GMRecovery.luau` | 加载失败时恢复开发者本人存档，沿用管理器接口、会话锁及支付回执保护；正常业务不调用。 |
| `Player/ItemToolVisual.luau` | 原生 Tool 图片外观，不承担拥有权、效果或发奖。 |
| `Player/SAnalyticsCompClass.luau` | 项目事件口径、漏斗和会话统计，复用 FS.AnalyticsManager；统计故障不阻断核心业务。 |
| `Service/SPurchaseReceiptService.luau` | 接入项目购买统计与提示；当前平台回调包装框架 ProcessReceipt，结算、去重与保存仍由框架负责，不能覆盖已有包装或建立第二套结算。 |
| `Service/SGamePassService.luau` | 项目 Game Pass 权益校验与恢复；与 Developer Product 收据区分，异步返回重验会话。 |
| `Service/SRankingServiceClass.luau` | 项目榜单接入与查询，结合 SRankingClass/SStrengthRankingClass 核对实际写分和关服流程。 |
| `Config/StorageConfig.luau` | 私有存档名称、测试模式、保存周期和会话锁；变更时说明对测试及正式数据的影响，不当作玩法配置。 |

三个 Handlers 表由 Main 注册到 Provider，已有业务实现不得用空模板覆盖。预留名称沿用既有约定；新建端专属模块遵循 AGENTS.md。

## 处理器调用契约

- ItemHandlers：配置 UseHandler 对应对象，调用 `handler:CanUse(context)`、`handler:Use(context)`。context 包含 playerObject、itemObject、itemDataConfig、consumeCount 和 extraData。消耗与回滚须核对背包调用点，预检不得发奖或扣库存。
- BuyHandlers：配置 BuyHandler 对应对象，调用 `handler:CanBuy(context)`、`handler:Buy(context)`。context 包含 playerObject、devGoodsId、num、goodsConfig 和 extraData。CanBuy 只预检，结算 Buy 不得 yield，成功显式返回 true，不用客户端购买完成通知发奖。
- RewardHandlers：奖励 Type 对应函数 `handler(rewardComponent, entry, tables)`。在预检中验证条目，将待提交的表字段快照写入 tables，字段名对应 PlayerDataConfig，成功返回 true。不直接改档、发奖或启动异步任务；预检可能重复且整批仍可能失败。当前不支持自定义 Type 作为消耗。

处理器只在服务端注册。写实现前读取实际上下文及调用点，不把项目处理器 require 到框架共享模块。

## 公共接入

以下路径位于 `ReplicatedStorage/Scripts/`。

| 文件 | 职责 |
| --- | --- |
| `GameInit.luau` | 两端初始化编排，只加载当前项目配置、Provider 和框架。 |
| `SetupProvider.luau` | 项目配置与框架之间的接入边界；新接口需调用者和 Provider 配套，不直接套用其他仓库的容量、管理员或空榜单设置。 |
| `Game/Shared/PlayerDataConfig.luau` | 玩家字段类型、默认值、存档域与同步策略；组件不重复补默认结构，旧档变更通过项目迁移。 |
| `Game/Shared/NetworkProtocol.luau` | 初始化前声明项目协议；先核对 FrameworkInit 已有消息，避免重复声明。 |
| `Game/Shared/Text.luau` | 当前项目文案定义与翻译入口；客户端 Main 初始化 FC.Localization，业务文案仍在所属脚本声明。 |

`Game/Configs/` 只读；配置通过 MCP 修改源 XLSX，检查、保存成功后导出。扩展已有 Shared 模块前按文件定向搜索，不批量读取整个目录。

## 添加功能时的判断

- 玩家独有状态放对应玩家组件；跨玩家共享的地图状态、刷新器或服务放 `Service/`。
- 新类先由 Main require 注册，再 AddComponent 或创建服务；握手前必需的服务先于玩家管理器就绪，不依赖目录自动扫描。
- 跨项目可复用且不依赖项目配置或节点的能力才考虑放入框架；普通业务通过现有 Provider、回调或子类接入，框架维护仍须有用户任务授权。
- 查询节点复用 FX.Loader；本项目支持 `.` 与 `/` 路径，不照搬其他仓库仅点分隔的实现；特殊名称按编码规则使用原生节点 API。

验证遵循 AGENTS.md，默认编译和同步只读核对；加载成功或静态检查不等于实际玩法验收。
