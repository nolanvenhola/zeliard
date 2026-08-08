#ifndef ZELIARD_TOWN_DIALOG_H
#define ZELIARD_TOWN_DIALOG_H

#include "../core/types.h"

typedef struct {
    u8 active;
    u8 waiting;
    u8 page_wait;
    u8 final_wait;
    u8 pending_sound_cue;
    u8 scroll_active;
    u8 scroll_resume_pending;
    u8 scroll_pass;
    u8 scroll_wait_ticks;
    u8 prompt_active;
    u8 prompt_kind;
    u8 prompt_selection;
    u8 prompt_direction_latch;
    u8 control_wait_dialog;
    u8 original_npc_direction;
    u8 original_npc_type;
    u16 npc_offset;
    u16 panel_ax;
    u16 panel_cx;
    u16 glyph_count;
    u16 scroll_count;
    u16 scroll_step_count;
    u16 scroll_packed;
    u16 scroll_layout;
    u16 prompt_position;
} zeliard_town_dialog_t;

int zeliard_town_dialog_begin(zeliard_town_dialog_t *dialog,
                              u8 *game_seg, u8 *scratch,
                              u8 *vga, size_t vga_size, u16 npc_position);
int zeliard_town_dialog_begin_live(zeliard_town_dialog_t *dialog,
                                   u8 *game_seg, u8 *scratch,
                                   u8 *tile_data, size_t tile_data_size,
                                   const u8 *mask_data, size_t mask_data_size,
                                   u8 *vga, size_t vga_size,
                                   u16 npc_position);
int zeliard_town_dialog_begin_facing(zeliard_town_dialog_t *dialog,
                                     u8 *cs, u8 *scratch,
                                     u8 *tile_data, size_t tile_data_size,
                                     const u8 *mask_data,
                                     size_t mask_data_size,
                                     u8 *vga, size_t vga_size,
                                     u16 npc_position);
int zeliard_town_dialog_continue(zeliard_town_dialog_t *dialog,
                                 u8 *game_seg, const u8 *scratch,
                                 u8 *vga, size_t vga_size);
int zeliard_town_dialog_advance_pit(zeliard_town_dialog_t *dialog,
                                    u8 *game_seg,
                                    u8 *vga, size_t vga_size);

#endif
