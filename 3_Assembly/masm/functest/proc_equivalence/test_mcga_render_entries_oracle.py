#!/usr/bin/env python3
"""Behavior oracle for MCGA image render entrypoints.

This executes the MASM-built 105GDMCA.bin bytes in Unicorn and captures the
MCGA framebuffer written through ES=A000.  These are driver-level contracts for
the opening port's C renderers:

* CS:3004 -> runtime 3088h: gfx_update_fn / render_plane_ab_loop
* CS:3010 -> runtime 33B7h: disp_game_fn / story image display

The synthetic fixture covers the entry wiring.  The asset-backed cases exercise
the same DS:SI source boundary used by the opening demo, so they catch real
plane-selection and clipped-blit drift in the web port.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import Uc, UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_BX,
    UC_X86_REG_CS,
    UC_X86_REG_CX,
    UC_X86_REG_DI,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SI,
    UC_X86_REG_SP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT  # noqa: E402


GDMCA_BIN = MASM_ROOT / "bin" / "zelres1" / "105GDMCA.bin"
OPDMO_BIN = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"

CODE_SEG = 0x1000
DATA_SEG = 0x2000
WORK_SEG = CODE_SEG + 0x3000
STACK_SEG = 0x6000
VGA_SEG = 0xA000

LOAD_BASE = 0x2FFC
RET_SENTINEL = 0x0080
FRAME_TIMER = 0xFF1A
FRAMEBUFFER_BYTES = 320 * 200

ENTRY_GFX_UPDATE = 0x3088
ENTRY_DISP_GAME = 0x33B7
OPDMO_LOAD_BASE = 0x5FFC
OPDMO_ENTRY_XOR_MASK_RENDER = 0x6F41
OPDMO_ENTRY_MERGE_GFX_PLANES = 0x6FAC
OPDMO_GFX_UPDATE_FN_SLOT = 0x3004
OPDMO_FRAMEBUFFER_A = 0x4000
OPDMO_EXT_SEGMENT = 0xD000

SRC_DI = 0x4000
BX = 0x0410
CX = 0x0810
PLANE_BYTES = ((CX >> 8) & 0xFF) * (CX & 0xFF)
SOURCE_BYTES = PLANE_BYTES * 3

ASSET_ROOT = MASM_ROOT.parent.parent / "6_WebPort" / "engine" / "assets"

EXPECTED = {
    "gfx_update_al00": {
        "entry": ENTRY_GFX_UPDATE,
        "ax": 0x0000,
        "fnv": "4d9cd38e12f64a4d",
        "nonzero": 416,
        "bbox": (16, 16, 47, 31),
    },
    "gfx_update_alff": {
        "entry": ENTRY_GFX_UPDATE,
        "ax": 0x00FF,
        "fnv": "4d9cd38e12f64a4d",
        "nonzero": 416,
        "bbox": (16, 16, 47, 31),
    },
    "disp_game_al06": {
        "entry": ENTRY_DISP_GAME,
        "ax": 0x0006,
        "fnv": "4d9cd38e12f64a4d",
        "nonzero": 416,
        "bbox": (16, 16, 47, 31),
    },
    "disp_game_al09": {
        "entry": ENTRY_DISP_GAME,
        "ax": 0x0009,
        "fnv": "4d9cd38e12f64a4d",
        "nonzero": 416,
        "bbox": (16, 16, 47, 31),
    },
    "hime_disp_game_al09": {
        "entry": ENTRY_DISP_GAME,
        "asset": "hime.grp",
        "rows": 0x48,
        "cl": 0x68,
        "ax": 0x0009,
        "fnv": "acf935f65da3df18",
        "nonzero": 29952,
        "bbox": (16, 16, 303, 119),
    },
    "hime_disp_game_al06": {
        "entry": ENTRY_DISP_GAME,
        "asset": "hime.grp",
        "rows": 0x48,
        "cl": 0x68,
        "ax": 0x0006,
        "fnv": "acf935f65da3df18",
        "nonzero": 29952,
        "bbox": (16, 16, 303, 119),
    },
    "isi_disp_game_al07": {
        "entry": ENTRY_DISP_GAME,
        "asset": "isi.grp",
        "rows": 0x48,
        "cl": 0x68,
        "ax": 0x0007,
        "fnv": "289821951f6f5dde",
        "nonzero": 10551,
        "bbox": (16, 16, 303, 119),
    },
    "sei_disp_game_al05": {
        "entry": ENTRY_DISP_GAME,
        "asset": "sei.grp",
        "rows": 0x24,
        "cl": 0x68,
        "ax": 0x0005,
        "fnv": "5d95614779039634",
        "nonzero": 9524,
        "bbox": (16, 16, 159, 117),
    },
    "yuu1_disp_game_al07": {
        "entry": ENTRY_DISP_GAME,
        "asset": "yuu1.grp",
        "rows": 0x48,
        "cl": 0x68,
        "ax": 0x0007,
        "fnv": "6c3fdfd6ae025e9f",
        "nonzero": 18564,
        "bbox": (16, 16, 303, 119),
    },
    "ame_disp_game_al00": {
        "entry": ENTRY_DISP_GAME,
        "asset": "ame.grp",
        "rows": 0x48,
        "cl": 0x68,
        "ax": 0x0000,
        "fnv": "a01eebd621d68a49",
        "nonzero": 24663,
        "bbox": (16, 16, 303, 119),
    },
}

YUU_RECT_EXPECTED = {
    "yuu_split_left_rect": {
        "di": 0x4000,
        "bx": 0x0B18,
        "cx": 0x1858,
        "fnv": "e95599ea7d6b89ed",
        "nonzero": 8448,
        "bbox": (44, 24, 139, 111),
    },
    "yuu_split_right_rect": {
        "di": 0x8000,
        "bx": 0x2D18,
        "cx": 0x1858,
        "fnv": "54c8bc1f7562731f",
        "nonzero": 8448,
        "bbox": (180, 24, 275, 111),
    },
    "yuu_portrait_sm0_rect": {
        "di": 0x98C0,
        "bx": 0x3350,
        "cx": 0x0E20,
        "fnv": "09006cc563c60c0f",
        "nonzero": 1792,
        "bbox": (204, 80, 259, 111),
    },
    "yuu_portrait_sm6_rect": {
        "di": 0xB840,
        "bx": 0x3338,
        "cx": 0x0B10,
        "fnv": "9f51f3c7c05b4b1a",
        "nonzero": 704,
        "bbox": (204, 56, 247, 71),
    },
    "yuu_portrait_lg0_rect": {
        "di": 0x58C0,
        "bx": 0x1350,
        "cx": 0x0920,
        "fnv": "f64f78e9a3a0de52",
        "nonzero": 1152,
        "bbox": (76, 80, 111, 111),
    },
    "yuu_portrait_lg6_rect": {
        "di": 0x6D00,
        "bx": 0x1238,
        "cx": 0x0B10,
        "fnv": "8cc3b7242ac94c75",
        "nonzero": 704,
        "bbox": (72, 56, 115, 71),
    },
}

NEC_HOU_HANDOFF_EXPECTED = {
    "di": 0x75A0,
    "bx": 0x2048,
    "cx": 0x1040,
    "ax": 0x00FF,
    "fnv": "9cca3279aebfea37",
    "nonzero": 1923,
    "bbox": (128, 72, 191, 128),
}

NEC_HOU_GFX_UPDATE_SEQUENCE_EXPECTED = {
    "fnv": "4be8b5f202d287f9",
    "nonzero": 2822,
    "bbox": (73, 34, 246, 128),
}

FINAL_COMPOSITE_EXPECTED = {
    "fnv": "92d8ad4d7c4c1f7f",
    "nonzero": 31986,
    "bbox": (32, 8, 287, 199),
}

MAOP_SCRIPT_AREA_EXPECTED = {
    "fnv": "a1dc196e7d430488",
    "nonzero": 16684,
    "bbox": (16, 16, 303, 119),
}

COMPOSED_EXPECTED = {
    "waku_ame_ax9": {
        "calls": [
            ("waku.grp", 0x0000, 0x0000, 0x5088, 0x4000),
            ("ame.grp", 0x0009, 0x0410, 0x4868, 0x4000),
        ],
        "fnv": "87930cdc61e043cf",
        "nonzero": 36231,
        "bbox": (0, 0, 319, 135),
    },
    "waku_hime_ax9": {
        "calls": [
            ("waku.grp", 0x0000, 0x0000, 0x5088, 0x4000),
            ("hime.grp", 0x0009, 0x0410, 0x4868, 0x4000),
        ],
        "fnv": "e4902326b0b62c7a",
        "nonzero": 41520,
        "bbox": (0, 0, 319, 135),
    },
    "waku_hime_ax6": {
        "calls": [
            ("waku.grp", 0x0000, 0x0000, 0x5088, 0x4000),
            ("hime.grp", 0x0006, 0x0410, 0x4868, 0x4000),
        ],
        "fnv": "e4902326b0b62c7a",
        "nonzero": 41520,
        "bbox": (0, 0, 319, 135),
    },
    "waku_isi_ax7": {
        "calls": [
            ("waku.grp", 0x0000, 0x0000, 0x5088, 0x4000),
            ("isi.grp", 0x0007, 0x0410, 0x4868, 0x4000),
        ],
        "fnv": "9a806ed4cade95b8",
        "nonzero": 22119,
        "bbox": (0, 0, 319, 135),
    },
}


def fnv1a64(data: bytes) -> str:
    h = 0xCBF29CE484222325
    for b in data:
        h ^= b
        h = (h * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016x}"


def framebuffer_bbox(frame: bytes) -> tuple[int, int, int, int] | None:
    pts = [(i % 320, i // 320) for i, b in enumerate(frame) if b]
    if not pts:
        return None
    return (
        min(x for x, _ in pts),
        min(y for _, y in pts),
        max(x for x, _ in pts),
        max(y for _, y in pts),
    )


def source_fixture() -> bytes:
    out = bytearray(SOURCE_BYTES)
    for i in range(SOURCE_BYTES):
        # Pattern chosen to exercise high/low bits in all three planes while
        # remaining stable across Python versions.
        out[i] = ((i * 37) ^ (i >> 1) ^ 0x5A) & 0xFF
    return bytes(out)


def fill_buffer_decompress(file_data: bytes) -> bytes:
    if len(file_data) < 5:
        raise ValueError("fill_buffer input too small")
    chunk_size = int.from_bytes(file_data[:4], "little")
    flag = file_data[4]
    if flag == 0:
        avail = max(chunk_size - 1, 0)
        buf = file_data[5:5 + avail]
    else:
        if len(file_data) < 9:
            raise ValueError("multi-section fill_buffer input too small")
        skip = int.from_bytes(file_data[5:7], "little")
        read_size = int.from_bytes(file_data[7:9], "little")
        start = 9 + skip
        buf = file_data[start:start + read_size]
    if not buf:
        raise ValueError("empty fill_buffer payload")
    opcode = buf[0] & 7
    data = buf[1:]

    def method0(d: bytes) -> bytes:
        return bytes(d)

    def method1(d: bytes) -> bytes:
        tbl_end = d.find(b"\xff")
        if tbl_end < 0:
            tbl_end = len(d)
        si = tbl_end + 1 if tbl_end < len(d) else tbl_end
        out = bytearray()
        while si < len(d):
            al = d[si]
            si += 1
            count, value = 1, al
            for p in range(0, tbl_end - 1, 2):
                key = d[p]
                if key & 0x0F:
                    break
                if (al & 0xF0) == key:
                    count, value = (al & 0x0F) + 2, d[p + 1]
                    break
            out.extend([value] * count)
        return bytes(out)

    def method2(d: bytes) -> bytes:
        marker, si, out = d[0], 1, bytearray()
        while si < len(d):
            al = d[si]
            si += 1
            count = 1
            if (al & 0xF0) == marker and si < len(d):
                count, al = (al & 0x0F) + 3, d[si]
                si += 1
            out.extend([al] * count)
        return bytes(out)

    def method3(d: bytes) -> bytes:
        tbl_end = d.find(b"\xff")
        if tbl_end < 0:
            tbl_end = len(d)
        si = tbl_end + 1 if tbl_end < len(d) else tbl_end
        out = bytearray()
        while si < len(d):
            al = d[si]
            si += 1
            count, value = 1, al
            for p in range(0, tbl_end - 1, 2):
                key = d[p]
                if key & 0xF0:
                    break
                if (al & 0x0F) == key:
                    count, value = (al >> 4) + 2, d[p + 1]
                    break
            out.extend([value] * count)
        return bytes(out)

    def method4(d: bytes) -> bytes:
        marker, si, out = d[0], 1, bytearray()
        while si < len(d):
            al = d[si]
            si += 1
            count = 1
            if (al & 0x0F) == marker and si < len(d):
                count, al = (al >> 4) + 3, d[si]
                si += 1
            out.extend([al] * count)
        return bytes(out)

    def method5(d: bytes) -> bytes:
        si, out = 0, bytearray()
        while si < len(d):
            al, count = d[si], 1
            if si + 1 < len(d) and d[si + 1] == al:
                if si + 2 < len(d):
                    count = d[si + 2] + 2
                    si += 2
                else:
                    si += 1
            si += 1
            out.extend([al] * count)
        return bytes(out)

    def method6(d: bytes) -> bytes:
        table, si = {}, 0
        while si + 1 < len(d):
            key, value = d[si], d[si + 1]
            si += 2
            if key == 0xFF and value == 0xFF:
                break
            table[key] = value
        out = bytearray()
        while si < len(d):
            b = d[si]
            si += 1
            if b in table and si < len(d):
                out.extend([table[b]] * (d[si] + 2))
                si += 1
            else:
                out.append(b)
        return bytes(out)

    def method7(d: bytes) -> bytes:
        escape, si, out = d[0], 1, bytearray()
        while si < len(d):
            b = d[si]
            si += 1
            if b == escape and si + 1 < len(d):
                value, count = d[si], d[si + 1] + 3
                si += 2
                out.extend([value] * count)
            else:
                out.append(b)
        return bytes(out)

    return [
        method0, method1, method2, method3,
        method4, method5, method6, method7,
    ][opcode](data)


def rcl_byte_1(value: int, carry: int) -> tuple[int, int]:
    return ((value << 1) & 0xFF) | (carry & 1), 1 if value & 0x80 else 0


def read_rcl_pair(value: int) -> tuple[int, int]:
    carry = 0
    al = 0
    value, carry = rcl_byte_1(value, carry)
    total = al + al + carry
    al, carry = total & 0xFF, 1 if total > 0xFF else 0
    value, carry = rcl_byte_1(value, carry)
    total = al + al + carry
    return value, total & 3


def img_open_decode_payload(payload: bytes) -> bytes:
    if len(payload) < 2:
        raise ValueError("img_open payload too small")
    ctrl_count = int.from_bytes(payload[:2], "little")
    out = bytearray(ctrl_count * 8)
    ctrl_i = 2
    lit_i = 2 + ctrl_count
    out_i = 0
    for _ in range(ctrl_count):
        ctrl = payload[ctrl_i] if ctrl_i < len(payload) else 0
        ctrl_i += 1
        for bit in range(7, -1, -1):
            if ctrl & (1 << bit):
                out[out_i] = payload[lit_i] if lit_i < len(payload) else 0
                lit_i += 1
            out_i += 1

    dh = 0
    for i, value in enumerate(out):
        value, pair = read_rcl_pair(value)
        dh ^= pair
        ah = dh
        value, pair = read_rcl_pair(value)
        dh ^= pair
        ah = ((ah << 2) | dh) & 0xFF
        value, pair = read_rcl_pair(value)
        dh ^= pair
        ah = ((ah << 2) | dh) & 0xFF
        value, pair = read_rcl_pair(value)
        dh ^= pair
        out[i] = ((ah << 2) | dh) & 0xFF
    return bytes(out)


def asset_source(asset: str) -> bytes:
    return img_open_decode_payload(
        fill_buffer_decompress((ASSET_ROOT / asset).read_bytes())
    )


def yuu_segment_source() -> bytes:
    seg = bytearray(0x10000)
    yuup = asset_source("yuup.grp")
    oup = asset_source("oup.grp")
    seg[0x4000:0x4000 + len(yuup)] = yuup
    seg[0x8000:0x8000 + len(oup)] = oup
    return bytes(seg)


def nec_hou_handoff_segment_source() -> bytes:
    seg = bytearray(0x10000)
    nec = asset_source("nec.grp")
    hou = asset_source("hou.grp")
    seg[0x4000:0x4000 + len(nec)] = nec
    seg[0x9000:0x9000 + len(hou)] = hou
    return bytes(seg)


def final_yuu_segment_source() -> bytes:
    data = OPDMO_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + OPDMO_LOAD_BASE, data)
    mu.mem_write(
        (CODE_SEG << 4) + OPDMO_GFX_UPDATE_FN_SLOT,
        bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]),
    )
    yuu3 = asset_source("yuu3.grp")
    yuu4 = asset_source("yuu4.grp")
    mu.mem_write(
        (DATA_SEG << 4) + OPDMO_FRAMEBUFFER_A,
        yuu3[:0x10000 - OPDMO_FRAMEBUFFER_A],
    )
    mu.mem_write(
        (DATA_SEG << 4) + OPDMO_EXT_SEGMENT,
        yuu4[:0x10000 - OPDMO_EXT_SEGMENT],
    )

    def hook_code(uc, _address, _size, _user):
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)

    for entry, regs in (
        (OPDMO_ENTRY_MERGE_GFX_PLANES, {UC_X86_REG_DI: OPDMO_FRAMEBUFFER_A}),
        (
            OPDMO_ENTRY_XOR_MASK_RENDER,
            {UC_X86_REG_SI: OPDMO_EXT_SEGMENT, UC_X86_REG_DI: OPDMO_FRAMEBUFFER_A},
        ),
    ):
        mu.reg_write(UC_X86_REG_CS, CODE_SEG)
        mu.reg_write(UC_X86_REG_DS, CODE_SEG)
        mu.reg_write(UC_X86_REG_ES, DATA_SEG)
        mu.reg_write(UC_X86_REG_SS, STACK_SEG)
        mu.reg_write(UC_X86_REG_SP, 0xFFFC)
        for reg, value in regs.items():
            mu.reg_write(reg, value)
        mu.mem_write(
            (STACK_SEG << 4) + 0xFFFC,
            bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]),
        )
        mu.emu_start((CODE_SEG << 4) + entry, (CODE_SEG << 4) + 0xFFFF)

    return bytes(mu.mem_read(DATA_SEG << 4, 0x10000))


def run_entry(entry: int, ax: int, bx: int = BX, cx: int = CX,
              di: int = SRC_DI, source: bytes | None = None,
              source_is_segment: bool = False) -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    if source is None:
        source = source_fixture()
    if source_is_segment:
        mu.mem_write(DATA_SEG << 4, source[:0x10000])
    else:
        mu.mem_write((DATA_SEG << 4) + di, source[:0x10000 - di])

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, DATA_SEG)
    mu.reg_write(UC_X86_REG_ES, DATA_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    mu.reg_write(UC_X86_REG_AX, ax)
    mu.reg_write(UC_X86_REG_BX, bx)
    mu.reg_write(UC_X86_REG_CX, cx)
    mu.reg_write(UC_X86_REG_DI, di)

    sp = 0xFFFC
    mu.reg_write(UC_X86_REG_SP, sp)
    mu.mem_write((STACK_SEG << 4) + sp,
                 bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))

    def hook_code(uc, _address, _size, _user):
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)
    mu.emu_start((CODE_SEG << 4) + entry, (CODE_SEG << 4) + 0xFFFF)
    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def run_disp_game_sequence(calls: list[tuple[str, int, int, int, int]]) -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)

    def hook_code(uc, _address, _size, _user):
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)

    for asset, ax, bx, cx, di in calls:
        source = asset_source(asset)
        mu.mem_write((DATA_SEG << 4) + di, source[:0x10000 - di])
        mu.reg_write(UC_X86_REG_DS, DATA_SEG)
        mu.reg_write(UC_X86_REG_ES, DATA_SEG)
        mu.reg_write(UC_X86_REG_AX, ax)
        mu.reg_write(UC_X86_REG_BX, bx)
        mu.reg_write(UC_X86_REG_CX, cx)
        mu.reg_write(UC_X86_REG_DI, di)
        sp = 0xFFFC
        mu.reg_write(UC_X86_REG_SP, sp)
        mu.mem_write((STACK_SEG << 4) + sp,
                     bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))
        mu.emu_start((CODE_SEG << 4) + ENTRY_DISP_GAME,
                     (CODE_SEG << 4) + 0xFFFF)

    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def run_nec_hou_gfx_update_sequence() -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)

    def hook_code(uc, _address, _size, _user):
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)

    for entry, ax, bx, cx, di, source, source_is_segment in (
        (ENTRY_GFX_UPDATE, 0x00FF, 0x1220, 0x2C68, OPDMO_FRAMEBUFFER_A,
         asset_source("nec.grp"), False),
        (ENTRY_DISP_GAME, NEC_HOU_HANDOFF_EXPECTED["ax"],
         NEC_HOU_HANDOFF_EXPECTED["bx"], NEC_HOU_HANDOFF_EXPECTED["cx"],
         NEC_HOU_HANDOFF_EXPECTED["di"], nec_hou_handoff_segment_source(), True),
    ):
        if source_is_segment:
            mu.mem_write(DATA_SEG << 4, source[:0x10000])
        else:
            mu.mem_write((DATA_SEG << 4) + di, source[:0x10000 - di])
        mu.reg_write(UC_X86_REG_DS, DATA_SEG)
        mu.reg_write(UC_X86_REG_ES, DATA_SEG)
        mu.reg_write(UC_X86_REG_AX, ax)
        mu.reg_write(UC_X86_REG_BX, bx)
        mu.reg_write(UC_X86_REG_CX, cx)
        mu.reg_write(UC_X86_REG_DI, di)
        sp = 0xFFFC
        mu.reg_write(UC_X86_REG_SP, sp)
        mu.mem_write((STACK_SEG << 4) + sp,
                     bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))
        mu.emu_start((CODE_SEG << 4) + entry, (CODE_SEG << 4) + 0xFFFF)

    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def run_maop_script_area_sequence() -> bytes:
    data = GDMCA_BIN.read_bytes()
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, DATA_SEG, WORK_SEG, STACK_SEG, VGA_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    mu.mem_write(CODE_SEG << 4, bytes([0x90]) * 0x10000)
    mu.mem_write((CODE_SEG << 4) + LOAD_BASE, data)
    maop = asset_source("maop.grp")
    mu.mem_write((DATA_SEG << 4) + 0x8000, maop[:0x8000])
    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)

    def hook_code(uc, _address, _size, _user):
        uc.mem_write((CODE_SEG << 4) + FRAME_TIMER, b"\xff")
        if uc.reg_read(UC_X86_REG_IP) == RET_SENTINEL:
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)
    for entry, ds, es, regs in (
        (
            0x38E6,
            CODE_SEG,
            CODE_SEG,
            {UC_X86_REG_AX: 8, UC_X86_REG_BX: 0x1515,
             UC_X86_REG_CX: 0x315D, UC_X86_REG_DI: 0},
        ),
        (
            0x3E35,
            DATA_SEG,
            DATA_SEG,
            {UC_X86_REG_AX: 8, UC_X86_REG_BX: 0x1618,
             UC_X86_REG_CX: 0x315D, UC_X86_REG_DI: 0x8000},
        ),
    ):
        mu.reg_write(UC_X86_REG_DS, ds)
        mu.reg_write(UC_X86_REG_ES, es)
        for reg, value in regs.items():
            mu.reg_write(reg, value)
        sp = 0xFFFC
        mu.reg_write(UC_X86_REG_SP, sp)
        mu.mem_write((STACK_SEG << 4) + sp,
                     bytes([RET_SENTINEL & 0xFF, RET_SENTINEL >> 8]))
        mu.emu_start((CODE_SEG << 4) + entry, (CODE_SEG << 4) + 0xFFFF)

    return bytes(mu.mem_read(VGA_SEG << 4, FRAMEBUFFER_BYTES))


def main() -> int:
    failures: list[str] = []
    for name, spec in EXPECTED.items():
        source = asset_source(spec["asset"]) if "asset" in spec else None
        cx = ((spec.get("rows", CX >> 8) & 0xFF) << 8) | (
            spec.get("cl", CX & 0xFF) & 0xFF
        )
        frame = run_entry(spec["entry"], spec["ax"], cx=cx, source=source)
        actual_fnv = fnv1a64(frame)
        actual_nonzero = sum(1 for b in frame if b)
        actual_bbox = framebuffer_bbox(frame)
        ok = (actual_fnv == spec["fnv"] and
              actual_nonzero == spec["nonzero"] and
              actual_bbox == spec["bbox"])
        print(
            f"mcga_render_{name}: {'PASS' if ok else 'FAIL'} "
            f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
        )
        if not ok:
            failures.append(name)

    yuu_source = yuu_segment_source()
    for name, spec in YUU_RECT_EXPECTED.items():
        frame = run_entry(ENTRY_DISP_GAME, 0, bx=spec["bx"], cx=spec["cx"],
                          di=spec["di"], source=yuu_source,
                          source_is_segment=True)
        actual_fnv = fnv1a64(frame)
        actual_nonzero = sum(1 for b in frame if b)
        actual_bbox = framebuffer_bbox(frame)
        ok = (actual_fnv == spec["fnv"] and
              actual_nonzero == spec["nonzero"] and
              actual_bbox == spec["bbox"])
        print(
            f"mcga_render_{name}: {'PASS' if ok else 'FAIL'} "
            f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
        )
        if not ok:
            failures.append(name)

    nec_hou_source = nec_hou_handoff_segment_source()
    frame = run_entry(
        ENTRY_DISP_GAME,
        NEC_HOU_HANDOFF_EXPECTED["ax"],
        bx=NEC_HOU_HANDOFF_EXPECTED["bx"],
        cx=NEC_HOU_HANDOFF_EXPECTED["cx"],
        di=NEC_HOU_HANDOFF_EXPECTED["di"],
        source=nec_hou_source,
        source_is_segment=True,
    )
    actual_fnv = fnv1a64(frame)
    actual_nonzero = sum(1 for b in frame if b)
    actual_bbox = framebuffer_bbox(frame)
    ok = (actual_fnv == NEC_HOU_HANDOFF_EXPECTED["fnv"] and
          actual_nonzero == NEC_HOU_HANDOFF_EXPECTED["nonzero"] and
          actual_bbox == NEC_HOU_HANDOFF_EXPECTED["bbox"])
    print(
        f"mcga_render_nec_hou_handoff_disp_game: {'PASS' if ok else 'FAIL'} "
        f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
    )
    if not ok:
        failures.append("nec_hou_handoff_disp_game")

    frame = run_nec_hou_gfx_update_sequence()
    actual_fnv = fnv1a64(frame)
    actual_nonzero = sum(1 for b in frame if b)
    actual_bbox = framebuffer_bbox(frame)
    ok = (actual_fnv == NEC_HOU_GFX_UPDATE_SEQUENCE_EXPECTED["fnv"] and
          actual_nonzero == NEC_HOU_GFX_UPDATE_SEQUENCE_EXPECTED["nonzero"] and
          actual_bbox == NEC_HOU_GFX_UPDATE_SEQUENCE_EXPECTED["bbox"])
    print(
        f"mcga_render_nec_hou_gfx_update_sequence: {'PASS' if ok else 'FAIL'} "
        f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
    )
    if not ok:
        failures.append("nec_hou_gfx_update_sequence")

    final_source = final_yuu_segment_source()
    frame = run_entry(ENTRY_GFX_UPDATE, 0x00FF, bx=0x0808, cx=0x40C0,
                      di=OPDMO_FRAMEBUFFER_A, source=final_source,
                      source_is_segment=True)
    actual_fnv = fnv1a64(frame)
    actual_nonzero = sum(1 for b in frame if b)
    actual_bbox = framebuffer_bbox(frame)
    ok = (actual_fnv == FINAL_COMPOSITE_EXPECTED["fnv"] and
          actual_nonzero == FINAL_COMPOSITE_EXPECTED["nonzero"] and
          actual_bbox == FINAL_COMPOSITE_EXPECTED["bbox"])
    print(
        f"mcga_render_final_yuu3_yuu4_composite: {'PASS' if ok else 'FAIL'} "
        f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
    )
    if not ok:
        failures.append("final_yuu3_yuu4_composite")

    for name, spec in COMPOSED_EXPECTED.items():
        frame = run_disp_game_sequence(spec["calls"])
        actual_fnv = fnv1a64(frame)
        actual_nonzero = sum(1 for b in frame if b)
        actual_bbox = framebuffer_bbox(frame)
        ok = (actual_fnv == spec["fnv"] and
              actual_nonzero == spec["nonzero"] and
              actual_bbox == spec["bbox"])
        print(
            f"mcga_render_{name}: {'PASS' if ok else 'FAIL'} "
            f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
        )
        if not ok:
            failures.append(name)

    frame = run_maop_script_area_sequence()
    actual_fnv = fnv1a64(frame)
    actual_nonzero = sum(1 for b in frame if b)
    actual_bbox = framebuffer_bbox(frame)
    ok = (actual_fnv == MAOP_SCRIPT_AREA_EXPECTED["fnv"] and
          actual_nonzero == MAOP_SCRIPT_AREA_EXPECTED["nonzero"] and
          actual_bbox == MAOP_SCRIPT_AREA_EXPECTED["bbox"])
    print(
        f"mcga_render_maop_script_area: {'PASS' if ok else 'FAIL'} "
        f"fnv={actual_fnv} nonzero={actual_nonzero} bbox={actual_bbox}"
    )
    if not ok:
        failures.append("maop_script_area")

    if failures:
        print("VERDICT: FAIL: MCGA render entry mismatch for " +
              ", ".join(failures))
        return 1
    print("VERDICT: PASS: MCGA render entry oracles match MASM bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
