#include "gameplay_state.h"

enum {
    ZELIARD_ENEMY_ENTRY_STRIDE = 0x0D,
    ZELIARD_MOVE_SLOT_NOT_FOUND = 0xFF,
    ZELIARD_SCROLL_BUF = 0xE000,
    ZELIARD_HUD_BUF = 0xE900,
    ZELIARD_SCROLL_WRAP_SIZE = 0x0900,
    ZELIARD_SCROLL_ROW_STRIDE = 0x24,
    ZELIARD_OBJECT_ENTRY_STRIDE = 0x10
};

void zeliard_subtract_from_player_hp(zeliard_player_state_t *state, u16 amount) {
    const u16 hp = zeliard_player_read_u16(state, ZEL_PLAYER_HP);
    zeliard_player_write_u16(state, ZEL_PLAYER_HP,
                             hp < amount ? 0 : (u16)(hp - amount));
}

void zeliard_hero_almas_add(zeliard_player_state_t *state, u16 amount) {
    u32 sum = (u32)zeliard_player_read_u16(state, ZEL_PLAYER_ALMAS) + amount;
    zeliard_player_write_u16(state, ZEL_PLAYER_ALMAS,
                             sum > 0xFFFFu ? 0xFFFFu : (u16)sum);
}

void zeliard_gold_add(zeliard_player_state_t *state, u16 amount_lo, u8 amount_hi) {
    const u32 amount = ((u32)amount_hi << 16) | amount_lo;
    zeliard_player_write_u24(
        state, ZEL_PLAYER_GOLD,
        zeliard_player_read_u24(state, ZEL_PLAYER_GOLD) + amount);
}

bool zeliard_gold_insufficient(const zeliard_player_state_t *state,
                               u16 amount_lo, u8 amount_hi) {
    const u8 gold_hi = zeliard_player_read_u8(state, ZEL_PLAYER_GOLD);
    const u16 gold_lo = zeliard_player_read_u16(state, ZEL_PLAYER_GOLD + 1);
    if (gold_hi < amount_hi) {
        return true;
    }
    u8 hi_remaining = (u8)(gold_hi - amount_hi);
    if (gold_lo >= amount_lo) {
        return false;
    }
    return hi_remaining == 0;
}

void zeliard_bank_add(zeliard_player_state_t *state, u16 amount_lo, u8 amount_hi) {
    const u32 amount = ((u32)amount_hi << 16) | amount_lo;
    zeliard_player_write_u24(
        state, ZEL_PLAYER_BANK_GOLD,
        zeliard_player_read_u24(state, ZEL_PLAYER_BANK_GOLD) + amount);
}

zeliard_town_walk_right_result_t zeliard_town_walk_right_col_full(
    u8 *town_player_col, u16 *starting_position, u16 *tile_ptr, u16 map_width) {
    if (*town_player_col < 0x10u) {
        ++(*town_player_col);
        return (zeliard_town_walk_right_result_t){
            .column_changed = true,
            .scrolled = false,
        };
    }

    u16 far_edge_start = (u16)(map_width - 0x23u);
    if (far_edge_start == (u16)(*starting_position + 1u)) {
        ++(*town_player_col);
        return (zeliard_town_walk_right_result_t){
            .column_changed = true,
            .scrolled = false,
        };
    }

    ++(*starting_position);
    *tile_ptr = (u16)(*tile_ptr + 8u);
    return (zeliard_town_walk_right_result_t){
        .column_changed = false,
        .scrolled = true,
    };
}

zeliard_town_walk_left_result_t zeliard_town_walk_left_col(
    u8 *town_player_col, u16 *starting_position, u16 *tile_ptr) {
    if (*town_player_col >= 0x0Bu) {
        --(*town_player_col);
        return (zeliard_town_walk_left_result_t){
            .column_changed = true,
            .scrolled = false,
        };
    }

    if (*starting_position == 0) {
        --(*town_player_col);
        return (zeliard_town_walk_left_result_t){
            .column_changed = true,
            .scrolled = false,
        };
    }

    --(*starting_position);
    *tile_ptr = (u16)(*tile_ptr - 8u);
    return (zeliard_town_walk_left_result_t){
        .column_changed = false,
        .scrolled = true,
    };
}

void zeliard_town_frame_clear_stat_x9f(u8 *stat_x9f) {
    *stat_x9f = 0;
}

void zeliard_entity_success_mark_stat_x9c(u8 *stat_x9c) {
    *stat_x9c = 0xFF;
}

void zeliard_inc_map_pos(zeliard_entity_pos_t *pos, u16 map_width) {
    pos->map_x = (u16)(pos->map_x + 1);
    pos->screen_x = (u8)(pos->screen_x + 1);
    if (pos->map_x >= map_width) {
        pos->map_x = (u16)(pos->map_x - map_width);
    }
}

