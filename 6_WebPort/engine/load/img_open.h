#ifndef ZELIARD_IMG_OPEN_H
#define ZELIARD_IMG_OPEN_H

#include "../core/types.h"

/* Opening-scene image decoder — ports decompress_image at
 * 3_Assembly/masm/working/zelres1/code/100OPDMO.asm:1468-1555.
 *
 * Two-stage decode of fill_buffer output:
 *   1. decode_rle_stream (100OPDMO.asm:1472-1509):
 *        Reads ctrl_count (2 bytes LE), ctrl_count control bytes,
 *        then literal bytes.  Each bit in each control byte (MSB first):
 *          0 → emit zero byte   1 → emit next literal byte
 *        Output = ctrl_count × 8 bytes = rows*cl*2 (2-plane 1bpp layout).
 *
 *   2. decomp_palette_transform (100OPDMO.asm:1511-1553):
 *        XOR-differential decode of 2-bit pairs MSB-first.
 *        Running state persists across the entire image.
 *        Output = same size as step-1 output = rows*cl*2 bytes.
 *
 * The result is the same 2-plane 1bpp layout that grp_decode_planes expects.
 * Pass rows and cl for validation (expected size = rows*cl*2).
 * Returns malloc'd buffer; caller frees. *out_size=0 on failure.
 */
u8* img_open_decode(const u8 *fb_out, size_t fb_size,
                    int rows, int cl, size_t *out_size);

u8* img_open_decode_overlap(const u8 *fb_out, size_t fb_size,
                            u16 src_offset, u16 dst_offset,
                            int rows, int cl, size_t *out_size);

#endif
