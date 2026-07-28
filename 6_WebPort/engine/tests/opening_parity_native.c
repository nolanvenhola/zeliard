#include "../core/framebuf.h"
#include "../core/timer.h"
#include "../load/fill_buffer.h"
#include "../load/grp.h"
#include "../load/img_open.h"
#include "../game/opening.h"
#include "../game/opening_script.h"
#include "../game/opening_trace.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/font_text.h"
#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void zeliard_init(void);
void zeliard_tick(uint32_t dt_ms);
void zeliard_key(int keycode);
int zeliard_scene(void);

#define OPDMO_TEST_WAIT_MS(ticks) \
    ((uint32_t)((((uint64_t)(ticks) * (uint64_t)ZEL_GAME_TIMER_DIVISOR * 1000u) + \
      (uint32_t)ZEL_PIT_HZ / 2u) / (uint32_t)ZEL_PIT_HZ))

enum {
    ZELIARD_SCENE_TITLE = 0,
    ZELIARD_SCENE_OPENING = 1,
    ZELIARD_SCENE_GAME = 2,
    OPENING_TITLE_FULL_SAMPLE_MS = 600,
    OPENING_TITLE_COMPLETE_MS = OPDMO_TEST_WAIT_MS(16 * 0x14),
    OPENING_AMULET_AUTO_MS = OPDMO_TEST_WAIT_MS(8 * 0x14 + 31 * 10 * 0x1C + 0x78 * 0x1C),
    OPENING_NEC_HOU_INTERLUDE_MS = OPDMO_TEST_WAIT_MS(8 * 0x14 + 2 * 0x14 + 12 * 0x1E),
    OPENING_DMAOU_DEMON_INTRO_MS = OPDMO_TEST_WAIT_MS(16 * 0x14 + 12 * 0x14 + 0xF0 + 91 * 0x14 + 0xF0 + 0x0F + 0xF0),
    OPENING_TITLE_GFX_READY_WAIT_TICKS = 20546 - 8 * 0x14,
    OPENING_TITLE_LOGO_COLOR_MS = OPDMO_TEST_WAIT_MS(
        8 * 0x14 + 3 * 0xF0 + 16 * 0x14 + 16 * 0x14 + 100 * 0x50 +
        OPENING_TITLE_GFX_READY_WAIT_TICKS + 8 * 0x14),
    OPENING_COPYRIGHT_INPUT_SAMPLE_MS = 16,
    OPENING_SCANLINE_SAMPLE_MS = OPDMO_TEST_WAIT_MS(16 * 0x14 + 8 * 0x14 + 95 * 0x1C),
    OPENING_SCANLINE_EXIT_FADE_MS = OPDMO_TEST_WAIT_MS(0x78 * 0x1C),
    OPENING_INPUT_CLEAR_MS = OPDMO_TEST_WAIT_MS(8 * 0x14),
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
    OPENING_PHASE_NEC_HOU_INTERLUDE = 20,
    OPENING_PHASE_DMAOU_DEMON_INTRO = 21,
    OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION = 22,
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

static size_t nonzero_count(const uint8_t *data, size_t n) {
    size_t count = 0;
    for (size_t i = 0; i < n; i++) {
        if (data[i]) count++;
    }
    return count;
}

static int framebuffer_nonzero_count(void);
static void framebuffer_bbox(int *min_x, int *min_y, int *max_x, int *max_y);

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

static int run_ttl3_decode_rle_memory_case(void) {
    size_t file_size = 0, planes_size = 0;
    uint8_t *file_data = platform_load_asset("ttl3.grp", &file_size);
    uint8_t *planes = file_data
        ? grp_decode_6de1_planes(file_data, file_size, &planes_size) : NULL;
    uint64_t got = planes ? fnv1a64(planes, planes_size) : 0;
    int ok = planes && planes_size == 14578 && got == 0x5655ba7b7c59348fULL;
    printf("ttl3_decode_rle_memory: %s bytes=%llu fnv=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)planes_size,
           (unsigned long long)got);
    free(file_data);
    free(planes);
    return ok;
}

static int run_busy_wait_delay_memory_case(void) {
    uint64_t got = opening_debug_busy_wait_delay_fixture_hash(4);
    int ok = got == 0x9f5d86fbdeb9b585ULL;
    printf("busy_wait_delay_memory: %s fnv=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got);
    return ok;
}

static int run_hime_dmaou_blend_memory_case(void) {
    size_t nonzero = 0;
    uint64_t got = opening_debug_hime_dmaou_blend_ranges_hash(&nonzero);
    int ok = got == 0x8a58f7d1074c0267ULL && nonzero == 10220;
    printf("hime_dmaou_apply_palette_blend_memory: %s fnv=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got,
           (unsigned long long)nonzero);
    return ok;
}

static int run_dmaou_prelude_segment_case(void) {
    size_t nonzero = 0;
    uint64_t got = opening_debug_dmaou_prelude_segment_hash(&nonzero);
    int ok = got == 0x66339916c7cc90f3ULL && nonzero == 5302;
    printf("dmaou_prelude_segment: %s fnv=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got,
           (unsigned long long)nonzero);
    return ok;
}

static int run_hime_dmaou_blend_frame_case(void) {
    size_t nonzero = 0;
    uint64_t got = opening_debug_hime_dmaou_blend_frame_hash(&nonzero);
    int ok = got == 0x2e5390699fcd8548ULL && nonzero == 28919;
    printf("hime_dmaou_apply_palette_blend_frame: %s fnv=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got,
           (unsigned long long)nonzero);
    return ok;
}

static int run_hime_dmaou_external_scratch_case(void) {
    size_t nonzero = 0;
    uint64_t got = opening_debug_hime_dmaou_ext_hash(&nonzero);
    int ok = got == 0xed5007e02c13c7c9ULL && nonzero == 4671;
    printf("hime_dmaou_external_scratch: %s fnv=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got,
           (unsigned long long)nonzero);
    return ok;
}

static int run_dmaou_apparition_3c1c_case(void) {
    size_t nonzero = 0;
    uint64_t got = opening_debug_dmaou_apparition_frame_hash(&nonzero);
    int ok = got == 0x2b2d0236d3732ef8ULL && nonzero == 1554;
    printf("dmaou_apparition_3c1c_ax07: %s fnv=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got,
           (unsigned long long)nonzero);
    return ok;
}

static int run_dmaou_post_busy_case(u8 al, uint64_t expected_ext,
                                    size_t expected_ext_nonzero,
                                    uint64_t expected_frame,
                                    size_t expected_frame_nonzero) {
    size_t ext_nonzero = 0;
    size_t frame_nonzero = 0;
    uint64_t ext = opening_debug_dmaou_post_busy_ext_hash(al, &ext_nonzero);
    uint64_t frame = opening_debug_dmaou_post_busy_frame_hash(al, &frame_nonzero);
    int ok = ext == expected_ext && ext_nonzero == expected_ext_nonzero &&
             frame == expected_frame && frame_nonzero == expected_frame_nonzero;
    printf("dmaou_post_busy_al%u: %s ext=%016llx/%llu frame=%016llx/%llu\n",
           al, ok ? "PASS" : "FAIL", (unsigned long long)ext,
           (unsigned long long)ext_nonzero, (unsigned long long)frame,
           (unsigned long long)frame_nonzero);
    return ok;
}

typedef struct {
    uint16_t ax;
    uint64_t expected_fnv;
    uint8_t color77[3];
    uint8_t coloraa[3];
} opdmo_palette_case_t;

static int run_opdmo_palette_case(const opdmo_palette_case_t *tc) {
    palette_set_opdmo_mcga(tc->ax);
    uint64_t got = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int ok = got == tc->expected_fnv &&
             g_palette[0x77].r == tc->color77[0] &&
             g_palette[0x77].g == tc->color77[1] &&
             g_palette[0x77].b == tc->color77[2] &&
             g_palette[0xaa].r == tc->coloraa[0] &&
             g_palette[0xaa].g == tc->coloraa[1] &&
             g_palette[0xaa].b == tc->coloraa[2];
    printf("opdmo_mcga_palette_ax%02x: %s palette=%016llx color77=%u/%u/%u coloraa=%u/%u/%u\n",
           tc->ax, ok ? "PASS" : "FAIL", (unsigned long long)got,
           g_palette[0x77].r, g_palette[0x77].g, g_palette[0x77].b,
           g_palette[0xaa].r, g_palette[0xaa].g, g_palette[0xaa].b);
    return ok;
}

static int run_opdmo_palette_cases(void) {
    static const opdmo_palette_case_t cases[] = {
        {5, 0xd426e9cee31f233dULL, {248, 248, 248}, {248, 0, 0}},
        {6, 0x65e3aefa7aa23c1dULL, {248, 248, 248}, {248, 0, 0}},
        {7, 0x17f2e97c18ac0f31ULL, {248, 248, 248}, {248, 0, 0}},
        {8, 0xfe6d0ffd656d2c0dULL, {248, 248, 248}, {248, 0, 0}},
        {9, 0x0219e910f646978dULL, {248, 248, 248}, {248, 0, 0}},
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++)
        ok &= run_opdmo_palette_case(&cases[i]);
    return ok;
}

/* 100OPDMO's title tile loop uses game:4000 as scratch while 105GDMCA:3A02
 * later reads palette registers from the loaded driver image at 4289h.
 * Exercise both spans in one process so title work storage cannot leak into
 * the late guardian palette service. */
static int run_title_tile_scratch_palette_isolation_case(void) {
    enum {
        OPENING_PHASE_KING_GRIEF_AND_SPIRIT = 6,
        OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION = 22,
    };
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION, 14000);
    opening_render_phase_for_test(OPENING_PHASE_KING_GRIEF_AND_SPIRIT, 41526);
    uint64_t palette = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int ok = palette == 0x17f2e97c18ac0f31ULL &&
             g_palette[1].r == 0 && g_palette[1].g == 0 &&
             g_palette[1].b == 127 &&
             g_palette[119].r == 248 && g_palette[119].g == 248 &&
             g_palette[119].b == 248;
    printf("title_tile_scratch_palette_isolation: %s palette=%016llx p01=%u/%u/%u p77=%u/%u/%u\n",
           ok ? "PASS" : "FAIL", (unsigned long long)palette,
           g_palette[1].r, g_palette[1].g, g_palette[1].b,
           g_palette[119].r, g_palette[119].g, g_palette[119].b);
    return ok;
}

static int run_initial_title_case(uint64_t expected_fb_fnv, uint64_t expected_palette_fnv) {
    zeliard_init();
    zeliard_tick(OPENING_TITLE_FULL_SAMPLE_MS);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    uint64_t pal = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int scene = zeliard_scene();
    int ok = scene == ZELIARD_SCENE_OPENING &&
             fb == expected_fb_fnv &&
             pal == expected_palette_fnv &&
             g_palette[0x77].r == 248 &&
             g_palette[0x77].g == 248 &&
             g_palette[0x77].b == 248;
    printf("initial_title_screen: %s scene=%d framebuffer=%016llx palette=%016llx color77=%u/%u/%u\n",
           ok ? "PASS" : "FAIL", scene, (unsigned long long)fb, (unsigned long long)pal,
           g_palette[0x77].r, g_palette[0x77].g, g_palette[0x77].b);
    return ok;
}

static int run_title_mcga_render_pass_case(uint64_t expected_fb_fnv,
                                           uint64_t expected_palette_fnv) {
    zeliard_init();
    zeliard_tick(600);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    uint64_t pal = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int scene = zeliard_scene();
    int ok = scene == ZELIARD_SCENE_OPENING &&
             opening_phase_id() == OPENING_PHASE_COPYRIGHT_TITLE_CARD &&
             fb == expected_fb_fnv &&
             pal == expected_palette_fnv &&
             g_palette[0x77].r == 248 &&
             g_palette[0x77].g == 248 &&
             g_palette[0x77].b == 248;
    printf("title_mcga_render_pass_midpoint: %s framebuffer=%016llx palette=%016llx color77=%u/%u/%u\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb,
           (unsigned long long)pal,
           g_palette[0x77].r, g_palette[0x77].g, g_palette[0x77].b);
    return ok;
}

static int run_nec_mcga_render_pass_case(uint64_t expected_fb_fnv,
                                         uint64_t expected_palette_fnv) {
    opening_init();
    opening_tick(OPENING_TITLE_COMPLETE_MS + 600);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    uint64_t pal = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int ok = opening_phase_id() == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             fb == expected_fb_fnv &&
             pal == expected_palette_fnv;
    printf("nec_mcga_render_pass_midpoint: %s framebuffer=%016llx palette=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb,
           (unsigned long long)pal);
    return ok;
}

static void overlay_on_framebuffer(const uint8_t *image, int w, int h, int x0, int y0) {
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

static int run_nec_hou_composite_case(uint64_t expected_fb_fnv) {
    const image_case_t nec = {"nec", "nec.grp", 44, 104, 72, 32,
                              PIPE_IMG_OPEN_GFX_DRAW, 176, 104, 0, 0};
    const image_case_t hou = {"hou", "hou.grp", 16, 64, 128, 72,
                              PIPE_IMG_OPEN_GFX_DRAW, 64, 64, 0, 0};
    int nw = 0, nh = 0, hw = 0, hh = 0;
    uint8_t *ni = decode_case(&nec, &nw, &nh);
    uint8_t *hi = decode_case(&hou, &hw, &hh);
    if (!ni || !hi) {
        free(ni);
        free(hi);
        printf("opening_nec_hou_composite: FAIL decode failed\n");
        return 0;
    }
    blit_to_framebuffer(ni, nw, nh, nec.x, nec.y);
    overlay_on_framebuffer(hi, hw, hh, hou.x, hou.y);
    uint64_t got = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    free(ni);
    free(hi);
    int ok = got == expected_fb_fnv;
    printf("opening_nec_hou_composite: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)got);
    return ok;
}

static uint8_t *decode_opening_planes_asset(const char *asset,
                                            int rows, int cl,
                                            size_t *out_size,
                                            size_t *payload_size_out) {
    size_t file_size = 0;
    uint8_t *file_data = platform_load_asset(asset, &file_size);
    if (!file_data) return NULL;

    size_t payload_size = 0;
    uint8_t *payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    free(file_data);
    if (!payload) return NULL;

    size_t planes_size = 0;
    uint8_t *planes = img_open_decode(payload, payload_size, rows, cl, &planes_size);
    free(payload);
    if (!planes) return NULL;

    if (payload_size_out) *payload_size_out = payload_size;
    *out_size = planes_size;
    return planes;
}

static int expect_mem_contract(const char *name,
                               const uint8_t *data, size_t size,
                               uint64_t expected_fnv,
                               size_t expected_nonzero) {
    uint64_t got_fnv = fnv1a64(data, size);
    size_t got_nonzero = nonzero_count(data, size);
    int ok = got_fnv == expected_fnv && got_nonzero == expected_nonzero;
    printf("%s: %s fnv=%016llx nonzero=%zu\n",
           name, ok ? "PASS" : "FAIL",
           (unsigned long long)got_fnv, got_nonzero);
    return ok;
}

static int run_opdemo_nec_hou_handoff_memory_case(void) {
    uint8_t game_seg[0x10000];
    memset(game_seg, 0, sizeof(game_seg));

    size_t nec_planes_size = 0, nec_payload_size = 0;
    uint8_t *nec_planes = decode_opening_planes_asset("nec.grp", 44, 104,
                                                      &nec_planes_size,
                                                      &nec_payload_size);
    size_t hou_planes_size = 0, hou_payload_size = 0;
    uint8_t *hou_planes = decode_opening_planes_asset("hou.grp", 16, 64,
                                                      &hou_planes_size,
                                                      &hou_payload_size);
    if (!nec_planes || !hou_planes) {
        free(nec_planes);
        free(hou_planes);
        printf("opdemo_nec_hou_handoff_memory: FAIL decode failed\n");
        return 0;
    }

    if (nec_planes_size > sizeof(game_seg) - 0x4000) {
        nec_planes_size = sizeof(game_seg) - 0x4000;
    }
    if (hou_planes_size > sizeof(game_seg) - 0x9000) {
        hou_planes_size = sizeof(game_seg) - 0x9000;
    }
    memcpy(game_seg + 0x4000, nec_planes, nec_planes_size);
    memcpy(game_seg + 0x9000, hou_planes, hou_planes_size);
    free(nec_planes);
    free(hou_planes);

    int ok = 1;
    ok &= nec_payload_size == 5786;
    ok &= hou_payload_size == 1500;
    ok &= nec_planes_size == 16896;
    ok &= hou_planes_size == 2560;
    ok &= expect_mem_contract("opdemo_nec_hou_handoff_mem_4000",
                              game_seg + 0x4000, 44u * 104u * 2u,
                              0x37e229a1ff0277cbULL, 1422u);
    ok &= expect_mem_contract("opdemo_nec_hou_handoff_mem_75a0",
                              game_seg + 0x75A0, 16u * 64u * 2u,
                              0xe031286249ba5435ULL, 702u);
    ok &= expect_mem_contract("opdemo_nec_hou_handoff_mem_9000",
                              game_seg + 0x9000, 16u * 64u * 2u,
                              0xae1c24df5911f572ULL, 1074u);
    ok &= expect_mem_contract("opdemo_nec_hou_handoff_mem_97c0",
                              game_seg + 0x97C0, 34u * 112u * 2u,
                              0xb066e9e800f20da0ULL, 298u);
    printf("opdemo_nec_hou_handoff_regs: %s bx=2048 cx=1040 di=75A0 es=game_seg\n",
           ok ? "PASS" : "FAIL");
    return ok;
}

static int run_opdemo_nec_hou_handoff_disp_game_rect_case(uint64_t expected_image,
                                                          int expected_w,
                                                          int expected_h,
                                                          size_t expected_image_nonzero,
                                                          uint64_t expected_fb,
                                                          int expected_fb_nonzero,
                                                          int expected_min_x,
                                                          int expected_min_y,
                                                          int expected_max_x,
                                                          int expected_max_y) {
    uint8_t game_seg[0x10000];
    memset(game_seg, 0, sizeof(game_seg));

    size_t nec_planes_size = 0, nec_payload_size = 0;
    uint8_t *nec_planes = decode_opening_planes_asset("nec.grp", 44, 104,
                                                      &nec_planes_size,
                                                      &nec_payload_size);
    if (!nec_planes) {
        printf("opdemo_nec_hou_handoff_disp_game_rect: FAIL decode failed\n");
        return 0;
    }
    if (nec_planes_size > sizeof(game_seg) - 0x4000) {
        nec_planes_size = sizeof(game_seg) - 0x4000;
    }
    memcpy(game_seg + 0x4000, nec_planes, nec_planes_size);
    free(nec_planes);

    int w = 0;
    int h = 0;
    uint8_t *image = zeliard_mcga_render_three_plane_ab(
        game_seg, 0x75A0, 0x10 * 0x40, 0x10, 0x40, &w, &h);
    if (!image) {
        printf("opdemo_nec_hou_handoff_disp_game_rect: FAIL render failed\n");
        return 0;
    }
    uint64_t image_hash = fnv1a64(image, (size_t)w * (size_t)h);
    size_t image_nz = nonzero_count(image, (size_t)w * (size_t)h);

    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        int dy = 0x48 + y;
        if (dy < 0 || dy >= ZELIARD_HEIGHT) continue;
        for (int x = 0; x < w; x++) {
            int dx = 0x20 * 4 + x;
            if (dx < 0 || dx >= ZELIARD_WIDTH) continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] = image[y * w + x];
        }
    }
    free(image);

    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int fb_nonzero = framebuffer_nonzero_count();
    int min_x = 0, min_y = 0, max_x = 0, max_y = 0;
    framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);

