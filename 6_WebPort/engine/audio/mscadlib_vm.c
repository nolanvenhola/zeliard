#include "mscadlib_vm.h"
#include "../third_party/8086tiny/8086tiny.h"

#include <string.h>

enum {
    GAME_SEG = 0x1000,
    MUSIC_SEG = GAME_SEG + 0x0FF0,
    STACK_SEG = 0x3000,
    DRIVER_ENTRY_TICK = 0x0100,
    DRIVER_ENTRY_SERVICE = 0x0103,
    DRIVER_LOAD_OFFSET = 0x0100,
    SFX_DRIVER_ENTRY_TICK = 0x1100,
    SFX_DRIVER_LOAD_OFFSET = 0x1100,
    SCORE_OFFSET = 0x3000,
    MAX_DRIVER_INSTRUCTIONS = 1000000
};

static zel_mscadlib_vm_t *g_active_vm;

static size_t linear(u16 segment, u16 offset) {
    return (size_t)segment * 16u + offset;
}

static void write_u16(u8 *memory, size_t address, u16 value) {
    memory[address] = (u8)value;
    memory[address + 1] = (u8)(value >> 8);
}

static void on_port_write(void *context, u16 port, u8 value) {
    zel_mscadlib_vm_t *vm = (zel_mscadlib_vm_t *)context;

    if (vm->port_write_count >= sizeof(vm->port_writes) / sizeof(vm->port_writes[0])) {
        vm->failed = 1;
        return;
    }
    vm->port_writes[vm->port_write_count++] = (zel_audio_port_write_t){
        .tick = vm->tick, .port = port, .value = value
    };

    if (port == 0x0388) {
        vm->opl_address = value;
        vm->opl_address_valid = 1;
        return;
    }
    if (port != 0x0389 || !vm->opl_address_valid)
        return;
    if (vm->write_count >= sizeof(vm->writes) / sizeof(vm->writes[0])) {
        vm->failed = 1;
        return;
    }
    vm->writes[vm->write_count++] = (zel_opl_write_t){
        .tick = vm->tick,
        .reg = vm->opl_address,
        .value = value
    };
}

static int run_far_return(zel_mscadlib_vm_t *vm, u16 entry) {
    u8 *memory = zel_tiny86_memory();
    u16 *regs = zel_tiny86_registers();
    const u16 sp = 0xFFFC;

    regs[ZEL_TINY86_CS] = MUSIC_SEG;
    regs[ZEL_TINY86_SS] = STACK_SEG;
    regs[ZEL_TINY86_SP] = sp;
    zel_tiny86_set_ip(entry);
    write_u16(memory, linear(STACK_SEG, sp), 0);
    write_u16(memory, linear(STACK_SEG, (u16)(sp + 2)), 0);
    return zel_tiny86_run(MAX_DRIVER_INSTRUCTIONS) == ZEL_TINY86_HALTED;
}

static int run_iret(zel_mscadlib_vm_t *vm, u16 entry) {
    u8 *memory = zel_tiny86_memory();
    u16 *regs = zel_tiny86_registers();
    const u16 sp = 0xFFFA;

    regs[ZEL_TINY86_CS] = MUSIC_SEG;
    regs[ZEL_TINY86_SS] = STACK_SEG;
    regs[ZEL_TINY86_SP] = sp;
    zel_tiny86_set_ip(entry);
    write_u16(memory, linear(STACK_SEG, sp), 0);
    write_u16(memory, linear(STACK_SEG, (u16)(sp + 2)), 0);
    write_u16(memory, linear(STACK_SEG, (u16)(sp + 4)), 0x0202);
    return zel_tiny86_run(MAX_DRIVER_INSTRUCTIONS) == ZEL_TINY86_HALTED;
}

int zel_mscadlib_vm_init(zel_mscadlib_vm_t *vm,
                         const u8 *driver, size_t driver_size,
                         const u8 *tiny86_bios, size_t bios_size) {
    return zel_mscadlib_vm_init_variant(vm, driver, driver_size,
                                        tiny86_bios, bios_size, 0);
}

