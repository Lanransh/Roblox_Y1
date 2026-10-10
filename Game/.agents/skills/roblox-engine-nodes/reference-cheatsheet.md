# 节点 API 速查

| 类型 | 接法 |
| --- | --- |
| Instance | ClassName、Name、Parent、IsA、GetChildren/GetDescendants、Clone/Destroy、GetAttribute/SetAttribute |
| BasePart | CFrame、Position、Orientation、Size、Color、Transparency、Anchored、CanCollide、CanTouch、CollisionGroup |
| Model | GetPivot/PivotTo；尺寸缩放按实际需求使用 ScaleTo，不给 Model 写 Position |
| 玩家角色 | Player.Character 是 Model，运动参数在 Humanoid，例如 WalkSpeed |
| 接触区 | BasePart.Touched/TouchEnded，回调参数为接触的 BasePart |
| 附着点 | Attachment 的 CFrame/Position 与 WorldCFrame/WorldPosition 区分局部和世界 |
| 三维 UI | BillboardGui 或 SurfaceGui，属性按对应类确认 |

没有通用 Visible/Enabled/LocalPosition/LocalScale 属性。BasePart 的可见性用 Transparency，
GuiObject 才有 Visible；不要把各类属性混用。
Clone 需 Archivable；设置名称、属性和变换后再 Parent 到目标容器，避免复制半初始化实例。

依据：[Instance](https://create.roblox.com/docs/reference/engine/classes/Instance)、
[BasePart](https://create.roblox.com/docs/reference/engine/classes/BasePart)、
[PVInstance](https://create.roblox.com/docs/reference/engine/classes/PVInstance)。
