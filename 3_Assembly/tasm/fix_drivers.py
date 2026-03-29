"""
Linkability fix for driver files.
Uses LST proc-marker table to convert LST src_lnum -> ASM source line,
then splits db blocks at each target offset and inserts _lbl label bytes.
TASM 2.01 constraint: DRIVER_BASE + (offset label) with delta=0 only.
"""
import re
from pathlib import Path

WORKING = Path('c:/Projects/Zeliard/3_Assembly/tasm/working')
CONFIGS = {
    'gmmcga': 0x2000,
    'gmcga':  0x2000,
    'gmega':  0x2000,
    'gmhgc':  0x2000,
    'gmtga':  0x2000,
    'stick':  0x0100,
}

def build_offset_table(lst_text, asm_lines):
    """
    Build a sorted list of (lst_lnum, offset) by matching proc/endp/label
    markers between LST and ASM source. offset = lst_lnum - asm_line.
    """
    src_list = asm_lines  # list of source lines (0-indexed)
    table = []  # [(lst_lnum, offset)]

    for line in lst_text.split('\n'):
        m = re.match(r'\s+(\d+)\s+[0-9A-Fa-f]{4}\s+(\w+)\s+(proc|endp|label)\b', line)
        if not m:
            continue
        lst_lnum = int(m.group(1))
        name = m.group(2)
        typ  = m.group(3).lower()  # match same type to avoid proc/endp confusion
        # Find in asm source (match type exactly)
        for i, srcl in enumerate(src_list, 1):
            if re.match(rf'\s*{re.escape(name)}\s+{typ}\b', srcl, re.I):
                offset = lst_lnum - i
                table.append((lst_lnum, offset))
                break

    return sorted(table)

def lst_to_asm_line(lst_lnum, offset_table):
    """Convert a LST src_lnum to ASM source line number using the offset table."""
    # Use the most recent entry with lst_lnum <= target
    best_offset = offset_table[0][1] if offset_table else 0
    for (tbl_lst, tbl_off) in offset_table:
        if tbl_lst <= lst_lnum:
            best_offset = tbl_off
        else:
            break
    return lst_lnum - best_offset  # 1-indexed ASM line

def parse_lst_db_lines(lst_text, offset_table, asm_lines):
    """
    Extract db lines from LST: returns dict mapping
      bin_offset -> (asm_line_idx_0based, byte_pos_within_line, line_bytes)
    """
    result = {}  # bin_offset -> (asm_line_0based, byte_pos)
    for line in lst_text.split('\n'):
        m = re.match(r'\s+(\d+)\s+([0-9A-Fa-f]{4})\s+(.*)', line)
        if not m:
            continue
        lst_lnum = int(m.group(1))
        hex_off = int(m.group(2), 16)
        rest = m.group(3)
        if not re.search(r'\bdb\b', rest, re.I):
            continue
        asm_lnum = lst_to_asm_line(lst_lnum, offset_table)
        asm_idx = asm_lnum - 1  # 0-based
        if 0 <= asm_idx < len(asm_lines):
            result[hex_off] = (asm_idx, lst_lnum)
    return result

def db_line_bytes_lst(line_text):
    """Parse a db line into list of ints. Returns None if not parseable."""
    m = re.match(r'\s*db\s+(.*?)(\s*;.*)?$', line_text, re.I)
    if not m:
        return None
    vals_str = m.group(1).strip()
    result = []
    for part in vals_str.split(','):
        part = part.strip()
        dm = re.match(r'(\d+)\s+dup\s*\(\s*(.*?)\s*\)', part, re.I)
        if dm:
            count = int(dm.group(1))
            inner = dm.group(2).strip()
            hm = re.match(r'0?([0-9A-Fa-f]+)h', inner, re.I)
            val = int(hm.group(1), 16) if hm else 0
            result.extend([val] * count)
        elif re.match(r"'[^']*'", part):
            for ch in part[1:-1]:
                result.append(ord(ch))
        else:
            hm = re.match(r'0?([0-9A-Fa-f]+)h', part, re.I)
            if hm:
                result.append(int(hm.group(1), 16))
            else:
                try:
                    result.append(int(part))
                except Exception:
                    return None
    return result


def rebuild_db_line(indent, byte_vals):
    strs = [f'0{v:02X}h' for v in byte_vals]
    return f'{indent}db\t {", ".join(strs)}'


