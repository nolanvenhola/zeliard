#ifndef ZELIARD_FILL_BUFFER_H
#define ZELIARD_FILL_BUFFER_H

#include "../core/types.h"

/* SAR chunk fill_buffer decompressor.
 *
 * Ports the fill_buffer dispatcher at 041F:0DAD (game_seg loader).
 * Canonical reference: 2_SAR/Tools/decompress_sar.py _fill_buffer().
 *
 * Eight methods dispatched on buf[0] & 7:
 *   0  copy verbatim        1  lo-nibble table RLE
 *   2  hi-nibble marker RLE 3  hi-nibble table RLE
 *   4  lo-nibble marker RLE 5  same-byte-pair RLE
 *   6  2-byte table RLE     7  escape-byte RLE
 *
 * SAR chunk format:
 *   [0-3] LE uint32 chunk_data_size (= file_size - 4)
 *   [4]   flag: 0=simple, non-0=multi-section VGA/NEC split
 *   flag=0: fill_buffer input = file_data[5 .. 5+chunk_data_size-2]
 *   flag≠0: skip_count at [5-6], read_count at [7-8]; data at [9+skip_count]
 */
u8* fill_buffer_decompress(const u8 *file_data, size_t file_size, size_t *out_size);

/* Release SAR mode 1's cavern selector table.  Town exits and the fight VM
 * must resolve the same MDT before applying map-width-dependent placement. */
const char *zeliard_cavern_map_asset(u8 selector);

#endif
