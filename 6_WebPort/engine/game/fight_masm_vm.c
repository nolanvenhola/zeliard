#include "fight_masm_vm.h"

#include "../load/fill_buffer.h"
#include "../platform/platform.h"
#include "../render/palette.h"
#include "../third_party/8086tiny/8086tiny.h"

#include <stdlib.h>
#include <string.h>

void zel_fight86_reset(const unsigned char *bios, unsigned bios_size);
void zel_fight86_set_step_callback(zel_tiny86_step_fn callback, void *context);
void zel_fight86_set_out_callback(zel_tiny86_out_fn callback, void *context);
int zel_fight86_run(unsigned max_instructions);
unsigned char *zel_fight86_memory(void);
unsigned zel_fight86_memory_size(void);
unsigned short *zel_fight86_registers(void);
unsigned short zel_fight86_ip(void);
void zel_fight86_set_ip(unsigned short value);
void zel_fight86_set_flags(unsigned short value);

enum {
    FIGHT_SEG = 0x1000,
    GAME_SEG = 0x2000,
    ASSET_SEG = 0x3000,
    VGA_SEG = 0xA000,
    SAR_STUB = 0x0500,
    FIGHT_LOAD_BASE = 0x6000,
    PLAYER_AREA_SELECTOR = 0x00C4,
    MAO2_APPEAR_GATE = 0xFF21,
    CINEMATIC_ACTIVE = 0xFF77,
    JASHIIN_FINAL_SELECTOR = 0x1E,
    FIGHT_TOWN_ENTRY = 0x79DC,
    STICK_SUBSAMPLE_ACCUMULATOR = 0x092B,
    INSTRUCTIONS_PER_SLICE = 50000,
};

typedef struct {
    u8 active;
    zeliard_fight_vm_error_t last_error;
    u8 at_frame;
    u8 allow_frame_once;
    u8 direction;
    u8 palette_index;
    u8 palette_component;
    u8 exit_operation;
    u8 exit_selector;
    u8 exit_scroll_dir;
    u8 exit_player_y;
    u8 music_chunk;
    u8 ending_mode;
    u8 ending_finished;
    u8 ending_at_wait;
    u8 ending_allow_wait_once;
    u8 ending_driver_init;
    u8 ending_driver_ready;
    u8 ending_present_pending;
    u8 ending_host_action_latched;
    u8 ending_graphics_in_progress;
    u8 bootstrap_clock;
    u8 authored_wait_sequence;
    u16 exit_dispatch_slot;
    u16 exit_scroll_count;
    u16 ending_graphics_return_ip;
    u32 instructions;
    u32 frame_pit_ticks;
    u16 trace[32];
    u8 trace_at;
    u8 sound_cues[32];
    u8 sound_cue_read;
    u8 sound_cue_write;
    u8 sound_cue_count;
} fight_vm_state_t;

static fight_vm_state_t g_fight_vm;
static u8 g_debug_invincible;
static u8 g_debug_no_gravity;
static size_t linear(u16 segment, u16 offset);

enum {
    /* SAR loading strips the four-byte chunk header, so binary offset N is
     * resident at FIGHT_LOAD_BASE - 4 + N. */
    DEBUG_GRAVITY_BRANCH = 0x6970,
    DEBUG_DAMAGE_ENTRY = 0x7685,
};

static void apply_debug_patches(void) {
    static const u8 gravity_original[] = { 0xE8, 0x03, 0x02, 0x73, 0x03 };
    static const u8 gravity_disabled[] = { 0xE9, 0xCE, 0x01, 0x90, 0x90 };
    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);

    /* MASM 200FIGHT:combat_step_advance calls check_3tile_clearance at
     * release offset 0974h. Flight jumps directly to check_combat_7f,
     * bypassing only the authored downward fall path. */
    memcpy(memory + fight + DEBUG_GRAVITY_BRANCH,
           g_debug_no_gravity ? gravity_disabled : gravity_original,
           sizeof(gravity_original));
    /* Every cavern damage path converges at subtract_from_player_HP,
     * release offset 1689h. RET preserves hit animation/audio while making
     * the player immune to the HP subtraction itself. */
    memory[fight + DEBUG_DAMAGE_ENTRY] =
        g_debug_invincible ? 0xC3 : 0x29;
}

static void post_sound_cue(fight_vm_state_t *state, u8 cue) {
    if (!cue) return;
    if (state->sound_cue_count == sizeof(state->sound_cues)) {
        /* Preserve the newest executed event if an unusually long host slice
         * outruns audio consumption. */
        state->sound_cue_read = (u8)((state->sound_cue_read + 1u) & 31u);
        --state->sound_cue_count;
    }
    state->sound_cues[state->sound_cue_write] = cue;
    state->sound_cue_write = (u8)((state->sound_cue_write + 1u) & 31u);
    ++state->sound_cue_count;
}

static size_t linear(u16 segment, u16 offset) {
    return (size_t)segment * 16u + offset;
}

static void write_u16(u8 *memory, size_t address, u16 value) {
    memory[address] = (u8)value;
    memory[address + 1] = (u8)(value >> 8);
}

static u16 read_u16(const u8 *memory, size_t address) {
    return (u16)(memory[address] | ((u16)memory[address + 1] << 8));
}

static int ending_graphics_dispatch(const u8 *memory, size_t instruction) {
    if (memory[instruction] != 0x2E || memory[instruction + 1] != 0xFF ||
        (memory[instruction + 2] != 0x16 &&
         memory[instruction + 2] != 0x26))
        return 0;

    const u16 slot = read_u16(memory, instruction + 3);
    switch (slot) {
        case 0x3004: /* gfx_draw_fn */
        case 0x3006: /* gfx_update_fn */
        case 0x3008: /* gfx_palette_fn */
        case 0x3010: /* gfx_blit_fn */
        case 0x3020: /* gfx_scene_fn1 */
        case 0x3022: /* gfx_scene_fn2 */
        case 0x3024: /* gfx_scene_fn3 */
        case 0x3028: /* gfx_sprite_fn */
        case 0x302A: /* drv2_fn_21 */
        case 0x302C: /* drv2_fn_22 */
        case 0x302E: /* gfx_scroll_jmp */
        case 0x3030: /* gfx_putchar_fn */
        case 0x8584: /* full_scroll_fn_ptr */
            return 1;
        default:
            return 0;
    }
}

