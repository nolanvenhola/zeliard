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

    const u8 input_bh = (u8)(bx >> 8);
    const u16 position = (u8)bx;
    const u16 saved_ax = input_bh;
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

int zeliard_gmmcga_draw_life_scale(u8 *vga, size_t vga_size, u16 ax) {
    (void)ax;
    return zeliard_gmmcga_draw_status_line(vga, vga_size, 0, 0x0210, 0x8800);
}

static u16 life_width(u16 value) {
    return value > 0x0320 ? 0x0064 : (u16)(value >> 3);
}

static void fill_life_columns(u8 *vga, u16 di, u16 count,
                              u8 rows, u8 and_mask, u8 or_mask) {
    for (u16 column = 0; column < count; ++column) {
        u16 at = (u16)(di + column);
        for (u8 row = 0; row < rows; ++row) {
            vga[at] = (u8)((vga[at] & and_mask) | or_mask);
            at = (u16)(at + 320);
        }
    }
}

int zeliard_gmmcga_draw_life_max(u8 *vga, size_t vga_size,
                                 const u8 *game_seg, size_t game_size) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x00B4)
        return -1;
    const u16 width = life_width(read_u16_le(game_seg + 0x00B2));
    fill_life_columns(vga, 0xCC14, width, 6, 0x2D, 0x12);
    return 0;
}

int zeliard_gmmcga_draw_life_current(u8 *vga, size_t vga_size,
                                     const u8 *game_seg, size_t game_size) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x0092)
        return -1;
    const u16 width = life_width(read_u16_le(game_seg + 0x0090));
    fill_life_columns(vga, 0xCC14, width, 5, 0x12, 0x09);
    fill_life_columns(vga, (u16)(0xCC14 + width), (u16)(100 - width),
                      5, 0x12, 0x00);
    return 0;
}

static int draw_text_record(u8 *vga, size_t vga_size,
                            u8 *game_seg, size_t game_size, u16 si,
                            u8 color, u8 paired_color) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x10000 ||
        (size_t)si + 4 > game_size)
        return -1;

    game_seg[0x2CBD] = color;
    game_seg[0x2CBE] = paired_color;
    const u8 x = game_seg[si++];
    const u8 y = game_seg[si++];
    const u8 x_offset = game_seg[si++];
    const u8 count = game_seg[si++];
    if ((size_t)si + count > game_size) return -1;

    u16 di = (u16)((u16)y * 320u + (u16)x * 4u + x_offset);
    const u16 font = read_u16_le(game_seg + 0xF504);
    for (u8 index = 0; index < count; ++index) {
        const u8 character = game_seg[si++];
        const u16 glyph = (u16)(font + (u16)(u8)(character - 0x20) * 8u);
        const u16 char_di = di;
        for (u8 row = 0; row < 8; ++row) {
            u8 bits = game_seg[(u16)(glyph + row)];
            u16 pixel = (u16)(char_di + (u16)row * 320u);
            for (u8 column = 0; column < 4; ++column) {
                const u8 set = (u8)(bits >> 7);
                bits <<= 1;
                if (set) {
                    vga[pixel] = game_seg[0x2CBD];
                    vga[(u16)(pixel + 1)] = game_seg[0x2CBE];
                }
                pixel = (u16)(pixel + 1);
            }
        }
        di = (u16)(di + 5);
    }
    return 0;
}

int zeliard_gmmcga_draw_town_text_record(u8 *vga, size_t vga_size,
                                         u8 *game_seg, size_t game_size,
                                         u16 si) {
    return draw_text_record(vga, vga_size, game_seg, game_size, si,
                            0x09, 0x2D);
}

int zeliard_gmmcga_draw_hud_label(u8 *vga, size_t vga_size,
                                  u8 *game_seg, size_t game_size, u16 si) {
    return draw_text_record(vga, vga_size, game_seg, game_size, si,
                            0x1B, 0x12);
}

static void format_hud_digits(u8 *game_seg, u32 value) {
    u32 divisor = 1000000;
    for (u8 index = 0; index < 7; ++index) {
        game_seg[0x2433 + index] = (u8)(value / divisor);
        value %= divisor;
        divisor /= 10;
    }
    for (u8 index = 0; index < 6 && game_seg[0x2433 + index] == 0; ++index)
        game_seg[0x2433 + index] = 0xFF;
}

