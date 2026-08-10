#include "../audio/opening_audio.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    short *pcm = malloc(sizeof(short) * 2 * 65536);
    int ok = pcm != NULL;
    zel_opening_audio_init();
    for (int backend = ZEL_AUDIO_MT32; ok && backend <= ZEL_AUDIO_SPEAKER; ++backend) {
        ok &= zel_opening_audio_set_backend(backend);
        ok &= zel_opening_audio_backend() == backend;
        ok &= !zel_opening_audio_backend_fallback();
        ok &= zel_audio_play_music(ZEL_MUSIC_ZOPN);
        zel_opening_audio_tick(backend == ZEL_AUDIO_SPEAKER ? 5000 : 250);
        size_t frames = zel_opening_audio_read_pcm(pcm, 65536);
        unsigned peak = 0;
        for (size_t i = 0; i < frames * 2; ++i) {
            unsigned magnitude = pcm[i] < 0 ? (unsigned)-(int)pcm[i] : (unsigned)pcm[i];
            if (magnitude > peak) peak = magnitude;
        }
        unsigned generated_peak = zel_opening_audio_generated_peak();
        printf("legacy_audio_pcm:backend_%d: %s frames=%zu peak=%u generated=%u\n",
               backend, frames && generated_peak ? "PASS" : "FAIL", frames, peak,
               generated_peak);
        ok &= frames == ZEL_AUDIO_PCM_CUSHION_FRAMES && generated_peak > 0;
        zel_opening_audio_begin_gameplay_transition_fade();
        for (unsigned ms = 0; ms < 5000 && !zel_opening_audio_ready_for_transition(); ++ms)
            zel_opening_audio_tick(1);
        printf("legacy_audio_pcm:backend_%d_fade: %s attenuation=%d\n",
               backend, zel_opening_audio_ready_for_transition() ? "PASS" : "FAIL",
               zel_opening_audio_attenuation());
        ok &= zel_opening_audio_ready_for_transition();
        zel_opening_audio_stop();
    }
    /* Invalid/unavailable selections are rejected without disturbing the
     * release default contract. */
    ok &= !zel_opening_audio_set_backend(99);
    puts(ok ? "VERDICT: PASS" : "VERDICT: FAIL");
    free(pcm);
    return ok ? 0 : 1;
}
