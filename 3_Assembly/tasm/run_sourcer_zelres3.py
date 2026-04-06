#!/usr/bin/env python3
"""
run_sourcer_zelres3.py — Run SourcerRunner on all zelres3 bins missing .asm files.

Usage:
  python run_sourcer_zelres3.py           # process all missing
  python run_sourcer_zelres3.py --skip N  # skip first N files (resume)
  python run_sourcer_zelres3.py STEM      # process single file (e.g. 301MAPCA)

For each file, SourcerRunner launches DOSBox with Sourcer. Press:
  I  ->  <filename>  ->  ENTER  ->  F  ->  T (x9)  ->  P (x7)  ->  G
"""

import sys, subprocess, glob, os
from pathlib import Path

ROOT = Path(__file__).parent
RUNNER = ROOT / 'SourcerRunner/bin/Debug/net8.0/SourcerRunner.exe'
CODE_DIR = ROOT / 'working/zelres3/code'
OUTPUT_DIR = CODE_DIR

def get_pending():
    bins = {Path(f).stem for f in glob.glob(str(CODE_DIR / '*.bin'))}
    asms = {Path(f).stem for f in glob.glob(str(CODE_DIR / '*.asm'))}
    return sorted(bins - asms)

def run_one(stem):
    bin_path = CODE_DIR / f'{stem}.bin'
    print(f'\n{"="*60}')
    print(f'  File: {stem}.bin  ({bin_path.stat().st_size} bytes)')
    print(f'{"="*60}')
    print(f'  Keystroke sequence in DOSBox:')
    print(f'    I  {stem}.bin  ENTER  F  TTTTTTTTT  PPPPPPP  G')
    print()
    result = subprocess.run(
        [str(RUNNER), str(bin_path), '--output', str(OUTPUT_DIR)],
        timeout=300
    )
    asm = OUTPUT_DIR / f'{stem}.asm'
    if asm.exists():
        print(f'  OK: Created {stem}.asm ({asm.stat().st_size} bytes)')
        return True
    else:
        print(f'  SKIP: No .asm produced')
        return False

def main():
    if not RUNNER.exists():
        print('ERROR: SourcerRunner not found. Build it first:')
        print('  cd 3_Assembly/tasm/SourcerRunner && dotnet build')
        sys.exit(1)

    # Single file mode
    if len(sys.argv) > 1 and not sys.argv[1].startswith('--'):
        run_one(sys.argv[1])
        return

    # Batch mode
    skip = 0
    if '--skip' in sys.argv:
        idx = sys.argv.index('--skip')
        skip = int(sys.argv[idx + 1])

    pending = get_pending()
    total = len(pending)
    print(f'zelres3 Sourcer batch: {total} files to process')
    if skip:
        print(f'Skipping first {skip} files (resume mode)')
        pending = pending[skip:]

    done = 0
    for i, stem in enumerate(pending, skip + 1):
        print(f'\n[{i}/{total}] ', end='')
        success = run_one(stem)
        if success:
            done += 1
        remaining = total - i
        print(f'  Progress: {done} done, {remaining} remaining')

    print(f'\nBatch complete: {done}/{total} files disassembled')
    still_missing = get_pending()
    if still_missing:
        print(f'Still missing .asm: {len(still_missing)} files')
        print(f'  Resume with: python run_sourcer_zelres3.py --skip {total - len(still_missing)}')

if __name__ == '__main__':
    main()
