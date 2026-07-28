#include "opening_audio.h"
#include "../core/timer.h"

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

void zel_opening_audio_init(void) {
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
}

void zel_opening_audio_sync_phase(int phase) {
    /* 100OPDMO:390 writes cue 4 immediately before the DMAOU animation. */
    if (phase == OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION - 1 &&
        phase != g_last_phase)
        zel_opening_audio_write_cue(4);
    if (phase != OPDMO_PHASE_STAFF_CREDITS &&
        g_music_track == ZEL_OPENING_MUSIC_ZEND && g_music_complete)
        g_music_track = ZEL_OPENING_MUSIC_NONE;
    if (phase == OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION && phase != g_last_phase)
        g_music_track = ZEL_OPENING_MUSIC_ZOPN;
    else if (phase == OPDMO_PHASE_STAFF_CREDITS && phase != g_last_phase) {
        g_music_track = ZEL_OPENING_MUSIC_ZEND;
        g_music_complete = 0;
        g_transition_fade = 0;
        g_attenuation = 0;
        g_driver_tick_divider = 1;
        g_fade_interval_counter = 1;
        g_timer_subtick_accum = 0;
    }
    g_last_phase = phase;
}

void zel_opening_audio_stop(void) {
    g_music_track = ZEL_OPENING_MUSIC_NONE;
    g_music_complete = 1;
    g_transition_fade = 0;
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
    if (g_music_track == ZEL_OPENING_MUSIC_ZEND && !g_music_complete)
        g_transition_fade = 1;
}

void zel_opening_audio_tick(u32 dt_ms) {
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
    g_music_enabled = (unsigned char)!g_music_enabled;
}

void zel_opening_audio_toggle_sound(void) {
    /* stick.asm:391-395 performs NOT gvar_sound_flag, then writes cue 1. */
    g_sound_enabled = (unsigned char)!g_sound_enabled;
    zel_opening_audio_write_cue(1);
}

void zel_opening_audio_pause(void) {
    if (g_paused)
        return;
    /* stick.asm:978-1000 writes cue 2 before INT 60h AX=3, CL=FFh. */
    zel_opening_audio_write_cue(2);
    g_paused = 1;
}

void zel_opening_audio_resume(void) {
    /* stick.asm:1015-1021 invokes INT 60h AX=3, CL=0. */
    g_paused = 0;
}

void zel_opening_audio_write_cue(u8 cue) {
    g_cue_mailbox = cue;
}

u8 zel_opening_audio_take_cue(void) {
    u8 cue = g_cue_mailbox;
    g_cue_mailbox = 0;
    /* SNDADLIB clears the mailbox before testing gvar_sound_flag. */
    return g_sound_enabled ? cue : 0;
}
