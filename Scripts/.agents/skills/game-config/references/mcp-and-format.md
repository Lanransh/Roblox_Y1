# MCP 调用与配置格式

用于配置操作、Meta 和导出协议。业务选表见同目录 `game-configs.md`，仅需要时加载。

## 1. 工具与版本流程

逻辑名为 `sgtk.config.*`；Codex 中通常显示为 `mcp__studio_game_toolkit__sgtk_config_*`。以当前连接暴露的 schema 为准，不猜未提供的工具或参数。
工具只访问当前工程配置目录直属 XLSX，忽略 `~$` 临时文件，不接受任意磁盘路径。先 list 核对工程和文件。

| 工具 | 参数 | 作用 |
| --- | --- | --- |
| `list` | `offset?`, `limit?` | 文件名、`sourceRevision`；按 `nextOffset` 翻页 |
| `check`（磁盘） | `filename`, `expectedSourceRevision?` | 只读诊断已保存文件，不创建草稿 |
| `open` | `filename`, `expectedSourceRevision?`, `includeApi?` | 打开/复用版本化内存草稿；首次用 book API 时加 `includeApi:true` 获取完整接口 |
| `execute_script` | `contextId`, `expectedDraftRevision`, `apiVersion:"1"`, `code` | 在草稿执行同步 JavaScript 函数体，顶层 `return` 返回查询结果 |
| `check`（草稿） | `contextId`, `expectedDraftRevision` | 只读检查精确版本；不能同时传 filename/sourceRevision |
| `close` | `contextId`, `expectedDraftRevision` | 完整检查，必要时 WPS 重算，备份后保存；成功才关闭；不会更新 Luau 导出文件 |
| `export` | `filename`, `expectedSavedRevision` | 导出精确的已保存版本；不隐式保存草稿，有脏草稿时拒绝 |

普通查询：list → 磁盘 check（诊断时）或 open → execute_script 读取。
编辑：list → open → 查询目标 → execute_script 修改 → 草稿 check → close → 按任务需要 export。

- `contextId`、`draftRevision` 和源版本均取真实返回值。每次执行后使用返回的新 `draftRevision`，不要自行加一；只有实际变更才递增。
- close 后使用返回的 `savedRevision` 作为 export 的 `expectedSavedRevision`。导出现有磁盘版本时先重新获取并核对该版本。
- `check` 不重算、不保存、不导出。无 errors 但仍有 `full_export`/公式 pending 不代表已完成；完整验证发生在 close/export。
- 根据 `isError`、顶层 error、`closed`、`saved` 和检查位置报告实际结果，不依赖某个可选字段一定存在；不同服务版本可能省略空数组、重复字段或 `readyToClose`。
- open/close/export 会检查 WPS 占用；不自动关闭用户文档、删除锁文件或终止 WPS。外部版本冲突保留草稿，不强制覆盖或自动合并。
- 执行异常回滚本次脚本；正常执行但检查失败保留草稿。草稿仅在内存中，不承诺重启恢复；当前无丢弃/强制保存接口。

## 2. book API 和查询示例

脚本是同步 JavaScript，不是 TypeScript/Node.js；无文件、网络、进程、import/require、异步能力。仅返回 JSON 可序列化数据，不返回 book/句柄本身。
分页通常默认 50、最多 200；优先返回目标字段或记录，避免整表输出。结构、键或类型改动后重新获取对象句柄。

```javascript
const rows = book.struct("GoodsData");
return {
  meta: rows.getMeta(),
  fields: rows.listFields(),
  records: rows.readRecords({ offset: 0, limit: 5 })
};
```

实际文件应先用 `book.listConfigs()` 找到子配置。`book.listSheets()` 可找未导出页签，`book.sheet(name).readRows({startRow:1,limit:5})` 可读取表头/说明。

| 对象 | 主要方法 |
| --- | --- |
| book | `listConfigs`, `config(key)`, `struct(key)`, `table(key)`, `listSheets`, `sheet(name)`, `addSheet`, `addConfig`, `removeConfig`, `check` |
| Config | `getMeta`, `setMeta(patch)`, `getSheet` |
| Struct | `listFields`, `field(name)`, `addField`, `removeField`, `readRecords`, `record(key)`, `addRecord`, `removeRecord` |
| Field | `getMeta`, `setMeta`, `setDescription` |
| Record | `read()`, `cell(fieldName)` |
| Table | `readEntries`, `entry(key)`, `addEntry`, `removeEntry` |
| Entry | `getMeta`, `setMeta`, `keyCell`, `valueCell` |
| Sheet | `getInfo`, `getUsedRange`, `getOccupiedRows`, `getOccupiedColumns`, `readRows`, `cell("A1")`, `insertRows`, `deleteRows`, `rename`, `remove` |
| Cell | `read`, `getValue`, `getFormula`, `getCachedResult`, `setValue`, `setFormula`, `clear` |

