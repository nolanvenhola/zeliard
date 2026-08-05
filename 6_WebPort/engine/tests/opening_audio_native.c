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

static int expect_sustained_pcm(const char *name, int phase) {
    short pcm[480 * 2];
    int ok = 1;

    zel_opening_audio_init();
    zel_opening_audio_sync_phase(phase);
    for (int second = 0; second < 8; ++second) {
        unsigned peak = 0;
        unsigned long long sum = 0;
        size_t samples = 0;
        for (int block = 0; block < 100; ++block) {
            zel_opening_audio_tick(10);
            size_t frames = zel_opening_audio_read_pcm(pcm, 480);
            for (size_t i = 0; i < frames * 2; ++i) {
                unsigned magnitude = pcm[i] < 0 ? (unsigned)-(int)pcm[i] : (unsigned)pcm[i];
                if (magnitude > peak)
                    peak = magnitude;
                sum += magnitude;
            }
            samples += frames * 2;
        }
        printf("opening_audio:%s_second_%d: peak=%u mean=%llu writes=%u\n",
               name, second + 1, peak, samples ? sum / samples : 0,
               zel_opening_audio_opl_write_count());
        ok &= peak > 256 && sum / (samples ? samples : 1) > 16;
    }
    printf("opening_audio:%s_sustained: %s\n", name, ok ? "PASS" : "FAIL");
    return ok;
}

static int expect_sustained_track_pcm(const char *name,
                                      zel_music_track_t track) {
    short pcm[480 * 2];
    unsigned peak = 0;
    unsigned long long sum = 0;
    size_t samples = 0;

    zel_opening_audio_init();
    int ok = zel_audio_play_music(track);
    for (int block = 0; block < 200; ++block) {
        zel_opening_audio_tick(10);
        size_t frames = zel_opening_audio_read_pcm(pcm, 480);
        for (size_t i = 0; i < frames * 2; ++i) {
            unsigned magnitude = pcm[i] < 0 ?
                (unsigned)-(int)pcm[i] : (unsigned)pcm[i];
            if (magnitude > peak)
                peak = magnitude;
            sum += magnitude;
        }
        samples += frames * 2;
    }
    ok &= zel_opening_audio_music_track() == (int)track;
    ok &= samples > 0 && peak > 256 && sum / samples > 16;
    printf("opening_audio:%s_gameplay_pcm: %s frames=%zu peak=%u mean=%llu writes=%u\n",
           name, ok ? "PASS" : "FAIL", samples / 2, peak,
           samples ? sum / samples : 0, zel_opening_audio_opl_write_count());
    return ok;
}

static int expect_gameplay_track_load(const char *name,
                                      zel_music_track_t track) {
    short pcm[ZEL_AUDIO_PCM_CUSHION_FRAMES * 2];
    zel_opening_audio_init();
    int ok = zel_audio_play_music(track);
    const u32 writes_before = zel_opening_audio_opl_write_count();
    zel_opening_audio_tick(250);
    const size_t frames = zel_opening_audio_read_pcm(
        pcm, ZEL_AUDIO_PCM_CUSHION_FRAMES);
    size_t nonzero = 0;
    for (size_t i = 0; i < frames * 2; ++i)
        nonzero += pcm[i] != 0;
    ok &= zel_opening_audio_music_track() == (int)track;
    ok &= zel_opening_audio_opl_write_count() > writes_before;
    ok &= frames == ZEL_AUDIO_PCM_CUSHION_FRAMES && nonzero > 100;
    printf("opening_audio:%s_load: %s track=%d frames=%zu nonzero=%zu writes=%u\n",
           name, ok ? "PASS" : "FAIL", (int)track, frames, nonzero,
           zel_opening_audio_opl_write_count());
    return ok;
}

static int expect_sfx_pcm(u8 cue) {
    short pcm[480 * 2];
    unsigned peak = 0;
    unsigned long long sum = 0;
    size_t samples = 0;

    zel_opening_audio_init();
    zel_opening_audio_tick(10);
    (void)zel_opening_audio_read_pcm(pcm, 480);
    zel_opening_audio_write_cue(cue);
    for (int block = 0; block < 100; ++block) {
        zel_opening_audio_tick(10);
        size_t frames = zel_opening_audio_read_pcm(pcm, 480);
        for (size_t i = 0; i < frames * 2; ++i) {
            unsigned magnitude = pcm[i] < 0 ? (unsigned)-(int)pcm[i] : (unsigned)pcm[i];
            if (magnitude > peak)
                peak = magnitude;
            sum += magnitude;
        }
        samples += frames * 2;
    }
    const int ok = samples == 96000 && peak > 256 && sum / samples >= 8;
    printf("opening_audio:exact_sndadlib_cue_%02x_pcm: %s peak=%u mean=%llu writes=%u\n",
           cue, ok ? "PASS" : "FAIL", peak, samples ? sum / samples : 0,
           zel_opening_audio_opl_write_count());
    return ok;
}