void zeliard_dec_map_pos(zeliard_entity_pos_t *pos, u16 map_width) {
    pos->map_x = (u16)(pos->map_x - 1);
    pos->screen_x = (u8)(pos->screen_x - 1);
    if ((pos->map_x & 0x8000u) != 0) {
        pos->map_x = (u16)(pos->map_x + map_width);
    }
}

void zeliard_inc_row(zeliard_entity_pos_t *pos) {
    pos->row = (u8)((pos->row + 1) & 0x3F);
}

void zeliard_dec_row(zeliard_entity_pos_t *pos) {
    pos->row = (u8)((pos->row - 1) & 0x3F);
}

bool zeliard_entity_move_direction(zeliard_entity_pos_t *pos, u16 map_width,
                                   zeliard_entity_move_dir_t direction,
                                   bool collision) {
    bool east_bound = direction == ZELIARD_MOVE_E ||
                      direction == ZELIARD_MOVE_NE ||
                      direction == ZELIARD_MOVE_SE;
    bool west_bound = direction == ZELIARD_MOVE_W ||
                      direction == ZELIARD_MOVE_NW ||
                      direction == ZELIARD_MOVE_SW;
    bool vertical_only = direction == ZELIARD_MOVE_N ||
                         direction == ZELIARD_MOVE_S;

    if (east_bound && pos->screen_x >= 0x22u) {
        return false;
    }
    if (west_bound && pos->screen_x < 2u) {
        return false;
    }
    if (vertical_only && (pos->screen_x == 0 || pos->screen_x == 0x23u)) {
        return false;
    }
    if (collision) {
        return false;
    }

    switch (direction) {
    case ZELIARD_MOVE_E:
        zeliard_inc_map_pos(pos, map_width);
        break;
    case ZELIARD_MOVE_NE:
        zeliard_inc_map_pos(pos, map_width);
        zeliard_dec_row(pos);
        break;
    case ZELIARD_MOVE_N:
        zeliard_dec_row(pos);
        break;
    case ZELIARD_MOVE_NW:
        zeliard_dec_map_pos(pos, map_width);
        zeliard_dec_row(pos);
        break;
    case ZELIARD_MOVE_W:
        zeliard_dec_map_pos(pos, map_width);
        break;
    case ZELIARD_MOVE_SW:
        zeliard_dec_map_pos(pos, map_width);
        zeliard_inc_row(pos);
        break;
    case ZELIARD_MOVE_S:
        zeliard_inc_row(pos);
        break;
    case ZELIARD_MOVE_SE:
        zeliard_inc_map_pos(pos, map_width);
        zeliard_inc_row(pos);
        break;
    }

    return true;
}

void zeliard_tick_decrement_enemy_counters(u8 *enemy_data_buf) {
    u8 *entry = enemy_data_buf;
    while (*entry != 0xFF) {
        if (*entry != 0) {
            --(*entry);
        }
        entry += ZELIARD_ENEMY_ENTRY_STRIDE;
    }
}

void zeliard_tick_increment_enemy_counters(u8 *enemy_data_buf) {
    u8 *entry = enemy_data_buf;
    while (*entry != 0xFF) {
        if (*entry != 0) {
            ++(*entry);
        }
        entry += ZELIARD_ENEMY_ENTRY_STRIDE;
    }
}

bool zeliard_gate_spell_fx_active(u8 spell_fx_active) {
    return spell_fx_active != 0;
}

u16 zeliard_town_measure_word_width(const u8 *text, size_t max_len,
                                    const u8 glyph_widths[96],
                                    size_t *consumed) {
    u16 width = 0;
    size_t pos = 0;
    while (pos < max_len) {
        u8 ch = text[pos++];
        if ((ch & 0x80u) != 0 || ch == 0x20u || ch == 0x2Fu) {
            break;
        }
        if (ch < 0x20u) {
            continue;
        }
        width = (u16)(width + glyph_widths[ch - 0x20u]);
    }
    if (consumed != NULL) {
        *consumed = pos;
    }
    return width;
}

u16 zeliard_town_count_wrapped_lines(const u8 *text, size_t max_len,
                                     const u8 glyph_widths[96]) {
    u16 lines = 0;
    u16 line_width = 0;
    size_t pos = 0;

    while (pos < max_len) {
        u8 ch = text[pos++];
        if ((ch & 0x80u) != 0) {
            break;
        }
        if (ch == 0x2Fu) {
            ++lines;
            line_width = 0;
            continue;
        }

        if (ch >= 0x20u) {
            line_width = (u16)(line_width + glyph_widths[ch - 0x20u]);
        }

        if (ch == 0x20u) {
            u16 next_width = zeliard_town_measure_word_width(
                text + pos, max_len - pos, glyph_widths, NULL);
            if ((u16)(line_width + next_width) >= 0x00A8u) {
                line_width = 0;
                ++lines;
            }
        }
    }

    if (line_width != 0) {
        ++lines;
    }
    return lines;
}

u16 zeliard_town_dialog_cursor_pos(u16 dialog_pos, u8 row) {
    return (u16)(dialog_pos + 0x0100u + (u16)(row * 10u));
}

