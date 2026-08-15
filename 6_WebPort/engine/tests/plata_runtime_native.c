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
    u8 *image = platform_load_asset("mp61.mdt", &size);
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
    prepare_player(game, 15, 30, 28);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("plata_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 256;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 6;
    ok &= zeliard_fight_masm_vm_music_chunk() == 91;
    ok &= monsters == 40 && items == 20 && families == 0x1E;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[60][16];
    for (unsigned object = 0; object < 60; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 60; ++object) {
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
    printf("plata_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;

    /* MP61 object nine is linked to stdply byte 2Ch/mask 80h. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 15, 30, 28);
    persistent_game[0x2C] = 0x80;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 persisted[16];
    for (unsigned byte = 0; byte < 16; ++byte)
        persisted[byte] = (u8)zeliard_fight_masm_vm_peek_u8(
            (u16)(persistent_objects + 9u * 16u + byte));
    printf("plata_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x hash=%016llx\n", persistent_objects,
           persisted[0], persisted[1], persisted[11], persisted[12],
           fnv1a64(persisted, sizeof(persisted)));
    ok &= persisted[0] == 0 && persisted[1] == 0xFF;
    ok &= persisted[11] == 0xFF && persisted[12] == 0xFF;

    /* MP61 and MP60 x30/y28 are an exact Plata/Tesoro reverse pair. */
    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 15, 30, 28);
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int entered = advance_frame(route_game, route_vga, 1);
    const u16 entered_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    route_game[0x80] = 30 - 16;
    route_game[0x81] = 0;
    route_game[0x82] = (28 - 9) & 0x3F;
    const int returned = advance_frame(route_game, route_vga, 1);
    printf("plata_tesoro_route_probe: entered=%d/%04x returned=%d "
           "width=%u music=%02x pos=%02x/%02x\n", entered,
           entered_objects, returned,
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), route_game[0x80],
           route_game[0x82]);
    ok &= entered && returned && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 256;
    ok &= zeliard_fight_masm_vm_music_chunk() == 91;

    /* MP61 x31/y5 is the authored high-bit Dorado town handoff. */
    static u8 town_game[0x10000], town_vga[0x10000];
    prepare_player(town_game, 15, 31, 5);
    town_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        town_game, sizeof(town_game), town_vga, sizeof(town_vga));
    const int town_handoff = advance_frame(town_game, town_vga, 1);
    printf("plata_dorado_handoff_probe: advanced=%d active=%d "
           "operation=%02x selector=%02x pos=%02x/%02x\n", town_handoff,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(), town_game[0x80],
           town_game[0x82]);
    ok &= town_handoff && !zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_exit_operation() == 1;
    ok &= zeliard_fight_masm_vm_exit_selector() == 0x86;

    ok &= first_frame == 0x8392713EDCEC5B4AULL;
    ok &= moving_frame == 0x3C4D197AEE469740ULL;

    printf("VERDICT: %s: Plata exact fight VM, persistence, and routes\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
