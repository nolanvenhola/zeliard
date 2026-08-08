#include "opening_audio.h"
#include "mscadlib_vm.h"
#include "../core/timer.h"
#include "../platform/platform.h"
#include "opal/opal.h"

#include <stdlib.h>

/* 100OPDMO release phase IDs. The proxy models the two places where MASM
 * loads a score and invokes INT 60h; unrelated phase changes leave the
 * currently loaded driver score alone. */
enum {
    OPDMO_PHASE_STAFF_CREDITS = 2,
    OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION = 22
};

static zel_opening_music_track_t g_music_track;
static unsigned char g_cue_mailbox;
static unsigned char g_music_enabled;
static unsigned char g_sound_enabled;
static unsigned char g_paused;
static unsigned char g_music_complete;
static unsigned char g_transition_fade;
static unsigned char g_attenuation;
static unsigned char g_driver_tick_divider;
static unsigned char g_fade_interval_counter;
static u32 g_timer_subtick_accum;
static int g_last_phase;
static zel_mscadlib_vm_t g_mscadlib;
static Opal g_opl;
static unsigned char g_exact_driver;
static u32 g_pcm_subframe_accum;
static int g_audio_rate = 48000;
enum {
    PCM_RING_FRAMES = 65536,
    PCM_MAX_BUFFERED_FRAMES = ZEL_AUDIO_PCM_CUSHION_FRAMES
};
static short g_pcm_ring[PCM_RING_FRAMES * 2];
static size_t g_pcm_read;
static size_t g_pcm_write;
static u32 g_opl_write_count;
static u32 g_generated_peak;
static u32 g_cue_serial;

static void clear_pcm_ring(void) {
    g_pcm_read = g_pcm_write = 0;
    g_pcm_subframe_accum = 0;
}

static void apply_driver_writes(void) {
    zel_opl_write_t writes[256];
    size_t count;
    do {
        count = zel_mscadlib_vm_take_writes(&g_mscadlib, writes,
                                             sizeof(writes) / sizeof(writes[0]));
        for (size_t i = 0; i < count; ++i) {
            opalWriteReg(&g_opl, writes[i].reg, writes[i].value);
            g_opl_write_count++;
        }
    } while (count == sizeof(writes) / sizeof(writes[0]));
}

static size_t pcm_available(void) {
    if (g_pcm_write >= g_pcm_read)
        return g_pcm_write - g_pcm_read;
    return PCM_RING_FRAMES - g_pcm_read + g_pcm_write;
}

static void ring_sample(short left, short right) {
    if (pcm_available() >= PCM_MAX_BUFFERED_FRAMES)
        g_pcm_read = (g_pcm_read + 1) % PCM_RING_FRAMES;
    size_t next = (g_pcm_write + 1) % PCM_RING_FRAMES;
    if (next == g_pcm_read)
        g_pcm_read = (g_pcm_read + 1) % PCM_RING_FRAMES;
    g_pcm_ring[g_pcm_write * 2] = left;
    g_pcm_ring[g_pcm_write * 2 + 1] = right;
    g_pcm_write = next;
}

static void generate_pcm_ms(void) {
    unsigned frames;
    if (!g_exact_driver)
        return;
    g_pcm_subframe_accum += (u32)g_audio_rate;
    frames = g_pcm_subframe_accum / 1000u;
    g_pcm_subframe_accum %= 1000u;
    for (unsigned i = 0; i < frames; ++i) {
        short left, right;
        opalSample(&g_opl, &left, &right);
        unsigned left_magnitude = left < 0 ? (unsigned)-(int)left : (unsigned)left;
        unsigned right_magnitude = right < 0 ? (unsigned)-(int)right : (unsigned)right;
        if (left_magnitude > g_generated_peak)
            g_generated_peak = left_magnitude;
        if (right_magnitude > g_generated_peak)
            g_generated_peak = right_magnitude;
        ring_sample(left, right);
    }
}

