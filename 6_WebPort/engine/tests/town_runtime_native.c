#include "../game/town_runtime.h"
#include "../game/room_masm_vm.h"
#include "../core/player_state.h"
#include "../load/fill_buffer.h"
#include "../render/palette.h"
#include "../render/town_mcga.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static unsigned long long frame_rect_hash(const u8 *vga, u16 x, u16 y,
                                          u16 width, u16 height) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (u16 row = 0; row < height; ++row) {
        const u8 *pixel = vga + (size_t)(y + row) * 320u + x;
        for (u16 column = 0; column < width; ++column) {
            hash ^= pixel[column];
            hash *= 0x100000001B3ULL;
        }
    }
    return hash;
}

static u8 *read_file(const char *name, size_t *size) {
    FILE *file = fopen(name, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END);
    const long length = ftell(file);
    rewind(file);
    u8 *data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        data = NULL;
    }
    fclose(file);
    *size = length > 0 ? (size_t)length : 0;
    return data;
}

static int load_direct(u8 *destination, size_t capacity, const char *asset) {
    size_t size = 0;
    u8 *data = read_file(asset, &size);
    if (!data || size > capacity) {
        free(data);
        return 0;
    }
    memcpy(destination, data, size);
    free(data);
    return 1;
}

static int load_raw(u8 *destination, size_t capacity, const char *asset) {
    size_t size = 0;
    u8 *data = read_file(asset, &size);
    if (!data || size < 4) {
        free(data);
        return 0;
    }
    const size_t declared = (size_t)data[0] | ((size_t)data[1] << 8) |
        ((size_t)data[2] << 16) | ((size_t)data[3] << 24);
    if (declared > size - 4 || declared > capacity) {
        free(data);
        return 0;
    }
    memcpy(destination, data + 4, declared);
    free(data);
    return 1;
}

static int load_font(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *data = read_file("assets/font.grp", &size);
    u8 *decoded = data ? fill_buffer_decompress(data, size, &decoded_size) : NULL;
    free(data);
    if (!decoded || decoded_size > 0x0B00) {
        free(decoded);
        return 0;
    }
    memcpy(segment + 0xF500, decoded, decoded_size);
    free(decoded);
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = (u16)(segment[0xF500 + offset] |
                                ((u16)segment[0xF501 + offset] << 8));
        const u16 relocated = (u16)(value + 0xF500);
        segment[0xF500 + offset] = (u8)relocated;
        segment[0xF501 + offset] = (u8)(relocated >> 8);
    }
    return 1;
}

static int load_item_panel(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *data = read_file("assets/itemp.grp", &size);
    u8 *decoded = data ? fill_buffer_decompress(data, size, &decoded_size) : NULL;
    free(data);
    if (!decoded || decoded_size > 0x1E00) {
        free(decoded);
        return 0;
    }
    memcpy(segment + 0xE200, decoded, decoded_size);
    free(decoded);
    for (u16 offset = 0; offset < 14; offset += 2) {
        const u16 value = (u16)(segment[0xE200 + offset] |
                                ((u16)segment[0xE201 + offset] << 8));
        const u16 relocated = (u16)(value + 0xE200);
        segment[0xE200 + offset] = (u8)relocated;
        segment[0xE201 + offset] = (u8)(relocated >> 8);
    }
    return 1;
}

static unsigned long long selected_state_hash(const u8 *segment) {
    static const struct { u16 offset; u8 size; } ranges[] = {
        {0x009F, 1}, {0x00E4, 1}, {0x2433, 7}, {0x2CBD, 2},
        {0x7C45, 2}, {0xFF1D, 2}, {0xFF2A, 2},
    };
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t range = 0; range < sizeof(ranges) / sizeof(ranges[0]); ++range) {
        for (u8 index = 0; index < ranges[range].size; ++index) {
            hash ^= segment[ranges[range].offset + index];
            hash *= 0x100000001B3ULL;
        }
    }
    return hash;
}

static unsigned long long npc_state_hash(const u8 *segment) {
    u16 at = (u16)(segment[0xC00F] | ((u16)segment[0xC010] << 8));
    size_t size = 2;
    while (at + size + 8 <= 0x10000) {
        const u16 position = (u16)(segment[at + size - 2] |
                                   ((u16)segment[at + size - 1] << 8));
        if (position == 0xFFFF) break;
        size += 8;
    }
    return fnv1a64(segment + at, size);
}

static int town_actor_bank_matches(const u8 *game_data, const u8 *mask_data,
                                   u8 selector) {
    static const unsigned long long pixel_hashes[2] = {
        0xC287EABFFE898D6CULL, 0x44D254E063EEEC7DULL,
    };
    static const unsigned long long mask_hashes[2] = {
        0xF205BFB757BBDA0CULL, 0x4F2D17A7A7837D5FULL,
    };
    return selector < 2 &&
        fnv1a64(game_data + 0x4100, 0x1EC0) == pixel_hashes[selector] &&
        fnv1a64(mask_data + 0x7000, 0x0520) == mask_hashes[selector];
}

static int town_actor_patterns_match(const u8 *expected_game_data,
                                     const u8 *expected_mask_data,
                                     const u8 *actual_game_data,
                                     const u8 *actual_mask_data) {
    /* MMAN is shorter than the A4h-tile conversion span used by 106TOWN,
     * so bytes after its authored payload retain prior segment contents.
     * Compare the five entities' pattern table and every tile it can
     * reference, excluding that intentionally unowned tail. */
    if (memcmp(expected_game_data + 0x4000, actual_game_data + 0x4000,
               5u * 0x30u) != 0)
        return 0;
    for (u16 pattern = 0; pattern < 5u * 0x30u; ++pattern) {
        const u8 tile_id = expected_game_data[0x4000 + pattern];
        if (!tile_id || tile_id > 0xA4) return 0;
        const u8 tile = (u8)(tile_id - 1);
        if (memcmp(expected_game_data + 0x4100 + (u16)tile * 0x30u,
                   actual_game_data + 0x4100 + (u16)tile * 0x30u,
                   0x30) != 0 ||
            memcmp(expected_mask_data + 0x7000 + (u16)tile * 8u,
                   actual_mask_data + 0x7000 + (u16)tile * 8u,
                   8) != 0)
            return 0;
    }
    return 1;
}

static int town_npc_records_are_renderable(const u8 *segment,
                                            u8 expected_count) {
    u16 at = (u16)(segment[0xC00F] | ((u16)segment[0xC010] << 8));
    for (u8 count = 0; count < expected_count; ++count, at = (u16)(at + 8)) {
        if (at > 0xFFF7) return 0;
        const u16 position =
            (u16)(segment[at] | ((u16)segment[at + 1] << 8));
        const u8 entity = (u8)(segment[at + 2] & 0x7F);
        const u8 motion = segment[at + 5];
        /* GTMCGA gives each entity eight six-byte patterns (four frames in
         * each direction) in the 4000h..40FFh actor table. */
        const u16 last_pattern_byte =
            (u16)(0x4000u + (u16)entity * 0x30u + 7u * 6u + 5u);
        if (position == 0xFFFF || motion > 7 || last_pattern_byte >= 0x4100)
            return 0;
    }
    return at <= 0xFFFE && segment[at] == 0xFF && segment[at + 1] == 0xFF;
}

