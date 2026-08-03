#ifndef ZELIARD_ROOM_MASM_VM_H
#define ZELIARD_ROOM_MASM_VM_H

#include "room_runtime.h"

enum {
    ZEL_ROOM_VM_INPUT_NONE = 0,
    ZEL_ROOM_VM_INPUT_MENU = 1,
    ZEL_ROOM_VM_INPUT_TEXT = 2,
    ZEL_ROOM_VM_INPUT_NAME = 3,
};

int zeliard_room_masm_vm_start(zeliard_room_kind_t kind,
                               const u8 *game_seg, size_t game_size,
                               const u8 *vga, size_t vga_size);
int zeliard_room_masm_vm_advance(u8 *game_seg, size_t game_size,
                                 u8 *vga, size_t vga_size,
                                 u32 pit_ticks, u8 direction,
                                 u8 space, u8 enter);
u16 zeliard_room_masm_vm_ip(void);
int zeliard_room_masm_vm_at_input_poll(void);
int zeliard_room_masm_vm_input_kind(void);
int zeliard_room_masm_vm_active(void);
u8 zeliard_room_masm_vm_take_sound_cue(void);
void zeliard_room_masm_vm_text_key(u8 ascii);
u32 zeliard_room_masm_vm_save_serial(void);
const char *zeliard_room_masm_vm_save_name(void);
const u8 *zeliard_room_masm_vm_save_record(void);
void zeliard_room_masm_vm_force_save_failure(int fail);
void zeliard_room_masm_vm_stop(void);

#endif
