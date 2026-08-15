#include "opening_audio.h"
#include "mscadlib_vm.h"
#include "../core/timer.h"
#include "../platform/platform.h"
#include "opal/opal.h"

#include <stdlib.h>
#include <string.h>

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
static zel_audio_backend_t g_backend = ZEL_AUDIO_ADLIB;
static unsigned char g_backend_fallback;
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
static u32 g_cue_rebase_serial;
static u32 g_reset_serial;

typedef struct {
    double phase;
    double frequency;
    unsigned char volume;
    unsigned char active;
    unsigned char note;
    unsigned char channel;
} legacy_voice_t;

static legacy_voice_t g_legacy_voice[32];
static u16 g_pcjr_tone[3];
static u8 g_pcjr_volume[4];
static u8 g_pcjr_latched;
static u8 g_pcjr_noise;
static u16 g_pcjr_lfsr;
static u16 g_speaker_divisor;
static u8 g_speaker_low;
static u8 g_speaker_enabled;
static u8 g_midi_status;
static u8 g_midi_data[2];
static u8 g_midi_count;

static void reset_legacy_synth(void) {
    memset(g_legacy_voice, 0, sizeof(g_legacy_voice));
    memset(g_pcjr_tone, 0, sizeof(g_pcjr_tone));
    memset(g_pcjr_volume, 15, sizeof(g_pcjr_volume));
    g_pcjr_latched = g_pcjr_noise = 0;
    g_pcjr_lfsr = 0x4000;
    g_speaker_divisor = 0;
    g_speaker_low = g_speaker_enabled = 0;
    g_midi_status = g_midi_count = 0;
}

static double midi_frequency(u8 note) {
    static const double octave4[12] = {
        261.625565, 277.182631, 293.664768, 311.126984,
        329.627557, 349.228231, 369.994423, 391.995436,
        415.304698, 440.0, 466.163762, 493.883301
    };
    int octave = (int)note / 12 - 1;
    double f = octave4[note % 12];
    while (octave < 4) { f *= 0.5; octave++; }
    while (octave > 4) { f *= 2.0; octave--; }
    return f;
}

static void midi_note(u8 channel, u8 note, u8 velocity, int on) {
    for (unsigned i = 0; i < 32; ++i) {
        legacy_voice_t *voice = &g_legacy_voice[i];
        if (!on && voice->active && voice->channel == channel && voice->note == note) {
            voice->active = 0;
            return;
        }
        if (on && (!voice->active || (voice->channel == channel && voice->note == note))) {
            voice->active = 1;
            voice->channel = channel;
            voice->note = note;
            voice->volume = velocity;
            voice->frequency = midi_frequency(note);
            return;
        }
    }
}

static void consume_midi_byte(u8 value) {
    if (value & 0x80) {
        if (value < 0xF0) {
            g_midi_status = value;
            g_midi_count = 0;
        } else if (value < 0xF8) {
            g_midi_status = 0;
            g_midi_count = 0;
        }
        return;
    }
    if (!g_midi_status)
        return;
    g_midi_data[g_midi_count++] = value;
    if (g_midi_count == 2) {
        u8 command = g_midi_status & 0xF0;
        u8 channel = g_midi_status & 0x0F;
        if (command == 0x90)
            midi_note(channel, g_midi_data[0], g_midi_data[1], g_midi_data[1] != 0);
        else if (command == 0x80)
            midi_note(channel, g_midi_data[0], 0, 0);
        g_midi_count = 0;
    }
}

static void consume_pcjr_byte(u8 value) {
    unsigned channel;
    if (value & 0x80) {
        g_pcjr_latched = value;
        channel = (value >> 5) & 3;
        if (value & 0x10)
            g_pcjr_volume[channel] = value & 15;
        else if (channel < 3)
            g_pcjr_tone[channel] = (g_pcjr_tone[channel] & 0x3F0) | (value & 15);
        else
            g_pcjr_noise = value & 7;
    } else {
        channel = (g_pcjr_latched >> 5) & 3;
        if (!(g_pcjr_latched & 0x10) && channel < 3)
            g_pcjr_tone[channel] = (g_pcjr_tone[channel] & 15) | ((u16)(value & 0x3F) << 4);
    }
}

