#!/usr/bin/env python3
"""
Phase-4 batch 4a regression net — locks in semantics of the arithmetic
procs renamed during Phases 2-3:

  hero_gold_add        (town slot 0x600C target)   24-bit add+adc+carry
  hero_almas_add       (CPU 0x9183 in fight)       16-bit add with FFFF cap
  hero_HP_subtract     (CPU 0x768A in fight)       16-bit sub with 0 clamp
  hero_bank_add        (BANKPRO at 0xA345)         24-bit add+adc+carry
  check_gold_sufficient (town slot 0x600A target)  24-bit compare

These are tighter than the discovery-style probes under
proc_equivalence/ — they assert exact byte deltas + flag state for
fixed inputs.  A future refactor that silently breaks one of these
procs fails the relevant scenario loudly.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, check_regression  # noqa: E402

# Function entry points (CPU addresses, current build)
HERO_HP_SUBTRACT = 0x768A          # 200FIGHT
HERO_ALMAS_ADD   = 0x9183          # 200FIGHT
# town dispatch slot targets (read at runtime from the slot word)
TOWN_GOLD_ADD_SLOT  = 0x600C
TOWN_GOLD_CHECK_SLOT = 0x600A
# bank deposit add+adc pair (BANKPRO loaded at 0xA000; offset 0x345)
BANK_ADD_ADC_ADDR = 0xA349   # rebuilt bin/zelres2/213BANKP.bin (offset 0x349)


def read_slot_target(flat_path, slot_addr, load_base):
    data = flat_path.read_bytes()
    fo = slot_addr - load_base
    return data[fo] | (data[fo + 1] << 8)


def main() -> int:
    fight_path, fight_base = BIN_PATHS['fight']
    town_path,  town_base  = BIN_PATHS['town']
    bank_path,  bank_base  = BIN_PATHS['bank']
    if not (fight_path.exists() and town_path.exists() and bank_path.exists()):
        print('VERDICT: INCONCLUSIVE: required bin missing')
        return 1

    failures = []

    # ---------- hero_HP_subtract scenarios ----------
    h = TasmHarness(fight_path, fight_base)
    stub_video_drivers(h)
    SCENARIOS = [
        ('HP_sub:normal', dict(hp=50, dmg=20),
            [(0x90, 50, 30)]),
        ('HP_sub:underflow_clamp', dict(hp=10, dmg=50),
            [(0x90, 10, 0)]),
        ('HP_sub:no_underflow', dict(hp=0xFFFF, dmg=1),
            [(0x90, 0xFF, 0xFE)]),
    ]
    for label, inp, expected in SCENARIOS:
        h.write_word(0x90, inp['hp'])
        snap = h.snapshot()
        ok, msg = check_regression(
            h, HERO_HP_SUBTRACT,
            regs={'ax': inp['dmg']},
            expected_diffs=expected,
            label=label,
        )
        print(msg)
        if not ok: failures.append(label)
        h.restore(snap)

    # ---------- hero_almas_add scenarios ----------
    SCENARIOS = [
        ('almas_add:simple', dict(almas=100, ax=50),
            [(0x8B, 100, 150)]),
        ('almas_add:overflow_cap', dict(almas=0xFFF0, ax=0x10),
            [(0x8B, 0xF0, 0xFF)]),  # high byte was already 0xFF, no change
        ('almas_add:carry_into_high', dict(almas=0xFE, ax=2),
            [(0x8B, 0xFE, 0x00), (0x8C, 0, 1)]),
    ]
    for label, inp, expected in SCENARIOS:
        h.write_word(0x8B, inp['almas'])
        snap = h.snapshot()
        ok, msg = check_regression(
            h, HERO_ALMAS_ADD,
            regs={'ax': inp['ax']},
            expected_diffs=expected,
            label=label,
        )
        print(msg)
        if not ok: failures.append(label)
        h.restore(snap)

    # ---------- hero_gold_add (town slot 0x600C target) ----------
    h2 = TasmHarness(town_path, town_base)
    target = read_slot_target(town_path, TOWN_GOLD_ADD_SLOT, town_base)
    SCENARIOS = [
        ('gold_add:simple', dict(gold_hi=0, gold_lo=0, ax=100, dx=0),
            [(0x86, 0, 100)]),
        ('gold_add:carry', dict(gold_hi=0, gold_lo=0xFFFE, ax=5, dx=0),
            [(0x85, 0, 1), (0x86, 0xFE, 0x03), (0x87, 0xFF, 0x00)]),
    ]
    for label, inp, expected in SCENARIOS:
        h2.write_byte(0x85, inp['gold_hi'])
        h2.write_word(0x86, inp['gold_lo'])
        snap = h2.snapshot()
        ok, msg = check_regression(
            h2, target,
            regs={'ax': inp['ax'], 'dx': inp['dx']},
            expected_diffs=expected,
            label=label,
        )
        print(msg)
        if not ok: failures.append(label)
        h2.restore(snap)

    # ---------- check_gold_sufficient (town slot 0x600A target) ----------
    target = read_slot_target(town_path, TOWN_GOLD_CHECK_SLOT, town_base)
    # CF=1 if gold < request, CF=0 if gold >= request
    SCENARIOS = [
        ('gold_check:enough',     dict(gold_hi=0, gold_lo=200, ax=100, dx=0), {'CF': False}),
        ('gold_check:not_enough', dict(gold_hi=0, gold_lo=50,  ax=100, dx=0), {'CF': True}),
        ('gold_check:exact',      dict(gold_hi=0, gold_lo=100, ax=100, dx=0), {'CF': False}),
    ]
    for label, inp, expected_flags in SCENARIOS:
        h2.write_byte(0x85, inp['gold_hi'])
        h2.write_word(0x86, inp['gold_lo'])
        snap = h2.snapshot()
        ok, msg = check_regression(
            h2, target,
            regs={'ax': inp['ax'], 'dx': inp['dx']},
            expected_flags=expected_flags,
            label=label,
        )
        print(msg)
        if not ok: failures.append(label)
        h2.restore(snap)

    # ---------- hero_bank add+adc (BANKPRO at 0xA345) ----------
    h3 = TasmHarness(bank_path, bank_base)
    SCENARIOS = [
        ('bank_add:simple', dict(hi=0, lo=0, ax=100, dl=0),
            [(0x89, 0, 100)]),
        ('bank_add:carry', dict(hi=0, lo=0xFFFE, ax=5, dl=0),
            [(0x88, 0, 1), (0x89, 0xFE, 0x03), (0x8A, 0xFF, 0x00)]),
        ('bank_add:nonzero_dl', dict(hi=0, lo=0, ax=10, dl=2),
            [(0x88, 0, 2), (0x89, 0, 10)]),
    ]
    for label, inp, expected in SCENARIOS:
        h3.write_byte(0x88, inp['hi'])
        h3.write_word(0x89, inp['lo'])
        snap = h3.snapshot()
        ok, msg = check_regression(
            h3, BANK_ADD_ADC_ADDR,
            regs={'ax': inp['ax'], 'dx': inp['dl'] & 0xFF},
            max_steps=2,    # exactly: ADD then ADC
            expected_diffs=expected,
            label=label,
        )
        print(msg)
        if not ok: failures.append(label)
        h3.restore(snap)

    if failures:
        print(f'\nVERDICT: FAIL: {len(failures)} scenario(s) regressed: {failures}')
        return 1
    print(f'\nVERDICT: PASS: all 14 arithmetic regression scenarios green.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
