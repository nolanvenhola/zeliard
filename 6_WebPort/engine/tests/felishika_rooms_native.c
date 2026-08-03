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
        ok &= zeliard_room_leave(room, cs, 0x10000, vga, 0x10000) == 0;
    }
    free(cs); free(vga); free(room);
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
    printf("muralla_release_vm_drugstore_text_repress: ticks=%u "
           "frames=%016llx>%016llx kind=%d\n", ticks, intro_frame,
           description_frame, zeliard_room_masm_vm_input_kind());
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
    printf("muralla_release_vm_armory_buy: ticks=%u gold=%u sword=%u "
           "inventory=%02x\n", ticks, gold, cs[0x92], cs[0xD2]);
    /* 212ARMRP:weapon_commit replaces player:sword; there is no carried
     * sword array. The old tier is returned through script_give_item. */
    ok &= cs[0x92] == 1 && gold == 1350 && cs[0xD2] == 0xC0;
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
    printf("muralla_release_vm_armory_shield: ticks=%u gold=%u shield=%u "
           "hp=%u/%u inventory=%02x\n", ticks, gold,
           cs[ZEL_PLAYER_SHIELD], shield_hp, shield_max, cs[0xDB]);
    ok &= cs[ZEL_PLAYER_SHIELD] == 1 && gold == 1025 &&
        shield_hp == 30 && shield_max == 30 && cs[0xDB] == 0xC0;
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

int main(void) {
    const unsigned long long king = render_king();
    const unsigned long long sage = render_sage();
    const unsigned long long omoya = render_omoya();
    const int ok = king == 0xC3F7143FE6C981F1ULL &&
                   sage == 0xA6873B3AD33ACEC7ULL &&
                   omoya == 0x1C86E94322A50C57ULL && runtime_round_trip() &&
                   king_branch_selection() && prompt_clear_service() &&
                   church_script_flow() &&
                   muralla_shop_menu_frames() &&
                   muralla_shop_main_menu_routes() &&
                   muralla_release_vm_menu_frames() &&
                   muralla_release_vm_browser_space() &&
                   muralla_release_vm_held_space_edge() &&
                   muralla_release_vm_drugstore_text_repress() &&
                   muralla_release_vm_armory_exit() &&
                   muralla_release_vm_armory_buy() &&
                   muralla_release_vm_armory_replace_shield() &&
                   muralla_release_vm_church_heal() &&
                   muralla_release_vm_drug_buy() &&
                   muralla_release_vm_bank_exchange() &&
                   king_first_visit_script() &&
                   king_followup_scripts();
    printf("felishika_rooms: king=%016llx sage=%016llx omoya=%016llx\n",
           king, sage, omoya);
    printf("VERDICT: %s: C room frames match release MASM\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
