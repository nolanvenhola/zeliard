#include "../core/runtime.h"
#include "../core/framebuf.h"
#include "../core/timer.h"
#include "../render/palette.h"
#include "../render/mcga_render.h"
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
    zel_runtime_tick(&rt, 43);
    zel_runtime_key_down(&rt, 32);
    zel_runtime_key_down(&rt, 13);
    zel_runtime_tick(&rt, 22);
    int ok = rt.mem[ZEL_GVAR_SPACEBAR_STATE] == 0xFF &&
             rt.mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY;
    zel_runtime_key_up(&rt, 32);
    zel_runtime_key_up(&rt, 13);
    ok &= rt.mem[ZEL_GVAR_SPACEBAR_STATE] == 0xFF &&
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
    ok &= rt.mem[ZEL_GVAR_ANIM_TIMER] == 1 &&
          rt.mem[ZEL_GVAR_ANIM_TIMER + 1] == 0;
    ok &= rt.mem[ZEL_GVAR_FRAME_COUNT] == 1 &&
          rt.mem[ZEL_GVAR_FRAME_COUNT + 1] == 0;
    ok &= zel_runtime_mcga(&rt) == &rt.mcga;
    ok &= rt.mcga.frame_timer == rt.mem[ZEL_GVAR_FRAME_TIMER];
    const u32 subtick_before_wait = rt.timer_subtick_accum;
    ok &= zel_runtime_timer_wait(&rt, "test", 0x1C) == ZEL_RUNTIME_WAIT_PENDING;
    zel_runtime_tick(&rt, 200);
    ok &= rt.mem[ZEL_GVAR_FRAME_TIMER] >= 0x1C;
    ok &= zel_runtime_timer_wait(&rt, "test", 0x1C) == ZEL_RUNTIME_WAIT_READY;
    ok &= rt.mem[ZEL_GVAR_FRAME_TIMER] == 0;
    ok &= rt.mcga.frame_timer == 0;
    ok &= rt.timer_subtick_accum != 0 || subtick_before_wait == 0;
    ok &= rt.low_level_trace.interrupt_handler_cascade == 2;
    ok &= rt.low_level_trace.stick_exit_dlg_handler == 2;
    ok &= rt.low_level_trace.stick_pause_dlg_handler == 2;
    ok &= rt.low_level_trace.stick_joy_cal_handler == 2;
    ok &= rt.low_level_trace.stick_joy_detect_handler == 2;

    zel_runtime_key_down(&rt, 32);
    zel_runtime_tick(&rt, 22);
    rt.mem[ZEL_GVAR_FRAME_TIMER] = 0x7F;
    ok &= zel_runtime_timer_wait(&rt, "test", 0x1C) == ZEL_RUNTIME_WAIT_SKIPPED;
    ok &= rt.mem[ZEL_GVAR_FRAME_TIMER] == 0x7F;
    ok &= rt.low_level_trace.interrupt_handler_cascade == 2;

    zel_runtime_t transition_rt;
    zel_runtime_init(&transition_rt);
    transition_rt.mem[ZEL_GVAR_FRAME_TIMER] = 0x20;
    ok &= zel_runtime_scene_transition_wait(
              &transition_rt, "scene_transition_wait", 0x20) ==
          ZEL_RUNTIME_WAIT_READY;
    ok &= transition_rt.low_level_trace.interrupt_handler_cascade == 1;

    printf("runtime_timer_rate: %s ms=%u/%u/%u/%u ticks1000=%u frame=%02x cascade=%llu\n",
           ok ? "PASS" : "FAIL",
           zel_timer_ticks_to_ms(0x10),
           zel_timer_ticks_to_ms(0x1C),
           zel_timer_ticks_to_ms(0x50),
           zel_timer_ticks_to_ms(0xF0),
           zel_timer_ms_to_ticks(1000),
           rt.mem[ZEL_GVAR_FRAME_TIMER],
           (unsigned long long)rt.low_level_trace.interrupt_handler_cascade);
    return ok;
}

