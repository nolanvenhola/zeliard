#include "../game/fight_masm_vm.h"
#include "../platform/platform.h"
#include "../render/palette.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    const char *name;
    const char *asset;
    u8 selector;
    u16 width;
    u8 level;
    u8 music;
    unsigned monsters;
    unsigned items;
    unsigned families;
    unsigned long long first_hash;
    unsigned long long moving_hash;
} cavern_case_t;

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static u16 read_u16(const u8 *data, size_t offset) {
    return (u16)(data[offset] | ((u16)data[offset + 1] << 8));
}

static void prepare_player(u8 *game, u8 selector) {
    memset(game, 0, 0x10000);
    game[0x80] = 4;
    game[0x82] = 21;
    game[0x83] = 12;
    game[0x90] = 0;
    game[0x91] = 2;
    game[0xB2] = 0;
    game[0xB3] = 2;
    game[0xC4] = selector;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

static int advance_frame(u8 *game, u8 *vga, u8 direction) {
    for (unsigned attempt = 0; attempt < 512; ++attempt) {
        const int rendered = zeliard_fight_masm_vm_advance(
            game, 0x10000, vga, 0x10000, 20, direction);
        if (!zeliard_fight_masm_vm_active() ||
            zeliard_fight_masm_vm_at_frame()) return rendered;
    }
    return 0;
}

static int map_shape(const char *asset, unsigned *monsters,
                     unsigned *items, unsigned *families,
                     unsigned *persistent) {
    size_t size = 0;
    u8 *image = platform_load_asset(asset, &size);
    if (!image || size < 4 + 0x12) { free(image); return 0; }
    const u8 *map = image + 4;
    size_t at = 4u + (size_t)(read_u16(map, 0x10) - 0xC000u);
    *monsters = *items = *families = *persistent = 0;
    while (at + 16 <= size && read_u16(image, at) != 0xFFFF) {
        const u8 *row = image + at;
        if (row[14]) {
            ++*monsters;
            if (row[4] >= 1 && row[4] <= 8) *families |= 1u << row[4];
        } else {
            ++*items;
        }
        if (row[7] & 0x20) ++*persistent;
        at += 16;
    }
    free(image);
    return 1;
}

static int run_case(const cavern_case_t *test) {
    static u8 game[0x10000], vga[0x10000];
    unsigned monsters = 0, items = 0, families = 0, persistent = 0;
    prepare_player(game, test->selector);
    palette_set_game_mcga();
    int ok = map_shape(test->asset, &monsters, &items, &families,
                       &persistent);
    ok &= zeliard_fight_masm_vm_start(game, sizeof(game), vga, sizeof(vga));
    const u16 initial_width = zeliard_fight_masm_vm_peek_u16(0xC002);
    const u8 initial_level = zeliard_fight_masm_vm_peek_u8(0xC012);
    const u8 initial_music = zeliard_fight_masm_vm_music_chunk();
    const unsigned long long first = fnv1a64(vga, 64000);
    for (unsigned frame = 0; ok && frame < 10; ++frame)
        ok &= advance_frame(game, vga, 8);
    const unsigned long long moving = fnv1a64(vga, 64000);
    ok &= zeliard_fight_masm_vm_active();
    ok &= initial_width == test->width;
    ok &= initial_level == test->level;
    ok &= initial_music == test->music;
    ok &= monsters == test->monsters && items == test->items;
    ok &= families == test->families;
    if (test->first_hash) ok &= first == test->first_hash;
    if (test->moving_hash) ok &= moving == test->moving_hash;
    printf("remaining_cavern:%s: %s selector=%02x width=%u level=%u "
           "music=%02x objects=%u/%u families=%02x persistent=%u current=%u/%u/%02x "
           "hash=%016llx/%016llx\n", test->name, ok ? "PASS" : "FAIL",
           test->selector, initial_width, initial_level, initial_music,
           monsters, items, families, persistent,
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), first, moving);
    return ok;
}