int zel_mscadlib_vm_init_variant(zel_mscadlib_vm_t *vm,
                         const u8 *driver, size_t driver_size,
                         const u8 *tiny86_bios, size_t bios_size,
                         int mt32_score) {
    u8 *memory;
    const size_t driver_address = linear(MUSIC_SEG, DRIVER_LOAD_OFFSET);

    if (!vm || !driver || !tiny86_bios || driver_size == 0 || bios_size == 0)
        return 0;
    memset(vm, 0, sizeof(*vm));
    zel_tiny86_reset(tiny86_bios, (unsigned)bios_size);
    memory = zel_tiny86_memory();
    if (driver_address + driver_size > zel_tiny86_memory_size())
        return 0;
    memcpy(memory + driver_address, driver, driver_size);
    /* zeliad.asm installs INT 60h as MUSIC_SEG:0103h. SNDADLIB invokes
     * MSCADLIB service 6 through that vector when effects start and end. */
    write_u16(memory, 0x60u * 4u, DRIVER_ENTRY_SERVICE);
    write_u16(memory, 0x60u * 4u + 2u, MUSIC_SEG);
    zel_tiny86_set_out_callback(on_port_write, vm);
    /* MPU-401 status: bit 6 clear means ready for a command/data byte. */
    zel_tiny86_set_io_port(0x331, 0);
    g_active_vm = vm;
    vm->loaded = 1;
    vm->mt32_score = mt32_score ? 1 : 0;
    return 1;
}

int zel_mscadlib_vm_load_sfx_driver(zel_mscadlib_vm_t *vm,
                                    const u8 *driver, size_t driver_size) {
    u8 *memory;
    const size_t driver_address = linear(MUSIC_SEG, SFX_DRIVER_LOAD_OFFSET);

    if (!vm || vm != g_active_vm || !vm->loaded || !driver || driver_size == 0)
        return 0;
    memory = zel_tiny86_memory();
    if (driver_address + driver_size > zel_tiny86_memory_size())
        return 0;
    memcpy(memory + driver_address, driver, driver_size);
    vm->sfx_loaded = 1;
    return 1;
}

int zel_mscadlib_vm_load_score(zel_mscadlib_vm_t *vm,
                               const u8 *sar_file, size_t sar_file_size) {
    u8 *memory;
    u16 *regs;
    u32 payload_size;
    u16 mt32_size;
    u16 adlib_size;
    const u8 *selected_score;
    u16 selected_size;

    if (!vm || vm != g_active_vm || !vm->loaded || !sar_file || sar_file_size < 4)
        return 0;
    payload_size = (u32)sar_file[0] | ((u32)sar_file[1] << 8) |
                   ((u32)sar_file[2] << 16) | ((u32)sar_file[3] << 24);
    if (payload_size != sar_file_size - 4 || payload_size < 4)
        return 0;
    mt32_size = (u16)sar_file[4] | ((u16)sar_file[5] << 8);
    adlib_size = (u16)sar_file[6] | ((u16)sar_file[7] << 8);
    if (4u + (u32)mt32_size + (u32)adlib_size != payload_size)
        return 0;
    selected_size = vm->mt32_score ? mt32_size : adlib_size;
    selected_score = vm->mt32_score ? sar_file + 8u : sar_file + 8u + mt32_size;
    if (SCORE_OFFSET + (u32)selected_size > 0x10000u)
        return 0;
    memory = zel_tiny86_memory();
    /* stick.asm fio_open_savefile_retry consumes the outer SAR size dword.
     * AL=5 then reads two 16-bit variant sizes from the payload.  With the
     * non-MT-32 flag used by MSCADLIB it seeks past the first variant and
     * reads the second one at the caller's exact ES:DI. */
    memcpy(memory + linear(GAME_SEG, SCORE_OFFSET), selected_score, selected_size);

    regs = zel_tiny86_registers();
    regs[ZEL_TINY86_AX] = 0;
    regs[ZEL_TINY86_CX] = 0;
    regs[ZEL_TINY86_DS] = GAME_SEG;
    regs[ZEL_TINY86_ES] = GAME_SEG;
    regs[ZEL_TINY86_SI] = SCORE_OFFSET;
    if (!run_iret(vm, DRIVER_ENTRY_SERVICE)) {
        vm->failed = 1;
        return 0;
    }
    return !vm->failed;
}