static void relocate_words(u8 *memory, size_t address, unsigned count,
                           u16 addend) {
    for (unsigned i = 0; i < count; ++i) {
        const size_t at = address + i * 2u;
        write_u16(memory, at, (u16)(read_u16(memory, at) + addend));
    }
}

static int prepare_sword_graphics(u8 *memory, u8 sword) {
    static const u16 source_slots[] = {
        0x1800, 0x1800, 0x1800, 0x1800, 0x1802, 0x1802, 0x1804,
    };
    if (sword >= sizeof(source_slots) / sizeof(source_slots[0])) return 0;

    /* stick.asm:fn4_load_sword_graphics selects one of sword.grp's three
     * banks, copies 0x1000 words from CS+2000h into game_seg:B000h, then
     * relocates the fifteen reachability-table pointers at B002h. */
    const size_t slot = linear(ASSET_SEG, source_slots[sword]);
    const u16 source = read_u16(memory, slot);
    const size_t destination = linear(GAME_SEG, 0xB000);
    memcpy(memory + destination, memory + linear(ASSET_SEG, source), 0x2000);
    relocate_words(memory, destination, 15, 0xB000);
    return 1;
}

static int load_payload_to(u8 *memory, size_t destination,
                           const char *name) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    if (!file || size < 4) { free(file); return 0; }
    const u32 payload = (u32)file[0] | ((u32)file[1] << 8) |
        ((u32)file[2] << 16) | ((u32)file[3] << 24);
    if (payload > size - 4 || destination + payload >
            zel_fight86_memory_size()) {
        free(file);
        return 0;
    }
    memcpy(memory + destination, file + 4, payload);
    free(file);
    return 1;
}

static int load_raw_to(u8 *memory, size_t destination, const char *name) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    if (!file || destination + size > zel_fight86_memory_size()) {
        free(file);
        return 0;
    }
    memcpy(memory + destination, file, size);
    free(file);
    return 1;
}

typedef struct {
    u8 archive;
    u8 chunk;
    const char *asset;
} fight_asset_ref_t;

static const fight_asset_ref_t FIGHT_ASSETS[] = {
    {1, 30, "mman.grp"},
    /* ROKADEMO.BIN: the release boss-victory overlay.  200FIGHT loads it
     * after the boss death FSM completes; it renders the raised-sword pose
     * and carries the recovered crystal into the HUD. */
    {2, 1, "rokad.bin"},
    {2, 2, "eai1.bin"},
    {2, 3, "eai2.bin"},
    {2, 4, "eai3.bin"},
    {2, 5, "eai4.bin"},
    {2, 6, "eai5.bin"},
    {2, 7, "eai6.bin"},
    {2, 8, "eai7.bin"},
    {2, 9, "eai8.bin"},
    {2, 10, "crab.bin"},
    {2, 11, "tako.bin"},
    {2, 12, "tori.bin"},
    {2, 13, "zela.bin"},
    {2, 14, "meda.bin"},
    {2, 15, "lega.bin"},
    {2, 16, "zel2.bin"},
    {2, 17, "drgn.bin"},
    {2, 18, "akma.bin"},
    {2, 19, "mao1.bin"},
    {2, 20, "mao2.bin"},
    {2, 21, "mp10.mdt"},
    {2, 52, "fman.grp"},
    {2, 53, "roka.grp"},
    {2, 54, "dman.grp"},
    {2, 55, "dchr.grp"},
    {2, 56, "encnt.grp"},
    {2, 57, "enp1.grp"},
    {2, 58, "enp2.grp"},
    {2, 59, "enp3.grp"},
    {2, 60, "enp4.grp"},
    {2, 61, "enp5.grp"},
    {2, 62, "enp6.grp"},
    {2, 63, "enp7.grp"},
    {2, 64, "enp8.grp"},
    {2, 65, "crab.grp"},
    {2, 66, "tako.grp"},
    {2, 67, "tori.grp"},
    {2, 68, "zela.grp"},
    {2, 69, "meda.grp"},
    {2, 70, "lega.grp"},
    {2, 71, "drgn.grp"},
    {2, 72, "akma.grp"},
    {2, 73, "mao1.grp"},
    {2, 74, "mao2.grp"},
    {2, 75, "mpp1.grp"},
    {2, 76, "mpp2.grp"},
    {2, 77, "mpp3.grp"},
    {2, 78, "mpp4.grp"},
    {2, 79, "mpp5.grp"},
    {2, 80, "mpp6.grp"},
    {2, 81, "mpp7.grp"},
    {2, 82, "mpp8.grp"},
    {2, 83, "mpp9.grp"},
    {2, 84, "mppa.grp"},
    {2, 85, "mppb.grp"},
    {2, 86, "mus1.msd"},
    {2, 87, "mus2.msd"},
    {2, 88, "mus3.msd"},
    {2, 89, "mus4.msd"},
    {2, 90, "mus5.msd"},
    {2, 91, "mus6.msd"},
    {2, 92, "mus7.msd"},
    {2, 93, "mus8.msd"},
    {2, 94, "mbos.msd"},
    {2, 95, "mfan.msd"},
    {2, 96, "mmao.msd"},
};

static const char *asset_for_ref(u8 archive, u8 chunk) {
    for (size_t i = 0; i < sizeof(FIGHT_ASSETS) / sizeof(FIGHT_ASSETS[0]); ++i)
        if (FIGHT_ASSETS[i].archive == archive &&
            FIGHT_ASSETS[i].chunk == chunk)
            return FIGHT_ASSETS[i].asset;
    return NULL;
}

