#include "zeliad_loader.h"

#include <stddef.h>
#include <string.h>

bool zeliard_parse_startup_save_arg(const char *command_tail, size_t tail_len,
                                    char *save_filename, size_t save_filename_cap) {
    static const char suffix[] = ".USR";
    size_t out = 0;
    bool has_content = false;

    if (save_filename_cap == 0) {
        return false;
    }
    save_filename[0] = '\0';

    for (size_t i = 0; i < tail_len; ++i) {
        char ch = command_tail[i];
        if (ch == ' ' || ch == '\r') {
            continue;
        }
        has_content = true;
        if (out + 1 >= save_filename_cap) {
            return false;
        }
        save_filename[out++] = ch;
    }

    if (!has_content) {
        return false;
    }

    for (size_t i = 0; i < sizeof(suffix) - 1; ++i) {
        if (out + 1 >= save_filename_cap) {
            return false;
        }
        save_filename[out++] = suffix[i];
    }
    save_filename[out] = '\0';
    return true;
}

void zeliard_init_game_globals(zeliard_game_globals_t *globals,
                               const zeliard_loader_init_input_t *input) {
    memset(globals, 0, sizeof(*globals));

    globals->chunk_load_fn = ZELIARD_ZELIAD_CALLBACK_OFS;
    globals->chunk_load_seg = input->zeliad_code_seg;
    globals->old_int08_ofs = input->old_int08_ofs;
    globals->old_int08_seg = input->old_int08_seg;
    globals->old_int09_ofs = input->old_int09_ofs;
    globals->old_int09_seg = input->old_int09_seg;

    globals->enable_all = 0xFF;
    globals->key_released = 0xFF;
    globals->save_flag = 5;
    globals->last_key = input->joystick_enabled;
    globals->game_phase = input->mt32_enabled;
    globals->gfx_mode = input->graphics_mode;
    globals->game_seg = (u16)(input->game_entry_seg + 0x1000);

    if (input->cmdline_savefile != NULL) {
        for (size_t i = 0; i < sizeof(globals->save_name_buf); ++i) {
            char ch = input->cmdline_savefile[i];
            if (ch == '\0' || ch == '.') {
                break;
            }
            if (ch >= 'a' && ch < '{') {
                ch = (char)(ch & 0x5F);
            }
            globals->save_name_buf[i] = (u8)ch;
        }
    }
}

static bool append_loader_trace_event(zeliard_loader_trace_event_t *out,
                                      size_t max_events,
                                      size_t *count,
                                      u16 es,
                                      u16 di,
                                      u16 load_offset,
                                      const char *filename) {
    if (*count >= max_events) {
        return false;
    }
    out[*count] = (zeliard_loader_trace_event_t){
        .kind = ZELIARD_LOADER_TRACE_LOAD_FILE,
        .es = es,
        .di = di,
        .load_offset = load_offset,
        .filename = filename,
    };
    ++*count;
    return true;
}

size_t zeliard_resolve_loader_trace(zeliard_loader_trace_event_t *out,
                                    size_t max_events,
                                    const zeliard_loader_plan_input_t *input) {
    static const char *const gfx_driver_by_mode[6] = {
        "gmega.bin",
        "gmcga.bin",
        "gmcga.bin",
        "gmhgc.bin",
        "gmmcga.bin",
        "gmtga.bin",
    };
    static const u16 gfx_descriptor_by_mode[6] = {
        0x0812, 0x081E, 0x081E, 0x082A, 0x0836, 0x0843,
    };

    if (out == NULL || input == NULL || input->graphics_mode >= 6) {
        return 0;
    }

    const char *player_file = "stdply.bin";
    u16 player_descriptor = 0x085A;
    if (input->save_filename != NULL && input->save_filename[0] != '\0') {
        player_file = input->save_filename;
        player_descriptor = 0x0867;
    }

    const u16 driver_seg = (u16)(input->game_entry_seg + 0x0FF0);
    size_t count = 0;

    if (!append_loader_trace_event(out, max_events, &count,
                                   input->game_entry_seg, player_descriptor,
                                   0x0000, player_file) ||
        !append_loader_trace_event(out, max_events, &count,
                                   input->game_entry_seg, 0x0806,
                                   0x0100, "stick.bin") ||
        !append_loader_trace_event(out, max_events, &count,
                                   input->game_entry_seg, 0x084F,
                                   0xA000, "game.bin") ||
        !append_loader_trace_event(out, max_events, &count,
                                   input->game_entry_seg,
                                   gfx_descriptor_by_mode[input->graphics_mode],
                                   0x2000,
                                   gfx_driver_by_mode[input->graphics_mode]) ||
        !append_loader_trace_event(out, max_events, &count,
                                   driver_seg, 0x0889,
                                   0x0100, input->music_driver_name) ||
        !append_loader_trace_event(out, max_events, &count,
                                   driver_seg, 0x089B,
                                   0x1100, input->joystick_driver_name)) {
        return 0;
    }

    return count;
}

bool zeliard_resolve_loader_plan(zeliard_loader_plan_t *plan,
                                 const zeliard_loader_plan_input_t *input) {
    if (plan == NULL) {
        return false;
    }

    zeliard_loader_trace_event_t trace[6];
    const size_t count = zeliard_resolve_loader_trace(trace, 6, input);
    if (count != 6) {
        plan->file_count = 0;
        return false;
    }

    plan->file_count = count;
    for (size_t i = 0; i < count; ++i) {
        plan->files[i] = (zeliard_loader_file_entry_t){
            .segment = trace[i].es,
            .descriptor_offset = trace[i].di,
            .offset = trace[i].load_offset,
            .filename = trace[i].filename,
        };
    }
    return true;
}

zeliard_video_mode_plan_t zeliard_resolve_video_mode_plan(u8 graphics_mode) {
    static const u16 int10_ax_by_mode[6] = {
        0x000E,
        0x0005,
        0x0006,
        0x0000,
        0x0013,
        0x0009,
    };

    zeliard_video_mode_plan_t plan = {
        .kind = ZELIARD_VIDEO_MODE_INVALID,
        .int10_ax = 0,
        .hgc_clear_segment = 0,
        .hgc_clear_words = 0,
    };

    if (graphics_mode >= 6) {
        return plan;
    }

    if (graphics_mode == 3) {
        plan.kind = ZELIARD_VIDEO_MODE_HGC;
        plan.hgc_clear_segment = 0xB000;
        plan.hgc_clear_words = 0x4000;
        return plan;
    }

    plan.kind = ZELIARD_VIDEO_MODE_INT10;
    plan.int10_ax = int10_ax_by_mode[graphics_mode];
    return plan;
}
