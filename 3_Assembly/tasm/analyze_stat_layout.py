#!/usr/bin/env python3
"""
analyze_stat_layout.py

For every address in the player-stat record (0x80..0xAA), classify HOW the
cleaned source reads and writes it.  An address accessed only via `mov al,
[NNh]` is a byte field; one accessed via `mov ax, [NNh]` extends across NN
and NN+1 as a word; an `adc [NNh], dl` reveals it's the high half of a
multi-precision arithmetic chain.

Output: a per-address summary that distinguishes
  - byte fields
  - word fields (and which adjacent address is their high byte)
  - multi-precision arithmetic anchors (low-word/high-byte add/adc pairs)
  - addresses currently labelled "reserved" but actually accessed

This is a STATIC analysis — purely lexical inspection of the source.  Its
output is the input to the next round of harness probes (which will
verify the inferred structure by running the actual functions).
"""

import os, re, argparse
from collections import defaultdict

ROOT = 'c:/Projects/Zeliard/3_Assembly/tasm/working'

# Default range = stdply player-stat record.  Override on the CLI:
#   python analyze_stat_layout.py --range 0xFF00 0xFFFF
LO, HI = 0x80, 0xAA

# Segment groups — files that share a runtime CS register at execution time.
# An `cs:[NN]` reference in any file in a group refers to the SAME byte across
# the group; refs from a different group at the same offset are independent
# memory.  Member matching is by basename-prefix.  Items not listed are
# treated as their own segment (no cross-file aggregation for cs: refs).
SEGMENTS = {
    # Game segment (zeliad.exe loads stdply, stick, gm*, gd*, gf*, gt* at
    # known offsets here, and game/town/fight/select/mole take turns at
    # CS:0x6000+0xA000).  All these can read each other's CS-relative state.
    'game_seg': [
        'stdply', 'stick', 'game', 'zeliard',
        'gmcga', 'gmega', 'gmhgc', 'gmmcga', 'gmtga',
        'gdcga', 'gdega', 'gdhgc', 'gdmcga', 'gdtga',
        'gfcga', 'gfega', 'gfhgc', 'gfmcga', 'gftga',
        'gtcga', 'gtega', 'gthgc', 'gtmcga', 'gttga',
        '106TOWN', '107GTEGA', '108GTCGA', '109GTHGC', '110GTTGA', '111GTMCA',
        '200FIGHT', '201SELCT', '202GFEGA', '203GFCGA', '204GFHGC', '205GFTGA',
        '206GFMCA', '207MOLE', '101GDEGA', '102GDCGA', '103GDHGC', '104GDTGA',
        '105GDMCA', '100OPDMO',
    ],
    # Per-enemy segment (zelres3 chunks loaded at CS:0xA000 in a separate
    # segment; eai*, crab, akma, drgn, etc. are each only resident one at
    # a time).  These do NOT see the game-segment CS-relative state.
    'enemy_seg': [
        'crab', 'eai1', 'eai2', 'akma', 'drgn',
        '300ROKAD', '301EAI1', '302EAI2', '303CRAB', '304TAKO', '305TORI',
        '306ZELA', '307MEDA', '308LEGA', '309ZEL2', '310DRGN', '311AKMA',
        '312MAO1', '313MAO2',
    ],
    # NPC/town-shop segment (zelres1 chunks 200-219 loaded at the same
    # CS:0xA000 slot as enemies but for town interactions).
    'town_npc_seg': [
        '210INNAP', '211KENJP', '212ARMRP', '213BANKP', '214CHURP',
        '215DRUGP', '216HOUSP', '217KINGP', '218OMOYP', '219RAUSP',
    ],
}


def _file_segment(path):
    """Return the segment name for a given source file path, or None if
    the file isn't in any defined segment group."""
    base = os.path.basename(path)
    stem = base.rsplit('.', 1)[0]
    for seg, members in SEGMENTS.items():
        for m in members:
            if stem.startswith(m) or stem == m:
                return seg
    return None

