#ifndef ZELIARD_TIMER_H
#define ZELIARD_TIMER_H

#include "types.h"

enum {
    ZEL_PIT_HZ = 1193182,
    ZEL_GAME_TIMER_DIVISOR = 0x13B1,
};

u32 zel_timer_ticks_to_ms(u32 ticks);
u32 zel_timer_ms_to_ticks(u32 ms);
u32 zel_timer_advance_ms(u32 *subtick_accum, u32 dt_ms);

#endif
