#include "town_runtime.h"
#include "room_masm_vm.h"
#include "ckpd_masm_vm.h"

#include "../core/player_state.h"
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
    TOWN_START_POSITION = ZEL_PLAYER_START_POSITION,
    TOWN_PLAYER_COLUMN = ZEL_PLAYER_SCREEN_POSITION,
    TOWN_FACING_DIRECTION = ZEL_PLAYER_FACING_DIRECTION,
    TOWN_POSE_INDEX = ZEL_PLAYER_POSE,
    TOWN_NPC_LIST_POINTER = 0xC00F,
    TOWN_MAP_LIMIT_POINTER = 0xC011,
    TOWN_KEY_EVENT_POINTER = 0xC015,
    TOWN_TILE_COLLISION_MAP = 0xC01C,
    PLAYER_CURRENT_AREA = ZEL_PLAYER_SAVE_SAGE,
    GVAR_INPUT_DIRECTION = 0xFF17,
    GVAR_FRAME_TIMER = 0xFF1A,
    GVAR_SPACEBAR_STATE = 0xFF1D,
    GVAR_TILE_POINTER = 0xFF2A,
    GVAR_ANIM_SPEED = 0xFF33,
};

typedef struct {
    zeliard_town_area_t area;
    u8 area_id;
    const char *map_asset;
    const char *pattern_asset;
    const char *actor_asset;
} town_area_asset_t;

