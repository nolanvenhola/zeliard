#!/usr/bin/env python3
"""Release-MASM checkpoint for 100OPDMO:palette_lookup.

The procedure builds the CS+2000h sprite-cache surface from the decoded
DMAOU image in gvar_game_seg.  This locks the segment boundary and byte-level
copy order used by the mechanical C runtime translation.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import (
    UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES, UC_X86_REG_IP,
    UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from test_mcga_render_entries_oracle import asset_source, fnv1a64  # noqa: E402

CODE, GAME, SCRATCH, STACK = 0x1000, 0x2000, 0x3000, 0x5000
LOAD_BASE, HEADER_SIZE, RET_SENTINEL = 0x6000, 4, 0x0080
ENTRY = LOAD_BASE + resolve_proc("opdmo", "palette_lookup") - HEADER_SIZE
EXPECTED_FNV = "7e5496f95d852ef4"
EXPECTED_NONZERO = 1075


def main() -> int:
    opdmo = (MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin").read_bytes()
    dmaou = asset_source("dmaou.grp")
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE, GAME, SCRATCH, STACK):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    code_base = CODE << 4
    mu.mem_write(code_base + LOAD_BASE - HEADER_SIZE, bytes(HEADER_SIZE))
    mu.mem_write(code_base + LOAD_BASE, opdmo[HEADER_SIZE:])
    mu.mem_write((GAME << 4) + 0x97C0, dmaou)
    mu.mem_write(code_base + 0xFF2C, bytes((GAME & 0xFF, GAME >> 8)))
    mu.mem_write((STACK << 4) + 0xFFFC,
                 bytes((RET_SENTINEL & 0xFF, RET_SENTINEL >> 8)))

    for reg, value in ((UC_X86_REG_CS, CODE), (UC_X86_REG_DS, CODE),
                       (UC_X86_REG_ES, CODE), (UC_X86_REG_SS, STACK),
                       (UC_X86_REG_SP, 0xFFFC)):
        mu.reg_write(reg, value)

    def stop_at_return(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, stop_at_return)
    mu.emu_start(code_base + ENTRY, 0)
    scratch = bytes(mu.mem_read(SCRATCH << 4, 0x2CA0))
    actual_fnv = fnv1a64(scratch)
    actual_nonzero = sum(byte != 0 for byte in scratch)
    ok = (mu.reg_read(UC_X86_REG_IP) == RET_SENTINEL and
          actual_fnv == EXPECTED_FNV and actual_nonzero == EXPECTED_NONZERO)
    print("opdemo_palette_lookup: " + ("PASS" if ok else "FAIL") +
          f" fnv={actual_fnv} nonzero={actual_nonzero}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": palette lookup matches release bytes")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
