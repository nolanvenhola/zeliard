#!/usr/bin/env python3
"""Run one canonical input scenario against DOSBox-X and/or WASM."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(ROOT / "3_Assembly" / "masm"))

from zeliard_replay import (  # noqa: E402
    KEYS, Scenario, ScenarioError, canonical_document, load_scenario,
    scenario_sha256,
)

STICK_RELEASE_SIZE = 0x1036
HOOK_RUNTIME_ORIGIN = 0x1136
EVENT_MARKER = b"ZRPEVENT"
EVENT_CAPACITY = 512
RESULT_STRUCT = struct.Struct("<4sHBBHHHBBBB")
ASCII_SCANCODES = {
    **dict(zip("1234567890", range(0x02, 0x0C))),
    **dict(zip("qwertyuiop", range(0x10, 0x1A))),
    **dict(zip("asdfghjkl", range(0x1E, 0x27))),
    **dict(zip("zxcvbnm", range(0x2C, 0x33))),
    "\b": 0x0E,
}


def _write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def _compile_hook(output: Path) -> bytes:
    import build_masm

    result = build_masm.compile_one_masm(
        HERE / "guest" / "zreplay.asm", output)
    if not result[1] or result[3] is None:
        raise RuntimeError(f"replay hook assembly failed: {result[2]}")
    hook = Path(result[3]).read_bytes()
    marker = hook.find(EVENT_MARKER)
    if marker < 0:
        raise RuntimeError("replay hook event marker is missing")
    if STICK_RELEASE_SIZE + len(hook) >= 0x1F00:
        raise RuntimeError("replay hook overlaps the graphics driver at CS:2000")
    return hook


def _dos_records(scenario: Scenario, checkpoint: str) -> bytes:
    records = bytearray()
    checkpoint_id = scenario.checkpoint_names().index(checkpoint)
    reached = False
    keyboard_keys: set[str] = set()
    gamepad_keys: set[str] = set()
    active_keys: set[str] = set()

    def emit_state(tick: int, sequence: int, next_keys: set[str]) -> None:
        nonlocal active_keys
        # Releases precede makes, matching the WASM binding loop's transition
        # from the previous complete controller state to the next one.
        for key in sorted(active_keys - next_keys):
            records.extend(struct.pack(
                "<HBBB", tick, KEYS[key][1] | 0x80, sequence, 0))
        for key in sorted(next_keys - active_keys):
            records.extend(struct.pack(
                "<HBBB", tick, KEYS[key][1], sequence, 0))
        active_keys = set(next_keys)

    for event in scenario.events:
        if event.pit_tick > 0xFFFE:
            raise ScenarioError(
                f"event {event.sequence} exceeds the DOS replay tick range")
        if event.sequence > 0xFF:
            raise ScenarioError("DOS replay supports at most 256 source events")
        if event.action in {"key_down", "key_up"}:
            key = event.payload["key"]
            if event.action == "key_down":
                keyboard_keys.add(key)
            else:
                keyboard_keys.remove(key)
            emit_state(event.pit_tick, event.sequence,
                       keyboard_keys | gamepad_keys)
        elif event.action == "joystick":
            directions = event.payload["directions"]
            buttons = event.payload["buttons"]
            desired = set()
            for mask, key in ((1, "up"), (2, "down"), (4, "left"),
                              (8, "right")):
                if directions & mask:
                    desired.add(key)
            for mask, key in ((1, "space"), (2, "alt"), (4, "enter"),
                              (8, "escape"), (16, "f7"), (32, "f9"),
                              (64, "f1"), (128, "f2")):
                if buttons & mask:
                    desired.add(key)
            gamepad_keys = desired
            emit_state(event.pit_tick, event.sequence,
                       keyboard_keys | gamepad_keys)
        elif event.action == "checkpoint" and event.payload["name"] == checkpoint:
            records += struct.pack("<HBBB", event.pit_tick, 0xFF,
                                   checkpoint_id, event.sequence)
            reached = True
            break
        elif event.action == "text_key":
            character = event.payload["text"]
            lower = character.lower()
            if lower not in ASCII_SCANCODES:
                raise ScenarioError(
                    f"DOSBox-X cannot type character {character!r}")
            scan = ASCII_SCANCODES[lower]
            if character.isupper():
                records += struct.pack(
                    "<HBBB", event.pit_tick, 0x2A, event.sequence, 0)
            records += struct.pack(
                "<HBBB", event.pit_tick, scan, event.sequence, 0)
            records += struct.pack(
                "<HBBB", event.pit_tick, scan | 0x80, event.sequence, 0)
            if character.isupper():
                records += struct.pack(
                    "<HBBB", event.pit_tick, 0xAA, event.sequence, 0)
        # Assertions are evaluated from the checkpoint report by the host.
    if not reached:
        raise ScenarioError(f"checkpoint {checkpoint!r} was not reached")
    if len(records) // 5 > EVENT_CAPACITY:
        raise ScenarioError("checkpoint prefix exceeds DOS event capacity")
    return bytes(records)


def _instrument_stick(stick: bytes, hook_template: bytes,
                      records: bytes) -> bytes:
    if len(stick) != STICK_RELEASE_SIZE:
        raise RuntimeError(
            f"stick.bin must be {STICK_RELEASE_SIZE} bytes, got {len(stick)}")
    timer_present = 0x15A
    if stick[timer_present:timer_present + 5] != b"\x2E\xFF\x1E\x10\xFF":
        raise RuntimeError("stick.bin graphics-present call does not match the release driver")
    hook = bytearray(hook_template)
    marker = hook.index(EVENT_MARKER)
    table = marker + len(EVENT_MARKER)
    hook[table:table + len(records)] = records
    image = bytearray(stick)
    # Replace the timer's far graphics call with a near call to the hook. The
    # hook performs that original call first and resumes at CS:025Fh.
    displacement = STICK_RELEASE_SIZE - (timer_present + 3)
    struct.pack_into("<BH", image, timer_present, 0xE8, displacement)
    image[timer_present + 3:timer_present + 5] = b"\x90\x90"
    image += hook
    return bytes(image)


def _dosbox_executable() -> Path:
    pin = json.loads((ROOT / "scripts/dosboxx/dosboxx-pin.json").read_text())
    relative = Path(*pin["executableRelativePath"].split("/"))
    executable = (ROOT / "artifacts/dosboxx-cache" / pin["version"] /
                  "portable" / relative)
    if not executable.is_file():
        raise RuntimeError(
            "pinned DOSBox-X is not provisioned; run "
            "scripts/dosboxx/Invoke-ZeliardDosboxX.ps1 -Action Provision")
    import hashlib
    actual = hashlib.sha256(executable.read_bytes()).hexdigest().upper()
    if actual != pin["executableSha256"].upper():
        raise RuntimeError("cached DOSBox-X executable failed its pin hash")
    return executable


def _parse_dos_result(path: Path, expected_checkpoint: str) -> dict[str, Any]:
    raw = path.read_bytes()
    if len(raw) != RESULT_STRUCT.size:
        raise RuntimeError(
            f"{expected_checkpoint}: replay result is {len(raw)} bytes, "
            f"expected {RESULT_STRUCT.size}")
    (magic, tick, checkpoint_id, status, segment_crc, framebuffer_crc,
     palette_crc, last_input, checkpoint_sequence, first_missed,
     _reserved) = RESULT_STRUCT.unpack(raw)
    if magic != b"ZRP1":
        raise RuntimeError(f"{expected_checkpoint}: invalid replay result magic")
    if status != 1:
        raise RuntimeError(
            f"{expected_checkpoint}: guest status={status}, "
            f"lastInput={last_input}, firstMissed={first_missed}, tick={tick}")
    return {
        "name": expected_checkpoint,
        "guestTick": tick,
        "checkpointId": checkpoint_id,
        "checkpointSequence": checkpoint_sequence,
        "lastAcceptedInput": None if last_input == 0xFF else last_input,
        "firstMissedInput": None if first_missed == 0xFF else first_missed,
        "hashes": {
            "segmentCrc16": f"{segment_crc:04X}",
            "framebufferCrc16": f"{framebuffer_crc:04X}",
            "paletteCrc16": f"{palette_crc:04X}",
        },
    }


def run_dosbox(scenario: Scenario, source: str, repeat: int,
               output_root: Path, timeout: int) -> dict[str, Any]:
    executable = _dosbox_executable()
    game_source = (ROOT / "1_OriginalGame" if source == "original" else
                   ROOT / "3_Assembly/masm/bin")
    hook = _compile_hook(output_root / "hook-build")
    base_stick = (game_source / "stick.bin").read_bytes()
    save_source = None
    save_record = None
    if scenario.setup.get("save"):
        save_source = (ROOT / scenario.setup["save"]).resolve()
        if not save_source.is_file() or save_source.stat().st_size != 0x100:
            raise ScenarioError(
                f"setup save must be a 256-byte file: {save_source}")
        save_record = bytearray(save_source.read_bytes())
        for offset, byte in scenario.setup.get("patches", {}).items():
            save_record[int(offset, 0)] = byte
    runs = []
    for run_index in range(repeat):
        checkpoints = []
        for checkpoint in scenario.checkpoint_names():
            checkpoint_event = next(
                event for event in scenario.events
                if event.action == "checkpoint" and
                event.payload["name"] == checkpoint)
            prior_inputs = [
                event.sequence for event in scenario.events
                if event.sequence < checkpoint_event.sequence and
                event.action in {"key_down", "key_up", "text_key", "joystick"}
            ]
            last_scheduled = prior_inputs[-1] if prior_inputs else None
            stage = output_root / f"dosboxx-{source}-r{run_index:02d}-{checkpoint}"
            game = stage / "game"
            if stage.exists():
                shutil.rmtree(stage)
            shutil.copytree(game_source, game)
            save_argument = ""
            if save_source:
                save_base = save_source.stem[:8]
                save_name = save_base + ".USR"
                (game / save_name).write_bytes(save_record)
                save_argument = " " + save_base
            records = _dos_records(scenario, checkpoint)
            (game / "stick.bin").write_bytes(
                _instrument_stick(base_stick, hook, records))
            config = stage / "dosbox-x.conf"
            config.write_text(
                "[dosbox]\nstartbanner=false\ndisable graphical splash=true\n"
                "allow quit after warning=true\n"
                "[sdl]\nfullscreen=false\nautolock=false\noutput=surface\n"
                "showmenu=false\n"
                "[render]\nframeskip=0\naspect=false\nscaler=none\n"
                "[cpu]\ncore=normal\ncycles=fixed 5000\n"
                "[autoexec]\n@echo off\n"
                f'mount c "{game}"\nc:\nzeliad.exe{save_argument}\nexit\n',
                encoding="ascii")
            environment = os.environ.copy()
            environment["SDL_VIDEODRIVER"] = "dummy"
            environment["SDL_AUDIODRIVER"] = "dummy"
            startupinfo = None
            creationflags = 0
            if os.name == "nt":
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                startupinfo.wShowWindow = subprocess.SW_HIDE
                creationflags = subprocess.CREATE_NO_WINDOW
            command = [str(executable), "-nodefaultconf", "-conf", str(config)]
            try:
                completed = subprocess.run(
                    command, cwd=executable.parent, env=environment,
                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                    timeout=timeout, startupinfo=startupinfo,
                    creationflags=creationflags, check=False)
            except subprocess.TimeoutExpired as exc:
                raise RuntimeError(
                    f"first missed checkpoint={checkpoint!r} sequence="
                    f"{checkpoint_event.sequence}; last scheduled input="
                    f"{last_scheduled}; DOSBox-X timed out before REPLAY.OUT") from exc
            result_path = game / "REPLAY.OUT"
            if not result_path.is_file():
                tail = completed.stdout.decode(errors="replace")[-500:]
                raise RuntimeError(
                    f"first missed checkpoint={checkpoint!r} sequence="
                    f"{checkpoint_event.sequence}; last scheduled input="
                    f"{last_scheduled}; DOSBox-X exited {completed.returncode} "
                    f"without REPLAY.OUT; output={tail!r}")
            checkpoints.append(_parse_dos_result(result_path, checkpoint))
        runs.append({"run": run_index, "status": "pass",
                     "checkpoints": checkpoints})
    signatures = [json.dumps(run["checkpoints"], sort_keys=True) for run in runs]
    deterministic = all(item == signatures[0] for item in signatures)
    return {
        "format": "zeliard-replay-result-v1", "runtime": f"dosboxx-{source}",
        "scenario": scenario.name, "repeat": repeat,
        "deterministic": deterministic, "runs": runs,
    }


def run_wasm(scenario: Scenario, repeat: int, url: str,
             output_root: Path, timeout: int) -> dict[str, Any]:
    canonical = output_root / "scenario.canonical.json"
    report_path = output_root / "wasm-result.json"
    _write_json(canonical, canonical_document(scenario))
    runner = ROOT / "6_WebPort/shell/run_guest_replay.mjs"
    command = ["node", str(runner), "--scenario", str(canonical),
               "--output", str(report_path), "--repeat", str(repeat),
               "--url", url]
    completed = subprocess.run(command, cwd=runner.parent, timeout=timeout,
                               text=True, capture_output=True, check=False)
    if completed.returncode != 0:
        raise RuntimeError(
            "WASM replay failed:\n" + completed.stdout + completed.stderr)
    return json.loads(report_path.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("scenario", type=Path)
    parser.add_argument("--runtime", choices=("dosboxx", "wasm", "both"),
                        default="both")
    parser.add_argument("--source", choices=("original", "masm"),
                        default="original")
    parser.add_argument("--repeat", type=int, default=1)
    parser.add_argument("--url", default="http://127.0.0.1:5179/")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.repeat < 1:
        parser.error("--repeat must be positive")
    scenario = load_scenario(args.scenario)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    output_root = (args.output or ROOT / "artifacts/replay-runs" /
                   f"{scenario.name}-{stamp}").resolve()
    output_root.mkdir(parents=True, exist_ok=True)
    reports = []
    if args.runtime in {"dosboxx", "both"}:
        reports.append(run_dosbox(scenario, args.source, args.repeat,
                                  output_root, args.timeout))
    if args.runtime in {"wasm", "both"}:
        reports.append(run_wasm(scenario, args.repeat, args.url,
                                output_root, args.timeout))
    result = {
        "format": "zeliard-replay-suite-v1",
        "scenario": scenario.name,
        "scenarioSha256": scenario_sha256(scenario),
        "status": "pass" if all(r["deterministic"] for r in reports) else "fail",
        "reports": reports,
    }
    _write_json(output_root / "result.json", result)
    print(json.dumps({"status": result["status"],
                      "output": str(output_root / "result.json")}, indent=2))
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
