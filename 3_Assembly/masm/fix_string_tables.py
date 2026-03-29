"""
fix_string_tables.py — Replace Sourcer-decoded fake instructions with proper
db declarations for known string/data table regions.

For each region:
  1. Extract bytes from compiled binary
  2. Find the ASM source lines via LST offset mapping
  3. Replace with db declarations (string form for printable, hex for binary)
  4. Verify bit-perfect output via build_all.py

Usage: python3 fix_string_tables.py [--dry-run]
"""
import re, sys, subprocess
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from fix_db_jumps import parse_lst, build_resolved_table, lst_to_asm_line

WORKING = Path('c:/Projects/Zeliard/3_Assembly/masm/working')
BIN_DIR = Path('c:/Projects/Zeliard/3_Assembly/tasm/bin')
TASM_RUNNER = Path('c:/Projects/Zeliard/3_Assembly/tasm/TasmRunner')

DRY_RUN = '--dry-run' in sys.argv

def is_printable_str(b):
    return 0x20 <= b <= 0x7E

def bytes_to_db(data, indent='\t\t'):
    """Convert bytes to TASM db declarations, using string form where possible."""
    lines = []
    i = 0
    while i < len(data):
        # Try to extract a printable string run
        if is_printable_str(data[i]):
            j = i
            while j < len(data) and is_printable_str(data[j]):
                j += 1
            s = bytes(data[i:j]).decode('ascii')
            # Escape backslashes and single quotes for TASM
            s_esc = s.replace('\\', '\\\\').replace("'", "\\'")
            lines.append(f"{indent}db\t'{s_esc}', 0\t\t; 0x{i:04X}")
            i = j + 1  # skip the null
        elif data[i] == 0x00:
            # Extra null — just skip (null already included after strings)
            i += 1
        else:
            # Non-printable byte — group up to 6 bytes as hex
            j = i
            while j < len(data) and (not is_printable_str(data[j]) or data[j] == 0x00):
                if data[j] == 0x00 and j > i:
                    break  # stop at null (string terminator)
                j = min(j + 1, len(data))
                if j - i >= 6:
                    break
            chunk = data[i:j]
            hex_vals = ', '.join(f'0{b:02X}h' for b in chunk)
            lines.append(f"{indent}db\t{hex_vals}\t\t; 0x{i:04X}")
            i = j
    return lines


def get_lst(asm_path):
    """Return path to LST; generate if needed."""
    stem = asm_path.stem.upper()
    lst_path = asm_path.parent / f'{stem}.LST'
    if not lst_path.exists():
        print(f'  Generating LST for {asm_path.name}...')
        dotnet = TASM_RUNNER / 'bin/Debug/net8.0/TasmRunner.exe'
        if not dotnet.exists():
            dotnet = 'dotnet'
            args = ['dotnet', 'run', '--project', str(TASM_RUNNER), '--',
                    str(asm_path), '--bin', '--output', str(asm_path.parent)]
        else:
            args = [str(dotnet), str(asm_path), '--bin', '--output',
                    str(asm_path.parent)]
        subprocess.run(args, capture_output=True, cwd=TASM_RUNNER)
    return lst_path if lst_path.exists() else None


def find_asm_lines_for_range(lst_text, src_lines, bin_start, bin_end):
    """
    Find the range of ASM source lines that cover binary offsets [bin_start, bin_end).
    Returns (first_asm_idx, last_asm_idx) 0-based, or None if not found.
    """
    labels, _, raw_tbl = parse_lst(lst_text)
    tbl = build_resolved_table(raw_tbl, src_lines)

    # Build offset -> asm_idx
    # Handles both TASM format ("   LNUM\tOFFSET  bytes") and
    # MASM format (" OFFSET  bytes") where MASM has no line numbers.
    off_to_asm = {}
    seq = 0
    for line in lst_text.split('\n'):
        seq += 1
        # TASM: leading spaces + decimal line number + hex offset
        m = re.match(r'\s+(\d+)\s+([0-9A-F]{4})\s', line)
        if m:
            o = int(m.group(2), 16)
            if o not in off_to_asm:
                ll = int(m.group(1))
                idx = lst_to_asm_line(ll, tbl) - 1
                if 0 <= idx < len(src_lines):
                    off_to_asm[o] = idx
            continue
        # MASM: single leading space + hex offset (no line number)
        m = re.match(r'^ ([0-9A-F]{4})\s', line)
        if m:
            o = int(m.group(1), 16)
            if o not in off_to_asm:
                # For MASM, use sequential LST position as approximate line number
                # and find the source line by content matching below
                off_to_asm[o] = seq

    # Find ASM indices in range — clamp to valid source line range
    n_lines = len(src_lines)
    indices = [min(idx, n_lines - 1) for o, idx in off_to_asm.items()
               if bin_start <= o < bin_end and 0 <= idx < n_lines * 3]
    if not indices:
        return None, None
    first = min(indices)
    last  = max(indices)
    # For MASM sequential numbers that exceed file length, scan backward for real code
    if first >= n_lines or last >= n_lines:
        return None, None
    return first, last


