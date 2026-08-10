#include "../load/fill_buffer.h"
#include "../core/input.h"
#include "../core/player_state.h"
#include "../game/room_runtime.h"
#include "../game/room_masm_vm.h"
#include "../render/room_mcga.h"
#include "../render/town_mcga.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long value = 0xCBF29CE484222325ULL;
    while (size--) { value ^= *data++; value *= 0x100000001B3ULL; }
    return value;
}

static unsigned long long frame_rect_hash(const u8 *frame, u16 x, u16 y,
                                          u16 width, u16 height) {
    unsigned long long value = 0xCBF29CE484222325ULL;
    for (u16 row = 0; row < height; ++row) {
        const u8 *pixel = frame + (size_t)(y + row) * 320u + x;
        for (u16 column = 0; column < width; ++column) {
            value ^= pixel[column];
            value *= 0x100000001B3ULL;
        }
    }
    return value;
}

static u8 *read_file(const char *path, size_t *size) {
    FILE *file = fopen(path, "rb");
    if (!file) return NULL;
    fseek(file, 0, SEEK_END); long length = ftell(file); rewind(file);
    u8 *data = length > 0 ? malloc((size_t)length) : NULL;
    if (!data || fread(data, 1, (size_t)length, file) != (size_t)length) {
        free(data); data = NULL;
    }
    fclose(file); *size = data ? (size_t)length : 0; return data;
}

static int load_payload(u8 *segment, u16 offset, const char *path) {
    size_t size = 0; u8 *file = read_file(path, &size);
    if (!file || size < 4) { free(file); return -1; }
    const size_t payload_size = (size_t)file[0] | ((size_t)file[1] << 8) |
        ((size_t)file[2] << 16) | ((size_t)file[3] << 24);
    if (payload_size > size - 4 || payload_size > 0x10000u - offset) {
        free(file); return -2;
    }
    memcpy(segment + offset, file + 4, payload_size); free(file); return 0;
}

static int load_raw(u8 *segment, u16 offset, const char *path) {
    size_t size = 0; u8 *file = read_file(path, &size);
    if (!file || size > 0x10000u - offset) { free(file); return -1; }
    memcpy(segment + offset, file, size); free(file); return 0;
}

static int load_font(u8 *segment) {
    size_t size = 0, decoded_size = 0;
    u8 *file = read_file("assets/font.grp", &size);
    u8 *decoded = file ? fill_buffer_decompress(file, size, &decoded_size) : NULL;
    free(file);
    if (!decoded || decoded_size > 0x0B00) { free(decoded); return -1; }
    memcpy(segment + 0xF500, decoded, decoded_size); free(decoded);
    for (u16 offset = 0; offset < 6; offset += 2) {
        u16 value = (u16)(segment[0xF500 + offset] |
                          (segment[0xF501 + offset] << 8));
        value = (u16)(value + 0xF500);
        segment[0xF500 + offset] = (u8)value;
        segment[0xF501 + offset] = (u8)(value >> 8);
    }
    return 0;
}

static int load_tiles(const char *path, u8 *tiles) {
    size_t size = 0, plane_size = 0;
    u8 *file = read_file(path, &size);
    u8 *planes = file ? fill_buffer_decompress(file, size, &plane_size) : NULL;
    free(file);
    int result = planes ? zeliard_gmmcga_prepare_room_tiles(
        planes, plane_size, tiles, 0x3000, 0x100) : -1;
    free(planes); return result;
}

static unsigned long long render_king(void) {
    u8 cs[0x10000] = {0}, tiles[0x3000] = {0}, vga[0x10000] = {0};
    if (load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0xA000, "assets/kingpro.bin") || load_font(cs) ||
        load_tiles("assets/king.grp", tiles)) return 0;
    printf("tiles=%016llx first=%02x%02x%02x%02x%02x%02x\n",
           fnv1a64(tiles, sizeof(tiles)), tiles[0], tiles[1], tiles[2],
           tiles[3], tiles[4], tiles[5]);
    zeliard_gmmcga_clear_playfield(vga, sizeof(vga));
    zeliard_gmmcga_draw_life_scale(vga, sizeof(vga), 0);
    printf("king:life=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_draw_town_text_record(vga, sizeof(vga), cs, sizeof(cs), 0xA41A);
    printf("king:header=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gtmcga_draw_room_grid(cs + 0xA16E, 96, tiles, sizeof(tiles),
                                  vga, sizeof(vga), 0x0E17);
    printf("king:grid=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_fill_frame(vga, sizeof(vga), 0x0D60, 0x3637, cs[0xFF77]);
    return fnv1a64(vga, sizeof(vga));
}

static unsigned long long render_sage(void) {
    u8 cs[0x10000] = {0}, tiles[0x3000] = {0}, vga[0x10000] = {0};
    if (load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0xA000, "assets/kenjpro.bin") || load_font(cs) ||
        load_tiles("assets/kenja.grp", tiles)) return 0;
    cs[0xC006] = 1; cs[0xBB12] = 0x17; cs[0xBB13] = 0x07;
    const u16 header = (u16)(cs[0xACBD] | (cs[0xACBE] << 8));
    printf("tiles=%016llx first=%02x%02x%02x%02x%02x%02x\n",
           fnv1a64(tiles, sizeof(tiles)), tiles[0], tiles[1], tiles[2],
           tiles[3], tiles[4], tiles[5]);
    zeliard_gmmcga_clear_playfield(vga, sizeof(vga));
    zeliard_gmmcga_draw_life_scale(vga, sizeof(vga), 0);
    zeliard_gmmcga_draw_town_text_record(vga, sizeof(vga), cs, sizeof(cs), header);
    printf("sage:loader=%016llx header=%04x\n",
           fnv1a64(vga, sizeof(vga)), header);
    zeliard_gtmcga_draw_room_grid(cs + 0xA9B6, 96, tiles, sizeof(tiles),
                                  vga, sizeof(vga), 0x0717);
    printf("sage:grid=%016llx\n", fnv1a64(vga, sizeof(vga)));
    zeliard_gmmcga_fill_frame(vga, sizeof(vga), 0x0D60, 0x3637, cs[0xFF77]);
    return fnv1a64(vga, sizeof(vga));
}

static unsigned long long render_omoya(void) {
    u8 cs[0x10000] = {0}, tiles[0x3000] = {0}, vga[0x10000] = {0};
    if (load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0xA000, "assets/omoypro.bin") || load_font(cs) ||
        load_tiles("assets/omoya.grp", tiles)) return 0;
    zeliard_gmmcga_clear_playfield(vga, sizeof(vga));
    zeliard_gmmcga_draw_life_scale(vga, sizeof(vga), 0);
    zeliard_gmmcga_draw_town_text_record(
        vga, sizeof(vga), cs, sizeof(cs), 0xA245);
    zeliard_gtmcga_draw_room_tile_grid(
        cs + 0xA129, 16u * 17u, 16, 17, tiles, sizeof(tiles),
        vga, sizeof(vga), 0x0C1E);
    return fnv1a64(vga, sizeof(vga));
}

