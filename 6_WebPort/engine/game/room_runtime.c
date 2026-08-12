#include "room_runtime.h"
#include "room_masm_vm.h"

#include "../core/player_state.h"
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
    CHURCH_SCRIPT_WAIT,
    CHURCH_SCRIPT_HEAL,
    CHURCH_SCRIPT_SERMON_ANIM,
    SHOP_SCRIPT_WAIT,
    SHOP_SCRIPT_BANNER_SEQUENCE,
    SHOP_SCRIPT_BANK_INTRO,
    SHOP_SCRIPT_MENU,
    GVAR_FRAME_TIMER = 0xFF1A,
    GVAR_ANIM_TIMER = 0xFF1B,
    GVAR_INPUT_DIRECTION = 0xFF17,
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

static int draw_armory_first_frame(const u8 *game_seg,
                                    const u8 *tiles,
                                    u8 *vga, size_t vga_size) {
    u8 tile_map[96];
    size_t output = 0;
    u16 descriptor = 0xAA10;
    for (u8 block = 0; block < 2; ++block) {
        const u8 rows = game_seg[descriptor++];
        if (!rows || output + (size_t)rows * 12u > sizeof(tile_map))
            return -1;
        const u16 source = read_u16(game_seg, descriptor);
        descriptor = (u16)(descriptor + 2);
        memcpy(tile_map + output, game_seg + source, (size_t)rows * 12u);
        output += (size_t)rows * 12u;
    }
    if (output != sizeof(tile_map)) return -1;
    return zeliard_gtmcga_draw_room_grid(
        tile_map, sizeof(tile_map), tiles, 0x3000,
        vga, vga_size, 0x0717);
}

static u8 expand_shop_mask(u8 mask, u8 count, u8 base, u8 *output) {
    u8 written = 0;
    for (u8 index = 0; index < count; ++index) {
        const u8 carry = mask & 0x80u;
        mask <<= 1;
        if (carry) output[written++] = (u8)(base + index);
    }
    return written;
}

static void prepare_shop_runtime_data(u8 *game_seg,
                                      zeliard_room_kind_t kind) {
    const u8 shop = game_seg[0xC006] ? game_seg[0xC006] : 1;
    const u8 index = (u8)(shop - 1u);
    if (kind == ZEL_ROOM_ARMORY) {
        const u16 source = read_u16(game_seg, (u16)(0xBAA7 + index * 2u));
        memcpy(game_seg + 0xBBFD, game_seg + source, 36);
        game_seg[0xBC31] = expand_shop_mask(
            game_seg[ZEL_PLAYER_SWORD_SHOP_INVENTORY + index],
            6, 0, game_seg + 0xBC3B);
        game_seg[0xBC32] = expand_shop_mask(
            game_seg[ZEL_PLAYER_SHIELD_SHOP_INVENTORY + index],
            6, 0, game_seg + 0xBC41);
    } else if (kind == ZEL_ROOM_DRUGSTORE) {
        const u16 source = read_u16(game_seg, (u16)(0xB10C + index * 2u));
        memcpy(game_seg + 0xB1F6, game_seg + source, 24);
        game_seg[0xB20E] = expand_shop_mask(
            game_seg[ZEL_PLAYER_MAGIC_SHOP_INVENTORY + index],
            8, 0, game_seg + 0xB20F);
    }
}

