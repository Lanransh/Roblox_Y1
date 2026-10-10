# UI 常用接法

```lua
self:TrackConnection(confirmButton.Activated:Connect(function()
    self:Hide()
end))

self:WatchDataChanged(fieldDefinition, function(value)
    amountLabel.Text = tostring(value)
end)
```

确认框可直接复用已挂载组件：

```lua
_G.FC.PlayerObject:RequireComponent("FCCommonUIComp"):ShowConfirm({
    Desc = "确认继续？",
    ConfirmBtnTxt = "继续",
    CancelBtnTxt = "取消",
    ConfirmCB = function()
        -- 本地交互；权威操作仍走业务服务端协议。
    end,
})
```

动画来自 `FC.UIAnim`：
`Open(node, duration, callback)`、`Close(node, callback, duration)`；
淡入淡出需 CanvasGroup，缩放通过 UIScale，进度修改填充节点 Size。
不要把 ImageLabel 的透明度属性当成整棵子树的透明度。
