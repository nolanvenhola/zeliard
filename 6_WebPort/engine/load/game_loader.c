#include "game_loader.h"

#include "fill_buffer.h"

#include <stdlib.h>
#include <string.h>

enum {
    GAME_REF_LEVEL_TILESET_BASE = 0xA363,
    GAME_REF_LEVEL_MAP_BASE = 0xA38F,
    GAME_MUSIC_PLAYER_FN = 0x18AB,
    GAME_GFX_CALL_A_SLOT = 0,
    GAME_GFX_CALL_B_SLOT = 1,
    GAME_GFX_CALL_C_SLOT = 2,
    GAME_TILE_GFX_BASE = 0x37A4,
    GAME_FONT_GFX_BASE = 0x3EA4,
    GAME_CODE_SEG = 0x1000,
};

static bool add_boot_call(zeliard_game_bootstrap_plan_t *plan,
                          zeliard_game_bootstrap_call_kind_t kind,
                          const char *name, u16 es_delta, u16 dest_offset,
                          u8 al, u8 ah, u16 ref_offset) {
    if (plan->call_count >= sizeof(plan->calls) / sizeof(plan->calls[0])) {
        return false;
    }
    plan->calls[plan->call_count++] = (zeliard_game_bootstrap_call_t){
        .kind = kind,
        .es_delta = es_delta,
        .dest_offset = dest_offset,
        .ref_offset = ref_offset,
        .al = al,
        .ah = ah,
        .name = name,
    };
    return true;
}

static bool append_bootstrap_trace_event(zeliard_game_bootstrap_trace_event_t *out,
                                         size_t max_events,
                                         size_t *count,
                                         zeliard_game_bootstrap_call_kind_t kind,
                                         const char *name,
                                         u16 es_delta,
                                         u16 dest_offset,
                                         u8 al,
                                         u8 ah,
                                         u16 ref_offset) {
    if (*count >= max_events) {
        return false;
    }
    out[*count] = (zeliard_game_bootstrap_trace_event_t){
        .kind = kind,
        .es_delta = es_delta,
        .dest_offset = dest_offset,
        .ref_offset = ref_offset,
        .al = al,
        .ah = ah,
        .name = name,
    };
    ++*count;
    return true;
}

static bool append_level_load_trace_event(zeliard_game_level_load_trace_event_t *out,
                                          size_t max_events,
                                          size_t *count,
                                          zeliard_game_bootstrap_call_kind_t kind,
                                          const char *name,
                                          u16 es_delta,
                                          u16 dest_offset,
                                          u8 al,
                                          u8 ah,
                                          u16 ref_offset) {
    if (*count >= max_events) {
        return false;
    }
    out[*count] = (zeliard_game_level_load_trace_event_t){
        .kind = kind,
        .es_delta = es_delta,
        .dest_offset = dest_offset,
        .ref_offset = ref_offset,
        .al = al,
        .ah = ah,
        .name = name,
    };
    ++*count;
    return true;
}

static bool add_driver_call(zeliard_game_bootstrap_plan_t *plan,
                            u8 slot, u8 al, u16 bx) {
    if (plan->driver_call_count >= sizeof(plan->driver_calls) / sizeof(plan->driver_calls[0])) {
        return false;
    }
    plan->driver_calls[plan->driver_call_count++] =
        (zeliard_game_bootstrap_driver_call_t){
            .slot = slot,
            .al = al,
            .bx = bx,
        };
    return true;
}

static bool add_state_clear(zeliard_game_bootstrap_plan_t *plan, u16 offset) {
    if (plan->state_clear_count >=
        sizeof(plan->state_clears) / sizeof(plan->state_clears[0])) {
        return false;
    }
    plan->state_clears[plan->state_clear_count++] =
        (zeliard_game_bootstrap_state_write_t){
            .offset = offset,
            .value = 0,
        };
    return true;
}

