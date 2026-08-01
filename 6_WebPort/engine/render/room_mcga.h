#ifndef ZELIARD_ROOM_MCGA_H
#define ZELIARD_ROOM_MCGA_H

#include "../core/types.h"

/* GMMCGA:2C2A, resident dispatch slot CS:2044. */
int zeliard_gmmcga_prepare_room_tiles(const u8 *planes, size_t planes_size,
                                      u8 *tiles, size_t tiles_size,
                                      u16 tile_count);

/* GTMCGA:371C, loaded dispatch slot CS:3016. */
int zeliard_gtmcga_draw_room_glyph(const u8 *tiles, size_t tiles_size,
                                   u8 *vga, size_t vga_size,
                                   u8 glyph, u16 bx);

/* Mechanical form of the 8-row by 12-column loops shared by KINGP/KENJP. */
int zeliard_gtmcga_draw_room_grid(const u8 *tile_ids, size_t tile_id_size,
                                  const u8 *tiles, size_t tiles_size,
                                  u8 *vga, size_t vga_size, u16 bx);

#endif
