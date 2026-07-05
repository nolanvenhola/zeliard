#!/usr/bin/env python3
"""Oracle for 100OPDMO run_opening_demo_main's first visual sequence.

The full opening demo contains timers, sprite scripts, palette fades, text
bytecode, and the final transition back into game.bin.  This probe runs the
real MASM-built opdemo bytes through the first title/castle setup sequence and
the DMAOU visual setup, with external graphics/SAR services stubbed, then stops
just before the sprite animation loop.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent))

from fixtures import MASM_ROOT, resolve_proc  # noqa: E402
from harness import CODE_SEG, RET_SENTINEL, TasmHarness  # noqa: E402


OPDEMO_BIN = MASM_ROOT / "bin" / "zelres1" / "100OPDMO.bin"
LOAD_BASE = 0x6000
HEADER_SIZE = 4

SAR_LOADER_SLOT = 0x010C
GFX_INIT_SLOT = 0x2042
NARRATION_STONE_SLOT = 0x202A
GFX_DRAW_SLOT = 0x3002
GFX_UPDATE_SLOT = 0x3004
GFX_MODE_SLOT = 0x3006
GFX_PALETTE_SLOT = 0x3008
ANIM_FN_WIPE_SLOT = 0x300A
ANIM_FN_FADE_SLOT = 0x300C
ANIM_FN_DRAW_SLOT = 0x300E
DISP_GAME_SLOT = 0x3010
DISP_DATA_6F59_SLOT = 0x3012
DISP_NARR_CHAP2_SLOT = 0x3014
DISP_CHAP2_CALL_SLOT = 0x3016
DISP_DRV_SEG_3_SLOT = 0x3018
DISP_NARR_CHAP3_SLOT = 0x301A
DISP_NARR_OPEN_SLOT = 0x301C
DISP_SET_DRV_SEG_SLOT = 0x301E
DISP_NARR_CHAP4_SLOT = 0x3030
DISP_FONT_INV_SLOT = 0x3020
DISP_DATA_7420_SLOT = 0x3022
DISP_LOAD_SETUP_SLOT = 0x3024
DISP_SCRIPT_AREA_SLOT = 0x3026
JASHIIN_SPEECH_SLOT = 0x2000
STICK_EXIT_DLG_SLOT = 0x0110
STICK_PAUSE_DLG_SLOT = 0x0112
STICK_JOY_CAL_SLOT = 0x0116
STICK_JOY_DETECT_SLOT = 0x0118

SAR_THUNK = 0x0200
GFX_INIT_THUNK = 0x0202
NARRATION_STONE_THUNK = 0x0204
GFX_DRAW_THUNK = 0x0206
GFX_UPDATE_THUNK = 0x0208
GFX_MODE_THUNK = 0x020A
GFX_PALETTE_THUNK = 0x020C
ANIM_FN_WIPE_THUNK = 0x020E
ANIM_FN_FADE_THUNK = 0x0210
ANIM_FN_DRAW_THUNK = 0x0212
DISP_GAME_THUNK = 0x0214
DISP_DATA_6F59_THUNK = 0x0216
DISP_NARR_CHAP3_THUNK = 0x0218
DISP_NARR_CHAP2_THUNK = 0x021A
DISP_CHAP2_CALL_THUNK = 0x021C
DISP_NARR_CHAP4_THUNK = 0x021E
JASHIIN_SPEECH_THUNK = 0x0220
DISP_DRV_SEG_3_THUNK = 0x0222
DISP_NARR_OPEN_THUNK = 0x0224
DISP_SET_DRV_SEG_THUNK = 0x0226
STICK_EXIT_DLG_THUNK = 0x0228
STICK_PAUSE_DLG_THUNK = 0x022A
STICK_JOY_CAL_THUNK = 0x022C
STICK_JOY_DETECT_THUNK = 0x022E
DISP_FONT_INV_THUNK = 0x0230
DISP_DATA_7420_THUNK = 0x0232
DISP_LOAD_SETUP_THUNK = 0x0234
DISP_SCRIPT_AREA_THUNK = 0x0236

OFF_GAME_SEG = 0xFF2C
OFF_SCENE_MODE = 0xFF24
OFF_SPACEBAR_STATE = 0xFF1D
OFF_ENTER_KEY = 0xFF29
OFF_VOLUME_B = 0xFF75
OFF_FRAME_TIMER = 0xFF1A
OFF_ENABLE_ALL = 0xFF26
OFF_SCRIPT_PC = 0x6D56

STOP_BEFORE_SPRITE_LOOP = 0x6154
SCENE_AFTER_ANIM = 0x6171
STOP_AFTER_SCENE_SPRITE_C = 0x6171
STOP_BEFORE_JASHIIN_SPEECH = 0x61BB
TITLE_ASSET_BLOCK_START = 0x61B3
STOP_AFTER_TITLE_ASSET_LOADS = 0x621E
TITLE_INT60_START = 0x621E
TITLE_INT60_ADDR = 0x622E
TITLE_DISPLAY_HANDOFF_START = 0x621E
STOP_BEFORE_COLOR_ROTATE = 0x629B
COLOR_ROTATE_START = 0x629B
STOP_AFTER_COLOR_ROTATE = 0x62C4
WAIT_GFX_ENABLED_START = 0x62C4
OPENING_NEXT_SCENE_START = 0x63E5
TIMER_EXIT_INT60_ADDR = 0x643A
TRANS_EXIT_START = 0x6477
POST_TITLE_STORY_START = 0x6540
POST_TITLE_FIRST_SCRIPT_CALL = 0x65C4
NARRATION_PROLOGUE_ENTRY = 0x79C6
STORY_1_TO_2_START = 0x65C7
POST_TITLE_SECOND_SCRIPT_CALL = 0x65FF
STORY_SCRIPT_2_ENTRY = 0x7CAD
STORY_2_TO_3_START = 0x6602
POST_TITLE_THIRD_SCRIPT_CALL = 0x6641
STORY_SCRIPT_3_ENTRY = 0x7DDF
STORY_SCRIPT_4_ENTRY = 0x7E8D
STORY_SCRIPT_5_ENTRY = 0x7F78
STORY_SCRIPT_6_ENTRY = 0x7F79
STORY_SCRIPT_7_ENTRY = 0x8016
STORY_SCRIPT_8_ENTRY = 0x8071
STORY_SCRIPT_9_ENTRY = 0x8075
STORY_SCRIPT_10_ENTRY = 0x8136
STORY_SCRIPT_11_ENTRY = 0x81D8
STORY_SCRIPT_12_ENTRY = 0x8223
STORY_SCRIPT_13_ENTRY = 0x862C
STORY_SCRIPT_14_ENTRY = 0x872E
STORY_SCRIPT_15_ENTRY = 0x87DB
STORY_SCRIPT_16_ENTRY = 0x883C
STORY_SCRIPT_17_ENTRY = 0x8BA4
STORY_SCRIPT_18_ENTRY = 0x8BA5
STORY_SCRIPT_19_ENTRY = 0x8C0B
STORY_SCRIPT_20_ENTRY = 0x8C50
APPARITION_OVERLAY_START = 0x666F
POST_TITLE_SIXTH_SCRIPT_CALL = 0x6686
APPARITION_REMOVE_ISI_START = 0x668C
POST_TITLE_EIGHTH_SCRIPT_CALL = 0x66F3
ISI_REVEAL_START = 0x66F6
POST_TITLE_NINTH_SCRIPT_CALL = 0x6713
YUU_SETUP_START = 0x6788
POST_TITLE_FOURTEENTH_SCRIPT_CALL = 0x67F4
YUU_SPLIT_START = 0x67FA
POST_TITLE_SIXTEENTH_SCRIPT_CALL = 0x6845
MAOP_SETUP_START = 0x684B
POST_TITLE_EIGHTEENTH_SCRIPT_CALL = 0x6892
YUU2_SETUP_START = 0x6915
POST_TITLE_TWENTIETH_SCRIPT_CALL = 0x6954
FINAL_SCENE_START = 0x6957
FINAL_SCENE_STOP = 0x6A05
ANIM_FADE_TBL_CREDITS = 0x742F
ANIMATE_SCANLINE_START = 0x6358
SCENE_SPRITE_C = 0x911E
DIRECT_CALLS = {
    "decode_rle_to_es_di": "decode_rle_to_es_di",
    "decompress_image": "decompress_image",
    "animate_scanline": "animate_scanline",
    "palette_lookup": "palette_lookup",
}


def word_bytes(value: int) -> list[int]:
    return [value & 0xFF, (value >> 8) & 0xFF]


def near_jmp_bytes(from_ip: int, to_ip: int) -> list[int]:
    rel = (to_ip - (from_ip + 3)) & 0xFFFF
    return [0xE9, rel & 0xFF, (rel >> 8) & 0xFF]


def load_opdemo_with_header_strip(h: TasmHarness) -> None:
    data = OPDEMO_BIN.read_bytes()
    h.write_code(LOAD_BASE - HEADER_SIZE, [0] * HEADER_SIZE)
    h.write_code(LOAD_BASE, data[HEADER_SIZE:])


def setup_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)

    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (GFX_INIT_SLOT, GFX_INIT_THUNK),
        (NARRATION_STONE_SLOT, NARRATION_STONE_THUNK),
        (GFX_DRAW_SLOT, GFX_DRAW_THUNK),
        (GFX_UPDATE_SLOT, GFX_UPDATE_THUNK),
        (GFX_MODE_SLOT, GFX_MODE_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
        (DISP_DATA_6F59_SLOT, DISP_DATA_6F59_THUNK),
        (DISP_NARR_CHAP2_SLOT, DISP_NARR_CHAP2_THUNK),
        (DISP_NARR_CHAP3_SLOT, DISP_NARR_CHAP3_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))

    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(OFF_SPACEBAR_STATE, [0xA5])
    h.write_code(OFF_ENTER_KEY, [0x5A])
    h.write_code(OFF_VOLUME_B, [0])
    h.write_code(STOP_BEFORE_SPRITE_LOOP, near_jmp_bytes(STOP_BEFORE_SPRITE_LOOP, RET_SENTINEL))

    stubs = {
        SAR_THUNK: {},
        GFX_INIT_THUNK: {},
        NARRATION_STONE_THUNK: {},
        GFX_DRAW_THUNK: {},
        GFX_UPDATE_THUNK: {},
        GFX_MODE_THUNK: {},
        GFX_PALETTE_THUNK: {},
        DISP_GAME_THUNK: {},
        DISP_DATA_6F59_THUNK: {},
        DISP_NARR_CHAP2_THUNK: {},
        DISP_NARR_CHAP3_THUNK: {},
    }
    for proc_name in DIRECT_CALLS:
        stubs[LOAD_BASE + resolve_proc("opdmo", proc_name) - HEADER_SIZE] = {}
    return h, stubs


def setup_sprite_c_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    h.write_code(DISP_NARR_CHAP2_SLOT, word_bytes(DISP_NARR_CHAP2_THUNK))
    h.write_code(STOP_AFTER_SCENE_SPRITE_C, near_jmp_bytes(STOP_AFTER_SCENE_SPRITE_C, RET_SENTINEL))
    stubs = {
        DISP_NARR_CHAP2_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_scene_after_anim_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (DISP_NARR_CHAP2_SLOT, DISP_NARR_CHAP2_THUNK),
        (DISP_CHAP2_CALL_SLOT, DISP_CHAP2_CALL_THUNK),
        (DISP_NARR_CHAP4_SLOT, DISP_NARR_CHAP4_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(STOP_BEFORE_JASHIIN_SPEECH, near_jmp_bytes(STOP_BEFORE_JASHIIN_SPEECH, RET_SENTINEL))
    stubs = {
        DISP_NARR_CHAP2_THUNK: {},
        DISP_CHAP2_CALL_THUNK: {},
        DISP_NARR_CHAP4_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_title_asset_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (JASHIIN_SPEECH_SLOT, JASHIIN_SPEECH_THUNK),
        (GFX_MODE_SLOT, GFX_MODE_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(STOP_AFTER_TITLE_ASSET_LOADS,
                 near_jmp_bytes(STOP_AFTER_TITLE_ASSET_LOADS, RET_SENTINEL))
    stubs = {
        SAR_THUNK: {},
        JASHIIN_SPEECH_THUNK: {},
        GFX_MODE_THUNK: {},
        GFX_PALETTE_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "decode_rle_to_es_di") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_title_int60_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(TITLE_INT60_ADDR, near_jmp_bytes(TITLE_INT60_ADDR, RET_SENTINEL))
    return h, {}


def setup_title_display_handoff_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (DISP_DRV_SEG_3_SLOT, DISP_DRV_SEG_3_THUNK),
        (GFX_UPDATE_SLOT, GFX_UPDATE_THUNK),
        (DISP_NARR_CHAP3_SLOT, DISP_NARR_CHAP3_THUNK),
        (DISP_NARR_OPEN_SLOT, DISP_NARR_OPEN_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(TITLE_INT60_ADDR, [0x90, 0x90])
    h.write_code(STOP_BEFORE_COLOR_ROTATE,
                 near_jmp_bytes(STOP_BEFORE_COLOR_ROTATE, RET_SENTINEL))
    stubs = {
        DISP_DRV_SEG_3_THUNK: {},
        GFX_UPDATE_THUNK: {},
        DISP_NARR_CHAP3_THUNK: {},
        DISP_NARR_OPEN_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE: {},
        LOAD_BASE + resolve_proc("opdmo", "decode_rle_to_es_di") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_title_color_rotate_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    h.write_code(DISP_SET_DRV_SEG_SLOT, word_bytes(DISP_SET_DRV_SEG_THUNK))
    h.write_code(STOP_AFTER_COLOR_ROTATE,
                 near_jmp_bytes(STOP_AFTER_COLOR_ROTATE, RET_SENTINEL))
    stubs = {
        DISP_SET_DRV_SEG_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_title_wait_exit_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (STICK_EXIT_DLG_SLOT, STICK_EXIT_DLG_THUNK),
        (STICK_PAUSE_DLG_SLOT, STICK_PAUSE_DLG_THUNK),
        (STICK_JOY_CAL_SLOT, STICK_JOY_CAL_THUNK),
        (STICK_JOY_DETECT_SLOT, STICK_JOY_DETECT_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_ENABLE_ALL, [0xFF])
    h.write_code(OPENING_NEXT_SCENE_START,
                 near_jmp_bytes(OPENING_NEXT_SCENE_START, RET_SENTINEL))
    stubs = {
        STICK_EXIT_DLG_THUNK: {},
        STICK_PAUSE_DLG_THUNK: {},
        STICK_JOY_CAL_THUNK: {},
        STICK_JOY_DETECT_THUNK: {},
    }
    return h, stubs


def setup_timer_exit_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (GFX_INIT_SLOT, GFX_INIT_THUNK),
        (GFX_MODE_SLOT, GFX_MODE_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(OFF_ENABLE_ALL, [0xFF])
    h.write_code(OFF_SPACEBAR_STATE, [0xA5])
    h.write_code(OFF_ENTER_KEY, [0x5A])
    h.write_code(TIMER_EXIT_INT60_ADDR, [0x90, 0x90])
    h.write_code(TRANS_EXIT_START, near_jmp_bytes(TRANS_EXIT_START, RET_SENTINEL))
    credits_target = LOAD_BASE + resolve_proc("opdmo", "credits_scroll_display") - HEADER_SIZE
    stubs = {
        SAR_THUNK: {},
        GFX_INIT_THUNK: {},
        GFX_MODE_THUNK: {},
        GFX_PALETTE_THUNK: {},
        credits_target: {},
    }
    return h, stubs


def setup_credits_scroll_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (ANIM_FN_WIPE_SLOT, ANIM_FN_WIPE_THUNK),
        (ANIM_FN_FADE_SLOT, ANIM_FN_FADE_THUNK),
        (ANIM_FN_DRAW_SLOT, ANIM_FN_DRAW_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_FRAME_TIMER, [0xFF])
    h.write_code(OFF_SPACEBAR_STATE, [0])
    h.write_code(OFF_ENTER_KEY, [0])
    interrupt_target = LOAD_BASE + resolve_proc("opdmo", "interrupt_handler_cascade") - HEADER_SIZE
    # The real interrupt/input cascade advances gvar_frame_timer outside this
    # chunk. Model that observable service effect so scene_transition_wait can
    # complete without replacing any of the credits-scroll control flow.
    h.write_code(interrupt_target, [0x2E, 0xFE, 0x06, 0x1A, 0xFF, 0xC3])
    stubs = {
        ANIM_FN_WIPE_THUNK: {},
        # The graphics service consumes one credits-table entry and leaves SI
        # immediately after its CR/FF terminator.
        ANIM_FN_FADE_THUNK: {"scan_si_until": [0x0D, 0xFF]},
        ANIM_FN_DRAW_THUNK: {},
    }
    return h, stubs


def setup_animate_scanline_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (ANIM_FN_WIPE_SLOT, ANIM_FN_WIPE_THUNK),
        (ANIM_FN_FADE_SLOT, ANIM_FN_FADE_THUNK),
        (ANIM_FN_DRAW_SLOT, ANIM_FN_DRAW_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_FRAME_TIMER, [0xFF])
    h.write_code(OFF_SPACEBAR_STATE, [0])
    h.write_code(OFF_ENTER_KEY, [0])
    stubs = {
        ANIM_FN_WIPE_THUNK: {},
        ANIM_FN_FADE_THUNK: {"scan_si_until": [0x0D, 0xFF]},
        ANIM_FN_DRAW_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_trans_exit_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    h.write_code(GFX_INIT_SLOT, word_bytes(GFX_INIT_THUNK))
    h.write_code(OFF_ENABLE_ALL, [0xFF])
    h.write_code(OFF_SPACEBAR_STATE, [0xA5])
    h.write_code(OFF_ENTER_KEY, [0x5A])
    h.write_code(POST_TITLE_STORY_START, near_jmp_bytes(POST_TITLE_STORY_START, RET_SENTINEL))
    return h, {GFX_INIT_THUNK: {}}


def setup_post_title_story_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(POST_TITLE_FIRST_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_FIRST_SCRIPT_CALL, RET_SENTINEL))
    stubs = {
        SAR_THUNK: {},
        GFX_PALETTE_THUNK: {},
        DISP_GAME_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_first_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (JASHIIN_SPEECH_SLOT, JASHIIN_SPEECH_THUNK),
        (DISP_NARR_CHAP4_SLOT, DISP_NARR_CHAP4_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(OFF_SCRIPT_PC, word_bytes(NARRATION_PROLOGUE_ENTRY))
    stubs = {
        JASHIIN_SPEECH_THUNK: {},
        DISP_NARR_CHAP4_THUNK: {},
        DISP_GAME_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_story_1_to_2_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(POST_TITLE_SECOND_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_SECOND_SCRIPT_CALL, RET_SENTINEL))
    stubs = {
        SAR_THUNK: {},
        GFX_PALETTE_THUNK: {},
        DISP_GAME_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_second_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_2_ENTRY))
    return h, stubs


def setup_story_2_to_3_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
        (DISP_FONT_INV_SLOT, DISP_FONT_INV_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(POST_TITLE_THIRD_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_THIRD_SCRIPT_CALL, RET_SENTINEL))
    stubs = {
        SAR_THUNK: {},
        GFX_PALETTE_THUNK: {},
        DISP_GAME_THUNK: {},
        DISP_FONT_INV_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE: {},
    }
    return h, stubs


def setup_third_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_3_ENTRY))
    return h, stubs


def setup_fourth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_4_ENTRY))
    return h, stubs


def setup_fifth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_5_ENTRY))
    return h, stubs


def setup_sixth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_6_ENTRY))
    return h, stubs


def setup_seventh_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_7_ENTRY))
    return h, stubs


def setup_apparition_overlay_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    h.write_code(DISP_DATA_7420_SLOT, word_bytes(DISP_DATA_7420_THUNK))
    h.write_code(POST_TITLE_SIXTH_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_SIXTH_SCRIPT_CALL, RET_SENTINEL))
    return h, {DISP_DATA_7420_THUNK: {}}


def setup_eighth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_8_ENTRY))
    return h, stubs


def setup_ninth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_9_ENTRY))
    return h, stubs


def setup_tenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_10_ENTRY))
    return h, stubs


def setup_eleventh_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_11_ENTRY))
    return h, stubs


def setup_twelfth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_12_ENTRY))
    return h, stubs


def setup_thirteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_13_ENTRY))
    return h, stubs


def setup_fourteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_14_ENTRY))
    return h, stubs


def setup_fifteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_15_ENTRY))
    return h, stubs


def setup_sixteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_16_ENTRY))
    return h, stubs


def setup_seventeenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_17_ENTRY))
    return h, stubs


def setup_eighteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_18_ENTRY))
    return h, stubs


def setup_nineteenth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_19_ENTRY))
    return h, stubs


def setup_twentieth_story_script_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h, stubs = setup_first_story_script_harness()
    h.write_code(OFF_SCRIPT_PC, word_bytes(STORY_SCRIPT_20_ENTRY))
    return h, stubs


def setup_apparition_remove_isi_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (SAR_LOADER_SLOT, SAR_THUNK),
        (DISP_GAME_SLOT, DISP_GAME_THUNK),
        (GFX_MODE_SLOT, GFX_MODE_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(POST_TITLE_EIGHTH_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_EIGHTH_SCRIPT_CALL, RET_SENTINEL))
    return h, {
        SAR_THUNK: {},
        DISP_GAME_THUNK: {},
        GFX_MODE_THUNK: {},
        LOAD_BASE + resolve_proc("opdmo", "busy_wait_delay") - HEADER_SIZE: {},
        LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer") - HEADER_SIZE: {},
        LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE: {},
    }


def setup_isi_reveal_harness() -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    for slot, thunk in (
        (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
        (GFX_UPDATE_SLOT, GFX_UPDATE_THUNK),
    ):
        h.write_code(slot, word_bytes(thunk))
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(POST_TITLE_NINTH_SCRIPT_CALL,
                 near_jmp_bytes(POST_TITLE_NINTH_SCRIPT_CALL, RET_SENTINEL))
    return h, {GFX_PALETTE_THUNK: {}, GFX_UPDATE_THUNK: {}}


def setup_late_transition_harness(start: int, stop: int,
                                  slots: tuple[tuple[int, int], ...],
                                  direct_calls: tuple[str, ...] = ()) -> tuple[TasmHarness, dict[int, dict]]:
    h = TasmHarness(str(OPDEMO_BIN), LOAD_BASE)
    load_opdemo_with_header_strip(h)
    stubs = {}
    for slot, thunk in slots:
        h.write_code(slot, word_bytes(thunk))
        stubs[thunk] = {}
    for proc_name in direct_calls:
        target = LOAD_BASE + resolve_proc("opdmo", proc_name) - HEADER_SIZE
        stubs[target] = {}
    h.write_code(OFF_GAME_SEG, word_bytes(CODE_SEG))
    h.write_code(stop, near_jmp_bytes(stop, RET_SENTINEL))
    return h, stubs


def setup_yuu_transition_harness() -> tuple[TasmHarness, dict[int, dict]]:
    return setup_late_transition_harness(
        YUU_SETUP_START, POST_TITLE_FOURTEENTH_SCRIPT_CALL,
        ((SAR_LOADER_SLOT, SAR_THUNK), (GFX_UPDATE_SLOT, GFX_UPDATE_THUNK)),
        ("decompress_image",))


def setup_yuu_split_harness() -> tuple[TasmHarness, dict[int, dict]]:
    return setup_late_transition_harness(
        YUU_SPLIT_START, POST_TITLE_SIXTEENTH_SCRIPT_CALL,
        ((DISP_FONT_INV_SLOT, DISP_FONT_INV_THUNK),
         (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
         (DISP_LOAD_SETUP_SLOT, DISP_LOAD_SETUP_THUNK),
         (DISP_GAME_SLOT, DISP_GAME_THUNK)))


def setup_maop_transition_harness() -> tuple[TasmHarness, dict[int, dict]]:
    return setup_late_transition_harness(
        MAOP_SETUP_START, POST_TITLE_EIGHTEENTH_SCRIPT_CALL,
        ((SAR_LOADER_SLOT, SAR_THUNK),
         (DISP_FONT_INV_SLOT, DISP_FONT_INV_THUNK),
         (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
         (DISP_LOAD_SETUP_SLOT, DISP_LOAD_SETUP_THUNK),
         (DISP_SCRIPT_AREA_SLOT, DISP_SCRIPT_AREA_THUNK)),
        ("decompress_image",))


def setup_yuu2_transition_harness() -> tuple[TasmHarness, dict[int, dict]]:
    return setup_late_transition_harness(
        YUU2_SETUP_START, POST_TITLE_TWENTIETH_SCRIPT_CALL,
        ((DISP_FONT_INV_SLOT, DISP_FONT_INV_THUNK),
         (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK),
         (SAR_LOADER_SLOT, SAR_THUNK),
         (DISP_GAME_SLOT, DISP_GAME_THUNK)),
        ("decompress_image",))


def setup_final_scene_harness() -> tuple[TasmHarness, dict[int, dict]]:
    return setup_late_transition_harness(
        FINAL_SCENE_START, FINAL_SCENE_STOP,
        ((SAR_LOADER_SLOT, SAR_THUNK),
         (GFX_MODE_SLOT, GFX_MODE_THUNK),
         (GFX_UPDATE_SLOT, GFX_UPDATE_THUNK),
         (GFX_DRAW_SLOT, GFX_DRAW_THUNK),
         (GFX_PALETTE_SLOT, GFX_PALETTE_THUNK)),
        ("decompress_image", "merge_gfx_planes", "xor_mask_render",
         "wait_story_scene_timer", "animate_scanline_alt"))


def read_code(h: TasmHarness, offset: int, length: int) -> bytes:
    return bytes(h.mu.mem_read((CODE_SEG << 4) + offset, length))


def read_code_byte(h: TasmHarness, offset: int) -> int:
    return read_code(h, offset, 1)[0]


def read_code_word(h: TasmHarness, offset: int) -> int:
    return int.from_bytes(read_code(h, offset, 2), "little")


def read_ref_name(h: TasmHarness, offset: int) -> str:
    raw = bytearray()
    pos = offset + 2
    while True:
        b = read_code_byte(h, pos)
        if b == 0:
            return raw.decode("ascii", errors="replace")
        raw.append(b)
        pos += 1


def stub_regs(result: dict, thunk: int) -> list[dict[str, int]]:
    return [regs for regs in result.get("stub_regs", []) if regs["ip"] == thunk]


def sar_records(h: TasmHarness, result: dict) -> list[dict[str, int | str]]:
    out: list[dict[str, int | str]] = []
    for regs in stub_regs(result, SAR_THUNK):
        si = regs["si"]
        out.append({
            "name": read_ref_name(h, si),
            "al": regs["ax"] & 0xFF,
            "di": regs["di"],
            "es_delta": (regs["es"] - CODE_SEG) & 0xFFFF,
            "si": si,
        })
    return out


def expect(condition: bool, failures: list[str], message: str) -> None:
    if not condition:
        failures.append(message)


def assert_story_script_protocol(failures: list[str], label: str, setup,
                                 final_pc: int, wait_10: int, wait_f0: int,
                                 draw_calls: int, clear_count: int) -> None:
    h, stubs = setup()
    result = h.call_function(
        LOAD_BASE + resolve_proc("opdmo", "run_script_interpreter") - HEADER_SIZE,
        regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=stubs, max_steps=100000)
    waits = stub_regs(
        result, LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer")
        - HEADER_SIZE)
    wait_al = [r["ax"] & 0xFF for r in waits]
    expect(result["stopped_reason"] == "returned_to_sentinel", failures,
           f"{label} did not return at SCR_BREAK: {result['stopped_reason']}")
    expect(wait_al.count(0x10) == wait_10 and wait_al.count(0xF0) == wait_f0,
           failures, f"{label} wait protocol was not {wait_10}*10h + {wait_f0}*F0h")
    expect(len(stub_regs(result, DISP_NARR_CHAP4_THUNK)) == draw_calls,
           failures, f"{label} did not emit {draw_calls} glyph draw calls")
    expect(len(stub_regs(result, JASHIIN_SPEECH_THUNK)) == clear_count,
           failures, f"{label} did not emit {clear_count} scroll clears")
    expect(read_code_word(h, OFF_SCRIPT_PC) == final_pc,
           failures, f"{label} final PC {read_code_word(h, OFF_SCRIPT_PC):04X} "
                     f"!= {final_pc:04X}")


def assert_sar_record(failures: list[str], records: list[dict[str, int | str]],
                      index: int, name: str, al: int, di: int, es_delta: int) -> None:
    if index >= len(records):
        failures.append(f"missing SAR record {index}: {name}")
        return
    rec = records[index]
    expect(rec["name"] == name, failures, f"SAR[{index}] name {rec['name']!r} != {name!r}")
    expect(rec["al"] == al, failures, f"SAR[{index}] AL {rec['al']:02X} != {al:02X}")
    expect(rec["di"] == di, failures, f"SAR[{index}] DI {rec['di']:04X} != {di:04X}")
    expect(rec["es_delta"] == es_delta, failures,
           f"SAR[{index}] ES delta {rec['es_delta']:04X} != {es_delta:04X}")


def main() -> int:
    failures: list[str] = []
    h, stubs = setup_harness()
    result = h.call_function(LOAD_BASE, regs={"ds": CODE_SEG, "es": CODE_SEG, "si": 0, "bx": 6},
                             stub_calls=stubs, max_steps=2000)
    records = sar_records(h, result)

    expect(result["stopped_reason"] == "returned_to_sentinel", failures,
           f"opening sequence did not stop at checkpoint: {result['stopped_reason']}")
    expect(len(records) == 4, failures, f"opening first-sequence SAR calls {len(records)} != 4")
    assert_sar_record(failures, records, 0, "ttl3.grp", 2, 0xA000, 0x0000)
    assert_sar_record(failures, records, 1, "nec.grp", 2, 0xA000, 0x0000)
    assert_sar_record(failures, records, 2, "hou.grp", 2, 0xB800, 0x0000)
    assert_sar_record(failures, records, 3, "dmaou.grp", 2, 0xA000, 0x0000)

    expect(len(stub_regs(result, GFX_INIT_THUNK)) == 2, failures,
           "gfx_init_fn was not called twice before DMAOU checkpoint")
    expect([r["ax"] for r in stub_regs(result, GFX_PALETTE_THUNK)] == [4, 1, 2, 3],
           failures, "palette calls before sprite loop were not AX=4, AX=1, AX=2, AX=3")

    decode_rle_regs = stub_regs(
        result, LOAD_BASE + resolve_proc("opdmo", "decode_rle_to_es_di") - HEADER_SIZE)
    expect([(r["si"], r["di"], r["es"]) for r in decode_rle_regs] ==
           [(0xA000, 0x4000, CODE_SEG)],
           failures, "ttl3 decode_rle_to_es_di did not use SI=A000 DI=4000 ES=game_seg")

    decompress_regs = stub_regs(
        result, LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE)
    expect([(r["si"], r["di"], r["es"]) for r in decompress_regs] ==
           [(0xA000, 0x4000, CODE_SEG),
            (0xB800, 0x9000, CODE_SEG),
            (0xA000, 0x97C0, CODE_SEG)],
           failures, "NEC/HOU/DMAOU decompress_image calls did not match source/destination buffers")
    expect(len(stub_regs(
        result, LOAD_BASE + resolve_proc("opdmo", "palette_lookup") - HEADER_SIZE)) == 1,
           failures, "palette_lookup was not called once for DMAOU scene data")

    expect([(r["bx"], r["cx"], r["si"]) for r in stub_regs(result, NARRATION_STONE_THUNK)] ==
           [(0x0000, 0x0096, 0x64EA)],
           failures, "narration stone call did not use BX=0 CL=96 SI=64EA")
    expect([(r["bx"], r["cx"], r["di"], r["es"]) for r in stub_regs(result, DISP_NARR_CHAP3_THUNK)] ==
           [(0x070F, 0x4170, 0x4000, CODE_SEG)],
           failures, "ttl3 title blit call did not use BX=070F CX=4170 DI=4000")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(result, GFX_DRAW_THUNK)] ==
           [(0xFF, 0x1220, 0x2C68, 0x4000, CODE_SEG)],
           failures, "NEC gfx_draw call did not use AL=FF BX=1220 CX=2C68 DI=4000")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(result, GFX_UPDATE_THUNK)] ==
           [(0xFF, 0x1220, 0x2C68, 0x4000, CODE_SEG),
            (0xFF, 0x1720, 0x2270, 0x0000, CODE_SEG + 0x2000)],
           failures, "NEC/DMAOU gfx_update calls did not match expected geometry")
    expect([(r["bx"], r["cx"]) for r in stub_regs(result, GFX_MODE_THUNK)] ==
           [(0x1220, 0x2C68)],
           failures, "DMAOU gfx_mode call did not use BX=1220 CX=2C68")
    expect([(r["bx"], r["cx"], r["di"], r["es"]) for r in stub_regs(result, DISP_GAME_THUNK)] ==
           [(0x2048, 0x1040, 0x75A0, CODE_SEG)],
           failures, "HOU overlay display call did not use BX=2048 CX=1040 DI=75A0")
    expect([r["si"] for r in stub_regs(result, DISP_DATA_6F59_THUNK)] == [0x9060],
           failures, "scene_sprite_a dispatch did not use SI=9060")
    expect(len(stub_regs(
        result, LOAD_BASE + resolve_proc("opdmo", "animate_scanline") - HEADER_SIZE)) == 1,
           failures, "animate_scanline was not called once before HOU overlay")

    expect(read_code_byte(h, OFF_SPACEBAR_STATE) == 0, failures,
           "gvar_spacebar_state was not cleared")
    expect(read_code_byte(h, OFF_ENTER_KEY) == 0, failures,
           "gvar_enter_key was not cleared")
    expect(read_code_byte(h, OFF_VOLUME_B) == 4, failures,
           "gvar_volume_b was not set to 4 before scene_sprite_a")

    h_sprite, sprite_stubs = setup_sprite_c_harness()
    sprite_result = h_sprite.call_function(STOP_BEFORE_SPRITE_LOOP,
                                           regs={"ds": CODE_SEG, "es": CODE_SEG, "si": SCENE_SPRITE_C},
                                           stub_calls=sprite_stubs, max_steps=500)
    expect(sprite_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"scene_sprite_c loop did not stop at checkpoint: {sprite_result['stopped_reason']}")
    expected_sprite_calls = [
        (0, 0x1720), (0, 0x1720), (0, 0x1720), (1, 0x1720),
        (1, 0x1720), (0, 0x1720), (0, 0x1720), (1, 0x1720),
        (1, 0x1720), (2, 0x1720), (2, 0x1720), (4, 0x1720),
    ]
    expect([(r["ax"] & 0xFF, r["bx"]) for r in stub_regs(sprite_result, DISP_NARR_CHAP2_THUNK)] ==
           expected_sprite_calls,
           failures, "scene_sprite_c dispatch sequence did not match bytes 1,1,1,2,2,1,1,2,2,3,3,5")
    timer_regs = stub_regs(
        sprite_result, LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE)
    expect([r["ax"] & 0xFF for r in timer_regs] == [0x14] * len(expected_sprite_calls),
           failures, "scene_sprite_c timer waits were not AL=14h for each frame")
    expect(sprite_result["regs_after"]["si"] == 0x912B, failures,
           f"scene_sprite_c final SI {sprite_result['regs_after']['si']:04X} != 912B")

    h_after, after_stubs = setup_scene_after_anim_harness()
    after_result = h_after.call_function(SCENE_AFTER_ANIM, regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=after_stubs, max_steps=10000)
    expect(after_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"scene_after_anim did not stop before Jashiin speech: {after_result['stopped_reason']}")
    expect([(r["ax"] & 0xFF, r["bx"]) for r in stub_regs(after_result, DISP_NARR_CHAP2_THUNK)] ==
           [(2, 0x1720), (3, 0x1720)],
           failures, "scene_after_anim explicit chapter-2 calls were not AL=2 then AL=3 at BX=1720")
    expect(len(stub_regs(after_result, DISP_CHAP2_CALL_THUNK)) == 38, failures,
           "scene_sprite_b script did not emit 38 chapter-2 animation dispatches")
    expect(len(stub_regs(after_result, DISP_NARR_CHAP4_THUNK)) == 176, failures,
           "scene_sprite_b script did not emit 176 chapter-4 glyph draw calls")
    after_timer_regs = stub_regs(
        after_result, LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE)
    expected_after_timers = [0xF0] + [0x14] * 91 + [0xF0, 0x0F, 0xF0]
    expect([r["ax"] & 0xFF for r in after_timer_regs] == expected_after_timers,
           failures, "scene_after_anim wait sequence did not match F0 + 91*14 + F0/0F/F0")
    expect(after_result["regs_after"]["si"] == SCENE_SPRITE_C, failures,
           f"scene_sprite_b final SI {after_result['regs_after']['si']:04X} != {SCENE_SPRITE_C:04X}")

    h_title, title_stubs = setup_title_asset_harness()
    title_result = h_title.call_function(TITLE_ASSET_BLOCK_START,
                                         regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=title_stubs, max_steps=1000)
    title_records = sar_records(h_title, title_result)
    expect(title_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"title asset block did not stop before int60 setup: {title_result['stopped_reason']}")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"]) for r in stub_regs(title_result, JASHIIN_SPEECH_THUNK)] ==
           [(0, 0x0094, 0x501E)],
           failures, "Jashiin speech call was not AL=0 BX=0094 CX=501E")
    expect(len(title_records) == 4, failures, f"title asset SAR calls {len(title_records)} != 4")
    assert_sar_record(failures, title_records, 0, "ttl1.grp", 2, 0xA000, 0x0000)
    assert_sar_record(failures, title_records, 1, "ttl2.grp", 2, 0xA000, 0x0000)
    assert_sar_record(failures, title_records, 2, "ttl3.grp", 2, 0xB000, 0x0000)
    assert_sar_record(failures, title_records, 3, "zopn.msd", 5, 0x3000, 0x0000)
    title_decode_regs = stub_regs(
        title_result, LOAD_BASE + resolve_proc("opdmo", "decode_rle_to_es_di") - HEADER_SIZE)
    expect([(r["si"], r["di"], r["es"]) for r in title_decode_regs] ==
           [(0xA000, 0x4000, CODE_SEG)],
           failures, "ttl1 decode_rle_to_es_di did not use SI=A000 DI=4000 ES=game_seg")
    expect([(r["bx"], r["cx"]) for r in stub_regs(title_result, GFX_MODE_THUNK)] ==
           [(0x1720, 0x2270)],
           failures, "title asset block gfx_mode did not use BX=1720 CX=2270")
    expect([r["ax"] for r in stub_regs(title_result, GFX_PALETTE_THUNK)] == [4],
           failures, "title asset block palette call was not AX=4")

    h_int, int_stubs = setup_title_int60_harness()
    int_result = h_int.call_function(TITLE_INT60_START,
                                     regs={"ds": CODE_SEG, "es": CODE_SEG},
                                     stub_calls=int_stubs, max_steps=100)
    expect(int_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"title int60 setup did not stop at interrupt checkpoint: {int_result['stopped_reason']}")
    expect(read_code_byte(h_int, OFF_FRAME_TIMER) == 0, failures,
           "title int60 setup did not clear gvar_frame_timer before interrupt")
    expect((int_result["regs_after"]["ax"], int_result["regs_after"]["si"],
            int_result["regs_after"]["ds"]) == (0, 0x3000, CODE_SEG),
           failures, "title int60 setup was not AX=0 SI=3000 DS=game_seg at interrupt")

    h_handoff, handoff_stubs = setup_title_display_handoff_harness()
    handoff_result = h_handoff.call_function(TITLE_DISPLAY_HANDOFF_START,
                                             regs={"ds": CODE_SEG, "es": CODE_SEG},
                                             stub_calls=handoff_stubs, max_steps=1000)
    expect(handoff_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"title display handoff did not stop before color rotation: {handoff_result['stopped_reason']}")
    expect(len(stub_regs(handoff_result, DISP_DRV_SEG_3_THUNK)) == 1, failures,
           "title display handoff did not call disp_drv_seg_3 once")
    handoff_timer_regs = stub_regs(
        handoff_result, LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE)
    expect([r["ax"] & 0xFF for r in handoff_timer_regs] == [0xF0, 0xF0, 0xF0],
           failures, "title display handoff wait sequence was not F0/F0/F0")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(handoff_result, GFX_UPDATE_THUNK)] ==
           [(0, 0x0B48, 0x3180, 0x4000, CODE_SEG)],
           failures, "title display handoff gfx_update was not AL=0 BX=0B48 CX=3180 DI=4000")
    handoff_decode_regs = stub_regs(
        handoff_result, LOAD_BASE + resolve_proc("opdmo", "decode_rle_to_es_di") - HEADER_SIZE)
    expect([(r["si"], r["di"], r["es"]) for r in handoff_decode_regs] ==
           [(0xB000, 0x4000, CODE_SEG), (0xA000, 0x4000, CODE_SEG)],
           failures, "title display handoff did not decode ttl3 then ttl2 into scene_framebuf")
    expect([(r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(handoff_result, DISP_NARR_CHAP3_THUNK)] ==
           [(0x070F, 0x4170, 0x4000, CODE_SEG)],
           failures, "title display handoff ttl3 blit was not BX=070F CX=4170 DI=4000")
    expect([r["si"] for r in stub_regs(handoff_result, DISP_NARR_OPEN_THUNK)] == [0x912B],
           failures, "title display handoff did not dispatch scene_sprite_d")

    h_rotate, rotate_stubs = setup_title_color_rotate_harness()
    rotate_result = h_rotate.call_function(COLOR_ROTATE_START,
                                           regs={"ds": CODE_SEG, "es": CODE_SEG},
                                           stub_calls=rotate_stubs, max_steps=3000)
    expect(rotate_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"title color rotation did not stop before gfx-enabled wait: {rotate_result['stopped_reason']}")
    rotate_calls = [r["ax"] & 0xFF for r in stub_regs(rotate_result, DISP_SET_DRV_SEG_THUNK)]
    expect(len(rotate_calls) == 200, failures,
           f"title color rotation disp_set calls {len(rotate_calls)} != 200")
    expect(rotate_calls[:6] == [0xC7, 0x00, 0xC5, 0x02, 0xC3, 0x04], failures,
           "title color rotation first calls were not C7/00, C5/02, C3/04")
    expect(rotate_calls[-6:] == [0x05, 0xC2, 0x03, 0xC4, 0x01, 0xC6], failures,
           "title color rotation final calls were not 05/C2, 03/C4, 01/C6")
    rotate_timer_regs = stub_regs(
        rotate_result, LOAD_BASE + resolve_proc("opdmo", "timer_wait_loop") - HEADER_SIZE)
    expect([r["ax"] & 0xFF for r in rotate_timer_regs] == [0x50] * 100,
           failures, "title color rotation waits were not 100 calls of AL=50h")

    h_exit, exit_stubs = setup_title_wait_exit_harness()
    exit_result = h_exit.call_function(WAIT_GFX_ENABLED_START,
                                       regs={"ds": CODE_SEG, "es": CODE_SEG},
                                       stub_calls=exit_stubs, max_steps=200)
    expect(exit_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"title gfx-enabled wait did not jump to opening_next_scene: {exit_result['stopped_reason']}")
    expect([len(stub_regs(exit_result, thunk)) for thunk in
            (STICK_EXIT_DLG_THUNK, STICK_PAUSE_DLG_THUNK,
             STICK_JOY_CAL_THUNK, STICK_JOY_DETECT_THUNK)] == [1, 1, 1, 1],
           failures, "title gfx-enabled wait did not run interrupt cascade once")

    h_timer_int, timer_int_stubs = setup_timer_exit_harness()
    h_timer_int.write_code(TIMER_EXIT_INT60_ADDR,
                           near_jmp_bytes(TIMER_EXIT_INT60_ADDR, RET_SENTINEL))
    timer_int_result = h_timer_int.call_function(OPENING_NEXT_SCENE_START,
                                                 regs={"ds": CODE_SEG, "es": CODE_SEG},
                                                 stub_calls=timer_int_stubs, max_steps=1000)
    expect(timer_int_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"opening_next_scene did not stop at int60 checkpoint: {timer_int_result['stopped_reason']}")
    expect((timer_int_result["regs_after"]["ax"], timer_int_result["regs_after"]["si"],
            timer_int_result["regs_after"]["di"], timer_int_result["regs_after"]["ds"]) ==
           (0, 0x3000, 0x3000, CODE_SEG),
           failures, "opening_next_scene int60 setup was not AX=0 SI=3000 DI=3000 DS=game_seg")

    h_timer, timer_stubs = setup_timer_exit_harness()
    timer_result = h_timer.call_function(OPENING_NEXT_SCENE_START,
                                         regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=timer_stubs, max_steps=1000)
    timer_records = sar_records(h_timer, timer_result)
    credits_target = LOAD_BASE + resolve_proc("opdmo", "credits_scroll_display") - HEADER_SIZE
    expect(timer_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"opening_next_scene did not jump to trans_exit checkpoint: {timer_result['stopped_reason']}")
    expect(read_code_byte(h_timer, OFF_SCENE_MODE) == 8, failures,
           "opening_next_scene did not set gvar_scene_mode=8")
    expect(read_code_byte(h_timer, OFF_SPACEBAR_STATE) == 0, failures,
           "opening_next_scene did not clear spacebar state")
    expect(read_code_byte(h_timer, OFF_ENTER_KEY) == 0, failures,
           "opening_next_scene did not clear enter key state")
    expect(read_code_byte(h_timer, OFF_FRAME_TIMER) == 0, failures,
           "opening_next_scene did not clear frame timer before int60")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"]) for r in stub_regs(timer_result, GFX_MODE_THUNK)] ==
           [(0xFF, 0x0000, 0x50C8)],
           failures, "opening_next_scene gfx_mode was not AL=FF BX=0000 CX=50C8")
    expect(len(stub_regs(timer_result, GFX_INIT_THUNK)) == 1, failures,
           "opening_next_scene did not call gfx_init once")
    expect(len(timer_records) == 1, failures,
           f"opening_next_scene SAR calls {len(timer_records)} != 1")
    assert_sar_record(failures, timer_records, 0, "zend.msd", 5, 0x3000, 0x0000)
    expect([r["ax"] for r in stub_regs(timer_result, GFX_PALETTE_THUNK)] == [1],
           failures, "opening_next_scene palette call was not AX=1")
    expect(len(stub_regs(timer_result, credits_target)) == 1, failures,
           "opening_next_scene did not call credits_scroll_display once")

    h_trans, trans_stubs = setup_trans_exit_harness()
    trans_result = h_trans.call_function(TRANS_EXIT_START,
                                         regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=trans_stubs, max_steps=200)
    expect(trans_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"trans_exit did not reach post-title story checkpoint: {trans_result['stopped_reason']}")
    expect(read_code_byte(h_trans, OFF_SCENE_MODE) == 8, failures,
           "trans_exit did not set gvar_scene_mode=8")
    expect(read_code_byte(h_trans, OFF_SPACEBAR_STATE) == 0, failures,
           "trans_exit did not clear spacebar state")
    expect(read_code_byte(h_trans, OFF_ENTER_KEY) == 0, failures,
           "trans_exit did not clear enter key state")
    expect(len(stub_regs(trans_result, GFX_INIT_THUNK)) == 1, failures,
           "trans_exit did not call gfx_init once")

    h_story, story_stubs = setup_post_title_story_harness()
    story_result = h_story.call_function(POST_TITLE_STORY_START,
                                         regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=story_stubs, max_steps=1000)
    story_records = sar_records(h_story, story_result)
    expect(story_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"post-title story setup did not stop before first script call: "
           f"{story_result['stopped_reason']}")
    expect([r["ax"] for r in stub_regs(story_result, GFX_PALETTE_THUNK)] == [5],
           failures, "post-title story setup palette call was not AX=5")
    expect(len(story_records) == 2, failures,
           f"post-title story setup SAR calls {len(story_records)} != 2")
    assert_sar_record(failures, story_records, 0, "waku.grp", 2, 0xA000, 0x0000)
    assert_sar_record(failures, story_records, 1, "ame.grp", 2, 0xA000, 0x0000)
    story_decompress = stub_regs(
        story_result, LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE)
    expect([(r["si"], r["di"], r["es"]) for r in story_decompress] ==
           [(0xA000, 0x0000, CODE_SEG + 0x2000),
            (0xA000, 0x4000, CODE_SEG)],
           failures, "post-title story setup did not decompress WAKU then AME "
                     "to the expected buffers")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(story_result, DISP_GAME_THUNK)] ==
           [(0x00, 0x0000, 0x5088, 0x0000, CODE_SEG + 0x2000),
            (0x00, 0x0410, 0x4868, 0x4000, CODE_SEG)],
           failures, "post-title story setup display calls did not match WAKU/AME geometry")

    h_script, script_stubs = setup_first_story_script_harness()
    script_result = h_script.call_function(
        LOAD_BASE + resolve_proc("opdmo", "run_script_interpreter") - HEADER_SIZE,
        regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=script_stubs, max_steps=100000)
    expect(script_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"first post-title story script did not return at SCR_BREAK: "
           f"{script_result['stopped_reason']}")
    story_waits = stub_regs(
        script_result, LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer")
        - HEADER_SIZE)
    wait_al = [r["ax"] & 0xFF for r in story_waits]
    expect(len(story_waits) == 777 and wait_al.count(0x10) == 743
           and wait_al.count(0xF0) == 34,
           failures, "first post-title story script wait protocol was not "
                     "743*10h + 34*F0h")
    expect(len(stub_regs(script_result, DISP_NARR_CHAP4_THUNK)) == 1372,
           failures, "first post-title story script did not emit 1372 glyph draw calls")
    first_draws = stub_regs(script_result, DISP_NARR_CHAP4_THUNK)[:4]
    expect([(r["ax"] & 0xFF, (r["ax"] >> 8) & 0xFF, r["bx"], r["cx"])
            for r in first_draws] ==
           [(ord("P"), 0x00, 0x0005, 0x0090),
            (ord("P"), 0x00, 0x0004, 0x008F),
            (ord("O"), 0x00, 0x0005, 0x009A),
            (ord("O"), 0x07, 0x0004, 0x0099)],
           failures, "first story script initial P/O draw registers did not match")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"])
            for r in stub_regs(script_result, JASHIIN_SPEECH_THUNK)] ==
           [(0, 0x008F, 0x5039)] * 9,
           failures, "first post-title story script did not emit nine exact scroll clears")
    expect(read_code_word(h_script, OFF_SCRIPT_PC) == 0x7CAD,
           failures, f"first post-title story script final PC "
                     f"{read_code_word(h_script, OFF_SCRIPT_PC):04X} != 7CAD")

    h_hime, hime_stubs = setup_story_1_to_2_harness()
    hime_result = h_hime.call_function(STORY_1_TO_2_START,
                                       regs={"ds": CODE_SEG, "es": CODE_SEG},
                                       stub_calls=hime_stubs, max_steps=1000)
    hime_records = sar_records(h_hime, hime_result)
    expect(hime_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"HIME transition did not stop before second script call: "
           f"{hime_result['stopped_reason']}")
    expect([r["ax"] for r in stub_regs(hime_result, GFX_PALETTE_THUNK)] == [9],
           failures, "HIME transition palette call was not AX=9")
    expect(len(hime_records) == 1, failures,
           f"HIME transition SAR calls {len(hime_records)} != 1")
    assert_sar_record(failures, hime_records, 0, "hime.grp", 2, 0xA000, 0x0000)
    expect([(r["si"], r["di"], r["es"]) for r in stub_regs(
        hime_result, LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE)] ==
           [(0xA000, 0x4000, CODE_SEG)],
           failures, "HIME transition did not decompress HIME to scene_framebuf")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"], r["es"])
            for r in stub_regs(hime_result, DISP_GAME_THUNK)] ==
           [(0x09, 0x0410, 0x4868, 0x4000, CODE_SEG)],
           failures, "HIME transition BLIT_SCENE_FRAME geometry did not match")

    h_script2, script2_stubs = setup_second_story_script_harness()
    script2_result = h_script2.call_function(
        LOAD_BASE + resolve_proc("opdmo", "run_script_interpreter") - HEADER_SIZE,
        regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=script2_stubs, max_steps=100000)
    expect(script2_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"second post-title story script did not return at SCR_BREAK: "
           f"{script2_result['stopped_reason']}")
    story2_waits = stub_regs(
        script2_result, LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer")
        - HEADER_SIZE)
    wait2_al = [r["ax"] & 0xFF for r in story2_waits]
    expect(len(story2_waits) == 321 and wait2_al.count(0x10) == 306
           and wait2_al.count(0xF0) == 15,
           failures, "second post-title story script wait protocol was not "
                     "306*10h + 15*F0h")
    expect(len(stub_regs(script2_result, DISP_NARR_CHAP4_THUNK)) == 562,
           failures, "second post-title story script did not emit 562 glyph draw calls")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"])
            for r in stub_regs(script2_result, JASHIIN_SPEECH_THUNK)] ==
           [(0, 0x008F, 0x5039)] * 4,
           failures, "second post-title story script did not emit four exact scroll clears")
    expect(read_code_word(h_script2, OFF_SCRIPT_PC) == 0x7DDF,
           failures, f"second post-title story script final PC "
                     f"{read_code_word(h_script2, OFF_SCRIPT_PC):04X} != 7DDF")

    h_dmaou, dmaou_stubs = setup_story_2_to_3_harness()
    dmaou_result = h_dmaou.call_function(STORY_2_TO_3_START,
                                         regs={"ds": CODE_SEG, "es": CODE_SEG},
                                         stub_calls=dmaou_stubs, max_steps=1000)
    dmaou_records = sar_records(h_dmaou, dmaou_result)
    expect(dmaou_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"DMAOU story transition did not stop before third script call: "
           f"{dmaou_result['stopped_reason']}")
    expect(len(stub_regs(dmaou_result, DISP_FONT_INV_THUNK)) == 1,
           failures, "DMAOU story transition did not clear the font layer once")
    expect([r["ax"] for r in stub_regs(dmaou_result, GFX_PALETTE_THUNK)] == [6],
           failures, "DMAOU story transition palette call was not AX=6")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"])
            for r in stub_regs(dmaou_result, DISP_GAME_THUNK)] ==
           [(6, 0x0410, 0x4868, 0x4000)],
           failures, "DMAOU story transition scene blit did not match")
    expect(len(dmaou_records) == 1, failures,
           f"DMAOU story transition SAR calls {len(dmaou_records)} != 1")
    assert_sar_record(failures, dmaou_records, 0, "dmaou.grp", 2, 0xA000, 0x0000)
    expect([(r["si"], r["di"], r["es"]) for r in stub_regs(
        dmaou_result, LOAD_BASE + resolve_proc("opdmo", "decompress_image") - HEADER_SIZE)] ==
           [(0xA000, 0x97C0, CODE_SEG)],
           failures, "DMAOU story transition did not decompress to scene_data_i")

    h_script3, script3_stubs = setup_third_story_script_harness()
    script3_result = h_script3.call_function(
        LOAD_BASE + resolve_proc("opdmo", "run_script_interpreter") - HEADER_SIZE,
        regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=script3_stubs, max_steps=100000)
    expect(script3_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"third post-title story script did not return at SCR_BREAK: "
           f"{script3_result['stopped_reason']}")
    story3_waits = stub_regs(
        script3_result, LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer")
        - HEADER_SIZE)
    wait3_al = [r["ax"] & 0xFF for r in story3_waits]
    expect(len(story3_waits) == 181 and wait3_al.count(0x10) == 174
           and wait3_al.count(0xF0) == 7,
           failures, "third post-title story script wait protocol was not "
                     "174*10h + 7*F0h")
    expect(len(stub_regs(script3_result, DISP_NARR_CHAP4_THUNK)) == 312,
           failures, "third post-title story script did not emit 312 glyph draw calls")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"])
            for r in stub_regs(script3_result, JASHIIN_SPEECH_THUNK)] ==
           [(0, 0x008F, 0x5039)],
           failures, "third post-title story script did not emit one exact scroll clear")
    expect(read_code_word(h_script3, OFF_SCRIPT_PC) == 0x7E8D,
           failures, f"third post-title story script final PC "
                     f"{read_code_word(h_script3, OFF_SCRIPT_PC):04X} != 7E8D")

    assert_story_script_protocol(failures, "sixth post-title story script",
                                 setup_sixth_story_script_harness,
                                 0x8016, 157, 2, 298, 2)
    assert_story_script_protocol(failures, "seventh post-title story script",
                                 setup_seventh_story_script_harness,
                                 0x8071, 91, 0, 176, 0)

    h_apparition, apparition_stubs = setup_apparition_overlay_harness()
    apparition_result = h_apparition.call_function(
        APPARITION_OVERLAY_START, regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=apparition_stubs, max_steps=100)
    expect(apparition_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"apparition overlay did not stop before sixth script call: "
           f"{apparition_result['stopped_reason']}")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"],
             (r["es"] - CODE_SEG) & 0xFFFF)
            for r in stub_regs(apparition_result, DISP_DATA_7420_THUNK)] ==
           [(7, 0x1728, 0x2230, 0x0000, 0x2000)],
           failures, "apparition overlay dispatch did not match AL=7 "
                     "BX=1728 CX=2230 DI=0 ES=CS+2000")

    assert_story_script_protocol(failures, "eighth post-title story script",
                                 setup_eighth_story_script_harness,
                                 0x8075, 4, 2, 0, 1)
    assert_story_script_protocol(failures, "ninth post-title story script",
                                 setup_ninth_story_script_harness,
                                 0x8136, 193, 6, 364, 2)
    assert_story_script_protocol(failures, "tenth post-title story script",
                                 setup_tenth_story_script_harness,
                                 0x81D8, 162, 3, 300, 2)
    assert_story_script_protocol(failures, "eleventh post-title story script",
                                 setup_eleventh_story_script_harness,
                                 0x8223, 75, 2, 138, 1)
    assert_story_script_protocol(failures, "twelfth post-title story script",
                                 setup_twelfth_story_script_harness,
                                 0x862C, 1033, 22, 1984, 7)
    assert_story_script_protocol(failures, "thirteenth post-title story script",
                                 setup_thirteenth_story_script_harness,
                                 0x872E, 258, 10, 472, 3)
    assert_story_script_protocol(failures, "fourteenth post-title story script",
                                 setup_fourteenth_story_script_harness,
                                 0x87DB, 173, 7, 316, 2)
    assert_story_script_protocol(failures, "fifteenth post-title story script",
                                 setup_fifteenth_story_script_harness,
                                 0x883C, 97, 3, 180, 1)
    assert_story_script_protocol(failures, "sixteenth post-title story script",
                                 setup_sixteenth_story_script_harness,
                                 0x8BA4, 605, 16, 1142, 5)
    assert_story_script_protocol(failures, "seventeenth post-title story script",
                                 setup_seventeenth_story_script_harness,
                                 0x8BA5, 1, 0, 0, 0)
    assert_story_script_protocol(failures, "eighteenth post-title story script",
                                 setup_eighteenth_story_script_harness,
                                 0x8C0B, 102, 3, 188, 1)
    assert_story_script_protocol(failures, "nineteenth post-title story script",
                                 setup_nineteenth_story_script_harness,
                                 0x8C50, 69, 2, 126, 1)
    assert_story_script_protocol(failures, "twentieth post-title story script",
                                 setup_twentieth_story_script_harness,
                                 0x8FBC, 795, 22, 1492, 7)

    h_isi, isi_stubs = setup_apparition_remove_isi_harness()
    isi_result = h_isi.call_function(
        APPARITION_REMOVE_ISI_START, regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=isi_stubs, max_steps=1000)
    expect(isi_result["stopped_reason"] == "returned_to_sentinel", failures,
           f"apparition removal/ISI setup did not reach call 8: "
           f"{isi_result['stopped_reason']}")
    busy_target = LOAD_BASE + resolve_proc("opdmo", "busy_wait_delay") - HEADER_SIZE
    story_wait_target = LOAD_BASE + resolve_proc("opdmo", "wait_story_scene_timer") - HEADER_SIZE
    expect([r["ax"] & 0xFF for r in stub_regs(isi_result, busy_target)] == [2, 3],
           failures, "apparition removal busy waits were not AL=2 then AL=3")
    expect([r["ax"] & 0xFF for r in stub_regs(isi_result, story_wait_target)] == [0x0F],
           failures, "apparition removal story wait was not AL=0F")
    expect([(r["bx"], r["cx"], r["di"], (r["es"] - CODE_SEG) & 0xFFFF)
            for r in stub_regs(isi_result, DISP_GAME_THUNK)] ==
           [(0x1728, 0x2230, 0, 0x2000), (0x1728, 0x2230, 0, 0x2000)],
           failures, "apparition removal WAKU restoration calls did not match")
    isi_records = sar_records(h_isi, isi_result)
    expect(len(isi_records) == 1, failures,
           f"apparition removal/ISI setup SAR calls {len(isi_records)} != 1")
    assert_sar_record(failures, isi_records, 0, "isi.grp", 2, 0xA000, 0)
    expect([(r["bx"], r["cx"]) for r in stub_regs(isi_result, GFX_MODE_THUNK)] ==
           [(0x0410, 0x4868)],
           failures, "ISI setup gfx_mode geometry did not match")

    h_reveal, reveal_stubs = setup_isi_reveal_harness()
    reveal_result = h_reveal.call_function(
        ISI_REVEAL_START, regs={"ds": CODE_SEG, "es": CODE_SEG},
        stub_calls=reveal_stubs, max_steps=100)
    expect([r["ax"] for r in stub_regs(reveal_result, GFX_PALETTE_THUNK)] == [7],
           failures, "ISI reveal palette was not AX=7")
    expect([(r["ax"] & 0xFF, r["bx"], r["cx"], r["di"])
            for r in stub_regs(reveal_result, GFX_UPDATE_THUNK)] ==
           [(0xFF, 0x0410, 0x4868, 0x4000)],
           failures, "ISI reveal gfx_update did not match")

    if failures:
        print("opdemo opening sequence oracle mismatches:")
        for failure in failures:
            print(f"  - {failure}")
        print("VERDICT: FAIL")
        return 1

    print("opdemo opening sequence oracle: ttl3, NEC, HOU, DMAOU, sprite scripts, title asset reload, title display handoff, title color/exit flow, opening_next_scene, and post-title story setup match")
    print("VERDICT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
