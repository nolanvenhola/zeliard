#!/usr/bin/env python3
"""
verify1.py - Compile a single ASM file and check it matches the expected bin.

Usage:
  python3 verify1.py zelres1/code/100OPDMO.asm
  python3 verify1.py zelres2/code/200FIGHT.asm
"""
import sys, subprocess, tempfile, struct
from pathlib import Path

ROOT    = Path(__file__).parent
WORKING = ROOT / 'working'
BIN     = ROOT / 'bin'
RUNNER  = ROOT / 'TasmRunner/bin/Debug/net8.0/TasmRunner.exe'

def output_ext(stem):
    import re
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s): return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s): return '.mdt'
    return '.bin'

def strip_mz(data):
    hdr = struct.unpack_from('<H', data, 8)[0]
    return data[hdr * 16:]

def patch_zeliad_exe(exe_data):
    """Normalize TLINK 2.01 zeliad.exe to original linker format (bit-perfect).
    Shared with build_all.py — keep in sync."""
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

def main():
    if len(sys.argv) < 2:
        print('Usage: verify1.py <subpath/to/file.asm>')
        sys.exit(1)

    rel = sys.argv[1]
    asm = WORKING / rel
    if not asm.exists():
        print(f'Not found: {asm}'); sys.exit(1)

    stem = asm.stem
    is_zeliad = (stem.lower() == 'zeliad')
    # Determine expected bin path (zelresN/code → bin/zelresN)
    parts = asm.relative_to(WORKING).parts  # e.g. ('zelres1', 'code', 'foo.asm')
    if is_zeliad:
        expected = BIN / 'zeliad.exe'   # compare full patched exe vs original
    elif len(parts) >= 2 and parts[0].startswith('zelres'):
        expected = BIN / parts[0] / (stem + output_ext(stem))
    elif parts[0] in ('core', 'drivers'):
        expected = BIN / (stem + output_ext(stem))
    else:
        expected = BIN / (stem + output_ext(stem))

    if not expected.exists():
        print(f'No expected bin: {expected}'); sys.exit(1)

    with tempfile.TemporaryDirectory(prefix='z_verify_') as tmp:
        # zeliad: assemble to .EXE so we can apply patch_zeliad_exe
        if is_zeliad:
            run_args = [str(RUNNER), str(asm), '--output', tmp]
        else:
            run_args = [str(RUNNER), str(asm), '--bin', '--output', tmp]
        result = subprocess.run(run_args, capture_output=True, text=True)

        if is_zeliad:
            out_exe = Path(tmp) / (stem.upper() + '.EXE')
            if not out_exe.exists():
                out_exe = Path(tmp) / (stem + '.exe')
            out_bin = None
            if out_exe.exists():
                out_bin = Path(tmp) / (stem + '.exe.patched')
                out_bin.write_bytes(patch_zeliad_exe(out_exe.read_bytes()))
        else:
            out_bin = Path(tmp) / (stem.upper() + output_ext(stem).upper())
            if not out_bin.exists():
                out_bin = Path(tmp) / (stem + output_ext(stem))
            if not out_bin.exists():
                out_bin = Path(tmp) / (stem + '.bin')
            if not out_bin.exists():
                out_bin = Path(tmp) / (stem.upper() + '.BIN')
            if not out_bin.exists():
                out_exe = Path(tmp) / (stem.upper() + '.EXE')
                if out_exe.exists():
                    out_bin = Path(tmp) / (stem + output_ext(stem))
                    out_bin.write_bytes(strip_mz(out_exe.read_bytes()))

        if not out_bin.exists():
            print(f'FAIL: no output produced (exit {result.returncode})')
            if result.stderr: print(result.stderr[:200])
            sys.exit(1)

        got  = out_bin.read_bytes()
        want = expected.read_bytes()

        display_ext = '.exe' if is_zeliad else output_ext(stem)
        if got == want:
            print(f'BIT-PERFECT  {stem}{display_ext}  ({len(got)} bytes)')
        else:
            diffs = sum(1 for a, b in zip(got, want) if a != b)
            size_delta = len(got) - len(want)
            print(f'MISMATCH  {stem}  diffs={diffs}  size_delta={size_delta:+d}')
            # Show first few differences
            for i, (a, b) in enumerate(zip(got, want)):
                if a != b:
                    print(f'  0x{i:04X}: got={a:02X} want={b:02X}')
                if i > 100: break
            sys.exit(1)

if __name__ == '__main__':
    main()
