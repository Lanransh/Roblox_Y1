# LootSellUI 验证记录

日期：2026-10-09（Asia/Hong_Kong）。

## 实现范围

- 只出售回基地后存入正式背包的收藏品，不出售 `RockLoot` 临时战利品。
- 进入 `Workspace.Shop.Trigger` 自动打开 UIEditor 导出的界面，离开关闭；背包计数区不作为出售入口。游戏业务继承 `CLootSellView`，不修改生成文件。
- 普通收益为库存条目价格之和乘重生金币倍率；库存价格已包含幸运倍率，不重复相乘。
- 双倍出售暂时免费，将普通收益乘 2，不接 VIP、出售卡或购买。
- 正式库存保持服务端私有；客户端只收到可售条目的展示快照。
- 稳定实例 ID 保存在收藏品附加数据中，换格不改变 ID；服务器拒绝伪造、重复和过期目标。

## 本任务文件

- `ServerScriptService/Server/Player/SLootSellCompClass.lua`：正式库存快照及权威出售结算。
- `StarterPlayer/StarterPlayerScripts/Client/UI/CLootSellUICompClass.lua`：真实列表、图标、本地化、动作与 RPC 结果处理。
- `StarterPlayer/StarterPlayerScripts/Client/UI/CMainUICompClass.lua`：正式库存计数，移除错误的背包点击出售入口。
- `ReplicatedStorage/Scripts/Game/Configs/ItemConfig.lua`：声明收藏品 `SellId` 附加字段。
- `ReplicatedStorage/Scripts/Game/Shared/PlayerDataConfig.lua`：临时同步字段 `LootSellEntries`。
- `ReplicatedStorage/Scripts/Game/Shared/NetworkProtocol.lua`：出售 RPC 白名单。
- `ReplicatedStorage/Scripts/Game/Shared/Localization.csv`：出售英文文案、参数及兜底。
- `ServerScriptService/Server/Main.server.lua`、`ServerScriptService/Server/Player/SPlayerObjectClass.lua`、`ServerScriptService/Server/Player/SPlayerObjectManagerClass.lua`：服务端加载、挂载及协议转发。
- `StarterPlayer/StarterPlayerScripts/Client/Main.client.lua`、`StarterPlayer/StarterPlayerScripts/Client/Player/CPlayerObjectClass.lua`：客户端加载和挂载。
- `Docs/功能验收清单.md`：补充系统与数值范围，保持未勾选。

重新导入后上述实现和展示脚本仍在，本轮没有覆盖用户新导入的生成文件、UI 源文件或配置表。

## 构建及实际运行验证

使用本机已有 Rojo：

```powershell
& 'C:/Users/lanran/Desktop/Gamedev/StudioGameToolkit/ToolRuntime/rojo/rojo.exe' build 'Game/default.project.json' -o 'Game/Build/LootSellValidation.rbxlx'
git -c safe.directory=C:/Users/lanran/Desktop/Gamedev/Roblox_Y1 diff --check
```

两项通过；Git 仅提示 LF/CRLF 转换，无空白错误。

Roblox MCP 在“金钱”（placeId 107081730213446）进行测试。编辑态用 `ScriptEditorService:GetEditorSource` 确认同步缓冲区，不把尚未提交的 `Source` 当作最新源码。启动真实 Client/Server 后，以仅本次试玩存在的 Script/LocalScript 调用游戏组件与真实出售 RPC；使用 `StudioMemory = true`，停止试玩已清除测试脚本和内存档。下表是此前结算验证结果，出售区域入口的专项验证另列，不把旧入口的测试当作新入口已通过。

| 验证项 | 本次结果 |
| --- | --- |
| 新导入后的节点、展示类、业务类及启动接入 | 存在，加载成功 |
| 空背包 | 显示 `No items to sell.`，两个出售按钮禁用 |
| 真实图标与幸运价格 | 普通测试条目 10、幸运测试条目 25；重生 2 次倍率 5，预览 50 + 125 = 175 |
| 普通出售完整 RPC | 余额 100 → 275，库存 2 → 0，提示实际到账 175 |
| 免费双倍出售完整 RPC | 余额 100 → 450，库存 2 → 0，提示实际到账 350 |
| 请求期间重复触发动作 | 按钮禁用、重复动作被忽略，只结算一次 |
| 非法倍率、重复 ID、伪造 ID、稀疏数组、空数组、错误参数类型 | 请求失败，库存与金币不变 |
| 已售 ID 再次请求 | 失败，不重复到账 |
| 换格后的稳定 ID | 保持不变，原 ID 仍能定位实际库存 |
| 未入库战利品、已激活图鉴 | 出售不修改 |
| 原生 Tool 与容量 | 已售 Tool 清除，背包计数刷新为 0/12 |
| 满包 12 条 | 12 行、12/12、总价 225，滚动高度 1336，容量颜色 `ffd34f` |
| 失败结果的客户端处理 | 保留库存，恢复按钮，显示英文失败提示 |
| 关闭及隐藏期间库存同步 | 保持关闭，再打开显示最新库存并清除旧结果提示 |
| 本轮 Studio 控制台 | 仅正常启动与 Toolkit 暂停监听信息，无脚本错误 |

上次满包颜色断言因大小写比较失败，实际颜色正确；本轮按大小写归一后验证通过，没有因此修改游戏代码。

## 验证边界

- 后续按用户要求调整反馈：移除出售窗口底部状态文字，成功、失败及空背包点击改用通用浮层提示；空包按钮可点击，仅请求处理中禁用。通用提示保留在高层 ScreenGui，避免被出售窗口遮住。这些调整未重新试玩，上表此前的底部文案和空包禁用结果不代表当前交互验收。
- 按钮动作通过展示类 `EmitUIAction` 进入真实游戏业务与网络链路；没有模拟物理鼠标点击或验收所有设备的视觉布局。
- 没有测试云端持久化、重登恢复或 Roblox 云端多语言译文。新增动态 Key 仍需导入云端翻译表。
- 未下载独立 Luau 编译器；语法与运行依据为 Studio 实际加载及上述运行测试，不将 Rojo 构建单独当作语法验证。
- 测试记录不代替用户系统验收，验收清单未自动勾选。
