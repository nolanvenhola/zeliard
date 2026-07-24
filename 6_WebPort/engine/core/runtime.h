#ifndef ZELIARD_RUNTIME_H
#define ZELIARD_RUNTIME_H

#include "types.h"
#include "../render/palette.h"
#include "../render/mcga_runtime.h"
#include "../render/font_text.h"
#include <stddef.h>

enum {
    ZEL_SEG_SIZE = 0x10000,
    ZEL_GFX_PLANE_B = 0x3000,
    ZEL_FRAMEBUFFER_A = 0x4000,
    ZEL_FRAMEBUFFER_B = 0x6000,
    ZEL_GVAR_FRAME_TIMER = 0xFF1A,
    ZEL_GVAR_ANIM_TIMER = 0xFF1B,
    ZEL_GVAR_SPACEBAR_STATE = 0xFF1D,
    ZEL_GVAR_ENTER_KEY = 0xFF29,
    ZEL_GVAR_GAME_SEG = 0xFF2C,
    ZEL_GVAR_FRAME_COUNT = 0xFF50,
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
    ZEL_PROXY_DECOMPRESS_IMAGE,
    ZEL_PROXY_VGA_DISP_GAME,
    ZEL_PROXY_VGA_DISP_NARR_CHAP2,
    ZEL_PROXY_VGA_DISP_NARR_CHAP3,
    ZEL_PROXY_VGA_DISP_NARR_CHAP4,
    ZEL_PROXY_VGA_JASHIIN_SPEECH,
    ZEL_PROXY_VGA_DISP_DRV_SEG_3,
    ZEL_PROXY_VGA_SCANLINE,
    ZEL_PROXY_SPRITE_DISPATCH,
    ZEL_PROXY_SOUND_COMMAND,
    ZEL_PROXY_TIMER_WAIT,
    ZEL_PROXY_OVERLAY_SWAP,
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
    zel_proxy_event_t events[512];
    size_t count;
    int overflowed;
} zel_proxy_log_t;

typedef struct {
    u8 mem[ZEL_SEG_SIZE];
    /* stick.asm:swap_overlay_blocks addresses this as (CS+2000h). */
    u8 overlay_mem[ZEL_SEG_SIZE];
    /* 100OPDMO SET_ES_2000 scratch segment (distinct from gvar_game_seg). */
    u8 scratch_mem[ZEL_SEG_SIZE];
    zel_regs_t regs;
    zel_proxy_log_t log;
    zel_mcga_runtime_t mcga;
    u32 timer_ms;
    u32 timer_subtick_accum;
    u8 opdmo_prelude_step;
    u8 opdmo_scanline_started;
    u8 opdmo_sprite_a_started;
    u8 opdmo_sprite_a_waiting;
    u8 opdmo_scene_sprite_c_waiting;
    u16 opdmo_scene_sprite_c_si;
    u8 opdmo_sprite_b_active;
    u8 opdmo_sprite_b_waiting;
    u16 opdmo_sprite_b_si;
    u8 opdmo_release_loaded;
    u8 mcga_release_loaded;
    zeliard_font_t opdmo_font;
} zel_runtime_t;

typedef enum {
    ZEL_RUNTIME_WAIT_PENDING = 0,
    ZEL_RUNTIME_WAIT_READY = 1,
    ZEL_RUNTIME_WAIT_SKIPPED = 2,
} zel_runtime_wait_result_t;

void zel_runtime_init(zel_runtime_t *rt);
void zel_runtime_destroy(zel_runtime_t *rt);
int  zel_runtime_load_chunk(zel_runtime_t *rt, const char *asset, u8 al, u16 dest);
void zel_runtime_tick(zel_runtime_t *rt, u32 dt_ms);
void zel_runtime_key_down(zel_runtime_t *rt, int keycode);
void zel_runtime_key_up(zel_runtime_t *rt, int keycode);
u8  *zel_runtime_framebuffer(zel_runtime_t *rt);
palette_color_t *zel_runtime_palette(zel_runtime_t *rt);

/* Low-level MCGA state owned for the eventual translated opening path. */
zel_mcga_runtime_t *zel_runtime_mcga(zel_runtime_t *rt);

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
void zel_runtime_decompress_image(zel_runtime_t *rt, const char *source,
                                  u16 si, u16 di);
