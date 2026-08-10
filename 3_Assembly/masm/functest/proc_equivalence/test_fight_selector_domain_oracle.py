#!/usr/bin/env python3
"""Audit the complete release-MASM fight area and sword selector domains."""

from __future__ import annotations

import re
import struct
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import MASM_ROOT  # noqa: E402

sys.path.insert(0, str(HERE))
from test_mcga_render_entries_oracle import fill_buffer_decompress  # noqa: E402

MAP_STEMS = (
    "10", "1d", "20", "21", "2d", "30", "31", "3d", "40", "41",
    "4d", "50", "51", "5d", "60", "61", "62", "6d", "70", "71",
    "72", "73", "7d", "80", "81", "82", "83", "84", "8d", "90",
    "a0",
)


def main() -> int:
    repo = MASM_ROOT.parents[1]
    web_assets = repo / "6_WebPort" / "engine" / "assets"
    vm_source = (repo / "6_WebPort" / "engine" / "game" /
                 "fight_masm_vm.c").read_text(encoding="utf-8")

    release_maps = sorted((MASM_ROOT / "bin" / "zelres3").glob("*MP*.mdt"))
    expected_release_names = [
        f"{320 + selector:03d}MP{stem.upper()}.mdt"
        for selector, stem in enumerate(MAP_STEMS)
    ]
    release_names = [path.name for path in release_maps]
    assets_match = release_names == expected_release_names

    identities = []
    for selector, (stem, release) in enumerate(zip(MAP_STEMS, release_maps)):
        web = web_assets / f"mp{stem}.mdt"
        same = web.exists() and release.read_bytes() == web.read_bytes()
        identities.append(same)
        expected_case = re.compile(
            rf'case 0x{selector:02X}: return "mp{stem}\.mdt";')
        identities.append(bool(expected_case.search(vm_source)))

    release_sword = MASM_ROOT / "bin" / "zelres2" / "226SWRDG.grp"
    web_sword = web_assets / "sword.grp"
    sword_identity = release_sword.read_bytes() == web_sword.read_bytes()
    decoded = fill_buffer_decompress(release_sword.read_bytes())
    sword_banks = struct.unpack_from("<3H", decoded)
    bank_shape = sword_banks == (0x0006, 0x06D1, 0x1043)
    selector_shape = (
        "0x1800, 0x1800, 0x1800, 0x1800, 0x1802, 0x1802, 0x1804"
        in vm_source
    )

    # GAME.BIN passes the saved selector directly to SAR function 4.  The
    # release sword resource contains three banks; selectors 0..6 map onto
    # them as 0/0/0/0, 1/1, 2.  The native domain test executes every one.
    game = (MASM_ROOT / "bin" / "game.bin").read_bytes()
    direct_sword_load = bytes.fromhex("8a269200b004") in game

    ok = assets_match and all(identities) and sword_identity and bank_shape \
        and selector_shape and direct_sword_load
    print("fight_area_selector_domain: " + ("PASS" if assets_match and
          all(identities) else "FAIL") + f" count={len(release_maps)}")
    print("fight_sword_selector_domain: " + ("PASS" if sword_identity and
          bank_shape and selector_shape and direct_sword_load else "FAIL") +
          f" banks={[hex(value) for value in sword_banks]}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM selector assets and Web VM domain agree")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
