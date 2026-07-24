#include "runtime.h"
#include "framebuf.h"
#include "timer.h"
#include "../load/grp.h"
#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/mcga_render.h"
#include <stdlib.h>
#include <string.h>

enum {
    OPDMO_SCENE_DATA_A = 0x64EA,
    OPDMO_LOAD_BASE = 0x5FFC,
    OPDMO_SCANLINE_STREAM = 0x6FF0,
};

static void mem_write_u16(u8 *mem, u16 off, u16 value) {
    mem[off] = (u8)(value & 0xFF);
    mem[(u16)(off + 1)] = (u8)(value >> 8);
}

static int runtime_load_opdmo_release(zel_runtime_t *rt) {
    if (rt->opdmo_release_loaded)
        return 1;
    size_t size = 0;
    u8 *data = platform_load_asset("100opdmo.bin", &size);
    if (!data || size > ZEL_SEG_SIZE - OPDMO_LOAD_BASE) {
        free(data);
        return 0;
    }
    memcpy(rt->mem + OPDMO_LOAD_BASE, data, size);
    free(data);
    rt->opdmo_release_loaded = 1;
    return 1;
}

static int runtime_load_mcga_release(zel_runtime_t *rt) {
    if (rt->mcga_release_loaded)
        return 1;
    size_t size = 0;
    u8 *data = platform_load_asset("105GDMCA.bin", &size);
    if (!data)
        data = platform_load_asset("105gdmca.bin", &size);
    if (!data || !zel_mcga_runtime_load_driver(&rt->mcga, data, size)) {
        free(data);
        return 0;
    }
    free(data);
    rt->mcga_release_loaded = 1;
    return 1;
}

static int runtime_load_opdmo_font(zel_runtime_t *rt) {
    return rt->opdmo_font.data || zeliard_font_load(&rt->opdmo_font);
}

static u16 read_le16(const u8 *mem, u16 off) {
    return (u16)(mem[off] | ((u16)mem[(u16)(off + 1)] << 8));
}

static u8 rol8(u8 value, u8 *carry) {
    *carry = (u8)(value >> 7);
    return (u8)((value << 1) | *carry);
}

static u8 rcl8(u8 value, u8 *carry) {
    u8 next_carry = (u8)(value >> 7);
    u8 result = (u8)((value << 1) | *carry);
    *carry = next_carry;
    return result;
}

/* Mechanical C translation of 100OPDMO:decompress_image.  It operates in
 * the game segment and intentionally mutates the source control bytes just
 * as the rotate-through-carry loop does in release MASM. */
static int opdmo_decompress_image(u8 *source_mem, u8 *dest_mem,
                                  u16 source_base, u16 dest_base) {
    u16 si = source_base;
    u16 di = dest_base;
    u16 cx = read_le16(source_mem, si);
    u16 bp = (u16)(si + 2);
    si = (u16)(bp + cx);

    for (u16 row = 0; row < cx; row++) {
        u8 al = 0;
        for (int bit = 0; bit < 8; bit++) {
            u8 carry = 0;
            source_mem[bp] = rol8(source_mem[bp], &carry);
            dest_mem[di++] = carry ? source_mem[si++] : al;
        }
        bp++;
    }

    u16 count = (u16)(cx * 8u);
    di = dest_base;
    u8 dh = 0;
    for (u16 index = 0; index < count; index++) {
        u8 value = dest_mem[di];
        u8 ah = 0;
        for (int group = 0; group < 4; group++) {
            u8 carry = 0;
            u8 al = 0;
            value = rcl8(value, &carry);
            u16 doubled = (u16)al * 2u + carry;
            al = (u8)doubled;
            carry = (u8)(doubled >> 8);
            value = rcl8(value, &carry);
            doubled = (u16)al * 2u + carry;
            al = (u8)doubled;
            dh ^= al;
            ah = group == 0 ? dh : (u8)((ah << 2) | dh);
        }
        dest_mem[di++] = ah;
    }
    return count;
}

static int runtime_load_fill_buffer_asset(u8 *mem, const char *asset, u16 dest) {
    size_t file_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    size_t payload_size = 0;
    u8 *payload = file ? fill_buffer_decompress(file, file_size, &payload_size) : NULL;
    free(file);
    if (!payload || payload_size > (size_t)(ZEL_SEG_SIZE - dest)) {
        free(payload);
        return 0;
    }
    memcpy(mem + dest, payload, payload_size);
    free(payload);
    return 1;
}

static int runtime_decode_6de1_asset_to_overlay(zel_runtime_t *rt,
                                                 const char *asset, u16 dest) {
    size_t file_size = 0, decoded_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    u8 *decoded = file ? grp_decode_6de1_planes(file, file_size, &decoded_size) : NULL;
    free(file);
    if (!decoded || decoded_size > (size_t)(ZEL_SEG_SIZE - dest)) {
        free(decoded);
        return 0;
    }
    memcpy(rt->overlay_mem + dest, decoded, decoded_size);
    free(decoded);
    return 1;
}

static int runtime_load_nec_hou_sources(zel_runtime_t *rt) {
    return rt && runtime_load_fill_buffer_asset(rt->mem, "nec.grp", 0xA000) &&
           runtime_load_fill_buffer_asset(rt->mem, "hou.grp", 0xB800);
}

static int runtime_decompress_nec(zel_runtime_t *rt) {
    return rt && opdmo_decompress_image(rt->mem, rt->overlay_mem,
                                        0xA000, 0x4000) >= 0;
}

static int runtime_decompress_hou(zel_runtime_t *rt) {
    return rt && opdmo_decompress_image(rt->mem, rt->overlay_mem,
                                        0xB800, 0x9000) >= 0;
}

