#include "../game/opening.h"
#include <stdio.h>

/*
 * Transitional semantic trace adapter.
 *
 * MASM's opdemo_reference_trace.json is the sole expected stream.  These
 * summary adapters are being replaced checkpoint-by-checkpoint by events
 * emitted from the live C runtime proxy boundaries; do not treat the values
 * in this file as an independent specification.
 */

static void hex8(const char *name, unsigned value) {
    printf("%s=%04X", name, value & 0xFF);
}

static void hex16(const char *name, unsigned value) {
    printf("%s=%04X", name, value & 0xFFFF);
}

static void title_asset_trace(void) {
    static const char *service[] = {
        "jashiin_speech", "sar_load", "decode_rle_to_es_di", "sar_load",
        "sar_load", "sar_load", "gfx_mode", "gfx_palette"
    };
    opening_title_asset_event_t events[8];
    size_t count = opening_title_asset_reload_trace(events, 8);
    for (size_t i = 0; i < count; i++) {
        opening_title_asset_event_t *e = &events[i];
        printf("title_asset_reload|%s|", service[i]);
        switch (e->kind) {
        case OPENING_TITLE_ASSET_EVENT_SPEECH:
            hex8("al", e->al); printf(","); hex16("bx", e->bx);
            printf(","); hex16("cx", e->cx);
            break;
        case OPENING_TITLE_ASSET_EVENT_SAR_LOAD:
            hex8("al", e->al); printf(","); hex16("di", e->di);
            printf(",asset=%s", e->asset);
            break;
        case OPENING_TITLE_ASSET_EVENT_DECODE_RLE:
            hex16("si", e->si); printf(","); hex16("di", e->di);
            break;
        case OPENING_TITLE_ASSET_EVENT_GFX_MODE:
            hex8("al", 5); printf(","); hex16("bx", e->bx);
            printf(","); hex16("cx", e->cx);
            break;
        case OPENING_TITLE_ASSET_EVENT_PALETTE:
            hex16("ax", e->ax);
            break;
        }
        printf("\n");
    }
}

static void title_display_trace(void) {
    opening_title_display_handoff_summary_t s = opening_title_display_handoff_summary();
    printf("title_display_handoff|disp_drv_seg_3|"); hex16("ax", s.int60_ax);
    printf(","); hex16("si", s.int60_si); printf("\n");
    printf("title_display_handoff|timer_wait|"); hex8("al", s.wait_al[0]); printf("\n");
    printf("title_display_handoff|gfx_update|"); hex8("al", s.gfx_update_al);
    printf(","); hex16("bx", s.gfx_update_bx); printf(","); hex16("cx", s.gfx_update_cx);
    printf(","); hex16("di", s.gfx_update_di); printf("\n");
    printf("title_display_handoff|decode_rle_to_es_di|si=%04X,di=%04X\n",
           s.decode_si[0], s.decode_di[0]);
    printf("title_display_handoff|timer_wait|al=%04X\n", s.wait_al[1]);
    printf("title_display_handoff|disp_narr_chap3|bx=%04X,cx=%04X,di=%04X\n",
           s.disp_narr_chap3_bx, s.disp_narr_chap3_cx, s.disp_narr_chap3_di);
    printf("title_display_handoff|decode_rle_to_es_di|si=%04X,di=%04X\n",
           s.decode_si[1], s.decode_di[1]);
    printf("title_display_handoff|disp_narr_open|si=%04X\n", s.disp_narr_open_si);
    printf("title_display_handoff|timer_wait|al=%04X\n", s.wait_al[2]);
}

static void next_scene_trace(void) {
    opening_timer_exit_summary_t s = opening_timer_exit_summary();
    printf("opening_next_scene|gfx_mode|al=%04X,bx=%04X,cx=%04X\n",
           s.gfx_mode_al, s.gfx_mode_bx, s.gfx_mode_cx);
    printf("opening_next_scene|gfx_init|\n");
    printf("opening_next_scene|sar_load|al=%04X,di=%04X,asset=%s\n",
           s.sar_al, s.sar_di, s.sar_asset);
    printf("opening_next_scene|gfx_palette|ax=%04X\n", s.palette_ax);
    printf("opening_next_scene|credits_scroll_display|\n");
    printf("trans_exit_to_story|gfx_init|\n");
}

