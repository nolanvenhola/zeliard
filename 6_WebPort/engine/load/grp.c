/* GRP decoder — see grp.h for the pipeline overview.
 *
 * Validation against the assembly source of truth
 * (per feedback_port_validates_against_asm.md):
 *
 *  - decode_6de1():  line-for-line port of `decode_rle_to_es_di`
 *      at 3_Assembly/tasm/working/zelres1/code/100OPDMO.asm:1561-1595.
 *      Identical dispatch: bit 6 = 2-byte mode, bit 7/15 = fill, 0xFFFF
 *      = end-of-stream.  Direct asm-to-C transliteration of the body.
 *
 *  - interleave_4plane():  ports the per-driver 4-plane→nibble-pair
 *      pipeline that turns the 2-plane 1bpp RLE output into the
 *      paletted byte stream consumed by the mode-13h blit.  The
 *      canonical asm implementations live in the gfx-mode drivers
 *      (gmmcga.asm, gmcga.asm, gmega.asm, gmhgc.asm, gmtga.asm) inside
 *      the per-driver tilemap renderers; each driver has heavily-
 *      unrolled variants that emit the same byte stream.  This C
 *      implementation matches the Python reference at
 *      2_SAR/Tools/grp_view2.py:interleave_4plane and is gated by
 *      output-parity against 3_Assembly/dumps/zeliard_title_image.BIN.
 *      TODO: cite the specific gfx-driver proc once line-traced.
 *
 *  - render_8pass_blit():  ports the 8-pass mask-table blit that
 *      compresses the 896-wide nibble-packed render buffer into the
 *      260-wide on-screen image.  Mask tables match CLAUDE.md
 *      "Exact Blit Parameters" (mask1=[80,20,08,02,40,10,04,01],
 *      mask2=[01,04,10,40,02,08,20,80]).  Canonical asm: same
 *      per-driver gfx-mode files; same output-parity gate.
 */

#include "grp.h"
#include "../platform/platform.h"
#include <stdlib.h>
#include <string.h>

/* ---- header strip ------------------------------------------------------- */

static const u8* detect_and_strip_header(const u8 *data, size_t size, size_t *out_size) {
    if (size < 5) { *out_size = 0; return NULL; }
    u32 hdr = (u32)data[0] | ((u32)data[1] << 8)
            | ((u32)data[2] << 16) | ((u32)data[3] << 24);
    if (hdr + 4 == size) {
        /* SAR-style header present: skip 4-byte size + 1-byte fill_buffer opcode.
         * (For ttl3.grp the opcode is 0x00 = "raw" so the rest of the data is
         *  the 6DE1 RLE stream verbatim.) */
        *out_size = size - 5;
        return data + 5;
    }
    /* No header — start at byte 0. */
    *out_size = size;
    return data;
}

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

/* ---- 4-plane interleaver (0x30FC) ---------------------------------------- */
/* Reads 2 source words per iteration (plane A at SI, plane B at SI+BP).
 * Derives 4 logical pixel-bit values per word pair, packs as nibbles
 * (2 pixels per output byte).  See grp_view2.py interleave_4plane for the
 * shift-and-rotate magic this is faithfully porting. */
static u8* interleave_4plane(const u8 *src, size_t src_size,
                             int rows, int cl, size_t *out_size) {
    int BP = rows * cl;
    if ((size_t)(BP * 2) > src_size) {
        platform_log("interleave_4plane: src too small (%zu < %d)", src_size, BP * 2);
        *out_size = 0;
        return NULL;
    }
    /* Output size: one nibble-pair byte per 2 source pixels.
     * Total source pixels = BP * 8 (bits).  Output bytes = pixels / 2. */
    size_t cap = (size_t)BP * 4;  /* BP*8 pixels / 2 = BP*4 bytes */
    u8 *out = (u8*)malloc(cap);
    if (!out) { *out_size = 0; return NULL; }
    size_t out_n = 0;

    int si = 0;
    int iters = BP / 2;
    for (int it = 0; it < iters; it++) {
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
            /* Byte-swap acc (big-endian -> little-endian as the original
             * x86 store would have done). */
            u16 swapped = (u16)(((acc & 0xFF) << 8) | ((acc >> 8) & 0xFF));
            out[out_n++] = (u8)(swapped & 0xFF);
            out[out_n++] = (u8)(swapped >> 8);
        }
    }
    *out_size = out_n;
    return out;
}

/* ---- 8-pass mask blit (renders to a `call_size x blit_calls` image) ---- */
/* Mirrors grp_view2.py render_grp().  Builds a paletted byte image where
 * each byte is a nibble-pair (e.g. 0xAA = pure yellow, 0xCC = pure blue,
 * 0x8C = mixed). */
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

static u8* render_8pass_blit(const u8 *interleaved, size_t interleaved_size,
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
    size_t payload_size = 0;
    const u8 *payload = detect_and_strip_header(file_data, file_size, &payload_size);
    if (!payload || payload_size == 0) {
        platform_log("grp_decode: header strip failed");
        return NULL;
    }

    size_t decoded_size = 0;
    u8 *decoded = decode_6de1(payload, payload_size, &decoded_size);
    if (!decoded) {
        platform_log("grp_decode: 6DE1 decode failed");
        return NULL;
    }
    platform_log("grp_decode: payload=%zu decoded=%zu", payload_size, decoded_size);

    size_t interleaved_size = 0;
    u8 *interleaved = interleave_4plane(decoded, decoded_size, rows, cl, &interleaved_size);
    free(decoded);
    if (!interleaved) {
        platform_log("grp_decode: interleave failed");
        return NULL;
    }
    platform_log("grp_decode: interleaved=%zu (rows=%d cl=%d)", interleaved_size, rows, cl);

    int w = 0, h = 0;
    u8 *image = render_8pass_blit(interleaved, interleaved_size, rows, cl, &w, &h);
    free(interleaved);
    if (!image) {
        platform_log("grp_decode: blit failed");
        return NULL;
    }
    platform_log("grp_decode: image %dx%d ready", w, h);

    *out_w = w; *out_h = h;
    return image;
}
