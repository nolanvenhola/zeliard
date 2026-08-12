#include "input.h"
#include <string.h>

/* Runtime offsets owned by stick.asm. */
enum {
    STICK_SUBSAMPLE_CTR = 0x02BC,
    STICK_CHAIN_INT_CTR = 0x02BD,
    STICK_PAUSE_KEY_STATE = 0x02BE,
    STICK_BTN1_STATE = 0x02BF,
    STICK_MUSIC_KEY_STATE = 0x02C2,
    STICK_SFX_KEY_STATE = 0x02C3,
    STICK_INPUT_DIR_LO = 0x05C1,
    STICK_INPUT_DIR_HI = 0x05C2,
    STICK_INPUT_BTN_LO = 0x05C3,
    STICK_INPUT_BTN_HI = 0x05C4,
    STICK_EXT_KEY_FLAG = 0x05C5,
    GVAR_SKIP_FLAG = 0xFF16,
    GVAR_TIMER_FLAG = 0xFF17,
    GVAR_TIMER_COUNTER = 0xFF18,
    GVAR_SPACEBAR_STATE = 0xFF1D,
    GVAR_STATE_B = 0xFF1E,
    GVAR_SOUND_FLAG = 0xFF27,
    GVAR_ENTER_KEY = 0xFF29,
    GVAR_VOLUME_B = 0xFF75,
};

typedef struct {
    int keycode;
    u8 scancode;
    u8 direction_bit;
    u8 skip_bit;
    u16 timer_bit;
    u16 held_bit;
    u8 extended;
} key_binding_t;

static const key_binding_t KEY_BINDINGS[] = {
    {ZEL_INPUT_KEY_RIGHT,  0x4D, 8, 0, 0,      1u << 0, 1},
    {ZEL_INPUT_KEY_LEFT,   0x4B, 4, 0, 0,      1u << 1, 1},
    {ZEL_INPUT_KEY_DOWN,   0x50, 2, 0, 0,      1u << 2, 1},
    {ZEL_INPUT_KEY_UP,     0x48, 1, 0, 0,      1u << 3, 1},
    {ZEL_INPUT_KEY_SPACE,  0x39, 0, 1, 0,      1u << 4, 0},
    {ZEL_INPUT_KEY_ALT,    0x38, 0, 2, 0,      1u << 9, 0},
    {ZEL_INPUT_KEY_ENTER,  0x1C, 0, 0, 0x0001, 1u << 5, 0},
    {ZEL_INPUT_KEY_ESCAPE, 0x01, 0, 0, 0x0008, 1u << 6, 0},
    {ZEL_INPUT_KEY_F1,     0x3B, 0, 0, 0x1000, 1u << 7, 0},
    {ZEL_INPUT_KEY_F2,     0x3C, 0, 0, 0x2000, 1u << 8, 0},
    {ZEL_INPUT_KEY_F7,     0x41, 0, 0, 0x4000, 1u << 11, 0},
    {ZEL_INPUT_KEY_F9,     0x43, 0, 0, 0x8000, 1u << 10, 0},
};

static u16 read_u16(const u8 *mem, u16 off) {
    return (u16)(mem[off] | ((u16)mem[(u16)(off + 1)] << 8));
}

static void write_u16(u8 *mem, u16 off, u16 value) {
    mem[off] = (u8)value;
    mem[(u16)(off + 1)] = (u8)(value >> 8);
}

static const key_binding_t *find_binding(int keycode) {
    for (u32 i = 0; i < sizeof(KEY_BINDINGS) / sizeof(KEY_BINDINGS[0]); ++i)
        if (KEY_BINDINGS[i].keycode == keycode)
            return &KEY_BINDINGS[i];
    return NULL;
}

static u32 binding_action(const key_binding_t *binding) {
    if (binding->keycode == ZEL_INPUT_KEY_ENTER)
        return ZEL_INPUT_ACTION_ENTER;
    if (binding->keycode == ZEL_INPUT_KEY_ESCAPE)
        return ZEL_INPUT_ACTION_ESCAPE;
    if (binding->keycode == ZEL_INPUT_KEY_F7)
        return ZEL_INPUT_ACTION_RESTORE_MENU;
    if (binding->keycode == ZEL_INPUT_KEY_F9)
        return ZEL_INPUT_ACTION_SPEED_MENU;
    return ZEL_INPUT_ACTION_NONE;
}

static void merge_direction(u8 *mem) {
    u8 value = (u8)(mem[STICK_INPUT_DIR_LO] | mem[STICK_INPUT_BTN_LO]);
    value |= (u8)(mem[STICK_INPUT_DIR_HI] & 0x0F);
    value |= (u8)(mem[STICK_INPUT_DIR_HI] >> 4);
    value |= (u8)(mem[STICK_INPUT_BTN_HI] & 0x0F);
    value |= (u8)(mem[STICK_INPUT_BTN_HI] >> 4);
    mem[GVAR_TIMER_FLAG] = value;
}