static int runtime_round_trip(void) {
    u8 *cs = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
    if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
        free(cs); free(vga); free(room); return 0;
    }
    int ok = zeliard_room_enter(room, ZEL_ROOM_KING, cs, 0x10000,
                                vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xC3F7143FE6C981F1ULL;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    static const u8 zero[0x100] = {0};
    for (size_t offset = 0; offset < 0x1C00; offset += sizeof(zero))
        ok &= memcmp(cs + 0xA000 + offset, zero, sizeof(zero)) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xEB05052EA5B62325ULL;
    ok &= zeliard_room_enter(room, ZEL_ROOM_SAGE, cs, 0x10000,
                             vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0xA6873B3AD33ACEC7ULL;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    ok &= zeliard_room_enter(room, ZEL_ROOM_VIEWING, cs, 0x10000,
                             vga, 0x10000) == 0;
    ok &= fnv1a64(vga, 0x10000) == 0x1C86E94322A50C57ULL;
    ok &= !room->alternate_transition_requested;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    cs[0x0049] = 0xFF;
    ok &= zeliard_room_enter(room, ZEL_ROOM_VIEWING, cs, 0x10000,
                             vga, 0x10000) == 0;
    ok &= room->alternate_transition_requested;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    const struct {
        zeliard_room_kind_t kind;
        unsigned long long frame;
    } muralla_rooms[] = {
        {ZEL_ROOM_ARMORY, 0x12FD1F3947E28290ULL},
        {ZEL_ROOM_DRUGSTORE, 0xDD94A39161EEBD55ULL},
        {ZEL_ROOM_CHURCH, 0xBCD1421EFFE2E1B8ULL},
        {ZEL_ROOM_BANK, 0x41FC80F26CEF61FBULL},
    };
    cs[0xC006] = 1;
    for (size_t index = 0;
         index < sizeof(muralla_rooms) / sizeof(muralla_rooms[0]); ++index) {
        ok &= zeliard_room_enter(room, muralla_rooms[index].kind,
                                 cs, 0x10000, vga, 0x10000) == 0;
        const unsigned long long frame = fnv1a64(vga, 0x10000);
        printf("muralla_room_%u: frame=%016llx\n",
               (unsigned)muralla_rooms[index].kind, frame);
        ok &= frame == muralla_rooms[index].frame;
        if (muralla_rooms[index].kind == ZEL_ROOM_BANK) {
            u8 expected[0x10000];
            memcpy(expected, room->saved_vga, sizeof(expected));
            cs[ZEL_PLAYER_GOLD] = 0;
            cs[ZEL_PLAYER_GOLD + 1] = 0x41;
            cs[ZEL_PLAYER_GOLD + 2] = 0x01;
            cs[ZEL_PLAYER_ALMAS] = 7;
            cs[ZEL_PLAYER_ALMAS + 1] = 0;
            ok &= zeliard_gmmcga_draw_gold(
                      expected, sizeof(expected), cs, 0x10000) == 0;
            ok &= zeliard_gmmcga_draw_almas(
                      expected, sizeof(expected), cs, 0x10000) == 0;
            ok &= zeliard_room_leave(
                      room, cs, 0x10000, vga, 0x10000) == 0;
            ok &= memcmp(vga, expected, sizeof(expected)) == 0;
        } else {
            ok &= zeliard_room_leave(
                      room, cs, 0x10000, vga, 0x10000) == 0;
        }
    }
    free(cs); free(vga); free(room);
    return ok;
}

static int sage_life_hud_round_trip(void) {
    u8 *cs = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    u8 *expected = calloc(1, 0x10000);
    zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
    if (!cs || !vga || !expected || !room ||
        load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
        free(cs); free(vga); free(expected); free(room); return 0;
    }
    cs[ZEL_PLAYER_HP] = 0x40;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 0x40;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    zeliard_gmmcga_draw_life_scale(vga, 0x10000, 0);
    zeliard_gmmcga_draw_life_max(vga, 0x10000, cs, 0x10000);
    zeliard_gmmcga_draw_life_current(vga, 0x10000, cs, 0x10000);
    int ok = zeliard_room_enter(room, ZEL_ROOM_SAGE, cs, 0x10000,
                                vga, 0x10000) == 0;
    cs[ZEL_PLAYER_HP] = 0x80;
    cs[ZEL_PLAYER_HP_MAX] = 0x80;
    memcpy(expected, room->saved_vga, 0x10000);
    ok &= zeliard_gmmcga_draw_life_max(
              expected, 0x10000, cs, 0x10000) == 0;
    ok &= zeliard_gmmcga_draw_life_current(
              expected, 0x10000, cs, 0x10000) == 0;
    ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    ok &= memcmp(vga, expected, 0x10000) == 0;
    printf("sage_life_hud_round_trip: %s hp=%u/%u frame=%016llx\n",
           ok ? "PASS" : "FAIL", (unsigned)cs[ZEL_PLAYER_HP],
           (unsigned)cs[ZEL_PLAYER_HP_MAX], fnv1a64(vga, 0x10000));
    free(cs); free(vga); free(expected); free(room);
    return ok;
}

static unsigned long long frame_hash_without_rect(const u8 *frame,
                                                   u16 x, u16 y,
                                                   u16 width, u16 height) {
    u8 copy[0x10000];
    memcpy(copy, frame, sizeof(copy));
    for (u16 row = 0; row < height; ++row)
        memset(copy + (size_t)(y + row) * 320u + x, 0, width);
    return fnv1a64(copy, sizeof(copy));
}

static int church_script_flow(void) {
    u8 *cs = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
    if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
        load_raw(cs, 0x2000, "assets/gmmcga.bin") ||
        load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
        free(cs); free(vga); free(room); return 0;
    }
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 0x50;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0xC006] = 1;
    for (u8 index = 0; index < 7; ++index) {
        cs[ZEL_PLAYER_SPELL_CHARGES + index] = 0;
        cs[ZEL_PLAYER_SPELL_CHARGES_MAX + index] = (u8)(index + 2);
    }
    int ok = zeliard_room_enter(room, ZEL_ROOM_CHURCH, cs, 0x10000,
                                vga, 0x10000) == 0;
    unsigned ticks = 0;
    while (ok && !room->exit_requested && ticks++ < 20000) {
        if ((ticks % 400u) == 0) cs[0xFF1D] = 1;
        if (zeliard_room_advance_pit(room, cs, 0x10000, vga, 0x10000) < 0)
            ok = 0;
    }
    ok &= room->exit_requested && ticks < 20000;
    ok &= (u16)(cs[ZEL_PLAYER_HP] | ((u16)cs[ZEL_PLAYER_HP + 1] << 8)) == 0x50;
    printf("muralla_church_script: ticks=%u hp=%u exit=%u ip=%04x\n",
           ticks, (unsigned)(cs[ZEL_PLAYER_HP] |
           ((u16)cs[ZEL_PLAYER_HP + 1] << 8)), room->exit_requested,
           room->script_ip);
    free(cs); free(vga); free(room);
    return ok;
}

static int muralla_shop_menu_frames(void) {
    static const struct {
        zeliard_room_kind_t kind;
        unsigned long long frame;
    } cases[] = {
        {ZEL_ROOM_ARMORY, 0xD4A92FBE8A86E12AULL},
        {ZEL_ROOM_DRUGSTORE, 0xFCE58574B14C00FDULL},
        {ZEL_ROOM_BANK, 0x7B7375C7253142E3ULL},
    };
    int ok = 1;
    for (size_t index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
        if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
            load_raw(cs, 0x2000, "assets/gmmcga.bin") ||
            load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
            free(cs); free(vga); free(room); return 0;
        }
        cs[0xC006] = 1;
        int case_ok = zeliard_room_enter(
            room, cases[index].kind, cs, 0x10000, vga, 0x10000) == 0;
        unsigned ticks = 0;
        while (case_ok && !room->menu_active && !room->exit_requested &&
               ticks++ < 10000) {
            ++cs[0xFF1A];
            u16 timer = (u16)(cs[0xFF1B] | ((u16)cs[0xFF1C] << 8));
            ++timer; cs[0xFF1B] = (u8)timer; cs[0xFF1C] = (u8)(timer >> 8);
            zeliard_room_advance_pit(room, cs, 0x10000, vga, 0x10000);
        }
        const unsigned long long frame = fnv1a64(vga, 0x10000);
        printf("muralla_shop_menu_%u: ticks=%u active=%u frame=%016llx\n",
               (unsigned)cases[index].kind, ticks, room->menu_active, frame);
        if (getenv("ZELIARD_DUMP")) {
            char path[64];
            snprintf(path, sizeof(path), "build/shop-menu-c-%u.bin",
                     (unsigned)cases[index].kind);
            FILE *dump = fopen(path, "wb");
            if (dump) { fwrite(vga, 1, 0x10000, dump); fclose(dump); }
        }
        case_ok &= room->menu_active && frame == cases[index].frame;
        ok &= case_ok;
        free(cs); free(vga); free(room);
    }
    return ok;
}

static int muralla_shop_main_menu_routes(void) {
    static const struct {
        zeliard_room_kind_t kind;
        u8 selection;
        u16 script_ip;
    } cases[] = {
        {ZEL_ROOM_ARMORY, 0, 0xB1DE},
        {ZEL_ROOM_ARMORY, 1, 0xAE4A},
        {ZEL_ROOM_ARMORY, 2, 0xB026},
        {ZEL_ROOM_ARMORY, 3, 0xB081},
        {ZEL_ROOM_ARMORY, 4, 0xB11F},
        {ZEL_ROOM_DRUGSTORE, 0, 0xAB0E},
        {ZEL_ROOM_DRUGSTORE, 1, 0xA88C},
        {ZEL_ROOM_DRUGSTORE, 2, 0xAA79},
        {ZEL_ROOM_DRUGSTORE, 3, 0xAAA6},
        {ZEL_ROOM_BANK, 0, 0xAC5A},
        {ZEL_ROOM_BANK, 1, 0xA9B2},
        {ZEL_ROOM_BANK, 2, 0xAAA1},
        {ZEL_ROOM_BANK, 3, 0xAB32},
        {ZEL_ROOM_BANK, 4, 0xABF7},
    };
    int ok = 1;
    for (size_t index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
        if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
            load_raw(cs, 0x2000, "assets/gmmcga.bin") ||
            load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
            free(cs); free(vga); free(room); return 0;
        }
        cs[0xC006] = 1;
        int case_ok = zeliard_room_enter(
            room, cases[index].kind, cs, 0x10000, vga, 0x10000) == 0;
        unsigned ticks = 0;
        while (case_ok && !room->menu_active && !room->exit_requested &&
               ticks++ < 10000) {
            ++cs[0xFF1A];
            u16 timer = (u16)(cs[0xFF1B] | ((u16)cs[0xFF1C] << 8));
            ++timer; cs[0xFF1B] = (u8)timer; cs[0xFF1C] = (u8)(timer >> 8);
            case_ok &= zeliard_room_advance_pit(
                room, cs, 0x10000, vga, 0x10000) >= 0;
        }
        room->menu_selection = cases[index].selection;
        cs[0xFF1D] = 1;
        case_ok &= zeliard_room_advance_pit(
            room, cs, 0x10000, vga, 0x10000) >= 0;
        case_ok &= !room->menu_active && room->script_ip == cases[index].script_ip;
        printf("muralla_shop_route_%u_%u: ip=%04x expected=%04x\n",
               (unsigned)cases[index].kind, cases[index].selection,
               room->script_ip, cases[index].script_ip);
        ok &= case_ok;
        free(cs); free(vga); free(room);
    }
    return ok;
}

