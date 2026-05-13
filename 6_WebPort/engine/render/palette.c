#include "palette.h"
#include <string.h>

palette_color_t g_palette[256];

void palette_set_default(void) {
    /* Placeholder: a 27-color MCGA-style cube spread across the 256 slots.
     * Per CLAUDE.md the real per-scene palettes will be loaded from the
     * gmmcga driver's encoded format once that path is wired up.  For M1
     * we just need *some* RGB mapping so the test pattern renders.
     */
    memset(g_palette, 0, sizeof(g_palette));
    for (int i = 0; i < 256; i++) {
        /* Use the original VGA nibble-pair palette trick (CLAUDE.md):
         *   index = (hi_nibble << 4) | lo_nibble
         * with each nibble mapping to one of 4 base colours.  For the
         * placeholder we just spread RGB across the index. */
        g_palette[i].r = (u8)((i & 0xE0));
        g_palette[i].g = (u8)((i & 0x1C) << 3);
        g_palette[i].b = (u8)((i & 0x03) << 6);
    }
    /* Reserved palette slots used by the original title image (nibble-pair
     * trick produces these specific indices for the title logo). */
    g_palette[0x00] = (palette_color_t){  0,   0,   0};  /* black */
    g_palette[0xAA] = (palette_color_t){252, 200,   0};  /* yellow (logo) */
    g_palette[0xCC] = (palette_color_t){  0,   0, 168};  /* blue (outline) */
    g_palette[0x88] = (palette_color_t){  0,   0,  84};  /* dark blue */
}
