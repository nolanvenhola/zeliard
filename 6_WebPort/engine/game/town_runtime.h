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
    zeliard_town_event_t events[16];
    size_t event_count;
    u16 town_text_record;
    u8 map_side;
    u8 palette_index;
} zeliard_town_runtime_t;

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size);

#endif
