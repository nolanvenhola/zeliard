"""
fix_db_jumps.py — Convert Sourcer db-encoded relative jumps/calls to proper mnemonics.

For each db 0E9h/0E8h/0EBh in the source:
  1. Get byte offset from LST
  2. Calculate target offset
  3. Look up (or create) label at target
  4. Replace db line with proper jmp/call instruction

Usage: python3 fix_db_jumps.py [file1.asm ...]
       or run with no args to process all affected files.
"""
import re, struct, sys, shutil
from pathlib import Path

WORKING = Path('c:/Projects/Zeliard/3_Assembly/tasm/working')

JUMP_OPCODES = {
    0xE9: ('jmp',  3, 'near', 'rel16'),
    0xE8: ('call', 3, 'near', 'rel16'),
    0xEB: ('jmp',  2, 'short','rel8'),
}

# ── helpers ───────────────────────────────────────────────────────────────

def parse_lst(lst_text):
    """
    Return:
      offset_to_label  : {int offset -> str label_name}  (proc/label definitions)
      db_jumps         : list of (lst_lnum, off, opcode, target, hex_bytes_str)
      offset_table     : sorted [(lst_lnum, offset_delta)]  for line# conversion
    """
    offset_to_label = {}
    db_jumps = []
    offset_table = []   # for lst_lnum -> asm_lnum conversion

    for line in lst_text.split('\n'):
        # proc/label declarations → build offset→name map
        m = re.match(r'\s+(\d+)\s+([0-9A-Fa-f]{4})\s+(\w+)\s+(proc|label)\b', line, re.I)
        if m:
            off  = int(m.group(2), 16)
            name = m.group(3)
            if off not in offset_to_label:
                offset_to_label[off] = name
            # Store (lst_lnum, proc_name, type) — resolved properly in fix_file
            offset_table.append((int(m.group(1)), m.group(3), m.group(4).lower()))
            continue

        # Also capture plain labels: "   lnum   XXXX   label_name:" (no proc/endp keyword)
        m_lbl = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s+(\w+):\s*$', line)
        if m_lbl:
            off  = int(m_lbl.group(2), 16)
            name = m_lbl.group(3)
            if off not in offset_to_label:
                offset_to_label[off] = name
            continue

        # db lines with assembled bytes → look for encoded jumps
        # TASM outputs hex bytes in UPPERCASE in the dump column,
        # preventing false matches with instruction mnemonics like 'db'.
        m2 = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s+((?:[0-9A-F]{2}\s+)+)(.*)', line)
        if not m2:
            continue
        src_lnum  = int(m2.group(1))
        off       = int(m2.group(2), 16)
        hex_bytes = [int(x, 16) for x in m2.group(3).split()]
        rest      = m2.group(4).strip()

        if not rest.lower().startswith('db'):
            continue
        if not hex_bytes:
            continue
        # Only process lines that Sourcer marked as encoded instructions.
        # Lines without ';  Fixup' or ';*' are plain data bytes — skip them.
        if 'fixup' not in rest.lower() and ';*' not in rest:
            continue

        first = hex_bytes[0]
        if first not in JUMP_OPCODES:
            continue

        _, size, _, mode = JUMP_OPCODES[first]
        if mode == 'rel16' and len(hex_bytes) >= 3:
            rel    = struct.unpack_from('<h', bytes(hex_bytes[1:3]))[0]
            target = off + size + rel
        elif mode == 'rel8' and len(hex_bytes) >= 2:
            rel    = struct.unpack_from('<b', bytes([hex_bytes[1]]))[0]
            target = off + size + rel
        else:
            continue

        raw_src = re.search(r'db\s+(.*?)(?:\s*;|$)', rest, re.I).group(1).strip()
        db_jumps.append((src_lnum, off, first, target, raw_src))

    return offset_to_label, db_jumps, sorted(set(offset_table))


def lst_to_asm_line(lst_lnum, resolved_table):
    """Convert LST source line number to ASM source line number.
    resolved_table: sorted list of (lst_lnum, delta) where delta = lst_lnum - asm_lnum."""
    best_delta = resolved_table[0][1] if resolved_table else 0
    for tbl_lst, tbl_delta in resolved_table:
        if tbl_lst <= lst_lnum:
            best_delta = tbl_delta
        else:
            break
    return lst_lnum - best_delta


def build_resolved_table(raw_offset_table, asm_lines):
    """Resolve parse_lst's raw (lst_lnum, name, type) table into
    (lst_lnum, delta) where delta = lst_lnum - asm_lnum, by looking up
    each proc/label name in the ASM source."""
    resolved = []
    for lst_lnum, name, typ in raw_offset_table:
        for i, srcl in enumerate(asm_lines, 1):
            if re.match(rf'\s*{re.escape(name)}\s+{typ}\b', srcl, re.I):
                resolved.append((lst_lnum, lst_lnum - i))
                break
    return sorted(resolved)