static int vm_reach_menu(u8 *cs, u8 *vga, unsigned *ticks) {
    while (zeliard_room_masm_vm_active() &&
           zeliard_room_masm_vm_input_kind() != ZEL_ROOM_VM_INPUT_MENU &&
           (*ticks)++ < 6000) {
        const u8 acknowledge = zeliard_room_masm_vm_input_kind() ==
            ZEL_ROOM_VM_INPUT_TEXT;
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0)) return 0;
    }
    return zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
}

static int muralla_release_vm_menu_frames(void) {
    static const struct {
        zeliard_room_kind_t kind;
        unsigned long long frame;
        unsigned long long invariant_frame;
    } cases[] = {
        {ZEL_ROOM_ARMORY, 0xF3074246AE808D8CULL, 0},
        {ZEL_ROOM_DRUGSTORE, 0, 0x5B1F8B094F9EF6FBULL},
        {ZEL_ROOM_BANK, 0xC2530EBABD5407A1ULL, 0},
    };
    int ok = 1;
    for (size_t index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
            free(cs); free(vga); return 0;
        }
        cs[0xC006] = 1;
        int case_ok = zeliard_room_masm_vm_start(
            cases[index].kind, cs, 0x10000, vga, 0x10000);
        unsigned ticks = 0;
        case_ok &= vm_reach_menu(cs, vga, &ticks);
        const unsigned long long frame = fnv1a64(vga, 0x10000);
        const unsigned long long invariant = cases[index].invariant_frame ?
            frame_hash_without_rect(vga, 104, 24, 47, 47) : frame;
        if (getenv("ZELIARD_DUMP")) {
            char path[64];
            snprintf(path, sizeof(path), "build/shop-menu-vm-%u.bin",
                     (unsigned)cases[index].kind);
            FILE *dump = fopen(path, "wb");
            if (dump) { fwrite(vga, 1, 0x10000, dump); fclose(dump); }
        }
        printf("muralla_release_vm_menu_%u: ticks=%u ip=%04x "
               "frame=%016llx invariant=%016llx\n",
               (unsigned)cases[index].kind, ticks,
               zeliard_room_masm_vm_ip(), frame, invariant);
        case_ok &= zeliard_room_masm_vm_input_kind() ==
                       ZEL_ROOM_VM_INPUT_MENU &&
                   invariant == (cases[index].invariant_frame ?
                       cases[index].invariant_frame : cases[index].frame);
        ok &= case_ok;
        free(cs); free(vga);
    }
    return ok;
}

static int muralla_release_vm_browser_space(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    zel_input_state_t input;
    zel_input_init(&input, cs);
    zel_input_advance_pit(&input, cs, 10);
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const u16 menu_ip = zeliard_room_masm_vm_ip();
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    u8 menu_layout[6];
    memcpy(menu_layout, cs + 0xFF52, sizeof(menu_layout));
    zel_input_key_down(&input, cs, ZEL_INPUT_KEY_SPACE);
    u8 saw_space = 0;
    for (u8 tick = 0; ok && tick < 10; ++tick) {
        zel_input_advance_pit(&input, cs, 1);
        saw_space |= cs[0xFF1D];
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, cs[0xFF1D], 0);
    }
    const unsigned long long selected_frame = fnv1a64(vga, 0x10000);
    ok &= saw_space && (selected_frame != menu_frame ||
          memcmp(menu_layout, cs + 0xFF52, sizeof(menu_layout)) != 0);
    printf("muralla_release_vm_browser_space: ticks=%u ip=%04x>%04x "
           "kind=%d space=%02x frame=%016llx>%016llx "
           "layout=%02x/%02x>%02x/%02x edge=%02x\n", ticks, menu_ip,
           zeliard_room_masm_vm_ip(), zeliard_room_masm_vm_input_kind(),
           cs[0xFF1D], menu_frame, selected_frame,
           menu_layout[0], menu_layout[1], cs[0xFF52], cs[0xFF53],
           saw_space);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int vm_run_to_next_poll(u8 *cs, u8 *vga, u8 direction, u8 space,
                               unsigned *ticks);

static int muralla_release_vm_held_space_edge(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 confirm_ip = zeliard_room_masm_vm_ip();
    const int confirm_kind = zeliard_room_masm_vm_input_kind();

    u16 result_ip = confirm_ip;
    int result_kind = confirm_kind;
    for (unsigned tick = 0; ok && tick < 200 &&
         result_ip == confirm_ip && result_kind == confirm_kind; ++tick) {
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
        if (zeliard_room_masm_vm_at_input_poll()) {
            result_ip = zeliard_room_masm_vm_ip();
            result_kind = zeliard_room_masm_vm_input_kind();
        }
    }
    const unsigned long long result_frame = fnv1a64(vga, 0x10000);
    for (unsigned tick = 0; ok && tick < 25; ++tick)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    const u16 held_ip = zeliard_room_masm_vm_ip();
    const unsigned long long held_frame = fnv1a64(vga, 0x10000);
    ok &= (result_ip != confirm_ip || result_kind != confirm_kind) &&
          held_ip == result_ip && held_frame == result_frame &&
          zeliard_room_masm_vm_input_kind() == result_kind;
    printf("muralla_release_vm_held_space: ip=%04x/%d>%04x/%d=%04x/%d "
           "frame=%016llx/%016llx\n", confirm_ip, confirm_kind,
           result_ip, result_kind, held_ip,
           zeliard_room_masm_vm_input_kind(), result_frame, held_frame);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_armory_exit(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const u8 greeting_cue = zeliard_room_masm_vm_take_sound_cue();
    printf("muralla_release_vm_armory_audio: cue=%02x\n", greeting_cue);
    ok &= greeting_cue == 0x05;
    ok &= zeliard_room_masm_vm_advance(
        cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 4000) {
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0,
            zeliard_room_masm_vm_at_input_poll(), 0);
    }
    ok &= !zeliard_room_masm_vm_active();
    printf("muralla_release_vm_armory_exit: ticks=%u active=%d\n",
           ticks, zeliard_room_masm_vm_active());
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int vm_run_to_next_poll(u8 *cs, u8 *vga, u8 direction, u8 space,
                               unsigned *ticks) {
    if (!zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, direction, space, 0)) return 0;
    while (zeliard_room_masm_vm_active() &&
           !zeliard_room_masm_vm_at_input_poll() && (*ticks)++ < 6000)
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, 0, 0)) return 0;
    return 1;
}

static int satono_release_vm_inn_rest(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 2;
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 80;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0; cs[0x86] = 100; cs[0x87] = 0;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_INN, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 16000) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("satono_release_vm_inn: ticks=%u active=%d hp=%u gold=%u "
           "menu=%016llx\n", ticks, zeliard_room_masm_vm_active(), hp,
           gold, menu_frame);
    ok &= menu_frame == 0x0032097AB091434EULL &&
          !zeliard_room_masm_vm_active() && hp == 80 && gold == 70;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int tumba_release_vm_inn_rest(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 5;
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 80;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0; cs[0x86] = 150; cs[0x87] = 0;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_INN, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 16000) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("tumba_release_vm_inn: ticks=%u active=%d hp=%u gold=%u "
           "menu=%016llx\n", ticks, zeliard_room_masm_vm_active(), hp,
           gold, menu_frame);
    ok &= menu_frame == 0x6C45F923639FA67FULL &&
          !zeliard_room_masm_vm_active() && hp == 80 && gold == 50;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int vm_browser_space_pulse(zel_input_state_t *input,
                                  u8 *cs, u8 *vga, unsigned *ticks) {
    const u16 start_ip = zeliard_room_masm_vm_ip();
    const int start_kind = zeliard_room_masm_vm_input_kind();
    const unsigned long long start_frame = fnv1a64(vga, 0x10000);
    int progressed = 0;
    int sampled = 0;
    zel_input_key_down(input, cs, ZEL_INPUT_KEY_SPACE);
    for (unsigned tick = 0; tick < 2000; ++tick) {
        zel_input_advance_pit(input, cs, 1);
        sampled |= cs[0xFF1D] != 0;
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, cs[0xFF1D], 0))
            return 0;
        ++*ticks;
        progressed |= zeliard_room_masm_vm_ip() != start_ip ||
                      zeliard_room_masm_vm_input_kind() != start_kind ||
                      fnv1a64(vga, 0x10000) != start_frame;
        if (sampled && progressed && zeliard_room_masm_vm_at_input_poll()) break;
    }
    zel_input_key_up(input, cs, ZEL_INPUT_KEY_SPACE);
    /* stick.asm samples the released raw key at one of its five-PIT
     * subsample boundaries before it can emit another Space action. */
    for (unsigned tick = 0; tick < 5; ++tick) {
        zel_input_advance_pit(input, cs, 1);
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, cs[0xFF1D], 0))
            return 0;
        ++*ticks;
    }
    return sampled && progressed && zeliard_room_masm_vm_at_input_poll();
}

