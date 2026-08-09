#include "../game/fight_masm_vm.h"
#include "../render/palette.h"

#include <stdio.h>
#include <string.h>

static unsigned long long fnv1a64(const u8 *data, size_t size) {
    unsigned long long hash = 0xCBF29CE484222325ULL;
    while (size--) { hash ^= *data++; hash *= 0x100000001B3ULL; }
    return hash;
}

static void prepare_player(u8 *game, u8 spell, u8 charges) {
    memset(game, 0, 0x10000);
    game[0x80] = 18 - 16;
    game[0x82] = (58 - 9) & 0x3F;
    game[0x90] = 0x00;
    game[0x91] = 0x01;
    game[0x92] = 1;
    game[0x93] = 1;
    game[0x94] = 0x64;
    game[0x96] = 0x64;
    game[0x9D] = spell;
    game[0xAB + spell - 1] = charges;
    game[0xB4 + spell - 1] = charges;
    game[0xBB + spell - 1] = 0xFF;
    game[0xB2] = 0x00;
    game[0xB3] = 0x01;
    game[0xFF26] = 0xFF;
    game[0xFF33] = 5;
}

static int advance_frame(u8 *game, u8 *vga, u8 direction) {
    for (unsigned attempt = 0; attempt < 256; ++attempt) {
        const int rendered = zeliard_fight_masm_vm_advance(
            game, 0x10000, vga, 0x10000, 20, direction);
        if (!zeliard_fight_masm_vm_active() ||
            zeliard_fight_masm_vm_at_frame()) return rendered;
    }
    return 0;
}

typedef struct {
    int ok;
    u8 charge;
    u8 active;
    u16 slot_x;
    u8 slot_y;
    u8 slot_flags;
    u8 slot_frame;
    u8 slot_dir;
    u8 cues[32];
    unsigned cue_count;
    unsigned active_mask;
    unsigned long long frame_hash;
} spell_probe_t;

static spell_probe_t cast_spell(u8 spell, u8 charges, u8 facing) {
    static u8 game[0x10000], vga[0x10000];
    spell_probe_t result;
    memset(&result, 0, sizeof(result));
    prepare_player(game, spell, charges);
    palette_set_game_mcga();
    result.ok = zeliard_fight_masm_vm_start(
        game, sizeof(game), vga, sizeof(vga));
    game[0xC2] = facing;
    game[0xFF1E] = 0xFF;
    for (unsigned frame = 0; frame < 32; ++frame) {
        result.ok &= advance_frame(game, vga, 0);
        result.active_mask |=
            (unsigned)(game[0xFF3E] != 0) << (frame & 31u);
        for (u8 cue; (cue = zeliard_fight_masm_vm_take_sound_cue()) != 0;)
            if (result.cue_count < 32)
                result.cues[result.cue_count++] = cue;
    }
    result.charge = game[0xAB + spell - 1];
    result.active = game[0xFF3E];
    result.slot_x = (u16)zeliard_fight_masm_vm_peek_u16(0xEB15);
    result.slot_y = (u8)zeliard_fight_masm_vm_peek_u8(0xEB17);
    result.slot_flags = (u8)zeliard_fight_masm_vm_peek_u8(0xEB18);
    result.slot_frame = (u8)zeliard_fight_masm_vm_peek_u8(0xEB19);
    result.slot_dir = (u8)zeliard_fight_masm_vm_peek_u8(0xEB1A);
    result.frame_hash = fnv1a64(vga, 64000);
    zeliard_fight_masm_vm_stop();
    return result;
}

static void print_probe(const char *spell, const char *name,
                        const spell_probe_t *result) {
    printf("spell_%s_%s: charge=%u active=%02x "
           "slot=%04x/%02x/%02x/%02x/%02x cues=",
           spell, name, result->charge, result->active, result->slot_x,
           result->slot_y, result->slot_flags, result->slot_frame,
           result->slot_dir);
    for (unsigned i = 0; i < result->cue_count; ++i)
        printf("%02x", result->cues[i]);
    printf(" active_mask=%08x frame=%016llx\n", result->active_mask,
           result->frame_hash);
}

