#ifndef ZELIARD_CAVERN_TRANSITION_H
#define ZELIARD_CAVERN_TRANSITION_H

#include "../core/types.h"

enum {
    ZEL_CAVERN_TRANSITION_STEPS = 0x1A,
};

typedef struct {
    u8 active;
    u8 complete;
    u8 direction;
    u8 step;
    u8 pose;
    u8 packed_x;
    u8 wait_ticks;
    u8 wait_target;
    u16 map_width;
    u8 map_tiles[240 * 64];
    u8 pattern_tiles[26 * 64];
    u8 fman[8176];
    u8 background[0x10000];
} zeliard_cavern_transition_t;

/* 200FIGHT:enter_combat_screen -> check_c3. The caller has already run
 * 106TOWN:pf30_exec and written the destination record into game_seg. */
int zeliard_cavern_transition_begin(zeliard_cavern_transition_t *transition,
                                    u8 *game_seg, size_t game_size,
                                    u8 *vga, size_t vga_size);

/* Advance by raw stick.asm timer ticks. Input is intentionally absent:
 * check_c3 polls only stick service handlers while Duke crosses the room. */
int zeliard_cavern_transition_advance_pit(
    zeliard_cavern_transition_t *transition,
    u8 *game_seg, size_t game_size,
    u8 *vga, size_t vga_size, u32 pit_ticks);

#endif
