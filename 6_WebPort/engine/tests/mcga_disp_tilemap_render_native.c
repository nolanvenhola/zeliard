#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>

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
    uint8_t game[0x10000];
    uint8_t work[0x10000];
    for (size_t i = 0; i < sizeof(game); i++)
        game[i] = (uint8_t)((i * 17u + 29u) & 0xFFu);
    for (size_t i = 0; i < COUNT; i++)
        game[TABLE + i] = (uint8_t)((i * 37u + 11u) & 0xFFu);
    for (size_t i = 0; i < sizeof(work); i++)
        work[i] = (uint8_t)((i * 7u + 3u) & 0xFFu);

    int ok = zeliard_mcga_disp_tilemap_render(game, sizeof(game), TABLE,
                                               game, sizeof(game),
                                               work, sizeof(work)) == 0;
    uint64_t hash = fnv1a64(work, sizeof(work));
    ok &= hash == 0x46103A7E1CD5E485ULL;
    printf("mcga_disp_tilemap_render: %s work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)hash);
    printf("VERDICT: %s: C CS:3732 matches MASM work-segment oracle\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
