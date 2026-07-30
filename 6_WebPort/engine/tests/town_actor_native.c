#include "../load/fill_buffer.h"
#include "../render/town_mcga.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static u8 *read_file(const char *path, size_t *size) {
    FILE *file = fopen(path, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END);
    const long length = ftell(file);
    fseek(file, 0, SEEK_SET);
    u8 *data = length >= 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        data = NULL;
    }
    fclose(file);
    if (data) *size = (size_t)length;
    return data;
}

static u8 *decode_asset(const char *path, size_t *decoded_size) {
    size_t size = 0;
    u8 *file = read_file(path, &size);
    u8 *decoded = file ? fill_buffer_decompress(file, size, decoded_size) : NULL;
    free(file);
    return decoded;
}

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long value = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        value ^= data[i];
        value *= 0x100000001B3ULL;
    }
    return value;
}

int main(void) {
    static const u8 ids[6] = {0, 1, 2, 3, 4, 5};
    u8 game_data[0x10000] = {0};
    u8 mask_data[0x10000] = {0};
    u8 vga[0x10000] = {0};
    size_t cpat_size = 0, mman_size = 0;
    u8 *cpat = decode_asset("assets/cpat.grp", &cpat_size);
    u8 *mman = decode_asset("assets/mman.grp", &mman_size);
    int ok = cpat && cpat_size <= 0x8000 && mman && mman_size >= 0x120;
    if (ok) memcpy(game_data + 0x8000, cpat, cpat_size);
    memset(vga + 0xFA00, 0x2D, 0x180);
    ok &= zeliard_gtmcga_draw_npc_tiles(ids, sizeof(ids), game_data,
                                         sizeof(game_data), vga, sizeof(vga)) == 0;
    const unsigned long long npc_hash = fnv1a64(vga + 0xFA00, 0x180);

    if (ok) {
        memcpy(game_data + 0x6000, mman, 0x120);
        memcpy(mask_data + 0x8000, cpat, 0x30);
    }
    for (size_t i = 0; i < 0x180; ++i)
        vga[0xFA00 + i] = (u8)((i * 13 + 7) & 0x3F);
    ok &= zeliard_gtmcga_draw_player_tiles(ids, sizeof(ids), game_data,
                                            sizeof(game_data), mask_data,
                                            sizeof(mask_data), vga,
                                            sizeof(vga)) == 0;
    const unsigned long long player_hash = fnv1a64(vga + 0xFA00, 0x180);
    ok &= npc_hash == 0x077B30A88E854340ULL;
    ok &= player_hash == 0x9CCD07B60E989122ULL;
    free(cpat);
    free(mman);
    printf("town_actor: %s npc=%016llx player=%016llx\n",
           ok ? "PASS" : "FAIL", npc_hash, player_hash);
    printf("VERDICT: %s: GTMCGA actor blitters\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