static const town_area_asset_t TOWN_AREA_ASSETS[] = {
    {ZEL_TOWN_AREA_FELISHIKA, 0x80, "cmap.mdt", "cpat.grp", "mman.grp"},
    {ZEL_TOWN_AREA_MURALLA, 0x81, "mrmp.mdt", "mpat.grp", "mman.grp"},
    {ZEL_TOWN_AREA_SATONO, 0x82, "stmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_BOSQUE, 0x83, "bsmp.mdt", "mpat.grp", "mman.grp"},
    {ZEL_TOWN_AREA_HELADA, 0x84, "hlmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_TUMBA, 0x85, "tmmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_DORADO, 0x86, "drmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_LLAMA, 0x87, "llmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_PUREZA, 0x88, "prmp.mdt", "dpat.grp", "cman.grp"},
    {ZEL_TOWN_AREA_ESCO, 0x89, "esmp.mdt", "dpat.grp", "cman.grp"},
};

static const town_area_asset_t *town_assets_for_area_id(u8 area_id) {
    for (size_t index = 0;
         index < sizeof(TOWN_AREA_ASSETS) / sizeof(TOWN_AREA_ASSETS[0]);
         ++index) {
        if (TOWN_AREA_ASSETS[index].area_id == area_id)
            return &TOWN_AREA_ASSETS[index];
    }
    return NULL;
}

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

int zeliard_town_prepare_level_start(u8 *cs, size_t game_size, u8 area_id) {
    if (!cs || game_size < 0x10000) return -1;
    const town_area_asset_t *assets = town_assets_for_area_id(area_id);
    if (!assets || !load_raw_chunk(assets->map_asset,
                                    cs + TOWN_DESCRIPTOR,
                                    game_size - TOWN_DESCRIPTOR, NULL))
        return -2;

    /* Exact 200FIGHT:level_start/compute_scroll_offset_b arithmetic.  Loader
     * mode 1 has installed the selected town MDT before target_id (C013h)
     * becomes scroll_count (9F1Ah).  AX and BL then become player offsets
     * 80h and 83h; 82h is deliberately retained from the fight state. */
    const u16 width = read_u16(cs, 0xC002);
    const u16 target = read_u16(cs, 0xC013);
    u16 ax = target;
    u8 bl = 0x0D;
    const u16 remaining = (u16)(width - 0x0D);
    if (remaining < target) {
        ax = (u16)(width - 0x24);
        const u16 carry = width >= 0x24;
        const u16 cx = (u16)(target - ax - carry);
        bl = (u8)((u8)cx - 3u);
    } else {
        ax = (u16)(ax - 0x11);
        if (ax & 0xFF00u) {
            ax = 0;
            bl = (u8)((u8)target - 4u);
        }
    }
    write_u16(cs, TOWN_START_POSITION, ax);
    cs[TOWN_PLAYER_COLUMN] = bl;
    return 0;
}

int zeliard_town_prepare_cavern_door_return(
    u8 *cs, size_t game_size, u8 area_id,
    u16 scroll_count, u8 scroll_dir, u8 player_y) {
    if (!cs || game_size < 0x10000) return -1;
    const town_area_asset_t *assets = town_assets_for_area_id(area_id);
    if (!assets || !load_raw_chunk(assets->map_asset,
                                    cs + TOWN_DESCRIPTOR,
                                    game_size - TOWN_DESCRIPTOR, NULL))
        return -2;

    /* boss_link_check first runs compute_scroll_pos for the reverse ROKA
     * animation.  Once check_map_flag reaches level_start, MASM replaces
     * that wrapped coordinate with compute_scroll_offset_b's town viewport.
     * Stopping at the loader boundary and retaining the wrapped value makes
     * Satono x=4 become start=CBh and reads beyond STMP's tile array. */
    const u16 width = read_u16(cs, 0xC002);
    u16 start = scroll_count;
    u8 column = 0x0D;
    const u16 remaining = (u16)(width - 0x0D);
    if (remaining < scroll_count) {
        start = (u16)(width - 0x24);
        const u16 carry = width >= 0x24;
        const u16 cx = (u16)(scroll_count - start - carry);
        column = (u8)((u8)cx - 3u);
    } else {
        start = (u16)(start - 0x11);
        if (start & 0xFF00u) {
            start = 0;
            column = (u8)((u8)scroll_count - 4u);
        }
    }
    write_u16(cs, TOWN_START_POSITION, start);
    cs[TOWN_PLAYER_COLUMN] = column;
    cs[ZEL_PLAYER_MAP_SCROLL_ROW] =
        (u8)((scroll_dir + 1u - player_y) & 0x3Fu);
    return 0;
}

static int decode_town_header(u8 *cs, zeliard_town_runtime_t *town) {
    u16 si = read_u16(cs, TOWN_DESCRIPTOR);
    town->music_index = (u8)((cs[si] >> 1) & 0x1F);
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

static int load_pattern_bank(zeliard_game_exec_state_t *game,
                             const char *asset) {
    u8 *game_data = game->segment[1];
    size_t loaded_size = 0;
    if (!load_fill_chunk(asset, game_data + TOWN_PATTERN_DEST,
                         0x10000 - TOWN_PATTERN_DEST, &loaded_size))
        return -1;
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = read_u16(game_data,
                                   (u16)(TOWN_PATTERN_DEST + offset));
        write_u16(game_data, (u16)(TOWN_PATTERN_DEST + offset),
                  (u16)(value + TOWN_PATTERN_DEST));
    }
    return zeliard_gtmcga_process_pattern_tiles(game_data, 0x10000);
}

static int move_player(u8 *cs, const u8 *game_data, u8 *vga,
                       size_t vga_size, u8 direction);

static int town_enter_first_frame(zeliard_town_runtime_t *town,
                                  zeliard_game_exec_state_t *game,
                                  u8 *vga, size_t vga_size,
                                  int fresh_town_overlay) {
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
    town->facing_door_found = 0;
    u8 *cs = game->segment[0];
    zeliard_player_state_t player;
    if (!zeliard_player_state_bind(&player, cs, game->segment_size[0]))
        return -1;
    const u8 saved_area = zeliard_player_read_u8(
        &player, PLAYER_CURRENT_AREA);
    const town_area_asset_t *area_assets = town_assets_for_area_id(saved_area);
    if (!area_assets) return -1;
    town->area = area_assets->area;
    u8 *cs_1000 = game->segment[1];
    u8 *cs_2000 = game->segment[2];
    u8 *cs_3000 = game->segment[3];
    size_t loaded_size = 0;

    /* game.asm loads MMAN at gvar_game_seg:4000; 106TOWN:init_load_tiles
     * preprocesses 0A4h tiles to the CS+2000h mask bank at 7000h. */
    if (!load_fill_chunk(area_assets->actor_asset, cs_1000 + 0x4000, 0xC000,
                         &loaded_size) ||
        zeliard_gtmcga_encode_tile_block(cs_1000, 0x10000, 0x4100,
                                         cs_2000, 0x10000, 0x7000, 0xA4) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_PREPROCESS_MMAN, "106TOWN:init_load_tiles",
            area_assets->actor_asset, 0x1000, 0x4000, 2}))
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

    /* game.asm:start_load_game passes save_sage (C4h) as loader function 1's
     * AH selector.  The MDT and pattern bank must therefore be chosen as one
     * saved-area transaction; mixing Muralla position state with CMAP/CPAT
     * corrupts the transparent middle layer. */
    if (!load_raw_chunk(area_assets->map_asset, cs + TOWN_DESCRIPTOR,
                        0x10000 - TOWN_DESCRIPTOR, NULL) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CMAP, "game.asm:load_first_level",
            area_assets->map_asset, 0, TOWN_DESCRIPTOR, 1}))
        return -2;
    if (!decode_town_header(cs, town)) return -3;

    /* 106TOWN:load_town_pattern_chunk selects the pattern paired with MDT. */
    if (load_pattern_bank(game, area_assets->pattern_asset))
        return -4;
    if (!append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CPAT, "106TOWN:load_town_pattern_chunk",
            area_assets->pattern_asset, 0x1000, TOWN_PATTERN_DEST, 2}))
        return -4;

    /* game.asm loads 207MOLE as a fresh overlay before invoking its entry.
     * MOLE deliberately rewrites its own dispatch flags and decode scratch;
     * invoking a suspended copy a second time interprets its first compressed
     * stream with the final-pass flags and corrupts the entire stone chrome.
     * Reload the pristine overlay at this same service boundary. */
    if (!load_raw_chunk("mole.bin", cs_3000, 0x10000, NULL))
        return -5;
    /* Every release path that transfers control from FIGHT back to 106TOWN
     * first completes GMMCGA:2130's fade-to-black.  MOLE is not an opaque
     * full-screen blit: its final chrome pass ORs mask bits into VGA, so
     * entering it with the cavern/ROKA image still resident preserves stale
     * pixels in the top and side borders.  Make that loader-boundary
     * precondition explicit here so every town selector gets the same clean
     * transaction, including direct returns that bypass the ROKA room. */
    memset(vga, 0, 0x10000);
    if (zeliard_mole_render_mcga(cs_3000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_RUN_207MOLE, "game.asm:loaded_code_a", "mole.bin",
            0x3000, 0, 4}))
        return -5;
    /* game.asm calls GMMCGA:254C with AL=sword, BX=18ABh immediately after
     * 207MOLE has composed the HUD. The later town clear excludes this row. */
    const u8 sword = zeliard_player_read_u8(&player, ZEL_PLAYER_SWORD);
    if (sword != 0 &&
        zeliard_gmmcga_draw_equipped_sword(vga, vga_size, cs_1000, 0x10000,
                                            sword, 0x18AB))
        return -5;
    /* game.asm follows the sword call through dispatch slot CS:2020 to
     * GMMCGA:25FC using AL=shield and
     * BX=3EA4h. Replaying it here is required after loading a .usr record;
     * otherwise the saved shield value is restored but its HUD icon is not. */
    const u8 shield = zeliard_player_read_u8(&player, ZEL_PLAYER_SHIELD);
    if (shield != 0 &&
        zeliard_gmmcga_draw_equipped_shield(vga, vga_size, cs_1000, 0x10000,
                                             shield, 0x3EA4))
        return -5;
    /* game.asm:gfx_init_after_font calls GMMCGA:25E2h through slot 201Eh
     * with BX=37A4h whenever selected_spell is nonzero. */
    const u8 spell = zeliard_player_read_u8(
        &player, ZEL_PLAYER_SELECTED_SPELL);
    if (spell != 0 &&
        zeliard_gmmcga_draw_equipped_spell(vga, vga_size, cs_1000, 0x10000,
                                            spell, 0x37A4))
        return -5;
    if (zeliard_gmmcga_clear_playfield(vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_CLEAR_PLAYFIELD, "106TOWN:gfx_clear_fn", NULL,
            0, 0, 0}))
        return -6;
    /* 106TOWN:player_load_chunk uses town_map_side&1 to select the raw
     * YMPD/CKPD SAR entry at (CS+2000h):3300h. */
    const int side_1 = (town->map_side & 1u) != 0;
    const char *side_asset = side_1 ? "ckpd.bin" : "ympd.bin";
    if (!load_raw_chunk(side_asset, cs_2000 + TOWN_YMPD_DEST,
                        0x10000 - TOWN_YMPD_DEST, &loaded_size) ||
        !append_event(town, (zeliard_town_event_t){
            side_1 ? ZEL_TOWN_EVENT_LOAD_CKPD : ZEL_TOWN_EVENT_LOAD_YMPD,
            "106TOWN:player_load_chunk", side_asset,
            0x2000, TOWN_YMPD_DEST, 3}))
        return -8;
    const int side_render = side_1
        ? zeliard_ckpd_masm_vm_render(cs_2000 + TOWN_YMPD_DEST,
                                      loaded_size, vga, vga_size)
        : zeliard_ympd_render_mcga(cs_2000 + TOWN_YMPD_DEST, loaded_size,
                                   cs_3000, 0x10000, vga, vga_size);
    if (side_render ||
        !append_event(town, (zeliard_town_event_t){
            side_1 ? ZEL_TOWN_EVENT_RUN_209CKPD : ZEL_TOWN_EVENT_RUN_208YMPD,
            "106TOWN:gfx_draw_fn", side_asset,
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
    zeliard_player_write_u8(&player, ZEL_PLAYER_KEY_COUNT, 0);
    zeliard_player_write_u8(&player, ZEL_PLAYER_FRAME_SCRATCH, 0);
    write_u16(cs, GVAR_TILE_POINTER,
              (u16)(0xC017u + (u16)(u8)read_u16(cs,
                                                TOWN_START_POSITION) * 8u));
    /* 106TOWN:frame_update applies descriptor events before it draws the
     * first actors.  Bosque relies on this ordering: an already-owned Hero
     * Crest changes the sentry's blocking flags and dialog immediately. */
    process_town_event_table(cs);
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

    const u8 screen_position =
        zeliard_player_read_u8(&player, ZEL_PLAYER_SCREEN_POSITION);
    if (screen_position < 0x1B) {
        u16 cursor = (u16)(0xE000 + (u16)screen_position * 8u + 5u);
        memset(cs + cursor, 0xFF, 3);
        memset(cs + cursor + 8, 0xFF, 3);
    }
    if (zeliard_gtmcga_update_town_frame(cs, 0x10000, cs_1000, 0x10000,
                                          cs_2000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_UPDATE_FRAME, "106TOWN:gfx_update_fn", NULL,
            0, 0x3051, 0}))
        return -12;

    /* 106TOWN:portal_check invokes the direction-selected walk routine five
     * times when a side-1 map is entered with init_complete clear.  It first
     * calls tick_npcs_then_pump once, then pumps another NPC frame after each
     * of the first four walks.  That entry falls through draw_and_pump_input,
     * including mark_player_col_in_cursor_buf between actor composition and
     * the update.  Omitting that mark leaves an old 8x24 player strip on the
     * town background.  tick_npcs_dispatch already owns the complete
     * restore/move/stamp transaction; stamping again here corrupts an NPC's
     * saved floor byte with FD and leaves a phantom marker after it moves. */
    if (!fresh_town_overlay && town->map_side == 1 &&
        !zeliard_player_read_u8(&player, ZEL_PLAYER_INIT_COMPLETE)) {
        const u8 direction =
            (zeliard_player_read_u8(&player, ZEL_PLAYER_FACING_DIRECTION) & 1u)
                ? 4u : 8u;
        zeliard_town_tick_npcs(cs);
        if (zeliard_gtmcga_render_town_actors(
                cs, 0x10000, cs_1000, 0x10000, cs_2000, 0x10000,
                vga, vga_size))
            return -13;
        mark_player_col_in_cursor_buf(cs);
        if (zeliard_gtmcga_update_town_frame(
                cs, 0x10000, cs_1000, 0x10000, cs_2000, 0x10000,
                vga, vga_size))
            return -13;
        for (u8 step = 0; step < 5; ++step) {
            move_player(cs, cs_1000, vga, vga_size, direction);
            if (step == 4) break;
            zeliard_town_tick_npcs(cs);
            const int actor_result = zeliard_gtmcga_render_town_actors(
                cs, 0x10000, cs_1000, 0x10000, cs_2000, 0x10000,
                vga, vga_size);
            if (actor_result) return -13;
            mark_player_col_in_cursor_buf(cs);
            if (zeliard_gtmcga_update_town_frame(
                    cs, 0x10000, cs_1000, 0x10000, cs_2000, 0x10000,
                    vga, vga_size))
                return -13;
        }
    }

    palette_set_game_mcga();
    return 0;
}

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size) {
    return town_enter_first_frame(town, game, vga, vga_size, 0);
}

