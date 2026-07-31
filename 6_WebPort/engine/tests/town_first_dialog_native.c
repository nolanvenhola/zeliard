#include "../game/town_dialog.h"
#include "../load/fill_buffer.h"

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

static int load_raw(u8 *destination, size_t capacity, const char *name) {
    size_t size = 0;
    u8 *data = read_file(name, &size);
    if (!data || size < 4) { free(data); return 0; }
    const size_t declared = (size_t)data[0] | ((size_t)data[1] << 8) |
        ((size_t)data[2] << 16) | ((size_t)data[3] << 24);
    if (declared > size - 4 || declared > capacity) {
        free(data);
        return 0;
    }
    memcpy(destination, data + 4, declared);
    free(data);
    return 1;
}

static int load_font(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *data = read_file("assets/font.grp", &size);
    u8 *decoded = data ? fill_buffer_decompress(data, size, &decoded_size) : NULL;
    free(data);
    if (!decoded || decoded_size > 0x0B00) { free(decoded); return 0; }
    memcpy(segment + 0xF500, decoded, decoded_size);
    free(decoded);
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = (u16)(segment[0xF500 + offset] |
                                ((u16)segment[0xF501 + offset] << 8));
        const u16 relocated = (u16)(value + 0xF500);
        segment[0xF500 + offset] = (u8)relocated;
        segment[0xF501 + offset] = (u8)(relocated >> 8);
    }
    return 1;
}

int main(void) {
    u8 segment[0x10000] = {0};
    u8 scratch[0x10000] = {0};
    u8 vga[0x10000];
    u8 background[0x10000];
    zeliard_town_dialog_t dialog = {0};
    for (size_t i = 0; i < sizeof(vga); ++i)
        vga[i] = background[i] = (u8)(i * 13u + 7u);

    size_t driver_size = 0;
    u8 *driver = read_file("assets/gmmcga.bin", &driver_size);
    int ok = driver && driver_size <= 0xE000;
    if (ok) memcpy(segment + 0x2000, driver, driver_size);
    free(driver);
    ok &= load_raw(segment + 0x6000, 0xA000, "assets/town.bin");
    ok &= load_raw(segment + 0xC000, 0x4000, "assets/cmap.mdt");
    ok &= load_font(segment);
    segment[0x0080] = 0x1E;
    segment[0x0083] = 0x0B;
    segment[0x00C2] = 0;

    const int begin = ok ? zeliard_town_dialog_begin(
        &dialog, segment, scratch, vga, sizeof(vga), 0x0030) : -99;
    const unsigned long long page_hash = fnv1a64(vga, sizeof(vga));
    const u16 text_pc = (u16)(segment[0x7C58] |
                              ((u16)segment[0x7C59] << 8));
    ok &= begin == 0 && dialog.active && dialog.waiting;
    ok &= page_hash == 0x886C34A52FF3FEE5ULL;
    ok &= dialog.glyph_count == 161 && text_pc == 0xC4AC;
    ok &= dialog.pending_sound_cue == 0x1E && segment[0xFF75] == 0x1E;
    ok &= memcmp(segment + 0xC89C,
                 (const u8[]){0x30,0x00,0x81,0x18,0x01,0x07,0x00,0x00}, 8) == 0;

    segment[0xFF29] = 0x0D;
    const int continued = zeliard_town_dialog_continue(
        &dialog, segment, scratch, vga, sizeof(vga));
    ok &= continued == 1 && !dialog.active && !dialog.waiting;
    ok &= memcmp(vga, background, sizeof(vga)) == 0;
    ok &= memcmp(segment + 0xC89C,
                 (const u8[]){0x30,0x00,0x81,0x18,0x01,0x00,0x00,0x00}, 8) == 0;
    ok &= segment[0xFF1D] == 0 && segment[0xFF1E] == 0 &&
          segment[0xFF29] == 0;

    printf("town_first_dialog: %s page=%016llx glyphs=%u pc=%04x "
           "cue=%02x restore=%016llx\n", ok ? "PASS" : "FAIL", page_hash,
           dialog.glyph_count, text_pc, dialog.pending_sound_cue,
           fnv1a64(vga, sizeof(vga)));
    printf("VERDICT: %s: first Felishika castle dialog MASM parity\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
