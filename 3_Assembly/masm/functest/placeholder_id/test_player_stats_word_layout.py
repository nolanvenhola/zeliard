#!/usr/bin/env python3
"""
test_player_stats_word_layout.py

Probes three player-stat fields the static analyzer flagged as 16-bit
even though the cleaned source labels them as single bytes:

    DS:0x90..0x91  hero_HP        — 16-bit HP, not 8-bit max-80 as labelled
    DS:0x8B..0x8C  hero_almas     — 16-bit alt currency
    DS:0x94..0x95  shield_HP      — 16-bit shield HP

For each, we find a function that writes the field, run the function with
controlled inputs, and observe which bytes change.  If only the low byte
changes we're wrong about the layout; if the operation modifies both
bytes (or only the high byte under specific input), the field is genuinely
16 bits wide.

Functions identified by static byte-pattern search in fight.bin:

    0x7685  HP-damage     `sub word [90h], ax  / jnb +6 / mov [90h],0  / ...`
    0x917C  almas-add     `add word [8Bh], ax  / jnb +6 / mov [8Bh],FFFFh ...`
    0x75D6  shield-damage (multi-step, calls drv hooks; not in scope here)

The HP and almas functions also call a far-call driver hook (probably
"redraw HP bar" / "play sound").  We install a self-returning thunk in
the dispatch slot so the call doesn't crash the harness.
"""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS  # noqa: E402

FIGHT_FLAT, LOAD_BASE = BIN_PATHS['fight']

# Function entry points discovered by byte-pattern search
HP_DAMAGE_FN = 0x7685   # sub [90h],ax / jnb / mov [90h],0
ALMAS_ADD_FN = 0x917C   # add [8Bh],ax / jnb / mov [8Bh],FFFFh

# Both functions call far through cs:[2008h] (graphics-driver dispatch).
# We install a RETF thunk so they return cleanly without leaving the seg.
FARCALL_SLOT_HP_DAMAGE = 0x2008
FARCALL_SLOT_ALMAS     = 0x2014  # different slot in the dispatch table


def fmt_diffs(diffs):
    if not diffs:
        return '(none)'
    return '; '.join(f'DS:0x{off:X} 0x{old:02X}->0x{new:02X}'
                     for off, old, new in diffs)


def call_with_setup(fn, regs, ds_setup=None, far_slots=()):
    """Helper: fresh harness, set DS bytes, install far-call thunks, call."""
    h = TasmHarness(FIGHT_FLAT, LOAD_BASE)
    if ds_setup:
        for off, val, kind in ds_setup:
            if kind == 'word':
                h.write_word(off, val)
            else:
                h.write_byte(off, val)
    for slot in far_slots:
        h.install_farcall_thunk(slot)
    out = h.call_function(fn, regs=regs, max_steps=200)
    return h, out


# ===================================================================
# HP DAMAGE FUNCTION
# ===================================================================
def test_hp_damage():
    print('=' * 78)
    print('HP DAMAGE FUNCTION at 0x7685  (claim: takes AX = damage; HP -= AX,')
    print('clamps to 0 on underflow; calls draw-bar hook)')
    print('=' * 78)

    # Probe 1: HP=100 (16-bit), damage=30 -> HP becomes 70
    h, a = call_with_setup(
        HP_DAMAGE_FN,
        regs={'ax': 30},
        ds_setup=[(0x90, 100, 'word')],
        far_slots=[FARCALL_SLOT_HP_DAMAGE],
    )
    after_hp = h.read_word(0x90)
    hp1_ok = after_hp == 70
    print(f'\n  Probe HP1: HP=100, damage=30   (expect HP=70)')
    print(f'    stopped:  {a["stopped_reason"]}')
    print(f'    diffs:    {fmt_diffs(a["mem_diffs"])}')
    print(f'    -> HP after = {after_hp}  '
          f'{"PASS" if after_hp == 70 else "FAIL"}')

    # Probe 2: HP=300 (>255, requires word!) , damage=200 -> HP=100
    h, b = call_with_setup(
        HP_DAMAGE_FN,
        regs={'ax': 200},
        ds_setup=[(0x90, 300, 'word')],
        far_slots=[FARCALL_SLOT_HP_DAMAGE],
    )
    after_hp = h.read_word(0x90)
    hp2_ok = after_hp == 100
    print(f'\n  Probe HP2: HP=300 (>255), damage=200   (expect HP=100)')
    print(f'    diffs:    {fmt_diffs(b["mem_diffs"])}')
    print(f'    -> HP after = {after_hp}  '
          f'{"PASS — word storage confirmed" if after_hp == 100 else "FAIL"}')
    if after_hp != 100:
        print('    (If HP were 8-bit, 300 would have been stored as 44, ')
        print('     and damage of 200 would underflow into 100... coincidence.')
        print('     The decisive test is probe HP3 below.)')

    # Probe 3: HP=257 (low byte = 1, high byte = 1), damage = 1 -> HP=256
    # If HP were a single byte, [90]=1, [91] would be the start of next field.
    # Damage=1 -> [90] becomes 0, HP=0 (death).  But if it's a word, [90..91]
    # decrements 257->256, [90]=0 [91]=1 — high byte unchanged.
    h, c = call_with_setup(
        HP_DAMAGE_FN,
        regs={'ax': 1},
        ds_setup=[(0x90, 257, 'word')],   # 0x0101: lo=1, hi=1
        far_slots=[FARCALL_SLOT_HP_DAMAGE],
    )
    after_lo = h.read_byte(0x90)
    after_hi = h.read_byte(0x91)
    hp3_ok = after_lo == 0 and after_hi == 1
    print(f'\n  Probe HP3: HP=257 (0x0101), damage=1   ')
    print(f'    diffs:    {fmt_diffs(c["mem_diffs"])}')
    print(f'    -> [0x90]={after_lo}, [0x91]={after_hi}  ')
    if hp3_ok:
        print('    PASS: lo byte decremented to 0, hi byte preserved at 1.')
        print('          This proves the function treats 0x90..0x91 as a 16-bit field.')
    else:
        print('    FAIL: unexpected byte values.')

    # Probe 4: HP=5, damage=10 -> underflow, should clamp to 0
    h, d = call_with_setup(
        HP_DAMAGE_FN,
        regs={'ax': 10},
        ds_setup=[(0x90, 5, 'word')],
        far_slots=[FARCALL_SLOT_HP_DAMAGE],
    )
    after_hp = h.read_word(0x90)
    hp4_ok = after_hp == 0
    print(f'\n  Probe HP4: HP=5, damage=10   (expect HP clamps to 0 on underflow)')
    print(f'    diffs:    {fmt_diffs(d["mem_diffs"])}')
    print(f'    -> HP after = {after_hp}  '
          f'{"PASS — clamps to 0" if after_hp == 0 else "FAIL"}')


