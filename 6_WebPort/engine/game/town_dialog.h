#ifndef ZELIARD_TOWN_DIALOG_H
#define ZELIARD_TOWN_DIALOG_H

#include "../core/types.h"

typedef struct {
    u8 active;
    u8 waiting;
    u8 pending_sound_cue;
    u8 original_npc_direction;
    u8 original_npc_type;
    u16 npc_offset;
    u16 panel_ax;
    u16 panel_cx;
    u16 glyph_count;
} zeliard_town_dialog_t;

int zeliard_town_dialog_begin(zeliard_town_dialog_t *dialog,
                              u8 *game_seg, u8 *scratch,
                              u8 *vga, size_t vga_size, u16 npc_position);
int zeliard_town_dialog_continue(zeliard_town_dialog_t *dialog,
                                 u8 *game_seg, const u8 *scratch,
                                 u8 *vga, size_t vga_size);

#endif