static void apply_legacy_writes(void) {
    zel_audio_port_write_t writes[256];
    size_t count;
    do {
        count = zel_mscadlib_vm_take_port_writes(&g_mscadlib, writes, 256);
        for (size_t i = 0; i < count; ++i) {
            u16 port = writes[i].port;
            u8 value = writes[i].value;
            if (g_backend == ZEL_AUDIO_MT32 && port == 0x330)
                consume_midi_byte(value);
            else if (g_backend == ZEL_AUDIO_PCJR && port == 0xC0)
                consume_pcjr_byte(value);
            else if (g_backend == ZEL_AUDIO_SPEAKER && port == 0x42) {
                if (!g_speaker_low) {
                    g_speaker_divisor = (g_speaker_divisor & 0xFF00) | value;
                    g_speaker_low = 1;
                } else {
                    g_speaker_divisor = (g_speaker_divisor & 0x00FF) | ((u16)value << 8);
                    g_speaker_low = 0;
                }
            } else if (g_backend == ZEL_AUDIO_SPEAKER && port == 0x61)
                g_speaker_enabled = (value & 3) == 3;
        }
    } while (count == 256);
}

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
        u16 buffered_retriggers = 0;
        for (size_t i = 0; i < count; ++i) {
            const u8 reg = writes[i].reg;
            const int key_register = reg >= 0xB0 && reg <= 0xB8;
            const u16 channel_bit = key_register
                ? (u16)(1u << (reg - 0xB0)) : 0;
            int starts_retrigger = 0;
            if (key_register && !(writes[i].value & 0x20)) {
                for (size_t next = i + 1; next < count; ++next) {
                    if (writes[next].tick != writes[i].tick)
                        break;
                    if (writes[next].reg != reg)
                        continue;
                    starts_retrigger = (writes[next].value & 0x20) != 0;
                    break;
                }
            }
            /* SNDADLIB keys the boss-heartbeat channels off and immediately
             * back on in one PIT service. Only that same-channel retrigger
             * needs the YM3812's write spacing. Buffering the entire music
             * batch puts the heartbeat behind unrelated cavern-score writes
             * and can make it effectively disappear in the browser mix. */
            if (starts_retrigger ||
                (key_register && (buffered_retriggers & channel_bit))) {
                opalWriteRegBuffered(&g_opl, reg, writes[i].value);
                if (starts_retrigger)
                    buffered_retriggers |= channel_bit;
                else if (writes[i].value & 0x20)
                    buffered_retriggers &= (u16)~channel_bit;
            } else {
                opalWriteReg(&g_opl, reg, writes[i].value);
            }
            g_opl_write_count++;
        }
    } while (count == sizeof(writes) / sizeof(writes[0]));
    apply_legacy_writes();
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
        if (g_backend == ZEL_AUDIO_ADLIB) {
            opalSample(&g_opl, &left, &right);
        } else {
            double sample = 0.0;
            if (g_backend == ZEL_AUDIO_MT32) {
                short opl_left, opl_right;
                opalSample(&g_opl, &opl_left, &opl_right);
                const double sfx_sample =
                    ((double)opl_left + opl_right) / 65536.0;
                double music_sample = 0.0;
                unsigned voices = 0;
                for (unsigned v = 0; v < 32; ++v) {
                    legacy_voice_t *voice = &g_legacy_voice[v];
                    if (!voice->active)
                        continue;
                    voice->phase += voice->frequency / g_audio_rate;
                    if (voice->phase >= 1.0) voice->phase -= 1.0;
                    music_sample += (voice->phase < 0.5 ? 1.0 : -1.0) *
                                    voice->volume / 127.0;
                    voices++;
                }
                if (voices) music_sample /= voices;
                /* SNDADLIB remains the canonical effects driver with MT-32
                 * music. Mix it independently: averaging OPL into the MIDI
                 * voice count previously buried effects under busy scores. */
                sample = music_sample * 0.72 + sfx_sample * 0.82;
            } else if (g_backend == ZEL_AUDIO_PCJR) {
                for (unsigned v = 0; v < 3; ++v) {
                    u16 divisor = g_pcjr_tone[v] ? g_pcjr_tone[v] : 1;
                    double frequency = 3579545.0 / (32.0 * divisor);
                    g_legacy_voice[v].phase += frequency / g_audio_rate;
                    if (g_legacy_voice[v].phase >= 1.0) g_legacy_voice[v].phase -= 1.0;
                    sample += (g_legacy_voice[v].phase < 0.5 ? 1.0 : -1.0) *
                              (15 - g_pcjr_volume[v]) / 45.0;
                }
                if (g_pcjr_volume[3] < 15) {
                    static const double noise_rates[3] = { 6991.3, 3495.6, 1747.8 };
                    double frequency = (g_pcjr_noise & 3) == 3
                        ? 3579545.0 / (32.0 * (g_pcjr_tone[2] ? g_pcjr_tone[2] : 1))
                        : noise_rates[g_pcjr_noise & 3];
                    g_legacy_voice[3].phase += frequency / g_audio_rate;
                    if (g_legacy_voice[3].phase >= 1.0) {
                        g_legacy_voice[3].phase -= 1.0;
                        u16 feedback = (g_pcjr_lfsr ^
                            ((g_pcjr_noise & 4) ? (g_pcjr_lfsr >> 1) : 0)) & 1;
                        g_pcjr_lfsr = (g_pcjr_lfsr >> 1) | (feedback << 14);
                    }
                    sample += (g_pcjr_lfsr & 1 ? 1.0 : -1.0) *
                              (15 - g_pcjr_volume[3]) / 45.0;
                }
            } else if (g_speaker_enabled && g_speaker_divisor) {
                double frequency = 1193182.0 / g_speaker_divisor;
                g_legacy_voice[0].phase += frequency / g_audio_rate;
                if (g_legacy_voice[0].phase >= 1.0) g_legacy_voice[0].phase -= 1.0;
                sample = g_legacy_voice[0].phase < 0.5 ? 0.32 : -0.32;
            }
            sample *= (64.0 - g_attenuation) / 64.0;
            if (sample > 1.0) sample = 1.0;
            if (sample < -1.0) sample = -1.0;
            left = right = (short)(sample * 20000.0);
        }
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
    case ZEL_MUSIC_MUS6: return "mus6.msd";
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
    const char *music_driver_name = "mscadlib.drv";
    const char *sfx_driver_name = "sndadlib.drv";
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
    g_cue_rebase_serial = 0;
    g_backend_fallback = 0;
    reset_legacy_synth();
    opalInit(&g_opl, g_audio_rate);
    if (g_backend == ZEL_AUDIO_MT32)
        music_driver_name = "mscmt.drv";
    else if (g_backend == ZEL_AUDIO_PCJR) {
        music_driver_name = "mscjr.drv";
        sfx_driver_name = "sndjr.drv";
    } else if (g_backend == ZEL_AUDIO_SPEAKER) {
        music_driver_name = "mscstd.drv";
        sfx_driver_name = "sndstd.drv";
    }
    driver = platform_load_asset(music_driver_name, &driver_size);
    sfx_driver = platform_load_asset(sfx_driver_name, &sfx_driver_size);
    bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    g_exact_driver = driver && sfx_driver && bios &&
        zel_mscadlib_vm_init_variant(&g_mscadlib, driver, driver_size,
                                     bios, bios_size,
                                     g_backend == ZEL_AUDIO_MT32) &&
        zel_mscadlib_vm_load_sfx_driver(&g_mscadlib, sfx_driver,
                                        sfx_driver_size);
    if (!g_exact_driver && g_backend != ZEL_AUDIO_ADLIB) {
        free(driver); free(sfx_driver);
        driver = platform_load_asset("mscadlib.drv", &driver_size);
        sfx_driver = platform_load_asset("sndadlib.drv", &sfx_driver_size);
        g_backend = ZEL_AUDIO_ADLIB;
        g_backend_fallback = 1;
        g_exact_driver = driver && sfx_driver && bios &&
            zel_mscadlib_vm_init(&g_mscadlib, driver, driver_size,
                                 bios, bios_size) &&
            zel_mscadlib_vm_load_sfx_driver(&g_mscadlib, sfx_driver,
                                            sfx_driver_size);
    }
    if (g_exact_driver) {
        /* zeliad.asm initializes FF09h to FFh before installing SNDADLIB.
         * Its heartbeat path requires that exact shared exit-state value. */
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF09, 0xFF);
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
        /* game.asm clears FF08h when the resident gameplay chunk changes.
         * Clear it before stopping the score so SNDADLIB cannot retain the
         * last boss-distance value across a load or town handoff. */
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF08, 0);
        /* The FF08 transition is consumed by SNDADLIB's timer entry, not by
         * MSCADLIB service 1.  Run that exact timer entry once so the active
         * heartbeat operator is keyed off before the next scene starts. */
        zel_mscadlib_vm_tick(&g_mscadlib);
        apply_driver_writes();
        zel_mscadlib_vm_service(&g_mscadlib, 1, 0);
        apply_driver_writes();
    }
    g_music_track = ZEL_OPENING_MUSIC_NONE;
    g_music_complete = 1;
    g_transition_fade = 0;
    clear_pcm_ring();
    g_attenuation = 0;
    /* PCM already posted to an AudioWorklet is outside the DOS driver's
     * address space. Mark this game-audio discontinuity so the browser
     * adapter also discards the stale queued sound. */
    g_reset_serial++;
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