static bool add_relocation(zeliard_game_bootstrap_plan_t *plan, u16 es_delta,
                           u16 offset, u8 word_count, u16 addend) {
    if (plan->relocation_count >=
        sizeof(plan->relocations) / sizeof(plan->relocations[0])) {
        return false;
    }
    plan->relocations[plan->relocation_count++] =
        (zeliard_game_bootstrap_relocation_t){
            .es_delta = es_delta,
            .offset = offset,
            .word_count = word_count,
            .addend = addend,
        };
    return true;
}

static bool append_bootstrap_effect(zeliard_game_bootstrap_effect_event_t *out,
                                    size_t max_events,
                                    size_t *count,
                                    zeliard_game_bootstrap_effect_event_t event) {
    if (*count >= max_events) {
        return false;
    }
    out[*count] = event;
    ++*count;
    return true;
}

size_t zeliard_game_resolve_music_trace(zeliard_game_music_trace_event_t *out,
                                        size_t max_events,
                                        u8 music_track_count) {
    static const u16 track_refs[9] = {
        0x0F00,
        0x3D00,
        0x1500,
        0x3700,
        0x1B00,
        0x3100,
        0x2100,
        0x2B00,
        0x2600,
    };

    if (out == NULL || music_track_count > 9 || max_events < music_track_count) {
        return 0;
    }

    for (u8 i = 0; i < music_track_count; ++i) {
        out[i] = (zeliard_game_music_trace_event_t){
            .track_ref = track_refs[i],
            .track_index = i,
            .background_flag = (i == 8) ? 1u : 0u,
        };
    }
    return music_track_count;
}

bool zeliard_game_resolve_music_plan(zeliard_game_music_plan_t *plan,
                                     u8 music_track_count) {
    if (plan == NULL) {
        return false;
    }

    zeliard_game_music_trace_event_t trace[9];
    const size_t count = zeliard_game_resolve_music_trace(
        trace, sizeof(trace) / sizeof(trace[0]), music_track_count);
    if (count != music_track_count) {
        plan->load_count = 0;
        return false;
    }

    plan->load_count = count;
    for (size_t i = 0; i < count; ++i) {
        plan->loads[i] = (zeliard_game_music_track_load_t){
            .track_ref = trace[i].track_ref,
            .track_index = trace[i].track_index,
            .background_flag = trace[i].background_flag,
        };
    }
    return true;
}

size_t zeliard_game_resolve_palette_trace(zeliard_game_palette_trace_event_t *out,
                                          size_t max_events,
                                          u8 gfx_mode) {
    static const u8 ega_attr_palette[17] = {
        0x00,
        0x3F, 0x24, 0x12, 0x1B, 0x09, 0x36, 0x2D, 0x38,
        0x07, 0x04, 0x02, 0x03, 0x01, 0x06, 0x05, 0x00,
    };
    static const u8 mcga_base_colors[8][3] = {
        {0x00, 0x00, 0x00},
        {0x1F, 0x1F, 0x1F},
        {0x1F, 0x00, 0x00},
        {0x00, 0x1F, 0x00},
        {0x00, 0x1F, 0x1F},
        {0x00, 0x00, 0x1F},
        {0x1F, 0x1F, 0x00},
        {0x1F, 0x00, 0x1F},
    };

    if (out == NULL) {
        return 0;
    }

    switch (gfx_mode) {
    case 0:
        if (max_events < 1) {
            return 0;
        }
        out[0] = (zeliard_game_palette_trace_event_t){
            .kind = ZELIARD_GAME_PALETTE_TRACE_EGA_ATTR,
            .interrupt_no = 0x10,
            .ax = 0x1002,
            .es_delta = 0,
            .ega_border = ega_attr_palette[0],
        };
        for (size_t i = 0; i < 16; ++i) {
            out[0].ega_regs[i] = ega_attr_palette[i + 1];
        }
        return 1;
    case 1:
    case 2:
    case 3:
    case 5:
        return 0;
    case 4:
        if (max_events < 64) {
            return 0;
        }
        for (u8 base = 0; base < 8; ++base) {
            for (u8 shade = 0; shade < 8; ++shade) {
                const u8 index = (u8)(base * 8 + shade);
                const u8 r = (u8)(mcga_base_colors[base][0] + mcga_base_colors[shade][0]);
                const u8 g = (u8)(mcga_base_colors[base][1] + mcga_base_colors[shade][1]);
                const u8 b = (u8)(mcga_base_colors[base][2] + mcga_base_colors[shade][2]);
                out[index] = (zeliard_game_palette_trace_event_t){
                    .kind = ZELIARD_GAME_PALETTE_TRACE_MCGA_DAC,
                    .interrupt_no = 0x10,
                    .ax = 0x1010,
                    .bx = index,
                    .cx = (u16)((g << 8) | b),
                    .dx = (u16)(r << 8),
                    .dac_index = index,
                    .r = r,
                    .g = g,
                    .b = b,
                };
            }
        }
        return 64;
    default:
        return 0;
    }
}