static int muralla_release_vm_drugstore_text_repress(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_DRUGSTORE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    zel_input_state_t input;
    zel_input_init(&input, cs);
    zel_input_advance_pit(&input, cs, 10);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    /* 215DRUGP: Description -> question -> item menu -> item intro ->
     * Ken'ko's multi-page description. Each slash is a fresh key wait. */
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT;
    const unsigned long long intro_frame = fnv1a64(vga, 0x10000);
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT;
    const unsigned long long description_frame = fnv1a64(vga, 0x10000);
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    ok &= intro_frame != description_frame;
    const unsigned long long shop_menu_backdrop =
        frame_rect_hash(vga, 156, 34, 112, 45);
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    const unsigned long long second_list_backdrop =
        frame_rect_hash(vga, 156, 34, 112, 45);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT;
    const unsigned long long second_intro_backdrop =
        frame_rect_hash(vga, 156, 34, 112, 45);
    ok &= second_list_backdrop == shop_menu_backdrop &&
          second_intro_backdrop == shop_menu_backdrop;
    for (unsigned page = 0; ok && page < 12 &&
         zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT; ++page)
        ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    for (unsigned page = 0; ok && page < 12 &&
         zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT; ++page)
        ok &= vm_browser_space_pulse(&input, cs, vga, &ticks);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    const unsigned long long returned_menu_backdrop =
        frame_rect_hash(vga, 156, 34, 112, 45);
    ok &= returned_menu_backdrop == shop_menu_backdrop;
    printf("muralla_release_vm_drugstore_text_repress: ticks=%u "
           "frames=%016llx>%016llx backdrop=%016llx/%016llx/%016llx/%016llx "
           "kind=%d\n", ticks, intro_frame, description_frame,
           shop_menu_backdrop, second_list_backdrop, second_intro_backdrop,
           returned_menu_backdrop, zeliard_room_masm_vm_input_kind());
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_armory_buy(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    cs[ZEL_PLAYER_SWORD] = 2;
    cs[0x85] = 0; cs[0x86] = 0xE8; cs[0x87] = 0x03;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    const unsigned long long sword_frame = frame_rect_hash(
        vga, 192, 171, 20, 18);
    printf("muralla_release_vm_armory_buy: ticks=%u gold=%u sword=%u "
           "inventory=%02x frame=%016llx\n", ticks, gold, cs[0x92],
           cs[0xD2], sword_frame);
    /* 212ARMRP:weapon_commit replaces player:sword; there is no carried
     * sword array. The old tier is returned through script_give_item. */
    ok &= cs[0x92] == 1 && gold == 1350 && cs[0xD2] == 0xC0 &&
          sword_frame == 0xACE1EEC895369B0AULL;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_wise_man_sword_buy(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    cs[ZEL_PLAYER_SWORD] = 1;
    cs[0x85] = 0; cs[0x86] = 0x10; cs[0x87] = 0x27;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    /* Muralla stocks Training and Wise Man's swords. Move to the second
     * release-MASM list entry before accepting the trade. */
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    const unsigned long long sword_frame = frame_rect_hash(
        vga, 192, 171, 20, 18);
    printf("muralla_release_vm_wise_man_sword: ticks=%u gold=%u sword=%u "
           "inventory=%02x frame=%016llx\n", ticks, gold, cs[0x92],
           cs[0xD2], sword_frame);
    /* 1500-gold purchase less the native 200-gold Training Sword trade. */
    ok &= cs[0x92] == 2 && gold == 8700 && cs[0xD2] == 0xC0 &&
          sword_frame == 0x077A65ACB967926DULL;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int bosque_release_vm_spirit_sword_buy(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 3;
    cs[ZEL_PLAYER_SWORD] = 2;
    cs[0x85] = 0; cs[0x86] = 0x20; cs[0x87] = 0x4E;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    /* Bosque's release inventory exposes Spirit Sword as list entry 3. */
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    const unsigned long long sword_frame = frame_rect_hash(
        vga, 192, 171, 20, 18);
    printf("bosque_release_vm_spirit_sword: ticks=%u gold=%u sword=%u "
           "inventory=%02x frame=%016llx\n", ticks, gold, cs[0x92],
           cs[0xD4], sword_frame);
    /* 7500-gold purchase less the native 1450-gold Wise Man trade. */
    ok &= cs[0x92] == 3 && gold == 13950 && cs[0xD4] == 0xE0 &&
          sword_frame == 0xA8A66214ADC1AFD1ULL;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int tumba_release_vm_knight_sword_trade(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 5;
    cs[0x24] = 0x80;
    cs[0x9B] = 0xFF;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 12000 &&
           !(cs[ZEL_PLAYER_SWORD] == 4 && cs[0x9B] == 0 &&
             (cs[0xD6] & 0x10) == 0 && (cs[0x24] & 2) != 0)) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const unsigned long long sword_frame = frame_rect_hash(
        vga, 192, 171, 20, 18);
    const int traded = cs[ZEL_PLAYER_SWORD] == 4 && cs[0x9B] == 0 &&
        (cs[0xD6] & 0x10) == 0 && (cs[0x24] & 2) != 0;
    printf("tumba_release_vm_knight_trade: ticks=%u traded=%d sword=%u "
           "crest=%02x inventory=%02x state=%02x frame=%016llx\n",
           ticks, traded, cs[ZEL_PLAYER_SWORD], cs[0x9B], cs[0xD6],
           cs[0x24], sword_frame);
    ok &= traded && cs[0xD6] == 0x60 && cs[0x24] == 0x82 &&
          sword_frame == 0xD8DEE0CB628E0F10ULL;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_armory_replace_shield(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    cs[ZEL_PLAYER_SHIELD] = 2;
    cs[ZEL_PLAYER_SHIELD_HP] = 1;
    cs[ZEL_PLAYER_SHIELD_HP_MAX] = 1;
    cs[0x85] = 0; cs[0x86] = 0xE8; cs[0x87] = 0x03;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    const u16 shield_hp = (u16)(cs[ZEL_PLAYER_SHIELD_HP] |
        ((u16)cs[ZEL_PLAYER_SHIELD_HP + 1] << 8));
    const u16 shield_max = (u16)(cs[ZEL_PLAYER_SHIELD_HP_MAX] |
        ((u16)cs[ZEL_PLAYER_SHIELD_HP_MAX + 1] << 8));
    const unsigned long long shield_frame = frame_rect_hash(
        vga, 246, 164, 24, 32);
    const unsigned long long shield_icon = frame_rect_hash(
        vga, 250, 164, 16, 16);
    const unsigned long long shield_field = frame_rect_hash(
        vga, 246, 186, 24, 10);
    printf("muralla_release_vm_armory_shield: ticks=%u gold=%u shield=%u "
           "hp=%u/%u inventory=%02x frame=%016llx icon=%016llx "
           "field=%016llx\n",
           ticks, gold,
           cs[ZEL_PLAYER_SHIELD], shield_hp, shield_max, cs[0xDB],
           shield_frame, shield_icon, shield_field);
    ok &= cs[ZEL_PLAYER_SHIELD] == 1 && gold == 1025 &&
        shield_hp == 30 && shield_max == 30 && cs[0xDB] == 0xC0 &&
        shield_frame == 0xE611803CA6AB2963ULL &&
        shield_icon == 0x18FDBA10EBC3FCC6ULL &&
        shield_field == 0x741B4FFF4B27D4F0ULL;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_church_heal(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 0x50;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0xC006] = 1;
    for (u8 index = 0; index < 7; ++index) {
        cs[ZEL_PLAYER_SPELL_CHARGES + index] = 0;
        cs[ZEL_PLAYER_SPELL_CHARGES_MAX + index] = (u8)(index + 2);
    }
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_CHURCH, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 12000)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0,
            zeliard_room_masm_vm_at_input_poll(), 0);
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
                         ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    int charges = 1;
    for (u8 index = 0; index < 7; ++index)
        charges &= cs[ZEL_PLAYER_SPELL_CHARGES + index] ==
                   cs[ZEL_PLAYER_SPELL_CHARGES_MAX + index];
    ok &= !zeliard_room_masm_vm_active() && hp == 0x50 && charges;
    printf("muralla_release_vm_church: ticks=%u hp=%u charges=%d active=%d\n",
           ticks, hp, charges, zeliard_room_masm_vm_active());
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int esco_release_vm_church_free_heal(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 0x50;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0;
    cs[0x86] = 123;
    cs[0x87] = 0;
    cs[0xC006] = 9;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_CHURCH, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 12000)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0,
            zeliard_room_masm_vm_at_input_poll(), 0);
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
                         ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    ok &= !zeliard_room_masm_vm_active() && hp == 0x50 && gold == 123;
    printf("esco_release_vm_church: ticks=%u hp=%u gold=%u active=%d\n",
           ticks, hp, gold, zeliard_room_masm_vm_active());
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_drug_buy(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x85] = 0; cs[0x86] = 0xE8; cs[0x87] = 0x03;
    cs[0xC006] = 1;
    u8 before[0x20];
    memcpy(before, cs + ZEL_PLAYER_ITEM_SLOTS, sizeof(before));
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_DRUGSTORE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    const int inventory_changed =
        memcmp(before, cs + ZEL_PLAYER_ITEM_SLOTS, sizeof(before)) != 0;
    printf("muralla_release_vm_drug_buy: ticks=%u gold=%06x "
           "inventory_changed=%d script=%04x kind=%d\n", ticks, gold,
           inventory_changed,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= gold == 950 && inventory_changed;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 10; cs[0x8C] = 0; cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("muralla_release_vm_bank_exchange: ticks=%u almas=%u "
           "gold=%06x script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 60;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int tumba_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 10; cs[0x8C] = 0; cs[0xC006] = 5;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("tumba_release_vm_bank_exchange: ticks=%u almas=%u "
           "gold=%06x script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 20;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int dorado_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 10; cs[0x8C] = 0; cs[0xC006] = 6;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("dorado_release_vm_bank_exchange: ticks=%u almas=%u "
           "gold=%06x script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 40;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int dorado_release_vm_inn_rest(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 6;
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 80;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0; cs[0x86] = 200; cs[0x87] = 0;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_INN, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 16000) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("dorado_release_vm_inn: ticks=%u active=%d hp=%u gold=%u "
           "menu=%016llx\n", ticks, zeliard_room_masm_vm_active(), hp,
           gold, menu_frame);
    ok &= menu_frame == 0xCB2CB42DC0F50DFFULL &&
          !zeliard_room_masm_vm_active() && hp == 80 && gold == 50;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int llama_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 8; cs[0x8C] = 0; cs[0xC006] = 7;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("llama_release_vm_bank_exchange: ticks=%u almas=%u "
           "gold=%06x script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 4;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int llama_release_vm_inn_rest(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 7;
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 80;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0; cs[0x86] = 250; cs[0x87] = 0;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_INN, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 16000) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("llama_release_vm_inn: ticks=%u active=%d hp=%u gold=%u "
           "menu=%016llx\n", ticks, zeliard_room_masm_vm_active(), hp,
           gold, menu_frame);
    ok &= menu_frame == 0x8DCAFD5210EE9F71ULL &&
          !zeliard_room_masm_vm_active() && hp == 80 && gold == 50;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int pureza_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 10; cs[0x8C] = 0; cs[0xC006] = 8;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("pureza_release_vm_bank_exchange: ticks=%u almas=%u "
           "gold=%06x script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 60;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int esco_release_vm_bank_exchange(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0x8B] = 10; cs[0x8C] = 0; cs[0xC006] = 9;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u16 almas = (u16)(cs[0x8B] | ((u16)cs[0x8C] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("esco_release_vm_bank_exchange: ticks=%u almas=%u gold=%06x "
           "script=%04x kind=%d\n", ticks, almas, gold,
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           zeliard_room_masm_vm_input_kind());
    ok &= almas == 0 && gold == 80;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int pureza_release_vm_inn_rest(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 8;
    cs[ZEL_PLAYER_HP] = 8;
    cs[ZEL_PLAYER_HP + 1] = 0;
    cs[ZEL_PLAYER_HP_MAX] = 80;
    cs[ZEL_PLAYER_HP_MAX + 1] = 0;
    cs[0x85] = 0; cs[0x86] = 0xC2; cs[0x87] = 0x01;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_INN, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long menu_frame = fnv1a64(vga, 0x10000);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() && ticks++ < 16000) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0);
    }
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u32 gold = ((u32)cs[0x85] << 16) |
                     ((u32)cs[0x87] << 8) | cs[0x86];
    printf("pureza_release_vm_inn: ticks=%u active=%d hp=%u gold=%u "
           "menu=%016llx\n", ticks, zeliard_room_masm_vm_active(), hp,
           gold, menu_frame);
    ok &= menu_frame == 0xC9D30811879513B9ULL &&
          !zeliard_room_masm_vm_active() && hp == 80 && gold == 50;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static u32 bank_amount(const u8 *cs) {
    return ((u32)cs[0xAD29] << 16) |
           (u16)(cs[0xAD2A] | ((u16)cs[0xAD2B] << 8));
}

static int bank_reach_amount_selector(u8 *cs, u8 *vga, u8 menu_row,
                                      unsigned *ticks) {
    if (!vm_reach_menu(cs, vga, ticks)) return 0;
    for (u8 row = 0; row < menu_row; ++row)
        if (!vm_run_to_next_poll(cs, vga, 2, 0, ticks)) return 0;

    for (unsigned step = 0; step < 8000; ++step) {
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll();
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0)) return 0;
        ++*ticks;
        if (acknowledge && !zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, 0, 0)) return 0;
        if (cs[0xAD2F] == 0x23 &&
            (cs[0xAD2C] || cs[0xAD2D] || cs[0xAD2E])) return 1;
    }
    return 0;
}

