---
name: roblox-localization
description: 为 Roblox_Y1 游戏动态文本接入翻译，维护 Text.Define 声明、业务前缀与 Key 稳定性。新增或审查翻译定义、业务动态消息、参数模板、服务端提示或语言刷新时使用。先检查 Generated，不修改生成脚本，不为配置引用或静态节点补定义。
---

# 游戏动态文本本地化

先确定文案归属，再补必要的动态翻译。声明合同如下，StudioGameToolkit 收集工具
须配套支持；工具未适配时报告未完成收集验证，不回退到静默漏收。
本 skill 统一维护声明、命名、运行时接口、工具流程与验证规则。

## 五条处理规则

1. 不修改 `StarterPlayerScripts/Client/UI/Generated/` 下的 Lua/Luau。
   对有生成展示类的界面，先读取其 Render、赋值与翻译逻辑；已经正确处理的动态
   文本不重复翻译。仅在确认 Generated 未正确处理某项动态文本时，才在手写接入
   脚本中最小补充，并保留其正常展示、状态与生命周期。不能仅因文本会变化就补一层。
   无 Generated 对应的业务动态消息，由产生或显示它的脚本处理。
2. 需要新增业务动态原文的文件，在本文件顶层定义自己的 `local TranslationTexts`。
   只登记当前文件需要的动态文案，不创建全局或集中共享表，不导入、导出文案表。
   接收服务端传来的完整定义不需要再复制登记一份。
3. Key 在工具的收集范围内必须唯一。同文件、跨文件及与配置的 Key 碰撞都要解决，
   即使英文完全相同也不能重复声明同一个 Key。各文件使用简短、可区分的业务前缀；
   同一文件重复使用同语义的同一句文案时引用已有表项，不再声明第二项。
4. 配置引用的翻译由工具生成和处理。不要为了读取名称、描述等配置字段，另外补
   Key/Source 定义、复制配置文案或增加翻译兼容层；不修改生成配置。
5. 静态节点的文本由工具收集，不在业务脚本为标题、按钮固定文字、说明等静态
   文案补翻译表或重复覆盖。静态文字即使由脚本赋值，也不因此成为本技能的处理目标。

## 定义合同

工具只静态解析声明，不通过 Text.Tr、Text.TrSource 或 Text.Mark 调用推断文案。
每文件最多一个顶层同名声明，先加载 Text，再使用固定形式：

```lua
local TranslationTexts = Text.Define("Activity", {
    PassActivated = "Gained {value} Diamonds and activated a {days:int}-day weekly pass!",
    InventoryFull = "Your inventory is full",
})
```

- 前缀是简短、稳定的 PascalCase 业务名，如 Activity，不带 S/C、CompClass 等
  实现细节，不按文件名或路径推导。条目直接用 PascalCase 标识符，不含句点、
  不用字符串索引声明，不重复命名空间；写 PassActivated，不写 Welfare.PassActivated。
  前缀与条目名仅含英文字母和数字且大写字母开头。原文使用完整英文或模板，
  前缀与原文必须为非空字符串字面量。完整 Key 固定为 `prefix .. "." .. name`，
  上例分别为 `Activity.PassActivated`、`Activity.InventoryFull`。
- 允许注释、转义、长字符串和尾逗号；不使用拼接、插值、变量、其他函数或 require
  结果生成定义，不使用调用别名。不在函数、分支中声明，不重新赋值或动态补字段。
- 收集器只解析固定声明的字面量，不执行 Luau、不求值函数、不做宏展开。
  必须检查原始表内重复条目名及收集范围内重复完整 Key；遇到非法声明或冲突，
  报告文件和行号并使收集失败，不静默跳过。运行时表已覆盖的重复项无法补检。
- 本次需要新增定义的业务动态文案统一使用 Text.Define，不新增显式 Key/Source
  文案表或运行时旧 Key 别名；这不要求为静态节点或配置引用新增定义。
- 只定义动态业务原文，不把配置字段、玩家输入、业务 ID、节点路径或静态节点
  文本抄进表。全部表项都会被收集，未调用的项也会入表，不为“完整”预填无关文案。
- 保持原文、参数名、类型和必要标签一致，不修改 CSV 绕过声明校验。

## 前缀选择与 Key 稳定性

- 新增定义前，先在相关业务脚本中用限定路径和返回量的 `rg -n` 检索
  `Text.Define`、候选前缀及条目，确认文案归属和已有命名；完整 Key 唯一性仍由
  工具在全部收集范围校验，局部检索不能代替收集验证。
- 已有本文件声明时只补必要条目，不再建第二张表。同文件、同语义的相同原文复用
  已有项；同文不同义使用不同条目。接收服务端完整定义时不复制登记。
