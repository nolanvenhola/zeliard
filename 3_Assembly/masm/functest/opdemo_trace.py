#!/usr/bin/env python3
"""Export a deterministic service-call trace from the real MASM OPDMO bytes.

Version 1 is intentionally segmented: it stitches exact executions of the
existing trusted OPDMO oracle checkpoints. Segment boundaries are explicit in
the JSON so they cannot be mistaken for a continuous full-frame trace.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE / "proc_equivalence"))

import test_opdemo_opening_sequence as opdmo  # noqa: E402
from harness import CODE_SEG  # noqa: E402


REGISTER_NAMES = ("ax", "bx", "cx", "dx", "si", "di", "ds", "es")


def normalized_regs(raw: dict[str, int]) -> dict[str, str]:
    return {name: f"{raw[name] & 0xFFFF:04X}" for name in REGISTER_NAMES}


def append_stub_events(events: list[dict], checkpoint: str, result: dict,
                       services: dict[int, str], harness=None,
                       named_only: bool = False) -> None:
    for index, raw in enumerate(result.get("stub_regs", [])):
        service = services.get(raw["ip"])
        if service is None and named_only:
            continue
        if service is None:
            service = f"stub_{raw['ip']:04X}"
        event = {
            "checkpoint": checkpoint,
            "index": index,
            "service": service,
            "regs": normalized_regs(raw),
        }
        if service == "sar_load" and harness is not None:
            event["asset"] = opdmo.read_ref_name(harness, raw["si"])
        events.append(event)


def run_segment(name: str, harness, stubs: dict[int, dict], start: int,
                regs: dict[str, int], max_steps: int,
                services: dict[int, str], named_only: bool = False) -> tuple[dict, list[dict]]:
    result = harness.call_function(start, regs=regs, stub_calls=stubs,
                                   max_steps=max_steps)
    if result["stopped_reason"] != "returned_to_sentinel":
        raise RuntimeError(
            f"{name} did not complete: {result['stopped_reason']} "
            f"after {result['instructions']} instructions"
        )
    events: list[dict] = []
    append_stub_events(events, name, result, services, harness, named_only)
    event_hash = hashlib.sha256(
        json.dumps(events, sort_keys=True, separators=(",", ":")).encode("utf-8")
    ).hexdigest()
    segment = {
        "name": name,
        "entry_ip": f"{start:04X}",
        "stop_reason": result["stopped_reason"],
        "instruction_count": result["instructions"],
        "final_regs": {
            key: f"{value & 0xFFFF:04X}"
            for key, value in result["regs_after"].items()
        },
        "event_count": len(events),
        "event_sha256": event_hash,
        "final_state": {
            "scene_mode": f"{opdmo.read_code_byte(harness, opdmo.OFF_SCENE_MODE):02X}",
            "spacebar_state": f"{opdmo.read_code_byte(harness, opdmo.OFF_SPACEBAR_STATE):02X}",
            "enter_key": f"{opdmo.read_code_byte(harness, opdmo.OFF_ENTER_KEY):02X}",
            "frame_timer": f"{opdmo.read_code_byte(harness, opdmo.OFF_FRAME_TIMER):02X}",
            "enable_all": f"{opdmo.read_code_byte(harness, opdmo.OFF_ENABLE_ALL):02X}",
        },
    }
    return segment, events


def export_trace() -> dict:
    segments: list[dict] = []
    events: list[dict] = []

    direct = {
        opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", name) - opdmo.HEADER_SIZE: name
        for name in opdmo.DIRECT_CALLS
    }
    common = {
        opdmo.SAR_THUNK: "sar_load",
        opdmo.GFX_INIT_THUNK: "gfx_init",
        opdmo.NARRATION_STONE_THUNK: "narration_stone",
        opdmo.GFX_DRAW_THUNK: "gfx_draw",
        opdmo.GFX_UPDATE_THUNK: "gfx_update",
        opdmo.GFX_MODE_THUNK: "gfx_mode",
        opdmo.GFX_PALETTE_THUNK: "gfx_palette",
        opdmo.DISP_GAME_THUNK: "disp_game",
        opdmo.DISP_DATA_6F59_THUNK: "disp_data_6f59",
        opdmo.DISP_NARR_CHAP2_THUNK: "disp_narr_chap2",
        opdmo.DISP_NARR_CHAP3_THUNK: "disp_narr_chap3",
        **direct,
    }

    specs = []
    h, stubs = opdmo.setup_harness()
    specs.append(("initial_visual_pipeline", h, stubs, opdmo.LOAD_BASE,
                  {"ds": CODE_SEG, "es": CODE_SEG, "si": 0, "bx": 6}, 2000, common))

    h, stubs = opdmo.setup_animate_scanline_harness()
    specs.append(("ancient_prologue_scanline", h, stubs, opdmo.ANIMATE_SCANLINE_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100000, {
                      opdmo.ANIM_FN_WIPE_THUNK: "anim_wipe",
                      opdmo.ANIM_FN_FADE_THUNK: "anim_fade",
                      opdmo.ANIM_FN_DRAW_THUNK: "anim_draw",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "timer_wait_loop")
                      - opdmo.HEADER_SIZE: "timer_wait",
                  }))

    h, stubs = opdmo.setup_sprite_c_harness()
    specs.append(("demon_sprite_c", h, stubs, opdmo.STOP_BEFORE_SPRITE_LOOP,
                  {"ds": CODE_SEG, "es": CODE_SEG, "si": opdmo.SCENE_SPRITE_C}, 500, {
                      opdmo.DISP_NARR_CHAP2_THUNK: "disp_narr_chap2",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "timer_wait_loop")
                      - opdmo.HEADER_SIZE: "timer_wait",
                  }))

    h, stubs = opdmo.setup_scene_after_anim_harness()
    specs.append(("demon_text_and_exit", h, stubs, opdmo.SCENE_AFTER_ANIM,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 10000, {
                      opdmo.DISP_NARR_CHAP2_THUNK: "disp_narr_chap2",
                      opdmo.DISP_CHAP2_CALL_THUNK: "disp_chap2_call",
                      opdmo.DISP_NARR_CHAP4_THUNK: "disp_narr_chap4",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "timer_wait_loop")
                      - opdmo.HEADER_SIZE: "timer_wait",
                  }))

    h, stubs = opdmo.setup_title_asset_harness()
    specs.append(("title_asset_reload", h, stubs, opdmo.TITLE_ASSET_BLOCK_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.JASHIIN_SPEECH_THUNK: "jashiin_speech",
                      opdmo.GFX_MODE_THUNK: "gfx_mode",
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decode_rle_to_es_di")
                      - opdmo.HEADER_SIZE: "decode_rle_to_es_di",
                  }))

    h, stubs = opdmo.setup_title_display_handoff_harness()
    specs.append(("title_display_handoff", h, stubs, opdmo.TITLE_DISPLAY_HANDOFF_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.DISP_DRV_SEG_3_THUNK: "disp_drv_seg_3",
                      opdmo.GFX_UPDATE_THUNK: "gfx_update",
                      opdmo.DISP_NARR_CHAP3_THUNK: "disp_narr_chap3",
                      opdmo.DISP_NARR_OPEN_THUNK: "disp_narr_open",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "timer_wait_loop")
                      - opdmo.HEADER_SIZE: "timer_wait",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decode_rle_to_es_di")
                      - opdmo.HEADER_SIZE: "decode_rle_to_es_di",
                  }))

    h, stubs = opdmo.setup_title_color_rotate_harness()
    specs.append(("title_color_rotation", h, stubs, opdmo.COLOR_ROTATE_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 3000, {
                      opdmo.DISP_SET_DRV_SEG_THUNK: "disp_set_drv_seg",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "timer_wait_loop")
                      - opdmo.HEADER_SIZE: "timer_wait",
                  }))

    h, stubs = opdmo.setup_timer_exit_harness()
    specs.append(("opening_next_scene", h, stubs, opdmo.OPENING_NEXT_SCENE_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.GFX_INIT_THUNK: "gfx_init",
                      opdmo.GFX_MODE_THUNK: "gfx_mode",
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "credits_scroll_display")
                      - opdmo.HEADER_SIZE: "credits_scroll_display",
                  }))

    h, stubs = opdmo.setup_credits_scroll_harness()
    specs.append(("credits_scroll", h, stubs,
                  opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "credits_scroll_display")
                  - opdmo.HEADER_SIZE,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 500000, {
                      opdmo.ANIM_FN_WIPE_THUNK: "anim_wipe",
                      opdmo.ANIM_FN_FADE_THUNK: "anim_fade",
                      opdmo.ANIM_FN_DRAW_THUNK: "anim_draw",
                  }))

    h, stubs = opdmo.setup_trans_exit_harness()
    specs.append(("trans_exit_to_story", h, stubs, opdmo.TRANS_EXIT_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 200, {
                      opdmo.GFX_INIT_THUNK: "gfx_init",
                  }))

    h, stubs = opdmo.setup_post_title_story_harness()
    specs.append(("post_title_story_setup", h, stubs, opdmo.POST_TITLE_STORY_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
                      - opdmo.HEADER_SIZE: "decompress_image",
                  }))

    h, stubs = opdmo.setup_first_story_script_harness()
    specs.append(("post_title_story_script_1", h, stubs,
                  opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "run_script_interpreter")
                  - opdmo.HEADER_SIZE,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100000, {
                      opdmo.JASHIIN_SPEECH_THUNK: "jashiin_speech",
                      opdmo.DISP_NARR_CHAP4_THUNK: "disp_narr_chap4",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
                      - opdmo.HEADER_SIZE: "story_timer_wait",
                  }))

    h, stubs = opdmo.setup_story_1_to_2_harness()
    specs.append(("post_title_hime_transition", h, stubs, opdmo.STORY_1_TO_2_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
                      - opdmo.HEADER_SIZE: "decompress_image",
                  }))

    h, stubs = opdmo.setup_second_story_script_harness()
    specs.append(("post_title_story_script_2", h, stubs,
                  opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "run_script_interpreter")
                  - opdmo.HEADER_SIZE,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100000, {
                      opdmo.JASHIIN_SPEECH_THUNK: "jashiin_speech",
                      opdmo.DISP_NARR_CHAP4_THUNK: "disp_narr_chap4",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
                      - opdmo.HEADER_SIZE: "story_timer_wait",
                  }))

    h, stubs = opdmo.setup_story_2_to_3_harness()
    specs.append(("post_title_dmaou_transition", h, stubs, opdmo.STORY_2_TO_3_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.DISP_FONT_INV_THUNK: "disp_font_inv",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
                      - opdmo.HEADER_SIZE: "decompress_image",
                  }))

    h, stubs = opdmo.setup_third_story_script_harness()
    specs.append(("post_title_story_script_3", h, stubs,
                  opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "run_script_interpreter")
                  - opdmo.HEADER_SIZE,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100000, {
                      opdmo.JASHIIN_SPEECH_THUNK: "jashiin_speech",
                      opdmo.DISP_NARR_CHAP4_THUNK: "disp_narr_chap4",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
                      - opdmo.HEADER_SIZE: "story_timer_wait",
                  }))

    for number, setup in (
        (4, opdmo.setup_fourth_story_script_harness),
        (5, opdmo.setup_fifth_story_script_harness),
        (6, opdmo.setup_sixth_story_script_harness),
        (7, opdmo.setup_seventh_story_script_harness),
        (8, opdmo.setup_eighth_story_script_harness),
        (9, opdmo.setup_ninth_story_script_harness),
        (10, opdmo.setup_tenth_story_script_harness),
        (11, opdmo.setup_eleventh_story_script_harness),
        (12, opdmo.setup_twelfth_story_script_harness),
        (13, opdmo.setup_thirteenth_story_script_harness),
        (14, opdmo.setup_fourteenth_story_script_harness),
        (15, opdmo.setup_fifteenth_story_script_harness),
        (16, opdmo.setup_sixteenth_story_script_harness),
        (17, opdmo.setup_seventeenth_story_script_harness),
        (18, opdmo.setup_eighteenth_story_script_harness),
        (19, opdmo.setup_nineteenth_story_script_harness),
        (20, opdmo.setup_twentieth_story_script_harness),
    ):
        h, stubs = setup()
        specs.append((f"post_title_story_script_{number}", h, stubs,
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "run_script_interpreter")
                      - opdmo.HEADER_SIZE,
                      {"ds": CODE_SEG, "es": CODE_SEG}, 100000, {
                          opdmo.JASHIIN_SPEECH_THUNK: "jashiin_speech",
                          opdmo.DISP_NARR_CHAP4_THUNK: "disp_narr_chap4",
                          opdmo.DISP_GAME_THUNK: "disp_game",
                          opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
                          - opdmo.HEADER_SIZE: "story_timer_wait",
                      }))

    h, stubs = opdmo.setup_apparition_overlay_harness()
    specs.append(("post_title_apparition_overlay", h, stubs,
                  opdmo.APPARITION_OVERLAY_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100, {
                      opdmo.DISP_DATA_7420_THUNK: "disp_data_7420",
                  }))

    h, stubs = opdmo.setup_apparition_remove_isi_harness()
    specs.append(("post_title_apparition_remove_isi", h, stubs,
                  opdmo.APPARITION_REMOVE_ISI_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 1000, {
                      opdmo.SAR_THUNK: "sar_load",
                      opdmo.DISP_GAME_THUNK: "disp_game",
                      opdmo.GFX_MODE_THUNK: "gfx_mode",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "busy_wait_delay")
                      - opdmo.HEADER_SIZE: "busy_wait",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
                      - opdmo.HEADER_SIZE: "story_timer_wait",
                      opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
                      - opdmo.HEADER_SIZE: "decompress_image",
                  }))

    h, stubs = opdmo.setup_isi_reveal_harness()
    specs.append(("post_title_isi_reveal", h, stubs, opdmo.ISI_REVEAL_START,
                  {"ds": CODE_SEG, "es": CODE_SEG}, 100, {
                      opdmo.GFX_PALETTE_THUNK: "gfx_palette",
                      opdmo.GFX_UPDATE_THUNK: "gfx_update",
                  }))

    for checkpoint, setup, start, services in (
        ("post_title_yuu_setup", opdmo.setup_yuu_transition_harness,
         opdmo.YUU_SETUP_START, {
             opdmo.SAR_THUNK: "sar_load",
             opdmo.GFX_UPDATE_THUNK: "gfx_update",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
             - opdmo.HEADER_SIZE: "decompress_image",
         }),
        ("post_title_yuu_split", opdmo.setup_yuu_split_harness,
         opdmo.YUU_SPLIT_START, {
             opdmo.DISP_FONT_INV_THUNK: "disp_font_inv",
             opdmo.GFX_PALETTE_THUNK: "gfx_palette",
             opdmo.DISP_LOAD_SETUP_THUNK: "disp_load_setup",
             opdmo.DISP_GAME_THUNK: "disp_game",
         }),
        ("post_title_maop_setup", opdmo.setup_maop_transition_harness,
         opdmo.MAOP_SETUP_START, {
             opdmo.SAR_THUNK: "sar_load",
             opdmo.DISP_FONT_INV_THUNK: "disp_font_inv",
             opdmo.GFX_PALETTE_THUNK: "gfx_palette",
             opdmo.DISP_LOAD_SETUP_THUNK: "disp_load_setup",
             opdmo.DISP_SCRIPT_AREA_THUNK: "disp_script_area",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
             - opdmo.HEADER_SIZE: "decompress_image",
         }),
        ("post_title_yuu2_setup", opdmo.setup_yuu2_transition_harness,
         opdmo.YUU2_SETUP_START, {
             opdmo.DISP_FONT_INV_THUNK: "disp_font_inv",
             opdmo.GFX_PALETTE_THUNK: "gfx_palette",
             opdmo.SAR_THUNK: "sar_load",
             opdmo.DISP_GAME_THUNK: "disp_game",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
             - opdmo.HEADER_SIZE: "decompress_image",
         }),
        ("post_title_final_scene", opdmo.setup_final_scene_harness,
         opdmo.FINAL_SCENE_START, {
             opdmo.SAR_THUNK: "sar_load",
             opdmo.GFX_MODE_THUNK: "gfx_mode",
             opdmo.GFX_UPDATE_THUNK: "gfx_update",
             opdmo.GFX_DRAW_THUNK: "gfx_draw",
             opdmo.GFX_PALETTE_THUNK: "gfx_palette",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "decompress_image")
             - opdmo.HEADER_SIZE: "decompress_image",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "merge_gfx_planes")
             - opdmo.HEADER_SIZE: "merge_gfx_planes",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "xor_mask_render")
             - opdmo.HEADER_SIZE: "xor_mask_render",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "wait_story_scene_timer")
             - opdmo.HEADER_SIZE: "story_timer_wait",
             opdmo.LOAD_BASE + opdmo.resolve_proc("opdmo", "animate_scanline_alt")
             - opdmo.HEADER_SIZE: "animate_scanline_alt",
         }),
    ):
        h, stubs = setup()
        specs.append((checkpoint, h, stubs, start,
                      {"ds": CODE_SEG, "es": CODE_SEG}, 5000, services))

    for spec in specs:
        segment, segment_events = run_segment(*spec)
        segments.append(segment)
        events.extend(segment_events)

    source_path = opdmo.OPDEMO_BIN
    return {
        "schema": "zeliard.opdemo.service_trace.v1",
        "capture_mode": "segmented_reference_v1",
        "source": "3_Assembly/masm/bin/zelres1/100OPDMO.bin",
        "source_sha256": hashlib.sha256(source_path.read_bytes()).hexdigest(),
        "source_load_base": "6000",
        "limitations": [
            "Exact MASM execution within each segment.",
            "External graphics, SAR, timer, and driver services are recorded and modeled.",
            "The credits anim_fade service consumes one CR/FF-terminated table entry per call.",
            "Segment boundaries are not yet continuous execution boundaries.",
            "Framebuffer and palette frame hashes are not yet captured.",
        ],
        "segments": segments,
        "events": events,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", type=Path)
    args = parser.parse_args()
    trace = export_trace()
    encoded = json.dumps(trace, indent=2) + "\n"

    if args.check:
        expected = args.check.read_text(encoding="utf-8")
        if encoded != expected:
            print(f"VERDICT: FAIL: trace differs from {args.check}")
            return 1
        print(f"VERDICT: PASS: trace matches {args.check}")
        return 0

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
        print(f"wrote {args.output}: {len(trace['events'])} events")
    else:
        print(encoded, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
