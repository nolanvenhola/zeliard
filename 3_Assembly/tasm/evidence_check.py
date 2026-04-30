#!/usr/bin/env python3
"""
evidence_check.py - Gather deterministic evidence for contested symbol names.

Both Claude's cleanup work and the friend's IDA-based work use LLM
interpretation. To validate names without trusting either LLM, this tool
gathers evidence from the BINARY itself:

  E1. Initial byte value at the address (from the .bin chunk).
  E2. Strings within ±100 bytes in the same chunk.
  E3. Read/write sites in the cleaned ASM (where the address is referenced).
  E4. DOS/BIOS interrupts in the referencing functions.
  E5. Hardware port I/O (in/out) in the referencing functions.
  E6. Numeric patterns: bytes that match documented enum values from
      common.inc (e.g. SWORD_TRAINING=1 — a byte starting at 1 is consistent
      with sword_type but not with sword_HP which starts higher).

Per-claim verdict:
  - SUPPORTED:    deterministic evidence aligns with the claim
  - CONTRADICTED: evidence rules out the claim
  - INCONCLUSIVE: not enough evidence to judge

Usage:
    python evidence_check.py             # run on all contested addresses
    python evidence_check.py --addr 0x90 # check a single address
"""

import re
import os
import argparse
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
BIN = ROOT / 'bin'
IDA = ROOT.parent / 'ida'
FLAT = ROOT / 'research' / 'flatfiles'

# Map common chunk-prefix → location of the binary
CHUNK_BIN_HINTS = {
    'stdply': BIN / 'stdply.bin',
    'stick': BIN / 'stick.bin',
    'game': BIN / 'game.bin',
    'zeliad': BIN / 'zeliad.exe',
    'gmcga': BIN / 'gmcga.bin',
    'gmega': BIN / 'gmega.bin',
    'gmhgc': BIN / 'gmhgc.bin',
    'gmmcga': BIN / 'gmmcga.bin',
    'gmtga': BIN / 'gmtga.bin',
}

# Flat file locations (IDA-native, no SAR header) and their CPU load base.
# IDA's "org N" line determines load_base; file_offset N maps to CPU (load_base + N).
FLAT_BIN_HINTS = {
    'fight':   (FLAT / 'ZELRES2' / 'fight.bin',   0x6000),
    'town':    (FLAT / 'ZELRES1' / 'town.bin',    0x6000),
    'select':  (FLAT / 'ZELRES2' / 'select.bin',  0xA000),
    'mole':    (FLAT / 'ZELRES2' / 'mole.bin',    0x0100),
    'crab':    (FLAT / 'ZELRES3' / 'CRAB.BIN',    0xA000),
    'eai1':    (FLAT / 'ZELRES3' / 'EAI1.BIN',    0xA000),
    'gmmcga':  (FLAT / 'ZELRES1' / 'gmmcga.bin',  0x2000),
    'gdmcga':  (FLAT / 'ZELRES1' / 'gdmcga.bin',  0x3000),
    'gfmcga':  (FLAT / 'ZELRES2' / 'gfmcga.bin',  0x3000),
    'gtmcga':  (FLAT / 'ZELRES1' / 'gtmcga.bin',  0x3000),
    'ckpd':    (FLAT / 'ZELRES2' / 'CKPD.BIN',    0x0100),
    'ympd':    (FLAT / 'ZELRES2' / 'YMPD.BIN',    0x0100),
}

# Enum constants from IDA common.inc (deterministic — they're literal numeric
# values defined in the code) — anything matching these provides evidence.
COMMON_ENUMS = {
    'SWORD_TRAINING':     1,
    'SWORD_WISE_MANS':    2,
    'SWORD_SPIRIT':       3,
    'SWORD_KNIGHT':       4,
    'SWORD_ILLUMINATION': 5,
    'SWORD_ENCHANTMENT':  6,
    'SHIELD_CLAY':        1,
    'SHIELD_WISE_MANS':   2,
    'LEFT':               1,
    'UP':                 2,
    'KEY_ENTER':          1,
}


def load_bytes(path):
    """Return file bytes or empty bytes if missing."""
    if not path.exists():
        return b''
    return path.read_bytes()


def find_strings_in_chunk(data, addr, window=100):
    """Find ASCII strings within addr ± window."""
    lo, hi = max(0, addr - window), min(len(data), addr + window + 1)
    out = []
    i = lo
    while i < hi:
        # Find a printable run >= 4 chars
        if 0x20 <= data[i] < 0x7F:
            j = i
            while j < hi and 0x20 <= data[j] < 0x7F:
                j += 1
            run = data[i:j]
            if len(run) >= 4:
                out.append((i, run.decode('ascii', errors='replace')))
            i = j
        else:
            i += 1
    return out


def find_refs_in_asm(asm_path, addr_hex_options):
    """Find source lines that reference any of the address-hex variants.

    Returns list of (line_num, line, kind) where kind is 'read', 'write', or 'call'.
    """
    if not asm_path.exists():
        return []
    out = []
    text = asm_path.read_text(encoding='utf-8')
    lines = text.split('\n')
    for ln, line in enumerate(lines, 1):
        # Strip comment
        no_comment = re.sub(r';.*', '', line)
        if not no_comment.strip():
            continue
        # Check each address variant
        for ahex in addr_hex_options:
            # Match patterns like [<addr>], cs:[<addr>], ds:<addr>, equal to <addr>
            if re.search(rf'\b{ahex}\b', no_comment, re.I):
                kind = 'ref'
                # Crude write detection: appears as destination in mov
                if re.search(rf'mov\s+(?:byte\s+ptr\s+)?(?:word\s+ptr\s+)?(?:cs:|ds:|es:)?\[?{ahex}', no_comment, re.I):
                    kind = 'write'
                elif re.search(rf'(?:call|jmp)\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[?{ahex}', no_comment, re.I):
                    kind = 'call'
                else:
                    kind = 'read'
                out.append((ln, line.rstrip(), kind))
                break  # only count once per line
    return out


