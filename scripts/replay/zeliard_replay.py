#!/usr/bin/env python3
"""Shared deterministic replay contract for DOSBox-X and WASM.

Scenario time is measured in Zeliard's 0x13B1-divisor PIT interrupts.  Host
milliseconds are deliberately absent from the format.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

FORMAT = "zeliard-replay-v1"
CLOCKS = {"pit_tick", "frame", "breakpoint"}
ACTIONS = {
    "key_down", "key_up", "text_key", "joystick", "wait", "assert",
    "checkpoint",
}

# Browser KeyboardEvent keyCodes and IBM PC/XT set-1 scan codes.  stick.asm
# consumes the scan codes, while the WASM input shim consumes keyCodes.
KEYS: dict[str, tuple[int, int]] = {
    "escape": (27, 0x01),
    "enter": (13, 0x1C),
    "alt": (18, 0x38),
    "space": (32, 0x39),
    "left": (37, 0x4B),
    "up": (38, 0x48),
    "right": (39, 0x4D),
    "down": (40, 0x50),
    "f1": (112, 0x3B),
    "f2": (113, 0x3C),
    "f7": (118, 0x41),
    "f9": (120, 0x43),
}


class ScenarioError(ValueError):
    pass


@dataclass(frozen=True)
class Event:
    sequence: int
    clock: str
    value: int | str
    action: str
    payload: dict[str, Any]
    resolved_tick: int | None = None
    breakpoint_offset: int = 0

    @property
    def pit_tick(self) -> int:
        value = self.resolved_tick if self.resolved_tick is not None else self.value
        if not isinstance(value, int):
            raise ScenarioError(f"event {self.sequence} has a non-integer tick")
        return value


@dataclass(frozen=True)
class Scenario:
    name: str
    events: tuple[Event, ...]
    setup: dict[str, Any]
    breakpoints: dict[str, int]
    comparison: dict[str, Any]
    source: Path | None = None

    def checkpoint_names(self) -> list[str]:
        return [str(e.payload["name"]) for e in self.events
                if e.action == "checkpoint"]


def _integer(value: Any, label: str, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise ScenarioError(f"{label} must be an integer >= {minimum}")
    return value


def load_scenario(path: str | Path) -> Scenario:
    source = Path(path).resolve()
    try:
        document = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ScenarioError(f"cannot read scenario {source}: {exc}") from exc
    return parse_scenario(document, source)


def parse_scenario(document: Any, source: Path | None = None) -> Scenario:
    if not isinstance(document, dict):
        raise ScenarioError("scenario root must be an object")
    if document.get("format") != FORMAT:
        raise ScenarioError(f"scenario format must be {FORMAT!r}")
    name = document.get("name")
    if not isinstance(name, str) or not name.strip():
        raise ScenarioError("scenario name must be a non-empty string")
    raw_events = document.get("events")
    if not isinstance(raw_events, list) or not raw_events:
        raise ScenarioError("scenario events must be a non-empty array")

    raw_breakpoints = document.get("breakpoints", {})
    if not isinstance(raw_breakpoints, dict):
        raise ScenarioError("scenario breakpoints must be an object")
    breakpoints: dict[str, int] = {}
    for breakpoint, tick in raw_breakpoints.items():
        if not isinstance(breakpoint, str) or not breakpoint:
            raise ScenarioError("breakpoint names must be non-empty strings")
        breakpoints[breakpoint] = _integer(
            tick, f"breakpoint {breakpoint!r} tick")

    setup = document.get("setup", {})
    if not isinstance(setup, dict):
        raise ScenarioError("scenario setup must be an object")
    if set(setup) - {"save", "patches"}:
        raise ScenarioError("scenario setup contains unsupported fields")
    if "save" in setup and (not isinstance(setup["save"], str) or
                            not setup["save"]):
        raise ScenarioError("scenario setup save must be a non-empty path")
    patches = setup.get("patches", {})
    if not isinstance(patches, dict):
        raise ScenarioError("scenario setup patches must be an object")
    if patches and "save" not in setup:
        raise ScenarioError("scenario setup patches require a save")
    for offset, byte in patches.items():
        try:
            parsed_offset = int(offset, 0)
        except (TypeError, ValueError) as exc:
            raise ScenarioError(f"invalid setup patch offset {offset!r}") from exc
        if not 0 <= parsed_offset < 0x100:
            raise ScenarioError(f"setup patch offset is outside the save: {offset}")
        _integer(byte, f"setup patch {offset}")
        if byte > 0xFF:
            raise ScenarioError(f"setup patch byte is out of range: {offset}")

    comparison = document.get("comparison", {})
    if not isinstance(comparison, dict):
        raise ScenarioError("scenario comparison policy must be an object")
    if set(comparison) - {"stopOnFirstDivergence", "tickTolerance"}:
        raise ScenarioError("scenario comparison policy contains unsupported fields")
    stop_on_first = comparison.get("stopOnFirstDivergence", True)
    if not isinstance(stop_on_first, bool):
        raise ScenarioError("stopOnFirstDivergence must be boolean")
    tick_tolerance = _integer(
        comparison.get("tickTolerance", 0), "comparison tickTolerance")
    comparison = {
        "stopOnFirstDivergence": stop_on_first,
        "tickTolerance": tick_tolerance,
    }

    events: list[Event] = []
    cursor = 0
    held: set[str] = set()
    joystick_held = False
    checkpoints: set[str] = set()
    for sequence, raw in enumerate(raw_events):
        if not isinstance(raw, dict):
            raise ScenarioError(f"event {sequence} must be an object")
        action = raw.get("action")
        if action not in ACTIONS:
            raise ScenarioError(f"event {sequence} has unknown action {action!r}")
        if action == "wait":
            ticks = _integer(raw.get("ticks"), f"event {sequence} wait ticks", 1)
            cursor += ticks
            continue

        when = raw.get("when", {"clock": "pit_tick", "value": cursor})
        if not isinstance(when, dict) or when.get("clock") not in CLOCKS:
            raise ScenarioError(f"event {sequence} has an invalid clock")
        clock = str(when["clock"])
        value: int | str
        resolved_tick = None
        breakpoint_offset = 0
        if clock == "breakpoint":
            value = when.get("value")
            if not isinstance(value, str) or not value:
                raise ScenarioError(
                    f"event {sequence} breakpoint must be a non-empty name")
            if value not in breakpoints:
                raise ScenarioError(
                    f"event {sequence} references unknown breakpoint {value!r}")
            breakpoint_offset = _integer(
                when.get("offset", 0), f"event {sequence} breakpoint offset")
            resolved_tick = breakpoints[value] + breakpoint_offset
            if resolved_tick < cursor:
                raise ScenarioError(
                    f"event {sequence} moves backward from tick {cursor} "
                    f"to breakpoint {value!r} ({resolved_tick})")
            cursor = resolved_tick
        else:
            value = _integer(when.get("value"), f"event {sequence} time")
            if clock == "frame":
                # Current MCGA parity scenarios define one frame boundary per
                # timer interrupt. Keeping the clock label preserves intent.
                value = int(value)
            if value < cursor:
                raise ScenarioError(
                    f"event {sequence} moves backward from tick {cursor} to {value}")
            cursor = int(value)

        payload = {k: v for k, v in raw.items()
                   if k not in {"action", "when"}}
        if action in {"key_down", "key_up"}:
            key = payload.get("key")
            if not isinstance(key, str) or key.lower() not in KEYS:
                raise ScenarioError(f"event {sequence} has unsupported key {key!r}")
            key = key.lower()
            payload["key"] = key
            if action == "key_down":
                if key in held:
                    raise ScenarioError(
                        f"event {sequence} duplicates held key {key!r}")
                held.add(key)
            else:
                if key not in held:
                    raise ScenarioError(
                        f"event {sequence} releases unheld key {key!r}")
                held.remove(key)
        elif action == "text_key":
            text = payload.get("text")
            if not isinstance(text, str) or len(text) != 1 or ord(text) > 127:
                raise ScenarioError(f"event {sequence} text must be one ASCII character")
        elif action == "joystick":
            for field in ("directions", "buttons"):
                payload[field] = _integer(
                    payload.get(field, 0), f"event {sequence} {field}")
            if payload["directions"] > 0x0F or payload["buttons"] > 0xFF:
                raise ScenarioError(f"event {sequence} joystick mask is out of range")
            joystick_held = bool(payload["directions"] or payload["buttons"])
        elif action == "assert":
            expected = payload.get("expected")
            if not isinstance(expected, dict) or not expected:
                raise ScenarioError(f"event {sequence} assertion is empty")
        elif action == "checkpoint":
            checkpoint = payload.get("name")
            if not isinstance(checkpoint, str) or not checkpoint:
                raise ScenarioError(f"event {sequence} checkpoint needs a name")
            if checkpoint in checkpoints:
                raise ScenarioError(f"duplicate checkpoint {checkpoint!r}")
            checkpoints.add(checkpoint)

        events.append(Event(sequence, clock, value, action, payload,
                            resolved_tick, breakpoint_offset))

    if held:
        raise ScenarioError("scenario ends with stuck keys: " + ", ".join(sorted(held)))
    if joystick_held:
        raise ScenarioError("scenario ends with stuck joystick state")
    if not checkpoints:
        raise ScenarioError("scenario must contain at least one checkpoint")
    return Scenario(name.strip(), tuple(events), dict(setup), breakpoints,
                    comparison, source)


def canonical_document(scenario: Scenario) -> dict[str, Any]:
    return {
        "format": FORMAT,
        "name": scenario.name,
        **({"setup": scenario.setup} if scenario.setup else {}),
        **({"breakpoints": scenario.breakpoints}
           if scenario.breakpoints else {}),
        "comparison": scenario.comparison,
        "events": [
            {
                "sequence": event.sequence,
                "when": {
                    "clock": event.clock,
                    "value": event.value,
                    **({"offset": event.breakpoint_offset}
                       if event.breakpoint_offset else {}),
                    **({"resolvedTick": event.resolved_tick}
                       if event.resolved_tick is not None else {}),
                },
                "action": event.action,
                **event.payload,
            }
            for event in scenario.events
        ],
    }


def scenario_sha256(scenario: Scenario) -> str:
    encoded = json.dumps(canonical_document(scenario), sort_keys=True,
                         separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest().upper()


def dos_scancode_events(scenario: Scenario,
                        stop_checkpoint: str) -> Iterable[tuple[int, int]]:
    """Yield (tick, scan code), stopping at a checkpoint marker (-1).

    Assertions remain host-side; text and joystick input require the WASM
    adapter or a future joystick port probe and are rejected explicitly.
    """
    found = False
    for event in scenario.events:
        tick = event.pit_tick
        if event.action in {"key_down", "key_up"}:
            scan = KEYS[event.payload["key"]][1]
            if event.action == "key_up":
                scan |= 0x80
            yield tick, scan
        elif event.action == "checkpoint":
            if event.payload["name"] == stop_checkpoint:
                yield tick, -1
                found = True
                break
        elif event.action in {"text_key", "joystick"}:
            raise ScenarioError(
                f"DOS adapter does not support {event.action!r} at event "
                f"{event.sequence}")
    if not found:
        raise ScenarioError(f"checkpoint {stop_checkpoint!r} does not exist")


def _main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("scenario", type=Path)
    parser.add_argument("--canonical", action="store_true")
    args = parser.parse_args()
    scenario = load_scenario(args.scenario)
    result = canonical_document(scenario) if args.canonical else {
        "status": "valid",
        "name": scenario.name,
        "events": len(scenario.events),
        "checkpoints": scenario.checkpoint_names(),
        "sha256": scenario_sha256(scenario),
    }
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
