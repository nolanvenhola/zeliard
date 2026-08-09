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
    u8 *image = platform_load_asset("mp51.mdt", &size);
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
    prepare_player(game, 12, 9, 25);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("cementar_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 240;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 5;
    ok &= zeliard_fight_masm_vm_music_chunk() == 90;
    ok &= monsters == 36 && items == 34 && families == 0x1E;
    ok &= first_frame == 0x8FFD874A333A26D8ULL;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[70][16];
    for (unsigned object = 0; object < 70; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 70; ++object) {
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
    printf("cementar_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;
    ok &= moving_frame == 0xBF272AE6914819DFULL;

    /* MP51 x88/y34 and MP50 x88/y34 are an exact reverse door pair. */
    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 12, 88, 34);
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int entered = advance_frame(route_game, route_vga, 1);
    const u16 entered_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    route_game[0x80] = 88 - 16;
    route_game[0x81] = 0;
    route_game[0x82] = (34 - 9) & 0x3F;
    const int returned = advance_frame(route_game, route_vga, 1);
    printf("cementar_route_probe: entered=%d/%04x returned=%d width=%u "
           "music=%02x pos=%02x/%02x\n", entered, entered_objects,
           returned, zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), route_game[0x80],
           route_game[0x82]);
    ok &= entered && returned && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 240;

    static u8 boss_game[0x10000], boss_vga[0x10000];
    prepare_player(boss_game, 12, 157, 16);
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
        if (!encounter_start &&
            zeliard_fight_masm_vm_peek_u16(0xC002) == 73)
            encounter_start = ticks;
        if (!boss_music_frame && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music_frame = ticks;
        if (encounter_start && !encounter_finish &&
            zeliard_fight_masm_vm_at_frame()) encounter_finish = ticks;
        if (ticks == 56) encounter_hash = fnv1a64(boss_vga, 64000);
        if (ticks == 180) chamber_hash = fnv1a64(boss_vga, 64000);
    }
    printf("cementar_vista_encounter_probe: ticks=%u start=%u music_at=%u "
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
    ok &= encounter_hash == 0x45FF2A0E6F888B11ULL;
    ok &= chamber_hash == 0xEAC3EE032BB88481ULL;

    /* MEDA owns Vista's 700-point damage word and phase/death state. Drive
     * only its documented terminal state, leaving the original 28h-step
     * death FSM and 200FIGHT completion/persistence path intact. */
    printf("vista_state_probe: damage=%04x phase=%02x/%02x/%02x/%02x "
           "death=%02x completion=%02x shutdown=%04x\n",
           zeliard_fight_masm_vm_peek_u16(0xA719),
           zeliard_fight_masm_vm_peek_u8(0xA72F),
           zeliard_fight_masm_vm_peek_u8(0xA734),
           zeliard_fight_masm_vm_peek_u8(0xA735),
           zeliard_fight_masm_vm_peek_u8(0xA736),
           zeliard_fight_masm_vm_peek_u8(0xFF2E),
           zeliard_fight_masm_vm_peek_u8(0xFF30),
           zeliard_fight_masm_vm_peek_u16(0x603C));
    ok &= zeliard_fight_masm_vm_peek_u16(0xA719) == 0x02BC;
    ok &= zeliard_fight_masm_vm_peek_u16(0x603C) == 0x83DB;
    ok &= zeliard_fight_masm_vm_poke_u16(0xA719, 0);
    for (u16 address = 0xA72F; address <= 0xA737; ++address)
        ok &= zeliard_fight_masm_vm_poke_u8(address, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned vista_frames = 0, vista_completion = 0;
    unsigned long long vista_completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && vista_frames < 400 &&
           !(boss_game[0x20] == 0xFF && boss_game[0x21] == 0xFF)) {
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga), 20, 0);
        ++vista_frames;
        if (!vista_completion &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            vista_completion = vista_frames;
            vista_completion_hash = fnv1a64(boss_vga, 64000);
        }
    }
    printf("vista_death_probe: frames=%u completion=%u timer=%02x "
           "defeated=%02x/%02x event=%02x hash=%016llx\n",
           vista_frames, vista_completion,
           zeliard_fight_masm_vm_peek_u8(0xA733), boss_game[0x20],
           boss_game[0x21], boss_game[0x24], vista_completion_hash);
    ok &= vista_completion == 295;
    ok &= vista_frames == 317;
    ok &= vista_completion_hash == 0x12D2EFB6554132B3ULL;
    ok &= boss_game[0x20] == 0xFF && boss_game[0x21] == 0xFF;

    /* A persisted defeated word still enters the authored empty MP5D room,
     * while suppressing MEDA, ENCOUNTER!, and the boss music switch. */
    static u8 revisit_game[0x10000], revisit_vga[0x10000];
    prepare_player(revisit_game, 12, 157, 16);
    revisit_game[0x98] = 1;
    revisit_game[0x20] = revisit_game[0x21] = 0xFF;
    revisit_game[0x24] = 0x04;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        revisit_game, sizeof(revisit_game), revisit_vga,
        sizeof(revisit_vga));
    unsigned revisit_frames = 0, revisit_chamber = 0;
    unsigned revisit_boss_music = 0;
    while (zeliard_fight_masm_vm_active() && revisit_frames < 180) {
        ok &= advance_frame(revisit_game, revisit_vga,
                            revisit_chamber ? 0 : 1);
        ++revisit_frames;
        const u16 width = zeliard_fight_masm_vm_peek_u16(0xC002);
        if (!revisit_chamber && width == 73) revisit_chamber = revisit_frames;
        if (zeliard_fight_masm_vm_music_chunk() == 94)
            revisit_boss_music = revisit_frames;
    }
    printf("vista_revisit_probe: frames=%u chamber=%u boss_music=%u "
           "active=%d width=%u music=%02x selector=%02x\n",
           revisit_frames, revisit_chamber, revisit_boss_music,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), revisit_game[0xC4]);
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= zeliard_fight_masm_vm_music_chunk() == 90;
    ok &= revisit_game[0xC4] == 0x0D;
    ok &= revisit_chamber > 0 && revisit_boss_music == 0;

    printf("VERDICT: %s: Cementar exact fight VM and Vista handoff\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
