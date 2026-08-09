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
    u8 *image = platform_load_asset("mp70.mdt", &size);
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
    prepare_player(game, 18, 20, 30);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    printf("caliente_probe: started=%d active=%d frame=%d width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x frame=%016llx\n",
           started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 208;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 7;
    ok &= zeliard_fight_masm_vm_music_chunk() == 92;
    ok &= monsters == 19 && items == 10 && families == 0x1E;

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[29][16];
    for (unsigned object = 0; object < 29; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 29; ++object) {
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
    printf("caliente_ai_probe: objects=%04x changed=%02x frame=%016llx\n",
           objects, changed_families, moving_frame);
    ok &= changed_families == 0x1E;

    /* MP70 object seven is tied to stdply byte 34h/mask 08h. */
    static u8 persistent_game[0x10000], persistent_vga[0x10000];
    prepare_player(persistent_game, 18, 20, 30);
    persistent_game[0x34] = 0x08;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        persistent_game, sizeof(persistent_game), persistent_vga,
        sizeof(persistent_vga));
    const u16 persistent_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 persisted = (u16)(persistent_objects + 7u * 16u);
    printf("caliente_persistence_probe: objects=%04x head=%02x%02x "
           "link=%02x%02x\n", persistent_objects,
           zeliard_fight_masm_vm_peek_u8(persisted),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 1)),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 11)),
           zeliard_fight_masm_vm_peek_u8((u16)(persisted + 12)));
    ok &= zeliard_fight_masm_vm_peek_u8(persisted) == 0;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 1)) == 0xFF;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 11)) == 0xFF;
    ok &= zeliard_fight_masm_vm_peek_u8((u16)(persisted + 12)) == 0xFF;

    /* Llama route 2 enters the dedicated MP73 hut arena. Its descriptor
     * selects ZEL2 (program index 12h) and ENP7 (sprite index 0Ch). */
    static u8 paguro_game[0x10000], paguro_vga[0x10000];
    prepare_player(paguro_game, 21, 27, 12);
    paguro_game[0x83] = 13;
    paguro_game[0xC5] = 0x87;
    palette_set_game_mcga();
    const int paguro_started = zeliard_fight_masm_vm_start(
        paguro_game, sizeof(paguro_game), paguro_vga, sizeof(paguro_vga));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(paguro_game, paguro_vga, 0);
    printf("paguro_probe: started=%d active=%d frame=%d width=%u "
           "level=%u music=%02x damage=%04x state=%02x/%02x/%02x "
           "hash=%016llx\n",
           paguro_started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(),
           zeliard_fight_masm_vm_peek_u16(0xA5E2),
           zeliard_fight_masm_vm_peek_u8(0xA5F7),
           zeliard_fight_masm_vm_peek_u8(0xA5F8),
           zeliard_fight_masm_vm_peek_u8(0xA601),
           fnv1a64(paguro_vga, 64000));
    ok &= paguro_started && zeliard_fight_masm_vm_active() &&
          zeliard_fight_masm_vm_peek_u16(0xC002) == 73 &&
          zeliard_fight_masm_vm_peek_u8(0xC012) == 1 &&
          zeliard_fight_masm_vm_peek_u16(0xA5E2) == 0x0258;
    ok &= zeliard_fight_masm_vm_poke_u16(0xA5E2, 0);
    for (u16 address = 0xA5F6; address <= 0xA602; ++address)
        ok &= zeliard_fight_masm_vm_poke_u8(address, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned paguro_frames = 0, paguro_completion = 0;
    unsigned long long paguro_completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && paguro_frames < 400 &&
           !(paguro_game[0x30] == 0xFF && paguro_game[0x31] == 0xFF)) {
        ok &= zeliard_fight_masm_vm_advance(
            paguro_game, sizeof(paguro_game), paguro_vga,
            sizeof(paguro_vga), 20, 0);
        ++paguro_frames;
        if (!paguro_completion &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            paguro_completion = paguro_frames;
            paguro_completion_hash = fnv1a64(paguro_vga, 64000);
        }
    }
    printf("paguro_death_probe: frames=%u completion=%u timer=%02x "
           "defeated=%02x/%02x almas=%u event=%02x hash=%016llx\n",
           paguro_frames, paguro_completion,
           zeliard_fight_masm_vm_peek_u8(0xA601), paguro_game[0x30],
           paguro_game[0x31], read_u16(paguro_game, 0x8B),
           paguro_game[0x34], paguro_completion_hash);
    ok &= paguro_completion == 121 && paguro_frames == 134 &&
          paguro_game[0x30] == 0xFF && paguro_game[0x31] == 0xFF &&
          read_u16(paguro_game, 0x8B) == 1600;

    static u8 paguro_revisit_game[0x10000], paguro_revisit_vga[0x10000];
    prepare_player(paguro_revisit_game, 21, 27, 12);
    paguro_revisit_game[0x83] = 13;
    paguro_revisit_game[0x30] = paguro_revisit_game[0x31] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        paguro_revisit_game, sizeof(paguro_revisit_game),
        paguro_revisit_vga, sizeof(paguro_revisit_vga));
    for (unsigned frame = 0; frame < 20; ++frame)
        ok &= advance_frame(paguro_revisit_game, paguro_revisit_vga, 0);
    const unsigned long long paguro_revisit_hash =
        fnv1a64(paguro_revisit_vga, 64000);
    printf("paguro_revisit_probe: active=%d width=%u music=%02x "
           "damage=%04x completion=%02x hash=%016llx\n",
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(),
           zeliard_fight_masm_vm_peek_u16(0xA5E2),
           zeliard_fight_masm_vm_peek_u8(0xFF30),
           paguro_revisit_hash);
    ok &= zeliard_fight_masm_vm_active() &&
          zeliard_fight_masm_vm_peek_u16(0xC002) == 73 &&
          zeliard_fight_masm_vm_peek_u8(0xFF30) == 0 &&
          paguro_revisit_hash == 0xBB2ACCD3E056F84FULL;

    /* Area 7 subtracts 15 HP every 64 combat frames unless wearable 5,
     * the Asbestos Cape, is selected. */
    static u8 heat_game[0x10000], heat_vga[0x10000];
    prepare_player(heat_game, 18, 20, 30);
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        heat_game, sizeof(heat_game), heat_vga, sizeof(heat_vga));
    for (unsigned frame = 0; frame < 70; ++frame)
        ok &= advance_frame(heat_game, heat_vga, 8);
    const u16 unprotected_hp = read_u16(heat_game, 0x90);

    static u8 cape_game[0x10000], cape_vga[0x10000];
    prepare_player(cape_game, 18, 20, 30);
    cape_game[0x9E] = 5;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        cape_game, sizeof(cape_game), cape_vga, sizeof(cape_vga));
    for (unsigned frame = 0; frame < 70; ++frame)
        ok &= advance_frame(cape_game, cape_vga, 8);
    const u16 protected_hp = read_u16(cape_game, 0x90);
    printf("caliente_heat_probe: unprotected=%u cape=%u delta=%u\n",
           unprotected_hp, protected_hp, protected_hp - unprotected_hp);
    ok &= protected_hp == 512 && unprotected_hp == 497;

    /* The x49/y59 authored route enters Reaccion and returns through its
     * x103/y33 reverse door without consuming a key. */
    static u8 route_game[0x10000], route_vga[0x10000];
    prepare_player(route_game, 18, 49, 59);
    route_game[0xC3] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        route_game, sizeof(route_game), route_vga, sizeof(route_vga));
    const int entered = advance_frame(route_game, route_vga, 1);
    const u16 entered_width = zeliard_fight_masm_vm_peek_u16(0xC002);
    printf("caliente_reaccion_route_probe: entered=%d/%u "
           "width=%u music=%02x\n", entered, entered_width,
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk());
    ok &= entered && zeliard_fight_masm_vm_active();
    ok &= entered_width == 196;

    /* Caliente x199/y33 enters the 70-column Dragon chamber and owns the
     * complete release ROKA/ENCOUNTER sequence before DRGN dispatch. */
    static u8 boss_game[0x10000], boss_vga[0x10000];
    prepare_player(boss_game, 18, 199, 33);
    boss_game[0x98] = 1;
    boss_game[0xA0] = 6;
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
        if (!encounter_start && zeliard_fight_masm_vm_peek_u16(0xC002) == 70)
            encounter_start = ticks;
        if (!boss_music_frame && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music_frame = ticks;
        if (encounter_start && !encounter_finish &&
            zeliard_fight_masm_vm_at_frame()) encounter_finish = ticks;
        if (ticks == 56) encounter_hash = fnv1a64(boss_vga, 64000);
        if (ticks == 180) chamber_hash = fnv1a64(boss_vga, 64000);
    }
    printf("caliente_dragon_encounter_probe: ticks=%u start=%u music_at=%u "
           "finish=%u active=%d width=%u music=%02x intro=%02x "
           "hashes=%016llx/%016llx\n", ticks, encounter_start,
           boss_music_frame, encounter_finish,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), boss_game[0xC3],
           encounter_hash, chamber_hash);
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 70;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    ok &= encounter_start && boss_music_frame && encounter_finish;
    ok &= boss_game[0xC3] == 0;

    ok &= encounter_start == 8 && boss_music_frame == 59;
    ok &= encounter_finish == 115;
    ok &= first_frame == 0x27426A7D61E13010ULL;
    ok &= moving_frame == 0xA0B08A219B2900FAULL;
    ok &= encounter_hash == 0x04A9FCB661F00001ULL;
    ok &= chamber_hash == 0x1591CDB47E031B7AULL;

    /* Restart directly in MP7D for the deterministic death fixture, as the
     * release test does for Pulpo. Entrance timing remains covered by the
     * routed fixture above; this isolates DRGN's death FSM and persistence
     * patch from player damage accumulated while sampling the entrance. */
    prepare_player(boss_game, 22, 20, 30);
    boss_game[0x98] = 1;
    boss_game[0xA0] = 6;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga));
    printf("dragon_state_probe: damage=%04x death=%02x step=%02x "
           "phase=%02x/%02x completion=%02x shutdown=%04x captured=%02x "
           "item=%02x\n",
           zeliard_fight_masm_vm_peek_u16(0xAA3F),
           zeliard_fight_masm_vm_peek_u8(0xFF2E),
           zeliard_fight_masm_vm_peek_u8(0xAA58),
           zeliard_fight_masm_vm_peek_u8(0xAA5B),
           zeliard_fight_masm_vm_peek_u8(0xAA5C),
           zeliard_fight_masm_vm_peek_u8(0xFF30),
           zeliard_fight_masm_vm_peek_u16(0x603C), boss_game[0x49],
           boss_game[0xFF4B]);
    ok &= zeliard_fight_masm_vm_peek_u16(0xAA3F) == 0x0320;
    boss_game[0x90] = boss_game[0xB2] = 0xFF;
    boss_game[0x91] = boss_game[0xB3] = 0x7F;
    ok &= zeliard_fight_masm_vm_poke_u16(0xAA3F, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAA58, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned dragon_frames = 0, dragon_completion = 0;
    unsigned long long dragon_completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && dragon_frames < 300 &&
           !dragon_completion) {
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga),
            20, 0);
        ++dragon_frames;
        if (!dragon_completion &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            dragon_completion = dragon_frames;
            dragon_completion_hash = fnv1a64(boss_vga, 64000);
        }
    }
    unsigned dragon_persistence = 0;
    while (zeliard_fight_masm_vm_active() && dragon_frames < 1200 &&
           !(boss_game[0x32] == 0xFF && boss_game[0x33] == 0xFF)) {
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga),
            20, 0);
        ++dragon_frames;
        if (boss_game[0x32] == 0xFF && boss_game[0x33] == 0xFF)
            dragon_persistence = dragon_frames;
    }
    printf("dragon_death_probe: frames=%u completion=%u/%02x "
           "persistence=%u defeated=%02x/%02x hash=%016llx\n", dragon_frames,
           dragon_completion, zeliard_fight_masm_vm_peek_u8(0xFF30),
           dragon_persistence, boss_game[0x32], boss_game[0x33],
           dragon_completion_hash);
    ok &= dragon_completion == 122;
    ok &= dragon_completion_hash == 0xC75B95AA49A4D649ULL;
    ok &= dragon_persistence > dragon_completion;
    ok &= boss_game[0x32] == 0xFF && boss_game[0x33] == 0xFF;

    printf("caliente_hash_contract: first=%016llx moving=%016llx "
           "encounter=%016llx chamber=%016llx\n", first_frame, moving_frame,
           encounter_hash, chamber_hash);
    printf("VERDICT: %s: Caliente exact fight VM, Paguro hut, heat family, "
           "persistence, routes, and Dragon handoff\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
