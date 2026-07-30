#include "town_runtime.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../render/town_background.h"
#include "../render/town_mcga.h"

#include <stdlib.h>
#include <string.h>

enum {
    TOWN_DESCRIPTOR = 0xC000,
    TOWN_MAP_SIDE = 0x7C45,
    TOWN_PALETTE_INDEX = 0x7C46,
    TOWN_TEXT_POINTER = 0xC004,
    TOWN_PATTERN_DEST = 0x8000,
    TOWN_YMPD_DEST = 0x3300,
};

static u16 read_u16(const u8 *memory, u16 offset) {
    return (u16)(memory[offset] | ((u16)memory[(u16)(offset + 1)] << 8));
}

static int append_event(zeliard_town_runtime_t *town,
                        zeliard_town_event_t event) {
    if (town->event_count >= sizeof(town->events) / sizeof(town->events[0]))
        return 0;
    town->events[town->event_count++] = event;
    return 1;
}

static int load_raw_chunk(const char *asset, u8 *destination,
                          size_t capacity, size_t *loaded_size) {
    size_t file_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    if (!file || file_size < 4) {
        free(file);
        return 0;
    }
    const size_t declared = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (declared > file_size - 4 || declared > capacity) {
        free(file);
        return 0;
    }
    memcpy(destination, file + 4, declared);
    free(file);
    if (loaded_size) *loaded_size = declared;
    return 1;
}

static int load_fill_chunk(const char *asset, u8 *destination,
                           size_t capacity, size_t *loaded_size) {
    size_t file_size = 0;
    u8 *file = platform_load_asset(asset, &file_size);
    size_t payload_size = 0;
    u8 *payload = file ? fill_buffer_decompress(file, file_size,
                                                &payload_size) : NULL;
    free(file);
    if (!payload || payload_size > capacity) {
        free(payload);
        return 0;
    }
    memcpy(destination, payload, payload_size);
    free(payload);
    if (loaded_size) *loaded_size = payload_size;
    return 1;
}

static int decode_town_header(u8 *cs, zeliard_town_runtime_t *town) {
    u16 si = read_u16(cs, TOWN_DESCRIPTOR);
    ++si;
    do {
        const u8 value = cs[si++];
        if ((u8)(value + 1) == 0) break;
    } while (si != 0);
    if (si == 0) return 0;
    town->map_side = cs[si++];
    town->palette_index = cs[si];
    cs[TOWN_MAP_SIDE] = town->map_side;
    cs[TOWN_PALETTE_INDEX] = town->palette_index;
    town->town_text_record = read_u16(cs, TOWN_TEXT_POINTER);
    return 1;
}

