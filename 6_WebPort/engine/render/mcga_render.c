#include "mcga_render.h"
#include <stdlib.h>

static u16 rotl16(u16 value) {
    return (u16)(((value << 1) & 0xFFFFu) | (value >> 15));
}

static u8 read_u8_or_zero(const u8 *data, size_t size, size_t offset) {
    return offset < size ? data[offset] : 0;
}

static u16 read_be16_or_zero(const u8 *data, size_t size, size_t offset) {
    return (u16)(((u16)read_u8_or_zero(data, size, offset) << 8) |
                 read_u8_or_zero(data, size, offset + 1u));
}

u16 zeliard_mcga_pal_process_words(u16 *src_d, u16 *src_c,
                                   u16 *src_b, u16 *src_a) {
    u16 acc = 0;
    for (int i = 0; i < 4; i++) {
        *src_d = rotl16(*src_d);
        acc = (u16)(((acc << 1) | (*src_d & 1u)) & 0xFFFFu);
        *src_c = rotl16(*src_c);
        acc = (u16)(((acc << 1) | (*src_c & 1u)) & 0xFFFFu);
        *src_b = rotl16(*src_b);
        acc = (u16)(((acc << 1) | (*src_b & 1u)) & 0xFFFFu);
        *src_a = rotl16(*src_a);
        acc = (u16)(((acc << 1) | (*src_a & 1u)) & 0xFFFFu);
    }
    return (u16)(((acc & 0xFFu) << 8) | (acc >> 8));
}

static int mask_bit_pos(u8 mask) {
    u8 bl = mask;
    for (int s = 0; s < 8; s++) {
        int carry = (bl >> 7) & 1;
        bl = (u8)(((bl << 1) & 0xFFu) | carry);
        if (carry)
            return s;
    }
    return -1;
}

u8 *zeliard_mcga_render_interleaved_8pass(const u8 *interleaved,
                                          size_t interleaved_size,
                                          int rows, int cl,
                                          int *out_w, int *out_h) {
    static const u8 mask_a[8] = {0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01};
    static const u8 mask_b[8] = {0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80};
    int call_size = rows * 4;
    int blit_calls = cl;
    int pos_a[8], pos_b[8];

    *out_w = call_size;
    *out_h = blit_calls;
    for (int i = 0; i < 8; i++) {
        pos_a[i] = mask_bit_pos(mask_a[i]);
        pos_b[i] = mask_bit_pos(mask_b[i]);
    }

    size_t out_size = (size_t)call_size * (size_t)blit_calls;
    u8 *image = (u8 *)calloc(out_size ? out_size : 1, 1);
    if (!image)
        return NULL;

    for (int start = 0; start < 8; start++) {
        int k = start;
        for (int row = 0; row < blit_calls; row++) {
            int write_pos = (row & 1) ? pos_b[k & 7] : pos_a[k & 7];
            for (int x = 0; x < call_size; x++) {
                if ((x & 7) == write_pos) {
                    size_t idx = (size_t)row * (size_t)call_size + (size_t)x;
                    if (idx < interleaved_size)
                        image[idx] |= interleaved[idx];
                }
            }
            k++;
        }
    }
    return image;
}

u8 *zeliard_mcga_render_a_full_stride(const u8 *planes, size_t planes_size,
                                      int rows, int cl, int plane_stride,
                                      int *out_w, int *out_h) {
    const int bp = rows * cl;
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        u16 bx = read_be16_or_zero(planes, planes_size,
                                   (size_t)plane_stride + (size_t)si);
        u16 ax = read_be16_or_zero(planes, planes_size, (size_t)si);
        u16 dx = (u16)(bx & ax);
        u16 cx = (u16)(bx | ax);
        dx = (u16)~dx;

        u16 src_c = (u16)(bx & dx);
        u16 src_b = (u16)(ax & dx);
        u16 src_d = cx;
        u16 src_a = 0;

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            interleaved[out++] = (u8)(word & 0xFFu);
            interleaved[out++] = (u8)(word >> 8);
        }
    }

    u8 *image = zeliard_mcga_render_interleaved_8pass(interleaved, out,
                                                      rows, cl,
                                                      out_w, out_h);
    free(interleaved);
    return image;
}

u8 *zeliard_mcga_render_a_full(const u8 *planes, size_t planes_size,
                               int rows, int cl, int *out_w, int *out_h) {
    return zeliard_mcga_render_a_full_stride(planes, planes_size, rows, cl,
                                             rows * cl, out_w, out_h);
}

u8 *zeliard_mcga_render_two_plane_da(const u8 *planes, size_t planes_size,
                                     int rows, int cl, int *out_w,
                                     int *out_h) {
    const int bp = rows * cl;
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        u16 src_d = read_be16_or_zero(planes, planes_size,
                                      (size_t)bp + (size_t)si);
        u16 src_a = read_be16_or_zero(planes, planes_size, (size_t)si);
        u16 src_b = 0;
        u16 src_c = 0;

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            interleaved[out++] = (u8)(word & 0xFFu);
            interleaved[out++] = (u8)(word >> 8);
        }
    }

    u8 *image = zeliard_mcga_render_interleaved_8pass(interleaved, out,
                                                      rows, cl,
                                                      out_w, out_h);
    free(interleaved);
    return image;
}

