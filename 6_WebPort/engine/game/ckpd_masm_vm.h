#ifndef ZELIARD_CKPD_MASM_VM_H
#define ZELIARD_CKPD_MASM_VM_H

#include "../core/types.h"

/* Execute the header-stripped 209CKPD release payload at its authored
 * (CS+2000h):3300h address with AL=4 (MCGA), then copy A000:0000 back. */
int zeliard_ckpd_masm_vm_render(const u8 *payload, size_t payload_size,
                                u8 *vga, size_t vga_size);

#endif
