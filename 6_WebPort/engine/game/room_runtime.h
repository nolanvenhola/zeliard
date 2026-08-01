#ifndef ZELIARD_ROOM_RUNTIME_H
#define ZELIARD_ROOM_RUNTIME_H

#include "../core/types.h"

typedef enum {
    ZEL_ROOM_NONE = 0,
    ZEL_ROOM_KING = 1,
    ZEL_ROOM_SAGE = 2,
    ZEL_ROOM_VIEWING = 3,
} zeliard_room_kind_t;

typedef struct {
    zeliard_room_kind_t kind;
    u8 active;
    u8 alternate_transition_requested;
    u8 saved_code[0x1C00];
    u8 saved_vga[0x10000];
} zeliard_room_runtime_t;

int zeliard_room_enter(zeliard_room_runtime_t *room,
                       zeliard_room_kind_t kind,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size);
int zeliard_room_leave(zeliard_room_runtime_t *room,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size);

#endif
