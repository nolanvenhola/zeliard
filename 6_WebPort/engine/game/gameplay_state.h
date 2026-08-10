#ifndef ZELIARD_GAMEPLAY_STATE_H
#define ZELIARD_GAMEPLAY_STATE_H

#include "../core/types.h"
#include "../core/player_state.h"

typedef struct {
    u16 map_x;         /* [si] */
    u8  row;           /* [si+2] */
    u8  screen_x;      /* [si+3] */
} zeliard_entity_pos_t;

typedef enum {
    ZELIARD_MOVE_E,
    ZELIARD_MOVE_NE,
    ZELIARD_MOVE_N,
    ZELIARD_MOVE_NW,
    ZELIARD_MOVE_W,
    ZELIARD_MOVE_SW,
    ZELIARD_MOVE_S,
    ZELIARD_MOVE_SE
} zeliard_entity_move_dir_t;

typedef struct {
    u8 enemy_id_table[0x18]; /* DS:0x8000 */
    u8 move_slot_a[4];       /* DS:0x8024 */
    u8 move_slot_b[4];       /* DS:0x8028 */
    u8 move_slot_c[4];       /* DS:0x802C */
} zeliard_fight_tables_t;

typedef struct {
    u8 gvar_pose_idx;      /* DS:0x00E7 */
    u8 gvar_timer_ticks;   /* DS:0xFF08 */
    u8 color_sel;          /* DS:0xFF36 */
    u8 flag_shield;        /* DS:0xFF38 */
    u8 flag_riding;        /* DS:0xFF3A */
    u8 gvar_palette_flag;  /* DS:0xFF3C */
    u8 equip_byte;         /* DS:0xFF3D */
    u8 spell_fx_active;    /* DS:0xFF3E */
    u8 scroll_active;      /* DS:0xFF43 */
    u8 restore_pending;    /* DS:0xFF44 */
    u8 gvar_item_result;   /* DS:0xFF4B */
    u8 enemy_scroll_flag;  /* DS:0x9EEF */
    u8 combat_active;      /* DS:0x9EF5 */
    u8 enemy_data_buf;     /* DS:0xEB80 */
    u8 enemy_data_buf2;    /* DS:0xEDA0 */
    u16 boss_entry_tbl;    /* DS:0xEB15 */
} zeliard_combat_reset_state_t;

typedef struct {
    bool carry;
    u8 value;
    bool zero;
} zeliard_object_state_result_t;

typedef struct {
    bool placed;
    u8 write_calls;
    u16 write_targets[6];
    u8 row_after;
} zeliard_place_3cell_result_t;

typedef struct {
    bool column_changed;
    bool scrolled;
} zeliard_town_walk_left_result_t;

typedef struct {
    bool column_changed;
    bool scrolled;
} zeliard_town_walk_right_result_t;

typedef struct {
    u8 sel_row;
    u8 init_al;
    u16 bx;
    u16 cx;
    u8 al_sequence[10];
} zeliard_town_selection_scroll_result_t;

typedef enum {
    ZELIARD_TOWN_MENU_NONE,
    ZELIARD_TOWN_MENU_CURSOR_LEFT,
    ZELIARD_TOWN_MENU_CURSOR_RIGHT,
    ZELIARD_TOWN_MENU_SCROLL_UP,
    ZELIARD_TOWN_MENU_SCROLL_DOWN
} zeliard_town_menu_action_t;

typedef struct {
    zeliard_town_menu_action_t action;
    u8 visible_row;
    u8 sel_row;
} zeliard_town_menu_decision_t;

typedef enum {
    ZELIARD_TOWN_MENU_PRE_JOY_CONTINUE,
    ZELIARD_TOWN_MENU_PRE_JOY_SKIP,
    ZELIARD_TOWN_MENU_PRE_JOY_ACCEPT
} zeliard_town_menu_pre_joy_action_t;

typedef struct {
    zeliard_town_menu_pre_joy_action_t action;
    bool terminal;
    bool carry;
    u8 volume;
} zeliard_town_menu_pre_joy_result_t;

typedef struct {
    u8 draw_row;
    u8 tick_row;
    u8 skip_flag2;
    u8 spacebar_state;
    u8 frame_timer;
    zeliard_town_menu_pre_joy_result_t pre_joy;
} zeliard_town_menu_entry_result_t;

