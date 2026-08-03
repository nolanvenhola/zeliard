#ifndef ZELIARD_INVENTORY_MASM_VM_H
#define ZELIARD_INVENTORY_MASM_VM_H

#include "../core/types.h"

typedef enum {
    ZEL_INVENTORY_CONTEXT_CAVERN = 0,
    ZEL_INVENTORY_CONTEXT_TOWN = 1,
} zeliard_inventory_context_t;

int zeliard_inventory_masm_vm_start(u8 *game_seg, size_t game_size,
                                    u8 *vga, size_t vga_size,
                                    zeliard_inventory_context_t context);
int zeliard_inventory_masm_vm_advance(u8 *game_seg, size_t game_size,
                                      u8 *vga, size_t vga_size,
                                      u32 pit_ticks, u8 direction,
                                      u8 space, u8 enter);
int zeliard_inventory_masm_vm_active(void);
int zeliard_inventory_masm_vm_at_input_poll(void);
u16 zeliard_inventory_masm_vm_ip(void);
u8 zeliard_inventory_masm_vm_peek(u16 offset);
u16 zeliard_inventory_masm_vm_itemp_word(u16 offset);
void zeliard_inventory_masm_vm_stop(void);

#endif
