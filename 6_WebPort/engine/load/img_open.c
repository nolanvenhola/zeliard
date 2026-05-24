/* img_open — opening-scene image decoder.
 *
 * Ports decompress_image at 100OPDMO.asm:1468-1555:
 *   Stage 1  decode_rle_stream   (lines 1472-1509) — flag-bit RLE
 *   Stage 2  decomp_palette_transform (lines 1511-1553) — XOR-delta 2-bit pairs
 *
 * Output is the 2-plane 1bpp data that grp_decode_planes consumes.
 */

#include "img_open.h"
#include "../platform/platform.h"
#include <stdlib.h>

/* ---- Stage 1: decode_rle_stream (100OPDMO.asm:1472-1509) ---------------- */
/* Input layout (fill_buffer output):
 *   [0-1]  ctrl_count LE uint16
 *   [2 .. 2+ctrl_count-1]  control bytes
 *   [2+ctrl_count ..]      literal bytes
 * For each bit of each control byte (MSB first):
 *   0 → emit 0x00        1 → emit next literal byte
 * Total output = ctrl_count × 8 bytes = expected_size */
static u8* decode_rle_stream(const u8 *src, size_t src_size,
                              size_t expected, size_t *out_size) {
    if (src_size < 2) { *out_size = 0; return NULL; }
    u16 ctrl_count = (u16)src[0] | ((u16)src[1] << 8);
    size_t out_n = (size_t)ctrl_count * 8;

    if (expected > 0 && out_n != expected) {
        platform_log("img_open: ctrl_count×8=%zu != expected=%zu", out_n, expected);
        /* Continue anyway — use ctrl_count's implied size */
    }

    u8 *out = (u8*)calloc(out_n ? out_n : 1, 1);
    if (!out) { *out_size = 0; return NULL; }

    size_t ci = 2;                  /* control bytes start here */
    size_t li = 2 + ctrl_count;    /* literal bytes start here */
    size_t oi = 0;

    for (size_t c = 0; c < ctrl_count && ci < src_size && oi < out_n; c++) {
        u8 ctrl = src[ci++];
        for (int bit = 7; bit >= 0 && oi < out_n; bit--) {
            if (ctrl & (1 << bit)) {
                out[oi++] = (li < src_size) ? src[li++] : 0;
            } else {
                out[oi++] = 0;
            }
        }
    }

    *out_size = out_n;
    return out;
}

/* ---- Stage 2: decomp_palette_transform (100OPDMO.asm:1511-1553) --------- */
/* XOR-differential decode of 2-bit pairs, MSB first.
 * Each input byte has 4 two-bit pairs; each pair is XOR'd with running
 * state dh (starts at 0 for each image; persists byte-to-byte within).
 * Result is stored in the same 2-bit positions of the output byte.
 * Applied in-place. */
static void palette_transform(u8 *data, size_t size) {
    u8 dh = 0;  /* running 2-bit state */
    for (size_t i = 0; i < size; i++) {
        u8 in  = data[i];
        u8 out = 0;
        /* Process pairs in MSB-first order: shifts 6, 4, 2, 0 */
        for (int s = 6; s >= 0; s -= 2) {
            u8 pair = (in >> s) & 3;
            pair ^= dh;
            dh = pair;
            out |= (u8)(pair << s);
        }
        data[i] = out;
    }
}

/* ---- public API ---------------------------------------------------------- */

u8* img_open_decode(const u8 *fb_out, size_t fb_size,
                    int rows, int cl, size_t *out_size) {
    size_t expected = (size_t)rows * (size_t)cl * 2;

    size_t n = 0;
    u8 *planes = decode_rle_stream(fb_out, fb_size, expected, &n);
    if (!planes) {
        platform_log("img_open_decode: decode_rle_stream failed");
        *out_size = 0;
        return NULL;
    }

    palette_transform(planes, n);
    *out_size = n;
    return planes;
}
