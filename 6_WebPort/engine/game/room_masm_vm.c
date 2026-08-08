#include "room_masm_vm.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../third_party/8086tiny/8086tiny.h"

#include <stdlib.h>
#include <string.h>

/* Private-instance entrypoints emitted by room_8086tiny.c. */
void zel_room86_reset(const unsigned char *bios, unsigned bios_size);
void zel_room86_set_step_callback(zel_tiny86_step_fn callback, void *context);
int zel_room86_run(unsigned max_instructions);
unsigned char *zel_room86_memory(void);
unsigned zel_room86_memory_size(void);
unsigned short *zel_room86_registers(void);
unsigned short zel_room86_ip(void);
void zel_room86_set_ip(unsigned short value);
void zel_room86_set_flags(unsigned short value);

enum {
    GAME_SEG = 0x1000,
    DATA_SEG = 0x2000,
    STACK_SEG = 0x8000,
    VGA_SEG = 0xA000,
    SAR_STUB = 0x0500,
    TOWN_POLL_AFTER_TICK = 0x735D,
    TOWN_TEXT_WAIT_INPUT = 0x71DF,
    TOWN_TEXT_WAIT_REPEAT = 0x71E9,
    TOWN_TEXT_WAIT_AFTER_TICK = 0x71EC,
    BANK_DEPOSIT_AMOUNT_QUERY = 0xA2D8,
    BANK_DEPOSIT_REPEAT_QUERY = 0xA2FE,
    BANK_WITHDRAW_AMOUNT_QUERY = 0xA477,
    BANK_WITHDRAW_REPEAT_QUERY = 0xA49D,
    SAGE_NAME_INPUT_POLL = 0xA592,
    INSTRUCTIONS_PER_PIT = 6000,
};

typedef struct {
    u8 active;
    zeliard_room_kind_t kind;
    u8 at_input_poll;
    u8 input_kind;
    u8 allow_poll_once;
    u8 skip_text_repeat_once;
    u8 direction;
    u8 pending_space;
    u8 pending_enter;
    u8 host_space_latched;
    u8 host_enter_latched;
    u8 host_direction_latched;
    u16 bank_query_yield;
    u8 pending_sound_cue;
    u8 pending_ascii;
    u8 session_exit_requested;
    u8 dos_handle_open;
    u8 dos_write_ok;
    u8 drug_description_backdrop_active;
    u8 drug_description_backdrop[112u * 45u];
    char save_name[13];
    u8 save_record[0x100];
    u8 *graphic;
    size_t graphic_size;
} room_vm_state_t;

static room_vm_state_t g_room_vm;
static u32 g_save_serial;
static char g_save_name[13];
static u8 g_save_record[0x100];
static u8 g_force_save_failure;

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

static u8 *load_asset(const char *name, size_t *size) {
    return platform_load_asset(name, size);
}

static int load_payload_to(u8 *memory, size_t destination,
                           const char *name) {
    size_t size = 0;
    u8 *file = load_asset(name, &size);
    if (!file || size < 4) { free(file); return 0; }
    const u32 payload = (u32)file[0] | ((u32)file[1] << 8) |
        ((u32)file[2] << 16) | ((u32)file[3] << 24);
    if (payload > size - 4 || destination + payload > zel_room86_memory_size()) {
        free(file); return 0;
    }
    memcpy(memory + destination, file + 4, payload);
    free(file);
    return 1;
}

static int load_raw_to(u8 *memory, size_t destination, const char *name) {
    size_t size = 0;
    u8 *file = load_asset(name, &size);
    if (!file || destination + size > zel_room86_memory_size()) {
        free(file); return 0;
    }
    memcpy(memory + destination, file, size);
    free(file);
    return 1;
}

static int load_fill_to(u8 *memory, size_t destination, const char *name) {
    size_t size = 0, output_size = 0;
    u8 *file = load_asset(name, &size);
    u8 *output = file ? fill_buffer_decompress(file, size, &output_size) : NULL;
    free(file);
    if (!output || destination + output_size > zel_room86_memory_size()) {
        free(output);
        return 0;
    }
    memcpy(memory + destination, output, output_size);
    free(output);
    return 1;
}