static int load_exact_track(const char *asset) {
    size_t size = 0;
    u8 *score = platform_load_asset(asset, &size);
    int ok;
    clear_pcm_ring();
    ok = score && zel_mscadlib_vm_load_score(&g_mscadlib, score, size);
    free(score);
    if (ok)
        apply_driver_writes();
    return ok;
}

static const char *music_asset(zel_music_track_t track) {
    switch (track) {
    case ZEL_MUSIC_ZOPN: return "zopn.msd";
    case ZEL_MUSIC_ZEND: return "zend.msd";
    case ZEL_MUSIC_MGT1: return "mgt1.msd";
    case ZEL_MUSIC_MGT2: return "mgt2.msd";
    case ZEL_MUSIC_UGM1: return "ugm1.msd";
    case ZEL_MUSIC_UGM2: return "ugm2.msd";
    case ZEL_MUSIC_MUS1: return "mus1.msd";
    case ZEL_MUSIC_MUS2: return "mus2.msd";
    case ZEL_MUSIC_MUS3: return "mus3.msd";
    case ZEL_MUSIC_MUS4: return "mus4.msd";
    case ZEL_MUSIC_MUS5: return "mus5.msd";
    case ZEL_MUSIC_MBOS: return "mbos.msd";
    case ZEL_MUSIC_MFAN: return "mfan.msd";
    default: return NULL;
    }
}

int zel_audio_play_music(zel_music_track_t track) {
    const char *asset = music_asset(track);
    if (!asset) {
        if (track == ZEL_MUSIC_NONE) {
            zel_opening_audio_stop();
            return 1;
        }
        return 0;
    }

    g_music_track = track;
    g_music_complete = 0;
    g_transition_fade = 0;
    g_attenuation = 0;
    g_driver_tick_divider = 1;
    g_fade_interval_counter = 1;
    g_timer_subtick_accum = 0;
    if (!g_exact_driver || !load_exact_track(asset)) {
        g_music_track = ZEL_MUSIC_NONE;
        g_music_complete = 1;
        g_exact_driver = 0;
        return 0;
    }
    return 1;
}

void zel_opening_audio_init(void) {
    size_t driver_size = 0, sfx_driver_size = 0, bios_size = 0;
    u8 *driver;
    u8 *sfx_driver;
    u8 *bios;
    g_music_track = ZEL_OPENING_MUSIC_NONE;
    g_cue_mailbox = 0;
    g_music_enabled = 1;
    g_sound_enabled = 1;
    g_paused = 0;
    g_music_complete = 1;
    g_transition_fade = 0;
    g_attenuation = 0;
    g_driver_tick_divider = 1;
    g_fade_interval_counter = 1;
    g_timer_subtick_accum = 0;
    g_last_phase = -1;
    clear_pcm_ring();
    g_opl_write_count = 0;
    g_generated_peak = 0;
    g_cue_serial = 0;
    opalInit(&g_opl, g_audio_rate);
    driver = platform_load_asset("mscadlib.drv", &driver_size);
    sfx_driver = platform_load_asset("sndadlib.drv", &sfx_driver_size);
    bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    g_exact_driver = driver && sfx_driver && bios &&
        zel_mscadlib_vm_init(&g_mscadlib, driver, driver_size, bios, bios_size) &&
        zel_mscadlib_vm_load_sfx_driver(&g_mscadlib, sfx_driver,
                                        sfx_driver_size);
    if (g_exact_driver) {
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF27, 0);
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF75, 0);
    }
    free(driver);
    free(sfx_driver);
    free(bios);
}

void zel_opening_audio_sync_phase(int phase) {
    /* 100OPDMO:390 writes cue 4 immediately before the DMAOU animation. */
    if (phase == OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION - 1 &&
        phase != g_last_phase)
        zel_opening_audio_write_cue(4);
    if (phase != OPDMO_PHASE_STAFF_CREDITS &&
        g_music_track == ZEL_OPENING_MUSIC_ZEND && g_music_complete)
        g_music_track = ZEL_OPENING_MUSIC_NONE;
    if (phase == OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION && phase != g_last_phase) {
        zel_audio_play_music(ZEL_MUSIC_ZOPN);
    }
    else if (phase == OPDMO_PHASE_STAFF_CREDITS && phase != g_last_phase) {
        zel_audio_play_music(ZEL_MUSIC_ZEND);
    }
    g_last_phase = phase;
}

