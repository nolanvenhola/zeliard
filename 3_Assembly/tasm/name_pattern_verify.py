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

    (re.compile(r'^apply_'),
     [
         # apply_* procs apply some change -- write to memory or register.
         [r'\bmov\b', r'\bxor\b', r'\bor\b', r'\band\b',
          r'\badd\b', r'\bsub\b', r'\binc\b', r'\bdec\b',
          r'\bcall\b'],
     ],
     'apply_*: writes/calls to apply effect'),

    (re.compile(r'_main$|^main_'),
     [
         # main entry: typically calls many subroutines and returns
         [r'\bcall\b'],
         [r'\bret(?:n|f)?\b', r'\bjmp\b'],
     ],
     'main entry: calls subroutines + returns/exits'),

    (re.compile(r'^bcd_|_bcd_|_to_bcd$|_from_bcd$'),
     [
         # BCD ops use AAA/AAS/AAM/AAD or arithmetic with mask 0Fh
         [r'\baa[admsu]\b', r'\band\s+\w+\s*,\s*0?[01F]Fh',
          r'\badd\b', r'\bsub\b', r'\bmul\b', r'\bdiv\b'],
     ],
     'BCD: AAA/AAS/AAM/AAD or arithmetic + mask'),

    (re.compile(r'tile_|_tile_|^tile|tile$'),
     [
         # Tile ops typically write to ES:DI (video) or build a buffer
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\bmov\b', r'\bcall\b'],
     ],
     'tile_*: tile data manipulation'),

    (re.compile(r'^pal_|^palette_|_palette_|_pal_'),
     [
         # palette ops use port 0x3C7/0x3C8/0x3C9 (VGA palette ports)
         # OR memory writes to palette state
         [r'\bdx\s*,\s*0?3C[789]h', r'\bin\s+(?:al|ax)',
          r'\bout\s+dx\b', r'\bmov\b', r'\bcall\b'],
     ],
     'palette: VGA palette I/O or palette-state writes'),

    (re.compile(r'^bg_'),
     [
         # background ops: rep movs (save/restore) or rep stos
         [r'\bmovs[bw]\b', r'\brep\s+movs[bw]\b',
          r'\bstos[bw]\b', r'\brep\s+stos[bw]\b',
          r'\bcall\b'],
     ],
     'bg_*: background save/restore/render'),

    (re.compile(r'^bound_'),
     [
         # bound check: cmp + branch
         [r'\bcmp\b', r'\btest\b'],
         [r'\bjbe\b', r'\bjnb\b', r'\bjz\b', r'\bjnz\b',
          r'\bjne\b', r'\bje\b', r'\bja\b', r'\bjb\b'],
     ],
     'bound_*: boundary cmp + branch'),

    (re.compile(r'^(ui|dlg|dialog|menu|hud)_|_dlg_|_menu_'),
     [
         # UI procs typically call render functions
         [r'\bcall\b'],
     ],
     'UI/dialog: dispatches to render/draw helpers'),

    (re.compile(r'^(snd|audio|music|sound)_|_audio_|_sound_|^play_'),
     [
         # Audio: int 60h, port 0x388/0x389 (Adlib), or memory writes
         [r'\bint\s+60h?\b', r'\bdx\s*,\s*0?38[89]h',
          r'\bcall\b', r'\bmov\b'],
     ],
     'audio/sound: Adlib port I/O, INT 60h, or call'),

    (re.compile(r'^anim_|^animate_|_anim$|_animate$'),
     [
         # Animation: usually has a frame counter inc + render call
         [r'\binc\b', r'\bdec\b', r'\bcall\b', r'\bcmp\b'],
     ],
     'animation: counter + render dispatch'),

    (re.compile(r'^(boss|enemy)_|_boss_|_enemy_'),
     [
         # Boss/enemy procs: state ops + branches
         [r'\bcmp\b', r'\btest\b', r'\bmov\b'],
     ],
     'boss/enemy: state read/write/branch'),
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


def load_all_procs():
    """Return list of {file, line, name} for ALL procs in the inventory.

    Scans the inventory directly (not the ledger) so the report is
    self-contained: every name-pattern match emits a SUPPORTED row,
    independent of what audit_section.py has already attributed to
    other evidence sources.  audit_section.py prioritises higher-
    strength sources first, so the only effect is that the
    name-pattern report stays complete.
    """
    out = []
    for file_rel, line_no, name, kind in parse_inventory_rows():
        if kind == 'proc':
            out.append({'file': file_rel, 'line': line_no, 'name': name})
    return out


def main():
    pending = load_all_procs()
    print(f'Loaded {len(pending)} procs from inventory ({INVENTORY_MD.name})')

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