- 新文件选简短、稳定、可区分的业务前缀；与其他文件前缀重名时，为新前缀增加
  实际业务语义限定，例如 LootDisplay、LootSell，不拼文件路径、S/C 或 CompClass，
  不为给新声明让路而改名已有前缀。不批量重命名已有声明来统一风格。
- 前缀和条目名共同组成翻译身份。重构、移动或重命名文件、调整类名、缩短命名时
  默认保持已有 Key，不从文件路径重新生成。发现已有完整 Key 冲突时，先说明涉及的
  定义及迁移影响，不擅自选择保留方或改名已有 Key。
- 只有用户明确授权改 Key 时才迁移：逐项保持 Source、参数名、类型和必要标签不变，
  交付旧 Key → 新 Key 映射，由工具显式迁移译文，不按英文相同自动搬用历史译文。
  单独修改 Source 时保持 Key，并说明已有译文需要复核；需同时改 Key 和 Source 时，
  分别说明两种变更及验证范围，不能当成仅改名处理。

## 运行时接口

模块位于 `ReplicatedStorage/Scripts/Game/Shared/Text.luau`，框架初始化后加载：

```lua
local FX = _G.FX
local FXLoader = FX.Loader
local Text = FXLoader:RequireShared("Scripts.Game.Shared.Text")
```

- `Text.Define(prefix, sources)`：两端均可调用，仅展开为按原条目名索引的
  Key/Source 定义；返回表与定义只读，不翻译、不维护全局 Key 注册表。
  必须在顶层声明前加载 Text，使用处为 `TranslationTexts.Name`。
  既有业务 ID 与条目命名不同，可在所属脚本显式映射到定义，不更改业务 ID 或存档约定。
- `Text.Tr(definition, arguments)`：只接受 Key/Source 定义，内部使用原生
  `Translator:FormatByKey`；查询失败按该定义 Source 做英文参数格式化，不按原文
  查其他语义 Key。不要向 Text.Tr 传字符串，也不恢复 Text.Mark 或全局 Key 映射。
- `Text.TrSource(source)`：独立的原文查询入口，不需要 Key，内部使用原生
  `Translator:Translate(game, source)`。未加载、缺译、报错或空译文时返回原文。
  它不登记原文、不补翻译定义、不格式化参数；参数模板或同文不同义使用 Text.Tr。
- 两个翻译接口均只在客户端调用，复用入口创建的 `FC.Localization`。不另建翻译对象，
  不在共享模块顶层提前翻译并缓存玩家语言文本。

## 参数、服务端与语言刷新

- 服务端不翻译，只通过已有 `ShowLocalizedTips(definition, arguments, duration)`
  发送完整定义和独立参数；不只发字符串 Key，也不先拼接数量、名字再翻译。
  嵌套业务动态名称可传 itemDefinition；引用配置名称时只传 itemSource 原文，客户端
  用 Text.TrSource 查询并解析为 item，不为配置合成 Key/Source 定义。
- 数量缩写复用 GameUtility.NumberToText，使用 `{value}`；需要整数时使用
  `{count:int}`。显示字符串不参与计算、存档或发奖，不翻译玩家输入及内部查找标识。
- 字符串或已格式化的值使用 `{name}`，禁止使用 Roblox 不支持的 `{name:string}`；
  翻译占位符的格式说明符与 Luau 类型标注不同。未指定格式的占位符可与数字
  说明符组合，例如 `{name}: {count:int}`。
- 合法格式说明符为 `int / fixed / num / hex / HEX / datetime / iso8601 /
  shorttime / shortdatetime / shortdate / translate`。数字说明符传有限 number，
  不传数字字符串；日期传 Unix 秒，不传毫秒或已格式化日期。`:translate` 传 string，
  用于按参数原文查询译文，不代替普通字符串占位符；同条文案不混用 `:translate`
  与数字类说明符。
- 倒计时使用 `{minutes}:{seconds}` 或 `Next reward in {time}`，在参数侧用
  `string.format("%02d", ...)` 或 `string.format("%02d:%02d", ...)` 补零，
  不把格式化指令写进占位符。离线时长可用
  `You were away for {hours:int}h {minutes}m`，minutes 传补零后的字符串。
- UIEditor 导入的 UI 节点与 `UI/Generated/` 展示脚本已在制作阶段处理动态文本及
  AutoLocalize：纯数值、图标字符及代码已翻译的具体文本节点提前关闭，隐藏原型同样
  配置，克隆继承；依赖自动翻译的文案保持开启。接入默认沿用这些配置，不在 OnReady、
  Render 或每次刷新时重复关闭，也不新增批量关闭或遍历兜底代码。
  只关闭需要处理的那一个文本节点，不关闭图片父节点、按钮、容器或整组子树；
  图标字符指文本节点中的字符，ImageLabel/ImageButton 图片节点保持开启。
  祖先 AutoLocalize=false 会阻断后代，子节点 true 不能恢复；关闭前确认该文本节点
  没有依赖自动翻译的后代，有冲突则保持开启并反馈用户，由制作端处理层级。
