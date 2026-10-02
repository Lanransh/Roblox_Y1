---
name: roblox-node-tree-reader
description: 在 Roblox/Rojo 项目中确认场景、存储和 UI 实例路径、层级与类型；编写节点访问或校验模型结构时使用，以项目映射、模型源文件和动态创建代码为依据。
---

# Roblox 节点树定位

先确认 `Game/default.project.json` 的服务映射，再定位目标服务目录和模型源文件。
当前项目没有独立 MapTree 导出，不能要求读取 .maptree，也不能根据 MiniStudio 类型推断路径。

按任务选择参考：
- 查哪个服务、哪种源文件：[reference-cheatsheet.md](reference-cheatsheet.md)。
- 编写访问路径与处理节点缺失：[reference-rules.md](reference-rules.md)。
- 汇报已确认和未确认结构：[reference-output-template.md](reference-output-template.md)。

读取顺序：对应模型源文件 -> 动态创建代码 -> 必要时生成 Rojo sourcemap 或经用户授权读取 Studio 实例树。
节点名、大小写、层级和 ClassName 以当前可验证来源为准；不要猜测。
二进制 .rbxm 在本地无法读取时，明确结构未确认，使用现有解析工具或已授权的 Studio 工具；不虚构节点。
