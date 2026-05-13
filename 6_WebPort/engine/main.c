/* Zeliard web-port engine entry point.
 *
 * M1.5 scope: render the title-logo GRP (131TTL3G.grp / "ttl3.grp") into
 * the framebuffer at its canonical VGA position (col 28, row 15) so we
 * can visually verify the decode pipeline matches the original.
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "render/palette.h"
#include "load/grp.h"
#include "platform/platform.h"
#include <stdlib.h>
#include <string.h>

#ifdef __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

/* TTL3G geometry from CLAUDE.md "VERIFIED: Zeliard Title Logo" trace:
 *   source: rows=65, cl=112 → image 896x65 in 1bpp 2-plane form
 *   output: call_size=260 (=rows*4), blit_calls=112 (=cl) → 260x112 image
 *   blit position: VGA byte offset 4828 → row 15, col 28 */
static const int  TTL3_ROWS    = 65;
static const int  TTL3_CL      = 112;
static const int  TTL3_VGA_X   = 28;
static const int  TTL3_VGA_Y   = 15;
static const char TTL3_ASSET[] = "ttl3.grp";

/* Decoded image cached at init.  M1.5 just blits the same frame each tick;
 * later milestones will animate the full opening cinematic. */
static u8 *g_title_image    = NULL;
static int g_title_image_w  = 0;
static int g_title_image_h  = 0;

static void load_title_image(void) {
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(TTL3_ASSET, &file_size);
    if (!file_data) {
        platform_log("load_title_image: asset load failed: %s", TTL3_ASSET);
        return;
    }
    g_title_image = grp_decode(file_data, file_size, TTL3_ROWS, TTL3_CL,
                                &g_title_image_w, &g_title_image_h);
    free(file_data);
    if (!g_title_image) {
        platform_log("load_title_image: decode failed");
    } else {
        platform_log("load_title_image: %s %dx%d ready", TTL3_ASSET,
                     g_title_image_w, g_title_image_h);
    }
}

static void blit_title_image(void) {
    if (!g_title_image) return;
    for (int y = 0; y < g_title_image_h; y++) {
        int dy = y + TTL3_VGA_Y;
        if (dy >= ZELIARD_HEIGHT) break;
        for (int x = 0; x < g_title_image_w; x++) {
            int dx = x + TTL3_VGA_X;
            if (dx >= ZELIARD_WIDTH) break;
            u8 v = g_title_image[y * g_title_image_w + x];
            if (v == 0) continue;  /* black is the background — leave it */
            g_framebuf[dy * ZELIARD_WIDTH + dx] = v;
        }
    }
}

EXPORT void zeliard_init(void) {
    palette_set_scene(PALETTE_TITLE);
    framebuf_clear(0);
    load_title_image();
    platform_log("zeliard_init: ready (framebuffer %dx%d)", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

EXPORT void zeliard_tick(u32 dt_ms) {
    (void)dt_ms;
    /* For M1.5 the title scene is static — just re-blit each frame so the
     * framebuffer stays correct even if other code clears it. */
    framebuf_clear(0);
    blit_title_image();
}

EXPORT u8* zeliard_framebuf(void) { return g_framebuf; }
EXPORT palette_color_t* zeliard_palette(void) { return g_palette; }
EXPORT int zeliard_width(void)  { return ZELIARD_WIDTH; }
EXPORT int zeliard_height(void) { return ZELIARD_HEIGHT; }

#ifndef __EMSCRIPTEN__
#include <stdio.h>
int main(int argc, char **argv) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: framebuffer initialised, exiting");
    (void)argc; (void)argv;
    return 0;
}
#endif
