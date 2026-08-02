#include "room_runtime.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/room_mcga.h"
#include "../render/town_mcga.h"

#include <stdlib.h>
#include <string.h>

enum {
    KING_SCRIPT_DELAY = 1,
    KING_SCRIPT_WAIT_INPUT,
    KING_SCRIPT_WAIT_LONG,
    KING_SCRIPT_PORTRAIT_SEQUENCE,
    KING_SCRIPT_GOLD_AWARD,
    KING_SCRIPT_SCROLL,
    KING_SCRIPT_DONE,
    GVAR_FRAME_TIMER = 0xFF1A,
    GVAR_ANIM_TIMER = 0xFF1B,
    GVAR_SPACEBAR_STATE = 0xFF1D,
    GVAR_SKIP_FLAG2 = 0xFF1E,
    GVAR_ENTER_KEY = 0xFF29,
    GVAR_SCRIPT_IP = 0xFF4C,
    GVAR_TEXT_X = 0xFF4E,
    GVAR_TEXT_Y = 0xFF4F,
    GVAR_FRAME_COUNT = 0xFF50,
    GVAR_SOUND_CUE = 0xFF75,
    KING_MOUTH_MODE = 0xA79D,
    KING_MOUTH_PHASE = 0xA79E,
    KING_MOUTH_SET = 0xA79F,
    KING_FACE_MODE = 0xA7A0,
    KING_FACE_PHASE = 0xA7A1,
    TOWN_CHAR_WIDTH_TABLE = 0x7B82,
    TOWN_CHAR_ADVANCE_TABLE = 0x7BE2,
    TOWN_TEXT_LINE_COUNT = 0x7C52,
    TOWN_TEXT_WRAP = 0x7C5D,
};

static u16 read_u16(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static void write_u16(u8 *memory, u16 offset, u16 value) {
    memory[offset] = (u8)value;
    memory[(u16)(offset + 1)] = (u8)(value >> 8);
}

int zeliard_room_prepare_enter(zeliard_room_runtime_t *room,
                               const u8 *vga, size_t vga_size) {
    if (!room || !vga || vga_size < 0x10000 || room->active) return -1;
    memcpy(room->saved_vga, vga, sizeof(room->saved_vga));
    room->entry_frame_prepared = 1;
    return 0;
}

static int load_room_program(u8 *game_seg, const char *asset) {
    size_t size = 0;
    u8 *file = platform_load_asset(asset, &size);
    if (!file || size < 4) { free(file); return -1; }
    const size_t payload = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (payload > size - 4 || payload > 0x6000) {
        free(file); return -2;
    }
    memcpy(game_seg + 0xA000, file + 4, payload);
    free(file);
    return 0;
}

static int load_room_tiles(const char *asset, u8 *tiles) {
    size_t size = 0, plane_size = 0;
    u8 *file = platform_load_asset(asset, &size);
    u8 *planes = file ? fill_buffer_decompress(file, size, &plane_size) : NULL;
    free(file);
    if (!planes) return -1;
    const int result = zeliard_gmmcga_prepare_room_tiles(
        planes, plane_size, tiles, 0x3000, 0x100);
    free(planes);
    return result;
}

int zeliard_room_enter(zeliard_room_runtime_t *room,
                       zeliard_room_kind_t kind,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size) {
    if (!room || !game_seg || !vga || game_size < 0x10000 ||
        vga_size < 0x10000 || room->active) return -1;
    const char *program = kind == ZEL_ROOM_KING ? "kingpro.bin" :
                          kind == ZEL_ROOM_SAGE ? "kenjpro.bin" :
                          kind == ZEL_ROOM_VIEWING ? "omoypro.bin" : NULL;
    const char *graphic = kind == ZEL_ROOM_KING ? "king.grp" :
                          kind == ZEL_ROOM_SAGE ? "kenja.grp" :
                          kind == ZEL_ROOM_VIEWING ? "omoya.grp" : NULL;
    if (!program || !graphic) return -2;

    memcpy(room->saved_code, game_seg + 0xA000, sizeof(room->saved_code));
    if (!room->entry_frame_prepared)
        memcpy(room->saved_vga, vga, sizeof(room->saved_vga));
    room->entry_frame_prepared = 0;
    if (load_room_program(game_seg, program)) return -3;

    const int loaded = load_room_tiles(graphic, room->room_tiles);
    if (loaded) {
        memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
        return -5;
    }

    zeliard_gmmcga_clear_playfield(vga, vga_size);
    zeliard_gmmcga_draw_life_scale(vga, vga_size, 0);
    if (kind == ZEL_ROOM_KING) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA41A);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA16E, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0E17);
    } else if (kind == ZEL_ROOM_SAGE) {
        game_seg[0xC006] = 1;
        game_seg[0xBB12] = 0x17;
        game_seg[0xBB13] = 0x07;
        const u16 header = (u16)(game_seg[0xACBD] |
                                 ((u16)game_seg[0xACBE] << 8));
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, header);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA9B6, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0717);
    } else {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA245);
        zeliard_gtmcga_draw_room_tile_grid(
            game_seg + 0xA129, 16u * 17u, 16, 17,
            room->room_tiles, 0x3000, vga, vga_size, 0x0C1E);
    }
    if (kind != ZEL_ROOM_VIEWING)
        zeliard_gmmcga_fill_frame(
            vga, vga_size, 0x0D60, 0x3637, game_seg[0xFF77]);
    palette_set_game_mcga();
    room->kind = kind;
    room->active = 1;
    room->exit_requested = 0;
    room->script_state = 0;
    room->pending_sound_cue = 0;
    /* 211OMOYP:A041 tests player offset 49h after drawing the room and
     * branches to end_demo_transition when it is nonzero. */
    room->alternate_transition_requested =
        kind == ZEL_ROOM_VIEWING && game_seg[0x0049] != 0;
    if (kind == ZEL_ROOM_KING) {
        room->king_entry_gold = ((u32)game_seg[0x85] << 16) |
                                read_u16(game_seg, 0x86);
        game_seg[GVAR_TEXT_X] = 0;
        game_seg[GVAR_TEXT_Y] = 0;
        game_seg[TOWN_TEXT_LINE_COUNT] = 0;
        room->script_ip = zeliard_king_select_script(game_seg, game_size);
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        room->script_delay = 6;
        room->script_state = KING_SCRIPT_DELAY;
    }
    return 0;
}

