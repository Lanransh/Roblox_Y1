# 石头寻宝加载页视觉稿

仅供视觉审阅。未接入业务、未启动游戏、未导出到 Studio。

- UI：interfaces/RockTreasureLoadingConceptUI/RockTreasureLoadingConceptUI.json
- AI 背景：assets/LoadingConcept/ForestBackground-v1.png
- 审阅图：assets/LoadingConcept/ForestLoading-concept.png
- 视觉：清新森林浅绿底，金橙色水平标牌，草绿色进度，岩石与宝石点缀。
- 复用 styles/templates/Title 的 TitleImg 及 ProgressBar 的 ProgressBarImg 完整结构；改尺寸、标题橙色、进度绿色。
- 按用户要求例外采用全屏 AI 背景和示例进度 68 / 100；文字保持可编辑，当前是静态稿。
- 静态姿态横幅角度为 0；后续可做小幅左右摇晃，镐子敲击与宝石闪光。
- 本次无加载 View 业务逻辑，状态文字均为静态样例；实现时再改动态文本与本地化职责。
- 新背景只导入项目图片库，未上传 Roblox，云资源 ID 为空；正式导出前需要配置。
- 已检查 App 截图、保存重开、6 个文本属性及诊断（无错误）；未进行运行态、Studio、真机验收。

AI 背景由 StudioGameToolkit asset-workflow 生成（T011/C002），最终提示：将蓝色积木底全部替换为清新浅绿森林，两侧树木、中央大幅留白，底部低矮岩石草地、青色宝石与小宝箱，无文字、无 UI、无雪和冰。完整英文提示词保留在该工具任务历史中。

更新：进度前端已换为 AI 生成的统一卡通木柄铁镐与开裂矿石（T012/C001），素材 PickaxeCrackedOre-v2.png。保留用户手动缩小后的插画尺寸与位置。旧审阅图为历史版本，当前画面以 UIEditor 为准。新插画尚无 Roblox ID；本次只检查静态外观。

英文与本地化更新：静态标题 ROCK TREASURE、副标题 Break rocks. Discover treasure!、提示 Tip: Every rock could hide a surprise. 和审美稿标注采用英文源文案与 AutoLocalize=true。LoadingStatusTxt 和 ProgressTxt 保存为空且 AutoLocalize=false，状态由 View 中 RockTreasureLoading.Loading（Finding a path to treasure...）通过 Text.Tr 求值，数字不登记翻译。example 提供 68/100；View 消费 State.current/target，缺值或 target<=0 时清空数字并显示空条，不接真实加载。已保存重开、执行六节点文本验收、运行和重置断言及截图检查；未验证外部文案收集、译文发布、Roblox 真实语言切换。

导入记录（2026-11-18）：背景 rbxassetid://97051183682432；镐子矿石 rbxassetid://90659602935781。均已上传 ArtSource/Images/Loading，当前体验 10768714039 的 grant 返回 skipped=2/errors=[]。UI 导出 deliveryId=53c39323fde94b478917c17a31f2ab72，Studio 已核对 StarterGui.RockTreasureLoadingConceptUI 与正确图片引用；Generated 模块已创建，翻译代码位于 Studio 编辑器草稿（GetEditorSource 含 Text.Define/Text.Tr，Source 仍为空），须在 Studio 提交脚本草稿。未发布游戏，未启动游戏，未接入真实加载。
