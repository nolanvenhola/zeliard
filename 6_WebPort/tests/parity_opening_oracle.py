#!/usr/bin/env python3
"""Validate opening/title oracle scenarios against their manifest."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from opening_oracle import compute_manifest, scenario_by_name

HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "opening_oracle_manifest.json"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--print-manifest", action="store_true",
                    help="print the freshly computed manifest and exit")
    args = ap.parse_args()

    computed = compute_manifest()
    if args.print_manifest:
        print(json.dumps(computed, indent=2))
        return 0

    expected = json.loads(MANIFEST.read_text(encoding="utf8"))
    exp = scenario_by_name(expected)
    got = scenario_by_name(computed)
    failures: list[str] = []

    for name, exp_item in exp.items():
        got_item = got.get(name)
        if got_item is None:
            failures.append(f"{name}: missing computed scenario")
            continue
        for key, exp_value in exp_item.items():
            if key in {"source", "description"}:
                continue
            got_value = got_item.get(key)
            if got_value != exp_value:
                failures.append(
                    f"{name}.{key}: got {got_value!r}, expected {exp_value!r}"
                )
    for name in sorted(set(got) - set(exp)):
        failures.append(f"{name}: computed scenario is not in manifest")

    if failures:
        print("Opening oracle parity failures:")
        for item in failures:
            print(f"  {item}")
        print(f"VERDICT: FAIL: {len(failures)} manifest mismatch(es)")
        return 1

    print(f"Validated {len(exp)} opening/title oracle scenarios.")
    print("VERDICT: PASS: opening oracle manifest matches reference decoder")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