static int expect_dialog_sfx_continuity(void) {
    short pcm[512 * 2];
    zel_opening_audio_init();
    zel_opening_audio_tick(100);
    const size_t stale_frames = zel_opening_audio_pcm_available();
    const u32 serial = zel_opening_audio_cue_serial();
    const u32 writes = zel_opening_audio_opl_write_count();
    zel_opening_audio_write_cue(0x1E);

    int service_ms = 0;
    while (zel_opening_audio_opl_write_count() == writes && service_ms < 5) {
        zel_opening_audio_tick(1);
        service_ms++;
    }
    const size_t buffered_frames = zel_opening_audio_pcm_available();
    const size_t delivered = zel_opening_audio_read_pcm(pcm, 512);
    const int ok = stale_frames == ZEL_AUDIO_PCM_CUSHION_FRAMES &&
        zel_opening_audio_cue_serial() == serial + 1 &&
        service_ms > 0 && service_ms <= 5 &&
        zel_opening_audio_opl_write_count() > writes &&
        buffered_frames == ZEL_AUDIO_PCM_CUSHION_FRAMES && delivered == 512;
    printf("opening_audio:dialog_sfx_continuity: %s before=%zu after=%zu "
           "service=%dms serial=%u\n", ok ? "PASS" : "FAIL",
           stale_frames, buffered_frames, service_ms,
           zel_opening_audio_cue_serial());
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

    ok &= expect_sustained_track_pcm("mgt1_castle", ZEL_MUSIC_MGT1);

    zel_opening_audio_init();
    zel_opening_audio_sync_phase(2);
    ok &= expect_track("skip_direct_to_credits", ZEL_OPENING_MUSIC_ZEND);
    ok &= zel_opening_audio_exact_driver_active();
    zel_opening_audio_tick(250);
    short pcm[4096 * 2];
    size_t pcm_frames = zel_opening_audio_read_pcm(pcm, 4096);
    size_t pcm_nonzero = 0;
    unsigned pcm_peak = 0;
    unsigned long long pcm_abs_sum = 0;
    for (size_t i = 0; i < pcm_frames * 2; ++i) {
        unsigned magnitude = pcm[i] < 0 ? (unsigned)-(int)pcm[i] : (unsigned)pcm[i];
        pcm_nonzero += pcm[i] != 0;
        if (magnitude > pcm_peak)
            pcm_peak = magnitude;
        pcm_abs_sum += magnitude;
    }
    const int pcm_flowing = pcm_frames == ZEL_AUDIO_PCM_CUSHION_FRAMES &&
                            pcm_nonzero > 100 && pcm_peak > 16 &&
                            pcm_abs_sum > pcm_frames * 2;
    printf("opening_audio:exact_mscadlib_pcm: %s frames=%zu nonzero=%zu peak=%u mean=%llu\n",
           pcm_flowing ? "PASS" : "FAIL",
           pcm_frames, pcm_nonzero, pcm_peak,
           pcm_frames ? pcm_abs_sum / (pcm_frames * 2) : 0);
    ok &= pcm_flowing;
    ok &= expect_sustained_pcm("zopn", 22);
    ok &= expect_sustained_pcm("zend", 2);
    ok &= expect_gameplay_track_load("mgt1", ZEL_MUSIC_MGT1);
    ok &= expect_gameplay_track_load("mgt2", ZEL_MUSIC_MGT2);
    ok &= expect_gameplay_track_load("ugm1", ZEL_MUSIC_UGM1);
    ok &= expect_gameplay_track_load("ugm2", ZEL_MUSIC_UGM2);
    static const u8 sfx_pcm_cues[] = {
        0x02, 0x04, 0x07, 0x09, 0x16, 0x1E,
        0x3D, 0x3E, 0x3F, 0x40, 0x41
    };
    for (size_t i = 0; i < sizeof(sfx_pcm_cues); ++i)
        ok &= expect_sfx_pcm(sfx_pcm_cues[i]);
    ok &= expect_dialog_sfx_continuity();

    zel_opening_audio_write_cue(0x3F);
    if (zel_opening_audio_take_cue() != 0x3F || zel_opening_audio_take_cue() != 0) {
        puts("opening_audio:cue_mailbox: FAIL");
        ok = 0;
    } else {
        puts("opening_audio:cue_mailbox: PASS");
    }

    int control_ok = 1;
    zel_opening_audio_toggle_music();
    control_ok &= !zel_opening_audio_music_enabled();
    control_ok &= zel_opening_audio_take_cue() == 1;
    zel_opening_audio_toggle_music();
    control_ok &= zel_opening_audio_music_enabled();
    control_ok &= zel_opening_audio_take_cue() == 1;
    puts(control_ok ? "opening_audio:f1_music_toggle: PASS" :
                      "opening_audio:f1_music_toggle: FAIL");
    ok &= control_ok;

    control_ok = 1;
    zel_opening_audio_toggle_sound();
    control_ok &= !zel_opening_audio_sound_enabled();
    control_ok &= zel_opening_audio_take_cue() == 0;
    zel_opening_audio_write_cue(0x3F);
    control_ok &= zel_opening_audio_take_cue() == 0;
    zel_opening_audio_toggle_sound();
    control_ok &= zel_opening_audio_sound_enabled();
    control_ok &= zel_opening_audio_take_cue() == 1;
    puts(control_ok ? "opening_audio:f2_sound_toggle: PASS" :
                      "opening_audio:f2_sound_toggle: FAIL");
    ok &= control_ok;

    control_ok = 1;
    zel_opening_audio_pause();
    control_ok &= zel_opening_audio_paused();
    control_ok &= zel_opening_audio_take_cue() == 2;
    zel_opening_audio_resume();
    control_ok &= !zel_opening_audio_paused();
    puts(control_ok ? "opening_audio:pause_service: PASS" :
                      "opening_audio:pause_service: FAIL");
    ok &= control_ok;

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
