#include "player_state.h"

#include <string.h>

static bool valid_offset(const zeliard_player_state_t *state,
                         u16 offset, u16 width) {
    return state && state->bytes &&
           (u32)offset + (u32)width <= ZEL_PLAYER_RECORD_SIZE;
}

bool zeliard_player_state_bind(zeliard_player_state_t *state,
                               u8 *game_seg, size_t game_seg_size) {
    if (!state) return false;
    state->bytes = NULL;
    if (!game_seg || game_seg_size < ZEL_PLAYER_RECORD_SIZE)
        return false;
    state->bytes = game_seg;
    return true;
}

u8 zeliard_player_read_u8(const zeliard_player_state_t *state, u16 offset) {
    return valid_offset(state, offset, 1) ? state->bytes[offset] : 0;
}

u16 zeliard_player_read_u16(const zeliard_player_state_t *state, u16 offset) {
    if (!valid_offset(state, offset, 2)) return 0;
    return (u16)(state->bytes[offset] |
                 ((u16)state->bytes[(u16)(offset + 1)] << 8));
}

u32 zeliard_player_read_u24(const zeliard_player_state_t *state, u16 offset) {
    if (!valid_offset(state, offset, 3)) return 0;
    /* MASM stores the high byte first, followed by a little-endian low word. */
    return ((u32)state->bytes[offset] << 16) |
           zeliard_player_read_u16(state, (u16)(offset + 1));
}

void zeliard_player_write_u8(zeliard_player_state_t *state, u16 offset, u8 value) {
    if (valid_offset(state, offset, 1)) state->bytes[offset] = value;
}

void zeliard_player_write_u16(zeliard_player_state_t *state, u16 offset, u16 value) {
    if (!valid_offset(state, offset, 2)) return;
    state->bytes[offset] = (u8)value;
    state->bytes[(u16)(offset + 1)] = (u8)(value >> 8);
}

void zeliard_player_write_u24(zeliard_player_state_t *state, u16 offset, u32 value) {
    if (!valid_offset(state, offset, 3)) return;
    value &= 0xFFFFFFu;
    state->bytes[offset] = (u8)(value >> 16);
    zeliard_player_write_u16(state, (u16)(offset + 1), (u16)value);
}

bool zeliard_player_snapshot(const zeliard_player_state_t *state,
                             u8 out[ZEL_PLAYER_RECORD_SIZE]) {
    if (!valid_offset(state, 0, ZEL_PLAYER_RECORD_SIZE) || !out) return false;
    memcpy(out, state->bytes, ZEL_PLAYER_RECORD_SIZE);
    return true;
}

bool zeliard_player_import(zeliard_player_state_t *state,
                           const u8 record[ZEL_PLAYER_RECORD_SIZE]) {
    if (!valid_offset(state, 0, ZEL_PLAYER_RECORD_SIZE) || !record) return false;
    memcpy(state->bytes, record, ZEL_PLAYER_RECORD_SIZE);
    return true;
}
