#!/usr/bin/env python3
"""
verify1.py - Compile a single MASM .asm file and verify it matches the release bin.

Usage (from masm/ directory):
  python verify1.py zelres1/106TOWN.asm
  python verify1.py zelres2/200FIGHT.asm
  python verify1.py core/game.asm
"""
import sys, re, tempfile, struct, shutil, subprocess
from pathlib import Path

ROOT    = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
BIN     = ROOT / 'bin'
TASM_ROOT = (ROOT / '../tasm').resolve()
MASM_DIR  = ROOT / 'tool/masm51'
TLINK_DIR = ROOT / 'tool/tlink'
DOSBOX    = ROOT / 'TasmRunner/bin/Debug/net8.0/dosbox/dosbox.exe'


def output_ext(stem):
    s = stem.upper()
    if re.match(r'^[123]\d{2}MP', s): return '.mdt'
    if re.match(r'^[123]\d{2}\w{2}MP$', s): return '.mdt'
    return '.bin'


def strip_mz(data):
    hdr = struct.unpack_from('<H', data, 8)[0]
    return data[hdr * 16:]


def compile_one(asm_path):
    """Compile asm_path with MASM 5.1 + TLINK. Returns (ok, bin_bytes, msg)."""
    stem     = asm_path.stem
    dos_stem = stem.upper()[:8]

    # Detect org offset (same logic as build_masm.py)
    org_offset = 0
    for line in asm_path.read_text(errors='replace').split('\n'):
        m = re.match(r'\s*org\s+([0-9A-Fa-f]+)h\b', line, re.IGNORECASE)
        if m:
            org_offset = int(m.group(1), 16)
            break

    with tempfile.TemporaryDirectory(prefix='z_verify_') as tmp:
        tmp = Path(tmp)

        # Mount parent of asm_path (the code/ or drivers/ directory) as 'w:'
        mount_root = asm_path.parent.parent   # zelresN or working root
        asm_subdir = asm_path.parent.name     # code, drivers, etc.

        conf = tmp / 'masm.conf'
        conf.write_text('\n'.join([
            '[autoexec]',
            '@echo off',
            f'mount m "{MASM_DIR}"',
            f'mount l "{TLINK_DIR}"',
            f'mount w "{mount_root}"',
            f'mount o "{tmp}"',
            'set PATH=M:\\;L:\\',
            'w:',
            f'cd {asm_subdir}',
            f'm:\\masm /l {asm_path.name},o:\\{dos_stem}.OBJ,o:\\{dos_stem}.LST,NUL; > o:\\out.txt',
            'echo MASM-EXIT:%errorlevel% >> o:\\out.txt',
            f'l:\\tlink /c /x o:\\{dos_stem}.OBJ,o:\\{dos_stem}.EXE >> o:\\out.txt',
            'echo TLINK-EXIT:%errorlevel% >> o:\\out.txt',
            'exit',
        ]) + '\n')

        try:
            subprocess.run([str(DOSBOX), '-conf', str(conf), '-exit'],
                           capture_output=True, text=True, timeout=180)
        except subprocess.TimeoutExpired:
            return False, None, 'TIMEOUT'
        except Exception as e:
            return False, None, f'spawn error: {e}'

        out_txt = tmp / 'OUT.TXT'
        masm_out = out_txt.read_text(errors='replace') if out_txt.exists() else ''

        exe = tmp / (dos_stem + '.EXE')
        if not exe.exists():
            return False, None, f'no EXE produced\n{masm_out[-600:]}'

        raw     = exe.read_bytes()
        stripped = strip_mz(raw)
        data    = stripped[org_offset:]
        return True, data, masm_out


def main():
    if len(sys.argv) < 2:
        print('Usage: verify1.py <zelresN/file.asm>  (relative to working/)')
        sys.exit(1)

    rel = sys.argv[1]
    # Accept both zelresN/file.asm and zelresN/code/file.asm
    asm = WORKING / rel
    if not asm.exists():
        print(f'Not found: {asm}')
        sys.exit(1)

    stem  = asm.stem
    parts = asm.relative_to(WORKING).parts

    # Always use TASM reference bins as ground truth
    tasm_bin = TASM_ROOT / 'bin'
    if len(parts) >= 2 and parts[0].startswith('zelres'):
        expected = tasm_bin / parts[0] / (stem + output_ext(stem))
    elif parts[0] in ('core', 'drivers'):
        expected = tasm_bin / (stem + output_ext(stem))
    else:
        expected = tasm_bin / (stem + output_ext(stem))

    if not expected.exists():
        # Fall back to masm bin
        if len(parts) >= 2 and parts[0].startswith('zelres'):
            expected = BIN / parts[0] / (stem + output_ext(stem))
        else:
            expected = BIN / (stem + output_ext(stem))

    if not expected.exists():
        print(f'No expected bin at: {expected}')
        sys.exit(1)

    print(f'Compiling {asm.name} ...')
    ok, got_bytes, msg = compile_one(asm)

    if not ok:
        print(f'FAIL: compilation failed')
        print(msg[-600:])
        sys.exit(1)

    want = expected.read_bytes()

    if got_bytes == want:
        rel_path = f'working/{"/".join(parts)}'
        print(f'BIT-PERFECT — {rel_path} matches expected ({len(want)} bytes)')
        sys.exit(0)
    else:
        diffs = sum(a != b for a, b in zip(got_bytes, want))
        extra = len(got_bytes) - len(want)
        print(f'MISMATCH: got {len(got_bytes)} bytes, want {len(want)} bytes, '
              f'{diffs} byte diffs, size delta {extra:+d}')
        # Show first differing byte
        for i, (a, b) in enumerate(zip(got_bytes, want)):
            if a != b:
                print(f'  First diff at offset 0x{i:04X}: got 0x{a:02X}, want 0x{b:02X}')
                break
        sys.exit(1)


if __name__ == '__main__':
    main()