static void opdmo_palette_copy_rect(u8 *dst, const u8 *src, u16 *si,
                                    u16 bx, u16 cx, int font_row) {
    const u8 width = (u8)(cx >> 8);
    const u8 rows = (u8)cx;
    u16 di = (u16)((u16)0x22u * (u8)bx + (u8)(bx >> 8));
    if (font_row)
        di = (u16)(di + 0x0EE0u);
    for (u8 row = 0; row < rows; row++) {
        for (u8 col = 0; col < width; col++)
            dst[(u16)(di + col)] = src[(*si)++];
        di = (u16)(di + 0x22u);
    }
}

static void log_event(zel_runtime_t *rt, zel_proxy_event_t event) {
    if (!rt)
        return;
    if (rt->log.count >= sizeof(rt->log.events) / sizeof(rt->log.events[0])) {
        rt->log.overflowed = 1;
        return;
    }
    rt->log.events[rt->log.count++] = event;
}

void zel_runtime_init(zel_runtime_t *rt) {
    if (!rt)
        return;
    memset(rt, 0, sizeof(*rt));
    rt->regs.cs = 0;
    rt->regs.ds = 0;
    rt->regs.es = 0;
    rt->regs.ss = 0;
    rt->regs.sp = 0x2000;
    mem_write_u16(rt->mem, ZEL_GVAR_GAME_SEG, 0);
    zel_mcga_runtime_init(&rt->mcga);
    framebuf_clear(0);
    palette_set_scene(PALETTE_OPENING);
}

void zel_runtime_destroy(zel_runtime_t *rt) {
    if (!rt)
        return;
    zeliard_font_free(&rt->opdmo_font);
    rt->opdmo_scanline_started = 0;
}

int zel_runtime_load_chunk(zel_runtime_t *rt, const char *asset, u8 al, u16 dest) {
    if (!rt || !asset)
        return 0;

    size_t size = 0;
    u8 *data = platform_load_asset(asset, &size);
    if (!data) {
        log_event(rt, (zel_proxy_event_t){
                          .kind = ZEL_PROXY_ASSET_LOAD,
                          .source = "zel_runtime_load_chunk",
                          .asset = asset,
                          .al = al,
                          .di = dest,
                          .value = 0,
                      });
        return 0;
    }

    size_t max_copy = ZEL_SEG_SIZE - dest;
    size_t copy_size = size < max_copy ? size : max_copy;
    memcpy(&rt->mem[dest], data, copy_size);
    free(data);

    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_ASSET_LOAD,
                      .source = "LOAD_DATA",
                      .asset = asset,
                      .al = al,
                      .di = dest,
                      .es = rt->regs.es,
                      .value = copy_size == size,
                      .size = size,
                  });
    return copy_size == size;
}

void zel_runtime_tick(zel_runtime_t *rt, u32 dt_ms) {
    if (!rt)
        return;
    const u32 ticks = zel_timer_advance_ms(&rt->timer_subtick_accum, dt_ms);
    rt->mem[ZEL_GVAR_FRAME_TIMER] =
        (u8)(rt->mem[ZEL_GVAR_FRAME_TIMER] + (u8)ticks);
    const u16 anim_timer = (u16)(rt->mem[ZEL_GVAR_ANIM_TIMER] |
                                  ((u16)rt->mem[ZEL_GVAR_ANIM_TIMER + 1] << 8));
    const u16 frame_count = (u16)(rt->mem[ZEL_GVAR_FRAME_COUNT] |
                                   ((u16)rt->mem[ZEL_GVAR_FRAME_COUNT + 1] << 8));
    const u16 next_anim_timer = (u16)(anim_timer + ticks);
    const u16 next_frame_count = (u16)(frame_count + ticks);
    rt->mem[ZEL_GVAR_ANIM_TIMER] = (u8)next_anim_timer;
    rt->mem[ZEL_GVAR_ANIM_TIMER + 1] = (u8)(next_anim_timer >> 8);
    rt->mem[ZEL_GVAR_FRAME_COUNT] = (u8)next_frame_count;
    rt->mem[ZEL_GVAR_FRAME_COUNT + 1] = (u8)(next_frame_count >> 8);
    (void)zel_mcga_runtime_tick(&rt->mcga, dt_ms);
    rt->timer_ms += dt_ms;
}

void zel_runtime_key_down(zel_runtime_t *rt, int keycode) {
    if (!rt)
        return;
    if (keycode == 32)
        rt->mem[ZEL_GVAR_SPACEBAR_STATE] = 0xFF;
    if (keycode == ZEL_ENTER_KEY)
        rt->mem[ZEL_GVAR_ENTER_KEY] = ZEL_ENTER_KEY;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_KEYBOARD_KEY_DOWN,
                      .source = "zel_runtime_key_down",
                      .value = (u32)keycode,
                  });
}

void zel_runtime_key_up(zel_runtime_t *rt, int keycode) {
    if (!rt)
        return;
    if (keycode == 32)
        rt->mem[ZEL_GVAR_SPACEBAR_STATE] = 0;
    if (keycode == ZEL_ENTER_KEY)
        rt->mem[ZEL_GVAR_ENTER_KEY] = 0;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_KEYBOARD_KEY_UP,
                      .source = "zel_runtime_key_up",
                      .value = (u32)keycode,
                  });
}

u8 *zel_runtime_framebuffer(zel_runtime_t *rt) {
    (void)rt;
    return g_framebuf;
}

palette_color_t *zel_runtime_palette(zel_runtime_t *rt) {
    (void)rt;
    return g_palette;
}

zel_mcga_runtime_t *zel_runtime_mcga(zel_runtime_t *rt) {
    return rt ? &rt->mcga : NULL;
}

void zel_runtime_keyboard_clear_opening_skip(zel_runtime_t *rt, const char *source) {
    if (!rt)
        return;
    rt->mem[ZEL_GVAR_SPACEBAR_STATE] = 0;
    rt->mem[ZEL_GVAR_ENTER_KEY] = 0;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_KEYBOARD_CLEAR,
                      .source = source,
                  });
}

