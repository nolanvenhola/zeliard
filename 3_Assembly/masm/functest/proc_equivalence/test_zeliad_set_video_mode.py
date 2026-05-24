#!/usr/bin/env python3
"""Runtime oracle for zeliad.asm set_video_mode.

The DOS loader dispatches on graphics_mode:
  0 -> INT 10h AX=000Eh
  1 -> INT 10h AX=0005h
  2 -> INT 10h AX=0006h
  3 -> Hercules register setup + B000 clear
  4 -> INT 10h AX=0013h
  5 -> INT 10h AX=0009h
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_HOOK_INTR, UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_AX, UC_X86_REG_DX

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, TasmHarness  # noqa: E402
from masm_image import materialize_mz_image  # noqa: E402


MASM_ROOT = HERE.parents[1]
ZELIAD_BIN = materialize_mz_image(MASM_ROOT / "bin" / "zeliad.exe",
                                  "masm_zeliad")

LOAD_BASE = 0x0000
SET_VIDEO_MODE = 0x057A
OFF_GRAPHICS_MODE = 0x08E7

HGC_VIDEO_BASE = 0xB0000
HGC_VIDEO_SIZE = 0x10000
HGC_CLEAR_BYTES = 0x8000


def run_mode(mode: int) -> tuple[dict, list[dict[str, int]], int]:
    h = TasmHarness(ZELIAD_BIN, LOAD_BASE)
    h.write_code(OFF_GRAPHICS_MODE, [mode])
    int_calls: list[dict[str, int]] = []
    hgc_writes = 0

    def hook_intr(uc, intno, _ud):
        int_calls.append({
            "int": intno & 0xFF,
            "ax": uc.reg_read(UC_X86_REG_AX) & 0xFFFF,
            "dx": uc.reg_read(UC_X86_REG_DX) & 0xFFFF,
        })

    def hook_hgc_write(_uc, _access, addr, size, _value, _ud):
        nonlocal hgc_writes
        if HGC_VIDEO_BASE <= addr < HGC_VIDEO_BASE + HGC_CLEAR_BYTES:
            hgc_writes += size

    h.mu.mem_map(HGC_VIDEO_BASE, HGC_VIDEO_SIZE)
    intr_hook = h.mu.hook_add(UC_HOOK_INTR, hook_intr)
    write_hook = h.mu.hook_add(UC_HOOK_MEM_WRITE, hook_hgc_write,
                               begin=HGC_VIDEO_BASE,
                               end=HGC_VIDEO_BASE + HGC_VIDEO_SIZE - 1)
    try:
        result = h.call_function(SET_VIDEO_MODE, max_steps=50000)
    finally:
        h.mu.hook_del(intr_hook)
        h.mu.hook_del(write_hook)
    return result, int_calls, hgc_writes


def expect(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def main() -> int:
    failures: list[str] = []
    expected_int_modes = {
        0: 0x000E,
        1: 0x0005,
        2: 0x0006,
        4: 0x0013,
        5: 0x0009,
    }

    for mode, expected_ax in expected_int_modes.items():
        result, calls, hgc_writes = run_mode(mode)
        expect(result["stopped_reason"] == "returned_to_sentinel", failures,
               f"mode {mode} did not return cleanly: {result['stopped_reason']}")
        expect(len(calls) == 1, failures, f"mode {mode} INT count {len(calls)} != 1")
        if len(calls) == 1:
            expect(calls[0]["int"] == 0x10, failures,
                   f"mode {mode} interrupt {calls[0]['int']:02X} != 10")
            expect(calls[0]["ax"] == expected_ax, failures,
                   f"mode {mode} AX {calls[0]['ax']:04X} != {expected_ax:04X}")
        expect(hgc_writes == 0, failures,
               f"mode {mode} unexpectedly wrote {hgc_writes} HGC bytes")

    result, calls, hgc_writes = run_mode(3)
    expect(result["stopped_reason"] == "returned_to_sentinel", failures,
           f"HGC did not return cleanly: {result['stopped_reason']}")
    expect(len(calls) == 0, failures, f"HGC made {len(calls)} INT calls")
    expect(hgc_writes == HGC_CLEAR_BYTES, failures,
           f"HGC clear wrote {hgc_writes} bytes != {HGC_CLEAR_BYTES}")
    expect(result["regs_after"]["es"] == 0xB000, failures,
           f"HGC ES {result['regs_after']['es']:04X} != B000")

    if failures:
        print("zeliad set_video_mode oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("zeliad set_video_mode oracle: INT 10h modes and HGC video clear match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
