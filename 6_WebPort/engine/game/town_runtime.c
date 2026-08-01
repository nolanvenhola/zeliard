#include "town_runtime.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/town_background.h"
#include "../render/town_mcga.h"

#include <stdlib.h>
#include <string.h>

enum {
    TOWN_DESCRIPTOR = 0xC000,
    TOWN_MAP_SIDE = 0x7C45,
    TOWN_PALETTE_INDEX = 0x7C46,
    TOWN_TEXT_POINTER = 0xC004,
    TOWN_PATTERN_DEST = 0x8000,
    TOWN_YMPD_DEST = 0x3300,
    TOWN_START_POSITION = 0x0080,
    TOWN_PLAYER_COLUMN = 0x0083,
    TOWN_FACING_DIRECTION = 0x00C2,
    TOWN_POSE_INDEX = 0x00E7,
    TOWN_NPC_LIST_POINTER = 0xC00F,
    TOWN_MAP_LIMIT_POINTER = 0xC011,
    TOWN_KEY_EVENT_POINTER = 0xC015,
    TOWN_TILE_COLLISION_MAP = 0xC01C,
    GVAR_INPUT_DIRECTION = 0xFF17,
    GVAR_FRAME_TIMER = 0xFF1A,
    GVAR_SPACEBAR_STATE = 0xFF1D,
    GVAR_TILE_POINTER = 0xFF2A,
    GVAR_ANIM_SPEED = 0xFF33,
};