int zel_mscadlib_vm_service(zel_mscadlib_vm_t *vm, u16 ax, u16 cx) {
    u16 *regs;

    if (!vm || vm != g_active_vm || !vm->loaded)
        return 0;
    regs = zel_tiny86_registers();
    regs[ZEL_TINY86_AX] = ax;
    regs[ZEL_TINY86_CX] = cx;
    regs[ZEL_TINY86_DS] = GAME_SEG;
    regs[ZEL_TINY86_ES] = GAME_SEG;
    if (!run_iret(vm, DRIVER_ENTRY_SERVICE)) {
        vm->failed = 1;
        return 0;
    }
    return !vm->failed;
}

int zel_mscadlib_vm_tick(zel_mscadlib_vm_t *vm) {
    u16 *regs;

    if (!vm || vm != g_active_vm || !vm->loaded)
        return 0;
    vm->tick++;
    regs = zel_tiny86_registers();
    regs[ZEL_TINY86_DS] = GAME_SEG;
    regs[ZEL_TINY86_ES] = GAME_SEG;
    /* stick.asm timer_isr_entry calls gvar_gfx_fn (SNDADLIB:1100h) before
     * gvar_input_fn (MSCADLIB:0100h) on every PIT interrupt. */
    if (vm->sfx_loaded && !run_far_return(vm, SFX_DRIVER_ENTRY_TICK)) {
        vm->failed = 1;
        return 0;
    }
    regs[ZEL_TINY86_DS] = GAME_SEG;
    regs[ZEL_TINY86_ES] = GAME_SEG;
    if (!run_far_return(vm, DRIVER_ENTRY_TICK)) {
        vm->failed = 1;
        return 0;
    }
    return !vm->failed;
}

size_t zel_mscadlib_vm_take_writes(zel_mscadlib_vm_t *vm,
                                   zel_opl_write_t *out, size_t capacity) {
    size_t available;
    size_t count;

    if (!vm || !out)
        return 0;
    available = vm->write_count - vm->read_index;
    count = available < capacity ? available : capacity;
    memcpy(out, vm->writes + vm->read_index, count * sizeof(*out));
    vm->read_index += count;
    if (vm->read_index == vm->write_count) {
        vm->read_index = 0;
        vm->write_count = 0;
    }
    return count;
}

size_t zel_mscadlib_vm_take_port_writes(zel_mscadlib_vm_t *vm,
                                   zel_audio_port_write_t *out, size_t capacity) {
    size_t available, count;
    if (!vm || !out)
        return 0;
    available = vm->port_write_count - vm->port_read_index;
    count = available < capacity ? available : capacity;
    memcpy(out, vm->port_writes + vm->port_read_index, count * sizeof(*out));
    vm->port_read_index += count;
    if (vm->port_read_index == vm->port_write_count)
        vm->port_read_index = vm->port_write_count = 0;
    return count;
}

u8 zel_mscadlib_vm_global(const zel_mscadlib_vm_t *vm, u16 offset) {
    (void)vm;
    return zel_tiny86_memory()[linear(GAME_SEG, offset)];
}

void zel_mscadlib_vm_set_global(zel_mscadlib_vm_t *vm, u16 offset, u8 value) {
    (void)vm;
    zel_tiny86_memory()[linear(GAME_SEG, offset)] = value;
}