static int run_persistence_case(const char *name, u8 selector,
                                unsigned object_index, u8 state_byte,
                                u8 state_mask) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, selector);
    game[state_byte] = state_mask;
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const u16 objects = zeliard_fight_masm_vm_peek_u16(0xC010);
    const u16 object = (u16)(objects + object_index * 16u);
    const u8 head0 = zeliard_fight_masm_vm_peek_u8(object);
    const u8 head1 = zeliard_fight_masm_vm_peek_u8((u16)(object + 1));
    const u8 link0 = zeliard_fight_masm_vm_peek_u8((u16)(object + 11));
    const u8 link1 = zeliard_fight_masm_vm_peek_u8((u16)(object + 12));
    ok &= (head0 == 0 && head1 == 0xFF && link0 == 0xFF && link1 == 0xFF) ||
          (head0 == 0xFF && head1 == 0xFF);
    printf("remaining_persistence:%s: %s selector=%02x object=%u "
           "state=%02x/%02x bytes=%02x%02x/%02x%02x\n", name,
           ok ? "PASS" : "FAIL", selector, object_index, state_byte,
           state_mask, head0, head1, link0, link1);
    return ok;
}

static int run_reaccion_connector_case(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, 0x15);
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 73;
    ok &= zeliard_fight_masm_vm_peek_u8(0xC012) == 1;
    ok &= zeliard_fight_masm_vm_music_chunk() == 94;
    for (unsigned frame = 0; frame < 12 &&
            zeliard_fight_masm_vm_active(); ++frame)
        (void)advance_frame(game, vga, 8);
    const unsigned long long frame_hash = fnv1a64(vga, 64000);
    ok &= zeliard_fight_masm_vm_active();
    ok &= frame_hash == 0x3AE0970582010DEAULL;
    printf("remaining_connector:Reaccion: %s width=%u level=%u music=%02x "
           "hash=%016llx\n", ok ? "PASS" : "FAIL",
           zeliard_fight_masm_vm_peek_u16(0xC002),
           zeliard_fight_masm_vm_peek_u8(0xC012),
           zeliard_fight_masm_vm_music_chunk(), frame_hash);
    return ok;
}

int main(void) {
    static const cavern_case_t cases[] = {
        {"Reaccion", "mp71.mdt", 0x13, 196, 7, 92, 25, 10, 0x1E,
         0x55381990B26D942FULL, 0x845AD63F57A4D9BFULL},
        {"Absor", "mp80.mdt", 0x17, 256, 8, 93, 45, 15, 0x1E,
         0xCC5CD9FA6D361CEAULL, 0x52F63ADD9ABAEAE8ULL},
        {"Milagro", "mp81.mdt", 0x18, 256, 8, 93, 58, 11, 0x1E,
         0xC3189668BD1A3ADFULL, 0x221B465D60148574ULL},
        {"Desleal", "mp82.mdt", 0x19, 192, 8, 93, 33, 6, 0x1E,
         0xB80048D0365418A4ULL, 0x6A4858D3424999DFULL},
        {"Falter", "mp83.mdt", 0x1A, 128, 8, 93, 7, 0, 0x08,
         0x411F9291DFB1E1E2ULL, 0x90830982257B7796ULL},
        {"Final", "mp84.mdt", 0x1B, 64, 8, 93, 0, 1, 0x00,
         0x0B890219DDE1EBFAULL, 0x61A4956CE9E37858ULL},
        {"Alguien handoff", "mp8d.mdt", 0x1C, 70, 8, 94, 0, 0, 0x00,
         0x1170CCB80731F929ULL, 0x9296F65C33677825ULL},
        {"Jashiin phase transition", "mp90.mdt", 0x1D, 73, 10, 96, 0, 0, 0x00,
         0xEC4322843F255355ULL, 0xC323E744770E9BD2ULL},
        {"Jashiin phase two", "mpa0.mdt", 0x1E, 73, 10, 96, 0, 0, 0x00,
         0x23D025DB28E274EBULL, 0xEF5D3778CBB67675ULL},
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i)
        ok &= run_case(&cases[i]);
    ok &= run_reaccion_connector_case();
    ok &= run_persistence_case("Reaccion", 0x13, 9, 0x35, 0x10);
    ok &= run_persistence_case("Absor", 0x17, 24, 0x42, 0x10);
    ok &= run_persistence_case("Milagro", 0x18, 3, 0x43, 0x20);
    ok &= run_persistence_case("Desleal", 0x19, 3, 0x44, 0x08);
    ok &= run_persistence_case("Final", 0x1B, 0, 0x45, 0x10);
    printf("VERDICT: %s: all remaining cavern release maps execute in the "
           "exact fight VM\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
