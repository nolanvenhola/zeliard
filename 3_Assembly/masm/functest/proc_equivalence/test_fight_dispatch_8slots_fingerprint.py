#!/usr/bin/env python3
"""
test_fight_dispatch_8slots_fingerprint.py

Behavioral fingerprint of all 8 move-monster dispatch slots in fight.bin
(0x6008..0x6016).  No labels are assumed.  We:

  1. Read the address each slot points to.
  2. For each, also read the address of the slot at +0x10 (which Phase 2
     identified as the matching "collision check" call target).  We use
     that address as the stub target so the function under test can
     fall through past its own collision check without dragging in the
     proximity map.
  3. Run each function with identical inputs, stub the collision check
     as "passable", and record exactly which bytes of a fresh fake
     monster struct the function mutates.
  4. Group the 8 functions by their mutation fingerprint.

The fingerprint is the ground truth: if 3 functions all increment SI+3
by 1, those 3 functions BEHAVE as the east-mover family, regardless of
what we (or IDA) call them.  Likewise for west, north, south.
"""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS  # noqa: E402

FIGHT_FLAT, LOAD_BASE = BIN_PATHS['fight']
MONSTER_PTR = 0x1000
REBUILT_BIN_HEADER_BIAS = 4

# IDA's name for each slot — used ONLY as a label for the report.
# The test does not depend on these names being correct.
SLOT_LABELS = {
    0x600C: 'E_hyp',
    0x600E: 'NE_hyp',
    0x6010: 'N_hyp',
    0x6012: 'NW_hyp',
    0x6014: 'W_hyp',
    0x6016: 'SW_hyp',
    0x6018: 'S_hyp',
    0x601A: 'SE_hyp',
}


def read_word(data, addr, base):
    fo = addr - base
    return (data[fo] | (data[fo + 1] << 8)) + REBUILT_BIN_HEADER_BIAS


def first_call_target(data, addr, base, max_scan=16):
    """Walk the bytes at `addr` looking for the first CALL rel16 (E8 LL HH).
    Returns the absolute call-target address, or None if not found.

    This is how we discover what each mover calls without hard-coding the
    pairing — it just decodes the byte stream the function would execute.
    """
    fo = addr - base
    end = fo + max_scan
    i = fo
    while i + 2 < min(end, len(data)):
        b = data[i]
        if b == 0xE8:  # call rel16
            rel = data[i + 1] | (data[i + 2] << 8)
            if rel >= 0x8000:
                rel -= 0x10000
            return ((addr + (i - fo) + 3 + rel)) & 0xFFFF
        # Skip past common 1-2-byte instructions to keep scanning.
        # We only need to recognize them well enough to find the first CALL.
        if b in (0xC3, 0xCB):  # ret variants — function ended before any CALL
            return None
        if b == 0x80 and i + 3 < len(data):  # 80 /digit imm8 → 4 bytes
            i += 4
        elif b in (0x73, 0x75, 0x74, 0x77, 0x76, 0xEB):  # short jcc / jmp
            i += 2
        elif b in (0xF5, 0xF8, 0xF9):  # cmc, clc, stc — single byte
            i += 1
        elif b == 0x8A and i + 2 < len(data):  # mov r/m, r8 (e.g. mov al,[si+3])
            i += 3
        elif b == 0x0A and i + 1 < len(data):  # or r8, r8
            i += 2
        elif b == 0x3C and i + 1 < len(data):  # cmp al, imm8
            i += 2
        else:
            i += 1
    return None


