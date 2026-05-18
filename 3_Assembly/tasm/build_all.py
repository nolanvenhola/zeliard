#!/usr/bin/env python3
"""
build_all.py - Zeliard full build, parallelised across N TasmRunner.exe
               instances (one per .asm file).  Each invocation runs in
               its own DOSBox-X session, so there are no session-limit
               failures like the old single-DOSBox approach.

Usage:
    python build_all.py [--verify] [--clean] [--workers N] [--debug]

Options:
    --verify       Compare rebuilt SARs against originals in 1_OriginalGame/
    --clean        Delete compiled outputs before building
    --workers N    Parallel workers (default: 8)
    --serial       Force --workers 1 (use when a parallel run masks an error)
    --debug        Build with DEBUG_BUILD=1; output to bin_debug/ (no verify)
"""

import subprocess, struct, shutil, re, sys, tempfile, argparse, os, time
import concurrent.futures
from pathlib import Path

# ── Paths ────────────────────────────────────────────────────────────────────
ROOT      = Path(__file__).parent.resolve()
WORKING   = ROOT / 'working'
BIN       = ROOT / 'bin'
BIN_DEBUG = ROOT / 'bin_debug'
SAR_ORIG  = ROOT / '../../1_OriginalGame'

# TasmRunner.exe — same C# wrapper that verify1.py uses.
RUNNER   = ROOT / 'TasmRunner/bin/Debug/net8.0/TasmRunner.exe'

DEFAULT_WORKERS  = 8
PER_FILE_TIMEOUT = 180

# ── Output extension mapping ──────────────────────────────────────────────────
def output_ext(stem):
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s):        return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s):  return '.mdt'
    return '.bin'

def keep_as_exe(stem):
    return stem.lower() == 'zeliad'

# ── Debug-build source patching ───────────────────────────────────────────────
def patch_debug_sources():
    """Replace DEBUG_BUILD EQU 0 with EQU 1 in every ASM that opts in.
    Returns list of (path, original_bytes) for restore_debug_sources().
    Uses binary I/O to avoid encoding/line-ending corruption."""
    patches = [
        (b'DEBUG_BUILD\tEQU\t0', b'DEBUG_BUILD\tEQU\t1'),
        (b'SIZE_TEST\tEQU\t0',   b'SIZE_TEST\tEQU\t1'),
    ]
    patched = []
    for asm in WORKING.rglob('*.asm'):
        data = asm.read_bytes()
        new_data = data
        for needle, replace in patches:
            new_data = new_data.replace(needle, replace, 1)
        if new_data != data:
            patched.append((asm, data))
            asm.write_bytes(new_data)
    return patched

def restore_debug_sources(patched):
    for asm, original_bytes in patched:
        asm.write_bytes(original_bytes)

# ── Gather all ASM files to compile ──────────────────────────────────────────
def gather_jobs(out_bin):
    jobs = []
    for asm in sorted((WORKING / 'core').glob('*.asm')):
        jobs.append((asm, out_bin))
    for asm in sorted((WORKING / 'drivers').glob('*.asm')):
        jobs.append((asm, out_bin))
    for n in [1, 2, 3]:
        dest = out_bin / f'zelres{n}'
        for asm in sorted((WORKING / f'zelres{n}/code').glob('*.asm')):
            jobs.append((asm, dest))
    return jobs

# ── MZ stripping ─────────────────────────────────────────────────────────────
def strip_mz_header(exe_data):
    hdr_paras = struct.unpack_from('<H', exe_data, 8)[0]
    return exe_data[hdr_paras * 16:]

# ── Patch TLINK 2.01 zeliad.exe back to original linker output ───────────────
def patch_zeliad_exe(exe_data):
    HDR_SIZE  = 0x200
    CODE_SIZE = 2538
    TOTAL     = HDR_SIZE + CODE_SIZE
    if len(exe_data) < TOTAL:
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
    for i in range(0x1E + len(relocs) * 4, HDR_SIZE):
        result[i] = 0
    return bytes(result)