void zel_opening_audio_stop(void) {
    if (g_exact_driver) {
        zel_mscadlib_vm_service(&g_mscadlib, 1, 0);
        apply_driver_writes();
    }
    g_music_track = ZEL_OPENING_MUSIC_NONE;
    g_music_complete = 1;
    g_transition_fade = 0;
    clear_pcm_ring();
    g_attenuation = 0;
}

int zel_opening_audio_music_track(void) {
    return (int)g_music_track;
}

void zel_opening_audio_music_complete(int track) {
    if ((int)g_music_track == track)
        g_music_complete = 1;
}

void zel_opening_audio_begin_transition_fade(void) {
    /* 100OPDMO trans_exit writes 8 to FF24h. MSCADLIB sub_463 uses that
     * byte as its reload interval and adds four to FF25h on each expiry.
     * FF25h is divided by four when applied to the OPL total-level fields,
     * yielding 64 attenuation steps before the byte wraps and FF26h is set. */
    if (g_music_track == ZEL_OPENING_MUSIC_ZEND && !g_music_complete) {
        g_transition_fade = 1;
        if (g_exact_driver)
            zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF24, 8);
    }
}

void zel_opening_audio_begin_gameplay_transition_fade(void) {
    /* Town scene transitions write 4 to shared byte FF24h.  MSCADLIB treats
     * it as the fade reload interval, adding four to FF25h on each expiry.
     * At the original PIT rate, 64 steps at interval four span the same
     * roughly 2.1 seconds as check_c3's 26 x 20-tick ROKA walk. */
    if (g_music_track != ZEL_MUSIC_NONE && !g_music_complete) {
        g_transition_fade = 1;
        g_fade_interval_counter = 1;
        if (g_exact_driver)
            zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF24, 4);
    }
}

void zel_opening_audio_begin_gameplay_death_fade(void) {
    /* 200FIGHT:fade_out writes 8 to shared byte FF24h immediately before
     * its thirty redraw-lock wipe passes and final MCGA fade-to-black. */
    if (g_music_track != ZEL_MUSIC_NONE && !g_music_complete) {
        g_transition_fade = 1;
        g_fade_interval_counter = 1;
        if (g_exact_driver)
            zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF24, 8);
    }
}

void zel_opening_audio_tick(u32 dt_ms) {
    if (g_exact_driver) {
        for (u32 ms = 0; ms < dt_ms; ++ms) {
            u32 ticks = zel_timer_advance_ms(&g_timer_subtick_accum, 1);
            while (ticks-- > 0) {
                if (!zel_mscadlib_vm_tick(&g_mscadlib)) {
                    g_exact_driver = 0;
                    break;
                }
                apply_driver_writes();
            }
            generate_pcm_ms();
        }
        g_attenuation = zel_mscadlib_vm_global(&g_mscadlib, 0xFF25) / 4u;
        if (zel_mscadlib_vm_global(&g_mscadlib, 0xFF26)) {
            /* The final overflowing add stores FFh in FF25h, then keys off.
             * Keep the public 0..64 contract while memory remains exact. */
            g_attenuation = 64;
            g_music_complete = 1;
            g_transition_fade = 0;
        }
        if (g_exact_driver)
            return;
    }
    u32 ticks = zel_timer_advance_ms(&g_timer_subtick_accum, dt_ms);

    while (ticks-- > 0 && !g_music_complete) {
        if (--g_driver_tick_divider != 0)
            continue;
        g_driver_tick_divider = 2; /* MSCADLIB loc_404: byte_CC6 = 2. */
        if (!g_transition_fade || --g_fade_interval_counter != 0)
            continue;
        g_fade_interval_counter = 8; /* FF24h written by trans_exit. */
        if (g_attenuation < 64)
            g_attenuation++;
        if (g_attenuation == 64) {
            g_transition_fade = 0;
            g_music_complete = 1; /* MSCADLIB sub_463 writes FF26h = FFh. */
        }
    }
}

