/* GRP decoder — see grp.h for the pipeline overview.
 *
 * Validation against the assembly source of truth
 * (per feedback_port_validates_against_asm.md):
 *
 *  - decode_6de1():  line-for-line port of `decode_rle_to_es_di`
 *      at 3_Assembly/masm/working/zelres1/code/100OPDMO.asm:1561-1595.
 *      Identical dispatch: bit 6 = 2-byte mode, bit 7/15 = fill, 0xFFFF
 *      = end-of-stream.  Direct asm-to-C transliteration of the body.
 *
 *  - interleave_4plane():  ports the 2-plane → nibble-packed-4-plane
 *      pipeline.  Canonical asm: `render_plane_abc_loop` at
 *      3_Assembly/masm/working/zelres1/code/105GDMCA.asm:234-255.
 *      That loop loads a word from plane A (lodsw+xchg) and plane B
 *      (ds:[bp+si]+xchg), computes dx=NOT(A AND B), cx=A OR B,
 *      ax=A AND dx, bx=B AND dx, stores into src_word_a/b/c/d, then
 *      calls `pal_process_loop` (105GDMCA.asm:2344-2371) four times.
 *      pal_process_loop rotates all four src_words left through carry
 *      twice per call (inner CX=2 loop, 8 rol+adc pairs per iteration),
 *      accumulating bits into AX.  Each call emits one output word (AX
 *      after xchg ah,al).  Four calls per source word-pair = 4 output
 *      words = 8 nibble-packed output bytes per 16 source pixels.
 *      Output-parity validated against 3_Assembly/dumps/zeliard_title_image.BIN.
 *
 *  - render_8pass_blit():  ports the 8-pass mask-table blit.  Canonical
 *      asm: `run_render_passes_mcga` at 105GDMCA.asm:307-362.  That proc
 *      runs bp=8 outer passes; each pass iterates cl blit_calls alternating
 *      mask_tbl_a[bx&7] (even calls) and mask_tbl_b[bx&7] (odd calls) where
 *      bx starts at cur_row_ctr and increments each call.  mask_tbl_a and
 *      mask_tbl_b are EQU'd to cs:32B9h and cs:32C1h (105GDMCA.asm:47-48)
 *      and contain [80,20,08,02,40,10,04,01] / [01,04,10,40,02,08,20,80]
 *      (confirmed via Python reference + 100% parity vs golden BIN).
 */

#include "grp.h"
#include "fill_buffer.h"
#include "../platform/platform.h"
#include <stdlib.h>
#include <string.h>

/* ---- 0x6DE1 RLE decoder ------------------------------------------------- */
/* Operates on raw chunk data (after 4-byte header + fill_buffer opcode).
 *   1-byte mode (bit 6 = 0):  b & 0x3F = count
 *      bit 7 = 0  → copy `count` literal bytes
 *      bit 7 = 1  → emit next byte `count` times
 *   2-byte mode (bit 6 = 1):  big-endian word (b<<8|next) & 0x3FFF = count
 *      bit 15 = 0  → copy `count` literal bytes
 *      bit 15 = 1  → emit next byte `count` times
 *      0xFFFF      → end of stream
 */
static u8* decode_6de1(const u8 *src, size_t src_size, size_t *out_size) {
    /* Output can be much larger than input.  4x is generous for these images. */
    size_t cap = src_size * 8 + 1024;
    u8 *out = (u8*)malloc(cap);
    if (!out) { *out_size = 0; return NULL; }
    size_t n = 0;

    #define EMIT(byte) do { \
        if (n >= cap) { cap *= 2; u8 *t = realloc(out, cap); if (!t) { free(out); *out_size = 0; return NULL; } out = t; } \
        out[n++] = (byte); \
    } while (0)

    size_t i = 0;
    while (i < src_size) {
        u8 b = src[i];
        if (b & 0x40) {
            /* 2-byte mode */
            if (i + 1 >= src_size) break;
            u16 word = ((u16)b << 8) | src[i + 1];
            i += 2;
            if (word == 0xFFFF) break;
            u16 count = word & 0x3FFF;
            if (word & 0x8000) {
                if (i < src_size) {
                    u8 v = src[i++];
                    for (u16 k = 0; k < count; k++) EMIT(v);
                }
            } else {
                for (u16 k = 0; k < count && i < src_size; k++) EMIT(src[i++]);
            }
        } else {
            /* 1-byte mode */
            u8 count = b & 0x3F;
            i++;
            if (b & 0x80) {
                if (i < src_size) {
                    u8 v = src[i++];
                    for (u8 k = 0; k < count; k++) EMIT(v);
                }
            } else {
                for (u8 k = 0; k < count && i < src_size; k++) EMIT(src[i++]);
            }
        }
    }
    #undef EMIT

    *out_size = n;
    return out;
}