void zel_runtime_vga_init(zel_runtime_t *rt, const char *source) {
    if (!rt)
        return;
    /* gmmcga.bin CS:2C01 (the word at CS:2042h) clears all 200 mode-13h
     * rows in eight interleaved passes.  The resulting visible surface is
     * precisely a 320x200 black framebuffer. */
    framebuf_clear(0);
    memset(rt->mcga.vga, 0, sizeof(rt->mcga.vga));
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_INIT,
                      .source = source,
                  });
}

void zel_runtime_vga_palette(zel_runtime_t *rt, const char *source, u16 ax) {
    if (!rt)
        return;
    rt->regs.ax = ax;
    /* CS:[3008] in the release OPDMO dispatches to 105GDMCA:4221.  Its
     * sixteen-row DAC expansion is captured in palette_set_opdmo_mcga;
     * browser-era scene palette aliases are not equivalent. */
    palette_set_opdmo_mcga(ax);
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_PALETTE,
                      .source = source,
                      .ax = ax,
                      .al = (u8)ax,
                  });
}

void zel_runtime_vga_mode(zel_runtime_t *rt, const char *source, u16 ax, u16 bx, u16 cx) {
    if (!rt)
        return;
    rt->regs.ax = ax;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_MODE,
                      .source = source,
                      .ax = ax,
                      .bx = bx,
                      .cx = cx,
                      .al = (u8)ax,
                  });
}

void zel_runtime_vga_draw(zel_runtime_t *rt, const char *source,
                          u8 al, u16 bx, u16 cx, u16 di) {
    if (!rt)
        return;
    rt->regs.ax = al;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    rt->regs.di = di;
    /* 100OPDMO's CS:[3002] resolves to 105GDMCA:30FCh, the two-plane
     * disp_render_a_full path.  ES is the game segment, represented here by
     * overlay_mem; the driver's CS+3000h scratch and A000h target are mcga. */
    if (runtime_load_mcga_release(rt)) {
        (void)zeliard_mcga_disp_render_a_full_stage(
            rt->mcga.driver, sizeof(rt->mcga.driver),
            rt->overlay_mem, sizeof(rt->overlay_mem),
            rt->mcga.work, sizeof(rt->mcga.work),
            al, bx, cx, di, rt->mcga.vga, sizeof(rt->mcga.vga), 16);
        memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    }
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_DRAW,
                      .source = source,
                      .al = al,
                      .bx = bx,
                      .cx = cx,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_vga_update(zel_runtime_t *rt, const char *source,
                            u8 al, u16 bx, u16 cx, u16 di) {
    if (!rt)
        return;
    rt->regs.ax = al;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    rt->regs.di = di;
    /* 100OPDMO's CS:[3004] resolves to release 105GDMCA:3088h.  It expands
     * C/B/A with D=0 before entering the same masked blit loop. */
    if (runtime_load_mcga_release(rt)) {
        const u8 *source_seg = rt->overlay_mem;
        /* palette_lookup follows SET_ES_2000 and passes that exact segment
         * to gfx_update, not gvar_game_seg. */
        if (rt->regs.es == (u16)(rt->regs.cs + 0x2000))
            source_seg = rt->scratch_mem;
        (void)zeliard_mcga_gfx_update_cba_stage(
            rt->mcga.driver, sizeof(rt->mcga.driver),
            source_seg, ZEL_SEG_SIZE,
            rt->mcga.work, sizeof(rt->mcga.work),
            al, bx, cx, di, rt->mcga.vga, sizeof(rt->mcga.vga), 16);
        memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    }
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_UPDATE,
                      .source = source,
                      .al = al,
                      .bx = bx,
                      .cx = cx,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_text_draw(zel_runtime_t *rt, const char *source,
                           u16 bx, u8 cl, u16 si) {
    if (!rt)
        return;
    rt->regs.bx = bx;
    rt->regs.cx = (u16)((rt->regs.cx & 0xFF00) | cl);
    rt->regs.si = si;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_TEXT_DRAW,
                      .source = source,
                      .bx = bx,
                      .cl = cl,
                      .si = si,
                  });
}

void zel_runtime_decode_rle(zel_runtime_t *rt, const char *source, u16 si, u16 di) {
    if (!rt)
        return;
    rt->regs.si = si;
    rt->regs.di = di;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_DECODE_RLE,
                      .source = source,
                      .si = si,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_decompress_image(zel_runtime_t *rt, const char *source,
                                  u16 si, u16 di) {
    if (!rt)
        return;
    rt->regs.si = si;
    rt->regs.di = di;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_DECOMPRESS_IMAGE,
                      .source = source,
                      .si = si,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_vga_disp_game(zel_runtime_t *rt, const char *source,
                               u8 al, u16 bx, u16 cx, u16 di) {
    if (!rt)
        return;
    rt->regs.ax = al;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    rt->regs.di = di;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_DISP_GAME,
                      .source = source,
                      .al = al,
                      .bx = bx,
                      .cx = cx,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_vga_disp_narr_chap2(zel_runtime_t *rt, const char *source,
                                     u8 al, u16 bx) {
    if (!rt)
        return;
    rt->regs.ax = al;
    rt->regs.bx = bx;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_DISP_NARR_CHAP2,
                      .source = source,
                      .al = al,
                      .bx = bx,
                  });
}

void zel_runtime_vga_disp_narr_chap4(zel_runtime_t *rt, const char *source,
                                     u8 al, u8 ah, u16 bx, u8 cl) {
    if (!rt)
        return;
    rt->regs.ax = (u16)(al | ((u16)ah << 8));
    rt->regs.bx = bx;
    rt->regs.cx = (u16)((rt->regs.cx & 0xFF00) | cl);
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_DISP_NARR_CHAP4,
                      .source = source,
                      .al = al,
                      .ax = rt->regs.ax,
                      .bx = bx,
                      .cl = cl,
                  });
}

