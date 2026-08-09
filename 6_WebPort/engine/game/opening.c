/* Opening cinematic — MASM-shaped OPDMO playback.
 *
 * Ports the image-display portion of run_opening_demo_main
 * (3_Assembly/masm/working/zelres1/code/100OPDMO.asm:272-465).
 *
 * Two distinct decode pipelines are used by the original game:
 *
 * ttl3.grp (Zeliard logo):
 *   LOAD_DATA res_ttl3_grp → vga_seg
 *   decode_rle_to_es_di (6DE1 decode, 100OPDMO.asm:290) → scene_framebuf
 *   disp_narr_chap3(BX=0x70F, CX=0x4170) → rows=65, cl=112 at VGA(28,15)
 *   Pipeline: fill_buffer → 6DE1 → interleave_4plane_abc → 8-pass blit
 *   Blit position: BX=0x70F → compute_vram_xy_offset_mcga → col=28, row=15
 *   (offset = 320*BL + BH*4 = 320*15 + 7*4 = 4828 = row 15, col 28)
 *
 * nec.grp (castle scene):
 *   LOAD_DATA res_nec_grp → vga_seg (100OPDMO.asm:302)
 *   DECOMPRESS_VGA → decompress_image → scene_framebuf
 *   gfx_draw_fn(AL=0xFF, BX=0x1220, CX=0x2C68) → rows=44, cl=104 at VGA(72,32)
 *   Pipeline: fill_buffer → decompress_image → interleave_gfx_draw → 8-pass blit
 *   interleave_gfx_draw: planes = {B, 0, 0, A} → nibble values 0/1/8/9
 *   Blit position: BX=0x1220 → 320*32 + 18*4 = 10312 → row=32, col=72
 *
 * hou.grp (palace/overlay):
 *   Loaded to cga_text_seg, decompressed to screen_buf_2 (100OPDMO.asm:323-331),
 *   then rendered via gfx_update_fn (disp_render_a_full path in 105GDMCA.asm).
 *   Overlaid on nec.grp at BX=0x2048, CX=0x1040 → rows=16, cl=64 at VGA(128,72).
 *
 * Text overlays, sprite animations, and palette fades are deferred for later
 * milestones.
 */

#include "opening.h"
#include "opening_script.h"
#include "opening_trace.h"
#include "../render/mcga_runtime.h"
#include "../core/timer.h"
#include "../load/grp.h"
#include "../load/fill_buffer.h"
#include "../load/img_open.h"
#include "../render/palette.h"
#include "../render/font_text.h"
#include "../render/mcga_render.h"
#include "../core/framebuf.h"
#include "../platform/platform.h"
#include <stdlib.h>
#include <string.h>

#if defined(__GNUC__) || defined(__clang__)
#define ZEL_UNUSED __attribute__((unused))
#else
#define ZEL_UNUSED
#endif

/* ---- scene table -------------------------------------------------------- */
typedef enum {
    IMG_GRP     = 0,   /* fill_buffer → 6DE1 → interleave_abc → 8-pass blit */
    IMG_GFX_DRAW = 1,  /* fill_buffer → decompress_image → interleave_gfx_draw → blit */
    IMG_OPEN_ABC = 2,  /* fill_buffer → decompress_image → interleave_abc → blit */
} img_type_t;

typedef struct {
    const char     *asset;
    int             rows, cl;       /* interleave params */
    int             x, y;           /* blit origin in VGA pixel coords */
    u32             duration_ms;
    palette_scene_t palette;
    img_type_t      img_type;
} scene_def_t;

#define OPDMO_WAIT_MS(ticks) \
    ((u32)((((unsigned long long)(ticks) * \
      (unsigned long long)ZEL_GAME_TIMER_DIVISOR * 1000u) + \
      (u32)ZEL_PIT_HZ / 2u) / (u32)ZEL_PIT_HZ))
#define OPDMO_WAIT_TICKS(ticks) ((u32)(ticks))

/* ttl3.grp: fill_buffer(method 0 raw) → 6DE1 → 2-plane 1bpp.
 *           rows=65, cl=112, BP=7280 → decoded ~14560 bytes.
 *           interleave_4plane_abc → 8-pass blit (call_size=260, blit_calls=112).
 *           Image = 260×112 at VGA col=28 row=15 (BX=0x70F in asm).
 *
 * nec.grp:  fill_buffer(method 6) → decompress_image → 2-plane 1bpp.
 *           rows=44, cl=104, BP=4576 → decoded ~9152 bytes.
 *           interleave_gfx_draw → 8-pass blit (call_size=176, blit_calls=104).
 *           Image = 176×104 at VGA col=72 row=32 (BX=0x1220 in asm). */
static const scene_def_t SCENES[] = {
    { "ttl3.grp", 65, 112, 28, 15, 4000, PALETTE_OPENING, IMG_GRP      },
    { "nec.grp",  44, 104, 72, 32, 3500, PALETTE_OPENING, IMG_GFX_DRAW },
    { "dmaou.grp", 0x22, 0x70, 92, 32, 3500, PALETTE_OPENING, IMG_OPEN_ABC },
};
#define NUM_SCENES ((int)(sizeof(SCENES) / sizeof(SCENES[0])))

static const scene_def_t HOU_OVERLAY =
    { "hou.grp", 16, 64, 128, 72, 0, PALETTE_OPENING, IMG_GFX_DRAW };

static const scene_def_t DMAOU_APPARITION =
    { "dmaou.grp", 0x22, 0x30, 92, 40, 0, PALETTE_OPENING, IMG_GFX_DRAW };

static const scene_def_t TITLE_LAYER =
    { NULL, 0x31, 0x80, 44, 72, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t WAKU_FRAME =
    { "waku.grp", 0x50, 0x88, 0, 0, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t AME_SCENE =
    { "ame.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t HIME_SCENE =
    { "hime.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t ISI_SCENE =
    { "isi.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t OUI_SCENE =
    { "oui.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t SEI_SCENE =
    { "sei.grp", 0x24, 0x68, 88, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t YUU1_SCENE =
    { "yuu1.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t YUU2_SCENE =
    { "yuu2.grp", 0x31, 0x60, 64, 16, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t YUUP_SCENE =
    { "yuup.grp", 0x3A, 0x80, 44, 24, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t OUP_SCENE =
    { "oup.grp", 0x3F, 0x80, 180, 24, 0, PALETTE_OPENING, IMG_GRP };

static const scene_def_t YUU3_SCENE =
    { "yuu3.grp", 0x40, 0xC0, 32, 8, 0, PALETTE_OPENING, IMG_GFX_DRAW };

static const scene_def_t MAOP_SCENE =
    { "maop.grp", 0x30, 0x5D, 88, 24, 0, PALETTE_OPENING, IMG_GRP };

enum {
    OPDMO_SEG_SIZE = 0x10000,
    OPDMO_FRAMEBUFFER_A = 0x4000,
    OPDMO_SCENE_DATA_I = 0x97C0,
    OPDMO_FONT_PLANE_A = 0x0660,
    OPDMO_PLANE_DATA_A = 0x1D40,
    OPDMO_PLANE_DATA_B = 0x3A80,
    OPDMO_TEMP_DECODE_BUF = 0x46D3,
    OPDMO_GFX_PLANE_B = 0x3000,
    OPDMO_FRAMEBUFFER_B = 0x6000,
    OPDMO_EXT_SEGMENT = 0xD000,
    OPDMO_FONT_SCANLINE_OFS = 0x0819,
    OPDMO_PIXEL_MASK_A = 0x0D20,
    OPDMO_PIXEL_MASK_B = 0x1A40,
    FINAL_SCENE_ROWS = 0x40,
    FINAL_SCENE_CL = 0xC0,
    FINAL_SCENE_BP = FINAL_SCENE_ROWS * FINAL_SCENE_CL,
    MCGA_REVEAL_BATCH_COUNT = 13,
    MCGA_REVEAL_LOOKUP_COUNT = 1966,
    REVEAL_STEP_COUNT = MCGA_REVEAL_BATCH_COUNT,
    REVEAL_FRAME_TICKS = OPDMO_WAIT_TICKS(0x1C),
    REVEAL_FRAME_MS = OPDMO_WAIT_MS(0x1C),
    MCGA_REVEAL_FRAME_TICKS = OPDMO_WAIT_TICKS(0x0C),
    MCGA_REVEAL_FRAME_MS = OPDMO_WAIT_MS(0x0C),
    MCGA_RENDER_PASS_COUNT = 8,
    MCGA_RENDER_PASS_TICKS = OPDMO_WAIT_TICKS(0x14),
    MCGA_RENDER_PASS_MS = OPDMO_WAIT_MS(0x14),
    TITLE_FADE_IN_TICKS = 2 * MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    TITLE_FADE_IN_MS = OPDMO_WAIT_MS(TITLE_FADE_IN_TICKS),
    TITLE_CARD_TICKS = TITLE_FADE_IN_TICKS,
    TITLE_CARD_MS = OPDMO_WAIT_MS(TITLE_CARD_TICKS),
    SCANLINE_FRAME_TICKS = OPDMO_WAIT_TICKS(0x1C),
    SCANLINE_FRAME_MS = OPDMO_WAIT_MS(0x1C),
    SCANLINE_ENTRY_FRAMES = 10,
    SCANLINE_EXIT_FRAMES = 120,
    GFX_MODE_CLEAR_BX = 0x0000,
    GFX_MODE_CLEAR_CX = 0x50C8,
    GFX_MODE_CLEAR_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    GFX_MODE_CLEAR_MS = OPDMO_WAIT_MS(GFX_MODE_CLEAR_TICKS),
    HIME_ENTRY_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    HIME_ENTRY_BLIT_MS = OPDMO_WAIT_MS(HIME_ENTRY_BLIT_TICKS),
    /* 100OPDMO:849 calls 105GDMCA:38E6 after script 2. The driver draws
     * immediately, then waits twelve 0Ch timer periods while completing its
     * four-sided inverse-font transition. */
    FONT_INV_TRANSITION_TICKS = 12 * OPDMO_WAIT_TICKS(0x0C),
    FONT_INV_TRANSITION_MS = OPDMO_WAIT_MS(FONT_INV_TRANSITION_TICKS),
    DMAOU_ENTRY_CLEAR_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    DMAOU_ENTRY_CLEAR_MS = OPDMO_WAIT_MS(DMAOU_ENTRY_CLEAR_TICKS),
    DMAOU_ENTRY_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    DMAOU_ENTRY_BLIT_MS = OPDMO_WAIT_MS(DMAOU_ENTRY_BLIT_TICKS),
    DMAOU_PRELUDE_ENTRY_TICKS = DMAOU_ENTRY_CLEAR_TICKS +
                                DMAOU_ENTRY_BLIT_TICKS,
    DMAOU_PRELUDE_ENTRY_MS = OPDMO_WAIT_MS(DMAOU_PRELUDE_ENTRY_TICKS),
    ISI_REVEAL_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    ISI_REVEAL_BLIT_MS = OPDMO_WAIT_MS(ISI_REVEAL_BLIT_TICKS),
    ISI_POST_SCRIPT8_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    ISI_POST_SCRIPT8_BLIT_MS = OPDMO_WAIT_MS(ISI_POST_SCRIPT8_BLIT_TICKS),
    OUI_UPDATE_TICKS = MCGA_RENDER_PASS_COUNT * 2 * MCGA_RENDER_PASS_TICKS,
    OUI_UPDATE_MS = OPDMO_WAIT_MS(OUI_UPDATE_TICKS),
    SEI_REVEAL_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    SEI_REVEAL_MS = OPDMO_WAIT_MS(SEI_REVEAL_TICKS),
    YUU1_ENTRY_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    YUU1_ENTRY_BLIT_MS = OPDMO_WAIT_MS(YUU1_ENTRY_BLIT_TICKS),
    DMAOU_BLEND_DELAY_TICKS = OPDMO_WAIT_TICKS(0x04),
    DMAOU_BLEND_DELAY_MS = OPDMO_WAIT_MS(0x04),
    /* 100OPDMO:867-872 calls 105GDMCA:3C1C with AL=7, BX=1728h,
     * CX=2230h.  The driver reveals one of eight row lanes per 14h wait. */
    DMAOU_APPARITION_REVEAL_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    DMAOU_APPARITION_REVEAL_MS = OPDMO_WAIT_MS(DMAOU_APPARITION_REVEAL_TICKS),
    /* 100OPDMO:880-901.  Each DISP_GAME AL=0 call reaches
     * 105GDMCA:33B7, which runs an eight-pass OR draw followed by an
     * eight-pass masked-write draw.  Keep the two calls distinct: the
     * AL=0F wait occurs between their completed framebuffers. */
    APPARITION_REMOVE_FIRST_DRAW_TICKS = 2 * MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    APPARITION_REMOVE_FIRST_DRAW_MS = OPDMO_WAIT_MS(APPARITION_REMOVE_FIRST_DRAW_TICKS),
    APPARITION_REMOVE_HOLD_TICKS = OPDMO_WAIT_TICKS(0x0F),
    APPARITION_REMOVE_HOLD_MS = OPDMO_WAIT_MS(0x0F),
    APPARITION_REMOVE_SECOND_DRAW_TICKS = 2 * MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    APPARITION_REMOVE_SECOND_DRAW_MS = OPDMO_WAIT_MS(APPARITION_REMOVE_SECOND_DRAW_TICKS),
    APPARITION_REMOVE_ISI_TICKS = APPARITION_REMOVE_FIRST_DRAW_TICKS +
                                  APPARITION_REMOVE_HOLD_TICKS +
                                  APPARITION_REMOVE_SECOND_DRAW_TICKS,
    APPARITION_REMOVE_ISI_MS = APPARITION_REMOVE_FIRST_DRAW_MS +
                               APPARITION_REMOVE_HOLD_MS +
                               APPARITION_REMOVE_SECOND_DRAW_MS,
    STORY_FETCH_TICKS = OPDMO_WAIT_TICKS(0x10),
    STORY_FETCH_MS = OPDMO_WAIT_MS(0x10),
    STORY_WAIT_TICKS = OPDMO_WAIT_TICKS(0xF0),
    STORY_WAIT_MS = OPDMO_WAIT_MS(0xF0),
    AMULET_FADE_IN_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    AMULET_FADE_IN_MS = OPDMO_WAIT_MS(AMULET_FADE_IN_TICKS),
    ANCIENT_PROLOGUE_SCROLL_TICKS = 31 * SCANLINE_ENTRY_FRAMES * SCANLINE_FRAME_TICKS,
    ANCIENT_PROLOGUE_SCROLL_MS = OPDMO_WAIT_MS(ANCIENT_PROLOGUE_SCROLL_TICKS),
    AMULET_TEXT_FADE_OUT_TICKS = SCANLINE_EXIT_FRAMES * SCANLINE_FRAME_TICKS,
    AMULET_TEXT_FADE_OUT_MS = OPDMO_WAIT_MS(AMULET_TEXT_FADE_OUT_TICKS),
    ANCIENT_PROLOGUE_TICKS = AMULET_FADE_IN_TICKS + ANCIENT_PROLOGUE_SCROLL_TICKS + AMULET_TEXT_FADE_OUT_TICKS,
    ANCIENT_PROLOGUE_MS = OPDMO_WAIT_MS(ANCIENT_PROLOGUE_TICKS),
    SPRITE_A_RECORD_COUNT = 9,
    SPRITE_A_RECORD_SIZE = 6,
    SPRITE_A_FRAME_WAIT_TICKS = OPDMO_WAIT_TICKS(0x1E),
    SPRITE_A_FRAME_WAIT_MS = OPDMO_WAIT_MS(0x1E),
    SPRITE_A_FRAME_COUNT = 12,
    SPRITE_A_TICKS = SPRITE_A_FRAME_COUNT * SPRITE_A_FRAME_WAIT_TICKS,
    SPRITE_A_MS = OPDMO_WAIT_MS(SPRITE_A_TICKS),
    NEC_HOU_BLIT_TICKS = OPDMO_WAIT_TICKS(8 * 0x14),
    NEC_HOU_BLIT_MS = OPDMO_WAIT_MS(8 * 0x14),
    /* 100OPDMO:381-389 decompresses HOU and calls 105GDMCA:33B7 before
     * scene_sprite_a.  Those routines do not poll gvar_frame_timer, but the
     * hardware PIT continues advancing during their synchronous execution.
     * The released-video oracle measures that span as 2*14h timer ticks. */
    NEC_HOU_OVERLAY_SERVICE_TICKS = OPDMO_WAIT_TICKS(2 * 0x14),
    NEC_HOU_OVERLAY_SERVICE_MS = OPDMO_WAIT_MS(2 * 0x14),
    NEC_HOU_TRANSITION_TICKS = NEC_HOU_BLIT_TICKS +
                               NEC_HOU_OVERLAY_SERVICE_TICKS +
                               SPRITE_A_TICKS,
    NEC_HOU_TRANSITION_MS = OPDMO_WAIT_MS(NEC_HOU_TRANSITION_TICKS),
    DMAOU_SPRITE_C_FRAME_TICKS = OPDMO_WAIT_TICKS(0x14),
    DMAOU_SPRITE_C_FRAME_MS = OPDMO_WAIT_MS(0x14),
    DMAOU_SPRITE_C_TICKS = 12 * DMAOU_SPRITE_C_FRAME_TICKS,
    DMAOU_SPRITE_C_MS = OPDMO_WAIT_MS(DMAOU_SPRITE_C_TICKS),
    DMAOU_BEFORE_SPRITE_B_TICKS = OPDMO_WAIT_TICKS(0xF0),
    DMAOU_BEFORE_SPRITE_B_MS = OPDMO_WAIT_MS(0xF0),
    DMAOU_SPRITE_B_WAIT_COUNT = 91,
    DMAOU_SPRITE_B_TICKS = DMAOU_SPRITE_B_WAIT_COUNT * DMAOU_SPRITE_C_FRAME_TICKS,
    DMAOU_SPRITE_B_MS = OPDMO_WAIT_MS(DMAOU_SPRITE_B_TICKS),
    DMAOU_AFTER_SPRITE_B_TICKS = OPDMO_WAIT_TICKS(0xF0),
    DMAOU_AFTER_SPRITE_B_MS = OPDMO_WAIT_MS(0xF0),
    DMAOU_EXPLICIT_FRAME_TICKS = OPDMO_WAIT_TICKS(0x0F),
    DMAOU_EXPLICIT_FRAME_MS = OPDMO_WAIT_MS(0x0F),
    DMAOU_AFTER_EXPLICIT_FRAME_TICKS = OPDMO_WAIT_TICKS(0xF0),
    DMAOU_AFTER_EXPLICIT_FRAME_MS = OPDMO_WAIT_MS(0xF0),
    DMAOU_DEMON_INTRO_TICKS = DMAOU_PRELUDE_ENTRY_TICKS +
                              DMAOU_SPRITE_C_TICKS +
                              DMAOU_BEFORE_SPRITE_B_TICKS +
                              DMAOU_SPRITE_B_TICKS +
                              DMAOU_AFTER_SPRITE_B_TICKS +
                              DMAOU_EXPLICIT_FRAME_TICKS +
                              DMAOU_AFTER_EXPLICIT_FRAME_TICKS,
    DMAOU_DEMON_INTRO_MS = OPDMO_WAIT_MS(DMAOU_DEMON_INTRO_TICKS),
    TITLE_COLOR_ROTATE_TICKS = 100 * OPDMO_WAIT_TICKS(0x50),
    TITLE_COLOR_ROTATE_MS = 100 * OPDMO_WAIT_MS(0x50),
    TITLE_TTL1_UPDATE_TICKS = MCGA_RENDER_PASS_COUNT * 2 * MCGA_RENDER_PASS_TICKS,
    TITLE_TTL1_UPDATE_MS = OPDMO_WAIT_MS(TITLE_TTL1_UPDATE_TICKS),
    /* 100OPDMO:495-499 dispatches ttl3 through 105GDMCA:30FCh.  The
     * disp_render_a_full path performs an eight-pass OR reveal followed by
     * the common eight-pass masked write; both loops wait 14h ticks. */
    TITLE_TTL3_UPDATE_TICKS = MCGA_RENDER_PASS_COUNT * 2 * MCGA_RENDER_PASS_TICKS,
    TITLE_TTL3_UPDATE_MS = OPDMO_WAIT_MS(TITLE_TTL3_UPDATE_TICKS),
    TITLE_PRE_CLEAR_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    TITLE_PRE_CLEAR_MS = OPDMO_WAIT_MS(TITLE_PRE_CLEAR_TICKS),
    TITLE_COLOR_START_TICKS = TITLE_PRE_CLEAR_TICKS +
                              OPDMO_WAIT_TICKS(0xF0) * 3 +
                              TITLE_TTL1_UPDATE_TICKS +
                              TITLE_TTL3_UPDATE_TICKS,
    TITLE_COLOR_START_MS = OPDMO_WAIT_MS(TITLE_COLOR_START_TICKS),
    /* 100OPDMO:528-532 polls gvar_enable_all after the 37B4 sweep.  The
     * current sound proxy cannot yet derive this from zopn.msd, so retain the
     * release-capture oracle: the first changed title frame is at 192.567s.
     * The former 20546-tick residual included the omitted 30E4 eight-pass
     * clear.  That call is now modeled above as 8*14h ticks. */
    TITLE_GFX_READY_WAIT_TICKS = 20546 - TITLE_PRE_CLEAR_TICKS,
    TITLE_GFX_READY_WAIT_MS = OPDMO_WAIT_MS(TITLE_GFX_READY_WAIT_TICKS),
    TITLE_LOGO_HANDOFF_TICKS = TITLE_PRE_CLEAR_TICKS +
                               OPDMO_WAIT_TICKS(0xF0) * 3 +
                               TITLE_TTL1_UPDATE_TICKS +
                               TITLE_TTL3_UPDATE_TICKS +
                               TITLE_COLOR_ROTATE_TICKS +
                               TITLE_GFX_READY_WAIT_TICKS +
                               GFX_MODE_CLEAR_TICKS,
    TITLE_LOGO_HANDOFF_MS = OPDMO_WAIT_MS(TITLE_LOGO_HANDOFF_TICKS),
    CREDITS_ENTRY_SCROLL_TICKS = 52 * SCANLINE_ENTRY_FRAMES * SCANLINE_FRAME_TICKS,
    CREDITS_ENTRY_SCROLL_MS = OPDMO_WAIT_MS(CREDITS_ENTRY_SCROLL_TICKS),
    CREDITS_SCROLL_TICKS = CREDITS_ENTRY_SCROLL_TICKS + AMULET_TEXT_FADE_OUT_TICKS,
    CREDITS_SCROLL_MS = OPDMO_WAIT_MS(CREDITS_SCROLL_TICKS),
    FINAL_SCENE_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    FINAL_SCENE_BLIT_MS = OPDMO_WAIT_MS(FINAL_SCENE_BLIT_TICKS),
    FINAL_SCENE_HOLD_TICKS = STORY_WAIT_TICKS,
    FINAL_SCENE_HOLD_MS = STORY_WAIT_MS,
    /* 100OPDMO:1075-1080 performs a second eight-pass gfx_draw after F0. */
    FINAL_SCENE_DRAW_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    FINAL_SCENE_DRAW_MS = OPDMO_WAIT_MS(FINAL_SCENE_DRAW_TICKS),
    /* animate_scanline_alt consumes six centered CR records then its
     * separate FF record: seven records x ten draws. */
    FINAL_SCENE_TEXT_TICKS = 7 * SCANLINE_ENTRY_FRAMES * SCANLINE_FRAME_TICKS,
    FINAL_SCENE_TEXT_MS = OPDMO_WAIT_MS(FINAL_SCENE_TEXT_TICKS),
    FINAL_SCENE_FADE_TICKS = 0xA0 * SCANLINE_FRAME_TICKS,
    FINAL_SCENE_FADE_MS = OPDMO_WAIT_MS(FINAL_SCENE_FADE_TICKS),
    FINAL_SCENE_POST_HOLD_TICKS = 10 * OPDMO_WAIT_TICKS(0xC8),
    FINAL_SCENE_POST_HOLD_MS = OPDMO_WAIT_MS(FINAL_SCENE_POST_HOLD_TICKS),
    /* 100OPDMO:1123-1128 enters transition_out_to_game by calling
     * gfx_mode_fn with BX=0000h/CX=50C8h.  105GDMCA clears one masked lane
     * per 14h-tick render pass before game.bin is loaded. */
    FINAL_SCENE_CLEAR_TICKS = GFX_MODE_CLEAR_TICKS,
    FINAL_SCENE_CLEAR_MS = GFX_MODE_CLEAR_MS,
    RAIN_PRINCESS_WAKU_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    RAIN_PRINCESS_WAKU_BLIT_MS = OPDMO_WAIT_MS(RAIN_PRINCESS_WAKU_BLIT_TICKS),
    RAIN_PRINCESS_AME_BLIT_TICKS = MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_TICKS,
    RAIN_PRINCESS_AME_BLIT_MS = OPDMO_WAIT_MS(RAIN_PRINCESS_AME_BLIT_TICKS),
    RAIN_PRINCESS_ENTRY_TICKS = RAIN_PRINCESS_WAKU_BLIT_TICKS + RAIN_PRINCESS_AME_BLIT_TICKS,
    RAIN_PRINCESS_ENTRY_MS = OPDMO_WAIT_MS(RAIN_PRINCESS_ENTRY_TICKS),
    RAIN_PRINCESS_TICKS = RAIN_PRINCESS_ENTRY_TICKS +
                          743 * STORY_FETCH_TICKS + 34 * STORY_WAIT_TICKS,
    RAIN_PRINCESS_MS = RAIN_PRINCESS_ENTRY_MS +
                       743 * STORY_FETCH_MS + 34 * STORY_WAIT_MS,
    RAIN_SAND_TICKS = HIME_ENTRY_BLIT_TICKS + 306 * STORY_FETCH_TICKS + 15 * STORY_WAIT_TICKS +
                      FONT_INV_TRANSITION_TICKS,
    RAIN_SAND_MS = HIME_ENTRY_BLIT_MS + 306 * STORY_FETCH_MS + 15 * STORY_WAIT_MS +
                   FONT_INV_TRANSITION_MS,
    JASHIIN_CURSE_TICKS = DMAOU_ENTRY_BLIT_TICKS +
                       (174 + 235 + 1 + 157 + 91) * STORY_FETCH_TICKS +
                        (7 + 6 + 2) * STORY_WAIT_TICKS +
                        DMAOU_BLEND_DELAY_TICKS +
                        DMAOU_APPARITION_REVEAL_TICKS +
                        APPARITION_REMOVE_ISI_TICKS,
    JASHIIN_CURSE_MS = DMAOU_ENTRY_BLIT_MS +
                       (174 + 235 + 1 + 157 + 91) * STORY_FETCH_MS +
                        (7 + 6 + 2) * STORY_WAIT_MS +
                        DMAOU_BLEND_DELAY_MS +
                        DMAOU_APPARITION_REVEAL_MS +
                        APPARITION_REMOVE_ISI_MS,
    KING_SPIRIT_TICKS = ISI_REVEAL_BLIT_TICKS + ISI_POST_SCRIPT8_BLIT_TICKS +
                     OUI_UPDATE_TICKS +
                     SEI_REVEAL_TICKS +
                     (4 + 193 + 162 + 75 + 1033 + 258) * STORY_FETCH_TICKS +
                     (2 + 6 + 3 + 2 + 22 + 10) * STORY_WAIT_TICKS +
                     FONT_INV_TRANSITION_TICKS,
    KING_SPIRIT_MS = ISI_REVEAL_BLIT_MS + ISI_POST_SCRIPT8_BLIT_MS +
                     OUI_UPDATE_MS +
                     SEI_REVEAL_MS +
                     (4 + 193 + 162 + 75 + 1033 + 258) * STORY_FETCH_MS +
                     (2 + 6 + 3 + 2 + 22 + 10) * STORY_WAIT_MS +
                     FONT_INV_TRANSITION_MS,
    DUKE_ARRIVES_TICKS = YUU1_ENTRY_BLIT_TICKS +
                       (173 + 97) * STORY_FETCH_TICKS +
                       (7 + 3) * STORY_WAIT_TICKS +
                       FONT_INV_TRANSITION_TICKS,
    DUKE_ARRIVES_MS = YUU1_ENTRY_BLIT_MS +
                       (173 + 97) * STORY_FETCH_MS +
                       (7 + 3) * STORY_WAIT_MS +
                       FONT_INV_TRANSITION_MS,
    KING_DUKE_TICKS = (605 + 1) * STORY_FETCH_TICKS +
                   16 * STORY_WAIT_TICKS +
                   FONT_INV_TRANSITION_TICKS,
    KING_DUKE_MS = (605 + 1) * STORY_FETCH_MS +
                   16 * STORY_WAIT_MS +
                   FONT_INV_TRANSITION_MS,
    JASHIIN_CONFRONT_TICKS = (102 + 69) * STORY_FETCH_TICKS +
                          (3 + 2) * STORY_WAIT_TICKS +
                          24 * OPDMO_WAIT_TICKS(0x0F) +
                          (795 + 77) * STORY_FETCH_TICKS +
                          (22 + 2) * STORY_WAIT_TICKS,
    JASHIIN_CONFRONT_MS = (102 + 69) * STORY_FETCH_MS +
                          (3 + 2) * STORY_WAIT_MS +
                          24 * OPDMO_WAIT_MS(0x0F) +
                          (795 + 77) * STORY_FETCH_MS +
                          (22 + 2) * STORY_WAIT_MS,
    JASHIIN_DEPART_TICKS = 24 * OPDMO_WAIT_TICKS(0x0F) +
                        FONT_INV_TRANSITION_TICKS +
                        87 * STORY_FETCH_TICKS + 3 * STORY_WAIT_TICKS,
    JASHIIN_DEPART_MS = 24 * OPDMO_WAIT_MS(0x0F) +
                        FONT_INV_TRANSITION_MS +
                        87 * STORY_FETCH_MS + 3 * STORY_WAIT_MS,
    DESTINY_CARD_TICKS = FINAL_SCENE_BLIT_TICKS + FINAL_SCENE_HOLD_TICKS +
                          FINAL_SCENE_DRAW_TICKS +
                          FINAL_SCENE_TEXT_TICKS + FINAL_SCENE_FADE_TICKS +
                          FINAL_SCENE_POST_HOLD_TICKS +
                          FINAL_SCENE_CLEAR_TICKS,
    DESTINY_CARD_MS = FINAL_SCENE_BLIT_MS + FINAL_SCENE_HOLD_MS +
                      FINAL_SCENE_DRAW_MS +
                      FINAL_SCENE_TEXT_MS + FINAL_SCENE_FADE_MS +
                      FINAL_SCENE_POST_HOLD_MS + FINAL_SCENE_CLEAR_MS,
    TITLE_COPYRIGHT_COLOR = 0x77,
    SCANLINE_TEXT_COLOR = TITLE_COPYRIGHT_COLOR,
    TITLE_COPYRIGHT_Y = 0x96,
    TITLE_COPYRIGHT_X = 0x20,
    TITLE_COPYRIGHT_LINE_HEIGHT = 8,
    OPDMO_MCGA_BLACK_INDEX = 0x00,
    OPDMO_MCGA_RED_WIPE_INDEX = 0xA0,
};

static const char TITLE_COPYRIGHT_LINE_1[] = "Copyright (C)1987,1990 GAME ARTS";
static const char TITLE_COPYRIGHT_LINE_2[] = "Copyright (C)1990 Sierra On-Line";

static const char *const ANCIENT_PROLOGUE_LINES[] = {
    "           Two thousand years,",
    "from the dark reaches of another galaxy,",
    "        a demon with not a shred",
    "      of compassion for humankind,",
    "         descended upon earth.",
    "",
    "          He defiled the land,",
    "  sending vile creatures to live in it,",
    "   and thus became ruler of the world.",
    "",
    "         The King of Felishika,",
    "     appalled by what had happened,",
    "          prayed to the Spirit",
    "      of the Holy Land of Zeliard",
    "    for help in defeating this monster.",
    "",
    "    With the help of the holy crystals",
    "       called Tears of Esmesanti,",
    "    the King managed to wrest power",
    "    from the fiend and seal him deep",
    "     within the bowels of the earth.",
    "",
    "            And once again,",
    " the light of peace came to shine upon",
    "              the earth.",
    "",
    "",
    "However, it is written in",
    "       the Sixth Book of Esmesanti:",
    "                    The Age of Darkness.",
    "",
};
#define ANCIENT_PROLOGUE_LINE_COUNT ((int)(sizeof(ANCIENT_PROLOGUE_LINES) / sizeof(ANCIENT_PROLOGUE_LINES[0])))

/* 100OPDMO:742F anim_fade_tbl_credits has 52 CR/FF-terminated records.
 * The bytes are interpreted by 105GDMCA:32C9; do not duplicate the text in
 * C, because even spacing and control bytes are part of the visual contract. */
enum { CREDITS_STREAM_RECORDS = 52 };

static const char *const RAIN_SAND_LINES[] = {
    "The raindrops turned to grains of sand",
    "which covered the ground below her.",
    "",
    "The green hills and plains turned a",
    "dusty brown.",
    "",
    "Trees and flowers crumpled and were",
    "buried beneath the sand.",
};
#define RAIN_SAND_LINE_COUNT ((int)(sizeof(RAIN_SAND_LINES) / sizeof(RAIN_SAND_LINES[0])))

static const char *const JASHIIN_CURSE_LINES[] = {
    "\"I am Jashiin, the Emperor of Chaos.\"",
    "",
    "\"Beautiful Princess Felicia, you will",
    "make a lovely and terrifying symbol",
    "of my awakening.\"",
    "",
    "Princess Felicia was turned to stone.",
};
#define JASHIIN_CURSE_LINE_COUNT ((int)(sizeof(JASHIIN_CURSE_LINES) / sizeof(JASHIIN_CURSE_LINES[0])))

static const char *const KING_SPIRIT_LINES[] = {
    "The rain of sand continued for 108 days.",
    "",
    "The King wept most of all.",
    "",
    "\"I am the Guardian Spirit of the Holy",
    "Land of Zeliard.\"",
    "",
    "\"Recover the nine Holy Crystals,",
    "the Tears of Esmesanti.\"",
};
#define KING_SPIRIT_LINE_COUNT ((int)(sizeof(KING_SPIRIT_LINES) / sizeof(KING_SPIRIT_LINES[0])))

static const char *const DUKE_ARRIVES_LINES[] ZEL_UNUSED = {
    "Having spoken these words, the Spirit",
    "disappeared.",
    "",
    "But the next day, a stranger appeared",
    "in the kingdom...",
    "",
    "\"What a desolate place!\"",
    "\"Why has the Spirit led me here?\"",
};
#define DUKE_ARRIVES_LINE_COUNT ((int)(sizeof(DUKE_ARRIVES_LINES) / sizeof(DUKE_ARRIVES_LINES[0])))

static const char *const KING_DUKE_LINES[] ZEL_UNUSED = {
    "\"Duke Garland! You must be the man",
    "of destiny of whom the Spirit spoke.\"",
    "",
    "\"I beg of you to destroy the demon",
    "Jashiin who has cursed my kingdom.\"",
    "",
    "\"I will dedicate my life to this task.\"",
};
#define KING_DUKE_LINE_COUNT ((int)(sizeof(KING_DUKE_LINES) / sizeof(KING_DUKE_LINES[0])))

static const char *const JASHIIN_CONFRONT_LINES[] ZEL_UNUSED = {
    "Suddenly, the room grew cold.",
    "A black mist swirled around them.",
    "",
    "\"Are you the fool who dares to",
    "challenge me?\"",
    "",
    "\"You shall address me as the",
    "Emperor of Chaos!\"",
};
#define JASHIIN_CONFRONT_LINE_COUNT ((int)(sizeof(JASHIIN_CONFRONT_LINES) / sizeof(JASHIIN_CONFRONT_LINES[0])))

static const char *const JASHIIN_DEPART_LINES[] ZEL_UNUSED = {
    "\"Mark my words, evil one: I will not",
    "stop until I have reclaimed the nine",
    "holy crystals.\"",
    "",
    "Jashiin disappeared leaving echoes",
    "of earsplitting laughter.",
    "",
    "\"You haven't seen the last of me,",
    "Jashiin!\"",
};
#define JASHIIN_DEPART_LINE_COUNT ((int)(sizeof(JASHIIN_DEPART_LINES) / sizeof(JASHIIN_DEPART_LINES[0])))

static const u8 OPENING_PROLOGUE_SCRIPT_FALLBACK[] =
    "\360\376\363\372"
    "Once, long ago, a terrible storm came to the land of Zeliard. "
    "\365\365\365\365\376\367"
    "Dark clouds filled the sky; lightning flashed and thunder crashed. "
    "\362"
    "Day after day, rain poured from the heavens as if in lament."
    "\365\365\365\365\376\365\365\376\363\365"
    "On the seventh day of rain, a beautiful young girl stood on her balcony watching this dark, sad rain."
    "\365\365\365\365\376\363"
    "The girl was Princess Felicia la Felishika.  She was the only daughter of King Felishika, and the light of his life."
    "\365\365\365\365\376\363\365"
    "Her smiles were like sunshine, her voice as beautiful as that of an angel.  She was adored by the people of the kingdom."
    "\365\365\365\365\375";

static const u8 SCENE_SPRITE_C[] = {
    0x01, 0x01, 0x01, 0x02, 0x02, 0x01,
    0x01, 0x02, 0x02, 0x03, 0x03, 0x05, 0x00
};

/* scene_sprite_a at runtime CS:9060h.  105GDMCA.disp_sprite_obj_init
 * consumes nine 6-byte records: x, y, dx, dy, first_frame, last_frame. */
static const u8 SCENE_SPRITE_A[] = {
    0x58, 0x25, 0xF0, 0x00, 0x00, 0x03,
    0x68, 0x21, 0xFC, 0xFC, 0x04, 0x07,
    0x70, 0x23, 0x01, 0xFD, 0x04, 0x07,
    0x70, 0x24, 0x04, 0xFD, 0x04, 0x07,
    0x78, 0x25, 0x06, 0xFE, 0x04, 0x07,
    0x78, 0x28, 0x06, 0x02, 0x04, 0x07,
    0x70, 0x29, 0x04, 0x03, 0x04, 0x07,
    0x70, 0x2A, 0x01, 0x03, 0x04, 0x07,
    0x68, 0x2C, 0xFC, 0x04, 0x04, 0x07,
};

static const u8 SCENE_SPRITE_B[] = {
    0xFF, 0x01, 0x08, 0x01, 'B',  'e',  0x03, 'w',
    'a',  0x04, 'r',  'e',  ',',  ' ',  0x03, 'f',
    'o',  0x04, 'r',  ' ',  0x04, 'I',  ' ',  0x01,
    's',  'h',  'a',  0x03, 'l',  'l',  ' ',  'w',
    0x04, 'a',  'k',  0x03, 'e',
    0xFF, 0x01, 0x06, 0x03, 'f',  'r',  'o',  0x03,
    'm',  ' ',  0x02, 'm',  0x01, 'y',  ' ',  0x03,
    's',  0x01, 'l',  'e',  'e',  0x01, 'p',  ' ',
    'o',  'f',  ' ',  0x03, '2',  ',',  0x04, '0',
    '0',  '0',  ' ',  0x01, 'y',  'e',  0x04, 'a',
    'r',  0x03, 's',
    0xFF, 0x01, 0x02, 0x04, 'a',  0x02, 'n',  0x03,
    'd',  ' ',  0x03, 'o',  0x02, 'n',  'c',  'e',
    ' ',  0x04, 'a',  'g',  'a',  0x01, 'i',  'n',
    ' ',  0x02, 'r',  'e',  0x04, 'i',  0x01, 'g',
    'n',  ' ',  0x03, 'o',  'v',  0x04, 'e',  'r',
    ' ',  0x01, 't',  'h',  'e',  ' ',  0x04, 'w',
    'o',  'r',  0x03, 'l',  'd',  '.',  0x02, 0x00
};

/* scene_sprite_d at runtime CS:912Bh. The release chunk is loaded at 6000h
 * with the SAR header stripped, so these bytes are copied from
 * 3_Assembly/masm/bin/zelres1/100OPDMO.bin file offset 312Fh. */
static const u8 SCENE_SPRITE_D[25 * 34] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14,
    0x15, 0x16, 0x00, 0x00, 0x00, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21,
    0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x00, 0x00, 0x2F,
    0x30, 0x31, 0x32, 0x33, 0x00, 0x00, 0x34, 0x35, 0x36, 0x37, 0x38, 0x00, 0x39, 0x26, 0x3A, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x3B, 0x3C, 0x3D, 0x00, 0x00, 0x00, 0x3E, 0x3F, 0x40, 0x41, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x43, 0x44, 0x45, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x47, 0x16, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x49,
    0x4A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x4B, 0x4C, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x4E, 0x4F, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x52, 0x53, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x54, 0x55, 0x56, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x57, 0x58, 0x59,
    0x5A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5B,
    0x5C, 0x5D, 0x5E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x5F, 0x60, 0x61, 0x62, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x63, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x65, 0x66, 0x67, 0x68, 0x69, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72,
    0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A,
    0x7B, 0x7C, 0x7D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7E, 0x7F, 0x80, 0x81, 0x82,
    0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x00, 0x00, 0x00, 0x00, 0x0F, 0x8A, 0x8B, 0x8C, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2F, 0x8D, 0x8E,
    0x8F, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x00, 0x00, 0x00, 0x98, 0x99, 0x9A, 0x9B,
    0x9C, 0x9D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x9E, 0x9F, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0x16, 0x00, 0xAA, 0xAB,
    0xAC, 0xAD, 0xAE, 0xAF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0x26, 0x26, 0xB9, 0xBA, 0xBB,
    0xBC, 0xBD, 0xBE, 0xBF, 0xC0, 0xC1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,
};

/* 100OPDMO.asm uses adjacent 96-byte metric slices at char_width_tbl and
 * char_glyph_tbl, indexed by (character - 0x20), for story text placement.
 * These bytes are copied from the MASM bit-perfect 100OPDMO release chunk. */
static const u8 OPDMO_STORY_LEFT_BEARING[96] = {
    0, 2, 2, 3, 1, 0, 0, 2, 2, 3, 1, 1, 1, 2, 2, 0,
    1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 3, 2, 1, 1, 2, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 2, 2, 1, 1,
    1, 0, 0, 1, 0, 1, 1, 0, 0, 2, 1, 0, 2, 0, 1, 1,
    0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 2, 0, 3, 1, 0
};

static const u8 OPDMO_STORY_ADVANCE[96] = {
    5, 4, 4, 4, 6, 8, 5, 3, 4, 4, 6, 6, 6, 5, 6, 8,
    7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 3, 4, 6, 6, 6, 7,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 8, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 7, 8, 8, 8, 8, 8, 7, 5, 3, 5, 6, 7,
    7, 8, 8, 7, 8, 7, 7, 8, 8, 5, 6, 8, 5, 8, 7, 7,
    8, 8, 8, 7, 6, 8, 8, 8, 7, 7, 7, 4, 8, 4, 7, 8
};

/* ---- decoded image cache ------------------------------------------------ */
typedef struct {
    u8        *pixels;
    int        w, h;
    int        x, y;
} cached_image_t;

static cached_image_t g_images[NUM_SCENES];
static cached_image_t g_hou_overlay;
static u8            *g_hou_planes = NULL;
static size_t         g_hou_planes_size = 0;
static cached_image_t g_ame_scene;
static cached_image_t g_hime_scene;
static cached_image_t g_hime_scene_ax9;
static cached_image_t g_hime_scene_ax6;
static cached_image_t g_hime_dmaou_blend_scene;
static u8            *g_hime_dmaou_blend_seg;
static u8            *g_hime_dmaou_ext_seg;
static u8            *g_scene_sprite_c_work_seg;
static u8            *g_scene_sprite_c_vga_seg;
static u8            *g_scene_sprite_b_work_seg;
static u8            *g_scene_sprite_b_vga_seg;
static u8            *g_dmaou_prelude_game_seg;
static u8            *g_dmaou_prelude_scratch_seg;
static u8            *g_dmaou_entry_work_seg;
static u8            *g_dmaou_entry_vga_seg;
static cached_image_t g_dmaou_apparition_overlay;
static cached_image_t g_isi_scene;
static cached_image_t g_isi_scene_ax7;
static cached_image_t g_oui_scene;
static cached_image_t g_oui_scene_gfx_update;
static cached_image_t g_oui_scene_gfx_update_framed;
static cached_image_t g_sei_scene;
static cached_image_t g_sei_scene_ax5;
static cached_image_t g_sei_disp_data_ax5;
static cached_image_t g_sei_disp_data_overlay;
static cached_image_t g_yuu1_scene;
static cached_image_t g_yuu1_scene_ax7;
static cached_image_t g_yuu2_scene;
static cached_image_t g_yuup_scene;
static cached_image_t g_oup_scene;
static cached_image_t g_yuu3_scene;
static cached_image_t g_yuu3_final_scene;
static cached_image_t g_yuu3_final_draw_scene;
static u8 *g_final_yuu_runtime_seg;
static cached_image_t g_maop_scene;
static u8             *g_maop_planes = NULL;
static size_t          g_maop_planes_size = 0;
static cached_image_t g_ttl1_layer;
static u8             *g_ttl1_planes = NULL;
static size_t          g_ttl1_planes_size = 0;
static u8             *g_ttl3_planes = NULL;
static size_t          g_ttl3_planes_size = 0;
static u8             *g_ttl2_planes = NULL;
static size_t          g_ttl2_planes_size = 0;
static cached_image_t g_ttl2_tilemap;
static u8             *g_ttl2_tilemap_planes = NULL;
static size_t          g_ttl2_tilemap_planes_size = 0;
static int            g_title_tilemap_variant = 0;
static int            g_ame_render_mode_for_test = -1;
static cached_image_t g_title_pass_frames[MCGA_RENDER_PASS_COUNT + 1];
static cached_image_t g_nec_pass_frames[MCGA_RENDER_PASS_COUNT + 1];
static u8             *g_title_card_frame = NULL;
static u8             *g_yuu_anim_seg = NULL;
static u8             *g_opdmo_chunk_seg = NULL;
static u8             *g_gdmcga_chunk_seg = NULL;
static zel_mcga_runtime_t g_amulet_scanline_runtime;
static int            g_amulet_scanline_runtime_ready = 0;
static u32            g_amulet_scanline_draws = 0;
static zel_mcga_runtime_t g_credits_scanline_runtime;
static int            g_credits_scanline_runtime_ready = 0;
static u32            g_credits_scanline_draws = 0;
static zel_mcga_runtime_t g_final_scanline_runtime;
static int            g_final_scanline_runtime_ready = 0;
static u32            g_final_scanline_draws = 0;
static u8             *g_title_runtime_seg = NULL;
static u8             *g_title_vga_seg = NULL;
static u8             *g_title_base_work_seg = NULL;
static u8             *g_title_tile_work_seg = NULL;
static u8             *g_title_driver_work_seg = NULL;
static int             g_title_handoff_speech_clear_done = 0;
static u8              g_title_preclear_frame[ZELIARD_FB_SIZE];
static int             g_title_preclear_frame_ready = 0;
static u8              g_title_color_base_frame[ZELIARD_FB_SIZE];
static int             g_title_color_base_frame_ready = 0;
static u8              g_title_complete_frame[ZELIARD_FB_SIZE];
static int             g_title_complete_frame_ready = 0;
static u8             *g_story_anim_seg = NULL;
static const u8       *g_story_anim_source_seg = NULL;
static const char     *g_story_anim_asset = NULL;
static u16             g_story_anim_offset = 0;
static u8             *g_nec_hou_handoff_seg = NULL;
static int             g_nec_hou_handoff_loaded = 0;
static u8             *g_story_script_1 = NULL;
static size_t          g_story_script_1_size = 0;
static u8             *g_story_script_2 = NULL;
static size_t          g_story_script_2_size = 0;
static u8             *g_story_script_3 = NULL;
static size_t          g_story_script_3_size = 0;
static u8             *g_story_script_4 = NULL;
static size_t          g_story_script_4_size = 0;
static u8             *g_story_script_5 = NULL;
static size_t          g_story_script_5_size = 0;
static u8             *g_story_script_6 = NULL;
static size_t          g_story_script_6_size = 0;
static u8             *g_story_script_7 = NULL;
static size_t          g_story_script_7_size = 0;
static u8             *g_story_script_8 = NULL;
static size_t          g_story_script_8_size = 0;
static u8             *g_story_script_9 = NULL;
static size_t          g_story_script_9_size = 0;
static u8             *g_story_script_10 = NULL;
static size_t          g_story_script_10_size = 0;
static u8             *g_story_script_11 = NULL;
static size_t          g_story_script_11_size = 0;
static u8             *g_story_script_12 = NULL;
static size_t          g_story_script_12_size = 0;
static u8             *g_story_script_13 = NULL;
static size_t          g_story_script_13_size = 0;
static u8             *g_story_script_14 = NULL;
static size_t          g_story_script_14_size = 0;
static u8             *g_story_script_15 = NULL;
static size_t          g_story_script_15_size = 0;
static u8             *g_story_script_16 = NULL;
static size_t          g_story_script_16_size = 0;
static u8             *g_story_script_17 = NULL;
static size_t          g_story_script_17_size = 0;
static u8             *g_story_script_18 = NULL;
static size_t          g_story_script_18_size = 0;
static u8             *g_story_script_19 = NULL;
static size_t          g_story_script_19_size = 0;
static u8             *g_story_script_20 = NULL;
static size_t          g_story_script_20_size = 0;
static u8             *g_story_script_21 = NULL;
static size_t          g_story_script_21_size = 0;
static u8             *g_story_script_22 = NULL;
static size_t          g_story_script_22_size = 0;
static zeliard_font_t g_font;
static int            g_font_ready = 0;
enum {
    PAUSE_X = 128,
    PAUSE_Y = 30,
    PAUSE_W = 64,
    PAUSE_H = 16
};
enum {
    SPEED_X = 104,
    SPEED_Y = 70,
    SPEED_W = 120,
    SPEED_H = 40
};
static u8             g_pause_indexed_backup[PAUSE_W * PAUSE_H];
static u8             g_pause_rgb_backup[PAUSE_W * PAUSE_H * 3];
static int            g_pause_rgb_active;
static int            g_pause_overlay_active;
static u8             g_speed_indexed_backup[SPEED_W * SPEED_H];
static u8             g_speed_rgb_backup[SPEED_W * SPEED_H * 3];
static int            g_speed_rgb_active;
static int            g_speed_overlay_active;
static u8             g_speed_text_color;
static int            g_restore_overlay_active;
static palette_color_t g_opening_palette[256];
static palette_color_t g_title_card_palette[256];
static u32            g_elapsed   = 0;
static u32            g_elapsed_ticks = 0;
static u32            g_timer_subtick_accum = 0;
static int            g_done      = 0;
static int            g_dmaou_apparition_mode_for_test = -1;
static int            g_amulet_skip_fade_active = 0;
static u32            g_amulet_skip_base_elapsed = 0;
static u32            g_amulet_skip_fade_elapsed = 0;
static u32            g_amulet_skip_fade_ticks = 0;
static u8             g_amulet_skip_frame[ZELIARD_FB_SIZE];
static int            g_credits_exit_active;
static int            g_credits_exit_released;
static u32            g_credits_exit_clear_ticks;
static u8             g_credits_exit_frame[ZELIARD_FB_SIZE];
static int            g_story_anim_source = 0;
static void          (*g_sound_cue_sink)(u8 cue) = NULL;

typedef struct {
    const u8 *script;
    size_t max_rendered_pc;
} story_sound_progress_t;

static story_sound_progress_t g_story_sound_progress[24];

static int story_sound_is_new_glyph(const u8 *script, size_t pc) {
    story_sound_progress_t *free_slot = NULL;
    for (size_t i = 0; i < sizeof(g_story_sound_progress) /
                            sizeof(g_story_sound_progress[0]); i++) {
        story_sound_progress_t *slot = &g_story_sound_progress[i];
        if (slot->script == script) {
            if (pc <= slot->max_rendered_pc)
                return 0;
            slot->max_rendered_pc = pc;
            return 1;
        }
        if (!slot->script && !free_slot)
            free_slot = slot;
    }
    if (!free_slot)
        return 0;
    free_slot->script = script;
    free_slot->max_rendered_pc = pc;
    return 1;
}

typedef enum {
    OPENING_PHASE_COPYRIGHT_TITLE_CARD = 0,
    OPENING_PHASE_AMULET_ANCIENT_PROLOGUE = 1,
    OPENING_PHASE_STAFF_CREDITS = 2,
    OPENING_PHASE_RAIN_PRINCESS = 3,
    OPENING_PHASE_RAIN_TURNS_TO_SAND = 4,
    OPENING_PHASE_JASHIIN_CURSES_PRINCESS = 5,
    OPENING_PHASE_KING_GRIEF_AND_SPIRIT = 6,
    OPENING_PHASE_DUKE_ARRIVES = 7,
    OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS = 8,
    OPENING_PHASE_JASHIIN_CONFRONTATION = 9,
    OPENING_PHASE_JASHIIN_DEPARTURE = 10,
    OPENING_PHASE_DESTINY_CARD = 11,
    OPENING_PHASE_DONE = 12,
    OPENING_PHASE_NEC_HOU_INTERLUDE = 20,
    OPENING_PHASE_DMAOU_DEMON_INTRO = 21,
    OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION = 22,
} opening_phase_t;

static opening_phase_t g_phase = OPENING_PHASE_COPYRIGHT_TITLE_CARD;

typedef struct {
    opening_phase_t phase;
    const char *manifest_id;
    u32 duration_ticks;
} opening_phase_def_t;

static const opening_phase_def_t OPENING_PHASES[] = {
    { OPENING_PHASE_COPYRIGHT_TITLE_CARD,        "copyright_title_card",             TITLE_CARD_TICKS },
    { OPENING_PHASE_AMULET_ANCIENT_PROLOGUE,     "amulet_ancient_prologue_scroll",  ANCIENT_PROLOGUE_TICKS },
    { OPENING_PHASE_NEC_HOU_INTERLUDE,           "nec_hou_interlude",               NEC_HOU_TRANSITION_TICKS },
    { OPENING_PHASE_DMAOU_DEMON_INTRO,           "dmaou_demon_intro",               DMAOU_DEMON_INTRO_TICKS },
    { OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,   "title_logo_color_rotation",       TITLE_LOGO_HANDOFF_TICKS },
    { OPENING_PHASE_STAFF_CREDITS,               "staff_credits_scroll",            CREDITS_SCROLL_TICKS },
    { OPENING_PHASE_RAIN_PRINCESS,               "rain_princess_story_start",       RAIN_PRINCESS_TICKS },
    { OPENING_PHASE_RAIN_TURNS_TO_SAND,          "rain_turns_to_sand",              RAIN_SAND_TICKS },
    { OPENING_PHASE_JASHIIN_CURSES_PRINCESS,     "jashiin_curses_princess",         JASHIIN_CURSE_TICKS },
    { OPENING_PHASE_KING_GRIEF_AND_SPIRIT,       "king_grief_and_guardian_spirit",  KING_SPIRIT_TICKS },
    { OPENING_PHASE_DUKE_ARRIVES,                "yuu1_jashiin_labyrinths",         DUKE_ARRIVES_TICKS },
    { OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS,    "yuu_split_jashiin_duke_exchange", KING_DUKE_TICKS },
    { OPENING_PHASE_JASHIIN_CONFRONTATION,       "maop_jashiin_speech_and_reveals", JASHIIN_CONFRONT_TICKS },
    { OPENING_PHASE_JASHIIN_DEPARTURE,           "jashiin_departure_and_final_vow", JASHIIN_DEPART_TICKS },
    { OPENING_PHASE_DESTINY_CARD,                "door_of_destiny_final_card",      DESTINY_CARD_TICKS },
};
#define OPENING_PHASE_COUNT ((int)(sizeof(OPENING_PHASES) / sizeof(OPENING_PHASES[0])))

static int g_phase_idx = 0;

/* ---- loaders ------------------------------------------------------------ */
static void load_grp_scene(int idx) {
    cached_image_t    *img = &g_images[idx];
    const scene_def_t *s   = &SCENES[idx];

    size_t file_size = 0;
    u8 *file_data = platform_load_asset(s->asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", s->asset);
        return;
    }

    img->pixels = grp_decode(file_data, file_size, s->rows, s->cl,
                             &img->w, &img->h);
    free(file_data);

    if (img->pixels)
        platform_log("opening: scene %d (%s) %dx%d ok", idx, s->asset, img->w, img->h);
    else
        platform_log("opening: grp_decode failed for %s", s->asset);
}

static void load_gfx_draw_scene(int idx) {
    cached_image_t    *img = &g_images[idx];
    const scene_def_t *s   = &SCENES[idx];

    size_t file_size = 0;
    u8 *file_data = platform_load_asset(s->asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", s->asset);
        return;
    }

    /* fill_buffer decompress (strips SAR header + opcode) */
    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload || payload_size == 0) {
        platform_log("opening: fill_buffer failed for %s", s->asset);
        return;
    }

    /* decompress_image: decode_rle_stream + palette_transform → 2-plane 1bpp */
    size_t planes_size = 0;
    u8 *planes = img_open_decode(payload, payload_size, s->rows, s->cl, &planes_size);
    free(payload);
    if (!planes || planes_size == 0) {
        platform_log("opening: img_open_decode failed for %s", s->asset);
        return;
    }

    /* interleave_gfx_draw (render_plane_a_loop variant) + 8-pass blit */
    img->pixels = grp_decode_planes_gfx_draw(planes, planes_size, s->rows, s->cl,
                                              &img->w, &img->h);
    free(planes);

    if (img->pixels)
        platform_log("opening: scene %d (%s) gfx_draw %dx%d ok",
                     idx, s->asset, img->w, img->h);
    else
        platform_log("opening: grp_decode_planes_gfx_draw failed for %s", s->asset);
}

static void load_gfx_draw_overlay(cached_image_t *img, const scene_def_t *s) {
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(s->asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", s->asset);
        return;
    }

    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload || payload_size == 0) {
        platform_log("opening: fill_buffer failed for %s", s->asset);
        return;
    }

    size_t planes_size = 0;
    u8 *planes = img_open_decode(payload, payload_size, s->rows, s->cl, &planes_size);
    free(payload);
    if (!planes || planes_size == 0) {
        platform_log("opening: img_open_decode failed for %s", s->asset);
        return;
    }

    img->pixels = grp_decode_planes_gfx_draw(planes, planes_size, s->rows, s->cl,
                                             &img->w, &img->h);
    free(planes);

    if (img->pixels)
        platform_log("opening: overlay (%s) gfx_draw %dx%d ok",
                     s->asset, img->w, img->h);
    else
        platform_log("opening: grp_decode_planes_gfx_draw failed for %s", s->asset);
}

static u8 *load_img_open_planes(const char *asset, int rows, int cl,
                                size_t *planes_size);
static void load_story_scene(cached_image_t *img, const scene_def_t *scene);
static void load_story_scene_plane_mode(cached_image_t *img,
                                        const scene_def_t *scene, u8 mode);
static void load_story_scene_gfx_update(cached_image_t *img,
                                        const scene_def_t *scene);
static void load_disp_data_3c1c_scene(cached_image_t *img,
                                      const scene_def_t *scene,
                                      u8 render_mode, u16 bx, u16 cx);
static void load_disp_data_3c1c_overlay(cached_image_t *img,
                                        const scene_def_t *scene,
                                        u8 render_mode, u16 bx, u16 cx);
static u8 *render_disp_data_3c1c_image(const u8 *planes, size_t planes_size,
                                       int rows, int cl, u8 render_mode,
                                       int *out_w, int *out_h);
static u8 *decode_img_open_file_data(const u8 *file_data, size_t file_size,
                                     int rows, int cl, size_t *planes_size);
static void opdmoseg_copy(u8 *seg, int offset, const u8 *src, size_t size);

static void palette_lookup_copy_rect(u8 *dst, size_t dst_size,
                                     const u8 *seg, u16 *src_ofs,
                                     u16 bx, u16 cx, int add_font_row) {
    const int pitch = 0x22;
    const int width = (cx >> 8) & 0xFF;
    const int height = cx & 0xFF;
    const int base = pitch * (bx & 0xFF) + ((bx >> 8) & 0xFF) +
                     (add_font_row ? 0x0EE0 : 0);

    for (int y = 0; y < height; y++) {
        int d = base + y * pitch;
        for (int x = 0; x < width; x++) {
            if ((size_t)(d + x) < dst_size)
                dst[d + x] = seg[*src_ofs];
            *src_ofs = (u16)(*src_ofs + 1u);
        }
    }
}

static u8 *build_dmaou_palette_lookup_scratch(const u8 *planes,
                                              size_t planes_size,
                                              size_t *scratch_size) {
    enum {
        SCENE_DATA_I = 0x97C0,
        SPRITE_BUF_A = 0x9C40,
        SPRITE_BUF_B = 0xA9C0,
        SPRITE_BUF_C = 0xAB40,
        PALETTE_LOOKUP_SCRATCH_SIZE = 0x2CA0
    };

    u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    u8 *scratch = (u8 *)calloc(PALETTE_LOOKUP_SCRATCH_SIZE, 1);
    if (!seg || !scratch) {
        free(seg);
        free(scratch);
        return NULL;
    }

    opdmoseg_copy(seg, SCENE_DATA_I, planes, planes_size);

    u16 si = SPRITE_BUF_C;
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0000, 0x2230, 1);
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0000, 0x2230, 0);
    si = SPRITE_BUF_B;
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0F30, 0x0620, 1);
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0F30, 0x0620, 0);
    si = SPRITE_BUF_A;
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0850, 0x1220, 0);
    palette_lookup_copy_rect(scratch, PALETTE_LOOKUP_SCRATCH_SIZE,
                             seg, &si, 0x0850, 0x1220, 1);

    free(seg);
    *scratch_size = PALETTE_LOOKUP_SCRATCH_SIZE;
    return scratch;
}

static u8 *render_dmaou_palette_lookup_scene(const u8 *planes,
                                             size_t planes_size,
                                             const scene_def_t *s,
                                             int *out_w, int *out_h) {
    size_t scratch_size = 0;
    u8 *scratch = build_dmaou_palette_lookup_scratch(planes, planes_size,
                                                     &scratch_size);
    if (!scratch)
        return NULL;

    u8 *image = zeliard_mcga_render_a_full(scratch, scratch_size,
                                           s->rows, s->cl, out_w, out_h);
    free(scratch);
    return image;
}

static void load_img_open_abc_scene(int idx) {
    cached_image_t    *img = &g_images[idx];
    const scene_def_t *s   = &SCENES[idx];

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(s->asset, s->rows, s->cl, &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        platform_log("opening: img_open_decode failed for %s", s->asset);
        return;
    }

    if (idx == 2) {
        img->pixels = render_dmaou_palette_lookup_scene(planes, planes_size,
                                                        s, &img->w, &img->h);
    } else {
        img->pixels = grp_decode_planes(planes, planes_size, s->rows, s->cl,
                                        &img->w, &img->h);
    }
    free(planes);

    if (img->pixels)
        platform_log("opening: scene %d (%s) img_open_abc %dx%d ok",
                     idx, s->asset, img->w, img->h);
    else
        platform_log("opening: grp_decode_planes failed for %s", s->asset);
}

static u8 *load_img_open_planes(const char *asset, int rows, int cl,
                                size_t *planes_size);
static void load_maop_driver_planes(void);
static void render_story_background(const cached_image_t *background);
static void blit_cached_image(const cached_image_t *img);
static void clear_story_text_area(void);
static void clear_story_image_window(void);
static void clear_story_rect(int x, int y, int w, int h);
static void draw_story_image_bottom_rule(void);
static void render_script_story(const cached_image_t *background,
                                const u8 *script, size_t script_size,
                                u32 elapsed_ms);
static void opdmoseg_copy(u8 *seg, int offset, const u8 *src, size_t size);
static u16 opdmoseg_read16_le(const u8 *seg, int offset);
static void opdmoseg_write16_le(u8 *seg, int offset, u16 value);
static void render_disp_game_rect_from_segment(const u8 *seg,
                                               u16 di, u16 bx, u16 cx);
static void render_disp_script_area_from_segment(const u8 *seg,
                                                 u16 di, u16 bx, u16 cx);
static u8 *render_disp_data_3c1c_image(const u8 *planes,
                                       size_t planes_size,
                                       int rows, int cl,
                                       u8 render_mode,
                                       int *out_w, int *out_h);
static void opdmo_mcga_prepare_maop_script_area(u8 *seg, u16 di);
static void render_maop_reveal_step(u32 elapsed_ms);

static void load_game_frame_overlay(cached_image_t *img, const scene_def_t *s) {
    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(s->asset, s->rows, s->cl, &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    img->x = s->x;
    img->y = s->y;

    int bp = s->rows * s->cl;
    if (planes_size >= (size_t)bp * 3u) {
        u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
        if (seg) {
            opdmoseg_copy(seg, OPDMO_FRAMEBUFFER_A, planes, (size_t)bp * 3u);
            img->pixels = zeliard_mcga_render_three_plane_ab(
                seg, OPDMO_FRAMEBUFFER_A, bp, s->rows, s->cl,
                &img->w, &img->h);
            free(seg);
        }
    } else if (planes_size >= (size_t)bp * 2u) {
        img->pixels = zeliard_mcga_render_two_plane_da(
            planes, planes_size, s->rows, s->cl, &img->w, &img->h);
    } else {
        img->pixels = grp_decode_planes(planes, planes_size, s->rows, s->cl,
                                        &img->w, &img->h);
    }
    free(planes);

    if (img->pixels)
        platform_log("opening: overlay (%s) game-frame %dx%d ok",
                     s->asset, img->w, img->h);
    else
        platform_log("opening: game-frame decode failed for %s", s->asset);
}

static void composite_opaque(cached_image_t *dst, const cached_image_t *src) {
    if (!dst || !dst->pixels || !src || !src->pixels)
        return;

    int ox = src->x - dst->x;
    int oy = src->y - dst->y;
    for (int y = 0; y < src->h; y++) {
        int dy = y + oy;
        if (dy < 0 || dy >= dst->h)
            continue;
        for (int x = 0; x < src->w; x++) {
            int dx = x + ox;
            if (dx < 0 || dx >= dst->w)
                continue;
            dst->pixels[dy * dst->w + dx] = src->pixels[y * src->w + x];
        }
    }
}

static void frame_story_scene_with_waku(cached_image_t *img) {
    if (!img || !img->pixels)
        return;

    cached_image_t frame;
    memset(&frame, 0, sizeof(frame));
    load_game_frame_overlay(&frame, &WAKU_FRAME);
    if (!frame.pixels)
        return;

    composite_opaque(&frame, img);
    free(img->pixels);
    *img = frame;
}

static void clone_framed_story_scene(cached_image_t *dst,
                                     const cached_image_t *src) {
    if (!dst || dst->pixels || !src || !src->pixels)
        return;

    *dst = *src;
    size_t size = (size_t)src->w * (size_t)src->h;
    dst->pixels = (u8 *)malloc(size ? size : 1u);
    if (!dst->pixels) {
        memset(dst, 0, sizeof(*dst));
        return;
    }
    memcpy(dst->pixels, src->pixels, size);
    frame_story_scene_with_waku(dst);
}

/* 100OPDMO:906-913 loads/decompresses OUI only after script 9.  Keep the
 * host cache lazy at that same transition rather than prebuilding it during
 * opening_init. */
static void ensure_oui_scene_loaded(void) {
    if (g_oui_scene_gfx_update_framed.pixels)
        return;
    load_story_scene(&g_oui_scene, &OUI_SCENE);
    load_story_scene_gfx_update(&g_oui_scene_gfx_update, &OUI_SCENE);
    clone_framed_story_scene(&g_oui_scene_gfx_update_framed,
                             &g_oui_scene_gfx_update);
    frame_story_scene_with_waku(&g_oui_scene);
}

static void ensure_sei_scene_loaded(void) {
    if (g_sei_scene_ax5.pixels)
        return;
    load_story_scene(&g_sei_scene, &SEI_SCENE);
    load_story_scene_plane_mode(&g_sei_scene_ax5, &SEI_SCENE, 5);
    frame_story_scene_with_waku(&g_sei_scene);
    frame_story_scene_with_waku(&g_sei_scene_ax5);
}

static void ensure_sei_disp_data_loaded(void) {
    ensure_sei_scene_loaded();
    load_disp_data_3c1c_scene(&g_sei_disp_data_ax5, &SEI_SCENE, 5,
                              0x1610, 0x2468);
    load_disp_data_3c1c_overlay(&g_sei_disp_data_overlay, &SEI_SCENE, 5,
                                0x1610, 0x2468);
}

static void ensure_yuu1_scene_loaded(void) {
    if (g_yuu1_scene_ax7.pixels)
        return;
    load_story_scene(&g_yuu1_scene, &YUU1_SCENE);
    load_story_scene_plane_mode(&g_yuu1_scene_ax7, &YUU1_SCENE, 7);
    frame_story_scene_with_waku(&g_yuu1_scene);
    frame_story_scene_with_waku(&g_yuu1_scene_ax7);
}

static void load_scene(int idx) {
    cached_image_t    *img = &g_images[idx];
    const scene_def_t *s   = &SCENES[idx];
    if (img->pixels) return;

    img->x = s->x;
    img->y = s->y;

    if (s->img_type == IMG_GRP)
        load_grp_scene(idx);
    else if (s->img_type == IMG_GFX_DRAW)
        load_gfx_draw_scene(idx);
    else
        load_img_open_abc_scene(idx);
}

static void load_title_pass_frame(int pass_count) {
    if (pass_count < 0)
        pass_count = 0;
    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    cached_image_t *img = &g_title_pass_frames[pass_count];
    if (img->pixels)
        return;

    const scene_def_t *s = &SCENES[0];
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(s->asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", s->asset);
        return;
    }

    img->x = s->x;
    img->y = s->y;
    img->pixels = grp_decode_partial_passes(file_data, file_size, s->rows, s->cl,
                                            pass_count, &img->w, &img->h);
    free(file_data);

    if (img->pixels)
        platform_log("opening: title pass %d (%s) %dx%d ok",
                     pass_count, s->asset, img->w, img->h);
    else
        platform_log("opening: title pass %d decode failed for %s",
                     pass_count, s->asset);
}

static void load_gfx_draw_scene_pass_frame(cached_image_t *frames, int scene_idx,
                                           int pass_count) {
    if (pass_count < 0)
        pass_count = 0;
    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    cached_image_t *img = &frames[pass_count];
    if (img->pixels)
        return;

    const scene_def_t *s = &SCENES[scene_idx];
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(s->asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", s->asset);
        return;
    }

    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload || payload_size == 0) {
        platform_log("opening: fill_buffer failed for %s", s->asset);
        return;
    }

    size_t planes_size = 0;
    u8 *planes = img_open_decode(payload, payload_size, s->rows, s->cl,
                                 &planes_size);
    free(payload);
    if (!planes || planes_size == 0) {
        platform_log("opening: img_open_decode failed for %s", s->asset);
        return;
    }

    img->x = s->x;
    img->y = s->y;
    img->pixels = grp_decode_planes_gfx_draw_partial_passes(planes, planes_size,
                                                             s->rows, s->cl,
                                                             pass_count,
                                                             &img->w, &img->h);
    free(planes);

    if (img->pixels)
        platform_log("opening: scene %d pass %d (%s) %dx%d ok",
                     scene_idx, pass_count, s->asset, img->w, img->h);
    else
        platform_log("opening: scene %d pass %d decode failed for %s",
                     scene_idx, pass_count, s->asset);
}

static void load_hou_overlay(void) {
    if (g_hou_overlay.pixels) return;
    g_hou_overlay.x = HOU_OVERLAY.x;
    g_hou_overlay.y = HOU_OVERLAY.y;

    size_t file_size = 0;
    u8 *file_data = platform_load_asset(HOU_OVERLAY.asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", HOU_OVERLAY.asset);
        return;
    }

    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload || payload_size == 0) {
        platform_log("opening: fill_buffer failed for %s", HOU_OVERLAY.asset);
        return;
    }

    free(g_hou_planes);
    g_hou_planes = img_open_decode(payload, payload_size,
                                   HOU_OVERLAY.rows, HOU_OVERLAY.cl,
                                   &g_hou_planes_size);
    free(payload);
    if (!g_hou_planes || g_hou_planes_size == 0) {
        platform_log("opening: img_open_decode failed for %s", HOU_OVERLAY.asset);
        return;
    }

    g_hou_overlay.pixels = grp_decode_planes_gfx_draw(
        g_hou_planes, g_hou_planes_size, HOU_OVERLAY.rows, HOU_OVERLAY.cl,
        &g_hou_overlay.w, &g_hou_overlay.h);

    if (g_hou_overlay.pixels)
        platform_log("opening: overlay (%s) gfx_draw %dx%d ok",
                     HOU_OVERLAY.asset, g_hou_overlay.w, g_hou_overlay.h);
    else
        platform_log("opening: grp_decode_planes_gfx_draw failed for %s",
                     HOU_OVERLAY.asset);
}

static void load_ame_scene(void) {
    if (g_ame_scene.pixels) return;

    cached_image_t frame;
    cached_image_t rain;
    memset(&frame, 0, sizeof(frame));
    memset(&rain, 0, sizeof(rain));

    load_game_frame_overlay(&frame, &WAKU_FRAME);
    if (g_ame_render_mode_for_test >= 0) {
        size_t planes_size = 0;
        u8 *planes = load_img_open_planes(AME_SCENE.asset, AME_SCENE.rows,
                                          AME_SCENE.cl, &planes_size);
        if (planes && planes_size) {
            rain.pixels = render_disp_data_3c1c_image(
                planes, planes_size, AME_SCENE.rows, AME_SCENE.cl,
                (u8)g_ame_render_mode_for_test, &rain.w, &rain.h);
            rain.x = AME_SCENE.x;
            rain.y = AME_SCENE.y;
        }
        free(planes);
    } else {
        load_game_frame_overlay(&rain, &AME_SCENE);
    }

    if (frame.pixels) {
        g_ame_scene = frame;
        composite_opaque(&g_ame_scene, &rain);
        free(rain.pixels);
        return;
    }

    g_ame_scene = rain;
}

static void load_story_scene(cached_image_t *img, const scene_def_t *scene) {
    if (img->pixels) return;
    img->x = scene->x;
    img->y = scene->y;
    if (scene->img_type == IMG_GRP)
        load_game_frame_overlay(img, scene);
    else
        load_gfx_draw_overlay(img, scene);
}

static void load_story_scene_gfx_update(cached_image_t *img,
                                        const scene_def_t *scene) {
    if (!img || img->pixels)
        return;
    img->x = scene->x;
    img->y = scene->y;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(scene->asset, scene->rows, scene->cl,
                                      &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (seg) {
        opdmoseg_copy(seg, 0, planes, planes_size);
        img->pixels = zeliard_mcga_render_three_plane_ab_interleaved(
            seg, 0, scene->rows * scene->cl, scene->rows, scene->cl,
            &img->w, &img->h);
        free(seg);
    }
    free(planes);

    if (img->pixels)
        platform_log("opening: scene (%s) gfx_update 3088h AL=00 %dx%d at %d,%d ok",
                     scene->asset, img->w, img->h, img->x, img->y);
}

static void load_story_scene_plane_mode(cached_image_t *img,
                                        const scene_def_t *scene,
                                        u8 render_mode) {
    if (img->pixels)
        return;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(scene->asset, scene->rows, scene->cl,
                                      &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    img->pixels = render_disp_data_3c1c_image(
        planes, planes_size, scene->rows, scene->cl, render_mode,
        &img->w, &img->h);
    free(planes);
    img->x = 16;
    img->y = 16;

    if (img->pixels)
        platform_log("opening: scene (%s) disp_game 33B7h AL=%02X %dx%d at %d,%d ok",
                     scene->asset, render_mode, img->w, img->h,
                     img->x, img->y);
    else
        platform_log("opening: scene (%s) disp_game 33B7h AL=%02X failed",
                     scene->asset, render_mode);
}

static u16 opdmoseg_read16_le(const u8 *seg, int offset) {
    int lo = offset & 0xFFFF;
    int hi = (offset + 1) & 0xFFFF;
    return (u16)(seg[lo] | ((u16)seg[hi] << 8));
}

static void opdmoseg_write16_le(u8 *seg, int offset, u16 value) {
    int lo = offset & 0xFFFF;
    int hi = (offset + 1) & 0xFFFF;
    seg[lo] = (u8)(value & 0xFFu);
    seg[hi] = (u8)(value >> 8);
}

static void opdmo_cycle_palette_colors_to(const u8 *source, u8 *dest,
                                          u16 source_si, u16 dest_di) {
    u16 si = source_si;
    u16 di = dest_di;

    for (int row = 0; row < 0x30; row++) {
        for (int col = 0; col < 0x22; col++) {
            u8 ah = source[(OPDMO_FONT_PLANE_A + si) & 0xFFFF];
            u8 al = source[si & 0xFFFF];
            u8 bh = (u8)(~al & ah);
            ah ^= bh;
            dest[di & 0xFFFF] = al;
            dest[(OPDMO_FONT_PLANE_A + di) & 0xFFFF] = bh;
            dest[(0x0CC0 + di) & 0xFFFF] = ah;
            si++;
            di++;
        }
    }
}

static void opdmo_cycle_palette_colors(u8 *seg, u16 source_si, u16 dest_di) {
    opdmo_cycle_palette_colors_to(seg, seg, source_si, dest_di);
}

static uint64_t opdmo_fnv1a64(const u8 *data, size_t size) {
    uint64_t hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; i++) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

uint64_t opening_debug_busy_wait_delay_fixture_hash(u8 al) {
    u8 *seg = (u8 *)malloc(OPDMO_SEG_SIZE);
    if (!seg)
        return 0;
    for (size_t i = 0; i < OPDMO_SEG_SIZE; i++)
        seg[i] = (u8)((i * 37u + 11u) & 0xFFu);

    /* 100OPDMO:busy_wait_delay: AX = AL * 0CC0h + AB40h;
     * DS=game segment, ES=game+2000h, DI=0.  The fixture uses one 64K
     * segment because its source block and destination planes do not overlap. */
    opdmo_cycle_palette_colors(seg, (u16)(0xAB40u + (u16)al * 0x0CC0u), 0);
    uint64_t hash = opdmo_fnv1a64(seg, OPDMO_SEG_SIZE);
    free(seg);
    return hash;
}

static void opdmo_apply_palette_blend_from(u8 *seg, const u8 *source,
                                           u16 source_si) {
    u16 si = source_si;
    u16 di = OPDMO_TEMP_DECODE_BUF;

    for (int row = 0; row < 0x30; row++) {
        u16 row_di = di;
        for (int col = 0; col < 0x11; col++) {
            u16 ax = opdmoseg_read16_le(seg, di);
            u16 bx = opdmoseg_read16_le(seg, OPDMO_PLANE_DATA_A + di);
            ax = (u16)~ax;
            bx = (u16)~bx;
            ax = (u16)(ax & bx);
            ax = (u16)(ax & opdmoseg_read16_le(seg, OPDMO_PLANE_DATA_B + di));

            u16 dx = (u16)~ax;
            bx = ax;

            u16 dst = opdmoseg_read16_le(seg, di);
            opdmoseg_write16_le(seg, di,
                (u16)((dst & dx) |
                      (ax & opdmoseg_read16_le(source, si))));

            dst = opdmoseg_read16_le(seg, OPDMO_PLANE_DATA_A + di);
            opdmoseg_write16_le(seg, OPDMO_PLANE_DATA_A + di,
                (u16)((dst & dx) |
                      (bx & opdmoseg_read16_le(source, OPDMO_FONT_PLANE_A + si))));

            dst = opdmoseg_read16_le(seg, OPDMO_PLANE_DATA_B + di);
            opdmoseg_write16_le(seg, OPDMO_PLANE_DATA_B + di,
                (u16)((dst & dx) |
                      (bx & opdmoseg_read16_le(source, 0x0CC0 + si))));

            di = (u16)(di + 2);
            si = (u16)(si + 2);
        }
        di = (u16)(row_di + 0x48);
    }
}

static void load_hime_dmaou_blend_scene(void) {
    if (g_hime_dmaou_blend_scene.pixels)
        return;

    u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!seg)
        return;

    u8 *ext_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!ext_seg) {
        free(seg);
        return;
    }

    size_t hime_size = 0;
    u8 *hime = load_img_open_planes(HIME_SCENE.asset, HIME_SCENE.rows,
                                    HIME_SCENE.cl, &hime_size);
    if (!hime || hime_size == 0) {
        free(hime);
        free(ext_seg);
        free(seg);
        return;
    }
    opdmoseg_copy(seg, OPDMO_FRAMEBUFFER_A, hime, hime_size);
    free(hime);

    size_t dmaou_size = 0;
    u8 *dmaou = load_img_open_planes("dmaou.grp", 0x22, 0x70,
                                     &dmaou_size);
    if (!dmaou || dmaou_size == 0) {
        free(dmaou);
        free(ext_seg);
        free(seg);
        return;
    }
    opdmoseg_copy(seg, OPDMO_SCENE_DATA_I, dmaou, dmaou_size);
    opdmoseg_copy(ext_seg, 0, dmaou, dmaou_size);
    free(dmaou);

    /* 100OPDMO:858-861: busy_wait_delay reads DS=game and writes the
     * transformed planes to ES=game+2000h. apply_palette_blend then reads
     * that external scratch while it updates the game segment. */
    opdmo_cycle_palette_colors_to(seg, ext_seg, 0xAB40 + 4 * 0x0CC0, 0);
    opdmo_apply_palette_blend_from(seg, ext_seg, 0);

    g_hime_dmaou_blend_scene.pixels = zeliard_mcga_render_three_plane_ab(
        seg, OPDMO_FRAMEBUFFER_A, HIME_SCENE.rows * HIME_SCENE.cl,
        HIME_SCENE.rows, HIME_SCENE.cl,
        &g_hime_dmaou_blend_scene.w, &g_hime_dmaou_blend_scene.h);

    g_hime_dmaou_blend_scene.x = HIME_SCENE.x;
    g_hime_dmaou_blend_scene.y = HIME_SCENE.y;
    g_hime_dmaou_blend_seg = seg;
    g_hime_dmaou_ext_seg = ext_seg;
    if (g_hime_dmaou_blend_scene.pixels) {
        frame_story_scene_with_waku(&g_hime_dmaou_blend_scene);
        platform_log("opening: hime/dmaou apply_palette_blend scene %dx%d ok",
                     g_hime_dmaou_blend_scene.w,
                     g_hime_dmaou_blend_scene.h);
    }
}

static void load_dmaou_prelude_game_segment(void) {
    if (g_dmaou_prelude_game_seg)
        return;

    size_t dmaou_size = 0;
    u8 *dmaou = load_img_open_planes("dmaou.grp", 0x22, 0x70,
                                     &dmaou_size);
    if (!dmaou || dmaou_size == 0) {
        free(dmaou);
        return;
    }

    g_dmaou_prelude_game_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    g_dmaou_prelude_scratch_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (g_dmaou_prelude_game_seg)
        opdmoseg_copy(g_dmaou_prelude_game_seg, OPDMO_SCENE_DATA_I,
                      dmaou, dmaou_size);
    if (g_dmaou_prelude_scratch_seg) {
        size_t scratch_size = 0;
        u8 *scratch = build_dmaou_palette_lookup_scratch(
            dmaou, dmaou_size, &scratch_size);
        if (scratch) {
            if (scratch_size > OPDMO_SEG_SIZE)
                scratch_size = OPDMO_SEG_SIZE;
            memcpy(g_dmaou_prelude_scratch_seg, scratch, scratch_size);
            free(scratch);
        }
    }
    free(dmaou);
}

uint64_t opening_debug_dmaou_prelude_segment_hash(size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;
    load_dmaou_prelude_game_segment();
    if (!g_dmaou_prelude_game_seg)
        return 0;
    if (nonzero) {
        for (size_t i = 0; i < OPDMO_SEG_SIZE; i++)
            if (g_dmaou_prelude_game_seg[i])
                (*nonzero)++;
    }
    return opdmo_fnv1a64(g_dmaou_prelude_game_seg, OPDMO_SEG_SIZE);
}

uint64_t opening_debug_hime_dmaou_blend_ranges_hash(size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;

    load_hime_dmaou_blend_scene();
    if (!g_hime_dmaou_blend_seg)
        return 0;

    const u16 ranges[] = {
        OPDMO_TEMP_DECODE_BUF,
        (u16)(OPDMO_PLANE_DATA_A + OPDMO_TEMP_DECODE_BUF),
        (u16)(OPDMO_PLANE_DATA_B + OPDMO_TEMP_DECODE_BUF),
    };
    uint64_t hash = 0xCBF29CE484222325ULL;
    for (size_t range = 0; range < sizeof(ranges) / sizeof(ranges[0]); range++) {
        for (u16 i = 0; i < 0x1600u; i++) {
            u8 value = g_hime_dmaou_blend_seg[(u16)(ranges[range] + i)];
            hash ^= value;
            hash *= 0x100000001B3ULL;
            if (nonzero && value)
                (*nonzero)++;
        }
    }
    return hash;
}

uint64_t opening_debug_hime_dmaou_blend_frame_hash(size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;

    load_hime_dmaou_blend_scene();
    if (!g_hime_dmaou_blend_seg)
        return 0;

    int w = 0;
    int h = 0;
    u8 *image = zeliard_mcga_render_three_plane_ab(
        g_hime_dmaou_blend_seg, OPDMO_FRAMEBUFFER_A,
        HIME_SCENE.rows * HIME_SCENE.cl, HIME_SCENE.rows, HIME_SCENE.cl,
        &w, &h);
    if (!image)
        return 0;

    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++)
            framebuf_set_pixel(HIME_SCENE.x + x, HIME_SCENE.y + y,
                               image[(size_t)y * (size_t)w + (size_t)x]);
    }
    free(image);
    if (nonzero) {
        for (size_t i = 0; i < ZELIARD_FB_SIZE; i++)
            if (g_framebuf[i])
                (*nonzero)++;
    }
    return opdmo_fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
}

uint64_t opening_debug_hime_dmaou_ext_hash(size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;

    load_hime_dmaou_blend_scene();
    if (!g_hime_dmaou_ext_seg)
        return 0;

    if (nonzero) {
        for (size_t i = 0; i < OPDMO_SEG_SIZE; i++)
            if (g_hime_dmaou_ext_seg[i])
                (*nonzero)++;
    }
    return opdmo_fnv1a64(g_hime_dmaou_ext_seg, OPDMO_SEG_SIZE);
}

uint64_t opening_debug_dmaou_apparition_frame_hash(size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;

    load_hime_dmaou_blend_scene();
    if (!g_hime_dmaou_ext_seg)
        return 0;

    int w = 0;
    int h = 0;
    u8 *image = render_disp_data_3c1c_image(
        g_hime_dmaou_ext_seg, OPDMO_SEG_SIZE,
        DMAOU_APPARITION.rows, DMAOU_APPARITION.cl, 7, &w, &h);
    if (!image)
        return 0;

    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++)
            framebuf_set_pixel(DMAOU_APPARITION.x + x, DMAOU_APPARITION.y + y,
                               image[(size_t)y * (size_t)w + (size_t)x]);
    }
    free(image);
    if (nonzero) {
        for (size_t i = 0; i < ZELIARD_FB_SIZE; i++)
            if (g_framebuf[i])
                (*nonzero)++;
    }
    return opdmo_fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
}

static u8 *opdmo_dmaou_post_busy_external(u8 al) {
    load_hime_dmaou_blend_scene();
    if (!g_hime_dmaou_blend_seg || !g_hime_dmaou_ext_seg)
        return NULL;

    u8 *ext = (u8 *)malloc(OPDMO_SEG_SIZE);
    if (!ext)
        return NULL;
    memcpy(ext, g_hime_dmaou_ext_seg, OPDMO_SEG_SIZE);
    opdmo_cycle_palette_colors_to(g_hime_dmaou_blend_seg, ext,
                                  (u16)(0xAB40u + (u16)al * 0x0CC0u), 0);
    return ext;
}

uint64_t opening_debug_dmaou_post_busy_ext_hash(u8 al, size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;
    u8 *ext = opdmo_dmaou_post_busy_external(al);
    if (!ext)
        return 0;
    if (nonzero) {
        for (size_t i = 0; i < OPDMO_SEG_SIZE; i++)
            if (ext[i])
                (*nonzero)++;
    }
    uint64_t hash = opdmo_fnv1a64(ext, OPDMO_SEG_SIZE);
    free(ext);
    return hash;
}

uint64_t opening_debug_dmaou_post_busy_frame_hash(u8 al, size_t *nonzero) {
    if (nonzero)
        *nonzero = 0;
    u8 *ext = opdmo_dmaou_post_busy_external(al);
    if (!ext)
        return 0;

    int w = 0;
    int h = 0;
    u8 *image = zeliard_mcga_render_three_plane_ab(
        ext, 0, 0x22 * 0x30, 0x22, 0x30, &w, &h);
    free(ext);
    if (!image)
        return 0;

    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++)
            framebuf_set_pixel(DMAOU_APPARITION.x + x, DMAOU_APPARITION.y + y,
                               image[(size_t)y * (size_t)w + (size_t)x]);
    }
    free(image);
    if (nonzero) {
        for (size_t i = 0; i < ZELIARD_FB_SIZE; i++)
            if (g_framebuf[i])
                (*nonzero)++;
    }
    return opdmo_fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
}

static u8 *load_img_open_planes(const char *asset, int rows, int cl,
                                size_t *planes_size);
static void opdmoseg_copy(u8 *seg, int offset, const u8 *src, size_t size);

static void load_yuu_anim_segment(void) {
    if (g_yuu_anim_seg)
        return;

    g_yuu_anim_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_yuu_anim_seg)
        return;

    size_t yuup_size = 0;
    u8 *yuup = load_img_open_planes("yuup.grp", YUUP_SCENE.rows, YUUP_SCENE.cl,
                                    &yuup_size);
    if (yuup) {
        opdmoseg_copy(g_yuu_anim_seg, OPDMO_FRAMEBUFFER_A, yuup, yuup_size);
        free(yuup);
    }

    size_t oup_size = 0;
    u8 *oup = load_img_open_planes("oup.grp", OUP_SCENE.rows, OUP_SCENE.cl,
                                   &oup_size);
    if (oup) {
        opdmoseg_copy(g_yuu_anim_seg, 0x8000, oup, oup_size);
        free(oup);
    }
}

static void ZEL_UNUSED load_opdmo_chunk_segment(void) {
    if (g_opdmo_chunk_seg)
        return;

    size_t chunk_size = 0;
    u8 *chunk = platform_load_asset("100opdmo.bin", &chunk_size);
    if (!chunk || chunk_size == 0) {
        free(chunk);
        platform_log("opening: 100opdmo.bin unavailable for story portraits");
        return;
    }

    g_opdmo_chunk_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_opdmo_chunk_seg) {
        free(chunk);
        return;
    }

    opdmoseg_copy(g_opdmo_chunk_seg, 0x5FFC, chunk, chunk_size);
    free(chunk);
}

static void ZEL_UNUSED load_gdmcga_chunk_segment(void) {
    if (g_gdmcga_chunk_seg)
        return;

    size_t chunk_size = 0;
    u8 *chunk = platform_load_asset("105GDMCA.bin", &chunk_size);
    if (!chunk || chunk_size == 0)
        chunk = platform_load_asset("105gdmca.bin", &chunk_size);
    if (!chunk || chunk_size == 0) {
        free(chunk);
        platform_log("opening: 105GDMCA.bin unavailable for MCGA palette regs");
        return;
    }

    g_gdmcga_chunk_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_gdmcga_chunk_seg) {
        free(chunk);
        return;
    }

    opdmoseg_copy(g_gdmcga_chunk_seg, 0x2FFC, chunk, chunk_size);
    free(chunk);
}

static void load_title_runtime_segment(void) {
    if (g_title_runtime_seg)
        return;

    g_title_runtime_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_runtime_seg)
        return;

    /* zeliad.asm stores game_entry_seg + 1000h in gvar_game_seg.  Driver,
     * OPDMO, font, and loader binaries remain in CS and must not seed this
     * separate game-data segment. */
}

static const u8 *opdmo_mcga_palette_regs_ax(u16 ax, u8 scratch[48]) {
    enum {
        MCGA_PAL_R_REG = 0x4289,
        MCGA_PAL_REG_SIZE = 0x30,
    };
    u16 offset = (u16)(MCGA_PAL_R_REG + ax * MCGA_PAL_REG_SIZE);
    /* write_palette_byte_mcga (105GDMCA:3A02) reads its palette register
     * table from the loaded graphics-driver segment.  The OPDMO title
     * helpers intentionally use game:4000 as tile scratch, which overlaps
     * 4289h in the composite title work segment; that scratch must never
     * become the palette oracle. */
    if (g_gdmcga_chunk_seg) {
        if (offset <= (u16)(0x10000 - MCGA_PAL_REG_SIZE))
            return &g_gdmcga_chunk_seg[offset];
        for (u16 i = 0; i < MCGA_PAL_REG_SIZE; i++)
            scratch[i] = g_gdmcga_chunk_seg[(u16)(offset + i)];
        return scratch;
    }
    if (g_title_runtime_seg) {
        if (offset <= (u16)(0x10000 - MCGA_PAL_REG_SIZE))
            return &g_title_runtime_seg[offset];
        for (u16 i = 0; i < MCGA_PAL_REG_SIZE; i++)
            scratch[i] = g_title_runtime_seg[(u16)(offset + i)];
        return scratch;
    }
    return NULL;
}

static void opdmo_disp_set_mcga_ax(u16 ax) {
    /* 100OPDMO call word ptr cs:[gfx_palette_fn], AX preserved. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_GFX_PALETTE, ax, 0, 0, 0, 0, 0);
    u8 scratch[48];
    const u8 *regs = opdmo_mcga_palette_regs_ax(ax, scratch);
    if (regs) {
        palette_set_opdmo_mcga_from_regs(regs);
        return;
    }
    if (ax < 10) {
        palette_set_opdmo_mcga(ax);
        return;
    }
    static const u8 zero_regs[48] = {0};
    palette_set_opdmo_mcga_from_regs(zero_regs);
}

static void clear_story_anim_segment(void) {
    free(g_story_anim_seg);
    g_story_anim_seg = NULL;
    g_story_anim_source_seg = NULL;
    g_story_anim_asset = NULL;
    g_story_anim_offset = 0;
}

static void ZEL_UNUSED load_story_anim_segment_from_scene(const scene_def_t *scene,
                                                          u16 offset) {
    if (!scene || !scene->asset)
        return;
    if (g_story_anim_seg && g_story_anim_asset == scene->asset &&
        g_story_anim_offset == offset)
        return;

    clear_story_anim_segment();
    g_story_anim_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_story_anim_seg)
        return;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(scene->asset, scene->rows, scene->cl,
                                      &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        clear_story_anim_segment();
        platform_log("opening: story anim segment load failed for %s",
                     scene->asset);
        return;
    }

    opdmoseg_copy(g_story_anim_seg, offset, planes, planes_size);
    free(planes);
    g_story_anim_asset = scene->asset;
    g_story_anim_offset = offset;
}

static void load_nec_hou_handoff_segment(void) {
    if (g_nec_hou_handoff_loaded)
        return;
    if (!g_nec_hou_handoff_seg)
        g_nec_hou_handoff_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_nec_hou_handoff_seg)
        return;

    memset(g_nec_hou_handoff_seg, 0, OPDMO_SEG_SIZE);

    size_t nec_size = 0;
    u8 *nec = load_img_open_planes("nec.grp", 44, 104, &nec_size);
    if (nec) {
        opdmoseg_copy(g_nec_hou_handoff_seg, OPDMO_FRAMEBUFFER_A, nec, nec_size);
        free(nec);
    }

    size_t hou_size = 0;
    u8 *hou = load_img_open_planes("hou.grp", 16, 64, &hou_size);
    if (hou) {
        opdmoseg_copy(g_nec_hou_handoff_seg, 0x9000, hou, hou_size);
        free(hou);
    }

    g_nec_hou_handoff_loaded = nec_size == 16896u &&
                               hou_size == 2560u;
    if (!g_nec_hou_handoff_loaded)
        platform_log("opening: NEC/HOU handoff segment incomplete nec=%llu hou=%llu",
                     (unsigned long long)nec_size,
                     (unsigned long long)hou_size);
}

static u8 *decode_img_open_file_data(const u8 *file_data, size_t file_size,
                                     int rows, int cl, size_t *planes_size) {
    if (!file_data || !planes_size)
        return NULL;
    size_t payload_size = 0;
    u8 *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    if (!payload || payload_size == 0) {
        *planes_size = 0;
        return NULL;
    }

    u8 *planes = NULL;
    planes = img_open_decode(payload, payload_size, rows, cl, planes_size);
    free(payload);
    return planes;
}

static u8 *load_img_open_planes(const char *asset, int rows, int cl,
                                size_t *planes_size) {
    size_t file_size = 0;
    u8 *file_data = platform_load_asset(asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing asset %s", asset);
        *planes_size = 0;
        return NULL;
    }
    u8 *planes = decode_img_open_file_data(file_data, file_size, rows, cl,
                                           planes_size);
    free(file_data);
    if (!planes || *planes_size == 0)
        platform_log("opening: img_open_decode failed for %s", asset);
    return planes;
}

static const u8 MCGA_DRIVER_3A5F[] = {
    0x00,0x00,0x00,0x03,0x80,0x80,0x85,0x84,0x03,0x03,0x03,0x03,0x84,0x84,0x84,0x84,
    0x03,0x03,0x03,0x03,0x84,0x84,0x84,0xD4,0x00,0x00,0x00,0xFF,0x00,0x00,0x55,0x00,
    0x00,0x00,0x01,0xFF,0x02,0x02,0x56,0x00,0x00,0x00,0x00,0xFF,0x40,0x40,0x55,0x00,
    0x00,0x00,0x00,0xC0,0x01,0x01,0x61,0x21,0xC0,0xC0,0xC0,0xC0,0x21,0x21,0x21,0x21,
    0xC0,0xC0,0xC0,0xC0,0x21,0x21,0x21,0x21,0xC0,0xE0,0xE0,0xE0,0x2B,0x01,0x01,0x01,
    0x03,0x03,0x03,0x03,0xD4,0x84,0x84,0x84,0x03,0x03,0x03,0x03,0x84,0x84,0x84,0x84,
    0x03,0x02,0x00,0x00,0x84,0x85,0x80,0x80,0xFF,0xAA,0x00,0x00,0x00,0x55,0x00,0x00,
    0xFF,0xA8,0x00,0x00,0x00,0x56,0x02,0x02,0xFF,0xFF,0x00,0x00,0x00,0x55,0x40,0x40,
    0xC0,0xC0,0xC0,0xC0,0x2B,0x21,0x21,0x21,0xC0,0xC0,0xC0,0xC0,0x21,0x21,0x21,0x21,
    0xC0,0x80,0x00,0x00,0x21,0x61,0x01,0x01,0x00,0x00,0xFF,0xFF,0x00,0x00,0x00,0x00,
    0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x07,0x07,0x07,0x80,0x80,0x80,0x80,
    0xE0,0xE0,0xE0,0xE0,0x01,0x01,0x01,0x01,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,
    0x01,0x02,0x03,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,
    0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x0B,0x0C,0x0D,0x00,0x0E,0x0F,0x15,0x15,0x15,
    0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,
    0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,
    0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,
    0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x10,
    0x0E,0x13,0x00,0x12,0x11,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,
    0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x0A,0x09,0x08,0x07,0x00,0x04,0x06,0x14,
    0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,
    0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,
    0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,
    0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,
    0x14,0x05,0x04,0x00,0x18,0x46,0x18,0x45,0x17,0x44,0x16,0x43,0x15,0x42,0x14,0x41,
    0x13,0x40,0x12,0x3F,0x11,0x3E,0x10,0x3D,0x0F,0x3C,0x0E,0x3B,0x0D,0x3A,0x0C,0x39,
    0x0B,0x38,0x0A,0x37,0x09,0x36,0x08,0x35,0x07,0x34,0x06,0x33,0x05,0x32,0x04,0x31,
    0x03,0x30,0x02,0x2F,0x01,0x2E,0x00,0x02,0x55,0x03,0xFF,0x01,0x55,0x1E,0x2E,0xA2,
    0x08,0x45,0x53,0x51,0x8A,0xC5,0xF6,0xE1,0x8B,0xE8,0x06,0x1F,0x8B,0xF7,0x8C,0xC8,
    0x05,0x00,0x30,0x8E,0xC0,0xBF,0x00,0x00,0x2E,0xC7,0x06,0x01,0x45,0x00,0x00,0x2E,
    0xC7,0x06,0xFB,0x44,0x00,0x00,0x2E,0xC7,0x06,0xFD,0x44,0x00,0x00,0x2E,0xC7,0x06,
    0xFF,0x44,0x00,0x00,0x8B,0xCD,0xD1,0xE9,0x56,0x2E,0xF6,0x06,0x08,0x45,0x01,0x74,
    0x0A,0x8B,0x04,0x86,0xE0,0x2E,0xA3,0xFB,0x44,0x03,0xF5,0x2E,0xF6,0x06,0x08,0x45,
    0x02,0x74,0x0A,0x8B,0x04,0x86,0xE0,0x2E,0xA3,0xFD,0x44,0x03,0xF5,0x2E,0xF6,0x06,
    0x08,0x45,0x04,0x74,0x08,0x8B,0x04,0x86,0xE0,0x2E,0xA3,0xFF,0x44,0xE8,0xDA,0x07,
    0xAB,0xE8,0xD6,0x07,0xAB,0xE8,0xD2,0x07,0xAB,0xE8,0xCE,0x07,0xAB,0x5E,0x46,0x46,
    0xE2,0xB6,0x59,0x5B,0x81,0xEB,0x10,0x04,0x2E,0xC6,0x06,0x06,0x45,0x00,0x2E,0xC6
};

static u8 mcga_driver_byte(u16 addr) {
    enum { MCGA_DRIVER_SLICE_BASE = 0x3A5F };
    if (addr < MCGA_DRIVER_SLICE_BASE)
        return 0;
    size_t offset = (size_t)(addr - MCGA_DRIVER_SLICE_BASE);
    return offset < sizeof(MCGA_DRIVER_3A5F) ? MCGA_DRIVER_3A5F[offset] : 0;
}

static void ZEL_UNUSED load_dmaou_apparition_overlay(void) {
    if (g_dmaou_apparition_overlay.pixels)
        return;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(DMAOU_APPARITION.asset,
                                      DMAOU_APPARITION.rows,
                                      DMAOU_APPARITION.cl,
                                      &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    size_t interleaved_size = 0;
    u8 *interleaved = zeliard_mcga_render_plane_select_interleaved(
        planes, planes_size, DMAOU_APPARITION.rows, DMAOU_APPARITION.cl, 7,
        &interleaved_size);
    free(planes);
    if (!interleaved)
        return;

    if (interleaved_size < (size_t)DMAOU_APPARITION.rows * 4u *
                               (size_t)DMAOU_APPARITION.cl) {
        free(interleaved);
        return;
    }
    g_dmaou_apparition_overlay.pixels = interleaved;
    g_dmaou_apparition_overlay.w = DMAOU_APPARITION.rows * 4;
    g_dmaou_apparition_overlay.h = DMAOU_APPARITION.cl;
    g_dmaou_apparition_overlay.x = DMAOU_APPARITION.x;
    g_dmaou_apparition_overlay.y = DMAOU_APPARITION.y;
    if (g_dmaou_apparition_overlay.pixels)
        platform_log("opening: apparition overlay (dmaou.grp) %dx%d ok",
                     g_dmaou_apparition_overlay.w,
                     g_dmaou_apparition_overlay.h);
}

static u8 *render_disp_data_3c1c_image(const u8 *planes,
                                       size_t planes_size,
                                       int rows, int cl,
                                       u8 render_mode,
                                       int *out_w, int *out_h) {
    size_t interleaved_size = 0;
    u8 *image = zeliard_mcga_render_plane_select_interleaved(
        planes, planes_size, rows, cl, render_mode, &interleaved_size);
    if (!image)
        return NULL;

    *out_w = rows * 4;
    *out_h = cl;
    return image;
}

static void ZEL_UNUSED load_dmaou_apparition_disp_data_3c1c(void) {
    if (g_dmaou_apparition_overlay.pixels)
        return;

    if (g_hime_dmaou_ext_seg) {
        u8 render_mode = (g_dmaou_apparition_mode_for_test >= 0)
            ? (u8)g_dmaou_apparition_mode_for_test
            : 7u;
        g_dmaou_apparition_overlay.pixels = render_disp_data_3c1c_image(
            g_hime_dmaou_ext_seg, OPDMO_SEG_SIZE,
            DMAOU_APPARITION.rows, DMAOU_APPARITION.cl,
            render_mode, &g_dmaou_apparition_overlay.w,
            &g_dmaou_apparition_overlay.h);
        g_dmaou_apparition_overlay.x = DMAOU_APPARITION.x;
        g_dmaou_apparition_overlay.y = DMAOU_APPARITION.y;
        if (g_dmaou_apparition_overlay.pixels) {
            platform_log("opening: apparition disp_data_7420 scratch %dx%d ok",
                         g_dmaou_apparition_overlay.w,
                         g_dmaou_apparition_overlay.h);
            return;
        }
    }

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(SCENES[2].asset,
                                      SCENES[2].rows,
                                      SCENES[2].cl,
                                      &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    size_t scratch_size = 0;
    u8 *scratch = build_dmaou_palette_lookup_scratch(planes, planes_size,
                                                     &scratch_size);
    free(planes);
    if (!scratch || scratch_size == 0) {
        free(scratch);
        return;
    }

    u8 render_mode = (g_dmaou_apparition_mode_for_test >= 0)
        ? (u8)g_dmaou_apparition_mode_for_test
        : 7u;
    g_dmaou_apparition_overlay.pixels = render_disp_data_3c1c_image(
        scratch, scratch_size, DMAOU_APPARITION.rows, DMAOU_APPARITION.cl,
        render_mode, &g_dmaou_apparition_overlay.w,
        &g_dmaou_apparition_overlay.h);
    free(scratch);

    g_dmaou_apparition_overlay.x = DMAOU_APPARITION.x;
    g_dmaou_apparition_overlay.y = DMAOU_APPARITION.y;
    if (g_dmaou_apparition_overlay.pixels)
        platform_log("opening: apparition disp_data_3c1c %dx%d ok",
                     g_dmaou_apparition_overlay.w,
                     g_dmaou_apparition_overlay.h);
}

static void load_disp_data_3c1c_scene(cached_image_t *img,
                                      const scene_def_t *scene,
                                      u8 render_mode,
                                      u16 bx,
                                      u16 cx) {
    if (!img || img->pixels)
        return;

    const int rows = (cx >> 8) & 0xFF;
    const int cl = cx & 0xFF;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(scene->asset, rows, cl, &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    img->pixels = render_disp_data_3c1c_image(planes, planes_size,
                                              rows, cl, render_mode,
                                              &img->w, &img->h);
    free(planes);
    img->x = ((((bx - 0x0410u) >> 8) & 0xFF) * 4);
    img->y = ((bx - 0x0410u) & 0xFF) + 0x10;

    if (img->pixels)
        frame_story_scene_with_waku(img);

    if (img->pixels)
        platform_log("opening: %s disp_data_3c1c AL=%u %dx%d at %d,%d ok",
                     scene->asset, render_mode, img->w, img->h, img->x, img->y);
}

static void load_disp_data_3c1c_overlay(cached_image_t *img,
                                        const scene_def_t *scene,
                                        u8 render_mode,
                                        u16 bx,
                                        u16 cx) {
    if (!img || img->pixels)
        return;

    const int rows = (cx >> 8) & 0xFF;
    const int cl = cx & 0xFF;

    size_t planes_size = 0;
    u8 *planes = load_img_open_planes(scene->asset, rows, cl, &planes_size);
    if (!planes || planes_size == 0) {
        free(planes);
        return;
    }

    img->pixels = render_disp_data_3c1c_image(planes, planes_size,
                                              rows, cl, render_mode,
                                              &img->w, &img->h);
    free(planes);
    img->x = ((bx >> 8) & 0xFF) * 4;
    img->y = bx & 0xFF;

    if (img->pixels)
        platform_log("opening: %s disp_data_3c1c overlay AL=%u %dx%d at %d,%d ok",
                     scene->asset, render_mode, img->w, img->h, img->x, img->y);
}

static u8 ror8_1(u8 value) {
    return (u8)((value >> 1) | (value << 7));
}

static void mcga_store_word(u16 di, u16 word) {
    int offset = (int)di;
    if (offset < ZELIARD_WIDTH * ZELIARD_HEIGHT)
        g_framebuf[offset] = (u8)(word & 0xFFu);
    if (offset + 1 < ZELIARD_WIDTH * ZELIARD_HEIGHT)
        g_framebuf[offset + 1] = (u8)(word >> 8);
}

static void mcga_extract_scroll_words(u16 *si, u8 cur_row, u8 cur_col,
                                      u16 *src_d, u16 *src_c,
                                      u16 *src_b, u16 *src_a) {
    u8 al = (u8)(*si & 0xFFu);
    u8 ah = mcga_driver_byte((u16)(*si + 4u));
    u16 ax = (u16)(((u16)ah << 8) | al);

    *src_a = 0;
    *src_d = 0;
    *src_c = ax;
    *src_b = ax;

    al = (u8)(mcga_driver_byte(*si) & cur_col);
    *si = (u16)(*si + 1u);
    ah = al;
    al = cur_row;

    u8 carry = (u8)(al & 1u);
    al >>= 1;
    if (carry)
        *src_a = (u16)(*src_a | (((u16)ah << 8) | al));

    carry = (u8)(al & 1u);
    al >>= 1;
    if (carry)
        *src_b = (u16)(*src_b | (((u16)ah << 8) | al));

    carry = (u8)(al & 1u);
    al >>= 1;
    if (carry)
        *src_c = (u16)(*src_c | (((u16)ah << 8) | al));
}

static void mcga_lookup_palette_entry(u8 step, u16 di, u8 cur_row, u8 cur_col) {
    u16 si = (u16)(0x3A5Fu + ((u16)(step - 1u) * 8u));
    for (int band = 0; band < 4; band++) {
        u8 band_col = (band & 1) ? ror8_1(cur_col) : cur_col;
        u16 src_d = 0;
        u16 src_c = 0;
        u16 src_b = 0;
        u16 src_a = 0;
        mcga_extract_scroll_words(&si, cur_row, band_col,
                                  &src_d, &src_c, &src_b, &src_a);
        for (int rep = 0; rep < 2; rep++) {
            u16 word = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                       &src_b, &src_a);
            mcga_store_word(di, word);
            di = (u16)(di + 2u);
        }
        if (band != 3)
            di = (u16)(di + 0x013Cu);
    }
}

static int mcga_scroll_ring_segment_budgeted(u8 step, u16 *di, u16 delta,
                                             u8 cur_row, u8 cur_col,
                                             u32 *entries,
                                             u32 max_entries) {
    if (*entries >= max_entries)
        return 0;
    mcga_lookup_palette_entry(step, *di, cur_row, cur_col);
    (*entries)++;
    *di = (u16)(*di + delta);
    return 1;
}

static void render_disp_load_setup_scroll_ring_budgeted(u8 ax_step,
                                                        u32 max_entries) {
    u16 bx = (u16)ax_step * 2u;
    u8 cur_row = mcga_driver_byte((u16)(0x3C16u + bx));
    u8 cur_col = mcga_driver_byte((u16)(0x3C17u + bx));
    u16 di = 0x1410;
    u16 si = 0x3B1F;
    u8 step;
    u32 entries = 0;

    while ((step = mcga_driver_byte(si++)) != 0)
        if (!mcga_scroll_ring_segment_budgeted(step, &di, 0x0500,
                                               cur_row, cur_col,
                                               &entries, max_entries))
            return;
    di = (u16)(di + 0xFB04u);

    while ((step = mcga_driver_byte(si++)) != 0)
        if (!mcga_scroll_ring_segment_budgeted(step, &di, 0x0004,
                                               cur_row, cur_col,
                                               &entries, max_entries))
            return;
    di = (u16)(di + 0xFAFCu);

    while ((step = mcga_driver_byte(si++)) != 0)
        if (!mcga_scroll_ring_segment_budgeted(step, &di, 0xFB00,
                                               cur_row, cur_col,
                                               &entries, max_entries))
            return;
    di = (u16)(di + 0x04FCu);

    while ((step = mcga_driver_byte(si++)) != 0)
        if (!mcga_scroll_ring_segment_budgeted(step, &di, 0xFFFC,
                                               cur_row, cur_col,
                                               &entries, max_entries))
            return;
    di = (u16)(di + 0x0504u);

    si = 0x3BE3;
    for (;;) {
        step = mcga_driver_byte(si++);
        if (step == 0)
            return;
        for (u8 i = 0; i < step; i++)
            if (!mcga_scroll_ring_segment_budgeted(0x18, &di, 0x0500,
                                                   cur_row, cur_col,
                                                   &entries, max_entries))
                return;
        di = (u16)(di + 0xFB00u);

        step = mcga_driver_byte(si++);
        if (step == 0)
            return;
        for (u8 i = 0; i < step; i++)
            if (!mcga_scroll_ring_segment_budgeted(0x18, &di, 0x0004,
                                                   cur_row, cur_col,
                                                   &entries, max_entries))
                return;
        di = (u16)(di - 4u);

        step = mcga_driver_byte(si++);
        if (step == 0)
            return;
        for (u8 i = 0; i < step; i++)
            if (!mcga_scroll_ring_segment_budgeted(0x18, &di, 0xFB00,
                                                   cur_row, cur_col,
                                                   &entries, max_entries))
                return;
        di = (u16)(di + 0x0500u);

        step = mcga_driver_byte(si++);
        if (step == 0)
            return;
        for (u8 i = 0; i < step; i++)
            if (!mcga_scroll_ring_segment_budgeted(0x18, &di, 0xFFFC,
                                                   cur_row, cur_col,
                                                   &entries, max_entries))
                return;
        di = (u16)(di + 4u);
    }
}

static void ZEL_UNUSED render_disp_load_setup_scroll_ring(u8 ax_step) {
    render_disp_load_setup_scroll_ring_budgeted(ax_step, 0xFFFFFFFFu);
}

static void disp_load_write_status_pattern(int offset) {
    static const int rel[] = { -7, -5, -3, -1 };
    for (size_t i = 0; i < sizeof(rel) / sizeof(rel[0]); i++) {
        int pos = offset + rel[i];
        if (pos >= 0 && pos + 1 < ZELIARD_FB_SIZE) {
            g_framebuf[pos] = 0x02;
            g_framebuf[pos + 1] = 0x02;
        }
    }
}

static void disp_load_clear_status_row(int offset, int width_bytes) {
    disp_load_write_status_pattern(offset);
    if (offset >= 0 && offset < ZELIARD_FB_SIZE)
        g_framebuf[offset] = 0xFF;
    for (int i = 1; i <= width_bytes + 2; i++) {
        int pos = offset + i;
        if (pos >= 0 && pos < ZELIARD_FB_SIZE)
            g_framebuf[pos] = 0;
    }
    int right = offset + width_bytes + 3;
    if (right >= 0 && right < ZELIARD_FB_SIZE)
        g_framebuf[right] = 0xFF;
}

static void render_disp_load_setup_rect(u16 bx_reg, u16 cx_reg) {
    int x = ((bx_reg >> 8) & 0xFF) * 4;
    int y = bx_reg & 0xFF;
    int ch = (cx_reg >> 8) & 0xFF;
    int cl = cx_reg & 0xFF;
    int width_bytes = ch * 4 - 4;
    int middle_rows = cl - 5;
    if (width_bytes < 0 || middle_rows < 0)
        return;

    int offset = y * ZELIARD_WIDTH + x;
    disp_load_write_status_pattern(offset);
    for (int i = 0; i < width_bytes + 4; i++) {
        int pos = offset + i;
        if (pos >= 0 && pos < ZELIARD_FB_SIZE)
            g_framebuf[pos] = 0xFF;
    }

    y++;
    offset += ZELIARD_WIDTH;
    for (int row = 0; row < 2; row++) {
        disp_load_clear_status_row(offset, width_bytes);
        y++;
        offset += ZELIARD_WIDTH;
    }

    for (int row = 0; row < middle_rows; row++) {
        disp_load_write_status_pattern(offset);
        if (offset >= 0 && offset + 3 < ZELIARD_FB_SIZE) {
            g_framebuf[offset] = 0xFF;
            g_framebuf[offset + 1] = 0;
            g_framebuf[offset + 2] = 0;
            g_framebuf[offset + 3] = 0;
        }
        int right = offset + width_bytes;
        if (right >= 0 && right + 3 < ZELIARD_FB_SIZE) {
            g_framebuf[right] = 0;
            g_framebuf[right + 1] = 0;
            g_framebuf[right + 2] = 0;
            g_framebuf[right + 3] = 0xFF;
        }
        y++;
        offset += ZELIARD_WIDTH;
    }

    disp_load_clear_status_row(offset, width_bytes);
    /* 105GDMCA's tail emits the closing full-width border one row after the
     * normal bottom status row. */
    offset += ZELIARD_WIDTH;
    disp_load_write_status_pattern(offset);
    for (int i = 0; i < width_bytes + 4; i++) {
        int pos = offset + i;
        if (pos >= 0 && pos < ZELIARD_FB_SIZE)
            g_framebuf[pos] = 0xFF;
    }
}

static void render_disp_load_setup_rect_loop_elapsed(u16 bx_reg,
                                                     u16 dx_reg,
                                                     u32 elapsed_ms) {
    const u32 step_ms = OPDMO_WAIT_MS(0x0F);
    u32 steps = elapsed_ms >= 24 * step_ms ? 24 : (elapsed_ms / step_ms) + 1;
    if (steps > 24)
        steps = 24;
    for (u32 i = 0; i < steps; i++) {
        render_disp_load_setup_rect(bx_reg, dx_reg);
        bx_reg = (u16)(bx_reg + 0x0100u);
        dx_reg = (u16)(dx_reg - 0x0100u);
    }
}

static void ZEL_UNUSED render_disp_load_setup_scroll_ring_elapsed(u8 ax_step,
                                                                  u32 elapsed_ms) {
    const u32 full_ms = MCGA_REVEAL_BATCH_COUNT * MCGA_REVEAL_FRAME_MS;
    u32 entries;
    if (elapsed_ms >= full_ms) {
        entries = 0xFFFFFFFFu;
    } else {
        entries = (u32)(((unsigned long long)elapsed_ms *
                         MCGA_REVEAL_LOOKUP_COUNT) / full_ms);
        if (entries == 0 && elapsed_ms > 0)
            entries = 1;
    }
    render_disp_load_setup_scroll_ring_budgeted(ax_step, entries);
}

static void load_maop_driver_planes(void) {
    if (g_maop_planes)
        return;
    g_maop_planes = load_img_open_planes("maop.grp", MAOP_SCENE.rows, MAOP_SCENE.cl,
                                         &g_maop_planes_size);
}

static void render_maop_driver_background(void) {
    enum {
        MAOP_SOURCE_DI = 0x8000,
        MAOP_DRIVER_BX = 0x1618,
        MAOP_DRIVER_CX = 0x2F58
    };
    load_maop_driver_planes();
    framebuf_clear(0);
    cached_image_t frame;
    memset(&frame, 0, sizeof(frame));
    load_game_frame_overlay(&frame, &WAKU_FRAME);
    if (frame.pixels) {
        blit_cached_image(&frame);
        free(frame.pixels);
    }
    if (!g_maop_planes || g_maop_planes_size == 0) {
        blit_cached_image(&g_maop_scene);
        return;
    }

    /* 100OPDMO:968-978: palette 8, then the 1515h/315Dh load-setup
     * rectangle is drawn before disp_script_area places MAOP at 1618h.
     * The four-pixel inset leaves the load-setup perimeter visible. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_LOAD_SETUP, 0x0008,
                         0x1515, 0x315D, 0, 0, 0);
    render_disp_load_setup_rect(0x1515, 0x315D);

    u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!seg)
        return;
    opdmoseg_copy(seg, MAOP_SOURCE_DI, g_maop_planes, g_maop_planes_size);
    opdmo_mcga_prepare_maop_script_area(seg, MAOP_SOURCE_DI);
    render_disp_script_area_from_segment(seg, MAOP_SOURCE_DI,
                                         MAOP_DRIVER_BX, MAOP_DRIVER_CX);
    free(seg);
}

static void opdmoseg_copy(u8 *seg, int offset, const u8 *src, size_t size) {
    for (size_t i = 0; i < size; i++)
        seg[(offset + (int)i) & 0xFFFF] = src[i];
}

static void opdmoseg_merge_gfx_planes(u8 *seg) {
    /* 100OPDMO: BX=0808h, CX=50C8h, ES:DI=game_seg:4000h. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_MERGE_GFX_PLANES, 0x0002,
                         0x0808, 0x50C8, OPDMO_FRAMEBUFFER_A, 0, 0);
    int di = OPDMO_FRAMEBUFFER_A;
    for (int i = 0; i < 0x3000; i++, di++) {
        int a_ofs = di & 0xFFFF;
        int b_ofs = (OPDMO_GFX_PLANE_B + di) & 0xFFFF;
        int c_ofs = (OPDMO_FRAMEBUFFER_B + di) & 0xFFFF;
        seg[c_ofs] = 0;
        u8 al = (u8)(seg[b_ofs] & (u8)~seg[a_ofs]);
        seg[a_ofs] |= al;
        seg[c_ofs] |= al;
        seg[b_ofs] &= (u8)~al;
        al = (u8)(seg[b_ofs] & seg[a_ofs]);
        seg[c_ofs] |= al;
    }
}

static void opdmoseg_xor_mask_render(u8 *seg) {
    /* 100OPDMO: SI=D000h, ES:DI=game_seg:4000h. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_XOR_MASK_RENDER, 0x0002,
                         OPDMO_EXT_SEGMENT, 0, OPDMO_FRAMEBUFFER_A, 0, 0);
    int si = OPDMO_EXT_SEGMENT;
    int di = OPDMO_FRAMEBUFFER_A + OPDMO_FONT_SCANLINE_OFS;
    for (int row = 0; row < 0xA0; row++) {
        int row_di = di;
        for (int col = 0; col < 0x15; col++, si++, di++) {
            int s = si & 0xFFFF;
            int mask_a = (OPDMO_PIXEL_MASK_A + si) & 0xFFFF;
            int mask_b = (OPDMO_PIXEL_MASK_B + si) & 0xFFFF;
            int dst_a = di & 0xFFFF;
            int dst_b = (OPDMO_GFX_PLANE_B + di) & 0xFFFF;
            int dst_c = (OPDMO_FRAMEBUFFER_B + di) & 0xFFFF;
            u8 al = (u8)(seg[s] & seg[mask_a] & (u8)~seg[mask_b]);
            al = (u8)~al;
            u8 ah = (u8)~(seg[s] | seg[mask_a] | seg[mask_b]);
            seg[s] &= al;
            seg[mask_a] &= al;
            seg[dst_a] &= ah;
            seg[dst_b] &= ah;
            seg[dst_c] &= ah;
            seg[dst_a] |= seg[s];
            seg[dst_b] |= seg[mask_a];
            seg[dst_c] |= seg[mask_b];
        }
        di = row_di + 0x40;
    }
}

static void load_final_yuu_scene(void) {
    if (g_yuu3_final_scene.pixels) return;

    /* MASM performs both SAR loads before either decompression. */
    size_t yuu3_size = 0;
    size_t yuu3_file_size = 0;
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SAR_LOAD, 0x0002, 0x95E8,
                         0, 0xA000, 0, 0);
    u8 *yuu3_file = platform_load_asset("yuu3.grp", &yuu3_file_size);
    size_t yuu4_file_size = 0;
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SAR_LOAD, 0x0002, 0x95F3,
                         0, OPDMO_EXT_SEGMENT, 0, 0);
    u8 *yuu4_file = platform_load_asset("yuu4.grp", &yuu4_file_size);
    if (!yuu3_file || !yuu4_file) {
        free(yuu3_file);
        free(yuu4_file);
        platform_log("opening: final YUU asset load failed");
        return;
    }
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DECOMPRESS_IMAGE, 0x0002,
                         0xA000, 0, OPDMO_FRAMEBUFFER_A, 0, 0);
    u8 *yuu3 = decode_img_open_file_data(yuu3_file, yuu3_file_size,
                                         FINAL_SCENE_ROWS, FINAL_SCENE_CL,
                                         &yuu3_size);
    free(yuu3_file);
    if (!yuu3) {
        free(yuu3);
        free(yuu4_file);
        return;
    }

    u8 *seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!seg) {
        free(yuu3);
        free(yuu4_file);
        return;
    }

    opdmoseg_copy(seg, OPDMO_FRAMEBUFFER_A, yuu3, yuu3_size);
    free(yuu3);

    /* 100OPDMO:1056-1058: gfx_mode_fn clears the full 320x200 target before
     * merge_gfx_planes. Asset preload has no visible framebuffer yet, but this
     * exact service boundary belongs in the mechanically translated trace. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_GFX_MODE, 0x0000,
                         0x0000, 0x50C8, 0, 0, 0);
    opdmoseg_merge_gfx_planes(seg);

    /* MASM only opens yuu4 into D000 after the mode clear and merge. */
    size_t yuu4_size = 0;
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DECOMPRESS_IMAGE, 0x0002,
                         OPDMO_EXT_SEGMENT, 0, OPDMO_EXT_SEGMENT, 0, 0);
    u8 *yuu4 = decode_img_open_file_data(yuu4_file, yuu4_file_size, 1, 1,
                                         &yuu4_size);
    free(yuu4_file);
    if (!yuu4) {
        free(seg);
        return;
    }
    opdmoseg_copy(seg, OPDMO_EXT_SEGMENT, yuu4, yuu4_size);
    free(yuu4);
    opdmoseg_xor_mask_render(seg);

    g_yuu3_final_scene.x = YUU3_SCENE.x;
    g_yuu3_final_scene.y = YUU3_SCENE.y;
    g_yuu3_final_scene.pixels = zeliard_mcga_render_three_plane_ab(
        seg, OPDMO_FRAMEBUFFER_A, FINAL_SCENE_BP, FINAL_SCENE_ROWS,
        FINAL_SCENE_CL, &g_yuu3_final_scene.w, &g_yuu3_final_scene.h);
    /* gfx_draw_fn uses render_plane_a_loop: D=B, C=0, B=0, A=A.  Retain the
     * post-XOR segment so this later display is not reconstructed from an
     * already composited framebuffer. */
    g_yuu3_final_draw_scene.x = YUU3_SCENE.x;
    g_yuu3_final_draw_scene.y = YUU3_SCENE.y;
    g_yuu3_final_draw_scene.pixels = zeliard_mcga_render_three_plane_mapped(
        seg, OPDMO_FRAMEBUFFER_A, FINAL_SCENE_BP, FINAL_SCENE_ROWS,
        FINAL_SCENE_CL, 1, -1, -1, 0,
        &g_yuu3_final_draw_scene.w, &g_yuu3_final_draw_scene.h);
    g_final_yuu_runtime_seg = seg;

    if (g_yuu3_final_scene.pixels)
        platform_log("opening: final yuu3/yuu4 composite %dx%d ok",
                     g_yuu3_final_scene.w, g_yuu3_final_scene.h);
    else
        platform_log("opening: final yuu3/yuu4 composite failed");
}

static void load_title_card_frame(void) {
    if (g_title_card_frame) return;

    size_t file_size = 0;
    u8 *file_data = platform_load_asset("title_full.bin", &file_size);
    if (!file_data) {
        platform_log("opening: missing title_full.bin");
        return;
    }
    if (file_size != ZELIARD_FB_SIZE) {
        platform_log("opening: bad title_full.bin size %zu", file_size);
        free(file_data);
        return;
    }
    g_title_card_frame = file_data;
}

static void load_title_handoff_layer(cached_image_t *img, const char *asset) {
    if (img->pixels)
        return;

    u8 *owned_planes = NULL;
    size_t owned_planes_size = 0;
    const u8 *planes = g_ttl1_planes;
    size_t planes_size = g_ttl1_planes_size;
    if (!planes || !planes_size) {
        size_t file_size = 0;
        u8 *file_data = platform_load_asset(asset, &file_size);
        if (!file_data) {
            platform_log("opening: missing title handoff asset %s", asset);
            return;
        }
        owned_planes = grp_decode_6de1_planes(file_data, file_size,
                                              &owned_planes_size);
        free(file_data);
        planes = owned_planes;
        planes_size = owned_planes_size;
    }

    if (!planes || !planes_size) {
        platform_log("opening: title handoff plane decode failed for %s", asset);
        return;
    }

    img->pixels = zeliard_mcga_render_three_plane_ab_direct(
        planes, 0, TITLE_LAYER.rows * TITLE_LAYER.cl,
        TITLE_LAYER.rows, TITLE_LAYER.cl, &img->w, &img->h);
    free(owned_planes);
    img->x = TITLE_LAYER.x;
    img->y = TITLE_LAYER.y;

    if (img->pixels)
        platform_log("opening: title handoff layer %s %dx%d ok",
                     asset, img->w, img->h);
    else
        platform_log("opening: title handoff layer decode failed for %s", asset);
}

static void load_title_handoff_planes(const char *asset,
                                      u8 **planes, size_t *planes_size) {
    if (*planes)
        return;

    size_t file_size = 0;
    u8 *file_data = platform_load_asset(asset, &file_size);
    if (!file_data) {
        platform_log("opening: missing title handoff planes %s", asset);
        return;
    }

    *planes = grp_decode_6de1_planes(file_data, file_size, planes_size);
    free(file_data);

    if (*planes)
        platform_log("opening: title handoff planes %s decoded=%zu",
                     asset, *planes_size);
    else
        platform_log("opening: title handoff planes decode failed for %s", asset);
}

static void build_title_open_tilemap(void) {
    enum {
        TITLE_SCENE_BUF_SIZE = 0x5000,
        TITLE_TILE_SRC_STRIDE = 0x28,
        TITLE_TILE_PLANE_STRIDE = 0x640,
        TITLE_TILE_DEST_STRIDE = 0x22,
        TITLE_TILE_DEST_PLANE_STRIDE = 0x1A90,
        TITLE_TILE_ROWS = 25,
        TITLE_TILE_COLS = 34,
        TITLE_TILE_H = 8,
        TITLE_TILEMAP_PLANES_SIZE = TITLE_TILE_DEST_PLANE_STRIDE * 3
    };

    if (g_ttl2_tilemap.pixels)
        return;
    if (!g_ttl2_planes)
        return;

    u8 *scene = (u8 *)calloc(TITLE_SCENE_BUF_SIZE, 1);
    u8 *seg = (u8 *)calloc(TITLE_TILEMAP_PLANES_SIZE, 1);
    if (!scene || !seg) {
        free(scene);
        free(seg);
        return;
    }

    size_t n = g_ttl2_planes_size < TITLE_SCENE_BUF_SIZE ? g_ttl2_planes_size : TITLE_SCENE_BUF_SIZE;
    memcpy(scene, g_ttl2_planes, n);

    for (int row = 0; row < TITLE_TILE_ROWS; row++) {
        for (int col = 0; col < TITLE_TILE_COLS; col++) {
            u8 tile = SCENE_SPRITE_D[row * TITLE_TILE_COLS + col];
            int tile_src = (tile / TITLE_TILE_SRC_STRIDE) * 0x140 +
                           (tile % TITLE_TILE_SRC_STRIDE);
            int tile_dst = row * 0x110 + col;
            for (int plane = 0; plane < 3; plane++) {
                for (int y = 0; y < TITLE_TILE_H; y++) {
                    int src = tile_src + plane * TITLE_TILE_PLANE_STRIDE +
                              y * TITLE_TILE_SRC_STRIDE;
                    int dst = plane * TITLE_TILE_DEST_PLANE_STRIDE +
                              tile_dst + y * TITLE_TILE_DEST_STRIDE;
                    if (src < TITLE_SCENE_BUF_SIZE &&
                        dst < TITLE_TILEMAP_PLANES_SIZE)
                        seg[dst] = scene[src];
                }
            }
        }
    }

    static const int plane_maps[][4] = {
        {-1, 2, 1, 0},
        {-1, 2, 0, 1},
        {-1, 1, 2, 0},
        {-1, 1, 0, 2},
        {-1, 0, 2, 1},
        {-1, 0, 1, 2},
    };
    int variant = g_title_tilemap_variant;
    if (variant < 0 ||
        variant >= (int)(sizeof(plane_maps) / sizeof(plane_maps[0])))
        variant = 0;

    free(g_ttl2_tilemap_planes);
    g_ttl2_tilemap_planes = (u8 *)malloc(TITLE_TILEMAP_PLANES_SIZE);
    if (g_ttl2_tilemap_planes) {
        memcpy(g_ttl2_tilemap_planes, seg, TITLE_TILEMAP_PLANES_SIZE);
        g_ttl2_tilemap_planes_size = TITLE_TILEMAP_PLANES_SIZE;
    } else {
        g_ttl2_tilemap_planes_size = 0;
    }

    g_ttl2_tilemap.x = 0;
    g_ttl2_tilemap.y = 0;
    g_ttl2_tilemap.pixels = zeliard_mcga_render_three_plane_mapped(
        seg, 0, TITLE_TILE_DEST_PLANE_STRIDE,
        TITLE_TILE_DEST_STRIDE, TITLE_TILE_ROWS * TITLE_TILE_H,
        plane_maps[variant][0], plane_maps[variant][1],
        plane_maps[variant][2], plane_maps[variant][3],
        &g_ttl2_tilemap.w, &g_ttl2_tilemap.h);
    free(scene);
    free(seg);

    if (g_ttl2_tilemap.pixels)
        platform_log("opening: title scene_sprite_d tilemap %dx%d ok",
                     g_ttl2_tilemap.w, g_ttl2_tilemap.h);
    else
        platform_log("opening: title scene_sprite_d tilemap render failed");
}

static u8 reverse_bits8(u8 value) {
    u8 out = 0;
    for (int i = 0; i < 8; i++) {
        out = (u8)((out << 1) | (value & 1u));
        value >>= 1;
    }
    return out;
}

static u16 rol16_cf(u16 *value) {
    u16 carry = (u16)((*value >> 15) & 1u);
    *value = (u16)((*value << 1) | carry);
    return carry;
}

static u16 title_sprite_mask_word(u16 *mask_word) {
    u8 al, ah, dl;
    u16 cf = rol16_cf(mask_word);
    al = cf ? 0xFF : 0x00;
    cf = rol16_cf(mask_word);
    ah = cf ? 0xFF : 0x00;
    al = (u8)(al | ah);
    cf = rol16_cf(mask_word);
    dl = cf ? 0xFF : 0x00;
    cf = rol16_cf(mask_word);
    ah = cf ? 0xFF : 0x00;
    ah = (u8)(ah | dl);
    return (u16)(((u16)ah << 8) | al);
}

static u16 title_sprite_pixel_word(u16 ax, u16 words[4]) {
    for (int rep = 0; rep < 2; rep++) {
        for (int i = 3; i >= 0; i--) {
            u16 cf = rol16_cf(&words[i]);
            ax = (u16)((ax << 1) | cf);
        }
        for (int i = 3; i >= 0; i--) {
            u16 cf = rol16_cf(&words[i]);
            ax = (u16)((ax << 1) | cf);
        }
    }
    return (u16)(((ax & 0xFFu) << 8) | (ax >> 8));
}

static u16 title_sprite_read_be16(const u8 *buf, size_t size, size_t off) {
    u8 hi = off < size ? buf[off] : 0;
    u8 lo = off + 1u < size ? buf[off + 1u] : 0;
    return (u16)(((u16)hi << 8) | lo);
}

static void title_sprite_write_word(int offset, u16 mask, u16 pixels) {
    if (offset < 0 || offset + 1 >= ZELIARD_FB_SIZE)
        return;
    u8 lo = (u8)(pixels & 0xFFu);
    u8 hi = (u8)(pixels >> 8);
    g_framebuf[offset] = (u8)((g_framebuf[offset] & (u8)(mask & 0xFFu)) | lo);
    g_framebuf[offset + 1] =
        (u8)((g_framebuf[offset + 1] & (u8)(mask >> 8)) | hi);
}

/* Legacy presentation path.  It is deliberately not the authority for
 * 105GDMCA:37B4: render/mcga_render.c now owns the direct release-shaped
 * routine, which needs the original CS+2000h title work segment. */
static void render_title_sprite_obj_scanline_legacy(u8 al) {
    enum {
        TITLE_SPRITE_ROW_BYTES = 0x22,
        TITLE_SPRITE_SECOND_PLANE_DELTA = 0x1A6E,
        TITLE_SPRITE_SCRATCH_SIZE = 0x44,
        TITLE_SPRITE_WORDS_PER_HALF = 0x11,
    };
    if (!g_ttl2_tilemap_planes ||
        g_ttl2_tilemap_planes_size < TITLE_SPRITE_SCRATCH_SIZE)
        return;

    u8 scratch[TITLE_SPRITE_SCRATCH_SIZE];
    size_t si = (size_t)al * TITLE_SPRITE_ROW_BYTES;
    for (size_t i = 0; i < TITLE_SPRITE_ROW_BYTES; i++) {
        scratch[i] = reverse_bits8(g_ttl2_tilemap_planes[
            (si + i) % g_ttl2_tilemap_planes_size]);
        scratch[TITLE_SPRITE_ROW_BYTES + i] = reverse_bits8(g_ttl2_tilemap_planes[
            (si + TITLE_SPRITE_SECOND_PLANE_DELTA + i) %
            g_ttl2_tilemap_planes_size]);
    }

    int di0 = (int)al * ZELIARD_WIDTH;
    int di = di0;
    u16 ax_state = 0;
    for (int i = 0; i < TITLE_SPRITE_WORDS_PER_HALF; i++) {
        u16 ax = title_sprite_read_be16(g_ttl2_tilemap_planes,
                                        g_ttl2_tilemap_planes_size,
                                        si + (size_t)i * 2u);
        u16 bx = title_sprite_read_be16(g_ttl2_tilemap_planes,
                                        g_ttl2_tilemap_planes_size,
                                        si + 0x1A90u + (size_t)i * 2u);
        u16 common = (u16)(ax & bx);
        u16 words[4] = { common, bx, bx, bx };
        u16 mask_word = (u16)~(ax | bx);
        for (int word = 0; word < 4; word++) {
            u16 mask = title_sprite_mask_word(&mask_word);
            ax_state = title_sprite_pixel_word(mask, words);
            title_sprite_write_word(di + word * 2, mask, ax_state);
        }
        di += 8;
    }

    di = di0 + 0x138;
    for (int i = 0; i < TITLE_SPRITE_WORDS_PER_HALF; i++) {
        u16 ax = title_sprite_read_be16(scratch, sizeof(scratch), (size_t)i * 2u);
        u16 bx = title_sprite_read_be16(scratch, sizeof(scratch),
                                        0x22u + (size_t)i * 2u);
        u16 common = (u16)(ax & bx);
        u16 words[4] = { common, bx, bx, bx };
        u16 mask_word = (u16)~(ax | bx);
        const int offsets[4] = {4, 6, 0, 2};
        for (int word = 0; word < 4; word++) {
            u16 mask = title_sprite_mask_word(&mask_word);
            ax_state = title_sprite_pixel_word(mask, words);
            title_sprite_write_word(di + offsets[word], mask, ax_state);
        }
        di -= 8;
    }
}

static void ZEL_UNUSED render_title_sprite_obj_loop_legacy(u32 elapsed_ms) {
    u32 count = elapsed_ms / OPDMO_WAIT_MS(0x50) + 1u;
    if (count > 100)
        count = 100;

    u8 al = 0xC7;
    u8 ah = 0x00;
    for (u32 i = 0; i < count; i++) {
        render_title_sprite_obj_scanline_legacy(al);
        render_title_sprite_obj_scanline_legacy(ah);
        ah = (u8)(ah + 2);
        al = (u8)(al - 2);
    }
}

static int prepare_title_tile_render_segments(void) {
    load_gdmcga_chunk_segment();
    load_title_runtime_segment();
    load_title_handoff_planes("ttl1.grp", &g_ttl1_planes, &g_ttl1_planes_size);
    load_title_handoff_planes("ttl3.grp", &g_ttl3_planes, &g_ttl3_planes_size);
    load_title_handoff_planes("ttl2.grp", &g_ttl2_planes, &g_ttl2_planes_size);
    if (!g_gdmcga_chunk_seg || !g_title_runtime_seg || !g_ttl1_planes ||
        !g_ttl3_planes || !g_ttl2_planes)
        return -1;
    if (!g_title_vga_seg)
        g_title_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_tile_work_seg)
        g_title_tile_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_vga_seg || !g_title_tile_work_seg)
        return -1;

    /* 100OPDMO:501-506 decodes the already-loaded ttl2 stream for the
     * 3732 tile builder.  3732 reads its graphics from game:4000h. */
    size_t bytes = g_ttl2_planes_size;
    if (bytes > 0x6000u)
        bytes = 0x6000u;
    memcpy(g_title_runtime_seg + 0x4000, g_ttl2_planes, bytes);
    /* SI=scene_sprite_d is fetched while DS still names the OPDMO code
     * segment; the helper later switches DS to gvar_game_seg for ttl2 data.
     * Keep that table separate from the game:9000 staging image. */
    load_opdmo_chunk_segment();
    return zeliard_mcga_disp_tilemap_render(g_opdmo_chunk_seg,
                                            OPDMO_SEG_SIZE, 0x912B,
                                            g_title_runtime_seg,
                                            OPDMO_SEG_SIZE,
                                            g_title_tile_work_seg,
                                            OPDMO_SEG_SIZE);
}

/* 100OPDMO's first title image call is CS:[301Ah] -> 105GDMCA:30FCh.
 * Its source is the decoded ttl3 two-plane image at game:4000; zero pixels
 * deliberately retain the copyright text already present in A000. */
static int render_title_base_image_30fc(int pass_count) {
    load_gdmcga_chunk_segment();
    load_title_runtime_segment();
    load_title_handoff_planes("ttl3.grp", &g_ttl3_planes, &g_ttl3_planes_size);
    if (!g_gdmcga_chunk_seg || !g_title_runtime_seg || !g_ttl3_planes)
        return -1;
    if (!g_title_base_work_seg)
        g_title_base_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_vga_seg)
        g_title_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_base_work_seg || !g_title_vga_seg)
        return -1;

    memset(g_title_base_work_seg, 0, OPDMO_SEG_SIZE);
    size_t bytes = g_ttl3_planes_size;
    if (bytes > 0x7000u)
        bytes = 0x7000u;
    memcpy(g_title_runtime_seg + OPDMO_FRAMEBUFFER_A, g_ttl3_planes, bytes);
    memcpy(g_title_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
    memset(g_title_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);
    if (zeliard_mcga_disp_render_a_full_stage(g_gdmcga_chunk_seg,
                                              OPDMO_SEG_SIZE,
                                              g_title_runtime_seg,
                                              OPDMO_SEG_SIZE,
                                              g_title_base_work_seg,
                                              OPDMO_SEG_SIZE,
                                              0, 0x070F, 0x4170,
                                              OPDMO_FRAMEBUFFER_A,
                                              g_title_vga_seg, OPDMO_SEG_SIZE,
                                              pass_count) != 0)
        return -1;
    memcpy(g_framebuf, g_title_vga_seg, ZELIARD_FB_SIZE);
    return 0;
}

/* 100OPDMO:446-452 decodes ttl1 to game:4000; 482-487 then calls the
 * CS:3004 gfx_update_fn target (105GDMCA:3088) with AX=0/BX=0B48/CX=3180. */
static int render_title_ttl1_update_3088(int pass_count) {
    load_gdmcga_chunk_segment();
    load_title_runtime_segment();
    load_title_handoff_planes("ttl1.grp", &g_ttl1_planes, &g_ttl1_planes_size);
    if (!g_gdmcga_chunk_seg || !g_title_runtime_seg || !g_ttl1_planes)
        return -1;
    if (!g_title_base_work_seg)
        g_title_base_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_vga_seg)
        g_title_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_base_work_seg || !g_title_vga_seg)
        return -1;
    memset(g_title_base_work_seg, 0, OPDMO_SEG_SIZE);
    size_t bytes = g_ttl1_planes_size > 0x7000u ? 0x7000u : g_ttl1_planes_size;
    memcpy(g_title_runtime_seg + OPDMO_FRAMEBUFFER_A, g_ttl1_planes, bytes);
    memcpy(g_title_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
    memset(g_title_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);
    if (zeliard_mcga_gfx_update_cba_stage(g_gdmcga_chunk_seg,
                                          OPDMO_SEG_SIZE,
                                          g_title_runtime_seg,
                                          OPDMO_SEG_SIZE,
                                          g_title_base_work_seg,
                                          OPDMO_SEG_SIZE,
                                          0, 0x0B48, 0x3180,
                                          OPDMO_FRAMEBUFFER_A,
                                          g_title_vga_seg, OPDMO_SEG_SIZE,
                                          pass_count) != 0)
        return -1;
    memcpy(g_framebuf, g_title_vga_seg, ZELIARD_FB_SIZE);
    return 0;
}

static u32 title_color_pair_count(u32 elapsed_ms) {
    u32 count = elapsed_ms / OPDMO_WAIT_MS(0x50) + 1u;
    return count > 100u ? 100u : count;
}

static void render_title_sprite_obj_loop_37b4(u32 elapsed_ms) {
    if (prepare_title_tile_render_segments() != 0)
        return;

    /* opening_render_phase_for_test and the browser redraw this phase from
     * elapsed time.  37B4 mutates CS scratch/state, so replay gets a private
     * driver image.  The canonical loaded 105GDMCA segment remains intact:
     * its 4289h palette-register table is later consumed by 3A02. */
    if (!g_title_driver_work_seg)
        g_title_driver_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_title_driver_work_seg)
        return;
    memcpy(g_title_driver_work_seg, g_gdmcga_chunk_seg, OPDMO_SEG_SIZE);

    memcpy(g_title_vga_seg,
           g_title_color_base_frame_ready
               ? g_title_color_base_frame
               : g_framebuf,
           ZELIARD_FB_SIZE);
    memset(g_title_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);

    u32 count = title_color_pair_count(elapsed_ms);
    u8 al = 0xC7;
    u8 ah = 0x00;
    for (u32 i = 0; i < count; i++) {
        (void)zeliard_mcga_disp_tile_render(g_title_driver_work_seg,
                                            OPDMO_SEG_SIZE,
                                            g_title_tile_work_seg,
                                            OPDMO_SEG_SIZE, al,
                                            g_title_vga_seg, OPDMO_SEG_SIZE);
        (void)zeliard_mcga_disp_tile_render(g_title_driver_work_seg,
                                            OPDMO_SEG_SIZE,
                                            g_title_tile_work_seg,
                                            OPDMO_SEG_SIZE, ah,
                                            g_title_vga_seg, OPDMO_SEG_SIZE);
        ah = (u8)(ah + 2u);
        al = (u8)(al - 2u);
    }
    memcpy(g_framebuf, g_title_vga_seg, ZELIARD_FB_SIZE);
}

static void load_story_script_1(void) {
    if (g_story_script_1) return;
    g_story_script_1 = platform_load_asset("opdemo_story_script_1.bin",
                                            &g_story_script_1_size);
    if (!g_story_script_1)
        platform_log("opening: exact first story script asset unavailable");
}

static void load_story_script_2(void) {
    if (g_story_script_2) return;
    g_story_script_2 = platform_load_asset("opdemo_story_script_2.bin",
                                            &g_story_script_2_size);
    if (!g_story_script_2)
        platform_log("opening: exact second story script asset unavailable");
}

static void load_story_script_3(void) {
    if (g_story_script_3) return;
    g_story_script_3 = platform_load_asset("opdemo_story_script_3.bin",
                                            &g_story_script_3_size);
    if (!g_story_script_3)
        platform_log("opening: exact third story script asset unavailable");
}

static void load_story_script_4(void) {
    if (g_story_script_4) return;
    g_story_script_4 = platform_load_asset("opdemo_story_script_4.bin",
                                            &g_story_script_4_size);
    if (!g_story_script_4)
        platform_log("opening: exact fourth story script asset unavailable");
}

static void load_story_script_asset(const char *name, u8 **data, size_t *size) {
    if (*data) return;
    *data = platform_load_asset(name, size);
    if (!*data)
        platform_log("opening: exact story script asset unavailable: %s", name);
}

static int mcga_render_passes_write_pixel(int pass_count, int x, int y);
static int mcga_pass_count_for_elapsed(u32 elapsed_ms);
static void render_ame_story(u32 elapsed_ms);

/* ---- blitter ------------------------------------------------------------ */
/* Both IMG_GRP and IMG_GFX_DRAW produce the same nibble-packed paletted pixel
 * format from render_8pass_blit.  Non-zero pixels are written; zero = transparent. */
static void blit_cached_image(const cached_image_t *img) {
    if (!img->pixels) return;

    int bx = img->x;
    int by = img->y;
    for (int y = 0; y < img->h; y++) {
        int dy = y + by;
        if (dy < 0 || dy >= ZELIARD_HEIGHT) continue;
        for (int x = 0; x < img->w; x++) {
            int dx = x + bx;
            if (dx < 0 || dx >= ZELIARD_WIDTH) continue;
            u8 v = img->pixels[y * img->w + x];
            if (v == 0) continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] = v;
        }
    }
}

static void blit_cached_image_mcga_render_passes(const cached_image_t *img,
                                                 int pass_count) {
    if (!img || !img->pixels || pass_count <= 0)
        return;

    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    for (int y = 0; y < img->h; y++) {
        int dy = y + img->y;
        if (dy < 0 || dy >= ZELIARD_HEIGHT)
            continue;
        for (int x = 0; x < img->w; x++) {
            int dx = x + img->x;
            if (dx < 0 || dx >= ZELIARD_WIDTH)
                continue;
            if (!mcga_render_passes_write_pixel(pass_count, x, y))
                continue;
            u8 v = img->pixels[y * img->w + x];
            if (v == 0)
                continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] = v;
        }
    }
}

static void blit_cached_image_mcga_masked_write_passes(const cached_image_t *img,
                                                       int pass_count) {
    if (!img || !img->pixels || pass_count <= 0)
        return;

    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    /* 100OPDMO.GFX_BLIT sets AL=0FFh, so 105GDMCA.render_blit_entry skips
     * the OR pass and runs only disp_blit_masked with render_mode_flag=0FFh.
     * disp_blit_masked writes the selected source byte directly, including
     * zero pixels; unlike normal cached-image drawing, zero is not transparent. */
    for (int y = 0; y < img->h; y++) {
        int dy = y + img->y;
        if (dy < 0 || dy >= ZELIARD_HEIGHT)
            continue;
        for (int x = 0; x < img->w; x++) {
            int dx = x + img->x;
            if (dx < 0 || dx >= ZELIARD_WIDTH)
                continue;
            if (!mcga_render_passes_write_pixel(pass_count, x, y))
                continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] =
                img->pixels[y * img->w + x];
        }
    }
}

static void blit_story_inner_mcga_masked_write_passes(const cached_image_t *img,
                                                      int pass_count) {
    if (!img || !img->pixels || pass_count <= 0)
        return;
    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    /* 100OPDMO's story GFX_BLIT uses BX=0410h/CX=4868h: the 288x104
     * interior at (16,16).  Cached story images include the surrounding WAKU
     * frame, so consume that same interior while preserving the live border. */
    for (int y = 0; y < 0x68; y++) {
        for (int x = 0; x < 0x48 * 4; x++) {
            if (!mcga_render_passes_write_pixel(pass_count, x, y))
                continue;
            int px = 0x10 + x;
            int py = 0x10 + y;
            if (px < img->w && py < img->h)
                g_framebuf[py * ZELIARD_WIDTH + px] =
                    img->pixels[py * img->w + px];
        }
    }
}

static void blit_cached_image_mcga_update_full(const cached_image_t *img) {
    blit_cached_image_mcga_render_passes(img, MCGA_RENDER_PASS_COUNT);
    blit_cached_image_mcga_masked_write_passes(img, MCGA_RENDER_PASS_COUNT);
}

static void blit_cached_image_mcga_update_elapsed(const cached_image_t *img,
                                                  u32 elapsed_ms) {
    if (elapsed_ms >= MCGA_RENDER_PASS_COUNT * 2u * MCGA_RENDER_PASS_MS) {
        blit_cached_image_mcga_update_full(img);
        return;
    }

    if (elapsed_ms >= MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_MS) {
        blit_cached_image_mcga_render_passes(img, MCGA_RENDER_PASS_COUNT);
        elapsed_ms -= MCGA_RENDER_PASS_COUNT * MCGA_RENDER_PASS_MS;
        blit_cached_image_mcga_masked_write_passes(
            img, mcga_pass_count_for_elapsed(elapsed_ms));
    } else {
        blit_cached_image_mcga_render_passes(
            img, mcga_pass_count_for_elapsed(elapsed_ms));
    }
}

/* 100OPDMO:881/891 supplies ES=game_seg+2000h and DI=0 to 105GDMCA:33B7.
 * busy_wait_delay leaves DS on the opening chunk while cycling colors in that
 * separate ES segment, so this cannot reuse the ordinary game-segment DMAOU
 * cache.  Build the exact three-plane source for each call, then let the
 * same two-stage MCGA dispatcher translation reveal it. */
static void render_dmaou_post_busy_display(u8 busy_al, u32 elapsed_ms) {
    u8 *external = opdmo_dmaou_post_busy_external(busy_al);
    if (!external)
        return;

    int w = 0;
    int h = 0;
    u8 *pixels = zeliard_mcga_render_three_plane_ab(
        external, 0, 0x22 * 0x30, 0x22, 0x30, &w, &h);
    free(external);
    if (!pixels)
        return;

    cached_image_t image;
    memset(&image, 0, sizeof(image));
    image.x = DMAOU_APPARITION.x;
    image.y = DMAOU_APPARITION.y;
    image.w = w;
    image.h = h;
    image.pixels = pixels;
    blit_cached_image_mcga_update_elapsed(&image, elapsed_ms);
    free(pixels);
}

static void blit_cached_image_mcga_row_reveal_passes(const cached_image_t *img,
                                                     int pass_count) {
    if (!img || !img->pixels || pass_count <= 0)
        return;

    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;

    /* 105GDMCA.asm disp_data_7420/3C1C render_pass_loop:
     * cur_pass_ctr selects rows pass, pass+8, pass+16... through the clipped
     * BX/CX rectangle. blit_sprite_clipped_mcga clears the full 0x48-cell
     * story row before writing the clipped sprite columns, so selected rows
     * are destructive across the whole image panel. */
    const int panel_y = 0x10;
    const int panel_h = 0x68;
    for (int panel_row = 0; panel_row < panel_h; panel_row++) {
        if ((panel_row & 7) >= pass_count)
            continue;
        int dy = panel_y + panel_row;
        if (dy < 0 || dy >= ZELIARD_HEIGHT)
            continue;

        const int panel_x = 0x04 * 4;
        const int panel_w = 0x48 * 4;
        int clear_x0 = panel_x;
        int clear_x1 = panel_x + panel_w;
        if (clear_x0 < 0)
            clear_x0 = 0;
        if (clear_x1 > ZELIARD_WIDTH)
            clear_x1 = ZELIARD_WIDTH;
        if (clear_x1 > clear_x0)
            memset(&g_framebuf[dy * ZELIARD_WIDTH + clear_x0],
                   OPDMO_MCGA_BLACK_INDEX, (size_t)(clear_x1 - clear_x0));

        int image_y = dy - img->y;
        if (image_y < 0 || image_y >= img->h)
            continue;
        for (int x = 0; x < img->w; x++) {
            int dx = x + img->x;
            if (dx < 0 || dx >= ZELIARD_WIDTH)
                continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] =
                img->pixels[image_y * img->w + x];
        }
    }
}

static void blit_ame_inner_scene_mcga_passes(int pass_count) {
    if (!g_ame_scene.pixels)
        return;
    if (pass_count <= 0)
        return;

    const int rect_x = AME_SCENE.x;
    const int rect_y = AME_SCENE.y;
    const int rect_w = AME_SCENE.rows * 4;
    const int rect_h = AME_SCENE.cl;
    for (int y = 0; y < rect_h; y++) {
        int dy = rect_y + y;
        if (dy < 0 || dy >= ZELIARD_HEIGHT)
            continue;
        int sy = dy - g_ame_scene.y;
        if (sy < 0 || sy >= g_ame_scene.h)
            continue;
        for (int x = 0; x < rect_w; x++) {
            int dx = rect_x + x;
            if (dx < 0 || dx >= ZELIARD_WIDTH)
                continue;
            int sx = dx - g_ame_scene.x;
            if (sx < 0 || sx >= g_ame_scene.w)
                continue;
            if (!mcga_render_passes_write_pixel(pass_count, x, y))
                continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] =
                g_ame_scene.pixels[sy * g_ame_scene.w + sx];
        }
    }
}

static void render_ame_to_hime_handoff(u32 elapsed_ms) {
    const u32 source_ms = RAIN_PRINCESS_MS > OPDMO_WAIT_MS(0x18)
        ? RAIN_PRINCESS_MS - OPDMO_WAIT_MS(0x18)
        : 0u;
    render_ame_story(source_ms);
    opdmo_disp_set_mcga_ax(9);
    clear_story_text_area();

    int pass_count = mcga_pass_count_for_elapsed(elapsed_ms);
    if (pass_count <= 0)
        return;

    /* 100OPDMO: mov ax,9 / gfx_palette_fn / BLIT_SCENE_FRAME.
     * BLIT_SCENE_FRAME uses BX=0410h/CX=4868h with scene_framebuf, so only
     * the 288x104 inner AME rectangle is pass-written here.  The WAKU border
     * is already on the framebuffer from the previous scene. */
    blit_ame_inner_scene_mcga_passes(pass_count);
}

static void blit_scene(int idx) {
    blit_cached_image(&g_images[idx]);
}

static void draw_centered_line(const char *line, int y, u8 color);
static void draw_title_copyright_text(void);
static void opening_set_phase(opening_phase_t phase);
static void blit_temp_image_opaque(const u8 *pixels, int w, int h, int dx, int dy);

/* 100OPDMO:scene_sprite_loop. Each byte routes through CS:[3014] to
 * 105GDMCA:364F; it is a page renderer, not a narration call. */
static void render_scene_sprite_c_pages(size_t frame_count) {
    const size_t total_frames = sizeof(SCENE_SPRITE_C) - 1u;
    if (frame_count > total_frames)
        frame_count = total_frames;
    load_dmaou_prelude_game_segment();
    if (!g_dmaou_prelude_game_seg)
        return;
    if (!g_scene_sprite_c_work_seg)
        g_scene_sprite_c_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_c_vga_seg)
        g_scene_sprite_c_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_c_work_seg || !g_scene_sprite_c_vga_seg)
        return;

    memset(g_scene_sprite_c_work_seg, 0, OPDMO_SEG_SIZE);
    memcpy(g_scene_sprite_c_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
    memset(g_scene_sprite_c_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);
    for (size_t i = 0; i < frame_count; i++) {
        (void)zeliard_mcga_disp_render_ab_ab40(
            g_dmaou_prelude_game_seg, OPDMO_SEG_SIZE,
            g_scene_sprite_c_work_seg, OPDMO_SEG_SIZE,
            (u8)(SCENE_SPRITE_C[i] - 1u), 0x1720,
            g_scene_sprite_c_vga_seg,
            OPDMO_SEG_SIZE);
    }
    memcpy(g_framebuf, g_scene_sprite_c_vga_seg, ZELIARD_FB_SIZE);
}

static void render_scene_sprite_c_page(u8 page) {
    load_dmaou_prelude_game_segment();
    if (!g_dmaou_prelude_game_seg)
        return;
    if (!g_scene_sprite_c_work_seg)
        g_scene_sprite_c_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_c_vga_seg)
        g_scene_sprite_c_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_c_work_seg || !g_scene_sprite_c_vga_seg)
        return;

    memset(g_scene_sprite_c_work_seg, 0, OPDMO_SEG_SIZE);
    memcpy(g_scene_sprite_c_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
    memset(g_scene_sprite_c_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);
    (void)zeliard_mcga_disp_render_ab_ab40(
        g_dmaou_prelude_game_seg, OPDMO_SEG_SIZE,
        g_scene_sprite_c_work_seg, OPDMO_SEG_SIZE,
        page, 0x1720, g_scene_sprite_c_vga_seg, OPDMO_SEG_SIZE);
    memcpy(g_framebuf, g_scene_sprite_c_vga_seg, ZELIARD_FB_SIZE);
}

/* 100OPDMO:play_sprite_anim_script / char_render_proc.  The FF 01 xx
 * records set render_state_a=xx*8 and advance render_state_b by ten.  Every
 * printable byte is forwarded twice to CS:[3030]: first AH=2 at +2,+1, then
 * AH=7 at the base position. */
static void render_scene_sprite_b_stream(size_t max_waits) {
    if (!g_font_ready)
        return;
    load_dmaou_prelude_game_segment();

    if (!g_scene_sprite_b_work_seg)
        g_scene_sprite_b_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_b_vga_seg)
        g_scene_sprite_b_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_scene_sprite_b_work_seg || !g_scene_sprite_b_vga_seg)
        return;
    memset(g_scene_sprite_b_work_seg, 0, OPDMO_SEG_SIZE);
    memcpy(g_scene_sprite_b_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
    memset(g_scene_sprite_b_vga_seg + ZELIARD_FB_SIZE, 0,
           OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);

    u16 render_state_a = 0;
    u8 render_state_b = 0x8A;
    size_t waits = 0;

    for (size_t i = 0; i < sizeof(SCENE_SPRITE_B);) {
        u8 value = SCENE_SPRITE_B[i++];
        if (value == 0)
            break;
        if (value < 5) {
            /* 100OPDMO CS:[3016] -> 105GDMCA:36AB. */
            if (g_dmaou_prelude_game_seg) {
                (void)zeliard_mcga_disp_render_ab_gseg(
                    g_dmaou_prelude_game_seg, OPDMO_SEG_SIZE,
                    g_scene_sprite_b_work_seg, OPDMO_SEG_SIZE,
                    (u8)(value - 1u), 0x1F70,
                    g_scene_sprite_b_vga_seg, OPDMO_SEG_SIZE);
                memcpy(g_framebuf, g_scene_sprite_b_vga_seg,
                       ZELIARD_FB_SIZE);
            }
            continue;
        }
        if (waits >= max_waits)
            break;
        if (value == 0xFF) {
            if (i >= sizeof(SCENE_SPRITE_B))
                break;
            u8 marker = SCENE_SPRITE_B[i++];
            if (marker == 0)
                break;
            if (marker == 1 && i < sizeof(SCENE_SPRITE_B)) {
                render_state_a = (u16)SCENE_SPRITE_B[i++] * 8u;
                render_state_b = (u8)(render_state_b + 10u);
            }
            waits++;
            continue;
        }

        zeliard_font_draw_mcga_alt_char(&g_font, render_state_a + 2u,
                                        (int)render_state_b + 1, value, 2, 1);
        zeliard_font_draw_mcga_alt_char(&g_font, render_state_a, render_state_b,
                                        value, 7, 1);
        /* CS:[3030] writes the same A000 surface that 36AB reads/modifies. */
        memcpy(g_scene_sprite_b_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
        render_state_a = (u16)(render_state_a + 8u);
        waits++;
    }

    memcpy(g_framebuf, g_scene_sprite_b_vga_seg, ZELIARD_FB_SIZE);
}

static void render_scene_sprite_b_text(void) {
    render_scene_sprite_b_stream(SIZE_MAX);
}

static void render_scene_sprite_b_text_waits(size_t max_waits) {
    render_scene_sprite_b_stream(max_waits);
}

static void render_initial_copyright_text(void) {
    framebuf_clear(0);
    memcpy(g_palette, g_title_card_palette, sizeof(g_palette));
    /* 100OPDMO:343-346: SI=scene_data_a (CS:64EAh), BX=0, CL=96h,
     * CS:[202A] -> GMMCGA:291A.  The stream owns its leading selector,
     * spacing, CRs, and FF terminator; do not rebuild it from C strings. */
    load_opdmo_chunk_segment();
    if (g_opdmo_chunk_seg && g_font_ready) {
        zeliard_font_draw_mcga_narration_stream(&g_font, 0, 0x96,
                                                 g_opdmo_chunk_seg + 0x64EA,
                                                 OPDMO_SEG_SIZE - 0x64EA, 1);
    } else {
        draw_title_copyright_text();
    }
}

static void render_copyright_title_card(u32 elapsed_ms) {
    /* 100OPDMO:343-353 draws the copyright stream and immediately calls
     * CS:[301Ah].  The release slot contains 30FCh; 105GDMCA:263-282 forces
     * AL=0 and executes two eight-pass loops, each waiting 14h timer ticks.
     * There is no separate pre-hold, post-hold, or clear wait in this span. */
    if (elapsed_ms < TITLE_FADE_IN_MS) {
        memcpy(g_palette, g_title_card_palette, sizeof(g_palette));
        render_initial_copyright_text();
        int pass_count = (int)(elapsed_ms / MCGA_RENDER_PASS_MS);
        (void)render_title_base_image_30fc(pass_count);
        return;
    }

    /* Defensive direct-call behavior.  The phase scheduler normally changes
     * phase at this exact boundary, just as MASM continues to gfx_init_fn. */
    opdmo_disp_set_mcga_ax(1);
    framebuf_clear(0);
}

static int mcga_mask_writes_pixel(u8 mask, int x) {
    return (mask & (0x80u >> (x & 7))) != 0;
}

static u8 mcga_mask_for_pass_row(int pass, int row) {
    /* 105GDMCA.asm run_render_passes_mcga uses mask_tbl_a/mask_tbl_b at
     * runtime CS:32B9/32C1 to reveal or clear one byte lane per timed pass. */
    static const u8 mask_tbl_a[8] = {0x80, 0x20, 0x08, 0x02, 0x40, 0x10, 0x04, 0x01};
    static const u8 mask_tbl_b[8] = {0x01, 0x04, 0x10, 0x40, 0x02, 0x08, 0x20, 0x80};
    int idx = (pass + row) & 7;
    return (row & 1) ? mask_tbl_b[idx] : mask_tbl_a[idx];
}

static int mcga_render_passes_write_pixel(int pass_count, int x, int y) {
    if (pass_count >= MCGA_RENDER_PASS_COUNT)
        return 1;
    for (int pass = 0; pass < pass_count; pass++) {
        if (mcga_mask_writes_pixel(mcga_mask_for_pass_row(pass, y), x))
            return 1;
    }
    return 0;
}

static void clear_framebuffer_mcga_render_passes(int pass_count) {
    if (pass_count <= 0)
        return;
    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;
    for (int y = 0; y < ZELIARD_HEIGHT; y++) {
        for (int x = 0; x < ZELIARD_WIDTH; x++) {
            if (mcga_render_passes_write_pixel(pass_count, x, y))
                g_framebuf[y * ZELIARD_WIDTH + x] = 0;
        }
    }
}

static int mcga_pass_count_for_elapsed(u32 elapsed_ms) {
    /* 105GDMCA.run_render_passes_mcga writes the current masked lane before
     * it polls gvar_frame_timer for its 14h-tick wait (105GDMCA:316-360).
     * A snapshot taken at the caller's entry therefore already contains pass
     * zero; the second pass starts only after the first wait completes. */
    int pass_count = 1 + (int)(elapsed_ms / MCGA_RENDER_PASS_MS);
    if (pass_count > MCGA_RENDER_PASS_COUNT)
        pass_count = MCGA_RENDER_PASS_COUNT;
    return pass_count;
}

static void render_story_background(const cached_image_t *background) {
    framebuf_clear(OPDMO_MCGA_BLACK_INDEX);
    if (background)
        blit_cached_image(background);
}

static void ZEL_UNUSED render_waku_black_story_shell(void) {
    cached_image_t frame;
    memset(&frame, 0, sizeof(frame));
    load_game_frame_overlay(&frame, &WAKU_FRAME);
    if (!frame.pixels) {
        framebuf_clear(OPDMO_MCGA_BLACK_INDEX);
        return;
    }

    render_story_background(&frame);
    free(frame.pixels);
    clear_story_image_window();
    clear_story_text_area();
}

static void ZEL_UNUSED clear_mcga_disp_data_3c1c_window(void) {
    const int x = 4 * 4;
    const int y = 0x10;
    const int w = 0x48 * 4;
    const int h = 0x68;

    for (int row = 0; row < h; row++) {
        int yy = y + row;
        if (yy < 0 || yy >= ZELIARD_HEIGHT)
            continue;
        int x0 = x;
        int width = w;
        if (x0 < 0) {
            width += x0;
            x0 = 0;
        }
        if (x0 + width > ZELIARD_WIDTH)
            width = ZELIARD_WIDTH - x0;
        if (width > 0)
            memset(&g_framebuf[yy * ZELIARD_WIDTH + x0], OPDMO_MCGA_BLACK_INDEX,
                   (size_t)width);
    }
}

static void render_dmaou_apparition_background(void) {
    load_dmaou_apparition_disp_data_3c1c();
    render_waku_black_story_shell();
    if (g_dmaou_apparition_overlay.pixels)
        blit_cached_image(&g_dmaou_apparition_overlay);
    draw_story_image_bottom_rule();
}

static void render_guardian_spirit_story(const cached_image_t *background,
                                         const u8 *script,
                                         size_t script_size,
                                         u32 elapsed_ms) {
    render_story_background(background);
    clear_story_rect(0x10, 0x10, 0x13 * 4, 0x70);
    clear_story_rect(0x36 * 4, 0x10, 0x2A * 4, 0x70);
    draw_story_image_bottom_rule();
    render_script_story(NULL, script, script_size, elapsed_ms);
}

static void render_guardian_spirit_overlay_story(const u8 *script,
                                                size_t script_size,
                                                u32 elapsed_ms) {
    const cached_image_t *oui_bg = g_oui_scene_gfx_update_framed.pixels
        ? &g_oui_scene_gfx_update_framed
        : &g_oui_scene;
    render_story_background(oui_bg);
    if (g_sei_disp_data_overlay.pixels)
        blit_cached_image_mcga_row_reveal_passes(&g_sei_disp_data_overlay,
                                                 MCGA_RENDER_PASS_COUNT);
    draw_story_image_bottom_rule();
    render_script_story(NULL, script, script_size, elapsed_ms);
}

static void clear_story_text_area(void) {
    const int x = 0;
    const int y = 0x8F;
    const int w = ZELIARD_WIDTH;
    const int h = 0x39;
    for (int row = 0; row < h && y + row < ZELIARD_HEIGHT; row++)
        memset(&g_framebuf[(y + row) * ZELIARD_WIDTH + x],
               OPDMO_MCGA_BLACK_INDEX, (size_t)w);
}

static void ZEL_UNUSED clear_story_image_window(void) {
    const int x = 0x10;
    const int y = 0x10;
    const int w = 0x48 * 4;
    const int h = 0x68;
    for (int row = 0; row < h && y + row < ZELIARD_HEIGHT; row++)
        memset(&g_framebuf[(y + row) * ZELIARD_WIDTH + x],
               OPDMO_MCGA_BLACK_INDEX, (size_t)w);
}

static void clear_story_rect(int x, int y, int w, int h) {
    if (x < 0) {
        w += x;
        x = 0;
    }
    if (y < 0) {
        h += y;
        y = 0;
    }
    if (x + w > ZELIARD_WIDTH)
        w = ZELIARD_WIDTH - x;
    if (y + h > ZELIARD_HEIGHT)
        h = ZELIARD_HEIGHT - y;
    if (w <= 0 || h <= 0)
        return;

    for (int row = 0; row < h; row++)
        memset(&g_framebuf[(y + row) * ZELIARD_WIDTH + x],
               OPDMO_MCGA_BLACK_INDEX, (size_t)w);
}

static void draw_story_image_bottom_rule(void) {
    const int y = 0x77;
    if (y < 0 || y >= ZELIARD_HEIGHT)
        return;
    for (int x = 0x10; x < 0x130 && x < ZELIARD_WIDTH; x++)
        g_framebuf[y * ZELIARD_WIDTH + x] = 0x66;
}

static void blit_temp_image_opaque(const u8 *pixels, int w, int h, int dx, int dy) {
    if (!pixels)
        return;
    for (int y = 0; y < h; y++) {
        int yy = dy + y;
        if (yy < 0 || yy >= ZELIARD_HEIGHT)
            continue;
        for (int x = 0; x < w; x++) {
            int xx = dx + x;
            if (xx < 0 || xx >= ZELIARD_WIDTH)
                continue;
            g_framebuf[yy * ZELIARD_WIDTH + xx] = pixels[y * w + x];
        }
    }
}

static void render_disp_game_rect_from_segment(const u8 *seg,
                                               u16 di, u16 bx, u16 cx) {
    if (!seg)
        return;

    int rows = (cx >> 8) & 0xFF;
    int cl = cx & 0xFF;
    int dx = ((bx >> 8) & 0xFF) * 4;
    int dy = bx & 0xFF;
    int w = 0;
    int h = 0;
    int bp = rows * cl;
    size_t plane_bytes = (size_t)bp * 3u;
    u8 *planes = (u8 *)malloc(plane_bytes ? plane_bytes : 1u);
    if (!planes)
        return;
    for (size_t i = 0; i < plane_bytes; i++)
        planes[i] = seg[(di + (u16)i) & 0xFFFFu];

    u8 *image = zeliard_mcga_render_three_plane_ab(
        planes, 0, bp, rows, cl, &w, &h);
    free(planes);
    if (!image)
        return;
    blit_temp_image_opaque(image, w, h, dx, dy);
    free(image);
}

static void render_disp_script_area_from_segment(const u8 *seg,
                                                 u16 di, u16 bx, u16 cx) {
    if (!seg)
        return;

    int rows = (cx >> 8) & 0xFF;
    int cl = cx & 0xFF;
    int dx = ((bx >> 8) & 0xFF) * 4;
    int dy = bx & 0xFF;
    int w = 0;
    int h = 0;
    int bp = rows * cl;
    u8 *image = zeliard_mcga_render_three_plane_ab_direct(
        seg, di, bp, rows, cl, &w, &h);
    if (!image)
        return;
    blit_temp_image_opaque(image, w, h, dx, dy);
    free(image);
}

static void render_disp_game_rect_from_yuu_segment(u16 di, u16 bx, u16 cx) {
    render_disp_game_rect_from_segment(g_yuu_anim_seg, di, bx, cx);
}

static void opdmo_mcga_prepare_maop_script_area(u8 *seg, u16 di) {
    if (!seg)
        return;

    for (u16 i = 0; i < 0x1028u; i++) {
        u8 a = seg[(di + i) & 0xFFFFu];
        u8 b = seg[(di + 0x1028u + i) & 0xFFFFu];
        u8 c = seg[(di + 0x2050u + i) & 0xFFFFu];
        u8 al = (u8)(~(a & b & (u8)~c));
        seg[(di + i) & 0xFFFFu] = (u8)(a & al);
        seg[(di + 0x1028u + i) & 0xFFFFu] = (u8)(b & al);
        seg[(di + 0x2050u + i) & 0xFFFFu] = (u8)(c & al);

        al = (u8)(c & (u8)~a & (u8)~b);
        seg[(di + i) & 0xFFFFu] = (u8)(seg[(di + i) & 0xFFFFu] | al);
        seg[(di + 0x1028u + i) & 0xFFFFu] =
            (u8)(seg[(di + 0x1028u + i) & 0xFFFFu] | al);
        seg[(di + 0x2050u + i) & 0xFFFFu] =
            (u8)(seg[(di + 0x2050u + i) & 0xFFFFu] & (u8)~al);
    }
}

static void render_yuu_split_background(void) {
    /* yuu1.grp has been loaded by this point in 100OPDMO's YUU sequence.
     * Keep the dependency at the first renderer that consumes it so direct
     * oracle entrypoints exercise the same runtime state as the live path. */
    ensure_yuu1_scene_loaded();
    const cached_image_t *yuu1_bg = g_yuu1_scene_ax7.pixels ? &g_yuu1_scene_ax7 : &g_yuu1_scene;
    render_story_background(yuu1_bg);

    /* 100OPDMO:940-948 does not reload yuu1 after script 15.  CS:[3020]
     * (105GDMCA:38E6, AX=0) finishes the red inward wipe on the live VGA
     * page, then palette 6 and the two disp_load_setup/disp_game pairs draw
     * into that persistent result.  Reconstruct that completed page before
     * applying the portrait rectangles; starting from yuu1 here makes the
     * center apparition reappear behind them. */
    load_gdmcga_chunk_segment();
    if (g_gdmcga_chunk_seg) {
        (void)zeliard_mcga_disp_font_inv_render_stage(
            g_gdmcga_chunk_seg, 0, g_framebuf, ZELIARD_FB_SIZE, 12);
    }

    load_yuu_anim_segment();
    /* 100OPDMO: AX=6, then the two load/reveal and disp_game pairs. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_LOAD_SETUP, 0x0006,
                         0x0A15, 0x1A5D, 0, 0, 0);
    render_disp_load_setup_rect(0x0A15, 0x1A5D);
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0006,
                         0x0B18, 0x1858, OPDMO_FRAMEBUFFER_A, 0, 0);
    render_disp_game_rect_from_yuu_segment(OPDMO_FRAMEBUFFER_A, 0x0B18, 0x1858);
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_LOAD_SETUP, 0x0006,
                         0x2C15, 0x1A5D, OPDMO_FRAMEBUFFER_A, 0, 0);
    render_disp_load_setup_rect(0x2C15, 0x1A5D);
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0006,
                         0x2D18, 0x1858, 0x8000, 0, 0);
    render_disp_game_rect_from_yuu_segment(0x8000, 0x2D18, 0x1858);
}

static void render_yuu_split_after_maop_background(void) {
    render_maop_reveal_step(24 * OPDMO_WAIT_MS(0x0F));
    load_yuu_anim_segment();
    render_disp_load_setup_rect(0x2C15, 0x1A5D);
    render_disp_load_setup_rect(0x0A15, 0x1A5D);
    render_disp_game_rect_from_yuu_segment(OPDMO_FRAMEBUFFER_A, 0x0B18, 0x1858);
}

static void render_yuu_split_left_return_background(void) {
    /* 100OPDMO:1003-1034 enters gameplay_input_loop with the page produced by
     * the completed MAOP reveal, split restore, and scripts 20/21 still live.
     * There is no YUU1 reload or clear between those operations. */
    render_yuu_split_after_maop_background();
    if (g_story_script_21)
        render_script_story(NULL, g_story_script_21, g_story_script_21_size,
                            0xFFFFFFFFu);
}

static void render_yuu_script_portrait(u8 ch) {
    if (!g_story_anim_source)
        return;

    const u8 *seg = g_story_anim_source_seg
        ? g_story_anim_source_seg
        : (g_story_anim_seg ? g_story_anim_seg : g_yuu_anim_seg);
    u8 frame = (u8)(ch & 0x0F);
    if ((ch & 0xF0u) == 0x80u) {
        if (frame < 6) {
            render_disp_game_rect_from_segment(
                seg, (u16)(0x98C0u + frame * 0x0540u), 0x3350, 0x0E20);
        } else {
            render_disp_game_rect_from_segment(
                seg, (u16)(0xB840u + (frame - 6u) * 0x0210u), 0x3338, 0x0B10);
        }
    } else {
        if (frame < 6) {
            render_disp_game_rect_from_segment(
                seg, (u16)(0x58C0u + frame * 0x0360u), 0x1350, 0x0920);
        } else {
            render_disp_game_rect_from_segment(
                seg, (u16)(0x6D00u + (frame - 6u) * 0x0210u), 0x1238, 0x0B10);
        }
    }
}

static void render_maop_reveal_step(u32 elapsed_ms) {
    render_maop_driver_background();
    if (g_story_script_18)
        render_script_story(NULL, g_story_script_18, g_story_script_18_size,
                            0xFFFFFFFFu);
    if (g_story_script_19)
        render_script_story(NULL, g_story_script_19, g_story_script_19_size,
                            0xFFFFFFFFu);
    render_disp_load_setup_rect_loop_elapsed(0x1515, 0x315D, elapsed_ms);
}

static void render_split_return_reveal_step(u32 elapsed_ms) {
    render_yuu_split_left_return_background();
    render_disp_load_setup_rect_loop_elapsed(0x2C15, 0x1A5D, elapsed_ms);
}

static void draw_centered_line(const char *line, int y, u8 color) {
    if (!line || y < -8 || y >= ZELIARD_HEIGHT)
        return;
    int len = (int)strlen(line);
    int x = (ZELIARD_WIDTH - len * 8) / 2;
    if (x < 0) x = 0;
    zeliard_font_draw_text(&g_font, x, y, line, color);
}

static void draw_title_copyright_text(void) {
    zeliard_font_draw_text(&g_font, TITLE_COPYRIGHT_X, TITLE_COPYRIGHT_Y,
                           TITLE_COPYRIGHT_LINE_1, TITLE_COPYRIGHT_COLOR);
    zeliard_font_draw_text(&g_font, TITLE_COPYRIGHT_X,
                           TITLE_COPYRIGHT_Y + TITLE_COPYRIGHT_LINE_HEIGHT,
                           TITLE_COPYRIGHT_LINE_2, TITLE_COPYRIGHT_COLOR);
}

static void render_scanline_text(const char *const *lines, int line_count,
                                 u32 elapsed_ms) {
    if (!g_font_ready)
        return;

    u32 frame = zel_timer_ms_to_ticks(elapsed_ms) / SCANLINE_FRAME_TICKS;
    const u32 entry_frames = line_count * SCANLINE_ENTRY_FRAMES;
    int newest;
    int subpixel;

    if (frame >= entry_frames)
        frame = entry_frames ? entry_frames - 1 : 0;

    newest = (int)(frame / SCANLINE_ENTRY_FRAMES);
    subpixel = (int)(frame % SCANLINE_ENTRY_FRAMES);

    const int region_top = 32;
    const int region_bottom = region_top + 120;
    for (int i = 0; i <= newest; i++) {
        int y = region_bottom - (newest - i) * 10 - subpixel;
        if (y <= region_top - 10 || y >= region_bottom)
            continue;
        zeliard_font_draw_text(&g_font, 0, y, lines[i], SCANLINE_TEXT_COLOR);
    }
}

static void render_amulet_ancient_prologue_composed(u32 elapsed_ms) {
    opdmo_disp_set_mcga_ax(1);
    framebuf_clear(0);

    if (elapsed_ms < AMULET_FADE_IN_MS) {
        int pass_count = mcga_pass_count_for_elapsed(elapsed_ms);
        load_gfx_draw_scene_pass_frame(g_nec_pass_frames, 1, pass_count);
        blit_cached_image(&g_nec_pass_frames[pass_count]);
        return;
    }

    blit_scene(1);

    elapsed_ms -= AMULET_FADE_IN_MS;

    u32 text_elapsed = elapsed_ms;
    if (text_elapsed > ANCIENT_PROLOGUE_SCROLL_MS)
        text_elapsed = ANCIENT_PROLOGUE_SCROLL_MS;
    render_scanline_text(ANCIENT_PROLOGUE_LINES, ANCIENT_PROLOGUE_LINE_COUNT,
                         text_elapsed);
}

static void reset_amulet_scanline_runtime(void) {
    zel_mcga_runtime_init(&g_amulet_scanline_runtime);
    g_amulet_scanline_runtime_ready = 0;
    g_amulet_scanline_draws = 0;
}

static void reset_credits_scanline_runtime(void) {
    zel_mcga_runtime_init(&g_credits_scanline_runtime);
    g_credits_scanline_runtime_ready = 0;
    g_credits_scanline_draws = 0;
}

static void reset_final_scanline_runtime(void) {
    zel_mcga_runtime_init(&g_final_scanline_runtime);
    g_final_scanline_runtime_ready = 0;
    g_final_scanline_draws = 0;
}

static int start_amulet_scanline_runtime(void) {
    load_opdmo_chunk_segment();
    load_gdmcga_chunk_segment();
    if (!g_font_ready || !g_font.data || !g_opdmo_chunk_seg ||
        !g_gdmcga_chunk_seg)
        return 0;

    /* 100OPDMO calls gfx_init_fn immediately before NEC's completed MCGA
     * draw. Preserve that clear boundary before seeding the scanline VGA
     * segment; otherwise pixels from the preceding title surface survive
     * beneath NEC and every masked 332Ch draw diverges from MASM. */
    framebuf_clear(0);
    blit_scene(1);
    memcpy(g_amulet_scanline_runtime.driver, g_gdmcga_chunk_seg,
           sizeof(g_amulet_scanline_runtime.driver));
    memcpy(g_amulet_scanline_runtime.vga, g_framebuf, ZELIARD_FB_SIZE);
    if (zel_mcga_runtime_begin_scanline_stream(
            &g_amulet_scanline_runtime, g_font.data, g_font.size,
            g_font.ptr_a, g_opdmo_chunk_seg + 0x6FF0,
            OPDMO_SEG_SIZE - 0x6FF0) != 0)
        return 0;
    g_amulet_scanline_runtime_ready = 1;
    g_amulet_scanline_draws = 0;
    return 1;
}

static int render_amulet_scanline_runtime(u32 scroll_ticks) {
    const u32 total_draws = 430;
    u32 wanted_draws = 1u + scroll_ticks / SCANLINE_FRAME_TICKS;
    if (wanted_draws > total_draws)
        wanted_draws = total_draws;

    if (!g_amulet_scanline_runtime_ready && !start_amulet_scanline_runtime())
        return 0;
    if (wanted_draws < g_amulet_scanline_draws) {
        reset_amulet_scanline_runtime();
        if (!start_amulet_scanline_runtime())
            return 0;
    }

    while (g_amulet_scanline_draws < wanted_draws) {
        int result = zel_mcga_runtime_advance_scanline(&g_amulet_scanline_runtime);
        if (result == 0) {
            /* Replay to an absolute OPDMO tick checkpoint.  The live runtime
             * still uses the same 1Ch gate; reconstruction may cross several
             * gates in one browser tick. */
            g_amulet_scanline_runtime.frame_timer = 0x1C;
            continue;
        }
        if (result != 1)
            return 0;
        g_amulet_scanline_draws++;
    }
    memcpy(g_framebuf, zel_mcga_runtime_framebuffer(&g_amulet_scanline_runtime),
           ZELIARD_FB_SIZE);
    return 1;
}

static void render_amulet_ancient_prologue(u32 elapsed_ms) {
    if (g_elapsed_ticks < AMULET_FADE_IN_TICKS)
    {
        render_amulet_ancient_prologue_composed(elapsed_ms);
        return;
    }

    /* The driver waits on the BIOS-derived game tick, so retain it here.
     * Converting the rounded browser milliseconds back to ticks can move a
     * scanline draw across a 1Ch boundary. */
    u32 scroll_ticks = g_elapsed_ticks - AMULET_FADE_IN_TICKS;
    /* animate_scanline owns both halves of this sequence: 31 decoded text
     * records x ten draws, then its 78h-frame AX=0 exit loop.  Do not replace
     * that latter half with a separate high-level clear; it changes the work
     * segment and visible pixels between credits handoff checkpoints. */
    if (scroll_ticks < ANCIENT_PROLOGUE_SCROLL_TICKS +
                       AMULET_TEXT_FADE_OUT_TICKS) {
        if (render_amulet_scanline_runtime(scroll_ticks))
            return;
    }

    /* Phase-local test probes may request an elapsed time after the final
     * 430th draw. Replay the completed driver stream rather than composing a
     * synthetic text frame or a separate clear. */
    (void)render_amulet_scanline_runtime(
        ANCIENT_PROLOGUE_SCROLL_TICKS + AMULET_TEXT_FADE_OUT_TICKS);
}

static void render_amulet_skip_fade(void) {
    /* timer_wait_loop branches to opening_next_scene on Space/Enter.  That
     * path calls gfx_mode_fn(AL=FFh, BX=0000h, CX=50C8h), whose MCGA handler
     * clears the currently presented surface in eight masked 14h-tick
     * passes.  It does not finish animate_scanline's 78h-frame exit loop. */
    memcpy(g_framebuf, g_amulet_skip_frame, sizeof(g_amulet_skip_frame));
    clear_framebuffer_mcga_render_passes(
        mcga_pass_count_for_elapsed(g_amulet_skip_fade_elapsed));
}

static void render_credits_scroll(u32 elapsed_ms) {
    const u32 total_draws = CREDITS_STREAM_RECORDS * SCANLINE_ENTRY_FRAMES +
                            SCANLINE_EXIT_FRAMES;
    u32 wanted_draws = 1u + g_elapsed_ticks / SCANLINE_FRAME_TICKS;

    (void)elapsed_ms;
    load_opdmo_chunk_segment();
    load_gdmcga_chunk_segment();
    if (!g_font_ready || !g_font.data || !g_opdmo_chunk_seg ||
        !g_gdmcga_chunk_seg)
        return;

    if (!g_credits_scanline_runtime_ready) {
        /* 100OPDMO:729-731 selects palette AX=1 immediately before
         * credits_scroll_display. */
        opdmo_disp_set_mcga_ax(1);
        /* opening_next_scene has completed GFX_MODE AL=FF over the full
         * 320x200 surface before credits_scroll_display is entered. */
        framebuf_clear(0);
        memcpy(g_credits_scanline_runtime.driver, g_gdmcga_chunk_seg,
               sizeof(g_credits_scanline_runtime.driver));
        memcpy(g_credits_scanline_runtime.vga, g_framebuf, ZELIARD_FB_SIZE);
        if (zel_mcga_runtime_begin_scanline_stream(
                &g_credits_scanline_runtime, g_font.data, g_font.size,
                g_font.ptr_a, g_opdmo_chunk_seg + 0x742F,
                OPDMO_SEG_SIZE - 0x742F) != 0)
            return;
        g_credits_scanline_runtime_ready = 1;
        g_credits_scanline_draws = 0;
    }

    if (wanted_draws > total_draws)
        wanted_draws = total_draws;
    while (g_credits_scanline_draws < wanted_draws) {
        int result = zel_mcga_runtime_advance_scanline(&g_credits_scanline_runtime);
        if (result == 0) {
            g_credits_scanline_runtime.frame_timer = 0x1C;
            continue;
        }
        if (result != 1)
            return;
        g_credits_scanline_draws++;
    }
    memcpy(g_framebuf, zel_mcga_runtime_framebuffer(&g_credits_scanline_runtime),
           ZELIARD_FB_SIZE);
}

static void render_story_lines(const char *const *lines, int line_count, int top_y) {
    if (!g_font_ready || !lines || line_count <= 0)
        return;
    for (int i = 0; i < line_count; i++)
        draw_centered_line(lines[i], top_y + i * 10, 7);
}

static void render_story_card(const cached_image_t *background,
                              const char *const *lines, int line_count) {
    framebuf_clear(0);
    if (background)
        blit_cached_image(background);
    int top = 138;
    if (line_count > 8)
        top = 124;
    render_story_lines(lines, line_count, top);
}

typedef struct {
    u8 active;
    u8 x;
    u8 y;
    i8 vx;
    i8 vy;
    u8 toggle;
    u8 frame;
    u8 end;
} sprite_obj_state_t;

typedef struct {
    u16 frame_ptr;
    u16 cx;
} sprite_frame_def_t;

static const sprite_frame_def_t SPRITE_A_FRAME_TABLE[] = {
    {0x9000, 0x0620},
    {0x9180, 0x0620},
    {0x9300, 0x0620},
    {0x9480, 0x0620},
    {0x9600, 0x0418},
    {0x96C0, 0x0418},
    {0x9780, 0x0418},
    {0x9840, 0x0418},
};

static const u8 SPRITE_A_PAL_CYCLE[8][3] = {
    {0x1F, 0x1F, 0x00},
    {0x0F, 0x0F, 0x00},
    {0x1F, 0x1F, 0x1F},
    {0x0F, 0x0F, 0x0F},
    {0x1F, 0x00, 0x1F},
    {0x0F, 0x00, 0x0F},
    {0x1F, 0x00, 0x00},
    {0x0F, 0x00, 0x00},
};

static u8 g_sprite_a_base_framebuf[ZELIARD_FB_SIZE];
static u8 g_sprite_a_final_framebuf[ZELIARD_FB_SIZE];
static u8 g_sprite_a_restore_framebuf[ZELIARD_FB_SIZE];

enum {
    SPRITE_A_OBJECT_BYTES = 15,
    SPRITE_A_OBJECT_TABLE_BYTES = SPRITE_A_RECORD_COUNT * SPRITE_A_OBJECT_BYTES,
};

/* 105GDMCA:3437.  Keep the driver's CS:A000 object representation as the
 * source for the C renderer instead of reconstructing a scene-specific state
 * directly from the six-byte OPDMO records. */
static void sprite_a_build_object_table(
    u8 objects[SPRITE_A_OBJECT_TABLE_BYTES]) {
    u16 saved_pixels = 0;
    size_t source = 0;
    size_t dest = 0;

    for (size_t index = 0; index < SPRITE_A_RECORD_COUNT; index++) {
        objects[dest++] = 1;
        objects[dest++] = (u8)saved_pixels;
        objects[dest++] = (u8)(saved_pixels >> 8);
        objects[dest++] = SCENE_SPRITE_A[source++];
        objects[dest++] = SCENE_SPRITE_A[source++];
        objects[dest++] = (u8)saved_pixels;
        objects[dest++] = (u8)(saved_pixels >> 8);
        objects[dest++] = 1;
        objects[dest++] = 1;
        objects[dest++] = SCENE_SPRITE_A[source++];
        objects[dest++] = SCENE_SPRITE_A[source++];
        objects[dest++] = 0;
        objects[dest++] = 0;
        objects[dest++] = SCENE_SPRITE_A[source++];
        objects[dest++] = SCENE_SPRITE_A[source++];
        saved_pixels = (u16)(saved_pixels + 0x0300u);
    }
}

static void sprite_a_init_state(sprite_obj_state_t state[SPRITE_A_RECORD_COUNT]) {
    u8 objects[SPRITE_A_OBJECT_TABLE_BYTES];
    memset(state, 0, sizeof(sprite_obj_state_t) * SPRITE_A_RECORD_COUNT);
    sprite_a_build_object_table(objects);
    for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
        const u8 *object = &objects[i * SPRITE_A_OBJECT_BYTES];
        state[i].active = object[0];
        state[i].y = object[3];
        state[i].x = object[4];
        state[i].vy = (i8)object[9];
        state[i].vx = (i8)object[10];
        state[i].toggle = object[12];
        state[i].frame = object[13];
        state[i].end = object[14];
    }
}

static void sprite_a_step_state(sprite_obj_state_t state[SPRITE_A_RECORD_COUNT]) {
    for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
        sprite_obj_state_t *s = &state[i];
        if (!s->active)
            continue;
        if (s->frame != s->end) {
            s->toggle = (u8)(s->toggle + 1u);
            if ((s->toggle & 1u) == 0)
                s->frame = (u8)(s->frame + 1u);
        }
        s->y = (u8)(s->y + s->vy);
        s->x = (u8)(s->x + s->vx);
    }

    for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
        sprite_obj_state_t *s = &state[i];
        if (!s->active)
            continue;
        s->active = 0;
        if (s->x < 0x4B && s->y < 0xA0)
            s->active = 1;
    }
}

static void sprite_a_state_for_frame(int frame_index,
                                     sprite_obj_state_t state[SPRITE_A_RECORD_COUNT]) {
    if (frame_index < 0)
        frame_index = 0;
    if (frame_index >= SPRITE_A_FRAME_COUNT)
        frame_index = SPRITE_A_FRAME_COUNT - 1;

    sprite_a_init_state(state);
    for (int frame = 0; frame <= frame_index; frame++)
        sprite_a_step_state(state);
}

static void render_sprite_frame_mcga_or(u8 x_cell, u8 y,
                                        const sprite_frame_def_t *frame) {
    if (!g_hou_planes || g_hou_planes_size == 0 || !frame)
        return;

    const int rows = (frame->cx >> 8) & 0xFF;
    const int cl = frame->cx & 0xFF;
    const int bp = rows * cl;
    if (rows <= 0 || cl <= 0 || frame->frame_ptr < 0x9000)
        return;

    const size_t base = (size_t)(frame->frame_ptr - 0x9000u);
    if (base + (size_t)bp * 2u > g_hou_planes_size)
        return;

    const int dst_x0 = (int)x_cell * 4;
    const int dst_y0 = (int)y;
    u16 src_d = 0;

    for (int row = 0; row < cl; row++) {
        for (int col = 0; col < rows; col++) {
            const size_t src = base + (size_t)row * (size_t)rows + (size_t)col;
            u16 src_b = (u16)((u16)g_hou_planes[src + (size_t)bp] << 8);
            u16 src_a = (u16)((u16)g_hou_planes[src] << 8);
            u16 src_c = src_a;

            u16 word0 = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                        &src_b, &src_a);
            u16 word1 = zeliard_mcga_pal_process_words(&src_d, &src_c,
                                                        &src_b, &src_a);
            u8 px[4] = {
                (u8)(word0 & 0xFFu),
                (u8)(word0 >> 8),
                (u8)(word1 & 0xFFu),
                (u8)(word1 >> 8),
            };

            int dst_y = dst_y0 + row;
            int dst_x = dst_x0 + col * 4;
            if (dst_y < 0 || dst_y >= ZELIARD_HEIGHT)
                continue;
            for (int p = 0; p < 4; p++) {
                int dx = dst_x + p;
                if (dx >= 0 && dx < ZELIARD_WIDTH)
                    g_framebuf[dst_y * ZELIARD_WIDTH + dx] |= px[p];
            }
        }
    }
}

static void render_sprite_a_slot(const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT],
                                 int slot) {
    if (slot < 0 || slot >= SPRITE_A_RECORD_COUNT)
        return;
    const sprite_obj_state_t *s = &state[slot];
    if (!s->active ||
        s->frame >= sizeof(SPRITE_A_FRAME_TABLE) / sizeof(SPRITE_A_FRAME_TABLE[0]))
        return;
    render_sprite_frame_mcga_or(s->x, s->y, &SPRITE_A_FRAME_TABLE[s->frame]);
}

static void render_sprite_a_slots(const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT],
                                  int max_slot) {
    if (max_slot < 0)
        return;
    if (max_slot >= SPRITE_A_RECORD_COUNT)
        max_slot = SPRITE_A_RECORD_COUNT - 1;

    for (int i = 0; i <= max_slot; i++)
        render_sprite_a_slot(state, i);
}

/* 105GDMCA:812-830 / copy_to_di_mcga.  The driver restores every object's
 * saved rectangle, including an object that was clipped inactive by the
 * preceding draw pass.  All nine rectangles were saved before any sprite
 * was drawn, so their source is the clean frame snapshot. */
static void restore_sprite_a_slot_from_base(
    const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT], int slot) {
    if (slot < 0 || slot >= SPRITE_A_RECORD_COUNT)
        return;
    const sprite_obj_state_t *s = &state[slot];
    if (s->frame >= sizeof(SPRITE_A_FRAME_TABLE) /
                       sizeof(SPRITE_A_FRAME_TABLE[0]))
        return;

    const u16 cx = SPRITE_A_FRAME_TABLE[s->frame].cx;
    const int width = ((cx >> 8) & 0xFF) * 4;
    const int height = cx & 0xFF;
    const int x0 = (int)s->x * 4;
    const int y0 = (int)s->y;
    for (int row = 0; row < height; row++) {
        const int y = y0 + row;
        if (y < 0 || y >= ZELIARD_HEIGHT)
            continue;
        int x = x0;
        int copy_width = width;
        if (x < 0) {
            copy_width += x;
            x = 0;
        }
        if (x + copy_width > ZELIARD_WIDTH)
            copy_width = ZELIARD_WIDTH - x;
        if (copy_width > 0) {
            memcpy(g_framebuf + y * ZELIARD_WIDTH + x,
                   g_sprite_a_base_framebuf + y * ZELIARD_WIDTH + x,
                   (size_t)copy_width);
        }
    }
}

static void render_sprite_a_restore_snapshot(
    const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT],
    int last_restored_slot) {
    render_sprite_a_slots(state, SPRITE_A_RECORD_COUNT - 1);
    if (last_restored_slot >= SPRITE_A_RECORD_COUNT)
        last_restored_slot = SPRITE_A_RECORD_COUNT - 1;
    for (int slot = 0; slot <= last_restored_slot; slot++)
        restore_sprite_a_slot_from_base(state, slot);
}

static void render_sprite_a_frame5_restore_scanout(
    const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT]) {
    render_sprite_a_slots(state, SPRITE_A_RECORD_COUNT - 1);
    memcpy(g_sprite_a_restore_framebuf, g_framebuf, ZELIARD_FB_SIZE);

    /* copy_to_di_mcga has completed slots 0..6 when the released scanout
     * reaches row 110.  Rows already scanned retain the complete state-5
     * draw; later rows see only the slot-7/8 tail of the restore loop. */
    for (int slot = 0; slot <= 6; slot++)
        restore_sprite_a_slot_from_base(state, slot);
    memcpy(g_framebuf, g_sprite_a_restore_framebuf,
           (size_t)110 * ZELIARD_WIDTH);
}

typedef struct {
    u8 y_start;
    i8 slot;
} sprite_a_dac_band_t;

enum {
    /* Signed slots preserve writes that cross a movement-state boundary:
     * -1 is the preceding frame's ninth write, while 9+ belongs to the next
     * frame.  This out-of-range sentinel denotes the AX=2 state outside the
     * sprite palette loop. */
    SPRITE_A_PALETTE_2_SLOT = -128,
};

static u8 sprite_a_dac_cycle_for_slot(int frame_index, i8 slot) {
    return (u8)(((frame_index * SPRITE_A_RECORD_COUNT) + slot) & 7);
}

/* 105GDMCA:754-772 runs this complete DAC write once for every sprite
 * object, not merely for colour zero.  AX is zero at the call site, so the
 * driver's pal_r_reg table is the AX=0 palette basis with the first RGB
 * triple replaced by the current pal_cycle_tbl value. */
static void sprite_a_apply_palette_write(int frame_index, int slot) {
    u8 cycle = sprite_a_dac_cycle_for_slot(frame_index, (i8)slot);
    const u8 *rgb = SPRITE_A_PAL_CYCLE[cycle & 7u];
    u8 scratch[48];
    const u8 *regs = opdmo_mcga_palette_regs_ax(0, scratch);
    if (regs) {
        palette_set_opdmo_mcga_from_regs_with_rgb0(regs, rgb[0], rgb[1], rgb[2]);
    } else {
        /* The asset-loading fallback keeps native unit tests independent of
         * browser assets; production always takes the real driver bytes. */
        palette_set_opdmo_mcga_with_rgb0(0, rgb[0], rgb[1], rgb[2]);
    }
}

/* 105GDMCA:754-808 calls write_palette_byte_mcga and then draws one object,
 * nine times per movement state.  The released-video row profiles below are
 * keyed to those exact MASM writes: colors are pal_cycle_tbl slots, and the
 * boundaries are the first captured scanline at which each completed write
 * is visible.  Negative/9+ slots retain transactions crossing a movement
 * boundary instead of inventing a stable palette between frame waits. */
static size_t ZEL_UNUSED sprite_a_dac_race_bands_capture_table(
    int frame_index,
    u32 frame_elapsed_ms,
    sprite_a_dac_band_t out[8]) {
    switch (frame_index) {
    case 0:
        if (frame_elapsed_ms < 118u) {
            out[0] = (sprite_a_dac_band_t){0, SPRITE_A_PALETTE_2_SLOT};
            out[1] = (sprite_a_dac_band_t){190, 0};
            return 2;
        }
        out[0] = (sprite_a_dac_band_t){0, 4};
        out[1] = (sprite_a_dac_band_t){40, 5};
        out[2] = (sprite_a_dac_band_t){133, 6};
        out[3] = (sprite_a_dac_band_t){199, 7};
        return 4;
    case 1:
        if (frame_elapsed_ms < 59u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            return 1;
        }
        if (frame_elapsed_ms < 93u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){81, 0};
            return 2;
        }
        out[0] = (sprite_a_dac_band_t){0, 5};
        out[1] = (sprite_a_dac_band_t){13, 6};
        out[2] = (sprite_a_dac_band_t){105, 7};
        return 3;
    case 2:
        if (frame_elapsed_ms < 97u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){54, 0};
            out[2] = (sprite_a_dac_band_t){196, 1};
            return 3;
        }
        out[0] = (sprite_a_dac_band_t){0, 6};
        out[1] = (sprite_a_dac_band_t){77, 7};
        out[2] = (sprite_a_dac_band_t){169, 8};
        return 3;
    case 3:
        if (frame_elapsed_ms < 105u) {
            out[0] = (sprite_a_dac_band_t){0, 7};
            out[1] = (sprite_a_dac_band_t){28, 8};
            out[2] = (sprite_a_dac_band_t){170, 9};
            return 3;
        }
        out[0] = (sprite_a_dac_band_t){0, 6};
        out[1] = (sprite_a_dac_band_t){50, 7};
        out[2] = (sprite_a_dac_band_t){143, 8};
        return 3;
    case 4:
        if (frame_elapsed_ms < 109u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){2, 0};
            out[2] = (sprite_a_dac_band_t){143, 1};
            return 3;
        }
        out[0] = (sprite_a_dac_band_t){0, 6};
        out[1] = (sprite_a_dac_band_t){24, 7};
        out[2] = (sprite_a_dac_band_t){117, 8};
        return 3;
    case 5:
        if (frame_elapsed_ms < 83u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            return 1;
        }
        out[0] = (sprite_a_dac_band_t){0, 5};
        out[1] = (sprite_a_dac_band_t){31, 6};
        out[2] = (sprite_a_dac_band_t){124, 7};
        return 3;
    case 6:
        if (frame_elapsed_ms >= 110u) {
            out[0] = (sprite_a_dac_band_t){0, 0};
            out[1] = (sprite_a_dac_band_t){132, 1};
            out[2] = (sprite_a_dac_band_t){174, 2};
            return 3;
        }
        if (frame_elapsed_ms < 87u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){166, 0};
            return 2;
        }
        out[0] = (sprite_a_dac_band_t){0, 7};
        out[1] = (sprite_a_dac_band_t){84, 8};
        return 2;
    case 7:
        if (frame_elapsed_ms < 95u) {
            out[0] = (sprite_a_dac_band_t){0, 7};
            out[1] = (sprite_a_dac_band_t){132, 8};
            out[2] = (sprite_a_dac_band_t){174, 9};
            return 3;
        }
        out[0] = (sprite_a_dac_band_t){0, 7};
        out[1] = (sprite_a_dac_band_t){48, 8};
        return 2;
    case 8:
        if (frame_elapsed_ms < 104u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){101, 0};
            out[2] = (sprite_a_dac_band_t){144, 1};
            out[3] = (sprite_a_dac_band_t){186, 2};
            return 4;
        }
        out[0] = (sprite_a_dac_band_t){0, 8};
        return 1;
    case 9:
        if (frame_elapsed_ms < 108u) {
            out[0] = (sprite_a_dac_band_t){0, -1};
            out[1] = (sprite_a_dac_band_t){70, 0};
            out[2] = (sprite_a_dac_band_t){113, 1};
            out[3] = (sprite_a_dac_band_t){156, 2};
            return 4;
        }
        out[0] = (sprite_a_dac_band_t){0, 8};
        return 1;
    case 10:
        if (frame_elapsed_ms >= 100u) {
            out[0] = (sprite_a_dac_band_t){0, 0};
            return 1;
        }
        out[0] = (sprite_a_dac_band_t){0, 7};
        out[1] = (sprite_a_dac_band_t){44, 8};
        out[2] = (sprite_a_dac_band_t){87, 9};
        out[3] = (sprite_a_dac_band_t){130, 10};
        return 4;
    case 11:
        if (frame_elapsed_ms >= 86u) {
            out[0] = (sprite_a_dac_band_t){0, 8};
            return 1;
        }
        out[0] = (sprite_a_dac_band_t){0, 7};
        out[1] = (sprite_a_dac_band_t){13, 8};
        out[2] = (sprite_a_dac_band_t){57, 9};
        out[3] = (sprite_a_dac_band_t){99, 10};
        out[4] = (sprite_a_dac_band_t){142, 11};
        out[5] = (sprite_a_dac_band_t){184, 12};
        return 6;
    default:
        return 0;
    }
}

static void render_sprite_a_final_and_raster_rgb(int frame_index,
                                                 u32 frame_elapsed_ms,
                                                 const sprite_obj_state_t state[SPRITE_A_RECORD_COUNT]) {
    memcpy(g_sprite_a_base_framebuf, g_framebuf, ZELIARD_FB_SIZE);
    render_sprite_a_slots(state, SPRITE_A_RECORD_COUNT - 1);
    memcpy(g_sprite_a_final_framebuf, g_framebuf, ZELIARD_FB_SIZE);

    palette_color_t palette_after_slot[SPRITE_A_RECORD_COUNT][256];
    for (int slot = 0; slot < SPRITE_A_RECORD_COUNT; slot++) {
        sprite_a_apply_palette_write(frame_index, slot);
        memcpy(palette_after_slot[slot], g_palette, sizeof(g_palette));
    }

    sprite_a_dac_band_t bands[8];
    size_t band_count = sprite_a_dac_race_bands_capture_table(frame_index,
                                                              frame_elapsed_ms,
                                                              bands);
    if (band_count == 0) {
        framebuf_rgb_disable();
        return;
    }

    /* 105GDMCA:812-830 restores each saved sprite rectangle in object-table
     * order.  The release scanout at the frame-6/7 boundary catches slot 8
     * after slots 0..7 have been restored.  Once the restore returns,
     * sprite_anim_frame_top advances the object table to frame 7 before the
     * next complete draw; it must not replay frame 6. */
    const int restore_slot8_only =
        (frame_index == 6 && frame_elapsed_ms >= 110u) ||
        (frame_index == 7 && frame_elapsed_ms < 95u);
    const int frame6_restore_tail =
        frame_index == 6 && frame_elapsed_ms >= 45u &&
        frame_elapsed_ms < 87u;
    const int frame6_restore_scanout =
        frame_index == 6 && frame_elapsed_ms < 45u;
    const int frame3_restored =
        frame_index == 3 && frame_elapsed_ms < 105u;
    const int frame8_restored =
        frame_index == 8 && frame_elapsed_ms < 104u;
    const int frame10_waiting =
        frame_index == 10 && frame_elapsed_ms >= 100u;
    const int frame5_previous_full =
        frame_index == 5 && frame_elapsed_ms < 83u;
    sprite_obj_state_t frame4_state[SPRITE_A_RECORD_COUNT];
    if (frame5_previous_full)
        sprite_a_state_for_frame(4, frame4_state);
    sprite_obj_state_t frame5_state[SPRITE_A_RECORD_COUNT];
    if (frame6_restore_scanout || frame6_restore_tail)
        sprite_a_state_for_frame(5, frame5_state);
    sprite_obj_state_t frame6_state[SPRITE_A_RECORD_COUNT];
    if (frame_index == 7)
        sprite_a_state_for_frame(6, frame6_state);

    for (int i = 0; i < ZELIARD_FB_SIZE; i++) {
        const palette_color_t c = g_palette[g_framebuf[i]];
        g_rgb_framebuf[i * 3 + 0] = c.r;
        g_rgb_framebuf[i * 3 + 1] = c.g;
        g_rgb_framebuf[i * 3 + 2] = c.b;
    }

    for (size_t band = 0; band < band_count; band++) {
        int y0 = bands[band].y_start;
        int y1 = band + 1 < band_count ? bands[band + 1].y_start : ZELIARD_HEIGHT;
        int raster_frame = frame_index;
        int raster_slot = bands[band].slot;
        const int palette_sequence_slot = raster_slot;
        const int palette_2 = raster_slot == SPRITE_A_PALETTE_2_SLOT;
        while (!palette_2 && raster_slot < 0) {
            raster_frame--;
            raster_slot += SPRITE_A_RECORD_COUNT;
        }
        if (!palette_2 && raster_slot >= SPRITE_A_RECORD_COUNT) {
            raster_frame += raster_slot / SPRITE_A_RECORD_COUNT;
            raster_slot %= SPRITE_A_RECORD_COUNT;
        }
        /* A 30 Hz scanout can catch the final 105GDMCA palette/draw pass
         * after its ninth transaction boundary.  There is no thirteenth
         * movement state: MASM is still displaying the last updated object
         * table until sprite_restore_loop completes, and only then writes
         * AX=2.  Keep that final table and continue cur_col_ctr instead of
         * prematurely substituting the black AX=2 palette. */
        const int terminal_transaction =
            !palette_2 && raster_frame >= SPRITE_A_FRAME_COUNT;
        if (terminal_transaction) {
            raster_frame = frame_index;
            raster_slot = SPRITE_A_RECORD_COUNT - 1;
        }
        int max_slot = palette_2 ? -1 : raster_slot - 1;
        memcpy(g_framebuf, g_sprite_a_base_framebuf, ZELIARD_FB_SIZE);
        if (!palette_2 && (frame3_restored || frame8_restored)) {
            /* The released scanout crosses sprite_restore_loop after all
             * nine 3552h copies but while the frame-3 DAC writes are still
             * visible.  The indexed A000 page is therefore the clean saved
             * background for every band. */
        } else if (!palette_2 && frame5_previous_full) {
            render_sprite_a_slots(frame4_state, SPRITE_A_RECORD_COUNT - 1);
        } else if (!palette_2 && frame10_waiting) {
            render_sprite_a_slots(state, SPRITE_A_RECORD_COUNT - 1);
        } else if (!palette_2 && frame6_restore_scanout) {
            render_sprite_a_frame5_restore_scanout(frame5_state);
        } else if (!palette_2 && frame6_restore_tail) {
            render_sprite_a_restore_snapshot(frame5_state, 7);
        } else if (!palette_2 && restore_slot8_only) {
            render_sprite_a_slot(frame_index == 7 ? frame6_state : state, 8);
        } else if (!palette_2 && raster_frame != frame_index &&
            raster_frame >= 0 && raster_frame < SPRITE_A_FRAME_COUNT) {
            sprite_obj_state_t raster_state[SPRITE_A_RECORD_COUNT];
            sprite_a_state_for_frame(raster_frame, raster_state);
            render_sprite_a_slots(raster_state, max_slot);
        } else if (!palette_2) {
            render_sprite_a_slots(state, max_slot);
        }
        if (!palette_2) {
            if (terminal_transaction) {
                sprite_a_apply_palette_write(frame_index,
                                             palette_sequence_slot);
            } else if (raster_frame == frame_index) {
                memcpy(g_palette, palette_after_slot[raster_slot],
                       sizeof(g_palette));
            } else if (raster_frame >= 0 && raster_frame < SPRITE_A_FRAME_COUNT) {
                sprite_a_apply_palette_write(raster_frame, raster_slot);
            } else {
                /* 105GDMCA:844-845 restores AX=2 when no sprite object
                 * remains active after the final frame. */
                opdmo_disp_set_mcga_ax(2);
            }
        } else {
            opdmo_disp_set_mcga_ax(2);
        }

        for (int y = y0; y < y1; y++) {
            for (int x = 0; x < ZELIARD_WIDTH; x++) {
                const int p = y * ZELIARD_WIDTH + x;
                if (g_framebuf[p] == 0 && palette_2) {
                    g_rgb_framebuf[p * 3 + 0] = 0;
                    g_rgb_framebuf[p * 3 + 1] = 0;
                    g_rgb_framebuf[p * 3 + 2] = 0;
                    continue;
                }
                const palette_color_t c =
                    palette_2
                        ? palette_opdmo_mcga_step_color(2, 8, g_framebuf[p],
                                                        0, 0, 0, 0)
                        : g_palette[g_framebuf[p]];
                g_rgb_framebuf[p * 3 + 0] = c.r;
                g_rgb_framebuf[p * 3 + 1] = c.g;
                g_rgb_framebuf[p * 3 + 2] = c.b;
            }
        }
    }

    memcpy(g_framebuf, g_sprite_a_final_framebuf, ZELIARD_FB_SIZE);
    memcpy(g_palette, palette_after_slot[SPRITE_A_RECORD_COUNT - 1],
           sizeof(g_palette));
    g_rgb_framebuf_active = 1;
}

static void render_scene_sprite_a_frame_at_elapsed(int frame_index,
                                                   u32 frame_elapsed_ms) {
    load_hou_overlay();
    framebuf_clear(0);
    blit_scene(1);

    if (frame_index < 0)
        return;
    if (frame_index >= SPRITE_A_FRAME_COUNT)
        frame_index = SPRITE_A_FRAME_COUNT - 1;

    sprite_obj_state_t state[SPRITE_A_RECORD_COUNT];
    sprite_a_state_for_frame(frame_index, state);

    render_sprite_a_final_and_raster_rgb(frame_index, frame_elapsed_ms, state);
}

static void render_nec_hou_handoff_base(void) {
    /* 100OPDMO reaches this point directly from GFX_BLIT.  Neither the
     * caller nor disp_game clears A000, so HOU is layered over the carried
     * NEC/scanline surface rather than a synthetic black screen. */
    load_nec_hou_handoff_segment();
    /* 105GDMCA:812-830 restores every sprite's saved background rectangle
     * before the next frame.  Snapshot rendering must therefore start from
     * the clean post-GFX_BLIT surface, not the preceding browser frame. */
    framebuf_clear(0);
    if (g_nec_hou_handoff_loaded) {
        int w = 0;
        int h = 0;
        u8 *nec = zeliard_mcga_render_three_plane_ab(
            g_nec_hou_handoff_seg, OPDMO_FRAMEBUFFER_A,
            0x2C * 0x68, 0x2C, 0x68, &w, &h);
        if (nec) {
            blit_temp_image_opaque(nec, w, h, 0x12 * 4, 0x20);
            free(nec);
        }
    }
    if (g_nec_hou_handoff_loaded)
        render_disp_game_rect_from_segment(g_nec_hou_handoff_seg,
                                           0x75A0, 0x2048, 0x1040);
}

static void render_scene_sprite_a_frame_at_elapsed_masm_handoff(
    int frame_index,
    u32 frame_elapsed_ms) {
    load_hou_overlay();
    render_nec_hou_handoff_base();

    if (frame_index < 0)
        return;
    if (frame_index >= SPRITE_A_FRAME_COUNT)
        frame_index = SPRITE_A_FRAME_COUNT - 1;

    sprite_obj_state_t state[SPRITE_A_RECORD_COUNT];
    sprite_a_state_for_frame(frame_index, state);

    render_sprite_a_final_and_raster_rgb(frame_index, frame_elapsed_ms, state);
}

static void render_scene_sprite_a_frame(int frame_index) {
    render_scene_sprite_a_frame_at_elapsed(frame_index, 0);
}

static void render_nec_hou_gfx_blit_transition(u32 elapsed_ms) {
    /* 100OPDMO:378-380 changes to palette 2 and passes the decompressed NEC
     * planes at game:4000 through 105GDMCA's masked GFX_BLIT.  This source is
     * the driver's three-plane output, not the earlier two-plane gfx_draw
     * cache used by animate_scanline.  Replacing its lanes introduces the
     * yellow/red amulet pixels over eight 14h-timed passes. */
    load_nec_hou_handoff_segment();
    if (!g_nec_hou_handoff_loaded)
        return;

    int w = 0;
    int h = 0;
    u8 *pixels = zeliard_mcga_render_three_plane_ab(
        g_nec_hou_handoff_seg, OPDMO_FRAMEBUFFER_A,
        0x2C * 0x68, 0x2C, 0x68, &w, &h);
    if (!pixels)
        return;

    cached_image_t image = {pixels, w, h, 0x12 * 4, 0x20};
    blit_cached_image_mcga_masked_write_passes(
        &image, mcga_pass_count_for_elapsed(elapsed_ms));
    free(pixels);
}

static void ZEL_UNUSED render_nec_hou_transition(u32 elapsed_ms) {
    u32 elapsed_ticks = g_elapsed_ticks;
    opdmo_disp_set_mcga_ax(2);
    if (elapsed_ticks < NEC_HOU_BLIT_TICKS) {
        render_nec_hou_gfx_blit_transition(elapsed_ms);
        return;
    }

    elapsed_ticks -= NEC_HOU_BLIT_TICKS;
    if (elapsed_ticks < NEC_HOU_OVERLAY_SERVICE_TICKS) {
        render_nec_hou_handoff_base();
        /* The released MCGA scanout at the synchronous disp_game return
         * begins before scene_sprite_a but reaches row 190 after its first
         * write_palette_byte_mcga.  Five 236.7 Hz game ticks cover that
         * final 30 Hz scanout interval; use the normal frame-0 transaction
         * renderer so palette and draw ordering remain shared with MASM. */
        if (elapsed_ticks + 5u >= NEC_HOU_OVERLAY_SERVICE_TICKS) {
            sprite_obj_state_t state[SPRITE_A_RECORD_COUNT];
            sprite_a_state_for_frame(0, state);
            render_sprite_a_final_and_raster_rgb(0, 0, state);
        }
        return;
    }

    u32 sprite_elapsed_ticks = elapsed_ticks - NEC_HOU_OVERLAY_SERVICE_TICKS;
    int sprite_frame = (int)(sprite_elapsed_ticks / SPRITE_A_FRAME_WAIT_TICKS);
    u32 frame_elapsed = zel_timer_ticks_to_ms(
        sprite_elapsed_ticks % SPRITE_A_FRAME_WAIT_TICKS);
    render_scene_sprite_a_frame_at_elapsed_masm_handoff(sprite_frame,
                                                        frame_elapsed);
}

static void ZEL_UNUSED render_dmaou_intro(u32 elapsed_ms) {
    load_gdmcga_chunk_segment();
    load_dmaou_prelude_game_segment();
    if (!g_dmaou_entry_work_seg)
        g_dmaou_entry_work_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
    if (!g_dmaou_entry_vga_seg)
        g_dmaou_entry_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);

    render_scene_sprite_a_frame(SPRITE_A_FRAME_COUNT - 1);
    framebuf_rgb_disable();
    /* 105GDMCA sprite_active_check falls through only after all nine sprite
     * records are inactive, then executes `mov ax,2` and jumps directly to
     * palette_write_entry.  The frame-11 renderer above intentionally keeps
     * the palette races visible while that final 1Eh wait is in progress;
     * DMAOU begins after the proc returns, so its carried framebuffer must
     * use the restored AX=2 palette. */
    opdmo_disp_set_mcga_ax(2);
    if (g_gdmcga_chunk_seg && g_dmaou_prelude_scratch_seg &&
        g_dmaou_entry_work_seg && g_dmaou_entry_vga_seg) {
        memset(g_dmaou_entry_work_seg, 0, OPDMO_SEG_SIZE);
        memcpy(g_dmaou_entry_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
        memset(g_dmaou_entry_vga_seg + ZELIARD_FB_SIZE, 0,
               OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);

        int clear_passes = MCGA_RENDER_PASS_COUNT;
        if (elapsed_ms < DMAOU_ENTRY_CLEAR_MS)
            clear_passes = mcga_pass_count_for_elapsed(elapsed_ms);
        (void)zeliard_mcga_disp_render_a_rev_stage(
            g_gdmcga_chunk_seg, OPDMO_SEG_SIZE,
            g_dmaou_prelude_scratch_seg, OPDMO_SEG_SIZE,
            0x1220, 0x2C68, 0,
            g_dmaou_entry_vga_seg, OPDMO_SEG_SIZE, clear_passes);
        if (elapsed_ms < DMAOU_ENTRY_CLEAR_MS) {
            memcpy(g_framebuf, g_dmaou_entry_vga_seg, ZELIARD_FB_SIZE);
            return;
        }

        u32 update_elapsed = elapsed_ms - DMAOU_ENTRY_CLEAR_MS;
        int update_passes = MCGA_RENDER_PASS_COUNT;
        if (update_elapsed < DMAOU_ENTRY_BLIT_MS)
            update_passes = mcga_pass_count_for_elapsed(update_elapsed);
        opdmo_disp_set_mcga_ax(3);
        (void)zeliard_mcga_gfx_update_da_stage(
            g_gdmcga_chunk_seg, OPDMO_SEG_SIZE,
            g_dmaou_prelude_scratch_seg, OPDMO_SEG_SIZE,
            g_dmaou_entry_work_seg, OPDMO_SEG_SIZE,
            0x00FF, 0x1720, 0x2270, 0,
            g_dmaou_entry_vga_seg, OPDMO_SEG_SIZE,
            MCGA_RENDER_PASS_COUNT + update_passes);
        memcpy(g_framebuf, g_dmaou_entry_vga_seg, ZELIARD_FB_SIZE);
    }
    if (elapsed_ms < DMAOU_PRELUDE_ENTRY_MS)
        return;
    elapsed_ms -= DMAOU_PRELUDE_ENTRY_MS;

    /* scene_sprite_loop draws its first page before waiting 14h ticks.  Once
     * the twelve calls finish, their last page remains visible through the
     * following F0 wait that precedes play_sprite_anim_script. */
    size_t sprite_c_frames = 1u + elapsed_ms / DMAOU_SPRITE_C_FRAME_MS;
    if (sprite_c_frames > sizeof(SCENE_SPRITE_C) - 1u)
        sprite_c_frames = sizeof(SCENE_SPRITE_C) - 1u;
    render_scene_sprite_c_pages(sprite_c_frames);
    if (elapsed_ms < DMAOU_SPRITE_C_MS)
        return;
    elapsed_ms -= DMAOU_SPRITE_C_MS;

    if (elapsed_ms < DMAOU_BEFORE_SPRITE_B_MS)
        return;
    elapsed_ms -= DMAOU_BEFORE_SPRITE_B_MS;

    if (elapsed_ms < DMAOU_SPRITE_B_MS) {
        size_t waits = elapsed_ms / DMAOU_SPRITE_C_FRAME_MS;
        render_scene_sprite_b_text_waits(waits);
        return;
    }
    render_scene_sprite_b_text();
    elapsed_ms -= DMAOU_SPRITE_B_MS;

    if (elapsed_ms < DMAOU_AFTER_SPRITE_B_MS)
        return;
    elapsed_ms -= DMAOU_AFTER_SPRITE_B_MS;

    /* 100OPDMO:432-438 performs two more CS:[3014] page draws after the
     * scripted warning: page 2, wait 0Fh, then page 3. */
    render_scene_sprite_c_page(2);
    if (elapsed_ms < DMAOU_EXPLICIT_FRAME_MS)
        return;
    render_scene_sprite_c_page(3);
}

static void ZEL_UNUSED render_title_logo_handoff(u32 elapsed_ms) {
    load_gdmcga_chunk_segment();
    load_opdmo_chunk_segment();
    load_title_runtime_segment();

    if (g_title_complete_frame_ready &&
        elapsed_ms >= TITLE_COLOR_START_MS + TITLE_COLOR_ROTATE_MS) {
        opdmo_disp_set_mcga_ax(4);
        framebuf_rgb_disable();
        memcpy(g_framebuf, g_title_complete_frame,
               sizeof(g_title_complete_frame));
        elapsed_ms -= TITLE_COLOR_START_MS + TITLE_COLOR_ROTATE_MS;
        if (elapsed_ms >= TITLE_GFX_READY_WAIT_MS) {
            elapsed_ms -= TITLE_GFX_READY_WAIT_MS;
            clear_framebuffer_mcga_render_passes(
                mcga_pass_count_for_elapsed(elapsed_ms));
        }
        return;
    }

    /* 100OPDMO:440-443 enters the post-DMAOU title sequence by calling the
     * GMMCGA dispatch word encoded at CS:2000.  That resolves to 2046 with
     * AL=0/BX=0094/CX=501E and clears the speech field in the A000 window.
     * This is a one-shot service call, not a presentation clear. */
    if (!g_title_handoff_speech_clear_done) {
        if (!g_title_vga_seg)
            g_title_vga_seg = (u8 *)calloc(OPDMO_SEG_SIZE, 1);
        if (g_title_vga_seg) {
            memcpy(g_title_vga_seg, g_framebuf, ZELIARD_FB_SIZE);
            memset(g_title_vga_seg + ZELIARD_FB_SIZE, 0,
                   OPDMO_SEG_SIZE - ZELIARD_FB_SIZE);
            (void)zeliard_gmmcga_jashiin_speech_clear(g_title_vga_seg,
                                                       OPDMO_SEG_SIZE,
                                                       0, 0x0094, 0x501E);
            memcpy(g_framebuf, g_title_vga_seg, ZELIARD_FB_SIZE);
        }
        g_title_handoff_speech_clear_done = 1;
    }
    if (!g_title_preclear_frame_ready) {
        memcpy(g_title_preclear_frame, g_framebuf,
               sizeof(g_title_preclear_frame));
        g_title_preclear_frame_ready = 1;
    }
    memcpy(g_framebuf, g_title_preclear_frame, sizeof(g_title_preclear_frame));
    if (elapsed_ms < TITLE_PRE_CLEAR_MS) {
        (void)zeliard_mcga_disp_render_a_rev_stage(
            g_gdmcga_chunk_seg, OPDMO_SEG_SIZE,
            g_title_runtime_seg, OPDMO_SEG_SIZE,
            0x1720, 0x2270, 0x3000,
            g_framebuf, ZELIARD_FB_SIZE,
            mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    (void)zeliard_mcga_disp_render_a_rev_stage(
        g_gdmcga_chunk_seg, OPDMO_SEG_SIZE,
        g_title_runtime_seg, OPDMO_SEG_SIZE,
        0x1720, 0x2270, 0x3000,
        g_framebuf, ZELIARD_FB_SIZE, MCGA_RENDER_PASS_COUNT);
    elapsed_ms -= TITLE_PRE_CLEAR_MS;
    opdmo_disp_set_mcga_ax(4);
    /* 100OPDMO calls CS:[3018] -> 105GDMCA:3707 before its first F0 wait. */
    (void)zeliard_mcga_disp_drv_seg_3_seed(g_framebuf, ZELIARD_FB_SIZE);
    framebuf_rgb_disable();

    /* MASM title handoff:
     *  - ttl1.grp is decoded before the music/driver handoff.
     *  - after wait F0, gfx_update AL=0 draws ttl1 at BX=0B48/CX=3180.
     *    In 105GDMCA this runs two timed MCGA render sweeps.
     *  - after wait F0, ttl3 is decoded and disp_narr_chap3 draws it.
     *  - ttl2 is decoded, disp_narr_open consumes scene_sprite_d, then wait F0.
     *  - the 100-step disp_set color loop holds the resulting composition.
     */
    if (elapsed_ms < OPDMO_WAIT_MS(0xF0))
        return;
    elapsed_ms -= OPDMO_WAIT_MS(0xF0);

    if (elapsed_ms < TITLE_TTL1_UPDATE_MS) {
        (void)render_title_ttl1_update_3088(
            (int)(elapsed_ms / MCGA_RENDER_PASS_MS));
        return;
    }
    elapsed_ms -= TITLE_TTL1_UPDATE_MS;

    /* 100OPDMO:487 has completed the ttl1 CS:3088 update.  Retain its
     * pass-16 pixels throughout the following F0 wait. */
    (void)render_title_ttl1_update_3088(16);

    if (elapsed_ms < OPDMO_WAIT_MS(0xF0))
        return;
    elapsed_ms -= OPDMO_WAIT_MS(0xF0);

    /* 100OPDMO:489-499 decodes the buffered ttl3 planes to game:9000 and
     * invokes CS:[301Ah] -> 105GDMCA:30FCh over the existing ttl1 image.
     * 30FCh runs two eight-pass, 14h-timed loops; exposing only its final
     * framebuffer skipped the captured Zeliard-logo reveal entirely. */
    if (elapsed_ms < TITLE_TTL3_UPDATE_MS) {
        int passes = (int)(elapsed_ms / MCGA_RENDER_PASS_MS);
        if (passes > MCGA_RENDER_PASS_COUNT * 2)
            passes = MCGA_RENDER_PASS_COUNT * 2;
        if (render_title_base_image_30fc(passes) != 0)
            blit_scene(0);
        return;
    }
    if (render_title_base_image_30fc(MCGA_RENDER_PASS_COUNT * 2) != 0)
        blit_scene(0);
    elapsed_ms -= TITLE_TTL3_UPDATE_MS;

    if (elapsed_ms < OPDMO_WAIT_MS(0xF0))
        return;
    elapsed_ms -= OPDMO_WAIT_MS(0xF0);

    if (!g_title_color_base_frame_ready) {
        memcpy(g_title_color_base_frame, g_framebuf,
               sizeof(g_title_color_base_frame));
        g_title_color_base_frame_ready = 1;
    }
    if (elapsed_ms < TITLE_COLOR_ROTATE_MS) {
        render_title_sprite_obj_loop_37b4(elapsed_ms);
        return;
    }
    if (!g_title_complete_frame_ready) {
        render_title_sprite_obj_loop_37b4(TITLE_COLOR_ROTATE_MS);
        memcpy(g_title_complete_frame, g_framebuf,
               sizeof(g_title_complete_frame));
        g_title_complete_frame_ready = 1;
    } else {
        memcpy(g_framebuf, g_title_complete_frame,
               sizeof(g_title_complete_frame));
    }
    if (elapsed_ms < TITLE_COLOR_ROTATE_MS + TITLE_GFX_READY_WAIT_MS)
        return;

    /* 100OPDMO:699-704 opening_next_scene invokes gfx_mode_fn with
     * AL=FF/BX=0000/CX=50C8.  The MCGA driver clears one mask lane before
     * each 14h wait, using the same eight-pass lane order as its blitter. */
    elapsed_ms -= TITLE_COLOR_ROTATE_MS + TITLE_GFX_READY_WAIT_MS;
    clear_framebuffer_mcga_render_passes(
        mcga_pass_count_for_elapsed(elapsed_ms));
}

typedef struct {
    u16 text_x_pos;
    u8 text_y_pos;
    u8 text_color_fg;
    u8 text_color_bg;
    u8 text_attr;
} story_draw_state_t;

static int script_terminates_width(u8 ch) {
    return ch == ' ' ||
           ch == ZELIARD_SCRIPT_SCR_END_SCRIPT ||
           ch == ZELIARD_SCRIPT_SCR_SCROLL ||
           ch == ZELIARD_SCRIPT_SCR_BREAK ||
           ch == ZELIARD_SCRIPT_SCR_DIRECT ||
           ch == ZELIARD_SCRIPT_SCR_PARA ||
           ch == ZELIARD_SCRIPT_SCR_MODE2 ||
           ch == ZELIARD_SCRIPT_SCR_MODE3;
}

static u16 story_text_width(const u8 *script, size_t script_size, size_t pc) {
    u16 width = 0;
    while (pc < script_size) {
        u8 ch = script[pc++];
        if (script_terminates_width(ch))
            return width;
        if (ch & 0x80)
            continue;
        if (ch >= 0x20)
            width = (u16)(width + OPDMO_STORY_ADVANCE[ch - 0x20]);
    }
    return width;
}

static void story_newline(story_draw_state_t *state) {
    state->text_x_pos = 0;
    state->text_y_pos++;
}

static u8 story_palette_index(u8 color_nibble) {
    color_nibble &= 0x0Fu;
    return (u8)((color_nibble << 4) | color_nibble);
}

static void draw_story_char(story_draw_state_t *state, const u8 *script,
                            size_t script_size, size_t pc, u8 ch) {
    if (ch < 0x20)
        return;

    u16 x = (u16)(state->text_x_pos + 4u);
    u16 y = (u16)((u16)state->text_y_pos * 10u + 0x8Fu);
    u8 index = (u8)(ch - 0x20);
    int draw_x = (int)x - (int)OPDMO_STORY_LEFT_BEARING[index];
    int draw_y = (int)y;
    /* MASM calls disp_narr_chap4 twice per glyph: foreground at +1,+1,
     * then background at the base coordinates.  Keep both calls separate in
     * the trace so it can compare directly with the MASM stub-register log. */
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_GLYPH,
                         (u16)(((u16)state->text_color_fg << 8) | ch),
                         (u16)(draw_x + 1), (u16)(draw_y + 1),
                         state->text_color_fg, 0, (u16)(pc - 1));
    zeliard_font_draw_char(&g_font, draw_x + 1, draw_y + 1, ch,
                           story_palette_index(state->text_color_fg));
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_GLYPH,
                         (u16)(((u16)state->text_color_bg << 8) | ch),
                         (u16)draw_x, (u16)draw_y, state->text_color_bg,
                         0, (u16)(pc - 1));
    zeliard_font_draw_char(&g_font, draw_x, draw_y, ch,
                           story_palette_index(state->text_color_bg));
    /* 100OPDMO:1189-1190 writes text_attr to gvar_volume_b for every
     * non-space printable byte. Snapshot redraws must not rewrite old cues. */
    if (story_sound_is_new_glyph(script, pc) && ch != ' ' && state->text_attr &&
        g_sound_cue_sink)
        g_sound_cue_sink(state->text_attr);
    state->text_x_pos = (u16)(state->text_x_pos + OPDMO_STORY_ADVANCE[index]);

    if (ch == ' ') {
        u16 next_word_width = story_text_width(script, script_size, pc);
        if ((u16)(state->text_x_pos + next_word_width) >= 0x0138u)
            story_newline(state);
    }
}

static int apply_story_control(story_draw_state_t *state, u8 ch, u32 *time_ticks,
                               const cached_image_t *background,
                               int draw_enabled, u16 script_pc) {
    if (ch == ZELIARD_SCRIPT_SCR_END_SCRIPT || ch == ZELIARD_SCRIPT_SCR_BREAK)
        return 0;

    u8 high = (u8)(ch & 0xF0u);
    if (high == 0x80 || high == 0x90) {
        if (draw_enabled)
            render_yuu_script_portrait(ch);
        return 1;
    }

    switch (ch) {
    case ZELIARD_SCRIPT_SCR_BOLD:
        state->text_color_fg = 1;
        state->text_color_bg = 7;
        break;
    case ZELIARD_SCRIPT_SCR_NORMAL:
        state->text_color_fg = 0;
        state->text_color_bg = 7;
        break;
    case ZELIARD_SCRIPT_SCR_COLOR6:
        state->text_color_fg = 2;
        state->text_color_bg = 6;
        break;
    case ZELIARD_SCRIPT_SCR_WAIT:
        *time_ticks += STORY_WAIT_TICKS;
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_WAIT, 0x00F0, 0, 0, 0, 0,
                             script_pc);
        break;
    case ZELIARD_SCRIPT_SCR_WAIT3:
        *time_ticks += STORY_WAIT_TICKS * 3u;
        for (int i = 0; i < 3; i++)
            zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_WAIT, 0x00F0,
                                 0, 0, 0, 0, script_pc);
        break;
    case ZELIARD_SCRIPT_SCR_DIRECT:
        state->text_x_pos = 0;
        state->text_y_pos = 0;
        break;
    case ZELIARD_SCRIPT_SCR_PARA:
        state->text_x_pos = 0;
        state->text_y_pos = 1;
        break;
    case ZELIARD_SCRIPT_SCR_MODE2:
        state->text_x_pos = 0;
        state->text_y_pos = 2;
        break;
    case ZELIARD_SCRIPT_SCR_MODE3:
        state->text_x_pos = 0;
        state->text_y_pos = 3;
        break;
    case ZELIARD_SCRIPT_SCR_SCROLL:
        if (draw_enabled) {
            if (background)
                render_story_background(background);
            else
                clear_story_text_area();
        }
        state->text_x_pos = 0;
        state->text_y_pos = 0;
        break;
    case ZELIARD_SCRIPT_SCR_RESET:
        state->text_attr = 0;
        break;
    case ZELIARD_SCRIPT_SCR_SPK_UNK:
        state->text_attr = '=';
        break;
    case ZELIARD_SCRIPT_SCR_SPK_KING:
        state->text_attr = '>';
        break;
    case ZELIARD_SCRIPT_SCR_SPK_NARR:
        state->text_attr = '?';
        break;
    case ZELIARD_SCRIPT_SCR_SPK_DEMON:
        state->text_attr = '@';
        break;
    case ZELIARD_SCRIPT_SCR_SPK_PRINC:
        state->text_attr = 'A';
        break;
    default:
        break;
    }
    return 1;
}

static void run_script_story_state(story_draw_state_t *state,
                                   const cached_image_t *background,
                                   const u8 *script,
                                   size_t script_size,
                                   u32 elapsed_ms,
                                   int draw_enabled) {
    if (!state || !script || !g_font_ready)
        return;

    /* Keep the interpreter on the same integer timer timeline as
     * wait_story_scene_timer.  The browser API is milliseconds, but MASM
     * only observes gvar_frame_timer values, so rounding each byte's delay
     * would move later script bytes and phase boundaries. */
    u32 time_ticks = 0;
    const u32 elapsed_ticks = zel_timer_ms_to_ticks(elapsed_ms);
    int wait_before_fetch = 1;
    for (size_t pc = 0; pc < script_size;) {
        if (wait_before_fetch) {
            time_ticks += STORY_FETCH_TICKS;
            zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_WAIT, 0x0010, 0, 0,
                                 0, 0, (u16)pc);
            if (time_ticks > elapsed_ticks)
                break;
        }
        wait_before_fetch = 1;

        u8 ch = script[pc++];
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_BYTE, ch, 0, 0, 0, 0,
                             (u16)(pc - 1));
        if ((ch & 0x80) == 0) {
            if (draw_enabled)
                draw_story_char(state, script, script_size, pc, ch);
            else if (ch >= 0x20) {
                u8 index = (u8)(ch - 0x20);
                state->text_x_pos =
                    (u16)(state->text_x_pos + OPDMO_STORY_ADVANCE[index]);
                if (ch == ' ') {
                    u16 next_word_width = story_text_width(script, script_size, pc);
                    if ((u16)(state->text_x_pos + next_word_width) >= 0x0138u)
                        story_newline(state);
                }
            }
            continue;
        }

        if ((ch & 0xF0u) == 0x80u || (ch & 0xF0u) == 0x90u)
            wait_before_fetch = 0; /* MASM portrait handlers jump to script_refetch. */
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_SCRIPT_CONTROL, ch,
                             state->text_x_pos, state->text_y_pos,
                             state->text_attr, 0, (u16)(pc - 1));
        if (!apply_story_control(state, ch, &time_ticks, background,
                                 draw_enabled, (u16)(pc - 1)))
            break;
        if (time_ticks > elapsed_ticks)
            break;
    }
}

static void render_script_story(const cached_image_t *background,
                                const u8 *script, size_t script_size,
                                u32 elapsed_ms);

static u8 story_initial_text_attr(const u8 *script) {
    /* text_attr is one shared byte at 6D5Dh in 100OPDMO, not per-script
     * state. These scripts begin after a speaker control followed by BREAK. */
    if (script == g_story_script_14)
        return '=';
    if (script == g_story_script_16)
        return '>';
    if (script == g_story_script_19 || script == g_story_script_20)
        return '?';
    return 0;
}

static void render_script_story_with_colors(const cached_image_t *background,
                                            const u8 *script,
                                            size_t script_size,
                                            u32 elapsed_ms,
                                            u8 initial_fg,
                                            u8 initial_bg) {
    if (background)
        render_story_background(background);
    if (!g_font_ready) return;

    story_draw_state_t state;
    memset(&state, 0, sizeof(state));
    state.text_color_fg = initial_fg;
    state.text_color_bg = initial_bg;
    state.text_attr = story_initial_text_attr(script);
    run_script_story_state(&state, background, script, script_size,
                           elapsed_ms, 1);
}

static void render_script_story(const cached_image_t *background,
                                const u8 *script, size_t script_size,
                                u32 elapsed_ms) {
    render_script_story_with_colors(background, script, script_size,
                                    elapsed_ms, 0, 7);
}

static u32 story_script_duration_ms(const u8 *script, size_t script_size) {
    /* wait_story_scene_timer compares the ISR's integer gvar_frame_timer
     * against AL.  Accumulate those ticks exactly as MASM does, then convert
     * the completed span once; rounding every byte's wait drifts long story
     * scripts far enough to move visible scene transitions. */
    return zel_timer_ticks_to_ms(
        zeliard_opening_script_timer_ticks(script, script_size));
}

static void render_ame_story(u32 elapsed_ms) {
    opdmo_disp_set_mcga_ax(5);

    if (elapsed_ms < RAIN_PRINCESS_WAKU_BLIT_MS) {
        /* 100OPDMO: disp_game AL=00 BX=0000 CX=5088 DI=0000,
         * ES=game_seg+2000h. */
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0000,
                             0x0000, 0x5088, 0x0000, 0x2000, 0);
        /* Both blocking MCGA blits finish before the script begins. Present
         * the complete scene immediately instead of exposing lane passes as
         * an invented fade into the first speech. */
        render_waku_black_story_shell();
        blit_ame_inner_scene_mcga_passes(MCGA_RENDER_PASS_COUNT);
        return;
    }
    elapsed_ms -= RAIN_PRINCESS_WAKU_BLIT_MS;

    if (elapsed_ms < RAIN_PRINCESS_AME_BLIT_MS) {
        /* 100OPDMO: disp_game AL=00 BX=0410 CX=4868 DI=4000. */
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0000,
                             0x0410, 0x4868, 0x4000, 0x0000, 0);
        render_waku_black_story_shell();
        blit_ame_inner_scene_mcga_passes(MCGA_RENDER_PASS_COUNT);
        return;
    }
    elapsed_ms -= RAIN_PRINCESS_AME_BLIT_MS;

    const u8 *script = g_story_script_1 ? g_story_script_1 : OPENING_PROLOGUE_SCRIPT_FALLBACK;
    size_t script_size = g_story_script_1 ? g_story_script_1_size
                                          : sizeof(OPENING_PROLOGUE_SCRIPT_FALLBACK);
    /* The release chunk enters this script at runtime 79C6h, the 'P' just
     * before F0/FE/F3/FA.  text_color_fg and text_color_bg are both zero in
     * the chunk's static script state (6D5Bh/6D5Ch), so that preamble byte is
     * executed but invisible.  FA establishes 0/7 before "Once, long ago". */
    render_script_story_with_colors(&g_ame_scene, script, script_size,
                                    elapsed_ms, 0, 0);
}

static void render_ame_sand_story(u32 elapsed_ms) {
    opdmo_disp_set_mcga_ax(9);
    if (elapsed_ms < HIME_ENTRY_BLIT_MS) {
        /* 100OPDMO.asm lines 842-845:
         *   mov ax,9 / call gfx_palette_fn / BLIT_SCENE_FRAME
         *   LOAD_DATA res_hime_grp
         *
         * 105GDMCA render_blit_entry then runs run_render_passes_mcga:
         * eight masked write passes with the 0x14 frame timer. hime.grp is
         * not loaded until this clean AME-frame redraw completes. */
        render_ame_to_hime_handoff(elapsed_ms);
        return;
    }

    elapsed_ms -= HIME_ENTRY_BLIT_MS;
    if (!g_story_script_2) {
        render_story_card(&g_ame_scene, RAIN_SAND_LINES, RAIN_SAND_LINE_COUNT);
        return;
    }
    /* 100OPDMO.asm loads/decompresses hime.grp here but does not blit it
     * until the later AX=6 BLIT_SCENE_FRAME after this script returns. */
    const u32 script_ms = story_script_duration_ms(g_story_script_2,
                                                    g_story_script_2_size);
    if (elapsed_ms < script_ms) {
        render_script_story(&g_ame_scene, g_story_script_2, g_story_script_2_size,
                            elapsed_ms);
        return;
    }

    /* CS:[3020] -> 105GDMCA:38E6. Rebuild the completed script framebuffer
     * before advancing the driver's twelve frame-timed batches, because the
     * opening renderer is snapshot-based while the MASM driver is stateful. */
    render_script_story(&g_ame_scene, g_story_script_2, g_story_script_2_size,
                        script_ms);
    load_gdmcga_chunk_segment();
    if (!g_gdmcga_chunk_seg)
        return;
    elapsed_ms -= script_ms;
    int wait_count = (int)(elapsed_ms / MCGA_REVEAL_FRAME_MS) + 1;
    if (wait_count > 12)
        wait_count = 12;
    (void)zeliard_mcga_disp_font_inv_render_stage(g_gdmcga_chunk_seg, 0,
                                                   g_framebuf, ZELIARD_FB_SIZE,
                                                   wait_count);
}

static void render_hime_story_3(u32 elapsed_ms) {
    opdmo_disp_set_mcga_ax(6);
    const cached_image_t *bg = g_hime_scene_ax6.pixels ? &g_hime_scene_ax6 : &g_hime_scene;
    const cached_image_t *blend_bg = g_hime_dmaou_blend_scene.pixels
        ? &g_hime_dmaou_blend_scene
        : bg;
    if (elapsed_ms < DMAOU_ENTRY_BLIT_MS) {
        /* The following MCGA dispatch is render_blit_entry ->
         * run_render_passes_mcga; dmaou.grp is not loaded until this pass
         * completes, so the visible source is the clean hime scene_framebuf
         * under palette 6, with the previous script text cleared. */
        framebuf_clear(OPDMO_MCGA_BLACK_INDEX);
        blit_cached_image_mcga_render_passes(bg,
                                             mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    elapsed_ms -= DMAOU_ENTRY_BLIT_MS;

    typedef struct {
        const u8 *script;
        size_t size;
        u32 duration;
    } story_part_t;
    const story_part_t parts[] = {
        {g_story_script_3, g_story_script_3_size,
         story_script_duration_ms(g_story_script_3, g_story_script_3_size)},
        {g_story_script_4, g_story_script_4_size,
         story_script_duration_ms(g_story_script_4, g_story_script_4_size)},
        {g_story_script_5, g_story_script_5_size,
         story_script_duration_ms(g_story_script_5, g_story_script_5_size)},
        {g_story_script_6, g_story_script_6_size,
         story_script_duration_ms(g_story_script_6, g_story_script_6_size)},
        {g_story_script_7, g_story_script_7_size,
         story_script_duration_ms(g_story_script_7, g_story_script_7_size)},
    };
    if (!g_story_script_3) {
        render_story_card(bg, JASHIIN_CURSE_LINES, JASHIIN_CURSE_LINE_COUNT);
        return;
    }
    story_draw_state_t state;
    memset(&state, 0, sizeof(state));
    state.text_color_fg = 0;
    state.text_color_bg = 7;
    for (size_t i = 0; i < sizeof(parts) / sizeof(parts[0]); i++) {
        if (!parts[i].script)
            continue;
        if (elapsed_ms < parts[i].duration) {
            if (i >= 3) {
                (void)blend_bg;
                render_dmaou_apparition_background();
                run_script_story_state(&state, NULL, parts[i].script,
                                       parts[i].size, elapsed_ms, 1);
            } else {
                const cached_image_t *part_bg = (i >= 1) ? blend_bg : bg;
                render_story_background(part_bg);
                if (i == 1) {
                    /* 100OPDMO:855-864 returns from call 03 at the SCR_BREAK
                     * after "presence near her, " and immediately resumes at
                     * "and suddenly" in call 04.  The intervening blend/blit
                     * changes the picture but does not clear the text page.
                     * Rebuild that carried page before drawing call 04. */
                    story_draw_state_t carried_state;
                    memset(&carried_state, 0, sizeof(carried_state));
                    carried_state.text_color_fg = 0;
                    carried_state.text_color_bg = 7;
                    run_script_story_state(&carried_state, part_bg,
                                           parts[0].script, parts[0].size,
                                           parts[0].duration, 1);
                    state = carried_state;
                }
                run_script_story_state(&state, part_bg, parts[i].script,
                                       parts[i].size, elapsed_ms, 1);
            }
            return;
        }
        run_script_story_state(&state, NULL, parts[i].script, parts[i].size,
                               parts[i].duration, 0);
        elapsed_ms -= parts[i].duration;
        if (i == 0) {
            if (elapsed_ms < DMAOU_BLEND_DELAY_MS) {
                render_story_background(bg);
                return;
            }
            elapsed_ms -= DMAOU_BLEND_DELAY_MS;
        } else if (i == 2) {
            /* 100OPDMO:867-872.  Preserve the completed princess/Jashiin
             * text page while disp_data_7420 clears and replaces row lanes
             * across the 0410h/4868h story panel. */
            if (elapsed_ms < DMAOU_APPARITION_REVEAL_MS) {
                story_draw_state_t transition_state;
                memset(&transition_state, 0, sizeof(transition_state));
                transition_state.text_color_fg = 0;
                transition_state.text_color_bg = 7;
                run_script_story_state(&transition_state, bg,
                                       parts[0].script, parts[0].size,
                                       parts[0].duration, 0);
                render_story_background(blend_bg);
                run_script_story_state(&transition_state, blend_bg,
                                       parts[1].script, parts[1].size,
                                       parts[1].duration, 1);
                run_script_story_state(&transition_state, blend_bg,
                                       parts[2].script, parts[2].size,
                                       parts[2].duration, 1);
                load_dmaou_apparition_disp_data_3c1c();
                if (g_dmaou_apparition_overlay.pixels) {
                    blit_cached_image_mcga_row_reveal_passes(
                        &g_dmaou_apparition_overlay,
                        mcga_pass_count_for_elapsed(elapsed_ms));
                }
                return;
            }
            elapsed_ms -= DMAOU_APPARITION_REVEAL_MS;
        }
    }

    if (elapsed_ms < APPARITION_REMOVE_ISI_MS) {
        /* 100OPDMO.asm apparition-removal/ISI setup:
         *   busy_wait_delay AL=2
         *   DISP_GAME AL=0 BX=1728 CX=2230
         *   wait_story_scene_timer AL=0F
         *   busy_wait_delay AL=3
         *   DISP_GAME AL=0 BX=1728 CX=2230
         *   LOAD_DATA isi.grp
         *
         * The two DISP_GAME calls affect the story image rectangle before
         * isi.grp is loaded; the script text remains the completed guardian
         * spirit line until the next phase starts. */
        render_dmaou_apparition_background();
        render_script_story_with_colors(NULL, g_story_script_7,
                                        g_story_script_7_size,
                                        91 * STORY_FETCH_MS, 2, 6);

        if (elapsed_ms < APPARITION_REMOVE_FIRST_DRAW_MS) {
            zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0000,
                                 0x1728, 0x2230, 0x0000, 0x2000, 0);
            render_dmaou_post_busy_display(2, elapsed_ms);
            return;
        }
        elapsed_ms -= APPARITION_REMOVE_FIRST_DRAW_MS;

        if (elapsed_ms < APPARITION_REMOVE_HOLD_MS) {
            /* The first DISP_GAME result remains on the VGA page while
             * wait_story_scene_timer AL=0F advances gvar_frame_timer. */
            zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0000,
                                 0x1728, 0x2230, 0x0000, 0x2000, 0);
            render_dmaou_post_busy_display(2, APPARITION_REMOVE_FIRST_DRAW_MS);
            return;
        }
        elapsed_ms -= APPARITION_REMOVE_HOLD_MS;

        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0000,
                             0x1728, 0x2230, 0x0000, 0x2000, 0);
        render_dmaou_post_busy_display(3, elapsed_ms);
        return;
    }

    (void)blend_bg;
    render_dmaou_apparition_background();
    render_script_story_with_colors(NULL, g_story_script_7,
                                    g_story_script_7_size,
                                    91 * STORY_FETCH_MS, 2, 6);
}

static void render_sei_font_inv_complete(void) {
    ensure_sei_disp_data_loaded();
    const cached_image_t *sei_bg = g_sei_disp_data_ax5.pixels
        ? &g_sei_disp_data_ax5
        : (g_sei_scene_ax5.pixels ? &g_sei_scene_ax5 : &g_sei_scene);
    u32 script12_ms = story_script_duration_ms(g_story_script_12,
                                                g_story_script_12_size);
    if (g_sei_disp_data_overlay.pixels)
        render_guardian_spirit_overlay_story(g_story_script_12,
                                             g_story_script_12_size,
                                             script12_ms);
    else
        render_guardian_spirit_story(sei_bg, g_story_script_12,
                                     g_story_script_12_size, script12_ms);

    load_gdmcga_chunk_segment();
    if (g_gdmcga_chunk_seg) {
        (void)zeliard_mcga_disp_font_inv_render_stage(
            g_gdmcga_chunk_seg, 0, g_framebuf, ZELIARD_FB_SIZE, 12);
    }
}

static void render_hime_story_4(u32 elapsed_ms) {
    opdmo_disp_set_mcga_ax(7);
    const cached_image_t *isi_bg = g_isi_scene_ax7.pixels ? &g_isi_scene_ax7 : &g_isi_scene;
    const cached_image_t *oui_bg = NULL;
    const cached_image_t *sei_bg = NULL;
    typedef struct {
        const cached_image_t *background;
        const u8 *script;
        size_t size;
        u32 duration;
    } story_part_t;
    const story_part_t parts[] = {
        {isi_bg, g_story_script_8, g_story_script_8_size,
         story_script_duration_ms(g_story_script_8, g_story_script_8_size)},
        {isi_bg, g_story_script_9, g_story_script_9_size,
         story_script_duration_ms(g_story_script_9, g_story_script_9_size)},
        {NULL, g_story_script_10, g_story_script_10_size,
         story_script_duration_ms(g_story_script_10, g_story_script_10_size)},
        {NULL, g_story_script_11, g_story_script_11_size,
         story_script_duration_ms(g_story_script_11, g_story_script_11_size)},
        {NULL, g_story_script_12, g_story_script_12_size,
         story_script_duration_ms(g_story_script_12, g_story_script_12_size)},
        {NULL, g_story_script_13, g_story_script_13_size,
         story_script_duration_ms(g_story_script_13, g_story_script_13_size)},
    };
    if (!g_story_script_8 || !g_story_script_9 ||
        !g_story_script_10 || !g_story_script_11 ||
        !g_story_script_12 || !g_story_script_13) {
        render_story_card(isi_bg, KING_SPIRIT_LINES, KING_SPIRIT_LINE_COUNT);
        return;
    }

    if (elapsed_ms < ISI_REVEAL_BLIT_MS) {
        render_waku_black_story_shell();
        render_script_story_with_colors(NULL, g_story_script_7,
                                        g_story_script_7_size,
                                        91 * STORY_FETCH_MS, 2, 6);
        blit_cached_image_mcga_masked_write_passes(
            isi_bg, mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    elapsed_ms -= ISI_REVEAL_BLIT_MS;

    for (size_t i = 0; i < sizeof(parts) / sizeof(parts[0]); i++) {
        if (elapsed_ms < parts[i].duration) {
            const cached_image_t *background = parts[i].background;
            if (i >= 2 && i < 4) {
                ensure_oui_scene_loaded();
                oui_bg = g_oui_scene_gfx_update_framed.pixels
                    ? &g_oui_scene_gfx_update_framed : &g_oui_scene;
                background = oui_bg;
            }
            if (i >= 4) {
                ensure_sei_disp_data_loaded();
                sei_bg = g_sei_disp_data_ax5.pixels
                    ? &g_sei_disp_data_ax5
                    : (g_sei_scene_ax5.pixels ? &g_sei_scene_ax5 : &g_sei_scene);
                background = sei_bg;
            }
            if (i == 5) {
                /* 100OPDMO:925-930 runs script 12, completes CS:[3020], then
                 * executes script 13 on that persistent red VGA page. */
                render_sei_font_inv_complete();
                render_script_story(NULL, parts[i].script, parts[i].size,
                                    elapsed_ms);
            } else if (i >= 4 && g_sei_disp_data_overlay.pixels)
                render_guardian_spirit_overlay_story(parts[i].script,
                                                     parts[i].size,
                                                     elapsed_ms);
            else if (i >= 4)
                render_guardian_spirit_story(background,
                                             parts[i].script,
                                             parts[i].size,
                                             elapsed_ms);
            else
                render_script_story(background, parts[i].script,
                                    parts[i].size, elapsed_ms);
            return;
        }
        elapsed_ms -= parts[i].duration;
        if (i == 0) {
            if (elapsed_ms < ISI_POST_SCRIPT8_BLIT_MS) {
                render_script_story(isi_bg, parts[i].script,
                                    parts[i].size, parts[i].duration);
                blit_cached_image_mcga_masked_write_passes(
                    isi_bg, mcga_pass_count_for_elapsed(elapsed_ms));
                return;
            }
            elapsed_ms -= ISI_POST_SCRIPT8_BLIT_MS;
        } else if (i == 1) {
            /* 100OPDMO:906-913: oui.grp is loaded/decompressed after script
             * 9, immediately before gfx_update_fn begins its transition. */
            ensure_oui_scene_loaded();
            oui_bg = g_oui_scene_gfx_update_framed.pixels
                ? &g_oui_scene_gfx_update_framed : &g_oui_scene;
            const cached_image_t *oui_update = g_oui_scene_gfx_update.pixels
                ? &g_oui_scene_gfx_update
                : &g_oui_scene;
            if (elapsed_ms < OUI_UPDATE_MS) {
                render_script_story(isi_bg, parts[i].script,
                                    parts[i].size, parts[i].duration);
                /* 100OPDMO: xor AL,AL / BX=0410h / CX=4868h / DI=4000h
                 * followed by gfx_update_fn for the OUI transition. */
                zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_GFX_UPDATE, 0x0000,
                                     0x0410, 0x4868, OPDMO_FRAMEBUFFER_A,
                                     0, 0);
                blit_cached_image_mcga_update_elapsed(oui_update, elapsed_ms);
                return;
            }
            elapsed_ms -= OUI_UPDATE_MS;
        } else if (i == 3) {
            /* 100OPDMO:918-924: sei.grp is loaded, decompressed, and passed
             * to disp_data_7420 (AL=5) only after script 11 completes. */
            ensure_sei_disp_data_loaded();
            sei_bg = g_sei_disp_data_ax5.pixels
                ? &g_sei_disp_data_ax5
                : (g_sei_scene_ax5.pixels ? &g_sei_scene_ax5 : &g_sei_scene);
            if (elapsed_ms < SEI_REVEAL_MS) {
                render_script_story(oui_bg, parts[i].script,
                                    parts[i].size, parts[i].duration);
                if (g_sei_disp_data_overlay.pixels) {
                    blit_cached_image_mcga_row_reveal_passes(
                        &g_sei_disp_data_overlay,
                        mcga_pass_count_for_elapsed(elapsed_ms));
                }
                return;
            }
            elapsed_ms -= SEI_REVEAL_MS;
        } else if (i == 4) {
            /* 100OPDMO:926-930: script 12 completes on the SEI frame,
             * then CS:[3020] -> 105GDMCA:38E6 runs for twelve 0Ch waits
             * before script 13 begins. */
            if (elapsed_ms < FONT_INV_TRANSITION_MS) {
                if (g_sei_disp_data_overlay.pixels) {
                    render_guardian_spirit_overlay_story(parts[i].script,
                                                         parts[i].size,
                                                         parts[i].duration);
                } else {
                    render_guardian_spirit_story(parts[i].background,
                                                 parts[i].script,
                                                 parts[i].size,
                                                 parts[i].duration);
                }
                load_gdmcga_chunk_segment();
                if (g_gdmcga_chunk_seg) {
                    int wait_count = (int)(elapsed_ms / MCGA_REVEAL_FRAME_MS) + 1;
                    if (wait_count > 12)
                        wait_count = 12;
                    (void)zeliard_mcga_disp_font_inv_render_stage(
                        g_gdmcga_chunk_seg, 0, g_framebuf, ZELIARD_FB_SIZE,
                        wait_count);
                }
                return;
            }
            elapsed_ms -= FONT_INV_TRANSITION_MS;
        }
    }
    render_sei_font_inv_complete();
    render_script_story(NULL, g_story_script_13, g_story_script_13_size,
                        parts[5].duration);
}

static void render_isi_story(u32 elapsed_ms) {
    ensure_yuu1_scene_loaded();
    const u32 call_14_duration =
        story_script_duration_ms(g_story_script_14, g_story_script_14_size);
    const u32 call_15_duration =
        story_script_duration_ms(g_story_script_15, g_story_script_15_size);
    const cached_image_t *yuu1_bg = g_yuu1_scene_ax7.pixels
        ? &g_yuu1_scene_ax7
        : &g_yuu1_scene;

    if (!g_story_script_14 || !g_story_script_15) {
        opdmo_disp_set_mcga_ax(7);
        render_story_background(yuu1_bg);
        return;
    }
    opdmo_disp_set_mcga_ax(7);

    /* 100OPDMO:929-933 completes script 13 on the existing SEI frame, then
     * loads yuu1.grp and executes GFX_BLIT 0410h,4868h,4000h.  Rebuild that
     * persistent source page and advance the driver's eight masked-write
     * lanes instead of presenting the completed Duke frame immediately. */
    if (elapsed_ms < YUU1_ENTRY_BLIT_MS) {
        render_hime_story_4(KING_SPIRIT_MS);
        blit_story_inner_mcga_masked_write_passes(
            yuu1_bg, mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    elapsed_ms -= YUU1_ENTRY_BLIT_MS;

    if (elapsed_ms < call_14_duration) {
        render_script_story(yuu1_bg, g_story_script_14, g_story_script_14_size,
                            elapsed_ms);
        return;
    }
    elapsed_ms -= call_14_duration;
    if (elapsed_ms < call_15_duration) {
        render_script_story(yuu1_bg, g_story_script_15, g_story_script_15_size,
                            elapsed_ms);
        return;
    }

    /* 100OPDMO:940-944 completes script 15, then invokes the 12-wait
     * CS:[3020] transition before palette 6 and the YUU split setup. */
    render_script_story(yuu1_bg, g_story_script_15, g_story_script_15_size,
                        call_15_duration);
    load_gdmcga_chunk_segment();
    if (!g_gdmcga_chunk_seg)
        return;
    elapsed_ms -= call_15_duration;
    int wait_count = (int)(elapsed_ms / MCGA_REVEAL_FRAME_MS) + 1;
    if (wait_count > 12)
        wait_count = 12;
    (void)zeliard_mcga_disp_font_inv_render_stage(g_gdmcga_chunk_seg, 0,
                                                   g_framebuf, ZELIARD_FB_SIZE,
                                                   wait_count);
}

static void render_oui_sei_story(u32 elapsed_ms) {
    /* 100OPDMO switches to MCGA palette 6 before the YUU split reveal. */
    opdmo_disp_set_mcga_ax(6);
    typedef struct {
        const u8 *script;
        size_t size;
        u32 duration;
        int portrait_anim;
    } story_part_t;
    const story_part_t parts[] = {
        {g_story_script_16, g_story_script_16_size,
         story_script_duration_ms(g_story_script_16, g_story_script_16_size), 1},
        {g_story_script_17, g_story_script_17_size,
         story_script_duration_ms(g_story_script_17, g_story_script_17_size), 0},
    };

    if (!g_story_script_16 || !g_story_script_17) {
        render_yuu_split_background();
        return;
    }
    for (size_t i = 0; i < sizeof(parts) / sizeof(parts[0]); i++) {
        if (elapsed_ms < parts[i].duration) {
            render_yuu_split_background();
            if (parts[i].portrait_anim) {
                load_yuu_anim_segment();
                g_story_anim_source_seg = g_yuu_anim_seg;
            }
            g_story_anim_source = parts[i].portrait_anim;
            render_script_story(NULL, parts[i].script, parts[i].size,
                                elapsed_ms);
            g_story_anim_source = 0;
            g_story_anim_source_seg = NULL;
            return;
        }
        elapsed_ms -= parts[i].duration;
    }

    /* 100OPDMO:964-970 completes scripts 16/17 on the YUU split, then
     * CS:[3020] -> 105GDMCA:38E6 consumes twelve 0Ch waits before MAOP is
     * loaded and palette 8 is selected. */
    render_yuu_split_background();
    render_script_story(NULL, g_story_script_17, g_story_script_17_size,
                        parts[1].duration ? parts[1].duration : 0xFFFFFFFFu);
    load_gdmcga_chunk_segment();
    if (!g_gdmcga_chunk_seg)
        return;
    int wait_count = (int)(elapsed_ms / MCGA_REVEAL_FRAME_MS) + 1;
    if (wait_count > 12)
        wait_count = 12;
    (void)zeliard_mcga_disp_font_inv_render_stage(g_gdmcga_chunk_seg, 0,
                                                   g_framebuf, ZELIARD_FB_SIZE,
                                                   wait_count);
}

static void render_jashiin_intro(u32 elapsed_ms) {
    const u32 maop_reveal_ms = 24 * OPDMO_WAIT_MS(0x0F);
    typedef struct {
        const u8 *script;
        size_t size;
        u32 duration;
    } story_part_t;
    const story_part_t maop_parts[] = {
        {g_story_script_18, g_story_script_18_size,
         story_script_duration_ms(g_story_script_18, g_story_script_18_size)},
        {g_story_script_19, g_story_script_19_size,
         story_script_duration_ms(g_story_script_19, g_story_script_19_size)},
    };
    const story_part_t split_parts[] = {
        {g_story_script_20, g_story_script_20_size,
         story_script_duration_ms(g_story_script_20, g_story_script_20_size)},
        {g_story_script_21, g_story_script_21_size,
         story_script_duration_ms(g_story_script_21, g_story_script_21_size)},
    };
    if (!g_story_script_18 || !g_story_script_19 || !g_story_script_20) {
        opdmo_disp_set_mcga_ax(8);
        render_maop_driver_background();
        return;
    }

    opdmo_disp_set_mcga_ax(8);
    for (size_t i = 0; i < sizeof(maop_parts) / sizeof(maop_parts[0]); i++) {
        if (elapsed_ms < maop_parts[i].duration) {
            render_maop_driver_background();
            render_script_story(NULL, maop_parts[i].script,
                                maop_parts[i].size, elapsed_ms);
            return;
        }
        elapsed_ms -= maop_parts[i].duration;
    }

    if (elapsed_ms < maop_reveal_ms) {
        opdmo_disp_set_mcga_ax(8);
        render_maop_reveal_step(elapsed_ms);
        return;
    }
    elapsed_ms -= maop_reveal_ms;

    opdmo_disp_set_mcga_ax(8);
    for (size_t i = 0; i < sizeof(split_parts) / sizeof(split_parts[0]); i++) {
        if (!split_parts[i].script)
            continue;
        if (elapsed_ms < split_parts[i].duration) {
            render_yuu_split_after_maop_background();
            if (i == 0) {
                load_yuu_anim_segment();
                g_story_anim_source = 1;
                g_story_anim_source_seg = g_yuu_anim_seg;
            }
            render_script_story(NULL, split_parts[i].script,
                                split_parts[i].size, elapsed_ms);
            g_story_anim_source = 0;
            g_story_anim_source_seg = NULL;
            return;
        }
        elapsed_ms -= split_parts[i].duration;
    }
    render_yuu_split_after_maop_background();
    if (g_story_script_21)
        render_script_story(NULL, g_story_script_21, g_story_script_21_size,
                            split_parts[1].duration ? split_parts[1].duration
                                                    : 0xFFFFFFFFu);
}

static void render_jashiin_departure(u32 elapsed_ms) {
    const u32 reveal_duration = 24 * OPDMO_WAIT_MS(0x0F);
    /* 100OPDMO:1016-1038 retains palette 8 from the MAOP sequence throughout
     * the second 24-step load-setup reveal and the following font-inverse
     * transition.  Palette 7 is selected only after both have returned. */
    opdmo_disp_set_mcga_ax(8);
    if (elapsed_ms < reveal_duration) {
        render_yuu_split_left_return_background();
        render_disp_load_setup_rect_loop_elapsed(0x2C15, 0x1A5D, elapsed_ms);
        return;
    }
    elapsed_ms -= reveal_duration;

    /* 100OPDMO:1018-1037 completes the second 24-step reveal loop, then
     * calls CS:[3020] -> 105GDMCA:38E6 before yuu2.grp is loaded for the
     * final narration. */
    if (elapsed_ms < FONT_INV_TRANSITION_MS) {
        render_yuu_split_left_return_background();
        render_disp_load_setup_rect_loop_elapsed(
            0x2C15, 0x1A5D, reveal_duration);
        load_gdmcga_chunk_segment();
        if (g_gdmcga_chunk_seg) {
            int wait_count = (int)(elapsed_ms / MCGA_REVEAL_FRAME_MS) + 1;
            if (wait_count > 12)
                wait_count = 12;
            (void)zeliard_mcga_disp_font_inv_render_stage(
                g_gdmcga_chunk_seg, 0, g_framebuf, ZELIARD_FB_SIZE,
                wait_count);
        }
        return;
    }
    elapsed_ms -= FONT_INV_TRANSITION_MS;

    /* 100OPDMO:1036-1048 keeps CS:[3020]'s completed page alive, switches to
     * palette 7, and draws yuu2 at 1010h.  Its 3160h image is an inset layer;
     * clearing here would discard the WAKU frame and red surround. */
    render_yuu_split_left_return_background();
    render_disp_load_setup_rect_loop_elapsed(0x2C15, 0x1A5D,
                                             reveal_duration);
    load_gdmcga_chunk_segment();
    if (g_gdmcga_chunk_seg)
        (void)zeliard_mcga_disp_font_inv_render_stage(
            g_gdmcga_chunk_seg, 0, g_framebuf, ZELIARD_FB_SIZE, 12);
    opdmo_disp_set_mcga_ax(7);
    zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_DISP_GAME, 0x0007,
                         0x1010, 0x3160, OPDMO_FRAMEBUFFER_A, 0, 0);
    blit_cached_image(&g_yuu2_scene);
    render_script_story(NULL, g_story_script_22, g_story_script_22_size,
                        elapsed_ms);
}

static void render_final_yuu_composite_static(void) {
    if (g_yuu3_final_scene.pixels)
        render_story_background(&g_yuu3_final_scene);
    else
        render_story_background(&g_yuu3_scene);
}

static void render_final_yuu_draw_static(const cached_image_t *draw_image) {
    framebuf_clear(OPDMO_MCGA_BLACK_INDEX);
    /* AL=FF selects 105GDMCA's masked-write path.  Starting black makes its
     * direct source writes, including zero pixels, exact on a time snapshot. */
    blit_cached_image_mcga_masked_write_passes(draw_image,
                                               MCGA_RENDER_PASS_COUNT);
}

static void render_destiny_story(u32 elapsed_ms) {
    const cached_image_t *final_bg = g_yuu3_final_scene.pixels
        ? &g_yuu3_final_scene
        : &g_yuu3_scene;

    if (elapsed_ms < FINAL_SCENE_BLIT_MS) {
        opdmo_disp_set_mcga_ax(7);
        framebuf_clear(OPDMO_MCGA_BLACK_INDEX);
        /* 100OPDMO GFX_BLIT 0808h,40C0h,4000h sets AL=FF before
         * gfx_update_fn.  105GDMCA.render_blit_entry therefore skips its OR
         * pass and performs masked writes, including source zero pixels. */
        blit_cached_image_mcga_masked_write_passes(
            final_bg, mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    elapsed_ms -= FINAL_SCENE_BLIT_MS;

    if (elapsed_ms < FINAL_SCENE_HOLD_MS) {
        opdmo_disp_set_mcga_ax(7);
        render_final_yuu_composite_static();
        return;
    }
    elapsed_ms -= FINAL_SCENE_HOLD_MS;

    const cached_image_t *draw_image = g_yuu3_final_draw_scene.pixels
        ? &g_yuu3_final_draw_scene : final_bg;
    if (elapsed_ms < FINAL_SCENE_DRAW_MS) {
        /* 100OPDMO:1075-1080: AL=FF, BX=0808, CX=40C0, ES:DI=game:4000.
         * The second eight-pass draw uses B/0/0/A, not the prior composite. */
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_GFX_DRAW, 0x00FF,
                             0x0808, 0x40C0, OPDMO_FRAMEBUFFER_A, 0, 0);
        opdmo_disp_set_mcga_ax(7);
        render_final_yuu_composite_static();
        blit_cached_image_mcga_masked_write_passes(
            draw_image, mcga_pass_count_for_elapsed(elapsed_ms));
        return;
    }
    elapsed_ms -= FINAL_SCENE_DRAW_MS;

    const u32 pre_scanline_ticks = FINAL_SCENE_BLIT_TICKS +
                                   FINAL_SCENE_HOLD_TICKS +
                                   FINAL_SCENE_DRAW_TICKS;
    const u32 total_draws = 7u * SCANLINE_ENTRY_FRAMES + 0xA0u;
    u32 scanline_ticks = g_elapsed_ticks > pre_scanline_ticks
        ? g_elapsed_ticks - pre_scanline_ticks : 0;
    u32 wanted_draws = 1u + scanline_ticks / SCANLINE_FRAME_TICKS;

    load_opdmo_chunk_segment();
    load_gdmcga_chunk_segment();
    if (!g_font_ready || !g_font.data || !g_opdmo_chunk_seg ||
        !g_gdmcga_chunk_seg)
        return;

    if (!g_final_scanline_runtime_ready) {
        opdmo_disp_set_mcga_ax(1);
        render_final_yuu_draw_static(draw_image);
        memcpy(g_final_scanline_runtime.driver, g_gdmcga_chunk_seg,
               sizeof(g_final_scanline_runtime.driver));
        memcpy(g_final_scanline_runtime.vga, g_framebuf, ZELIARD_FB_SIZE);
        if (zel_mcga_runtime_begin_scanline_stream_ex(
                &g_final_scanline_runtime, g_font.data, g_font.size,
                g_font.ptr_a, g_opdmo_chunk_seg + 0x7338,
                OPDMO_SEG_SIZE - 0x7338, 0x0014, 0x50A0, 0x00A0) != 0)
            return;
        g_final_scanline_runtime_ready = 1;
        g_final_scanline_draws = 0;
    }
    if (wanted_draws > total_draws)
        wanted_draws = total_draws;
    while (g_final_scanline_draws < wanted_draws) {
        int result = zel_mcga_runtime_advance_scanline(&g_final_scanline_runtime);
        if (result == 0) {
            g_final_scanline_runtime.frame_timer = 0x1C;
            continue;
        }
        if (result != 1)
            return;
        g_final_scanline_draws++;
    }
    memcpy(g_framebuf, zel_mcga_runtime_framebuffer(&g_final_scanline_runtime),
           ZELIARD_FB_SIZE);

    const u32 clear_start_ticks = pre_scanline_ticks +
                                  FINAL_SCENE_TEXT_TICKS +
                                  FINAL_SCENE_FADE_TICKS +
                                  FINAL_SCENE_POST_HOLD_TICKS;
    if (g_elapsed_ticks >= clear_start_ticks) {
        u32 clear_ticks = g_elapsed_ticks - clear_start_ticks;
        int clear_passes = 1 + (int)(clear_ticks / MCGA_RENDER_PASS_TICKS);
        if (clear_passes > MCGA_RENDER_PASS_COUNT)
            clear_passes = MCGA_RENDER_PASS_COUNT;
        zel_opdmo_trace_emit(ZEL_OPDMO_TRACE_GFX_MODE, 0,
                             GFX_MODE_CLEAR_BX, GFX_MODE_CLEAR_CX,
                             0, 0, 0);
        clear_framebuffer_mcga_render_passes(clear_passes);
    }
}

/* ---- public API --------------------------------------------------------- */

void opening_init(void) {
    g_pause_overlay_active = 0;
    g_speed_overlay_active = 0;
    g_restore_overlay_active = 0;
    g_pause_rgb_active = 0;
    memset(g_images, 0, sizeof(g_images));
    memset(&g_hou_overlay, 0, sizeof(g_hou_overlay));
    free(g_hou_planes);
    g_hou_planes = NULL;
    g_hou_planes_size = 0;
    memset(&g_ame_scene, 0, sizeof(g_ame_scene));
    memset(&g_hime_scene, 0, sizeof(g_hime_scene));
    memset(&g_hime_scene_ax9, 0, sizeof(g_hime_scene_ax9));
    memset(&g_hime_scene_ax6, 0, sizeof(g_hime_scene_ax6));
    memset(&g_hime_dmaou_blend_scene, 0, sizeof(g_hime_dmaou_blend_scene));
    free(g_hime_dmaou_blend_seg);
    g_hime_dmaou_blend_seg = NULL;
    free(g_hime_dmaou_ext_seg);
    g_hime_dmaou_ext_seg = NULL;
    free(g_scene_sprite_c_work_seg);
    g_scene_sprite_c_work_seg = NULL;
    free(g_scene_sprite_c_vga_seg);
    g_scene_sprite_c_vga_seg = NULL;
    free(g_scene_sprite_b_work_seg);
    g_scene_sprite_b_work_seg = NULL;
    free(g_scene_sprite_b_vga_seg);
    g_scene_sprite_b_vga_seg = NULL;
    free(g_dmaou_prelude_game_seg);
    g_dmaou_prelude_game_seg = NULL;
    free(g_dmaou_prelude_scratch_seg);
    g_dmaou_prelude_scratch_seg = NULL;
    free(g_dmaou_entry_work_seg);
    g_dmaou_entry_work_seg = NULL;
    free(g_dmaou_entry_vga_seg);
    g_dmaou_entry_vga_seg = NULL;
    free(g_yuu_anim_seg);
    g_yuu_anim_seg = NULL;
    free(g_opdmo_chunk_seg);
    g_opdmo_chunk_seg = NULL;
    free(g_gdmcga_chunk_seg);
    g_gdmcga_chunk_seg = NULL;
    free(g_title_runtime_seg);
    g_title_runtime_seg = NULL;
    free(g_title_vga_seg);
    g_title_vga_seg = NULL;
    free(g_title_base_work_seg);
    g_title_base_work_seg = NULL;
    free(g_title_tile_work_seg);
    g_title_tile_work_seg = NULL;
    free(g_title_driver_work_seg);
    g_title_driver_work_seg = NULL;
    clear_story_anim_segment();
    free(g_nec_hou_handoff_seg);
    g_nec_hou_handoff_seg = NULL;
    g_nec_hou_handoff_loaded = 0;
    free(g_ttl1_planes);
    g_ttl1_planes = NULL;
    g_ttl1_planes_size = 0;
    free(g_ttl3_planes);
    g_ttl3_planes = NULL;
    g_ttl3_planes_size = 0;
    free(g_ttl2_planes);
    g_ttl2_planes = NULL;
    g_ttl2_planes_size = 0;
    free(g_ttl2_tilemap_planes);
    g_ttl2_tilemap_planes = NULL;
    g_ttl2_tilemap_planes_size = 0;
    memset(&g_dmaou_apparition_overlay, 0, sizeof(g_dmaou_apparition_overlay));
    memset(&g_isi_scene, 0, sizeof(g_isi_scene));
    memset(&g_isi_scene_ax7, 0, sizeof(g_isi_scene_ax7));
    memset(&g_oui_scene, 0, sizeof(g_oui_scene));
    memset(&g_oui_scene_gfx_update, 0, sizeof(g_oui_scene_gfx_update));
    memset(&g_oui_scene_gfx_update_framed, 0,
           sizeof(g_oui_scene_gfx_update_framed));
    memset(&g_sei_scene, 0, sizeof(g_sei_scene));
    memset(&g_sei_scene_ax5, 0, sizeof(g_sei_scene_ax5));
    memset(&g_sei_disp_data_ax5, 0, sizeof(g_sei_disp_data_ax5));
    memset(&g_sei_disp_data_overlay, 0, sizeof(g_sei_disp_data_overlay));
    memset(&g_yuu1_scene, 0, sizeof(g_yuu1_scene));
    memset(&g_yuu1_scene_ax7, 0, sizeof(g_yuu1_scene_ax7));
    memset(&g_yuu2_scene, 0, sizeof(g_yuu2_scene));
    memset(&g_yuup_scene, 0, sizeof(g_yuup_scene));
    memset(&g_oup_scene, 0, sizeof(g_oup_scene));
    memset(&g_yuu3_scene, 0, sizeof(g_yuu3_scene));
    memset(&g_yuu3_final_scene, 0, sizeof(g_yuu3_final_scene));
    memset(&g_yuu3_final_draw_scene, 0, sizeof(g_yuu3_final_draw_scene));
    free(g_final_yuu_runtime_seg);
    g_final_yuu_runtime_seg = NULL;
    memset(&g_maop_scene, 0, sizeof(g_maop_scene));
    memset(g_title_pass_frames, 0, sizeof(g_title_pass_frames));
    memset(g_nec_pass_frames, 0, sizeof(g_nec_pass_frames));
    memset(&g_ttl1_layer, 0, sizeof(g_ttl1_layer));
    memset(&g_ttl2_tilemap, 0, sizeof(g_ttl2_tilemap));
    g_elapsed   = 0;
    g_elapsed_ticks = 0;
    g_timer_subtick_accum = 0;
    g_credits_exit_active = 0;
    g_credits_exit_released = 0;
    g_credits_exit_clear_ticks = 0;
    memset(g_story_sound_progress, 0, sizeof(g_story_sound_progress));
    g_done      = 0;
    g_phase     = OPENING_PHASE_COPYRIGHT_TITLE_CARD;
    g_phase_idx = 0;
    g_title_handoff_speech_clear_done = 0;
    g_title_preclear_frame_ready = 0;
    g_title_color_base_frame_ready = 0;
    g_title_complete_frame_ready = 0;
    g_amulet_skip_fade_active = 0;
    g_amulet_skip_base_elapsed = 0;
    g_amulet_skip_fade_elapsed = 0;
    g_amulet_skip_fade_ticks = 0;
    memset(g_amulet_skip_frame, 0, sizeof(g_amulet_skip_frame));
    reset_amulet_scanline_runtime();
    reset_credits_scanline_runtime();
    reset_final_scanline_runtime();
    for (int i = 0; i < NUM_SCENES; i++)
        load_scene(i);
    load_hou_overlay();
    load_ame_scene();
    load_story_scene(&g_hime_scene, &HIME_SCENE);
    load_story_scene(&g_hime_scene_ax9, &HIME_SCENE);
    load_story_scene(&g_hime_scene_ax6, &HIME_SCENE);
    load_hime_dmaou_blend_scene();
    load_story_scene(&g_isi_scene, &ISI_SCENE);
    load_story_scene_plane_mode(&g_isi_scene_ax7, &ISI_SCENE, 7);
    frame_story_scene_with_waku(&g_hime_scene);
    frame_story_scene_with_waku(&g_hime_scene_ax9);
    frame_story_scene_with_waku(&g_hime_scene_ax6);
    frame_story_scene_with_waku(&g_isi_scene);
    frame_story_scene_with_waku(&g_isi_scene_ax7);
    load_story_scene(&g_yuu2_scene, &YUU2_SCENE);
    load_story_scene(&g_yuup_scene, &YUUP_SCENE);
    load_story_scene(&g_oup_scene, &OUP_SCENE);
    load_story_scene(&g_yuu3_scene, &YUU3_SCENE);
    load_final_yuu_scene();
    load_story_scene(&g_maop_scene, &MAOP_SCENE);
    load_title_card_frame();
    load_title_handoff_planes("ttl1.grp", &g_ttl1_planes, &g_ttl1_planes_size);
    load_title_handoff_planes("ttl3.grp", &g_ttl3_planes, &g_ttl3_planes_size);
    load_title_handoff_layer(&g_ttl1_layer, "ttl1.grp");
    load_title_handoff_planes("ttl2.grp", &g_ttl2_planes, &g_ttl2_planes_size);
    build_title_open_tilemap();
    load_story_script_1();
    load_story_script_2();
    load_story_script_3();
    load_story_script_4();
    load_story_script_asset("opdemo_story_script_5.bin", &g_story_script_5,
                            &g_story_script_5_size);
    load_story_script_asset("opdemo_story_script_6.bin", &g_story_script_6,
                            &g_story_script_6_size);
    load_story_script_asset("opdemo_story_script_7.bin", &g_story_script_7,
                            &g_story_script_7_size);
    load_story_script_asset("opdemo_story_script_8.bin", &g_story_script_8,
                            &g_story_script_8_size);
    load_story_script_asset("opdemo_story_script_9.bin", &g_story_script_9,
                            &g_story_script_9_size);
    load_story_script_asset("opdemo_story_script_10.bin", &g_story_script_10,
                            &g_story_script_10_size);
    load_story_script_asset("opdemo_story_script_11.bin", &g_story_script_11,
                            &g_story_script_11_size);
    load_story_script_asset("opdemo_story_script_12.bin", &g_story_script_12,
                            &g_story_script_12_size);
    load_story_script_asset("opdemo_story_script_13.bin", &g_story_script_13,
                            &g_story_script_13_size);
    load_story_script_asset("opdemo_story_script_14.bin", &g_story_script_14,
                            &g_story_script_14_size);
    load_story_script_asset("opdemo_story_script_15.bin", &g_story_script_15,
                            &g_story_script_15_size);
    load_story_script_asset("opdemo_story_script_16.bin", &g_story_script_16,
                            &g_story_script_16_size);
    load_story_script_asset("opdemo_story_script_17.bin", &g_story_script_17,
                            &g_story_script_17_size);
    load_story_script_asset("opdemo_story_script_18.bin", &g_story_script_18,
                            &g_story_script_18_size);
    load_story_script_asset("opdemo_story_script_19.bin", &g_story_script_19,
                            &g_story_script_19_size);
    load_story_script_asset("opdemo_story_script_20.bin", &g_story_script_20,
                            &g_story_script_20_size);
    load_story_script_asset("opdemo_story_script_21.bin", &g_story_script_21,
                            &g_story_script_21_size);
    load_story_script_asset("opdemo_story_script_22.bin", &g_story_script_22,
                            &g_story_script_22_size);
    if (!g_font_ready)
        g_font_ready = zeliard_font_load(&g_font);
    /* 100OPDMO:338-340 selects MCGA palette AX=4 before drawing the
     * copyright stream and invoking the title blit. */
    palette_set_opdmo_mcga(4);
    memcpy(g_title_card_palette, g_palette, sizeof(g_title_card_palette));
    g_title_card_palette[TITLE_COPYRIGHT_COLOR] = (palette_color_t){248, 248, 248};
    palette_set_scene(PALETTE_OPENING);
    memcpy(g_opening_palette, g_palette, sizeof(g_opening_palette));
    platform_log("opening_init: %d scenes ready", NUM_SCENES);
}

static void pause_overlay_set_pixel(int x, int y, u8 index) {
    size_t pixel = (size_t)y * ZELIARD_WIDTH + (size_t)x;
    g_framebuf[pixel] = index;
    if (g_pause_rgb_active) {
        g_rgb_framebuf[pixel * 3u + 0u] = g_palette[index].r;
        g_rgb_framebuf[pixel * 3u + 1u] = g_palette[index].g;
        g_rgb_framebuf[pixel * 3u + 2u] = g_palette[index].b;
    }
}

static void render_credits_gfx_init_clear(void) {
    /* GMMCGA:2C01 vga_vram_init clears scanlines in eight lane passes:
     * 0,8,...192, then 1,9,...193, through lane 7.  Unlike the 105GDMCA
     * masked blits this writes complete 320-byte scanlines. */
    int passes = 1 + (int)(zel_timer_ticks_to_ms(g_credits_exit_clear_ticks) /
                            MCGA_RENDER_PASS_MS);
    if (passes > 8)
        passes = 8;
    memcpy(g_framebuf, g_credits_exit_frame, sizeof(g_credits_exit_frame));
    for (int lane = 0; lane < passes; lane++)
        for (int y = lane; y < ZELIARD_HEIGHT; y += 8)
            memset(g_framebuf + y * ZELIARD_WIDTH, 0, ZELIARD_WIDTH);
    framebuf_rgb_disable();
}

static void begin_credits_exit(void) {
    if (g_credits_exit_active)
        return;
    g_credits_exit_active = 1;
    g_credits_exit_released = 0;
    g_credits_exit_clear_ticks = 0;
    memcpy(g_credits_exit_frame, g_framebuf, sizeof(g_credits_exit_frame));
    render_credits_gfx_init_clear();
}

int opening_credits_exit_waiting(void) {
    return g_credits_exit_active;
}

void opening_credits_exit_release(void) {
    g_credits_exit_released = 1;
}

static void pause_overlay_show_colors(u8 border_color, u8 text_color) {
    if (g_pause_overlay_active)
        return;

    g_pause_rgb_active = g_rgb_framebuf_active;
    for (int row = 0; row < PAUSE_H; row++) {
        size_t src = (size_t)(PAUSE_Y + row) * ZELIARD_WIDTH + PAUSE_X;
        size_t dst = (size_t)row * PAUSE_W;
        memcpy(g_pause_indexed_backup + dst, g_framebuf + src, PAUSE_W);
        memcpy(g_pause_rgb_backup + dst * 3u, g_rgb_framebuf + src * 3u,
               PAUSE_W * 3u);
    }

    /* stick.asm:984-995 calls GMMCGA fn0 with BX=201Eh/CX=1010h,
     * then fn21 with BX=008Ch/CL=22h. */
    for (int row = 0; row < PAUSE_H; row++) {
        for (int col = 0; col < PAUSE_W; col++) {
            u8 color = (row < 2 || row >= PAUSE_H - 2 ||
                        col < 2 || col >= PAUSE_W - 2) ? border_color : 0u;
            pause_overlay_set_pixel(PAUSE_X + col, PAUSE_Y + row, color);
        }
    }
    if (g_font_ready) {
        static const char pause_text[] = "PAUSE";
        for (size_t i = 0; i < sizeof(pause_text) - 1u; i++) {
            int x = 140 + (int)i * 8;
            u8 ch = (u8)pause_text[i];
            size_t glyph = (size_t)g_font.ptr_a + (size_t)(ch - 0x20u) * 8u;
            if (glyph + 8u > g_font.size)
                continue;
            for (int row = 0; row < 8; row++) {
                u8 bits = g_font.data[glyph + (size_t)row];
                for (int col = 0; col < 8; col++) {
                    if (bits & (u8)(0x80u >> col))
                        pause_overlay_set_pixel(x + col, 34 + row, text_color);
                }
            }
        }
    }
    g_pause_overlay_active = 1;
}

void opening_pause_overlay_show(void) {
    /* GMMCGA cinematic mode maps fn0's border to FFh and fn21's selector
     * seven to 77h. */
    pause_overlay_show_colors(0xFF, 0x77);
}

void opening_pause_overlay_show_game(const u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x10000) return;
    const int cinematic = game_seg[0xFF77] != 0;
    /* GMMCGA:2046 uses 0909h outside cinematics. GMMCGA:291A starts
     * char_color at selector one, resolved through tile_color_tbl:24EAh. */
    pause_overlay_show_colors(cinematic ? 0xFF : 0x09,
                              cinematic ? 0x77 : game_seg[0x24EB]);
}

void opening_pause_overlay_hide(void) {
    if (!g_pause_overlay_active)
        return;
    for (int row = 0; row < PAUSE_H; row++) {
        size_t dst = (size_t)(PAUSE_Y + row) * ZELIARD_WIDTH + PAUSE_X;
        size_t src = (size_t)row * PAUSE_W;
        memcpy(g_framebuf + dst, g_pause_indexed_backup + src, PAUSE_W);
        memcpy(g_rgb_framebuf + dst * 3u, g_pause_rgb_backup + src * 3u,
               PAUSE_W * 3u);
    }
    g_rgb_framebuf_active = g_pause_rgb_active;
    g_pause_overlay_active = 0;
}

static void speed_overlay_draw_char(int x, int y, u8 ch, u8 color) {
    if (!g_font_ready || ch < 0x20u)
        return;
    const size_t glyph = (size_t)g_font.ptr_a +
        (size_t)(ch - 0x20u) * 8u;
    if (glyph + 8u > g_font.size)
        return;
    for (int row = 0; row < 8; ++row) {
        const u8 bits = g_font.data[glyph + (size_t)row];
        for (int col = 0; col < 8; ++col)
            if (bits & (u8)(0x80u >> col))
                pause_overlay_set_pixel(x + col, y + row, color);
    }
}

static void speed_overlay_draw_text(int x, int y, const char *text,
                                    u8 color) {
    for (size_t i = 0; text[i]; ++i)
        speed_overlay_draw_char(x + (int)i * 8, y, (u8)text[i], color);
}

void opening_restore_overlay_show_game(const u8 *game_seg, size_t game_size) {
    if (g_restore_overlay_active || g_speed_overlay_active || !game_seg ||
        game_size < 0x10000)
        return;
    g_speed_rgb_active = g_rgb_framebuf_active;
    for (int row = 0; row < SPEED_H; ++row) {
        const size_t src = (size_t)(SPEED_Y + row) * ZELIARD_WIDTH + SPEED_X;
        const size_t dst = (size_t)row * SPEED_W;
        memcpy(g_speed_indexed_backup + dst, g_framebuf + src, SPEED_W);
        memcpy(g_speed_rgb_backup + dst * 3u, g_rgb_framebuf + src * 3u,
               SPEED_W * 3u);
    }
    const int cinematic = game_seg[0xFF77] != 0;
    const u8 border = cinematic ? 0xFF : 0x09;
    g_speed_text_color = cinematic ? 0x77 : game_seg[0x24EB];
    for (int row = 0; row < SPEED_H; ++row)
        for (int col = 0; col < SPEED_W; ++col)
            pause_overlay_set_pixel(SPEED_X + col, SPEED_Y + row,
                (row < 2 || row >= SPEED_H - 2 || col < 2 ||
                 col >= SPEED_W - 2) ? border : 0u);
    /* stick.asm:restore_game_confirm_dlg uses the same AX=0C46h,
     * CX=1028h box as F9, then draws its CR-delimited text at BX=0074h. */
    speed_overlay_draw_text(116, 82, "Restore Game", g_speed_text_color);
    speed_overlay_draw_text(116, 90, " Sure?(Y/N)", g_speed_text_color);
    g_restore_overlay_active = 1;
}

void opening_restore_overlay_hide(void) {
    if (!g_restore_overlay_active)
        return;
    for (int row = 0; row < SPEED_H; ++row) {
        const size_t dst = (size_t)(SPEED_Y + row) * ZELIARD_WIDTH + SPEED_X;
        const size_t src = (size_t)row * SPEED_W;
        memcpy(g_framebuf + dst, g_speed_indexed_backup + src, SPEED_W);
        memcpy(g_rgb_framebuf + dst * 3u, g_speed_rgb_backup + src * 3u,
               SPEED_W * 3u);
    }
    g_rgb_framebuf_active = g_speed_rgb_active;
    g_restore_overlay_active = 0;
}

void opening_speed_overlay_set_digit(u8 digit) {
    if (!g_speed_overlay_active || digit > 9u)
        return;
    for (int row = 0; row < 8; ++row)
        for (int col = 0; col < 8; ++col)
            pause_overlay_set_pixel(204 + col, 90 + row, 0);
    speed_overlay_draw_char(204, 90, (u8)('0' + digit),
                            g_speed_text_color);
}

void opening_speed_overlay_show_game(const u8 *game_seg, size_t game_size,
                                     u8 digit) {
    if (g_speed_overlay_active || g_restore_overlay_active || !game_seg ||
        game_size < 0x10000)
        return;
    g_speed_rgb_active = g_rgb_framebuf_active;
    for (int row = 0; row < SPEED_H; ++row) {
        const size_t src = (size_t)(SPEED_Y + row) * ZELIARD_WIDTH + SPEED_X;
        const size_t dst = (size_t)row * SPEED_W;
        memcpy(g_speed_indexed_backup + dst, g_framebuf + src, SPEED_W);
        memcpy(g_speed_rgb_backup + dst * 3u, g_rgb_framebuf + src * 3u,
               SPEED_W * 3u);
    }
    const int cinematic = game_seg[0xFF77] != 0;
    const u8 border = cinematic ? 0xFF : 0x09;
    g_speed_text_color = cinematic ? 0x77 : game_seg[0x24EB];
    for (int row = 0; row < SPEED_H; ++row)
        for (int col = 0; col < SPEED_W; ++col)
            pause_overlay_set_pixel(SPEED_X + col, SPEED_Y + row,
                (row < 2 || row >= SPEED_H - 2 || col < 2 ||
                 col >= SPEED_W - 2) ? border : 0u);
    /* stick.asm passes BX=0074h/CL=52h for the CR-delimited prompt and
     * BX=00CCh/CL=5Ah for the selected digit. */
    speed_overlay_draw_text(116, 82, "Speed change", g_speed_text_color);
    speed_overlay_draw_text(116, 90, "Select 0-9:", g_speed_text_color);
    g_speed_overlay_active = 1;
    opening_speed_overlay_set_digit(digit <= 9u ? digit : 5u);
}

void opening_speed_overlay_hide(void) {
    if (!g_speed_overlay_active)
        return;
    for (int row = 0; row < SPEED_H; ++row) {
        const size_t dst = (size_t)(SPEED_Y + row) * ZELIARD_WIDTH + SPEED_X;
        const size_t src = (size_t)row * SPEED_W;
        memcpy(g_framebuf + dst, g_speed_indexed_backup + src, SPEED_W);
        memcpy(g_rgb_framebuf + dst * 3u, g_speed_rgb_backup + src * 3u,
               SPEED_W * 3u);
    }
    g_rgb_framebuf_active = g_speed_rgb_active;
    g_speed_overlay_active = 0;
}

void opening_tick(u32 dt_ms) {
    if (g_done) return;

    u32 dt_ticks = zel_timer_advance_ms(&g_timer_subtick_accum, dt_ms);

    if (g_credits_exit_active) {
        g_credits_exit_clear_ticks += dt_ticks;
        if (g_credits_exit_clear_ticks > GFX_MODE_CLEAR_TICKS)
            g_credits_exit_clear_ticks = GFX_MODE_CLEAR_TICKS;
        render_credits_gfx_init_clear();
        if (g_credits_exit_released &&
            g_credits_exit_clear_ticks >= GFX_MODE_CLEAR_TICKS) {
            g_credits_exit_active = 0;
            opening_set_phase(OPENING_PHASE_RAIN_PRINCESS);
        }
        return;
    }

    if (g_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
        g_amulet_skip_fade_active) {
        g_amulet_skip_fade_ticks += dt_ticks;
        g_amulet_skip_fade_elapsed = zel_timer_ticks_to_ms(g_amulet_skip_fade_ticks);
        if (g_amulet_skip_fade_ticks >= GFX_MODE_CLEAR_TICKS) {
            g_amulet_skip_fade_active = 0;
            opening_set_phase(OPENING_PHASE_STAFF_CREDITS);
            return;
        }
        render_amulet_skip_fade();
        return;
    }

    g_elapsed_ticks += dt_ticks;
    g_elapsed = zel_timer_ticks_to_ms(g_elapsed_ticks);

    while (g_phase_idx < OPENING_PHASE_COUNT &&
           g_elapsed_ticks >= OPENING_PHASES[g_phase_idx].duration_ticks) {
        if (g_phase == OPENING_PHASE_STAFF_CREDITS) {
            g_elapsed_ticks = OPENING_PHASES[g_phase_idx].duration_ticks;
            g_elapsed = zel_timer_ticks_to_ms(g_elapsed_ticks);
            begin_credits_exit();
            return;
        }
        g_elapsed_ticks -= OPENING_PHASES[g_phase_idx].duration_ticks;
        g_elapsed = zel_timer_ticks_to_ms(g_elapsed_ticks);
        g_phase_idx++;
        if (g_phase_idx >= OPENING_PHASE_COUNT) {
            g_done = 1;
            g_phase = OPENING_PHASE_DONE;
            return;
        }
        g_phase = OPENING_PHASES[g_phase_idx].phase;
        platform_log("opening: phase %s", OPENING_PHASES[g_phase_idx].manifest_id);
        /* The indexed A000 framebuffer is authoritative across scene changes.
         * RGB scanout is only a host representation of an active MCGA raster
         * effect (sprite-A palette writes).  It must not leak its old bands
         * into the following MASM palette state. */
        framebuf_rgb_disable();
    }

    switch (g_phase) {
    case OPENING_PHASE_COPYRIGHT_TITLE_CARD:
        render_copyright_title_card(g_elapsed);
        break;
    case OPENING_PHASE_AMULET_ANCIENT_PROLOGUE:
        render_amulet_ancient_prologue(g_elapsed);
        break;
    case OPENING_PHASE_NEC_HOU_INTERLUDE:
        render_nec_hou_transition(g_elapsed);
        break;
    case OPENING_PHASE_DMAOU_DEMON_INTRO:
        render_dmaou_intro(g_elapsed);
        break;
    case OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION:
        render_title_logo_handoff(g_elapsed);
        break;
    case OPENING_PHASE_STAFF_CREDITS:
        render_credits_scroll(g_elapsed);
        break;
    case OPENING_PHASE_RAIN_PRINCESS:
        render_ame_story(g_elapsed);
        break;
    case OPENING_PHASE_RAIN_TURNS_TO_SAND:
        render_ame_sand_story(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_CURSES_PRINCESS:
        render_hime_story_3(g_elapsed);
        break;
    case OPENING_PHASE_KING_GRIEF_AND_SPIRIT:
        render_hime_story_4(g_elapsed);
        break;
    case OPENING_PHASE_DUKE_ARRIVES:
        render_isi_story(g_elapsed);
        break;
    case OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS:
        render_oui_sei_story(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_CONFRONTATION:
        render_jashiin_intro(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_DEPARTURE:
        render_jashiin_departure(g_elapsed);
        break;
    case OPENING_PHASE_DESTINY_CARD:
        render_destiny_story(g_elapsed);
        break;
    case OPENING_PHASE_DONE:
        g_done = 1;
        break;
    }
}

int opening_done(void) {
    return g_done;
}

int opening_phase_id(void) {
    return (int)g_phase;
}

u32 opening_phase_elapsed_ms(void) {
    if (g_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
        g_amulet_skip_fade_active)
        return g_amulet_skip_fade_elapsed;
    return zel_timer_ticks_to_ms(g_elapsed_ticks);
}

u32 opening_nec_hou_sprite_debug_word(void) {
    if (g_phase != OPENING_PHASE_NEC_HOU_INTERLUDE)
        return 0xFFFFFFFFu;

    u32 elapsed_ticks = g_elapsed_ticks;
    if (elapsed_ticks < NEC_HOU_BLIT_TICKS + NEC_HOU_OVERLAY_SERVICE_TICKS)
        return 0xFFFFFFFEu;

    u32 sprite_elapsed_ticks = elapsed_ticks - NEC_HOU_BLIT_TICKS -
                               NEC_HOU_OVERLAY_SERVICE_TICKS;
    int frame_index = (int)(sprite_elapsed_ticks / SPRITE_A_FRAME_WAIT_TICKS);
    u32 frame_elapsed = zel_timer_ticks_to_ms(
        sprite_elapsed_ticks % SPRITE_A_FRAME_WAIT_TICKS);
    if (frame_index >= SPRITE_A_FRAME_COUNT) {
        frame_index = SPRITE_A_FRAME_COUNT - 1;
        frame_elapsed = SPRITE_A_FRAME_WAIT_MS - 1;
    }

    sprite_a_dac_band_t bands[8];
    size_t band_count = sprite_a_dac_race_bands_capture_table(frame_index,
                                                              frame_elapsed,
                                                              bands);
    return ((u32)frame_index & 0xFFu) |
           ((frame_elapsed & 0xFFFFu) << 8) |
           (((u32)band_count & 0xFFu) << 24);
}

u32 opening_nec_hou_sprite_debug_slots(void) {
    if (g_phase != OPENING_PHASE_NEC_HOU_INTERLUDE)
        return 0xFFFFFFFFu;

    u32 elapsed_ticks = g_elapsed_ticks;
    if (elapsed_ticks < NEC_HOU_BLIT_TICKS + NEC_HOU_OVERLAY_SERVICE_TICKS)
        return 0xFFFFFFFFu;

    u32 sprite_elapsed_ticks = elapsed_ticks - NEC_HOU_BLIT_TICKS -
                               NEC_HOU_OVERLAY_SERVICE_TICKS;
    int frame_index = (int)(sprite_elapsed_ticks / SPRITE_A_FRAME_WAIT_TICKS);
    u32 frame_elapsed = zel_timer_ticks_to_ms(
        sprite_elapsed_ticks % SPRITE_A_FRAME_WAIT_TICKS);
    if (frame_index >= SPRITE_A_FRAME_COUNT) {
        frame_index = SPRITE_A_FRAME_COUNT - 1;
        frame_elapsed = SPRITE_A_FRAME_WAIT_MS - 1;
    }

    sprite_a_dac_band_t bands[8];
    size_t band_count = sprite_a_dac_race_bands_capture_table(frame_index,
                                                              frame_elapsed,
                                                              bands);
    u32 packed = 0;
    for (size_t i = 0; i < band_count && i < 8; i++) {
        u32 nibble = bands[i].slot < 0 ? 0xFu : ((u32)bands[i].slot & 0xFu);
        packed |= nibble << (i * 4u);
    }
    return packed;
}

void opening_set_phase_for_test(int phase) {
    opening_set_phase((opening_phase_t)phase);
}

void opening_render_phase_for_test(int phase, u32 elapsed_ms) {
    /* Reusing a selected phase must not inject another phase-entry render.
     * This keeps repeated oracle probes observational rather than mutating. */
    if (g_phase != (opening_phase_t)phase)
        opening_set_phase((opening_phase_t)phase);
    if (g_done)
        return;
    g_elapsed_ticks = zel_timer_ms_to_ticks(elapsed_ms);
    g_elapsed = zel_timer_ticks_to_ms(g_elapsed_ticks);
    switch (g_phase) {
    case OPENING_PHASE_COPYRIGHT_TITLE_CARD:
        render_copyright_title_card(g_elapsed);
        break;
    case OPENING_PHASE_AMULET_ANCIENT_PROLOGUE:
        render_amulet_ancient_prologue(g_elapsed);
        break;
    case OPENING_PHASE_NEC_HOU_INTERLUDE:
        render_nec_hou_transition(g_elapsed);
        break;
    case OPENING_PHASE_DMAOU_DEMON_INTRO:
        render_dmaou_intro(g_elapsed);
        break;
    case OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION:
        render_title_logo_handoff(g_elapsed);
        break;
    case OPENING_PHASE_STAFF_CREDITS:
        render_credits_scroll(g_elapsed);
        break;
    case OPENING_PHASE_RAIN_PRINCESS:
        render_ame_story(g_elapsed);
        break;
    case OPENING_PHASE_RAIN_TURNS_TO_SAND:
        render_ame_sand_story(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_CURSES_PRINCESS:
        render_hime_story_3(g_elapsed);
        break;
    case OPENING_PHASE_KING_GRIEF_AND_SPIRIT:
        render_hime_story_4(g_elapsed);
        break;
    case OPENING_PHASE_DUKE_ARRIVES:
        render_isi_story(g_elapsed);
        break;
    case OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS:
        render_oui_sei_story(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_CONFRONTATION:
        render_jashiin_intro(g_elapsed);
        break;
    case OPENING_PHASE_JASHIIN_DEPARTURE:
        render_jashiin_departure(g_elapsed);
        break;
    case OPENING_PHASE_DESTINY_CARD:
        render_destiny_story(g_elapsed);
        break;
    case OPENING_PHASE_DONE:
        g_done = 1;
        break;
    }
}

void opening_set_yuu_plane_variant_for_test(int variant) {
    (void)variant;
}

void opening_set_title_tilemap_variant_for_test(int variant) {
    if (g_title_tilemap_variant == variant)
        return;
    free(g_ttl2_tilemap.pixels);
    memset(&g_ttl2_tilemap, 0, sizeof(g_ttl2_tilemap));
    free(g_ttl2_tilemap_planes);
    g_ttl2_tilemap_planes = NULL;
    g_ttl2_tilemap_planes_size = 0;
    g_title_tilemap_variant = variant;
}

void opening_set_dmaou_apparition_mode_for_test(int mode) {
    g_dmaou_apparition_mode_for_test = mode;
}

void opening_set_ame_render_mode_for_test(int mode) {
    g_ame_render_mode_for_test = mode;
}

void opening_render_cached_scene_for_test(int scene_idx) {
    framebuf_clear(0);
    if (scene_idx >= 0 && scene_idx < NUM_SCENES)
        blit_scene(scene_idx);
}

void opening_debug_render_late_frame(opening_debug_late_frame_t frame) {
    opening_init();
    memcpy(g_palette, g_opening_palette, sizeof(g_palette));
    switch (frame) {
    case OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_00:
        render_maop_reveal_step(0);
        break;
    case OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_12:
        render_maop_reveal_step(12 * OPDMO_WAIT_MS(0x0F));
        break;
    case OPENING_DEBUG_LATE_SPLIT_RETURN_STEP_12:
        render_split_return_reveal_step(12 * OPDMO_WAIT_MS(0x0F));
        break;
    case OPENING_DEBUG_LATE_FINAL_YUU3_YUU4:
        opdmo_disp_set_mcga_ax(7);
        render_final_yuu_composite_static();
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_96:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 96);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_24:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 24);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_48:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 48);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_72:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 72);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_192:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 192);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_120:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 120);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_144:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 144);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_168:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring_budgeted(0x0F, 168);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX06_FULL:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring(0x06);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX08_FULL:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring(0x08);
        break;
    case OPENING_DEBUG_LATE_DISP_LOAD_AX0F_FULL:
        framebuf_clear(0);
        render_disp_load_setup_scroll_ring(0x0F);
        break;
    case OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_LEFT:
        framebuf_clear(0);
        render_disp_load_setup_rect(0x0A15, 0x1A5D);
        break;
    case OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_RIGHT:
        framebuf_clear(0);
        render_disp_load_setup_rect(0x2C15, 0x1A5D);
        break;
    case OPENING_DEBUG_DISP_LOAD_SETUP_RECT_MAOP:
        framebuf_clear(0);
        render_disp_load_setup_rect(0x1515, 0x315D);
        break;
    case OPENING_DEBUG_LATE_WAKU_AME_AX9:
        opdmo_disp_set_mcga_ax(9);
        render_story_background(&g_ame_scene);
        break;
    case OPENING_DEBUG_LATE_WAKU_HIME_AX9:
        opdmo_disp_set_mcga_ax(9);
        render_story_background(&g_hime_scene_ax9);
        break;
    case OPENING_DEBUG_LATE_WAKU_HIME_AX6:
        opdmo_disp_set_mcga_ax(6);
        render_story_background(&g_hime_scene_ax6);
        break;
    case OPENING_DEBUG_LATE_WAKU_ISI_AX7:
        opdmo_disp_set_mcga_ax(7);
        render_story_background(&g_isi_scene_ax7);
        break;
    case OPENING_DEBUG_LATE_MAOP_SCRIPT_AREA:
        render_maop_driver_background();
        break;
    case OPENING_DEBUG_LATE_OUI_GFX_UPDATE_FULL:
        framebuf_clear(0);
        ensure_oui_scene_loaded();
        blit_cached_image_mcga_update_full(&g_oui_scene_gfx_update);
        break;
    case OPENING_DEBUG_LATE_SEI_3C1C_PASS_01:
        load_disp_data_3c1c_overlay(&g_sei_disp_data_overlay, &SEI_SCENE, 5,
                                    0x1610, 0x2468);
        framebuf_clear(0);
        blit_cached_image_mcga_row_reveal_passes(&g_sei_disp_data_overlay, 1);
        break;
    case OPENING_DEBUG_LATE_SEI_3C1C_PASS_02:
        load_disp_data_3c1c_overlay(&g_sei_disp_data_overlay, &SEI_SCENE, 5,
                                    0x1610, 0x2468);
        framebuf_clear(0);
        blit_cached_image_mcga_row_reveal_passes(&g_sei_disp_data_overlay, 2);
        break;
    case OPENING_DEBUG_LATE_SEI_3C1C_PASS_04:
        load_disp_data_3c1c_overlay(&g_sei_disp_data_overlay, &SEI_SCENE, 5,
                                    0x1610, 0x2468);
        framebuf_clear(0);
        blit_cached_image_mcga_row_reveal_passes(&g_sei_disp_data_overlay, 4);
        break;
    case OPENING_DEBUG_LATE_SEI_3C1C_PASS_08:
        load_disp_data_3c1c_overlay(&g_sei_disp_data_overlay, &SEI_SCENE, 5,
                                    0x1610, 0x2468);
        framebuf_clear(0);
        blit_cached_image_mcga_row_reveal_passes(&g_sei_disp_data_overlay, 8);
        break;
    }
}


void opening_skip(void) {
    g_done = 1;
}

void opening_set_sound_cue_sink(void (*sink)(u8 cue)) {
    g_sound_cue_sink = sink;
}

static void opening_set_phase_index(int idx) {
    if (idx < 0)
        idx = 0;
    if (idx >= OPENING_PHASE_COUNT) {
        g_done = 1;
        g_phase = OPENING_PHASE_DONE;
        return;
    }
    g_phase_idx = idx;
    g_phase = OPENING_PHASES[g_phase_idx].phase;
    g_title_handoff_speech_clear_done = 0;
    g_title_preclear_frame_ready = 0;
    g_title_color_base_frame_ready = 0;
    g_title_complete_frame_ready = 0;
    g_elapsed = 0;
    g_elapsed_ticks = 0;
    g_timer_subtick_accum = 0;
    g_amulet_skip_fade_active = 0;
    g_amulet_skip_base_elapsed = 0;
    g_amulet_skip_fade_elapsed = 0;
    g_amulet_skip_fade_ticks = 0;
    g_credits_exit_active = 0;
    g_credits_exit_released = 0;
    g_credits_exit_clear_ticks = 0;
    memset(g_amulet_skip_frame, 0, sizeof(g_amulet_skip_frame));
    reset_amulet_scanline_runtime();
    reset_credits_scanline_runtime();
    reset_final_scanline_runtime();
    framebuf_rgb_disable();
    platform_log("opening: key advance to phase %s", OPENING_PHASES[g_phase_idx].manifest_id);
    opening_tick(0);
}

static void opening_set_phase(opening_phase_t phase) {
    for (int i = 0; i < OPENING_PHASE_COUNT; i++) {
        if (OPENING_PHASES[i].phase == phase) {
            opening_set_phase_index(i);
            return;
        }
    }
    g_done = 1;
    g_phase = OPENING_PHASE_DONE;
}

void opening_key_advance(void) {
    if (g_done)
        return;

    switch (g_phase) {
    case OPENING_PHASE_COPYRIGHT_TITLE_CARD:
        /* The first title/copyright card has no MASM input wait before NEC/HOU. */
        return;

    case OPENING_PHASE_AMULET_ANCIENT_PROLOGUE:
        if (g_amulet_skip_fade_active) {
            /* opening_next_scene is blocked inside gfx_mode_fn until all
             * eight MCGA passes finish, so input is not polled here. */
            return;
        }
        g_amulet_skip_fade_active = 1;
        g_amulet_skip_base_elapsed = g_elapsed;
        memcpy(g_amulet_skip_frame, g_framebuf, sizeof(g_amulet_skip_frame));
        g_amulet_skip_fade_elapsed = 0;
        g_amulet_skip_fade_ticks = 0;
        opening_tick(0);
        return;

    case OPENING_PHASE_STAFF_CREDITS:
        begin_credits_exit(); /* trans_exit: gfx_init, then wait FF26h */
        return;

    case OPENING_PHASE_NEC_HOU_INTERLUDE:
    case OPENING_PHASE_DMAOU_DEMON_INTRO:
    case OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION:
        opening_set_phase(OPENING_PHASE_STAFF_CREDITS); /* opening_next_scene */
        return;

    case OPENING_PHASE_RAIN_PRINCESS:
    case OPENING_PHASE_RAIN_TURNS_TO_SAND:
    case OPENING_PHASE_JASHIIN_CURSES_PRINCESS:
    case OPENING_PHASE_KING_GRIEF_AND_SPIRIT:
    case OPENING_PHASE_DUKE_ARRIVES:
    case OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS:
    case OPENING_PHASE_JASHIIN_CONFRONTATION:
    case OPENING_PHASE_JASHIIN_DEPARTURE:
        /* 100OPDMO:story_scene_input_handler jumps to transition_out_to_game
         * for either gvar_spacebar_state or ENTER.  It never advances a
         * story scene to the next presentation phase. */
        g_done = 1;
        return;

    case OPENING_PHASE_DESTINY_CARD:
        g_done = 1; /* transition_out_to_game */
        return;

    case OPENING_PHASE_DONE:
        g_done = 1;
        return;
    }
}

size_t opening_scene_sprite_c_events(opening_sprite_event_t *out, size_t max_events) {
    size_t count = 0;
    for (size_t i = 0; SCENE_SPRITE_C[i] != 0; i++) {
        if (out && count < max_events) {
            out[count].display_al = (u8)(SCENE_SPRITE_C[i] - 1);
            out[count].bx = 0x1720;
            out[count].delay = 0x14;
        }
        count++;
    }
    return count;
}

opening_sprite_a_summary_t opening_scene_sprite_a_summary(void) {
    opening_sprite_a_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.record_count = SPRITE_A_RECORD_COUNT;
    summary.source_bytes_consumed = sizeof(SCENE_SPRITE_A);
    summary.frame_wait_al = 0x1E;
    summary.dispatch_slot = 0x3012;
    summary.dispatch_target = 0x3437;

    typedef struct {
        u8 active;
        u8 x;
        u8 y;
        i8 vx;
        i8 vy;
        u8 toggle;
        u8 frame;
        u8 end;
    } sprite_state_t;

    sprite_state_t state[SPRITE_A_RECORD_COUNT];
    memset(state, 0, sizeof(state));
    for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
        const u8 *record = &SCENE_SPRITE_A[i * SPRITE_A_RECORD_SIZE];
        summary.records[i].x = record[0];
        summary.records[i].y = record[1];
        summary.records[i].vx = (i8)record[2];
        summary.records[i].vy = (i8)record[3];
        summary.records[i].first_frame = record[4];
        summary.records[i].last_frame = record[5];

        state[i].active = 1;
        state[i].y = record[0];
        state[i].x = record[1];
        state[i].vy = (i8)record[2];
        state[i].vx = (i8)record[3];
        state[i].frame = record[4];
        state[i].end = record[5];
    }

    while (summary.frame_count < 256) {
        int any_active = 0;
        for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++)
            any_active |= state[i].active != 0;
        if (!any_active)
            break;

        for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
            sprite_state_t *s = &state[i];
            if (!s->active)
                continue;
            if (s->frame != s->end) {
                s->toggle = (u8)(s->toggle + 1);
                if ((s->toggle & 1) == 0)
                    s->frame = (u8)(s->frame + 1);
            }
            s->y = (u8)(s->y + s->vy);
            s->x = (u8)(s->x + s->vx);
        }

        for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
            sprite_state_t *s = &state[i];
            if (!s->active)
                continue;
            s->active = 0;
            if (s->x < 0x4B && s->y < 0xA0)
                s->active = 1;
        }
        summary.frame_count++;
    }

    return summary;
}

size_t opening_debug_scene_sprite_a_object_table(u8 *out, size_t max_bytes) {
    const size_t required = SPRITE_A_OBJECT_TABLE_BYTES;
    if (!out || max_bytes < required)
        return required;

    sprite_a_build_object_table(out);
    return required;
}

void opening_render_sprite_a_frame_for_test(int frame_index) {
    opening_init();
    opdmo_disp_set_mcga_ax(2);
    render_scene_sprite_a_frame(frame_index);
}

size_t opening_scene_sprite_a_frame_table(opening_sprite_a_frame_table_entry_t *out,
                                          size_t max_entries) {
    size_t count = sizeof(SPRITE_A_FRAME_TABLE) / sizeof(SPRITE_A_FRAME_TABLE[0]);
    if (!out)
        return count;
    if (max_entries < count)
        count = max_entries;
    for (size_t i = 0; i < count; i++) {
        out[i].frame_ptr = SPRITE_A_FRAME_TABLE[i].frame_ptr;
        out[i].cx = SPRITE_A_FRAME_TABLE[i].cx;
    }
    return sizeof(SPRITE_A_FRAME_TABLE) / sizeof(SPRITE_A_FRAME_TABLE[0]);
}

size_t opening_scene_sprite_a_frame_trace(opening_sprite_a_frame_state_t *out,
                                          size_t max_frames) {
    const size_t total = SPRITE_A_FRAME_COUNT;
    if (!out)
        return total;
    size_t count = max_frames < total ? max_frames : total;
    for (size_t frame = 0; frame < count; frame++) {
        sprite_obj_state_t state[SPRITE_A_RECORD_COUNT];
        sprite_a_state_for_frame((int)frame, state);
        memset(&out[frame], 0, sizeof(out[frame]));
        out[frame].frame_index = frame;
        out[frame].final_palette_cycle =
            (u8)(((frame * SPRITE_A_RECORD_COUNT) +
                  (SPRITE_A_RECORD_COUNT - 1)) & 7);
        for (size_t i = 0; i < SPRITE_A_RECORD_COUNT; i++) {
            out[frame].objects[i].active = state[i].active;
            out[frame].objects[i].x = state[i].x;
            out[frame].objects[i].y = state[i].y;
            out[frame].objects[i].frame = state[i].frame;
            if (state[i].active)
                out[frame].active_count++;
        }
    }
    return total;
}

static opening_scanline_summary_t make_scanline_summary(size_t entry_count) {
    opening_scanline_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.entry_count = entry_count;
    summary.entry_draw_count = summary.entry_count * SCANLINE_ENTRY_FRAMES;
    summary.exit_draw_count = SCANLINE_EXIT_FRAMES;
    summary.total_draw_count = summary.entry_draw_count + summary.exit_draw_count;
    for (size_t i = 0; i < SCANLINE_ENTRY_FRAMES; i++)
        summary.entry_draw_al[i] = (u8)i;
    summary.exit_draw_al = 0;
    summary.wait_al = 0x1C;
    summary.bx = 0x0020;
    summary.cx = 0x5078;
    return summary;
}

static uint64_t opening_fnv1a64(const u8 *data, size_t size) {
    uint64_t value = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; i++) {
        value ^= data[i];
        value *= 0x100000001B3ULL;
    }
    return value;
}

opening_scanline_summary_t opening_scanline_summary(void) {
    return make_scanline_summary(ANCIENT_PROLOGUE_LINE_COUNT);
}

opening_scanline_summary_t opening_credits_summary(void) {
    return make_scanline_summary(CREDITS_STREAM_RECORDS);
}

opening_scanline_runtime_summary_t opening_amulet_scanline_runtime_summary(void) {
    opening_scanline_runtime_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.rendered_draws = g_amulet_scanline_draws;
    summary.stream_pos = g_amulet_scanline_runtime.scan_stream_pos;
    summary.exit_frame = g_amulet_scanline_runtime.scan_exit_frame;
    summary.finished = g_amulet_scanline_runtime.scan_finished;
    summary.visible_hash = opening_fnv1a64(g_amulet_scanline_runtime.vga, 0xFA00);
    summary.work_hash = opening_fnv1a64(g_amulet_scanline_runtime.work,
                                        sizeof(g_amulet_scanline_runtime.work));
    return summary;
}

opening_scanline_runtime_summary_t opening_credits_scanline_runtime_summary(void) {
    opening_scanline_runtime_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.rendered_draws = g_credits_scanline_draws;
    summary.stream_pos = g_credits_scanline_runtime.scan_stream_pos;
    summary.exit_frame = g_credits_scanline_runtime.scan_exit_frame;
    summary.finished = g_credits_scanline_runtime.scan_finished;
    summary.visible_hash = opening_fnv1a64(g_credits_scanline_runtime.vga, 0xFA00);
    summary.work_hash = opening_fnv1a64(g_credits_scanline_runtime.work,
                                        sizeof(g_credits_scanline_runtime.work));
    return summary;
}

opening_scanline_runtime_summary_t opening_final_scanline_runtime_summary(void) {
    opening_scanline_runtime_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.rendered_draws = g_final_scanline_draws;
    summary.stream_pos = g_final_scanline_runtime.scan_stream_pos;
    summary.exit_frame = g_final_scanline_runtime.scan_exit_frame;
    summary.finished = g_final_scanline_runtime.scan_finished;
    summary.visible_hash = opening_fnv1a64(g_final_scanline_runtime.vga, 0xFA00);
    summary.work_hash = opening_fnv1a64(g_final_scanline_runtime.work,
                                        sizeof(g_final_scanline_runtime.work));
    return summary;
}

opening_sprite_b_summary_t opening_scene_sprite_b_summary(void) {
    opening_sprite_b_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.first_wait = 0xF0;
    summary.after_script_wait = 0xF0;
    summary.between_explicit_calls_wait = 0x0F;
    summary.after_explicit_calls_wait = 0xF0;
    summary.explicit_chapter2_al[0] = 2;
    summary.explicit_chapter2_al[1] = 3;
    summary.explicit_chapter2_bx = 0x1720;

    /* These mirror play_sprite_anim_script's local render-state effects.
     * The chapter-2 and chapter-4 services are counted at the call boundary;
     * their driver implementation is deliberately outside this OPDMO summary. */
    u16 render_state_a = 0;
    u8 render_state_b = 0x8A;
    u8 volume_b = 0;

    for (size_t i = 0; i < sizeof(SCENE_SPRITE_B);) {
        u8 value = SCENE_SPRITE_B[i++];
        if (value == 0)
            break;
        if (value < 5) {
            summary.chapter2_call_count++;
            continue;
        }
        if (value == 0xFF) {
            if (i >= sizeof(SCENE_SPRITE_B))
                break;
            u8 marker = SCENE_SPRITE_B[i++];
            if (marker == 0)
                break;
            if (marker == 1 && i < sizeof(SCENE_SPRITE_B)) {
                render_state_a = (u16)SCENE_SPRITE_B[i++] * 8u;
                render_state_b = (u8)(render_state_b + 10u);
            }
            summary.script_wait_count++;
            continue;
        }
        summary.glyph_count++;
        summary.chapter4_draw_call_count += 2;
        render_state_a = (u16)(render_state_a + 8u);
        if (value != ' ')
            volume_b = 0x3F;
        summary.script_wait_count++;
    }
    summary.script_bytes_consumed = sizeof(SCENE_SPRITE_B);
    summary.final_render_state_a = render_state_a;
    summary.final_render_state_b = render_state_b;
    summary.final_volume_b = volume_b;
    return summary;
}

static void append_title_asset_event(opening_title_asset_event_t *out,
                                     size_t max_events, size_t *count,
                                     opening_title_asset_event_t event) {
    if (out && *count < max_events)
        out[*count] = event;
    (*count)++;
}

size_t opening_title_asset_reload_trace(opening_title_asset_event_t *out, size_t max_events) {
    size_t count = 0;
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_SPEECH,
            .al = 0, .bx = 0x0094, .cx = 0x501E,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_SAR_LOAD,
            .asset = "ttl1.grp", .al = 2, .di = 0xA000, .es_delta = 0,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_DECODE_RLE,
            .si = 0xA000, .di = 0x4000, .es_delta = 0,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_SAR_LOAD,
            .asset = "ttl2.grp", .al = 2, .di = 0xA000, .es_delta = 0,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_SAR_LOAD,
            .asset = "ttl3.grp", .al = 2, .di = 0xB000, .es_delta = 0,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_SAR_LOAD,
            .asset = "zopn.msd", .al = 5, .di = 0x3000, .es_delta = 0,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_GFX_MODE,
            .bx = 0x1720, .cx = 0x2270,
        });
    append_title_asset_event(out, max_events, &count,
        (opening_title_asset_event_t){
            .kind = OPENING_TITLE_ASSET_EVENT_PALETTE,
            .ax = 4,
        });
    return count;
}

opening_title_asset_summary_t opening_title_asset_summary(void) {
    opening_title_asset_summary_t summary;
    opening_title_asset_event_t events[8];
    size_t sar_index = 0;
    memset(&summary, 0, sizeof(summary));
    size_t count = opening_title_asset_reload_trace(events, sizeof(events) / sizeof(events[0]));

    for (size_t i = 0; i < count && i < sizeof(events) / sizeof(events[0]); i++) {
        const opening_title_asset_event_t *event = &events[i];
        switch (event->kind) {
        case OPENING_TITLE_ASSET_EVENT_SPEECH:
            summary.jashiin_speech_al = event->al;
            summary.jashiin_speech_bx = event->bx;
            summary.jashiin_speech_cx = event->cx;
            break;
        case OPENING_TITLE_ASSET_EVENT_SAR_LOAD:
            if (sar_index < 4) {
                summary.sar_asset[sar_index] = event->asset;
                summary.sar_al[sar_index] = event->al;
                summary.sar_di[sar_index] = event->di;
                summary.sar_es_delta[sar_index] = event->es_delta;
                sar_index++;
            }
            break;
        case OPENING_TITLE_ASSET_EVENT_DECODE_RLE:
            summary.decode_si = event->si;
            summary.decode_di = event->di;
            break;
        case OPENING_TITLE_ASSET_EVENT_GFX_MODE:
            summary.gfx_mode_bx = event->bx;
            summary.gfx_mode_cx = event->cx;
            break;
        case OPENING_TITLE_ASSET_EVENT_PALETTE:
            summary.palette_ax = event->ax;
            break;
        }
    }
    return summary;
}

opening_title_display_handoff_summary_t opening_title_display_handoff_summary(void) {
    opening_title_display_handoff_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.int60_ax = 0;
    summary.int60_si = 0x3000;
    summary.int60_ds_delta = 0;
    summary.driver_call_count = 1;
    summary.wait_al[0] = 0xF0;
    summary.wait_al[1] = 0xF0;
    summary.wait_al[2] = 0xF0;
    summary.gfx_update_al = 0;
    summary.gfx_update_bx = 0x0B48;
    summary.gfx_update_cx = 0x3180;
    summary.gfx_update_di = 0x4000;
    summary.gfx_update_es_delta = 0;
    summary.decode_si[0] = 0xB000;
    summary.decode_si[1] = 0xA000;
    summary.decode_di[0] = 0x4000;
    summary.decode_di[1] = 0x4000;
    summary.disp_narr_chap3_bx = 0x070F;
    summary.disp_narr_chap3_cx = 0x4170;
    summary.disp_narr_chap3_di = 0x4000;
    summary.disp_narr_open_si = 0x912B;
    return summary;
}

opening_title_color_exit_summary_t opening_title_color_exit_summary(void) {
    opening_title_color_exit_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.iterations = 100;
    summary.disp_set_call_count = 200;
    summary.disp_sprite_slot = 0x301E;
    summary.disp_sprite_target = 0x37B4;
    summary.disp_sprite_writes_palette = 0;
    summary.disp_sprite_object_count = 9;
    summary.disp_sprite_record_size = 0x0F;
    summary.disp_sprite_scratch_size = 0x44;
    summary.disp_sprite_source_stride = 0x22;
    summary.disp_sprite_row_count = 0x11;
    summary.wait_count = 100;
    summary.wait_al = 0x50;
    summary.interrupt_cascade_count = 1;
    summary.stick_handler_call_count = 4;
    summary.exits_to_game = 1;

    u8 al = 0xC7;
    u8 ah = 0x00;
    size_t first_count = 0;
    u8 final_values[6] = {0};
    size_t final_count = 0;
    for (size_t i = 0; i < summary.iterations; i++) {
        u8 pair[2] = {al, ah};
        for (size_t j = 0; j < 2; j++) {
            if (first_count < sizeof(summary.first_disp_set_al))
                summary.first_disp_set_al[first_count++] = pair[j];
            final_values[final_count % sizeof(final_values)] = pair[j];
            final_count++;
        }
        ah = (u8)(ah + 2);
        al = (u8)(al - 2);
    }
    size_t start = final_count % sizeof(final_values);
    for (size_t i = 0; i < sizeof(summary.final_disp_set_al); i++)
        summary.final_disp_set_al[i] = final_values[(start + i) % sizeof(final_values)];
    return summary;
}

opening_timer_exit_summary_t opening_timer_exit_summary(void) {
    opening_timer_exit_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.scene_mode = 8;
    summary.gfx_mode_al = 0xFF;
    summary.gfx_mode_bx = 0x0000;
    summary.gfx_mode_cx = 0x50C8;
    summary.gfx_init_count = 1;
    summary.sar_asset = "zend.msd";
    summary.sar_al = 5;
    summary.sar_di = 0x3000;
    summary.sar_es_delta = 0;
    summary.int60_ax = 0;
    summary.int60_si = 0x3000;
    summary.int60_di = 0x3000;
    summary.int60_ds_delta = 0;
    summary.palette_ax = 1;
    summary.credits_call_count = 1;
    summary.clears_input = 1;
    return summary;
}

opening_trans_exit_summary_t opening_trans_exit_summary(void) {
    opening_trans_exit_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.scene_mode = 8;
    summary.gfx_init_count = 1;
    summary.clears_input = 1;
    summary.reaches_post_title_story = 1;
    return summary;
}

opening_post_title_story_summary_t opening_post_title_story_summary(void) {
    opening_post_title_story_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.palette_ax = 5;
    summary.sar_asset[0] = "waku.grp";
    summary.sar_asset[1] = "ame.grp";
    summary.sar_al[0] = 2;
    summary.sar_al[1] = 2;
    summary.sar_di[0] = 0xA000;
    summary.sar_di[1] = 0xA000;
    summary.decompress_si[0] = 0xA000;
    summary.decompress_si[1] = 0xA000;
    summary.decompress_di[0] = 0x0000;
    summary.decompress_di[1] = 0x4000;
    summary.decompress_es_delta[0] = 0x2000;
    summary.decompress_es_delta[1] = 0x0000;
    summary.disp_game_al[0] = 0;
    summary.disp_game_al[1] = 0;
    summary.disp_game_bx[0] = 0x0000;
    summary.disp_game_bx[1] = 0x0410;
    summary.disp_game_cx[0] = 0x5088;
    summary.disp_game_cx[1] = 0x4868;
    summary.disp_game_di[0] = 0x0000;
    summary.disp_game_di[1] = 0x4000;
    summary.disp_game_es_delta[0] = 0x2000;
    summary.disp_game_es_delta[1] = 0x0000;
    return summary;
}

opening_hime_transition_summary_t opening_hime_transition_summary(void) {
    opening_hime_transition_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.palette_ax = 9;
    summary.disp_game_al = 9;
    summary.disp_game_bx = 0x0410;
    summary.disp_game_cx = 0x4868;
    summary.disp_game_di = 0x4000;
    summary.sar_asset = "hime.grp";
    summary.sar_al = 2;
    summary.sar_di = 0xA000;
    summary.decompress_si = 0xA000;
    summary.decompress_di = 0x4000;
    return summary;
}

opening_dmaou_transition_summary_t opening_dmaou_transition_summary(void) {
    opening_dmaou_transition_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.font_clear_count = 1;
    summary.palette_ax = 6;
    summary.disp_game_al = 6;
    summary.disp_game_bx = 0x0410;
    summary.disp_game_cx = 0x4868;
    summary.disp_game_di = 0x4000;
    summary.sar_asset = "dmaou.grp";
    summary.sar_al = 2;
    summary.sar_di = 0xA000;
    summary.decompress_si = 0xA000;
    summary.decompress_di = 0x97C0;
    return summary;
}

opening_apparition_overlay_summary_t opening_apparition_overlay_summary(void) {
    opening_apparition_overlay_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.al = 7;
    summary.bx = 0x1728;
    summary.cx = 0x2230;
    summary.di = 0;
    summary.es_delta = 0x2000;
    return summary;
}

opening_apparition_remove_isi_summary_t opening_apparition_remove_isi_summary(void) {
    opening_apparition_remove_isi_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.busy_wait_al[0] = 2;
    summary.busy_wait_al[1] = 3;
    summary.disp_game_al[0] = 0;
    summary.disp_game_al[1] = 0;
    summary.disp_game_bx[0] = summary.disp_game_bx[1] = 0x1728;
    summary.disp_game_cx[0] = summary.disp_game_cx[1] = 0x2230;
    summary.story_timer_wait_al = 0x0F;
    summary.sar_asset = "isi.grp";
    summary.sar_al = 2;
    summary.sar_di = 0xA000;
    summary.decompress_si = 0xA000;
    summary.decompress_di = 0x4000;
    summary.gfx_mode_bx = 0x0410;
    summary.gfx_mode_cx = 0x4868;
    return summary;
}

opening_isi_reveal_summary_t opening_isi_reveal_summary(void) {
    opening_isi_reveal_summary_t summary;
    memset(&summary, 0, sizeof(summary));
    summary.palette_ax = 7;
    summary.gfx_update_al = 0xFF;
    summary.gfx_update_bx = 0x0410;
    summary.gfx_update_cx = 0x4868;
    summary.gfx_update_di = 0x4000;
    return summary;
}
