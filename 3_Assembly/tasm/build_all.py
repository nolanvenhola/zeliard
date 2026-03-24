#!/usr/bin/env python3
"""
build_all.py - Zeliard full build: single DOSBox-X session compiles
               all ASM sources, then Python packs the three SAR files.

Usage:
    python build_all.py [--verify] [--clean]

Options:
    --verify    Compare rebuilt SARs against originals in 1_OriginalGame/
    --clean     Delete compiled outputs in bin/ before building
"""

import subprocess, struct, shutil, re, sys, tempfile, argparse, os
from pathlib import Path

# ── Paths ────────────────────────────────────────────────────────────────────
ROOT     = Path(__file__).parent.resolve()
WORKING  = ROOT / 'working'
BIN      = ROOT / 'bin'
SAR_ORIG = ROOT / '../../1_OriginalGame'
SAR_TOOL = ROOT / '../../2_SAR/Tools/pack_sar.py'

# DOSBox and TASM bundled inside TasmRunner build output
_RUNNER  = ROOT / 'TasmRunner/bin/Debug/net8.0'
DOSBOX   = _RUNNER / 'dosbox/dosbox.exe'
TASM_DIR = _RUNNER / 'tool/tasm201'

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

# ── Build single DOSBox conf that compiles everything ────────────────────────
def build_dosbox_conf(jobs, work_dir, conf_path):
    """
    Copy all .asm + srmacros.inc to work_dir, write a DOSBox conf
    that compiles every file with TASM + TLINK in one session.
    """
    srmacros = WORKING / 'srmacros.inc'
    shutil.copy2(srmacros, work_dir / 'SRMACROS.INC')

    lines = [
        '[autoexec]',
        '@echo off',
        f'mount t "{TASM_DIR}"',
        f'mount w "{work_dir}"',
        'set PATH=T:\\',
        'w:',
        '',
    ]

    for asm, _ in jobs:
        stem = asm.stem
        # Copy .asm to flat work dir
        shutil.copy2(asm, work_dir / asm.name)

        lines += [
            f'echo Assembling {asm.name}...',
            f'tasm /l {asm.name}',
            f'if errorlevel 1 goto err_{stem}',
            f'tlink /c /x {stem}.obj, {stem}.exe',
            f'if errorlevel 1 goto err_{stem}',
            f'goto ok_{stem}',
            f':err_{stem}',
            f'echo FAILED: {asm.name} >> BUILD_ERR.TXT',
            f':ok_{stem}',
            '',
        ]

    lines += ['echo Build complete.', 'exit', '']
    conf_path.write_text('\n'.join(lines))

# ── Run DOSBox ────────────────────────────────────────────────────────────────
def run_dosbox(conf_path):
    result = subprocess.run(
        [str(DOSBOX), '-conf', str(conf_path), '-noconsole', '-exit'],
        capture_output=True, text=True
    )
    return result.returncode

# ── Process compiled outputs ──────────────────────────────────────────────────
def strip_mz_header(exe_data):
    """Extract raw code section from MZ executable."""
    hdr_paras = struct.unpack_from('<H', exe_data, 8)[0]
    return exe_data[hdr_paras * 16:]

def process_outputs(jobs, work_dir):
    ok = fail = 0
    for asm, dest_dir in jobs:
        stem     = asm.stem
        exe_path = work_dir / f'{stem}.EXE'
        if not exe_path.exists():
            exe_path = work_dir / f'{stem}.exe'

        if not exe_path.exists():
            print(f'  [FAIL] {asm.name} — no output produced')
            fail += 1
            continue

        dest_dir.mkdir(parents=True, exist_ok=True)
        exe_data = exe_path.read_bytes()

        if keep_as_exe(stem):
            dest = dest_dir / f'{stem}.exe'
            dest.write_bytes(exe_data)
        else:
            raw  = strip_mz_header(exe_data)
            ext  = output_ext(stem)
            dest = dest_dir / (stem + ext)
            dest.write_bytes(raw)

        print(f'  [OK  ] {asm.name} -> {dest.relative_to(ROOT)}')
        ok += 1

    # Report any TASM errors logged to BUILD_ERR.TXT
    err_log = work_dir / 'BUILD_ERR.TXT'
    if err_log.exists():
        errs = err_log.read_text().strip()
        if errs:
            print(f'\n  TASM errors logged:\n{errs}')

    return ok, fail

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
    parser.add_argument('--verify', action='store_true', help='Verify SARs against originals')
    parser.add_argument('--clean',  action='store_true', help='Clean bin/ before build')
    args = parser.parse_args()

    if args.clean:
        print('Cleaning bin/ ...')
        for f in BIN.rglob('*'):
            if f.is_file() and f.suffix.lower() in ('.bin','.mdt','.msd','.grp','.exe','.sar'):
                f.unlink()

    jobs = gather_jobs()
    print(f'Found {len(jobs)} ASM files to compile.\n')

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path  = Path(tmp)
        conf_path = tmp_path / 'build.conf'

        # ── Stage 1: compile in DOSBox ──
        print('=== Stage 1: Compiling in DOSBox-X (single session) ===')
        build_dosbox_conf(jobs, tmp_path, conf_path)
        print(f'Launching DOSBox-X with {len(jobs)} files...')
        run_dosbox(conf_path)

        # ── Stage 2: process outputs ──
        print('\n=== Stage 2: Processing compiled outputs ===')
        ok, fail = process_outputs(jobs, tmp_path)
        print(f'\n  OK: {ok}   Failed: {fail}')

    # ── Stage 3: copy data files ──
    print('\n=== Stage 3: Copying data files ===')
    n = copy_data_files()
    print(f'  Copied {n} data files.')

    # ── Stage 4: pack SARs ──
    print('\n=== Stage 4: Packing SAR archives ===')
    pack_sars()

    # ── Stage 5: verify (optional) ──
    if args.verify:
        print('\n=== Stage 5: Verifying SARs ===')
        if verify_sars():
            print('\n  All SARs bit-perfect.')
        else:
            print('\n  WARNING: SAR mismatch.')
            sys.exit(1)

    print('\nBuild complete.')

if __name__ == '__main__':
    main()
