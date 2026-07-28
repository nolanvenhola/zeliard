#include "../audio/opening_audio.h"
#include "../audio/adlib_cue.h"
#include <stdio.h>
#include <stdlib.h>

static int expect_track(const char *name, int expected) {
    int actual = zel_opening_audio_music_track();
    int ok = actual == expected;
    printf("opening_audio:%s: %s actual=%d expected=%d\n",
           name, ok ? "PASS" : "FAIL", actual, expected);
    return ok;
}

int main(void) {
    int ok = 1;

    zel_opening_audio_init();
    ok &= expect_track("init_silent", ZEL_OPENING_MUSIC_NONE);
    ok &= zel_opening_audio_music_enabled();
    ok &= zel_opening_audio_sound_enabled();
    ok &= !zel_opening_audio_paused();

    zel_opening_audio_sync_phase(1);
    ok &= expect_track("amulet_still_silent", ZEL_OPENING_MUSIC_NONE);

    zel_opening_audio_sync_phase(22);
    ok &= expect_track("zopn_title_handoff", ZEL_OPENING_MUSIC_ZOPN);

    zel_opening_audio_sync_phase(21);
    ok &= expect_track("unrelated_phase_retains_zopn", ZEL_OPENING_MUSIC_ZOPN);
    ok &= zel_opening_audio_take_cue() == 4;
    zel_opening_audio_sync_phase(21);
    ok &= zel_opening_audio_take_cue() == 0;
    puts(ok ? "opening_audio:dmaou_cue_once: PASS" :
              "opening_audio:dmaou_cue_once: FAIL");

    zel_opening_audio_sync_phase(2);
    ok &= expect_track("zend_credits_handoff", ZEL_OPENING_MUSIC_ZEND);
    ok &= !zel_opening_audio_ready_for_transition();

    zel_opening_audio_begin_transition_fade();
    ok &= expect_track("credits_fade_keeps_same_source", ZEL_OPENING_MUSIC_ZEND);
    ok &= !zel_opening_audio_ready_for_transition();
    int fade_ms = 0;
    while (zel_opening_audio_attenuation() == 0 && fade_ms < 100)
        zel_opening_audio_tick(1), fade_ms++;
    ok &= zel_opening_audio_attenuation() == 1;
    const int first_step_ms = fade_ms;
    while (!zel_opening_audio_ready_for_transition() && fade_ms < 5000)
        zel_opening_audio_tick(1), fade_ms++;
    ok &= zel_opening_audio_attenuation() == 64;
    ok &= zel_opening_audio_ready_for_transition();
    zel_opening_audio_sync_phase(3);
    ok &= expect_track("zend_completion_releases_story", ZEL_OPENING_MUSIC_NONE);
    printf("opening_audio:mscadlib_fade_8x64: %s first=%dms total=%dms\n",
           (first_step_ms <= 5 && fade_ms >= 4200 && fade_ms <= 4300) ? "PASS" : "FAIL",
           first_step_ms, fade_ms);
    ok &= first_step_ms <= 5 && fade_ms >= 4200 && fade_ms <= 4300;

    zel_opening_audio_stop();
    ok &= expect_track("game_handoff_stops", ZEL_OPENING_MUSIC_NONE);

    zel_opening_audio_init();
    zel_opening_audio_sync_phase(2);
    ok &= expect_track("skip_direct_to_credits", ZEL_OPENING_MUSIC_ZEND);

    zel_opening_audio_write_cue(0x3F);
    if (zel_opening_audio_take_cue() != 0x3F || zel_opening_audio_take_cue() != 0) {
        puts("opening_audio:cue_mailbox: FAIL");
        ok = 0;
    } else {
        puts("opening_audio:cue_mailbox: PASS");
    }

    zel_opening_audio_toggle_music();
    ok &= !zel_opening_audio_music_enabled();
    ok &= zel_opening_audio_take_cue() == 1;
    zel_opening_audio_toggle_music();
    ok &= zel_opening_audio_music_enabled();
    ok &= zel_opening_audio_take_cue() == 1;
    puts(ok ? "opening_audio:f1_music_toggle: PASS" :
              "opening_audio:f1_music_toggle: FAIL");

    zel_opening_audio_toggle_sound();
    ok &= !zel_opening_audio_sound_enabled();
    ok &= zel_opening_audio_take_cue() == 0;
    zel_opening_audio_write_cue(0x3F);
    ok &= zel_opening_audio_take_cue() == 0;
    zel_opening_audio_toggle_sound();
    ok &= zel_opening_audio_sound_enabled();
    ok &= zel_opening_audio_take_cue() == 1;
    puts(ok ? "opening_audio:f2_sound_toggle: PASS" :
              "opening_audio:f2_sound_toggle: FAIL");

    zel_opening_audio_pause();
    ok &= zel_opening_audio_paused();
    ok &= zel_opening_audio_take_cue() == 2;
    zel_opening_audio_resume();
    ok &= !zel_opening_audio_paused();
    puts(ok ? "opening_audio:pause_service: PASS" :
              "opening_audio:pause_service: FAIL");

    FILE *driver_file = fopen("assets/sndadlib.drv", "rb");
    if (!driver_file) {
        puts("opening_audio:sndadlib_open: FAIL");
        ok = 0;
    } else {
        fseek(driver_file, 0, SEEK_END);
        long driver_size = ftell(driver_file);
        rewind(driver_file);
        u8 *driver = (u8 *)malloc((size_t)driver_size);
        if (!driver || fread(driver, 1, (size_t)driver_size, driver_file) !=
                           (size_t)driver_size) {
            puts("opening_audio:sndadlib_read: FAIL");
            ok = 0;
        } else {
            static const struct {
                u8 cue;
                u8 priority;
                u16 voice_a, voice_b, tail;
            } expected[] = {
                {0x02, 0xFF, 0x1915, 0x201F, 0x1923},
                {0x04, 0x00, 0x193E, 0x194A, 0x1955},
                {0x3D, 0xFF, 0x1FEC, 0x201F, 0x1FF6},
                {0x3E, 0xFF, 0x1FF7, 0x201F, 0x1FF6},
                {0x3F, 0xFF, 0x2001, 0x201F, 0x1FF6},
                {0x40, 0xFF, 0x200B, 0x201F, 0x1FF6},
                {0x41, 0xFF, 0x2015, 0x201F, 0x1FF6},
            };
            for (size_t i = 0; i < sizeof(expected) / sizeof(expected[0]); i++) {
                zel_adlib_cue_descriptor_t actual;
                int decoded = zel_adlib_cue_descriptor(driver, (size_t)driver_size,
                                                        expected[i].cue, &actual);
                int match = decoded && actual.priority == expected[i].priority &&
                            actual.voice_a == expected[i].voice_a &&
                            actual.voice_b == expected[i].voice_b &&
                            actual.tail == expected[i].tail;
                printf("opening_audio:sndadlib_cue_%02X: %s\n",
                       expected[i].cue, match ? "PASS" : "FAIL");
                ok &= match;
            }
        }
        free(driver);
        fclose(driver_file);
    }

    printf("VERDICT: %s: opening audio native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
