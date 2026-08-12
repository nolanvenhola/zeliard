#include "../game/fight_masm_vm.h"
#include "../load/fill_buffer.h"
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

static void prepare_player(u8 *game, u8 selector, u16 start, u8 row,
                           u8 screen) {
    memset(game, 0, 0x10000);
    game[0x0080] = (u8)start;
    game[0x0081] = (u8)(start >> 8);
    game[0x0082] = row;
    game[0x0083] = screen;
    game[0x0090] = 0;
    game[0x0091] = 1;
    game[0x00B2] = 0;
    game[0x00B3] = 1;
    game[0x00C4] = selector;
    /* zeliad.asm initializes the shared driver-ready flag to FFh. */
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

static u16 read_u16(const u8 *data, size_t offset) {
    return (u16)(data[offset] | ((u16)data[offset + 1] << 8));
}

static int count_map_objects(const char *asset, unsigned records,
                             unsigned *monsters, unsigned *items,
                             unsigned *families) {
    size_t size = 0;
    u8 *map = platform_load_asset(asset, &size);
    if (!map || size < 4 + 0x1D) { free(map); return 0; }
    const u16 object_ptr = read_u16(map + 4, 0x10);
    const size_t start = 4u + (size_t)(object_ptr - 0xC000u);
    if (object_ptr < 0xC000 || start + records * 16u > size) {
        free(map);
        return 0;
    }
    *monsters = *items = *families = 0;
    for (unsigned i = 0; i < records; ++i) {
        const u8 *record = map + start + i * 16u;
        if (record[14]) {
            ++*monsters;
            if (record[4] >= 1 && record[4] <= 4)
                *families |= 1u << record[4];
        } else {
            ++*items;
        }
    }
    free(map);
    return 1;
}

int main(void) {
    static u8 game[0x10000];
    static u8 vga[0x10000];
    int ok = 1;

    /* Release MASM's method-1 decoder skips key/value pairs until an FFh
     * key. ENCNT.GRP begins with 60h,FFh: the FFh value must not be mistaken
     * for the terminator or the four-frame title data is shifted/garbled. */
    size_t encounter_file_size = 0, encounter_art_size = 0;
    u8 *encounter_file = platform_load_asset("encnt.grp", &encounter_file_size);
    u8 *encounter_art = encounter_file ? fill_buffer_decompress(
        encounter_file, encounter_file_size, &encounter_art_size) : NULL;
    const unsigned long long encounter_art_hash = encounter_art
        ? fnv1a64(encounter_art, encounter_art_size) : 0;
    const int encounter_art_ok = encounter_art_size == 1040 &&
        encounter_art_hash == 0xCEE54C916F8A4C77ULL;
    printf("pulpo_encounter_art_decode: %s size=%zu hash=%016llx\n",
           encounter_art_ok ? "PASS" : "FAIL", encounter_art_size,
           encounter_art_hash);
    ok &= encounter_art_ok;
    free(encounter_art);
    free(encounter_file);

    /* MP10 item record 21 links mask 40h to STDPLY byte 02h.  MASM's
     * process_map_seg_updates must consume that persistent bit on a fresh
     * cavern load, keeping the collected/opened object deactivated. */
    static u8 persistence_game[0x10000];
    static u8 persistence_vga[0x10000];
    prepare_player(persistence_game, 0x00, 0, 0, 0);
    persistence_game[0x02] = 0x40;
    palette_set_game_mcga();
    const int persistence_started = zeliard_fight_masm_vm_start(
        persistence_game, sizeof(persistence_game), persistence_vga,
        sizeof(persistence_vga));
    const u16 persistence_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 persisted_item = (u16)(persistence_objects + 21u * 16u);
    u8 persisted_record[16];
    for (unsigned byte = 0; byte < sizeof(persisted_record); ++byte)
        persisted_record[byte] = (u8)zeliard_fight_masm_vm_peek_u8(
            (u16)(persisted_item + byte));
    printf("malicia_persistent_object_probe: started=%d objects=%04x "
           "record=%016llx head=%02x%02x link=%02x%02x\n",
           persistence_started, persistence_objects,
           fnv1a64(persisted_record, sizeof(persisted_record)),
           persisted_record[0], persisted_record[1],
           persisted_record[11], persisted_record[12]);
    ok &= persistence_started && persistence_objects == 0xD62E;
    ok &= persisted_record[0] == 0x00 && persisted_record[1] == 0xFF;
    ok &= persisted_record[11] == 0xFF && persisted_record[12] == 0xFF;
    ok &= fnv1a64(persisted_record, sizeof(persisted_record)) ==
        0xC7C0EA18D2F4AC3FULL;

    /* MP20: canonical Peligro map and Area 2 resource family. */
    prepare_player(game, 0x02, 95 - 16, (35 - 9) & 0x3F, 0);
    palette_set_game_mcga();
    const int peligro_started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long peligro_frame = fnv1a64(vga, 64000);
    printf("peligro_probe: started=%d active=%d at_frame=%d ip=%04x "
           "width=%u music=%02x pos=%02x/%02x/%02x frame=%016llx\n",
           peligro_started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(), zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), game[0x80], game[0x82],
           game[0x83], peligro_frame);
    ok &= peligro_started && zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 224;
    ok &= zeliard_fight_masm_vm_music_chunk() == 87;
    ok &= peligro_frame == 0xFF95FFC21CA3D0F8ULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/peligro-first-frame.ppm", vga);
    unsigned monsters = 0, items = 0, families = 0;
    ok &= count_map_objects("mp20.mdt", 56, &monsters, &items, &families);
    ok &= monsters == 45 && items == 11 && families == 0x1E;
    const u16 peligro_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 enemy_before[56][16];
    unsigned family_counts[5] = {0};
    memset(enemy_before, 0, sizeof(enemy_before));
    for (unsigned enemy = 0; enemy < 56; ++enemy) {
        const u16 record = (u16)(peligro_objects + enemy * 16u);
        for (unsigned byte = 0; byte < 16; ++byte)
            enemy_before[enemy][byte] = (u8)
                zeliard_fight_masm_vm_peek_u8((u16)(record + byte));
        if (enemy_before[enemy][14] && enemy_before[enemy][4] <= 4)
            ++family_counts[enemy_before[enemy][4]];
    }
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned enemy = 0; enemy < 56; ++enemy) {
        const u8 family = enemy_before[enemy][4];
        if (!enemy_before[enemy][14] || family < 1 || family > 4) continue;
        const u16 record = (u16)(peligro_objects + enemy * 16u);
        for (unsigned byte = 0; byte < 16; ++byte) {
            if (zeliard_fight_masm_vm_peek_u8((u16)(record + byte)) !=
                enemy_before[enemy][byte]) {
                changed_families |= 1u << family;
                break;
            }
        }
    }
    const unsigned long long peligro_moving_frame = fnv1a64(vga, 64000);
    ok &= peligro_moving_frame == 0xD7C5DAA1C10C8A55ULL;
    printf("peligro_ai_probe: monsters=%u items=%u families=%02x/%02x "
           "counts=%u/%u/%u/%u pos=%02x/%02x/%02x frame=%016llx\n",
           monsters, items, families, changed_families, family_counts[1],
           family_counts[2], family_counts[3], family_counts[4],
           game[0x80], game[0x82], game[0x83],
           peligro_moving_frame);
    ok &= family_counts[1] && family_counts[2] && family_counts[3] &&
        family_counts[4];
    ok &= changed_families == 0x1E;

    static u8 combat_game[0x10000];
    static u8 combat_vga[0x10000];
    prepare_player(combat_game, 0x02, 0, (38 - 9) & 0x3F, 0);
    combat_game[0x0092] = 1;
    combat_game[0x0093] = 1;
    combat_game[0x0094] = 0x64;
    combat_game[0x0096] = 0x64;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        combat_game, sizeof(combat_game), combat_vga, sizeof(combat_vga));
    const u16 object_list =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    int enemy_hit = 0;
    unsigned damage_sounds = 0;
    u8 enemy_hp_min = 0xFF;
    combat_game[0xFF1D] = 0xFF;
    for (unsigned frame = 0; frame < 12; ++frame) {
        combat_game[0xFF16] = 1;
        ok &= advance_frame(combat_game, combat_vga, 0);
        for (u8 cue; (cue = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
            damage_sounds += cue == 0x08 || cue == 0x09 || cue == 0x16;
        for (unsigned enemy = 0; enemy < 56; ++enemy) {
            const u16 record = (u16)(object_list + enemy * 16u);
            const u8 flags = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(record + 5u));
            const u8 hp = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(record + 8u));
            enemy_hit |= (flags & 0x41u) == 0x41u;
            if (hp && hp < enemy_hp_min) enemy_hp_min = hp;
        }
    }
    const unsigned long long combat_frame = fnv1a64(combat_vga, 64000);
    printf("peligro_combat_probe: object_list=%04x hit=%d enemy_hp=%02x "
           "damage_sounds=%u hp=%04x shield=%04x frame=%016llx\n",
           object_list, enemy_hit, enemy_hp_min, damage_sounds,
           read_u16(combat_game, 0x90), read_u16(combat_game, 0x94),
           combat_frame);
    ok &= object_list == 0xD834;
    ok &= enemy_hit;
    ok &= read_u16(combat_game, 0x90) == 0x0100;
    ok &= read_u16(combat_game, 0x94) == 0x0064;
    ok &= combat_frame == 0x42590611458A2A5CULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/peligro-combat-frame.ppm",
                                   combat_vga);

    /* MP21 is the authored connector, not a host transition. */
    prepare_player(game, 0x03, 66 - 16, (35 - 9) & 0x3F, 0);
    palette_set_game_mcga();
    const int connector_started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long connector_frame = fnv1a64(vga, 64000);
    printf("peligro_connector_probe: started=%d active=%d at_frame=%d "
           "ip=%04x width=%u music=%02x pos=%02x/%02x/%02x "
           "fight_col=%02x player_y=%02x frame=%016llx\n", connector_started,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(), zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), game[0x80], game[0x82],
           game[0x83], game[0x84],
           zeliard_fight_masm_vm_peek_u8(0xC016), connector_frame);
    ok &= connector_started && zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 96;
    ok &= zeliard_fight_masm_vm_music_chunk() == 87;
    ok &= connector_frame == 0xF3520FDADFC5C0ABULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/peligro-connector-frame.ppm", vga);

    /* Press Up at MP21's authored x=66/y=35 door and follow map-id 02. */
    const int entered_peligro = advance_frame(game, vga, 1);
    /* The map loader clears the playfield while switching overlays.  Advance
     * through the next ordinary gameplay boundary before evaluating the
     * destination, matching the frame a player actually receives. */
    for (unsigned frame = 0; frame < 4; ++frame)
        ok &= advance_frame(game, vga, 0);
    const unsigned long long entered_peligro_frame = fnv1a64(vga, 64000);
    printf("peligro_connector_exit_probe: advanced=%d active=%d "
           "at_frame=%d width=%u music=%02x pos=%02x/%02x/%02x "
           "frame=%016llx\n", entered_peligro,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), game[0x80], game[0x82],
           game[0x83], entered_peligro_frame);
    ok &= entered_peligro && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 224;
    ok &= zeliard_fight_masm_vm_music_chunk() == 87;
    ok &= entered_peligro_frame == 0x695317B1A2369148ULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/peligro-connector-exit.ppm", vga);

    /* MP20's right-hand arena door enters Pulpo (selector 04). */
    static u8 boss_route_game[0x10000];
    static u8 boss_route_vga[0x10000];
    prepare_player(boss_route_game, 0x02, 190 - 16,
                   (47 - 9) & 0x3F, 0);
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boss_route_game, sizeof(boss_route_game), boss_route_vga,
        sizeof(boss_route_vga));
    const int boss_route_advanced = advance_frame(
        boss_route_game, boss_route_vga, 1);
    printf("peligro_pulpo_route_probe: advanced=%d active=%d width=%u "
           "music=%02x pos=%02x/%02x/%02x\n", boss_route_advanced,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), boss_route_game[0x80],
           boss_route_game[0x82], boss_route_game[0x83]);
    ok &= boss_route_advanced && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 52;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;

    /* Preserve every host-presented frame of the authored boss entrance.
     * The ordinary helper intentionally waits for 629Ch and would collapse
     * the ENCOUNTER wipe into a single assertion point. */
    static u8 encounter_game[0x10000];
    static u8 encounter_vga[0x10000];
    prepare_player(encounter_game, 0x02, 190 - 16,
                   (47 - 9) & 0x3F, 0);
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        encounter_game, sizeof(encounter_game), encounter_vga,
        sizeof(encounter_vga));
    unsigned encounter_ticks = 0;
    unsigned encounter_start = 0;
    unsigned encounter_finish = 0;
    unsigned boss_music_frame = 0;
    unsigned long long encounter_text_hash = 0;
    unsigned long long encounter_stack_hash = 0;
    unsigned long long chamber_reveal_hash = 0;
    unsigned long long pulpo_emerge_hash = 0;
    unsigned long long chamber_ready_hash = 0;
    while (zeliard_fight_masm_vm_active() && encounter_ticks < 200) {
        const u8 direction = encounter_start ? 0 : 1;
        ok &= zeliard_fight_masm_vm_advance(
            encounter_game, sizeof(encounter_game), encounter_vga,
            sizeof(encounter_vga), 20, direction);
        ++encounter_ticks;
        const u16 width = zeliard_fight_masm_vm_peek_u16(0xC002);
        if (!encounter_start && width == 52) encounter_start = encounter_ticks;
        if (!boss_music_frame && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music_frame = encounter_ticks;
        if (encounter_start && !encounter_finish &&
            zeliard_fight_masm_vm_at_frame())
            encounter_finish = encounter_ticks;
        const unsigned long long frame_hash = fnv1a64(encounter_vga, 64000);
        if (encounter_ticks == 56) encounter_text_hash = frame_hash;
        if (encounter_ticks == 67) encounter_stack_hash = frame_hash;
        if (encounter_ticks == 129) chamber_reveal_hash = frame_hash;
        if (encounter_ticks == 137) pulpo_emerge_hash = frame_hash;
        if (encounter_ticks == 180) chamber_ready_hash = frame_hash;
        if (getenv("ZELIARD_DUMP") &&
            (encounter_ticks == 26 || encounter_ticks == 56 ||
             encounter_ticks == 67 || encounter_ticks == 129 ||
             encounter_ticks == 137 || encounter_ticks == 145 ||
             encounter_ticks == 162 || encounter_ticks == 180)) {
            char path[64];
            snprintf(path, sizeof(path), "build/pulpo-encounter-%03u.ppm",
                     encounter_ticks);
            ok &= write_visual_fixture(path, encounter_vga);
        }
    }
    printf("pulpo_encounter_probe: ticks=%u start=%u music=%u finish=%u "
           "intro=%02x width=%u hashes=%016llx/%016llx/%016llx/"
           "%016llx/%016llx\n", encounter_ticks, encounter_start,
           boss_music_frame, encounter_finish, encounter_game[0xC3],
           zeliard_fight_masm_vm_peek_u16(0xC002), encounter_text_hash,
           encounter_stack_hash, chamber_reveal_hash, pulpo_emerge_hash,
           chamber_ready_hash);
    ok &= encounter_start == 4 && boss_music_frame == 56;
    ok &= encounter_finish == 112 && encounter_game[0xC3] == 0x40;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 52;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= encounter_text_hash == 0xE55AD9EFE2E447E8ULL;
    ok &= encounter_stack_hash == 0xE55AD9EFE2E447E8ULL;
    ok &= chamber_reveal_hash == 0xF77D900D9AEA259CULL;
    ok &= pulpo_emerge_hash == 0x08A2C95C6F7D8E6FULL;
    ok &= chamber_ready_hash == 0xC5C665325BCFA9B6ULL;

    /* MP20's authored green-door boundary continues at selector 05. */
    static u8 outbound_game[0x10000];
    static u8 outbound_vga[0x10000];
    prepare_player(outbound_game, 0x02, 205 - 16,
                   (47 - 9) & 0x3F, 0);
    outbound_game[0x00C3] = 0xFF;
    outbound_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        outbound_game, sizeof(outbound_game), outbound_vga,
        sizeof(outbound_vga));
    int outbound_advanced = advance_frame(outbound_game, outbound_vga, 1);
    outbound_advanced |= advance_frame(outbound_game, outbound_vga, 1);
    const unsigned long long madera_entry_frame =
        fnv1a64(outbound_vga, 64000);
    printf("peligro_outbound_probe: advanced=%d active=%d width=%u music=%02x "
           "operation=%02x selector=%02x dispatch=%04x pos=%02x/%02x/%02x "
           "frame=%016llx\n",
           outbound_advanced, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(),
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(),
           zeliard_fight_masm_vm_exit_dispatch_slot(), outbound_game[0x80],
           outbound_game[0x82], outbound_game[0x83], madera_entry_frame);
    ok &= outbound_advanced && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 204;
    ok &= zeliard_fight_masm_vm_music_chunk() == 88;
    ok &= madera_entry_frame == 0x9C0E087885EB6BDDULL;

    /* MP2D: Peligro's Pulpo boundary and boss resource family. */
    prepare_player(game, 0x04, 0x08, 0x09, 0);
    game[0x00C3] = 0xFF;
    palette_set_game_mcga();
    const int pulpo_started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long pulpo_frame = fnv1a64(vga, 64000);
    printf("pulpo_probe: started=%d active=%d at_frame=%d ip=%04x "
           "width=%u music=%02x frame=%016llx\n", pulpo_started,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(), zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), pulpo_frame);
    ok &= pulpo_started;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 52;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= pulpo_frame == 0x61C577577189EA71ULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/pulpo-first-frame.ppm", vga);

    /* Drive the release Pulpo module's own death state machine.  This is a
     * test setup only: gameplay reaches the same state by reducing AA83 HP
     * to zero through the normal sword-hit callback. */
    prepare_player(game, 0x04, 0x08, 0x09, 0);
    game[0x00C3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= zeliard_fight_masm_vm_poke_u16(0xAA83, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAA9E, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned victory_frames = 0;
    unsigned completion_frame = 0;
    unsigned tear_frame = 0;
    unsigned roka_start_frame = 0;
    unsigned roka_finish_frame = 0;
    unsigned long long completion_hash = 0;
    unsigned long long raised_sword_hash = 0;
    unsigned long long crystal_launch_hash = 0;
    unsigned long long crystal_motion_hash = 0;
    unsigned long long crystal_arrival_hash = 0;
    u8 last_pose = 0xFF;
    while (zeliard_fight_masm_vm_active() && victory_frames < 1200 &&
           !roka_finish_frame) {
        /* One host tick per sample is important here.  ROKADEMO contains
         * several MASM wait_frame loops and must not be fast-forwarded by
         * the ordinary gameplay-boundary helper above. */
        const unsigned post_completion = completion_frame
            ? victory_frames - completion_frame : 0;
        const u8 direction = !completion_frame || roka_start_frame ? 0
            : post_completion < 48 ? 8
            : post_completion < 88 ? 4
            : 1;
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, direction);
        ++victory_frames;
        if (!completion_frame &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            completion_frame = victory_frames;
            completion_hash = fnv1a64(vga, 64000);
        }
        if (!tear_frame && game[0xA0]) tear_frame = victory_frames;
        const u16 ip = zeliard_fight_masm_vm_ip();
        if (!roka_start_frame && ip >= 0xA009 && ip < 0xA5A8)
            roka_start_frame = victory_frames;
        if (roka_start_frame && !raised_sword_hash &&
            zeliard_fight_masm_vm_peek_u8(0x00E7) >= 5)
            raised_sword_hash = fnv1a64(vga, 64000);
        const u8 crystal_y =
            (u8)zeliard_fight_masm_vm_peek_u8(0xA59C);
        const u8 crystal_x =
            (u8)zeliard_fight_masm_vm_peek_u8(0xA59D);
        if (roka_start_frame && !crystal_launch_hash &&
            crystal_y == 0x94 && crystal_x == 0x50)
            crystal_launch_hash = fnv1a64(vga, 64000);
        if (roka_start_frame && !crystal_motion_hash &&
            crystal_y == 0x68 && crystal_x == 0x29)
            crystal_motion_hash = fnv1a64(vga, 64000);
        if (roka_start_frame && !crystal_arrival_hash &&
            crystal_y == 0x3C && crystal_x == 0x02)
            crystal_arrival_hash = fnv1a64(vga, 64000);
        if (roka_start_frame && zeliard_fight_masm_vm_at_frame() &&
            zeliard_fight_masm_vm_peek_u16(0xC002) == 224)
            roka_finish_frame = victory_frames;
        const u8 pose = (u8)zeliard_fight_masm_vm_peek_u8(0x00E7);
        const int pose_changed = pose != last_pose;
        if (getenv("ZELIARD_DUMP") &&
            (victory_frames % 40 == 0 || pose_changed))
            printf("pulpo_victory_step: frame=%u ip=%04x map=%u "
                   "pos=%02x/%02x/%02x state=%02x/%02x/%02x "
                   "pose=%02x crystal=%02x/%02x\n",
                   victory_frames, ip,
                   zeliard_fight_masm_vm_peek_u16(0xC002), game[0x80],
                   game[0x82], game[0x83], game[0xFF30], game[0xFF2E],
                   game[0x9F], pose,
                   zeliard_fight_masm_vm_peek_u8(0xA59C),
                   zeliard_fight_masm_vm_peek_u8(0xA59D));
        last_pose = pose;
        if (getenv("ZELIARD_DUMP") &&
            (victory_frames == 1 || victory_frames == 20 ||
             victory_frames == completion_frame || pose_changed ||
             victory_frames % 40 == 0 || victory_frames == tear_frame ||
             victory_frames == roka_finish_frame)) {
            char path[64];
            snprintf(path, sizeof(path), "build/pulpo-victory-%03u.ppm",
                     victory_frames);
            ok &= write_visual_fixture(path, vga);
        }
    }
    printf("pulpo_victory_probe: frames=%u completion=%u/%02x tear=%u "
           "roka=%u/%u "
           "death=%02x timer=%02x tears=%02x pos=%02x/%02x/%02x "
           "pose=%02x hero=%02x "
           "weapon=%02x active=%d exit=%02x/%02x/%04x "
           "hashes=%016llx/%016llx/%016llx/%016llx/%016llx\n",
           victory_frames, completion_frame,
           zeliard_fight_masm_vm_peek_u8(0xFF30),
           tear_frame, roka_start_frame, roka_finish_frame,
           zeliard_fight_masm_vm_peek_u8(0xFF2E),
           zeliard_fight_masm_vm_peek_u8(0xAA9E), game[0xA0], game[0x80],
           game[0x82], game[0x83], game[0xE7],
           game[0xFF3F], game[0xFF41], zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector(),
           zeliard_fight_masm_vm_exit_dispatch_slot(), completion_hash,
           raised_sword_hash, crystal_launch_hash, crystal_motion_hash,
           crystal_arrival_hash);
    ok &= completion_frame > 0;
    ok &= roka_start_frame > completion_frame;
    ok &= tear_frame == roka_start_frame;
    ok &= raised_sword_hash != 0 && crystal_launch_hash != 0;
    ok &= crystal_motion_hash != 0 && crystal_arrival_hash != 0;
    ok &= completion_hash == 0x3A6EA18B0C80A526ULL;
    ok &= raised_sword_hash == 0xC6C34266874659F5ULL;
    ok &= crystal_launch_hash == 0x2592F6516DFA4178ULL;
    ok &= crystal_motion_hash == 0x2E428816D40D20DAULL;
    ok &= crystal_arrival_hash == 0xCBC81A369B2EBBC4ULL;
    ok &= roka_finish_frame > roka_start_frame;
    ok &= game[0xA0] == 1;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 224;

    printf("VERDICT: %s: Peligro assets and exact fight VM route\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
