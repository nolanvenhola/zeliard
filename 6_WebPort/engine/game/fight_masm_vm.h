#ifndef ZELIARD_FIGHT_MASM_VM_H
#define ZELIARD_FIGHT_MASM_VM_H

#include "../core/types.h"

typedef enum {
    ZEL_FIGHT_VM_ERROR_NONE = 0,
    ZEL_FIGHT_VM_ERROR_ARGUMENT,
    ZEL_FIGHT_VM_ERROR_BIOS,
    ZEL_FIGHT_VM_ERROR_AREA_SELECTOR,
    ZEL_FIGHT_VM_ERROR_ASSET_LOAD,
    ZEL_FIGHT_VM_ERROR_SWORD_SELECTOR,
    ZEL_FIGHT_VM_ERROR_BOOTSTRAP,
} zeliard_fight_vm_error_t;

int zeliard_fight_masm_vm_start(u8 *game_seg, size_t game_size,
                                u8 *vga, size_t vga_size);
int zeliard_fight_masm_vm_advance(u8 *game_seg, size_t game_size,
                                  u8 *vga, size_t vga_size,
                                  u32 pit_ticks, u8 direction);
int zeliard_fight_masm_vm_active(void);
zeliard_fight_vm_error_t zeliard_fight_masm_vm_last_error(void);
int zeliard_fight_masm_vm_at_frame(void);
u16 zeliard_fight_masm_vm_ip(void);
u8 zeliard_fight_masm_vm_exit_operation(void);
u8 zeliard_fight_masm_vm_exit_selector(void);
u16 zeliard_fight_masm_vm_exit_dispatch_slot(void);
u16 zeliard_fight_masm_vm_exit_scroll_count(void);
u8 zeliard_fight_masm_vm_exit_scroll_dir(void);
u8 zeliard_fight_masm_vm_exit_player_y(void);
u8 zeliard_fight_masm_vm_music_chunk(void);
int zeliard_fight_masm_vm_ending_requested(void);
int zeliard_fight_masm_vm_begin_ending(void);
int zeliard_fight_masm_vm_ending_active(void);
int zeliard_fight_masm_vm_ending_finished(void);
u8 zeliard_fight_masm_vm_ending_scene(void);
/* One entry per executed 200FIGHT write to gvar_volume_b (FF75h). */
u8 zeliard_fight_masm_vm_take_sound_cue(void);
int zeliard_fight_masm_vm_peek_u8(u16 offset);
int zeliard_fight_masm_vm_peek_u16(u16 offset);
int zeliard_fight_masm_vm_poke_u8(u16 offset, u8 value);
int zeliard_fight_masm_vm_poke_u16(u16 offset, u16 value);
int zeliard_fight_masm_vm_restore_game_state(const u8 *game_seg,
                                             size_t game_size);
int zeliard_fight_masm_vm_restore_vga(const u8 *vga, size_t vga_size);
void zeliard_fight_masm_vm_stop(void);

#endif
