#include "cavern_transition.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"

#include <stdlib.h>
#include <string.h>

enum {
    PLAYER_START_POSITION = 0x0080,
    PLAYER_MAP_SCROLL_ROW = 0x0082,
    PLAYER_FACING_DIRECTION = 0x00C2,
    PLAYER_POSE = 0x00E7,
    PLAYER_BOSS_INTRO_FLAG = 0x00C3,
    GVAR_ANIM_SPEED = 0xFF33,
    MAP_LOAD_BASE = 0xC000,
    MAP_SEG_PTR = 0xC00C,
    PLAYFIELD_X = 48,
    PLAYFIELD_Y = 14,
    PLAYFIELD_COLS = 28,
    PLAYFIELD_ROWS = 18,
    TILE_SIDE = 8,
    FMAN_TILE_DATA = 0x0333,
};

static const u8 HERO_PALETTE[16] = {
    0x00, 0x01, 0x02, 0x03, 0x08, 0x09, 0x0A, 0x0B,
    0x10, 0x11, 0x12, 0x13, 0x18, 0x19, 0x1A, 0x1B,
};

static u16 read_u16(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static void write_u16(u8 *memory, u16 offset, u16 value) {
    memory[offset] = (u8)value;
    memory[(u16)(offset + 1)] = (u8)(value >> 8);
}

static int load_raw(const char *name, u8 *out, size_t capacity,
                    size_t *out_size) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    if (!file || size < 4) {
        free(file);
        return -1;
    }
    const size_t declared = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (declared > size - 4 || declared > capacity) {
        free(file);
        return -1;
    }
    memcpy(out, file + 4, declared);
    free(file);
    if (out_size) *out_size = declared;
    return 0;
}

static int load_fill(const char *name, u8 *out, size_t capacity,
                     size_t expected_size) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    size_t decoded_size = 0;
    u8 *decoded = file ? fill_buffer_decompress(file, size, &decoded_size)
                       : NULL;
    free(file);
    if (!decoded || decoded_size != expected_size || decoded_size > capacity) {
        free(decoded);
        return -1;
    }
    memcpy(out, decoded, decoded_size);
    free(decoded);
    return 0;
}

/* 200FIGHT:process_map_seg_updates. The MDT contains absolute game-segment
 * pointers: each condition is [flag word pointer, mask byte], followed by
 * [destination word pointer, replacement word] records and FFFF terminators. */
static int process_map_seg_updates(u8 *game_seg) {
    u16 si = read_u16(game_seg, MAP_SEG_PTR);
    for (u16 groups = 0; groups < 0x100; ++groups) {
        const u16 flag_ptr = read_u16(game_seg, si);
        if (flag_ptr == 0xFFFF) return 0;
        const u8 mask = game_seg[(u16)(si + 2)];
        si = (u16)(si + 3);
        const int apply = (mask & game_seg[flag_ptr]) != 0;
        for (u16 records = 0; records < 0x100; ++records) {
            const u16 dest = read_u16(game_seg, si);
            if (dest == 0xFFFF) {
                si = (u16)(si + 2);
                break;
            }
            if (apply)
                write_u16(game_seg, dest,
                          read_u16(game_seg, (u16)(si + 2)));
            si = (u16)(si + 4);
            if (records == 0xFF) return -1;
        }
    }
    return -1;
}

/* 200FIGHT:scroll_byte_dispatch_a and fill_scroll_column. MDT columns are
 * independent 64-cell streams; the top two bits select these four forms. */
static int decode_map(zeliard_cavern_transition_t *transition,
                      const u8 *map, size_t map_size) {
    if (map_size < 0x1B) return -1;
    const u16 width = (u16)(map[2] | ((u16)map[3] << 8));
    if (width == 0 || width > 240) return -1;
    size_t si = 0x1B;
    memset(transition->map_tiles, 0, sizeof(transition->map_tiles));
    for (u16 col = 0; col < width; ++col) {
        u8 row = 0;
        while (row < 0x40) {
            if (si >= map_size) return -1;
            const u8 packed = map[si++];
            u8 count;
            u8 tile;
            switch (packed >> 6) {
            case 0:
                count = (u8)(packed + 1);
                if (si >= map_size) return -1;
                tile = map[si++];
                break;
            case 1:
                count = (u8)(((packed >> 4) & 3) + 2);
                tile = (u8)((packed & 0x0F) + 1);
                break;
            case 2:
                count = (u8)(packed & 0x3F);
                tile = 0;
                if (count == 0) continue;
                break;
            default:
                count = 1;
                tile = (u8)(packed & 0x3F);
                break;
            }
            while (count-- && row < 0x40)
                transition->map_tiles[(size_t)row++ * width + col] = tile;
        }
    }
    transition->map_width = width;
    return 0;
}