static void relocate_words(u8 *memory, size_t address, u8 count,
                           u16 addend) {
    for (u8 index = 0; index < count; ++index) {
        const size_t at = address + (size_t)index * 2u;
        write_u16(memory, at, (u16)(read_u16(memory, at) + addend));
    }
}

static int room_step(void *context, u16 cs, u16 ip) {
    room_vm_state_t *state = context;
    u8 *memory = zel_room86_memory();
    if (cs == GAME_SEG && state->kind == ZEL_ROOM_SAGE) {
        const size_t instruction = linear(cs, ip);
        u16 *registers = zel_room86_registers();
        /* 217KENJP A934-A93A is xor ax,ax followed by the only
         * CS:jmp far [FF00] in KENJPRO. Intercept the exact release bytes
         * before 8086tiny transfers control out of the emulated game. */
        if (registers[ZEL_TINY86_AX] == 0 &&
            memory[instruction] == 0x2E &&
            memory[instruction + 1] == 0xFF &&
            memory[instruction + 2] == 0x2E &&
            memory[instruction + 3] == 0x00 &&
            memory[instruction + 4] == 0xFF) {
            state->session_exit_requested = 1;
            state->active = 0;
            return 1;
        }
    }
    if (cs == GAME_SEG && ip == SAR_STUB) {
        u16 *registers = zel_room86_registers();
        const u8 operation = (u8)registers[ZEL_TINY86_AX];
        if (operation == 2) {
            const size_t destination = linear(
                registers[ZEL_TINY86_ES], registers[ZEL_TINY86_DI]);
            if (destination + state->graphic_size <= zel_room86_memory_size())
                memcpy(memory + destination, state->graphic,
                       state->graphic_size);
        } else if (operation == 6) {
            /* stick.asm:scan_savefile_dir builds a count byte, 255 near
             * pointers, then fixed nine-byte base-name records. */
            char names[0xFF][9] = {{0}};
            const size_t count = platform_list_save_names(names, 0xFF);
            /* The loader descriptor at A907 resolves the service output to
             * game_seg:E000; ES:DI are not loader outputs at this callsite. */
            const u16 output_offset = 0xE000;
            const size_t output = linear(GAME_SEG, output_offset);
            if (output + 0xAF6 <= zel_room86_memory_size()) {
                memset(memory + output, 0, 0xAF6);
                memory[output] = (u8)count;
                for (size_t index = 0; index < 0xFF; ++index)
                    write_u16(memory, output + 1 + index * 2,
                              (u16)(output_offset + 0x201 +
                                    index * 9));
                for (size_t index = 0; index < count; ++index)
                    memcpy(memory + output + 0x201 + index * 9,
                           names[index], sizeof(names[index]));
            }
        }
        return 0;
    }
    /* The room chunk is entered by 106TOWN with a near call through A000h.
     * Its final driver tail-return therefore reaches our zero return marker. */
    if (cs == GAME_SEG && ip == 0) {
        state->active = 0;
        return 1;
    }
    if (cs == GAME_SEG && state->kind == ZEL_ROOM_SAGE &&
        ip == SAGE_NAME_INPUT_POLL) {
        if (state->pending_ascii) {
            memory[linear(GAME_SEG, 0xFF29)] = state->pending_ascii;
            state->pending_ascii = 0;
            state->at_input_poll = 0;
            state->input_kind = ZEL_ROOM_VM_INPUT_NONE;
            return 0;
        }
        if ((read_u16(memory, linear(GAME_SEG, 0xFF18)) & 1u) ||
            memory[linear(GAME_SEG, 0xFF1E)]) {
            /* wait_name_input consumes this Enter itself.  Do not replay the
             * host edge into the script's following prompt_yes_no call: the
             * release code requires a fresh choice for "continue your
             * quest?" after the file has been written. */
            state->pending_space = 0;
            state->pending_enter = 0;
            state->allow_poll_once = 0;
            state->at_input_poll = 0;
            state->input_kind = ZEL_ROOM_VM_INPUT_NONE;
            return 0;
        }
        state->at_input_poll = 1;
        state->input_kind = ZEL_ROOM_VM_INPUT_NAME;
        return 1;
    }
    if (cs == GAME_SEG) {
        const size_t instruction = linear(cs, ip);
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x21) {
            u16 *registers = zel_room86_registers();
            const u8 function = (u8)(registers[ZEL_TINY86_AX] >> 8);
            if (function == 0x3C) {
                const size_t source = linear(registers[ZEL_TINY86_DS],
                                             registers[ZEL_TINY86_DX]);
                size_t length = 0;
                while (length + 1 < sizeof(state->save_name) &&
                       source + length < zel_room86_memory_size() &&
                       memory[source + length]) {
                    state->save_name[length] = (char)memory[source + length];
                    ++length;
                }
                state->save_name[length] = '\0';
                state->dos_handle_open = 1;
                state->dos_write_ok = 0;
                registers[ZEL_TINY86_AX] = 5;
                zel_room86_set_flags(0x0202);
            } else if (function == 0x40 && state->dos_handle_open &&
                       registers[ZEL_TINY86_BX] == 5 &&
                       registers[ZEL_TINY86_CX] == 0x100) {
                const size_t source = linear(registers[ZEL_TINY86_DS],
                                             registers[ZEL_TINY86_DX]);
                if (source + sizeof(state->save_record) <=
                    zel_room86_memory_size()) {
                    memcpy(state->save_record, memory + source,
                           sizeof(state->save_record));
                    state->dos_write_ok = (u8)(!g_force_save_failure &&
                        platform_save_record(state->save_name,
                            state->save_record, sizeof(state->save_record)));
                    registers[ZEL_TINY86_AX] = state->dos_write_ok
                        ? 0x100 : 5;
                    zel_room86_set_flags(state->dos_write_ok
                        ? 0x0202 : 0x0203);
                } else {
                    registers[ZEL_TINY86_AX] = 5;
                    zel_room86_set_flags(0x0203);
                }
            } else if (function == 0x3E && state->dos_handle_open &&
                       registers[ZEL_TINY86_BX] == 5) {
                state->dos_handle_open = 0;
                if (state->dos_write_ok) {
                    memcpy(g_save_name, state->save_name,
                           sizeof(g_save_name));
                    memcpy(g_save_record, state->save_record,
                           sizeof(g_save_record));
                    ++g_save_serial;
                }
                registers[ZEL_TINY86_AX] = 0;
                zel_room86_set_flags(0x0202);
            } else {
                registers[ZEL_TINY86_AX] = 1;
                zel_room86_set_flags(0x0203);
            }
            zel_room86_set_ip((u16)(ip + 2u));
            return 1;
        }
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x61) {
            u16 *registers = zel_room86_registers();
            const int bank_amount_query =
                ip == BANK_DEPOSIT_AMOUNT_QUERY ||
                ip == BANK_DEPOSIT_REPEAT_QUERY ||
                ip == BANK_WITHDRAW_AMOUNT_QUERY ||
                ip == BANK_WITHDRAW_REPEAT_QUERY;
            /* stick.asm:query_input_state returns gvar_timer_flag in AL and
             * gvar_skip_flag in AH.  BANKP's amount selector consumes both
             * as held levels: AL drives accelerated repeats and AH bit 0
             * commits the selected deposit/withdraw amount. */
            registers[ZEL_TINY86_AX] = (u16)(
                state->direction | ((u16)memory[linear(GAME_SEG, 0xFF16)] << 8));
            if ((ip == BANK_DEPOSIT_AMOUNT_QUERY ||
                 ip == BANK_WITHDRAW_AMOUNT_QUERY) &&
                (memory[linear(GAME_SEG, 0xFF16)] & 1u)) {
                /* The amount loop consumes this Space make as AH bit 0.
                 * Retire the host one-shot too, otherwise the intercepted
                 * 106TOWN menu poll replays it and immediately re-enters the
                 * same deposit/withdraw selector after the transaction. */
                memory[linear(GAME_SEG, 0xFF1D)] = 0;
                state->pending_space = 0;
                state->allow_poll_once = 0;
            }
            state->bank_query_yield = bank_amount_query ? ip : 0;
            zel_room86_set_ip((u16)(ip + 2u));
            if (state->kind == ZEL_ROOM_SAGE &&
                registers[ZEL_TINY86_AX] == 0)
                return 0;
            return 1;
        }
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x60) {
            /* INT 60h controls the installed music driver. Room effects are
             * instead posted to gvar_volume (FF75h) and consumed by the
             * timer-driven SNDADLIB service. */
            zel_room86_set_ip((u16)(ip + 2u));
            return state->kind == ZEL_ROOM_SAGE ? 0 : 1;
        }
    }
    if (cs == GAME_SEG && ip == TOWN_POLL_AFTER_TICK) {
        if (state->allow_poll_once) {
            state->allow_poll_once = 0;
            state->at_input_poll = 0;
            state->input_kind = ZEL_ROOM_VM_INPUT_NONE;
            const size_t base = linear(GAME_SEG, 0);
            if (state->pending_space) memory[base + 0xFF1D] = 0xFF;
            if (state->pending_enter) memory[base + 0xFF1E] = 0xFF;
            state->pending_space = 0;
            state->pending_enter = 0;
            return 0;
        }
        state->at_input_poll = 1;
        state->input_kind = ZEL_ROOM_VM_INPUT_MENU;
        return 1;
    }
    if (cs == GAME_SEG && ip == TOWN_TEXT_WAIT_INPUT) {
        if (state->allow_poll_once) {
            state->allow_poll_once = 0;
            state->skip_text_repeat_once = 1;
            state->at_input_poll = 0;
            state->input_kind = ZEL_ROOM_VM_INPUT_NONE;
            return 0;
        }
        state->at_input_poll = 1;
        state->input_kind = ZEL_ROOM_VM_INPUT_TEXT;
        return 1;
    }
    if (cs == GAME_SEG && ip == TOWN_TEXT_WAIT_REPEAT) {
        if (state->skip_text_repeat_once) {
            state->skip_text_repeat_once = 0;
            return 0;
        }
        if (state->allow_poll_once) {
            state->allow_poll_once = 0;
            state->at_input_poll = 0;
            state->input_kind = ZEL_ROOM_VM_INPUT_NONE;
            return 0;
        }
        state->at_input_poll = 1;
        state->input_kind = ZEL_ROOM_VM_INPUT_TEXT;
        return 1;
    }
    if (cs == GAME_SEG && ip == TOWN_TEXT_WAIT_AFTER_TICK) {
        const size_t base = linear(GAME_SEG, 0);
        if (state->pending_space) memory[base + 0xFF1D] = 0xFF;
        if (state->pending_enter) memory[base + 0xFF1E] = 0xFF;
        state->pending_space = 0;
        state->pending_enter = 0;
    }
    return 0;
}

