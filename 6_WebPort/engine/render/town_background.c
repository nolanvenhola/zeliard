#include "town_background.h"

#include <string.h>

static u8 shift_bit8(u8 *value);

enum {
    MOLE_FLAG_1 = 0x0497,
    MOLE_FLAG_2 = 0x0498,
    MOLE_MODE = 0x0499,
    MOLE_MCGA_LUT = 0x02AE,
};

static int mole_unpack(u8 *chunk, size_t chunk_size, u16 source, u16 destination) {
    size_t si = source;
    size_t di = destination;
    for (;;) {
        if (si >= chunk_size || di >= chunk_size) return -1;
        u8 value = chunk[si++];
        if (value == 0) return 0;
        const u8 high = value & 0xF0;
        size_t count = 1;
        if (high == chunk[MOLE_FLAG_1]) {
            count = value & 0x0F;
            if (count == 0) count = 0x100;
            value = 0xAA;
        } else if (high == 0x40) {
            count = value & 0x0F;
            if (count == 0) count = 0x100;
            value = 0;
        } else if (chunk[MOLE_FLAG_2] != 0 && high == 0xD0) {
            count = value & 0x0F;
            if (count == 0) count = 0x100;
            value = 0xFF;
        }
        if (di + count > chunk_size) return -1;
        memset(chunk + di, value, count);
        di += count;
    }
}

static u8 mole_mcga_pixel(u8 *high, u8 *low, const u8 *lut) {
    u8 index = 0;
    for (u8 bit = 0; bit < 2; ++bit) {
        index = (u8)((index << 1) | shift_bit8(high));
        index = (u8)((index << 1) | shift_bit8(low));
    }
    return lut[index & 0x0F];
}

static int mole_blit(u8 *chunk, size_t chunk_size, u16 si, u16 bp,
                     u16 bx, u16 cx, u8 *vga) {
    const u8 rows = (u8)cx;
    const u8 pairs = (u8)(cx >> 8);
    size_t row_destination = (size_t)(u8)bx * 320u +
                             (size_t)(u8)(bx >> 8) * 4u;
    const u8 *lut = chunk + MOLE_MCGA_LUT;
    for (u8 row = 0; row < rows; ++row) {
        size_t di = row_destination;
        for (u8 pair = 0; pair < pairs; ++pair) {
            if ((size_t)si >= chunk_size) return -11;
            if ((size_t)bp + si >= chunk_size) return -12;
            if (di + 4 > 0x10000) return -13;
            u8 high = chunk[(u16)(bp + si)];
            u8 low = chunk[si++];
            for (u8 pixel = 0; pixel < 4; ++pixel)
                vga[di++] = mole_mcga_pixel(&high, &low, lut);
        }
        row_destination += 320;
    }
    return 0;
}

static void mole_or_mask_byte(u8 value, u8 *vga, size_t *destination) {
    for (u8 pixel = 0; pixel < 4; ++pixel) {
        u8 mask = (u8)(shift_bit8(&value) << 2);
        mask = (u8)((mask << 1) | shift_bit8(&value));
        mask <<= 2;
        vga[(*destination)++] |= mask;
    }
}

static int mole_or_mask_postpass(const u8 *chunk, size_t chunk_size,
                                 u8 *vga, size_t vga_size) {
    size_t source = 0x049A;
    static const u16 block_destinations[] = {0x3AC8, 0x3BF0};

    /*
     * Runtime target 038Ch is the MCGA handler after the SAR header is
     * stripped. The annotated source listing's file-offset interpretation
     * incorrectly describes it as a RETN stub.
     */
    for (u8 block = 0; block < 2; ++block) {
        size_t row_destination = block_destinations[block];
        for (u8 row = 0; row < 5; ++row) {
            size_t destination = row_destination;
            if (source + 2 > chunk_size || destination + 8 > vga_size) return -1;
            mole_or_mask_byte(chunk[source++], vga, &destination);
            mole_or_mask_byte(chunk[source++], vga, &destination);
            row_destination += 0x0140;
        }
    }
    return 0;
}

