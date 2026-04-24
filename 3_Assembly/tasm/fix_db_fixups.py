#!/usr/bin/env python3
"""
fix_db_fixups.py — Convert Sourcer `; Fixup - byte match` db/dw declarations
                   back into proper TASM assembly mnemonics.

For each `; Fixup - byte match` line in ASM files the script:
  1. Reads the binary offset from the corresponding LST file.
  2. Reads the actual bytes from the compiled binary at that offset.
  3. Decodes using ndisasm -b 16.
  4. Converts ndisasm output to TASM syntax.
  5. Replaces the db/dw line (and, for far-address dw lines, the preceding db opcode
     line) with the proper mnemonic.

After processing all files, runs `python3 build_all.py --verify` to confirm the
SARs remain bit-perfect.

Usage:
    python3 fix_db_fixups.py [--dry-run] [file1.asm ...]
"""

import re
import os
import sys
import subprocess
import tempfile
from pathlib import Path

# ── Paths ────────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).parent.resolve()
WORKING    = SCRIPT_DIR / 'working'
BIN_DIR    = SCRIPT_DIR / 'bin'

# ── Target files (relative to WORKING) ───────────────────────────────────────

TARGET_FILES = [
    # zelres1/code (skip drivers: 101-111 GD/GT files are graphics drivers)
    'zelres1/code/106TOWN.asm',
    'zelres1/code/124UTILA.asm',
    'zelres1/code/130UTILB.asm',
    # zelres2/code (skip 202-206 graphics drivers per user request)
    'zelres2/code/200FIGHT.asm',
    'zelres2/code/207MOLEB.asm',
    'zelres2/code/208SATNO.asm',
    'zelres2/code/209BOSQE.asm',
    'zelres2/code/210HELDA.asm',
    'zelres2/code/212TUMBA.asm',
    'zelres2/code/214LLAMA.asm',
    'zelres2/code/217PULPO.asm',
    'zelres2/code/236CMAP.asm',
    'zelres2/code/238STMP.asm',
    # zelres3/code
    'zelres3/code/314LVLRD.asm',
    'zelres3/code/316TILCL.asm',
    'zelres3/code/331MP50.asm',
    'zelres3/code/332MP51.asm',
    'zelres3/code/334MP60.asm',
    'zelres3/code/335MP61.asm',
    'zelres3/code/356LVGRP.asm',
]

# ── Binary extension mapping (mirrors build_all.py output_ext) ───────────────

def binary_ext(stem: str) -> str:
    """Return the compiled binary file extension for a given source stem."""
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s):       return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s): return '.mdt'
    return '.bin'

def find_bin(asm_path: Path) -> Path | None:
    """Locate the compiled binary for an ASM file."""
    parts  = asm_path.relative_to(WORKING).parts  # ('zelres1', 'code', '106TOWN.asm')
    subdir = parts[0]                              # 'zelres1' / 'zelres2' / 'zelres3'
    stem   = asm_path.stem
    ext    = binary_ext(stem)
    return BIN_DIR / subdir / (stem + ext)

# ── LST parsing ───────────────────────────────────────────────────────────────

# Reuse the proc/label-based LST→ASM line mapping from fix_db_jumps.py.
# We use it only as a coarse estimate; the real lookup is byte-content matching.
from fix_db_jumps import build_resolved_table, lst_to_asm_line

# LST lines with assembled byte dumps:
#   "   1413\t0CE2  83 3C FF\t\t\t     db  83h, ..."
_LST_BYTE_LINE = re.compile(
    r'^\s+(\d+)\s+([0-9A-F]{4})\s+((?:[0-9A-F]{2,4}\s+)*)',
)

# proc/label declarations (for build_resolved_table calibration)
_LST_PROC_LBL = re.compile(
    r'^\s+(\d+)\s+[0-9A-Fa-f]{4}\s+(\w+)\s+(proc|label)\b', re.I
)