void zeliard_town_cursor_anim_positions(u16 dialog_pos, u8 row,
                                        bool slide_right,
                                        u16 positions[10]) {
    u16 pos = zeliard_town_dialog_cursor_pos(dialog_pos, row);
    for (u8 i = 0; i < 10; ++i) {
        pos = (u16)(pos + (slide_right ? 1 : -1));
        positions[i] = pos;
    }
}

zeliard_town_selection_scroll_result_t zeliard_town_selection_scroll_plan(
    u8 *sel_row, u8 visible_row, u16 dialog_pos, u8 dialog_cols,
    u8 dialog_timer, const u8 *selection_xlat, bool scroll_down) {
    if (scroll_down) {
        *sel_row = (u8)(*sel_row + 1u);
    } else {
        *sel_row = (u8)(*sel_row - 1u);
    }

    zeliard_town_selection_scroll_result_t result = {
        .sel_row = *sel_row,
        .init_al = selection_xlat[(u8)(*sel_row + visible_row)],
        .bx = (u16)(dialog_pos + 0x0301u),
        .cx = (u16)(((u16)dialog_timer << 8) |
                    (u8)((dialog_cols * 10u) - 2u)),
    };

    for (u8 i = 0; i < 10; ++i) {
        result.al_sequence[i] = scroll_down ? i : (u8)(9u - i);
    }
    return result;
}

zeliard_town_menu_decision_t zeliard_town_menu_input_decision(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows) {
    zeliard_town_menu_decision_t result = {
        .action = ZELIARD_TOWN_MENU_NONE,
        .visible_row = visible_row,
        .sel_row = sel_row,
    };

    switch (direction & 0x03u) {
    case 1:
        if (visible_row != 0) {
            result.visible_row = (u8)(visible_row - 1u);
            result.action = ZELIARD_TOWN_MENU_CURSOR_LEFT;
        } else if (sel_row != 0) {
            result.sel_row = (u8)(sel_row - 1u);
            result.action = ZELIARD_TOWN_MENU_SCROLL_UP;
        }
        break;
    case 2: {
        u8 bottom_visible_row = (u8)(dialog_cols - 1u);
        if (visible_row < bottom_visible_row) {
            result.visible_row = (u8)(visible_row + 1u);
            result.action = ZELIARD_TOWN_MENU_CURSOR_RIGHT;
        } else {
            u8 last_item_row = (u8)(dialog_rows - 1u);
            u8 next_item_row = (u8)(visible_row + sel_row + 1u);
            if (last_item_row >= next_item_row) {
                result.sel_row = (u8)(sel_row + 1u);
                result.action = ZELIARD_TOWN_MENU_SCROLL_DOWN;
            }
        }
        break;
    }
    default:
        break;
    }

    return result;
}

zeliard_town_menu_pre_joy_result_t zeliard_town_menu_pre_joy_result(
    u8 skip_flag2, u8 spacebar_state, u8 volume) {
    if (skip_flag2 != 0) {
        return (zeliard_town_menu_pre_joy_result_t){
            .action = ZELIARD_TOWN_MENU_PRE_JOY_SKIP,
            .terminal = true,
            .carry = true,
            .volume = volume,
        };
    }

    if (spacebar_state != 0) {
        return (zeliard_town_menu_pre_joy_result_t){
            .action = ZELIARD_TOWN_MENU_PRE_JOY_ACCEPT,
            .terminal = true,
            .carry = false,
            .volume = 0x1F,
        };
    }

    return (zeliard_town_menu_pre_joy_result_t){
        .action = ZELIARD_TOWN_MENU_PRE_JOY_CONTINUE,
        .terminal = false,
        .carry = true,
        .volume = volume,
    };
}

zeliard_town_menu_entry_result_t zeliard_town_menu_entry_after_tick(
    u8 visible_row, u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume) {
    return (zeliard_town_menu_entry_result_t){
        .draw_row = visible_row,
        .tick_row = visible_row,
        .skip_flag2 = tick_skip_flag2,
        .spacebar_state = tick_spacebar_state,
        .frame_timer = 0,
        .pre_joy = zeliard_town_menu_pre_joy_result(
            tick_skip_flag2, tick_spacebar_state, volume),
    };
}

zeliard_town_menu_entry_joystick_result_t zeliard_town_menu_entry_joystick_result(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows,
    u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume) {
    zeliard_town_menu_entry_result_t entry =
        zeliard_town_menu_entry_after_tick(
            visible_row, tick_skip_flag2, tick_spacebar_state, volume);
    zeliard_town_menu_decision_t decision = {
        .action = ZELIARD_TOWN_MENU_NONE,
        .visible_row = visible_row,
        .sel_row = sel_row,
    };
    if (!entry.pre_joy.terminal) {
        decision = zeliard_town_menu_input_decision(
            direction, visible_row, sel_row, dialog_cols, dialog_rows);
    }

    return (zeliard_town_menu_entry_joystick_result_t){
        .entry = entry,
        .decision = decision,
    };
}

