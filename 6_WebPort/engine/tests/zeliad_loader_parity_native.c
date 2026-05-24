#include "../load/zeliad_loader.h"
#include <stdio.h>
#include <string.h>

static int expect_bool(const char *label, bool got, bool want) {
    int ok = got == want;
    printf("%s: %s got=%d want=%d\n", label, ok ? "PASS" : "FAIL", got ? 1 : 0, want ? 1 : 0);
    return ok;
}

static int expect_str(const char *label, const char *got, const char *want) {
    int ok = strcmp(got, want) == 0;
    printf("%s: %s got=\"%s\" want=\"%s\"\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_u8(const char *label, u8 got, u8 want) {
    int ok = got == want;
    printf("%s: %s got=0x%02X want=0x%02X\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_u16(const char *label, u16 got, u16 want) {
    int ok = got == want;
    printf("%s: %s got=0x%04X want=0x%04X\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_bytes(const char *label, const u8 *got, const u8 *want, size_t len) {
    int ok = memcmp(got, want, len) == 0;
    printf("%s: %s\n", label, ok ? "PASS" : "FAIL");
    return ok;
}

static int check_common_globals(const char *prefix, const zeliard_game_globals_t *g,
                                u8 graphics_mode, u8 mt32_enabled, u8 joystick_enabled) {
    int ok = 1;
    char label[96];

#define L(name) snprintf(label, sizeof(label), "%s:%s", prefix, name)
    L("chunk_load_fn"); ok &= expect_u16(label, g->chunk_load_fn, ZELIARD_ZELIAD_CALLBACK_OFS);
    L("chunk_load_seg"); ok &= expect_u16(label, g->chunk_load_seg, 0x1000);
    L("old_int08_ofs"); ok &= expect_u16(label, g->old_int08_ofs, 0x1111);
    L("old_int08_seg"); ok &= expect_u16(label, g->old_int08_seg, 0x2222);
    L("old_int09_ofs"); ok &= expect_u16(label, g->old_int09_ofs, 0x3333);
    L("old_int09_seg"); ok &= expect_u16(label, g->old_int09_seg, 0x4444);
    L("enable_all"); ok &= expect_u8(label, g->enable_all, 0xFF);
    L("key_released"); ok &= expect_u8(label, g->key_released, 0xFF);
    L("save_flag"); ok &= expect_u8(label, g->save_flag, 0x05);
    L("last_key"); ok &= expect_u8(label, g->last_key, joystick_enabled);
    L("game_phase"); ok &= expect_u8(label, g->game_phase, mt32_enabled);
    L("gfx_mode"); ok &= expect_u8(label, g->gfx_mode, graphics_mode);
    L("game_seg"); ok &= expect_u16(label, g->game_seg, 0x4000);
    L("timer_ticks"); ok &= expect_u8(label, g->timer_ticks, 0);
    L("timer_counter"); ok &= expect_u16(label, g->timer_counter, 0);
    L("state_c"); ok &= expect_u16(label, g->state_c, 0);
    L("flag_shield"); ok &= expect_u8(label, g->flag_shield, 0);
    L("flag_climbing"); ok &= expect_u8(label, g->flag_climbing, 0);
    L("flag_riding"); ok &= expect_u8(label, g->flag_riding, 0);
    L("scroll_active"); ok &= expect_u8(label, g->scroll_active, 0);
    L("input_lock"); ok &= expect_u8(label, g->input_lock, 0);
    L("disk_swap_suppressed"); ok &= expect_u8(label, g->disk_swap_suppressed, 0);
#undef L
    return ok;
}

static int run_init_global_cases(void) {
    int ok = 1;
    zeliard_loader_init_input_t input = {
        .zeliad_code_seg = 0x1000,
        .game_entry_seg = 0x3000,
        .old_int08_ofs = 0x1111,
        .old_int08_seg = 0x2222,
        .old_int09_ofs = 0x3333,
        .old_int09_seg = 0x4444,
        .graphics_mode = 4,
        .mt32_enabled = 0xFF,
        .joystick_enabled = 0xFF,
        .cmdline_savefile = "hero.USR",
    };
    zeliard_game_globals_t g;
    static const u8 hero_name[8] = {'H', 'E', 'R', 'O', 0, 0, 0, 0};
    static const u8 mixed_name[8] = {'M', 'I', 'X', 'E', 'D', 0, 0, 0};
    static const u8 clamped_name[8] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};

    zeliard_init_game_globals(&g, &input);
    ok &= check_common_globals("zeliad_init_game_globals:hero", &g, 4, 0xFF, 0xFF);
    ok &= expect_bytes("zeliad_init_game_globals:hero:save_name", g.save_name_buf, hero_name, 8);

    input.graphics_mode = 1;
    input.mt32_enabled = 0;
    input.joystick_enabled = 0;
    input.cmdline_savefile = "MiXeD.USR";
    zeliard_init_game_globals(&g, &input);
    ok &= check_common_globals("zeliad_init_game_globals:mixed", &g, 1, 0, 0);
    ok &= expect_bytes("zeliad_init_game_globals:mixed:save_name", g.save_name_buf, mixed_name, 8);

    input.graphics_mode = 5;
    input.mt32_enabled = 0xFF;
    input.joystick_enabled = 0;
    input.cmdline_savefile = "abcdefghijk";
    zeliard_init_game_globals(&g, &input);
    ok &= check_common_globals("zeliad_init_game_globals:clamp", &g, 5, 0xFF, 0);
    ok &= expect_bytes("zeliad_init_game_globals:clamp:save_name", g.save_name_buf, clamped_name, 8);

    return ok;
}

static int expect_loader_entry(const char *label, const zeliard_loader_file_entry_t *entry,
                               u16 segment, u16 descriptor_offset, u16 offset,
                               const char *filename) {
    int ok = 1;
    char field[96];
    snprintf(field, sizeof(field), "%s:segment", label);
    ok &= expect_u16(field, entry->segment, segment);
    snprintf(field, sizeof(field), "%s:descriptor_offset", label);
    ok &= expect_u16(field, entry->descriptor_offset, descriptor_offset);
    snprintf(field, sizeof(field), "%s:offset", label);
    ok &= expect_u16(field, entry->offset, offset);
    snprintf(field, sizeof(field), "%s:filename", label);
    ok &= expect_str(field, entry->filename, filename);
    return ok;
}

static int expect_loader_trace_event(const char *label,
                                     const zeliard_loader_trace_event_t *event,
                                     u16 es, u16 di, u16 load_offset,
                                     const char *filename) {
    int ok = 1;
    char field[96];
    snprintf(field, sizeof(field), "%s:kind", label);
    ok &= expect_u16(field, (u16)event->kind, ZELIARD_LOADER_TRACE_LOAD_FILE);
    snprintf(field, sizeof(field), "%s:es", label);
    ok &= expect_u16(field, event->es, es);
    snprintf(field, sizeof(field), "%s:di", label);
    ok &= expect_u16(field, event->di, di);
    snprintf(field, sizeof(field), "%s:load_offset", label);
    ok &= expect_u16(field, event->load_offset, load_offset);
    snprintf(field, sizeof(field), "%s:filename", label);
    ok &= expect_str(field, event->filename, filename);
    return ok;
}

static int run_loader_plan_cases(void) {
    int ok = 1;
    zeliard_loader_plan_t plan;
    zeliard_loader_trace_event_t trace[6];
    zeliard_loader_plan_input_t input = {
        .game_entry_seg = 0x3000,
        .graphics_mode = 0,
        .save_filename = "",
        .music_driver_name = "mscadlib.drv",
        .joystick_driver_name = "sndadlib.drv",
    };
    static const char *const gfx_names[6] = {
        "gmega.bin", "gmcga.bin", "gmcga.bin", "gmhgc.bin", "gmmcga.bin", "gmtga.bin",
    };
    static const u16 gfx_descriptors[6] = {
        0x0812, 0x081E, 0x081E, 0x082A, 0x0836, 0x0843,
    };

    for (u8 mode = 0; mode < 6; ++mode) {
        input.graphics_mode = mode;
        input.save_filename = "";
        size_t trace_count = zeliard_resolve_loader_trace(trace, 6, &input);
        bool resolved = zeliard_resolve_loader_plan(&plan, &input);
        char label[80];
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:count", mode);
        ok &= expect_u16(label, (u16)trace_count, 6);
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:player", mode);
        ok &= expect_loader_trace_event(label, &trace[0], 0x3000, 0x085A, 0x0000, "stdply.bin");
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:stick", mode);
        ok &= expect_loader_trace_event(label, &trace[1], 0x3000, 0x0806, 0x0100, "stick.bin");
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:game", mode);
        ok &= expect_loader_trace_event(label, &trace[2], 0x3000, 0x084F, 0xA000, "game.bin");
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:gfx", mode);
        ok &= expect_loader_trace_event(label, &trace[3], 0x3000, gfx_descriptors[mode],
                                        0x2000, gfx_names[mode]);
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:music", mode);
        ok &= expect_loader_trace_event(label, &trace[4], 0x3FF0, 0x0889, 0x0100, "mscadlib.drv");
        snprintf(label, sizeof(label), "zeliad_load_trace:mode%u:joystick", mode);
        ok &= expect_loader_trace_event(label, &trace[5], 0x3FF0, 0x089B, 0x1100, "sndadlib.drv");

        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:resolved", mode);
        ok &= expect_bool(label, resolved, true);
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:count", mode);
        ok &= expect_u16(label, (u16)plan.file_count, 6);
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:player", mode);
        ok &= expect_loader_entry(label, &plan.files[0], 0x3000, 0x085A, 0x0000, "stdply.bin");
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:stick", mode);
        ok &= expect_loader_entry(label, &plan.files[1], 0x3000, 0x0806, 0x0100, "stick.bin");
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:game", mode);
        ok &= expect_loader_entry(label, &plan.files[2], 0x3000, 0x084F, 0xA000, "game.bin");
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:gfx", mode);
        ok &= expect_loader_entry(label, &plan.files[3], 0x3000, gfx_descriptors[mode],
                                  0x2000, gfx_names[mode]);
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:music", mode);
        ok &= expect_loader_entry(label, &plan.files[4], 0x3FF0, 0x0889, 0x0100, "mscadlib.drv");
        snprintf(label, sizeof(label), "zeliad_load_plan:mode%u:joystick", mode);
        ok &= expect_loader_entry(label, &plan.files[5], 0x3FF0, 0x089B, 0x1100, "sndadlib.drv");
    }

    input.graphics_mode = 4;
    input.save_filename = "CUSTOM.USR";
    ok &= expect_u16("zeliad_load_trace:save:count",
                     (u16)zeliard_resolve_loader_trace(trace, 6, &input), 6);
    ok &= expect_loader_trace_event("zeliad_load_trace:save:player",
                                    &trace[0], 0x3000, 0x0867, 0x0000, "CUSTOM.USR");
    ok &= expect_bool("zeliad_load_plan:save:resolved",
                      zeliard_resolve_loader_plan(&plan, &input), true);
    ok &= expect_loader_entry("zeliad_load_plan:save:player",
                              &plan.files[0], 0x3000, 0x0867, 0x0000, "CUSTOM.USR");

    input.graphics_mode = 6;
    ok &= expect_u16("zeliad_load_trace:invalid_mode",
                     (u16)zeliard_resolve_loader_trace(trace, 6, &input), 0);
    ok &= expect_bool("zeliad_load_plan:invalid_mode",
                      zeliard_resolve_loader_plan(&plan, &input), false);
    return ok;
}

static int run_video_mode_cases(void) {
    int ok = 1;
    static const u16 expected_ax[6] = {
        0x000E, 0x0005, 0x0006, 0x0000, 0x0013, 0x0009,
    };

    for (u8 mode = 0; mode < 6; ++mode) {
        zeliard_video_mode_plan_t plan = zeliard_resolve_video_mode_plan(mode);
        char label[96];
        if (mode == 3) {
            snprintf(label, sizeof(label), "zeliad_video_mode:mode%u:kind", mode);
            ok &= expect_u16(label, (u16)plan.kind, ZELIARD_VIDEO_MODE_HGC);
            snprintf(label, sizeof(label), "zeliad_video_mode:mode%u:hgc_segment", mode);
            ok &= expect_u16(label, plan.hgc_clear_segment, 0xB000);
            snprintf(label, sizeof(label), "zeliad_video_mode:mode%u:hgc_words", mode);
            ok &= expect_u16(label, plan.hgc_clear_words, 0x4000);
        } else {
            snprintf(label, sizeof(label), "zeliad_video_mode:mode%u:kind", mode);
            ok &= expect_u16(label, (u16)plan.kind, ZELIARD_VIDEO_MODE_INT10);
            snprintf(label, sizeof(label), "zeliad_video_mode:mode%u:int10_ax", mode);
            ok &= expect_u16(label, plan.int10_ax, expected_ax[mode]);
        }
    }

    zeliard_video_mode_plan_t invalid = zeliard_resolve_video_mode_plan(6);
    ok &= expect_u16("zeliad_video_mode:invalid:kind",
                     (u16)invalid.kind, ZELIARD_VIDEO_MODE_INVALID);
    return ok;
}

int main(void) {
    int ok = 1;
    char out[40];
    bool parsed;

    parsed = zeliard_parse_startup_save_arg("", 0, out, sizeof(out));
    ok &= expect_bool("zeliad_psp_save_arg:empty:parsed", parsed, false);
    ok &= expect_str("zeliad_psp_save_arg:empty:name", out, "");

    parsed = zeliard_parse_startup_save_arg("   ", 3, out, sizeof(out));
    ok &= expect_bool("zeliad_psp_save_arg:spaces:parsed", parsed, false);
    ok &= expect_str("zeliad_psp_save_arg:spaces:name", out, "");

    parsed = zeliard_parse_startup_save_arg("  hero", 6, out, sizeof(out));
    ok &= expect_bool("zeliad_psp_save_arg:leading_spaces:parsed", parsed, true);
    ok &= expect_str("zeliad_psp_save_arg:leading_spaces:name", out, "hero.USR");

    parsed = zeliard_parse_startup_save_arg("foo bar", 7, out, sizeof(out));
    ok &= expect_bool("zeliad_psp_save_arg:space_compact:parsed", parsed, true);
    ok &= expect_str("zeliad_psp_save_arg:space_compact:name", out, "foobar.USR");

    parsed = zeliard_parse_startup_save_arg("MiXeD", 5, out, sizeof(out));
    ok &= expect_bool("zeliad_psp_save_arg:case:parsed", parsed, true);
    ok &= expect_str("zeliad_psp_save_arg:case:name", out, "MiXeD.USR");

    ok &= run_init_global_cases();
    ok &= run_loader_plan_cases();
    ok &= run_video_mode_cases();

    printf("VERDICT: %s: zeliad loader native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
