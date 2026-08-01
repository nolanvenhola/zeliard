#ifndef ZELIARD_GAME_LOADER_H
#define ZELIARD_GAME_LOADER_H

#include "../core/types.h"

typedef enum {
    ZELIARD_GAME_PALETTE_NOOP = 0,
    ZELIARD_GAME_PALETTE_EGA_ATTR = 1,
    ZELIARD_GAME_PALETTE_MCGA_DAC = 2,
} zeliard_game_palette_kind_t;

typedef enum {
    ZELIARD_GAME_BOOT_LOAD_CHUNK = 0,
    ZELIARD_GAME_BOOT_LOAD_ARCHIVE = 1,
    ZELIARD_GAME_BOOT_LOAD_LEVEL = 2,
} zeliard_game_bootstrap_call_kind_t;

typedef struct {
    u16 track_ref;
    u8 track_index;
    u8 background_flag;
} zeliard_game_music_track_load_t;

typedef struct {
    zeliard_game_music_track_load_t loads[9];
    size_t load_count;
} zeliard_game_music_plan_t;

typedef struct {
    u8 track_index;
    u16 track_ref;
    u8 background_flag;
} zeliard_game_music_trace_event_t;

typedef struct {
    u8 border;
    u8 regs[16];
} zeliard_game_ega_palette_t;

typedef struct {
    u8 index;
    u8 r;
    u8 g;
    u8 b;
} zeliard_game_mcga_dac_write_t;

typedef struct {
    zeliard_game_palette_kind_t kind;
    zeliard_game_ega_palette_t ega;
    zeliard_game_mcga_dac_write_t mcga[64];
    size_t mcga_count;
} zeliard_game_palette_plan_t;

typedef enum {
    ZELIARD_GAME_PALETTE_TRACE_EGA_ATTR = 0,
    ZELIARD_GAME_PALETTE_TRACE_MCGA_DAC = 1,
} zeliard_game_palette_trace_kind_t;

typedef struct {
    zeliard_game_palette_trace_kind_t kind;
    u16 interrupt_no;
    u16 ax;
    u16 bx;
    u16 cx;
    u16 dx;
    u16 es_delta;
    u8 ega_border;
    u8 ega_regs[16];
    u8 dac_index;
    u8 r;
    u8 g;
    u8 b;
} zeliard_game_palette_trace_event_t;

typedef struct {
    bool load_saved_game;
    u8 gfx_mode;
    u8 sword;
    u8 shield;
    u8 selected_spell;
    u8 music_track_count;
    u8 current_area_id;
    u8 level_music_source;
    u8 town_sprite_source;
} zeliard_game_bootstrap_input_t;

typedef struct {
    u8 current_area_id;
    u8 level_music_source;
    u8 town_sprite_source;
} zeliard_game_level_load_input_t;

typedef struct {
    zeliard_game_bootstrap_call_kind_t kind;
    u16 es_delta;
    u16 dest_offset;
    u16 ref_offset;
    u8 al;
    u8 ah;
    const char *name;
} zeliard_game_bootstrap_call_t;

typedef struct {
    zeliard_game_bootstrap_call_kind_t kind;
    u16 es_delta;
    u16 dest_offset;
    u16 ref_offset;
    u8 al;
    u8 ah;
    const char *name;
} zeliard_game_bootstrap_trace_event_t;

typedef struct {
    zeliard_game_bootstrap_call_kind_t kind;
    u16 es_delta;
    u16 dest_offset;
    u16 ref_offset;
    u8 al;
    u8 ah;
    const char *name;
} zeliard_game_level_load_trace_event_t;

typedef enum {
    ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE = 0,
    ZELIARD_GAME_BOOT_EFFECT_RELOCATION = 1,
    ZELIARD_GAME_BOOT_EFFECT_MUSIC_LOAD = 2,
    ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL = 3,
    ZELIARD_GAME_BOOT_EFFECT_GAME_INIT_CALL = 4,
    ZELIARD_GAME_BOOT_EFFECT_BRANCH = 5,
} zeliard_game_bootstrap_effect_kind_t;

typedef enum {
    ZELIARD_GAME_BOOT_BRANCH_OPDEMO = 0,
    ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP = 1,
} zeliard_game_bootstrap_branch_target_t;

typedef struct {
    u8 slot;
    u8 al;
    u16 bx;
} zeliard_game_bootstrap_driver_call_t;

typedef struct {
    u16 offset;
    u8 value;
} zeliard_game_bootstrap_state_write_t;

typedef struct {
    u16 es_delta;
    u16 offset;
    u8 word_count;
    u16 addend;
} zeliard_game_bootstrap_relocation_t;

