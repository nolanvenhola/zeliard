#include "../game/gameplay_state.h"
#include <stdio.h>
#include <string.h>

static int expect_u16(const char *label, u16 got, u16 want) {
    int ok = got == want;
    printf("%s: %s got=0x%04X want=0x%04X\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_u8(const char *label, u8 got, u8 want) {
    int ok = got == want;
    printf("%s: %s got=0x%02X want=0x%02X\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_bool(const char *label, bool got, bool want) {
    int ok = got == want;
    printf("%s: %s got=%d want=%d\n", label, ok ? "PASS" : "FAIL", got ? 1 : 0, want ? 1 : 0);
    return ok;
}

static int run_hp_cases(void) {
    int ok = 1;
    zeliard_player_state_t s = {.hero_hp = 50};
    zeliard_subtract_from_player_hp(&s, 20);
    ok &= expect_u16("HP_sub:normal", s.hero_hp, 30);

    s.hero_hp = 10;
    zeliard_subtract_from_player_hp(&s, 50);
    ok &= expect_u16("HP_sub:underflow_clamp", s.hero_hp, 0);

    s.hero_hp = 0xFFFF;
    zeliard_subtract_from_player_hp(&s, 1);
    ok &= expect_u16("HP_sub:no_underflow", s.hero_hp, 0xFFFE);
    return ok;
}

static int run_almas_cases(void) {
    int ok = 1;
    zeliard_player_state_t s = {.hero_almas = 100};
    zeliard_hero_almas_add(&s, 50);
    ok &= expect_u16("almas_add:simple", s.hero_almas, 150);

    s.hero_almas = 0xFFF0;
    zeliard_hero_almas_add(&s, 0x10);
    ok &= expect_u16("almas_add:overflow_cap", s.hero_almas, 0xFFFF);

    s.hero_almas = 0x00FE;
    zeliard_hero_almas_add(&s, 2);
    ok &= expect_u16("almas_add:carry_into_high", s.hero_almas, 0x0100);
    return ok;
}

static int run_gold_bank_cases(void) {
    int ok = 1;
    zeliard_player_state_t s = {0};

    zeliard_gold_add(&s, 100, 0);
    ok &= expect_u8("gold_add:simple:hi", s.gold_hi, 0);
    ok &= expect_u16("gold_add:simple:lo", s.gold_lo, 100);

    s.gold_hi = 0; s.gold_lo = 0xFFFE;
    zeliard_gold_add(&s, 5, 0);
    ok &= expect_u8("gold_add:carry:hi", s.gold_hi, 1);
    ok &= expect_u16("gold_add:carry:lo", s.gold_lo, 3);

    s.gold_hi = 0; s.gold_lo = 200;
    ok &= expect_bool("gold_check:enough", zeliard_gold_insufficient(&s, 100, 0), false);
    s.gold_hi = 0; s.gold_lo = 50;
    ok &= expect_bool("gold_check:not_enough", zeliard_gold_insufficient(&s, 100, 0), true);
    s.gold_hi = 0; s.gold_lo = 100;
    ok &= expect_bool("gold_check:exact", zeliard_gold_insufficient(&s, 100, 0), false);

    s.bank_hi = 0; s.bank_lo = 0;
    zeliard_bank_add(&s, 100, 0);
    ok &= expect_u8("bank_add:simple:hi", s.bank_hi, 0);
    ok &= expect_u16("bank_add:simple:lo", s.bank_lo, 100);

    s.bank_hi = 0; s.bank_lo = 0xFFFE;
    zeliard_bank_add(&s, 5, 0);
    ok &= expect_u8("bank_add:carry:hi", s.bank_hi, 1);
    ok &= expect_u16("bank_add:carry:lo", s.bank_lo, 3);

    s.bank_hi = 0; s.bank_lo = 0;
    zeliard_bank_add(&s, 10, 2);
    ok &= expect_u8("bank_add:nonzero_dl:hi", s.bank_hi, 2);
    ok &= expect_u16("bank_add:nonzero_dl:lo", s.bank_lo, 10);
    return ok;
}

static int run_town_state_cases(void) {
    int ok = 1;
    u8 town_col = 0x05;
    ok &= expect_bool("town_walk_right_col:inside:moved",
                      zeliard_town_walk_right_col(&town_col), true);
    ok &= expect_u8("town_walk_right_col:inside:col", town_col, 0x06);

    town_col = 0x0F;
    ok &= expect_bool("town_walk_right_col:one_before_bound:moved",
                      zeliard_town_walk_right_col(&town_col), true);
    ok &= expect_u8("town_walk_right_col:one_before_bound:col", town_col, 0x10);

    town_col = 0x10;
    ok &= expect_bool("town_walk_right_col:at_bound:moved",
                      zeliard_town_walk_right_col(&town_col), false);
    ok &= expect_u8("town_walk_right_col:at_bound:col", town_col, 0x10);

    u16 start = 0x0020;
    u16 tile_ptr = 0x1234;
    town_col = 0x0F;
    zeliard_town_walk_right_result_t right =
        zeliard_town_walk_right_col_full(&town_col, &start, &tile_ptr, 0x0064);
    ok &= expect_bool("town_walk_right_col_full:inside:changed", right.column_changed, true);
    ok &= expect_bool("town_walk_right_col_full:inside:scrolled", right.scrolled, false);
    ok &= expect_u8("town_walk_right_col_full:inside:col", town_col, 0x10);
    ok &= expect_u16("town_walk_right_col_full:inside:start", start, 0x0020);
    ok &= expect_u16("town_walk_right_col_full:inside:tile", tile_ptr, 0x1234);

    start = 0x0003;
    tile_ptr = 0x1234;
    town_col = 0x10;
    right = zeliard_town_walk_right_col_full(&town_col, &start, &tile_ptr, 0x0064);
    ok &= expect_bool("town_walk_right_col_full:scroll:changed", right.column_changed, false);
    ok &= expect_bool("town_walk_right_col_full:scroll:scrolled", right.scrolled, true);
    ok &= expect_u8("town_walk_right_col_full:scroll:col", town_col, 0x10);
    ok &= expect_u16("town_walk_right_col_full:scroll:start", start, 0x0004);
    ok &= expect_u16("town_walk_right_col_full:scroll:tile", tile_ptr, 0x123C);

    start = 0x0003;
    tile_ptr = 0x1234;
    town_col = 0x10;
    right = zeliard_town_walk_right_col_full(&town_col, &start, &tile_ptr, 0x0027);
    ok &= expect_bool("town_walk_right_col_full:far_edge:changed", right.column_changed, true);
    ok &= expect_bool("town_walk_right_col_full:far_edge:scrolled", right.scrolled, false);
    ok &= expect_u8("town_walk_right_col_full:far_edge:col", town_col, 0x11);
    ok &= expect_u16("town_walk_right_col_full:far_edge:start", start, 0x0003);
    ok &= expect_u16("town_walk_right_col_full:far_edge:tile", tile_ptr, 0x1234);

    start = 0x0020;
    tile_ptr = 0x1234;
    town_col = 0x0D;
    zeliard_town_walk_left_result_t left =
        zeliard_town_walk_left_col(&town_col, &start, &tile_ptr);
    ok &= expect_bool("town_walk_left_col:inside:changed", left.column_changed, true);
    ok &= expect_bool("town_walk_left_col:inside:scrolled", left.scrolled, false);
    ok &= expect_u8("town_walk_left_col:inside:col", town_col, 0x0C);
    ok &= expect_u16("town_walk_left_col:inside:start", start, 0x0020);
    ok &= expect_u16("town_walk_left_col:inside:tile", tile_ptr, 0x1234);

    start = 0x0020;
    tile_ptr = 0x1234;
    town_col = 0x0B;
    left = zeliard_town_walk_left_col(&town_col, &start, &tile_ptr);
    ok &= expect_bool("town_walk_left_col:threshold:changed", left.column_changed, true);
    ok &= expect_u8("town_walk_left_col:threshold:col", town_col, 0x0A);

    start = 0x0000;
    tile_ptr = 0x1234;
    town_col = 0x0A;
    left = zeliard_town_walk_left_col(&town_col, &start, &tile_ptr);
    ok &= expect_bool("town_walk_left_col:no_scroll_edge:changed", left.column_changed, true);
    ok &= expect_bool("town_walk_left_col:no_scroll_edge:scrolled", left.scrolled, false);
    ok &= expect_u8("town_walk_left_col:no_scroll_edge:col", town_col, 0x09);
    ok &= expect_u16("town_walk_left_col:no_scroll_edge:start", start, 0x0000);
    ok &= expect_u16("town_walk_left_col:no_scroll_edge:tile", tile_ptr, 0x1234);

    start = 0x0003;
    tile_ptr = 0x1234;
    town_col = 0x0A;
    left = zeliard_town_walk_left_col(&town_col, &start, &tile_ptr);
    ok &= expect_bool("town_walk_left_col:scroll:changed", left.column_changed, false);
    ok &= expect_bool("town_walk_left_col:scroll:scrolled", left.scrolled, true);
    ok &= expect_u8("town_walk_left_col:scroll:col", town_col, 0x0A);
    ok &= expect_u16("town_walk_left_col:scroll:start", start, 0x0002);
    ok &= expect_u16("town_walk_left_col:scroll:tile", tile_ptr, 0x122C);

    u8 stat_x9f = 0x55;
    zeliard_town_frame_clear_stat_x9f(&stat_x9f);
    ok &= expect_u8("town_frame_clear_stat_x9f:sentinel", stat_x9f, 0x00);

    u8 stat_x9c = 0x55;
    zeliard_entity_success_mark_stat_x9c(&stat_x9c);
    ok &= expect_u8("entity_success_mark_stat_x9c:sentinel", stat_x9c, 0xFF);
    return ok;
}

static int run_movement_cases(void) {
    int ok = 1;
    zeliard_entity_pos_t p = {.map_x = 50, .row = 0, .screen_x = 5};
    zeliard_inc_map_pos(&p, 100);
    ok &= expect_u16("inc_map_pos:in_bounds:x", p.map_x, 51);
    ok &= expect_u8("inc_map_pos:in_bounds:screen", p.screen_x, 6);

    p.map_x = 99; p.screen_x = 5;
    zeliard_inc_map_pos(&p, 100);
    ok &= expect_u16("inc_map_pos:wrap:x", p.map_x, 0);
    ok &= expect_u8("inc_map_pos:wrap:screen", p.screen_x, 6);

    p.map_x = 50; p.screen_x = 5;
    zeliard_dec_map_pos(&p, 100);
    ok &= expect_u16("dec_map_pos:in_bounds:x", p.map_x, 49);
    ok &= expect_u8("dec_map_pos:in_bounds:screen", p.screen_x, 4);

    p.map_x = 0; p.screen_x = 5;
    zeliard_dec_map_pos(&p, 100);
    ok &= expect_u16("dec_map_pos:wrap:x", p.map_x, 99);
    ok &= expect_u8("dec_map_pos:wrap:screen", p.screen_x, 4);

    p.row = 10;
    zeliard_inc_row(&p);
    ok &= expect_u8("inc_row:simple", p.row, 11);
    p.row = 0x3F;
    zeliard_inc_row(&p);
    ok &= expect_u8("inc_row:wrap_3F", p.row, 0);
    p.row = 10;
    zeliard_dec_row(&p);
    ok &= expect_u8("dec_row:simple", p.row, 9);
    p.row = 0;
    zeliard_dec_row(&p);
    ok &= expect_u8("dec_row:wrap_0", p.row, 0x3F);

    static const struct {
        const char *name;
        zeliard_entity_move_dir_t dir;
        u16 x;
        u8 row;
        u8 screen;
    } move_cases[] = {
        {"entity_move:E", ZELIARD_MOVE_E, 51, 10, 11},
        {"entity_move:NE", ZELIARD_MOVE_NE, 51, 9, 11},
        {"entity_move:N", ZELIARD_MOVE_N, 50, 9, 10},
        {"entity_move:NW", ZELIARD_MOVE_NW, 49, 9, 9},
        {"entity_move:W", ZELIARD_MOVE_W, 49, 10, 9},
        {"entity_move:SW", ZELIARD_MOVE_SW, 49, 11, 9},
        {"entity_move:S", ZELIARD_MOVE_S, 50, 11, 10},
        {"entity_move:SE", ZELIARD_MOVE_SE, 51, 11, 11},
    };
    for (size_t i = 0; i < sizeof(move_cases) / sizeof(move_cases[0]); ++i) {
        p.map_x = 50;
        p.row = 10;
        p.screen_x = 10;
        bool moved = zeliard_entity_move_direction(&p, 100, move_cases[i].dir, false);
        char label[64];
        snprintf(label, sizeof(label), "%s:moved", move_cases[i].name);
        ok &= expect_bool(label, moved, true);
        snprintf(label, sizeof(label), "%s:x", move_cases[i].name);
        ok &= expect_u16(label, p.map_x, move_cases[i].x);
        snprintf(label, sizeof(label), "%s:row", move_cases[i].name);
        ok &= expect_u8(label, p.row, move_cases[i].row);
        snprintf(label, sizeof(label), "%s:screen", move_cases[i].name);
        ok &= expect_u8(label, p.screen_x, move_cases[i].screen);
    }

    p.map_x = 50; p.row = 10; p.screen_x = 0x22;
    ok &= expect_bool("entity_move:E_bound:moved",
                      zeliard_entity_move_direction(&p, 100, ZELIARD_MOVE_E, false),
                      false);
    ok &= expect_u16("entity_move:E_bound:x", p.map_x, 50);
    ok &= expect_u8("entity_move:E_bound:screen", p.screen_x, 0x22);

    p.map_x = 50; p.row = 10; p.screen_x = 1;
    ok &= expect_bool("entity_move:W_bound:moved",
                      zeliard_entity_move_direction(&p, 100, ZELIARD_MOVE_W, false),
                      false);
    ok &= expect_u16("entity_move:W_bound:x", p.map_x, 50);
    ok &= expect_u8("entity_move:W_bound:screen", p.screen_x, 1);

    p.map_x = 50; p.row = 10; p.screen_x = 0;
    ok &= expect_bool("entity_move:N_x0:moved",
                      zeliard_entity_move_direction(&p, 100, ZELIARD_MOVE_N, false),
                      false);
    ok &= expect_u8("entity_move:N_x0:row", p.row, 10);

    p.map_x = 50; p.row = 10; p.screen_x = 0x23;
    ok &= expect_bool("entity_move:S_x23:moved",
                      zeliard_entity_move_direction(&p, 100, ZELIARD_MOVE_S, false),
                      false);
    ok &= expect_u8("entity_move:S_x23:row", p.row, 10);

    p.map_x = 50; p.row = 10; p.screen_x = 10;
    ok &= expect_bool("entity_move:E_collision:moved",
                      zeliard_entity_move_direction(&p, 100, ZELIARD_MOVE_E, true),
                      false);
    ok &= expect_u16("entity_move:E_collision:x", p.map_x, 50);
    ok &= expect_u8("entity_move:E_collision:screen", p.screen_x, 10);
    return ok;
}

static void setup_enemy_buf(u8 *buf, size_t count, const u8 *first_bytes, size_t first_count) {
    for (size_t i = 0; i < count; ++i) {
        buf[i] = 0xEE;
    }
    for (size_t i = 0; i < first_count; ++i) {
        buf[i * 0x0D] = first_bytes[i];
    }
    buf[first_count * 0x0D] = 0xFF;
}

static int run_enemy_tick_cases(void) {
    int ok = 1;
    u8 buf[0x0D * 6] = {0};

    const u8 dec_active[] = {10, 5, 20};
    setup_enemy_buf(buf, sizeof(buf), dec_active, 3);
    zeliard_tick_decrement_enemy_counters(buf);
    ok &= expect_u8("tick_dec:3_active:0", buf[0 * 0x0D], 9);
    ok &= expect_u8("tick_dec:3_active:1", buf[1 * 0x0D], 4);
    ok &= expect_u8("tick_dec:3_active:2", buf[2 * 0x0D], 19);

    const u8 dec_zeros[] = {0, 5, 0, 7};
    setup_enemy_buf(buf, sizeof(buf), dec_zeros, 4);
    zeliard_tick_decrement_enemy_counters(buf);
    ok &= expect_u8("tick_dec:zeros_skipped:0", buf[0 * 0x0D], 0);
    ok &= expect_u8("tick_dec:zeros_skipped:1", buf[1 * 0x0D], 4);
    ok &= expect_u8("tick_dec:zeros_skipped:2", buf[2 * 0x0D], 0);
    ok &= expect_u8("tick_dec:zeros_skipped:3", buf[3 * 0x0D], 6);

    setup_enemy_buf(buf, sizeof(buf), NULL, 0);
    zeliard_tick_decrement_enemy_counters(buf);
    ok &= expect_u8("tick_dec:empty", buf[0], 0xFF);

    const u8 inc_active[] = {10, 5, 20};
    setup_enemy_buf(buf, sizeof(buf), inc_active, 3);
    zeliard_tick_increment_enemy_counters(buf);
    ok &= expect_u8("tick_inc:3_active:0", buf[0 * 0x0D], 11);
    ok &= expect_u8("tick_inc:3_active:1", buf[1 * 0x0D], 6);
    ok &= expect_u8("tick_inc:3_active:2", buf[2 * 0x0D], 21);

    const u8 inc_zeros[] = {0, 5, 0};
    setup_enemy_buf(buf, sizeof(buf), inc_zeros, 3);
    zeliard_tick_increment_enemy_counters(buf);
    ok &= expect_u8("tick_inc:zeros_skipped:0", buf[0 * 0x0D], 0);
    ok &= expect_u8("tick_inc:zeros_skipped:1", buf[1 * 0x0D], 6);
    ok &= expect_u8("tick_inc:zeros_skipped:2", buf[2 * 0x0D], 0);
    return ok;
}

static int run_town_text_cases(void) {
    static const u8 glyph_widths[96] = {
        0, 3, 1, 0, 5, 4, 4, 4, 6, 8, 5, 3, 4, 4, 6, 6,
        6, 5, 6, 8, 7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 3, 4,
        6, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 7, 8, 8, 8, 8, 8, 7, 5,
        3, 5, 6, 7, 7, 8, 8, 7, 8, 7, 7, 8, 8, 5, 6, 8,
        5, 8, 7, 7, 8, 8, 8, 7, 6, 8, 8, 8, 7, 7, 7, 4
    };
    int ok = 1;
    size_t consumed = 0;

    const u8 abc_space[] = {'A', 'B', 'C', ' ', 'r', 'e', 's', 't', 0x80};
    ok &= expect_u16("town_measure_word_width:abc_space:width",
                     zeliard_town_measure_word_width(
                         abc_space, sizeof(abc_space), glyph_widths, &consumed),
                     19);
    ok &= expect_u16("town_measure_word_width:abc_space:consumed",
                     (u16)consumed, 4);

    const u8 hi_slash[] = {'H', 'i', '/', 't', 'h', 'e', 'r', 'e', 0x80};
    ok &= expect_u16("town_measure_word_width:hi_slash:width",
                     zeliard_town_measure_word_width(
                         hi_slash, sizeof(hi_slash), glyph_widths, &consumed),
                     15);
    ok &= expect_u16("town_measure_word_width:hi_slash:consumed",
                     (u16)consumed, 3);

    const u8 control_then_a[] = {0x1F, 'A', ' ', 0x80};
    ok &= expect_u16("town_measure_word_width:control_then_a:width",
                     zeliard_town_measure_word_width(
                         control_then_a, sizeof(control_then_a),
                         glyph_widths, &consumed),
                     6);
    ok &= expect_u16("town_measure_word_width:control_then_a:consumed",
                     (u16)consumed, 3);

    const u8 highbit_immediate[] = {0x80, 'A'};
    ok &= expect_u16("town_measure_word_width:highbit_immediate:width",
                     zeliard_town_measure_word_width(
                         highbit_immediate, sizeof(highbit_immediate),
                         glyph_widths, &consumed),
                     0);
    ok &= expect_u16("town_measure_word_width:highbit_immediate:consumed",
                     (u16)consumed, 1);

    const u8 single_line[] = {'A', 'B', 'C', 0x80};
    ok &= expect_u16("town_count_wrapped_lines:single_line",
                     zeliard_town_count_wrapped_lines(
                         single_line, sizeof(single_line), glyph_widths),
                     1);

    const u8 slash_break[] = {'A', 'B', 'C', '/', 'D', 'E', 0x80};
    ok &= expect_u16("town_count_wrapped_lines:slash_break",
                     zeliard_town_count_wrapped_lines(
                         slash_break, sizeof(slash_break), glyph_widths),
                     2);

    u8 space_no_wrap[29];
    memset(space_no_wrap, 'A', 26);
    space_no_wrap[26] = ' ';
    space_no_wrap[27] = 'B';
    space_no_wrap[28] = 0x80;
    ok &= expect_u16("town_count_wrapped_lines:space_no_wrap",
                     zeliard_town_count_wrapped_lines(
                         space_no_wrap, sizeof(space_no_wrap), glyph_widths),
                     1);

    u8 space_wrap[30];
    memset(space_wrap, 'A', 27);
    space_wrap[27] = ' ';
    space_wrap[28] = 'B';
    space_wrap[29] = 0x80;
    ok &= expect_u16("town_count_wrapped_lines:space_wrap_equal_168",
                     zeliard_town_count_wrapped_lines(
                         space_wrap, sizeof(space_wrap), glyph_widths),
                     2);

    const u8 empty_highbit[] = {0x80};
    ok &= expect_u16("town_count_wrapped_lines:empty_highbit",
                     zeliard_town_count_wrapped_lines(
                         empty_highbit, sizeof(empty_highbit), glyph_widths),
                     0);

    ok &= expect_u16("town_dialog_cursor_pos:row0",
                     zeliard_town_dialog_cursor_pos(0x343B, 0), 0x353B);
    ok &= expect_u16("town_dialog_cursor_pos:row1",
                     zeliard_town_dialog_cursor_pos(0x343B, 1), 0x3545);
    ok &= expect_u16("town_dialog_cursor_pos:row5",
                     zeliard_town_dialog_cursor_pos(0x2000, 5), 0x2132);
    ok &= expect_u16("town_dialog_cursor_pos:word_wrap",
                     zeliard_town_dialog_cursor_pos(0xFF00, 3), 0x001E);

    u16 cursor_positions[10];
    zeliard_town_cursor_anim_positions(0x343B, 1, false, cursor_positions);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_cursor_anim:left_row1:%u", i);
        ok &= expect_u16(label, cursor_positions[i], (u16)(0x3544u - i));
    }

    zeliard_town_cursor_anim_positions(0x343B, 1, true, cursor_positions);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_cursor_anim:right_row1:%u", i);
        ok &= expect_u16(label, cursor_positions[i], (u16)(0x3546u + i));
    }

    u8 xlat[64];
    for (u8 i = 0; i < 64; ++i) {
        xlat[i] = (u8)(0x80u + i);
    }

    u8 sel_row = 2;
    zeliard_town_selection_scroll_result_t scroll =
        zeliard_town_selection_scroll_plan(
            &sel_row, 0, 0x2000, 5, 7, xlat, false);
    ok &= expect_u8("town_selection_scroll:up:sel_row", sel_row, 1);
    ok &= expect_u8("town_selection_scroll:up:result_sel_row", scroll.sel_row, 1);
    ok &= expect_u8("town_selection_scroll:up:init_al", scroll.init_al, 0x81);
    ok &= expect_u16("town_selection_scroll:up:bx", scroll.bx, 0x2301);
    ok &= expect_u16("town_selection_scroll:up:cx", scroll.cx, 0x0730);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_selection_scroll:up:al%u", i);
        ok &= expect_u8(label, scroll.al_sequence[i], (u8)(9u - i));
    }

    sel_row = 1;
    scroll = zeliard_town_selection_scroll_plan(
        &sel_row, 4, 0x2000, 5, 7, xlat, true);
    ok &= expect_u8("town_selection_scroll:down:sel_row", sel_row, 2);
    ok &= expect_u8("town_selection_scroll:down:result_sel_row", scroll.sel_row, 2);
    ok &= expect_u8("town_selection_scroll:down:init_al", scroll.init_al, 0x86);
    ok &= expect_u16("town_selection_scroll:down:bx", scroll.bx, 0x2301);
    ok &= expect_u16("town_selection_scroll:down:cx", scroll.cx, 0x0730);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_selection_scroll:down:al%u", i);
        ok &= expect_u8(label, scroll.al_sequence[i], i);
    }

    zeliard_town_menu_decision_t decision =
        zeliard_town_menu_input_decision(1, 2, 3, 5, 8);
    ok &= expect_u8("town_menu_decision:up_visible:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_CURSOR_LEFT);
    ok &= expect_u8("town_menu_decision:up_visible:visible", decision.visible_row, 1);
    ok &= expect_u8("town_menu_decision:up_visible:sel", decision.sel_row, 3);

    decision = zeliard_town_menu_input_decision(1, 0, 0, 5, 8);
    ok &= expect_u8("town_menu_decision:up_top_no_scroll:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_decision:up_top_no_scroll:visible",
                    decision.visible_row, 0);
    ok &= expect_u8("town_menu_decision:up_top_no_scroll:sel", decision.sel_row, 0);

    decision = zeliard_town_menu_input_decision(1, 0, 2, 5, 8);
    ok &= expect_u8("town_menu_decision:up_top_scroll:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_SCROLL_UP);
    ok &= expect_u8("town_menu_decision:up_top_scroll:visible",
                    decision.visible_row, 0);
    ok &= expect_u8("town_menu_decision:up_top_scroll:sel", decision.sel_row, 1);

    decision = zeliard_town_menu_input_decision(2, 2, 1, 5, 8);
    ok &= expect_u8("town_menu_decision:down_visible:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_CURSOR_RIGHT);
    ok &= expect_u8("town_menu_decision:down_visible:visible",
                    decision.visible_row, 3);
    ok &= expect_u8("town_menu_decision:down_visible:sel", decision.sel_row, 1);

    decision = zeliard_town_menu_input_decision(2, 4, 3, 5, 8);
    ok &= expect_u8("town_menu_decision:down_bottom_no_scroll:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_decision:down_bottom_no_scroll:visible",
                    decision.visible_row, 4);
    ok &= expect_u8("town_menu_decision:down_bottom_no_scroll:sel",
                    decision.sel_row, 3);

    decision = zeliard_town_menu_input_decision(2, 4, 2, 5, 8);
    ok &= expect_u8("town_menu_decision:down_bottom_scroll:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_SCROLL_DOWN);
    ok &= expect_u8("town_menu_decision:down_bottom_scroll:visible",
                    decision.visible_row, 4);
    ok &= expect_u8("town_menu_decision:down_bottom_scroll:sel",
                    decision.sel_row, 3);

    decision = zeliard_town_menu_input_decision(0, 2, 1, 5, 8);
    ok &= expect_u8("town_menu_decision:neutral:action",
                    (u8)decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_decision:neutral:visible", decision.visible_row, 2);
    ok &= expect_u8("town_menu_decision:neutral:sel", decision.sel_row, 1);

    zeliard_town_menu_pre_joy_result_t pre_joy =
        zeliard_town_menu_pre_joy_result(1, 0, 0x55);
    ok &= expect_u8("town_menu_pre_joy:skip:action",
                    (u8)pre_joy.action, ZELIARD_TOWN_MENU_PRE_JOY_SKIP);
    ok &= expect_bool("town_menu_pre_joy:skip:terminal", pre_joy.terminal, true);
    ok &= expect_bool("town_menu_pre_joy:skip:carry", pre_joy.carry, true);
    ok &= expect_u8("town_menu_pre_joy:skip:volume", pre_joy.volume, 0x55);

    pre_joy = zeliard_town_menu_pre_joy_result(0, 1, 0x55);
    ok &= expect_u8("town_menu_pre_joy:spacebar:action",
                    (u8)pre_joy.action, ZELIARD_TOWN_MENU_PRE_JOY_ACCEPT);
    ok &= expect_bool("town_menu_pre_joy:spacebar:terminal", pre_joy.terminal, true);
    ok &= expect_bool("town_menu_pre_joy:spacebar:carry", pre_joy.carry, false);
    ok &= expect_u8("town_menu_pre_joy:spacebar:volume", pre_joy.volume, 0x1F);

    zeliard_town_menu_entry_result_t entry =
        zeliard_town_menu_entry_after_tick(3, 1, 0, 0x55);
    ok &= expect_u8("town_menu_entry:skip:draw_row", entry.draw_row, 3);
    ok &= expect_u8("town_menu_entry:skip:tick_row", entry.tick_row, 3);
    ok &= expect_u8("town_menu_entry:skip:skip_flag", entry.skip_flag2, 1);
    ok &= expect_u8("town_menu_entry:skip:spacebar", entry.spacebar_state, 0);
    ok &= expect_u8("town_menu_entry:skip:frame_timer", entry.frame_timer, 0);
    ok &= expect_u8("town_menu_entry:skip:action",
                    (u8)entry.pre_joy.action, ZELIARD_TOWN_MENU_PRE_JOY_SKIP);
    ok &= expect_bool("town_menu_entry:skip:carry", entry.pre_joy.carry, true);
    ok &= expect_u8("town_menu_entry:skip:volume", entry.pre_joy.volume, 0x55);

    entry = zeliard_town_menu_entry_after_tick(3, 0, 1, 0x55);
    ok &= expect_u8("town_menu_entry:spacebar:draw_row", entry.draw_row, 3);
    ok &= expect_u8("town_menu_entry:spacebar:tick_row", entry.tick_row, 3);
    ok &= expect_u8("town_menu_entry:spacebar:skip_flag", entry.skip_flag2, 0);
    ok &= expect_u8("town_menu_entry:spacebar:spacebar", entry.spacebar_state, 1);
    ok &= expect_u8("town_menu_entry:spacebar:frame_timer", entry.frame_timer, 0);
    ok &= expect_u8("town_menu_entry:spacebar:action",
                    (u8)entry.pre_joy.action, ZELIARD_TOWN_MENU_PRE_JOY_ACCEPT);
    ok &= expect_bool("town_menu_entry:spacebar:carry", entry.pre_joy.carry, false);
    ok &= expect_u8("town_menu_entry:spacebar:volume", entry.pre_joy.volume, 0x1F);

    zeliard_town_menu_entry_joystick_result_t joy =
        zeliard_town_menu_entry_joystick_result(1, 2, 3, 5, 8, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_joy:up_visible:draw_row",
                    joy.entry.draw_row, 2);
    ok &= expect_u8("town_menu_entry_joy:up_visible:frame_timer",
                    joy.entry.frame_timer, 0);
    ok &= expect_u8("town_menu_entry_joy:up_visible:action",
                    (u8)joy.decision.action, ZELIARD_TOWN_MENU_CURSOR_LEFT);
    ok &= expect_u8("town_menu_entry_joy:up_visible:visible",
                    joy.decision.visible_row, 1);
    ok &= expect_u8("town_menu_entry_joy:up_visible:sel",
                    joy.decision.sel_row, 3);

    joy = zeliard_town_menu_entry_joystick_result(1, 0, 0, 5, 8, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_joy:up_top_no_scroll:draw_row",
                    joy.entry.draw_row, 0);
    ok &= expect_u8("town_menu_entry_joy:up_top_no_scroll:action",
                    (u8)joy.decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_entry_joy:up_top_no_scroll:visible",
                    joy.decision.visible_row, 0);
    ok &= expect_u8("town_menu_entry_joy:up_top_no_scroll:sel",
                    joy.decision.sel_row, 0);

    joy = zeliard_town_menu_entry_joystick_result(2, 2, 1, 5, 8, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_joy:down_visible:draw_row",
                    joy.entry.draw_row, 2);
    ok &= expect_u8("town_menu_entry_joy:down_visible:action",
                    (u8)joy.decision.action, ZELIARD_TOWN_MENU_CURSOR_RIGHT);
    ok &= expect_u8("town_menu_entry_joy:down_visible:visible",
                    joy.decision.visible_row, 3);
    ok &= expect_u8("town_menu_entry_joy:down_visible:sel",
                    joy.decision.sel_row, 1);

    joy = zeliard_town_menu_entry_joystick_result(2, 4, 3, 5, 8, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_joy:down_bottom_no_scroll:draw_row",
                    joy.entry.draw_row, 4);
    ok &= expect_u8("town_menu_entry_joy:down_bottom_no_scroll:action",
                    (u8)joy.decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_entry_joy:down_bottom_no_scroll:visible",
                    joy.decision.visible_row, 4);
    ok &= expect_u8("town_menu_entry_joy:down_bottom_no_scroll:sel",
                    joy.decision.sel_row, 3);

    joy = zeliard_town_menu_entry_joystick_result(0, 2, 1, 5, 8, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_joy:neutral:draw_row",
                    joy.entry.draw_row, 2);
    ok &= expect_u8("town_menu_entry_joy:neutral:action",
                    (u8)joy.decision.action, ZELIARD_TOWN_MENU_NONE);
    ok &= expect_u8("town_menu_entry_joy:neutral:visible",
                    joy.decision.visible_row, 2);
    ok &= expect_u8("town_menu_entry_joy:neutral:sel",
                    joy.decision.sel_row, 1);

    u8 selection_xlat[0x40];
    for (u8 i = 0; i < sizeof(selection_xlat); ++i) {
        selection_xlat[i] = (u8)(0x80u + i);
    }

    zeliard_town_menu_entry_scroll_result_t entry_scroll =
        zeliard_town_menu_entry_scroll_result(
            1, 0, 2, 5, 8, 0x2000, 7, selection_xlat, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_scroll:up:draw_row",
                    entry_scroll.joystick.entry.draw_row, 0);
    ok &= expect_bool("town_menu_entry_scroll:up:did_scroll",
                      entry_scroll.did_scroll, true);
    ok &= expect_u8("town_menu_entry_scroll:up:action",
                    (u8)entry_scroll.joystick.decision.action,
                    ZELIARD_TOWN_MENU_SCROLL_UP);
    ok &= expect_u8("town_menu_entry_scroll:up:visible",
                    entry_scroll.joystick.decision.visible_row, 0);
    ok &= expect_u8("town_menu_entry_scroll:up:sel",
                    entry_scroll.joystick.decision.sel_row, 1);
    ok &= expect_u8("town_menu_entry_scroll:up:scroll_sel",
                    entry_scroll.scroll.sel_row, 1);
    ok &= expect_u8("town_menu_entry_scroll:up:init_al",
                    entry_scroll.scroll.init_al, 0x81);
    ok &= expect_u16("town_menu_entry_scroll:up:bx",
                     entry_scroll.scroll.bx, 0x2301);
    ok &= expect_u16("town_menu_entry_scroll:up:cx",
                     entry_scroll.scroll.cx, 0x0730);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_menu_entry_scroll:up:al%d", i);
        ok &= expect_u8(label, entry_scroll.scroll.al_sequence[i], (u8)(9u - i));
    }

    entry_scroll = zeliard_town_menu_entry_scroll_result(
        2, 4, 2, 5, 8, 0x2000, 7, selection_xlat, 0, 0, 0x55);
    ok &= expect_u8("town_menu_entry_scroll:down:draw_row",
                    entry_scroll.joystick.entry.draw_row, 4);
    ok &= expect_bool("town_menu_entry_scroll:down:did_scroll",
                      entry_scroll.did_scroll, true);
    ok &= expect_u8("town_menu_entry_scroll:down:action",
                    (u8)entry_scroll.joystick.decision.action,
                    ZELIARD_TOWN_MENU_SCROLL_DOWN);
    ok &= expect_u8("town_menu_entry_scroll:down:visible",
                    entry_scroll.joystick.decision.visible_row, 4);
    ok &= expect_u8("town_menu_entry_scroll:down:sel",
                    entry_scroll.joystick.decision.sel_row, 3);
    ok &= expect_u8("town_menu_entry_scroll:down:scroll_sel",
                    entry_scroll.scroll.sel_row, 3);
    ok &= expect_u8("town_menu_entry_scroll:down:init_al",
                    entry_scroll.scroll.init_al, 0x87);
    ok &= expect_u16("town_menu_entry_scroll:down:bx",
                     entry_scroll.scroll.bx, 0x2301);
    ok &= expect_u16("town_menu_entry_scroll:down:cx",
                     entry_scroll.scroll.cx, 0x0730);
    for (u8 i = 0; i < 10; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "town_menu_entry_scroll:down:al%d", i);
        ok &= expect_u8(label, entry_scroll.scroll.al_sequence[i], i);
    }

    zeliard_town_prompt_yes_no_result_t prompt =
        zeliard_town_prompt_yes_no_result(5, 8, 3, true);
    ok &= expect_u8("town_prompt_yes_no:yes:temp_cols",
                    prompt.temp_dialog_cols, 2);
    ok &= expect_u8("town_prompt_yes_no:yes:temp_rows",
                    prompt.temp_dialog_rows, 2);
    ok &= expect_u16("town_prompt_yes_no:yes:clear_rows",
                     prompt.clear_rows, 2);
    ok &= expect_u16("town_prompt_yes_no:yes:clear_text",
                     prompt.clear_text_ptr, 0x7513);
    ok &= expect_u8("town_prompt_yes_no:yes:poll_visible",
                    prompt.poll_visible_row, 0);
    ok &= expect_u8("town_prompt_yes_no:yes:restore_cols",
                    prompt.restored_dialog_cols, 5);
    ok &= expect_u8("town_prompt_yes_no:yes:restore_rows",
                    prompt.restored_dialog_rows, 8);
    ok &= expect_u8("town_prompt_yes_no:yes:restore_sel",
                    prompt.restored_sel_row, 3);
    ok &= expect_bool("town_prompt_yes_no:yes:accepted",
                      prompt.accepted, true);
    ok &= expect_bool("town_prompt_yes_no:yes:carry",
                      prompt.carry, true);

    prompt = zeliard_town_prompt_yes_no_result(5, 8, 3, false);
    ok &= expect_u8("town_prompt_yes_no:no:temp_cols",
                    prompt.temp_dialog_cols, 2);
    ok &= expect_u8("town_prompt_yes_no:no:temp_rows",
                    prompt.temp_dialog_rows, 2);
    ok &= expect_u16("town_prompt_yes_no:no:clear_rows",
                     prompt.clear_rows, 2);
    ok &= expect_u16("town_prompt_yes_no:no:clear_text",
                     prompt.clear_text_ptr, 0x7513);
    ok &= expect_u8("town_prompt_yes_no:no:poll_visible",
                    prompt.poll_visible_row, 0);
    ok &= expect_u8("town_prompt_yes_no:no:restore_cols",
                    prompt.restored_dialog_cols, 5);
    ok &= expect_u8("town_prompt_yes_no:no:restore_rows",
                    prompt.restored_dialog_rows, 8);
    ok &= expect_u8("town_prompt_yes_no:no:restore_sel",
                    prompt.restored_sel_row, 3);
    ok &= expect_bool("town_prompt_yes_no:no:accepted",
                      prompt.accepted, false);
    ok &= expect_bool("town_prompt_yes_no:no:carry",
                      prompt.carry, false);

    zeliard_town_clear_dialog_rows_plan_t clear_rows =
        zeliard_town_clear_dialog_rows_plan(0x2000, 3, 0xAA55);
    ok &= expect_u8("town_clear_dialog_rows:three:count",
                    clear_rows.call_count, 3);
    const u16 expected_three_bx[3] = {0x2301, 0x230B, 0x2315};
    for (u8 i = 0; i < 3; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_clear_dialog_rows:three:%u:row", i);
        ok &= expect_u8(label, clear_rows.calls[i].row, i);
        snprintf(label, sizeof(label), "town_clear_dialog_rows:three:%u:ax", i);
        ok &= expect_u16(label, clear_rows.calls[i].ax, expected_three_bx[i]);
        snprintf(label, sizeof(label), "town_clear_dialog_rows:three:%u:bx", i);
        ok &= expect_u16(label, clear_rows.calls[i].bx, expected_three_bx[i]);
        snprintf(label, sizeof(label), "town_clear_dialog_rows:three:%u:cx", i);
        ok &= expect_u16(label, clear_rows.calls[i].cx, 0);
        snprintf(label, sizeof(label), "town_clear_dialog_rows:three:%u:dx", i);
        ok &= expect_u16(label, clear_rows.calls[i].dx, (u16)(0xAA00 | i));
    }
    ok &= expect_u16("town_clear_dialog_rows:three:final_cx",
                     clear_rows.final_cx, 0);
    ok &= expect_u16("town_clear_dialog_rows:three:final_dx",
                     clear_rows.final_dx, 0xAA03);

    clear_rows = zeliard_town_clear_dialog_rows_plan(0x3450, 1, 0x1200);
    ok &= expect_u8("town_clear_dialog_rows:one:count",
                    clear_rows.call_count, 1);
    ok &= expect_u16("town_clear_dialog_rows:one:ax",
                     clear_rows.calls[0].ax, 0x3751);
    ok &= expect_u16("town_clear_dialog_rows:one:bx",
                     clear_rows.calls[0].bx, 0x3751);
    ok &= expect_u16("town_clear_dialog_rows:one:cx",
                     clear_rows.calls[0].cx, 0);
    ok &= expect_u16("town_clear_dialog_rows:one:dx",
                     clear_rows.calls[0].dx, 0x1200);
    ok &= expect_u16("town_clear_dialog_rows:one:final_dx",
                     clear_rows.final_dx, 0x1201);

    zeliard_town_shop_selection_anim_plan_t shop_anim =
        zeliard_town_shop_selection_anim_plan(2, 3, 0x2000, selection_xlat);
    ok &= expect_u8("town_shop_selection_anim:three:count",
                    shop_anim.call_count, 3);
    const u16 expected_shop_bx[3] = {0x2300, 0x230A, 0x2314};
    const u8 expected_shop_init[3] = {0x82, 0x83, 0x84};
    for (u8 i = 0; i < 3; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_shop_selection_anim:three:%u:init_al", i);
        ok &= expect_u8(label, shop_anim.calls[i].init_al, expected_shop_init[i]);
        snprintf(label, sizeof(label), "town_shop_selection_anim:three:%u:draw_bx", i);
        ok &= expect_u16(label, shop_anim.calls[i].draw_bx, expected_shop_bx[i]);
        snprintf(label, sizeof(label), "town_shop_selection_anim:three:%u:draw_cx", i);
        ok &= expect_u16(label, shop_anim.calls[i].draw_cx, (u16)(3 - i));
    }
    ok &= expect_u16("town_shop_selection_anim:three:final_ax",
                     shop_anim.final_ax, 0x0305);
    ok &= expect_u16("town_shop_selection_anim:three:final_cx",
                     shop_anim.final_cx, 0);

    u8 selection_xlat_90[64];
    for (u8 i = 0; i < 64; ++i) {
        selection_xlat_90[i] = (u8)(0x90 + i);
    }
    shop_anim = zeliard_town_shop_selection_anim_plan(5, 1, 0x3450,
                                                       selection_xlat_90);
    ok &= expect_u8("town_shop_selection_anim:one:count",
                    shop_anim.call_count, 1);
    ok &= expect_u8("town_shop_selection_anim:one:init_al",
                    shop_anim.calls[0].init_al, 0x95);
    ok &= expect_u16("town_shop_selection_anim:one:draw_bx",
                     shop_anim.calls[0].draw_bx, 0x3750);
    ok &= expect_u16("town_shop_selection_anim:one:draw_cx",
                     shop_anim.calls[0].draw_cx, 1);
    ok &= expect_u16("town_shop_selection_anim:one:final_ax",
                     shop_anim.final_ax, 0x0106);

    zeliard_town_shop_selection_anim_plan_t menu_items =
        zeliard_town_menu_items_column_plan(2, 3, 0x2000);
    ok &= expect_u8("town_menu_items_column:three:count",
                    menu_items.call_count, 3);
    for (u8 i = 0; i < menu_items.call_count; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_menu_items_column:three:%u:init_al", i);
        ok &= expect_u8(label, menu_items.calls[i].init_al, (u8)(2 + i));
        snprintf(label, sizeof(label), "town_menu_items_column:three:%u:draw_bx", i);
        ok &= expect_u16(label, menu_items.calls[i].draw_bx,
                         (u16)(0x2300 + (i * 10)));
        snprintf(label, sizeof(label), "town_menu_items_column:three:%u:draw_cx", i);
        ok &= expect_u16(label, menu_items.calls[i].draw_cx, (u16)(3 - i));
    }
    ok &= expect_u16("town_menu_items_column:three:final_ax",
                     menu_items.final_ax, 0x0305);
    ok &= expect_u16("town_menu_items_column:three:final_cx",
                     menu_items.final_cx, 0);

    menu_items = zeliard_town_menu_items_column_plan(5, 1, 0x3450);
    ok &= expect_u8("town_menu_items_column:one:count",
                    menu_items.call_count, 1);
    ok &= expect_u8("town_menu_items_column:one:init_al",
                    menu_items.calls[0].init_al, 5);
    ok &= expect_u16("town_menu_items_column:one:draw_bx",
                     menu_items.calls[0].draw_bx, 0x3750);
    ok &= expect_u16("town_menu_items_column:one:draw_cx",
                     menu_items.calls[0].draw_cx, 1);
    ok &= expect_u16("town_menu_items_column:one:final_ax",
                     menu_items.final_ax, 0x0106);

    const u8 restart_name[8] = {'R', 'e', '-', 'S', 't', 'a', 'r', 't'};
    const u8 plain_name[8] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
    zeliard_town_save_name_new_check_t new_check =
        zeliard_town_check_save_name_is_new(restart_name, 4);
    ok &= expect_u8("town_save_name_new:hyphen:flag",
                    new_check.save_new_flag, 0xFF);
    ok &= expect_u8("town_save_name_new:hyphen:len",
                    new_check.save_name_len, 0);
    new_check = zeliard_town_check_save_name_is_new(plain_name, 4);
    ok &= expect_u8("town_save_name_new:plain:flag",
                    new_check.save_new_flag, 0);
    ok &= expect_u8("town_save_name_new:plain:len",
                    new_check.save_name_len, 4);

    zeliard_town_save_name_clear_result_t clear_name =
        zeliard_town_clear_save_name_if_new(0, 5, plain_name);
    ok &= expect_u8("town_save_name_clear:inactive:flag",
                    clear_name.save_new_flag, 0);
    ok &= expect_u8("town_save_name_clear:inactive:maxlen",
                    clear_name.save_name_maxlen, 5);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_name_clear:inactive:%u", i);
        ok &= expect_u8(label, clear_name.save_name_buf[i], plain_name[i]);
    }

    clear_name = zeliard_town_clear_save_name_if_new(0xFF, 5, plain_name);
    ok &= expect_u8("town_save_name_clear:active:flag",
                    clear_name.save_new_flag, 0);
    ok &= expect_u8("town_save_name_clear:active:maxlen",
                    clear_name.save_name_maxlen, 0);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_name_clear:active:%u", i);
        ok &= expect_u8(label, clear_name.save_name_buf[i], '`');
    }

    zeliard_town_save_name_cursor_update_t cursor_update =
        zeliard_town_save_name_cursor_update(0x0060, 0x56, 2, 5, 1);
    ok &= expect_u16("town_save_cursor:update_forward:fill_bx",
                     cursor_update.fill_bx, 0x1C5E);
    ok &= expect_u16("town_save_cursor:update_forward:fill_cx",
                     cursor_update.fill_cx, 0x0208);
    ok &= expect_u8("town_save_cursor:update_forward:len",
                    cursor_update.final_save_name_len, 3);
    ok &= expect_u16("town_save_cursor:update_forward:draw_bx",
                     cursor_update.draw_bx, 0x0078);
    ok &= expect_u16("town_save_cursor:update_forward:draw_cx",
                     cursor_update.draw_cx, 0x025E);
    ok &= expect_u16("town_save_cursor:update_forward:draw_ax",
                     cursor_update.draw_ax, 0x067F);

    cursor_update = zeliard_town_save_name_cursor_update(0x0060, 0x56, 0, 5, 0xFF);
    ok &= expect_u8("town_save_cursor:update_underflow:len",
                    cursor_update.final_save_name_len, 0);
    ok &= expect_u16("town_save_cursor:update_underflow:draw_bx",
                     cursor_update.draw_bx, 0x0060);

    cursor_update = zeliard_town_save_name_cursor_update(0x0060, 0x56, 5, 5, 2);
    ok &= expect_u8("town_save_cursor:update_max_clamp:len",
                    cursor_update.final_save_name_len, 5);
    ok &= expect_u16("town_save_cursor:update_max_clamp:draw_bx",
                     cursor_update.draw_bx, 0x0088);

    zeliard_town_save_name_redraw_t redraw =
        zeliard_town_save_name_redraw(0x0060, 0x56);
    ok &= expect_u16("town_save_cursor:redraw:fill_bx",
                     redraw.fill_bx, 0x1856);
    ok &= expect_u16("town_save_cursor:redraw:fill_cx",
                     redraw.fill_cx, 0x1008);
    ok &= expect_u16("town_save_cursor:redraw:fill_ax",
                     redraw.fill_ax, 0);
    ok &= expect_u16("town_save_cursor:redraw:draw_bx",
                     redraw.draw_bx, 0x0060);
    ok &= expect_u16("town_save_cursor:redraw:draw_cx",
                     redraw.draw_cx, 0x1056);
    ok &= expect_u16("town_save_cursor:redraw:draw_si",
                     redraw.draw_si, 0x7C67);

    const u8 save_backspace_name[8] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', '`'};
    zeliard_town_save_name_backspace_result_t backspace =
        zeliard_town_save_name_backspace(0, 3, 5, save_backspace_name, 0x0060, 0x56);
    const u8 backspace_normal_expected[8] =
        {'A', 'B', 'D', 'E', 'F', 'G', '`', '`'};
    ok &= expect_u8("town_save_backspace:normal:len",
                    backspace.save_name_len, 2);
    ok &= expect_u8("town_save_backspace:normal:maxlen",
                    backspace.save_name_maxlen, 4);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_backspace:normal:%u", i);
        ok &= expect_u8(label, backspace.save_name_buf[i],
                        backspace_normal_expected[i]);
    }
    ok &= expect_u16("town_save_backspace:normal:cursor_clear_bx",
                     backspace.cursor_update.fill_bx, 0x1E5E);
    ok &= expect_u16("town_save_backspace:normal:cursor_draw_bx",
                     backspace.cursor_update.draw_bx, 0x0070);
    ok &= expect_u16("town_save_backspace:normal:redraw_bx",
                     backspace.redraw.fill_bx, 0x1856);

    backspace =
        zeliard_town_save_name_backspace(0, 0, 5, save_backspace_name, 0x0060, 0x56);
    const u8 backspace_empty_expected[8] =
        {'B', 'C', 'D', 'E', 'F', 'G', '`', '`'};
    ok &= expect_u8("town_save_backspace:empty:len",
                    backspace.save_name_len, 0);
    ok &= expect_u8("town_save_backspace:empty:maxlen",
                    backspace.save_name_maxlen, 4);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_backspace:empty:%u", i);
        ok &= expect_u8(label, backspace.save_name_buf[i],
                        backspace_empty_expected[i]);
    }
    ok &= expect_u16("town_save_backspace:empty:cursor_clear_bx",
                     backspace.cursor_update.fill_bx, 0x185E);
    ok &= expect_u16("town_save_backspace:empty:cursor_draw_bx",
                     backspace.cursor_update.draw_bx, 0x0060);

    const u8 append_blank_name[8] = {'A', 'B', '`', 'D', 'E', 'F', 'G', '`'};
    zeliard_town_save_name_append_result_t append =
        zeliard_town_save_name_append_char(0, 2, 2, append_blank_name,
                                           0x0060, 0x56, 'C');
    const u8 append_blank_expected[8] =
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', '`'};
    ok &= expect_u8("town_save_append:blank:len",
                    append.save_name_len, 3);
    ok &= expect_u8("town_save_append:blank:maxlen",
                    append.save_name_maxlen, 3);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_append:blank:%u", i);
        ok &= expect_u8(label, append.save_name_buf[i],
                        append_blank_expected[i]);
    }
    ok &= expect_u16("town_save_append:blank:cursor_clear_bx",
                     append.cursor_update.fill_bx, 0x1C5E);
    ok &= expect_u16("town_save_append:blank:cursor_draw_bx",
                     append.cursor_update.draw_bx, 0x0078);

    append = zeliard_town_save_name_append_char(0, 2, 5, save_backspace_name,
                                                0x0060, 0x56, 'Z');
    const u8 append_overwrite_expected[8] =
        {'A', 'B', 'Z', 'D', 'E', 'F', 'G', '`'};
    ok &= expect_u8("town_save_append:overwrite:len",
                    append.save_name_len, 3);
    ok &= expect_u8("town_save_append:overwrite:maxlen",
                    append.save_name_maxlen, 5);
    for (u8 i = 0; i < 8; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "town_save_append:overwrite:%u", i);
        ok &= expect_u8(label, append.save_name_buf[i],
                        append_overwrite_expected[i]);
    }

    return ok;
}

