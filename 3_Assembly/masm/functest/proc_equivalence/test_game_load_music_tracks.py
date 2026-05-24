#!/usr/bin/env python3
"""MASM oracle for game.asm load_music_tracks."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from harness import CODE_SEG, TasmHarness  # noqa: E402


MASM_ROOT = HERE.parents[1]
GAME_BIN = MASM_ROOT / "bin" / "game.bin"

LOAD_BASE = 0xA000
LOAD_MUSIC_TRACKS = 0xA3A5
OFF_MUSIC_TRACK_COUNT = 0x00A0
SOUND_LOAD_TRACK_FN = 0x203E
SOUND_THUNK = 0x0200

TRACK_REFS = [
    0x0F00,
    0x3D00,
    0x1500,
    0x3700,
    0x1B00,
    0x3100,
    0x2100,
    0x2B00,
    0x2600,
]


def write_code_word(h: TasmHarness, offset: int, value: int) -> None:
    h.write_code(offset, [value & 0xFF, (value >> 8) & 0xFF])


def run_case(count: int) -> list[tuple[int, int, int]]:
    h = TasmHarness(GAME_BIN, LOAD_BASE)
    h.write_code(OFF_MUSIC_TRACK_COUNT, [count & 0xFF])
    write_code_word(h, SOUND_LOAD_TRACK_FN, SOUND_THUNK)
    result = h.call_function(
        LOAD_MUSIC_TRACKS,
        regs={"ds": CODE_SEG, "ax": 0x9900},
        stub_calls={SOUND_THUNK: {}},
    )
    if result["stopped_reason"] != "returned_to_sentinel":
        raise AssertionError(result["stopped_reason"])
    return [
        (regs["dx"], regs["bx"], regs["ax"] & 0x00FF)
        for regs in result["stub_regs"]
    ]


def expect_eq(failures: list[str], label: str, got, want) -> None:
    if got != want:
        failures.append(f"{label}: got={got!r} want={want!r}")


def main() -> int:
    failures: list[str] = []

    expect_eq(failures, "zero_count", run_case(0), [])

    first_three = [(idx, TRACK_REFS[idx], 0) for idx in range(3)]
    expect_eq(failures, "first_three_tracks", run_case(3), first_three)

    all_tracks = [(idx, TRACK_REFS[idx], 1 if idx == 8 else 0)
                  for idx in range(9)]
    expect_eq(failures, "all_tracks_with_bg_flag", run_case(9), all_tracks)

    if failures:
        print("game load_music_tracks oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("game load_music_tracks oracle: count gate, track refs, and background flag match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
