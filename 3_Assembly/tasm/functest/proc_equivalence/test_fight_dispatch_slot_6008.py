#!/usr/bin/env python3
"""
test_fight_dispatch_slot_6008.py

Probes the function whose address sits at fight.bin's dispatch slot 0x6008
(which is 0x91E5 in the loaded image).  We make NO assumption about what
this function is "called" — we just observe what bytes do when executed
with controlled inputs.  The IDA hypothesis (`move_monster_E`) is one
candidate explanation; the test will either be consistent with it or rule
it out, based on observed behavior.

Calling-convention probe
------------------------
Per the bytes at 0x91E5 we already know (from evidence_check.py phase 2):
    80 7C 03 22 F5 73 01 C3 ...
which decodes as:
    cmp byte ptr [si+3], 22h     ; m_x_rel-like field at SI+3 vs constant 34
    cmc                          ; complement carry
    jnb  +1                      ; (skip 1 byte)
    retn                         ; early return

So the function reads a byte at [SI+3] and branches on whether it is < 34.
Our probes:

    Probe A — input "out of east bound":
        SI = pointer to a fake monster struct in DS
        [SI+3] = 50 (>> 34)
        Expected if this is a directional-mover: returns within ~4 insns,
        without calling out to any further code.

    Probe B — input "in bounds":
        [SI+3] = 10 (< 34)
        Expected: control flow continues past byte 7 of the function and
        executes a CALL into the chunk (we'll detect this by stubbing the
        first call site and watching it fire, OR by counting instructions).
"""

import os
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402

FIGHT_FLAT = Path('c:/Projects/Zeliard/3_Assembly/tasm/research/flatfiles/'
                  'ZELRES2/fight.bin')
LOAD_BASE  = 0x6000
SLOT_ADDR  = 0x6008          # dispatch slot we're probing
MONSTER_PTR = 0x1000         # we'll place a fake monster struct here in DS


def read_dispatch_slot(path, slot_addr, load_base):
    data = path.read_bytes()
    fo = slot_addr - load_base
    return data[fo] | (data[fo + 1] << 8)


