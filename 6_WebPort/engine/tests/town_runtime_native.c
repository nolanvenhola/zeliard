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