def find_proc_at_line(asm_path, line_num):
    """Walk back from line_num to find the enclosing proc/label."""
    if not asm_path.exists():
        return None
    text = asm_path.read_text(encoding='utf-8')
    lines = text.split('\n')
    for i in range(line_num - 1, -1, -1):
        if i >= len(lines):
            continue
        m = re.match(r'^([a-zA-Z_]\w*)\s+proc\s+(?:near|far)', lines[i])
        if m:
            return m.group(1)
        m = re.match(r'^([a-zA-Z_]\w*)\s*:', lines[i])
        if m:
            return m.group(1)
    return None


def find_proc_body(asm_path, proc_name):
    """Extract the body of a proc by name."""
    if not asm_path.exists() or not proc_name:
        return ''
    text = asm_path.read_text(encoding='utf-8')
    pattern = rf'^{re.escape(proc_name)}\s+proc\s+(?:near|far).*?^{re.escape(proc_name)}\s+endp'
    m = re.search(pattern, text, re.M | re.S)
    if m:
        return m.group(0)
    # Or label-style: from `proc_name:` to next proc/endp
    pattern = rf'^{re.escape(proc_name)}\s*:.*?(?=^\w+\s+(?:proc|endp)|^\w+\s*:)'
    m = re.search(pattern, text, re.M | re.S)
    if m:
        return m.group(0)
    return ''


def detect_int_calls(body):
    """Find INT NN calls and return a list of (int_num, function_byte)."""
    found = []
    # `mov ah, NN` then `int 21h` style
    for m in re.finditer(r'mov\s+ah\s*,\s*([0-9a-fA-F]+h?).*?\n.*?int\s+([0-9a-fA-F]+h?)', body, re.I | re.S):
        ah = int(m.group(1).rstrip('hH'), 16)
        intn = int(m.group(2).rstrip('hH'), 16)
        found.append((intn, ah))
    # also raw `int NNh` mentions
    for m in re.finditer(r'int\s+([0-9a-fA-F]+h?)\b', body, re.I):
        intn = int(m.group(1).rstrip('hH'), 16)
        if not any(n == intn for n, _ in found):
            found.append((intn, None))
    return found


def detect_port_io(body):
    """Find IN/OUT to specific ports."""
    found = []
    for m in re.finditer(r'\b(in|out)\s+(?:al|ax|dx)\s*,\s*(?:al|ax|dx|([0-9a-fA-F]+h?))', body, re.I):
        op = m.group(1).lower()
        if m.group(2):
            port = int(m.group(2).rstrip('hH'), 16)
            found.append((op, hex(port)))
        else:
            found.append((op, 'dx'))
    return found


def addr_hex_variants(addr):
    """Return common hex spellings of an integer address for grep-style match."""
    out = set()
    out.add(f'{addr:X}h')
    out.add(f'{addr:x}h')
    out.add(f'0{addr:X}h')
    out.add(f'0{addr:x}h')
    out.add(f'{addr:04X}h')
    out.add(f'{addr:04x}h')
    return list(out)


def gather_evidence(file_stem, addr, claim_label='?'):
    """Return a dict of evidence for an (asm-file-stem, address) pair."""
    asm_path = None
    bin_path = None
    # Find the .asm file
    for d in ['core', 'drivers', 'zelres1/code', 'zelres2/code', 'zelres3/code']:
        p = WORKING / d / f'{file_stem}.asm'
        if p.exists():
            asm_path = p
            break
    # Find the bin
    bin_path = CHUNK_BIN_HINTS.get(file_stem.lower())
    if not bin_path or not bin_path.exists():
        # Try by zelresN/<stem>.bin
        for d in ['zelres1', 'zelres2', 'zelres3']:
            p = BIN / d / f'{file_stem}.bin'
            if p.exists():
                bin_path = p
                break

    ev = {'file': file_stem, 'addr': addr, 'claim': claim_label}

    # E1: initial byte value
    if bin_path and bin_path.exists():
        data = bin_path.read_bytes()
        ev['bin_size'] = len(data)
        if 0 <= addr < len(data):
            byte_val = data[addr]
            ev['init_byte'] = byte_val
            # Match against known enums
            matches = [k for k, v in COMMON_ENUMS.items() if v == byte_val]
            ev['enum_matches'] = matches
        else:
            ev['init_byte'] = None
    else:
        ev['init_byte'] = None
        ev['enum_matches'] = []

    # E2: nearby strings
    if bin_path and bin_path.exists():
        ev['nearby_strings'] = find_strings_in_chunk(data, addr, 100)
    else:
        ev['nearby_strings'] = []

    # E3: code references
    refs = find_refs_in_asm(asm_path, addr_hex_variants(addr)) if asm_path else []
    ev['refs'] = refs

    # E4/E5: per-referencing-proc, look for INT and IN/OUT
    procs = set()
    for ln, _, _ in refs:
        p = find_proc_at_line(asm_path, ln)
        if p:
            procs.add(p)
    ev['referencing_procs'] = sorted(procs)
    int_calls = []
    port_ops = []
    for p in procs:
        body = find_proc_body(asm_path, p)
        for ic in detect_int_calls(body):
            int_calls.append((p, ic))
        for po in detect_port_io(body):
            port_ops.append((p, po))
    ev['int_calls'] = int_calls
    ev['port_ops'] = port_ops

    return ev


