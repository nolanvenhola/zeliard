#ifndef ZELIARD_OPENING_SCRIPT_H
#define ZELIARD_OPENING_SCRIPT_H

#include "../core/types.h"
#include <stddef.h>

enum {
    ZELIARD_SCRIPT_SCR_END_SCRIPT = 0xFF,
    ZELIARD_SCRIPT_SCR_SCROLL = 0xFE,
    ZELIARD_SCRIPT_SCR_BREAK = 0xFD,
    ZELIARD_SCRIPT_SCR_BOLD = 0xFB,
    ZELIARD_SCRIPT_SCR_NORMAL = 0xFA,
    ZELIARD_SCRIPT_SCR_COLOR6 = 0xF9,
    ZELIARD_SCRIPT_SCR_DIRECT = 0xF7,
    ZELIARD_SCRIPT_SCR_WAIT3 = 0xF6,
    ZELIARD_SCRIPT_SCR_WAIT = 0xF5,
    ZELIARD_SCRIPT_SCR_PARA = 0xF3,
    ZELIARD_SCRIPT_SCR_MODE2 = 0xF2,
    ZELIARD_SCRIPT_SCR_MODE3 = 0xF1,
    ZELIARD_SCRIPT_SCR_RESET = 0xF0,
    ZELIARD_SCRIPT_SCR_SPK_UNK = 0xEF,
    ZELIARD_SCRIPT_SCR_SPK_KING = 0xEE,
    ZELIARD_SCRIPT_SCR_SPK_NARR = 0xED,
    ZELIARD_SCRIPT_SCR_SPK_DEMON = 0xEC,
    ZELIARD_SCRIPT_SCR_SPK_PRINC = 0xEB
};

typedef enum {
    ZELIARD_SCRIPT_STOP_NONE = 0,
    ZELIARD_SCRIPT_STOP_END,
    ZELIARD_SCRIPT_STOP_BREAK,
    ZELIARD_SCRIPT_STOP_LIMIT
} zeliard_script_stop_t;

typedef struct {
    size_t pc;
    u16 text_x_pos;
    u8 text_y_pos;
    u8 text_color_fg;
    u8 text_color_bg;
    u8 text_attr;
    u8 volume_b;
    u8 frame_timer;
    u8 last_char;
    u16 last_draw_x;
    u16 last_draw_y;
    size_t wait_10_count;
    size_t pause_f0_count;
    size_t clear_count;
    size_t portrait_small_count;
    size_t portrait_large_count;
    size_t glyph_count;
    size_t draw_call_count;
    size_t newline_count;
    zeliard_script_stop_t stop;
} zeliard_opening_script_state_t;

void zeliard_opening_script_init(zeliard_opening_script_state_t *state, size_t pc);
u16 zeliard_opening_script_calc_text_width(const u8 *script, size_t max_len,
                                           const u8 advances[96]);
zeliard_script_stop_t zeliard_opening_script_run(zeliard_opening_script_state_t *state,
                                                 const u8 *script, size_t script_size,
                                                 const u8 widths[96],
                                                 const u8 advances[96],
                                                 size_t max_steps);

#endif