# ── Compile a single .asm file via TasmRunner.exe ────────────────────────────
def compile_one(asm, dest_dir):
    stem   = asm.stem
    is_exe = keep_as_exe(stem)
    out_ext = output_ext(stem)

    with tempfile.TemporaryDirectory(prefix='z_build_') as tmp:
        log_dir = Path(tmp) / 'logs'
        log_dir.mkdir(exist_ok=True)
        args = [str(RUNNER), str(asm), '--output', tmp, '--logdir', str(log_dir)]
        if not is_exe:
            args.append('--bin')
        try:
            result = subprocess.run(args, capture_output=True, text=True,
                                    timeout=PER_FILE_TIMEOUT)
        except subprocess.TimeoutExpired:
            return (asm, False, f'TIMEOUT after {PER_FILE_TIMEOUT}s', None)
        except Exception as e:
            return (asm, False, f'spawn error: {e}', None)

        tmp_path = Path(tmp)
        candidates = [
            tmp_path / (stem.upper() + out_ext.upper()),
            tmp_path / (stem + out_ext),
            tmp_path / (stem + '.bin'),
            tmp_path / (stem.upper() + '.BIN'),
        ]
        if is_exe:
            candidates = [tmp_path / (stem.upper() + '.EXE'),
                          tmp_path / (stem + '.exe')]
        produced = next((c for c in candidates if c.exists()), None)

        if not produced:
            # Try stripping MZ from .exe
            out_exe = tmp_path / (stem.upper() + '.EXE')
            if out_exe.exists():
                raw = strip_mz_header(out_exe.read_bytes())
                produced = tmp_path / (stem + out_ext)
                produced.write_bytes(raw)

        if not produced:
            tail = result.stderr[-300:] if result.stderr else result.stdout[-300:]
            return (asm, False, f'no output (rc={result.returncode}) {tail}'.strip(), None)

        dest_dir.mkdir(parents=True, exist_ok=True)
        data = produced.read_bytes()
        if is_exe and stem.lower() == 'zeliad':
            data = patch_zeliad_exe(data)
            dest = dest_dir / f'{stem}.exe'
        else:
            dest = dest_dir / (stem + out_ext)
        dest.write_bytes(data)
        return (asm, True, '', dest)

# ── Run the parallel compile across all jobs ─────────────────────────────────
def compile_all(jobs, workers):
    print(f'Compiling {len(jobs)} files with {workers} parallel workers '
          f'(timeout: {PER_FILE_TIMEOUT}s/file)...\n')
    t0 = time.time()
    results, completed = [], 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as ex:
        future_to_asm = {ex.submit(compile_one, asm, dest): asm
                         for asm, dest in jobs}
        for fut in concurrent.futures.as_completed(future_to_asm):
            asm, ok, msg, dest = fut.result()
            completed += 1
            tag   = '[OK  ]' if ok else '[FAIL]'
            rel   = dest.relative_to(ROOT) if dest else ''
            extra = f'-> {rel}' if dest else ''
            err   = f'  ! {msg}' if not ok else ''
            print(f'  ({completed:2d}/{len(jobs)}) {tag} {asm.name:<20} {extra}{err}')
            results.append((asm, ok, msg, dest))
    elapsed   = time.time() - t0
    ok_count  = sum(1 for r in results if r[1])
    fail_count = len(results) - ok_count
    print(f'\n  OK: {ok_count}   Failed: {fail_count}   ({elapsed:.1f}s wall)')
    return results, ok_count, fail_count

# ── Copy static runtime files from 1_OriginalGame ────────────────────────────
STATIC_EXTS = {'.drv', '.com', '.cfg', '.usr'}

def copy_static_files(out_bin):
    orig = SAR_ORIG.resolve()
    if not orig.exists():
        return 0
    copied = 0
    for f in sorted(orig.iterdir()):
        if f.suffix.lower() in STATIC_EXTS:
            dest = out_bin / f.name
            if not dest.exists() or f.stat().st_mtime > dest.stat().st_mtime:
                shutil.copy2(f, dest)
                copied += 1
    return copied

