/* Zeliard web-port engine entry point.
 *
 * The reconstructed game loads OPDMO first. The opening demo itself owns the
 * copyright/title card, so there is no separate title scene before it.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "core/input.h"
#include "core/timer.h"
#include "render/palette.h"
#include "game/opening.h"
#include "game/town_runtime.h"
#include "audio/opening_audio.h"
#include "load/game_loader.h"
#include "platform/platform.h"

#include <stdlib.h>
#include <string.h>

#ifdef __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

typedef enum {
    SCENE_TITLE = 0, /* Reserved for API compatibility; OPDMO owns the title. */
    SCENE_OPENING = 1,
    SCENE_GAME = 2
} game_scene_t;

static game_scene_t g_scene = SCENE_OPENING;
static int g_paused;
static u8 g_game_segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE];
static u8 g_game_vga[ZELIARD_GAME_SEGMENT_SIZE];
static zeliard_game_exec_state_t g_game_exec;
static zeliard_town_runtime_t g_town_runtime;
static zel_input_state_t g_input;
static u32 g_input_subtick_accum;

static bool game_fetch_asset(void *context, const char *name,
                             u8 **data, size_t *size) {
    (void)context;
    *data = platform_load_asset(name, size);
    return *data != NULL;
}

static bool game_loader_service(void *context,
                                const zeliard_game_bootstrap_call_t *call,
                                zeliard_game_exec_state_t *state) {
    (void)context;
    (void)state;
    platform_log("game loader service: kind=%u AL=%u AH=%u ref=%04X ES=CS+%04X DI=%04X",
                 (unsigned)call->kind, call->al, call->ah, call->ref_offset,
                 call->es_delta, call->dest_offset);
    return true;
}

static bool game_load_direct(const char *name, u16 destination) {
    size_t size = 0;
    u8 *data = platform_load_asset(name, &size);
    if (!data || size > (size_t)ZELIARD_GAME_SEGMENT_SIZE - destination) {
        free(data);
        return false;
    }
    memcpy(g_game_segments[0] + destination, data, size);
    free(data);
    return true;
}

static void game_memory_init(void) {
    memset(g_game_segments, 0, sizeof(g_game_segments));
    memset(g_game_vga, 0, sizeof(g_game_vga));
    memset(&g_game_exec, 0, sizeof(g_game_exec));
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        g_game_exec.segment[i] = g_game_segments[i];
        g_game_exec.segment_size[i] = ZELIARD_GAME_SEGMENT_SIZE;
    }
    if (!game_load_direct("stdply.bin", 0)) {
        platform_log("game bootstrap: stdply.bin load failed");
    }
    if (!game_load_direct("gmmcga.bin", 0x2000)) {
        platform_log("game bootstrap: gmmcga.bin load failed");
    }
    /* zeliad.asm:init_game_globals stores the default F9 speed at FF33. */
    g_game_segments[0][0xFF33] = 5;
    zel_input_init(&g_input, g_game_segments[0]);
}

static void consume_opening_advance(void) {
    if (g_scene != SCENE_OPENING)
        return;
    opening_key_advance();
    if (opening_credits_exit_waiting())
        zel_opening_audio_begin_transition_fade();
    zel_opening_audio_sync_phase(opening_phase_id());
}

static void apply_input_actions(u32 actions) {
    if (actions & ZEL_INPUT_ACTION_TOGGLE_MUSIC)
        zel_opening_audio_toggle_music();
    if (actions & ZEL_INPUT_ACTION_TOGGLE_SOUND)
        zel_opening_audio_toggle_sound();
    if ((actions & ZEL_INPUT_ACTION_ESCAPE) && !g_paused) {
        opening_pause_overlay_show();
        g_paused = 1;
        zel_opening_audio_pause();
    }
    if (actions & ZEL_INPUT_ACTION_SPACE) {
        if (g_paused) {
            g_game_segments[0][0xFF1D] = 0;
            opening_pause_overlay_hide();
            g_paused = 0;
            zel_opening_audio_resume();
        } else if (g_scene == SCENE_OPENING) {
            g_game_segments[0][0xFF1D] = 0;
            consume_opening_advance();
        }
    }
    if ((actions & ZEL_INPUT_ACTION_ENTER) && !g_paused) {
        if (g_scene == SCENE_OPENING) {
            g_game_segments[0][0xFF29] = 0;
            consume_opening_advance();
        }
    }
}