int zeliard_mole_render_mcga(u8 *chunk, size_t chunk_size,
                             u8 *vga, size_t vga_size) {
    if (!chunk || chunk_size < 0x3286 + 0x960 || !vga || vga_size < 0x10000)
        return -1;

    chunk[MOLE_MODE] = 4;
    if (mole_unpack(chunk, chunk_size, 0x04AE, 0x2926) ||
        mole_unpack(chunk, chunk_size, 0x073D, 0x3286) ||
        mole_blit(chunk, chunk_size, 0x2926, 0x0960, 0x0C00, 0x380D, vga))
        return -2;

    chunk[MOLE_FLAG_1] = 0x10;
    if (mole_unpack(chunk, chunk_size, 0x08CD, 0x2926)) return -31;
    if (mole_unpack(chunk, chunk_size, 0x10DB, 0x3286)) return -32;
    {
        const int result = mole_blit(chunk, chunk_size, 0x2926, 0x0960,
                                     0x0000, 0x0CC8, vga);
        if (result) return result;
    }
    if (mole_unpack(chunk, chunk_size, 0x1861, 0x2926)) return -34;
    if (mole_unpack(chunk, chunk_size, 0x2088, 0x3286)) return -35;
    if (mole_blit(chunk, chunk_size, 0x2926, 0x0960, 0x4400, 0x0CC8, vga))
        return -36;

    chunk[MOLE_FLAG_2] = 0xFF;
    chunk[MOLE_FLAG_1] = 0x50;
    if (mole_unpack(chunk, chunk_size, 0x2799, 0x2926)) return -4;
    memset(chunk + 0x3286, 0, 0x0960);
    if (mole_blit(chunk, chunk_size, 0x2926, 0x0960,
                  0x0C9E, 0x382A, vga))
        return -5;
    return mole_or_mask_postpass(chunk, chunk_size, vga, vga_size);
}

enum {
    YMPD_RUNTIME_BASE = 0x3300,
    YMPD_MOUNTAINS_0 = 0x38E7,
    YMPD_MOUNTAINS_1 = 0x4759,
    YMPD_GROUND_0 = 0x559E,
    YMPD_GROUND_1 = 0x56F1,
    YMPD_SCRATCH_MOUNTAINS_1 = 0x1340,
};

static int runtime_index(u16 address, size_t chunk_size, size_t *index) {
    if (address < YMPD_RUNTIME_BASE) return -1;
    *index = (size_t)(address - YMPD_RUNTIME_BASE);
    return *index < chunk_size ? 0 : -1;
}

static int decode_mountains(const u8 *chunk, size_t chunk_size, u16 source,
                            u8 *scratch, size_t destination) {
    size_t si;
    if (runtime_index(source, chunk_size, &si) || destination + 88u * 56u > 0x4D00)
        return -1;

    size_t di = destination;
    u8 column = 0;
    u8 row = 0;
    while (column != 88) {
        if (si >= chunk_size) return -1;
        u8 value = chunk[si++];
        u8 count = 1;
        if (value == 6) {
            if (si + 1 >= chunk_size) return -1;
            value = chunk[si++];
            count = chunk[si++];
        }
        do {
            scratch[di++] = value;
            if (++row == 56) {
                row = 0;
                ++column;
                if (column == 88) return 0;
            }
        } while (--count != 0);
    }
    return 0;
}

static int decode_ground_rows(const u8 *chunk, size_t chunk_size, u16 source,
                              u8 *scratch, size_t destination) {
    size_t si;
    if (runtime_index(source, chunk_size, &si) || destination + 16u * 28u > 0x4D00)
        return -1;

    size_t di = destination;
    for (u8 row = 0; row < 16; ++row) {
        u8 emitted = 0;
        while (emitted != 28) {
            if (si >= chunk_size) return -1;
            u8 value = chunk[si++];
            u8 count = 1;
            if ((value & 0xF0) == 0x60) {
                count = value & 0x0F;
                value = 0;
            }
            if (count == 0 || (u16)emitted + count > 28) return -1;
            memset(scratch + di, value, count);
            di += count;
            emitted = (u8)(emitted + count);
        }
    }
    return 0;
}

