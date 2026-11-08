# 脚本用法与记录格式

从 `Scripts/` 运行。路径示例指本工程；其他工程使用实际路径。记录放在输入旁或用户指定的可写工作目录，不写入 CSV 元数据或 `Docs/`。输入目录无写权限时按当前环境请求所需写权限，不复制旧 CSV 冒充正式结果。

```powershell
python -X utf8 .agents/skills/roblox-translate/scripts/translation_review.py init --csv ../GameKitWorkspace/Translation/translation-upload.csv --index ../GameKitWorkspace/Translation/translation-ai-context.json --review outputs/translations/translation-review.json
python -X utf8 .agents/skills/roblox-translate/scripts/translation_review.py batch --review outputs/translations/translation-review.json --start 1 --limit 10
python -X utf8 .agents/skills/roblox-translate/scripts/translation_review.py report --review outputs/translations/translation-review.json
python -X utf8 .agents/skills/roblox-translate/scripts/translation_review.py apply --review outputs/translations/translation-review.json
```

`init` 不覆盖已有记录。`batch` 的 row/start 为从 1 起的数据记录序号，不是物理行号（CSV 单元格可跨行）；按身份匹配，不以该序号匹配来源。`report` 不写文件；输出全表问题、缺译、覆盖缺口及候选与实际 CSV 的差异，较大时将 JSON 用 UTF-8 保存到工作目录再按需查询，不能截掉剩余问题便宣称完成。退出码：0 全部完成，2 尚未完成或有待确认，1 输入/校验/保存失败。`batch` 成功返回 0。

## 编辑审查 JSON

`baseline_b64` 是不可编辑的原始 CSV 快照；`baseline_sha256`、`applied_sha256`、`index_sha256`、路径、version、rows 的顺序/row/identity 和 sources.location 不手改。它们用于防止错行、元数据变化、来源或 CSV 在审查期间变化。`glossary` 是自由结构的统一术语记录，建议按概念记录用途依据及各语言词汇，分批续用。

逐条编辑以下字段；布尔值使用 JSON true/false：

```json
{
  "row": 1,
  "identity": ["key", "Shop.Price"],
  "sources": [{
    "location": "code:../Scripts/Shop.luau:8",
    "checked": true,
    "observed_source": "{price}",
    "evidence": "定义路径与行号；实际调用路径与行号；price 来自 FormatNumber，已包含币种。"
  }],
  "usage": "购买按钮的价格文本，price 已包含完整显示符号。",
  "evidence": "调用、参数赋值及显示条件的实际证据，不仅是索引摘要。",
  "playtest_required": false,
  "playtests": [],
  "languages": {
    "ja": {"value": "{price}", "reviewed": true, "evidence": "结合按钮与参数来源复核；本例价格组仅 Shop.Price，日语通读后确认纯参数保留，无额外词语或符号。", "pending": ""}
  }
}
```

示例只展示一个语言，实际必须保留初始化生成的全部语言。每个 source 均独立检查，`observed_source` 必须与 CSV 当前 Source 完全相同；不同则该来源不能 checked。相同也仅证明原文对应，仍须检查用途、调用、参数和显示条件后才设 `checked: true`。节点记录 MCP 模式/实例/属性及周围布局；配置记录 MCP 工作簿/页签/字段/记录和消费路径。多个来源都检查后才允许该条语义完成。

每个语言的 `value` 是最终目标单元格；`reviewed` 仅在来源与用途已核实、逐条语义审查及下述按语言集中复审完成、必要试玩疑点已解决后为 true。静态证据足够时不要求试玩。`evidence` 简述该语言保留或修改的实际依据、关联文案的复审范围及结论；正确旧译文也填写。待确认设 `pending` 为包含疑点、已知证据、缺少信息和阻断原因的具体说明，`reviewed: false`，value 保持基线值。

允许批量读写记录及引用共享证据，但结论须对应实际检查的来源和语言单元格。不得用按行号区间批量设 `reviewed: true` 代替逐语言判断、仅因原文相同自动 checked，或以通用“已核对”说明替代实际判断。纯参数等相同结论可以共享简短依据，无须为制造差异而改写说明。

## 按语言集中复审

