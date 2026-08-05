#include "../game/fight_masm_vm.h"
#include "../render/palette.h"
#include "../platform/platform.h"

#include <stdio.h>
#include <stdlib.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static u16 read_u16(const u8 *data, u16 offset) {
    return (u16)(data[offset] | ((u16)data[(u16)(offset + 1)] << 8));
}

static int advance_release_frame(u8 *game, size_t game_size, u8 *vga,
                                 size_t vga_size, u32 frames, u8 direction) {
    for (unsigned attempt = 0; attempt < 256; ++attempt) {
        const int advanced = zeliard_fight_masm_vm_advance(
            game, game_size, vga, vga_size, frames * 20u, direction);
        if (!zeliard_fight_masm_vm_active()) return advanced;
        if (zeliard_fight_masm_vm_at_frame()) return 1;
    }
    return 0;
}

static int advance_pit(u8 *game, size_t game_size, u8 *vga,
                       size_t vga_size, u32 ticks, u8 direction) {
    return zeliard_fight_masm_vm_advance(
        game, game_size, vga, vga_size, ticks, direction);
}

/* Existing scenarios count release gameplay frames, not browser refreshes. */
#define zeliard_fight_masm_vm_advance advance_release_frame

static int write_visual_fixture(const char *path, const u8 *vga) {
    FILE *ppm = fopen(path, "wb");
    if (!ppm) return 0;
    fputs("P6\n320 200\n255\n", ppm);
    for (unsigned i = 0; i < 64000; ++i) {
        fputc(g_palette[vga[i]].r, ppm);
        fputc(g_palette[vga[i]].g, ppm);
        fputc(g_palette[vga[i]].b, ppm);
    }
    return fclose(ppm) == 0;
}

