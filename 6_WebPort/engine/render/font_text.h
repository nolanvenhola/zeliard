#ifndef ZELIARD_FONT_TEXT_H
#define ZELIARD_FONT_TEXT_H

#include "../core/types.h"
#include <stddef.h>

typedef struct {
    u8 *data;
    size_t size;
    u16 ptr_a;
    u16 ptr_b;
    u16 ptr_c;
} zeliard_font_t;

typedef struct {
    size_t bytes_consumed;
    size_t glyph_count;
    size_t line_count;
} zeliard_font_stream_result_t;

int  zeliard_font_load(zeliard_font_t *font);
void zeliard_font_free(zeliard_font_t *font);

void zeliard_font_draw_char(const zeliard_font_t *font, int x, int y, u8 ch, u8 color);
/* GMMCGA:27E9 render_text_char_alt. During OPDMO's cinematic mode the
 * selector in AH becomes (selector << 4) | selector before glyph pixels are
 * written to A000. */
void zeliard_font_draw_mcga_alt_char(const zeliard_font_t *font,
                                     int x, int y, u8 ch, u8 color_selector,
                                     int cinematic_active);
/* GMMCGA:291A streamed narration. CR advances one glyph row, bytes with bit
 * 7 select a new color, and FF terminates the stream. */
void zeliard_font_draw_mcga_narration_stream(const zeliard_font_t *font,
                                             int x, int y, const u8 *stream,
                                             size_t max_len,
                                             int cinematic_active);
void zeliard_font_draw_text(const zeliard_font_t *font, int x, int y, const char *text, u8 color);
void zeliard_font_draw_command_stream(const zeliard_font_t *font, int x, int y,
                                      const u8 *stream, size_t max_len, u8 initial_color);
zeliard_font_stream_result_t zeliard_font_draw_opening_anim_stream(const zeliard_font_t *font,
                                                                   int x, int y,
                                                                   const u8 *stream,
                                                                   size_t max_len,
                                                                   u8 color,
                                                                   int line_height);

#endif
