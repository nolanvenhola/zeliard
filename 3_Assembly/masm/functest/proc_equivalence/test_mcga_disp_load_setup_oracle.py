#!/usr/bin/env python3
"""Behavior oracle for MCGA disp_font_inv / scroll-ring renderer.

This executes the MASM-built 105GDMCA.bin bytes in Unicorn and captures the
64000-byte MCGA framebuffer written through ES=A000.  It is intentionally a
driver-level oracle: the web port should match these hashes when translating
the opening-demo inverse-font calls that dispatch through CS:3020.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import Uc, UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_CS,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"

CODE_SEG = 0x1000
STACK_SEG = 0x5000
VGA_SEG = 0xA000

# 105GDMCA.bin includes the four-byte SAR header.  At runtime the loader strips
# that header, so file offset N maps to CS:(0x3000 - 4 + N).
LOAD_BASE = 0x2FFC
DISP_FONT_INV = 0x38E6
LOOKUP_PALETTE_ENTRY = 0x39C4
RET_SENTINEL = 0x0080
FRAME_TIMER = 0xFF1A
FRAMEBUFFER_BYTES = 320 * 200


EXPECTED = {
    # Values observed in 100OPDMO's MASM semantic trace:
    #   post_title_yuu_split disp_load_setup AX=0006
    #   post_title_maop_setup disp_load_setup AX=0008
    0x0006: ("2deb8b761ec82310", 21509, (16, 16, 303, 119)),
    0x0008: ("8ee815ad4c559738", 21509, (16, 16, 303, 119)),

    # Suspicious/important timer value used by wait_story_scene_timer after
    # reveal calls; this guards against accidentally treating AL=0F as a draw
    # parameter without evidence.
    0x000F: ("f367db99ee55cc05", 297, (16, 16, 303, 119)),
}

PARTIAL_EXPECTED = {
    # Partial captures stop immediately before the N+1th
    # lookup_palette_entry_mcga call. These are the browser reveal animation
    # checkpoints for the AX=0F mask used late in 100OPDMO.
    (0x000F, 0): ("dd14fcc6528cab25", 0, None),
    (0x000F, 24): ("7fe0fcd0234eeb53", 113, (16, 16, 19, 111)),
    (0x000F, 48): ("abef20a5dcc8a033", 138, (16, 16, 27, 119)),
    (0x000F, 72): ("abef20a5dcc8a033", 138, (16, 16, 27, 119)),
    (0x000F, 96): ("e90b4d1e375f70f3", 148, (16, 16, 299, 119)),
    (0x000F, 120): ("6463a816dfa96235", 262, (16, 16, 303, 119)),
    (0x000F, 144): ("45f68d2d081c1353", 287, (16, 16, 303, 119)),
    (0x000F, 168): ("45f68d2d081c1353", 287, (16, 16, 303, 119)),
    (0x000F, 192): ("f367db99ee55cc05", 297, (16, 16, 303, 119)),
}


def fnv1a64(data: bytes) -> str:
    h = 0xCBF29CE484222325
    for b in data:
        h ^= b
        h = (h * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016x}"


def framebuffer_bbox(frame: bytes) -> tuple[int, int, int, int] | None:
    pts: list[tuple[int, int]] = []
    for offset, value in enumerate(frame):
        if value:
            pts.append((offset % 320, offset // 320))
    if not pts:
        return None
    return (
        min(x for x, _ in pts),
        min(y for _, y in pts),
        max(x for x, _ in pts),
        max(y for _, y in pts),
    )


def run_disp_font_inv(ax: int, max_entries: int | None = None) -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, VGA_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_AX, ax)

    sp = 0xFFFC
    mu.reg_write(UC_X86_REG_SP, sp)
    mu.mem_write((STACK_SEG << 4) + sp,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    lookup_count = 0

    def hook_code(uc, _address, _size, _user):
        nonlocal lookup_count
        # disp_scroll_ring waits on the ISR-driven frame timer during its
        # horizontal pass.  In this isolated oracle, force the timer elapsed.
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        ip = uc.reg_read(UC_X86_REG_IP)
        if ip == LOOKUP_PALETTE_ENTRY:
            if max_entries is not None and lookup_count >= max_entries:
                uc.emu_stop()
                return
            lookup_count += 1
        if ip == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.emu_start((CODE_SEG << 4) + DISP_FONT_INV,
                 (CODE_SEG << 4) + 0xFFFF)
    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def main() -> int:
    failures: list[str] = []
    for ax, (expected_hash, expected_nonzero, expected_bbox) in EXPECTED.items():
        frame = run_disp_font_inv(ax)
        actual_hash = fnv1a64(frame)
        actual_nonzero = sum(1 for b in frame if b)
        actual_bbox = framebuffer_bbox(frame)
        ok = (actual_hash == expected_hash and
              actual_nonzero == expected_nonzero and
              actual_bbox == expected_bbox)
        print(
            f"mcga_disp_font_inv_ax{ax:02x}: "
            f"{'PASS' if ok else 'FAIL'} "
            f"hash={actual_hash} nonzero={actual_nonzero} bbox={actual_bbox}"
        )
        if not ok:
            failures.append(f"AX={ax:04x}")

    for (ax, max_entries), (expected_hash, expected_nonzero,
                            expected_bbox) in PARTIAL_EXPECTED.items():
        frame = run_disp_font_inv(ax, max_entries)
        actual_hash = fnv1a64(frame)
        actual_nonzero = sum(1 for b in frame if b)
        actual_bbox = framebuffer_bbox(frame)
        ok = (actual_hash == expected_hash and
              actual_nonzero == expected_nonzero and
              actual_bbox == expected_bbox)
        print(
            f"mcga_disp_font_inv_ax{ax:02x}_entry{max_entries:03d}: "
            f"{'PASS' if ok else 'FAIL'} "
            f"hash={actual_hash} nonzero={actual_nonzero} bbox={actual_bbox}"
        )
        if not ok:
            failures.append(f"AX={ax:04x}/entry={max_entries}")

    if failures:
        print(f"VERDICT: FAIL: MCGA disp_font_inv mismatch for {', '.join(failures)}")
        return 1
    print("VERDICT: PASS: MCGA disp_font_inv oracle matches MASM bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
