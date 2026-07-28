#include "../core/types.h"
#include "../core/framebuf.h"
#include <stdio.h>
#include <string.h>

void zeliard_init(void);
void zeliard_tick(u32 dt_ms);
void zeliard_key(int keycode);
int zeliard_phase(void);
u32 zeliard_phase_elapsed(void);
int zeliard_paused(void);
int zeliard_music_track(void);
void zeliard_music_complete(int track);
int zeliard_music_attenuation(void);
int zeliard_music_enabled(void);
int zeliard_sound_enabled(void);
int zeliard_sound_cue(void);
void zeliard_opening_set_phase_for_test(int phase);

int main(void) {
    int ok = 1;

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

    printf("VERDICT: %s: MASM keyboard controls\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
