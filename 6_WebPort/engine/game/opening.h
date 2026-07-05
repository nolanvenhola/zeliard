#ifndef ZELIARD_OPENING_H
#define ZELIARD_OPENING_H

#include "../core/types.h"
#include <stddef.h>

/* Opening cinematic state machine derived from run_opening_demo_main.
 * MASM oracle contracts define the phase order and input-routing behavior.
 */

void opening_init(void);     /* pre-decode all opening images */
void opening_tick(u32 dt_ms); /* advance timer, blit current scene */
int  opening_done(void);     /* returns 1 when all scenes complete */
void opening_skip(void);     /* immediately advance past remaining scenes */
void opening_key_advance(void); /* MASM SPACE/ENTER phase-sensitive advance */
int  opening_phase_id(void); /* native parity/debug: current opening phase enum */
u32  opening_phase_elapsed_ms(void); /* native parity/debug: current phase elapsed */
u32  opening_nec_hou_sprite_debug_word(void); /* debug: frame | elapsed | band count */
u32  opening_nec_hou_sprite_debug_slots(void); /* debug: eight 4-bit signed slots, -1 as F */
void opening_set_phase_for_test(int phase); /* native parity/debug hook */
void opening_render_phase_for_test(int phase, u32 elapsed_ms); /* render exact phase-local time */
void opening_set_yuu_plane_variant_for_test(int variant); /* native parity/debug hook */
void opening_set_dmaou_apparition_mode_for_test(int mode); /* native parity/debug hook */
void opening_render_cached_scene_for_test(int scene_idx); /* native parity/debug hook */

typedef enum {
    OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_00 = 0,
    OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_12 = 1,
    OPENING_DEBUG_LATE_SPLIT_RETURN_STEP_12 = 2,
    OPENING_DEBUG_LATE_FINAL_YUU3_YUU4 = 3,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_96 = 4,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_192 = 5,
    OPENING_DEBUG_LATE_WAKU_AME_AX9 = 6,
    OPENING_DEBUG_LATE_WAKU_HIME_AX9 = 7,
    OPENING_DEBUG_LATE_WAKU_HIME_AX6 = 8,
    OPENING_DEBUG_LATE_WAKU_ISI_AX7 = 9,
    OPENING_DEBUG_LATE_MAOP_SCRIPT_AREA = 10,
} opening_debug_late_frame_t;

void opening_debug_render_late_frame(opening_debug_late_frame_t frame);

typedef struct {
    u8  display_al;  /* scene byte minus one, passed to disp_narr_chap2 */
    u16 bx;          /* destination/control word used by the asm caller */
    u8  delay;       /* timer_wait_loop AL value after each frame */
} opening_sprite_event_t;

typedef struct {
    u8 x;
    u8 y;
    i8 vx;
    i8 vy;
    u8 first_frame;
    u8 last_frame;
} opening_sprite_a_record_t;

typedef struct {
    size_t record_count;
    size_t source_bytes_consumed;
    size_t frame_count;
    u8 frame_wait_al;
    u16 dispatch_slot;
    u16 dispatch_target;
    opening_sprite_a_record_t records[9];
} opening_sprite_a_summary_t;

typedef struct {
    u16 frame_ptr;
    u16 cx;
} opening_sprite_a_frame_table_entry_t;

typedef struct {
    u8 active;
    u8 x;
    u8 y;
    u8 frame;
} opening_sprite_a_object_state_t;

typedef struct {
    size_t frame_index;
    u8 active_count;
    u8 final_palette_cycle;
    opening_sprite_a_object_state_t objects[9];
} opening_sprite_a_frame_state_t;

typedef struct {
    size_t entry_count;
    size_t entry_draw_count;
    size_t exit_draw_count;
    size_t total_draw_count;
    u8 entry_draw_al[10];
    u8 exit_draw_al;
    u8 wait_al;
    u16 bx;
    u16 cx;
} opening_scanline_summary_t;

typedef struct {
    size_t script_bytes_consumed;
    size_t chapter2_call_count;
    size_t glyph_count;
    size_t chapter4_draw_call_count;
    size_t script_wait_count;
    u8 first_wait;
    u8 after_script_wait;
    u8 between_explicit_calls_wait;
    u8 after_explicit_calls_wait;
    u8 explicit_chapter2_al[2];
    u16 explicit_chapter2_bx;
} opening_sprite_b_summary_t;

typedef struct {
    u8 jashiin_speech_al;
    u16 jashiin_speech_bx;
    u16 jashiin_speech_cx;
    const char *sar_asset[4];
    u8 sar_al[4];
    u16 sar_di[4];
    u16 sar_es_delta[4];
    u16 decode_si;
    u16 decode_di;
    u16 gfx_mode_bx;
    u16 gfx_mode_cx;
    u16 palette_ax;
} opening_title_asset_summary_t;

typedef enum {
    OPENING_TITLE_ASSET_EVENT_SPEECH,
    OPENING_TITLE_ASSET_EVENT_SAR_LOAD,
    OPENING_TITLE_ASSET_EVENT_DECODE_RLE,
    OPENING_TITLE_ASSET_EVENT_GFX_MODE,
    OPENING_TITLE_ASSET_EVENT_PALETTE,
} opening_title_asset_event_kind_t;

typedef struct {
    opening_title_asset_event_kind_t kind;
    const char *asset;
    u8 al;
    u16 ax;
    u16 bx;
    u16 cx;
    u16 si;
    u16 di;
    u16 es_delta;
} opening_title_asset_event_t;

