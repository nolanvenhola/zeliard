#!/usr/bin/env python3
"""
test_town_dispatch_slot_600A.py

Probes the function at town.bin slot 0x600A (per IDA: `check_gold_sufficient`).
The point of this test, beyond validating the IDA name, is to CROSS-CHECK the
gold-layout refinement we just applied to stdply.asm:

    add_gold_to_hero  (slot 0x600C) writes  DS:0x85 (hi), 0x86..0x87 (low word)
    check_gold_sufficient (this slot)  must read the SAME three bytes if the
        hero_gold_hi / _lo / _mid layout is correct.

Bytes at 0x7570:
    8A 1E 85 00      mov bl, ds:[85h]      ; load gold_hi
    2A DA            sub bl, dl            ; gold_hi - request_hi
    73 01            jnb +1                ; if CF=0 (sufficient hi), skip RET
    C3               ret                   ; insufficient hi -> CF=1 return
    8A D3            mov dl, bl            ;
    8B 1E 86 00      mov bx, ds:[86h]      ; load gold low word (0x86..0x87)
    93               xchg bx, ax           ; bx <- request_lo, ax <- gold_lo
    2B C3            sub ax, bx            ; gold_lo - request_lo
    ... (multi-precision finish)

Calling convention (inferred from bytes):
    DX:AX = request amount (DL=high byte, AX=low word)
    Returns CF=1 if gold24 < request, else CF=0.

Probes
------
For each probe we set the three gold bytes, call with a known DX:AX, and
observe ONLY the carry flag (no memory writes — this is a pure comparator).
"""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402

TOWN_FLAT = Path('c:/Projects/Zeliard/3_Assembly/tasm/research/flatfiles/'
                 'ZELRES1/town.bin')
LOAD_BASE = 0x6000
SLOT_ADDR = 0x600A


def call_check(gold_hi, gold_lo, gold_mid, request_hi, request_low_word):
    """One probe: set the 3 gold bytes, call the function, return CF + diffs."""
    h = TasmHarness(TOWN_FLAT, LOAD_BASE)
    h.write_byte(0x85, gold_hi)
    h.write_byte(0x86, gold_lo)
    h.write_byte(0x87, gold_mid)
    target = (TOWN_FLAT.read_bytes()[SLOT_ADDR - LOAD_BASE]
              | (TOWN_FLAT.read_bytes()[SLOT_ADDR - LOAD_BASE + 1] << 8))
    out = h.call_function(target,
                          regs={'ax': request_low_word, 'dx': request_hi})
    return out, target


def gold24(hi, lo, mid):
    """Reconstruct 24-bit gold value from the three bytes."""
    return (hi << 16) | (mid << 8) | lo


def request24(hi, low_word):
    """Reconstruct 24-bit request from DL:AX."""
    return (hi << 16) | low_word


def probe(name, gold, req, *, expect_cf):
    gh, glo, gmid = gold
    rhi, rlo = req
    out, target = call_check(gh, glo, gmid, rhi, rlo)
    cf = out['flags_after']['CF']
    rid = out['stopped_reason'] == 'returned_to_sentinel'
    diffs = out['mem_diffs']
    g24 = gold24(gh, glo, gmid)
    r24 = request24(rhi, rlo)
    sufficient = g24 >= r24
    expected_cf = (not sufficient)  # CF=1 if insufficient, CF=0 if sufficient
    pass_ = (cf == expected_cf == expect_cf and not diffs and rid)
    print(f'  {name:<48s}  gold={g24:>7d}  req={r24:>7d}  '
          f'CF={int(cf)}  diffs={len(diffs)}  '
          f'-> {"PASS" if pass_ else "FAIL"}')
    return pass_