typedef struct {
    zeliard_game_bootstrap_effect_kind_t kind;
    u16 offset;
    u8 value;
    u16 es_delta;
    u8 word_count;
    u16 addend;
    u8 track_index;
    u16 track_ref;
    u8 background_flag;
    u8 driver_slot;
    u8 al;
    u16 bx;
    u16 segment;
    zeliard_game_bootstrap_branch_target_t branch_target;
} zeliard_game_bootstrap_effect_event_t;

typedef struct {
    zeliard_game_bootstrap_call_t calls[15];
    size_t call_count;
    zeliard_game_bootstrap_state_write_t state_clears[16];
    size_t state_clear_count;
    zeliard_game_bootstrap_relocation_t relocations[3];
    size_t relocation_count;
    zeliard_game_music_plan_t music_plan;
    zeliard_game_bootstrap_driver_call_t driver_calls[3];
    size_t driver_call_count;
    u16 game_init_fn_segment;
    bool jumps_to_opdemo;
    bool jumps_to_game_loop;
    u8 cinematic_active;
    u8 current_level_idx;
} zeliard_game_bootstrap_plan_t;

enum {
    ZELIARD_GAME_SEGMENT_SIZE = 0x10000,
    ZELIARD_GAME_SEGMENT_COUNT = 4,
    ZELIARD_GAME_EXEC_EVENT_CAP = 64,
};

typedef enum {
    ZELIARD_GAME_EXEC_LOAD = 0,
    ZELIARD_GAME_EXEC_STATE_WRITE,
    ZELIARD_GAME_EXEC_RELOCATION,
    ZELIARD_GAME_EXEC_GFX_INIT,
    ZELIARD_GAME_EXEC_PALETTE,
    ZELIARD_GAME_EXEC_GAME_INIT,
    ZELIARD_GAME_EXEC_MUSIC_LOAD,
    ZELIARD_GAME_EXEC_DRIVER_CALL,
    ZELIARD_GAME_EXEC_BRANCH,
} zeliard_game_exec_event_kind_t;

typedef struct {
    zeliard_game_exec_event_kind_t kind;
    zeliard_game_bootstrap_call_t call;
    zeliard_game_bootstrap_effect_event_t effect;
} zeliard_game_exec_event_t;

/* CS is segment[0]; the other pointers model CS+1000h, CS+2000h and
 * CS+3000h. They are separate 64 KiB 8086 segments, not flattened offsets. */
typedef struct {
    u8 *segment[ZELIARD_GAME_SEGMENT_COUNT];
    size_t segment_size[ZELIARD_GAME_SEGMENT_COUNT];
    zeliard_game_exec_event_t events[ZELIARD_GAME_EXEC_EVENT_CAP];
    size_t event_count;
    zeliard_game_bootstrap_branch_target_t branch_target;
    bool branched;
} zeliard_game_exec_state_t;

typedef bool (*zeliard_game_asset_fetch_fn)(void *context, const char *name,
                                            u8 **data, size_t *size);
typedef bool (*zeliard_game_loader_service_fn)(
    void *context, const zeliard_game_bootstrap_call_t *call,
    zeliard_game_exec_state_t *state);

typedef struct {
    void *context;
    zeliard_game_asset_fetch_fn fetch_asset;
    zeliard_game_loader_service_fn loader_service;
} zeliard_game_exec_services_t;

bool zeliard_game_resolve_music_plan(zeliard_game_music_plan_t *plan,
                                     u8 music_track_count);
size_t zeliard_game_resolve_music_trace(zeliard_game_music_trace_event_t *out,
                                        size_t max_events,
                                        u8 music_track_count);
bool zeliard_game_resolve_palette_plan(zeliard_game_palette_plan_t *plan,
                                       u8 gfx_mode);
size_t zeliard_game_resolve_palette_trace(zeliard_game_palette_trace_event_t *out,
                                          size_t max_events,
                                          u8 gfx_mode);
size_t zeliard_game_resolve_level_load_trace(
    zeliard_game_level_load_trace_event_t *out,
    size_t max_events,
    const zeliard_game_level_load_input_t *input);
size_t zeliard_game_resolve_bootstrap_trace(zeliard_game_bootstrap_trace_event_t *out,
                                            size_t max_events,
                                            const zeliard_game_bootstrap_input_t *input);
size_t zeliard_game_resolve_bootstrap_effect_trace(
    zeliard_game_bootstrap_effect_event_t *out,
    size_t max_events,
    const zeliard_game_bootstrap_input_t *input);
bool zeliard_game_resolve_bootstrap_plan(zeliard_game_bootstrap_plan_t *plan,
                                         const zeliard_game_bootstrap_input_t *input);
bool zeliard_game_execute_bootstrap(zeliard_game_exec_state_t *state,
                                    const zeliard_game_bootstrap_input_t *input,
                                    const zeliard_game_exec_services_t *services);

#endif