static zeliard_fight_tables_t fixture_fight_tables(void) {
    zeliard_fight_tables_t tables = {0};
    tables.enemy_id_table[0] = 0x10;
    tables.enemy_id_table[1] = 0x21;
    tables.enemy_id_table[2] = 0x31;
    tables.enemy_id_table[3] = 0x41;
    tables.move_slot_a[0] = 0x40;
    tables.move_slot_a[1] = 0x41;
    tables.move_slot_a[2] = 0x42;
    tables.move_slot_a[3] = 0x43;
    tables.move_slot_b[0] = 0x20;
    tables.move_slot_b[1] = 0x21;
    tables.move_slot_b[2] = 0x22;
    tables.move_slot_b[3] = 0x23;
    tables.move_slot_c[0] = 0x30;
    tables.move_slot_c[1] = 0x31;
    tables.move_slot_c[2] = 0x32;
    tables.move_slot_c[3] = 0x33;
    return tables;
}

static int run_classifier_cases(void) {
    int ok = 1;
    zeliard_fight_tables_t tables = fixture_fight_tables();

    ok &= expect_bool("gate_spell_fx:inactive", zeliard_gate_spell_fx_active(0), false);
    ok &= expect_bool("gate_spell_fx:active", zeliard_gate_spell_fx_active(1), true);

    ok &= expect_bool("entity_known:low_hit", zeliard_is_entity_known_type(&tables, 0x21), true);
    ok &= expect_bool("entity_known:low_miss", zeliard_is_entity_known_type(&tables, 0x05), false);
    ok &= expect_bool("entity_known:mid", zeliard_is_entity_known_type(&tables, 0x60), true);
    ok &= expect_bool("entity_known:high", zeliard_is_entity_known_type(&tables, 0x90), false);
    ok &= expect_bool("entity_lax:low_hit", zeliard_is_entity_id_lax(&tables, 0x21), true);
    ok &= expect_bool("entity_lax:low_miss", zeliard_is_entity_id_lax(&tables, 0x05), false);
    ok &= expect_bool("entity_lax:mid", zeliard_is_entity_id_lax(&tables, 0x60), true);
    ok &= expect_bool("entity_lax:high", zeliard_is_entity_id_lax(&tables, 0x90), true);

    ok &= expect_bool("inA7_b:area7",
                      zeliard_is_non_area7_slot_b_entity(&tables, 7, 0x21), false);
    ok &= expect_bool("inA7_b:area3_slot_b",
                      zeliard_is_non_area7_slot_b_entity(&tables, 3, 0x21), true);
    ok &= expect_bool("inA7_b:area3_slot_a",
                      zeliard_is_non_area7_slot_b_entity(&tables, 3, 0x41), false);
    ok &= expect_bool("inA7_b:unknown",
                      zeliard_is_non_area7_slot_b_entity(&tables, 3, 0x99), false);

    ok &= expect_bool("unkA5_b:area5_slot_b",
                      zeliard_is_unknown_or_area5_slot_b(&tables, 5, 0x21), true);
    ok &= expect_bool("unkA5_b:area5_slot_a",
                      zeliard_is_unknown_or_area5_slot_b(&tables, 5, 0x41), false);
    ok &= expect_bool("unkA5_b:area3",
                      zeliard_is_unknown_or_area5_slot_b(&tables, 3, 0x21), false);
    ok &= expect_bool("unkA5_b:unknown",
                      zeliard_is_unknown_or_area5_slot_b(&tables, 5, 0x05), true);

    ok &= expect_bool("unkA5_c:area5_slot_c",
                      zeliard_is_unknown_or_area5_slot_c(&tables, 5, 0x31), true);
    ok &= expect_bool("unkA5_c:area5_slot_b",
                      zeliard_is_unknown_or_area5_slot_c(&tables, 5, 0x21), false);
    ok &= expect_bool("unkA5_c:area3",
                      zeliard_is_unknown_or_area5_slot_c(&tables, 3, 0x31), false);
    ok &= expect_bool("unkA5_c:unknown",
                      zeliard_is_unknown_or_area5_slot_c(&tables, 5, 0x05), true);
    return ok;
}

