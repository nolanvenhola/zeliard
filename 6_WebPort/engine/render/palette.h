#ifndef ZELIARD_PALETTE_H
#define ZELIARD_PALETTE_H

#include "../core/types.h"

/* 256-entry VGA DAC palette.  Each entry is RGB in 0-255 range (the
 * source DAC values are 6-bit; the capture tooling already scaled to
 * 8-bit, so no conversion needed here).
 *
 * The original game switches palettes per scene via the gfx-driver
 * function-4 dispatch slot (see write_palette_byte_mcga in
 * 3_Assembly/masm/working/zelres1/code/105GDMCA.asm:2201).  We mirror
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
/* game.asm:mcga_palette_handler, the 8x8 additive gameplay DAC. */
void palette_set_game_mcga(void);
void palette_set_opdmo_mcga(u16 ax);
void palette_set_opdmo_mcga_with_rgb0(u16 ax, u8 r0, u8 g0, u8 b0);
void palette_set_opdmo_mcga_from_regs_with_rgb0(const u8 regs[48],
                                                u8 r0, u8 g0, u8 b0);
void palette_set_opdmo_mcga_from_regs(const u8 regs[48]);
palette_color_t palette_opdmo_mcga_step_color(u16 ax, u8 step_row,
                                               u8 color_index,
                                               int override_rgb0,
                                               u8 r0, u8 g0, u8 b0);

#endif