def render_evidence(ev):
    """Format evidence into markdown."""
    out = []
    out.append(f'### `{ev["file"]}` @ `0x{ev["addr"]:X}` — claim: *{ev["claim"]}*')
    out.append('')
    if ev.get('init_byte') is not None:
        bv = ev["init_byte"]
        out.append(f'- **Initial byte:** `0x{bv:02X}` = `{bv}` decimal')
        if ev.get('enum_matches'):
            out.append(f'  - Matches enum: {", ".join("`" + m + "`" for m in ev["enum_matches"])}')
    else:
        out.append('- Initial byte: (out of bin range)')
    if ev.get('nearby_strings'):
        out.append(f'- **Strings within ±100 bytes** ({len(ev["nearby_strings"])}):')
        for off, s in ev['nearby_strings'][:5]:
            out.append(f'  - `{s.strip()}` @ +{off-ev["addr"]:+d}')
    refs = ev.get('refs', [])
    out.append(f'- **Code references in {ev["file"]}.asm:** {len(refs)}')
    for ln, line, kind in refs[:6]:
        out.append(f'  - L{ln} *{kind}* — `{line.strip()[:80]}`')
    if len(refs) > 6:
        out.append(f'  - ...and {len(refs) - 6} more')
    if ev.get('referencing_procs'):
        out.append(f'- **Referencing procs:** {", ".join("`" + p + "`" for p in ev["referencing_procs"][:8])}')
    if ev.get('int_calls'):
        ints = sorted(set((ic[0], ic[1][0], ic[1][1]) for ic in ev['int_calls']))
        out.append(f'- **DOS/BIOS calls in those procs:**')
        for p, n, ah in ints[:6]:
            ah_str = f'fn 0x{ah:X}' if ah is not None else '(no ah set)'
            out.append(f'  - `{p}` calls INT 0x{n:X} {ah_str}')
    if ev.get('port_ops'):
        ports = sorted(set((po[0], po[1][0], po[1][1]) for po in ev['port_ops']))
        out.append(f'- **Port I/O in those procs:**')
        for p, op, port in ports[:6]:
            out.append(f'  - `{p}` does `{op} {port}`')
    out.append('')
    return '\n'.join(out)


# ----------------------------------------------------------------------
# Verdict heuristics
# ----------------------------------------------------------------------

def verdict_supports_hp(ev):
    """A 'hero_HP' style claim is supported if init_byte is in plausible HP range
    (16..255) AND we see referencing procs that don't look driver-state-y."""
    bv = ev.get('init_byte')
    if bv is None:
        return None
    if bv < 16 or bv > 200:
        return ('CONTRADICTED', f'init byte 0x{bv:02X}={bv} outside plausible HP range')
    return ('SUPPORTED', f'init byte 0x{bv:02X}={bv} in HP range; matches manual\'s starting HP if 0x50=80')


def verdict_supports_gold(ev):
    """A 'hero_gold_*' claim is supported if init_byte is 0 (start with no gold)."""
    bv = ev.get('init_byte')
    if bv is None:
        return None
    if bv == 0:
        return ('SUPPORTED', f'init byte = 0x00, consistent with starting with 0 gold')
    return ('CONTRADICTED', f'init byte = 0x{bv:02X}, hero should start with 0 gold')


def verdict_supports_sword_type(ev):
    """A 'sword_type' claim is supported if init_byte matches SWORD_TRAINING (1)."""
    bv = ev.get('init_byte')
    if bv is None:
        return None
    if bv == 1:  # SWORD_TRAINING
        return ('SUPPORTED', f'init byte = 1 = SWORD_TRAINING (matches manual\'s starting weapon)')
    if 0 <= bv <= 6:  # any sword type is plausible
        return ('SUPPORTED', f'init byte = {bv}, in sword-type enum range')
    return ('CONTRADICTED', f'init byte = 0x{bv:02X}, outside sword-type enum range')


def verdict_supports_shield(ev):
    """A 'shield_*' claim is supported if init_byte = 0 (no shield)."""
    bv = ev.get('init_byte')
    if bv is None:
        return None
    if bv == 0:
        return ('SUPPORTED', f'init byte = 0, consistent with no starting shield')
    return ('INCONCLUSIVE', f'init byte = 0x{bv:02X}; could be shield_HP for non-zero shield')


# Map claim categories to their verdict functions
VERDICT_FNS = {
    'hero_HP':           verdict_supports_hp,
    'shield_HP':         verdict_supports_hp,
    'hero_gold_hi':      verdict_supports_gold,
    'hero_gold_lo':      verdict_supports_gold,
    'hero_almas':        verdict_supports_gold,
    'sword_type':        verdict_supports_sword_type,
    'shield_type':       verdict_supports_shield,
    'current_magic_spell': verdict_supports_shield,
}


