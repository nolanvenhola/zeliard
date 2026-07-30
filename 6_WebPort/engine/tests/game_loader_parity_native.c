#include "../load/game_loader.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int expect_bool(const char *label, bool got, bool want) {
    int ok = got == want;
    printf("%s: %s got=%d want=%d\n", label, ok ? "PASS" : "FAIL",
           got ? 1 : 0, want ? 1 : 0);
    return ok;
}

static int expect_size(const char *label, size_t got, size_t want) {
    int ok = got == want;
    printf("%s: %s got=%zu want=%zu\n", label, ok ? "PASS" : "FAIL", got, want);
    return ok;
}

static int expect_u16(const char *label, u16 got, u16 want) {
    int ok = got == want;
    printf("%s: %s got=0x%04X want=0x%04X\n", label, ok ? "PASS" : "FAIL",
           got, want);
    return ok;
}

static int expect_u8(const char *label, u8 got, u8 want) {
    int ok = got == want;
    printf("%s: %s got=0x%02X want=0x%02X\n", label, ok ? "PASS" : "FAIL",
           got, want);
    return ok;
}

static int expect_str(const char *label, const char *got, const char *want) {
    int ok = (got == NULL && want == NULL) ||
             (got != NULL && want != NULL && strcmp(got, want) == 0);
    printf("%s: %s got=\"%s\" want=\"%s\"\n", label, ok ? "PASS" : "FAIL",
           got ? got : "", want ? want : "");
    return ok;
}

static int run_zero_case(void) {
    zeliard_game_music_trace_event_t trace[9] = {0};
    zeliard_game_music_plan_t plan = {0};
    int ok = expect_size("game_music_trace:zero:count",
                         zeliard_game_resolve_music_trace(trace, 9, 0), 0);
    ok &= expect_bool("game_music:zero:resolved",
                         zeliard_game_resolve_music_plan(&plan, 0), true);
    ok &= expect_size("game_music:zero:count", plan.load_count, 0);
    return ok;
}

static int run_first_three_case(void) {
    static const u16 refs[3] = {0x0F00, 0x3D00, 0x1500};
    zeliard_game_music_trace_event_t trace[9] = {0};
    zeliard_game_music_plan_t plan = {0};
    int ok = expect_size("game_music_trace:first_three:count",
                         zeliard_game_resolve_music_trace(trace, 9, 3), 3);
    for (u8 i = 0; i < 3; ++i) {
        char label[72];
        snprintf(label, sizeof(label), "game_music_trace:first_three:%u:index", i);
        ok &= expect_u8(label, trace[i].track_index, i);
        snprintf(label, sizeof(label), "game_music_trace:first_three:%u:ref", i);
        ok &= expect_u16(label, trace[i].track_ref, refs[i]);
        snprintf(label, sizeof(label), "game_music_trace:first_three:%u:bg", i);
        ok &= expect_u8(label, trace[i].background_flag, 0);
    }
    ok &= expect_bool("game_music:first_three:resolved",
                         zeliard_game_resolve_music_plan(&plan, 3), true);
    ok &= expect_size("game_music:first_three:count", plan.load_count, 3);
    for (u8 i = 0; i < 3; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "game_music:first_three:%u:index", i);
        ok &= expect_u8(label, plan.loads[i].track_index, i);
        snprintf(label, sizeof(label), "game_music:first_three:%u:ref", i);
        ok &= expect_u16(label, plan.loads[i].track_ref, refs[i]);
        snprintf(label, sizeof(label), "game_music:first_three:%u:bg", i);
        ok &= expect_u8(label, plan.loads[i].background_flag, 0);
    }
    return ok;
}

static int run_all_tracks_case(void) {
    static const u16 refs[9] = {
        0x0F00, 0x3D00, 0x1500, 0x3700, 0x1B00,
        0x3100, 0x2100, 0x2B00, 0x2600,
    };
    zeliard_game_music_trace_event_t trace[9] = {0};
    zeliard_game_music_plan_t plan = {0};
    int ok = expect_size("game_music_trace:all:count",
                         zeliard_game_resolve_music_trace(trace, 9, 9), 9);
    for (u8 i = 0; i < 9; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "game_music_trace:all:%u:index", i);
        ok &= expect_u8(label, trace[i].track_index, i);
        snprintf(label, sizeof(label), "game_music_trace:all:%u:ref", i);
        ok &= expect_u16(label, trace[i].track_ref, refs[i]);
        snprintf(label, sizeof(label), "game_music_trace:all:%u:bg", i);
        ok &= expect_u8(label, trace[i].background_flag, i == 8 ? 1 : 0);
    }
    ok &= expect_bool("game_music:all:resolved",
                         zeliard_game_resolve_music_plan(&plan, 9), true);
    ok &= expect_size("game_music:all:count", plan.load_count, 9);
    for (u8 i = 0; i < 9; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "game_music:all:%u:index", i);
        ok &= expect_u8(label, plan.loads[i].track_index, i);
        snprintf(label, sizeof(label), "game_music:all:%u:ref", i);
        ok &= expect_u16(label, plan.loads[i].track_ref, refs[i]);
        snprintf(label, sizeof(label), "game_music:all:%u:bg", i);
        ok &= expect_u8(label, plan.loads[i].background_flag, i == 8 ? 1 : 0);
    }
    return ok;
}

static int run_invalid_case(void) {
    zeliard_game_music_trace_event_t trace[9] = {0};
    zeliard_game_music_plan_t plan = {0};
    int ok = expect_size("game_music_trace:invalid_count",
                         zeliard_game_resolve_music_trace(trace, 9, 10), 0);
    ok &= expect_bool("game_music:invalid_count",
                      zeliard_game_resolve_music_plan(&plan, 10), false);
    return ok;
}

