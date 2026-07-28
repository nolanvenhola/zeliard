#!/usr/bin/env python3
"""Require every captured-video anchor to have MASM and native C evidence."""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CONTRACT_PATH = ROOT / "6_WebPort/tests/opening_video_anchor_contracts.json"
ANCHOR_SOURCES = (
    "6_WebPort/tests/opening_video_anchors.json",
    "6_WebPort/tests/masm_capture_video_anchors.json",
)


def load_json(relative_path: str) -> dict:
    return json.loads((ROOT / relative_path).read_text(encoding="utf-8"))


def check_needles(relative_path: str, needles: list[str], errors: list[str],
                  contract_name: str, evidence_kind: str) -> None:
    path = ROOT / relative_path
    if not path.is_file():
        errors.append(f"{contract_name}: missing {evidence_kind} file {relative_path}")
        return
    text = path.read_text(encoding="cp1252")
    for needle in needles:
        if needle not in text:
            errors.append(
                f"{contract_name}: {evidence_kind} needle {needle!r} "
                f"not found in {relative_path}"
            )


def main() -> int:
    document = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    contracts = document.get("contracts", [])
    errors: list[str] = []

    if document.get("authority") != "MASM release source and executable behavior oracles":
        errors.append("contract authority must remain MASM release source and executable behavior oracles")

    contract_source_paths = {contract.get("anchor_source", "") for contract in contracts}
    if "" in contract_source_paths:
        errors.append("one or more contracts omit anchor_source")
        contract_source_paths.remove("")
    unknown_sources = sorted(contract_source_paths - set(ANCHOR_SOURCES))
    for source_path in unknown_sources:
        errors.append(f"contract names unknown anchor source {source_path}")

    expected: dict[tuple[str, str], dict] = {}
    for source_path in ANCHOR_SOURCES:
        source = load_json(source_path)
        for anchor in source.get("anchors", []):
            key = (source_path, anchor["id"])
            if key in expected:
                errors.append(f"duplicate source anchor {source_path}#{anchor['id']}")
            expected[key] = anchor

    counts = Counter(
        (contract.get("anchor_source", ""), contract.get("anchor_id", ""))
        for contract in contracts
    )
    for key, count in sorted(counts.items()):
        if count != 1:
            errors.append(f"{key[0]}#{key[1]} has {count} contracts; expected exactly one")

    actual_keys = set(counts)
    expected_keys = set(expected)
    for source_path, anchor_id in sorted(expected_keys - actual_keys):
        errors.append(f"missing contract for {source_path}#{anchor_id}")
    for source_path, anchor_id in sorted(actual_keys - expected_keys):
        errors.append(f"stale contract for {source_path}#{anchor_id}")

    for contract in contracts:
        key = (contract.get("anchor_source", ""), contract.get("anchor_id", ""))
        name = f"{key[0]}#{key[1]}"
        anchor = expected.get(key)
        if anchor is None:
            continue
        if contract.get("phase") != anchor.get("phase"):
            errors.append(
                f"{name}: phase {contract.get('phase')} != source {anchor.get('phase')}"
            )
        if contract.get("phase_id") != anchor.get("phase_id"):
            errors.append(
                f"{name}: phase_id {contract.get('phase_id')!r} "
                f"!= source {anchor.get('phase_id')!r}"
            )
        if contract.get("status") != "live_parity":
            errors.append(f"{name}: status must be live_parity")

        masm = contract.get("masm", {})
        c_test = contract.get("c", {})
        check_needles(
            masm.get("source_file", ""),
            masm.get("source_needles", []),
            errors,
            name,
            "MASM source",
        )
        check_needles(
            masm.get("oracle_file", ""),
            masm.get("oracle_needles", []),
            errors,
            name,
            "MASM oracle",
        )
        check_needles(
            c_test.get("test_file", ""),
            c_test.get("test_needles", []),
            errors,
            name,
            "native C test",
        )
        if not masm.get("source_needles"):
            errors.append(f"{name}: no MASM source needles")
        if not masm.get("oracle_needles"):
            errors.append(f"{name}: no executable MASM oracle needles")
        if not c_test.get("test_needles"):
            errors.append(f"{name}: no native C checkpoint needles")

    for error in errors:
        print(f"ERROR: {error}")
    if errors:
        print(f"VERDICT: FAIL: {len(errors)} opening video anchor contract errors")
        return 1

    for source_path, anchor_id in sorted(expected):
        print(f"PASS: {source_path}#{anchor_id}")
    print(
        f"VERDICT: PASS: all {len(expected)} captured-video anchors have "
        "MASM oracle and native C checkpoints"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