static int run_overlay_swap_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);

    for (size_t i = 0; i < 0x7000; i++) {
        rt.mem[0x3000 + i] = (u8)((i * 13u + 7u) & 0xFFu);
        rt.overlay_mem[0x9000 + i] = (u8)((i * 37u + 11u) & 0xFFu);
    }

    const uint64_t low_before = fnv1a64(&rt.mem[0x3000], 0x7000);
    const uint64_t high_before = fnv1a64(&rt.overlay_mem[0x9000], 0x7000);
    rt.mem[0x70] = 0x80;
    rt.mem[0x71] = 0x00;
    const u16 expected_target = 0x0080;
    const u16 target = zel_runtime_swap_overlay_blocks(&rt,
                                                        "stick:swap_overlay_blocks",
                                                        0x0070);
    const uint64_t low_after = fnv1a64(&rt.mem[0x3000], 0x7000);
    const uint64_t high_after = fnv1a64(&rt.overlay_mem[0x9000], 0x7000);
    int ok = low_after == high_before && high_after == low_before &&
             low_after == 0x76d5a1593e8d4325ULL &&
             high_after == 0xf4bbe72facf04325ULL &&
             target == expected_target && rt.log.count == 1 &&
             rt.log.events[0].kind == ZEL_PROXY_OVERLAY_SWAP &&
             rt.log.events[0].bx == 0x0070 &&
             rt.log.events[0].value == expected_target &&
             rt.log.events[0].size == 0x7000;
    printf("runtime_overlay_swap: %s target=%04x low=%016llx high=%016llx\n",
           ok ? "PASS" : "FAIL", target,
           (unsigned long long)low_after, (unsigned long long)high_after);
    return ok;
}

static int run_gmmcga_gfx_init_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    for (size_t i = 0; i < ZELIARD_FB_SIZE; i++) {
        g_framebuf[i] = (uint8_t)((i * 37u + 11u) & 0xFFu);
        rt.mcga.vga[i] = (uint8_t)((i * 19u + 3u) & 0xFFu);
    }

    zel_runtime_vga_init(&rt, "gmmcga:2c01");
    const uint64_t framebuffer = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    const uint64_t mcga_framebuffer = fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE);
    int ok = framebuffer == 0xdd14fcc6528cab25ULL &&
             mcga_framebuffer == 0xdd14fcc6528cab25ULL && rt.log.count == 1 &&
             rt.log.events[0].kind == ZEL_PROXY_VGA_INIT;
    printf("runtime_gmmcga_gfx_init: %s framebuffer=%016llx mcga=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)framebuffer,
           (unsigned long long)mcga_framebuffer);
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
        ok &= event_matches(&rt.log.events[6], ZEL_PROXY_VGA_DISP_NARR_CHAP3,
                            NULL, 0, 0x070F, 0x4170, 0,
                            ZEL_FRAMEBUFFER_A, 0, 0);
    }

    uint64_t pal = fnv1a64((const uint8_t *)zel_runtime_palette(&rt),
                           sizeof(g_palette));
    ok &= pal == 0x8499fcc0f156a055ULL;
    ok &= fnv1a64(rt.overlay_mem + ZEL_FRAMEBUFFER_A, 14578) ==
          0x5655ba7b7c59348fULL;
    printf("runtime_opdmo_title_span: %s events=%llu palette=%016llx\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)rt.log.count,
           (unsigned long long)pal);
    return ok;
}

