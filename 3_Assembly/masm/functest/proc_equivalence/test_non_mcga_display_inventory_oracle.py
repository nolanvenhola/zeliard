#!/usr/bin/env python3
"""Static release oracle for the original non-MCGA display drivers.

The web renderer consumes a canonical logical frame, but graphics_mode still
uses the original loader's numeric contract.  This oracle prevents that
presentation layer from drifting away from the exact EGA/CGA/HGC/Tandy driver
set whose procedures were inventoried from the release build.
"""

from __future__ import annotations

import csv
import hashlib
from pathlib import Path


HERE = Path(__file__).resolve().parent
MASM_ROOT = HERE.parents[1]

EXPECTED_COUNTS = {
    "gmega": 16,
    "gmcga": 19,
    "gmhgc": 22,
    "gmtga": 20,
    "101GDEGA": 23,
    "102GDCGA": 19,
    "103GDHGC": 22,
    "104GDTGA": 22,
    "107GTEGA": 26,
    "108GTCGA": 27,
    "109GTHGC": 34,
    "110GTTGA": 30,
    "202GFEGA": 39,
    "203GFCGA": 42,
    "204GFHGC": 46,
    "205GFTGA": 47,
}

EXPECTED_SHA256 = {
    "bin/gmega.bin": "631d531060464c2e7d8139d63f11628715de6ba8d5ad49e07dad96db4c7cce0b",
    "bin/gmcga.bin": "53d0b58ab3dfc965fa4355008a66ed0d6a6bce4cd45a3dedbcaea2d54b67e415",
    "bin/gmhgc.bin": "f082f2b555e760d142c7fcfaa97a57e7767a8327ab41450b548e556292f36d10",
    "bin/gmtga.bin": "45a36ea9f904a74ebc8a18954cf6e11c1100cfb61a7a70715ae8d13b3ebbea14",
    "bin/zelres1/101GDEGA.bin": "178858b48a3cc02002e3f54b4ded22607fcd176c22a9d1ee8bfa8aea403eef5e",
    "bin/zelres1/102GDCGA.bin": "5f15f3c5ccf7c25ee6b1d6d736ec690b0311ab88c4ee384cf81a2b925f4075e3",
    "bin/zelres1/103GDHGC.bin": "64aba8498d5ae4123af8ec20bd01dfa413b9ec7664a783d1674716ad67dc02e6",
    "bin/zelres1/104GDTGA.bin": "e1df69174cebf2fe7d61ebf35447b3f251fe7ac790ad60613fd5999ef7ba7f87",
    "bin/zelres1/107GTEGA.bin": "94ee7f8145aa7c5ed63e81730ee15b7534e03b94e0af96c80e9e18179f67f2cc",
    "bin/zelres1/108GTCGA.bin": "f66a392090f4b20a9316596efe7a0eebced1e0ab9406ce95f406fbd9c07d4a31",
    "bin/zelres1/109GTHGC.bin": "ddbe2748bbb27d68c6b38a5c9f95b6e38980125f55c462d54a7f8b2194e74f39",
    "bin/zelres1/110GTTGA.bin": "fa34875701550ea538d8d62789f367ed8423c110eae32f9f273c4260c24b8ca2",
    "bin/zelres2/202GFEGA.bin": "e21f0d27d45f3772f81b9f6e75a578e82a49d89a70b314ff697bd9ecf75d71c9",
    "bin/zelres2/203GFCGA.bin": "5b2211763ca0d179b23ca5f50d47794c235319ad86b06da1efc7bf6efbe4505d",
    "bin/zelres2/204GFHGC.bin": "44f995c8d7e1f0c97d0f813bef36adece27245b77fa3e800e062a1cf44ba7943",
    "bin/zelres2/205GFTGA.bin": "721f171c942ab35eacff7a0d8bd33e2b5529915bb7914079e321b4daf3130d81",
}

OVERLAY_CHUNKS = {name for name in EXPECTED_COUNTS if name[0].isdigit()}


def main() -> int:
    failures: list[str] = []
    by_chunk: dict[str, list[dict[str, str]]] = {}
    with (MASM_ROOT / "functest" / "coverage.csv").open(
            newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            if row["chunk"] in EXPECTED_COUNTS:
                by_chunk.setdefault(row["chunk"], []).append(row)

    for chunk, expected in EXPECTED_COUNTS.items():
        rows = by_chunk.get(chunk, [])
        if len(rows) != expected:
            failures.append(f"{chunk}: expected {expected} procedures, got {len(rows)}")
        locations: set[int] = set()
        for row in rows:
            try:
                entry = int(row["entry_addr"], 0)
                size = int(row["size_bytes"], 0)
            except ValueError:
                failures.append(f"{chunk}/{row['name']}: invalid entry or size")
                continue
            if size <= 0:
                failures.append(f"{chunk}/{row['name']}: non-positive size")
            if entry in locations:
                failures.append(f"{chunk}: duplicate entry {entry:#06x}")
            locations.add(entry)

    overlay_total = sum(len(by_chunk.get(chunk, [])) for chunk in OVERLAY_CHUNKS)
    if overlay_total != 377:
        failures.append(f"non-MCGA overlay total: expected 377, got {overlay_total}")

    for relative, expected in EXPECTED_SHA256.items():
        path = MASM_ROOT / relative
        if not path.is_file():
            failures.append(f"missing release driver: {relative}")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected:
            failures.append(f"{relative}: SHA-256 {actual}, expected {expected}")

    print(f"non-MCGA overlays: {overlay_total}/377 procedures")
    print(f"base drivers: {sum(len(by_chunk.get(c, [])) for c in EXPECTED_COUNTS if c[0].isalpha())} procedures")
    print(f"release binaries: {len(EXPECTED_SHA256)} pinned")
    if failures:
        for failure in failures:
            print(f"FAIL: {failure}")
        print("VERDICT: FAIL")
        return 1
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
