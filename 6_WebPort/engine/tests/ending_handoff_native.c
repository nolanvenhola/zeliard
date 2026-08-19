#include "../game/fight_masm_vm.h"
#include "../render/palette.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    for (size_t i = 0; i < size; ++i) {
        hash ^= data[i];
        hash *= 0x100000001B3ULL;
    }
    return hash;
}

static int write_visual_fixture(const char *path, const u8 *vga) {
    FILE *ppm = fopen(path, "wb");
    if (!ppm) return 0;
    fputs("P6\n320 200\n255\n", ppm);
    for (unsigned i = 0; i < 64000; ++i) {
        fputc(g_palette[vga[i]].r, ppm);
        fputc(g_palette[vga[i]].g, ppm);
        fputc(g_palette[vga[i]].b, ppm);
    }
    return fclose(ppm) == 0;
}

static void prepare_player(u8 *game) {
    memset(game, 0, 0x10000);
    game[0x80] = 4;
    game[0x82] = 21;
    game[0x83] = 12;
    game[0x91] = 2;
    game[0x98] = 1;
    game[0xA0] = 8;
    game[0xB3] = 2;
    game[0xC4] = 0x1E;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

int main(void) {
    static u8 game[0x10000], vga[0x10000];
    prepare_player(game);
    palette_set_game_mcga();
    int ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    ok &= zeliard_fight_masm_vm_poke_u16(0xAC06, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xAC20, 0);
    ok &= zeliard_fight_masm_vm_poke_u8(0xFF2E, 0xFF);
    unsigned frames = 0, completion = 0;
    while (zeliard_fight_masm_vm_active() && frames < 300 && !completion) {
        ok &= zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 20, 0);
        ++frames;
        if (!completion && game[0xFF30] == 0xFF) completion = frames;
        if ((frames % 100) == 0 || !zeliard_fight_masm_vm_active())
            printf("handoff frame=%u active=%d ip=%04x completion=%02x "
                   "item=%02x warp=%02x init=%02x area=%02x exit=%u/%02x/%04x\n",
                   frames, zeliard_fight_masm_vm_active(),
                   zeliard_fight_masm_vm_ip(), game[0xFF30], game[0xFF4B],
                   zeliard_fight_masm_vm_peek_u8(0x9F1E), game[0xB3],
                   game[0xC4], zeliard_fight_masm_vm_exit_operation(),
                   zeliard_fight_masm_vm_exit_selector(),
                   zeliard_fight_masm_vm_exit_dispatch_slot());
    }
    printf("completion=%u frames=%u active=%d\n", completion, frames,
           zeliard_fight_masm_vm_active());
    /* FF30h completes the arena but does not start the ending. In the real
     * flow Duke faints, the Spirits return him outdoors in front of
     * Felishika Castle, the automatic guard greets him, and Duke walks into
     * the King's chamber.  The King's A6C1h post-victory speech then sends
     * him to Felicia's hut. Simulate only that final 211OMOYP signal here. */
    ok &= completion == 121 && zeliard_fight_masm_vm_active();
    game[0x49] = 0xFF;
    zeliard_fight_masm_vm_stop();
    const int ending_started = zeliard_fight_masm_vm_begin_ending(
        game, sizeof(game), vga, sizeof(vga));
    printf("ending_started=%d ip=%04x wait=%d\n", ending_started,
           zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_ending_active());
    unsigned transition_ticks = 0;
    while (zeliard_fight_masm_vm_ending_active() &&
           zeliard_fight_masm_vm_peek_u8(0xFF77) != 0xFF &&
           transition_ticks < 4000) {
        (void)zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 1, 0);
        ++transition_ticks;
    }
    printf("ending_driver_transition: ticks=%u ip=%04x cinematic=%02x\n",
           transition_ticks, zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_peek_u8(0xFF77));
    unsigned endmo_ticks = 0;
    int presented = 0;
    while (zeliard_fight_masm_vm_ending_active() && !presented &&
           endmo_ticks < 1000) {
        presented = zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 1, 0);
        ++endmo_ticks;
    }
    ok &= presented;
    const unsigned long long first_ending_hash = fnv1a64(vga, 64000);
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/ending-first-frame.ppm", vga);
    printf("ending_first_frame: ticks=%u active=%d ip=%04x scene=%u music=%02x "
           "hash=%016llx color7=%02x/%02x/%02x color77=%02x/%02x/%02x\n",
           endmo_ticks,
           zeliard_fight_masm_vm_ending_active(),
           zeliard_fight_masm_vm_ip(),
           zeliard_fight_masm_vm_ending_scene(),
           zeliard_fight_masm_vm_music_chunk(), first_ending_hash,
           g_palette[7].r, g_palette[7].g, g_palette[7].b,
           g_palette[0x77].r, g_palette[0x77].g, g_palette[0x77].b);
    unsigned composed_ticks = 0;
    while (zeliard_fight_masm_vm_ending_active() &&
           (zeliard_fight_masm_vm_ip() < 0x62EE ||
            zeliard_fight_masm_vm_ip() > 0x6305) &&
           composed_ticks < 2000) {
        (void)zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 1, 0);
        ++composed_ticks;
    }
    const unsigned long long composed_hash = fnv1a64(vga, 64000);
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/ending-split-frame.ppm", vga);
    printf("ending_split_composition: ticks=%u ip=%04x hash=%016llx\n",
           composed_ticks, zeliard_fight_masm_vm_ip(), composed_hash);
    unsigned pan_ticks = 0;
    while (zeliard_fight_masm_vm_ending_active() &&
           zeliard_fight_masm_vm_peek_u16(0x6630) == 0x6AA8 &&
           pan_ticks < 4000) {
        (void)zeliard_fight_masm_vm_advance(
            game, sizeof(game), vga, sizeof(vga), 1, 0);
        ++pan_ticks;
    }
    const unsigned long long panned_hash = fnv1a64(vga, 64000);
    const u16 panned_script = zeliard_fight_masm_vm_peek_u16(0x6630);
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/ending-princess-pan.ppm", vga);
    printf("ending_princess_pan_complete: ticks=%u script=%04x hash=%016llx\n",
           pan_ticks, panned_script, panned_hash);
    static u8 presented_text_vga[0x10000];
    memcpy(presented_text_vga, vga, sizeof(presented_text_vga));
    unsigned text_ticks = 0;
    unsigned text_presentations = 0;
    while (zeliard_fight_masm_vm_ending_active() &&
           zeliard_fight_masm_vm_peek_u16(0x6630) < 0x6AC0 &&
           text_ticks < 2000) {
        if (zeliard_fight_masm_vm_advance(
                game, sizeof(game), vga, sizeof(vga), 16, 0)) {
            memcpy(presented_text_vga, vga, sizeof(presented_text_vga));
            ++text_presentations;
        }
        ++text_ticks;
    }
    const u16 text_script = zeliard_fight_masm_vm_peek_u16(0x6630);
    const unsigned long long text_hash = fnv1a64(vga, 64000);
    const unsigned long long presented_text_hash =
        fnv1a64(presented_text_vga, 64000);
    unsigned text_pixels_changed = 0;
    for (unsigned i = 143u * 320u; i < 200u * 320u; ++i)
        if (vga[i] != 0) ++text_pixels_changed;
    if (getenv("ZELIARD_DUMP"))
        ok &= write_visual_fixture("build/ending-princess-text.ppm", vga);
    printf("ending_princess_text: ticks=%u script=%04x hash=%016llx "
           "presented=%u/%016llx nonblack=%u\n", text_ticks, text_script,
           text_hash, text_presentations, presented_text_hash,
           text_pixels_changed);
    unsigned ending_steps = 0;
    u8 last_scene = zeliard_fight_masm_vm_ending_scene();
    unsigned scene_changes = 0;
    unsigned credit_presentations = 0;
    unsigned authored_credit_presses = 0;
    int release_credit_action = 0;
    static u8 presented_credits_vga[0x10000];
    memcpy(presented_credits_vga, vga, sizeof(presented_credits_vga));
    while (zeliard_fight_masm_vm_ending_active() &&
           !zeliard_fight_masm_vm_ending_finished() &&
           ending_steps < 30000) {
        /* Advance every timed narration/credit boundary with no input.  Only
         * inject a fresh action edge when the release VM is actually parked
         * on 250ENDMO's F7 `test byte ptr [FF21h],FFh` wait.  The authored
         * credits byte stream contains exactly three such gates: one in
         * the preamble at 787Fh and two later in the named script body. */
        const u16 ending_ip = zeliard_fight_masm_vm_ip();
        const int at_credit_action_gate =
            zeliard_fight_masm_vm_peek_u8(ending_ip) == 0xF6 &&
            zeliard_fight_masm_vm_peek_u8((u16)(ending_ip + 1u)) == 0x06 &&
            zeliard_fight_masm_vm_peek_u8((u16)(ending_ip + 2u)) == 0x21 &&
            zeliard_fight_masm_vm_peek_u8((u16)(ending_ip + 3u)) == 0xFF;
        if (at_credit_action_gate && !release_credit_action) {
            game[0xFF16] = 1;
            release_credit_action = 1;
            ++authored_credit_presses;
            printf("ending_credit_action_gate: press=%u step=%u pc=%04x scene=%u\n",
                   authored_credit_presses, ending_steps,
                   zeliard_fight_masm_vm_peek_u16(0x6965),
                   zeliard_fight_masm_vm_ending_scene());
        } else {
            game[0xFF16] = 0;
            release_credit_action = 0;
        }
        if (zeliard_fight_masm_vm_advance(
                game, sizeof(game), vga, sizeof(vga), 255, 0)) {
            memcpy(presented_credits_vga, vga,
                   sizeof(presented_credits_vga));
            ++credit_presentations;
        }
        const u8 scene = zeliard_fight_masm_vm_ending_scene();
        if (scene != last_scene) {
            printf("ending_scene_change: step=%u scene=%u ip=%04x music=%02x\n",
                   ending_steps, scene, zeliard_fight_masm_vm_ip(),
                   zeliard_fight_masm_vm_music_chunk());
            if (getenv("ZELIARD_DUMP")) {
                char path[64];
                snprintf(path, sizeof(path),
                         "build/ending-credit-scene-%u.ppm", scene);
                ok &= write_visual_fixture(path, vga);
            }
            last_scene = scene;
            ++scene_changes;
        }
        ++ending_steps;
    }
    const unsigned long long final_hash = fnv1a64(vga, 64000);
    const unsigned long long presented_final_hash =
        fnv1a64(presented_credits_vga, 64000);
    printf("ending_complete: steps=%u finished=%d scene=%u changes=%u "
           "presses=%u presented=%u hash=%016llx/%016llx music=%02x ip=%04x\n",
           ending_steps, zeliard_fight_masm_vm_ending_finished(),
           zeliard_fight_masm_vm_ending_scene(), scene_changes,
           authored_credit_presses, credit_presentations, final_hash,
           presented_final_hash,
           zeliard_fight_masm_vm_music_chunk(), zeliard_fight_masm_vm_ip());
    ok &= ending_started && zeliard_fight_masm_vm_ending_active() &&
        zeliard_fight_masm_vm_music_chunk() == 0x27 &&
        zeliard_fight_masm_vm_peek_u8(0xFF77) == 0xFF &&
        g_palette[0x77].r == 0xFB && g_palette[0x77].g == 0xFB &&
        g_palette[0x77].b == 0xFB &&
        transition_ticks == 160 && endmo_ticks == 1 &&
        first_ending_hash == 0xDD14FCC6528CAB25ULL &&
        composed_ticks == 365 &&
        composed_hash == 0x70243A26C753C1E9ULL &&
        pan_ticks == 1465 &&
        panned_script == 0x6AA9 &&
        panned_hash == 0x8FC1408E72EAFCF4ULL &&
        text_ticks == 23 && text_script == 0x6AC0 &&
        text_hash == 0x7B6C469F5086C5CAULL &&
        text_presentations == 21 &&
        presented_text_hash == 0x7B6C469F5086C5CAULL &&
        text_pixels_changed == 342 &&
        ending_steps < 30000 && authored_credit_presses == 3 &&
        scene_changes == 7 && last_scene == 7 &&
        credit_presentations > 0 &&
        final_hash == 0x3DE6D98CBF2922D8ULL &&
        presented_final_hash == final_hash &&
        zeliard_fight_masm_vm_ending_finished();
    printf("VERDICT: %s: Jashiin completion remains playable; shrine starts 250ENDMO\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