void zel_runtime_vga_jashiin_speech(zel_runtime_t *rt, const char *source,
                                    u16 ax, u16 bx, u16 cx) {
    if (!rt)
        return;
    rt->regs.ax = ax;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    (void)zeliard_gmmcga_jashiin_speech_clear(
        rt->mcga.vga, sizeof(rt->mcga.vga), ax, bx, cx);
    memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_JASHIIN_SPEECH,
                      .source = source,
                      .ax = ax,
                      .bx = bx,
                      .cx = cx,
                      .al = (u8)ax,
                  });
}

void zel_runtime_vga_disp_narr_chap3(zel_runtime_t *rt, const char *source,
                                     u16 bx, u16 cx, u16 di) {
    if (!rt)
        return;
    rt->regs.bx = bx;
    rt->regs.cx = cx;
    rt->regs.di = di;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_DISP_NARR_CHAP3,
                      .source = source,
                      .bx = bx,
                      .cx = cx,
                      .di = di,
                      .es = rt->regs.es,
                  });
}

void zel_runtime_vga_scanline(zel_runtime_t *rt, const char *source, u16 si) {
    if (!rt)
        return;
    rt->regs.si = si;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_SCANLINE,
                      .source = source,
                      .si = si,
                  });
}

void zel_runtime_sprite_dispatch(zel_runtime_t *rt, const char *source, u16 si) {
    if (!rt)
        return;
    rt->regs.si = si;
    if (si == 0x9060 && runtime_load_opdmo_release(rt) &&
        runtime_load_mcga_release(rt)) {
        (void)zeliard_mcga_sprite_object_init(
            rt->mcga.driver, sizeof(rt->mcga.driver), rt->mem,
            sizeof(rt->mem), si);
        rt->opdmo_sprite_a_started = 1;
        rt->opdmo_sprite_a_waiting = 0;
    }
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_SPRITE_DISPATCH,
                      .source = source,
                      .si = si,
                  });
}

void zel_runtime_sound_command(zel_runtime_t *rt, const char *source, u16 ax, u16 si) {
    if (!rt)
        return;
    rt->regs.ax = ax;
    rt->regs.si = si;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_SOUND_COMMAND,
                      .source = source,
                      .ax = ax,
                      .si = si,
                  });
}

zel_runtime_wait_result_t zel_runtime_timer_wait(zel_runtime_t *rt,
                                                 const char *source, u8 al) {
    if (!rt)
        return ZEL_RUNTIME_WAIT_PENDING;

    if (rt->mem[ZEL_GVAR_SPACEBAR_STATE] != 0 ||
        rt->mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY) {
        log_event(rt, (zel_proxy_event_t){
                          .kind = ZEL_PROXY_TIMER_WAIT,
                          .source = source,
                          .al = al,
                          .value = ZEL_RUNTIME_WAIT_SKIPPED,
                      });
        return ZEL_RUNTIME_WAIT_SKIPPED;
    }
    if (rt->mem[ZEL_GVAR_FRAME_TIMER] < al)
        return ZEL_RUNTIME_WAIT_PENDING;

    rt->mem[ZEL_GVAR_FRAME_TIMER] = 0;
    rt->mcga.frame_timer = 0;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_TIMER_WAIT,
                      .source = source,
                      .al = al,
                      .value = ZEL_RUNTIME_WAIT_READY,
                  });
    return ZEL_RUNTIME_WAIT_READY;
}

u16 zel_runtime_swap_overlay_blocks(zel_runtime_t *rt, const char *source,
                                    u16 bx) {
    enum {
        LOW_OFFSET = 0x3000,
        HIGH_OFFSET = 0x9000,
        SWAP_BYTES = 0x7000,
    };
    if (!rt)
        return 0;

    /* stick.asm:1573-1595.  The MASM loop swaps words; byte pairs preserve
     * the same little-endian memory state without introducing a host word
     * alignment dependency. */
    for (size_t i = 0; i < SWAP_BYTES; i++) {
        u8 value = rt->overlay_mem[HIGH_OFFSET + i];
        rt->overlay_mem[HIGH_OFFSET + i] = rt->mem[LOW_OFFSET + i];
        rt->mem[LOW_OFFSET + i] = value;
    }

    const u16 target = (u16)(rt->mem[bx] | ((u16)rt->mem[(u16)(bx + 1)] << 8));
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_OVERLAY_SWAP,
                      .source = source,
                      .bx = bx,
                      .value = target,
                      .size = SWAP_BYTES,
                  });
    return target;
}

int zel_opdmo_0200_start_title_span(zel_runtime_t *rt) {
    if (!rt)
        return 0;

    rt->regs.sp = 0x2000;
    rt->regs.ds = rt->regs.cs;
    zel_runtime_keyboard_clear_opening_skip(rt, "100OPDMO:start:321");
    zel_runtime_vga_init(rt, "100OPDMO:start:325");

    rt->regs.ds = rt->regs.cs;
    if (!zel_runtime_load_chunk(rt, "ttl3.grp", 2, ZEL_GFX_PLANE_B))
        return 0;

    rt->regs.es = 0;
    zel_runtime_decode_rle(rt, "100OPDMO:start:336", ZEL_GFX_PLANE_B,
                           ZEL_FRAMEBUFFER_A);
    zel_runtime_vga_palette(rt, "100OPDMO:start:340", 4);
    zel_runtime_text_draw(rt, "100OPDMO:start:346", 0x0000, 0x96,
                          OPDMO_SCENE_DATA_A);
    if (zel_runtime_opdmo_render_title(rt, 16) != 0)
        return 0;
    rt->opdmo_prelude_step = 0;
    return 1;
}