void zel_opening_audio_set_heartbeat_volume(u8 volume) {
    /* 200FIGHT:compute_target_dist writes the boss-door proximity
     * attenuation to FF08h. SNDADLIB's PIT handler reads that shared byte
     * directly; FF27h remains the driver's authoritative F2 mute gate. */
    if (g_exact_driver)
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF08, volume);
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
        /* SNDADLIB normally consumes and discards the mailbox while FF27h
         * is muted. Gate it here as well between the host toggle and the
         * next emulated driver service. */
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF75,
                                   g_sound_enabled ? cue : 0);
}

void zel_opening_audio_write_immediate_cue(u8 cue) {
    /* A browser AudioWorklet may already hold a separate PCM cushion.  Mark
     * town UI cues at a clean engine-ring boundary so the host can discard
     * only audio rendered before the cue without also deleting its attack. */
    if (cue && g_sound_enabled) {
        g_pcm_read = g_pcm_write;
        g_cue_rebase_serial++;
    }
    zel_opening_audio_write_cue(cue);
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

int zel_opening_audio_set_backend(int backend) {
    zel_music_track_t resume = g_music_track;
    unsigned char music_enabled = g_music_enabled;
    unsigned char sound_enabled = g_sound_enabled;
    unsigned char paused = g_paused;
    if (backend < ZEL_AUDIO_ADLIB || backend > ZEL_AUDIO_SPEAKER)
        return 0;
    if ((int)g_backend == backend && g_exact_driver)
        return 1;
    g_backend = (zel_audio_backend_t)backend;
    zel_opening_audio_init();
    if (resume != ZEL_MUSIC_NONE)
        zel_audio_play_music(resume);
    if (!music_enabled && g_exact_driver)
        zel_mscadlib_vm_service(&g_mscadlib, 2, 0);
    g_music_enabled = music_enabled;
    g_sound_enabled = sound_enabled;
    if (g_exact_driver)
        zel_mscadlib_vm_set_global(&g_mscadlib, 0xFF27,
                                   sound_enabled ? 0 : 0xFF);
    g_paused = paused;
    if (paused && g_exact_driver)
        zel_mscadlib_vm_service(&g_mscadlib, 3, 0x00FF);
    if (g_exact_driver)
        apply_driver_writes();
    return g_exact_driver && !g_backend_fallback;
}

int zel_opening_audio_backend(void) { return (int)g_backend; }
int zel_opening_audio_backend_fallback(void) { return g_backend_fallback != 0; }

u32 zel_opening_audio_opl_write_count(void) {
    return g_opl_write_count;
}

u32 zel_opening_audio_generated_peak(void) {
    return g_generated_peak;
}

u32 zel_opening_audio_cue_serial(void) {
    return g_cue_serial;
}

u32 zel_opening_audio_cue_rebase_serial(void) {
    return g_cue_rebase_serial;
}

u32 zel_opening_audio_reset_serial(void) {
    return g_reset_serial;
}
