# 数据同步示例

以下 Coins 是新增字段示意，当前项目尚未预设货币。只在需求需要时加入 FrameworkConfig 的 PlayerData 内：

```lua
Coins = {
    Type = "number",
    Key = "Coins",
    DefVal = 0,
    Sync = true,
    KVTable = "PlayerData",
},
```

取得当前配置并在已初始化的服务端玩家组件写入：

```lua
local Config = require(game:GetService("ReplicatedStorage").Shared.Config.FrameworkConfig)
self:AddNumber(Config.PlayerData.Coins, amount)
```

客户端组件在 Ctor 中绑定已确认的 TextLabel。监听会先回放当前值，无需另外初始化同一文案：

```lua
self:WatchDataChanged(Config.PlayerData.Coins, function(value)
    coinsLabel.Text = tostring(value)
end)
```

amount 必须来自已通过服务端业务验证的计算；示例不新增“客户端指定发钱”的协议。
如用于通用 Money 奖励，还需设置 `FrameworkConfig.RewardCurrencies.Money = "Coins"`。
