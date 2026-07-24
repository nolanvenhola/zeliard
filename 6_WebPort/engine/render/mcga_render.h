#ifndef ZELIARD_MCGA_RENDER_H
#define ZELIARD_MCGA_RENDER_H

#include "../core/types.h"

u16 zeliard_mcga_pal_process_words(u16 *src_d, u16 *src_c,
                                   u16 *src_b, u16 *src_a);

u8 *zeliard_mcga_render_interleaved_8pass(const u8 *interleaved,
                                          size_t interleaved_size,
                                          int rows, int cl,
                                          int *out_w, int *out_h);

u8 *zeliard_mcga_render_a_full(const u8 *planes, size_t planes_size,
                               int rows, int cl, int *out_w, int *out_h);

u8 *zeliard_mcga_render_a_full_interleaved(const u8 *planes,
                                           size_t planes_size,
                                           int rows, int cl,
                                           int *out_w, int *out_h);

u8 *zeliard_mcga_render_a_full_stride(const u8 *planes, size_t planes_size,
                                      int rows, int cl, int plane_stride,
                                      int *out_w, int *out_h);

u8 *zeliard_mcga_render_two_plane_da(const u8 *planes, size_t planes_size,
                                     int rows, int cl, int *out_w,
                                     int *out_h);

u8 *zeliard_mcga_render_three_plane_ab(const u8 *seg, int base, int bp,
                                       int rows, int cl,
                                       int *out_w, int *out_h);

u8 *zeliard_mcga_render_three_plane_ab_interleaved(const u8 *seg,
                                                   int base, int bp,
                                                   int rows, int cl,
                                                   int *out_w, int *out_h);

u8 *zeliard_mcga_render_three_plane_ab_direct(const u8 *seg, int base, int bp,
                                              int rows, int cl,
                                              int *out_w, int *out_h);

u8 *zeliard_mcga_render_three_plane_mapped(const u8 *seg, int base, int bp,
                                           int rows, int cl, int map_d,
                                           int map_c, int map_b, int map_a,
                                           int *out_w, int *out_h);

u8 *zeliard_mcga_render_plane_select_interleaved(const u8 *planes,
                                                size_t planes_size,
                                                int rows, int cl,
                                                u8 render_mode,
                                                size_t *out_size);

/* 105GDMCA dispatch entry CS:3707 (OPDMO's disp_drv_seg_3_slot).  Writes
 * the driver's 320x200 two-row 00h/10h interlace seed into A000:0000 and
 * leaves A000:FA00..FFFF untouched. */
int zeliard_mcga_disp_drv_seg_3_seed(u8 *vga, size_t vga_size);

/* 105GDMCA:37B4 (`disp_tile_render`).  `driver_seg`, `work_seg`, and `vga`
 * are the original 64 KiB CS, CS+2000h DS, and A000h segments.  This keeps
 * the driver's CS:5191h scratch bytes and plane-state words in place. */
int zeliard_mcga_disp_tile_render(u8 *driver_seg, size_t driver_size,
                                  const u8 *work_seg, size_t work_size,
                                  u8 al, u8 *vga, size_t vga_size);

/* 105GDMCA:3732 (`disp_tilemap_render`).  The tile table is read through
 * the caller's DS (OPDMO code), while tile graphics are read after the
 * helper switches DS to gvar_game_seg. */
int zeliard_mcga_disp_tilemap_render(const u8 *table_seg, size_t table_size,
                                     u16 si, const u8 *game_seg,
                                     size_t game_size, u8 *work_seg,
                                     size_t work_size);

/* 105GDMCA dispatch entry CS:30FCh (`disp_render_a_full`).  This is the
 * opening title's base-image path: it combines the two decoded planes at
 * game:DI into the driver's CS+3000h workspace, then executes both eight-pass
 * A000 blits with the original BX/CX placement registers. */
int zeliard_mcga_disp_render_a_full(u8 *driver_seg, size_t driver_size,
                                    const u8 *game_seg, size_t game_size,
                                    u8 *work_seg, size_t work_size,
                                    u16 ax, u16 bx, u16 cx, u16 di,
                                    u8 *vga, size_t vga_size);

/* Same CS:30FC operation stopped after `pass_count` of its sixteen timed
 * render passes: eight OR passes followed by eight nonzero-write passes. */
int zeliard_mcga_disp_render_a_full_stage(u8 *driver_seg, size_t driver_size,
                                          const u8 *game_seg, size_t game_size,
                                          u8 *work_seg, size_t work_size,
                                          u16 ax, u16 bx, u16 cx, u16 di,
                                          u8 *vga, size_t vga_size,
                                          int pass_count);

/* 105GDMCA:3032, the target stored at runtime CS:3004 (gfx_update_fn).
 * It combines source plane D and A, then performs eight OR and eight normal
 * masked-write passes. */
int zeliard_mcga_gfx_update_da_stage(u8 *driver_seg, size_t driver_size,
                                     const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u16 ax, u16 bx, u16 cx, u16 di,
                                     u8 *vga, size_t vga_size,
                                     int pass_count);

