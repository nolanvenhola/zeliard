/* Zeliard web-port engine entry point.
 *
 * The reconstructed game loads OPDMO first. The opening demo itself owns the
 * copyright/title card, so there is no separate title scene before it.
 */

#include "core/types.h"
#include "core/framebuf.h"
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
        .save_tileset_source = g_game_segments[0][0xC000],
        .save_map_source = g_game_segments[0][0xC001],
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
    g_scene = SCENE_GAME;
    zel_opening_audio_stop();
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
    zel_opening_audio_init();
    opening_set_sound_cue_sink(zel_opening_audio_write_cue);
    opening_init();
    opening_tick(0);
    zel_opening_audio_sync_phase(opening_phase_id());
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    if (g_paused) {
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

/* Browser keycodes map to the scan-code actions in stick.asm:654-710. */
EXPORT void zeliard_key(int keycode) {
    if (keycode == 112) { /* F1 -> gvar_timer_counter bit 1000h */
        zel_opening_audio_toggle_music();
        return;
    }
    if (keycode == 113) { /* F2 -> gvar_timer_counter bit 2000h */
        zel_opening_audio_toggle_sound();
        return;
    }
    if (keycode == 27) { /* ESC -> gvar_timer_counter bit 0008h */
        if (!g_paused) {
            opening_pause_overlay_show();
            g_paused = 1;
            zel_opening_audio_pause();
        }
        return;
    }
    if (g_paused) {
        /* The blocking pause loop exits on gvar_spacebar_state, then clears it. */
        if (keycode == 32) {
            opening_pause_overlay_hide();
            g_paused = 0;
            zel_opening_audio_resume();
        }
        return;
    }
    if ((keycode == 13 || keycode == 32) && g_scene == SCENE_OPENING) {
        opening_key_advance();
        if (opening_credits_exit_waiting())
            zel_opening_audio_begin_transition_fade();
        zel_opening_audio_sync_phase(opening_phase_id());
    }
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
EXPORT void             zeliard_opening_set_phase_for_test(int phase) {
    opening_set_phase_for_test(phase);
    zel_opening_audio_sync_phase(opening_phase_id());
}
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_word(void) { return opening_nec_hou_sprite_debug_word(); }
EXPORT u32              zeliard_opening_nec_hou_sprite_debug_slots(void) { return opening_nec_hou_sprite_debug_slots(); }

#if !defined(__EMSCRIPTEN__) && !defined(ZELIARD_NO_MAIN)
int main(void) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    return 0;
}
#endif
