import os, re, collections

callers = collections.defaultdict(set)
callees = collections.defaultdict(set)

for root, _, files in os.walk('.'):
    for f in files:
        if not f.endswith('.asm'): continue
        src = os.path.join(root, f).replace('\\', '/').lstrip('./')
        text = open(os.path.join(root, f), encoding='latin-1').read()
        for target in re.findall(r'\bcall\s+(\w+)', text):
            if not target.startswith('word') and not target.startswith('dword'):
                callers[target].add(src)
                callees[src].add(target)

print('=== TOP 25 MOST-CALLED FUNCTIONS ===')
for fn, c in sorted(callers.items(), key=lambda x: -len(x[1]))[:25]:
    print(f'  {len(c):3d} callers  {fn}')

print()
print('=== TOP 10 HUB MODULES (most unique targets called) ===')
for src, c in sorted(callees.items(), key=lambda x: -len(x[1]))[:10]:
    print(f'  {len(c):3d} unique targets  {src}')
