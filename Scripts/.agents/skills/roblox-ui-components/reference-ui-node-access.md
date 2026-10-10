# Roblox UI API

| 类/任务 | 实际属性或方法 |
| --- | --- |
| ScreenGui | Enabled、ResetOnSpawn、DisplayOrder；没有 Visible |
| GuiObject | Visible、Size/Position（UDim2）、AnchorPoint（Vector2）、Rotation |
| TextLabel/TextButton | Text、TextColor3、TextSize、TextTransparency |
| ImageLabel/ImageButton | Image、ImageColor3、ImageTransparency |
| GuiButton | Activated:Connect；需要连续按压使用 InputBegan/InputEnded |
| Frame | BackgroundColor3、BackgroundTransparency |
| ScrollingFrame | CanvasSize、AutomaticCanvasSize；用 UIListLayout/UIGridLayout 布局 |
| UIScale | Scale 为 number，用于 UI 整体缩放 |
| CanvasGroup | GroupTransparency，用于整组淡入淡出 |
| 子节点 | GetChildren、FindFirstChild、WaitForChild、Clone、Destroy |
| 事件清理 | 保存 RBXScriptConnection 后 Disconnect，不能 Click:Clear |

位置尺寸使用 UDim2；AnchorPoint 使用 Vector2；颜色使用 Color3。资源使用获授权的
rbxassetid:// URI 或已有源文件中的合法内容 URI，不使用 sandboxId://。

`UIList:SetVirtual/SetVirtualItemNum/NotifyItemRefresh` 不是 Roblox 原生 API；
少量数据使用模板克隆，量大时先确认需求，再做分页或虚拟化，不假设框架已有虚拟列表。
Lua 数组通常从 1 开始，不沿用原项目刷新事件的 0 基索引。

Activated 支持按钮多种输入；详细 API 查
[GuiButton](https://create.roblox.com/docs/reference/engine/classes/GuiButton)、
[GuiObject](https://create.roblox.com/docs/reference/engine/classes/GuiObject)。
