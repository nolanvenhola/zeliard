#include "../core/input.h"
#include <stdio.h>
#include <string.h>

enum {
    SUBSAMPLE_CTR = 0x02BC,
    PAUSE_LATCH = 0x02BE,
    MUSIC_LATCH = 0x02C2,
    SFX_LATCH = 0x02C3,
    DIR_LO = 0x05C1,
    SKIP_FLAG = 0xFF16,
    INPUT_DIRECTION = 0xFF17,
    TIMER_COUNTER = 0xFF18,
    SPACE_ACTION = 0xFF1D,
    CANCEL_ACTION = 0xFF1E,
    SOUND_FLAG = 0xFF27,
    ASCII_ACTION = 0xFF29,
    VOLUME_B = 0xFF75,
};

static u16 word_at(const u8 *mem, u16 off) {
    return (u16)(mem[off] | ((u16)mem[(u16)(off + 1)] << 8));
}

int main(void) {
    static u8 mem[0x10000];
    zel_input_state_t input;
    int ok = 1;

    zel_input_init(&input, mem);
    ok &= mem[SUBSAMPLE_CTR] == 0x0A;
    ok &= zel_input_advance_pit(&input, mem, 10) == ZEL_INPUT_ACTION_NONE;
    ok &= mem[SUBSAMPLE_CTR] == 5 && mem[PAUSE_LATCH] == 0xFF;
    ok &= mem[MUSIC_LATCH] == 0xFF && mem[SFX_LATCH] == 0xFF;

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_RIGHT);
    ok &= mem[DIR_LO] == 8 && mem[INPUT_DIRECTION] == 8;
    ok &= zel_input_advance_pit(&input, mem, 15) == ZEL_INPUT_ACTION_NONE;
    ok &= mem[INPUT_DIRECTION] == 8;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_RIGHT);
    ok &= mem[DIR_LO] == 0 && mem[INPUT_DIRECTION] == 0;
    printf("continuous_input:held_direction: %s\n", ok ? "PASS" : "FAIL");

    u32 actions = zel_input_key_down(&input, mem, ZEL_INPUT_KEY_ENTER);
    ok &= actions == ZEL_INPUT_ACTION_ENTER;
    ok &= mem[ASCII_ACTION] == 0x0D && word_at(mem, TIMER_COUNTER) == 1;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_ENTER);
    ok &= mem[ASCII_ACTION] == 0x0D && word_at(mem, TIMER_COUNTER) == 0;

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_SPACE);
    ok &= mem[ASCII_ACTION] == 0 && mem[SKIP_FLAG] == 1;
    actions = zel_input_advance_pit(&input, mem, 5);
    ok &= actions == ZEL_INPUT_ACTION_SPACE;
    ok &= mem[SPACE_ACTION] == 0xFF && mem[PAUSE_LATCH] == 0;
    mem[SPACE_ACTION] = 0;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_SPACE);
    ok &= mem[SKIP_FLAG] == 0;
    zel_input_advance_pit(&input, mem, 5);
    ok &= mem[PAUSE_LATCH] == 0xFF;
    printf("continuous_input:space_enter_edges: %s\n", ok ? "PASS" : "FAIL");

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_ALT);
    ok &= mem[SKIP_FLAG] == 2 && mem[CANCEL_ACTION] == 0;
    ok &= zel_input_advance_pit(&input, mem, 5) == ZEL_INPUT_ACTION_NONE;
    ok &= mem[CANCEL_ACTION] == 0xFF;
    mem[CANCEL_ACTION] = 0;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_ALT);
    ok &= mem[SKIP_FLAG] == 0;
    zel_input_advance_pit(&input, mem, 5);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_ALT);
    zel_input_advance_pit(&input, mem, 5);
    ok &= mem[CANCEL_ACTION] == 0xFF;
    zel_input_release_all(&input, mem, 1);
    ok &= mem[SKIP_FLAG] == 0 && mem[CANCEL_ACTION] == 0;
    printf("continuous_input:alt_cancel_latch: %s\n", ok ? "PASS" : "FAIL");

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F1);
    actions = zel_input_advance_pit(&input, mem, 5);
    ok &= actions == ZEL_INPUT_ACTION_TOGGLE_MUSIC;
    ok &= mem[MUSIC_LATCH] == 0 && mem[VOLUME_B] == 1;
    ok &= zel_input_advance_pit(&input, mem, 5) == ZEL_INPUT_ACTION_NONE;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_F1);
    zel_input_advance_pit(&input, mem, 5);
    ok &= mem[MUSIC_LATCH] == 0xFF;

    mem[SOUND_FLAG] = 0xFF;
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F2);
    actions = zel_input_advance_pit(&input, mem, 5);
    ok &= actions == ZEL_INPUT_ACTION_TOGGLE_SOUND;
    ok &= mem[SFX_LATCH] == 0 && mem[SOUND_FLAG] == 0;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_F2);
    zel_input_advance_pit(&input, mem, 5);
    ok &= mem[SFX_LATCH] == 0xFF;
    printf("continuous_input:special_key_latches: %s\n", ok ? "PASS" : "FAIL");

    actions = zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F9);
    ok &= actions == ZEL_INPUT_ACTION_SPEED_MENU;
    ok &= word_at(mem, TIMER_COUNTER) == 0x8000;
    ok &= zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F9) ==
        ZEL_INPUT_ACTION_NONE;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_F9);
    ok &= word_at(mem, TIMER_COUNTER) == 0;
    printf("continuous_input:f9_speed_edge: %s\n", ok ? "PASS" : "FAIL");

    actions = zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F7);
    ok &= actions == ZEL_INPUT_ACTION_RESTORE_MENU;
    ok &= word_at(mem, TIMER_COUNTER) == 0x4000;
    ok &= zel_input_key_down(&input, mem, ZEL_INPUT_KEY_F7) ==
        ZEL_INPUT_ACTION_NONE;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_F7);
    ok &= word_at(mem, TIMER_COUNTER) == 0;
    printf("continuous_input:f7_restore_edge: %s\n", ok ? "PASS" : "FAIL");

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_CONTROL);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_SHIFT);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_S);
    ok &= word_at(mem, TIMER_COUNTER) == 0x0086;
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_E);
    ok &= word_at(mem, TIMER_COUNTER) == 0x0286;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_S);
    ok &= word_at(mem, TIMER_COUNTER) == 0x0206;
    zel_input_release_all(&input, mem, 1);
    ok &= word_at(mem, TIMER_COUNTER) == 0;
    printf("continuous_input:secret_level_exp_chord: %s\n",
           ok ? "PASS" : "FAIL");

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_LEFT);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_SPACE);
    mem[SPACE_ACTION] = 0xFF;
    mem[ASCII_ACTION] = 0x0D;
    zel_input_release_all(&input, mem, 1);
    ok &= input.held_keys == 0 && mem[INPUT_DIRECTION] == 0;
    ok &= mem[SKIP_FLAG] == 0 && word_at(mem, TIMER_COUNTER) == 0;
    ok &= mem[SPACE_ACTION] == 0 && mem[ASCII_ACTION] == 0;
    printf("continuous_input:focus_release: %s\n", ok ? "PASS" : "FAIL");

    memset(mem, 0, sizeof(mem));
    zel_input_init(&input, mem);
    zel_input_advance_pit(&input, mem, 10); /* arm released latches */
    actions = zel_input_gamepad_update(&input, mem,
        ZEL_GAMEPAD_UP | ZEL_GAMEPAD_RIGHT,
        ZEL_GAMEPAD_A | ZEL_GAMEPAD_B);
    ok &= actions == ZEL_INPUT_ACTION_NONE;
    ok &= mem[DIR_LO] == 0x09 && mem[INPUT_DIRECTION] == 0x09;
    ok &= mem[SKIP_FLAG] == 0x03;
    actions = zel_input_advance_pit(&input, mem, 5);
    ok &= (actions & ZEL_INPUT_ACTION_SPACE) != 0;
    ok &= mem[SPACE_ACTION] == 0xFF && mem[CANCEL_ACTION] == 0xFF;
    ok &= zel_input_gamepad_update(&input, mem,
        ZEL_GAMEPAD_UP | ZEL_GAMEPAD_RIGHT,
        ZEL_GAMEPAD_A | ZEL_GAMEPAD_B) == ZEL_INPUT_ACTION_NONE;
    printf("continuous_input:gamepad_masm_masks: %s\n",
           ok ? "PASS" : "FAIL");

    zel_input_gamepad_update(&input, mem, ZEL_GAMEPAD_RIGHT, 0);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_RIGHT);
    zel_input_gamepad_update(&input, mem, 0, 0);
    ok &= mem[INPUT_DIRECTION] == ZEL_GAMEPAD_RIGHT;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_RIGHT);
    ok &= mem[INPUT_DIRECTION] == 0;

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_LEFT);
    zel_input_gamepad_update(&input, mem, ZEL_GAMEPAD_LEFT, 0);
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_LEFT);
    ok &= mem[INPUT_DIRECTION] == ZEL_GAMEPAD_LEFT;
    zel_input_gamepad_update(&input, mem, 0, 0);
    ok &= mem[INPUT_DIRECTION] == 0;
    printf("continuous_input:keyboard_gamepad_coexistence: %s\n",
           ok ? "PASS" : "FAIL");

    actions = zel_input_gamepad_update(&input, mem, 0, ZEL_GAMEPAD_X);
    ok &= actions == ZEL_INPUT_ACTION_ENTER;
    ok &= zel_input_gamepad_update(&input, mem, 0, ZEL_GAMEPAD_X) ==
        ZEL_INPUT_ACTION_NONE;
    zel_input_gamepad_update(&input, mem, 0, 0);
    actions = zel_input_gamepad_update(&input, mem, 0, ZEL_GAMEPAD_START);
    ok &= actions == ZEL_INPUT_ACTION_ESCAPE;
    zel_input_gamepad_update(&input, mem, 0, 0);
    actions = zel_input_gamepad_update(&input, mem, 0, ZEL_GAMEPAD_BACK);
    ok &= actions == ZEL_INPUT_ACTION_RESTORE_MENU;
    zel_input_gamepad_update(&input, mem, 0, 0);
    actions = zel_input_gamepad_update(&input, mem, 0, ZEL_GAMEPAD_Y);
    ok &= actions == ZEL_INPUT_ACTION_SPEED_MENU;
    zel_input_gamepad_update(&input, mem, 0, 0);
    printf("continuous_input:gamepad_host_actions: %s\n",
           ok ? "PASS" : "FAIL");

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_RIGHT);
    zel_input_gamepad_update(&input, mem, ZEL_GAMEPAD_LEFT,
                             ZEL_GAMEPAD_A);
    zel_input_gamepad_update(&input, mem, 0, 0); /* disconnect release */
    ok &= mem[INPUT_DIRECTION] == ZEL_GAMEPAD_RIGHT;
    ok &= mem[SKIP_FLAG] == 0;
    zel_input_key_up(&input, mem, ZEL_INPUT_KEY_RIGHT);
    ok &= mem[INPUT_DIRECTION] == 0;
    printf("continuous_input:gamepad_disconnect_release: %s\n",
           ok ? "PASS" : "FAIL");

    printf("VERDICT: %s: continuous input matches stick.asm memory transitions\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