static const char *ending_asset_for_ref(u8 archive, u8 chunk) {
    if (archive == 0) {
        switch (chunk) {
            case 0x11: return "himp.grp";
            case 0x15: return "ne80.grp";
            case 0x16: return "ne81.grp";
            case 0x18: return "new1.grp";
            case 0x19: return "new2.grp";
            case 0x1C: return "sei.grp";
            case 0x1D: return "seip.grp";
            case 0x21: return "waku.grp";
            case 0x26: return "yuup.grp";
            case 0x27: return "zend.msd";
            default: return NULL;
        }
    }
    if (archive == 1) {
        switch (chunk) {
            case 0x34: return "en72.grp";
            case 0x35: return "end4.grp";
            case 0x36: return "end5.grp";
            case 0x37: return "end6.grp";
            case 0x38: return "end7.grp";
            case 0x39: return "final.grp";
            default: return NULL;
        }
    }
    return NULL;
}

static int ending_poll_instruction(const u8 *memory, size_t instruction) {
    /* Both 250ENDMO and 105GDMCA busy-wait on the shared ISR counters.
     * Yield at the compare/test instruction itself, independent of which
     * scene/driver helper owns the loop. */
    return (memory[instruction] == 0x2E &&
            ((memory[instruction + 1] == 0x80 &&
              memory[instruction + 2] == 0x3E &&
              memory[instruction + 3] == 0x1A &&
              memory[instruction + 4] == 0xFF) ||
             (memory[instruction + 1] == 0x3A &&
              memory[instruction + 2] == 0x06 &&
              memory[instruction + 3] == 0x1A &&
              memory[instruction + 4] == 0xFF))) ||
           (memory[instruction] == 0x3B &&
            memory[instruction + 1] == 0x06 &&
            memory[instruction + 2] == 0x50 &&
            memory[instruction + 3] == 0xFF) ||
           (memory[instruction] == 0xF6 &&
            memory[instruction + 1] == 0x06 &&
            memory[instruction + 2] == 0x21 &&
            memory[instruction + 3] == 0xFF);
}

static const char *map_for_selector(u8 selector) {
    return zeliard_cavern_map_asset(selector);
}

static int load_fill_to(u8 *memory, size_t destination, const char *name) {
    size_t size = 0, output_size = 0;
    u8 *file = platform_load_asset(name, &size);
    u8 *output = file ? fill_buffer_decompress(file, size, &output_size) : NULL;
    free(file);
    if (!output || destination + output_size > zel_fight86_memory_size()) {
        free(output);
        return 0;
    }
    memcpy(memory + destination, output, output_size);
    free(output);
    return 1;
}

static int asset_available(const char *name) {
    size_t size = 0;
    u8 *file = platform_load_asset(name, &size);
    const int available = file != NULL && size >= 4;
    free(file);
    return available;
}