bool zeliard_game_resolve_palette_plan(zeliard_game_palette_plan_t *plan,
                                       u8 gfx_mode) {
    if (plan == NULL || gfx_mode > 5) {
        return false;
    }

    zeliard_game_palette_trace_event_t trace[64];
    const size_t count = zeliard_game_resolve_palette_trace(
        trace, sizeof(trace) / sizeof(trace[0]), gfx_mode);

    *plan = (zeliard_game_palette_plan_t){0};
    plan->kind = ZELIARD_GAME_PALETTE_NOOP;

    switch (gfx_mode) {
    case 0:
        if (count != 1 || trace[0].kind != ZELIARD_GAME_PALETTE_TRACE_EGA_ATTR) {
            return false;
        }
        plan->kind = ZELIARD_GAME_PALETTE_EGA_ATTR;
        plan->ega.border = trace[0].ega_border;
        for (size_t i = 0; i < 16; ++i) {
            plan->ega.regs[i] = trace[0].ega_regs[i];
        }
        return true;
    case 1:
    case 2:
    case 3:
    case 5:
        return count == 0;
    case 4:
        if (count != 64) {
            return false;
        }
        plan->kind = ZELIARD_GAME_PALETTE_MCGA_DAC;
        plan->mcga_count = 64;
        for (size_t i = 0; i < count; ++i) {
            plan->mcga[i] = (zeliard_game_mcga_dac_write_t){
                .index = trace[i].dac_index,
                .r = trace[i].r,
                .g = trace[i].g,
                .b = trace[i].b,
            };
        }
        return true;
    default:
        return false;
    }
}

size_t zeliard_game_resolve_level_load_trace(
    zeliard_game_level_load_trace_event_t *out,
    size_t max_events,
    const zeliard_game_level_load_input_t *input) {
    if (out == NULL || input == NULL) {
        return 0;
    }

    const u8 player_tileset = (u8)((input->save_tileset_source >> 1) & 0x1F);
    size_t count = 0;
    if (!append_level_load_trace_event(out, max_events, &count,
                                       ZELIARD_GAME_BOOT_LOAD_LEVEL, NULL,
                                       0x3000, 0x0000, 1,
                                       input->current_area_id, 0) ||
        !append_level_load_trace_event(out, max_events, &count,
                                       ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                       "level_tileset",
                                       0x1000, 0x3000, 5, 0,
                                       (u16)(GAME_REF_LEVEL_TILESET_BASE +
                                             player_tileset * 11)) ||
        !append_level_load_trace_event(out, max_events, &count,
                                       ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                       "level_map",
                                       0x1000, 0x4000, 2, 0,
                                       (u16)(GAME_REF_LEVEL_MAP_BASE +
                                             input->save_map_source * 11))) {
        return 0;
    }
    return count;
}

