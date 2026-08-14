#include "../core/types.h"

#include <stdio.h>

void zeliard_init(void);
void zeliard_opening_set_phase_for_test(int phase);
void zeliard_key(int keycode);
void zeliard_tick(u32 dt_ms);
int zeliard_scene(void);
int zeliard_inventory_active(void);
int zeliard_test_begin_malicia_combat(void);
int zeliard_test_game_set_u8(unsigned offset, unsigned value);
int zeliard_test_game_u8(unsigned offset);
int zeliard_test_game_u16(unsigned offset);
int zeliard_test_fight_u8(unsigned offset);
int zeliard_debug_invincible(void);
void zeliard_debug_set_invincible(int enabled);
int zeliard_debug_no_gravity(void);
void zeliard_debug_set_no_gravity(int enabled);
void zeliard_debug_restore_shield_magic(void);
int zeliard_debug_add_item(int item_id);

int main(void) {
    int ok = 1;
    zeliard_init();
    zeliard_opening_set_phase_for_test(3);
    zeliard_key(13);
    zeliard_tick(0);
    ok &= zeliard_scene() == 2;
    ok &= zeliard_test_begin_malicia_combat();

    /* Exact release-MASM bytes: SAR loading strips the four-byte header, so
     * fight.bin offsets 0974h and 1689h are resident at 6970h and 7685h. */
    ok &= zeliard_test_fight_u8(0x6970) == 0xE8;
    ok &= zeliard_test_fight_u8(0x7685) == 0x29;
    zeliard_debug_set_no_gravity(1);
    ok &= zeliard_debug_no_gravity() == 1;
    ok &= zeliard_test_fight_u8(0x6970) == 0xE9;
    ok &= zeliard_test_fight_u8(0x6971) == 0xCE;
    ok &= zeliard_test_fight_u8(0x6972) == 0x01;
    ok &= zeliard_test_fight_u8(0x6973) == 0x90;
    ok &= zeliard_test_fight_u8(0x6974) == 0x90;
    zeliard_debug_set_no_gravity(0);
    ok &= zeliard_test_fight_u8(0x6970) == 0xE8;

    zeliard_debug_set_invincible(1);
    ok &= zeliard_debug_invincible() == 1;
    ok &= zeliard_test_fight_u8(0x7685) == 0xC3;
    ok &= zeliard_test_game_u16(0x90) == zeliard_test_game_u16(0xB2);
    zeliard_debug_set_invincible(0);
    ok &= zeliard_test_fight_u8(0x7685) == 0x29;

    zeliard_test_game_set_u8(0x93, 1);
    zeliard_test_game_set_u8(0x90, 0x01);
    zeliard_test_game_set_u8(0x91, 0x00);
    zeliard_test_game_set_u8(0xB2, 0x78);
    zeliard_test_game_set_u8(0xB3, 0x56);
    zeliard_test_game_set_u8(0x94, 1);
    zeliard_test_game_set_u8(0x95, 0);
    zeliard_test_game_set_u8(0x96, 0x34);
    zeliard_test_game_set_u8(0x97, 0x12);
    zeliard_test_game_set_u8(0xAB, 1);
    zeliard_test_game_set_u8(0xB4, 23);
    zeliard_test_game_set_u8(0xBB, 1);
    zeliard_debug_restore_shield_magic();
    ok &= zeliard_test_game_u16(0x90) == 0x5678;
    ok &= zeliard_test_fight_u8(0x90) == 0x78;
    ok &= zeliard_test_fight_u8(0x91) == 0x56;
    ok &= zeliard_test_game_u16(0x94) == 0x1234;
    ok &= zeliard_test_game_u8(0xAB) == 23;
    ok &= zeliard_test_fight_u8(0xAB) == 23;

    for (unsigned slot = 0; slot < 5; ++slot)
        zeliard_test_game_set_u8(0xA6 + slot, 0);
    ok &= zeliard_debug_add_item(5) == 1;
    ok &= zeliard_test_game_u8(0xA6) == 5;
    ok &= zeliard_test_fight_u8(0xA6) == 5;
    ok &= zeliard_debug_add_item(8) == 1;
    ok &= zeliard_test_game_u8(0xA7) == 8;
    ok &= zeliard_debug_add_item(0) == 0;
    ok &= zeliard_debug_add_item(9) == 0;
    for (unsigned slot = 0; slot < 5; ++slot)
        zeliard_test_game_set_u8(0xA6 + slot, 1);
    ok &= zeliard_debug_add_item(2) == 0;

    for (unsigned slot = 0; slot < 5; ++slot)
        zeliard_test_game_set_u8(0xA6 + slot, 0);
    zeliard_key(13);
    zeliard_tick(90);
    ok &= zeliard_inventory_active();
    ok &= zeliard_debug_add_item(6) == 1;
    ok &= zeliard_inventory_active();
    ok &= zeliard_test_game_u8(0xA6) == 6;
    ok &= zeliard_test_fight_u8(0xA6) == 6;

    printf("debug_support: %s\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