static int fight_step(void *context, u16 cs, u16 ip) {
    fight_vm_state_t *state = context;
    u8 *memory = zel_fight86_memory();
    u16 *registers = zel_fight86_registers();
    if (cs == FIGHT_SEG) {
        state->trace[state->trace_at++ & 31u] = ip;
        ++state->instructions;
        if (state->ending_driver_init && ip == 0x0502) {
            state->ending_driver_ready = 1;
            /* Return from the exact 211OMOYP `call cs:[3006h]`. ENDDEMO is
             * already resident, so assert FF77h and perform its authored
             * indirect jump as soon as the GDMCGA full-screen pass returns. */
            if (state->ending_mode) {
                const size_t fight = linear(FIGHT_SEG, 0);
                registers[ZEL_TINY86_AX] = 0;
                registers[ZEL_TINY86_CS] = FIGHT_SEG;
                registers[ZEL_TINY86_DS] = FIGHT_SEG;
                registers[ZEL_TINY86_ES] = FIGHT_SEG;
                registers[ZEL_TINY86_SS] = FIGHT_SEG;
                registers[ZEL_TINY86_SP] = 0x2000;
                memory[fight + CINEMATIC_ACTIVE] = 0xFF;
                zel_fight86_set_ip(read_u16(
                    memory, fight + FIGHT_LOAD_BASE));
                zel_fight86_set_flags(0x0202);
                state->ending_driver_init = 0;
                state->ending_at_wait = 0;
                state->ending_allow_wait_once = 1;
            }
            return 1;
        }
        const size_t instruction = linear(cs, ip);
        /* All 200FIGHT sound posts use `mov byte ptr [FF75h],imm8`.
         * Observe execution of that instruction, not the duration for which
         * the byte remains nonzero. A spike pit repeats because it executes
         * the damage path repeatedly; a single hit executes it once. */
        size_t opcode = instruction;
        if (memory[opcode] == 0x26 || memory[opcode] == 0x2E ||
            memory[opcode] == 0x36 || memory[opcode] == 0x3E)
            ++opcode;
        if (memory[opcode] == 0xC6 &&
            memory[opcode + 1] == 0x06 &&
            memory[opcode + 2] == 0x75 &&
            memory[opcode + 3] == 0xFF)
            post_sound_cue(state, memory[opcode + 4]);
        if (state->bootstrap_clock &&
            (state->instructions & 0x7FFu) == 0) {
            ++memory[linear(FIGHT_SEG, 0xFF1A)];
            write_u16(memory, linear(FIGHT_SEG, 0xFF1B),
                      (u16)(memory[linear(FIGHT_SEG, 0xFF1B)] |
                            ((u16)memory[linear(FIGHT_SEG, 0xFF1C)] << 8)) + 1u);
        }
    }
    if (cs == FIGHT_SEG && state->ending_mode) {
        const size_t instruction = linear(cs, ip);
        /* 250ENDMO changes the private VGA page through several GMMCGA
         * dispatch slots.  Those draws often occur after the timer poll and
         * before the next one, so ending_at_wait alone leaves the browser on
         * the preceding credit page (including immediately before FIN).
         * Publish every authored graphics dispatch, both CALL and JMP, once
         * its driver routine has returned.  Some full-screen blits exceed a
         * host CPU slice; publishing at call entry exposes a half-drawn page. */
        if (state->ending_graphics_in_progress &&
            ip == state->ending_graphics_return_ip) {
            state->ending_present_pending = 1;
            state->ending_graphics_in_progress = 0;
        }
        if (ending_graphics_dispatch(memory, instruction)) {
            state->ending_graphics_in_progress = 1;
            if (memory[instruction + 2] == 0x16) {
                state->ending_graphics_return_ip = (u16)(ip + 5u);
            } else {
                /* gfx_scroll_jmp is a tail call.  Its eventual RET consumes
                 * the caller's already-present return address at SS:SP. */
                state->ending_graphics_return_ip = read_u16(
                    memory, linear(registers[10], registers[4]));
            }
        }
        if (ip == 0x66C8 || ip == 0x66CB || ip == 0x66CC) {
            state->ending_finished = 1;
            state->ending_at_wait = 1;
            return 1;
        }
        if (ending_poll_instruction(memory, instruction)) {
            if (state->ending_allow_wait_once) {
                state->ending_allow_wait_once = 0;
                state->ending_at_wait = 0;
            } else {
                state->ending_at_wait = 1;
                return 1;
            }
        }
    }
    if (cs == FIGHT_SEG && !state->ending_mode && ip == 0x629C) {
        state->authored_wait_sequence = 0;
        if (state->allow_frame_once) {
            state->allow_frame_once = 0;
            state->at_frame = 0;
        } else {
            state->at_frame = 1;
            return 1;
        }
    }
    /* 200FIGHT:7F82 wait_anim_cycle is the display boundary used by the
     * 26-step boss-room entrance.  The DOS game completes the planar
     * ENCOUNTER! blit before waiting here.  Yielding on an arbitrary CPU
     * slice exposes a half-assembled graphic in the browser. */
    if (cs == FIGHT_SEG && ip == 0x7F82 && state->authored_wait_sequence) {
        if (state->allow_frame_once) {
            state->allow_frame_once = 0;
            state->at_frame = 0;
        } else {
            state->at_frame = 1;
            return 1;
        }
    }
    if (cs == FIGHT_SEG && ip == SAR_STUB) {
        const u16 si = registers[ZEL_TINY86_SI];
        const size_t ref = linear(registers[ZEL_TINY86_DS], si);
        const u8 operation = (u8)registers[ZEL_TINY86_AX];
        const u8 selector = (u8)(registers[ZEL_TINY86_AX] >> 8);
        const u8 archive = memory[ref];
        const u8 chunk = memory[ref + 1];
        const char *asset = state->ending_mode
                          ? ending_asset_for_ref(archive, chunk)
                          : operation == 1 ? map_for_selector(selector)
                          : operation == 4 ? "sword.grp:selected-bank"
                                           : asset_for_ref(archive, chunk);
        int loaded = 0;
        if (operation == 0) {
            const u16 dispatch_slot = registers[ZEL_TINY86_BX];
            const u16 target = read_u16(
                memory, linear(FIGHT_SEG, dispatch_slot));
            platform_log("200FIGHT dispatch: BX=%04X target=%04X",
                         dispatch_slot, target);
            /* BX=6002 is the death return through the swapped town overlay.
             * BX=6000 is fight.bin's internal level-start continuation and
             * remains resident in this private VM. */
            if (dispatch_slot == 0x6000 && target >= FIGHT_LOAD_BASE) {
                registers[ZEL_TINY86_CS] = FIGHT_SEG;
                registers[ZEL_TINY86_DS] = FIGHT_SEG;
                registers[ZEL_TINY86_ES] = FIGHT_SEG;
                zel_fight86_set_ip(target);
                return 1;
            }
            state->exit_operation = operation;
            state->exit_selector = selector;
            state->exit_dispatch_slot = dispatch_slot;
            state->active = 0;
            return 1;
        } else if (operation == 1 && !asset) {
            state->exit_operation = operation;
            state->exit_selector = selector;
            /* boss_check has already copied the selected door's arrival
             * coordinates into 9F1Ah/9F1Ch. The town MDT loader normally
             * returns and compute_scroll_pos consumes them; the host VM
             * yields at this loader boundary, so retain that handoff. */
            state->exit_scroll_count = read_u16(
                memory, linear(FIGHT_SEG, 0x9F1A));
            state->exit_scroll_dir = memory[linear(FIGHT_SEG, 0x9F1C)];
            state->exit_player_y = memory[linear(FIGHT_SEG, 0xC016)];
            state->active = 0;
            return 1;
        } else if (operation == 4) {
            loaded = prepare_sword_graphics(memory, selector);
        } else if (operation == 5 && asset) {
            /* stick.asm's AL=5 path hands the MSD chunk to the resident sound
             * driver. It does not copy the raw music payload to ES:DI. Doing
             * so here overwrote the tail of the 4000h enemy sprite bank when
             * a track exceeded 1000h bytes (MUS6 reaches 45B5h). */
            loaded = asset_available(asset);
            if (loaded) state->music_chunk = chunk;
        } else if (asset) {
            const size_t destination = operation == 1
                ? linear(FIGHT_SEG, 0xC000)
                : linear(registers[ZEL_TINY86_ES], registers[ZEL_TINY86_DI]);
            loaded = operation == 2
                ? load_fill_to(memory, destination, asset)
                : load_payload_to(memory, destination, asset);
            if (loaded && operation == 2 && archive == 2 && chunk == 56)
                state->authored_wait_sequence = 1;
            if (loaded && operation == 1 &&
                selector == JASHIIN_FINAL_SELECTOR) {
                /* MP90's release script loads MPA0 directly, without
                 * returning through the host selector. Preserve that live
                 * handoff in the player record so saves and the final-ending
                 * detector both see the active MAO2 arena. */
                memory[linear(FIGHT_SEG, PLAYER_AREA_SELECTOR)] = selector;
            }
            if (loaded && archive == 2 &&
                ((operation == 3 && chunk == 20) ||
                 (operation == 2 && chunk == 74))) {
                /* 319MAO2 gates Jashiin's first appearance on FF21h. The DOS
                 * resident handoff leaves this shared byte asserted; a fresh
                 * zero-filled WASM segment did not, so MAO2 returned forever
                 * with every animation flag clear. Assert it again after the
                 * MAO2 sprite load because cold/direct arena initialization
                 * clears shared scratch state after loading the code chunk. */
                memory[linear(FIGHT_SEG, MAO2_APPEAR_GATE)] = 0xFF;
            }
        }
        platform_log("200FIGHT loader: AL=%u AH=%u SI=%04X ref=%u/%u asset=%s loaded=%d ES=%04X DI=%04X",
                     (unsigned)operation, (unsigned)selector, si, archive, chunk,
                     asset ? asset : "?", loaded,
                     registers[ZEL_TINY86_ES], registers[ZEL_TINY86_DI]);
        return 0;
    }
    if (cs == FIGHT_SEG) {
        const size_t instruction = linear(cs, ip);
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x60) {
            zel_fight86_set_ip((u16)(ip + 2u));
            return 1;
        }
        if (memory[instruction] == 0xCD && memory[instruction + 1] == 0x61) {
            const u8 buttons = memory[linear(FIGHT_SEG, 0xFF16)];
            /* Match stick.asm's INT 61h contract exactly: AL is the physical
             * direction mask and AH is Alt/Space. 200FIGHT combines those
             * inputs with player state and nearby-object scans to choose the
             * appropriate sword reachability table and animation. */
            registers[ZEL_TINY86_AX] =
                (u16)(state->direction | ((u16)buttons << 8));
            zel_fight86_set_ip((u16)(ip + 2u));
            return 1;
        }
    }
    return 0;
}

