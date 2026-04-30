#!/usr/bin/env python3
"""
test_stdply_stat_X9F.py

Probe of DS:0x9F — the placeholder byte `stat_X9F` in stdply.

Static evidence (grep across working/ + source/):
  - 1 write site:  106TOWN.asm:313  `mov byte ptr ds:[9Fh],al` (after
                   xor al,al — i.e. CLEARS the byte every frame).  This
                   is inside the town's frame_update prologue, alongside
                   gvar_skip_input/skip_flag2/cur_magic_idx clears.
  - 0 read sites anywhere in cleaned tree, raw Sourcer dump, or drivers.

frame_update is non-returning (main town loop), so we can't call it as
a proc.  Instead we start emulation at the `xor al,al` two instructions
before the write and run a small instruction budget.  We watch reads on
[9Fh] before the write and verify the write actually fires.

Verdict
-------
  PASS  iff the write zeroes [9Fh] AND no reader on [9Fh] fired in the
        prologue → corroborates the static "write-only / per-frame
        clear" finding.
"""
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from harness import TasmHarness  # noqa: E402
from fixtures import BIN_PATHS, stub_video_drivers  # noqa: E402

CHUNK = 'town'
# Byte-pattern search confirmed `xor al,al; mov ds:[FF1Dh],al; mov ds:[FF1Eh],al;
# mov ds:[E4h],al; mov ds:[9Fh],al ; ...` at file offset 0xC1.
START_ADDR = 0x60C1   # xor al,al at file offset 0xC1 + load_base 0x6000


def main() -> int:
    flat_path, load_base = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print(f'MISSING: {flat_path}')
        print('VERDICT: INCONCLUSIVE: flat-file artefact missing')
        return 1

    h = TasmHarness(flat_path, load_base)
    stub_video_drivers(h)

    # Sentinel value — distinct from 0 (the value the writer should set)
    # so we can tell the write fired even though it writes a zero.
    h.write_byte(0x9F, 0x55)

    # Run the prologue.  frame_update never RETs, so we'll exhaust the
    # instruction budget — the verdict comes from observed writes/reads.
    result = h.call_function(
        START_ADDR,
        watch_reads=[0x9F],
        watch_writes=[0x9F],
        max_steps=10,    # xor + 4 mov stores fit; stop before the gfx call
    )

    val_after = h.read_byte(0x9F)
    reads     = result['reads_observed']
    writes    = result['writes_observed']
    stopped   = result['stopped_reason']

    print(f'started at CPU 0x{START_ADDR:04X} (frame_update prologue)')
    print(f'  stopped:        {stopped}')
    print(f'  instructions:   {result["instructions"]}')
    print(f'  [9Fh] before:   0x55 (sentinel)')
    print(f'  [9Fh] after:    0x{val_after:02X}  (expect 0x00 if write fired)')
    print(f'  reads on [9Fh]: {len(reads)} {reads}')
    print(f'  writes on [9Fh]: {len(writes)} {writes}')

    write_fired = val_after == 0x00 and len(writes) >= 1
    no_read     = len(reads) == 0

    if write_fired and no_read:
        print('\nVERDICT: PASS: stat_X9F is write-only — town frame prologue '
              'zeroes it every frame, no reader observed.  Consistent with '
              "grep: 1 write, 0 reads across the entire codebase.")
        return 0
    if not write_fired:
        print(f'\nVERDICT: INCONCLUSIVE: writer did not fire (final byte 0x{val_after:02X}).')
        return 1
    print('\nVERDICT: REFUTED: a reader fired on [9Fh] — grep missed it.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
