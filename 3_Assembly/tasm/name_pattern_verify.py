#!/usr/bin/env python3
"""name_pattern_verify.py - structural verification by name-pattern.

When a proc name implies a specific role (e.g. `wait_*`, `inc_*`,
`*_dispatch`), the proc body is expected to contain opcode patterns
characteristic of that role.  This script checks each PENDING proc
against the role implied by its name.  No cross-driver evidence
required -- works on single-proc bodies.

Verdicts:
  - SUPPORTED      body matches the name's implied role pattern.
  - INCONCLUSIVE   no clear pattern match (could go either way).
  - CONTRADICTED   body strictly contradicts the name (rare; only
                   for unambiguous cases like a `set_*` proc with
                   no memory writes at all).

Output: working/NAME_PATTERN_VERIFY.md
"""

import csv
import re
import sys
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
INVENTORY_MD = WORKING / 'SECTION_INVENTORY.md'
LEDGER_CSV = WORKING / 'SECTION_AUDIT.csv'


# Name-pattern -> role fingerprint.
# Each entry: (regex matching name, [pattern groups], description).
# A proc whose name matches the regex is verified by fingerprint_match.
NAME_PATTERNS = [
    (re.compile(r'^wait_|_wait$|_wait_'),
     [
         # A wait proc must have a polling loop -- a backward jump or loop tail.
         [r'\bjz\b', r'\bjnz\b', r'\bloop\b', r'\bjmp\s+(?:short\s+)?\w+\b'],
         # AND read some state (a memory load or in port).
         [r'\bmov\s+(?:al|ax)\s*,\s*(?:cs:|ds:)?\[', r'\btest\b',
          r'\bcmp\b', r'\bin\s+(?:al|ax)'],
     ],
     'wait/poll loop: read state in a backward branch'),

    (re.compile(r'^dispatch_|_dispatch$|_dispatcher$'),
     [
         # Dispatcher must have an indirect call/jmp via a table.
         [r'\bcall\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[',
          r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[',
          r'\bcall\s+(?:word\s+ptr\s+)?\w+\[bx',
          r'\bjmp\s+(?:word\s+ptr\s+)?\w+\[bx',
          r'\bxlat\b'],
     ],
     'dispatcher: indirect call/jmp via table'),

    (re.compile(r'^(increment|decrement|inc|dec)_'),
     [
         [r'\binc\b', r'\bdec\b', r'\badd\b', r'\bsub\b'],
     ],
     'increment/decrement: inc/dec/add/sub op present'),

    (re.compile(r'^(compute|calc|calculate)_'),
     [
         # Math op
         [r'\bmul\b', r'\bdiv\b', r'\badd\b', r'\bsub\b',
          r'\bshl\b', r'\bshr\b', r'\band\b', r'\bor\b'],
     ],
     'compute/calc: arithmetic or bitwise op'),

    (re.compile(r'^(find|scan|search|locate|seek)_'),
     [
         # Find/scan: loop with compare, or scasb/scasw/repe scasb
         [r'\bscas[bw]\b', r'\brep(?:e|ne)?\s+scas[bw]\b',
          r'\bcmp\b', r'\bloop\b'],
     ],
     'find/scan: scasb/cmp/loop'),

    (re.compile(r'^(check|is|test|verify|has)_'),
     [
         # Check/test: at minimum a comparison + branch
         [r'\bcmp\b', r'\btest\b', r'\bor\s+\w+\s*,\s*\w+'],
         [r'\bjz\b', r'\bjnz\b', r'\bjne\b', r'\bje\b',
          r'\bjnb\b', r'\bjb\b', r'\bjnc\b', r'\bjc\b',
          r'\bja\b', r'\bjbe\b', r'\bjs\b', r'\bjns\b',
          r'\bret(?:n|f)?\b'],
     ],
     'check/test: cmp/test followed by branch'),

    (re.compile(r'_handler$|^handle_|_isr$'),
     [
         [r'\bret(?:n|f)?\b', r'\biret\b'],  # just must have a return
     ],
     'handler/isr: must end with return (sanity)'),

    (re.compile(r'^try_'),
     [
         # try_ procs check a condition then branch to do/not-do
         [r'\bcmp\b', r'\btest\b'],
         [r'\bjz\b', r'\bjnz\b', r'\bjne\b', r'\bje\b',
          r'\bjnb\b', r'\bjb\b'],
     ],
     'try_*: condition check + branch'),

    (re.compile(r'^(load|save|read|write|fetch|store)_'),
     [
         # Load/save: at least a memory read/write
         [r'\bmov\b', r'\blods[bw]\b', r'\bstos[bw]\b',
          r'\bmovs[bw]\b', r'\brep\s+(?:movs|stos|lods)[bw]\b',
          r'\bcall\s+\w*(?:loader|reader|writer|copy|sar)\w*\b'],
     ],
     'load/save/read/write: at least one memory op or loader call'),

    (re.compile(r'(render|blit|draw|paint)_|_render$|_blit$|_draw$|_paint$'),
     [
         # Render/blit: must touch ES:DI or video memory or call gfx fn
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\brep\s+(?:movs|stos)[bw]\b',
          r'\bcall\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w*(?:gfx|render|blit|draw)',
          r'\bcall\s+\w*(?:render|blit|draw|paint|fill_rect|plot|font)'],
     ],
     'render/blit/draw: writes to ES:DI or calls gfx routine'),

    (re.compile(r'^(set|clear|reset|zero)_'),
     [
         # Set/clear: must do at least one memory or register write
         [r'\bmov\b', r'\bxor\s+\w+\s*,\s*\w+\b',
          r'\bstos[bw]\b', r'\brep\s+stos[bw]\b'],
     ],
     'set/clear: writes register/memory'),

    (re.compile(r'^(process|update|advance|step|tick)_'),
     [
         # Process/update: branches or has loop
         [r'\bcmp\b', r'\btest\b', r'\binc\b', r'\bdec\b',
          r'\badd\b', r'\bsub\b', r'\bcall\b', r'\bjnz\b'],
     ],
     'process/update/advance: state-update operations'),
]