int zeliard_room_leave(zeliard_room_runtime_t *room,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size) {
    if (!room || !room->active || !game_seg || !vga ||
        game_size < 0x10000 || vga_size < 0x10000) return -1;
    memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
    memcpy(vga, room->saved_vga, sizeof(room->saved_vga));
    if (room->kind == ZEL_ROOM_KING) {
        const u32 gold = ((u32)game_seg[0x85] << 16) |
                         read_u16(game_seg, 0x86);
        if (gold != room->king_entry_gold)
            zeliard_gmmcga_draw_gold(vga, vga_size, game_seg, game_size);
    }
    room->active = 0;
    room->alternate_transition_requested = 0;
    room->entry_frame_prepared = 0;
    room->exit_requested = 0;
    room->script_state = 0;
    room->pending_sound_cue = 0;
    room->kind = ZEL_ROOM_NONE;
    return 0;
}

u16 zeliard_king_select_script(const u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x10000) return 0;
    if ((u8)(game_seg[5] | game_seg[6]) == 0) return 0xA42F;
    if (game_seg[6] == 0) return 0xA53C;
    if (game_seg[0x49] == 0) return 0xA5D2;
    return 0xA6C1;
}

static u16 measure_king_word(const u8 *game_seg, u16 si) {
    u16 width = 0;
    for (;;) {
        const u8 ch = game_seg[si++];
        if (!ch || ch == 0xFF || ch == 0x20 || ch == 0x2F ||
            ch == 0x0D || ch == 0x0C)
            return width;
        if (ch >= 0x20 && ch < 0x80)
            width = (u16)(width + game_seg[TOWN_CHAR_ADVANCE_TABLE + ch - 0x20]);
    }
}