    int ok = image_hash == expected_image &&
             w == expected_w &&
             h == expected_h &&
             image_nz == expected_image_nonzero &&
             fb == expected_fb &&
             fb_nonzero == expected_fb_nonzero &&
             min_x == expected_min_x &&
             min_y == expected_min_y &&
             max_x == expected_max_x &&
             max_y == expected_max_y;
    printf("opdemo_nec_hou_handoff_disp_game_rect: %s image=%016llx w=%d h=%d image_nonzero=%zu framebuffer=%016llx fb_nonzero=%d bbox=(%d,%d,%d,%d)\n",
           ok ? "PASS" : "FAIL", (unsigned long long)image_hash, w, h,
           image_nz, (unsigned long long)fb, fb_nonzero,
           min_x, min_y, max_x, max_y);
    return ok;
}

static int run_nec_three_plane_reveal_case(void) {
    const uint32_t pass1_ms = 0;
    const uint32_t pass8_ms = OPDMO_TEST_WAIT_MS(7 * 0x14);
    int pass1_warm = 0;
    int pass8_warm = 0;

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, pass1_ms);
    uint64_t pass1 = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int pass1_nonzero = framebuffer_nonzero_count();
    for (int i = 0; i < ZELIARD_FB_SIZE; i++) {
        const palette_color_t c = g_palette[g_framebuf[i]];
        pass1_warm += c.r >= 120 && c.g >= 120 && c.b < 80;
    }

    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, pass8_ms);
    uint64_t pass8 = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int pass8_nonzero = framebuffer_nonzero_count();
    for (int i = 0; i < ZELIARD_FB_SIZE; i++) {
        const palette_color_t c = g_palette[g_framebuf[i]];
        pass8_warm += c.r >= 120 && c.g >= 120 && c.b < 80;
    }

    int ok = !g_rgb_framebuf_active && pass1 != pass8 &&
             pass8_nonzero > pass1_nonzero && pass8_warm > pass1_warm;
    printf("nec_three_plane_reveal: %s pass1=%016llx/%d/%d pass8=%016llx/%d/%d rgb=%d\n",
           ok ? "PASS" : "FAIL", (unsigned long long)pass1, pass1_nonzero,
           pass1_warm, (unsigned long long)pass8, pass8_nonzero, pass8_warm,
           g_rgb_framebuf_active);
    return ok;
}

static int run_sprite_restore_clears_previous_frame_case(void) {
    const uint32_t frame0_ms = OPDMO_TEST_WAIT_MS(8 * 0x14 + 2 * 0x14);
    const uint32_t frame8_ms = OPDMO_TEST_WAIT_MS(
        8 * 0x14 + 2 * 0x14 + 8 * 0x1E);

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, frame0_ms);
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, frame8_ms);
    uint64_t sequential = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, frame8_ms);
    uint64_t direct = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    int ok = sequential == direct;
    printf("sprite_restore_clears_previous_frame: %s sequential=%016llx direct=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)sequential,
           (unsigned long long)direct);
    return ok;
}

static int rgb_pixel_is(int x, int y, uint8_t r, uint8_t g, uint8_t b) {
    size_t offset = (size_t)(y * ZELIARD_WIDTH + x) * 3u;
    return g_rgb_framebuf[offset + 0] == r &&
           g_rgb_framebuf[offset + 1] == g &&
           g_rgb_framebuf[offset + 2] == b;
}

static int run_sprite_dac_transaction_cadence_case(void) {
    /* 105GDMCA:754-808 writes the palette and draws each of nine objects in
     * order.  Preserve the release-observed transaction crossings instead
     * of averaging palette and draw work into equal host durations. */
    const uint32_t frame0_ms = OPDMO_TEST_WAIT_MS(10 * 0x14) + 1;
    const uint32_t frame8_ms =
        OPDMO_TEST_WAIT_MS(10 * 0x14 + 8 * 0x1E) + 1;
    const uint32_t service_overlap_ms =
        OPDMO_TEST_WAIT_MS(10 * 0x14) - 17;
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE,
                                  service_overlap_ms);
    int service_overlap = g_rgb_framebuf_active &&
                          opening_nec_hou_sprite_debug_word() == 0xFFFFFFFEu &&
                          rgb_pixel_is(0, 189, 0, 0, 0) &&
                          rgb_pixel_is(0, 190, 248, 248, 0);
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE,
                                  frame0_ms);
    int frame0 = g_rgb_framebuf_active &&
                 rgb_pixel_is(0, 0, 0, 0, 0) &&
                 rgb_pixel_is(0, 189, 0, 0, 0) &&
                 rgb_pixel_is(0, 190, 248, 248, 0);
    opening_init();
    opening_render_phase_for_test(
        OPENING_PHASE_NEC_HOU_INTERLUDE,
        frame8_ms);
    int frame8 = rgb_pixel_is(0, 0, 120, 0, 0) &&
                 rgb_pixel_is(0, 100, 120, 0, 0) &&
                 rgb_pixel_is(0, 101, 248, 248, 0) &&
                 rgb_pixel_is(0, 143, 248, 248, 0) &&
                 rgb_pixel_is(0, 144, 120, 120, 0) &&
                 rgb_pixel_is(0, 185, 120, 120, 0) &&
                 rgb_pixel_is(0, 186, 248, 248, 248);

    int ok = service_overlap && frame0 && frame8;
    printf("sprite_dac_transaction_cadence: %s overlap=%d frame0=%d frame8=%d ms=%u/%u/%u debug=%08x\n",
           ok ? "PASS" : "FAIL", service_overlap, frame0, frame8,
           service_overlap_ms, frame0_ms, frame8_ms,
           opening_nec_hou_sprite_debug_word());
    return ok;
}

static int run_sprite_completion_restores_palette_case(void) {
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_DMAOU_DEMON_INTRO, 0);

    uint64_t palette = fnv1a64((const uint8_t *)g_palette,
                               sizeof(g_palette));
    int black0 = g_palette[0].r == 0 &&
                 g_palette[0].g == 0 &&
                 g_palette[0].b == 0;
    int ok = palette == 0xf2decbc9b73964b1ULL &&
             black0 && !g_rgb_framebuf_active;
    printf("sprite_completion_restores_ax2_palette: %s palette=%016llx color0=%u/%u/%u rgb=%d\n",
           ok ? "PASS" : "FAIL", (unsigned long long)palette,
           g_palette[0].r, g_palette[0].g, g_palette[0].b,
           g_rgb_framebuf_active);
    return ok;
}

static int run_sprite_restore_crossing_case(void) {
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, 1728);
    int frame6 = g_rgb_framebuf_active &&
                 rgb_pixel_is(0, 0, 248, 0, 0) &&
                 rgb_pixel_is(0, 132, 120, 0, 0) &&
                 rgb_pixel_is(0, 174, 248, 248, 0);
    int frame6_left_pixels = 0;
    int frame6_right_pixels = 0;
    int frame6_blue_bbox[4] = {ZELIARD_WIDTH, ZELIARD_HEIGHT, -1, -1};
    for (int y = 76; y < 100; y++) {
        for (int x = 0; x < 50; x++)
            frame6_left_pixels += !rgb_pixel_is(x, y, 248, 0, 0);
        for (int x = 280; x < 320; x++)
            frame6_right_pixels += !rgb_pixel_is(x, y, 248, 0, 0);
    }
    for (int y = 0; y < ZELIARD_HEIGHT; y++) {
        for (int x = 270; x < ZELIARD_WIDTH; x++) {
            size_t p = (size_t)(y * ZELIARD_WIDTH + x) * 3u;
            if (g_rgb_framebuf[p + 0] < 100 &&
                g_rgb_framebuf[p + 1] > 80 &&
                g_rgb_framebuf[p + 2] > 150) {
                if (x < frame6_blue_bbox[0]) frame6_blue_bbox[0] = x;
                if (y < frame6_blue_bbox[1]) frame6_blue_bbox[1] = y;
                if (x > frame6_blue_bbox[2]) frame6_blue_bbox[2] = x;
                if (y > frame6_blue_bbox[3]) frame6_blue_bbox[3] = y;
            }
        }
    }
    frame6 &= frame6_left_pixels == 0 && frame6_right_pixels > 20;

    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, 1829);
    int frame7 = rgb_pixel_is(0, 0, 248, 0, 0) &&
                 rgb_pixel_is(0, 48, 120, 0, 0);
    int frame7_left_pixels = 0;
    int frame7_right_pixels = 0;
    int frame7_lower_left_pixels = 0;
    int frame7_lower_right_pixels = 0;
    for (int y = 76; y < 100; y++) {
        for (int x = 0; x < 50; x++)
            frame7_left_pixels += !rgb_pixel_is(x, y, 120, 0, 0);
        for (int x = 280; x < 320; x++)
            frame7_right_pixels += !rgb_pixel_is(x, y, 120, 0, 0);
    }
    for (int y = 116; y < 168; y++) {
        for (int x = 32; x < 84; x++)
            frame7_lower_left_pixels += !rgb_pixel_is(x, y, 120, 0, 0);
        for (int x = 236; x < 288; x++)
            frame7_lower_right_pixels += !rgb_pixel_is(x, y, 120, 0, 0);
    }
    /* Once sprite_restore_loop returns, the next sprite_anim_frame_top
     * advances all records before drawing.  State 7 retains slots
     * 1,2,3,6,7; slot 8 has crossed the x=4Bh active boundary. */
    frame7 &= frame7_left_pixels > 20 && frame7_right_pixels == 0 &&
              frame7_lower_left_pixels > 20 &&
              frame7_lower_right_pixels > 20;

    opening_render_phase_for_test(OPENING_PHASE_NEC_HOU_INTERLUDE, 2231);
    int frame10 = rgb_pixel_is(0, 0, 248, 248, 248) &&
                  rgb_pixel_is(0, 100, 248, 248, 248);

    int ok = frame6 && frame7 && frame10;
    printf("sprite_restore_crossings: %s frame6=%d frame7=%d frame10=%d pixels=%d/%d,%d/%d,%d/%d blue6=%d,%d,%d,%d\n",
           ok ? "PASS" : "FAIL", frame6, frame7, frame10,
           frame6_left_pixels, frame6_right_pixels,
           frame7_left_pixels, frame7_right_pixels,
           frame7_lower_left_pixels, frame7_lower_right_pixels,
           frame6_blue_bbox[0], frame6_blue_bbox[1],
           frame6_blue_bbox[2], frame6_blue_bbox[3]);
    return ok;
}

static void advance_to_opening(void) {
    zeliard_init();
    zeliard_tick(16);
    zeliard_key(32);
    zeliard_tick(16);
    zeliard_tick(16);
}

static int run_copyright_input_ignored_case(uint64_t expected_fb_fnv) {
    zeliard_init();
    zeliard_tick(OPENING_COPYRIGHT_INPUT_SAMPLE_MS);
    zeliard_key(32);
    zeliard_tick(16);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int scene = zeliard_scene();
    int ok = scene == ZELIARD_SCENE_OPENING &&
             opening_phase_id() == OPENING_PHASE_COPYRIGHT_TITLE_CARD &&
             fb == expected_fb_fnv;
    printf("copyright_input_ignored: %s scene=%d phase=%d framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", scene, opening_phase_id(), (unsigned long long)fb);
    return ok;
}

static int run_opening_input_ignores_copyright_card_case(void) {
    advance_to_opening();
    int opening_scene = zeliard_scene();
    zeliard_key(13);
    zeliard_tick(16);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int after_scene = zeliard_scene();
    int ok = opening_scene == ZELIARD_SCENE_OPENING &&
             after_scene == ZELIARD_SCENE_OPENING &&
             opening_phase_id() == OPENING_PHASE_COPYRIGHT_TITLE_CARD &&
             fb == 0x1bd80e81a778a2caULL;
    printf("opening_input_ignores_copyright_card: %s opening_scene=%d after_scene=%d phase=%d framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", opening_scene, after_scene, opening_phase_id(),
           (unsigned long long)fb);
    return ok;
}

static int run_opening_input_advances_to_credits_case(void) {
    opening_init();
    opening_tick(OPENING_TITLE_COMPLETE_MS);
    opening_tick(4000);
    int before_phase = opening_phase_id();
    uint64_t before_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    opening_key_advance();
    int clear_phase = opening_phase_id();
    uint64_t clear_pass_zero_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    opening_tick(600);
    int before_clear_complete_phase = opening_phase_id();
    opening_tick(OPENING_INPUT_CLEAR_MS - 600);
    int after_phase = opening_phase_id();
    int ok = before_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             clear_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             clear_pass_zero_fb == 0xc4bfb36b05b4fb72ULL &&
             clear_pass_zero_fb != before_fb &&
             before_clear_complete_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             after_phase == OPENING_PHASE_STAFF_CREDITS &&
             !opening_done();
    printf("opening_input_advances_to_credits: %s before=%d clear=%d pending=%d after=%d before_fb=%016llx pass0_fb=%016llx done=%d\n",
           ok ? "PASS" : "FAIL", before_phase, clear_phase,
           before_clear_complete_phase, after_phase,
           (unsigned long long)before_fb,
           (unsigned long long)clear_pass_zero_fb,
           opening_done());
    return ok;
}

static int run_opening_input_during_amulet_clear_is_ignored_case(void) {
    opening_init();
    opening_tick(OPENING_TITLE_COMPLETE_MS);
    opening_tick(4000);
    opening_key_advance();

    opening_tick(16);
    int fade_phase = opening_phase_id();
    opening_key_advance();

    int phase = opening_phase_id();
    int ok = fade_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             !opening_done();
    printf("opening_input_during_amulet_clear_is_ignored: %s clear=%d phase=%d done=%d\n",
           ok ? "PASS" : "FAIL", fade_phase, phase, opening_done());
    return ok;
}

