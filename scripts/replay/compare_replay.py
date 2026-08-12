#!/usr/bin/env python3
"""Compare aligned Zeliard replay results and render actionable reports."""

from __future__ import annotations

import argparse
import html
import json
from pathlib import Path
from typing import Any

from zeliard_replay import Scenario, load_scenario

FORMAT = "zeliard-differential-report-v1"
HASH_FIELDS = {
    "segmentCrc16": "state",
    "framebufferCrc16": "framebuffer",
    "paletteCrc16": "palette",
}
AUDIO_FIELDS = ("audio", "audioEvents", "soundCues", "music")


def _checkpoint_tick(checkpoint: dict[str, Any]) -> int | None:
    value = checkpoint.get("guestTick")
    if value is None:
        value = checkpoint.get("state", {}).get("guestTick")
    return value if isinstance(value, int) else None


def _checkpoint_map(report: dict[str, Any]) -> tuple[list[str], dict[str, Any]]:
    runs = report.get("runs", [])
    if not runs or runs[0].get("status") != "pass":
        return [], {}
    checkpoints = runs[0].get("checkpoints", [])
    names = [row.get("name") for row in checkpoints
             if isinstance(row.get("name"), str)]
    return names, {row["name"]: row for row in checkpoints
                   if isinstance(row.get("name"), str)}


def _state_differences(left: dict[str, Any], right: dict[str, Any]) -> list[dict[str, Any]]:
    left_state = left.get("state")
    right_state = right.get("state")
    if not isinstance(left_state, dict) or not isinstance(right_state, dict):
        return []
    differences = []
    for key in sorted(set(left_state) & set(right_state) - {"guestTick"}):
        if left_state[key] != right_state[key]:
            differences.append({"field": key, "left": left_state[key],
                                "right": right_state[key]})
    return differences


def _owner_map(scenario: Scenario) -> dict[str, str]:
    result = {}
    for event in scenario.events:
        if event.action != "checkpoint":
            continue
        owner = event.payload.get("owner") or event.payload.get("masmOwner")
        result[event.payload["name"]] = (str(owner) if owner else
                                          "unmapped MASM owner")
    return result


def default_pairs(reports: list[dict[str, Any]]) -> list[tuple[str, str]]:
    runtimes = {report.get("runtime") for report in reports}
    pairs = []
    if {"dosboxx-original", "dosboxx-masm"} <= runtimes:
        pairs.append(("dosboxx-original", "dosboxx-masm"))
    if {"dosboxx-masm", "wasm"} <= runtimes:
        pairs.append(("dosboxx-masm", "wasm"))
    elif {"dosboxx-original", "wasm"} <= runtimes:
        pairs.append(("dosboxx-original", "wasm"))
    return pairs