def parse_lst_fixups(lst_text: str):
    """
    Parse a TASM .LST file.

    Returns:
      fixups       : list of dicts — one per "Fixup - byte match" db/dw line:
                       lst_lnum   int   — printed LST line number (used as ordering key)
                       offset     int   — binary offset from LST hex column
                       kind       str   — 'db' or 'dw'
                       raw_bytes  bytes — byte values encoded in the db/dw operand
      offset_table : raw list for build_resolved_table (proc/label calibration)
    """
    fixups       = []
    offset_table = []

    for line in lst_text.split('\n'):
        # Proc/label declarations for LST→ASM calibration
        m = _LST_PROC_LBL.match(line)
        if m:
            offset_table.append((int(m.group(1)), m.group(2), m.group(3).lower()))
            continue

        # Lines with byte dumps
        m = _LST_BYTE_LINE.match(line)
        if not m:
            continue

        lst_lnum   = int(m.group(1))
        offset     = int(m.group(2), 16)
        hex_tokens = m.group(3).split()
        rest       = line[m.end():].strip()

        if 'Fixup' not in rest and 'fixup' not in rest:
            continue

        if rest.lower().startswith('dw'):
            # dw tokens are 4-char (16-bit words in hex, little-endian in the file)
            raw = b''
            for tok in hex_tokens:
                if len(tok) == 4:
                    # LST shows words as big-endian display but stored little-endian:
                    # "9497" in LST → bytes 97 94 in binary... wait.
                    # TASM LST for "dw 9497h" shows the word value 9497h;
                    # in the binary file it is stored little-endian: 97 94.
                    # BUT the LST byte-dump column for words lists the ACTUAL bytes
                    # in memory order: "9497" = first byte 0x94, second byte 0x97.
                    # Empirically verified: binary at 0x3790 for dw 9497h,8E97h is
                    # 97 94 97 8E, and the LST column shows "9497 8E97".
                    # So the LST column is byte-swapped relative to the dw value.
                    # raw bytes: tok[2:4] tok[0:2]  (low byte first = little-endian)
                    raw += bytes([int(tok[2:4], 16), int(tok[0:2], 16)])
                elif len(tok) == 2:
                    raw += bytes([int(tok, 16)])
            fixups.append({
                'lst_lnum' : lst_lnum,
                'offset'   : offset,
                'kind'     : 'dw',
                'raw_bytes': raw,
            })

        elif rest.lower().startswith('db'):
            # db tokens are 2-char bytes
            raw = bytes(int(tok, 16) for tok in hex_tokens if len(tok) == 2)
            fixups.append({
                'lst_lnum' : lst_lnum,
                'offset'   : offset,
                'kind'     : 'db',
                'raw_bytes': raw,
            })

    return fixups, offset_table

# ── ASM source scanning ───────────────────────────────────────────────────────

_FIXUP_TAG = re.compile(r';\s*Fixup\s*-\s*byte\s*match', re.I)
_DB_LINE   = re.compile(r'^\s*db\b', re.I)
_DW_LINE   = re.compile(r'^\s*dw\b', re.I)


def extract_db_bytes(line: str) -> bytes:
    """
    Parse byte values from a db or dw source line, ignoring the comment.

    For db lines: each hex token is a byte (0x00–0xFF).
    For dw lines: each hex token is a 16-bit word stored little-endian.
    """
    code_part = line.split(';')[0]           # strip trailing comment
    result    = b''
    for tok in re.findall(r'0?([0-9A-Fa-f]+)h', code_part):
        val = int(tok, 16)
        if val > 0xFF:
            # 16-bit word → little-endian bytes
            result += bytes([val & 0xFF, (val >> 8) & 0xFF])
        else:
            result += bytes([val])
    return result


def build_asm_fixup_index(src_lines: list[str]) -> dict[bytes, list[int]]:
    """
    Build a map: raw_bytes → sorted list of 0-based ASM line indices that have
    a '; Fixup - byte match' comment and those bytes.

    Used to resolve which ASM line corresponds to each LST fixup entry.
    """
    index: dict[bytes, list[int]] = {}
    for idx, line in enumerate(src_lines):
        if not _FIXUP_TAG.search(line):
            continue
        if not (_DB_LINE.match(line) or _DW_LINE.match(line)):
            continue
        raw = extract_db_bytes(line)
        index.setdefault(raw, []).append(idx)
    return index

# ── ndisasm decoding ──────────────────────────────────────────────────────────

