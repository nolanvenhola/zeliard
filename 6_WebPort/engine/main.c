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
    zel_opening_audio_init();
    opening_init();
    opening_tick(0);
    zel_opening_audio_sync_phase(opening_phase_id());
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    while (dt_ms > 0 || (dt_ms == 0 && g_scene == SCENE_OPENING)) {
        u32 step_ms = dt_ms > 100 ? 100 : dt_ms;
        if (g_scene == SCENE_OPENING) {
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

/* Called by the TypeScript shell on ENTER (13) or SPACE (32) keydown. */
EXPORT void zeliard_key(int keycode) {
    if ((keycode == 13 || keycode == 32) && g_scene == SCENE_OPENING)
        opening_key_advance();
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
