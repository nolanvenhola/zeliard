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

    printf("town_mcga_services: %s vga=%016llx packed=%016llx masks=%016llx\n",
           ok ? "PASS" : "FAIL",
           fnv1a64(vga, 0x10000), fnv1a64(ds + 0x4100, 144),
           fnv1a64(es + 0x7000, 24));
    printf("VERDICT: %s: town MCGA services match MASM oracles\n",
           ok ? "PASS" : "FAIL");
    free(vga);
    return ok ? 0 : 1;
}
