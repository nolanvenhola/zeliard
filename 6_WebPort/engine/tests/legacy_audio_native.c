#include "../audio/mscadlib_vm.h"
#include <stdio.h>
#include <stdlib.h>

static u8 *read_file(const char *path, size_t *size) {
    FILE *f = fopen(path, "rb"); long n; u8 *p;
    if (!f) return NULL;
    fseek(f, 0, SEEK_END); n = ftell(f); rewind(f);
    p = n > 0 ? malloc((size_t)n) : NULL;
    if (!p || fread(p, 1, (size_t)n, f) != (size_t)n) { free(p); p = NULL; n = 0; }
    fclose(f); *size = (size_t)n; return p;
}

static u32 hash_ports(const zel_audio_port_write_t *writes, size_t count) {
    u32 h = 2166136261u;
    for (size_t i = 0; i < count; ++i) {
        h = (h ^ (u8)writes[i].tick) * 16777619u;
        h = (h ^ (u8)(writes[i].tick >> 8)) * 16777619u;
        h = (h ^ (u8)writes[i].port) * 16777619u;
        h = (h ^ (u8)(writes[i].port >> 8)) * 16777619u;
        h = (h ^ writes[i].value) * 16777619u;
    }
    return h;
}

int main(void) {
    static const struct { const char *name, *music, *sfx; int mt; } cases[] = {
        { "mt32", "mscmt.drv", "sndadlib.drv", 1 },
        { "pcjr", "mscjr.drv", "sndjr.drv", 0 },
        { "speaker", "mscstd.drv", "sndstd.drv", 0 },
    };
    static const size_t music_counts[] = { 894, 785, 1558 };
    static const u32 music_hashes[] = { 0x666053d7u, 0x5911bbc2u, 0x70e5ca8au };
    static const unsigned fade_counts[] = { 801, 1009, 1009 };
    static const u8 fade_attenuation[] = { 0x00, 0xFF, 0xFF };
    static const size_t cue_counts[2][11] = {
        {105,119,148,132,141,200,46,46,46,46,46},
        {45,45,161,54,113,131,18,18,18,18,18}
    };
    static const u32 cue_hashes[2][11] = {
        {0x0d701b0au,0x17ba800au,0xcaffd7c9u,0x6d488887u,0x5165556bu,
         0x3080b150u,0xf2223117u,0x4b1badd3u,0xfdd2b6b7u,0x11a6d1d1u,0x341240e7u},
        {0xc3e941e3u,0xc8e07bfcu,0x6d68d9f7u,0xba9d0db9u,0x10cb84e5u,
         0x41ea9d79u,0x8372bbc4u,0x4391ace8u,0x61b7a3ffu,0xb5fa7cf3u,0x8036a631u}
    };
    zel_mscadlib_vm_t *vm = calloc(1, sizeof(*vm));
    zel_audio_port_write_t *writes = calloc(16384, sizeof(*writes));
    size_t bios_n = 0, score_n = 0;
    u8 *bios = read_file("assets/8086tiny-bios.bin", &bios_n);
    u8 *score = read_file("assets/zopn.msd", &score_n);
    int ok = vm && writes && bios && score;
    static const u8 cues[] = { 0x02, 0x04, 0x07, 0x09, 0x16, 0x1E,
                               0x3D, 0x3E, 0x3F, 0x40, 0x41 };
    for (size_t c = 0; ok && c < sizeof(cases)/sizeof(cases[0]); ++c) {
        size_t music_n = 0, sfx_n = 0;
        char path[64];
        snprintf(path, sizeof(path), "assets/%s", cases[c].music);
        u8 *music = read_file(path, &music_n);
        snprintf(path, sizeof(path), "assets/%s", cases[c].sfx);
        u8 *sfx = read_file(path, &sfx_n);
        int case_ok = music && sfx &&
            zel_mscadlib_vm_init_variant(vm, music, music_n, bios, bios_n, cases[c].mt) &&
            zel_mscadlib_vm_load_sfx_driver(vm, sfx, sfx_n) &&
            zel_mscadlib_vm_load_score(vm, score, score_n);
        for (unsigned tick = 0; case_ok && tick < 1024; ++tick)
            case_ok &= zel_mscadlib_vm_tick(vm);
        size_t count = zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
        u32 port_hash = hash_ports(writes, count);
        int music_match = case_ok && count == music_counts[c] &&
                          port_hash == music_hashes[c];
        printf("legacy_audio:%s:zopn_1024: %s writes=%zu hash=%08x complete=%02x\n",
               cases[c].name, music_match ? "PASS" : "FAIL", count,
               port_hash, zel_mscadlib_vm_global(vm, 0xFF26));
        ok &= music_match;
        case_ok = zel_mscadlib_vm_init_variant(vm, music, music_n, bios, bios_n,
            cases[c].mt) && zel_mscadlib_vm_load_score(vm, score, score_n);
        zel_mscadlib_vm_set_global(vm, 0xFF24, 8);
        unsigned fade_ticks = 0;
        while (case_ok && !zel_mscadlib_vm_global(vm, 0xFF26) && fade_ticks < 3000) {
            case_ok &= zel_mscadlib_vm_tick(vm);
            fade_ticks++;
        }
        int fade_match = case_ok && fade_ticks == fade_counts[c] &&
            zel_mscadlib_vm_global(vm, 0xFF24) == 0 &&
            zel_mscadlib_vm_global(vm, 0xFF25) == fade_attenuation[c] &&
            zel_mscadlib_vm_global(vm, 0xFF26) == 0xFF;
        printf("legacy_audio:%s:fade: %s ticks=%u globals=%02x/%02x/%02x\n",
            cases[c].name, fade_match ? "PASS" : "FAIL",
            fade_ticks, zel_mscadlib_vm_global(vm, 0xFF24),
            zel_mscadlib_vm_global(vm, 0xFF25),
            zel_mscadlib_vm_global(vm, 0xFF26));
        ok &= fade_match;
        if (c == 0) {
            /* MT-32 music still uses the release SNDADLIB effects driver.
             * This path was previously omitted from the cue matrix, allowing
             * working OPL writes to be mixed below audibility in the host. */
            for (size_t q = 0; q < sizeof(cues); ++q) {
                case_ok = zel_mscadlib_vm_init_variant(vm, music, music_n,
                    bios, bios_n, 1) &&
                    zel_mscadlib_vm_load_sfx_driver(vm, sfx, sfx_n);
                zel_mscadlib_vm_set_global(vm, 0xFF27, 0);
                case_ok &= zel_mscadlib_vm_tick(vm);
                (void)zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
                zel_mscadlib_vm_set_global(vm, 0xFF75, cues[q]);
                for (unsigned tick = 0; case_ok && tick < 256; ++tick)
                    case_ok &= zel_mscadlib_vm_tick(vm);
                count = zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
                size_t opl_writes = 0;
                for (size_t w = 0; w < count; ++w)
                    opl_writes += writes[w].port == 0x388 ||
                                  writes[w].port == 0x389;
                int cue_match = case_ok && opl_writes > 0 &&
                    zel_mscadlib_vm_global(vm, 0xFF75) == 0;
                printf("legacy_audio:mt32:cue_%02x: %s opl_writes=%zu "
                       "mailbox=%02x\n", cues[q],
                       cue_match ? "PASS" : "FAIL", opl_writes,
                       zel_mscadlib_vm_global(vm, 0xFF75));
                ok &= cue_match;
            }
        } else {
            for (size_t q = 0; q < sizeof(cues); ++q) {
                case_ok = zel_mscadlib_vm_init_variant(vm, music, music_n,
                    bios, bios_n, 0) &&
                    zel_mscadlib_vm_load_sfx_driver(vm, sfx, sfx_n);
                zel_mscadlib_vm_set_global(vm, 0xFF27, 0);
                case_ok &= zel_mscadlib_vm_tick(vm);
                (void)zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
                zel_mscadlib_vm_set_global(vm, 0xFF75, cues[q]);
                for (unsigned tick = 0; case_ok && tick < 256; ++tick)
                    case_ok &= zel_mscadlib_vm_tick(vm);
                count = zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
                port_hash = hash_ports(writes, count);
                int cue_match = case_ok && count == cue_counts[c - 1][q] &&
                    port_hash == cue_hashes[c - 1][q] &&
                    zel_mscadlib_vm_global(vm, 0xFF75) == 0;
                printf("legacy_audio:%s:cue_%02x: %s writes=%zu hash=%08x mailbox=%02x\n",
                    cases[c].name, cues[q], cue_match ? "PASS" : "FAIL",
                    count, port_hash,
                    zel_mscadlib_vm_global(vm, 0xFF75));
                ok &= cue_match;
            }
        }
        free(music); free(sfx);
    }
    static const char *mt_tracks[] = {
        "zend.msd","zopn.msd","mgt1.msd","mgt2.msd","ugm1.msd","ugm2.msd",
        "mus1.msd","mus2.msd","mus3.msd","mus4.msd","mus5.msd","mus6.msd",
        "mbos.msd","mfan.msd"
    };
    static const size_t mt_track_counts[] = {
        357,379,247,256,378,203,351,327,346,356,496,302,258,278
    };
    static const u32 mt_track_hashes[] = {
        0xcf45fa34u,0xe3d9d5c4u,0xac6a1fe1u,0xe0fdb304u,
        0xfbcecf2au,0xdce66b76u,0xe5b571b4u,0x2dcbe260u,
        0xd1108033u,0x55d54975u,0x770da94fu,0x2ba2c363u,
        0x3bd7511bu,0xe25f5794u
    };
    size_t mt_music_n = 0;
    u8 *mt_music = read_file("assets/mscmt.drv", &mt_music_n);
    for (size_t t = 0; ok && t < sizeof(mt_tracks)/sizeof(mt_tracks[0]); ++t) {
        char path[64]; size_t track_n = 0;
        snprintf(path, sizeof(path), "assets/%s", mt_tracks[t]);
        u8 *track = read_file(path, &track_n);
        int track_ok = track && mt_music &&
            zel_mscadlib_vm_init_variant(vm, mt_music, mt_music_n, bios, bios_n, 1) &&
            zel_mscadlib_vm_load_score(vm, track, track_n);
        for (unsigned tick = 0; track_ok && tick < 256; ++tick)
            track_ok &= zel_mscadlib_vm_tick(vm);
        size_t count = zel_mscadlib_vm_take_port_writes(vm, writes, 16384);
        u32 port_hash = hash_ports(writes, count);
        int checkpoint = track_ok && count == mt_track_counts[t] &&
                         port_hash == mt_track_hashes[t];
        printf("legacy_audio:mt32:%s_256: %s writes=%zu hash=%08x\n",
            mt_tracks[t], checkpoint ? "PASS" : "FAIL", count, port_hash);
        ok &= checkpoint;
        free(track);
    }
    free(mt_music);
    puts(ok ? "VERDICT: PASS" : "VERDICT: FAIL");
    free(vm); free(writes); free(bios); free(score);
    return ok ? 0 : 1;
}
