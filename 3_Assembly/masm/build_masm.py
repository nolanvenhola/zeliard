#!/usr/bin/env python3
"""
build_masm.py - Zeliard build using MASM 5.1 + TLINK.

Assembles all 60 source files with MASM 5.1 (which accepts symbolic
offset expressions that TASM 2.01 rejects), verifies bit-perfect output
against the originals in ../tasm/bin/, and packs SARs.

Source files live in masm/working/ (masm-local copy).
Outputs go to masm/bin/ (release) or masm/bin_debug/ (debug).

Usage:
    python build_masm.py [--verify] [--clean] [--workers N] [--serial] [--debug]
                         [--dosbox PATH]

Options:
    --verify   Verify SARs against TASM reference (release only)
    --clean    Clean output dir before build
    --workers  Parallel workers (default: 8)
    --serial   Force single worker
    --debug    Build with DEBUG_BUILD=1; output to masm/bin_debug/
    --dosbox   DOSBox/DOSBox-X executable (defaults to the local TasmRunner copy)
"""

import subprocess, struct, shutil, re, sys, tempfile, argparse, time
import concurrent.futures
from pathlib import Path

ROOT      = Path(__file__).parent.resolve()
TASM_ROOT = (ROOT / '../tasm').resolve()
WORKING   = ROOT / 'working'          # masm-local copy of ASM sources
BIN       = ROOT / 'bin'
BIN_DEBUG = ROOT / 'bin_debug'
TASM_BIN  = TASM_ROOT / 'bin'        # reference for bit-perfect verify
SAR_ORIG  = (ROOT / '../../1_OriginalGame').resolve()

MASM_DIR    = ROOT / 'tool/masm51'
TLINK_DIR   = ROOT / 'tool/tlink'
DOSBOX      = ROOT / 'TasmRunner/bin/Debug/net8.0/dosbox/dosbox.exe'

DEFAULT_WORKERS  = 8
PER_FILE_TIMEOUT = 180


def output_ext(stem):
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s): return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s): return '.mdt'
    return '.bin'

def keep_as_exe(stem):
    return stem.lower() == 'zeliad'

def strip_mz_header(data):
    hdr = struct.unpack_from('<H', data, 8)[0]
    return data[hdr * 16:]

def patch_zeliad_exe(exe_data):
    HDR_SIZE  = 0x200
    CODE_SIZE = 2538
    TOTAL     = HDR_SIZE + CODE_SIZE
    if len(exe_data) < TOTAL:
        return exe_data
    result = bytearray(TOTAL)
    result[HDR_SIZE:] = exe_data[HDR_SIZE:HDR_SIZE + CODE_SIZE]
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