以实际 `includeApi:true` 返回的签名为准。CellValue 是 `string | number | boolean | null`；数组和 KV 在单元格中仍写协议字符串，不传 JS 数组/对象。

修改示例（仅在用户确实要求将对应价格改为 18 时）：

```javascript
const cell = book.struct("GoodsData").record(111).cell("Price");
const before = cell.read();
cell.setValue(18);
return { before, after: cell.read() };
```

`setValue` 不覆盖公式；改公式用 `setFormula("=...")`，清空用 `clear()`。公式缓存有 `fresh/pending/unavailable` 状态，不能把旧缓存当新计算结果。
含公式的候选由宿主在 close/export 中使用独立 WPS 实例重算；不以 AI 手算或静默删除公式替代。
公式/布局引用可能阻断物理移动、删除和页签重命名；不要为了完成修改而移除这些保护。

## 3. 工作簿布局与三种 Meta

### 子配置 ConfigMeta

首个物理页签是索引，名称常为 `Rule`，名称本身不决定索引身份。第 1 行标题，第 2 行起：

| 列 | API 字段 | 含义/允许值 |
| --- | --- | --- |
| A | `key` | 导出模块的一级子配置键，string 或 number |
| B | `keyType` | 一级子配置键类型，只支持 `string`、`number` |
| C | `format` | `struct` 或 `table` |
| D | `keyField` | struct 的记录主键字段名；table 按每行 MetaInfo 读键，此列不指定其键类型 |
| E | `sheet` | 数据页签名称，必须存在 |
| F | `description` | 配置说明，CellValue，不参与前五列导出协议 |

例如 `GoodsData | string | struct | DevGoodsId | GoodsData`。
**B 列不决定 struct 行主键的类型**；行主键按 D 指向的字段及该字段类型解析。
`setMeta(patch)` 只改给出的属性，不自动创建页签、切换数据布局或迁移数据。
新增页签不会自动被导出；需 `addConfig` 声明。`removeConfig` 保留物理页签；仍被引用的页签不可删除。

### Struct 字段 FieldMeta

第 1 行字段说明，第 2 行字段名，第 3 行字段类型，第 4 行起记录。
`getMeta()` 返回 `{name,type,description,column}`；column 是只读列号。
`setMeta` 可改 name/type/description；类型变化不自动转换旧值。
仅有说明、没有完整字段名和类型的备注列不作为导出字段。字段名、类型和标量字符串解析时去首尾空白。
主键必须非空且唯一，不能只清空主键来删除记录；用 `removeRecord(key)`。

### Table 条目 EntryMeta / MetaInfo

第 1 行标题；第 2 行起 A/B/C 为 `MetaInfo | Key | Value`，每行独立声明类型。
`MetaInfo` 是 `keyType,valueType`，如 `string,number`、`string,kv_string`。
API 返回 `{keyType,valueType}`，键类型只允许 string/number，值类型见下一节。
三列必须齐全；即使 valueType 带 `_option`，table 的空 Value 也会先被三列完整性检查拒绝。
允许页签其他列存备注，但不将其作为配置值导出。重复条目键报错。

## 4. 支持的字段类型和单元格写法

完整基础类型共 13 种，下面每一种都支持追加 `_option`；没有 `bool_array`、JSON、原生 Color3/Vector3 或任意 Luau 表类型。

| 类型 | Excel 单元格例子 | 导出值 |
| --- | --- | --- |
| `string` | `Hello` | 字符串，去首尾空白 |
| `bool` | Excel TRUE/FALSE 或文本 `true`/`false` | boolean；数值 0/1 不作为 bool |
| `number` | `12`、`1.5`、`1e6` | 有限数值，不接受 NaN/Infinity |
| `string_array` | `A,B,C` | 字符串数组，逗号分隔，不支持 CSV 引号转义 |
| `number_array` | `1,2.5,3` | 数值数组；单个数值也可用 |
| `vec2` | `1,2` 或 `{1,2}` | `{x=1,y=2}` 普通表 |
| `vec3` | `{1,2,3}` | `{x=1,y=2,z=3}` 普通表 |
| `vec4` | `{1,2,3,4}` | `{x=1,y=2,z=3,w=4}` 普通表 |
| `vec2_array` | `{1,35},{2,30}` | vec2 表数组，可有尾逗号 |
| `vec3_array` | `{1,2,3},{4,5,6}` | vec3 表数组 |
| `vec4_array` | `{1,2,3,4},{5,6,7,8}` | vec4 表数组 |
| `kv_string` | `Type=Item,ItemId=104,Count=1` | KV 表；值依次识别 bool、有限 number，否则为字符串 |
| `kv_string_array` | `{Type=Gem,Count=3},{Type=Item,Id=105,Count=1}` | KV 表数组；键和值是否被业务接受另查消费代码 |