static int run_reset_combat_state_case(void) {
    int ok = 1;
    zeliard_combat_reset_state_t s = {
        .gvar_pose_idx = 0x55,
        .gvar_timer_ticks = 0x55,
        .color_sel = 0x55,
        .flag_shield = 0x55,
        .flag_riding = 0x55,
        .gvar_palette_flag = 0x55,
        .equip_byte = 0x55,
        .spell_fx_active = 0x55,
        .scroll_active = 0x55,
        .restore_pending = 0x55,
        .gvar_item_result = 0x55,
        .enemy_scroll_flag = 0x55,
        .combat_active = 0x55,
        .enemy_data_buf = 0x55,
        .enemy_data_buf2 = 0x55,
        .boss_entry_tbl = 0x1234,
    };

    zeliard_reset_combat_state(&s);
    ok &= expect_u8("reset:gvar_pose_idx", s.gvar_pose_idx, 0);
    ok &= expect_u8("reset:gvar_timer_ticks", s.gvar_timer_ticks, 0);
    ok &= expect_u8("reset:color_sel", s.color_sel, 0);
    ok &= expect_u8("reset:flag_shield", s.flag_shield, 0);
    ok &= expect_u8("reset:gvar_palette_flag", s.gvar_palette_flag, 0);
    ok &= expect_u8("reset:equip_byte", s.equip_byte, 0);
    ok &= expect_u8("reset:spell_fx_active", s.spell_fx_active, 0);
    ok &= expect_u8("reset:scroll_active", s.scroll_active, 0);
    ok &= expect_u8("reset:restore_pending", s.restore_pending, 0);
    ok &= expect_u8("reset:gvar_item_result", s.gvar_item_result, 0);
    ok &= expect_u8("reset:enemy_scroll_flag", s.enemy_scroll_flag, 0);
    ok &= expect_u8("reset:enemy_data_buf", s.enemy_data_buf, 0xFF);
    ok &= expect_u8("reset:enemy_data_buf2", s.enemy_data_buf2, 0xFF);
    ok &= expect_u16("reset:boss_entry_tbl", s.boss_entry_tbl, 0xFFFF);
    ok &= expect_u8("reset:flag_riding", s.flag_riding, 0xFF);
    ok &= expect_u8("reset:combat_active", s.combat_active, 0xFF);
    return ok;
}

