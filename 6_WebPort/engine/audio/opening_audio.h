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
void zel_opening_audio_write_cue(u8 cue);
u8 zel_opening_audio_take_cue(void);

#endif
