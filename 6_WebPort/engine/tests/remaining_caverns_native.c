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

static int run_lion_key_probe(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, 0x17);
    game[0x80] = 147 - 16;
    game[0x82] = (4 - 9) & 0x3F;
    game[0x92] = 1;
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned frames = 0;
    while (ok && frames < 20 && !game[0x99]) {
        game[0xFF16] = 1;
        ok &= advance_frame(game, vga, 0);
        ++frames;
    }
    u8 cue = 0;
    for (u8 next; (next = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
        cue = next;
    const unsigned long long frame = fnv1a64(vga, 64000);
    const int found = ok && frames == 1 && game[0x99] == 1 &&
        (game[0x42] & 0x08) && cue == 0x11 &&
        frame == 0xD2A4B730E2894357ULL;
    printf("lion_key_acquisition: %s frames=%u key=%u state=%02x "
           "cue=%02x frame=%016llx\n", found ? "PASS" : "FAIL", frames,
           game[0x99], game[0x42], cue, frame);
    zeliard_fight_masm_vm_stop();
    return found;
}

static void prepare_route_player(u8 *game, u8 selector, u16 x, u8 y) {
    prepare_player(game, selector);
    game[0x80] = (u8)(x - 16u);
    game[0x81] = (u8)((x - 16u) >> 8);
    game[0x82] = (u8)((y - 9u) & 0x3Fu);
    game[0xC3] = 0xFF;
}

static int run_lion_key_routes(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_route_player(game, 14, 31, 5);
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= advance_frame(game, vga, 1);
    const u16 locked_width = zeliard_fight_masm_vm_peek_u16(0xC002);
    const unsigned long long locked_frame = fnv1a64(vga, 64000);
    const int locked = zeliard_fight_masm_vm_active() &&
        locked_width == 320 && game[0x99] == 0 && !(game[0x2B] & 0x10);
    zeliard_fight_masm_vm_stop();

    prepare_route_player(game, 14, 31, 5);
    game[0x99] = 1;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= advance_frame(game, vga, 1);
    const unsigned long long opened_frame = fnv1a64(vga, 64000);
    const int unlocked = zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_peek_u16(0xC002) == 320 &&
        game[0x99] == 0 && (game[0x2B] & 0x10);
    ok &= advance_frame(game, vga, 1);
    const unsigned long long entered_frame = fnv1a64(vga, 64000);
    const int entered = zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_peek_u16(0xC002) == 73 &&
        game[0x99] == 0 && (game[0x2B] & 0x10);
    zeliard_fight_masm_vm_stop();

    prepare_route_player(game, 14, 31, 5);
    game[0x2B] = 0x10;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= advance_frame(game, vga, 1);
    const unsigned long long revisit_frame = fnv1a64(vga, 64000);
    const int revisit = zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_peek_u16(0xC002) == 73 &&
        game[0x99] == 0 && game[0x2B] == 0x10;
    zeliard_fight_masm_vm_stop();

    prepare_route_player(game, 16, 62, 13);
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= advance_frame(game, vga, 1);
    const int free_return = zeliard_fight_masm_vm_active() &&
        zeliard_fight_masm_vm_peek_u16(0xC002) == 320 &&
        game[0x99] == 0;
    zeliard_fight_masm_vm_stop();

    const int frames_match =
        locked_frame == 0xDF17A50269DE13BCULL &&
        opened_frame == 0x9A42F282121D01CFULL &&
        entered_frame == 0x50FE5808AC150C69ULL &&
        revisit_frame == entered_frame;

    printf("lion_key_routes: %s locked=%d/%u unlock=%d enter=%d "
           "revisit=%d return=%d frames=%016llx/%016llx/%016llx/%016llx\n",
           locked && unlocked && entered && revisit && free_return &&
           frames_match ?
           "PASS" : "FAIL", locked, locked_width, unlocked, entered,
           revisit, free_return, locked_frame, opened_frame, entered_frame,
           revisit_frame);
    return ok && locked && unlocked && entered && revisit && free_return &&
        frames_match;
}

static int run_alguien_case(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, 0x18);
    game[0x80] = 222 - 16;
    game[0x82] = (19 - 9) & 0x3F;
    game[0x98] = 1;
    game[0xA0] = 7;
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    unsigned encounter_start = 0, boss_music = 0, encounter_finish = 0;
    unsigned long long encounter_hash = 0, chamber_hash = 0;
    for (unsigned frame = 1; ok && frame <= 220; ++frame) {
        const u8 direction = encounter_start ? 0 : 1;
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, direction);
        if (!encounter_start &&
            zeliard_fight_masm_vm_peek_u16(0xC002) == 70)
            encounter_start = frame;
        if (!boss_music && zeliard_fight_masm_vm_music_chunk() == 94)
            boss_music = frame;
        if (frame == 56) encounter_hash = fnv1a64(vga, 64000);
        if (!encounter_finish && encounter_start &&
            zeliard_fight_masm_vm_at_frame())
            encounter_finish = frame;
        if (frame == 180) chamber_hash = fnv1a64(vga, 64000);
    }
    printf("alguien_encounter_probe: start=%u music=%u finish=%u width=%u "
           "hash=%016llx/%016llx\n", encounter_start, boss_music,
           encounter_finish, zeliard_fight_masm_vm_peek_u16(0xC002),
           encounter_hash, chamber_hash);

    prepare_player(game, 0x1C);
    game[0x98] = 1;
    game[0xA0] = 7;
    palette_set_game_mcga();
    ok &= zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const u16 hp = zeliard_fight_masm_vm_peek_u16(0xAA09);
    ok &= zeliard_fight_masm_vm_poke_u16(0xAA09, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAA29, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned frames = 0, completion = 0;
    unsigned long long completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && frames < 300 && !completion) {
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, 0);
        ++frames;
        if (zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            completion = frames;
            completion_hash = fnv1a64(vga, 64000);
        }
    }
    printf("alguien_death_probe: hp=%04x frames=%u completion=%u/%02x "
           "state=%02x/%02x tears=%02x hash=%016llx\n", hp, frames,
           completion, zeliard_fight_masm_vm_peek_u8(0xFF30),
           game[0x44], game[0x45], game[0xA0], completion_hash);
    ok &= encounter_start && boss_music && encounter_finish;
    ok &= encounter_start == 7 && boss_music == 58;
    ok &= encounter_finish == 114;
    ok &= encounter_hash == 0x3FB7C3A9BFE6BE2DULL;
    ok &= chamber_hash == 0x149B57432C2399C1ULL;
    ok &= zeliard_fight_masm_vm_peek_u16(0xC002) == 70;
    ok &= hp == 0x0320;
    ok &= completion == 121;
    ok &= completion_hash == 0x541A5D42892DE229ULL;
    return ok;
}