def compare_pair(left_report: dict[str, Any], right_report: dict[str, Any],
                 scenario: Scenario) -> dict[str, Any]:
    left_runtime = str(left_report["runtime"])
    right_runtime = str(right_report["runtime"])
    left_order, left = _checkpoint_map(left_report)
    right_order, right = _checkpoint_map(right_report)
    order = list(dict.fromkeys(left_order + right_order))
    owners = _owner_map(scenario)
    stop_on_first = scenario.comparison["stopOnFirstDivergence"]
    tolerance = scenario.comparison["tickTolerance"]
    timeline = []
    first = None

    for name in order:
        differences = []
        if name not in left or name not in right:
            differences.append({
                "category": "checkpoint",
                "field": "presence",
                "left": name in left,
                "right": name in right,
            })
            left_row = left.get(name, {})
            right_row = right.get(name, {})
        else:
            left_row, right_row = left[name], right[name]
            left_tick = _checkpoint_tick(left_row)
            right_tick = _checkpoint_tick(right_row)
            if (left_tick is None or right_tick is None or
                    abs(left_tick - right_tick) > tolerance):
                differences.append({
                    "category": "timing", "field": "guestTick",
                    "left": left_tick, "right": right_tick,
                    "tolerance": tolerance,
                })
            for difference in _state_differences(left_row, right_row):
                differences.append({"category": "state", **difference})
            left_hashes = left_row.get("hashes", {})
            right_hashes = right_row.get("hashes", {})
            for field, category in HASH_FIELDS.items():
                if field in left_hashes and field in right_hashes and \
                        left_hashes[field] != right_hashes[field]:
                    differences.append({
                        "category": category, "field": field,
                        "left": left_hashes[field],
                        "right": right_hashes[field],
                    })
            for field in AUDIO_FIELDS:
                if field in left_row and field in right_row and \
                        left_row[field] != right_row[field]:
                    differences.append({
                        "category": "audio", "field": field,
                        "left": left_row[field], "right": right_row[field],
                    })

        entry = {
            "checkpoint": name,
            "owner": owners.get(name, "unmapped MASM owner"),
            "status": "fail" if differences else "pass",
            "leftTick": _checkpoint_tick(left_row),
            "rightTick": _checkpoint_tick(right_row),
            "leftHashes": left_row.get("hashes", {}),
            "rightHashes": right_row.get("hashes", {}),
            "differences": differences,
        }
        timeline.append(entry)
        if differences and first is None:
            first = {
                "checkpoint": name,
                "owner": entry["owner"],
                "category": differences[0]["category"],
                "differences": differences,
            }
            if stop_on_first:
                break

    return {
        "pair": f"{left_runtime}-vs-{right_runtime}",
        "leftRuntime": left_runtime,
        "rightRuntime": right_runtime,
        "status": "fail" if first else "pass",
        "firstDivergence": first,
        "timeline": timeline,
        "coverage": {
            "leftCheckpoints": len(left), "rightCheckpoints": len(right),
            "comparedCheckpoints": len(timeline),
            "availableCheckpoints": len(order),
        },
    }


def compare_suite(suite: dict[str, Any], scenario: Scenario,
                  pairs: list[tuple[str, str]] | None = None,
                  reproduction: str = "") -> dict[str, Any]:
    reports = suite.get("reports", [])
    by_runtime = {str(report.get("runtime")): report for report in reports}
    selected = pairs if pairs is not None else default_pairs(reports)
    pair_results = []
    for left, right in selected:
        if left not in by_runtime or right not in by_runtime:
            raise ValueError(f"comparison pair is unavailable: {left} vs {right}")
        pair_results.append(compare_pair(
            by_runtime[left], by_runtime[right], scenario))
    status = "pass" if pair_results and all(
        result["status"] == "pass" for result in pair_results) else "fail"
    first = next((result["firstDivergence"] for result in pair_results
                  if result["firstDivergence"]), None)
    return {
        "format": FORMAT,
        "scenario": suite.get("scenario", scenario.name),
        "scenarioSha256": suite.get("scenarioSha256"),
        "status": status,
        "policy": scenario.comparison,
        "reproductionCommand": reproduction,
        "firstDivergence": first,
        "pairs": pair_results,
    }


def compact_golden(report: dict[str, Any]) -> dict[str, Any]:
    return {
        "format": "zeliard-replay-golden-v1",
        "scenario": report["scenario"],
        "scenarioSha256": report.get("scenarioSha256"),
        "pairs": [{
            "pair": pair["pair"], "status": pair["status"],
            "checkpoints": [{
                "name": row["checkpoint"],
                "leftTick": row["leftTick"],
                "rightTick": row["rightTick"],
                "leftHashes": row["leftHashes"],
                "rightHashes": row["rightHashes"],
            } for row in pair["timeline"]],
        } for pair in report["pairs"]],
    }


