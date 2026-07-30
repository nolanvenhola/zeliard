#include "town_mcga.h"

#include <stdlib.h>
#include <string.h>

typedef struct {
    u16 slot;
    const char *name;
    u8 call_count;
} town_slot_spec_t;

static const town_slot_spec_t TOWN_GT_SLOTS[] = {
    {0x3002, "gfx_draw_fn", 3}, {0x3004, "gfx_update_fn", 1},
    {0x3006, "gfx_scroll_left_fn", 1}, {0x3008, "gfx_scroll_right_fn", 1},
    {0x300A, "gfx_scroll_right2_fn", 1}, {0x300C, "gfx_scroll_left2_fn", 1},
    {0x300E, "gfx_npc_draw_fn", 1}, {0x3010, "gfx_npc_update_fn", 1},
    {0x3012, "gfx_fn_3012", 1}, {0x3014, "gfx_fn_3014", 1},
    {0x3018, "gfx_cursor_fn", 3}, {0x301A, "gfx_sel_init_fn", 6},
    {0x301C, "gfx_sel_draw_fn", 2}, {0x301E, "gfx_sel_scroll_up_fn", 2},
    {0x3020, "gfx_sel_scroll_dn_fn", 2}, {0x3024, "gfx_ret_fn", 1},
    {0x3026, "gfx_copy_fn", 3},
};

static const town_slot_spec_t TOWN_GM_SLOTS[] = {
    {0x2000, "gfx_fill_fn", 12}, {0x2002, "gfx_clear_fn", 4},
    {0x2004, "gfx_draw_tile_fn", 5}, {0x2006, "gfx_render_a_fn", 1},
    {0x2008, "gfx_render_b_fn", 1}, {0x200E, "gfx_load_img_fn", 4},
    {0x2010, "gfx_draw_map_fn", 2}, {0x2012, "gfx_draw_player_fn", 2},
    {0x2014, "gfx_render_c_fn", 2}, {0x2016, "gfx_render_d_fn", 1},
    {0x2018, "gfx_draw_icon_a_fn", 1}, {0x201A, "gfx_draw_icon_b_fn", 1},
    {0x2022, "gfx_draw_char_fn", 5}, {0x2024, "gfx_scroll_row_fn", 2},
    {0x2026, "gfx_text_layout_a_fn", 1}, {0x2028, "gfx_text_layout_b_fn", 1},
    {0x202A, "gfx_draw_str_fn", 3}, {0x2038, "gfx_clear_row_fn", 1},
    {0x2040, "gfx_blit_fn", 4}, {0x2042, "gfx_refresh_fn", 1},
};

size_t zeliard_gtmcga_resolve_town_dispatch(
    const u8 *chunk, size_t chunk_size,
    zeliard_gtmcga_dispatch_t *out, size_t out_count) {
    const size_t count = sizeof(TOWN_GT_SLOTS) / sizeof(TOWN_GT_SLOTS[0]);
    if (!chunk || !out || out_count < count || chunk_size < 4) return 0;
    const size_t declared = (size_t)chunk[0] | ((size_t)chunk[1] << 8) |
        ((size_t)chunk[2] << 16) | ((size_t)chunk[3] << 24);
    if (declared > chunk_size - 4) return 0;
    for (size_t i = 0; i < count; ++i) {
        const size_t offset = TOWN_GT_SLOTS[i].slot - 0x3000;
        if (offset + 2 > declared) return 0;
        out[i] = (zeliard_gtmcga_dispatch_t){
            .slot = TOWN_GT_SLOTS[i].slot,
            .target = (u16)(chunk[4 + offset] | ((u16)chunk[5 + offset] << 8)),
            .name = TOWN_GT_SLOTS[i].name,
            .town_call_count = TOWN_GT_SLOTS[i].call_count,
        };
    }
    return count;
}

size_t zeliard_gmmcga_resolve_town_dispatch(
    const u8 *driver, size_t driver_size,
    zeliard_gmmcga_dispatch_t *out, size_t out_count) {
    const size_t count = sizeof(TOWN_GM_SLOTS) / sizeof(TOWN_GM_SLOTS[0]);
    if (!driver || !out || out_count < count) return 0;
    for (size_t i = 0; i < count; ++i) {
        const size_t offset = TOWN_GM_SLOTS[i].slot - 0x2000;
        if (offset + 2 > driver_size) return 0;
        out[i] = (zeliard_gmmcga_dispatch_t){
            .slot = TOWN_GM_SLOTS[i].slot,
            .target = (u16)(driver[offset] | ((u16)driver[offset + 1] << 8)),
            .name = TOWN_GM_SLOTS[i].name,
            .town_call_count = TOWN_GM_SLOTS[i].call_count,
        };
    }
    return count;
}

int zeliard_gmmcga_clear_playfield(u8 *vga, size_t vga_size) {
    if (!vga || vga_size < 0x10000) return -1;

    u16 di = 0x11B0;
    for (u16 pass = 0; pass < 8; ++pass) {
        u16 row = di;
        for (u16 block = 0; block < 0x12; ++block) {
            for (u16 x = 0; x < 0xE0; ++x)
                vga[(u16)(row + x)] = 0;
            row = (u16)(row + 0x0A00);
        }
        di = (u16)(di + 0x0140);
    }
    return 0;
}

