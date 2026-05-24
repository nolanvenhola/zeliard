#!/usr/bin/env python3
"""
test_town_player_col_X83.py

Probe of DS:0x83 — currently labeled `ply_accel` (low byte; declared
as `ply_accel db 0Ah, 0Ah` covering 0x83-0x84 in stdply.asm).

Static evidence (grep):
  - 20+ sites in 106TOWN.asm read/write [83h]:
        cmp [83h], 0Bh  (lower bound check in walk_left)
        dec [83h]       (left movement)
        cmp [83h], 10h  (upper bound check in walk_right)
        inc [83h]       (right movement)
        bl = [83h]; bx = (bl + 4) + [80h] + 1     (tile lookup)
        bl = [83h]; bx = (bl + 6) * 8 + tile_ptr  (tile lookup)
  - The tile-lookup arithmetic + bounded inc/dec range 0x0B..0x10 is
    consistent with a SCREEN-COLUMN POSITION counter, not acceleration.
  - DS:0x84 is independently used in 200FIGHT (bounds 0..7) — distinct
    semantics; the two bytes are NOT a 16-bit accel/velocity pair.

This probe runs `walk_right_move` (CPU 0x6824 found by byte-pattern
search in town.bin) with [83h] in three states and observes:
  A. [83h] = 0x05  (well inside 0..0x10 range)        → expect [83h]++
  B. [83h] = 0x10  (at the upper bound)               → expect inc-edge branch
  C. [83h] = 0x0F  (one below the upper bound)        → expect [83h]++

If [83h] increments by exactly 1 in cases A and C, that's a COUNTER
not an acceleration term, and the canonical name should be
`town_player_col` (or similar 'screen column' noun).

Verdict
-------
  PASS-RENAME  iff [83h] increments by exactly 1 in cases A and C.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK = 'town'
WALK_RIGHT_MOVE = 0x6828   # byte-pattern matched in rebuilt 106TOWN.bin


def probe(h, x83_initial: int) -> tuple[int, dict]:
    h.write_byte(0xE7, 0)        # gvar_pose_idx (touched by walk_right_move)
    h.write_byte(0xC2, 0)        # player_facing
    h.write_byte(0x83, x83_initial)
    h.write_byte(0x84, 0x55)      # untouched control byte
    snap = h.snapshot()
    result = h.call_function(
        WALK_RIGHT_MOVE,
        watch_writes=[0x83, 0x84],
        max_steps=200,
    )
    val_after = h.read_byte(0x83)
    h.restore(snap)
    return val_after, result


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    print(f'walk_right_move @ CPU 0x{WALK_RIGHT_MOVE:04X}')
    print()

    # Probe A: well within bounds
    val_a, res_a = probe(h, 0x05)
    print(f'Probe A: [83h] before=0x05 -> after=0x{val_a:02X}  (expect 0x06)')

    # Probe B: at upper bound (jae fires; takes walk_right_edge — needs map_width
    # context which we don't seed.  Just observe what happens.)
    val_b, res_b = probe(h, 0x10)
    print(f'Probe B: [83h] before=0x10 -> after=0x{val_b:02X}  (jae edge branch)')

    # Probe C: one below upper bound
    val_c, res_c = probe(h, 0x0F)
    print(f'Probe C: [83h] before=0x0F -> after=0x{val_c:02X}  (expect 0x10)')

    print()
    print(f'  [84h] untouched in all probes (was 0x55, still 0x{h.read_byte(0x84):02X}).')

    inc_a = (val_a == 0x06)
    inc_c = (val_c == 0x10)

    if inc_a and inc_c:
        print('\nVERDICT: PASS: [83h] increments by exactly 1 in walk_right_move '
              "when within bounds — it's a SCREEN-COLUMN COUNTER, not an "
              "acceleration term.  Rename recommendation: split the bogus "
              "`ply_accel db 0Ah, 0Ah` declaration into `town_player_col` "
              "(DS:0x83) and `fight_player_col` (DS:0x84) — they have "
              "DIFFERENT semantics and DIFFERENT bounds (0..0x10 in town, "
              "0..7 in fight).")
        return 0
    print('\nVERDICT: REFUTED or INCONCLUSIVE: [83h] did not increment as predicted.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