static int dirty_town_entry_matches_clean(u8 area_id,
                                          unsigned long long *frame_hash) {
    static const u8 actor_selectors[10] = {0, 0, 1, 0, 1, 1, 0, 1, 1, 0};
    static const u8 npc_counts[10] = {4, 9, 7, 12, 8, 8, 12, 9, 10, 7};
    static u8 clean_segments[ZELIARD_GAME_SEGMENT_COUNT]
                            [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 dirty_segments[ZELIARD_GAME_SEGMENT_COUNT]
                            [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 clean_vga[0x10000];
    static u8 dirty_vga[0x10000];
    zeliard_game_exec_state_t clean_game = {0};
    zeliard_game_exec_state_t dirty_game = {0};
    zeliard_town_runtime_t clean_town = {0};
    zeliard_town_runtime_t dirty_town = {0};

    memset(clean_segments, 0, sizeof(clean_segments));
    memset(dirty_segments, 0, sizeof(dirty_segments));
    memset(clean_vga, 0, sizeof(clean_vga));
    memset(dirty_vga, 0xA5, sizeof(dirty_vga));
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        clean_game.segment[i] = clean_segments[i];
        clean_game.segment_size[i] = sizeof(clean_segments[i]);
        dirty_game.segment[i] = dirty_segments[i];
        dirty_game.segment_size[i] = sizeof(dirty_segments[i]);
    }
    const int clean_loaded =
        load_direct(clean_segments[0], sizeof(clean_segments[0]),
                    "assets/stdply.bin") &&
        load_direct(clean_segments[0] + 0x2000, 0xE000,
                    "assets/gmmcga.bin") &&
        load_raw(clean_segments[0] + 0x6000, 0xA000,
                 "assets/town.bin") &&
        load_raw(clean_segments[3], sizeof(clean_segments[3]),
                 "assets/mole.bin") &&
        load_font(clean_segments[0]) && load_item_panel(clean_segments[1]);
    if (!clean_loaded) return 0;
    memcpy(dirty_segments, clean_segments, sizeof(clean_segments));
    for (unsigned copy = 0; copy < 2; ++copy) {
        u8 *player = copy ? dirty_segments[0] : clean_segments[0];
        player[0x00C4] = area_id;
        player[0x00C5] = area_id;
        player[ZEL_PLAYER_START_POSITION] = 0x20;
        player[ZEL_PLAYER_START_POSITION + 1] = 0;
        player[ZEL_PLAYER_MAP_SCROLL_ROW] = 0;
        player[ZEL_PLAYER_SCREEN_POSITION] = 0x0D;
        player[ZEL_PLAYER_INIT_COMPLETE] = 0xFF;
        player[ZEL_PLAYER_SWORD] = 1;
        player[ZEL_PLAYER_SHIELD] = 1;
        player[ZEL_PLAYER_SHIELD_HP] = 30;
        player[ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    }
    const int clean_result = zeliard_town_enter_first_frame(
        &clean_town, &clean_game, clean_vga, sizeof(clean_vga));
    const int dirty_result = zeliard_town_enter_first_frame(
        &dirty_town, &dirty_game, dirty_vga, sizeof(dirty_vga));
    /* A cavern return re-enters 106TOWN with the already-executed town
     * overlay resident. It must still match a pristine first invocation. */
    memset(dirty_vga, 0x5A, sizeof(dirty_vga));
    const int repeated_result = zeliard_town_enter_first_frame(
        &dirty_town, &dirty_game, dirty_vga, sizeof(dirty_vga));
    if (frame_hash) *frame_hash = fnv1a64(dirty_vga, sizeof(dirty_vga));
    const u8 town_index = (u8)(area_id - 0x80);
    const int clean_bank = town_index < 10 && town_actor_bank_matches(
        clean_segments[1], clean_segments[2], actor_selectors[town_index]);
    const int dirty_bank = town_index < 10 && town_actor_patterns_match(
        clean_segments[1], clean_segments[2], dirty_segments[1],
        dirty_segments[2]);
    const int clean_npcs = town_index < 10 && town_npc_records_are_renderable(
        clean_segments[0], npc_counts[town_index]);
    const int dirty_npcs = town_index < 10 && town_npc_records_are_renderable(
        dirty_segments[0], npc_counts[town_index]);
    printf("town_npc_audit_%02x: bank=%d/%d records=%d/%d count=%u\n",
           area_id, clean_bank, dirty_bank, clean_npcs, dirty_npcs,
           town_index < 10 ? (unsigned)npc_counts[town_index] : 0);
    return clean_result == 0 && dirty_result == 0 && repeated_result == 0 &&
        town_index < 10 && clean_town.area == (zeliard_town_area_t)town_index &&
        clean_town.area == dirty_town.area &&
        clean_bank && dirty_bank && clean_npcs && dirty_npcs &&
        memcmp(clean_vga, dirty_vga, sizeof(clean_vga)) == 0;
}

int main(void) {
    u8 segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE] = {{0}};
    u8 vga[0x10000] = {0};
    zeliard_game_exec_state_t game = {0};
    zeliard_town_runtime_t town;
    int ok = 1;
    u8 facing_fixture[0x10000] = {0};
    zeliard_town_runtime_t facing_town = {0};
    facing_fixture[0x0080] = 0x20;
    facing_fixture[0x0083] = 0x0A;
    facing_fixture[0xFF2A] = 0x00;
    facing_fixture[0xFF2B] = 0x50;
    facing_fixture[0xC00F] = 0x00;
    facing_fixture[0xC010] = 0x60;
    facing_fixture[0xC009] = 0x00;
    facing_fixture[0xC00A] = 0x61;
    facing_fixture[0xFF1D] = 0xFF;
    facing_fixture[0x507D] = 0xFD;
    facing_fixture[0x5085] = 0xFD;
    static const u8 facing_npcs[] = {
        0x2F, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00,
        0x30, 0x00, 0x80, 0x00, 0x00, 0x07, 0x80, 0x00,
        0xFF, 0xFF,
    };
    static const u8 facing_doors[] = {0x2E, 0x00, 0x07, 0xFF, 0xFF};
    memcpy(facing_fixture + 0x6000, facing_npcs, sizeof(facing_npcs));
    memcpy(facing_fixture + 0x6100, facing_doors, sizeof(facing_doors));
    zeliard_town_detect_facing_targets(&facing_town, facing_fixture, 1);
    static const u8 npc_seed_anim[8] = {0x30, 0x10, 0x30, 0x55,
                                        0x30, 0x10, 0x30, 0x55};
    static const u16 npc_expected_position[8] = {
        0x20, 0x1F, 0x1F, 0x20, 0x20, 0x1F, 0x1F, 0x20};
    static const u8 npc_expected_anim[8] = {
        0x01, 0x01, 0x01, 0x55, 0x01, 0x01, 0x01, 0x55};
    for (u8 type = 0; type < 8; ++type) {
        memset(facing_fixture, 0, sizeof(facing_fixture));
        facing_fixture[0x0083] = 0x0A;
        facing_fixture[0xC00F] = 0x00;
        facing_fixture[0xC010] = 0x60;
        facing_fixture[0xC011] = 0x00;
        facing_fixture[0xC012] = 0x62;
        facing_fixture[0x6202] = 0x40;
        facing_fixture[0x6000] = 0x20;
        facing_fixture[0x6002] = 0x80;
        facing_fixture[0x6003] = 0x22;
        facing_fixture[0x6004] = npc_seed_anim[type];
        facing_fixture[0x6005] = type;
        facing_fixture[0x6008] = 0xFF;
        facing_fixture[0x6009] = 0xFF;
        facing_fixture[0xC01C + 0x20 * 8] = 0xFD;
        facing_fixture[0xC01C + 0x1F * 8] = 0x33;
        zeliard_town_tick_npcs(facing_fixture);
        const u16 position = (u16)(facing_fixture[0x6000] |
                                   ((u16)facing_fixture[0x6001] << 8));
        ok &= position == npc_expected_position[type];
        ok &= facing_fixture[0x6004] == npc_expected_anim[type];
    }
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        game.segment[i] = segments[i];
        game.segment_size[i] = sizeof(segments[i]);
    }
    ok &= load_direct(segments[0], sizeof(segments[0]), "assets/stdply.bin") &&
        load_direct(segments[0] + 0x2000, 0xE000, "assets/gmmcga.bin") &&
        load_raw(segments[0] + 0x6000, 0xA000, "assets/town.bin") &&
        load_raw(segments[3], sizeof(segments[3]), "assets/mole.bin") &&
        load_font(segments[0]) && load_item_panel(segments[1]);
    const u16 pristine_shield_base = (u16)(segments[1][0xE202] |
        ((u16)segments[1][0xE203] << 8));
    const unsigned long long pristine_shield_source = fnv1a64(
        segments[1] + pristine_shield_base, 0xC0);
    static const unsigned long long equipped_spell_oracle[7] = {
        0x4B78EDCB41024AE4ULL, 0x38EC34BD15886153ULL,
        0x27BE1BB89569FF7DULL, 0x084168335E2CB4F8ULL,
        0x22C4134884DF7F89ULL, 0xAE4412E5B02DFFDBULL,
        0xCB99E1ED8440BF12ULL,
    };
    static u8 equipped_spell_vga[0x10000];
    unsigned long long equipped_spell_hashes[7];
    for (u8 spell = 1; spell <= 7; ++spell) {
        memset(equipped_spell_vga, 0, sizeof(equipped_spell_vga));
        ok &= zeliard_gmmcga_draw_equipped_spell(
            equipped_spell_vga, sizeof(equipped_spell_vga),
            segments[1], sizeof(segments[1]), spell, 0x37A4) == 0;
        equipped_spell_hashes[spell - 1] = frame_rect_hash(
            equipped_spell_vga, 222, 164, 16, 16);
        ok &= equipped_spell_hashes[spell - 1] ==
              equipped_spell_oracle[spell - 1];
    }
    /* A Sage changes selected_spell while its room overlay owns VGA. On
     * return, the cached town frame may still contain the previously
     * selected spell. Pin the exit redraw to the newly learned spell. */
    static u8 sage_exit_vga[0x10000];
    static u8 sage_exit_game[0x10000];
    memset(sage_exit_vga, 0, sizeof(sage_exit_vga));
    memcpy(sage_exit_game, segments[0], sizeof(sage_exit_game));
    sage_exit_game[ZEL_PLAYER_SELECTED_SPELL] = 1;
    ok &= zeliard_gmmcga_draw_equipped_spell(
        sage_exit_vga, sizeof(sage_exit_vga), segments[1],
        sizeof(segments[1]), 1, 0x37A4) == 0;
    sage_exit_game[ZEL_PLAYER_SELECTED_SPELL] = 2;
    sage_exit_game[ZEL_PLAYER_SPELL_CHARGES + 1] = 6;
    ok &= zeliard_town_redraw_room_exit_spell_hud(
        sage_exit_vga, sizeof(sage_exit_vga), sage_exit_game,
        sizeof(sage_exit_game), segments[1], sizeof(segments[1])) == 0;
    const unsigned long long sage_exit_spell = frame_rect_hash(
        sage_exit_vga, 222, 164, 16, 16);
    const unsigned long long sage_exit_charge = frame_rect_hash(
        sage_exit_vga, 220, 187, 16, 8);
    ok &= sage_exit_spell == equipped_spell_oracle[1] &&
          sage_exit_charge == 0xE4CD1F75D7093925ULL;
    ok &= facing_town.facing_item_position == 0x002F;
    ok &= facing_town.facing_npc_position == 0x0030;
    ok &= facing_town.facing_door_type == 0x07;
    ok &= facing_fixture[0xFF1D] == 0;
    const int result = ok ? zeliard_town_enter_first_frame(
        &town, &game, vga, sizeof(vga)) : -99;
    ok &= result == 0;
    const unsigned long long frame_hash = fnv1a64(vga, sizeof(vga));
    const unsigned long long sword_hash =
        frame_rect_hash(vga, 192, 171, 20, 18);
    const unsigned long long state_hash = selected_state_hash(segments[0]);
    const unsigned long long capture_hash = fnv1a64(segments[0] + 0xA000, 0x1500);
    const unsigned long long palette_hash = fnv1a64((const u8 *)g_palette,
                                                    sizeof(g_palette));
    printf("town_mman_banks: pixels=%016llx masks=%016llx\n",
           fnv1a64(segments[1] + 0x4100, 0x1EC0),
           fnv1a64(segments[2] + 0x7000, 0x0520));
    printf("town_itemp_shield_source: base=%04x source=%016llx\n",
           pristine_shield_base, pristine_shield_source);
    printf("town_itemp_spell_frames: %016llx/%016llx/%016llx/%016llx/"
           "%016llx/%016llx/%016llx\n",
           equipped_spell_hashes[0], equipped_spell_hashes[1],
           equipped_spell_hashes[2], equipped_spell_hashes[3],
           equipped_spell_hashes[4], equipped_spell_hashes[5],
           equipped_spell_hashes[6]);
    printf("town_sage_exit_spell_hud: spell=%016llx charge=%016llx\n",
           sage_exit_spell, sage_exit_charge);
    const unsigned long long cpat_pixel_hash =
        fnv1a64(segments[1] + 0x8100, 0x2EE0);
    const unsigned long long cpat_alpha_hash =
        fnv1a64(segments[1] + 0xD000, 0x07D0);
    printf("town_cpat_banks: pixels=%016llx alpha=%016llx\n",
           cpat_pixel_hash, cpat_alpha_hash);
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-first-frame.bin", "wb");
        if (dump) {
            fwrite(vga, 1, sizeof(vga), dump);
            fclose(dump);
        }
    }
    ok &= town.event_count == 12;
    ok &= town.town_text_record == 0xC3B0;
    ok &= town.map_side == 0 && town.palette_index == 0;
    ok &= segments[0][0xC3AC] == 0x00;
    ok &= segments[0][0xC3AD] == 0xFF;
    ok &= frame_hash == 0xC2F2C7571B84C55DULL;
    ok &= sword_hash == 0xACE1EEC895369B0AULL;
    ok &= state_hash == 0xE75DC3416036703FULL;
    ok &= capture_hash == 0xF2C3F82A0F93D06DULL;
    ok &= palette_hash == 0xF0597D78ABA0CC75ULL;
    ok &= cpat_pixel_hash == 0x639503FA794A154FULL;
    ok &= cpat_alpha_hash == 0x2AE75F00707E7659ULL;
    ok &= fnv1a64(vga + 0xFA00, 0x180) == 0x14D37DE120D41703ULL;

    static u8 door_segments[ZELIARD_GAME_SEGMENT_COUNT]
                           [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 door_vga[0x10000];
    memcpy(door_segments, segments, sizeof(door_segments));
    memcpy(door_vga, vga, sizeof(door_vga));
    zeliard_town_runtime_t *door_town = malloc(sizeof(*door_town));
    if (!door_town) return 1;
    *door_town = town;
    u16 door_at = (u16)(segments[0][0xC009] |
                        ((u16)segments[0][0xC00A] << 8));
    u16 viewing_position = 0xFFFF;
    while (door_at <= 0xFFFC) {
        const u16 position = (u16)(segments[0][door_at] |
            ((u16)segments[0][(u16)(door_at + 1)] << 8));
        if (position == 0xFFFF) break;
        if (segments[0][(u16)(door_at + 2)] == 1) {
            viewing_position = position;
            break;
        }
        door_at = (u16)(door_at + 3);
    }
    const u8 door_column = 0x0E;
    const u16 door_start = (u16)(viewing_position - door_column - 4u);
    segments[0][0x0080] = (u8)door_start;
    segments[0][0x0081] = (u8)(door_start >> 8);
    segments[0][0x0083] = door_column;
    const u16 door_tile_ptr = (u16)(0xC017u + (u16)(u8)door_start * 8u);
    segments[0][0xFF2A] = (u8)door_tile_ptr;
    segments[0][0xFF2B] = (u8)(door_tile_ptr >> 8);
    segments[0][0xFF33] = 5;
    const int viewing_trigger_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 1);
    ok &= viewing_trigger_frames == 1 && !town.room.active;
    ok &= segments[0][0x00E7] == 4;
    ok &= town.building_transition == ZEL_TOWN_BUILDING_TRANSITION_ENTER;
    ok &= town.pending_room_kind == ZEL_ROOM_VIEWING;
    ok &= memcmp(town.room.saved_vga, vga, sizeof(vga)) == 0;
    const unsigned long long viewing_door_pose_hash =
        frame_rect_hash(vga, (u16)(48u + door_column * 8u), 118, 16, 24);
    ok &= viewing_door_pose_hash == 0xB35317713AEBD129ULL;
    const int viewing_fade_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 88, 0);
    const unsigned long long viewing_frame_hash = fnv1a64(vga, sizeof(vga));
    const unsigned long long viewing_artwork_hash =
        frame_rect_hash(vga, 96, 30, 136, 128);
    ok &= viewing_position != 0xFFFF && viewing_fade_frames == 8;
    ok &= town.room.active && town.room.kind == ZEL_ROOM_VIEWING;
    ok &= town.building_transition == ZEL_TOWN_BUILDING_TRANSITION_NONE;
    ok &= viewing_artwork_hash == 0x33207D5A3E0A63EFULL;
    segments[0][0xFF1D] = 0xFF;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0) == 1;
    ok &= town.room.active;
    ok &= town.building_transition == ZEL_TOWN_BUILDING_TRANSITION_LEAVE;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 88, 0) == 8;
    ok &= !town.room.active && town.room.kind == ZEL_ROOM_NONE;
    ok &= segments[0][0x00E7] == 1;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0) == 1;
    const unsigned long long viewing_return_player =
        frame_rect_hash(vga, (u16)(48u + door_column * 8u), 118, 16, 24);
    ok &= viewing_return_player == 0x2FA50B810D419D98ULL;
    printf("town_viewing_room: position=%04x frame=%016llx "
           "artwork=%016llx door_pose=%016llx return=%016llx "
           "pose=%u entered=%d\n",
           viewing_position, viewing_frame_hash, viewing_artwork_hash,
           viewing_door_pose_hash, viewing_return_player,
           segments[0][0x00E7], viewing_fade_frames);
    memcpy(segments, door_segments, sizeof(door_segments));
    memcpy(vga, door_vga, sizeof(door_vga));
    town = *door_town;

    segments[0][0x0049] = 0xFF;
    ok &= zeliard_room_enter(&town.room, ZEL_ROOM_VIEWING,
                             segments[0], sizeof(segments[0]),
                             vga, sizeof(vga)) == 0;
    ok &= town.room.alternate_transition_requested;
    segments[0][0xFF1D] = 0xFF;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0) > 0;
    ok &= town.room.active;
    ok &= zeliard_room_leave(&town.room, segments[0], sizeof(segments[0]),
                             vga, sizeof(vga)) == 0;
    memcpy(segments, door_segments, sizeof(door_segments));
    memcpy(vga, door_vga, sizeof(door_vga));
    town = *door_town;
    free(door_town);

    static u8 overlap_segment[ZELIARD_GAME_SEGMENT_SIZE];
    static u8 overlap_vga[0x10000];
    memcpy(overlap_segment, segments[0], sizeof(overlap_segment));
    memcpy(overlap_vga, vga, sizeof(overlap_vga));
    unsigned long long overlap_hashes[4] = {0};
    for (u8 column = 0x0C; column < 0x10; ++column) {
        memcpy(segments[0], overlap_segment, sizeof(overlap_segment));
        memcpy(vga, overlap_vga, sizeof(overlap_vga));
        segments[0][0x0083] = column;
        memset(segments[0] + 0xE000, 0xFE, 0xE0);
        ok &= zeliard_gtmcga_render_town_actors(
            segments[0], 0x10000, segments[1], 0x10000,
            segments[2], 0x10000, vga, sizeof(vga)) == 0;
        const u16 cursor = (u16)(0xE000 + (u16)column * 8u + 5u);
        memset(segments[0] + cursor, 0xFF, 3);
        memset(segments[0] + cursor + 8, 0xFF, 3);
        ok &= zeliard_gtmcga_update_town_frame(
            segments[0], 0x10000, segments[1], 0x10000,
            segments[2], 0x10000, vga, sizeof(vga)) == 0;
        overlap_hashes[column - 0x0C] = fnv1a64(vga, sizeof(vga));
        if (getenv("ZELIARD_DUMP")) {
            char path[64];
            snprintf(path, sizeof(path), "build/town-overlap-col%02x.bin",
                     column);
            FILE *dump = fopen(path, "wb");
            if (dump) {
                fwrite(vga, 1, sizeof(vga), dump);
                fclose(dump);
            }
        }
    }
    memcpy(segments[0], overlap_segment, sizeof(overlap_segment));
    memcpy(vga, overlap_vga, sizeof(overlap_vga));
    printf("town_castle_actor_overlap: col0c=%016llx col0d=%016llx "
           "col0e=%016llx col0f=%016llx\n",
           overlap_hashes[0], overlap_hashes[1], overlap_hashes[2],
           overlap_hashes[3]);
    static const unsigned long long expected_overlap_hashes[4] = {
        0x6333D093FCA2C433ULL, 0x1D5A1101EDF5C98AULL,
        0x2F929C9CEA3C7BDAULL, 0x272B599A04C3F1F5ULL,
    };
    for (size_t index = 0; index < 4; ++index)
        ok &= overlap_hashes[index] == expected_overlap_hashes[index];

    static u8 idle_segments[ZELIARD_GAME_SEGMENT_COUNT]
                           [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 idle_vga[0x10000];
    memcpy(idle_segments, segments, sizeof(idle_segments));
    memcpy(idle_vga, vga, sizeof(idle_vga));
    const zeliard_town_runtime_t initial_town = town;
    segments[0][0xFF33] = 5;
    const int idle_frames_1 = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long idle_frame_hash_1 = fnv1a64(vga, sizeof(vga));
    const unsigned long long idle_npc_hash_1 = npc_state_hash(segments[0]);
    if (getenv("ZELIARD_DUMP")) {
        FILE *idle_dump = fopen("build/town-idle-frame-1.bin", "wb");
        if (idle_dump) {
            fwrite(vga, 1, sizeof(vga), idle_dump);
            fclose(idle_dump);
        }
        idle_dump = fopen("build/town-idle-state-1.bin", "wb");
        if (idle_dump) {
            fwrite(segments[0], 1, sizeof(segments[0]), idle_dump);
            fclose(idle_dump);
        }
    }
    const int idle_frames_2 = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long idle_frame_hash_2 = fnv1a64(vga, sizeof(vga));
    const unsigned long long idle_npc_hash_2 = npc_state_hash(segments[0]);
    if (getenv("ZELIARD_DUMP")) {
        FILE *idle_dump = fopen("build/town-idle-frame-2.bin", "wb");
        if (idle_dump) {
            fwrite(vga, 1, sizeof(vga), idle_dump);
            fclose(idle_dump);
        }
        idle_dump = fopen("build/town-idle-state-2.bin", "wb");
        if (idle_dump) {
            fwrite(segments[0], 1, sizeof(segments[0]), idle_dump);
            fclose(idle_dump);
        }
    }
    ok &= idle_frames_1 == 1 && idle_frames_2 == 1;
    ok &= idle_frame_hash_1 == 0x29B8C02DC02C4CF5ULL;
    ok &= idle_npc_hash_1 == 0x7AEF6E1921E0C970ULL;
    ok &= idle_frame_hash_2 == 0xD78AC5FEC4195764ULL;
    ok &= idle_npc_hash_2 == 0x04FCC161ECC110A0ULL;
    printf("town_idle_oracle: frame1=%016llx/npc=%016llx "
           "frame2=%016llx/npc=%016llx\n",
           idle_frame_hash_1, idle_npc_hash_1,
           idle_frame_hash_2, idle_npc_hash_2);
    memcpy(segments, idle_segments, sizeof(idle_segments));
    memcpy(vga, idle_vga, sizeof(idle_vga));
    town = initial_town;
    const u8 initial_column = segments[0][0x0083];
    const u16 initial_start = (u16)(segments[0][0x0080] |
                                    ((u16)segments[0][0x0081] << 8));
    segments[0][0xFF33] = 5;
    const int right_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 8);
    const int settle_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long live_frame_hash = fnv1a64(vga, sizeof(vga));
    const unsigned long long live_npc_hash = npc_state_hash(segments[0]);
    const u32 live_frame_count = town.frame_count;
    const u16 live_start = (u16)(segments[0][0x0080] |
                                 ((u16)segments[0][0x0081] << 8));
    ok &= right_frames == 1 && settle_frames == 1;
    ok &= town.frame_count == 2;
    ok &= segments[0][0x0083] == (u8)(initial_column + 1);
    ok &= live_start == initial_start;
    ok &= (segments[0][0x00C2] & 1) == 0;
    ok &= live_frame_hash == 0xEE82A668ED2EE7ACULL;
    ok &= live_npc_hash == 0x04FCC161ECC110A0ULL;
    const int scroll_walk_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 140, 8);
    const int scroll_settle_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const u16 scrolled_start = (u16)(segments[0][0x0080] |
                                     ((u16)segments[0][0x0081] << 8));
    const unsigned long long scrolled_frame_hash = fnv1a64(vga, sizeof(vga));
    ok &= scroll_walk_frames == 7 && scroll_settle_frames == 1;
    ok &= town.frame_count == 10;
    ok &= segments[0][0x0083] == 0x10;
    ok &= scrolled_start == (u16)(initial_start + 2);
    ok &= scrolled_frame_hash == 0x36B79FA14F9B7C34ULL;

    memcpy(segments, idle_segments, sizeof(idle_segments));
    memcpy(vga, idle_vga, sizeof(idle_vga));
    town = initial_town;
    segments[0][0x0080] = 0x4E;
    segments[0][0x0081] = 0;
    segments[0][0x0083] = 0x1C;
    segments[0][0xFF2A] = 0x87;
    segments[0][0xFF2B] = 0xC2;
    segments[0][0xFF33] = 5;
    const int muralla_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long muralla_frame_hash = fnv1a64(vga, sizeof(vga));
    const unsigned long long muralla_playfield_hash = fnv1a64(vga, 160u * 320u);
    const unsigned long long muralla_state_hash = selected_state_hash(segments[0]);
    const unsigned long long muralla_npc_hash = npc_state_hash(segments[0]);
    const unsigned long long mpat_pixel_hash =
        fnv1a64(segments[1] + 0x8100, 0x2EE0);
    const unsigned long long mpat_alpha_hash =
        fnv1a64(segments[1] + 0xD000, 0x07D0);
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-muralla-c-frame.bin", "wb");
        if (dump) {
            fwrite(vga, 1, sizeof(vga), dump);
            fclose(dump);
        }
    }
    ok &= muralla_frames == 1;
    ok &= town.area == ZEL_TOWN_AREA_MURALLA;
    ok &= town.map_side == 0 && town.palette_index == 1;
    ok &= town.town_text_record == 0xC6D8;
    ok &= segments[0][0x00C4] == 0x81;
    ok &= segments[0][0x0080] == 0 && segments[0][0x0081] == 0;
    ok &= segments[0][0x0083] == 0;
    ok &= segments[0][0xC002] == 0xD7 && segments[0][0xC003] == 0;
    ok &= mpat_pixel_hash == 0x057549E40BE35E14ULL;
    ok &= mpat_alpha_hash == 0x68EDAA05B46B4C6EULL;
    ok &= muralla_playfield_hash == 0x2DF9ABEBE695245FULL;
    u8 *muralla_snapshot = malloc(sizeof(segments) + sizeof(vga));
    zeliard_town_runtime_t muralla_town_snapshot = town;
    ok &= muralla_snapshot != NULL;
    if (muralla_snapshot) {
        memcpy(muralla_snapshot, segments, sizeof(segments));
        memcpy(muralla_snapshot + sizeof(segments), vga, sizeof(vga));
    }
    const u16 muralla_npc_list = (u16)(segments[0][0xC00F] |
        ((u16)segments[0][0xC010] << 8));
    const u16 muralla_talk_npc = (u16)(muralla_npc_list + 8);
    const u16 muralla_talk_position = (u16)(segments[0][muralla_talk_npc] |
        ((u16)segments[0][(u16)(muralla_talk_npc + 1)] << 8));
    const u8 muralla_dialog_id = segments[0][(u16)(muralla_talk_npc + 7)];
    const u8 muralla_npc_direction = segments[0][(u16)(muralla_talk_npc + 2)];
    const u8 muralla_npc_type = segments[0][(u16)(muralla_talk_npc + 5)];

    /* 106TOWN dialog waits call tick_npcs_then_pump: the speaker is switched
     * to stationary type 7 while every other NPC continues its normal
     * movement/animation dispatch. Exercise the public PIT path so this
     * cannot regress into a dialog-only early return. */
    ok &= zeliard_town_dialog_begin_live(
        &town.dialog, segments[0], segments[3],
        segments[1], sizeof(segments[1]),
        segments[2], sizeof(segments[2]), vga, sizeof(vga),
        muralla_talk_position) == 0;
    const unsigned long long dialog_npc_state_before =
        npc_state_hash(segments[0]);
    const u16 dialog_speaker_position_before =
        (u16)(segments[0][muralla_talk_npc] |
              ((u16)segments[0][(u16)(muralla_talk_npc + 1)] << 8));
    segments[0][0xFF33] = 5;
    const int dialog_motion_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long dialog_npc_state_after =
        npc_state_hash(segments[0]);
    const u16 dialog_speaker_position_after =
        (u16)(segments[0][muralla_talk_npc] |
              ((u16)segments[0][(u16)(muralla_talk_npc + 1)] << 8));
    printf("town_dialog_npc_motion: frames=%d active=%d "
           "npc=%016llx/%016llx speaker=%04x/%04x type=%u\n",
           dialog_motion_frames, town.dialog.active,
           dialog_npc_state_before, dialog_npc_state_after,
           dialog_speaker_position_before, dialog_speaker_position_after,
           segments[0][(u16)(muralla_talk_npc + 5)]);
    ok &= dialog_motion_frames == 1 && town.dialog.active &&
        dialog_npc_state_after != dialog_npc_state_before &&
        dialog_speaker_position_after == dialog_speaker_position_before &&
        segments[0][(u16)(muralla_talk_npc + 5)] == 7;

    if (muralla_snapshot) {
        memcpy(segments, muralla_snapshot, sizeof(segments));
        memcpy(vga, muralla_snapshot + sizeof(segments), sizeof(vga));
        town = muralla_town_snapshot;
    }
    const u8 muralla_saved_player_col = segments[0][0x0083];
    segments[0][0x0083] = 5;
    ok &= zeliard_gtmcga_render_town_actors(
        segments[0], sizeof(segments[0]), segments[1], sizeof(segments[1]),
        segments[2], sizeof(segments[2]), vga, sizeof(vga)) == 0;
    memset(segments[0] + 0xE02D, 0xFF, 3);
    memset(segments[0] + 0xE035, 0xFF, 3);
    ok &= zeliard_gtmcga_update_town_frame(
        segments[0], sizeof(segments[0]), segments[1], sizeof(segments[1]),
        segments[2], sizeof(segments[2]), vga, sizeof(vga)) == 0;
    u8 *muralla_dialog_base = malloc(sizeof(vga));
    ok &= muralla_dialog_base != NULL;
    if (muralla_dialog_base) memcpy(muralla_dialog_base, vga, sizeof(vga));
    const unsigned long long muralla_pre_dialog = fnv1a64(vga, sizeof(vga));
    const unsigned long long muralla_pre_npc =
        frame_rect_hash(vga, 72, 112, 40, 36);
    ok &= zeliard_town_dialog_begin_live(
        &town.dialog, segments[0], segments[3],
        segments[1], sizeof(segments[1]),
        segments[2], sizeof(segments[2]), vga, sizeof(vga),
        muralla_talk_position) == 0;
    const unsigned long long muralla_dialog_frame = fnv1a64(vga, sizeof(vga));
    const unsigned long long muralla_talking_npc =
        frame_rect_hash(vga, 72, 112, 40, 36);
    const u16 muralla_first_page_glyphs = town.dialog.glyph_count;
    const u8 muralla_talking_direction =
        segments[0][(u16)(muralla_talk_npc + 2)];
    const u8 muralla_talking_type = segments[0][(u16)(muralla_talk_npc + 5)];
    unsigned muralla_dialog_pages = 0;
    while (town.dialog.active && muralla_dialog_pages++ < 8) {
        segments[0][0xFF1D] = 0xFF;
        ok &= zeliard_town_dialog_continue(
            &town.dialog, segments[0], segments[3], vga, sizeof(vga)) >= 0;
    }
    const u16 muralla_dialog_glyphs = town.dialog.glyph_count;
    const u8 muralla_restored_direction =
        segments[0][(u16)(muralla_talk_npc + 2)];
    const u8 muralla_restored_type = segments[0][(u16)(muralla_talk_npc + 5)];
    const unsigned long long muralla_dialog_restored = fnv1a64(vga, sizeof(vga));
    u16 dialog_min_x = 320, dialog_min_y = 200, dialog_max_x = 0, dialog_max_y = 0;
    if (muralla_snapshot) {
        const u8 *before_dialog = muralla_snapshot + sizeof(segments);
        for (u16 y = 0; y < 200; ++y) for (u16 x = 0; x < 320; ++x) {
            const size_t at = (size_t)y * 320u + x;
            if (vga[at] == before_dialog[at]) continue;
            if (x < dialog_min_x) dialog_min_x = x;
            if (x > dialog_max_x) dialog_max_x = x;
            if (y < dialog_min_y) dialog_min_y = y;
            if (y > dialog_max_y) dialog_max_y = y;
        }
    }
    ok &= muralla_talk_position == 0x0009 && muralla_dialog_id == 0;
    ok &= muralla_dialog_glyphs > 0 && muralla_dialog_pages > 0;
    ok &= muralla_talking_type == 7;
    ok &= muralla_talking_direction ==
          ((segments[0][0x00C2] & 1) ?
              (u8)(muralla_npc_direction & 0x7F) :
              (u8)(muralla_npc_direction | 0x80));
    ok &= muralla_restored_direction == muralla_npc_direction;
    ok &= muralla_restored_type == muralla_npc_type;
    ok &= muralla_talking_npc != muralla_pre_npc;
    printf("town_muralla_dialog: npc=%04x id=%u pages=%u glyphs=%u/%u "
           "facing=%02x>%02x>%02x type=%u>%u>%u pre=%016llx "
           "frame=%016llx restored=%016llx npc=%016llx>%016llx "
           "diff=%u,%u-%u,%u\n",
           muralla_talk_position, muralla_dialog_id, muralla_dialog_pages,
           muralla_first_page_glyphs, muralla_dialog_glyphs,
           muralla_npc_direction, muralla_talking_direction,
           muralla_restored_direction, muralla_npc_type, muralla_talking_type,
           muralla_restored_type, muralla_pre_dialog,
           muralla_dialog_frame, muralla_dialog_restored,
           muralla_pre_npc, muralla_talking_npc,
           dialog_min_x, dialog_min_y, dialog_max_x, dialog_max_y);
    if (muralla_dialog_base) {
        free(muralla_dialog_base);
    }
    segments[0][0x0083] = muralla_saved_player_col;
    if (muralla_snapshot)
        memcpy(vga, muralla_snapshot + sizeof(segments), sizeof(vga));
    segments[0][ZEL_PLAYER_SHIELD] = 1;
    segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    segments[0][ZEL_PLAYER_SHIELD_HP + 1] = 0;
    segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    segments[0][ZEL_PLAYER_SHIELD_HP_MAX + 1] = 0;
    ok &= zeliard_town_begin_room_transition(
        &town, ZEL_ROOM_ARMORY, vga, sizeof(vga)) == 0;
    const int armory_enter_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 88, 0);
    unsigned armory_ticks = 0;
    while (town.room.active && !zeliard_room_masm_vm_at_input_poll() &&
           armory_ticks++ < 2000)
        ok &= zeliard_town_advance_pit(
            &town, &game, vga, sizeof(vga), 1, 0) >= 0;
    ok &= town.room.active && town.room.exact_vm_active;
    ok &= zeliard_room_masm_vm_at_input_poll();
    segments[0][0xFF1D] = 0xFF;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 1, 0) >= 0;
    segments[0][0xFF1D] = 0;
    ok &= zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 1, 0) >= 0;
    while (town.building_transition != ZEL_TOWN_BUILDING_TRANSITION_LEAVE &&
           armory_ticks++ < 4000) {
        if (zeliard_room_masm_vm_at_input_poll()) {
            segments[0][0xFF1D] = 0xFF;
            ok &= zeliard_town_advance_pit(
                &town, &game, vga, sizeof(vga), 1, 0) >= 0;
            segments[0][0xFF1D] = 0;
        }
        ok &= zeliard_town_advance_pit(
            &town, &game, vga, sizeof(vga), 1, 0) >= 0;
    }
    const int armory_leave_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 88, 0);
    const unsigned long long armory_return_playfield =
        fnv1a64(vga, 160u * 320u);
    const unsigned long long armory_return_shield =
        frame_rect_hash(vga, 246, 164, 24, 32);
    const unsigned long long armory_return_shield_icon =
        frame_rect_hash(vga, 250, 164, 16, 16);
    const unsigned long long armory_return_shield_field =
        frame_rect_hash(vga, 246, 186, 24, 10);
    const u16 armory_shield_base = (u16)(segments[1][0xE202] |
        ((u16)segments[1][0xE203] << 8));
    const unsigned long long armory_shield_source = fnv1a64(
        segments[1] + armory_shield_base, 0xC0);
    ok &= armory_enter_frames == 8 && armory_leave_frames == 8;
    ok &= !town.room.active &&
          town.building_transition == ZEL_TOWN_BUILDING_TRANSITION_NONE;
    ok &= armory_return_playfield == 0x2DF9ABEBE695245FULL;
    ok &= armory_return_shield == 0xD5E97AC5633D8B37ULL &&
          armory_return_shield_icon == 0x18FDBA10EBC3FCC6ULL &&
          armory_return_shield_field == 0x741B4FFF4B27D4F0ULL &&
          armory_shield_source == pristine_shield_source;
    printf("town_muralla_armory_round_trip: ticks=%u enter=%d leave=%d "
           "playfield=%016llx shield=%016llx icon=%016llx field=%016llx "
           "base=%04x source=%016llx\n",
           armory_ticks,
           armory_enter_frames, armory_leave_frames,
           armory_return_playfield, armory_return_shield,
           armory_return_shield_icon, armory_return_shield_field,
           armory_shield_base, armory_shield_source);
    segments[0][0x0080] = 0xB9;
    segments[0][0x0081] = 0;
    segments[0][0x0083] = 0x10;
    segments[0][0xFF2A] = 0xDF;
    segments[0][0xFF2B] = 0xC5;
    const int cavern_exit_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 1);
    const int cavern_requested = town.cavern_exit_requested;
    const u16 cavern_start = (u16)(segments[0][0x0080] |
                                   ((u16)segments[0][0x0081] << 8));
    const u8 cavern_row = segments[0][0x0082];
    const u8 cavern_boss = segments[0][0x00C3];
    const u8 cavern_area = segments[0][0x00C4];
    ok &= cavern_exit_frames == 1 && cavern_requested;
    ok &= cavern_start == 0x2D;
    ok &= cavern_row == 0x3D;
    ok &= cavern_boss == 0 && cavern_area == 0;
    if (muralla_snapshot) {
        memcpy(segments, muralla_snapshot, sizeof(segments));
        memcpy(vga, muralla_snapshot + sizeof(segments), sizeof(vga));
        town = muralla_town_snapshot;
        free(muralla_snapshot);
    }
    segments[0][0x0083] = 0xFF;
    const int castle_return_frames = zeliard_town_advance_pit(
        &town, &game, vga, sizeof(vga), 20, 0);
    const unsigned long long castle_return_playfield =
        fnv1a64(vga, 160u * 320u);
    const unsigned long long return_cpat_pixels =
        fnv1a64(segments[1] + 0x8100, 0x2EE0);
    const unsigned long long return_cpat_alpha =
        fnv1a64(segments[1] + 0xD000, 0x07D0);
    ok &= castle_return_frames == 1;
    ok &= town.area == ZEL_TOWN_AREA_FELISHIKA;
    ok &= segments[0][0x00C4] == 0x80;
    ok &= segments[0][0x0080] == 0x4E && segments[0][0x0081] == 0;
    ok &= segments[0][0x0083] == 0x1A;
    ok &= segments[0][0xC002] == 0x72 && segments[0][0xC003] == 0;
    ok &= castle_return_playfield == 0x254DCDB105A9AE44ULL;
    ok &= return_cpat_pixels == 0x3E695EED8F9A92ECULL;
    ok &= return_cpat_alpha == 0x2AE75F00707E7659ULL;

    /* Ticket #79: execute the same C service span from the independently
     * pinned release-MASM Satono fixture.  Satono is the first descriptor
     * that switches all three authored selectors at once: UGM1, CMAN, DPAT. */
    static u8 satono_segments[ZELIARD_GAME_SEGMENT_COUNT]
                              [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 satono_vga[0x10000];
    zeliard_game_exec_state_t satono_game = {0};
    zeliard_town_runtime_t *satono = calloc(1, sizeof(*satono));
    ok &= satono != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        satono_game.segment[i] = satono_segments[i];
        satono_game.segment_size[i] = sizeof(satono_segments[i]);
    }
    ok &= load_direct(satono_segments[0], sizeof(satono_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(satono_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(satono_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(satono_segments[3], sizeof(satono_segments[3]),
                   "assets/mole.bin") &&
          load_font(satono_segments[0]) && load_item_panel(satono_segments[1]);
    satono_segments[0][0x00C4] = 0x82;
    satono_segments[0][0x00C5] = 0x82;
    satono_segments[0][0x0080] = 0x4B;
    satono_segments[0][0x0081] = 0;
    satono_segments[0][0x0082] = 0;
    satono_segments[0][0x0083] = 0x0D;
    satono_segments[0][ZEL_PLAYER_SWORD] = 1;
    satono_segments[0][ZEL_PLAYER_SHIELD] = 1;
    satono_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    satono_segments[0][ZEL_PLAYER_SHIELD_HP + 1] = 0;
    satono_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    satono_segments[0][ZEL_PLAYER_SHIELD_HP_MAX + 1] = 0;
    const int satono_result = satono ? zeliard_town_enter_first_frame(
        satono, &satono_game, satono_vga, sizeof(satono_vga)) : -99;
    const unsigned long long satono_frame =
        fnv1a64(satono_vga, sizeof(satono_vga));
    const unsigned long long satono_playfield =
        fnv1a64(satono_vga, 160u * 320u);
    const unsigned long long satono_capture =
        fnv1a64(satono_segments[0] + 0xA000, 0x1500);
    const unsigned long long satono_state =
        selected_state_hash(satono_segments[0]);
    const unsigned long long satono_npcs =
        npc_state_hash(satono_segments[0]);
    const unsigned long long satono_dpat_pixels =
        fnv1a64(satono_segments[1] + 0x8100, 0x2EE0);
    const unsigned long long satono_dpat_alpha =
        fnv1a64(satono_segments[1] + 0xD000, 0x07D0);
    const unsigned long long satono_cman_pixels =
        fnv1a64(satono_segments[1] + 0x4100, 0x1EC0);
    const unsigned long long satono_cman_masks =
        fnv1a64(satono_segments[2] + 0x7000, 0x0520);
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-satono-c-frame.bin", "wb");
        if (dump) {
            fwrite(satono_vga, 1, sizeof(satono_vga), dump);
            fclose(dump);
        }
    }
    ok &= satono_result == 0 && satono->area == ZEL_TOWN_AREA_SATONO;
    ok &= satono->music_index == 1 && satono->map_side == 1 &&
          satono->palette_index == 2 && satono->town_text_record == 0xC6D8;
    ok &= satono_frame == 0xA017DD4B4A88F9B8ULL &&
          satono_playfield == 0x44CA66C7D16E925AULL &&
          satono_capture == 0xAB3088CF79795EEDULL &&
          satono_state == 0xA44A7ECC9A5C610DULL &&
          satono_npcs == 0x49A89CB0912C308FULL;
    ok &= satono_dpat_pixels == 0x3F819F76329F575EULL &&
          satono_dpat_alpha == 0x597550E40F08BCB6ULL &&
          satono_cman_pixels == 0x44D254E063EEEC7DULL &&
          satono_cman_masks == 0x4F2D17A7A7837D5FULL;

    static u8 satono_snapshot[sizeof(satono_segments) + sizeof(satono_vga)];
    memcpy(satono_snapshot, satono_segments, sizeof(satono_segments));
    memcpy(satono_snapshot + sizeof(satono_segments), satono_vga,
           sizeof(satono_vga));
    const zeliard_town_runtime_t satono_runtime_snapshot = *satono;

    /* 106TOWN:portal_check selects the opposite five-step entry routine
     * when facing_direction bit 0 is set. Starting at 004Bh/0Dh, three
     * column steps and two scroll steps end at 0049h/0Ah. */
    satono_segments[0][ZEL_PLAYER_START_POSITION] = 0x4B;
    satono_segments[0][ZEL_PLAYER_START_POSITION + 1] = 0;
    satono_segments[0][ZEL_PLAYER_SCREEN_POSITION] = 0x0D;
    satono_segments[0][ZEL_PLAYER_FACING_DIRECTION] = 1;
    const int satono_left_entry = zeliard_town_enter_first_frame(
        satono, &satono_game, satono_vga, sizeof(satono_vga));
    printf("town_satono_left_entry: rc=%d start=%02x%02x col=%02x\n",
           satono_left_entry,
           satono_segments[0][ZEL_PLAYER_START_POSITION + 1],
           satono_segments[0][ZEL_PLAYER_START_POSITION],
           satono_segments[0][ZEL_PLAYER_SCREEN_POSITION]);
    ok &= satono_left_entry == 0 &&
          satono_segments[0][ZEL_PLAYER_START_POSITION] == 0x49 &&
          satono_segments[0][ZEL_PLAYER_START_POSITION + 1] == 0 &&
          satono_segments[0][ZEL_PLAYER_SCREEN_POSITION] == 0x0A;
    memcpy(satono_segments, satono_snapshot, sizeof(satono_segments));
    memcpy(satono_vga, satono_snapshot + sizeof(satono_segments),
           sizeof(satono_vga));
    *satono = satono_runtime_snapshot;

    /* The same 106TOWN live pump is used by every town while an NPC speaks.
     * Satono's flame tiles intersect the right-hand dialog panel, making it
     * the release fixture for the required foreground compositing order. */
    const u16 satono_npc_list = (u16)(satono_segments[0][0xC00F] |
        ((u16)satono_segments[0][0xC010] << 8));
    const u16 satono_talk_position = (u16)(
        satono_segments[0][satono_npc_list] |
        ((u16)satono_segments[0][(u16)(satono_npc_list + 1)] << 8));
    const int satono_dialog_begin = zeliard_town_dialog_begin_live(
        &satono->dialog, satono_segments[0], satono_segments[3],
        satono_segments[1], sizeof(satono_segments[1]),
        satono_segments[2], sizeof(satono_segments[2]),
        satono_vga, sizeof(satono_vga), satono_talk_position);
    const u16 satono_panel_x = (u16)(satono->dialog.panel_ax >> 8) * 8u;
    const u16 satono_panel_y = (u8)satono->dialog.panel_ax;
    const u16 satono_panel_width =
        (u16)(satono->dialog.panel_cx >> 8) * 8u;
    const u16 satono_panel_height = (u8)satono->dialog.panel_cx;
    const unsigned long long satono_dialog_panel_before = frame_rect_hash(
        satono_vga, satono_panel_x, satono_panel_y,
        satono_panel_width, satono_panel_height);
    const unsigned long long satono_dialog_frame_before =
        fnv1a64(satono_vga, sizeof(satono_vga));
    satono_segments[0][0xFF33] = 5;
    int satono_dialog_frames = 0;
    int satono_dialog_panel_stable = 1;
    int satono_dialog_background_changed = 0;
    for (unsigned frame = 0; frame < 16; ++frame) {
        const int advanced = zeliard_town_advance_pit(
            satono, &satono_game, satono_vga, sizeof(satono_vga), 20, 0);
        if (advanced < 0) {
            satono_dialog_panel_stable = 0;
            break;
        }
        satono_dialog_frames += advanced;
        satono_dialog_panel_stable &= frame_rect_hash(
            satono_vga, satono_panel_x, satono_panel_y,
            satono_panel_width, satono_panel_height) ==
            satono_dialog_panel_before;
        satono_dialog_background_changed |=
            fnv1a64(satono_vga, sizeof(satono_vga)) !=
            satono_dialog_frame_before;
    }
    const unsigned long long satono_dialog_panel_after = frame_rect_hash(
        satono_vga, satono_panel_x, satono_panel_y,
        satono_panel_width, satono_panel_height);
    const unsigned long long satono_dialog_frame_after =
        fnv1a64(satono_vga, sizeof(satono_vga));
    printf("town_satono_dialog_overlay: begin=%d frames=%d active=%d "
           "panel=%016llx/%016llx frame=%016llx/%016llx\n",
           satono_dialog_begin, satono_dialog_frames,
           satono->dialog.active, satono_dialog_panel_before,
           satono_dialog_panel_after, satono_dialog_frame_before,
           satono_dialog_frame_after);
    ok &= satono_dialog_begin == 0 && satono_dialog_frames == 16 &&
          satono->dialog.active &&
          satono_dialog_panel_stable &&
          satono_dialog_panel_after == satono_dialog_panel_before &&
          satono_dialog_background_changed;

    memcpy(satono_segments, satono_snapshot, sizeof(satono_segments));
    memcpy(satono_vga, satono_snapshot + sizeof(satono_segments),
           sizeof(satono_vga));
    *satono = satono_runtime_snapshot;

    satono_segments[0][0x0083] = 0xFF;
    const int satono_left_frames = zeliard_town_advance_pit(
        satono, &satono_game, satono_vga, sizeof(satono_vga), 20, 0);
    ok &= satono_left_frames > 0 && satono->cavern_exit_requested;
    ok &= satono_segments[0][0x0080] == 0x70 &&
          satono_segments[0][0x0081] == 0 &&
          satono_segments[0][0x0082] == 0x17 &&
          satono_segments[0][0x00C3] == 0xFF &&
          satono_segments[0][0x00C4] == 0;

    memcpy(satono_segments, satono_snapshot, sizeof(satono_segments));
    memcpy(satono_vga, satono_snapshot + sizeof(satono_segments),
           sizeof(satono_vga));
    *satono = satono_runtime_snapshot;
    satono_segments[0][0x0083] = 0x1C;
    const int satono_right_frames = zeliard_town_advance_pit(
        satono, &satono_game, satono_vga, sizeof(satono_vga), 20, 0);
    ok &= satono_right_frames > 0 && satono->cavern_exit_requested;
    ok &= satono_segments[0][0x0080] == 0xD6 &&
          satono_segments[0][0x0081] == 0x00 &&
          satono_segments[0][0x0082] == 0x34 &&
          satono_segments[0][0x00C3] == 0 &&
          satono_segments[0][0x00C4] == 2;

    memcpy(satono_segments, satono_snapshot, sizeof(satono_segments));
    memcpy(satono_vga, satono_snapshot + sizeof(satono_segments),
           sizeof(satono_vga));
    *satono = satono_runtime_snapshot;
    satono_segments[0][0x0080] = 0x6F;
    satono_segments[0][0x0081] = 0;
    satono_segments[0][0x0083] = 0x0D;
    satono_segments[0][0xFF2A] = 0x8F;
    satono_segments[0][0xFF2B] = 0xC3;
    const int satono_inn_trigger = zeliard_town_advance_pit(
        satono, &satono_game, satono_vga, sizeof(satono_vga), 20, 1);
    const int satono_inn_fade = zeliard_town_advance_pit(
        satono, &satono_game, satono_vga, sizeof(satono_vga), 88, 0);
    ok &= satono_inn_trigger > 0 && satono_inn_fade > 0;
    ok &= satono->room.active && satono->room.kind == ZEL_ROOM_INN &&
          satono->room.exact_vm_active && zeliard_room_masm_vm_active();
    printf("town_satono_entry: rc=%d frame=%016llx playfield=%016llx "
           "state=%016llx npc=%016llx dpat=%016llx/%016llx "
           "cman=%016llx/%016llx music=%u\n",
           satono_result, satono_frame, satono_playfield, satono_state,
           satono_npcs, satono_dpat_pixels, satono_dpat_alpha,
           satono_cman_pixels, satono_cman_masks,
           (unsigned)satono->music_index);
    printf("town_satono_routes: left=%d/%02x%02x/%02x/%02x/%02x "
           "right=%d/%02x%02x/%02x/%02x/%02x inn=%d/%d/%d\n",
           satono_left_frames, 0x00, 0x70, 0x17, 0xFF, 0x00,
           satono_right_frames, 0xFF, 0xF6, 0x34, 0x00, 0x02,
           satono_inn_trigger, satono_inn_fade,
           satono->room.kind);
    zeliard_room_masm_vm_stop();
    free(satono);

    /* Ticket #80: Bosque's stable first frame uses the release BSMP/MPAT/
     * MMAN selector set.  The position is the exact 200FIGHT handoff from
     * Riza: target 3Ch becomes start 2Bh, screen column 0Dh. */
    static u8 bosque_segments[ZELIARD_GAME_SEGMENT_COUNT]
                              [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 bosque_vga[0x10000];
    zeliard_game_exec_state_t bosque_game = {0};
    zeliard_town_runtime_t *bosque = calloc(1, sizeof(*bosque));
    ok &= bosque != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        bosque_game.segment[i] = bosque_segments[i];
        bosque_game.segment_size[i] = sizeof(bosque_segments[i]);
    }
    ok &= load_direct(bosque_segments[0], sizeof(bosque_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(bosque_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(bosque_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(bosque_segments[3], sizeof(bosque_segments[3]),
                   "assets/mole.bin") &&
          load_font(bosque_segments[0]) && load_item_panel(bosque_segments[1]);
    bosque_segments[0][0x00C4] = 0x83;
    bosque_segments[0][0x00C5] = 0x83;
    bosque_segments[0][0x0080] = 0x2B;
    bosque_segments[0][0x0081] = 0;
    bosque_segments[0][0x0082] = 0;
    bosque_segments[0][0x0083] = 0x0D;
    bosque_segments[0][ZEL_PLAYER_SWORD] = 1;
    bosque_segments[0][ZEL_PLAYER_SHIELD] = 1;
    bosque_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    bosque_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int bosque_result = bosque ? zeliard_town_enter_first_frame(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga)) : -99;
    const unsigned long long bosque_frame =
        fnv1a64(bosque_vga, sizeof(bosque_vga));
    const unsigned long long bosque_playfield =
        fnv1a64(bosque_vga, 160u * 320u);
    const unsigned long long bosque_capture =
        fnv1a64(bosque_segments[0] + 0xA000, 0x1500);
    const unsigned long long bosque_state =
        selected_state_hash(bosque_segments[0]);
    const unsigned long long bosque_npcs =
        npc_state_hash(bosque_segments[0]);
    const unsigned long long bosque_mpat_pixels =
        fnv1a64(bosque_segments[1] + 0x8100, 0x2EE0);
    const unsigned long long bosque_mpat_alpha =
        fnv1a64(bosque_segments[1] + 0xD000, 0x07D0);
    const unsigned long long bosque_mman_pixels =
        fnv1a64(bosque_segments[1] + 0x4100, 0x1EC0);
    const unsigned long long bosque_mman_masks =
        fnv1a64(bosque_segments[2] + 0x7000, 0x0520);
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-bosque-c-frame.bin", "wb");
        if (dump) {
            fwrite(bosque_vga, 1, sizeof(bosque_vga), dump);
            fclose(dump);
        }
    }
    ok &= bosque_result == 0 && bosque->area == ZEL_TOWN_AREA_BOSQUE;
    ok &= bosque->music_index == 2 && bosque->map_side == 0 &&
          bosque->palette_index == 1 && bosque->town_text_record == 0xC4E0;
    ok &= bosque_frame == 0x653EE54A0E8B4721ULL &&
          bosque_playfield == 0xAAA634D89DBA5AA5ULL &&
          bosque_capture == 0xF2C3F82A0F93D06DULL &&
          bosque_state == 0x8F27932A06F807C8ULL &&
          bosque_npcs == 0x8D764A90CC39987EULL;
    ok &= bosque_mpat_pixels == 0x057549E40BE35E14ULL &&
          bosque_mpat_alpha == 0x68EDAA05B46B4C6EULL &&
          bosque_mman_pixels == 0xC287EABFFE898D6CULL &&
          bosque_mman_masks == 0xF205BFB757BBDA0CULL;
    ok &= bosque_segments[0][0xCCFA] == 0xC0 &&
          bosque_segments[0][0xCCFB] == 0x0B;

    static u8 bosque_snapshot[sizeof(bosque_segments) + sizeof(bosque_vga)];
    memcpy(bosque_snapshot, bosque_segments, sizeof(bosque_segments));
    memcpy(bosque_snapshot + sizeof(bosque_segments), bosque_vga,
           sizeof(bosque_vga));
    const zeliard_town_runtime_t bosque_runtime_snapshot = *bosque;

    /* Door type 9 is route record 1 (Pollo); door type 8 is record 0
     * (Riza). request_cavern_exit applies the MASM -10h/-0Ah transforms. */
    bosque_segments[0][0x0080] = 0;
    bosque_segments[0][0x0081] = 0;
    bosque_segments[0][0x0083] = 3;
    bosque_segments[0][0xFF2A] = 0x17;
    bosque_segments[0][0xFF2B] = 0xC0;
    const int bosque_pollo = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 20, 1);
    ok &= bosque_pollo > 0 && bosque->cavern_exit_requested &&
          bosque_segments[0][0x0080] == 0x85 &&
          bosque_segments[0][0x0081] == 0 &&
          bosque_segments[0][0x0082] == 4 &&
          bosque_segments[0][0x00C3] == 0xFF &&
          bosque_segments[0][0x00C4] == 6;

    memcpy(bosque_segments, bosque_snapshot, sizeof(bosque_segments));
    memcpy(bosque_vga, bosque_snapshot + sizeof(bosque_segments),
           sizeof(bosque_vga));
    *bosque = bosque_runtime_snapshot;
    bosque_segments[0][0x0080] = 125;
    bosque_segments[0][0x0081] = 0;
    bosque_segments[0][0x0083] = 13;
    const u16 bosque_riza_tile = (u16)(0xC017 + 125 * 8);
    bosque_segments[0][0xFF2A] = (u8)bosque_riza_tile;
    bosque_segments[0][0xFF2B] = (u8)(bosque_riza_tile >> 8);
    const int bosque_riza = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 20, 1);
    ok &= bosque_riza > 0 && bosque->cavern_exit_requested &&
          bosque_segments[0][0x0080] == 0xA9 &&
          bosque_segments[0][0x0081] == 0 &&
          bosque_segments[0][0x0082] == 9 &&
          bosque_segments[0][0x00C3] == 0 &&
          bosque_segments[0][0x00C4] == 5;

    memcpy(bosque_segments, bosque_snapshot, sizeof(bosque_segments));
    memcpy(bosque_vga, bosque_snapshot + sizeof(bosque_segments),
           sizeof(bosque_vga));
    *bosque = bosque_runtime_snapshot;

    /* BSMP gates the sentry on cavern object-state bit 0012h/08h.  The
     * similarly named player byte at 009Ch is not this town gate. Without
     * the cavern bit, the sentry remains C0h/0Bh: one prompt, Left blocked,
     * and Right retreats after dismissing the response. */
    bosque_segments[0][0x0012] &= (u8)~0x08;
    bosque_segments[0][0x009C] = 0xFF;
    const int bosque_no_crest_result = zeliard_town_enter_first_frame(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga));
    const int bosque_no_crest_actor =
        bosque_segments[0][0xCCFA] == 0xC0 &&
        bosque_segments[0][0xCCFB] == 0x0B;
    bosque_segments[0][0x0080] = 0;
    bosque_segments[0][0x0081] = 0;
    bosque_segments[0][0x0083] = 7;
    bosque_segments[0][0x00C2] = 1;
    bosque_segments[0][0xFF2A] = 0x17;
    bosque_segments[0][0xFF2B] = 0xC0;
    const int bosque_guard_no_crest_begin = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_no_crest_world = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    const int bosque_guard_no_crest_held = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const int bosque_guard_no_crest_prompt =
        bosque->dialog.active && bosque->dialog.prompt_active &&
        bosque->dialog.prompt_selection == 0;
    const int bosque_guard_no_crest_select_no = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 2);
    const int bosque_guard_no_crest_arrow = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 40, 0);
    const int bosque_guard_no_crest_no_selected =
        bosque->dialog.prompt_active && bosque->dialog.prompt_selection == 1;
    bosque_segments[0][0xFF1D] = 0xFF;
    const int bosque_guard_no_crest_confirm = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 0);
    const int bosque_guard_no_crest_no_response =
        bosque->dialog.active && !bosque->dialog.prompt_active &&
        bosque->dialog.final_wait &&
        (u16)(bosque_segments[0][0x7C58] |
              ((u16)bosque_segments[0][0x7C59] << 8)) == 0xCCB5;
    const int bosque_guard_no_crest_left_open = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const int bosque_guard_no_crest_right_open = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 8);
    const int bosque_guard_no_crest_directions_blocked =
        bosque->dialog.active;
    bosque_segments[0][0xFF1D] = 0xFF;
    const int bosque_guard_no_crest_release = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 0);
    const int bosque_guard_no_crest_left = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_no_crest_blocked = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    const int bosque_guard_no_crest_right = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 8);
    const u16 bosque_guard_no_crest_retreat = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    const int bosque_guard_no_crest_return = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const int bosque_guard_no_crest_retry = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_no_crest_retry_world = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    ok &= bosque_no_crest_result == 0 &&
          bosque_no_crest_actor &&
          bosque_guard_no_crest_begin > 0 &&
          bosque_guard_no_crest_held > 0 &&
          bosque_guard_no_crest_prompt &&
          bosque_guard_no_crest_select_no > 0 &&
          bosque_guard_no_crest_arrow > 0 &&
          bosque_guard_no_crest_no_selected &&
          bosque_guard_no_crest_confirm > 0 &&
          bosque_guard_no_crest_no_response &&
          bosque_guard_no_crest_left_open > 0 &&
          bosque_guard_no_crest_right_open > 0 &&
          bosque_guard_no_crest_directions_blocked &&
          bosque_guard_no_crest_release > 0 &&
          bosque_guard_no_crest_left > 0 &&
          bosque_guard_no_crest_right > 0 &&
          bosque_guard_no_crest_return > 0 &&
          bosque_guard_no_crest_retry > 0 &&
          bosque_guard_no_crest_world == 10 &&
          bosque->dialog.active == 0 &&
          bosque_segments[0][0xCCFA] == 0x40 &&
          bosque_segments[0][0xCCFB] == 0x0B &&
          bosque_guard_no_crest_blocked == bosque_guard_no_crest_world &&
          bosque_guard_no_crest_retreat == bosque_guard_no_crest_world + 1 &&
          bosque_guard_no_crest_retry_world == bosque_guard_no_crest_world;
    printf("town_bosque_guard_no_crest: actor=%d begin=%d held=%d "
           "prompt=%d select=%d arrow=%d selected=%d confirm=%d "
           "response=%d horizontal=%d/%d/%d close=%d\n",
           bosque_no_crest_actor, bosque_guard_no_crest_begin,
           bosque_guard_no_crest_held, bosque_guard_no_crest_prompt,
           bosque_guard_no_crest_select_no, bosque_guard_no_crest_arrow,
           bosque_guard_no_crest_no_selected,
           bosque_guard_no_crest_confirm,
           bosque_guard_no_crest_no_response,
           bosque_guard_no_crest_left_open,
           bosque_guard_no_crest_right_open,
           bosque_guard_no_crest_directions_blocked,
           bosque_guard_no_crest_release);

    memcpy(bosque_segments, bosque_snapshot, sizeof(bosque_segments));
    memcpy(bosque_vga, bosque_snapshot + sizeof(bosque_segments),
           sizeof(bosque_vga));
    *bosque = bosque_runtime_snapshot;

    /* With cavern bit 0012h/08h set, process_town_event_table changes the
     * same actor to 80h/0Eh: dialog 14, passable, still only one trigger. */
    bosque_segments[0][0x0012] |= 0x08;
    bosque_segments[0][0x009C] = 0;
    const int bosque_crest_result = zeliard_town_enter_first_frame(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga));
    ok &= bosque_crest_result == 0 &&
          bosque_segments[0][0xCCFA] == 0x80 &&
          bosque_segments[0][0xCCFB] == 0x0E;
    bosque_segments[0][0x0080] = 0;
    bosque_segments[0][0x0081] = 0;
    bosque_segments[0][0x0083] = 7;
    bosque_segments[0][0x00C2] = 1;
    bosque_segments[0][0xFF2A] = 0x17;
    bosque_segments[0][0xFF2B] = 0xC0;
    const int bosque_guard_crest_begin = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_crest_world = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    const int bosque_guard_crest_held = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const int bosque_guard_crest_release = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 0);
    const int bosque_guard_crest_left = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_crest_passed = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    const int bosque_guard_crest_return = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 8);
    const int bosque_guard_crest_retry = zeliard_town_advance_pit(
        bosque, &bosque_game, bosque_vga, sizeof(bosque_vga), 1, 4);
    const u16 bosque_guard_crest_retry_world = (u16)(
        bosque_segments[0][0x0080] + bosque_segments[0][0x0083] + 4u);
    ok &= bosque_guard_crest_begin > 0 && bosque_guard_crest_held > 0 &&
          bosque_guard_crest_release > 0 && bosque_guard_crest_left > 0 &&
          bosque_guard_crest_return > 0 && bosque_guard_crest_retry > 0 &&
          bosque_guard_crest_world == 10 && !bosque->dialog.active &&
          bosque_guard_crest_passed == bosque_guard_crest_world - 1 &&
          bosque_guard_crest_retry_world == bosque_guard_crest_passed;
    printf("town_bosque_entry: rc=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx mpat=%016llx/%016llx "
           "mman=%016llx/%016llx music=%u sentry=%02x/%02x\n",
           bosque_result, bosque_frame, bosque_playfield, bosque_capture,
           bosque_state, bosque_npcs, bosque_mpat_pixels, bosque_mpat_alpha,
           bosque_mman_pixels, bosque_mman_masks,
           (unsigned)bosque->music_index, bosque_segments[0][0xCCFA],
           bosque_segments[0][0xCCFB]);
    printf("town_bosque_routes: pollo=%d/0085/04/ff/06 "
           "riza=%d/00a9/09/00/05 crest=%d/%02x/%02x "
           "guard_no_crest=%u>%u>%u>%u "
           "guard_crest=%u>%u>%u\n",
           bosque_pollo, bosque_riza, bosque_crest_result,
           bosque_segments[0][0xCCFA], bosque_segments[0][0xCCFB],
           bosque_guard_no_crest_world, bosque_guard_no_crest_blocked,
           bosque_guard_no_crest_retreat,
           bosque_guard_no_crest_retry_world,
           bosque_guard_crest_world, bosque_guard_crest_passed,
           bosque_guard_crest_retry_world);
    free(bosque);

    /* Ticket #81: Helada's release HLMP descriptor selects UGM1, DPAT,
     * CMAN, and the 200FIGHT handoff target 2Ch -> start 1Bh/column 0Dh. */
    static u8 helada_segments[ZELIARD_GAME_SEGMENT_COUNT]
                              [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 helada_vga[0x10000];
    zeliard_game_exec_state_t helada_game = {0};
    zeliard_town_runtime_t *helada = calloc(1, sizeof(*helada));
    ok &= helada != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        helada_game.segment[i] = helada_segments[i];
        helada_game.segment_size[i] = sizeof(helada_segments[i]);
    }
    ok &= load_direct(helada_segments[0], sizeof(helada_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(helada_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(helada_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(helada_segments[3], sizeof(helada_segments[3]),
                   "assets/mole.bin") &&
          load_font(helada_segments[0]) && load_item_panel(helada_segments[1]);
    helada_segments[0][0x00C4] = 0x84;
    helada_segments[0][0x00C5] = 0x84;
    helada_segments[0][0x0080] = 0x1B;
    helada_segments[0][0x0083] = 0x0D;
    helada_segments[0][ZEL_PLAYER_SWORD] = 1;
    helada_segments[0][ZEL_PLAYER_SHIELD] = 1;
    helada_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    helada_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int helada_result = helada ? zeliard_town_enter_first_frame(
        helada, &helada_game, helada_vga, sizeof(helada_vga)) : -99;
    const unsigned long long helada_frame =
        fnv1a64(helada_vga, sizeof(helada_vga));
    const unsigned long long helada_playfield =
        fnv1a64(helada_vga, 160u * 320u);
    const unsigned long long helada_capture =
        fnv1a64(helada_segments[0] + 0xA000, 0x1500);
    const unsigned long long helada_state =
        selected_state_hash(helada_segments[0]);
    const unsigned long long helada_npcs =
        npc_state_hash(helada_segments[0]);
    const u8 helada_story_before[4] = {
        helada_segments[0][0xCDD4], helada_segments[0][0xCDD5],
        helada_segments[0][0xCDDD], helada_segments[0][0xCDED],
    };
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-helada-c-frame.bin", "wb");
        if (dump) {
            fwrite(helada_vga, 1, sizeof(helada_vga), dump);
            fclose(dump);
        }
    }
    ok &= helada_result == 0 && helada->area == ZEL_TOWN_AREA_HELADA;
    ok &= helada->music_index == 1 && helada->map_side == 1 &&
          helada->palette_index == 2 && helada->town_text_record == 0xC738;
    ok &= helada_frame == 0xC1E9F964D6BC4E9EULL &&
          helada_playfield == 0x3E652144F91393CBULL &&
          helada_capture == 0xAB3088CF79795EEDULL &&
          helada_state == 0xA2987CCC98EC7C27ULL &&
          helada_npcs == 0x3BFEA3AEA757B08EULL;
    ok &= helada_story_before[0] == 0x80 &&
          helada_story_before[1] == 3 &&
          helada_story_before[2] == 2 &&
          helada_story_before[3] == 6;

    static u8 helada_snapshot[sizeof(helada_segments) + sizeof(helada_vga)];
    memcpy(helada_snapshot, helada_segments, sizeof(helada_segments));
    memcpy(helada_snapshot + sizeof(helada_segments), helada_vga,
           sizeof(helada_vga));
    const zeliard_town_runtime_t helada_runtime_snapshot = *helada;

    helada_segments[0][0x0083] = 0xFF;
    const int helada_left = zeliard_town_advance_pit(
        helada, &helada_game, helada_vga, sizeof(helada_vga), 20, 0);
    ok &= helada_left > 0 && helada->cavern_exit_requested &&
          helada_segments[0][0x0080] == 0x46 &&
          helada_segments[0][0x0081] == 0 &&
          helada_segments[0][0x0082] == 0x0C &&
          helada_segments[0][0x00C3] == 0xFF &&
          helada_segments[0][0x00C4] == 8;

    memcpy(helada_segments, helada_snapshot, sizeof(helada_segments));
    memcpy(helada_vga, helada_snapshot + sizeof(helada_segments),
           sizeof(helada_vga));
    *helada = helada_runtime_snapshot;
    helada_segments[0][0x0083] = 0x1C;
    const int helada_right = zeliard_town_advance_pit(
        helada, &helada_game, helada_vga, sizeof(helada_vga), 20, 0);
    ok &= helada_right > 0 && helada->cavern_exit_requested &&
          helada_segments[0][0x0080] == 0 &&
          helada_segments[0][0x0081] == 0 &&
          helada_segments[0][0x0082] == 0x0C &&
          helada_segments[0][0x00C3] == 0 &&
          helada_segments[0][0x00C4] == 9;

    memcpy(helada_segments, helada_snapshot, sizeof(helada_segments));
    memcpy(helada_vga, helada_snapshot + sizeof(helada_segments),
           sizeof(helada_vga));
    *helada = helada_runtime_snapshot;
    helada_segments[0][0x0080] = 75;
    helada_segments[0][0x0081] = 0;
    helada_segments[0][0x0083] = 13;
    const u16 helada_inn_tile = (u16)(0xC017 + 75 * 8);
    helada_segments[0][0xFF2A] = (u8)helada_inn_tile;
    helada_segments[0][0xFF2B] = (u8)(helada_inn_tile >> 8);
    const int helada_inn_trigger = zeliard_town_advance_pit(
        helada, &helada_game, helada_vga, sizeof(helada_vga), 20, 1);
    const int helada_inn_fade = zeliard_town_advance_pit(
        helada, &helada_game, helada_vga, sizeof(helada_vga), 88, 0);
    ok &= helada_inn_trigger > 0 && helada_inn_fade > 0 &&
          helada->room.active && helada->room.kind == ZEL_ROOM_INN &&
          helada->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(helada_segments, helada_snapshot, sizeof(helada_segments));
    memcpy(helada_vga, helada_snapshot + sizeof(helada_segments),
           sizeof(helada_vga));
    *helada = helada_runtime_snapshot;
    helada_segments[0][0x001A] |= 0x10;
    const int helada_ruzeria = zeliard_town_enter_first_frame(
        helada, &helada_game, helada_vga, sizeof(helada_vga));
    ok &= helada_ruzeria == 0 &&
          helada_segments[0][0xCDD4] == 0 &&
          helada_segments[0][0xCDD5] == 7 &&
          helada_segments[0][0xCDDD] == 8 &&
          helada_segments[0][0xCDED] == 9;
    printf("town_helada_entry: rc=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u "
           "story=%02x/%02x/%02x/%02x>%02x/%02x/%02x/%02x\n",
           helada_result, helada_frame, helada_playfield, helada_capture,
           helada_state, helada_npcs, (unsigned)helada->music_index,
           helada_story_before[0], helada_story_before[1],
           helada_story_before[2], helada_story_before[3],
           helada_segments[0][0xCDD4], helada_segments[0][0xCDD5],
           helada_segments[0][0xCDDD], helada_segments[0][0xCDED]);
    printf("town_helada_routes: left=%d/0046/0c/ff/08 "
           "right=%d/0000/0c/00/09 inn=%d/%d/%d\n",
           helada_left, helada_right, helada_inn_trigger, helada_inn_fade,
           ZEL_ROOM_INN);
    free(helada);

    /* Ticket #82: Tumba's release TMMP descriptor selects MGT2, DPAT,
     * CMAN, and the 200FIGHT handoff target 80h -> start 6Fh/column 0Dh. */
    static u8 tumba_segments[ZELIARD_GAME_SEGMENT_COUNT]
                             [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 tumba_vga[0x10000];
    zeliard_game_exec_state_t tumba_game = {0};
    zeliard_town_runtime_t *tumba = calloc(1, sizeof(*tumba));
    ok &= tumba != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        tumba_game.segment[i] = tumba_segments[i];
        tumba_game.segment_size[i] = sizeof(tumba_segments[i]);
    }
    ok &= load_direct(tumba_segments[0], sizeof(tumba_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(tumba_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(tumba_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(tumba_segments[3], sizeof(tumba_segments[3]),
                   "assets/mole.bin") &&
          load_font(tumba_segments[0]) && load_item_panel(tumba_segments[1]);
    tumba_segments[0][0x00C4] = 0x85;
    tumba_segments[0][0x00C5] = 0x85;
    tumba_segments[0][0x0080] = 0x6F;
    tumba_segments[0][0x0083] = 0x0D;
    tumba_segments[0][ZEL_PLAYER_SWORD] = 1;
    tumba_segments[0][ZEL_PLAYER_SHIELD] = 1;
    tumba_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    tumba_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int tumba_result = tumba ? zeliard_town_enter_first_frame(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga)) : -99;
    const unsigned long long tumba_frame =
        fnv1a64(tumba_vga, sizeof(tumba_vga));
    const unsigned long long tumba_playfield =
        fnv1a64(tumba_vga, 160u * 320u);
    const unsigned long long tumba_capture =
        fnv1a64(tumba_segments[0] + 0xA000, 0x1500);
    const unsigned long long tumba_state =
        selected_state_hash(tumba_segments[0]);
    const unsigned long long tumba_npcs =
        npc_state_hash(tumba_segments[0]);
    const u8 tumba_story_before[3] = {
        tumba_segments[0][0xCFD3], tumba_segments[0][0xCFDB],
        tumba_segments[0][0xCFEB],
    };
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-tumba-c-frame.bin", "wb");
        if (dump) {
            fwrite(tumba_vga, 1, sizeof(tumba_vga), dump);
            fclose(dump);
        }
    }
    ok &= tumba_result == 0 && tumba->area == ZEL_TOWN_AREA_TUMBA;
    ok &= tumba->music_index == 3 && tumba->map_side == 1 &&
          tumba->palette_index == 2 && tumba->town_text_record == 0xC890;
    ok &= tumba_frame == 0xB2ED8F2244E27CF5ULL &&
          tumba_playfield == 0x11FF4AA993181A6FULL &&
          tumba_capture == 0xAB3088CF79795EEDULL &&
          tumba_state == 0xA3DE3DCC9A00D3BAULL &&
          tumba_npcs == 0x4BD4AC92306C323AULL;
    ok &= tumba_story_before[0] == 2 && tumba_story_before[1] == 3 &&
          tumba_story_before[2] == 7;

    static u8 tumba_snapshot[sizeof(tumba_segments) + sizeof(tumba_vga)];
    memcpy(tumba_snapshot, tumba_segments, sizeof(tumba_segments));
    memcpy(tumba_snapshot + sizeof(tumba_segments), tumba_vga,
           sizeof(tumba_vga));
    const zeliard_town_runtime_t tumba_runtime_snapshot = *tumba;

    tumba_segments[0][0x0083] = 0xFF;
    const int tumba_left = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 20, 0);
    ok &= tumba_left > 0 && tumba->cavern_exit_requested &&
          tumba_segments[0][0x0080] == 0x4E &&
          tumba_segments[0][0x0081] == 0 &&
          tumba_segments[0][0x0082] == 1 &&
          tumba_segments[0][0x00C3] == 0xFF &&
          tumba_segments[0][0x00C4] == 0x0B;

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0083] = 0x1C;
    const int tumba_right = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 20, 0);
    ok &= tumba_right > 0 && tumba->cavern_exit_requested &&
          tumba_segments[0][0x0080] == 0x73 &&
          tumba_segments[0][0x0081] == 0 &&
          tumba_segments[0][0x0082] == 0 &&
          tumba_segments[0][0x00C3] == 0 &&
          tumba_segments[0][0x00C4] == 0x0B;

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0080] = 27;
    tumba_segments[0][0x0081] = 0;
    tumba_segments[0][0x0083] = 13;
    const u16 tumba_armory_tile = (u16)(0xC017 + 27 * 8);
    tumba_segments[0][0xFF2A] = (u8)tumba_armory_tile;
    tumba_segments[0][0xFF2B] = (u8)(tumba_armory_tile >> 8);
    const int tumba_armory_trigger = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 20, 1);
    const int tumba_armory_fade = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 88, 0);
    ok &= tumba_armory_trigger > 0 && tumba_armory_fade > 0 &&
          tumba->room.active && tumba->room.kind == ZEL_ROOM_ARMORY &&
          tumba->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0080] = 76;
    tumba_segments[0][0x0081] = 0;
    tumba_segments[0][0x0083] = 13;
    const u16 tumba_inn_tile = (u16)(0xC017 + 76 * 8);
    tumba_segments[0][0xFF2A] = (u8)tumba_inn_tile;
    tumba_segments[0][0xFF2B] = (u8)(tumba_inn_tile >> 8);
    const int tumba_inn_trigger = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 20, 1);
    const int tumba_inn_fade = zeliard_town_advance_pit(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga), 88, 0);
    ok &= tumba_inn_trigger > 0 && tumba_inn_fade > 0 &&
          tumba->room.active && tumba->room.kind == ZEL_ROOM_INN &&
          tumba->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0022] |= 2;
    const int tumba_pirika = zeliard_town_enter_first_frame(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga));
    const u8 tumba_pirika_a = tumba_segments[0][0xCFD3];
    const u8 tumba_pirika_b = tumba_segments[0][0xCFDB];
    ok &= tumba_pirika == 0 && tumba_pirika_a == 8 && tumba_pirika_b == 9;

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0024] = 0x80;
    const int tumba_glory = zeliard_town_enter_first_frame(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga));
    const u8 tumba_glory_dialog = tumba_segments[0][0xCFEB];
    ok &= tumba_glory == 0 && tumba_glory_dialog == 10;

    memcpy(tumba_segments, tumba_snapshot, sizeof(tumba_segments));
    memcpy(tumba_vga, tumba_snapshot + sizeof(tumba_segments),
           sizeof(tumba_vga));
    *tumba = tumba_runtime_snapshot;
    tumba_segments[0][0x0024] = 2;
    const int tumba_glory_traded = zeliard_town_enter_first_frame(
        tumba, &tumba_game, tumba_vga, sizeof(tumba_vga));
    const u8 tumba_traded_dialog = tumba_segments[0][0xCFEB];
    ok &= tumba_glory_traded == 0 && tumba_traded_dialog == 11;
    printf("town_tumba_entry: rc=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u "
           "story=%02x/%02x/%02x>%02x/%02x/%02x/%02x\n",
           tumba_result, tumba_frame, tumba_playfield, tumba_capture,
           tumba_state, tumba_npcs, (unsigned)tumba->music_index,
           tumba_story_before[0], tumba_story_before[1],
           tumba_story_before[2], tumba_pirika_a, tumba_pirika_b,
           tumba_glory_dialog, tumba_traded_dialog);
    printf("town_tumba_routes: left=%d/004e/01/ff/0b "
           "right=%d/0073/00/00/0b armory=%d/%d/%d inn=%d/%d/%d\n",
           tumba_left, tumba_right, tumba_armory_trigger,
           tumba_armory_fade, ZEL_ROOM_ARMORY, tumba_inn_trigger,
           tumba_inn_fade, ZEL_ROOM_INN);
    free(tumba);

    /* Ticket #83: Dorado's release DRMP descriptor selects MGT2, DPAT,
     * MMAN, and the 200FIGHT handoff target 5Ch -> start 4Bh/column 0Dh. */
    static u8 dorado_segments[ZELIARD_GAME_SEGMENT_COUNT]
                              [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 dorado_vga[0x10000];
    zeliard_game_exec_state_t dorado_game = {0};
    zeliard_town_runtime_t *dorado = calloc(1, sizeof(*dorado));
    ok &= dorado != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        dorado_game.segment[i] = dorado_segments[i];
        dorado_game.segment_size[i] = sizeof(dorado_segments[i]);
    }
    ok &= load_direct(dorado_segments[0], sizeof(dorado_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(dorado_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(dorado_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(dorado_segments[3], sizeof(dorado_segments[3]),
                   "assets/mole.bin") &&
          load_font(dorado_segments[0]) &&
          load_item_panel(dorado_segments[1]);
    dorado_segments[0][0x00C4] = 0x86;
    dorado_segments[0][0x00C5] = 0x86;
    dorado_segments[0][0x0080] = 0x4B;
    dorado_segments[0][0x0083] = 0x0D;
    dorado_segments[0][ZEL_PLAYER_SWORD] = 1;
    dorado_segments[0][ZEL_PLAYER_SHIELD] = 1;
    dorado_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    dorado_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int dorado_result = dorado ? zeliard_town_enter_first_frame(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga)) : -99;
    const int dorado_actor_mman =
        fnv1a64(dorado_segments[1] + 0x4100, 0x1EC0) ==
            0xC287EABFFE898D6CULL &&
        fnv1a64(dorado_segments[2] + 0x7000, 0x0520) ==
            0xF205BFB757BBDA0CULL;
    const unsigned long long dorado_frame =
        fnv1a64(dorado_vga, sizeof(dorado_vga));
    const unsigned long long dorado_playfield =
        fnv1a64(dorado_vga, 160u * 320u);
    const unsigned long long dorado_capture =
        fnv1a64(dorado_segments[0] + 0xA000, 0x1500);
    const unsigned long long dorado_state =
        selected_state_hash(dorado_segments[0]);
    const unsigned long long dorado_npcs =
        npc_state_hash(dorado_segments[0]);
    const u8 dorado_story_before[2] = {
        dorado_segments[0][0xCDFB], dorado_segments[0][0xCE03],
    };
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-dorado-c-frame.bin", "wb");
        if (dump) {
            fwrite(dorado_vga, 1, sizeof(dorado_vga), dump);
            fclose(dump);
        }
    }
    ok &= dorado_result == 0 && dorado->area == ZEL_TOWN_AREA_DORADO &&
          dorado_actor_mman;
    ok &= dorado->music_index == 3 && dorado->map_side == 1 &&
          dorado->palette_index == 2 && dorado->town_text_record == 0xC6D8;
    ok &= dorado_frame == 0x8C8091CE1A71AE19ULL &&
          dorado_playfield == 0xF7BAD97B9E14237CULL &&
          dorado_capture == 0xAB3088CF79795EEDULL &&
          dorado_state == 0xA44A7ECC9A5C610DULL &&
          dorado_npcs == 0x25A3DA737241664DULL;
    ok &= dorado_story_before[0] == 4 && dorado_story_before[1] == 5;

    static u8 dorado_snapshot[sizeof(dorado_segments) + sizeof(dorado_vga)];
    memcpy(dorado_snapshot, dorado_segments, sizeof(dorado_segments));
    memcpy(dorado_snapshot + sizeof(dorado_segments), dorado_vga,
           sizeof(dorado_vga));
    const zeliard_town_runtime_t dorado_runtime_snapshot = *dorado;

    /* 106TOWN invalidates the complete GTMCGA tile cursor after restoring
     * an NPC speech panel. Dorado's animated scenery made the missing
     * invalidation visible as a stale rectangular background after talk. */
    dorado_segments[0][0xFF33] = 5;
    const int dorado_dialog_begin = zeliard_town_dialog_begin_live(
        &dorado->dialog, dorado_segments[0], dorado_segments[3],
        dorado_segments[1], sizeof(dorado_segments[1]),
        dorado_segments[2], sizeof(dorado_segments[2]),
        dorado_vga, sizeof(dorado_vga), 190);
    dorado_segments[0][0xFF1D] = 0xFF;
    const int dorado_dialog_close = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 20, 0);
    int dorado_dialog_cursor_invalid = 1;
    for (u16 cursor = 0xE000; cursor < 0xE0E0; ++cursor)
        dorado_dialog_cursor_invalid &= dorado_segments[0][cursor] == 0xFE;
    ok &= dorado_dialog_begin == 0 && dorado_dialog_close > 0 &&
          !dorado->dialog.active && dorado_dialog_cursor_invalid;
    printf("town_dorado_dialog_restore: begin=%d close=%d active=%d "
           "cursor=%d\n", dorado_dialog_begin, dorado_dialog_close,
           dorado->dialog.active, dorado_dialog_cursor_invalid);

    memcpy(dorado_segments, dorado_snapshot, sizeof(dorado_segments));
    memcpy(dorado_vga, dorado_snapshot + sizeof(dorado_segments),
           sizeof(dorado_vga));
    *dorado = dorado_runtime_snapshot;

    dorado_segments[0][0x0083] = 0xFF;
    const int dorado_left = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 20, 0);
    ok &= dorado_left > 0 && dorado->cavern_exit_requested &&
          dorado_segments[0][0x0080] == 0x0F &&
          dorado_segments[0][0x0081] == 0 &&
          dorado_segments[0][0x0082] == 0x3C &&
          dorado_segments[0][0x00C3] == 0xFF &&
          dorado_segments[0][0x00C4] == 0x0F;

    memcpy(dorado_segments, dorado_snapshot, sizeof(dorado_segments));
    memcpy(dorado_vga, dorado_snapshot + sizeof(dorado_segments),
           sizeof(dorado_vga));
    *dorado = dorado_runtime_snapshot;
    dorado_segments[0][0x0083] = 0x1C;
    const int dorado_right = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 4, 0);
    ok &= dorado_right > 0 && dorado->cavern_exit_requested &&
          (u16)(dorado_segments[0][0x0080] |
                ((u16)dorado_segments[0][0x0081] << 8)) == 0x012B &&
          dorado_segments[0][0x0082] == 0x27 &&
          dorado_segments[0][0x00C3] == 0 &&
          dorado_segments[0][0x00C4] == 0x0E;

    memcpy(dorado_segments, dorado_snapshot, sizeof(dorado_segments));
    memcpy(dorado_vga, dorado_snapshot + sizeof(dorado_segments),
           sizeof(dorado_vga));
    *dorado = dorado_runtime_snapshot;
    dorado_segments[0][0x0080] = 53;
    dorado_segments[0][0x0081] = 0;
    dorado_segments[0][0x0083] = 13;
    const u16 dorado_inn_tile = (u16)(0xC017 + 53 * 8);
    dorado_segments[0][0xFF2A] = (u8)dorado_inn_tile;
    dorado_segments[0][0xFF2B] = (u8)(dorado_inn_tile >> 8);
    const int dorado_inn_trigger = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 20, 1);
    const int dorado_inn_fade = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 88, 0);
    ok &= dorado_inn_trigger > 0 && dorado_inn_fade > 0 &&
          dorado->room.active && dorado->room.kind == ZEL_ROOM_INN &&
          dorado->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(dorado_segments, dorado_snapshot, sizeof(dorado_segments));
    memcpy(dorado_vga, dorado_snapshot + sizeof(dorado_segments),
           sizeof(dorado_vga));
    *dorado = dorado_runtime_snapshot;
    dorado_segments[0][0x0080] = 111;
    dorado_segments[0][0x0081] = 0;
    dorado_segments[0][0x0083] = 13;
    const u16 dorado_bank_tile = (u16)(0xC017 + 111 * 8);
    dorado_segments[0][0xFF2A] = (u8)dorado_bank_tile;
    dorado_segments[0][0xFF2B] = (u8)(dorado_bank_tile >> 8);
    const int dorado_bank_trigger = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 20, 1);
    const int dorado_bank_fade = zeliard_town_advance_pit(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga), 88, 0);
    ok &= dorado_bank_trigger > 0 && dorado_bank_fade > 0 &&
          dorado->room.active && dorado->room.kind == ZEL_ROOM_BANK &&
          dorado->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(dorado_segments, dorado_snapshot, sizeof(dorado_segments));
    memcpy(dorado_vga, dorado_snapshot + sizeof(dorado_segments),
           sizeof(dorado_vga));
    *dorado = dorado_runtime_snapshot;
    dorado_segments[0][0x002A] |= 4;
    const int dorado_silkarn = zeliard_town_enter_first_frame(
        dorado, &dorado_game, dorado_vga, sizeof(dorado_vga));
    const u8 dorado_silkarn_a = dorado_segments[0][0xCDFB];
    const u8 dorado_silkarn_b = dorado_segments[0][0xCE03];
    ok &= dorado_silkarn == 0 &&
          dorado_silkarn_a == 12 && dorado_silkarn_b == 13;
    printf("town_dorado_entry: rc=%d actor_mman=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u "
           "story=%02x/%02x>%02x/%02x\n",
           dorado_result, dorado_actor_mman, dorado_frame, dorado_playfield,
           dorado_capture,
           dorado_state, dorado_npcs, (unsigned)dorado->music_index,
           dorado_story_before[0], dorado_story_before[1],
           dorado_silkarn_a, dorado_silkarn_b);
    printf("town_dorado_routes: left=%d/000f/3c/ff/0f "
           "right=%d/012b/27/00/0e inn=%d/%d/%d bank=%d/%d/%d\n",
           dorado_left, dorado_right, dorado_inn_trigger, dorado_inn_fade,
           ZEL_ROOM_INN, dorado_bank_trigger, dorado_bank_fade,
           ZEL_ROOM_BANK);
    free(dorado);

    /* Ticket #84: Llama's release LLMP descriptor selects MGT1, DPAT,
     * CMAN, and the 200FIGHT handoff target 47h -> start 36h/column 0Dh. */
    static u8 llama_segments[ZELIARD_GAME_SEGMENT_COUNT]
                             [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 llama_vga[0x10000];
    zeliard_game_exec_state_t llama_game = {0};
    zeliard_town_runtime_t *llama = calloc(1, sizeof(*llama));
    ok &= llama != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        llama_game.segment[i] = llama_segments[i];
        llama_game.segment_size[i] = sizeof(llama_segments[i]);
    }
    ok &= load_direct(llama_segments[0], sizeof(llama_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(llama_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(llama_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(llama_segments[3], sizeof(llama_segments[3]),
                   "assets/mole.bin") &&
          load_font(llama_segments[0]) &&
          load_item_panel(llama_segments[1]);
    llama_segments[0][0x00C4] = 0x87;
    llama_segments[0][0x00C5] = 0x87;
    llama_segments[0][0x0080] = 0x36;
    llama_segments[0][0x0083] = 0x0D;
    llama_segments[0][ZEL_PLAYER_SWORD] = 1;
    llama_segments[0][ZEL_PLAYER_SHIELD] = 1;
    llama_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    llama_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int llama_result = llama ? zeliard_town_enter_first_frame(
        llama, &llama_game, llama_vga, sizeof(llama_vga)) : -99;
    const unsigned long long llama_frame =
        fnv1a64(llama_vga, sizeof(llama_vga));
    const unsigned long long llama_playfield =
        fnv1a64(llama_vga, 160u * 320u);
    const unsigned long long llama_capture =
        fnv1a64(llama_segments[0] + 0xA000, 0x1500);
    const unsigned long long llama_state =
        selected_state_hash(llama_segments[0]);
    const unsigned long long llama_npcs =
        npc_state_hash(llama_segments[0]);
    const u8 llama_story_before[3] = {
        llama_segments[0][0xD0D2], llama_segments[0][0xD0DA],
        llama_segments[0][0xD0E2],
    };
    if (getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-llama-c-frame.bin", "wb");
        if (dump) {
            fwrite(llama_vga, 1, sizeof(llama_vga), dump);
            fclose(dump);
        }
    }
    ok &= llama_result == 0 && llama->area == ZEL_TOWN_AREA_LLAMA;
    ok &= llama->music_index == 2 && llama->map_side == 0 &&
          llama->palette_index == 1 && llama->town_text_record == 0xC8E0;
    ok &= llama_frame == 0xA8D2A6F63DAA834AULL &&
          llama_playfield == 0x490A5B10473F47A4ULL &&
          llama_capture == 0xF2C3F82A0F93D06DULL &&
          llama_state == 0x9163832A08DECDB0ULL &&
          llama_npcs == 0x55B5FACA82E29E35ULL;
    ok &= llama_story_before[0] == 0 && llama_story_before[1] == 3 &&
          llama_story_before[2] == 18;

    static u8 llama_snapshot[sizeof(llama_segments) + sizeof(llama_vga)];
    memcpy(llama_snapshot, llama_segments, sizeof(llama_segments));
    memcpy(llama_snapshot + sizeof(llama_segments), llama_vga,
           sizeof(llama_vga));
    const zeliard_town_runtime_t llama_runtime_snapshot = *llama;

    /* LLMP places the frightened resident at x220, two columns before the
     * Paguro door at x222.  Merely approaching from the left must begin her
     * warning dialog; the player does not press Space or Up to trigger it.
     * This is the release flow that introduces the creature in the hut. */
    llama_segments[0][0x0080] = 201;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 13;
    llama_segments[0][0x0084] = 0;
    u16 llama_tile = (u16)(0xC017 + 201 * 8);
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_warning = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 20, 8);
    const unsigned long long llama_warning_frame =
        fnv1a64(llama_vga, sizeof(llama_vga));
    ok &= llama_warning > 0 && llama->dialog.active &&
          llama->facing_npc_position == 220 &&
          llama->dialog.npc_offset == 0xD0CB &&
          llama->dialog.pending_sound_cue == 0x1E &&
          !llama->cavern_exit_requested;

    unsigned llama_warning_steps = 0;
    while (llama->dialog.active && llama_warning_steps++ < 2000) {
        if (llama->dialog.scroll_active ||
            llama->dialog.scroll_resume_pending) {
            ok &= zeliard_town_dialog_advance_pit(
                &llama->dialog, llama_segments[0], llama_vga,
                sizeof(llama_vga)) >= 0;
        } else if (llama->dialog.waiting) {
            llama_segments[0][0xFF1D] = 0xFF;
            ok &= zeliard_town_dialog_continue(
                &llama->dialog, llama_segments[0], llama_segments[3],
                llama_vga, sizeof(llama_vga)) >= 0;
        }
    }
    ok &= !llama->dialog.active && llama_segments[0][0x009A] == 0;

    /* Door type 8 uses route record 0. 106TOWN loads MP70 before applying
     * destination-10h, then wraps the negative result by MP70's width. */
    llama_segments[0][0x0080] = 252;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 13;
    llama_tile = (u16)(0xC017 + 252 * 8);
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_route_0 = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 20, 1);
    ok &= llama_route_0 > 0 && llama->cavern_exit_requested &&
          (u16)(llama_segments[0][0x0080] |
                ((u16)llama_segments[0][0x0081] << 8)) == 0x00C1 &&
          llama_segments[0][0x0082] == 0x0C &&
          llama_segments[0][0x00C3] == 0 &&
          llama_segments[0][0x00C4] == 0x12;

    memcpy(llama_segments, llama_snapshot, sizeof(llama_segments));
    memcpy(llama_vga, llama_snapshot + sizeof(llama_segments),
           sizeof(llama_vga));
    *llama = llama_runtime_snapshot;
    llama_segments[0][0x0080] = 0;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 4;
    llama_tile = 0xC017;
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_caliente_reverse = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 4, 1);
    ok &= llama_caliente_reverse > 0 && llama->cavern_exit_requested &&
          (u16)(llama_segments[0][0x0080] |
                ((u16)llama_segments[0][0x0081] << 8)) == 0x0088 &&
          llama_segments[0][0x0082] == 0x3D &&
          llama_segments[0][0x00C3] == 0xFF &&
          llama_segments[0][0x00C4] == 0x12;

    memcpy(llama_segments, llama_snapshot, sizeof(llama_segments));
    memcpy(llama_vga, llama_snapshot + sizeof(llama_segments),
           sizeof(llama_vga));
    *llama = llama_runtime_snapshot;
    llama_segments[0][0x0080] = 205;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 13;
    llama_tile = (u16)(0xC017 + 205 * 8);
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_paguro = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 20, 1);
    ok &= llama_paguro > 0 && llama->cavern_exit_requested &&
          (u16)(llama_segments[0][0x0080] |
                ((u16)llama_segments[0][0x0081] << 8)) == 0x000B &&
          llama_segments[0][0x0082] == 0x03 &&
          llama_segments[0][0x00C3] == 0 &&
          llama_segments[0][0x00C4] == 0x15;

    memcpy(llama_segments, llama_snapshot, sizeof(llama_segments));
    memcpy(llama_vga, llama_snapshot + sizeof(llama_segments),
           sizeof(llama_vga));
    *llama = llama_runtime_snapshot;
    llama_segments[0][0x0080] = 159;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 13;
    llama_tile = (u16)(0xC017 + 159 * 8);
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_inn_trigger = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 20, 1);
    const int llama_inn_fade = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 88, 0);
    ok &= llama_inn_trigger > 0 && llama_inn_fade > 0 &&
          llama->room.active && llama->room.kind == ZEL_ROOM_INN &&
          llama->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(llama_segments, llama_snapshot, sizeof(llama_segments));
    memcpy(llama_vga, llama_snapshot + sizeof(llama_segments),
           sizeof(llama_vga));
    *llama = llama_runtime_snapshot;
    llama_segments[0][0x0080] = 125;
    llama_segments[0][0x0081] = 0;
    llama_segments[0][0x0083] = 13;
    llama_tile = (u16)(0xC017 + 125 * 8);
    llama_segments[0][0xFF2A] = (u8)llama_tile;
    llama_segments[0][0xFF2B] = (u8)(llama_tile >> 8);
    const int llama_bank_trigger = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 20, 1);
    const int llama_bank_fade = zeliard_town_advance_pit(
        llama, &llama_game, llama_vga, sizeof(llama_vga), 88, 0);
    ok &= llama_bank_trigger > 0 && llama_bank_fade > 0 &&
          llama->room.active && llama->room.kind == ZEL_ROOM_BANK &&
          llama->room.exact_vm_active && zeliard_room_masm_vm_active();
    zeliard_room_masm_vm_stop();

    memcpy(llama_segments, llama_snapshot, sizeof(llama_segments));
    memcpy(llama_vga, llama_snapshot + sizeof(llama_segments),
           sizeof(llama_vga));
    *llama = llama_runtime_snapshot;
    llama_segments[0][0x0030] = 0xFF;
    llama_segments[0][0x0034] = 0xC0;
    const int llama_story = zeliard_town_enter_first_frame(
        llama, &llama_game, llama_vga, sizeof(llama_vga));
    const u8 llama_story_after[3] = {
        llama_segments[0][0xD0D2], llama_segments[0][0xD0DA],
        llama_segments[0][0xD0E2],
    };
    ok &= llama_story == 0 && llama_story_after[0] == 2 &&
          llama_story_after[1] == 9 && llama_story_after[2] == 16;
    printf("town_llama_entry: rc=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u "
           "story=%02x/%02x/%02x>%02x/%02x/%02x\n",
           llama_result, llama_frame, llama_playfield, llama_capture,
           llama_state, llama_npcs, (unsigned)llama->music_index,
           llama_story_before[0], llama_story_before[1],
           llama_story_before[2], llama_story_after[0],
           llama_story_after[1], llama_story_after[2]);
    printf("town_llama_routes: edge=%d/fff1/0c/00/12 "
           "reverse=%d/0088/3d/ff/12 paguro=%d/000b/03/00/15 "
           "warning=%d/%016llx/%u inn=%d/%d/%d bank=%d/%d/%d\n",
           llama_route_0, llama_caliente_reverse, llama_paguro,
           llama_warning, llama_warning_frame, llama_warning_steps,
           llama_inn_trigger, llama_inn_fade, ZEL_ROOM_INN,
           llama_bank_trigger, llama_bank_fade, ZEL_ROOM_BANK);
    free(llama);

    /* Ticket #85: Pureza's PRMP descriptor selects UGM1, DPAT, CMAN,
     * and the release 200FIGHT target 4Ch -> start 3Bh/column 0Dh. */
    static u8 pureza_segments[ZELIARD_GAME_SEGMENT_COUNT]
                              [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 pureza_vga[0x10000];
    zeliard_game_exec_state_t pureza_game = {0};
    zeliard_town_runtime_t *pureza = calloc(1, sizeof(*pureza));
    ok &= pureza != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        pureza_game.segment[i] = pureza_segments[i];
        pureza_game.segment_size[i] = sizeof(pureza_segments[i]);
    }
    ok &= load_direct(pureza_segments[0], sizeof(pureza_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(pureza_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(pureza_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(pureza_segments[3], sizeof(pureza_segments[3]),
                   "assets/mole.bin") &&
          load_font(pureza_segments[0]) &&
          load_item_panel(pureza_segments[1]);
    pureza_segments[0][0x00C4] = 0x88;
    pureza_segments[0][0x00C5] = 0x88;
    pureza_segments[0][0x0080] = 0x3B;
    pureza_segments[0][0x0083] = 0x0D;
    pureza_segments[0][ZEL_PLAYER_SWORD] = 1;
    pureza_segments[0][ZEL_PLAYER_SHIELD] = 1;
    pureza_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    pureza_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int pureza_result = pureza ? zeliard_town_enter_first_frame(
        pureza, &pureza_game, pureza_vga, sizeof(pureza_vga)) : -99;
    const unsigned long long pureza_frame =
        fnv1a64(pureza_vga, sizeof(pureza_vga));
    const unsigned long long pureza_playfield =
        fnv1a64(pureza_vga, 160u * 320u);
    const unsigned long long pureza_capture =
        fnv1a64(pureza_segments[0] + 0xA000, 0x1500);
    const unsigned long long pureza_state =
        selected_state_hash(pureza_segments[0]);
    const unsigned long long pureza_npcs =
        npc_state_hash(pureza_segments[0]);
    ok &= pureza_result == 0 && pureza->area == ZEL_TOWN_AREA_PUREZA;
    ok &= pureza->music_index == 1 && pureza->map_side == 1 &&
          pureza->palette_index == 2 && pureza->town_text_record == 0xCA20;
    ok &= pureza_frame == 0x316F4F9EEC134576ULL &&
          pureza_playfield == 0x08EAD07F074662FFULL &&
          pureza_capture == 0xAB3088CF79795EEDULL &&
          pureza_state == 0xA2987BCC98EC7A74ULL &&
          pureza_npcs == 0x7F0E494064868DA3ULL;
    ok &= pureza_segments[0][0xD090] == 5 &&
          (u16)(pureza_segments[0][0xD0B1] |
                ((u16)pureza_segments[0][0xD0B2] << 8)) == 0x0124;

    static u8 pureza_snapshot[sizeof(pureza_segments) + sizeof(pureza_vga)];
    memcpy(pureza_snapshot, pureza_segments, sizeof(pureza_segments));
    memcpy(pureza_snapshot + sizeof(pureza_segments), pureza_vga,
           sizeof(pureza_vga));
    const zeliard_town_runtime_t pureza_runtime_snapshot = *pureza;

    static const struct { u16 position; u8 type; } pureza_doors[] = {
        {49, 4}, {93, 7}, {128, 2}, {181, 6}, {231, 3}, {294, 0xFF},
    };
    for (size_t i = 0; i < sizeof(pureza_doors) / sizeof(pureza_doors[0]);
         ++i) {
        const u16 start = (u16)(pureza_doors[i].position - 17);
        pureza_segments[0][0x0080] = (u8)start;
        pureza_segments[0][0x0081] = (u8)(start >> 8);
        pureza_segments[0][0x0083] = 13;
        zeliard_town_detect_facing_targets(pureza, pureza_segments[0], 1);
        ok &= pureza->facing_door_found &&
              pureza->facing_door_type == pureza_doors[i].type;
    }

    /* The sole boundary record enters the authored Pureza cavern route. */
    pureza_segments[0][0x0080] = 0;
    pureza_segments[0][0x0081] = 0;
    pureza_segments[0][0x0083] = 0;
    pureza_segments[0][0xFF2A] = 0x17;
    pureza_segments[0][0xFF2B] = 0xC0;
    const int pureza_route = zeliard_town_advance_pit(
        pureza, &pureza_game, pureza_vga, sizeof(pureza_vga), 20, 4);
    ok &= pureza_route > 0 && pureza->cavern_exit_requested &&
          (u16)(pureza_segments[0][0x0080] |
                ((u16)pureza_segments[0][0x0081] << 8)) == 0x005F &&
          pureza_segments[0][0x0082] == 0x0B &&
          pureza_segments[0][0x00C3] == 0xFF &&
          pureza_segments[0][0x00C4] == 0x17;

    /* Event order is significant: finding the Lion Head Key removes the
     * help NPC and selects dialog 6; using it later overrides dialog 7. */
    memcpy(pureza_segments, pureza_snapshot, sizeof(pureza_segments));
    memcpy(pureza_vga, pureza_snapshot + sizeof(pureza_segments),
           sizeof(pureza_vga));
    *pureza = pureza_runtime_snapshot;
    pureza_segments[0][0x0042] = 0x08;
    ok &= zeliard_town_enter_first_frame(
              pureza, &pureza_game, pureza_vga, sizeof(pureza_vga)) == 0 &&
          pureza_segments[0][0xD090] == 6 &&
          pureza_segments[0][0xD0B1] == 0xFF &&
          pureza_segments[0][0xD0B2] == 0xFF;
    pureza_segments[0][0x002B] = 0x10;
    ok &= zeliard_town_enter_first_frame(
              pureza, &pureza_game, pureza_vga, sizeof(pureza_vga)) == 0 &&
          pureza_segments[0][0xD090] == 7;

    /* With the warning already seen, special door FF fades to Dorado at
     * 0084h/0Dh, but C5 keeps Pureza as the Sage/death-return town. */
    memcpy(pureza_segments, pureza_snapshot, sizeof(pureza_segments));
    memcpy(pureza_vga, pureza_snapshot + sizeof(pureza_segments),
           sizeof(pureza_vga));
    *pureza = pureza_runtime_snapshot;
    pureza_segments[0][0x0045] = 0x80;
    pureza_segments[0][0x0080] = 0x15;
    pureza_segments[0][0x0081] = 0x01;
    pureza_segments[0][0x0083] = 0x0D;
    const u16 pureza_tile = (u16)(0xC017 + 0x0115 * 8);
    pureza_segments[0][0xFF2A] = (u8)pureza_tile;
    pureza_segments[0][0xFF2B] = (u8)(pureza_tile >> 8);
    const int pureza_special_trigger = zeliard_town_advance_pit(
        pureza, &pureza_game, pureza_vga, sizeof(pureza_vga), 20, 1);
    const int pureza_special_fade = zeliard_town_advance_pit(
        pureza, &pureza_game, pureza_vga, sizeof(pureza_vga), 88, 0);
    ok &= pureza_special_trigger > 0 && pureza_special_fade > 0 &&
          pureza->area == ZEL_TOWN_AREA_DORADO &&
          pureza_segments[0][0x00C4] == 0x86 &&
          pureza_segments[0][0x00C5] == 0x88 &&
          (u16)(pureza_segments[0][0x0080] |
                ((u16)pureza_segments[0][0x0081] << 8)) == 0x0084 &&
          pureza_segments[0][0x0083] == 0x0D &&
          pureza->music_index == 3;

    memcpy(pureza_segments, pureza_snapshot, sizeof(pureza_segments));
    memcpy(pureza_vga, pureza_snapshot + sizeof(pureza_segments),
           sizeof(pureza_vga));
    *pureza = pureza_runtime_snapshot;
    pureza_segments[0][0x0045] = 0;
    pureza_segments[0][0x0080] = 0x15;
    pureza_segments[0][0x0081] = 0x01;
    pureza_segments[0][0x0083] = 0x0D;
    pureza_segments[0][0xFF2A] = (u8)pureza_tile;
    pureza_segments[0][0xFF2B] = (u8)(pureza_tile >> 8);
    const int pureza_warning_trigger = zeliard_town_advance_pit(
        pureza, &pureza_game, pureza_vga, sizeof(pureza_vga), 20, 1);
    ok &= pureza_warning_trigger > 0 && pureza->dialog.active &&
          pureza->special_door_pending;
    unsigned pureza_warning_ticks = 0;
    while (ok && pureza->area == ZEL_TOWN_AREA_PUREZA &&
           pureza_warning_ticks < 20000) {
        if (pureza->dialog.waiting) pureza_segments[0][0xFF1D] = 0xFF;
        ok &= zeliard_town_advance_pit(
                  pureza, &pureza_game, pureza_vga,
                  sizeof(pureza_vga), 1, 0) >= 0;
        ++pureza_warning_ticks;
    }
    ok &= pureza->area == ZEL_TOWN_AREA_DORADO &&
          (pureza_segments[0][0x0045] & 0x80) &&
          pureza_segments[0][0x00C5] == 0x88;

    printf("town_pureza_entry: rc=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u\n",
           pureza_result, pureza_frame, pureza_playfield, pureza_capture,
           pureza_state, pureza_npcs,
           (unsigned)pureza_runtime_snapshot.music_index);
    printf("town_pureza_routes: cavern=%d/005f/0b/ff/17 "
           "special=%d/%d/86/0084/0d warning=%d/%u sage=88\n",
           pureza_route, pureza_special_trigger, pureza_special_fade,
           pureza_warning_trigger, pureza_warning_ticks);
    free(pureza);

    /* Ticket #86: Esco's ESMP descriptor is the hidden final village. It
     * shares its boundary and doorway table: left enters cavern route 18h,
     * while right opens the alternate authored route back to Helada. */
    static u8 esco_segments[ZELIARD_GAME_SEGMENT_COUNT]
                            [ZELIARD_GAME_SEGMENT_SIZE];
    static u8 esco_vga[0x10000];
    zeliard_game_exec_state_t esco_game = {0};
    zeliard_town_runtime_t *esco = calloc(1, sizeof(*esco));
    int esco_ok = esco != NULL;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        esco_game.segment[i] = esco_segments[i];
        esco_game.segment_size[i] = sizeof(esco_segments[i]);
    }
    esco_ok &= load_direct(esco_segments[0], sizeof(esco_segments[0]),
                      "assets/stdply.bin") &&
          load_direct(esco_segments[0] + 0x2000, 0xE000,
                      "assets/gmmcga.bin") &&
          load_raw(esco_segments[0] + 0x6000, 0xA000,
                   "assets/town.bin") &&
          load_raw(esco_segments[3], sizeof(esco_segments[3]),
                   "assets/mole.bin") &&
          load_font(esco_segments[0]) &&
          load_item_panel(esco_segments[1]);
    esco_segments[0][0x00C4] = 0x89;
    esco_segments[0][0x00C5] = 0x89;
    esco_segments[0][0x0080] = 0x9A;
    esco_segments[0][0x0083] = 0x0D;
    esco_segments[0][ZEL_PLAYER_SWORD] = 1;
    esco_segments[0][ZEL_PLAYER_SHIELD] = 1;
    esco_segments[0][ZEL_PLAYER_SHIELD_HP] = 30;
    esco_segments[0][ZEL_PLAYER_SHIELD_HP_MAX] = 30;
    const int esco_result = esco ? zeliard_town_enter_first_frame(
        esco, &esco_game, esco_vga, sizeof(esco_vga)) : -99;
    const int esco_actor_mman =
        fnv1a64(esco_segments[1] + 0x4100, 0x1EC0) ==
            0xC287EABFFE898D6CULL &&
        fnv1a64(esco_segments[2] + 0x7000, 0x0520) ==
            0xF205BFB757BBDA0CULL;
    const unsigned long long esco_frame =
        fnv1a64(esco_vga, sizeof(esco_vga));
    const unsigned long long esco_playfield =
        fnv1a64(esco_vga, 160u * 320u);
    const unsigned long long esco_capture =
        fnv1a64(esco_segments[0] + 0xA000, 0x1500);
    const unsigned long long esco_state =
        selected_state_hash(esco_segments[0]);
    const unsigned long long esco_npcs =
        npc_state_hash(esco_segments[0]);
    esco_ok &= esco_result == 0 && esco->area == ZEL_TOWN_AREA_ESCO &&
               esco_actor_mman;
    esco_ok &= esco->music_index == 2 && esco->map_side == 0 &&
          esco->palette_index == 1 && esco->town_text_record == 0xC6D8;
    esco_ok &= esco_frame == 0xC533A2131FBF07E7ULL &&
               esco_playfield == 0x58E96A42F196797CULL &&
               esco_capture == 0xF2C3F82A0F93D06DULL &&
               esco_state == 0x90F5C82A0880BE0FULL &&
               esco_npcs == 0xFA227698AC7EE473ULL;

    static const struct { u16 position; u8 type; } esco_doors[] = {
        {57, 3}, {111, 4}, {138, 6}, {171, 5}, {205, 8},
    };
    for (size_t i = 0; i < sizeof(esco_doors) / sizeof(esco_doors[0]);
         ++i) {
        const u16 start = (u16)(esco_doors[i].position - 17);
        esco_segments[0][0x0080] = (u8)start;
        esco_segments[0][0x0081] = (u8)(start >> 8);
        esco_segments[0][0x0083] = 13;
        zeliard_town_detect_facing_targets(esco, esco_segments[0], 1);
        esco_ok &= esco->facing_door_found &&
              esco->facing_door_type == esco_doors[i].type;
    }

    static u8 esco_snapshot[sizeof(esco_segments) + sizeof(esco_vga)];
    memcpy(esco_snapshot, esco_segments, sizeof(esco_segments));
    memcpy(esco_snapshot + sizeof(esco_segments), esco_vga,
           sizeof(esco_vga));
    const zeliard_town_runtime_t esco_runtime_snapshot = *esco;
    esco_segments[0][0x0080] = 0;
    esco_segments[0][0x0081] = 0;
    esco_segments[0][0x0083] = 0;
    esco_segments[0][0xFF2A] = 0x17;
    esco_segments[0][0xFF2B] = 0xC0;
    const int esco_tunnel = zeliard_town_advance_pit(
        esco, &esco_game, esco_vga, sizeof(esco_vga), 20, 4);
    esco_ok &= esco_tunnel > 0 && esco->cavern_exit_requested &&
          (u16)(esco_segments[0][0x0080] |
                ((u16)esco_segments[0][0x0081] << 8)) == 0x006B &&
          esco_segments[0][0x0082] == 0x3C &&
          esco_segments[0][0x00C3] == 0 &&
          esco_segments[0][0x00C4] == 0x18;

    memcpy(esco_segments, esco_snapshot, sizeof(esco_segments));
    memcpy(esco_vga, esco_snapshot + sizeof(esco_segments),
           sizeof(esco_vga));
    *esco = esco_runtime_snapshot;
    esco_segments[0][0x0083] = 0x1C;
    const int esco_gardens = zeliard_town_advance_pit(
        esco, &esco_game, esco_vga, sizeof(esco_vga), 1, 8);
    esco_ok &= esco_gardens > 0 && esco->area == ZEL_TOWN_AREA_HELADA &&
          esco_segments[0][0x00C4] == 0x84 &&
          (u16)(esco_segments[0][0x0080] |
                ((u16)esco_segments[0][0x0081] << 8)) == 0x00BF &&
          esco_segments[0][0x0083] == 0x1A;

    printf("town_esco_entry: ok=%d rc=%d actor_mman=%d frame=%016llx playfield=%016llx "
           "capture=%016llx state=%016llx npc=%016llx music=%u\n",
           esco_ok, esco_result, esco_actor_mman, esco_frame, esco_playfield,
           esco_capture,
           esco_state, esco_npcs,
           (unsigned)esco_runtime_snapshot.music_index);
    printf("town_esco_routes: tunnel=%d/006b/3c/00/18 "
           "gardens=%d/84/00bf/1a\n", esco_tunnel, esco_gardens);
    ok &= esco_ok;
    free(esco);
    unsigned long long dirty_entry_hash = 0xCBF29CE484222325ULL;
    int all_town_surfaces_clean = 1;
    for (u8 area_id = 0x80; area_id <= 0x89; ++area_id) {
        unsigned long long area_hash = 0;
        const int area_clean = dirty_town_entry_matches_clean(
            area_id, &area_hash);
        all_town_surfaces_clean &= area_clean;
        dirty_entry_hash ^= area_hash;
        dirty_entry_hash *= 0x100000001B3ULL;
    }
    ok &= all_town_surfaces_clean;
    printf("town_dirty_surface_reentry_all_selectors: %s hash=%016llx\n",
           all_town_surfaces_clean ? "PASS" : "FAIL", dirty_entry_hash);
    printf("town_muralla_entry: frames=%d frame=%016llx playfield=%016llx state=%016llx "
           "npc=%016llx mpat=%016llx/%016llx area=%02x text=%04x\n",
           muralla_frames, muralla_frame_hash, muralla_playfield_hash,
           muralla_state_hash,
           muralla_npc_hash, mpat_pixel_hash, mpat_alpha_hash,
           segments[0][0x00C4], town.town_text_record);
    printf("town_castle_return: frames=%d playfield=%016llx cpat=%016llx/%016llx "
           "area=%02x col=%02x start=%02x%02x\n",
           castle_return_frames, castle_return_playfield,
           return_cpat_pixels, return_cpat_alpha, segments[0][0x00C4],
           segments[0][0x0083], segments[0][0x0081], segments[0][0x0080]);
    printf("town_muralla_cavern_exit: frames=%d requested=%d start=%04x "
           "row=%02x boss=%02x area=%02x\n",
           cavern_exit_frames, cavern_requested, cavern_start,
           cavern_row, cavern_boss, cavern_area);
    printf("town_runtime: %s rc=%d frame=%016llx sword=%016llx "
           "state=%016llx capture=%016llx palette=%016llx events=%u text=%04x\n",
           ok ? "PASS" : "FAIL", result, frame_hash, sword_hash, state_hash,
           capture_hash,
           palette_hash, (unsigned)town.event_count, town.town_text_record);
    printf("town_live_loop: frames=%u col=%02x start=%04x frame=%016llx "
           "npc_state=%016llx item=%04x npc=%04x door=%02x\n",
           (unsigned)live_frame_count, (u8)(initial_column + 1), live_start,
           live_frame_hash, live_npc_hash, town.facing_item_position,
           town.facing_npc_position, town.facing_door_type);
    printf("town_live_scroll: frames=%u col=%02x start=%04x frame=%016llx\n",
           (unsigned)town.frame_count, segments[0][0x0083], scrolled_start,
           scrolled_frame_hash);
    printf("VERDICT: %s: first 106TOWN castle frame service span\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
