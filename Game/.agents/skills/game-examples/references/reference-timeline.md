# 动画与 Timeline 迁移

当前没有 FXTimelinePlayer、FXTimelineTrackClass、FXTimelineClipClass；
不要 require 这些类或声称它们已经注册。

单段 UI 动画优先用 `FC.UIAnim`（FCUIAnim.lua）：
Open/Close、Move、FadeIn/FadeOut、Shake/Pulse、Progress。
缩放使用 UIScale，整组透明度使用 CanvasGroup，进度操作填充 GuiObject.Size。

场景动画可查看 `ReplicatedStorage/Framework/Shared/Object/FXModelAnimationCompClass.lua`，
根据实际方法签名使用。简单属性补间可用 TweenService；Model 的变换需 PivotTo，
不能直接 Tween 一个不存在的 Model.Position。

需要序列时，按用户明确的顺序串联完成回调或受控任务；只有复杂轨道、循环、跳转等需求
明确后才设计 Timeline，不为缺少原类而移植整套框架。
所属组件在隐藏/析构时取消自己持有的 Tween、连接与任务。
每次播放用当前有效对象，处理关闭后旧完成回调覆盖新状态的竞态。
