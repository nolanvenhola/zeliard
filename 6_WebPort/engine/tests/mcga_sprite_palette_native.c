#include "../render/palette.h"

#include <stdio.h>
#include <stdlib.h>

enum {
    GDMCA_LOAD_BASE = 0x2FFC,
    PAL_CYCLE_TBL = 0x3637,
    PAL_R_REG = 0x4289,
    PAL_CYCLE_COUNT = 8,
    PALETTE_REG_SIZE = 48,
    PALETTE_VARIANTS = 10,
};

static unsigned long long fnv1a64(const unsigned char *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; i++) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static unsigned char *read_file(const char *path, size_t *size_out) {
    FILE *file = fopen(path, "rb");
    if (!file)
        return NULL;
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    if (size <= 0) {
        fclose(file);
        return NULL;
    }
    unsigned char *data = malloc((size_t)size);
    if (!data || fread(data, 1, (size_t)size, file) != (size_t)size) {
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    *size_out = (size_t)size;
    return data;
}

/* 105GDMCA.write_palette_byte_mcga uses AX * 0x30 as the palette-table
 * selector, then adds the selected row and column triples for every DAC
 * entry. Keep this byte-for-byte check beside the special sprite AX=0
 * sequence so each 100OPDMO gfx_palette_fn call is covered by driver bytes. */
static int verify_palette_variant(const unsigned char *driver, int ax,
                                  unsigned long long *hash_out) {
    const unsigned char *regs = driver +
        (PAL_R_REG - GDMCA_LOAD_BASE) + ax * PALETTE_REG_SIZE;
    int ok = 1;

    palette_set_opdmo_mcga_from_regs(regs);
    *hash_out = fnv1a64((const unsigned char *)g_palette, sizeof(g_palette));
    for (int row = 0; row < 16; row++) {
        for (int col = 0; col < 16; col++) {
            const unsigned char *row_rgb = regs + row * 3;
            const unsigned char *col_rgb = regs + col * 3;
            palette_color_t actual = g_palette[row * 16 + col];
            unsigned char r = (unsigned char)((row_rgb[0] + col_rgb[0]) * 4u);
            unsigned char g = (unsigned char)((row_rgb[1] + col_rgb[1]) * 4u);
            unsigned char b = (unsigned char)((row_rgb[2] + col_rgb[2]) * 4u);
            if (actual.r != r || actual.g != g || actual.b != b)
                ok = 0;
        }
    }
    return ok;
}

int main(void) {
    static const unsigned long long expected[9] = {
        0x8c1b5d92b515a565ULL, 0x4eb2a0c47ca354e5ULL,
        0xc0ed78c2b506baddULL, 0x35913b1023d1e75dULL,
        0x57244e404ecaffd5ULL, 0x416f780684d0b1d5ULL,
        0x6a17ece3d98cc76dULL, 0xb1d5292d31db3d6dULL,
        0x8c1b5d92b515a565ULL,
    };
    size_t size = 0;
    unsigned char *driver = read_file("assets/105GDMCA.bin", &size);
    int ok = driver && size >= (size_t)(PAL_R_REG - GDMCA_LOAD_BASE +
                                         PALETTE_VARIANTS * PALETTE_REG_SIZE);
    unsigned long long hashes[9] = {0};
    unsigned long long variant_hashes[PALETTE_VARIANTS] = {0};

    for (int ax = 0; ok && ax < PALETTE_VARIANTS; ax++) {
        if (!verify_palette_variant(driver, ax, &variant_hashes[ax]))
            ok = 0;
    }

    for (int slot = 0; ok && slot < 9; slot++) {
        size_t cycle = (size_t)(slot & (PAL_CYCLE_COUNT - 1));
        const unsigned char *rgb = driver + (PAL_CYCLE_TBL - GDMCA_LOAD_BASE) + cycle * 3;
        const unsigned char *regs = driver + (PAL_R_REG - GDMCA_LOAD_BASE);
        palette_set_opdmo_mcga_from_regs_with_rgb0(regs, rgb[0], rgb[1], rgb[2]);
        hashes[slot] = fnv1a64((const unsigned char *)g_palette, sizeof(g_palette));
        if (expected[slot] != 0 && hashes[slot] != expected[slot])
            ok = 0;
    }

    printf("mcga_sprite_palette: %s hashes=", ok ? "PASS" : "FAIL");
    for (int slot = 0; slot < 9; slot++)
        printf("%s%016llx", slot ? "," : "", hashes[slot]);
    putchar('\n');
    printf("mcga_palette_variants: ");
    for (int ax = 0; ax < PALETTE_VARIANTS; ax++)
        printf("%s%016llx", ax ? "," : "", variant_hashes[ax]);
    putchar('\n');
    printf("VERDICT: %s: C AX=0..9 and sprite palette states match 105GDMCA driver bytes\n",
           ok ? "PASS" : "FAIL");
    free(driver);
    return ok ? 0 : 1;
}
