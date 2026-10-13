# 界面接入

- 在 `StarterPlayerScripts/Client/UI/Generated/` 查找对应展示类，结合生成标记、ScreenGuiName 和实际节点确认界面来源。节点查询按 AGENTS.md。
- 有对应生成展示类时，业务子类必须继承该类，放在 Generated 之外，只挂载业务子类。无对应生成类的普通界面使用 FCUICompClass 或已有项目 UI 基类。
- 生成展示类、共享基类和导入元数据由 UIEditor 管理，不直接写入业务；布局与展示修改通过编辑器导出。预览数据、模拟动作和预览接入脚本不作为游戏业务。
- 核对展示类的配置、状态、Render 与 EmitUIAction 契约；真实数据和动作通过业务子类接入。复用已有按钮绑定，通过 OnUIAction 处理动作。生成脚本缺失或与节点不符时先解决对应关系。
- 检查父类 Ctor/OnReady/Dtor 的调用顺序并保留 Super；沿实际初始化链调用 BindUIData/Render，不假设它们自动执行。生成类由业务模块加载，业务模块在客户端玩家对象创建前 require。

# UI 生命周期

- 普通组件提供 GetCompName 和 _rootNode，或覆盖 GetRootNode；附加显隐行为使用 OnShow/OnHide，Show 不重复绑定事件。
- 数据订阅和组件清理遵循 [框架规则](../roblox-framework-dev/reference-rules.md)；网络回调用 UnRegServerMsgCallback 解除。
- 模板克隆与组件自建实例区分所有权。长生命周期界面使用 ResetOnSpawn=false，或明确处理重生后的重新绑定。
