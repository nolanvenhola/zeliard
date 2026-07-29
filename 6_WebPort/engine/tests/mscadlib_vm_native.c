#include "../audio/mscadlib_vm.h"

#include <stdio.h>
#include <stdlib.h>

static u8 *read_file(const char *path, size_t *size) {
    FILE *file = fopen(path, "rb");
    long length;
    u8 *data;

    if (!file)
        return NULL;
    fseek(file, 0, SEEK_END);
    length = ftell(file);
    rewind(file);
    data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data);
        data = NULL;
        length = 0;
    }
    fclose(file);
    *size = (size_t)length;
    return data;
}

static u32 hash_writes(const zel_opl_write_t *writes, size_t count) {
    u32 hash = 2166136261u;
    for (size_t i = 0; i < count; ++i) {
        hash = (hash ^ (u8)writes[i].tick) * 16777619u;
        hash = (hash ^ (u8)(writes[i].tick >> 8)) * 16777619u;
        hash = (hash ^ writes[i].reg) * 16777619u;
        hash = (hash ^ writes[i].value) * 16777619u;
    }
    return hash;
}

int main(void) {
    zel_mscadlib_vm_t vm;
    zel_opl_write_t writes[16384];
    size_t driver_size = 0, sfx_driver_size = 0, bios_size = 0;
    size_t score_size = 0, score2_size = 0;
    u8 *driver = read_file("assets/mscadlib.drv", &driver_size);
    u8 *sfx_driver = read_file("assets/sndadlib.drv", &sfx_driver_size);
    u8 *bios = read_file("assets/8086tiny-bios.bin", &bios_size);
    u8 *score = read_file("assets/zend.msd", &score_size);
    u8 *score2 = read_file("assets/zopn.msd", &score2_size);
    size_t count;
    int ok = driver && sfx_driver && bios && score && score2;

    if (!ok) {
        puts("mscadlib_vm:assets: INCONCLUSIVE");
        puts("VERDICT: INCONCLUSIVE");
        free(driver); free(sfx_driver); free(bios); free(score); free(score2);
        return 2;
    }
    ok &= zel_mscadlib_vm_init(&vm, driver, driver_size, bios, bios_size);
    ok &= zel_mscadlib_vm_load_score(&vm, score, score_size);
    for (unsigned i = 0; ok && i < 1024; ++i)
        ok &= zel_mscadlib_vm_tick(&vm);
    count = zel_mscadlib_vm_take_writes(&vm, writes,
                                        sizeof(writes) / sizeof(writes[0]));
    printf("mscadlib_vm:zend_1024_ticks: %s writes=%zu hash=%08x complete=%02x\n",
           ok && count == 1216 && hash_writes(writes, count) == 0xe956bdebu ?
               "PASS" : "FAIL", count,
           hash_writes(writes, count), zel_mscadlib_vm_global(&vm, 0xFF26));
    ok &= count == 1216 && hash_writes(writes, count) == 0xe956bdebu;

    ok &= zel_mscadlib_vm_init(&vm, driver, driver_size, bios, bios_size);
    ok &= zel_mscadlib_vm_load_score(&vm, score2, score2_size);
    for (unsigned i = 0; ok && i < 1024; ++i)
        ok &= zel_mscadlib_vm_tick(&vm);
    count = zel_mscadlib_vm_take_writes(&vm, writes,
                                        sizeof(writes) / sizeof(writes[0]));
    printf("mscadlib_vm:zopn_1024_ticks: %s writes=%zu hash=%08x complete=%02x\n",
           ok && count == 2232 && hash_writes(writes, count) == 0x92b90cdeu ?
               "PASS" : "FAIL", count, hash_writes(writes, count),
           zel_mscadlib_vm_global(&vm, 0xFF26));
    ok &= count == 2232 && hash_writes(writes, count) == 0x92b90cdeu;

    ok &= zel_mscadlib_vm_init(&vm, driver, driver_size, bios, bios_size);
    ok &= zel_mscadlib_vm_load_score(&vm, score, score_size);
    zel_mscadlib_vm_set_global(&vm, 0xFF24, 8);
    unsigned fade_ticks = 0;
    while (ok && !zel_mscadlib_vm_global(&vm, 0xFF26) && fade_ticks < 2000) {
        ok &= zel_mscadlib_vm_tick(&vm);
        fade_ticks++;
    }
    const int fade_match = fade_ticks == 1009 &&
        zel_mscadlib_vm_global(&vm, 0xFF24) == 0 &&
        zel_mscadlib_vm_global(&vm, 0xFF25) == 0xFF &&
        zel_mscadlib_vm_global(&vm, 0xFF26) == 0xFF;
    printf("mscadlib_vm:credits_fade: %s ticks=%u globals=%02x/%02x/%02x\n",
           fade_match ? "PASS" : "FAIL", fade_ticks,
           zel_mscadlib_vm_global(&vm, 0xFF24),
           zel_mscadlib_vm_global(&vm, 0xFF25),
           zel_mscadlib_vm_global(&vm, 0xFF26));
    ok &= fade_match;

    static const u8 sfx_cues[] = { 0x02, 0x04, 0x3D, 0x3E, 0x3F, 0x40, 0x41 };
    static const size_t sfx_write_counts[] = { 95, 122, 83, 83, 83, 83, 83 };
    static const u32 sfx_write_hashes[] = {
        0xa57a52a3u, 0xe4c9b1d6u, 0xd00c874eu, 0x7bebfd22u,
        0x6a9f3432u, 0x28076aebu, 0xdb93e6a7u
    };
    for (size_t cue_index = 0; cue_index < sizeof(sfx_cues); ++cue_index) {
        int cue_ok = zel_mscadlib_vm_init(&vm, driver, driver_size,
                                           bios, bios_size);
        cue_ok &= zel_mscadlib_vm_load_sfx_driver(&vm, sfx_driver,
                                                   sfx_driver_size);
        zel_mscadlib_vm_set_global(&vm, 0xFF27, 0);
        cue_ok &= zel_mscadlib_vm_tick(&vm);
        (void)zel_mscadlib_vm_take_writes(&vm, writes,
                                          sizeof(writes) / sizeof(writes[0]));
        zel_mscadlib_vm_set_global(&vm, 0xFF75, sfx_cues[cue_index]);
        for (unsigned i = 0; cue_ok && i < 256; ++i)
            cue_ok &= zel_mscadlib_vm_tick(&vm);
        count = zel_mscadlib_vm_take_writes(&vm, writes,
                                            sizeof(writes) / sizeof(writes[0]));
        const u32 write_hash = hash_writes(writes, count);
        const int cue_match = cue_ok && count == sfx_write_counts[cue_index] &&
            write_hash == sfx_write_hashes[cue_index] &&
            zel_mscadlib_vm_global(&vm, 0xFF75) == 0;
        printf("sndadlib_vm:cue_%02x_256_ticks: %s writes=%zu hash=%08x mailbox=%02x disabled=%02x\n",
               sfx_cues[cue_index], cue_match ? "PASS" : "FAIL", count, write_hash,
               zel_mscadlib_vm_global(&vm, 0xFF75),
               zel_mscadlib_vm_global(&vm, 0xFF27));
        ok &= cue_match;
    }
    puts(ok ? "VERDICT: PASS" : "VERDICT: FAIL");
    free(driver); free(sfx_driver); free(bios); free(score); free(score2);
    return ok ? 0 : 1;
}
