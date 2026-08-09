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
    FIGHT_TOWN_ENTRY = 0x79DC,
    INSTRUCTIONS_PER_SLICE = 50000,
};

typedef struct {
    u8 active;
    u8 at_frame;
    u8 allow_frame_once;
    u8 direction;
    u8 palette_index;
    u8 palette_component;
    u8 exit_operation;
    u8 exit_selector;
    u8 music_chunk;
    u8 bootstrap_clock;
    u8 authored_wait_sequence;
    u16 exit_dispatch_slot;
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
    {2, 10, "crab.bin"},
    {2, 11, "tako.bin"},
    {2, 12, "tori.bin"},
    {2, 13, "zela.bin"},
    {2, 14, "meda.bin"},
    {2, 15, "lega.bin"},
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
    {2, 65, "crab.grp"},
    {2, 66, "tako.grp"},
    {2, 67, "tori.grp"},
    {2, 68, "zela.grp"},
    {2, 69, "meda.grp"},
    {2, 70, "lega.grp"},
    {2, 75, "mpp1.grp"},
    {2, 76, "mpp2.grp"},
    {2, 77, "mpp3.grp"},
    {2, 78, "mpp4.grp"},
    {2, 79, "mpp5.grp"},
    {2, 80, "mpp6.grp"},
    {2, 86, "mus1.msd"},
    {2, 87, "mus2.msd"},
    {2, 88, "mus3.msd"},
    {2, 89, "mus4.msd"},
    {2, 90, "mus5.msd"},
    {2, 91, "mus6.msd"},
    {2, 94, "mbos.msd"},
    {2, 95, "mfan.msd"},
};

static const char *asset_for_ref(u8 archive, u8 chunk) {
    for (size_t i = 0; i < sizeof(FIGHT_ASSETS) / sizeof(FIGHT_ASSETS[0]); ++i)
        if (FIGHT_ASSETS[i].archive == archive &&
            FIGHT_ASSETS[i].chunk == chunk)
            return FIGHT_ASSETS[i].asset;
    return NULL;
}