# ======================================================================
# PHASE 2 — Code-pointer (dispatch slot) validation
# ======================================================================
#
# A dispatch slot at addr S in a binary holds a word value T = the entry
# point of some procedure. To validate a claim like "S holds the addr of
# move_monster_E", we:
#   (1) Read the slot's word value T from the flat (header-stripped) file.
#   (2) Compute file_offset(T) = T - load_base.
#   (3) Compare bytes at that offset against an expected byte signature
#       associated with the claimed name (e.g. for move_monster_E,
#       80 7C 03 22 F5 73 01 C3 = `cmp [si+3],22h / cmc / jnb +1 / ret`).
#
# In addition to per-name signature match, we test the STRUCTURAL claim:
#   the 8 move_monster_* slots split into 3 byte-pattern groups (east,
#   west, vertical) that match the 3 directional groupings IDA's labels
#   imply. Group consistency is far stronger evidence than any single
#   signature match because it survives an LLM mis-labeling any one slot.
# ----------------------------------------------------------------------

# Byte signatures keyed by IDA's claimed function name.
#
# Format:  [(file_offset, expected_byte), ...]  — sparse constraints; only
# the listed offsets must match (others are wildcards). This handles the
# common case where part of a function is universal (e.g. a `mov ax,[si+2]
# / call coords_to_proximity_addr` prologue) but the rel16 call's offset
# bytes vary, with direction-specific instructions resuming after.
#
# Value tuple: (constraint_list, mnemonic_explanation).
def _sig_bytes(hex_str):
    """Helper: contiguous byte sequence -> [(0, b0), (1, b1), ...]"""
    bs = bytes.fromhex(hex_str.replace(' ', ''))
    return [(i, b) for i, b in enumerate(bs)]


EXPECTED_SIGNATURES = {
    # ---- fight.bin: 8 directional movers (validated in earlier session) ----
    # East-going move_monster_* — bound check m_x_rel<34, then incrementX
    # `cmp [si+3], 22h / cmc / jnb +1 / ret`
    'move_monster_E':  (_sig_bytes('80 7C 03 22 F5 73 01 C3'),
                        'cmp [si+3],22h / cmc / jnb +1 / ret'),
    'move_monster_NE': (_sig_bytes('80 7C 03 22 F5 73 01 C3'),
                        'cmp [si+3],22h / cmc / jnb +1 / ret'),
    'move_monster_SE': (_sig_bytes('80 7C 03 22 F5 73 01 C3'),
                        'cmp [si+3],22h / cmc / jnb +1 / ret'),
    # West-going — different bound check (no cmc), m_x_rel<2 returns
    # `cmp [si+3], 02h / jnb +1 / ret`
    'move_monster_W':  (_sig_bytes('80 7C 03 02 73 01 C3'),
                        'cmp [si+3],02h / jnb +1 / ret'),
    'move_monster_NW': (_sig_bytes('80 7C 03 02 73 01 C3'),
                        'cmp [si+3],02h / jnb +1 / ret'),
    'move_monster_SW': (_sig_bytes('80 7C 03 02 73 01 C3'),
                        'cmp [si+3],02h / jnb +1 / ret'),
    # Vertical-only (N, S) — different test pattern, reads m_y_rel
    # `mov al,[si+3] / or al,al / stc / jnz +1 / ret`
    'move_monster_N':  (_sig_bytes('8A 44 03 0A C0 F9 75 01 C3'),
                        'mov al,[si+3] / or al,al / stc / jnz +1 / ret'),
    'move_monster_S':  (_sig_bytes('8A 44 03 0A C0 F9 75 01 C3'),
                        'mov al,[si+3] / or al,al / stc / jnz +1 / ret'),

    # ---- fight.bin: 8 collision-check_*2 functions ----
    # Universal prefix (all 8): `mov ax,[si+2] / call coords_to_proximity_addr`
    # at offset 0..3 = 8B 44 02 E8. Bytes 4..5 are the rel16 call offset, which
    # varies. Direction-specific instructions resume at offset 6.
    # E2/NE2/SE2: inc di / inc di (bytes 6-7 = 47 47), then check (+2,0).
    'check_collision_E2': (_sig_bytes('8B 44 02 E8') + [(6, 0x47), (7, 0x47)],
        'mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di'),
    'check_collision_NE2': (_sig_bytes('8B 44 02 E8') + [(6, 0x47), (7, 0x47)],
        'mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di'),
    'check_collision_SE2': (_sig_bytes('8B 44 02 E8') + [(6, 0x47), (7, 0x47)],
        'mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di'),
    # W2/NW2: dec di once (byte 6 = 4F).  W2 then `call rel16` (E8); NW2 reads
    # `mov al,[di]` (8A 05) at +1, +2 — both share `4F` at offset 6.
    'check_collision_W2': (_sig_bytes('8B 44 02 E8') + [(6, 0x4F), (7, 0xE8)],
        'mov ax,[si+2] / call coords_to_addr / [..] / dec di / call'),
    'check_collision_NW2': (_sig_bytes('8B 44 02 E8') + [(6, 0x4F), (7, 0x8A), (8, 0x05)],
        'mov ax,[si+2] / call coords_to_addr / [..] / dec di / mov al,[di]'),
    # SW2: dec di twice (4F 4F).  Distinct from W2 (single dec) and NW2.
    'check_collision_SW2': (_sig_bytes('8B 44 02 E8') + [(6, 0x4F), (7, 0x4F)],
        'mov ax,[si+2] / call coords_to_addr / [..] / dec di / dec di'),
    # N2: `xchg si,di / sub si,36`  -> 87 F7 83 EE 24 at offset 6..10
    'check_collision_N2': (_sig_bytes('8B 44 02 E8') +
                           [(6, 0x87), (7, 0xF7), (8, 0x83), (9, 0xEE), (10, 0x24)],
        'mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / sub si,36'),
    # S2: `xchg si,di / add si,72`  -> 87 F7 83 C6 48 at offset 6..10
    'check_collision_S2': (_sig_bytes('8B 44 02 E8') +
                           [(6, 0x87), (7, 0xF7), (8, 0x83), (9, 0xC6), (10, 0x48)],
        'mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / add si,72'),

    # ---- town.bin: high-confidence dispatch slots ----
    # town_entry_normal: `mov cs:[disable_edge_scroll], 0` at addr 0x7C43.
    # `2E C6 06 43 7C 00` = mov byte ptr cs:[7C43h], 0  — distinctive CS-write.
    'town_entry_normal':
        (_sig_bytes('2E C6 06 43 7C 00'),
         'mov cs:byte ptr [7C43h], 0  ; clear disable_edge_scroll'),
    # town_entry_init: same target byte addr 0x7C43, but writes 0FFh then jumps.
    # `2E C6 06 43 7C FF EB 06` = mov [7C43h],FFh ; jmp short town_entry_common
    'town_entry_init':
        (_sig_bytes('2E C6 06 43 7C FF EB 06'),
         'mov cs:byte ptr [7C43h], 0FFh / jmp short town_entry_common'),
    # check_gold_sufficient: reads hero_gold_hi at DS:0x85 (cross-module
    # reference to a Phase-1-validated address — strong evidence).
    # `8A 1E 85 00 2A DA 73 01 C3` = mov bl,[85h] / sub bl,bl / jnb +1 / ret
    'check_gold_sufficient':
        (_sig_bytes('8A 1E 85 00 2A DA 73 01 C3'),
         'mov bl, ds:[85h] (hero_gold_hi) / sub bl,bl / jnb +1 / ret'),
    # add_gold_to_hero: writes hero_gold_lo (0x86) and hero_gold_hi (0x85) —
    # validates BOTH the function name AND the Phase-1 hero_gold rename.
    # `01 06 86 00 10 16 85 00 C3` = add [86],ax / adc [85],dx / ret
    'add_gold_to_hero':
        (_sig_bytes('01 06 86 00 10 16 85 00 C3'),
         'add ds:[86h],ax / adc ds:[85h],dx / ret  ; gold_lo += AX, gold_hi += DX+CF'),
    # restore_game: calls mscadlib driver (INT 60h) function 3. INT 60h is the
    # game's audio driver entry; function 3 = restore audio state on load.
    # bytes [2..6] = `B8 03 00 CD 60` = mov ax,3 / int 60h
    'restore_game':
        ([(2, 0xB8), (3, 0x03), (4, 0x00), (5, 0xCD), (6, 0x60)],
         'mov ax, 3 / int 60h  ; mscadlib (audio driver) restore-state call'),
}

