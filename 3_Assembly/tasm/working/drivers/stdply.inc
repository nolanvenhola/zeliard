;==========================================================================
;
;  stdply.inc - Shared field offsets for stdply.bin player state block
;
;  stdply.bin loads at game_entry_seg:0000h. All graphics drivers (gm*.bin)
;  run in the same segment and access this data via CS-relative addresses.
;
;  Include this file in every driver that reads stdply state fields.
;  If stdply.asm's layout changes, update the EQUs here — all drivers
;  pick up the change automatically.
;
;==========================================================================

; Player config bytes  [0x0080-0x0084]
ply_walk_speed          equ     80h     ; walk speed (init 0x1E = 30)
ply_accel               equ     83h     ; movement acceleration x,y (init 0x0A each)

; Timer / display state  [0x0085-0x008F]
drv_timer_flag          equ     85h     ; timer display active flag
drv_time_param_a        equ     86h     ; timestamp low byte
drv_time_param_b        equ     8Bh     ; timestamp high byte

; Text / animation state  [0x0090-0x00AA]
drv_text_src            equ     90h     ; text source stride (init 0x50 = 80)
ply_jump_flag           equ     92h     ; jump enable flag (init 1)
drv_sprite_flag         equ     93h     ; sprite display active flag
drv_time_param_c        equ     94h     ; time counter byte
drv_frame_idx           equ     9Dh     ; animation frame index (1-based; 0=none)

; Animation color LUT  [0x00AB-0x00C3]
drv_color_lut           equ     0ABh    ; base: cs:[drv_color_lut + frame - 1]
