# 添加客户端玩家组件

位置：`StarterPlayer/StarterPlayerScripts/Client/Player/CExampleCompClass.lua`。
UI 业务组件放 Client/UI。目标界面有 UIEditor 生成展示类时，先加载并继承该类，在 Generated 之外提供真实数据和动作处理；没有对应生成脚本的普通界面才沿用 FCUICompClass 或项目已有 UI 基类。接入前按 [UI 接入规则](../../roblox-ui-components/reference-rules.md) 确认界面来源、数据契约和生命周期。

```lua
local FX = _G.FX
local CExampleCompClass = FX.Class("CExampleCompClass", "FCPlayerCompClass")

--- 返回业务协作名。
--- @return string 组件名称。
function CExampleCompClass:GetCompName()
    return "CExampleComp"
end

--- 握手完成后执行需要初始玩家数据的逻辑。
function CExampleCompClass:OnReady()
    -- 按明确需求读取或订阅配置中已声明且 Sync=true 的字段。
end

return CExampleCompClass
```

在 Main.client.lua 加载 Scripts/GameInit 完成框架初始化之后、创建 PlayerClass.New 之前 require 业务模块（UIEditor 界面由业务模块先加载对应生成展示类），
然后在 `Client/Player/CPlayerObjectClass.lua` 的 Ctor 挂载：
`self:AddComponent("CExampleCompClass")`。

若覆盖 Ctor/Dtor 调用 Super。订阅连接用 TrackConnection；
FX 网络注册是每客户端协议唯一回调，需要 Dtor 解除。任务与自建节点单独清理。