int zeliard_room_enter(zeliard_room_runtime_t *room,
                       zeliard_room_kind_t kind,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size) {
    if (!room || !game_seg || !vga || game_size < 0x10000 ||
        vga_size < 0x10000 || room->active) return -1;
    zeliard_player_state_t player;
    if (!zeliard_player_state_bind(&player, game_seg, game_size)) return -1;
    const char *program = kind == ZEL_ROOM_KING ? "kingpro.bin" :
                          kind == ZEL_ROOM_SAGE ? "kenjpro.bin" :
                          kind == ZEL_ROOM_VIEWING ? "omoypro.bin" :
                          kind == ZEL_ROOM_ARMORY ? "armrpro.bin" :
                          kind == ZEL_ROOM_DRUGSTORE ? "drugpro.bin" :
                          kind == ZEL_ROOM_CHURCH ? "churpro.bin" :
                          kind == ZEL_ROOM_BANK ? "bankpro.bin" :
                          kind == ZEL_ROOM_INN ? "innapro.bin" : NULL;
    const char *graphic = kind == ZEL_ROOM_KING ? "king.grp" :
                          kind == ZEL_ROOM_SAGE ? "kenja.grp" :
                          kind == ZEL_ROOM_VIEWING ? "omoya.grp" :
                          kind == ZEL_ROOM_ARMORY ? "armr.grp" :
                          kind == ZEL_ROOM_DRUGSTORE ? "drug.grp" :
                          kind == ZEL_ROOM_CHURCH ? "church.grp" :
                          kind == ZEL_ROOM_BANK ? "bank.grp" :
                          kind == ZEL_ROOM_INN ? "inn.grp" : NULL;
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
    prepare_shop_runtime_data(game_seg, kind);

    zeliard_gmmcga_clear_playfield(vga, vga_size);
    zeliard_gmmcga_draw_life_scale(vga, vga_size, 0);
    if (kind == ZEL_ROOM_KING) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA41A);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA16E, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0E17);
    } else if (kind == ZEL_ROOM_SAGE) {
        /* 217KENJP records DS:0000..00FF verbatim and therefore cannot
         * repair the release game's stale 0C5h field while saving.  The web
         * death/recall paths use that documented last-sage destination, so
         * commit the town selector at the same boundary where 106TOWN hands
         * control to the sage overlay.  Castle and Esco do not host sages. */
        const u8 sage_town = game_seg[ZEL_PLAYER_SAVE_SAGE];
        if (sage_town >= 0x81 && sage_town <= 0x88)
            game_seg[ZEL_PLAYER_LAST_SAGE] = sage_town;
        if (game_seg[0xC006] == 0) game_seg[0xC006] = 1;
        game_seg[0xBB12] = 0x17;
        game_seg[0xBB13] = 0x07;
        const u16 header = (u16)(game_seg[0xACBD] |
                                 ((u16)game_seg[0xACBE] << 8));
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, header);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA9B6, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0717);
    } else if (kind == ZEL_ROOM_VIEWING) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA245);
        zeliard_gtmcga_draw_room_tile_grid(
            game_seg + 0xA129, 16u * 17u, 16, 17,
            room->room_tiles, 0x3000, vga, vga_size, 0x0C1E);
    } else if (kind == ZEL_ROOM_ARMORY) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xACAE);
        if (draw_armory_first_frame(game_seg, room->room_tiles,
                                    vga, vga_size)) return -6;
    } else if (kind == ZEL_ROOM_DRUGSTORE) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA81C);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA5E4, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0717);
    } else if (kind == ZEL_ROOM_CHURCH) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA2A6);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA177, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0E17);
    } else if (kind == ZEL_ROOM_BANK) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA8EE);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA6C8, 96, room->room_tiles, 0x3000,
            vga, vga_size, 0x0717);
    }
    if (kind != ZEL_ROOM_VIEWING)
        zeliard_gmmcga_fill_frame(
            vga, vga_size, 0x0D60, 0x3637, game_seg[0xFF77]);
    palette_set_game_mcga();
    room->kind = kind;
    room->active = 1;
    room->exit_requested = 0;
    room->session_exit_requested = 0;
    room->script_state = 0;
    room->pending_sound_cue = 0;
    room->exact_vm_active = 0;
    room->menu_active = 0;
    room->menu_selection = 0;
    room->menu_count = 0;
    room->menu_direction_latch = 0;
    room->menu_action = 0;
    memset(room->menu_item_ids, 0, sizeof(room->menu_item_ids));
    /* 211OMOYP:A041 tests player offset 49h after drawing the room and
     * branches to end_demo_transition when it is nonzero. */
    room->alternate_transition_requested =
        kind == ZEL_ROOM_VIEWING &&
        zeliard_player_read_u8(&player, ZEL_PLAYER_AREA_LOAD_FLAG) != 0;
    room->entry_gold = zeliard_player_read_u24(&player, ZEL_PLAYER_GOLD);
    room->entry_almas = zeliard_player_read_u16(&player, ZEL_PLAYER_ALMAS);
    room->entry_hp = zeliard_player_read_u16(&player, ZEL_PLAYER_HP);
    room->entry_hp_max = zeliard_player_read_u16(
        &player, ZEL_PLAYER_HP_MAX);
    if (kind == ZEL_ROOM_KING) {
        game_seg[GVAR_TEXT_X] = 0;
        game_seg[GVAR_TEXT_Y] = 0;
        game_seg[TOWN_TEXT_LINE_COUNT] = 0;
        room->script_ip = zeliard_king_select_script(game_seg, game_size);
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        room->script_word_check_pending = 1;
        room->script_delay = 6;
        room->script_state = KING_SCRIPT_DELAY;
    } else if (kind == ZEL_ROOM_CHURCH) {
        game_seg[GVAR_TEXT_X] = 0;
        game_seg[GVAR_TEXT_Y] = 0;
        game_seg[TOWN_TEXT_LINE_COUNT] = 0;
        room->script_ip = zeliard_player_read_u16(
            &player, ZEL_PLAYER_HP) == zeliard_player_read_u16(
                &player, ZEL_PLAYER_HP_MAX) ? 0xA2B4 : 0xA2F2;
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        room->script_word_check_pending = 1;
        room->script_delay = 6;
        room->script_state = KING_SCRIPT_DELAY;
    } else if (kind == ZEL_ROOM_ARMORY ||
               kind == ZEL_ROOM_DRUGSTORE || kind == ZEL_ROOM_BANK) {
        game_seg[GVAR_TEXT_X] = 0;
        game_seg[GVAR_TEXT_Y] = 0;
        game_seg[TOWN_TEXT_LINE_COUNT] = 0;
        room->script_ip = kind == ZEL_ROOM_ARMORY ? 0xADD3 :
                          kind == ZEL_ROOM_DRUGSTORE ? 0xA86B : 0xA98D;
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        room->script_word_check_pending = 1;
        if (kind == ZEL_ROOM_BANK) {
            room->script_sequence_index = 0;
            room->script_wait_ticks = 30;
            room->script_state = SHOP_SCRIPT_BANK_INTRO;
        } else {
            room->script_delay = 6;
            room->script_state = KING_SCRIPT_DELAY;
        }
    }
    return 0;
}