int zeliard_town_enter_saved_first_frame(zeliard_town_runtime_t *town,
                                         zeliard_game_exec_state_t *game,
                                         u8 *vga, size_t vga_size) {
    return town_enter_first_frame(town, game, vga, vga_size, 1);
}

static u16 player_world_position(const u8 *cs) {
    zeliard_player_state_t player = {.bytes = (u8 *)cs};
    return (u16)(zeliard_player_read_u16(&player, ZEL_PLAYER_START_POSITION) +
                 (u8)(zeliard_player_read_u8(
                     &player, ZEL_PLAYER_SCREEN_POSITION) + 4));
}

void zeliard_town_detect_facing_targets(zeliard_town_runtime_t *town, u8 *cs,
                                        u8 input_direction) {
    if (!town || !cs) return;
    town->facing_item_position = 0xFFFF;
    town->facing_npc_position = 0xFFFF;
    town->facing_door_type = 0xFF;
    town->facing_door_found = 0;
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
                town->facing_door_found = 1;
                break;
            }
            si = (u16)(si + 3);
        }
    }
}

static int move_player(u8 *cs, const u8 *game_data, u8 *vga,
                       size_t vga_size, u8 direction) {
    zeliard_player_state_t player = {.bytes = cs};
    const int left = (direction & 0x0C) == 4;
    const int right = (direction & 0x0C) == 8;
    if (!left && !right) {
        zeliard_player_write_u8(
            &player, ZEL_PLAYER_POSE,
            (u8)(zeliard_player_read_u8(&player, ZEL_PLAYER_POSE) | 1));
        return 0;
    }

    const u8 column =
        zeliard_player_read_u8(&player, ZEL_PLAYER_SCREEN_POSITION);
    const u16 tile_ptr = read_u16(cs, GVAR_TILE_POINTER);
    const u8 map_column = (u8)(column + (left ? 3 : 6));
    const u16 tile_at = (u16)(tile_ptr + (u16)map_column * 8u + 7u);
    if (!tile_is_passable(game_data, cs[tile_at])) return 0;

    const u16 target = (u16)(player_world_position(cs) + (left ? -1 : 1));
    if (npc_blocks_position(cs, target)) return 0;

    zeliard_player_write_u8(
        &player, ZEL_PLAYER_POSE,
        (u8)((zeliard_player_read_u8(&player, ZEL_PLAYER_POSE) + 1) & 3));
    if (left) {
        zeliard_player_write_u8(
            &player, ZEL_PLAYER_FACING_DIRECTION,
            (u8)(zeliard_player_read_u8(
                &player, ZEL_PLAYER_FACING_DIRECTION) | 1));
        if (column >= 0x0B ||
            zeliard_player_read_u16(&player, ZEL_PLAYER_START_POSITION) == 0) {
            zeliard_player_write_u8(
                &player, ZEL_PLAYER_SCREEN_POSITION, (u8)(column - 1));
            return 1;
        }
        zeliard_player_write_u16(
            &player, ZEL_PLAYER_START_POSITION,
            (u16)(zeliard_player_read_u16(
                &player, ZEL_PLAYER_START_POSITION) - 1));
        write_u16(cs, GVAR_TILE_POINTER, (u16)(tile_ptr - 8));
        zeliard_gtmcga_scroll_view_left(vga, vga_size);
        if (cs[TOWN_MAP_SIDE] == 1)
            zeliard_gtmcga_scroll_view_up(vga, vga_size);
        return 2;
    }

    zeliard_player_write_u8(
        &player, ZEL_PLAYER_FACING_DIRECTION,
        (u8)(zeliard_player_read_u8(
            &player, ZEL_PLAYER_FACING_DIRECTION) & 0xFE));
    if (column < 0x10) {
        zeliard_player_write_u8(
            &player, ZEL_PLAYER_SCREEN_POSITION, (u8)(column + 1));
        return 1;
    }
    const u16 next_start = (u16)(zeliard_player_read_u16(
        &player, ZEL_PLAYER_START_POSITION) + 1);
    if ((u16)(read_u16(cs, 0xC002) - 0x23) == next_start) {
        zeliard_player_write_u8(
            &player, ZEL_PLAYER_SCREEN_POSITION, (u8)(column + 1));
        return 1;
    }
    zeliard_player_write_u16(&player, ZEL_PLAYER_START_POSITION, next_start);
    write_u16(cs, GVAR_TILE_POINTER, (u16)(tile_ptr + 8));
    zeliard_gtmcga_scroll_view_right(vga, vga_size);
    if (cs[TOWN_MAP_SIDE] == 1)
        zeliard_gtmcga_scroll_view_down(vga, vga_size);
    return 2;
}

