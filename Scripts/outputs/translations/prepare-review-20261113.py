import json,sys,copy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'outputs/translations'
sys.path.insert(0,str(ROOT/'.agents/skills/roblox-translate/scripts'))
import translation_review as tr
path=OUT/'translation-review-20261113.json'
state=json.loads(path.read_text(encoding='utf-8'))
table=tr.parse(__import__('base64').b64decode(state['baseline_b64']))
old=json.loads((OUT/'translation-review-20261110-refresh.json').read_text(encoding='utf-8'))
oldtable=tr.parse(__import__('base64').b64decode(old['baseline_b64']))
prior={tuple(x['identity']):(x,r) for x,r in zip(old['rows'],oldtable.rows)}
audit=json.loads((OUT/'source-audit-20261113.json').read_text(encoding='utf-8'))
assert all(a['matches'] for a in audit)
byloc={(a['row'],a['location']):a for a in audit}
decisions=json.loads((OUT/'translation-decisions-20261113.json').read_text(encoding='utf-8'))
hant=json.loads((OUT/'hant-decisions-20261113.json').read_text(encoding='utf-8'))
aliases={'es-es':'es','es-mx':'es','pt-br':'pt','pt-pt':'pt','fr-fr':'fr','fr-ca':'fr'}
usages={
16:'世界1和世界2的完成告示牌；两处相同原文，告诉玩家通关后进入下个世界。Studio Edit 两处 CompletionSurfaceGui.Message；TextScaled/TextWrapped 均为 true。',
42:'主界面 VIP 入口按钮；CVipPurchaseUICompClass.Open 仅未拥有 VIP 时打开专用介绍窗。',
83:'设置中视距行标题；CSettingsUICompClass:77、98 将 renderDistance 传给 CRockLevelComp.SetRenderDistance。205×56、字号24，采用清晰短译。',
84:'视距 Low 选项；Generated/CSettingsView:210 绑定 Low/Medium/High，不是音量或品质。',
85:'视距 Medium 选项；Generated/CSettingsView:210，游戏默认中档。',
86:'视距 High 选项；Generated/CSettingsView:210，游戏渲染距离高档。',
88:'光环商店隐藏行原型的已拥有状态，75×17、字号16；CAuraShopUICompClass 使用 owned 列表；不等同 Equipped。',
107:'VIP 专属介绍窗永久权益说明；PurchaseIntroUI.PopupPanelImg.PermanentTxt，380×28、字号18、可换行。',
108:'VIP 介绍窗的战利品出售收益标题；旁有固定双倍权益，与 BenefitDetailTxt 共同说明价值翻倍。',
109:'VIP 介绍窗权益详情；370×56、字号20、可换行。CVipPurchaseUICompClass 和 CPurchaseIntroView 契约限定永久 VIP。',
110:'VIP 介绍窗标题；StarterGui.PurchaseIntroUI.TitleBox.TitleTxt，保留 VIP 缩写。',
114:'武器商店隐藏行原型的已拥有状态，75×17、字号16；CWeaponShopUICompClass owned 状态；不等同 Equipped。',
117:'首周签到页副标题，奖励仅首次累计登录7日发放一次；SActivityCompClass:129 限制累计登录计数，CWelfareUICompClass:54 读取 LoginMilestoneData。303×32、字号22，短译保留一次性。',
118:'首周签到页页脚；前7个累计登录日，不是每周循环或连续7日。615×28、字号22；与117、126、129-132、384-385集中连读。',
126:'首周签到页签；WelfareUI.TabsBox.SignInTabBtn；首周奖励而非每日重置标签。',
129:'首周第7天奖励卡标签；SignInBoxTemplateImg.WeeklyTxt 隐藏原型。',
130:'首周第7天奖励卡标签；SignInBlueTemplateImg.WeeklyTxt 隐藏原型。',
131:'首周第7天奖励卡标签；SignInPurpleTemplateImg.WeeklyTxt 隐藏原型。',
132:'首周大型奖励卡的限时范围提示；SignInGrandTemplateImg.HintTxt。',
133:'开发者 GM 控件，切换主界面 GM 按钮外观，隐藏后原位置仍可点击；CGMIntegrationCompClass:70-71 → CMainUIComp.ToggleGMButtonVisuals；CGMPanelView:48、129。源文案仍为中文，未改源。',
215:'场景岩石区推荐等级标牌；CRockLevelCompClass:206-235 创建 RecommendedLevel，level 来自 RockLevel.GetRecommendedLevel(area.Index)，整数；TextScaled=true。',
273:'主界面优先级提醒：当前等级达到重生门槛且重生次数未满；CMainUICompClass:669-672、714-718。',
274:'主界面训练区升级提醒：已满足 NeedRebirhLevel 且存在 TrainingRate 更高的训练区；CMainUICompClass:674-679、714-718。',
275:'主界面镐子升级提醒：未拥有、金币足够、倍率高于已拥有最高倍率；CMainUICompClass:682-706，强调 better，不能沿用旧 new 译文。',
276:'主界面光环升级提醒：未拥有、金币足够、倍率高于已拥有最高倍率；CMainUICompClass:682-706，强调 better。',
277:'主界面世界2解锁限时提醒；Guide.world2ReminderUntil 与服务器时间比较，优先于重生及商店提醒；CMainUICompClass:663-666。',
299:'VIP 业务配置标题，CVipPurchaseUICompClass:11-15、34-38；当前专用 View 静态标题保存在节点，配置定义仍登记但不证明运行时消费。',
300:'VIP 业务配置名称：战利品出售收益2倍；CVipPurchaseUICompClass:11-15、34-38；当前 View 静态权益保存在节点。',
301:'VIP 业务配置权益类别标签；CVipPurchaseUICompClass:11-15、34-38；当前专用 View 使用静态节点。',
302:'VIP 业务配置权益描述；CVipPurchaseUICompClass:11-15、34-38；当前 View 使用静态节点，不把定义声明作实际显示证据。',
337:'VIP 购买按钮进行中状态；CPurchaseIntroView.Render:Purchased 优先，其次 pending；尚在等待平台/服务端，不表示已买到。',
338:'VIP 购买按钮已拥有状态；CPurchaseIntroView.Render 的 Purchased 分支，资格来自 Vip 服务端同步。',
339:'VIP 购买按钮无有效报价状态；CPurchaseIntroView.Render config.price==nil；不表述为售罄。',
384:'首周签到页动态标题；CWelfareView:224、844，day 来自 state.signInDay，1-7整数；按首周不是每日循环译。',
385:'首周第7天奖励动态标签；CWelfareView:225；CWelfareUICompClass:54-60 配置 featured=LoginDays==7 与 badge。'
}
groups=[(1,52,'场景标牌、主界面导航、倍率与价格'),(53,78,'福利页的签到、在线奖励、任务'),(79,114,'设置、商店拥有状态、VIP和出售权益'),(115,133,'首周签到和福利静态节点、GM按钮'),(134,199,'服务端购买、库存、奖励和权限提示'),(200,239,'拾取、好友、群组与新手引导'),(240,302,'排行榜、出售、主界面成长提醒和VIP'),(303,360,'福利反馈、商店、图鉴、重生与设置状态'),(361,403,'福利动态计数、倒计时、周卡和世界'),(404,424,'活动任务目标与奖励说明'),(425,572,'收藏品名称及同概念物品区别'),(573,612,'镐子与锤子商品系列'),(613,637,'光环商品名称'),(638,689,'商品礼包、钻石周卡、倍数和道具功能')]
def group(n):
    a,b,title=next(g for g in groups if g[0]<=n<=g[1]);return f'{a}-{b}：{title}'