def main():
    if not TOWN_FLAT.exists():
        print(f'MISSING: {TOWN_FLAT}')
        sys.exit(1)

    flat = TOWN_FLAT.read_bytes()
    target = flat[SLOT_ADDR - LOAD_BASE] | (flat[SLOT_ADDR - LOAD_BASE + 1] << 8)
    print(f'town.bin dispatch slot 0x{SLOT_ADDR:X} -> function at 0x{target:X}')
    print('Probes assert CF=1 when request > gold24, CF=0 otherwise.')
    print('Each probe also confirms the function performs no memory writes.\n')

    print('=' * 78)
    print('PROBES')
    print('=' * 78)

    results = []

    # ---- Group I: pure low-byte comparisons (gold_hi=0, mid=0) ----
    results.append(probe('I.1  gold=0,         req=0    -> sufficient',
                         gold=(0, 0, 0), req=(0, 0), expect_cf=False))
    results.append(probe('I.2  gold=0,         req=1    -> insufficient',
                         gold=(0, 0, 0), req=(0, 1), expect_cf=True))
    results.append(probe('I.3  gold=100,       req=50   -> sufficient',
                         gold=(0, 100, 0), req=(0, 50), expect_cf=False))
    results.append(probe('I.4  gold=100,       req=200  -> insufficient',
                         gold=(0, 100, 0), req=(0, 200), expect_cf=True))

    # ---- Group II: middle byte (0x87) MUST be read for these to be right ----
    # If the function ignored 0x87, gold would appear to be 0 in II.1/II.2
    # and the CF verdicts would flip.
    results.append(probe('II.1 gold=256 (mid=1), req=200 -> sufficient',
                         gold=(0, 0, 1), req=(0, 200), expect_cf=False))
    results.append(probe('II.2 gold=256 (mid=1), req=300 -> insufficient',
                         gold=(0, 0, 1), req=(0, 300), expect_cf=True))
    results.append(probe('II.3 gold=257 (mid=1,lo=1), req=257 -> sufficient',
                         gold=(0, 1, 1), req=(0, 257), expect_cf=False))

    # ---- Group III: high byte (0x85) MUST be read for these ----
    results.append(probe('III.1 gold=65536 (hi=1), req=65000 -> sufficient',
                         gold=(1, 0, 0), req=(0, 65000), expect_cf=False))
    results.append(probe('III.2 gold=65536 (hi=1), req=65537 -> insufficient',
                         gold=(1, 0, 0), req=(1, 1), expect_cf=True))
    results.append(probe('III.3 gold=131071 (hi=1,mid=255,lo=255), req=131071',
                         gold=(1, 0xFF, 0xFF), req=(1, 0xFFFF), expect_cf=False))

    # ---- Group IV: control — function must be PURE (no writes) ----
    # Already covered by every probe's diffs==0 check, but call out explicitly:
    out_pure, _ = call_check(50, 200, 0, 0, 100)
    pure_ok = (not out_pure['mem_diffs']
               and out_pure['stopped_reason'] == 'returned_to_sentinel')
    print(f'  IV   purity check (no memory writes during compare)         '
          f'diffs={len(out_pure["mem_diffs"])}    -> '
          f'{"PASS" if pure_ok else "FAIL"}')
    results.append(pure_ok)

    print('\n' + '=' * 78)
    print('VERDICT')
    print('=' * 78)
    n_pass = sum(results)
    n_total = len(results)
    print(f'  {n_pass}/{n_total} probes passed.')
    print()
    if n_pass == n_total:
        print('  Observed semantics:')
        print('    • Reads exactly 3 bytes: DS:0x85, DS:0x86, DS:0x87.')
        print('    • Treats them as a 24-bit value with hi=0x85 and')
        print('      little-endian low word at 0x86..0x87 — same layout that')
        print('      add_gold_to_hero (slot 0x600C) WROTE to in the prior test.')
        print('    • Returns CF=1 iff request_24 > gold_24.')
        print('    • Performs no memory writes (pure comparator).')
        print()
        print('  This cross-validates the gold-layout rename:')
        print('    DS:0x85 = hero_gold_hi   (high byte)')
        print('    DS:0x86 = hero_gold_lo   (low byte of low word)')
        print('    DS:0x87 = hero_gold_mid  (high byte of low word)')
        print()
        print('  Both the writer and the reader agree on the 3-byte layout —')
        print('  this would not be true if 0x87 were truly "reserved" as the')
        print('  pre-refinement source claimed.')
    else:
        print('  At least one probe failed — see above.  Layout may need')
        print('  further refinement.')


if __name__ == '__main__':
    main()