static int draw_building_entry_pose(u8 *cs, const u8 *game_data,
                                    const u8 *mask_data, u8 *vga,
                                    size_t vga_size) {
    /* 106TOWN:door_action sets pose 4, restores the actor background, and
     * calls draw_and_pump_input once before gfx_fade_to_black_fn. Rebuild the
     * offscreen actor tiles and commit that rear-facing frame before the room
     * transition snapshots VGA. */
    cs[TOWN_POSE_INDEX] = 4;
    restore_tiles_under_npcs(cs);
    stamp_npcs_save_tiles(cs);
    if (zeliard_gtmcga_render_town_actors(
            cs, 0x10000, game_data, 0x10000,
            mask_data, 0x10000, vga, vga_size))
        return -1;
    mark_player_col_in_cursor_buf(cs);
    return zeliard_gtmcga_update_town_frame(
        cs, 0x10000, game_data, 0x10000,
        mask_data, 0x10000, vga, vga_size);
}

int zeliard_town_begin_room_transition(zeliard_town_runtime_t *town,
                                       zeliard_room_kind_t kind,
                                       u8 *vga, size_t vga_size) {
    if (!town || kind == ZEL_ROOM_NONE ||
        town->building_transition != ZEL_TOWN_BUILDING_TRANSITION_NONE)
        return -1;
    if (zeliard_room_prepare_enter(&town->room, vga, vga_size)) return -1;
    town->building_transition = ZEL_TOWN_BUILDING_TRANSITION_ENTER;
    town->pending_room_kind = kind;
    town->building_transition_pass = 0;
    town->building_transition_ticks = 0;
    return 0;
}

