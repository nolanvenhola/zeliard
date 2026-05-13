#ifndef ZELIARD_PALETTE_H
#define ZELIARD_PALETTE_H

#include "../core/types.h"

/* 256-entry VGA DAC palette.  Each entry is RGB in 0-255 range (the
 * source DAC values are 6-bit; the capture tooling already scaled to
 * 8-bit, so no conversion needed here).
 *
 * The original game switches palettes per scene via the gfx-driver
 * function-4 dispatch slot (see write_palette_byte_mcga in
 * 3_Assembly/tasm/working/zelres1/code/105GDMCA.asm:2201).  We mirror
 * that behaviour via palette_set_scene(); the three captured palettes
 * are embedded as static data in palettes_extracted.h.
 */
typedef struct { u8 r, g, b; } palette_color_t;
extern palette_color_t g_palette[256];

typedef enum {
    PALETTE_OPENING  = 1,  /* P1 — opening cinematic */
    PALETTE_TITLE    = 2,  /* P2 — title screen */
    PALETTE_GAMEPLAY = 3,  /* P3 — in-game */
} palette_scene_t;

void palette_set_scene(palette_scene_t scene);

#endif
