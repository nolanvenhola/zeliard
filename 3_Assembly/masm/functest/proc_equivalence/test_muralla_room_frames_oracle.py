#!/usr/bin/env python3
"""Release-MASM first stable-frame oracles for Muralla buildings."""

import sys
from pathlib import Path

from unicorn import UC_HOOK_CODE, UcError
from unicorn.x86_const import (
    UC_X86_REG_AX, UC_X86_REG_CS, UC_X86_REG_DS, UC_X86_REG_ES,
    UC_X86_REG_IP, UC_X86_REG_SP, UC_X86_REG_SS,
)

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from test_felishika_room_frames_oracle import (  # noqa: E402
    GAME_SEG, MASM_ROOT, VGA_SEG, build_machine, fnv1a64, frame_rect,
    run_until_boundary,
)


CASES = (
    {
        "name": "armor",
        "program": "212ARMRP.bin",
        "graphic": "220ARMRG.grp",
        "descriptor_shop_id": 1,
        "boundary_pattern": bytes.fromhex("c7064cffd3ad"),
        "frame": 0x12FD1F3947E28290,
        "artwork": 0xDDF10D6134E5DA7C,
        "menu_frame": 0xF3074246AE808D8C,
    },
    {
        "name": "bank",
        "program": "213BANKP.bin",
        "graphic": "221BANKG.grp",
        "descriptor_shop_id": 1,
        "boundary_pattern": bytes.fromhex("c7064cff89a9"),
        "frame": 0x41FC80F26CEF61FB,
        "artwork": 0x0E059B43834625FF,
        "menu_frame": 0xC2530EBABD5407A1,
        "wait_pattern": bytes.fromhex("803e1aff3c72f9"),
    },
    {
        "name": "church",
        "program": "214CHURP.bin",
        "graphic": "222CHRCH.grp",
        "descriptor_shop_id": 1,
        "boundary_pattern": bytes.fromhex("89364cff"),
        "frame": 0xBCD1421EFFE2E1B8,
        "artwork": 0x63FD6BC71C824C5C,
    },
    {
        "name": "drugstore",
        "program": "215DRUGP.bin",
        "graphic": "223DRUGG.grp",
        "descriptor_shop_id": 1,
        "boundary_pattern": bytes.fromhex("c7064cff6ba8"),
        "frame": 0xDD94A39161EEBD55,
        "artwork": 0xB72FA5E69F6FA18D,
        "menu_frame": 0xEE7EECCE440BF677,
        "wait_pattern": bytes.fromhex("803e1aff5072f9"),
    },
)


def run_to_main_menu(machine, case) -> bytes:
    """Run a release shop program through the first menu cursor draw.

    The town frame tick is a browser/DOS host boundary in this harness. The
    direct FF1A loops are released after their body has run; all drawing,
    script dispatch, and menu construction remain release-MASM execution.
    """
    base = GAME_SEG << 4
    # The DOS PIT normally advances FF1A asynchronously while this routine
    # calls the installed input/audio dispatchers. Supply that observable
    # timer side effect and return from the host-service boundary.
    machine.mem_write(base + 0x7042, b"\xfe\x06\x1a\xff\xc3")
    image = bytes(machine.mem_read(base + 0xA000, 0x1C00))
    released_waits = 0
    for at in range(len(image) - 7):
        if image[at:at + 4] == b"\x80\x3e\x1a\xff" and \
                image[at + 5] == 0x72:
            machine.mem_write(base + 0xA000 + at + 5, b"\x90\x90")
            released_waits += 1
    if case.get("wait_pattern") and not released_waits:
        raise RuntimeError(f"{case['name']} timer waits missing")

    for register, value in (
        (UC_X86_REG_CS, GAME_SEG), (UC_X86_REG_DS, GAME_SEG),
        (UC_X86_REG_ES, 0x2000), (UC_X86_REG_SS, 0x8000),
        (UC_X86_REG_SP, 0xFFFC), (UC_X86_REG_AX, 1),
    ):
        machine.reg_write(register, value)

    reached = False
    last = [0, 0]

    def stop(uc, address, size, _user):
        nonlocal reached
        last[:] = address, size
        if uc.reg_read(UC_X86_REG_CS) == GAME_SEG and \
                uc.reg_read(UC_X86_REG_IP) == 0x735D:
            reached = True
            uc.emu_stop()

    hook = machine.hook_add(UC_HOOK_CODE, stop)
    try:
        machine.emu_start(base + 0xA000, 0, count=30_000_000)
    except UcError as error:
        code = bytes(machine.mem_read(last[0], 8)).hex()
        raise RuntimeError(
            f"menu execution failed at {last[0]:05x} ({code}): {error}") \
            from error
    machine.hook_del(hook)
    if not reached:
        raise RuntimeError(
            f"{case['name']} did not reach the post-cursor input check")
    return bytes(machine.mem_read(VGA_SEG << 4, 0x10000))


def main() -> int:
    passed = True
    for case in CASES:
        program = MASM_ROOT / "bin" / "zelres2" / case["program"]
        graphic = MASM_ROOT / "bin" / "zelres2" / case["graphic"]
        if not program.exists() or not graphic.exists():
            print(f"VERDICT: INCONCLUSIVE: missing Muralla {case['name']} assets")
            return 0

        payload = program.read_bytes()[4:]
        pattern_at = payload.find(case["boundary_pattern"])
        if pattern_at < 0:
            print(f"muralla_{case['name']}_room: FAIL boundary pattern missing")
            passed = False
            continue

        boundary = 0xA000 + pattern_at + len(case["boundary_pattern"])
        machine = build_machine(program, graphic)
        base = GAME_SEG << 4
        machine.mem_write(
            base + 0xC006, bytes((case["descriptor_shop_id"],)))
        run_until_boundary(machine, 0xA000, boundary)
        frame = bytes(machine.mem_read(VGA_SEG << 4, 0x10000))
        artwork = frame_rect(frame, 56, 23, 208, 128)
        frame_hash = fnv1a64(frame)
        artwork_hash = fnv1a64(artwork)
        case_passed = frame_hash == case["frame"] and \
            artwork_hash == case["artwork"]
        passed &= case_passed
        print(f"muralla_{case['name']}_room: "
              f"{'PASS' if case_passed else 'FAIL'} "
              f"boundary={boundary:04x} frame={frame_hash:016x} "
              f"artwork={artwork_hash:016x}")

        if "menu_frame" in case:
            menu_machine = build_machine(program, graphic)
            menu_machine.mem_write(
                base + 0xC006, bytes((case["descriptor_shop_id"],)))
            menu_frame = run_to_main_menu(menu_machine, case)
            menu_hash = fnv1a64(menu_frame)
            menu_passed = menu_hash == case["menu_frame"]
            passed &= menu_passed
            print(f"muralla_{case['name']}_main_menu: "
                  f"{'PASS' if menu_passed else 'FAIL'} "
                  f"frame={menu_hash:016x}")

    print(f"VERDICT: {'PASS' if passed else 'FAIL'}: "
          "release-MASM Muralla room and main-menu frames")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
