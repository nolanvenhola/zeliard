#include "palette.h"
#include <string.h>

palette_color_t g_palette[256];

/* The original 4-plane → nibble-pair pipeline emits bytes built from two
 * nibbles, each drawn from one of four base colours:
 *
 *   nibble  base colour          source (CLAUDE.md "Zeliard Title Logo")
 *   ----------------------------------------------------------
 *   0x0     black                background
 *   0xA     yellow               logo body
 *   0xC     blue                 outline
 *   0x8     dark blue            inner outline
 *
 * Every byte b in the rendered image is two nibbles (hi<<4 | lo); the
 * palette entry at index b is the average of the two base colours.  Pure
 * indices 0x00, 0xAA, 0xCC, 0x88 yield the four pure base colours; mixed
 * indices yield smooth blended pixels that give the logo its anti-aliased
 * look.  This is the original "nibble-pair palette trick" from the VGA
 * mode-13h pipeline.
 */
static const palette_color_t BASE_COLOURS[4] = {
    /* index by nibble value mapped through:
     *   0x0 -> 0 (black), 0xA -> 1 (yellow), 0xC -> 2 (blue), 0x8 -> 3 (dark blue)
     * any other nibble falls through to black. */
    {   0,   0,   0 },  /* 0x0 black */
    { 252, 200,   0 },  /* 0xA yellow (logo body) */
    {  40,  80, 200 },  /* 0xC blue (outline) */
    {  20,  20, 120 },  /* 0x8 dark blue (inner outline) */
};

static int base_index_for_nibble(u8 n) {
    switch (n) {
        case 0x0: return 0;
        case 0xA: return 1;
        case 0xC: return 2;
        case 0x8: return 3;
        default:  return 0;  /* unmapped — treat as background */
    }
}

void palette_set_default(void) {
    memset(g_palette, 0, sizeof(g_palette));
    for (int i = 0; i < 256; i++) {
        int hi = base_index_for_nibble((u8)((i >> 4) & 0xF));
        int lo = base_index_for_nibble((u8)(i & 0xF));
        /* Average the two base colours for the mixed nibble pair. */
        g_palette[i].r = (u8)((BASE_COLOURS[hi].r + BASE_COLOURS[lo].r) / 2);
        g_palette[i].g = (u8)((BASE_COLOURS[hi].g + BASE_COLOURS[lo].g) / 2);
        g_palette[i].b = (u8)((BASE_COLOURS[hi].b + BASE_COLOURS[lo].b) / 2);
    }
}