static void apply_binding(u8 *mem, const key_binding_t *binding, int down) {
    /* dispatch_extended_key writes the translated ASCII byte on ordinary
     * make codes before process_scancode updates masks. */
    if (down && !binding->extended)
        mem[GVAR_ENTER_KEY] = binding->scancode == 0x1C ? 0x0D : 0;
    if (binding->direction_bit) {
        if (down)
            mem[STICK_INPUT_DIR_LO] |= binding->direction_bit;
        else
            mem[STICK_INPUT_DIR_LO] &= (u8)~binding->direction_bit;
    }
    if (binding->skip_bit) {
        if (down)
            mem[GVAR_SKIP_FLAG] |= binding->skip_bit;
        else
            mem[GVAR_SKIP_FLAG] &= (u8)~binding->skip_bit;
    }
    if (binding->timer_bit) {
        u16 timer = read_u16(mem, GVAR_TIMER_COUNTER);
        if (down)
            timer |= binding->timer_bit;
        else
            timer &= (u16)~binding->timer_bit;
        write_u16(mem, GVAR_TIMER_COUNTER, timer);
    }
    merge_direction(mem);
}

void zel_input_init(zel_input_state_t *state, u8 *mem) {
    if (!state || !mem)
        return;
    memset(state, 0, sizeof(*state));
    mem[STICK_SUBSAMPLE_CTR] = 0x0A;
    mem[STICK_CHAIN_INT_CTR] = 0x0D;
    memset(mem + STICK_PAUSE_KEY_STATE, 0, 7);
    memset(mem + STICK_INPUT_DIR_LO, 0, 5);
    mem[GVAR_SKIP_FLAG] = 0;
    mem[GVAR_TIMER_FLAG] = 0;
    write_u16(mem, GVAR_TIMER_COUNTER, 0);
    mem[GVAR_SPACEBAR_STATE] = 0;
    mem[GVAR_STATE_B] = 0;
    mem[GVAR_ENTER_KEY] = 0;
}

u32 zel_input_key_down(zel_input_state_t *state, u8 *mem, int keycode) {
    const key_binding_t *binding = find_binding(keycode);
    if (!state || !mem || !binding || (state->held_keys & binding->held_bit))
        return ZEL_INPUT_ACTION_NONE;
    state->held_keys |= binding->held_bit;
    if (state->gamepad_keys & binding->held_bit)
        return ZEL_INPUT_ACTION_NONE;
    apply_binding(mem, binding, 1);
    return binding_action(binding);
}

void zel_input_key_up(zel_input_state_t *state, u8 *mem, int keycode) {
    const key_binding_t *binding = find_binding(keycode);
    if (!state || !mem || !binding || !(state->held_keys & binding->held_bit))
        return;
    state->held_keys &= (u16)~binding->held_bit;
    if (state->gamepad_keys & binding->held_bit)
        return;
    apply_binding(mem, binding, 0);
}

void zel_input_consume_key(zel_input_state_t *state, u8 *mem, int keycode) {
    const key_binding_t *binding = find_binding(keycode);
    if (!state || !mem || !binding)
        return;
    /* A blocking STICK/DOS modal consumes its terminating make code before
     * returning to 200FIGHT. Browser keydown delivery is asynchronous, so
     * synthesize the corresponding released state at that boundary; the
     * later physical keyup is then harmless. */
    state->held_keys &= (u16)~binding->held_bit;
    state->gamepad_keys &= (u16)~binding->held_bit;
    apply_binding(mem, binding, 0);
}

