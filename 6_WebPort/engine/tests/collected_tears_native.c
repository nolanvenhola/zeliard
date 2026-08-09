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
    u8 *game = calloc(1, 0x10000);
    if (!vga || !game) return 1;

    int ok = 1;
    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    game[0x00A0] = 2;
    ok &= zeliard_gmmcga_draw_collected_tears(
        vga, 0x10000, game, 0x10000) == 0;
    const unsigned long long two_hash = fnv1a64(vga, 0x10000);
    ok &= two_hash == 0x78CE592EA8B5637DULL;

    for (size_t i = 0; i < 0x10000; ++i)
        vga[i] = (u8)(i * 13 + 5);
    game[0x00A0] = 9;
    ok &= zeliard_gmmcga_draw_collected_tears(
        vga, 0x10000, game, 0x10000) == 0;
    const unsigned long long nine_hash = fnv1a64(vga, 0x10000);
    ok &= nine_hash == 0xED19D671A07BBED3ULL;

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

    printf("collected_tears: %s count2=%016llx count9=%016llx loaded_top=%016llx\n",
           ok ? "PASS" : "FAIL", two_hash, nine_hash, loaded_top_hash);
    printf("VERDICT: %s: loaded-game Tear HUD matches release MASM\n",
           ok ? "PASS" : "FAIL");
    free(game);
    free(vga);
    return ok ? 0 : 1;
}