# Prefixes ndisasm decodes as standalone instructions but that attach to the next one
_PREFIX_WORDS = frozenset({
    'lock', 'rep', 'repe', 'repz', 'repne', 'repnz',
    'cs', 'ds', 'es', 'fs', 'gs', 'ss',
})

# Mnemonics that TASM 2.01 does NOT support → skip these fixups (leave as db).
# These are mainly SSE3+ / post-286 instructions that ndisasm may decode but
# TASM 2.01 cannot assemble.
_TASM201_UNSUPPORTED = frozenset({
    'fisttp',   # SSE3: integer store and pop (0xDD /1, 0xDB /1, 0xDF /1)
    'ud2',      # 286+: undefined instruction trap (0x0F 0x0B)
})


def decode_bytes(data: bytes, origin: int = 0) -> tuple[str | None, int]:
    """
    Decode the FIRST instruction (plus any leading prefix) from `data` using
    ndisasm -b 16 with the given origin address.

    Returns (tasm_mnemonic_string, bytes_consumed) or (None, 0) on failure.

    Special handling:
    - 0x82 opcode → replaced with 0x80 before decoding (sign-extended imm8 form
      that modern ndisasm doesn't support; functionally identical to 0x80).
    - Lock/rep prefix: merged with the following instruction line.
    """
    # Substitute 0x82 → 0x80 for ndisasm compatibility.
    # 0x82 is the sign-extended immediate form (functionally identical to 0x80 in 8086)
    # but modern ndisasm no longer supports it.  The substitution may appear after
    # prefix bytes (LOCK = F0, REP = F2/F3, segment overrides = 26/2E/36/3E/64/65).
    _PREFIX_BYTES = frozenset({
        0xF0, 0xF2, 0xF3,             # lock, repne, rep
        0x26, 0x2E, 0x36, 0x3E,       # ES, CS, SS, DS
        0x64, 0x65,                   # FS, GS
    })
    patched = bytearray(data)
    i = 0
    while i < len(patched) and patched[i] in _PREFIX_BYTES:
        i += 1
    if i < len(patched) and patched[i] == 0x82:
        patched[i] = 0x80

    with tempfile.NamedTemporaryFile(delete=False, suffix='.bin') as f:
        f.write(bytes(patched) + bytes(16))   # pad for safe decode
        tmp = f.name

    try:
        result = subprocess.run(
            ['ndisasm', '-b', '16', '-o', f'0x{origin:X}', tmp],
            capture_output=True, text=True, timeout=5,
        )
        lines = [l for l in result.stdout.split('\n') if l.strip()]
        if not lines:
            return None, 0

        def parse_line(text: str) -> tuple[str | None, int]:
            """Parse one ndisasm output line → (mnemonic, byte_count)."""
            parts = text.split(None, 2)
            if len(parts) < 3:
                return None, 0
            byte_hex = parts[1]
            instr    = parts[2].strip()
            nbytes   = len(byte_hex) // 2
            return instr, nbytes

        instr0, nb0 = parse_line(lines[0])
        if instr0 is None or nb0 == 0:
            return None, 0

        # Reject if ndisasm truly couldn't decode (returns "db 0xNN")
        if instr0.lower().startswith('db '):
            return None, 0

        # If the first "instruction" is a BARE prefix (one word only, e.g. "lock"),
        # merge with the following instruction line.  When ndisasm emits the prefix and
        # its target instruction together on one line (e.g. "lock add byte [bx+si],0x2"),
        # the line already has more than one word — don't merge again in that case.
        parts0    = instr0.split()
        first_word = parts0[0].lower()
        if first_word in _PREFIX_WORDS and len(parts0) == 1 and len(lines) >= 2:
            instr1, nb1 = parse_line(lines[1])
            if instr1 is not None and nb1 > 0 and not instr1.lower().startswith('db '):
                return instr0 + ' ' + instr1, nb0 + nb1

        return instr0, nb0

    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass

# ── ndisasm → TASM syntax conversion ─────────────────────────────────────────

# Mnemonic groups where 0xFF…-style immediates almost certainly mean -1
_SIGNED_IMM_OPS = frozenset({
    'cmp', 'sub', 'add', 'adc', 'sbb', 'and', 'or', 'xor', 'test', 'mov',
})
_ALL_ONES = {0xFF, 0xFFFF, 0xFFFFFFFF, 0xFFFFFFFFFFFFFFFF}