static int run_ega_palette_case(void) {
    static const u8 regs[16] = {
        0x3F, 0x24, 0x12, 0x1B, 0x09, 0x36, 0x2D, 0x38,
        0x07, 0x04, 0x02, 0x03, 0x01, 0x06, 0x05, 0x00,
    };
    zeliard_game_palette_trace_event_t trace[64] = {0};
    zeliard_game_palette_plan_t plan = {0};
    int ok = expect_size("game_palette_trace:ega:count",
                         zeliard_game_resolve_palette_trace(trace, 64, 0), 1);
    ok &= expect_u8("game_palette_trace:ega:kind", (u8)trace[0].kind,
                    (u8)ZELIARD_GAME_PALETTE_TRACE_EGA_ATTR);
    ok &= expect_u16("game_palette_trace:ega:int", trace[0].interrupt_no, 0x10);
    ok &= expect_u16("game_palette_trace:ega:ax", trace[0].ax, 0x1002);
    ok &= expect_u16("game_palette_trace:ega:es", trace[0].es_delta, 0);
    ok &= expect_u8("game_palette_trace:ega:border", trace[0].ega_border, 0);
    for (u8 i = 0; i < 16; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "game_palette_trace:ega:reg%u", i);
        ok &= expect_u8(label, trace[0].ega_regs[i], regs[i]);
    }
    ok &= expect_bool("game_palette:ega:resolved",
                         zeliard_game_resolve_palette_plan(&plan, 0), true);
    ok &= expect_u8("game_palette:ega:kind", (u8)plan.kind,
                    (u8)ZELIARD_GAME_PALETTE_EGA_ATTR);
    ok &= expect_u8("game_palette:ega:border", plan.ega.border, 0);
    for (u8 i = 0; i < 16; ++i) {
        char label[64];
        snprintf(label, sizeof(label), "game_palette:ega:reg%u", i);
        ok &= expect_u8(label, plan.ega.regs[i], regs[i]);
    }
    return ok;
}

static int run_noop_palette_cases(void) {
    static const u8 modes[] = {1, 2, 3, 5};
    int ok = 1;
    for (size_t i = 0; i < sizeof(modes); ++i) {
        char label[64];
        zeliard_game_palette_trace_event_t trace[64] = {0};
        zeliard_game_palette_plan_t plan = {0};
        snprintf(label, sizeof(label), "game_palette_trace:noop%u:count", modes[i]);
        ok &= expect_size(label, zeliard_game_resolve_palette_trace(trace, 64, modes[i]), 0);
        snprintf(label, sizeof(label), "game_palette:noop%u:resolved", modes[i]);
        ok &= expect_bool(label, zeliard_game_resolve_palette_plan(&plan, modes[i]), true);
        snprintf(label, sizeof(label), "game_palette:noop%u:kind", modes[i]);
        ok &= expect_u8(label, (u8)plan.kind, (u8)ZELIARD_GAME_PALETTE_NOOP);
        snprintf(label, sizeof(label), "game_palette:noop%u:count", modes[i]);
        ok &= expect_size(label, plan.mcga_count, 0);
    }
    return ok;
}

static int expect_mcga_entry(const char *label, const zeliard_game_palette_plan_t *plan,
                             u8 index, u8 r, u8 g, u8 b) {
    char full_label[80];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:index", label);
    ok &= expect_u8(full_label, plan->mcga[index].index, index);
    snprintf(full_label, sizeof(full_label), "%s:r", label);
    ok &= expect_u8(full_label, plan->mcga[index].r, r);
    snprintf(full_label, sizeof(full_label), "%s:g", label);
    ok &= expect_u8(full_label, plan->mcga[index].g, g);
    snprintf(full_label, sizeof(full_label), "%s:b", label);
    ok &= expect_u8(full_label, plan->mcga[index].b, b);
    return ok;
}

static int run_mcga_palette_case(void) {
    zeliard_game_palette_trace_event_t trace[64] = {0};
    zeliard_game_palette_plan_t plan = {0};
    int ok = expect_size("game_palette_trace:mcga:count",
                         zeliard_game_resolve_palette_trace(trace, 64, 4), 64);
    ok &= expect_u8("game_palette_trace:mcga:entry0:kind", (u8)trace[0].kind,
                    (u8)ZELIARD_GAME_PALETTE_TRACE_MCGA_DAC);
    ok &= expect_u16("game_palette_trace:mcga:entry0:int", trace[0].interrupt_no, 0x10);
    ok &= expect_u16("game_palette_trace:mcga:entry0:ax", trace[0].ax, 0x1010);
    ok &= expect_u16("game_palette_trace:mcga:entry0:bx", trace[0].bx, 0);
    ok &= expect_u16("game_palette_trace:mcga:entry0:dx", trace[0].dx, 0x0000);
    ok &= expect_u16("game_palette_trace:mcga:entry0:cx", trace[0].cx, 0x0000);
    ok &= expect_u8("game_palette_trace:mcga:entry1:index", trace[1].dac_index, 1);
    ok &= expect_u8("game_palette_trace:mcga:entry1:r", trace[1].r, 0x1F);
    ok &= expect_u8("game_palette_trace:mcga:entry1:g", trace[1].g, 0x1F);
    ok &= expect_u8("game_palette_trace:mcga:entry1:b", trace[1].b, 0x1F);
    ok &= expect_u16("game_palette_trace:mcga:entry9:bx", trace[9].bx, 9);
    ok &= expect_u16("game_palette_trace:mcga:entry9:dx", trace[9].dx, 0x3E00);
    ok &= expect_u16("game_palette_trace:mcga:entry9:cx", trace[9].cx, 0x3E3E);
    ok &= expect_u8("game_palette_trace:mcga:entry63:index", trace[63].dac_index, 63);
    ok &= expect_u8("game_palette_trace:mcga:entry63:r", trace[63].r, 0x3E);
    ok &= expect_u8("game_palette_trace:mcga:entry63:g", trace[63].g, 0x00);
    ok &= expect_u8("game_palette_trace:mcga:entry63:b", trace[63].b, 0x3E);
    ok &= expect_bool("game_palette:mcga:resolved",
                         zeliard_game_resolve_palette_plan(&plan, 4), true);
    ok &= expect_u8("game_palette:mcga:kind", (u8)plan.kind,
                    (u8)ZELIARD_GAME_PALETTE_MCGA_DAC);
    ok &= expect_size("game_palette:mcga:count", plan.mcga_count, 64);
    ok &= expect_mcga_entry("game_palette:mcga:entry0", &plan, 0, 0x00, 0x00, 0x00);
    ok &= expect_mcga_entry("game_palette:mcga:entry1", &plan, 1, 0x1F, 0x1F, 0x1F);
    ok &= expect_mcga_entry("game_palette:mcga:entry9", &plan, 9, 0x3E, 0x3E, 0x3E);
    ok &= expect_mcga_entry("game_palette:mcga:entry63", &plan, 63, 0x3E, 0x00, 0x3E);
    return ok;
}

