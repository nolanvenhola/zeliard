#include "../game/town_runtime.h"
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
        load_font(segments[0]);
    ok &= facing_town.facing_item_position == 0x002F;
    ok &= facing_town.facing_npc_position == 0x0030;
    ok &= facing_town.facing_door_type == 0x07;
    ok &= facing_fixture[0xFF1D] == 0;
    const int result = ok ? zeliard_town_enter_first_frame(
        &town, &game, vga, sizeof(vga)) : -99;
    ok &= result == 0;
    const unsigned long long frame_hash = fnv1a64(vga, sizeof(vga));
    const unsigned long long state_hash = selected_state_hash(segments[0]);
    const unsigned long long capture_hash = fnv1a64(segments[0] + 0xA000, 0x1500);
    const unsigned long long palette_hash = fnv1a64((const u8 *)g_palette,
                                                    sizeof(g_palette));
    printf("town_mman_banks: pixels=%016llx masks=%016llx\n",
           fnv1a64(segments[1] + 0x4100, 0x1EC0),
           fnv1a64(segments[2] + 0x7000, 0x0520));
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
    ok &= frame_hash == 0x1FA483016782AFECULL;
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
    ok &= town.building_transition == ZEL_TOWN_BUILDING_TRANSITION_ENTER;
    ok &= town.pending_room_kind == ZEL_ROOM_VIEWING;
    ok &= memcmp(town.room.saved_vga, vga, sizeof(vga)) == 0;
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
    printf("town_viewing_room: position=%04x frame=%016llx "
           "artwork=%016llx entered=%d\n", viewing_position,
           viewing_frame_hash, viewing_artwork_hash, viewing_fade_frames);
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
        0xC7A9AAD199FEB82EULL, 0x2DF829B1230E73A3ULL,
        0x312DDFEB392959C3ULL, 0xC2202A1FE9149790ULL,
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
    ok &= idle_frame_hash_1 == 0x26D0E4434D4F9C14ULL;
    ok &= idle_npc_hash_1 == 0x7AEF6E1921E0C970ULL;
    ok &= idle_frame_hash_2 == 0xE3CDA193615CB7A5ULL;
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
    ok &= live_frame_hash == 0xDC19F817A64D52F1ULL;
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
    ok &= scrolled_frame_hash == 0x09576E5990854B01ULL;
    printf("town_runtime: %s rc=%d frame=%016llx state=%016llx "
           "capture=%016llx palette=%016llx events=%u text=%04x\n",
           ok ? "PASS" : "FAIL", result, frame_hash, state_hash, capture_hash,
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
