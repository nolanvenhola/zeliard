"""
find_string_tables.py — Scan compiled binaries for ASCII string table regions.

Looks for sequences of null-terminated printable strings in the .bin files
and reports whether the corresponding ASM source has them properly annotated
or still decoded as fake instructions by Sourcer.

Usage: python3 find_string_tables.py
"""
import re
from pathlib import Path

BIN  = Path('c:/Projects/Zeliard/3_Assembly/tasm/bin')
WORK = Path('c:/Projects/Zeliard/3_Assembly/tasm/working')

# Minimum criteria for a string table candidate
MIN_STRING_LEN    = 3    # minimum chars per individual string
MIN_STRINGS       = 2    # minimum number of strings in a sequence
MIN_PRINTABLE_PCT = 0.75  # minimum fraction of bytes that are printable ASCII

def is_printable(b):
    return 0x20 <= b <= 0x7E

def parse_null_strings(data, start, max_len=256):
    """
    Starting at `start`, parse consecutive null-terminated strings.
    Returns list of (offset, string_bytes) until we hit too many non-printable
    chars or exceed max_len bytes.
    """
    strings = []
    off = start
    end = min(start + max_len, len(data))

    while off < end:
        # Find next null
        null_pos = off
        while null_pos < end and data[null_pos] != 0:
            null_pos += 1

        s = bytes(data[off:null_pos])
        if len(s) == 0:
            off = null_pos + 1
            continue

        printable = sum(1 for b in s if is_printable(b))
        if printable / max(len(s), 1) < MIN_PRINTABLE_PCT:
            break  # too many non-printable bytes, end of table

        strings.append((off, s))
        off = null_pos + 1

    return strings


def find_tables_in_binary(bin_path):
    """Scan a binary for string table candidates."""
    data = bin_path.read_bytes()
    tables = []
    off = 0

    while off < len(data) - 4:
        # Quick scan: look for runs of printable bytes + null
        if not is_printable(data[off]) and data[off] != 0:
            off += 1
            continue

        strings = parse_null_strings(data, off)

        # Filter: need at least MIN_STRINGS with MIN_STRING_LEN each
        good = [s for _, s in strings if len(s) >= MIN_STRING_LEN
                and sum(is_printable(b) for b in s) / len(s) >= MIN_PRINTABLE_PCT]

        if len(good) >= MIN_STRINGS:
            total_bytes = sum(len(s) + 1 for _, s in strings)
            tables.append({
                'offset':  off,
                'end':     off + total_bytes,
                'strings': strings,
                'bytes':   total_bytes,
            })
            off += total_bytes  # skip past this table
        else:
            off += 1

    return tables


def check_asm_annotation(asm_path, bin_offset, bin_end):
    """
    Check whether the ASM source region covering bin_offset..bin_end
    is properly annotated as string data (db 'text') or still decoded
    as fake instructions.
    """
    if not asm_path.exists():
        return 'no_asm'

    lst_path = asm_path.parent / (asm_path.stem.upper() + '.LST')
    if not lst_path.exists():
        return 'no_lst'

    src_lines = asm_path.read_text(errors='replace').split('\n')
    lst_text  = lst_path.read_text(errors='replace')

    # Find ASM lines that cover this binary region
    # Build offset -> source line from LST
    offsets_in_range = {}
    for line in lst_text.split('\n'):
        m = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s', line)
        if m:
            o = int(m.group(2), 16)
            if bin_offset <= o < bin_end:
                offsets_in_range[o] = int(m.group(1))

    if not offsets_in_range:
        return 'not_found'

    # Sample the source lines at those LST line numbers
    # Determine offset delta from the first proc/endp marker before this region
    # (simplified: just check if any line in the region has db 'text' or is an instruction)
    fake_instrs = 0
    string_dbs  = 0

    for lst_lnum in sorted(offsets_in_range.values()):
        # Rough conversion: find ASM line (may be off due to include offsets)
        # Use the raw LST line number as an approximation
        asm_idx = lst_lnum - 1
        if 0 <= asm_idx < len(src_lines):
            line = src_lines[asm_idx].strip()
            if re.match(r"db\s+'", line, re.I):
                string_dbs += 1
            elif re.match(r'(push|pop|inc|dec|xor|cmp|sub|add|mov|jnz|jz|call|jmp)\b',
                          line, re.I):
                fake_instrs += 1
            elif re.match(r'db\b', line, re.I):
                string_dbs += 1  # raw db (could be annotated or not)

    if string_dbs > 0 and fake_instrs == 0:
        return 'annotated'
    elif fake_instrs > 0:
        return 'fake_instrs'
    else:
        return 'unknown'


# ── Main scan ──────────────────────────────────────────────────────────────

SCAN_DIRS = [
    'zelres1',
    'zelres2',
    'zelres3',
]

results = []

for sar in SCAN_DIRS:
    bin_dir = BIN / sar
    asm_dirs = [
        WORK / sar / 'code',
        WORK / sar / 'data',
    ]

    for bin_file in sorted(bin_dir.glob('*.bin')):
        # Find corresponding ASM
        asm_path = None
        for d in asm_dirs:
            p = d / (bin_file.stem + '.asm')
            if p.exists():
                asm_path = p
                break

        tables = find_tables_in_binary(bin_file)
        if not tables:
            continue

        for tbl in tables:
            strings = tbl['strings']
            # Decode for display
            decoded = []
            for _, s in strings:
                try:
                    decoded.append(s.decode('ascii'))
                except Exception:
                    decoded.append(s.hex())

            status = check_asm_annotation(asm_path, tbl['offset'], tbl['end']) \
                     if asm_path else 'no_asm'

            results.append({
                'file':    bin_file.name,
                'asm':     asm_path.name if asm_path else '(no asm)',
                'offset':  tbl['offset'],
                'end':     tbl['end'],
                'bytes':   tbl['bytes'],
                'strings': decoded,
                'status':  status,
            })

# ── Report ─────────────────────────────────────────────────────────────────

print(f'Found {len(results)} string table candidates\n')

# Group by status
for status, label in [
    ('fake_instrs', 'NEEDS FIXING (decoded as fake instructions)'),
    ('unknown',     'UNCERTAIN (mixed or unknown state)'),
    ('annotated',   'Already annotated as db strings'),
    ('no_asm',      'No ASM file (data chunk)'),
    ('no_lst',      'No LST file'),
    ('not_found',   'Region not found in LST'),
]:
    group = [r for r in results if r['status'] == status]
    if not group:
        continue
    print(f'=== {label} ({len(group)}) ===')
    for r in group:
        strings_preview = ' | '.join(
            repr(s) if len(s) <= 12 else repr(s[:12] + '...')
            for s in r['strings'][:4]
        )
        if len(r['strings']) > 4:
            strings_preview += f' ... (+{len(r["strings"])-4} more)'
        print(f'  {r["file"]:<22} 0x{r["offset"]:04X}-0x{r["end"]:04X} '
              f'({r["bytes"]:3d}B)  {strings_preview}')
    print()
