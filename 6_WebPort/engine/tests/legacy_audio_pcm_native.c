#include "../audio/opening_audio.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    short *pcm = malloc(sizeof(short) * 2 * 65536);
    short *baseline = malloc(sizeof(short) * 2 * 65536);
    int ok = pcm != NULL && baseline != NULL;
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

    /* MT-32 music and SNDADLIB effects are separate hardware streams in the
     * release setup. Render the same score twice and prove that posting a cue
     * materially changes the audible PCM while MIDI music is active. */
    ok &= zel_opening_audio_set_backend(ZEL_AUDIO_MT32);
    ok &= zel_audio_play_music(ZEL_MUSIC_ZOPN);
    zel_opening_audio_tick(40);
    size_t baseline_frames = zel_opening_audio_read_pcm(baseline, 65536);
    zel_opening_audio_init();
    ok &= zel_audio_play_music(ZEL_MUSIC_ZOPN);
    zel_opening_audio_write_cue(0x1E);
    zel_opening_audio_tick(40);
    size_t cue_frames = zel_opening_audio_read_pcm(pcm, 65536);
    unsigned long long pcm_difference = 0;
    size_t compare_frames = baseline_frames < cue_frames
        ? baseline_frames : cue_frames;
    for (size_t i = 0; i < compare_frames * 2; ++i) {
        int difference = (int)pcm[i] - baseline[i];
        pcm_difference += difference < 0 ? (unsigned)-difference
                                         : (unsigned)difference;
    }
    const int mt32_sfx_audible = compare_frames > 0 &&
        pcm_difference > compare_frames * 100u;
    printf("legacy_audio_pcm:mt32_music_plus_sfx: %s frames=%zu diff=%llu\n",
           mt32_sfx_audible ? "PASS" : "FAIL", compare_frames,
           pcm_difference);
    ok &= mt32_sfx_audible;
    /* Invalid/unavailable selections are rejected without disturbing the
     * release default contract. */
    ok &= !zel_opening_audio_set_backend(99);
    puts(ok ? "VERDICT: PASS" : "VERDICT: FAIL");
    free(baseline);
    free(pcm);
    return ok ? 0 : 1;
}