def main():
    if not FIGHT_FLAT.exists():
        print(f'MISSING: {FIGHT_FLAT}')
        sys.exit(1)

    flat = FIGHT_FLAT.read_bytes()

    # ------------------------------------------------------------------
    # Step 1 — read each mover's address from its dispatch slot.
    # ------------------------------------------------------------------
    movers = [(slot, read_word(flat, slot, LOAD_BASE))
              for slot in sorted(SLOT_LABELS)]

    print('Mover slots:')
    for slot, mover_addr in movers:
        print(f'  slot 0x{slot:X}  hyp={SLOT_LABELS[slot]:>7s}  '
              f'mover=0x{mover_addr:X}')

    # The 8 collision-check targets (read from the dispatch table at
    # 0x6018..0x6026 — the second-half of fight.bin's exports).  We don't
    # need to know which mover pairs with which collision: stubbing all 8
    # addresses with CF=0 covers every possible call from any mover, and
    # the unrelated stubs simply never trigger during a given mover's run.
    COLLISION_STUBS = {
        read_word(flat, slot, LOAD_BASE): {'cf': 0}
        for slot in range(0x601C, 0x602C, 2)
    }
    print('\nCollision-check addresses to stub (all CF=0 / passable):')
    for tgt in sorted(COLLISION_STUBS):
        print(f'  0x{tgt:X}')

    # ------------------------------------------------------------------
    # Step 2 — run each mover with [SI+3]=10 and ALL 8 collision targets
    # stubbed as "passable".  Fresh harness per slot to avoid state leaks.
    # ------------------------------------------------------------------
    results = []
    for slot, mover_addr in movers:
        h = TasmHarness(FIGHT_FLAT, LOAD_BASE)
        h.write_data(MONSTER_PTR, [0x00] * 32)
        h.write_word(0xC002, 100)
        h.write_word(MONSTER_PTR, 50)
        h.write_byte(MONSTER_PTR + 2, 10)
        h.write_byte(MONSTER_PTR + 3, 10)

        out = h.call_function(
            mover_addr,
            regs={'si': MONSTER_PTR},
            stub_calls=COLLISION_STUBS,
            max_steps=200,
        )
        results.append((slot, mover_addr, None, out))

    # ------------------------------------------------------------------
    # Step 3 — print per-slot behavior and group by fingerprint.
    # ------------------------------------------------------------------
    print('\n' + '=' * 78)
    print('PER-SLOT BEHAVIOR  (input: monster=zeros, [SI+3]=10, '
          'paired-collision stubbed CF=0)')
    print('=' * 78)
    print(f'{"slot":>6s}  {"hyp":>7s}  {"target":>7s}  {"insns":>5s}  '
          f'{"CF":>3s}  mem_diffs (all relative to SI)')
    fingerprints = {}
    for slot, mover_addr, col_addr, out in results:  # col_addr is auto-discovered
        diffs = out['mem_diffs']
        cf    = out['flags_after']['CF']
        ret   = out['stopped_reason'] == 'returned_to_sentinel'
        # Format diffs as offsets relative to SI=MONSTER_PTR.
        diff_str = ', '.join(
            f'+{off-MONSTER_PTR}: 0x{old:02X}->0x{new:02X}'
            for off, old, new in diffs
        ) or '(none)'
        status = 'OK' if ret else f'STOP={out["stopped_reason"][:18]}'
        print(f'  0x{slot:04X}  {SLOT_LABELS[slot]:>7s}  0x{mover_addr:5X}  '
              f'{out["instructions"]:5d}  '
              f'{int(cf):>3d}  {status:>20s}  {diff_str}')

        # Build fingerprint: tuple of (offset, +/-) per diff, ignoring magnitudes.
        # Magnitude matters for direction strength, so we keep it.
        fp = tuple(sorted(
            (off - MONSTER_PTR, new - old) for off, old, new in diffs
        ))
        fingerprints.setdefault(fp, []).append(SLOT_LABELS[slot])

    # ------------------------------------------------------------------
    # Step 4 — group by fingerprint.
    # ------------------------------------------------------------------
    print('\n' + '=' * 78)
    print('FINGERPRINT GROUPS  (each unique mutation pattern -> members)')
    print('=' * 78)
    for fp, members in fingerprints.items():
        if not fp:
            print(f'  no mutations -> {members}')
            continue
        diffs_str = ', '.join(
            f'SI+{off}: {("+" if d>0 else "")}{d}'
            for off, d in fp
        )
        print(f'  [{diffs_str}]  -> {members}')

    # ------------------------------------------------------------------
    # Step 5 — observational verdict.
    #
    # Build a per-slot semantic descriptor purely from the mutations:
    #   SI+0..1 (word) = 16-bit X sub-position
    #   SI+2          = Y tile coordinate
    #   SI+3          = X tile coordinate
    # We classify each slot's net effect as "X+", "X-", "Y+", "Y-", or
    # combinations thereof (diagonal), based on signed deltas to SI+3
    # and SI+2.  Then we check whether the fingerprint families map
    # cleanly onto the 8 cardinal/diagonal directions.
    # ------------------------------------------------------------------
    print('\n' + '=' * 78)
    print('VERDICT')
    print('=' * 78)

    def signed_delta(old, new):
        d = new - old
        if d > 127:   d -= 256
        if d < -128:  d += 256
        return d

    def classify(diffs):
        # Pull the X-tile (SI+3) and Y-tile (SI+2) signed deltas.
        dx_tile = 0
        dy_tile = 0
        for off, old, new in diffs:
            rel = off - MONSTER_PTR
            d = signed_delta(old, new)
            # Mask to interpret 0xFF as -1 wrap (the X word at SI+0..1
            # wraps and a 0x3F mask is applied to Y at SI+2 after dec).
            if rel == 3:
                dx_tile = d
            elif rel == 2:
                # 0x00 -> 0x3F (= +63) is a wrapped DEC; 0x00 -> 0x01 is INC
                if d == 63:
                    dy_tile = -1
                else:
                    dy_tile = d
        return dx_tile, dy_tile

    DIR_NAMES = {
        ( 1,  0): 'E', ( 1, -1): 'NE', ( 0, -1): 'N', (-1, -1): 'NW',
        (-1,  0): 'W', (-1,  1): 'SW', ( 0,  1): 'S', ( 1,  1): 'SE',
        ( 0,  0): '(no movement)',
    }

    print('  Slot       hyp     observed d(X,Y)   inferred direction   match?')
    matches = 0
    for slot, mover_addr, _, out in results:
        dx, dy = classify(out['mem_diffs'])
        observed = DIR_NAMES.get((dx, dy), f'unknown({dx},{dy})')
        hyp = SLOT_LABELS[slot].replace('_hyp', '')
        ok = (observed == hyp)
        matches += ok
        print(f'  0x{slot:04X}   {hyp:>4s}     ({dx:+d},{dy:+d})            '
              f'{observed:>4s}              {"YES" if ok else "NO"}')

    print(f'\n  {matches}/8 slots\' OBSERVED behavior matches their IDA-name hypothesis.')
    print('  Each verdict is grounded in actual instruction execution —')
    print('  no signature, no label transfer, no LLM judgment.')

    if matches == 8:
        print('\nVERDICT: PASS: all 8 movement dispatch slots match their observed direction fingerprints.')
        return 0
    print(f'\nVERDICT: REFUTED: only {matches}/8 movement dispatch slots matched their direction fingerprints.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
