#ifndef ZELIARD_GRP_H
#define ZELIARD_GRP_H

#include "../core/types.h"

/* GRP image decoder.  Ports the 0x6DE1 RLE decoder + 4-plane interleaver
 * + 8-pass mask blit pipeline used by the original opening/title scenes.
 *
 * Source spec:
 *   - CLAUDE.md sections "fill_buffer Decoder", "0x6DE1 RLE Decoder",
 *     "4-Plane Interleaver", "VGA Output", and "Exact Blit Parameters"
 *   - 2_SAR/Tools/grp_view2.py (Python reference: decode_6de1,
 *     interleave_4plane, render_grp)
 *
 * Pipeline for a typical title/opening GRP (e.g. ttl3.grp):
 *   raw_file (7803 B)
 *      └─ strip 4-byte size header + 1-byte fill_buffer opcode (=0 raw)
 *      └─ decode_6de1 RLE                       → ~14560 B (2 planes 1bpp)
 *      └─ interleave_4plane (rows=65, cl=112)   → ~29120 B nibble-packed
 *      └─ 8-pass mask blit (call_size=260, blit_calls=112)
 *      └─ paste into framebuffer at (28, 15)    → 260x112 image
 */

/* Decode a complete GRP into a freshly-malloc'd 260x112-style image.
 * Returns malloc'd buffer of `*out_w * *out_h` paletted bytes, or NULL.
 * Caller frees with free().  `rows` and `cl` are the source plane
 * geometry (rows=CH=number of source rows, cl=CL=bytes per row at 1bpp).
 */
u8* grp_decode(const u8 *file_data, size_t file_size,
               int rows, int cl,
               int *out_w, int *out_h);

#endif