void zel_runtime_vga_disp_game(zel_runtime_t *rt, const char *source,
                               u8 al, u16 bx, u16 cx, u16 di);
void zel_runtime_vga_disp_narr_chap2(zel_runtime_t *rt, const char *source,
                                     u8 al, u16 bx);
void zel_runtime_vga_disp_narr_chap4(zel_runtime_t *rt, const char *source,
                                     u8 al, u8 ah, u16 bx, u8 cl);
void zel_runtime_vga_jashiin_speech(zel_runtime_t *rt, const char *source,
                                    u16 ax, u16 bx, u16 cx);
void zel_runtime_vga_disp_narr_chap3(zel_runtime_t *rt, const char *source,
                                     u16 bx, u16 cx, u16 di);
void zel_runtime_vga_scanline(zel_runtime_t *rt, const char *source,
                              u16 si);
void zel_runtime_sprite_dispatch(zel_runtime_t *rt, const char *source,
                                 u16 si);
void zel_runtime_sound_command(zel_runtime_t *rt, const char *source, u16 ax, u16 si);
/* Mechanical timer_wait_loop / scene_transition_wait poll.  It observes
 * SPACE/ENTER before the timer threshold, and clears only gvar_frame_timer
 * after a satisfied threshold just as 100OPDMO does. */
zel_runtime_wait_result_t zel_runtime_timer_wait(zel_runtime_t *rt,
                                                 const char *source, u8 al);

/* stick.asm:swap_overlay_blocks, reached by the SAR-loader overlay path.
 * Exchanges CS:3000h-9FFFh with (CS+2000h):9000h-FFFFh, then returns
 * the post-swap CS:[BX] tail-jump target for the translated caller. */
u16 zel_runtime_swap_overlay_blocks(zel_runtime_t *rt, const char *source,
                                    u16 bx);

/* First exact-runtime translated slice:
 * 100OPDMO.asm start through the title/copyright display handoff.
 */
int zel_opdmo_0200_start_title_span(zel_runtime_t *rt);

/* Mechanical continuation of run_opening_demo_main from the title blit to
 * the first scene_sprite_a dispatch.  Each call executes exactly one source
 * call block and never invents a host-time delay.  Return values: 1 advanced,
 * 0 completed, -1 asset/proxy failure. */
int zel_opdmo_0200_prelude_step(zel_runtime_t *rt);
int zel_opdmo_0200_prelude_finished(const zel_runtime_t *rt);

/* Exact 100OPDMO:animate_scanline bridge.  The first call maps the release
 * OPDMO/MCGA chunks at their original segment offsets and starts the real
 * 6FF0h stream.  Subsequent calls return 1 for a draw, 0 while waiting on
 * FF1Ah, 2 after the 430th draw, and -1 on an asset/decoder failure. */
int zel_runtime_opdmo_begin_animate_scanline(zel_runtime_t *rt);
int zel_runtime_opdmo_advance_animate_scanline(zel_runtime_t *rt);

/* 100OPDMO title setup: narration_stone at 64EAh followed by the real
 * CS:30FCh disp_narr_chap3 image renderer.  `pass_count` is 0..16, where
 * each pass is one of the driver's source-timed masked blits. */
int zel_runtime_opdmo_render_title(zel_runtime_t *rt, int pass_count);

/* 100OPDMO's NEC/HOU preparation through the instruction immediately before
 * disp_game(AX=0, BX=2048h, CX=1040h, DI=75A0h). */
int zel_runtime_opdmo_prepare_nec_hou_handoff(zel_runtime_t *rt);
int zel_runtime_opdmo_render_hou_disp_game(zel_runtime_t *rt);
int zel_runtime_opdmo_palette_lookup(zel_runtime_t *rt);

/* Advances the 105GDMCA:3437 scene_sprite_a loop by one observable action:
 * 1 after a prepare or completed restore with more sprites, 0 while its
 * FF1A >= 1Eh wait is pending, 2 after the final restore, -1 on failure. */
int zel_runtime_opdmo_advance_sprite_a(zel_runtime_t *rt);

#endif
