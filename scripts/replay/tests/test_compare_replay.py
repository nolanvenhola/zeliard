import copy
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "replay"))

from compare_replay import (  # noqa: E402
    compact_golden, compare_suite, render_html,
)
from zeliard_replay import parse_scenario  # noqa: E402


def checkpoint(name="ready", tick=12):
    return {
        "name": name,
        "state": {"guestTick": tick, "scene": 2, "transitionOwner": "town"},
        "hashes": {
            "segmentCrc16": "1111",
            "framebufferCrc16": "2222",
            "paletteCrc16": "3333",
        },
        "audioEvents": [{"tick": tick, "kind": "music", "value": 3}],
    }


def runtime(name, rows=None):
    return {
        "format": "zeliard-replay-result-v1", "runtime": name,
        "deterministic": True,
        "runs": [{"run": 0, "status": "pass",
                  "checkpoints": rows or [checkpoint()]}],
    }


class DifferentialReportTests(unittest.TestCase):
    def setUp(self):
        self.scenario = parse_scenario({
            "format": "zeliard-replay-v1", "name": "synthetic",
            "events": [{"action": "checkpoint", "name": "ready",
                        "owner": "200FIGHT:frame_boundary"}],
        })
        self.suite = {
            "format": "zeliard-replay-suite-v1", "scenario": "synthetic",
            "scenarioSha256": "A" * 64,
            "reports": [runtime("dosboxx-masm"), runtime("wasm")],
        }

    def compare(self, suite=None):
        return compare_suite(suite or self.suite, self.scenario,
                             reproduction="python run_replay.py synthetic.json")

    def test_matching_report_has_hash_and_coverage_evidence(self):
        report = self.compare()
        self.assertEqual(report["status"], "pass")
        pair = report["pairs"][0]
        self.assertEqual(pair["coverage"]["comparedCheckpoints"], 1)
        self.assertEqual(pair["timeline"][0]["leftHashes"]["framebufferCrc16"],
                         "2222")
        self.assertIn("200FIGHT:frame_boundary", render_html(report))
        self.assertNotIn("audioEvents", str(compact_golden(report)))

    def test_deliberate_timing_mismatch_is_timing(self):
        suite = copy.deepcopy(self.suite)
        suite["reports"][1]["runs"][0]["checkpoints"][0]["state"]["guestTick"] = 13
        first = self.compare(suite)["firstDivergence"]
        self.assertEqual(first["category"], "timing")
        self.assertEqual(first["owner"], "200FIGHT:frame_boundary")

    def test_deliberate_state_mismatch_is_state(self):
        suite = copy.deepcopy(self.suite)
        suite["reports"][1]["runs"][0]["checkpoints"][0]["state"]["scene"] = 3
        self.assertEqual(self.compare(suite)["firstDivergence"]["category"],
                         "state")

    def test_deliberate_pixel_mismatch_is_framebuffer(self):
        suite = copy.deepcopy(self.suite)
        suite["reports"][1]["runs"][0]["checkpoints"][0]["hashes"][
            "framebufferCrc16"] = "FFFF"
        self.assertEqual(self.compare(suite)["firstDivergence"]["category"],
                         "framebuffer")

    def test_deliberate_audio_mismatch_is_audio(self):
        suite = copy.deepcopy(self.suite)
        suite["reports"][1]["runs"][0]["checkpoints"][0]["audioEvents"][0][
            "value"] = 4
        self.assertEqual(self.compare(suite)["firstDivergence"]["category"],
                         "audio")

    def test_original_masm_pair_is_independent(self):
        suite = copy.deepcopy(self.suite)
        suite["reports"] = [runtime("dosboxx-original"),
                            runtime("dosboxx-masm"), runtime("wasm")]
        report = self.compare(suite)
        self.assertEqual([row["pair"] for row in report["pairs"]], [
            "dosboxx-original-vs-dosboxx-masm",
            "dosboxx-masm-vs-wasm",
        ])

    def test_continue_policy_preserves_later_timeline(self):
        self.scenario = parse_scenario({
            "format": "zeliard-replay-v1", "name": "continue",
            "comparison": {"stopOnFirstDivergence": False},
            "events": [
                {"action": "checkpoint", "name": "ready"},
                {"action": "checkpoint", "name": "later"},
            ],
        })
        left = [checkpoint(), checkpoint("later", 20)]
        right = copy.deepcopy(left)
        right[0]["hashes"]["paletteCrc16"] = "0000"
        suite = {"scenario": "continue", "reports": [
            runtime("dosboxx-masm", left), runtime("wasm", right)]}
        self.assertEqual(len(self.compare(suite)["pairs"][0]["timeline"]), 2)


if __name__ == "__main__":
    unittest.main()
