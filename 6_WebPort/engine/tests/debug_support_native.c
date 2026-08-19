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
int zeliard_test_restart_town(int area);
int zeliard_test_restart_fight(int selector, int start_position,
                               int map_scroll_row, int screen_position);
int zeliard_test_enter_room(int kind);
int zeliard_test_king_script(void);
int zeliard_room_kind(void);
int zeliard_ending_active(void);
int zeliard_music_track(void);
int zeliard_music_attenuation(void);
int zeliard_debug_invincible(void);
void zeliard_debug_set_invincible(int enabled);
int zeliard_debug_unlimited_magic(void);
void zeliard_debug_set_unlimited_magic(int enabled);
int zeliard_debug_no_gravity(void);
void zeliard_debug_set_no_gravity(int enabled);
int zeliard_debug_kill_boss(void);
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

    zeliard_test_game_set_u8(0xAB, 1);
    zeliard_debug_set_unlimited_magic(1);
    ok &= zeliard_debug_unlimited_magic() == 1;
    ok &= zeliard_test_game_u8(0xAB) == 23;
    ok &= zeliard_test_fight_u8(0xAB) == 23;
    zeliard_test_game_set_u8(0xAB, 0);
    zeliard_tick(20);
    ok &= zeliard_test_game_u8(0xAB) == 23;
    ok &= zeliard_test_fight_u8(0xAB) == 23;
    zeliard_debug_set_unlimited_magic(0);
    ok &= zeliard_debug_unlimited_magic() == 0;

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

    /* Final and Falter both use MASM level 8 / mus8.msd. Reproduce the
     * checkpoint path through a town and prove the shared chunk cache does
     * not suppress Final's score after the town driver replaced it. */
    const int falter_started =
        zeliard_test_restart_fight(0x1A, 0, 0, 0x08);
    const int falter_music = zeliard_music_track();
    const int town_restarted = zeliard_test_restart_town(0);
    const int town_music = zeliard_music_track();
    const int final_started =
        zeliard_test_restart_fight(0x1B, 0, 1, 0x00);
    const int final_music = zeliard_music_track();
    const int final_music_ok = falter_started && falter_music == 16 &&
        town_restarted && town_music != 16 && final_started &&
        final_music == 16;
    ok &= final_music_ok;
    printf("debug_support:final_music_restart: %s tracks=%d/%d/%d\n",
           final_music_ok ? "PASS" : "FAIL", falter_music, town_music,
           final_music);

    /* MP90's dialogue entry fades MUS8 using MASM's FF24h=0Ah interval;
     * the MPA0 fight that follows uses the separate MMAO score. */
    const int jashiin_started =
        zeliard_test_restart_fight(0x1D, 0, 0, 0x00);
    const int jashiin_entry_music = zeliard_music_track();
    int jashiin_fade_peak = zeliard_music_attenuation();
    for (unsigned frame = 0; frame < 500 &&
            zeliard_music_track() != 17; ++frame) {
        zeliard_tick(20);
        if (zeliard_music_attenuation() > jashiin_fade_peak)
            jashiin_fade_peak = zeliard_music_attenuation();
    }
    const int jashiin_music_ok = jashiin_started &&
        jashiin_entry_music == 16 && jashiin_fade_peak == 64 &&
        zeliard_music_track() == 17;
    ok &= jashiin_music_ok;
    printf("debug_support:jashiin_music_handoff: %s tracks=%d/%d fade=%d\n",
           jashiin_music_ok ? "PASS" : "FAIL", jashiin_entry_music,
           zeliard_music_track(), jashiin_fade_peak);
    const int jashiin_killed = zeliard_debug_kill_boss();
    const int kill_boss_ok = jashiin_killed &&
        zeliard_test_fight_u8(0xAC06) == 0 &&
        zeliard_test_fight_u8(0xAC07) == 0 &&
        zeliard_test_fight_u8(0xAC20) == 0;
    ok &= kill_boss_ok;
    printf("debug_support:kill_jashiin: %s\n",
           kill_boss_ok ? "PASS" : "FAIL");

    /* The post-Jashiin route remains interactive after the outdoor guard:
     * Duke walks into the King's chamber, where 210KINGP selects A6C1h and
     * directs him to Felicia.  The princess hut's 211OMOYP alternate entry
     * is the later, sole 250ENDMO trigger. */
    ok &= zeliard_test_restart_town(0);
    ok &= zeliard_test_game_set_u8(0x05, 0xFF) == 0;
    /* Reproduce an early-web checkpoint: final victory survived, but the
     * older byte-06h prerequisite did not. The King must still recover to
     * the authored post-Jashiin script instead of A53Ch. */
    ok &= zeliard_test_game_set_u8(0x06, 0x00) == 0;
    ok &= zeliard_test_game_set_u8(0x49, 0xFF) == 0;
    /* A restored post-victory record must recreate the same transient gate. */
    ok &= zeliard_test_restart_town(0);
    const int king_script = zeliard_test_king_script();
    ok &= king_script == 0xA6C1;
    const int princess_blocked_before_king =
        zeliard_test_enter_room(3) == -2;
    ok &= princess_blocked_before_king;
    ok &= zeliard_test_enter_room(1) == 0;
    int saw_king_room = 0;
    for (unsigned frame = 0; frame < 5000; ++frame) {
        zeliard_key(32);
        zeliard_tick(90);
        if (zeliard_room_kind() == 1) saw_king_room = 1;
        if (saw_king_room && zeliard_room_kind() == 0) break;
    }
    const int king_room_ok = princess_blocked_before_king && saw_king_room &&
        zeliard_room_kind() == 0 && !zeliard_ending_active();
    ok &= king_room_ok;
    printf("debug_support:post_victory_king: %s script=%04x blocked=%d room=%d ending=%d\n",
           king_room_ok ? "PASS" : "FAIL", king_script,
           princess_blocked_before_king, zeliard_room_kind(),
           zeliard_ending_active());

    /* The completed speech unlocks the following player-entered hut. */
    ok &= zeliard_test_enter_room(3) == 0;
    /* 211OMOYP preserves the stone-Princess frame for 012Ch raw PIT ticks
     * before its GDMCGA/end-demo handoff. */
    ok &= !zeliard_ending_active();
    for (unsigned frame = 0; frame < 100 && !zeliard_ending_active(); ++frame)
        zeliard_tick(90);
    ok &= zeliard_ending_active();
    printf("debug_support:princess_hut_handoff: %s room=%d ending=%d\n",
           zeliard_ending_active() ? "PASS" : "FAIL",
           zeliard_room_kind(), zeliard_ending_active());

    printf("debug_support: %s\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