def _fmt_hex(raw_hex: str, mnemonic_word: str) -> str:
    """Format a hex value from ndisasm (raw_hex without '0x') as TASM literal."""
    val = int(raw_hex, 16)
    if val in _ALL_ONES and mnemonic_word.lower() in _SIGNED_IMM_OPS:
        return '-1'
    upper = raw_hex.upper()
    # TASM requires the literal to start with a digit (0-9), so add exactly one
    # leading zero if the value starts with a hex letter (A-F).
    if not upper[0].isdigit():
        return '0' + upper + 'h'
    return upper + 'h'


def ndisasm_to_tasm(instr: str) -> str:
    """
    Convert an ndisasm Intel-syntax mnemonic string to TASM-compatible syntax.

    Transformations:
      - Far jmp/call:  "jmp word 0xSEG:word 0xOFF" → "jmp far ptr OOOOh:SSSSh"
      - aam/aad:       drop spurious 'byte' keyword  ("aam byte 0xN" → "aam 0Nh")
      - Size specifiers: add 'ptr'  ("word [si]" → "word ptr [si]")
      - Hex literals:  "0xNN" → "0NNh"  (sign-extended -1 values → "-1")
      - FPU registers: "st0" → "st(0)", …, "st7" → "st(7)"
      - Segment override: "[cs:di]" → "cs:[di]"
    """
    mnemonic_word = instr.split()[0] if instr.split() else ''

    # ── far jmp/call immediate: "jmp word 0xSEG:word 0xOFF" ──────────────────
    m_far = re.match(
        r'^(jmp|call)\s+word\s+0x([0-9a-fA-F]+):word\s+0x([0-9a-fA-F]+)',
        instr, re.I,
    )
    if m_far:
        op  = m_far.group(1).lower()
        seg = m_far.group(2).upper()
        off = m_far.group(3).upper()
        # TASM requires hex literals to start with a digit: add one '0' prefix if needed
        seg_s = seg if seg[0].isdigit() else ('0' + seg)
        off_s = off if off[0].isdigit() else ('0' + off)
        return f'{op}\tfar ptr {off_s}h:{seg_s}h'

    # ── aam/aad: strip spurious 'byte' keyword ────────────────────────────────
    instr = re.sub(r'\b(aa[dm])\s+byte\s+', r'\1 ', instr, flags=re.I)

    # ── size specifiers: insert 'ptr' ─────────────────────────────────────────
    instr = re.sub(
        r'\b(byte|word|dword|qword|tword)\s+\[',
        r'\1 ptr [',
        instr, flags=re.I,
    )

    # ── hex literals: 0xNN → 0NNh ────────────────────────────────────────────
    instr = re.sub(
        r'0x([0-9a-fA-F]+)',
        lambda m: _fmt_hex(m.group(1), mnemonic_word),
        instr,
    )

    # ── FPU registers: st0..st7 → st(0)..st(7) ───────────────────────────────
    instr = re.sub(r'\bst([0-7])\b', r'st(\1)', instr)

    # ── Segment override in memory ref: [seg:expr] → seg:[expr] ──────────────
    instr = re.sub(r'\[(\w{2}):([^\]]+)\]', r'\1:[\2]', instr)

    return instr

# ── Per-file processing ───────────────────────────────────────────────────────

