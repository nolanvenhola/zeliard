#!/usr/bin/env python3
"""
exe2bin.py - Strip MZ header and org padding from EXE to produce raw binary.

Usage:
    python exe2bin.py input.exe output.bin [org_offset]

    org_offset: the ORG value used in the ASM source (hex or decimal).
                Defaults to 0 if not specified.

Examples:
    python exe2bin.py fight.exe fight.bin 0x6000
    python exe2bin.py gfmcga.exe gfmcga.bin 0x3000
    python exe2bin.py stick.exe stick.bin 0x100
"""

import struct, sys
from pathlib import Path

def exe_to_bin(exe_data, org_offset=0):
    hdr_paras = struct.unpack_from('<H', exe_data, 8)[0]
    code_start = hdr_paras * 16
    return exe_data[code_start + org_offset:]

if len(sys.argv) < 3:
    print("Usage: exe2bin.py input.exe output.bin [org_offset]")
    sys.exit(1)

src        = Path(sys.argv[1])
dst        = Path(sys.argv[2])
org_offset = int(sys.argv[3], 0) if len(sys.argv) > 3 else 0

exe_data = src.read_bytes()
raw = exe_to_bin(exe_data, org_offset)
dst.write_bytes(raw)
print(f"{src} -> {dst} ({len(raw)} bytes, skipped {org_offset:#x} bytes of org padding)")
