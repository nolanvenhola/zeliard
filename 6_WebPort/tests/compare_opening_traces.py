#!/usr/bin/env python3
"""Compare two OPDMO service traces and report the first divergence."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("candidate", type=Path)
    args = parser.parse_args()

    reference = json.loads(args.reference.read_text(encoding="utf-8"))
    candidate = json.loads(args.candidate.read_text(encoding="utf-8"))
    ref_events = reference.get("events", [])
    got_events = candidate.get("events", [])

    for index, (expected, got) in enumerate(zip(ref_events, got_events)):
        if expected != got:
            print(f"VERDICT: FAIL: first divergence at event {index}")
            print(f"reference: {json.dumps(expected, sort_keys=True)}")
            print(f"candidate: {json.dumps(got, sort_keys=True)}")
            return 1

    if len(ref_events) != len(got_events):
        print(f"VERDICT: FAIL: event count reference={len(ref_events)} candidate={len(got_events)}")
        return 1

    print(f"VERDICT: PASS: {len(ref_events)} service events match")
    return 0
