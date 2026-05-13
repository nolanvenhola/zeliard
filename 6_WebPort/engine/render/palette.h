#ifndef ZELIARD_PALETTE_H
#define ZELIARD_PALETTE_H

#include "../core/types.h"

/* The active 256-entry VGA DAC palette.  Each entry is RGB in 0-255 range
 * (converted from the original 6-bit DAC values by left-shifting 2).
 *
 * The original game switches palettes per scene (P1=Opening, P2=Title,
 * P3=Gameplay) via the gfx-driver function 4 dispatch slot.  See
 * CLAUDE.md "Captured Palettes" section for the source captures.
 */
typedef struct { u8 r, g, b; } palette_color_t;
extern palette_color_t g_palette[256];

void palette_set_default(void);  /* Title palette (P2) as a starting point. */

#endif
