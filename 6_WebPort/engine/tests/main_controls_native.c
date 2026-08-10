#include "../core/types.h"
#include "../core/framebuf.h"
#include "../render/palette.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void zeliard_init(void);
void zeliard_tick(u32 dt_ms);
void zeliard_key(int keycode);
void zeliard_key_down(int keycode);
void zeliard_key_up(int keycode);
void zeliard_text_key(int ascii);
int zeliard_scene(void);
int zeliard_test_town_dialog_active(void);
int zeliard_test_fight_returns_to_town(int operation, int selector,
                                       int dispatch);
int zeliard_test_begin_malicia_death(void);
int zeliard_test_begin_malicia_combat(void);
int zeliard_test_begin_malicia_transition(void);
int zeliard_test_begin_malicia_exit(void);
int zeliard_test_restart_fight(int selector, int start_position,
                               int map_scroll_row, int screen_position);
int zeliard_test_game_set_u8(unsigned offset, unsigned value);
int zeliard_test_redraw_town(void);
int zeliard_fight_active(void);
int zeliard_fight_map_width(void);
int zeliard_cavern_transition_active(void);
int zeliard_cavern_transition_step(void);
int zeliard_inventory_active(void);
int zeliard_test_enter_room(int kind);
int zeliard_room_kind(void);
int zeliard_room_ip(void);
int zeliard_room_input_kind(void);
int zeliard_phase(void);
u32 zeliard_phase_elapsed(void);
u32 zeliard_audio_opl_write_count(void);
u32 zeliard_audio_cue_serial(void);
int zeliard_paused(void);
int zeliard_speed_menu_active(void);
int zeliard_restore_menu_active(void);
u32 zeliard_load_request_serial(void);
int zeliard_game_speed_digit(void);
int zeliard_music_track(void);
void zeliard_music_complete(int track);
int zeliard_music_attenuation(void);
int zeliard_music_enabled(void);
int zeliard_sound_enabled(void);
int zeliard_sound_cue(void);
int zeliard_test_game_u8(unsigned offset);
int zeliard_test_game_u16(unsigned offset);
int zeliard_test_fight_u8(unsigned offset);
void zeliard_opening_set_phase_for_test(int phase);
int zeliard_load_record(const u8 *record, int size);
int zeliard_town_area(void);

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static int write_frame_ppm(const char *path, const u8 *frame) {
    FILE *ppm = fopen(path, "wb");
    if (!ppm) return 0;
    fputs("P6\n320 200\n255\n", ppm);
    for (size_t i = 0; i < ZELIARD_FB_SIZE; ++i) {
        fputc(g_palette[frame[i]].r, ppm);
        fputc(g_palette[frame[i]].g, ppm);
        fputc(g_palette[frame[i]].b, ppm);
    }
    return fclose(ppm) == 0;
}

static int write_frame_raw(const char *path, const u8 *frame) {
    FILE *raw = fopen(path, "wb");
    if (!raw) return 0;
    const int wrote = fwrite(frame, 1, ZELIARD_FB_SIZE, raw) == ZELIARD_FB_SIZE;
    return fclose(raw) == 0 && wrote;
}

static unsigned long long side_frame_hash(const u8 *frame) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (int y = 0; y < 160; ++y) {
        for (int x = 0; x < ZELIARD_WIDTH; ++x) {
            /* Sage text windows legitimately extend left to x=32. Above the
             * HUD, the immutable stone frame is x=0..31 and x=272..319. */
            if (x >= 32 && x < 272) continue;
            hash ^= frame[y * ZELIARD_WIDTH + x];
            hash *= 0x100000001B3ULL;
        }
    }
    return hash;
}

static unsigned long long frame_rect_hash(int x, int y, int width, int height) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (int row = 0; row < height; ++row) {
        const u8 *pixels = &g_framebuf[(y + row) * ZELIARD_WIDTH + x];
        for (int column = 0; column < width; ++column) {
            hash ^= pixels[column];
            hash *= 0x100000001B3ULL;
        }
    }
    return hash;
}

