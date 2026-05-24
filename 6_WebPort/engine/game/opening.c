/* Opening cinematic — simplified M2 slideshow.
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
#include "../load/grp.h"
#include "../load/fill_buffer.h"
#include "../load/img_open.h"
#include "../render/palette.h"
#include "../render/font_text.h"
#include "../core/framebuf.h"
#include "../platform/platform.h"
#include <stdlib.h>
#include <string.h>

/* ---- scene table -------------------------------------------------------- */
typedef enum {
    IMG_GRP     = 0,   /* fill_buffer → 6DE1 → interleave_abc → 8-pass blit */
    IMG_GFX_DRAW = 1,  /* fill_buffer → decompress_image → interleave_gfx_draw → blit */
} img_type_t;

typedef struct {
    const char     *asset;
    int             rows, cl;       /* interleave params */
    int             x, y;           /* blit origin in VGA pixel coords */
    u32             duration_ms;
    palette_scene_t palette;
    img_type_t      img_type;
} scene_def_t;

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
    { "dmaou.grp", 34, 112, 92, 32, 3500, PALETTE_OPENING, IMG_GFX_DRAW },
};
#define NUM_SCENES ((int)(sizeof(SCENES) / sizeof(SCENES[0])))

static const scene_def_t HOU_OVERLAY =
    { "hou.grp", 16, 64, 128, 72, 0, PALETTE_OPENING, IMG_GFX_DRAW };

static const scene_def_t AME_SCENE =
    { "ame.grp", 0x48, 0x68, 16, 16, 0, PALETTE_OPENING, IMG_GFX_DRAW };

enum {
    TITLE_TO_BLACK_MS = 900,
    AME_SCROLL_MS = 18500,
    AME_HOLD_MS = 1500,
};

static const char *const PROLOGUE_LINES[] = {
    "Once, long ago, a terrible storm came",
    "to the land of Zeliard.",
    "",
    "Dark clouds filled the sky; lightning",
    "flashed and thunder crashed.",
    "",
    "Day after day, rain poured from the",
    "heavens as if in lament.",
    "",
    "On the seventh day of rain, a beautiful",
    "young girl stood on her balcony watching",
    "this dark, sad rain.",
};
#define PROLOGUE_LINE_COUNT ((int)(sizeof(PROLOGUE_LINES) / sizeof(PROLOGUE_LINES[0])))