static bool enter_game_scene(void) {
    const zeliard_game_exec_services_t services = {
        .fetch_asset = game_fetch_asset,
        .loader_service = game_loader_service,
    };
    /* 100OPDMO:transition_out_to_game loads the ordinary DOS file game.bin
     * at CS:A000, sets AX=FFFFh, then jumps through CS:[6A73] = A000h. */
    if (!game_load_direct("game.bin", 0xA000)) {
        platform_log("game bootstrap: game.bin load failed");
        return false;
    }
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = true,
        .gfx_mode = 4,
        .sword = g_game_segments[0][0x92],
        .shield = g_game_segments[0][0x93],
        .selected_spell = g_game_segments[0][0x9D],
        .music_track_count = g_game_segments[0][0xA0],
        .current_area_id = g_game_segments[0][0xC4],
        .level_music_source = g_game_segments[0][0xC000],
        .town_sprite_source = g_game_segments[0][0xC001],
    };
    if (!zeliard_game_execute_bootstrap(&g_game_exec, &input, &services) ||
        !g_game_exec.branched ||
        g_game_exec.branch_target != ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP) {
        platform_log("game bootstrap: game.asm execution failed");
        return false;
    }
    if (zeliard_town_enter_first_frame(&g_town_runtime, &g_game_exec,
                                        g_game_vga, sizeof(g_game_vga)) != 0) {
        platform_log("game bootstrap: first 106TOWN castle frame failed");
        return false;
    }
    memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    /* game.asm:A1E0 resolves CMAP's descriptor byte 00 to record 0 at
     * A363 (MGT1.MSD). 106TOWN:60A9 starts that game_seg:3000 score with
     * INT 60h AX=0 immediately after the initial town draw. */
    if (!zel_audio_play_music(ZEL_MUSIC_MGT1)) {
        platform_log("game bootstrap: MGT1.MSD exact music start failed");
        return false;
    }
    g_scene = SCENE_GAME;
    platform_log("zeliard_tick: first castle frame ready (%u boot, %u town events)",
                 (unsigned)g_game_exec.event_count,
                 (unsigned)g_town_runtime.event_count);
    return true;
}

EXPORT void zeliard_init(void) {
    framebuf_clear(0);
    game_memory_init();
    g_scene = SCENE_OPENING;
    g_paused = 0;
    g_input_subtick_accum = 0;
    zel_opening_audio_init();
    opening_set_sound_cue_sink(zel_opening_audio_write_cue);
    opening_init();
    opening_tick(0);
    zel_opening_audio_sync_phase(opening_phase_id());
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    const int was_paused = g_paused;
    const u32 input_ticks =
        zel_timer_advance_ms(&g_input_subtick_accum, dt_ms);
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], input_ticks));
    if (was_paused) {
        if (g_paused)
            zel_opening_audio_tick(dt_ms);
        return;
    }
    if (g_paused) {
        zel_opening_audio_tick(dt_ms);
        return;
    }
    if (g_scene == SCENE_GAME) {
        const int frames = zeliard_town_advance_pit(
            &g_town_runtime, &g_game_exec, g_game_vga, sizeof(g_game_vga),
            input_ticks, g_game_segments[0][0xFF17]);
        if (frames < 0) {
            platform_log("zeliard_tick: 106TOWN live frame failed (%d)", frames);
        } else if (frames > 0) {
            memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
        }
        if (g_town_runtime.dialog.pending_sound_cue) {
            zel_opening_audio_write_cue(
                g_town_runtime.dialog.pending_sound_cue);
            g_town_runtime.dialog.pending_sound_cue = 0;
        }
        zel_opening_audio_tick(dt_ms);
        return;
    }
    while (dt_ms > 0 || (dt_ms == 0 && g_scene == SCENE_OPENING)) {
        u32 step_ms = dt_ms > 100 ? 100 : dt_ms;
        if (g_scene == SCENE_OPENING) {
            if (opening_credits_exit_waiting())
                zel_opening_audio_begin_transition_fade();
            zel_opening_audio_tick(step_ms);
            if (opening_credits_exit_waiting() &&
                zel_opening_audio_ready_for_transition())
                opening_credits_exit_release();
            opening_tick(step_ms);
            zel_opening_audio_sync_phase(opening_phase_id());
            if (opening_done() && !enter_game_scene())
                break;
        }
        if (dt_ms <= step_ms)
            break;
        dt_ms -= step_ms;
    }
}

/* Browser keycodes enter the same make/break state machine as stick.asm. */
EXPORT void zeliard_key_down(int keycode) {
    apply_input_actions(zel_input_key_down(
        &g_input, g_game_segments[0], keycode));
}