def render_html(report: dict[str, Any]) -> str:
    encoded = json.dumps(report).replace("</", "<\\/")
    title = html.escape(f"Zeliard parity: {report['scenario']}")
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>{title}</title><style>
body{{font:14px system-ui;background:#101418;color:#e8edf2;margin:24px}}
h1,h2{{margin:.4em 0}} .pass{{color:#64d98b}} .fail{{color:#ff7272}}
table{{border-collapse:collapse;width:100%;margin:12px 0 28px}}
th,td{{border:1px solid #3b4652;padding:7px;text-align:left;vertical-align:top}}
th{{background:#202832}} code,pre{{background:#171d24;padding:3px 5px;white-space:pre-wrap}}
details{{margin:4px 0}} .muted{{color:#9eabb8}}
</style></head><body><h1>{title}</h1><div id="app"></div>
<script id="report" type="application/json">{encoded}</script><script>
const r=JSON.parse(document.querySelector('#report').textContent);
const esc=v=>String(v??'').replace(/[&<>"']/g,c=>({{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}}[c]));
let out=`<p class="${{r.status}}"><b>${{r.status.toUpperCase()}}</b></p>`;
if(r.firstDivergence)out+=`<p>First divergence: <b>${{esc(r.firstDivergence.category)}}</b> at <code>${{esc(r.firstDivergence.checkpoint)}}</code> — ${{esc(r.firstDivergence.owner)}}</p>`;
out+=`<p>Reproduce: <code>${{esc(r.reproductionCommand)}}</code></p>`;
for(const p of r.pairs){{out+=`<h2>${{esc(p.pair)}} <span class="${{p.status}}">${{p.status}}</span></h2><p class="muted">${{p.coverage.comparedCheckpoints}} / ${{p.coverage.availableCheckpoints}} checkpoints compared</p><table><thead><tr><th>Checkpoint</th><th>Ticks</th><th>Hashes</th><th>Differences / MASM owner</th></tr></thead><tbody>`;for(const c of p.timeline){{out+=`<tr><td class="${{c.status}}">${{esc(c.checkpoint)}}</td><td>${{esc(c.leftTick)}} / ${{esc(c.rightTick)}}</td><td><details><summary>hashes</summary><pre>${{esc(JSON.stringify({{left:c.leftHashes,right:c.rightHashes}},null,2))}}</pre></details></td><td>${{esc(c.owner)}}<pre>${{esc(JSON.stringify(c.differences,null,2))}}</pre></td></tr>`}}out+='</tbody></table>'}}
document.querySelector('#app').innerHTML=out;
</script></body></html>"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("result", type=Path)
    parser.add_argument("--scenario", required=True, type=Path)
    parser.add_argument("--json", dest="json_output", type=Path)
    parser.add_argument("--html", dest="html_output", type=Path)
    parser.add_argument("--pair", action="append", default=[],
                        help="LEFT:RIGHT runtime pair (repeatable)")
    parser.add_argument("--reproduction", default="")
    parser.add_argument("--write-golden", type=Path)
    args = parser.parse_args()
    suite = json.loads(args.result.read_text(encoding="utf-8"))
    scenario = load_scenario(args.scenario)
    pairs = None
    if args.pair:
        pairs = []
        for value in args.pair:
            try:
                left, right = value.split(":", 1)
            except ValueError as exc:
                raise SystemExit(f"invalid --pair {value!r}; use LEFT:RIGHT") from exc
            pairs.append((left, right))
    report = compare_suite(suite, scenario, pairs, args.reproduction)
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(json.dumps(report, indent=2) + "\n")
    if args.html_output:
        args.html_output.parent.mkdir(parents=True, exist_ok=True)
        args.html_output.write_text(render_html(report), encoding="utf-8")
    if args.write_golden:
        args.write_golden.parent.mkdir(parents=True, exist_ok=True)
        args.write_golden.write_text(
            json.dumps(compact_golden(report), indent=2) + "\n")
    print(json.dumps({"status": report["status"],
                      "firstDivergence": report["firstDivergence"]}, indent=2))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
