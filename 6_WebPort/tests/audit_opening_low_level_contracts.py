#!/usr/bin/env python3
"""Audit every lower-level dependency called by MASM 100OPDMO.

This inventory is derived from MASM on every run. A contract marked adapter or
oracle is intentionally incomplete; only live_parity is accepted by --strict.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ASM = ROOT / "3_Assembly/masm/working/zelres1/code/100OPDMO.asm"
CONTRACTS = ROOT / "6_WebPort/tests/opening_low_level_contracts.json"
CALL_RE = re.compile(r"^\s*(?:call|int)\s+(.+?)(?:\s*;.*)?$", re.IGNORECASE)
SLOT_RE = re.compile(r"^word ptr cs:\[([^]]+)\]$", re.IGNORECASE)


def normalize_target(operand: str) -> str:
    operand = operand.strip()
    slot = SLOT_RE.match(operand)
    return slot.group(1) if slot else operand


def masm_dependencies() -> tuple[Counter[str], dict[str, list[int]]]:
    dependencies: Counter[str] = Counter()
    call_lines: dict[str, list[int]] = {}
    for line_number, line in enumerate(ASM.read_text(encoding="cp1252").splitlines(), 1):
        match = CALL_RE.match(line)
        if match:
            target = normalize_target(match.group(1))
            dependencies[target] += 1
            call_lines.setdefault(target, []).append(line_number)
    return dependencies, call_lines


def remaining_evidence(contract: dict) -> str:
    state = contract.get("state", "missing")
    if state == "adapter":
        return ("Capture the real MASM service boundary, then replace the C "
                "adapter with a traced runtime implementation.")
    if state == "oracle":
        return ("Connect the existing MASM oracle to the live C runtime trace "
                "and framebuffer/memory comparison.")
    return "Complete."


def write_report(path: Path, dependencies: Counter[str], call_lines: dict[str, list[int]],
                 contracts: dict) -> None:
    rows = [
        "# Opening Low-Level Parity Inventory",
        "",
        "Generated from `100OPDMO.asm`; MASM is the authority.",
        "",
        "| Dependency | MASM call lines | Calls | Kind | Current C boundary | State | Next evidence |",
        "|---|---|---:|---|---|---|---|",
    ]
    for name in sorted(dependencies, key=lambda item: (-dependencies[item], item)):
        contract = contracts.get(name, {})
        c_boundary = contract.get("c", "UNCONTRACTED")
        rows.append(
            f"| `{name}` | {', '.join(map(str, call_lines[name]))} | {dependencies[name]} | "
            f"{contract.get('kind', 'missing')} | "
            f"{c_boundary} | {contract.get('state', 'missing')} | "
            f"{remaining_evidence(contract)} |"
        )
    path.write_text("\n".join(rows) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true",
                        help="fail unless every dependency has live parity")
    parser.add_argument("--report", type=Path,
                        help="write a Markdown inventory of every MASM dependency")
    args = parser.parse_args()

    dependencies, call_lines = masm_dependencies()
    document = json.loads(CONTRACTS.read_text(encoding="utf-8"))
    contracts = document["contracts"]
    missing = sorted(set(dependencies) - set(contracts))
    stale = sorted(set(contracts) - set(dependencies))
    states = Counter(
        contracts[name].get("state", "missing")
        for name in dependencies if name in contracts
    )

    print(f"MASM lower-level dependencies: {len(dependencies)} ({sum(dependencies.values())} calls)")
    for state in ("live_parity", "adapter", "oracle", "missing"):
        print(f"  {state}: {states[state]}")
    if missing:
        print("uncontracted MASM dependencies:")
        for name in missing:
            print(f"  {name}")
    if stale:
        print("stale contracts not called by MASM:")
        for name in stale:
            print(f"  {name}")

    incomplete = [
        name for name in dependencies
        if contracts.get(name, {}).get("state") != "live_parity"
    ]
    if args.report:
        write_report(args.report, dependencies, call_lines, contracts)
        print(f"wrote parity inventory: {args.report}")
    if missing or stale:
        print("VERDICT: FAIL: lower-level contract inventory differs from MASM")
        return 1
    if args.strict and incomplete:
        print(f"VERDICT: FAIL: {len(incomplete)} dependencies lack live C/MASM parity")
        return 1
    print(f"VERDICT: PASS: all {len(dependencies)} MASM dependencies are inventoried")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
