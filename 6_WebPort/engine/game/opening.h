#ifndef ZELIARD_OPENING_H
#define ZELIARD_OPENING_H

#include "../core/types.h"
#include <stddef.h>

/* Opening cinematic state machine.
 *
 * Simplified port of run_opening_demo_main (100OPDMO.asm:272-465).
 * The full asm sequence includes text overlays, sprite animations, and
 * palette fades; this M2 implementation shows the key scene images in
 * order with fixed durations and supports ENTER/SPACE skip.
 */

void opening_init(void);     /* pre-decode all opening images */
void opening_tick(u32 dt_ms); /* advance timer, blit current scene */
int  opening_done(void);     /* returns 1 when all scenes complete */
void opening_skip(void);     /* immediately advance past remaining scenes */

typedef struct {
    u8  display_al;  /* scene byte minus one, passed to disp_narr_chap2 */
    u16 bx;          /* destination/control word used by the asm caller */
    u8  delay;       /* timer_wait_loop AL value after each frame */
} opening_sprite_event_t;

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

size_t opening_scene_sprite_c_events(opening_sprite_event_t *out, size_t max_events);
opening_sprite_b_summary_t opening_scene_sprite_b_summary(void);
size_t opening_title_asset_reload_trace(opening_title_asset_event_t *out, size_t max_events);
opening_title_asset_summary_t opening_title_asset_summary(void);
opening_title_display_handoff_summary_t opening_title_display_handoff_summary(void);
opening_title_color_exit_summary_t opening_title_color_exit_summary(void);
opening_timer_exit_summary_t opening_timer_exit_summary(void);
opening_trans_exit_summary_t opening_trans_exit_summary(void);

#endif