static u16 count_king_lines(const u8 *game_seg, u16 si) {
    u16 lines = 0, width = 0;
    for (;;) {
        const u8 ch = game_seg[si++];
        if (!ch) return lines;
        if (ch == 0xFF) {
            if (game_seg[si++] == 0xFF) return lines;
            continue;
        }
        if (ch == 0x0C) return lines;
        if (ch == 0x2F || ch == 0x0D) {
            width = 0;
            ++lines;
            continue;
        }
        if (ch < 0x20 || ch >= 0x80) continue;
        width = (u16)(width + game_seg[TOWN_CHAR_ADVANCE_TABLE + ch - 0x20]);
        if (ch == 0x20 && (u16)(width + measure_king_word(game_seg, si)) >= 0xD0) {
            width = 0;
            ++lines;
        }
    }
}

static void king_scroll_row(u8 *vga) {
    for (u8 row = 0; row < 50; ++row)
        memmove(vga + (size_t)(98 + row) * 320u + 56,
                vga + (size_t)(99 + row) * 320u + 56, 208);
}

static void king_draw_page_prompt(u8 *game_seg, u8 *vga, size_t vga_size) {
    /* 106TOWN:dlg_draw_prompt_then_clear passes AX=027Ch, BX=009Ch,
     * CL=8Bh to GMMCGA:27E9. */
    zeliard_gmmcga_draw_text_char(vga, vga_size, game_seg, 0x10000,
                                  0x7C, 2, 0x009C, 0x8B);
}

static void king_schedule_delay(zeliard_room_runtime_t *room) {
    room->script_delay = 6;
    room->script_state = KING_SCRIPT_DELAY;
}

static void king_sound_cue(zeliard_room_runtime_t *room, u8 *game_seg,
                           u8 cue) {
    game_seg[GVAR_SOUND_CUE] = cue;
    room->pending_sound_cue = cue;
}

static void king_draw_variant(zeliard_room_runtime_t *room, const u8 *game_seg,
                              u8 *vga, size_t vga_size, u8 variant) {
    const u16 source = read_u16(game_seg, (u16)(0xA1CE + (u16)variant * 2u));
    zeliard_gtmcga_draw_room_tile_grid(
        game_seg + source, 42, 7, 6, room->room_tiles, sizeof(room->room_tiles),
        vga, vga_size, 0x1117);
}

static void king_draw_glyph_run(zeliard_room_runtime_t *room,
                                const u8 *game_seg, u8 *vga, size_t vga_size,
                                u16 source, u16 position, u8 rows, u8 columns) {
    zeliard_gtmcga_draw_room_tile_grid(
        game_seg + source, (size_t)rows * columns, rows, columns,
        room->room_tiles, sizeof(room->room_tiles), vga, vga_size, position);
}

static void king_face_anim_tick(zeliard_room_runtime_t *room, u8 *game_seg,
                                u8 *vga, size_t vga_size) {
    if (read_u16(game_seg, GVAR_FRAME_COUNT) < 4) return;
    write_u16(game_seg, GVAR_FRAME_COUNT, 0);
    if (game_seg[KING_FACE_MODE]) {
        const u8 phase = ++game_seg[KING_FACE_PHASE];
        if (phase < 0x1A) {
            const u8 set = game_seg[(u16)(0xA360 + phase)];
            king_draw_glyph_run(room, game_seg, vga, vga_size,
                                (u16)(0xA37A + (u16)set * 4u), 0x112F, 1, 4);
        } else {
            u16 ax = read_u16(game_seg, GVAR_ANIM_TIMER);
            const u8 ah = (u8)(ax >> 8);
            const u16 al_sum = (u16)(u8)ax + ah;
            ax = (u16)((u8)al_sum |
                ((u16)(u8)(ah + (al_sum > 0xFF)) << 8));
            ax = (u16)(ax + read_u16(game_seg, 0x092B));
            write_u16(game_seg, 0x092B, ax);
            if ((u8)ax == 0) game_seg[KING_FACE_PHASE] = 0xFF;
        }
    }
    if (game_seg[KING_MOUTH_MODE]) {
        if (++game_seg[KING_MOUTH_PHASE] >= 6) {
            game_seg[KING_MOUTH_PHASE] = 0;
            const u8 set = (u8)(++game_seg[KING_MOUTH_SET] & 1);
            king_draw_glyph_run(room, game_seg, vga, vga_size,
                                (u16)(0xA3D4 + (u16)set * 10u), 0x113F, 2, 5);
        }
    }
}