static int enter_adjacent_town(zeliard_town_runtime_t *town,
                               zeliard_game_exec_state_t *game,
                               u8 *vga, size_t vga_size,
                               zeliard_town_area_t area) {
    if ((size_t)area >= sizeof(TOWN_AREA_ASSETS) / sizeof(TOWN_AREA_ASSETS[0]))
        return -1;
    const town_area_asset_t *assets = &TOWN_AREA_ASSETS[area];
    u8 *cs = game->segment[0];
    u8 *game_data = game->segment[1];
    u8 *mask_data = game->segment[2];
    zeliard_player_state_t player = {.bytes = cs};

    /* 106TOWN:try_door_transition restores the descriptor-backed collision
     * bytes before loader mode 1 replaces the active MDT at CS:C000. */
    restore_tiles_under_npcs(cs);
    if (!load_raw_chunk(assets->map_asset, cs + TOWN_DESCRIPTOR,
                        0x10000 - TOWN_DESCRIPTOR, NULL) ||
        !decode_town_header(cs, town) ||
        !load_fill_chunk(assets->actor_asset, game_data + 0x4000,
                         0xC000, NULL) ||
        zeliard_gtmcga_encode_tile_block(game_data, 0x10000, 0x4100,
                                         mask_data, 0x10000, 0x7000, 0xA4) ||
        load_pattern_bank(game, assets->pattern_asset))
        return -2;

    town->area = area;
    zeliard_player_write_u8(&player, PLAYER_CURRENT_AREA, assets->area_id);
    if (area == ZEL_TOWN_AREA_MURALLA) {
        zeliard_player_write_u16(&player, ZEL_PLAYER_START_POSITION, 0);
        zeliard_player_write_u8(&player, ZEL_PLAYER_SCREEN_POSITION, 0);
    } else {
        zeliard_player_write_u16(
            &player, ZEL_PLAYER_START_POSITION,
            (u16)(read_u16(cs, 0xC002) - 0x24));
        zeliard_player_write_u8(&player, ZEL_PLAYER_SCREEN_POSITION, 0x1A);
    }
    const u16 start = zeliard_player_read_u16(
        &player, ZEL_PLAYER_START_POSITION);
    write_u16(cs, GVAR_TILE_POINTER,
              (u16)(0xC017u + (u16)(u8)start * 8u));
    cs[GVAR_SPACEBAR_STATE] = 0;
    cs[0xFF1E] = 0;
    zeliard_player_write_u8(&player, ZEL_PLAYER_KEY_COUNT, 0);
    zeliard_player_write_u8(&player, ZEL_PLAYER_FRAME_SCRATCH, 0);
    process_town_event_table(cs);

    if (zeliard_gmmcga_draw_first_frame_hud(
            vga, vga_size, cs, 0x10000, town->town_text_record))
        return -3;
    memset(cs + 0xE000, 0xFE, 0xE0);
    stamp_npcs_save_tiles(cs);
    if (zeliard_gtmcga_render_town_actors(
            cs, 0x10000, game_data, 0x10000,
            mask_data, 0x10000, vga, vga_size))
        return -4;
    mark_player_col_in_cursor_buf(cs);
    if (zeliard_gtmcga_update_town_frame(
            cs, 0x10000, game_data, 0x10000,
            mask_data, 0x10000, vga, vga_size))
        return -5;
    palette_set_game_mcga();
    append_event(town, (zeliard_town_event_t){
        ZEL_TOWN_EVENT_LOAD_AREA, "106TOWN:load_area_assets",
        assets->map_asset, 0, TOWN_DESCRIPTOR, 1});
    append_event(town, (zeliard_town_event_t){
        ZEL_TOWN_EVENT_LOAD_PATTERN, "106TOWN:load_town_pattern_chunk",
        assets->pattern_asset, 0x1000, TOWN_PATTERN_DEST, 2});
    return 0;
}