static int run_opening_input_credits_to_story_case(void) {
    opening_init();
    opening_tick(OPENING_TITLE_COMPLETE_MS);
    opening_key_advance();
    opening_tick(OPENING_SCANLINE_EXIT_FADE_MS);
    opening_set_phase_for_test(OPENING_PHASE_STAFF_CREDITS);
    int before_phase = opening_phase_id();
    opening_key_advance();
    int after_phase = opening_phase_id();
    int ok = before_phase == OPENING_PHASE_STAFF_CREDITS &&
             after_phase == OPENING_PHASE_RAIN_PRINCESS &&
             !opening_done();
    printf("opening_input_credits_to_story: %s before=%d after=%d done=%d\n",
           ok ? "PASS" : "FAIL", before_phase, after_phase, opening_done());
    return ok;
}

static int run_opening_input_story_exits_to_game_case(void) {
    static const int story_phases[] = {
        OPENING_PHASE_RAIN_PRINCESS,
        OPENING_PHASE_RAIN_TURNS_TO_SAND,
        OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
        OPENING_PHASE_KING_GRIEF_AND_SPIRIT,
        OPENING_PHASE_DUKE_ARRIVES,
        OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS,
        OPENING_PHASE_JASHIIN_CONFRONTATION,
        OPENING_PHASE_JASHIIN_DEPARTURE,
    };
    static const int keys[] = {32, 13};
    int ok = 1;
    for (size_t phase_index = 0; phase_index < sizeof(story_phases) / sizeof(story_phases[0]); phase_index++) {
        for (size_t key_index = 0; key_index < sizeof(keys) / sizeof(keys[0]); key_index++) {
            zeliard_init();
            opening_set_phase_for_test(story_phases[phase_index]);
            zeliard_key(keys[key_index]);
            zeliard_tick(0);
            ok &= zeliard_scene() == ZELIARD_SCENE_GAME;
        }
    }
    printf("opening_input_story_exits_to_game: %s phases=%llu keys=%llu\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)(sizeof(story_phases) / sizeof(story_phases[0])),
           (unsigned long long)(sizeof(keys) / sizeof(keys[0])));
    return ok;
}

static int run_opening_key_contract_case(void) {
    const int keys[] = {32, 13};
    int ok = 1;
    for (size_t i = 0; i < sizeof(keys) / sizeof(keys[0]); i++) {
        int initial_phase, after_title_phase, after_fade_phase, after_credits_phase;
        zeliard_init();
        zeliard_key(keys[i]);
        zeliard_tick(16);
        zeliard_tick(16);
        zeliard_key(keys[i]);
        initial_phase = opening_phase_id();
        ok &= initial_phase == OPENING_PHASE_COPYRIGHT_TITLE_CARD;

        opening_tick(OPENING_TITLE_COMPLETE_MS);
        zeliard_key(keys[i]);
        after_title_phase = opening_phase_id();
        ok &= after_title_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE;
        opening_tick(OPENING_SCANLINE_EXIT_FADE_MS);
        after_fade_phase = opening_phase_id();
        ok &= after_fade_phase == OPENING_PHASE_STAFF_CREDITS;
        ok &= !opening_done();

        zeliard_key(keys[i]);
        after_credits_phase = opening_phase_id();
        ok &= after_credits_phase == OPENING_PHASE_RAIN_PRINCESS;
        ok &= !opening_done();
        zeliard_key(keys[i]);
        zeliard_tick(0);
        ok &= zeliard_scene() == ZELIARD_SCENE_GAME;
        printf("opening_key_route: key=%d phases=%d,%d,%d,%d\n", keys[i],
               initial_phase, after_title_phase, after_fade_phase, after_credits_phase);
    }
    printf("opening_space_enter_routing: %s\n", ok ? "PASS" : "FAIL");
    return ok;
}

static int run_copyright_timer_starts_prologue_case(void) {
    zeliard_init();
    zeliard_tick(OPENING_TITLE_COMPLETE_MS - 1);
    int before_phase = opening_phase_id();
    zeliard_tick(1);
    int after_phase = opening_phase_id();
    int ok = zeliard_scene() == ZELIARD_SCENE_OPENING &&
             before_phase == OPENING_PHASE_COPYRIGHT_TITLE_CARD &&
             after_phase == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE;
    printf("copyright_timer_starts_prologue: %s before=%d after=%d\n",
           ok ? "PASS" : "FAIL", before_phase, after_phase);
    return ok;
}

static int run_amulet_phase_starts_first_mcga_pass_case(void) {
    zeliard_init();
    zeliard_tick(OPENING_TITLE_COMPLETE_MS);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = zeliard_scene() == ZELIARD_SCENE_OPENING &&
             opening_phase_id() == OPENING_PHASE_AMULET_ANCIENT_PROLOGUE &&
             opening_phase_elapsed_ms() == 0 &&
             fb == 0xc0d7344e7c121107ULL &&
             g_palette[0].r == 0 &&
             g_palette[0].g == 0 &&
             g_palette[0].b == 0;
    printf("amulet_phase_starts_first_mcga_pass: %s phase=%d elapsed=%u framebuffer=%016llx color00=%u/%u/%u\n",
           ok ? "PASS" : "FAIL",
           opening_phase_id(), opening_phase_elapsed_ms(),
           (unsigned long long)fb,
           g_palette[0].r, g_palette[0].g, g_palette[0].b);
    return ok;
}

static int run_automatic_interlude_phase_order_case(void) {
    zeliard_init();
    zeliard_tick(OPENING_TITLE_COMPLETE_MS + OPENING_AMULET_AUTO_MS + 10);
    int phase_nec_hou = opening_phase_id();

    zeliard_tick(OPENING_NEC_HOU_INTERLUDE_MS + 10);
    int phase_dmaou = opening_phase_id();

    zeliard_tick(OPENING_DMAOU_DEMON_INTRO_MS + 10);
    int phase_title = opening_phase_id();

    zeliard_tick(OPENING_TITLE_LOGO_COLOR_MS + 10);
    int phase_credits = opening_phase_id();

    int ok = phase_nec_hou == OPENING_PHASE_NEC_HOU_INTERLUDE &&
             phase_dmaou == OPENING_PHASE_DMAOU_DEMON_INTRO &&
             phase_title == OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION &&
             phase_credits == OPENING_PHASE_STAFF_CREDITS;
    printf("automatic_interlude_phase_order: %s phases=%d,%d,%d,%d\n",
           ok ? "PASS" : "FAIL",
           phase_nec_hou, phase_dmaou, phase_title, phase_credits);
    return ok;
}

static int run_title_handoff_visual_regression_case(void) {
    opening_init();

    opening_render_phase_for_test(OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,
                                  OPDMO_TEST_WAIT_MS(8 * 0x14));
    uint64_t entry_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    opening_render_phase_for_test(OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,
                                  OPDMO_TEST_WAIT_MS(8 * 0x14 + 16 * 0x14) + 14000);
    uint64_t logo_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    int ok = entry_fb == 0x10c1dbf72fb2ab25ULL &&
             /* MASM 100OPDMO:510-515, pair 29 of 105GDMCA:37B4. */
             logo_fb == 0x72b10cf33f09f8b9ULL;
    printf("title_handoff_visual_regression: %s entry=%016llx logo=%016llx\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)entry_fb,
           (unsigned long long)logo_fb);
    return ok;
}

static int run_title_handoff_timing_boundaries_case(void) {
    typedef struct {
        const char *name;
        uint32_t elapsed_ms;
        uint64_t expected_fb;
        size_t expected_nonzero;
    } boundary_t;
    const boundary_t boundaries[] = {
        {"after_preclear", OPDMO_TEST_WAIT_MS(8 * 0x14), 0x10c1dbf72fb2ab25ULL, 32000},
        {"after_wait_f0", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0), 0x10c1dbf72fb2ab25ULL, 32000},
        /* Values below come from the MASM release oracle:
         * test_mcga_title_sweep_assets_oracle.py. */
        {"after_ttl1_update", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14), 0x35893eebb0ca0bdcULL, 32457},
        {"ttl3_reveal_start", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0), 0x35893eebb0ca0bdcULL, 32457},
        {"after_ttl3_update", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 16 * 0x14), 0xe6682f4dcc5fd4cbULL, 39868},
        {"color_loop_start", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0), 0x257dcb1d74b024cbULL, 39860},
        {"color_loop_after_10_waits_pair_11", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 10 * 0x50), 0xc514af3f6ad9fcc0ULL, 40172},
        {"visual_sample_14000ms_pair_29", OPDMO_TEST_WAIT_MS(8 * 0x14 + 16 * 0x14) + 14000, 0x72b10cf33f09f8b9ULL, 40445},
        {"color_loop_done_pair_100", OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 + 100 * 0x50), 0xbd2123d05705e410ULL, 41239},
    };

    int ok = 1;
    for (size_t i = 0; i < sizeof(boundaries) / sizeof(boundaries[0]); i++) {
        opening_init();
        opening_render_phase_for_test(OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,
                                      boundaries[i].elapsed_ms);
        uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
        size_t nz = nonzero_count(g_framebuf, ZELIARD_FB_SIZE);
        int pass = fb == boundaries[i].expected_fb &&
                   nz == boundaries[i].expected_nonzero;
        ok &= pass;
        printf("title_handoff_boundary:%s: %s elapsed=%u fb=%016llx nonzero=%llu\n",
               boundaries[i].name, pass ? "PASS" : "FAIL",
               boundaries[i].elapsed_ms,
               (unsigned long long)fb,
               (unsigned long long)nz);
    }
    return ok;
}

static int run_opening_title_card_case(uint64_t expected_fb_fnv) {
    opening_init();
    opening_tick(OPENING_TITLE_FULL_SAMPLE_MS);
    opening_tick(0);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == expected_fb_fnv;
    printf("opening_title_card: %s framebuffer=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb);
    return ok;
}

/* This is the join between two independently checked MASM contracts: the
 * completed NEC MCGA draw, followed by 100OPDMO:6358 using the mechanical
 * 105GDMCA:32C9/332C runtime.  It deliberately replaced the former
 * hand-authored render_scanline_text() checksum. */
static int run_opening_scanline_runtime_bridge_case(uint64_t expected_fb_fnv,
                                                     uint64_t expected_work_fnv) {
    opening_init();
    opening_tick(OPENING_SCANLINE_SAMPLE_MS);
    opening_tick(0);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    opening_scanline_runtime_summary_t s =
        opening_amulet_scanline_runtime_summary();
    int ok = fb == expected_fb_fnv &&
             s.rendered_draws == 96 &&
             s.visible_hash == expected_fb_fnv &&
             s.work_hash == expected_work_fnv;
    printf("opening_scanline_runtime_bridge: %s framebuffer=%016llx "
           "draws=%llu visible=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb,
           (unsigned long long)s.rendered_draws,
           (unsigned long long)s.visible_hash,
           (unsigned long long)s.work_hash);
    return ok;
}

static int run_amulet_scanline_runtime_completion_case(void) {
    const uint32_t elapsed_ms = OPDMO_TEST_WAIT_MS(
        8 * 0x14 + (31 * 10 + 120 - 1) * 0x1C);
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_AMULET_ANCIENT_PROLOGUE,
                                  elapsed_ms);
    opening_scanline_runtime_summary_t s =
        opening_amulet_scanline_runtime_summary();
    int ok = s.rendered_draws == 430 && s.exit_frame == 0x78 &&
             s.finished == 1 &&
             s.visible_hash == 0x76a5c68141189f10ULL &&
             s.work_hash == 0xb65f2bb82806e676ULL;
    printf("amulet_scanline_runtime_completion: %s draws=%llu stream=%llu exit=%u "
           "finished=%u visible=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)s.rendered_draws,
           (unsigned long long)s.stream_pos, s.exit_frame, s.finished,
           (unsigned long long)s.visible_hash, (unsigned long long)s.work_hash);
    return ok;
}

static int run_final_scanline_runtime_completion_case(void) {
    /* A sufficiently late deterministic snapshot consumes the complete
     * 7338h six-line/FF stream plus its real 0A0h AX=0 exit. */
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_DESTINY_CARD, 1000000u);
    opening_scanline_runtime_summary_t s =
        opening_final_scanline_runtime_summary();
    int ok = s.rendered_draws == 230 && s.exit_frame == 0xA0 &&
             s.finished == 1 && s.work_hash == 0x9609F325A52F2190ULL;
    printf("final_scanline_runtime_completion: %s draws=%llu stream=%llu exit=%u "
           "finished=%u visible=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)s.rendered_draws,
           (unsigned long long)s.stream_pos, s.exit_frame, s.finished,
           (unsigned long long)s.visible_hash, (unsigned long long)s.work_hash);
    return ok;
}

static int run_final_transition_clear_case(void) {
    /* 100OPDMO:1083-1128: seven 10-frame scanline records, the 0A0h AX=0
     * exit loop, ten C8h holds, then gfx_mode_fn(0000h,50C8h). */
    const uint32_t clear_start_ticks =
        8 * 0x14 + 0xF0 + 8 * 0x14 +
        7 * 10 * 0x1C + 0xA0 * 0x1C + 10 * 0xC8;

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_DESTINY_CARD,
                                  OPDMO_TEST_WAIT_MS(clear_start_ticks - 1));
    int before = framebuffer_nonzero_count();

    opening_render_phase_for_test(OPENING_PHASE_DESTINY_CARD,
                                  OPDMO_TEST_WAIT_MS(clear_start_ticks));
    int pass1 = framebuffer_nonzero_count();
    opening_render_phase_for_test(OPENING_PHASE_DESTINY_CARD,
                                  OPDMO_TEST_WAIT_MS(clear_start_ticks + 3 * 0x14));
    int pass4 = framebuffer_nonzero_count();
    zel_opdmo_trace_reset();
    opening_render_phase_for_test(OPENING_PHASE_DESTINY_CARD,
                                  OPDMO_TEST_WAIT_MS(clear_start_ticks + 7 * 0x14));
    int pass8 = framebuffer_nonzero_count();

    zel_opdmo_trace_event_t events[64];
    size_t count = zel_opdmo_trace_copy(events, 64);
    int clear_event = 0;
    for (size_t i = 0; i < count; i++) {
        clear_event += events[i].kind == ZEL_OPDMO_TRACE_GFX_MODE &&
                       events[i].bx == 0x0000 && events[i].cx == 0x50C8;
    }

    int ok = before > pass1 && pass1 > pass4 && pass4 > pass8 &&
             pass8 == 0 && clear_event == 1;
    printf("final_transition_clear: %s nonzero=%d/%d/%d/%d event=%d\n",
           ok ? "PASS" : "FAIL", before, pass1, pass4, pass8, clear_event);
    return ok;
}

static int run_late_frame_case(const char *name, opening_debug_late_frame_t frame,
                               uint64_t expected_fb_fnv) {
    opening_debug_render_late_frame(frame);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == expected_fb_fnv;
    printf("%s: %s framebuffer=%016llx\n",
           name, ok ? "PASS" : "FAIL", (unsigned long long)fb);
    return ok;
}

static uint64_t framebuffer_rect_fnv(int x, int y, int w, int h) {
    uint8_t row[ZELIARD_WIDTH];
    uint64_t hval = 1469598103934665603ULL;
    for (int yy = 0; yy < h; yy++) {
        int sy = y + yy;
        if (sy < 0 || sy >= ZELIARD_HEIGHT)
            continue;
        int copy_w = w;
        int sx = x;
        if (sx < 0) {
            copy_w += sx;
            sx = 0;
        }
        if (sx + copy_w > ZELIARD_WIDTH)
            copy_w = ZELIARD_WIDTH - sx;
        if (copy_w <= 0)
            continue;
        memcpy(row, &g_framebuf[sy * ZELIARD_WIDTH + sx], (size_t)copy_w);
        for (int i = 0; i < copy_w; i++) {
            hval ^= row[i];
            hval *= 1099511628211ULL;
        }
    }
    return hval;
}

static int framebuffer_rect_nonzero_count(int x, int y, int w, int h) {
    int count = 0;
    for (int yy = 0; yy < h; yy++) {
        int sy = y + yy;
        if (sy < 0 || sy >= ZELIARD_HEIGHT)
            continue;
        for (int xx = 0; xx < w; xx++) {
            int sx = x + xx;
            if (sx < 0 || sx >= ZELIARD_WIDTH)
                continue;
            count += g_framebuf[sy * ZELIARD_WIDTH + sx] != 0;
        }
    }
    return count;
}

static int run_late_frame_rect_case(const char *name,
                                    opening_debug_late_frame_t frame,
                                    int x, int y, int w, int h,
                                    uint64_t expected_rect_fnv,
                                    int expected_nonzero) {
    opening_debug_render_late_frame(frame);
    uint64_t rect = framebuffer_rect_fnv(x, y, w, h);
    int nonzero = framebuffer_rect_nonzero_count(x, y, w, h);
    int ok = rect == expected_rect_fnv && nonzero == expected_nonzero;
    printf("%s: %s rect=%d,%d,%d,%d fnv=%016llx nonzero=%d\n",
           name, ok ? "PASS" : "FAIL", x, y, w, h,
           (unsigned long long)rect, nonzero);
    return ok;
}