static const char *map_for_selector(u8 selector) {
    switch (selector) {
        case 0x00:
        case 0x1E: return "mp10.mdt";
        case 0x01:
        case 0x1F: return "mp1d.mdt";
        case 0x02:
        case 0x20: return "mp20.mdt";
        case 0x03:
        case 0x21: return "mp21.mdt";
        case 0x04:
        case 0x22: return "mp2d.mdt";
        case 0x05:
        case 0x23: return "mp30.mdt";
        case 0x06:
        case 0x24: return "mp31.mdt";
        case 0x07:
        case 0x25: return "mp3d.mdt";
        case 0x08:
        case 0x26: return "mp40.mdt";
        case 0x09:
        case 0x27: return "mp41.mdt";
        /* MP4D is Agar's chamber.  The release engine reaches it through
         * MP40's x224/y18 door, then owns the directional ROKA run and the
         * complete ENCOUNTER! wipe before dispatching ZELA. */
        case 0x0A:
        case 0x28: return "mp4d.mdt";
        case 0x0B:
        case 0x29: return "mp50.mdt";
        case 0x0C:
        case 0x2A: return "mp51.mdt";
        /* MP5D is Vista's chamber, reached from Cementar's x157/y16
         * authored boss door through the standard ROKA/ENCOUNTER flow. */
        case 0x0D:
        case 0x2B: return "mp5d.mdt";
        case 0x0E:
        case 0x2C: return "mp60.mdt";
        case 0x0F:
        case 0x2D: return "mp61.mdt";
        /* MP62 is Arrugia's secret treasure cavern, reached through
         * Tesoro's x31/y5 Lion-keyed door and exited through x62/y13. */
        case 0x10:
        case 0x2E: return "mp62.mdt";
        /* MP6D is Tarso's chamber.  Tesoro's x309/y41 boss door owns the
         * standard ROKA run and ENCOUNTER! wipe before dispatching LEGA. */
        case 0x11:
        case 0x2F: return "mp6d.mdt";
        default: return NULL;
    }
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

static int fight_step(void *context, u16 cs, u16 ip) {
    fight_vm_state_t *state = context;
    u8 *memory = zel_fight86_memory();
    u16 *registers = zel_fight86_registers();
    if (cs == FIGHT_SEG) {
        state->trace[state->trace_at++ & 31u] = ip;
        ++state->instructions;
        const size_t instruction = linear(cs, ip);
        /* All 200FIGHT sound posts use `mov byte ptr [FF75h],imm8`.
         * Observe execution of that instruction, not the duration for which
         * the byte remains nonzero. A spike pit repeats because it executes
         * the damage path repeatedly; a single hit executes it once. */
        if (memory[instruction] == 0xC6 &&
            memory[instruction + 1] == 0x06 &&
            memory[instruction + 2] == 0x75 &&
            memory[instruction + 3] == 0xFF)
            post_sound_cue(state, memory[instruction + 4]);
        if (state->bootstrap_clock &&
            (state->instructions & 0x7FFu) == 0) {
            ++memory[linear(FIGHT_SEG, 0xFF1A)];
            write_u16(memory, linear(FIGHT_SEG, 0xFF1B),
                      (u16)(memory[linear(FIGHT_SEG, 0xFF1B)] |
                            ((u16)memory[linear(FIGHT_SEG, 0xFF1C)] << 8)) + 1u);
        }
    }
    if (cs == FIGHT_SEG && ip == 0x629C) {
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
        const char *asset = operation == 1 ? map_for_selector(selector)
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
            state->active = 0;
            return 1;
        } else if (operation == 4) {
            loaded = prepare_sword_graphics(memory, selector);
        } else if (asset) {
            const size_t destination = operation == 1
                ? linear(FIGHT_SEG, 0xC000)
                : linear(registers[ZEL_TINY86_ES], registers[ZEL_TINY86_DI]);
            loaded = operation == 2
                ? load_fill_to(memory, destination, asset)
                : load_payload_to(memory, destination, asset);
            if (loaded && operation == 2 && archive == 2 && chunk == 56)
                state->authored_wait_sequence = 1;
            if (loaded && operation == 5)
                state->music_chunk = chunk;
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
    if (!game_seg || game_size < 0x10000 || !vga || vga_size < 0x10000)
        return 0;
    size_t bios_size = 0;
    u8 *bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    if (!bios) return 0;
    memset(&g_fight_vm, 0, sizeof(g_fight_vm));
    g_fight_vm.music_chunk = 0xFF;
    zel_fight86_reset(bios, (unsigned)bios_size);
    free(bios);

    u8 *memory = zel_fight86_memory();
    const size_t fight = linear(FIGHT_SEG, 0);
    memcpy(memory + fight, game_seg, 0x10000);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);
    const char *initial_map = map_for_selector(game_seg[0x00C4]);
    if (!initial_map) {
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
        platform_log("200FIGHT VM base asset load failed");
        return 0;
    }
    relocate_words(memory, linear(ASSET_SEG, 0x1800), 3, 0x1800);
    if (!prepare_sword_graphics(memory, game_seg[0x0092])) {
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
    memcpy(game_seg, memory + fight, 0x10000);
    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    g_fight_vm.bootstrap_clock = 0;
    if (!g_fight_vm.at_frame) {
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
int zeliard_fight_masm_vm_at_frame(void) { return g_fight_vm.at_frame; }
u16 zeliard_fight_masm_vm_ip(void) { return zel_fight86_ip(); }
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
u8 zeliard_fight_masm_vm_music_chunk(void) {
    return g_fight_vm.music_chunk;
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
void zeliard_fight_masm_vm_stop(void) { g_fight_vm.active = 0; }
