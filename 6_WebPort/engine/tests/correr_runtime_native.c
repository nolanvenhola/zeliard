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
    game[0x90] = 0;
    game[0x91] = 2;
    game[0xB2] = 0;
    game[0xB3] = 2;
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
    u8 *image = platform_load_asset("mp72.mdt", &size);
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
    prepare_player(game, 20, 64, 30);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("correr_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 128;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 7;
    ok &= zeliard_fight_masm_vm_music_chunk() == 92;
    ok &= monsters == 14 && items == 3 && families == 0x10;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[17][16];
    for (unsigned object = 0; object < 17; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 17; ++object) {
        const u8 family = before[object][4];
        if (!before[object][14] || family < 1 || family > 8) continue;
        for (unsigned byte = 0; byte < 16; ++byte)
            if (zeliard_fight_masm_vm_peek_u8(
                    (u16)(objects + object * 16u + byte)) != before[object][byte]) {
                changed_families |= 1u << family;
                break;
            }
    }
    const unsigned long long moving_frame = fnv1a64(vga, 64000);
    printf("correr_movement_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x10;

    /* MP72 object four is tied to stdply byte 35h/mask 04h. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 20, 64, 30);
    persistent_game[0x35] = 0x04;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 persisted = (u16)(persistent_objects + 4u * 16u);
    printf("correr_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x\n", persistent_objects,
           zeliard_fight_masm_vm_peek_u8(persisted),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 1)),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 11)),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 12)));
    ok &= zeliard_fight_masm_vm_peek_u8(persisted) == 0;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 1)) == 0xFF;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 11)) == 0xFF;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 12)) == 0xFF;

    /* MP72 x50/y8 enters Caliente; MP70 x83/y1 is the exact reverse. */
    static u8 forward_game[0x10000], forward_vga[0x10000];
    prepare_player(forward_game, 20, 50, 8);
    forward_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        forward_game, sizeof(forward_game), forward_vga, sizeof(forward_vga));
    const int forward = advance_frame(forward_game, forward_vga, 1);
    const u16 forward_width = zeliard_fight_masm_vm_peek_u16(0xC002);

    static u8 reverse_game[0x10000], reverse_vga[0x10000];
    prepare_player(reverse_game, 18, 83, 1);
    reverse_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        reverse_game, sizeof(reverse_game), reverse_vga, sizeof(reverse_vga));
    const int reverse = advance_frame(reverse_game, reverse_vga, 1);
    printf("correr_caliente_route_probe: forward=%d/%u reverse=%d/%u "
           "music=%02x\n", forward, forward_width, reverse,
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk());
    ok &= forward && reverse && zeliard_fight_masm_vm_active();
    ok &= forward_width == 208;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 128;

    /* Despite the generated inventory's heuristic label, MP72 x25/y40 is
     * a free Reaccion route: release MASM crosses with no key and does not
     * consume a carried normal key. */
    static u8 locked_game[0x10000], locked_vga[0x10000];
    prepare_player(locked_game, 20, 25, 40);
    locked_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        locked_game, sizeof(locked_game), locked_vga, sizeof(locked_vga));
    const int no_key = advance_frame(locked_game, locked_vga, 1);
    const u16 no_key_width = zeliard_fight_masm_vm_peek_u16(0xC002);

    static u8 key_game[0x10000], key_vga[0x10000];
    prepare_player(key_game, 20, 25, 40);
    key_game[0x98] = 1;
    key_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        key_game, sizeof(key_game), key_vga, sizeof(key_vga));
    const int carried = advance_frame(key_game, key_vga, 1);
    printf("correr_reaccion_free_route_probe: no_key=%d/%u carried=%d/%u key=%u\n",
           no_key, no_key_width, carried,
           zeliard_fight_masm_vm_peek_u16(0xC002), key_game[0x98]);
    ok &= no_key && no_key_width == 196;
    ok &= carried && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 196;
    ok &= key_game[0x98] == 1;

    ok &= first_frame == 0x222C18F8DF1EAB6BULL;
    ok &= moving_frame == 0x5A7517354DC68A7EULL;

    printf("correr_hash_contract: first=%016llx moving=%016llx\n",
           first_frame, moving_frame);
    printf("VERDICT: %s: Correr exact family-4 movement, persistence, and routes\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