static const u8 SCENE_SPRITE_C[] = {
    0x01, 0x01, 0x01, 0x02, 0x02, 0x01,
    0x01, 0x02, 0x02, 0x03, 0x03, 0x05, 0x00
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

/* ---- decoded image cache ------------------------------------------------ */
typedef struct {
    u8        *pixels;
    int        w, h;
    int        x, y;
} cached_image_t;

static cached_image_t g_images[NUM_SCENES];
static cached_image_t g_hou_overlay;
static cached_image_t g_ame_scene;
static zeliard_font_t g_font;
static int            g_font_ready = 0;
static int            g_scene_idx = 0;
static u32            g_elapsed   = 0;
static int            g_done      = 0;

typedef enum {
    OPENING_PHASE_TITLE_TO_BLACK = 0,
    OPENING_PHASE_AME_SCROLL = 1,
    OPENING_PHASE_DONE = 2,
} opening_phase_t;

static opening_phase_t g_phase = OPENING_PHASE_TITLE_TO_BLACK;

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

static void load_scene(int idx) {
    cached_image_t    *img = &g_images[idx];
    const scene_def_t *s   = &SCENES[idx];
    if (img->pixels) return;

    img->x = s->x;
    img->y = s->y;

    if (s->img_type == IMG_GRP)
        load_grp_scene(idx);
    else
        load_gfx_draw_scene(idx);
}

static void load_hou_overlay(void) {
    if (g_hou_overlay.pixels) return;
    g_hou_overlay.x = HOU_OVERLAY.x;
    g_hou_overlay.y = HOU_OVERLAY.y;
    load_gfx_draw_overlay(&g_hou_overlay, &HOU_OVERLAY);
}

static void load_ame_scene(void) {
    if (g_ame_scene.pixels) return;
    g_ame_scene.x = AME_SCENE.x;
    g_ame_scene.y = AME_SCENE.y;
    load_gfx_draw_overlay(&g_ame_scene, &AME_SCENE);
}

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

static void blit_scene(int idx) {
    blit_cached_image(&g_images[idx]);
}

static void render_scene_sprite_b_text(int x, int y) {
    zeliard_font_draw_opening_anim_stream(&g_font, x, y, SCENE_SPRITE_B,
                                          sizeof(SCENE_SPRITE_B), 7, 10);
}

static void render_opening_text(int idx) {
    if (!g_font_ready) return;
    if (idx == 2)
        render_scene_sprite_b_text(24, 144);
}

static void render_title_to_black(u32 elapsed_ms) {
    u32 capped = elapsed_ms > TITLE_TO_BLACK_MS ? TITLE_TO_BLACK_MS : elapsed_ms;
    int covered = (int)((capped * (u32)ZELIARD_HEIGHT) / TITLE_TO_BLACK_MS);
    if (covered < 0) covered = 0;
    if (covered > ZELIARD_HEIGHT) covered = ZELIARD_HEIGHT;

    for (int y = 0; y < ZELIARD_HEIGHT; y++) {
        int interlace = ((y & 1) == 0) ? covered : covered - 18;
        if (interlace < 0) interlace = 0;
        if (y < interlace)
            memset(&g_framebuf[y * ZELIARD_WIDTH], 0, ZELIARD_WIDTH);
    }
}

static void render_ame_story(u32 elapsed_ms) {
    framebuf_clear(0);
    blit_cached_image(&g_ame_scene);
    if (!g_font_ready) return;

    u32 scroll_span = AME_SCROLL_MS > AME_HOLD_MS ? AME_SCROLL_MS - AME_HOLD_MS : AME_SCROLL_MS;
    u32 capped = elapsed_ms > scroll_span ? scroll_span : elapsed_ms;
    int start_y = ZELIARD_HEIGHT + 12;
    int end_y = 62;
    int y = start_y - (int)((capped * (u32)(start_y - end_y)) / scroll_span);

    for (int i = 0; i < PROLOGUE_LINE_COUNT; i++) {
        int line_y = y + i * 10;
        if (line_y < -10 || line_y >= ZELIARD_HEIGHT) continue;
        int len = (int)strlen(PROLOGUE_LINES[i]);
        int x = (ZELIARD_WIDTH - len * 8) / 2;
        if (x < 4) x = 4;
        zeliard_font_draw_text(&g_font, x + 1, line_y + 1, PROLOGUE_LINES[i], 0);
        zeliard_font_draw_text(&g_font, x, line_y, PROLOGUE_LINES[i], 7);
    }
}

/* ---- public API --------------------------------------------------------- */

void opening_init(void) {
    memset(g_images, 0, sizeof(g_images));
    memset(&g_hou_overlay, 0, sizeof(g_hou_overlay));
    memset(&g_ame_scene, 0, sizeof(g_ame_scene));
    g_scene_idx = 0;
    g_elapsed   = 0;
    g_done      = 0;
    g_phase     = OPENING_PHASE_TITLE_TO_BLACK;
    for (int i = 0; i < NUM_SCENES; i++)
        load_scene(i);
    load_hou_overlay();
    load_ame_scene();
    if (!g_font_ready)
        g_font_ready = zeliard_font_load(&g_font);
    palette_set_scene(PALETTE_OPENING);
    platform_log("opening_init: %d scenes ready", NUM_SCENES);
}

void opening_tick(u32 dt_ms) {
    if (g_done) return;
    g_elapsed += dt_ms;

    if (g_phase == OPENING_PHASE_TITLE_TO_BLACK) {
        render_title_to_black(g_elapsed);
        if (g_elapsed >= TITLE_TO_BLACK_MS) {
            g_elapsed = 0;
            g_phase = OPENING_PHASE_AME_SCROLL;
            framebuf_clear(0);
        }
        return;
    }

    if (g_phase == OPENING_PHASE_AME_SCROLL) {
        render_ame_story(g_elapsed);
        if (g_elapsed >= AME_SCROLL_MS) {
            g_elapsed = 0;
            g_phase = OPENING_PHASE_DONE;
            g_done = 1;
        }
        return;
    }

    if (g_scene_idx >= NUM_SCENES) { g_done = 1; return; }
    framebuf_clear(0);
    blit_scene(g_scene_idx);
    if (g_scene_idx == 1)
        blit_cached_image(&g_hou_overlay);
    render_opening_text(g_scene_idx);
    if (g_elapsed >= SCENES[g_scene_idx].duration_ms) {
        g_elapsed = 0;
        g_scene_idx++;
        if (g_scene_idx < NUM_SCENES)
            palette_set_scene(SCENES[g_scene_idx].palette);
        else
            g_done = 1;
    }
}

int opening_done(void) {
    return g_done;
}

void opening_skip(void) {
    g_done = 1;
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
            if (marker == 1 && i < sizeof(SCENE_SPRITE_B))
                i++;
            summary.script_wait_count++;
            continue;
        }
        summary.glyph_count++;
        summary.chapter4_draw_call_count += 2;
        summary.script_wait_count++;
    }
    summary.script_bytes_consumed = sizeof(SCENE_SPRITE_B);
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
