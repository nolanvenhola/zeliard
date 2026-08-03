#include "cavern_transition.h"

#include "../core/player_state.h"
#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"

#include <stdlib.h>
#include <string.h>

enum {
    PLAYER_FACING_DIRECTION = 0x00C2,
    PLAYER_POSE = 0x00E7,
    PLAYER_BOSS_INTRO_FLAG = 0x00C3,
    GVAR_ANIM_SPEED = 0xFF33,
    GVAR_COLOR_SELECT = 0xFF36,
    GVAR_FLAG_SHIELD = 0xFF38,
    GVAR_FLAG_CLIMBING = 0xFF39,
    GVAR_FLAG_RIDING = 0xFF3A,
    GVAR_EQUIP_BYTE = 0xFF3D,
    GVAR_HERO_FRAME = 0xFF3F,
    GVAR_FLAG_HERO_STATE = 0xFF40,
    GVAR_WEAPON_STATE = 0xFF41,
    GVAR_SHIELD_SELECT = 0xFF42,
    PLAYFIELD_X = 48,
    PLAYFIELD_Y = 14,
    PLAYFIELD_COLS = 28,
    PLAYFIELD_ROWS = 18,
    ROKA_MAP_SIZE = PLAYFIELD_COLS * PLAYFIELD_ROWS,
    ROKA_TILE_COUNT = 0x7C,
    ROKA_TILE_BYTES = 48,
    GFMCA_ROKA_MAP_FILE_OFFSET = 0x173F,
    FMAN_TILE_DATA = 0x0333,
    FMAN_TILE_COUNT = 0xE6,
    FMAN_TILE_BYTES = 32,
};

static const u8 HERO_PALETTE[16] = {
    0x00, 0x01, 0x02, 0x03, 0x08, 0x09, 0x0A, 0x0B,
    0x10, 0x11, 0x12, 0x13, 0x18, 0x19, 0x1A, 0x1B,
};

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

static u8 roka_transform_component(u8 value) {
    /* 206GFMCA:ah_xform_6to3, selected by drv2_fn_15 with AL=0. */
    if (value == 6) return 3;
    if (value == 7) return 5;
    return value;
}

static u8 roka_transform_pixel(u8 value) {
    return (u8)((roka_transform_component((u8)(value >> 3)) << 3) |
                roka_transform_component((u8)(value & 7)));
}

static void decode_roka_tile(const u8 *src, u8 *dst) {
    /* 200FIGHT first calls GMMCGA:2C2A. It extracts sixteen 3-bit planar
     * pixels from each six-byte source row. 206GFMCA:4614 then pairs those
     * pixels into eight 6-bit MCGA indices and applies transform slot zero. */
    for (u8 row = 0; row < 8; ++row) {
        const u16 plane_0 = (u16)(((u16)src[0] << 8) | src[1]);
        const u16 plane_1 = (u16)(((u16)src[2] << 8) | src[3]);
        const u16 plane_2 = (u16)(((u16)src[4] << 8) | src[5]);
        src += 6;
        for (u8 pixel = 0; pixel < 8; ++pixel) {
            const u8 left_bit = (u8)(15u - pixel * 2u);
            const u8 right_bit = (u8)(left_bit - 1u);
            const u8 left = (u8)((((plane_2 >> left_bit) & 1u) << 2) |
                                 (((plane_1 >> left_bit) & 1u) << 1) |
                                  ((plane_0 >> left_bit) & 1u));
            const u8 right = (u8)((((plane_2 >> right_bit) & 1u) << 2) |
                                  (((plane_1 >> right_bit) & 1u) << 1) |
                                   ((plane_0 >> right_bit) & 1u));
            const u8 packed = (u8)((left << 3) | right);
            *dst++ = packed ? roka_transform_pixel(packed) : 0;
        }
    }
}

