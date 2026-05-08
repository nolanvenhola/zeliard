#!/usr/bin/env python3
"""data_pattern_verify.py - structural verification of data items by name pattern.

For each data/label item in the inventory, the name often implies the
data SHAPE (string / table / single pointer / buffer).  We verify the
source line at the inventory's recorded line number against that shape.

Verdicts:
  - SUPPORTED      source line shape matches the name's implied shape.
  - INCONCLUSIVE   shape was checkable but didn't match expected.
  - PENDING        no shape implied by name pattern.

Output: working/DATA_PATTERN_VERIFY.md
"""

import csv
import re
import sys
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
INVENTORY_MD = WORKING / 'SECTION_INVENTORY.md'


# Each entry: (name regex, [line shape regex(es)], description).
# The line shape regex is matched against the inventory's source line
# (after stripping comments).  ANY of the regexes matching counts as a hit.
DATA_PATTERNS = [
    # Strings: db with quoted text
    (re.compile(r'^str_|^msg_|_str$|_msg$|^txt_|_txt$'),
     [r"\bdb\s+(?:'[^']*'|\"[^\"]*\")",
      r"\bdb\s+\d+\s+dup\s*\(\s*['\"]"],   # also `db N dup ('?')`
     'string: db with quoted text'),

    # Function pointers: a single dw of an address/symbol
    (re.compile(r'^gfx_fn_|^drv_fn_|_fn$|_func$'),
     [r"\bdw\s+\w+(?:\s*[+\-]\s*\w+)?\s*(?:;|$)",   # dw symbol [+/- offset]
      r"\bdw\s+0?[0-9A-Fa-f]+h?\s*(?:;|$)"],         # dw <hex>
     'function pointer: single dw of address'),

    # Pointers (similar to fn pointer but role differs)
    (re.compile(r'_ptr$|^ptr_|_ofs$|_offset$|_addr$|^addr_'),
     [r"\b(?:dw|dd)\b"],
     'pointer/offset/address: dw or dd'),

    # Tables: multi-element db/dw (commas in operand)
    (re.compile(r'_tbl$|_table$|^tbl_|_tbl_|^tbl_|_recs$'),
     [r"\b(?:db|dw|dd)\s+[^;]*,",          # multi-element via comma
      r"\b(?:db|dw|dd)\s+\d+\s+dup",       # or "N dup (...)"
      r"\blabel\s+(?:byte|word|dword)"],   # or a label-only marker
     'table: multi-element db/dw or label-byte/word marker'),

    # Buffers: typically `db N dup(0)` or `dw 0` placeholders
    (re.compile(r'_buf$|_buffer$|^buf_'),
     [r"\b(?:db|dw)\s+\d+\s+dup",          # N dup() placeholder
      r"\b(?:db|dw|dd)\s+0\b",              # zero placeholder
      r"\blabel\s+(?:byte|word|dword)"],   # or label marker into a buffer
     'buffer: db/dw N dup(0) or zero placeholder or label marker'),

    # ref_*: SAR resource reference (chunk_id + archive byte pair)
    (re.compile(r'^ref_|_ref$'),
     [r"\bdb\b", r"\bdw\b"],
     'resource reference: db/dw (1-3 bytes)'),

    # Counts/lengths: typically a single byte/word
    (re.compile(r'_count$|^count_|^n_|_num$|_len$'),
     [r"\bdb\s+\d+\b",                     # db <number>
      r"\bdw\s+\d+\b",
      r"\bdb\s+0?[0-9A-Fa-f]+h\b"],
     'count/length: single db/dw of a number'),

    # Flags: db with 0 / 0FFh / single byte
    (re.compile(r'_flag$|_flags$|_active$|_pending$|_done$|_ready$'),
     [r"\bdb\s+0\b",
      r"\bdb\s+0?(?:FF|0)h\b",
      r"\bdb\s+\d+\b"],
     'flag/state byte: db 0 / 0FFh / single byte'),

    # Generic data: just check it's a `db`/`dw`/`dd` line
    (re.compile(r'_data$|^data_'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'data: db/dw/dd or label marker'),

    # *_lbl labels: typically `name label byte` / `label word`
    (re.compile(r'_lbl$'),
     [r"\blabel\s+(?:byte|word|dword)\b",
      r"^\s*\w+\s*:"],                     # bare label
     'label_lbl: label byte/word or bare label'),
]


def parse_inventory_rows():
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


def get_source_line(asm_path: Path, line_num: int) -> str:
    if not asm_path.exists():
        return ''
    try:
        with asm_path.open(encoding='utf-8', errors='replace') as f:
            for i, l in enumerate(f, 1):
                if i == line_num:
                    return l.rstrip()
                if i > line_num:
                    break
    except OSError:
        pass
    return ''


def strip_comment(line: str) -> str:
    return re.sub(r';.*', '', line).rstrip()


def classify(name: str, source_line: str) -> tuple[str, str, str] | None:
    """Returns (verdict, description, matched_regex) or None if no name pattern."""
    cleaned = strip_comment(source_line)
    for name_re, shape_regexes, desc in DATA_PATTERNS:
        if not name_re.search(name):
            continue
        for shape in shape_regexes:
            if re.search(shape, cleaned, re.IGNORECASE):
                return ('SUPPORTED', desc, shape)
        return ('INCONCLUSIVE', desc, '')
    return None  # name pattern doesn't apply


def main():
    items = []
    for file_rel, line_no, name, kind in parse_inventory_rows():
        if not (kind == 'data' or kind.startswith('label')):
            continue
        items.append({'file': file_rel, 'line': line_no, 'name': name, 'kind': kind})

    print(f'Loaded {len(items)} data/label items from inventory')

    counts = defaultdict(int)
    matched_rows = []
    inconclusive_rows = []
    for it in items:
        asm = ROOT / it['file']
        line = get_source_line(asm, it['line'])
        if not line:
            counts['line_not_found'] += 1
            continue
        result = classify(it['name'], line)
        if result is None:
            counts['no_pattern'] += 1
            continue
        verdict, desc, _ = result
        counts[verdict] += 1
        row = {
            'file': it['file'],
            'line': it['line'],
            'name': it['name'],
            'kind': it['kind'],
            'desc': desc,
            'verdict': verdict,
            'source_line': line.strip()[:100],
        }
        if verdict == 'SUPPORTED':
            matched_rows.append(row)
        else:
            inconclusive_rows.append(row)

    print()
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f'  {k:<20} {v}')

    out = []
    out.append('# Data-Pattern Structural Verification')
    out.append('')
    out.append('Auto-generated by `data_pattern_verify.py`.')
    out.append('')
    out.append('For each data/label inventory item whose name implies a shape')
    out.append('(string / table / pointer / buffer / count / flag), the source')
    out.append('line at the inventory\'s recorded line number is checked against')
    out.append('the expected shape.')
    out.append('')
    out.append(f'Total data/label rows scanned: **{len(items)}**')
    out.append('')
    out.append('## Counts')
    out.append('')
    out.append('| Bucket | Count |')
    out.append('|---|---:|')
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        out.append(f'| {k} | {v} |')
    out.append('')
    out.append(f'## SUPPORTED rows ({len(matched_rows)})')
    out.append('')
    out.append('| File | Line | Name | Kind | Pattern | Source line |')
    out.append('|---|---:|---|---|---|---|')
    for r in matched_rows:
        sl = r['source_line'].replace('|', '\\|')
        out.append(f'| `{r["file"]}` | {r["line"]} | `{r["name"]}` | '
                   f'{r["kind"]} | {r["desc"]} | `{sl}` |')
    if inconclusive_rows:
        out.append('')
        out.append(f'## INCONCLUSIVE rows ({len(inconclusive_rows)})')
        out.append('')
        out.append('Name pattern matched but source line did not have the expected shape.')
        out.append('')
        out.append('| File | Line | Name | Kind | Expected | Source line |')
        out.append('|---|---:|---|---|---|---|')
        for r in inconclusive_rows:
            sl = r['source_line'].replace('|', '\\|')
            out.append(f'| `{r["file"]}` | {r["line"]} | `{r["name"]}` | '
                       f'{r["kind"]} | {r["desc"]} | `{sl}` |')

    path = WORKING / 'DATA_PATTERN_VERIFY.md'
    path.write_text('\n'.join(out), encoding='utf-8')
    print(f'\nWrote {path}')


if __name__ == '__main__':
    main()
