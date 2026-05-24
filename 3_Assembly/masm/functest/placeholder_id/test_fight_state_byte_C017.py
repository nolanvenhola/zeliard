#!/usr/bin/env python3
"""
test_fight_state_byte_C017.py

Probe of DS:0xC017 — the placeholder `state_byte_C017` in 200FIGHT.

Static evidence (grep across working/ + source/):
  - 1 read site:  200FIGHT.asm:6791  `add bx, ds:state_byte_C017`
                  inside `start_boss_scroll` at file offset 0x306B.
                  Encoded as `03 1E C0 17` — a real disp16 memory read.
  - 1 use as immediate (NOT a memory read): 106TOWN.asm:367
                  `add ax, 0C017h` — uses 0xC017 as a hard-coded base
                  constant when computing `8*map_scroll_col + 0xC017`,
                  result stored in gvar_tile_ptr.

The two usages together imply 0xC017 is the start of a DATA TABLE
(used by 106TOWN as a base-address constant), and 200FIGHT reads the
first word of that table for an indexed lookup:
        bl = [si+6]            ; entity field (a row/column index)
        bx = 2*bl + [0xC017]   ; bx = base_word + 2*idx
        si = [bx]              ; entry-pointer dereference
That makes the byte at 0xC017 NOT a state byte but the first word of
a world/tile data table.

This probe runs `start_boss_scroll` with a sentinel word at [0xC017]
and a controlled `[si+6]`, and verifies BX ends up at the predicted
sum.  If yes, the read is value-bearing → the canonical name should be
something like `tile_data_table` or `world_tile_base`, not `state_byte_*`.

Verdict
-------
  PASS-RENAME  iff BX = 2*[si+6] + [C017_word] after start_boss_scroll
               → C017 is a data-table base; rename recommendation in
               the verdict message.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK         = 'fight'
START_BOSS_SCROLL = 0x9050   # current rebuilt 200FIGHT.bin entry
DRAW_COMBAT_HUD_LAYOUT = 0x7412


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    # Place a fake entity at DS:SI=0x1000 with [si+6]=0x05 (the index byte).
    SI_BASE = 0x1000
    IDX     = 0x05
    h.write_data(SI_BASE, [0]*16)        # zero out 16-byte entity record
    h.write_byte(SI_BASE + 6, IDX)       # entity index field

    # Sentinel word at [0xC017].  Pick a value that, when summed with
    # 2*IDX, gives a BX that's distinct from either operand alone.
    SENTINEL = 0x1234
    h.write_word(0xC017, SENTINEL)
    h.write_word(SENTINEL + 2 * IDX, 0x2000)

    # The test only needs to observe the table-base arithmetic before
    # the HUD helper; stub the helper after the value-bearing read fires.
    result = h.call_function(
        START_BOSS_SCROLL,
        regs={'si': SI_BASE, 'ax': 0, 'bx': 0},
        stub_calls={DRAW_COMBAT_HUD_LAYOUT: {}},
        watch_reads=[0xC017, 0xC018],
        watch_writes=[0xC017, 0xC018],
        max_steps=100,
    )

    expected_bx = 2 * IDX + SENTINEL
    bx_after = result['regs_after']['bx']
    reads = result['reads_observed']
    writes = result['writes_observed']

    print(f'start_boss_scroll (CPU 0x{START_BOSS_SCROLL:04X}) called with '
          f'[si+6]={IDX}, [0xC017]_word=0x{SENTINEL:04X}')
    print(f'  stopped:           {result["stopped_reason"]}')
    print(f'  instructions:      {result["instructions"]}')
    print(f'  BX after:          0x{bx_after:04X}  (expected 0x{expected_bx:04X})')
    print(f'  reads on [C017]:   {len(reads)}  {reads}')
    print(f'  writes on [C017]:  {len(writes)} {writes}')

    read_fired  = len(reads) >= 2  # word read = 2 byte accesses on C017+C018
    no_write    = len(writes) == 0
    bx_correct  = bx_after == expected_bx

    if read_fired and bx_correct and no_write:
        print('\nVERDICT: PASS: [0xC017] is read as a 16-bit value-bearing '
              'word; BX ends at 2*idx + word_at_C017 as predicted.  This '
              'is a DATA-TABLE BASE word, not a state byte.  Rename '
              "recommendation: `world_tile_base` (or similar 'table base' "
              'noun) in the canonical EQU; remove `state_byte_C017` alias.')
        return 0
    if not read_fired:
        print('\nVERDICT: INCONCLUSIVE: read on [0xC017] did not fire — '
              'execution diverged before reaching the disp16 load.')
        return 1
    print('\nVERDICT: REFUTED: BX did not equal 2*idx + word_at_C017 — '
          'something else is going on with this address.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