/* ---- 4-plane interleaver (two variants) ---------------------------------- */
/* Both variants port pal_process_loop (105GDMCA.asm:2344-2371): rotate each
 * src_word left through carry, accumulate MSBs into output word, xchg bytes.
 * The difference is the src_word assignment before the loop:
 *
 *  render_plane_abc_loop (105GDMCA.asm:234-255) — used by grp_decode,
 *    grp_decode_planes, and ttl3.grp (validated vs golden BIN):
 *      planes = { A|B, B&~AB, A&~AB, 0 } → nibble values 0/0xA/0xC/0x8
 *
 *  render_plane_a_loop (105GDMCA.asm:141-152) — used by gfx_draw_fn
 *    (100OPDMO.asm:318, nec.grp, dmaou.grp, etc.):
 *      planes = { B, 0, 0, A } → nibble values 0/0x1/0x8/0x9
 */

/* render_plane_abc_loop variant: planes = {A|B, B&~AB, A&~AB, 0}.
 * Ports render_plane_abc_loop (105GDMCA.asm:234-255) + pal_process_loop
 * (105GDMCA.asm:2344-2371).  Reads word-pairs from plane A (at SI) and
 * plane B (at SI+BP), derives AND/OR/NOT-AND logic for the 4 src_words,
 * then rotates them through carry to build nibble-packed output. */
static u8* interleave_4plane_impl(const u8 *src, size_t src_size,
                             int rows, int cl, size_t *out_size) {
    int BP = rows * cl;
    if ((size_t)(BP * 2) > src_size) {
        platform_log("interleave_4plane: src too small (%zu < %d)", src_size, BP * 2);
        *out_size = 0;
        return NULL;
    }
    /* BP*8 pixels / 2 = BP*4 output bytes; build whole buffer then return. */
    size_t cap = (size_t)BP * 4;
    u8 *out = (u8*)malloc(cap);
    if (!out) { *out_size = 0; return NULL; }
    size_t out_n = 0;

    int si = 0;
    int word_pairs = BP / 2;
    for (int it = 0; it < word_pairs; it++) {
        int bi = BP + si;
        u16 ax = ((u16)src[si] << 8) | (u16)src[si + 1];
        u16 bx = ((u16)src[bi] << 8) | (u16)src[bi + 1];
        si += 2;

        u16 dx = (~(bx & ax)) & 0xFFFF;
        u16 cx = (bx | ax) & 0xFFFF;
        ax = (u16)(ax & dx);
        bx = (u16)(bx & dx);
        u16 planes[4] = { cx, bx, ax, 0 };

        for (int rep = 0; rep < 4; rep++) {
            u16 pw[4] = { planes[0], planes[1], planes[2], planes[3] };
            u16 acc = 0;
            for (int r1 = 0; r1 < 2; r1++) {
                for (int r2 = 0; r2 < 2; r2++) {
                    for (int j = 0; j < 4; j++) {
                        u16 msb = (u16)(pw[j] >> 15);
                        pw[j] = (u16)(((pw[j] << 1) & 0xFFFF) | msb);
                        acc = (u16)(((acc << 1) | msb) & 0xFFFF);
                    }
                }
            }
            for (int j = 0; j < 4; j++) planes[j] = pw[j];
            u16 swapped = (u16)(((acc & 0xFF) << 8) | ((acc >> 8) & 0xFF));
            out[out_n++] = (u8)(swapped & 0xFF);
            out[out_n++] = (u8)(swapped >> 8);
        }
    }
    *out_size = out_n;
    return out;
}

