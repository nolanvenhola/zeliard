#include "town_dialog.h"

#include "../render/town_mcga.h"

#include <string.h>

enum {
    TOWN_ITEM_TABLE_PTR = 0xC00D,
    TOWN_NPC_LIST_PTR = 0xC00F,
    TOWN_FACING = 0x00C2,
    TEXT_DRAW_X = 0x7C4E,
    TEXT_DRAW_X2 = 0x7C50,
    TEXT_COL_POS = 0x7C53,
    TEXT_BOX_COLS = 0x7C54,
    TEXT_BOX_FLAG = 0x7C55,
    TEXT_ANIM_STEP = 0x7C56,
    TEXT_ROW_FLAG = 0x7C57,
    TEXT_STR_PTR = 0x7C58,
    TEXT_LAYOUT_CX = 0x7C5A,
    TEXT_DONE_FLAG = 0x7C5C,
    TEXT_WRAP_FLAG = 0x7C5D,
    CHAR_WIDTH_TABLE = 0x7B82,
    CHAR_GLYPH_TABLE = 0x7BE2,
    GVAR_SPACE = 0xFF1D,
    GVAR_SKIP = 0xFF1E,
    GVAR_ENTER = 0xFF29,
    GVAR_SOUND = 0xFF75,
    GVAR_INPUT_DIRECTION = 0xFF17,
};

