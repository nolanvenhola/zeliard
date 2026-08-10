#!/usr/bin/env python3
"""Release-byte oracle for the complete 250ENDMO live-path contract."""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

ENDMO_SHA = "83f34e5b9adb321a1717019ed24fecadb619c53d515a53b25f8f7d79472b9350"
PROCS = (
    "run_ending_scene_main", "timer_wait_loop", "gfx_driver_tick_full",
    "render_narration_page", "measure_script_word_width",
    "run_credits_loop_main", "put_credits_char", "credits_wait_tick",
    "credits_driver_tick", "rle_blit_pair", "rle_decode_plane",
    "fill_credits_triplane",
)
ASSETS = {
    "waku.grp": (0, 0x21), "sei.grp": (0, 0x1C),
    "yuup.grp": (0, 0x26), "seip.grp": (0, 0x1D),
    "himp.grp": (0, 0x11), "new1.grp": (0, 0x18),
    "new2.grp": (0, 0x19), "ne80.grp": (0, 0x15),
    "ne81.grp": (0, 0x16), "end5.grp": (1, 0x36),
    "end4.grp": (1, 0x35), "end6.grp": (1, 0x37),
    "end7.grp": (1, 0x38), "en72.grp": (1, 0x34),
    "final.grp": (1, 0x39), "zend.msd": (0, 0x27),
}


def main() -> int:
    repo = MASM_ROOT.parents[1]
    endmo_path = MASM_ROOT / "bin" / "zelres2" / "250ENDMO.bin"
    image = endmo_path.read_bytes()
    payload = image[4:]
    source = (MASM_ROOT / "working" / "zelres2" / "code" /
              "250ENDMO.asm").read_text(encoding="utf-8")
    vm = (repo / "6_WebPort" / "engine" / "game" /
          "fight_masm_vm.c").read_text(encoding="utf-8")
    manifest = (repo / "6_WebPort" / "scripts" /
                "copy_assets.mjs").read_text(encoding="utf-8")

    exact_binary = hashlib.sha256(image).hexdigest() == ENDMO_SHA
    all_procs = all(f"{name}\t" in source or f"{name} " in source
                    for name in PROCS)
    refs = []
    mappings = []
    for name, (archive, chunk) in ASSETS.items():
        refs.append(bytes((archive, chunk)) in payload)
        mappings.append(f'return "{name}"' in vm)
        mappings.append(f"'{name}'" in manifest)

    # Seven relocated credit handlers and the permanent final-screen tick
    # loop are exact bytes from the built release overlay.
    dispatch = payload[0x0820:0x082E]
    dispatch_ok = dispatch == bytes.fromhex(
        "2e685a689168b568c268cf683269")
    final_loop = bytes.fromhex("e88b02ebfb") in payload
    entry_ok = image[:2] == bytes.fromhex("eb21")
    narration_ok = all(text in payload for text in (
        b"Jashiin", b"Felicia", b"GAME ARTS",
    ))
    vm_contract = all(token in vm for token in (
        "ending_requested", '"gdmcga.bin"', '"endmo.bin"',
        "ending_poll_instruction", "ending_finished",
    ))

    ok = exact_binary and all_procs and all(refs) and all(mappings) and \
        dispatch_ok and final_loop and entry_ok and narration_ok and vm_contract
    print("endmo_release: " + ("PASS" if exact_binary and all_procs else "FAIL") +
          f" sha={hashlib.sha256(image).hexdigest()} procs={len(PROCS)}")
    print("endmo_resources: " + ("PASS" if all(refs) and all(mappings)
          else "FAIL") + f" refs={len(ASSETS)}")
    print("endmo_live_path: " + ("PASS" if dispatch_ok and final_loop and
          entry_ok and narration_ok and vm_contract else "FAIL"))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": exact 250ENDMO narration, credits, graphics, timing, and audio contract")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