/* render_plane_a_loop variant: planes = {B, 0, 0, A} → nibble values 0/1/8/9.
 * Ports render_plane_a_loop (105GDMCA.asm:141-152) used by gfx_draw_fn. */
static u8* interleave_gfx_draw_impl(const u8 *src, size_t src_size,
                                    int rows, int cl, size_t *out_size) {
    int BP = rows * cl;
    if ((size_t)(BP * 2) > src_size) {
        platform_log("interleave_gfx_draw: src too small (%zu < %d)", src_size, BP * 2);
        *out_size = 0;
        return NULL;
    }
    size_t cap = (size_t)BP * 4;
    u8 *out = (u8*)malloc(cap);
    if (!out) { *out_size = 0; return NULL; }
    size_t out_n = 0;

    int si = 0;
    int word_pairs = BP / 2;
    for (int it = 0; it < word_pairs; it++) {
        int bi = BP + si;
        u16 ax = ((u16)src[si] << 8) | (u16)src[si + 1];   /* plane A */
        u16 bx = ((u16)src[bi] << 8) | (u16)src[bi + 1];   /* plane B */
        si += 2;

        /* src_word_d=B, src_word_c=0, src_word_b=0, src_word_a=A */
        u16 planes[4] = { bx, 0, 0, ax };

        for (int rep = 0; rep < 4; rep++) {
            u16 pw[4] = { planes[0], planes[1], planes[2], planes[3] };
            u16 acc = 0;
            for (int r1 = 0; r1 < 2; r1++) {
                for (int r2 = 0; r2 < 2; r2++) {
                    for (int j = 0; j < 4; j++) {
                        u16 msb = (u16)(pw[j] >> 15);
                        pw[j] = (u16)(((pw[j] << 1) & 0xFFFF) | msb);
                        acc = (u16)(((acc << 1) | msb) & 0xFFFF);
                    }
                }
            }
            for (int j = 0; j < 4; j++) planes[j] = pw[j];
            u16 swapped = (u16)(((acc & 0xFF) << 8) | ((acc >> 8) & 0xFF));
            out[out_n++] = (u8)(swapped & 0xFF);
            out[out_n++] = (u8)(swapped >> 8);
        }
    }
    *out_size = out_n;
    return out;
}

/* ---- 8-pass mask blit (renders to a `call_size x blit_calls` image) ---- */
/* Ports run_render_passes_mcga (105GDMCA.asm:307-362).  8 outer passes (bp=8);
 * each pass iterates blit_calls columns, alternating mask_tbl_a[k&7] for even
 * calls and mask_tbl_b[k&7] for odd calls (EQU'd at cs:32B9h/32C1h, lines
 * 47-48).  Within each call the mask bit selects which of the 8 mod-8
 * positions to copy.  8 passes combined via OR reconstruct all positions. */
static int find_set_bit_pos(u8 mask) {
    /* The original x86 code rotates left and counts shifts until carry-out.
     * Equivalent: bit position of the set bit, counting from MSB. */
    u8 bl = mask;
    for (int s = 0; s < 8; s++) {
        int cf = (bl >> 7) & 1;
        bl = (u8)(((bl << 1) & 0xFF) | cf);
        if (cf) return s;
    }
    return -1;
}

static u8* render_8pass_blit_impl(const u8 *interleaved, size_t interleaved_size,
                             int rows, int cl, int *out_w, int *out_h) {
    static const u8 mask1[8] = { 0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01 };
    static const u8 mask2[8] = { 0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80 };

    int call_size  = rows * 4;
    int blit_calls = cl;
    *out_w = call_size;
    *out_h = blit_calls;

    int m1p[8], m2p[8];
    for (int k = 0; k < 8; k++) { m1p[k] = find_set_bit_pos(mask1[k]); m2p[k] = find_set_bit_pos(mask2[k]); }

    size_t out_n = (size_t)call_size * (size_t)blit_calls;
    u8 *vga = (u8*)calloc(out_n, 1);
    if (!vga) return NULL;

    for (int start_k = 0; start_k < 8; start_k++) {
        int k = start_k;
        for (int n = 0; n < blit_calls; n++) {
            int wp = (n & 1) ? m2p[k & 7] : m1p[k & 7];
            for (int i = 0; i < call_size; i++) {
                if ((i & 7) == wp) {
                    size_t src_idx = (size_t)n * (size_t)call_size + (size_t)i;
                    if (src_idx < interleaved_size) {
                        vga[src_idx] |= interleaved[src_idx];
                    }
                }
            }
            k++;
        }
    }
    return vga;
}

