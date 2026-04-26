"""
annotate_db_rows.py: Add per-row offset comments to bare `db` lines within labeled
data blocks. Block-local offset starts at 0 at each new label.

Recognizes lines that look like data block headers:
  labelname:                              <- starts a new block
  labelname    label   byte               <- starts a new block

For each bare-db line within a block (no comment, no DUP, no string), appends
`; +0xNN` showing the byte offset within the block.

Usage:
  python annotate_db_rows.py <asm_path> [--dry-run]
"""
import sys
import re

DB_RE = re.compile(r'^(\s+db\s+)(.+?)(\s*;.*)?$')
DW_RE = re.compile(r'^(\s+dw\s+)(.+?)(\s*;.*)?$')
DUP_RE = re.compile(r'(\d+)\s+dup\s*\(\s*(\S+)\s*\)', re.IGNORECASE)
LABEL_BLOCK_RES = [
    re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*):\s*$'),
    re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*):\s*;'),
    re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s+label\s+\S+', re.I),
]
PROC_RE = re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s+proc\b', re.I)
LABEL_DB_RE = re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*):(\s+)(d[bw])\s+(.+?)(\s*;.*)?$')
# inline label without colon: "name   dw  ..." or "name   db  ..."
INLINE_DATA_LBL_RE = re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s+(d[bw])\s+(.+?)(\s*;.*)?$')

def count_dw_bytes(operand: str) -> int:
    s = operand.strip()
    total = 0
    def replace_dup(m):
        nonlocal total
        total += int(m.group(1)) * 2
        return ''
    s_no_dup = DUP_RE.sub(replace_dup, s)
    out_tokens = []
    cur = ''
    in_str = False
    str_quote = None
    for c in s_no_dup:
        if in_str:
            cur += c
            if c == str_quote:
                in_str = False
        else:
            if c in ('"', "'"):
                in_str = True
                str_quote = c
                cur += c
            elif c == ',':
                if cur.strip():
                    out_tokens.append(cur.strip())
                cur = ''
            else:
                cur += c
    if cur.strip():
        out_tokens.append(cur.strip())
    for tok in out_tokens:
        if tok.strip():
            total += 2
    return total

def count_db_bytes(operand: str) -> int:
    s = operand.strip()
    total = 0
    def replace_dup(m):
        nonlocal total
        total += int(m.group(1))
        return ''
    s_no_dup = DUP_RE.sub(replace_dup, s)
    out_tokens = []
    cur = ''
    in_str = False
    str_quote = None
    for c in s_no_dup:
        if in_str:
            cur += c
            if c == str_quote:
                in_str = False
        else:
            if c in ('"', "'"):
                in_str = True
                str_quote = c
                cur += c
            elif c == ',':
                if cur.strip():
                    out_tokens.append(cur.strip())
                cur = ''
            else:
                cur += c
    if cur.strip():
        out_tokens.append(cur.strip())
    for tok in out_tokens:
        tok = tok.strip()
        if not tok:
            continue
        if (tok.startswith("'") and tok.endswith("'") and len(tok) >= 2) or \
           (tok.startswith('"') and tok.endswith('"') and len(tok) >= 2):
            inner = tok[1:-1]
            total += len(inner)
        else:
            total += 1
    return total

def is_label_line(line: str) -> bool:
    s = line.rstrip()
    for r in LABEL_BLOCK_RES:
        if r.match(s):
            return True
    if PROC_RE.match(s):
        return True
    return False

def main():
    if len(sys.argv) < 2:
        print("usage: annotate_db_rows.py <asm> [--dry-run]")
        sys.exit(1)
    path = sys.argv[1]
    dry = '--dry-run' in sys.argv
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    block_offset = 0
    annotated = 0
    for raw in lines:
        line = raw.rstrip('\n')

        if is_label_line(line):
            block_offset = 0
            new_lines.append(raw)
            continue

        m_label_db = LABEL_DB_RE.match(line)
        if m_label_db:
            block_offset = 0
            operand = m_label_db.group(4)
            existing = m_label_db.group(5) or ''
            kind = m_label_db.group(3).lower()
            adv = count_db_bytes(operand) if kind == 'db' else count_dw_bytes(operand)
            block_offset += adv
            new_lines.append(raw)
            continue

        # inline data label without colon: e.g. "data_80    dw   5F5Fh, 0AF54h"
        m_inline = INLINE_DATA_LBL_RE.match(line)
        if m_inline:
            # don't reset offset -- this is a sub-label inside a larger block
            operand = m_inline.group(3)
            kind = m_inline.group(2).lower()
            adv = count_db_bytes(operand) if kind == 'db' else count_dw_bytes(operand)
            block_offset += adv
            new_lines.append(raw)
            continue

        m_db = DB_RE.match(line)
        if m_db:
            operand = m_db.group(2)
            existing = m_db.group(3) or ''
            advance = count_db_bytes(operand)
            line_offset = block_offset
            block_offset += advance
            has_str = "'" in operand or '"' in operand
            has_dup = bool(DUP_RE.search(operand))
            if not existing and not has_str and not has_dup:
                new_lines.append(line + f'\t; +0x{line_offset:03X}\n')
                annotated += 1
            else:
                new_lines.append(raw)
            continue

        # Standalone dw lines: advance offset (don't add comments to dw)
        m_dw = DW_RE.match(line)
        if m_dw:
            operand = m_dw.group(2)
            advance = count_dw_bytes(operand)
            block_offset += advance
            new_lines.append(raw)
            continue

        # any other line: pass through (can include code instructions which we don't track)
        # Heuristic: if the line is an instruction inside a proc, that breaks block_offset tracking,
        # but we only annotate db lines so it's ok. We DO want code lines to count as "advancing" the
        # block? Actually no -- if there's code mixed in, the block isn't a pure data block, and
        # offset semantics are unclear. So we just keep block_offset until next label.
        new_lines.append(raw)

    print(f"annotated {annotated} db lines")
    if not dry:
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)

if __name__ == '__main__':
    main()