逐条审查便于核对原意；集中复审用于发现同一语言在关联文案中的术语漂移、语法和表达问题。每个已有语言都按功能阅读关联按钮、状态、提示和引导，包含保留的旧译文；可分批处理，最终覆盖全表并检查跨批关联。复审范围用现有 `languages[locale].evidence` 记录条目身份或明确批次范围及功能，引用共享结论时保留可定位范围，不新增一套必填字段。

- **按钮**：使用目标语言常见的动作表达，与点击行为一致。
- **状态**：区分可领取、已领取、未解锁等状态，不把动作和结果混为一谈。
- **数量提示**：明确数量指次数、天数、物品还是奖励，检查条件和剩余量含义。
- **动态句子**：从调用和配置确定参数取值范围，代入会影响语法的代表值，如数量 1/多项、不同词尾或性别的物品名。检查助词、词尾、单复数、冠词和量词；无法覆盖变化时改为不依赖该变化的自然句式，不新增参数、改格式或改消费代码。静态代入可确认时无需启动游戏；取值范围不明则记录疑点。
- **术语**：在现有 `glossary` 中按概念、用途和语言记录首选表达及合理变体。发现漂移后检索整表相关概念，连同关联按钮、状态、提示和地区语言列复查；不同地区分别判断，不机械复制，不把不同概念强行统一。

集中复审发现问题时修正并重查受影响单元格；不能立即确认的撤销其完成标记、保留基线值并写具体 pending。来源不足时可以记录语言疑点，但不能据此应用修改或标为完成。脚本不检查集中复审是否实际发生，最终需另行报告各语言的覆盖和发现。

## 必要试玩与显示证据

先区分疑点范围：

- **共同场景疑点**：用途、参数含义或显示条件等尚未明确，须运行时解决且影响整条文案时，设行级 `playtest_required: true`，并在 `playtests` 维护所需核验目标。脚本会用该行结果约束全部语言；仍可静态调查的问题先继续静态工作。
- **单语言疑点**：仅某语言的语法、候选裁切或排版尚未确认时，只将该语言设为 `reviewed: false`、`value` 保持基线值，并在其 `pending` 写明阻断，在其 `evidence` 保留候选及核验过程。不要因此设置行级试玩标记或向行级 `playtests` 添加未完成目标；其他已确认语言可继续应用。若先前误记在行级，将该目标及历史移入对应语言证据，再按剩余共同场景目标确定行级标记，不能丢弃未解决问题。

启动前在对应范围的 `evidence` 中写明条目、疑点、静态证据不足之处、目标界面/状态、已定位的入口/触发方式和预期观察；入口无法定位时保留阻断，不先启动。共享一次操作的条目可以引用同一证据，但须分别说明解决了什么问题。

行级 `playtests` 保存每个共同核验目标的当前结论，不作为逐次尝试的追加日志：`{"state":"核验界面/状态及实际操作", "observed":true, "evidence":"语言、条目及译文版本；目标及祖先可见、状态成立的证据；实际文字、参数和显示结果；对应疑点的结论"}`。未观察到则 observed 为 false，写具体原因。同一目标重试成功时更新原记录为 true，并在 evidence 保留先前失败原因及本次成功证据，不另留一个已被成功重试取代的 false 记录。不同的必要界面/状态各保留一项，全部通过后该行才就绪；未解决前不将 playtest_required 改为 false 来绕过阻断。单语言核验以相同方式在该语言 evidence 更新结论并保留历史，解决疑点后才清除 pending、恢复候选值并完成该语言复审。

仅启动游戏、读取隐藏 PlayerGui 节点、查询坐标或调用打开方法而未确认显示结果，都不能记为观察成功。候选值、语言或核验条件变化时，先检查旧证据是否仍适用；不适用的证据不能用于完成标记。单语言候选变化只撤销受影响语言的 reviewed，更新其 pending/evidence；共同核验条件变化则更新对应行级目标为 observed: false，待重新观察后再恢复。保留旧版本与历史结论，不用旧候选的成功观察证明新候选已显示。

证据明确区分：

- **原界面或已有云端译文**：只能证明所见界面、状态和该版本译文，不能证明本地候选译文已显示。
- **候选文字尺寸测量**：记录候选、语言、字体、字号及可用空间等测量条件；只能说明尺寸估计，不能证明实际无裁切或遮挡。
- **候选译文实际显示**：记录候选值/版本、语言、界面/状态及可见结果，仅覆盖实际观察的范围。无可用的授权预览方式时报告未验证，不为取得显示证据自动上传云端或改 UI/翻译接入。