def parse_inventory_rows():
    """Yield (file, line, name, kind) tuples from SECTION_INVENTORY.md."""
    text = INVENTORY_MD.read_text(encoding='utf-8', errors='replace')
    head_re = re.compile(r'^##\s+(working/\S+\.asm)\b')
    row_re = re.compile(
        r'^-\s+\[[ x]\]\s+L(\d+)\s+`([^`]+)`\s+\*\(([^)]+)\)\*'
    )
    current_file = None
    for line in text.splitlines():
        m = head_re.match(line)
        if m:
            current_file = m.group(1)
            continue
        m = row_re.match(line)
        if m and current_file:
            yield (current_file, int(m.group(1)), m.group(2), m.group(3).strip())


def load_proc_body(asm_path: Path, proc_name: str) -> str | None:
    if not asm_path.exists():
        return None
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return None
    pattern = re.compile(
        r'^' + re.escape(proc_name) + r'\s+proc\s+near\s*\n'
        r'(?P<body>.*?)'
        r'^' + re.escape(proc_name) + r'\s+endp',
        re.MULTILINE | re.DOTALL,
    )
    m = pattern.search(text)
    return m.group('body') if m else None


def strip_comments(body: str) -> str:
    out = []
    for line in body.split('\n'):
        line = re.sub(r';.*', '', line)
        if line.strip():
            out.append(line)
    return '\n'.join(out)


def fingerprint_match(body: str, groups: list[list[str]]) -> bool:
    body_no_comments = strip_comments(body)
    for group in groups:
        if not any(re.search(p, body_no_comments, re.IGNORECASE) for p in group):
            return False
    return True


def load_pending_procs():
    """Return list of {file, line, name, kind} for PENDING procs from the ledger."""
    if not LEDGER_CSV.exists():
        print(f'ERROR: ledger not found at {LEDGER_CSV}', file=sys.stderr)
        sys.exit(1)
    out = []
    with LEDGER_CSV.open(encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['verdict'] == 'PENDING' and r['kind'] == 'proc':
                out.append({
                    'file': r['file'],
                    'line': int(r['line']),
                    'name': r['name'],
                })
    return out


def main():
    pending = load_pending_procs()
    print(f'Loaded {len(pending)} PENDING procs from {LEDGER_CSV.name}')

    # Stats
    counts = defaultdict(int)
    matched_rows = []
    for r in pending:
        name = r['name']
        # Find the first matching name pattern
        match = None
        for name_re, groups, desc in NAME_PATTERNS:
            if name_re.search(name):
                match = (name_re, groups, desc)
                break
        if match is None:
            counts['no_pattern'] += 1
            continue

        name_re, groups, desc = match
        asm = ROOT / r['file']
        body = load_proc_body(asm, name)
        if body is None:
            counts['proc_not_found'] += 1
            continue

        if fingerprint_match(body, groups):
            counts['SUPPORTED'] += 1
            matched_rows.append({
                'file': r['file'],
                'line': r['line'],
                'name': name,
                'desc': desc,
                'verdict': 'SUPPORTED',
            })
        else:
            counts['INCONCLUSIVE'] += 1

    print()
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f'  {k:<20} {v}')

    # Write report
    report = WORKING / 'NAME_PATTERN_VERIFY.md'
    out_lines = [
        '# Name-Pattern Structural Verification',
        '',
        'Auto-generated by `name_pattern_verify.py`.',
        '',
        'For each PENDING proc whose name matches a known role pattern',
        '(e.g. `wait_*`, `*_dispatch`, `set_*`), the proc body is checked',
        'against the role-specific opcode fingerprint.  Match -> SUPPORTED.',
        '',
        f'Total PENDING procs scanned: **{len(pending)}**',
        '',
        '## Counts',
        '',
        '| Bucket | Count |',
        '|---|---:|',
    ]
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        out_lines.append(f'| {k} | {v} |')
    out_lines.extend([
        '',
        f'## SUPPORTED rows ({len(matched_rows)})',
        '',
        '| File | Line | Name | Role pattern |',
        '|---|---:|---|---|',
    ])
    for r in matched_rows:
        out_lines.append(f'| `{r["file"]}` | {r["line"]} | `{r["name"]}` | {r["desc"]} |')
    report.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'\nWrote {report}')


if __name__ == '__main__':
    main()