static void king_start_command(zeliard_room_runtime_t *room, u8 *game_seg,
                               u8 *vga, size_t vga_size, u8 command) {
    room->script_command = command;
    switch (command) {
    case 0:
        room->script_sequence_index = 0;
        king_draw_variant(room, game_seg, vga, vga_size, game_seg[0xA0F8]);
        game_seg[GVAR_FRAME_TIMER] = 0;
        room->script_wait_ticks = 25;
        room->script_state = KING_SCRIPT_PORTRAIT_SEQUENCE;
        break;
    case 1:
        room->script_gold_steps = 10;
        room->script_wait_ticks = 0;
        room->script_state = KING_SCRIPT_GOLD_AWARD;
        break;
    case 2:
        game_seg[GVAR_FRAME_TIMER] = 0;
        room->script_wait_ticks = 150;
        room->script_state = KING_SCRIPT_WAIT_LONG;
        break;
    case 3:
        game_seg[KING_FACE_MODE] = 0xFF;
        king_draw_glyph_run(room, game_seg, vga, vga_size,
                            0xA3DE, 0x113F, 2, 5);
        king_schedule_delay(room);
        break;
    case 4:
        game_seg[KING_MOUTH_MODE] = 0xFF;
        king_schedule_delay(room);
        break;
    case 5:
        game_seg[KING_MOUTH_MODE] = 0;
        king_draw_glyph_run(room, game_seg, vga, vga_size,
                            0xA3D4, 0x113F, 2, 5);
        king_schedule_delay(room);
        break;
    default:
        room->script_state = KING_SCRIPT_DONE;
        room->exit_requested = 1;
        break;
    }
}

static void king_advance_line(zeliard_room_runtime_t *room, u8 *game_seg) {
    game_seg[GVAR_TEXT_X] = 0;
    ++game_seg[TOWN_TEXT_LINE_COUNT];
    ++game_seg[GVAR_TEXT_Y];
    if (game_seg[TOWN_TEXT_LINE_COUNT] < 4 && game_seg[GVAR_TEXT_Y] < 5) {
        king_schedule_delay(room);
        return;
    }
    if (game_seg[GVAR_TEXT_Y] >= 5) --game_seg[GVAR_TEXT_Y];
    room->script_scroll_steps = 10;
    room->script_prompt_after_scroll =
        count_king_lines(game_seg, room->script_ip) >= 2;
    room->script_state = KING_SCRIPT_SCROLL;
}

static void king_process_script_byte(zeliard_room_runtime_t *room,
                                     u8 *game_seg, u8 *vga,
                                     size_t vga_size) {
    if ((u16)(game_seg[GVAR_TEXT_X] + measure_king_word(
            game_seg, room->script_ip)) >= 0xD0) {
        king_advance_line(room, game_seg);
        return;
    }
    const u8 ch = game_seg[room->script_ip++];
    write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
    if (ch == 0x2F || ch == 0x0D) {
        king_advance_line(room, game_seg);
        return;
    }
    if (ch == 0x0C) {
        game_seg[GVAR_TEXT_X] = game_seg[GVAR_TEXT_Y] = 0;
        game_seg[TOWN_TEXT_LINE_COUNT] = 0;
        zeliard_gmmcga_fill_frame(vga, vga_size, 0x0D60, 0x3637,
                                  game_seg[0xFF77]);
        king_schedule_delay(room);
        return;
    }
    if (ch == 0x0F) {
        king_draw_page_prompt(game_seg, vga, vga_size);
        room->script_prompt_after_scroll = 1;
        room->script_state = KING_SCRIPT_WAIT_INPUT;
        game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
        return;
    }
    if (ch == 0x11) {
        room->script_state = KING_SCRIPT_WAIT_INPUT;
        game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
        return;
    }
    if (ch == 0x13) {
        game_seg[TOWN_TEXT_WRAP] = 0xFF;
        king_schedule_delay(room);
        return;
    }
    if (ch == 0x15) {
        game_seg[TOWN_TEXT_WRAP] = 0;
        king_schedule_delay(room);
        return;
    }
    if (ch == 0xFF) {
        const u8 command = game_seg[room->script_ip++];
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        if (command == 0xFF) {
            room->script_state = KING_SCRIPT_DONE;
            room->exit_requested = 1;
        } else {
            king_start_command(room, game_seg, vga, vga_size, command);
        }
        return;
    }
    if (ch == 0) {
        king_start_command(room, game_seg, vga, vga_size, 0);
        return;
    }
    if (ch >= 0x20 && ch < 0x80) {
        const u8 width = game_seg[TOWN_CHAR_WIDTH_TABLE + ch - 0x20];
        const u16 x = (u16)(0x38u + game_seg[GVAR_TEXT_X] - width);
        const u8 y = (u8)(0x63u + game_seg[GVAR_TEXT_Y] * 10u);
        zeliard_gmmcga_draw_text_char(vga, vga_size, game_seg, 0x10000,
                                      ch, 1, x, y);
        game_seg[GVAR_TEXT_X] = (u8)(game_seg[GVAR_TEXT_X] +
            game_seg[TOWN_CHAR_ADVANCE_TABLE + ch - 0x20]);
        if (ch != 0x20) king_sound_cue(room, game_seg, 5);
    }
    king_schedule_delay(room);
}

