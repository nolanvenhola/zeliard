#!/usr/bin/env python3
"""
run_sourcer_all.py - Re-run Sourcer on all Zeliard binaries with MASM-4.0 output.

For each directory in masm/working that contains .sdf + .bin files,
runs Sourcer in DOSBox to produce MASM-syntax .asm files.
Processes all directories in a single DOSBox session per subdirectory group.
"""
import subprocess, tempfile, sys
from pathlib import Path

DOSBOX  = Path('c:/Projects/Zeliard/3_Assembly/tasm/TasmRunner/bin/Debug/net8.0/dosbox/dosbox.exe')
SOURCER = Path('c:/Projects/Zeliard/3_Assembly/sourcer/sourcer8.01')
MASM_W  = Path('c:/Projects/Zeliard/3_Assembly/masm/working')

# Collect all (directory, sdf, bin) tuples
jobs = []
for sdf in sorted(MASM_W.rglob('*.sdf')):
    content = sdf.read_text(errors='replace')
    inp = next((l.split('=')[1].strip() for l in content.splitlines() if 'Input filename' in l), None)
    if not inp:
        continue
    bin_file = sdf.parent / inp
    if bin_file.exists():
        jobs.append((sdf.parent, sdf.name, inp))

print(f'Found {len(jobs)} files to disassemble')

# Group jobs by directory so we can run each dir in one DOSBox session
from collections import defaultdict
by_dir = defaultdict(list)
for dir_, sdf_name, inp in jobs:
    by_dir[dir_].append((sdf_name, inp))

total_done = 0
for dir_, dir_jobs in sorted(by_dir.items()):
    rel = dir_.relative_to(MASM_W)
    print(f'\n{rel} ({len(dir_jobs)} files)...')

    # Build inline autoexec with all sr commands for this directory
    lines = [
        '[autoexec]',
        '@echo off',
        f'mount s "{SOURCER}"',
        f'mount w "{dir_}"',
        'set PATH=S:\\',
        'w:',
    ]
    for sdf_name, inp in dir_jobs:
        lines.append(f'echo {inp}')
        lines.append(f'sr {inp} {sdf_name}')
    lines.append('exit')

    conf = '\n'.join(lines) + '\n'
    conf_path = Path(tempfile.gettempdir()) / 'dosbox_sourcer_masm.conf'
    conf_path.write_text(conf)

    result = subprocess.run(
        [str(DOSBOX), '-conf', str(conf_path), '-noconsole', '-exit'],
        capture_output=True, text=True
    )

    # Count produced ASM files
    produced = [inp for _, inp in dir_jobs
                if (dir_ / (Path(inp).stem + '.asm')).exists()
                or (dir_ / (Path(inp).stem + '.ASM')).exists()]
    print(f'  -> {len(produced)}/{len(dir_jobs)} ASM files produced')
    total_done += len(produced)

print(f'\nTotal: {total_done} ASM files produced')
