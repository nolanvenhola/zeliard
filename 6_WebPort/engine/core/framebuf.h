#ifndef ZELIARD_FRAMEBUF_H
#define ZELIARD_FRAMEBUF_H

#include "types.h"

/* The framebuffer is a 320x200 paletted (8-bit index) buffer matching the
 * original VGA mode 13h.  The shell converts indices to RGBA at present-time
 * using the current palette.
 */
extern u8 g_framebuf[ZELIARD_FB_SIZE];
extern u8 g_rgb_framebuf[ZELIARD_FB_SIZE * 3];
extern int g_rgb_framebuf_active;

void framebuf_clear(u8 index);
void framebuf_set_pixel(int x, int y, u8 index);
u8   framebuf_get_pixel(int x, int y);
void framebuf_rgb_disable(void);

#endif