static int run_invalid_palette_case(void) {
    zeliard_game_palette_trace_event_t trace[64] = {0};
    zeliard_game_palette_plan_t plan = {0};
    int ok = expect_size("game_palette_trace:invalid_mode",
                         zeliard_game_resolve_palette_trace(trace, 64, 6), 0);
    ok &= expect_bool("game_palette:invalid_mode",
                      zeliard_game_resolve_palette_plan(&plan, 6), false);
    return ok;
}

static int expect_boot_call(const char *label, const zeliard_game_bootstrap_call_t *call,
                            zeliard_game_bootstrap_call_kind_t kind, const char *name,
                            u16 es_delta, u16 dest_offset, u8 al, u8 ah) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)call->kind, (u8)kind);
    snprintf(full_label, sizeof(full_label), "%s:name", label);
    ok &= expect_str(full_label, call->name, name);
    snprintf(full_label, sizeof(full_label), "%s:es", label);
    ok &= expect_u16(full_label, call->es_delta, es_delta);
    snprintf(full_label, sizeof(full_label), "%s:di", label);
    ok &= expect_u16(full_label, call->dest_offset, dest_offset);
    snprintf(full_label, sizeof(full_label), "%s:al", label);
    ok &= expect_u8(full_label, call->al, al);
    snprintf(full_label, sizeof(full_label), "%s:ah", label);
    ok &= expect_u8(full_label, call->ah, ah);
    return ok;
}

static int expect_boot_trace_event(const char *label,
                                   const zeliard_game_bootstrap_trace_event_t *event,
                                   zeliard_game_bootstrap_call_kind_t kind,
                                   const char *name,
                                   u16 es_delta,
                                   u16 dest_offset,
                                   u8 al,
                                   u8 ah) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind, (u8)kind);
    snprintf(full_label, sizeof(full_label), "%s:name", label);
    ok &= expect_str(full_label, event->name, name);
    snprintf(full_label, sizeof(full_label), "%s:es", label);
    ok &= expect_u16(full_label, event->es_delta, es_delta);
    snprintf(full_label, sizeof(full_label), "%s:di", label);
    ok &= expect_u16(full_label, event->dest_offset, dest_offset);
    snprintf(full_label, sizeof(full_label), "%s:al", label);
    ok &= expect_u8(full_label, event->al, al);
    snprintf(full_label, sizeof(full_label), "%s:ah", label);
    ok &= expect_u8(full_label, event->ah, ah);
    return ok;
}

static int expect_level_trace_event(const char *label,
                                    const zeliard_game_level_load_trace_event_t *event,
                                    zeliard_game_bootstrap_call_kind_t kind,
                                    const char *name,
                                    u16 es_delta,
                                    u16 dest_offset,
                                    u8 al,
                                    u8 ah,
                                    u16 ref_offset) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind, (u8)kind);
    snprintf(full_label, sizeof(full_label), "%s:name", label);
    ok &= expect_str(full_label, event->name, name);
    snprintf(full_label, sizeof(full_label), "%s:es", label);
    ok &= expect_u16(full_label, event->es_delta, es_delta);
    snprintf(full_label, sizeof(full_label), "%s:di", label);
    ok &= expect_u16(full_label, event->dest_offset, dest_offset);
    snprintf(full_label, sizeof(full_label), "%s:al", label);
    ok &= expect_u8(full_label, event->al, al);
    snprintf(full_label, sizeof(full_label), "%s:ah", label);
    ok &= expect_u8(full_label, event->ah, ah);
    snprintf(full_label, sizeof(full_label), "%s:ref", label);
    ok &= expect_u16(full_label, event->ref_offset, ref_offset);
    return ok;
}

static int expect_driver_call(const char *label,
                              const zeliard_game_bootstrap_driver_call_t *call,
                              u8 slot, u8 al, u16 bx) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:slot", label);
    ok &= expect_u8(full_label, call->slot, slot);
    snprintf(full_label, sizeof(full_label), "%s:al", label);
    ok &= expect_u8(full_label, call->al, al);
    snprintf(full_label, sizeof(full_label), "%s:bx", label);
    ok &= expect_u16(full_label, call->bx, bx);
    return ok;
}

static int expect_boot_effect_state(const char *label,
                                    const zeliard_game_bootstrap_effect_event_t *event,
                                    u16 offset, u8 value) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE);
    snprintf(full_label, sizeof(full_label), "%s:offset", label);
    ok &= expect_u16(full_label, event->offset, offset);
    snprintf(full_label, sizeof(full_label), "%s:value", label);
    ok &= expect_u8(full_label, event->value, value);
    return ok;
}

static int expect_boot_effect_relocation(
    const char *label,
    const zeliard_game_bootstrap_effect_event_t *event,
    u16 es_delta,
    u16 offset,
    u8 word_count,
    u16 addend) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_RELOCATION);
    snprintf(full_label, sizeof(full_label), "%s:es", label);
    ok &= expect_u16(full_label, event->es_delta, es_delta);
    snprintf(full_label, sizeof(full_label), "%s:offset", label);
    ok &= expect_u16(full_label, event->offset, offset);
    snprintf(full_label, sizeof(full_label), "%s:word_count", label);
    ok &= expect_u8(full_label, event->word_count, word_count);
    snprintf(full_label, sizeof(full_label), "%s:addend", label);
    ok &= expect_u16(full_label, event->addend, addend);
    return ok;
}

static int expect_boot_effect_music(const char *label,
                                    const zeliard_game_bootstrap_effect_event_t *event,
                                    u8 index, u16 track_ref, u8 background_flag) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_MUSIC_LOAD);
    snprintf(full_label, sizeof(full_label), "%s:index", label);
    ok &= expect_u8(full_label, event->track_index, index);
    snprintf(full_label, sizeof(full_label), "%s:ref", label);
    ok &= expect_u16(full_label, event->track_ref, track_ref);
    snprintf(full_label, sizeof(full_label), "%s:bg", label);
    ok &= expect_u8(full_label, event->background_flag, background_flag);
    return ok;
}

