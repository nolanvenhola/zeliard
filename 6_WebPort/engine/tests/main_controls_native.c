#include "../core/types.h"
#include "../core/framebuf.h"
#include <stdio.h>
#include <string.h>

void zeliard_init(void);
void zeliard_tick(u32 dt_ms);
void zeliard_key(int keycode);
void zeliard_key_down(int keycode);
void zeliard_key_up(int keycode);
int zeliard_scene(void);
int zeliard_test_town_dialog_active(void);
int zeliard_test_fight_returns_to_town(int operation, int selector,
                                       int dispatch);
int zeliard_test_begin_malicia_death(void);
int zeliard_test_begin_malicia_combat(void);
int zeliard_test_redraw_town(void);
int zeliard_fight_active(void);
int zeliard_inventory_active(void);
int zeliard_test_enter_room(int kind);
int zeliard_room_kind(void);
int zeliard_phase(void);
u32 zeliard_phase_elapsed(void);
u32 zeliard_audio_opl_write_count(void);
int zeliard_paused(void);
int zeliard_music_track(void);
void zeliard_music_complete(int track);
int zeliard_music_attenuation(void);
int zeliard_music_enabled(void);
int zeliard_sound_enabled(void);
int zeliard_sound_cue(void);
void zeliard_opening_set_phase_for_test(int phase);
int zeliard_load_record(const u8 *record, int size);
int zeliard_test_game_u8(int offset);
int zeliard_town_area(void);

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
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
    record[0x05] = 0xFF;       /* repeat king script */
    record[0x80] = 0x34;       /* position */
    record[0x85] = 0x01;       /* carried gold high byte */
    record[0x86] = 0x56;
    record[0x87] = 0x34;
    record[0x8D] = 7;          /* experience level */
    record[0x92] = 2;          /* sword */
    record[0x93] = 1;          /* shield */
    record[0x9D] = 3;          /* selected spell */
    record[0xBD] = 0xFF;       /* Fuego learned */
    record[0xC4] = 0x81;       /* saved at Muralla's Sage */
    record[0xE5] = 0xE0;       /* first three sages spoken */
    const int gold_before_invalid = zeliard_test_game_u8(0x85);
    const int invalid_rejected = !zeliard_load_record(record, 0xFF) &&
        zeliard_test_game_u8(0x85) == gold_before_invalid;
    ok &= invalid_rejected;
    const int loaded = zeliard_load_record(record, sizeof(record));
    const int restored = loaded && zeliard_scene() == 2 &&
        zeliard_test_game_u8(0x05) == 0xFF &&
        zeliard_test_game_u8(0x80) == 0x34 &&
        zeliard_test_game_u8(0x85) == 0x01 &&
        zeliard_test_game_u8(0x86) == 0x56 &&
        zeliard_test_game_u8(0x87) == 0x34 &&
        zeliard_test_game_u8(0x8D) == 7 &&
        zeliard_test_game_u8(0x92) == 2 &&
        zeliard_test_game_u8(0x93) == 1 &&
         zeliard_test_game_u8(0x9D) == 3 &&
         zeliard_test_game_u8(0xBD) == 0xFF &&
         zeliard_test_game_u8(0xC4) == 0x81 &&
         zeliard_town_area() == 1 &&
         zeliard_test_game_u8(0xE5) == 0xE0;
    const unsigned long long restored_frame = fnv1a64(
        g_framebuf, ZELIARD_FB_SIZE);
    const int restored_muralla_frame =
        restored_frame == 0xCB57D41686D4A49DULL;
    ok &= restored_muralla_frame;
    ok &= restored;
    printf("main_controls:save_restore_bootstrap: %s invalid=%d level=%d "
           "spell=%d sages=%02x area=%d frame=%016llx cumulative=%d\n",
           restored && restored_muralla_frame ? "PASS" : "FAIL",
           invalid_rejected,
           zeliard_test_game_u8(0x8D), zeliard_test_game_u8(0x9D),
           zeliard_test_game_u8(0xE5), zeliard_town_area(), restored_frame, ok);

    ok &= zeliard_test_begin_malicia_combat();
    for (unsigned settle = 0; settle < 5; ++settle)
        zeliard_tick(16);
    zeliard_key_down(32);
    int attack_started = 0;
    int equip_armed = 0;
    for (unsigned attack_tick = 0; attack_tick < 40; ++attack_tick) {
        zeliard_tick(16);
        attack_started |= zeliard_test_game_u8(0xFF45) == 2;
        equip_armed |= zeliard_test_game_u8(0xFF3D) != 0;
    }
    zeliard_key_up(32);
    ok &= attack_started;
    printf("main_controls:malicia_space_attack: %s armed=%d state=%02X equip=%02X climb=%02X debug=%02X sword=%02X buttons=%02X\n",
           attack_started ? "PASS" : "FAIL",
           equip_armed,
           zeliard_test_game_u8(0xFF45), zeliard_test_game_u8(0xFF3D),
           zeliard_test_game_u8(0xFF39), zeliard_test_game_u8(0xFF3B),
           zeliard_test_game_u8(0x92), zeliard_test_game_u8(0xFF16));

    record[0xC4] = 0x81;
    ok &= zeliard_load_record(record, sizeof(record));
    ok &= zeliard_test_begin_malicia_death();
    unsigned death_ticks = 0;
    while (zeliard_fight_active() && death_ticks++ < 5000)
        zeliard_tick(16);
    u8 death_return_frame[ZELIARD_FB_SIZE];
    memcpy(death_return_frame, g_framebuf, sizeof(death_return_frame));
    const int reference_redrawn = zeliard_test_redraw_town();
    unsigned town_redraw_differences = 0;
    for (size_t i = 0; i < sizeof(death_return_frame); ++i)
        town_redraw_differences += death_return_frame[i] != g_framebuf[i];
    const int death_return_redrawn = !zeliard_fight_active() &&
        zeliard_town_area() == 1 && reference_redrawn &&
        town_redraw_differences == 0;
    ok &= death_return_redrawn;
    printf("main_controls:malicia_death_town_redraw: %s ticks=%u diff=%u area=%d\n",
           death_return_redrawn ? "PASS" : "FAIL", death_ticks,
           town_redraw_differences, zeliard_town_area());

    printf("VERDICT: %s: MASM keyboard controls\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
