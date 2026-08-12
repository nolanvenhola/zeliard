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

static void prepare_player(u8 *game, u8 selector, u16 x, u8 y) {
    memset(game, 0, 0x10000);
    game[0x0080] = (u8)(x - 16u);
    game[0x0081] = (u8)((x - 16u) >> 8);
    game[0x0082] = (u8)((y - 9u) & 0x3Fu);
    game[0x0083] = 12;
    game[0x0091] = 1;
    game[0x00B3] = 1;
    game[0x00C4] = selector;
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

static int map_shape(unsigned *monsters, unsigned *items,
                     unsigned *families) {
    size_t size = 0;
    u8 *image = platform_load_asset("mp31.mdt", &size);
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
    static u8 game[0x10000];
    static u8 vga[0x10000];
    int ok = 1;
    prepare_player(game, 6, 19, 49);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    printf("riza_probe: started=%d active=%d frame_ready=%d width=%u "
           "music=%02x objects=%u/%u families=%02x pos=%02x/%02x/%02x "
           "frame=%016llx\n", started, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_at_frame(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), monsters, items, families,
           game[0x80], game[0x82], game[0x83], first_frame);
    ok &= started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 204;
    ok &= zeliard_fight_masm_vm_music_chunk() == 88;

    ok &= monsters == 36 && items == 12 && families == 0x0E;
    ok &= first_frame == 0xEBAAAD7878680058ULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/riza-first-frame.ppm", vga);

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[48][16];
    memset(before, 0, sizeof(before));
    for (unsigned object = 0; object < 48; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 48; ++object) {
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
    printf("riza_ai_probe: changed=%02x frame=%016llx\n",
           changed_families, moving_frame);
    ok &= changed_families == 0x0E;
    ok &= moving_frame == 0xA8F6478AFB85D4F5ULL;

    /* MP31's release descriptor stores the Pollo target at C013h/C015h.
     * Run this separate singleton-VM fixture only after the first-frame and
     * live-AI checks above have finished consuming their original fixture. */
    static u8 heartbeat_game[0x10000];
    static u8 heartbeat_vga[0x10000];
    prepare_player(heartbeat_game, 6, 188, 21);
    /* A town/UI cue may still occupy the shared mailbox at handoff. MASM
     * does not replay it on 200FIGHT entry; only a newly executed FF75h
     * write is a sound event. */
    heartbeat_game[0xFF75] = 0x0B;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        heartbeat_game, sizeof(heartbeat_game),
        heartbeat_vga, sizeof(heartbeat_vga));
    const u8 entry_cue = zeliard_fight_masm_vm_take_sound_cue();
    ok &= advance_frame(heartbeat_game, heartbeat_vga, 0);
    const u8 near_volume = heartbeat_game[0xFF08];
    heartbeat_game[0x80] = 16;
    heartbeat_game[0x81] = 0;
    heartbeat_game[0x82] = 0;
    ok &= advance_frame(heartbeat_game, heartbeat_vga, 0);
    const u8 far_volume = heartbeat_game[0xFF08];
    printf("riza_boss_door_heartbeat: target=%u/%u near=%u far=%u "
           "entry_cue=%02x\n",
           zeliard_fight_masm_vm_peek_u16(0xC013),
           zeliard_fight_masm_vm_peek_u8(0xC015), near_volume, far_volume,
           entry_cue);
    ok &= zeliard_fight_masm_vm_peek_u16(0xC013) == 188 &&
        zeliard_fight_masm_vm_peek_u8(0xC015) == 21 &&
        near_volume == 15 && far_volume == 0 && entry_cue == 0;

    /* Traverse MP30's paired x19/y49 door first so release 200FIGHT owns
     * the locked-door state mutation before testing the reverse route. */
    static u8 return_game[0x10000];
    static u8 return_vga[0x10000];
    prepare_player(return_game, 5, 19, 49);
    return_game[0x00C3] = 0xFF;
    return_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        return_game, sizeof(return_game), return_vga, sizeof(return_vga));
    int entered_riza = advance_frame(return_game, return_vga, 1);
    const u16 entered_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    return_game[0x80] = 19 - 16;
    return_game[0x81] = 0;
    return_game[0x82] = (49 - 9) & 0x3F;
    int returned = advance_frame(return_game, return_vga, 1);
    const u16 returned_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const unsigned long long returned_frame = fnv1a64(return_vga, 64000);
    printf("riza_return_probe: entered=%d/%04x returned=%d/%04x active=%d "
           "width=%u music=%02x pos=%02x/%02x/%02x frame=%016llx\n",
           entered_riza, entered_objects, returned, returned_objects,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), return_game[0x80],
           return_game[0x82], return_game[0x83],
           returned_frame);
    ok &= entered_riza && returned && zeliard_fight_masm_vm_active();
    ok &= entered_objects == 0xCEA8 && returned_objects == 0xCC5F;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 204;
    ok &= zeliard_fight_masm_vm_music_chunk() == 88;

    /* MP31 x188/y20 enters MP3D through 200FIGHT's directional ROKA and
     * ENCOUNTER! sequence, then loads exact TORI code/sprites. */
    static u8 boss_game[0x10000];
    static u8 boss_vga[0x10000];
    prepare_player(boss_game, 6, 188, 20);
    boss_game[0x00C3] = 0;
    boss_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga));
    unsigned boss_ticks = 0, encounter_start = 0, encounter_finish = 0;
    unsigned boss_music_frame = 0;
    unsigned long long hashes[5] = {0};
    int saw_boss_music = 0;
    while (zeliard_fight_masm_vm_active() && boss_ticks < 200) {
        const u8 direction = encounter_start ? 0 : 1;
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga),
            20, direction);
        ++boss_ticks;
        const u16 width = zeliard_fight_masm_vm_peek_u16(0xC002);
        if (!encounter_start && width == 73) encounter_start = boss_ticks;
        if (!boss_music_frame && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music_frame = boss_ticks;
        if (encounter_start && !encounter_finish &&
            zeliard_fight_masm_vm_at_frame())
            encounter_finish = boss_ticks;
        saw_boss_music |= zeliard_fight_masm_vm_music_chunk() == 94;
        const unsigned long long hash = fnv1a64(boss_vga, 64000);
        if (boss_ticks == 59) hashes[0] = hash;
        if (boss_ticks == 68) hashes[1] = hash;
        if (boss_ticks == 129) hashes[2] = hash;
        if (boss_ticks == 137) hashes[3] = hash;
        if (boss_ticks == 180) hashes[4] = hash;
        if (getenv("ZELIARD_DUMP") &&
            (boss_ticks == 59 || boss_ticks == 68 ||
             boss_ticks == 129 || boss_ticks == 180)) {
            char path[64];
            snprintf(path, sizeof(path), "build/pollo-encounter-%03u.ppm",
                     boss_ticks);
            ok &= write_visual_fixture(path, boss_vga);
        }
    }
    printf("riza_pollo_encounter_probe: ticks=%u start=%u music_at=%u "
           "finish=%u active=%d width=%u music=%02x intro=%02x "
           "hashes=%016llx/%016llx/%016llx/%016llx/%016llx\n", boss_ticks,
           encounter_start, boss_music_frame, encounter_finish,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), boss_game[0xC3], hashes[0],
           hashes[1], hashes[2], hashes[3], hashes[4]);
    ok &= zeliard_fight_masm_vm_active() && saw_boss_music;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= encounter_start && boss_music_frame && encounter_finish;
    ok &= encounter_start == 7 && boss_music_frame == 58;
    ok &= encounter_finish == 114 && boss_game[0xC3] == 0;
    ok &= hashes[0] == 0x3E7C293A14FDD357ULL;
    ok &= hashes[1] == 0x3E7C293A14FDD357ULL;
    ok &= hashes[2] == 0xFA684D7C2FDF3441ULL;
    ok &= hashes[3] == 0xFA684D7C2FDF3441ULL;
    ok &= hashes[4] == 0xFA684D7C2FDF3441ULL;

    /* TORI's release module owns Pollo's 500-point damage word and all
     * flight/turn/dive state. Verify live state, then drive only its
     * documented terminal state so the original death FSM runs unchanged. */
    printf("pollo_state_probe: hp=%02x damage=%04x phase=%02x/%02x/%02x "
           "death=%02x completion=%02x shutdown=%04x\n",
           zeliard_fight_masm_vm_peek_u8(0xA773),
           zeliard_fight_masm_vm_peek_u16(0xA776),
           zeliard_fight_masm_vm_peek_u8(0xA791),
           zeliard_fight_masm_vm_peek_u8(0xA793),
           zeliard_fight_masm_vm_peek_u8(0xA79A),
           zeliard_fight_masm_vm_peek_u8(0xFF2E),
           zeliard_fight_masm_vm_peek_u8(0xFF30),
           zeliard_fight_masm_vm_peek_u16(0x603C));
    ok &= zeliard_fight_masm_vm_peek_u16(0xA776) == 0x01F4;
    ok &= zeliard_fight_masm_vm_peek_u16(0x603C) == 0x83DB;
    ok &= zeliard_fight_masm_vm_poke_u16(0xA776, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA78C, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA78D, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA78E, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA794, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA797, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA798, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xA79A, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned pollo_frames = 0, pollo_completion = 0;
    unsigned long long pollo_completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && pollo_frames < 400 &&
           !(boss_game[0x10] == 0xFF && boss_game[0x11] == 0xFF)) {
        ok &= zeliard_fight_masm_vm_advance(
            boss_game, sizeof(boss_game), boss_vga, sizeof(boss_vga), 20, 0);
        ++pollo_frames;
        if (!pollo_completion &&
            zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            pollo_completion = pollo_frames;
            pollo_completion_hash = fnv1a64(boss_vga, 64000);
        }
    }
    printf("pollo_death_probe: frames=%u completion=%u timer=%02x "
           "defeated=%02x/%02x event=%02x hash=%016llx\n",
           pollo_frames, pollo_completion,
           zeliard_fight_masm_vm_peek_u8(0xA794), boss_game[0x10],
           boss_game[0x11], boss_game[0x13], pollo_completion_hash);
    ok &= pollo_completion == 123;
    ok &= pollo_completion_hash == 0xFA684D7C2FDF3441ULL;
    ok &= boss_game[0x10] == 0xFF && boss_game[0x11] == 0xFF;
    ok &= (boss_game[0x13] & 0x08u) != 0;

    /* A persisted defeated word must bypass the Pollo chamber on revisit. */
    static u8 revisit_game[0x10000];
    static u8 revisit_vga[0x10000];
    prepare_player(revisit_game, 6, 188, 20);
    revisit_game[0x00C3] = 0;
    revisit_game[0x0098] = 1;
    revisit_game[0x10] = revisit_game[0x11] = 0xFF;
    revisit_game[0x13] = 0x0A;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        revisit_game, sizeof(revisit_game), revisit_vga,
        sizeof(revisit_vga));
    unsigned revisit_frames = 0;
    while (zeliard_fight_masm_vm_active() && revisit_frames < 180) {
        ok &= advance_frame(
            revisit_game, revisit_vga, revisit_frames < 16 ? 1 : 0);
        ++revisit_frames;
    }
    printf("pollo_revisit_probe: frames=%u active=%d width=%u music=%02x "
           "selector=%02x pos=%02x/%02x/%02x\n", revisit_frames,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), revisit_game[0xC4],
           revisit_game[0x80], revisit_game[0x82], revisit_game[0x83]);
    ok &= zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 204;
    ok &= zeliard_fight_masm_vm_music_chunk() == 88;
    ok &= revisit_game[0xC4] == 6;

    /* The authored town warp preserves the high-bit selector contract used
     * by main.c to restore Bosque rather than treating it as MP21. */
    static u8 bosque_game[0x10000];
    static u8 bosque_vga[0x10000];
    prepare_player(bosque_game, 6, 149, 13);
    bosque_game[0x00C3] = 0xFF;
    bosque_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        bosque_game, sizeof(bosque_game), bosque_vga, sizeof(bosque_vga));
    const int bosque_handoff = advance_frame(bosque_game, bosque_vga, 1);
    printf("riza_bosque_handoff_probe: advanced=%d active=%d operation=%02x "
           "selector=%02x\n", bosque_handoff,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_exit_operation(),
           zeliard_fight_masm_vm_exit_selector());
    ok &= bosque_handoff && !zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_exit_operation() == 1;
    ok &= zeliard_fight_masm_vm_exit_selector() == 0x83;

    printf("VERDICT: %s: Riza exact fight VM resources and Pollo handoff\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
