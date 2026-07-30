#include "../render/town_mcga.h"

#include <stdio.h>
#include <stdlib.h>

static u8 *read_paths(const char *const *paths, size_t path_count, size_t *size) {
    for (size_t i = 0; i < path_count; ++i) {
        FILE *file = fopen(paths[i], "rb");
        if (!file) continue;
        fseek(file, 0, SEEK_END);
        long length = ftell(file);
        fseek(file, 0, SEEK_SET);
        u8 *data = length > 0 ? (u8 *)malloc((size_t)length) : NULL;
        if (data && fread(data, 1, (size_t)length, file) == (size_t)length) {
            fclose(file);
            *size = (size_t)length;
            return data;
        }
        fclose(file);
        free(data);
    }
    return NULL;
}

static u8 *read_gt_chunk(size_t *size) {
    static const char *const paths[] = {
        "assets/gtmcga.bin",
        "../../3_Assembly/masm/bin/zelres1/111GTMCA.bin",
        "3_Assembly/masm/bin/zelres1/111GTMCA.bin",
    };
    return read_paths(paths, sizeof(paths) / sizeof(paths[0]), size);
}

static u8 *read_gm_driver(size_t *size) {
    static const char *const paths[] = {
        "../../3_Assembly/masm/working/drivers/gmmcga.bin",
        "3_Assembly/masm/working/drivers/gmmcga.bin",
    };
    return read_paths(paths, sizeof(paths) / sizeof(paths[0]), size);
}

int main(void) {
    static const u16 slots[] = {
        0x3002, 0x3004, 0x3006, 0x3008, 0x300A, 0x300C, 0x300E,
        0x3010, 0x3012, 0x3014, 0x3018, 0x301A, 0x301C, 0x301E,
        0x3020, 0x3024, 0x3026,
    };
    static const u16 targets[] = {
        0x3028, 0x3051, 0x3628, 0x3677, 0x36A4, 0x36F1, 0x32FC,
        0x3526, 0x359A, 0x34EC, 0x3785, 0x3805, 0x37CC, 0x3999,
        0x39EF, 0x3AF9, 0x3A71,
    };
    size_t chunk_size = 0;
    u8 *chunk = read_gt_chunk(&chunk_size);
    zeliard_gtmcga_dispatch_t dispatch[17];
    const size_t count = zeliard_gtmcga_resolve_town_dispatch(
        chunk, chunk_size, dispatch, sizeof(dispatch) / sizeof(dispatch[0]));
    int ok = count == 17;
    unsigned total_calls = 0;
    for (size_t i = 0; i < count; ++i) {
        const int entry_ok = dispatch[i].slot == slots[i] &&
            dispatch[i].target == targets[i] && dispatch[i].name;
        printf("town_gt_dispatch:%04X: %s target=%04X calls=%u name=%s\n",
               slots[i], entry_ok ? "PASS" : "FAIL", dispatch[i].target,
               dispatch[i].town_call_count, dispatch[i].name);
        total_calls += dispatch[i].town_call_count;
        ok &= entry_ok;
    }
    ok &= total_calls == 31;
    free(chunk);

    static const u16 gm_slots[] = {
        0x2000, 0x2002, 0x2004, 0x2006, 0x2008, 0x200E, 0x2010,
        0x2012, 0x2014, 0x2016, 0x2018, 0x201A, 0x2022, 0x2024,
        0x2026, 0x2028, 0x202A, 0x2038, 0x2040, 0x2042,
    };
    static const u16 gm_targets[] = {
        0x2046, 0x2106, 0x2195, 0x2227, 0x2256, 0x22BF, 0x22CD,
        0x2385, 0x238F, 0x23AC, 0x23CC, 0x23F5, 0x27E9, 0x2857,
        0x289A, 0x28D9, 0x291A, 0x22DB, 0x2130, 0x2C01,
    };
    size_t driver_size = 0;
    u8 *driver = read_gm_driver(&driver_size);
    zeliard_gmmcga_dispatch_t gm_dispatch[20];
    const size_t gm_count = zeliard_gmmcga_resolve_town_dispatch(
        driver, driver_size, gm_dispatch,
        sizeof(gm_dispatch) / sizeof(gm_dispatch[0]));
    ok &= gm_count == 20;
    unsigned gm_total_calls = 0;
    for (size_t i = 0; i < gm_count; ++i) {
        const int entry_ok = gm_dispatch[i].slot == gm_slots[i] &&
            gm_dispatch[i].target == gm_targets[i] && gm_dispatch[i].name;
        printf("town_gm_dispatch:%04X: %s target=%04X calls=%u name=%s\n",
               gm_slots[i], entry_ok ? "PASS" : "FAIL", gm_dispatch[i].target,
               gm_dispatch[i].town_call_count, gm_dispatch[i].name);
        gm_total_calls += gm_dispatch[i].town_call_count;
        ok &= entry_ok;
    }
    ok &= gm_total_calls == 54;
    free(driver);

    printf("VERDICT: %s: 106TOWN reached MCGA dispatch tables\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
