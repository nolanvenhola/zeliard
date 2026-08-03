#include "../game/cavern_transition.h"

#include <stdio.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static unsigned long long playfield_hash(const u8 *vga) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (u16 row = 14; row < 158; ++row) {
        for (u16 col = 48; col < 272; ++col) {
            hash ^= vga[(size_t)row * 320 + col];
            hash *= 0x100000001B3ULL;
        }
    }
    return hash;
}

static int run_direction(u8 direction) {
    static zeliard_cavern_transition_t transition;
    static u8 game[0x10000];
    static u8 vga[0x10000];
    memset(game, 0, sizeof(game));
    memset(vga, 0x3F, sizeof(vga));
    game[0] = direction ? 0 : 1;
    game[0x80] = 0x2D;
    game[0x81] = 0;
    game[0x82] = 0x3D;
    game[0x84] = 7;
    game[0xC2] = 0x40;
    game[0xC3] = direction ? 0xFF : 0;
    game[0xE7] = 0;
    game[0xFF33] = 5;

    int ok = zeliard_cavern_transition_begin(
        &transition, game, sizeof(game), vga, sizeof(vga)) == 0;
    ok &= transition.active && !transition.complete;
    ok &= transition.step == 1 && transition.pose == 1;
    ok &= transition.packed_x == (direction ? 0x3E : 0xA8);
    ok &= game[0x84] == 7;
    ok &= game[0xC2] == (direction ? 0x41 : 0x40);
    ok &= transition.map_width == 0x00F0;
    ok &= transition.wait_target == 20;
    ok &= (direction ? game[0xC013] == 0x1A
                     : game[0xC013] == 0xFF);
    ok &= (direction ? game[0xC014] == 0x00
                     : game[0xC014] == 0xFF);

    const unsigned long long first_hash = playfield_hash(vga);
    ok &= zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 19) == 0;
    ok &= transition.step == 1;
    ok &= zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 1) == 1;
    ok &= transition.step == 2;
    ok &= transition.packed_x == (direction ? 0x3C : 0xAA);

    /* The MASM loop has 26 draw/wait iterations, followed immediately by
     * the final 0618h clear. No keyboard state is supplied to this API. */
    zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 24 * 20);
    ok &= transition.step == ZEL_CAVERN_TRANSITION_STEPS;
    ok &= transition.active && !transition.complete;
    zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 20);
    ok &= !transition.active && transition.complete;
    ok &= transition.packed_x == (direction ? 0x0C : 0xDA);
    ok &= transition.pose == 0x1A && game[0xE7] == 0x1A;

    const unsigned long long final_hash = playfield_hash(vga);
    printf("cavern_transition_%s: first=%016llx final=%016llx "
           "steps=%u packed_x=%02x\n",
           direction ? "right_to_left" : "left_to_right",
           first_hash, final_hash, transition.step, transition.packed_x);
    const unsigned long long expected_first = direction
        ? 0x8C75BEF27064A08CULL : 0x48D95049BE5ACC4BULL;
    return ok && first_hash == expected_first &&
        final_hash == 0x0704EC9455A7754AULL &&
        fnv1a64(transition.pattern_tiles,
                sizeof(transition.pattern_tiles)) == 0x6756A16ADA39B5E7ULL &&
        fnv1a64(transition.map_tiles, sizeof(transition.map_tiles)) != 0;
}

int main(void) {
    const int ok = run_direction(0) && run_direction(1);
    printf("VERDICT: %s: 200FIGHT check_c3 forced-run transition\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