static u16 read_u16(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static void write_u16(u8 *memory, u16 offset, u16 value) {
    memory[offset] = (u8)value;
    memory[(u16)(offset + 1)] = (u8)(value >> 8);
}

static u8 *find_npc(u8 *cs, u16 position) {
    u16 at = read_u16(cs, TOWN_NPC_LIST_POINTER);
    while (at <= 0xFFF7) {
        const u16 npc_position = read_u16(cs, at);
        if (npc_position == 0xFFFF) return NULL;
        if (npc_position == position) return cs + at;
        at = (u16)(at + 8);
    }
    return NULL;
}

static void restore_tiles_under_npcs(u8 *cs) {
    u16 at = read_u16(cs, TOWN_NPC_LIST_POINTER);
    while (at <= 0xFFF7) {
        const u16 position = read_u16(cs, at);
        if (position == 0xFFFF) return;
        const u8 saved = cs[(u16)(at + 3)];
        if (saved != 0xFD)
            cs[(u16)(TOWN_TILE_COLLISION_MAP + position * 8u)] = saved;
        at = (u16)(at + 8);
    }
}

static void stamp_npcs_save_tiles(u8 *cs) {
    u16 at = read_u16(cs, TOWN_NPC_LIST_POINTER);
    while (at <= 0xFFF7) {
        const u16 position = read_u16(cs, at);
        if (position == 0xFFFF) return;
        const u16 map_at = (u16)(TOWN_TILE_COLLISION_MAP + position * 8u);
        cs[(u16)(at + 3)] = cs[map_at];
        cs[map_at] = 0xFD;
        at = (u16)(at + 8);
    }
}

static void npc_move_with_limits(u8 *cs, u8 *npc, u16 *position,
                                 u8 high_mask) {
    const u8 stepped = (u8)(npc[4] + 0x10);
    npc[4] = stepped;
    const u8 high = (u8)(stepped & high_mask);
    if (high != 0) return;

    u8 frame = (u8)((stepped + 1) & 0x0F);
    npc[4] = (u8)(high | frame);
    const u16 limits = read_u16(cs, TOWN_MAP_LIMIT_POINTER);
    if (npc[2] & 0x80) {
        *position = (u16)(*position - 1);
        if (read_u16(cs, limits) >= *position) npc[2] &= 0x7F;
    } else {
        *position = (u16)(*position + 1);
        if (read_u16(cs, (u16)(limits + 2)) < *position) npc[2] |= 0x80;
    }
}

static void npc_cycle_move(u8 *npc, u16 *position, u8 high_mask) {
    const u8 stepped = (u8)(npc[4] + 0x10);
    npc[4] = stepped;
    const u8 high = (u8)(stepped & high_mask);
    if (high != 0) return;

    const u8 frame = (u8)((stepped + 1) & 0x0F);
    npc[4] = (u8)(high | frame);
    if ((frame & 7) == 0) {
        npc[2] ^= 0x80;
    } else if (npc[2] & 0x80) {
        *position = (u16)(*position - 1);
    } else {
        *position = (u16)(*position + 1);
    }
}

void zeliard_town_tick_npcs(u8 *cs) {
    if (!cs) return;
    restore_tiles_under_npcs(cs);
    u16 at = read_u16(cs, TOWN_NPC_LIST_POINTER);
    while (at <= 0xFFF7) {
        u8 *npc = cs + at;
        u16 position = read_u16(cs, at);
        if (position == 0xFFFF) break;
        switch (npc[5]) {
        case 0: {
            npc[2] |= 0x80;
            const u16 player = (u16)(read_u16(cs, TOWN_START_POSITION) +
                                     (u8)(cs[TOWN_PLAYER_COLUMN] + 4));
            if (player >= position) npc[2] &= 0x7F;
            const u8 stepped = (u8)(npc[4] + 0x10);
            npc[4] = stepped;
            if ((stepped & 0x30) == 0)
                npc[4] = (u8)((stepped + 1) & 1);
            break;
        }
        case 1: npc_move_with_limits(cs, npc, &position, 0x10); break;
        case 2: npc_move_with_limits(cs, npc, &position, 0x30); break;
        case 3: {
            npc[2] |= 0x80;
            const u16 player = (u16)(read_u16(cs, TOWN_START_POSITION) +
                                     (u8)(cs[TOWN_PLAYER_COLUMN] + 4));
            if (player >= position) npc[2] &= 0x7F;
            break;
        }
        case 4: {
            const u8 stepped = (u8)(npc[4] + 0x10);
            npc[4] = stepped;
            if ((stepped & 0x30) == 0)
                npc[4] = (u8)((stepped + 1) & 1);
            break;
        }
        case 5: npc_cycle_move(npc, &position, 0x10); break;
        case 6: npc_cycle_move(npc, &position, 0x30); break;
        default: break;
        }
        write_u16(cs, at, position);
        at = (u16)(at + 8);
    }
    stamp_npcs_save_tiles(cs);
}

static void process_town_event_table(u8 *cs) {
    u16 si = read_u16(cs, TOWN_KEY_EVENT_POINTER);
    for (u16 outer = 0; outer < 0x100 && si <= 0xFFFC; ++outer) {
        const u16 flag_pointer = read_u16(cs, si);
        si = (u16)(si + 2);
        if (flag_pointer == 0xFFFF) return;
        const u8 mask = cs[si++];
        const int active = (cs[flag_pointer] & mask) != 0;
        for (u16 inner = 0; inner < 0x100 && si <= 0xFFFC; ++inner) {
            const u16 destination = read_u16(cs, si);
            si = (u16)(si + 2);
            if (destination == 0xFFFF) break;
            const u8 value = cs[si++];
            if (active) cs[destination] = value;
        }
    }
}

static int tile_is_passable(const u8 *game_data, u8 tile) {
    u16 si = read_u16(game_data, 0x8002);
    u8 count = game_data[si++];
    while (count--)
        if (game_data[si++] == tile) return 0;
    return 1;
}

static int npc_blocks_position(u8 *cs, u16 position) {
    u8 *npc = find_npc(cs, position);
    return npc && (npc[6] & 0x40) != 0;
}

static void mark_player_col_in_cursor_buf(u8 *cs) {
    const u8 column = cs[TOWN_PLAYER_COLUMN];
    if (column >= 0x1B) return;
    const u16 at = (u16)(0xE000 + (u16)column * 8u + 5u);
    memset(cs + at, 0xFF, 3);
    memset(cs + at + 8, 0xFF, 3);
}

static int append_event(zeliard_town_runtime_t *town,
                        zeliard_town_event_t event) {
    if (town->event_count >= sizeof(town->events) / sizeof(town->events[0]))
        return 0;
    town->events[town->event_count++] = event;
    return 1;
}

static int load_raw_chunk(const char *asset, u8 *destination,
                          size_t capacity, size_t *loaded_size) {
    size_t file_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    if (!file || file_size < 4) {
        free(file);
        return 0;
    }
    const size_t declared = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (declared > file_size - 4 || declared > capacity) {
        free(file);
        return 0;
    }
    memcpy(destination, file + 4, declared);
    free(file);
    if (loaded_size) *loaded_size = declared;
    return 1;
}

static int load_fill_chunk(const char *asset, u8 *destination,
                           size_t capacity, size_t *loaded_size) {
    size_t file_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    size_t payload_size = 0;
    u8 *payload = file ? fill_buffer_decompress(file, file_size,
                                                &payload_size) : NULL;
    free(file);
    if (!payload || payload_size > capacity) {
        free(payload);
        return 0;
    }
    memcpy(destination, payload, payload_size);
    free(payload);
    if (loaded_size) *loaded_size = payload_size;
    return 1;
}

static int decode_town_header(u8 *cs, zeliard_town_runtime_t *town) {
    u16 si = read_u16(cs, TOWN_DESCRIPTOR);
    ++si;
    do {
        const u8 value = cs[si++];
        if ((u8)(value + 1) == 0) break;
    } while (si != 0);
    if (si == 0) return 0;
    town->map_side = cs[si++];
    town->palette_index = cs[si];
    cs[TOWN_MAP_SIDE] = town->map_side;
    cs[TOWN_PALETTE_INDEX] = town->palette_index;
    town->town_text_record = read_u16(cs, TOWN_TEXT_POINTER);
    return 1;
}

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size) {
    if (!town || !game || !vga || vga_size < 0x10000)
        return -1;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        if (!game->segment[i] || game->segment_size[i] < 0x10000)
            return -1;
    }
    memset(town, 0, sizeof(*town));
    town->facing_item_position = 0xFFFF;
    town->facing_npc_position = 0xFFFF;
    town->facing_door_type = 0xFF;
    u8 *cs = game->segment[0];
    u8 *cs_1000 = game->segment[1];
    u8 *cs_2000 = game->segment[2];
    u8 *cs_3000 = game->segment[3];
    size_t loaded_size = 0;

    /* game.asm loads MMAN at gvar_game_seg:4000; 106TOWN:init_load_tiles
     * preprocesses 0A4h tiles to the CS+2000h mask bank at 7000h. */
    if (!load_fill_chunk("mman.grp", cs_1000 + 0x4000, 0xC000,
                         &loaded_size) ||
        zeliard_gtmcga_encode_tile_block(cs_1000, 0x10000, 0x4100,
                                         cs_2000, 0x10000, 0x7000, 0xA4) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_PREPROCESS_MMAN, "106TOWN:init_load_tiles",
            "mman.grp", 0x1000, 0x4000, 2}))
        return -2;

    /* 106TOWN:load_town_door_table performs the same conversion for the
     * TMAN player bank at 6000h and its masks at CS+2000h:8000h. */
    if (!load_fill_chunk("tman.grp", cs_1000 + 0x6000, 0xA000,
                         &loaded_size) ||
        zeliard_gtmcga_encode_tile_block(cs_1000, 0x10000, 0x6000,
                                         cs_2000, 0x10000, 0x8000, 0x2E) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_PREPROCESS_TMAN, "106TOWN:load_town_door_table",
            "tman.grp", 0x1000, 0x6000, 2}))
        return -2;

    /* stick.asm AL=1, AH=80h selects CMAP.MDT and loads its raw MDT body. */
    if (!load_raw_chunk("cmap.mdt", cs + TOWN_DESCRIPTOR,
                        0x10000 - TOWN_DESCRIPTOR, NULL) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CMAP, "game.asm:load_first_level", "cmap.mdt",
            0, TOWN_DESCRIPTOR, 1}))
        return -2;
    if (!decode_town_header(cs, town)) return -3;

    /* 106TOWN:load_town_pattern_chunk, palette index zero -> CPAT.GRP. */
    if (!load_fill_chunk("cpat.grp", cs_1000 + TOWN_PATTERN_DEST,
                         0x10000 - TOWN_PATTERN_DEST, &loaded_size))
        return -4;
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = read_u16(cs_1000, (u16)(TOWN_PATTERN_DEST + offset));
        cs_1000[TOWN_PATTERN_DEST + offset] = (u8)(value + TOWN_PATTERN_DEST);
        cs_1000[TOWN_PATTERN_DEST + offset + 1] =
            (u8)((value + TOWN_PATTERN_DEST) >> 8);
    }
    if (zeliard_gtmcga_process_pattern_tiles(cs_1000, 0x10000))
        return -4;
    if (!append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CPAT, "106TOWN:load_town_pattern_chunk",
            "cpat.grp", 0x1000, TOWN_PATTERN_DEST, 2}))
        return -4;

    if (zeliard_mole_render_mcga(cs_3000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_RUN_207MOLE, "game.asm:loaded_code_a", "mole.bin",
            0x3000, 0, 4}))
        return -5;
    if (zeliard_gmmcga_clear_playfield(vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_CLEAR_PLAYFIELD, "106TOWN:gfx_clear_fn", NULL,
            0, 0, 0}))
        return -6;
    /* 106TOWN:player_load_chunk loads YMPD at (CS+2000h):3300h. */
    if (!load_raw_chunk("ympd.bin", cs_2000 + TOWN_YMPD_DEST,
                        0x10000 - TOWN_YMPD_DEST, &loaded_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_YMPD, "106TOWN:player_load_chunk", "ympd.bin",
            0x2000, TOWN_YMPD_DEST, 3}))
        return -8;
    if (zeliard_ympd_render_mcga(cs_2000 + TOWN_YMPD_DEST, loaded_size,
                                  cs_3000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_RUN_208YMPD, "106TOWN:int60", "ympd.bin",
            0x2000, TOWN_YMPD_DEST, 4}))
        return -9;

    /* GTMCGA:3028 saves the rendered scenery strip used by the transparent
     * pixels in the first three CPAT rows. */
    if (zeliard_gtmcga_capture_playfield(vga, vga_size, cs, 0x10000) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_CAPTURE_PLAYFIELD, "106TOWN:gfx_draw_fn", NULL,
            0, 0xA000, 0}))
        return -7;

    cs[0xFF1D] = 0;
    cs[0xFF1E] = 0;
    cs[0x00E4] = 0;
    cs[0x009F] = 0;
    write_u16(cs, GVAR_TILE_POINTER,
              (u16)(0xC017u + (u16)(u8)read_u16(cs,
                                                TOWN_START_POSITION) * 8u));
    if (zeliard_gmmcga_draw_first_frame_hud(vga, vga_size, cs, 0x10000,
                                             town->town_text_record) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_DRAW_FIRST_HUD, "106TOWN:frame_update", NULL,
            0, town->town_text_record, 0}))
        return -10;

    memset(cs + 0xE000, 0xFE, 0xE0);
    /* 106TOWN initial frame calls stamp_npcs_save_tiles once before the
     * actor renderer. Live frames perform the same stamp at the end of
     * tick_npcs_dispatch; render_town_actors itself never owns this state. */
    stamp_npcs_save_tiles(cs);
    if (zeliard_gtmcga_render_town_actors(cs, 0x10000, cs_1000, 0x10000,
                                          cs_2000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_DRAW_ACTORS, "106TOWN:render_town_actors", NULL,
            0, 0xFA00, 0}))
        return -11;

    if (cs[0x0083] < 0x1B) {
        u16 cursor = (u16)(0xE000 + (u16)cs[0x0083] * 8u + 5u);
        memset(cs + cursor, 0xFF, 3);
        memset(cs + cursor + 8, 0xFF, 3);
    }
    if (zeliard_gtmcga_update_town_frame(cs, 0x10000, cs_1000, 0x10000,
                                          cs_2000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_UPDATE_FRAME, "106TOWN:gfx_update_fn", NULL,
            0, 0x3051, 0}))
        return -12;

    palette_set_game_mcga();
    return 0;
}

