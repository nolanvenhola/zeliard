#ifndef ZELIARD_OPENING_AUDIO_H
#define ZELIARD_OPENING_AUDIO_H

#include "../core/types.h"

typedef enum {
    ZEL_OPENING_MUSIC_NONE = 0,
    ZEL_OPENING_MUSIC_ZOPN = 1,
    ZEL_OPENING_MUSIC_ZEND = 2
} zel_opening_music_track_t;

void zel_opening_audio_init(void);
void zel_opening_audio_sync_phase(int phase);
void zel_opening_audio_stop(void);
int zel_opening_audio_music_track(void);
void zel_opening_audio_music_complete(int track);
void zel_opening_audio_begin_transition_fade(void);
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

#endif
