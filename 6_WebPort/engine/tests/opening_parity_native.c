#include "../core/framebuf.h"
#include "../load/fill_buffer.h"
#include "../load/grp.h"
#include "../load/img_open.h"
#include "../game/opening.h"
#include "../game/opening_script.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/font_text.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void zeliard_init(void);
void zeliard_tick(uint32_t dt_ms);
void zeliard_key(int keycode);
int zeliard_scene(void);

enum {
    ZELIARD_SCENE_TITLE = 0,
    ZELIARD_SCENE_OPENING = 1,
    ZELIARD_SCENE_GAME = 2,
};

typedef enum { PIPE_GRP_ABC, PIPE_IMG_OPEN_GFX_DRAW } pipeline_t;

typedef struct {
    const char *name;
    const char *asset;
    int rows, cl, x, y;
    pipeline_t pipeline;
    int expected_w, expected_h;
    uint64_t expected_image_fnv;
    uint64_t expected_framebuffer_fnv;
} image_case_t;

static uint64_t fnv1a64(const uint8_t *data, size_t n) {
    uint64_t h = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < n; i++) {
        h ^= data[i];
        h *= 0x100000001B3ULL;
    }
    return h;
}

static uint8_t *decode_case(const image_case_t *tc, int *out_w, int *out_h) {
    size_t file_size = 0;
    uint8_t *file_data = platform_load_asset(tc->asset, &file_size);
    if (!file_data) return NULL;

    if (tc->pipeline == PIPE_GRP_ABC) {
        uint8_t *image = grp_decode(file_data, file_size, tc->rows, tc->cl, out_w, out_h);
        free(file_data);
        return image;
    }

    size_t payload_size = 0;
    uint8_t *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload) return NULL;

    size_t planes_size = 0;
    uint8_t *planes = img_open_decode(payload, payload_size, tc->rows, tc->cl, &planes_size);
    free(payload);
    if (!planes) return NULL;

    uint8_t *image = grp_decode_planes_gfx_draw(planes, planes_size, tc->rows, tc->cl, out_w, out_h);
    free(planes);
    return image;
}

static void blit_to_framebuffer(const uint8_t *image, int w, int h, int x0, int y0) {
    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        int dy = y0 + y;
        if (dy < 0 || dy >= ZELIARD_HEIGHT) continue;
        for (int x = 0; x < w; x++) {
            int dx = x0 + x;
            if (dx < 0 || dx >= ZELIARD_WIDTH) continue;
            uint8_t v = image[y * w + x];
            if (v) g_framebuf[dy * ZELIARD_WIDTH + dx] = v;
        }
    }
}

static int run_image_case(const image_case_t *tc) {
    int w = 0, h = 0;
    uint8_t *image = decode_case(tc, &w, &h);
    if (!image) {
        printf("%s: FAIL decode failed\n", tc->name);
        return 0;
    }

    uint64_t image_fnv = fnv1a64(image, (size_t)w * (size_t)h);
    blit_to_framebuffer(image, w, h, tc->x, tc->y);
    uint64_t fb_fnv = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    free(image);

    int ok = 1;
    if (w != tc->expected_w || h != tc->expected_h) ok = 0;
    if (image_fnv != tc->expected_image_fnv) ok = 0;
    if (fb_fnv != tc->expected_framebuffer_fnv) ok = 0;
    printf("%s: %s w=%d h=%d image=%016llx framebuffer=%016llx\n",
           tc->name, ok ? "PASS" : "FAIL", w, h,
           (unsigned long long)image_fnv, (unsigned long long)fb_fnv);
    return ok;
}

