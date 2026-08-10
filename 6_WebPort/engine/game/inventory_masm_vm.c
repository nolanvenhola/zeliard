#include "inventory_masm_vm.h"

#include "../core/player_state.h"
#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../third_party/8086tiny/8086tiny.h"

#include <stdlib.h>
#include <string.h>

void zel_inventory86_reset(const unsigned char *bios, unsigned bios_size);
void zel_inventory86_set_step_callback(zel_tiny86_step_fn callback,
                                       void *context);
int zel_inventory86_run(unsigned max_instructions);
unsigned char *zel_inventory86_memory(void);
unsigned zel_inventory86_memory_size(void);
unsigned short *zel_inventory86_registers(void);
unsigned short zel_inventory86_ip(void);
void zel_inventory86_set_ip(unsigned short value);
void zel_inventory86_set_flags(unsigned short value);

enum {
    GAME_SEG = 0x1000,
    ITEMP_SEG = 0x2000,
    ASSET_SEG_2 = 0x3000,
    STACK_SEG = 0x8000,
    VGA_SEG = 0xA000,
    SELCT_LOAD_BASE = 0x9FFC,
    SELCT_CAVERN_ENTRY = 0xA001,
    SELCT_TOWN_ENTRY = 0xA00B,
    SELCT_POLL_INPUT = 0xAA6C,
    INSTRUCTIONS_PER_PIT = 12000,
};

typedef struct {
    u8 active;
    u8 at_input_poll;
    u8 allow_poll_once;
    u8 direction;
    u16 trace[16];
    u8 trace_at;
    u8 sound_cues[16];
    u8 sound_cue_read;
    u8 sound_cue_write;
    u8 sound_cue_count;
} inventory_vm_state_t;

static inventory_vm_state_t g_inventory_vm;

static void post_sound_cue(inventory_vm_state_t *state, u8 cue) {
    if (!cue) return;
    if (state->sound_cue_count == sizeof(state->sound_cues)) {
        state->sound_cue_read = (u8)((state->sound_cue_read + 1u) & 15u);
        --state->sound_cue_count;
    }
    state->sound_cues[state->sound_cue_write] = cue;
    state->sound_cue_write = (u8)((state->sound_cue_write + 1u) & 15u);
    ++state->sound_cue_count;
}

static size_t linear(u16 segment, u16 offset) {
    return (size_t)segment * 16u + offset;
}

static u16 read_u16(const u8 *memory, size_t address) {
    return (u16)(memory[address] | ((u16)memory[address + 1] << 8));
}

static void write_u16(u8 *memory, size_t address, u16 value) {
    memory[address] = (u8)value;
    memory[address + 1] = (u8)(value >> 8);
}

static void normalize_selected_spell(u8 *game_seg) {
    const u8 selected = game_seg[ZEL_PLAYER_SELECTED_SPELL];
    u8 last_learned = 0;
    for (u8 spell = 1; spell <= 7; ++spell) {
        if (game_seg[ZEL_PLAYER_SPELL_KNOWN + spell - 1] == 0) continue;
        last_learned = spell;
        if (spell == selected) return;
    }

    /* 201SELCT:draw_spell_panel searches selected_spell in the compact
     * spell_idx_tbl, while its input loop limits spell_cursor to
     * spell_count-1. Release saves maintain the invariant that the selected
     * ID is learned; imported/edited saves may not. Clamp such a selection
     * to the compact table's final populated slot (or zero when empty), so
     * the exact MASM cursor can never be drawn over an empty entry. */
    game_seg[ZEL_PLAYER_SELECTED_SPELL] = last_learned;
}

static int load_raw_to(u8 *memory, size_t destination, const char *name) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    if (!file || destination + size > zel_inventory86_memory_size()) {
        free(file);
        return 0;
    }
    memcpy(memory + destination, file, size);
    free(file);
    return 1;
}

static int load_fill_to(u8 *memory, size_t destination, const char *name,
                        size_t *decoded_size) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    size_t output_size = 0;
    u8 *output = file ? fill_buffer_decompress(file, size, &output_size) : NULL;
    free(file);
    if (!output || destination + output_size > zel_inventory86_memory_size()) {
        free(output);
        return 0;
    }
    memcpy(memory + destination, output, output_size);
    free(output);
    if (decoded_size) *decoded_size = output_size;
    return 1;
}

static void relocate_words(u8 *memory, size_t address, u8 count,
                           u16 addend) {
    for (u8 i = 0; i < count; ++i) {
        const size_t at = address + (size_t)i * 2u;
        write_u16(memory, at, (u16)(read_u16(memory, at) + addend));
    }
}

