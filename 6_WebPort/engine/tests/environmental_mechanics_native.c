#include "../game/fight_masm_vm.h"
#include "../platform/platform.h"
#include "../render/palette.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    u8 selector;
    u16 width;
    u16 x;
    u8 y;
    u8 direction;
    unsigned frames;
    u16 expected_x;
    u8 expected_y;
    const char *name;
} movement_case_t;

static u16 read_u16(const u8 *data, size_t offset) {
    return (u16)(data[offset] | ((u16)data[offset + 1] << 8));
}

static void prepare_player(u8 *game, const movement_case_t *test) {
    const u16 origin = (u16)((test->x + test->width - 16u) % test->width);
    memset(game, 0, 0x10000);
    game[0x80] = (u8)origin;
    game[0x81] = (u8)(origin >> 8);
    game[0x82] = (u8)((test->y - 9u) & 0x3Fu);
    game[0x83] = 12;
    game[0x90] = 0;
    game[0x91] = 2;
    game[0xB2] = 0;
    game[0xB3] = 2;
    game[0xC4] = test->selector;
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

static u16 world_x(const u8 *game, u16 width) {
    return (u16)((read_u16(game, 0x80) + game[0x83] + 4u) % width);
}

static u8 world_y(const u8 *game) {
    return (u8)((game[0x82] + 9u) & 0x3Fu);
}

static int run_movement_case(const movement_case_t *test) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game, test);
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    for (unsigned frame = 0; ok && frame < test->frames; ++frame)
        ok &= advance_frame(game, vga, test->direction);
    const u16 x = world_x(game, test->width);
    const u8 y = world_y(game);
    ok &= zeliard_fight_masm_vm_active();
    ok &= x == test->expected_x && y == test->expected_y;
    printf("environment:%s: %s start=%u/%u frames=%u final=%u/%u\n",
           test->name, ok ? "PASS" : "FAIL", test->x, test->y,
           test->frames, x, y);
    return ok;
}

static int records_equal(const char *asset, size_t pointer_offset,
                         size_t record_size, const u8 *expected,
                         size_t expected_size, const char *name) {
    size_t size = 0;
    u8 *image = platform_load_asset(asset, &size);
    int ok = image && size > 4 + pointer_offset + 1;
    if (ok) {
        const u8 *map = image + 4;
        const size_t offset = (size_t)(read_u16(map, pointer_offset) - 0xC000u);
        ok &= offset + expected_size + 2 <= size - 4;
        ok &= expected_size % record_size == 0;
        ok &= memcmp(map + offset, expected, expected_size) == 0;
        ok &= map[offset + expected_size] == 0xFF;
        ok &= map[offset + expected_size + 1] == 0xFF;
    }
    printf("environment:%s: %s bytes=%zu records=%zu\n", name,
           ok ? "PASS" : "FAIL", expected_size,
           record_size ? expected_size / record_size : 0);
    free(image);
    return ok;
}

int main(void) {
    static const movement_case_t movement[] = {
        {18, 208, 125, 11, 0, 15, 109, 11, "caliente_upper_airflow"},
        {18, 208, 106, 36, 0, 15, 107, 7, "caliente_wrapped_airflow"},
        {20, 128, 78, 23, 0, 15, 84, 36, "correr_upper_airflow"},
        {20, 128, 1, 34, 0, 15, 15, 45, "correr_wrapped_airflow"},
        {20, 128, 78, 59, 0, 15, 62, 59, "correr_lower_airflow"},
        /* Area-7/8 release-VM probes found by the exhaustive coordinate
         * survey.  These lock the complete current + collision + gravity
         * trajectory, including Reaccion's vertical wrap. */
        {19, 196, 50, 2, 0, 15, 72, 3, "reaccion_wrapped_airflow"},
        {23, 256, 97, 37, 0, 20, 85, 46, "absor_airflow"},
        {24, 256, 193, 17, 0, 10, 194, 30, "milagro_airflow"},
        {25, 192, 9, 17, 0, 20, 22, 18, "desleal_airflow"},
        {26, 128, 25, 5, 0, 10, 9, 5, "falter_airflow"},
    };
    static const u8 caliente_vertical[] = {
        0x07,0x00,0x06, 0x0E,0x00,0x03, 0x17,0x00,0x03,
        0x1C,0x00,0x3F, 0x1F,0x00,0x3F, 0x2D,0x00,0x19,
        0x40,0x00,0x3F, 0x5A,0x00,0x05, 0xBA,0x00,0x04,
        0xC3,0x00,0x31,
    };
    static const u8 caliente_collapsing[] = {
        0x1A,0x00,0x27, 0x1D,0x00,0x26, 0x20,0x00,0x24,
    };
    static const u8 corroer_horizontal_platforms[] = {
        0x53,0x80,0x2F,0x4C,0x00,0x5A,0x00,
        0x64,0x80,0xAF,0x5D,0x00,0x6B,0x00,
    };
    static const u8 riza_horizontal[] = {
        0x60,0x40,0xAA,0x5D,0x00,0x63,0x00,
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(movement) / sizeof(movement[0]); ++i)
        ok &= run_movement_case(&movement[i]);
    ok &= records_equal("mp70.mdt", 4, 3, caliente_vertical,
                        sizeof(caliente_vertical), "caliente_vertical_rows");
    ok &= records_equal("mp70.mdt", 6, 3, caliente_collapsing,
                        sizeof(caliente_collapsing), "caliente_collapsing_rows");
    ok &= records_equal("mp50.mdt", 8, 7, corroer_horizontal_platforms,
                        sizeof(corroer_horizontal_platforms),
                        "corroer_horizontal_platforms");
    ok &= records_equal("mp31.mdt", 8, 7, riza_horizontal,
                        sizeof(riza_horizontal), "riza_concealed_floor");
    printf("VERDICT: %s: canonical environmental currents, hidden routes, "
           "and concealed-floor records\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
