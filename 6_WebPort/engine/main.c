/* Zeliard web-port engine entry point.
 *
 * Scene progression:
 *   SCENE_OPENING  → run_opening_demo_main (M2: simplified slideshow)
 *   SCENE_TITLE    → ttl3.grp logo (M1.5)
 *
 * ENTER or SPACE (forwarded via zeliard_key()) skips the opening.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "render/palette.h"
#include "load/grp.h"
#include "game/opening.h"
#include "platform/platform.h"
#include <stdlib.h>
#include <string.h>

#ifdef __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

/* ---- title logo (M1.5) -------------------------------------------------- */
/* TTL3G geometry from CLAUDE.md "VERIFIED: Zeliard Title Logo":
 *   rows=65, cl=112 → call_size=260, blit_calls=112 → 260×112 image
 *   VGA byte offset 4828 → row 15, col 28 */
static const int  TTL3_ROWS    = 65;
static const int  TTL3_CL      = 112;
static const int  TTL3_VGA_X   = 28;
static const int  TTL3_VGA_Y   = 15;
static const char TTL3_ASSET[] = "ttl3.grp";

static u8 *g_title_image   = NULL;
static int  g_title_w      = 0;
static int  g_title_h      = 0;

static void load_title_image(void) {
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(TTL3_ASSET, &file_size);
    if (!file_data) {
        platform_log("load_title_image: missing %s", TTL3_ASSET);
        return;
    }
    g_title_image = grp_decode(file_data, file_size, TTL3_ROWS, TTL3_CL,
                                &g_title_w, &g_title_h);
    free(file_data);
    if (g_title_image)
        platform_log("load_title_image: %dx%d ready", g_title_w, g_title_h);
}

static void blit_title_image(void) {
    if (!g_title_image) return;
    for (int y = 0; y < g_title_h; y++) {
        int dy = y + TTL3_VGA_Y;
        if (dy >= ZELIARD_HEIGHT) break;
        for (int x = 0; x < g_title_w; x++) {
            int dx = x + TTL3_VGA_X;
            if (dx >= ZELIARD_WIDTH) break;
            u8 v = g_title_image[y * g_title_w + x];
            if (v == 0) continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] = v;
        }
    }
}

/* ---- scene state -------------------------------------------------------- */
typedef enum { SCENE_OPENING = 0, SCENE_TITLE = 1 } game_scene_t;
static game_scene_t g_scene        = SCENE_OPENING;
static int          g_skip_pending = 0;

/* ---- public API --------------------------------------------------------- */

EXPORT void zeliard_init(void) {
    framebuf_clear(0);
    opening_init();   /* sets PALETTE_OPENING and pre-decodes opening images */
    load_title_image();
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    if (g_scene == SCENE_OPENING) {
        if (g_skip_pending) {
            g_skip_pending = 0;
            opening_skip();
        }
        opening_tick(dt_ms);
        if (opening_done()) {
            g_scene = SCENE_TITLE;
            palette_set_scene(PALETTE_TITLE);
            framebuf_clear(0);
            platform_log("zeliard_tick: switching to SCENE_TITLE");
        }
    } else {
        framebuf_clear(0);
        blit_title_image();
    }
}

/* Called by the TypeScript shell on ENTER (13) or SPACE (32) keydown. */
EXPORT void zeliard_key(int keycode) {
    if (keycode == 13 || keycode == 32) {
        if (g_scene == SCENE_OPENING)
            g_skip_pending = 1;
    }
}

EXPORT u8*             zeliard_framebuf(void) { return g_framebuf; }
EXPORT palette_color_t* zeliard_palette(void) { return g_palette; }
EXPORT int             zeliard_width(void)    { return ZELIARD_WIDTH; }
EXPORT int             zeliard_height(void)   { return ZELIARD_HEIGHT; }

#ifndef __EMSCRIPTEN__
#include <stdio.h>
int main(int argc, char **argv) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    (void)argc; (void)argv;
    return 0;
}
#endif
