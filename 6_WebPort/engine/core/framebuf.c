#include "framebuf.h"
#include <string.h>

u8 g_framebuf[ZELIARD_FB_SIZE];
u8 g_rgb_framebuf[ZELIARD_FB_SIZE * 3];
int g_rgb_framebuf_active;

void framebuf_clear(u8 index) {
    memset(g_framebuf, index, ZELIARD_FB_SIZE);
    framebuf_rgb_disable();
}

void framebuf_set_pixel(int x, int y, u8 index) {
    if ((unsigned)x >= ZELIARD_WIDTH || (unsigned)y >= ZELIARD_HEIGHT) return;
    g_framebuf[y * ZELIARD_WIDTH + x] = index;
}

u8 framebuf_get_pixel(int x, int y) {
    if ((unsigned)x >= ZELIARD_WIDTH || (unsigned)y >= ZELIARD_HEIGHT) return 0;
    return g_framebuf[y * ZELIARD_WIDTH + x];
}

void framebuf_rgb_disable(void) {
    g_rgb_framebuf_active = 0;
}
