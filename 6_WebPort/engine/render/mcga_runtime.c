#include "mcga_runtime.h"

#include "../core/timer.h"
#include "mcga_render.h"

#include <string.h>

void zel_mcga_runtime_init(zel_mcga_runtime_t *rt) {
    if (rt)
        memset(rt, 0, sizeof(*rt));
}

int zel_mcga_runtime_load_driver(zel_mcga_runtime_t *rt,
                                 const u8 *chunk, size_t chunk_size) {
    if (!rt || !chunk || chunk_size < 4u ||
        chunk_size > ZEL_MCGA_SEG_SIZE - ZEL_MCGA_DRIVER_LOAD)
        return 0;
    memset(rt->driver, 0, sizeof(rt->driver));
    memcpy(rt->driver + ZEL_MCGA_DRIVER_LOAD, chunk, chunk_size);
    return 1;
}

int zel_mcga_runtime_decode_scanline(zel_mcga_runtime_t *rt,
                                     const u8 *font_data, size_t font_size,
                                     u16 font_ptr_a,
                                     const u8 *stream, size_t stream_size) {
    if (!rt)
        return -1;
    return zeliard_mcga_anim_fade_decode(
        font_data, font_size, font_ptr_a, stream, stream_size,
        rt->driver + ZEL_MCGA_SCANLINE_WORKSPACE,
        ZEL_MCGA_SCANLINE_WORKSPACE_SIZE);
}

int zel_mcga_runtime_draw_scanline(zel_mcga_runtime_t *rt,
                                   u16 ax, u16 bx, u16 cx) {
    if (!rt)
        return -1;
    return zeliard_mcga_anim_draw_step(rt->driver, sizeof(rt->driver),
                                       rt->work, sizeof(rt->work),
                                       rt->vga, sizeof(rt->vga),
                                       ax, bx, cx);
}

int zel_mcga_runtime_begin_scanline_stream_ex(zel_mcga_runtime_t *rt,
                                              const u8 *font_data,
                                              size_t font_size,
                                              u16 font_ptr_a,
                                              const u8 *stream,
                                              size_t stream_size,
                                              u16 draw_bx, u16 draw_cx,
                                              u16 exit_frames) {
    if (!rt || !font_data || !stream || stream_size == 0)
        return -1;
    /* 100OPDMO calls 105GDMCA:44CCh before every animate_scanline stream. */
    memset(rt->work, 0, sizeof(rt->work));
    rt->scan_font = font_data;
    rt->scan_font_size = font_size;
    rt->scan_font_ptr_a = font_ptr_a;
    rt->scan_stream = stream;
    rt->scan_stream_size = stream_size;
    rt->scan_stream_pos = 0;
    rt->scan_frame = 10;
    rt->scan_waiting = 0;
    rt->scan_final_record = 0;
    rt->scan_finished = 0;
    rt->scan_exit_frame = 0;
    rt->scan_draw_bx = draw_bx;
    rt->scan_draw_cx = draw_cx;
    rt->scan_exit_frames = exit_frames;
    return 0;
}

int zel_mcga_runtime_begin_scanline_stream(zel_mcga_runtime_t *rt,
                                           const u8 *font_data,
                                           size_t font_size,
                                           u16 font_ptr_a,
                                           const u8 *stream,
                                           size_t stream_size) {
    return zel_mcga_runtime_begin_scanline_stream_ex(
        rt, font_data, font_size, font_ptr_a, stream, stream_size,
        0x0020, 0x5078, 0x0078);
}

int zel_mcga_runtime_advance_scanline(zel_mcga_runtime_t *rt) {
    if (!rt || !rt->scan_stream)
        return -1;
    if (rt->scan_finished)
        return 2;
    if (rt->scan_waiting && !zel_mcga_runtime_take_timer(rt, 0x1C))
        return 0;
    rt->scan_waiting = 0;

    if (rt->scan_final_record && rt->scan_frame >= 10) {
        if (rt->scan_exit_frame >= rt->scan_exit_frames) {
            rt->scan_finished = 1;
            return 2;
        }
        if (zel_mcga_runtime_draw_scanline(rt, 0, rt->scan_draw_bx,
                                           rt->scan_draw_cx) != 0)
            return -1;
        rt->scan_exit_frame++;
        rt->scan_waiting = 1;
        /* 100OPDMO's exit loop returns after its final timed AX=0 draw; do
         * not require a synthetic 121st dispatch merely to mark completion. */
        if (rt->scan_exit_frame == rt->scan_exit_frames)
            rt->scan_finished = 1;
        return 1;
    }

    if (rt->scan_frame >= 10) {
        if (rt->scan_stream_pos >= rt->scan_stream_size)
            return -1;
        int consumed = zel_mcga_runtime_decode_scanline(
            rt, rt->scan_font, rt->scan_font_size, rt->scan_font_ptr_a,
            rt->scan_stream + rt->scan_stream_pos,
            rt->scan_stream_size - rt->scan_stream_pos);
        if (consumed <= 0 || (size_t)consumed > rt->scan_stream_size - rt->scan_stream_pos)
            return -1;
        rt->scan_final_record =
            rt->scan_stream[rt->scan_stream_pos + (size_t)consumed - 1u] == 0xFFu;
        rt->scan_stream_pos += (size_t)consumed;
        rt->scan_frame = 0;
    }

    if (zel_mcga_runtime_draw_scanline(rt, rt->scan_frame, rt->scan_draw_bx,
                                       rt->scan_draw_cx) != 0)
        return -1;
    rt->scan_frame++;
    rt->scan_waiting = 1;
    return 1;
}

u32 zel_mcga_runtime_tick(zel_mcga_runtime_t *rt, u32 dt_ms) {
    if (!rt)
        return 0;
    u32 ticks = zel_timer_advance_ms(&rt->timer_subtick_accum, dt_ms);
    rt->timer_ticks += ticks;
    rt->frame_timer = (u8)(rt->frame_timer + (u8)ticks);
    return ticks;
}

int zel_mcga_runtime_take_timer(zel_mcga_runtime_t *rt, u8 required) {
    if (!rt || rt->frame_timer < required)
        return 0;
    rt->frame_timer = 0;
    return 1;
}

const u8 *zel_mcga_runtime_framebuffer(const zel_mcga_runtime_t *rt) {
    return rt ? rt->vga : NULL;
}