int zel_opdmo_0200_prelude_step(zel_runtime_t *rt) {
    if (!rt)
        return -1;

    /* This is deliberately a source-order state machine, not a scene
     * scheduler.  The numbers are the call blocks after the title handoff in
     * 100OPDMO:run_opening_demo_main.  A block may make several adjacent
     * calls only where MASM has no possible timer/input observation between
     * them. */
    switch (rt->opdmo_prelude_step) {
    case 0:
        if (!zel_runtime_load_chunk(rt, "nec.grp", 2, ZEL_GFX_PLANE_B))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 1:
        if (!zel_runtime_load_chunk(rt, "hou.grp", 2, 0xB800))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 2:
        if (!runtime_load_nec_hou_sources(rt) || !runtime_decompress_nec(rt))
            return -1;
        rt->regs.es = rt->regs.cs;
        zel_runtime_decompress_image(rt, "100OPDMO:nec:decompress_image",
                                     ZEL_GFX_PLANE_B, ZEL_FRAMEBUFFER_A);
        zel_runtime_vga_init(rt, "100OPDMO:nec:gfx_init");
        zel_runtime_keyboard_clear_opening_skip(rt, "100OPDMO:nec:clear_input");
        zel_runtime_vga_palette(rt, "100OPDMO:nec:palette", 1);
        rt->opdmo_prelude_step++;
        return 1;
    case 3:
        rt->regs.es = rt->regs.cs;
        zel_runtime_vga_draw(rt, "100OPDMO:nec:gfx_draw", 0xFF,
                             0x1220, 0x2C68, ZEL_FRAMEBUFFER_A);
        rt->opdmo_prelude_step++;
        return 1;
    case 4:
        if (!rt->opdmo_scanline_started) {
            if (zel_runtime_opdmo_begin_animate_scanline(rt) != 0)
                return -1;
            return 1;
        }
        {
            int scanline_rc = zel_runtime_opdmo_advance_animate_scanline(rt);
            if (scanline_rc < 0)
                return -1;
            if (scanline_rc != 2)
                return 1;
        }
        rt->opdmo_prelude_step++;
        return 1;
    case 5:
        rt->regs.es = rt->regs.cs;
        zel_runtime_vga_palette(rt, "100OPDMO:hou:palette", 2);
        zel_runtime_vga_update(rt, "100OPDMO:hou:gfx_blit", 0xFF,
                               0x1220, 0x2C68, ZEL_FRAMEBUFFER_A);
        rt->opdmo_prelude_step++;
        return 1;
    case 6:
        if (!runtime_decompress_hou(rt))
            return -1;
        rt->regs.es = rt->regs.cs;
        zel_runtime_decompress_image(rt, "100OPDMO:hou:decompress_image",
                                     0xB800, 0x9000);
        rt->opdmo_prelude_step++;
        return 1;
    case 7:
        if (zel_runtime_opdmo_render_hou_disp_game(rt) != 0)
            return -1;
        rt->mem[0xFF75] = 4;
        zel_runtime_sprite_dispatch(rt, "100OPDMO:scene_sprite_a", 0x9060);
        rt->opdmo_prelude_step++;
        return 1;
    case 8:
        {
            const int sprite_rc = zel_runtime_opdmo_advance_sprite_a(rt);
            if (sprite_rc < 0)
                return -1;
            if (sprite_rc != 2)
                return 1;
        }
        rt->opdmo_prelude_step++;
        return 1;
    case 9:
        if (!zel_runtime_load_chunk(rt, "dmaou.grp", 2, ZEL_GFX_PLANE_B) ||
            !runtime_load_fill_buffer_asset(rt->mem, "dmaou.grp", 0xA000) ||
            !opdmo_decompress_image(rt->mem, rt->overlay_mem,
                                    0xA000, 0x97C0))
            return -1;
        rt->regs.es = rt->regs.cs;
        zel_runtime_decompress_image(rt, "100OPDMO:dmaou:decompress_image",
                                     0xA000, 0x97C0);
        rt->opdmo_prelude_step++;
        return 1;
    case 10:
        if (zel_runtime_opdmo_palette_lookup(rt) != 0)
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 11:
        zel_runtime_vga_mode(rt, "100OPDMO:dmaou:gfx_mode", 0,
                             0x1220, 0x2C68);
        rt->opdmo_prelude_step++;
        return 1;
    case 12:
        zel_runtime_vga_palette(rt, "100OPDMO:dmaou:gfx_palette", 3);
        rt->opdmo_prelude_step++;
        return 1;
    case 13:
        rt->regs.es = (u16)(rt->regs.cs + 0x2000);
        zel_runtime_vga_update(rt, "100OPDMO:dmaou:gfx_update", 0xFF,
                               0x1720, 0x2270, 0x0000);
        rt->opdmo_prelude_step++;
        return 1;
    case 14:
        /* scene_sprite_c is release OPDMO CS:911Eh. */
        rt->opdmo_scene_sprite_c_si = 0x911E;
        rt->opdmo_scene_sprite_c_waiting = 0;
        rt->opdmo_prelude_step++;
        return 1;
    case 15:
        if (rt->opdmo_scene_sprite_c_waiting) {
            zel_runtime_wait_result_t wait = zel_runtime_timer_wait(
                rt, "100OPDMO:scene_sprite_c:timer_wait_loop", 0x14);
            if (wait == ZEL_RUNTIME_WAIT_PENDING)
                return 1;
            if (wait == ZEL_RUNTIME_WAIT_SKIPPED)
                return -1; /* Caller must take the real opening_next_scene path. */
            rt->opdmo_scene_sprite_c_waiting = 0;
            return 1;
        }
        rt->mem[ZEL_GVAR_FRAME_TIMER] = 0;
        rt->mcga.frame_timer = 0;
        {
            u8 value = rt->mem[rt->opdmo_scene_sprite_c_si++];
            if (value == 0) {
                rt->opdmo_prelude_step++;
                return 1;
            }
            zel_runtime_vga_disp_narr_chap2(
                rt, "100OPDMO:scene_sprite_c:disp_narr_chap2",
                (u8)(value - 1), 0x1720);
            rt->opdmo_scene_sprite_c_waiting = 1;
        }
        return 1;
    case 16:
        /* scene_after_anim begins with WAIT_FRAME 0F0h. */
        {
            zel_runtime_wait_result_t wait = zel_runtime_timer_wait(
                rt, "100OPDMO:scene_after_anim:wait_before_sprite_b", 0xF0);
            if (wait == ZEL_RUNTIME_WAIT_PENDING)
                return 1;
            if (wait == ZEL_RUNTIME_WAIT_SKIPPED)
                return -1; /* opening_next_scene has not yet been translated here. */
        }
        rt->opdmo_prelude_step++;
        return 1;
    case 17:
        /* play_sprite_anim_script(scene_sprite_b), DS=CS. */
        rt->opdmo_sprite_b_si = 0x9096;
        rt->opdmo_sprite_b_active = 1;
        rt->opdmo_sprite_b_waiting = 0;
        rt->mem[0x653F] = 0x8A;
        rt->opdmo_prelude_step++;
        return 1;
    case 18:
        if (rt->opdmo_sprite_b_waiting) {
            zel_runtime_wait_result_t wait = zel_runtime_timer_wait(
                rt, "100OPDMO:sprite_b:timer_wait_loop", 0x14);
            if (wait == ZEL_RUNTIME_WAIT_PENDING)
                return 1;
            if (wait == ZEL_RUNTIME_WAIT_SKIPPED)
                return -1;
            rt->opdmo_sprite_b_waiting = 0;
            return 1;
        }
        rt->mem[ZEL_GVAR_FRAME_TIMER] = 0;
        rt->mcga.frame_timer = 0;
        while (rt->opdmo_sprite_b_active) {
            const u8 value = rt->mem[rt->opdmo_sprite_b_si++];
            if (value == 0) {
                rt->opdmo_sprite_b_active = 0;
                rt->opdmo_prelude_step++;
                return 1;
            }
            if (value < 5) {
                zel_runtime_vga_disp_narr_chap2(
                    rt, "100OPDMO:sprite_b:disp_chap2_call",
                    (u8)(value - 1), 0x1F70);
                continue;
            }
            if (value == 0xFF) {
                const u8 command = rt->mem[rt->opdmo_sprite_b_si++];
                if (command == 1) {
                    const u8 frame = rt->mem[rt->opdmo_sprite_b_si++];
                    rt->mem[0x653D] = (u8)(frame << 3);
                    rt->mem[0x653E] = 0;
                    rt->mem[0x653F] = (u8)(rt->mem[0x653F] + 0x0A);
                }
            } else {
                const u16 state_a = (u16)(rt->mem[0x653D] |
                                           ((u16)rt->mem[0x653E] << 8));
                const u8 state_b = rt->mem[0x653F];
                zel_runtime_vga_disp_narr_chap4(
                    rt, "100OPDMO:sprite_b:disp_narr_chap4", value, 2,
                    (u16)(state_a + 2), (u8)(state_b + 1));
                zel_runtime_vga_disp_narr_chap4(
                    rt, "100OPDMO:sprite_b:disp_narr_chap4", value, 7,
                    state_a, state_b);
                const u16 next = (u16)(state_a + 8);
                rt->mem[0x653D] = (u8)next;
                rt->mem[0x653E] = (u8)(next >> 8);
                if (value != ' ')
                    rt->mem[0xFF75] = 0x3F;
            }
            rt->opdmo_sprite_b_waiting = 1;
            return 1;
        }
        return -1;
    case 19:
        if (zel_runtime_timer_wait(rt,
                "100OPDMO:scene_after_anim:wait_after_sprite_b", 0xF0) ==
            ZEL_RUNTIME_WAIT_PENDING)
            return 1;
        if (rt->mem[ZEL_GVAR_SPACEBAR_STATE] ||
            rt->mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY)
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 20:
        zel_runtime_vga_disp_narr_chap2(
            rt, "100OPDMO:scene_after_anim:disp_narr_chap2", 2, 0x1720);
        rt->opdmo_prelude_step++;
        return 1;
    case 21:
        if (zel_runtime_timer_wait(rt,
                "100OPDMO:scene_after_anim:wait_between_chap2", 0x0F) ==
            ZEL_RUNTIME_WAIT_PENDING)
            return 1;
        if (rt->mem[ZEL_GVAR_SPACEBAR_STATE] ||
            rt->mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY)
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 22:
        zel_runtime_vga_disp_narr_chap2(
            rt, "100OPDMO:scene_after_anim:disp_narr_chap2", 3, 0x1720);
        rt->opdmo_prelude_step++;
        return 1;
    case 23:
        if (zel_runtime_timer_wait(rt,
                "100OPDMO:scene_after_anim:wait_before_jashiin_speech", 0xF0) ==
            ZEL_RUNTIME_WAIT_PENDING)
            return 1;
        if (rt->mem[ZEL_GVAR_SPACEBAR_STATE] ||
            rt->mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY)
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 24:
        zel_runtime_vga_jashiin_speech(
            rt, "100OPDMO:jashiin_speech_disp", 0, 0x0094, 0x501E);
        rt->opdmo_prelude_step++;
        return 1;
    case 25:
        /* LOAD_DATA res_ttl1_grp, vga_seg: ES=CS, DI=A000h, AL=2. */
        rt->regs.es = rt->regs.cs;
        if (!zel_runtime_load_chunk(rt, "ttl1.grp", 2, 0xA000) ||
            !runtime_load_fill_buffer_asset(rt->mem, "ttl1.grp", 0xA000))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 26:
        /* ES=gvar_game_seg, SI=A000h, DI=4000h, call decode_rle_to_es_di. */
        rt->regs.es = rt->regs.cs;
        if (!runtime_decode_6de1_asset_to_overlay(rt, "ttl1.grp", 0x4000))
            return -1;
        zel_runtime_decode_rle(rt, "100OPDMO:ttl1:decode_rle_to_es_di",
                               0xA000, 0x4000);
        rt->opdmo_prelude_step++;
        return 1;
    case 27:
        /* LOAD_DATA res_ttl2_grp, vga_seg. */
        rt->regs.es = rt->regs.cs;
        if (!zel_runtime_load_chunk(rt, "ttl2.grp", 2, 0xA000) ||
            !runtime_load_fill_buffer_asset(rt->mem, "ttl2.grp", 0xA000))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 28:
        /* sar_loader(res_ttl3_grp, AL=2, ES=CS, DI=B000h). */
        rt->regs.es = rt->regs.cs;
        if (!zel_runtime_load_chunk(rt, "ttl3.grp", 2, 0xB000) ||
            !runtime_load_fill_buffer_asset(rt->mem, "ttl3.grp", 0xB000))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 29:
        /* sar_loader(res_zopn_msd, AL=5, ES=gvar_game_seg, DI=3000h). */
        rt->regs.es = rt->regs.cs;
        /* AL=5 is the score/resource service path. It must not be decoded
         * into the graphics game segment; that would overwrite ttl1's 4000h
         * frame. The proxy records and stages the original chunk for the
         * later INT 60h sound consumer. */
        if (!zel_runtime_load_chunk(rt, "zopn.msd", 5, 0x3000))
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    case 30:
        zel_runtime_vga_mode(rt, "100OPDMO:title:gfx_mode", 0,
                             0x1720, 0x2270);
        rt->opdmo_prelude_step++;
        return 1;
    case 31:
        zel_runtime_vga_palette(rt, "100OPDMO:title:gfx_palette", 4);
        rt->opdmo_prelude_step++;
        return 1;
    case 32:
        rt->mem[ZEL_GVAR_FRAME_TIMER] = 0;
        rt->mcga.frame_timer = 0;
        /* push ds / ds=gvar_game_seg / SI=3000h / AX=0 / INT 60h */
        zel_runtime_sound_command(rt, "100OPDMO:title:int60_score_start", 0, 0x3000);
        rt->opdmo_prelude_step++;
        return 1;
    case 33:
        if (zeliard_mcga_disp_drv_seg_3_seed(rt->mcga.vga,
                                              sizeof(rt->mcga.vga)) != 0)
            return -1;
        memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
        log_event(rt, (zel_proxy_event_t){
                          .kind = ZEL_PROXY_VGA_DISP_DRV_SEG_3,
                          .source = "100OPDMO:title:disp_drv_seg_3",
                      });
        rt->opdmo_prelude_step++;
        return 1;
    case 34:
        if (zel_runtime_timer_wait(rt,
                "100OPDMO:title:wait_before_gfx_update", 0xF0) ==
            ZEL_RUNTIME_WAIT_PENDING)
            return 1;
        if (rt->mem[ZEL_GVAR_SPACEBAR_STATE] ||
            rt->mem[ZEL_GVAR_ENTER_KEY] == ZEL_ENTER_KEY)
            return -1;
        rt->opdmo_prelude_step++;
        return 1;
    default:
        return 0;
    }
}