# Structural family memberships — used for cross-claim consistency check.
# Each family lists names whose function bodies should share a byte-prefix.
# `prefix_len` is the number of leading bytes that must agree across members.
# (Some families compare bytes that span past a rel16 call — see notes.)
DIRECTION_FAMILIES = {
    # move_monster_* — first 8 bytes of the body are direction-specific
    # bound-check + return; identical inside each direction-family.
    'move_east_x':   {'members': ['move_monster_E', 'move_monster_NE', 'move_monster_SE'],
                      'prefix_len': 8},
    'move_west_x':   {'members': ['move_monster_W', 'move_monster_NW', 'move_monster_SW'],
                      'prefix_len': 7},
    'move_vertical': {'members': ['move_monster_N', 'move_monster_S'],
                      'prefix_len': 9},
    # check_collision_*2 — bytes 0..3 (`8B 44 02 E8`) are universal across all 8;
    # bytes 4..5 are a rel16 call offset that varies per function. The first
    # 4 bytes are sufficient to confirm "this is a collision-check function."
    'collision_universal':
        {'members': ['check_collision_E2', 'check_collision_W2',
                     'check_collision_N2', 'check_collision_S2',
                     'check_collision_NE2', 'check_collision_SE2',
                     'check_collision_NW2', 'check_collision_SW2'],
         'prefix_len': 4},
}


def read_slot_word(file_stem, slot_addr):
    """Return (slot_value, load_base, flat_path) for a dispatch slot.

    Reads the flat (header-stripped) file and pulls the word at
    file_offset = slot_addr - load_base.
    """
    info = FLAT_BIN_HINTS.get(file_stem)
    if not info:
        return None, None, None
    flat_path, load_base = info
    if not flat_path.exists():
        return None, load_base, flat_path
    data = flat_path.read_bytes()
    fo = slot_addr - load_base
    if fo < 0 or fo + 1 >= len(data):
        return None, load_base, flat_path
    return data[fo] | (data[fo + 1] << 8), load_base, flat_path


def read_bytes_at_addr(file_stem, addr, length=12):
    """Return up to `length` bytes at CPU `addr` in the flat file."""
    info = FLAT_BIN_HINTS.get(file_stem)
    if not info:
        return b''
    flat_path, load_base = info
    if not flat_path.exists():
        return b''
    data = flat_path.read_bytes()
    fo = addr - load_base
    if fo < 0 or fo >= len(data):
        return b''
    return data[fo:fo + length]


