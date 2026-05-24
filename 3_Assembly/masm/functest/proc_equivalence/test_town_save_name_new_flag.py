#!/usr/bin/env python3
"""MASM oracle for 106TOWN save-name new-file helpers."""

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import BIN_PATHS  # noqa: E402
from harness import CODE_SEG, TasmHarness  # noqa: E402


CHUNK = "town"
OFF_SAVE_NAME_LEN = 0x7C5E
OFF_SAVE_NAME_MAXLEN = 0x7C5F
OFF_SAVE_NEW_FLAG = 0x7C64
OFF_SAVE_NAME_BUF = 0x7C67

CHECK_SAVE_NAME_IS_NEW = 0x77C7
CLEAR_SAVE_NAME_IF_NEW = 0x77E9


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def seed_name(h: TasmHarness, raw: bytes) -> None:
    if len(raw) != 8:
        raise ValueError("save name fixture must be exactly 8 bytes")
    h.write_code(OFF_SAVE_NAME_BUF, raw)


def check_save_name_cases() -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    failures: list[str] = []

    h = TasmHarness(flat_path, load_base)
    seed_name(h, b"Re-Start")
    h.write_code(OFF_SAVE_NEW_FLAG, [0x55])
    h.write_code(OFF_SAVE_NAME_LEN, [4])
    result = h.call_function(CHECK_SAVE_NAME_IS_NEW, max_steps=120)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"check_hyphen: {result['stopped_reason']}")
    if read_code(h, OFF_SAVE_NEW_FLAG, 1)[0] != 0xFF:
        failures.append("check_hyphen: save_new_flag != 0xff")
    if read_code(h, OFF_SAVE_NAME_LEN, 1)[0] != 0:
        failures.append("check_hyphen: save_name_len != 0")

    h = TasmHarness(flat_path, load_base)
    seed_name(h, b"ABCDEFGH")
    h.write_code(OFF_SAVE_NEW_FLAG, [0x55])
    h.write_code(OFF_SAVE_NAME_LEN, [4])
    result = h.call_function(CHECK_SAVE_NAME_IS_NEW, max_steps=120)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"check_plain: {result['stopped_reason']}")
    if read_code(h, OFF_SAVE_NEW_FLAG, 1)[0] != 0:
        failures.append("check_plain: save_new_flag != 0")
    if read_code(h, OFF_SAVE_NAME_LEN, 1)[0] != 4:
        failures.append("check_plain: save_name_len changed")

    return failures


def clear_save_name_cases() -> list[str]:
    flat_path, load_base = BIN_PATHS[CHUNK]
    failures: list[str] = []

    h = TasmHarness(flat_path, load_base)
    seed_name(h, b"ABCDEFGH")
    h.write_code(OFF_SAVE_NEW_FLAG, [0x00])
    h.write_code(OFF_SAVE_NAME_MAXLEN, [5])
    result = h.call_function(CLEAR_SAVE_NAME_IF_NEW, max_steps=120)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"clear_inactive: {result['stopped_reason']}")
    if read_code(h, OFF_SAVE_NAME_BUF, 8) != b"ABCDEFGH":
        failures.append("clear_inactive: save_name_buf changed")
    if read_code(h, OFF_SAVE_NAME_MAXLEN, 1)[0] != 5:
        failures.append("clear_inactive: save_name_maxlen changed")

    h = TasmHarness(flat_path, load_base)
    seed_name(h, b"ABCDEFGH")
    h.write_code(OFF_SAVE_NEW_FLAG, [0xFF])
    h.write_code(OFF_SAVE_NAME_MAXLEN, [5])
    result = h.call_function(CLEAR_SAVE_NAME_IF_NEW, max_steps=120)
    if result["stopped_reason"] != "returned_to_sentinel":
        failures.append(f"clear_active: {result['stopped_reason']}")
    if read_code(h, OFF_SAVE_NEW_FLAG, 1)[0] != 0:
        failures.append("clear_active: save_new_flag != 0")
    if read_code(h, OFF_SAVE_NAME_BUF, 8) != b"````````":
        failures.append("clear_active: save_name_buf not blanked")
    if read_code(h, OFF_SAVE_NAME_MAXLEN, 1)[0] != 0:
        failures.append("clear_active: save_name_maxlen != 0")

    return failures


def main() -> int:
    flat_path, _ = BIN_PATHS[CHUNK]
    if not flat_path.exists():
        print("VERDICT: INCONCLUSIVE: town chunk missing")
        return 1

    failures = check_save_name_cases() + clear_save_name_cases()
    if failures:
        print("town save-name new-flag oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("town save-name new-flag oracle: hyphen detection and blank-on-new match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