static int room_masm_vm_start_impl(zeliard_room_kind_t kind,
                                   const u8 *game_seg, size_t game_size,
                                   const u8 *vga, size_t vga_size,
                                   int death_sage) {
    const char *program = kind == ZEL_ROOM_ARMORY ? "armrpro.bin" :
                          kind == ZEL_ROOM_DRUGSTORE ? "drugpro.bin" :
                          kind == ZEL_ROOM_CHURCH ? "churpro.bin" :
                          kind == ZEL_ROOM_BANK ? "bankpro.bin" :
                          kind == ZEL_ROOM_INN ? "innapro.bin" :
                          kind == ZEL_ROOM_SAGE ? "kenjpro.bin" : NULL;
    const char *graphic = kind == ZEL_ROOM_ARMORY ? "armr.grp" :
                          kind == ZEL_ROOM_DRUGSTORE ? "drug.grp" :
                          kind == ZEL_ROOM_CHURCH ? "church.grp" :
                          kind == ZEL_ROOM_BANK ? "bank.grp" :
                          kind == ZEL_ROOM_INN ? "inn.grp" :
                          kind == ZEL_ROOM_SAGE ? "kenja.grp" : NULL;
    if (!program || !graphic || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return 0;

    size_t bios_size = 0, graphic_file_size = 0, font_file_size = 0;
    u8 *bios = load_asset("8086tiny-bios.bin", &bios_size);
    u8 *graphic_file = load_asset(graphic, &graphic_file_size);
    u8 *font_file = load_asset("font.grp", &font_file_size);
    size_t decoded_size = 0, font_size = 0;
    u8 *decoded = graphic_file ? fill_buffer_decompress(
        graphic_file, graphic_file_size, &decoded_size) : NULL;
    u8 *font = font_file ? fill_buffer_decompress(
        font_file, font_file_size, &font_size) : NULL;
    free(graphic_file);
    free(font_file);
    if (!bios || !decoded || !font) {
        free(bios); free(decoded); free(font); return 0;
    }

    free(g_room_vm.graphic);
    memset(&g_room_vm, 0, sizeof(g_room_vm));
    g_room_vm.graphic = decoded;
    g_room_vm.graphic_size = decoded_size;
    g_room_vm.kind = kind;
    zel_room86_reset(bios, (unsigned)bios_size);
    free(bios);
    u8 *memory = zel_room86_memory();
    const size_t base = linear(GAME_SEG, 0);
    memcpy(memory + base, game_seg, 0x10000);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);
    if (!load_raw_to(memory, base + 0x0100, "stick.bin") ||
        !load_raw_to(memory, base + 0x2000, "gmmcga.bin") ||
        !load_payload_to(memory, base + 0x3000, "gtmcga.bin") ||
        !load_payload_to(memory, base + 0x6000, "town.bin") ||
        !load_payload_to(memory, base + 0xA000, program) ||
        !load_fill_to(memory, linear(DATA_SEG, 0xE200), "itemp.grp") ||
        base + 0xF500 + font_size > zel_room86_memory_size()) {
        free(font); return 0;
    }
    /* game.asm loads itemp.grp at (CS+1000h):E200h and relocates its seven
     * GMMCGA source pointers before any room program can draw equipment. */
    relocate_words(memory, linear(DATA_SEG, 0xE200), 7, 0xE200);
    memcpy(memory + base + 0xF500, font, font_size);
    free(font);
    for (u16 offset = 0; offset < 6; offset += 2) {
        const u16 pointer = read_u16(memory, base + 0xF500 + offset);
        write_u16(memory, base + 0xF500 + offset,
                  (u16)(pointer + 0xF500));
    }
    write_u16(memory, base + 0x010C, SAR_STUB);
    write_u16(memory, base + 0xFF2C, DATA_SEG);
    memory[base + SAR_STUB] = 0xC3;

    u16 *registers = zel_room86_registers();
    registers[ZEL_TINY86_AX] = kind == ZEL_ROOM_SAGE ? 0 : 1;
    registers[ZEL_TINY86_CS] = GAME_SEG;
    registers[ZEL_TINY86_DS] = GAME_SEG;
    registers[ZEL_TINY86_ES] = DATA_SEG;
    registers[ZEL_TINY86_SS] = STACK_SEG;
    registers[ZEL_TINY86_SP] = 0xFFF8;
    write_u16(memory, linear(STACK_SEG, 0xFFF8), 0);
    write_u16(memory, linear(STACK_SEG, 0xFFFA), 0);
    zel_room86_set_ip(kind == ZEL_ROOM_SAGE
        ? (death_sage ? 0xA006 : 0xA027) : 0xA000);
    zel_room86_set_flags(0x0202);
    zel_room86_set_step_callback(room_step, &g_room_vm);
    g_room_vm.active = 1;
    return 1;
}

