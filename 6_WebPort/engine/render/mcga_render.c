#include "mcga_render.h"
#include <stdlib.h>
#include <string.h>

static u16 rotl16(u16 value) {
    return (u16)(((value << 1) & 0xFFFFu) | (value >> 15));
}

static void write_le16_wrap(u8 *dst, size_t size, u16 offset, u16 value) {
    if (size == 0)
        return;
    dst[offset % size] = (u8)value;
    dst[(u16)(offset + 1u) % size] = (u8)(value >> 8);
}

/* 105GDMCA:4469 pal_process_loop.  The original rotates four source words
 * through carry twice per loop, for two loops, then swaps AX's bytes. */
static u16 mcga_driver_pal_process(u16 src[4]) {
    u16 ax = 0;
    for (int loop = 0; loop < 2; loop++) {
        for (int plane = 0; plane < 4; plane++) {
            u16 carry = (u16)(src[plane] >> 15);
            src[plane] = rotl16(src[plane]);
            ax = (u16)((ax << 1) | carry);
        }
        for (int plane = 0; plane < 4; plane++) {
            u16 carry = (u16)(src[plane] >> 15);
            src[plane] = rotl16(src[plane]);
            ax = (u16)((ax << 1) | carry);
        }
    }
    return (u16)((ax << 8) | (ax >> 8));
}

/* 105GDMCA:3A28 plus 39C4.  This renders one 4x4 MCGA animation cell. */
static void mcga_driver_draw_cell(const u8 *seg, u8 frame, u8 row_mask,
                                  u8 col_mask, u16 di, u8 *vga,
                                  size_t vga_size) {
    u16 table = (u16)(0x3A5Fu + ((u16)(frame - 1u) << 3));

    for (int row = 0; row < 4; row++) {
        /* `lodsb` in 3A28 advances SI, so each row consumes the next byte
         * pair from this eight-byte frame record. */
        u16 row_table = (u16)(table + row);
        u8 row_col_mask = col_mask;
        if ((row & 1) != 0)
            row_col_mask = (u8)((row_col_mask >> 1) | (row_col_mask << 7));
        u8 masked = (u8)(seg[row_table] & row_col_mask);
        u8 bits = row_mask;
        /* At 3A34, AH is loaded from [SI+4] while AL still contains the
         * low byte of the frame-table offset established by 39C4. */
        u16 initial = (u16)(((u16)seg[(u16)(row_table + 4)] << 8) |
                            (row_table & 0xFFu));
        u16 src[4] = {0, initial, initial, 0};
        u16 source;

        /* 3A28 shifts AL between the three plane-selection tests. */
        u8 carry = (u8)(bits & 1u);
        bits >>= 1;
        source = (u16)(((u16)masked << 8) | bits);
        if (carry)
            src[3] |= source;
        carry = (u8)(bits & 1u);
        bits >>= 1;
        source = (u16)(((u16)masked << 8) | bits);
        if (carry)
            src[2] |= source;
        carry = (u8)(bits & 1u);
        bits >>= 1;
        source = (u16)(((u16)masked << 8) | bits);
        if (carry)
            src[1] |= source;

        u16 row_di = (u16)(di + row * 0x140);
        write_le16_wrap(vga, vga_size, row_di, mcga_driver_pal_process(src));
        write_le16_wrap(vga, vga_size, (u16)(row_di + 2),
                        mcga_driver_pal_process(src));
    }
}

int zeliard_mcga_disp_font_inv_render_stage(const u8 *driver_seg,
                                            u16 ax_mode,
                                            u8 *vga, size_t vga_size,
                                            int wait_count) {
    if (!driver_seg || !vga || vga_size == 0)
        return -1;

    u16 table_index = (u16)(ax_mode << 1);
    u8 row_mask = driver_seg[(u16)(0x3C16u + table_index)];
    u8 col_mask = driver_seg[(u16)(0x3C17u + table_index)];
    u16 di = 0x1410;
    u16 si = 0x3B1F;

    for (;;) {
        u8 frame = driver_seg[si++];
        if (frame == 0)
            break;
        mcga_driver_draw_cell(driver_seg, frame, row_mask, col_mask, di, vga, vga_size);
        di = (u16)(di + 0x500);
    }
    di = (u16)(di + 0xFB04);
    for (;;) {
        u8 frame = driver_seg[si++];
        if (frame == 0)
            break;
        mcga_driver_draw_cell(driver_seg, frame, row_mask, col_mask, di, vga, vga_size);
        di = (u16)(di + 4);
    }
    di = (u16)(di + 0xFAFC);
    for (;;) {
        u8 frame = driver_seg[si++];
        if (frame == 0)
            break;
        mcga_driver_draw_cell(driver_seg, frame, row_mask, col_mask, di, vga, vga_size);
        di = (u16)(di + 0xFB00);
    }
    di = (u16)(di + 0x04FC);
    for (;;) {
        u8 frame = driver_seg[si++];
        if (frame == 0)
            break;
        mcga_driver_draw_cell(driver_seg, frame, row_mask, col_mask, di, vga, vga_size);
        di = (u16)(di - 4);
    }
    di = (u16)(di + 0x504);

    int waits = 0;
    si = 0x3BE3;
    for (;;) {
        u8 count = driver_seg[si++];
        if (count == 0)
            return waits;
        for (u8 i = 0; i < count; i++) {
            mcga_driver_draw_cell(driver_seg, 0x18, row_mask, col_mask, di, vga, vga_size);
            di = (u16)(di + 0x500);
        }
        di = (u16)(di + 0xFB00);
        count = driver_seg[si++];
        if (count == 0)
            return waits;
        for (u8 i = 0; i < count; i++) {
            mcga_driver_draw_cell(driver_seg, 0x18, row_mask, col_mask, di, vga, vga_size);
            di = (u16)(di + 4);
        }
        di = (u16)(di - 4);
        count = driver_seg[si++];
        if (count == 0)
            return waits;
        for (u8 i = 0; i < count; i++) {
            mcga_driver_draw_cell(driver_seg, 0x18, row_mask, col_mask, di, vga, vga_size);
            di = (u16)(di + 0xFB00);
        }
        di = (u16)(di + 0x500);
        count = driver_seg[si++];
        if (count == 0)
            return waits;
        for (u8 i = 0; i < count; i++) {
            mcga_driver_draw_cell(driver_seg, 0x18, row_mask, col_mask, di, vga, vga_size);
            di = (u16)(di - 4);
        }
        di = (u16)(di + 4);
        waits++;
        if (wait_count > 0 && waits >= wait_count)
            return waits;
    }
}