static int run_scroll_helper_cases(void) {
    int ok = 1;
    u16 col = 0;
    u8 row = 0;
    zeliard_scroll_offset_b_result_t off;
    zeliard_match_dl_result_t match;

    zeliard_compute_scroll_pos(100, 10, 5, 200, &col, &row);
    ok &= expect_u16("scroll_pos:no_underflow:col", col, 84);
    ok &= expect_u8("scroll_pos:no_underflow:row", row, 6);

    zeliard_compute_scroll_pos(5, 20, 10, 200, &col, &row);
    ok &= expect_u16("scroll_pos:underflow_wrap:col", col, 189);
    ok &= expect_u8("scroll_pos:underflow_wrap:row", row, 11);

    off = zeliard_compute_scroll_offset_b(100, 200);
    ok &= expect_u16("scroll_offset_b:near:ax", off.ax, 0x0053);
    ok &= expect_u16("scroll_offset_b:near:bx", off.bx, 0x000D);
    off = zeliard_compute_scroll_offset_b(5, 200);
    ok &= expect_u16("scroll_offset_b:start_wrap:ax", off.ax, 0x0000);
    ok &= expect_u16("scroll_offset_b:start_wrap:bx", off.bx, 0x0001);
    off = zeliard_compute_scroll_offset_b(187, 200);
    ok &= expect_u16("scroll_offset_b:near_edge:ax", off.ax, 0x00AA);
    ok &= expect_u16("scroll_offset_b:near_edge:bx", off.bx, 0x000D);
    off = zeliard_compute_scroll_offset_b(195, 200);
    ok &= expect_u16("scroll_offset_b:far_end:ax", off.ax, 0x00A4);
    ok &= expect_u16("scroll_offset_b:far_end:bx", off.bx, 0x001B);
    off = zeliard_compute_scroll_offset_b(188, 200);
    ok &= expect_u16("scroll_offset_b:far_edge:ax", off.ax, 0x00A4);
    ok &= expect_u16("scroll_offset_b:far_edge:bx", off.bx, 0x0014);

    match = zeliard_match_dl_within_3(0x10, 0x10);
    ok &= expect_u8("match_dl:exact:dh", match.dh, 1);
    ok &= expect_u8("match_dl:exact:dl", match.dl, 0x10);
    ok &= expect_bool("match_dl:exact:zf", match.zero, true);
    match = zeliard_match_dl_within_3(0x11, 0x10);
    ok &= expect_u8("match_dl:plus1:dh", match.dh, 0);
    ok &= expect_u8("match_dl:plus1:dl", match.dl, 0x11);
    ok &= expect_bool("match_dl:plus1:zf", match.zero, true);
    match = zeliard_match_dl_within_3(0x12, 0x10);
    ok &= expect_u8("match_dl:plus2:dh", match.dh, 0xFF);
    ok &= expect_u8("match_dl:plus2:dl", match.dl, 0x12);
    ok &= expect_bool("match_dl:plus2:zf", match.zero, true);
    match = zeliard_match_dl_within_3(0x99, 0x10);
    ok &= expect_u8("match_dl:no_match:dh", match.dh, 0xFF);
    ok &= expect_u8("match_dl:no_match:dl", match.dl, 0x12);
    ok &= expect_bool("match_dl:no_match:zf", match.zero, false);

    ok &= expect_u16("world_inner_x:normal",
                     zeliard_convert_world_x_to_inner_screen_x(20, 10, 40), 0x0017);
    ok &= expect_u16("world_inner_x:left_wrap",
                     zeliard_convert_world_x_to_inner_screen_x(2, 5, 40), 0xFFFC);
    ok &= expect_u16("world_inner_x:boundary",
                     zeliard_convert_world_x_to_inner_screen_x(10, 10, 40), 0x0021);
    ok &= expect_u16("world_screen_x:normal",
                     zeliard_convert_world_x_to_screen_x(20, 10, 40), 0x0019);
    ok &= expect_u16("world_screen_x:left_wrap",
                     zeliard_convert_world_x_to_screen_x(2, 5, 40), 0xFFFE);
    ok &= expect_u16("world_screen_x:boundary",
                     zeliard_convert_world_x_to_screen_x(10, 10, 40), 0x0023);

    ok &= expect_u8("scroll_dispatch:00", zeliard_scroll_dispatch_table_offset(0x00), 0);
    ok &= expect_u8("scroll_dispatch:80", zeliard_scroll_dispatch_table_offset(0x80), 4);
    ok &= expect_u8("scroll_dispatch:C0", zeliard_scroll_dispatch_table_offset(0xC0), 6);

    ok &= expect_u16("scroll_buf_offset:0_0", zeliard_scroll_buf_offset(0, 0), 0xE000);
    ok &= expect_u16("scroll_buf_offset:1_0", zeliard_scroll_buf_offset(1, 0), 0xE024);
    ok &= expect_u16("scroll_buf_offset:3F_10", zeliard_scroll_buf_offset(0x3F, 0x10), 0xE8EC);
    ok &= expect_u16("scroll_buf_offset:40_0", zeliard_scroll_buf_offset(0x40, 0), 0xE000);

    ok &= expect_u16("scroll_wrap_high:below", zeliard_scroll_si_wrap_high(0xE8FF), 0xE8FF);
    ok &= expect_u16("scroll_wrap_high:at", zeliard_scroll_si_wrap_high(0xE900), 0xE000);
    ok &= expect_u16("scroll_wrap_high:above", zeliard_scroll_si_wrap_high(0xEA00), 0xE100);
    ok &= expect_u16("scroll_wrap_low:at", zeliard_scroll_si_wrap_low(0xE000), 0xE000);
    ok &= expect_u16("scroll_wrap_low:above", zeliard_scroll_si_wrap_low(0xE001), 0xE001);
    ok &= expect_u16("scroll_wrap_low:below", zeliard_scroll_si_wrap_low(0xDFFF), 0xE8FF);
    ok &= expect_u16("scroll_wrap_low:far_below", zeliard_scroll_si_wrap_low(0xDF00), 0xE800);

    ok &= expect_bool("area4_gate:area4_accessory4",
                      zeliard_gate_area4_no_accessory4(4, 4), false);
    ok &= expect_bool("area4_gate:area4_accessory3",
                      zeliard_gate_area4_no_accessory4(4, 3), true);
    ok &= expect_bool("area4_gate:area3_accessory4",
                      zeliard_gate_area4_no_accessory4(3, 4), false);

    ok &= expect_u16("scroll_si_from_player:basic",
                     zeliard_scroll_si_from_player(2, 0, 0xE000), 0xE04C);
    ok &= expect_u16("scroll_si_from_player:wrap_high",
                     zeliard_scroll_si_from_player(10, 0, 0xE800), 0xE06C);

    ok &= expect_u16("world_tile_entry_address:idx5",
                     zeliard_world_tile_entry_address(0x1234, 5), 0x123E);
    ok &= expect_u16("world_tile_entry_address:idx0",
                     zeliard_world_tile_entry_address(0xC017, 0), 0xC017);
    ok &= expect_u16("world_tile_entry_address:wrap",
                     zeliard_world_tile_entry_address(0xFFFE, 2), 0x0002);

    u8 object_list[0x800] = {0};
    object_list[3 * 0x10 + 4] = 0x77;
    object_list[2 * 0x10 + 4] = 0x00;
    zeliard_object_state_result_t r = zeliard_get_object_state_at_cell(0x40, object_list);
    ok &= expect_bool("object_state:bit7_clear:cf", r.carry, true);
    ok &= expect_bool("object_state:bit7_clear:zf", r.zero, true);
    r = zeliard_get_object_state_at_cell(0x83, object_list);
    ok &= expect_u8("object_state:slot3:value", r.value, 0x77);
    ok &= expect_bool("object_state:slot3:cf", r.carry, false);
    ok &= expect_bool("object_state:slot3:zf", r.zero, false);
    r = zeliard_get_object_state_at_cell(0x82, object_list);
    ok &= expect_u8("object_state:slot2:value", r.value, 0);
    ok &= expect_bool("object_state:slot2:zf", r.zero, true);

    u8 charges = 3;
    u8 slot4 = 0x00;
    u8 slot5 = 0xC0;
    bool placed = zeliard_try_place_tile_id_49(&charges, false, &slot4, &slot5);
    ok &= expect_bool("tile49:success:placed", placed, true);
    ok &= expect_u8("tile49:success:charges", charges, 2);
    ok &= expect_u8("tile49:success:slot5", slot5, 0xC9);

    charges = 0;
    slot4 = 0x00;
    slot5 = 0xC0;
    placed = zeliard_try_place_tile_id_49(&charges, false, &slot4, &slot5);
    ok &= expect_bool("tile49:no_charge:placed", placed, false);
    ok &= expect_u8("tile49:no_charge:charges", charges, 0);
    ok &= expect_u8("tile49:no_charge:slot5", slot5, 0xC0);

    charges = 3;
    slot4 = 0x00;
    slot5 = 0xC0;
    placed = zeliard_try_place_tile_id_49(&charges, true, &slot4, &slot5);
    ok &= expect_bool("tile49:object_carry:placed", placed, false);
    ok &= expect_u8("tile49:object_carry:charges", charges, 3);
    ok &= expect_u8("tile49:object_carry:slot5", slot5, 0xC0);

    charges = 3;
    slot4 = 0x20;
    slot5 = 0xC0;
    placed = zeliard_try_place_tile_id_49(&charges, false, &slot4, &slot5);
    ok &= expect_bool("tile49:slot4_bit5:placed", placed, false);
    ok &= expect_u8("tile49:slot4_bit5:charges", charges, 3);
    ok &= expect_u8("tile49:slot4_bit5:slot5", slot5, 0xC0);

    charges = 3;
    slot4 = 0x00;
    slot5 = 0xE0;
    placed = zeliard_try_place_tile_id_49(&charges, false, &slot4, &slot5);
    ok &= expect_bool("tile49:slot5_bit5:placed", placed, false);
    ok &= expect_u8("tile49:slot5_bit5:charges", charges, 3);
    ok &= expect_u8("tile49:slot5_bit5:slot5", slot5, 0xE0);
    return ok;
}