def main():
    if not FIGHT_FLAT.exists():
        print(f'MISSING: {FIGHT_FLAT}')
        sys.exit(1)

    target = read_dispatch_slot(FIGHT_FLAT, SLOT_ADDR, LOAD_BASE)
    print(f'fight.bin dispatch slot 0x{SLOT_ADDR:X} -> function at 0x{target:X}')
    print('-' * 70)

    h = TasmHarness(FIGHT_FLAT, LOAD_BASE)

    # Lay down a minimal monster-shaped struct at DS:0x1000.
    # We don't claim what each byte means; we just set [SI+3] to the probe value.
    # (Other bytes are zeroed by Unicorn's mem_map default.)
    def reset_monster(probe_x_rel):
        h.write_data(MONSTER_PTR, [0x00] * 32)
        h.write_byte(MONSTER_PTR + 3, probe_x_rel)

    # ------------------------------------------------------------------
    # Probe A — [SI+3] = 50  (>= 34)
    # ------------------------------------------------------------------
    reset_monster(50)
    a = h.call_function(target, regs={'si': MONSTER_PTR})
    print(f'\nProbe A: [SI+3]=50  ({hex(50)})')
    print(f'  stopped:        {a["stopped_reason"]}')
    print(f'  instructions:   {a["instructions"]}')
    print(f'  last IP:        0x{a["last_ip"]:X}')
    print(f'  CF after:       {a["flags_after"]["CF"]}')
    print(f'  mem diffs:      {len(a["mem_diffs"])} byte(s) changed')
    if a['mem_diffs']:
        for off, old, new in a['mem_diffs'][:5]:
            print(f'    DS:0x{off:X}: 0x{old:02X} -> 0x{new:02X}')

    # ------------------------------------------------------------------
    # Probes B & C — [SI+3] = 10  (< 34).  The function falls through to
    # `call rel16` at offset +8 (E8 C4 00), targeting 0x91E5 + 11 + 0xC4
    # = 0x92B4.  We stub that call so the harness doesn't drag in the
    # whole proximity-map subsystem.  Two stub variants:
    #
    #   Probe B: stub with CF=0  -> function should take the "passable"
    #            branch and tail-jump to whatever advances the monster.
    #   Probe C: stub with CF=1  -> function should observe "blocked" and
    #            return early.
    # ------------------------------------------------------------------
    CALL_TARGET = 0x92B4   # check_collision_E2 per dispatch slot 0x6018

    reset_monster(10)
    b = h.call_function(
        target, regs={'si': MONSTER_PTR},
        stub_calls={CALL_TARGET: {'cf': 0}},  # "no collision"
        max_steps=2000,
    )
    print(f'\nProbe B: [SI+3]=10  with CALL_TARGET stubbed CF=0 (passable)')
    print(f'  stopped:        {b["stopped_reason"]}')
    print(f'  instructions:   {b["instructions"]}')
    print(f'  last IP:        0x{b["last_ip"]:X}')
    print(f'  CF after:       {b["flags_after"]["CF"]}')
    print(f'  mem diffs:      {len(b["mem_diffs"])} byte(s) changed')
    for off, old, new in b['mem_diffs'][:8]:
        print(f'    DS:0x{off:X}: 0x{old:02X} -> 0x{new:02X}')

    reset_monster(10)
    c = h.call_function(
        target, regs={'si': MONSTER_PTR},
        stub_calls={CALL_TARGET: {'cf': 1}},  # "collision"
        max_steps=2000,
    )
    print(f'\nProbe C: [SI+3]=10  with CALL_TARGET stubbed CF=1 (blocked)')
    print(f'  stopped:        {c["stopped_reason"]}')
    print(f'  instructions:   {c["instructions"]}')
    print(f'  last IP:        0x{c["last_ip"]:X}')
    print(f'  CF after:       {c["flags_after"]["CF"]}')
    print(f'  mem diffs:      {len(c["mem_diffs"])} byte(s) changed')
    for off, old, new in c['mem_diffs'][:8]:
        print(f'    DS:0x{off:X}: 0x{old:02X} -> 0x{new:02X}')

    # ------------------------------------------------------------------
    # Behavioral observations (no naming claim)
    # ------------------------------------------------------------------
    print('\n' + '=' * 70)
    print('OBSERVATIONS')
    print('=' * 70)

    # +1 to allow the NOP at the sentinel itself (counted as the 5th insn
    # in our trace — the actual function emitted only 4 instructions).
    early_return_when_high = (
        a['stopped_reason'] == 'returned_to_sentinel'
        and a['instructions'] <= 5
    )
    passable_mutates    = bool(b['mem_diffs'])
    blocked_no_mutation = not c['mem_diffs']
    blocked_returns_quickly = (
        c['stopped_reason'] == 'returned_to_sentinel'
        and c['instructions'] < b['instructions']
    )

    print(f'  - High input (50) returned early in <= 5 hooked steps:   '
          f'{early_return_when_high}')
    print(f'  - With "passable" stub, function MUTATED data segment:    '
          f'{passable_mutates}  ({len(b["mem_diffs"])} byte(s))')
    print(f'  - With "blocked"  stub, function LEFT data unchanged:     '
          f'{blocked_no_mutation}')
    print(f'  - "Blocked" return was faster than "passable" path:       '
          f'{blocked_returns_quickly}')

    if early_return_when_high and passable_mutates and blocked_no_mutation:
        print('\n  --> Function at 0x{:X} behaves as a CONDITIONAL MUTATOR:'
              .format(target))
        print('      • bails out when [SI+3] >= 34   (no side effects)')
        print('      • bails out when collision-stub returned CF=1   (no side effects)')
        print('      • mutates monster bytes only when both checks pass')
        print('      This is the observable signature of a movement primitive.')
        print('      It is CONSISTENT with the "move_monster_E" hypothesis,')
        print('      but the harness has only proven the control-flow shape and')
        print('      that mutation depends on both the bound and the collision')
        print('      result.  Direction (east vs other) is not verified here —')
        print('      that requires comparing this slot\'s mem diffs against the')
        print('      other 7 directional slots run with identical inputs.')
    else:
        print('\n  --> Function does NOT match the expected bounded-mutator shape.')


if __name__ == '__main__':
    main()
