#include "../game/opening.h"
#include "../game/opening_trace.h"
#include <stdio.h>

int main(void) {
    enum { MAX_EVENTS = 8192 };
    zel_opdmo_trace_event_t events[MAX_EVENTS];
    size_t counts[ZEL_OPDMO_TRACE_SCRIPT_CONTROL + 1] = {0};
    size_t wait_10 = 0;
    size_t wait_f0 = 0;
    zel_opdmo_trace_event_t first_glyphs[4];
    size_t first_glyph_count = 0;
    int saw_waku = 0;
    int saw_ame = 0;
    int saw_merge = 0;
    int saw_xor = 0;
    int saw_final_mode = 0;
    int saw_final_draw = 0;
    int final_setup_index = 0;
    int split_index = 0;
    int saw_oui_update = 0;

    zel_opdmo_trace_reset();
    opening_init();
    size_t init_count = zel_opdmo_trace_copy(events, MAX_EVENTS);
    for (size_t i = 0; i < init_count; i++) {
        const zel_opdmo_trace_event_t *event = &events[i];
        if (final_setup_index == 0 && event->kind == ZEL_OPDMO_TRACE_SAR_LOAD &&
            event->ax == 2 && event->bx == 0x95E8 && event->di == 0xA000)
            final_setup_index++;
        else if (final_setup_index == 1 && event->kind == ZEL_OPDMO_TRACE_SAR_LOAD &&
                 event->ax == 2 && event->bx == 0x95F3 && event->di == 0xD000)
            final_setup_index++;
        else if (final_setup_index == 2 &&
                 event->kind == ZEL_OPDMO_TRACE_DECOMPRESS_IMAGE &&
                 event->ax == 2 && event->bx == 0xA000 && event->di == 0x4000)
            final_setup_index++;
        else if (final_setup_index == 3 && event->kind == ZEL_OPDMO_TRACE_GFX_MODE &&
                 event->ax == 0 && event->bx == 0 && event->cx == 0x50C8)
            final_setup_index++;
        else if (final_setup_index == 4 &&
                 event->kind == ZEL_OPDMO_TRACE_MERGE_GFX_PLANES &&
                 event->ax == 2 && event->bx == 0x0808 && event->cx == 0x50C8 &&
                 event->di == 0x4000)
            final_setup_index++;
        else if (final_setup_index == 5 &&
                 event->kind == ZEL_OPDMO_TRACE_DECOMPRESS_IMAGE &&
                 event->ax == 2 && event->bx == 0xD000 && event->di == 0xD000)
            final_setup_index++;
        else if (final_setup_index == 6 &&
                 event->kind == ZEL_OPDMO_TRACE_XOR_MASK_RENDER &&
                 event->ax == 2 && event->bx == 0xD000 && event->di == 0x4000)
            final_setup_index++;
        if (event->kind == ZEL_OPDMO_TRACE_MERGE_GFX_PLANES &&
            event->ax == 2 && event->bx == 0x0808 && event->cx == 0x50C8 &&
            event->di == 0x4000)
            saw_merge = 1;
        if (event->kind == ZEL_OPDMO_TRACE_GFX_MODE && event->ax == 0 &&
            event->bx == 0 && event->cx == 0x50C8)
            saw_final_mode = 1;
        if (event->kind == ZEL_OPDMO_TRACE_XOR_MASK_RENDER &&
            event->ax == 2 && event->bx == 0xD000 && event->di == 0x4000)
            saw_xor = 1;
    }
    if (final_setup_index != 7 || !saw_final_mode || !saw_merge || !saw_xor ||
        zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live YUU3/YUU4 merge/XOR trace diverges from MASM\n");
        return 1;
    }

    /* 100OPDMO:1071-1082. The post-F0 gfx_draw is a separate call from the
     * first masked GFX_BLIT and must occur before palette 1. */
    zel_opdmo_trace_reset();
    opening_render_phase_for_test(11, 1800);
    size_t final_draw_count = zel_opdmo_trace_copy(events, MAX_EVENTS);
    for (size_t i = 0; i < final_draw_count; i++) {
        const zel_opdmo_trace_event_t *event = &events[i];
        if (event->kind == ZEL_OPDMO_TRACE_GFX_DRAW && event->ax == 0x00FF &&
            event->bx == 0x0808 && event->cx == 0x40C0 &&
            event->di == 0x4000) {
            saw_final_draw = 1;
            break;
        }
    }
    if (!saw_final_draw || zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live final YUU gfx_draw trace diverges from MASM\n");
        return 1;
    }

    /* These are the two real disp_game calls that build the first story
     * frame.  The register tuples are from the MASM post-title setup oracle. */
    zel_opdmo_trace_reset();
    opening_render_phase_for_test(3, 700);
    size_t image_count = zel_opdmo_trace_copy(events, MAX_EVENTS);
    for (size_t i = 0; i < image_count; i++) {
        const zel_opdmo_trace_event_t *event = &events[i];
        if (event->kind != ZEL_OPDMO_TRACE_DISP_GAME)
            continue;
        if (event->ax == 0 && event->bx == 0x0000 && event->cx == 0x5088 &&
            event->di == 0 && event->es_delta == 0x2000)
            saw_waku = 1;
        if (event->ax == 0 && event->bx == 0x0410 && event->cx == 0x4868 &&
            event->di == 0x4000 && event->es_delta == 0)
            saw_ame = 1;
    }
    if (!saw_waku || !saw_ame || zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live WAKU/AME disp_game trace diverges from MASM\n");
        return 1;
    }

    zel_opdmo_trace_reset();
    opening_render_phase_for_test(8, 0);
    size_t split_count = zel_opdmo_trace_copy(events, MAX_EVENTS);
    for (size_t i = 0; i < split_count; i++) {
        const zel_opdmo_trace_event_t *event = &events[i];
        if (split_index == 0 && event->kind == ZEL_OPDMO_TRACE_GFX_PALETTE &&
            event->ax == 6)
            split_index++;
        else if (split_index == 1 &&
                 event->kind == ZEL_OPDMO_TRACE_DISP_LOAD_SETUP &&
                 event->ax == 6 && event->bx == 0x0A15 && event->cx == 0x1A5D)
            split_index++;
        else if (split_index == 2 && event->kind == ZEL_OPDMO_TRACE_DISP_GAME &&
                 event->ax == 6 && event->bx == 0x0B18 && event->cx == 0x1858 &&
                 event->di == 0x4000)
            split_index++;
        else if (split_index == 3 &&
                 event->kind == ZEL_OPDMO_TRACE_DISP_LOAD_SETUP &&
                 event->ax == 6 && event->bx == 0x2C15 && event->cx == 0x1A5D)
            split_index++;
        else if (split_index == 4 && event->kind == ZEL_OPDMO_TRACE_DISP_GAME &&
                 event->ax == 6 && event->bx == 0x2D18 && event->cx == 0x1858 &&
                 event->di == 0x8000)
            split_index++;
    }
    if (split_index != 5 || zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live YUU split reveal trace diverges from MASM\n");
        return 1;
    }

    /* The OUI update sits after scripts 8 and 9 in phase 6. Search phase
     * local time through the real renderer rather than duplicating its timing
     * arithmetic in the test. */
    for (u32 elapsed = 0; elapsed <= 30000 && !saw_oui_update; elapsed += 500) {
        zel_opdmo_trace_reset();
        opening_render_phase_for_test(6, elapsed);
        size_t update_count = zel_opdmo_trace_copy(events, MAX_EVENTS);
        for (size_t i = 0; i < update_count; i++) {
            const zel_opdmo_trace_event_t *event = &events[i];
            if (event->kind == ZEL_OPDMO_TRACE_GFX_UPDATE && event->ax == 0 &&
                event->bx == 0x0410 && event->cx == 0x4868 &&
                event->di == 0x4000) {
                saw_oui_update = 1;
                break;
            }
        }
    }
    if (!saw_oui_update || zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live OUI gfx_update trace diverges from MASM\n");
        return 1;
    }

    zel_opdmo_trace_reset();
    /* Phase 3 executes the real AME story renderer and its first MASM script. */
    opening_render_phase_for_test(3, 120000);

    size_t count = zel_opdmo_trace_copy(events, MAX_EVENTS);
    for (size_t i = 0; i < count; i++) {
        if ((size_t)events[i].kind < sizeof(counts) / sizeof(counts[0]))
            counts[events[i].kind]++;
        if (events[i].kind == ZEL_OPDMO_TRACE_SCRIPT_WAIT) {
            if (events[i].ax == 0x0010) wait_10++;
            if (events[i].ax == 0x00F0) wait_f0++;
        }
        if (events[i].kind == ZEL_OPDMO_TRACE_SCRIPT_GLYPH &&
            first_glyph_count < sizeof(first_glyphs) / sizeof(first_glyphs[0]))
            first_glyphs[first_glyph_count++] = events[i];
    }

    printf("live_trace palette=%llu wait=%llu byte=%llu glyph=%llu control=%llu dropped=%llu\n",
           (unsigned long long)counts[ZEL_OPDMO_TRACE_GFX_PALETTE],
           (unsigned long long)counts[ZEL_OPDMO_TRACE_SCRIPT_WAIT],
           (unsigned long long)counts[ZEL_OPDMO_TRACE_SCRIPT_BYTE],
           (unsigned long long)counts[ZEL_OPDMO_TRACE_SCRIPT_GLYPH],
           (unsigned long long)counts[ZEL_OPDMO_TRACE_SCRIPT_CONTROL],
           (unsigned long long)zel_opdmo_trace_dropped());
    /* Exact MASM oracle: test_opdemo_opening_sequence.py first story script. */
    if (count == 0 || counts[ZEL_OPDMO_TRACE_GFX_PALETTE] == 0 ||
        counts[ZEL_OPDMO_TRACE_SCRIPT_WAIT] != 777 || wait_10 != 743 ||
        wait_f0 != 34 || counts[ZEL_OPDMO_TRACE_SCRIPT_BYTE] != 743 ||
        counts[ZEL_OPDMO_TRACE_SCRIPT_GLYPH] != 1372 ||
        counts[ZEL_OPDMO_TRACE_SCRIPT_CONTROL] != 57 ||
        first_glyph_count != 4 ||
        first_glyphs[0].ax != 0x0050 || first_glyphs[0].bx != 0x0005 ||
        first_glyphs[0].cx != 0x0090 ||
        first_glyphs[1].ax != 0x0050 || first_glyphs[1].bx != 0x0004 ||
        first_glyphs[1].cx != 0x008F ||
        first_glyphs[2].ax != 0x004F || first_glyphs[2].bx != 0x0005 ||
        first_glyphs[2].cx != 0x009A ||
        first_glyphs[3].ax != 0x074F || first_glyphs[3].bx != 0x0004 ||
        first_glyphs[3].cx != 0x0099 ||
        zel_opdmo_trace_dropped() != 0) {
        printf("VERDICT: FAIL: live AME script trace diverges from MASM\n");
        return 1;
    }
    printf("VERDICT: PASS: live WAKU/AME, OUI update, YUU split, and AME script match MASM\n");
    return 0;
}