static void render_hud_digits(u8 *vga, u8 *game_seg, u16 digit_ptr,
                              u8 x, u8 y, u8 count, int half_pixel) {
    const u16 font = read_u16_le(game_seg + 0xF502);
    const u8 color = game_seg[0x24EB];
    u16 destination = (u16)((u16)y * 320u + (u16)x * 4u +
                            (half_pixel ? 2u : 0u));
    for (u8 digit_index = 0; digit_index < count; ++digit_index) {
        const u8 digit = game_seg[(u16)(digit_ptr + digit_index)];
        for (u8 row = 0; row < 7; ++row)
            memset(vga + (u16)(destination + (u16)row * 320u), 0x05, 6);
        if (digit != 0xFF) {
            const u16 glyph = (u16)(font + (u16)digit * 8u);
            for (u8 row = 0; row < 7; ++row) {
                const u8 bits = game_seg[(u16)(glyph + row)];
                u16 pixel = (u16)(destination + (u16)row * 320u);
                for (u8 column = 0; column < 6; ++column) {
                    if (bits & (u8)(0x20u >> column)) vga[pixel] = color;
                    pixel = (u16)(pixel + 1);
                }
            }
        }
        destination = (u16)(destination + 6);
    }
}

static int draw_hud_number(u8 *vga, size_t vga_size,
                           u8 *game_seg, size_t game_size, u32 value,
                           u16 digit_ptr, u8 x, u8 y, u8 count,
                           int half_pixel) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x10000)
        return -1;
    format_hud_digits(game_seg, value);
    render_hud_digits(vga, game_seg, digit_ptr, x, y, count, half_pixel);
    return 0;
}

int zeliard_gmmcga_draw_almas(u8 *vga, size_t vga_size,
                              u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x008D) return -1;
    return draw_hud_number(vga, vga_size, game_seg, game_size,
                           read_u16_le(game_seg + 0x008B), 0x2435,
                           0x26, 0xBB, 5, 1);
}

int zeliard_gmmcga_draw_gold(u8 *vga, size_t vga_size,
                             u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x0088) return -1;
    const u32 value = ((u32)game_seg[0x0085] << 16) |
                      read_u16_le(game_seg + 0x0086);
    return draw_hud_number(vga, vga_size, game_seg, game_size, value,
                           0x2434, 0x13, 0xBB, 6, 1);
}

int zeliard_gmmcga_draw_spell_charge(u8 *vga, size_t vga_size,
                                     u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x01AB) return -1;
    const u8 selected = game_seg[0x009D];
    const u16 charge_address = (u16)(0x00AB + (u8)(selected - 1));
    return draw_hud_number(vga, vga_size, game_seg, game_size,
                           game_seg[charge_address], 0x2437,
                           0x37, 0xBB, 3, 1);
}

int zeliard_gmmcga_draw_shield_hp(u8 *vga, size_t vga_size,
                                  u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x0096) return -1;
    if (game_seg[0x0093] == 0) return 0;
    return draw_hud_number(vga, vga_size, game_seg, game_size,
                           read_u16_le(game_seg + 0x0094), 0x2437,
                           0x3E, 0xBB, 3, 1);
}

