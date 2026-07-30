#ifndef ZELIARD_TOWN_MCGA_H
#define ZELIARD_TOWN_MCGA_H

#include "../core/types.h"

typedef struct {
    u16 slot;
    u16 target;
    const char *name;
    u8 town_call_count;
} zeliard_gtmcga_dispatch_t;

typedef struct {
    u16 slot;
    u16 target;
    const char *name;
    u8 town_call_count;
} zeliard_gmmcga_dispatch_t;

size_t zeliard_gtmcga_resolve_town_dispatch(
    const u8 *chunk, size_t chunk_size,
    zeliard_gtmcga_dispatch_t *out, size_t out_count);

size_t zeliard_gmmcga_resolve_town_dispatch(
    const u8 *driver, size_t driver_size,
    zeliard_gmmcga_dispatch_t *out, size_t out_count);

/* GMMCGA:2106, resident dispatch slot CS:2002. */
int zeliard_gmmcga_clear_playfield(u8 *vga, size_t vga_size);

/* GTMCGA:3A71, loaded dispatch slot CS:3026. */
int zeliard_gtmcga_encode_tile_block(u8 *ds, size_t ds_size, u16 si,
                                     u8 *es, size_t es_size, u16 di,
                                     u16 tile_count);

/* GMMCGA:2195, resident dispatch slot CS:2004, normal (AL=0) path. */
int zeliard_gmmcga_draw_status_line(u8 *vga, size_t vga_size,
                                    u16 ax, u16 bx, u16 cx);

#endif