/* 200FIGHT stages MPP through the GF planar conversion before
 * 206GFMCA:4259 consumes packed pixels. Decode the source three-plane tile
 * directly: each row is three big-endian words and each pixel uses two
 * adjacent bits from every plane. */
static void decode_pattern_tiles(zeliard_cavern_transition_t *transition,
                                 const u8 *patterns) {
    /* GFMCA:41E7 treats zero as an empty tile. For nonzero AL it decrements
     * the ID, multiplies by 30h, and adds 8030h, so MPP+0000..002F is the
     * map's metadata/index block and tile N begins at MPP + N*30h. */
    memset(transition->pattern_tiles, 0, sizeof(transition->pattern_tiles));
    for (u8 tile = 1; tile < 26; ++tile) {
        const u8 *src = patterns + (size_t)tile * 48;
        u8 *dst = transition->pattern_tiles + (size_t)tile * 64;
        for (u8 row = 0; row < 8; ++row) {
            const u16 p1 = (u16)(((u16)src[0] << 8) | src[1]);
            const u16 p2 = (u16)(((u16)src[2] << 8) | src[3]);
            const u16 p3 = (u16)(((u16)src[4] << 8) | src[5]);
            src += 6;
            for (u8 pixel = 0; pixel < 8; ++pixel) {
                const u8 high_bit = (u8)(15 - pixel * 2);
                const u8 low_bit = (u8)(high_bit - 1);
                const u8 high = (u8)((((p3 >> high_bit) & 1) << 2) |
                    (((p2 >> high_bit) & 1) << 1) |
                    ((p1 >> high_bit) & 1));
                const u8 low = (u8)((((p3 >> low_bit) & 1) << 2) |
                    (((p2 >> low_bit) & 1) << 1) |
                    ((p1 >> low_bit) & 1));
                *dst++ = (u8)((high << 3) | low);
            }
        }
    }
}

static void draw_background(zeliard_cavern_transition_t *transition,
                            const u8 *game_seg, u8 *vga) {
    memcpy(transition->background, vga, sizeof(transition->background));
    const u16 start_col = read_u16(game_seg, PLAYER_START_POSITION);
    const u8 start_row = game_seg[PLAYER_MAP_SCROLL_ROW];
    for (u8 screen_row = 0; screen_row < PLAYFIELD_ROWS; ++screen_row) {
        const u8 map_row = (u8)((start_row + screen_row) & 0x3F);
        for (u8 screen_col = 0; screen_col < PLAYFIELD_COLS; ++screen_col) {
            const u16 map_col = (u16)((start_col + screen_col) %
                                      transition->map_width);
            const u8 tile = transition->map_tiles[
                (size_t)map_row * transition->map_width + map_col];
            const u8 *pixels = transition->pattern_tiles +
                (size_t)(tile < 26 ? tile : 0) * 64;
            for (u8 row = 0; row < TILE_SIDE; ++row) {
                u8 *dest = vga +
                    (size_t)(PLAYFIELD_Y + screen_row * 8 + row) * 320 +
                    PLAYFIELD_X + screen_col * 8;
                memcpy(dest, pixels + row * 8, 8);
            }
        }
    }
    memcpy(transition->background, vga, sizeof(transition->background));
}

static int fman_pixel(const u8 *tile, u8 row, u8 x) {
    const u16 p0 = (u16)(((u16)tile[row * 4] << 8) | tile[row * 4 + 1]);
    const u16 p1 = (u16)(((u16)tile[row * 4 + 2] << 8) | tile[row * 4 + 3]);
    const u16 combined = (u16)(p0 | p1);
    const u16 row_mask = (u16)~(combined | (combined >> 1) |
                                (u16)(combined << 2));
    const u8 s1 = (u8)(15 - x * 2);
    const u8 s2 = (u8)(14 - x * 2);
    if (((row_mask >> s2) & 3) == 3) return -1;
    const u8 nibble = (u8)((((p1 >> s1) & 1) << 3) |
        (((p0 >> s1) & 1) << 2) | (((p1 >> s2) & 1) << 1) |
        ((p0 >> s2) & 1));
    return HERO_PALETTE[nibble];
}

