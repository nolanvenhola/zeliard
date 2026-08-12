import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "replay"))

from zeliard_replay import (  # noqa: E402
    ScenarioError, dos_scancode_events, load_scenario, parse_scenario,
    scenario_sha256,
)
from run_replay import _dos_records, _instrument_stick  # noqa: E402


class ReplayContractTests(unittest.TestCase):
    def test_smoke_scenario_normalizes_relative_waits(self):
        scenario = load_scenario(
            ROOT / "scripts/replay/scenarios/smoke-title-menu.json")
        self.assertEqual(scenario.checkpoint_names(),
                         ["title-ready", "menu-moved"])
        self.assertEqual([e.pit_tick for e in scenario.events],
                         [48, 48, 50, 62, 66, 68])
        self.assertEqual(
            list(dos_scancode_events(scenario, "menu-moved")),
            [(48, 0x39), (50, 0xB9), (62, 0x50), (66, 0xD0),
             (68, -1)],
        )

    def test_canonical_hash_is_stable(self):
        scenario = load_scenario(
            ROOT / "scripts/replay/scenarios/smoke-title-menu.json")
        self.assertEqual(scenario_sha256(scenario), scenario_sha256(scenario))
        self.assertEqual(len(scenario_sha256(scenario)), 64)

    def test_duplicate_down_and_stuck_keys_are_rejected(self):
        base = {
            "format": "zeliard-replay-v1", "name": "bad", "events": [
                {"action": "key_down", "key": "left"},
                {"action": "key_down", "key": "left"},
                {"action": "checkpoint", "name": "never"},
            ]}
        with self.assertRaisesRegex(ScenarioError, "duplicates held key"):
            parse_scenario(base)
        base["events"].pop(1)
        with self.assertRaisesRegex(ScenarioError, "stuck keys"):
            parse_scenario(base)

    def test_release_without_make_is_rejected(self):
        with self.assertRaisesRegex(ScenarioError, "releases unheld key"):
            parse_scenario({
                "format": "zeliard-replay-v1", "name": "bad",
                "events": [
                    {"action": "key_up", "key": "f9"},
                    {"action": "checkpoint", "name": "never"},
                ]})

    def test_host_time_is_not_a_clock(self):
        with self.assertRaisesRegex(ScenarioError, "invalid clock"):
            parse_scenario({
                "format": "zeliard-replay-v1", "name": "bad",
                "events": [{
                    "when": {"clock": "milliseconds", "value": 10},
                    "action": "checkpoint", "name": "bad",
                }]})

    def test_private_stick_instrumentation_preserves_release_source(self):
        scenario = load_scenario(
            ROOT / "scripts/replay/scenarios/smoke-title-menu.json")
        records = _dos_records(scenario, "menu-moved")
        source = (ROOT / "1_OriginalGame/stick.bin").read_bytes()
        hook = b"hook" + b"ZRPEVENT" + bytes([0xFF]) * 3000
        instrumented = _instrument_stick(source, hook, records)
        self.assertEqual(source[0x15A:0x15F], b"\x2e\xff\x1e\x10\xff")
        self.assertEqual(instrumented[0x15A], 0xE8)
        self.assertEqual(instrumented[0x15D:0x15F], b"\x90\x90")
        table = 0x1036 + hook.index(b"ZRPEVENT") + len(b"ZRPEVENT")
        self.assertEqual(instrumented[table:table + len(records)], records)

    def test_setup_save_is_canonical(self):
        scenario = load_scenario(
            ROOT / "scripts/replay/scenarios/saved-town-controls.json")
        self.assertEqual(scenario.setup["save"],
                         "scripts/state/fixtures/valid/BASE.USR")

    def test_named_breakpoint_resolves_without_host_time(self):
        scenario = parse_scenario({
            "format": "zeliard-replay-v1", "name": "breakpoint",
            "breakpoints": {"100OPDMO:title_display": 120},
            "events": [{
                "when": {"clock": "breakpoint",
                         "value": "100OPDMO:title_display", "offset": 3},
                "action": "checkpoint", "name": "title",
            }],
        })
        self.assertEqual(scenario.events[0].pit_tick, 123)

    def test_dos_joystick_and_keyboard_share_held_state(self):
        scenario = parse_scenario({
            "format": "zeliard-replay-v1", "name": "combined",
            "events": [
                {"action": "key_down", "key": "right"},
                {"action": "joystick", "directions": 8, "buttons": 1},
                {"action": "key_up", "key": "right"},
                {"action": "joystick", "directions": 0, "buttons": 0},
                {"action": "text_key", "text": "A"},
                {"action": "checkpoint", "name": "combined"},
            ],
        })
        records = _dos_records(scenario, "combined")
        scans = [records[index + 2] for index in range(0, len(records), 5)]
        # Right is not released while the gamepad still owns it.
        self.assertEqual(scans, [0x4D, 0x39, 0xCD, 0xB9,
                                 0x2A, 0x1E, 0x9E, 0xAA, 0xFF])


if __name__ == "__main__":
    unittest.main()
