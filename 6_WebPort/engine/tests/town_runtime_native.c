#include "../game/town_runtime.h"
#include "../load/fill_buffer.h"
#include "../render/palette.h"

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
    ok &= frame_hash == 0x5FFA5500A462B8EFULL;
    ok &= state_hash == 0xE79422416064A11CULL;
    ok &= capture_hash == 0x437AEC553ACB4725ULL;
    ok &= palette_hash == 0xF0597D78ABA0CC75ULL;
    ok &= fnv1a64(vga + 0xFA00, 0x180) == 0xF5ED4A7A119DE3ECULL;
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
    ok &= live_frame_hash == 0x0711CC9604513081ULL;
    ok &= live_npc_hash == 0x653529AFD9704EF2ULL;
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
    ok &= scrolled_frame_hash == 0xDC2FED8396064996ULL;
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
