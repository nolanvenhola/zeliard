#include "../game/fight_masm_vm.h"
#include "../render/palette.h"

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

static void prepare_player(u8 *game) {
    memset(game, 0, 0x10000);
    game[0x80] = 4;
    game[0x82] = 21;
    game[0x83] = 12;
    game[0x91] = 2;
    game[0x98] = 1;
    game[0xA0] = 8;
    game[0xB3] = 2;
    game[0xC4] = 0x1E;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

int main(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game);
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= zeliard_fight_masm_vm_poke_u16(0xAC06, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAC20, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned frames = 0, completion = 0;
    while (zeliard_fight_masm_vm_active() && frames < 300 && !completion) {
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, 0);
        ++frames;
        if (!completion && game[0xFF30] == 0xFF) completion = frames;
        if ((frames % 100) == 0 || !zeliard_fight_masm_vm_active())
            printf("handoff frame=%u active=%d ip=%04x completion=%02x "
                   "item=%02x warp=%02x init=%02x area=%02x exit=%u/%02x/%04x\n",
                   frames, zeliard_fight_masm_vm_active(),
                   zeliard_fight_masm_vm_ip(), game[0xFF30], game[0xFF4B],
                   zeliard_fight_masm_vm_peek_u8(0x9F1E), game[0xB3],
                   game[0xC4], zeliard_fight_masm_vm_exit_operation(),
                   zeliard_fight_masm_vm_exit_selector(),
                   zeliard_fight_masm_vm_exit_dispatch_slot());
    }
    printf("completion=%u frames=%u active=%d requested=%d\n", completion,
           frames, zeliard_fight_masm_vm_active(),
           zeliard_fight_masm_vm_ending_requested());
    ok &= completion == 121 && zeliard_fight_masm_vm_ending_requested();
    const int ending_started = zeliard_fight_masm_vm_begin_ending();
    printf("ending_started=%d ip=%04x wait=%d\n", ending_started,
           zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_ending_active());
    ok &= zeliard_fight_masm_vm_advance(
        game, sizeof(game), vga, sizeof(vga), 255, 0);
    const unsigned long long first_ending_hash = fnv1a64(vga, 64000);
    printf("ending_first_frame: active=%d ip=%04x scene=%u music=%02x "
           "hash=%016llx\n", zeliard_fight_masm_vm_ending_active(),
           zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_ending_scene(),
           zeliard_fight_masm_vm_music_chunk(), first_ending_hash);
    ok &= ending_started && zeliard_fight_masm_vm_ending_active() &&
        zeliard_fight_masm_vm_music_chunk() == 0xFF &&
        first_ending_hash == 0xEB3313660845B4C4ULL;
    printf("VERDICT: %s: exact Jashiin completion to first 250ENDMO frame\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