int zel_opdmo_0200_prelude_finished(const zel_runtime_t *rt) {
    return rt && rt->opdmo_prelude_step >= 35;
}

int zel_runtime_opdmo_begin_animate_scanline(zel_runtime_t *rt) {
    if (!rt)
        return -1;
    if (rt->opdmo_scanline_started)
        return 0;

    if (!runtime_load_opdmo_release(rt))
        return -1;
    if (!runtime_load_mcga_release(rt))
        return -1;
    if (!runtime_load_opdmo_font(rt))
        return -1;

    int rc = zel_mcga_runtime_begin_scanline_stream(
        &rt->mcga, rt->opdmo_font.data, rt->opdmo_font.size,
        rt->opdmo_font.ptr_a, rt->mem + OPDMO_SCANLINE_STREAM,
        ZEL_SEG_SIZE - OPDMO_SCANLINE_STREAM);
    if (rc != 0)
        return -1;

    rt->opdmo_scanline_started = 1;
    zel_runtime_vga_scanline(rt, "100OPDMO:animate_scanline",
                             OPDMO_SCANLINE_STREAM);
    return 0;
}

int zel_runtime_opdmo_advance_animate_scanline(zel_runtime_t *rt) {
    if (!rt || !rt->opdmo_scanline_started)
        return -1;

    /* Both the translated procedure and the MCGA proxy observe the same
     * IRQ-driven FF1Ah byte.  Synchronize before and after one MASM draw or
     * wait probe; no browser-duration approximation is involved. */
    rt->mcga.frame_timer = rt->mem[ZEL_GVAR_FRAME_TIMER];
    int rc = zel_mcga_runtime_advance_scanline(&rt->mcga);
    rt->mem[ZEL_GVAR_FRAME_TIMER] = rt->mcga.frame_timer;
    if (rc == 1)
        memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    return rc;
}

