# 路径与生命周期

- game:GetService 获取服务；路径逐级访问，名字和类型先确认。
- 客户端不能访问 ServerStorage 或 ServerScriptService 内容。
- StarterGui 是模板，实际玩家界面通常位于 Players.LocalPlayer.PlayerGui。
- 客户端必需的复制节点按到达时机 WaitForChild；不把磁盘上存在当作运行时已到达。
- 可选或动态节点 FindFirstChild；Character、Backpack、流式场景、重生 UI 等必须处理真实的创建和销毁。
- 固定、同步可用的内部节点不加重复判空；未确认节点明确说明证据缺失。
- 本地 Rojo 配置使用 $ignoreUnknownInstances；Studio 可保留磁盘外节点，但本地 build 不包含它们。修改 Studio 节点后需要显式导出回源文件。
- 文件夹与模型名不能跨层拼接；使用 GetChildren/GetDescendants，不使用 Children 属性。
- 需求与当前模型不一致时报告差异，按明确任务决定改模板还是访问代码。