zeliard_town_menu_entry_scroll_result_t zeliard_town_menu_entry_scroll_result(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows,
    u16 dialog_pos, u8 dialog_timer, const u8 *selection_xlat,
    u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume) {
    zeliard_town_menu_entry_joystick_result_t joystick =
        zeliard_town_menu_entry_joystick_result(
            direction, visible_row, sel_row, dialog_cols, dialog_rows,
            tick_skip_flag2, tick_spacebar_state, volume);

    zeliard_town_selection_scroll_result_t scroll = {0};
    bool did_scroll =
        joystick.decision.action == ZELIARD_TOWN_MENU_SCROLL_UP ||
        joystick.decision.action == ZELIARD_TOWN_MENU_SCROLL_DOWN;
    if (did_scroll) {
        u8 mutable_sel_row = sel_row;
        scroll = zeliard_town_selection_scroll_plan(
            &mutable_sel_row, visible_row, dialog_pos, dialog_cols,
            dialog_timer, selection_xlat,
            joystick.decision.action == ZELIARD_TOWN_MENU_SCROLL_DOWN);
    }

    return (zeliard_town_menu_entry_scroll_result_t){
        .joystick = joystick,
        .did_scroll = did_scroll,
        .scroll = scroll,
    };
}

zeliard_town_prompt_yes_no_result_t zeliard_town_prompt_yes_no_result(
    u8 dialog_cols, u8 dialog_rows, u8 sel_row, bool poll_carry) {
    return (zeliard_town_prompt_yes_no_result_t){
        .temp_dialog_cols = 2,
        .temp_dialog_rows = 2,
        .clear_rows = 2,
        .clear_text_ptr = 0x7513,
        .poll_visible_row = 0,
        .restored_dialog_cols = dialog_cols,
        .restored_dialog_rows = dialog_rows,
        .restored_sel_row = sel_row,
        .accepted = poll_carry,
        .carry = poll_carry,
    };
}

zeliard_town_clear_dialog_rows_plan_t zeliard_town_clear_dialog_rows_plan(
    u16 dialog_pos, u16 row_count, u16 initial_dx) {
    zeliard_town_clear_dialog_rows_plan_t plan = {0};
    u8 rows = (row_count > ZELIARD_TOWN_CLEAR_DIALOG_ROWS_MAX)
                  ? ZELIARD_TOWN_CLEAR_DIALOG_ROWS_MAX
                  : (u8)row_count;
    plan.call_count = rows;
    for (u8 row = 0; row < rows; ++row) {
        u16 ax = (u16)(dialog_pos + 0x0301u + ((u16)row * 10u));
        plan.calls[row] = (zeliard_town_clear_dialog_row_call_t){
            .row = row,
            .ax = ax,
            .bx = ax,
            .cx = 0,
            .dx = (u16)((initial_dx & 0xFF00u) | row),
        };
    }
    plan.final_cx = 0;
    plan.final_dx = (u16)((initial_dx & 0xFF00u) | (row_count & 0xFFu));
    return plan;
}

zeliard_town_shop_selection_anim_plan_t zeliard_town_shop_selection_anim_plan(
    u8 start_al, u16 count, u16 dialog_pos, const u8 *selection_xlat) {
    zeliard_town_shop_selection_anim_plan_t plan = {0};
    u8 calls = (count > ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX)
                   ? ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX
                   : (u8)count;
    plan.call_count = calls;
    for (u8 i = 0; i < calls; ++i) {
        u8 al = (u8)(start_al + i);
        plan.calls[i] = (zeliard_town_shop_selection_anim_call_t){
            .init_al = selection_xlat[al],
            .draw_bx = (u16)(dialog_pos + 0x0300u + ((u16)i * 10u)),
            .draw_cx = (u16)(count - i),
        };
    }
    plan.final_ax = (u16)(((count & 0xFFu) << 8) |
                          ((start_al + count) & 0xFFu));
    plan.final_cx = 0;
    return plan;
}

zeliard_town_shop_selection_anim_plan_t zeliard_town_menu_items_column_plan(
    u8 start_al, u16 count, u16 dialog_pos) {
    zeliard_town_shop_selection_anim_plan_t plan = {0};
    u8 calls = (count > ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX)
                   ? ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX
                   : (u8)count;
    plan.call_count = calls;
    for (u8 i = 0; i < calls; ++i) {
        plan.calls[i] = (zeliard_town_shop_selection_anim_call_t){
            .init_al = (u8)(start_al + i),
            .draw_bx = (u16)(dialog_pos + 0x0300u + ((u16)i * 10u)),
            .draw_cx = (u16)(count - i),
        };
    }
    plan.final_ax = (u16)(((count & 0xFFu) << 8) |
                          ((start_al + count) & 0xFFu));
    plan.final_cx = 0;
    return plan;
}