static int run_entity_slot_write_cases(void) {
    int ok = 1;
    u8 slot = 0x05;
    u8 ext[0x80] = {0};

    zeliard_entity_slot_write_tagged(&slot, ext, 0x42);
    ok &= expect_u8("slot_write:direct:slot", slot, 0x42);
    ok &= expect_u8("slot_write:direct:ext5", ext[5], 0);

    slot = 0x85;
    for (size_t i = 0; i < sizeof(ext); ++i) {
        ext[i] = 0;
    }
    zeliard_entity_slot_write_tagged(&slot, ext, 0x42);
    ok &= expect_u8("slot_write:indirect5:slot", slot, 0x85);
    ok &= expect_u8("slot_write:indirect5:ext5", ext[5], 0x42);

    slot = 0xFF;
    for (size_t i = 0; i < sizeof(ext); ++i) {
        ext[i] = 0;
    }
    zeliard_entity_slot_write_tagged(&slot, ext, 0x99);
    ok &= expect_u8("slot_write:indirect7F:slot", slot, 0xFF);
    ok &= expect_u8("slot_write:indirect7F:ext7F", ext[0x7F], 0x99);
    return ok;
}

static int run_sprite_blit_gate_cases(void) {
    int ok = 1;
    u16 coord = 0x1234;
    zeliard_prep_dirty_blit_result_t prep = zeliard_prep_dirty_blit(&coord, 0x42, 0x33);
    ok &= expect_bool("prep_dirty:clear:dirty", prep.dirty, false);
    ok &= expect_u16("prep_dirty:clear:coord", coord, 0x1234);

    coord = 0x9234;
    prep = zeliard_prep_dirty_blit(&coord, 0x42, 0x33);
    ok &= expect_bool("prep_dirty:set:dirty", prep.dirty, true);
    ok &= expect_u16("prep_dirty:set:coord", coord, 0x1234);
    ok &= expect_u16("prep_dirty:set:dx", prep.dx, 0x1234);
    ok &= expect_u8("prep_dirty:set:al", prep.al, 0x42);
    ok &= expect_u8("prep_dirty:set:ah", prep.ah, 0x33);

    zeliard_enemy_sprite_blit_result_t blit =
        zeliard_enemy_sprite_blit_gate(0xFC, 0x42, 0);
    ok &= expect_bool("enemy_blit:empty:calc", blit.calc_hud_called, true);
    ok &= expect_bool("enemy_blit:empty:scroll", blit.scroll_offset_called, false);
    ok &= expect_bool("enemy_blit:empty:skipped", blit.skipped, true);

    blit = zeliard_enemy_sprite_blit_gate(0x10, 0x42, 5);
    ok &= expect_bool("enemy_blit:occupied:calc", blit.calc_hud_called, true);
    ok &= expect_bool("enemy_blit:occupied:scroll", blit.scroll_offset_called, true);
    ok &= expect_bool("enemy_blit:occupied:skipped", blit.skipped, false);
    ok &= expect_u8("enemy_blit:occupied:al", blit.al, 0x47);

    coord = 0x2345;
    prep = zeliard_prep_boss_dirty_blit(&coord, 0x42, 0x33);
    ok &= expect_bool("prep_boss_dirty:clear:dirty", prep.dirty, false);
    ok &= expect_u16("prep_boss_dirty:clear:coord", coord, 0x2345);

    coord = 0xA345;
    prep = zeliard_prep_boss_dirty_blit(&coord, 0x42, 0x33);
    ok &= expect_bool("prep_boss_dirty:set:dirty", prep.dirty, true);
    ok &= expect_u16("prep_boss_dirty:set:coord", coord, 0x2345);
    ok &= expect_u16("prep_boss_dirty:set:dx", prep.dx, 0x2345);
    ok &= expect_u8("prep_boss_dirty:set:al", prep.al, 0x42);
    ok &= expect_u8("prep_boss_dirty:set:ah", prep.ah, 0x33);

    zeliard_entity_dispatch_b_result_t disp =
        zeliard_entity_fn_dispatch_b_prepare(0x05, 0xFF);
    ok &= expect_u8("entity_dispatch_b:A:offset", disp.table_offset, 0x0A);
    ok &= expect_u8("entity_dispatch_b:A:al", disp.al, 0x3F);
    disp = zeliard_entity_fn_dispatch_b_prepare(0x0B, 0x42);
    ok &= expect_u8("entity_dispatch_b:B:offset", disp.table_offset, 0x06);
    ok &= expect_u8("entity_dispatch_b:B:al", disp.al, 0x02);
    disp = zeliard_entity_fn_dispatch_b_prepare(0xF8, 0x34);
    ok &= expect_u8("entity_dispatch_b:C:offset", disp.table_offset, 0x00);
    ok &= expect_u8("entity_dispatch_b:C:al", disp.al, 0x34);

    zeliard_entity_step_dispatch_c_result_t step =
        zeliard_entity_step_dispatch_c_prepare(0x05, 0xFF, false);
    ok &= expect_bool("entity_step_dispatch_c:A:dispatched", step.dispatched, true);
    ok &= expect_bool("entity_step_dispatch_c:A:update", step.path_update_called, false);
    ok &= expect_u8("entity_step_dispatch_c:A:offset", step.table_offset, 0x0A);
    ok &= expect_u8("entity_step_dispatch_c:A:pos", step.pos_byte, 0x3F);

    step = zeliard_entity_step_dispatch_c_prepare(0x45, 0xFF, true);
    ok &= expect_bool("entity_step_dispatch_c:B:dispatched", step.dispatched, false);
    ok &= expect_bool("entity_step_dispatch_c:B:update", step.path_update_called, true);
    ok &= expect_u8("entity_step_dispatch_c:B:pos", step.pos_byte, 0xFF);

    step = zeliard_entity_step_dispatch_c_prepare(0x45, 0xFF, false);
    ok &= expect_bool("entity_step_dispatch_c:C:dispatched", step.dispatched, true);
    ok &= expect_bool("entity_step_dispatch_c:C:update", step.path_update_called, true);
    ok &= expect_u8("entity_step_dispatch_c:C:offset", step.table_offset, 0x0A);
    ok &= expect_u8("entity_step_dispatch_c:C:pos", step.pos_byte, 0x3F);
    return ok;
}

