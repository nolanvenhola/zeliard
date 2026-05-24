#ifndef ZELIARD_LOADER_H
#define ZELIARD_LOADER_H

#include "../core/types.h"

enum {
    ZELIARD_ZELIAD_CALLBACK_OFS = 0x02D9,
    ZELIARD_STICK_INPUT_FN_OFS = 0x0100,
    ZELIARD_STDPLY_GFX_FN_OFS = 0x1100
};

typedef struct {
    u16 zeliad_code_seg;
    u16 game_entry_seg;
    u16 old_int08_ofs;
    u16 old_int08_seg;
    u16 old_int09_ofs;
    u16 old_int09_seg;
    u8 graphics_mode;
    u8 mt32_enabled;
    u8 joystick_enabled;
    const char *cmdline_savefile;
} zeliard_loader_init_input_t;

typedef struct {
    u16 chunk_load_fn;
    u16 chunk_load_seg;
    u16 old_int08_ofs;
    u16 old_int08_seg;
    u8 timer_ticks;
    u8 key_released;
    u8 last_key;
    u8 key_state;
    u16 input_fn_ofs;
    u16 input_fn_seg;
    u16 gfx_fn_ofs;
    u16 gfx_fn_seg;
    u8 gfx_mode;
    u8 game_phase;
    u8 skip_flag;
    u8 timer_flag;
    u16 timer_counter;
    u8 state_a;
    u8 state_b;
    u16 state_c;
    u8 enable_all;
    u8 sound_flag;
    u8 key_pressed;
    u16 game_seg;
    u8 save_flag;
    u8 save_flag_next;
    u8 flag_shield;
    u8 flag_climbing;
    u8 flag_riding;
    u8 music_flag_d;
    u8 palette_flag;
    u8 debug_mode;
    u8 debug_val;
    u8 scroll_active;
    u8 save_name_buf[8];
    u8 input_lock;
    u8 volume_b;
    u8 disk_swap_suppressed;
    u16 old_int09_ofs;
    u16 old_int09_seg;
} zeliard_game_globals_t;

typedef struct {
    u16 game_entry_seg;
    u8 graphics_mode;
    const char *save_filename;
    const char *music_driver_name;
    const char *joystick_driver_name;
} zeliard_loader_plan_input_t;

typedef struct {
    u16 segment;
    u16 descriptor_offset;
    u16 offset;
    const char *filename;
} zeliard_loader_file_entry_t;

typedef struct {
    zeliard_loader_file_entry_t files[6];
    size_t file_count;
} zeliard_loader_plan_t;

typedef enum {
    ZELIARD_VIDEO_MODE_INT10,
    ZELIARD_VIDEO_MODE_HGC,
    ZELIARD_VIDEO_MODE_INVALID
} zeliard_video_mode_kind_t;

typedef struct {
    zeliard_video_mode_kind_t kind;
    u16 int10_ax;
    u16 hgc_clear_segment;
    u16 hgc_clear_words;
} zeliard_video_mode_plan_t;

typedef enum {
    ZELIARD_LOADER_TRACE_LOAD_FILE,
} zeliard_loader_trace_kind_t;

typedef struct {
    zeliard_loader_trace_kind_t kind;
    u16 es;
    u16 di;
    u16 load_offset;
    const char *filename;
} zeliard_loader_trace_event_t;

bool zeliard_parse_startup_save_arg(const char *command_tail, size_t tail_len,
                                    char *save_filename, size_t save_filename_cap);
void zeliard_init_game_globals(zeliard_game_globals_t *globals,
                               const zeliard_loader_init_input_t *input);
size_t zeliard_resolve_loader_trace(zeliard_loader_trace_event_t *out,
                                    size_t max_events,
                                    const zeliard_loader_plan_input_t *input);
bool zeliard_resolve_loader_plan(zeliard_loader_plan_t *plan,
                                 const zeliard_loader_plan_input_t *input);
zeliard_video_mode_plan_t zeliard_resolve_video_mode_plan(u8 graphics_mode);

#endif
