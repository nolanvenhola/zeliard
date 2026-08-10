#!/usr/bin/env python3
"""Regression guard for release data that must not enter procedure coverage."""

from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

MASM_ROOT = Path(__file__).resolve().parents[2]
CLASSIFY_PATH = MASM_ROOT / "functest" / "classify.py"
spec = importlib.util.spec_from_file_location("masm_classify", CLASSIFY_PATH)
assert spec and spec.loader
classify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(classify)


def main() -> int:
    stdply_source = MASM_ROOT / "working" / "drivers" / "stdply.asm"
    mole_source = MASM_ROOT / "working" / "zelres2" / "code" / "207MOLE.asm"
    stdply_bin = MASM_ROOT / "bin" / "stdply.bin"
    if not stdply_bin.exists():
        stdply_bin = MASM_ROOT.parents[1] / "1_OriginalGame" / "stdply.bin"

    stdply_procs = classify.parse_asm_features(stdply_source)
    mole_procs = classify.parse_asm_features(mole_source)
    payload = stdply_bin.read_bytes()
    digest = hashlib.sha256(payload).hexdigest()

    ok = classify.DATA_ONLY_MODULES == {"stdply"}
    ok &= set(stdply_procs) == {"run_stdply_main"}  # linker-only envelope
    ok &= "write_dma_port_then_pad" not in mole_procs
    ok &= len(payload) == 233
    ok &= digest == "c2312fb031230d2cab839ee9f62cca415fbcd414011d884a30a38b66aae44fb8"
    ok &= payload[:0x80] == bytes(0x80)
    ok &= payload[0x80:0x85] == b"\x1e\x00\x00\x0a\x0a"
    ok &= payload[0x90:0x94] == b"\x50\x00\x01\x00"

    print("data_only_boundaries: " + ("PASS" if ok else "FAIL") +
          f" stdply_procs={len(stdply_procs)} bytes={len(payload)} sha256={digest}")
    print("VERDICT: " + ("PASS" if ok else "FAIL") +
          ": stdply and MOLE sprite data are excluded from procedure coverage")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
