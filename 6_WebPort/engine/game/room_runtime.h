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
    u8 entry_frame_prepared;
    u8 exit_requested;
    u8 script_state;
    u8 script_delay;
    u8 script_command;
    u8 script_sequence_index;
    u8 script_gold_steps;
    u8 script_scroll_steps;
    u8 script_prompt_after_scroll;
    u8 script_word_check_pending;
    u8 pending_sound_cue;
    u16 script_ip;
    u16 script_wait_ticks;
    u32 king_entry_gold;
    u8 saved_code[0x1C00];
    u8 saved_vga[0x10000];
    u8 room_tiles[0x3000];
} zeliard_room_runtime_t;

int zeliard_room_prepare_enter(zeliard_room_runtime_t *room,
                               const u8 *vga, size_t vga_size);

int zeliard_room_enter(zeliard_room_runtime_t *room,
                       zeliard_room_kind_t kind,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size);
int zeliard_room_leave(zeliard_room_runtime_t *room,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size);

/* Advance a loaded room by one raw stick.asm PIT interrupt (236.7 Hz). */
int zeliard_room_advance_pit(zeliard_room_runtime_t *room,
                             u8 *game_seg, size_t game_size,
                             u8 *vga, size_t vga_size);

/* 210KINGP:A3E8 branch selector, exposed for oracle parity tests. */
u16 zeliard_king_select_script(const u8 *game_seg, size_t game_size);

#endif