- 仅对接入代码自行创建、没有生成原型可继承且由自身完成翻译的文本节点，在创建后、
  写入文本前关闭 AutoLocalize；不修改 Studio 模板、导入数据或整个父容器的本地化属性。
- 翻译调用是一次求值。通过现有 Changed 事件在翻译器加载或语言变化后重新求值，
  保留原文定义与参数；连接随组件清理，提示刷新不重置显示计时。

## 验证与交付

- 工具按“编辑态节点 → 脚本 TranslationTexts → 勾选 XLSX 字段”三路收集；
  配置保持普通字符串，配置文案使用 Key=Source，由工具生成和处理。
- 检查实际 Generated 接口，说明动态缺口和接入补充点；没有缺口就不增加翻译代码。
- 仅接入现有生成 UI 时，完成接入后通过 Roblox MCP 对本次 UI 批量只读核验即可：
  先确认目标 Studio 与 DataModel，按实际节点及脚本职责检查全部相关文本节点，包含
  隐藏 Templates 原型；核对纯数据、图标字符和代码已翻译文本的 AutoLocalize=false，
  依赖自动翻译的文案为 true，图片节点、父容器和 ScreenGui 保持开启；同时检查文本
  节点的祖先与后代，不能只看子节点 true 就判断自动翻译有效。使用当前 MCP 支持的
  批量查询方式，避免逐节点反复调用；不为此新增运行时检查或关闭逻辑。
  编辑态检查 StarterGui；已有客户端试玩时可同时核对 PlayerGui 中的克隆继承，
  不为这项属性检查自行启动试玩。发现异常时向用户报告节点完整路径、实际值和期望值，
  由 UIEditor 源界面修正后重新导出；不自动修改生成节点、Generated 脚本或在接入代码
  补关开关。MCP 不可用、节点缺失或查询截断时报告未验证范围，不把未查到当成通过。
  未新增翻译定义或修改文案时，不因单纯 UI 接入额外触发翻译收集、发布或语言试玩。
- 检查本次相关模板是否含 `:string`，同时核对参数类型、倒计时补零及参数变化后的
  显示。若问题来自 Generated，先排查接入脚本；必须修正生成源模板时，报告来源，
  由 UIEditor 工作区修正并重新导出，不直接修补 Generated，也不新增重复翻译绕过。
  修正 Source 保留原 Key，并通过工具流程复核已有译文中的同类格式；仅改英文回退
  不代表已有译文已修复。无法在当前工作区完成时明确报告待修复与待导出范围。
- 用已适配 Text.Define 的翻译工具检查声明合法性、来源范围及 Key 唯一性；
  原文查询成功不代表原文已收集。迁移需按显式映射比对完整 Key，确认 Source 与参数不变。
- 分别报告定义修改、工具收集、译文生成、云端发布及语言验收状态；工具产物生成
  不代表已上传，收集或发布成功也不代表已有目标语言译文。工具不可用或未适配时
  明确报告未完成收集验证，不以代码保存成功代替。
- 验证仅覆盖本次动态文本，核对参数生产与消费链路，包括英文回退、同英文不同 Key、
  参数、语言刷新、长译文布局和重复翻译问题。
  遵循 AGENTS.md，区分语法、Script Sync 和实际运行结果，不因本技能自动启动试玩。
- UIEditor 的英文 UTC 预览不代替 Roblox 玩家语言下的数字、日期、时间格式及语言
  刷新验收；App 验证通过不代表游戏同步、真实翻译或发布验证通过。
- 收集、译文生成和发布由工具流程处理，不手工改翻译文件、不通过 Roblox MCP
  维护翻译表、不自动上传云端。不修改静态节点、生成内容或配置来扩大本次范围。

## 既有接入点

以下仅用于定位数据链路，不代表已核对当前代码或 Studio 同步状态。

- 配置名称、任务描述及商店说明通过 Text.TrSource 查询。Tool 用 DisplayNameSource
  属性传递原文，掉落消息用 NameSource，嵌套提示参数用 itemSource。
- 引导配置携带 textId 等业务标识，显示端通过本地映射取得 TranslationTexts 定义；
  旧引导存档由数据迁移按当前步骤配置重建目标。
- 等级、数量、价格、容量等 UI 动态模板仍需逐项检查 Generated 的实际行为，
  不把既有接入描述或历史扫描报告当成当前翻译缺口、覆盖率或同步状态的证据。
