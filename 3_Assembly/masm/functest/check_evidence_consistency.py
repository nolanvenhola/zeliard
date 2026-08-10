#!/usr/bin/env python3
"""Fail CI when functional-test indexes or coverage evidence drift."""

from __future__ import annotations

import csv
import json
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
        "direct-procedure-oracle", "exact-release-byte-oracle",
        "release-byte-procedure-oracle",
        "release-byte-inventory",
        "exact-release-byte-vm",
        "integration-only", "browser-smoke", "out-of-scope-non-mcga",
        "out-of-scope-data-only",
        "uncovered",
    }
    seen: set[tuple[str, str]] = set()
    for row in rows:
        label = f"{row['chunk']}:{row['name']}"
        key = (row['chunk'], row['name'])
        if key in seen:
            errors.append(f"{label} appears more than once")
        seen.add(key)
        if row.get("evidence_tier") not in valid:
            errors.append(f"{label} invalid evidence tier")
        if row.get("browser_smoke") not in {"yes", "no"}:
            errors.append(f"{label} invalid browser-smoke marker")
        if row.get("evidence_tier") == "uncovered" and not row.get("gap_ticket"):
            errors.append(f"{label} uncovered without ticket")
        if row.get("evidence_tier") == "integration-only" and not row.get("gap_ticket"):
            errors.append(f"{label} integration-only without follow-up ticket")
        source = row.get("evidence_source", "")
        if source and not source.startswith("http"):
            candidate = REPO / source
            if not candidate.exists():
                errors.append(f"{label} broken evidence source {source}")
        if row.get("evidence_tier") == "exact-release-byte-oracle" and \
                not source.endswith("_oracle.py"):
            errors.append(f"{label} exact oracle does not name an oracle fixture")

    required_chunks = {
        "game", "zeliad", "gmcga", "gmega", "gmhgc", "gmmcga",
        "gmtga", "stick",
    }
    missing_chunks = required_chunks - {row["chunk"] for row in rows}
    for chunk in sorted(missing_chunks):
        errors.append(f"coverage missing canonical core/driver chunk {chunk}")

    manifest_path = ROOT / "procedure_oracle_evidence.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest_seen: set[tuple[str, str]] = set()
    for group in manifest.get("groups", []):
        source = group.get("source", "")
        if not source or not (REPO / source).exists():
            errors.append(f"procedure manifest broken source {source}")
        for name in group.get("procedures", []):
            key = (group.get("chunk", ""), name)
            if key in manifest_seen:
                errors.append(f"procedure manifest duplicates {key[0]}:{key[1]}")
            manifest_seen.add(key)
            if key not in seen:
                errors.append(f"procedure manifest has stale entry {key[0]}:{key[1]}")
    classified_manifest = {
        (row["chunk"], row["name"])
        for row in rows
        if row.get("evidence_tier") == "release-byte-procedure-oracle"
    }
    for key in sorted(manifest_seen ^ classified_manifest):
        errors.append(f"procedure manifest/classifier drift {key[0]}:{key[1]}")
    for chunk in ("100OPDMO", "105GDMCA", "106TOWN", "111GTMCA"):
        leftovers = [
            row["name"] for row in rows
            if row["chunk"] == chunk and row["evidence_tier"] == "integration-only"
        ]
        if leftovers:
            errors.append(f"{chunk} still integration-only: {','.join(leftovers)}")

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