static u8 shift_bit8(u8 *value) {
    const u8 carry = (u8)(*value >> 7);
    *value <<= 1;
    return carry;
}

static u8 shift_bit16(u16 *value) {
    const u8 carry = (u8)(*value >> 15);
    *value <<= 1;
    return carry;
}

static u8 expand_mountain_pixel(u8 *high, u8 *low) {
    u8 al = shift_bit8(high);
    al <<= 1;
    al = (u8)((al << 1) | shift_bit8(low));
    al = (u8)((al << 1) | shift_bit8(high));
    al <<= 1;
    return (u8)((al << 1) | shift_bit8(low));
}

static void render_mountains(const u8 *scratch, u8 *vga) {
    size_t si = 0;
    size_t row_destination = 0x11B0;
    for (u8 row = 0; row < 88; ++row) {
        size_t di = row_destination;
        for (u8 pair = 0; pair < 56; ++pair) {
            u8 high = scratch[YMPD_SCRATCH_MOUNTAINS_1 + si];
            u8 low = scratch[si++];
            for (u8 pixel = 0; pixel < 4; ++pixel)
                vga[di++] = expand_mountain_pixel(&high, &low);
        }
        row_destination += 320;
    }
}

static u16 read_u16_be_pair(const u8 *data) {
    return (u16)((u16)data[0] << 8 | data[1]);
}

static u8 expand_ground_pixel(u16 *first, u16 *second, int final_shift) {
    u8 al = shift_bit16(first);
    al = (u8)((al << 1) | shift_bit16(second));
    al <<= 1;
    al = (u8)((al << 1) | shift_bit16(first));
    al = (u8)((al << 1) | shift_bit16(second));
    return final_shift ? (u8)(al << 1) : al;
}

static void render_ground_band(const u8 *scratch, size_t *source,
                               u8 *vga, size_t destination, int reverse) {
    for (u8 row = 0; row < 8; ++row) {
        const size_t row_source = *source;
        size_t si = row_source;
        size_t di = destination;
        for (u8 tile = 0; tile < 14; ++tile) {
            u16 first = read_u16_be_pair(scratch + si);
            u16 second = read_u16_be_pair(scratch + si + 0x1C);
            if (reverse) {
                const u16 swap = first;
                first = second;
                second = swap;
            }
            for (u8 pixel = 0; pixel < 8; ++pixel)
                vga[di++] = expand_ground_pixel(&first, &second, !reverse);
            si += 2;
        }
        *source = row_source + 0x38;
        destination += 320;
    }
}

static void render_ground(const u8 *scratch, u8 *vga) {
    size_t source = 0;
    render_ground_band(scratch, &source, vga, 0xB1B0, 0);
    render_ground_band(scratch, &source, vga, 0xBBB0, 1);

    size_t src = 0xB1B0;
    size_t dst = 0xB220;
    for (u8 row = 0; row < 16; ++row) {
        memcpy(vga + dst, vga + src, 112);
        src += 320;
        dst += 320;
    }
}

int zeliard_ympd_render_mcga(const u8 *chunk, size_t chunk_size,
                             u8 *scratch, size_t scratch_size,
                             u8 *vga, size_t vga_size) {
    if (!chunk || !scratch || !vga || scratch_size < 0x4D00 || vga_size < 0x10000)
        return -1;

    memset(scratch, 0, 0x4D00);
    if (decode_mountains(chunk, chunk_size, YMPD_MOUNTAINS_0, scratch, 0) ||
        decode_mountains(chunk, chunk_size, YMPD_MOUNTAINS_1, scratch,
                         YMPD_SCRATCH_MOUNTAINS_1))
        return -1;
    render_mountains(scratch, vga);

    if (decode_ground_rows(chunk, chunk_size, YMPD_GROUND_0, scratch, 0) ||
        decode_ground_rows(chunk, chunk_size, YMPD_GROUND_1, scratch, 0x1C0))
        return -1;
    render_ground(scratch, vga);
    return 0;
}
