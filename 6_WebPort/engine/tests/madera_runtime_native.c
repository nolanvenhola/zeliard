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

static void prepare_player(u8 *game) {
    memset(game, 0, 0x10000);
    /* MP20's x205/y47 door arrives at MP30 x21/y6. 200FIGHT stores the
     * scroll-relative x and wrapped row exactly as authored here. */
    game[0x0080] = 5;
    game[0x0082] = (6 - 9) & 0x3F;
    game[0x0083] = 12;
    game[0x0091] = 1;
    game[0x00B3] = 1;
    game[0x00C4] = 5;
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
    u8 *image = platform_load_asset("mp30.mdt", &size);
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
    prepare_player(game);
    palette_set_game_mcga();
    const int started = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const unsigned long long first_frame = fnv1a64(vga, 64000);
    unsigned monsters = 0, items = 0, families = 0;
    ok &= map_shape(&monsters, &items, &families);
    printf("madera_probe: started=%d active=%d frame_ready=%d width=%u "
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
    ok &= monsters == 30 && items == 15 && families == 0x0E;
    ok &= first_frame == 0xB784912E0CDFC25FULL;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/madera-first-frame.ppm", vga);

    const u16 objects = (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    u8 before[45][16];
    memset(before, 0, sizeof(before));
    for (unsigned object = 0; object < 45; ++object)
        for (unsigned byte = 0; byte < 16; ++byte)
            before[object][byte] = (u8)zeliard_fight_masm_vm_peek_u8(
                (u16)(objects + object * 16u + byte));
    for (unsigned frame = 0; frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    unsigned changed_families = 0;
    for (unsigned object = 0; object < 45; ++object) {
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
    printf("madera_ai_probe: changed=%02x frame=%016llx\n",
           changed_families, moving_frame);
    ok &= changed_families == 0x0E;
    ok &= moving_frame == 0x473C7472FCC5CA7FULL;

    /* MP30 object 40 is the sword-revealed Hero's Crest.  Confirm its
     * authored stdply byte-12h/mask-08h link, then prove both that event
     * byte and the separate 9Ch inventory marker survive a map reload. */
    static u8 crest_game[0x10000];
    static u8 crest_vga[0x10000];
    prepare_player(crest_game);
    crest_game[0x0080] = 166 - 16;
    crest_game[0x0082] = (54 - 9) & 0x3F;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        crest_game, sizeof(crest_game), crest_vga, sizeof(crest_vga));
    const u16 crest_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 crest_object = (u16)(crest_objects + 40u * 16u);
    const int crest_link =
        zeliard_fight_masm_vm_peek_u8((u16)(crest_object + 11u)) == 0x12 &&
        zeliard_fight_masm_vm_peek_u8((u16)(crest_object + 12u)) == 0x00 &&
        zeliard_fight_masm_vm_peek_u8((u16)(crest_object + 13u)) == 0x08;
    const u16 crest_head = zeliard_fight_masm_vm_peek_u16(crest_object);
    const unsigned long long crest_pre_frame = fnv1a64(crest_vga, 64000);

    static u8 crest_revisit_game[0x10000];
    static u8 crest_revisit_vga[0x10000];
    prepare_player(crest_revisit_game);
    crest_revisit_game[0x0080] = 166 - 16;
    crest_revisit_game[0x0082] = (54 - 9) & 0x3F;
    crest_revisit_game[0x12] = 0x08;
    crest_revisit_game[0x9C] = 0xFF;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        crest_revisit_game, sizeof(crest_revisit_game), crest_revisit_vga,
        sizeof(crest_revisit_vga));
    const u16 revisit_objects =
        (u16)zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 revisit_object = (u16)(revisit_objects + 40u * 16u);
    const u16 revisit_head =
        zeliard_fight_masm_vm_peek_u16(revisit_object);
    const u16 revisit_link =
        zeliard_fight_masm_vm_peek_u16((u16)(revisit_object + 11u));
    const unsigned long long crest_revisit_frame =
        fnv1a64(crest_revisit_vga, 64000);
    printf("madera_hero_crest_persistence: link=%d object=%04x>%04x "
           "persist=%02x inventory=%02x link_after=%04x "
           "frame=%016llx>%016llx\n",
           crest_link, crest_head, revisit_head, crest_revisit_game[0x12],
           crest_revisit_game[0x9C], revisit_link, crest_pre_frame,
           crest_revisit_frame);
    ok &= crest_link && crest_head == 0x00A6 && revisit_head == 0x00A6 &&
        revisit_link == 0x0012 && crest_revisit_game[0x12] == 0x08 &&
        crest_revisit_game[0x9C] == 0xFF;

    /* The same authored door is bidirectional: MP30 x21/y6 returns to
     * Peligro x205/y47 and restores the area-2 resource family. */
    static u8 return_game[0x10000];
    static u8 return_vga[0x10000];
    prepare_player(return_game);
    return_game[0x00C3] = 0xFF;
    return_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        return_game, sizeof(return_game), return_vga, sizeof(return_vga));
    int returned = advance_frame(return_game, return_vga, 1);
    returned |= advance_frame(return_game, return_vga, 1);
    const unsigned long long return_frame = fnv1a64(return_vga, 64000);
    printf("madera_return_probe: advanced=%d active=%d width=%u music=%02x "
           "pos=%02x/%02x/%02x frame=%016llx\n", returned,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(), return_game[0x80],
           return_game[0x82], return_game[0x83], return_frame);
    ok &= returned && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 224;
    ok &= zeliard_fight_masm_vm_music_chunk() == 87;

    /* MP30's paired-layer door hands off to selector 6, the Riza ticket,
     * without mutating the persistent player record. */
    static u8 riza_game[0x10000];
    static u8 riza_vga[0x10000];
    prepare_player(riza_game);
    riza_game[0x0080] = 19 - 16;
    riza_game[0x0082] = (49 - 9) & 0x3F;
    riza_game[0x00C3] = 0xFF;
    riza_game[0x0098] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        riza_game, sizeof(riza_game), riza_vga, sizeof(riza_vga));
    int riza_handoff = advance_frame(riza_game, riza_vga, 1);
    printf("madera_riza_handoff_probe: advanced=%d active=%d width=%u "
           "music=%02x objects=%04x\n", riza_handoff,
           zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_music_chunk(),
           zeliard_fight_masm_vm_peek_u16(0xC010));
    ok &= riza_handoff && zeliard_fight_masm_vm_active();
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 204;
    ok &= zeliard_fight_masm_vm_music_chunk() == 88;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC010) == 0xCEA8;

    printf("VERDICT: %s: Madera exact fight VM resources and state\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
