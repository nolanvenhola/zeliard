import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

import sys

STATE_DIR = Path(__file__).resolve().parents[1]
ROOT = STATE_DIR.parents[1]
sys.path.insert(0, str(STATE_DIR))

import zeliard_state as state


class ZeliardStateTests(unittest.TestCase):
    def test_layout_is_resolved_from_masm(self):
        equates = state.parse_masm_equates()
        resolved = state.fields()
        self.assertGreaterEqual(len(resolved), 80)
        for field in resolved:
            self.assertEqual(field.offset, equates[field.name], field.name)
        self.assertEqual(equates["cavern_object_state"], 0)
        self.assertEqual(equates["cavern_object_state_end"], 0x80)

    def test_generation_is_deterministic_and_manifest_is_exact(self):
        with tempfile.TemporaryDirectory() as first_dir, tempfile.TemporaryDirectory() as second_dir:
            first = state.generate(Path(first_dir))
            second = state.generate(Path(second_dir))
            self.assertEqual(first, second)
            for category in ("valid", "malformed"):
                for name, metadata in first["fixtures"][category].items():
                    payload = (Path(first_dir) / category / name).read_bytes()
                    self.assertEqual(len(payload), metadata["size"])
                    self.assertEqual(state.sha256(payload), metadata["sha256"])

    def test_every_documented_persistent_bit_has_clear_set_roundtrip(self):
        valid, _ = state.generate_fixture_records()
        clear = valid["CLEAR.USR"]
        progressed = valid["PROGRESS.USR"]
        coverage = state.coverage_entries()
        expected_count = len(state.BOSS_WORDS) + len(state.WHOLE_BYTE_FLAGS) + len(state.EVENT_BITS)
        self.assertEqual(len(coverage), expected_count)
        self.assertEqual(len({entry["name"] for entry in coverage}), expected_count)
        for entry in coverage:
            offset = entry["offset"]
            mask = int(entry["mask"], 16)
            width = 2 if mask == 0xFFFF else 1
            self.assertEqual(int.from_bytes(clear[offset:offset + width], "little") & mask, 0)
            self.assertEqual(int.from_bytes(progressed[offset:offset + width], "little") & mask, mask)
            self.assertTrue(entry["round_trip"])

    def test_valid_and_malformed_boundaries(self):
        valid, malformed = state.generate_fixture_records()
        for name, record in valid.items():
            self.assertEqual(state.validate(record), [], name)
        for name, record in malformed.items():
            self.assertNotEqual(state.validate(record), [], name)

    def test_scalar_codec_roundtrips_every_field(self):
        for field in state.fields():
            for value in {field.minimum, field.maximum}:
                record = state.base_record()
                state.write_value(record, field, value)
                self.assertEqual(state.read_value(record, field), value, field.name)

    def test_semantic_diff_names_offset_mask_and_values(self):
        valid, _ = state.generate_fixture_records()
        changes = state.semantic_diff(valid["CLEAR.USR"], valid["PROGRESS.USR"])
        hero = next(change for change in changes if change["name"] == "riza.hero_crest_gate")
        self.assertEqual(hero, {"offset": "0x12", "mask": "0x08",
                                "name": "riza.hero_crest_gate", "expected": 0, "actual": 1})
        boss = next(change for change in changes if change["name"] == "boss.cangrejo_defeated")
        self.assertEqual(boss["offset"], "0x00")
        self.assertEqual(boss["mask"], "0xFFFF")

    def test_legacy_editor_codec_roundtrips_generated_records(self):
        editor_path = ROOT / "3_Assembly/tasm/save_edit.py"
        spec = importlib.util.spec_from_file_location("zeliard_legacy_save_edit", editor_path)
        module = importlib.util.module_from_spec(spec)
        assert spec.loader
        spec.loader.exec_module(module)
        valid, _ = state.generate_fixture_records()
        for fixture_name, record in valid.items():
            rebuilt = bytearray(record)
            for _, offset, kind, _ in module.FIELDS:
                value = module.decode_field(record, offset, kind)
                encoded = module.encode_field(kind, value)
                rebuilt[offset:offset + len(encoded)] = encoded
            self.assertEqual(bytes(rebuilt), record, fixture_name)

    def test_fixture_names_are_dos_command_line_safe(self):
        valid, _ = state.generate_fixture_records()
        for name in valid:
            self.assertRegex(name, r"^[A-Z0-9_]{1,8}\.USR$")

    def test_tracked_manifest_matches_generator(self):
        expected = json.loads((STATE_DIR / "fixtures/manifest.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as output:
            self.assertEqual(state.generate(Path(output)), expected)


if __name__ == "__main__":
    unittest.main()