zeliard_town_save_name_new_check_t zeliard_town_check_save_name_is_new(
    const u8 save_name_buf[8], u8 save_name_len) {
    for (u8 i = 0; i < 8; ++i) {
        if (save_name_buf[i] == '-') {
            return (zeliard_town_save_name_new_check_t){
                .save_new_flag = 0xFF,
                .save_name_len = 0,
            };
        }
    }
    return (zeliard_town_save_name_new_check_t){
        .save_new_flag = 0,
        .save_name_len = save_name_len,
    };
}

zeliard_town_save_name_clear_result_t zeliard_town_clear_save_name_if_new(
    u8 save_new_flag, u8 save_name_maxlen, const u8 save_name_buf[8]) {
    zeliard_town_save_name_clear_result_t result = {
        .save_new_flag = save_new_flag,
        .save_name_maxlen = save_name_maxlen,
    };
    for (u8 i = 0; i < 8; ++i) {
        result.save_name_buf[i] = save_name_buf[i];
    }
    if (save_new_flag != 0) {
        result.save_new_flag = 0;
        result.save_name_maxlen = 0;
        for (u8 i = 0; i < 8; ++i) {
            result.save_name_buf[i] = '`';
        }
    }
    return result;
}

zeliard_town_save_name_cursor_update_t zeliard_town_save_name_cursor_update(
    u16 cursor_x, u8 cursor_y, u8 save_name_len, u8 save_name_maxlen, u8 delta) {
    u8 final_len = (u8)(save_name_len + delta);
    if (final_len & 0x80u) {
        final_len = 0;
    }
    if (final_len >= 8) {
        --final_len;
    }
    if (final_len >= save_name_maxlen) {
        final_len = save_name_maxlen;
    }

    return (zeliard_town_save_name_cursor_update_t){
        .fill_bx = (u16)(((((cursor_x >> 2) + ((u16)save_name_len * 2u)) & 0xFFu) << 8) |
                          ((cursor_y + 8u) & 0xFFu)),
        .fill_cx = 0x0208,
        .fill_ax = 0,
        .final_save_name_len = final_len,
        .draw_bx = (u16)(cursor_x + ((u16)final_len * 8u)),
        .draw_cx = (u16)(0x0200u | ((cursor_y + 8u) & 0xFFu)),
        .draw_ax = 0x067F,
    };
}

zeliard_town_save_name_redraw_t zeliard_town_save_name_redraw(
    u16 cursor_x, u8 cursor_y) {
    return (zeliard_town_save_name_redraw_t){
        .fill_bx = (u16)((((cursor_x >> 2) & 0xFFu) << 8) | cursor_y),
        .fill_cx = 0x1008,
        .fill_ax = 0,
        .draw_bx = cursor_x,
        .draw_cx = (u16)(0x1000u | cursor_y),
        .draw_si = 0x7C67,
    };
}

zeliard_town_save_name_backspace_result_t zeliard_town_save_name_backspace(
    u8 save_new_flag, u8 save_name_len, u8 save_name_maxlen,
    const u8 save_name_buf[8], u16 cursor_x, u8 cursor_y) {
    zeliard_town_save_name_backspace_result_t result = {
        .save_new_flag = save_new_flag,
        .save_name_len = save_name_len,
        .save_name_maxlen = save_name_maxlen,
    };
    for (u8 i = 0; i < 8; ++i) {
        result.save_name_buf[i] = save_name_buf[i];
    }
    if (result.save_new_flag != 0) {
        result.save_new_flag = 0;
        result.save_name_maxlen = 0;
        for (u8 i = 0; i < 8; ++i) {
            result.save_name_buf[i] = '`';
        }
    }

    u8 source = result.save_name_len;
    if (source == 0) {
        source = 1;
    }
    for (u8 i = 0; i < (u8)(8u - source); ++i) {
        result.save_name_buf[(u8)(source - 1u + i)] =
            result.save_name_buf[(u8)(source + i)];
    }
    if (result.save_name_maxlen != 0) {
        --result.save_name_maxlen;
    }
    result.save_name_buf[7] = '`';

    result.cursor_update = zeliard_town_save_name_cursor_update(
        cursor_x, cursor_y, result.save_name_len, result.save_name_maxlen, 0xFF);
    result.save_name_len = result.cursor_update.final_save_name_len;
    result.redraw = zeliard_town_save_name_redraw(cursor_x, cursor_y);
    return result;
}

zeliard_town_save_name_append_result_t zeliard_town_save_name_append_char(
    u8 save_new_flag, u8 save_name_len, u8 save_name_maxlen,
    const u8 save_name_buf[8], u16 cursor_x, u8 cursor_y, u8 char_value) {
    zeliard_town_save_name_append_result_t result = {
        .save_new_flag = save_new_flag,
        .save_name_len = save_name_len,
        .save_name_maxlen = save_name_maxlen,
    };
    for (u8 i = 0; i < 8; ++i) {
        result.save_name_buf[i] = save_name_buf[i];
    }
    if (result.save_new_flag != 0) {
        result.save_new_flag = 0;
        result.save_name_maxlen = 0;
        for (u8 i = 0; i < 8; ++i) {
            result.save_name_buf[i] = '`';
        }
    }

    u8 index = result.save_name_len;
    if (result.save_name_buf[index] == '`') {
        ++result.save_name_maxlen;
    }
    result.save_name_buf[index] = char_value;
    result.redraw = zeliard_town_save_name_redraw(cursor_x, cursor_y);
    result.cursor_update = zeliard_town_save_name_cursor_update(
        cursor_x, cursor_y, result.save_name_len, result.save_name_maxlen, 1);
    result.save_name_len = result.cursor_update.final_save_name_len;
    return result;
}