def fix_region(asm_path, bin_path, bin_start, bin_end, comment=''):
    """
    Replace fake-instruction lines for binary region [bin_start, bin_end)
    with proper db declarations.
    """
    lst_path = get_lst(asm_path)
    if not lst_path:
        print(f'  SKIP: no LST for {asm_path.name}')
        return False

    src = asm_path.read_text(errors='replace')
    src_lines = src.split('\n')
    lst_text = lst_path.read_text(errors='replace')
    bin_data = bin_path.read_bytes()

    first_idx, last_idx = find_asm_lines_for_range(
        lst_text, src_lines, bin_start, bin_end)

    if first_idx is None:
        print(f'  SKIP: region 0x{bin_start:04X}-0x{bin_end:04X} not found in {asm_path.name}')
        return False

    # Extract the actual bytes
    data = bytes(bin_data[bin_start:bin_end])

    # Build replacement db lines
    db_lines = []
    if comment:
        db_lines.append(f'\t\t; {comment}')
    db_lines.extend(bytes_to_db(data))

    # Safety: skip proc/endp/label lines at the boundaries — keep them in place
    # Also skip if the first line is a meaningful instruction (not single-byte ASCII)
    # Lines to skip at boundaries: proc/endp declarations and real multi-byte instructions
    SKIP_PATTERNS = re.compile(
        r'^\s*(\w+\s+)?(endp|proc|label)\b|^\s*\w+:', re.I)
    REAL_INSTR = re.compile(
        r'^\s*(jmp|call|ret|jnz|jz|je|jne|jc|jnc|jbe|ja|jl|jge|jle|jg'
        r'|jno|jo|js|jns|jp|jnp|jcxz|loop|int|hlt|iret'
        r'|add\b|sub\b|adc\b|sbb\b|mov\b|cmp\b|and\b|or\b|xor\s+\w+,'
        r'|test\b|push\s+\w{2,}|pop\s+\w{2,}|retn\b|ret\b)\b', re.I)

    # Trim from start: skip proc/endp/label lines
    while first_idx <= last_idx and (
            SKIP_PATTERNS.match(src_lines[first_idx].strip()) or
            REAL_INSTR.match(src_lines[first_idx].strip())):
        first_idx += 1

    # Trim from end: skip proc/endp/label lines
    while last_idx >= first_idx and (
            SKIP_PATTERNS.match(src_lines[last_idx].strip()) or
            REAL_INSTR.match(src_lines[last_idx].strip())):
        last_idx -= 1

    if first_idx > last_idx:
        print(f'  SKIP: no replaceable lines in range for {asm_path.name} '
              f'0x{bin_start:04X}-0x{bin_end:04X}')
        return False

    old_lines = src_lines[first_idx:last_idx + 1]

    if DRY_RUN:
        print(f'  [DRY RUN] {asm_path.name} 0x{bin_start:04X}-0x{bin_end:04X}:')
        print(f'    Replace {last_idx - first_idx + 1} lines (ASM {first_idx+1}-{last_idx+1})')
        print(f'    First old: {old_lines[0].strip()[:50]}')
        print(f'    First new: {db_lines[0].strip()[:50]}')
        return True

    # Apply replacement
    new_src_lines = src_lines[:first_idx] + db_lines + src_lines[last_idx + 1:]
    asm_path.write_text('\n'.join(new_src_lines))
    return True


# ── Table definitions ─────────────────────────────────────────────────────