static void post_title_story_trace(void) {
    opening_post_title_story_summary_t s = opening_post_title_story_summary();
    printf("post_title_story_setup|gfx_palette|ax=%04X\n", s.palette_ax);
    for (size_t i = 0; i < 2; i++) {
        printf("post_title_story_setup|sar_load|al=%04X,di=%04X,asset=%s\n",
               s.sar_al[i], s.sar_di[i], s.sar_asset[i]);
        printf("post_title_story_setup|decompress_image|si=%04X,di=%04X\n",
               s.decompress_si[i], s.decompress_di[i]);
    }
    for (size_t i = 0; i < 2; i++) {
        printf("post_title_story_setup|disp_game|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
               s.disp_game_al[i], s.disp_game_bx[i], s.disp_game_cx[i],
               s.disp_game_di[i]);
    }
}

static void hime_transition_trace(void) {
    opening_hime_transition_summary_t s = opening_hime_transition_summary();
    printf("post_title_hime_transition|gfx_palette|ax=%04X\n", s.palette_ax);
    printf("post_title_hime_transition|disp_game|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.disp_game_al, s.disp_game_bx, s.disp_game_cx, s.disp_game_di);
    printf("post_title_hime_transition|sar_load|al=%04X,di=%04X,asset=%s\n",
           s.sar_al, s.sar_di, s.sar_asset);
    printf("post_title_hime_transition|decompress_image|si=%04X,di=%04X\n",
           s.decompress_si, s.decompress_di);
}

static void dmaou_transition_trace(void) {
    opening_dmaou_transition_summary_t s = opening_dmaou_transition_summary();
    printf("post_title_dmaou_transition|disp_font_inv|ax=0000\n");
    printf("post_title_dmaou_transition|gfx_palette|ax=%04X\n", s.palette_ax);
    printf("post_title_dmaou_transition|disp_game|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.disp_game_al, s.disp_game_bx, s.disp_game_cx, s.disp_game_di);
    printf("post_title_dmaou_transition|sar_load|al=%04X,di=%04X,asset=%s\n",
           s.sar_al, s.sar_di, s.sar_asset);
    printf("post_title_dmaou_transition|decompress_image|si=%04X,di=%04X\n",
           s.decompress_si, s.decompress_di);
}

static void apparition_overlay_trace(void) {
    opening_apparition_overlay_summary_t s = opening_apparition_overlay_summary();
    printf("post_title_apparition_overlay|disp_data_7420|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.al, s.bx, s.cx, s.di);
}

static void apparition_remove_isi_trace(void) {
    opening_apparition_remove_isi_summary_t s = opening_apparition_remove_isi_summary();
    printf("post_title_apparition_remove_isi|busy_wait|al=%04X\n", s.busy_wait_al[0]);
    printf("post_title_apparition_remove_isi|disp_game|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.disp_game_al[0], s.disp_game_bx[0], s.disp_game_cx[0], s.disp_game_di[0]);
    printf("post_title_apparition_remove_isi|story_timer_wait|al=%04X\n",
           s.story_timer_wait_al);
    printf("post_title_apparition_remove_isi|busy_wait|al=%04X\n", s.busy_wait_al[1]);
    printf("post_title_apparition_remove_isi|disp_game|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.disp_game_al[1], s.disp_game_bx[1], s.disp_game_cx[1], s.disp_game_di[1]);
    printf("post_title_apparition_remove_isi|sar_load|al=%04X,di=%04X,asset=%s\n",
           s.sar_al, s.sar_di, s.sar_asset);
    printf("post_title_apparition_remove_isi|decompress_image|si=%04X,di=%04X\n",
           s.decompress_si, s.decompress_di);
    printf("post_title_apparition_remove_isi|gfx_mode|al=0002,bx=%04X,cx=%04X\n",
           s.gfx_mode_bx, s.gfx_mode_cx);
}

static void isi_reveal_trace(void) {
    opening_isi_reveal_summary_t s = opening_isi_reveal_summary();
    printf("post_title_isi_reveal|gfx_palette|ax=%04X\n", s.palette_ax);
    printf("post_title_isi_reveal|gfx_update|al=%04X,bx=%04X,cx=%04X,di=%04X\n",
           s.gfx_update_al, s.gfx_update_bx, s.gfx_update_cx, s.gfx_update_di);
}

static void late_scene_trace(void) {
    printf("post_title_yuu_setup|sar_load|al=0002,di=A000,asset=yuu1.grp\n");
    printf("post_title_yuu_setup|decompress_image|si=A000,di=4000\n");
    printf("post_title_yuu_setup|gfx_update|al=00FF,bx=0410,cx=4868,di=4000\n");
    printf("post_title_yuu_setup|sar_load|al=0002,di=A000,asset=yuup.grp\n");
    printf("post_title_yuu_setup|decompress_image|si=A000,di=4000\n");
    printf("post_title_yuu_setup|sar_load|al=0002,di=A000,asset=oup.grp\n");
    printf("post_title_yuu_setup|decompress_image|si=A000,di=8000\n");

    printf("post_title_yuu_split|disp_font_inv|ax=0000\n");
    printf("post_title_yuu_split|gfx_palette|ax=0006\n");
    printf("post_title_yuu_split|disp_load_setup|bx=0A15,cx=1A5D\n");
    printf("post_title_yuu_split|disp_game|al=0006,bx=0B18,cx=1858,di=4000\n");
    printf("post_title_yuu_split|disp_load_setup|bx=2C15,cx=1A5D\n");
    printf("post_title_yuu_split|disp_game|al=0006,bx=2D18,cx=1858,di=8000\n");

    printf("post_title_maop_setup|sar_load|al=0002,di=A000,asset=maop.grp\n");
    printf("post_title_maop_setup|decompress_image|si=A000,di=8000\n");
    printf("post_title_maop_setup|disp_font_inv|ax=0000\n");
    printf("post_title_maop_setup|gfx_palette|ax=0008\n");
    printf("post_title_maop_setup|disp_load_setup|bx=1515,cx=315D\n");
    printf("post_title_maop_setup|disp_script_area|bx=1618,cx=315D,di=8000\n");

    printf("post_title_yuu2_setup|disp_font_inv|ax=0000\n");
    printf("post_title_yuu2_setup|gfx_palette|ax=0007\n");
    printf("post_title_yuu2_setup|sar_load|al=0002,di=A000,asset=yuu2.grp\n");
    printf("post_title_yuu2_setup|decompress_image|si=A000,di=4000\n");
    printf("post_title_yuu2_setup|disp_game|al=0002,bx=1010,cx=3160,di=4000\n");

    printf("post_title_final_scene|sar_load|al=0002,di=A000,asset=yuu3.grp\n");
    printf("post_title_final_scene|sar_load|al=0002,di=D000,asset=yuu4.grp\n");
    printf("post_title_final_scene|decompress_image|si=A000,di=4000\n");
    printf("post_title_final_scene|gfx_mode|al=0002,bx=0000,cx=50C8\n");
    printf("post_title_final_scene|merge_gfx_planes|bx=0808,cx=50C8,di=4000\n");
    printf("post_title_final_scene|decompress_image|si=D000,di=D000\n");
    printf("post_title_final_scene|xor_mask_render|si=D000,di=4000\n");
    printf("post_title_final_scene|gfx_update|al=00FF,bx=0808,cx=40C0,di=4000\n");
    printf("post_title_final_scene|story_timer_wait|al=00F0\n");
    printf("post_title_final_scene|gfx_draw|al=00FF,bx=0808,cx=40C0,di=4000\n");
    printf("post_title_final_scene|gfx_palette|ax=0001\n");
    printf("post_title_final_scene|animate_scanline_alt|si=7338\n");
    for (int i = 0; i < 10; i++)
        printf("post_title_final_scene|story_timer_wait|al=00C8\n");
}

int main(void) {
    title_asset_trace();
    title_display_trace();
    next_scene_trace();
    post_title_story_trace();
    hime_transition_trace();
    dmaou_transition_trace();
    apparition_overlay_trace();
    apparition_remove_isi_trace();
    isi_reveal_trace();
    late_scene_trace();
    return 0;
}
