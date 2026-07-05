#include "../core/runtime.h"
#include "../core/timer.h"
#include "../render/palette.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint64_t fnv1a64(const uint8_t *data, size_t n) {
    uint64_t h = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < n; i++) {
        h ^= data[i];
        h *= 0x100000001B3ULL;
    }
    return h;
}

static int event_matches(const zel_proxy_event_t *e, zel_proxy_event_kind_t kind,
                         const char *asset, u16 ax, u16 bx, u16 cx, u16 si,
                         u16 di, u8 al, u8 cl) {
    if (e->kind != kind)
        return 0;
    if (asset != NULL && (e->asset == NULL || strcmp(e->asset, asset) != 0))
        return 0;
    if (asset == NULL && e->asset != NULL)
        return 0;
    return e->ax == ax && e->bx == bx && e->cx == cx && e->si == si &&
           e->di == di && e->al == al && e->cl == cl;
}

static int run_runtime_input_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    zel_runtime_key_down(&rt, 32);
    zel_runtime_key_down(&rt, 13);
    int ok = rt.mem[ZEL_GVAR_SPACEBAR_STATE] == 0xFF &&
             rt.mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY;
    zel_runtime_keyboard_clear_opening_skip(&rt, "test");
    ok &= rt.mem[ZEL_GVAR_SPACEBAR_STATE] == 0 &&
          rt.mem[ZEL_GVAR_ENTER_KEY] == 0;
    printf("runtime_keyboard_proxy: %s space=%02x enter=%02x events=%llu\n",
           ok ? "PASS" : "FAIL",
           rt.mem[ZEL_GVAR_SPACEBAR_STATE],
           rt.mem[ZEL_GVAR_ENTER_KEY],
           (unsigned long long)rt.log.count);
    return ok;
}

static int run_timer_rate_case(void) {
    int ok = 1;
    ok &= zel_timer_ticks_to_ms(1) == 4;
    ok &= zel_timer_ticks_to_ms(0x10) == 68;
    ok &= zel_timer_ticks_to_ms(0x1C) == 118;
    ok &= zel_timer_ticks_to_ms(0x50) == 338;
    ok &= zel_timer_ticks_to_ms(0xF0) == 1014;
    ok &= zel_timer_ms_to_ticks(1000) == 237;

    u32 accum = 0;
    ok &= zel_timer_advance_ms(&accum, 4) == 0;
    ok &= zel_timer_advance_ms(&accum, 4) == 1;
    ok &= zel_timer_advance_ms(&accum, 8) == 2;

    zel_runtime_t rt;
    zel_runtime_init(&rt);
    zel_runtime_tick(&rt, 5);
    ok &= rt.mem[ZEL_GVAR_FRAME_TIMER] == 1;
    zel_runtime_timer_wait(&rt, "test", 0x1C);
    ok &= rt.mem[ZEL_GVAR_FRAME_TIMER] == 0;

    printf("runtime_timer_rate: %s ms=%u/%u/%u/%u ticks1000=%u frame=%02x\n",
           ok ? "PASS" : "FAIL",
           zel_timer_ticks_to_ms(0x10),
           zel_timer_ticks_to_ms(0x1C),
           zel_timer_ticks_to_ms(0x50),
           zel_timer_ticks_to_ms(0xF0),
           zel_timer_ms_to_ticks(1000),
           rt.mem[ZEL_GVAR_FRAME_TIMER]);
    return ok;
}

static int run_opdmo_title_span_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);

    ok &= rt.regs.sp == 0x2000;
    ok &= rt.mem[ZEL_GVAR_SPACEBAR_STATE] == 0;
    ok &= rt.mem[ZEL_GVAR_ENTER_KEY] == 0;
    ok &= rt.log.count == 7;
    ok &= !rt.log.overflowed;

    if (rt.log.count == 7) {
        ok &= event_matches(&rt.log.events[0], ZEL_PROXY_KEYBOARD_CLEAR,
                            NULL, 0, 0, 0, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[1], ZEL_PROXY_VGA_INIT,
                            NULL, 0, 0, 0, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[2], ZEL_PROXY_ASSET_LOAD,
                            "ttl3.grp", 0, 0, 0, 0, ZEL_GFX_PLANE_B, 2, 0);
        ok &= rt.log.events[2].size > 0;
        ok &= rt.mem[ZEL_GFX_PLANE_B] != 0 || rt.mem[ZEL_GFX_PLANE_B + 1] != 0;
        ok &= event_matches(&rt.log.events[3], ZEL_PROXY_DECODE_RLE,
                            NULL, 0, 0, 0, ZEL_GFX_PLANE_B,
                            ZEL_FRAMEBUFFER_A, 0, 0);
        ok &= event_matches(&rt.log.events[4], ZEL_PROXY_VGA_PALETTE,
                            NULL, 4, 0, 0, 0, 0, 4, 0);
        ok &= event_matches(&rt.log.events[5], ZEL_PROXY_TEXT_DRAW,
                            NULL, 0, 0x0000, 0, 0x64EA, 0, 0, 0x96);
        ok &= event_matches(&rt.log.events[6], ZEL_PROXY_VGA_DRAW,
                            NULL, 0, 0x070F, 0x4170, 0,
                            ZEL_FRAMEBUFFER_A, 0, 0);
    }

    uint64_t pal = fnv1a64((const uint8_t *)zel_runtime_palette(&rt),
                           sizeof(g_palette));
    ok &= pal == 0xd9e89a4c32254f58ULL;
    printf("runtime_opdmo_title_span: %s events=%llu palette=%016llx\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)rt.log.count,
           (unsigned long long)pal);
    return ok;
}

int main(void) {
    int ok = 1;
    ok &= run_runtime_input_case();
    ok &= run_timer_rate_case();
    ok &= run_opdmo_title_span_case();
    printf("VERDICT: %s: MASM-shaped runtime parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