static int expect_boot_effect_driver(const char *label,
                                     const zeliard_game_bootstrap_effect_event_t *event,
                                     u8 slot, u8 al, u16 bx) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL);
    snprintf(full_label, sizeof(full_label), "%s:slot", label);
    ok &= expect_u8(full_label, event->driver_slot, slot);
    snprintf(full_label, sizeof(full_label), "%s:al", label);
    ok &= expect_u8(full_label, event->al, al);
    snprintf(full_label, sizeof(full_label), "%s:bx", label);
    ok &= expect_u16(full_label, event->bx, bx);
    return ok;
}

static int expect_boot_effect_game_init(
    const char *label,
    const zeliard_game_bootstrap_effect_event_t *event,
    u16 segment) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_GAME_INIT_CALL);
    snprintf(full_label, sizeof(full_label), "%s:segment", label);
    ok &= expect_u16(full_label, event->segment, segment);
    return ok;
}

static int expect_boot_effect_branch(
    const char *label,
    const zeliard_game_bootstrap_effect_event_t *event,
    zeliard_game_bootstrap_branch_target_t target) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:kind", label);
    ok &= expect_u8(full_label, (u8)event->kind,
                    (u8)ZELIARD_GAME_BOOT_EFFECT_BRANCH);
    snprintf(full_label, sizeof(full_label), "%s:target", label);
    ok &= expect_u8(full_label, (u8)event->branch_target, (u8)target);
    return ok;
}

static int run_level_load_trace_cases(void) {
    zeliard_game_level_load_trace_event_t trace[3] = {0};
    zeliard_game_level_load_input_t input = {
        .current_area_id = 3,
        .save_tileset_source = 0x0A,
        .save_map_source = 0x03,
    };
    int ok = expect_size("game_level_load_trace:saved:count",
                         zeliard_game_resolve_level_load_trace(trace, 3, &input),
                         3);
    ok &= expect_level_trace_event("game_level_load_trace:saved:0", &trace[0],
                                   ZELIARD_GAME_BOOT_LOAD_LEVEL, NULL,
                                   0x3000, 0x0000, 1, 3, 0);
    ok &= expect_level_trace_event("game_level_load_trace:saved:1", &trace[1],
                                   ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                   "level_tileset",
                                   0x1000, 0x3000, 5, 0, 0xA39A);
    ok &= expect_level_trace_event("game_level_load_trace:saved:2", &trace[2],
                                   ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                   "level_map",
                                   0x1000, 0x4000, 2, 0, 0xA3B0);

    memset(trace, 0, sizeof(trace));
    input = (zeliard_game_level_load_input_t){
        .current_area_id = 7,
        .save_tileset_source = 0x3E,
        .save_map_source = 0xFF,
    };
    ok &= expect_size("game_level_load_trace:edge:count",
                      zeliard_game_resolve_level_load_trace(trace, 3, &input),
                      3);
    ok &= expect_level_trace_event("game_level_load_trace:edge:0", &trace[0],
                                   ZELIARD_GAME_BOOT_LOAD_LEVEL, NULL,
                                   0x3000, 0x0000, 1, 7, 0);
    ok &= expect_level_trace_event("game_level_load_trace:edge:1", &trace[1],
                                   ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                   "level_tileset",
                                   0x1000, 0x3000, 5, 0, 0xA4B8);
    ok &= expect_level_trace_event("game_level_load_trace:edge:2", &trace[2],
                                   ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                   "level_map",
                                   0x1000, 0x4000, 2, 0, 0xAE84);
    ok &= expect_size("game_level_load_trace:null",
                      zeliard_game_resolve_level_load_trace(trace, 3, NULL),
                      0);
    ok &= expect_size("game_level_load_trace:small_buffer",
                      zeliard_game_resolve_level_load_trace(trace, 2, &input),
                      0);
    return ok;
}

static int expect_boot_clears(const char *label,
                              const zeliard_game_bootstrap_plan_t *plan) {
    static const u16 offsets[16] = {
        0xFF39, 0xFF3A, 0xFF43, 0xFF44,
        0xFF3C, 0xFF3D, 0xFF38, 0xFF36,
        0xFF3E, 0xFF4B, 0xFF08, 0x00E7,
        0xFF74, 0xFF77, 0xFF40, 0xFF42,
    };
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:clear_count", label);
    ok &= expect_size(full_label, plan->state_clear_count, 16);
    for (u8 i = 0; i < 16 && i < plan->state_clear_count; ++i) {
        snprintf(full_label, sizeof(full_label), "%s:clear%u:offset", label, i);
        ok &= expect_u16(full_label, plan->state_clears[i].offset, offsets[i]);
        snprintf(full_label, sizeof(full_label), "%s:clear%u:value", label, i);
        ok &= expect_u8(full_label, plan->state_clears[i].value, 0);
    }
    return ok;
}

static int expect_relocation(const char *label,
                             const zeliard_game_bootstrap_relocation_t *reloc,
                             u16 es_delta, u16 offset, u8 word_count, u16 addend) {
    char full_label[96];
    int ok = 1;
    snprintf(full_label, sizeof(full_label), "%s:es", label);
    ok &= expect_u16(full_label, reloc->es_delta, es_delta);
    snprintf(full_label, sizeof(full_label), "%s:offset", label);
    ok &= expect_u16(full_label, reloc->offset, offset);
    snprintf(full_label, sizeof(full_label), "%s:word_count", label);
    ok &= expect_u8(full_label, reloc->word_count, word_count);
    snprintf(full_label, sizeof(full_label), "%s:addend", label);
    ok &= expect_u16(full_label, reloc->addend, addend);
    return ok;
}

