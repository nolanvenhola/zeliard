#!/usr/bin/env python3
"""Release-byte oracle for event-posted 200FIGHT damage sound cues."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
from fixtures import BIN_PATHS, MASM_ROOT  # noqa: E402

BUILT_BIN, _LOAD_BASE = BIN_PATHS["fight"]
WORKING_BIN = MASM_ROOT / "working" / "zelres2" / "code" / "200FIGHT.bin"
BIN = BUILT_BIN if BUILT_BIN.exists() else WORKING_BIN

# mov byte ptr ds:[FF75h], imm8
EXPECTED_COUNTS = {0x08: 1, 0x09: 4, 0x16: 1}


def main() -> int:
    image = BIN.read_bytes()
    assert image[:4] == b"\x2e\x3f\x00\x00"
    payload = image[4:]
    patterns = {
        cue: bytes((0xC6, 0x06, 0x75, 0xFF, cue))
        for cue in EXPECTED_COUNTS
    }
    counts = {cue: payload.count(pattern) for cue, pattern in patterns.items()}
    # These are discrete stores executed by damage paths. There is no MASM
    # loop that services a held FF75 value; repeated pit sound requires the
    # tile-damage path to execute the store again on a later combat scan.
    instruction_sites = {
        cue: [0x6000 + at for at in range(len(payload) - 4)
              if payload[at:at + 5] == pattern]
        for cue, pattern in patterns.items()
    }
    ok = counts == EXPECTED_COUNTS
    print("fight_damage_sound: " + ("PASS" if ok else "FAIL") + " " +
          " ".join(f"cue_{cue:02x}={count}@" +
                   ",".join(f"{site:04x}" for site in instruction_sites[cue])
                   for cue, count in counts.items()))
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": release-MASM damage sounds are discrete writes per damage event")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
