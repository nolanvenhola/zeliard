#include "../game/inventory_masm_vm.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long value = 0xCBF29CE484222325ULL;
    while (size--) { value ^= *data++; value *= 0x100000001B3ULL; }
    return value;
}

static int load_player(u8 *memory) {
    FILE *file = fopen("assets/stdply.bin", "rb");
    if (!file) return 0;
    const size_t read = fread(memory, 1, 233, file);
    fclose(file);
    return read == 233;
}

int main(void) {
    u8 *game = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    if (!game || !vga || !load_player(game)) {
        free(game); free(vga);
        puts("VERDICT: FAIL: inventory fixture load");
        return 1;
    }
    game[0x92] = 1;
    game[0x98] = 1;
    game[0xB2] = 100;
    game[0x90] = 100;
    const int started = zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long frame = fnv1a64(vga, 64000);
    const unsigned long long state = fnv1a64(game, 233);
    printf("inventory_masm_entry: started=%d active=%d poll=%d ip=%04x "
           "frame=%016llx state=%016llx itemp=%04x/%04x/%04x/%04x/%04x/%04x/%04x\n", started,
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll(),
           zeliard_inventory_masm_vm_ip(), frame, state,
           zeliard_inventory_masm_vm_itemp_word(0xE200),
           zeliard_inventory_masm_vm_itemp_word(0xE202),
           zeliard_inventory_masm_vm_itemp_word(0xE204),
           zeliard_inventory_masm_vm_itemp_word(0xE206),
           zeliard_inventory_masm_vm_itemp_word(0xE208),
           zeliard_inventory_masm_vm_itemp_word(0xE20A),
           zeliard_inventory_masm_vm_itemp_word(0xE20C));
    int ok = started && zeliard_inventory_masm_vm_active() &&
        zeliard_inventory_masm_vm_at_input_poll() &&
        zeliard_inventory_masm_vm_ip() == 0xAA6C &&
        frame == 0x9b51b5e53ead2dbdULL &&
        zeliard_inventory_masm_vm_itemp_word(0xE200) == 0xE20E &&
        zeliard_inventory_masm_vm_itemp_word(0xE202) == 0xE862 &&
        zeliard_inventory_masm_vm_itemp_word(0xE204) == 0xECE2 &&
        zeliard_inventory_masm_vm_itemp_word(0xE206) == 0xEF22 &&
        zeliard_inventory_masm_vm_itemp_word(0xE208) == 0xF462 &&
        zeliard_inventory_masm_vm_itemp_word(0xE20A) == 0xF5E2 &&
        zeliard_inventory_masm_vm_itemp_word(0xE20C) == 0xFBE2;

    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 0, 0);
    ok &= zeliard_inventory_masm_vm_active() &&
        zeliard_inventory_masm_vm_at_input_poll() &&
        zeliard_inventory_masm_vm_ip() == 0xAA6C;
    printf("inventory_masm_idle_poll: active=%d poll=%d ip=%04x\n",
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll(),
           zeliard_inventory_masm_vm_ip());

    zeliard_inventory_masm_vm_stop();

    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x98] = 1;
    game[0xB2] = 100;
    game[0x90] = 100;
    game[0xFF18] = 1;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    game[0xFF18] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 0, 0);
    printf("inventory_masm_open_release: active=%d exit=%02x\n",
           zeliard_inventory_masm_vm_active(), game[0xAE01]);
    ok &= zeliard_inventory_masm_vm_active() && game[0xAE01] == 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 0, 1);
    printf("inventory_masm_exit_press: active=%d exit=%02x\n",
           zeliard_inventory_masm_vm_active(), game[0xAE01]);
    ok &= !zeliard_inventory_masm_vm_active();
    printf("inventory_masm_enter_cycle: active=%d poll=%d ip=%04x "
           "exit=%02x\n", zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll(),
           zeliard_inventory_masm_vm_ip(), game[0xAE01]);
    ok &= !zeliard_inventory_masm_vm_active();
    zeliard_inventory_masm_vm_stop();

    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x98] = 1;
    game[0xB2] = 100;
    game[0x90] = 100;
    game[0xBB] = 1;
    game[0xBC] = 1;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long populated_entry = fnv1a64(vga, 64000);
    const u8 populated_cursor_before =
        zeliard_inventory_masm_vm_peek(0xADFB);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 4, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const unsigned long long populated_left = fnv1a64(vga, 64000);
    printf("inventory_masm_populated_left: active=%d poll=%d ip=%04x "
           "entry=%016llx left=%016llx spell=%02x count=%02x cursor=%02x/%02x\n",
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll(),
           zeliard_inventory_masm_vm_ip(), populated_entry, populated_left,
           game[0x9D], zeliard_inventory_masm_vm_peek(0xADFA),
           populated_cursor_before,
           zeliard_inventory_masm_vm_peek(0xADFB));
    ok &= zeliard_inventory_masm_vm_active() &&
        zeliard_inventory_masm_vm_at_input_poll() &&
        populated_entry == 0x6916dc254fa0ff29ULL &&
        populated_left == 0x9300d8c22f08091eULL &&
        game[0x9D] == 2 && populated_cursor_before == 2 &&
        zeliard_inventory_masm_vm_peek(0xADFB) == 1;
    zeliard_inventory_masm_vm_stop();

    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA6] = 1;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_TOWN);
    printf("inventory_masm_town_gate: flag=%02x active=%d poll=%d\n",
           zeliard_inventory_masm_vm_peek(0xADF8),
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll());
    ok &= zeliard_inventory_masm_vm_peek(0xADF8) == 0xFF &&
        zeliard_inventory_masm_vm_active() &&
        zeliard_inventory_masm_vm_at_input_poll();
    zeliard_inventory_masm_vm_stop();
    free(game); free(vga);
    printf("VERDICT: %s: release MASM 201SELCT entry frame\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