def compile_one_masm(asm, dest_dir):
    """Compile a single .asm with MASM 5.1 + TLINK. Returns (asm, ok, msg, dest)."""
    stem    = asm.stem
    dos_stem = stem.upper()[:8]
    is_exe  = keep_as_exe(stem)
    out_ext = output_ext(stem)

    with tempfile.TemporaryDirectory(prefix='z_masm_') as tmp:
        tmp_path    = Path(tmp)
        mount_root  = asm.parent.parent
        asm_subdir  = asm.parent.name

        # Always link to EXE, then strip the MZ header to get a flat binary.
        # /tiny (COM format) requires org 100h and fails for game engine chunks.
        link_cmd = f'l:\\tlink /c /x o:\\{dos_stem}.OBJ,o:\\{dos_stem}.EXE >> o:\\out.txt'

        conf = tmp_path / 'masm.conf'
        conf.write_text('\n'.join([
            '[autoexec]',
            '@echo off',
            f'mount m "{MASM_DIR}"',
            f'mount l "{TLINK_DIR}"',
            f'mount w "{mount_root}"',
            f'mount o "{tmp_path}"',
            'set PATH=M:\\;L:\\',
            'w:',
            f'cd {asm_subdir}',
            f'm:\\masm /l {asm.name},o:\\{dos_stem}.OBJ,o:\\{dos_stem}.LST,NUL; > o:\\out.txt',
            'echo MASM-EXIT:%errorlevel% >> o:\\out.txt',
            link_cmd,
            'echo TLINK-EXIT:%errorlevel% >> o:\\out.txt',
            'exit',
        ]) + '\n')

        try:
            subprocess.run([str(DOSBOX), '-conf', str(conf), '-exit'],
                           capture_output=True, text=True, timeout=PER_FILE_TIMEOUT)
        except subprocess.TimeoutExpired:
            return (asm, False, f'TIMEOUT after {PER_FILE_TIMEOUT}s', None)
        except Exception as e:
            return (asm, False, f'spawn error: {e}', None)

        out_txt  = tmp_path / 'OUT.TXT'
        masm_out = out_txt.read_text(errors='replace') if out_txt.exists() else ''

        exe = tmp_path / (dos_stem + '.EXE')
        if not exe.exists():
            return (asm, False, f'no EXE\n{masm_out[-400:]}', None)

        dest_dir.mkdir(parents=True, exist_ok=True)
        raw = exe.read_bytes()

        if is_exe and stem.lower() == 'zeliad':
            data = patch_zeliad_exe(raw)
            dest = dest_dir / f'{stem}.exe'
        else:
            # Strip MZ header, then strip any org-directive padding.
            # Files with org > 0 (e.g. game.asm org 0A000h) get that many
            # zero bytes prepended by TLINK — remove them to match the
            # original flat chunk binary.
            stripped = strip_mz_header(raw)
            org_offset = 0
            for line in asm.read_text(errors='replace').split('\n'):
                m = re.match(r'\s*org\s+([0-9A-Fa-f]+)h\b', line, re.IGNORECASE)
                if m:
                    org_offset = int(m.group(1), 16)
                    break
            data = stripped[org_offset:]
            dest = dest_dir / (stem + out_ext)

        dest.write_bytes(data)
        lst = tmp_path / (dos_stem + '.LST')
        is_release_output = dest_dir == BIN or BIN in dest_dir.parents
        if is_release_output and lst.exists():
            shutil.copy2(lst, asm.with_suffix('.LST'))
        return (asm, True, masm_out[:200], dest)


def compile_one(asm, dest_dir):
    return compile_one_masm(asm, dest_dir)


# ── Debug-build source patching ───────────────────────────────────────────────
def patch_debug_sources():
    """Patch DEBUG_BUILD EQU 0 → 1 in masm/working/.  Binary I/O only."""
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


def compile_all(jobs, workers):
    print(f'Compiling {len(jobs)} files ({workers} workers)...\n')
    t0 = time.time()
    results, completed = [], 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as ex:
        future_to_asm = {ex.submit(compile_one, asm, dest): asm for asm, dest in jobs}
        for fut in concurrent.futures.as_completed(future_to_asm):
            asm, ok, msg, dest = fut.result()
            completed += 1
            tag = '[OK  ]' if ok else '[FAIL]'
            rel = dest.relative_to(ROOT) if dest else ''
            err = f'  ! {msg[:80]}' if not ok else ''
            print(f'  ({completed:2d}/{len(jobs)}) {tag} {asm.name:<20} {f"-> {rel}" if dest else ""}{err}')
            results.append((asm, ok, msg, dest))
    elapsed = time.time() - t0
    ok_c = sum(1 for r in results if r[1])
    print(f'\n  OK: {ok_c}   Failed: {len(results)-ok_c}   ({elapsed:.1f}s)')
    return results, ok_c, len(results) - ok_c


def copy_data_files(out_bin):
    copied = 0
    for n in [1, 2, 3]:
        dest = out_bin / f'zelres{n}'
        dest.mkdir(parents=True, exist_ok=True)
        for f in sorted((WORKING / f'zelres{n}/data').iterdir()):
            shutil.copy2(f, dest / f.name)
            copied += 1
    return copied


def copy_static_files(out_bin):
    orig = SAR_ORIG.resolve()
    if not orig.exists():
        return 0
    copied = 0
    for f in sorted(orig.iterdir()):
        if f.suffix.lower() in {'.drv', '.com', '.cfg', '.usr'}:
            dest = out_bin / f.name
            if not dest.exists() or f.stat().st_mtime > dest.stat().st_mtime:
                shutil.copy2(f, dest)
                copied += 1
    return copied


