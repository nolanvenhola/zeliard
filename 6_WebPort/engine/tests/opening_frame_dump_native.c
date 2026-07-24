#include "../core/framebuf.h"
#include "../core/types.h"
#include "../game/opening.h"
#include "../render/palette.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int write_ppm(const char *path) {
    FILE *f = fopen(path, "wb");
    if (!f) {
        fprintf(stderr, "opening-frame-dump: fopen %s failed: %d\n", path, errno);
        return 0;
    }

    fprintf(f, "P6\n%d %d\n255\n", ZELIARD_WIDTH, ZELIARD_HEIGHT);
    if (g_rgb_framebuf_active) {
        fwrite(g_rgb_framebuf, 3, ZELIARD_FB_SIZE, f);
    } else {
        for (int i = 0; i < ZELIARD_FB_SIZE; i++) {
            palette_color_t c = g_palette[g_framebuf[i]];
            fputc(c.r, f);
            fputc(c.g, f);
            fputc(c.b, f);
        }
    }
    fclose(f);
    return 1;
}

static int write_pgm_indices(const char *path) {
    FILE *f = fopen(path, "wb");
    if (!f) {
        fprintf(stderr, "opening-frame-dump: fopen %s failed: %d\n", path, errno);
        return 0;
    }

    fprintf(f, "P5\n%d %d\n255\n", ZELIARD_WIDTH, ZELIARD_HEIGHT);
    fwrite(g_framebuf, 1, ZELIARD_FB_SIZE, f);
    fclose(f);
    return 1;
}

int main(int argc, char **argv) {
    if (argc < 4 || argc > 12) {
        fprintf(stderr, "usage: %s <opening_phase_id> <elapsed_ms> <out.ppm|out.pgm> [--indices] [--timeline] [--stats] [--yuu-variant N] [--title-variant N] [--dmaou-mode N] [--ame-mode N] [--scene N] [--late N]\n", argv[0]);
        return 2;
    }

    int phase = atoi(argv[1]);
    u32 elapsed_ms = (u32)strtoul(argv[2], NULL, 10);
    const char *out_path = argv[3];
    int raw_indices = 0;
    int yuu_variant = 0;
    int title_variant = 0;
    int dmaou_mode = -1;
    int ame_mode = -1;
    int scene_idx = -1;
    int late_idx = -1;
    int timeline = 0;
    int stats = 0;
    for (int i = 4; i < argc; i++) {
        if (strcmp(argv[i], "--indices") == 0) {
            raw_indices = 1;
        } else if (strcmp(argv[i], "--timeline") == 0) {
            timeline = 1;
        } else if (strcmp(argv[i], "--stats") == 0) {
            stats = 1;
        } else if (strcmp(argv[i], "--yuu-variant") == 0 && i + 1 < argc) {
            yuu_variant = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--title-variant") == 0 && i + 1 < argc) {
            title_variant = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--dmaou-mode") == 0 && i + 1 < argc) {
            dmaou_mode = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--ame-mode") == 0 && i + 1 < argc) {
            ame_mode = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--scene") == 0 && i + 1 < argc) {
            scene_idx = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--late") == 0 && i + 1 < argc) {
            late_idx = atoi(argv[++i]);
        } else {
            fprintf(stderr, "opening-frame-dump: unknown option %s\n", argv[i]);
            return 2;
        }
    }

    opening_set_dmaou_apparition_mode_for_test(dmaou_mode);
    opening_set_ame_render_mode_for_test(ame_mode);
    opening_init();
    opening_set_yuu_plane_variant_for_test(yuu_variant);
    opening_set_title_tilemap_variant_for_test(title_variant);
    if (timeline) {
        u32 current_ms = 0;
        while (current_ms < elapsed_ms) {
            u32 step_ms = elapsed_ms - current_ms;
            if (step_ms > 10)
                step_ms = 10;
            opening_tick(step_ms);
            current_ms += step_ms;
        }
        fprintf(stderr, "timeline phase=%d elapsed=%u\n",
                opening_phase_id(), opening_phase_elapsed_ms());
    } else if (late_idx >= 0)
        opening_debug_render_late_frame((opening_debug_late_frame_t)late_idx);
    else if (scene_idx >= 0)
        opening_render_cached_scene_for_test(scene_idx);
    else
        opening_render_phase_for_test(phase, elapsed_ms);
    if (stats) {
        unsigned int index_count[256] = {0};
        int nonzero = 0;
        for (int i = 0; i < ZELIARD_FB_SIZE; i++) {
            index_count[g_framebuf[i]]++;
            if (g_framebuf[i] != 0)
                nonzero++;
        }
        fprintf(stderr,
                "stats requested_phase=%d requested_elapsed=%u phase=%d phase_elapsed=%u rgb_active=%d nonzero=%d\n",
                phase, elapsed_ms, opening_phase_id(), opening_phase_elapsed_ms(),
                g_rgb_framebuf_active, nonzero);
        for (int index = 0; index < 256; index++) {
            if (index_count[index] == 0)
                continue;
            palette_color_t c = g_palette[index];
            fprintf(stderr, "palette index=%u count=%u rgb=%u,%u,%u\n",
                    index, index_count[index], c.r, c.g, c.b);
        }
    }
    return (raw_indices ? write_pgm_indices(out_path) : write_ppm(out_path)) ? 0 : 1;
}
