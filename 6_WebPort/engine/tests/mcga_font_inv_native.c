#include "../render/mcga_render.h"
#include "../load/fill_buffer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t n) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < n; i++) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static u8 *read_file(const char *path, size_t *out_size) {
    FILE *file = fopen(path, "rb");
    if (!file) return NULL;
    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }
    long length = ftell(file);
    if (length < 0 || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    u8 *data = (u8 *)malloc((size_t)length);
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    *out_size = (size_t)length;
    return data;
}

int main(void) {
    FILE *file = fopen("assets/105GDMCA.bin", "rb");
    if (!file) {
        printf("VERDICT: INCONCLUSIVE: assets/105GDMCA.bin unavailable\n");
        return 2;
    }
    u8 *seg = (u8 *)calloc(0x10000, 1);
    u8 *vga = (u8 *)calloc(0x10000, 1);
    if (!seg || !vga) {
        free(seg);
        free(vga);
        fclose(file);
        printf("VERDICT: INCONCLUSIVE: allocation failed\n");
        return 2;
    }
    size_t size = fread(&seg[0x2FFC], 1, 0x10000 - 0x2FFC, file);
    fclose(file);
    if (size < 4) {
        printf("VERDICT: INCONCLUSIVE: 105GDMCA.bin is truncated\n");
        free(seg);
        free(vga);
        return 2;
    }

    int waits = zeliard_mcga_disp_font_inv_render(seg, 0, vga, 0x10000);
    unsigned long long hash = fnv1a64(vga, 0xFA00);
    size_t nonzero = 0;
    for (size_t i = 0; i < 0xFA00; i++)
        nonzero += vga[i] != 0;

    int ok = waits == 12 && nonzero == 28541 &&
             hash == 0x33DF220F4A159897ULL;
    printf("mcga_disp_font_inv: %s waits=%d nonzero=%zu fnv=%016llx\n",
           ok ? "PASS" : "FAIL", waits, nonzero, hash);

    size_t font_file_size = 0;
    size_t opdmo_size = 0;
    u8 *font_file = read_file("assets/font.grp", &font_file_size);
    u8 *opdmo = read_file("assets/100opdmo.bin", &opdmo_size);
    size_t font_size = 0;
    u8 *font = font_file ? fill_buffer_decompress(font_file, font_file_size,
                                                   &font_size) : NULL;
    u8 workspace[0x0C80];
    const size_t fade_table = 0x6FF0u - 0x6000u + 4u;
    int consumed = -1;
    if (font && opdmo && font_size >= 2 && opdmo_size > fade_table) {
        u16 font_ptr_a = (u16)font[0] | ((u16)font[1] << 8);
        consumed = zeliard_mcga_anim_fade_decode(font, font_size, font_ptr_a,
                                                  opdmo + fade_table,
                                                  opdmo_size - fade_table,
                                                  workspace, sizeof(workspace));
    }
    unsigned long long fade_hash = consumed > 0 ? fnv1a64(workspace, sizeof(workspace)) : 0;
    size_t fade_nonzero = 0;
    for (size_t i = 0; i < sizeof(workspace) && consumed > 0; i++)
        fade_nonzero += workspace[i] != 0;
    int fade_ok = consumed == 32 && fade_nonzero == 337 &&
                  fade_hash == 0xE200DE9ED666F4A2ULL;
    printf("mcga_anim_fade_decode: %s consumed=%d nonzero=%zu fnv=%016llx\n",
           fade_ok ? "PASS" : "FAIL", consumed, fade_nonzero, fade_hash);
    ok &= fade_ok;

    u8 *work = (u8 *)calloc(0x10000, 1);
    static const unsigned long long draw_vga_expected[10] = {
        0xDD14FCC6528CAB25ULL, 0xFA151EAFED0E5B83ULL,
        0x07BC4B13B6E7F813ULL, 0x479F0D47B74D9A23ULL,
        0xB82CFB9C3EAEE5A3ULL, 0xC5B2ADE66BD56655ULL,
        0xECD053EDB47C1CA3ULL, 0x13035385BDDC1803ULL,
        0x40823048DCEDE303ULL, 0xB5669CFA9BF9B903ULL,
    };
    static const unsigned long long draw_work_expected[10] = {
        0x2B18D38AA5B9A504ULL, 0xA0229313AB0384C2ULL,
        0xD24B2BA395637040ULL, 0x0A73FBD8AE89C85CULL,
        0x8BD8FDBBFBFB8969ULL, 0xDE346A04F7EF8E74ULL,
        0x7F9E1C3E07EE81FEULL, 0xB4FC14F7C5BD8FA2ULL,
        0x215308F64AFEC0A2ULL, 0xE9DEDAEA93F4F1A2ULL,
    };
    int draw_ok = work != NULL && consumed > 0;
    if (draw_ok) {
        memcpy(seg + 0x4511, workspace, sizeof(workspace));
        memset(vga, 0, 0x10000);
        for (int frame = 0; frame < 10; frame++) {
            int result = zeliard_mcga_anim_draw_step(seg, 0x10000, work,
                                                     0x10000, vga, 0x10000,
                                                     (u16)frame, 0x0020, 0x5078);
            unsigned long long vga_hash = fnv1a64(vga, 0xFA00);
            unsigned long long work_hash = fnv1a64(work, 0x10000);
            if (result != 0 || vga_hash != draw_vga_expected[frame] ||
                work_hash != draw_work_expected[frame]) {
                printf("  frame=%d result=%d vga=%016llx expected=%016llx work=%016llx expected=%016llx\n",
                       frame, result, vga_hash, draw_vga_expected[frame],
                       work_hash, draw_work_expected[frame]);
                draw_ok = 0;
                break;
            }
        }
    }
    printf("mcga_anim_draw_step: %s\n", draw_ok ? "PASS" : "FAIL");
    ok &= draw_ok;

    free(font_file);
    free(opdmo);
    free(font);
    free(work);
    printf("VERDICT: %s: MCGA 38E6, 32C9, and 332C parity\n",
           ok ? "PASS" : "FAIL");
    free(seg);
    free(vga);
    return ok ? 0 : 1;
}