int zel_runtime_opdmo_render_title(zel_runtime_t *rt, int pass_count) {
    if (!rt || pass_count < 0 || pass_count > 16 ||
        !runtime_load_opdmo_release(rt) || !runtime_load_mcga_release(rt) ||
        !runtime_load_opdmo_font(rt))
        return -1;

    size_t file_size = 0;
    u8 *file_data = platform_load_asset("ttl3.grp", &file_size);
    size_t plane_size = 0;
    u8 *planes = file_data
        ? grp_decode_6de1_planes(file_data, file_size, &plane_size) : NULL;
    free(file_data);
    if (!planes || plane_size > ZEL_SEG_SIZE - ZEL_FRAMEBUFFER_A) {
        free(planes);
        return -1;
    }

    /* MASM: narration_stone_disp(BX=0, CL=96h, SI=64EAh), then
     * disp_narr_chap3(AX=0, BX=070Fh, CX=4170h, ES:DI=game:4000h). */
    framebuf_clear(0);
    zeliard_font_draw_mcga_narration_stream(
        &rt->opdmo_font, 0, 0x96, rt->mem + OPDMO_SCENE_DATA_A,
        ZEL_SEG_SIZE - OPDMO_SCENE_DATA_A, 1);
    memcpy(rt->mcga.vga, g_framebuf, ZELIARD_FB_SIZE);
    memset(rt->mcga.vga + ZELIARD_FB_SIZE, 0,
           ZEL_MCGA_SEG_SIZE - ZELIARD_FB_SIZE);
    memset(rt->mcga.work, 0, sizeof(rt->mcga.work));
    /* decode_rle_to_es_di writes ES=gvar_game_seg:4000h.  OPDMO's own
     * code/stream remains in CS, so these must not alias: the 6FF0h
     * animate_scanline table lies inside the title image's destination range.
     * overlay_mem is the runtime's second 64 KiB segment. */
    memcpy(rt->overlay_mem + ZEL_FRAMEBUFFER_A, planes, plane_size);
    free(planes);

    if (zeliard_mcga_disp_render_a_full_stage(
            rt->mcga.driver, sizeof(rt->mcga.driver), rt->overlay_mem,
            sizeof(rt->overlay_mem), rt->mcga.work, sizeof(rt->mcga.work), 0,
            0x070F, 0x4170, ZEL_FRAMEBUFFER_A, rt->mcga.vga,
            sizeof(rt->mcga.vga), pass_count) != 0)
        return -1;
    memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    zel_runtime_vga_disp_narr_chap3(rt, "100OPDMO:disp_narr_chap3",
                                    0x070F, 0x4170, ZEL_FRAMEBUFFER_A);
    return 0;
}

