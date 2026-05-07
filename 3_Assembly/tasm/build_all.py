#!/usr/bin/env python3
"""
build_all.py - Zeliard full build, parallelised across N TasmRunner.exe
               instances (one per .asm file).  Each invocation runs in
               its own DOSBox-X session, so there are no session-limit
               failures like the old single-DOSBox approach (which
               silently dropped 50+ files past some unknown threshold
               while still letting SAR verify pass against stale .bin).

Usage:
    python build_all.py [--verify] [--clean] [--workers N]

Options:
    --verify       Compare rebuilt SARs against originals in 1_OriginalGame/
    --clean        Delete compiled outputs in bin/ before building
    --workers N    Parallel workers (default: 8)
    --serial       Force --workers 1 (use when a parallel run masks an error)
"""

import subprocess, struct, shutil, re, sys, tempfile, argparse, os, time
import concurrent.futures
from pathlib import Path

# ── Paths ────────────────────────────────────────────────────────────────────
ROOT     = Path(__file__).parent.resolve()
WORKING  = ROOT / 'working'
BIN      = ROOT / 'bin'
SAR_ORIG = ROOT / '../../1_OriginalGame'
SAR_TOOL = ROOT / '../../2_SAR/Tools/pack_sar.py'

# TasmRunner.exe — same C# wrapper that verify1.py uses.  Spawns its own
# DOSBox-X per call (TASM/TLINK bundled).  Per-call isolation = no
# session-limit issues.
RUNNER   = ROOT / 'TasmRunner/bin/Debug/net8.0/TasmRunner.exe'

DEFAULT_WORKERS = 8
PER_FILE_TIMEOUT = 180   # seconds — generous; most files compile in <5s

# ── Output extension mapping ──────────────────────────────────────────────────
def output_ext(stem):
    """Return the correct file extension for a compiled chunk."""
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s):            return '.mdt'   # dungeon map
    if re.match(r'^[123]\d{2}\w{2}MP$', s):      return '.mdt'   # town map (xxMP)
    return '.bin'

# zeliad.asm is the only file that stays as .exe
def keep_as_exe(stem):
    return stem.lower() == 'zeliad'

# ── Gather all ASM files to compile ──────────────────────────────────────────
def gather_jobs():
    """Return list of (asm_path, dest_dir) for every file to compile."""
    jobs = []
    # Core
    for asm in sorted((WORKING / 'core').glob('*.asm')):
        jobs.append((asm, BIN))
    # Drivers
    for asm in sorted((WORKING / 'drivers').glob('*.asm')):
        jobs.append((asm, BIN))
    # SAR code chunks
    for n in [1, 2, 3]:
        dest = BIN / f'zelres{n}'
        for asm in sorted((WORKING / f'zelres{n}/code').glob('*.asm')):
            jobs.append((asm, dest))
    return jobs

# ── MZ stripping (for non-zeliad .exe outputs) ───────────────────────────────
def strip_mz_header(exe_data):
    hdr_paras = struct.unpack_from('<H', exe_data, 8)[0]
    return exe_data[hdr_paras * 16:]

# ── Patch TLINK 2.01 zeliad.exe back to original linker output ───────────────
def patch_zeliad_exe(exe_data):
    """
    Convert TLINK 2.01 zeliad.exe to original linker format (byte-perfect).

    TLINK 2.01 differences vs the original linker:
      - Inserts a 32-byte extended header before the reloc table (0x1E -> 0x3E)
      - Omits relocation entry at offset 0x08C6
      - Adds 6 trailing zero padding bytes to code section
      - Different checksum value

    Target: 3050 bytes, reloc table at 0x1E, 6 entries, code = 2538 bytes.
    """
    HDR_SIZE  = 0x200
    CODE_SIZE = 2538
    TOTAL     = HDR_SIZE + CODE_SIZE

    if len(exe_data) < HDR_SIZE + CODE_SIZE:
        return exe_data

    result = bytearray(TOTAL)
    result[HDR_SIZE:HDR_SIZE + CODE_SIZE] = exe_data[HDR_SIZE:HDR_SIZE + CODE_SIZE]
    result[:HDR_SIZE] = exe_data[:HDR_SIZE]

    struct.pack_into('<H', result, 0x02, 490)
    struct.pack_into('<H', result, 0x04, 6)
    struct.pack_into('<H', result, 0x06, 6)
    struct.pack_into('<H', result, 0x0A, 0x0201)
    struct.pack_into('<H', result, 0x0C, 0x0201)
    struct.pack_into('<H', result, 0x12, 0xAC11)
    struct.pack_into('<H', result, 0x18, 0x001E)
    result[0x1A] = 0; result[0x1B] = 0
    result[0x1C] = 1; result[0x1D] = 0

    relocs = [(0x000C, 0), (0x036B, 0), (0x08C6, 0),
              (0x08CA, 0), (0x08CE, 0), (0x08D2, 0)]
    for i, (off, seg) in enumerate(relocs):
        struct.pack_into('<HH', result, 0x1E + i * 4, off, seg)

    reloc_end = 0x1E + len(relocs) * 4
    for i in range(reloc_end, HDR_SIZE):
        result[i] = 0

    return bytes(result)

