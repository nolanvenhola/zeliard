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
#include <string.h>

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

static u8 rol8_1(u8 value, u8 *carry) {
    *carry = (u8)((value & 0x80u) != 0);
    return (u8)((value << 1) | *carry);
}

static u8* decode_rle_stream_overlap(const u8 *src, size_t src_size,
                                     u16 src_offset, u16 dst_offset,
                                     size_t expected, size_t *out_size) {
    u8 *mem = (u8 *)calloc(0x10000, 1);
    if (!mem) {
        *out_size = 0;
        return NULL;
    }
    for (size_t i = 0; i < src_size; i++)
        mem[(src_offset + (u16)i) & 0xFFFFu] = src[i];

    u16 si = src_offset;
    u16 di = dst_offset;
    u16 ctrl_count = (u16)mem[si] | ((u16)mem[(si + 1u) & 0xFFFFu] << 8);
    si = (u16)(si + 2u);
    u16 bp = si;
    si = (u16)(si + ctrl_count);
    size_t out_n = (size_t)ctrl_count * 8u;

    if (expected > 0 && out_n != expected) {
        platform_log("img_open: ctrl_count×8=%zu != expected=%zu", out_n, expected);
    }

    for (u16 c = 0; c < ctrl_count; c++) {
        for (int bit = 0; bit < 8; bit++) {
            u8 carry = 0;
            mem[bp] = rol8_1(mem[bp], &carry);
            if (carry) {
                mem[di] = mem[si];
                si = (u16)(si + 1u);
            } else {
                mem[di] = 0;
            }
            di = (u16)(di + 1u);
        }
        bp = (u16)(bp + 1u);
    }

    u8 *out = (u8 *)malloc(out_n ? out_n : 1u);
    if (!out) {
        free(mem);
        *out_size = 0;
        return NULL;
    }
    for (size_t i = 0; i < out_n; i++)
        out[i] = mem[(dst_offset + (u16)i) & 0xFFFFu];
    free(mem);
    *out_size = out_n;
    return out;
}

/* ---- Stage 2: decomp_palette_transform (100OPDMO.asm:1622-1664) --------- */
static void rcl_byte_1(u8 *value, u8 *carry) {
    const u8 old = *value;
    *value = (u8)((old << 1) | (*carry & 1u));
    *carry = (u8)((old & 0x80u) != 0);
}

static u8 read_rcl_pair(u8 *value) {
    u8 carry = 0;  /* xor al,al clears CF before each two-rcl pair */
    u8 al = 0;

    rcl_byte_1(value, &carry);
    {
        const unsigned sum = (unsigned)al + (unsigned)al + (unsigned)carry;
        al = (u8)sum;
        carry = (u8)(sum > 0xFFu);
    }
    rcl_byte_1(value, &carry);
    {
        const unsigned sum = (unsigned)al + (unsigned)al + (unsigned)carry;
        al = (u8)sum;
        carry = (u8)(sum > 0xFFu);
    }
    return (u8)(al & 3u);
}

/* XOR-differential decode of 2-bit pairs.  The MASM code extracts each pair by
 * rotating the byte in memory through carry, so later pairs see the mutated
 * byte.  This deliberately mirrors the register side effects instead of doing
 * a direct bit-slice. */
static void palette_transform(u8 *data, size_t size) {
    u8 dh = 0;  /* running 2-bit state */
    for (size_t i = 0; i < size; i++) {
        u8 value = data[i];

        dh ^= read_rcl_pair(&value);
        u8 ah = dh;

        dh ^= read_rcl_pair(&value);
        ah = (u8)((ah << 2) | dh);

        dh ^= read_rcl_pair(&value);
        ah = (u8)((ah << 2) | dh);

        dh ^= read_rcl_pair(&value);
        ah = (u8)((ah << 2) | dh);

        data[i] = ah;
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

u8* img_open_decode_overlap(const u8 *fb_out, size_t fb_size,
                            u16 src_offset, u16 dst_offset,
                            int rows, int cl, size_t *out_size) {
    size_t expected = (size_t)rows * (size_t)cl * 2u;

    size_t n = 0;
    u8 *planes = decode_rle_stream_overlap(fb_out, fb_size, src_offset,
                                           dst_offset, expected, &n);
    if (!planes) {
        platform_log("img_open_decode_overlap: decode_rle_stream failed");
        *out_size = 0;
        return NULL;
    }

    palette_transform(planes, n);
    *out_size = n;
    return planes;
}