EXPORT void zeliard_key_up(int keycode) {
    zel_input_key_up(&g_input, g_game_segments[0], keycode);
}

EXPORT void zeliard_release_all_keys(void) {
    zel_input_release_all(&g_input, g_game_segments[0], 1);
}

/* Compatibility pulse for older native callers. Browser code uses down/up. */
EXPORT void zeliard_key(int keycode) {
    /* Arm stick.asm's make-edge latch during an idle sample first. */
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], 10));
    u32 actions = zel_input_key_down(&g_input, g_game_segments[0], keycode);
    actions |= zel_input_advance_pit(&g_input, g_game_segments[0], 5);
    apply_input_actions(actions);
    zel_input_key_up(&g_input, g_game_segments[0], keycode);
    apply_input_actions(zel_input_advance_pit(
        &g_input, g_game_segments[0], 5));
}

EXPORT u8*              zeliard_framebuf(void) { return g_framebuf; }
EXPORT u8*              zeliard_rgb_framebuf(void) { return g_rgb_framebuf; }
EXPORT int              zeliard_rgb_framebuf_active(void) { return g_rgb_framebuf_active; }
EXPORT palette_color_t* zeliard_palette(void)  { return g_palette; }
EXPORT int              zeliard_width(void)    { return ZELIARD_WIDTH; }
EXPORT int              zeliard_height(void)   { return ZELIARD_HEIGHT; }
EXPORT int              zeliard_scene(void)    { return (int)g_scene; }
EXPORT int              zeliard_phase(void)    { return opening_phase_id(); }
EXPORT u32              zeliard_phase_elapsed(void) { return opening_phase_elapsed_ms(); }
EXPORT int              zeliard_music_track(void) { return zel_opening_audio_music_track(); }
EXPORT void             zeliard_music_complete(int track) { zel_opening_audio_music_complete(track); }
EXPORT int              zeliard_music_attenuation(void) { return zel_opening_audio_attenuation(); }
EXPORT int              zeliard_paused(void) { return g_paused; }
EXPORT int              zeliard_music_enabled(void) { return zel_opening_audio_music_enabled(); }
EXPORT int              zeliard_sound_enabled(void) { return zel_opening_audio_sound_enabled(); }
EXPORT int              zeliard_sound_cue(void) { return (int)zel_opening_audio_take_cue(); }
EXPORT int              zeliard_audio_pcm(short *stereo, int frames) {
    return frames > 0 ? (int)zel_opening_audio_read_pcm(stereo, (size_t)frames) : 0;
}
EXPORT int              zeliard_audio_pcm_available(void) { return (int)zel_opening_audio_pcm_available(); }
EXPORT int              zeliard_exact_music_driver(void) { return zel_opening_audio_exact_driver_active(); }
EXPORT void             zeliard_audio_set_sample_rate(int sample_rate) { zel_opening_audio_set_sample_rate(sample_rate); }
EXPORT u32              zeliard_audio_opl_write_count(void) { return zel_opening_audio_opl_write_count(); }
EXPORT u32              zeliard_audio_generated_peak(void) { return zel_opening_audio_generated_peak(); }
EXPORT u32              zeliard_audio_cue_serial(void) { return zel_opening_audio_cue_serial(); }
EXPORT void             zeliard_opening_set_phase_for_test(int phase) {
    opening_set_phase_for_test(phase);
    zel_opening_audio_sync_phase(opening_phase_id());
}
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_word(void) { return opening_nec_hou_sprite_debug_word(); }
#ifndef __EMSCRIPTEN__
int zeliard_test_town_dialog_active(void) { return g_town_runtime.dialog.active; }
#endif
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_slots(void) { return opening_nec_hou_sprite_debug_slots(); }
EXPORT int              zeliard_room_kind(void) { return (int)g_town_runtime.room.kind; }
EXPORT int              zeliard_test_enter_room(int kind) {
    if (g_scene != SCENE_GAME || g_town_runtime.room.active ||
        (kind != ZEL_ROOM_KING && kind != ZEL_ROOM_SAGE &&
         kind != ZEL_ROOM_VIEWING)) return -1;
    const int result = zeliard_room_enter(
        &g_town_runtime.room, (zeliard_room_kind_t)kind,
        g_game_segments[0], sizeof(g_game_segments[0]),
        g_game_vga, sizeof(g_game_vga));
    if (!result) memcpy(g_framebuf, g_game_vga, ZELIARD_FB_SIZE);
    return result;
}

#if !defined(__EMSCRIPTEN__) && !defined(ZELIARD_NO_MAIN)
int main(void) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    return 0;
}
#endif
