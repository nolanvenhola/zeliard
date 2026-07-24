#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>

static uint64_t fnv1a64(const uint8_t *data, size_t n) {
    uint64_t h = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < n; i++) {
        h ^= data[i];
        h *= 0x100000001B3ULL;
    }
    return h;
}

int main(void) {
    uint8_t vga[0x10000];
    for (size_t i = 0; i < sizeof(vga); i++)
        vga[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);

    int ok = zeliard_mcga_disp_drv_seg_3_seed(vga, sizeof(vga)) == 0;
    const uint64_t visible = fnv1a64(vga, 320u * 200u);
    const uint64_t full = fnv1a64(vga, sizeof(vga));
    ok &= visible == 0x10C1DBF72FB2AB25ULL;
    ok &= full == 0x65718FD904161F25ULL;
    ok &= vga[0] == 0x00 && vga[1] == 0x10;
    ok &= vga[320] == 0x10 && vga[321] == 0x00;
    ok &= vga[0xFA00] == (uint8_t)((0xFA00u * 37u + 11u) & 0xFFu);
    printf("mcga_disp_drv_seg_3: %s visible=%016llx full=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)visible,
           (unsigned long long)full);
    printf("VERDICT: %s: C CS:3707 seed matches MASM framebuffer oracle\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
