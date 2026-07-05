#include "timer.h"
#include <stdint.h>

u32 zel_timer_ticks_to_ms(u32 ticks) {
    const uint64_t numerator =
        (uint64_t)ticks * (uint64_t)ZEL_GAME_TIMER_DIVISOR * 1000u;
    return (u32)((numerator + (ZEL_PIT_HZ / 2u)) / ZEL_PIT_HZ);
}

u32 zel_timer_ms_to_ticks(u32 ms) {
    const uint64_t numerator = (uint64_t)ms * (uint64_t)ZEL_PIT_HZ;
    return (u32)((numerator + (ZEL_GAME_TIMER_DIVISOR * 500u)) /
                 ((uint64_t)ZEL_GAME_TIMER_DIVISOR * 1000u));
}

u32 zel_timer_advance_ms(u32 *subtick_accum, u32 dt_ms) {
    u32 accum = subtick_accum ? *subtick_accum : 0;
    uint64_t next = (uint64_t)accum + (uint64_t)dt_ms * (uint64_t)ZEL_PIT_HZ;
    const uint64_t tick_units = (uint64_t)ZEL_GAME_TIMER_DIVISOR * 1000u;
    const u32 ticks = (u32)(next / tick_units);
    accum = (u32)(next % tick_units);
    if (subtick_accum)
        *subtick_accum = accum;
    return ticks;
}