static int muralla_release_vm_bank_amount_input(u8 withdraw) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    /* 213BANKP copies the selected account's 24-bit balance into AD2C:AD2E. */
    if (withdraw) {
        cs[0x88] = 0; cs[0x89] = 0xE8; cs[0x8A] = 0x03;
    } else {
        cs[0x85] = 0; cs[0x86] = 0xE8; cs[0x87] = 0x03;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_BANK, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= bank_reach_amount_selector(cs, vga, withdraw ? 3 : 2, &ticks);

    unsigned change_ticks[64] = {0};
    size_t change_count = 0;
    u32 previous = bank_amount(cs);
    for (unsigned held = 1; ok && held <= 500; ++held) {
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 1, 0, 0);
        const u32 amount = bank_amount(cs);
        if (amount != previous && change_count < 64) {
            change_ticks[change_count++] = held;
            previous = amount;
        }
    }
    const u32 selected = bank_amount(cs);
    const unsigned first_gap = change_count > 2
        ? change_ticks[2] - change_ticks[1] : 0;
    const unsigned last_gap = change_count > 2
        ? change_ticks[change_count - 1] - change_ticks[change_count - 2] : 0;
    ok &= change_count == 20 && selected == 20 &&
          first_gap == 34 && last_gap == 17;

    /* query_input_state returns the held Space mask in AH bit 0. */
    cs[0xFF16] = 1;
    for (unsigned held = 0; ok && held < 20; ++held)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    cs[0xFF16] = 0;
    for (unsigned settle = 0; ok && settle < 2000; ++settle) {
        if (zeliard_room_masm_vm_at_input_poll()) break;
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 0, 0);
    }
    const u32 carried = ((u32)cs[0x85] << 16) |
        (u16)(cs[0x86] | ((u16)cs[0x87] << 8));
    const u32 banked = ((u32)cs[0x88] << 16) |
        (u16)(cs[0x89] | ((u16)cs[0x8A] << 8));
    ok &= withdraw ? (carried == selected && banked == 1000 - selected)
                   : (carried == 1000 - selected && banked == selected);
    printf("muralla_release_vm_bank_%s: ticks=%u changes=%u amount=%u "
           "gaps=%u>%u carried=%u banked=%u delay=%u\n",
           withdraw ? "withdraw" : "deposit", ticks,
           (unsigned)change_count, selected, first_gap, last_gap,
           carried, banked, cs[0xAD2F]);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int king_branch_selection(void) {
    u8 cs[0x10000] = {0};
    int ok = zeliard_king_select_script(cs, sizeof(cs)) == 0xA42F;
    cs[5] = 0xFF;
    ok &= zeliard_king_select_script(cs, sizeof(cs)) == 0xA53C;
    cs[6] = 0xFF;
    ok &= zeliard_king_select_script(cs, sizeof(cs)) == 0xA5D2;
    cs[0x49] = 0xFF;
    ok &= zeliard_king_select_script(cs, sizeof(cs)) == 0xA6C1;
    return ok;
}

static int prompt_clear_service(void) {
    u8 vga[0x10000];
    for (size_t index = 0; index < sizeof(vga); ++index)
        vga[index] = (u8)(index * 17u + 3u);
    int ok = zeliard_gmmcga_clear_rect(
        vga, sizeof(vga), 0x278B, 0x020A) == 0;
    ok &= fnv1a64(vga, sizeof(vga)) == 0x18ADDA5D7FCDF1E5ULL;
    return ok;
}