size_t zeliard_game_resolve_bootstrap_trace(zeliard_game_bootstrap_trace_event_t *out,
                                            size_t max_events,
                                            const zeliard_game_bootstrap_input_t *input) {
    static const char *gd_driver_by_mode[6] = {
        "gdega.bin", "gdcga.bin", "gdcga.bin", "gdhgc.bin", "gdmcga.bin", "gdtga.bin",
    };
    static const char *gt_driver_by_mode[6] = {
        "gtega.bin", "gtcga.bin", "gtcga.bin", "gthgc.bin", "gtmcga.bin", "gttga.bin",
    };
    static const char *gf_frame_by_mode[6] = {
        "gfega.bin", "gfcga.bin", "gfcga.bin", "gfhgc.bin", "gfmcga.bin", "gftga.bin",
    };

    if (out == NULL || input == NULL || input->gfx_mode > 5) {
        return 0;
    }

    size_t count = 0;

    if (!append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "font.grp",
                                      0x0000, 0xF500, 2, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                      gd_driver_by_mode[input->gfx_mode],
                                      0x0000, 0x3000, 3, 0, 0)) {
        return 0;
    }

    if (!input->load_saved_game) {
        if (!append_bootstrap_trace_event(out, max_events, &count,
                                          ZELIARD_GAME_BOOT_LOAD_CHUNK, "opdemo.bin",
                                          0x0000, 0x6000, 3, 0, 0)) {
            return 0;
        }
        return count;
    }

    if (!append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                      gt_driver_by_mode[input->gfx_mode],
                                      0x0000, 0x3000, 3, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "town.bin",
                                      0x0000, 0x6000, 3, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK,
                                      gf_frame_by_mode[input->gfx_mode],
                                      0x2000, 0x9000, 3, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "fight.bin",
                                      0x2000, 0xC000, 3, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "select.bin",
                                      0x1000, 0xC000, 3, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "itemp.grp",
                                      0x1000, 0xE200, 2, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "magic.grp",
                                      0x2000, 0x0000, 2, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "sword.grp",
                                      0x2000, 0x1800, 2, 0, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_ARCHIVE, NULL,
                                      0x2000, 0x1800, 4, input->sword, 0) ||
        !append_bootstrap_trace_event(out, max_events, &count,
                                      ZELIARD_GAME_BOOT_LOAD_CHUNK, "mole.bin",
                                      0x3000, 0x0000, 3, 0, 0)) {
        return 0;
    }

    zeliard_game_level_load_trace_event_t level_trace[3];
    const zeliard_game_level_load_input_t level_input = {
        .current_area_id = input->current_area_id,
        .save_tileset_source = input->save_tileset_source,
        .save_map_source = input->save_map_source,
    };
    const size_t level_count = zeliard_game_resolve_level_load_trace(
        level_trace, sizeof(level_trace) / sizeof(level_trace[0]), &level_input);
    if (level_count != 3) {
        return 0;
    }
    for (size_t i = 0; i < level_count; ++i) {
        if (!append_bootstrap_trace_event(out, max_events, &count,
                                          level_trace[i].kind,
                                          level_trace[i].name,
                                          level_trace[i].es_delta,
                                          level_trace[i].dest_offset,
                                          level_trace[i].al,
                                          level_trace[i].ah,
                                          level_trace[i].ref_offset)) {
            return 0;
        }
    }

    return count;
}