static int run_phase_frame_case(const char *name, int phase_id, uint32_t elapsed_ms,
                                uint64_t expected_fb_fnv) {
    opening_init();
    opening_render_phase_for_test(phase_id, elapsed_ms);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == expected_fb_fnv;
    printf("%s: %s phase=%d elapsed=%u framebuffer=%016llx\n",
           name, ok ? "PASS" : "FAIL", phase_id, elapsed_ms,
           (unsigned long long)fb);
    return ok;
}

static int run_maop_live_border_case(void) {
    /* 100OPDMO:972-978 draws disp_load_setup(1515h,315Dh), then places the
     * MAOP image four pixels inside it with disp_script_area at 1618h. */
    enum {
        left = 0x15 * 4,
        top = 0x15,
        right = left + 0x31 * 4 - 1,
        bottom = top + 0x5D - 1,
    };
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_JASHIIN_CONFRONTATION, 0);

    int mismatches = 0;
    for (int x = left; x <= right; x++) {
        mismatches += g_framebuf[top * ZELIARD_WIDTH + x] != 0xFF;
        mismatches += g_framebuf[bottom * ZELIARD_WIDTH + x] != 0xFF;
    }
    for (int y = top; y <= bottom; y++) {
        mismatches += g_framebuf[y * ZELIARD_WIDTH + left] != 0xFF;
        mismatches += g_framebuf[y * ZELIARD_WIDTH + right] != 0xFF;
    }

    palette_color_t white = g_palette[0xFF];
    int ok = mismatches == 0 && white.r == 248 && white.g == 248 &&
             white.b == 248;
    printf("maop_live_border: %s bounds=%d,%d,%d,%d mismatches=%d "
           "rgb=%u/%u/%u\n",
           ok ? "PASS" : "FAIL", left, top, right, bottom, mismatches,
           white.r, white.g, white.b);
    return ok;
}

static int run_jashiin_departure_yuu2_shell_case(void) {
    zel_opdmo_trace_event_t events[4096];

    opening_init();
    zel_opdmo_trace_reset();
    opening_render_phase_for_test(OPENING_PHASE_JASHIIN_DEPARTURE, 500);
    uint64_t transition_palette =
        fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int transition_center_mismatches = 0;
    for (int y = 24; y < 112; y++) {
        for (int x = 144; x < 176; x++) {
            uint8_t pixel = g_framebuf[y * ZELIARD_WIDTH + x];
            transition_center_mismatches += pixel != 0x02 && pixel != 0x20;
        }
    }
    size_t event_count = zel_opdmo_trace_copy(events, 4096);
    int transition_ax8 = 0;
    int transition_ax7 = 0;
    int transition_last_palette = -1;
    for (size_t i = 0; i < event_count; i++) {
        if (events[i].kind != ZEL_OPDMO_TRACE_GFX_PALETTE)
            continue;
        transition_ax8 += events[i].ax == 8;
        transition_ax7 += events[i].ax == 7;
        transition_last_palette = events[i].ax;
    }

    opening_init();
    zel_opdmo_trace_reset();
    opening_render_phase_for_test(OPENING_PHASE_JASHIIN_DEPARTURE, 30000);
    uint64_t final_palette =
        fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    uint64_t final_frame = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    event_count = zel_opdmo_trace_copy(events, 4096);
    int palette7_event = -1;
    int yuu2_event = -1;
    for (size_t i = 0; i < event_count; i++) {
        if (events[i].kind == ZEL_OPDMO_TRACE_GFX_PALETTE &&
            events[i].ax == 7)
            palette7_event = (int)i;
        if (events[i].kind == ZEL_OPDMO_TRACE_DISP_GAME &&
            events[i].bx == 0x1010 && events[i].cx == 0x3160)
            yuu2_event = (int)i;
    }

    int border_mismatches = 0;
    for (int x = 66; x <= 257; x++) {
        border_mismatches += g_framebuf[23 * ZELIARD_WIDTH + x] != 0x77;
        border_mismatches += g_framebuf[111 * ZELIARD_WIDTH + x] != 0x77;
    }
    for (int y = 23; y <= 111; y++) {
        border_mismatches += g_framebuf[y * ZELIARD_WIDTH + 66] != 0x77;
        border_mismatches += g_framebuf[y * ZELIARD_WIDTH + 257] != 0x77;
    }

    int surround_mismatches = 0;
    for (int y = 24; y < 111; y++) {
        for (int x = 32; x <= 63; x++) {
            uint8_t pixel = g_framebuf[y * ZELIARD_WIDTH + x];
            surround_mismatches += pixel != 0x02 && pixel != 0x20;
        }
        for (int x = 260; x <= 287; x++) {
            uint8_t pixel = g_framebuf[y * ZELIARD_WIDTH + x];
            surround_mismatches += pixel != 0x02 && pixel != 0x20;
        }
    }

    int ok = transition_ax8 > 0 && transition_last_palette == 8 &&
             transition_palette == 0xfe6d0ffd656d2c0dULL &&
             transition_center_mismatches == 0 &&
             final_palette == 0x17f2e97c18ac0f31ULL &&
             palette7_event >= 0 && yuu2_event > palette7_event &&
             border_mismatches == 0 && surround_mismatches == 0;
    printf("jashiin_departure_yuu2_shell: %s transition_ax8/ax7/last=%d/%d/%d "
           "palette=%016llx center=%d final=%016llx/%016llx events=%d/%d "
           "border=%d surround=%d\n",
           ok ? "PASS" : "FAIL",
           transition_ax8, transition_ax7, transition_last_palette,
           (unsigned long long)transition_palette,
           transition_center_mismatches,
           (unsigned long long)final_frame,
           (unsigned long long)final_palette,
           palette7_event, yuu2_event,
           border_mismatches, surround_mismatches);
    return ok;
}

static int run_rain_princess_preamble_hidden_case(void) {
    const uint32_t entry_ms = OPDMO_TEST_WAIT_MS(2 * 8 * 0x14);

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_RAIN_PRINCESS, entry_ms);
    uint64_t before = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    /* Runtime 79C6h is 'P', fetched after one 10h timer wait.  MASM's
     * text_color_fg/bg bytes are still 00/00 here, so executing it must not
     * alter the visible framebuffer.  FA sets normal 00/07 colors later. */
    opening_render_phase_for_test(
        OPENING_PHASE_RAIN_PRINCESS,
        entry_ms + OPDMO_TEST_WAIT_MS(0x10));
    uint64_t after = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);

    int ok = before == after;
    printf("rain_princess_preamble_hidden: %s before=%016llx after=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)before,
           (unsigned long long)after);
    return ok;
}

static int run_story_break_preserves_text_page_case(void) {
    size_t script3_size = 0;
    u8 *script3 = platform_load_asset("opdemo_story_script_3.bin",
                                      &script3_size);
    if (!script3)
        return 0;

    /* 100OPDMO:855-864: eight 14h entry passes, call 03, AL=4 delay,
     * blend/blit, then call 04.  Sample eight fetched bytes into call 04. */
    u32 ticks = 8u * 0x14u +
                zeliard_opening_script_timer_ticks(script3, script3_size) +
                0x04u + 8u * 0x10u;
    free(script3);

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                                  zel_timer_ticks_to_ms(ticks));
    int carried_rows = framebuffer_rect_nonzero_count(4, 143, 312, 20);
    int continuation_row = framebuffer_rect_nonzero_count(4, 163, 312, 10);
    int ok = carried_rows > 500 && continuation_row > 0;
    printf("story_break_preserves_text_page: %s carried=%d continuation=%d\n",
           ok ? "PASS" : "FAIL", carried_rows, continuation_row);
    return ok;
}

static int run_yuu_split_preserves_font_inv_center_case(void) {
    /* 100OPDMO:942-961 leaves CS:[3020]'s completed red wipe in A000 and
     * draws the YUUP/OUP portrait rectangles on either side.  The untouched
     * center strip must therefore survive the phase-7 -> phase-8 handoff. */
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_DUKE_ARRIVES, 1000000u);
    int wipe_other = 0;
    for (int y = 24; y < 112; y++) {
        for (int x = 144; x < 176; x++) {
            uint8_t v = g_framebuf[y * ZELIARD_WIDTH + x];
            wipe_other += v != 0x02 && v != 0x20;
        }
    }

    opening_render_phase_for_test(OPENING_PHASE_KING_PLEADS_DUKE_ACCEPTS, 0);
    int split_other = 0;
    for (int y = 24; y < 112; y++) {
        for (int x = 144; x < 176; x++) {
            uint8_t v = g_framebuf[y * ZELIARD_WIDTH + x];
            split_other += v != 0x02 && v != 0x20;
        }
    }

    int ok = wipe_other == 0 && split_other == 0;
    printf("yuu_split_preserves_font_inv_center: %s wipe_other=%d split_other=%d\n",
           ok ? "PASS" : "FAIL", wipe_other, split_other);
    return ok;
}

static int duke_dissolve_nonred_count(void) {
    int count = 0;
    for (int y = 24; y < 112; y++) {
        for (int x = 32; x < 288; x++) {
            uint8_t v = g_framebuf[y * ZELIARD_WIDTH + x];
            count += v != 0x02 && v != 0x20;
        }
    }
    return count;
}

static int run_duke_entry_masked_dissolve_case(void) {
    /* 100OPDMO:929-933 retains script 13's completed red CS:[3020] page and
     * passes yuu1 through the eight 14h-timed masked-write lanes. */
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_KING_GRIEF_AND_SPIRIT,
                                  1000000u);
    int red_base = duke_dissolve_nonred_count();

    opening_render_phase_for_test(OPENING_PHASE_DUKE_ARRIVES, 0);
    int pass1 = duke_dissolve_nonred_count();
    opening_render_phase_for_test(OPENING_PHASE_DUKE_ARRIVES,
                                  OPDMO_TEST_WAIT_MS(4 * 0x14));
    int pass4 = duke_dissolve_nonred_count();
    opening_render_phase_for_test(OPENING_PHASE_DUKE_ARRIVES,
                                  OPDMO_TEST_WAIT_MS(8 * 0x14));
    int pass8 = duke_dissolve_nonred_count();

    int ok = red_base == 0 && pass1 > red_base && pass4 > pass1 &&
             pass8 > pass4;
    printf("duke_entry_masked_dissolve: %s red=%d pass1=%d pass4=%d pass8=%d\n",
           ok ? "PASS" : "FAIL", red_base, pass1, pass4, pass8);
    return ok;
}

/* Build the phase-5 removal boundary from the exact extracted OPDMO streams,
 * rather than baking a browser-observed millisecond. */
static uint32_t phase5_apparition_remove_start_ms(void) {
    static const char *const scripts[] = {
        "opdemo_story_script_3.bin", "opdemo_story_script_4.bin",
        "opdemo_story_script_5.bin", "opdemo_story_script_6.bin",
        "opdemo_story_script_7.bin",
    };
    u32 ticks = 8 * 0x14 + 0x04 + 8 * 0x14;
    for (size_t i = 0; i < sizeof(scripts) / sizeof(scripts[0]); i++) {
        size_t size = 0;
        u8 *script = platform_load_asset(scripts[i], &size);
        if (!script)
            return 0;
        ticks += zeliard_opening_script_timer_ticks(script, size);
        free(script);
    }
    return zel_timer_ticks_to_ms(ticks);
}

static uint32_t phase5_apparition_reveal_start_ms(void) {
    static const char *const scripts[] = {
        "opdemo_story_script_3.bin", "opdemo_story_script_4.bin",
        "opdemo_story_script_5.bin",
    };
    u32 ticks = 8 * 0x14 + 0x04;
    for (size_t i = 0; i < sizeof(scripts) / sizeof(scripts[0]); i++) {
        size_t size = 0;
        u8 *script = platform_load_asset(scripts[i], &size);
        if (!script)
            return 0;
        ticks += zeliard_opening_script_timer_ticks(script, size);
        free(script);
    }
    return zel_timer_ticks_to_ms(ticks);
}

static int run_dmaou_black_stripe_reveal_case(void) {
    const uint32_t reveal_start = phase5_apparition_reveal_start_ms();
    if (!reveal_start)
        return 0;

    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                                  reveal_start + OPDMO_TEST_WAIT_MS(1));
    int selected_nonblack = 0;
    int untouched_nonblack = 0;
    for (int x = 16; x < 304; x++) {
        selected_nonblack += g_framebuf[16 * ZELIARD_WIDTH + x] != 0;
        untouched_nonblack += g_framebuf[17 * ZELIARD_WIDTH + x] != 0;
    }

    int ok = selected_nonblack == 0 && untouched_nonblack > 0;
    printf("dmaou_black_stripe_reveal: %s start=%u selected=%d untouched=%d\n",
           ok ? "PASS" : "FAIL", reveal_start,
           selected_nonblack, untouched_nonblack);
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

static void fill_opdmo_script_metrics(u8 widths[96], u8 advances[96]) {
    static const u8 real_widths[96] = {
        0, 2, 2, 3, 1, 0, 0, 2, 2, 3, 1, 1, 1, 2, 2, 0,
        1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 3, 2, 1, 1, 2, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 2, 2, 1, 1,
        1, 0, 0, 1, 0, 1, 1, 0, 0, 2, 1, 0, 2, 0, 1, 1,
        0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 2, 0, 3, 1, 0
    };
    static const u8 real_advances[96] = {
        5, 4, 4, 4, 6, 8, 5, 3, 4, 4, 6, 6, 6, 5, 6, 8,
        7, 5, 7, 7, 7, 7, 7, 7, 7, 7, 3, 4, 6, 6, 6, 7,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 5, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 7, 8, 8, 8, 8, 8, 7, 5, 3, 5, 6, 7,
        7, 8, 8, 7, 8, 7, 7, 8, 8, 5, 6, 8, 5, 8, 7, 7,
        8, 8, 8, 7, 6, 8, 8, 8, 7, 7, 7, 4, 8, 4, 7, 8
    };
    memcpy(widths, real_widths, sizeof(real_widths));
    memcpy(advances, real_advances, sizeof(real_advances));
}

static int run_opdmo_script_metric_table_case(void) {
    u8 widths[96];
    u8 advances[96];
    fill_opdmo_script_metrics(widths, advances);
    uint64_t width_hash = fnv1a64(widths, sizeof(widths));
    uint64_t advance_hash = fnv1a64(advances, sizeof(advances));
    int ok = width_hash == 0xed77bdb2b81d208cULL &&
             advance_hash == 0x5f47e03bf75dbdb9ULL;
    printf("opdemo_script_metric_tables: %s widths=%016llx advances=%016llx\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)width_hash,
           (unsigned long long)advance_hash);
    return ok;
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

static int run_scene_sprite_a_case(void) {
    opening_sprite_a_summary_t s = opening_scene_sprite_a_summary();
    int ok = 1;
    ok &= s.record_count == 9;
    ok &= s.source_bytes_consumed == 54;
    ok &= s.frame_count == 12;
    ok &= s.frame_wait_al == 0x1E;
    ok &= s.dispatch_slot == 0x3012;
    ok &= s.dispatch_target == 0x3437;
    ok &= s.records[0].x == 0x58;
    ok &= s.records[0].y == 0x25;
    ok &= s.records[0].vx == -16;
    ok &= s.records[0].vy == 0;
    ok &= s.records[0].first_frame == 0;
    ok &= s.records[0].last_frame == 3;
    ok &= s.records[8].x == 0x68;
    ok &= s.records[8].y == 0x2C;
    ok &= s.records[8].vx == -4;
    ok &= s.records[8].vy == 4;
    ok &= s.records[8].first_frame == 4;
    ok &= s.records[8].last_frame == 7;
    printf("opening_scene_sprite_a_summary: %s bytes=%llu records=%llu frames=%llu wait=%02x target=%04x\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.source_bytes_consumed,
           (unsigned long long)s.record_count,
           (unsigned long long)s.frame_count,
           s.frame_wait_al,
           s.dispatch_target);
    return ok;
}

static int run_scene_sprite_a_object_table_case(void) {
    uint8_t objects[9 * 15] = {0};
    size_t size = opening_debug_scene_sprite_a_object_table(objects,
                                                             sizeof(objects));
    uint64_t hash = fnv1a64(objects, sizeof(objects));
    int ok = size == sizeof(objects) && hash == 0xc21fe918b5101768ULL;
    printf("opening_scene_sprite_a_object_table: %s bytes=%llu fnv=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)size,
           (unsigned long long)hash);
    return ok;
}

static int run_scene_sprite_a_render_case(const char *name, int frame_index,
                                          uint64_t expected_fb,
                                          uint64_t expected_palette,
                                          int expected_nonzero,
                                          int expected_min_x,
                                          int expected_min_y,
                                          int expected_max_x,
                                          int expected_max_y) {
    opening_render_sprite_a_frame_for_test(frame_index);
    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    uint64_t palette = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
    int nonzero = framebuffer_nonzero_count();
    int min_x = 0, min_y = 0, max_x = 0, max_y = 0;
    framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);
    int ok = fb == expected_fb &&
             palette == expected_palette &&
             nonzero == expected_nonzero &&
             min_x == expected_min_x &&
             min_y == expected_min_y &&
             max_x == expected_max_x &&
             max_y == expected_max_y;
    printf("%s: %s framebuffer=%016llx palette=%016llx nonzero=%d bbox=(%d,%d,%d,%d)\n",
           name, ok ? "PASS" : "FAIL", (unsigned long long)fb,
           (unsigned long long)palette, nonzero, min_x, min_y, max_x, max_y);
    return ok;
}

