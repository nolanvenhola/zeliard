#!/usr/bin/env python3
"""
Phase-4 batch 4e regression: lock in the small gate / classifier procs
adjacent to the combat-FSM bytes.  These are the simplest "behavior is
still as captured" tests since each proc is a 5-30 byte branchless
classifier.

  gate_spell_fx_active        (CPU 0x8AB4): tests [spell_fx_active]
  is_non_area7_slot_b_entity  (CPU 0x6947): area_num + slot lookup
  is_unknown_or_area5_slot_b  (CPU 0x92F2): tri-condition classifier
  is_unknown_or_area5_slot_c  (CPU 0x9348): twin of slot_b version

The full combat-input FSM (FF45/46/47 writers) is omitted from this
batch — it's tightly coupled to int 61h + read_joystick and unsuitable
for clean unit testing.  Coverage of those bytes comes via the
adjacent gates here plus the existing probes under proc_equivalence/.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness, DATA_SEG  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, check_regression, resolve_proc  # noqa: E402

SPELL_FX_ACTIVE = 0xFF3E
AREA_NUM = 0xC012
GVAR_GAME_SEG = 0xFF2C


def main() -> int:
    flat, base = BIN_PATHS['fight']
    gate_spell_fx = base + resolve_proc('fight', 'gate_spell_fx_active')
    gate_spell_fx_fallthrough = gate_spell_fx + 8
    is_non_area7_slot_b = base + resolve_proc('fight', 'is_non_area7_slot_b_entity')
    is_unknown_or_a5_b = base + resolve_proc('fight', 'is_unknown_or_area5_slot_b')
    is_unknown_or_a5_c = base + resolve_proc('fight', 'is_unknown_or_area5_slot_c')
    h = TasmHarness(flat, base)
    stub_video_drivers(h)
    h.write_code(GVAR_GAME_SEG, [DATA_SEG & 0xFF, (DATA_SEG >> 8) & 0xFF])
    # enemy_id_table at 0x8000: include all IDs we use (0x21 in slot_b,
    # 0x31 in slot_c, 0x41 in slot_a) so they all classify as "known".
    h.write_data(0x8000, bytes([0x10, 0x21, 0x31, 0x41] + [0]*0x14))
    # Slot tables
    h.write_data(0x8024, bytes([0x40, 0x41, 0x42, 0x43]))  # slot_a
    h.write_data(0x8028, bytes([0x20, 0x21, 0x22, 0x23]))  # slot_b
    h.write_data(0x802C, bytes([0x30, 0x31, 0x32, 0x33]))  # slot_c

    failures = []

    # ---- gate_spell_fx_active ----
    # spell_fx_active=0  -> retn (no fall-through; the +3 jump skips retn
    # only if non-zero)
    h.write_byte(SPELL_FX_ACTIVE, 0)
    snap = h.snapshot()
    ok, msg = check_regression(
        h, gate_spell_fx, expected_diffs=[],
        label='gate_spell_fx:inactive')
    print(msg);  failures += [] if ok else ['gate_spell_fx:inactive']
    h.restore(snap)

    # spell_fx_active!=0 -> skip RETN and fall through into the next handler.
    # Stub the fall-through target so the branch is observable without dragging
    # in the selected-spell dispatch machinery that follows it.
    h.write_byte(SPELL_FX_ACTIVE, 1)
    snap = h.snapshot()
    result = h.call_function(
        gate_spell_fx,
        stub_calls={gate_spell_fx_fallthrough: {}},
        max_steps=50)
    active_ok = (
        result["stopped_reason"] == "returned_to_sentinel"
        and result.get("stubs_fired", []) == [gate_spell_fx_fallthrough]
    )
    print("gate_spell_fx:active:",
          "PASS" if active_ok else f"FAIL {result['stopped_reason']} stubs={result.get('stubs_fired', [])}")
    failures += [] if active_ok else ['gate_spell_fx:active']
    h.restore(snap)

    # ---- is_non_area7_slot_b_entity ----
    cases = [
        ('inA7_b:area7', 7, 0x21, False),
        ('inA7_b:area3_slot_b', 3, 0x21, True),
        ('inA7_b:area3_slot_a', 3, 0x41, False),
        ('inA7_b:unknown', 3, 0x99, False),
    ]
    for label, area, eid, expect_cf in cases:
        h.write_byte(AREA_NUM, area)
        h.write_byte(0x1000, eid)
        snap = h.snapshot()
        ok, msg = check_regression(
            h, is_non_area7_slot_b, regs={'si': 0x1000},
            expected_flags={'CF': expect_cf}, label=label)
        print(msg);  failures += [] if ok else [label]
        h.restore(snap)

    # ---- is_unknown_or_area5_slot_b ----
    cases = [
        ('unkA5_b:area5_slot_b',  5, 0x21, True),
        ('unkA5_b:area5_slot_a',  5, 0x41, False),
        ('unkA5_b:area3',         3, 0x21, False),
        ('unkA5_b:unknown',       5, 0x05, True),
    ]
    for label, area, eid, expect_cf in cases:
        h.write_byte(AREA_NUM, area)
        h.write_byte(0x1000, eid)
        snap = h.snapshot()
        ok, msg = check_regression(
            h, is_unknown_or_a5_b,
            regs={'di': 0x1000, 'si': 0x3000},
            expected_flags={'CF': expect_cf}, label=label)
        print(msg);  failures += [] if ok else [label]
        h.restore(snap)

    # ---- is_unknown_or_area5_slot_c ----
    cases = [
        ('unkA5_c:area5_slot_c',  5, 0x31, True),
        ('unkA5_c:area5_slot_b',  5, 0x21, False),
        ('unkA5_c:area3',         3, 0x31, False),
        ('unkA5_c:unknown',       5, 0x05, True),
    ]
    for label, area, eid, expect_cf in cases:
        h.write_byte(AREA_NUM, area)
        h.write_byte(0x1000, eid)
        snap = h.snapshot()
        ok, msg = check_regression(
            h, is_unknown_or_a5_c,
            regs={'di': 0x1000, 'si': 0x3000},
            expected_flags={'CF': expect_cf}, label=label)
        print(msg);  failures += [] if ok else [label]
        h.restore(snap)

    if failures:
        print(f'\nVERDICT: FAIL: {failures}')
        return 1
    print('\nVERDICT: PASS: all 14 gate/classifier scenarios green.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
