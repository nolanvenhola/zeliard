#ifndef ZELIARD_OPENING_H
#define ZELIARD_OPENING_H

#include "../core/types.h"
#include <stddef.h>
#include <stdint.h>
#include <stdint.h>

/* Opening cinematic state machine mechanically derived from MASM
 * run_opening_demo_main. MASM bytes, source, and oracle traces are the sole
 * authority for phase order, timing, rendering, and input routing.
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
void opening_set_title_tilemap_variant_for_test(int variant); /* native parity/debug hook */
void opening_set_dmaou_apparition_mode_for_test(int mode); /* native parity/debug hook */
void opening_set_ame_render_mode_for_test(int mode); /* native parity/debug hook */
void opening_render_cached_scene_for_test(int scene_idx); /* native parity/debug hook */
uint64_t opening_debug_busy_wait_delay_fixture_hash(u8 al); /* MASM memory-fixture hook */
uint64_t opening_debug_hime_dmaou_blend_ranges_hash(size_t *nonzero); /* MASM plane fixture */
uint64_t opening_debug_hime_dmaou_blend_frame_hash(size_t *nonzero); /* MASM MCGA fixture */
uint64_t opening_debug_hime_dmaou_ext_hash(size_t *nonzero); /* MASM ES scratch fixture */
uint64_t opening_debug_dmaou_apparition_frame_hash(size_t *nonzero); /* MASM 3C1C fixture */
uint64_t opening_debug_dmaou_post_busy_ext_hash(u8 al, size_t *nonzero);
uint64_t opening_debug_dmaou_post_busy_frame_hash(u8 al, size_t *nonzero);

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
    OPENING_DEBUG_LATE_OUI_GFX_UPDATE_FULL = 11,
    OPENING_DEBUG_LATE_SEI_3C1C_PASS_01 = 12,
    OPENING_DEBUG_LATE_SEI_3C1C_PASS_02 = 13,
    OPENING_DEBUG_LATE_SEI_3C1C_PASS_04 = 14,
    OPENING_DEBUG_LATE_SEI_3C1C_PASS_08 = 15,
    /* Direct 105GDMCA:38E6 fixtures.  Keep these independent of the
     * scene player so the native test can compare the complete driver call
     * against its MASM framebuffer oracle. */
    OPENING_DEBUG_LATE_DISP_LOAD_AX06_FULL = 16,
    OPENING_DEBUG_LATE_DISP_LOAD_AX08_FULL = 17,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_FULL = 18,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_24 = 19,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_48 = 20,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_72 = 21,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_120 = 22,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_144 = 23,
    OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_168 = 24,
    OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_LEFT = 25,
    OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_RIGHT = 26,
    OPENING_DEBUG_DISP_LOAD_SETUP_RECT_MAOP = 27,
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
    size_t rendered_draws;
    size_t stream_pos;
    u16 exit_frame;
    u8 finished;
    uint64_t visible_hash;
    uint64_t work_hash;
} opening_scanline_runtime_summary_t;

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
    u16 final_render_state_a;
    u8 final_render_state_b;
    u8 final_volume_b;
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
    u16 disp_sprite_slot;
    u16 disp_sprite_target;
    u8 disp_sprite_writes_palette;
    u8 disp_sprite_object_count;
    u8 disp_sprite_record_size;
    u8 disp_sprite_scratch_size;
    u8 disp_sprite_source_stride;
    u8 disp_sprite_row_count;
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
size_t opening_debug_scene_sprite_a_object_table(u8 *out, size_t max_bytes);
size_t opening_scene_sprite_a_frame_table(opening_sprite_a_frame_table_entry_t *out,
                                          size_t max_entries);
size_t opening_scene_sprite_a_frame_trace(opening_sprite_a_frame_state_t *out,
                                          size_t max_frames);
opening_scanline_summary_t opening_scanline_summary(void);
opening_scanline_summary_t opening_credits_summary(void);
opening_scanline_runtime_summary_t opening_amulet_scanline_runtime_summary(void);
opening_scanline_runtime_summary_t opening_credits_scanline_runtime_summary(void);
opening_scanline_runtime_summary_t opening_final_scanline_runtime_summary(void);
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