for row,rec in zip(table.rows,state['rows']):
    n=rec['row']; previous,oldrow=prior.get(tuple(rec['identity']),(None,None))
    same=previous is not None and oldrow['Source']==row['Source']
    rec['usage']=usages.get(n,previous['usage'] if same else '')
    assert rec['usage'], (n,row['Source'])
    rec['evidence']=(previous['evidence']+'\n' if same else '')+'2026-11-13：见 source-audit-20261113.json 中本条全部来源；当前原文逐项精确一致。当前实例/尺寸通过 Studio Edit inspect_instance；配置由 GameKit MCP 读取当前工作簿、页签、字段、单元格；定义与实际调用已定位。'+rec['usage']
    rec['playtest_required']=previous['playtest_required'] if same else False
    rec['playtests']=copy.deepcopy(previous['playtests']) if same else []
    for s in rec['sources']:
        a=byloc[(n,s['location'])]
        s['checked']=True;s['observed_source']=a['observed_source'];s['evidence']=a['detail']+'; 用途/条件/参数：'+rec['usage']
    for locale,cell in rec['languages'].items():
        baseline=row[locale]; cell['value']=baseline;cell['pending']='';cell['reviewed']=False
        p=previous['languages'].get(locale) if same else None
        if p and p['value']==baseline and p['pending']:
            cell['pending']=p['pending']+' 2026-11-13：Edit模板已重新核对，未获得本地候选实际可见显示证据；继续保留本次基线。'
            cell['evidence']=p['evidence']+'\n本次按语言集中复审 '+group(n)+'；语义已通读，显示疑点未关闭。'
            continue
        if not baseline:
            vals=decisions['new'][row['Source']]
            if locale.startswith('en-'):
                cell['value']='Toggle GM button visibility (keep clickable)' if n==133 else row['Source']
            else:
                cell['value']=dict(zip(decisions['locales'],vals))[aliases.get(locale,locale)]
                if locale=='pt-pt': cell['value']=decisions['pt-pt'].get(row['Source'],cell['value'])
        if locale=='zh-hant' and row['Source'] in hant:
            cell['value']=hant[row['Source']]
        if locale=='ko' and row['Source']=='Picked up lucky {item} (×{rate})!':
            cell['value']='행운의 아이템 획득: {item} (×{rate})!'
        cell['reviewed']=True
        action='补译' if not baseline else '修正' if cell['value']!=baseline else '保留'
        cell['evidence']=(p['evidence']+'\n' if p and p['value']==baseline else '')+f'2026-11-13 {locale} {action}；精确身份及当前Source匹配；集中连读 {group(n)}，与相邻按钮/状态/同源功能核对。'
        if locale=='zh-hant':
            cell['evidence']+=' 繁體語義及術語獨立復審：鎬子/鏟子、簽到/已簽到、Robux/鑽石/金幣、掛機/離線、次數/天數區分；物品為名詞狀態而非開啟指令。'
        if n in usages:cell['evidence']+=' '+usages[n]
        if row['Source']=='Tablet':cell['evidence']+=' GameKit ItemData!F5=Y1_002_Pill 證明為藥片，不是平板電腦。'
        if '{' in row['Source']:cell['evidence']+=' 代入數量1/2/7（等級及計數含整數格式）、格式化value=1.2K、item為不同物品名檢查句式；純參數不加單位，模板完整保留。'