def pack_sars(out_bin):
    r = subprocess.run(
        [sys.executable, str(TASM_ROOT / 'pack_tasm_sar.py'),
         '--bin-dir', str(out_bin), '--out-dir', str(out_bin)],
        capture_output=True, text=True
    )
    for line in r.stdout.strip().splitlines():
        print(f'  {line}')
    if r.returncode != 0:
        for line in r.stderr.strip().splitlines():
            print(f'  {line}')
    return r.returncode == 0


def verify_sars():
    all_ok = True
    for n in [1, 2, 3]:
        orig = (TASM_BIN / f'zelres{n}.sar').read_bytes()
        comp = (BIN      / f'zelres{n}.sar').read_bytes()
        diffs = sum(a != b for a, b in zip(orig, comp))
        if diffs == 0 and len(orig) == len(comp):
            print(f'  zelres{n}.sar: BIT-PERFECT ({len(orig):,} bytes)')
        else:
            print(f'  zelres{n}.sar: DIFF  diffs={diffs}  orig={len(orig)}  comp={len(comp)}')
            all_ok = False
    return all_ok


def main():
    global DOSBOX
    p = argparse.ArgumentParser(description='MASM 5.1 build for Zeliard')
    p.add_argument('--verify',  action='store_true', help='Verify SARs against TASM reference (release only)')
    p.add_argument('--clean',   action='store_true', help='Clean output dir before build')
    p.add_argument('--workers', type=int, default=DEFAULT_WORKERS)
    p.add_argument('--serial',  action='store_true', help='Force single worker')
    p.add_argument('--debug',   action='store_true', help='Build with DEBUG_BUILD=1; output to masm/bin_debug/')
    p.add_argument('--dosbox', type=Path, default=DOSBOX,
                   help='DOSBox or DOSBox-X executable used to run MASM 5.1')
    args = p.parse_args()

    DOSBOX = args.dosbox.resolve()

    if not MASM_DIR.exists():
        print(f'FATAL: MASM 5.1 not found at {MASM_DIR}'); sys.exit(2)
    if not DOSBOX.exists():
        print(f'FATAL: DOSBox not found at {DOSBOX}'); sys.exit(2)

    out_bin = BIN_DEBUG if args.debug else BIN

    if args.debug:
        print(f'DEBUG BUILD — output to {out_bin.name}/')
        print('  (DEBUG_BUILD EQU 1 patched into masm/working/ sources; restored after build)\n')

    if args.clean:
        print(f'Cleaning {out_bin.name}/ ...')
        for f in out_bin.rglob('*'):
            if f.is_file() and f.suffix.lower() in ('.bin','.mdt','.msd','.grp','.exe','.sar'):
                f.unlink()

    workers = 1 if args.serial else max(1, args.workers)
    jobs = gather_jobs(out_bin)
    print(f'MASM BUILD — {len(jobs)} files via MASM 5.1\n')

    patched = []
    try:
        if args.debug:
            patched = patch_debug_sources()
            names = [p.name for p, _ in patched]
            print(f'  Patched DEBUG_BUILD=1 in: {", ".join(names)}\n')

        print('=== Stage 1: Compile ===')
        results, ok, fail = compile_all(jobs, workers)

    finally:
        if patched:
            restore_debug_sources(patched)
            print(f'  Restored {len(patched)} source file(s).')

    if fail > 0:
        print(f'\nFAILED ({fail}):')
        for asm, ok_f, msg, _ in results:
            if not ok_f:
                print(f'  {asm.relative_to(WORKING)}: {msg[:80]}')
        print('\nABORTING: SAR pack skipped.')
        sys.exit(1)

    print('\n=== Stage 2: Copy data + static files ===')
    print(f'  {copy_data_files(out_bin)} SAR data files.')
    print(f'  {copy_static_files(out_bin)} static runtime files.')

    print('\n=== Stage 3: Pack SARs ===')
    if not pack_sars(out_bin):
        print('\nABORTING: SAR pack failed.')
        sys.exit(1)

    if args.verify:
        if args.debug:
            print('\n(--verify skipped for debug build)')
        else:
            print('\n=== Stage 4: Verify vs TASM reference ===')
            if verify_sars():
                print('\n  All SARs bit-perfect.')
            else:
                print('\n  SAR mismatch.')
                sys.exit(1)

    print(f'\nBuild complete ({out_bin.name}/).')


if __name__ == '__main__':
    main()
