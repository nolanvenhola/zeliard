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

static void scroll_dialog_rows(u8 *vga, u16 packed) {
    const u16 x = (u16)((u8)(packed >> 8) * 8u + 4u);
    const u16 y = (u16)((u8)packed + 4u);
    enum { WIDTH = 168, ROW_HEIGHT = 10, VISIBLE_ROWS = 8 };
    for (u16 row = 0; row < (VISIBLE_ROWS - 1) * ROW_HEIGHT; ++row)
        memmove(vga + (size_t)(y + row) * 320u + x,
                vga + (size_t)(y + row + ROW_HEIGHT) * 320u + x, WIDTH);
    for (u16 row = (VISIBLE_ROWS - 1) * ROW_HEIGHT;
         row < VISIBLE_ROWS * ROW_HEIGHT; ++row)
        memset(vga + (size_t)(y + row) * 320u + x, 0, WIDTH);
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
            cs[TEXT_COL_POS] = 0;
            if (++cs[TEXT_BOX_COLS] == 8) {
                --cs[TEXT_BOX_COLS];
                scroll_dialog_rows(vga, read_u16(cs, TEXT_DRAW_X));
            }
            if (++cs[TEXT_ROW_FLAG] >= 7 && cs[TEXT_ANIM_STEP] != 8) {
                cs[TEXT_ANIM_STEP] = (u8)(cs[TEXT_ANIM_STEP] - 7u);
                const u16 packed = read_u16(cs, TEXT_DRAW_X);
                const u16 x = (u16)((u8)(packed >> 8) * 8u + 84u);
                const u16 y = (u16)((u8)packed + 74u);
                zeliard_gmmcga_draw_text_char(
                    vga, vga_size, cs, 0x10000, 0x7C, 2, x, (u8)y);
                dialog->waiting = dialog->page_wait = 1;
                return 0;
            }
            continue;
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
            cs[TEXT_COL_POS] = 0;
            if (++cs[TEXT_BOX_COLS] == 8) {
                --cs[TEXT_BOX_COLS];
                scroll_dialog_rows(vga, packed);
            }
            if (++cs[TEXT_ROW_FLAG] >= 7 && cs[TEXT_ANIM_STEP] != 8) {
                cs[TEXT_ANIM_STEP] = (u8)(cs[TEXT_ANIM_STEP] - 7u);
                const u16 prompt_x = (u16)((u8)(packed >> 8) * 8u + 84u);
                const u16 prompt_y = (u16)((u8)packed + 74u);
                zeliard_gmmcga_draw_text_char(
                    vga, vga_size, cs, 0x10000, 0x7C, 2,
                    prompt_x, (u8)prompt_y);
                dialog->waiting = dialog->page_wait = 1;
                return 0;
            }
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

int zeliard_town_dialog_begin(zeliard_town_dialog_t *dialog,
                              u8 *cs, u8 *scratch,
                              u8 *vga, size_t vga_size, u16 npc_position) {
    if (!dialog || !cs || !scratch || !vga || dialog->active) return -1;
    const u16 npc = find_npc_offset(cs, npc_position);
    if (npc == 0xFFFF || (cs[(u16)(npc + 6)] & 0xC0)) return -2;
    memset(dialog, 0, sizeof(*dialog));
    dialog->active = 1;
    dialog->npc_offset = npc;
    dialog->original_npc_direction = cs[(u16)(npc + 2)];
    dialog->original_npc_type = cs[(u16)(npc + 5)];
    cs[(u16)(npc + 5)] = 7;
    if (cs[TOWN_FACING] & 1) cs[(u16)(npc + 2)] &= 0x7F;
    else cs[(u16)(npc + 2)] |= 0x80;
    cs[(u16)(npc + 4)] |= 1;
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

int zeliard_town_dialog_continue(zeliard_town_dialog_t *dialog,
                                 u8 *cs, const u8 *scratch,
                                 u8 *vga, size_t vga_size) {
    if (!dialog || !dialog->active || !dialog->waiting) return 0;
    if (!cs[GVAR_SPACE] && !cs[GVAR_ENTER] && !cs[GVAR_SKIP]) return 0;
    cs[GVAR_SPACE] = cs[GVAR_ENTER] = cs[GVAR_SKIP] = 0;
    if (dialog->page_wait) {
        dialog->waiting = dialog->page_wait = 0;
        cs[TEXT_ROW_FLAG] = 0;
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