# Compile patterns that capture one of: byte ptr, word ptr, ax, al, dl, etc.
# We tag each reference with its access size and operation kind.
# Patterns:
#   word ptr ds:[NN]   -> WORD
#   byte ptr ds:[NN]   -> BYTE
#   mov ax, [NN]       -> WORD (16-bit register implies word access)
#   mov al, [NN]       -> BYTE
#   adc [NN], dl       -> ADC8 (multi-precision high half)
#   add [NN], ax       -> ADD16 (multi-precision low half)
#   inc / dec byte ptr -> INC/DEC8

ADDR_RE = re.compile(
    # Group "addr": the hex address (literal form).
    # Critical: after the trailing `h` we require a non-word boundary
    # (`(?!\w)`) — otherwise the regex matches `cs:char_src_ptr` as
    # `cs:ch` with addr=0x0C, since `c` is a hex digit.
    r'(?:'
        # Bracketed form: cs:[NNh] or [NNh]
        r'(?:ds|cs|es|ss|fs|gs):\[(?P<addr1>[0-9A-Fa-f]+)h\]'
        r'|'
        r'\[(?P<addr2>[0-9A-Fa-f]+)h\]'
        r'|'
        # Bare form: cs:NNh (no brackets) — must end at word boundary
        r'(?:ds|cs|es|ss|fs|gs):(?P<addr3>[0-9A-Fa-f]+)h(?!\w)'
    r')'
)

# Named-form references: a memory operand using an EQU symbol, e.g.
#   mov al, ds:gvar_music_b   or   mov bl, [hero_HP]
# Captures the symbol name; we resolve to an address via the EQU map.
NAME_RE = re.compile(
    r'(?:'
        r'(?:ds|cs|es|ss|fs|gs):\[?(?P<name1>[a-zA-Z_]\w*)\]?'
        r'|'
        r'\[(?P<name2>[a-zA-Z_]\w*)\]'
    r')'
)


def build_equ_map():
    """Scan every .inc/.asm under ROOT for `name equ <hex>` lines and
    return name -> int address.  Multiple definitions of the same name
    are kept as a set; we'll prefer addresses in the requested range."""
    name_to_addrs = defaultdict(set)
    for dirpath, _, filenames in os.walk(ROOT):
        for fn in filenames:
            if not fn.endswith(('.asm', '.inc')):
                continue
            p = os.path.join(dirpath, fn)
            try:
                txt = open(p, encoding='utf-8', errors='replace').read()
            except OSError:
                continue
            for line in txt.split('\n'):
                no_c = re.sub(r';.*', '', line)
                m = re.match(r'^\s*([a-zA-Z_]\w*)\s+equ\s+([0-9A-Fa-f]+)h\s*$',
                             no_c)
                if m:
                    try:
                        name_to_addrs[m.group(1)].add(int(m.group(2), 16))
                    except ValueError:
                        pass
    return name_to_addrs

# Heuristics applied to the WHOLE no-comment line:
WORD_INDICATORS = re.compile(
    r'\bword\s+ptr\b|\b(?:ax|bx|cx|dx|si|di|bp|sp)\s*,|'
    r',\s*(?:ax|bx|cx|dx|si|di|bp|sp)\b',
    re.I
)
BYTE_INDICATORS = re.compile(
    r'\bbyte\s+ptr\b|\b(?:al|ah|bl|bh|cl|ch|dl|dh)\s*,|'
    r',\s*(?:al|ah|bl|bh|cl|ch|dl|dh)\b',
    re.I
)
WRITE_OPCODES = re.compile(
    r'^\s*(?:mov|add|adc|sub|sbb|inc|dec|or|and|xor|not|neg|test\s)',
    re.I
)
ADC_RE = re.compile(r'^\s*adc\b', re.I)
ADD_RE = re.compile(r'^\s*add\b', re.I)
SBB_RE = re.compile(r'^\s*sbb\b', re.I)
SUB_RE = re.compile(r'^\s*sub\b', re.I)


