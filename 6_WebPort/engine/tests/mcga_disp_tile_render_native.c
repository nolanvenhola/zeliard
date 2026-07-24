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
    uint8_t driver[0x10000] = {0};
    uint8_t work[0x10000];
    uint8_t vga[0x10000];
    for (size_t i = 0; i < sizeof(work); i++)
        work[i] = (uint8_t)((i * 17u + 29u) & 0xFFu);
    for (size_t i = 0; i < sizeof(vga); i++)
        vga[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);

    int ok = zeliard_mcga_disp_tile_render(driver, sizeof(driver), work,
                                            sizeof(work), 0xC7, vga,
                                            sizeof(vga)) == 0;
    const uint64_t scratch = fnv1a64(driver + 0x5191, 0x44);
    const uint64_t full = fnv1a64(vga, sizeof(vga));
    const uint64_t visible = fnv1a64(vga, 0xFA00);
    ok &= scratch == 0xC6CB27A7C8FA9A48ULL;
    ok &= full == 0x2E48564BCD87489AULL;
    ok &= visible == 0x7D858614A475149AULL;
    printf("mcga_disp_tile_render: %s scratch=%016llx vga=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)scratch,
           (unsigned long long)full);
    printf("VERDICT: %s: C CS:37B4 matches MASM framebuffer oracle\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
