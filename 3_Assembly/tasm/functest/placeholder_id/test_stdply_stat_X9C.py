#!/usr/bin/env python3
"""
test_stdply_stat_X9C.py

Probe of DS:0x9C — the placeholder byte `stat_X9C` in stdply.

Static evidence (grep across working/ + source/):
  - 1 write site:  200FIGHT.asm:6816  `mov byte ptr ds:[9Ch],0FFh`
                   inside `entity_fn_e_4` success path (after game_func_118
                   returns CF=0); then jumps to entity_deactivate.
  - 0 read sites anywhere in the cleaned tree, raw Sourcer dump, or drivers.

The static finding alone makes this byte a vestigial / write-only signal
candidate.  This runtime probe corroborates by:
  (a) confirming the writer at entity_fn_e_4 actually flips [9Ch] to 0xFF
      when game_func_118 returns CF=0;
  (b) installing a UC_HOOK_MEM_READ on DS:0x9C and verifying NO read
      fires during the writer's execution path (writer + entity_deactivate
      tail).

Verdict
-------
  PASS  iff write observed AND zero reads observed → vestigial / write-only.
  FAIL  iff a read fires (would mean grep missed something — call subtree
        accesses [9Ch] via base+offset arithmetic).
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK     = 'fight'
ENTITY_FN_E_4 = 0x9086    # 200FIGHT.LST: offset 0x3086 + load_base 0x6000
GAME_FUNC_118 = 0x90DA    # 200FIGHT.LST: offset 0x30DA + load_base 0x6000


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print(f'MISSING: {flat_path}')
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    # Sentinel value at [9Ch] — distinct from both 0 (initial) and 0xFF
    # (the value the writer should set).
    h.write_byte(0x9C, 0x55)
    # Give SI a safe slot for entity_deactivate's `mov word ptr [si], 0FF00h`
    # to land in.  DS:0x1000 is an unused harness scratch area.
    SI_SAFE = 0x1000

    # Stub game_func_118 to return CF=0 so the entity_fn_e_4 path takes
    # the success branch that writes [9Ch].  game_func_118 is reached via
    # near-call from entity_fn_e_4, so the stub_calls path applies.
    result = h.call_function(
        ENTITY_FN_E_4,
        regs={'si': SI_SAFE, 'dx': 0, 'ax': 0},
        stub_calls={GAME_FUNC_118: {'cf': 0, 'ax': 0}},
        watch_reads=[0x9C],
        watch_writes=[0x9C],
        max_steps=200,
    )

    # ----- observations ----------------------------------------------------
    val_after = h.read_byte(0x9C)
    reads     = result['reads_observed']
    writes    = result['writes_observed']
    stopped   = result['stopped_reason']

    print(f'entity_fn_e_4 (CPU 0x{ENTITY_FN_E_4:04X}) called with stub '
          f'game_func_118 -> CF=0')
    print(f'  stopped:        {stopped}')
    print(f'  instructions:   {result["instructions"]}')
    print(f'  [9Ch] before:   0x55 (sentinel)')
    print(f'  [9Ch] after:    0x{val_after:02X}  (expect 0xFF if writer fired)')
    print(f'  reads on [9Ch]: {len(reads)} {reads}')
    print(f'  writes on [9Ch]: {len(writes)} {writes}')
    if h.format_diffs(result):
        print(f'  byte diffs:\n    ' + h.format_diffs(result).replace('\n', '\n    '))

    # ----- verdict ---------------------------------------------------------
    write_fired = val_after == 0xFF and len(writes) >= 1
    no_read     = len(reads) == 0

    if write_fired and no_read:
        print('\nVERDICT: PASS: stat_X9C is write-only — entity_fn_e_4 sets '
              'it to 0xFF on game_func_118 success, no reader observed in '
              'its call subtree (consistent with grep showing 0 read sites).')
        return 0
    if not write_fired:
        print('\nVERDICT: INCONCLUSIVE: writer did not fire — stub or path '
              'assumption wrong; cannot speak to read behavior.')
        return 1
    print('\nVERDICT: REFUTED: a reader fired on [9Ch] during the writer '
          "subtree — grep missed it; static 'vestigial' claim is wrong.")
    return 1


if __name__ == '__main__':
    sys.exit(main())
