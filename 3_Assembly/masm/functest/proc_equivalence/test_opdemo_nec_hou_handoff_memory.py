#!/usr/bin/env python3
"""Oracle for OPDEMO's NEC/HOU handoff memory state.

This runs MASM-built 100OPDMO.bin through the first castle/amulet setup with
real fill_buffer payloads. External driver calls are stubbed. OPDEMO's
decompress_image boundary is instrumented with a mechanical Python translation
of that MASM proc so decoded buffers land in the same ES:DI ranges without
letting image writes overlap the executing chunk in this standalone harness.
The probe stops at the HOU disp_game_fn call:

    mov bx,2048h
    mov cx,1040h
    mov es,gvar_game_seg
    mov di,75A0h
    call word ptr cs:[3010h]

The goal is to lock down the exact memory that the C runtime must model before
the browser path tries to draw this span.
"""

from __future__ import annotations

import sys
from pathlib import Path

from unicorn import (
    Uc,
    UC_ARCH_X86,
    UC_HOOK_CODE,
    UC_MODE_16,
    UC_PROT_ALL,
)
from unicorn.x86_const import (
    UC_X86_REG_AX,
    UC_X86_REG_EAX,
    UC_X86_REG_EBX,
    UC_X86_REG_ECX,
    UC_X86_REG_EDX,
    UC_X86_REG_ESI,
    UC_X86_REG_EDI,
    UC_X86_REG_EBP,
    UC_X86_REG_BX,
    UC_X86_REG_CS,
    UC_X86_REG_CX,
    UC_X86_REG_DI,
    UC_X86_REG_DS,
    UC_X86_REG_ES,
    UC_X86_REG_IP,
    UC_X86_REG_SI,
    UC_X86_REG_SP,
    UC_X86_REG_ESP,
    UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from harness import CODE_SEG, STACK_SEG  # noqa: E402
from test_mcga_render_entries_oracle import fill_buffer_decompress, fnv1a64  # noqa: E402
import test_opdemo_opening_sequence as opdmo  # noqa: E402


OPDEMO_BIN = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
ASSET_ROOT = MASM_ROOT.parent.parent / "6_WebPort" / "engine" / "assets"
GAME_SEG = 0x2000

LOAD_BASE = 0x6000
HEADER_SIZE = 4
RET_SENTINEL = 0x0080

SAR_THUNK = 0x0200
RET_THUNK = 0x0202
STOP_THUNK = 0x0214
DECOMPRESS_IMAGE_ENTRY = LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE

EXPECTED = {
    "disp_regs": (0x2048, 0x1040, 0x75A0, GAME_SEG),
    "mem_4000_fnv": "37e229a1ff0277cb",
    "mem_75a0_fnv": "e031286249ba5435",
    "mem_9000_fnv": "ae1c24df5911f572",
    "mem_97c0_fnv": "b066e9e800f20da0",
    "mem_4000_nonzero": 1422,
    "mem_75a0_nonzero": 702,
    "mem_9000_nonzero": 1074,
    "mem_97c0_nonzero": 298,
}


def word_bytes(value: int) -> bytes:
    return bytes((value & 0xFF, (value >> 8) & 0xFF))


def install_slots(mu: Uc) -> None:
    base = CODE_SEG << 4
    for slot in (
        opdmo.GFX_INIT_SLOT,
        opdmo.NARRATION_STONE_SLOT,
        opdmo.GFX_DRAW_SLOT,
        opdmo.GFX_UPDATE_SLOT,
        opdmo.GFX_MODE_SLOT,
        opdmo.GFX_PALETTE_SLOT,
        opdmo.DISP_NARR_CHAP3_SLOT,
    ):
        mu.mem_write(base + slot, word_bytes(RET_THUNK))

    mu.mem_write(base + opdmo.SAR_LOADER_SLOT, word_bytes(SAR_THUNK))
    mu.mem_write(base + opdmo.DISP_GAME_SLOT, word_bytes(STOP_THUNK))


def read_resource_ref(mu: Uc, seg: int, off: int) -> bytes:
    out = bytearray(mu.mem_read((seg << 4) + off, 2))
    cur = (seg << 4) + off + 2
    while True:
        value = mu.mem_read(cur, 1)[0]
        cur += 1
        if value == 0:
            return bytes(out)
        out.append(value)


def asset_for_ref(ref: bytes) -> str:
    name = ref[2:].decode("ascii").lower()
    if name not in {"ttl3.grp", "nec.grp", "hou.grp", "dmaou.grp"}:
        raise AssertionError(f"unexpected SAR ref {ref!r}")
    return name


def rol8(value: int) -> tuple[int, int]:
    carry = 1 if value & 0x80 else 0
    return ((value << 1) | carry) & 0xFF, carry


def rcl8(value: int, carry: int) -> tuple[int, int]:
    next_carry = 1 if value & 0x80 else 0
    return ((value << 1) | (carry & 1)) & 0xFF, next_carry


def adc_al_al(value: int, carry: int) -> tuple[int, int]:
    total = value + value + (carry & 1)
    return total & 0xFF, 1 if total > 0xFF else 0


def img_decompress_image_masm_equivalent(
    src: bytes,
    source_base: int,
    dest_base: int,
) -> tuple[bytes, int]:
    """Mechanical translation of 100OPDMO.decompress_image.

    The OPDEMO handoff probe uses this as an instrumentation boundary. It
    preserves the proc's observable memory output while avoiding millions of
    Unicorn hooks in the string-heavy bit loop.
    """
    mem = bytearray(0x10000)
    for i, value in enumerate(src):
        mem[(source_base + i) & 0xFFFF] = value

    si = source_base
    di = dest_base
    ax = mem[si] | (mem[(si + 1) & 0xFFFF] << 8)
    si = (si + 2) & 0xFFFF
    cx = ax
    bp = si
    si = (si + cx) & 0xFFFF

    for _ in range(cx):
        al = 0
        for _bit in range(8):
            mem[bp], carry = rol8(mem[bp])
            if carry:
                mem[di] = mem[si]
                si = (si + 1) & 0xFFFF
            else:
                mem[di] = al
            di = (di + 1) & 0xFFFF
        bp = (bp + 1) & 0xFFFF

    count = (cx * 8) & 0xFFFF
    di = dest_base
    dh = 0
    for _ in range(count):
        value = mem[di]

        carry = 0
        al = 0
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        dh ^= al
        ah = dh

        carry = 0
        al = 0
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        dh ^= al
        ah = ((ah << 2) | dh) & 0xFF

        carry = 0
        al = 0
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        dh ^= al
        ah = ((ah << 2) | dh) & 0xFF

        carry = 0
        al = 0
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        value, carry = rcl8(value, carry)
        al, carry = adc_al_al(al, carry)
        dh ^= al
        ah = ((ah << 2) | dh) & 0xFF

        mem[di] = ah
        di = (di + 1) & 0xFFFF

    return bytes(mem[dest_base:dest_base + count]), count


def run_probe() -> dict:
    mu = Uc(UC_ARCH_X86, UC_MODE_16)
    for seg in (CODE_SEG, GAME_SEG, STACK_SEG):
        mu.mem_map(seg << 4, 0x10000, UC_PROT_ALL)

    base = CODE_SEG << 4
    game_base = GAME_SEG << 4
    mu.mem_write(base, bytes([0x90]) * 0x10000)
    mu.mem_write(game_base, bytes([0]) * 0x10000)
    data = OPDEMO_BIN.read_bytes()
    mu.mem_write(base + LOAD_BASE - HEADER_SIZE, bytes([0] * HEADER_SIZE))
    mu.mem_write(base + LOAD_BASE, data[HEADER_SIZE:])
    mu.mem_write(base + opdmo.OFF_GAME_SEG, word_bytes(GAME_SEG))
    install_slots(mu)

    # Direct dependencies before the HOU handoff. We want decompress_image to
    # run for real, but title decode and scanline animation are irrelevant here.
    for proc_name in ("decode_rle_to_es_di", "animate_scanline"):
        addr = LOAD_BASE + resolve_proc("opdmo", proc_name) - HEADER_SIZE
        mu.mem_write(base + addr, b"\xC3")

    state: dict = {
        "sar": [],
        "stop_regs": None,
        "instructions": 0,
        "last_ip": None,
        "stopped_reason": None,
        "_resume_ip": None,
        "decompress_entries": [],
        "initial_slots": {
            f"{slot:04X}": bytes(mu.mem_read(base + slot, 2)).hex()
            for slot in (
                opdmo.GFX_INIT_SLOT,
                opdmo.GFX_DRAW_SLOT,
                opdmo.GFX_UPDATE_SLOT,
                opdmo.GFX_PALETTE_SLOT,
                opdmo.DISP_GAME_SLOT,
                0x1E09,
            )
        },
    }

    def stop_after_simulated_ret(uc: Uc) -> None:
        sp = uc.reg_read(UC_X86_REG_SP) & 0xFFFF
        raw = uc.mem_read((STACK_SEG << 4) + sp, 2)
        ret_ip = raw[0] | (raw[1] << 8)
        uc.reg_write(UC_X86_REG_SP, (sp + 2) & 0xFFFF)
        state["_resume_ip"] = ret_ip
        uc.emu_stop()

    def hook_code(uc: Uc, _addr: int, _size: int, _user) -> None:
        ip = uc.reg_read(UC_X86_REG_IP) & 0xFFFF
        state["instructions"] += 1
        state["last_ip"] = ip
        if ip == RET_SENTINEL:
            state["stopped_reason"] = "returned_to_sentinel"
            uc.emu_stop()
            return

        if ip == DECOMPRESS_IMAGE_ENTRY:
            ds = uc.reg_read(UC_X86_REG_DS) & 0xFFFF
            es = uc.reg_read(UC_X86_REG_ES) & 0xFFFF
            si = uc.reg_read(UC_X86_REG_SI) & 0xFFFF
            di = uc.reg_read(UC_X86_REG_DI) & 0xFFFF
            src_word = uc.mem_read((ds << 4) + si, 2)
            source = bytes(uc.mem_read((ds << 4) + si, 0x10000 - si))
            decoded, decoded_size = img_decompress_image_masm_equivalent(
                source, si, di
            )
            uc.mem_write((es << 4) + di, decoded)
            uc.reg_write(UC_X86_REG_CX, 0)
            uc.reg_write(UC_X86_REG_DI, (di + decoded_size) & 0xFFFF)
            uc.reg_write(UC_X86_REG_SI, (si + 2 + (src_word[0] | (src_word[1] << 8))) & 0xFFFF)
            state["decompress_entries"].append({
                "si": si,
                "di": di,
                "ds": ds,
                "es": es,
                "src_word": src_word[0] | (src_word[1] << 8),
                "decoded_size": decoded_size,
            })
            stop_after_simulated_ret(uc)
            return

        if ip == RET_THUNK:
            stop_after_simulated_ret(uc)
            return

        if ip == SAR_THUNK:
            ds = uc.reg_read(UC_X86_REG_DS) & 0xFFFF
            es = uc.reg_read(UC_X86_REG_ES) & 0xFFFF
            si = uc.reg_read(UC_X86_REG_SI) & 0xFFFF
            di = uc.reg_read(UC_X86_REG_DI) & 0xFFFF
            ref = read_resource_ref(uc, ds, si)
            asset = asset_for_ref(ref)
            payload = fill_buffer_decompress((ASSET_ROOT / asset).read_bytes())
            uc.mem_write((es << 4) + di, payload[:0x10000 - di])
            state["sar"].append((asset, es, di, len(payload)))
            stop_after_simulated_ret(uc)
            return

        if ip == STOP_THUNK:
            state["stopped_reason"] = "reached_hou_disp_game_handoff"
            state["stop_regs"] = {
                "ax": uc.reg_read(UC_X86_REG_AX) & 0xFFFF,
                "bx": uc.reg_read(UC_X86_REG_BX) & 0xFFFF,
                "cx": uc.reg_read(UC_X86_REG_CX) & 0xFFFF,
                "di": uc.reg_read(UC_X86_REG_DI) & 0xFFFF,
                "es": uc.reg_read(UC_X86_REG_ES) & 0xFFFF,
            }
            uc.emu_stop()

    mu.hook_add(UC_HOOK_CODE, hook_code)

    mu.reg_write(UC_X86_REG_CS, CODE_SEG)
    mu.reg_write(UC_X86_REG_DS, CODE_SEG)
    mu.reg_write(UC_X86_REG_ES, CODE_SEG)
    mu.reg_write(UC_X86_REG_SS, STACK_SEG)
    for reg in (
        UC_X86_REG_EAX,
        UC_X86_REG_EBX,
        UC_X86_REG_ECX,
        UC_X86_REG_EDX,
        UC_X86_REG_ESI,
        UC_X86_REG_EDI,
        UC_X86_REG_EBP,
        UC_X86_REG_ESP,
    ):
        mu.reg_write(reg, 0)
    mu.reg_write(UC_X86_REG_SP, 0xFFFC)
    mu.reg_write(UC_X86_REG_SI, 0)
    mu.reg_write(UC_X86_REG_BX, 6)
    mu.mem_write((STACK_SEG << 4) + 0xFFFC, word_bytes(RET_SENTINEL))

    next_ip = LOAD_BASE
    max_steps = 10000000
    try:
        while True:
            state["_resume_ip"] = None
            budget_left = max_steps - state["instructions"]
            if budget_left <= 0:
                state["stopped_reason"] = f"max_steps_exhausted ({max_steps})"
                break
            mu.emu_start(base + next_ip, 0, count=budget_left)
            if state.get("_resume_ip") is not None:
                next_ip = state["_resume_ip"]
                continue
            if state["stopped_reason"] is None:
                state["stopped_reason"] = f"max_steps_exhausted ({max_steps})"
            break
    except Exception as exc:
        state["stopped_reason"] = f"exception: {exc}"

    segment = bytes(mu.mem_read(game_base, 0x10000))
    return {"state": state, "segment": segment}


def count_nonzero(data: bytes) -> int:
    return sum(1 for value in data if value)


def main() -> int:
    result = run_probe()
    state = result["state"]
    segment = result["segment"]
    regs = state["stop_regs"]
    failures: list[str] = []

    if regs is None:
        failures.append("did not reach HOU disp_game handoff")
    else:
        actual_regs = (regs["bx"], regs["cx"], regs["di"], regs["es"])
        if actual_regs != EXPECTED["disp_regs"]:
            failures.append(f"disp regs {actual_regs!r} != {EXPECTED['disp_regs']!r}")

    ranges = {
        "mem_4000": segment[0x4000:0x4000 + 44 * 104 * 2],
        "mem_75a0": segment[0x75A0:0x75A0 + 16 * 64 * 2],
        "mem_9000": segment[0x9000:0x9000 + 16 * 64 * 2],
        "mem_97c0": segment[0x97C0:0x97C0 + 34 * 112 * 2],
    }
    for name, data in ranges.items():
        digest = fnv1a64(data)
        nonzero = count_nonzero(data)
        if digest != EXPECTED[f"{name}_fnv"]:
            failures.append(f"{name} fnv {digest} != {EXPECTED[f'{name}_fnv']}")
        if nonzero != EXPECTED[f"{name}_nonzero"]:
            failures.append(f"{name} nonzero {nonzero} != {EXPECTED[f'{name}_nonzero']}")
        print(f"opdemo_nec_hou_handoff_{name}: fnv={digest} nonzero={nonzero}")

    print(f"opdemo_nec_hou_handoff_sar: {state['sar']}")
    print(f"opdemo_nec_hou_handoff_initial_slots: {state['initial_slots']}")
    print(f"opdemo_nec_hou_handoff_decompress_entries: {state['decompress_entries']}")
    print(
        "opdemo_nec_hou_handoff_exec: "
        f"instructions={state['instructions']} last_ip={state['last_ip']:04X} "
        f"reason={state['stopped_reason']}"
    )
    if regs:
        print(
            "opdemo_nec_hou_handoff_regs: "
            f"ax={regs['ax']:04X} bx={regs['bx']:04X} cx={regs['cx']:04X} "
            f"di={regs['di']:04X} es={regs['es']:04X}"
        )

    if failures:
        print("VERDICT: FAIL: " + "; ".join(failures))
        return 1
    print("VERDICT: PASS: OPDEMO NEC/HOU handoff memory matches MASM bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
