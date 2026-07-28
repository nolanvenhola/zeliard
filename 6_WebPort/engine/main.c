/* Zeliard web-port engine entry point.
 *
 * The reconstructed game loads OPDMO first. The opening demo itself owns the
 * copyright/title card, so there is no separate title scene before it.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "render/palette.h"
#include "game/opening.h"
#include "audio/opening_audio.h"
#include "platform/platform.h"

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

static void enter_game_scene(void) {
    g_scene = SCENE_GAME;
    zel_opening_audio_stop();
    palette_set_scene(PALETTE_OPENING);
    framebuf_clear(0);
    platform_log("zeliard_tick: switching to SCENE_GAME");
}

EXPORT void zeliard_init(void) {
    framebuf_clear(0);
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
    if (g_paused)
        return;
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
            if (opening_done())
                enter_game_scene();
        } else {
            framebuf_clear(0);
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