static int read_file_bytes_at(const char *path, long offset,
                              uint8_t *out, size_t size) {
    FILE *f = fopen(path, "rb");
    if (!f)
        return 0;
    int ok = fseek(f, offset, SEEK_SET) == 0 &&
             fread(out, 1, size, f) == size;
    fclose(f);
    return ok;
}

static int run_scene_sprite_a_frame_table_case(void) {
    static const uint8_t expected_bytes[] = {
        0x00, 0x90, 0x20, 0x06, 0x80, 0x91, 0x20, 0x06,
        0x00, 0x93, 0x20, 0x06, 0x80, 0x94, 0x20, 0x06,
        0x00, 0x96, 0x18, 0x04, 0xC0, 0x96, 0x18, 0x04,
        0x80, 0x97, 0x18, 0x04, 0x40, 0x98, 0x18, 0x04,
    };
    static const uint16_t expected_ptrs[] = {
        0x9000, 0x9180, 0x9300, 0x9480, 0x9600, 0x96C0, 0x9780, 0x9840,
    };
    static const uint16_t expected_cx[] = {
        0x0620, 0x0620, 0x0620, 0x0620, 0x0418, 0x0418, 0x0418, 0x0418,
    };

    uint8_t bytes[sizeof(expected_bytes)] = {0};
    const char *paths[] = {
        "../../3_Assembly/masm/bin/zelres1/105GDMCA.bin",
        "3_Assembly/masm/bin/zelres1/105GDMCA.bin",
    };
    int read_ok = 0;
    for (size_t i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
        if (read_file_bytes_at(paths[i], 0x061B, bytes, sizeof(bytes))) {
            read_ok = 1;
            break;
        }
    }

    opening_sprite_a_frame_table_entry_t table[8];
    size_t table_count = opening_scene_sprite_a_frame_table(
        table, sizeof(table) / sizeof(table[0]));
    int ok = read_ok && table_count == 8 &&
             memcmp(bytes, expected_bytes, sizeof(expected_bytes)) == 0;
    for (size_t i = 0; i < 8; i++) {
        ok &= table[i].frame_ptr == expected_ptrs[i];
        ok &= table[i].cx == expected_cx[i];
    }
    printf("opening_scene_sprite_a_frame_table: %s count=%llu bin=%s first=%04x/%04x last=%04x/%04x\n",
           ok ? "PASS" : "FAIL", (unsigned long long)table_count,
           read_ok ? "read" : "missing",
           table[0].frame_ptr, table[0].cx,
           table[7].frame_ptr, table[7].cx);
    return ok;
}

static uint64_t hash_sprite_a_trace(const opening_sprite_a_frame_state_t *trace,
                                    size_t count) {
    uint8_t bytes[12 * (3 + 9 * 4)];
    size_t p = 0;
    for (size_t f = 0; f < count; f++) {
        bytes[p++] = (uint8_t)trace[f].frame_index;
        bytes[p++] = trace[f].active_count;
        bytes[p++] = trace[f].final_palette_cycle;
        for (size_t i = 0; i < 9; i++) {
            bytes[p++] = trace[f].objects[i].active;
            bytes[p++] = trace[f].objects[i].x;
            bytes[p++] = trace[f].objects[i].y;
            bytes[p++] = trace[f].objects[i].frame;
        }
    }
    return fnv1a64(bytes, p);
}

static int run_scene_sprite_a_full_frame_case(void) {
    static const uint64_t expected_fb[12] = {
        0xf9765efa9b86befaULL,
        0xdec807b6e4eb8879ULL,
        0xb792b25ad795d5d3ULL,
        0x02cf2b8cc960fff1ULL,
        0xb5b5e96654719f35ULL,
        0xc2018e1ad30db78cULL,
        0x8052ab097370a3a0ULL,
        0x0a6685aeb78b1e1dULL,
        0x89e518aea1045740ULL,
        0x56e3b4b21e7238b0ULL,
        0x7938bc13df3ab7edULL,
        0x76a5c68141189f10ULL,
    };
    static const uint64_t expected_palette[12] = {
        0x841c63875a757ce5ULL,
        0x886ccbdcc20d8ae5ULL,
        0x3898de1f9bd44db5ULL,
        0xc4e6a2333b015635ULL,
        0x4db573aeeb2a6421ULL,
        0x98e57c638ee326a1ULL,
        0xbffb21d87e8cec5dULL,
        0x79a88fc0fcd94f5dULL,
        0x841c63875a757ce5ULL,
        0x886ccbdcc20d8ae5ULL,
        0x3898de1f9bd44db5ULL,
        0xc4e6a2333b015635ULL,
    };
    static const int expected_nonzero[12] = {
        3125, 3431, 3531, 3944, 3944, 4176,
        3810, 3627, 3444, 3444, 3261, 2712,
    };
    static const int expected_bbox[12][4] = {
        {73, 34, 246, 146},
        {73, 34, 246, 149},
        {73, 34, 246, 155},
        {71, 24, 253, 160},
        {55, 8, 269, 166},
        {37, 34, 287, 174},
        {21, 34, 303, 158},
        {5, 34, 279, 162},
        {33, 34, 291, 166},
        {21, 34, 303, 170},
        {9, 34, 311, 174},
        {73, 34, 246, 128},
    };
    const uint64_t expected_trace_hash = 0x5f634151fa155c30ULL;

    opening_sprite_a_frame_state_t trace[12];
    size_t trace_count = opening_scene_sprite_a_frame_trace(
        trace, sizeof(trace) / sizeof(trace[0]));
    uint64_t trace_hash = hash_sprite_a_trace(trace, trace_count);
    int ok = trace_count == 12 && trace_hash == expected_trace_hash;

    printf("opening_scene_sprite_a_full_trace: %s frames=%llu hash=%016llx active=%u/%u/%u cycles=%u/%u/%u\n",
           ok ? "PASS" : "FAIL", (unsigned long long)trace_count,
           (unsigned long long)trace_hash,
           trace[0].active_count, trace[8].active_count, trace[11].active_count,
           trace[0].final_palette_cycle, trace[8].final_palette_cycle,
           trace[11].final_palette_cycle);
    for (int frame = 0; frame < 12; frame++) {
        opening_render_sprite_a_frame_for_test(frame);
        uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
        uint64_t palette = fnv1a64((const uint8_t *)g_palette, sizeof(g_palette));
        int nonzero = framebuffer_nonzero_count();
        int min_x = 0, min_y = 0, max_x = 0, max_y = 0;
        framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);
        int frame_ok = fb == expected_fb[frame] &&
                       palette == expected_palette[frame] &&
                       nonzero == expected_nonzero[frame] &&
                       min_x == expected_bbox[frame][0] &&
                       min_y == expected_bbox[frame][1] &&
                       max_x == expected_bbox[frame][2] &&
                       max_y == expected_bbox[frame][3];
        ok &= frame_ok;
        printf("opening_scene_sprite_a_full_frame_%02d: %s fb=%016llx pal=%016llx nonzero=%d bbox=(%d,%d,%d,%d) active=%u cycle=%u\n",
               frame, frame_ok ? "PASS" : "FAIL",
               (unsigned long long)fb, (unsigned long long)palette,
               nonzero, min_x, min_y, max_x, max_y,
               trace[frame].active_count, trace[frame].final_palette_cycle);
    }

    return ok;
}

static void blit_mcga_test_image(const uint8_t *image, int w, int h,
                                 uint16_t bx) {
    int x0 = ((bx >> 8) & 0xFF) * 4;
    int y0 = bx & 0xFF;

    framebuf_clear(0);
    for (int y = 0; y < h; y++) {
        int yy = y0 + y;
        if (yy < 0 || yy >= ZELIARD_HEIGHT)
            continue;
        for (int x = 0; x < w; x++) {
            int xx = x0 + x;
            if (xx < 0 || xx >= ZELIARD_WIDTH)
                continue;
            g_framebuf[yy * ZELIARD_WIDTH + xx] = image[y * w + x];
        }
    }
}

static void blit_mcga_disp_game_image(const uint8_t *image, int w, int h,
                                      uint16_t bx, uint16_t cx) {
    uint8_t clip = (uint8_t)((bx - 0x0410u) & 0xFFu);
    int top = clip;
    int height = cx & 0xFF;
    int width_groups = (cx >> 8) & 0xFF;
    int copy_w = width_groups * 4;
    int x0 = 16;
    int y0 = top + 16;

    framebuf_clear(0);
    for (int y = 0; y < height; y++) {
        int src_y = top + y;
        int dy = y0 + y;
        if (src_y < 0 || src_y >= h || dy < 0 || dy >= ZELIARD_HEIGHT)
            continue;
        for (int x = 0; x < copy_w; x++) {
            int src_x = x;
            int dx = x0 + x;
            if (src_x < 0 || src_x >= w || dx < 0 || dx >= ZELIARD_WIDTH)
                continue;
            g_framebuf[dy * ZELIARD_WIDTH + dx] =
                image[src_y * w + src_x];
        }
    }
}

static int framebuffer_nonzero_count(void) {
    int count = 0;
    for (size_t i = 0; i < ZELIARD_FB_SIZE; i++)
        count += g_framebuf[i] != 0;
    return count;
}

static void framebuffer_bbox(int *min_x, int *min_y, int *max_x, int *max_y) {
    *min_x = ZELIARD_WIDTH;
    *min_y = ZELIARD_HEIGHT;
    *max_x = -1;
    *max_y = -1;
    for (int y = 0; y < ZELIARD_HEIGHT; y++) {
        for (int x = 0; x < ZELIARD_WIDTH; x++) {
            if (!g_framebuf[y * ZELIARD_WIDTH + x])
                continue;
            if (x < *min_x) *min_x = x;
            if (y < *min_y) *min_y = y;
            if (x > *max_x) *max_x = x;
            if (y > *max_y) *max_y = y;
        }
    }
}

typedef struct {
    const char *name;
    const char *asset;
    int rows;
    int cl;
    uint8_t masm_ax;
    uint64_t expected_fb;
    int expected_nonzero;
    int expected_min_x;
    int expected_min_y;
    int expected_max_x;
    int expected_max_y;
} mcga_asset_oracle_case_t;

static int run_mcga_render_asset_oracle_case(
    const mcga_asset_oracle_case_t *tc) {
    size_t file_size = 0;
    uint8_t *file_data = platform_load_asset(tc->asset, &file_size);
    if (!file_data) {
        printf("%s: FAIL asset unavailable\n", tc->name);
        return 0;
    }

    size_t payload_size = 0;
    uint8_t *payload = fill_buffer_decompress(file_data, file_size,
                                              &payload_size);
    free(file_data);
    if (!payload) {
        printf("%s: FAIL fill_buffer failed\n", tc->name);
        return 0;
    }

    size_t planes_size = 0;
    uint8_t *planes = img_open_decode(payload, payload_size, tc->rows, tc->cl,
                                      &planes_size);
    free(payload);
    if (!planes) {
        printf("%s: FAIL img_open failed\n", tc->name);
        return 0;
    }

    uint8_t seg[0x10000] = {0};
    const int base = 0x4000;
    size_t copy_size = planes_size;
    if (copy_size > sizeof(seg) - (size_t)base)
        copy_size = sizeof(seg) - (size_t)base;
    memcpy(seg + base, planes, copy_size);
    free(planes);
    int w = 0;
    int h = 0;
    uint8_t *image = zeliard_mcga_render_three_plane_ab(
        seg, base, tc->rows * tc->cl, tc->rows, tc->cl, &w, &h);
    if (!image) {
        printf("%s: FAIL three-plane render failed\n", tc->name);
        return 0;
    }

    uint16_t cx = (uint16_t)((tc->rows << 8) | tc->cl);
    blit_mcga_disp_game_image(image, w, h, 0x0410, cx);
    free(image);

    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int nonzero = framebuffer_nonzero_count();
    int min_x, min_y, max_x, max_y;
    framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);
    int ok = fb == tc->expected_fb &&
             nonzero == tc->expected_nonzero &&
             min_x == tc->expected_min_x &&
             min_y == tc->expected_min_y &&
             max_x == tc->expected_max_x &&
             max_y == tc->expected_max_y;
    printf("%s: %s masm_ax=%02x framebuffer=%016llx nonzero=%d bbox=(%d,%d,%d,%d)\n",
           tc->name, ok ? "PASS" : "FAIL", tc->masm_ax,
           (unsigned long long)fb, nonzero, min_x, min_y, max_x, max_y);
    return ok;
}

static int run_mcga_render_asset_oracles_case(void) {
    static const mcga_asset_oracle_case_t cases[] = {
        {"mcga_hime_disp_game_al09", "hime.grp", 0x48, 0x68, 0x09,
         0xacf935f65da3df18ULL, 29952, 16, 16, 303, 119},
        {"mcga_hime_disp_game_al06", "hime.grp", 0x48, 0x68, 0x06,
         0xacf935f65da3df18ULL, 29952, 16, 16, 303, 119},
        {"mcga_isi_disp_game_al07", "isi.grp", 0x48, 0x68, 0x07,
         0x289821951f6f5ddeULL, 10551, 16, 16, 303, 119},
        {"mcga_sei_disp_game_al05", "sei.grp", 0x24, 0x68, 0x05,
         0x5d95614779039634ULL, 9524, 16, 16, 159, 117},
        {"mcga_yuu1_disp_game_al07", "yuu1.grp", 0x48, 0x68, 0x07,
         0x6c3fdfd6ae025e9fULL, 18564, 16, 16, 303, 119},
        {"mcga_ame_disp_game_al00", "ame.grp", 0x48, 0x68, 0x00,
         0xa01eebd621d68a49ULL, 24663, 16, 16, 303, 119},
        {"mcga_ame_disp_game_al09", "ame.grp", 0x48, 0x68, 0x09,
         0xa01eebd621d68a49ULL, 24663, 16, 16, 303, 119},
        {"mcga_ame_disp_game_alaa", "ame.grp", 0x48, 0x68, 0xAA,
         0xa01eebd621d68a49ULL, 24663, 16, 16, 303, 119},
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++)
        ok &= run_mcga_render_asset_oracle_case(&cases[i]);
    return ok;
}

static uint8_t *load_img_open_planes_for_test(const char *asset, int rows,
                                              int cl, size_t *out_size) {
    size_t file_size = 0;
    uint8_t *file_data = platform_load_asset(asset, &file_size);
    if (!file_data) {
        *out_size = 0;
        return NULL;
    }

    size_t payload_size = 0;
    uint8_t *payload = fill_buffer_decompress(file_data, file_size,
                                              &payload_size);
    free(file_data);
    if (!payload) {
        *out_size = 0;
        return NULL;
    }

    uint8_t *planes = img_open_decode(payload, payload_size, rows, cl,
                                      out_size);
    free(payload);
    return planes;
}

typedef struct {
    const char *name;
    const char *asset;
    int rows;
    int cl;
    uint8_t expected_return_al;
    size_t expected_size;
} img_open_return_al_case_t;

static int run_img_open_return_al_oracle_case(
    const img_open_return_al_case_t *tc) {
    size_t planes_size = 0;
    uint8_t *planes = load_img_open_planes_for_test(tc->asset, tc->rows,
                                                    tc->cl, &planes_size);
    if (!planes) {
        printf("%s: FAIL asset decode failed\n", tc->name);
        return 0;
    }

    uint8_t return_al = planes_size ? planes[planes_size - 1] : 0;
    int ok = return_al == tc->expected_return_al &&
             planes_size == tc->expected_size;
    printf("%s: %s return_al=%02x size=%llu\n",
           tc->name, ok ? "PASS" : "FAIL", return_al,
           (unsigned long long)planes_size);
    free(planes);
    return ok;
}

static int run_img_open_return_al_oracles_case(void) {
    static const img_open_return_al_case_t cases[] = {
        {"img_open_waku_return_al", "waku.grp", 0x50, 0x88, 0xFE, 32640},
        {"img_open_ame_return_al", "ame.grp", 0x48, 0x68, 0xAA, 22528},
        {"img_open_hime_return_al", "hime.grp", 0x48, 0x68, 0xAA, 22528},
        {"img_open_isi_return_al", "isi.grp", 0x48, 0x68, 0xAA, 22528},
        {"img_open_sei_return_al", "sei.grp", 0x24, 0x68, 0xAA, 7680},
        {"img_open_yuu1_return_al", "yuu1.grp", 0x48, 0x68, 0x00, 22504},
    };

    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++)
        ok &= run_img_open_return_al_oracle_case(&cases[i]);
    return ok;
}

