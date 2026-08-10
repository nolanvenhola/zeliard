#!/usr/bin/env python3
"""Fail CI when functional-test indexes or coverage evidence drift."""

from __future__ import annotations

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]


def main() -> int:
    errors: list[str] = []
    index = (ROOT / "INDEX.md").read_text(encoding="utf-8")
    tests = {
        path.relative_to(ROOT).as_posix()
        for path in ROOT.glob("*/*.py")
        if path.name.startswith("test_")
    }
    links = set(re.findall(r"\]\(([^)]+\.py)\)", index))
    for missing in sorted(tests - links):
        errors.append(f"INDEX.md missing {missing}")
    for broken in sorted(links - tests):
        errors.append(f"INDEX.md broken link {broken}")

    with (ROOT / "coverage.csv").open(encoding="utf-8", newline="") as fp:
        rows = list(csv.DictReader(fp))
    valid = {
        "direct-procedure-oracle", "exact-release-byte-vm",
        "integration-only", "browser-smoke", "out-of-scope-non-mcga",
        "uncovered",
    }
    for row in rows:
        label = f"{row['chunk']}:{row['name']}"
        if row.get("evidence_tier") not in valid:
            errors.append(f"{label} invalid evidence tier")
        if row.get("browser_smoke") not in {"yes", "no"}:
            errors.append(f"{label} invalid browser-smoke marker")
        if row.get("evidence_tier") == "uncovered" and not row.get("gap_ticket"):
            errors.append(f"{label} uncovered without ticket")
        source = row.get("evidence_source", "")
        if source and not source.startswith("http"):
            candidate = REPO / source
            if not candidate.exists():
                errors.append(f"{label} broken evidence source {source}")

    opening = (REPO / "6_WebPort" / "OPENING_DEMO_VIDEO_ORACLE.md").read_text(
        encoding="utf-8")
    if "## Current accepted status" not in opening:
        errors.append("opening video oracle lacks current accepted status")
    if "## Immediate Fix Queue" in opening:
        errors.append("opening video oracle still exposes the historical fix queue")

    if errors:
        print("evidence_consistency: FAIL")
        print("\n".join(errors))
        return 1
    print(f"evidence_consistency: PASS tests={len(tests)} coverage={len(rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
