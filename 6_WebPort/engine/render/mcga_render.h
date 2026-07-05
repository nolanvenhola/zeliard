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

u8 *zeliard_mcga_render_a_full_stride(const u8 *planes, size_t planes_size,
                                      int rows, int cl, int plane_stride,
                                      int *out_w, int *out_h);

u8 *zeliard_mcga_render_two_plane_da(const u8 *planes, size_t planes_size,
                                     int rows, int cl, int *out_w,
                                     int *out_h);

u8 *zeliard_mcga_render_three_plane_ab(const u8 *seg, int base, int bp,
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

#endif