size_t zeliard_game_resolve_bootstrap_effect_trace(
    zeliard_game_bootstrap_effect_event_t *out,
    size_t max_events,
    const zeliard_game_bootstrap_input_t *input) {
    static const u16 boot_clear_offsets[16] = {
        0xFF39,
        0xFF3A,
        0xFF43,
        0xFF44,
        0xFF3C,
        0xFF3D,
        0xFF38,
        0xFF36,
        0xFF3E,
        0xFF4B,
        0xFF08,
        0x00E7,
        0xFF74,
        0xFF77,
        0xFF40,
        0xFF42,
    };
    zeliard_game_music_trace_event_t music_trace[9];
    size_t count = 0;

    if (out == NULL || input == NULL || input->gfx_mode > 5) {
        return 0;
    }

    for (size_t i = 0; i < sizeof(boot_clear_offsets) / sizeof(boot_clear_offsets[0]); ++i) {
        if (!append_bootstrap_effect(out, max_events, &count,
                                     (zeliard_game_bootstrap_effect_event_t){
                                         .kind = ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE,
                                         .offset = boot_clear_offsets[i],
                                         .value = 0,
                                     })) {
            return 0;
        }
    }

    if (!append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_RELOCATION,
                                     .es_delta = 0x0000,
                                     .offset = 0xF500,
                                     .word_count = 3,
                                     .addend = 0xF500,
                                 })) {
        return 0;
    }

    if (!input->load_saved_game) {
        if (!append_bootstrap_effect(out, max_events, &count,
                                     (zeliard_game_bootstrap_effect_event_t){
                                         .kind = ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE,
                                         .offset = 0xFF77,
                                         .value = 0xFF,
                                     }) ||
            !append_bootstrap_effect(out, max_events, &count,
                                     (zeliard_game_bootstrap_effect_event_t){
                                         .kind = ZELIARD_GAME_BOOT_EFFECT_BRANCH,
                                         .branch_target = ZELIARD_GAME_BOOT_BRANCH_OPDEMO,
                                     })) {
            return 0;
        }
        return count;
    }

    if (!append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_RELOCATION,
                                     .es_delta = 0x1000,
                                     .offset = 0xE200,
                                     .word_count = 7,
                                     .addend = 0xE200,
                                 }) ||
        !append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_RELOCATION,
                                     .es_delta = 0x2000,
                                     .offset = 0x1800,
                                     .word_count = 3,
                                     .addend = 0x1800,
                                 }) ||
        !append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_GAME_INIT_CALL,
                                     .segment = GAME_CODE_SEG + 0x3000,
                                 })) {
        return 0;
    }

    const size_t music_count = zeliard_game_resolve_music_trace(
        music_trace, sizeof(music_trace) / sizeof(music_trace[0]),
        input->music_track_count);
    if (music_count != input->music_track_count) {
        return 0;
    }
    for (size_t i = 0; i < music_count; ++i) {
        if (!append_bootstrap_effect(out, max_events, &count,
                                     (zeliard_game_bootstrap_effect_event_t){
                                         .kind = ZELIARD_GAME_BOOT_EFFECT_MUSIC_LOAD,
                                         .track_index = music_trace[i].track_index,
                                         .track_ref = music_trace[i].track_ref,
                                         .background_flag = music_trace[i].background_flag,
                                     })) {
            return 0;
        }
    }

    if (input->sword != 0 &&
        !append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL,
                                     .driver_slot = GAME_GFX_CALL_A_SLOT,
                                     .al = input->sword,
                                     .bx = GAME_MUSIC_PLAYER_FN,
                                 })) {
        return 0;
    }
    if (input->shield != 0 &&
        !append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL,
                                     .driver_slot = GAME_GFX_CALL_C_SLOT,
                                     .al = input->shield,
                                     .bx = GAME_FONT_GFX_BASE,
                                 })) {
        return 0;
    }
    if (input->selected_spell != 0 &&
        !append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL,
                                     .driver_slot = GAME_GFX_CALL_B_SLOT,
                                     .al = input->selected_spell,
                                     .bx = GAME_TILE_GFX_BASE,
                                 })) {
        return 0;
    }
    if (!append_bootstrap_effect(out, max_events, &count,
                                 (zeliard_game_bootstrap_effect_event_t){
                                     .kind = ZELIARD_GAME_BOOT_EFFECT_BRANCH,
                                     .branch_target = ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP,
                                 })) {
        return 0;
    }

    return count;
}

