#ifndef ZELIARD_TOWN_RUNTIME_H
#define ZELIARD_TOWN_RUNTIME_H

#include "../core/types.h"
#include "../load/game_loader.h"

typedef enum {
    ZEL_TOWN_EVENT_LOAD_CMAP = 0,
    ZEL_TOWN_EVENT_PREPROCESS_MMAN,
    ZEL_TOWN_EVENT_PREPROCESS_TMAN,
    ZEL_TOWN_EVENT_LOAD_CPAT,
    ZEL_TOWN_EVENT_RUN_207MOLE,
    ZEL_TOWN_EVENT_CLEAR_PLAYFIELD,
    ZEL_TOWN_EVENT_CAPTURE_PLAYFIELD,
    ZEL_TOWN_EVENT_LOAD_YMPD,
    ZEL_TOWN_EVENT_RUN_208YMPD,
    ZEL_TOWN_EVENT_DRAW_FIRST_HUD,
    ZEL_TOWN_EVENT_DRAW_ACTORS,
    ZEL_TOWN_EVENT_UPDATE_FRAME,
    ZEL_TOWN_EVENT_PROCESS_EVENTS,
    ZEL_TOWN_EVENT_TICK_NPCS,
    ZEL_TOWN_EVENT_MOVE_PLAYER,
    ZEL_TOWN_EVENT_SCROLL_VIEW,
} zeliard_town_event_kind_t;

typedef struct {
    zeliard_town_event_kind_t kind;
    const char *source;
    const char *asset;
    u16 segment_delta;
    u16 offset;
    u8 al;
} zeliard_town_event_t;

typedef struct {
    zeliard_town_event_t events[32];
    size_t event_count;
    u16 town_text_record;
    u8 map_side;
    u8 palette_index;
    u32 frame_count;
    u16 facing_item_position;
    u16 facing_npc_position;
    u8 facing_door_type;
} zeliard_town_runtime_t;

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size);

/* Advance the 106TOWN loop by raw stick.asm PIT ticks (236.7 Hz). */
int zeliard_town_advance_pit(zeliard_town_runtime_t *town,
                             zeliard_game_exec_state_t *game,
                             u8 *vga, size_t vga_size,
                             u32 pit_ticks, u8 input_direction);

/* 106TOWN try_take_facing_item/try_talk.../door_scan target scan only. */
void zeliard_town_detect_facing_targets(zeliard_town_runtime_t *town,
                                        u8 *game_seg, u8 input_direction);

/* 106TOWN:tick_npcs_dispatch, including restore and stamp passes. */
void zeliard_town_tick_npcs(u8 *game_seg);

#endif
