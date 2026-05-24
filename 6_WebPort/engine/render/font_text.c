#include "font_text.h"
#include "../core/framebuf.h"
#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include <stdlib.h>
#include <string.h>

static u16 read_le16(const u8 *p) {
    return (u16)p[0] | ((u16)p[1] << 8);
}

int zeliard_font_load(zeliard_font_t *font) {
    if (!font) return 0;
    memset(font, 0, sizeof(*font));

    size_t file_size = 0;
    u8 *file_data = platform_load_asset("font.grp", &file_size);
    if (!file_data) {
        platform_log("font_text: missing font.grp");
        return 0;
    }

    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload || payload_size < 6) {
        free(payload);
        platform_log("font_text: font.grp decode failed");
        return 0;
    }

    font->data = payload;
    font->size = payload_size;
    font->ptr_a = read_le16(payload + 0);
    font->ptr_b = read_le16(payload + 2);
    font->ptr_c = read_le16(payload + 4);
    platform_log("font_text: font.grp ready size=%zu ptrs=%04x/%04x/%04x",
                 font->size, font->ptr_a, font->ptr_b, font->ptr_c);
    return 1;
}

void zeliard_font_free(zeliard_font_t *font) {
    if (!font) return;
    free(font->data);
    memset(font, 0, sizeof(*font));
}

void zeliard_font_draw_char(const zeliard_font_t *font, int x, int y, u8 ch, u8 color) {
    if (!font || !font->data || ch < 0x20) return;

    size_t glyph = (size_t)font->ptr_a + (size_t)(ch - 0x20) * 8u;
    if (glyph + 8u > font->size) return;

    for (int row = 0; row < 8; row++) {
        int dy = y + row;
        if (dy < 0 || dy >= ZELIARD_HEIGHT) continue;

        u8 bits = font->data[glyph + (size_t)row];
        for (int col = 0; col < 8; col++) {
            int dx = x + col;
            if (dx < 0 || dx >= ZELIARD_WIDTH) continue;
            if (bits & (u8)(0x80u >> col))
                g_framebuf[dy * ZELIARD_WIDTH + dx] = color;
        }
    }
}

void zeliard_font_draw_text(const zeliard_font_t *font, int x, int y, const char *text, u8 color) {
    if (!text) return;
    int col = x;
    int row = y;
    for (const unsigned char *p = (const unsigned char *)text; *p; p++) {
        if (*p == '\r' || *p == '\n') {
            col = x;
            row += 8;
            continue;
        }
        zeliard_font_draw_char(font, col, row, *p, color);
        col += 8;
    }
}

void zeliard_font_draw_command_stream(const zeliard_font_t *font, int x, int y,
                                      const u8 *stream, size_t max_len, u8 initial_color) {
    if (!stream) return;
    int col = x;
    int row = y;
    u8 color = initial_color;

    for (size_t i = 0; i < max_len; i++) {
        u8 ch = stream[i];
        if (ch == 0xFF) return;
        if (ch == 0x0D) {
            col = x;
            row += 8;
            continue;
        }
        if (ch & 0x80) {
            color = (u8)(ch & 7);
            continue;
        }
        zeliard_font_draw_char(font, col, row, ch, color);
        col += 8;
    }
}

zeliard_font_stream_result_t zeliard_font_draw_opening_anim_stream(const zeliard_font_t *font,
                                                                   int x, int y,
                                                                   const u8 *stream,
                                                                   size_t max_len,
                                                                   u8 color,
                                                                   int line_height) {
    zeliard_font_stream_result_t result;
    memset(&result, 0, sizeof(result));
    if (!stream) return result;

    int col = x;
    int row = y;
    int line_started = 0;

    for (size_t i = 0; i < max_len;) {
        u8 value = stream[i++];
        result.bytes_consumed = i;
        if (value == 0)
            break;
        if (value == 0xFF) {
            if (i >= max_len)
                break;
            u8 marker = stream[i++];
            result.bytes_consumed = i;
            if (marker == 0)
                break;
            if (marker == 1 && i < max_len) {
                i++;
                result.bytes_consumed = i;
            }
            if (line_started) {
                row += line_height;
                col = x;
                result.line_count++;
            }
            continue;
        }
        if (value < 0x20)
            continue;
        zeliard_font_draw_char(font, col, row, value, color);
        col += 8;
        result.glyph_count++;
        if (!line_started) {
            line_started = 1;
            result.line_count = 1;
        }
    }
    return result;
}
