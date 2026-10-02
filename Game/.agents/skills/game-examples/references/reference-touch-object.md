# 鼠标与触摸

当前没有 FCTouchObjectClass。离散按钮点击用 GuiButton.Activated；
连续按压或拖动用 GuiObject.InputBegan 与 UserInputService.InputChanged/InputEnded。
不要使用旧 TouchBegin/TouchEnd/TouchMove 信号。

- 开始时只接收 MouseButton1 或 Touch，记录当前输入，避免多点触摸串线。
- 鼠标移动是 MouseMovement 输入对象，不能要求和起始 MouseButton1 对象相同。
- 触摸移动与结束应匹配当前 Touch 输入对象。
- 结束监听放 UserInputService，避免移出按钮后丢失松手。
- 组件 TrackConnection 持有连接；隐藏时结束交互，析构时 Disconnect。
- 只需要点击时不要引入每帧循环。
- 键盘快捷操作使用现有 FC.KeyObjectClass 或 ContextActionService；
  触摸按钮与键盘长按的具体接法见长按参考。
