# UI 生命周期

- 框架 UI 子类继承 FCUICompClass，提供 GetCompName 和 _rootNode，或覆盖 GetRootNode。
- 基类已有 Show/Hide：ScreenGui 用 Enabled，GuiObject 用 Visible；只需要附加刷新时覆盖 OnShow/OnHide。
- Ctor 调用 Super 后获取已核对的节点，绑定事件；Show 不重新 Connect 或注册协议。
- WatchDataChanged 回放当前值；不重复手动初始化同一文案。
- RBXScriptConnection 用 TrackConnection；网络回调用 UnRegServerMsgCallback 解除，不能当连接处理。
- 覆盖 Dtor 必须调用 Super；清理自建实例、任务、动画与交互对象，只清理自己拥有的对象。
- 使用 ResetOnSpawn=false 的长生命周期模板，或明确处理重生后重新绑定；不能持有已销毁的 PlayerGui 克隆。
- 关闭动画仅在需求已有时保留，播完才隐藏；处理再次 Show 时旧回调隐藏新界面的竞态。
- 普通列表删除行时保留 UIListLayout/UIPadding；不要 ClearAllChildren 清掉布局器和模板。