int zel_runtime_opdmo_prepare_nec_hou_handoff(zel_runtime_t *rt) {
    if (!runtime_load_nec_hou_sources(rt))
        return -1;
    if (!runtime_decompress_nec(rt) || !runtime_decompress_hou(rt))
        return -1;
    return 0;
}

int zel_runtime_opdmo_render_hou_disp_game(zel_runtime_t *rt) {
    if (!rt)
        return -1;
    int width = 0;
    int height = 0;
    u8 *image = zeliard_mcga_render_three_plane_ab(
        rt->overlay_mem, 0x75A0, 0x10 * 0x40, 0x10, 0x40,
        &width, &height);
    if (!image || width != 64 || height != 64) {
        free(image);
        return -1;
    }

    /* 105GDMCA:33B7 receives BX=2048h: BH*4 is the x coordinate and BL
     * is y.  It updates the existing A000 raster; it does not clear it. */
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++)
            rt->mcga.vga[(0x48 + y) * ZELIARD_WIDTH + 0x80 + x] =
                image[y * width + x];
    }
    free(image);
    memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    rt->regs.es = rt->regs.cs;
    zel_runtime_vga_disp_game(rt, "100OPDMO:hou:disp_game", 0,
                              0x2048, 0x1040, 0x75A0);
    return 0;
}

int zel_runtime_opdmo_palette_lookup(zel_runtime_t *rt) {
    if (!rt)
        return -1;
    /* 100OPDMO:palette_lookup. SET_ES_2000 is deliberately represented by
     * scratch_mem, not the decoded game segment in overlay_mem. */
    memset(rt->scratch_mem, 0, 0x2CA0);
    u16 si = 0xAB40;
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0000, 0x2230, 1);
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0000, 0x2230, 0);
    si = 0xA9C0;
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0F30, 0x0620, 1);
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0F30, 0x0620, 0);
    si = 0x9C40;
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0850, 0x1220, 0);
    opdmo_palette_copy_rect(rt->scratch_mem, rt->overlay_mem, &si,
                            0x0850, 0x1220, 1);
    return 0;
}

int zel_runtime_opdmo_advance_sprite_a(zel_runtime_t *rt) {
    if (!rt || !rt->opdmo_sprite_a_started)
        return -1;
    if (!rt->opdmo_sprite_a_waiting) {
        if (zeliard_mcga_sprite_frame_prepare(
                rt->mcga.driver, sizeof(rt->mcga.driver), rt->overlay_mem,
                sizeof(rt->overlay_mem), rt->mcga.work, sizeof(rt->mcga.work),
                rt->mcga.vga, sizeof(rt->mcga.vga)) != 0)
            return -1;
        rt->opdmo_sprite_a_waiting = 1;
        memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
        return 1;
    }

    /* 105GDMCA:3544 polls its CS-resident FF1Ah.  Runtime ticks own the
     * same byte, so no browser-duration approximation is introduced here. */
    if (rt->mem[ZEL_GVAR_FRAME_TIMER] < 0x1E)
        return 0;
    rt->mcga.driver[0xFF1A] = rt->mem[ZEL_GVAR_FRAME_TIMER];
    if (zeliard_mcga_sprite_frame_restore(
            rt->mcga.driver, sizeof(rt->mcga.driver), rt->mcga.work,
            sizeof(rt->mcga.work), rt->mcga.vga, sizeof(rt->mcga.vga)) != 0)
        return -1;
    rt->mem[ZEL_GVAR_FRAME_TIMER] = rt->mcga.driver[0xFF1A];
    rt->mcga.frame_timer = rt->mem[ZEL_GVAR_FRAME_TIMER];
    rt->opdmo_sprite_a_waiting = 0;
    memcpy(g_framebuf, rt->mcga.vga, ZELIARD_FB_SIZE);
    return zeliard_mcga_sprite_objects_active(rt->mcga.driver,
                                               sizeof(rt->mcga.driver)) ? 1 : 2;
}
