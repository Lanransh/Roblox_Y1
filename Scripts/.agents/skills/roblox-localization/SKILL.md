---
name: roblox-localization
description: 为 Roblox_Y1 游戏动态文本接入翻译。先检查 Generated 的展示与翻译，仅在其未正确处理动态文本时由接入脚本补充；不修改 Generated，不为配置引用或静态节点补翻译定义。新增业务动态消息、参数模板、服务端提示或语言刷新时使用。
---

# 游戏动态文本本地化

先确定文案归属，再补必要的动态翻译。收集合同以 StudioGameToolkit 当前翻译文本
收集工具为准；运行时接口见[项目本地化](../../../Docs/本地化接入.md)。

## 五条处理规则

1. 不修改 `StarterPlayerScripts/Client/UI/Generated/` 下的 Lua/Luau。
   对有生成展示类的界面，先读取其 Render、赋值与翻译逻辑；已经正确处理的动态
   文本不重复翻译。仅在确认 Generated 未正确处理某项动态文本时，才在手写接入
   脚本中最小补充，并保留其正常展示、状态与生命周期。不能仅因文本会变化就补一层。
   无 Generated 对应的业务动态消息，由产生或显示它的脚本处理。
2. 每个使用动态文案的文件，在本文件顶层定义自己的 `local TranslationTexts`。
   只登记当前文件需要的动态文案，不创建全局或集中共享表，不导入、导出文案表。
   接收服务端传来的完整定义不需要再复制登记一份。
3. Key 在工具的收集范围内必须唯一。同文件、跨文件及与配置的 Key 碰撞都要解决，
   即使英文完全相同也不能重复声明同一个 Key。各文件使用可区分的模块前缀；
   同一文件重复使用同一句文案时引用已有表项，不再声明第二项。
4. 配置引用的翻译由工具生成和处理。不要为了读取名称、描述等配置字段，另外补
   Key/Source 定义、复制配置文案或增加翻译兼容层；不修改生成配置。
5. 静态节点的文本由工具收集，不在业务脚本为标题、按钮固定文字、说明等静态
   文案补翻译表或重复覆盖。静态文字即使由脚本赋值，也不因此成为本技能的处理目标。

## 定义合同

工具只静态解析声明，不通过 Text.Tr、Text.TrSource 或 Text.Mark 调用推断文案。
每文件最多一个顶层同名表，每项只允许非空字符串字面量 Key、Source：

```lua
local TranslationTexts = {
    ReceivedCoins = {
        Key = "RewardMessage.ReceivedCoins",
        Source = "You received {amount:int} Coins",
    },
}
```

- Source 使用完整英文或完整模板；字段名只是本文件的引用入口，不代替云端 Key。
- 允许注释、转义、长字符串和尾逗号；不使用拼接、插值、变量、函数或 require
  结果生成定义。不在函数、分支中声明，不重新赋值或动态补字段。
- 只定义动态业务原文，不把配置字段、玩家输入、业务 ID、节点路径或静态节点
  文本抄进表。全部表项都会被收集，未调用的项也会入表，不为“完整”预填无关文案。
- 保持原文、参数名、类型和必要标签一致。改 Key 或改 Source 可能影响已有译文，
  不按英文相同自动搬用历史译文；冲突先修正定义，不修改 CSV 绕过校验。

## 运行时接口

模块位于 `ReplicatedStorage/Scripts/Game/Shared/Text.luau`，框架初始化后加载：

```lua
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts/Game/Shared/Text")
```

- `Text.Tr(definition, arguments)`：只接受 Key/Source 定义，内部使用原生
  `Translator:FormatByKey`；查询失败按该定义 Source 做英文参数格式化，不按原文
  查其他语义 Key。不要向 Text.Tr 传字符串，也不恢复 Text.Mark 或全局 Key 映射。
- `Text.TrSource(source)`：独立的原文查询入口，不需要 Key，内部使用原生
  `Translator:Translate(game, source)`。未加载、缺译、报错或空译文时返回原文。
  它不登记原文、不补翻译定义、不格式化参数；参数模板或同文不同义使用 Text.Tr。
- 两个接口均只在客户端调用，复用入口创建的 `FC.Localization`。不另建翻译对象，
  不在共享模块顶层提前翻译并缓存玩家语言文本。

## 参数、服务端与语言刷新

- 服务端不翻译，只通过已有 `ShowLocalizedTips(definition, arguments, duration)`
  发送完整定义和独立参数；不只发字符串 Key，也不先拼接数量、名字再翻译。
  嵌套业务动态名称可传 itemDefinition；引用配置名称时只传 itemSource 原文，客户端
  用 Text.TrSource 查询并解析为 item，不为配置合成 Key/Source 定义。
- 数量缩写复用 GameUtility.NumberToText，使用 `{value}`；需要整数时使用
  `{count:int}`。显示字符串不参与计算、存档或发奖，不翻译玩家输入及内部查找标识。
- 仅在客户端运行时关闭自己负责翻译的具体动态节点的 AutoLocalize，避免二次翻译；
  不修改 Studio 模板、导入数据或整个父容器的本地化属性。
- 翻译调用是一次求值。通过现有 Changed 事件在翻译器加载或语言变化后重新求值，
  保留原文定义与参数；连接随组件清理，提示刷新不重置显示计时。

## 验证与交付

- 检查实际 Generated 接口，说明动态缺口和接入补充点；没有缺口就不增加翻译代码。
- 用翻译工具检查声明合法性、来源范围及 Key 唯一性；原文查询成功不代表原文已收集。
  可运行 `python -X utf8 Tools/check_translation_contract.py` 检查项目入口规则。
- 验证仅覆盖本次动态文本，包括英文回退、参数、语言刷新和重复翻译问题。
  遵循 AGENTS.md，区分语法、Script Sync 和实际运行结果，不因本技能自动启动试玩。
- 收集、译文生成和发布由工具流程处理，不手工改翻译文件、不通过 Roblox MCP
  维护翻译表、不自动上传云端。不修改静态节点、生成内容或配置来扩大本次范围。
