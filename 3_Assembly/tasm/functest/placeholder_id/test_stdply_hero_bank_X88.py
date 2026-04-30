#!/usr/bin/env python3
"""
test_stdply_hero_bank_X88.py

Probe of DS:0x88..0x8A — currently labeled `stat_X88_hi/lo` (declared
in stdply.asm/stdply.inc as a placeholder 24-bit field).

Static evidence (grep across working/):
  - 0x88..0x8A is heavily used in 213BANKP.asm (the bank shop chunk):
        add word ptr ds:[89h], ax     ← deposit low word
        adc byte ptr ds:[88h], dl     ← carry into hi byte
        mov dl, [88h]; mov ax, [89h]  ← load bank balance for display/check
  - This is the SAME 24-bit multi-precision pattern as hero_gold_hi/lo
    (0x85 hi + 0x86..0x87 lo word).  213BANKP also writes back into
    [85h]:[86h] (hero gold) when withdrawing — making bank ↔ gold the
    obvious symmetry.
  - The bank chunk's `script_take_item` callback (line 415) follows the
    pattern of TAKE-FROM-GOLD, then ADD-TO-BANK; the hi/lo split lets
    the 24-bit value reach 0xFFFFFF (~16M units), same cap as gold.

This probe loads BANKPRO.BIN, sets the byte triple to a known value,
positions execution at the add+adc pair (file offset 0x0345, found via
byte-pattern search), runs both instructions with AX=100/DL=0, and
verifies the 24-bit value increments by 100.

A second probe tests carry propagation: low_word=0xFFFE + AX=5 should
spill into the hi byte (since 0xFFFE+5 = 0x10003).

Verdict
-------
  PASS-RENAME  iff the deposit add increments [89h] correctly AND the
               carry propagates into [88h] when low overflows.
               → DS:0x88..0x8A is `hero_bank_hi/lo` (24-bit banked
               gold), NOT a placeholder stat field.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402

# 213BANKP.bin is `org 0` and position-independent for our local DS reads,
# so any load_base works.  We use 0xA000 (the typical shop-chunk base).
BANK_BIN = (HERE.parent.parent / 'research' / 'flatfiles' /
            'ZELRES2' / 'BANKPRO.BIN')
LOAD_BASE = 0xA000
ADD_ADC_OFFSET = 0x0345  # byte-pattern matched for `add [89h],ax; adc [88h],dl`
ADD_ADC_ADDR   = LOAD_BASE + ADD_ADC_OFFSET  # = 0xA345


def probe(h, bank_hi, bank_lo, ax_in, dl_in):
    h.write_byte(0x88, bank_hi)
    h.write_word(0x89, bank_lo)
    snap = h.snapshot()
    result = h.call_function(
        ADD_ADC_ADDR,
        regs={'ax': ax_in, 'dx': dl_in & 0xFF},  # DL = dx low byte
        watch_writes=[0x88, 0x89, 0x8A],
        max_steps=2,    # exactly: ADD then ADC
    )
    new_hi = h.read_byte(0x88)
    new_lo = h.read_word(0x89)
    h.restore(snap)
    return new_hi, new_lo, result


def main() -> int:
    if not BANK_BIN.exists():
        print(f'MISSING: {BANK_BIN}')
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1
    h = TasmHarness(BANK_BIN, LOAD_BASE)

    print(f'BANKPRO.BIN add+adc @ CPU 0x{ADD_ADC_ADDR:04X} (file_off 0x{ADD_ADC_OFFSET:04X})')
    print()

    # Probe A: simple deposit
    new_hi, new_lo, _ = probe(h, bank_hi=0, bank_lo=0, ax_in=100, dl_in=0)
    print(f'Probe A: deposit 100 into empty bank')
    print(f'  before: [88h]=0  [89h..8Ah]=0  AX=100')
    print(f'  after:  [88h]=0x{new_hi:02X}  [89h..8Ah]=0x{new_lo:04X}')
    a_ok = (new_hi == 0 and new_lo == 100)
    print(f'  -> {"OK" if a_ok else "WRONG"}: expected hi=0, lo=100')

    # Probe B: carry propagation
    new_hi, new_lo, _ = probe(h, bank_hi=0, bank_lo=0xFFFE, ax_in=5, dl_in=0)
    print(f'\nProbe B: carry propagation — bank lo=0xFFFE, deposit 5')
    print(f'  before: [88h]=0  [89h..8Ah]=0xFFFE  AX=5')
    print(f'  after:  [88h]=0x{new_hi:02X}  [89h..8Ah]=0x{new_lo:04X}')
    b_ok = (new_hi == 1 and new_lo == 0x0003)
    print(f'  -> {"OK" if b_ok else "WRONG"}: expected hi=1 (carry), lo=0x0003')

    # Probe C: deposit with non-zero hi component (DL=2)
    new_hi, new_lo, _ = probe(h, bank_hi=0, bank_lo=0, ax_in=10, dl_in=2)
    print(f'\nProbe C: 24-bit deposit with non-zero hi')
    print(f'  before: [88h]=0  [89h..8Ah]=0  AX=10  DL=2')
    print(f'  after:  [88h]=0x{new_hi:02X}  [89h..8Ah]=0x{new_lo:04X}')
    c_ok = (new_hi == 2 and new_lo == 10)
    print(f'  -> {"OK" if c_ok else "WRONG"}: expected hi=2, lo=10')

    if a_ok and b_ok and c_ok:
        print('\nVERDICT: PASS: DS:0x88..0x8A is a 24-bit multi-precision '
              'value (hi byte + low word, identical layout to hero_gold).  '
              'Bank chunk uses it as the deposit accumulator, mirroring '
              'gold semantics.  Rename recommendation: `hero_bank_hi` '
              '(0x88) + `hero_bank_lo` (0x89..0x8A); replace the placeholder '
              '`stat_X88_hi/lo` with the canonical names in stdply.inc.')
        return 0
    print('\nVERDICT: REFUTED or INCONCLUSIVE: bank-add semantics did not '
          'match the predicted 24-bit hi+lo layout.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