static void fight_out(void *context, u16 port, u8 value) {
    fight_vm_state_t *state = context;
    if (port == 0x03C8) {
        state->palette_index = value;
        state->palette_component = 0;
        return;
    }
    if (port != 0x03C9) return;
    const u8 scaled = (u8)((value << 2) | (value >> 4));
    palette_color_t *color = &g_palette[state->palette_index];
    if (state->palette_component == 0) color->r = scaled;
    else if (state->palette_component == 1) color->g = scaled;
    else color->b = scaled;
    if (++state->palette_component == 3) {
        state->palette_component = 0;
        ++state->palette_index;
    }
}

int zeliard_fight_masm_vm_start(u8 *game_seg, size_t game_size,
                                u8 *vga, size_t vga_size) {
    memset(&g_fight_vm, 0, sizeof(g_fight_vm));
    if (!game_seg || game_size < 0x10000 || !vga || vga_size < 0x10000) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_ARGUMENT;
        return 0;
    }
    size_t bios_size = 0;
    u8 *bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    if (!bios) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_BIOS;
        return 0;
    }
    g_fight_vm.music_chunk = 0xFF;
    zel_fight86_reset(bios, (unsigned)bios_size);
    free(bios);

    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    memcpy(memory + fight, game_seg, 0x10000);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);
    const char *initial_map = map_for_selector(game_seg[0x00C4]);
    if (!initial_map) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_AREA_SELECTOR;
        platform_log("200FIGHT VM unsupported area selector %02X",
                     game_seg[0x00C4]);
        return 0;
    }
    if (!load_raw_to(memory, fight + 0x0100, "stick.bin") ||
        !load_raw_to(memory, fight + 0x2000, "gmmcga.bin") ||
        !load_payload_to(memory, fight + 0x3000, "gfmcga.bin") ||
        !load_payload_to(memory, fight + FIGHT_LOAD_BASE, "fight.bin") ||
        !load_payload_to(memory, fight + 0xC000, initial_map) ||
        !load_fill_to(memory, linear(ASSET_SEG, 0x0000), "magic.grp") ||
        !load_fill_to(memory, linear(ASSET_SEG, 0x1800), "sword.grp")) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_ASSET_LOAD;
        platform_log("200FIGHT VM base asset load failed");
        return 0;
    }
    /* stick.bin remains resident in DOS while town/fight overlays change.
     * Preserve its RNG accumulator: EAI6 uses it for the Tesoro/Plata
     * ceiling-block release gate. Reloading it as zero at every cavern made
     * those traps release in the same prematurely synchronized pattern. */
    write_u16(memory, fight + STICK_SUBSAMPLE_ACCUMULATOR,
              (u16)(game_seg[STICK_SUBSAMPLE_ACCUMULATOR] |
                    ((u16)game_seg[STICK_SUBSAMPLE_ACCUMULATOR + 1] << 8)));
    apply_debug_patches();
    relocate_words(memory, linear(ASSET_SEG, 0x1800), 3, 0x1800);
    if (!prepare_sword_graphics(memory, game_seg[0x0092])) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_SWORD_SELECTOR;
        platform_log("200FIGHT VM unsupported sword selector %02X",
                     game_seg[0x0092]);
        return 0;
    }
    write_u16(memory, fight + 0x010C, SAR_STUB);
    memory[fight + SAR_STUB] = 0xC3;
    write_u16(memory, fight + 0xFF2C, GAME_SEG);

    u16 *registers = zel_fight86_registers();
    registers[ZEL_TINY86_AX] = 0;
    registers[ZEL_TINY86_CS] = FIGHT_SEG;
    registers[ZEL_TINY86_DS] = FIGHT_SEG;
    registers[ZEL_TINY86_ES] = FIGHT_SEG;
    registers[ZEL_TINY86_SS] = FIGHT_SEG;
    registers[ZEL_TINY86_SP] = 0x2000;
    zel_fight86_set_ip(FIGHT_TOWN_ENTRY);
    zel_fight86_set_flags(0x0202);
    zel_fight86_set_step_callback(fight_step, &g_fight_vm);
    zel_fight86_set_out_callback(fight_out, &g_fight_vm);
    g_fight_vm.active = 1;
    g_fight_vm.allow_frame_once = 1;
    g_fight_vm.bootstrap_clock = 1;

    for (unsigned pass = 0; pass < 400 && g_fight_vm.active &&
            !g_fight_vm.at_frame; ++pass) {
        const int result = zel_fight86_run(INSTRUCTIONS_PER_SLICE);
        if (result == ZEL_TINY86_HALTED) {
            g_fight_vm.active = 0;
            break;
        }
    }
    if (memory[fight + PLAYER_AREA_SELECTOR] == JASHIIN_FINAL_SELECTOR)
        memory[fight + MAO2_APPEAR_GATE] = 0xFF;
    memcpy(game_seg, memory + fight, 0x10000);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    g_fight_vm.bootstrap_clock = 0;
    if (!g_fight_vm.at_frame) {
        g_fight_vm.last_error = ZEL_FIGHT_VM_ERROR_BOOTSTRAP;
        platform_log("200FIGHT VM start stopped at %04X after %u instructions; trace:",
                     zel_fight86_ip(), (unsigned)g_fight_vm.instructions);
        for (unsigned i = 0; i < 32; ++i) {
            const u8 at = (u8)(g_fight_vm.trace_at + i);
            platform_log(" %04X", g_fight_vm.trace[at & 31u]);
        }
    }
    return g_fight_vm.active && g_fight_vm.at_frame;
}

