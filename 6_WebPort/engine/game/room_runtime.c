#include "room_runtime.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/room_mcga.h"
#include "../render/town_mcga.h"

#include <stdlib.h>
#include <string.h>

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
                          kind == ZEL_ROOM_SAGE ? "kenjpro.bin" : NULL;
    const char *graphic = kind == ZEL_ROOM_KING ? "king.grp" :
                          kind == ZEL_ROOM_SAGE ? "kenja.grp" : NULL;
    if (!program || !graphic) return -2;

    memcpy(room->saved_code, game_seg + 0xA000, sizeof(room->saved_code));
    memcpy(room->saved_vga, vga, sizeof(room->saved_vga));
    if (load_room_program(game_seg, program)) return -3;

    u8 *tiles = malloc(0x3000);
    if (!tiles) {
        memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
        return -4;
    }
    const int loaded = load_room_tiles(graphic, tiles);
    if (loaded) {
        free(tiles);
        memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
        return -5;
    }

    zeliard_gmmcga_clear_playfield(vga, vga_size);
    zeliard_gmmcga_draw_life_scale(vga, vga_size, 0);
    if (kind == ZEL_ROOM_KING) {
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, 0xA41A);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA16E, 96, tiles, 0x3000,
            vga, vga_size, 0x0E17);
    } else {
        game_seg[0xC006] = 1;
        game_seg[0xBB12] = 0x17;
        game_seg[0xBB13] = 0x07;
        const u16 header = (u16)(game_seg[0xACBD] |
                                 ((u16)game_seg[0xACBE] << 8));
        zeliard_gmmcga_draw_town_text_record(
            vga, vga_size, game_seg, game_size, header);
        zeliard_gtmcga_draw_room_grid(
            game_seg + 0xA9B6, 96, tiles, 0x3000,
            vga, vga_size, 0x0717);
    }
    free(tiles);
    zeliard_gmmcga_fill_frame(
        vga, vga_size, 0x0D60, 0x3637, game_seg[0xFF77]);
    palette_set_game_mcga();
    room->kind = kind;
    room->active = 1;
    return 0;
}

int zeliard_room_leave(zeliard_room_runtime_t *room,
                       u8 *game_seg, size_t game_size,
                       u8 *vga, size_t vga_size) {
    if (!room || !room->active || !game_seg || !vga ||
        game_size < 0x10000 || vga_size < 0x10000) return -1;
    memcpy(game_seg + 0xA000, room->saved_code, sizeof(room->saved_code));
    memcpy(vga, room->saved_vga, sizeof(room->saved_vga));
    room->active = 0;
    room->kind = ZEL_ROOM_NONE;
    return 0;
}