static void request_cavern_exit(zeliard_town_runtime_t *town, u8 *cs,
                                u8 destination_index) {
    zeliard_player_state_t player = {.bytes = cs};
    const u16 record = (u16)(read_u16(cs, 0xC00B) +
                             (u16)destination_index * 5u);
    const u16 destination = read_u16(cs, record);
    const u8 destination_area = cs[(u16)(record + 4)];
    u16 start = (u16)(destination - 0x10u);
    /* 106TOWN:pf30_exec calls SAR mode 1 before this calculation, so
     * town_map_width at C002 is already the destination cavern's width.
     * The host defers that load until after the ROKA transition; obtain the
     * same width explicitly before applying MASM's signed-underflow wrap. */
    if ((int16_t)start < 0) {
        const char *asset = zeliard_cavern_map_asset(destination_area);
        size_t file_size = 0;
        u8 *file = asset ? platform_load_asset(asset, &file_size) : NULL;
        /* MDT files carry a four-byte payload length; map_width is C002. */
        if (file && file_size >= 8)
            start = (u16)(start + read_u16(file, 6));
        free(file);
    }
    zeliard_player_write_u16(
        &player, ZEL_PLAYER_START_POSITION, start);
    zeliard_player_write_u8(
        &player, ZEL_PLAYER_MAP_SCROLL_ROW,
        (u8)((cs[(u16)(record + 2)] - 0x0Au) & 0x3Fu));
    zeliard_player_write_u8(
        &player, ZEL_PLAYER_BOSS_INTRO_FLAG,
        (u8)((cs[(u16)(record + 3)] & 1u) ? 0xFF : 0));
    zeliard_player_write_u8(
        &player, PLAYER_CURRENT_AREA, destination_area);
    town->cavern_exit_requested = 1;
}

int zeliard_town_area_supported(u8 area_id) {
    return town_assets_for_area_id(area_id) != NULL;
}

static int try_town_boundary_transition(zeliard_town_runtime_t *town,
                                        zeliard_game_exec_state_t *game,
                                        u8 *vga, size_t vga_size) {
    zeliard_player_state_t player = {.bytes = game->segment[0]};
    const u8 column = zeliard_player_read_u8(
        &player, ZEL_PLAYER_SCREEN_POSITION);
    const int parity = column == 0xFF ? 1 : column == 0x1C ? 0 : -1;
    if (parity < 0) return 0;

    u8 *cs = game->segment[0];
    u16 record = read_u16(cs, 0xC007);
    for (u8 count = 0; count < 0x40; ++count, record = (u16)(record + 4)) {
        if ((cs[record] & 1u) != (u8)parity) continue;
        const u8 target = cs[(u16)(record + 1)];
        if (cs[record] & 0xFEu) {
            restore_tiles_under_npcs(cs);
            request_cavern_exit(town, cs, target);
            return 1;
        }
        const u8 area_id = (u8)(0x80u | target);
        const town_area_asset_t *assets = town_assets_for_area_id(area_id);
        if (!assets) return -1;
        return enter_adjacent_town(town, game, vga, vga_size,
                                   assets->area) ? -1 : 1;
    }
    return 0;
}