/* 105GDMCA:3088, the release target used by OPDMO's gfx_update_fn.  It
 * expands the C/B/A source planes (D is zero) and enters the masked blitter. */
int zeliard_mcga_gfx_update_cba_stage(u8 *driver_seg, size_t driver_size,
                                      const u8 *game_seg, size_t game_size,
                                      u8 *work_seg, size_t work_size,
                                      u16 ax, u16 bx, u16 cx, u16 di,
                                      u8 *vga, size_t vga_size,
                                      int pass_count);

/* 105GDMCA:3437..3464.  Initializes the nine 15-byte sprite objects at
 * driver CS:A000h from OPDMO's six-byte scene records, then enters the
 * frame loop.  This helper stops at that precise frame-loop boundary. */
int zeliard_mcga_sprite_object_init(u8 *driver_seg, size_t driver_size,
                                    const u8 *scene_seg, size_t scene_size,
                                    u16 si);

/* 105GDMCA:3465..3543.  Executes one sprite-frame prepare pass through the
 * instruction immediately before the FF1A >= 1Eh wait: object update,
 * background save, palette-cycle state advance, and 35CCh OR sprite blits. */
int zeliard_mcga_sprite_frame_prepare(u8 *driver_seg, size_t driver_size,
                                      const u8 *game_seg, size_t game_size,
                                      u8 *work_seg, size_t work_size,
                                      u8 *vga, size_t vga_size);

/* 105GDMCA:3544..357D after FF1A has reached 1Eh.  Clears the driver timer
 * and restores every packed background rectangle from CS+3000h to A000. */
int zeliard_mcga_sprite_frame_restore(u8 *driver_seg, size_t driver_size,
                                      const u8 *work_seg, size_t work_size,
                                      u8 *vga, size_t vga_size);

/* 105GDMCA:3580..358F.  Returns nonzero when at least one CS:A000 sprite
 * object remains active and the driver branches back to the next frame. */
int zeliard_mcga_sprite_objects_active(const u8 *driver_seg, size_t driver_size);

/* 105GDMCA:36AB (`disp_render_ab_gseg`), the target in OPDMO's
 * disp_chap2_call_slot. AL selects a 0x480-byte two-plane page at
 * game_seg:97C0h + AL*480h. The driver expands it into CS+3000h:0000h and
 * directly copies the CH*4 by CL rectangle to A000 at the caller's BX. */
int zeliard_mcga_disp_render_ab_gseg(const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u8 al, u16 bx,
                                     u8 *vga, size_t vga_size);

/* 105GDMCA:364F, the target in OPDMO's disp_narr_chap2_slot. AL selects a
 * 0xCC0-byte two-plane page at game_seg:AB40h + AL*CC0h. The driver expands
 * it into CS+3000h:0000h and copies its fixed 136x48 rectangle to A000:0. */
int zeliard_mcga_disp_render_ab_ab40(const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u8 al, u8 *vga, size_t vga_size);

/* 105GDMCA dispatch table entry at runtime CS:3020 (target 38E6).
 * `driver_seg` is the original driver mapped at offset 2FFCh, and `vga` is
 * the complete 64 KB A000 window.  Returns the number of 0Ch timer waits. */
int zeliard_mcga_disp_font_inv_render(const u8 *driver_seg,
                                      u16 ax_mode,
                                      u8 *vga, size_t vga_size);

/* Same renderer stopped immediately after `wait_count` completed 0Ch waits.
 * A value <= 0 executes the complete routine. */
int zeliard_mcga_disp_font_inv_render_stage(const u8 *driver_seg,
                                            u16 ax_mode,
                                            u8 *vga, size_t vga_size,
                                            int wait_count);

/* 105GDMCA:32C9. Decodes one 0xFF-terminated opening scanline record into
 * the driver's 0x0C80-byte CS:4511 workspace. Returns bytes consumed, or
 * -1 when a MASM memory access would fall outside the supplied buffers. */
int zeliard_mcga_anim_fade_decode(const u8 *font_data, size_t font_size,
                                  u16 font_ptr_a, const u8 *stream,
                                  size_t stream_size, u8 *workspace,
                                  size_t workspace_size);

/* 105GDMCA:332C. Applies one scanline-transition step to the driver's
 * CS+2000h work buffer and the A000 framebuffer. `ax`, `bx`, and `cx` are
 * the registers at the real dispatch boundary. Both segments are 64 KiB. */
int zeliard_mcga_anim_draw_step(const u8 *driver_seg, size_t driver_size,
                                u8 *work_seg, size_t work_size,
                                u8 *vga, size_t vga_size,
                                u16 ax, u16 bx, u16 cx);

/* GMMCGA:2046, dispatch-table function 0, with AL=0.  This is the branch
 * used by OPDMO's jashiin_speech_disp_fn calls: clear CH*4 bytes for CL rows
 * at (AH*4, BH) in the A000 window. */
int zeliard_gmmcga_jashiin_speech_clear(u8 *vga, size_t vga_size,
                                        u16 ax, u16 bx, u16 cx);
#endif
