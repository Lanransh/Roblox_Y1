---
name: roblox-localization
description: 按固定文字自动本地化、动态文字客户端 Text.Tr 的分工处理 Roblox_Y1 文案。新增或修改 UI 文本、AutoLocalize、服务端提示、Text.Mark 来源或语言刷新时使用。
---

# Roblox 项目本地化

英文是源文案和默认兜底。代码侧负责区分固定与动态文字、设置目标节点、
标记原文、传递参数和刷新显示；收集、云端上传、Studio ATC 采集及最终验收
是独立环节。本技能不通过 Roblox MCP 维护翻译表，不手工改翻译 CSV，
不自动上传云端或启动试玩。

本文路径以 `Scripts/` 为基准。流程说明见
[项目本地化](../../../Docs/本地化接入.md)。

## 先确定节点由谁翻译

### 固定文字：让引擎翻译

- UI 模板中有 `AutoLocalize` 属性的节点默认开启，包括父级容器；固定文字
  使用英文，确认节点及祖先都没有阻断自动本地化。
- 脚本给节点赋固定英文标题也可以走此方式。是否动态取决于文案是否需要
  参数替换、名称查询或组合，不取决于是否出现在脚本中。
- 固定文字不必套 `Text.Tr()` 或 `Text.Mark()`，实际展示后交给 ATC 收集。
- 只处理当前任务涉及的节点；修改模板或导入数据遵循项目 UI 接入规则，
  不直接编辑 Generated 脚本。

```lua
-- 固定英文标题：保持自动本地化，交给 ATC 采集。
title.AutoLocalize = true
title.Text = "Inventory"
```

### 动态文字：仅由客户端脚本运行时关闭，再翻译

- Studio 编辑态的节点、UI 模板及导入数据保持 `AutoLocalize = true`；
  不在属性面板或通过 MCP 将它们改成 false，也不把 false 保存进模板。
- 仅在客户端脚本运行时，创建、克隆或绑定实际显示节点后，执行
  `label.AutoLocalize = false`，再写入 `Text.Tr()` 结果，避免引擎二次翻译。
- 只关闭由代码负责翻译的具体节点，不关闭整个 ScreenGui 或父容器，
  不影响同界面的固定标题、按钮和其他文字。
- 新建、克隆或重新绑定节点时也要明确该设置；不能在动态节点已配置后，
  又批量把所有后代重置为 true。

```lua
-- 客户端脚本运行时执行；Studio 编辑态模板仍保持 AutoLocalize = true。
label.AutoLocalize = false
label.Text = Text.Tr("Strength: {value}", {
    value = GameUtility.NumberToText(strength),
})
```

## Text 接口与原文来源

模块位于 `ReplicatedStorage/Scripts/Game/Shared/Text.luau`。
框架初始化后的业务模块这样加载：

```lua
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
```

| 场景 | 接口 | 原文收集位置 |
| --- | --- | --- |
| 客户端直接写动态模板 | `Text.Tr("Strength: {value}", arguments)` | 调用中的完整模板 |
| 原文先存变量、从函数返回或由服务端发送 | 定义处 `Text.Mark("Not enough coins")`，客户端显示处 `Text.Tr(message, arguments)` | Mark 中的字面量 |
| 配置名称、描述 | 客户端 `Text.Tr(config.Name)` | 工具中指定的配置字段 |

- `Text.Mark(source)` 两端均可用，只返回原文，不翻译、不格式化、不注册条目。
- `Text.Tr(source, arguments)` 仅客户端可用，通过共享翻译对象读取云端译文并
  格式化，缺失时回退英文；复用入口创建的 `FC.Localization`，不另建 Translator。
  在对象初始化后、释放前调用，不在共享模块顶层提前翻译并缓存玩家语言文本。
- 英文原文自身作为翻译 Key，使用完整、自然的英文，不另造编号。
  `Text.Tr(variable)` 合法，但不能据此认为原文已收集；应有字面量标记或
  明确的配置字段来源，无法确认时报告缺口。
- 配置保持普通字符串，不给配置值套 Text 调用或改造生成格式。配置修改遵循
  `$game-config`，不手改生成脚本。

## 服务端只发送原文与参数

```lua
-- 服务端：标记完整模板，保持参数独立，不生成玩家语言文本。
local message = Text.Mark("You received {amount:int} Coins")
self:GetPlayerObject():ShowLocalizedTips(message, {amount = amount})
```

现有 `ShowLocalizedTips()` 接收端已经调用 `Text.Tr()`；提示文字节点由客户端
脚本运行时关闭自动本地化，不修改 Studio 编辑态模板。语言变化后用原文和
参数重算，不重置提示计时。
其他显示入口也必须在客户端完成翻译及节点设置。普通 `ShowTips()` 只展示
已准备好的文字，不会自动翻译。服务端不调用 `Text.Tr()`，不为翻译另建网络请求。

不先将数量或名字拼接进完整句子。数量缩写在客户端复用
`GameUtility.NumberToText` 并使用字符串参数 `{value}`；整数使用 `{count:int}`。
参数名、类型与格式标签保持一致。名称参数先在客户端 `Text.Tr(config.Name)`，
再传入整句；参数字符串不会自动递归翻译。计算、存档、发奖始终使用原始数据。

## 刷新和交付边界

- `Text.Tr()` 是一次求值，不自动绑定 UI。动态界面订阅共享翻译对象的
  `Changed`，在云端加载或语言变化后，用原文及参数重算，连接随组件清理。
- 玩家显示名与模型名、节点路径、物品 ID、存档标识分开，不翻译业务查找标识。
- 自维护的动态模板通过翻译工具收集并上传 Roblox 云端，供脚本读取；
  `AutoLocalize = false` 的动态节点不依赖 ATC 补模板或 Key。工具尚未实现，
  标记不等于已收集、上传或生成译文。
- 固定文字走 Studio ATC，需要开启采集并让相应界面实际出现；采集入云端
  不等于目标语言已有译文。TextBox 的 ATC 只采集 PlaceholderText，不采集
  玩家输入的 Text。上传、采集和验收交接给对应流程，不在编码中自动执行。
- 交付区分代码、云端上传、ATC 覆盖和最终验收状态。验收应覆盖英文兜底、
  目标语言、参数变化、语言切换、长译文布局及二次翻译问题。
  实际验证遵循 AGENTS.md，不因本技能启动试玩；语法、同步与运行分别报告。