def classify_line(line):
    """Return (size, opcode_kind) for the FIRST address matched on the line.

    size: 'byte' | 'word' | '?'
    opcode_kind: 'mov' | 'inc' | 'dec' | 'add' | 'adc' | 'sub' | 'sbb'
                  | 'test' | 'or' | 'and' | 'xor' | 'cmp' | '?'
    """
    no_c = re.sub(r';.*', '', line)
    if WORD_INDICATORS.search(no_c) and not BYTE_INDICATORS.search(no_c):
        size = 'word'
    elif BYTE_INDICATORS.search(no_c) and not WORD_INDICATORS.search(no_c):
        size = 'byte'
    elif 'word ptr' in no_c.lower():
        size = 'word'
    elif 'byte ptr' in no_c.lower():
        size = 'byte'
    else:
        size = '?'
    m = re.match(r'^\s*(\w+)', no_c)
    op = m.group(1).lower() if m else '?'
    return size, op


def main():
    global LO, HI
    ap = argparse.ArgumentParser()
    ap.add_argument('--range', nargs=2, metavar=('LO', 'HI'),
                    help='Address range as two hex args (e.g. 0xFF00 0xFFFF)')
    ap.add_argument('--show-zero', action='store_true',
                    help='Include addresses with no genuine refs in the table')
    ap.add_argument('--segment', choices=list(SEGMENTS.keys()),
                    help='Restrict analysis to files in this segment group. '
                         'Without --segment, ALL files are aggregated (the '
                         'old behaviour, which inflates counts when offsets '
                         'collide across segments).')
    args = ap.parse_args()
    if args.range:
        LO = int(args.range[0], 16)
        HI = int(args.range[1], 16)
    print(f'Analyzing range 0x{LO:04X}..0x{HI:04X}'
          + (f', segment={args.segment}' if args.segment else
             ', segment=ALL (cross-segment counts may overlap)')
          + '\n')

    equ_map = build_equ_map()
    print(f'Resolved {len(equ_map)} EQU symbol(s); names in range will be '
          f'counted alongside literal-hex references.\n')

    # addr -> {'byte_reads': N, 'byte_writes': N, 'word_reads': N, ...}
    info = defaultdict(lambda: defaultdict(int))
    samples = defaultdict(list)

    for dirpath, _, filenames in os.walk(ROOT):
        for fn in filenames:
            if not fn.endswith(('.asm', '.inc')):
                continue
            p = os.path.join(dirpath, fn)
            file_seg = _file_segment(p) if args.segment else None
            try:
                txt = open(p, encoding='utf-8', errors='replace').read()
            except OSError:
                continue
            for ln, line in enumerate(txt.split('\n'), 1):
                no_c = re.sub(r';.*', '', line)
                stripped = no_c.strip().lower()
                # Skip data declarations
                if stripped.startswith(('db ', 'dw ', 'dd ', 'db\t', 'dw\t', 'dd\t')):
                    continue
                # Try to resolve a memory operand to an address: first via
                # literal-hex match, then via EQU-name match.
                addr = None
                m = ADDR_RE.search(no_c)
                if m:
                    ah = (m.group('addr1') or m.group('addr2')
                          or m.group('addr3'))
                    try:
                        addr = int(ah, 16)
                    except (ValueError, TypeError):
                        addr = None
                if addr is None:
                    m_name = NAME_RE.search(no_c)
                    if m_name:
                        nm = m_name.group('name1') or m_name.group('name2')
                        # Filter out register-name false positives
                        if nm.lower() in ('ax','bx','cx','dx','si','di','bp','sp',
                                          'al','ah','bl','bh','cl','ch','dl','dh',
                                          'es','cs','ds','ss','fs','gs',
                                          'word','byte','dword','ptr',
                                          'far','near','offset','seg','short'):
                            pass
                        elif nm in equ_map:
                            # Prefer an address that lies in our requested range
                            cands = [a for a in equ_map[nm] if LO <= a <= HI]
                            if cands:
                                addr = cands[0]
                if addr is None:
                    continue
                if not (LO <= addr <= HI):
                    continue
                # Segment filter: cs:/es:/ss:-relative refs see the chunk's
                # OWN segment (which depends on which chunk it is); ds:-
                # relative refs see the shared data segment (the game seg
                # for all chunks loaded at runtime).  So when the user
                # restricts to a segment group, we drop CS-relative refs
                # from files in OTHER segment groups but keep DS-relative
                # refs from anywhere.
                if args.segment:
                    is_ds_ref = bool(re.search(r'\bds:', no_c, re.I))
                    if not is_ds_ref and file_seg != args.segment:
                        continue
                size, op = classify_line(no_c)
                # Decide read/write/test from opcode
                if op in ('mov',):
                    # mov reg, [addr]   -> read
                    # mov [addr], reg   -> write
                    if re.search(rf'\b(?:byte|word)\s+ptr\s+(?:ds|cs|es|ss):?\[?{addr:X}h?\]?\s*,', no_c, re.I) \
                       or re.search(rf'\b(?:ds|cs|es|ss):\[?{addr:X}h\]?\s*,', no_c, re.I) \
                       or re.search(rf'^\s*mov\s+(?:byte\s+ptr\s+|word\s+ptr\s+)?\[?{addr:X}h?\]?\s*,', no_c, re.I):
                        kind = f'{size}_write'
                    else:
                        kind = f'{size}_read'
                elif op in ('add', 'adc', 'sub', 'sbb', 'inc', 'dec',
                            'or', 'and', 'xor', 'not', 'neg'):
                    kind = f'{size}_{op}'
                elif op in ('test', 'cmp'):
                    kind = f'{size}_{op}'
                else:
                    kind = f'{size}_{op}'
                info[addr][kind] += 1
                if len(samples[addr]) < 3:
                    samples[addr].append((os.path.basename(p), ln,
                                          line.rstrip()[:90]))

    # ---- Report ----
    print(f'{"addr":>6s}  {"summary":<60s}  {"sample"}')
    print('-' * 130)
    for addr in range(LO, HI + 1):
        if addr not in info:
            if args.show_zero:
                print(f' 0x{addr:04X}  (no genuine memory references)')
            continue
        summary_bits = []
        for kind, n in sorted(info[addr].items(), key=lambda kv: -kv[1]):
            summary_bits.append(f'{kind}={n}')
        s = ', '.join(summary_bits)
        sample = samples[addr][0][2] if samples[addr] else ''
        print(f' 0x{addr:04X}  {s[:60]:<60s}  {sample[:60]}')

    # ---- Inferences ----
    print('\n' + '=' * 70)
    print('INFERENCES (purely from access patterns)')
    print('=' * 70)
    print('* word_read/word_write at addr N AND no genuine refs at N+1')
    print('  -> N is the LOW byte of a 16-bit field spanning N..N+1.')
    print('* byte_adc at addr N + word_add/word_write at addr N-1')
    print('  -> N is the HIGH byte of a 24-bit field whose low word is at N-1.')
    print('* byte_test or byte_write of FFh at "reserved" addr')
    print('  -> N is a flag byte, not reserved.')
    print()

    for addr in range(LO, HI + 1):
        if addr not in info:
            continue
        kinds = info[addr]
        notes = []
        # 16-bit field detection
        word_total = sum(v for k, v in kinds.items() if k.startswith('word'))
        if word_total > 0:
            n1 = info.get(addr + 1, {})
            n1_count = sum(n1.values())
            if n1_count == 0 or all(k.startswith(('byte_adc', 'byte_sbb'))
                                     for k in n1):
                notes.append(f'WORD field at 0x{addr:02X}..0x{addr+1:02X}')
        # Multi-precision detection
        if any(k.startswith('byte_adc') for k in kinds):
            notes.append(f'high-byte of multi-precision (low_word likely at '
                         f'0x{addr-2:02X}..0x{addr-1:02X})')
        if any(k.startswith('byte_sbb') for k in kinds):
            notes.append('high-byte of multi-precision SUB chain')
        # Flag byte
        if any(k == 'byte_test' for k in kinds) and word_total == 0:
            notes.append('flag byte (test byte ptr ...)')
        if notes:
            print(f' 0x{addr:04X}  ' + '; '.join(notes))


if __name__ == '__main__':
    main()
