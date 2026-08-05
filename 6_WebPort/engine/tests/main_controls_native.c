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
int zeliard_scene(void);
int zeliard_test_town_dialog_active(void);
int zeliard_test_fight_returns_to_town(int operation, int selector,
                                       int dispatch);
int zeliard_test_begin_malicia_death(void);
int zeliard_test_begin_malicia_combat(void);
int zeliard_test_begin_malicia_transition(void);
int zeliard_test_begin_malicia_exit(void);
int zeliard_test_redraw_town(void);
int zeliard_fight_active(void);
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
int zeliard_music_track(void);
void zeliard_music_complete(int track);
int zeliard_music_attenuation(void);
int zeliard_music_enabled(void);
int zeliard_sound_enabled(void);
int zeliard_sound_cue(void);
int zeliard_test_game_u8(unsigned offset);
int zeliard_test_game_u16(unsigned offset);
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
    const unsigned long long restored_shield =
        frame_rect_hash(250, 164, 16, 16);
    const unsigned long long muralla_clean_side_frame =
        side_frame_hash(g_framebuf);
    if (getenv("ZELIARD_DUMP"))
        write_frame_ppm("build/muralla-before-cavern.ppm", g_framebuf);
    const int restored_muralla_frame =
        restored_frame == 0x858B0095BBABA57DULL;
    const int restored_shield_icon =
        restored_shield == 0x18FDBA10EBC3FCC6ULL;
    ok &= restored_muralla_frame && restored_shield_icon;
    ok &= restored;
    printf("main_controls:save_restore_bootstrap: %s invalid=%d level=%d "
           "spell=%d sages=%02x area=%d frame=%016llx shield=%016llx "
           "cumulative=%d\n",
           restored && restored_muralla_frame && restored_shield_icon ?
               "PASS" : "FAIL",
           invalid_rejected,
           zeliard_test_game_u8(0x8D), zeliard_test_game_u8(0x9D),
           zeliard_test_game_u8(0xE5), zeliard_town_area(), restored_frame,
           restored_shield, ok);

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
    const u32 malicia_cue_serial_before = zeliard_audio_cue_serial();
    unsigned malicia_cue_counts[256] = {0};
    for (unsigned settle = 0; settle < 5; ++settle) {
        zeliard_tick(16);
        const u8 cue = (u8)zeliard_sound_cue();
        malicia_cue_counts[cue]++;
    }
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
        malicia_cue_serial_after - malicia_cue_serial_before == 3 &&
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
           "silent=%u\n", malicia_cue_edges ? "PASS" : "FAIL",
           malicia_cue_counts[0x14], malicia_cue_counts[0x03],
           malicia_cue_counts[0x07], malicia_cue_counts[0]);

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
        death_hud_hash == 0x661FD6497C0EAD69ULL &&
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
        death_sage_exit_playfield == 0x03AEADB0E2FF861AULL;
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
    const int return_start = zeliard_test_game_u8(0x80);
    const int return_scroll = zeliard_test_game_u8(0x82);
    const int return_column = zeliard_test_game_u8(0x83);
    u8 reverse_reference_frame[ZELIARD_FB_SIZE];
    memcpy(reverse_reference_frame, g_framebuf,
           sizeof(reverse_reference_frame));
    ok &= zeliard_test_begin_malicia_exit();
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
    zeliard_tick(16);
    const int reverse_returned = reverse_transition_seen &&
        reverse_music_samples > 0 && reverse_music_continued &&
        reverse_fade_peak == 64 && zeliard_music_track() == 3 &&
        !zeliard_fight_active() && !zeliard_cavern_transition_active() &&
        zeliard_town_area() == 1 && zeliard_test_game_u8(0xC4) == 0x81 &&
        zeliard_test_game_u8(0x80) == return_start &&
        zeliard_test_game_u8(0x82) == return_scroll &&
        zeliard_test_game_u8(0x83) == return_column &&
        reverse_restore_differences == 0 &&
        (zeliard_test_game_u8(0xC2) & 1);
    ok &= reverse_returned;
    printf("main_controls:malicia_reverse_cavern_return: %s ticks=%u "
           "area=%d pos=%02x/%02x/%02x facing=%02x diff=%u "
           "music=%d/%u/%d fade=%d\n",
           reverse_returned ? "PASS" : "FAIL", return_ticks,
           zeliard_town_area(), zeliard_test_game_u8(0x80),
           zeliard_test_game_u8(0x82), zeliard_test_game_u8(0x83),
           zeliard_test_game_u8(0xC2), reverse_restore_differences,
           reverse_music_continued, reverse_music_samples,
           zeliard_music_track(), reverse_fade_peak);

    printf("VERDICT: %s: MASM keyboard controls\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