u8 *zeliard_mcga_render_three_plane_ab(const u8 *seg, int base, int bp,
                                       int rows, int cl,
                                       int *out_w, int *out_h) {
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        int a_ofs = (base + si) & 0xFFFF;
        int b_ofs = (base + bp + si) & 0xFFFF;
        int c_ofs = (base + bp * 2 + si) & 0xFFFF;
        u16 src_a = (u16)(((u16)seg[a_ofs] << 8) | seg[(a_ofs + 1) & 0xFFFF]);
        u16 src_b = (u16)(((u16)seg[b_ofs] << 8) | seg[(b_ofs + 1) & 0xFFFF]);
        u16 src_c = (u16)(((u16)seg[c_ofs] << 8) | seg[(c_ofs + 1) & 0xFFFF]);
        u16 src_d = 0;

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            interleaved[out++] = (u8)(word & 0xFFu);
            interleaved[out++] = (u8)(word >> 8);
        }
    }

    u8 *image = zeliard_mcga_render_interleaved_8pass(interleaved, out,
                                                      rows, cl,
                                                      out_w, out_h);
    free(interleaved);
    return image;
}

u8 *zeliard_mcga_render_three_plane_ab_direct(const u8 *seg, int base, int bp,
                                              int rows, int cl,
                                              int *out_w, int *out_h) {
    const size_t image_size = (size_t)rows * 4u * (size_t)cl;
    u8 *image = (u8 *)malloc(image_size ? image_size : 1u);
    if (!image)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        int a_ofs = (base + si) & 0xFFFF;
        int b_ofs = (base + bp + si) & 0xFFFF;
        int c_ofs = (base + bp * 2 + si) & 0xFFFF;
        u16 src_a = (u16)(((u16)seg[a_ofs] << 8) | seg[(a_ofs + 1) & 0xFFFF]);
        u16 src_b = (u16)(((u16)seg[b_ofs] << 8) | seg[(b_ofs + 1) & 0xFFFF]);
        u16 src_c = (u16)(((u16)seg[c_ofs] << 8) | seg[(c_ofs + 1) & 0xFFFF]);
        u16 src_d = 0;

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            if (out + 1u < image_size) {
                image[out++] = (u8)(word & 0xFFu);
                image[out++] = (u8)(word >> 8);
            }
        }
    }

    *out_w = rows * 4;
    *out_h = cl;
    return image;
}

static u16 read_mapped_plane_word(const u8 *seg, int base, int bp,
                                  int plane, int si) {
    if (plane < 0)
        return 0;
    int ofs = (base + plane * bp + si) & 0xFFFF;
    return (u16)(((u16)seg[ofs] << 8) | seg[(ofs + 1) & 0xFFFF]);
}

u8 *zeliard_mcga_render_three_plane_mapped(const u8 *seg, int base, int bp,
                                           int rows, int cl, int map_d,
                                           int map_c, int map_b, int map_a,
                                           int *out_w, int *out_h) {
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        u16 src_d = read_mapped_plane_word(seg, base, bp, map_d, si);
        u16 src_c = read_mapped_plane_word(seg, base, bp, map_c, si);
        u16 src_b = read_mapped_plane_word(seg, base, bp, map_b, si);
        u16 src_a = read_mapped_plane_word(seg, base, bp, map_a, si);

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            interleaved[out++] = (u8)(word & 0xFFu);
            interleaved[out++] = (u8)(word >> 8);
        }
    }

    u8 *image = zeliard_mcga_render_interleaved_8pass(interleaved, out,
                                                      rows, cl,
                                                      out_w, out_h);
    free(interleaved);
    return image;
}

u8 *zeliard_mcga_render_plane_select_interleaved(const u8 *planes,
                                                size_t planes_size,
                                                int rows, int cl,
                                                u8 render_mode,
                                                size_t *out_size) {
    int bp = rows * cl;
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved) {
        *out_size = 0;
        return NULL;
    }

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        size_t cursor = (size_t)si;
        u16 src_a = 0;
        u16 src_b = 0;
        u16 src_c = 0;
        u16 src_d = 0;

        if (render_mode & 1u) {
            src_a = read_be16_or_zero(planes, planes_size, cursor);
            cursor += (size_t)bp;
        }
        if (render_mode & 2u) {
            src_b = read_be16_or_zero(planes, planes_size, cursor);
            cursor += (size_t)bp;
        }
        if (render_mode & 4u)
            src_c = read_be16_or_zero(planes, planes_size, cursor);

        for (int rep = 0; rep < 4; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            interleaved[out++] = (u8)(word & 0xFFu);
            interleaved[out++] = (u8)(word >> 8);
        }
    }

    *out_size = out;
    return interleaved;
}
