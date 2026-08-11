#!/usr/bin/env python3
"""
masm_runner.py - Build a single .asm file with MASM 5.1 in DOSBox.

This is the MASM equivalent of TasmRunner.exe.  MASM 5.1 accepts the
`equ CONST + offset label` syntax that TASM 2.01 rejects with "Operand
types do not match", so symbolic chunk-relative addressing can be used
directly without the IF DEBUG_BUILD workaround.

Usage:
    python masm_runner.py <subpath/to/file.asm> [--bin] [--output DIR]
"""
import sys, subprocess, tempfile, struct, argparse, shutil
from pathlib import Path

ROOT      = Path(__file__).parent.resolve()  # masm/
WORKING   = ROOT / 'working'                 # masm-local ASM source copy
MASM_DIR  = ROOT / 'tool/masm51'
LINK_DIR  = ROOT / 'tool/tlink'
DOSBOX    = ROOT / 'TasmRunner/bin/Debug/net8.0/dosbox/dosbox.exe'


def background_process_options():
    """Run the assembler emulator without a focus-stealing GUI window."""
    if sys.platform != 'win32':
        return {}
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = subprocess.SW_HIDE
    return {
        'startupinfo': startup,
        'creationflags': subprocess.CREATE_NO_WINDOW,
    }


def strip_mz(data):
    hdr = struct.unpack_from('<H', data, 8)[0]
    return data[hdr * 16:]


def build(asm_path: Path, output_dir: Path, want_bin: bool, link: bool) -> tuple[bool, str]:
    """
    Returns (success, message).  Output files (OBJ/LST/EXE/BIN) are
    placed in output_dir using the asm's stem as the basename.
    """
    stem = asm_path.stem
    # MASM 5.1's filename is also case-sensitive in some contexts; uppercase
    # to match DOS conventions.
    dos_stem = stem.upper()[:8]

    with tempfile.TemporaryDirectory(prefix='z_masm_') as tmp:
        tmp = Path(tmp)

        # Copy the asm + ALL .inc files from the asm's directory.
        # MASM resolves include paths relative to the source file.
        for f in asm_path.parent.iterdir():
            if f.suffix.lower() in ('.asm', '.inc'):
                shutil.copy(f, tmp / f.name)

        conf = tmp / 'masm.conf'
        lines = [
            '[autoexec]',
            '@echo off',
            f'mount m "{MASM_DIR}"',
            f'mount l "{LINK_DIR}"',
            f'mount w "{tmp}"',
            'set PATH=M:\\;L:\\',
            'w:',
            f'm:\\masm /l {asm_path.name},{dos_stem}.OBJ,{dos_stem}.LST,NUL; > out.txt',
            'echo MASM-EXIT:%errorlevel% >> out.txt',
        ]
        if link:
            # TLINK from TASM 2.01 reads MASM OBJ records and produces an
            # MZ EXE.  /c = case sensitive, /x = no map file.
            lines += [
                'echo === TLINK === >> out.txt',
                f'l:\\tlink /c /x {dos_stem}.OBJ,{dos_stem}.EXE >> out.txt',
                'echo TLINK-EXIT:%errorlevel% >> out.txt',
            ]
        lines.append('exit')
        conf.write_text('\n'.join(lines) + '\n')

        subprocess.run([str(DOSBOX), '-conf', str(conf), '-exit'],
                       capture_output=True, text=True, timeout=120,
                       **background_process_options())

        out_txt = (tmp / 'OUT.TXT')
        if not out_txt.exists():
            out_txt = (tmp / 'out.txt')
        masm_output = out_txt.read_text(errors='replace') if out_txt.exists() else '(no output)'

        # Collect produced files
        produced = {}
        for ext in ('.OBJ', '.LST', '.EXE'):
            f = tmp / (dos_stem + ext)
            if f.exists():
                produced[ext.lower()] = f

        if '.obj' not in produced:
            return False, f'MASM did not produce OBJ.\n{masm_output[:1500]}'

        # Copy results to output_dir
        output_dir.mkdir(parents=True, exist_ok=True)
        for ext, src in produced.items():
            shutil.copy(src, output_dir / (stem + ext))

        # If --bin requested, strip MZ header from EXE
        if want_bin and '.exe' in produced:
            exe_data = produced['.exe'].read_bytes()
            bin_data = strip_mz(exe_data)
            (output_dir / (stem + '.bin')).write_bytes(bin_data)
        elif want_bin and '.exe' not in produced:
            return False, f'No EXE produced — LINK failed.\n{masm_output}'

        return True, masm_output


def main():
    p = argparse.ArgumentParser(description='MASM 5.1 runner via DOSBox')
    p.add_argument('asm', help='Path to .asm file (relative to working/ or absolute)')
    p.add_argument('--output', default=None, help='Output directory (default: tempdir alongside asm)')
    p.add_argument('--bin', action='store_true', help='Also strip MZ header and write .bin')
    p.add_argument('--no-link', action='store_true', help='Stop after MASM (no LINK)')
    args = p.parse_args()

    asm = Path(args.asm)
    if not asm.is_absolute():
        asm = (WORKING / args.asm).resolve()
    if not asm.exists():
        print(f'Not found: {asm}'); sys.exit(1)

    output_dir = Path(args.output).resolve() if args.output else asm.parent
    ok, msg = build(asm, output_dir, want_bin=args.bin, link=not args.no_link)
    if ok:
        print(f'OK: {asm.name}')
        # Show key output lines only
        for line in msg.split('\n'):
            line = line.strip()
            if line and ('Error' in line or 'EXIT' in line or 'Bytes' in line):
                print(f'  {line}')
        sys.exit(0)
    else:
        print(f'FAIL: {asm.name}')
        print(msg)
        sys.exit(1)


if __name__ == '__main__':
    main()