static int run_palette_case(uint64_t expected_fnv) {
    palette_set_scene(PALETTE_TITLE);
    uint64_t got = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int ok = got == expected_fnv;
    printf("title_palette_state: %s palette=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got);
    return ok;
}

static int run_initial_title_case(uint64_t expected_fb_fnv, uint64_t expected_palette_fnv) {
    zeliard_init();
    zeliard_tick(16);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    uint64_t pal = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int scene = zeliard_scene();
    int ok = scene == ZELIARD_SCENE_TITLE &&
             fb == expected_fb_fnv &&
             pal == expected_palette_fnv;
    printf("initial_title_screen: %s scene=%d framebuffer=%016llx palette=%016llx\n",
           ok ? "PASS" : "FAIL", scene, (unsigned long long)fb, (unsigned long long)pal);
    return ok;
}

static void advance_to_opening(void) {
    zeliard_init();
    zeliard_tick(16);
    zeliard_key(32);
    zeliard_tick(16);
    zeliard_tick(16);
}

static int run_title_input_starts_opening_case(uint64_t expected_fb_fnv) {
    advance_to_opening();
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int scene = zeliard_scene();
    int ok = scene == ZELIARD_SCENE_OPENING &&
             fb == expected_fb_fnv;
    printf("title_input_starts_opening: %s scene=%d framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", scene, (unsigned long long)fb);
    return ok;
}

static int run_opening_input_exit_case(void) {
    advance_to_opening();
    int opening_scene = zeliard_scene();
    zeliard_key(13);
    zeliard_tick(16);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int game_scene = zeliard_scene();
    int ok = opening_scene == ZELIARD_SCENE_OPENING &&
             game_scene == ZELIARD_SCENE_GAME &&
             fb == 0xdd14fcc6528cab25ULL;
    printf("opening_input_exit_to_game: %s opening_scene=%d game_scene=%d framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", opening_scene, game_scene, (unsigned long long)fb);
    return ok;
}

static int run_title_timer_starts_opening_case(void) {
    zeliard_init();
    zeliard_tick(7999);
    int still_title_scene = zeliard_scene();
    zeliard_tick(1);
    int opening_scene = zeliard_scene();
    int ok = still_title_scene == ZELIARD_SCENE_TITLE &&
             opening_scene == ZELIARD_SCENE_OPENING;
    printf("title_timer_starts_opening: %s still_title=%d opening_scene=%d\n",
           ok ? "PASS" : "FAIL", still_title_scene, opening_scene);
    return ok;
}

static int run_opening_ame_scene_case(uint64_t expected_fb_fnv) {
    opening_init();
    opening_tick(900);
    opening_tick(0);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == expected_fb_fnv;
    printf("opening_ame_scene: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb);
    return ok;
}

static int run_opening_ame_scroll_case(uint64_t expected_fb_fnv) {
    opening_init();
    opening_tick(900);
    opening_tick(9000);
    opening_tick(0);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == expected_fb_fnv;
    printf("opening_ame_scroll: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb);
    return ok;
}

static int run_font_renderer_case(void) {
    zeliard_font_t font;
    int ok = zeliard_font_load(&font);
    ok &= font.size == 1623;
    ok &= font.ptr_a == 0x0006;
    ok &= font.ptr_b == 0x0306;
    ok &= font.ptr_c == 0x0356;
    framebuf_clear(0);
    static const uint8_t text[] = {
        'A', 'b', 'c', 0x82, '1', '2', '3', 0x0D,
        'Z', 'e', 'l', 'i', 'a', 'r', 'd', 0xFF
    };
    static const uint8_t anim_text[] = {
        0xFF, 1, 3, 1, 'H', 'i',
        0xFF, 1, 2, 4, 'O', 'K', 0
    };
    zeliard_font_draw_command_stream(&font, 16, 24, text, sizeof(text), 7);
    zeliard_font_stream_result_t stream_result =
        zeliard_font_draw_opening_anim_stream(&font, 16, 48, anim_text,
                                              sizeof(anim_text), 6, 10);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    ok &= stream_result.glyph_count == 4;
    ok &= stream_result.line_count == 2;
    ok &= stream_result.bytes_consumed == sizeof(anim_text);
    ok &= fb == 0x2bddbdf589f45e66ULL;
    printf("font_text_renderer: %s size=%llu ptrs=%04x/%04x/%04x glyphs=%llu lines=%llu framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)font.size,
           font.ptr_a, font.ptr_b, font.ptr_c,
           (unsigned long long)stream_result.glyph_count,
           (unsigned long long)stream_result.line_count,
           (unsigned long long)fb);
    zeliard_font_free(&font);
    return ok;
}

static void fill_script_metrics(u8 widths[96], u8 advances[96], u8 advance) {
    for (size_t i = 0; i < 96; i++) {
        widths[i] = 1;
        advances[i] = advance;
    }
}

static int run_script_calc_width_case(void) {
    u8 widths[96];
    u8 advances[96];
    fill_script_metrics(widths, advances, 5);
    advances['A' - 0x20] = 3;
    advances['B' - 0x20] = 4;
    advances['C' - 0x20] = 7;

    const u8 script[] = {'A', 0x81, 0x02, 'B', ZELIARD_SCRIPT_SCR_WAIT,
                         'C', ' ', 'D'};
    u16 width = zeliard_opening_script_calc_text_width(script, sizeof(script), advances);
    int ok = width == 14;
    printf("opening_script_calc_text_width: %s width=%u\n",
           ok ? "PASS" : "FAIL", width);
    return ok;
}

static int run_script_interpreter_control_case(void) {
    u8 widths[96];
    u8 advances[96];
    fill_script_metrics(widths, advances, 8);

    const u8 script[] = {
        ZELIARD_SCRIPT_SCR_DIRECT,
        ZELIARD_SCRIPT_SCR_NORMAL,
        ZELIARD_SCRIPT_SCR_SPK_UNK,
        'A', ' ', 'B',
        ZELIARD_SCRIPT_SCR_WAIT,
        ZELIARD_SCRIPT_SCR_PARA,
        ZELIARD_SCRIPT_SCR_BOLD,
        0x80, 0x91,
        'C',
        ZELIARD_SCRIPT_SCR_BREAK
    };

    zeliard_opening_script_state_t s;
    zeliard_opening_script_init(&s, 0);
    zeliard_script_stop_t stop =
        zeliard_opening_script_run(&s, script, sizeof(script), widths, advances, 128);

    int ok = 1;
    ok &= stop == ZELIARD_SCRIPT_STOP_BREAK;
    ok &= s.pc == sizeof(script);
    ok &= s.wait_10_count == 11;
    ok &= s.pause_f0_count == 1;
    ok &= s.portrait_small_count == 1;
    ok &= s.portrait_large_count == 1;
    ok &= s.glyph_count == 4;
    ok &= s.draw_call_count == 8;
    ok &= s.text_color_fg == 1;
    ok &= s.text_color_bg == 7;
    ok &= s.text_attr == '=';
    ok &= s.volume_b == '=';
    ok &= s.text_y_pos == 1;
    ok &= s.text_x_pos == 8;
    ok &= s.last_char == 'C';
    ok &= s.last_draw_x == 3;
    ok &= s.last_draw_y == 0x99;
    printf("opening_script_interpreter_controls: %s pc=%llu wait10=%llu pause=%llu glyphs=%llu portraits=%llu/%llu\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.pc,
           (unsigned long long)s.wait_10_count,
           (unsigned long long)s.pause_f0_count,
           (unsigned long long)s.glyph_count,
           (unsigned long long)s.portrait_small_count,
           (unsigned long long)s.portrait_large_count);
    return ok;
}

static int run_script_interpreter_wrap_case(void) {
    u8 widths[96];
    u8 advances[96];
    fill_script_metrics(widths, advances, 8);
    advances['A' - 0x20] = 250;
    advances[' ' - 0x20] = 20;
    advances['B' - 0x20] = 100;

    const u8 script[] = {'A', ' ', 'B', ZELIARD_SCRIPT_SCR_BREAK};
    zeliard_opening_script_state_t s;
    zeliard_opening_script_init(&s, 0);
    zeliard_script_stop_t stop =
        zeliard_opening_script_run(&s, script, sizeof(script), widths, advances, 128);

    int ok = 1;
    ok &= stop == ZELIARD_SCRIPT_STOP_BREAK;
    ok &= s.wait_10_count == 4;
    ok &= s.newline_count == 1;
    ok &= s.text_y_pos == 1;
    ok &= s.text_x_pos == 100;
    ok &= s.glyph_count == 3;
    ok &= s.last_char == 'B';
    ok &= s.last_draw_x == 3;
    ok &= s.last_draw_y == 0x99;
    printf("opening_script_interpreter_wrap: %s wait10=%llu newline=%llu x=%u y=%u\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.wait_10_count,
           (unsigned long long)s.newline_count,
           s.text_x_pos, s.text_y_pos);
    return ok;
}

static int run_scene_sprite_c_case(void) {
    opening_sprite_event_t events[16];
    const uint8_t expected_al[] = {0, 0, 0, 1, 1, 0, 0, 1, 1, 2, 2, 4};
    size_t count = opening_scene_sprite_c_events(events, sizeof(events) / sizeof(events[0]));
    int ok = count == sizeof(expected_al) / sizeof(expected_al[0]);
    if (ok) {
        for (size_t i = 0; i < count; i++) {
            if (events[i].display_al != expected_al[i] ||
                events[i].bx != 0x1720 ||
                events[i].delay != 0x14) {
                ok = 0;
                break;
            }
        }
    }
    printf("opening_scene_sprite_c_events: %s count=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)count);
    return ok;
}

static int run_scene_sprite_b_case(void) {
    opening_sprite_b_summary_t s = opening_scene_sprite_b_summary();
    int ok = 1;
    ok &= s.script_bytes_consumed == 136;
    ok &= s.chapter2_call_count == 38;
    ok &= s.glyph_count == 88;
    ok &= s.chapter4_draw_call_count == 176;
    ok &= s.script_wait_count == 91;
    ok &= s.first_wait == 0xF0;
    ok &= s.after_script_wait == 0xF0;
    ok &= s.between_explicit_calls_wait == 0x0F;
    ok &= s.after_explicit_calls_wait == 0xF0;
    ok &= s.explicit_chapter2_al[0] == 2;
    ok &= s.explicit_chapter2_al[1] == 3;
    ok &= s.explicit_chapter2_bx == 0x1720;
    printf("opening_scene_sprite_b_summary: %s bytes=%llu chap2=%llu glyphs=%llu waits=%llu\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.script_bytes_consumed,
           (unsigned long long)s.chapter2_call_count,
           (unsigned long long)s.glyph_count,
           (unsigned long long)s.script_wait_count);
    return ok;
}

static int run_title_asset_case(void) {
    opening_title_asset_summary_t s = opening_title_asset_summary();
    opening_title_asset_event_t trace[8];
    size_t trace_count = opening_title_asset_reload_trace(trace, sizeof(trace) / sizeof(trace[0]));
    const char *expected_asset[] = {"ttl1.grp", "ttl2.grp", "ttl3.grp", "zopn.msd"};
    const uint8_t expected_al[] = {2, 2, 2, 5};
    const uint16_t expected_di[] = {0xA000, 0xA000, 0xB000, 0x3000};
    int ok = 1;
    ok &= trace_count == 8;
    ok &= trace[0].kind == OPENING_TITLE_ASSET_EVENT_SPEECH;
    ok &= trace[0].al == 0;
    ok &= trace[0].bx == 0x0094;
    ok &= trace[0].cx == 0x501E;
    ok &= trace[1].kind == OPENING_TITLE_ASSET_EVENT_SAR_LOAD;
    ok &= trace[2].kind == OPENING_TITLE_ASSET_EVENT_DECODE_RLE;
    ok &= trace[3].kind == OPENING_TITLE_ASSET_EVENT_SAR_LOAD;
    ok &= trace[4].kind == OPENING_TITLE_ASSET_EVENT_SAR_LOAD;
    ok &= trace[5].kind == OPENING_TITLE_ASSET_EVENT_SAR_LOAD;
    ok &= trace[6].kind == OPENING_TITLE_ASSET_EVENT_GFX_MODE;
    ok &= trace[7].kind == OPENING_TITLE_ASSET_EVENT_PALETTE;
    ok &= trace[2].si == 0xA000;
    ok &= trace[2].di == 0x4000;
    ok &= trace[6].bx == 0x1720;
    ok &= trace[6].cx == 0x2270;
    ok &= trace[7].ax == 4;
    for (size_t i = 0; i < 4; i++) {
        const opening_title_asset_event_t *event = &trace[i < 1 ? 1 : i + 2];
        ok &= strcmp(event->asset, expected_asset[i]) == 0;
        ok &= event->al == expected_al[i];
        ok &= event->di == expected_di[i];
        ok &= event->es_delta == 0;
    }
    ok &= s.jashiin_speech_al == 0;
    ok &= s.jashiin_speech_bx == 0x0094;
    ok &= s.jashiin_speech_cx == 0x501E;
    for (size_t i = 0; i < 4; i++) {
        ok &= strcmp(s.sar_asset[i], expected_asset[i]) == 0;
        ok &= s.sar_al[i] == expected_al[i];
        ok &= s.sar_di[i] == expected_di[i];
        ok &= s.sar_es_delta[i] == 0;
    }
    ok &= s.decode_si == 0xA000;
    ok &= s.decode_di == 0x4000;
    ok &= s.gfx_mode_bx == 0x1720;
    ok &= s.gfx_mode_cx == 0x2270;
    ok &= s.palette_ax == 4;
    printf("opening_title_asset_reload: %s trace=%llu speech=%02x/%04x/%04x mode=%04x/%04x palette=%u\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)trace_count,
           s.jashiin_speech_al, s.jashiin_speech_bx, s.jashiin_speech_cx,
           s.gfx_mode_bx, s.gfx_mode_cx, s.palette_ax);
    return ok;
}

static int run_title_display_handoff_case(void) {
    opening_title_display_handoff_summary_t s = opening_title_display_handoff_summary();
    int ok = 1;
    ok &= s.int60_ax == 0;
    ok &= s.int60_si == 0x3000;
    ok &= s.int60_ds_delta == 0;
    ok &= s.driver_call_count == 1;
    ok &= s.wait_al[0] == 0xF0;
    ok &= s.wait_al[1] == 0xF0;
    ok &= s.wait_al[2] == 0xF0;
    ok &= s.gfx_update_al == 0;
    ok &= s.gfx_update_bx == 0x0B48;
    ok &= s.gfx_update_cx == 0x3180;
    ok &= s.gfx_update_di == 0x4000;
    ok &= s.gfx_update_es_delta == 0;
    ok &= s.decode_si[0] == 0xB000;
    ok &= s.decode_si[1] == 0xA000;
    ok &= s.decode_di[0] == 0x4000;
    ok &= s.decode_di[1] == 0x4000;
    ok &= s.disp_narr_chap3_bx == 0x070F;
    ok &= s.disp_narr_chap3_cx == 0x4170;
    ok &= s.disp_narr_chap3_di == 0x4000;
    ok &= s.disp_narr_open_si == 0x912B;
    printf("opening_title_display_handoff: %s update=%02x/%04x/%04x open_si=%04x\n",
           ok ? "PASS" : "FAIL",
           s.gfx_update_al, s.gfx_update_bx, s.gfx_update_cx, s.disp_narr_open_si);
    return ok;
}

static int run_title_color_exit_case(void) {
    opening_title_color_exit_summary_t s = opening_title_color_exit_summary();
    const uint8_t expected_first[] = {0xC7, 0x00, 0xC5, 0x02, 0xC3, 0x04};
    const uint8_t expected_final[] = {0x05, 0xC2, 0x03, 0xC4, 0x01, 0xC6};
    int ok = 1;
    ok &= s.iterations == 100;
    ok &= s.disp_set_call_count == 200;
    ok &= s.wait_count == 100;
    ok &= s.wait_al == 0x50;
    for (size_t i = 0; i < 6; i++) {
        ok &= s.first_disp_set_al[i] == expected_first[i];
        ok &= s.final_disp_set_al[i] == expected_final[i];
    }
    ok &= s.interrupt_cascade_count == 1;
    ok &= s.stick_handler_call_count == 4;
    ok &= s.exits_to_game == 1;
    printf("opening_title_color_exit: %s iterations=%llu disp_set=%llu wait=%02x exit=%u\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.iterations,
           (unsigned long long)s.disp_set_call_count,
           s.wait_al, s.exits_to_game);
    return ok;
}

static int run_timer_exit_case(void) {
    opening_timer_exit_summary_t s = opening_timer_exit_summary();
    int ok = 1;
    ok &= s.scene_mode == 8;
    ok &= s.gfx_mode_al == 0xFF;
    ok &= s.gfx_mode_bx == 0x0000;
    ok &= s.gfx_mode_cx == 0x50C8;
    ok &= s.gfx_init_count == 1;
    ok &= strcmp(s.sar_asset, "zend.msd") == 0;
    ok &= s.sar_al == 5;
    ok &= s.sar_di == 0x3000;
    ok &= s.sar_es_delta == 0;
    ok &= s.int60_ax == 0;
    ok &= s.int60_si == 0x3000;
    ok &= s.int60_di == 0x3000;
    ok &= s.int60_ds_delta == 0;
    ok &= s.palette_ax == 1;
    ok &= s.credits_call_count == 1;
    ok &= s.clears_input == 1;
    printf("opening_timer_exit_to_game: %s mode=%02x sar=%s palette=%u credits=%llu\n",
           ok ? "PASS" : "FAIL",
           s.gfx_mode_al, s.sar_asset, s.palette_ax,
           (unsigned long long)s.credits_call_count);
    return ok;
}

static int run_trans_exit_case(void) {
    opening_trans_exit_summary_t s = opening_trans_exit_summary();
    int ok = 1;
    ok &= s.scene_mode == 8;
    ok &= s.gfx_init_count == 1;
    ok &= s.clears_input == 1;
    ok &= s.reaches_post_title_story == 1;
    printf("opening_trans_exit: %s scene_mode=%u post_title=%u\n",
           ok ? "PASS" : "FAIL", s.scene_mode, s.reaches_post_title_story);
    return ok;
}

int main(void) {
    const image_case_t cases[] = {
        {"ttl3_logo_bbox", "ttl3.grp", 65, 112, 28, 15, PIPE_GRP_ABC,
         260, 112, 0xa2d522d659f26245ULL, 0x05f15837ed2f4105ULL},
        {"nec_scene_bbox", "nec.grp", 44, 104, 72, 32, PIPE_IMG_OPEN_GFX_DRAW,
         176, 104, 0x552a8dee88d1f0f0ULL, 0x76a5c68141189f10ULL},
        {"hou_overlay_bbox", "hou.grp", 16, 64, 128, 72, PIPE_IMG_OPEN_GFX_DRAW,
         64, 64, 0xb783aef2a4a8a1dbULL, 0xb66970464bb149dbULL},
        {"dmaou_scene_bbox", "dmaou.grp", 34, 112, 92, 32, PIPE_IMG_OPEN_GFX_DRAW,
         136, 112, 0x67b90328c77d9e4fULL, 0x5c7fa1b0aad0838fULL},
        {"ame_scene_bbox", "ame.grp", 72, 104, 16, 16, PIPE_IMG_OPEN_GFX_DRAW,
         288, 104, 0xfc33527252c2b15fULL, 0x07f4f8b3e8d8f1dfULL},
    };

    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
        ok &= run_image_case(&cases[i]);
    }
    ok &= run_opening_ame_scene_case(0x07f4f8b3e8d8f1dfULL);
    ok &= run_opening_ame_scroll_case(0xee3dc790268284cbULL);
    ok &= run_font_renderer_case();
    ok &= run_script_calc_width_case();
    ok &= run_script_interpreter_control_case();
    ok &= run_script_interpreter_wrap_case();
    ok &= run_scene_sprite_c_case();
    ok &= run_scene_sprite_b_case();
    ok &= run_title_asset_case();
    ok &= run_title_display_handoff_case();
    ok &= run_title_color_exit_case();
    ok &= run_timer_exit_case();
    ok &= run_trans_exit_case();
    ok &= run_palette_case(0xd9e89a4c32254f58ULL);
    ok &= run_initial_title_case(0x513e9ef6009064eaULL, 0xd9e89a4c32254f58ULL);
    ok &= run_title_input_starts_opening_case(0x513e9ef6009064eaULL);
    ok &= run_title_timer_starts_opening_case();
    ok &= run_opening_input_exit_case();
    printf("VERDICT: %s: opening native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
