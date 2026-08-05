#!/usr/bin/env python3
"""Release-byte oracle for the ROKA transition music boundary.

106TOWN scene transitions write four to shared byte FF24h, which MSCADLIB
uses as its fade interval.  200FIGHT's check_c3 then owns the 26-step
transition-cavern run without invoking INT 60h.  The next level_start
boundary stops the faded score with AX=1 and only then loads the destination
level's music chunk.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

BUILT_BIN, LOAD_BASE = BIN_PATHS["fight"]
WORKING_BIN = MASM_ROOT / "working" / "zelres2" / "code" / "200FIGHT.bin"
BIN = BUILT_BIN if BUILT_BIN.exists() else WORKING_BIN
TOWN_BUILT_BIN, TOWN_LOAD_BASE = BIN_PATHS["town"]
TOWN_WORKING_BIN = MASM_ROOT / "working" / "zelres1" / "code" / "106TOWN.bin"
TOWN_BIN = TOWN_BUILT_BIN if TOWN_BUILT_BIN.exists() else TOWN_WORKING_BIN

# Label addresses from the release-matching 200FIGHT listing.  These are
# intentionally direct release-byte anchors because check_c3/level_start are
# internal labels inside check_3tile_J_pattern rather than standalone procs.
CHECK_C3 = 0x7C72
CHECK_MAP_FLAG = 0x7CF8
LEVEL_START = 0x7D89


def image_bytes(start: int, end: int) -> bytes:
    image = BIN.read_bytes()
    assert image[:4] == b"\x2e\x3f\x00\x00"
    # The SAR header occupies offsets 6000h..6003h in the assembled image;
    # listing offsets therefore map directly from LOAD_BASE into the file.
    return image[start - LOAD_BASE:end - LOAD_BASE]


def main() -> int:
    run_bytes = image_bytes(CHECK_C3, CHECK_MAP_FLAG)
    level_bytes = image_bytes(LEVEL_START, LEVEL_START + 5)

    run_has_no_music_interrupt = b"\xcd\x60" not in run_bytes
    level_stops_music = level_bytes == b"\xb8\x01\x00\xcd\x60"
    town_image = TOWN_BIN.read_bytes()
    assert int.from_bytes(town_image[:4], "little") == len(town_image) - 4
    fade_interval_writes = town_image.count(b"\xc6\x06\x24\xff\x04")
    town_uses_interval_four = fade_interval_writes == 2
    ok = (run_has_no_music_interrupt and level_stops_music and
          town_uses_interval_four)

    print("fight_transition_music:run: "
          f"{'PASS' if run_has_no_music_interrupt else 'FAIL'} "
          f"bytes={len(run_bytes)} int60_calls={run_bytes.count(bytes((0xCD, 0x60)))}")
    print("fight_transition_music:level_start: "
          f"{'PASS' if level_stops_music else 'FAIL'} "
          f"prefix={level_bytes.hex()}")
    print("fight_transition_music:town_fade_interval: "
          f"{'PASS' if town_uses_interval_four else 'FAIL'} "
          f"ff24_interval_4_writes={fade_interval_writes}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM music continues through ROKA and switches on exit")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
