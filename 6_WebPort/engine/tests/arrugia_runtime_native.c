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
    u8 *image = platform_load_asset("mp62.mdt", &size);
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
    prepare_player(game, 16, 55, 39);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("arrugia_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 6;
    ok &= zeliard_fight_masm_vm_music_chunk() == 91;
    ok &= monsters == 0 && items == 28 && families == 0;
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    const unsigned long long moving_frame = fnv1a64(vga, 64000);
    printf("arrugia_idle_probe: frame=%016llx\n", moving_frame);

    /* MP62 objects 22..27 are the six persistent treasure/stash records.
     * Save bytes 2Ch/2Dh must remove every collected/opened record on load. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 16, 55, 39);
    persistent_game[0x2C] = 0x0F;
    persistent_game[0x2D] = 0xC0;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    unsigned removed = 0;
    for (unsigned object = 22; object <= 27; ++object) {
        const u16 at = (u16)(objects + object * 16u);
        const u8 head0 = (u8)zeliard_fight_masm_vm_peek_u8(at);
        const u8 head1 = (u8)zeliard_fight_masm_vm_peek_u8((u16)(at + 1));
        const u8 link0 = (u8)zeliard_fight_masm_vm_peek_u8((u16)(at + 11));
        const u8 link1 = (u8)zeliard_fight_masm_vm_peek_u8((u16)(at + 12));
        removed += head0 == 0 && head1 == 0xFF &&
                   link0 == 0xFF && link1 == 0xFF;
    }
    printf("arrugia_persistence_probe: objects=%04x removed=%u state=%02x/%02x\n",
           objects, removed, persistent_game[0x2C], persistent_game[0x2D]);
    ok &= removed == 6;

    /* Tesoro x31/y5 is the keyed entrance.  A missing key leaves the
     * player in MP60; one Lion key is consumed by the authored door. */
    static u8 locked_game[0x10000], locked_vga[0x10000];
    prepare_player(locked_game, 14, 31, 5);
    locked_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        locked_game, sizeof(locked_game), locked_vga, sizeof(locked_vga));
    const int locked = advance_frame(locked_game, locked_vga, 1);
    const unsigned locked_width = zeliard_fight_masm_vm_peek_u16(0xC002);

    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 14, 31, 5);
    route_game[0x99] = 1;
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int returned = advance_frame(route_game, route_vga, 1);
    printf("arrugia_tesoro_entry_probe: locked=%d/%u entered=%d key=%u "
           "active=%d width=%u pos=%02x/%02x\n", locked, locked_width,
           returned, route_game[0x99], zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002), route_game[0x80],
           route_game[0x82]);
    ok &= locked && locked_width == 320;
    ok &= returned && zeliard_fight_masm_vm_active();
    ok &= route_game[0x99] == 0;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 320;

    /* Arrugia's reverse x62/y13 door must remain usable without consuming
     * another Lion key, so the player cannot be trapped in the secret. */
    static u8 return_game[0x10000], return_vga[0x10000];
    prepare_player(return_game, 16, 62, 13);
    return_game[0x99] = 1;
    return_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        return_game, sizeof(return_game), return_vga, sizeof(return_vga));
    const int free_return = advance_frame(return_game, return_vga, 1);
    printf("arrugia_free_return_probe: returned=%d key=%u active=%d width=%u\n",
           free_return, return_game[0x99], zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002));
    ok &= free_return && zeliard_fight_masm_vm_active();
    ok &= return_game[0x99] == 1;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 320;

    /* MP62 x40/y37 is the exact boundary to selector 17h.  Because MP80 is
     * another supported cavern, the release VM loads it in place and keeps
     * running; only a town/external overlay handoff makes the VM inactive. */
    static u8 boundary_game[0x10000], boundary_vga[0x10000];
    prepare_player(boundary_game, 16, 40, 37);
    boundary_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boundary_game, sizeof(boundary_game), boundary_vga,
        sizeof(boundary_vga));
    const int boundary = advance_frame(boundary_game, boundary_vga, 1);
    printf("arrugia_boundary_probe: advanced=%d active=%d width=%u area=%u "
           "operation=%02x selector=%02x pos=%02x/%02x\n", boundary,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(), boundary_game[0x80],
           boundary_game[0x82]);
    ok &= boundary && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 256;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 8;
    ok &= boundary_game[0x80] == 57 - 16;
    ok &= boundary_game[0x82] == ((57 - 9) & 0x3F);

    ok &= first_frame == 0x721F19A2356F535AULL;
    ok &= moving_frame == 0xDBDAA9CDD3F773D7ULL;

    printf("VERDICT: %s: Arrugia exact fight VM, persistence, and routes\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
