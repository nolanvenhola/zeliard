#ifndef ZELIARD_RUNTIME_H
#define ZELIARD_RUNTIME_H

#include "types.h"
#include "../render/palette.h"
#include <stddef.h>

enum {
    ZEL_SEG_SIZE = 0x10000,
    ZEL_GFX_PLANE_B = 0x3000,
    ZEL_FRAMEBUFFER_A = 0x4000,
    ZEL_FRAMEBUFFER_B = 0x6000,
    ZEL_GVAR_FRAME_TIMER = 0xFF1A,
    ZEL_GVAR_SPACEBAR_STATE = 0xFF1D,
    ZEL_GVAR_ENTER_KEY = 0xFF29,
    ZEL_GVAR_GAME_SEG = 0xFF2C,
    ZEL_ENTER_KEY = 0x0D,
};

typedef struct {
    u16 ax, bx, cx, dx;
    u16 si, di, bp, sp;
    u16 cs, ds, es, ss;
    u16 flags;
} zel_regs_t;

typedef enum {
    ZEL_PROXY_KEYBOARD_CLEAR,
    ZEL_PROXY_KEYBOARD_KEY_DOWN,
    ZEL_PROXY_KEYBOARD_KEY_UP,
    ZEL_PROXY_VGA_INIT,
    ZEL_PROXY_VGA_MODE,
    ZEL_PROXY_VGA_PALETTE,
    ZEL_PROXY_VGA_DRAW,
    ZEL_PROXY_VGA_UPDATE,
    ZEL_PROXY_TEXT_DRAW,
    ZEL_PROXY_ASSET_LOAD,
    ZEL_PROXY_DECODE_RLE,
    ZEL_PROXY_SOUND_COMMAND,
    ZEL_PROXY_TIMER_WAIT,
} zel_proxy_event_kind_t;

typedef struct {
    zel_proxy_event_kind_t kind;
    const char *source;
    const char *asset;
    u16 ax, bx, cx, dx;
    u16 si, di, es;
    u8 al, cl;
    u32 value;
    size_t size;
} zel_proxy_event_t;

typedef struct {
    zel_proxy_event_t events[256];
    size_t count;
    int overflowed;
} zel_proxy_log_t;

typedef struct {
    u8 mem[ZEL_SEG_SIZE];
    zel_regs_t regs;
    zel_proxy_log_t log;
    u32 timer_ms;
    u32 timer_subtick_accum;
} zel_runtime_t;

void zel_runtime_init(zel_runtime_t *rt);
int  zel_runtime_load_chunk(zel_runtime_t *rt, const char *asset, u8 al, u16 dest);
void zel_runtime_tick(zel_runtime_t *rt, u32 dt_ms);
void zel_runtime_key_down(zel_runtime_t *rt, int keycode);
void zel_runtime_key_up(zel_runtime_t *rt, int keycode);
u8  *zel_runtime_framebuffer(zel_runtime_t *rt);
palette_color_t *zel_runtime_palette(zel_runtime_t *rt);

void zel_runtime_keyboard_clear_opening_skip(zel_runtime_t *rt, const char *source);
void zel_runtime_vga_init(zel_runtime_t *rt, const char *source);
void zel_runtime_vga_palette(zel_runtime_t *rt, const char *source, u16 ax);
void zel_runtime_vga_mode(zel_runtime_t *rt, const char *source, u16 ax, u16 bx, u16 cx);
void zel_runtime_vga_draw(zel_runtime_t *rt, const char *source,
                          u8 al, u16 bx, u16 cx, u16 di);
void zel_runtime_vga_update(zel_runtime_t *rt, const char *source,
                            u8 al, u16 bx, u16 cx, u16 di);
void zel_runtime_text_draw(zel_runtime_t *rt, const char *source,
                           u16 bx, u8 cl, u16 si);
void zel_runtime_decode_rle(zel_runtime_t *rt, const char *source, u16 si, u16 di);
void zel_runtime_sound_command(zel_runtime_t *rt, const char *source, u16 ax, u16 si);
void zel_runtime_timer_wait(zel_runtime_t *rt, const char *source, u8 al);

/* First exact-runtime translated slice:
 * 100OPDMO.asm start through the title/copyright display handoff.
 */
int zel_opdmo_0200_start_title_span(zel_runtime_t *rt);

#endif
