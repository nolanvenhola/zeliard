/* Zeliard web-port engine entry point.
 *
 * M1 scope: prove the WASM <-> JS pipeline works end-to-end.
 *   zeliard_init()      -- one-time setup; initialises framebuffer + palette
 *   zeliard_tick(dt)    -- per-frame update; for M1 just animates a test
 *                          pattern so we can see the framebuffer is live
 *   zeliard_framebuf()  -- returns pointer to the 320x200 paletted buffer
 *   zeliard_palette()   -- returns pointer to the 256-entry palette
 *
 * Once the pipeline lights up we'll swap the test pattern for real GRP
 * rendering (M1.5: title-logo render of 131TTL3G.grp).
 */

#include "core/types.h"
#include "core/framebuf.h"
#include "render/palette.h"
#include "platform/platform.h"

#ifdef __EMSCRIPTEN__
#  include <emscripten.h>
#  define EXPORT EMSCRIPTEN_KEEPALIVE
#else
#  define EXPORT
#endif

static u32 g_tick_count = 0;

EXPORT void zeliard_init(void) {
    palette_set_default();
    framebuf_clear(0);
    platform_log("zeliard_init: framebuffer %dx%d ready", ZELIARD_WIDTH, ZELIARD_HEIGHT);
}

/* Draws a moving test pattern so we can confirm the framebuffer is live and
 * the JS side is presenting frames at the correct rate.  Replaced by real
 * scene rendering once GRP decoding lands. */
static void draw_test_pattern(u32 t) {
    /* Diagonal gradient bands that scroll with the tick counter. */
    for (int y = 0; y < ZELIARD_HEIGHT; y++) {
        for (int x = 0; x < ZELIARD_WIDTH; x++) {
            u8 v = (u8)((x + y + t) & 0xFF);
            g_framebuf[y * ZELIARD_WIDTH + x] = v;
        }
    }
    /* Plant the title-logo palette indices in known corners so we can verify
     * the palette table is being read correctly. */
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
            g_framebuf[y * ZELIARD_WIDTH + x] = 0xAA;  /* yellow */
            g_framebuf[y * ZELIARD_WIDTH + (ZELIARD_WIDTH - 16 + x)] = 0xCC;  /* blue */
            g_framebuf[(ZELIARD_HEIGHT - 16 + y) * ZELIARD_WIDTH + x] = 0x88;  /* dark blue */
            g_framebuf[(ZELIARD_HEIGHT - 16 + y) * ZELIARD_WIDTH + (ZELIARD_WIDTH - 16 + x)] = 0x00;  /* black */
        }
    }
}

EXPORT void zeliard_tick(u32 dt_ms) {
    (void)dt_ms;
    g_tick_count++;
    draw_test_pattern(g_tick_count);
}

EXPORT u8* zeliard_framebuf(void) {
    return g_framebuf;
}

EXPORT palette_color_t* zeliard_palette(void) {
    return g_palette;
}

EXPORT int zeliard_width(void)  { return ZELIARD_WIDTH; }
EXPORT int zeliard_height(void) { return ZELIARD_HEIGHT; }

#ifndef __EMSCRIPTEN__
/* Native entry point for the parity-test harness. */
#include <stdio.h>
int main(int argc, char **argv) {
    zeliard_init();
    zeliard_tick(0);
    platform_log("native build: framebuffer initialised, exiting");
    (void)argc; (void)argv;
    return 0;
}
#endif