int zeliard_gmmcga_draw_first_frame_hud(u8 *vga, size_t vga_size,
                                        u8 *game_seg, size_t game_size,
                                        u16 town_text_si) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x10000)
        return -1;
    if (zeliard_gmmcga_draw_status_line(vga, vga_size, 0, 0x0204, 0x2100) ||
        zeliard_gmmcga_draw_status_line(vga, vga_size, 0, 0x021C, 0x4200) ||
        zeliard_gmmcga_draw_status_line(vga, vga_size, 0, 0x481C, 0x4200) ||
        zeliard_gmmcga_draw_life_scale(vga, vga_size, 0))
        return -1;
    static const u16 label_addresses[] = {0x6C93, 0x6C9B, 0x6CA4, 0x6CAC};
    for (size_t i = 0; i < sizeof(label_addresses) / sizeof(label_addresses[0]); ++i) {
        if (zeliard_gmmcga_draw_hud_label(vga, vga_size, game_seg,
                                          game_size, label_addresses[i]))
            return -1;
    }
    if (zeliard_gmmcga_draw_life_max(vga, vga_size, game_seg, game_size) ||
        zeliard_gmmcga_draw_life_current(vga, vga_size, game_seg, game_size) ||
        zeliard_gmmcga_draw_almas(vga, vga_size, game_seg, game_size) ||
        zeliard_gmmcga_draw_gold(vga, vga_size, game_seg, game_size) ||
        zeliard_gmmcga_draw_spell_charge(vga, vga_size, game_seg, game_size) ||
        zeliard_gmmcga_draw_shield_hp(vga, vga_size, game_seg, game_size))
        return -1;
    return zeliard_gmmcga_draw_town_text_record(vga, vga_size, game_seg,
                                                 game_size, town_text_si);
}

int zeliard_gtmcga_capture_playfield(const u8 *vga, size_t vga_size,
                                     u8 *game_seg, size_t game_size) {
    if (!vga || vga_size < 0x10000 || !game_seg || game_size < 0x10000)
        return -1;

    size_t out = 0xA000;
    for (u16 block = 0; block < 0x1C; ++block) {
        size_t source = 0x61B0 + block * 8;
        for (u16 row = 0; row < 0x18; ++row) {
            memcpy(game_seg + out, vga + source, 8);
            out += 8;
            source += 320;
        }
    }
    return 0;
}

static void unpack_mcga_triplet(const u8 *source, u8 *destination,
                                int combine) {
    const u16 word = read_u16_le(source);
    u16 dx = word;
    const u8 third = source[2];
    u16 bx = (u16)(((u16)(u8)word << 8) | third);
    dx >>= 2;
    const u8 pixels[4] = {
        (u8)(dx >> 8),
        (u8)((u8)dx >> 2),
        (u8)(((bx << 2) >> 8) & 0x3F),
        (u8)(third & 0x3F),
    };
    for (u8 i = 0; i < 4; ++i) {
        if (combine) destination[i] |= pixels[i];
        else destination[i] = pixels[i];
    }
}

int zeliard_gtmcga_draw_npc_tiles(const u8 *tile_ids, size_t tile_id_size,
                                  const u8 *game_data, size_t game_data_size,
                                  u8 *vga, size_t vga_size) {
    if (!tile_ids || tile_id_size < 6 || !game_data ||
        game_data_size < 0x10000 || !vga || vga_size < 0x10000)
        return -1;
    size_t destination = 0xFA00;
    for (u8 tile = 0; tile < 6; ++tile) {
        size_t source = 0x8100u + (size_t)tile_ids[tile] * 0x30u;
        if (source + 0x30 > game_data_size) return -1;
        for (u8 group = 0; group < 0x10; ++group) {
            unpack_mcga_triplet(game_data + source, vga + destination, 0);
            source += 3;
            destination += 4;
        }
    }
    return 0;
}

int zeliard_gtmcga_draw_player_tiles(const u8 *tile_ids, size_t tile_id_size,
                                     const u8 *game_data, size_t game_data_size,
                                     const u8 *mask_data, size_t mask_data_size,
                                     u8 *vga, size_t vga_size) {
    if (!tile_ids || tile_id_size < 6 || !game_data ||
        game_data_size < 0x10000 || !mask_data ||
        mask_data_size < 0x10000 || !vga || vga_size < 0x10000)
        return -1;
    size_t destination = 0xFA00;
    for (u8 tile = 0; tile < 6; ++tile) {
        const u8 tile_id = tile_ids[tile];
        size_t source = 0x6000u + (size_t)tile_id * 0x30u;
        size_t mask = 0x8000u + (size_t)tile_id * 8u;
        if (source + 0x30 > game_data_size || mask + 8 > mask_data_size)
            return -1;
        for (u8 row = 0; row < 8; ++row) {
            u8 bits = mask_data[mask++];
            for (u8 pixel = 0; pixel < 8; ++pixel) {
                const u8 keep = (bits & 0x80) ? 0xFF : 0x00;
                vga[destination + pixel] &= keep;
                bits <<= 1;
            }
            for (u8 half = 0; half < 2; ++half) {
                unpack_mcga_triplet(game_data + source,
                                    vga + destination + half * 4, 1);
                source += 3;
            }
            destination += 8;
        }
    }
    return 0;
}

