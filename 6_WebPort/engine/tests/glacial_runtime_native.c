#include "../game/fight_masm_vm.h"
#include "../render/palette.h"
#include "../platform/platform.h"

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

static u16 read_u16(const u8 *data, size_t offset) {
    return (u16)(data[offset] | ((u16)data[offset + 1] << 8));
}

static void prepare_player(u8 *game, u8 selector, u16 x, u8 y) {
    memset(game, 0, 0x10000);
    game[0x80] = (u8)(x - 16u);
    game[0x81] = (u8)((x - 16u) >> 8);
    game[0x82] = (u8)((y - 9u) & 0x3Fu);
    game[0x83] = 12;
    game[0x91] = 1;
    game[0xB3] = 1;
    game[0xC4] = selector;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

static int advance_frame(u8 *game, u8 *vga, u8 direction) {
    for (unsigned attempt = 0; attempt < 256; ++attempt) {
        const int rendered = zeliard_fight_masm_vm_advance(
            game, 0x10000, vga, 0x10000, 20, direction);
        if (!zeliard_fight_masm_vm_active() ||
            zeliard_fight_masm_vm_at_frame()) return rendered;
    }
    return 0;
}

static int map_shape(unsigned *monsters, unsigned *items,
                     unsigned *families) {
    size_t size = 0;
    u8 *image = platform_load_asset("mp40.mdt", &size);
    if (!image || size < 4 + 0x12) { free(image); return 0; }
    const u8 *map = image + 4;
    size_t at = 4u + (size_t)(read_u16(map, 0x10) - 0xC000u);
    *monsters = *items = *families = 0;
    while (at + 16 <= size && read_u16(image, at) != 0xFFFF) {
        const u8 *row = image + at;
        if (row[14]) {
            ++*monsters;
            if (row[4] >= 1 && row[4] <= 8) *families |= 1u << row[4];
        } else {
            ++*items;
        }
        at += 16;
    }
    free(image);
    return 1;
}

int main(void) {
    static u8 game[0x10000], vga[0x10000];
    int ok = 1;
    prepare_player(game, 8, 22, 9);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("glacial_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 320;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 4;
    ok &= zeliard_fight_masm_vm_music_chunk() == 89;
    ok &= monsters == 38 && items == 31 && families == 0x1E;
    ok &= first_frame == 0xCDE0F82110F4E359ULL;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[69][16];
    for (unsigned object = 0; object < 69; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 69; ++object) {
        const u8 family = before[object][4];
        if (!before[object][14] || family < 1 || family > 8) continue;
        for (unsigned byte = 0; byte < 16; ++byte)
            if (zeliard_fight_masm_vm_peek_u8(
                    (u16)(objects + object * 16u + byte)) !=
                    before[object][byte]) {
                changed_families |= 1u << family;
                break;
            }
    }
    const unsigned long long moving_frame = fnv1a64(vga, 64000);
    printf("glacial_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;
    ok &= moving_frame == 0x8560A7508B342550ULL;

    /* MP40 object zero is backed by stdply byte 1Ah/mask 80h.  The release
     * map update must delete it on re-entry. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 8, 22, 9);
    persistent_game[0x1A] = 0x80;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 persisted[16];
    for (unsigned byte = 0; byte < 16; ++byte)
        persisted[byte] = (u8)zeliard_fight_masm_vm_peek_u8(
            (u16)(persistent_objects + byte));
    printf("glacial_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x hash=%016llx\n", persistent_objects,
           persisted[0], persisted[1], persisted[11], persisted[12],
           fnv1a64(persisted, sizeof(persisted)));
    ok &= persisted[0] == 0 && persisted[1] == 0xFF;
    ok &= persisted[11] == 0xFF && persisted[12] == 0xFF;

    /* The MP40 x224/y18 door enters MP4D.  Release 200FIGHT performs the
     * directional run, ENCOUNTER! sequence, boss-score switch, and exact
     * ZELA code/sprite loads before returning a stable chamber frame. */
    static u8 boss_game[0x10000], boss_vga[0x10000];
    prepare_player(boss_game, 8, 224, 18);
    boss_game[0x98] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga));
    unsigned ticks = 0, encounter_start = 0, encounter_finish = 0;
    unsigned boss_music_frame = 0;
    unsigned long long encounter_hash = 0, chamber_hash = 0;
    while (zeliard_fight_masm_vm_active() && ticks < 220) {
        const u8 direction = encounter_start ? 0 : 1;
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga),
            20, direction);
        ++ticks;
        const u16 width = zeliard_fight_masm_vm_peek_u16(0xC002);
        if (!encounter_start && width == 73) encounter_start = ticks;
        if (!boss_music_frame && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music_frame = ticks;
        if (encounter_start && !encounter_finish &&
            zeliard_fight_masm_vm_at_frame()) encounter_finish = ticks;
        if (ticks == 56) encounter_hash = fnv1a64(boss_vga, 64000);
        if (ticks == 180) chamber_hash = fnv1a64(boss_vga, 64000);
    }
    printf("glacial_agar_encounter_probe: ticks=%u start=%u music_at=%u "
           "finish=%u active=%d width=%u music=%02x intro=%02x "
           "hashes=%016llx/%016llx\n", ticks, encounter_start,
           boss_music_frame, encounter_finish,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), boss_game[0xC3],
           encounter_hash, chamber_hash);
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= encounter_start && boss_music_frame && encounter_finish;
    ok &= encounter_start == 7 && boss_music_frame == 58;
    ok &= encounter_finish == 114 && boss_game[0xC3] == 0;
    ok &= encounter_hash == 0x9F32E6CE4CA27519ULL;
    ok &= chamber_hash == 0x16FCB1BA7C156A8AULL;

    printf("VERDICT: %s: Glacial exact fight VM and Agar handoff\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
