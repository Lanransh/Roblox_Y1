# 界面接入

- `StarterPlayerScripts/Client/UI/Generated/` 中有界面对应脚本，就属于 UIEditor 生成的 UI，不要求额外生成标记。实际节点与托管范围按 [UI 归属与业务接入](../roblox-external-tools/references/ui-integration.md) 确认；节点查询按 [Studio 操作](../roblox-studio-operations/SKILL.md)。
- 有对应生成 View 时使用 [外部工具协作](../roblox-external-tools/SKILL.md) 的 UI 接入参考；契约、职责边界与回源改造流程只在该参考维护。
- 无对应生成类的普通界面使用 FCUICompClass 或已有项目 UI 基类。

# UI 生命周期

- 普通组件提供 GetCompName 和 _rootNode，或覆盖 GetRootNode；附加显隐行为使用 OnShow/OnHide，Show 不重复绑定事件。
- 数据订阅和组件清理遵循 [框架规则](../roblox-framework-dev/reference-rules.md)；网络回调用 UnRegServerMsgCallback 解除。
- 模板克隆与组件自建实例区分所有权。长生命周期界面使用 ResetOnSpawn=false，或明确处理重生后的重新绑定。

# 屏幕适配与验收

- 新增或修改 UI 时默认考虑电脑、手机横屏和手机竖屏；适配覆盖本次改动，不自动扩展为整个界面重做。
- 优先沿用所属界面的缩放、布局和文字适配方案。独立界面明确设计基准及缩放方式；尺寸、间距、文字和装饰协调变化，避免只调字号或只放大按钮，也不对已有 UIScale 重复乘倍率。
- 定位和尺寸依据实际视口及安全区，避让顶栏、刘海、触屏控制和物品栏；尺寸变化时重新适配。触屏按钮保留足够点击范围，同时限制其屏幕占比，不把桌面固定像素尺寸直接用于手机。
- 文字考虑较长译文和动态数值，放不下时按原方案缩小、换行或调整布局。不统一强制 TextScaled；已有整体缩放与溢出处理的界面继续沿用，采用 TextScaled 时明确字号上限。
- 验收覆盖电脑、手机横屏、手机竖屏、长译文及运行中尺寸变化，核对显示、点击与关闭恢复；只报告实际完成的检查，未验证的设备、语言或状态明确说明。试玩和脚本运行仍遵守项目已有授权要求，阅读本规则不视为授权。
- UIEditor 托管节点和 View 的适配在源 UI 中制作、保存和导出，业务子类不另写缩放或布局覆盖；具体边界沿用 UI 归属与业务接入规则。