bool zeliard_game_resolve_bootstrap_plan(zeliard_game_bootstrap_plan_t *plan,
                                         const zeliard_game_bootstrap_input_t *input) {
    if (plan == NULL || input == NULL || input->gfx_mode > 5) {
        return false;
    }

    zeliard_game_bootstrap_trace_event_t trace[15];
    const size_t trace_count = zeliard_game_resolve_bootstrap_trace(
        trace, sizeof(trace) / sizeof(trace[0]), input);
    if (trace_count == 0) {
        return false;
    }

    *plan = (zeliard_game_bootstrap_plan_t){0};
    for (size_t i = 0; i < trace_count; ++i) {
        if (!add_boot_call(plan, trace[i].kind, trace[i].name, trace[i].es_delta,
                           trace[i].dest_offset, trace[i].al, trace[i].ah,
                           trace[i].ref_offset)) {
            return false;
        }
    }

    zeliard_game_bootstrap_effect_event_t effects[40];
    const size_t effect_count = zeliard_game_resolve_bootstrap_effect_trace(
        effects, sizeof(effects) / sizeof(effects[0]), input);
    if (effect_count == 0) {
        return false;
    }

    plan->player_tileset = (u8)((input->save_tileset_source >> 1) & 0x1F);
    for (size_t i = 0; i < effect_count; ++i) {
        const zeliard_game_bootstrap_effect_event_t *effect = &effects[i];
        switch (effect->kind) {
        case ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE:
            if (effect->offset == 0xFF77) {
                plan->cinematic_active = effect->value;
            }
            if (effect->value == 0 && !add_state_clear(plan, effect->offset)) {
                return false;
            }
            break;
        case ZELIARD_GAME_BOOT_EFFECT_RELOCATION:
            if (!add_relocation(plan, effect->es_delta, effect->offset,
                                effect->word_count, effect->addend)) {
                return false;
            }
            break;
        case ZELIARD_GAME_BOOT_EFFECT_MUSIC_LOAD:
            if (plan->music_plan.load_count >=
                sizeof(plan->music_plan.loads) / sizeof(plan->music_plan.loads[0])) {
                return false;
            }
            plan->music_plan.loads[plan->music_plan.load_count++] =
                (zeliard_game_music_track_load_t){
                    .track_ref = effect->track_ref,
                    .track_index = effect->track_index,
                    .background_flag = effect->background_flag,
                };
            break;
        case ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL:
            if (!add_driver_call(plan, effect->driver_slot, effect->al, effect->bx)) {
                return false;
            }
            break;
        case ZELIARD_GAME_BOOT_EFFECT_GAME_INIT_CALL:
            plan->game_init_fn_segment = effect->segment;
            break;
        case ZELIARD_GAME_BOOT_EFFECT_BRANCH:
            plan->jumps_to_opdemo =
                effect->branch_target == ZELIARD_GAME_BOOT_BRANCH_OPDEMO;
            plan->jumps_to_game_loop =
                effect->branch_target == ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP;
            break;
        default:
            return false;
        }
    }

    return true;
}

static u16 game_read_u16(const u8 *mem, u16 offset) {
    return (u16)(mem[offset] | ((u16)mem[(u16)(offset + 1)] << 8));
}

static void game_write_u16(u8 *mem, u16 offset, u16 value) {
    mem[offset] = (u8)value;
    mem[(u16)(offset + 1)] = (u8)(value >> 8);
}

static bool game_exec_log(zeliard_game_exec_state_t *state,
                          zeliard_game_exec_event_t event) {
    if (state->event_count >= ZELIARD_GAME_EXEC_EVENT_CAP) {
        return false;
    }
    state->events[state->event_count++] = event;
    return true;
}

static u8 *game_exec_segment(zeliard_game_exec_state_t *state, u16 es_delta,
                             size_t *size) {
    if ((es_delta & 0x0FFF) != 0 || es_delta > 0x3000) {
        return NULL;
    }
    const size_t index = es_delta >> 12;
    if (!state->segment[index] || state->segment_size[index] < ZELIARD_GAME_SEGMENT_SIZE) {
        return NULL;
    }
    if (size) {
        *size = state->segment_size[index];
    }
    return state->segment[index];
}

