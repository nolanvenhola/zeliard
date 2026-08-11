#include "../core/player_state.h"

#include <stdio.h>
#include <string.h>

static int roundtrip_fixture(const char *name) {
    char path[256];
    unsigned char input[ZEL_PLAYER_RECORD_SIZE];
    unsigned char game_segment[ZEL_PLAYER_RECORD_SIZE];
    unsigned char output[ZEL_PLAYER_RECORD_SIZE];
    zeliard_player_state_t player;

    snprintf(path, sizeof(path), "../../scripts/state/fixtures/valid/%s", name);
    FILE *file = fopen(path, "rb");
    if (!file) {
        printf("usr_fixture:%s: FAIL open %s\n", name, path);
        return 0;
    }
    const size_t size = fread(input, 1, sizeof(input), file);
    const int extra = fgetc(file);
    fclose(file);
    if (size != sizeof(input) || extra != EOF) {
        printf("usr_fixture:%s: FAIL size=%zu extra=%d\n", name, size, extra);
        return 0;
    }

    memset(game_segment, 0xCD, sizeof(game_segment));
    if (!zeliard_player_state_bind(&player, game_segment, sizeof(game_segment)) ||
        !zeliard_player_import(&player, input) ||
        !zeliard_player_snapshot(&player, output) ||
        memcmp(input, output, sizeof(input)) != 0) {
        printf("usr_fixture:%s: FAIL import/snapshot\n", name);
        return 0;
    }
    printf("usr_fixture:%s: PASS\n", name);
    return 1;
}

int main(void) {
    static const char *fixtures[] = {
        "BASE.USR", "CLEAR.USR", "PROGRESS.USR", "BOUNDARY.USR", "LEAKAGE.USR"
    };
    int ok = 1;
    for (size_t i = 0; i < sizeof(fixtures) / sizeof(fixtures[0]); ++i)
        ok &= roundtrip_fixture(fixtures[i]);
    return ok ? 0 : 1;
}
