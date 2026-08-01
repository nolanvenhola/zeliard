#include "room_mcga.h"

#include <string.h>

static u16 rol16(u16 value) {
    return (u16)((value << 1) | (value >> 15));
}

static void shift_plane_bit(u16 *plane, u16 *value) {
    *plane = rol16(*plane);
    *value = (u16)((*value << 1) | (*plane & 1));
}

static void shift_plane_triplet(u16 *p0, u16 *p1, u16 *p2, u16 *value) {
    shift_plane_bit(p2, value);
    shift_plane_bit(p1, value);
    shift_plane_bit(p0, value);
}

int zeliard_gmmcga_prepare_room_tiles(const u8 *planes, size_t planes_size,
                                      u8 *tiles, size_t tiles_size,
                                      u16 tile_count) {
    const size_t bytes = (size_t)tile_count * 0x30u;
    if (!planes || !tiles || tiles_size < bytes)
        return -1;

    memset(tiles, 0, bytes);

    for (u16 tile = 0; tile < tile_count; ++tile) {
        const size_t tile_source = (size_t)tile * 0x30u;
        u8 *dst = tiles + (size_t)tile * 0x30u;
        for (u8 row = 0; row < 8; ++row) {
            const size_t source = tile_source + (size_t)row * 6u;
            const u8 b0 = source < planes_size ? planes[source] : 0;
            const u8 b1 = source + 1 < planes_size ? planes[source + 1] : 0;
            const u8 b2 = source + 2 < planes_size ? planes[source + 2] : 0;
            const u8 b3 = source + 3 < planes_size ? planes[source + 3] : 0;
            const u8 b4 = source + 4 < planes_size ? planes[source + 4] : 0;
            const u8 b5 = source + 5 < planes_size ? planes[source + 5] : 0;
            u16 p0 = (u16)((b0 << 8) | b1);
            u16 p1 = (u16)((b2 << 8) | b3);
            u16 p2 = (u16)((b4 << 8) | b5);
            u16 ax = p2;
            for (u8 group = 0; group < 2; ++group) {
                for (u8 bit = 0; bit < 5; ++bit)
                    shift_plane_triplet(&p0, &p1, &p2, &ax);
                shift_plane_bit(&p2, &ax);
                dst[0] = (u8)ax;
                dst[1] = (u8)(ax >> 8);
                shift_plane_bit(&p1, &ax);
                shift_plane_bit(&p0, &ax);
                shift_plane_triplet(&p0, &p1, &p2, &ax);
                shift_plane_triplet(&p0, &p1, &p2, &ax);
                dst[2] = (u8)ax;
                dst += 3;
            }
        }
    }
    return 0;
}

int zeliard_gtmcga_draw_room_glyph(const u8 *tiles, size_t tiles_size,
                                   u8 *vga, size_t vga_size,
                                   u8 glyph, u16 bx) {
    const size_t source = (size_t)glyph * 0x30u;
    const u8 x = (u8)(bx >> 8);
    const u8 y = (u8)bx;
    if (!tiles || !vga || source + 0x30u > tiles_size ||
        (size_t)y * 320u + (size_t)x * 8u + 7u + 7u * 320u >= vga_size)
        return -1;

    const u8 *src = tiles + source;
    size_t dst = (size_t)y * 320u + (size_t)x * 8u;
    for (u8 row = 0; row < 8; ++row, dst += 320) {
        for (u8 group = 0; group < 2; ++group) {
            const u8 b0 = *src++;
            const u8 b1 = *src++;
            const u8 b2 = *src++;
            const u16 shifted_dx = (u16)(((u16)b0 | ((u16)b1 << 8)) >> 2);
            vga[dst + group * 4u + 0] = (u8)(b1 >> 2);
            vga[dst + group * 4u + 1] = (u8)((u8)shifted_dx >> 2);
            vga[dst + group * 4u + 2] =
                (u8)(((b0 << 2) | (b2 >> 6)) & 0x3F);
            vga[dst + group * 4u + 3] = (u8)(b2 & 0x3F);
        }
    }
    return 0;
}

int zeliard_gtmcga_draw_room_tile_grid(
    const u8 *tile_ids, size_t tile_id_size, u8 rows, u8 columns,
    const u8 *tiles, size_t tiles_size,
    u8 *vga, size_t vga_size, u16 bx) {
    if (!tile_ids || !rows || !columns ||
        tile_id_size < (size_t)rows * columns) return -1;
    for (u8 row = 0; row < rows; ++row) {
        for (u8 col = 0; col < columns; ++col) {
            const u16 position = (u16)(bx + ((u16)col << 8) + row * 8u);
            if (zeliard_gtmcga_draw_room_glyph(
                    tiles, tiles_size, vga, vga_size,
                    tile_ids[(size_t)row * columns + col], position))
                return -2;
        }
    }
    return 0;
}

int zeliard_gtmcga_draw_room_grid(const u8 *tile_ids, size_t tile_id_size,
                                  const u8 *tiles, size_t tiles_size,
                                  u8 *vga, size_t vga_size, u16 bx) {
    return zeliard_gtmcga_draw_room_tile_grid(
        tile_ids, tile_id_size, 8, 12, tiles, tiles_size,
        vga, vga_size, bx);
}