static u16 read_u16(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static void write_u16(u8 *memory, u16 offset, u16 value) {
    memory[offset] = (u8)value;
    memory[(u16)(offset + 1)] = (u8)(value >> 8);
}

static u16 find_npc_offset(const u8 *cs, u16 position) {
    u16 at = read_u16(cs, TOWN_NPC_LIST_PTR);
    while (at <= 0xFFF7) {
        const u16 candidate = read_u16(cs, at);
        if (candidate == 0xFFFF) break;
        if (candidate == position) return at;
        at = (u16)(at + 8);
    }
    return 0xFFFF;
}

static u16 measure_word(const u8 *cs, u16 si) {
    u16 width = 0;
    for (;;) {
        const u8 ch = cs[si++];
        if (ch & 0x80 || ch == 0x20 || ch == 0x2F) return width;
        if (ch >= 0x20)
            width = (u16)(width + cs[(u16)(CHAR_GLYPH_TABLE + ch - 0x20)]);
    }
}

static u8 count_wrapped_lines(const u8 *cs, u16 si) {
    u16 lines = 0, width = 0;
    for (;;) {
        const u8 ch = cs[si++];
        if (ch & 0x80) return (u8)(lines + (width != 0));
        if (ch == 0x2F) {
            ++lines;
            width = 0;
            continue;
        }
        width = (u16)(width + cs[(u16)(CHAR_GLYPH_TABLE + ch - 0x20)]);
        if (ch == 0x20 && (u16)(width + measure_word(cs, si)) >= 0xA8) {
            ++lines;
            width = 0;
        }
    }
}

enum {
    /* 106TOWN:render_scroll_loop calls GMMCGA:2857 ten times without a
     * timer wait. Preserve each visible result on consecutive runtime ticks. */
    SCROLL_PASS_PIT_TICKS = 1,
};

static void scroll_dialog_one_row(u8 *vga, u16 packed, u16 layout) {
    const u16 x = (u16)((u8)(packed >> 8) * 8u);
    const u16 y = (u16)((u8)packed + 4u);
    /* GMMCGA doubles CH twice, then uses that value as REP MOVSW count. */
    const u16 width = (u16)(((u8)(layout >> 8) >> 1) * 8u);
    const u16 height = (u16)((u8)layout - 8u);
    for (u16 row = 0; row < height; ++row)
        memmove(vga + (size_t)(y + row) * 320u + x,
                vga + (size_t)(y + row + 1u) * 320u + x, width);
}

static void begin_dialog_scroll(zeliard_town_dialog_t *dialog,
                                u16 packed, u16 layout) {
    dialog->scroll_active = 1;
    dialog->scroll_pass = 0;
    dialog->scroll_wait_ticks = SCROLL_PASS_PIT_TICKS;
    dialog->scroll_packed = packed;
    dialog->scroll_layout = layout;
}

static void clear_page_prompt(u8 *vga, u16 packed) {
    const u16 x = (u16)((u8)(packed >> 8) * 8u + 84u);
    const u16 y = (u16)((u8)packed + 74u);
    for (u16 row = 0; row < 8; ++row)
        memset(vga + (size_t)(y + row) * 320u + x, 0, 8);
}

static void draw_prompt_cursor(u8 *vga, u16 packed, u8 row) {
    static const u8 bits[9] = {
        0x00, 0x60, 0x70, 0x78, 0x7C, 0x78, 0x70, 0x60, 0x00,
    };
    const u16 x = (u16)(((u8)(packed >> 8) + 1u) * 4u);
    const u16 y = (u16)((u8)packed + (u16)row * 10u + 1u);
    for (u8 glyph_row = 0; glyph_row < 9; ++glyph_row) {
        u8 mask = bits[glyph_row];
        for (u8 pixel = 0; pixel < 8; ++pixel) {
            if ((mask & 0x80) && x + pixel < 320 && y + glyph_row < 200)
                vga[(size_t)(y + glyph_row) * 320u + x + pixel] = 0x12;
            mask <<= 1;
        }
    }
}

static int draw_prompt_string(const u8 *cs, u8 *vga, size_t vga_size,
                              u16 string, u16 packed, u8 row) {
    u16 x = (u16)(((u8)(packed >> 8) + 3u) * 4u);
    const u8 y = (u8)((u8)packed + row * 10u + 1u);
    while (cs[string]) {
        const u8 character = cs[string++];
        if (zeliard_gmmcga_draw_text_char(
                vga, vga_size, cs, 0x10000, character, 1, x, y))
            return -1;
        x = (u16)(x + cs[(u16)(CHAR_GLYPH_TABLE + character - 0x20)]);
    }
    return 0;
}

static int draw_yes_no_prompt(zeliard_town_dialog_t *dialog,
                              const u8 *cs, u8 *vga, size_t vga_size) {
    /* 106TOWN:ctrl_81_header derives this 12x25 frame and its menu origin
     * directly from town_char_idx, then calls prompt_yes_no with the
     * resident "Yes"/"No" strings at 7513h. */
    u16 frame = dialog->panel_ax;
    frame = (u16)((u16)((u8)(frame >> 8) * 2u) << 8 | (u8)frame);
    frame = (u16)(frame + 0x193Fu);
    dialog->prompt_position = (u16)(frame + 0x0103u);
    if (zeliard_gmmcga_fill_frame(vga, vga_size, frame, 0x0C19, 0) ||
        draw_prompt_string(cs, vga, vga_size, 0x7513, dialog->prompt_position, 0) ||
        draw_prompt_string(cs, vga, vga_size, 0x7517, dialog->prompt_position, 1))
        return -1;
    draw_prompt_cursor(vga, dialog->prompt_position,
                       dialog->prompt_selection);
    return 0;
}

static int finish_dialog_newline(zeliard_town_dialog_t *dialog, u8 *cs,
                                 u8 *vga, size_t vga_size) {
    if (++cs[TEXT_ROW_FLAG] >= 7 && cs[TEXT_ANIM_STEP] != 8) {
        cs[TEXT_ANIM_STEP] = (u8)(cs[TEXT_ANIM_STEP] - 7u);
        const u16 packed = read_u16(cs, TEXT_DRAW_X);
        const u16 x = (u16)((u8)(packed >> 8) * 8u + 84u);
        const u16 y = (u16)((u8)packed + 74u);
        if (zeliard_gmmcga_draw_text_char(
                vga, vga_size, cs, 0x10000, 0x7C, 2, x, (u8)y))
            return -3;
        dialog->waiting = dialog->page_wait = 1;
    }
    return 0;
}

static int start_dialog_newline(zeliard_town_dialog_t *dialog, u8 *cs,
                                u8 *vga, size_t vga_size, u16 packed) {
    cs[TEXT_COL_POS] = 0;
    if (++cs[TEXT_BOX_COLS] == 8) {
        --cs[TEXT_BOX_COLS];
        begin_dialog_scroll(dialog, packed, read_u16(cs, TEXT_LAYOUT_CX));
        return 1;
    }
    return finish_dialog_newline(dialog, cs, vga, vga_size);
}

static int render_dialog_chars(zeliard_town_dialog_t *dialog, u8 *cs,
                               u8 *vga, size_t vga_size) {
    for (;;) {
        u16 si = read_u16(cs, TEXT_STR_PTR);
        const u8 ch = cs[si++];
        write_u16(cs, TEXT_STR_PTR, si);
        if (ch == 0xFF) {
            dialog->waiting = dialog->final_wait = 1;
            return 0;
        }
        if (ch == 0x2F) {
            const int result = start_dialog_newline(
                dialog, cs, vga, vga_size, read_u16(cs, TEXT_DRAW_X));
            if (result) return result < 0 ? result : 0;
            if (dialog->waiting) return 0;
            continue;
        }
        if (ch == 0x81) {
            dialog->prompt_active = 1;
            dialog->prompt_selection = 0;
            dialog->prompt_direction_latch = 0;
            dialog->waiting = 1;
            return draw_yes_no_prompt(dialog, cs, vga, vga_size) ? -3 : 0;
        }
        if (ch & 0x80) return -2;
        const u16 packed = read_u16(cs, TEXT_DRAW_X);
        u16 x = (u16)((u8)(packed >> 8) * 8u + cs[TEXT_COL_POS] + 4u);
        const u8 y = (u8)((u8)packed + cs[TEXT_BOX_COLS] * 10u + 4u);
        x = (u16)(x - cs[(u16)(CHAR_WIDTH_TABLE + ch - 0x20)]);
        if (zeliard_gmmcga_draw_text_char(vga, vga_size, cs, 0x10000,
                                          ch, 1, x, y))
            return -3;
        ++dialog->glyph_count;
        cs[TEXT_COL_POS] = (u8)(cs[TEXT_COL_POS] +
            cs[(u16)(CHAR_GLYPH_TABLE + ch - 0x20)]);
        if (ch == 0x20 &&
            (u16)(cs[TEXT_COL_POS] + measure_word(cs, si)) >= 0xA8) {
            const int result = start_dialog_newline(
                dialog, cs, vga, vga_size, packed);
            if (result) return result < 0 ? result : 0;
            if (dialog->waiting) return 0;
        }
    }
}

static int render_dialog(zeliard_town_dialog_t *dialog, u8 *cs,
                         u8 *vga, size_t vga_size, u8 dialog_id, u16 ax) {
    write_u16(cs, TEXT_DRAW_X2, ax);
    write_u16(cs, TEXT_DRAW_X, ax);
    const u16 table = read_u16(cs, TOWN_ITEM_TABLE_PTR);
    u16 si = read_u16(cs, (u16)(table + (u16)dialog_id * 2u));
    cs[TEXT_COL_POS] = cs[TEXT_BOX_COLS] = cs[TEXT_BOX_FLAG] = 0;
    cs[TEXT_ROW_FLAG] = 0;
    write_u16(cs, TEXT_STR_PTR, si);
    u8 lines = count_wrapped_lines(cs, si);
    cs[TEXT_ANIM_STEP] = lines;
    const u8 visible_lines = lines < 8 ? lines : 8;
    const u8 height = (u8)(visible_lines * 10u + 6u);
    const u16 layout_cx = (u16)(0x2C00 | height);
    write_u16(cs, TEXT_LAYOUT_CX, layout_cx);
    u16 draw = ax;
    u8 x_quad = (u8)draw;
    x_quad = (u8)(x_quad + 0x56u - height);
    const u8 even_lines = (u8)(visible_lines & 0xFE);
    x_quad = (u8)(x_quad - (u8)((0x40u - even_lines * 8u) >> 1));
    draw = (u16)((draw & 0xFF00u) | x_quad);
    write_u16(cs, TEXT_DRAW_X, draw);
    const u16 fill_bx = (u16)(((u8)(draw >> 8) * 2u) << 8) | x_quad;
    if (zeliard_gmmcga_fill_frame(vga, vga_size, fill_bx, layout_cx, 0))
        return -1;

    return render_dialog_chars(dialog, cs, vga, vga_size);
}

static int begin_dialog(zeliard_town_dialog_t *dialog,
                        u8 *cs, u8 *scratch,
                        u8 *tile_data, size_t tile_data_size,
                        const u8 *mask_data, size_t mask_data_size,
                        u8 *vga, size_t vga_size, u16 npc_position,
                        int facing_trigger) {
    if (!dialog || !cs || !scratch || !vga || dialog->active) return -1;
    const u16 npc = find_npc_offset(cs, npc_position);
    if (npc == 0xFFFF) return -2;
    if (facing_trigger) {
        if (!(cs[(u16)(npc + 6)] & 0x80)) return -2;
    } else if (cs[(u16)(npc + 6)] & 0xC0) {
        return -2;
    }
    memset(dialog, 0, sizeof(*dialog));
    dialog->active = 1;
    dialog->npc_offset = npc;
    dialog->original_npc_direction = cs[(u16)(npc + 2)];
    dialog->original_npc_type = cs[(u16)(npc + 5)];
    if (facing_trigger) {
        cs[(u16)(npc + 6)] &= 0x7F;
        cs[TEXT_DONE_FLAG] = 0xFF;
    } else {
        cs[(u16)(npc + 5)] = 7;
        if (cs[TOWN_FACING] & 1) cs[(u16)(npc + 2)] &= 0x7F;
        else cs[(u16)(npc + 2)] |= 0x80;
    }
    cs[(u16)(npc + 4)] |= 1;
    if (tile_data && mask_data) {
        if (zeliard_gtmcga_render_town_actors(
                cs, 0x10000, tile_data, tile_data_size,
                mask_data, mask_data_size, vga, vga_size)) return -3;
        const u8 column = cs[0x0083];
        if (column < 0x1B) {
            const u16 cursor = (u16)(0xE000u + (u16)column * 8u + 5u);
            memset(cs + cursor, 0xFF, 3);
            memset(cs + cursor + 8u, 0xFF, 3);
        }
        if (zeliard_gtmcga_update_town_frame(
                cs, 0x10000, tile_data, tile_data_size,
                mask_data, mask_data_size, vga, vga_size)) return -3;
    }
    dialog->panel_ax = (cs[TOWN_FACING] & 1) ? 0x0718 : 0x0B18;
    dialog->panel_cx = 0x1658;
    if (zeliard_gmmcga_save_rect(vga, vga_size, scratch, 0x10000,
                                  dialog->panel_ax, dialog->panel_cx, 0))
        return -3;
    cs[GVAR_SOUND] = 0x1E;
    dialog->pending_sound_cue = 0x1E;
    cs[GVAR_SPACE] = 0;
    const int result = render_dialog(dialog, cs, vga, vga_size,
                                     cs[(u16)(npc + 7)], dialog->panel_ax);
    if (result) dialog->active = 0;
    return result;
}

int zeliard_town_dialog_begin(zeliard_town_dialog_t *dialog,
                              u8 *cs, u8 *scratch,
                              u8 *vga, size_t vga_size, u16 npc_position) {
    return begin_dialog(dialog, cs, scratch, NULL, 0, NULL, 0,
                        vga, vga_size, npc_position, 0);
}

int zeliard_town_dialog_begin_live(zeliard_town_dialog_t *dialog,
                                   u8 *cs, u8 *scratch,
                                   u8 *tile_data, size_t tile_data_size,
                                   const u8 *mask_data, size_t mask_data_size,
                                   u8 *vga, size_t vga_size,
                                   u16 npc_position) {
    return begin_dialog(dialog, cs, scratch, tile_data, tile_data_size,
                        mask_data, mask_data_size, vga, vga_size,
                        npc_position, 0);
}

int zeliard_town_dialog_begin_facing(zeliard_town_dialog_t *dialog,
                                     u8 *cs, u8 *scratch,
                                     u8 *tile_data, size_t tile_data_size,
                                     const u8 *mask_data,
                                     size_t mask_data_size,
                                     u8 *vga, size_t vga_size,
                                     u16 npc_position) {
    return begin_dialog(dialog, cs, scratch, tile_data, tile_data_size,
                        mask_data, mask_data_size, vga, vga_size,
                        npc_position, 1);
}

int zeliard_town_dialog_continue(zeliard_town_dialog_t *dialog,
                                 u8 *cs, const u8 *scratch,
                                 u8 *vga, size_t vga_size) {
    if (!dialog || !dialog->active || !dialog->waiting) return 0;
    if (dialog->prompt_active) {
        const u8 direction = cs[GVAR_INPUT_DIRECTION] & 3u;
        if (!direction) dialog->prompt_direction_latch = 0;
        else if (!dialog->prompt_direction_latch) {
            dialog->prompt_direction_latch = direction;
            const u8 previous = dialog->prompt_selection;
            if (direction == 1) dialog->prompt_selection = 0;
            else if (direction == 2) dialog->prompt_selection = 1;
            if (previous != dialog->prompt_selection &&
                draw_yes_no_prompt(dialog, cs, vga, vga_size))
                return -1;
        }
        if (!cs[GVAR_SPACE] && !cs[GVAR_ENTER] && !cs[GVAR_SKIP]) return 0;
        cs[GVAR_SPACE] = cs[GVAR_ENTER] = cs[GVAR_SKIP] = 0;
        /* prompt_yes_no returns carry for Yes. ctrl_81_header dispatches
         * carry to dialog 13 and no-carry to dialog 12. */
        const u8 next_dialog = dialog->prompt_selection ? 12 : 13;
        dialog->prompt_active = dialog->waiting = 0;
        return render_dialog(dialog, cs, vga, vga_size,
                             next_dialog, dialog->panel_ax);
    }
    if (!cs[GVAR_SPACE] && !cs[GVAR_ENTER] && !cs[GVAR_SKIP]) return 0;
    cs[GVAR_SPACE] = cs[GVAR_ENTER] = cs[GVAR_SKIP] = 0;
    if (dialog->page_wait) {
        dialog->waiting = dialog->page_wait = 0;
        clear_page_prompt(vga, read_u16(cs, TEXT_DRAW_X));
        cs[TEXT_ROW_FLAG] = 0;
        cs[GVAR_SOUND] = 0x1D;
        dialog->pending_sound_cue = 0x1D;
        const int result = render_dialog_chars(dialog, cs, vga, vga_size);
        return result ? result : 0;
    }
    if (zeliard_gmmcga_restore_rect(vga, vga_size, scratch, 0x10000,
                                     dialog->panel_ax, dialog->panel_cx, 0))
        return -1;
    cs[(u16)(dialog->npc_offset + 5)] = dialog->original_npc_type;
    cs[(u16)(dialog->npc_offset + 2)] = dialog->original_npc_direction;
    cs[TEXT_DONE_FLAG] = cs[TEXT_WRAP_FLAG] = 0;
    dialog->active = dialog->waiting = 0;
    return 1;
}

int zeliard_town_dialog_advance_pit(zeliard_town_dialog_t *dialog,
                                    u8 *cs,
                                    u8 *vga, size_t vga_size) {
    if (!dialog || !dialog->active || !cs || !vga || vga_size < 0x10000)
        return -1;
    if (dialog->scroll_active) {
        if (--dialog->scroll_wait_ticks != 0) return 0;
        scroll_dialog_one_row(vga, dialog->scroll_packed,
                              dialog->scroll_layout);
        ++dialog->scroll_pass;
        ++dialog->scroll_step_count;
        if (dialog->scroll_pass < 10) {
            dialog->scroll_wait_ticks = SCROLL_PASS_PIT_TICKS;
        } else {
            dialog->scroll_active = 0;
            dialog->scroll_resume_pending = 1;
            ++dialog->scroll_count;
        }
        return 1;
    }
    if (!dialog->scroll_resume_pending) return 0;
    dialog->scroll_resume_pending = 0;
    const int result = finish_dialog_newline(dialog, cs, vga, vga_size);
    if (result || dialog->waiting) return result < 0 ? result : 1;
    return render_dialog_chars(dialog, cs, vga, vga_size) < 0 ? -1 : 1;
}