static int run_bootstrap_new_game_case(void) {
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = false,
        .gfx_mode = 4,
    };
    zeliard_game_bootstrap_trace_event_t trace[15] = {0};
    zeliard_game_bootstrap_effect_event_t effects[40] = {0};
    zeliard_game_bootstrap_plan_t plan = {0};
    int ok = expect_size("game_boot_trace:new:count",
                         zeliard_game_resolve_bootstrap_trace(trace, 15, &input), 3);
    ok &= expect_boot_trace_event("game_boot_trace:new:0", &trace[0],
                                  ZELIARD_GAME_BOOT_LOAD_CHUNK, "font.grp",
                                  0x0000, 0xF500, 2, 0);
    ok &= expect_boot_trace_event("game_boot_trace:new:1", &trace[1],
                                  ZELIARD_GAME_BOOT_LOAD_CHUNK, "gdmcga.bin",
                                  0x0000, 0x3000, 3, 0);
    ok &= expect_boot_trace_event("game_boot_trace:new:2", &trace[2],
                                  ZELIARD_GAME_BOOT_LOAD_CHUNK, "opdemo.bin",
                                  0x0000, 0x6000, 3, 0);
    ok &= expect_size("game_boot_effect_trace:new:count",
                      zeliard_game_resolve_bootstrap_effect_trace(effects, 40, &input),
                      19);
    ok &= expect_boot_effect_state("game_boot_effect_trace:new:0", &effects[0],
                                   0xFF39, 0);
    ok &= expect_boot_effect_state("game_boot_effect_trace:new:13", &effects[13],
                                   0xFF77, 0);
    ok &= expect_boot_effect_relocation("game_boot_effect_trace:new:16",
                                        &effects[16], 0x0000, 0xF500, 3,
                                        0xF500);
    ok &= expect_boot_effect_state("game_boot_effect_trace:new:17", &effects[17],
                                   0xFF77, 0xFF);
    ok &= expect_boot_effect_branch("game_boot_effect_trace:new:18", &effects[18],
                                    ZELIARD_GAME_BOOT_BRANCH_OPDEMO);
    ok &= expect_bool("game_boot:new:resolved",
                         zeliard_game_resolve_bootstrap_plan(&plan, &input), true);
    ok &= expect_size("game_boot:new:count", plan.call_count, 3);
    ok &= expect_boot_call("game_boot:new:0", &plan.calls[0],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "font.grp", 0x0000, 0xF500, 2, 0);
    ok &= expect_boot_call("game_boot:new:1", &plan.calls[1],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "gdmcga.bin", 0x0000, 0x3000, 3, 0);
    ok &= expect_boot_call("game_boot:new:2", &plan.calls[2],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "opdemo.bin", 0x0000, 0x6000, 3, 0);
    ok &= expect_boot_clears("game_boot:new", &plan);
    ok &= expect_size("game_boot:new:relocation_count", plan.relocation_count, 1);
    ok &= expect_relocation("game_boot:new:reloc0", &plan.relocations[0],
                            0x0000, 0xF500, 3, 0xF500);
    ok &= expect_u8("game_boot:new:cinematic", plan.cinematic_active, 0xFF);
    ok &= expect_bool("game_boot:new:jumps_opdemo", plan.jumps_to_opdemo, true);
    ok &= expect_bool("game_boot:new:jumps_loop", plan.jumps_to_game_loop, false);
    return ok;
}

static int run_bootstrap_saved_game_case(void) {
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = true,
        .gfx_mode = 1,
        .sword = 0,
        .current_area_id = 3,
        .save_tileset_source = 0x0A,
        .save_map_source = 0x03,
    };
    zeliard_game_bootstrap_trace_event_t trace[15] = {0};
    zeliard_game_bootstrap_effect_event_t effects[40] = {0};
    zeliard_game_bootstrap_plan_t plan = {0};
    int ok = expect_size("game_boot_trace:saved:count",
                         zeliard_game_resolve_bootstrap_trace(trace, 15, &input), 15);
    ok &= expect_boot_trace_event("game_boot_trace:saved:0", &trace[0],
                                  ZELIARD_GAME_BOOT_LOAD_CHUNK, "font.grp",
                                  0x0000, 0xF500, 2, 0);
    ok &= expect_boot_trace_event("game_boot_trace:saved:1", &trace[1],
                                  ZELIARD_GAME_BOOT_LOAD_CHUNK, "gdcga.bin",
                                  0x0000, 0x3000, 3, 0);
    ok &= expect_boot_trace_event("game_boot_trace:saved:10", &trace[10],
                                  ZELIARD_GAME_BOOT_LOAD_ARCHIVE, NULL,
                                  0x2000, 0x1800, 4, 0);
    ok &= expect_boot_trace_event("game_boot_trace:saved:12", &trace[12],
                                  ZELIARD_GAME_BOOT_LOAD_LEVEL, NULL,
                                  0x3000, 0x0000, 1, 3);
    ok &= expect_u16("game_boot_trace:saved:13:ref", trace[13].ref_offset, 0xA39A);
    ok &= expect_u16("game_boot_trace:saved:14:ref", trace[14].ref_offset, 0xA3B0);
    ok &= expect_size("game_boot_effect_trace:saved:count",
                      zeliard_game_resolve_bootstrap_effect_trace(effects, 40, &input),
                      21);
    ok &= expect_boot_effect_state("game_boot_effect_trace:saved:0", &effects[0],
                                   0xFF39, 0);
    ok &= expect_boot_effect_relocation("game_boot_effect_trace:saved:16",
                                        &effects[16], 0x0000, 0xF500, 3,
                                        0xF500);
    ok &= expect_boot_effect_relocation("game_boot_effect_trace:saved:17",
                                        &effects[17], 0x1000, 0xE200, 7,
                                        0xE200);
    ok &= expect_boot_effect_relocation("game_boot_effect_trace:saved:18",
                                        &effects[18], 0x2000, 0x1800, 3,
                                        0x1800);
    ok &= expect_boot_effect_game_init("game_boot_effect_trace:saved:19",
                                       &effects[19], 0x4000);
    ok &= expect_boot_effect_branch("game_boot_effect_trace:saved:20",
                                    &effects[20],
                                    ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP);
    ok &= expect_bool("game_boot:saved:resolved",
                         zeliard_game_resolve_bootstrap_plan(&plan, &input), true);
    ok &= expect_size("game_boot:saved:count", plan.call_count, 15);
    ok &= expect_boot_call("game_boot:saved:0", &plan.calls[0],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "font.grp", 0x0000, 0xF500, 2, 0);
    ok &= expect_boot_call("game_boot:saved:1", &plan.calls[1],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "gdcga.bin", 0x0000, 0x3000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:2", &plan.calls[2],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "gtcga.bin", 0x0000, 0x3000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:3", &plan.calls[3],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "town.bin", 0x0000, 0x6000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:4", &plan.calls[4],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "gfcga.bin", 0x2000, 0x9000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:5", &plan.calls[5],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "fight.bin", 0x2000, 0xC000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:6", &plan.calls[6],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "select.bin", 0x1000, 0xC000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:7", &plan.calls[7],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "itemp.grp", 0x1000, 0xE200, 2, 0);
    ok &= expect_boot_call("game_boot:saved:8", &plan.calls[8],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "magic.grp", 0x2000, 0x0000, 2, 0);
    ok &= expect_boot_call("game_boot:saved:9", &plan.calls[9],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "sword.grp", 0x2000, 0x1800, 2, 0);
    ok &= expect_boot_call("game_boot:saved:10", &plan.calls[10],
                           ZELIARD_GAME_BOOT_LOAD_ARCHIVE, NULL, 0x2000, 0x1800, 4, 0);
    ok &= expect_boot_call("game_boot:saved:11", &plan.calls[11],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "mole.bin", 0x3000, 0x0000, 3, 0);
    ok &= expect_boot_call("game_boot:saved:12", &plan.calls[12],
                           ZELIARD_GAME_BOOT_LOAD_LEVEL, NULL, 0x3000, 0x0000, 1, 3);
    ok &= expect_boot_call("game_boot:saved:13", &plan.calls[13],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "level_tileset", 0x1000, 0x3000, 5, 0);
    ok &= expect_u16("game_boot:saved:13:ref", plan.calls[13].ref_offset, 0xA39A);
    ok &= expect_boot_call("game_boot:saved:14", &plan.calls[14],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "level_map", 0x1000, 0x4000, 2, 0);
    ok &= expect_u16("game_boot:saved:14:ref", plan.calls[14].ref_offset, 0xA3B0);
    ok &= expect_u8("game_boot:saved:tileset", plan.player_tileset, 5);
    ok &= expect_size("game_boot:saved:music_count", plan.music_plan.load_count, 0);
    ok &= expect_size("game_boot:saved:driver_count", plan.driver_call_count, 0);
    ok &= expect_boot_clears("game_boot:saved", &plan);
    ok &= expect_size("game_boot:saved:relocation_count", plan.relocation_count, 3);
    ok &= expect_relocation("game_boot:saved:reloc0", &plan.relocations[0],
                            0x0000, 0xF500, 3, 0xF500);
    ok &= expect_relocation("game_boot:saved:reloc1", &plan.relocations[1],
                            0x1000, 0xE200, 7, 0xE200);
    ok &= expect_relocation("game_boot:saved:reloc2", &plan.relocations[2],
                            0x2000, 0x1800, 3, 0x1800);
    ok &= expect_u16("game_boot:saved:game_init_fn_segment",
                     plan.game_init_fn_segment, 0x4000);
    ok &= expect_u8("game_boot:saved:cinematic", plan.cinematic_active, 0);
    ok &= expect_bool("game_boot:saved:jumps_opdemo", plan.jumps_to_opdemo, false);
    ok &= expect_bool("game_boot:saved:jumps_loop", plan.jumps_to_game_loop, true);
    return ok;
}