int zeliard_town_enter_first_frame(zeliard_town_runtime_t *town,
                                   zeliard_game_exec_state_t *game,
                                   u8 *vga, size_t vga_size) {
    if (!town || !game || !vga || vga_size < 0x10000)
        return -1;
    for (size_t i = 0; i < ZELIARD_GAME_SEGMENT_COUNT; ++i) {
        if (!game->segment[i] || game->segment_size[i] < 0x10000)
            return -1;
    }
    memset(town, 0, sizeof(*town));
    u8 *cs = game->segment[0];
    u8 *cs_1000 = game->segment[1];
    u8 *cs_2000 = game->segment[2];
    u8 *cs_3000 = game->segment[3];
    size_t loaded_size = 0;

    /* game.asm loads MMAN at gvar_game_seg:4000; 106TOWN:init_load_tiles
     * preprocesses 0A4h tiles to the CS+2000h mask bank at 7000h. */
    if (!load_fill_chunk("mman.grp", cs_1000 + 0x4000, 0xC000,
                         &loaded_size) ||
        zeliard_gtmcga_encode_tile_block(cs_1000, 0x10000, 0x4100,
                                         cs_2000, 0x10000, 0x7000, 0xA4) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_PREPROCESS_MMAN, "106TOWN:init_load_tiles",
            "mman.grp", 0x1000, 0x4000, 2}))
        return -2;

    /* 106TOWN:load_town_door_table performs the same conversion for the
     * TMAN player bank at 6000h and its masks at CS+2000h:8000h. */
    if (!load_fill_chunk("tman.grp", cs_1000 + 0x6000, 0xA000,
                         &loaded_size) ||
        zeliard_gtmcga_encode_tile_block(cs_1000, 0x10000, 0x6000,
                                         cs_2000, 0x10000, 0x8000, 0x2E) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_PREPROCESS_TMAN, "106TOWN:load_town_door_table",
            "tman.grp", 0x1000, 0x6000, 2}))
        return -2;

    /* stick.asm AL=1, AH=80h selects CMAP.MDT and loads its raw MDT body. */
    if (!load_raw_chunk("cmap.mdt", cs + TOWN_DESCRIPTOR,
                        0x10000 - TOWN_DESCRIPTOR, NULL) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CMAP, "game.asm:load_first_level", "cmap.mdt",
            0, TOWN_DESCRIPTOR, 1}))
        return -2;
    if (!decode_town_header(cs, town)) return -3;

    /* 106TOWN:load_town_pattern_chunk, palette index zero -> CPAT.GRP. */
    if (!load_fill_chunk("cpat.grp", cs_1000 + TOWN_PATTERN_DEST,
                         0x10000 - TOWN_PATTERN_DEST, &loaded_size))
        return -4;
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 value = read_u16(cs_1000, (u16)(TOWN_PATTERN_DEST + offset));
        cs_1000[TOWN_PATTERN_DEST + offset] = (u8)(value + TOWN_PATTERN_DEST);
        cs_1000[TOWN_PATTERN_DEST + offset + 1] =
            (u8)((value + TOWN_PATTERN_DEST) >> 8);
    }
    if (!append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_CPAT, "106TOWN:load_town_pattern_chunk",
            "cpat.grp", 0x1000, TOWN_PATTERN_DEST, 2}))
        return -4;

    if (zeliard_mole_render_mcga(cs_3000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_RUN_207MOLE, "game.asm:loaded_code_a", "mole.bin",
            0x3000, 0, 4}))
        return -5;
    if (zeliard_gmmcga_clear_playfield(vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_CLEAR_PLAYFIELD, "106TOWN:gfx_clear_fn", NULL,
            0, 0, 0}))
        return -6;
    if (zeliard_gtmcga_capture_playfield(vga, vga_size, cs, 0x10000) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_CAPTURE_PLAYFIELD, "106TOWN:gfx_draw_fn", NULL,
            0, 0xA000, 0}))
        return -7;

    /* 106TOWN:player_load_chunk loads YMPD at (CS+2000h):3300h. */
    if (!load_raw_chunk("ympd.bin", cs_2000 + TOWN_YMPD_DEST,
                        0x10000 - TOWN_YMPD_DEST, &loaded_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_LOAD_YMPD, "106TOWN:player_load_chunk", "ympd.bin",
            0x2000, TOWN_YMPD_DEST, 3}))
        return -8;
    if (zeliard_ympd_render_mcga(cs_2000 + TOWN_YMPD_DEST, loaded_size,
                                 cs_3000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_RUN_208YMPD, "106TOWN:int60", "ympd.bin",
            0x2000, TOWN_YMPD_DEST, 4}))
        return -9;

    cs[0xFF1D] = 0;
    cs[0xFF1E] = 0;
    cs[0x00E4] = 0;
    cs[0x009F] = 0;
    cs[0xFF2A] = 0x17;
    cs[0xFF2B] = 0xC0;
    if (zeliard_gmmcga_draw_first_frame_hud(vga, vga_size, cs, 0x10000,
                                             town->town_text_record) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_DRAW_FIRST_HUD, "106TOWN:frame_update", NULL,
            0, town->town_text_record, 0}))
        return -10;

    memset(cs + 0xE000, 0xFE, 0xE0);
    if (zeliard_gtmcga_render_town_actors(cs, 0x10000, cs_1000, 0x10000,
                                          cs_2000, 0x10000, vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_DRAW_ACTORS, "106TOWN:render_town_actors", NULL,
            0, 0xFA00, 0}))
        return -11;

    if (cs[0x0083] < 0x1B) {
        u16 cursor = (u16)(0xE000 + (u16)cs[0x0083] * 8u + 5u);
        memset(cs + cursor, 0xFF, 3);
        memset(cs + cursor + 8, 0xFF, 3);
    }
    if (zeliard_gtmcga_update_town_frame(cs, 0x10000, cs_1000, 0x10000,
                                          vga, vga_size) ||
        !append_event(town, (zeliard_town_event_t){
            ZEL_TOWN_EVENT_UPDATE_FRAME, "106TOWN:gfx_update_fn", NULL,
            0, 0x3051, 0}))
        return -12;

    palette_set_game_mcga();
    return 0;
}
