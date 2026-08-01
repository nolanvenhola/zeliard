#include "../load/fill_buffer.h"
#include "../game/room_runtime.h"
#include "../render/room_mcga.h"
#include "../render/town_mcga.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long value = 0xCBF29CE484222325ULL;
    while (size--) { value ^= *data++; value *= 0x100000001B3ULL; }
    return value;
}

static u8 *read_file(const char *path, size_t *size) {
    FILE *file = fopen(path, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END); long length = ftell(file); rewind(file);
    u8 *data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data); data = NULL;
    }
    fclose(file); *size = data ? (size_t)length : 0; return data;
}

static int load_payload(u8 *segment, u16 offset, const char *path) {
    size_t size = 0; u8 *file = read_file(path, &size);
    if (!file || size < 4) { free(file); return -1; }
    const size_t payload_size = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (payload_size > size - 4 || payload_size > 0x10000u - offset) {
        free(file); return -2;
    }
    memcpy(segment + offset, file + 4, payload_size); free(file); return 0;
}

static int load_raw(u8 *segment, u16 offset, const char *path) {
    size_t size = 0; u8 *file = read_file(path, &size);
    if (!file || size > 0x10000u - offset) { free(file); return -1; }
    memcpy(segment + offset, file, size); free(file); return 0;
}

static int load_font(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *file = read_file("assets/font.grp", &size);
    u8 *decoded = file ? fill_buffer_decompress(file, size, &decoded_size) : NULL;
    free(file);
    if (!decoded || decoded_size > 0x0B00) { free(decoded); return -1; }
    memcpy(segment + 0xF500, decoded, decoded_size); free(decoded);
    for (u16 offset = 0; offset < 6; offset += 2) {
        u16 value = (u16)(segment[0xF500 + offset] |
                          (segment[0xF501 + offset] << 8));
        value = (u16)(value + 0xF500);
        segment[0xF500 + offset] = (u8)value;
        segment[0xF501 + offset] = (u8)(value >> 8);
    }
    return 0;
}

static int load_tiles(const char *path, u8 *tiles) {
    size_t size = 0, plane_size = 0;
    u8 *file = read_file(path, &size);
    u8 *planes = file ? fill_buffer_decompress(file, size, &plane_size) : NULL;
    free(file);
    int result = planes ? zeliard_gmmcga_prepare_room_tiles(
        planes, plane_size, tiles, 0x3000, 0x100) : -1;
    free(planes); return result;
}

static unsigned long long render_king(void) {
    u8 cs[0x10000] = {0}, tiles[0x3000] = {0}, vga[0x10000] = {0};
    if (load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0xA000, "assets/kingpro.bin") || load_font(cs) ||
        load_tiles("assets/king.grp", tiles)) return 0;
    printf("tiles=%016llx first=%02x%02x%02x%02x%02x%02x\n",
           fnv1a64(tiles, sizeof(tiles)), tiles[0], tiles[1], tiles[2],
           tiles[3], tiles[4], tiles[5]);
    zeliard_gmmcga_clear_playfield(vga, sizeof(vga));
    zeliard_gmmcga_draw_life_scale(vga, sizeof(vga), 0);
    printf("king:life=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_draw_town_text_record(vga, sizeof(vga), cs, sizeof(cs), 0xA41A);
    printf("king:header=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gtmcga_draw_room_grid(cs + 0xA16E, 96, tiles, sizeof(tiles),
                                  vga, sizeof(vga), 0x0E17);
    printf("king:grid=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_fill_frame(vga, sizeof(vga), 0x0D60, 0x3637, cs[0xFF77]);
    return fnv1a64(vga, sizeof(vga));
}

static unsigned long long render_sage(void) {
    u8 cs[0x10000] = {0}, tiles[0x3000] = {0}, vga[0x10000] = {0};
    if (load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0xA000, "assets/kenjpro.bin") || load_font(cs) ||
        load_tiles("assets/kenja.grp", tiles)) return 0;
    cs[0xC006] = 1; cs[0xBB12] = 0x17; cs[0xBB13] = 0x07;
    const u16 header = (u16)(cs[0xACBD] | (cs[0xACBE] << 8));
    printf("tiles=%016llx first=%02x%02x%02x%02x%02x%02x\n",
           fnv1a64(tiles, sizeof(tiles)), tiles[0], tiles[1], tiles[2],
           tiles[3], tiles[4], tiles[5]);
    zeliard_gmmcga_clear_playfield(vga, sizeof(vga));
    zeliard_gmmcga_draw_life_scale(vga, sizeof(vga), 0);
    zeliard_gmmcga_draw_town_text_record(vga, sizeof(vga), cs, sizeof(cs), header);
    printf("sage:loader=%016llx header=%04x\n",
           fnv1a64(vga, sizeof(vga)), header);
    zeliard_gtmcga_draw_room_grid(cs + 0xA9B6, 96, tiles, sizeof(tiles),
                                  vga, sizeof(vga), 0x0717);
    printf("sage:grid=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_fill_frame(vga, sizeof(vga), 0x0D60, 0x3637, cs[0xFF77]);
    return fnv1a64(vga, sizeof(vga));
}

static int runtime_round_trip(void) {
    u8 *cs = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
    if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
        load_font(cs)) { free(cs); free(vga); free(room); return 0; }
    int ok = zeliard_room_enter(room, ZEL_ROOM_KING, cs, 0x10000,
                                vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xC3F7143FE6C981F1ULL;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    static const u8 zero[0x100] = {0};
    for (size_t offset = 0; offset < 0x1C00; offset += sizeof(zero))
        ok &= memcmp(cs + 0xA000 + offset, zero, sizeof(zero)) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xEB05052EA5B62325ULL;
    ok &= zeliard_room_enter(room, ZEL_ROOM_SAGE, cs, 0x10000,
                             vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xA6873B3AD33ACEC7ULL;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    free(cs); free(vga); free(room);
    return ok;
}

int main(void) {
    const unsigned long long king = render_king();
    const unsigned long long sage = render_sage();
    const int ok = king == 0xC3F7143FE6C981F1ULL &&
                   sage == 0xA6873B3AD33ACEC7ULL && runtime_round_trip();
    printf("felishika_rooms: king=%016llx sage=%016llx\n", king, sage);
    printf("VERDICT: %s: C room frames match release MASM\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