static int run_bootstrap_saved_optional_case(void) {
    static const u16 refs[3] = {0x0F00, 0x3D00, 0x1500};
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = true,
        .gfx_mode = 1,
        .sword = 0x12,
        .shield = 0x34,
        .selected_spell = 0x56,
        .music_track_count = 3,
        .current_area_id = 3,
        .save_tileset_source = 0x0A,
        .save_map_source = 0x03,
    };
    zeliard_game_bootstrap_trace_event_t trace[15] = {0};
    zeliard_game_bootstrap_effect_event_t effects[40] = {0};
    zeliard_game_bootstrap_plan_t plan = {0};
    int ok = expect_size("game_boot_trace:optional:count",
                         zeliard_game_resolve_bootstrap_trace(trace, 15, &input), 15);
    ok &= expect_boot_trace_event("game_boot_trace:optional:10", &trace[10],
                                  ZELIARD_GAME_BOOT_LOAD_ARCHIVE, NULL,
                                  0x2000, 0x1800, 4, 0x12);
    ok &= expect_size("game_boot_effect_trace:optional:count",
                      zeliard_game_resolve_bootstrap_effect_trace(effects, 40, &input),
                      27);
    ok &= expect_boot_effect_music("game_boot_effect_trace:optional:20",
                                   &effects[20], 0, 0x0F00, 0);
    ok &= expect_boot_effect_music("game_boot_effect_trace:optional:21",
                                   &effects[21], 1, 0x3D00, 0);
    ok &= expect_boot_effect_music("game_boot_effect_trace:optional:22",
                                   &effects[22], 2, 0x1500, 0);
    ok &= expect_boot_effect_driver("game_boot_effect_trace:optional:23",
                                    &effects[23], 0, 0x12, 0x18AB);
    ok &= expect_boot_effect_driver("game_boot_effect_trace:optional:24",
                                    &effects[24], 2, 0x34, 0x3EA4);
    ok &= expect_boot_effect_driver("game_boot_effect_trace:optional:25",
                                    &effects[25], 1, 0x56, 0x37A4);
    ok &= expect_boot_effect_branch("game_boot_effect_trace:optional:26",
                                    &effects[26],
                                    ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP);
    ok &= expect_bool("game_boot:optional:resolved",
                         zeliard_game_resolve_bootstrap_plan(&plan, &input), true);
    ok &= expect_size("game_boot:optional:count", plan.call_count, 15);
    ok &= expect_boot_call("game_boot:optional:1", &plan.calls[1],
                           ZELIARD_GAME_BOOT_LOAD_CHUNK, "gdcga.bin", 0x0000, 0x3000, 3, 0);
    ok &= expect_boot_call("game_boot:optional:10", &plan.calls[10],
                           ZELIARD_GAME_BOOT_LOAD_ARCHIVE, NULL, 0x2000, 0x1800, 4, 0x12);
    ok &= expect_size("game_boot:optional:music_count", plan.music_plan.load_count, 3);
    for (u8 i = 0; i < 3; ++i) {
        char label[80];
        snprintf(label, sizeof(label), "game_boot:optional:music%u:index", i);
        ok &= expect_u8(label, plan.music_plan.loads[i].track_index, i);
        snprintf(label, sizeof(label), "game_boot:optional:music%u:ref", i);
        ok &= expect_u16(label, plan.music_plan.loads[i].track_ref, refs[i]);
        snprintf(label, sizeof(label), "game_boot:optional:music%u:bg", i);
        ok &= expect_u8(label, plan.music_plan.loads[i].background_flag, 0);
    }
    ok &= expect_size("game_boot:optional:driver_count", plan.driver_call_count, 3);
    ok &= expect_driver_call("game_boot:optional:driver0", &plan.driver_calls[0],
                             0, 0x12, 0x18AB);
    ok &= expect_driver_call("game_boot:optional:driver1", &plan.driver_calls[1],
                             2, 0x34, 0x3EA4);
    ok &= expect_driver_call("game_boot:optional:driver2", &plan.driver_calls[2],
                             1, 0x56, 0x37A4);
    return ok;
}

