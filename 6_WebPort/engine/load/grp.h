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

/* Decode a complete GRP file into a paletted image.
 * Strips the SAR header + fill_buffer opcode, runs 6DE1 RLE,
 * then interleave_4plane + 8-pass mask blit.
 * Returns malloc'd buffer; caller frees.  NULL on failure. */
u8* grp_decode(const u8 *file_data, size_t file_size,
               int rows, int cl,
               int *out_w, int *out_h);

/* Decode through fill_buffer + 6DE1 only. This mirrors 100OPDMO
 * decode_rle_to_es_di and returns the two-plane bytes that later driver
 * routines consume. */
u8* grp_decode_6de1_planes(const u8 *file_data, size_t file_size,
                           size_t *out_size);

/* Same as grp_decode, but stops the MCGA render-pass blit after pass_count
 * passes. pass_count 0 returns a black image; 8 returns the completed image. */
u8* grp_decode_partial_passes(const u8 *file_data, size_t file_size,
                              int rows, int cl, int pass_count,
                              int *out_w, int *out_h);

/* Same pipeline but starting from already-decompressed 2-plane 1bpp data.
 * Uses the render_plane_abc_loop interleave (planes = {A|B, B&~AB, A&~AB, 0}).
 * Returns malloc'd buffer; caller frees.  NULL on failure. */
u8* grp_decode_planes(const u8 *planes, size_t planes_size,
                      int rows, int cl, int *out_w, int *out_h);

u8* grp_decode_planes_partial_passes(const u8 *planes, size_t planes_size,
                                     int rows, int cl, int pass_count,
                                     int *out_w, int *out_h);

/* Same pipeline using the render_plane_a_loop interleave
 * (planes = {B, 0, 0, A}, produces nibble values 0/1/8/9 instead of 0/A/C/8).
 * Used by gfx_draw_fn scenes (100OPDMO.asm:318 — nec.grp, dmaou.grp, etc.)
 * via decompress_image → grp_decode_planes_gfx_draw.
 * Returns malloc'd buffer; caller frees.  NULL on failure. */
u8* grp_decode_planes_gfx_draw(const u8 *planes, size_t planes_size,
                                int rows, int cl, int *out_w, int *out_h);

u8* grp_decode_planes_gfx_draw_partial_passes(const u8 *planes, size_t planes_size,
                                              int rows, int cl, int pass_count,
                                              int *out_w, int *out_h);

#endif