static int king_first_visit_script(void) {
    u8 *cs = calloc(1, 0x10000);
    u8 *vga = calloc(1, 0x10000);
    zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
    if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
        load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
        free(cs); free(vga); free(room); return 0;
    }
    int ok = zeliard_room_enter(room, ZEL_ROOM_KING, cs, 0x10000,
                                vga, 0x10000) == 0;
    ok &= room->script_ip == 0xA42F;
    ok &= (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)) == 0xA42F;
    u32 ticks = 0;
    u16 wait_ips[16] = {0};
    u8 wait_y[16] = {0}, wait_lines[16] = {0}, wait_prompt[16] = {0};
    size_t wait_count = 0;
    while (ok && !room->exit_requested && ticks < 30000) {
        cs[0xFF1A]++;
        u16 timer = (u16)(cs[0xFF1B] | ((u16)cs[0xFF1C] << 8));
        ++timer; cs[0xFF1B] = (u8)timer; cs[0xFF1C] = (u8)(timer >> 8);
        timer = (u16)(cs[0xFF50] | ((u16)cs[0xFF51] << 8));
        ++timer; cs[0xFF50] = (u8)timer; cs[0xFF51] = (u8)(timer >> 8);
        if (room->script_state == 2) {
            if (wait_count < sizeof(wait_ips) / sizeof(wait_ips[0])) {
                wait_ips[wait_count] = room->script_ip;
                wait_y[wait_count] = cs[0xFF4F];
                wait_lines[wait_count] = cs[0x7C52];
                wait_prompt[wait_count] = room->script_prompt_after_scroll;
                ++wait_count;
            }
            cs[0xFF1D] = 0xFF;
        }
        ok &= zeliard_room_advance_pit(room, cs, 0x10000,
                                       vga, 0x10000) >= 0;
        ++ticks;
    }
    const u32 gold = ((u32)cs[0x85] << 16) |
                     (u16)(cs[0x86] | ((u16)cs[0x87] << 8));
    ok &= room->exit_requested && ticks < 30000;
    static const u16 expected_wait_ips[] = {0xA49F, 0xA516, 0xA53A};
    static const u8 expected_wait_y[] = {4, 4, 4};
    static const u8 expected_wait_lines[] = {4, 4, 1};
    static const u8 expected_wait_prompt[] = {1, 1, 0};
    ok &= wait_count == sizeof(expected_wait_ips) / sizeof(expected_wait_ips[0]);
    for (size_t index = 0;
         index < wait_count && index < sizeof(expected_wait_ips) / sizeof(expected_wait_ips[0]);
         ++index) {
        ok &= wait_ips[index] == expected_wait_ips[index] &&
              wait_y[index] == expected_wait_y[index] &&
              wait_lines[index] == expected_wait_lines[index] &&
              wait_prompt[index] == expected_wait_prompt[index];
    }
    const u8 completed = room->exit_requested;
    ok &= gold == 1000;
    ok &= cs[5] == 0xFF;
    ok &= cs[0xFF4C] == 0x3C && cs[0xFF4D] == 0xA5;
    u8 *expected_town = calloc(1, 0x10000);
    ok &= expected_town != NULL;
    if (expected_town) {
        ok &= zeliard_gmmcga_draw_gold(expected_town, 0x10000,
                                        cs, 0x10000) == 0;
        ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
        ok &= memcmp(vga, expected_town, 0x10000) == 0;
    }
    printf("king_script: ticks=%u gold=%u ip=%02x%02x exit=%u\n",
           ticks, gold, cs[0xFF4D], cs[0xFF4C], completed);
    printf("king_first_waits:");
    for (size_t index = 0; index < wait_count; ++index)
        printf(" %04x/y%u/l%u/p%u", wait_ips[index], wait_y[index],
               wait_lines[index], wait_prompt[index]);
    printf("\n");
    free(expected_town); free(cs); free(vga); free(room);
    return ok;
}

static int king_followup_scripts(void) {
    static const struct {
        u8 flag_a, flag_b, quest;
        u16 start;
        u16 automatic_wait;
        u16 explicit_wait;
    } cases[] = {
        {0xFF, 0x00, 0x00, 0xA53C, 0xA5A7, 0xA5D0},
        {0xFF, 0xFF, 0x00, 0xA5D2, 0xA651, 0xA6BF},
        {0xFF, 0xFF, 0xFF, 0xA6C1, 0xA739, 0xA79B},
    };
    int ok = 1;
    for (size_t index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        zeliard_room_runtime_t *room = calloc(1, sizeof(*room));
        if (!cs || !vga || !room || load_raw(cs, 0, "assets/stdply.bin") ||
            load_payload(cs, 0x6000, "assets/town.bin") || load_font(cs)) {
            free(cs); free(vga); free(room); return 0;
        }
        cs[5] = cases[index].flag_a;
        cs[6] = cases[index].flag_b;
        cs[0x49] = cases[index].quest;
        cs[0x86] = 0x41; cs[0x87] = 0x01; /* 321 gold */
        ok &= zeliard_room_enter(room, ZEL_ROOM_KING, cs, 0x10000,
                                 vga, 0x10000) == 0;
        ok &= room->script_ip == cases[index].start;
        u32 ticks = 0;
        u16 wait_ips[16] = {0};
        u8 wait_prompt[16] = {0};
        size_t wait_count = 0;
        while (ok && !room->exit_requested && ticks < 30000) {
            ++cs[0xFF1A];
            u16 timer = (u16)(cs[0xFF1B] | ((u16)cs[0xFF1C] << 8));
            ++timer; cs[0xFF1B] = (u8)timer; cs[0xFF1C] = (u8)(timer >> 8);
            timer = (u16)(cs[0xFF50] | ((u16)cs[0xFF51] << 8));
            ++timer; cs[0xFF50] = (u8)timer; cs[0xFF51] = (u8)(timer >> 8);
            if (room->script_state == 2) {
                if (wait_count < sizeof(wait_ips) / sizeof(wait_ips[0])) {
                    wait_ips[wait_count] = room->script_ip;
                    wait_prompt[wait_count] = room->script_prompt_after_scroll;
                    ++wait_count;
                }
                cs[0xFF1D] = 0xFF;
            }
            ok &= zeliard_room_advance_pit(room, cs, 0x10000,
                                           vga, 0x10000) >= 0;
            ++ticks;
        }
        const u32 gold = ((u32)cs[0x85] << 16) |
                         (u16)(cs[0x86] | ((u16)cs[0x87] << 8));
        ok &= room->exit_requested && ticks < 30000 && gold == 321;
        ok &= wait_count == 2 && wait_ips[0] == cases[index].automatic_wait &&
              wait_ips[1] == cases[index].explicit_wait &&
              wait_prompt[0] == 1 && wait_prompt[1] == 0;
        printf("king_script_%04x: ticks=%u gold=%u exit=%u\n",
               cases[index].start, ticks, gold, room->exit_requested);
        printf("king_waits_%04x:", cases[index].start);
        for (size_t wait = 0; wait < wait_count; ++wait)
            printf(" %04x", wait_ips[wait]);
        printf("\n");
        free(cs); free(vga); free(room);
    }
    return ok;
}

static int sage_release_vm_menu(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    /* 106TOWN stores one-based sage id 1 for Marid before entering KENJP. */
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const unsigned long long frame = fnv1a64(vga, 0x10000);
    const u16 script = (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8));
    printf("sage_release_vm_menu: ticks=%u ip=%04x script=%04x "
           "kind=%d frame=%016llx\n", ticks, zeliard_room_masm_vm_ip(),
           script, zeliard_room_masm_vm_input_kind(), frame);
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int muralla_release_vm_cursor_slide(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_ARMORY, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    unsigned long long previous = fnv1a64(vga, 0x10000);
    unsigned changed_frames = 0;
    unsigned slide_ticks = 0;
    for (; ok && slide_ticks < 60; ++slide_ticks) {
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1,
            slide_ticks == 0 ? 2 : 0, 0, 0);
        const unsigned long long frame = fnv1a64(vga, 0x10000);
        if (frame != previous) {
            ++changed_frames;
            previous = frame;
        }
        if (slide_ticks > 0 &&
            zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU)
            break;
    }
    ok &= changed_frames >= 9 && slide_ticks >= 36 && slide_ticks <= 45;
    printf("muralla_release_vm_cursor_slide: %s ticks=%u frames=%u "
           "row=%u\n", ok ? "PASS" : "FAIL", slide_ticks,
           changed_frames, cs[0xFF56]);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int sage_release_vm_ignores_early_direction(void) {
    int ok = 1;
    for (u8 direction = 1; direction <= 2; ++direction) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
            free(cs); free(vga); return 0;
        }
        cs[0xC006] = 1;
        int case_ok = zeliard_room_masm_vm_start(
            ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
        unsigned ticks = 0;
        while (case_ok && zeliard_room_masm_vm_active() &&
               zeliard_room_masm_vm_input_kind() != ZEL_ROOM_VM_INPUT_TEXT &&
               ticks++ < 6000) {
            case_ok &= zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, direction, 0, 0);
        }
        case_ok &= zeliard_room_masm_vm_active();
        case_ok &= zeliard_room_masm_vm_input_kind() ==
                   ZEL_ROOM_VM_INPUT_TEXT;
        case_ok &= cs[0xFF17] == 0;
        case_ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, direction, 0, 0);
        case_ok &= zeliard_room_masm_vm_active();
        case_ok &= zeliard_room_masm_vm_input_kind() ==
                   ZEL_ROOM_VM_INPUT_TEXT;
        case_ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 0, 0);
        unsigned menu_ticks = 0;
        case_ok &= vm_reach_menu(cs, vga, &menu_ticks);
        printf("sage_release_vm_early_direction_%u: speech_ticks=%u "
               "menu_ticks=%u active=%d kind=%d selection=%u\n",
               direction, ticks, menu_ticks,
               zeliard_room_masm_vm_active(),
               zeliard_room_masm_vm_input_kind(), cs[0xFF56]);
        case_ok &= zeliard_room_masm_vm_active();
        case_ok &= zeliard_room_masm_vm_input_kind() ==
                   ZEL_ROOM_VM_INPUT_MENU;
        case_ok &= cs[0xFF56] == 0;
        zeliard_room_masm_vm_stop();
        free(cs); free(vga);
        ok &= case_ok;
    }
    return ok;
}

