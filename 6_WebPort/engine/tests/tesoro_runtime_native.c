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
    u8 *image = platform_load_asset("mp60.mdt", &size);
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
    prepare_player(game, 14, 30, 28);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("tesoro_probe: started=%d active=%d frame=%d width=%u level=%u "
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
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 6;
    ok &= zeliard_fight_masm_vm_music_chunk() == 91;
    ok &= monsters == 45 && items == 16 && families == 0x1E;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[61][16];
    for (unsigned object = 0; object < 61; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 61; ++object) {
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
    printf("tesoro_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;

    /* MP60 object four is linked to stdply byte 2Ah/mask 80h. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 14, 30, 28);
    persistent_game[0x2A] = 0x80;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 persisted[16];
    for (unsigned byte = 0; byte < 16; ++byte)
        persisted[byte] = (u8)zeliard_fight_masm_vm_peek_u8(
            (u16)(persistent_objects + 4u * 16u + byte));
    printf("tesoro_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x hash=%016llx\n", persistent_objects,
           persisted[0], persisted[1], persisted[11], persisted[12],
           fnv1a64(persisted, sizeof(persisted)));
    ok &= persisted[0] == 0 && persisted[1] == 0xFF;
    ok &= persisted[11] == 0xFF && persisted[12] == 0xFF;

    /* MP60 and MP61 x30/y28 are an exact Tesoro/Plata reverse pair. */
    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 14, 30, 28);
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int entered = advance_frame(route_game, route_vga, 1);
    const u16 entered_width = zeliard_fight_masm_vm_peek_u16(0xC002);
    route_game[0x80] = 30 - 16;
    route_game[0x81] = 0;
    route_game[0x82] = (28 - 9) & 0x3F;
    const int returned = advance_frame(route_game, route_vga, 1);
    printf("tesoro_plata_route_probe: entered=%d/%u returned=%d width=%u "
           "music=%02x pos=%02x/%02x\n", entered, entered_width, returned,
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), route_game[0x80],
           route_game[0x82]);
    ok &= entered && returned && zeliard_fight_masm_vm_active();
    ok &= entered_width == 256;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 320;

    /* MP60 x309/y41 enters Tarso's MP6D chamber through the complete
     * release ROKA run and ENCOUNTER! sequence before LEGA dispatch. */
    static u8 boss_game[0x10000], boss_vga[0x10000];
    prepare_player(boss_game, 14, 309, 41);
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
    printf("tesoro_tarso_encounter_probe: ticks=%u start=%u music_at=%u "
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
    ok &= boss_game[0xC3] == 0;

    ok &= encounter_start == 7 && boss_music_frame == 58;
    ok &= encounter_finish == 114;
    ok &= first_frame == 0xC279435AE90D41A5ULL;
    ok &= moving_frame == 0xECADCE12E43E5BF4ULL;
    ok &= encounter_hash == 0x8E1B768A0AEC4C05ULL;
    ok &= chamber_hash == 0x4E95A8CA69455F86ULL;

    /* LEGA owns Tarso's 640-point damage word and all of its secondary
     * animation state. Drive the documented terminal state, then let its
     * release 28h-step death and completion path run unchanged. */
    printf("tarso_state_probe: damage=%04x phase=%02x/%02x/%02x/%02x "
           "death=%02x completion=%02x\n",
           zeliard_fight_masm_vm_peek_u16(0xA7A3),
           zeliard_fight_masm_vm_peek_u8(0xA7B9),
           zeliard_fight_masm_vm_peek_u8(0xA7BD),
           zeliard_fight_masm_vm_peek_u8(0xA7C0),
           zeliard_fight_masm_vm_peek_u8(0xA7C2),
           zeliard_fight_masm_vm_peek_u8(0xFF2E),
           zeliard_fight_masm_vm_peek_u8(0xFF30));
    ok &= zeliard_fight_masm_vm_peek_u16(0xA7A3) == 0x0280;
    /* Keep this terminal-state fixture focused on Tarso's death path; the
     * player-damage/death route has its own release-VM coverage. */
    boss_game[0x90] = boss_game[0xB2] = 0xFF;
    boss_game[0x91] = boss_game[0xB3] = 0x7F;
    ok &= zeliard_fight_masm_vm_poke_u16(0xA7A3, 0);
    for (u16 address = 0xA7B8; address <= 0xA7C8; ++address)
        ok &= zeliard_fight_masm_vm_poke_u8(address, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned tarso_frames = 0, tarso_completion = 0;
    unsigned long long tarso_completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && tarso_frames < 200 &&
           !tarso_completion) {
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga), 20, 0);
        ++tarso_frames;
        if (!tarso_completion &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            tarso_completion = tarso_frames;
            tarso_completion_hash = fnv1a64(boss_vga, 64000);
        }
    }
    printf("tarso_death_probe: frames=%u completion=%u timer=%02x "
           "defeated=%02x/%02x event=%02x hash=%016llx\n",
           tarso_frames, tarso_completion,
           zeliard_fight_masm_vm_peek_u8(0xA7B8), boss_game[0x28],
           boss_game[0x29], boss_game[0x2D], tarso_completion_hash);
    ok &= zeliard_fight_masm_vm_active();
    ok &= tarso_completion == 87;
    ok &= tarso_frames == 87;
    ok &= zeliard_fight_masm_vm_peek_u8(0xA7B8) == 0x28;
    ok &= tarso_completion_hash == 0xC659055DC800A0F6ULL;

    /* Defeated Tarso revisits retain the empty MP6D room but skip LEGA,
     * ENCOUNTER!, and the boss score, matching the release save word. */
    static u8 revisit_game[0x10000], revisit_vga[0x10000];
    prepare_player(revisit_game, 14, 309, 41);
    revisit_game[0x98] = 1;
    revisit_game[0x28] = revisit_game[0x29] = 0xFF;
    revisit_game[0x2D] = 0x10;
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
    printf("tarso_revisit_probe: frames=%u chamber=%u boss_music=%u "
           "active=%d width=%u music=%02x selector=%02x\n",
           revisit_frames, revisit_chamber, revisit_boss_music,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), revisit_game[0xC4]);
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= zeliard_fight_masm_vm_music_chunk() == 91;
    ok &= revisit_game[0xC4] == 0x11;
    ok &= revisit_chamber > 0 && revisit_boss_music == 0;

    printf("VERDICT: %s: Tesoro exact fight VM, persistence, and Tarso handoff\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