static int run_opdmo_prelude_contract_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);
    int steps = 0;
    while (ok && !zel_opdmo_0200_prelude_finished(&rt)) {
        int advanced = zel_opdmo_0200_prelude_step(&rt);
        ok &= advanced == 1;
        if (rt.opdmo_prelude_step == 4 && rt.mcga.scan_waiting) {
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x1C)
                zel_runtime_tick(&rt, 4);
        }
        if (rt.opdmo_prelude_step == 8 && rt.opdmo_sprite_a_waiting) {
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x1E)
                zel_runtime_tick(&rt, 4);
        }
        if (rt.opdmo_prelude_step == 15 && rt.opdmo_scene_sprite_c_waiting) {
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x14)
                zel_runtime_tick(&rt, 4);
        }
        if (rt.opdmo_prelude_step == 16 && rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
                zel_runtime_tick(&rt, 4);
        if (rt.opdmo_prelude_step == 18 && rt.opdmo_sprite_b_waiting)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x14)
                zel_runtime_tick(&rt, 4);
        if (rt.opdmo_prelude_step == 19 && rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
                zel_runtime_tick(&rt, 4);
        if (rt.opdmo_prelude_step == 21 && rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x0F)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x0F)
                zel_runtime_tick(&rt, 4);
        if (rt.opdmo_prelude_step == 23 && rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
                zel_runtime_tick(&rt, 4);
        if (rt.opdmo_prelude_step == 34 && rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0xF0)
                zel_runtime_tick(&rt, 4);
        if (++steps > 800) {
            ok = 0;
            break;
        }
    }

    int steps_ok = steps == 695;
    int finished_ok = zel_opdmo_0200_prelude_finished(&rt);
    int volume_ok = rt.mem[0xFF75] == 0x3F;
    int scratch_ok = fnv1a64(rt.scratch_mem, 0x2CA0) == 0x7e5496f95d852ef4ULL;
    int log_ok = rt.log.count == 371 && !rt.log.overflowed;
    ok &= steps_ok && finished_ok && volume_ok && scratch_ok && log_ok;

    if (rt.log.count == 371) {
        ok &= event_matches(&rt.log.events[7], ZEL_PROXY_ASSET_LOAD,
                            "nec.grp", 0, 0, 0, 0, ZEL_GFX_PLANE_B, 2, 0);
        ok &= event_matches(&rt.log.events[8], ZEL_PROXY_ASSET_LOAD,
                            "hou.grp", 0, 0, 0, 0, 0xB800, 2, 0);
        ok &= event_matches(&rt.log.events[9], ZEL_PROXY_DECOMPRESS_IMAGE,
                            NULL, 0, 0, 0, ZEL_GFX_PLANE_B,
                            ZEL_FRAMEBUFFER_A, 0, 0);
        ok &= event_matches(&rt.log.events[10], ZEL_PROXY_VGA_INIT,
                            NULL, 0, 0, 0, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[11], ZEL_PROXY_KEYBOARD_CLEAR,
                            NULL, 0, 0, 0, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[12], ZEL_PROXY_VGA_PALETTE,
                            NULL, 1, 0, 0, 0, 0, 1, 0);
        ok &= event_matches(&rt.log.events[13], ZEL_PROXY_VGA_DRAW,
                            NULL, 0, 0x1220, 0x2C68, 0,
                            ZEL_FRAMEBUFFER_A, 0xFF, 0);
        ok &= event_matches(&rt.log.events[14], ZEL_PROXY_VGA_SCANLINE,
                            NULL, 0, 0, 0, 0x6FF0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[15], ZEL_PROXY_VGA_PALETTE,
                            NULL, 2, 0, 0, 0, 0, 2, 0);
        ok &= event_matches(&rt.log.events[16], ZEL_PROXY_VGA_UPDATE,
                            NULL, 0, 0x1220, 0x2C68, 0,
                            ZEL_FRAMEBUFFER_A, 0xFF, 0);
        ok &= event_matches(&rt.log.events[17], ZEL_PROXY_DECOMPRESS_IMAGE,
                            NULL, 0, 0, 0, 0xB800, 0x9000, 0, 0);
        ok &= event_matches(&rt.log.events[18], ZEL_PROXY_VGA_DISP_GAME,
                            NULL, 0, 0x2048, 0x1040, 0,
                            0x75A0, 0, 0);
        ok &= event_matches(&rt.log.events[19], ZEL_PROXY_SPRITE_DISPATCH,
                            NULL, 0, 0, 0, 0x9060, 0, 0, 0);
        ok &= event_matches(&rt.log.events[20], ZEL_PROXY_ASSET_LOAD,
                            "dmaou.grp", 0, 0, 0, 0, ZEL_GFX_PLANE_B, 2, 0);
        ok &= event_matches(&rt.log.events[21], ZEL_PROXY_DECOMPRESS_IMAGE,
                            NULL, 0, 0, 0, 0xA000, 0x97C0, 0, 0);
        ok &= event_matches(&rt.log.events[22], ZEL_PROXY_VGA_MODE,
                            NULL, 0, 0x1220, 0x2C68, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[23], ZEL_PROXY_VGA_PALETTE,
                            NULL, 3, 0, 0, 0, 0, 3, 0);
        ok &= event_matches(&rt.log.events[24], ZEL_PROXY_VGA_UPDATE,
                            NULL, 0, 0x1720, 0x2270, 0,
                            0x0000, 0xFF, 0);
        static const u8 sprite_c_al[] = {0, 0, 0, 1, 1, 0,
                                         0, 1, 1, 2, 2, 4};
        for (size_t i = 0; i < sizeof(sprite_c_al); i++) {
            const size_t dispatch = 25 + i * 2;
            ok &= event_matches(&rt.log.events[dispatch],
                                ZEL_PROXY_VGA_DISP_NARR_CHAP2,
                                NULL, 0, 0x1720, 0, 0, 0,
                                sprite_c_al[i], 0);
            ok &= event_matches(&rt.log.events[dispatch + 1],
                                ZEL_PROXY_TIMER_WAIT,
                                NULL, 0, 0, 0, 0, 0, 0x14, 0);
            ok &= rt.log.events[dispatch + 1].value == ZEL_RUNTIME_WAIT_READY;
        }
        ok &= rt.opdmo_scene_sprite_c_si == 0x912B;
        ok &= event_matches(&rt.log.events[49], ZEL_PROXY_TIMER_WAIT,
                            NULL, 0, 0, 0, 0, 0, 0xF0, 0);
        ok &= rt.log.events[49].value == ZEL_RUNTIME_WAIT_READY;
        size_t sprite_b_chap2 = 0, sprite_b_chap4 = 0, sprite_b_waits = 0;
        for (size_t i = 50; i < rt.log.count; i++) {
            const zel_proxy_event_t *e = &rt.log.events[i];
            if (e->kind == ZEL_PROXY_VGA_DISP_NARR_CHAP2 && e->bx == 0x1F70)
                sprite_b_chap2++;
            if (e->kind == ZEL_PROXY_VGA_DISP_NARR_CHAP4)
                sprite_b_chap4++;
            if (e->kind == ZEL_PROXY_TIMER_WAIT && e->al == 0x14)
                sprite_b_waits++;
        }
        ok &= sprite_b_chap2 == 38;
        ok &= sprite_b_chap4 == 176;
        ok &= sprite_b_waits == 91;
        ok &= rt.opdmo_sprite_b_si == 0x911E;
        ok &= rt.mem[0x653D] == 0x30 && rt.mem[0x653E] == 0x01;
        ok &= rt.mem[0x653F] == 0xA8;
        ok &= event_matches(&rt.log.events[355], ZEL_PROXY_TIMER_WAIT,
                            NULL, 0, 0, 0, 0, 0, 0xF0, 0);
        ok &= event_matches(&rt.log.events[356], ZEL_PROXY_VGA_DISP_NARR_CHAP2,
                            NULL, 0, 0x1720, 0, 0, 0, 2, 0);
        ok &= event_matches(&rt.log.events[357], ZEL_PROXY_TIMER_WAIT,
                            NULL, 0, 0, 0, 0, 0, 0x0F, 0);
        ok &= event_matches(&rt.log.events[358], ZEL_PROXY_VGA_DISP_NARR_CHAP2,
                            NULL, 0, 0x1720, 0, 0, 0, 3, 0);
        ok &= event_matches(&rt.log.events[359], ZEL_PROXY_TIMER_WAIT,
                            NULL, 0, 0, 0, 0, 0, 0xF0, 0);
        ok &= event_matches(&rt.log.events[360], ZEL_PROXY_VGA_JASHIIN_SPEECH,
                            NULL, 0, 0x0094, 0x501E, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[361], ZEL_PROXY_ASSET_LOAD,
                            "ttl1.grp", 0, 0, 0, 0, 0xA000, 2, 0);
        ok &= rt.mem[0xA000] != 0 || rt.mem[0xA001] != 0;
        ok &= event_matches(&rt.log.events[362], ZEL_PROXY_DECODE_RLE,
                            NULL, 0, 0, 0, 0xA000, 0x4000, 0, 0);
        ok &= fnv1a64(rt.overlay_mem + 0x4000, 0x4000) ==
              0x980744ecba9d37e1ULL;
        ok &= event_matches(&rt.log.events[363], ZEL_PROXY_ASSET_LOAD,
                            "ttl2.grp", 0, 0, 0, 0, 0xA000, 2, 0);
        ok &= event_matches(&rt.log.events[364], ZEL_PROXY_ASSET_LOAD,
                            "ttl3.grp", 0, 0, 0, 0, 0xB000, 2, 0);
        ok &= rt.mem[0xB000] != 0 || rt.mem[0xB001] != 0;
        ok &= event_matches(&rt.log.events[365], ZEL_PROXY_ASSET_LOAD,
                            "zopn.msd", 0, 0, 0, 0, 0x3000, 5, 0);
        ok &= event_matches(&rt.log.events[366], ZEL_PROXY_VGA_MODE,
                            NULL, 0, 0x1720, 0x2270, 0, 0, 0, 0);
        ok &= event_matches(&rt.log.events[367], ZEL_PROXY_VGA_PALETTE,
                            NULL, 4, 0, 0, 0, 0, 4, 0);
        ok &= event_matches(&rt.log.events[368], ZEL_PROXY_SOUND_COMMAND,
                            NULL, 0, 0, 0, 0x3000, 0, 0, 0);
        ok &= rt.log.events[369].kind == ZEL_PROXY_VGA_DISP_DRV_SEG_3;
        ok &= event_matches(&rt.log.events[370], ZEL_PROXY_TIMER_WAIT,
                            NULL, 0, 0, 0, 0, 0, 0xF0, 0);
    }

    printf("runtime_opdmo_prelude: %s steps=%d events=%llu volume=%02x scratch=%016llx\n",
           ok ? "PASS" : "FAIL", steps, (unsigned long long)rt.log.count,
           rt.mem[0xFF75],
           (unsigned long long)fnv1a64(rt.scratch_mem, 0x2CA0));
    return ok;
}