bool zeliard_is_entity_known_type(const zeliard_fight_tables_t *tables, u8 entity_id) {
    if (entity_id < 0x49) {
        for (size_t i = 0; i < sizeof(tables->enemy_id_table); ++i) {
            if (tables->enemy_id_table[i] == entity_id) {
                return true;
            }
        }
        return false;
    }
    return entity_id < 0x80;
}

bool zeliard_is_entity_id_lax(const zeliard_fight_tables_t *tables, u8 entity_id) {
    if (entity_id >= 0x49) {
        return true;
    }
    for (size_t i = 0; i < sizeof(tables->enemy_id_table); ++i) {
        if (tables->enemy_id_table[i] == entity_id) {
            return true;
        }
    }
    return false;
}

static u8 scan_move_slot(const u8 slot[4], u8 entity_id, u8 family) {
    for (u8 i = 0; i < 4; ++i) {
        if (slot[i] == 0) {
            return ZELIARD_MOVE_SLOT_NOT_FOUND;
        }
        if (slot[i] == entity_id) {
            return family;
        }
    }
    return ZELIARD_MOVE_SLOT_NOT_FOUND;
}

u8 zeliard_lookup_move_slot_family(const zeliard_fight_tables_t *tables, u8 entity_id) {
    if (entity_id == 0) {
        return ZELIARD_MOVE_SLOT_NOT_FOUND;
    }

    u8 family = scan_move_slot(tables->move_slot_a, entity_id, 0);
    if (family != ZELIARD_MOVE_SLOT_NOT_FOUND) {
        return family;
    }

    family = scan_move_slot(tables->move_slot_b, entity_id, 1);
    if (family != ZELIARD_MOVE_SLOT_NOT_FOUND) {
        return family;
    }

    return scan_move_slot(tables->move_slot_c, entity_id, 2);
}

bool zeliard_is_non_area7_slot_b_entity(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id) {
    if (area_num == 7) {
        return false;
    }
    return zeliard_lookup_move_slot_family(tables, entity_id) == 1;
}

bool zeliard_is_unknown_or_area5_slot_b(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id) {
    if (!zeliard_is_entity_known_type(tables, entity_id)) {
        return true;
    }
    if (area_num != 5) {
        return false;
    }
    return zeliard_lookup_move_slot_family(tables, entity_id) == 1;
}

bool zeliard_is_unknown_or_area5_slot_c(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id) {
    if (!zeliard_is_entity_known_type(tables, entity_id)) {
        return true;
    }
    if (area_num != 5) {
        return false;
    }
    return zeliard_lookup_move_slot_family(tables, entity_id) == 2;
}

void zeliard_reset_combat_state(zeliard_combat_reset_state_t *state) {
    state->scroll_active = 0;
    state->restore_pending = 0;
    state->gvar_palette_flag = 0;
    state->equip_byte = 0;
    state->flag_shield = 0;
    state->color_sel = 0;
    state->enemy_scroll_flag = 0;
    state->spell_fx_active = 0;
    state->gvar_item_result = 0;
    state->gvar_timer_ticks = 0;
    state->gvar_pose_idx = 0;

    state->enemy_data_buf = 0xFF;
    state->enemy_data_buf2 = 0xFF;
    state->boss_entry_tbl = 0xFFFF;
    state->flag_riding = 0xFF;
    state->combat_active = 0xFF;
}

void zeliard_compute_scroll_pos(u16 scroll_count, u8 scroll_dir, u8 player_y,
                                u16 map_width, u16 *map_scroll_col,
                                u8 *map_scroll_row) {
    u16 col = (u16)(scroll_count + 0xFFF0u);
    if ((col & 0x8000u) != 0) {
        col = (u16)(col + map_width);
    }
    *map_scroll_col = col;
    *map_scroll_row = (u8)((scroll_dir + 1u - player_y) & 0x3Fu);
}

zeliard_scroll_offset_b_result_t zeliard_compute_scroll_offset_b(
    u16 scroll_count, u16 map_width) {
    u16 bx = 0x000D;
    u16 ax = scroll_count;
    u16 cx = (u16)(map_width - bx);

    if (cx < ax) {
        ax = map_width;
        u32 add = (u32)ax + 0xFFDcu;
        ax = (u16)add;
        u16 carry = add > 0xFFFFu ? 1u : 0u;
        cx = (u16)(scroll_count - ax - carry);
        bx = (u8)((u8)cx - 3u);
        return (zeliard_scroll_offset_b_result_t){.ax = ax, .bx = bx};
    }

    ax = (u16)(ax + 0xFFEFu);
    if ((ax & 0xFF00u) != 0) {
        ax = 0;
        bx = (u8)((u8)scroll_count - 4u);
    }
    return (zeliard_scroll_offset_b_result_t){.ax = ax, .bx = bx};
}