static u16 read_u16_le(const u8 *data) {
    return (u16)(data[0] | ((u16)data[1] << 8));
}

static u16 byte_swap_u16(u16 value) {
    return (u16)((value << 8) | (value >> 8));
}

static u8 rotate_append(u16 *plane, u16 *accumulator) {
    const u8 carry = (u8)(*plane >> 15);
    *plane = (u16)((*plane << 1) | carry);
    *accumulator = (u16)((*accumulator << 1) | carry);
    return carry;
}

static void append_three_planes(u16 *p0, u16 *p1, u16 *p2, u16 *ax) {
    (void)rotate_append(p2, ax);
    (void)rotate_append(p1, ax);
    (void)rotate_append(p0, ax);
}

int zeliard_gtmcga_encode_tile_block(u8 *ds, size_t ds_size, u16 si,
                                     u8 *es, size_t es_size, u16 di,
                                     u16 tile_count) {
    const size_t source_size = (size_t)tile_count * 0x30;
    const size_t mask_size = (size_t)tile_count * 8;
    if (!ds || !es || (size_t)si + source_size > ds_size ||
        (size_t)di + mask_size > es_size)
        return -1;

    u8 *scratch = source_size ? malloc(source_size) : NULL;
    if (source_size && !scratch) return -1;
    if (source_size) memcpy(scratch, ds + si, source_size);

    size_t source_pos = 0;
    size_t packed_pos = si;
    size_t mask_pos = di;
    for (u16 tile = 0; tile < tile_count; ++tile) {
        for (u16 row = 0; row < 8; ++row) {
            const u16 raw0 = read_u16_le(scratch + source_pos);
            const u16 raw1 = read_u16_le(scratch + source_pos + 2);
            const u16 raw2 = read_u16_le(scratch + source_pos + 4);
            source_pos += 6;

            const u16 occupied = (u16)(raw0 | raw1 | raw2);
            const u16 shared = (u16)(raw0 & raw1 & raw2);
            const u16 keep = (u16)~shared;
            u16 p0 = byte_swap_u16((u16)(raw0 & keep));
            u16 p1 = byte_swap_u16((u16)(raw1 & keep));
            u16 p2 = byte_swap_u16((u16)(raw2 & keep));
            u16 alpha = (u16)~byte_swap_u16(occupied);
            u16 ax = alpha;

            for (u16 half = 0; half < 2; ++half) {
                for (u16 pixel = 0; pixel < 5; ++pixel)
                    append_three_planes(&p0, &p1, &p2, &ax);
                (void)rotate_append(&p2, &ax);
                ds[packed_pos++] = (u8)ax;
                ds[packed_pos++] = (u8)(ax >> 8);
                (void)rotate_append(&p1, &ax);
                (void)rotate_append(&p0, &ax);
                append_three_planes(&p0, &p1, &p2, &ax);
                append_three_planes(&p0, &p1, &p2, &ax);
                ds[packed_pos++] = (u8)ax;
            }

            u8 dl = (u8)p0;
            for (u16 pair = 0; pair < 8; ++pair) {
                const u8 bit_a = (u8)(alpha >> 15);
                alpha = (u16)((alpha << 1) | bit_a);
                const u8 bit_b = (u8)(alpha >> 15);
                alpha = (u16)((alpha << 1) | bit_b);
                const u8 mask_bit = (u8)(bit_a & bit_b);
                dl = (u8)((dl << 1) | mask_bit);
            }
            es[mask_pos++] = dl;
        }
    }
    free(scratch);
    return 0;
}

static void plot_status_column(u8 *vga, u16 di, u8 middle, u8 bottom) {
    vga[di] = 0;
    for (u16 row = 0; row < 8; ++row) {
        di = (u16)(di + 320);
        vga[di] = middle;
    }
    di = (u16)(di + 320);
    vga[di] = bottom;
}

int zeliard_gmmcga_draw_status_line(u8 *vga, size_t vga_size,
                                    u16 ax, u16 bx, u16 cx) {
    if (!vga || vga_size < 0x10000 || (u8)ax != 0) return -1;

    const u8 input_ah = (u8)(ax >> 8);
    const u8 input_bh = (u8)(bx >> 8);
    const u16 position = (u16)(((u16)input_ah << 8) | (u8)bx);
    const u16 saved_ax = (u16)(((u16)input_ah << 8) | input_bh);
    u16 di = (u16)((u16)(320u * (u16)(position + 0x009E)) +
                   saved_ax + 0x0030);
    plot_status_column(vga, di, 0, 0);
    di = (u16)(di + 1);
    for (u16 column = 0; column < (u8)(cx >> 8); ++column) {
        plot_status_column(vga, di, 0x05, 0x2D);
        di = (u16)(di + 1);
    }
    return 0;
}