def _signature_template_str(constraints):
    """Render a sparse [(off, byte), ...] constraint list as a hex template
    with `??` for unspecified bytes."""
    if not constraints:
        return ''
    max_off = max(off for off, _ in constraints)
    cmap = {off: b for off, b in constraints}
    parts = [f'{cmap[i]:02X}' if i in cmap else '??' for i in range(max_off + 1)]
    return ' '.join(parts)


def _check_signature(target_bytes, constraints):
    """Return True if every (offset, expected_byte) constraint is satisfied;
    False otherwise. Bytes at unspecified offsets are wildcards."""
    if not constraints:
        return False
    for off, expected in constraints:
        if off >= len(target_bytes) or target_bytes[off] != expected:
            return False
    return True


def gather_code_evidence(file_stem, slot_addr, claim_name):
    """Validate that the dispatch slot at slot_addr holds the addr of `claim_name`.

    Evidence:
      - C1. Slot value reads cleanly (target addr in plausible range).
      - C2. Bytes at target satisfy every byte constraint of the claim's
            expected signature (sparse offset → byte map; allows wildcards
            for variable bytes like rel16 call offsets).
    """
    ev = {
        'kind':       'code_pointer',
        'file':       file_stem,
        'slot_addr':  slot_addr,
        'claim':      claim_name,
    }
    slot_val, load_base, flat_path = read_slot_word(file_stem, slot_addr)
    ev['slot_value'] = slot_val
    ev['load_base']  = load_base
    ev['flat_path']  = str(flat_path) if flat_path else None
    if slot_val is None:
        return ev
    # Read enough bytes to cover any reasonable signature.
    target_bytes = read_bytes_at_addr(file_stem, slot_val, length=24)
    ev['target_bytes'] = target_bytes
    sig = EXPECTED_SIGNATURES.get(claim_name)
    if sig:
        constraints, mnemonic = sig
        ev['expected_constraints'] = constraints
        ev['expected_template']    = _signature_template_str(constraints)
        ev['expected_mnemonic']    = mnemonic
        ev['signature_match']      = _check_signature(target_bytes, constraints)
    else:
        ev['expected_constraints'] = None
        ev['expected_template']    = None
        ev['expected_mnemonic']    = None
        ev['signature_match']      = None
    return ev


def verdict_supports_code_pointer(ev):
    """Verdict: SUPPORTED if every byte constraint matches; CONTRADICTED if
    any required byte differs; INCONCLUSIVE if no signature is known."""
    if ev.get('slot_value') is None:
        return ('INCONCLUSIVE', 'could not read dispatch slot from flat file')
    if ev.get('expected_constraints') is None:
        return ('INCONCLUSIVE',
                f'no expected byte signature for `{ev["claim"]}`; '
                f'slot points to 0x{ev["slot_value"]:X}')
    if ev.get('signature_match'):
        return ('SUPPORTED',
                f'slot 0x{ev["slot_addr"]:X} -> 0x{ev["slot_value"]:X}; '
                f'bytes match `{ev["expected_template"]}` '
                f'({ev["expected_mnemonic"]})')
    # Find the specific constraint(s) that failed
    tb = ev.get('target_bytes', b'')
    fails = []
    for off, expected in ev['expected_constraints']:
        actual = tb[off] if off < len(tb) else None
        if actual != expected:
            actual_str = f'0x{actual:02X}' if actual is not None else 'EOF'
            fails.append(f'+{off}: expected 0x{expected:02X}, got {actual_str}')
    return ('CONTRADICTED',
            f'slot 0x{ev["slot_addr"]:X} -> 0x{ev["slot_value"]:X}; '
            f'mismatched byte(s): {"; ".join(fails)}')


def render_code_evidence(ev):
    out = []
    out.append(f'### `{ev["file"]}` slot `0x{ev["slot_addr"]:X}` -> '
               f'claim *{ev["claim"]}*')
    out.append('')
    sv = ev.get('slot_value')
    if sv is None:
        out.append('- (could not read dispatch slot from flat file)')
        out.append('')
        return '\n'.join(out)
    out.append(f'- Flat file: `{ev["flat_path"]}`')
    out.append(f'- Load base: `0x{ev["load_base"]:X}`')
    out.append(f'- Slot value (target addr): `0x{sv:X}`')
    tb = ev.get('target_bytes', b'')
    if tb:
        out.append(f'- First {len(tb)} bytes at target: `{tb.hex(" ")}`')
    if ev.get('expected_template'):
        out.append(f'- Expected template: `{ev["expected_template"]}`')
        out.append(f'- Mnemonic: {ev.get("expected_mnemonic","")}')
        out.append(f'- Signature match: **{ev.get("signature_match")}**')
    out.append('')
    return '\n'.join(out)


def check_directional_grouping(file_stem, slot_addr_by_name):
    """Structural cross-claim test: for each declared family, do the member
    targets share a byte-prefix of the family's `prefix_len`?

    Returns dict family -> {prefixes: set, members: list, prefix_len: int}.
    """
    info = {}
    for family, spec in DIRECTION_FAMILIES.items():
        names      = spec['members']
        prefix_len = spec['prefix_len']
        prefixes = set()
        members  = []
        for name in names:
            slot = slot_addr_by_name.get(name)
            if slot is None:
                continue
            sv, base, _ = read_slot_word(file_stem, slot)
            if sv is None:
                continue
            tb = read_bytes_at_addr(file_stem, sv, prefix_len)
            prefixes.add(tb)
            members.append((name, slot, sv, tb))
        info[family] = {'prefixes': prefixes,
                        'members':  members,
                        'prefix_len': prefix_len}
    return info