static u16 player_world_position(const u8 *cs) {
    return (u16)(read_u16(cs, TOWN_START_POSITION) +
                 (u8)(cs[TOWN_PLAYER_COLUMN] + 4));
}

void zeliard_town_detect_facing_targets(zeliard_town_runtime_t *town, u8 *cs,
                                        u8 input_direction) {
    if (!town || !cs) return;
    town->facing_item_position = 0xFFFF;
    town->facing_npc_position = 0xFFFF;
    town->facing_door_type = 0xFF;
    const int step = (cs[TOWN_FACING_DIRECTION] & 1) ? -1 : 1;
    const u16 world = player_world_position(cs);
    const u8 column = cs[TOWN_PLAYER_COLUMN];
    const u16 tile_ptr = read_u16(cs, GVAR_TILE_POINTER);

    if (cs[GVAR_SPACEBAR_STATE]) {
        cs[GVAR_SPACEBAR_STATE] = 0;
        for (u8 distance = 1; distance <= 3; ++distance) {
            const u16 position = (u16)(world + step * distance);
            const u16 tile = (u16)(tile_ptr +
                (u16)(u8)(column + 4 + step * distance) * 8u + 5u);
            if (cs[tile] != 0xFD) continue;
            u8 *npc = find_npc(cs, position);
            if (npc && (npc[6] & 0xC0) == 0)
                town->facing_item_position = position;
            break;
        }
    }

    const u16 talk_position = (u16)(world + step * 2);
    const u16 talk_tile = (u16)(tile_ptr +
        (u16)(u8)(column + 4 + step * 2) * 8u + 5u);
    if (cs[talk_tile] == 0xFD) {
        u8 *npc = find_npc(cs, talk_position);
        if (npc && (npc[6] & 0x80) &&
            (((npc[2] & 0x80) != 0) == (step > 0)))
            town->facing_npc_position = talk_position;
    }

    if ((input_direction & 0x03) == 1) {
        u16 si = read_u16(cs, 0xC009);
        for (u16 count = 0; count < 0x100 && si <= 0xFFFC; ++count) {
            const u16 position = read_u16(cs, si);
            if (position == 0xFFFF) break;
            if (position == world || position == (u16)(world + 1) ||
                position == (u16)(world - 1)) {
                town->facing_door_type = cs[(u16)(si + 2)];
                break;
            }
            si = (u16)(si + 3);
        }
    }
}

