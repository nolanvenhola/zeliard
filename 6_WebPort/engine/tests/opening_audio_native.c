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

    zel_opening_audio_sync_phase(1);
    ok &= expect_track("amulet_still_silent", ZEL_OPENING_MUSIC_NONE);

    zel_opening_audio_sync_phase(22);
    ok &= expect_track("zopn_title_handoff", ZEL_OPENING_MUSIC_ZOPN);

    zel_opening_audio_sync_phase(21);
    ok &= expect_track("unrelated_phase_retains_zopn", ZEL_OPENING_MUSIC_ZOPN);

    zel_opening_audio_sync_phase(2);
    ok &= expect_track("zend_credits_handoff", ZEL_OPENING_MUSIC_ZEND);

    zel_opening_audio_sync_phase(3);
    ok &= expect_track("story_retains_zend", ZEL_OPENING_MUSIC_ZEND);

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
