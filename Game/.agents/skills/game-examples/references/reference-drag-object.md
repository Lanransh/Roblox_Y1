# UI 拖拽

当前没有 FCDragObjectClass；输入边界见 reference-touch-object.md。
需要拖拽时才实现原生输入逻辑，不自动为背包增加换格功能。

流程：
1. 核对源、目标、拖动层、AnchorPoint 与布局器，确定拖的是自由 GuiObject 还是布局列表中的替身。
2. InputBegan 记录指针起点和初始 UDim2.Position。
3. UserInputService.InputChanged 匹配鼠标移动或当前触摸输入，
   用指针位移更新 Offset，同时保留 Scale；考虑父级 UIScale 的坐标变换。
4. InputEnded 时结束当前输入，按需求用目标 AbsolutePosition/AbsoluteSize 命中检测，
   处理 GUI inset、重叠优先级与隐藏节点，恢复临时替身。
5. Hide/Dtor 清理拖动状态和持有的连接，避免隐藏界面继续移动。
6. 若拖拽意味着物品转移或交换，只发送请求；服务端校验格号、所有权与状态。
   当前没有公开背包换格协议，不能照搬旧 C2S 入口。

不要拖动由 UIListLayout 控制的位置后期待它保留；需要时用独立拖动层或改变布局顺序。
仅修改提示词时不新增输入框架或业务协议。
