#ifndef ZELIARD_PLAYER_STATE_H
#define ZELIARD_PLAYER_STATE_H

#include "types.h"

#include <stddef.h>

enum {
    ZEL_PLAYER_RECORD_SIZE = 0x0100,

    /* 210KINGP:select_script_branch persistent bytes. */
    ZEL_PLAYER_KING_DIALOG_DONE = 0x0005,
    ZEL_PLAYER_KING_DIALOG_DONE_B = 0x0006,
    ZEL_PLAYER_AREA_LOAD_FLAG = 0x0049,

    ZEL_PLAYER_START_POSITION = 0x0080,
    ZEL_PLAYER_MAP_SCROLL_ROW = 0x0082,
    ZEL_PLAYER_SCREEN_POSITION = 0x0083,
    ZEL_PLAYER_FIGHT_COLUMN = 0x0084,
    ZEL_PLAYER_GOLD = 0x0085,
    ZEL_PLAYER_BANK_GOLD = 0x0088,
    ZEL_PLAYER_ALMAS = 0x008B,
    ZEL_PLAYER_HERO_LEVEL = 0x008D,
    ZEL_PLAYER_EXPERIENCE = 0x008E,
    ZEL_PLAYER_HP = 0x0090,
    ZEL_PLAYER_SWORD = 0x0092,
    ZEL_PLAYER_SHIELD = 0x0093,
    ZEL_PLAYER_SHIELD_HP = 0x0094,
    ZEL_PLAYER_SHIELD_HP_MAX = 0x0096,
    ZEL_PLAYER_KEYS_NORMAL = 0x0098,
    ZEL_PLAYER_KEYS_LION = 0x0099,
    ZEL_PLAYER_SELECTED_SPELL = 0x009D,
    ZEL_PLAYER_SELECTED_ACCESSORY = 0x009E,
    ZEL_PLAYER_FRAME_SCRATCH = 0x009F,
    ZEL_PLAYER_TEARS = 0x00A0,
    ZEL_PLAYER_ACCESSORY_SLOTS = 0x00A1,
    ZEL_PLAYER_ITEM_SLOTS = 0x00A6,
    ZEL_PLAYER_SPELL_CHARGES = 0x00AB,
    ZEL_PLAYER_HP_MAX = 0x00B2,
    ZEL_PLAYER_SPELL_CHARGES_MAX = 0x00B4,
    ZEL_PLAYER_SPELL_KNOWN = 0x00BB,
    ZEL_PLAYER_FACING_DIRECTION = 0x00C2,
    ZEL_PLAYER_BOSS_INTRO_FLAG = 0x00C3,
    ZEL_PLAYER_SAVE_SAGE = 0x00C4,
    ZEL_PLAYER_LAST_SAGE = 0x00C5,
    ZEL_PLAYER_HEAL_PULSE_COUNT = 0x00C6,
    ZEL_PLAYER_CURRENT_LEVEL = 0x00C8,
    ZEL_PLAYER_MAGIC_SHOP_INVENTORY = 0x00C9,
    ZEL_PLAYER_SWORD_SHOP_INVENTORY = 0x00D2,
    ZEL_PLAYER_SHIELD_SHOP_INVENTORY = 0x00DB,
    ZEL_PLAYER_KEY_COUNT = 0x00E4,
    ZEL_PLAYER_SAGES_SPOKEN = 0x00E5,
    ZEL_PLAYER_SCENE_TRANSITION = 0x00E6,
    ZEL_PLAYER_POSE = 0x00E7,
    ZEL_PLAYER_INIT_COMPLETE = 0x00E8,
};

/* A view over the canonical 256 bytes at game_seg:0000h. */
typedef struct {
    u8 *bytes;
} zeliard_player_state_t;

bool zeliard_player_state_bind(zeliard_player_state_t *state,
                               u8 *game_seg, size_t game_seg_size);
u8 zeliard_player_read_u8(const zeliard_player_state_t *state, u16 offset);
u16 zeliard_player_read_u16(const zeliard_player_state_t *state, u16 offset);
u32 zeliard_player_read_u24(const zeliard_player_state_t *state, u16 offset);
void zeliard_player_write_u8(zeliard_player_state_t *state, u16 offset, u8 value);
void zeliard_player_write_u16(zeliard_player_state_t *state, u16 offset, u16 value);
void zeliard_player_write_u24(zeliard_player_state_t *state, u16 offset, u32 value);
bool zeliard_player_snapshot(const zeliard_player_state_t *state,
                             u8 out[ZEL_PLAYER_RECORD_SIZE]);
bool zeliard_player_import(zeliard_player_state_t *state,
                           const u8 record[ZEL_PLAYER_RECORD_SIZE]);

#endif