static int stage_roka_background(zeliard_cavern_transition_t *transition,
                                 u8 *vga) {
    enum { BANK_SIZE = ROKA_TILE_COUNT * ROKA_TILE_BYTES };
    u8 bank[BANK_SIZE];
    size_t driver_size = 0;
    u8 *driver = platform_load_asset("gfmcga.bin", &driver_size);
    if (!driver ||
        GFMCA_ROKA_MAP_FILE_OFFSET + ROKA_MAP_SIZE > driver_size) {
        platform_log("200FIGHT ROKA staging assets are incomplete");
        free(driver);
        return -1;
    }
    if (load_fill("roka.grp", bank, sizeof(bank), sizeof(bank))) {
        platform_log("200FIGHT ROKA payload decode failed");
        free(driver);
        return -1;
    }

    memcpy(transition->roka_map,
           driver + GFMCA_ROKA_MAP_FILE_OFFSET, ROKA_MAP_SIZE);
    for (u8 tile = 0; tile < ROKA_TILE_COUNT; ++tile)
        decode_roka_tile(bank + (size_t)tile * ROKA_TILE_BYTES,
                         transition->roka_tiles + (size_t)tile * 64);
    free(driver);

    for (u8 row = 0; row < PLAYFIELD_ROWS; ++row) {
        for (u8 col = 0; col < PLAYFIELD_COLS; ++col) {
            const u8 tile = transition->roka_map[row * PLAYFIELD_COLS + col];
            const u8 *pixels = transition->roka_tiles + (size_t)tile * 64;
            for (u8 py = 0; py < 8; ++py) {
                memcpy(vga + (size_t)(PLAYFIELD_Y + row * 8 + py) * 320 +
                           PLAYFIELD_X + col * 8,
                       pixels + py * 8, 8);
            }
        }
    }
    memcpy(transition->background, vga, sizeof(transition->background));
    return 0;
}

static u16 rol16(u16 value, u8 *carry) {
    *carry = (u8)(value >> 15);
    return (u16)((value << 1) | *carry);
}

static u16 fman_expand_word(u16 *plane_a, u16 *plane_b) {
    u16 out = 0;
    for (u8 i = 0; i < 4; ++i) {
        u8 carry;
        *plane_a = rol16(*plane_a, &carry);
        out = (u16)((out << 1) | carry);
        *plane_b = rol16(*plane_b, &carry);
        out = (u16)((out << 1) | carry);
        *plane_a = rol16(*plane_a, &carry);
        out = (u16)((out << 1) | carry);
        *plane_b = rol16(*plane_b, &carry);
        out = (u16)((out << 1) | carry);
    }
    return out;
}

static u8 fman_transparency_mask(u16 source_mask) {
    u8 out = 0;
    for (u8 i = 0; i < 8; ++i) {
        u8 pair = 0;
        for (u8 bit = 0; bit < 2; ++bit) {
            const u8 carry = (u8)(source_mask >> 15);
            source_mask = (u16)((source_mask << 1) | carry);
            pair = (u8)((pair << 1) | carry);
        }
        out = (u8)((out << 1) | (pair == 3));
    }
    return out;
}

static void preprocess_fman(zeliard_cavern_transition_t *transition) {
    /* 206GFMCA:drv2_fn_20 (entry 4EDD): expand each four-plane source
     * row into the two words consumed by mca_fetch_color_lut, while D000
     * receives the eight-bit background-preservation mask. */
    for (u16 tile = 0; tile < FMAN_TILE_COUNT; ++tile) {
        u8 *pixels = transition->fman + FMAN_TILE_DATA +
                     (size_t)tile * FMAN_TILE_BYTES;
        for (u8 row = 0; row < 8; ++row) {
            const u8 *src = pixels + row * 4;
            u16 plane_b = (u16)(((u16)src[0] << 8) | src[1]);
            u16 plane_a = (u16)(((u16)src[2] << 8) | src[3]);
            const u16 combined = (u16)(plane_a | plane_b);
            const u16 spread = (u16)(combined | (combined >> 1) |
                                     (u16)(combined << 1));
            const u16 source_mask = (u16)~spread;
            const u16 first = fman_expand_word(&plane_a, &plane_b);
            const u16 second = fman_expand_word(&plane_a, &plane_b);
            pixels[row * 4] = (u8)first;
            pixels[row * 4 + 1] = (u8)(first >> 8);
            pixels[row * 4 + 2] = (u8)second;
            pixels[row * 4 + 3] = (u8)(second >> 8);
            transition->fman_masks[(size_t)tile * 8 + row] =
                fman_transparency_mask(source_mask);
        }
    }
}