int main(void) {
    int ok = 1;
    ok &= zeliard_test_fight_returns_to_town(0, 0, 0x6002);
    ok &= zeliard_test_fight_returns_to_town(0, 0, 0x601C);
    ok &= !zeliard_test_fight_returns_to_town(0, 0, 0x6000);
    ok &= zeliard_test_fight_returns_to_town(1, 0x81, 0);
    ok &= !zeliard_test_fight_returns_to_town(1, 0x80, 0);

    zeliard_init();
    zeliard_opening_set_phase_for_test(3);
    zeliard_tick(250);
    const int phase = zeliard_phase();
    const u32 before_pause = zeliard_phase_elapsed();
    u8 before_pause_frame[ZELIARD_FB_SIZE];
    memcpy(before_pause_frame, g_framebuf, sizeof(before_pause_frame));

    zeliard_key(27);
    ok &= zeliard_paused() == 1;
    ok &= zeliard_sound_cue() == 2;
    ok &= g_framebuf[30 * ZELIARD_WIDTH + 128] == 0xFF;
    ok &= g_framebuf[31 * ZELIARD_WIDTH + 191] == 0xFF;
    ok &= g_framebuf[33 * ZELIARD_WIDTH + 130] == 0;
    int pause_glyph_pixels = 0;
    for (int y = 34; y < 42; y++)
        for (int x = 140; x < 180; x++)
            pause_glyph_pixels += g_framebuf[y * ZELIARD_WIDTH + x] == 0x77;
    ok &= pause_glyph_pixels > 0;
    zeliard_tick(1000);
    ok &= zeliard_phase() == phase;
    ok &= zeliard_phase_elapsed() == before_pause;

    zeliard_key(13);
    ok &= zeliard_paused() == 1;
    zeliard_key(32);
    ok &= zeliard_paused() == 0;
    ok &= zeliard_phase() == phase;
    ok &= zeliard_phase_elapsed() == before_pause;
    ok &= memcmp(before_pause_frame, g_framebuf, sizeof(before_pause_frame)) == 0;
    zeliard_tick(100);
    ok &= zeliard_phase_elapsed() > before_pause;
    printf("main_controls:escape_space_pause: %s\n", ok ? "PASS" : "FAIL");

    zeliard_opening_set_phase_for_test(2);
    ok &= zeliard_music_track() == 2;
    memset(g_framebuf, 0x55, ZELIARD_FB_SIZE);
    zeliard_key(32);
    ok &= zeliard_music_track() == 2;
    ok &= zeliard_phase() == 2;
    ok &= g_framebuf[0 * ZELIARD_WIDTH + 10] == 0;
    ok &= g_framebuf[1 * ZELIARD_WIDTH + 10] == 0x55;
    zeliard_tick(100);
    ok &= zeliard_phase() == 2;
    ok &= zeliard_music_attenuation() > 0;
    ok &= g_framebuf[1 * ZELIARD_WIDTH + 10] == 0;
    ok &= g_framebuf[2 * ZELIARD_WIDTH + 10] == 0x55;
    zeliard_tick(4200);
    ok &= zeliard_phase() == 3;
    ok &= zeliard_music_track() == 0;
    ok &= zeliard_music_attenuation() == 64;
    printf("main_controls:credits_skip_mscadlib_fade: %s\n",
           ok ? "PASS" : "FAIL");

    zeliard_key(112);
    ok &= zeliard_music_enabled() == 0;
    ok &= zeliard_sound_cue() == 1;
    zeliard_key(112);
    ok &= zeliard_music_enabled() == 1;
    ok &= zeliard_sound_cue() == 1;
    printf("main_controls:f1_music: %s\n", ok ? "PASS" : "FAIL");

    zeliard_key(113);
    ok &= zeliard_sound_enabled() == 0;
    ok &= zeliard_sound_cue() == 0;
    zeliard_key(113);
    ok &= zeliard_sound_enabled() == 1;
    ok &= zeliard_sound_cue() == 1;
    printf("main_controls:f2_sound: %s\n", ok ? "PASS" : "FAIL");

    zeliard_opening_set_phase_for_test(3);
    zeliard_tick(66000);
    const int princess_cue = zeliard_sound_cue();
    ok &= princess_cue == 0x41;
    printf("main_controls:princess_text_cue_41: %s cue=%02X\n",
           princess_cue == 0x41 ? "PASS" : "FAIL", princess_cue);

    zeliard_init();
    zeliard_opening_set_phase_for_test(3);
    zeliard_key(13);
    zeliard_tick(0);
    ok &= zeliard_scene() == 2;
    ok &= zeliard_music_track() == 3;
    const u32 castle_writes = zeliard_audio_opl_write_count();
    zeliard_tick(250);
    ok &= zeliard_audio_opl_write_count() > castle_writes;
    zeliard_key(112);
    ok &= zeliard_music_enabled() == 0 && zeliard_music_track() == 3;
    zeliard_key(112);
    ok &= zeliard_music_enabled() == 1 && zeliard_music_track() == 3;
    zeliard_key(27);
    ok &= zeliard_paused() == 1 && zeliard_music_track() == 3;
    int game_pause_pixels = 0;
    for (int y = 30; y < 46; ++y)
        for (int x = 128; x < 192; ++x)
            game_pause_pixels += g_framebuf[y * ZELIARD_WIDTH + x] == 0x09;
    ok &= game_pause_pixels == 446;
    zeliard_key(32);
    ok &= zeliard_paused() == 0 && zeliard_music_track() == 3;
    u8 before_speed_menu[ZELIARD_FB_SIZE];
    memcpy(before_speed_menu, g_framebuf, sizeof(before_speed_menu));
    zeliard_key(120);
    const int speed_menu_opened = zeliard_paused() &&
        zeliard_speed_menu_active() && zeliard_game_speed_digit() == 5 &&
        zeliard_sound_cue() == 2 &&
        g_framebuf[70 * ZELIARD_WIDTH + 104] == 0x09 &&
        g_framebuf[72 * ZELIARD_WIDTH + 106] == 0;
    zeliard_text_key('9');
    const int speed_selected = zeliard_speed_menu_active() &&
        zeliard_game_speed_digit() == 9 &&
        zeliard_test_game_u8(0xFF33) == 1 && zeliard_sound_cue() == 1;
    /* Restore the suite's canonical default cadence before later movement
     * fixtures; selecting again while the prompt is open is legal. */
    zeliard_text_key('5');
    zeliard_key(32);
    const int speed_menu_closed = !zeliard_paused() &&
        !zeliard_speed_menu_active() &&
        memcmp(before_speed_menu, g_framebuf, sizeof(before_speed_menu)) == 0;
    zeliard_key(120);
    zeliard_key(27);
    const int speed_escape_selected = zeliard_paused() &&
        zeliard_speed_menu_active() && zeliard_game_speed_digit() == 5;
    zeliard_key(27);
    const int speed_escape_closed = !zeliard_paused() &&
        !zeliard_speed_menu_active();
    ok &= speed_menu_opened && speed_selected && speed_menu_closed &&
        speed_escape_selected && speed_escape_closed;
    printf("main_controls:f9_speed_menu: %s opened=%d selected=%d "
           "closed=%d digit=%d internal=%d\n",
           speed_menu_opened && speed_selected && speed_menu_closed &&
               speed_escape_selected && speed_escape_closed ?
               "PASS" : "FAIL",
           speed_menu_opened, speed_selected, speed_menu_closed,
           speed_selected ? 9 : zeliard_game_speed_digit(),
           speed_selected ? 1 : zeliard_test_game_u8(0xFF33));
    u8 before_restore_menu[ZELIARD_FB_SIZE];
    memcpy(before_restore_menu, g_framebuf, sizeof(before_restore_menu));
    const u32 load_serial_before = zeliard_load_request_serial();
    zeliard_key(118);
    const int restore_opened = zeliard_paused() &&
        zeliard_restore_menu_active() && zeliard_sound_cue() == 2 &&
        g_framebuf[70 * ZELIARD_WIDTH + 104] == 0x09;
    const int restore_music_before = zeliard_music_enabled();
    zeliard_key(27);
    zeliard_key(32);
    zeliard_key(112);
    zeliard_text_key('A');
    const int restore_ignored_other_keys = zeliard_paused() &&
        zeliard_restore_menu_active() &&
        zeliard_music_enabled() == restore_music_before;
    zeliard_text_key('N');
    const int restore_declined = !zeliard_paused() &&
        !zeliard_restore_menu_active() &&
        zeliard_load_request_serial() == load_serial_before &&
        memcmp(before_restore_menu, g_framebuf,
               sizeof(before_restore_menu)) == 0;
    zeliard_key(118);
    zeliard_text_key('Y');
    const int restore_confirmed = !zeliard_paused() &&
        !zeliard_restore_menu_active() &&
        zeliard_load_request_serial() == load_serial_before + 1 &&
        memcmp(before_restore_menu, g_framebuf,
               sizeof(before_restore_menu)) == 0;
    ok &= restore_opened && restore_ignored_other_keys && restore_declined &&
        restore_confirmed;
    printf("main_controls:f7_restore_menu: %s opened=%d exclusive=%d no=%d "
           "yes=%d serial=%u\n",
           restore_opened && restore_ignored_other_keys && restore_declined &&
               restore_confirmed ?
               "PASS" : "FAIL",
           restore_opened, restore_ignored_other_keys, restore_declined,
           restore_confirmed,
           (unsigned)zeliard_load_request_serial());
    zeliard_key_down(39);
    zeliard_tick(90);
    zeliard_key_up(39);
    zeliard_tick(90);
    zeliard_key_down(32);
    zeliard_tick(90);
    zeliard_key_up(32);
    zeliard_tick(90);
    const unsigned long long dialog_hash = fnv1a64(g_framebuf,
                                                    ZELIARD_FB_SIZE);
    const int dialog_cue = zeliard_sound_cue();
    const int dialog_active = zeliard_test_town_dialog_active();
    zeliard_key_down(13);
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    const int dialog_dismissed = !zeliard_test_town_dialog_active();
    printf("main_controls:first_castle_dialog: %s frame=%016llx cue=%02X "
           "music=%d active=%d dismissed=%d\n",
           dialog_cue == 0x1E && zeliard_music_track() == 3 &&
               dialog_active && dialog_dismissed ?
               "PASS" : "FAIL",
           dialog_hash, dialog_cue, zeliard_music_track(), dialog_active,
           dialog_dismissed);
    ok &= dialog_cue == 0x1E && zeliard_music_track() == 3 &&
          dialog_active && dialog_dismissed;

    const unsigned long long pre_inventory_hash = fnv1a64(
        g_framebuf, ZELIARD_FB_SIZE);
    zeliard_key_down(13);
    const int inventory_opened = zeliard_inventory_active();
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    const unsigned long long inventory_hash = fnv1a64(
        g_framebuf, ZELIARD_FB_SIZE);
    int inventory_bottom_black = 1;
    for (u16 x = 48; x < 272; ++x)
        inventory_bottom_black &= g_framebuf[157u * 320u + x] == 0;
    ok &= inventory_opened && zeliard_inventory_active() &&
        inventory_hash != 0xCBF29CE484222325ULL && inventory_bottom_black;
    zeliard_key_down(13);
    zeliard_tick(90);
    const int inventory_closed = !zeliard_inventory_active();
    const unsigned long long returned_town_hash = fnv1a64(
        g_framebuf, ZELIARD_FB_SIZE);
    zeliard_key_up(13);
    zeliard_tick(90);
    ok &= inventory_closed && returned_town_hash == pre_inventory_hash;
    printf("main_controls:inventory_enter_cycle: %s frame=%016llx "
           "returned=%016llx opened=%d closed=%d bottom_black=%d\n",
           inventory_opened && inventory_closed && inventory_bottom_black &&
               returned_town_hash == pre_inventory_hash ? "PASS" : "FAIL",
           inventory_hash, returned_town_hash, inventory_opened,
           inventory_closed, inventory_bottom_black);

    ok &= zeliard_test_enter_room(1) == 0;
    ok &= zeliard_music_track() == 3 && zeliard_room_kind() == 0;
    zeliard_tick(500);
    const int room_music_stopped =
        zeliard_room_kind() == 1 && zeliard_music_track() == 0;
    ok &= room_music_stopped;
    printf("main_controls:king_entry_music_stop: %s room=%d music=%d\n",
           room_music_stopped ? "PASS" : "FAIL", zeliard_room_kind(),
           zeliard_music_track());

    u8 record[0x100];
    memset(record, 0, sizeof(record));
    FILE *record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x02] = 0x40;       /* MP10 collected/opened object state */
    record[0x05] = 0xFF;       /* repeat king script */
    record[0x80] = 0x34;       /* position */
    record[0x85] = 0x01;       /* carried gold high byte */
    record[0x86] = 0x56;
    record[0x87] = 0x34;
    record[0x8D] = 7;          /* experience level */
    record[0x92] = 2;          /* sword */
    record[0x93] = 1;          /* shield */
    record[0x99] = 1;          /* Lion Head's Key */
    record[0xA0] = 4;          /* Tears of Esmesanti */
    record[0x9D] = 3;          /* selected spell */
    record[0xAB] = 24;         /* Espada charge */
    record[0xAD] = 8;          /* Fuego charge */
    record[0xBB] = 0xFF;       /* Espada learned */
    record[0xBD] = 0xFF;       /* Fuego learned */
    record[0xC4] = 0x81;       /* saved at Muralla's Sage */
    record[0xE5] = 0xE0;       /* first three sages spoken */
    const int gold_before_invalid = zeliard_test_game_u8(0x85);
    const int invalid_rejected = !zeliard_load_record(record, 0xFF) &&
        zeliard_test_game_u8(0x85) == gold_before_invalid;
    ok &= invalid_rejected;
    const int loaded = zeliard_load_record(record, sizeof(record));
    const int restored = loaded && zeliard_scene() == 2 &&
        zeliard_test_game_u8(0x02) == 0x40 &&
        zeliard_test_game_u8(0x05) == 0xFF &&
        zeliard_test_game_u8(0x80) == 0x34 &&
        zeliard_test_game_u8(0x85) == 0x01 &&
        zeliard_test_game_u8(0x86) == 0x56 &&
        zeliard_test_game_u8(0x87) == 0x34 &&
        zeliard_test_game_u8(0x8D) == 7 &&
        zeliard_test_game_u8(0x92) == 2 &&
        zeliard_test_game_u8(0x93) == 1 &&
        zeliard_test_game_u8(0x99) == 1 &&
        zeliard_test_game_u8(0xA0) == 4 &&
         zeliard_test_game_u8(0x9D) == 3 &&
         zeliard_test_game_u8(0xBD) == 0xFF &&
         zeliard_test_game_u8(0xC4) == 0x81 &&
         zeliard_town_area() == 1 &&
         zeliard_test_game_u8(0xE5) == 0xE0;
    const unsigned long long restored_frame = fnv1a64(
        g_framebuf, ZELIARD_FB_SIZE);
    const unsigned long long restored_shield =
        frame_rect_hash(250, 164, 16, 16);
    const unsigned long long restored_sword =
        frame_rect_hash(192, 171, 20, 18);
    const unsigned long long restored_spell =
        frame_rect_hash(222, 164, 16, 16);
    const unsigned long long restored_spell_charge =
        frame_rect_hash(220, 187, 16, 8);
    const unsigned long long muralla_clean_side_frame =
        side_frame_hash(g_framebuf);
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/muralla-before-cavern.ppm", g_framebuf);
    const int restored_muralla_frame =
        restored_frame == 0x69540C88F1D2C94CULL;
    const int restored_shield_icon =
        restored_shield == 0x18FDBA10EBC3FCC6ULL;
    const int restored_sword_icon =
        restored_sword == 0x077A65ACB967926DULL;
    const int restored_spell_hud =
        restored_spell == 0x27BE1BB89569FF7DULL &&
        restored_spell_charge == 0x3AE76BA0C22B9071ULL;
    ok &= restored_muralla_frame && restored_shield_icon &&
        restored_sword_icon && restored_spell_hud;
    ok &= restored;
    printf("main_controls:save_restore_bootstrap: %s invalid=%d level=%d "
           "spell=%d sages=%02x area=%d frame=%016llx sword=%016llx "
           "shield=%016llx magic=%016llx/%016llx "
           "cumulative=%d\n",
           restored && restored_muralla_frame && restored_shield_icon &&
               restored_sword_icon && restored_spell_hud ?
               "PASS" : "FAIL",
           invalid_rejected,
           zeliard_test_game_u8(0x8D), zeliard_test_game_u8(0x9D),
           zeliard_test_game_u8(0xE5), zeliard_town_area(), restored_frame,
           restored_sword, restored_shield, restored_spell,
           restored_spell_charge, ok);

    /* 201SELCT initializes its cursor from selected_spell. With Espada and
     * Fuego known, one Left from Fuego selects Espada. Closing must retain
     * DS:009Dh and redraw both the frame and ABh charge over the town HUD. */
    zeliard_key_down(13);
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    const int spell_inventory_opened = zeliard_inventory_active();
    zeliard_key_down(37);
    zeliard_tick(90);
    zeliard_key_up(37);
    zeliard_tick(90);
    const int spell_selected_in_inventory =
        zeliard_test_game_u8(0x9D) == 1;
    zeliard_key_down(13);
    zeliard_tick(90);
    const int spell_inventory_closed = !zeliard_inventory_active();
    zeliard_key_up(13);
    zeliard_tick(16);
    const unsigned long long selected_spell_frame =
        frame_rect_hash(222, 164, 16, 16);
    const unsigned long long selected_spell_charge =
        frame_rect_hash(220, 187, 16, 8);
    const int selected_spell_border =
        g_framebuf[186u * 320u + 222u] == 0x00 &&
        g_framebuf[190u * 320u + 218u] == 0x00 &&
        g_framebuf[195u * 320u + 222u] == 0x2D;
    const int town_spell_selection_retained = spell_inventory_opened &&
        spell_selected_in_inventory && spell_inventory_closed &&
        zeliard_test_game_u8(0x9D) == 1 &&
        selected_spell_frame == 0x4B78EDCB41024AE4ULL &&
        selected_spell_charge == 0x5269F8EB4520CFB1ULL &&
        selected_spell_border;
    ok &= town_spell_selection_retained;
    printf("main_controls:town_spell_inventory_return: %s "
           "opened=%d selected=%d closed=%d spell=%d "
           "frame=%016llx charge=%016llx border=%d\n",
           town_spell_selection_retained ? "PASS" : "FAIL",
           spell_inventory_opened, spell_selected_in_inventory,
           spell_inventory_closed, zeliard_test_game_u8(0x9D),
           selected_spell_frame, selected_spell_charge,
           selected_spell_border);
    /* Restore the suite's Fuego fixture for the following cavern tests. */
    ok &= zeliard_load_record(record, sizeof(record));

    ok &= zeliard_test_begin_malicia_transition();
    unsigned forward_ticks = 0;
    int forward_fade_peak = 0;
    int forward_music_continued = zeliard_cavern_transition_active() &&
        zeliard_music_track() == 3;
    while (zeliard_cavern_transition_active() && forward_ticks++ < 2000) {
        zeliard_tick(16);
        if (zeliard_music_attenuation() > forward_fade_peak)
            forward_fade_peak = zeliard_music_attenuation();
        if (zeliard_cavern_transition_active())
            forward_music_continued &= zeliard_music_track() == 3;
    }
    const int forward_music_preserved = forward_music_continued &&
        forward_fade_peak == 64 && !zeliard_cavern_transition_active() &&
        zeliard_music_track() == 3;
    ok &= forward_music_preserved;
    printf("main_controls:malicia_forward_transition_music: %s ticks=%u "
           "continued=%d fade=%d inherited=%d\n",
           forward_music_preserved ? "PASS" : "FAIL", forward_ticks,
           forward_music_continued, forward_fade_peak,
           zeliard_music_track());

    ok &= zeliard_test_begin_malicia_combat();
    const int lion_key_entered_cavern =
        zeliard_test_game_u8(0x99) == 1 &&
        zeliard_test_fight_u8(0x99) == 1 &&
        zeliard_test_game_u8(0xA0) == 4 &&
        zeliard_test_fight_u8(0xA0) == 4;
    ok &= lion_key_entered_cavern;
    printf("main_controls:progression_cavern_handoff: %s "
           "lion=%u/%u tears=%u/%u\n",
           lion_key_entered_cavern ? "PASS" : "FAIL",
           zeliard_test_game_u8(0x99), zeliard_test_fight_u8(0x99),
           zeliard_test_game_u8(0xA0), zeliard_test_fight_u8(0xA0));
    unsigned malicia_cue_counts[256] = {0};
    for (unsigned settle = 0; settle < 5; ++settle) {
        zeliard_tick(16);
        const u8 cue = (u8)zeliard_sound_cue();
        malicia_cue_counts[cue]++;
    }
    const unsigned long long cavern_before_inventory =
        fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    unsigned cavern_before_nonzero = 0;
    for (size_t pixel = 0; pixel < ZELIARD_FB_SIZE; ++pixel)
        cavern_before_nonzero += g_framebuf[pixel] != 0;
    /* Browser input can arrive between host presentations. Deliberately
     * stale the presentation buffer: cavern return must come from the
     * resident 200FIGHT VGA page, never this host-side copy. */
    memset(g_framebuf, 0, ZELIARD_FB_SIZE);
    zeliard_key_down(13);
    const int cavern_inventory_opened = zeliard_inventory_active();
    const int cavern_inventory_open_cue = zeliard_sound_cue();
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    zeliard_key_down(13);
    zeliard_tick(90);
    const int cavern_inventory_closed = !zeliard_inventory_active();
    const int cavern_inventory_close_cue = zeliard_sound_cue();
    const unsigned long long cavern_after_inventory =
        fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    unsigned cavern_after_nonzero = 0;
    for (size_t pixel = 0; pixel < ZELIARD_FB_SIZE; ++pixel)
        cavern_after_nonzero += g_framebuf[pixel] != 0;
    zeliard_key_up(13);
    zeliard_tick(16);
    const unsigned long long cavern_after_resume =
        fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    unsigned cavern_resume_nonzero = 0;
    for (size_t pixel = 0; pixel < ZELIARD_FB_SIZE; ++pixel)
        cavern_resume_nonzero += g_framebuf[pixel] != 0;
    const int cavern_inventory_restored = cavern_inventory_opened &&
        cavern_inventory_closed && zeliard_fight_active() &&
        cavern_inventory_open_cue == 0x0B &&
        cavern_inventory_close_cue == 0x0B &&
        cavern_before_nonzero > 1000 && cavern_after_nonzero > 1000 &&
        cavern_resume_nonzero > 1000;
    ok &= cavern_inventory_restored;
    printf("main_controls:malicia_inventory_return: %s "
           "before=%016llx close=%016llx resume=%016llx "
           "nonzero=%u/%u/%u cues=%02x/%02x active=%d\n",
           cavern_inventory_restored ? "PASS" : "FAIL",
           cavern_before_inventory, cavern_after_inventory,
           cavern_after_resume, cavern_before_nonzero,
           cavern_after_nonzero, cavern_resume_nonzero,
           cavern_inventory_open_cue, cavern_inventory_close_cue,
           zeliard_fight_active());

    /* Exercise the real cavern selector path, not a synthetic state write:
     * select and consume a Kenshiko Potion, then prove its player record and
     * FF4Bh result survive the handoff back into the suspended fight VM. */
    for (unsigned offset = 0xA1; offset <= 0xC1; ++offset)
        zeliard_test_game_set_u8(offset, 0);
    zeliard_test_game_set_u8(0xA6, 1);
    zeliard_test_game_set_u8(0x90, 10);
    zeliard_test_game_set_u8(0x91, 0);
    zeliard_test_game_set_u8(0xB2, 100);
    zeliard_test_game_set_u8(0xB3, 0);
    zeliard_tick(90);
    const unsigned long long cavern_low_hp_life =
        frame_rect_hash(84, 163, 100, 6);
    zeliard_key_down(13);
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    zeliard_key_down(39);
    zeliard_tick(16);
    zeliard_key_up(39);
    zeliard_tick(90);
    zeliard_key_down(32);
    zeliard_tick(16);
    const int potion_use_cue = zeliard_sound_cue();
    zeliard_key_up(32);
    zeliard_tick(90);
    const int potion_applied_during_inventory = zeliard_inventory_active() &&
        zeliard_test_game_u16(0x90) == 90 &&
        zeliard_test_game_u8(0xA6) == 0 &&
        zeliard_test_game_u8(0xFF4B) == 1 && potion_use_cue == 0x0E;
    zeliard_key_down(13);
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    const unsigned long long cavern_healed_life =
        frame_rect_hash(84, 163, 100, 6);
    const int potion_applied_after_inventory =
        !zeliard_inventory_active() && zeliard_fight_active() &&
        zeliard_test_game_u16(0x90) == 90 &&
        zeliard_test_fight_u8(0x90) == 90 &&
        zeliard_test_fight_u8(0x91) == 0 &&
        zeliard_test_fight_u8(0xA6) == 0 &&
        zeliard_test_fight_u8(0xFF4B) == 1 &&
        cavern_healed_life != cavern_low_hp_life;
    ok &= potion_applied_during_inventory && potion_applied_after_inventory;
    printf("main_controls:malicia_inventory_potion: %s during=%d "
           "hp=%04x/%02x item=%02x/%02x result=%02x/%02x "
           "life=%016llx>%016llx\n",
           potion_applied_during_inventory &&
               potion_applied_after_inventory ? "PASS" : "FAIL",
           potion_applied_during_inventory, zeliard_test_game_u16(0x90),
           zeliard_test_fight_u8(0x90), zeliard_test_game_u8(0xA6),
           zeliard_test_fight_u8(0xA6), zeliard_test_game_u8(0xFF4B),
           zeliard_test_fight_u8(0xFF4B), cavern_low_hp_life,
           cavern_healed_life);

    const u32 malicia_cue_serial_before = zeliard_audio_cue_serial();
    zeliard_key_down(32);
    int attack_started = 0;
    for (unsigned attack_tick = 0; attack_tick < 40; ++attack_tick) {
        zeliard_tick(16);
        const u8 cue = (u8)zeliard_sound_cue();
        malicia_cue_counts[cue]++;
        attack_started |= zeliard_test_game_u8(0xFF45) == 1 &&
            zeliard_test_game_u8(0xFF46) == 0;
    }
    zeliard_key_up(32);
    const u32 malicia_cue_serial_after = zeliard_audio_cue_serial();
    const int malicia_cue_edges =
        malicia_cue_counts[0x14] == 1 &&
        malicia_cue_counts[0x03] == 1 &&
        malicia_cue_counts[0x07] == 1;
    ok &= attack_started;
    ok &= malicia_cue_edges;
    printf("main_controls:malicia_space_attack: %s state=%02X/%02X "
           "facing=%02X sword=%02X cues=%u\n",
           attack_started ? "PASS" : "FAIL",
           zeliard_test_game_u8(0xFF45), zeliard_test_game_u8(0xFF46),
           zeliard_test_game_u8(0xC2), zeliard_test_game_u8(0x92),
           malicia_cue_serial_after - malicia_cue_serial_before);
    printf("main_controls:malicia_cue_edges: %s 14=%u 03=%u 07=%u "
           "inventory=%u/%u serial=%u silent=%u\n",
           malicia_cue_edges ? "PASS" : "FAIL",
           malicia_cue_counts[0x14], malicia_cue_counts[0x03],
           malicia_cue_counts[0x07], malicia_cue_counts[0x0C],
           malicia_cue_counts[0x0E],
           malicia_cue_serial_after - malicia_cue_serial_before,
           malicia_cue_counts[0]);

    /* 200FIGHT:check_state18 passively restores two HP after every sixteen
     * undisturbed cavern frames. Verify that real host time advances that
     * MASM process, updates shared state, and redraws the life bar. */
    zeliard_test_game_set_u8(0x90, 50);
    zeliard_test_game_set_u8(0x91, 0);
    zeliard_test_game_set_u8(0xB2, 100);
    zeliard_test_game_set_u8(0xB3, 0);
    const int regen_hp_before = zeliard_test_game_u16(0x90);
    const unsigned long long regen_life_before =
        frame_rect_hash(84, 163, 100, 6);
    for (unsigned regen_tick = 0; regen_tick < 20; ++regen_tick)
        zeliard_tick(90);
    const int regen_hp_after = zeliard_test_game_u16(0x90);
    const unsigned long long regen_life_after =
        frame_rect_hash(84, 163, 100, 6);
    const int passive_life_restoration = regen_hp_before == 50 &&
        regen_hp_after >= 52 && regen_life_after != regen_life_before;
    ok &= passive_life_restoration;
    printf("main_controls:malicia_passive_life_restoration: %s "
           "hp=%d>%d life=%016llx>%016llx\n",
           passive_life_restoration ? "PASS" : "FAIL",
           regen_hp_before, regen_hp_after, regen_life_before,
           regen_life_after);

    record[0xC4] = 0x81;
    ok &= zeliard_load_record(record, sizeof(record));
    const int death_saved_frame_scratch = zeliard_test_game_u8(0x9F);
    const int death_cavern_start = zeliard_test_game_u16(0x80);
    const int death_cavern_scroll = zeliard_test_game_u8(0x82);
    const int death_cavern_screen = zeliard_test_game_u8(0x83);
    ok &= zeliard_test_begin_malicia_death();
    unsigned death_ticks = 0;
    unsigned death_wipe_frames = 0;
    unsigned long long death_wipe_hash = 0;
    while (zeliard_fight_active() && death_ticks++ < 5000) {
        zeliard_tick(16);
        if (zeliard_test_game_u8(0xFF24) == 8) {
            const unsigned long long hash = fnv1a64(
                g_framebuf, ZELIARD_FB_SIZE);
            if (hash != death_wipe_hash) {
                death_wipe_hash = hash;
                death_wipe_frames++;
            }
        }
    }
    const int death_boundary_attenuation = zeliard_music_attenuation();
    const int death_black_boundary = !zeliard_fight_active() &&
        zeliard_room_kind() == 0 && death_boundary_attenuation > 0;
    unsigned sage_wait_ticks = 0;
    while (zeliard_room_kind() != 2 && sage_wait_ticks++ < 500)
        zeliard_tick(16);
    const int death_sage_entry_ip = zeliard_room_ip();
    const int death_sage_start = zeliard_test_game_u16(0x80);
    const int death_sage_scroll = zeliard_test_game_u8(0x82);
    const int death_sage_screen = zeliard_test_game_u8(0x83);
    const int death_sage_target = zeliard_test_game_u16(0xC013);
    const unsigned long long death_clean_side_frame =
        side_frame_hash(g_framebuf);
    palette_color_t death_clean_palette[256];
    memcpy(death_clean_palette, g_palette, sizeof(death_clean_palette));
    const int death_returned_to_sage = !zeliard_fight_active() &&
        zeliard_town_area() == 1 && zeliard_room_kind() == 2 &&
        death_sage_entry_ip == 0xA006 &&
        zeliard_test_game_u8(0x9F) == death_saved_frame_scratch &&
        zeliard_test_game_u8(0x99) == 1 &&
        zeliard_test_game_u8(0xA0) == 4 &&
        zeliard_test_game_u8(0xC4) == 0x81 &&
        zeliard_test_game_u8(0xC5) == 0x81 &&
        zeliard_test_game_u16(0x90) == zeliard_test_game_u16(0xB2);
    const int death_transition_presented = death_black_boundary &&
        death_wipe_frames >= 2;
    unsigned death_dialog_ticks = 0;
    while (zeliard_room_input_kind() == 0 &&
           death_dialog_ticks++ < 500)
        zeliard_tick(16);
    const int death_dialog_selected =
        zeliard_room_input_kind() == 2; /* text pager, not menu */
    const unsigned long long death_hud_hash =
        frame_rect_hash(0, 160, 320, 40);
    const int death_hud_clean =
        death_clean_side_frame == muralla_clean_side_frame &&
        side_frame_hash(g_framebuf) == muralla_clean_side_frame &&
        death_hud_hash == 0xAB8BC464C621F0FCULL &&
        memcmp(g_palette, death_clean_palette,
               sizeof(death_clean_palette)) == 0;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/malicia-death-sage.ppm", g_framebuf);
    ok &= death_transition_presented;
    ok &= death_returned_to_sage;
    ok &= death_dialog_selected;
    ok &= death_hud_clean;
    printf("main_controls:malicia_death_fade_wipe: %s frames=%u "
           "attenuation=%d sage_wait=%u\n",
           death_transition_presented ? "PASS" : "FAIL",
           death_wipe_frames, death_boundary_attenuation, sage_wait_ticks);
    printf("main_controls:malicia_death_sage_return: %s ticks=%u "
           "area=%d room=%d ip=%04X scratch=%02X/%02X "
           "sage=%02X/%02X hp=%04X/%04X\n",
           death_returned_to_sage ? "PASS" : "FAIL", death_ticks,
           zeliard_town_area(), zeliard_room_kind(), death_sage_entry_ip,
           zeliard_test_game_u8(0x9F), death_saved_frame_scratch,
           zeliard_test_game_u8(0xC4), zeliard_test_game_u8(0xC5),
           zeliard_test_game_u16(0x90), zeliard_test_game_u16(0xB2));
    printf("main_controls:malicia_death_sage_dialog: %s input=%d "
           "ticks=%u script=%04X\n",
           death_dialog_selected ? "PASS" : "FAIL",
           zeliard_room_input_kind(), death_dialog_ticks,
           zeliard_test_game_u16(0xFF4C));
    printf("main_controls:malicia_death_hud_clean: %s "
           "side=%016llx/%016llx/%016llx "
           "hud=%016llx palette=%d\n",
           death_hud_clean ? "PASS" : "FAIL",
           side_frame_hash(g_framebuf), death_clean_side_frame,
           muralla_clean_side_frame,
           death_hud_hash,
           memcmp(g_palette, death_clean_palette,
                  sizeof(death_clean_palette)) == 0);
    unsigned death_room_exit_ticks = 0;
    while (zeliard_room_kind() == 2 && death_room_exit_ticks++ < 3000) {
        if (zeliard_room_input_kind() == 2) {
            /* Match browser input: the exact room VM must sample the make
             * edge before the break clears stick.asm's physical-key mask. */
            zeliard_key_down(32);
            zeliard_tick(16);
            zeliard_key_up(32);
            zeliard_tick(16);
        } else {
            zeliard_tick(16);
        }
    }
    const int death_sage_exit_position = zeliard_room_kind() == 0 &&
        death_sage_start == 0x009B &&
        death_sage_scroll == 0x0E &&
        death_sage_screen == 0x0D &&
        death_sage_target == 0x00AC &&
        death_sage_start + death_sage_screen + 4 == death_sage_target &&
        zeliard_test_game_u16(0x80) == death_sage_start &&
        zeliard_test_game_u8(0x82) == death_sage_scroll &&
        zeliard_test_game_u8(0x83) == death_sage_screen &&
        (death_sage_start != death_cavern_start ||
         death_sage_scroll != death_cavern_scroll ||
         death_sage_screen != death_cavern_screen);
    const unsigned long long death_sage_exit_playfield =
        frame_rect_hash(48, 14, 224, 146);
    if (getenv("ZELIARD_DUMP")) {
        write_frame_ppm("build/malicia-death-sage-exit.ppm", g_framebuf);
        write_frame_raw("build/malicia-death-sage-exit.bin", g_framebuf);
    }
    const int death_sage_exit_clean = death_sage_exit_position &&
        death_sage_exit_playfield == 0x6D0F31CCF394BD6DULL;
    ok &= death_sage_exit_clean;
    printf("main_controls:malicia_death_sage_exit: %s ticks=%u input=%d "
           "script=%04X sage=%04X/%02X/%02X target=%04X frame=%016llx "
           "cavern=%04X/%02X/%02X\n",
           death_sage_exit_clean ? "PASS" : "FAIL",
           death_room_exit_ticks, zeliard_room_input_kind(),
           zeliard_test_game_u16(0xFF4C),
           death_sage_start, death_sage_scroll,
           death_sage_screen, death_sage_target,
           death_sage_exit_playfield,
           death_cavern_start, death_cavern_scroll,
           death_cavern_screen);

    record[0xC4] = 0x81;
    ok &= zeliard_load_record(record, sizeof(record));
    u8 reverse_reference_frame[ZELIARD_FB_SIZE];
    memcpy(reverse_reference_frame, g_framebuf,
           sizeof(reverse_reference_frame));
    const unsigned long long reverse_reference_life =
        frame_rect_hash(84, 163, 100, 6);
    const unsigned long long reverse_reference_sword =
        frame_rect_hash(192, 171, 20, 18);
    ok &= zeliard_test_begin_malicia_exit();
    /* Return with real cavern damage rather than the full-health town
     * snapshot captured above. */
    /* Authored item/stash records OR their consumed/opened masks into the
     * low STDPLY block.  Change it after the town snapshot to prove that
     * the cavern-to-town handoff retains those persistent bits. */
    zeliard_test_game_set_u8(0x02, 0x40);
    zeliard_test_game_set_u8(0x0A, 0x05);
    zeliard_test_game_set_u8(0x90, 0x40);
    zeliard_test_game_set_u8(0x91, 0);
    zeliard_key_down(38);
    unsigned return_ticks = 0;
    int reverse_transition_seen = 0;
    int reverse_music_continued = 1;
    unsigned reverse_music_samples = 0;
    int reverse_fade_peak = 0;
    int return_key_released = 0;
    while ((zeliard_fight_active() || zeliard_cavern_transition_active()) &&
           return_ticks++ < 2000) {
        zeliard_tick(16);
        if (zeliard_music_attenuation() > reverse_fade_peak)
            reverse_fade_peak = zeliard_music_attenuation();
        reverse_transition_seen |= zeliard_cavern_transition_active() &&
            zeliard_cavern_transition_step() > 0 &&
            (zeliard_test_game_u8(0xC2) & 1);
        if (zeliard_cavern_transition_active() &&
            zeliard_cavern_transition_step() > 0) {
            ++reverse_music_samples;
            reverse_music_continued &= zeliard_music_track() == 7;
        }
        if (zeliard_cavern_transition_active() && !return_key_released) {
            zeliard_key_up(38);
            return_key_released = 1;
        }
    }
    if (!return_key_released) zeliard_key_up(38);
    zeliard_tick(16);
    unsigned reverse_restore_differences = 0;
    for (size_t i = 0; i < sizeof(reverse_reference_frame); ++i)
        reverse_restore_differences +=
            reverse_reference_frame[i] != g_framebuf[i];
    const unsigned long long reverse_return_life =
        frame_rect_hash(84, 163, 100, 6);
    const unsigned long long reverse_return_sword =
        frame_rect_hash(192, 171, 20, 18);
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/muralla-cavern-return.ppm", g_framebuf);
    zeliard_tick(16);
    const int reverse_returned = reverse_transition_seen &&
        reverse_music_samples > 0 && reverse_music_continued &&
        reverse_fade_peak == 64 && zeliard_music_track() == 3 &&
        !zeliard_fight_active() && !zeliard_cavern_transition_active() &&
        zeliard_town_area() == 1 && zeliard_test_game_u8(0xC4) == 0x81 &&
        zeliard_test_game_u8(0x80) == 0xBD &&
        zeliard_test_game_u8(0x82) == 0x36 &&
        zeliard_test_game_u8(0x83) == 0x0C &&
        zeliard_test_game_u8(0x02) == 0x40 &&
        zeliard_test_game_u8(0x0A) == 0x05 &&
        zeliard_test_game_u16(0x90) == 0x0040 &&
        reverse_return_life == 0xBDB83C5FCD36CAF8ULL &&
        reverse_return_life != reverse_reference_life &&
        reverse_return_sword == reverse_reference_sword &&
        reverse_restore_differences > 0 &&
        (zeliard_test_game_u8(0xC2) & 1);
    ok &= reverse_returned;
    printf("main_controls:malicia_reverse_cavern_return: %s ticks=%u "
           "area=%d pos=%02x/%02x/%02x facing=%02x hp=%04x diff=%u "
           "life=%016llx>%016llx sword=%016llx/%016llx "
           "state=%02x/%02x music=%d/%u/%d fade=%d\n",
           reverse_returned ? "PASS" : "FAIL", return_ticks,
           zeliard_town_area(), zeliard_test_game_u8(0x80),
           zeliard_test_game_u8(0x82), zeliard_test_game_u8(0x83),
           zeliard_test_game_u8(0xC2), zeliard_test_game_u16(0x90),
           reverse_restore_differences,
           reverse_reference_life, reverse_return_life,
           reverse_reference_sword, reverse_return_sword,
           zeliard_test_game_u8(0x02), zeliard_test_game_u8(0x0A),
           reverse_music_continued, reverse_music_samples,
           zeliard_music_track(), reverse_fade_peak);

    /* The same main.c death/re-entry path must remain area-independent when
     * the exact VM is running Peligro rather than Malicia. */
    ok &= zeliard_test_restart_fight(2, 0, (38 - 9) & 0x3F, 0);
    zeliard_test_game_set_u8(0xC5, 0x81);
    zeliard_test_game_set_u8(0x90, 0);
    zeliard_test_game_set_u8(0x91, 0);
    unsigned peligro_death_ticks = 0;
    while (zeliard_room_kind() != 2 && peligro_death_ticks++ < 5500)
        zeliard_tick(16);
    const int peligro_death_returned = !zeliard_fight_active() &&
        zeliard_town_area() == 1 && zeliard_room_kind() == 2 &&
        zeliard_room_ip() == 0xA006 &&
        zeliard_test_game_u8(0xC4) == 0x81 &&
        zeliard_test_game_u8(0xC5) == 0x81 &&
        zeliard_test_game_u16(0x90) == zeliard_test_game_u16(0xB2);
    ok &= peligro_death_returned;
    printf("main_controls:peligro_death_sage_return: %s ticks=%u "
           "area=%d room=%d ip=%04X sage=%02X/%02X hp=%04X/%04X\n",
           peligro_death_returned ? "PASS" : "FAIL",
           peligro_death_ticks, zeliard_town_area(), zeliard_room_kind(),
           zeliard_room_ip(), zeliard_test_game_u8(0xC4),
           zeliard_test_game_u8(0xC5), zeliard_test_game_u16(0x90),
           zeliard_test_game_u16(0xB2));

    /* A saved Satono game must bootstrap the authored town selector as one
     * transaction: STMP/DPAT/CMAN, UGM1, and the saved player coordinates. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x80] = 0x4B;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x82;
    record[0xC5] = 0x82;
    const int satono_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long satono_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int satono_bootstrap = satono_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 2 && zeliard_test_game_u8(0xC4) == 0x82 &&
        zeliard_test_game_u8(0x80) == 0x4B &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 5 &&
        satono_playfield == 0x2B037379CC51F013ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/satono-save-bootstrap.ppm", g_framebuf);
    ok &= satono_bootstrap;
    printf("main_controls:satono_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           satono_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), satono_playfield);

    /* 106TOWN always calls 201SELCT through its A00Bh entry, regardless of
     * which town asset set is resident. Prove Satono cannot inherit the
     * cavern A001h item-use path: a real right/confirm attempt must leave
     * the potion, HP, and item-result byte unchanged. */
    for (unsigned offset = 0xA1; offset <= 0xC1; ++offset)
        zeliard_test_game_set_u8(offset, 0);
    zeliard_test_game_set_u8(0xA6, 1);
    zeliard_test_game_set_u8(0x90, 10);
    zeliard_test_game_set_u8(0x91, 0);
    zeliard_test_game_set_u8(0xB2, 100);
    zeliard_test_game_set_u8(0xB3, 0);
    zeliard_test_game_set_u8(0xFF4B, 0);
    zeliard_key_down(13);
    const int satono_inventory_opened = zeliard_inventory_active();
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    zeliard_key_down(39);
    zeliard_tick(90);
    zeliard_key_up(39);
    zeliard_tick(90);
    zeliard_key_down(32);
    zeliard_tick(90);
    zeliard_key_up(32);
    zeliard_tick(90);
    const int satono_item_use_blocked = satono_inventory_opened &&
        zeliard_inventory_active() && zeliard_test_game_u16(0x90) == 10 &&
        zeliard_test_game_u8(0xA6) == 1 &&
        zeliard_test_game_u8(0xFF4B) == 0;
    zeliard_key_down(13);
    zeliard_tick(90);
    zeliard_key_up(13);
    zeliard_tick(90);
    ok &= satono_item_use_blocked && !zeliard_inventory_active();
    printf("main_controls:satono_inventory_no_use: %s opened=%d "
           "hp=%04x item=%02x result=%02x closed=%d\n",
           satono_item_use_blocked && !zeliard_inventory_active()
               ? "PASS" : "FAIL",
           satono_inventory_opened, zeliard_test_game_u16(0x90),
           zeliard_test_game_u8(0xA6), zeliard_test_game_u8(0xFF4B),
           !zeliard_inventory_active());

    /* Full authored round trip: Satono's left boundary enters MP10 with
     * C3=FF (right-to-left). MP10 door 4 returns to STMP with flags 00,
     * so check_c3 must run left-to-right and compute fresh town coordinates
     * instead of restoring the boundary that initiated the trip. */
    zeliard_test_game_set_u8(0x83, 0xFF);
    zeliard_tick(90);
    const int satono_departure_started =
        zeliard_cavern_transition_active() &&
        (zeliard_test_game_u8(0xC2) & 1);
    unsigned satono_departure_ticks = 0;
    while (zeliard_cavern_transition_active() &&
           satono_departure_ticks++ < 1000)
        zeliard_tick(16);
    if (!zeliard_fight_active()) zeliard_tick(16);
    const int malicia_entered = zeliard_fight_active() &&
        zeliard_fight_map_width() == 240;

    zeliard_test_game_set_u8(0x98, 1);
    const int satono_door_staged = zeliard_test_restart_fight(
        0, 128 - 16, (32 - 9) & 0x3F, 0);
    zeliard_key_down(38);
    unsigned satono_door_ticks = 0;
    while (!zeliard_cavern_transition_active() &&
           satono_door_ticks++ < 100)
        zeliard_tick(16);
    zeliard_key_up(38);
    const int satono_return_transition =
        zeliard_cavern_transition_active() &&
        !(zeliard_test_game_u8(0xC2) & 1) &&
        zeliard_test_game_u8(0xC4) == 0x82;
    unsigned satono_return_ticks = 0;
    while ((zeliard_fight_active() ||
            zeliard_cavern_transition_active()) &&
           satono_return_ticks++ < 1000)
        zeliard_tick(16);
    zeliard_tick(16);
    const int satono_returned = !zeliard_fight_active() &&
        !zeliard_cavern_transition_active() && zeliard_town_area() == 2 &&
        zeliard_test_game_u8(0xC4) == 0x82 &&
        zeliard_test_game_u8(0x83) != 0xFF &&
        zeliard_test_game_u8(0x83) != 0x1C &&
        !(zeliard_test_game_u8(0xC2) & 1);
    for (unsigned settle = 0; settle < 10; ++settle) zeliard_tick(16);
    const int satono_return_stable = satono_returned &&
        !zeliard_fight_active() && !zeliard_cavern_transition_active() &&
        zeliard_town_area() == 2;
    ok &= satono_departure_started && malicia_entered &&
        satono_door_staged && satono_return_transition &&
        satono_return_stable;
    printf("main_controls:satono_malicia_round_trip: %s depart=%d/%u "
           "malicia=%d door=%d/%u reverse=%d return=%d/%u "
           "area=%d pos=%02x/%02x/%02x facing=%02x stable=%d\n",
           satono_departure_started && malicia_entered &&
               satono_door_staged && satono_return_transition &&
               satono_return_stable ? "PASS" : "FAIL",
           satono_departure_started, satono_departure_ticks,
           malicia_entered, satono_door_staged, satono_door_ticks,
           satono_return_transition, satono_returned, satono_return_ticks,
           zeliard_town_area(), zeliard_test_game_u8(0x80),
           zeliard_test_game_u8(0x82), zeliard_test_game_u8(0x83),
           zeliard_test_game_u8(0xC2), satono_return_stable);

    /* Riza's town handoff and a Bosque .USR restore must select BSMP,
     * MPAT/MMAN, and MGT2 as one transaction. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x12] &= (u8)~0x08;
    record[0x80] = 0x2B;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x83;
    record[0xC5] = 0x83;
    const int bosque_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long bosque_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int bosque_bootstrap = bosque_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 3 && zeliard_test_game_u8(0xC4) == 0x83 &&
        zeliard_test_game_u8(0x80) == 0x2B &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 4 &&
        bosque_playfield == 0xAAA634D89DBA5AA5ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/bosque-save-bootstrap.ppm", g_framebuf);
    ok &= bosque_bootstrap;
    printf("main_controls:bosque_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           bosque_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), bosque_playfield);

    /* Helada save records select HLMP/DPAT/CMAN, UGM1, and the exact
     * 200FIGHT-to-town coordinate handoff in one bootstrap transaction. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x1A] &= (u8)~0x10;
    record[0x80] = 0x1B;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x84;
    record[0xC5] = 0x84;
    const int helada_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long helada_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int helada_bootstrap = helada_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 4 && zeliard_test_game_u8(0xC4) == 0x84 &&
        zeliard_test_game_u8(0x80) == 0x1B &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 5 &&
        helada_playfield == 0xBAC31FEAB6F5800EULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/helada-save-bootstrap.ppm", g_framebuf);
    ok &= helada_bootstrap;
    printf("main_controls:helada_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           helada_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), helada_playfield);

    /* Tumba save records select TMMP/DPAT/CMAN, MGT2, and the exact
     * 200FIGHT-to-town coordinate handoff in one bootstrap transaction. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x22] &= (u8)~2;
    record[0x24] = 0;
    record[0x80] = 0x6F;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x85;
    record[0xC5] = 0x85;
    const int tumba_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long tumba_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int tumba_bootstrap = tumba_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 5 && zeliard_test_game_u8(0xC4) == 0x85 &&
        zeliard_test_game_u8(0x80) == 0x6F &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 6 &&
        tumba_playfield == 0x9ADCE418F222531CULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/tumba-save-bootstrap.ppm", g_framebuf);
    ok &= tumba_bootstrap;
    printf("main_controls:tumba_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           tumba_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), tumba_playfield);

    /* Dorado save records select DRMP/DPAT/CMAN, MGT2, and the exact
     * 200FIGHT-to-town coordinate handoff in one bootstrap transaction. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x2A] &= (u8)~4;
    record[0x80] = 0x4B;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x86;
    record[0xC5] = 0x86;
    const int dorado_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long dorado_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int dorado_bootstrap = dorado_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 6 && zeliard_test_game_u8(0xC4) == 0x86 &&
        zeliard_test_game_u8(0x80) == 0x4B &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 6 &&
        dorado_playfield == 0x0DE689A1BDEFFA27ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/dorado-save-bootstrap.ppm", g_framebuf);
    ok &= dorado_bootstrap;
    printf("main_controls:dorado_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           dorado_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), dorado_playfield);

    /* Llama save records select LLMP/DPAT/CMAN, MGT2, and the exact
     * 200FIGHT-to-town coordinate handoff in one bootstrap transaction. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x30] = 0;
    record[0x34] = 0;
    record[0x80] = 0x36;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x87;
    record[0xC5] = 0x87;
    const int llama_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long llama_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int llama_bootstrap = llama_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 7 && zeliard_test_game_u8(0xC4) == 0x87 &&
        zeliard_test_game_u8(0x80) == 0x36 &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 4 &&
        llama_playfield == 0x490A5B10473F47A4ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/llama-save-bootstrap.ppm", g_framebuf);
    ok &= llama_bootstrap;
    printf("main_controls:llama_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           llama_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), llama_playfield);

    /* Pureza save records select PRMP/DPAT/CMAN and the release fight-to-
     * town target 4Ch -> start 3Bh / screen column 0Dh. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x42] = 0;
    record[0x2B] = 0;
    record[0x80] = 0x3B;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x88;
    record[0xC5] = 0x88;
    const int pureza_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long pureza_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int pureza_bootstrap = pureza_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 8 && zeliard_test_game_u8(0xC4) == 0x88 &&
        zeliard_test_game_u8(0x80) == 0x3B &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 5 &&
        pureza_playfield == 0x594014704DE81F54ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/pureza-save-bootstrap.ppm", g_framebuf);
    ok &= pureza_bootstrap;
    printf("main_controls:pureza_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           pureza_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), pureza_playfield);

    /* Esco save records select ESMP/DPAT/CMAN. Its release target ABh in a
     * D7h-wide map resolves to start 009Ah / screen column 0Dh. */
    memset(record, 0, sizeof(record));
    record_file = fopen("assets/stdply.bin", "rb");
    ok &= record_file && fread(record, 1, sizeof(record), record_file) > 0;
    if (record_file) fclose(record_file);
    record[0x80] = 0x9A;
    record[0x81] = 0;
    record[0x82] = 0;
    record[0x83] = 0x0D;
    record[0xC4] = 0x89;
    record[0xC5] = 0x89;
    const int esco_loaded = zeliard_load_record(record, sizeof(record));
    const unsigned long long esco_playfield =
        fnv1a64(g_framebuf, 160u * ZELIARD_WIDTH);
    const int esco_bootstrap = esco_loaded && zeliard_scene() == 2 &&
        zeliard_town_area() == 9 && zeliard_test_game_u8(0xC4) == 0x89 &&
        zeliard_test_game_u8(0x80) == 0x9A &&
        zeliard_test_game_u8(0x83) == 0x0D &&
        zeliard_music_track() == 4 &&
        esco_playfield == 0xC6E95699DF8A3712ULL;
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/esco-save-bootstrap.ppm", g_framebuf);
    ok &= esco_bootstrap;
    printf("main_controls:esco_save_bootstrap: %s area=%d pos=%02x/%02x "
           "music=%d playfield=%016llx\n",
           esco_bootstrap ? "PASS" : "FAIL", zeliard_town_area(),
           zeliard_test_game_u8(0x80), zeliard_test_game_u8(0x83),
           zeliard_music_track(), esco_playfield);

    printf("VERDICT: %s: MASM keyboard controls\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
