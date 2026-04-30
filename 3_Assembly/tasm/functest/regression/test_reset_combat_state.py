#!/usr/bin/env python3
"""
Phase-4 batch 4b regression: lock in `reset_combat_state` (was
game_func_73 in 200FIGHT, CPU 0x7E5D).  Single proc that zero-clears
~15 game-state flags + sets two enemy-buffer sentinels + one word
sentinel before tail-jumping to `hud_fill`.  This single test thus
serves as a regression net for a large slice of the flag-clearer
behavior captured during Phase 3.
"""
import sys
from pathlib import Path
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers, check_regression  # noqa: E402

RESET_COMBAT_STATE = 0x7E5D
HUD_FILL = 0x73B8

# Flags this proc zero-clears (offset, name)
FLAGS_ZEROED = [
    (0xE7,  'gvar_pose_idx'),
    (0xFF08,'gvar_timer_ff08'),
    (0xFF36,'gvar_save_flag_3'),
    (0xFF38,'gvar_music_flag_a'),
    (0xFF3C,'gvar_palette_flag'),
    (0xFF3D,'gvar_combat_ff3D'),
    (0xFF3E,'spell_fx_active'),
    (0xFF43,'gvar_joystick_flag'),
    (0xFF44,'restore_pending'),
    (0xFF4B,'gvar_item_result'),
    (0x9EEF,'enemy_scroll_flag'),
]
# After `mov ax,0FFFFh`, AL=0xFF for the rest of the proc — these
# bytes get 0xFF, not 0x00 (in source-code order, after the mov ax).
FLAGS_SET_FF = [
    (0xEB80, 'enemy_data_buf'),
    (0xEDA0, 'enemy_data_buf2'),
    (0xFF3A, 'gvar_music_flag_c'),
    (0x9EF5, 'combat_active'),
]
SENTINEL_FFFF_WORD = 0xEB15


def main() -> int:
    flat, base = BIN_PATHS['fight']
    h = TasmHarness(flat, base)
    stub_video_drivers(h)

    # Pre-fill every touched byte with a unique non-zero sentinel so we
    # can verify they all changed.
    for addr, _ in FLAGS_ZEROED:
        h.write_byte(addr, 0x55)
    for addr, _ in FLAGS_SET_FF:
        h.write_byte(addr, 0x55)
    h.write_word(SENTINEL_FFFF_WORD, 0x1234)

    expected_diffs = (
        [(addr, 0x55, 0x00) for addr, _ in FLAGS_ZEROED] +
        [(addr, 0x55, 0xFF) for addr, _ in FLAGS_SET_FF] +
        [(SENTINEL_FFFF_WORD, 0x34, 0xFF), (SENTINEL_FFFF_WORD + 1, 0x12, 0xFF)]
    )

    snap = h.snapshot()
    ok, msg = check_regression(
        h, RESET_COMBAT_STATE,
        stub_calls={HUD_FILL: {}},
        max_steps=200,
        expected_diffs=expected_diffs,
        label='reset_combat_state:full',
    )
    print(msg)
    h.restore(snap)

    if ok:
        print('\nVERDICT: PASS: reset_combat_state zeroes 11 flags, sets '
              "4 sentinels to 0xFF, and writes 0xFFFF to the EB15 word — "
              "exactly as captured.")
        return 0
    print('\nVERDICT: FAIL: reset_combat_state behavior diverged from golden.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