int zeliard_mcga_disp_font_inv_render(const u8 *driver_seg,
                                      u16 ax_mode,
                                      u8 *vga, size_t vga_size) {
    return zeliard_mcga_disp_font_inv_render_stage(driver_seg, ax_mode,
                                                   vga, vga_size, 0);
}

int zeliard_mcga_anim_fade_decode(const u8 *font_data, size_t font_size,
                                  u16 font_ptr_a, const u8 *stream,
                                  size_t stream_size, u8 *workspace,
                                  size_t workspace_size) {
    if (!font_data || !stream || !workspace || workspace_size < 0x0C80u)
        return -1;

    /* 105GDMCA:32C9 clears CS:4511..5190 before consuming the record. */
    memset(workspace, 0, 0x0C80u);
    size_t stream_pc = 0;
    size_t column = 0;

    while (stream_pc < stream_size) {
        u8 ch = stream[stream_pc++];
        if (ch == 0xFFu)
            return (int)stream_pc;
        if (ch < 0x20u)
            return (int)stream_pc;
        if (ch == 0x20u) {
            column += 8u;
            continue;
        }

        size_t glyph = (size_t)font_ptr_a + (size_t)(ch - 0x20u) * 8u;
        if (glyph + 8u > font_size || column + 8u > 320u)
            return -1;
        for (size_t row = 0; row < 8u; row++) {
            u8 bits = font_data[glyph + row];
            size_t dst = row * 320u + column;
            for (size_t pixel = 0; pixel < 8u; pixel++) {
                workspace[dst + pixel] = (bits & (u8)(0x80u >> pixel))
                    ? 0xFFu : 0x00u;
            }
        }
        column += 8u;
    }

    return -1;
}

static u16 read_le16_wrap(const u8 *src, size_t size, u16 offset) {
    if (!src || size == 0)
        return 0;
    return (u16)((u16)src[offset % size] |
                 ((u16)src[(u16)(offset + 1u) % size] << 8));
}

static u16 mcga_compute_vram_xy_offset(u16 bx) {
    /* 105GDMCA:44E3. BL is the row and BH is the four-pixel column. */
    return (u16)((u16)((u16)(bx & 0x00FFu) * 0x0140u) +
                 (u16)((u16)(bx >> 8) * 4u));
}