static int run_jashiin_case(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, 0x1E);
    game[0x98] = 1;
    game[0xA0] = 8;
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    const u16 position = zeliard_fight_masm_vm_peek_u16(0xAC06);
    const unsigned long long first_hash = fnv1a64(vga, 64000);
    ok &= zeliard_fight_masm_vm_poke_u16(0xAC06, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAC20, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned frames = 0, completion = 0;
    unsigned long long completion_hash = 0;
    while (zeliard_fight_masm_vm_active() && frames < 300 && !completion) {
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, 0);
        ++frames;
        if (zeliard_fight_masm_vm_peek_u8(0xFF30) == 0xFF) {
            completion = frames;
            completion_hash = fnv1a64(vga, 64000);
        }
    }
    printf("jashiin_final_probe: position=%04x frames=%u completion=%u/%02x "
           "tears=%02x hash=%016llx/%016llx\n", position, frames,
           completion, zeliard_fight_masm_vm_peek_u8(0xFF30), game[0xA0],
           first_hash, completion_hash);
    ok &= position == 0x0320;
    ok &= completion == 121;
    ok &= first_hash == 0x23D025DB28E274EBULL;
    ok &= completion_hash == 0xBAC3070BD3942E86ULL;
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
    ok &= run_alguien_case();
    ok &= run_jashiin_case();
    ok &= run_reaccion_connector_case();
    ok &= run_lion_key_probe();
    ok &= run_lion_key_routes();
    ok &= run_persistence_case("Reaccion", 0x13, 9, 0x35, 0x10);
    ok &= run_persistence_case("Absor", 0x17, 24, 0x42, 0x10);
    ok &= run_persistence_case("Lion key", 0x17, 32, 0x42, 0x08);
    ok &= run_persistence_case("Milagro", 0x18, 3, 0x43, 0x20);
    ok &= run_persistence_case("Desleal", 0x19, 3, 0x44, 0x08);
    ok &= run_persistence_case("Final", 0x1B, 0, 0x45, 0x10);
    printf("VERDICT: %s: all remaining cavern release maps execute in the "
           "exact fight VM\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
