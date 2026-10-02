# 当前原生背包与道具

当前项目没有 FCInventoryCompClass 和旧版定制背包 UI。
不要生成继承该类的代码，也不要假设已有背包筛选、拖拽换格、详情面板或库存同步协议。

实际入口：
- `ReplicatedStorage/Scripts/Framework/Server/Player/FSInventoryCompClass.lua`：存档、容量、堆叠、增删、换格、UseItem。
- `ServerScriptService/Server/Player/SPlayerObjectClass.lua`：SInventoryCompClass，
  创建 Tool、SyncTools、ActivateTool；组件协作名为 FSInventoryComp。
- `StarterPlayer/StarterPlayerScripts/Client/Player/CNativeBackpack.lua`：Tool.Activated 输入，
  发送 C2S_ActivateTool。
- `ReplicatedStorage/Shared/Config/FrameworkConfig.lua`：Inventory 字段、Items、容量配置。

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