static void draw_fman_layer(const zeliard_cavern_transition_t *transition,
                            u16 frame_base, u8 frame, int x, int y,
                            u8 *vga) {
    const u8 *indices = transition->fman + frame_base + (frame & 3u) * 9u;
    for (u8 cell = 0; cell < 9; ++cell) {
        const u8 tile_index = indices[cell];
        if (tile_index == 0) continue;
        const size_t tile_offset = FMAN_TILE_DATA + (size_t)tile_index * 32;
        if (tile_offset + 32 > sizeof(transition->fman)) continue;
        const u8 *tile = transition->fman + tile_offset;
        const int cell_x = x + (cell / 3) * 8;
        const int cell_y = y + (cell % 3) * 8;
        for (u8 row = 0; row < 8; ++row) {
            for (u8 col = 0; col < 8; ++col) {
                const int color = fman_pixel(tile, row, col);
                const int px = cell_x + col;
                const int py = cell_y + row;
                if (color >= 0 && px >= 0 && px < 320 && py >= 0 && py < 200)
                    vga[(size_t)py * 320 + px] = (u8)color;
            }
        }
    }
}

static void draw_hero(zeliard_cavern_transition_t *transition, u8 *vga) {
    const int x = ((int)transition->packed_x * 4) % 320;
    const u8 frame = (u8)(transition->pose & 3);
    if (transition->direction) {
        draw_fman_layer(transition, 0x075, frame, x, 0x6E, vga);
        draw_fman_layer(transition, 0x1B9, frame, x, 0x6E, vga);
    } else {
        draw_fman_layer(transition, 0x000, frame, x, 0x6E, vga);
        draw_fman_layer(transition, 0x117, frame, x, 0x6E, vga);
    }
}

static void render_step(zeliard_cavern_transition_t *transition,
                        u8 *game_seg, u8 *vga) {
    memcpy(vga, transition->background, sizeof(transition->background));
    transition->pose++;
    game_seg[PLAYER_POSE] = transition->pose;
    if (transition->direction)
        transition->packed_x = (u8)(transition->packed_x - 2);
    else
        transition->packed_x = (u8)(transition->packed_x + 2);
    draw_hero(transition, vga);
    transition->step++;
}

int zeliard_cavern_transition_begin(zeliard_cavern_transition_t *transition,
                                    u8 *game_seg, size_t game_size,
                                    u8 *vga, size_t vga_size) {
    if (!transition || !game_seg || game_size < 0x10000 || !vga ||
        vga_size < 0x10000) return -1;
    memset(transition, 0, sizeof(*transition));
    u8 patterns[26 * 48];
    size_t map_size = 0;
    if (load_raw("mp10.mdt", game_seg + MAP_LOAD_BASE,
                 game_size - MAP_LOAD_BASE, &map_size) ||
        process_map_seg_updates(game_seg) ||
        decode_map(transition, game_seg + MAP_LOAD_BASE, map_size) ||
        load_fill("mpp1.grp", patterns, sizeof(patterns), sizeof(patterns)) ||
        load_fill("fman.grp", transition->fman, sizeof(transition->fman),
                  sizeof(transition->fman))) return -2;
    decode_pattern_tiles(transition, patterns);
    palette_set_game_mcga();
    draw_background(transition, game_seg, vga);

    transition->direction = game_seg[PLAYER_BOSS_INTRO_FLAG] ? 1 : 0;
    transition->packed_x = transition->direction ? 0x40 : 0xA6;
    transition->pose = game_seg[PLAYER_POSE];
    transition->wait_target = (u8)(4u * game_seg[GVAR_ANIM_SPEED]);
    if (transition->wait_target == 0) transition->wait_target = 1;
    if (transition->direction) game_seg[PLAYER_FACING_DIRECTION] |= 1;
    else game_seg[PLAYER_FACING_DIRECTION] &= 0xFE;
    transition->active = 1;
    render_step(transition, game_seg, vga);
    return 0;
}

int zeliard_cavern_transition_advance_pit(
    zeliard_cavern_transition_t *transition,
    u8 *game_seg, size_t game_size,
    u8 *vga, size_t vga_size, u32 pit_ticks) {
    if (!transition || !transition->active || !game_seg ||
        game_size < 0x10000 || !vga || vga_size < 0x10000) return 0;
    int frames = 0;
    while (pit_ticks--) {
        if (++transition->wait_ticks < transition->wait_target) continue;
        transition->wait_ticks = 0;
        if (transition->step >= ZEL_CAVERN_TRANSITION_STEPS) {
            memcpy(vga, transition->background,
                   sizeof(transition->background));
            transition->active = 0;
            transition->complete = 1;
            frames++;
            break;
        }
        render_step(transition, game_seg, vga);
        frames++;
    }
    return frames;
}