typedef struct {
    zeliard_town_menu_entry_result_t entry;
    zeliard_town_menu_decision_t decision;
} zeliard_town_menu_entry_joystick_result_t;

typedef struct {
    zeliard_town_menu_entry_joystick_result_t joystick;
    bool did_scroll;
    zeliard_town_selection_scroll_result_t scroll;
} zeliard_town_menu_entry_scroll_result_t;

typedef struct {
    u8 temp_dialog_cols;
    u8 temp_dialog_rows;
    u16 clear_rows;
    u16 clear_text_ptr;
    u8 poll_visible_row;
    u8 restored_dialog_cols;
    u8 restored_dialog_rows;
    u8 restored_sel_row;
    bool accepted;
    bool carry;
} zeliard_town_prompt_yes_no_result_t;

#define ZELIARD_TOWN_CLEAR_DIALOG_ROWS_MAX 8

typedef struct {
    u8 row;
    u16 ax;
    u16 bx;
    u16 cx;
    u16 dx;
} zeliard_town_clear_dialog_row_call_t;

typedef struct {
    u8 call_count;
    zeliard_town_clear_dialog_row_call_t calls[ZELIARD_TOWN_CLEAR_DIALOG_ROWS_MAX];
    u16 final_cx;
    u16 final_dx;
} zeliard_town_clear_dialog_rows_plan_t;

#define ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX 8

typedef struct {
    u8 init_al;
    u16 draw_bx;
    u16 draw_cx;
} zeliard_town_shop_selection_anim_call_t;

typedef struct {
    u8 call_count;
    zeliard_town_shop_selection_anim_call_t calls[ZELIARD_TOWN_SHOP_SELECTION_ANIM_MAX];
    u16 final_ax;
    u16 final_cx;
} zeliard_town_shop_selection_anim_plan_t;

typedef struct {
    u8 save_new_flag;
    u8 save_name_len;
} zeliard_town_save_name_new_check_t;

typedef struct {
    u8 save_new_flag;
    u8 save_name_maxlen;
    u8 save_name_buf[8];
} zeliard_town_save_name_clear_result_t;

typedef struct {
    u16 fill_bx;
    u16 fill_cx;
    u16 fill_ax;
    u8 final_save_name_len;
    u16 draw_bx;
    u16 draw_cx;
    u16 draw_ax;
} zeliard_town_save_name_cursor_update_t;

typedef struct {
    u16 fill_bx;
    u16 fill_cx;
    u16 fill_ax;
    u16 draw_bx;
    u16 draw_cx;
    u16 draw_si;
} zeliard_town_save_name_redraw_t;

typedef struct {
    u8 save_new_flag;
    u8 save_name_len;
    u8 save_name_maxlen;
    u8 save_name_buf[8];
    zeliard_town_save_name_cursor_update_t cursor_update;
    zeliard_town_save_name_redraw_t redraw;
} zeliard_town_save_name_backspace_result_t;

typedef zeliard_town_save_name_backspace_result_t zeliard_town_save_name_append_result_t;

typedef struct {
    u16 ax;
    u16 bx;
} zeliard_scroll_offset_b_result_t;

typedef struct {
    u8 dh;
    u8 dl;
    bool zero;
} zeliard_match_dl_result_t;

typedef struct {
    bool dirty;
    u16 coord_word;
    u16 dx;
    u8 al;
    u8 ah;
} zeliard_prep_dirty_blit_result_t;

typedef struct {
    u8 table_offset;
    u8 al;
} zeliard_entity_dispatch_b_result_t;

typedef struct {
    bool dispatched;
    bool path_update_called;
    u8 table_offset;
    u8 pos_byte;
} zeliard_entity_step_dispatch_c_result_t;

void zeliard_subtract_from_player_hp(zeliard_player_state_t *state, u16 amount);
void zeliard_hero_almas_add(zeliard_player_state_t *state, u16 amount);

void zeliard_gold_add(zeliard_player_state_t *state, u16 amount_lo, u8 amount_hi);
bool zeliard_gold_insufficient(const zeliard_player_state_t *state,
                               u16 amount_lo, u8 amount_hi);
