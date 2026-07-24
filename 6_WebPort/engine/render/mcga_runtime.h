#ifndef ZELIARD_MCGA_RUNTIME_H
#define ZELIARD_MCGA_RUNTIME_H

#include "../core/types.h"
#include <stddef.h>

/* Mechanical state for 105GDMCA.  The arrays mirror the segments touched by
 * the driver: its CS image, CS+2000h scratch segment, and A000h VGA memory. */
enum {
    ZEL_MCGA_SEG_SIZE = 0x10000,
    ZEL_MCGA_DRIVER_LOAD = 0x2FFC,
    ZEL_MCGA_SCANLINE_WORKSPACE = 0x4511,
    ZEL_MCGA_SCANLINE_WORKSPACE_SIZE = 0x0C80,
};

typedef struct {
    u8 driver[ZEL_MCGA_SEG_SIZE];
    u8 work[ZEL_MCGA_SEG_SIZE];
    u8 vga[ZEL_MCGA_SEG_SIZE];
    u8 frame_timer;
    u32 timer_subtick_accum;
    u32 timer_ticks;

    const u8 *scan_font;
    size_t scan_font_size;
    u16 scan_font_ptr_a;
    const u8 *scan_stream;
    size_t scan_stream_size;
    size_t scan_stream_pos;
    u8 scan_frame;
    u8 scan_waiting;
    u8 scan_final_record;
    u8 scan_finished;
    u16 scan_exit_frame;
    u16 scan_draw_bx;
    u16 scan_draw_cx;
    u16 scan_exit_frames;
} zel_mcga_runtime_t;

void zel_mcga_runtime_init(zel_mcga_runtime_t *rt);

/* Copies a complete SAR chunk file, including its four-byte header, to the
 * same address range used by the MASM driver fixture. */
int zel_mcga_runtime_load_driver(zel_mcga_runtime_t *rt,
                                 const u8 *chunk, size_t chunk_size);

/* 105GDMCA:32C9 then 332C.  The decoder writes CS:4511..5190 and the draw
 * step mutates both CS+2000h and A000h. */
int zel_mcga_runtime_decode_scanline(zel_mcga_runtime_t *rt,
                                     const u8 *font_data, size_t font_size,
                                     u16 font_ptr_a,
                                     const u8 *stream, size_t stream_size);
int zel_mcga_runtime_draw_scanline(zel_mcga_runtime_t *rt,
                                   u16 ax, u16 bx, u16 cx);

/* Mechanical translation of the first half of 100OPDMO:animate_scanline.
 * Each decoded record receives ten 332Ch draws (AX=0..9, BX=20h,
 * CX=5078h); all but the first draw wait for gvar_frame_timer >= 1Ch.
 * `advance_scanline` returns 1 for a rendered frame, 0 while waiting,
 * 2 once the FF-terminated stream's 120-frame AX=0 fade has completed, or
 * -1 for malformed input. */
int zel_mcga_runtime_begin_scanline_stream(zel_mcga_runtime_t *rt,
                                           const u8 *font_data,
                                           size_t font_size,
                                           u16 font_ptr_a,
                                           const u8 *stream,
                                           size_t stream_size);
int zel_mcga_runtime_begin_scanline_stream_ex(zel_mcga_runtime_t *rt,
                                              const u8 *font_data,
                                              size_t font_size,
                                              u16 font_ptr_a,
                                              const u8 *stream,
                                              size_t stream_size,
                                              u16 draw_bx, u16 draw_cx,
                                              u16 exit_frames);
int zel_mcga_runtime_advance_scanline(zel_mcga_runtime_t *rt);

/* Advance the deterministic hardware-tick proxy. `take_timer` models the
 * opening wait loops that clear gvar_frame_timer once AL has been reached. */
u32 zel_mcga_runtime_tick(zel_mcga_runtime_t *rt, u32 dt_ms);
int zel_mcga_runtime_take_timer(zel_mcga_runtime_t *rt, u8 required);

const u8 *zel_mcga_runtime_framebuffer(const zel_mcga_runtime_t *rt);

#endif
