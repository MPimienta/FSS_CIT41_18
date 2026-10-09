from pathlib import Path
import json,re,math,argparse
ROOT=Path(__file__).resolve().parent
LOG=ROOT/'Resultados'

def events(file):
    out=[]
    for line in file.read_text(encoding='utf-8',errors='replace').splitlines():
        m=re.search(r'FSS\|\s*([\d.]+)\|([^|\s]+)(.*)',line)
        if not m: continue
        e={'time':float(m[1]),'kind':m[2]}
        for k,v in re.findall(r'\|([^=|]+)=([^|]*)',m[3]):
            v=v.strip()
            try: v=float(v) if any(c in v for c in '.Ee') and v not in ['TRUE','FALSE'] else int(v)
            except ValueError: pass
            e[k]=v
        out.append(e)
    return out

def analyze(code,engine='host',file=None):
    file=Path(file) if file else LOG/f'{code}_{engine}.log'
    es=sorted(events(file),key=lambda e:e['time']); checks=[]
    def ck(label,ok,detail=''): checks.append(dict(check=label,passed=bool(ok),detail=detail))
    def of(kind): return [e for e in es if e['kind']==kind]
    ck('La aplicacion produce trazas',len(es)>100)
    ck('Sin excepciones Ada',not re.search(r'raised \w+|unhandled|TASK_FAULT|DIAG\|FAULT|PROGRAM_ERROR|CONSTRAINT_ERROR|STORAGE_ERROR|TASKING_ERROR', file.read_text(errors='replace'),re.I))
    window=70 if code=='P2-2' else 20
    summaries=of('TRACE_SUMMARY')
    ck('Ventana de captura completa',len(summaries)==1 and summaries[0].get('window')==window)
    ck('Sin perdida ni truncamiento de salida',len(summaries)==1 and
       all(summaries[0].get(k)==0 for k in ['lost','live_lost','clipped']) and not of('OUTPUT_LOSS'))
    ck('Salida visible sin atraso de un periodo de display',len(summaries)==1 and
       0<=summaries[0].get('max_live_output_age',1e6)<1.0)
    ck('Sin OVERRUN en la ventana observada',not of('OVERRUN'))
    sp=of('SPEED'); pi=of('PITCH'); ro=of('ROLL')
    ck('Velocidad de salida entre 300 y 1000',bool(sp) and all(300<=e['value']<=1000 for e in sp))
    ck('Pitch limitado a +/-30',bool(pi) and all(abs(e['value'])<=30 for e in pi))
    ck('Roll limitado a +/-45',bool(ro) and all(abs(e['value'])<=45 for e in ro))
    for task,period in [('POSITION',.2),('SPEED',.3)]+([] if code.startswith('P2') else [('COLLISION',.25),('DISPLAY',1)]):
        jobs=[e for e in of('JOB') if e['task']==task]
        # Nominal release sequence, independent of host execution jitter.
        ck(f'Releases absolutos {task}',len(jobs)>3 and all(abs((e['release']/period)-round(e['release']/period))<.002 for e in jobs))
        expected=math.ceil(window/period)
        releases=[e['release'] for e in jobs]
        ck(f'Sin activaciones perdidas {task}',len(jobs)==expected and
           all(abs(r-i*period)<.00001 for i,r in enumerate(releases)),
           f'{len(jobs)}/{expected}')
        done=[e for e in of('DONE') if e['task']==task]
        ck(f'Todas las activaciones completadas {task}',
           sorted(e['release'] for e in done)==sorted(releases))
        ck(f'Respuesta dentro del periodo {task}',bool(done) and
           all(0<=e['response']<=period for e in done),
           f'max_ms={max((e["response"] for e in done),default=0)*1000:.3f}')
    if code=='P2-1':
        vals={e['value'] for e in sp}; ck('Minimo maximo y velocidad intermedia', {300,600,1000}<=vals)
    if code=='P2-2':
        pos=of('POSITION_DATA')
        lows=[e for e in pos if e['alt']<=2000 and e['jx']<0]
        highs=[e for e in pos if e['alt']>=10000 and e['jx']>0]
        ck('Proteccion inferior observada',bool(lows) and all(e['pitch']==0 for e in lows))
        ck('Proteccion superior observada',bool(highs) and all(e['pitch']==0 for e in highs))
        ck('Recuperacion desde limite inferior',any(e['alt']<=2000 and e['pitch']>0 for e in pos))
        ck('Recuperacion desde limite superior',any(e['alt']>=10000 and e['pitch']<0 for e in pos))
    if code=='P2-3':
        pos=of('POSITION_DATA'); vals={e['value'] for e in sp}
        ck('Compensaciones 600 750 700 800', {600,750,700,800}<=vals)
        ck('Banda muerta inclusiva',any(e['jx']==3 and e['jy']==-3 and e['pitch']==0 and e['roll']==0 for e in pos))
        ck('Saturacion negativa',any(e['pitch']==-30 and e['roll']==-45 for e in pos))
    starts=of('EVADE_START'); ends=of('EVADE_END')
    if code.startswith('F-'):
        ck('Respuesta de evasion <= 80 ms',bool(starts) and all(0<=e['response']<=.080 for e in starts))
        cd=of('COLLISION_DATA'); ck('Aviso y maniobra presentes',bool(starts) and any(e['warning']=='TRUE' for e in cd))
        ck('Ausencia de obstaculo desactiva aviso',all(e['warning']=='FALSE' and e['evade']=='FALSE' for e in cd if e['distance']>5000))
        modes=of('MODE')
        for st in starts:
            finish=next((e for e in ends if e['id']==st['id'] and e['time']>=st['time']),None)
            cancellation=next((e for e in modes if e['automatic']=='FALSE' and e['time']>=st['time']),None)
            until=min(finish['time'] if finish else 1e6,cancellation['time'] if cancellation else 1e6)
            ck(f'Arbitraje durante maniobra {st["id"]}',not any(st['time']<e['time']<until for e in ro))
            if finish:
                ck(f'Maniobra {st["id"]} no termina antes de 3 s',finish['issued']-st['start']>=2.999)
        ck('Recuperacion de roll al finalizar',bool(ends))
        if code=='F-2':
            ck('Visibilidad reducida adelanta la maniobra',any(e['light']<500 and e['ttc']>5 and e['evade']=='TRUE' for e in cd))
            ck('Ausencia del piloto adelanta la maniobra',any(e['present']==0 and e['ttc']>5 and e['evade']=='TRUE' for e in cd))
        if code=='F-3':
            ck('Cuatro cambios y rebote descartado',[e['automatic'] for e in modes]==['FALSE','TRUE','FALSE','TRUE'])
            ck('Temporizador antiguo invalidado',bool(of('TIMER_CANCELLED')))
            manual=False; bad=[]
            for e in es:
                if e['kind']=='MODE': manual=e['automatic']=='FALSE'
                elif manual and e['kind'] in ['SPEED','PITCH','ROLL','EVADE_START','EVADE_END']: bad.append(e)
            ck('Sin escrituras de actuadores en manual',not bad,str(bad[:1]))
            for a,b in [(4.3,5.7),(9.3,11.7)]:
                ck(f'Sensores y display siguen activos {a}-{b}',all(any(a<e['time']<b for e in of(k)) for k in ['POSITION_DATA','SPEED_DATA','COLLISION_DATA','DISPLAY_DATA']))
    timing=dict(overruns=len(of('OVERRUN')),max_evasion_response_ms=round(max([e['response'] for e in starts],default=0)*1000,3),max_end_lateness_ms=round(max([e['lateness'] for e in ends],default=0)*1000,3))
    return dict(code=code,engine=engine,events=len(es),checks=checks,passed=sum(c['passed'] for c in checks),total=len(checks),timing=timing)

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--file',type=Path)
    parser.add_argument('--case',choices=['P2-1','P2-2','P2-3','F-1','F-2','F-3'],default='F-3')
    parser.add_argument('--engine',default='host')
    args=parser.parse_args()
    results=([analyze(args.case,args.engine,args.file)] if args.file else
             [analyze(code,args.engine) for code in ['P2-1','P2-2','P2-3','F-1','F-2','F-3']])
    destination=args.file.with_suffix('.analysis.json') if args.file else LOG/'results.json'
    destination.write_text(json.dumps(results,indent=2,ensure_ascii=False),encoding='utf-8')
    for r in results:
        print(r['code'],r['passed'],r['total'],r['timing'])
        for c in r['checks']:
            if not c['passed']: print('FAIL',c)
    if any(r['passed']!=r['total'] for r in results): raise SystemExit(1)