KV 键使用英文字母/下划线开头的标识符；值不能包含逗号或空白，也不支持嵌套对象。不要使用 JSON 语法或加引号期待转义；引号可能被当作字符串本身。
`kv_string` 是历史类型名，内部值不局限于字符串。

optional 空单元格语义：

- `string_array_option`、`kv_string_array_option` → `{}`。
- 其余 `_option`（含 number_array、vec 数组）→ `nil`。
- 非空但格式错误依然报错；`_option` 不跳过类型检查。必填类型提供合法值，不利用旧解析器的空值偶然行为。

## 5. Luau 导出结构

所有分类的工作簿共用以下结构。以一个示例 GameConfig.xlsx 为例，首个索引页声明：

| 子配置键 | 键类型 | 格式 | 主键字段 | 数据页签 |
| --- | --- | --- | --- | --- |
| CommonConfig | string | table | Key | CommonConfig |
| LevelData | string | struct | Id | LevelData |

CommonConfig 页签（第 1 行标题，第 2 行起数据）：

| MetaInfo | Key | Value |
| --- | --- | --- |
| string,number | MaxPlayerCount | 8 |
| string,kv_string | OfflineReward | MaxSeconds=14400,Rate=0.25 |

LevelData 页签（前 3 行是说明、字段名、类型，第 4 行起数据）：

| A | B | C | D |
| --- | --- | --- | --- |
| 关卡 ID | 名称 | 血量 | 奖励 |
| Id | Name | HP | Rewards |
| number | string | number | kv_string_array |
| 1 | First Level | 100 | {Type=Coin,Count=10},{Type=Item,Id=101,Count=1} |

在 RobloxStudio 工程中输出 GameConfig.luau ModuleScript：

```lua
return {
    CommonConfig = {
        MaxPlayerCount = 8,
        OfflineReward = {
            MaxSeconds = 14400,
            Rate = 0.25
        }
    },
    LevelData = {
        [1] = {
            Id = 1,
            Name = [[First Level]],
            HP = 100,
            Rewards = {
                [1] = {
                    Type = [[Coin]],
                    Count = 10
                },
                [2] = {
                    Type = [[Item]],
                    Id = 101,
                    Count = 1
                },
            }
        }
    }
}
```

因此游戏代码取得模块后，可读取 `GameConfig.CommonConfig.MaxPlayerCount`、`GameConfig.LevelData[1].HP`、`GameConfig.LevelData[1].Rewards[2].Id`。
示例里的 Type=Coin/Item 是业务数据，导出器只转换表结构，不实现发奖。
struct 为 `模块[子配置键][记录主键].字段`，table 为 `模块[子配置键][条目键]`。记录键来自声明的主键字段，主键字段本身也保留在记录中；页签名可以与子配置键不同，导出使用子配置键。
数组使用从 1 开始的显式索引；向量是普通轴字段表；空值序列化为 nil（Luau 表中等价于该键不存在）。
字符串用 `[[...]]`，遇闭合冲突升级 `[=[...]=]` 等；保留字符串内容，不执行其中代码。
绝对值达到 `10^6` 的数值用科学计数法；非合法标识符/保留字的字符串键用中括号引号语法。

RobloxStudio 工程默认输出到 `../Scripts/ReplicatedStorage/Scripts/Game/Configs`；MiniStudio 默认输出到 `../Code/ServiceNodes/MainStorage/Scripts/Game/Configs`。相对路径按 MCP 当前工程工作区解析；实际目标以本地 `configExportDirectory` 设置及 export 返回路径为准，不传临时输出目录。
MiniStudio 输出同名 `.lua`，上述示例文件内容改为 `_G.GameConfig = {...}`，内部 table/struct 结构保持相同。RobloxStudio 使用 `return {...}`，游戏通过 require 取得模块；是否再赋给 `_G` 由加载代码决定。后缀和模块包装由工程类型决定，不由输出目录名称决定。
export 完成解析、检查、序列化后才替换目标；失败不应当作已更新。生成模块成功不证明 Script Sync、Studio require 或游戏行为已验证。
