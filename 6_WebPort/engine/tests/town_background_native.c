#include "../render/town_background.h"

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

static u8 *read_file(const char *name, size_t *size) {
    FILE *file = fopen(name, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END);
    const long length = ftell(file);
    rewind(file);
    u8 *data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        data = NULL;
    }
    fclose(file);
    *size = length > 0 ? (size_t)length : 0;
    return data;
}

int main(void) {
    size_t file_size = 0;
    u8 *file = read_file("assets/ympd.bin", &file_size);
    size_t mole_file_size = 0;
    u8 *mole_file = read_file("assets/mole.bin", &mole_file_size);
    u8 *mole = calloc(1, 0x10000);
    u8 *scratch = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    int ok = file && file_size > 4 && mole_file && mole_file_size > 4 &&
             mole_file_size - 4 <= 0x10000 && mole && scratch && vga;
    int mole_result = -99;
    if (ok) {
        memcpy(mole, mole_file + 4, mole_file_size - 4);
        mole_result = zeliard_mole_render_mcga(mole, 0x10000, vga, 0x10000);
        ok = mole_result == 0;
    }
    const unsigned long long mole_hash = ok ? fnv1a64(vga, 0x10000) : 0;
    if (ok && getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/mole-frame.bin", "wb");
        if (dump) {
            fwrite(vga, 1, 0x10000, dump);
            fclose(dump);
        }
    }
    ok &= mole_hash == 0xEF69F3CFFCC4FE6EULL;
    if (ok)
        ok = zeliard_ympd_render_mcga(file + 4, file_size - 4,
                                      scratch, 0x10000, vga, 0x10000) == 0;
    const unsigned long long vga_hash = ok ? fnv1a64(vga, 0x10000) : 0;
    const unsigned long long scratch_hash = ok ? fnv1a64(scratch, 0x4D00) : 0;
    if (ok && getenv("ZELIARD_DUMP")) {
        FILE *dump = fopen("build/town-background-frame.bin", "wb");
        if (dump) {
            fwrite(vga, 1, 0x10000, dump);
            fclose(dump);
        }
    }
    ok &= vga_hash == 0x14093BAEA087B3ADULL;
    ok &= scratch_hash == 0x7102E40B2CF1F6DFULL;
    printf("town_background: %s rc=%d mole=%016llx combined=%016llx scratch=%016llx\n",
           ok ? "PASS" : "FAIL", mole_result, mole_hash, vga_hash, scratch_hash);
    printf("VERDICT: %s: 207MOLE + 208YMPD MCGA frame matches release MASM\n",
           ok ? "PASS" : "FAIL");
    free(vga);
    free(scratch);
    free(mole);
    free(mole_file);
    free(file);
    return ok ? 0 : 1;
}