static bool game_exec_load(zeliard_game_exec_state_t *state,
                           const zeliard_game_bootstrap_call_t *call,
                           const zeliard_game_exec_services_t *services) {
    if (call->kind != ZELIARD_GAME_BOOT_LOAD_CHUNK || call->ref_offset != 0 ||
        (call->al != 2 && call->al != 3)) {
        if (!services->loader_service ||
            !services->loader_service(services->context, call, state)) {
            return false;
        }
        return game_exec_log(state, (zeliard_game_exec_event_t){
            .kind = ZELIARD_GAME_EXEC_LOAD,
            .call = *call,
        });
    }

    if (!services->fetch_asset || !call->name) {
        return false;
    }
    u8 *file_data = NULL;
    size_t file_size = 0;
    if (!services->fetch_asset(services->context, call->name,
                               &file_data, &file_size) || !file_data) {
        return false;
    }

    u8 *payload = NULL;
    size_t payload_size = 0;
    if (call->al == 2) {
        payload = fill_buffer_decompress(file_data, file_size, &payload_size);
    } else if (file_size >= 4) {
        const size_t declared = (size_t)file_data[0] |
            ((size_t)file_data[1] << 8) | ((size_t)file_data[2] << 16) |
            ((size_t)file_data[3] << 24);
        if (declared <= file_size - 4) {
            payload_size = declared;
            payload = (u8 *)malloc(payload_size ? payload_size : 1);
            if (payload && payload_size) {
                memcpy(payload, file_data + 4, payload_size);
            }
        }
    }
    free(file_data);

    size_t segment_size = 0;
    u8 *segment = game_exec_segment(state, call->es_delta, &segment_size);
    const bool fits = segment && payload &&
        payload_size <= segment_size - call->dest_offset;
    if (fits && payload_size) {
        memcpy(segment + call->dest_offset, payload, payload_size);
    }
    free(payload);
    if (!fits) {
        return false;
    }
    return game_exec_log(state, (zeliard_game_exec_event_t){
        .kind = ZELIARD_GAME_EXEC_LOAD,
        .call = *call,
    });
}

static bool game_exec_state_write(zeliard_game_exec_state_t *state,
                                  u16 offset, u8 value) {
    u8 *cs = game_exec_segment(state, 0, NULL);
    if (!cs) {
        return false;
    }
    cs[offset] = value;
    return game_exec_log(state, (zeliard_game_exec_event_t){
        .kind = ZELIARD_GAME_EXEC_STATE_WRITE,
        .effect = {
            .kind = ZELIARD_GAME_BOOT_EFFECT_STATE_WRITE,
            .offset = offset,
            .value = value,
        },
    });
}

static bool game_exec_relocate(zeliard_game_exec_state_t *state,
                               zeliard_game_bootstrap_relocation_t relocation) {
    u8 *segment = game_exec_segment(state, relocation.es_delta, NULL);
    if (!segment || (u32)relocation.offset + relocation.word_count * 2u >
                        ZELIARD_GAME_SEGMENT_SIZE) {
        return false;
    }
    for (u8 i = 0; i < relocation.word_count; ++i) {
        const u16 offset = (u16)(relocation.offset + i * 2);
        game_write_u16(segment, offset,
                       (u16)(game_read_u16(segment, offset) + relocation.addend));
    }
    return game_exec_log(state, (zeliard_game_exec_event_t){
        .kind = ZELIARD_GAME_EXEC_RELOCATION,
        .effect = {
            .kind = ZELIARD_GAME_BOOT_EFFECT_RELOCATION,
            .es_delta = relocation.es_delta,
            .offset = relocation.offset,
            .word_count = relocation.word_count,
            .addend = relocation.addend,
        },
    });
}

static bool game_exec_simple_effect(zeliard_game_exec_state_t *state,
                                    zeliard_game_exec_event_kind_t kind,
                                    zeliard_game_bootstrap_effect_event_t effect) {
    return game_exec_log(state, (zeliard_game_exec_event_t){
        .kind = kind,
        .effect = effect,
    });
}