int main(void) {
    static u8 cadence_game[0x10000];
    static u8 cadence_vga[0x10000];
    cadence_game[0x0080] = 0x2D;
    cadence_game[0x0082] = 0x3D;
    cadence_game[0x0090] = 0x00;
    cadence_game[0x0091] = 0x01;
    cadence_game[0x00B2] = 0x00;
    cadence_game[0x00B3] = 0x01;
    cadence_game[0xFF33] = 5;
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        cadence_game, sizeof(cadence_game), cadence_vga,
        sizeof(cadence_vga));
    const int cadence_started_at_frame = zeliard_fight_masm_vm_at_frame();
    const int cadence_speed = zeliard_fight_masm_vm_peek_u8(0xFF33);
    ok &= cadence_started_at_frame && cadence_speed == 5;
    const u8 cadence_x = cadence_game[0x80];
    const int early_frame = advance_pit(
        cadence_game, sizeof(cadence_game), cadence_vga,
        sizeof(cadence_vga), 19, 8);
    ok &= !early_frame && cadence_game[0x80] == cadence_x;
    const int gated_frame = advance_pit(
        cadence_game, sizeof(cadence_game), cadence_vga,
        sizeof(cadence_vga), 1, 8);
    ok &= gated_frame;
    for (unsigned attempt = 0; attempt < 256 &&
            !zeliard_fight_masm_vm_at_frame(); ++attempt) {
        advance_pit(
            cadence_game, sizeof(cadence_game), cadence_vga,
            sizeof(cadence_vga), 0, 8);
    }
    ok &= cadence_game[0x80] == (u8)(cadence_x + 1u);
    printf("malicia_cadence: start=%d speed=%02x early=%d gated=%d pos=%02x/%02x expected=%02x ok=%d\n",
           cadence_started_at_frame, cadence_speed,
           early_frame, gated_frame, cadence_x, cadence_game[0x80],
           (u8)(cadence_x + 1u), ok);

    static u8 game[0x10000];
    static u8 vga[0x10000];
    game[0x0080] = 0x2D;
    game[0x0082] = 0x3D;
    game[0x0090] = 0x00;
    game[0x0091] = 0x01;
    game[0x00B2] = 0x00;
    game[0x00B3] = 0x01;
    game[0x00C3] = 0;
    game[0x00C4] = 0;
    game[0xFF33] = 5;
    palette_set_game_mcga();

    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    const unsigned long long first_palette =
        fnv1a64((const u8 *)g_palette, sizeof(g_palette));
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_ip() == 0x629C;
    ok &= first_frame == 0x8500AA3694C8DDEBULL;
    ok &= first_palette == 0xF0597D78ABA0CC75ULL;
    ok &= write_visual_fixture("build/malicia-first-frame.ppm", vga);

    const u16 object_list = read_u16(game, 0xC010);
    unsigned monsters = 0;
    unsigned items = 0;
    unsigned family_mask = 0;
    size_t map_size = 0;
    u8 *map = platform_load_asset("mp10.mdt", &map_size);
    if (!map || map_size < 4 + 0x162E + 54 * 16) {
        ok = 0;
    } else {
        const u16 raw_object_list = read_u16(map + 4, 0x10);
        const size_t records = 4u + (size_t)(raw_object_list - 0xC000u);
        for (unsigned i = 0; i < 54; ++i) {
            const u8 *record = map + records + i * 16;
            if (record[14]) {
                ++monsters;
                if (record[4] >= 1 && record[4] <= 4)
                    family_mask |= 1u << record[4];
            } else {
                ++items;
            }
        }
    }
    free(map);
    ok &= read_u16(game, 0xC002) == 240;
    ok &= object_list == 0xD62E;
    ok &= monsters == 36;
    ok &= items == 18;
    ok &= family_mask == 0x0E;

    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 1, 8);

    const unsigned long long moving_frame = fnv1a64(vga, 64000);
    const u8 moving_x = game[0x80];
    const u8 moving_row = game[0x82];
    ok &= zeliard_fight_masm_vm_ip() == 0x629C;
    ok &= game[0x80] == 0x37;
    ok &= game[0x82] == 0x3D;
    ok &= game[0xC2] == 0x02;
    ok &= game[0xE7] == 0x0A;
    ok &= moving_frame == 0x6DF79A2F0D5A685EULL;

    printf("malicia_runtime: first=%016llx palette=%016llx "
           "moving=%016llx pos=%02x/%02x objects=%u/%u families=%02x ip=%04x\n",
           first_frame, first_palette, moving_frame,
           moving_x, moving_row, monsters, items, family_mask,
           zeliard_fight_masm_vm_ip());
    static u8 exit_game[0x10000];
    static u8 exit_vga[0x10000];
    exit_game[0x0080] = 0x2D;
    exit_game[0x0082] = 0x3D;
    exit_game[0x0090] = 0x00;
    exit_game[0x0091] = 0x01;
    exit_game[0x00B2] = 0x00;
    exit_game[0x00B3] = 0x01;
    exit_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        exit_game, sizeof(exit_game), exit_vga, sizeof(exit_vga));
    unsigned exit_frames = 0;
    while (zeliard_fight_masm_vm_active() && exit_frames < 120) {
        zeliard_fight_masm_vm_advance(
            exit_game, sizeof(exit_game), exit_vga, sizeof(exit_vga), 1, 1);
        ++exit_frames;
    }
    ok &= !zeliard_fight_masm_vm_active();
    ok &= exit_frames == 1;
    ok &= zeliard_fight_masm_vm_exit_operation() == 1;
    ok &= zeliard_fight_masm_vm_exit_selector() == 0x81;
    printf("malicia_muralla_exit: active=%d frames=%u operation=%02x "
           "selector=%02x dispatch=%04x pos=%02x/%02x ip=%04x\n",
           zeliard_fight_masm_vm_active(), exit_frames,
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(),
           zeliard_fight_masm_vm_exit_dispatch_slot(), exit_game[0x80],
           exit_game[0x82], zeliard_fight_masm_vm_ip());

    static u8 outbound_game[0x10000];
    static u8 outbound_vga[0x10000];
    outbound_game[0x0080] = 95 - 16;
    outbound_game[0x0082] = (50 - 9) & 0x3F;
    outbound_game[0x0090] = 0x00;
    outbound_game[0x0091] = 0x01;
    outbound_game[0x0099] = 1;
    outbound_game[0x00B2] = 0x00;
    outbound_game[0x00B3] = 0x01;
    outbound_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        outbound_game, sizeof(outbound_game), outbound_vga,
        sizeof(outbound_vga));
    unsigned outbound_frames = 0;
    while (zeliard_fight_masm_vm_active() && outbound_frames < 20) {
        zeliard_fight_masm_vm_advance(
            outbound_game, sizeof(outbound_game), outbound_vga,
            sizeof(outbound_vga), 1, 1);
        ++outbound_frames;
    }
    ok &= !zeliard_fight_masm_vm_active();
    ok &= outbound_frames == 1;
    ok &= zeliard_fight_masm_vm_exit_operation() == 1;
    ok &= zeliard_fight_masm_vm_exit_selector() == 0x03;
    printf("malicia_outbound: active=%d frames=%u operation=%02x "
           "selector=%02x dispatch=%04x pos=%02x/%02x keys=%02x ip=%04x\n",
           zeliard_fight_masm_vm_active(), outbound_frames,
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(),
           zeliard_fight_masm_vm_exit_dispatch_slot(), outbound_game[0x80],
           outbound_game[0x82], outbound_game[0x99],
           zeliard_fight_masm_vm_ip());

    static u8 pickup_game[0x10000];
    static u8 pickup_vga[0x10000];
    pickup_game[0x0080] = 26 - 16;
    pickup_game[0x0082] = (23 - 9) & 0x3F;
    pickup_game[0x0090] = 0x00;
    pickup_game[0x0091] = 0x01;
    pickup_game[0x00B2] = 0x00;
    pickup_game[0x00B3] = 0x01;
    pickup_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        pickup_game, sizeof(pickup_game), pickup_vga, sizeof(pickup_vga));
    u8 pickup_before[0x100];
    for (unsigned i = 0; i < sizeof(pickup_before); ++i)
        pickup_before[i] = pickup_game[i];
    for (unsigned frame = 0; frame < 12; ++frame)
        ok &= zeliard_fight_masm_vm_advance(
            pickup_game, sizeof(pickup_game), pickup_vga,
            sizeof(pickup_vga), 1, 0);
    unsigned pickup_changes = 0;
    for (unsigned i = 0; i < sizeof(pickup_before); ++i)
        pickup_changes += pickup_before[i] != pickup_game[i];
    ok &= pickup_changes == 2;
    ok &= pickup_game[0x85] == 0;
    ok &= pickup_game[0x86] == 0x32;
    ok &= pickup_game[0x87] == 0;
    ok &= read_u16(pickup_game, 0x90) == 0x00E2;
    printf("malicia_pickup_damage: changes=%u gold=%02x%02x%02x "
           "almas=%02x%02x item=%02x/%02x/%02x pos=%02x/%02x hp=%04x\n",
           pickup_changes, pickup_game[0x85], pickup_game[0x86],
           pickup_game[0x87], pickup_game[0x8C], pickup_game[0x8B],
           pickup_game[0xA6], pickup_game[0xA7], pickup_game[0xA8],
           pickup_game[0x80], pickup_game[0x82],
           read_u16(pickup_game, 0x90));

    static u8 death_game[0x10000];
    static u8 death_vga[0x10000];
    death_game[0x0080] = 26 - 16;
    death_game[0x0082] = (23 - 9) & 0x3F;
    death_game[0x0086] = 0x64;
    death_game[0x008B] = 0x64;
    death_game[0x0090] = 0x10;
    death_game[0x00B2] = 0x00;
    death_game[0x00B3] = 0x01;
    death_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        death_game, sizeof(death_game), death_vga, sizeof(death_vga));
    u16 minimum_hp = read_u16(death_game, 0x90);
    unsigned death_frames = 0;
    for (; death_frames < 160 && zeliard_fight_masm_vm_active();
            ++death_frames) {
        zeliard_fight_masm_vm_advance(
            death_game, sizeof(death_game), death_vga, sizeof(death_vga),
            1, 0);
        const u16 hp = read_u16(death_game, 0x90);
        if (hp < minimum_hp) minimum_hp = hp;
    }
    ok &= !zeliard_fight_masm_vm_active();
    ok &= minimum_hp == 1;
    ok &= read_u16(death_game, 0x90) == 0x0100;
    ok &= death_game[0x85] == 0 && death_game[0x86] == 0 &&
          death_game[0x87] == 0;
    ok &= read_u16(death_game, 0x8B) == 50;
    ok &= zeliard_fight_masm_vm_exit_operation() == 0;
    ok &= zeliard_fight_masm_vm_exit_dispatch_slot() == 0x6002;
    printf("malicia_death_reentry: frames=%u min_hp=%04x hp=%04x "
           "gold=%02x%02x%02x almas=%02x%02x pos=%02x/%02x ip=%04x\n",
           death_frames + 1, minimum_hp, read_u16(death_game, 0x90),
           death_game[0x85], death_game[0x86], death_game[0x87],
           death_game[0x8C], death_game[0x8B], death_game[0x80],
           death_game[0x82], zeliard_fight_masm_vm_ip());

    static u8 hazard_game[0x10000];
    static u8 hazard_vga[0x10000];
    /* MP10 tile 28/0 repeatedly executes the environment-damage path while
     * the player remains on it. Each HP-changing scan must have one cue. */
    unsigned hazard_damage_frames = 0, hazard_damage_sounds = 0;
    const u8 hazard_x = 28, hazard_y = 0;
    hazard_game[0x0080] = (u8)(hazard_x - 16);
    hazard_game[0x0082] = (u8)((hazard_y - 9) & 0x3F);
    hazard_game[0x0090] = 0x00;
    hazard_game[0x0091] = 0x04;
    hazard_game[0x00B2] = 0x00;
    hazard_game[0x00B3] = 0x04;
    hazard_game[0xFF33] = 5;
    ok &= zeliard_fight_masm_vm_start(
        hazard_game, sizeof(hazard_game), hazard_vga, sizeof(hazard_vga));
    while (zeliard_fight_masm_vm_take_sound_cue()) {}
    for (unsigned frame = 0; frame < 16; ++frame) {
        const u16 hp_before = read_u16(hazard_game, 0x90);
        ok &= zeliard_fight_masm_vm_advance(
            hazard_game, sizeof(hazard_game), hazard_vga,
            sizeof(hazard_vga), 1, 0);
        hazard_damage_frames += read_u16(hazard_game, 0x90) != hp_before;
        for (u8 cue;
             (cue = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
            hazard_damage_sounds += cue == 0x08 || cue == 0x09;
    }
    const int hazard_sound_events = hazard_damage_frames > 1 &&
        hazard_damage_sounds == hazard_damage_frames;
    ok &= hazard_sound_events;
    printf("malicia_hazard_damage_sound: %s tile=%u/%u "
           "frames=%u sounds=%u hp=%04x\n",
           hazard_sound_events ? "PASS" : "FAIL",
           hazard_x, hazard_y, hazard_damage_frames, hazard_damage_sounds,
           read_u16(hazard_game, 0x90));

    static u8 combat_game[0x10000];
    static u8 combat_vga[0x10000];
    combat_game[0x0080] = 18 - 16;
    combat_game[0x0082] = (58 - 9) & 0x3F;
    combat_game[0x0090] = 0x00;
    combat_game[0x0091] = 0x01;
    combat_game[0x0092] = 1;
    combat_game[0x0093] = 1;
    combat_game[0x0094] = 0x64;
    combat_game[0x0096] = 0x64;
    combat_game[0x00B2] = 0x00;
    combat_game[0x00B3] = 0x01;
    combat_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        combat_game, sizeof(combat_game), combat_vga, sizeof(combat_vga));
    int enemy_hit_observed = 0;
    unsigned damage_sound_events = 0;
    unsigned swing_state_mask = 0;
    unsigned swing_subindex_mask = 0;
    u8 enemy_hp_min = 0xFF;
    combat_game[0xFF1D] = 0xFF;
    for (unsigned frame = 0; frame < 8; ++frame) {
        combat_game[0xFF16] = 1;
        ok &= zeliard_fight_masm_vm_advance(
            combat_game, sizeof(combat_game), combat_vga,
            sizeof(combat_vga), 1, 0);
        for (u8 cue; (cue = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
            damage_sound_events += cue == 0x08 || cue == 0x09;
        swing_state_mask |= 1u << (combat_game[0xFF45] & 7u);
        swing_subindex_mask |= 1u << (combat_game[0xFF46] & 7u);
        for (unsigned enemy = 0; enemy < 54; ++enemy) {
            const u16 record = (u16)(0xD62Eu + enemy * 16u);
            const u8 flags = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(record + 5u));
            const u8 hp = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(record + 8u));
            enemy_hit_observed |= (flags & 0x41u) == 0x41u;
            if (hp && hp < enemy_hp_min) enemy_hp_min = hp;
        }
    }
    const unsigned long long attack_frame = fnv1a64(combat_vga, 64000);
    ok &= write_visual_fixture("build/malicia-attack-frame.ppm", combat_vga);
    const u8 attack_pose = combat_game[0xE7];
    for (unsigned frame = 0; frame < 4; ++frame) {
        combat_game[0xFF16] = 2;
        ok &= zeliard_fight_masm_vm_advance(
            combat_game, sizeof(combat_game), combat_vga,
            sizeof(combat_vga), 1, 0);
        for (u8 cue; (cue = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
            damage_sound_events += cue == 0x08 || cue == 0x09;
    }
    const unsigned long long shield_frame = fnv1a64(combat_vga, 64000);
    ok &= attack_frame == 0x05BCA66A3DF48083ULL;
    ok &= attack_pose == 0x80;
    /* With no direction held, the original FSM cycles the four even
     * reachability-table subindices while checking nearby enemies. */
    ok &= swing_state_mask == 0x01;
    ok &= swing_subindex_mask == 0x55;
    ok &= enemy_hit_observed;
    ok &= shield_frame == 0x0B6419D7CCFE686BULL;
    ok &= read_u16(combat_game, 0x94) == 0x0061;
    ok &= read_u16(combat_game, 0x90) == 0x00FD;
    /* Twelve host advances contain one actual MASM shield-damage write (the
     * event deals three points). FF75 remains nonzero afterward, but that
     * held mailbox value must not manufacture eleven additional sounds. */
    ok &= damage_sound_events == 1;
    ok &= combat_game[0xFF75] == 0x07;
    printf("malicia_combat: attack=%016llx pose=%02x "
           "shield=%016llx shield_hp=%04x hp=%04x cue=%02x hit=%d "
           "enemy_hp=%02x states=%02x/%02x damage_sounds=%u ip=%04x\n",
           attack_frame, attack_pose, shield_frame,
           read_u16(combat_game, 0x94), read_u16(combat_game, 0x90),
           combat_game[0xFF75], enemy_hit_observed, enemy_hp_min,
           swing_state_mask, swing_subindex_mask, damage_sound_events,
           zeliard_fight_masm_vm_ip());

    static u8 boss_route_game[0x10000];
    static u8 boss_route_vga[0x10000];
    boss_route_game[0x0080] = 141 - 16;
    boss_route_game[0x0082] = (32 - 9) & 0x3F;
    boss_route_game[0x0090] = 0x00;
    boss_route_game[0x0091] = 0x01;
    boss_route_game[0x00B2] = 0x00;
    boss_route_game[0x00B3] = 0x01;
    boss_route_game[0xFF33] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boss_route_game, sizeof(boss_route_game), boss_route_vga,
        sizeof(boss_route_vga));
    const int boss_route_advanced = zeliard_fight_masm_vm_advance(
        boss_route_game, sizeof(boss_route_game), boss_route_vga,
        sizeof(boss_route_vga), 1, 1);
    const unsigned long long boss_route_frame =
        fnv1a64(boss_route_vga, 64000);
    ok &= boss_route_advanced;
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= boss_route_frame == 0xD5D48B052A062FD6ULL;
    printf("malicia_boss_route: active=%d advanced=%d operation=%02x "
           "selector=%02x music=%02x width=%u frame=%016llx pos=%02x/%02x "
           "ip=%04x\n", zeliard_fight_masm_vm_active(), boss_route_advanced,
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(),
           zeliard_fight_masm_vm_music_chunk(),
           zeliard_fight_masm_vm_peek_u16(0xC002), boss_route_frame,
           boss_route_game[0x80],
           boss_route_game[0x82], zeliard_fight_masm_vm_ip());

    static u8 boss_game[0x10000];
    static u8 boss_vga[0x10000];
    boss_game[0x0080] = 0x0A;
    boss_game[0x0082] = 0x00;
    boss_game[0x0090] = 0x00;
    boss_game[0x0091] = 0x01;
    boss_game[0x00B2] = 0x00;
    boss_game[0x00B3] = 0x01;
    boss_game[0x00C3] = 0xFF;
    boss_game[0x00C4] = 0x01;
    boss_game[0xFF33] = 5;
    palette_set_game_mcga();
    const int boss_active = zeliard_fight_masm_vm_start(
        boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga));
    const unsigned long long boss_frame = fnv1a64(boss_vga, 64000);
    ok &= boss_active;
    ok &= boss_game[0xC002] == 0x49;
    ok &= boss_game[0xC003] == 0x00;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= boss_frame == 0xFA45DAB7DED99C6AULL;
    printf("malicia_boss: active=%d operation=%02x selector=%02x "
           "frame=%016llx pos=%02x/%02x ip=%04x\n", boss_active,
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(), boss_frame,
           boss_game[0x80], boss_game[0x82], zeliard_fight_masm_vm_ip());
    printf("VERDICT: %s: MASM Malicia map, movement, combat, pickups, death, exits, and Cangrejo\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