int zel_opening_audio_attenuation(void) {
    return g_attenuation;
}

int zel_opening_audio_ready_for_transition(void) {
    return g_music_complete || !g_music_enabled;
}

int zel_opening_audio_music_enabled(void) {
    return g_music_enabled != 0;
}

int zel_opening_audio_sound_enabled(void) {
    return g_sound_enabled != 0;
}

int zel_opening_audio_paused(void) {
    return g_paused != 0;
}

void zel_opening_audio_toggle_music(void) {
    /* stick.asm:367-377 writes cue 1, then invokes INT 60h AX=2. */
    zel_opening_audio_write_cue(1);
    if (g_exact_driver)
        zel_mscadlib_vm_service(&g_mscadlib, 2, g_music_enabled ? 0 : 1);
    g_music_enabled = (unsigned char)!g_music_enabled;
    if (g_exact_driver)
        apply_driver_writes();
}

void zel_opening_audio_toggle_sound(void) {
    /* stick.asm:391-395 performs NOT gvar_sound_flag, then writes cue 1. */
    g_sound_enabled = (unsigned char)!g_sound_enabled;
    if (g_exact_driver)
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF27,
                                   g_sound_enabled ? 0 : 0xFF);
    zel_opening_audio_write_cue(1);
}

void zel_opening_audio_pause(void) {
    if (g_paused)
        return;
    /* stick.asm:978-1000 writes cue 2 before INT 60h AX=3, CL=FFh. */
    zel_opening_audio_write_cue(2);
    g_paused = 1;
    if (g_exact_driver) {
        zel_mscadlib_vm_service(&g_mscadlib, 3, 0x00FF);
        apply_driver_writes();
        g_pcm_read = g_pcm_write;
    }
}

void zel_opening_audio_resume(void) {
    /* stick.asm:1015-1021 invokes INT 60h AX=3, CL=0. */
    g_paused = 0;
    if (g_exact_driver) {
        zel_mscadlib_vm_service(&g_mscadlib, 3, 0);
        apply_driver_writes();
    }
}

void zel_opening_audio_write_cue(u8 cue) {
    g_cue_mailbox = cue;
    if (cue && g_sound_enabled)
        /* Keep the host PCM continuous. SNDADLIB consumes FF75h on the next
         * original PIT service, and the bounded ring limits audible latency
         * without deleting music that the OPL has already rendered. */
        g_cue_serial++;
    if (g_exact_driver)
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF75, cue);
}

u8 zel_opening_audio_take_cue(void) {
    u8 cue = g_cue_mailbox;
    g_cue_mailbox = 0;
    /* SNDADLIB clears the mailbox before testing gvar_sound_flag. */
    return g_sound_enabled ? cue : 0;
}

size_t zel_opening_audio_read_pcm(short *stereo, size_t frames) {
    size_t count = 0;
    if (!stereo)
        return 0;
    while (count < frames && g_pcm_read != g_pcm_write) {
        stereo[count * 2] = g_pcm_ring[g_pcm_read * 2];
        stereo[count * 2 + 1] = g_pcm_ring[g_pcm_read * 2 + 1];
        g_pcm_read = (g_pcm_read + 1) % PCM_RING_FRAMES;
        count++;
    }
    return count;
}

size_t zel_opening_audio_pcm_available(void) {
    return pcm_available();
}

int zel_opening_audio_exact_driver_active(void) {
    return g_exact_driver != 0;
}

void zel_opening_audio_set_sample_rate(int sample_rate) {
    if (sample_rate < 8000 || sample_rate > 192000)
        return;
    g_audio_rate = sample_rate;
    clear_pcm_ring();
    opalSetSampleRate(&g_opl, sample_rate);
}

u32 zel_opening_audio_opl_write_count(void) {
    return g_opl_write_count;
}

u32 zel_opening_audio_generated_peak(void) {
    return g_generated_peak;
}

u32 zel_opening_audio_cue_serial(void) {
    return g_cue_serial;
}
