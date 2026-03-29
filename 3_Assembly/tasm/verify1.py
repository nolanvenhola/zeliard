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

def main():
    if len(sys.argv) < 2:
        print('Usage: verify1.py <subpath/to/file.asm>')
        sys.exit(1)

    rel = sys.argv[1]
    asm = WORKING / rel
    if not asm.exists():
        print(f'Not found: {asm}'); sys.exit(1)

    stem = asm.stem
    # Determine expected bin path (zelresN/code → bin/zelresN)
    parts = asm.relative_to(WORKING).parts  # e.g. ('zelres1', 'code', 'foo.asm')
    if len(parts) >= 2 and parts[0].startswith('zelres'):
        expected = BIN / parts[0] / (stem + output_ext(stem))
    elif parts[0] in ('core', 'drivers'):
        expected = BIN / (stem + output_ext(stem))
    else:
        expected = BIN / (stem + output_ext(stem))

    if not expected.exists():
        print(f'No expected bin: {expected}'); sys.exit(1)

    with tempfile.TemporaryDirectory(prefix='z_verify_') as tmp:
        result = subprocess.run(
            [str(RUNNER), str(asm), '--bin', '--output', tmp],
            capture_output=True, text=True
        )
        out_bin = Path(tmp) / (stem.upper() + output_ext(stem).upper())
        if not out_bin.exists():
            out_bin = Path(tmp) / (stem + output_ext(stem))
        if not out_bin.exists():
            # Try stripping MZ from .exe
            out_exe = Path(tmp) / (stem.upper() + '.EXE')
            if out_exe.exists():
                raw = strip_mz(out_exe.read_bytes())
                out_bin = Path(tmp) / (stem + output_ext(stem))
                out_bin.write_bytes(raw)

        if not out_bin.exists():
            print(f'FAIL: no output produced (exit {result.returncode})')
            if result.stderr: print(result.stderr[:200])
            sys.exit(1)

        got  = out_bin.read_bytes()
        want = expected.read_bytes()

        if got == want:
            print(f'BIT-PERFECT  {stem}{output_ext(stem)}  ({len(got)} bytes)')
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