static int move_player(u8 *cs, const u8 *game_data, u8 *vga,
                       size_t vga_size, u8 direction) {
    const int left = (direction & 0x0C) == 4;
    const int right = (direction & 0x0C) == 8;
    if (!left && !right) {
        cs[TOWN_POSE_INDEX] |= 1;
        return 0;
    }

    const u8 column = cs[TOWN_PLAYER_COLUMN];
    const u16 tile_ptr = read_u16(cs, GVAR_TILE_POINTER);
    const u8 map_column = (u8)(column + (left ? 3 : 6));
    const u16 tile_at = (u16)(tile_ptr + (u16)map_column * 8u + 7u);
    if (!tile_is_passable(game_data, cs[tile_at])) return 0;

    const u16 target = (u16)(player_world_position(cs) + (left ? -1 : 1));
    if (npc_blocks_position(cs, target)) return 0;

    cs[TOWN_POSE_INDEX] = (u8)((cs[TOWN_POSE_INDEX] + 1) & 3);
    if (left) {
        cs[TOWN_FACING_DIRECTION] |= 1;
        if (column >= 0x0B || read_u16(cs, TOWN_START_POSITION) == 0) {
            cs[TOWN_PLAYER_COLUMN]--;
            return 1;
        }
        write_u16(cs, TOWN_START_POSITION,
                  (u16)(read_u16(cs, TOWN_START_POSITION) - 1));
        write_u16(cs, GVAR_TILE_POINTER, (u16)(tile_ptr - 8));
        zeliard_gtmcga_scroll_view_left(vga, vga_size);
        return 2;
    }

    cs[TOWN_FACING_DIRECTION] &= 0xFE;
    if (column < 0x10) {
        cs[TOWN_PLAYER_COLUMN]++;
        return 1;
    }
    const u16 next_start = (u16)(read_u16(cs, TOWN_START_POSITION) + 1);
    if ((u16)(read_u16(cs, 0xC002) - 0x23) == next_start) {
        cs[TOWN_PLAYER_COLUMN]++;
        return 1;
    }
    write_u16(cs, TOWN_START_POSITION, next_start);
    write_u16(cs, GVAR_TILE_POINTER, (u16)(tile_ptr + 8));
    zeliard_gtmcga_scroll_view_right(vga, vga_size);
    return 2;
}

