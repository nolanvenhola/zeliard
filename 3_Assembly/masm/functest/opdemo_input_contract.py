#!/usr/bin/env python3
"""Export deterministic input-routing outcomes from the real MASM OPDMO bytes."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE / "proc_equivalence"))

import test_opdemo_opening_sequence as opdmo  # noqa: E402
from fixtures import resolve_proc  # noqa: E402
from harness import CODE_SEG, RET_SENTINEL, TasmHarness  # noqa: E402


ENTER_KEY = 0x0D
TRANSITION_OUT_TO_GAME = opdmo.LOAD_BASE + 0x0A45 - opdmo.HEADER_SIZE


def proc(name: str) -> int:
    return opdmo.LOAD_BASE + resolve_proc("opdmo", name) - opdmo.HEADER_SIZE


def base_harness() -> TasmHarness:
    h = TasmHarness(str(opdmo.OPDEMO_BIN), opdmo.LOAD_BASE)
    opdmo.load_opdemo_with_header_strip(h)
    return h


def state(h: TasmHarness) -> dict[str, str]:
    return {
        "scene_mode": f"{opdmo.read_code_byte(h, opdmo.OFF_SCENE_MODE):02X}",
        "spacebar_state": f"{opdmo.read_code_byte(h, opdmo.OFF_SPACEBAR_STATE):02X}",
        "enter_key": f"{opdmo.read_code_byte(h, opdmo.OFF_ENTER_KEY):02X}",
        "frame_timer": f"{opdmo.read_code_byte(h, opdmo.OFF_FRAME_TIMER):02X}",
    }


def run_jump_case(name: str, entry: int, target: int, space: int, enter: int) -> dict:
    h = base_harness()
    h.write_code(target, opdmo.near_jmp_bytes(target, RET_SENTINEL))
    h.write_code(opdmo.OFF_SPACEBAR_STATE, [space])
    h.write_code(opdmo.OFF_ENTER_KEY, [enter])
    result = h.call_function(entry, regs={"ds": CODE_SEG, "es": CODE_SEG}, max_steps=100)
    if result["stopped_reason"] != "returned_to_sentinel":
        raise RuntimeError(f"{name} did not reach expected target: {result['stopped_reason']}")
    return {
        "name": name,
        "outcome": f"jump_{target:04X}",
        "instruction_count": result["instructions"],
        "final_state": state(h),
    }


def run_timer_complete() -> dict:
    h = base_harness()
    h.write_code(proc("interrupt_handler_cascade"), [0xC3])
    h.write_code(opdmo.OFF_SPACEBAR_STATE, [0])
    h.write_code(opdmo.OFF_ENTER_KEY, [0])
    h.write_code(opdmo.OFF_FRAME_TIMER, [0x20])
    result = h.call_function(proc("timer_wait_loop"), regs={"ax": 0x14, "ds": CODE_SEG},
                             max_steps=100)
    if result["stopped_reason"] != "returned_to_sentinel":
        raise RuntimeError(f"timer completion failed: {result['stopped_reason']}")
    return {
        "name": "timer_wait_elapsed",
        "outcome": "return",
        "instruction_count": result["instructions"],
        "final_state": state(h),
    }


def export_contract() -> dict:
    timer = proc("timer_wait_loop")
    transition_wait = proc("scene_transition_wait")
    story_input = proc("story_scene_input_handler")
    transition_game = TRANSITION_OUT_TO_GAME
    cases = [
        run_jump_case("timer_wait_space", timer, opdmo.OPENING_NEXT_SCENE_START, 1, 0),
        run_jump_case("timer_wait_enter", timer, opdmo.OPENING_NEXT_SCENE_START, 0, ENTER_KEY),
        run_timer_complete(),
        run_jump_case("credits_wait_space", transition_wait, opdmo.TRANS_EXIT_START, 1, 0),
        run_jump_case("credits_wait_enter", transition_wait, opdmo.TRANS_EXIT_START, 0, ENTER_KEY),
        run_jump_case("story_input_space", story_input, transition_game, 1, 0),
        run_jump_case("story_input_enter", story_input, transition_game, 0, ENTER_KEY),
    ]
    return {
        "schema": "zeliard.opdemo.input_contract.v1",
        "source": "3_Assembly/masm/bin/zelres1/100OPDMO.bin",
        "cases": cases,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", type=Path)
    args = parser.parse_args()
    encoded = json.dumps(export_contract(), indent=2) + "\n"
    if args.check:
        if encoded != args.check.read_text(encoding="utf-8"):
            print(f"VERDICT: FAIL: input contract differs from {args.check}")
            return 1
        print(f"VERDICT: PASS: input contract matches {args.check}")
        return 0
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
        print(f"wrote {args.output}")
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