static void sync_game_state_to_host(u8 *game_seg, const u8 *memory,
                                    size_t game) {
    /* 201SELCT owns its A000-AE1F overlay and scratch region. The Magia
     * Stone is the exception to the usual player-record-only contract:
     * release MASM's item-5 handler seeds four seven-byte orbiting-sprite
     * records in 200FIGHT's shared EB60h work buffer. */
    memcpy(game_seg, memory + game, 233);
    memcpy(game_seg + 0x02BC, memory + game + 0x02BC, 9);
    memcpy(game_seg + 0x05C1, memory + game + 0x05C1, 5);
    memcpy(game_seg + 0xEB60, memory + game + 0xEB60, 4u * 7u);
    memcpy(game_seg + 0xFF00, memory + game + 0xFF00, 0x80);
}

static int inventory_step(void *context, u16 cs, u16 ip) {
    inventory_vm_state_t *state = context;
    u8 *memory = zel_inventory86_memory();
    if (cs == GAME_SEG) {
        state->trace[state->trace_at++ & 15u] = ip;
        const size_t instruction = linear(cs, ip);
        /* 201SELCT posts each UI/item effect as one immediate FF75h write.
         * Capture execution edges so a retained byte cannot repeat a cue. */
        if (memory[instruction] == 0xC6 &&
            memory[instruction + 1] == 0x06 &&
            memory[instruction + 2] == 0x75 &&
            memory[instruction + 3] == 0xFF)
            post_sound_cue(state, memory[instruction + 4]);
    }
    if (cs == GAME_SEG && ip == 0) {
        state->active = 0;
        return 1;
    }
    if (cs == GAME_SEG) {
        const size_t instruction = linear(cs, ip);
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x61) {
            u16 *registers = zel_inventory86_registers();
            /* stick.asm:query_input_state returns direction in AL and the
             * keyboard/joystick action mask (gvar_skip_flag) in AH. */
            registers[ZEL_TINY86_AX] = (u16)(state->direction |
                ((u16)memory[linear(GAME_SEG, 0xFF16)] << 8));
            zel_inventory86_set_ip((u16)(ip + 2u));
            return 1;
        }
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x60) {
            zel_inventory86_set_ip((u16)(ip + 2u));
            return 1;
        }
    }
    if (cs == GAME_SEG && ip == SELCT_POLL_INPUT) {
        if (state->allow_poll_once) {
            state->allow_poll_once = 0;
            state->at_input_poll = 0;
            return 0;
        }
        state->at_input_poll = 1;
        return 1;
    }
    return 0;
}

int zeliard_inventory_masm_vm_start(u8 *game_seg, size_t game_size,
                                    u8 *vga, size_t vga_size,
                                    zeliard_inventory_context_t context) {
    if (!game_seg || game_size < 0x10000 || !vga || vga_size < 0x10000)
        return 0;
    size_t bios_size = 0;
    u8 *bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    if (!bios) return 0;
    memset(&g_inventory_vm, 0, sizeof(g_inventory_vm));
    zel_inventory86_reset(bios, (unsigned)bios_size);
    free(bios);

    u8 *memory = zel_inventory86_memory();
    const size_t game = linear(GAME_SEG, 0);
    const size_t itemp = linear(ITEMP_SEG, 0);
    const size_t asset2 = linear(ASSET_SEG_2, 0);
    normalize_selected_spell(game_seg);
    memcpy(memory + game, game_seg, 0x10000);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);
    size_t font_size = 0;
    if (!load_raw_to(memory, game + 0x0100, "stick.bin") ||
        !load_raw_to(memory, game + 0x2000, "gmmcga.bin") ||
        !load_raw_to(memory, game + SELCT_LOAD_BASE, "select.bin") ||
        !load_fill_to(memory, itemp + 0xE200, "itemp.grp", NULL) ||
        !load_fill_to(memory, asset2 + 0x0000, "magic.grp", NULL) ||
        !load_fill_to(memory, asset2 + 0x1800, "sword.grp", NULL) ||
        !load_fill_to(memory, game + 0xF500, "font.grp", &font_size)) {
        return 0;
    }
    (void)font_size;
    relocate_words(memory, itemp + 0xE200, 7, 0xE200);
    relocate_words(memory, asset2 + 0x1800, 3, 0x1800);
    relocate_words(memory, game + 0xF500, 3, 0xF500);
    /* game.asm loads itemp.grp through ES=CS+1000h.  GMMCGA does not use
     * the selector's DS for these sprites: every item-panel source path
     * switches to the segment stored in gvar_game_seg (FF2C). */
    write_u16(memory, game + 0xFF2C, ITEMP_SEG);

    u16 *registers = zel_inventory86_registers();
    registers[ZEL_TINY86_AX] = 0;
    registers[ZEL_TINY86_CS] = GAME_SEG;
    registers[ZEL_TINY86_DS] = GAME_SEG;
    registers[ZEL_TINY86_ES] = GAME_SEG;
    registers[ZEL_TINY86_SS] = STACK_SEG;
    registers[ZEL_TINY86_SP] = 0xFFF8;
    write_u16(memory, linear(STACK_SEG, 0xFFF8), 0);
    /* 106TOWN enters at A00Bh, the embedded instruction that sets
     * has_items_flag=FFh. 200FIGHT enters at A001h and clears the flag,
     * enabling item use in caverns. */
    zel_inventory86_set_ip(context == ZEL_INVENTORY_CONTEXT_TOWN
                               ? SELCT_TOWN_ENTRY
                               : SELCT_CAVERN_ENTRY);
    zel_inventory86_set_flags(0x0202);
    zel_inventory86_set_step_callback(inventory_step, &g_inventory_vm);
    g_inventory_vm.active = 1;
    /* The first AA6C visit is the initial poll that seeds exit_queued.
     * Execute it and stop at the first steady-state panel poll. */
    g_inventory_vm.allow_poll_once = 1;

    for (unsigned pass = 0; pass < 2000 && g_inventory_vm.active &&
            !g_inventory_vm.at_input_poll; ++pass) {
        ++memory[game + 0xFF1A];
        if (zel_inventory86_run(INSTRUCTIONS_PER_PIT) == ZEL_TINY86_HALTED)
            g_inventory_vm.active = 0;
    }
    if (!g_inventory_vm.at_input_poll) {
        platform_log("201SELCT start stopped at %04X; trace:",
                     zel_inventory86_ip());
        for (unsigned i = 0; i < 16; ++i) {
            const u8 at = (u8)(g_inventory_vm.trace_at + i);
            platform_log(" %04X", g_inventory_vm.trace[at & 15u]);
        }
    }
    sync_game_state_to_host(game_seg, memory, game);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    return g_inventory_vm.active && g_inventory_vm.at_input_poll;
}

