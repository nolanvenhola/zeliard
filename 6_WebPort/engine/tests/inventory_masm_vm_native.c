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

    /* The normal-key byte is an independent count, not a boolean.  The
     * release panel reads that byte directly and separately from 0099h. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x98] = 12;
    game[0x99] = 0;
    game[0xB2] = 100;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long regular_keys_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_regular_keys: normal=%u lion=%u frame=%016llx\n",
           game[0x98], game[0x99], regular_keys_frame);
    ok &= game[0x98] == 12 && game[0x99] == 0 &&
        regular_keys_frame == 0x7FCD79835DAE904CULL;
    zeliard_inventory_masm_vm_stop();

    /* Lion Head's Key is the distinct 0099h special-key count.  It draws
     * in the inventory stats panel and remains separate from normal keys. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x98] = 0;
    game[0x99] = 1;
    game[0xB2] = 100;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long lion_key_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_lion_key: normal=%u lion=%u frame=%016llx\n",
           game[0x98], game[0x99], lion_key_frame);
    ok &= game[0x98] == 0 && game[0x99] == 1 &&
        lion_key_frame == 0xC75C5285A14628DFULL;
    zeliard_inventory_masm_vm_stop();

    /* Elf Crest is the first native ability slot at 009Ah. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x9A] = 0xFF;
    game[0x9B] = 0;
    game[0x9C] = 0;
    game[0xB2] = 100;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long elf_crest_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_elf_crest: abilities=%02x/%02x/%02x "
           "frame=%016llx\n", game[0x9A], game[0x9B], game[0x9C],
           elf_crest_frame);
    ok &= game[0x9A] == 0xFF && game[0x9B] == 0 && game[0x9C] == 0 &&
        elf_crest_frame == 0xE03E6EAF78609F00ULL;
    zeliard_inventory_masm_vm_stop();

    /* Glory Crest is the second native ability slot at 009Bh. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x9A] = 0;
    game[0x9B] = 0xFF;
    game[0x9C] = 0;
    game[0xB2] = 100;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long glory_crest_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_glory_crest: abilities=%02x/%02x/%02x "
           "frame=%016llx\n", game[0x9A], game[0x9B], game[0x9C],
           glory_crest_frame);
    ok &= game[0x9A] == 0 && game[0x9B] == 0xFF && game[0x9C] == 0 &&
        glory_crest_frame == 0xC1F1DA33BD88CCEEULL;
    zeliard_inventory_masm_vm_stop();

    /* Hero's Crest is the third native ability slot at 009Ch.  The
     * unmodified 201SELCT loop must draw that owned crest in the inventory
     * panel without synthesizing either of the other two crest slots. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x9A] = 0;
    game[0x9B] = 0;
    game[0x9C] = 0xFF;
    game[0xB2] = 100;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long hero_crest_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_hero_crest: abilities=%02x/%02x/%02x "
           "frame=%016llx\n", game[0x9A], game[0x9B], game[0x9C],
           hero_crest_frame);
    ok &= game[0x9A] == 0 && game[0x9B] == 0 && game[0x9C] == 0xFF &&
        hero_crest_frame == 0x8742DDA53C8D5CCEULL;
    zeliard_inventory_masm_vm_stop();

    /* Tier 1 is the Clay Shield. Its identity and 30/30 strength render
     * through the unmodified release inventory path. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x93] = 1;
    game[0x94] = 30;
    game[0x96] = 30;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long clay_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_clay_shield: shield=%u hp=%u/%u "
           "frame=%016llx\n", game[0x93], game[0x94], game[0x96],
           clay_frame);
    ok &= game[0x93] == 1 && game[0x94] == 30 && game[0x96] == 30 &&
        clay_frame == 0xFD80403148D2EDF4ULL;
    zeliard_inventory_masm_vm_stop();

    /* Tier 3 is the Stone Shield.  Its equipped identity and persisted
     * 180/180 strength render through the unmodified 201SELCT/GMMCGA path. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0x92] = 1;
    game[0x93] = 3;
    game[0x94] = 180;
    game[0x96] = 180;
    game[0x98] = 1;
    game[0x90] = 100;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const unsigned long long stone_frame = fnv1a64(vga, 64000);
    printf("inventory_masm_stone_shield: shield=%u hp=%u/%u "
           "frame=%016llx\n", game[0x93], game[0x94], game[0x96],
           stone_frame);
    ok &= game[0x93] == 3 && game[0x94] == 180 && game[0x96] == 180 &&
        stone_frame == 0xD751025FDA37F6EAULL;
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

    /* Pirika alone remains a compact, owned choice at cursor one and the
     * selected wearable survives the exact 201SELCT entry path unchanged. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA1] = 2;
    game[0x9E] = 2;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const u8 pirika_count = zeliard_inventory_masm_vm_peek(0xADFC);
    const u8 pirika_cursor = zeliard_inventory_masm_vm_peek(0xADFD);
    const u8 pirika_none = zeliard_inventory_masm_vm_peek(0xAE0A);
    const u8 pirika_owned = zeliard_inventory_masm_vm_peek(0xAE0B);
    printf("inventory_masm_pirika: selected=%u count=%u cursor=%u "
           "table=%u/%u\n", game[0x9E], pirika_count, pirika_cursor,
           pirika_none, pirika_owned);
    ok &= game[0x9E] == 2 && pirika_count == 2 && pirika_cursor == 1 &&
        pirika_none == 0 && pirika_owned == 2;
    zeliard_inventory_masm_vm_stop();

    /* The same owned-only table and selected-wearable state apply to
     * Silkarn ID 3 without synthesizing any unavailable shoe entries. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA4] = 3;
    game[0x9E] = 3;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const u8 silkarn_count = zeliard_inventory_masm_vm_peek(0xADFC);
    const u8 silkarn_cursor = zeliard_inventory_masm_vm_peek(0xADFD);
    const u8 silkarn_none = zeliard_inventory_masm_vm_peek(0xAE0A);
    const u8 silkarn_owned = zeliard_inventory_masm_vm_peek(0xAE0B);
    printf("inventory_masm_silkarn: selected=%u count=%u cursor=%u "
           "table=%u/%u\n", game[0x9E], silkarn_count, silkarn_cursor,
           silkarn_none, silkarn_owned);
    ok &= game[0x9E] == 3 && silkarn_count == 2 && silkarn_cursor == 1 &&
        silkarn_none == 0 && silkarn_owned == 3;
    zeliard_inventory_masm_vm_stop();

    /* Asbestos Cape is wearable ID 5 and uses the same mutually-exclusive
     * accessory slot and exact selected state as the four shoe types. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA5] = 5;
    game[0x9E] = 5;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const u8 cape_count = zeliard_inventory_masm_vm_peek(0xADFC);
    const u8 cape_cursor = zeliard_inventory_masm_vm_peek(0xADFD);
    const u8 cape_none = zeliard_inventory_masm_vm_peek(0xAE0A);
    const u8 cape_owned = zeliard_inventory_masm_vm_peek(0xAE0B);
    printf("inventory_masm_asbestos: selected=%u count=%u cursor=%u "
           "table=%u/%u\n", game[0x9E], cape_count, cape_cursor,
           cape_none, cape_owned);
    ok &= game[0x9E] == 5 && cape_count == 2 && cape_cursor == 1 &&
        cape_none == 0 && cape_owned == 5;
    zeliard_inventory_masm_vm_stop();

    /* Feruza ID 1 is also preserved as the selected, owned-only wearable. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    game[0xA3] = 1;
    game[0x9E] = 1;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    const u8 feruza_count = zeliard_inventory_masm_vm_peek(0xADFC);
    const u8 feruza_cursor = zeliard_inventory_masm_vm_peek(0xADFD);
    const u8 feruza_none = zeliard_inventory_masm_vm_peek(0xAE0A);
    const u8 feruza_owned = zeliard_inventory_masm_vm_peek(0xAE0B);
    printf("inventory_masm_feruza: selected=%u count=%u cursor=%u "
           "table=%u/%u\n", game[0x9E], feruza_count, feruza_cursor,
           feruza_none, feruza_owned);
    ok &= game[0x9E] == 1 && feruza_count == 2 && feruza_cursor == 1 &&
        feruza_none == 0 && feruza_owned == 1;
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

    /* The release removes the selected item before dispatch, so a Ken'ko
     * used at full life is still consumed and still emits cue 0Eh. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 1;
    game[0x90] = 100;
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
    const u16 full_potion_hp =
        (u16)(game[0x90] | ((u16)game[0x91] << 8));
    const u8 full_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 full_potion_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_potion_full: hp=%u item=%02x result=%02x "
           "cue=%02x\n", full_potion_hp, game[0xA6], game[0xFF4B],
           full_potion_cue);
    ok &= full_potion_hp == 100 && game[0xA6] == 0 &&
        game[0xFF4B] == 1 && full_select_cue == 0x0C &&
        full_potion_cue == 0x0E &&
        zeliard_inventory_masm_vm_take_sound_cue() == 0;
    zeliard_inventory_masm_vm_stop();

    /* Juu-en Fruit is item ID 2 and assigns maximum life directly. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 2;
    game[0x90] = 10;
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
    const u16 fruit_hp = (u16)(game[0x90] | ((u16)game[0x91] << 8));
    const u8 fruit_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 fruit_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_juuen: hp=%u item=%02x result=%02x cue=%02x\n",
           fruit_hp, game[0xA6], game[0xFF4B], fruit_cue);
    ok &= fruit_hp == 100 && game[0xA6] == 0 && game[0xFF4B] == 2 &&
        fruit_select_cue == 0x0C && fruit_cue == 0x0E &&
        zeliard_inventory_masm_vm_take_sound_cue() == 0;
    zeliard_inventory_masm_vm_stop();

    /* Elixir of Kashi (item ID 3) restores the selected spell to its
     * per-spell maximum; it does not merely add one charge. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 3;
    game[0x9D] = 2;
    game[0xAC] = 1;
    game[0xB5] = 6;
    ok &= zeliard_inventory_masm_vm_start(
        game, 0x10000, vga, 0x10000, ZEL_INVENTORY_CONTEXT_CAVERN);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 8, 0, 0);
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    zeliard_inventory_masm_vm_poke(0x009D, 2);
    game[0xFF16] = 1;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      1, 0, 1, 0);
    game[0xFF16] = 0;
    zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                      100, 0, 0, 0);
    const u8 elixir_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 elixir_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_elixir: charge=%u/%u item=%02x result=%02x "
           "cue=%02x\n", game[0xAC], game[0xB5], game[0xA6],
           game[0xFF4B], elixir_cue);
    ok &= game[0xAC] == 6 && game[0xB5] == 6 && game[0xA6] == 0 &&
        game[0xFF4B] == 3 && elixir_select_cue == 0x0C &&
        elixir_cue == 0x0E;
    zeliard_inventory_masm_vm_stop();

    /* Chikara Powder copies all seven maximum-charge bytes, including
     * unlearned spell slots, exactly as release REP MOVSB does. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 4;
    memset(game + 0xAB, 0, 7);
    for (u8 i = 0; i < 7; ++i) game[0xB4 + i] = (u8)(i + 1);
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
    const u8 chikara_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 chikara_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_chikara: charges=%u/%u/%u/%u/%u/%u/%u "
           "item=%02x result=%02x cue=%02x\n", game[0xAB], game[0xAC],
           game[0xAD], game[0xAE], game[0xAF], game[0xB0], game[0xB1],
           game[0xA6], game[0xFF4B], chikara_cue);
    ok &= memcmp(game + 0xAB, game + 0xB4, 7) == 0 &&
        game[0xA6] == 0 && game[0xFF4B] == 4 &&
        chikara_select_cue == 0x0C && chikara_cue == 0x0E;
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

    /* Holy Water repairs Clay Shield tier 1 by 80 points, capped to 30. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 6;
    game[0x93] = 1;
    game[0x94] = 10;
    game[0x96] = 30;
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
    const u16 clay_repaired = (u16)(game[0x94] | ((u16)game[0x95] << 8));
    const u8 clay_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 clay_repair_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_clay_holy_water: shield=%u/30 item=%02x "
           "result=%02x cue=%02x\n", clay_repaired, game[0xA6],
           game[0xFF4B], clay_repair_cue);
    ok &= clay_repaired == 30 && game[0xA6] == 0 &&
        game[0xFF4B] == 6 && clay_select_cue == 0x0C &&
        clay_repair_cue == 0x0E;
    zeliard_inventory_masm_vm_stop();

    /* Holy Water ID 6 repairs Stone Shield tier 3 by its native 100 points
     * and caps at the player's persisted 180 maximum strength. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 6;
    game[0x93] = 3;
    game[0x94] = 100;
    game[0x95] = 0;
    game[0x96] = 180;
    game[0x97] = 0;
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
    const u16 holy_shield = (u16)(game[0x94] | ((u16)game[0x95] << 8));
    const u8 holy_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 holy_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_stone_holy_water: shield=%u/180 item=%02x "
           "result=%02x cue=%02x\n", holy_shield, game[0xA6],
           game[0xFF4B], holy_cue);
    ok &= holy_shield == 180 && game[0xA6] == 0 &&
        game[0xFF4B] == 6 && holy_select_cue == 0x0C && holy_cue == 0x0E;
    zeliard_inventory_masm_vm_stop();

    /* Item removal precedes dispatch: with no shield equipped, Holy Water
     * is consumed and cue 0Eh is posted, but shield strength is untouched. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 6;
    game[0x93] = 0;
    game[0x94] = 17;
    game[0x96] = 80;
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
    const u8 empty_holy_select = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 empty_holy_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_holy_water_no_shield: shield=%u item=%02x "
           "result=%02x cue=%02x\n", game[0x94], game[0xA6],
           game[0xFF4B], empty_holy_cue);
    ok &= game[0x94] == 17 && game[0xA6] == 0 && game[0xFF4B] == 6 &&
        empty_holy_select == 0x0C && empty_holy_cue == 0x0E;
    zeliard_inventory_masm_vm_stop();

    /* Kioku Feather ID 8 consumes itself, posts its distinct 0Fh cue,
     * waits 120 release timer ticks, fades, and returns result 8 to the
     * resident fight loop for the last-Sage level reload. */
    memset(game, 0, 0x10000);
    memset(vga, 0, 0x10000);
    ok &= load_player(game);
    memset(game + 0xA1, 0, 0x21);
    game[0xA6] = 8;
    game[0xC5] = 0x84;
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
    unsigned kioku_batches = 0;
    while (zeliard_inventory_masm_vm_active() && kioku_batches++ < 20)
        zeliard_inventory_masm_vm_advance(game, 0x10000, vga, 0x10000,
                                          200, 0, 0, 0);
    const u8 kioku_select_cue = zeliard_inventory_masm_vm_take_sound_cue();
    const u8 kioku_cue = zeliard_inventory_masm_vm_take_sound_cue();
    printf("inventory_masm_kioku: active=%d ip=%04x batches=%u item=%02x "
           "result=%02x scene=%02x sage=%02x timer=%02x cue=%02x\n",
           zeliard_inventory_masm_vm_active(),
           zeliard_inventory_masm_vm_ip(), kioku_batches, game[0xA6],
           game[0xFF4B], game[0xFF24], game[0xC5], game[0xFF1A], kioku_cue);
    ok &= !zeliard_inventory_masm_vm_active() && game[0xA6] == 0 &&
        game[0xFF4B] == 8 && game[0xFF24] == 8 && game[0xC5] == 0x84 &&
        kioku_select_cue == 0x0C && kioku_cue == 0x0F;
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
