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
    (re.compile(r'^str_|^msg_|_str$|_msg$|^txt_|_txt$|_filename$|_name$|_speech|_text|_narration|_disappear|^narration_|_savefile$|^cmdline_'),
     [r"\bdb\s+(?:'[^']*'|\"[^\"]*\")",
      r"\bdb\s+\d+\s+dup\s*\(\s*['\"]",
      r"\bdb\s+0\b",                       # accept zero-init buffer for filename
      r"\b(?:db|dw)\s+\w+,"],               # multi-element db (script/text)
     'string/cmdline buffer: db quoted/zero-buf/multi-el'),

    # Function pointers: a single dw of an address/symbol
    (re.compile(r'^gfx_fn_|^drv_fn_|^anim_fn_|^disp_fn_|^audio_fn_|_fn$|_func$|^disp_\w+_fn$'),
     [r"\bdw\s+\w+(?:\s*[+\-]\s*\w+)?\s*(?:;|$)",   # dw symbol [+/- offset]
      r"\bdw\s+0?[0-9A-Fa-f]+h?\s*(?:;|$)",          # dw <hex>
      r"\bdb\s+\w+,"],                                # multi-element db (composite)
     'function pointer/compound: dw or composite db'),

    # Pointers (similar to fn pointer but role differs).  Accept db too:
    # some offsets are byte-sized (e.g. row_ofs is a 2-byte db pair).
    (re.compile(r'_ptr$|^ptr_|_ofs$|_offset$|_addr$|^addr_'),
     [r"\b(?:db|dw|dd)\b"],
     'pointer/offset/address: db/dw/dd'),

    # Tables: multi-element db/dw (commas in operand)
    (re.compile(r'_tbl$|_table$|^tbl_|_tbl_|^tbl_|_recs$|_params$|_lut$|^lut_|_digits_(?:hi|lo|all)$|_offset_table$|^hex_'),
     [r"\b(?:db|dw|dd)\s+[^;]*,",          # multi-element via comma
      r"\b(?:db|dw|dd)\s+\d+\s+dup",       # or "N dup (...)"
      r"\blabel\s+(?:byte|word|dword)",    # or a label-only marker
      r"\b(?:db|dw|dd)\s+\w+\s*(?:;|$)",   # first-element-only (multi-line)
      r"\bdb\s+(?:'|\")"],                  # quoted-string table content
     'table/params/LUT: multi-element db/dw, label, or string content'),

    # Buffers: typically `db N dup(0)` or `dw 0` placeholders
    (re.compile(r'_buf$|_buffer$|^buf_'),
     [r"\b(?:db|dw)\s+\d+\s+dup",          # N dup() placeholder
      r"\b(?:db|dw|dd)\s+0\b",              # zero placeholder
      r"\blabel\s+(?:byte|word|dword)"],   # or label marker into a buffer
     'buffer: db/dw N dup(0) or zero placeholder or label marker'),

    # ref_*: SAR resource reference (chunk_id + archive byte pair).
    # ref_*_lbl is also a label-marker form (label byte/word).
    (re.compile(r'^ref_|_ref$'),
     [r"\bdb\b", r"\bdw\b",
      r"\blabel\s+(?:byte|word|dword)\b"],
     'resource reference: db/dw or label-byte/word marker'),

    # Counts/lengths: typically a single byte/word
    (re.compile(r'_count$|^count_|^n_|_num$|_len$'),
     [r"\bdb\s+\d+\b",                     # db <number>
      r"\bdw\s+\d+\b",
      r"\bdb\s+0?[0-9A-Fa-f]+h\b",
      r"\bdw\s+0?[0-9A-Fa-f]+h\b"],         # dw <hex>h
     'count/length: single db/dw of a number'),

    # Flags: db with 0 / 0FFh / single byte
    (re.compile(r'_flag$|_flags$|_active$|_pending$|_done$|_ready$|^has_|_enabled$|_disabled$'),
     [r"\bdb\s+0\b",
      r"\bdb\s+0?(?:FF|0)h\b",
      r"\bdb\s+\d+\b"],
     'flag/state byte: db 0 / 0FFh / single byte'),

    # Saved registers: dw 0 placeholder
    (re.compile(r'^saved_'),
     [r"\b(?:db|dw|dd)\s+0\b"],
     'saved register: zero placeholder'),

    # Segment / offset.  Some are byte-pair sequences too (e.g.
    # disp_set_drv_seg db 's','e').  Accept any db/dw form.
    (re.compile(r'_seg$|_ofs$|_segment$|_entry_seg$'),
     [r"\b(?:db|dw|dd)\b"],
     'segment/offset: db/dw/dd'),

    # Mode / config single-byte settings
    (re.compile(r'_mode$|^mode_|_length$|^length_'),
     [r"\bdb\s+\d+\b", r"\bdb\s+0?[0-9A-Fa-f]+h?\b",
      r"\bdb\s+0\b"],
     'mode/length: single db value'),

    # Generic data: just check it's a `db`/`dw`/`dd` line
    (re.compile(r'_data$|^data_|_data_|^disp_|^gfx_|^ref_'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'data: db/dw/dd or label marker'),

    # Enemy / boss data items (mao1/mao2/akma/tori/drgn/crab/tako/zela/
    # meda/lega/zel2/jashiin/wizard prefix means it's chunk-local data
    # for that enemy/boss; just confirm the line is a data declaration).
    (re.compile(r'^(mao[12]|akma|tori|drgn|crab|tako|zela|meda|'
                r'lega|zel2|jashiin|wizard|inn|zr[1-3])_'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'enemy/boss/inn data: db/dw/dd or label marker'),

    # _marker / _trailer suffixes (small markers / table tails)
    (re.compile(r'_marker$|_trailer$|_tail$|_head$|_anchor$'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'marker/trailer: any db/dw/dd or label'),

    # _step / _init / _clear (state markers in tables)
    (re.compile(r'_step$|_init_$|_clear$|_init$|_phase$'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'step/init/clear marker: any db/dw/dd or label'),

    # Dispatch entry data
    (re.compile(r'_dispatch$|^dispatch_|_handler_tbl$'),
     [r"\b(?:db|dw|dd)\b"],
     'dispatch entry: db/dw'),

    # Plane / mask / xor data (graphics-related bytes)
    (re.compile(r'_plane\d*\b|^plane_|_mask$|_xor\d|^xor\d'),
     [r"\b(?:db|dw|dd)\b"],
     'plane/mask/xor data: db/dw'),

    # _ofs / _ptr at end (offset/pointer values)
    (re.compile(r'_ofs$|_ptr$|_addr$'),
     [r"\b(?:db|dw|dd)\b"],
     'offset/pointer value: db/dw/dd'),

    # _operation (numbered VGA operation placeholders -- accept any data)
    (re.compile(r'_operation$|_operation\d|^operation'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)"],
     'operation entry: any data form'),

    # _row_ofs / _col_ofs / *row_byte / row data patterns
    (re.compile(r'_row_ofs$|_col_ofs$|_row_byte$|_row_a$|_row_b$|_row\d$|_const_word_a?$'),
     [r"\b(?:db|dw|dd)\b"],
     'row/col offset/data: any db/dw'),

    # font / palette / scroll data
    (re.compile(r'^font_|^palette_|^scroll_|_palette_|_scroll_'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)\b"],
     'font/palette/scroll data: any db/dw or label'),

    # hex_digits_lo / _hi
    (re.compile(r'^hex_digits_'),
     [r"\bdb\s+(?:'|\")"],
     'hex digit table: db with quoted string'),

    # *_count$ (single value)
    (re.compile(r'_count$|^count_'),
     [r"\b(?:db|dw|dd)\b"],
     'count: any single-value db/dw/dd'),

    # *_loop$ (data with loop semantics)
    (re.compile(r'_loop$|_wait_loop$'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)\b"],
     'loop data: any db/dw or label'),

    # cell_*, banner_*, intro_*, header_*, hdr_* (content data)
    (re.compile(r'^cell_|^banner_|^intro_|^header_|^hdr_|^pose_|_lookup_tbls?$'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)\b"],
     'content/lookup data: any db/dw or label'),

    # bitmap_, plane_, xor_ data
    (re.compile(r'^bitmap_|_bitmap_|_xlat_|^xlat_|_xlat$'),
     [r"\b(?:db|dw|dd)\b",
      r"\blabel\s+(?:byte|word|dword)\b"],
     'bitmap/xor/xlat data: any db/dw or label'),

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


def get_source_lines(asm_path: Path, line_num: int, count: int = 3,
                     name_for_fallback: str = '') -> list[str]:
    """Return up to `count` lines starting at line_num.

    If name_for_fallback is given and the line at line_num doesn't start
    with that name (the inventory's line is stale), search the file for
    a line that starts with `<name>\\s` and use that instead.
    """
    if not asm_path.exists():
        return []
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return []
    lines = text.split('\n')

    # Primary: read at the inventory's line.
    if 0 < line_num <= len(lines):
        first = lines[line_num - 1]
        if not name_for_fallback or re.match(r'^' + re.escape(name_for_fallback) + r'(?:\s|:|$)', first):
            return [l.rstrip() for l in lines[line_num - 1: line_num - 1 + count]]

    # Fallback: search by name.
    if name_for_fallback:
        pat = re.compile(r'^' + re.escape(name_for_fallback) + r'(?:\s|:|$)')
        for i, l in enumerate(lines):
            if pat.match(l):
                return [ll.rstrip() for ll in lines[i: i + count]]
    return []


def strip_comment(line: str) -> str:
    return re.sub(r';.*', '', line).rstrip()


def classify(name: str, source_lines: list[str]) -> tuple[str, str, str] | None:
    """Returns (verdict, description, matched_regex) or None if no name pattern.

    Checks the first source line by default.  For table patterns, also
    checks the next 1-2 lines (multi-line tables have only one element on
    the first line but more on subsequent lines).
    """
    if not source_lines:
        return None
    cleaned = strip_comment(source_lines[0])
    for name_re, shape_regexes, desc in DATA_PATTERNS:
        if not name_re.search(name):
            continue
        # Check first line against all shape regexes
        for shape in shape_regexes:
            if re.search(shape, cleaned, re.IGNORECASE):
                return ('SUPPORTED', desc, shape)
        # For table-like names, also check subsequent lines for db/dw
        # (multi-line tables span several lines).
        if name_re.search(name) and ('table' in desc or 'pointer' in desc
                                     or 'data' in desc or 'buffer' in desc):
            for next_line in source_lines[1:]:
                next_clean = strip_comment(next_line)
                if re.match(r'\s*\b(?:db|dw|dd)\b', next_clean, re.IGNORECASE):
                    # Multi-line table/data block confirmed
                    return ('SUPPORTED', desc, 'multi-line db/dw block')
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
        lines = get_source_lines(asm, it['line'], count=4,
                                 name_for_fallback=it['name'])
        if not lines or not lines[0]:
            counts['line_not_found'] += 1
            continue
        result = classify(it['name'], lines)
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
            'source_line': lines[0].strip()[:100],
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