static int run_bootstrap_driver_table_cases(void) {
    static const char *gd_names[6] = {
        "gdega.bin", "gdcga.bin", "gdcga.bin", "gdhgc.bin", "gdmcga.bin", "gdtga.bin",
    };
    static const char *gt_names[6] = {
        "gtega.bin", "gtcga.bin", "gtcga.bin", "gthgc.bin", "gtmcga.bin", "gttga.bin",
    };
    static const char *gf_names[6] = {
        "gfega.bin", "gfcga.bin", "gfcga.bin", "gfhgc.bin", "gfmcga.bin", "gftga.bin",
    };
    int ok = 1;
    for (u8 mode = 0; mode < 6; ++mode) {
        char label[96];
        zeliard_game_bootstrap_plan_t plan = {0};
        zeliard_game_bootstrap_input_t input = {
            .load_saved_game = false,
            .gfx_mode = mode,
        };
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:new_resolved", mode);
        ok &= expect_bool(label, zeliard_game_resolve_bootstrap_plan(&plan, &input), true);
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:new_gd", mode);
        ok &= expect_str(label, plan.calls[1].name, gd_names[mode]);

        memset(&plan, 0, sizeof(plan));
        input = (zeliard_game_bootstrap_input_t){
            .load_saved_game = true,
            .gfx_mode = mode,
            .current_area_id = 3,
            .save_tileset_source = 0x0A,
            .save_map_source = 0x03,
        };
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:saved_resolved", mode);
        ok &= expect_bool(label, zeliard_game_resolve_bootstrap_plan(&plan, &input), true);
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:saved_gd", mode);
        ok &= expect_str(label, plan.calls[1].name, gd_names[mode]);
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:saved_gt", mode);
        ok &= expect_str(label, plan.calls[2].name, gt_names[mode]);
        snprintf(label, sizeof(label), "game_boot:driver_tables:%u:saved_gf", mode);
        ok &= expect_str(label, plan.calls[4].name, gf_names[mode]);
    }
    return ok;
}

static int run_invalid_bootstrap_case(void) {
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = true,
        .gfx_mode = 6,
    };
    zeliard_game_bootstrap_trace_event_t trace[15] = {0};
    zeliard_game_bootstrap_effect_event_t effects[40] = {0};
    zeliard_game_bootstrap_plan_t plan = {0};
    int ok = expect_size("game_boot_trace:invalid_mode",
                         zeliard_game_resolve_bootstrap_trace(trace, 15, &input), 0);
    ok &= expect_size("game_boot_effect_trace:invalid_mode",
                      zeliard_game_resolve_bootstrap_effect_trace(effects, 40, &input),
                      0);
    ok &= expect_bool("game_boot:invalid_mode",
                      zeliard_game_resolve_bootstrap_plan(&plan, &input), false);
    return ok;
}

typedef struct {
    size_t special_call_count;
    zeliard_game_bootstrap_call_t special_calls[4];
} exec_fixture_t;

static u8 *make_raw_chunk(const u8 *payload, size_t payload_size, size_t *size) {
    u8 *chunk = (u8 *)malloc(payload_size + 4);
    if (!chunk) {
        return NULL;
    }
    chunk[0] = (u8)payload_size;
    chunk[1] = (u8)(payload_size >> 8);
    chunk[2] = (u8)(payload_size >> 16);
    chunk[3] = (u8)(payload_size >> 24);
    memcpy(chunk + 4, payload, payload_size);
    *size = payload_size + 4;
    return chunk;
}

static u8 *make_fill_chunk(const u8 *payload, size_t payload_size, size_t *size) {
    /* SAR header, flag=0, fill_buffer opcode 0, then verbatim payload. */
    const size_t chunk_data_size = payload_size + 2;
    u8 *chunk = (u8 *)malloc(payload_size + 6);
    if (!chunk) {
        return NULL;
    }
    chunk[0] = (u8)chunk_data_size;
    chunk[1] = (u8)(chunk_data_size >> 8);
    chunk[2] = (u8)(chunk_data_size >> 16);
    chunk[3] = (u8)(chunk_data_size >> 24);
    chunk[4] = 0;
    chunk[5] = 0;
    memcpy(chunk + 6, payload, payload_size);
    *size = payload_size + 6;
    return chunk;
}

static bool exec_fetch_asset(void *context, const char *name,
                             u8 **data, size_t *size) {
    (void)context;
    static const u8 font[] = {1, 0, 2, 0, 3, 0};
    static const u8 itemp[] = {
        1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0,
    };
    static const u8 sword[] = {8, 0, 9, 0, 10, 0};
    static const u8 raw[] = {0xA5, 0x5A, 0xC3};
    if (strcmp(name, "font.grp") == 0) {
        *data = make_fill_chunk(font, sizeof(font), size);
    } else if (strcmp(name, "itemp.grp") == 0) {
        *data = make_fill_chunk(itemp, sizeof(itemp), size);
    } else if (strcmp(name, "sword.grp") == 0) {
        *data = make_fill_chunk(sword, sizeof(sword), size);
    } else if (strcmp(name, "magic.grp") == 0 ||
               strcmp(name, "level_map") == 0) {
        *data = make_fill_chunk(raw, sizeof(raw), size);
    } else {
        *data = make_raw_chunk(raw, sizeof(raw), size);
    }
    return *data != NULL;
}

static bool exec_loader_service(void *context,
                                const zeliard_game_bootstrap_call_t *call,
                                zeliard_game_exec_state_t *state) {
    exec_fixture_t *fixture = (exec_fixture_t *)context;
    if (fixture->special_call_count >= 4) {
        return false;
    }
    fixture->special_calls[fixture->special_call_count++] = *call;
    if (call->kind == ZELIARD_GAME_BOOT_LOAD_CHUNK && call->al == 5) {
        state->segment[1][call->dest_offset] = 0x5A;
    } else if (call->kind == ZELIARD_GAME_BOOT_LOAD_CHUNK && call->al == 2) {
        state->segment[1][call->dest_offset] = 0xA5;
    }
    return true;
}

