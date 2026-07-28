#include "opening_audio.h"

/* 100OPDMO release phase IDs. The proxy models the two places where MASM
 * loads a score and invokes INT 60h; unrelated phase changes leave the
 * currently loaded driver score alone. */
enum {
    OPDMO_PHASE_STAFF_CREDITS = 2,
    OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION = 22
};

static zel_opening_music_track_t g_music_track;
static unsigned char g_cue_mailbox;

void zel_opening_audio_init(void) {
    g_music_track = ZEL_OPENING_MUSIC_NONE;
    g_cue_mailbox = 0;
}

void zel_opening_audio_sync_phase(int phase) {
    if (phase == OPDMO_PHASE_TITLE_LOGO_COLOR_ROTATION)
        g_music_track = ZEL_OPENING_MUSIC_ZOPN;
    else if (phase == OPDMO_PHASE_STAFF_CREDITS)
        g_music_track = ZEL_OPENING_MUSIC_ZEND;
}

void zel_opening_audio_stop(void) {
    g_music_track = ZEL_OPENING_MUSIC_NONE;
}

int zel_opening_audio_music_track(void) {
    return (int)g_music_track;
}

void zel_opening_audio_write_cue(u8 cue) {
    g_cue_mailbox = cue;
}

u8 zel_opening_audio_take_cue(void) {
    u8 cue = g_cue_mailbox;
    g_cue_mailbox = 0;
    return cue;
}