zeliard_match_dl_result_t zeliard_match_dl_within_3(u8 cell, u8 dl) {
    u8 dh = 1;
    if (dl == cell) {
        return (zeliard_match_dl_result_t){.dh = dh, .dl = dl, .zero = true};
    }

    --dh;
    ++dl;
    if (dl == cell) {
        return (zeliard_match_dl_result_t){.dh = dh, .dl = dl, .zero = true};
    }

    --dh;
    ++dl;
    return (zeliard_match_dl_result_t){
        .dh = dh,
        .dl = dl,
        .zero = dl == cell,
    };
}

static u16 convert_world_x_to_screen_width(u16 world_x, u16 scroll_col,
                                           u16 map_width, u16 width) {
    u16 bx = world_x;
    u16 ax = (u16)(world_x - scroll_col);
    if (world_x >= scroll_col) {
        bx = ax;
        ax = width;
        return (u16)(ax - bx);
    }

    ax = width;
    ax = (u16)(ax - bx);
    if (width >= bx) {
        ax = (u16)(map_width - scroll_col);
        ax = (u16)(ax + bx);
        bx = ax;
        ax = width;
        return (u16)(ax - bx);
    }
    return ax;
}

u16 zeliard_convert_world_x_to_inner_screen_x(u16 world_x, u16 scroll_col,
                                              u16 map_width) {
    return convert_world_x_to_screen_width(world_x, scroll_col, map_width, 0x21);
}

u16 zeliard_convert_world_x_to_screen_x(u16 world_x, u16 scroll_col,
                                        u16 map_width) {
    return convert_world_x_to_screen_width(world_x, scroll_col, map_width, 0x23);
}

void zeliard_entity_slot_write_tagged(u8 *slot, u8 enemy_data_ext[0x80], u8 value) {
    if ((*slot & 0x80u) == 0) {
        *slot = value;
        return;
    }
    enemy_data_ext[*slot & 0x7Fu] = value;
}

zeliard_prep_dirty_blit_result_t zeliard_prep_dirty_blit(
    u16 *coord_word, u8 sprite_row, u8 sprite_col) {
    if ((*coord_word & 0x8000u) == 0) {
        return (zeliard_prep_dirty_blit_result_t){
            .dirty = false,
            .coord_word = *coord_word,
            .dx = 0,
            .al = 0,
            .ah = 0,
        };
    }

    *coord_word = (u16)(*coord_word & 0x7FFFu);
    return (zeliard_prep_dirty_blit_result_t){
        .dirty = true,
        .coord_word = *coord_word,
        .dx = *coord_word,
        .al = sprite_row,
        .ah = sprite_col,
    };
}

zeliard_enemy_sprite_blit_result_t zeliard_enemy_sprite_blit_gate(
    u8 slot_value, u8 al, u8 map_scroll_row) {
    if (slot_value >= 0xFCu) {
        return (zeliard_enemy_sprite_blit_result_t){
            .skipped = true,
            .calc_hud_called = true,
            .scroll_offset_called = false,
            .al = al,
        };
    }

    return (zeliard_enemy_sprite_blit_result_t){
        .skipped = false,
        .calc_hud_called = true,
        .scroll_offset_called = true,
        .al = (u8)(al + map_scroll_row),
    };
}

zeliard_prep_dirty_blit_result_t zeliard_prep_boss_dirty_blit(
    u16 *coord_word, u8 sprite_row, u8 sprite_col) {
    return zeliard_prep_dirty_blit(coord_word, sprite_row, sprite_col);
}

zeliard_entity_dispatch_b_result_t zeliard_entity_fn_dispatch_b_prepare(
    u8 state_byte, u8 al) {
    return (zeliard_entity_dispatch_b_result_t){
        .table_offset = (u8)((state_byte & 7u) * 2u),
        .al = (u8)(al & 0x3Fu),
    };
}

zeliard_entity_step_dispatch_c_result_t zeliard_entity_step_dispatch_c_prepare(
    u8 state_byte, u8 pos_byte, bool path_update_blocks) {
    bool path_update_called = (state_byte & 0x40u) != 0;
    if (path_update_called && path_update_blocks) {
        return (zeliard_entity_step_dispatch_c_result_t){
            .dispatched = false,
            .path_update_called = true,
            .table_offset = 0,
            .pos_byte = pos_byte,
        };
    }

    return (zeliard_entity_step_dispatch_c_result_t){
        .dispatched = true,
        .path_update_called = path_update_called,
        .table_offset = (u8)((state_byte & 7u) * 2u),
        .pos_byte = (u8)(pos_byte & 0x3Fu),
    };
}