static int run_opdmo_animate_scanline_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_runtime_opdmo_begin_animate_scanline(&rt) == 0;
    unsigned draws = 0;
    int rc = -1;

    while (ok && draws <= 430u) {
        rc = zel_runtime_opdmo_advance_animate_scanline(&rt);
        if (rc == 0) {
            while (rt.mem[ZEL_GVAR_FRAME_TIMER] < 0x1C)
                zel_runtime_tick(&rt, 4);
        } else if (rc == 1) {
            draws++;
        } else {
            break;
        }
    }

    const uint64_t vga = fnv1a64(rt.mcga.vga, 0xFA00);
    const uint64_t work = fnv1a64(rt.mcga.work, sizeof(rt.mcga.work));
    ok &= rc == 2;
    ok &= draws == 430u;
    ok &= rt.mcga.scan_exit_frame == 0x78;
    ok &= vga == 0xDD14FCC6528CAB25ULL;
    ok &= work == 0xB65F2BB82806E676ULL;
    ok &= rt.log.count == 1 &&
          rt.log.events[0].kind == ZEL_PROXY_VGA_SCANLINE &&
          rt.log.events[0].si == 0x6FF0;
    printf("runtime_opdmo_animate_scanline: %s draws=%u exit=%u vga=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", draws, rt.mcga.scan_exit_frame,
           (unsigned long long)vga, (unsigned long long)work);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_title_render_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_runtime_opdmo_render_title(&rt, 16) == 0;
    const uint64_t visible = fnv1a64(rt.mcga.vga, 0xFA00);
    const uint64_t work = fnv1a64(rt.mcga.work, sizeof(rt.mcga.work));
    ok &= visible == 0x513E9EF6009064EAULL;
    ok &= rt.log.count == 1 &&
          rt.log.events[0].kind == ZEL_PROXY_VGA_DISP_NARR_CHAP3 &&
          rt.log.events[0].bx == 0x070F &&
          rt.log.events[0].cx == 0x4170 &&
          rt.log.events[0].di == ZEL_FRAMEBUFFER_A;
    printf("runtime_opdmo_title_render: %s visible=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)visible,
           (unsigned long long)work);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_nec_hou_memory_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_runtime_opdmo_prepare_nec_hou_handoff(&rt) == 0;
    const uint64_t mem_4000 = fnv1a64(rt.overlay_mem + 0x4000, 44u * 104u * 2u);
    const uint64_t mem_75a0 = fnv1a64(rt.overlay_mem + 0x75A0, 16u * 64u * 2u);
    const uint64_t mem_9000 = fnv1a64(rt.overlay_mem + 0x9000, 16u * 64u * 2u);
    const uint64_t mem_97c0 = fnv1a64(rt.overlay_mem + 0x97C0, 34u * 112u * 2u);
    ok &= mem_4000 == 0x37E229A1FF0277CBULL;
    ok &= mem_75a0 == 0xE031286249BA5435ULL;
    ok &= mem_9000 == 0xAE1C24DF5911F572ULL;
    ok &= mem_97c0 == 0xB066E9E800F20DA0ULL;
    ok &= rt.log.count == 0;
    printf("runtime_opdmo_nec_hou_memory: %s 4000=%016llx 75a0=%016llx 9000=%016llx 97c0=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)mem_4000,
           (unsigned long long)mem_75a0, (unsigned long long)mem_9000,
           (unsigned long long)mem_97c0);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_hou_disp_game_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_runtime_opdmo_prepare_nec_hou_handoff(&rt) == 0;
    memset(rt.mcga.vga, 0, sizeof(rt.mcga.vga));
    ok &= zel_runtime_opdmo_render_hou_disp_game(&rt) == 0;
    const uint64_t framebuffer = fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE);
    ok &= framebuffer == 0x9CCA3279AEBFEA37ULL;
    ok &= rt.log.count == 1 && rt.log.events[0].kind == ZEL_PROXY_VGA_DISP_GAME &&
          rt.log.events[0].bx == 0x2048 && rt.log.events[0].cx == 0x1040 &&
          rt.log.events[0].di == 0x75A0;
    printf("runtime_opdmo_hou_disp_game: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)framebuffer);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_nec_hou_gfx_update_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_runtime_opdmo_prepare_nec_hou_handoff(&rt) == 0;
    memset(rt.mcga.vga, 0, sizeof(rt.mcga.vga));
    zel_runtime_vga_update(&rt, "100OPDMO:hou:gfx_blit", 0xFF,
                           0x1220, 0x2C68, 0x4000);
    ok &= zel_runtime_opdmo_render_hou_disp_game(&rt) == 0;
    const uint64_t framebuffer = fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE);
    /* Release-MASM oracle: test_mcga_render_entries_oracle.py,
     * run_nec_hou_gfx_update_sequence. */
    ok &= framebuffer == 0x4BE8B5F202D287F9ULL;
    printf("runtime_opdmo_nec_hou_gfx_update: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)framebuffer);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_sprite_object_init_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);
    zel_runtime_sprite_dispatch(&rt, "100OPDMO:scene_sprite_a", 0x9060);
    const uint64_t objects = fnv1a64(rt.mcga.driver + 0xA000, 9u * 15u);
    /* Release-MASM oracle: test_mcga_sprite_object_init_oracle.py. */
    ok &= objects == 0xC21FE918B5101768ULL;
    ok &= rt.mcga.driver[0x4505] == 0 && rt.mcga.driver[0xFF1A] == 0;
    printf("runtime_opdmo_sprite_object_init: %s objects=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)objects);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_sprite_frame_prepare_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);
    zel_runtime_sprite_dispatch(&rt, "100OPDMO:scene_sprite_a", 0x9060);
    for (size_t i = 0; i < ZEL_SEG_SIZE; i++) {
        rt.overlay_mem[i] = (u8)((i * 17u + 29u) & 0xFFu);
        rt.mcga.vga[i] = (u8)((i * 37u + 11u) & 0xFFu);
    }
    memset(rt.mcga.work, 0, sizeof(rt.mcga.work));
    ok &= zeliard_mcga_sprite_frame_prepare(
        rt.mcga.driver, sizeof(rt.mcga.driver), rt.overlay_mem,
        sizeof(rt.overlay_mem), rt.mcga.work, sizeof(rt.mcga.work),
        rt.mcga.vga, sizeof(rt.mcga.vga)) == 0;
    const uint64_t objects = fnv1a64(rt.mcga.driver + 0xA000, 9u * 15u);
    const uint64_t vga = fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE);
    const uint64_t work = fnv1a64(rt.mcga.work, sizeof(rt.mcga.work));
    ok &= objects == 0x15198061EF16CC51ULL;
    ok &= vga == 0x74AA23386B36F366ULL;
    ok &= work == 0x879CFABB32DD5D25ULL;
    printf("runtime_opdmo_sprite_frame_prepare: %s objects=%016llx vga=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)objects,
           (unsigned long long)vga, (unsigned long long)work);
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_sprite_frame_restore_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);
    zel_runtime_sprite_dispatch(&rt, "100OPDMO:scene_sprite_a", 0x9060);
    for (size_t i = 0; i < ZEL_SEG_SIZE; i++) {
        rt.overlay_mem[i] = (u8)((i * 17u + 29u) & 0xFFu);
        rt.mcga.vga[i] = (u8)((i * 37u + 11u) & 0xFFu);
    }
    memset(rt.mcga.work, 0, sizeof(rt.mcga.work));
    ok &= zeliard_mcga_sprite_frame_prepare(
        rt.mcga.driver, sizeof(rt.mcga.driver), rt.overlay_mem,
        sizeof(rt.overlay_mem), rt.mcga.work, sizeof(rt.mcga.work),
        rt.mcga.vga, sizeof(rt.mcga.vga)) == 0;
    rt.mcga.driver[0xFF1A] = 0x1E;
    ok &= zeliard_mcga_sprite_frame_restore(
        rt.mcga.driver, sizeof(rt.mcga.driver), rt.mcga.work,
        sizeof(rt.mcga.work), rt.mcga.vga, sizeof(rt.mcga.vga)) == 0;
    ok &= rt.mcga.driver[0xFF1A] == 0;
    ok &= fnv1a64(rt.mcga.driver + 0xA000, 9u * 15u) == 0x15198061EF16CC51ULL;
    ok &= fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE) == 0x14BFB33D5A9CAF25ULL;
    ok &= fnv1a64(rt.mcga.work, sizeof(rt.mcga.work)) == 0x879CFABB32DD5D25ULL;
    ok &= zeliard_mcga_sprite_objects_active(rt.mcga.driver,
                                              sizeof(rt.mcga.driver));
    printf("runtime_opdmo_sprite_frame_restore: %s\n", ok ? "PASS" : "FAIL");
    zel_runtime_destroy(&rt);
    return ok;
}

