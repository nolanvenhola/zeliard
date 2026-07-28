#ifndef ZELIARD_ADLIB_CUE_H
#define ZELIARD_ADLIB_CUE_H

#include "../core/types.h"
#include <stddef.h>

typedef struct {
    u8 priority;
    u16 voice_a;
    u16 voice_b;
    u16 tail;
} zel_adlib_cue_descriptor_t;

int zel_adlib_cue_descriptor(const u8 *driver, size_t driver_size, u8 cue,
                             zel_adlib_cue_descriptor_t *out);

#endif