u32 zel_input_gamepad_update(zel_input_state_t *state, u8 *mem,
                             u8 directions, u8 buttons) {
    u16 desired = 0;
    u32 actions = ZEL_INPUT_ACTION_NONE;
    if (!state || !mem)
        return actions;
    directions &= 0x0F;
    if (directions & ZEL_GAMEPAD_RIGHT) desired |= 1u << 0;
    if (directions & ZEL_GAMEPAD_LEFT)  desired |= 1u << 1;
    if (directions & ZEL_GAMEPAD_DOWN)  desired |= 1u << 2;
    if (directions & ZEL_GAMEPAD_UP)    desired |= 1u << 3;
    if (buttons & ZEL_GAMEPAD_A)        desired |= 1u << 4;
    if (buttons & ZEL_GAMEPAD_B)        desired |= 1u << 9;
    if (buttons & ZEL_GAMEPAD_X)        desired |= 1u << 5;
    if (buttons & ZEL_GAMEPAD_START)    desired |= 1u << 6;
    if (buttons & ZEL_GAMEPAD_BACK)     desired |= 1u << 11;
    if (buttons & ZEL_GAMEPAD_Y)        desired |= 1u << 10;
    if (buttons & ZEL_GAMEPAD_LB)       desired |= 1u << 7;
    if (buttons & ZEL_GAMEPAD_RB)       desired |= 1u << 8;

    for (u32 i = 0; i < sizeof(KEY_BINDINGS) / sizeof(KEY_BINDINGS[0]); ++i) {
        const key_binding_t *binding = &KEY_BINDINGS[i];
        const int was_down = (state->gamepad_keys & binding->held_bit) != 0;
        const int now_down = (desired & binding->held_bit) != 0;
        if (was_down == now_down)
            continue;
        if (now_down) {
            state->gamepad_keys |= binding->held_bit;
            if (!(state->held_keys & binding->held_bit)) {
                apply_binding(mem, binding, 1);
                actions |= binding_action(binding);
            }
        } else {
            state->gamepad_keys &= (u16)~binding->held_bit;
            if (!(state->held_keys & binding->held_bit))
                apply_binding(mem, binding, 0);
        }
    }
    return actions;
}

static u32 sample_special_keys(u8 *mem) {
    u32 actions = ZEL_INPUT_ACTION_NONE;
    const u16 timer = read_u16(mem, GVAR_TIMER_COUNTER);

    if (mem[STICK_MUSIC_KEY_STATE]) {
        if (timer == 0x1000) {
            mem[GVAR_VOLUME_B] = 1;
            mem[STICK_MUSIC_KEY_STATE] = 0;
            actions |= ZEL_INPUT_ACTION_TOGGLE_MUSIC;
        }
    } else if (timer != 0x1000) {
        mem[STICK_MUSIC_KEY_STATE] = 0xFF;
    }

    if (mem[STICK_SFX_KEY_STATE]) {
        if (timer == 0x2000) {
            mem[STICK_SFX_KEY_STATE] = 0;
            mem[GVAR_SOUND_FLAG] = (u8)~mem[GVAR_SOUND_FLAG];
            mem[GVAR_VOLUME_B] = 1;
            actions |= ZEL_INPUT_ACTION_TOGGLE_SOUND;
        }
    } else if (timer != 0x2000) {
        mem[STICK_SFX_KEY_STATE] = 0xFF;
    }
    return actions;
}

static u32 sample_pause_keys(u8 *mem) {
    u32 actions = ZEL_INPUT_ACTION_NONE;
    if (mem[STICK_PAUSE_KEY_STATE]) {
        if (mem[GVAR_SKIP_FLAG] & 1) {
            mem[STICK_PAUSE_KEY_STATE] = 0;
            if (!mem[GVAR_SPACEBAR_STATE])
                actions |= ZEL_INPUT_ACTION_SPACE;
            mem[GVAR_SPACEBAR_STATE] = 0xFF;
        }
    } else if (!(mem[GVAR_SKIP_FLAG] & 1)) {
        mem[STICK_PAUSE_KEY_STATE] = 0xFF;
    }

    if (mem[STICK_BTN1_STATE]) {
        if (mem[GVAR_SKIP_FLAG] & 2) {
            mem[STICK_BTN1_STATE] = 0;
            mem[GVAR_STATE_B] = 0xFF;
        }
    } else if (!(mem[GVAR_SKIP_FLAG] & 2)) {
        mem[STICK_BTN1_STATE] = 0xFF;
    }
    return actions;
}

u32 zel_input_advance_pit(zel_input_state_t *state, u8 *mem, u32 ticks) {
    u32 actions = ZEL_INPUT_ACTION_NONE;
    (void)state;
    if (!mem)
        return actions;
    while (ticks--) {
        mem[STICK_SUBSAMPLE_CTR]--;
        if (mem[STICK_SUBSAMPLE_CTR] == 0) {
            mem[STICK_SUBSAMPLE_CTR] = 5;
            actions |= sample_special_keys(mem);
            actions |= sample_pause_keys(mem);
        }
    }
    return actions;
}

void zel_input_release_all(zel_input_state_t *state, u8 *mem,
                           int clear_actions) {
    if (!state || !mem)
        return;
    for (u32 i = 0; i < sizeof(KEY_BINDINGS) / sizeof(KEY_BINDINGS[0]); ++i)
        if ((state->held_keys | state->gamepad_keys) & KEY_BINDINGS[i].held_bit)
            apply_binding(mem, &KEY_BINDINGS[i], 0);
    state->held_keys = 0;
    state->gamepad_keys = 0;
    if (clear_actions) {
        mem[GVAR_SPACEBAR_STATE] = 0;
        mem[GVAR_STATE_B] = 0;
        mem[GVAR_ENTER_KEY] = 0;
    }
}
