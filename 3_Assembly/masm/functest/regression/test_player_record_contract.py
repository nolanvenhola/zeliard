#!/usr/bin/env python3
"""Lock the C/WASM 256-byte player record to release MASM behavior."""

import hashlib
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FUNCTEST = HERE.parent
MASM_ROOT = FUNCTEST.parent
REPO_ROOT = MASM_ROOT.parent.parent
sys.path.insert(0, str(FUNCTEST))

from fixtures import BIN_PATHS, resolve_proc  # noqa: E402
from harness import TasmHarness  # noqa: E402

STDPLY_SHA256 = "c2312fb031230d2cab839ee9f62cca415fbcd414011d884a30a38b66aae44fb8"
GOLD_ADD_PATTERN = bytes.fromhex("0106860010168500c3")


def find_pattern_target(path: Path, pattern: bytes, load_base: int) -> int:
    offset = path.read_bytes().find(pattern)
    if offset < 0:
        raise RuntimeError(f"pattern not found in {path}: {pattern.hex()}")
    return load_base + offset


def full_record(seed: bytes) -> bytes:
    # zeliad loads the 233-byte stdply.bin into a zeroed game segment. The
    # save proxy nevertheless preserves the entire 256-byte image verbatim.
    return seed + bytes(0x100 - len(seed))


def run_proc(path: Path, load_base: int, address: int, record: bytes,
             regs: dict[str, int]):
    harness = TasmHarness(path, load_base)
    harness.write_data(0, record)
    return harness.call_function(address, regs=regs)


def main() -> int:
    failures: list[str] = []
    stdply_path = MASM_ROOT / "bin" / "stdply.bin"
    web_path = REPO_ROOT / "6_WebPort" / "engine" / "assets" / "stdply.bin"
    if not stdply_path.exists() or not web_path.exists():
        print("VERDICT: INCONCLUSIVE: stdply.bin missing from MASM or web assets")
        return 1

    stdply = stdply_path.read_bytes()
    web = web_path.read_bytes()
    digest = hashlib.sha256(stdply).hexdigest()
    checks = {
        "release_size_233": len(stdply) == 233,
        "release_sha256": digest == STDPLY_SHA256,
        "web_asset_exact": web == stdply,
        "initial_position": stdply[0x80:0x82] == bytes((0x1E, 0x00)),
        "initial_hp": stdply[0x90:0x92] == bytes((0x50, 0x00)),
        "initial_sword": stdply[0x92] == 1,
        "initial_save_sage": stdply[0xC4:0xC6] == bytes((0x80, 0x81)),
        "new_game_gap_zero": full_record(stdply)[0xE9:] == bytes(0x17),
    }
    for label, passed in checks.items():
        print(f"player_record:{label}: {'PASS' if passed else 'FAIL'}")
        if not passed:
            failures.append(label)

    record = bytearray(full_record(stdply))
    record[0xF4] = 0xA7

    fight_path, fight_base = BIN_PATHS["fight"]
    hp_result = run_proc(
        fight_path, fight_base,
        fight_base + resolve_proc("fight", "subtract_from_player_HP"),
        bytes(record), {"ax": 20})
    hp_expected = [(0x90, 0x50, 0x3C)]
    hp_pass = hp_result["mem_diffs"] == hp_expected
    print(f"player_record:masm_word_diff_allowlist: {'PASS' if hp_pass else 'FAIL'} "
          f"{hp_result['mem_diffs']}")
    if not hp_pass:
        failures.append("masm_word_diff_allowlist")

    town_path, town_base = BIN_PATHS["town"]
    gold_result = run_proc(
        town_path, town_base,
        find_pattern_target(town_path, GOLD_ADD_PATTERN, town_base),
        bytes(record), {"ax": 0x1234, "dx": 0x12})
    gold_expected = [
        (0x85, 0x00, 0x12),
        (0x86, 0x00, 0x34),
        (0x87, 0x00, 0x12),
    ]
    gold_pass = gold_result["mem_diffs"] == gold_expected
    print(f"player_record:masm_24bit_diff_allowlist: {'PASS' if gold_pass else 'FAIL'} "
          f"{gold_result['mem_diffs']}")
    if not gold_pass:
        failures.append("masm_24bit_diff_allowlist")

    # Both real procedures diff the whole DS image; the opaque save tail must
    # remain untouched, not merely be absent from a field-specific assertion.
    tail_pass = all(offset != 0xF4
                    for offset, _, _ in hp_result["mem_diffs"] +
                    gold_result["mem_diffs"])
    print(f"player_record:opaque_tail_preserved: {'PASS' if tail_pass else 'FAIL'}")
    if not tail_pass:
        failures.append("opaque_tail_preserved")

    if failures:
        print(f"VERDICT: FAIL: player-record contract failures: {failures}")
        return 1
    print("VERDICT: PASS: release MASM and C/WASM share the exact player-record contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