static int run_live_frame(zeliard_town_runtime_t *town,
                          zeliard_game_exec_state_t *game,
                          u8 *vga, size_t vga_size, u8 input_direction) {
    u8 *cs = game->segment[0];
    u8 *game_data = game->segment[1];
    u8 *mask_data = game->segment[2];
    if (town->dialog.active) {
        const int continued = zeliard_town_dialog_continue(
            &town->dialog, cs, game->segment[3], vga, vga_size);
        if (continued < 0) return -3;
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    process_town_event_table(cs);
    zeliard_town_tick_npcs(cs);
    if (zeliard_gtmcga_render_town_actors(cs, 0x10000, game_data, 0x10000,
                                          mask_data, 0x10000, vga, vga_size))
        return -1;
    mark_player_col_in_cursor_buf(cs);
    if (zeliard_gtmcga_update_town_frame(cs, 0x10000, game_data, 0x10000,
                                          mask_data, 0x10000, vga, vga_size))
        return -2;
    zeliard_town_detect_facing_targets(town, cs, input_direction);
    if (town->facing_item_position != 0xFFFF) {
        const int result = zeliard_town_dialog_begin(
            &town->dialog, cs, game->segment[3], vga, vga_size,
            town->facing_item_position);
        if (result) return -3;
    }
    move_player(cs, game_data, vga, vga_size, input_direction);
    cs[GVAR_FRAME_TIMER] = 0;
    town->frame_count++;
    return 0;
}

int zeliard_town_advance_pit(zeliard_town_runtime_t *town,
                             zeliard_game_exec_state_t *game,
                             u8 *vga, size_t vga_size,
                             u32 pit_ticks, u8 input_direction) {
    if (!town || !game || !vga || vga_size < 0x10000) return -1;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i)
        if (!game->segment[i] || game->segment_size[i] < 0x10000) return -1;
    u8 *cs = game->segment[0];
    cs[GVAR_INPUT_DIRECTION] = input_direction;
    int frames = 0;
    while (pit_ticks--) {
        cs[GVAR_FRAME_TIMER]++;
        const u8 threshold = (u8)(4u * cs[GVAR_ANIM_SPEED]);
        if (cs[GVAR_FRAME_TIMER] < threshold) continue;
        const int result = run_live_frame(town, game, vga, vga_size,
                                          input_direction);
        if (result) return result;
        ++frames;
    }
    return frames;
}
