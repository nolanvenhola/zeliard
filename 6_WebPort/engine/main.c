/* Zeliard web-port engine entry point.
 *
 * Scene progression:
 *   SCENE_TITLE    -> full copyright/title framebuffer
 *   SCENE_OPENING  -> opening demo slideshow/text sequence
 *   SCENE_GAME     -> gameplay handoff placeholder
 *
 * ENTER or SPACE advances the current attract/demo phase.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "render/palette.h"
#include "render/font_text.h"
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
static const char TITLE_FULL_ASSET[] = "title_full.bin";

static u8 *g_title_image   = NULL;
static u8 *g_title_frame   = NULL;
static zeliard_font_t g_title_font;
static int  g_title_font_ready = 0;
static int  g_title_w      = 0;
static int  g_title_h      = 0;

static void load_title_framebuffer(void) {
    if (g_title_frame) return;
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(TITLE_FULL_ASSET, &file_size);
    if (!file_data) {
        platform_log("load_title_framebuffer: missing %s", TITLE_FULL_ASSET);
        return;
    }
    if (file_size != ZELIARD_FB_SIZE) {
        platform_log("load_title_framebuffer: bad size %zu for %s", file_size, TITLE_FULL_ASSET);
        free(file_data);
        return;
    }
    g_title_frame = file_data;
    platform_log("load_title_framebuffer: %s ready", TITLE_FULL_ASSET);
}

static void load_title_image(void) {
    if (g_title_image) return;
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
    if (g_title_frame) {
        memcpy(g_framebuf, g_title_frame, ZELIARD_FB_SIZE);
        return;
    }
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
    if (g_title_font_ready) {
        zeliard_font_draw_text(&g_title_font, 36, 136,
                               "Copyright (C)1987,1990 GAME ARTS", 7);
        zeliard_font_draw_text(&g_title_font, 40, 152,
                               "Copyright (C)1990 Sierra On-Line", 7);
    }
}

/* ---- scene state -------------------------------------------------------- */
typedef enum {
    SCENE_TITLE = 0,
    SCENE_OPENING = 1,
    SCENE_GAME = 2
} game_scene_t;

enum {
    TITLE_WAIT_MS = 8000
};

static game_scene_t g_scene        = SCENE_TITLE;
static int          g_skip_pending = 0;
static int          g_title_start_pending = 0;
static u32          g_title_elapsed = 0;

static void enter_opening_scene(void) {
    g_scene = SCENE_OPENING;
    g_skip_pending = 0;
    g_title_start_pending = 0;
    opening_init();
    platform_log("zeliard_tick: switching to SCENE_OPENING");
}

static void enter_game_scene(void) {
    g_scene = SCENE_GAME;
    g_skip_pending = 0;
    g_title_start_pending = 0;
    g_title_elapsed = 0;
    palette_set_scene(PALETTE_OPENING);
    framebuf_clear(0);
    platform_log("zeliard_tick: switching to SCENE_GAME");
}

/* ---- public API --------------------------------------------------------- */

EXPORT void zeliard_init(void) {
    framebuf_clear(0);
    g_scene = SCENE_TITLE;
    g_skip_pending = 0;
    g_title_start_pending = 0;
    g_title_elapsed = 0;
    load_title_framebuffer();
    load_title_image();
    if (!g_title_font_ready)
        g_title_font_ready = zeliard_font_load(&g_title_font);
    palette_set_scene(PALETTE_TITLE);
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    if (g_scene == SCENE_TITLE) {
        if (g_title_start_pending) {
            enter_opening_scene();
            return;
        }
        if (dt_ms >= TITLE_WAIT_MS - g_title_elapsed) {
            enter_opening_scene();
            return;
        }
        g_title_elapsed += dt_ms;
        framebuf_clear(0);
        blit_title_image();
    } else if (g_scene == SCENE_OPENING) {
        if (g_skip_pending) {
            g_skip_pending = 0;
            enter_game_scene();
            return;
        }
        opening_tick(dt_ms);
        if (opening_done()) {
            enter_game_scene();
        }
    } else {
        framebuf_clear(0);
    }
}

/* Called by the TypeScript shell on ENTER (13) or SPACE (32) keydown. */
EXPORT void zeliard_key(int keycode) {
    if (keycode == 13 || keycode == 32) {
        if (g_scene == SCENE_TITLE)
            g_title_start_pending = 1;
        else if (g_scene == SCENE_OPENING)
            g_skip_pending = 1;
    }
}

EXPORT u8*             zeliard_framebuf(void) { return g_framebuf; }
EXPORT palette_color_t* zeliard_palette(void) { return g_palette; }
EXPORT int             zeliard_width(void)    { return ZELIARD_WIDTH; }
EXPORT int             zeliard_height(void)   { return ZELIARD_HEIGHT; }
EXPORT int             zeliard_scene(void)    { return (int)g_scene; }

#if !defined(__EMSCRIPTEN__) && !defined(ZELIARD_NO_MAIN)
#include <stdio.h>
int main(int argc, char **argv) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: done");
    (void)argc; (void)argv;
    return 0;
}
#endif
