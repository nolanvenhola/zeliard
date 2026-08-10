#ifndef ZELIARD_MSCADLIB_VM_H
#define ZELIARD_MSCADLIB_VM_H

#include "../core/types.h"

#include <stddef.h>

typedef struct {
    u32 tick;
    u8 reg;
    u8 value;
} zel_opl_write_t;

typedef struct {
    u32 tick;
    u16 port;
    u8 value;
} zel_audio_port_write_t;

typedef struct {
    u32 tick;
    u8 opl_address;
    u8 opl_address_valid;
    u8 loaded;
    u8 sfx_loaded;
    u8 failed;
    zel_opl_write_t writes[16384];
    size_t write_count;
    size_t read_index;
    zel_audio_port_write_t port_writes[16384];
    size_t port_write_count;
    size_t port_read_index;
    u8 mt32_score;
} zel_mscadlib_vm_t;

int zel_mscadlib_vm_init_variant(zel_mscadlib_vm_t *vm,
                         const u8 *driver, size_t driver_size,
                         const u8 *tiny86_bios, size_t bios_size,
                         int mt32_score);

int zel_mscadlib_vm_init(zel_mscadlib_vm_t *vm,
                         const u8 *driver, size_t driver_size,
                         const u8 *tiny86_bios, size_t bios_size);
int zel_mscadlib_vm_load_sfx_driver(zel_mscadlib_vm_t *vm,
                                    const u8 *driver, size_t driver_size);
int zel_mscadlib_vm_load_score(zel_mscadlib_vm_t *vm,
                               const u8 *sar_file, size_t sar_file_size);
int zel_mscadlib_vm_service(zel_mscadlib_vm_t *vm, u16 ax, u16 cx);
int zel_mscadlib_vm_tick(zel_mscadlib_vm_t *vm);
size_t zel_mscadlib_vm_take_writes(zel_mscadlib_vm_t *vm,
                                   zel_opl_write_t *out, size_t capacity);
size_t zel_mscadlib_vm_take_port_writes(zel_mscadlib_vm_t *vm,
                                   zel_audio_port_write_t *out, size_t capacity);
u8 zel_mscadlib_vm_global(const zel_mscadlib_vm_t *vm, u16 offset);
void zel_mscadlib_vm_set_global(zel_mscadlib_vm_t *vm, u16 offset, u8 value);

#endif