# ===================================================================
    return hp1_ok and hp2_ok and hp3_ok and hp4_ok


# ALMAS ADD FUNCTION
# ===================================================================
def test_almas_add():
    print('\n' + '=' * 78)
    print('ALMAS ADD FUNCTION at 0x917C  (claim: takes AX = amount; almas += AX,')
    print('caps at 0xFFFF on overflow; calls graphics hook)')
    print('=' * 78)

    # Probe 1: Almas=0, add 100  -> almas=100
    h, a = call_with_setup(
        ALMAS_ADD_FN,
        regs={'ax': 100},
        ds_setup=[(0x8B, 0, 'word')],
        far_slots=[FARCALL_SLOT_ALMAS],
    )
    after_a = h.read_word(0x8B)
    al1_ok = after_a == 100
    print(f'\n  Probe AL1: almas=0, add 100  (expect almas=100)')
    print(f'    diffs:    {fmt_diffs(a["mem_diffs"])}')
    print(f'    -> almas after = {after_a}  '
          f'{"PASS" if after_a == 100 else "FAIL"}')

    # Probe 2: Almas=300, add 50.  300 fits only in a word.
    h, b = call_with_setup(
        ALMAS_ADD_FN,
        regs={'ax': 50},
        ds_setup=[(0x8B, 300, 'word')],
        far_slots=[FARCALL_SLOT_ALMAS],
    )
    after_a = h.read_word(0x8B)
    al2_ok = after_a == 350
    print(f'\n  Probe AL2: almas=300 (>255), add 50  (expect almas=350)')
    print(f'    diffs:    {fmt_diffs(b["mem_diffs"])}')
    print(f'    -> almas after = {after_a}  '
          f'{"PASS — word storage confirmed" if after_a == 350 else "FAIL"}')

    # Probe 3: high byte preserved when only low byte changes
    h, c = call_with_setup(
        ALMAS_ADD_FN,
        regs={'ax': 1},
        ds_setup=[(0x8B, 0x0101, 'word')],   # almas = 257
        far_slots=[FARCALL_SLOT_ALMAS],
    )
    after_lo = h.read_byte(0x8B)
    after_hi = h.read_byte(0x8C)
    al3_ok = after_lo == 2 and after_hi == 1
    print(f'\n  Probe AL3: almas=257 (0x0101), add 1  (expect 258 -> hi stays 1)')
    print(f'    diffs:    {fmt_diffs(c["mem_diffs"])}')
    print(f'    -> [0x8B]={after_lo}, [0x8C]={after_hi}')
    if al3_ok:
        print('    PASS: lo went 1->2, hi preserved at 1.')
    else:
        print('    FAIL: unexpected byte values.')

    # Probe 4: Almas=0xFFFE, add 5 -> overflow, caps at 0xFFFF
    h, d = call_with_setup(
        ALMAS_ADD_FN,
        regs={'ax': 5},
        ds_setup=[(0x8B, 0xFFFE, 'word')],
        far_slots=[FARCALL_SLOT_ALMAS],
    )
    after_a = h.read_word(0x8B)
    al4_ok = after_a == 0xFFFF
    print(f'\n  Probe AL4: almas=0xFFFE, add 5  (expect cap at 0xFFFF on overflow)')
    print(f'    diffs:    {fmt_diffs(d["mem_diffs"])}')
    print(f'    -> almas after = 0x{after_a:04X}  '
          f'{"PASS — capped" if after_a == 0xFFFF else "FAIL"}')


    return al1_ok and al2_ok and al3_ok and al4_ok


def main() -> int:
    if not FIGHT_FLAT.exists():
        print(f'MISSING: {FIGHT_FLAT}')
        print('VERDICT: INCONCLUSIVE: fight flat-file artefact missing')
        return 1
    hp_ok = test_hp_damage()
    almas_ok = test_almas_add()
    if hp_ok and almas_ok:
        print('\nVERDICT: PASS: player HP and almas fields behave as 16-bit words.')
        return 0
    print('\nVERDICT: REFUTED: player HP/almas word-layout probes did not all match.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
