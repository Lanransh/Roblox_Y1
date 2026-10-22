---
name: roblox-localization
description: Roblox 文案翻译接入：Text.Define 声明、脚本创建节点的文字、文件内去重及生成内容边界。
---

# 文案翻译

## 1. 哪些要加

- 业务动态文案、脚本自行创建节点的固定文字，都用 `Text.Define`。
- 例：奖励提示、代码创建按钮的 `"Close"`。
- 纯数字、玩家输入、内部 ID 不登记翻译，例如 `"123"` 不需要 `Text.Define`。
- UI 模块先看 Generated 的基类；已正确翻译的不重复补。编辑态静态文字交给节点收集；配置原文用 `Text.TrSource`，不另建定义。

## 2. 怎么定义

每文件最多一个顶层 `TranslationTexts`，没有新增文案就不建空表。仅用字面量；前缀和条目用 PascalCase。同文件 **Key、Source 都不能重复**，相同文案复用表项；**跨文件均可重复**。

Source 用完整英文，动态值通过参数传入，不拼接、不拆句翻译。

```lua
local FX = _G.FX
local Text = FX.Loader:RequireShared("Scripts.Game.Shared.Text")

local TranslationTexts = Text.Define("Activity", {
    RewardReceived = "You gained {value} Coins",
    Close = "Close",
})

-- 客户端创建文本节点：先关闭自动翻译，再写入译文
local button = Instance.new("TextButton")
button.AutoLocalize = false
button.Text = Text.Tr(TranslationTexts.Close)
```

例：同文件 `Close = "Close"`、`Dismiss = "Close"` 不允许；A.lua、B.lua 各自声明相同定义允许。

## 3. 哪些不能改

- 不改 Generated、生成配置、UI 模板或翻译产物；生成源有问题就报告，不绕过。
- 不擅自改旧 Key；改 Source 不改 Key。不建共享文案表，不自动上传。
- 导入 UI 沿用 AutoLocalize 配置，不补批量关闭代码。脚本自行创建且由代码翻译的具体文本节点，必须在写入译文前设置 `AutoLocalize = false`，避免重复翻译；不关闭父容器，不阻断后代自动翻译。

## 4. 怎么使用和检查

- 客户端 `Text.Tr(定义, 参数)`；服务端用 `ShowLocalizedTips` 传完整定义和参数，不先拼文案。语言变化后重新翻译。
- 天数、道具件数等整数数量直接用 `{days:int}`、`{count:int}`，传整数 number，不使用 `GameUtility.NumberToText`。
- 收益、货币、均分结果等允许小数，用 `GameUtility.NumberToText` 后传 `{value}`；例如 `2/3` 显示 `0.67`，不擅自取整。格式化只影响显示，不改计算值。
- 字符串用 `{name}`，禁用 `{name:string}`；数字格式说明符传 number，日期传 Unix 秒，倒计时在参数侧补零；参数名与模板一致。
- UI 接入后用 MCP 只读检查文本节点、隐藏原型及祖先/后代的 AutoLocalize，异常报告、不自动修节点。
- 定义变化时检查文件内 Key/Source 去重及参数。遵守 AGENTS.md，不自动试玩、不将保存当作同步或运行通过。