static void sync_host_state(u8 *game_seg, u8 *vga) {
    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    memcpy(game_seg, memory + fight, 0x100);
    /* Four release-MASM Magia Stone orbit records. Keep their advancing
     * phase visible to 201SELCT if inventory is opened again. */
    memcpy(game_seg + 0xEB60, memory + fight + 0xEB60, 4u * 7u);
    memcpy(game_seg + STICK_SUBSAMPLE_ACCUMULATOR,
           memory + fight + STICK_SUBSAMPLE_ACCUMULATOR, 2);
    memcpy(game_seg + 0xFF00, memory + fight + 0xFF00, 0x80);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
}

int zeliard_fight_masm_vm_advance(u8 *game_seg, size_t game_size,
                                  u8 *vga, size_t vga_size,
                                  u32 pit_ticks, u8 direction) {
    if (!g_fight_vm.active || !game_seg || game_size < 0x10000 ||
        !vga || vga_size < 0x10000) return 0;
    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    memcpy(memory + fight, game_seg, 0x100);
    memcpy(memory + fight + 0xFF16, game_seg + 0xFF16, 0x14);
    g_fight_vm.direction = direction;

    if (g_fight_vm.ending_mode) {
        memory[fight + 0xFF1A] =
            (u8)(memory[fight + 0xFF1A] + (u8)pit_ticks);
        write_u16(memory, fight + 0xFF50,
                  (u16)(read_u16(memory, fight + 0xFF50) + (u16)pit_ticks));
        const u8 action_down = (u8)(game_seg[0xFF16] & 3u);
        if (!action_down)
            g_fight_vm.ending_host_action_latched = 0;
        if (action_down && !g_fight_vm.ending_host_action_latched) {
            memory[fight + 0xFF1D] = 0xFF;
            memory[fight + 0xFF21] = 0xFF;
            g_fight_vm.ending_host_action_latched = 1;
        }
        g_fight_vm.ending_at_wait = 0;
        g_fight_vm.ending_allow_wait_once = 1;
        g_fight_vm.ending_present_pending = 0;
        /* Keep the browser event loop available to paint and refill the
         * AudioWorklet.  Some 250ENDMO draws contain millions of guest
         * instructions between timer polls; running all of them in one host
         * callback starves both video and PCM.  Resume one bounded CPU slice
         * per host tick, but expose the VGA page only at the authored MASM
         * timer/input boundary detected by ending_poll_instruction(). */
        if (zel_fight86_run(INSTRUCTIONS_PER_SLICE) == ZEL_TINY86_HALTED) {
            g_fight_vm.active = 0;
        }
        sync_host_state(game_seg, vga);
        return g_fight_vm.active &&
            (g_fight_vm.ending_at_wait ||
             g_fight_vm.ending_present_pending);
    }

    g_fight_vm.frame_pit_ticks += pit_ticks;

    /* stick.asm's timer ISR advances these counters at 1.193182 MHz / 13B1h
     * (~236.7 Hz).  fight.bin gates a normal frame at four ticks times the
     * configured speed (20 ticks for the default value 5).  Keep the CPU at
     * the frame boundary until real host PIT ticks satisfy that gate. */
    memory[fight + 0xFF1A] =
        (u8)(memory[fight + 0xFF1A] + (u8)pit_ticks);
    write_u16(memory, fight + 0xFF1B,
              (u16)(read_u16(memory, fight + 0xFF1B) + (u16)pit_ticks));
    if (g_fight_vm.at_frame) {
        const u8 speed = memory[fight + 0xFF33];
        const u8 threshold = (u8)(4u * (speed ? speed : 1u));
        if (g_fight_vm.frame_pit_ticks < threshold) {
            sync_host_state(game_seg, vga);
            return 0;
        }
        g_fight_vm.frame_pit_ticks -= threshold;
    }
    const u8 resume_from_frame = g_fight_vm.at_frame;
    g_fight_vm.at_frame = 0;
    g_fight_vm.allow_frame_once = resume_from_frame;
    for (unsigned pass = 0; pass < 64 && g_fight_vm.active &&
            !g_fight_vm.at_frame; ++pass) {
        if (zel_fight86_run(INSTRUCTIONS_PER_SLICE) == ZEL_TINY86_HALTED) {
            g_fight_vm.active = 0;
            break;
        }
        if (!g_fight_vm.authored_wait_sequence) break;
    }
    sync_host_state(game_seg, vga);
    /* Long transitions and boss sequences can render between visits to the
     * 629Ch gameplay boundary.  Tell the host to present that synchronized
     * VGA work even while the VM is still inside such a sequence. */
    return 1;
}

int zeliard_fight_masm_vm_active(void) { return g_fight_vm.active; }
zeliard_fight_vm_error_t zeliard_fight_masm_vm_last_error(void) {
    return g_fight_vm.last_error;
}
int zeliard_fight_masm_vm_at_frame(void) { return g_fight_vm.at_frame; }
u16 zeliard_fight_masm_vm_ip(void) { return zel_fight86_ip(); }

static u16 mcga_append_plane_bit(u16 value, u16 *plane) {
    const u16 carry = (u16)(*plane >> 15);
    *plane = (u16)((*plane << 1) | carry);
    return (u16)((value << 1) | carry);
}

