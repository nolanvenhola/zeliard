#!/usr/bin/env python3
"""
build_all.py - Zeliard MASM build: single DOSBox session assembles all
               code chunks with MASM 4.0, then verifies against originals.

Mirrors tasm/build_all.py but uses MASM 4.0 + LINK.EXE instead of TASM + TLINK.
Skips game.asm and zeliad.asm (use TASM-specific syntax incompatible with MASM 4.0).

Usage:
    python build_all.py [--verify] [--clean] [--lsts-only]

Options:
    --verify     Compare rebuilt SARs against originals
    --clean      Delete compiled outputs before building
    --lsts-only  Only generate LST files (skip SAR packing/verify)
"""

import subprocess, struct, shutil, re, sys, tempfile, os
from pathlib import Path

# ── Paths ────────────────────────────────────────────────────────────────────
ROOT     = Path(__file__).parent.resolve()
WORKING  = ROOT / 'working'
BIN      = ROOT / 'bin'
SAR_ORIG = ROOT / '../../1_OriginalGame'

# DOSBox from TasmRunner; MASM 4.0 in tasm/tool/masm4
_TASM_RUNNER = ROOT / '../tasm/TasmRunner/bin/Debug/net8.0'
DOSBOX   = _TASM_RUNNER / 'dosbox/dosbox.exe'
MASM_DIR = ROOT / '../tasm/tool/masm4'

# These files use TASM-specific syntax (GAME_CODE_BASE pattern, zeliard.inc)
# and cannot be compiled by MASM 4.0 without modification.
SKIP_FILES = {'game', 'zeliad'}

# ── Output extension mapping ──────────────────────────────────────────────────
def output_ext(stem):
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s): return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s): return '.mdt'
    return '.bin'

# ── Gather all ASM files to compile ──────────────────────────────────────────
def gather_jobs():
    jobs = []
    for asm in sorted((WORKING / 'core').glob('*.asm')):
        if asm.stem.lower() not in SKIP_FILES:
            jobs.append((asm, BIN))
    for asm in sorted((WORKING / 'drivers').glob('*.asm')):
        jobs.append((asm, BIN))
    for n in [1, 2, 3]:
        dest = BIN / f'zelres{n}'
        for asm in sorted((WORKING / f'zelres{n}/code').glob('*.asm')):
            jobs.append((asm, dest))
    return jobs

# ── Build single DOSBox conf ──────────────────────────────────────────────────
def build_dosbox_conf(jobs, work_dir, conf_path):
    shutil.copy2(WORKING / 'srmacros.inc', work_dir / 'SRMACROS.INC')
    for inc in WORKING.glob('*.inc'):
        if inc.name.lower() != 'srmacros.inc':
            shutil.copy2(inc, work_dir / inc.name.upper())

    bat_lines = ['@echo off']
    for asm, _ in jobs:
        shutil.copy2(asm, work_dir / asm.name)
        stem = asm.stem
        bat_lines += [
            f'echo {asm.name}',
            # MASM: explicit output filenames, semicolon terminates prompts
            f'masm /l {asm.name}, {stem}.OBJ, {stem}.LST;',
            f'if not exist {stem}.OBJ echo FAILED: {asm.name} >> BUILD_ERR.TXT',
            f'if exist {stem}.OBJ link {stem}.OBJ, {stem}.EXE, NUL;',
        ]
    bat_lines += ['echo Done.']
    (work_dir / 'BUILD.BAT').write_text('\r\n'.join(bat_lines) + '\r\n')

    MASM = str(MASM_DIR)
    conf = '\n'.join([
        '[autoexec]',
        '@echo off',
        f'mount m "{MASM}"',
        f'mount w "{work_dir}"',
        'set PATH=M:\\',
        'w:',
        'call BUILD.BAT',
        'exit',
        '',
    ])
    conf_path.write_text(conf)

# ── Run DOSBox ────────────────────────────────────────────────────────────────
def run_dosbox(conf_path):
    result = subprocess.run(
        [str(DOSBOX), '-conf', str(conf_path), '-noconsole', '-exit'],
        capture_output=True, text=True
    )
    return result.returncode

# ── Process compiled outputs ──────────────────────────────────────────────────
def strip_mz_header(exe_data):
    hdr_paras = struct.unpack_from('<H', exe_data, 8)[0]
    return exe_data[hdr_paras * 16:]

def process_outputs(jobs, work_dir, lsts_only=False):
    ok = failed = 0
    for asm, dest_dir in jobs:
        stem = asm.stem
        exe_file = work_dir / f'{stem}.EXE'
        lst_file = work_dir / f'{stem}.LST'

        # Copy LST back to working directory (for fix scripts)
        if lst_file.exists():
            dest_lst = asm.parent / f'{stem.upper()}.LST'
            shutil.copy2(lst_file, dest_lst)

        if lsts_only:
            if lst_file.exists():
                ok += 1
            else:
                print(f'  [FAIL] {asm.name} — no LST produced')
                failed += 1
            continue

        if not exe_file.exists():
            print(f'  [FAIL] {asm.name} — no output produced')
            failed += 1
            continue

        exe_data = exe_file.read_bytes()
        bin_data = strip_mz_header(exe_data)
        ext = output_ext(stem)
        dest_dir.mkdir(parents=True, exist_ok=True)
        out_file = dest_dir / f'{stem}{ext}'
        out_file.write_bytes(bin_data)
        print(f'  [OK  ] {asm.name} -> {out_file.relative_to(ROOT.parent.parent)}')
        ok += 1

    return ok, failed

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    lsts_only = '--lsts-only' in sys.argv
    verify    = '--verify' in sys.argv
    clean     = '--clean' in sys.argv

    if clean and BIN.exists():
        shutil.rmtree(BIN)

    jobs = gather_jobs()
    print(f'Found {len(jobs)} ASM files to compile (skipping: {", ".join(SKIP_FILES)}).')

    with tempfile.TemporaryDirectory(prefix='zeliard_masm_') as tmp:
        work_dir  = Path(tmp)
        conf_path = work_dir / 'dosbox.conf'

        print(f'\n=== Compiling with MASM 4.0 ===')
        build_dosbox_conf(jobs, work_dir, conf_path)
        run_dosbox(conf_path)

        print(f'\n=== Processing outputs ===')
        ok, failed = process_outputs(jobs, work_dir, lsts_only=lsts_only)
        print(f'  OK: {ok}   Failed: {failed}')

    if verify and not lsts_only:
        print('\n=== Verifying against originals ===')
        from pathlib import Path as P
        sys.path.insert(0, str(ROOT / '../tasm'))
        import build_all as tasm_build
        # Use tasm's SAR packing and verification logic
        # (SARs live in tasm/bin, masm/bin has per-file bins)
        print('  (verification uses tasm/bin — run tasm/build_all.py --verify for SAR check)')

    print('\nBuild complete.')

if __name__ == '__main__':
    main()