# ── Compile a single .asm file via TasmRunner.exe ────────────────────────────
def compile_one(asm, dest_dir):
    """
    Compile one file.  Returns (asm_path, ok, msg, output_dest).

    Each call spawns its own DOSBox-X session in a fresh tempdir, so
    parallel callers don't share state.  We hunt for the produced output
    using the same case-variations verify1.py tries (TasmRunner is
    inconsistent about uppercasing the stem).
    """
    stem = asm.stem
    is_exe = keep_as_exe(stem)
    out_ext = output_ext(stem)

    with tempfile.TemporaryDirectory(prefix='z_build_') as tmp:
        # Per-job logdir so parallel workers don't collide on TasmRunner's
        # shared `./logs/tasm_<timestamp>.log` filename.  (Two workers
        # picking the same timestamp triggers a "file in use by another
        # process" error on the loser.)
        log_dir = Path(tmp) / 'logs'
        log_dir.mkdir(exist_ok=True)
        args = [str(RUNNER), str(asm), '--output', tmp, '--logdir', str(log_dir)]
        if not is_exe:
            args.append('--bin')
        try:
            result = subprocess.run(
                args, capture_output=True, text=True,
                timeout=PER_FILE_TIMEOUT,
            )
        except subprocess.TimeoutExpired:
            return (asm, False, f'TIMEOUT after {PER_FILE_TIMEOUT}s', None)
        except Exception as e:
            return (asm, False, f'spawn error: {e}', None)

        tmp_path = Path(tmp)

        # Hunt for the output file (TasmRunner case-inconsistent)
        candidates = [
            tmp_path / (stem.upper() + out_ext.upper()),
            tmp_path / (stem + out_ext),
            tmp_path / (stem + '.bin'),
            tmp_path / (stem.upper() + '.BIN'),
        ]
        if is_exe:
            candidates = [
                tmp_path / (stem.upper() + '.EXE'),
                tmp_path / (stem + '.exe'),
            ]
        produced = None
        for c in candidates:
            if c.exists():
                produced = c
                break

        if not produced:
            tail = result.stderr[-300:] if result.stderr else result.stdout[-300:]
            return (asm, False, f'no output (rc={result.returncode}) {tail}'.strip(), None)

        # Copy output into final dest
        dest_dir.mkdir(parents=True, exist_ok=True)
        data = produced.read_bytes()
        if is_exe:
            if stem.lower() == 'zeliad':
                data = patch_zeliad_exe(data)
            dest = dest_dir / f'{stem}.exe'
        else:
            dest = dest_dir / (stem + out_ext)
        dest.write_bytes(data)
        return (asm, True, '', dest)

# ── Run the parallel compile across all jobs ─────────────────────────────────
def compile_all(jobs, workers):
    """
    Returns (results, ok_count, fail_count) where results is the list of
    (asm, ok, msg, dest) tuples in completion order.
    """
    print(f'Compiling {len(jobs)} files with {workers} parallel workers '
          f'(timeout: {PER_FILE_TIMEOUT}s/file)...\n')

    t0 = time.time()
    results = []
    completed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as ex:
        future_to_asm = {
            ex.submit(compile_one, asm, dest): asm
            for asm, dest in jobs
        }
        for fut in concurrent.futures.as_completed(future_to_asm):
            asm, ok, msg, dest = fut.result()
            completed += 1
            tag = '[OK  ]' if ok else '[FAIL]'
            rel = dest.relative_to(ROOT) if dest else ''
            extra = f'-> {rel}' if dest else ''
            err = f'  ! {msg}' if not ok else ''
            print(f'  ({completed:2d}/{len(jobs)}) {tag} {asm.name:<20} {extra}{err}')
            results.append((asm, ok, msg, dest))

    elapsed = time.time() - t0
    ok_count = sum(1 for r in results if r[1])
    fail_count = len(results) - ok_count
    print(f'\n  OK: {ok_count}   Failed: {fail_count}   ({elapsed:.1f}s wall)')
    return results, ok_count, fail_count

