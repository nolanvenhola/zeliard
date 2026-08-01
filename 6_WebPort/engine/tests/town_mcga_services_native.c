#include "../render/town_mcga.h"

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

int main(void) {
    u8 *vga = malloc(0x10000);
    if (!vga) return 1;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 29 + 7);

    int ok = zeliard_gmmcga_clear_playfield(vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xDBAAD528760DFB25ULL;
    ok &= fnv1a64(vga, 320 * 200) == 0x4B4535E7677CB325ULL;
    for (u16 y = 0; y < 200; ++y) {
        for (u16 x = 0; x < 320; ++x) {
            const int cleared = x >= 48 && x < 272 && y >= 14 && y < 158;
            const u8 expected = cleared ? 0 : (u8)(((size_t)y * 320 + x) * 29 + 7);
            ok &= vga[(size_t)y * 320 + x] == expected;
        }
    }
    ok &= zeliard_gmmcga_clear_playfield(vga, 0xFFFF) == -1;

    static const unsigned long long fade_hashes[8] = {
        0x72AEEC8CE08F84E5ULL, 0x5EFAA6927F6A62E5ULL,
        0x07D8F5540EA329C5ULL, 0x977857E682AAD705ULL,
        0xDAEABA86ED6BA7E5ULL, 0x146EB61A440439A5ULL,
        0xC54918C143A086A5ULL, 0x4B4535E7677CB325ULL,
    };
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 29 + 7);
    for (u8 pass = 0; pass < 8; ++pass) {
        ok &= zeliard_gmmcga_building_fade_pass(
            vga, 0x10000, pass) == 0;
        ok &= fnv1a64(vga, 320 * 200) == fade_hashes[pass];
    }
    ok &= fnv1a64(vga, 0x10000) == 0xDBAAD528760DFB25ULL;
    ok &= zeliard_gmmcga_building_fade_pass(vga, 0x10000, 8) == -1;

    u8 ds[0x10000] = {0};
    u8 es[0x10000] = {0};
    for (size_t i = 0; i < 48; ++i)
        ds[0x4130 + i] = (u8)(i * 37 + 11);
    for (u16 row = 0; row < 8; ++row) {
        const u16 values[3] = {
            (u16)(1u << (row * 2)), (u16)(1u << (row * 2 + 1)),
            (u16)(0x8000u >> row),
        };
        for (u16 plane = 0; plane < 3; ++plane) {
            const size_t at = 0x4160 + row * 6 + plane * 2;
            ds[at] = (u8)values[plane];
            ds[at + 1] = (u8)(values[plane] >> 8);
        }
    }
    memset(es + 0x7000, 0xA5, 24);
    ok &= zeliard_gtmcga_encode_tile_block(ds, sizeof(ds), 0x4100,
                                            es, sizeof(es), 0x7000, 3) == 0;
    ok &= fnv1a64(ds + 0x4100, 144) == 0x67F69B87D30BB04FULL;
    ok &= fnv1a64(es + 0x7000, 24) == 0x13E086083EC42BBEULL;
    static const u8 expected_masks[24] = {
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xE7, 0xD7, 0xBB, 0x7B, 0xFC, 0xFD, 0xFA, 0xF6,
    };
    ok &= memcmp(es + 0x7000, expected_masks, sizeof(expected_masks)) == 0;
    ok &= zeliard_gtmcga_encode_tile_block(ds, 0x4100 + 143, 0x4100,
                                            es, sizeof(es), 0x7000, 3) == -1;

    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    ok &= zeliard_gmmcga_draw_status_line(vga, 0x10000, 0, 0x0204,
                                           0x2100) == 0;
    ok &= zeliard_gmmcga_draw_status_line(vga, 0x10000, 0, 0x021C,
                                           0x4200) == 0;
    ok &= zeliard_gmmcga_draw_status_line(vga, 0x10000, 0, 0x481C,
                                           0x4200) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x0F433DB68B152D2AULL;
    ok &= fnv1a64(vga, 320 * 200) == 0x4305C733A644D52AULL;
    ok &= zeliard_gmmcga_draw_status_line(vga, 0x10000, 1, 0x0204,
                                           0x2100) == -1;

    u8 life_seg[0x10000] = {0};
    life_seg[0x0090] = 0x45;
    life_seg[0x0091] = 0x02;
    life_seg[0x00B2] = 0x20;
    life_seg[0x00B3] = 0x03;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    ok &= zeliard_gmmcga_draw_life_scale(vga, 0x10000, 0x0500) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xCC1710A9629B2445ULL;
    ok &= zeliard_gmmcga_draw_life_max(vga, 0x10000, life_seg,
                                        sizeof(life_seg)) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x8922D9FFA5978415ULL;
    ok &= zeliard_gmmcga_draw_life_current(vga, 0x10000, life_seg,
                                            sizeof(life_seg)) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xB98E2BD56673813DULL;
    ok &= zeliard_gmmcga_draw_life_max(vga, 0x10000, life_seg, 0x00B3) == -1;

    for (size_t i = 0; i < 0x10000; ++i) {
        life_seg[i] = 0;
        vga[i] = (u8)(i * 11 + 9);
    }
    life_seg[0xF504] = 0x00;
    life_seg[0xF505] = 0x80;
    for (size_t character = 0; character < 96; ++character) {
        for (size_t row = 0; row < 8; ++row)
            life_seg[0x8000 + character * 8 + row] =
                (u8)(character * 37 + row * 19 + 0x53);
    }
    static const u8 life_record[] = {0x0E, 0xA3, 0x00, 0x05,
                                     'L', 'I', 'F', 'E', '!'};
    memcpy(life_seg + 0x9000, life_record, sizeof(life_record));
    ok &= zeliard_gmmcga_draw_town_text_record(vga, 0x10000, life_seg,
                                                sizeof(life_seg), 0x9000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x9ECCC715238D7787ULL;
    ok &= life_seg[0x2CBD] == 0x09 && life_seg[0x2CBE] == 0x2D;

    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 11 + 9);
    life_seg[0x9003] = 0x04;
    ok &= zeliard_gmmcga_draw_hud_label(vga, 0x10000, life_seg,
                                         sizeof(life_seg), 0x9000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x887B657AB4281BB6ULL;
    ok &= life_seg[0x2CBD] == 0x1B && life_seg[0x2CBE] == 0x12;

    memset(life_seg, 0, sizeof(life_seg));
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 7 + 3);
    life_seg[0xF502] = 0x00;
    life_seg[0xF503] = 0x80;
    for (size_t digit = 0; digit < 16; ++digit) {
        for (size_t row = 0; row < 8; ++row)
            life_seg[0x8000 + digit * 8 + row] =
                (u8)(digit * 31 + row * 23 + 0x41);
    }
    life_seg[0x24EB] = 0x2A;
    life_seg[0x008B] = 0x39; life_seg[0x008C] = 0x30;
    life_seg[0x0085] = 0x12; life_seg[0x0086] = 0x56; life_seg[0x0087] = 0x34;
    life_seg[0x0093] = 0x03; life_seg[0x0094] = 0xE1; life_seg[0x0095] = 0x10;
    life_seg[0x009D] = 0x03; life_seg[0x00AD] = 0x4D;
    ok &= zeliard_gmmcga_draw_almas(vga, 0x10000, life_seg,
                                     sizeof(life_seg)) == 0;
    unsigned long long almas_hash = fnv1a64(vga, 0x10000);
    ok &= almas_hash == 0x493B33F0AD38F70DULL;
    ok &= zeliard_gmmcga_draw_gold(vga, 0x10000, life_seg,
                                    sizeof(life_seg)) == 0;
    unsigned long long gold_hash = fnv1a64(vga, 0x10000);
    ok &= gold_hash == 0xF361E65421F56679ULL;
    ok &= zeliard_gmmcga_draw_spell_charge(vga, 0x10000, life_seg,
                                            sizeof(life_seg)) == 0;
    unsigned long long spell_hash = fnv1a64(vga, 0x10000);
    ok &= spell_hash == 0x34E71A370A27FF42ULL;
    ok &= zeliard_gmmcga_draw_shield_hp(vga, 0x10000, life_seg,
                                         sizeof(life_seg)) == 0;
    unsigned long long shield_hash = fnv1a64(vga, 0x10000);
    ok &= shield_hash == 0xFEF9AC4EA582B005ULL;
    printf("town_mcga_numeric: almas=%016llx gold=%016llx spell=%016llx shield=%016llx\n",
           almas_hash, gold_hash, spell_hash, shield_hash);
    life_seg[0x009D] = 0;
    life_seg[0x01AA] = 0x58;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 7 + 3);
    ok &= zeliard_gmmcga_draw_spell_charge(vga, 0x10000, life_seg,
                                            sizeof(life_seg)) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x5CA562D8E09D063EULL;
    life_seg[0x0093] = 0;
    unsigned long long no_shield_before = fnv1a64(vga, 0x10000);
    ok &= zeliard_gmmcga_draw_shield_hp(vga, 0x10000, life_seg,
                                         sizeof(life_seg)) == 0;
    ok &= fnv1a64(vga, 0x10000) == no_shield_before;

    memset(life_seg, 0, sizeof(life_seg));
    life_seg[0xF502] = 0x00; life_seg[0xF503] = 0x80;
    life_seg[0xF504] = 0x00; life_seg[0xF505] = 0x90;
    for (size_t digit = 0; digit < 16; ++digit) {
        for (size_t row = 0; row < 8; ++row)
            life_seg[0x8000 + digit * 8 + row] =
                (u8)(digit * 31 + row * 23 + 0x80);
    }
    for (size_t character = 0; character < 96; ++character) {
        for (size_t row = 0; row < 8; ++row)
            life_seg[0x9000 + character * 8 + row] =
                (u8)(character * 31 + row * 23 + 0x90);
    }
    static const u8 first_frame_records[] = {
        0x0E, 0xA3, 0x00, 0x04, 'L', 'I', 'F', 'E',
        0x1E, 0xBB, 0x03, 0x05, 'A', 'L', 'M', 'A', 'S',
        0x0D, 0xBB, 0x01, 0x04, 'G', 'O', 'L', 'D',
        0x0D, 0xAF, 0x01, 0x05, 'P', 'L', 'A', 'C', 'E',
    };
    memcpy(life_seg + 0x6C93, first_frame_records, sizeof(first_frame_records));
    static const u8 castle_record[] = {
        0x08, 0xAF, 0x02, 0x06, 'C', 'A', 'S', 'T', 'L', 'E'
    };
    memcpy(life_seg + 0x9800, castle_record, sizeof(castle_record));
    life_seg[0x24EB] = 0x2A;
    life_seg[0x008B] = 0x39; life_seg[0x008C] = 0x30;
    life_seg[0x0085] = 0x12; life_seg[0x0086] = 0x56; life_seg[0x0087] = 0x34;
    life_seg[0x0090] = 0x45; life_seg[0x0091] = 0x02;
    life_seg[0x0093] = 0x03; life_seg[0x0094] = 0xE1; life_seg[0x0095] = 0x10;
    life_seg[0x009D] = 0x03; life_seg[0x00AD] = 0x4D;
    life_seg[0x00B2] = 0x20; life_seg[0x00B3] = 0x03;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    ok &= zeliard_gmmcga_draw_first_frame_hud(vga, 0x10000, life_seg,
                                               sizeof(life_seg), 0x9800) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xA4388787A04C4E76ULL;
    u8 combined_state[9];
    memcpy(combined_state, life_seg + 0x2433, 7);
    memcpy(combined_state + 7, life_seg + 0x2CBD, 2);
    ok &= fnv1a64(combined_state, sizeof(combined_state)) ==
          0x36F73C3154C60582ULL;

    u8 game_seg[0x10000];
    for (size_t i = 0; i < sizeof(game_seg); ++i)
        game_seg[i] = (u8)(i * 29 + 7);
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 17 + 3);
    ok &= zeliard_gtmcga_capture_playfield(vga, 0x10000, game_seg,
                                            sizeof(game_seg)) == 0;
    ok &= fnv1a64(game_seg + 0xA000, 0x1500) == 0xE6CF3F9146BCEB25ULL;
    ok &= zeliard_gtmcga_capture_playfield(vga, 0xFFFF, game_seg,
                                            sizeof(game_seg)) == -1;

    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 37 + 11);
    ok &= zeliard_gtmcga_scroll_view_left(vga, 0x10000) == 0;
    const unsigned long long scroll_left_hash = fnv1a64(vga, 0x10000);
    ok &= scroll_left_hash == 0x3FC2021C15FF0B25ULL;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 37 + 11);
    ok &= zeliard_gtmcga_scroll_view_right(vga, 0x10000) == 0;
    const unsigned long long scroll_right_hash = fnv1a64(vga, 0x10000);
    ok &= scroll_right_hash == 0x402C490240B31725ULL;
    ok &= zeliard_gtmcga_scroll_view_left(vga, 0xFFFF) == -1;

    printf("town_mcga_services: %s vga=%016llx packed=%016llx masks=%016llx capture=%016llx\n",
           ok ? "PASS" : "FAIL",
           fnv1a64(vga, 0x10000), fnv1a64(ds + 0x4100, 144),
           fnv1a64(es + 0x7000, 24),
           fnv1a64(game_seg + 0xA000, 0x1500));
    printf("town_mcga_scroll: left=%016llx right=%016llx\n",
           scroll_left_hash, scroll_right_hash);
    printf("VERDICT: %s: town MCGA services match MASM oracles\n",
           ok ? "PASS" : "FAIL");
    free(vga);
    return ok ? 0 : 1;
}