def fix_file(asm_path: Path, lst_path: Path, bin_path: Path,
             dry_run: bool = False) -> int:
    """
    Process one ASM file: replace all '; Fixup - byte match' db/dw lines with
    decoded mnemonics.  Returns the number of successful replacements.
    """
    src      = asm_path.read_text(errors='replace')
    lst_text = lst_path.read_text(errors='replace')
    bin_data = bin_path.read_bytes()

    src_lines = src.split('\n')

    # ── Parse LST for all fixup entries ──────────────────────────────────────
    fixups, raw_offset_table = parse_lst_fixups(lst_text)
    if not fixups:
        return 0

    # ── Coarse LST→ASM line mapping (for tie-breaking duplicate byte patterns) ─
    offset_table = build_resolved_table(raw_offset_table, src_lines)

    # ── Build index of all fixup db/dw lines in the ASM source ───────────────
    # Maps raw_bytes → [line_indices with that fixup pattern]
    asm_fixup_index = build_asm_fixup_index(src_lines)

    # Track which ASM line indices have already been claimed by earlier fixups
    # (to handle duplicate byte patterns, e.g. two "83 FB FF" fixups).
    claimed: set[int] = set()

    def resolve_asm_idx(fx: dict) -> int | None:
        """
        Find the ASM line index for a fixup entry.

        Strategy:
          1. Look up all ASM fixup lines whose extracted bytes match fx['raw_bytes'].
          2. Among unclaimed matches, pick the one whose ASM line number is closest
             to the coarse LST-estimated ASM line (to handle duplicates).
          3. Mark the chosen index as claimed.
        """
        raw       = fx['raw_bytes']
        candidates = [i for i in asm_fixup_index.get(raw, []) if i not in claimed]
        if not candidates:
            return None

        # Coarse estimate from LST line number
        est_asm = lst_to_asm_line(fx['lst_lnum'], offset_table) - 1

        # Pick closest to estimate
        best = min(candidates, key=lambda i: abs(i - est_asm))
        claimed.add(best)
        return best

    # ── Sort fixups in REVERSE ASM order so replacements don't shift indices ──
    # Pre-resolve all to stable indices first, then sort.
    resolved: list[tuple[int, dict]] = []
    for fx in fixups:
        idx = resolve_asm_idx(fx)
        if idx is not None:
            resolved.append((idx, fx))
        else:
            print(f'  SKIP  {asm_path.name} LST line {fx["lst_lnum"]}: '
                  f'no unclaimed ASM fixup line with bytes {fx["raw_bytes"].hex()}')

    resolved.sort(key=lambda t: t[0], reverse=True)

    # ── Apply replacements ────────────────────────────────────────────────────
    replacements = 0

    for asm_idx, fx in resolved:
        offset   = fx['offset']
        kind     = fx['kind']
        expected = fx['raw_bytes']

        # Verify binary contents at the recorded offset
        if offset + len(expected) > len(bin_data):
            print(f'  SKIP  {asm_path.name} LST line {fx["lst_lnum"]}: '
                  f'offset 0x{offset:04X}+{len(expected)} beyond binary')
            continue

        actual = bin_data[offset:offset + len(expected)]
        if actual != expected:
            print(f'  SKIP  {asm_path.name} LST line {fx["lst_lnum"]}: '
                  f'binary mismatch at 0x{offset:04X}: '
                  f'LST={expected.hex()} binary={actual.hex()}')
            continue

        line   = src_lines[asm_idx]
        indent = re.match(r'^(\s*)', line).group(1)

        if kind == 'db':
            # Read bytes from binary (up to 8, bounded by fixup size) and decode
            chunk = bin_data[offset:offset + min(len(expected), 8)]
            instr, nbytes = decode_bytes(chunk, origin=offset)

            if instr is None or nbytes == 0:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'ndisasm could not decode {chunk.hex()} at 0x{offset:04X}')
                continue

            # Reject if ndisasm consumed bytes beyond what the fixup declares —
            # that means it read into the zero-padding added by decode_bytes,
            # implying the real instruction is larger than this fixup's byte range.
            if nbytes > len(expected):
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'decoded {nbytes} bytes > fixup size {len(expected)} '
                      f'(instruction spans beyond fixup boundary)')
                continue

            if nbytes > 8:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'decoded {nbytes} bytes (>8), suspicious')
                continue

            # Reject mnemonics that TASM 2.01 cannot assemble
            first_mnemonic = instr.split()[0].lower()
            if first_mnemonic in _TASM201_UNSUPPORTED:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'mnemonic {first_mnemonic!r} not supported by TASM 2.01')
                continue

            tasm_instr  = ndisasm_to_tasm(instr)
            was_comment = ','.join(f'0{b:02X}h' for b in expected[:nbytes])

            # Any bytes in the fixup beyond the first instruction remain as db
            trailing = expected[nbytes:]
            new_line  = f'{indent}\t\t{tasm_instr}\t\t\t; was: db {was_comment}'
            if trailing:
                t_bytes = ','.join(f'0{b:02X}h' for b in trailing)
                new_line += f'\n{indent}db\t{t_bytes}'

            src_lines[asm_idx] = new_line
            replacements += 1

        elif kind == 'dw':
            # dw fixup: the actual opcode byte is at offset-1 in the binary.
            # The preceding ASM line should be a bare "db 0EAh" or "db 9Ah".
            opcode_off = offset - 1
            if opcode_off < 0:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: dw offset-1 < 0')
                continue

            opcode_byte = bin_data[opcode_off]
            if opcode_byte not in (0xEA, 0x9A):
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'byte before dw is 0x{opcode_byte:02X}, not 0xEA/0x9A')
                continue

            # Find the preceding bare-db opcode line (no fixup tag)
            opcode_idx = None
            for delta in (-1, -2, 1, -3):
                idx = asm_idx + delta
                if 0 <= idx < len(src_lines):
                    candidate = src_lines[idx].strip()
                    if (re.match(r'^db\s', candidate, re.I)
                            and not _FIXUP_TAG.search(candidate)):
                        # Verify it holds the expected opcode byte
                        src_opcode = extract_db_bytes(src_lines[idx])
                        if src_opcode == bytes([opcode_byte]):
                            opcode_idx = idx
                            break

            if opcode_idx is None:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'cannot find preceding db 0x{opcode_byte:02X} opcode line')
                continue

            # Decode all 5 bytes (opcode + 4-byte far address) together
            chunk = bin_data[opcode_off:opcode_off + 5]
            instr, nbytes = decode_bytes(chunk, origin=opcode_off)

            if instr is None or nbytes != 5:
                print(f'  SKIP  {asm_path.name} ASM line {asm_idx+1}: '
                      f'ndisasm decode failed for {chunk.hex()} '
                      f'(got {nbytes} bytes, expected 5)')
                continue

            tasm_instr  = ndisasm_to_tasm(instr)
            was_opcode  = f'0{opcode_byte:02X}h'
            was_dw      = ','.join(f'0{b:02X}h' for b in expected)
            indent      = re.match(r'^(\s*)', src_lines[opcode_idx]).group(1)

            new_line = (
                f'{indent}\t\t{tasm_instr}'
                f'\t\t\t; was: db {was_opcode} + dw {was_dw}'
            )

            # Remove the two original lines (higher index first, then lower)
            hi, lo = sorted([asm_idx, opcode_idx], reverse=True)
            src_lines.pop(hi)
            src_lines[lo] = new_line
            replacements += 1

    if not dry_run and replacements > 0:
        asm_path.write_text('\n'.join(src_lines))

    return replacements

# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    dry_run   = '--dry-run' in sys.argv
    args      = [a for a in sys.argv[1:] if not a.startswith('--')]
    file_list = args if args else TARGET_FILES

    total = 0

    for rel in file_list:
        asm_path = WORKING / rel
        stem     = asm_path.stem.upper()
        lst_path = asm_path.parent / f'{stem}.LST'
        bin_path = find_bin(asm_path)

        if not asm_path.exists():
            print(f'SKIP (no asm):    {rel}')
            continue
        if not lst_path.exists():
            print(f'SKIP (no lst):    {rel}')
            continue
        if bin_path is None or not bin_path.exists():
            print(f'SKIP (no binary): {rel}  (expected: {bin_path})')
            continue

        n = fix_file(asm_path, lst_path, bin_path, dry_run=dry_run)
        if n:
            tag = '(dry-run) ' if dry_run else ''
            print(f'{tag}{asm_path.name}: {n} replacement(s)')
        total += n

    print(f'\nTotal: {total} replacement(s)')

    if total > 0 and not dry_run:
        print('\nRunning build_all.py --verify ...')
        result = subprocess.run(
            ['python3', str(SCRIPT_DIR / 'build_all.py'), '--verify'],
            cwd=str(SCRIPT_DIR),
        )
        if result.returncode == 0:
            print('build_all.py --verify PASSED — SARs are bit-perfect.')
        else:
            print('build_all.py --verify FAILED — check output above.')
            sys.exit(1)


if __name__ == '__main__':
    main()
