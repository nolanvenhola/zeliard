#include "adlib_cue.h"

enum {
    SNDADLIB_LINK_ORIGIN = 0x1100,
    SNDADLIB_CUE_TABLE = 0x1743,
    SNDADLIB_CUE_RECORD_SIZE = 7
};

static u16 read_le16(const u8 *p) {
    return (u16)(p[0] | ((u16)p[1] << 8));
}

int zel_adlib_cue_descriptor(const u8 *driver, size_t driver_size, u8 cue,
                             zel_adlib_cue_descriptor_t *out) {
    if (!driver || !out || cue == 0)
        return 0;

    size_t offset = (SNDADLIB_CUE_TABLE - SNDADLIB_LINK_ORIGIN) +
                    (size_t)(cue - 1u) * SNDADLIB_CUE_RECORD_SIZE;
    if (offset + SNDADLIB_CUE_RECORD_SIZE > driver_size)
        return 0;

    out->priority = driver[offset];
    out->voice_a = read_le16(driver + offset + 1);
    out->voice_b = read_le16(driver + offset + 3);
    out->tail = read_le16(driver + offset + 5);
    return 1;
}