static int sage_release_vm_exit_farewell(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    cs[0xFF16] |= 1u;
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    while (ok && zeliard_room_masm_vm_active() &&
           zeliard_room_masm_vm_input_kind() != ZEL_ROOM_VM_INPUT_TEXT &&
           ticks++ < 6000)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    const u16 farewell_script = (u16)(cs[0xFF4C] |
        ((u16)cs[0xFF4D] << 8));
    const u16 farewell_ip = zeliard_room_masm_vm_ip();
    const unsigned long long farewell_frame = fnv1a64(vga, 0x10000);
    ok &= zeliard_room_masm_vm_active();
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT;
    ok &= farewell_script == 0xAE06;
    ok &= farewell_frame == 0x999085E3C8BFBD1FULL;
    for (unsigned held = 0; ok && held < 25; ++held)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    ok &= zeliard_room_masm_vm_active();
    ok &= zeliard_room_masm_vm_ip() == farewell_ip;
    ok &= zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_TEXT;
    ok &= fnv1a64(vga, 0x10000) == farewell_frame;
    cs[0xFF16] &= (u8)~1u;
    ok &= zeliard_room_masm_vm_advance(
        cs, 0x10000, vga, 0x10000, 1, 0, 0, 0);
    cs[0xFF16] |= 1u;
    ok &= zeliard_room_masm_vm_advance(
        cs, 0x10000, vga, 0x10000, 1, 0, 1, 0);
    cs[0xFF16] &= (u8)~1u;
    for (unsigned leave = 0; ok && zeliard_room_masm_vm_active() &&
         leave < 6000; ++leave)
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 0, 0);
    ok &= !zeliard_room_masm_vm_active();
    printf("sage_release_vm_farewell: ticks=%u active=%d kind=%d "
           "ip=%04x script=%04x frame=%016llx\n", ticks,
           zeliard_room_masm_vm_active(),
           zeliard_room_masm_vm_input_kind(), farewell_ip,
           farewell_script, farewell_frame);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int sage_release_vm_record(void) {
    remove("DUKE.usr");
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    const u8 menu0 = cs[0xFF56];
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u8 menu1 = cs[0xFF56];
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u8 menu2 = cs[0xFF56];
    ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    const u8 menu3 = cs[0xFF56];
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u32 serial_before = zeliard_room_masm_vm_save_serial();
    static const char name[] = "DUKE";
    size_t name_at = 0;
    int entered = 0;
    for (unsigned step = 0; ok && step < 30000 &&
         zeliard_room_masm_vm_save_serial() == serial_before; ++step) {
        u8 acknowledge = 0;
        u8 enter_key = 0;
        if (cs[0xFF74]) {
            if (name_at < sizeof(name) - 1)
                zeliard_room_masm_vm_text_key((u8)name[name_at++]);
            else if (!entered) {
                cs[0xFF18] |= 1;
                enter_key = 1;
                entered = 1;
            }
        } else if (zeliard_room_masm_vm_at_input_poll() ||
                   (step != 0 && step % 400 == 0)) {
            acknowledge = 1;
        }
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, enter_key);
        if (enter_key) cs[0xFF18] &= (u8)~1u;
        ++ticks;
    }
    const u32 serial_after = zeliard_room_masm_vm_save_serial();
    unsigned prompt_ticks = 0;
    while (ok && zeliard_room_masm_vm_active() &&
           !zeliard_room_masm_vm_at_input_poll() && prompt_ticks < 10000) {
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, 0, 0);
        ++prompt_ticks;
    }
    const int continue_prompt = zeliard_room_masm_vm_active() &&
        zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_MENU &&
        cs[0xFF52] == 2 && cs[0xFF53] == 2;
    const unsigned long long continue_prompt_frame = fnv1a64(vga, 0x10000);
    printf("sage_release_vm_record: ticks=%u menu=%u>%u>%u>%u cmd=%u "
           "serial=%u>%u name=%s input=%02x len=%u ip=%04x script=%04x "
           "timer=%u/%u speed=%u continue_prompt=%d/%u/%016llx\n", ticks,
           menu0, menu1, menu2, menu3, cs[0xBB14], serial_before,
           serial_after, zeliard_room_masm_vm_save_name(), cs[0xFF74],
           cs[0xBB25], zeliard_room_masm_vm_ip(),
           (u16)(cs[0xFF4C] | ((u16)cs[0xFF4D] << 8)),
           cs[0xFF1A], (u16)(cs[0xFF50] | ((u16)cs[0xFF51] << 8)),
           cs[0xFF33], continue_prompt, prompt_ticks, continue_prompt_frame);
    ok &= serial_after == serial_before + 1 &&
           strcmp(zeliard_room_masm_vm_save_name(), "DUKE.usr") == 0 &&
           memcmp(zeliard_room_masm_vm_save_record(), cs, 0x100) == 0 &&
           continue_prompt &&
           continue_prompt_frame == 0xE4601DA85E58BFBFULL;
    FILE *saved = fopen("DUKE.usr", "rb");
    u8 disk_record[0x100];
    ok &= saved && fread(disk_record, 1, sizeof(disk_record), saved) ==
                   sizeof(disk_record) &&
          memcmp(disk_record, cs, sizeof(disk_record)) == 0;
    if (saved) fclose(saved);
    remove("DUKE.usr");
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int sage_drive_option(u8 *cs, u8 *vga, u8 option,
                             unsigned *ticks) {
    if (!vm_reach_menu(cs, vga, ticks)) return 0;
    for (u8 row = 0; row < option; ++row)
        if (!vm_run_to_next_poll(cs, vga, 2, 0, ticks)) return 0;
    if (!vm_run_to_next_poll(cs, vga, 0, 1, ticks)) return 0;
    int left_menu = zeliard_room_masm_vm_input_kind() !=
        ZEL_ROOM_VM_INPUT_MENU;
    for (unsigned step = 0; zeliard_room_masm_vm_active() &&
         *ticks < 30000; ++step) {
        if (left_menu && zeliard_room_masm_vm_input_kind() ==
                ZEL_ROOM_VM_INPUT_MENU)
            return 1;
        left_menu |= zeliard_room_masm_vm_input_kind() !=
            ZEL_ROOM_VM_INPUT_MENU;
        const u8 acknowledge = zeliard_room_masm_vm_at_input_poll() &&
            zeliard_room_masm_vm_input_kind() != ZEL_ROOM_VM_INPUT_NAME;
        if (!zeliard_room_masm_vm_advance(
                cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, 0))
            return 0;
        ++*ticks;
    }
    return option == 0 && !zeliard_room_masm_vm_active();
}