for drv_stem, base in CONFIGS.items():
    asm_path = WORKING / 'drivers' / f'{drv_stem}.asm'
    lst_path = WORKING / 'drivers' / f'{drv_stem.upper()}.LST'
    bin_path = WORKING.parent / 'bin' / f'{drv_stem}.bin'

    src      = asm_path.read_text(errors='replace')
    lst_text = lst_path.read_text(errors='replace')
    bin_data = bin_path.read_bytes()
    bin_size = len(bin_data)
    base_name = f'{drv_stem.upper()}_BASE'

    asm_lines = src.split('\n')

    # Find internal EQUs
    internals = {}
    for m in re.finditer(r'^(\w+)\s+equ\s+([0-9A-Fa-f]+h)', src, re.M):
        name, val_str = m.group(1), m.group(2)
        val = int(val_str[:-1], 16)
        if val == base:
            continue  # skip the DRIVER_BASE constant itself
        if base <= val < base + bin_size:
            off = val - base
            internals[name] = (val, off)

    if not internals:
        print(f'{drv_stem}: no internal EQUs')
        continue

    print(f'{drv_stem}: {len(internals)} internal EQUs')

    # Build offset table and db-line map
    offset_table = build_offset_table(lst_text, asm_lines)
    db_map = parse_lst_db_lines(lst_text, offset_table, asm_lines)
    # db_map: bin_offset -> (asm_line_0based, lst_lnum)

    # For each target offset: find which db block contains it
    # A db block starting at bin_off covers bin_off..bin_off+len(bytes)-1
    # Build: sorted list of (db_start_off, asm_idx)
    db_sorted = sorted(db_map.items())  # (bin_off, (asm_idx, lst_lnum))

    equ_to_lbl  = {}
    off_to_lbl   = {}
    insertions   = {}  # asm_idx -> [(byte_pos_in_line, lbl)]

    for equ_name, (val, off) in sorted(internals.items(), key=lambda x: x[1][1]):
        if off in off_to_lbl:
            equ_to_lbl[equ_name] = off_to_lbl[off]
            continue

        lbl = f'{equ_name}_lbl'
        off_to_lbl[off] = lbl
        equ_to_lbl[equ_name] = lbl

        # Find the db block that contains this offset
        found = False
        for i, (db_off, (asm_idx, lst_lnum)) in enumerate(db_sorted):
            if db_off > off:
                break
            # Check if this db block covers 'off'
            db_bytes = db_line_bytes_lst(asm_lines[asm_idx])
            if db_bytes and db_off + len(db_bytes) > off:
                byte_pos = off - db_off
                if asm_idx not in insertions:
                    insertions[asm_idx] = []
                insertions[asm_idx].append((byte_pos, lbl))
                found = True
                break

        if not found:
            print(f'  WARNING: no db block found for {equ_name}=0x{off:03X}')

    # Apply insertions in reverse order
    for asm_idx in sorted(insertions.keys(), reverse=True):
        orig_line = asm_lines[asm_idx]
        indent = re.match(r'^(\s*)', orig_line).group(1)
        byte_vals = db_line_bytes_lst(orig_line)
        if byte_vals is None:
            print(f'  WARNING: cannot parse asm line {asm_idx+1}')
            continue

        targets = sorted(insertions[asm_idx])
        new_lines = []
        prev = 0
        for byte_pos, lbl in targets:
            if byte_pos > prev:
                new_lines.append(rebuild_db_line(indent, byte_vals[prev:byte_pos]))
            new_lines.append(f'{lbl}\t\tequ\t$')
            prev = byte_pos
        if prev < len(byte_vals):
            new_lines.append(rebuild_db_line(indent, byte_vals[prev:]))

        asm_lines[asm_idx:asm_idx+1] = new_lines

    src = '\n'.join(asm_lines)

    # Replace EQU lines
    def replace_equ(m):
        name, val_str = m.group(1), m.group(2)
        if name not in equ_to_lbl:
            return m.group(0)
        lbl = equ_to_lbl[name]
        return f'{name}\t\tequ\t{base_name} + (offset {lbl})\t\t;*'

    src = re.sub(r'^(\w+)\s+equ\s+([0-9A-Fa-f]+h)', replace_equ, src, flags=re.M)

    # Add DRIVER_BASE constant
    insert_marker = '; The following equates'
    if insert_marker in src:
        src = src.replace(insert_marker,
            f'; zeliad loads {drv_stem}.bin at 0x{base:04X} in the game segment.\n'
            f'{base_name}\t\tequ\t0{base:04X}h\n\n'
            + insert_marker, 1)

    asm_path.write_text(src)
    print(f'  Written {asm_path.name}')

print('Done.')
