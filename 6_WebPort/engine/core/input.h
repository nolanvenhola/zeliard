#ifndef ZELIARD_INPUT_H
#define ZELIARD_INPUT_H

#include "types.h"

enum {
    ZEL_INPUT_KEY_ENTER = 13,
    ZEL_INPUT_KEY_SPACE = 32,
    ZEL_INPUT_KEY_ALT = 18,
    ZEL_INPUT_KEY_LEFT = 37,
    ZEL_INPUT_KEY_UP = 38,
    ZEL_INPUT_KEY_RIGHT = 39,
    ZEL_INPUT_KEY_DOWN = 40,
    ZEL_INPUT_KEY_ESCAPE = 27,
    ZEL_INPUT_KEY_F1 = 112,
    ZEL_INPUT_KEY_F2 = 113,
};

typedef enum {
    ZEL_INPUT_ACTION_NONE = 0,
    ZEL_INPUT_ACTION_SPACE = 1 << 0,
    ZEL_INPUT_ACTION_ENTER = 1 << 1,
    ZEL_INPUT_ACTION_ESCAPE = 1 << 2,
    ZEL_INPUT_ACTION_TOGGLE_MUSIC = 1 << 3,
    ZEL_INPUT_ACTION_TOGGLE_SOUND = 1 << 4,
} zel_input_action_t;

typedef struct {
    u16 held_keys;
} zel_input_state_t;

void zel_input_init(zel_input_state_t *state, u8 *game_seg);
u32 zel_input_key_down(zel_input_state_t *state, u8 *game_seg, int keycode);
void zel_input_key_up(zel_input_state_t *state, u8 *game_seg, int keycode);
u32 zel_input_advance_pit(zel_input_state_t *state, u8 *game_seg, u32 ticks);
void zel_input_release_all(zel_input_state_t *state, u8 *game_seg,
                           int clear_actions);

#endif