static int run_right_col_entity_scan_case(void) {
    int ok = 1;
    u8 escape_flag = 0xFF;
    u16 dispatch_si[3] = {0, 0, 0};
    u16 si_after = zeliard_tick_right_col_entities(&escape_flag, 2, 0,
                                                   0xE000, dispatch_si);

    ok &= expect_u8("right_col_scan:escape_flag", escape_flag, 0);
    ok &= expect_u16("right_col_scan:dispatch0", dispatch_si[0], 0xE095);
    ok &= expect_u16("right_col_scan:dispatch1", dispatch_si[1], 0xE071);
    ok &= expect_u16("right_col_scan:dispatch2", dispatch_si[2], 0xE04D);
    ok &= expect_u16("right_col_scan:si_after", si_after, 0xE029);
    return ok;
}

static int run_try_place_3cell_entity_row_cases(void) {
    int ok = 1;
    const u16 si_base = 0xE100;
    u8 scroll_buf[0x900] = {0};
    u8 entity_row = 0;
    zeliard_place_3cell_result_t r;

    scroll_buf[si_base - 0xE000 + 0x23] = 0x80;
    r = zeliard_try_place_3cell_entity_row(scroll_buf, si_base, &entity_row);
    ok &= expect_bool("place3:A:placed", r.placed, false);
    ok &= expect_u8("place3:A:write_calls", r.write_calls, 0);
    ok &= expect_u8("place3:A:row", entity_row, 0);

    for (size_t i = 0; i < sizeof(scroll_buf); ++i) {
        scroll_buf[i] = 0;
    }
    entity_row = 0;
    scroll_buf[si_base - 0xE000 + 0x24] = 0x42;
    r = zeliard_try_place_3cell_entity_row(scroll_buf, si_base, &entity_row);
    ok &= expect_bool("place3:B:placed", r.placed, false);
    ok &= expect_u8("place3:B:write_calls", r.write_calls, 0);
    ok &= expect_u8("place3:B:row", entity_row, 0);

    for (size_t i = 0; i < sizeof(scroll_buf); ++i) {
        scroll_buf[i] = 0;
    }
    entity_row = 0;
    r = zeliard_try_place_3cell_entity_row(scroll_buf, si_base, &entity_row);
    ok &= expect_bool("place3:C:placed", r.placed, true);
    ok &= expect_u8("place3:C:write_calls", r.write_calls, 6);
    ok &= expect_u16("place3:C:target0", r.write_targets[0], 0xE124);
    ok &= expect_u16("place3:C:target1", r.write_targets[1], 0xE100);
    ok &= expect_u16("place3:C:target2", r.write_targets[2], 0xE125);
    ok &= expect_u16("place3:C:target3", r.write_targets[3], 0xE101);
    ok &= expect_u16("place3:C:target4", r.write_targets[4], 0xE126);
    ok &= expect_u16("place3:C:target5", r.write_targets[5], 0xE102);
    ok &= expect_u8("place3:C:row", entity_row, 1);

    entity_row = 0x3F;
    r = zeliard_try_place_3cell_entity_row(scroll_buf, si_base, &entity_row);
    ok &= expect_bool("place3:C_wrap:placed", r.placed, true);
    ok &= expect_u8("place3:C_wrap:row", entity_row, 0);

    for (size_t i = 0; i < sizeof(scroll_buf); ++i) {
        scroll_buf[i] = 0;
    }
    entity_row = 0;
    scroll_buf[si_base - 0xE000 + 0x26] = 0xFF;
    r = zeliard_try_place_3cell_entity_row(scroll_buf, si_base, &entity_row);
    ok &= expect_bool("place3:D:placed", r.placed, false);
    ok &= expect_u8("place3:D:write_calls", r.write_calls, 0);
    ok &= expect_u8("place3:D:row", entity_row, 0);
    return ok;
}

int main(void) {
    int ok = 1;
    ok &= run_hp_cases();
    ok &= run_almas_cases();
    ok &= run_gold_bank_cases();
    ok &= run_town_state_cases();
    ok &= run_movement_cases();
    ok &= run_enemy_tick_cases();
    ok &= run_town_text_cases();
    ok &= run_classifier_cases();
    ok &= run_reset_combat_state_case();
    ok &= run_scroll_helper_cases();
    ok &= run_entity_slot_write_cases();
    ok &= run_sprite_blit_gate_cases();
    ok &= run_right_col_entity_scan_case();
    ok &= run_try_place_3cell_entity_row_cases();
    printf("VERDICT: %s: gameplay native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
