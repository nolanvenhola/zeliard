#ifndef ZELIARD_OPENING_AUDIO_H
#define ZELIARD_OPENING_AUDIO_H

#include "../core/types.h"
#include <stddef.h>

typedef enum {
    ZEL_MUSIC_NONE = 0,
    ZEL_MUSIC_ZOPN = 1,
    ZEL_MUSIC_ZEND = 2,
    ZEL_MUSIC_MGT1 = 3,
    ZEL_MUSIC_MGT2 = 4,
    ZEL_MUSIC_UGM1 = 5,
    ZEL_MUSIC_UGM2 = 6,
    ZEL_MUSIC_MUS1 = 7,
    ZEL_MUSIC_MBOS = 8,
    ZEL_MUSIC_MUS2 = 9,
    ZEL_MUSIC_MFAN = 10
} zel_music_track_t;

typedef zel_music_track_t zel_opening_music_track_t;
#define ZEL_OPENING_MUSIC_NONE ZEL_MUSIC_NONE
#define ZEL_OPENING_MUSIC_ZOPN ZEL_MUSIC_ZOPN
#define ZEL_OPENING_MUSIC_ZEND ZEL_MUSIC_ZEND

/* Keep enough PCM ahead for one browser audio callback plus a delayed
 * animation frame. This remains bounded so gameplay cues stay responsive. */
#define ZEL_AUDIO_PCM_CUSHION_FRAMES 3072

void zel_opening_audio_init(void);
void zel_opening_audio_sync_phase(int phase);
int zel_audio_play_music(zel_music_track_t track);
void zel_opening_audio_stop(void);
int zel_opening_audio_music_track(void);
void zel_opening_audio_music_complete(int track);
void zel_opening_audio_begin_transition_fade(void);
void zel_opening_audio_begin_gameplay_transition_fade(void);
void zel_opening_audio_begin_gameplay_death_fade(void);
void zel_opening_audio_tick(u32 dt_ms);
int zel_opening_audio_attenuation(void);
int zel_opening_audio_ready_for_transition(void);
int zel_opening_audio_music_enabled(void);
int zel_opening_audio_sound_enabled(void);
int zel_opening_audio_paused(void);
void zel_opening_audio_toggle_music(void);
void zel_opening_audio_toggle_sound(void);
void zel_opening_audio_pause(void);
void zel_opening_audio_resume(void);
void zel_opening_audio_write_cue(u8 cue);
u8 zel_opening_audio_take_cue(void);
size_t zel_opening_audio_read_pcm(short *stereo, size_t frames);
size_t zel_opening_audio_pcm_available(void);
int zel_opening_audio_exact_driver_active(void);
void zel_opening_audio_set_sample_rate(int sample_rate);
u32 zel_opening_audio_opl_write_count(void);
u32 zel_opening_audio_generated_peak(void);
u32 zel_opening_audio_cue_serial(void);

#endif