/* GMMCGA:2C2A converts CX packed 16x8, three-plane sprites in place.
 * bg_restore_rect leaves the selected spell's 24 packed sprites at 9350h;
 * the converter first uses game_seg:0000h as scratch, then writes the
 * decoded six-byte rows back to 9350h. */
static void decode_spell_graphics_mcga(u8 *game) {
    memcpy(game, game + 0x9350, 0x480);
    const u8 *source = game;
    u8 *destination = game + 0x9350;
    for (unsigned sprite = 0; sprite < 0x18; ++sprite) {
        for (unsigned row = 0; row < 8; ++row) {
            u16 plane0 = (u16)(((u16)source[0] << 8) | source[1]);
            u16 plane1 = (u16)(((u16)source[2] << 8) | source[3]);
            u16 plane2 = (u16)(((u16)source[4] << 8) | source[5]);
            source += 6;
            u16 ax = 0;
            for (unsigned half = 0; half < 2; ++half) {
                for (unsigned pixel = 0; pixel < 5; ++pixel) {
                    ax = mcga_append_plane_bit(ax, &plane2);
                    ax = mcga_append_plane_bit(ax, &plane1);
                    ax = mcga_append_plane_bit(ax, &plane0);
                }
                ax = mcga_append_plane_bit(ax, &plane2);
                *destination++ = (u8)ax;
                *destination++ = (u8)(ax >> 8);
                ax = mcga_append_plane_bit(ax, &plane1);
                ax = mcga_append_plane_bit(ax, &plane0);
                for (unsigned pixel = 0; pixel < 2; ++pixel) {
                    ax = mcga_append_plane_bit(ax, &plane2);
                    ax = mcga_append_plane_bit(ax, &plane1);
                    ax = mcga_append_plane_bit(ax, &plane0);
                }
                *destination++ = (u8)ax;
            }
        }
    }
}

int zeliard_fight_masm_vm_restore_game_state(const u8 *game_seg,
                                             size_t game_size) {
    if (!g_fight_vm.active || !game_seg || game_size < 0x10000) return 0;
    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    /* The DOS selector and 200FIGHT share DS. Mirror every persistent
     * selector result before resuming: player/equipment/item fields, the
     * four Magia Stone orbit records, and the complete shared gvar block
     * (including FF4Bh item result). */
    memcpy(memory + fight, game_seg, 0x100);
    memcpy(memory + fight + 0xEB60, game_seg + 0xEB60, 4u * 7u);
    memcpy(memory + fight + 0xFF00, game_seg + 0xFF00, 0x80);
    /* 200FIGHT:combat_palette_update is the release continuation after
     * 201SELCT returns. */
    memset(memory + fight + 0xE900, 0xFD, 0x214);
    memory[fight + 0x9EF5] = 0xFF;
    memory[fight + 0x9EEF] = 0;
    memory[fight + 0x9EF0] = 0;
    memory[fight + 0xFF1D] = 0;
    memory[fight + 0xFF1E] = 0;
    /* GMMCGA:2106, the MCGA drv_screen_init_a target. */
    u8 *vga = memory + linear(VGA_SEG, 0);
    for (unsigned row = 14; row < 158; ++row)
        memset(vga + row * 320u + 48u, 0, 224u);
    /* 206GFMCA:bg_restore_rect runs with ES=gvar_game_seg.  Stage the new
     * spell's 0x480-byte dirty-background bank in that auxiliary segment,
     * not in 200FIGHT's resident DS. */
    const u8 spell = memory[fight + 0x009D];
    if (spell && spell != 7) {
        const size_t magic = linear(ASSET_SEG, 0);
        const u16 source = read_u16(memory, magic + (spell - 1u) * 2u);
        memcpy(memory + linear(GAME_SEG, 0x9350),
               memory + magic + source, 0x480);
        decode_spell_graphics_mcga(memory + linear(GAME_SEG, 0));
    }
    return 1;
}

int zeliard_fight_masm_vm_restore_vga(const u8 *vga, size_t vga_size) {
    if (!g_fight_vm.active || !vga || vga_size < 0x10000) return 0;
    memcpy(zel_fight86_memory() + linear(VGA_SEG, 0), vga, 0x10000);
    return 1;
}