typedef struct {
    const char *name;
    uint16_t di;
    uint16_t bx;
    uint16_t cx;
    uint64_t expected_fb;
    int expected_nonzero;
    int expected_min_x;
    int expected_min_y;
    int expected_max_x;
    int expected_max_y;
} mcga_yuu_rect_oracle_case_t;

static int run_mcga_yuu_rect_oracle_case(
    const mcga_yuu_rect_oracle_case_t *tc) {
    uint8_t seg[0x10000] = {0};

    size_t yuup_size = 0;
    uint8_t *yuup = load_img_open_planes_for_test("yuup.grp", 0x3A, 0x80,
                                                 &yuup_size);
    size_t oup_size = 0;
    uint8_t *oup = load_img_open_planes_for_test("oup.grp", 0x3F, 0x80,
                                                &oup_size);
    if (!yuup || !oup) {
        free(yuup);
        free(oup);
        printf("%s: FAIL asset decode failed\n", tc->name);
        return 0;
    }
    memcpy(seg + 0x4000, yuup, yuup_size);
    memcpy(seg + 0x8000, oup, oup_size);
    free(yuup);
    free(oup);

    int rows = (tc->cx >> 8) & 0xFF;
    int cl = tc->cx & 0xFF;
    int bp = rows * cl;
    int w = 0;
    int h = 0;
    uint8_t *image = zeliard_mcga_render_three_plane_ab(
        seg, tc->di, bp, rows, cl, &w, &h);
    if (!image) {
        printf("%s: FAIL render failed\n", tc->name);
        return 0;
    }

    int dx = ((tc->bx >> 8) & 0xFF) * 4;
    int dy = tc->bx & 0xFF;
    blit_mcga_test_image(image, w, h, (uint16_t)((dx / 4) << 8 | dy));
    free(image);

    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int nonzero = framebuffer_nonzero_count();
    int min_x, min_y, max_x, max_y;
    framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);
    int ok = fb == tc->expected_fb &&
             nonzero == tc->expected_nonzero &&
             min_x == tc->expected_min_x &&
             min_y == tc->expected_min_y &&
             max_x == tc->expected_max_x &&
             max_y == tc->expected_max_y;
    printf("%s: %s framebuffer=%016llx nonzero=%d bbox=(%d,%d,%d,%d)\n",
           tc->name, ok ? "PASS" : "FAIL", (unsigned long long)fb,
           nonzero, min_x, min_y, max_x, max_y);
    return ok;
}

static int run_mcga_yuu_rect_oracles_case(void) {
    static const mcga_yuu_rect_oracle_case_t cases[] = {
        {"mcga_yuu_split_left_rect", 0x4000, 0x0B18, 0x1858,
         0xe95599ea7d6b89edULL, 8448, 44, 24, 139, 111},
        {"mcga_yuu_split_right_rect", 0x8000, 0x2D18, 0x1858,
         0x54c8bc1f7562731fULL, 8448, 180, 24, 275, 111},
        {"mcga_yuu_portrait_sm0_rect", 0x98C0, 0x3350, 0x0E20,
         0x09006cc563c60c0fULL, 1792, 204, 80, 259, 111},
        {"mcga_yuu_portrait_sm6_rect", 0xB840, 0x3338, 0x0B10,
         0x9f51f3c7c05b4b1aULL, 704, 204, 56, 247, 71},
        {"mcga_yuu_portrait_lg0_rect", 0x58C0, 0x1350, 0x0920,
         0xf64f78e9a3a0de52ULL, 1152, 76, 80, 111, 111},
        {"mcga_yuu_portrait_lg6_rect", 0x6D00, 0x1238, 0x0B10,
         0x8cc3b7242ac94c75ULL, 704, 72, 56, 115, 71},
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++)
        ok &= run_mcga_yuu_rect_oracle_case(&cases[i]);
    return ok;
}

static int run_mcga_render_entry_oracle_case(void) {
    enum {
        SRC_DI = 0x4000,
        BX = 0x0410,
        ROWS = 0x08,
        CL = 0x10,
        BP = ROWS * CL,
        SOURCE_BYTES = BP * 3
    };
    uint8_t seg[0x10000] = {0};
    for (int i = 0; i < SOURCE_BYTES; i++)
        seg[SRC_DI + i] = (uint8_t)(((i * 37) ^ (i >> 1) ^ 0x5A) & 0xFF);

    int w = 0;
    int h = 0;
    uint8_t *image = zeliard_mcga_render_three_plane_ab(seg, SRC_DI, BP,
                                                        ROWS, CL, &w, &h);
    if (!image) {
        printf("mcga_render_entry_oracle: FAIL render failed\n");
        return 0;
    }

    blit_mcga_test_image(image, w, h, BX);
    free(image);

    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    int nonzero = framebuffer_nonzero_count();
    int min_x, min_y, max_x, max_y;
    framebuffer_bbox(&min_x, &min_y, &max_x, &max_y);
    int ok = w == 32 &&
             h == 16 &&
             fb == 0x4d9cd38e12f64a4dULL &&
             nonzero == 416 &&
             min_x == 16 &&
             min_y == 16 &&
             max_x == 47 &&
             max_y == 31;
    printf("mcga_render_entry_oracle: %s w=%d h=%d framebuffer=%016llx nonzero=%d bbox=(%d,%d,%d,%d)\n",
           ok ? "PASS" : "FAIL", w, h, (unsigned long long)fb,
           nonzero, min_x, min_y, max_x, max_y);
    return ok;
}

static int run_scanline_summary_case(void) {
    opening_scanline_summary_t s = opening_scanline_summary();
    int ok = s.entry_count == 31 &&
             s.entry_draw_count == 310 &&
             s.exit_draw_count == 120 &&
             s.total_draw_count == 430 &&
             s.exit_draw_al == 0 &&
             s.wait_al == 0x1C &&
             s.bx == 0x0020 &&
             s.cx == 0x5078;
    for (int i = 0; i < 10; i++)
        ok &= s.entry_draw_al[i] == i;
    printf("opening_scanline_summary: %s entries=%llu draws=%llu+%llu wait=%02x\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.entry_count,
           (unsigned long long)s.entry_draw_count,
           (unsigned long long)s.exit_draw_count,
           s.wait_al);
    return ok;
}

static int run_exact_story_script_case(const char *asset, size_t expected_size,
                                       uint64_t expected_fnv, size_t expected_wait10,
                                       size_t expected_pause, size_t expected_clear,
                                       size_t expected_glyphs) {
    size_t size = 0;
    u8 *script = platform_load_asset(asset, &size);
    if (!script) {
        printf("%s: FAIL asset unavailable\n", asset);
        return 0;
    }

    u8 widths[96];
    u8 advances[96];
    fill_script_metrics(widths, advances, 8);
    zeliard_opening_script_state_t s;
    zeliard_opening_script_init(&s, 0);
    zeliard_script_stop_t stop =
        zeliard_opening_script_run(&s, script, size, widths, advances, size + 1);
    uint64_t hash = fnv1a64(script, size);
    u32 timer_ticks = zeliard_opening_script_timer_ticks(script, size);
    free(script);

    int ok = 1;
    ok &= size == expected_size;
    ok &= hash == expected_fnv;
    ok &= stop == ZELIARD_SCRIPT_STOP_BREAK || stop == ZELIARD_SCRIPT_STOP_END;
    ok &= s.pc == size;
    ok &= s.wait_10_count == expected_wait10;
    ok &= s.pause_f0_count == expected_pause;
    ok &= timer_ticks == expected_wait10 * 0x10u + expected_pause * 0xF0u;
    ok &= s.clear_count == expected_clear;
    ok &= s.glyph_count == expected_glyphs;
    ok &= s.draw_call_count == expected_glyphs * 2;
    printf("%s: %s bytes=%llu wait=%llu pause=%llu ticks=%u clear=%llu glyphs=%llu\n",
           asset, ok ? "PASS" : "FAIL",
           (unsigned long long)size,
           (unsigned long long)s.wait_10_count,
           (unsigned long long)s.pause_f0_count,
           timer_ticks,
           (unsigned long long)s.clear_count,
           (unsigned long long)s.glyph_count);
    return ok;
}

static int run_first_story_first_draw_case(void) {
    size_t size = 0;
    u8 *script = platform_load_asset("opdemo_story_script_1.bin", &size);
    if (!script) {
        printf("opdemo_story_script_1_first_draw: FAIL asset unavailable\n");
        return 0;
    }

    u8 widths[96];
    u8 advances[96];
    fill_opdmo_script_metrics(widths, advances);
    zeliard_opening_script_state_t s;
    zeliard_opening_script_init(&s, 0);
    zeliard_script_stop_t first_stop =
        zeliard_opening_script_run(&s, script, size, widths, advances, 1);
    int first_ok = first_stop == ZELIARD_SCRIPT_STOP_LIMIT &&
                   s.pc == 1 &&
                   s.wait_10_count == 1 &&
                   s.glyph_count == 1 &&
                   s.draw_call_count == 2 &&
                   s.last_char == 'P' &&
                   s.last_draw_x == 4 &&
                   s.last_draw_y == 0x8F &&
                   s.text_x_pos == 8;

    zeliard_opening_script_init(&s, 0);
    zeliard_script_stop_t stop =
        zeliard_opening_script_run(&s, script, size, widths, advances, 6);
    free(script);

    int ok = 1;
    ok &= first_ok;
    ok &= stop == ZELIARD_SCRIPT_STOP_LIMIT;
    ok &= s.pc == 6;
    ok &= s.wait_10_count == 6;
    ok &= s.glyph_count == 2;
    ok &= s.draw_call_count == 4;
    ok &= s.last_char == 'O';
    ok &= s.last_draw_x == 4;
    ok &= s.last_draw_y == 0x99;
    ok &= s.text_x_pos == 8;
    printf("opdemo_story_script_1_first_draw: %s char=%02x x=%u y=%u next_x=%u\n",
           ok ? "PASS" : "FAIL", s.last_char, s.last_draw_x,
           s.last_draw_y, s.text_x_pos);
    return ok;
}

static int run_credits_summary_case(void) {
    opening_scanline_summary_t s = opening_credits_summary();
    int ok = s.entry_count == 52 &&
             s.entry_draw_count == 520 &&
             s.exit_draw_count == 120 &&
             s.total_draw_count == 640 &&
             s.exit_draw_al == 0 &&
             s.wait_al == 0x1C &&
             s.bx == 0x0020 &&
             s.cx == 0x5078;
    for (int i = 0; i < 10; i++)
        ok &= s.entry_draw_al[i] == i;
    printf("opening_credits_summary: %s entries=%llu draws=%llu+%llu wait=%02x\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.entry_count,
           (unsigned long long)s.entry_draw_count,
           (unsigned long long)s.exit_draw_count,
           s.wait_al);
    return ok;
}

static int run_credits_scanline_runtime_completion_case(void) {
    const uint32_t elapsed_ms = OPDMO_TEST_WAIT_MS(
        8 * 0x14 + (52 * 10 + 120 - 1) * 0x1C);
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_STAFF_CREDITS, elapsed_ms);
    opening_scanline_runtime_summary_t s =
        opening_credits_scanline_runtime_summary();
    int ok = s.rendered_draws == 640 && s.exit_frame == 0x78 &&
             s.finished == 1 &&
             s.visible_hash == 0xDD14FCC6528CAB25ULL &&
             s.work_hash == 0xD6C423A74583C8E0ULL;
    printf("credits_scanline_runtime_completion: %s draws=%llu stream=%llu exit=%u "
           "finished=%u visible=%016llx work=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)s.rendered_draws,
           (unsigned long long)s.stream_pos, s.exit_frame, s.finished,
           (unsigned long long)s.visible_hash, (unsigned long long)s.work_hash);
    return ok;
}

static int run_credits_first_two_records_mcga_oracle_case(void) {
    static const uint64_t expected_visible[20] = {
        0xDD14FCC6528CAB25ULL, 0x8ED187DBCE325DE5ULL,
        0xAA89D2C673E1D5F5ULL, 0xD39904DC673281E3ULL,
        0xE7AD1871E6F07705ULL, 0xDF32DD85341A3283ULL,
        0x5490C643A8E61F23ULL, 0xFD082378D7EBDBF5ULL,
        0x2BE85E085AAB6833ULL, 0x5B9B26AB19E52E33ULL,
        0x227C7FA8847CF433ULL, 0xE6D2607FE9F73895ULL,
        0xA09CA3EC4A3B2FF5ULL, 0x4599526D6152E4D3ULL,
        0xD0314AD8E0FDA975ULL, 0xB1D9D1AC98F9F645ULL,
        0x8741B15435518F63ULL, 0xDEFC1C2BF57895B5ULL,
        0xF57FC27ACE0965B5ULL, 0x00E1AF4E66AA35B5ULL,
    };
    static const uint64_t expected_work[20] = {
        0xEAA64BA4798DE35FULL, 0xEC196A3C6381710BULL,
        0x9C180A02A651E692ULL, 0xD87A68999DD94BBDULL,
        0xEF6FD6E5B8530874ULL, 0x1F5DB548A6E3C4A0ULL,
        0x8AE1B4E0A15995F9ULL, 0x7CEAD5602081DFC8ULL,
        0x0C8CCA4828064EC8ULL, 0x5D9D1B8D1FF5BDC8ULL,
        0xC68A2E759A01C007ULL, 0x359C33546C31F279ULL,
        0x8191A96368EE451CULL, 0x24663034F9415A87ULL,
        0xAEB577AF2D275F31ULL, 0xE4A83A99EA068036ULL,
        0x8C89B84345D482A5ULL, 0xFD52A86D10D202A5ULL,
        0x41A3A6056F4F82A5ULL, 0x1648880DE14D02A5ULL,
    };
    int ok = 1;

    opening_init();
    for (int frame = 0; frame < 20; frame++) {
        opening_render_phase_for_test(
            OPENING_PHASE_STAFF_CREDITS,
            OPDMO_TEST_WAIT_MS((uint32_t)frame * 0x1C));
        opening_scanline_runtime_summary_t s =
            opening_credits_scanline_runtime_summary();
        int frame_ok = s.rendered_draws == (uint64_t)frame + 1 &&
                       s.visible_hash == expected_visible[frame] &&
                       s.work_hash == expected_work[frame];
        ok &= frame_ok;
        printf("credits_mcga_record_0_frame_%02d: %s visible=%016llx work=%016llx\n",
               frame, frame_ok ? "PASS" : "FAIL",
               (unsigned long long)s.visible_hash,
               (unsigned long long)s.work_hash);
    }
    for (int frame = 20; frame < 140; frame++) {
        opening_render_phase_for_test(
            OPENING_PHASE_STAFF_CREDITS,
            OPDMO_TEST_WAIT_MS((uint32_t)frame * 0x1C));
    }
    {
        opening_scanline_runtime_summary_t s =
            opening_credits_scanline_runtime_summary();
        int checkpoint_ok = s.rendered_draws == 140 &&
                            s.visible_hash == 0xE9B957AA11F8ECB3ULL &&
                            s.work_hash == 0x3BBA3D5D2B6FC1B8ULL;
        ok &= checkpoint_ok;
        printf("credits_mcga_record_13_frame_09: %s visible=%016llx work=%016llx\n",
               checkpoint_ok ? "PASS" : "FAIL",
               (unsigned long long)s.visible_hash,
               (unsigned long long)s.work_hash);
    }
    for (int frame = 140; frame < 270; frame++) {
        opening_render_phase_for_test(
            OPENING_PHASE_STAFF_CREDITS,
            OPDMO_TEST_WAIT_MS((uint32_t)frame * 0x1C));
    }
    {
        opening_scanline_runtime_summary_t s =
            opening_credits_scanline_runtime_summary();
        int checkpoint_ok = s.rendered_draws == 270 &&
                            s.visible_hash == 0x7EC968257BB31D13ULL &&
                            s.work_hash == 0x8AE7AB4BB782BCAEULL;
        ok &= checkpoint_ok;
        printf("credits_mcga_record_26_frame_09: %s visible=%016llx work=%016llx\n",
               checkpoint_ok ? "PASS" : "FAIL",
               (unsigned long long)s.visible_hash,
               (unsigned long long)s.work_hash);
    }
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
    ok &= s.final_render_state_a == 0x0130;
    ok &= s.final_render_state_b == 0xA8;
    ok &= s.final_volume_b == 0x3F;
    printf("opening_scene_sprite_b_summary: %s bytes=%llu chap2=%llu glyphs=%llu waits=%llu state=%04x/%02x volume=%02x\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.script_bytes_consumed,
           (unsigned long long)s.chapter2_call_count,
           (unsigned long long)s.glyph_count,
           (unsigned long long)s.script_wait_count,
           s.final_render_state_a, s.final_render_state_b, s.final_volume_b);
    return ok;
}