static void init_exec_state(zeliard_game_exec_state_t *state,
                            u8 segments[ZELIARD_GAME_SEGMENT_COUNT]
                                       [ZELIARD_GAME_SEGMENT_SIZE]) {
    memset(state, 0, sizeof(*state));
    memset(segments, 0xCC, ZELIARD_GAME_SEGMENT_COUNT * ZELIARD_GAME_SEGMENT_SIZE);
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        state->segment[i] = segments[i];
        state->segment_size[i] = ZELIARD_GAME_SEGMENT_SIZE;
    }
    /* game.bin:game_init_fn at CS:A470 is 0000:3000 before start_load_game. */
    segments[0][0xA470] = 0;
    segments[0][0xA471] = 0;
    segments[0][0xA472] = 0;
    segments[0][0xA473] = 0x30;
}

static int run_execute_new_game_case(void) {
    static u8 segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE];
    zeliard_game_exec_state_t state;
    exec_fixture_t fixture = {0};
    const zeliard_game_exec_services_t services = {
        .context = &fixture,
        .fetch_asset = exec_fetch_asset,
        .loader_service = exec_loader_service,
    };
    const zeliard_game_bootstrap_input_t input = {
        .load_saved_game = false,
        .gfx_mode = 4,
    };
    init_exec_state(&state, segments);
    int ok = expect_bool("game_exec:new:execute",
                         zeliard_game_execute_bootstrap(&state, &input, &services), true);
    ok &= expect_u16("game_exec:new:font_ptr0",
                     (u16)(segments[0][0xF500] | segments[0][0xF501] << 8), 0xF501);
    ok &= expect_u16("game_exec:new:font_ptr1",
                     (u16)(segments[0][0xF502] | segments[0][0xF503] << 8), 0xF502);
    ok &= expect_u16("game_exec:new:font_ptr2",
                     (u16)(segments[0][0xF504] | segments[0][0xF505] << 8), 0xF503);
    ok &= expect_u8("game_exec:new:gd_header_stripped", segments[0][0x3000], 0xA5);
    ok &= expect_u8("game_exec:new:opdemo_header_stripped", segments[0][0x6000], 0xA5);
    ok &= expect_u8("game_exec:new:cinematic", segments[0][0xFF77], 0xFF);
    ok &= expect_size("game_exec:new:event_count", state.event_count, 23);
    ok &= expect_bool("game_exec:new:branched", state.branched, true);
    ok &= expect_u8("game_exec:new:branch", (u8)state.branch_target,
                    ZELIARD_GAME_BOOT_BRANCH_OPDEMO);
    ok &= expect_size("game_exec:new:special_count", fixture.special_call_count, 0);
    return ok;
}

static int run_execute_post_opening_case(void) {
    static u8 segments[ZELIARD_GAME_SEGMENT_COUNT][ZELIARD_GAME_SEGMENT_SIZE];
    zeliard_game_exec_state_t state;
    exec_fixture_t fixture = {0};
    const zeliard_game_exec_services_t services = {
        .context = &fixture,
        .fetch_asset = exec_fetch_asset,
        .loader_service = exec_loader_service,
    };
    const zeliard_game_bootstrap_input_t input = {
        /* 100OPDMO:transition_out_to_game sets AX=FFFFh before jmp CS:[6A73]. */
        .load_saved_game = true,
        .gfx_mode = 4,
        .current_area_id = 0,
        .save_tileset_source = 0x0A,
        .save_map_source = 0x03,
    };
    init_exec_state(&state, segments);
    int ok = expect_bool("game_exec:post_opening:execute",
                         zeliard_game_execute_bootstrap(&state, &input, &services), true);
    ok &= expect_u8("game_exec:post_opening:town", segments[0][0x6000], 0xA5);
    ok &= expect_u8("game_exec:post_opening:gf", segments[2][0x9000], 0xA5);
    ok &= expect_u8("game_exec:post_opening:fight", segments[2][0xC000], 0xA5);
    ok &= expect_u8("game_exec:post_opening:select", segments[1][0xC000], 0xA5);
    ok &= expect_u16("game_exec:post_opening:itemp_ptr0",
                     (u16)(segments[1][0xE200] | segments[1][0xE201] << 8), 0xE201);
    ok &= expect_u16("game_exec:post_opening:itemp_ptr6",
                     (u16)(segments[1][0xE20C] | segments[1][0xE20D] << 8), 0xE207);
    ok &= expect_u16("game_exec:post_opening:sword_ptr0",
                     (u16)(segments[2][0x1800] | segments[2][0x1801] << 8), 0x1808);
    ok &= expect_u16("game_exec:post_opening:game_init_segment",
                     (u16)(segments[0][0xA472] | segments[0][0xA473] << 8), 0x4000);
    ok &= expect_u8("game_exec:post_opening:tileset_service", segments[1][0x3000], 0x5A);
    ok &= expect_u8("game_exec:post_opening:map", segments[1][0x4000], 0xA5);
    ok &= expect_size("game_exec:post_opening:special_count",
                      fixture.special_call_count, 4);
    ok &= expect_size("game_exec:post_opening:event_count", state.event_count, 38);
    ok &= expect_bool("game_exec:post_opening:branched", state.branched, true);
    ok &= expect_u8("game_exec:post_opening:branch", (u8)state.branch_target,
                    ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP);
    return ok;
}

int main(void) {
    int ok = 1;
    ok &= run_zero_case();
    ok &= run_first_three_case();
    ok &= run_all_tracks_case();
    ok &= run_invalid_case();
    ok &= run_ega_palette_case();
    ok &= run_noop_palette_cases();
    ok &= run_mcga_palette_case();
    ok &= run_invalid_palette_case();
    ok &= run_level_load_trace_cases();
    ok &= run_bootstrap_new_game_case();
    ok &= run_bootstrap_saved_game_case();
    ok &= run_bootstrap_saved_optional_case();
    ok &= run_bootstrap_driver_table_cases();
    ok &= run_invalid_bootstrap_case();
    ok &= run_execute_new_game_case();
    ok &= run_execute_post_opening_case();
    printf("VERDICT: %s: game loader native parity\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