# ----------------------------------------------------------------------
# Test cases
# ----------------------------------------------------------------------

# Contested addresses to validate. Each tuple: (file_stem, addr, ida_claim).
CONTESTED = [
    # Stdply data fields — IDA says hero stat record, we said driver state
    ('stdply', 0x80, 'proximity_map_left_col_x'),
    ('stdply', 0x83, 'hero_x_in_viewport'),
    ('stdply', 0x85, 'hero_gold_hi'),
    ('stdply', 0x86, 'hero_gold_lo'),
    ('stdply', 0x8B, 'hero_almas'),
    ('stdply', 0x90, 'hero_HP'),
    ('stdply', 0x92, 'sword_type'),
    ('stdply', 0x93, 'shield_type'),
    ('stdply', 0x94, 'shield_HP'),
    ('stdply', 0x9D, 'current_magic_spell'),
    ('stdply', 0xAB, 'spells_espada'),
]

# Code-pointer dispatch slots to validate.
# Tuple: (file_stem, slot_addr, claimed_target_name).
# Slot addresses are the CPU addresses of the dispatch words inside the binary.
# fight.bin's first dispatch word is at addr 0x6000 (per IDA's `org 6000h`).
# Per IDA's fight.asm header (lines 17-30):
#   0x6000 -> Cavern_Game_Init
#   0x6002 -> prepare_dungeon
#   0x6004 -> monster_move_in_direction
#   0x6006 -> Check_collision_in_direction
#   0x6008..0x601A -> move_monster_E/NE/N/NW/W/SW/S/SE
#   0x601C -> check_collision_E2
#   0x601E -> check_collision_W2
#   0x6020 -> check_collision_N2
#   0x6022 -> check_collision_S2
CODE_POINTER_CLAIMS = [
    # ---- fight.bin movers (0x6008..0x6016) ----
    ('fight', 0x6008, 'move_monster_E'),
    ('fight', 0x600A, 'move_monster_NE'),
    ('fight', 0x600C, 'move_monster_N'),
    ('fight', 0x600E, 'move_monster_NW'),
    ('fight', 0x6010, 'move_monster_W'),
    ('fight', 0x6012, 'move_monster_SW'),
    ('fight', 0x6014, 'move_monster_S'),
    ('fight', 0x6016, 'move_monster_SE'),
    # ---- fight.bin collision-checks (0x6018..0x6026) ----
    # Per IDA's fight.asm dispatch, slots 0x6018..0x6026 hold the 8 collision
    # checks in order: E2, W2, N2, S2, NE2, SE2, NW2, SW2.
    ('fight', 0x6018, 'check_collision_E2'),
    ('fight', 0x601A, 'check_collision_W2'),
    ('fight', 0x601C, 'check_collision_N2'),
    ('fight', 0x601E, 'check_collision_S2'),
    ('fight', 0x6020, 'check_collision_NE2'),
    ('fight', 0x6022, 'check_collision_SE2'),
    ('fight', 0x6024, 'check_collision_NW2'),
    ('fight', 0x6026, 'check_collision_SW2'),
    # ---- town.bin: 5 high-confidence dispatch slots ----
    # Per IDA's town.asm `start:` table at org 6000h:
    #   0x6000 town_entry_normal     (writes disable_edge_scroll=0)
    #   0x6002 town_entry_init       (writes disable_edge_scroll=FFh + jmp)
    #   0x600A check_gold_sufficient (reads ds:[85] hero_gold_hi)
    #   0x600C add_gold_to_hero      (writes ds:[86] then ds:[85])
    #   0x601C restore_game          (calls int 60h fn 3 = audio restore)
    ('town',  0x6000, 'town_entry_normal'),
    ('town',  0x6002, 'town_entry_init'),
    ('town',  0x600A, 'check_gold_sufficient'),
    ('town',  0x600C, 'add_gold_to_hero'),
    ('town',  0x601C, 'restore_game'),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--addr', help='Single address to check (hex)')
    ap.add_argument('--file', help='File stem for --addr')
    args = ap.parse_args()

    if args.addr:
        addr = int(args.addr, 16) if args.addr.startswith('0x') else int(args.addr, 16)
        file_stem = args.file or 'stdply'
        ev = gather_evidence(file_stem, addr)
        print(render_evidence(ev))
        return

    out_lines = ['# Deterministic Evidence Check — Contested Addresses', '']
    out_lines.append('Evidence-supported verdicts on contested name claims. Each claim is')
    out_lines.append('checked against deterministic evidence (initial byte values, nearby')
    out_lines.append('strings, code references, hardware/DOS calls) — no LLM judgment.')
    out_lines.append('')
    out_lines.append('| File | Address | IDA claim | Init byte | Verdict | Evidence |')
    out_lines.append('|---|---|---|---|---|---|')

    supported = 0
    contradicted = 0
    inconclusive = 0
    for file_stem, addr, claim in CONTESTED:
        ev = gather_evidence(file_stem, addr, claim)
        verdict_fn = VERDICT_FNS.get(claim)
        if verdict_fn:
            v = verdict_fn(ev)
        else:
            v = ('INCONCLUSIVE', 'no verdict heuristic for this claim')
        bv = ev.get('init_byte')
        bv_str = f'0x{bv:02X}' if bv is not None else '?'
        verdict, reason = v if v else ('INCONCLUSIVE', 'no evidence')
        out_lines.append(f'| stdply | `0x{addr:X}` | `{claim}` | {bv_str} | **{verdict}** | {reason} |')
        if verdict == 'SUPPORTED': supported += 1
        elif verdict == 'CONTRADICTED': contradicted += 1
        else: inconclusive += 1

    out_lines.append('')
    out_lines.append(f'**Phase 1 (data fields)**: {supported} supported / '
                     f'{contradicted} contradicted / {inconclusive} inconclusive')
    out_lines.append('')

    # ------------------------------------------------------------------
    # Phase 2 — code-pointer dispatch slots
    # ------------------------------------------------------------------
    out_lines.append('## Phase 2 — Code-Pointer Dispatch Slots')
    out_lines.append('')
    out_lines.append('Validates that each dispatch slot in a binary holds the address')
    out_lines.append('of the procedure IDA labels for it. Match is by byte signature')
    out_lines.append('(deterministic) — no LLM judgment.')
    out_lines.append('')
    out_lines.append('| File | Slot addr | IDA claim | Slot value | Verdict | Evidence |')
    out_lines.append('|---|---|---|---|---|---|')

    code_supported = 0
    code_contradicted = 0
    code_inconclusive = 0
    for file_stem, slot_addr, claim in CODE_POINTER_CLAIMS:
        ev = gather_code_evidence(file_stem, slot_addr, claim)
        v = verdict_supports_code_pointer(ev)
        verdict, reason = v
        sv = ev.get('slot_value')
        sv_str = f'0x{sv:X}' if sv is not None else '?'
        out_lines.append(
            f'| {file_stem} | `0x{slot_addr:X}` | `{claim}` | {sv_str} | '
            f'**{verdict}** | {reason} |'
        )
        if verdict == 'SUPPORTED':       code_supported += 1
        elif verdict == 'CONTRADICTED':  code_contradicted += 1
        else:                            code_inconclusive += 1

    out_lines.append('')
    out_lines.append(f'**Phase 2 (code pointers)**: {code_supported} supported / '
                     f'{code_contradicted} contradicted / {code_inconclusive} inconclusive')
    out_lines.append('')

    # ------------------------------------------------------------------
    # Phase 3 — structural directional grouping
    # ------------------------------------------------------------------
    out_lines.append('## Phase 3 — Structural Directional Grouping')
    out_lines.append('')
    out_lines.append('Cross-claim consistency check: do the 8 dispatch targets cluster')
    out_lines.append('into the directional families IDA\'s labels imply? If all 3 east')
    out_lines.append('targets share one byte prefix, all 3 west targets share another,')
    out_lines.append('and both vertical targets share a third, the labels are validated')
    out_lines.append('STRUCTURALLY (independent of any single signature definition).')
    out_lines.append('')

    # Run grouping per binary (fight has the directional families).
    slot_addr_by_name_fight = {claim: slot for f, slot, claim in CODE_POINTER_CLAIMS
                                if f == 'fight'}
    family_info = check_directional_grouping('fight', slot_addr_by_name_fight)

    structurally_consistent = True
    for family, finfo in family_info.items():
        prefixes   = finfo['prefixes']
        members    = finfo['members']
        prefix_len = finfo['prefix_len']
        out_lines.append(f'### Family `{family}` '
                         f'({len(members)} member(s), prefix {prefix_len} bytes)')
        if len(prefixes) == 1 and members:
            out_lines.append(
                f'- **Cohesive**: all {len(members)} share prefix '
                f'`{next(iter(prefixes)).hex(" ")}`'
            )
        elif len(prefixes) > 1:
            structurally_consistent = False
            out_lines.append(
                f'- **Split**: {len(prefixes)} distinct byte prefixes among '
                f'{len(members)} members (FAMILY DOES NOT COHERE)'
            )
        else:
            out_lines.append('- (no members validated)')
        for name, slot, sv, tb in members:
            out_lines.append(f'  - `{name}` slot 0x{slot:X} -> 0x{sv:X}: '
                             f'`{tb.hex(" ")}`')
        out_lines.append('')

    out_lines.append(
        f'**Structural consistency**: '
        f'{"PASS — all 3 families cohere" if structurally_consistent else "FAIL"}'
    )
    out_lines.append('')

    # ------------------------------------------------------------------
    # Detailed per-claim evidence
    # ------------------------------------------------------------------
    out_lines.append('## Detailed evidence per address')
    out_lines.append('')
    for file_stem, addr, claim in CONTESTED:
        ev = gather_evidence(file_stem, addr, claim)
        out_lines.append(render_evidence(ev))
    for file_stem, slot_addr, claim in CODE_POINTER_CLAIMS:
        ev = gather_code_evidence(file_stem, slot_addr, claim)
        out_lines.append(render_code_evidence(ev))

    out = WORKING / 'EVIDENCE_REPORT.md'
    out.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'Wrote {out}')
    print(f'Phase 1 (data):  {supported} supported, {contradicted} contradicted, {inconclusive} inconclusive')
    print(f'Phase 2 (code):  {code_supported} supported, {code_contradicted} contradicted, {code_inconclusive} inconclusive')
    print(f'Phase 3 (struct): {"PASS" if structurally_consistent else "FAIL"}')


if __name__ == '__main__':
    main()