int zeliard_room_advance_pit(zeliard_room_runtime_t *room,
                             u8 *game_seg, size_t game_size,
                             u8 *vga, size_t vga_size) {
    if (!room || !room->active || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return -1;
    if (room->kind != ZEL_ROOM_KING || room->exit_requested) return 0;
    switch (room->script_state) {
    case KING_SCRIPT_DELAY:
        if (room->script_delay && --room->script_delay) return 0;
        king_process_script_byte(room, game_seg, vga, vga_size);
        break;
    case KING_SCRIPT_WAIT_INPUT:
        if (!game_seg[GVAR_SPACEBAR_STATE] && !game_seg[GVAR_SKIP_FLAG2] &&
            game_seg[GVAR_ENTER_KEY] != 0x0D) return 0;
        game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
        game_seg[GVAR_ENTER_KEY] = 0;
        king_sound_cue(room, game_seg, 0x1D);
        if (room->script_prompt_after_scroll) {
            zeliard_gmmcga_fill_frame(vga, vga_size, 0x278B, 0x020A, 0);
            game_seg[TOWN_TEXT_LINE_COUNT] = 0;
            room->script_prompt_after_scroll = 0;
        }
        king_schedule_delay(room);
        break;
    case KING_SCRIPT_WAIT_LONG:
        king_face_anim_tick(room, game_seg, vga, vga_size);
        if (--room->script_wait_ticks == 0) king_schedule_delay(room);
        break;
    case KING_SCRIPT_PORTRAIT_SEQUENCE:
        king_face_anim_tick(room, game_seg, vga, vga_size);
        if (--room->script_wait_ticks == 0) {
            if (++room->script_sequence_index >= 12) {
                king_schedule_delay(room);
            } else {
                king_draw_variant(room, game_seg, vga, vga_size,
                    game_seg[(u16)(0xA0F8 + room->script_sequence_index)]);
                game_seg[GVAR_FRAME_TIMER] = 0;
                room->script_wait_ticks = 25;
            }
        }
        break;
    case KING_SCRIPT_GOLD_AWARD:
        if (room->script_wait_ticks == 0) {
            u32 gold = ((u32)game_seg[0x85] << 16) |
                       read_u16(game_seg, 0x86);
            gold = (gold + 100u) & 0xFFFFFFu;
            game_seg[0x85] = (u8)(gold >> 16);
            write_u16(game_seg, 0x86, (u16)gold);
            zeliard_gmmcga_draw_gold(vga, vga_size, game_seg, game_size);
            king_sound_cue(room, game_seg, 0x13);
            game_seg[GVAR_FRAME_TIMER] = 0;
            room->script_wait_ticks = 15;
        } else {
            king_face_anim_tick(room, game_seg, vga, vga_size);
            if (--room->script_wait_ticks == 0 && --room->script_gold_steps == 0) {
                game_seg[5] = 0xFF;
                king_schedule_delay(room);
            }
        }
        break;
    case KING_SCRIPT_SCROLL:
        king_scroll_row(vga);
        if (--room->script_scroll_steps == 0) {
            if (room->script_prompt_after_scroll) {
                king_draw_page_prompt(game_seg, vga, vga_size);
                room->script_state = KING_SCRIPT_WAIT_INPUT;
                game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
            } else {
                king_schedule_delay(room);
            }
        }
        break;
    default:
        break;
    }
    return room->exit_requested ? 1 : 0;
}