static int run_gmmcga_render_text_char_alt_case(void) {
    static const uint8_t glyph[8] = {
        0xA5, 0x3C, 0x81, 0x42, 0x18, 0xE7, 0x00, 0x7E,
    };
    static const uint64_t expected_hash[2] = {
        0x09E8C98B7168FE2DULL, 0xFFD7FB96FC8CEDE3ULL,
    };
    uint8_t font_data[0x188];
    uint8_t vga[0x10000];
    zeliard_font_t font;
    int ok = 1;

    memset(font_data, 0, sizeof(font_data));
    memcpy(font_data + 0x180, glyph, sizeof(glyph));
    memset(&font, 0, sizeof(font));
    font.data = font_data;
    font.size = sizeof(font_data);
    font.ptr_a = 0;

    for (int selector = 2, test_index = 0; selector <= 7;
         selector += 5, test_index++) {
        framebuf_clear(0);
        zeliard_font_draw_mcga_alt_char(&font, 4, 0x8F, 'P',
                                        (uint8_t)selector, 1);
        memset(vga, 0, sizeof(vga));
        memcpy(vga, g_framebuf, ZELIARD_FB_SIZE);
        uint64_t hash = fnv1a64(vga, sizeof(vga));
        uint8_t pixel = g_framebuf[0x8F * ZELIARD_WIDTH + 4];
        int case_ok = hash == expected_hash[test_index] &&
                      pixel == (uint8_t)(selector * 0x11);
        ok &= case_ok;
        printf("gmmcga_render_text_char_alt_%d: %s vga=%016llx pixel=%02x\n",
               selector, case_ok ? "PASS" : "FAIL",
               (unsigned long long)hash, pixel);
    }
    return ok;
}

