#include "../game/fight_masm_vm.h"
#include "../render/palette.h"

#include <stdio.h>
#include <string.h>

static void prepare_player(u8 *game, u8 area, u8 sword) {
    memset(game, 0, 0x10000);
    game[0x80] = 32;
    game[0x82] = 24;
    game[0x83] = 12;
    game[0x91] = 1;
    game[0x92] = sword;
    game[0xB3] = 1;
    game[0xC4] = area;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

static int start_valid(u8 *game, u8 *vga, u8 area, u8 sword) {
    prepare_player(game, area, sword);
    memset(vga, 0, 0x10000);
    const int started = zeliard_fight_masm_vm_start(
        game, 0x10000, vga, 0x10000);
    const int ok = started && zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_at_frame() &&
        zeliard_fight_masm_vm_last_error() == ZEL_FIGHT_VM_ERROR_NONE;
    zeliard_fight_masm_vm_stop();
    return ok;
}

static int reject_unchanged(u8 *game, u8 *vga, u8 area, u8 sword,
                            zeliard_fight_vm_error_t error) {
    static u8 game_before[0x10000], vga_before[0x10000];
    prepare_player(game, area, sword);
    memset(vga, 0xA5, 0x10000);
    memcpy(game_before, game, sizeof(game_before));
    memcpy(vga_before, vga, sizeof(vga_before));
    const int started = zeliard_fight_masm_vm_start(
        game, 0x10000, vga, 0x10000);
    return !started && !zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_last_error() == error &&
        memcmp(game, game_before, sizeof(game_before)) == 0 &&
        memcmp(vga, vga_before, sizeof(vga_before)) == 0;
}

int main(void) {
    static u8 game[0x10000], vga[0x10000];
    int ok = 1;
    palette_set_game_mcga();

    for (unsigned area = 0; area <= 0x1E; ++area) {
        const int accepted = start_valid(game, vga, (u8)area, 1);
        printf("fight_area_selector_%02X=%d\n", area, accepted);
        ok &= accepted;
    }
    for (unsigned sword = 0; sword <= 6; ++sword) {
        const int accepted = start_valid(game, vga, 0, (u8)sword);
        printf("fight_sword_selector_%02X=%d\n", sword, accepted);
        ok &= accepted;
    }

    static const u8 bad_areas[] = {0x1F, 0x7F, 0xFF};
    for (unsigned i = 0; i < sizeof(bad_areas); ++i)
        ok &= reject_unchanged(game, vga, bad_areas[i], 1,
                               ZEL_FIGHT_VM_ERROR_AREA_SELECTOR);
    static const u8 bad_swords[] = {7, 0xFF};
    for (unsigned i = 0; i < sizeof(bad_swords); ++i)
        ok &= reject_unchanged(game, vga, 0, bad_swords[i],
                               ZEL_FIGHT_VM_ERROR_SWORD_SELECTOR);

    ok &= !zeliard_fight_masm_vm_start(NULL, 0, vga, sizeof(vga)) &&
        zeliard_fight_masm_vm_last_error() == ZEL_FIGHT_VM_ERROR_ARGUMENT;
    printf("fight_selector_domain=%s\n", ok ? "ok" : "failed");
    return ok ? 0 : 1;
}
