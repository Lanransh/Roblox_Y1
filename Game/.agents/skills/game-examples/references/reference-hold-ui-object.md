# UI 与键盘长按

现有类：
- `StarterPlayer/StarterPlayerScripts/Client/Framework/FCHoldUIObjectClass.lua` -> FC.HoldUIObjectClass
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