static u16 read_at(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static u8 *find_npc(u8 *game_seg, u16 position) {
    u16 at = read_at(game_seg, 0xC00F);
    while (at <= 0xFFF7 && read_at(game_seg, at) != 0xFFFF) {
        if (read_at(game_seg, at) == position) return game_seg + at;
        at = (u16)(at + 8);
    }
    return NULL;
}

static int draw_masked_actor_tile(u8 tile_id, const u8 *game_data,
                                  const u8 *mask_data, u16 source_base,
                                  u16 mask_base, u8 *vga, size_t destination) {
    size_t source = (size_t)source_base + (size_t)tile_id * 0x30u;
    size_t mask = (size_t)mask_base + (size_t)tile_id * 8u;
    for (u8 row = 0; row < 8; ++row) {
        u8 bits = mask_data[mask++];
        for (u8 pixel = 0; pixel < 8; ++pixel) {
            vga[destination + pixel] &= (bits & 0x80) ? 0xFF : 0x00;
            bits <<= 1;
        }
        for (u8 half = 0; half < 2; ++half) {
            unpack_mcga_triplet(game_data + source,
                                vga + destination + half * 4, 1);
            source += 3;
        }
        destination += 8;
    }
    return 0;
}

static int compose_npc_slot(u8 slot, u8 *ids, const u8 *npc,
                            const u8 *game_data, const u8 *mask_data,
                            u8 *vga) {
    const u8 entity = npc[2];
    const u8 side = (entity & 0x80) ? 0 : 4;
    u16 pattern = (u16)(0x4000u + (u16)(entity & 0x7F) * 0x30u +
                        (u16)((npc[4] & 3) + side) * 6u);
    u8 first = 0, count = 3;
    size_t destination = 0xFA00;
    if (slot == 2) count = 6;
    else if (slot == 1) {
        first = 3;
        destination = 0xFAC0;
    } else {
        pattern = (u16)(pattern + 3);
    }
    for (u8 index = first; index < (u8)(first + count); ++index) {
        ids[index] = 0xFF;
        const u8 tile = (u8)(game_data[pattern++] - 1);
        draw_masked_actor_tile(tile, game_data, mask_data, 0x4100, 0x7000,
                               vga, destination);
        destination += 0x40;
    }
    return 0;
}

int zeliard_gtmcga_render_town_actors(u8 *game_seg, size_t game_size,
                                      u8 *game_data, size_t game_data_size,
                                      const u8 *mask_data, size_t mask_data_size,
                                      u8 *vga, size_t vga_size) {
    if (!game_seg || game_size < 0x10000 || !game_data ||
        game_data_size < 0x10000 || !mask_data ||
        mask_data_size < 0x10000 || !vga || vga_size < 0x10000)
        return -1;

    u16 npc_at = read_at(game_seg, 0xC00F);
    while (npc_at <= 0xFFF7 && read_at(game_seg, npc_at) != 0xFFFF) {
        const u16 column = read_at(game_seg, npc_at);
        const u16 map_at = (u16)(0xC01C + column * 8u);
        game_seg[npc_at + 3] = game_seg[map_at];
        game_seg[map_at] = 0xFD;
        npc_at = (u16)(npc_at + 8);
    }

    const u8 player_col = game_seg[0x0083];
    const u16 tile_ptr = read_at(game_seg, 0xFF2A);
    const u16 tile_at = (u16)(tile_ptr + (u16)(player_col + 4) * 8u + 5u);
    u8 ids[6];
    memcpy(ids, game_seg + tile_at, 3);
    memcpy(ids + 3, game_seg + (u16)(tile_at + 8), 3);
    u16 position = (u16)(read_at(game_seg, 0x0080) + player_col + 4);
    for (u8 group = 0; group < 2; ++group) {
        u8 *id = ids + group * 3;
        if (*id == 0xFD) {
            u8 *npc = find_npc(game_seg, position);
            if (!npc) return -2;
            u8 value = npc[3];
            while (value == 0xFD) {
                npc = find_npc(game_seg, position);
                if (!npc) return -2;
                do npc += 8; while (read_at(npc, 0) != position);
                value = npc[3];
            }
            *id = value;
        }
        ++position;
    }
    if (zeliard_gtmcga_draw_npc_tiles(ids, sizeof(ids), game_data,
                                       game_data_size, vga, vga_size))
        return -3;

    const u16 npc_column = (u16)(read_at(game_seg, 0x0080) + player_col + 3);
    const u8 column_ids[3] = {
        game_seg[(u16)(tile_at - 8)], game_seg[tile_at],
        game_seg[(u16)(tile_at + 8)],
    };
    npc_at = read_at(game_seg, 0xC00F);
    while (npc_at <= 0xFFF7 && read_at(game_seg, npc_at) != 0xFFFF) {
        for (u8 index = 0; index < 3; ++index) {
            if (column_ids[index] == 0xFD &&
                read_at(game_seg, npc_at) == (u16)(npc_column + index)) {
                compose_npc_slot((u8)(3 - index), ids, game_seg + npc_at,
                                 game_data, mask_data, vga);
                break;
            }
        }
        npc_at = (u16)(npc_at + 8);
    }

    const u16 walk = (game_seg[0x00C2] & 1) ? 0x6A3B : 0x6A59;
    const u16 player_ids = (u16)(walk + (u16)game_seg[0x00E7] * 6u);
    return zeliard_gtmcga_draw_player_tiles(game_seg + player_ids, 6,
                                             game_data, game_data_size,
                                             mask_data, mask_data_size,
                                             vga, vga_size);
}

static void draw_town_map_tile(const u8 *game_data, u8 tile_id,
                               u8 *vga, u16 destination) {
    size_t source = 0x8100u + (size_t)tile_id * 0x30u;
    for (u8 row = 0; row < 8; ++row) {
        unpack_mcga_triplet(game_data + source, vga + destination, 0);
        unpack_mcga_triplet(game_data + source + 3, vga + destination + 4, 0);
        source += 6;
        destination = (u16)(destination + 320);
    }
}

int zeliard_gtmcga_update_town_frame(u8 *game_seg, size_t game_size,
                                     const u8 *game_data, size_t game_data_size,
                                     u8 *vga, size_t vga_size) {
    if (!game_seg || game_size < 0x10000 || !game_data ||
        game_data_size < 0x10000 || !vga || vga_size < 0x10000)
        return -1;
    memset(game_seg + 0x42EF, 0, 0x200);
    const u8 player_col = game_seg[0x0083];
    u16 map = (u16)(read_at(game_seg, 0xFF2A) + 0x20);
    u16 tile_vga = 0x61B0;
    for (u8 column = 0; column < 0x1C; ++column) {
        if (column == player_col && column != 0x1B) {
            size_t source = 0xFA00;
            u16 destination = (u16)(0x93B0 + (u16)player_col * 8u);
            for (u8 side = 0; side < 2; ++side) {
                u16 row_at = (u16)(destination + side * 8u);
                for (u8 row = 0; row < 24; ++row) {
                    memcpy(vga + row_at, vga + source, 8);
                    source += 8;
                    row_at = (u16)(row_at + 320);
                }
            }
        }
        for (u8 row = 0; row < 8; ++row) {
            const u16 cursor = (u16)(0xE000 + (u16)column * 8u + row);
            const u8 tile = game_seg[map++];
            if (game_seg[cursor] != tile) {
                const u8 previous = game_seg[cursor];
                game_seg[cursor] = 0xFE;
                if (previous == 0xFF) continue;
                game_seg[cursor] = tile;
                if (tile != 0xFF) {
                    const u16 destination =
                        (u16)(tile_vga + (u16)row * 8u * 320u);
                    draw_town_map_tile(game_data, tile, vga, destination);
                }
            }
        }
        tile_vga = (u16)(tile_vga + 8);
    }
    return 0;
}
