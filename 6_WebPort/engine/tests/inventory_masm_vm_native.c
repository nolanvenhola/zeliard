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

    /* 201SELCT builds one wearable cursor table from A1h..A5h and keeps
     * selected_accessory (9Eh) on the matching owned entry. Ruzeria is ID
     * 4; the implicit leading zero is the unequipped choice. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA1] = 2;
    game[0xA2] = 4;
    game[0xA3] = 5;
    game[0x9E] = 4;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const u8 wearable_count = zeliard_inventory_masm_vm_peek(0xADFC);
    const u8 wearable_cursor = zeliard_inventory_masm_vm_peek(0xADFD);
    const u8 wearable_none = zeliard_inventory_masm_vm_peek(0xAE0A);
    const u8 wearable_pirika = zeliard_inventory_masm_vm_peek(0xAE0B);
    const u8 wearable_ruzeria = zeliard_inventory_masm_vm_peek(0xAE0C);
    const u8 wearable_cape = zeliard_inventory_masm_vm_peek(0xAE0D);
    printf("inventory_masm_ruzeria: selected=%u count=%u cursor=%u "
           "table=%u/%u/%u/%u\n", game[0x9E], wearable_count,
           wearable_cursor, wearable_none, wearable_pirika,
           wearable_ruzeria, wearable_cape);
    ok &= game[0x9E] == 4 && wearable_count == 4 &&
        wearable_cursor == 2 && wearable_none == 0 &&
        wearable_pirika == 2 && wearable_ruzeria == 4 &&
        wearable_cape == 5;
    zeliard_inventory_masm_vm_stop();

    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 1; /* Kenshiko Potion */
    game[0x90] = 10;
    game[0x91] = 0;
    game[0xB2] = 100;
    game[0xB3] = 0;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    game[0xFF16] = 1;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 1, 0);
    game[0xFF16] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const u16 potion_hp = (u16)(game[0x90] | ((u16)game[0x91] << 8));
    const u8 select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 potion_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 potion_cue_repeat = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_potion: hp=%u item=%02x result=%02x cue=%02x\n",
           potion_hp, game[0xA6], game[0xFF4B], potion_cue);
    ok &= potion_hp == 90 && game[0xA6] == 0 &&
        game[0xFF4B] == 1 && select_cue == 0x0C &&
        potion_cue == 0x0E && potion_cue_repeat == 0;
    zeliard_inventory_masm_vm_stop();

    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 1;
    game[0x90] = 70;
    game[0xB2] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    game[0xFF16] = 1;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 1, 0);
    game[0xFF16] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const u16 capped_potion_hp =
        (u16)(game[0x90] | ((u16)game[0x91] << 8));
    const u8 capped_select_cue =
        zeliard_inventory_masm_vm_take_sound_cue();
    const u8 capped_potion_cue =
        zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_potion_cap: hp=%u item=%02x result=%02x "
           "cue=%02x\n", capped_potion_hp, game[0xA6], game[0xFF4B],
           capped_potion_cue);
    ok &= capped_potion_hp == 100 && game[0xA6] == 0 &&
        game[0xFF4B] == 1 && capped_select_cue == 0x0C &&
        capped_potion_cue == 0x0E &&
        zeliard_inventory_masm_vm_take_sound_cue() == 0;
    zeliard_inventory_masm_vm_stop();

    /* Release 201SELCT item ID 5 (Magia Stone) seeds 200FIGHT's four
     * seven-byte orbiting-sprite records at EB60h. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    memset(game + 0xEB60, 0xFF, 4u * 7u);
    game[0xA6] = 5;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    game[0xFF16] = 1;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 1, 0);
    game[0xFF16] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    static const u8 magia_orbit[4u * 7u] = {
        0x00, 0x01, 0x50, 0x00, 0x00, 0x00, 0x00,
        0x04, 0xFF, 0x50, 0x00, 0x00, 0x00, 0x00,
        0x08, 0xFF, 0x50, 0x00, 0x00, 0x00, 0x00,
        0x0C, 0x01, 0x50, 0x00, 0x00, 0x00, 0x00
    };
    const int magia_matches =
        memcmp(game + 0xEB60, magia_orbit, sizeof(magia_orbit)) == 0;
    printf("inventory_masm_magia: item=%02x result=%02x orbit=%d "
           "heads=%02x/%02x/%02x/%02x\n", game[0xA6], game[0xFF4B],
           magia_matches, game[0xEB60], game[0xEB67], game[0xEB6E],
           game[0xEB75]);
    ok &= game[0xA6] == 0 && game[0xFF4B] == 5 && magia_matches;
    zeliard_inventory_masm_vm_stop();

    /* Release item ID 7 (Sabre Oil) increments E4h. 200FIGHT consumes that
     * byte in compute_action_anim_idx as the sword attack multiplier. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 7;
    game[0xE4] = 0;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    game[0xFF16] = 1;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 1, 0);
    game[0xFF16] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    printf("inventory_masm_sabre_oil: item=%02x result=%02x power=%u\n",
           game[0xA6], game[0xFF4B], game[0xE4]);
    ok &= game[0xA6] == 0 && game[0xFF4B] == 7 && game[0xE4] == 1;
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
    /* Imported save mismatch: Guerra selected, but only Espada and Saeta
     * are learned. The MASM overlay must start on the last populated slot. */
    game[0x9D] = 7;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long populated_entry = fnv1a64(vga, 64000);
    const u8 populated_cursor_before =
        zeliard_inventory_masm_vm_peek(0xADFB);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const unsigned long long populated_right_bound = fnv1a64(vga, 64000);
    const u8 populated_cursor_at_bound =
        zeliard_inventory_masm_vm_peek(0xADFB);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 4, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const unsigned long long populated_left = fnv1a64(vga, 64000);
    printf("inventory_masm_populated_bounds: active=%d poll=%d ip=%04x "
           "entry=%016llx right=%016llx left=%016llx spell=%02x "
           "count=%02x cursor=%02x/%02x/%02x\n",
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_at_input_poll(),
           zeliard_inventory_masm_vm_ip(), populated_entry,
           populated_right_bound, populated_left,
           game[0x9D], zeliard_inventory_masm_vm_peek(0xADFA),
           populated_cursor_before, populated_cursor_at_bound,
           zeliard_inventory_masm_vm_peek(0xADFB));
    ok &= zeliard_inventory_masm_vm_active() &&
        zeliard_inventory_masm_vm_at_input_poll() &&
        populated_entry == 0x49B2E39AB40708FEULL &&
        populated_right_bound == populated_entry &&
        populated_left == 0x211BFDDAAF3182C8ULL &&
        game[0x9D] == 1 && populated_cursor_before == 1 &&
        populated_cursor_at_bound == 1 &&
        zeliard_inventory_masm_vm_peek(0xADFB) == 0;
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