def make_label(off, is_call):
    """Generate a label name for an address without an existing label."""
    return f'sub_{off:04X}' if is_call else f'loc_{off:04X}'


# ── main fix function ──────────────────────────────────────────────────────

def fix_file(asm_path, lst_path, dry_run=False):
    src      = asm_path.read_text(errors='replace')
    lst_text = lst_path.read_text(errors='replace')

    offset_to_label, db_jumps, raw_offset_table = parse_lst(lst_text)

    if not db_jumps:
        return 0

    src_lines = src.split('\n')
    asm_line_count = len(src_lines)

    # Build the correct LST→ASM line number offset table
    offset_table = build_resolved_table(raw_offset_table, src_lines)

    # Group by target: collect which targets need new labels.
    # NOTE: We only insert new labels when the target is at the exact start of
    # a known instruction (safe). Targets in data sections or mid-instruction
    # would produce wrong relative offsets in JMP encoding.
    # Skip cross-module or out-of-range targets.
    new_labels = {}   # off -> label_name
    for lst_lnum, off, opcode, target, raw_src in db_jumps:
        if target < 0 or target > 0xFFFF:
            continue
        if target not in offset_to_label:
            is_call = (opcode == 0xE8)
            new_labels[target] = make_label(target, is_call)

    # Build the comprehensive offset map to check exact-offset matching
    # (used to verify label placement is safe)
    offset_map_all = {}
    for line in lst_text.split('\n'):
        m = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s', line)
        if m:
            o = int(m.group(2), 16)
            if o not in offset_map_all:
                offset_map_all[o] = True

    failed_labels = set()  # labels that couldn't be placed (defined before the if block)

    # Step 1: build comprehensive offset → asm_line_idx map from ALL LST lines,
    # then insert new labels at their target positions.
    if new_labels:
        all_off_to_asm = {}
        for line in lst_text.split('\n'):
            m = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s', line)
            if not m:
                continue
            ll  = int(m.group(1))
            o   = int(m.group(2), 16)
            idx = lst_to_asm_line(ll, offset_table) - 1
            if 0 <= idx < asm_line_count and o not in all_off_to_asm:
                all_off_to_asm[o] = idx

        def find_idx(target_off):
            if target_off in all_off_to_asm:
                return all_off_to_asm[target_off]
            # Nearest offset at or after target
            cands = [(o, i) for o, i in all_off_to_asm.items() if o >= target_off]
            return min(cands, key=lambda x: x[0])[1] if cands else None

        insertions = {}
        for target_off, lbl in new_labels.items():
            # Only insert if target is the exact start of an instruction (safe)
            if target_off not in offset_map_all:
                failed_labels.add(lbl)
                continue
            idx = find_idx(target_off)
            # Verify the found idx is actually AT the target offset
            # (not just "nearest") to avoid wrong relative encoding
            if idx is not None and all_off_to_asm.get(target_off) == idx:
                insertions.setdefault(idx, []).append(lbl)
            elif idx is not None:
                # find_idx returned a nearby (not exact) match — unsafe for jumps
                failed_labels.add(lbl)
            else:
                print(f'  WARNING: no asm line found for label at 0x{target_off:04X}')
                failed_labels.add(lbl)

        for idx in sorted(insertions.keys(), reverse=True):
            n = len(insertions[idx])
            for lbl in insertions[idx]:
                src_lines.insert(idx, f'{lbl}:')
            all_off_to_asm = {k: (v + n if v >= idx else v) for k, v in all_off_to_asm.items()}

    # Merge successfully-inserted new labels into the map
    for off, lbl in new_labels.items():
        if lbl not in failed_labels:
            offset_to_label[off] = lbl
    src = '\n'.join(src_lines)

    # Step 2: Replace each db line with proper instruction.
    # Use LST line number → ASM line idx to identify the exact line to replace,
    # avoiding false matches in data-heavy files.
    replacements = 0
    src_lines = src.split('\n')

    # Process in reverse ASM line order so insertions don't shift indices.
    sorted_jumps = sorted(
        db_jumps,
        key=lambda j: lst_to_asm_line(j[0], offset_table),
        reverse=True
    )

    for lst_lnum, off, opcode, target, raw_src in sorted_jumps:
        mnemonic, size, _, mode = JUMP_OPCODES[opcode]

        # Skip cross-module targets (outside valid offset range)
        if target < 0 or target > 0xFFFF:
            continue

        lbl = offset_to_label.get(target)
        if lbl is None:
            continue  # no label for this target — skip replacement

        # TASM 2.x: use 'jmp short' for 0xEB, plain 'jmp' for 0xE9 (auto near/short),
        # 'call' for 0xE8. ('jmp near label' is not valid TASM 2.x syntax.)
        if opcode == 0xEB:
            instr = f'\t\t{mnemonic}\tshort {lbl}'
        else:
            instr = f'\t\t{mnemonic}\t{lbl}'

        # Find the ASM line index via LST line number conversion
        asm_lnum = lst_to_asm_line(lst_lnum, offset_table)
        asm_idx  = asm_lnum - 1

        if not (0 <= asm_idx < len(src_lines)):
            print(f'  WARNING: asm_idx {asm_idx} out of range for {mnemonic} at 0x{off:04X}')
            continue

        line = src_lines[asm_idx]
        # If this line is a ;* comment or other non-db, search nearby lines
        if not re.match(r'\s*db\b', line, re.I):
            found = False
            for delta in (1, -1, 2, -2, 3):
                candidate = asm_idx + delta
                if 0 <= candidate < len(src_lines):
                    if re.match(r'\s*db\b', src_lines[candidate], re.I):
                        asm_idx = candidate
                        line = src_lines[asm_idx]
                        found = True
                        break
            if not found:
                print(f'  WARNING: line {asm_lnum} is not a db: {line.strip()[:50]}')
                continue

        # Parse all bytes from this db line
        all_bytes = re.findall(r'0?([0-9A-Fa-f]+)h', line)
        instr_byte_strs = all_bytes[:size]
        trailing_byte_strs = all_bytes[size:]

        # Get indentation
        indent = re.match(r'^(\s*)', line).group(1)

        # Trailing bytes (bytes beyond the jump instruction) go on a new db line
        trailing_part = ''
        if trailing_byte_strs:
            t_bytes = [f'0{int(b,16):02X}h' for b in trailing_byte_strs]
            trailing_part = '\n' + indent + 'db\t' + ', '.join(t_bytes)

        was = ', '.join(f'0{int(b,16):02X}h' for b in instr_byte_strs)
        new_line = instr + trailing_part + f'\t\t\t; was: db {was}'
        src_lines[asm_idx] = new_line
        replacements += 1

    src = '\n'.join(src_lines)

    if not dry_run and replacements > 0:
        asm_path.write_text(src)

    return replacements


