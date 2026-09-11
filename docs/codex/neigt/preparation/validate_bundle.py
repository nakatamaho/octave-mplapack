"""Check NEIGT manifests, installer safety and package invariants."""
from __future__ import annotations
import hashlib
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--bundle', type=Path, default=Path(__file__).resolve().parents[4])
parser.add_argument('--output', type=Path)
args = parser.parse_args()
root = args.bundle.expanduser().resolve()
cases = json.loads((root/'docs/codex/neigt/cases.json').read_text())
jobs = json.loads((root/'docs/codex/neigt/verification-jobs.json').read_text())
counts={}
for name, profile in cases['profiles'].items():
    n=len(profile['cases'])
    assert n==profile['expected_case_count']
    assert len({c['id'] for c in profile['cases']})==n
    rows=n*(len(profile['work_bits'])+1)*len(cases['standard_modes'])
    assert rows==profile['expected_measured_eig_rows']
    counts[name]={'cases':n,'measured_rows':rows}
    if name in jobs['profiles']:
        block=jobs['profiles'][name]
        assert len(block['jobs'])==block['expected_job_count']==26
        assert len({j['id'] for j in block['jobs']})==26
        present={c['id'] for c in profile['cases']}
        assert all(j.get('core_case') in present for j in block['jobs'] if 'core_case' in j)
        prefixes={'VS1':8,'VS2':4,'VS3':4,'VA1':3,'VA2':3,'VA3':4}
        for prefix, number in prefixes.items():
            assert {j['id'] for j in block['jobs'] if j['id'].startswith(prefix)}=={f'{prefix}-{i:02d}' for i in range(1,number+1)}
        counts[name]['verification_jobs']=26
text=(root/'docs/codex/neigt/MILESTONES.md').read_text()
assert all(text.count(f'## NEIGT{i:02d} ')==1 for i in range(26))
listed_paths = []
for line in (root/'SHA256SUMS-NEIGT').read_text().splitlines():
    checksum, relative = line.split('  ', 1)
    parts = Path(relative).parts
    assert not Path(relative).is_absolute() and '..' not in parts
    listed_paths.append(root/relative)
for path in (p for p in listed_paths if p.suffix == '.md'):
    assert path.read_text().count('```') % 2 == 0, path
for path in (p for p in listed_paths if p.suffix == '.py'):
    compile(path.read_text(), str(path), 'exec')
# Exact reduced-polynomial square-freeness in every enabled MKS dimension.
from fractions import Fraction as F

def trim(a):
    while len(a)>1 and a[-1]==0:a.pop()
    return a

def rem(a,b):
    a=a[:];b=trim(b[:])
    while len(a)>=len(b) and a!=[F(0)]:
        off=len(a)-len(b); fac=a[-1]/b[-1]
        for k in range(len(b)):a[k+off]-=fac*b[k]
        trim(a)
    return a

def gcd(a,b):
    while trim(b)!=[F(0)]:a,b=b,rem(a,b)
    return trim(a)

gcd_cases=[]
for n,m in [(6,3),(12,3),(32,3),(64,5)]:
    ell=(n-1)//m+1
    q=[F(-(n-m*j),8) for j in reversed(range(ell))]+[F(1)]
    dq=[F(k)*q[k] for k in range(1,len(q))]
    assert len(gcd(q,dq))==1
    gcd_cases.append({'n':n,'m':m,'degree':ell,'square_free':True})
# Installer checks after checksums have been generated.
installer=root/'install-neigt.py'
log=[]
with tempfile.TemporaryDirectory(prefix='neigt-installer-test-') as tmp:
    base=Path(tmp)
    repo=base/'repo'; repo.mkdir(); (repo/'.git').mkdir()
    def run(*extra,ok=True):
        proc=subprocess.run([sys.executable,str(installer),'--repo',str(repo),*extra],text=True,capture_output=True)
        assert (proc.returncode==0)==ok,(proc.returncode,proc.stderr)
        log.append({'arguments':list(extra),'returncode':proc.returncode})
    run()
    assert not (repo/'README-NEIGT.md').exists()
    run('--apply')
    for line in (root/'SHA256SUMS-NEIGT').read_text().splitlines():
        expected,name=line.split('  ',1)
        assert hashlib.sha256((repo/name).read_bytes()).hexdigest()==expected
    run('--apply')
    (repo/'README-NEIGT.md').write_text('Unrelated existing content.\n')
    # This new destination would have been copied before the conflict if preflight
    # were per-file instead of all-file; it must remain absent after rejection.
    (repo/'docs/codex/NEIGT-GOAL.md').unlink()
    run('--apply',ok=False)
    assert not (repo/'docs/codex/NEIGT-GOAL.md').exists()
    assert (repo/'README-NEIGT.md').read_text()=='Unrelated existing content.\n'
    # Independent symlink rejection.
    repo2=base/'symlink-repo';repo2.mkdir();(repo2/'.git').mkdir()
    outside=base/'outside';outside.mkdir();(repo2/'docs').symlink_to(outside,target_is_directory=True)
    proc=subprocess.run([sys.executable,str(installer),'--repo',str(repo2),'--apply'],capture_output=True,text=True)
    assert proc.returncode!=0
    assert list(outside.iterdir())==[]
    log.append({'case':'symlink_parent_rejection','returncode':proc.returncode})
result={'schema':'neigt-bundle-validation-v1','status':'PASS_BUNDLE_PREPARATION_ONLY',
        'counts':counts,'milestones':26,'reduced_polynomial_gcd_checks':gcd_cases,
        'installer_tests':log,'octave_executed':False,'mplapack_executed':False}
print(json.dumps(result,indent=2))
if args.output is not None:
    with args.output.open('x', encoding='utf-8') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