int zeliard_room_leave(zeliard_room_runtime_t *room,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size) {
    if (!room || !room->active || !game_seg || !vga ||
        game_size < 0x10000 || vga_size < 0x10000) return -1;
    zeliard_player_state_t player;
    if (!zeliard_player_state_bind(&player, game_seg, game_size)) return -1;
    memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
    memcpy(vga, room->saved_vga, sizeof(room->saved_vga));
    const u32 gold = zeliard_player_read_u24(&player, ZEL_PLAYER_GOLD);
    if (gold != room->entry_gold &&
        zeliard_gmmcga_draw_gold(vga, vga_size, game_seg, game_size))
        return -1;
    const u16 almas = zeliard_player_read_u16(&player, ZEL_PLAYER_ALMAS);
    if (almas != room->entry_almas &&
        zeliard_gmmcga_draw_almas(vga, vga_size, game_seg, game_size))
        return -1;
    const u16 hp = zeliard_player_read_u16(&player, ZEL_PLAYER_HP);
    const u16 hp_max = zeliard_player_read_u16(
        &player, ZEL_PLAYER_HP_MAX);
    /* 106TOWN:door_type_shop clears/redraws the playfield after the room
     * program returns but leaves the room program's live HUD pixels intact.
     * The web shell restores a full cached town frame, so replay the life
     * driver calls when that restore would otherwise reinstate old values. */
    if (hp_max != room->entry_hp_max &&
        zeliard_gmmcga_draw_life_max(
            vga, vga_size, game_seg, game_size))
        return -1;
    if ((hp != room->entry_hp || hp_max != room->entry_hp_max) &&
        zeliard_gmmcga_draw_life_current(
            vga, vga_size, game_seg, game_size))
        return -1;
    room->active = 0;
    room->alternate_transition_requested = 0;
    room->entry_frame_prepared = 0;
    room->exit_requested = 0;
    room->session_exit_requested = 0;
    room->script_state = 0;
    room->pending_sound_cue = 0;
    if (room->exact_vm_active) zeliard_room_masm_vm_stop();
    room->exact_vm_active = 0;
    room->menu_active = 0;
    room->kind = ZEL_ROOM_NONE;
    return 0;
}

u16 zeliard_king_select_script(const u8 *game_seg, size_t game_size) {
    if (!game_seg || game_size < 0x10000) return 0;
    zeliard_player_state_t player = {.bytes = (u8 *)game_seg};
    if ((u8)(zeliard_player_read_u8(&player, ZEL_PLAYER_KING_DIALOG_DONE) |
             zeliard_player_read_u8(&player, ZEL_PLAYER_KING_DIALOG_DONE_B)) == 0)
        return 0xA42F;
    if (zeliard_player_read_u8(&player, ZEL_PLAYER_KING_DIALOG_DONE_B) == 0)
        return 0xA53C;
    if (zeliard_player_read_u8(&player, ZEL_PLAYER_AREA_LOAD_FLAG) == 0)
        return 0xA5D2;
    return 0xA6C1;
}

static u16 measure_king_word(const u8 *game_seg, u16 si) {
    u16 width = 0, characters = 0;
    u8 last = 0;
    for (;;) {
        const u8 ch = game_seg[si++];
        if (!ch || ch == 0xFF || ch == 0x20 || ch == 0x2F ||
            ch == 0x0D || ch == 0x0C) {
            if (characters == 1 && (last == '.' || last == ',')) return 0;
            return width;
        }
        if (ch >= 0x20 && ch < 0x80) {
            last = ch;
            ++characters;
            width = (u16)(width + game_seg[TOWN_CHAR_ADVANCE_TABLE + ch - 0x20]);
        }
    }
}

