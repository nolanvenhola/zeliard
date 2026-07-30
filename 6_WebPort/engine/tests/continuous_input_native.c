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

    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_LEFT);
    zel_input_key_down(&input, mem, ZEL_INPUT_KEY_SPACE);
    mem[SPACE_ACTION] = 0xFF;
    mem[ASCII_ACTION] = 0x0D;
    zel_input_release_all(&input, mem, 1);
    ok &= input.held_keys == 0 && mem[INPUT_DIRECTION] == 0;
    ok &= mem[SKIP_FLAG] == 0 && word_at(mem, TIMER_COUNTER) == 0;
    ok &= mem[SPACE_ACTION] == 0 && mem[ASCII_ACTION] == 0;
    printf("continuous_input:focus_release: %s\n", ok ? "PASS" : "FAIL");

    printf("VERDICT: %s: continuous input matches stick.asm memory transitions\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