这些区别只描述证据范围，不要求每条文案、每种语言都试玩；静态证据能解决的问题可据此完成语言复审。仍需候选显示才能解决的疑点保持待确认。字段只记录已做工作，脚本无法替代理解或确认记录真实性。

## 候选校验与保存

- 标准 `csv.reader/writer` 处理 UTF-8（有/无 BOM）、引号、逗号、多行和 Unicode；保留未改记录的原始字节，改动记录保留其原行尾（CRLF/LF/CR/无末尾换行）。不按文本拆分 CSV 单元格。
- 从最初基线生成候选，仅允许已有 locale 列，保留 translator type 等全部元数据。候选重新解析后比较表头、行数、顺序和所有列值。行顺序与非译文值任何变化均失败。
- `apply` 要求每个修改单元格的身份唯一、全部来源匹配并有证据、用途明确、必要试玩记录和该语言语义审查完成。重复/缺失索引的其他未改条目仍可保留并报告。
- 对整表所有语言检查缺译、完整参数及次数、富文本，不跳过未改旧译文。缺译及身份/覆盖待确认允许保存部分有效结果，但完整状态为 false；任何模板/富文本错误或无证据修改均阻止替换，先根据 `report` 修复可确认项。无法修复时保留记录中的候选修改并明确未应用，不能称 CSV 已交付新译文。
- 保存时检查 CSV 仍是最近 init/apply 的内容，并在临时文件写好后再次比较输入，冲突就停止，不覆盖。候选通过校验后在同目录原子替换。CSV 保存后更新记录 checkpoint；若该步失败，错误明确指出 CSV 已保存，可检查后重试同一 apply 恢复 checkpoint，不能重新 init 丢掉基线。
- 若输入真的发生协作变化，先保留现有记录与原始基线，逐项协调差异，再针对新输入新建审查记录；只转移仍适用且已重新核对的证据，重新核对当前 Source 和新输入值。不手改哈希绕过冲突。

## 模板与富文本的机械边界

项目 `Text.Tr` → `Localization:Tr` 直接调用 Roblox `Translator:FormatByKey`，无自定义模板解析。支持命名和数字参数，完整保留大小写与 `int/fixed/num/HEX/hex/datetime/iso8601/shorttime/shortdatetime/shortdate/translate` 格式；使用 Counter 比较，不是参数名集合。纯参数条目必须原样相等。

官方 [动态文案](https://create.roblox.com/docs/production/localization/translate-dynamic-content) 和 [Translator](https://create.roblox.com/docs/reference/engine/classes/Translator) 未明确说明花括号字面转义；本工程未发现额外转义实现。脚本对残留花括号、双花括号、反斜杠花括号及未知格式报待确认，不把 Python/C# 转义约定当成 Roblox 已支持的规则。遇到此类条目，先通过已授权的最小 Studio 验证或可核验平台依据确认真实语法，再针对证据扩展解析与测试；禁止仅删掉警告。CSV 中 Lua 源码的转义已经是解码后的显示值，不再次 Lua-unescape。

富文本按 Roblox [支持标签](https://create.roblox.com/docs/ui/rich-text) 检查 XML 式嵌套、配对、重复属性、允许属性和常见属性值。支持 font、stroke、mark、b/i/u/s、uppercase/uc、smallcaps/sc、br 和 XML 注释；标签及属性值按出现次数保护，允许包裹位置移动，br 数量可随布局调整。`&lt;` 等实体由 XML 解析，不能把转义的文字当标签。未知/损坏语法报错，不悄悄删标签。

这些检查不能确认参数类型的运行值、字体可用性、换行/长度、标签包裹语义或语言质量；必须通过来源、实际 UI 与必要试玩复核。`report.complete` 也只能证明记录声明与机械条件齐全，不能代替 agent 逐项履行语义审查。

## 验证辅助脚本

```powershell
python -X utf8 -m unittest discover -s .agents/skills/roblox-translate/scripts -p 'test_*.py' -v
```

测试只操作临时样例，无 Roblox 运行、整表翻译或云端上传。
