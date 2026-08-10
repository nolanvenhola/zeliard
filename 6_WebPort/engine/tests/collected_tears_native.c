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
    static const unsigned long long expected[10] = {
        0xB8D228A3E2982325ULL, 0x0F5F39D88924A395ULL,
        0x78CE592EA8B5637DULL, 0xCAF5C0C71F14E0E5ULL,
        0xAE2D267AA667A435ULL, 0x69ED26513E3EDB35ULL,
        0xC752D237A749A2FDULL, 0xDC6EC9AD6A15B585ULL,
        0xF3B9F23C1D807A25ULL, 0xED19D671A07BBED3ULL,
    };
    u8 *vga = malloc(0x10000);
    u8 *game = calloc(1, 0x10000);
    if (!vga || !game) return 1;

    int ok = 1;
    unsigned long long hashes[10] = {0};
    for (u8 count = 0; count <= 9; ++count) {
        for (size_t i = 0; i < 0x10000; ++i)
            vga[i] = (u8)(i * 13 + 5);
        game[0x00A0] = count;
        ok &= zeliard_gmmcga_draw_collected_tears(
            vga, 0x10000, game, 0x10000) == 0;
        hashes[count] = fnv1a64(vga, 0x10000);
        ok &= hashes[count] == expected[count];
    }

    /* A loaded game enters through the combined town HUD path.  Confirm the
     * first-frame redraw preserves both top crystals, not just direct calls. */
    memset(game, 0, 0x10000);
    game[0x00A0] = 2;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    ok &= zeliard_gmmcga_draw_first_frame_hud(
        vga, 0x10000, game, 0x10000, 0x0100) == 0;
    const unsigned long long loaded_top_hash = fnv1a64(vga, 13 * 320);
    ok &= loaded_top_hash == 0x68FE4F5528DCB6BDULL;

    printf("collected_tears: %s", ok ? "PASS" : "FAIL");
    for (u8 count = 0; count <= 9; ++count)
        printf(" count%u=%016llx", count, hashes[count]);
    printf(" loaded_top=%016llx\n", loaded_top_hash);
    printf("VERDICT: %s: loaded-game Tear HUD matches release MASM\n",
           ok ? "PASS" : "FAIL");
    free(game);
    free(vga);
    return ok ? 0 : 1;
}