u8 zeliard_fight_masm_vm_exit_operation(void) {
    return g_fight_vm.exit_operation;
}
u8 zeliard_fight_masm_vm_exit_selector(void) {
    return g_fight_vm.exit_selector;
}
u16 zeliard_fight_masm_vm_exit_dispatch_slot(void) {
    return g_fight_vm.exit_dispatch_slot;
}
u16 zeliard_fight_masm_vm_exit_scroll_count(void) {
    return g_fight_vm.exit_scroll_count;
}
u8 zeliard_fight_masm_vm_exit_scroll_dir(void) {
    return g_fight_vm.exit_scroll_dir;
}
u8 zeliard_fight_masm_vm_exit_player_y(void) {
    return g_fight_vm.exit_player_y;
}
u8 zeliard_fight_masm_vm_music_chunk(void) {
    return g_fight_vm.music_chunk;
}
int zeliard_fight_masm_vm_begin_ending(u8 *game_seg, size_t game_size,
                                       u8 *vga, size_t vga_size) {
    if (!game_seg || game_size < 0x10000 || !vga || vga_size < 0x10000)
        return 0;

    /* 211OMOYP starts the ending from Felishika's Castle, after 200FIGHT
     * and the Jashiin arena have already been unloaded. Build the small
     * resident environment that DOS still has around the newly loaded
     * endmo.bin instead of depending on stale fight-VM memory. */
    memset(&g_fight_vm, 0, sizeof(g_fight_vm));
    size_t bios_size = 0;
    u8 *bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    if (!bios) return 0;
    zel_fight86_reset(bios, (unsigned)bios_size);
    free(bios);

    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    memcpy(memory + fight, game_seg, 0x10000);
    memcpy(memory + linear(GAME_SEG, 0), game_seg, 0x10000);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);
    if (!load_raw_to(memory, fight + 0x0100, "stick.bin") ||
        !load_raw_to(memory, fight + 0x2000, "gmmcga.bin") ||
        !load_fill_to(memory, fight + 0xF500, "font.grp"))
        return 0;
    /* game.asm keeps FONT.GRP resident at F500h and relocates its three
     * internal glyph-table pointers before any cinematic runs.  Ending can
     * begin after a room VM has replaced the shared segment, so provision
     * that resident dependency explicitly instead of trusting stale bytes.
     * 250ENDMO's gfx_putchar_fn calls read these exact relocated pointers. */
    relocate_words(memory, fight + 0xF500, 3, 0xF500);
    write_u16(memory, fight + 0x010C, SAR_STUB);
    memory[fight + SAR_STUB] = 0xC3;
    write_u16(memory, fight + 0xFF2C, GAME_SEG);
    zel_fight86_set_step_callback(fight_step, &g_fight_vm);
    zel_fight86_set_out_callback(fight_out, &g_fight_vm);
    g_fight_vm.active = 1;
    g_fight_vm.music_chunk = 0xFF;

    /* 211OMOYP loads ENDDEMO and GDMCGA without clearing the visible
     * Princess-hut frame, holds that frame for 012Ch ticks, then calls
     * dispatch slot 3006h with BX=0000h/CX=50C8h.  The town host has just
     * completed the same hold, so install both chunks now and let the exact
     * driver call own the transition into 250ENDMO. */
    if (!load_payload_to(memory, fight + FIGHT_LOAD_BASE, "endmo.bin") ||
        !load_payload_to(memory, fight + 0x3000, "gdmcga.bin"))
        return 0;
    u16 *registers = zel_fight86_registers();
    registers[ZEL_TINY86_AX] = 3;
    registers[ZEL_TINY86_BX] = 0;
    registers[ZEL_TINY86_CX] = 0x50C8;
    registers[ZEL_TINY86_DI] = 0x3000;
    registers[ZEL_TINY86_CS] = FIGHT_SEG;
    registers[ZEL_TINY86_DS] = FIGHT_SEG;
    registers[ZEL_TINY86_ES] = FIGHT_SEG;
    registers[ZEL_TINY86_SS] = FIGHT_SEG;
    registers[ZEL_TINY86_SP] = 0x1FFE;
    write_u16(memory, fight + 0x1FFE, 0x0502);
    g_fight_vm.ending_driver_init = 1;
    g_fight_vm.ending_driver_ready = 0;
    g_fight_vm.ending_mode = 1;
    g_fight_vm.ending_finished = 0;
    g_fight_vm.ending_at_wait = 0;
    g_fight_vm.ending_allow_wait_once = 1;
    g_fight_vm.at_frame = 0;
    zel_fight86_set_ip(read_u16(memory, fight + 0x3006));
    zel_fight86_set_flags(0x0202);
    g_fight_vm.music_chunk = 0xFF;
    /* Run only to GDMCGA's first authored timer boundary.  Subsequent host
     * ticks expose the complete assembly-driven transition; its RET loads
     * ENDDEMO and jumps through [6000h] in fight_step above. */
    for (unsigned pass = 0; pass < 2000 && g_fight_vm.active &&
            !g_fight_vm.ending_at_wait; ++pass) {
        if (zel_fight86_run(INSTRUCTIONS_PER_SLICE) == ZEL_TINY86_HALTED) {
            g_fight_vm.active = 0;
            break;
        }
    }
    sync_host_state(game_seg, vga);
    return g_fight_vm.active && g_fight_vm.ending_at_wait;
}
int zeliard_fight_masm_vm_ending_active(void) {
    return g_fight_vm.active && g_fight_vm.ending_mode;
}
int zeliard_fight_masm_vm_ending_finished(void) {
    return g_fight_vm.ending_finished;
}
u8 zeliard_fight_masm_vm_ending_scene(void) {
    return g_fight_vm.active && g_fight_vm.ending_mode
        ? zel_fight86_memory()[linear(FIGHT_SEG, 0x696C)] : 0;
}
u8 zeliard_fight_masm_vm_take_sound_cue(void) {
    if (!g_fight_vm.sound_cue_count) return 0;
    const u8 cue = g_fight_vm.sound_cues[g_fight_vm.sound_cue_read];
    g_fight_vm.sound_cue_read = (u8)((g_fight_vm.sound_cue_read + 1u) & 31u);
    --g_fight_vm.sound_cue_count;
    return cue;
}
int zeliard_fight_masm_vm_peek_u8(u16 offset) {
    return zel_fight86_memory()[linear(FIGHT_SEG, offset)];
}
int zeliard_fight_masm_vm_peek_u16(u16 offset) {
    return read_u16(zel_fight86_memory(), linear(FIGHT_SEG, offset));
}
int zeliard_fight_masm_vm_peek_data_u8(u16 offset) {
    const u8 *memory = zel_fight86_memory();
    const u16 data_seg = read_u16(memory, linear(FIGHT_SEG, 0xFF2C));
    return memory[linear(data_seg, offset)];
}
int zeliard_fight_masm_vm_poke_u8(u16 offset, u8 value) {
    if (!g_fight_vm.active) return 0;
    zel_fight86_memory()[linear(FIGHT_SEG, offset)] = value;
    return 1;
}
int zeliard_fight_masm_vm_poke_u16(u16 offset, u16 value) {
    if (!g_fight_vm.active || offset == 0xFFFFu) return 0;
    write_u16(zel_fight86_memory(), linear(FIGHT_SEG, offset), value);
    return 1;
}

void zeliard_fight_masm_vm_set_debug_invincible(int enabled) {
    g_debug_invincible = enabled != 0;
    if (g_fight_vm.active) apply_debug_patches();
}

void zeliard_fight_masm_vm_set_debug_no_gravity(int enabled) {
    g_debug_no_gravity = enabled != 0;
    if (g_fight_vm.active) apply_debug_patches();
}
void zeliard_fight_masm_vm_stop(void) { g_fight_vm.active = 0; }
