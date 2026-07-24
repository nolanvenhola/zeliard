#include "opening_script.h"
#include <string.h>

static int is_text_sound_exempt(u8 ch) {
    return ch == ' ' || ch == '.' || ch == ',' || ch == '"' || ch == '\'';
}

static int width_terminates(u8 ch) {
    return ch == ' ' ||
           ch == ZELIARD_SCRIPT_SCR_END_SCRIPT ||
           ch == ZELIARD_SCRIPT_SCR_SCROLL ||
           ch == ZELIARD_SCRIPT_SCR_BREAK ||
           ch == ZELIARD_SCRIPT_SCR_DIRECT ||
           ch == ZELIARD_SCRIPT_SCR_PARA ||
           ch == ZELIARD_SCRIPT_SCR_MODE2 ||
           ch == ZELIARD_SCRIPT_SCR_MODE3;
}

static void script_newline(zeliard_opening_script_state_t *state) {
    state->text_x_pos = 0;
    state->text_y_pos++;
    state->newline_count++;
}

void zeliard_opening_script_init(zeliard_opening_script_state_t *state, size_t pc) {
    if (!state) return;
    memset(state, 0, sizeof(*state));
    state->pc = pc;
}

u16 zeliard_opening_script_calc_text_width(const u8 *script, size_t max_len,
                                           const u8 advances[96]) {
    u16 width = 0;
    if (!script || !advances) return 0;

    for (size_t i = 0; i < max_len; i++) {
        u8 ch = script[i];
        if (width_terminates(ch))
            return width;
        if (ch & 0x80)
            continue;
        if (ch < 0x20)
            continue;
        width = (u16)(width + advances[ch - 0x20]);
    }
    return width;
}

static void render_char(zeliard_opening_script_state_t *state, u8 ch,
                        const u8 widths[96], const u8 advances[96],
                        const u8 *remaining_script, size_t remaining_size) {
    if (!is_text_sound_exempt(ch))
        state->volume_b = state->text_attr;

    if (ch < 0x20 || !widths || !advances)
        return;

    u8 index = (u8)(ch - 0x20);
    u16 x = (u16)(state->text_x_pos + 4u);
    u16 y = (u16)((u16)state->text_y_pos * 10u + 0x8Fu);
    state->last_char = ch;
    state->last_draw_x = (u16)(x - widths[index]);
    state->last_draw_y = y;
    state->glyph_count++;
    state->draw_call_count += 2;
    state->text_x_pos = (u16)(state->text_x_pos + advances[index]);

    if (ch == ' ') {
        u16 next_word_width =
            zeliard_opening_script_calc_text_width(remaining_script, remaining_size, advances);
        if ((u16)(state->text_x_pos + next_word_width) >= 0x0138u)
            script_newline(state);
    }
}

zeliard_script_stop_t zeliard_opening_script_run(zeliard_opening_script_state_t *state,
                                                 const u8 *script, size_t script_size,
                                                 const u8 widths[96],
                                                 const u8 advances[96],
                                                 size_t max_steps) {
    if (!state || !script) return ZELIARD_SCRIPT_STOP_LIMIT;

    state->frame_timer = 0;
    state->stop = ZELIARD_SCRIPT_STOP_NONE;
    int refetch_without_wait = 0;

    for (size_t step = 0; max_steps == 0 || step < max_steps; step++) {
        if (state->pc >= script_size) {
            state->stop = ZELIARD_SCRIPT_STOP_LIMIT;
            return state->stop;
        }

        if (!refetch_without_wait)
            state->wait_10_count++;
        refetch_without_wait = 0;

        u8 ch = script[state->pc++];
        if ((ch & 0x80) == 0) {
            render_char(state, ch, widths, advances,
                        script + state->pc, script_size - state->pc);
            continue;
        }

        if (ch == ZELIARD_SCRIPT_SCR_END_SCRIPT) {
            state->stop = ZELIARD_SCRIPT_STOP_END;
            return state->stop;
        }
        if (ch == ZELIARD_SCRIPT_SCR_BREAK) {
            state->stop = ZELIARD_SCRIPT_STOP_BREAK;
            return state->stop;
        }

        u8 high = (u8)(ch & 0xF0u);
        if (high == 0x80) {
            state->portrait_small_count++;
            refetch_without_wait = 1;
            continue;
        }
        if (high == 0x90) {
            state->portrait_large_count++;
            refetch_without_wait = 1;
            continue;
        }

        switch (ch) {
        case ZELIARD_SCRIPT_SCR_BOLD:
            state->text_color_fg = 1;
            state->text_color_bg = 7;
            break;
        case ZELIARD_SCRIPT_SCR_NORMAL:
            state->text_color_fg = 0;
            state->text_color_bg = 7;
            break;
        case ZELIARD_SCRIPT_SCR_COLOR6:
            state->text_color_fg = 2;
            state->text_color_bg = 6;
            break;
        case ZELIARD_SCRIPT_SCR_WAIT:
            state->pause_f0_count++;
            break;
        case ZELIARD_SCRIPT_SCR_WAIT3:
            state->pause_f0_count += 3;
            break;
        case ZELIARD_SCRIPT_SCR_DIRECT:
            state->text_x_pos = 0;
            state->text_y_pos = 0;
            break;
        case ZELIARD_SCRIPT_SCR_PARA:
            state->text_x_pos = 0;
            state->text_y_pos = 1;
            break;
        case ZELIARD_SCRIPT_SCR_MODE2:
            state->text_x_pos = 0;
            state->text_y_pos = 2;
            break;
        case ZELIARD_SCRIPT_SCR_MODE3:
            state->text_x_pos = 0;
            state->text_y_pos = 3;
            break;
        case ZELIARD_SCRIPT_SCR_SCROLL:
            state->clear_count++;
            state->text_x_pos = 0;
            state->text_y_pos = 0;
            break;
        case ZELIARD_SCRIPT_SCR_RESET:
            state->text_attr = 0;
            break;
        case ZELIARD_SCRIPT_SCR_SPK_UNK:
            state->text_attr = '=';
            break;
        case ZELIARD_SCRIPT_SCR_SPK_KING:
            state->text_attr = '>';
            break;
        case ZELIARD_SCRIPT_SCR_SPK_NARR:
            state->text_attr = '?';
            break;
        case ZELIARD_SCRIPT_SCR_SPK_DEMON:
            state->text_attr = '@';
            break;
        case ZELIARD_SCRIPT_SCR_SPK_PRINC:
            state->text_attr = 'A';
            break;
        default:
            break;
        }
    }

    state->stop = ZELIARD_SCRIPT_STOP_LIMIT;
    return state->stop;
}

u32 zeliard_opening_script_timer_ticks(const u8 *script, size_t script_size) {
    u32 ticks = 0;
    int wait_before_fetch = 1;

    if (!script)
        return 0;

    for (size_t pc = 0; pc < script_size;) {
        if (wait_before_fetch)
            ticks += 0x10;
        wait_before_fetch = 1;

        const u8 ch = script[pc++];
        if ((ch & 0x80u) == 0)
            continue;
        if (ch == ZELIARD_SCRIPT_SCR_END_SCRIPT ||
            ch == ZELIARD_SCRIPT_SCR_BREAK)
            break;
        if ((ch & 0xF0u) == 0x80u || (ch & 0xF0u) == 0x90u) {
            wait_before_fetch = 0;
            continue;
        }
        if (ch == ZELIARD_SCRIPT_SCR_WAIT)
            ticks += 0xF0;
        else if (ch == ZELIARD_SCRIPT_SCR_WAIT3)
            ticks += 3u * 0xF0u;
    }
    return ticks;
}
