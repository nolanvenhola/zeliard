#include "runtime.h"
#include "framebuf.h"
#include "timer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include <stdlib.h>
#include <string.h>

enum {
    OPDMO_SCENE_DATA_A = 0x64EA,
};

static void mem_write_u16(u8 *mem, u16 off, u16 value) {
    mem[off] = (u8)(value & 0xFF);
    mem[(u16)(off + 1)] = (u8)(value >> 8);
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
    framebuf_clear(0);
    palette_set_scene(PALETTE_OPENING);
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
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_VGA_INIT,
                      .source = source,
                  });
}

void zel_runtime_vga_palette(zel_runtime_t *rt, const char *source, u16 ax) {
    if (!rt)
        return;
    rt->regs.ax = ax;
    if (ax == 4)
        palette_set_scene(PALETTE_TITLE);
    else if (ax == 1)
        palette_set_scene(PALETTE_OPENING);
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

void zel_runtime_timer_wait(zel_runtime_t *rt, const char *source, u8 al) {
    if (!rt)
        return;
    rt->mem[ZEL_GVAR_FRAME_TIMER] = 0;
    rt->timer_subtick_accum = 0;
    log_event(rt, (zel_proxy_event_t){
                      .kind = ZEL_PROXY_TIMER_WAIT,
                      .source = source,
                      .al = al,
                  });
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
    zel_runtime_vga_draw(rt, "100OPDMO:start:353", 0, 0x070F, 0x4170,
                         ZEL_FRAMEBUFFER_A);
    return 1;
}
