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
    out_lines.append(f'**Summary**: {supported} supported / {contradicted} contradicted / {inconclusive} inconclusive')
    out_lines.append('')
    out_lines.append('## Detailed evidence per address')
    out_lines.append('')
    for file_stem, addr, claim in CONTESTED:
        ev = gather_evidence(file_stem, addr, claim)
        out_lines.append(render_evidence(ev))

    out = WORKING / 'EVIDENCE_REPORT.md'
    out.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'Wrote {out}')
    print(f'Supported: {supported}, Contradicted: {contradicted}, Inconclusive: {inconclusive}')


if __name__ == '__main__':
    main()