/* ---- public API --------------------------------------------------------- */

u8* grp_decode(const u8 *file_data, size_t file_size,
               int rows, int cl,
               int *out_w, int *out_h) {
    /* fill_buffer_decompress handles all 8 compression methods (including
     * method 0 = verbatim for ttl3.grp, and methods 5/6/7 for other GRPs).
     * It strips the 4-byte SAR size header, the 1-byte flag, and the 1-byte
     * fill_buffer method byte, returning the raw 6DE1 stream. */
    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    if (!payload || payload_size == 0) {
        platform_log("grp_decode: fill_buffer_decompress failed");
        return NULL;
    }

    size_t decoded_size = 0;
    u8 *decoded = decode_6de1(payload, payload_size, &decoded_size);
    free(payload);
    if (!decoded) {
        platform_log("grp_decode: 6DE1 decode failed");
        return NULL;
    }
    platform_log("grp_decode: payload=%zu decoded=%zu", payload_size, decoded_size);

    size_t interleaved_size = 0;
    u8 *interleaved = interleave_4plane_impl(decoded, decoded_size, rows, cl, &interleaved_size);
    free(decoded);
    if (!interleaved) {
        platform_log("grp_decode: interleave failed");
        return NULL;
    }
    platform_log("grp_decode: interleaved=%zu (rows=%d cl=%d)", interleaved_size, rows, cl);

    int w = 0, h = 0;
    u8 *image = render_8pass_blit_impl(interleaved, interleaved_size, rows, cl, &w, &h);
    free(interleaved);
    if (!image) {
        platform_log("grp_decode: blit failed");
        return NULL;
    }
    platform_log("grp_decode: image %dx%d ready", w, h);

    *out_w = w; *out_h = h;
    return image;
}

/* Takes already-decompressed 2-plane 1bpp data; runs render_plane_abc_loop
 * interleave (planes = {A|B, B&~AB, A&~AB, 0}) + 8-pass blit.
 * Used by the opening-scene img_open pipeline (disp_narr_chap3 path). */
u8* grp_decode_planes(const u8 *planes, size_t planes_size,
                      int rows, int cl, int *out_w, int *out_h) {
    size_t interleaved_size = 0;
    u8 *interleaved = interleave_4plane_impl(planes, planes_size, rows, cl, &interleaved_size);
    if (!interleaved) {
        platform_log("grp_decode_planes: interleave failed");
        return NULL;
    }
    int w = 0, h = 0;
    u8 *image = render_8pass_blit_impl(interleaved, interleaved_size, rows, cl, &w, &h);
    free(interleaved);
    if (!image) {
        platform_log("grp_decode_planes: blit failed");
        return NULL;
    }
    *out_w = w; *out_h = h;
    return image;
}

/* Same but uses render_plane_a_loop interleave (planes = {B, 0, 0, A}).
 * Used by gfx_draw_fn scenes (nec.grp, dmaou.grp — 100OPDMO.asm:318). */
u8* grp_decode_planes_gfx_draw(const u8 *planes, size_t planes_size,
                                int rows, int cl, int *out_w, int *out_h) {
    size_t interleaved_size = 0;
    u8 *interleaved = interleave_gfx_draw_impl(planes, planes_size, rows, cl, &interleaved_size);
    if (!interleaved) {
        platform_log("grp_decode_planes_gfx_draw: interleave failed");
        return NULL;
    }
    int w = 0, h = 0;
    u8 *image = render_8pass_blit_impl(interleaved, interleaved_size, rows, cl, &w, &h);
    free(interleaved);
    if (!image) {
        platform_log("grp_decode_planes_gfx_draw: blit failed");
        return NULL;
    }
    *out_w = w; *out_h = h;
    return image;
}