static int sage_release_vm_progression(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    cs[ZEL_PLAYER_HERO_LEVEL] = 0;
    cs[ZEL_PLAYER_EXPERIENCE] = 0xFF;
    cs[ZEL_PLAYER_EXPERIENCE + 1] = 0x7F;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= sage_drive_option(cs, vga, 1, &ticks);
    const u16 experience = (u16)(cs[ZEL_PLAYER_EXPERIENCE] |
        ((u16)cs[ZEL_PLAYER_EXPERIENCE + 1] << 8));
    const u16 hp = (u16)(cs[ZEL_PLAYER_HP] |
        ((u16)cs[ZEL_PLAYER_HP + 1] << 8));
    const u16 hp_max = (u16)(cs[ZEL_PLAYER_HP_MAX] |
        ((u16)cs[ZEL_PLAYER_HP_MAX + 1] << 8));
    printf("sage_release_vm_progression: ticks=%u level=%u exp=%u "
           "hp=%u/%u selected=%u charges=%02x%02x%02x%02x%02x%02x%02x "
           "max=%02x%02x%02x%02x%02x%02x%02x known=%02x%02x%02x%02x%02x%02x%02x "
           "sages=%02x save=%02x last=%02x kind=%d\n",
           ticks, cs[ZEL_PLAYER_HERO_LEVEL], experience, hp, hp_max,
           cs[ZEL_PLAYER_SELECTED_SPELL],
           cs[0xAB], cs[0xAC], cs[0xAD], cs[0xAE], cs[0xAF], cs[0xB0], cs[0xB1],
           cs[0xB4], cs[0xB5], cs[0xB6], cs[0xB7], cs[0xB8], cs[0xB9], cs[0xBA],
           cs[0xBB], cs[0xBC], cs[0xBD], cs[0xBE], cs[0xBF], cs[0xC0], cs[0xC1],
           cs[0xE5], cs[0xC4], cs[0xC5],
           zeliard_room_masm_vm_input_kind());
    ok &= cs[ZEL_PLAYER_HERO_LEVEL] == 1 && experience == 149 &&
          hp == 120 && hp_max == 120 &&
          memcmp(cs + ZEL_PLAYER_SPELL_CHARGES,
                 cs + ZEL_PLAYER_SPELL_CHARGES_MAX, 7) == 0 &&
          cs[ZEL_PLAYER_SAGES_SPOKEN] == 0x80;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int sage_release_vm_save_failure(void) {
    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    int ok = zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    unsigned ticks = 0;
    ok &= vm_reach_menu(cs, vga, &ticks);
    for (u8 row = 0; row < 3; ++row)
        ok &= vm_run_to_next_poll(cs, vga, 2, 0, &ticks);
    ok &= vm_run_to_next_poll(cs, vga, 0, 1, &ticks);
    const u32 serial = zeliard_room_masm_vm_save_serial();
    static const char name[] = "FAIL";
    size_t name_at = 0;
    int entered = 0, retried = 0;
    zeliard_room_masm_vm_force_save_failure(1);
    for (unsigned step = 0; ok && step < 20000 && !retried; ++step) {
        u8 acknowledge = 0, enter_key = 0;
        if (cs[0xFF74] && !entered) {
            if (name_at < sizeof(name) - 1)
                zeliard_room_masm_vm_text_key((u8)name[name_at++]);
            else {
                cs[0xFF18] |= 1;
                enter_key = 1;
                entered = 1;
            }
        } else if (entered && cs[0xFF74] &&
                   zeliard_room_masm_vm_input_kind() == ZEL_ROOM_VM_INPUT_NAME) {
            retried = 1;
        } else if (zeliard_room_masm_vm_at_input_poll() ||
                   (step != 0 && step % 200 == 0)) {
            acknowledge = 1;
        }
        ok &= zeliard_room_masm_vm_advance(
            cs, 0x10000, vga, 0x10000, 1, 0, acknowledge, enter_key);
        if (enter_key) cs[0xFF18] &= (u8)~1u;
        ++ticks;
    }
    zeliard_room_masm_vm_force_save_failure(0);
    printf("sage_release_vm_save_failure: ticks=%u retried=%d serial=%u>%u\n",
           ticks, retried, serial, zeliard_room_masm_vm_save_serial());
    ok &= retried && zeliard_room_masm_vm_save_serial() == serial;
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

static int sage_release_vm_spells_and_options(void) {
    static const unsigned long long spell_hud_frames[7] = {
        0xDA93F36C8062626DULL, 0x99814CD155D05ABAULL,
        0xD64D2F3AF8265544ULL, 0xADF963ADFEC088C1ULL,
        0x5ACEF86EEB3D62D0ULL, 0xBBFC20F451E8DBDAULL,
        0x06C0AA4AC3F53903ULL,
    };
    int ok = 1;
    for (u8 sage = 2; sage <= 8; ++sage) {
        u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
        if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
            free(cs); free(vga); return 0;
        }
        cs[0xC006] = sage;
        unsigned ticks = 0;
        ok &= zeliard_room_masm_vm_start(
            ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
        ok &= vm_reach_menu(cs, vga, &ticks);
        const u8 spell = (u8)(sage - 1);
        const u8 spoken = (u8)(0x80u >> (sage - 1));
        printf("sage_release_vm_spell_%u: ticks=%u selected=%u known=%02x "
               "spoken=%02x\n", sage, ticks,
               cs[ZEL_PLAYER_SELECTED_SPELL],
               cs[ZEL_PLAYER_SPELL_KNOWN + spell - 1],
               cs[ZEL_PLAYER_SAGES_SPOKEN]);
        ok &= cs[ZEL_PLAYER_SELECTED_SPELL] == spell &&
              cs[ZEL_PLAYER_SPELL_KNOWN + spell - 1] == 0xFF &&
              (cs[ZEL_PLAYER_SAGES_SPOKEN] & spoken) != 0;
        const unsigned long long learned_frame = frame_rect_hash(
            vga, 218, 150, 24, 50);
        u8 first_visit[0x100];
        memcpy(first_visit, cs, sizeof(first_visit));
        zeliard_room_masm_vm_stop();

        ticks = 0;
        ok &= zeliard_room_masm_vm_start(
            ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
        ok &= vm_reach_menu(cs, vga, &ticks);
        const unsigned long long repeat_frame = frame_rect_hash(
            vga, 218, 150, 24, 50);
        printf("sage_release_vm_spell_%u_hud: learned=%016llx "
               "repeat=%016llx\n", sage, learned_frame, repeat_frame);
        ok &= memcmp(first_visit, cs, sizeof(first_visit)) == 0;
        /* 217KENJP A957-A980 clears the spell HUD slot, installs the new
         * spell sprite through GMMCGA [201Eh], then tail-jumps through
         * [2018h] to draw it.  The first-visit result must therefore match
         * the normal HUD redraw on the already-learned repeat visit. */
        ok &= learned_frame == spell_hud_frames[spell - 1] &&
              repeat_frame == learned_frame;
        zeliard_room_masm_vm_stop();
        free(cs); free(vga);
    }

    u8 *cs = calloc(1, 0x10000), *vga = calloc(1, 0x10000);
    if (!cs || !vga || load_raw(cs, 0, "assets/stdply.bin")) {
        free(cs); free(vga); return 0;
    }
    cs[0xC006] = 1;
    unsigned ticks = 0;
    ok &= zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    ok &= vm_reach_menu(cs, vga, &ticks);
    u8 before[0x100];
    memcpy(before, cs, sizeof(before));
    ok &= sage_drive_option(cs, vga, 2, &ticks);
    ok &= memcmp(before, cs, sizeof(before)) == 0;
    zeliard_room_masm_vm_stop();

    ticks = 0;
    ok &= zeliard_room_masm_vm_start(
        ZEL_ROOM_SAGE, cs, 0x10000, vga, 0x10000);
    ok &= sage_drive_option(cs, vga, 0, &ticks);
    ok &= !zeliard_room_masm_vm_active();
    printf("sage_release_vm_options: ticks=%u listen_unchanged=1 exit=1\n",
           ticks);
    zeliard_room_masm_vm_stop();
    free(cs); free(vga);
    return ok;
}

int main(void) {
    const unsigned long long king = render_king();
    const unsigned long long sage = render_sage();
    const unsigned long long omoya = render_omoya();
    const int ok = king == 0xC3F7143FE6C981F1ULL &&
                   sage == 0xA6873B3AD33ACEC7ULL &&
                   omoya == 0x1C86E94322A50C57ULL && runtime_round_trip() &&
                   sage_life_hud_round_trip() &&
                   king_branch_selection() && prompt_clear_service() &&
                   church_script_flow() &&
                   muralla_shop_menu_frames() &&
                   muralla_shop_main_menu_routes() &&
                   muralla_release_vm_menu_frames() &&
                   muralla_release_vm_browser_space() &&
                   muralla_release_vm_cursor_slide() &&
                   muralla_release_vm_held_space_edge() &&
                   muralla_release_vm_drugstore_text_repress() &&
                   muralla_release_vm_armory_exit() &&
                   muralla_release_vm_armory_buy() &&
                   muralla_release_vm_wise_man_sword_buy() &&
                   bosque_release_vm_spirit_sword_buy() &&
                   tumba_release_vm_knight_sword_trade() &&
                   muralla_release_vm_armory_replace_shield() &&
                   muralla_release_vm_church_heal() &&
                   esco_release_vm_church_free_heal() &&
                   muralla_release_vm_drug_buy() &&
                   muralla_release_vm_bank_exchange() &&
                   tumba_release_vm_bank_exchange() &&
                   dorado_release_vm_bank_exchange() &&
                   llama_release_vm_bank_exchange() &&
                   pureza_release_vm_bank_exchange() &&
                   esco_release_vm_bank_exchange() &&
                   muralla_release_vm_bank_amount_input(0) &&
                   muralla_release_vm_bank_amount_input(1) &&
                   satono_release_vm_inn_rest() &&
                   tumba_release_vm_inn_rest() &&
                   dorado_release_vm_inn_rest() &&
                   llama_release_vm_inn_rest() &&
                   pureza_release_vm_inn_rest() &&
                   king_first_visit_script() &&
                   king_followup_scripts() &&
                   sage_release_vm_menu() &&
                   sage_release_vm_ignores_early_direction() &&
                   sage_release_vm_exit_farewell() &&
                   sage_release_vm_record() &&
                   sage_release_vm_save_failure() &&
                   sage_release_vm_progression() &&
                   sage_release_vm_spells_and_options();
    printf("felishika_rooms: king=%016llx sage=%016llx omoya=%016llx\n",
           king, sage, omoya);
    printf("VERDICT: %s: C room frames match release MASM\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