typedef struct {
    u8 int60_ax;
    u16 int60_si;
    u16 int60_ds_delta;
    size_t driver_call_count;
    u8 wait_al[3];
    u8 gfx_update_al;
    u16 gfx_update_bx;
    u16 gfx_update_cx;
    u16 gfx_update_di;
    u16 gfx_update_es_delta;
    u16 decode_si[2];
    u16 decode_di[2];
    u16 disp_narr_chap3_bx;
    u16 disp_narr_chap3_cx;
    u16 disp_narr_chap3_di;
    u16 disp_narr_open_si;
} opening_title_display_handoff_summary_t;

typedef struct {
    size_t iterations;
    size_t disp_set_call_count;
    size_t wait_count;
    u8 wait_al;
    u8 first_disp_set_al[6];
    u8 final_disp_set_al[6];
    size_t interrupt_cascade_count;
    size_t stick_handler_call_count;
    u8 exits_to_game;
} opening_title_color_exit_summary_t;

typedef struct {
    u8 scene_mode;
    u8 gfx_mode_al;
    u16 gfx_mode_bx;
    u16 gfx_mode_cx;
    size_t gfx_init_count;
    const char *sar_asset;
    u8 sar_al;
    u16 sar_di;
    u16 sar_es_delta;
    u8 int60_ax;
    u16 int60_si;
    u16 int60_di;
    u16 int60_ds_delta;
    u16 palette_ax;
    size_t credits_call_count;
    u8 clears_input;
} opening_timer_exit_summary_t;

typedef struct {
    u8 scene_mode;
    size_t gfx_init_count;
    u8 clears_input;
    u8 reaches_post_title_story;
} opening_trans_exit_summary_t;

typedef struct {
    u16 palette_ax;
    const char *sar_asset[2];
    u8 sar_al[2];
    u16 sar_di[2];
    u16 decompress_si[2];
    u16 decompress_di[2];
    u16 decompress_es_delta[2];
    u8 disp_game_al[2];
    u16 disp_game_bx[2];
    u16 disp_game_cx[2];
    u16 disp_game_di[2];
    u16 disp_game_es_delta[2];
} opening_post_title_story_summary_t;

typedef struct {
    u16 palette_ax;
    u8 disp_game_al;
    u16 disp_game_bx;
    u16 disp_game_cx;
    u16 disp_game_di;
    const char *sar_asset;
    u8 sar_al;
    u16 sar_di;
    u16 decompress_si;
    u16 decompress_di;
} opening_hime_transition_summary_t;

typedef struct {
    size_t font_clear_count;
    u16 palette_ax;
    u8 disp_game_al;
    u16 disp_game_bx;
    u16 disp_game_cx;
    u16 disp_game_di;
    const char *sar_asset;
    u8 sar_al;
    u16 sar_di;
    u16 decompress_si;
    u16 decompress_di;
} opening_dmaou_transition_summary_t;

typedef struct {
    u8 al;
    u16 bx;
    u16 cx;
    u16 di;
    u16 es_delta;
} opening_apparition_overlay_summary_t;

typedef struct {
    u8 busy_wait_al[2];
    u8 disp_game_al[2];
    u16 disp_game_bx[2];
    u16 disp_game_cx[2];
    u16 disp_game_di[2];
    u8 story_timer_wait_al;
    const char *sar_asset;
    u8 sar_al;
    u16 sar_di;
    u16 decompress_si;
    u16 decompress_di;
    u16 gfx_mode_bx;
    u16 gfx_mode_cx;
} opening_apparition_remove_isi_summary_t;

typedef struct {
    u16 palette_ax;
    u8 gfx_update_al;
    u16 gfx_update_bx;
    u16 gfx_update_cx;
    u16 gfx_update_di;
} opening_isi_reveal_summary_t;

size_t opening_scene_sprite_c_events(opening_sprite_event_t *out, size_t max_events);
opening_sprite_a_summary_t opening_scene_sprite_a_summary(void);
void opening_render_sprite_a_frame_for_test(int frame_index);
size_t opening_scene_sprite_a_frame_table(opening_sprite_a_frame_table_entry_t *out,
                                          size_t max_entries);
size_t opening_scene_sprite_a_frame_trace(opening_sprite_a_frame_state_t *out,
                                          size_t max_frames);
opening_scanline_summary_t opening_scanline_summary(void);
opening_scanline_summary_t opening_credits_summary(void);
opening_sprite_b_summary_t opening_scene_sprite_b_summary(void);
size_t opening_title_asset_reload_trace(opening_title_asset_event_t *out, size_t max_events);
opening_title_asset_summary_t opening_title_asset_summary(void);
opening_title_display_handoff_summary_t opening_title_display_handoff_summary(void);
opening_title_color_exit_summary_t opening_title_color_exit_summary(void);
opening_timer_exit_summary_t opening_timer_exit_summary(void);
opening_trans_exit_summary_t opening_trans_exit_summary(void);
opening_post_title_story_summary_t opening_post_title_story_summary(void);
opening_hime_transition_summary_t opening_hime_transition_summary(void);
opening_dmaou_transition_summary_t opening_dmaou_transition_summary(void);
opening_apparition_overlay_summary_t opening_apparition_overlay_summary(void);
opening_apparition_remove_isi_summary_t opening_apparition_remove_isi_summary(void);
opening_isi_reveal_summary_t opening_isi_reveal_summary(void);

#endif
