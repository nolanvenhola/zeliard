#ifndef ZELIARD_TOWN_BACKGROUND_H
#define ZELIARD_TOWN_BACKGROUND_H

#include "../core/types.h"

/* 207MOLE:0000, MCGA dispatch path (AL=4). The mutable chunk image is the
 * header-stripped runtime payload loaded into its own 64KB code segment. */
int zeliard_mole_render_mcga(u8 *chunk, size_t chunk_size,
                             u8 *vga, size_t vga_size);

/* 208YMPD:3300, MCGA dispatch path (AL=4). The chunk image is the
 * header-stripped runtime payload loaded at offset 3300h. */
int zeliard_ympd_render_mcga(const u8 *chunk, size_t chunk_size,
                             u8 *scratch, size_t scratch_size,
                             u8 *vga, size_t vga_size);

#endif
