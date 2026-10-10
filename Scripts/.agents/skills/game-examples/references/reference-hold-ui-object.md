# UI 与键盘长按

现有类：
- `ReplicatedStorage/Scripts/Framework/Client/FCHoldUIObjectClass.lua` -> FC.HoldUIObjectClass
- 同目录 `FCKeyObjectClass.lua` -> FC.KeyObjectClass
- FClient 已 require 两者；类名和 FC 导出名不同，不使用旧 FC.FCHoldUIObjectClass。

UI 示例（button 为已确认的 GuiObject）：

```lua
local FC = _G.FC
self._holdObject = FC.HoldUIObjectClass.New(button)
self._holdObject:SetHoldDuration(1)
self._holdObject:SetProgressCallback(function(progress)
    fillNode.Size = UDim2.fromScale(progress, 1)
end)
self._holdObject:SetHoldCompleteCallback(function()
    -- 发起业务请求；完成长按本身不授予服务端权限。
end)
```

键盘构造：`FC.KeyObjectClass.New(Enum.KeyCode.F)`。
两类均有 SetHoldStartCallback/SetHoldCompleteCallback/SetHoldCancelCallback/SetProgressCallback；
具体 SetEnabled/SetKeyCode 等仅按各类当前实现使用。
短按触发取消，按满触发完成；隐藏时调用 StopHold() 停止当前计时，
必要时按需求屏蔽新输入。析构调用对象 Dtor 并清空引用。
UI 基类不自动知道界面显隐，不能只 Hide 界面却继续处理隐藏的快捷键。

## 场景原生长按圆圈

`Shared/FXProximityPromptObjectClass.lua` -> `FX.ProximityPromptObjectClass`，由 FShared 自动加载。
默认创建 `Style = Default`、`HoldDuration = 1` 的原生 `ProximityPrompt`，圆圈进度、松手取消和键盘／触摸／手柄输入由 Roblox 处理。

推荐在服务端业务对象中创建，parent 为已确认的场景 BasePart、Attachment，或设置了 PrimaryPart 的 Model：

```lua
local FX = _G.FX
self._interaction = FX.ProximityPromptObjectClass.New(parent)
self._interaction:SetHoldDuration(2)
local prompt = self._interaction:GetPrompt()
prompt.ActionText = "打开"
prompt.ObjectText = "宝箱"
prompt.MaxActivationDistance = 10
prompt.KeyboardKeyCode = Enum.KeyCode.E
--- 接收交互玩家，再由服务端业务检查宝箱状态与领取资格。
--- @param player Player 引擎提供的交互玩家。
self._interaction:SetHoldCompleteCallback(function(player)
    print(player.Name, "完成交互")
end)
```

`SetEnabled(false)` 关闭提示；`SetHoldCompleteCallback(nil)` 清除回调；`HoldDuration = 0` 为即时交互。
对象析构时调用 `self._interaction:Dtor()` 并清空引用，释放连接及自建提示，保留 parent。
其他原生属性和事件通过 `GetPrompt()` 访问，自行增加的事件连接由业务持有并清理。

共享类也能在客户端创建本地提示，但本地实例不复制到服务器，客户端回调只能用于本地表现。
服务端 `Triggered` 事件不证明玩家实际长按了指定秒数；发奖、扣费等仍需校验玩家资格、业务状态和重复操作。
这是依附场景物体的提示；固定在屏幕上的普通按钮继续使用 `FC.HoldUIObjectClass`。

原生接口依据：[Roblox ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)。
