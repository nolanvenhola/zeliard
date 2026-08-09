#!/usr/bin/env python3
"""Release-byte oracle for stick.asm's F7 restore-game control flow."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402


def main() -> int:
    stick = (MASM_ROOT / "working" / "drivers" / "stick.bin").read_bytes()
    town = (MASM_ROOT / "working" / "zelres1" / "code" /
            "106TOWN.asm").read_text(encoding="latin-1")
    fight = (MASM_ROOT / "working" / "zelres2" / "code" /
             "200FIGHT.asm").read_text(encoding="latin-1")

    # process_scancode: F7 make/break is scan code 41h and timer mask 4000h.
    f7_dispatch = bytes.fromhex("B9 00 40 3C 41")
    # restore handler: exact timer equality, clear carry, branch to prompt.
    restore_edge = bytes.fromhex("2E 81 3E 18 FF 00 40 F8 74 01 C3")
    # Prompt waits for Y/N masks 20h/40h, tests Y, and preserves that result
    # while restoring the saved background and clearing action bytes.
    answer_flow = bytes.fromhex(
        "2E A1 18 FF A9 60 00 74 F7 A9 20 00 9C E8 5A 00 "
        "2E C6 06 17 FF 00 2E C6 06 1D FF 00 2E C6 06 1E FF 00"
    )
    prompt = b"Restore Game\r Sure?(Y/N)\xff"

    checks = {
        "f7_scan_41_mask_4000": stick.count(f7_dispatch) == 1,
        "restore_exact_edge": stick.count(restore_edge) == 1,
        "yn_answer_flow": stick.count(answer_flow) == 1,
        "release_prompt": stick.count(prompt) == 1,
        "town_dispatch": town.count(
            "call\tword ptr cs:[stick_restore_dlg_handler]") == 2,
        "town_load_on_carry": town.count("call\tenter_savegame_dialog") == 2,
        "fight_dispatch": fight.count(
            "call\tword ptr cs:[stick_restore_dlg_handler]") == 1,
        "fight_load_on_carry": "call\tenter_level_via_ref_a" in fight,
    }
    ok = all(checks.values())
    print("stick_f7_restore: " + ("PASS" if ok else "FAIL") + " " +
          " ".join(f"{name}={int(value)}" for name, value in checks.items()))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM F7 restore-game flow")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