int zeliard_inventory_masm_vm_advance(u8 *game_seg, size_t game_size,
                                      u8 *vga, size_t vga_size,
                                      u32 pit_ticks, u8 direction,
                                      u8 space, u8 enter) {
    if (!g_inventory_vm.active || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return 0;
    u8 *memory = zel_inventory86_memory();
    const size_t game = linear(GAME_SEG, 0);
    memcpy(memory + game + 0x02BC, game_seg + 0x02BC, 9);
    memcpy(memory + game + 0x05C1, game_seg + 0x05C1, 5);
    memcpy(memory + game + 0xFF16, game_seg + 0xFF16, 0x14);
    memory[game + 0xFF17] = direction;
    if (space) memory[game + 0xFF1D] = 0xFF;
    if (enter) write_u16(memory, game + 0xFF18,
                         (u16)(read_u16(memory, game + 0xFF18) | 1u));
    g_inventory_vm.direction = direction;
    if (pit_ticks) g_inventory_vm.allow_poll_once = 1;
    for (u32 tick = 0; tick < pit_ticks && g_inventory_vm.active; ++tick) {
        ++memory[game + 0xFF1A];
        write_u16(memory, game + 0xFF1B,
                  (u16)(read_u16(memory, game + 0xFF1B) + 1u));
        if (zel_inventory86_run(INSTRUCTIONS_PER_PIT) == ZEL_TINY86_HALTED) {
            g_inventory_vm.active = 0;
            break;
        }
        if (g_inventory_vm.at_input_poll) break;
    }
    sync_game_state_to_host(game_seg, memory, game);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    return 1;
}

int zeliard_inventory_masm_vm_active(void) { return g_inventory_vm.active; }
int zeliard_inventory_masm_vm_at_input_poll(void) {
    return g_inventory_vm.at_input_poll;
}
u16 zeliard_inventory_masm_vm_ip(void) { return zel_inventory86_ip(); }
u8 zeliard_inventory_masm_vm_peek(u16 offset) {
    return zel_inventory86_memory()[linear(GAME_SEG, offset)];
}
void zeliard_inventory_masm_vm_poke(u16 offset, u8 value) {
    zel_inventory86_memory()[linear(GAME_SEG, offset)] = value;
}
u16 zeliard_inventory_masm_vm_itemp_word(u16 offset) {
    return read_u16(zel_inventory86_memory(), linear(ITEMP_SEG, offset));
}
u8 zeliard_inventory_masm_vm_take_sound_cue(void) {
    if (!g_inventory_vm.sound_cue_count) return 0;
    const u8 cue = g_inventory_vm.sound_cues[g_inventory_vm.sound_cue_read];
    g_inventory_vm.sound_cue_read =
        (u8)((g_inventory_vm.sound_cue_read + 1u) & 15u);
    --g_inventory_vm.sound_cue_count;
    if (!g_inventory_vm.sound_cue_count)
        zel_inventory86_memory()[linear(GAME_SEG, 0xFF75)] = 0;
    return cue;
}
void zeliard_inventory_masm_vm_stop(void) {
    g_inventory_vm.active = 0;
    g_inventory_vm.at_input_poll = 0;
}