# ── entry point ────────────────────────────────────────────────────────────

# Files with db-encoded relative jumps (skip files where they're clearly data)
TARGET_FILES = [
    # zelres1/code
    'zelres1/code/100OPDMO.asm',
    'zelres1/code/101GDEGA.asm',
    'zelres1/code/103GDHGC.asm',
    'zelres1/code/104GDTGA.asm',
    'zelres1/code/105GDMCA.asm',
    'zelres1/code/106TOWNB.asm',
    'zelres1/code/107GTEGA.asm',
    'zelres1/code/108GTCGA.asm',
    'zelres1/code/109GTHGC.asm',
    'zelres1/code/110GTTGA.asm',
    'zelres1/code/124UTILA.asm',
    'zelres1/code/130UTILB.asm',
    # zelres2/code
    'zelres2/code/200FIGHT.asm',
    'zelres2/code/201SELCT.asm',
    'zelres2/code/202GFEGA.asm',
    'zelres2/code/203GFCGA.asm',
    'zelres2/code/204GFHGC.asm',
    'zelres2/code/207MOLEB.asm',
    'zelres2/code/208SATNO.asm',
    'zelres2/code/209BOSQE.asm',
    'zelres2/code/212TUMBA.asm',
    'zelres2/code/217PULPO.asm',
    'zelres2/code/250ENDMO.asm',
    # zelres3/code
    'zelres3/code/314LVLRD.asm',
    'zelres3/code/316TILCL.asm',
    'zelres3/code/331MP50.asm',
    'zelres3/code/332MP51.asm',
    # drivers
    'drivers/gmega.asm',
    'drivers/gmhgc.asm',
    'drivers/stick.asm',
]

if __name__ == '__main__':
    files = sys.argv[1:] or TARGET_FILES
    total = 0
    for rel in files:
        asm = WORKING / rel
        stem = asm.stem.upper()
        lst  = asm.parent / f'{stem}.LST'
        if not asm.exists():
            print(f'SKIP (no asm): {rel}')
            continue
        if not lst.exists():
            print(f'SKIP (no lst): {rel}')
            continue
        n = fix_file(asm, lst)
        if n:
            print(f'{asm.name}: {n} replacements')
        total += n
    print(f'\nTotal: {total} replacements')