static void compose_fman_cells(zeliard_cavern_transition_t *transition,
                               u16 frame_offset, u8 output_cell,
                               u8 cell_count) {
    const u8 *indices = transition->fman + frame_offset;
    for (u8 cell = 0; cell < cell_count; ++cell) {
        const u8 tile_index = indices[cell];
        const u8 target_cell = (u8)(output_cell + cell);
        if (target_cell >= 9) break;
        if (tile_index == 0) continue;
        const size_t tile_offset = FMAN_TILE_DATA + (size_t)tile_index * 32;
        if (tile_offset + 32 > sizeof(transition->fman)) continue;
        const u8 *tile = transition->fman + tile_offset;
        const u8 *masks = transition->fman_masks + (size_t)tile_index * 8;
        u8 *target = transition->hero_cells + (size_t)target_cell * 64;
        for (u8 row = 0; row < 8; ++row) {
            u16 words[2] = {
                (u16)(tile[row * 4] | ((u16)tile[row * 4 + 1] << 8)),
                (u16)(tile[row * 4 + 2] |
                      ((u16)tile[row * 4 + 3] << 8)),
            };
            for (u8 col = 0; col < 8; ++col) {
                const u8 preserve = (u8)((masks[row] >> (7 - col)) & 1);
                u16 *word = &words[col / 4];
                u8 color = 0;
                for (u8 bit = 0; bit < 4; ++bit) {
                    color = (u8)((color << 1) | (*word >> 15));
                    *word <<= 1;
                }
                if (!preserve) {
                    const size_t pixel = (size_t)row * 8 + col;
                    target[pixel] = HERO_PALETTE[color];
                    transition->hero_coverage[
                        (size_t)target_cell * 64 + pixel] = 1;
                }
            }
        }
    }
}

static u8 shield_state_get(const u8 *game_seg) {
    const u8 shield = game_seg[ZEL_PLAYER_SHIELD];
    if (shield == 0) return 0;
    return shield >= 4 ? 2 : 1;
}

static void compose_ordinary_hero(zeliard_cavern_transition_t *transition,
                                  const u8 *game_seg) {
    const u8 facing = (u8)(game_seg[PLAYER_FACING_DIRECTION] & 1u);
    const u8 pose = game_seg[PLAYER_POSE];
    const u8 shield_state = shield_state_get(game_seg);
    const u8 flag_shield = game_seg[GVAR_FLAG_SHIELD];
    u16 frame_offset;

    memset(transition->hero_cells, 0, sizeof(transition->hero_cells));
    memset(transition->hero_coverage, 0, sizeof(transition->hero_coverage));

    /* 206GFMCA:3ABE-3B7F. The shield bank is selected on the rear
     * equipment pass for a left-facing Duke. */
    frame_offset = facing ? 0x01B9 : 0x0117;
    if (shield_state && !facing) {
        frame_offset = (u16)(frame_offset + 0x006C +
            (flag_shield & 9u) + (shield_state > 1 ? 0x001B : 0));
        compose_fman_cells(transition, frame_offset,
                           flag_shield ? 3 : 0,
                           flag_shield ? 6 : 9);
    } else if (!flag_shield && pose != 0x80) {
        const u8 rear_pose = (u8)((pose + 2u) & 3u);
        if ((rear_pose & 1u) == 0) {
            frame_offset = (u16)(frame_offset + rear_pose * 9u);
            compose_fman_cells(transition, frame_offset, 0, 9);
        }
    }

    /* 206GFMCA:3B80-3BFC. These state tests choose a complete body bank,
     * not an overlay applied to a generic walking sprite. */
    frame_offset = facing ? 0x0075 : 0x0000;
    if (game_seg[ZEL_PLAYER_INIT_COMPLETE]) {
        frame_offset = (u16)(frame_offset + 0x005A + (pose & 3u) * 9u);
    } else if (flag_shield) {
        frame_offset = (u16)(frame_offset + 0x002D);
    } else if (game_seg[GVAR_EQUIP_BYTE] & 0x80u) {
        frame_offset = (u16)(frame_offset + 0x003F);
    } else if (game_seg[GVAR_SHIELD_SELECT] == 1) {
        frame_offset = (u16)(frame_offset + 0x0048);
    } else if (game_seg[GVAR_SHIELD_SELECT] == 2) {
        frame_offset = (u16)(frame_offset + 0x0051);
    } else if (game_seg[GVAR_EQUIP_BYTE] == 0x7F) {
        frame_offset = (u16)(frame_offset + 0x0036);
    } else if (pose == 0x80) {
        frame_offset = (u16)(frame_offset + 0x0024);
    } else {
        frame_offset = (u16)(frame_offset + (pose & 3u) * 9u);
    }
    compose_fman_cells(transition, frame_offset, 0, 9);

    if (game_seg[ZEL_PLAYER_INIT_COMPLETE]) return;

    /* 206GFMCA:3C05-3CDA. The shield bank moves to the front equipment
     * pass when Duke faces right. */
    frame_offset = facing ? 0x01B9 : 0x0117;
    if (shield_state && facing) {
        frame_offset = (u16)(frame_offset + 0x006C +
            (flag_shield & 9u) + (shield_state > 1 ? 0x001B : 0));
    } else if (flag_shield) {
        frame_offset = (u16)(frame_offset + 0x001B);
    } else if (pose == 0x80) {
        frame_offset = (u16)(frame_offset + 0x001B);
    } else {
        frame_offset = (u16)(frame_offset + (pose & 3u) * 9u);
    }
    compose_fman_cells(transition, frame_offset,
                       flag_shield ? 3 : 0,
                       flag_shield ? 6 : 9);
}