void zeliard_bank_add(zeliard_player_state_t *state, u16 amount_lo, u8 amount_hi);
zeliard_town_walk_right_result_t zeliard_town_walk_right_col_full(
    u8 *town_player_col, u16 *starting_position, u16 *tile_ptr, u16 map_width);
zeliard_town_walk_left_result_t zeliard_town_walk_left_col(
    u8 *town_player_col, u16 *starting_position, u16 *tile_ptr);
void zeliard_town_frame_clear_stat_x9f(u8 *stat_x9f);
void zeliard_entity_success_mark_stat_x9c(u8 *stat_x9c);

void zeliard_inc_map_pos(zeliard_entity_pos_t *pos, u16 map_width);
void zeliard_dec_map_pos(zeliard_entity_pos_t *pos, u16 map_width);
void zeliard_inc_row(zeliard_entity_pos_t *pos);
void zeliard_dec_row(zeliard_entity_pos_t *pos);
bool zeliard_entity_move_direction(zeliard_entity_pos_t *pos, u16 map_width,
                                   zeliard_entity_move_dir_t direction,
                                   bool collision);

void zeliard_tick_decrement_enemy_counters(u8 *enemy_data_buf);
void zeliard_tick_increment_enemy_counters(u8 *enemy_data_buf);

bool zeliard_gate_spell_fx_active(u8 spell_fx_active);
u16 zeliard_town_measure_word_width(const u8 *text, size_t max_len,
                                    const u8 glyph_widths[96],
                                    size_t *consumed);
u16 zeliard_town_count_wrapped_lines(const u8 *text, size_t max_len,
                                     const u8 glyph_widths[96]);
u16 zeliard_town_dialog_cursor_pos(u16 dialog_pos, u8 row);
void zeliard_town_cursor_anim_positions(u16 dialog_pos, u8 row,
                                        bool slide_right,
                                        u16 positions[10]);
zeliard_town_selection_scroll_result_t zeliard_town_selection_scroll_plan(
    u8 *sel_row, u8 visible_row, u16 dialog_pos, u8 dialog_cols,
    u8 dialog_timer, const u8 *selection_xlat, bool scroll_down);
zeliard_town_menu_decision_t zeliard_town_menu_input_decision(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows);
zeliard_town_menu_pre_joy_result_t zeliard_town_menu_pre_joy_result(
    u8 skip_flag2, u8 spacebar_state, u8 volume);
zeliard_town_menu_entry_result_t zeliard_town_menu_entry_after_tick(
    u8 visible_row, u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume);
zeliard_town_menu_entry_joystick_result_t zeliard_town_menu_entry_joystick_result(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows,
    u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume);
zeliard_town_menu_entry_scroll_result_t zeliard_town_menu_entry_scroll_result(
    u8 direction, u8 visible_row, u8 sel_row, u8 dialog_cols, u8 dialog_rows,
    u16 dialog_pos, u8 dialog_timer, const u8 *selection_xlat,
    u8 tick_skip_flag2, u8 tick_spacebar_state, u8 volume);
zeliard_town_prompt_yes_no_result_t zeliard_town_prompt_yes_no_result(
    u8 dialog_cols, u8 dialog_rows, u8 sel_row, bool poll_carry);
zeliard_town_clear_dialog_rows_plan_t zeliard_town_clear_dialog_rows_plan(
    u16 dialog_pos, u16 row_count, u16 initial_dx);
zeliard_town_shop_selection_anim_plan_t zeliard_town_shop_selection_anim_plan(
    u8 start_al, u16 count, u16 dialog_pos, const u8 *selection_xlat);
zeliard_town_shop_selection_anim_plan_t zeliard_town_menu_items_column_plan(
    u8 start_al, u16 count, u16 dialog_pos);
zeliard_town_save_name_new_check_t zeliard_town_check_save_name_is_new(
    const u8 save_name_buf[8], u8 save_name_len);
zeliard_town_save_name_clear_result_t zeliard_town_clear_save_name_if_new(
    u8 save_new_flag, u8 save_name_maxlen, const u8 save_name_buf[8]);