static int has_cue(const spell_probe_t *result, u8 expected) {
    for (unsigned i = 0; i < result->cue_count; ++i)
        if (result->cues[i] == expected) return 1;
    return 0;
}

int main(void) {
    const spell_probe_t right = cast_spell(1, 3, 0);
    const spell_probe_t left = cast_spell(1, 3, 1);
    const spell_probe_t empty = cast_spell(1, 0, 0);
    const spell_probe_t saeta_right = cast_spell(2, 3, 0);
    const spell_probe_t saeta_left = cast_spell(2, 3, 1);
    const spell_probe_t saeta_empty = cast_spell(2, 0, 0);
    print_probe("espada", "right", &right);
    print_probe("espada", "left", &left);
    print_probe("espada", "empty", &empty);
    print_probe("saeta", "right", &saeta_right);
    print_probe("saeta", "left", &saeta_left);
    print_probe("saeta", "empty", &saeta_empty);
    const int ok = right.ok && left.ok && empty.ok &&
        right.charge == 2 && right.active == 0 &&
        right.slot_x == 0xFFFF && right.slot_y == 0x3B &&
        right.slot_flags == 0x81 && right.slot_frame == 1 &&
        right.slot_dir == 1 && right.active_mask == 0x0000000C &&
        right.frame_hash == 0xE0BD8B77231AE163ULL &&
        has_cue(&right, 0x17) && has_cue(&right, 0x18) &&
        left.charge == 2 && left.active == 0 &&
        left.slot_x == 0xFFFF && left.slot_y == 0x3B &&
        left.slot_flags == 0 && left.slot_frame == 5 && left.slot_dir == 1 &&
        left.active_mask == 0x0000007C &&
        left.frame_hash == 0xA6449A0FD1BE0E7AULL &&
        has_cue(&left, 0x17) && has_cue(&left, 0x18) &&
        empty.charge == 0 && empty.active == 0 &&
        empty.slot_x == 0xFFFF && empty.slot_y == 0 &&
        empty.slot_flags == 0 && empty.slot_frame == 0 &&
        empty.slot_dir == 0 && empty.active_mask == 0 &&
        empty.frame_hash == 0xAADFEDB233F3F9A4ULL &&
        has_cue(&empty, 0x17) && !has_cue(&empty, 0x18) &&
        saeta_right.ok && saeta_left.ok && saeta_empty.ok &&
        saeta_right.charge == 2 && saeta_right.active == 0 &&
        saeta_right.slot_x == 0xFFFF && saeta_right.slot_y == 0x3B &&
        saeta_right.slot_flags == 1 && saeta_right.slot_frame == 0x0A &&
        saeta_right.slot_dir == 0 &&
        saeta_right.active_mask == 0x00000FFC &&
        saeta_right.frame_hash == 0xE0BD8B77231AE163ULL &&
        has_cue(&saeta_right, 0x17) && has_cue(&saeta_right, 0x18) &&
        saeta_left.charge == 2 && saeta_left.active == 0 &&
        saeta_left.slot_x == 0xFFFF && saeta_left.slot_y == 0x3B &&
        saeta_left.slot_flags == 0 && saeta_left.slot_frame == 0x0A &&
        saeta_left.slot_dir == 0 &&
        saeta_left.active_mask == 0x00000FFC &&
        saeta_left.frame_hash == 0xA6449A0FD1BE0E7AULL &&
        has_cue(&saeta_left, 0x17) && has_cue(&saeta_left, 0x18) &&
        saeta_empty.charge == 0 && saeta_empty.active == 0 &&
        saeta_empty.slot_x == 0xFFFF && saeta_empty.slot_y == 0 &&
        saeta_empty.slot_flags == 0 && saeta_empty.slot_frame == 0 &&
        saeta_empty.slot_dir == 0 && saeta_empty.active_mask == 0 &&
        saeta_empty.frame_hash == 0xAADFEDB233F3F9A4ULL &&
        has_cue(&saeta_empty, 0x17) && !has_cue(&saeta_empty, 0x18);
    printf("VERDICT: %s: release MASM spell cast probes\n",
           ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
