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

static int run_direction(u8 direction, u8 shield) {
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
    game[0x93] = shield;
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
    ok &= transition.wait_target == 20;
    ok &= transition.roka_map[0] == 0x07;
    ok &= transition.roka_map[sizeof(transition.roka_map) - 1] == 0x06;

    const unsigned long long first_hash = playfield_hash(vga);
    unsigned long long hero_hashes[4];
    hero_hashes[0] = fnv1a64(
        transition.hero_cells, sizeof(transition.hero_cells));
    ok &= zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 19) == 0;
    ok &= transition.step == 1;
    ok &= zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 1) == 1;
    ok &= transition.step == 2;
    ok &= transition.packed_x == (direction ? 0x3C : 0xAA);
    hero_hashes[1] = fnv1a64(
        transition.hero_cells, sizeof(transition.hero_cells));
    for (u8 pose = 2; pose < 4; ++pose) {
        ok &= zeliard_cavern_transition_advance_pit(
            &transition, game, sizeof(game), vga, sizeof(vga), 20) == 1;
        ok &= transition.step == (u8)(pose + 1);
        hero_hashes[pose] = fnv1a64(
            transition.hero_cells, sizeof(transition.hero_cells));
    }

    /* The MASM loop has 26 draw/wait iterations, followed immediately by
     * the final 0618h clear. No keyboard state is supplied to this API. */
    zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 22 * 20);
    ok &= transition.step == ZEL_CAVERN_TRANSITION_STEPS;
    ok &= transition.active && !transition.complete;
    zeliard_cavern_transition_advance_pit(
        &transition, game, sizeof(game), vga, sizeof(vga), 20);
    ok &= !transition.active && transition.complete;
    ok &= transition.packed_x == (direction ? 0x0C : 0xDA);
    ok &= transition.pose == 0x1A && game[0xE7] == 0x1A;

    const unsigned long long final_hash = playfield_hash(vga);
    const unsigned long long tiles_hash = fnv1a64(
        transition.roka_tiles, sizeof(transition.roka_tiles));
    const unsigned long long map_hash = fnv1a64(
        transition.roka_map, sizeof(transition.roka_map));
    const unsigned long long masks_hash = fnv1a64(
        transition.fman_masks, sizeof(transition.fman_masks));
    printf("cavern_transition_%s_shield%u: first=%016llx "
           "heroes=%016llx,%016llx,%016llx,%016llx "
           "final=%016llx tiles=%016llx map=%016llx masks=%016llx "
           "steps=%u packed_x=%02x\n",
           direction ? "right_to_left" : "left_to_right",
           shield, first_hash, hero_hashes[0], hero_hashes[1],
           hero_hashes[2], hero_hashes[3], final_hash, tiles_hash, map_hash,
           masks_hash, transition.step, transition.packed_x);
    static const unsigned long long expected_heroes[2][2][4] = {
        {
            {0xBFC85115E00A5F6BULL, 0x51FB025D18001B0AULL,
             0xD7A6BC1D6AA4A904ULL, 0x16A349B328945A09ULL},
            {0x5748A2F80C4C6A9AULL, 0x0441ED68C8DF6678ULL,
             0xD84C9852DA1E42D1ULL, 0x0EE27763B99365B6ULL},
        },
        {
            {0x4E8328D801C2F89BULL, 0x825EFEE9677010D6ULL,
             0x51E81E55648CB3CBULL, 0xBD3D9913B19E7B82ULL},
            {0x289B30DA7218A7C6ULL, 0x486AAD227B69F1D2ULL,
             0x6CE49FAD7D3C9070ULL, 0x18BD73799858BB81ULL},
        },
    };
    const unsigned long long expected_first = direction
        ? (shield ? 0x94195577CA63DCB6ULL : 0x2C7C3B2E09750EA3ULL)
        : (shield ? 0x7304BC06AFDB6360ULL : 0x78C4A6227D34DF1DULL);
    for (u8 pose = 0; pose < 4; ++pose)
        ok &= hero_hashes[pose] == expected_heroes[direction][shield][pose];
    return ok && first_hash == expected_first &&
        final_hash == 0xEAA9FF9A250BC759ULL &&
        tiles_hash == 0x567B807C59F8FC48ULL &&
        map_hash == 0xE6059A8DF57C7540ULL &&
        masks_hash == 0x89E910ADEFD499C0ULL;
}

int main(void) {
    const int left_ok = run_direction(0, 0) && run_direction(0, 1);
    const int right_ok = run_direction(1, 0) && run_direction(1, 1);
    const int ok = left_ok && right_ok;
    printf("VERDICT: %s: 200FIGHT ROKA check_c3 forced-run transition\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