int zeliard_mcga_anim_draw_step(const u8 *driver_seg, size_t driver_size,
                                u8 *work_seg, size_t work_size,
                                u8 *vga, size_t vga_size,
                                u16 ax, u16 bx, u16 cx) {
    if (!driver_seg || !work_seg || !vga || driver_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 332C: SI = 4511h + AL * 320. */
    u16 scanline_src = (u16)(0x4511u + (u16)((u8)ax * 0x0140u));

    /* 332C: DI = (CL + BL) * 320. The ADD is byte-sized and wraps. */
    u8 dst_row = (u8)((u8)cx + (u8)bx);
    u16 insert_di = (u16)((u16)dst_row * 0x0140u);

    /* rep movsw from work:0140 to work:0000.  The forward loop matters:
     * this is the exact overlap direction used by the 8086 instruction. */
    for (u32 i = 0; i < 0xFEC0u; i++)
        work_seg[i] = work_seg[0x0140u + i];

    /* rep movsw, CX=A0h, from CS:scanline_src to work:insert_di. */
    for (u16 i = 0; i < 0x0140u; i++)
        work_seg[(u16)(insert_di + i)] = driver_seg[(u16)(scanline_src + i)];

    u16 di = mcga_compute_vram_xy_offset(bx);

    /* The second source address is calculated after restoring BX and uses
     * the original BL/BH fields exactly as the assembly does. */
    u16 source = (u16)((u16)((u8)bx * 0x0140u) +
                        (u16)((u16)(bx >> 8) * 4u));
    u16 rows = (u8)cx;
    /* 3396 copies CH into BL, doubles BX, then makes CX=BX. */
    u16 words = (u16)((u8)(cx >> 8) * 2u);

    for (u16 row = 0; row < rows; row++) {
        for (u16 word = 0; word < words; word++) {
            u16 old_pixel = read_le16_wrap(vga, vga_size, di);
            u16 new_pixel = read_le16_wrap(work_seg, work_size, source);
            write_le16_wrap(vga, vga_size, di,
                            (u16)((old_pixel & 0x9999u) |
                                  (new_pixel & 0x6666u)));
            di = (u16)(di + 2u);
            source = (u16)(source + 2u);
        }
        di = (u16)(di + 0x0140u - (u16)(words * 2u));
    }
    return 0;
}

int zeliard_gmmcga_jashiin_speech_clear(u8 *vga, size_t vga_size,
                                        u16 ax, u16 bx, u16 cx) {
    if (!vga || vga_size < 0x10000u || (u8)ax != 0)
        return -1;

    /* 2049..205F forms DI = BH*320 + AH*4, then 20E8 clears exactly
     * CH*2 words per row and repeats CL times. */
    const size_t x = (size_t)((bx >> 8) & 0xFFu) * 4u;
    const size_t y = (size_t)(bx & 0xFFu);
    const size_t width = (size_t)((cx >> 8) & 0xFFu) * 4u;
    const size_t height = (size_t)(cx & 0xFFu);
    if (x + width > 320u || y + height > 200u)
        return -1;

    for (size_t row = 0; row < height; row++)
        memset(vga + (y + row) * 320u + x, 0, width);
    return 0;
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

u8 *zeliard_mcga_render_a_full_interleaved(const u8 *planes,
                                           size_t planes_size,
                                           int rows, int cl,
                                           int *out_w, int *out_h) {
    const int bp = rows * cl;
    size_t interleaved_size = (size_t)bp * 4u;
    u8 *interleaved = (u8 *)malloc(interleaved_size ? interleaved_size : 1u);
    if (!interleaved)
        return NULL;

    size_t out = 0;
    for (int si = 0; si < bp; si += 2) {
        u16 bx = read_be16_or_zero(planes, planes_size, (size_t)bp + (size_t)si);
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

    *out_w = rows * 4;
    *out_h = cl;
    return interleaved;
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

u8 *zeliard_mcga_render_three_plane_ab_interleaved(const u8 *seg,
                                                   int base, int bp,
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

    *out_w = rows * 4;
    *out_h = cl;
    return interleaved;
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
    u16 src_a = 0;
    u16 src_b = 0;
    u16 src_c = 0;
    u16 src_d = 0;
    for (int si = 0; si < bp; si += 2) {
        size_t cursor = (size_t)si;

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

int zeliard_mcga_disp_drv_seg_3_seed(u8 *vga, size_t vga_size) {
    enum { ROW_BYTES = 0x140, ROWS = 200 };
    if (!vga || vga_size < ROW_BYTES * ROWS)
        return -1;

    /* 105GDMCA:3707.  Each iteration uses REP STOSW with AX=1000h for
     * one scanline and AX=0010h for the next, then advances DI by 0140h. */
    for (size_t row = 0; row < ROWS; row++) {
        const u8 even = (row & 1u) == 0 ? 0x00 : 0x10;
        const u8 odd = (row & 1u) == 0 ? 0x10 : 0x00;
        for (size_t col = 0; col < ROW_BYTES; col += 2) {
            vga[row * ROW_BYTES + col] = even;
            vga[row * ROW_BYTES + col + 1] = odd;
        }
    }
    return 0;
}

static u8 mcga_rol8(u8 value) {
    return (u8)((value << 1) | (value >> 7));
}

/* 105GDMCA:31B4 run_render_passes_mcga, specialized only by accepting the
 * already-established DS:SI source instead of modeling the 8086 stack. */
static void mcga_run_masked_blit_passes(const u8 *work_seg, u16 si,
                                        u16 bx, u16 cx, u8 write_mode,
                                        u8 *vga, int pass_count) {
    static const u8 mask_a[8] = {
        0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01
    };
    static const u8 mask_b[8] = {
        0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80
    };
    const u8 height = (u8)(cx >> 8);
    const u8 width = (u8)cx;
    const u16 initial_di = mcga_compute_vram_xy_offset(bx);

    if (pass_count < 0)
        pass_count = 0;
    if (pass_count > 8)
        pass_count = 8;
    for (u8 pass = 0; pass < (u8)pass_count; pass++) {
        u8 column_counter = pass;
        u16 row_source = si;
        u16 row_di = initial_di;
        for (u8 column = 0; column < width; column++) {
            u8 mask = (column & 1u) == 0
                ? mask_a[column_counter & 7u]
                : mask_b[column_counter & 7u];
            for (u16 byte_index = 0; byte_index < (u16)height * 4u;
                 byte_index++) {
                u8 source = work_seg[(u16)(row_source + byte_index)];
                u8 carry = (u8)(mask >> 7);
                mask = mcga_rol8(mask);
                if (carry) {
                    u16 dst = (u16)(row_di + byte_index);
                    if (write_mode == 1u) {
                        vga[dst] = source;
                    } else if (write_mode == 2u) {
                        if (source != 0)
                            vga[dst] = source;
                    } else {
                        vga[dst] |= source;
                    }
                }
            }
            column_counter++;
            row_source = (u16)(row_source + (u16)height * 4u);
            row_di = (u16)(row_di + 0x0140u);
        }
    }
}

int zeliard_mcga_disp_render_a_rev_stage(u8 *driver_seg, size_t driver_size,
                                         const u8 *game_seg, size_t game_size,
                                         u16 bx, u16 cx, u16 di,
                                         u8 *vga, size_t vga_size,
                                         int pass_count) {
    if (!driver_seg || !game_seg || !vga ||
        driver_size < 0x10000u || game_size < 0x10000u ||
        vga_size < 0x10000u)
        return -1;

    if (pass_count < 0)
        pass_count = 0;
    if (pass_count > 8)
        pass_count = 8;

    /* 30F0 stores 329Dh in render_fn_ptr.  329D is disp_blit_clear:
     * complement BL, rotate one mask bit per VGA byte, and AND a CH*4-byte
     * span for each of CL rows.  DS:SI is restored by 30E4 but never read. */
    static const u8 mask_a[8] = {
        0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01
    };
    static const u8 mask_b[8] = {
        0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80
    };
    const u16 initial_di = mcga_compute_vram_xy_offset(bx);
    const u16 row_bytes = (u16)((u8)(cx >> 8) * 4u);
    const u8 rows = (u8)cx;
    for (u8 pass = 0; pass < (u8)pass_count; pass++) {
        u8 counter = pass;
        u16 row_di = initial_di;
        for (u8 row = 0; row < rows; row++) {
            u8 mask = (u8)~((row & 1u) == 0
                ? mask_a[counter & 7u]
                : mask_b[counter & 7u]);
            for (u16 byte_index = 0; byte_index < row_bytes; byte_index++) {
                u8 carry = (u8)(mask >> 7);
                mask = mcga_rol8(mask);
                vga[(u16)(row_di + byte_index)] &=
                    carry ? 0xFFu : 0x00u;
            }
            counter++;
            row_di = (u16)(row_di + 0x0140u);
        }
    }
    driver_seg[0x4506] = (u8)pass_count;
    driver_seg[0x4505] = (u8)((u8)cx + (u8)pass_count - 1u);
    return 0;
}

int zeliard_mcga_disp_render_a_full_stage(u8 *driver_seg, size_t driver_size,
                                          const u8 *game_seg, size_t game_size,
                                          u8 *work_seg, size_t work_size,
                                          u16 ax, u16 bx, u16 cx, u16 di,
                                          u8 *vga, size_t vga_size,
                                          int pass_count) {
    if (!driver_seg || !game_seg || !work_seg || !vga ||
        driver_size < 0x10000u || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 30FC..3158: BP = CH * CL; DS is ES (game segment), while ES becomes
     * CS+3000h.  The two plane words are read in the 8086's byte-swapped
     * order and expanded by four calls to 4469. */
    const u16 bp = (u16)((u8)(cx >> 8) * (u8)cx);
    u16 source = di;
    u16 output = 0;
    for (u16 remaining = (u16)(bp >> 1); remaining != 0; remaining--) {
        u16 plane_b = (u16)(((u16)game_seg[(u16)(source + bp)] << 8) |
                            game_seg[(u16)(source + bp + 1u)]);
        u16 plane_a = (u16)(((u16)game_seg[source] << 8) |
                            game_seg[(u16)(source + 1u)]);
        source = (u16)(source + 2u);

        u16 overlap = (u16)(plane_b & plane_a);
        u16 src_d = (u16)(plane_b | plane_a);
        u16 src_c = (u16)(plane_b & (u16)~overlap);
        u16 src_b = (u16)(plane_a & (u16)~overlap);
        u16 src_a = 0;
        for (int repeat = 0; repeat < 4; repeat++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            write_le16_wrap(work_seg, 0x10000u, output, word);
            output = (u16)(output + 2u);
        }
    }

    /* 315B..3188: 30FCh selects CS:3277 (`disp_blit_expand`), which first
     * ORs all eight masks when AL is zero, then writes only nonzero pixels.
     * Zero source pixels intentionally preserve the old A000 contents. */
    if (pass_count < 0)
        pass_count = 0;
    if (pass_count > 16)
        pass_count = 16;
    if ((u8)ax == 0)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 0, vga,
                                    pass_count < 8 ? pass_count : 8);
    if (pass_count > 8)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 2, vga,
                                    pass_count - 8);
    driver_seg[0x4506] = (u8)(pass_count > 8 ? pass_count - 8 : pass_count);
    driver_seg[0x4505] = (u8)((u8)cx + driver_seg[0x4506] - 1u);
    driver_seg[0x4508] = pass_count > 8 ? 0xFF : 0x00;
    return 0;
}

int zeliard_mcga_disp_render_a_full(u8 *driver_seg, size_t driver_size,
                                    const u8 *game_seg, size_t game_size,
                                    u8 *work_seg, size_t work_size,
                                    u16 ax, u16 bx, u16 cx, u16 di,
                                    u8 *vga, size_t vga_size) {
    return zeliard_mcga_disp_render_a_full_stage(driver_seg, driver_size,
                                                  game_seg, game_size,
                                                  work_seg, work_size,
                                                  ax, bx, cx, di,
                                                  vga, vga_size, 16);
}

int zeliard_mcga_gfx_update_da_stage(u8 *driver_seg, size_t driver_size,
                                     const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u16 ax, u16 bx, u16 cx, u16 di,
                                     u8 *vga, size_t vga_size,
                                     int pass_count) {
    if (!driver_seg || !game_seg || !work_seg || !vga ||
        driver_size < 0x10000u || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;
    const u16 bp = (u16)((u8)(cx >> 8) * (u8)cx);
    u16 source = di;
    u16 output = 0;
    for (u16 remaining = (u16)(bp >> 1); remaining != 0; remaining--) {
        u16 src_d = (u16)(((u16)game_seg[(u16)(source + bp)] << 8) |
                          game_seg[(u16)(source + bp + 1u)]);
        u16 src_a = (u16)(((u16)game_seg[source] << 8) |
                          game_seg[(u16)(source + 1u)]);
        u16 src_c = 0, src_b = 0;
        source = (u16)(source + 2u);
        for (int repeat = 0; repeat < 4; repeat++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            write_le16_wrap(work_seg, 0x10000u, output, word);
            output = (u16)(output + 2u);
        }
    }
    if (pass_count < 0) pass_count = 0;
    if (pass_count > 16) pass_count = 16;
    if ((u8)ax == 0)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 0, vga,
                                    pass_count < 8 ? pass_count : 8);
    if (pass_count > 8)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 1, vga,
                                    pass_count - 8);
    return 0;
}

int zeliard_mcga_gfx_update_cba_stage(u8 *driver_seg, size_t driver_size,
                                      const u8 *game_seg, size_t game_size,
                                      u8 *work_seg, size_t work_size,
                                      u16 ax, u16 bx, u16 cx, u16 di,
                                      u8 *vga, size_t vga_size,
                                      int pass_count) {
    if (!driver_seg || !game_seg || !work_seg || !vga ||
        driver_size < 0x10000u || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 105GDMCA:3088..30E1.  BP starts as CH*CL.  The loop doubles it for
     * plane C, halves it for plane B, then LODSW supplies plane A. */
    const u16 plane_bytes = (u16)((u8)(cx >> 8) * (u8)cx);
    u16 source = di;
    u16 output = 0;
    for (u16 remaining = (u16)(plane_bytes >> 1); remaining != 0; remaining--) {
        u16 src_c = (u16)(
            ((u16)game_seg[(u16)(source + plane_bytes + plane_bytes)] << 8) |
            game_seg[(u16)(source + plane_bytes + plane_bytes + 1u)]);
        u16 src_b = (u16)(
            ((u16)game_seg[(u16)(source + plane_bytes)] << 8) |
            game_seg[(u16)(source + plane_bytes + 1u)]);
        u16 src_a = (u16)(((u16)game_seg[source] << 8) |
                           game_seg[(u16)(source + 1u)]);
        u16 src_d = 0;
        source = (u16)(source + 2u);
        for (int repeat = 0; repeat < 4; repeat++) {
            const u16 word = zeliard_mcga_pal_process_words(
                &src_d, &src_c, &src_b, &src_a);
            write_le16_wrap(work_seg, 0x10000u, output, word);
            output = (u16)(output + 2u);
        }
    }

    /* 30E4 branches to render_blit_entry, the same two eight-pass masked
     * sequence as the 3032h A/D entry. */
    if (pass_count < 0) pass_count = 0;
    if (pass_count > 16) pass_count = 16;
    if ((u8)ax == 0)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 0, vga,
                                    pass_count < 8 ? pass_count : 8);
    if (pass_count > 8)
        mcga_run_masked_blit_passes(work_seg, 0, bx, cx, 1, vga,
                                    pass_count - 8);
    driver_seg[0x4506] = (u8)(pass_count > 8 ? pass_count - 8 : pass_count);
    driver_seg[0x4505] = (u8)((u8)cx + driver_seg[0x4506] - 1u);
    driver_seg[0x4508] = pass_count > 8 ? 0xFF : 0x00;
    return 0;
}

int zeliard_mcga_sprite_object_init(u8 *driver_seg, size_t driver_size,
                                    const u8 *scene_seg, size_t scene_size,
                                    u16 si) {
    enum {
        SPRITE_OBJECT_TABLE = 0xA000,
        SPRITE_OBJECT_COUNT = 9,
        SPRITE_OBJECT_SIZE = 15,
    };
    if (!driver_seg || !scene_seg || driver_size < 0x10000u ||
        scene_size < 0x10000u)
        return -1;

    /* 105GDMCA:3437.  The source records are x/y, dx/dy, first/last frame.
     * STOS/MOVS use the driver's CS as ES, so every table field remains at
     * its release offset for the following 3465h animation loop. */
    u16 dx = 0;
    u16 di = SPRITE_OBJECT_TABLE;
    for (int object = 0; object < SPRITE_OBJECT_COUNT; object++) {
        const u8 x = scene_seg[si++];
        const u8 y = scene_seg[si++];
        const u8 move_x = scene_seg[si++];
        const u8 move_y = scene_seg[si++];
        const u8 first_frame = scene_seg[si++];
        const u8 last_frame = scene_seg[si++];
        driver_seg[di++] = 1;
        write_le16_wrap(driver_seg, driver_size, di, dx);
        di = (u16)(di + 2u);
        driver_seg[di++] = x;
        driver_seg[di++] = y;
        /* MOVSW copies x/y but leaves AX holding DX from the preceding
         * MOV AX,DX; the following STOSW stores that same offset again. */
        write_le16_wrap(driver_seg, driver_size, di, dx);
        di = (u16)(di + 2u);
        write_le16_wrap(driver_seg, driver_size, di, 0x0101);
        di = (u16)(di + 2u);
        driver_seg[di++] = move_x;
        driver_seg[di++] = move_y;
        driver_seg[di++] = 0;
        driver_seg[di++] = 0;
        driver_seg[di++] = first_frame;
        driver_seg[di++] = last_frame;
        dx = (u16)(dx + 0x0300u);
    }
    driver_seg[0x4505] = 0;
    driver_seg[0xFF1A] = 0;
    return 0;
}

static u16 mcga_vram_xy_offset(u8 y, u8 x_cell) {
    return (u16)((u16)y * 0x0140u + (u16)x_cell * 4u);
}

static u16 sprite_read_le16(const u8 *seg, u16 off) {
    return (u16)(seg[off] | ((u16)seg[(u16)(off + 1u)] << 8));
}

static void or_le16_seg(u8 *seg, u16 off, u16 value) {
    const u16 old = (u16)(seg[off] | ((u16)seg[(u16)(off + 1u)] << 8));
    write_le16_wrap(seg, 0x10000u, off, (u16)(old | value));
}

int zeliard_mcga_sprite_frame_prepare(u8 *driver_seg, size_t driver_size,
                                      const u8 *game_seg, size_t game_size,
                                      u8 *work_seg, size_t work_size,
                                      u8 *vga, size_t vga_size) {
    enum { TABLE = 0xA000, COUNT = 9, SIZE = 15, FRAME_TBL = 0x3617,
           SRC_TBL = 0x3619, CUR_COL = 0x4505 };
    if (!driver_seg || !game_seg || !work_seg || !vga ||
        driver_size < 0x10000u || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 3465..34D1: advance each active object and copy its A000 rectangle to
     * the packed CS+3000h backing store selected during initialization. */
    for (u16 index = 0; index < COUNT; index++) {
        const u16 object = (u16)(TABLE + index * SIZE);
        if (driver_seg[object] == 0)
            continue;
        if (driver_seg[(u16)(object + 13u)] != driver_seg[(u16)(object + 14u)]) {
            driver_seg[(u16)(object + 12u)]++;
            if ((driver_seg[(u16)(object + 12u)] & 1u) == 0)
                driver_seg[(u16)(object + 13u)]++;
        }
        const u8 frame = driver_seg[(u16)(object + 13u)];
        const u16 cx = sprite_read_le16(driver_seg, (u16)(SRC_TBL + frame * 4u));
        write_le16_wrap(driver_seg, driver_size, (u16)(object + 7u), cx);
        driver_seg[(u16)(object + 4u)] =
            (u8)(driver_seg[(u16)(object + 4u)] + driver_seg[(u16)(object + 10u)]);
        driver_seg[(u16)(object + 3u)] =
            (u8)(driver_seg[(u16)(object + 3u)] + driver_seg[(u16)(object + 9u)]);
        const u16 dst = mcga_vram_xy_offset(driver_seg[(u16)(object + 3u)],
                                            driver_seg[(u16)(object + 4u)]);
        write_le16_wrap(driver_seg, driver_size, (u16)(object + 5u), dst);
        const u16 backup = (u16)(driver_seg[(u16)(object + 1u)] |
                                 ((u16)driver_seg[(u16)(object + 2u)] << 8));
        const u8 row_bytes = (u8)((u8)(cx >> 8) * 4u);
        for (u8 row = 0; row < (u8)cx; row++)
            for (u8 col = 0; col < row_bytes; col++)
                work_seg[(u16)(backup + (u16)row * row_bytes + col)] =
                    vga[(u16)(dst + (u16)row * 0x0140u + col)];
    }

    /* 34D3..3543: one DAC-cycle advance per object, followed by 35CCh for
     * active on-screen objects. DAC I/O has no A000/work-memory effect here;
     * retain the driver's observable cycle counter while rendering its pixels. */
    for (u16 index = 0; index < COUNT; index++) {
        const u16 object = (u16)(TABLE + index * SIZE);
        driver_seg[CUR_COL]++;
        const u8 active = driver_seg[object];
        if (active == 0)
            continue;
        const u8 y = driver_seg[(u16)(object + 3u)];
        const u8 x = driver_seg[(u16)(object + 4u)];
        /* 3515..3528: clear first, then reinstate DL only while the sprite
         * still falls inside the driver's x/y clip bounds. */
        driver_seg[object] = 0;
        if (x >= 0x4B || y >= 0xA0)
            continue;
        driver_seg[object] = active;
        const u8 frame = driver_seg[(u16)(object + 13u)];
        const u16 source = sprite_read_le16(driver_seg, (u16)(FRAME_TBL + frame * 4u));
        const u16 cx = (u16)(driver_seg[(u16)(object + 7u)] |
                             ((u16)driver_seg[(u16)(object + 8u)] << 8));
        const u16 plane_bytes = (u16)((u8)(cx >> 8) * (u8)cx);
        u16 si = source;
        u16 di = (u16)(driver_seg[(u16)(object + 5u)] |
                       ((u16)driver_seg[(u16)(object + 6u)] << 8));
        for (u8 row = 0; row < (u8)cx; row++) {
            for (u8 col = 0; col < (u8)(cx >> 8); col++) {
                u16 src_d = 0;
                u16 src_b = (u16)((u16)game_seg[(u16)(si + plane_bytes)] << 8);
                u16 src_a = (u16)((u16)game_seg[si] << 8);
                u16 src_c = src_a;
                si++;
                or_le16_seg(vga, di, zeliard_mcga_pal_process_words(
                    &src_d, &src_c, &src_b, &src_a));
                or_le16_seg(vga, (u16)(di + 2u), zeliard_mcga_pal_process_words(
                    &src_d, &src_c, &src_b, &src_a));
                di = (u16)(di + 4u);
            }
            di = (u16)(di + 0x0140u - (u16)(cx >> 8) * 4u);
        }
    }
    return 0;
}

int zeliard_mcga_sprite_objects_active(const u8 *driver_seg, size_t driver_size) {
    enum { TABLE = 0xA000, COUNT = 9, SIZE = 15 };
    if (!driver_seg || driver_size < 0x10000u)
        return 0;
    for (u16 index = 0; index < COUNT; index++)
        if (driver_seg[(u16)(TABLE + index * SIZE)] != 0)
            return 1;
    return 0;
}

int zeliard_mcga_sprite_frame_restore(u8 *driver_seg, size_t driver_size,
                                      const u8 *work_seg, size_t work_size,
                                      u8 *vga, size_t vga_size) {
    enum { TABLE = 0xA000, COUNT = 9, SIZE = 15 };
    if (!driver_seg || !work_seg || !vga || driver_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 3544 waits for FF1A >= 1Eh; its next instruction clears that byte.
     * The caller owns waiting, while this helper owns the exact 3552h copy. */
    driver_seg[0xFF1A] = 0;
    for (u16 index = 0; index < COUNT; index++) {
        const u16 object = (u16)(TABLE + index * SIZE);
        const u16 backup = sprite_read_le16(driver_seg, (u16)(object + 1u));
        const u16 dst = sprite_read_le16(driver_seg, (u16)(object + 5u));
        const u16 cx = sprite_read_le16(driver_seg, (u16)(object + 7u));
        const u8 row_bytes = (u8)((u8)(cx >> 8) * 4u);
        for (u8 row = 0; row < (u8)cx; row++)
            for (u8 col = 0; col < row_bytes; col++)
                vga[(u16)(dst + (u16)row * 0x0140u + col)] =
                    work_seg[(u16)(backup + (u16)row * row_bytes + col)];
    }
    return 0;
}

int zeliard_mcga_disp_render_ab_gseg(const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u8 al, u16 bx,
                                     u8 *vga, size_t vga_size) {
    enum { PAGE_BASE = 0x97C0, PAGE_SIZE = 0x0480, PLANE_SIZE = 0x0240,
           WORD_COUNT = 0x0120, BLIT_CX = 0x1220 };
    if (!game_seg || !work_seg || !vga || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 36AB..3704.  The xchg instructions make both source words big-endian
     * while the four pal_process_loop results are stored little-endian. */
    u16 source = (u16)(PAGE_BASE + (u16)al * PAGE_SIZE);
    u16 output = 0;
    for (u16 word = 0; word < WORD_COUNT; word++) {
        u16 src_b = (u16)(((u16)game_seg[(u16)(source + PLANE_SIZE)] << 8) |
                          game_seg[(u16)(source + PLANE_SIZE + 1u)]);
        u16 src_a = (u16)(((u16)game_seg[source] << 8) |
                          game_seg[(u16)(source + 1u)]);
        u16 src_d = 0, src_c = 0;
        source = (u16)(source + 2u);
        for (int repeat = 0; repeat < 4; repeat++) {
            write_le16_wrap(work_seg, work_size, output,
                            zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                           &src_b, &src_a));
            output = (u16)(output + 2u);
        }
    }

    /* 3701 jumps to blit_vga_entry. BX still belongs to the caller; CH is
     * the source width in 16-bit words and CL is the row count. */
    u16 src = 0;
    u16 dst = mcga_compute_vram_xy_offset(bx);
    const u16 bytes_per_row = (u16)((u8)(BLIT_CX >> 8) * 4u);
    const u8 rows = (u8)BLIT_CX;
    for (u8 row = 0; row < rows; row++) {
        for (u16 col = 0; col < bytes_per_row; col++)
            vga[(u16)(dst + col)] = work_seg[(u16)(src + col)];
        src = (u16)(src + bytes_per_row);
        dst = (u16)(dst + 0x0140u);
    }
    return 0;
}

int zeliard_mcga_disp_render_ab_ab40(const u8 *game_seg, size_t game_size,
                                     u8 *work_seg, size_t work_size,
                                     u8 al, u16 bx,
                                     u8 *vga, size_t vga_size) {
    enum { PAGE_BASE = 0xAB40, PAGE_SIZE = 0x0CC0, PLANE_SIZE = 0x0660,
           WORD_COUNT = 0x0330, BLIT_CX = 0x2230 };
    if (!game_seg || !work_seg || !vga || game_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 364F..36A8. This entry differs from 36AB in both page geometry and
     * plane assignment: the high plane becomes src_a before pal_process. */
    u16 source = (u16)(PAGE_BASE + (u16)al * PAGE_SIZE);
    u16 output = 0;
    for (u16 word = 0; word < WORD_COUNT; word++) {
        u16 src_a = (u16)(((u16)game_seg[(u16)(source + PLANE_SIZE)] << 8) |
                          game_seg[(u16)(source + PLANE_SIZE + 1u)]);
        u16 src_b = (u16)(((u16)game_seg[source] << 8) |
                          game_seg[(u16)(source + 1u)]);
        u16 src_d = 0, src_c = 0;
        source = (u16)(source + 2u);
        for (int repeat = 0; repeat < 4; repeat++) {
            write_le16_wrap(work_seg, work_size, output,
                            zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                           &src_b, &src_a));
            output = (u16)(output + 2u);
        }
    }

    u16 src = 0;
    u16 dst = mcga_compute_vram_xy_offset(bx);
    const u16 bytes_per_row = (u16)((u8)(BLIT_CX >> 8) * 4u);
    const u8 rows = (u8)BLIT_CX;
    for (u8 row = 0; row < rows; row++) {
        for (u16 col = 0; col < bytes_per_row; col++)
            vga[(u16)(dst + col)] = work_seg[(u16)(src + col)];
        src = (u16)(src + bytes_per_row);
        dst = (u16)(dst + 0x0140u);
    }
    return 0;
}

static u16 read_le16_seg(const u8 *seg, u16 offset) {
    return (u16)((u16)seg[offset] |
                 ((u16)seg[(u16)(offset + 1u)] << 8));
}

static void write_le16_seg(u8 *seg, u16 offset, u16 value) {
    seg[offset] = (u8)value;
    seg[(u16)(offset + 1u)] = (u8)(value >> 8);
}

/* 105GDMCA:4485.  The four ROL/SBB operations make byte masks from the
 * carry bits while leaving the rotated source mask in memory. */
static u16 mcga_rotate_mask_word(u16 *mask) {
    u8 al, ah, dl;
    u16 carry = (u16)(*mask >> 15);
    *mask = rotl16(*mask);
    al = carry ? 0xFFu : 0x00u;
    carry = (u16)(*mask >> 15);
    *mask = rotl16(*mask);
    ah = carry ? 0xFFu : 0x00u;
    al |= ah;
    carry = (u16)(*mask >> 15);
    *mask = rotl16(*mask);
    dl = carry ? 0xFFu : 0x00u;
    carry = (u16)(*mask >> 15);
    *mask = rotl16(*mask);
    ah = carry ? 0xFFu : 0x00u;
    ah |= dl;
    return (u16)(((u16)ah << 8) | al);
}

/* 105GDMCA:4469.  AX is intentionally an input: 37B4 passes the byte mask
 * returned by 4485 into this routine, then carries its output into A000. */
static u16 mcga_driver_pal_process_from(u16 ax, u16 src[4]) {
    for (int loop = 0; loop < 2; loop++) {
        for (int plane = 0; plane < 4; plane++) {
            u16 carry = (u16)(src[plane] >> 15);
            src[plane] = rotl16(src[plane]);
            ax = (u16)((ax << 1) | carry);
        }
        for (int plane = 0; plane < 4; plane++) {
            u16 carry = (u16)(src[plane] >> 15);
            src[plane] = rotl16(src[plane]);
            ax = (u16)((ax << 1) | carry);
        }
    }
    return (u16)((ax << 8) | (ax >> 8));
}

static u8 mcga_reverse_byte_with_ah(u8 value, u8 *ah) {
    for (int count = 0; count < 8; count++) {
        u8 carry = (u8)(value & 1u);
        value = (u8)((value >> 1) | (carry << 7));
        *ah = (u8)((*ah << 1) | carry);
    }
    return *ah;
}

int zeliard_mcga_disp_tile_render(u8 *driver_seg, size_t driver_size,
                                  const u8 *work_seg, size_t work_size,
                                  u8 al, u8 *vga, size_t vga_size) {
    enum {
        SCRATCH = 0x5191,
        PLANE_B = 0x1A6E,
        MASK = 0x1A8E,
        ROW_BYTES = 0x22,
        WORDS_PER_HALF = 0x11,
    };
    if (!driver_seg || !work_seg || !vga || driver_size < 0x10000u ||
        work_size < 0x10000u || vga_size < 0x10000u)
        return -1;

    /* 37BF..37E8: copy two CS+2000h planes to CS:5191h, preserving the
     * high byte that MUL left in AH across the consecutive bit reversals. */
    const u16 source = (u16)((u16)al * ROW_BYTES);
    u8 ah = (u8)(((u16)al * ROW_BYTES) >> 8);
    for (u16 i = 0; i < ROW_BYTES; i++)
        driver_seg[(u16)(SCRATCH + i)] =
            mcga_reverse_byte_with_ah(work_seg[(u16)(source + i)], &ah);
    for (u16 i = 0; i < ROW_BYTES; i++)
        driver_seg[(u16)(SCRATCH + ROW_BYTES + i)] =
            mcga_reverse_byte_with_ah(work_seg[(u16)(source + ROW_BYTES + PLANE_B + i)], &ah);

    /* 37FA calls 44E3 with BL=AL and BH=0: DI = AL * 320. */
    u16 di = (u16)((u16)al * 0x0140u);
    u16 si = source;
    for (int half = 0; half < 2; half++) {
        const u16 base_di = di;
        for (int word = 0; word < WORDS_PER_HALF; word++) {
            const u8 *read_seg = half == 0 ? work_seg : driver_seg;
            u16 ax = read_le16_seg(read_seg, si);
            si = (u16)(si + 2u);
            ax = (u16)((ax << 8) | (ax >> 8)); /* LODSW; XCHG AH,AL */
            u16 bx = read_le16_seg(read_seg, (u16)(si + (half == 0 ? MASK : 0x20u)));
            bx = (u16)((bx << 8) | (bx >> 8));
            const u16 src_a = (u16)(ax & bx);
            u16 src[4] = {bx, bx, bx, src_a}; /* D,C,B,A */
            u16 mask = (u16)~(ax | bx);
            static const u16 first_offsets[4] = {0, 2, 4, 6};
            static const u16 second_offsets[4] = {4, 6, 0, 2};
            const u16 *offsets = half == 0 ? first_offsets : second_offsets;
            for (int pixel = 0; pixel < 4; pixel++) {
                u16 ax_mask = mcga_rotate_mask_word(&mask);
                u16 pixels = mcga_driver_pal_process_from(ax_mask, src);
                u16 dst = (u16)(di + offsets[pixel]);
                u16 old = read_le16_seg(vga, dst);
                write_le16_seg(vga, dst, (u16)((old & ax_mask) | pixels));
            }
            di = half == 0 ? (u16)(di + 8u) : (u16)(di - 8u);
        }
        if (half == 0) {
            si = SCRATCH;
            di = (u16)(base_di + 0x0138u);
        }
    }
    return 0;
}

int zeliard_mcga_disp_tilemap_render(const u8 *table_seg, size_t table_size,
                                     u16 si, const u8 *game_seg,
                                     size_t game_size, u8 *work_seg,
                                     size_t work_size) {
    enum { TILE_ROWS = 0x19, TILE_COLS = 0x22, TILE_W = 0x28,
           TILE_H = 8, GAME_FRAME = 0x4000, SRC_ROW = 0x28,
           DST_ROW = 0x22, DST_TILE_ROW = 0x110,
           DST_PLANE = 0x1A90, SRC_PLANE = 0x640 };
    if (!table_seg || !game_seg || !work_seg || table_size < 0x10000u ||
        game_size < 0x10000u ||
        work_size < 0x10000u)
        return -1;

    /* 105GDMCA:3732 through compute_tile_vram_offset_mcga.  All source and
     * destination arithmetic is 16-bit, exactly like SI/DI on the 8086. */
    for (u16 row = 0; row < TILE_ROWS; row++) {
        for (u16 col = 0; col < TILE_COLS; col++) {
            u8 tile = table_seg[si++];
            u16 src = (u16)(GAME_FRAME +
                (u16)((tile / TILE_W) * 0x140u) + (tile % TILE_W));
            /* 36E7 first clears DH, so MUL receives BL (the row) only;
             * BH (the column) is added after the multiplication. */
            u16 dst = (u16)(row * DST_TILE_ROW + col);
            for (u16 plane = 0; plane < 3; plane++) {
                u16 plane_src = (u16)(src + plane * SRC_PLANE);
                u16 plane_dst = (u16)(dst + plane * DST_PLANE);
                for (u16 y = 0; y < TILE_H; y++)
                    work_seg[(u16)(plane_dst + y * DST_ROW)] =
                        game_seg[(u16)(plane_src + y * SRC_ROW)];
            }
        }
    }
    return 0;
}
