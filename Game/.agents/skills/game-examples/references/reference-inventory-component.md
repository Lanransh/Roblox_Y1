# 当前原生背包与道具

当前项目没有 FCInventoryCompClass 和旧版定制背包 UI。
不要生成继承该类的代码，也不要假设已有背包筛选、拖拽换格、详情面板或库存同步协议。

实际入口：
- `ReplicatedStorage/Scripts/Framework/Server/Player/FSInventoryCompClass.lua`：存档、容量、堆叠、增删、换格、UseItem。
- `ServerScriptService/Server/Player/SPlayerObjectClass.lua`：SInventoryCompClass，
  创建 Tool、SyncTools、ActivateTool；组件协作名为 FSInventoryComp。
- `ReplicatedStorage/Scripts/Framework/Client/FCNativeBackpack.lua`：Tool.Activated 输入，
  发送 C2S_ActivateTool；由 FClient 自动启动，项目 Main 无需手动调用。
- `ReplicatedStorage/Shared/Config/FrameworkConfig.lua`：Inventory 字段、Items、容量配置。

`Provider:GetNativeBackpackConfig()` 返回 `FrameworkConfig.NativeBackpack` 配置表，包含 `ShortcutEnabled` 和 `InventoryEnabled`，默认均为 true。
`ShortcutEnabled = false` 时，服务端不再将框架道具生成成 Tool，清理本组件已有 Tool，拒绝 ActivateTool 请求；客户端跳过 Tool 使用绑定，玩家无法手持框架道具。背包数据、发放及服务端直接调用 UseItem 的能力保留。
`InventoryEnabled` 控制原生界面显示，不删除背包数据。原生快捷栏和背包面板共用 CoreGui Backpack，任一字段为 false 时两者都隐藏；只关闭面板时输出原生界面限制警告。显示区不能独立隐藏。
配置在启动时读取，修改后需重启客户端与服务器。

新增道具配置包含 Id/Type/MaxStack/UseHandler。
需要原生背包呈现时，当前适配层支持 Name/ToolShape/ToolColor。
注册的使用处理器放服务端 `_G.Provider.ItemHandlers`，按 FXItemProcessor 的 CanUse/Use context 签名接入。

服务端发放可用 FSRewardComp 的 AddRewards；必须处理 false 返回：

```lua
local rewardComp = playerObject:RequireComponent("FSRewardComp")
local ok = rewardComp:AddRewards({ { Type = "Item", ItemId = 1001, Count = 1 } })
```

1001 是当前测试道具；真实奖励 ID 必须来自实际业务配置。
框架格号是存档身份，不能当默认背包屏幕数字键位置。
Inventory.Sync 当前为 false；客户端不具备完整框架背包数据。
若用户明确要求自定义背包，另行设计必要的同步字段、协议、服务器校验和原生 UI，
不在修改提示词时实现这些功能。