static int run_live_frame(zeliard_town_runtime_t *town,
                          zeliard_game_exec_state_t *game,
                          u8 *vga, size_t vga_size, u8 input_direction) {
    /* Largest 106TOWN speech panel: 22 character cells by 88 rows. */
    static u8 dialog_overlay[22u * 8u * 88u];
    u8 *cs = game->segment[0];
    u8 *game_data = game->segment[1];
    u8 *mask_data = game->segment[2];
    if (town->room.active) {
        if (town->room.alternate_transition_requested) {
            cs[GVAR_FRAME_TIMER] = 0;
            town->frame_count++;
            return 0;
        }
        if (town->room.exit_requested ||
            ((town->room.kind == ZEL_ROOM_VIEWING) &&
             (cs[GVAR_SPACEBAR_STATE] || cs[0xFF1E]))) {
            cs[GVAR_SPACEBAR_STATE] = 0;
            cs[0xFF1E] = 0;
            town->building_transition = ZEL_TOWN_BUILDING_TRANSITION_LEAVE;
            town->building_transition_pass = 0;
            town->building_transition_ticks = 0;
        }
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    if (town->dialog.active) {
        if (zeliard_gmmcga_save_rect(
                vga, vga_size, dialog_overlay, sizeof(dialog_overlay),
                town->dialog.panel_ax, town->dialog.panel_cx, 0))
            return -1;
        /* 106TOWN's dialog wait loops call tick_npcs_then_pump. That entry
         * advances every normal NPC, falls through to render_town_actors,
         * commits the frame, restores the foreground text page, and only
         * then samples the continue key. The
         * speaking NPC remains stationary because begin_dialog temporarily
         * changes its dispatch type to 7. */
        zeliard_town_tick_npcs(cs);
        if (zeliard_gtmcga_render_town_actors(
                cs, 0x10000, game_data, 0x10000,
                mask_data, 0x10000, vga, vga_size))
            return -1;
        mark_player_col_in_cursor_buf(cs);
        if (zeliard_gtmcga_update_town_frame(
                cs, 0x10000, game_data, 0x10000,
                mask_data, 0x10000, vga, vga_size))
            return -2;
        if (zeliard_gmmcga_restore_rect(
                vga, vga_size, dialog_overlay, sizeof(dialog_overlay),
                town->dialog.panel_ax, town->dialog.panel_cx, 0))
            return -2;
        const int continued = zeliard_town_dialog_continue(
            &town->dialog, cs, game->segment[3], vga, vga_size);
        if (continued < 0) return -3;
        if (town->special_door_pending && !town->dialog.active) {
            cs[0x0045] |= 0x80;
            town->special_door_pending = 0;
            town->building_transition =
                ZEL_TOWN_BUILDING_TRANSITION_SPECIAL;
            town->building_transition_pass = 0;
            town->building_transition_ticks = 0;
        }
        if (continued > 0 && !town->dialog.active &&
            town->building_transition == ZEL_TOWN_BUILDING_TRANSITION_NONE) {
            /* 106TOWN:text_end_seq returns to the same main-loop iteration.
             * Its following INT 61h sample therefore uses the direction that
             * dismissed the text to attempt the guarded step immediately. */
            move_player(cs, game_data, vga, vga_size, input_direction);
        }
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    zeliard_town_tick_npcs(cs);
    if (zeliard_gtmcga_render_town_actors(cs, 0x10000, game_data, 0x10000,
                                          mask_data, 0x10000, vga, vga_size))
        return -1;
    mark_player_col_in_cursor_buf(cs);
    if (zeliard_gtmcga_update_town_frame(cs, 0x10000, game_data, 0x10000,
                                          mask_data, 0x10000, vga, vga_size))
        return -2;
    const int adjacent = try_town_boundary_transition(
        town, game, vga, vga_size);
    if (adjacent < 0) return -5;
    if (adjacent > 0) {
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    zeliard_town_detect_facing_targets(town, cs, input_direction);
    if (town->facing_door_found &&
        draw_building_entry_pose(cs, game_data, mask_data, vga, vga_size))
        return -4;
    if (town->facing_door_type <= 7) {
        const zeliard_room_kind_t kind = town->facing_door_type == 0
            ? ZEL_ROOM_KING : town->facing_door_type == 1
            ? ZEL_ROOM_VIEWING : town->facing_door_type == 2
            ? ZEL_ROOM_SAGE : town->facing_door_type == 3
            ? ZEL_ROOM_ARMORY : town->facing_door_type == 4
            ? ZEL_ROOM_DRUGSTORE : town->facing_door_type == 5
            ? ZEL_ROOM_CHURCH : town->facing_door_type == 6
            ? ZEL_ROOM_BANK : ZEL_ROOM_INN;
        if (zeliard_town_begin_room_transition(
                town, kind, vga, vga_size)) return -4;
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    if (town->facing_door_type >= 8 && town->facing_door_type != 0xFF) {
        request_cavern_exit(town, cs, (u8)(town->facing_door_type - 8u));
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    if (town->facing_door_found && town->facing_door_type == 0xFF) {
        if (cs[0x0045] & 0x80) {
            town->building_transition =
                ZEL_TOWN_BUILDING_TRANSITION_SPECIAL;
            town->building_transition_pass = 0;
            town->building_transition_ticks = 0;
        } else {
            if (zeliard_town_dialog_begin_scripted(
                    &town->dialog, cs, game->segment[3], vga, vga_size,
                    0, 0x0918))
                return -3;
            town->special_door_pending = 1;
        }
        cs[GVAR_FRAME_TIMER] = 0;
        town->frame_count++;
        return 0;
    }
    if (town->facing_item_position != 0xFFFF) {
        const int result = zeliard_town_dialog_begin_live(
            &town->dialog, cs, game->segment[3],
            game_data, 0x10000, mask_data, 0x10000,
            vga, vga_size, town->facing_item_position);
        if (result) return -3;
    } else if (town->facing_npc_position != 0xFFFF) {
        const int result = zeliard_town_dialog_begin_facing(
            &town->dialog, cs, game->segment[3],
            game_data, 0x10000, mask_data, 0x10000,
            vga, vga_size, town->facing_npc_position);
        if (result) return -3;
    }
    move_player(cs, game_data, vga, vga_size, input_direction);
    cs[GVAR_FRAME_TIMER] = 0;
    town->frame_count++;
    return 0;
}

static int advance_building_transition(zeliard_town_runtime_t *town,
                                       zeliard_game_exec_state_t *game,
                                       u8 *vga, size_t vga_size) {
    /* GMMCGA:2184 runs LOOP 1F40h between masks. At the reference DOSBox-X
     * rate of 3000 cycles/ms, the 8086 LOOP timing maps to 11 PIT ticks. */
    enum { PASS_PIT_TICKS = 11 };
    if (++town->building_transition_ticks < PASS_PIT_TICKS) return 0;
    town->building_transition_ticks = 0;
    if (zeliard_gmmcga_building_fade_pass(
            vga, vga_size, town->building_transition_pass)) return -4;
    if (++town->building_transition_pass < 8) return 1;

    u8 *cs = game->segment[0];
    if (town->building_transition == ZEL_TOWN_BUILDING_TRANSITION_ENTER) {
        if (zeliard_room_enter(&town->room, town->pending_room_kind,
                               cs, 0x10000, vga, vga_size)) return -4;
        if (town->room.kind == ZEL_ROOM_SAGE ||
            town->room.kind == ZEL_ROOM_ARMORY ||
            town->room.kind == ZEL_ROOM_DRUGSTORE ||
            town->room.kind == ZEL_ROOM_CHURCH ||
            town->room.kind == ZEL_ROOM_BANK ||
            town->room.kind == ZEL_ROOM_INN) {
            if (!zeliard_room_masm_vm_start(
                    town->room.kind, cs, 0x10000, vga, vga_size)) return -5;
            town->room.exact_vm_active = 1;
        }
    } else if (town->building_transition == ZEL_TOWN_BUILDING_TRANSITION_LEAVE) {
        if (zeliard_room_leave(&town->room, cs, 0x10000,
                               vga, vga_size)) return -4;
        /* 106TOWN:door_type_shop resets gvar_pose_idx to 1 immediately
         * after the room program returns. Room programs reuse that byte;
         * carrying their value into render_town_actors indexes outside the
         * valid six-tile player pose and produces a garbled exit sprite. */
        cs[TOWN_POSE_INDEX] = 1;
        /* 212ARMRP commits directly to player sword/shield bytes and draws
         * the corresponding GMMCGA slots. Our room shell restores the town
         * frame, so repeat those exact driver calls against the live record. */
        const u8 sword = cs[ZEL_PLAYER_SWORD];
        if (sword && zeliard_gmmcga_draw_equipped_sword(
                         vga, vga_size, game->segment[1], 0x10000,
                         sword, 0x18AB))
            return -4;
        const u8 shield = cs[ZEL_PLAYER_SHIELD];
        if (shield &&
            (zeliard_gmmcga_draw_equipped_shield(
                 vga, vga_size, game->segment[1], 0x10000,
                 shield, 0x3EA4) ||
             zeliard_gmmcga_draw_status_line(
                 vga, vga_size, 0, 0xC61C, 0x1700) ||
             zeliard_gmmcga_draw_shield_hp(vga, vga_size, cs, 0x10000)))
            return -4;
    } else if (town->building_transition ==
               ZEL_TOWN_BUILDING_TRANSITION_SPECIAL) {
        /* 106TOWN:door_type_special loads town selector 86h (Dorado),
         * preserves the last-sage selector, then restarts the town at
         * start 0084h / screen column 0Dh under UGM2.MSD. */
        cs[PLAYER_CURRENT_AREA] = 0x86;
        write_u16(cs, TOWN_START_POSITION, 0x0084);
        cs[TOWN_PLAYER_COLUMN] = 0x0D;
        /* 106TOWN:special_door_load jumps back into the resident town loop
         * after fixing 0084h/0Dh; it does not take portal_check's side-1
         * entry walk. Model that resident-loop gate with init_complete only
         * for this synchronous full-frame reconstruction. */
        const u8 init_complete = cs[ZEL_PLAYER_INIT_COMPLETE];
        cs[ZEL_PLAYER_INIT_COMPLETE] = 0xFF;
        const int enter_result = zeliard_town_enter_first_frame(
            town, game, vga, vga_size);
        cs[ZEL_PLAYER_INIT_COMPLETE] = init_complete;
        if (enter_result) return -4;
        return 1;
    }
    town->building_transition = ZEL_TOWN_BUILDING_TRANSITION_NONE;
    town->pending_room_kind = ZEL_ROOM_NONE;
    town->building_transition_pass = 0;
    return 1;
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
        if (town->building_transition != ZEL_TOWN_BUILDING_TRANSITION_NONE) {
            const int result = advance_building_transition(
                town, game, vga, vga_size);
            if (result < 0) return result;
            frames += result;
            continue;
        }
        /* The exact room VM owns the same INT 8 clocks that its MASM busy
         * waits observe.  Do not advance FF1A/FF1B/FF50 here as well: doing
         * so doubles every shopkeeper and room-background animation rate. */
        if (town->room.active && town->room.exact_vm_active) {
            const int result = zeliard_room_advance_pit(
                &town->room, cs, 0x10000, vga, vga_size);
            if (result < 0) return result;
            frames = 1;
            if (result > 0) {
                town->building_transition = ZEL_TOWN_BUILDING_TRANSITION_LEAVE;
                town->building_transition_pass = 0;
                town->building_transition_ticks = 0;
            }
            continue;
        }
        cs[GVAR_FRAME_TIMER]++;
        write_u16(cs, 0xFF1B, (u16)(read_u16(cs, 0xFF1B) + 1));
        write_u16(cs, 0xFF50, (u16)(read_u16(cs, 0xFF50) + 1));
        if (town->dialog.active &&
            (town->dialog.prompt_cursor_anim_active ||
             town->dialog.scroll_active ||
             town->dialog.scroll_resume_pending)) {
            const int result = zeliard_town_dialog_advance_pit(
                &town->dialog, cs, vga, vga_size);
            if (result < 0) return -3;
            if (result > 0) frames = 1;
            continue;
        }
        if (town->room.active &&
            (town->room.kind == ZEL_ROOM_KING ||
             town->room.kind == ZEL_ROOM_CHURCH ||
             town->room.kind == ZEL_ROOM_ARMORY ||
             town->room.kind == ZEL_ROOM_DRUGSTORE ||
             town->room.kind == ZEL_ROOM_BANK)) {
            const int result = zeliard_room_advance_pit(
                &town->room, cs, 0x10000, vga, vga_size);
            if (result < 0) return result;
            /* The MASM room loop writes directly to A000 between normal
             * 106TOWN frames. Tell the host that its VGA mirror changed. */
            frames = 1;
            if (result > 0) {
                town->building_transition = ZEL_TOWN_BUILDING_TRANSITION_LEAVE;
                town->building_transition_pass = 0;
                town->building_transition_ticks = 0;
            }
            continue;
        }
        const u8 threshold = (u8)(4u * cs[GVAR_ANIM_SPEED]);
        if (cs[GVAR_FRAME_TIMER] < threshold) continue;
        const int result = run_live_frame(town, game, vga, vga_size,
                                          input_direction);
        if (result) return result;
        ++frames;
    }
    return frames;
}
