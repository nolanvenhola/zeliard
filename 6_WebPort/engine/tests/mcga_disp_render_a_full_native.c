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
    static const uint64_t stage_expected[] = {
        0x4B65CF9E0219777DULL, 0x21F995DF91097113ULL,
        0xBCFCE4C43AC64D0BULL, 0x904E7CFBDDD771CBULL,
    };
    static const int stage_numbers[] = {1, 8, 9, 16};
    uint8_t driver[0x10000] = {0};
    uint8_t game[0x10000];
    uint8_t work[0x10000] = {0};
    uint8_t vga[0x10000];
    for (size_t i = 0; i < sizeof(game); i++)
        game[i] = (uint8_t)((i * 17u + 29u) & 0xFFu);
    for (size_t i = 0; i < sizeof(vga); i++)
        vga[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);

    int ok = zeliard_mcga_disp_render_a_full(driver, sizeof(driver),
                                               game, sizeof(game),
                                               work, sizeof(work),
                                               0, 0x070F, 0x4170, 0x9000,
                                               vga, sizeof(vga)) == 0;
    const uint64_t work_hash = fnv1a64(work, sizeof(work));
    const uint64_t vga_hash = fnv1a64(vga, sizeof(vga));
    const uint64_t visible_hash = fnv1a64(vga, 0xFA00);
    ok &= work_hash == 0x21D1042FD1AD5D0FULL;
    ok &= vga_hash == 0xCC1B898574C695CBULL;
    ok &= visible_hash == 0x904E7CFBDDD771CBULL;
    for (size_t stage = 0; stage < sizeof(stage_numbers) / sizeof(stage_numbers[0]); stage++) {
        uint8_t stage_driver[0x10000] = {0};
        uint8_t stage_work[0x10000] = {0};
        uint8_t stage_vga[0x10000];
        for (size_t i = 0; i < sizeof(stage_vga); i++)
            stage_vga[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);
        ok &= zeliard_mcga_disp_render_a_full_stage(
            stage_driver, sizeof(stage_driver), game, sizeof(game),
            stage_work, sizeof(stage_work), 0, 0x070F, 0x4170, 0x9000,
            stage_vga, sizeof(stage_vga), stage_numbers[stage]) == 0;
        const uint64_t hash = fnv1a64(stage_vga, 0xFA00);
        printf("mcga_disp_render_a_full: pass=%d %016llx\n",
               stage_numbers[stage], (unsigned long long)hash);
        ok &= hash == stage_expected[stage];
    }
    printf("mcga_disp_render_a_full: %s work=%016llx vga=%016llx visible=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)work_hash,
           (unsigned long long)vga_hash, (unsigned long long)visible_hash);
    printf("VERDICT: %s: C CS:30FC matches MASM framebuffer oracle\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