static void blit_hero(zeliard_cavern_transition_t *transition,
                      const u8 *game_seg, u8 *vga) {
    /* 206GFMCA:hero_sprite_col_blit_pos forms one linear mode-13h address:
     * BL * 320 + BH * 4. A large BH therefore carries into Y. */
    const unsigned address = 0x6Eu * 320u + transition->packed_x * 4u;
    const int x = (int)(address % 320u);
    const int y = (int)(address / 320u);
    compose_ordinary_hero(transition, game_seg);
    for (u8 cell = 0; cell < 9; ++cell) {
        const int cell_x = x + (cell % 3) * 8;
        const int cell_y = y + (cell / 3) * 8;
        const u8 *pixels = transition->hero_cells + (size_t)cell * 64;
        const u8 *coverage = transition->hero_coverage + (size_t)cell * 64;
        for (u8 row = 0; row < 8; ++row) {
            const int py = cell_y + row;
            if (py < 0 || py >= 200) continue;
            for (u8 col = 0; col < 8; ++col) {
                const int px = cell_x + col;
                if (coverage[row * 8 + col] && px >= 0 && px < 320)
                    vga[(size_t)py * 320 + px] = pixels[row * 8 + col];
            }
        }
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
    blit_hero(transition, game_seg, vga);
    transition->step++;
}

int zeliard_cavern_transition_begin(zeliard_cavern_transition_t *transition,
                                    u8 *game_seg, size_t game_size,
                                    u8 *vga, size_t vga_size) {
    if (!transition || !game_seg || game_size < 0x10000 || !vga ||
        vga_size < 0x10000) return -1;
    memset(transition, 0, sizeof(*transition));
    if (load_fill("fman.grp", transition->fman, sizeof(transition->fman),
                  sizeof(transition->fman))) {
        platform_log("200FIGHT FMAN payload decode failed");
        return -2;
    }
    preprocess_fman(transition);
    if (stage_roka_background(transition, vga)) return -2;
    palette_set_game_mcga();

    /* 200FIGHT:enter_combat_screen calls reset_combat_state immediately
     * before check_c3. Preserve equipment in the player record, but clear
     * the transient combat/render state exactly as that path does. */
    game_seg[GVAR_EQUIP_BYTE] = 0;
    game_seg[GVAR_FLAG_SHIELD] = 0;
    game_seg[GVAR_COLOR_SELECT] = 0;
    game_seg[PLAYER_POSE] = 0;
    game_seg[GVAR_FLAG_RIDING] = 0;

    transition->direction = game_seg[PLAYER_BOSS_INTRO_FLAG] ? 1 : 0;
    transition->packed_x = transition->direction ? 0x40 : 0xA6;
    transition->pose = 0;
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