u8 zeliard_scroll_dispatch_table_offset(u8 encoded_cell) {
    return (u8)(((encoded_cell >> 6) & 0x03u) * 2u);
}

u16 zeliard_scroll_buf_offset(u8 row, u8 col) {
    return (u16)(ZELIARD_SCROLL_BUF +
                 (u16)(row & 0x3Fu) * ZELIARD_SCROLL_ROW_STRIDE +
                 col);
}

u16 zeliard_scroll_si_wrap_high(u16 si) {
    if (si >= ZELIARD_HUD_BUF) {
        return (u16)(si - ZELIARD_SCROLL_WRAP_SIZE);
    }
    return si;
}

u16 zeliard_scroll_si_wrap_low(u16 si) {
    if (si < ZELIARD_SCROLL_BUF) {
        return (u16)(si + ZELIARD_SCROLL_WRAP_SIZE);
    }
    return si;
}

bool zeliard_gate_area4_no_accessory4(u8 area_num, u8 selected_accessory) {
    return area_num == 4 && selected_accessory != 4;
}

u16 zeliard_scroll_si_from_player(u8 fight_player_col, u8 screen_position,
                                  u16 gvar_scroll_pos) {
    u16 si = (u16)((u16)fight_player_col * ZELIARD_SCROLL_ROW_STRIDE +
                   (u8)(screen_position + 4u) +
                   gvar_scroll_pos);
    return zeliard_scroll_si_wrap_high(si);
}

u16 zeliard_world_tile_entry_address(u16 world_tile_base, u8 entity_index) {
    return (u16)(world_tile_base + (u16)entity_index * 2u);
}

zeliard_object_state_result_t zeliard_get_object_state_at_cell(
    u8 scroll_cell, const u8 *object_list) {
    if ((scroll_cell & 0x80u) == 0) {
        return (zeliard_object_state_result_t){
            .carry = true,
            .value = scroll_cell,
            .zero = true,
        };
    }

    u8 slot = (u8)(scroll_cell & 0x7Fu);
    u8 value = object_list[(size_t)slot * ZELIARD_OBJECT_ENTRY_STRIDE + 4u];
    return (zeliard_object_state_result_t){
        .carry = false,
        .value = value,
        .zero = value == 0,
    };
}

bool zeliard_try_place_tile_id_49(u8 *charge_counter, bool object_carry,
                                  const u8 *slot4, u8 *slot5) {
    if (*charge_counter == 0) {
        return false;
    }
    if (object_carry) {
        return false;
    }
    if ((*slot4 & 0x20u) != 0) {
        return false;
    }
    if ((*slot5 & 0x20u) != 0) {
        return false;
    }

    *slot5 = (u8)((*slot5 & 0xE0u) | 0x49u);
    --(*charge_counter);
    return true;
}

u16 zeliard_tick_right_col_entities(u8 *escape_flag, u8 fight_player_col,
                                    u8 screen_position, u16 gvar_scroll_pos,
                                    u16 dispatch_si[3]) {
    *escape_flag = 0;
    u16 si = zeliard_scroll_si_from_player(fight_player_col, screen_position,
                                           gvar_scroll_pos);
    si = zeliard_scroll_si_wrap_high((u16)(si + 0x49u));

    for (u8 i = 0; i < 3; ++i) {
        dispatch_si[i] = si;
        si = zeliard_scroll_si_wrap_low((u16)(si - ZELIARD_SCROLL_ROW_STRIDE));
    }

    return si;
}

static size_t scroll_buf_index(u16 si) {
    return (size_t)(si - ZELIARD_SCROLL_BUF);
}

zeliard_place_3cell_result_t zeliard_try_place_3cell_entity_row(
    const u8 scroll_buf[0x900], u16 si_base, u8 *entity_row) {
    zeliard_place_3cell_result_t result = {
        .placed = false,
        .write_calls = 0,
        .write_targets = {0},
        .row_after = *entity_row,
    };

    u16 check_si = zeliard_scroll_si_wrap_high((u16)(si_base + 0x23u));
    if ((scroll_buf[scroll_buf_index(check_si)] & 0x80u) != 0) {
        return result;
    }

    for (u8 i = 0; i < 3; ++i) {
        u16 slot_si = (u16)(check_si + 1u + i);
        if (scroll_buf[scroll_buf_index(slot_si)] != 0) {
            return result;
        }
    }

    u16 row_si = zeliard_scroll_si_wrap_high((u16)(si_base + ZELIARD_SCROLL_ROW_STRIDE));
    u16 bx = si_base;
    u16 di = row_si;
    for (u8 i = 0; i < 3; ++i) {
        result.write_targets[result.write_calls++] = di;
        u16 saved = bx;
        bx = di;
        di = saved;
        result.write_targets[result.write_calls++] = di;
        saved = bx;
        bx = di;
        di = saved;
        ++di;
        ++bx;
    }

    *entity_row = (u8)((*entity_row + 1u) & 0x3Fu);
    result.placed = true;
    result.row_after = *entity_row;
    return result;
}
