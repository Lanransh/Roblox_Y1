import csv,json,re,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'outputs/translations'
sys.path.insert(0,str(ROOT/'.agents/skills/roblox-translate/scripts'))
import translation_review as tr
REVIEW=OUT/'translation-review-20261113.json'
state=json.loads(REVIEW.read_text(encoding='utf-8'))
table=tr.parse(Path(state['csv']).read_bytes())
old=json.loads((OUT/'translation-review-20261110-refresh.json').read_text(encoding='utf-8'))
oldrows={tuple(x['identity']):x for x in old['rows']}
nodes={}
for p in OUT.glob('node-source-evidence-20261113-*.json'):
    for e in json.loads(p.read_text(encoding='utf-8')):
        if e['status']=='fulfilled':
            r=e['value']['result']
            if not r.get('isError'):
                nodes[e['value']['path']]=json.loads(r['content'][0]['text'])
configs={}
for p in OUT.glob('config-source-evidence-20261113-*.json'):
    result=json.loads(p.read_text(encoding='utf-8'))
    r=result.get('structuredContent') or json.loads(result['content'][0]['text'])
    if r.get('execution')=='completed' and not r.get('logsTruncated'):
        for x in json.loads(r['logs'][1]): configs[x['location']]=x
audit=[]
for row,record in zip(table.rows,state['rows']):
    prior=oldrows.get(tuple(record['identity']))
    for s in record['sources']:
        loc=s['location']; observed=None; detail=''
        if loc.startswith('node:'):
            path,prop=loc[5:].rsplit('.',1); n=nodes.get(path)
            if n and 'matches' not in n:
                observed=n['properties'].get(prop)
                detail='Studio Edit '+path+'; '+json.dumps({k:n['properties'].get(k) for k in [prop,'RichText','TextWrapped','TextScaled','TextSize','Size','Visible','AutoLocalize']},ensure_ascii=False)
            else: detail='实例缺失或路径多义：'+path
        elif loc.startswith('config:'):
            c=configs.get(loc)
            if c:
                observed=c['cell']['value'];detail='GameKit 配置 MCP 当前只读单元格 '+loc+'; 字段 '+str(c['header']['value'])
            else: detail='配置查询未返回单元格 '+loc
        else:
            path,line=loc[5:].rsplit(':',1); p=ROOT/path.replace('../Scripts/','');lines=p.read_text(encoding='utf-8-sig').splitlines();key=row['Key'].split('.')[-1]
            matches=[(i+1,t) for i,t in enumerate(lines) if re.match(r'\s*'+re.escape(key)+r'\s*=\s*"',t)]
            if len(matches)==1:
                num,t=matches[0];m=re.search(r'=\s*("(?:\\.|[^"\\])*")',t)
                if m:
                    try: observed=json.loads(m[1])
                    except ValueError: observed=None
                calls=[{'line':i+1,'text':t} for i,t in enumerate(lines) if ('TranslationTexts.'+key) in t]
                detail=str(p)+':'+str(num)+' definition '+t+'; calls '+json.dumps(calls,ensure_ascii=False)
            else: detail='定义匹配数 '+str(len(matches))+' '+str(p)
        audit.append({'row':record['row'],'identity':record['identity'],'source':row['Source'],'location':loc,'observed_source':observed,'matches':observed==row['Source'],'detail':detail})
(OUT/'source-audit-20261113.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
print('SOURCE MATCH',sum(x['matches'] for x in audit),'/',len(audit))
print('SOURCE MISMATCH',[(x['row'],x['source'],x['observed_source'],x['detail'][:120]) for x in audit if not x['matches']])
print('REPORT', {k:v for k,v in tr.report_file(REVIEW).items() if not isinstance(v,list)})