static void copy_frame_rect(u8 *destination, const u8 *source,
                            u16 x, u16 y, u16 width, u16 height) {
    for (u16 row = 0; row < height; ++row)
        memcpy(destination + (size_t)row * width,
               source + (size_t)(y + row) * 320u + x, width);
}

static void restore_frame_rect(u8 *destination, const u8 *source,
                               u16 x, u16 y, u16 width, u16 height) {
    for (u16 row = 0; row < height; ++row)
        memcpy(destination + (size_t)(y + row) * 320u + x,
               source + (size_t)row * width, width);
}

int zeliard_room_masm_vm_start(zeliard_room_kind_t kind,
                               const u8 *game_seg, size_t game_size,
                               const u8 *vga, size_t vga_size) {
    return room_masm_vm_start_impl(
        kind, game_seg, game_size, vga, vga_size, 0);
}

int zeliard_room_masm_vm_start_death_sage(
        const u8 *game_seg, size_t game_size,
        const u8 *vga, size_t vga_size) {
    return room_masm_vm_start_impl(
        ZEL_ROOM_SAGE, game_seg, game_size, vga, vga_size, 1);
}

int zeliard_room_masm_vm_advance(u8 *game_seg, size_t game_size,
                                 u8 *vga, size_t vga_size,
                                 u32 pit_ticks, u8 direction,
                                 u8 space, u8 enter) {
    if (!g_room_vm.active || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return 0;
    u8 *memory = zel_room86_memory();
    const size_t base = linear(GAME_SEG, 0);
    /* Browser input owns the stick.asm timer latches and raw key masks.
     * Keep those host-updated bytes in the exact room VM's shared segment. */
    memcpy(memory + base + 0x02BC, game_seg + 0x02BC, 9);
    memcpy(memory + base + 0x05C1, game_seg + 0x05C1, 5);
    memcpy(memory + base + 0xFF16, game_seg + 0xFF16, 4);
    memory[base + 0xFF17] = direction;
    g_room_vm.direction = direction;
    /* FF16 bit 0 and FF18 bit 0 are stick.asm's physical key masks; FF1D
     * and FF29 are sampled action latches. Reset edge ownership on raw
     * key-up, not when a room proc happens to clear an action byte. */
    const u8 raw_input_active = (u8)(game_seg[0x02BC] != 0);
    const u8 raw_space_down = raw_input_active
        ? (u8)(game_seg[0xFF16] & 1u) : (u8)(space != 0);
    /* stick.asm presents Enter and Alt/button-B through different raw
     * masks, but both become 106TOWN's secondary FF1E menu action. */
    const u8 raw_enter_down = raw_input_active
        ? (u8)((read_u16(game_seg, 0xFF18) & 1u) |
               (game_seg[0xFF16] & 2u))
        : (u8)(enter != 0);
    if (!raw_space_down) g_room_vm.host_space_latched = 0;
    if (!raw_enter_down) g_room_vm.host_enter_latched = 0;
    if (!direction) g_room_vm.host_direction_latched = 0;
    const u8 space_edge = (u8)(space && raw_space_down &&
                               !g_room_vm.host_space_latched);
    const u8 enter_edge = (u8)(enter && raw_enter_down &&
                               !g_room_vm.host_enter_latched);
    const u8 direction_edge = (u8)(direction &&
                                   !g_room_vm.host_direction_latched);
    if (space_edge) g_room_vm.host_space_latched = 1;
    if (enter_edge) g_room_vm.host_enter_latched = 1;
    if (direction_edge) g_room_vm.host_direction_latched = 1;
    if (space_edge) memory[base + 0xFF1D] = 0xFF;
    if (enter_edge) memory[base + 0xFF29] = 0x0D;
    if (space_edge) g_room_vm.pending_space = 1;
    if (enter_edge) g_room_vm.pending_enter = 1;
    if (direction_edge || space_edge || enter_edge)
        g_room_vm.allow_poll_once = 1;
    for (u32 tick = 0; tick < pit_ticks; ++tick) {
        const u8 sound_cue = memory[base + 0xFF75];
        if (sound_cue) {
            g_room_vm.pending_sound_cue = sound_cue;
            memory[base + 0xFF75] = 0;
        }
        ++memory[base + 0xFF1A];
        write_u16(memory, base + 0xFF1B,
                  (u16)(read_u16(memory, base + 0xFF1B) + 1u));
        write_u16(memory, base + 0xFF50,
                  (u16)(read_u16(memory, base + 0xFF50) + 1u));
        const u32 amount_before =
            ((u32)memory[base + 0xAD29] << 16) |
            read_u16(memory, base + 0xAD2A);
        u16 previous_repeat_query = 0;
        for (unsigned slice = 0; slice < 8; ++slice) {
            g_room_vm.bank_query_yield = 0;
            const int result = zel_room86_run(INSTRUCTIONS_PER_PIT);
            if (result == ZEL_TINY86_HALTED) {
                g_room_vm.active = 0;
                break;
            }
            const u16 query = g_room_vm.bank_query_yield;
            const int repeat_query =
                query == BANK_DEPOSIT_REPEAT_QUERY ||
                query == BANK_WITHDRAW_REPEAT_QUERY;
            const u32 amount_after =
                ((u32)memory[base + 0xAD29] << 16) |
                read_u16(memory, base + 0xAD2A);
            if (!direction || !query ||
                (repeat_query && amount_after != amount_before) ||
                (repeat_query && previous_repeat_query == query)) break;
            previous_repeat_query = repeat_query ? query : 0;
        }
        if (!g_room_vm.active) break;
        if (g_room_vm.at_input_poll) break;
    }
    if (g_room_vm.kind == ZEL_ROOM_DRUGSTORE) {
        u8 *frame = memory + linear(VGA_SEG, 0);
        const u16 script_ip = read_u16(memory, base + 0xFF4C);
        /* 215DRUGP's description loop leaves the top-level shop menu as the
         * visual backdrop while AB0F asks whether another item is wanted.
         * Preserve that authored rectangle across the subsequent AACA item
         * selector and description.  The inner-box clear at loc_23 otherwise
         * becomes visible in the linear host framebuffer, although DOS keeps
         * the already-presented menu until the loop returns to A88C. */
        if (g_room_vm.at_input_poll && script_ip == 0xAB0F) {
            copy_frame_rect(g_room_vm.drug_description_backdrop, frame,
                            156, 34, 112, 45);
            g_room_vm.drug_description_backdrop_active = 1;
        } else if (g_room_vm.at_input_poll && script_ip == 0xA88C) {
            g_room_vm.drug_description_backdrop_active = 0;
        }
        if (g_room_vm.drug_description_backdrop_active)
            restore_frame_rect(frame, g_room_vm.drug_description_backdrop,
                               156, 34, 112, 45);
    }
    memcpy(game_seg, memory + base, 0x10000);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    return 1;
}

u16 zeliard_room_masm_vm_ip(void) { return zel_room86_ip(); }
int zeliard_room_masm_vm_at_input_poll(void) {
    return g_room_vm.at_input_poll;
}
int zeliard_room_masm_vm_input_kind(void) { return g_room_vm.input_kind; }
int zeliard_room_masm_vm_active(void) { return g_room_vm.active; }
int zeliard_room_masm_vm_session_exit_requested(void) {
    return g_room_vm.session_exit_requested;
}
u8 zeliard_room_masm_vm_take_sound_cue(void) {
    const u8 cue = g_room_vm.pending_sound_cue;
    g_room_vm.pending_sound_cue = 0;
    return cue;
}
void zeliard_room_masm_vm_text_key(u8 ascii) {
    if (g_room_vm.active) g_room_vm.pending_ascii = ascii;
}
u32 zeliard_room_masm_vm_save_serial(void) { return g_save_serial; }
const char *zeliard_room_masm_vm_save_name(void) { return g_save_name; }
const u8 *zeliard_room_masm_vm_save_record(void) { return g_save_record; }
void zeliard_room_masm_vm_force_save_failure(int fail) {
    g_force_save_failure = (u8)(fail != 0);
}
void zeliard_room_masm_vm_stop(void) {
    g_room_vm.active = 0;
    g_room_vm.at_input_poll = 0;
    g_room_vm.input_kind = ZEL_ROOM_VM_INPUT_NONE;
    free(g_room_vm.graphic);
    g_room_vm.graphic = NULL;
    g_room_vm.graphic_size = 0;
}