static u16 count_king_lines(const u8 *game_seg, u16 si) {
    u16 lines = 0, width = 0;
    for (;;) {
        const u8 ch = game_seg[si++];
        if (!ch) return (u16)(lines + (width != 0));
        if (ch == 0xFF) {
            if (game_seg[si++] == 0xFF)
                return (u16)(lines + (width != 0));
            continue;
        }
        if (ch == 0x0C) return (u16)(lines + (width != 0));
        if (ch == 0x2F || ch == 0x0D) {
            width = 0;
            ++lines;
            continue;
        }
        /* 106TOWN:count_dialog_wrapped_lines uses 8-bit BL subtraction and
         * indexes the advance table for every non-dispatched byte. */
        width = (u16)(width +
            game_seg[(u16)(TOWN_CHAR_ADVANCE_TABLE + (u8)(ch - 0x20))]);
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
    /* 210KINGP:script_loop calls 106TOWN:dlg_setup again after every
     * dispatched command. dlg_setup performs one leading word-fit test. */
    room->script_word_check_pending = 1;
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

static void church_draw_anim_step(zeliard_room_runtime_t *room,
                                  const u8 *game_seg,
                                  u8 *vga, size_t vga_size) {
    u8 phase = (u8)(game_seg[0xA3E5] + 1u);
    if (phase >= 3) phase = 0;
    ((u8 *)game_seg)[0xA3E5] = phase;
    const u16 sources[2] = {
        (u16)(0xA234 + (u16)phase * 6u),
        (u16)(0xA27C + (u16)phase * 4u),
    };
    const u16 positions[2] = {0x1037, 0x1537};
    const u8 rows[2] = {2, 2};
    const u8 columns[2] = {3, 2};
    for (u8 block = 0; block < 2; ++block) {
        for (u8 row = 0; row < rows[block]; ++row) {
            for (u8 column = 0; column < columns[block]; ++column) {
                const u8 glyph = game_seg[(u16)(sources[block] +
                    (u16)row * columns[block] + column)];
                if (glyph == 0xFF) continue;
                zeliard_gtmcga_draw_room_glyph(
                    room->room_tiles, sizeof(room->room_tiles),
                    vga, vga_size, glyph,
                    (u16)(positions[block] + ((u16)column << 8) + row * 8u));
            }
        }
    }
}

static void church_start_command(zeliard_room_runtime_t *room, u8 *game_seg,
                                 u8 *vga, size_t vga_size, u8 command) {
    room->script_command = command;
    room->script_word_check_pending = 1;
    switch (command) {
    case 0:
        game_seg[0xA3E4] = 0;
        room->script_sequence_index = 0;
        room->script_wait_ticks = 1;
        room->script_state = CHURCH_SCRIPT_SERMON_ANIM;
        break;
    case 1:
        room->script_ip = 0xA36A;
        write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
        king_schedule_delay(room);
        break;
    case 2:
        game_seg[GVAR_FRAME_TIMER] = 0;
        room->script_wait_ticks = 250;
        room->script_state = CHURCH_SCRIPT_WAIT;
        break;
    case 3:
        game_seg[GVAR_FRAME_TIMER] = 0;
        room->script_wait_ticks = 0;
        room->script_state = CHURCH_SCRIPT_HEAL;
        break;
    case 4:
        memcpy(game_seg + ZEL_PLAYER_SPELL_CHARGES,
               game_seg + ZEL_PLAYER_SPELL_CHARGES_MAX, 7);
        king_schedule_delay(room);
        break;
    default:
        room->script_state = KING_SCRIPT_DONE;
        room->exit_requested = 1;
        break;
    }
    (void)vga;
    (void)vga_size;
}

static void draw_menu_cursor(u8 *vga, u16 dialog_position, u8 row) {
    static const u8 bits[9] = {
        0x00, 0x60, 0x70, 0x78, 0x7C, 0x78, 0x70, 0x60, 0x00,
    };
    const u16 x = (u16)(((u8)(dialog_position >> 8) + 1u) * 4u);
    const u16 y = (u16)((u8)dialog_position + (u16)row * 10u + 1u);
    for (u8 glyph_row = 0; glyph_row < 9; ++glyph_row) {
        u8 mask = bits[glyph_row];
        for (u8 pixel = 0; pixel < 8; ++pixel) {
            if ((mask & 0x80) && x + pixel < 320 && y + glyph_row < 200)
                vga[(size_t)(y + glyph_row) * 320u + x + pixel] = 0x12;
            mask <<= 1;
        }
    }
}

static void draw_menu_string(const u8 *game_seg, u8 *vga,
                             u16 string, u16 dialog_position, u8 row) {
    const u16 font = read_u16(game_seg, 0xF504);
    u16 x = (u16)(((u8)(dialog_position >> 8) + 3u) * 4u);
    const u16 y = (u16)((u8)dialog_position + (u16)row * 10u + 1u);
    while (game_seg[string] && x < 320) {
        const u8 character = game_seg[string++];
        if (character < 0x20 || character >= 0x80) continue;
        const u16 source = (u16)(font + (u16)(character - 0x20) * 8u);
        for (u8 glyph_row = 0; glyph_row < 8 && y + glyph_row < 200;
             ++glyph_row) {
            u8 mask = game_seg[(u16)(source + glyph_row)];
            for (u8 pixel = 0; pixel < 4 && x + pixel < 320; ++pixel) {
                if (mask & 0x80)
                    vga[(size_t)(y + glyph_row) * 320u + x + pixel] = 9;
                mask <<= 1;
            }
        }
        x = (u16)(x + 5u);
    }
}

static void shop_draw_main_menu(zeliard_room_runtime_t *room,
                                const u8 *game_seg,
                                u8 *vga, size_t vga_size) {
    u16 strings, fill_position, fill_size, dialog_position;
    if (room->kind == ZEL_ROOM_ARMORY) {
        strings = 0xACC8; fill_position = 0x291D;
        fill_size = 0x1837; dialog_position = 0x2920;
        room->menu_count = 5;
    } else if (room->kind == ZEL_ROOM_DRUGSTORE) {
        strings = 0xA839; fill_position = 0x2722;
        fill_size = 0x1C2D; dialog_position = 0x2725;
        room->menu_count = 4;
    } else {
        strings = 0xA90C; fill_position = 0x281D;
        fill_size = 0x1A37; dialog_position = 0x2820;
        room->menu_count = 5;
    }
    zeliard_gmmcga_fill_frame(
        vga, vga_size, fill_position, fill_size, game_seg[0xFF77]);
    u16 string = strings;
    for (u8 row = 0; row < room->menu_count; ++row) {
        draw_menu_string(game_seg, vga, string, dialog_position, row);
        while (game_seg[string++]) {}
    }
    room->menu_active = 1;
    room->script_state = SHOP_SCRIPT_MENU;
}

static void shop_draw_banner_sequence_frame(zeliard_room_runtime_t *room,
                                            const u8 *game_seg,
                                            u8 *vga, size_t vga_size) {
    const u16 table = room->kind == ZEL_ROOM_DRUGSTORE ? 0xA745 : 0xA82F;
    const u16 source = read_u16(
        game_seg, (u16)(table + (u16)room->script_sequence_index * 2u));
    const u8 rows = room->kind == ZEL_ROOM_DRUGSTORE ? 7 : 5;
    const u8 columns = room->kind == ZEL_ROOM_DRUGSTORE ? 4 : 8;
    zeliard_gtmcga_draw_room_tile_grid(
        game_seg + source, (size_t)rows * columns, rows, columns,
        room->room_tiles, sizeof(room->room_tiles),
        vga, vga_size, 0x091F);
}

static void shop_draw_bank_intro_frame(zeliard_room_runtime_t *room,
                                       const u8 *game_seg,
                                       u8 *vga, size_t vga_size) {
    /* 213BANKP anim_scroll_step increments the counter before selecting
     * A773 + (counter & 1) * 28h. */
    const u16 source = (room->script_sequence_index & 1u) ? 0xA773 : 0xA79B;
    zeliard_gtmcga_draw_room_tile_grid(
        game_seg + source, 40, 5, 8,
        room->room_tiles, sizeof(room->room_tiles),
        vga, vga_size, 0x091F);
}

static void shop_draw_bank_intro_script_step(u8 *game_seg,
                                             u8 *vga, size_t vga_size) {
    /* 213BANKP resets gvar_script_ptr to A98B once per outer intro loop.
     * That address contains the period preceding the welcome sentence. */
    const u8 character = game_seg[0xA98B];
    const u8 width = game_seg[TOWN_CHAR_WIDTH_TABLE + character - 0x20];
    const u16 x = (u16)(0x38u + game_seg[GVAR_TEXT_X] - width);
    const u8 y = (u8)(0x63u + game_seg[GVAR_TEXT_Y] * 10u);
    zeliard_gmmcga_draw_text_char(
        vga, vga_size, game_seg, 0x10000, character, 1, x, y);
    game_seg[GVAR_TEXT_X] = (u8)(game_seg[GVAR_TEXT_X] +
        game_seg[TOWN_CHAR_ADVANCE_TABLE + character - 0x20]);
}

static void shop_start_command(zeliard_room_runtime_t *room, u8 *game_seg,
                               u8 *vga, size_t vga_size, u8 command) {
    const int menu_command =
        (room->kind == ZEL_ROOM_ARMORY && command == 0) ||
        (room->kind == ZEL_ROOM_DRUGSTORE && command == 2) ||
        (room->kind == ZEL_ROOM_BANK && command == 1);
    if (menu_command) {
        room->menu_selection = 0;
        shop_draw_main_menu(room, game_seg, vga, vga_size);
        return;
    }
    if ((room->kind == ZEL_ROOM_DRUGSTORE || room->kind == ZEL_ROOM_BANK) &&
        command == 0) {
        room->script_wait_ticks = room->kind == ZEL_ROOM_DRUGSTORE ? 80 : 60;
        room->script_state = SHOP_SCRIPT_WAIT;
        return;
    }
    room->script_state = KING_SCRIPT_DONE;
    room->exit_requested = 1;
}

static void shop_resume_script(zeliard_room_runtime_t *room, u8 *game_seg,
                               u16 script_ip) {
    room->menu_active = 0;
    room->script_ip = script_ip;
    write_u16(game_seg, GVAR_SCRIPT_IP, script_ip);
    room->script_word_check_pending = 1;
    king_schedule_delay(room);
}

static void shop_select_main_menu(zeliard_room_runtime_t *room,
                                  u8 *game_seg) {
    zeliard_player_state_t player = {.bytes = game_seg};
    u16 script_ip = 0;
    if (room->kind == ZEL_ROOM_ARMORY) {
        static const u16 scripts[5] = {
            0xB1DE, 0, 0xB026, 0xB081, 0xB11F,
        };
        script_ip = scripts[room->menu_selection];
        if (room->menu_selection == 1) {
            const u8 shield = zeliard_player_read_u8(
                &player, ZEL_PLAYER_SHIELD);
            const u16 hp = zeliard_player_read_u16(
                &player, ZEL_PLAYER_SHIELD_HP);
            const u16 maximum = zeliard_player_read_u16(
                &player, ZEL_PLAYER_SHIELD_HP_MAX);
            script_ip = !shield ? 0xAE4A : hp == maximum ? 0xAEB1 : 0xAEF8;
        }
    } else if (room->kind == ZEL_ROOM_DRUGSTORE) {
        static const u16 scripts[4] = {
            0xAB0E, 0xA88C, 0, 0xAAA6,
        };
        script_ip = scripts[room->menu_selection];
        if (room->menu_selection == 2) {
            script_ip = 0xAA79;
            for (u16 offset = ZEL_PLAYER_ITEM_SLOTS;
                 offset < ZEL_PLAYER_ITEM_SLOTS + 5; ++offset) {
                if (zeliard_player_read_u8(&player, offset)) {
                    script_ip = 0xA98D;
                    break;
                }
            }
        }
    } else {
        switch (room->menu_selection) {
        case 0:
            script_ip = 0xAC5A;
            break;
        case 1:
            script_ip = zeliard_player_read_u16(
                &player, ZEL_PLAYER_ALMAS) ? 0xA9D9 : 0xA9B2;
            break;
        case 2:
            script_ip = zeliard_player_read_u24(
                &player, ZEL_PLAYER_GOLD) ? 0xAACA : 0xAAA1;
            break;
        case 3:
            script_ip = zeliard_player_read_u24(
                &player, ZEL_PLAYER_BANK_GOLD) ? 0xAB80 : 0xAB32;
            break;
        default: {
            const u32 balance = zeliard_player_read_u24(
                &player, ZEL_PLAYER_BANK_GOLD);
            script_ip = balance == 0 ? 0xABF7 :
                        balance == 1 ? 0xAC35 : 0xAC10;
            break;
        }
        }
    }
    shop_resume_script(room, game_seg, script_ip);
}

static void room_start_command(zeliard_room_runtime_t *room, u8 *game_seg,
                               u8 *vga, size_t vga_size, u8 command) {
    if (room->kind == ZEL_ROOM_CHURCH)
        church_start_command(room, game_seg, vga, vga_size, command);
    else if (room->kind == ZEL_ROOM_ARMORY ||
             room->kind == ZEL_ROOM_DRUGSTORE || room->kind == ZEL_ROOM_BANK)
        shop_start_command(room, game_seg, vga, vga_size, command);
    else
        king_start_command(room, game_seg, vga, vga_size, command);
}

static void king_advance_line(zeliard_room_runtime_t *room, u8 *game_seg,
                              u8 *vga, size_t vga_size) {
    game_seg[GVAR_TEXT_X] = 0;
    ++game_seg[TOWN_TEXT_LINE_COUNT];
    ++game_seg[GVAR_TEXT_Y];
    const u8 prompt = game_seg[TOWN_TEXT_LINE_COUNT] >= 4 &&
        count_king_lines(game_seg, room->script_ip) >= 2;
    /* scroll_dlg_text_up is called at line four, but its entry immediately
     * returns while text_y is below five. Prompting is a separate decision. */
    if (game_seg[GVAR_TEXT_Y] >= 5) {
        --game_seg[GVAR_TEXT_Y];
        room->script_scroll_steps = 10;
        room->script_prompt_after_scroll = prompt;
        room->script_state = KING_SCRIPT_SCROLL;
    } else if (prompt) {
        king_draw_page_prompt(game_seg, vga, vga_size);
        room->script_prompt_after_scroll = 1;
        room->script_state = KING_SCRIPT_WAIT_INPUT;
        game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
    } else {
        king_schedule_delay(room);
    }
}

static void king_process_script_byte(zeliard_room_runtime_t *room,
                                     u8 *game_seg, u8 *vga,
                                     size_t vga_size) {
    if (room->script_word_check_pending) {
        room->script_word_check_pending = 0;
        if ((u16)(game_seg[GVAR_TEXT_X] + measure_king_word(
                game_seg, room->script_ip)) >= 0xD0) {
            king_advance_line(room, game_seg, vga, vga_size);
            return;
        }
    }
    const u8 ch = game_seg[room->script_ip++];
    write_u16(game_seg, GVAR_SCRIPT_IP, room->script_ip);
    if (ch == 0x2F || ch == 0x0D) {
        king_advance_line(room, game_seg, vga, vga_size);
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
        } else if (command >= 0x20 && command < 0x80) {
            const u8 width = game_seg[TOWN_CHAR_WIDTH_TABLE + command - 0x20];
            const u16 x = (u16)(0x38u + game_seg[GVAR_TEXT_X] - width);
            const u8 y = (u8)(0x63u + game_seg[GVAR_TEXT_Y] * 10u);
            zeliard_gmmcga_draw_text_char(
                vga, vga_size, game_seg, 0x10000, command, 1, x, y);
            game_seg[GVAR_TEXT_X] = (u8)(game_seg[GVAR_TEXT_X] +
                game_seg[TOWN_CHAR_ADVANCE_TABLE + command - 0x20]);
            king_schedule_delay(room);
        } else {
            room_start_command(room, game_seg, vga, vga_size, command);
        }
        return;
    }
    if (ch == 0) {
        room_start_command(room, game_seg, vga, vga_size, 0);
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
        if ((game_seg[TOWN_TEXT_WRAP] || ch == 0x20) &&
            (u16)(game_seg[GVAR_TEXT_X] + measure_king_word(
                game_seg, room->script_ip)) >= 0xD0) {
            king_advance_line(room, game_seg, vga, vga_size);
            return;
        }
    }
    king_schedule_delay(room);
}

int zeliard_room_advance_pit(zeliard_room_runtime_t *room,
                             u8 *game_seg, size_t game_size,
                             u8 *vga, size_t vga_size) {
    if (!room || !room->active || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return -1;
    if (room->exact_vm_active) {
        if (!zeliard_room_masm_vm_advance(
                game_seg, game_size, vga, vga_size, 1,
                game_seg[GVAR_INPUT_DIRECTION],
                game_seg[GVAR_SPACEBAR_STATE],
                (u8)(game_seg[GVAR_ENTER_KEY] == 0x0D ||
                     game_seg[GVAR_SKIP_FLAG2]))) return -2;
        const u8 cue = zeliard_room_masm_vm_take_sound_cue();
        if (cue) room->pending_sound_cue = cue;
        if (!zeliard_room_masm_vm_active()) {
            room->session_exit_requested =
                (u8)zeliard_room_masm_vm_session_exit_requested();
            zeliard_room_masm_vm_stop();
            room->exact_vm_active = 0;
            room->exit_requested = 1;
            return 1;
        }
        return 0;
    }
    if ((room->kind != ZEL_ROOM_KING && room->kind != ZEL_ROOM_CHURCH &&
         room->kind != ZEL_ROOM_ARMORY && room->kind != ZEL_ROOM_DRUGSTORE &&
         room->kind != ZEL_ROOM_BANK) ||
        room->exit_requested) return 0;
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
            zeliard_gmmcga_clear_rect(vga, vga_size, 0x278B, 0x020A);
            game_seg[TOWN_TEXT_LINE_COUNT] = 0;
            room->script_prompt_after_scroll = 0;
        }
        king_schedule_delay(room);
        break;
    case KING_SCRIPT_WAIT_LONG:
        if (room->kind == ZEL_ROOM_KING)
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
            zeliard_player_state_t player;
            zeliard_player_state_bind(&player, game_seg, game_size);
            zeliard_player_write_u24(
                &player, ZEL_PLAYER_GOLD,
                zeliard_player_read_u24(&player, ZEL_PLAYER_GOLD) + 100u);
            zeliard_gmmcga_draw_gold(vga, vga_size, game_seg, game_size);
            king_sound_cue(room, game_seg, 0x13);
            game_seg[GVAR_FRAME_TIMER] = 0;
            room->script_wait_ticks = 15;
        } else {
            king_face_anim_tick(room, game_seg, vga, vga_size);
            if (--room->script_wait_ticks == 0 && --room->script_gold_steps == 0) {
                zeliard_player_state_t player;
                zeliard_player_state_bind(&player, game_seg, game_size);
                zeliard_player_write_u8(
                    &player, ZEL_PLAYER_KING_DIALOG_DONE, 0xFF);
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
    case CHURCH_SCRIPT_WAIT:
        if ((room->script_wait_ticks & 31u) == 0)
            church_draw_anim_step(room, game_seg, vga, vga_size);
        if (--room->script_wait_ticks == 0) king_schedule_delay(room);
        break;
    case CHURCH_SCRIPT_HEAL: {
        zeliard_player_state_t player;
        zeliard_player_state_bind(&player, game_seg, game_size);
        const u16 hp = zeliard_player_read_u16(&player, ZEL_PLAYER_HP);
        const u16 maximum = zeliard_player_read_u16(
            &player, ZEL_PLAYER_HP_MAX);
        if (hp >= maximum) {
            zeliard_player_write_u16(&player, ZEL_PLAYER_HP, maximum);
            king_schedule_delay(room);
            break;
        }
        if (room->script_wait_ticks == 0) {
            const u16 healed = (u16)(hp + 8u);
            zeliard_player_write_u16(
                &player, ZEL_PLAYER_HP, healed < maximum ? healed : maximum);
            zeliard_gmmcga_draw_life_scale(vga, vga_size, 0);
            room->script_wait_ticks = 20;
        } else {
            if ((room->script_wait_ticks & 31u) == 0)
                church_draw_anim_step(room, game_seg, vga, vga_size);
            --room->script_wait_ticks;
        }
        break;
    }
    case CHURCH_SCRIPT_SERMON_ANIM:
        if (--room->script_wait_ticks == 0) {
            const u16 source = (u16)(0xA134 +
                (u16)room->script_sequence_index * 6u);
            zeliard_gtmcga_draw_room_tile_grid(
                game_seg + source, 6, 3, 2,
                room->room_tiles, sizeof(room->room_tiles),
                vga, vga_size, 0x163F);
            church_draw_anim_step(room, game_seg, vga, vga_size);
            if (++room->script_sequence_index >= 5) {
                king_schedule_delay(room);
            } else {
                room->script_wait_ticks = 32;
            }
        }
        break;
    case SHOP_SCRIPT_WAIT:
        if (--room->script_wait_ticks == 0) {
            room->script_sequence_index = 0;
            shop_draw_banner_sequence_frame(room, game_seg, vga, vga_size);
            room->script_wait_ticks = 40;
            room->script_state = SHOP_SCRIPT_BANNER_SEQUENCE;
        }
        break;
    case SHOP_SCRIPT_BANNER_SEQUENCE:
        if (--room->script_wait_ticks == 0) {
            if (++room->script_sequence_index >= 4) {
                king_schedule_delay(room);
            } else {
                shop_draw_banner_sequence_frame(room, game_seg, vga, vga_size);
                room->script_wait_ticks = 40;
            }
        }
        break;
    case SHOP_SCRIPT_BANK_INTRO:
        if (--room->script_wait_ticks == 0) {
            shop_draw_bank_intro_frame(room, game_seg, vga, vga_size);
            if (((room->script_sequence_index + 1u) & 1u) == 0)
                shop_draw_bank_intro_script_step(game_seg, vga, vga_size);
            if (++room->script_sequence_index >= 10) {
                king_schedule_delay(room);
            } else {
                room->script_wait_ticks = 30;
            }
        }
        break;
    case SHOP_SCRIPT_MENU: {
        const u16 dialog_position = room->kind == ZEL_ROOM_ARMORY ? 0x2920 :
                                    room->kind == ZEL_ROOM_DRUGSTORE ? 0x2725 :
                                    0x2820;
        draw_menu_cursor(vga, dialog_position, room->menu_selection);
        const u8 direction = game_seg[0xFF17] & 3u;
        if (!direction) room->menu_direction_latch = 0;
        else if (!room->menu_direction_latch) {
            room->menu_direction_latch = direction;
            const u8 previous = room->menu_selection;
            if (direction == 1 && room->menu_selection)
                --room->menu_selection;
            else if (direction == 2 &&
                     room->menu_selection + 1u < room->menu_count)
                ++room->menu_selection;
            if (previous != room->menu_selection)
                shop_draw_main_menu(room, game_seg, vga, vga_size);
        }
        if (game_seg[GVAR_SPACEBAR_STATE] || game_seg[GVAR_SKIP_FLAG2] ||
            game_seg[GVAR_ENTER_KEY] == 0x0D) {
            game_seg[GVAR_SPACEBAR_STATE] = game_seg[GVAR_SKIP_FLAG2] = 0;
            game_seg[GVAR_ENTER_KEY] = 0;
            shop_select_main_menu(room, game_seg);
        }
        break;
    }
    default:
        break;
    }
    return room->exit_requested ? 1 : 0;
}
