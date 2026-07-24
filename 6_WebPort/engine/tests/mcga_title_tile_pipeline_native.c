#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint64_t fnv1a64(const uint8_t *data, size_t size) {
    uint64_t hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; i++) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

int main(void) {
    enum { TABLE = 0x912B, COUNT = 0x19 * 0x22 };
    uint8_t driver[0x10000] = {0};
    uint8_t game[0x10000] = {0};
    uint8_t vga[0x10000];
    for (size_t i = 0; i < 0xC000; i++)
        game[0x4000 + i] = (uint8_t)((i * 17u + 29u) & 0xFFu);
    for (size_t i = 0; i < COUNT; i++)
        game[TABLE + i] = (uint8_t)((i * 37u + 11u) & 0xFFu);
    for (size_t i = 0; i < sizeof(vga); i++)
        vga[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);

    int ok = zeliard_mcga_disp_tilemap_render(game, sizeof(game), TABLE,
                                               game, sizeof(game),
                                               game, sizeof(game)) == 0;
    ok &= zeliard_mcga_disp_tile_render(driver, sizeof(driver), game,
                                        sizeof(game), 0xC7, vga,
                                        sizeof(vga)) == 0;
    ok &= zeliard_mcga_disp_tile_render(driver, sizeof(driver), game,
                                        sizeof(game), 0x00, vga,
                                        sizeof(vga)) == 0;
    uint64_t work = fnv1a64(game, sizeof(game));
    uint64_t screen = fnv1a64(vga, sizeof(vga));
    ok &= work == 0x8BED70B70EB897BAULL;
    ok &= screen == 0xD7E1E0FD7E6B87ABULL;
    printf("mcga_title_tile_pipeline: %s work=%016llx vga=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)work,
           (unsigned long long)screen);
    printf("VERDICT: %s: C 3732->37B4 title pair matches MASM oracle\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
