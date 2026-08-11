#ifndef ZELIARD_TOWN_RUNTIME_H
#define ZELIARD_TOWN_RUNTIME_H

#include "../core/types.h"
#include "../load/game_loader.h"
#include "town_dialog.h"
#include "room_runtime.h"

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
    ZEL_TOWN_EVENT_LOAD_CKPD,
    ZEL_TOWN_EVENT_RUN_209CKPD,
    ZEL_TOWN_EVENT_DRAW_FIRST_HUD,
    ZEL_TOWN_EVENT_DRAW_ACTORS,
    ZEL_TOWN_EVENT_UPDATE_FRAME,
    ZEL_TOWN_EVENT_PROCESS_EVENTS,
    ZEL_TOWN_EVENT_TICK_NPCS,
    ZEL_TOWN_EVENT_MOVE_PLAYER,
    ZEL_TOWN_EVENT_SCROLL_VIEW,
    ZEL_TOWN_EVENT_LOAD_AREA,
    ZEL_TOWN_EVENT_LOAD_PATTERN,
} zeliard_town_event_kind_t;

typedef enum {
    ZEL_TOWN_AREA_FELISHIKA = 0,
    ZEL_TOWN_AREA_MURALLA = 1,
    ZEL_TOWN_AREA_SATONO = 2,
    ZEL_TOWN_AREA_BOSQUE = 3,
    ZEL_TOWN_AREA_HELADA = 4,
    ZEL_TOWN_AREA_TUMBA = 5,
    ZEL_TOWN_AREA_DORADO = 6,
    ZEL_TOWN_AREA_LLAMA = 7,
    ZEL_TOWN_AREA_PUREZA = 8,
    ZEL_TOWN_AREA_ESCO = 9,
} zeliard_town_area_t;

typedef struct {
    zeliard_town_event_kind_t kind;
    const char *source;
    const char *asset;
    u16 segment_delta;
    u16 offset;
    u8 al;
} zeliard_town_event_t;

typedef enum {
    ZEL_TOWN_BUILDING_TRANSITION_NONE = 0,
    ZEL_TOWN_BUILDING_TRANSITION_ENTER,
    ZEL_TOWN_BUILDING_TRANSITION_LEAVE,
    ZEL_TOWN_BUILDING_TRANSITION_SPECIAL,
} zeliard_town_building_transition_t;

typedef struct {
    zeliard_town_event_t events[32];
    size_t event_count;
    u16 town_text_record;
    u8 map_side;
    u8 palette_index;
    u8 music_index;
    zeliard_town_area_t area;
    u32 frame_count;
    u16 facing_item_position;
    u16 facing_npc_position;
    u8 facing_door_type;
    u8 facing_door_found;
    u8 cavern_exit_requested;
    u8 special_door_pending;
    zeliard_town_building_transition_t building_transition;
    zeliard_room_kind_t pending_room_kind;
    u8 building_transition_pass;
    u8 building_transition_ticks;
    zeliard_town_dialog_t dialog;
    zeliard_room_runtime_t room;
} zeliard_town_runtime_t;

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size);

/* game.asm saved-game bootstrap enters a freshly loaded 106TOWN overlay.
 * Its init_entry sets town_init_flag, suppressing the side-door walk. */
int zeliard_town_enter_saved_first_frame(zeliard_town_runtime_t *town,
                                         zeliard_game_exec_state_t *game,
                                         u8 *vga, size_t vga_size);

/* 200FIGHT:next_level_start + level_start town-coordinate handoff. */
int zeliard_town_prepare_level_start(u8 *game_seg, size_t game_size,
                                     u8 area_id);

/* 200FIGHT town return after reverse transition and level_start's final
 * compute_scroll_offset_b viewport conversion. */
int zeliard_town_prepare_cavern_door_return(
    u8 *game_seg, size_t game_size, u8 area_id,
    u16 scroll_count, u8 scroll_dir, u8 player_y);

int zeliard_town_area_supported(u8 area_id);

int zeliard_town_begin_room_transition(zeliard_town_runtime_t *town,
                                       zeliard_room_kind_t kind,
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