# Each entry: (bin_file_stem, bin_start, bin_end, comment)
TABLES = [
    # 106TOWNB (town.bin) — resource filenames and UI strings
    ('106TOWNB', 0x073A, 0x0747, 'UI strings: Take/No Take prompt'),
    ('106TOWNB', 0x0AD9, 0x0AEF, 'SAR chunk references: YMPD.BIN, CKPD.BIN'),
    ('106TOWNB', 0x0D8E, 0x0DA2, 'Sprite file references: MMAN.GRP, CMAN.GRP'),
    ('106TOWNB', 0x0DCB, 0x0DF2, 'Pattern/sprite file references: MPAT.GRP, DPAT.GRP'),
    ('106TOWNB', 0x0F0B, 0x0F7B, 'Building program file references (OMOYPRO, KENJPRO, ARMRPRO...)'),
    ('106TOWNB', 0x166A, 0x1688, 'Game loader reference: GAME.BIN'),
    ('106TOWNB', 0x17A9, 0x17C7, 'Input/user string data'),

    # 201SELCT (select.bin) — partially fixed; one remaining region
    ('201SELCT', 0x0A10, 0x0A20, 'Menu shortcut table prefix entries'),

    # 200FIGHT (fight.bin) — ASCII sequence table
    ('200FIGHT', 0x19B3, 0x19E3, 'ASCII sequence / lookup table'),

    # Graphics driver character tables (202-206: gfega/cga/hgc/tga/mcga)
    ('202GFEGA', 0x19B3, 0x1A02, 'Character encoding / font lookup table'),
    ('202GFEGA', 0x1A1B, 0x1A28, 'Character encoding table (continued)'),
    ('203GFCGA', 0x188C, 0x18DB, 'Character encoding / font lookup table'),
    ('203GFCGA', 0x18DB, 0x18F4, 'Character encoding table (continued)'),
    ('203GFCGA', 0x18F4, 0x1901, 'Character encoding table (continued)'),
    ('204GFHGC', 0x17E5, 0x1834, 'Character encoding / font lookup table'),
    ('205GFTGA', 0x1A23, 0x1A72, 'Character encoding / font lookup table'),
    ('205GFTGA', 0x1A72, 0x1A8B, 'Character encoding table (continued)'),
    ('206GFMCA', 0x1809, 0x1858, 'Character encoding / font lookup table'),

    # 314LVLRD (level loader) — tile/character index tables
    ('314LVLRD', 0x00DA, 0x00EC, 'Tile index table'),
    ('314LVLRD', 0x0103, 0x013F, 'Tile/character index table'),
    ('314LVLRD', 0x0149, 0x0178, 'Tile index table (continued)'),
    ('314LVLRD', 0x0182, 0x018C, 'Tile index table (continued)'),

    # 316TILCL (tile clear) — tile pattern tables
    ('316TILCL', 0x01C2, 0x01CF, 'Tile pattern table'),
    ('316TILCL', 0x01F4, 0x021F, 'Tile pattern table (continued)'),
    ('316TILCL', 0x0221, 0x0233, 'Tile pattern table (continued)'),

    # 356LVGRP (level graphics) — small data table
    ('356LVGRP', 0x045C, 0x0465, 'Graphics data table'),
]

# Map stem to paths
def find_paths(stem):
    """Find (asm_path, bin_path) for a given file stem."""
    for subdir in ['zelres1', 'zelres2', 'zelres3']:
        for code_or_data in ['code', 'data', 'drivers', 'core']:
            asm_d = WORKING / subdir / code_or_data
            bin_d = BIN_DIR / subdir
            if asm_d.exists():
                asm = asm_d / f'{stem}.asm'
                if asm.exists():
                    # Find bin
                    for binf in bin_d.glob(f'{stem}.bin'):
                        return asm, binf
    # Check drivers and core
    for d in [WORKING / 'drivers', WORKING / 'core']:
        asm = d / f'{stem}.asm'
        if asm.exists():
            binf = BIN_DIR / f'{stem}.bin'
            if binf.exists():
                return asm, binf
    return None, None


# ── Main ──────────────────────────────────────────────────────────────────

print(f'Fixing {len(TABLES)} string table regions'
      + (' [DRY RUN]' if DRY_RUN else '') + '\n')

fixed = skipped = 0
files_modified = set()

for stem, start, end, comment in TABLES:
    asm_path, bin_path = find_paths(stem)
    if not asm_path:
        print(f'SKIP: {stem} not found')
        skipped += 1
        continue

    print(f'{stem}.asm  0x{start:04X}-0x{end:04X}  {comment[:45]}')
    ok = fix_region(asm_path, bin_path, start, end, comment)
    if ok:
        fixed += 1
        files_modified.add(asm_path)
    else:
        skipped += 1

print(f'\nResults: {fixed} fixed, {skipped} skipped')

# Note: MASM 4.0 cannot compile the largest files (memory limits).
# Verification is done via tasm/build_all.py --verify (canonical TASM build).