static int run_gmmcga_narration_stream_case(void) {
    static const uint8_t glyph[8] = {
        0xA5, 0x3C, 0x81, 0x42, 0x18, 0xE7, 0x00, 0x7E,
    };
    static const uint8_t stream[] = {'A', 0x82, 'B', 0x0d, 'C', 0xff};
    uint8_t font_data[0x188];
    uint8_t vga[0x10000];
    zeliard_font_t font;
    memset(font_data, 0, sizeof(font_data));
    for (uint8_t ch = 'A'; ch <= 'C'; ch++)
        memcpy(font_data + (ch - 0x20u) * 8u, glyph, sizeof(glyph));
    memset(&font, 0, sizeof(font));
    font.data = font_data;
    font.size = sizeof(font_data);
    framebuf_clear(0);
    zeliard_font_draw_mcga_narration_stream(&font, 4, 0x8f, stream,
                                             sizeof(stream), 1);
    memset(vga, 0, sizeof(vga));
    memcpy(vga, g_framebuf, ZELIARD_FB_SIZE);
    uint64_t hash = fnv1a64(vga, sizeof(vga));
    int ok = hash == 0x82CF53E05B4BA4F3ULL;
    printf("gmmcga_narration_stream: %s vga=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)hash);
    return ok;
}

static int run_gmmcga_jashiin_speech_clear_case(void) {
    uint8_t vga[0x10000];
    for (size_t index = 0; index < sizeof(vga); index++)
        vga[index] = (uint8_t)((index * 17u + 3u) & 0xffu);
    int rc = zeliard_gmmcga_jashiin_speech_clear(vga, sizeof(vga),
                                                  0, 0x0094, 0x501e);
    uint64_t hash = fnv1a64(vga, sizeof(vga));
    int ok = rc == 0 && hash == 0x9A550041FF6558A5ULL;
    printf("gmmcga_jashiin_speech_clear: %s vga=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned long long)hash);
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
    ok &= s.disp_sprite_slot == 0x301E;
    ok &= s.disp_sprite_target == 0x37B4;
    ok &= s.disp_sprite_writes_palette == 0;
    ok &= s.disp_sprite_object_count == 9;
    ok &= s.disp_sprite_record_size == 0x0F;
    ok &= s.disp_sprite_scratch_size == 0x44;
    ok &= s.disp_sprite_source_stride == 0x22;
    ok &= s.disp_sprite_row_count == 0x11;
    ok &= s.wait_count == 100;
    ok &= s.wait_al == 0x50;
    for (size_t i = 0; i < 6; i++) {
        ok &= s.first_disp_set_al[i] == expected_first[i];
        ok &= s.final_disp_set_al[i] == expected_final[i];
    }
    ok &= s.interrupt_cascade_count == 1;
    ok &= s.stick_handler_call_count == 4;
    ok &= s.exits_to_game == 1;
    printf("opening_title_color_exit: %s iterations=%llu disp_set=%llu sprite=%04x->%04x objs=%u stride=%02x rows=%u wait=%02x exit=%u\n",
           ok ? "PASS" : "FAIL",
           (unsigned long long)s.iterations,
           (unsigned long long)s.disp_set_call_count,
           s.disp_sprite_slot, s.disp_sprite_target,
           s.disp_sprite_object_count, s.disp_sprite_source_stride,
           s.disp_sprite_row_count,
           s.wait_al, s.exits_to_game);
    return ok;
}

static int run_title_handoff_repeated_tick_case(void) {
    const uint32_t color_start_ms =
        OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 +
                           16 * 0x14 + 0xF0);
    opening_init();
    opening_render_phase_for_test(OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,
                                  color_start_ms);
    for (uint32_t i = 1; i <= 100; i++) {
        opening_render_phase_for_test(
            OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION,
            color_start_ms + OPDMO_TEST_WAIT_MS(i * 0x50));
    }

    uint64_t fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    size_t nz = nonzero_count(g_framebuf, ZELIARD_FB_SIZE);
    int ok = fb == 0xbd2123d05705e410ULL && nz == 41239;
    printf("title_handoff_repeated_tick: %s framebuffer=%016llx nonzero=%llu\n",
           ok ? "PASS" : "FAIL", (unsigned long long)fb,
           (unsigned long long)nz);
    return ok;
}

static int run_title_handoff_incremental_scheduler_case(void) {
    const uint32_t color_done_ms =
        OPDMO_TEST_WAIT_MS(8 * 0x14 + 0xF0 + 16 * 0x14 + 0xF0 +
                           16 * 0x14 + 0xF0 + 100 * 0x50);
    opening_init();

    int guard = 0;
    while (opening_phase_id() != OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION &&
           guard++ < 1000)
        opening_tick(250);
    while (opening_phase_id() == OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION &&
           opening_phase_elapsed_ms() < color_done_ms + 250 &&
           guard++ < 3000)
        opening_tick(50);

    uint64_t color_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    size_t color_nz = nonzero_count(g_framebuf, ZELIARD_FB_SIZE);
    uint32_t first_hold_mismatch_ms = 0;
    while (opening_phase_id() == OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION &&
           opening_phase_elapsed_ms() < 120000 &&
           guard++ < 4000) {
        opening_tick(250);
        if (!first_hold_mismatch_ms &&
            nonzero_count(g_framebuf, ZELIARD_FB_SIZE) != color_nz)
            first_hold_mismatch_ms = opening_phase_elapsed_ms();
    }
    uint64_t hold_fb = fnv1a64(g_framebuf, ZELIARD_FB_SIZE);
    size_t hold_nz = nonzero_count(g_framebuf, ZELIARD_FB_SIZE);
    int ok = opening_phase_id() == OPENING_PHASE_TITLE_LOGO_COLOR_ROTATION &&
             color_fb == 0xbd2123d05705e410ULL && color_nz == 41239 &&
             hold_fb == color_fb && hold_nz == color_nz;
    printf("title_handoff_incremental_scheduler: %s phase=%d elapsed=%u first_mismatch=%u color=%016llx/%llu hold=%016llx/%llu\n",
           ok ? "PASS" : "FAIL", opening_phase_id(),
           opening_phase_elapsed_ms(), first_hold_mismatch_ms,
           (unsigned long long)color_fb,
           (unsigned long long)color_nz, (unsigned long long)hold_fb,
           (unsigned long long)hold_nz);
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
    printf("opening_next_scene: %s mode=%02x sar=%s palette=%u credits=%llu\n",
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

static int run_mcga_render_ab_gseg_case(void) {
    uint8_t game[0x10000] = {0};
    uint8_t work[0x10000] = {0};
    uint8_t vga[0x10000];
    int ok = 1;
    for (size_t i = 0; i < 0x480u * 4u; i++)
        game[0x97C0u + i] = (uint8_t)((i * 37u + 11u) & 0xFFu);
    for (size_t i = 0; i < sizeof(vga); i++)
        vga[i] = (uint8_t)((i * 19u + 7u) & 0xFFu);

    static const uint64_t expected_work[4] = {
        0xea54490a87acb88aULL, 0xb87ad8b93a57264aULL,
        0xea54490a87acb88aULL, 0xb87ad8b93a57264aULL,
    };
    static const uint64_t expected_vga[4] = {
        0xb4f706efef059ad2ULL, 0xd0cd568d834e7852ULL,
        0xb4f706efef059ad2ULL, 0xd0cd568d834e7852ULL,
    };
    for (uint8_t page = 0; page < 4; page++) {
        memset(work, 0, sizeof(work));
        for (size_t i = 0; i < sizeof(vga); i++)
            vga[i] = (uint8_t)((i * 19u + 7u) & 0xFFu);
        ok &= zeliard_mcga_disp_render_ab_gseg(game, sizeof(game), work,
                                               sizeof(work), page, 0, vga,
                                               sizeof(vga)) == 0;
        ok &= fnv1a64(work, sizeof(work)) == expected_work[page];
        ok &= fnv1a64(vga, sizeof(vga)) == expected_vga[page];
    }
    printf("mcga_disp_render_ab_gseg: %s pages=4 bx=0000\n",
           ok ? "PASS" : "FAIL");
    return ok;
}

static int run_mcga_render_ab_ab40_case(void) {
    uint8_t game[0x10000] = {0};
    uint8_t work[0x10000] = {0};
    uint8_t vga[0x10000];
    static const uint64_t expected_work[5] = {
        0x7a54e6f497d6e940ULL, 0x049b72555a9f1598ULL,
        0x1f645ffbcc732120ULL, 0x9582ade0b3c3edd8ULL,
        0x7a54e6f497d6e940ULL,
    };
    static const uint64_t expected_vga[5] = {
        0xdc34bd70d74ef260ULL, 0x1b7024e43dadfe28ULL,
        0x502d12c6680ebd80ULL, 0x3ab55aad4c798d48ULL,
        0xdc34bd70d74ef260ULL,
    };
    int ok = 1;

    for (size_t i = 0; i < 0x0cc0u * 5u; i++)
        game[0xab40u + i] = (uint8_t)((i * 29u + 0x53u) & 0xffu);
    for (uint8_t page = 0; page < 5; page++) {
        memset(work, 0, sizeof(work));
        for (size_t i = 0; i < sizeof(vga); i++)
            vga[i] = (uint8_t)((i * 13u + 0x31u) & 0xffu);
        ok &= zeliard_mcga_disp_render_ab_ab40(game, sizeof(game), work,
                                               sizeof(work), page, 0, vga,
                                               sizeof(vga)) == 0;
        ok &= fnv1a64(work, sizeof(work)) == expected_work[page];
        ok &= fnv1a64(vga, sizeof(vga)) == expected_vga[page];
    }
    static const uint64_t expected_opening_vga[2] = {
        0x3ec8fb9dae26aa6cULL, 0x8c57ccf6305fa3a4ULL,
    };
    for (uint8_t page = 2; page <= 3; page++) {
        memset(work, 0, sizeof(work));
        for (size_t i = 0; i < sizeof(vga); i++)
            vga[i] = (uint8_t)((i * 13u + 0x31u) & 0xffu);
        ok &= zeliard_mcga_disp_render_ab_ab40(
            game, sizeof(game), work, sizeof(work), page, 0x1720,
            vga, sizeof(vga)) == 0;
        ok &= fnv1a64(work, sizeof(work)) == expected_work[page];
        ok &= fnv1a64(vga, sizeof(vga)) == expected_opening_vga[page - 2];
    }
    printf("mcga_disp_render_ab_ab40: %s pages=5 BX=0000 pages=2,3 BX=1720\n",
           ok ? "PASS" : "FAIL");
    return ok;
}

static int run_mcga_disp_script_area_case(void) {
    enum { SOURCE_DI = 0x8000, PLANE_BYTES = 0x1028 };
    uint8_t *planes = NULL;
    uint8_t *seg = NULL;
    uint8_t *image = NULL;
    uint8_t vga[0x10000];
    size_t planes_size = 0;
    int w = 0, h = 0;
    int ok = 0;

    planes = decode_opening_planes_asset("maop.grp", 0x30, 0x5d,
                                         &planes_size, NULL);
    seg = (uint8_t *)calloc(0x10000, 1);
    if (!planes || !seg || planes_size > 0x8000u)
        goto done;
    memcpy(seg + SOURCE_DI, planes, planes_size);

    /* 105GDMCA:3E35's 1028h-byte three-plane pixel sort. */
    for (uint16_t i = 0; i < PLANE_BYTES; i++) {
        uint8_t *a = &seg[SOURCE_DI + i];
        uint8_t *b = &seg[SOURCE_DI + PLANE_BYTES + i];
        uint8_t *c = &seg[SOURCE_DI + 2 * PLANE_BYTES + i];
        uint8_t keep = (uint8_t)~(*a & *b & (uint8_t)~*c);
        *a &= keep;
        *b &= keep;
        *c &= keep;
        uint8_t merge = (uint8_t)(*c & (uint8_t)~*a & (uint8_t)~*b);
        *a |= merge;
        *b |= merge;
        *c &= (uint8_t)~merge;
    }
    image = zeliard_mcga_render_three_plane_ab_direct(seg, SOURCE_DI,
                                                       PLANE_BYTES, 0x2f, 0x58,
                                                       &w, &h);
    if (!image || w != 188 || h != 88)
        goto done;
    blit_to_framebuffer(image, w, h, 0x16 * 4, 0x18);
    memset(vga, 0, sizeof(vga));
    memcpy(vga, g_framebuf, ZELIARD_FB_SIZE);
    ok = fnv1a64(vga, sizeof(vga)) == 0x61C201EF93BF9D39ULL;

done:
    printf("mcga_disp_script_area: %s vga=%016llx\n", ok ? "PASS" : "FAIL",
           (unsigned long long)(ok ? fnv1a64(vga, sizeof(vga)) : 0));
    free(image);
    free(seg);
    free(planes);
    return ok;
}

static int run_apparition_remove_isi_case(void) {
    opening_apparition_remove_isi_summary_t s = opening_apparition_remove_isi_summary();
    int ok = 1;
    ok &= s.busy_wait_al[0] == 2;
    ok &= s.busy_wait_al[1] == 3;
    ok &= s.disp_game_al[0] == 0;
    ok &= s.disp_game_al[1] == 0;
    ok &= s.disp_game_bx[0] == 0x1728;
    ok &= s.disp_game_bx[1] == 0x1728;
    ok &= s.disp_game_cx[0] == 0x2230;
    ok &= s.disp_game_cx[1] == 0x2230;
    ok &= s.disp_game_di[0] == 0;
    ok &= s.disp_game_di[1] == 0;
    ok &= s.story_timer_wait_al == 0x0F;
    ok &= strcmp(s.sar_asset, "isi.grp") == 0;
    ok &= s.sar_al == 2;
    ok &= s.sar_di == 0xA000;
    ok &= s.decompress_si == 0xA000;
    ok &= s.decompress_di == 0x4000;
    ok &= s.gfx_mode_bx == 0x0410;
    ok &= s.gfx_mode_cx == 0x4868;
    printf("opening_apparition_remove_isi: %s waits=%02x/%02x disp=%02x/%04x/%04x sar=%s mode=%04x/%04x\n",
           ok ? "PASS" : "FAIL",
           s.busy_wait_al[0], s.busy_wait_al[1],
           s.disp_game_al[0], s.disp_game_bx[0], s.disp_game_cx[0],
           s.sar_asset, s.gfx_mode_bx, s.gfx_mode_cx);
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
    ok &= run_ttl3_decode_rle_memory_case();
    ok &= run_busy_wait_delay_memory_case();
    ok &= run_hime_dmaou_blend_memory_case();
    ok &= run_dmaou_prelude_segment_case();
    ok &= run_hime_dmaou_blend_frame_case();
    ok &= run_hime_dmaou_external_scratch_case();
    ok &= run_dmaou_apparition_3c1c_case();
    ok &= run_dmaou_post_busy_case(2, 0x8c5cd5885409e794ULL, 4643,
                                   0x1815cf0668c85b39ULL, 1512);
    ok &= run_dmaou_post_busy_case(3, 0x0168a8840b8730b8ULL, 4634,
                                   0xfd760b803e712fedULL, 1461);
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
        ok &= run_image_case(&cases[i]);
    }
    ok &= run_opdemo_nec_hou_handoff_memory_case();
    ok &= run_opdemo_nec_hou_handoff_disp_game_rect_case(
        0x6c526d707a77e637ULL, 64, 64, 1923,
        0x9cca3279aebfea37ULL, 1923, 128, 72, 191, 128);
    ok &= run_nec_three_plane_reveal_case();
    ok &= run_sprite_restore_clears_previous_frame_case();
    ok &= run_sprite_dac_transaction_cadence_case();
    ok &= run_sprite_completion_restores_palette_case();
    ok &= run_sprite_restore_crossing_case();
    /* Retired: run_opdemo_nec_hou_handoff_phase_frame_case was sampled at
     * the end of a synthetic two-times-14h service interval after 33B7h.
     * Release MASM has no timer wait there, so that timestamp does not name a
     * valid OPDMO checkpoint.  The preceding HOU memory/disp_game contracts
     * are release-MASM-derived; sprite-A gets its own per-frame oracle. */
    ok &= run_nec_hou_composite_case(0x9ef45cf29c1cd2b5ULL);
    ok &= run_opening_title_card_case(0x519522a8f9b14d3cULL);
    ok &= run_opening_scanline_runtime_bridge_case(
        0x99d1486b5642b42aULL, 0x57036e9bccfa36ceULL);
    ok &= run_amulet_scanline_runtime_completion_case();
    ok &= run_final_scanline_runtime_completion_case();
    ok &= run_final_transition_clear_case();
    ok &= run_late_frame_case("maop_reveal_step_00",
                              OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_00,
                              0x045c54146f3e47c0ULL);
    ok &= run_late_frame_case("maop_reveal_step_12",
                              OPENING_DEBUG_LATE_MAOP_REVEAL_STEP_12,
                              0x0e85b51a381f53c4ULL);
    ok &= run_late_frame_case("split_return_reveal_step_12",
                              OPENING_DEBUG_LATE_SPLIT_RETURN_STEP_12,
                              0xcfcbf218074ae6c3ULL);
    ok &= run_late_frame_case("final_yuu3_yuu4_composite",
                              OPENING_DEBUG_LATE_FINAL_YUU3_YUU4,
                              0x92d8ad4d7c4c1f7fULL);
    /* These phase-local samples use the real accumulated gvar_frame_timer
     * schedule of run_script_interpreter, not an independently rounded ms
     * delay per script byte.  The wait sequences are asserted by the MASM
     * `assert_story_script_protocol` oracle. */
    ok &= run_phase_frame_case("phase5_post_blend_script4_live",
                               OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                               42500 + OPDMO_TEST_WAIT_MS(8 * 0x14),
                               0x927f59a12736ed3aULL);
    ok &= run_phase_frame_case("phase5_script3_to_blend_delay",
                               OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                               42071 + OPDMO_TEST_WAIT_MS(8 * 0x14),
                               0xea9623da8322f73eULL);
    ok &= run_phase_frame_case("phase5_dmaou_apparition_disp_data",
                               OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                               45000 + OPDMO_TEST_WAIT_MS(8 * 0x14),
                               0x0d211db445165fe4ULL);
    const uint32_t apparition_remove_start = phase5_apparition_remove_start_ms();
    ok &= run_phase_frame_case("phase5_apparition_remove_al2_complete_live",
                               OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                               apparition_remove_start + OPDMO_TEST_WAIT_MS(16 * 0x14),
                               0x36e995bbd85aac02ULL);
    ok &= run_phase_frame_case("phase5_apparition_remove_al3_complete_live",
                               OPENING_PHASE_JASHIIN_CURSES_PRINCESS,
                               apparition_remove_start + OPDMO_TEST_WAIT_MS(16 * 0x14) +
                                   OPDMO_TEST_WAIT_MS(0x0F) + OPDMO_TEST_WAIT_MS(16 * 0x14) - 1,
                               0x7a54e13ec798898fULL);
    ok &= run_phase_frame_case("phase6_guardian_sei_overlay",
                               OPENING_PHASE_KING_GRIEF_AND_SPIRIT, 66000,
                               0x5198a7798d63e509ULL);
    ok &= run_duke_entry_masked_dissolve_case();
    ok &= run_yuu_split_preserves_font_inv_center_case();
    ok &= run_maop_live_border_case();
    ok &= run_jashiin_departure_yuu2_shell_case();
    ok &= run_phase_frame_case("phase9_duke_jashiin_after_maop",
                               OPENING_PHASE_JASHIIN_CONFRONTATION, 19000,
                               0xe51f0e6bf950dae9ULL);
    ok &= run_phase_frame_case("final_yuu3_yuu4_blit_start",
                               OPENING_PHASE_DESTINY_CARD, 0,
                               0x18f7ed5ff6c0906dULL);
    /* 100OPDMO:1075-84 draws the final YUU surface, then runs the verified
     * 7338 animate_scanline_alt stream.  These checkpoints replaced the old
     * synthetic destiny-card renderer. */
    ok &= run_phase_frame_case("final_yuu3_yuu4_alt_runtime_entry",
                               OPENING_PHASE_DESTINY_CARD, 8676,
                               0x9d2b83f7d134b93bULL);
    ok &= run_phase_frame_case("final_yuu3_yuu4_alt_runtime_mid_scroll",
                               OPENING_PHASE_DESTINY_CARD, 18676,
                               0x9d4c744cd829fa71ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_96",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_96,
                              0xe90b4d1e375f70f3ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_24",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_24,
                              0x7fe0fcd0234eeb53ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_48",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_48,
                              0xabef20a5dcc8a033ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_72",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_72,
                              0xabef20a5dcc8a033ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_120",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_120,
                              0x6463a816dfa96235ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_144",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_144,
                              0x45f68d2d081c1353ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_168",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_168,
                              0x45f68d2d081c1353ULL);
    ok &= run_late_frame_case("disp_load_ax0f_entry_192",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_ENTRY_192,
                              0xf367db99ee55cc05ULL);
    /* Complete direct calls to 105GDMCA:38E6.  The values come from the
     * Unicorn MASM oracle, not from the scene player. */
    ok &= run_late_frame_case("disp_load_ax06_full",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX06_FULL,
                              0x2deb8b761ec82310ULL);
    ok &= run_late_frame_case("disp_load_ax08_full",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX08_FULL,
                              0x8ee815ad4c559738ULL);
    ok &= run_late_frame_case("disp_load_ax0f_full",
                              OPENING_DEBUG_LATE_DISP_LOAD_AX0F_FULL,
                              0xf367db99ee55cc05ULL);
    ok &= run_late_frame_case("disp_load_setup_rect_yuu_left",
                              OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_LEFT,
                              0x82f852300d0ccbd9ULL);
    ok &= run_late_frame_case("disp_load_setup_rect_yuu_right",
                              OPENING_DEBUG_DISP_LOAD_SETUP_RECT_YUU_RIGHT,
                              0xdf07fffb511e6959ULL);
    ok &= run_late_frame_case("disp_load_setup_rect_maop",
                              OPENING_DEBUG_DISP_LOAD_SETUP_RECT_MAOP,
                              0xe4769151bb374b11ULL);
    ok &= run_late_frame_case("waku_ame_ax9_composite",
                              OPENING_DEBUG_LATE_WAKU_AME_AX9,
                              0x87930cdc61e043cfULL);
    ok &= run_late_frame_rect_case("waku_ame_ax9_inner_rect",
                                   OPENING_DEBUG_LATE_WAKU_AME_AX9,
                                   16, 16, 288, 104,
                                   0x603e529ec315331bULL, 24663);
    ok &= run_late_frame_rect_case("waku_ame_ax9_sky_rect",
                                   OPENING_DEBUG_LATE_WAKU_AME_AX9,
                                   80, 24, 190, 56,
                                   0x957c8e66b22faf56ULL, 9538);
    ok &= run_late_frame_case("waku_hime_ax9_composite",
                              OPENING_DEBUG_LATE_WAKU_HIME_AX9,
                              0xe4902326b0b62c7aULL);
    ok &= run_late_frame_case("waku_hime_ax6_composite",
                              OPENING_DEBUG_LATE_WAKU_HIME_AX6,
                              0xe4902326b0b62c7aULL);
    ok &= run_late_frame_case("waku_isi_ax7_composite",
                              OPENING_DEBUG_LATE_WAKU_ISI_AX7,
                              0x9a806ed4cade95b8ULL);
    ok &= run_late_frame_case("maop_script_area",
                              OPENING_DEBUG_LATE_MAOP_SCRIPT_AREA,
                              0x045c54146f3e47c0ULL);
    ok &= run_late_frame_case("oui_gfx_update_full",
                              OPENING_DEBUG_LATE_OUI_GFX_UPDATE_FULL,
                              0xd9de4271db1e6d0fULL);
    ok &= run_late_frame_case("sei_3c1c_pass_01",
                              OPENING_DEBUG_LATE_SEI_3C1C_PASS_01,
                              0xd0fa7852a4980779ULL);
    ok &= run_late_frame_case("sei_3c1c_pass_02",
                              OPENING_DEBUG_LATE_SEI_3C1C_PASS_02,
                              0xfb1363653dffc072ULL);
    ok &= run_late_frame_case("sei_3c1c_pass_04",
                              OPENING_DEBUG_LATE_SEI_3C1C_PASS_04,
                              0x170fa7d65e98edf7ULL);
    ok &= run_late_frame_case("sei_3c1c_pass_08",
                              OPENING_DEBUG_LATE_SEI_3C1C_PASS_08,
                              0x3a8e5e1c8fdd0b3eULL);
    ok &= run_font_renderer_case();
    ok &= run_script_calc_width_case();
    ok &= run_script_interpreter_control_case();
    ok &= run_script_interpreter_wrap_case();
    ok &= run_opdmo_script_metric_table_case();
    ok &= run_first_story_first_draw_case();
    ok &= run_rain_princess_preamble_hidden_case();
    ok &= run_story_break_preserves_text_page_case();
    ok &= run_dmaou_black_stripe_reveal_case();
    ok &= run_exact_story_script_case("opdemo_story_script_1.bin", 743,
                                      0xd77e2be1f175f020ULL, 743, 34, 9, 686);
    ok &= run_exact_story_script_case("opdemo_story_script_2.bin", 306,
                                      0x8a9f471b378e4a7bULL, 306, 15, 4, 281);
    ok &= run_exact_story_script_case("opdemo_story_script_3.bin", 174,
                                      0x46321012ab452221ULL, 174, 7, 1, 156);
    ok &= run_exact_story_script_case("opdemo_story_script_4.bin", 235,
                                      0x65ced3f222c259aeULL, 235, 6, 1, 223);
    ok &= run_exact_story_script_case("opdemo_story_script_5.bin", 1,
                                      0xaf64704c8602e808ULL, 1, 0, 0, 0);
    ok &= run_exact_story_script_case("opdemo_story_script_6.bin", 157,
                                      0x988b38048c42bc2cULL, 157, 2, 2, 149);
    ok &= run_exact_story_script_case("opdemo_story_script_7.bin", 91,
                                      0xa62417912655b0d8ULL, 91, 0, 0, 88);
    ok &= run_exact_story_script_case("opdemo_story_script_8.bin", 4,
                                      0xdc1dde1197dcde8aULL, 4, 2, 1, 0);
    ok &= run_exact_story_script_case("opdemo_story_script_9.bin", 193,
                                      0xc7f9af8cb06b6610ULL, 193, 6, 2, 182);
    ok &= run_exact_story_script_case("opdemo_story_script_10.bin", 162,
                                      0x0e89d0cd122e298fULL, 162, 3, 2, 150);
    ok &= run_exact_story_script_case("opdemo_story_script_11.bin", 75,
                                      0xb75f8f17a96cf33aULL, 75, 2, 1, 69);
    ok &= run_exact_story_script_case("opdemo_story_script_12.bin", 1033,
                                      0x3886477ab201f8cbULL, 1033, 22, 7, 992);
    ok &= run_exact_story_script_case("opdemo_story_script_13.bin", 258,
                                      0x5d0f71b5a0fe7952ULL, 258, 10, 3, 236);
    ok &= run_exact_story_script_case("opdemo_story_script_14.bin", 173,
                                      0x813d4d4d9467e520ULL, 173, 7, 2, 158);
    ok &= run_exact_story_script_case("opdemo_story_script_15.bin", 97,
                                      0xe998a3cdc7bc9ab8ULL, 97, 3, 1, 90);
    ok &= run_exact_story_script_case("opdemo_story_script_16.bin", 872,
                                      0xecbf9d5f63fee7d5ULL, 605, 16, 5, 571);
    ok &= run_exact_story_script_case("opdemo_story_script_17.bin", 1,
                                      0xaf64704c8602e808ULL, 1, 0, 0, 0);
    ok &= run_exact_story_script_case("opdemo_story_script_18.bin", 102,
                                      0xc0625a6800808910ULL, 102, 3, 1, 94);
    ok &= run_exact_story_script_case("opdemo_story_script_19.bin", 69,
                                      0x71ad183dd8147559ULL, 69, 2, 1, 63);
    ok &= run_exact_story_script_case("opdemo_story_script_20.bin", 876,
                                      0x430772a4e025f740ULL, 795, 22, 7, 746);
    ok &= run_exact_story_script_case("opdemo_story_script_21.bin", 77,
                                      0x55c23ef6288c7e74ULL, 77, 2, 1, 71);
    ok &= run_exact_story_script_case("opdemo_story_script_22.bin", 87,
                                      0x78bab3820e9a1dcbULL, 87, 3, 1, 78);
    ok &= run_scanline_summary_case();
    ok &= run_credits_summary_case();
    ok &= run_credits_scanline_runtime_completion_case();
    ok &= run_credits_first_two_records_mcga_oracle_case();
    ok &= run_scene_sprite_a_case();
    ok &= run_scene_sprite_a_object_table_case();
    ok &= run_scene_sprite_a_frame_table_case();
    ok &= run_scene_sprite_a_render_case("opening_scene_sprite_a_frame_00",
                                         0, 0xf9765efa9b86befaULL,
                                         0x841c63875a757ce5ULL,
                                         3125, 73, 34, 246, 146);
    ok &= run_scene_sprite_a_render_case("opening_scene_sprite_a_frame_08",
                                         8, 0x89e518aea1045740ULL,
                                         0x841c63875a757ce5ULL,
                                         3444, 33, 34, 291, 166);
    ok &= run_scene_sprite_a_render_case("opening_scene_sprite_a_frame_11",
                                         11, 0x76a5c68141189f10ULL,
                                         0xc4e6a2333b015635ULL,
                                         2712, 73, 34, 246, 128);
    ok &= run_scene_sprite_a_full_frame_case();
    ok &= run_scene_sprite_c_case();
    ok &= run_mcga_render_entry_oracle_case();
    ok &= run_mcga_render_asset_oracles_case();
    ok &= run_img_open_return_al_oracles_case();
    ok &= run_mcga_yuu_rect_oracles_case();
    ok &= run_scene_sprite_b_case();
    ok &= run_mcga_render_ab_gseg_case();
    ok &= run_mcga_render_ab_ab40_case();
    ok &= run_mcga_disp_script_area_case();
    ok &= run_gmmcga_render_text_char_alt_case();
    ok &= run_gmmcga_narration_stream_case();
    ok &= run_gmmcga_jashiin_speech_clear_case();
    ok &= run_title_asset_case();
    ok &= run_title_display_handoff_case();
    ok &= run_title_color_exit_case();
    ok &= run_title_handoff_timing_boundaries_case();
    ok &= run_title_handoff_repeated_tick_case();
    ok &= run_title_handoff_incremental_scheduler_case();
    ok &= run_timer_exit_case();
    ok &= run_trans_exit_case();
    ok &= run_apparition_remove_isi_case();
    ok &= run_palette_case(0xd9e89a4c32254f58ULL);
    ok &= run_opdmo_palette_cases();
    ok &= run_title_tile_scratch_palette_isolation_case();
    ok &= run_initial_title_case(0x519522a8f9b14d3cULL, 0x8499fcc0f156a055ULL);
    ok &= run_title_mcga_render_pass_case(0x519522a8f9b14d3cULL, 0x8499fcc0f156a055ULL);
    ok &= run_nec_mcga_render_pass_case(0x76a5c68141189f10ULL, 0x75d4cc9b41c60991ULL);
    ok &= run_copyright_input_ignored_case(0x1bd80e81a778a2caULL);
    ok &= run_copyright_timer_starts_prologue_case();
    ok &= run_amulet_phase_starts_first_mcga_pass_case();
    ok &= run_automatic_interlude_phase_order_case();
    ok &= run_title_handoff_visual_regression_case();
    ok &= run_opening_input_ignores_copyright_card_case();
    ok &= run_opening_input_advances_to_credits_case();
    ok &= run_opening_input_during_amulet_clear_is_ignored_case();
    ok &= run_opening_input_credits_to_story_case();
    ok &= run_opening_input_story_exits_to_game_case();
    ok &= run_opening_key_contract_case();
    printf("VERDICT: %s: opening native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