# ── Copy data files ───────────────────────────────────────────────────────────
def copy_data_files():
    copied = 0
    for n in [1, 2, 3]:
        dest = BIN / f'zelres{n}'
        dest.mkdir(parents=True, exist_ok=True)
        for f in sorted((WORKING / f'zelres{n}/data').iterdir()):
            shutil.copy2(f, dest / f.name)
            copied += 1
    return copied

# ── Pack SARs ─────────────────────────────────────────────────────────────────
def pack_sars():
    r = subprocess.run(
        [sys.executable, str(SAR_TOOL),
         '--sar-dir', str(SAR_ORIG),
         '--out-dir', str(BIN)],
        capture_output=True, text=True
    )
    for line in r.stdout.strip().splitlines():
        print(f'  {line}')
    return r.returncode == 0

# ── Verify SARs ───────────────────────────────────────────────────────────────
def verify_sars():
    all_ok = True
    for n in [1, 2, 3]:
        orig = (SAR_ORIG / f'zelres{n}.sar').read_bytes()
        comp = (BIN      / f'zelres{n}.sar').read_bytes()
        diffs = sum(a != b for a, b in zip(orig, comp))
        if diffs == 0 and len(orig) == len(comp):
            print(f'  zelres{n}.sar: BIT-PERFECT ({len(orig):,} bytes)')
        else:
            print(f'  zelres{n}.sar: DIFF  diffs={diffs}  '
                  f'orig={len(orig)}  comp={len(comp)}')
            all_ok = False
    return all_ok

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description='Build all Zeliard ASM sources and pack SARs')
    parser.add_argument('--verify',  action='store_true', help='Verify SARs against originals')
    parser.add_argument('--clean',   action='store_true', help='Clean bin/ before build')
    parser.add_argument('--workers', type=int, default=DEFAULT_WORKERS,
                        help=f'Parallel TasmRunner workers (default: {DEFAULT_WORKERS})')
    parser.add_argument('--serial',  action='store_true',
                        help='Force --workers 1 (when a parallel run masks an error)')
    args = parser.parse_args()

    if not RUNNER.exists():
        print(f'FATAL: TasmRunner.exe not found at {RUNNER}')
        print('Build it via: dotnet build TasmRunner/TasmRunner.csproj')
        sys.exit(2)

    if args.clean:
        print('Cleaning bin/ ...')
        for f in BIN.rglob('*'):
            if f.is_file() and f.suffix.lower() in ('.bin','.mdt','.msd','.grp','.exe','.sar'):
                f.unlink()

    workers = 1 if args.serial else max(1, args.workers)
    jobs = gather_jobs()
    print(f'Found {len(jobs)} ASM files to compile.\n')

    # ── Stage 1+2: parallel per-file compile ──
    print('=== Stage 1: Parallel compile via TasmRunner.exe ===')
    results, ok, fail = compile_all(jobs, workers)

    if fail > 0:
        print(f'\nFAILED files ({fail}):')
        for asm, ok_flag, msg, _ in results:
            if not ok_flag:
                print(f'  {asm.relative_to(WORKING)}: {msg}')
        print('\nABORTING: not packing SARs because some files failed to compile.')
        print('Re-run with --serial after fixing to confirm a clean build.')
        sys.exit(1)

    # ── Stage 3: copy data files ──
    print('\n=== Stage 2: Copying data files ===')
    n = copy_data_files()
    print(f'  Copied {n} data files.')

    # ── Stage 4: pack SARs ──
    print('\n=== Stage 3: Packing SAR archives ===')
    pack_sars()

    # ── Stage 5: verify (optional) ──
    if args.verify:
        print('\n=== Stage 4: Verifying SARs ===')
        if verify_sars():
            print('\n  All SARs bit-perfect.')
        else:
            print('\n  WARNING: SAR mismatch.')
            sys.exit(1)

    print('\nBuild complete.')

if __name__ == '__main__':
    main()