zeliard_town_save_name_cursor_update_t zeliard_town_save_name_cursor_update(
    u16 cursor_x, u8 cursor_y, u8 save_name_len, u8 save_name_maxlen, u8 delta);
zeliard_town_save_name_redraw_t zeliard_town_save_name_redraw(
    u16 cursor_x, u8 cursor_y);
zeliard_town_save_name_backspace_result_t zeliard_town_save_name_backspace(
    u8 save_new_flag, u8 save_name_len, u8 save_name_maxlen,
    const u8 save_name_buf[8], u16 cursor_x, u8 cursor_y);
zeliard_town_save_name_append_result_t zeliard_town_save_name_append_char(
    u8 save_new_flag, u8 save_name_len, u8 save_name_maxlen,
    const u8 save_name_buf[8], u16 cursor_x, u8 cursor_y, u8 char_value);
bool zeliard_is_entity_known_type(const zeliard_fight_tables_t *tables, u8 entity_id);
bool zeliard_is_entity_id_lax(const zeliard_fight_tables_t *tables, u8 entity_id);
u8 zeliard_lookup_move_slot_family(const zeliard_fight_tables_t *tables, u8 entity_id);
bool zeliard_is_non_area7_slot_b_entity(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id);
bool zeliard_is_unknown_or_area5_slot_b(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id);
bool zeliard_is_unknown_or_area5_slot_c(const zeliard_fight_tables_t *tables,
                                        u8 area_num, u8 entity_id);
void zeliard_reset_combat_state(zeliard_combat_reset_state_t *state);

void zeliard_compute_scroll_pos(u16 scroll_count, u8 scroll_dir, u8 player_y,
                                u16 map_width, u16 *map_scroll_col,
                                u8 *map_scroll_row);
zeliard_scroll_offset_b_result_t zeliard_compute_scroll_offset_b(
    u16 scroll_count, u16 map_width);
zeliard_match_dl_result_t zeliard_match_dl_within_3(u8 cell, u8 dl);
u16 zeliard_convert_world_x_to_inner_screen_x(u16 world_x, u16 scroll_col,
                                              u16 map_width);
u16 zeliard_convert_world_x_to_screen_x(u16 world_x, u16 scroll_col,
                                        u16 map_width);
void zeliard_entity_slot_write_tagged(u8 *slot, u8 enemy_data_ext[0x80], u8 value);
zeliard_prep_dirty_blit_result_t zeliard_prep_dirty_blit(
    u16 *coord_word, u8 sprite_row, u8 sprite_col);
zeliard_prep_dirty_blit_result_t zeliard_prep_boss_dirty_blit(
    u16 *coord_word, u8 sprite_row, u8 sprite_col);
zeliard_entity_dispatch_b_result_t zeliard_entity_fn_dispatch_b_prepare(
    u8 state_byte, u8 al);
zeliard_entity_step_dispatch_c_result_t zeliard_entity_step_dispatch_c_prepare(
    u8 state_byte, u8 pos_byte, bool path_update_blocks);
u8 zeliard_scroll_dispatch_table_offset(u8 encoded_cell);
u16 zeliard_scroll_buf_offset(u8 row, u8 col);
u16 zeliard_scroll_si_wrap_high(u16 si);
u16 zeliard_scroll_si_wrap_low(u16 si);
bool zeliard_gate_area4_no_accessory4(u8 area_num, u8 selected_accessory);
u16 zeliard_scroll_si_from_player(u8 fight_player_col, u8 screen_position,
                                  u16 gvar_scroll_pos);
u16 zeliard_world_tile_entry_address(u16 world_tile_base, u8 entity_index);
zeliard_object_state_result_t zeliard_get_object_state_at_cell(
    u8 scroll_cell, const u8 *object_list);
bool zeliard_try_place_tile_id_49(u8 *charge_counter, bool object_carry,
                                  const u8 *slot4, u8 *slot5);
u16 zeliard_tick_right_col_entities(u8 *escape_flag, u8 fight_player_col,
                                    u8 screen_position, u16 gvar_scroll_pos,
                                    u16 dispatch_si[3]);
zeliard_place_3cell_result_t zeliard_try_place_3cell_entity_row(
    const u8 scroll_buf[0x900], u16 si_base, u8 *entity_row);

#endif
