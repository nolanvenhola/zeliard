#include "ckpd_masm_vm.h"

#include "../platform/platform.h"
#include "../third_party/8086tiny/8086tiny.h"

#include <stdlib.h>
#include <string.h>

void zel_ckpd86_reset(const unsigned char *bios, unsigned bios_size);
void zel_ckpd86_set_step_callback(zel_tiny86_step_fn callback, void *context);
int zel_ckpd86_run(unsigned max_instructions);
unsigned char *zel_ckpd86_memory(void);
unsigned zel_ckpd86_memory_size(void);
unsigned short *zel_ckpd86_registers(void);
unsigned short zel_ckpd86_ip(void);
void zel_ckpd86_set_ip(unsigned short value);
void zel_ckpd86_set_flags(unsigned short value);

enum {
    CKPD_SEG = 0x1000,
    CKPD_LOAD_OFFSET = 0x3300,
    STACK_SEG = 0x8000,
    VGA_SEG = 0xA000,
    MAX_INSTRUCTIONS = 4000000,
};

typedef struct {
    u8 returned;
} ckpd_vm_state_t;

static size_t linear(u16 segment, u16 offset) {
    return (size_t)segment * 16u + offset;
}

static void write_u16(u8 *memory, size_t address, u16 value) {
    memory[address] = (u8)value;
    memory[address + 1] = (u8)(value >> 8);
}

static int ckpd_step(void *context, u16 cs, u16 ip) {
    ckpd_vm_state_t *state = context;
    if (cs == 0 && ip == 0) {
        state->returned = 1;
        return 1;
    }
    return 0;
}

int zeliard_ckpd_masm_vm_render(const u8 *payload, size_t payload_size,
                                u8 *vga, size_t vga_size) {
    if (!payload || payload_size == 0 || !vga || vga_size < 0x10000)
        return -1;

    size_t bios_size = 0;
    u8 *bios = platform_load_asset("8086tiny-bios.bin", &bios_size);
    if (!bios) return -2;
    zel_ckpd86_reset(bios, (unsigned)bios_size);
    free(bios);

    u8 *memory = zel_ckpd86_memory();
    const size_t chunk = linear(CKPD_SEG, CKPD_LOAD_OFFSET);
    if (chunk + payload_size > zel_ckpd86_memory_size()) return -3;
    memcpy(memory + chunk, payload, payload_size);
    memcpy(memory + linear(VGA_SEG, 0), vga, 0x10000);

    u16 *registers = zel_ckpd86_registers();
    registers[ZEL_TINY86_AX] = 4;
    registers[ZEL_TINY86_CS] = CKPD_SEG;
    registers[ZEL_TINY86_DS] = CKPD_SEG;
    registers[ZEL_TINY86_ES] = CKPD_SEG;
    registers[ZEL_TINY86_SS] = STACK_SEG;
    registers[ZEL_TINY86_SP] = 0xFFF8;
    write_u16(memory, linear(STACK_SEG, 0xFFF8), 0);
    write_u16(memory, linear(STACK_SEG, 0xFFFA), 0);
    zel_ckpd86_set_ip(CKPD_LOAD_OFFSET);
    zel_ckpd86_set_flags(0x0202);

    ckpd_vm_state_t state = {0};
    zel_ckpd86_set_step_callback(ckpd_step, &state);
    const int result = zel_ckpd86_run(MAX_INSTRUCTIONS);
    const int far_returned = state.returned ||
        (result == ZEL_TINY86_HALTED &&
         registers[ZEL_TINY86_CS] == 0 && zel_ckpd86_ip() == 0);
    if (!far_returned) {
        platform_log("209CKPD VM did not return: result=%d cs=%04X ip=%04X sp=%04X",
                     result, registers[ZEL_TINY86_CS],
                     (unsigned)zel_ckpd86_ip(), registers[ZEL_TINY86_SP]);
        return -4;
    }

    memcpy(vga, memory + linear(VGA_SEG, 0), 0x10000);
    return 0;
}
