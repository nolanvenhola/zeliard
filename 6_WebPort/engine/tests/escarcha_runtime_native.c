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

static int map_shape(const char *asset, unsigned *monsters,
                     unsigned *items, unsigned *families) {
    size_t size = 0;
    u8 *image = platform_load_asset(asset, &size);
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

    /* Helada's right boundary enters the authored Escarcha MP41 map. */
    prepare_player(game, 9, 16, 21);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape("mp41.mdt", &monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("escarcha_probe: started=%d active=%d frame_ready=%d width=%u "
           "level=%u music=%02x objects=%u/%u families=%02x "
           "pos=%02x/%02x/%02x frame=%016llx\n", started,
           zeliard_fight_masm_vm_active(), zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           game[0x80], game[0x82], game[0x83], first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 192;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 4;
    ok &= zeliard_fight_masm_vm_music_chunk() == 89;
    ok &= monsters == 14 && items == 22 && families == 0x1E;
    ok &= first_frame == 0x2F08B58A5CC7DBBDULL;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[36][16];
    for (unsigned object = 0; object < 36; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 36; ++object) {
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
    printf("escarcha_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;
    ok &= moving_frame == 0x5163F144DB63E65AULL;

    /* process_map_seg_updates consumes MP41 object six's 1Bh/20h link. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 9, 16, 21);
    persistent_game[0x1B] = 0x20;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 persisted[16];
    for (unsigned byte = 0; byte < 16; ++byte)
        persisted[byte] = (u8)zeliard_fight_masm_vm_peek_u8(
            (u16)(persistent_objects + 6u * 16u + byte));
    printf("escarcha_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x hash=%016llx\n", persistent_objects,
           persisted[0], persisted[1], persisted[11], persisted[12],
           fnv1a64(persisted, sizeof(persisted)));
    ok &= persisted[0] == 0 && persisted[1] == 0xFF;
    ok &= persisted[11] == 0xFF && persisted[12] == 0xFF;
    ok &= fnv1a64(persisted, sizeof(persisted)) ==
        0xD3D427FD080FAAD3ULL;

    /* MP41 x56/y55 and MP40 x22/y9 are a paired reverse/forward route. */
    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 9, 56, 55);
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int entered = advance_frame(route_game, route_vga, 1);
    const u16 entered_width =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC002);
    route_game[0x80] = 22 - 16;
    route_game[0x81] = 0;
    route_game[0x82] = 0;
    const int returned = advance_frame(route_game, route_vga, 1);
    const u16 returned_width =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC002);
    printf("escarcha_route_probe: entered=%d/%u returned=%d/%u active=%d "
           "music=%02x pos=%02x/%02x/%02x\n", entered, entered_width,
           returned, returned_width, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_music_chunk(), route_game[0x80],
           route_game[0x82], route_game[0x83]);
    ok &= entered && returned && zeliard_fight_masm_vm_active();
    ok &= entered_width == 320 && returned_width == 192;
    ok &= zeliard_fight_masm_vm_music_chunk() == 89;

    /* Ruzeria is selected_accessory ID 4.  The exact release routine gates
     * Area-4 slide/inertia at 200FIGHT:gate_area4_no_accessory4. */
    static u8 bare_game[0x10000], bare_vga[0x10000];
    static u8 shoes_game[0x10000], shoes_vga[0x10000];
    prepare_player(bare_game, 9, 16, 21);
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        bare_game, sizeof(bare_game), bare_vga, sizeof(bare_vga));
    for (unsigned frame = 0; frame < 12; ++frame)
        ok &= advance_frame(bare_game, bare_vga, frame < 4 ? 8 : 0);
    const u16 bare_x = read_u16(bare_game, 0x80);
    const u8 bare_axis = (u8)zeliard_fight_masm_vm_peek_u8(0xE5);
    prepare_player(shoes_game, 9, 16, 21);
    shoes_game[0x9E] = 4;
    shoes_game[0xA1] = 4;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        shoes_game, sizeof(shoes_game), shoes_vga, sizeof(shoes_vga));
    for (unsigned frame = 0; frame < 12; ++frame)
        ok &= advance_frame(shoes_game, shoes_vga, frame < 4 ? 8 : 0);
    const u16 shoes_x = read_u16(shoes_game, 0x80);
    const u8 shoes_axis = (u8)zeliard_fight_masm_vm_peek_u8(0xE5);
    printf("escarcha_ruzeria_probe: bare=%04x/%02x shoes=%04x/%02x\n",
           bare_x, bare_axis, shoes_x, shoes_axis);
    ok &= bare_x != shoes_x || bare_axis != shoes_axis;
    ok &= bare_x == 0x0006 && shoes_x == 0x0004;

    printf("VERDICT: %s: Escarcha exact fight VM resources and ice route\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