static int run_opdmo_sprite_frame_wait_case(void) {
    zel_runtime_t rt;
    zel_runtime_init(&rt);
    int ok = zel_opdmo_0200_start_title_span(&rt);
    zel_runtime_sprite_dispatch(&rt, "100OPDMO:scene_sprite_a", 0x9060);
    for (size_t i = 0; i < ZEL_SEG_SIZE; i++) {
        rt.overlay_mem[i] = (u8)((i * 17u + 29u) & 0xFFu);
        rt.mcga.vga[i] = (u8)((i * 37u + 11u) & 0xFFu);
    }
    memset(rt.mcga.work, 0, sizeof(rt.mcga.work));
    ok &= zel_runtime_opdmo_advance_sprite_a(&rt) == 1;
    ok &= rt.opdmo_sprite_a_waiting && rt.mem[ZEL_GVAR_FRAME_TIMER] == 0;
    ok &= zel_runtime_opdmo_advance_sprite_a(&rt) == 0;
    rt.mem[ZEL_GVAR_FRAME_TIMER] = 0x1E;
    ok &= zel_runtime_opdmo_advance_sprite_a(&rt) == 1;
    ok &= !rt.opdmo_sprite_a_waiting && rt.mem[ZEL_GVAR_FRAME_TIMER] == 0;
    ok &= fnv1a64(rt.mcga.vga, ZELIARD_FB_SIZE) == 0x14BFB33D5A9CAF25ULL;
    printf("runtime_opdmo_sprite_frame_wait: %s\n", ok ? "PASS" : "FAIL");
    zel_runtime_destroy(&rt);
    return ok;
}

int main(void) {
    int ok = 1;
    ok &= run_runtime_input_case();
    ok &= run_timer_rate_case();
    ok &= run_overlay_swap_case();
    ok &= run_gmmcga_gfx_init_case();
    ok &= run_opdmo_title_span_case();
    ok &= run_opdmo_prelude_contract_case();
    ok &= run_opdmo_animate_scanline_case();
    ok &= run_opdmo_title_render_case();
    ok &= run_opdmo_nec_hou_memory_case();
    ok &= run_opdmo_hou_disp_game_case();
    ok &= run_opdmo_nec_hou_gfx_update_case();
    ok &= run_opdmo_sprite_object_init_case();
    ok &= run_opdmo_sprite_frame_prepare_case();
    ok &= run_opdmo_sprite_frame_restore_case();
    ok &= run_opdmo_sprite_frame_wait_case();
    printf("VERDICT: %s: MASM-shaped runtime parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