bool zeliard_game_execute_bootstrap(zeliard_game_exec_state_t *state,
                                    const zeliard_game_bootstrap_input_t *input,
                                    const zeliard_game_exec_services_t *services) {
    zeliard_game_bootstrap_plan_t plan;
    if (!state || !input || !services ||
        !zeliard_game_resolve_bootstrap_plan(&plan, input)) {
        return false;
    }
    state->event_count = 0;
    state->branched = false;

    /* game.asm:start: font load/fixup, joystick poll, state zero pass, GD
     * load/init. The poll has no memory output in this contract. */
    if (!game_exec_load(state, &plan.calls[0], services) ||
        !game_exec_relocate(state, plan.relocations[0])) {
        return false;
    }
    for (size_t i = 0; i < plan.state_clear_count; ++i) {
        if (!game_exec_state_write(state, plan.state_clears[i].offset,
                                   plan.state_clears[i].value)) {
            return false;
        }
    }
    if (!game_exec_load(state, &plan.calls[1], services) ||
        !game_exec_simple_effect(state, ZELIARD_GAME_EXEC_GFX_INIT,
                                 (zeliard_game_bootstrap_effect_event_t){0})) {
        return false;
    }

    if (!input->load_saved_game) {
        if (!game_exec_state_write(state, 0xFF77, 0xFF) ||
            !game_exec_load(state, &plan.calls[2], services)) {
            return false;
        }
    } else {
        if (!game_exec_simple_effect(state, ZELIARD_GAME_EXEC_PALETTE,
                                     (zeliard_game_bootstrap_effect_event_t){0})) {
            return false;
        }
        for (size_t i = 2; i < plan.call_count; ++i) {
            if (!game_exec_load(state, &plan.calls[i], services)) {
                return false;
            }
            if (i == 7 && !game_exec_relocate(state, plan.relocations[1])) {
                return false;
            }
            if (i == 9 && !game_exec_relocate(state, plan.relocations[2])) {
                return false;
            }
            if (i == 11) {
                u8 *cs = game_exec_segment(state, 0, NULL);
                game_write_u16(cs, 0xA472, plan.game_init_fn_segment);
                if (!game_exec_simple_effect(state, ZELIARD_GAME_EXEC_GAME_INIT,
                        (zeliard_game_bootstrap_effect_event_t){
                            .kind = ZELIARD_GAME_BOOT_EFFECT_GAME_INIT_CALL,
                            .segment = plan.game_init_fn_segment,
                        })) {
                    return false;
                }
                for (size_t m = 0; m < plan.music_plan.load_count; ++m) {
                    const zeliard_game_music_track_load_t *music = &plan.music_plan.loads[m];
                    if (!game_exec_simple_effect(state, ZELIARD_GAME_EXEC_MUSIC_LOAD,
                            (zeliard_game_bootstrap_effect_event_t){
                                .kind = ZELIARD_GAME_BOOT_EFFECT_MUSIC_LOAD,
                                .track_index = music->track_index,
                                .track_ref = music->track_ref,
                                .background_flag = music->background_flag,
                            })) {
                        return false;
                    }
                }
                for (size_t d = 0; d < plan.driver_call_count; ++d) {
                    const zeliard_game_bootstrap_driver_call_t *driver = &plan.driver_calls[d];
                    if (!game_exec_simple_effect(state, ZELIARD_GAME_EXEC_DRIVER_CALL,
                            (zeliard_game_bootstrap_effect_event_t){
                                .kind = ZELIARD_GAME_BOOT_EFFECT_DRIVER_CALL,
                                .driver_slot = driver->slot,
                                .al = driver->al,
                                .bx = driver->bx,
                            })) {
                        return false;
                    }
                }
            }
        }
    }

    state->branch_target = input->load_saved_game
        ? ZELIARD_GAME_BOOT_BRANCH_GAME_LOOP
        : ZELIARD_GAME_BOOT_BRANCH_OPDEMO;
    state->branched = true;
    return game_exec_simple_effect(state, ZELIARD_GAME_EXEC_BRANCH,
        (zeliard_game_bootstrap_effect_event_t){
            .kind = ZELIARD_GAME_BOOT_EFFECT_BRANCH,
            .branch_target = state->branch_target,
        });
}