state['glossary']=copy.deepcopy(old['glossary'])
state['glossary']['2026-11-13集中复审']={
    'languages':table.languages,'ranges':groups,
    'zh-hant':{'Pickaxe':'鎬子','Shovel':'鏟子','Check In':'簽到','Checked In':'已簽到','Noob':'菜鳥','Tablet':'藥片','Double Sell Value Card':'雙倍出售卡','AFK':'掛機','offline':'離線','claims left':'剩餘可領取次數','currency':'Robux 保留專名與R$；遊戲金幣不譯美元；K/B/T保留顯示格式'},
    'regional':'es-es/es-mx 保留 guisantes/chícharos、gafas/lentes 地區用法；pt-pt 使用 treino、sessão、recolher、basebol 等現有詞；fr-fr/fr-ca 本批相同新句可自然通用；en-gb 保留 Armour 差異。',
    'scope':'689條、17語言全部通讀；既有16語言相同身份/Source/譯文且用途仍適用時沿用上次證據並本次集中復審。38個舊版顯示待確認仍保留。'}
path.write_text(json.dumps(state,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
report=tr.report_file(path)
(OUT/'translation-review-report-20261113.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if not isinstance(v,list)},ensure_ascii=False,indent=2))
print('blocked',report.get('blocked_changes'))
print('issues',report.get('issues'))
