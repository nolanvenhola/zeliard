#!/usr/bin/env python3
"""Oracle for GAME.BIN set_vga_palette.

The proc dispatches by gvar_gfx_mode:
  mode 0      -> one INT 10h/AX=1002h call with the EGA palette table
  modes 1/2/3/5 -> no palette programming
  mode 4      -> 64 INT 10h/AX=1010h DAC writes, generated from an 8x8
                 base-color addition table
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import UC_HOOK_INTR
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_BX,
    UC_X86_REG_CX,
    UC_X86_REG_DX,
    UC_X86_REG_ES,
)

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from harness import CODE_SEG, TasmHarness  # noqa: E402


GAME_BIN = MASM_ROOT / "bin" / "game.bin"
LOAD_BASE = 0xA000
OFF_GVAR_GFX_MODE = 0xFF14

EGA_ATTR_PALETTE = bytes([
    0x00,
    0x3F, 0x24, 0x12, 0x1B, 0x09, 0x36, 0x2D, 0x38,
    0x07, 0x04, 0x02, 0x03, 0x01, 0x06, 0x05, 0x00,
])

MCGA_BASE_COLORS = [
    (0x00, 0x00, 0x00),
    (0x1F, 0x1F, 0x1F),
    (0x1F, 0x00, 0x00),
    (0x00, 0x1F, 0x00),
    (0x00, 0x1F, 0x1F),
    (0x00, 0x00, 0x1F),
    (0x1F, 0x1F, 0x00),
    (0x1F, 0x00, 0x1F),
]


def expected_mcga_writes() -> list[tuple[int, int, int, int]]:
    writes: list[tuple[int, int, int, int]] = []
    index = 0
    for base_r, base_g, base_b in MCGA_BASE_COLORS:
        for off_r, off_g, off_b in MCGA_BASE_COLORS:
            writes.append((index, base_r + off_r, base_g + off_g, base_b + off_b))
            index += 1
    return writes


def run_palette_mode(mode: int) -> tuple[dict, list[dict[str, int]], TasmHarness]:
    h = TasmHarness(str(GAME_BIN), load_base=LOAD_BASE)
    h.write_byte(OFF_GVAR_GFX_MODE, mode)
    calls: list[dict[str, int]] = []

    def hook_intr(uc, intno, _ud):
        ax = uc.reg_read(UC_X86_REG_AX) & 0xFFFF
        bx = uc.reg_read(UC_X86_REG_BX) & 0xFFFF
        cx = uc.reg_read(UC_X86_REG_CX) & 0xFFFF
        dx = uc.reg_read(UC_X86_REG_DX) & 0xFFFF
        calls.append({
            "int": intno & 0xFF,
            "ax": ax,
            "bx": bx,
            "cx": cx,
            "dx": dx,
            "es": uc.reg_read(UC_X86_REG_ES) & 0xFFFF,
            "dh": (dx >> 8) & 0xFF,
            "ch": (cx >> 8) & 0xFF,
            "cl": cx & 0xFF,
        })

    hook = h.mu.hook_add(UC_HOOK_INTR, hook_intr)
    try:
        proc = resolve_proc("game", "set_vga_palette") + LOAD_BASE
        result = h.call_function(proc, max_steps=2000)
    finally:
        h.mu.hook_del(hook)
    return result, calls, h


def expect(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def main() -> int:
    failures: list[str] = []

    ega_result, ega_calls, ega_h = run_palette_mode(0)
    expect(ega_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"EGA did not return cleanly: {ega_result['stopped_reason']}")
    expect(len(ega_calls) == 1, failures, f"EGA INT count {len(ega_calls)} != 1")
    if len(ega_calls) == 1:
        call = ega_calls[0]
        expect(call["int"] == 0x10, failures, f"EGA interrupt {call['int']:02X} != 10")
        expect(call["ax"] == 0x1002, failures, f"EGA AX {call['ax']:04X} != 1002")
        expect(call["es"] == CODE_SEG, failures, f"EGA ES {call['es']:04X} != CS")
        palette = ega_h.mu.mem_read((CODE_SEG << 4) + call["dx"], len(EGA_ATTR_PALETTE))
        expect(bytes(palette) == EGA_ATTR_PALETTE, failures,
               f"EGA palette table {bytes(palette).hex()} != {EGA_ATTR_PALETTE.hex()}")

    for mode in (1, 2, 3, 5):
        result, calls, _h = run_palette_mode(mode)
        expect(result["stopped_reason"] == "returned_to_sentinel", failures,
               f"mode {mode} did not return cleanly: {result['stopped_reason']}")
        expect(len(calls) == 0, failures, f"mode {mode} made {len(calls)} INT calls")

    mcga_result, mcga_calls, _mcga_h = run_palette_mode(4)
    expected = expected_mcga_writes()
    got = [(c["bx"], c["dh"], c["ch"], c["cl"]) for c in mcga_calls]
    expect(mcga_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"MCGA did not return cleanly: {mcga_result['stopped_reason']}")
    expect(len(mcga_calls) == 64, failures, f"MCGA INT count {len(mcga_calls)} != 64")
    expect(all(c["int"] == 0x10 and c["ax"] == 0x1010 for c in mcga_calls),
           failures, "MCGA calls were not all INT 10h AX=1010h")
    expect(got == expected, failures, "MCGA DAC writes did not match 8x8 base-color sums")

    if failures:
        print("game set_vga_palette oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("game set_vga_palette oracle: EGA table, no-op modes, and MCGA DAC writes match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