# ── Copy data files ───────────────────────────────────────────────────────────
def copy_data_files(out_bin):
    copied = 0
    for n in [1, 2, 3]:
        dest = out_bin / f'zelres{n}'
        dest.mkdir(parents=True, exist_ok=True)
        for f in sorted((WORKING / f'zelres{n}/data').iterdir()):
            shutil.copy2(f, dest / f.name)
            copied += 1
    return copied

# ── Pack SARs ─────────────────────────────────────────────────────────────────
def pack_sars(out_bin):
    r = subprocess.run(
        [sys.executable, str(ROOT / 'pack_tasm_sar.py'),
         '--bin-dir', str(out_bin), '--out-dir', str(out_bin)],
        capture_output=True, text=True
    )
    for line in r.stdout.strip().splitlines():
        print(f'  {line}')
    if r.returncode != 0:
        for line in r.stderr.strip().splitlines():
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
    parser.add_argument('--clean',   action='store_true', help='Clean output dir before build')
    parser.add_argument('--workers', type=int, default=DEFAULT_WORKERS,
                        help=f'Parallel TasmRunner workers (default: {DEFAULT_WORKERS})')
    parser.add_argument('--serial',  action='store_true',
                        help='Force --workers 1 (when a parallel run masks an error)')
    parser.add_argument('--debug',   action='store_true',
                        help='Build with DEBUG_BUILD=1; output to bin_debug/ (no verify)')
    args = parser.parse_args()

    if not RUNNER.exists():
        print(f'FATAL: TasmRunner.exe not found at {RUNNER}')
        print('Build it via: dotnet build TasmRunner/TasmRunner.csproj')
        sys.exit(2)

    out_bin = BIN_DEBUG if args.debug else BIN

    if args.debug:
        print(f'DEBUG BUILD — output to {out_bin.name}/')
        print('  (DEBUG_BUILD EQU 1 patched into source files; restored after build)\n')

    if args.clean:
        print(f'Cleaning {out_bin.name}/ ...')
        for f in out_bin.rglob('*'):
            if f.is_file() and f.suffix.lower() in ('.bin','.mdt','.msd','.grp','.exe','.sar'):
                f.unlink()

    workers = 1 if args.serial else max(1, args.workers)
    jobs = gather_jobs(out_bin)
    print(f'Found {len(jobs)} ASM files to compile.\n')

    patched = []
    try:
        if args.debug:
            patched = patch_debug_sources()
            names = [p.name for p, _ in patched]
            print(f'  Patched DEBUG_BUILD=1 in: {", ".join(names)}\n')

        print('=== Stage 1: Parallel compile via TasmRunner.exe ===')
        results, ok, fail = compile_all(jobs, workers)

    finally:
        if patched:
            restore_debug_sources(patched)
            print(f'  Restored {len(patched)} source file(s).')

    if fail > 0:
        print(f'\nFAILED files ({fail}):')
        for asm, ok_flag, msg, _ in results:
            if not ok_flag:
                print(f'  {asm.relative_to(WORKING)}: {msg}')
        print('\nABORTING: not packing SARs because some files failed to compile.')
        print('Re-run with --serial after fixing to confirm a clean build.')
        sys.exit(1)

    print('\n=== Stage 2: Copying data and static files ===')
    print(f'  {copy_data_files(out_bin)} SAR data files.')
    print(f'  {copy_static_files(out_bin)} static runtime files.')

    print('\n=== Stage 3: Packing SAR archives ===')
    if not pack_sars(out_bin):
        print('\nABORTING: SAR packing failed.  See error above.')
        sys.exit(1)

    if args.verify:
        if args.debug:
            print('\n(--verify skipped for debug build)')
        else:
            print('\n=== Stage 4: Verifying SARs ===')
            if verify_sars():
                print('\n  All SARs bit-perfect.')
            else:
                print('\n  WARNING: SAR mismatch.')
                sys.exit(1)

    print(f'\nBuild complete ({out_bin.name}/).')

if __name__ == '__main__':
    main()
