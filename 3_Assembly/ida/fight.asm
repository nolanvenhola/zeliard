include common.inc
                .286
                .model small

; ===========================================================================

; Format      : Binary File
; Base Address: 0000h Range: 6000h - 9F2Eh Loaded length: 3F2Eh
; ===========================================================================

; Segment type: Pure code
fight           segment byte public 'CODE'
                assume cs:fight, ds:fight
                org 6000h
                assume es:nothing, ss:nothing
start           dw Cavern_Game_Init
                dw offset prepare_dungeon ; run from town to dungeon
                dw offset monster_move_in_direction ; al=angle starting from right, counter-clockwise
                dw offset Check_collision_in_direction
                dw offset move_monster_E
                dw offset move_monster_NE
                dw offset move_monster_N
                dw offset move_monster_NW
                dw offset move_monster_W
                dw offset move_monster_SW
                dw offset move_monster_S
                dw offset move_monster_SE
                dw offset check_collision_E2
                dw offset check_collision_W2
                dw offset check_collision_N2
                dw offset check_collision_S2
                dw offset check_collision_NE2
                dw offset check_collision_SE2
                dw offset check_collision_NW2
                dw offset check_collision_SW2
                dw offset coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                dw offset wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                dw offset wrap_map_from_below ; if (si < 0E000h) si += 900h
                dw offset if_passable_set_ZF
                dw offset Check_Monster_Ids_Two_Rows_Below_Monster
                dw offset Check_Vertical_Distance_Between_Hero_And_Monster
                dw offset Hero_Hits_monster
                dw offset HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                dw offset Get_Stats     ; al=0: return ah=hero_level/2
                                        ; al=1: return ah=sword_total_damage
                                        ; al=2..8: return ah=byte_98BE[al-2]
                                        ; al=9: NOP
                dw offset Add_Projectile_To_Array ; In: BX pointing to projectile struct
                dw offset Browse_Projectiles
                dw offset Find_Monsters_Near_Hero ; Return dl: number of monsters found nearby
                dw offset Move_Monster_NWE_Depending_On_Whats_Below ; si points to monster struc

; =============== S U B R O U T I N E =======================================


Cavern_Game_Init proc near              ; ...
                cli
                mov     sp, 2000h
                sti
                push    cs
                pop     ds
                assume ds:fight
                mov     slide_ticks_remaining, 0
                mov     horiz_movement_sub_tile_accum, 0
                mov     byte_9F22, 0
                mov     ax, 0FFFFh
                mov     projectiles_array, al
                mov     is_boss_dead, al
                mov     word ptr magic_projectiles, ax
                mov     byte ptr ds:boss_being_hit, 0
                mov     byte ptr ds:sprite_flash_flag, 0
                mov     byte ptr ds:boss_is_dead, 0
                mov     byte ptr ds:byte_9F01, 0
                test    byte ptr ds:is_boss_cavern, 0FFh
                jnz     short boss_place
                jmp     regular_cavern
; ---------------------------------------------------------------------------

boss_place:                             ; ...
                call    render_hud_bars_with_enemy
                mov     ax, 1
                int     60h             ; mscadlib.drv
                mov     byte_9F02, 0FFh
                mov     al, byte ptr ds:msd_index
                mov     bl, 11
                mul     bl
                add     ax, offset mgt1_msd
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 3000h       ; destination address for another binary
                mov     al, 5           ; fn_5
                call    cs:res_dispatcher_proc ; =0A84
                mov     si, offset encnt_grp
                mov     es, cs:game_segment
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; =0A84h
                call    cs:word_301C    ; =4518h
                mov     byte ptr ds:hero_sprite_hidden, 0
                call    cs:word_3016
                call    cs:word_3014
                call    clear_hero_in_viewport
                mov     byte_9F02, 0
                push    ds
                mov     ds, cs:game_segment
                assume ds:nothing
                mov     si, 3000h
                xor     ax, ax
                int     60h             ; mscadlib.drv
                pop     ds
                mov     cx, 6

loc_60E9:                               ; ...
                push    cx
                mov     byte ptr ds:frame_timer, 0

waiter0:                                ; ...
                cmp     byte ptr ds:frame_timer, 41h ; 'A'
                jb      short waiter0
                mov     bx, 0C28h
                mov     cx, 3828h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc
                mov     byte ptr ds:frame_timer, 0

loc_6108:                               ; ...
                cmp     byte ptr ds:frame_timer, 41h ; 'A'
                jb      short loc_6108
                call    cs:word_301C
                pop     cx
                loop    loc_60E9
                mov     si, ds:mdt_buffer
                add     si, 5
                mov     al, [si]
                mov     [si-1], al
                mov     bl, 11
                mul     bl
                add     ax, offset enp1_grp
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; =0A84h
                push    ds
                mov     ds, cs:game_segment
                mov     si, 4000h
                mov     bp, 0A000h
                mov     cx, 100h
                call    cs:word_3028
                pop     ds

render_boss_hud:                        ; ...
                mov     si, ds:word_A002
                add     si, 8
                lodsb
                mov     ds:byte_9F01, al
                mov     si, [si]
                call    cs:Render_Pascal_String_1_proc
                mov     si, ds:word_A002
                add     si, 3
                mov     bx, [si]
                push    bx
                call    cs:Draw_Boss_Max_Health_proc ; bx: boss maxHP
                pop     bx
                call    cs:Draw_Boss_Health_proc ; bx: boss health
                jmp     short loc_618F
; ---------------------------------------------------------------------------

regular_cavern:                         ; ...
                call    cs:Clear_Place_Enemy_Bar_proc
                call    render_place_and_gold_labels
                mov     si, ds:cavern_name_rendering_info ; =d614 for cavern Malicia
                call    cs:Render_Pascal_String_1_proc
                call    cs:Print_Gold_Decimal_proc

loc_618F:                               ; ...
                call    cs:Draw_Hero_Max_Health_proc
                call    cs:Draw_Hero_Health_proc
                call    cs:Print_Almas_Decimal_proc
                test    byte ptr ds:is_jashiin_cavern, 0FFh
                jnz     short jashiin_place
                jmp     init_cavern
; ---------------------------------------------------------------------------

jashiin_place:                          ; ...
                mov     ds:byte_9F26, 0FFh
                mov     word ptr ds:proximity_map_left_col_x, 41
                mov     byte ptr ds:hero_x_in_viewport, 5 ; 5+36=41; in the Jashiin's cavern hero appears not centered in viewport
                call    unpack_map
                call    clear_viewport_buffer

loc_61BE:                               ; ...
                call    main_update_render
                test    byte ptr ds:is_jashiin_cavern, 0FFh
                jnz     short loc_61BE  ; wait until fully entered the boss cavern
                push    ds
                mov     ds, cs:game_segment
                mov     si, 3000h
                xor     ax, ax
                int     60h             ; mscadlib.drv
                pop     ds
                mov     ds:byte_9F02, 0
                mov     ah, 30          ; MPA0.MDT - Jashiin's room
                mov     al, 1           ; fn_1
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                mov     byte ptr ds:is_boss_cavern, 0FFh
                mov     ds:byte_9F27, 0FFh
                mov     si, ds:mdt_buffer
                lodsb                   ; al = first byte of mdt_descr
                call    process_mdt_descriptor
                call    load_cavern_sprites_ai_music ; load dchr.grp
                                        ; load mpp{mpp_grp_index}.grp
                                        ; load eai{eai_bin_index}.bin
                                        ; load enp{enp_grp_index).grp
                                        ; load mgt{mgt_msd_index}.msd
                push    ds
                mov     ds, cs:game_segment
                mov     si, 8030h
                mov     cx, 102
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                call    cs:word_302A
                pop     ds
                push    ds
                call    cs:word_301A
                mov     cx, 24
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                mov     ds:hero_x_in_proximity_map, 18h
                mov     ds:byte_9F1C, 0Dh
                mov     byte ptr ds:hero_x_in_viewport, 0Ch
                mov     ds:byte_9F00, 0Ch
                call    hero_left_16_down_1
                call    render_hud_bars_with_enemy
                jmp     render_boss_hud
; ---------------------------------------------------------------------------

init_cavern:                            ; ...
                call    unpack_map      ; unpack *.mdt
                test    ds:byte_9F27, 0FFh
                jz      short loc_6254
                call    clear_viewport_buffer
                call    main_update_render
                mov     ds:byte_9F26, 0
                jmp     short loc_6266
; ---------------------------------------------------------------------------

loc_6254:                               ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_6260
                call    cs:Render_Viewport_Tiles_proc

loc_6260:                               ; ...
                call    clear_viewport_buffer ; 28x19
                call    update_all_monsters_in_map

loc_6266:                               ; ...
                test    byte ptr ds:is_death_already_processed, 0FFh
                jz      short not_dead
                jmp     process_hero_death
; ---------------------------------------------------------------------------

not_dead:                               ; ...
                test    ds:byte_9F02, 0FFh
                jz      short loc_628A
                mov     ds:byte_9F02, 0
                push    ds
                mov     ds, cs:game_segment
                mov     si, 3000h
                xor     ax, ax
                int     60h             ; mscadlib.drv
                pop     ds

loc_628A:                               ; ...
                xor     al, al
                mov     ds:byte_FF1D, al
                mov     ds:byte_FF1E, al
                mov     byte ptr ds:frame_timer, 0
                mov     ds:byte_9F27, 0

main_loop:                              ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jnz     short over_rope
                call    input_handling
                call    sliding_physics_step
                call    main_update_render
                call    magic_spell_fire_handler
                call    hero_interaction_check
                call    hero_knockback_handler
                inc     ds:frame_ticks
                cmp     ds:frame_ticks, 2
                jnz     short loc_62C5
                mov     byte ptr ds:squat_flag, 0

loc_62C5:                               ; ...
                mov     dx, offset main_loop
                push    dx              ;
                                        ; check input keys buffer
                int     61h             ; reserved for user interrupt
                test    al, 2
                jz      short no_down_pressed
                and     byte ptr ds:facing_direction, 11111101b ; down (not up)

no_down_pressed:                        ; ...
                call    airborne_movement
                call    state_machine_dispatcher
                retn                    ; jumps to main_loop
; ---------------------------------------------------------------------------

over_rope:                              ; ...
                mov     byte ptr ds:squat_flag, 0
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:slope_direction, 0
                mov     byte ptr ds:spell_active_flag, 0
                call    cs:Flush_Ui_Element_If_Dirty_proc
                mov     byte ptr ds:sword_swing_flag, 0
                call    main_update_render
                call    hero_knockback_handler
                call    state_machine_dispatcher
                cmp     byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jnz     short move_off_rope
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                inc     si
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short over_rope
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short over_rope

move_off_rope:                          ; ...
                and     byte ptr ds:facing_direction, 11111101b ; down
                mov     byte ptr ds:on_rope_flags, 0 ; any reason, including being hit by monster
                mov     byte ptr ds:byte_FF1D, 0
                mov     byte ptr ds:byte_FF1E, 0
                mov     ds:slide_ticks_remaining, 0
                mov     ds:horiz_movement_sub_tile_accum, 0
                mov     byte ptr ds:hero_animation_phase, 7Fh
                jmp     main_loop
Cavern_Game_Init endp


; =============== S U B R O U T I N E =======================================


state_machine_dispatcher proc near      ; ...
                mov     ds:byte_9F22, 0
                int     61h             ; reserved for user interrupt
                cmp     al, 101b
                jnz     short loc_6351
                jmp     left_up_pressed
; ---------------------------------------------------------------------------

loc_6351:                               ; ...
                cmp     al, 1001b
                jnz     short loc_6358
                jmp     right_up_pressed
; ---------------------------------------------------------------------------

loc_6358:                               ; ...
                cmp     al, 1
                jnz     short loc_635F
                jmp     up_pressed
; ---------------------------------------------------------------------------

loc_635F:                               ; ...
                mov     ah, al
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jnz     short loc_6399
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_6399
                test    ds:byte_9F0B, 0FFh
                jnz     short loc_6379
                jmp     loc_65BA
; ---------------------------------------------------------------------------

loc_6379:                               ; ...
                mov     ds:byte_9F0B, 0
                test    byte ptr ds:facing_direction, 10b ; up
                jnz     short no_squat_mode
                jmp     loc_65BA
; ---------------------------------------------------------------------------

no_squat_mode:                          ; ...
                mov     dx, offset loc_65BA
                push    dx
                test    byte ptr ds:facing_direction, LEFT
                jnz     short loc_6396
                jmp     loc_67C6
; ---------------------------------------------------------------------------

loc_6396:                               ; ...
                jmp     loc_663E
; ---------------------------------------------------------------------------

loc_6399:                               ; ...
                push    ax
                mov     al, ds:facing_direction
                and     al, 1
                cmp     al, ds:byte_9F24
                mov     ds:byte_9F24, al
                jz      short loc_63AB
                call    init_horizontal_sliding

loc_63AB:                               ; ...
                pop     ax
                mov     al, ah
                push    ax
                cmp     al, 2
                jnz     short loc_63B6
                call    down_pressed    ; down pressed

loc_63B6:                               ; ...
                pop     ax
                and     al, 0Ch
                cmp     al, 4
                jnz     short loc_63C0
                jmp     loc_663E
; ---------------------------------------------------------------------------

loc_63C0:                               ; ...
                cmp     al, 8
                jnz     short loc_63C7
                jmp     loc_67C6
; ---------------------------------------------------------------------------

loc_63C7:                               ; ...
                call    init_horizontal_sliding
                mov     al, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                or      al, ds:squat_flag
                jz      short loc_63D4
                retn
; ---------------------------------------------------------------------------

loc_63D4:                               ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                retn
state_machine_dispatcher endp


; =============== S U B R O U T I N E =======================================


hero_interaction_check proc near        ; ...
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_63E2
                retn
; ---------------------------------------------------------------------------

loc_63E2:                               ; ...
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_63EA
                retn
; ---------------------------------------------------------------------------

loc_63EA:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                mov     al, [si]        ; [e10c]=
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_63F5
                retn
; ---------------------------------------------------------------------------

loc_63F5:                               ; ...
                inc     si
                inc     si
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_63FF
                retn
; ---------------------------------------------------------------------------

loc_63FF:                               ; ...
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jz      short loc_640F
                jmp     hero_moves_left
; ---------------------------------------------------------------------------

loc_640F:                               ; ...
                jmp     hero_moves_right
hero_interaction_check endp


; =============== S U B R O U T I N E =======================================


hero_knockback_handler proc near        ; ...
                test    ds:byte_9F14, 0FFh
                jnz     short loc_641A
                retn
; ---------------------------------------------------------------------------

loc_641A:                               ; ...
                test    ds:byte_9F01, 0FFh
                jnz     short loc_6440
                mov     si, offset word_9F0E
                mov     al, [si]
                or      al, [si+1]
                mov     ah, [si+2]
                or      ah, [si+3]
                test    al, ah
                jz      short loc_643C
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_6440
                jmp     short loc_6463
; ---------------------------------------------------------------------------

loc_643C:                               ; ...
                or      al, al
                jnz     short loc_6463

loc_6440:                               ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_645B
                and     byte ptr ds:facing_direction, 11111100b
                or      byte ptr ds:facing_direction, 1
                mov     byte ptr ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:byte_FF1D, 0

loc_645B:                               ; ...
                call    move_hero_left_if_no_obstacles
                call    move_hero_left_if_no_obstacles
                jmp     short loc_6481
; ---------------------------------------------------------------------------

loc_6463:                               ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_6479
                and     byte ptr ds:facing_direction, 11111100b
                mov     byte ptr ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:byte_FF1D, 0

loc_6479:                               ; ...
                call    move_hero_right_if_no_obstacles
                call    move_hero_right_if_no_obstacles
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_6481:                               ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_6492  ;
                                        ; was on rope, hit by monster
                mov     byte ptr ds:on_rope_flags, 80h ; transition rope -> ground
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope

loc_6492:                               ; ...
                test    ds:air_up_tile_found, 0FFh
                jz      short loc_649A
                retn
; ---------------------------------------------------------------------------

loc_649A:                               ; ...
                test    byte ptr ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_64A2
                retn
; ---------------------------------------------------------------------------

loc_64A2:                               ; ...
                call    check_floor_for_landing
                jnb     short loc_64A8
                retn
; ---------------------------------------------------------------------------

loc_64A8:                               ; ...
                test    ds:byte_9F09, 0FFh
                jnz     short loc_64B2
                jmp     hero_scroll_down
; ---------------------------------------------------------------------------

loc_64B2:                               ; ...
                dec     ds:byte_9F09
                inc     byte ptr ds:hero_head_y_in_viewport
                retn
hero_knockback_handler endp


; =============== S U B R O U T I N E =======================================


sliding_physics_step proc near          ; ...
                call    set_zero_flag_if_slippery
                jz      short loc_64C1
                retn                    ; not slippery
; ---------------------------------------------------------------------------

loc_64C1:                               ; ...
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short on_ground
                retn
; ---------------------------------------------------------------------------

on_ground:                              ; ...
                test    ds:slide_ticks_remaining, 0FFh
                jnz     short loc_64D1
                retn
; ---------------------------------------------------------------------------

loc_64D1:                               ; ...
                dec     ds:slide_ticks_remaining
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1      ; points to tile under feet
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]
                cmp     al, 40h ; '@'
                jb      short loc_64EE
                cmp     al, 49h ; 'I'
                jnb     short loc_64EE
                mov     ds:slide_ticks_remaining, 0
                retn
; ---------------------------------------------------------------------------

loc_64EE:                               ; ...
                mov     al, ds:byte_9F22 ; slide_direction: 1 = right, 2 = left
                test    ds:byte_9F23, 1 ; slide_direction_flags: Bit 0 = slide direction from previous tick
                jz      short loc_6500
                cmp     al, 1
                jnz     short loc_64FD
                retn
; ---------------------------------------------------------------------------

loc_64FD:                               ; ...
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

loc_6500:                               ; ...
                cmp     al, 2
                jnz     short loc_6505
                retn
; ---------------------------------------------------------------------------

loc_6505:                               ; ...
                jmp     move_hero_left_if_no_obstacles
sliding_physics_step endp


; =============== S U B R O U T I N E =======================================


init_horizontal_sliding proc near       ; ...
                call    set_zero_flag_if_slippery
                jz      short loc_650E
                retn
; ---------------------------------------------------------------------------

loc_650E:                               ; ...
                test    ds:slide_ticks_remaining, 0FFh
                jz      short loc_6516
                retn
; ---------------------------------------------------------------------------

loc_6516:                               ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_651E
                retn
; ---------------------------------------------------------------------------

loc_651E:                               ; ...
                mov     al, ds:horiz_movement_sub_tile_accum
                shr     al, 1
                or      al, al
                jnz     short loc_6528
                retn
; ---------------------------------------------------------------------------

loc_6528:                               ; ...
                cmp     al, 0Ah
                jb      short loc_652E
                mov     al, 0Ah

loc_652E:                               ; ...
                mov     ds:slide_ticks_remaining, al
                mov     ds:horiz_movement_sub_tile_accum, 0
                retn
init_horizontal_sliding endp


; =============== S U B R O U T I N E =======================================


up_pressed      proc near               ; ...
                mov     ds:byte_9F18, 0
                call    try_door_interaction
                call    try_move_platform_up
                call    try_climb_rope
up_pressed      endp


; =============== S U B R O U T I N E =======================================


jump_press_handler proc near            ; ...
                inc     ds:slide_ticks_remaining
                cmp     ds:slide_ticks_remaining, 0Ah
                jb      short loc_6555
                mov     ds:slide_ticks_remaining, 0Ah

loc_6555:                               ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short on_ground1
                retn
; ---------------------------------------------------------------------------

on_ground1:                              ; ...
                mov     byte ptr ds:squat_flag, 0
                mov     al, ds:byte_9F09
                cmp     al, ds:feruza_shoes_four_else_two
                jnb     short loc_65BA
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                sub     si, 35          ; x++, y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_65A5
                mov     byte ptr ds:hero_animation_phase, 0
                and     byte ptr ds:facing_direction, 11111101b ; clear Down direction
                mov     byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     al, ds:feruza_shoes_four_else_two
                shr     al, 1
                mov     ds:height_above_ground, al
                inc     ds:byte_9F09
                cmp     byte ptr ds:hero_head_y_in_viewport, 7
                jnb     short simple_jump
                jmp     move_hero_up
; ---------------------------------------------------------------------------

simple_jump:                            ; ...
                dec     byte ptr ds:hero_head_y_in_viewport
                retn
; ---------------------------------------------------------------------------

loc_65A5:                               ; ...
                test    ds:byte_9F09, 0FFh
                jnz     short loc_65BA
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_65B4
                retn
; ---------------------------------------------------------------------------

loc_65B4:                               ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                retn
; ---------------------------------------------------------------------------

loc_65BA:                               ; ...
                mov     byte ptr ds:slope_direction, 0
                mov     byte ptr ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                retn
jump_press_handler endp


; =============== S U B R O U T I N E =======================================


try_climb_rope  proc near               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                inc     si
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short climb_to_rope_from_ground
                dec     si
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jnb     short loc_65DC
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_663E
                retn
; ---------------------------------------------------------------------------

loc_65DC:                               ; ...
                inc     si
                inc     si
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short loc_65E4
                retn
; ---------------------------------------------------------------------------

loc_65E4:                               ; ...
                test    byte ptr ds:facing_direction, 1
                jnz     short locret_65EE
                jmp     loc_67C6
; ---------------------------------------------------------------------------

locret_65EE:                            ; ...
                retn
; ---------------------------------------------------------------------------

climb_to_rope_from_ground:              ; ...
                mov     byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                mov     byte ptr ds:squat_flag, 0

loc_65F9:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                sub     si, 35
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                dec     byte ptr ds:hero_animation_phase
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short loc_6611
                or      byte ptr ds:hero_animation_phase, 1
                retn
; ---------------------------------------------------------------------------

loc_6611:                               ; ...
                call    move_hero_up
                call    main_update_render
                test    byte ptr ds:hero_animation_phase, 1
                jz      short loc_661F
                retn
; ---------------------------------------------------------------------------

loc_661F:                               ; ...
                jmp     short loc_65F9
try_climb_rope  endp


; =============== S U B R O U T I N E =======================================


move_hero_up    proc near               ; ...
                dec     byte ptr ds:viewport_top_row_y ; hero goes up
                mov     si, ds:viewport_top_offset ; viewport goes up too
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     ds:viewport_top_offset, si
                retn
move_hero_up    endp


; =============== S U B R O U T I N E =======================================


left_up_pressed proc near               ; ...
                mov     ds:byte_9F0B, 0FFh
                call    jump_press_handler
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_663E:                               ; ...
                mov     ds:byte_9F18, 0
                test    byte ptr ds:facing_direction, left
                jnz     short loc_664D
                jmp     flip_facing_direction
; ---------------------------------------------------------------------------

loc_664D:                               ; ...
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_6655
                retn
; ---------------------------------------------------------------------------

loc_6655:                               ; ...
                cmp     byte ptr ds:slope_direction, slope_right
                jnz     short loc_665F
                jmp     loc_6837
; ---------------------------------------------------------------------------

loc_665F:                               ; ...
                call    move_hero_left_if_no_obstacles
                jnb     short loc_6667
                jmp     loc_6837
; ---------------------------------------------------------------------------

loc_6667:                               ; ...
                mov     ds:byte_9F22, 2
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_6674
                retn
; ---------------------------------------------------------------------------

loc_6674:                               ; ...
                call    set_zero_flag_if_slippery
                jnz     short loc_6689
                test    ds:slide_ticks_remaining, 0FFh
                jnz     short loc_6689
                mov     ds:byte_9F23, 0
                inc     ds:horiz_movement_sub_tile_accum

loc_6689:                               ; ...
                or      byte ptr ds:facing_direction, 10b
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short on_ground2
                retn
; ---------------------------------------------------------------------------

on_ground2:                              ; ...
                inc     byte ptr ds:hero_animation_phase
                and     byte ptr ds:hero_animation_phase, 7Fh
                mov     ds:byte_9F19, 0
                retn
left_up_pressed endp


; =============== S U B R O U T I N E =======================================


move_hero_left_if_no_obstacles proc near ; ...
                call    hero_coords_to_proximity_map_offset ; =0xe10c
                mov     di, si
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                dec     si              ; =0xe0e7
                mov     cx, 4

check_4_tiles_to_the_left_of_hero:      ; ...
                call    get_dst_monster_flags ; =0x4a, 0x58, 0x5a, 0x5c
                add     al, al          ; monsters in the proximity map has bit 7 set
                jnb     short loc_66BC
                retn                    ; monster to the left of hero, can't move
; ---------------------------------------------------------------------------

loc_66BC:                               ; ...
                add     si, 36          ; 0xe10b
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                loop    check_4_tiles_to_the_left_of_hero
                xchg    di, si
                test    byte ptr ds:squat_flag, 0FFh ; =0
                jnz     short loc_66DC
                mov     al, [si]        ; tile where hero head will come
                call    is_non_blocking_tile ; ZF if can pass
                stc
                jz      short loc_66D6
                retn
; ---------------------------------------------------------------------------

loc_66D6:                               ; ...
                call    NC_can_pass_except_category2
                jnb     short loc_66DC
                retn
; ---------------------------------------------------------------------------

loc_66DC:                               ; ...
                mov     cx, 2

loc_66DF:                               ; ...
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]        ; map element (tile)
                call    is_non_blocking_tile_simple
                stc
                jz      short loc_66EE
                retn
; ---------------------------------------------------------------------------

loc_66EE:                               ; ...
                push    cx
                call    NC_can_pass_except_category2
                pop     cx
                jnb     short loc_66F6
                retn
; ---------------------------------------------------------------------------

loc_66F6:                               ; ...
                loop    loc_66DF

hero_moves_left:                        ; ...
                dec     word ptr ds:proximity_map_left_col_x
                cmp     word ptr ds:proximity_map_left_col_x, 0FFFFh
                jnz     short proximity_map_scrolls_right ; no wrap
                mov     ax, ds:mapWidth ; wrap to end of map
                dec     ax
                mov     ds:proximity_map_left_col_x, ax ; mapWidth - 1
                mov     si, ds:packed_map_end_ptr ; end of packed map + 1
                mov     ds:packed_map_ptr_for_hero_x_minus_18, si

proximity_map_scrolls_right:            ; ...
                push    cs              ; free left column of proximity map
                pop     es
                std
                mov     si, offset proximity_map+36*64-2
                mov     di, offset proximity_map+36*64-1
                mov     cx, 36*64-1
                rep movsb
                cld
                mov     si, ds:packed_map_ptr_for_hero_x_minus_18
                dec     si              ; points to the last byte of packed column
                mov     di, offset proximity_map+36*(64-1) ; last row, leftmost column
                xor     dl, dl          ; y = 0

fill_column_backward:                   ; ...
                call    unpack_step_backward
                dec     si
                add     dl, bh          ; y += count

repeat_bh_times:                        ; ...
                mov     [di], bl        ; tile
                sub     di, 36          ; move up one row
                dec     bh
                jnz     short repeat_bh_times
                cmp     dl, 64
                jb      short fill_column_backward
                inc     si
                mov     ds:packed_map_ptr_for_hero_x_minus_18, si
                mov     si, ds:packed_map_end_ptr
                dec     si              ; end of packed map
                mov     ax, ds:proximity_map_left_col_x ; already decremented and wrapped
                add     ax, 36          ; hero_x_plus_18_abs
                cmp     ax, ds:mapWidth
                jz      short no_column_skip_needed ;
                                        ; we need to prepare pointer also for unpacking rightmost column of proximity map
                                        ; they both need to be in sync (36 columns apart)
                mov     si, ds:packed_map_ptr_for_hero_x_plus_18
                xor     dh, dh          ; y = 0

skip_bh_times:                          ; ...
                call    unpack_step_backward
                dec     si
                add     dh, bh          ; y += count
                cmp     dh, 64
                jb      short skip_bh_times

no_column_skip_needed:                  ; ...
                mov     ds:packed_map_ptr_for_hero_x_plus_18, si
                call    every_projectile_moves_right_in_viewport ; x coord in viewport increases
                mov     bx, ds:proximity_map_left_col_x
                mov     byte ptr ds:monster_index, 0
                mov     si, ds:monsters_table_addr

next_monster:                           ; ...
                mov     ax, [si+monster.currX]
                cmp     ax, 0FFFFh      ; end of monsters marker
                jnz     short loc_6782
                retn
; ---------------------------------------------------------------------------

loc_6782:                               ; ...
                cmp     ah, 0FFh        ; special 'monster'
                jz      short skip_monster
                cmp     ax, bx          ; only process monsters on the left proximity margin
                jnz     short skip_monster
                xor     ah, ah          ; x relative to left proximity margin = 0
                mov     al, [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, ds:monster_index
                or      al, 80h
                mov     [di], al

skip_monster:                           ; ...
                inc     byte ptr ds:monster_index
                add     si, 10h
                jmp     short next_monster
move_hero_left_if_no_obstacles endp


; =============== S U B R O U T I N E =======================================


NC_can_pass_except_category2 proc near  ; ...
                cmp     ds:cavern_level, 7 ; Exception: MP73.MDT (The Hut) has level 1
                clc
                jnz     short loc_67AC
                retn
; ---------------------------------------------------------------------------

loc_67AC:                               ; ...
                mov     al, [si]
                push    si
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                pop     si
                cmp     cl, 2
                stc
                jnz     short loc_67BA
                retn
; ---------------------------------------------------------------------------

loc_67BA:                               ; ...
                clc
                retn
NC_can_pass_except_category2 endp


; =============== S U B R O U T I N E =======================================


right_up_pressed proc near              ; ...
                mov     ds:byte_9F0B, 0FFh
                call    jump_press_handler
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_67C6:                               ; ...
                mov     ds:byte_9F18, 0
                test    byte ptr ds:facing_direction, 1
                jnz     short flip_facing_direction
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_67DA
                retn
; ---------------------------------------------------------------------------

loc_67DA:                               ; ...
                cmp     byte ptr ds:slope_direction, 2
                jz      short loc_6837
                call    move_hero_right_if_no_obstacles
                jb      short loc_6837
                mov     ds:byte_9F22, 1
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_67F3
                retn
; ---------------------------------------------------------------------------

loc_67F3:                               ; ...
                call    set_zero_flag_if_slippery
                jnz     short loc_6808
                test    ds:slide_ticks_remaining, 0FFh
                jnz     short loc_6808
                mov     ds:byte_9F23, 1
                inc     ds:horiz_movement_sub_tile_accum

loc_6808:                               ; ...
                or      byte ptr ds:facing_direction, 2
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_6815
                retn
; ---------------------------------------------------------------------------

loc_6815:                               ; ...
                inc     byte ptr ds:hero_animation_phase
                and     byte ptr ds:hero_animation_phase, 7Fh
                mov     ds:byte_9F19, 0
                retn
right_up_pressed endp


; =============== S U B R O U T I N E =======================================


flip_facing_direction proc near         ; ...
                xor     byte ptr ds:facing_direction, 1
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short on_ground3
                retn
; ---------------------------------------------------------------------------

on_ground3:                              ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                retn
; ---------------------------------------------------------------------------

loc_6837:                               ; ...
                and     byte ptr ds:facing_direction, 11111101b ; clear Up
                mov     al, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                or      al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_6846
                retn
; ---------------------------------------------------------------------------

loc_6846:                               ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                retn
flip_facing_direction endp


; =============== S U B R O U T I N E =======================================


move_hero_right_if_no_obstacles proc near ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                inc     si
                inc     si              ; x+=2
                mov     di, si
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     cx, 4

loc_685C:                               ; ...
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                add     al, al
                jnb     short loc_6864
                retn
; ---------------------------------------------------------------------------

loc_6864:                               ; ...
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                loop    loc_685C
                xchg    di, si
                test    byte ptr ds:squat_flag, 0FFh
                jnz     short loc_6884
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                stc
                jz      short loc_687E
                retn
; ---------------------------------------------------------------------------

loc_687E:                               ; ...
                call    NC_can_pass_except_category1
                jnb     short loc_6884
                retn
; ---------------------------------------------------------------------------

loc_6884:                               ; ...
                mov     cx, 2

loc_6887:                               ; ...
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]
                call    is_non_blocking_tile_simple
                stc
                jz      short loc_6896
                retn
; ---------------------------------------------------------------------------

loc_6896:                               ; ...
                push    cx
                call    NC_can_pass_except_category1
                pop     cx
                jnb     short loc_689E
                retn
; ---------------------------------------------------------------------------

loc_689E:                               ; ...
                loop    loc_6887

hero_moves_right:                       ; ...
                inc     word ptr ds:proximity_map_left_col_x
                mov     ax, ds:proximity_map_left_col_x
                add     ax, 36-1
                cmp     ax, ds:mapWidth
                jnz     short proximity_map_scrolls_left
                mov     ds:packed_map_ptr_for_hero_x_plus_18, (offset packed_map_end_ptr+1)

proximity_map_scrolls_left:             ; ...
                push    cs
                pop     es
                mov     si, offset proximity_map+1
                mov     di, offset proximity_map
                mov     cx, 36*64-1
                rep movsb
                mov     si, ds:packed_map_ptr_for_hero_x_plus_18 ; =c7e7
                inc     si
                mov     di, offset proximity_map+36-1 ; right column offset
                call    unpack_column
                dec     si
                mov     ds:packed_map_ptr_for_hero_x_plus_18, si
                mov     ax, ds:proximity_map_left_col_x
                cmp     ax, ds:mapWidth
                jnz     short loc_68E7
                mov     word ptr ds:proximity_map_left_col_x, 0
                mov     si, offset packed_map_start
                jmp     short loc_68F8
; ---------------------------------------------------------------------------

loc_68E7:                               ; ...
                mov     si, ds:packed_map_ptr_for_hero_x_minus_18
                xor     dh, dh

unpack_left_column:                     ; ...
                call    unpack_step_forward ; unpack extra column to /dev/null
                inc     si
                add     dh, bh
                cmp     dh, 40h ; '@'
                jb      short unpack_left_column ; unpack extra column to /dev/null

loc_68F8:                               ; ...
                mov     ds:packed_map_ptr_for_hero_x_minus_18, si
                call    every_projectile_moves_left_in_viewport
                mov     byte ptr ds:monster_index, 0
                mov     bx, ds:proximity_map_left_col_x
                add     bx, 36-1
                mov     ax, bx
                sub     ax, ds:mapWidth
                jb      short loc_6915
                mov     bx, ax

loc_6915:                               ; ...
                mov     si, ds:monsters_table_addr

next_monster1:                           ; ...
                mov     ax, [si]
                cmp     ax, 0FFFFh
                jnz     short loc_6921
                retn                    ; monsters end marker
; ---------------------------------------------------------------------------

loc_6921:                               ; ...
                cmp     ah, 0FFh
                jz      short loc_6939
                cmp     ax, bx
                jnz     short loc_6939
                mov     ah, 35
                mov     al, [si+2]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, ds:monster_index
                or      al, 80h
                mov     [di], al

loc_6939:                               ; ...
                inc     byte ptr ds:monster_index
                add     si, 10h
                jmp     short next_monster1
move_hero_right_if_no_obstacles endp


; =============== S U B R O U T I N E =======================================


NC_can_pass_except_category1 proc near  ; ...
                cmp     ds:cavern_level, 7
                clc
                jnz     short loc_694B
                retn
; ---------------------------------------------------------------------------

loc_694B:                               ; ...
                mov     al, [si]
                push    si
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                pop     si
                dec     cl
                stc
                jnz     short loc_6958
                retn
; ---------------------------------------------------------------------------

loc_6958:                               ; ...
                clc
                retn
NC_can_pass_except_category1 endp


; =============== S U B R O U T I N E =======================================


airborne_movement proc near             ; ...
                test    ds:air_up_tile_found, 0FFh
                jz      short loc_6962
                retn
; ---------------------------------------------------------------------------

loc_6962:                               ; ...
                test    byte ptr ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short loc_696A
                retn
; ---------------------------------------------------------------------------

loc_696A:                               ; ...
                call    hero_collapse_platform
                call    slope_assist_on_landing
                call    check_floor_for_landing
                jnb     short loc_6978
                jmp     land_after_jump
; ---------------------------------------------------------------------------

loc_6978:                               ; ...
                inc     ds:jump_height_counter
                test    ds:byte_9F09, 0FFh
                jz      short loc_698D
                pushf
                dec     ds:byte_9F09
                inc     byte ptr ds:hero_head_y_in_viewport
                popf

loc_698D:                               ; ...
                pop     ax
                jnz     short loc_6993  ;
                                        ; fall off cliff
                call    hero_scroll_down

loc_6993:                               ; ...
                test    byte ptr ds:facing_direction, 2 ; 03 when walked left
                jnz     short loc_69AE
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 36*2+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jnb     short loc_69AE
                mov     byte ptr ds:on_rope_flags, 0FFh ; hang on rope by walking
                retn
; ---------------------------------------------------------------------------

loc_69AE:                               ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                mov     al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:jump_phase_flags, 7Fh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                test    byte ptr ds:slope_direction, 0FFh
                jz      short loc_69C3
                retn
; ---------------------------------------------------------------------------

loc_69C3:                               ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_69CB
                retn
; ---------------------------------------------------------------------------

loc_69CB:                               ; ...
                test    al, 0FFh
                jnz     short read_keys_buffer
                mov     ax, offset loc_69E0
                push    ax
                test    byte ptr ds:facing_direction, 1
                jz      short loc_69DD
                jmp     loc_663E
; ---------------------------------------------------------------------------

loc_69DD:                               ; ...
                jmp     loc_67C6
; ---------------------------------------------------------------------------

loc_69E0:                               ; ...
                and     byte ptr ds:facing_direction, 11111101b
                retn
; ---------------------------------------------------------------------------

read_keys_buffer:                       ; ...
                int     61h             ; ah: 0FF16h   ; Alt_Space
                                        ; al: 0FF17h   ; right_left_down_up
                and     al, 1100b
                cmp     al, 100b
                jz      short left_pressed
                cmp     al, 1000b
                jz      short right_pressed

loc_69F2:                               ; ...
                test    byte ptr ds:facing_direction, UP
                jnz     short loc_6A02
                cmp     al, 100b
                jz      short loc_6A4A
                cmp     al, 1000b
                jz      short loc_6A1E
                retn
; ---------------------------------------------------------------------------

loc_6A02:                               ; ...
                test    byte ptr ds:facing_direction, LEFT
                jz      short loc_6A0C
                jmp     loc_663E
; ---------------------------------------------------------------------------

loc_6A0C:                               ; ...
                jmp     loc_67C6
; ---------------------------------------------------------------------------

left_pressed:                           ; ...
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_69F2
                and     byte ptr ds:facing_direction, 11111101b
                call    flip_facing_direction

loc_6A1E:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jz      short loc_6A2F
                retn
; ---------------------------------------------------------------------------

loc_6A2F:                               ; ...
                inc     si
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_6A38
                retn
; ---------------------------------------------------------------------------

loc_6A38:                               ; ...
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

right_pressed:                          ; ...
                test    byte ptr ds:facing_direction, 1
                jz      short loc_69F2
                and     byte ptr ds:facing_direction, 11111101b
                call    flip_facing_direction

loc_6A4A:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jz      short loc_6A5B
                retn
; ---------------------------------------------------------------------------

loc_6A5B:                               ; ...
                dec     si
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_6A64
                retn
; ---------------------------------------------------------------------------

loc_6A64:                               ; ...
                jmp     move_hero_left_if_no_obstacles
airborne_movement endp


; =============== S U B R O U T I N E =======================================


slope_assist_on_landing proc near       ; ...
                mov     byte ptr ds:slope_direction, 0
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 2*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    get_slope_direction_by_tile_under_feet ; NZ: no slope
                                        ; ZF dl=1: right slope \
                                        ; ZF dl=2: left slope /
                jz      short loc_6A7B
                retn                    ; no slope
; ---------------------------------------------------------------------------

loc_6A7B:                               ; ...
                and     byte ptr ds:facing_direction, 11111101b
                mov     ds:slope_direction, dl
                test    ds:height_above_ground, 0FFh
                jnz     short check_silkarn_shoes_and_slopes
                mov     al, ds:ticks
                inc     ds:ticks
                and     al, 3           ; every 4th tick
                jz      short time_to_check_sliding_down ; ah: 0FF16h   ; Alt_Space
                                        ; al: 0FF17h   ; right_left_down_up
                retn
; ---------------------------------------------------------------------------

time_to_check_sliding_down:             ; ...
                int     61h             ; reserved for user interrupt
                cmp     byte ptr ds:slope_direction, slope_right
                jz      short right_slope
                test    al, 1000b       ; left slope, check Right keypress
                jz      short slide_off_leftwards
                retn                    ; right pressed on left slope - no slide
; ---------------------------------------------------------------------------

slide_off_leftwards:                    ; ...
                jmp     move_hero_left_if_no_obstacles
; ---------------------------------------------------------------------------

right_slope:                            ; ...
                test    al, 100b
                jz      short no_left_pressed
                retn                    ; left pressed on right slope - no slide
; ---------------------------------------------------------------------------

no_left_pressed:                        ; ...
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

check_silkarn_shoes_and_slopes:         ; ...
                mov     al, ds:current_accessory
                cmp     al, SHOES_SILKARN
                jnz     short no_silkarn_shoes_slide_off_slope
                retn                    ; silkarn shoes - no slide
; ---------------------------------------------------------------------------

no_silkarn_shoes_slide_off_slope:       ; ...
                dec     ds:height_above_ground
                cmp     byte ptr ds:slope_direction, slope_right
                jnz     short loc_6AC6
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

loc_6AC6:                               ; ...
                jmp     move_hero_left_if_no_obstacles
slope_assist_on_landing endp


; =============== S U B R O U T I N E =======================================


down_pressed    proc near               ; ...
                mov     ds:byte_9F18, 0
                test    byte ptr ds:slope_direction, 0FFh
                jz      short climb_off_rope_to_ground
                retn
; ---------------------------------------------------------------------------

climb_off_rope_to_ground:               ; ...
                call    move_platform_down_damage_monster
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 109         ; 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    is_over_rope    ; set CF if [si] is rope (0 or 1)
                jb      short loc_6B04  ;
                                        ; no more over rope
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_6AF9  ;
                                        ; was on rope
                mov     byte ptr ds:on_rope_flags, 80h ; ff -> 80h
                                        ; transition rope -> ground
                mov     byte ptr ds:jump_phase_flags, 80h ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                retn
; ---------------------------------------------------------------------------

loc_6AF9:                               ; ...
                mov     ds:frame_ticks, 0
                mov     byte ptr ds:squat_flag, 0FFh
                retn
; ---------------------------------------------------------------------------

loc_6B04:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 109         ; 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                inc     byte ptr ds:hero_animation_phase
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jz      short loc_6B1E
                or      byte ptr ds:hero_animation_phase, 1
                retn
; ---------------------------------------------------------------------------

loc_6B1E:                               ; ...
                call    hero_scroll_down
                call    main_update_render
                test    byte ptr ds:hero_animation_phase, 1
                jz      short loc_6B2C
                retn
; ---------------------------------------------------------------------------

loc_6B2C:                               ; ...
                jmp     short loc_6B04
down_pressed    endp


; =============== S U B R O U T I N E =======================================


hero_scroll_down proc near              ; ...
                inc     byte ptr ds:viewport_top_row_y ; hero goes down
                mov     si, ds:viewport_top_offset ; viewport goes down too
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     ds:viewport_top_offset, si
                retn
hero_scroll_down endp


; =============== S U B R O U T I N E =======================================


land_after_jump proc near               ; ...
                mov     al, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                xor     al, 7Fh
                jz      short loc_6B49
                retn
; ---------------------------------------------------------------------------

loc_6B49:                               ; ...
                pop     ax              ; will return to
                mov     dl, ds:jump_height_counter
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     ds:frame_ticks, 0
                mov     ds:jump_height_counter, 0
                mov     byte ptr ds:hero_animation_phase, 80h
                test    byte ptr ds:slope_direction, 0FFh
                jz      short loc_6B6A
                retn
; ---------------------------------------------------------------------------

loc_6B6A:                               ; ...
                cmp     dl, 2
                jnb     short squat_after_landing_from_big_height
                retn
; ---------------------------------------------------------------------------

squat_after_landing_from_big_height:    ; ...
                mov     byte ptr ds:squat_flag, 0FFh
                retn
land_after_jump endp


; =============== S U B R O U T I N E =======================================


check_floor_for_landing proc near       ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1      ; directly under feet
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     di, si
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                add     al, al          ; monsters have bit 7 set
                jnb     short loc_6B89
                retn                    ; CF: monster under feet
; ---------------------------------------------------------------------------

loc_6B89:                               ; ...
                dec     si              ; one tile left beneath hero
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                add     al, al
                jnb     short loc_6B92
                retn
; ---------------------------------------------------------------------------

loc_6B92:                               ; ...
                mov     si, di
                mov     al, [si]
                call    is_non_blocking_tile_simple
                stc
                jz      short loc_6B9D
                retn
; ---------------------------------------------------------------------------

loc_6B9D:                               ; ...
                cmp     byte ptr ds:hero_animation_phase, 80h
                clc
                jnz     short loc_6BA6
                retn
; ---------------------------------------------------------------------------

loc_6BA6:                               ; ...
                dec     si
                mov     al, [si]
                call    is_non_blocking_tile_simple
                clc
                jnz     short loc_6BB0
                retn
; ---------------------------------------------------------------------------

loc_6BB0:                               ; ...
                inc     si
                inc     si
                mov     al, [si]
                call    is_non_blocking_tile_simple
                stc
                jz      short loc_6BBB
                retn
; ---------------------------------------------------------------------------

loc_6BBB:                               ; ...
                clc
                retn
check_floor_for_landing endp


; =============== S U B R O U T I N E =======================================

; set CF if [si] is rope (0 or 1)

is_over_rope    proc near               ; ...
                mov     al, [si]
                dec     al              ; al=1 or 2
                cmp     al, 2           ; al=0,1 => CF
                retn
is_over_rope    endp


; =============== S U B R O U T I N E =======================================

; NZ: no slope
; ZF dl=1: right slope \
; ZF dl=2: left slope /

get_slope_direction_by_tile_under_feet proc near ; ...
                mov     es, cs:game_segment
                assume es:nothing
                mov     al, [si]        ; tile under hero feet
                mov     di, 8018h       ; 0xB, 0, 0, 0 - left slope tile defined as 0xb
                mov     dl, 2           ; try left slope
                mov     cx, 4

loc_6BD3:                               ; ...
                test    byte ptr es:[di], 0FFh
                jz      short no_left_slope_defined
                cmp     al, es:[di]
                jnz     short loc_6BDF
                retn                    ; hero stays on left slope
; ---------------------------------------------------------------------------

loc_6BDF:                               ; ...
                inc     di
                loop    loc_6BD3

no_left_slope_defined:                  ; ...
                mov     di, 801Ch       ; 0xC, 0, 0, 0 - right slope tile defined as 0xc
                mov     dl, 1           ; try right slope
                mov     cx, 4

loc_6BEA:                               ; ...
                test    byte ptr es:[di], 0FFh
                jz      short no_right_slope_defined
                cmp     al, es:[di]
                jnz     short loc_6BF6
                retn                    ; hero stays on right slope
; ---------------------------------------------------------------------------

loc_6BF6:                               ; ...
                inc     di
                loop    loc_6BEA

no_right_slope_defined:                 ; ...
                or      dl, dl          ; NZ if no slope
                retn
get_slope_direction_by_tile_under_feet endp


; =============== S U B R O U T I N E =======================================

; if Cangrejo_Defeated then [c013]=ffff
; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
; if 'Wall, Blue Potion' taken then [d987]=0000
; if 'Door to Cangrejo open' then [d580]=0181
; if 'Door to Satono open' then [d5a4]=0280

remove_accomplished_items proc near     ; ...
                mov     si, ds:accomplished_items_checker

next_item:                              ; ...
                mov     di, [si]        ; addr to check against the mask
                cmp     di, 0FFFFh
                jnz     short loc_6C08
                retn
; ---------------------------------------------------------------------------

loc_6C08:                               ; ...
                add     si, 3
                mov     al, [si-1]      ; mask to check
                and     al, [di]        ; boss defeated?
                jnz     short move_loop

skip_loop:                              ; ...
                mov     di, [si]
                cmp     di, 0FFFFh
                jz      short loc_6C2F
                add     si, 4
                jmp     short skip_loop
; ---------------------------------------------------------------------------

move_loop:                              ; ...
                mov     di, [si]        ; =c013, d65e,
                cmp     di, 0FFFFh
                jz      short loc_6C2F
                mov     ax, [si+2]
                mov     [di], ax
                add     si, 4
                jmp     short move_loop
; ---------------------------------------------------------------------------

loc_6C2F:                               ; ...
                inc     si
                inc     si
                jmp     short next_item
remove_accomplished_items endp


; =============== S U B R O U T I N E =======================================


render_place_and_gold_labels proc near  ; ...
                mov     si, offset byte_6C44
                call    cs:Render_Pascal_String_0_proc
                mov     si, offset byte_6C4C
                call    cs:Render_Pascal_String_0_proc
                retn
render_place_and_gold_labels endp

; ---------------------------------------------------------------------------
byte_6C44       db 0Dh                  ; ...
                                        ; marginLeft
                db 0BBh                 ; marginTop
                db    1
aGold           db 4,'GOLD'
byte_6C4C       db 0Dh                  ; ...
                                        ; marginLeft
                db 0AFh                 ; marginTop
                db    1
aPlace          db 5,'PLACE'

; =============== S U B R O U T I N E =======================================


render_hud_bars_with_enemy proc near    ; ...
                mov     bx, 210h
                xor     al, al
                mov     ch, 21h ; '!'
                call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
                                        ; bl: paddingTop
                                        ; al: masking mode
                mov     bx, 2310h
                mov     al, 80h
                mov     ch, 67h ; 'g'
                call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
                                        ; bl: paddingTop
                                        ; al: masking mode
                mov     bx, 0AA9h
                mov     dx, 0AB5h
                mov     cx, 0E03h
                call    cs:word_202C
                mov     bx, 21Ch
                xor     al, al
                mov     ch, 42h ; 'B'
                call    cs:Clear_HUD_Bar_proc ; bh: paddingLeft
                                        ; bl: paddingTop
                                        ; al: masking mode
                mov     si, offset byte_6C8F
                jmp     cs:Render_Pascal_String_0_proc
render_hud_bars_with_enemy endp

; ---------------------------------------------------------------------------
byte_6C8F       db 0Dh                  ; ...
                                        ; marginLeft
                db 0AFh                 ; marginTop
                db    2
aEnemy          db 5,'ENEMY'

; =============== S U B R O U T I N E =======================================


unpack_map      proc near               ; ...
                mov     si, offset packed_map_start ; unpack to /dev/null by columns, until the hero_x-18 position (proximity map left edge)
                                        ; 87 C4 45 C7 CA ...
                mov     cx, ds:proximity_map_left_col_x ; 002d
                or      cx, cx
                jz      short loc_6CB2

columns_skip_loop:                      ; ...
                xor     dh, dh          ; rows counter

loc_6CA5:                               ; ...
                call    unpack_step_forward
                inc     si
                add     dh, bh
                cmp     dh, 64          ; last row?
                jb      short loc_6CA5
                loop    columns_skip_loop

loc_6CB2:                               ; ...
                mov     ds:packed_map_ptr_for_hero_x_minus_18, si ; unpack 36 columns from the hero_x_minus_18
                mov     di, offset proximity_map ; unpacked proximity map
                mov     ax, ds:proximity_map_left_col_x ; in absolute map coords
                mov     cx, 36          ; proximity map width

columns_loop:                           ; ...
                push    di
                call    unpack_column
                pop     di
                inc     di
                inc     ax              ; x++
                cmp     ax, ds:mapWidth
                jnz     short loc_6CD1
                mov     si, offset packed_map_start ; continue from x=0 (map start)
                xor     ax, ax          ; x = 0

loc_6CD1:                               ; ...
                loop    columns_loop    ; fill 36 columns
                or      ax, ax          ; x in absolute map coords
                jnz     short loc_6CDB  ;
                                        ; last column of map unpacked
                mov     si, ds:packed_map_end_ptr

loc_6CDB:                               ; ...
                dec     si
                mov     ds:packed_map_ptr_for_hero_x_plus_18, si
                mov     al, ds:viewport_top_row_y ; 3d
                xor     ah, ah
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     ds:viewport_top_offset, di
                retn
unpack_map      endp


; =============== S U B R O U T I N E =======================================


unpack_step_forward proc near           ; ...
                mov     bl, [si]        ; 0,4,8,C
                and     bl, 0C0h
                rol     bl, 1
                rol     bl, 1
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_6CFA[bx]
unpack_step_forward endp

; ---------------------------------------------------------------------------
funcs_6CFA      dw offset unpack_forward_case0 ; ...
                dw offset unpack_case1
                dw offset unpack_case2
                dw offset unpack_case3

; =============== S U B R O U T I N E =======================================


unpack_step_backward proc near          ; ...
                mov     bl, [si]
                and     bl, 0C0h
                rol     bl, 1
                rol     bl, 1
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_6D13[bx]
unpack_step_backward endp

; ---------------------------------------------------------------------------
funcs_6D13      dw offset unpack_backward_case0 ; ...
                dw offset unpack_case1
                dw offset unpack_case2
                dw offset unpack_case3

; =============== S U B R O U T I N E =======================================


unpack_forward_case0 proc near          ; ...
                mov     bh, [si]        ; 00...... ........
                inc     bh              ; count = (byte & 3fh)+1
                inc     si
                mov     bl, [si]        ; tile = next_byte
                retn
unpack_forward_case0 endp


; =============== S U B R O U T I N E =======================================


unpack_backward_case0 proc near         ; ...
                mov     bl, [si]        ; only works if tile < 0x40
                dec     si
                mov     bh, [si]
                inc     bh
                retn
unpack_backward_case0 endp


; =============== S U B R O U T I N E =======================================


unpack_case1    proc near               ; ...
                mov     bl, [si]
                mov     bh, bl
                shr     bh, 1
                shr     bh, 1
                shr     bh, 1
                shr     bh, 1
                and     bh, 3
                add     bh, 2
                and     bl, 0Fh
                inc     bl
                retn
unpack_case1    endp


; =============== S U B R O U T I N E =======================================


unpack_case2    proc near               ; ...
                mov     bh, [si]
                and     bh, 3Fh
                xor     bl, bl
                retn
unpack_case2    endp


; =============== S U B R O U T I N E =======================================


unpack_case3    proc near               ; ...
                mov     bl, [si]
                and     bl, 3Fh
                mov     bh, 1
                retn
unpack_case3    endp


; =============== S U B R O U T I N E =======================================


unpack_column   proc near               ; ...
                xor     dl, dl          ; y=0

loc_6D59:                               ; ...
                call    unpack_step_forward
                inc     si
                add     dl, bh          ; column height

loc_6D5F:                               ; ...
                mov     [di], bl
                add     di, 36
                dec     bh
                jnz     short loc_6D5F
                cmp     dl, 64          ; 64 rows
                jb      short loc_6D59
                retn
unpack_column   endp


; =============== S U B R O U T I N E =======================================

; uint8_t y = AL
; uint8_t x = AH
; y &= 0x3F; // Clamp Y to 0-63
; uint16_t di = (y * 36) + x + 0xE000;

coords_in_ax_to_proximity_map_offset_in_di proc near ; ...
                push    bx
                and     al, 3Fh         ; y
                mov     bl, ah          ; x
                mov     bh, 36
                mul     bh              ; 36*y
                xor     bh, bh
                add     ax, bx
                add     ax, offset proximity_map
                mov     di, ax
                pop     bx
                retn
coords_in_ax_to_proximity_map_offset_in_di endp


; =============== S U B R O U T I N E =======================================

; if (si >= 0E900h) si -= 900h

wrap_map_from_above proc near           ; ...
                cmp     si, offset viewport_buffer_28x19
                jnb     short loc_6D89
                retn
; ---------------------------------------------------------------------------

loc_6D89:                               ; ...
                sub     si, 900h        ; 64*36
                retn
wrap_map_from_above endp


; =============== S U B R O U T I N E =======================================

; if (si < 0E000h) si += 900h

wrap_map_from_below proc near           ; ...
                cmp     si, 0E000h
                jb      short loc_6D95
                retn
; ---------------------------------------------------------------------------

loc_6D95:                               ; ...
                add     si, 900h        ; 64*36
                retn
wrap_map_from_below endp


; =============== S U B R O U T I N E =======================================


set_zero_flag_if_slippery proc near     ; ...
                cmp     ds:cavern_level, 4 ; danger type: slippery ground
                jz      short loc_6DA2
                retn                    ; NZ
; ---------------------------------------------------------------------------

loc_6DA2:                               ; ...
                cmp     byte ptr ds:current_accessory, SHOES_RUZERIA
                jnz     short no_ruzeria
                mov     al, 0FFh
                or      al, al
                retn                    ; NZ
; ---------------------------------------------------------------------------

no_ruzeria:                             ; ...
                xor     al, al
                retn                    ; ZF
set_zero_flag_if_slippery endp


; =============== S U B R O U T I N E =======================================

; Hero is 3x3 matrix. Return top-left coord in SI

hero_coords_to_proximity_map_offset proc near ; ...
                mov     al, ds:hero_head_y_in_viewport ; =0xa
                mov     cl, 36
                mul     cl              ; =0x168
                mov     cl, ds:hero_x_in_viewport ; =0xc
                add     cl, 4           ; =0x10; viewport left border starts +4 columns from the proximity map left edge
                xor     ch, ch
                add     ax, cx          ; =0x178
                mov     si, ax
                add     si, ds:viewport_top_offset ; +(0xe894 = 0xe000 + 36*61)
                jmp     short wrap_map_from_above ; if (si >= 0E900h) si -= 900h
hero_coords_to_proximity_map_offset endp


; =============== S U B R O U T I N E =======================================

; CF: no monster
; NC: active monster; al=type, bx=monster struct

get_dst_monster_flags proc near         ; ...
                mov     al, [si]
                test    al, 80h
                stc
                jnz     short monster_there
                retn                    ; CF, ZF if no monster
; ---------------------------------------------------------------------------

monster_there:                          ; ...
                and     al, 7Fh         ; monster id
                mov     cl, 10h         ; 16 bytes per monster
                mul     cl
                mov     bx, ax
                add     bx, ds:monsters_table_addr
                mov     al, [bx+monster.flags]
                or      al, al          ; NC, NZ if live monster (not item)
                retn
get_dst_monster_flags endp


; =============== S U B R O U T I N E =======================================

; ZF if can pass

is_non_blocking_tile proc near          ; ...
                cmp     al, 40h ; '@'
                jb      short lookup_shared
                cmp     al, al
                retn                    ; NZ: can't pass
is_non_blocking_tile endp


; =============== S U B R O U T I N E =======================================


is_non_blocking_tile_extended proc near ; ...
                cmp     al, 49h ; 'I'
                jb      short lookup_shared
                cmp     al, al
                retn
; ---------------------------------------------------------------------------

lookup_shared:                          ; ...
                push    di
                push    cx
                mov     es, cs:game_segment
                mov     di, 8000h       ; 00 01 02 08  09 0A 0B 0C  0F 10 11 12  13 14 15 16  17 18 19 00  00 00 00 00
                mov     cx, 24
                repne scasb
                pop     cx
                pop     di
                jnz     short loc_6E07
                retn                    ; ZF: one of passable tiles
; ---------------------------------------------------------------------------

loc_6E07:                               ; ...
                and     al, 9Fh
                cmp     al, 90h
                jz      short cant_pass
                cmp     al, 91h
                jz      short cant_pass
                and     al, 80h
                cmp     al, 80h
                retn
; ---------------------------------------------------------------------------

cant_pass:                              ; ...
                mov     al, 0FFh
                or      al, al
                retn                    ; NZ: cannot pass
is_non_blocking_tile_extended endp


; =============== S U B R O U T I N E =======================================


is_non_blocking_tile_simple proc near   ; ...
                cmp     al, 49h ; 'I'
                jb      short loc_6E22
                cmp     al, al
                retn
; ---------------------------------------------------------------------------

loc_6E22:                               ; ...
                push    di
                push    cx
                mov     es, cs:game_segment
                mov     di, 8000h
                mov     cx, 24
                repne scasb
                pop     cx
                pop     di
                jnz     short loc_6E36
                retn
; ---------------------------------------------------------------------------

loc_6E36:                               ; ...
                and     al, 80h
                cmp     al, 80h
                retn
is_non_blocking_tile_simple endp


; =============== S U B R O U T I N E =======================================


input_handling  proc near               ; ...
                test    byte ptr ds:sword_type, 0FFh ; sword present?
                jnz     short loc_6E43  ; ah: 0FF16h   ; Alt_Space
                                        ; al: 0FF17h   ; right_left_down_up
                retn                    ; no sword
; ---------------------------------------------------------------------------

loc_6E43:                               ; ...
                int     61h             ; reserved for user interrupt
                test    ah, 1
                jz      short sword_default ;
                                        ; space pressed
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jz      short sword_default ;
                                        ; space+up
                test    byte ptr ds:slope_direction, 0FFh
                jnz     short sword_default
                test    al, 10b         ; down
                jz      short sword_default ;
                                        ; space+up+down
                mov     byte ptr ds:sword_hit_type, 2 ; Ground downward thrust
                mov     byte ptr ds:sword_down_thrust, 2
                test    byte ptr ds:down_thrust_held_flag, 0FFh
                jz      short loc_6E70
                jmp     loc_6EF7
; ---------------------------------------------------------------------------

loc_6E70:                               ; ...
                mov     byte ptr ds:down_thrust_held_flag, 0FFh
                mov     byte ptr ds:soundFX_request, 4
                jmp     short loc_6EF7
; ---------------------------------------------------------------------------

sword_default:                          ; ...
                mov     byte ptr ds:down_thrust_held_flag, 0
                test    byte ptr ds:byte_FF1D, 0FFh
                jnz     short loc_6E89
                retn
; ---------------------------------------------------------------------------

loc_6E89:                               ; ...
                test    byte ptr ds:sword_swing_flag, 0FFh
                jz      short loc_6E91
                retn
; ---------------------------------------------------------------------------

loc_6E91:                               ; ...
                test    byte ptr ds:spell_active_flag, 0FFh
                jz      short loc_6E99
                retn
; ---------------------------------------------------------------------------

loc_6E99:                               ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jnz     short loc_6ED6
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                sub     si, 147         ; =E10C-(4*36+3) = E079
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xor     dl, dl
                mov     cx, 4

four_rows:                              ; ...
                push    cx
                mov     cx, 8

row_of_eight_tiles:                     ; ...
                push    cx
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jb      short no_monster ; no monster
                test    al, 1100000b    ; frog=8E => (8e & 7f)=0e
                jnz     short no_monster
                test    byte ptr [bx+7], 10h
                jnz     short no_monster
                mov     dl, 0FFh        ; monster found

no_monster:                             ; ...
                inc     si
                pop     cx
                loop    row_of_eight_tiles
                add     si, 28
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                pop     cx
                loop    four_rows
                or      dl, dl
                jnz     short loc_6EDC

loc_6ED6:                               ; ...
                int     61h             ; ah: 0FF16h   ; Alt_Space
                                        ; al: 0FF17h   ; right_left_down_up
                test    al, 1
                jz      short no_up_pressed ;
                                        ; up pressed

loc_6EDC:                               ; ...
                mov     byte ptr ds:sword_hit_type, 1 ; Overhead swing
                mov     byte ptr ds:sword_down_thrust, 0
                jmp     short loc_6EF2
; ---------------------------------------------------------------------------

no_up_pressed:                          ; ...
                mov     byte ptr ds:sword_hit_type, 0 ; Forward hit
                mov     byte ptr ds:sword_down_thrust, 0

loc_6EF2:                               ; ...
                mov     byte ptr ds:soundFX_request, 3

loc_6EF7:                               ; ...
                mov     byte ptr ds:byte_FF1D, 0
                mov     byte ptr ds:byte_FF1E, 0
                mov     byte ptr ds:sword_swing_flag, 0FFh
                retn
input_handling  endp


; =============== S U B R O U T I N E =======================================


apply_sword_hit_to_map_tiles proc near  ; ...
                test    byte ptr ds:sword_swing_flag, 0FFh
                jnz     short loc_6F0F
                retn
; ---------------------------------------------------------------------------

loc_6F0F:                               ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_6F1E
                test    byte ptr ds:boss_being_hit, 0FFh
                jz      short loc_6F1E
                retn
; ---------------------------------------------------------------------------

loc_6F1E:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                mov     bx, 4*36
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_6F2E
                mov     bx, 3*36

loc_6F2E:                               ; ...
                sub     si, bx
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     bl, ds:facing_direction
                and     bl, 1
                add     bl, bl
                add     bl, bl
                add     bl, bl
                add     bl, bl
                mov     al, ds:sword_hit_type
                mov     ah, 0
                or      al, al
                jz      short loc_6F57
                mov     ah, 6
                dec     al
                jz      short loc_6F57
                mov     al, bl
                add     al, 0Ah
                jmp     short loc_6F5E
; ---------------------------------------------------------------------------

loc_6F57:                               ; ...
                mov     al, ds:sword_down_thrust
                or      al, bl
                add     al, ah

loc_6F5E:                               ; ...
                and     al, 0FEh
                mov     bl, al
                xor     bh, bh
                mov     es, cs:game_segment
                mov     di, es:[bx+0B002h]

loc_6F6E:                               ; ...
                mov     al, es:[di]
                inc     di
                cmp     al, 0FFh
                jnz     short loc_6F77
                retn
; ---------------------------------------------------------------------------

loc_6F77:                               ; ...
                xor     ah, ah
                add     si, ax
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jb      short loc_6F6E
                test    al, 20h
                jnz     short loc_6F6E
                test    byte ptr [bx+5], 20h
                jnz     short loc_6F6E
                or      byte ptr [bx+5], 40h
                and     byte ptr [bx+5], 0E0h
                or      byte ptr [bx+5], 1
                jmp     short loc_6F6E
apply_sword_hit_to_map_tiles endp


; =============== S U B R O U T I N E =======================================


main_update_render proc near            ; ...
                mov     al, 2
                cmp     byte ptr ds:current_accessory, SHOES_FERUZA
                jnz     short no_feruza
                mov     al, 4

no_feruza:                              ; ...
                mov     ds:feruza_shoes_four_else_two, al
                call    check_airflows_on_hero
                test    byte ptr ds:jump_phase_flags, 0FFh ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jnz     short loc_6FD3
                mov     ds:byte_9F09, 0
                mov     al, ds:byte_9F00
                cmp     al, ds:hero_head_y_in_viewport
                jz      short loc_6FD3
                jb      short loc_6FCC
                call    move_hero_up
                inc     byte ptr ds:hero_head_y_in_viewport
                jmp     short loc_6FD3
; ---------------------------------------------------------------------------

loc_6FCC:                               ; ...
                call    hero_scroll_down
                dec     byte ptr ds:hero_head_y_in_viewport

loc_6FD3:                               ; ...
                test    byte ptr ds:is_jashiin_cavern, 0FFh
                jnz     short loc_6FE1
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_6FF9

loc_6FE1:                               ; ...
                mov     si, ds:word_A002
                add     si, 7
                mov     al, [si]
                cmp     ds:hero_x_in_viewport, al
                jz      short loc_7007
                call    move_hero_right_if_no_obstacles
                dec     byte ptr ds:hero_x_in_viewport
                jmp     short loc_7007
; ---------------------------------------------------------------------------

loc_6FF9:                               ; ...
                mov     al, ds:hero_x_in_viewport
                cmp     al, 0Ch
                jz      short loc_7007
                call    move_hero_left_if_no_obstacles
                inc     byte ptr ds:hero_x_in_viewport

loc_7007:                               ; ...
                mov     al, ds:hero_head_y_in_viewport ; hanging on rope, head at ground level: 0a
                add     al, ds:viewport_top_row_y ; 40h
                and     al, 3Fh
                mov     ds:hero_y_absolute, al ; hero Y absolute coord within the map
                call    update_boss_heartbeat_volume
                call    update_and_render_horiz_platforms
                call    render_vertical_platforms_to_proximity
                call    process_visible_collapsing_platforms
                call    process_doors
                call    dispatch_spell_projectile_movement
                test    byte ptr ds:boss_is_dead, 0FFh
                jnz     short loc_702F
                call    monsters_spawning

loc_702F:                               ; ...
                mov     byte ptr ds:hero_damage_this_frame, 0
                mov     ds:byte_9F14, 0
                call    check_hero_contact_damage
                call    cs:Flush_Ui_Element_If_Dirty_proc
                call    projectiles_collision_processing
                call    monsters_updates
                call    cs:Composite_Meta_Tile_Renderer_proc
                call    step_on_aggressive_ground
                cmp     ds:cavern_level, 7 ; danger type = temperature
                jnz     short skip_temperature_damage
                cmp     byte ptr ds:current_accessory, CAPE_ASBESTOS
                jz      short skip_temperature_damage
                inc     ds:temperature_timer
                test    ds:temperature_timer, 3Fh
                jnz     short skip_temperature_damage
                mov     byte ptr ds:hero_damage_this_frame, 0FFh
                mov     byte ptr ds:soundFX_request, 9
                mov     ax, 0Fh
                call    damage_hero     ; ax: damage level
                mov     dx, offset its_too_hot_str
                call    render_notification_string

skip_temperature_damage:                ; ...
                call    screen_flash_overlay
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short game_loop_render_and_timing
                mov     byte ptr ds:hero_damage_this_frame, 0
                jmp     short loc_7094
main_update_render endp


; =============== S U B R O U T I N E =======================================


game_loop_render_and_timing proc near   ; ...
                mov     byte ptr ds:hero_sprite_hidden, 0

loc_7094:                               ; ...
                mov     byte ptr ds:byte_FF40, 0
                test    byte ptr ds:sword_swing_flag, 0FFh
                jz      short loc_70B3
                mov     byte ptr ds:byte_FF40, 0FFh
                mov     al, ds:sword_hit_type
                mov     ds:byte_FF41, al
                mov     al, ds:sword_down_thrust
                mov     ds:byte_FF3F, al
                jmp     short loc_70CA
; ---------------------------------------------------------------------------

loc_70B3:                               ; ...
                test    byte ptr ds:spell_active_flag, 0FFh
                jz      short loc_70CA
                mov     byte ptr ds:byte_FF40, 0FFh
                mov     al, ds:byte_9F2B
                mov     ds:byte_FF3F, al
                mov     byte ptr ds:byte_FF41, 1

loc_70CA:                               ; ...
                test    byte ptr ds:hero_sprite_hidden, 0FFh
                jnz     short loc_70D4
                call    clear_hero_in_viewport

loc_70D4:                               ; ...
                call    cs:Sample_Neighborhood_Attributes_proc
                test    byte ptr ds:invincibility_flag, 0FFh
                jnz     short loc_710F
                mov     ax, ds:healing_potion_timer
                or      ax, ax
                jz      short loc_710F
                dec     ax
                mov     ds:healing_potion_timer, ax
                add     word ptr ds:hero_HP, 8   ; faster hp restoration
                mov     ax, ds:heroMaxHp
                cmp     ax, ds:hero_HP
                jnb     short loc_7105
                mov     ax, ds:heroMaxHp
                mov     ds:hero_HP, ax
                mov     word ptr ds:healing_potion_timer, 0

loc_7105:                               ; ...
                mov     byte ptr ds:soundFX_request, 13h
                call    cs:Draw_Hero_Health_proc

loc_710F:                               ; ...
                call    cs:Refresh_Dirty_Tiles_proc
                test    byte ptr ds:sprite_flash_flag, 0FFh
                jz      short loc_7125
                call    cs:Active_Entity_Sprite_Renderer_proc
                mov     byte ptr ds:byte_FF24, 0Ah

loc_7125:                               ; ...
                mov     cl, ds:speed_const
                mov     al, 2
                mul     cl

loc_712D:                               ; ...
                cmp     ds:frame_timer, al
                jb      short loc_712D
                call    monsters_updates
                call    cs:Flush_Ui_Element_If_Dirty_proc
                call    update_and_render_projectile_row_pair
                call    render_and_collision_pass_row
                call    update_active_projectiles_render
                call    apply_sword_hit_to_map_tiles
                call    cs:Composite_Meta_Tile_Renderer_proc
                mov     cl, ds:speed_const
                mov     al, 4
                mul     cl

loc_7154:                               ; ...
                push    ax
                call    cs:Confirm_Exit_Dialog_proc
                call    cs:Handle_Pause_State_proc
                call    cs:Handle_Speed_Change_proc
                call    cs:Joystick_Calibration_proc
                call    cs:Joystick_Deactivator_proc
                call    cs:Handle_Restore_Game_proc
                jnb     short loc_7178
                call    restore_game

loc_7178:                               ; ...
                pop     ax
                cmp     ds:frame_timer, al
                jb      short loc_7154
                mov     byte ptr ds:frame_timer, 0
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_718C
                retn
; ---------------------------------------------------------------------------

loc_718C:                               ; ...
                test    byte ptr ds:hero_invincibility, 0FFh
                jnz     short increase_hp
                test    word ptr ds:hero_HP, 0FFFFh
                jnz     short increase_hp
                jmp     process_hero_death
; ---------------------------------------------------------------------------

increase_hp:                            ; ...
                inc     ds:byte_9F18
                cmp     ds:byte_9F18, 16 ; increase hero HP by 2 every 16 time intervals
                jb      short loc_71C2
                mov     ds:byte_9F18, 0
                mov     ax, ds:hero_HP
                cmp     ax, ds:heroMaxHp
                jnb     short loc_71C2
                add     ax, 2           ; normal HP restoration speed
                mov     ds:hero_HP, ax
                call    cs:Draw_Hero_Health_proc

loc_71C2:                               ; ...
                test    ds:byte_9F1E, 0FFh
                jz      short loc_71CC
                jmp     load_place_and_reinit
; ---------------------------------------------------------------------------

loc_71CC:                               ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_71FA
                test    byte ptr ds:boss_is_dead, 0FFh
                jz      short loc_71FA
                cmp     ds:is_boss_dead, 0FFh
                jnz     short loc_71FA
                mov     si, ds:word_A002
                add     si, 5
                lodsw
                push    si
                call    update_hero_XP
                pop     si
                add     si, 4
                lodsw
                call    hero_got_almas  ; ax: almas to add
                mov     ds:byte_9F1E, 0FFh

loc_71FA:                               ; ...
                test    byte ptr ds:boss_being_hit, 0FFh
                jz      short loc_7202
                retn
; ---------------------------------------------------------------------------

loc_7202:                               ; ...
                test    word ptr ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, KEY_ENTER
                jnz     short bring_inventory_window
                mov     ds:byte_9EF5, 0
                retn
game_loop_render_and_timing endp


; =============== S U B R O U T I N E =======================================


screen_flash_overlay proc near          ; ...
                test    ds:byte_9EF0, 0FFh
                jz      short loc_7242
                mov     al, 0FCh
                inc     ds:byte_9EEE
                test    ds:byte_9EEE, 1Fh
                jnz     short loc_722B
                mov     al, 0FEh
                mov     ds:byte_9EF0, 0

loc_722B:                               ; ...
                push    cs
                pop     es
                mov     di, (offset viewport_buffer_28x19+21h) ; +(28+5)
                mov     cl, ds:byte_9EF1
                xor     ch, ch

loc_7236:                               ; ...
                push    cx
                mov     cx, 18
                rep stosb
                add     di, 10
                pop     cx
                loop    loc_7236

loc_7242:                               ; ...
                test    ds:byte_9EEF, 0FFh
                jnz     short loc_724A
                retn
; ---------------------------------------------------------------------------

loc_724A:                               ; ...
                mov     al, 0FCh
                inc     ds:byte_9EED
                and     ds:byte_9EED, 1Fh
                jnz     short loc_725E
                mov     al, 0FEh
                mov     ds:byte_9EEF, 0

loc_725E:                               ; ...
                push    ds
                pop     es
                assume es:nothing
                mov     di, (offset viewport_buffer_28x19+39h) ; +(2*28+1)
                mov     cx, 2

fill_viewport_2_lines:                  ; ...
                push    cx
                push    di
                mov     cx, 26
                rep stosb
                pop     di
                add     di, 28
                pop     cx
                loop    fill_viewport_2_lines
                retn
screen_flash_overlay endp


; =============== S U B R O U T I N E =======================================


bring_inventory_window proc near        ; ...
                mov     al, ds:byte_9EF5
                or      al, ds:spell_active_flag
                or      al, ds:byte_FF3E
                or      al, ds:byte_9F26
                jz      short loc_7287
                retn
; ---------------------------------------------------------------------------

loc_7287:                               ; ...
                mov     byte ptr ds:soundFX_request, 0Bh
                call    cs:Clear_Viewport_proc
                call    swap_eai_and_inventory_code_regions
                call    cs:Monster_AI_proc
                call    swap_eai_and_inventory_code_regions
                cmp     byte ptr ds:byte_FF4B, 8
                jnz     short loc_72A6
                jmp     loc_99E0
; ---------------------------------------------------------------------------

loc_72A6:                               ; ...
                call    cs:Clear_Viewport_proc
                push    ds
                call    cs:word_301A
                mov     cx, 18h
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                mov     ds:byte_9EF5, 0FFh
                call    clear_viewport_buffer
                mov     byte ptr ds:byte_FF1D, 0
                mov     byte ptr ds:byte_FF1E, 0
                mov     ds:byte_9EEF, 0
                mov     ds:byte_9EF0, 0
                jmp     main_update_render
bring_inventory_window endp


; =============== S U B R O U T I N E =======================================


swap_eai_and_inventory_code_regions proc near ; ...
                mov     es, cs:game_segment ; =1ac5
                mov     di, 0C000h      ; select.bin region (inventory)
                mov     si, 0A000h      ; eai{i}.bin region (enemy AI)
                mov     cx, 800h

loc_72E7:                               ; ...
                mov     ax, es:[di]
                movsw
                mov     [si-2], ax
                loop    loc_72E7
                retn
swap_eai_and_inventory_code_regions endp


; =============== S U B R O U T I N E =======================================


load_place_and_reinit proc near         ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_72F9
                retn
; ---------------------------------------------------------------------------

loc_72F9:                               ; ...
                mov     si, ds:mdt_buffer
                add     si, mdt_descriptor.eai_bin_idx_
                lodsb
                push    si
                mov     ds:eai_bin_index, al
                mov     bl, 11
                mul     bl
                add     ax, offset eai1_bin
                mov     si, ax
                push    cs
                pop     es
                assume es:fight
                mov     di, 0A000h      ; destination buffer
                mov     al, 3           ; fn_3
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                pop     si
                lodsb                   ; mdt_descriptor.enp_grp_idx_
                mov     ds:enp_grp_index, al
                mov     bl, 11
                mul     bl
                add     ax, offset enp1_grp
                mov     si, ax
                mov     es, cs:game_segment
                assume es:nothing
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                mov     si, 4000h
                mov     bp, 0A000h
                mov     cx, 100h
                call    cs:word_3028
                pop     ds
                mov     byte ptr ds:is_boss_cavern, 0
                mov     si, ds:mdt_buffer
                add     si, 8

next_optional_initializer:              ; ...
                lodsw
                cmp     ax, 0FFFFh
                jz      short end_of_mdt_descriptor ;
                                        ; if not ffff: optional initializers follow
                mov     bx, ax          ; address to init
                lodsw                   ; 16 bit word to write
                mov     [bx], ax
                jmp     short next_optional_initializer
; ---------------------------------------------------------------------------

end_of_mdt_descriptor:                  ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                mov     ax, ds:proximity_map_left_col_x
                mov     bl, ds:hero_x_in_viewport
                xor     bh, bh
                add     ax, bx
                test    byte ptr [si-5], 0FFh
                jz      short loc_737C
                add     ax, 9

loc_737C:                               ; ...
                mov     bx, ax
                sub     bx, ds:mapWidth
                jb      short loc_7386
                mov     ax, bx

loc_7386:                               ; ...
                mov     si, ds:doors_table_addr
                mov     [si], ax
                call    process_doors
                call    screen_flash_overlay
                call    clear_hero_in_viewport
                call    cs:Render_Viewport_Tiles_proc
                mov     bx, 21Ch
                xor     al, al
                mov     ch, 42h ; 'B'
                call    cs:Clear_HUD_Bar_proc
                mov     ax, 1
                int     60h             ; mscadlib.drv
                mov     ds:byte_9F1E, 0
                jmp     Cavern_Game_Init
load_place_and_reinit endp


; =============== S U B R O U T I N E =======================================


clear_viewport_buffer proc near         ; ...
                push    cs
                pop     es
                assume es:fight
                mov     di, offset viewport_buffer_28x19
                mov     cx, 28*19
                mov     al, 0FDh
                rep stosb
                retn
clear_viewport_buffer endp


; =============== S U B R O U T I N E =======================================


find_al_in_four_bytes_at_8020 proc near ; ...
                push    di
                mov     es, cs:game_segment
                assume es:nothing
                mov     di, 8020h
                mov     cx, 4

loc_73CC:                               ; ...
                mov     ah, es:[di]
                inc     di
                or      ah, ah
                jz      short loc_73DA
                cmp     ah, al
                jz      short loc_73DE
                loop    loc_73CC

loc_73DA:                               ; ...
                mov     ah, 0FFh
                or      ah, ah

loc_73DE:                               ; ...
                pop     di
                retn
find_al_in_four_bytes_at_8020 endp


; =============== S U B R O U T I N E =======================================


render_notification_string proc near    ; ...
                push    si
                push    dx
                mov     bx, 0E1Eh
                mov     cx, 3410h
                mov     al, 0FFh
                call    cs:Draw_Bordered_Rectangle_proc
                mov     ds:byte_9EED, 0
                mov     ds:byte_9EEF, 0FFh
                mov     ds:byte_9EEE, 0FFh
                pop     si
                lodsw
                add     ax, 3Ah ; ':'
                mov     bx, ax
                mov     cl, 22h ; '"'
                call    cs:Render_String_FF_Terminated_proc ; BX: starting x coord
                                        ; CL: starting y coord
                                        ; SI: string pointer
                pop     si
                retn
render_notification_string endp


; =============== S U B R O U T I N E =======================================


render_cavern_signs proc near           ; ...
                lodsb
                add     al, 19h
                mov     cl, al
                push    cx
                lodsb
                push    si
                add     al, 2
                mov     ds:byte_9EF1, al
                mov     bl, 8
                mul     bl
                mov     bx, 1616h
                mov     ch, 24h ; '$'
                mov     cl, al
                mov     al, 0FFh
                call    cs:Draw_Bordered_Rectangle_proc
                pop     si
                mov     ds:byte_9EED, 0
                mov     ds:byte_9EEF, 0
                mov     ds:byte_9EEE, 0
                mov     ds:byte_9EF0, 0FFh
                mov     bx, 58h ; 'X'
                pop     cx

loc_7446:                               ; ...
                mov     ds:word_9EF2, bx
                mov     ds:byte_9EF4, cl
                lodsb
                xor     ah, ah
                add     bx, ax

loc_7453:                               ; ...
                lodsb
                cmp     al, 0FFh
                jnz     short loc_7459
                retn
; ---------------------------------------------------------------------------

loc_7459:                               ; ...
                cmp     al, 2Fh ; '/'
                jz      short loc_746F
                mov     ah, 1
                push    cx
                push    bx
                push    si
                call    cs:Render_Font_Glyph_proc ; AL: ASCII character code
                                        ; AH: Palette/colour index
                                        ; BX: X pixel coordinate in framebuffer
                                        ; CX: Y pixel coordinate (row)
                                        ; CS:0xFF77: Flag: 0 = normal colour mode, nonzero = "bright/highlight" mode
                pop     si
                pop     bx
                pop     cx
                add     bx, 8
                jmp     short loc_7453
; ---------------------------------------------------------------------------

loc_746F:                               ; ...
                mov     bx, ds:word_9EF2
                mov     cl, ds:byte_9EF4
                add     cl, 0Ch
                jmp     short loc_7446
render_cavern_signs endp


; =============== S U B R O U T I N E =======================================


clear_hero_in_viewport proc near        ; ...
                mov     al, ds:hero_head_y_in_viewport
                mov     cl, 28
                mul     cl              ; ax=viewport_row_start
                mov     cl, ds:hero_x_in_viewport
                xor     ch, ch
                add     ax, cx
                add     ax, offset viewport_buffer_28x19
                mov     di, ax
                push    cs
                pop     es
                mov     al, 0FFh
                mov     cx, 3

three_tiles:                            ; ...
                stosb                   ; hero occupies 3x3 bytes in viewport buffer
                stosb
                stosb
                add     di, 25
                loop    three_tiles
                retn
clear_hero_in_viewport endp


; =============== S U B R O U T I N E =======================================


step_on_aggressive_ground proc near     ; ...
                cmp     byte ptr ds:current_accessory, SHOES_PIRIKA
                jnz     short no_pirika_shoes ; hero feets get hurting
                retn
; ---------------------------------------------------------------------------

no_pirika_shoes:                        ; ...
                mov     ds:byte_9F17, 0
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                mov     cx, 3
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_74C1
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                dec     cx

loc_74C1:                               ; ...
                push    cx
                mov     cx, 3

three_times:                            ; ...
                push    cx
                mov     al, [si]
                inc     si
                call    find_al_in_four_bytes_at_8020
                jnz     short loc_74D3
                mov     ds:byte_9F17, 0FFh

loc_74D3:                               ; ...
                pop     cx
                loop    three_times
                add     si, 33          ; 36-3
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                pop     cx
                loop    loc_74C1
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jnz     short loc_74F3
                inc     si
                mov     al, [si]
                call    find_al_in_four_bytes_at_8020
                jnz     short loc_74F3
                mov     ds:byte_9F17, 0FFh

loc_74F3:                               ; ...
                test    ds:byte_9F17, 0FFh
                jnz     short loc_74FB
                retn
; ---------------------------------------------------------------------------

loc_74FB:                               ; ...
                mov     byte ptr ds:hero_damage_this_frame, 0FFh
                mov     byte ptr ds:soundFX_request, 9
                mov     bl, ds:cavern_level
                dec     bl
                xor     bh, bh
                mov     al, ds:byte_7516[bx]
                xor     ah, ah
                jmp     damage_hero     ; ax: damage level
step_on_aggressive_ground endp

; ---------------------------------------------------------------------------
byte_7516       db 1, 1, 4, 8, 20, 20, 20, 20, 20 ; ...

; =============== S U B R O U T I N E =======================================


check_hero_contact_damage proc near     ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_752E
                test    byte ptr ds:boss_being_hit, 0FFh
                jz      short loc_752E
                retn
; ---------------------------------------------------------------------------

loc_752E:                               ; ...
                mov     ds:accumulated_contact_damage, 0
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                dec     si
                mov     di, offset word_9F0E
                mov     bx, offset loc_7651
                test    byte ptr ds:squat_flag, 0FFh
                jnz     short loc_754E
                mov     bx, offset get_monster_in_row_or_above
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h

loc_754E:                               ; ...
                push    bx
                push    di
                push    si
                call    bx ; get_monster_in_row_or_above
                sbb     al, al
                mov     [di], al
                jz      short loc_755C
                call    apply_hit_from_left

loc_755C:                               ; ...
                pop     si
                pop     di
                pop     bx
                inc     si
                inc     di
                push    bx
                push    di
                push    si
                call    bx ; get_monster_in_row_or_above
                jb      short loc_756B
                call    get_monster_one_row_above

loc_756B:                               ; ...
                sbb     al, al
                mov     [di], al
                jz      short loc_7574
                call    apply_hit_from_left

loc_7574:                               ; ...
                pop     si
                pop     di
                pop     bx
                inc     si
                inc     di
                push    bx
                push    di
                push    si
                call    bx ; get_monster_in_row_or_above
                jb      short loc_7583
                call    get_monster_one_row_above

loc_7583:                               ; ...
                sbb     al, al
                mov     [di], al
                jz      short loc_758C
                call    apply_hit_from_right

loc_758C:                               ; ...
                pop     si
                pop     di
                pop     bx
                inc     si
                inc     di
                call    bx ; get_monster_in_row_or_above
                sbb     al, al
                mov     [di], al
                jz      short loc_759C
                call    apply_hit_from_right

loc_759C:                               ; ...
                mov     di, offset word_9F0E
                mov     al, [di]
                or      al, [di+1]
                or      al, [di+2]
                or      al, [di+3]
                mov     ds:byte_9F14, al
                mov     ds:hero_damage_this_frame, al
                or      al, al
                jz      short locret_75B9
                call    cs:Print_ShieldHP_Decimal_proc

locret_75B9:                            ; ...
                retn
check_hero_contact_damage endp


; =============== S U B R O U T I N E =======================================


apply_hit_from_left proc near           ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_75C2
                retn
; ---------------------------------------------------------------------------

loc_75C2:                               ; ...
                mov     ax, ds:accumulated_contact_damage
                test    byte ptr ds:facing_direction, LEFT
                jz      short no_shield ; hero faced right (opposite direction) => shield useless
                jmp     short loc_75E2
apply_hit_from_left endp


; =============== S U B R O U T I N E =======================================


apply_hit_from_right proc near          ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_75D6
                retn
; ---------------------------------------------------------------------------

loc_75D6:                               ; ...
                mov     ax, ds:accumulated_contact_damage
                test    byte ptr ds:facing_direction, LEFT
                jnz     short no_shield ; hero faced left (opposite direction) => shield useless
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_75E2:                               ; ...
                test    byte ptr ds:shield_type, 0FFh
                jz      short no_shield
                shr     ax, 1
                mov     cl, ds:shield_type
                inc     cl
                shr     cl, 1
                shr     ax, cl
                sub     ds:shield_HP, ax ; shield absorbs AX damage
                jb      short shield_destroyed
                jnz     short hero_absorbs_damage

shield_destroyed:                       ; ...
                push    ax
                call    destroy_shield
                mov     word ptr ds:shield_HP, 0
                pop     ax

hero_absorbs_damage:                    ; ...
                call    damage_hero     ; ax: damage level
                mov     byte ptr ds:soundFX_request, 8
                retn
; ---------------------------------------------------------------------------

no_shield:                              ; ...
                call    damage_hero     ; ax: damage level
                mov     byte ptr ds:soundFX_request, 9
                retn
apply_hit_from_right endp


; =============== S U B R O U T I N E =======================================


destroy_shield  proc near               ; ...
                mov     byte ptr ds:shield_type, 0
                mov     bx, 0C51Ch
                mov     al, 0FFh
                mov     ch, 18h
                call    cs:Clear_HUD_Bar_proc
                mov     bx, 3EA3h
                mov     cx, 511h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc
                mov     dx, offset shield_broken_str
                jmp     render_notification_string
destroy_shield  endp


; =============== S U B R O U T I N E =======================================


get_monster_in_row_or_above proc near   ; ...
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jb      short loc_764B
                test    al, 40h
                jnz     short loc_764B
                and     al, 0Fh
                jmp     short loc_7675
; ---------------------------------------------------------------------------

loc_764B:                               ; ...
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h

loc_7651:                               ; ...
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jb      short get_monster_one_row_above
                test    al, 40h
                jnz     short get_monster_one_row_above
                and     al, 0Fh
                jmp     short loc_7675
get_monster_in_row_or_above endp


; =============== S U B R O U T I N E =======================================


get_monster_one_row_above proc near     ; ...
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                cmc
                jb      short loc_766B
                retn
; ---------------------------------------------------------------------------

loc_766B:                               ; ...
                clc
                test    al, 40h
                jz      short loc_7671
                retn
; ---------------------------------------------------------------------------

loc_7671:                               ; ...
                and     al, 0Fh
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_7675:                               ; ...
                mov     bl, al
                xor     bh, bh
                mov     al, ds:byte_A010[bx]
                xor     ah, ah
                add     ds:accumulated_contact_damage, ax
                stc
                retn
get_monster_one_row_above endp


; =============== S U B R O U T I N E =======================================

; ax: damage level

damage_hero     proc near               ; ...
                sub     ds:hero_HP, ax
                jnb     short loc_7691
                mov     word ptr ds:hero_HP, 0

loc_7691:                               ; ...
                push    si
                call    cs:Draw_Hero_Health_proc
                pop     si
                retn
damage_hero     endp


; =============== S U B R O U T I N E =======================================


check_airflows_on_hero proc near        ; ...
                mov     ds:air_up_tile_found, 0
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 2*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     cx, 3

check_across_hero_height:               ; ...
                push    cx
                call    dispatch_airflows
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                pop     cx
                loop    check_across_hero_height
                retn
check_airflows_on_hero endp


; =============== S U B R O U T I N E =======================================


dispatch_airflows proc near             ; ...
                mov     al, [si]
                push    si
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                pop     si
                jz      short airflow_detected
                retn
; ---------------------------------------------------------------------------

airflow_detected:                       ; ...
                pop     ax
                pop     ax
                mov     bl, cl
                xor     bh, bh
                add     bx, bx          ; switch 3 cases
                jmp     ds:airflows_table[bx] ; switch jump
dispatch_airflows endp

; ---------------------------------------------------------------------------
airflows_table  dw offset airflow_up    ; ...
                dw offset airflow_left  ; jump table for switch statement
                dw offset airflow_right
; ---------------------------------------------------------------------------

airflow_up:                             ; ...
                call    move_hero_up    ; jumptable 000076CA case 0
                call    move_hero_up
                mov     ds:air_up_tile_found, 0FFh
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:hero_animation_phase, 80h
                retn
; ---------------------------------------------------------------------------

airflow_right:                          ; ...
                call    move_hero_right_if_no_obstacles ; jumptable 000076CA case 2
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

airflow_left:                           ; ...
                call    move_hero_left_if_no_obstacles ; jumptable 000076CA case 1
                jmp     move_hero_left_if_no_obstacles

; =============== S U B R O U T I N E =======================================

; Is input tile an airflow?
; Input: al
; Output:
; NZ, cl=0xff (no airflow)
; ZF, cl=0 (Up), 1 (Left), 2 (Right)

get_airflow_direction proc near         ; ...
                or      al, al
                jz      short default
                mov     es, cs:game_segment ; 1ac5
                assume es:nothing
                mov     bh, al
                xor     cl, cl          ; check for airflow Up
                mov     si, 8024h
                mov     bl, 4

category0_check_loop:                   ; ...
                mov     al, es:[si]
                inc     si
                or      al, al
                jz      short category0_break_on_0
                cmp     al, bh
                jnz     short loc_7715
                retn                    ; found airflow Up
; ---------------------------------------------------------------------------

loc_7715:                               ; ...
                dec     bl
                jnz     short category0_check_loop

category0_break_on_0:                   ; ...
                inc     cl              ; check for airflow Left
                mov     si, 8028h
                mov     bl, 4

loc_7720:                               ; ...
                mov     al, es:[si]
                inc     si
                or      al, al
                jz      short category1_break_on_0
                cmp     al, bh
                jnz     short loc_772D
                retn                    ; found airflow Left
; ---------------------------------------------------------------------------

loc_772D:                               ; ...
                dec     bl
                jnz     short loc_7720

category1_break_on_0:                   ; ...
                inc     cl              ; check for airflow Right
                mov     si, 802Ch
                mov     bl, 4

loc_7738:                               ; ...
                mov     al, es:[si]
                inc     si
                or      al, al
                jz      short default
                cmp     al, bh
                jnz     short loc_7745
                retn                    ; found airflow Right
; ---------------------------------------------------------------------------

loc_7745:                               ; ...
                dec     bl
                jnz     short loc_7738

default:                                ; ...
                mov     cl, 0FFh
                or      cl, cl          ; NZ: no airflow, cl=0xff
                retn
get_airflow_direction endp


; =============== S U B R O U T I N E =======================================


update_boss_heartbeat_volume proc near  ; ...
                mov     ax, ds:tear_x
                cmp     ax, 0FFFFh
                jz      short distance_big
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jb      short distance_big
                mov     al, ds:hero_x_in_viewport
                add     al, 4
                mov     ah, al
                sub     al, bl
                jnb     short abs_al
                neg     al

abs_al:                                 ; ...
                mov     bh, al
                sub     bl, ah
                jnb     short abs_bl
                neg     bl

abs_bl:                                 ; ...
                cmp     bl, bh
                jb      short min_bl_bh
                mov     bl, bh

min_bl_bh:                              ; ...
                mov     ds:delta_x, bl
                mov     bl, ds:tear_y
                mov     bh, ds:hero_y_absolute
                mov     al, bh
                sub     al, bl
                and     al, 3Fh         ; wrap y
                sub     bl, bh
                and     bl, 3Fh
                cmp     bl, al
                jb      short min_al_bl
                mov     bl, al

min_al_bl:                              ; ...
                mov     ds:delta_y, bl  ; dy
                cmp     ds:delta_x, 16
                jnb     short distance_big
                mov     al, ds:delta_x  ; dx
                mov     bx, offset squares
                xlat
                mov     dl, al          ; dx^2
                cmp     ds:delta_y, 16
                jnb     short distance_big
                mov     al, ds:delta_y
                mov     bx, offset squares
                xlat                    ; dy^2
                add     al, dl          ; dx^2+dy^2
                jb      short distance_big ; dist^2 > 255
                mov     bx, offset distance_attenuation
                xlat
                mov     ds:heartbeat_volume, al
                retn
; ---------------------------------------------------------------------------

distance_big:                           ; ...
                mov     byte ptr ds:heartbeat_volume, 0
                retn
update_boss_heartbeat_volume endp

; ---------------------------------------------------------------------------
squares         db 0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225 ; ...
distance_attenuation db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh ; ...
                db 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Eh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh
                db 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Dh, 0Ch, 0Ch, 0Ch, 0Ch
                db 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
                db 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
                db 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
                db 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
                db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
                db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
                db 6, 6, 6, 6, 6, 6, 6, 6

; =============== S U B R O U T I N E =======================================


restore_game    proc near               ; ...
                mov     bx, 601Ch       ; far jump address to the town code (restore_game)
                jmp     transfer_to_town
restore_game    endp


; =============== S U B R O U T I N E =======================================


process_doors   proc near               ; ...
                mov     bp, ds:doors_table_addr ; =d57d

next_door:                              ; ...
                mov     ax, ds:[bp+door.x0]
                cmp     ax, 0FFFFh      ; doors end marker
                jnz     short loc_78EB
                retn
; ---------------------------------------------------------------------------

loc_78EB:                               ; ...
                call    calc_object_viewport_x_offset
                jb      short loc_7933
                mov     al, ds:[bp+door.field_3]
                and     al, 7
                add     al, 61h ; 'a'
                mov     ds:byte_79B6, al
                mov     ds:byte_79CA, al
                mov     al, ds:[bp+door.y0]
                xor     ah, ah
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                cmp     bl, 4
                jb      short loc_7938
                mov     cx, bx
                sub     bl, 36+3
                neg     bl
                inc     bl
                mov     al, bl
                cmp     al, 6
                jb      short loc_791D
                mov     al, 5

loc_791D:                               ; ...
                sub     cl, 4
                xor     ch, ch
                add     di, cx
                mov     si, offset byte_79C8
                test    ds:[bp+door.field_3], 80h
                jnz     short loc_7951
                mov     si, offset byte_79B4
                jmp     short loc_7951
; ---------------------------------------------------------------------------

loc_7933:                               ; ...
                add     bp, 0Ch
                jmp     short next_door
; ---------------------------------------------------------------------------

loc_7938:                               ; ...
                mov     si, offset byte_79C8
                test    ds:[bp+door.field_3], 80h
                jnz     short loc_7945
                mov     si, offset byte_79B4

loc_7945:                               ; ...
                mov     al, bl
                inc     al
                mov     cl, 5
                sub     cl, al
                xor     ch, ch
                add     si, cx

loc_7951:                               ; ...
                mov     cx, 4

four_times:                             ; ...
                push    cx
                push    ax
                push    di
                push    si

al_times:                               ; ...
                call    move_if_dst_high_bit_zero
                inc     di
                inc     si
                dec     al
                jnz     short al_times
                pop     si
                add     si, 5
                xchg    si, di
                pop     si
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    di, si
                pop     ax
                pop     cx
                loop    four_times
                jmp     short loc_7933
process_doors   endp


; =============== S U B R O U T I N E =======================================


move_if_dst_high_bit_zero proc near     ; ...
                test    byte ptr [di], 80h
                jz      short loc_797C
                retn
; ---------------------------------------------------------------------------

loc_797C:                               ; ...
                mov     dl, [si]
                mov     [di], dl
                retn
move_if_dst_high_bit_zero endp


; =============== S U B R O U T I N E =======================================


calc_object_viewport_x_offset proc near ; ...
                add     ax, 3           ; platform.x+3
                push    ax
                sub     ax, ds:mapWidth ; ax=platform.x+3-mapWidth
                pop     bx              ; bx=platform.x+3
                jnb     short x_coord_wrapped
                xchg    ax, bx

x_coord_wrapped:                        ; ...
                push    ax              ; platform.x+3
                sub     ax, ds:proximity_map_left_col_x ; ax=platform.x+3-(hero.x-18)
                pop     bx              ; bx=platform.x+3
                jb      short loc_799C
                xchg    ax, bx          ; bx=platform.x+3-(hero.x-18)
                mov     ax, 36+3
                sub     ax, bx          ; ax=18+hero.x-platform.x
                retn
; ---------------------------------------------------------------------------

loc_799C:                               ; ...
                mov     ax, 36+3
                sub     ax, bx          ; ax=36-platform.x
                jnb     short loc_79A4
                retn
; ---------------------------------------------------------------------------

loc_79A4:                               ; ...
                mov     ax, ds:mapWidth
                sub     ax, ds:proximity_map_left_col_x
                add     ax, bx          ; ax=mapWidth-(hero.x-18)+platform.x+3
                                        ; bx=platform.x+3
                xchg    ax, bx          ; bx=mapWidth-hero.x+18+platform.x+3
                mov     ax, 36+3
                sub     ax, bx          ; ax=18+hero.x-platform.x-mapWidth
                retn
calc_object_viewport_x_offset endp

; ---------------------------------------------------------------------------
byte_79B4       db 49h, 4Ah             ; ...
byte_79B6       db 61h, 4Bh, 4Ch, 4Dh, 4Fh, 50h, 51h, 4Eh, 5Fh, 52h, 53h, 54h, 60h, 5Fh, 55h, 56h, 57h, 60h ; ...
byte_79C8       db 49h, 4Ah             ; ...
byte_79CA       db 61h, 4Bh, 4Ch, 4Dh, 58h, 0, 59h, 4Eh, 5Fh, 5Ah, 0, 5Bh, 60h, 5Fh, 5Ch, 5Dh, 5Eh, 60h ; ...

; =============== S U B R O U T I N E =======================================

; run from town to dungeon

prepare_dungeon proc near               ; ...
                cli
                mov     sp, 2000h
                sti
                mov     ax, cs
                mov     ds, ax
                mov     es, ax
                mov     di, offset byte_9EED
                mov     cx, offset byte_9F2E
                sub     cx, offset byte_9EED
                dec     cx              ; 0x9f2e-0x9eed-1 = 64
                xor     al, al
                rep stosb
                not     al
                mov     ds:byte_9EF5, al
                mov     ds:eai_bin_index, al
                mov     ds:enp_grp_index, al
                call    reset_dungeon_state_vars
                mov     al, 0FFh
                mov     ds:spirit_sprite_0, al
                mov     ds:spirit_sprite_1, al
                mov     ds:spirit_sprite_2, al
                mov     ds:spirit_sprite_3, al
                mov     byte ptr ds:byte_FF3A, 0
                mov     es, cs:game_segment
                assume es:nothing
                mov     si, offset fman_grp
                mov     di, 6000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                assume ds:nothing
                mov     si, 6333h
                mov     bp, 0D000h
                mov     cx, 0E6h
                call    cs:word_3028
                pop     ds
                mov     si, ds:mdt_buffer
                lodsb
                call    process_mdt_descriptor
                call    cs:Clear_Viewport_proc
                mov     si, offset roka_grp_2
                mov     es, cs:game_segment
                mov     di, 8000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                mov     si, 8000h
                mov     cx, 80h
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                xor     al, al
                call    cs:word_301E    ; cs:[301E]=4614 => draw cavern entrance
                mov     al, ds:place_map_id
                or      al, al
                js      short loc_7A80
                call    remove_accomplished_items ; if Cangrejo_Defeated then [c013]=ffff
                                        ; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
                                        ; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
                                        ; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
                                        ; if 'Wall, Blue Potion' taken then [d987]=0000
                                        ; if 'Door to Cangrejo open' then [d580]=0181
                                        ; if 'Door to Satono open' then [d5a4]=0280

loc_7A80:                               ; ...
                jmp     loc_7C6E
prepare_dungeon endp


; =============== S U B R O U T I N E =======================================


try_door_interaction proc near          ; ...
                call    hero_coords_to_proximity_map_offset ; =e10c
                sub     si, 36+1        ; x--, y-- ; =0xe0e7
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                cmp     byte ptr [si], 4Ah ; 'J' ; door to Muralla: 0x49, 0x4A, 0x61, 0x4B, 0x4C
                jz      short on_the_right_door_tile ; hero is on the right tile of the door
                inc     si
                cmp     byte ptr [si], 4Ah ; 'J'
                jz      short enter_the_door ; hero is centered on door
                inc     si
                cmp     byte ptr [si], 4Ah ; 'J'
                jz      short on_the_left_door_tile
                retn
; ---------------------------------------------------------------------------

on_the_left_door_tile:                  ; ...
                test    byte ptr ds:facing_direction, 1
                jz      short loc_7AA6
                retn                    ; faced left - skip door interaction
; ---------------------------------------------------------------------------

loc_7AA6:                               ; ...
                pop     ax
                jmp     move_hero_right_if_no_obstacles
; ---------------------------------------------------------------------------

on_the_right_door_tile:                 ; ...
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_7AB2
                retn                    ; faced right - skip door interaction
; ---------------------------------------------------------------------------

loc_7AB2:                               ; ...
                pop     ax              ; =0x653f
                jmp     move_hero_left_if_no_obstacles
; ---------------------------------------------------------------------------

enter_the_door:                         ; ...
                mov     ax, ds:proximity_map_left_col_x ; proximity map left edge in the absolute map coords
                mov     bl, ds:hero_x_in_viewport
                add     bl, 4           ; viewport offset from proximity map margin
                xor     bh, bh
                add     ax, bx          ; hero x absolute
                mov     bx, ds:mapWidth
                dec     bx
                sub     bx, ax
                jnb     short no_wrap
                not     bx
                mov     ax, bx

no_wrap:                                ; ...
                mov     bl, ds:hero_head_y_in_viewport
                dec     bl
                add     bl, ds:viewport_top_row_y
                and     bl, 3Fh         ; wrap vertically
                mov     si, ds:doors_table_addr

next_door1:                              ; ...
                cmp     word ptr [si], 0FFFFh ; end of doors marker
                jnz     short loc_7AE8
                retn
; ---------------------------------------------------------------------------

loc_7AE8:                               ; ...
                cmp     ax, [si+door.x0]
                jnz     short loc_7AF1
                cmp     bl, [si+door.y0]
                jz      short loc_7AF6

loc_7AF1:                               ; ...
                add     si, 12
                jmp     short next_door1
; ---------------------------------------------------------------------------

loc_7AF6:                               ; ...
                pop     ax
                test    [si+door.field_3], 80h
                jnz     short loc_7B25
                call    open_door
                jb      short loc_7B03
                retn
; ---------------------------------------------------------------------------

loc_7B03:                               ; ...
                mov     byte ptr ds:hero_animation_phase, 80h
                mov     ds:horiz_movement_sub_tile_accum, 0
                test    ds:byte_9F19, 0FFh
                jz      short loc_7B15
                retn
; ---------------------------------------------------------------------------

loc_7B15:                               ; ...
                mov     ds:byte_9F19, 0FFh
                mov     byte ptr ds:soundFX_request, 16h
                mov     dx, offset cant_open_this_door_str
                jmp     render_notification_string
; ---------------------------------------------------------------------------

loc_7B25:                               ; ...
                mov     bx, [si+door.d_field_9]
                cmp     bx, 0FFFFh
                jz      short loc_7B32
                mov     al, [si+door.field_B]
                or      [bx], al

loc_7B32:                               ; ...
                push    si
                call    Browse_Projectiles
                call    clear_viewport_buffer
                call    cs:Flush_Ui_Element_If_Dirty_proc
                call    reset_dungeon_state_vars
                call    game_loop_render_and_timing
                mov     si, ds:monsters_table_addr
                mov     word ptr [si], 0FFFFh ; end-of-monsters marker
                pop     si              ; doors struct
                mov     al, [si+door.field_3]
                and     al, 111b
                push    ax
                mov     ax, [si+door.x1]
                mov     ds:hero_x_in_proximity_map, ax
                mov     al, [si+door.y1]
                mov     ds:byte_9F1C, al
                mov     al, [si+door.field_3]
                and     al, 1000000b
                mov     ds:is_left_run, al
                mov     al, [si+door.field_8]
                mov     ds:byte_9F1D, al
                mov     ah, [si+door.d_place_map_id]
                cmp     [si+door.y1], 0FFh
                jnz     short skip_if_cavern
                or      ah, 80h         ; door leads to town

skip_if_cavern:                         ; ...
                mov     ds:place_map_id, ah ; cavern/town id
                mov     al, 1           ; fn_1 Load mdt
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                test    byte ptr ds:place_map_id, 80h
                jnz     short skip_if_town ;
                                        ; place is cavern
                call    remove_accomplished_items ; if Cangrejo_Defeated then [c013]=ffff
                                        ; if 'Chest 50 Golds' taken then [d65e]=ff00, [d669]=ffff
                                        ; if 'Chest Red Potion' taken then [d77e]=ff00, [d789]=ffff
                                        ; if 'Muralla Key 1' taken then [d78e]=ff00, [d799]=ffff
                                        ; if 'Wall, Blue Potion' taken then [d987]=0000
                                        ; if 'Door to Cangrejo open' then [d580]=0181
                                        ; if 'Door to Satono open' then [d5a4]=0280

skip_if_town:                           ; ...
                call    hero_left_16_down_1
                mov     si, ds:mdt_buffer
                lodsb
                test    al, 1
                jnz     short loc_7BD0
                mov     si, offset roka_grp_1
                mov     es, cs:game_segment
                mov     di, 8000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                mov     si, 8000h
                mov     cx, 80h
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                pop     ax
                call    cs:word_301E
                mov     ds:byte_9EF6, 0FFh
                mov     byte ptr ds:byte_FF24, 0Ah
                jmp     short loc_7C02
; ---------------------------------------------------------------------------

loc_7BD0:                               ; ...
                mov     si, offset roka_grp_2
                mov     es, cs:game_segment
                mov     di, 8000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                mov     si, 8000h
                mov     cx, 80h
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                pop     ax
                call    cs:word_301E
                mov     si, ds:mdt_buffer
                lodsb
                call    process_mdt_descriptor

loc_7C02:                               ; ...
                mov     byte ptr ds:byte_FF3A, 0
                mov     ds:byte_9EF5, 0FFh
                mov     ds:projectiles_array, 0FFh
                test    ds:byte_9F1D, 80h
                jz      short loc_7C6E
                mov     si, offset rokademo_bin
                push    cs
                pop     es
                mov     di, 0A000h
                mov     al, 3           ; fn_3
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                call    cs:Monster_AI_proc
                mov     ds:enp_grp_index, 0FFh
                mov     ds:eai_bin_index, 0FFh
                mov     al, ds:msd_index
                mov     ds:byte_9EFA, al
                mov     ds:byte_9F02, 0FFh
                call    load_cavern_sprites_ai_music ; load dchr.grp
                                        ; load mpp{mpp_grp_index}.grp
                                        ; load eai{eai_bin_index}.bin
                                        ; load enp{enp_grp_index).grp
                                        ; load mgt{mgt_msd_index}.msd
                mov     es, cs:game_segment
                assume es:nothing
                mov     si, offset fman_grp
                mov     di, 6000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                push    ds
                mov     ds, cs:game_segment
                mov     si, 6333h
                mov     bp, 0D000h
                mov     cx, 0E6h
                call    cs:word_3028
                pop     ds
                jmp     loc_7CF4
; ---------------------------------------------------------------------------

loc_7C6E:                               ; ...
                test    byte ptr ds:is_left_run, 0FFh
                jnz     short run_to_town
                and     byte ptr ds:facing_direction, 11111110b ; run to the cavern
                mov     bx, 0A6Eh
                mov     cx, 26          ; 26 steps to animate

loc_7C80:                               ; ...
                push    cx              ; animate hero running in cavern entrance
                push    bx
                inc     byte ptr ds:hero_animation_phase
                call    cs:word_3016
                pop     bx
                add     bh, 2
                push    bx
                call    cs:word_3020
                call    sleep_loop_handle_system_keys
                pop     bx
                push    bx
                mov     cx, 218h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc
                pop     bx
                pop     cx
                loop    loc_7C80        ; animate hero running in cavern entrance
                mov     cx, 618h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc
                jmp     short loc_7CF4
; ---------------------------------------------------------------------------

run_to_town:                            ; ...
                or      byte ptr ds:facing_direction, 1
                mov     bx, 406Eh
                mov     cx, 1Ah

loc_7CBF:                               ; ...
                push    cx
                push    bx
                inc     byte ptr ds:hero_animation_phase
                call    cs:word_3016
                pop     bx
                sub     bh, 2
                push    bx
                call    cs:word_3020
                call    sleep_loop_handle_system_keys
                pop     bx
                push    bx
                add     bh, 4
                mov     cx, 218h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc
                pop     bx
                pop     cx
                loop    loc_7CBF
                mov     cx, 618h
                xor     al, al
                call    cs:Draw_Bordered_Rectangle_proc

loc_7CF4:                               ; ...
                mov     si, ds:mdt_buffer
                lodsb
                mov     ah, al
                and     al, 1
                jz      short loc_7D64
                call    load_cavern_sprites_ai_music ; load dchr.grp
                                        ; load mpp{mpp_grp_index}.grp
                                        ; load eai{eai_bin_index}.bin
                                        ; load enp{enp_grp_index).grp
                                        ; load mgt{mgt_msd_index}.msd
                mov     si, ds:mdt_buffer
                lodsb                   ; mdt_descriptor[0]
                mov     ah, al
                add     ah, ah
                sbb     bl, bl          ; if ah bit 7 is set => bl = ff (boss cavern)
                mov     ds:is_boss_cavern, bl
                add     ah, ah
                sbb     bl, bl          ; if ah bit 6 was set => bl = ff (Jashiin cavern)
                mov     ds:is_jashiin_cavern, bl
                mov     byte ptr ds:boss_being_hit, 0
                mov     byte ptr ds:sprite_flash_flag, 0
                call    cs:Clear_Viewport_proc
                mov     byte ptr ds:hero_x_in_viewport, 0Ch
                mov     al, ds:hero_head_y_in_viewport_initial_from_mdt
                mov     ds:hero_head_y_in_viewport, al
                mov     ds:byte_9F00, al
                mov     byte ptr ds:hero_animation_phase, 80h
                push    ds
                mov     ds, cs:game_segment
                mov     si, 8030h
                mov     cx, 66h ; 'f'
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                call    cs:word_302A
                pop     ds
                push    ds
                call    cs:word_301A
                mov     cx, 18h
                call    cs:Reassemble_3_Planes_To_Packed_Bitmap_proc
                pop     ds
                jmp     Cavern_Game_Init
; ---------------------------------------------------------------------------

loc_7D64:                               ; ...
                mov     si, ds:mdt_buffer
                inc     si
                lodsb                   ; mman_grp_idx
                mov     bl, 11
                mul     bl
                add     ax, offset mman_grp
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                mov     bx, 6000h       ; far jump to the town code

transfer_to_town:                       ; ...
                mov     ax, 1
                int     60h             ; mscadlib.drv
                push    bx
                call    edge_locking_scrolling_window ; Return:
                                        ; AX: proximity_map_left_col_x
                                        ; BL: hero_x_in_viewport
                mov     ds:proximity_map_left_col_x, ax
                mov     ds:hero_x_in_viewport, bl
                mov     si, ds:mdt_buffer
                lodsb
                shr     al, 1
                and     al, 11111b
                mov     ds:msd_index, al
                mov     bl, 11
                mul     bl
                add     ax, offset mgt1_msd
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 3000h
                mov     al, 5           ; fn_5
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                pop     bx
                xor     al, al          ; swap and go bx
                jmp     cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
try_door_interaction endp               ; fn1_load_mdt_idx_ah
                                        ; ...

; =============== S U B R O U T I N E =======================================


hero_left_16_down_1 proc near           ; ...
                mov     ax, ds:hero_x_in_proximity_map
                add     ax, -16
                or      ah, ah
                jns     short loc_7DCF
                add     ax, ds:mapWidth

loc_7DCF:                               ; ...
                mov     ds:proximity_map_left_col_x, ax
                mov     al, ds:byte_9F1C
                inc     al
                sub     al, ds:hero_head_y_in_viewport_initial_from_mdt
                and     al, 3Fh
                mov     ds:viewport_top_row_y, al
                retn
hero_left_16_down_1 endp


; =============== S U B R O U T I N E =======================================

; Return:
; AX: proximity_map_left_col_x
; BL: hero_x_in_viewport

edge_locking_scrolling_window proc near ; ...
                mov     bx, 13
                mov     ax, ds:hero_x_in_proximity_map
                mov     cx, ds:mapWidth
                sub     cx, bx
                sub     cx, ax
                jnb     short loc_7E03
                mov     ax, ds:mapWidth
                add     ax, -36
                mov     cx, ds:hero_x_in_proximity_map
                sbb     cx, ax
                mov     bl, cl
                sub     bl, 3
                retn
; ---------------------------------------------------------------------------

loc_7E03:                               ; ...
                add     ax, 0FFEFh
                or      ah, ah
                jnz     short loc_7E0B
                retn
; ---------------------------------------------------------------------------

loc_7E0B:                               ; ...
                xor     ax, ax
                mov     bl, byte ptr ds:hero_x_in_proximity_map
                sub     bl, 4           ; hero_x_in_viewport
                retn
edge_locking_scrolling_window endp


; =============== S U B R O U T I N E =======================================


open_door       proc near               ; ...
                mov     bl, [si+door.field_8]
                and     bl, 1
                jnz     short lion_head_key_needed ;
                                        ; ordinary key needed
                test    byte ptr ds:keys_amount, 0FFh
                stc
                jnz     short has_keys
                retn                    ; no keys
; ---------------------------------------------------------------------------

has_keys:                               ; ...
                dec     byte ptr ds:keys_amount  ; use ordinary key
                mov     byte ptr ds:soundFX_request, 15h
                or      [si+door.field_3], 80h
                mov     bx, [si+door.d_field_9]
                mov     al, [si+door.field_B]
                or      [bx], al
                retn
; ---------------------------------------------------------------------------

lion_head_key_needed:                   ; ...
                test    byte ptr ds:lion_head_keys, 0FFh
                stc
                jnz     short loc_7E45
                retn
; ---------------------------------------------------------------------------

loc_7E45:                               ; ...
                dec     byte ptr ds:lion_head_keys
                mov     byte ptr ds:soundFX_request, 15h
                or      byte ptr [si+3], 80h
                mov     bx, [si+9]
                mov     al, [si+0Bh]
                or      [bx], al
                retn
open_door       endp


; =============== S U B R O U T I N E =======================================


reset_dungeon_state_vars proc near      ; ...
                xor     al, al
                mov     ds:sword_swing_flag, al
                mov     ds:byte_FF44, al
                mov     ds:spell_active_flag, al
                mov     ds:jump_phase_flags, al ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     ds:squat_flag, al
                mov     ds:hero_damage_this_frame, al
                mov     ds:byte_9EEF, al
                mov     ds:byte_FF3E, al
                mov     ds:byte_FF4B, al
                mov     ds:heartbeat_volume, al
                mov     ds:hero_animation_phase, al
                mov     ax, 0FFFFh
                mov     ds:projectiles_array, al
                mov     ds:is_boss_dead, al
                mov     word ptr ds:magic_projectiles, ax
                mov     ds:byte_FF3A, al
                mov     ds:byte_9EF5, al
                jmp     clear_viewport_buffer
reset_dungeon_state_vars endp


; =============== S U B R O U T I N E =======================================


process_mdt_descriptor proc near        ; ...
                push    cs
                pop     es
                assume es:fight
                mov     di, offset byte_9EF6
                mov     cx, 4
                rep movsb               ; mdt_descr[1..4]
                shr     al, 1           ; mdt_descr[0]>>1
                and     al, 0Fh
                mov     ah, al
                mov     al, 0FFh
                cmp     ah, ds:msd_index
                jz      short loc_7EB6
                mov     byte ptr ds:byte_FF24, 0Ah
                mov     ds:msd_index, ah
                mov     al, ah

loc_7EB6:                               ; ...
                stosb
                mov     al, 0FFh
                stosb
                retn
process_mdt_descriptor endp


; =============== S U B R O U T I N E =======================================

; load dchr.grp
; load mpp{mpp_grp_index}.grp
; load eai{eai_bin_index}.bin
; load enp{enp_grp_index).grp
; load mgt{mgt_msd_index}.msd

load_cavern_sprites_ai_music proc near  ; ...
                mov     es, cs:game_segment
                assume es:nothing
                mov     si, offset dchr_grp
                mov     di, 8C00h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; res_dispatcher
                mov     bl, ds:mpp_grp_index
                mov     al, 11
                mul     bl
                add     ax, offset mpp_grp
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 8000h       ; destination buffer
                mov     al, 2           ; fn_2: load and unpack
                call    cs:res_dispatcher_proc ; res_dispatcher
                mov     bl, ds:byte_9EF8
                cmp     bl, 0FFh
                jnz     short loc_7EF3
                retn
; ---------------------------------------------------------------------------

loc_7EF3:                               ; ...
                cmp     bl, ds:eai_bin_index
                jz      short loc_7F12
                mov     ds:eai_bin_index, bl
                mov     al, 11
                mul     bl
                add     ax, offset eai1_bin
                mov     si, ax
                push    cs
                pop     es
                mov     di, 0A000h
                mov     al, 3           ; fn_3
                call    cs:res_dispatcher_proc ; res_dispatcher

loc_7F12:                               ; ...
                mov     bl, ds:byte_9EF9
                cmp     bl, 0FFh
                jnz     short loc_7F1C
                retn
; ---------------------------------------------------------------------------

loc_7F1C:                               ; ...
                cmp     bl, ds:enp_grp_index
                jz      short loc_7F53
                mov     ds:enp_grp_index, bl
                mov     al, 11
                mul     bl
                add     ax, offset enp1_grp
                mov     si, ax
                mov     es, cs:game_segment
                assume es:nothing
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; res_dispatcher
                push    ds
                mov     ds, cs:game_segment
                mov     si, 4000h
                mov     bp, 0A000h
                mov     cx, 100h
                call    cs:word_3028
                pop     ds

loc_7F53:                               ; ...
                mov     bl, ds:byte_9EFA
                cmp     bl, 0FFh
                jnz     short load_music
                retn
; ---------------------------------------------------------------------------

load_music:                             ; ...
                push    bx
                mov     ax, 1
                int     60h             ; mscadlib.drv
                mov     ds:byte_9F02, 0FFh
                pop     bx              ; =4 for Malicia
                mov     al, 11
                mul     bl
                add     ax, offset mgt1_msd
                mov     si, ax
                mov     es, cs:game_segment
                mov     di, 3000h
                mov     al, 5           ; fn_5
                call    cs:res_dispatcher_proc ; res_dispatcher
                retn
load_cavern_sprites_ai_music endp


; =============== S U B R O U T I N E =======================================


sleep_loop_handle_system_keys proc near ; ...
                mov     cl, ds:speed_const
                mov     al, 4
                mul     cl

loc_7F8A:                               ; ...
                push    ax
                call    cs:Confirm_Exit_Dialog_proc
                call    cs:Handle_Pause_State_proc
                call    cs:Handle_Speed_Change_proc
                call    cs:Joystick_Calibration_proc
                call    cs:Joystick_Deactivator_proc
                pop     ax
                cmp     ds:frame_timer, al
                jb      short loc_7F8A
                mov     byte ptr ds:frame_timer, 0
                retn
sleep_loop_handle_system_keys endp


; =============== S U B R O U T I N E =======================================


render_vertical_platforms_to_proximity proc near ; ...
                mov     si, ds:vertical_platforms_table_addr

next_vert_platform:                     ; ...
                mov     ax, [si+vert_platform.x]
                cmp     ax, 0FFFFh
                jnz     short loc_7FBD
                retn
; ---------------------------------------------------------------------------

loc_7FBD:                               ; ...
                call    abs_x_to_proximity_rel
                jb      short loc_7FD7
                mov     ah, bl
                mov     al, [si+vert_platform.y]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     cx, 3           ; 3 platform tiles
                mov     dl, 40h ; '@'   ; vertical platform has tiles 0x40, 0x41, 0x42

loc_7FCF:                               ; ...
                call    put_dl_to_proximity_layered
                inc     di              ; x++
                inc     dl              ; next platform tile
                loop    loc_7FCF

loc_7FD7:                               ; ...
                add     si, 3
                jmp     short next_vert_platform
render_vertical_platforms_to_proximity endp


; =============== S U B R O U T I N E =======================================


move_platform_down_damage_monster proc near ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short on_ground4
                retn
; ---------------------------------------------------------------------------

on_ground4:                              ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     dl, 40h ; '@'   ; vertical platform: tiles 0x40, 0x41, 0x42
                call    identify_platform_tile ; NZ: not a platform
                                        ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
                jz      short hor_platform_beneath
                retn
; ---------------------------------------------------------------------------

hor_platform_beneath:                   ; ...
                mov     di, ds:vertical_platforms_table_addr
                mov     dl, 40h ; '@'
                call    try_move_platform_down ; NC: platform is blocked
                                        ; CF: platform successfully moved down
                jnb     short blocked
                pop     ax
                mov     byte ptr ds:hero_animation_phase, 80h
                jmp     hero_scroll_down
; ---------------------------------------------------------------------------

blocked:                                ; ...
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jnb     short alive_or_dead_monster
                retn                    ; blocked by non-monster
; ---------------------------------------------------------------------------

alive_or_dead_monster:                  ; ...
                and     al, 1100000b    ; dead slug (almas) = 0x74
                jz      short alive_monster
                retn
; ---------------------------------------------------------------------------

alive_monster:                          ; ...
                test    [bx+monster.ai_flags], 100000b ; is damageable?
                jz      short monster_can_be_damaged
                retn
; ---------------------------------------------------------------------------

monster_can_be_damaged:                 ; ...
                or      [bx+monster.ai_flags], 1000000b ; damage monster
                and     [bx+monster.ai_flags], 11100000b
                retn
move_platform_down_damage_monster endp


; =============== S U B R O U T I N E =======================================

; NC: platform is blocked
; CF: platform successfully moved down

try_move_platform_down proc near        ; ...
                push    dx
                call    find_platform_under_hero
                pop     dx
                mov     bx, si
                add     si, 36-1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                test    byte ptr [si], 80h ; if high bit is set => platform is blocked below by monster
                clc
                jz      short loc_8038
                retn                    ; NC (blocked by monster)
; ---------------------------------------------------------------------------

loc_8038:                               ; ...
                mov     cx, 3           ; platform is 3 tiles

three_times__:                           ; ...
                inc     si
                test    byte ptr [si], 0FFh
                jz      short loc_8042
                retn                    ; NC: blocked by nonzero tile
; ---------------------------------------------------------------------------

loc_8042:                               ; ...
                loop    three_times__
                mov     si, bx          ; bx is platform offset in proximity map
                add     si, 36          ; row under the platform
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                push    di
                mov     di, si          ; platform struc offset
                mov     cx, 3

three_times_:                            ; ...
                push    dx
                push    bx
                call    put_dl_to_proximity_layered
                pop     bx
                xchg    di, bx
                push    bx
                xor     dl, dl
                call    put_dl_to_proximity_layered
                pop     bx
                xchg    di, bx
                inc     di
                inc     bx
                pop     dx
                inc     dl
                loop    three_times_
                pop     di
                inc     [di+vert_platform.y]
                and     [di+vert_platform.y], 3Fh
                stc
                retn                    ; CF: platform successfully moved down
try_move_platform_down endp


; =============== S U B R O U T I N E =======================================


try_move_platform_up proc near          ; ...
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jz      short loc_807C
                retn
; ---------------------------------------------------------------------------

loc_807C:                               ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                sub     si, 36-1
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     al, [si]
                call    is_non_blocking_tile ; ZF if can pass
                jz      short hero_not_blocked_above
                retn
; ---------------------------------------------------------------------------

hero_not_blocked_above:                 ; ...
                add     si, 36*4
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     dl, 40h ; '@'   ; vertical platform: tiles 0x40, 0x41, 0x42
                call    identify_platform_tile ; NZ: not a platform
                                        ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
                jz      short hor_platform_beneath_
                retn
; ---------------------------------------------------------------------------

hor_platform_beneath_:                   ; ...
                mov     di, ds:vertical_platforms_table_addr ; =d555
                mov     dl, 40h ; '@'
                push    dx
                call    find_platform_under_hero
                pop     dx
                mov     ax, si
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     bx, si
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     cx, 3           ; platform is 3 tiles

check_across_platform_width:            ; ...
                test    byte ptr [si], 80h
                jz      short not_blocked
                retn
; ---------------------------------------------------------------------------

not_blocked:                            ; ...
                test    byte ptr [bx], 0FFh
                jz      short not_blocked_
                retn
; ---------------------------------------------------------------------------

not_blocked_:                           ; ...
                inc     si
                inc     bx
                loop    check_across_platform_width
                mov     bx, ax
                mov     si, bx
                sub     si, 36
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                push    di              ; =d558
                mov     di, si          ; =e717
                mov     cx, 3

loc_80DA:                               ; ...
                push    dx
                push    bx
                call    put_dl_to_proximity_layered
                pop     bx              ; =e73b
                xchg    di, bx          ; bx=e717
                push    bx
                xor     dl, dl
                call    put_dl_to_proximity_layered
                pop     bx              ; =e717
                xchg    di, bx          ; bx=e73b
                inc     di
                inc     bx
                pop     dx
                inc     dl              ; 40h, 41h, 42h
                loop    loc_80DA
                pop     di              ; =d558
                dec     [di+door.y0]    ; move platform up
                and     [di+door.y0], 3Fh
                pop     ax
                pop     ax
                mov     byte ptr ds:hero_animation_phase, 80h
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                jmp     move_hero_up
try_move_platform_up endp


; =============== S U B R O U T I N E =======================================


find_platform_under_hero proc near      ; ...
                mov     al, ds:hero_x_in_viewport ; =0c
                add     al, 4           ; viewport starts +4 from proximity window
                add     al, dh          ; hero position on platform {-1, 0, 1}
                xor     ah, ah          ; =000f
                add     ax, ds:proximity_map_left_col_x ; +00ce=00dd
                cmp     ax, ds:mapWidth
                jb      short inside_the_map
                sub     ax, ds:mapWidth ; ax = hero absolute coord x

inside_the_map:                         ; ...
                mov     cl, ds:viewport_top_row_y
                add     cl, ds:hero_head_y_in_viewport ; hero absolute y coord in map
                add     cl, 3           ; hero height
                and     cl, 3Fh         ; hero feets y

next_platform:                          ; ...
                cmp     ax, [di+vert_platform.x]
                jnz     short loc_8137
                cmp     cl, [di+vert_platform.y]
                jz      short platform_found

loc_8137:                               ; ...
                add     di, 3           ; vertical platform descriptor is 3 bytes
                jmp     short next_platform
; ---------------------------------------------------------------------------

platform_found:                         ; ...
                call    abs_x_to_proximity_rel
                mov     al, [di+vert_platform.y]
                mov     ah, bl
                push    di
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     si, di
                pop     di
                retn
find_platform_under_hero endp


; =============== S U B R O U T I N E =======================================

; NZ: not a platform
; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile

identify_platform_tile proc near        ; ...
                mov     dh, 1
                cmp     dl, [si]
                jnz     short loc_8153
                retn                    ; left platform tile, return ZF and dh=1
; ---------------------------------------------------------------------------

loc_8153:                               ; ...
                dec     dh
                inc     dl
                cmp     dl, [si]
                jnz     short loc_815C
                retn                    ; middle platform tile, return ZF and dh=0
; ---------------------------------------------------------------------------

loc_815C:                               ; ...
                dec     dh
                inc     dl
                cmp     dl, [si]
                retn                    ; right platform tile, return ZF and dh=-1
identify_platform_tile endp


; =============== S U B R O U T I N E =======================================


process_visible_collapsing_platforms proc near ; ...
                mov     si, ds:collapsing_platforms_table_addr

next_collapsing_platform:               ; ...
                mov     ax, [si+vert_platform.x] ; x
                cmp     ax, 0FFFFh
                jnz     short loc_816F
                retn
; ---------------------------------------------------------------------------

loc_816F:                               ; ...
                call    abs_x_to_proximity_rel
                jb      short loc_8189
                mov     ah, bl
                mov     al, [si+vert_platform.y] ; y
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     cx, 3
                mov     dl, 43h ; 'C'   ; collapsing platform tiles are 0x43, 0x44, 0x45

loc_8181:                               ; ...
                call    put_dl_to_proximity_layered
                inc     di
                inc     dl
                loop    loc_8181

loc_8189:                               ; ...
                add     si, 3
                jmp     short next_collapsing_platform
process_visible_collapsing_platforms endp


; =============== S U B R O U T I N E =======================================


hero_collapse_platform proc near        ; ...
                call    hero_coords_to_proximity_map_offset ; Hero is 3x3 matrix. Return top-left coord in SI
                add     si, 3*36+1
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                mov     dl, 43h ; 'C'   ; collapsing platform tiles are 0x43, 0x44, 0x45
                call    identify_platform_tile ; NZ: not a platform
                                        ; ZF: platform; dh={1, 0, -1} for {left, mid, right} tile
                jz      short loc_819F
                retn
; ---------------------------------------------------------------------------

loc_819F:                               ; ...
                mov     di, ds:collapsing_platforms_table_addr
                mov     dl, 43h ; 'C'
                call    try_move_platform_down ; NC: platform is blocked
                                        ; CF: platform successfully moved down
                jb      short loc_81AB
                retn
; ---------------------------------------------------------------------------

loc_81AB:                               ; ...
                jmp     hero_scroll_down
hero_collapse_platform endp


; =============== S U B R O U T I N E =======================================


update_and_render_horiz_platforms proc near ; ...
                inc     ds:byte_9F07
                mov     si, ds:horiz_platforms_table_addr ; =d55f

next_platform_:                          ; ...
                mov     ax, [si+horiz_platform.x_and_flags]
                cmp     ax, 0FFFFh
                jnz     short loc_81BE
                retn
; ---------------------------------------------------------------------------

loc_81BE:                               ; ...
                and     ax, 3FFFh       ; x
                call    horiz_platform_proximity_x_offset
                jb      short loc_820A
                mov     cl, bl
                dec     bx
                dec     bx
                or      bh, bh
                jns     short loc_81DA
                inc     cl
                mov     al, [si+horiz_platform.y_and_flags]
                xor     ah, ah
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                jmp     short loc_8200
; ---------------------------------------------------------------------------

loc_81DA:                               ; ...
                mov     ax, bx
                sub     ax, 34
                jb      short loc_81F6
                push    ax
                mov     al, [si+horiz_platform.y_and_flags]
                mov     ah, 34
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                pop     ax
                add     di, ax
                mov     cl, al
                neg     cl
                add     cl, 2
                jmp     short loc_8200
; ---------------------------------------------------------------------------

loc_81F6:                               ; ...
                mov     ah, bl
                mov     al, [si+horiz_platform.y_and_flags]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     cl, 3           ; platform has 3 tiles

loc_8200:                               ; ...
                xor     ch, ch
                xor     dl, dl

clear_next_platform_tile:               ; ...
                call    put_dl_to_proximity_layered
                inc     di
                loop    clear_next_platform_tile

loc_820A:                               ; ...
                mov     ax, [si+horiz_platform.x_and_flags]
                mov     bl, ah
                and     ax, 3FFFh
                rol     bl, 1
                rol     bl, 1
                and     bl, 3           ; 00, 01, 10, 11
                jz      short skip_if_0
                dec     bl
                xor     bh, bh
                add     bx, bx
                call    ds:funcs_8220[bx]

skip_if_0:                              ; ...
                call    abs_x_to_proximity_rel
                jb      short loc_823E
                mov     ah, bl
                mov     al, [si+horiz_platform.y_and_flags]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     cx, 3
                mov     dl, 46h ; 'F'   ; Horizontal platform has tiles 0x46, 0x47, 0x48

loc_8236:                               ; ...
                call    put_dl_to_proximity_layered
                inc     di
                inc     dl
                loop    loc_8236

loc_823E:                               ; ...
                add     si, 7
                jmp     next_platform_
update_and_render_horiz_platforms endp

; ---------------------------------------------------------------------------
funcs_8220      dw offset update_slow_horiz_platform_coords ; ...
                dw offset update_horiz_platform_coords
                dw offset update_horiz_platform_coords

; =============== S U B R O U T I N E =======================================


update_slow_horiz_platform_coords proc near ; ...
                test    ds:byte_9F07, 1
                jnz     short update_horiz_platform_coords
                retn
update_slow_horiz_platform_coords endp


; =============== S U B R O U T I N E =======================================


update_horiz_platform_coords proc near  ; ...
                mov     cl, [si+horiz_platform.y_and_flags]
                and     [si+horiz_platform.y_and_flags], 10111111b
                test    cl, 40h         ; paused platform
                jz      short moving_platform
                retn
; ---------------------------------------------------------------------------

moving_platform:                        ; ...
                test    [si+horiz_platform.y_and_flags], 80h ; y bit 7 is direction: 0=right, 1=left
                jnz     short leftward
                inc     ax
                mov     bx, ax
                sub     ax, ds:mapWidth
                jz      short loc_826F
                xchg    ax, bx

loc_826F:                               ; ...
                push    si
                push    ax
                call    hero_on_horiz_platform
                jb      short loc_8279
                call    move_hero_right_if_no_obstacles

loc_8279:                               ; ...
                pop     ax
                pop     si
                mov     bx, [si+horiz_platform.max_x] ; platform moving rightward
                jmp     short loc_8299
; ---------------------------------------------------------------------------

leftward:                               ; ...
                dec     ax
                cmp     ax, 0FFFFh
                jnz     short loc_828A
                mov     ax, ds:mapWidth
                dec     ax

loc_828A:                               ; ...
                push    si
                push    ax
                call    hero_on_horiz_platform
                jb      short loc_8294
                call    move_hero_left_if_no_obstacles

loc_8294:                               ; ...
                pop     ax
                pop     si
                mov     bx, [si+horiz_platform.min_x] ; platform moving leftward

loc_8299:                               ; ...
                mov     dl, [si+1]
                and     dl, 11000000b   ; x_and_flags speed part
                or      dl, ah
                mov     byte ptr [si+horiz_platform.x_and_flags], al ; =2f
                mov     [si+1], dl      ; horiz. platform x = 40h => normal speed
                sub     bx, ax          ; 0024h-002f=fff5
                jz      short loc_82AB
                retn
; ---------------------------------------------------------------------------

loc_82AB:                               ; ...
                xor     [si+horiz_platform.y_and_flags], 80h ; change direction
                or      [si+horiz_platform.y_and_flags], 40h ; pause platform for several ticks
                retn
update_horiz_platform_coords endp


; =============== S U B R O U T I N E =======================================


hero_on_horiz_platform proc near        ; ...
                mov     dl, ds:jump_phase_flags ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                or      dl, ds:on_rope_flags ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                stc
                jz      short on_ground5
                retn
; ---------------------------------------------------------------------------

on_ground5:                              ; ...
                mov     al, ds:hero_head_y_in_viewport
                add     al, ds:viewport_top_row_y
                add     al, 3
                and     al, 3Fh
                mov     ah, [si+horiz_platform.y_and_flags]
                and     ah, 3Fh
                cmp     al, ah
                stc
                jz      short loc_82D7
                retn
; ---------------------------------------------------------------------------

loc_82D7:                               ; ...
                mov     ax, [si+horiz_platform.x_and_flags]
                and     ax, 3FFFh
                call    abs_x_to_proximity_rel
                jnb     short loc_82E2
                retn
; ---------------------------------------------------------------------------

loc_82E2:                               ; ...
                mov     dl, ds:hero_x_in_viewport
                add     dl, 4
                mov     cx, 3

loc_82EC:                               ; ...
                cmp     dl, al
                clc
                jnz     short loc_82F2
                retn
; ---------------------------------------------------------------------------

loc_82F2:                               ; ...
                inc     dl
                loop    loc_82EC
                stc
                retn
hero_on_horiz_platform endp


; =============== S U B R O U T I N E =======================================


abs_x_to_proximity_rel proc near        ; ...
                mov     bx, ax          ; ax=bx=inX (absolute x coord in the map)
                sub     ax, ds:proximity_map_left_col_x ; ax = inX-proximityLeft
                jb      short inX_lt_proxLeft ;
                                        ; case0:
                                        ; proximityLeft <= inX < mapWidth
                xchg    ax, bx          ; ax = inX
                                        ; bx = inX - proximityLeft
                mov     ax, 36-3
                sub     ax, bx          ; ax = 33 - (inX - proximityLeft)
                                        ; bx = inX - proximityLeft
                retn                    ; CF if: proximityLeft + 34 <= inX
                                        ; NC if: proximityLeft <= inX < proximityLeft + 34
; ---------------------------------------------------------------------------

inX_lt_proxLeft:                        ; ...
                mov     ax, 36-3        ; case1:
                                        ; inX < proximityLeft
                sub     ax, bx          ; ax = 33 - inX
                                        ; bx = inX
                jnb     short inX_le_33
                retn                    ; CF if: 33 < inX < proximityLeft
; ---------------------------------------------------------------------------

inX_le_33:                              ; ...
                mov     ax, ds:mapWidth ; case2:
                                        ; inX <= 33 < proximityLeft
                sub     ax, ds:proximity_map_left_col_x
                add     ax, bx          ; ax = mapWidth - proximity_map_left_col_x + inX
                                        ; bx = inX
                xchg    ax, bx          ; ax = inX
                                        ; bx = mapWidth - proximity_map_left_col_x + inX
                mov     ax, 36-3
                sub     ax, bx          ; ax = 33 - (mapWidth - proximity_map_left_col_x + inX)
                                        ; bx = mapWidth - proximity_map_left_col_x + inX
                retn                    ; CF if: 33 - inX < mapWidth - proximity_map_left_col_x
abs_x_to_proximity_rel endp


; =============== S U B R O U T I N E =======================================


horiz_platform_proximity_x_offset proc near ; ...
                add     ax, 2
                mov     bx, ax
                sub     ax, ds:mapWidth
                jnb     short loc_832B
                xchg    ax, bx

loc_832B:                               ; ...
                mov     bx, ax
                sub     ax, ds:proximity_map_left_col_x
                jb      short loc_833A
                xchg    ax, bx
                mov     ax, 37
                sub     ax, bx
                retn
; ---------------------------------------------------------------------------

loc_833A:                               ; ...
                mov     ax, 37
                sub     ax, bx
                jnb     short loc_8342
                retn
; ---------------------------------------------------------------------------

loc_8342:                               ; ...
                mov     ax, ds:mapWidth
                sub     ax, ds:proximity_map_left_col_x
                add     ax, bx
                xchg    ax, bx
                mov     ax, 37
                sub     ax, bx
                retn
horiz_platform_proximity_x_offset endp


; =============== S U B R O U T I N E =======================================


put_dl_to_proximity_layered proc near   ; ...
                test    byte ptr [di], 80h ; monster here?
                jnz     short loc_835A
                mov     [di], dl        ; di is destination
                retn
; ---------------------------------------------------------------------------

loc_835A:                               ; ...
                mov     bl, [di]        ; [di] contains offset to destination table of 128 values
                and     bl, 7Fh         ; bl = monster id
                xor     bh, bh
                mov     ds:proximity_second_layer[bx], dl ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                retn
put_dl_to_proximity_layered endp


; =============== S U B R O U T I N E =======================================


update_and_render_projectile_row_pair proc near ; ...
                mov     si, offset projectiles_array

loc_8369:                               ; ...
                cmp     byte ptr [si], 0FFh
                jnz     short loc_836F
                retn
; ---------------------------------------------------------------------------

loc_836F:                               ; ...
                push    si
                call    flush_dirty_projectile
                pop     si
                mov     al, [si]
                mov     [si+0Bh], al
                sub     al, 4
                cmp     al, 1Ch
                jnb     short loc_83D2
                mov     al, [si+1]
                sub     al, ds:viewport_top_row_y
                and     al, 3Fh
                cmp     al, 12h
                jnb     short loc_83D2
                mov     [si+0Ch], al
                mov     ah, [si+0Bh]
                push    ax
                call    proximity_map_coords_to_viewport_offset ; AL: proximity map relative y
                                        ; AH: proximity map relative x
                                        ; Return: address in DI
                pop     ax
                cmp     byte ptr [di], 0FFh
                jz      short loc_83CD
                cmp     byte ptr [di], 0FCh
                jz      short loc_83CD
                call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
                                        ; AH: x
                                        ; Returns video memory address in DI
                or      di, 8000h
                mov     [si+7], di
                mov     al, [si+2]
                mov     bl, al
                rol     bl, 1
                rol     bl, 1
                and     bx, 3
                mov     bl, ds:masks[bx]
                and     bl, [si+3]
                add     al, bl
                and     al, 3Fh
                and     di, 7FFFh
                call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
                                        ; DI: screen address

loc_83CD:                               ; ...
                add     si, 0Dh
                jmp     short loc_8369
; ---------------------------------------------------------------------------

loc_83D2:                               ; ...
                mov     byte ptr [si], 0
                jmp     short loc_83CD
update_and_render_projectile_row_pair endp

; ---------------------------------------------------------------------------
masks           db 0, 1, 3, 7           ; ...

; =============== S U B R O U T I N E =======================================


Browse_Projectiles proc near            ; ...
                mov     si, offset projectiles_array ; example:
                                        ; 1E 19 2B 00 0F 04 28 00 00 00 00 00 00

loc_83DE:                               ; ...
                cmp     [si+projectile.p_x_rel], 0FFh
                jz      short no_projectiles
                push    si
                call    flush_dirty_projectile
                pop     si
                add     si, 13
                jmp     short loc_83DE
; ---------------------------------------------------------------------------

no_projectiles:                         ; ...
                mov     ds:projectiles_array, 0FFh
                retn
Browse_Projectiles endp


; =============== S U B R O U T I N E =======================================


flush_dirty_projectile proc near        ; ...
                test    [si+projectile.p_field_7], 8000h
                jnz     short loc_83FB
                retn
; ---------------------------------------------------------------------------

loc_83FB:                               ; ...
                and     [si+projectile.p_field_7], 7FFFh
                mov     dx, [si+projectile.p_field_7]
                mov     al, [si+projectile.field_C]
                mov     ah, [si+projectile.field_B]
flush_dirty_projectile endp


; =============== S U B R O U T I N E =======================================


restore_bg_tile_at_given_position proc near ; ...
                push    ax
                call    proximity_map_coords_to_viewport_offset ; AL: proximity map relative y
                                        ; AH: proximity map relative x
                                        ; Return: address in DI
                pop     ax
                cmp     byte ptr [di], 0FCh
                jb      short loc_8414
                retn
; ---------------------------------------------------------------------------

loc_8414:                               ; ...
                add     al, ds:viewport_top_row_y
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, [di]
                jmp     cs:Cached_Tile_Drawer_proc ; AL: Tile Index
restore_bg_tile_at_given_position endp  ; DX: Screen destination


; =============== S U B R O U T I N E =======================================


projectiles_collision_processing proc near ; ...
                mov     si, offset projectiles_array
                mov     di, offset projectiles_array
                push    cs
                pop     es
                assume es:fight
                mov     ds:last_projectile_index, 0

next_projectile:                        ; ...
                mov     al, [si+projectile.p_x_rel]
                or      al, al
                jnz     short loc_843C
                test    [si+projectile.p_field_7], 8000h
                jz      short loc_846A

loc_843C:                               ; ...
                inc     al
                jnz     short loc_8444
                mov     [di+projectile.p_x_rel], 0FFh
                retn
; ---------------------------------------------------------------------------

loc_8444:                               ; ...
                inc     [si+projectile.field_3]
                push    es
                push    di
                call    sub_846F
                pop     di
                pop     es
                assume es:nothing
                push    si
                mov     cx, 13
                rep movsb
                pop     si
                test    [si+projectile.field_5], 40h
                jnz     short loc_8466
                mov     al, [si+projectile.field_3]
                cmp     al, [si+projectile.field_4]
                jb      short loc_8466
                mov     [si+projectile.p_x_rel], 0

loc_8466:                               ; ...
                inc     ds:last_projectile_index

loc_846A:                               ; ...
                add     si, 13
                jmp     short next_projectile
projectiles_collision_processing endp


; =============== S U B R O U T I N E =======================================


sub_846F        proc near               ; ...
                call    projectile_advance_position
                test    [si+projectile.field_5], 8
                jnz     short loc_8490
                mov     ah, [si+projectile.p_x_rel]
                or      ah, ah
                jnz     short loc_847F
                retn
; ---------------------------------------------------------------------------

loc_847F:                               ; ...
                mov     al, [si+projectile.p_y_rel]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, [di]
                call    is_non_blocking_tile_extended
                jz      short loc_8490
                mov     [si+projectile.p_x_rel], 0
                retn
; ---------------------------------------------------------------------------

loc_8490:                               ; ...
                mov     al, ds:viewport_top_row_y
                add     al, ds:hero_head_y_in_viewport
                test    byte ptr ds:squat_flag, 0FFh
                jnz     short loc_84A5
                and     al, 3Fh
                cmp     al, [si+projectile.p_y_rel]
                jz      short loc_84B4

loc_84A5:                               ; ...
                mov     cx, 2

loc_84A8:                               ; ...
                inc     al
                and     al, 3Fh
                cmp     al, [si+projectile.p_y_rel]
                jz      short loc_84B4
                loop    loc_84A8
                retn
; ---------------------------------------------------------------------------

loc_84B4:                               ; ...
                mov     al, ds:hero_x_in_viewport
                add     al, 4
                test    byte ptr ds:facing_direction, 1
                jz      short loc_84C2
                inc     al

loc_84C2:                               ; ...
                cmp     al, [si+projectile.p_x_rel]
                jz      short loc_84CD
                inc     al
                cmp     al, [si+projectile.p_x_rel]
                jz      short loc_84CD
                retn
; ---------------------------------------------------------------------------

loc_84CD:                               ; ...
                mov     [si+projectile.p_x_rel], 0
                test    byte ptr ds:shield_type, 0FFh
                jz      short loc_850E
                test    byte ptr ds:sword_swing_flag, 0FFh
                jnz     short loc_850E
                test    byte ptr ds:on_rope_flags, 0FFh ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                jnz     short loc_850E
                mov     al, [si+projectile.field_5]
                and     al, 7
                cmp     al, 2
                jz      short loc_850E
                cmp     al, 6
                jz      short loc_850E
                or      al, al
                jz      short loc_8507
                cmp     al, 1
                jz      short loc_8507
                cmp     al, 7
                jz      short loc_8507
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_850E
                jmp     short loc_854F
; ---------------------------------------------------------------------------

loc_8507:                               ; ...
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_854F

loc_850E:                               ; ...
                mov     al, [si+projectile.field_6]
                xor     ah, ah
                call    damage_hero     ; ax: damage level
                mov     byte ptr ds:soundFX_request, 9
                mov     al, 0FFh
                mov     ds:byte_9F14, al
                mov     ds:hero_damage_this_frame, al
                mov     bx, 0FFFFh
                mov     cx, 0FFFFh
                mov     al, [si+projectile.field_5]
                and     al, 7
                cmp     al, 2
                jz      short loc_8546
                cmp     al, 6
                jz      short loc_8546
                xor     bx, bx
                or      al, al
                jz      short loc_8546
                cmp     al, 1
                jz      short loc_8546
                cmp     al, 7
                jz      short loc_8546
                xchg    cx, bx

loc_8546:                               ; ...
                mov     ds:word_9F0E, cx
                mov     ds:word_9F10, bx
                retn
; ---------------------------------------------------------------------------

loc_854F:                               ; ...
                cmp     byte ptr ds:shield_type, SHIELD_HONOR
                jnb     short loc_856D
                mov     al, ds:hero_head_y_in_viewport
                add     al, ds:viewport_top_row_y
                inc     al
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_8568
                inc     al

loc_8568:                               ; ...
                call    projectile_y_vs_hero_row_dispatch
                jb      short loc_850E

loc_856D:                               ; ...
                mov     byte ptr ds:soundFX_request, 0Ah
                retn
sub_846F        endp


; =============== S U B R O U T I N E =======================================


projectile_y_vs_hero_row_dispatch proc near ; ...
                mov     bl, [si+projectile.field_5]
                and     bx, 7
                add     bx, bx
                and     al, 3Fh
                jmp     ds:funcs_857D[bx]
projectile_y_vs_hero_row_dispatch endp

; ---------------------------------------------------------------------------
funcs_857D      dw offset check_y_eq_projectile_row ; ...
                dw offset check_prev_y_eq_projectile_row
                dw offset check_prev_y_eq_projectile_row
                dw offset check_prev_y_eq_projectile_row
                dw offset check_y_eq_projectile_row
                dw offset check_next_y_eq_projectile_row
                dw offset check_next_y_eq_projectile_row
                dw offset check_next_y_eq_projectile_row

; =============== S U B R O U T I N E =======================================


check_y_eq_projectile_row proc near     ; ...
                cmp     al, [si+projectile.p_y_rel]
                jnz     short loc_8597
                retn
; ---------------------------------------------------------------------------

loc_8597:                               ; ...
                stc
                retn
check_y_eq_projectile_row endp


; =============== S U B R O U T I N E =======================================


check_prev_y_eq_projectile_row proc near ; ...
                dec     al
                and     al, 3Fh
                jmp     short check_y_eq_projectile_row
check_prev_y_eq_projectile_row endp


; =============== S U B R O U T I N E =======================================


check_next_y_eq_projectile_row proc near ; ...
                inc     al
                and     al, 3Fh
                jmp     short check_y_eq_projectile_row
check_next_y_eq_projectile_row endp


; =============== S U B R O U T I N E =======================================


projectile_advance_position proc near   ; ...
                test    [si+projectile.field_5], 40h
                jz      short loc_85B1
                call    projectile_read_curved_path_step
                jnb     short loc_85B1
                retn
; ---------------------------------------------------------------------------

loc_85B1:                               ; ...
                mov     bl, [si+projectile.field_5] ; trajectory type
                and     bx, 7
                add     bx, bx
                call    ds:funcs_85B9[bx]
                and     [si+projectile.p_y_rel], 3Fh
                retn
projectile_advance_position endp

; ---------------------------------------------------------------------------
funcs_85B9      dw offset incX          ; ...
                dw offset decY
                dw offset decY__
                dw offset decY_
                dw offset decX
                dw offset decX_incY
                dw offset incY
                dw offset incX_incY

; =============== S U B R O U T I N E =======================================


decY            proc near               ; ...
                dec     [si+projectile.p_y_rel]
decY            endp


; =============== S U B R O U T I N E =======================================


incX            proc near               ; ...
                inc     [si+projectile.p_x_rel]
                retn
incX            endp


; =============== S U B R O U T I N E =======================================


incX_incY       proc near               ; ...
                inc     [si+projectile.p_y_rel]
                inc     [si+projectile.p_x_rel]
                retn
incX_incY       endp


; =============== S U B R O U T I N E =======================================


decY_           proc near               ; ...
                dec     [si+projectile.p_y_rel]
decY_           endp


; =============== S U B R O U T I N E =======================================


decX            proc near               ; ...
                dec     [si+projectile.p_x_rel]
                retn
decX            endp


; =============== S U B R O U T I N E =======================================


decX_incY       proc near               ; ...
                inc     [si+projectile.p_y_rel]
                dec     [si+projectile.p_x_rel]
                retn
decX_incY       endp


; =============== S U B R O U T I N E =======================================


incY            proc near               ; ...
                inc     [si+projectile.p_y_rel]
                retn
incY            endp


; =============== S U B R O U T I N E =======================================


decY__          proc near               ; ...
                dec     [si+projectile.p_y_rel]
                retn
decY__          endp


; =============== S U B R O U T I N E =======================================


projectile_read_curved_path_step proc near ; ...
                mov     bl, [si+projectile.field_3]
                xor     bh, bh
                mov     di, [si+projectile.p_field_9]
                mov     al, [bx+di]
                cmp     al, 0FFh
                jnz     short loc_8607
                mov     byte ptr [si+80h], 0
                stc
                retn
; ---------------------------------------------------------------------------

loc_8607:                               ; ...
                and     al, 7
                and     [si+projectile.field_5], 0F8h
                or      [si+projectile.field_5], al
                retn
projectile_read_curved_path_step endp


; =============== S U B R O U T I N E =======================================

; In: BX pointing to projectile struct

Add_Projectile_To_Array proc near       ; ...
                cmp     ds:last_projectile_index, 31 ; max 32 projectiles
                jb      short loc_8619
                retn
; ---------------------------------------------------------------------------

loc_8619:                               ; ...
                push    si
                push    cs
                pop     es
                mov     si, bx
                mov     di, offset projectiles_array

find_array_end:                         ; ...
                cmp     byte ptr [di], 0FFh
                jz      short found_end_marker
                add     di, 13
                jmp     short find_array_end
; ---------------------------------------------------------------------------

found_end_marker:                       ; ...
                mov     cx, 13
                rep movsb               ; add new projectile to array
                mov     al, 0FFh        ; set end marker
                stosb
                inc     ds:last_projectile_index
                pop     si
                retn
Add_Projectile_To_Array endp


; =============== S U B R O U T I N E =======================================


every_projectile_moves_left_in_viewport proc near ; ...
                mov     si, offset projectiles_array

next_projectile_:                        ; ...
                mov     al, [si+projectile.p_x_rel]
                cmp     al, 0FFh
                jnz     short loc_8643
                retn
; ---------------------------------------------------------------------------

loc_8643:                               ; ...
                or      al, al
                jz      short loc_8649
                dec     [si+projectile.p_x_rel]

loc_8649:                               ; ...
                add     si, 13
                jmp     short next_projectile_
every_projectile_moves_left_in_viewport endp


; =============== S U B R O U T I N E =======================================


every_projectile_moves_right_in_viewport proc near ; ...
                mov     si, offset projectiles_array

next_projectile__:                        ; ...
                mov     al, [si+projectile.p_x_rel]
                cmp     al, 0FFh
                jnz     short loc_8658
                retn
; ---------------------------------------------------------------------------

loc_8658:                               ; ...
                or      al, al
                jz      short loc_865E
                inc     [si+projectile.p_x_rel]

loc_865E:                               ; ...
                add     si, 13
                jmp     short next_projectile__
every_projectile_moves_right_in_viewport endp


; =============== S U B R O U T I N E =======================================

; AL: proximity map relative y
; AH: proximity map relative x
; Return: address in DI

proximity_map_coords_to_viewport_offset proc near ; ...
                and     al, 3Fh         ; clamp y
                mov     bl, ah          ; proximity map relative x
                mov     bh, 28          ; viewport width
                mul     bh              ; ax=row offset in viewport buffer
                sub     bl, 4           ; viewport relative x
                xor     bh, bh
                add     ax, bx
                mov     di, ax
                add     di, offset viewport_buffer_28x19
                retn
proximity_map_coords_to_viewport_offset endp


; =============== S U B R O U T I N E =======================================


render_and_collision_pass_row proc near ; ...
                mov     si, offset spirit_sprite_0
                mov     cx, 4

next_spirit:                            ; ...
                push    cx
                cmp     byte ptr [si], 0FFh
                jz      short loc_86DC
                call    restore_bg_under_spirit_sprite
                test    byte ptr [si+2], 0FFh
                jnz     short loc_8693
                mov     byte ptr [si], 0FFh
                jmp     short loc_86DC
; ---------------------------------------------------------------------------

loc_8693:                               ; ...
                mov     bl, [si]
                and     bl, 0Fh
                xor     bh, bh
                add     bx, bx
                add     bx, offset circle ;
                                        ; ..345..
                                        ; .2...6.
                                        ; 1.....7
                                        ; 0.....8
                                        ; f.....9
                                        ; .e...a.
                                        ; ..dcb..
                mov     ah, ds:hero_x_in_viewport
                add     ah, [bx]
                mov     [si+5], ah
                mov     al, ds:hero_head_y_in_viewport
                add     al, [bx+1]
                and     al, 3Fh
                mov     [si+6], al
                push    ax
                call    proximity_map_coords_to_viewport_offset ; AL: proximity map relative y
                                        ; AH: proximity map relative x
                                        ; Return: address in DI
                pop     ax
                cmp     byte ptr [di], 0FFh
                jz      short loc_86DC
                cmp     byte ptr [di], 0FCh
                jz      short loc_86DC
                call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
                                        ; AH: x
                                        ; Returns video memory address in DI
                or      di, 8000h
                mov     [si+3], di
                mov     al, 66h ; 'f'
                and     di, 7FFFh
                push    si
                call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
                                        ; DI: screen address
                pop     si

loc_86DC:                               ; ...
                add     si, 7
                pop     cx
                loop    next_spirit
                retn
render_and_collision_pass_row endp


; =============== S U B R O U T I N E =======================================


restore_bg_under_spirit_sprite proc near ; ...
                test    word ptr [si+3], 8000h
                jnz     short loc_86EB
                retn
; ---------------------------------------------------------------------------

loc_86EB:                               ; ...
                and     word ptr [si+3], 7FFFh
                mov     dx, [si+3]
                mov     ah, [si+5]
                mov     al, [si+6]
                jmp     restore_bg_tile_at_given_position
restore_bg_under_spirit_sprite endp


; =============== S U B R O U T I N E =======================================


monsters_updates proc near              ; ...
                mov     si, offset spirit_sprite_0
                mov     cx, 4

next_spirit_:                            ; ...
                push    cx
                cmp     [si+spirit.field_0], 0FFh
                jz      short loc_873A
                mov     bl, [si+spirit.field_0]
                add     bl, [si+spirit.field_1]
                and     bl, 0Fh
                mov     [si+spirit.field_0], bl
                xor     bh, bh
                add     bx, bx
                add     bx, offset circle ;
                                        ; ..345..
                                        ; .2...6.
                                        ; 1.....7
                                        ; 0.....8
                                        ; f.....9
                                        ; .e...a.
                                        ; ..dcb..
                mov     ah, ds:hero_x_in_viewport
                add     ah, [bx]
                mov     al, ds:hero_head_y_in_viewport
                add     al, [bx+1]
                add     al, ds:viewport_top_row_y
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    si, di
                sub     si, 37
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                call    spirit_sprite_place_in_proximity_rows

loc_873A:                               ; ...
                add     si, 7
                pop     cx
                loop    next_spirit_
                retn
monsters_updates endp


; =============== S U B R O U T I N E =======================================


spirit_sprite_place_in_proximity_rows proc near ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_8750
                test    byte ptr ds:boss_is_dead, 0FFh
                jz      short loc_8750
                retn
; ---------------------------------------------------------------------------

loc_8750:                               ; ...
                call    proximity_cell_inject_spell_target
                inc     di
                call    proximity_cell_inject_spell_target
                xchg    si, di
                add     si, 35
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                call    proximity_cell_inject_spell_target
                inc     di
spirit_sprite_place_in_proximity_rows endp


; =============== S U B R O U T I N E =======================================


proximity_cell_inject_spell_target proc near ; ...
                test    byte ptr [si+2], 0FFh
                jnz     short loc_876C
                retn
; ---------------------------------------------------------------------------

loc_876C:                               ; ...
                xchg    si, di
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                xchg    si, di
                jnb     short loc_8776
                retn
; ---------------------------------------------------------------------------

loc_8776:                               ; ...
                test    byte ptr [bx+4], 20h
                jz      short loc_877D
                retn
; ---------------------------------------------------------------------------

loc_877D:                               ; ...
                test    byte ptr [bx+5], 20h
                jz      short loc_8784
                retn
; ---------------------------------------------------------------------------

loc_8784:                               ; ...
                and     byte ptr [bx+5], 0E0h
                or      byte ptr [bx+5], 49h
                dec     byte ptr [si+2]
                retn
proximity_cell_inject_spell_target endp

; ---------------------------------------------------------------------------
circle          dw 102h                 ; ...
                                        ;
                                        ; ..345..
                                        ; .2...6.
                                        ; 1.....7
                                        ; 0.....8
                                        ; f.....9
                                        ; .e...a.
                                        ; ..dcb..
                dw 2
                dw 0FF03h
                dw 0FE04h
                dw 0FE05h
                dw 0FE06h
                dw 0FF07h
                dw 8
                dw 108h
                dw 208h
                dw 307h
                dw 406h
                dw 405h
                dw 404h
                dw 303h
                dw 202h

; =============== S U B R O U T I N E =======================================


magic_spell_fire_handler proc near      ; ...
                test    byte ptr ds:current_magic_spell, 0FFh
                jnz     short loc_87B8
                retn
; ---------------------------------------------------------------------------

loc_87B8:                               ; ...
                test    byte ptr ds:spell_active_flag, 0FFh
                jnz     short loc_87F1
                test    byte ptr ds:byte_FF1E, 0FFh
                jnz     short loc_87C7
                retn
; ---------------------------------------------------------------------------

loc_87C7:                               ; ...
                mov     byte ptr ds:byte_FF1D, 0
                mov     byte ptr ds:byte_FF1E, 0
                test    byte ptr ds:sword_swing_flag, 0FFh
                jz      short loc_87D9
                retn
; ---------------------------------------------------------------------------

loc_87D9:                               ; ...
                test    byte ptr ds:byte_FF3E, 0FFh
                jz      short loc_87E1
                retn
; ---------------------------------------------------------------------------

loc_87E1:                               ; ...
                mov     ds:byte_9F2B, 0
                mov     byte ptr ds:spell_active_flag, 0FFh
                mov     byte ptr ds:soundFX_request, 17h
                retn
; ---------------------------------------------------------------------------

loc_87F1:                               ; ...
                add     ds:byte_9F2B, 2
                cmp     ds:byte_9F2B, 4
                jz      short loc_880B
                cmp     ds:byte_9F2B, 6
                jnb     short loc_8805
                retn
; ---------------------------------------------------------------------------

loc_8805:                               ; ...
                mov     byte ptr ds:spell_active_flag, 0
                retn
; ---------------------------------------------------------------------------

loc_880B:                               ; ...
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                test    byte ptr ds:magic_spells[bx], 0FFh
                jnz     short loc_881B
                retn
; ---------------------------------------------------------------------------

loc_881B:                               ; ...
                dec     byte ptr ds:magic_spells[bx]
                call    cs:Print_Magic_Left_Decimal_proc
                mov     byte ptr ds:soundFX_request, 18h
                mov     si, offset magic_projectiles
                mov     byte ptr ds:byte_FF3E, 0FFh
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_883B[bx]
magic_spell_fire_handler endp

; ---------------------------------------------------------------------------
funcs_883B      dw offset init_magic_projectile ; ...
                dw offset init_magic_projectile
                dw offset init_magic_projectile
                dw offset init_magic_projectile
                dw offset init_rascar
                dw offset init_agua
                dw offset init_guerra

; =============== S U B R O U T I N E =======================================


init_magic_projectile proc near         ; ...
                mov     al, ds:facing_direction
                not     al
                and     al, 1
                mov     [si+magic_projectile.field_3], al
                mov     al, ds:squat_flag
                and     al, 1
                add     al, ds:hero_head_y_in_viewport
                add     al, ds:viewport_top_row_y
                and     al, 3Fh
                mov     [si+magic_projectile.mp_y_rel], al
                mov     al, ds:hero_x_in_viewport
                add     al, 4
                mov     ah, [si+magic_projectile.field_3]
                not     ah
                and     ah, 1
                add     al, ah
                xor     ah, ah
                add     ax, ds:proximity_map_left_col_x
                cmp     ax, ds:mapWidth
                jb      short loc_8888
                sub     ax, ds:mapWidth

loc_8888:                               ; ...
                mov     [si+magic_projectile.mp_x_rel], ax
                mov     [si+magic_projectile.mp_field_9], 0
                mov     [si+magic_projectile.field_B], 0
                mov     [si+magic_projectile.field_D], 0
                mov     [si+magic_projectile.field_F], 0
                mov     [si+magic_projectile.field_4], 0
                mov     [si+magic_projectile.field_5], 0
                mov     word ptr [si+16], 0FFFFh ; terminate
                retn
init_magic_projectile endp


; =============== S U B R O U T I N E =======================================


init_rascar     proc near               ; ...
                mov     cx, 4

four_beams_of_rascar:                   ; ...
                push    cx
                mov     al, 6
                mul     cl
                add     ax, 2
                add     ax, ds:proximity_map_left_col_x
                cmp     ax, ds:mapWidth
                jb      short loc_88C1
                sub     ax, ds:mapWidth

loc_88C1:                               ; ...
                mov     [si], ax
                call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
                                        ;
                                        ; mov     ax, cs:0FF1Bh
                                        ; add     al, ah          ; ax += ah
                                        ; adc     ah, 0
                                        ; add     ax, cs:word_92B
                                        ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
                and     al, 3
                mov     ah, ds:viewport_top_row_y
                sub     ah, 3
                sub     ah, al
                and     ah, 3Fh
                mov     [si+2], ah
                mov     byte ptr [si+9], 0
                mov     byte ptr [si+0Bh], 0
                mov     byte ptr [si+0Dh], 0
                mov     byte ptr [si+0Fh], 0
                mov     byte ptr [si+4], 0
                mov     byte ptr [si+5], 0
                add     si, 10h
                pop     cx
                loop    four_beams_of_rascar
                retn
init_rascar     endp


; =============== S U B R O U T I N E =======================================


init_agua       proc near               ; ...
                push    si
                mov     cx, 3

loc_88FC:                               ; ...
                push    cx
                call    init_magic_projectile
                add     si, 10h
                pop     cx
                loop    loc_88FC
                pop     si
                sub     byte ptr [si+2], 2
                and     byte ptr [si+2], 3Fh
                add     byte ptr [si+12h], 2
                and     byte ptr [si+12h], 3Fh
                retn
init_agua       endp


; =============== S U B R O U T I N E =======================================


init_guerra     proc near               ; ...
                mov     ds:byte_9EED, 0FFh
                mov     ds:byte_9EEE, 0FFh
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_8930
                test    byte ptr ds:boss_being_hit, 0FFh
                jnz     short loc_8954

loc_8930:                               ; ...
                mov     si, ds:viewport_top_offset
                sub     si, 36          ; up from hero
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     cx, 19

rows_19:                                ; ...
                push    cx
                mov     cx, 36

columns_36:                             ; ...
                push    cx
                test    byte ptr [si], 80h
                jz      short loc_894A
                call    mark_proximity_monster_as_spell_target

loc_894A:                               ; ...
                inc     si
                pop     cx
                loop    columns_36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                pop     cx
                loop    rows_19

loc_8954:                               ; ...
                mov     byte ptr ds:byte_FF3E, 0
                mov     byte ptr ds:soundFX_request, 19h
                call    cs:word_3018
                mov     byte ptr ds:byte_FF1E, 0
                call    clear_viewport_buffer
                jmp     main_update_render
init_guerra     endp


; =============== S U B R O U T I N E =======================================


update_active_projectiles_render proc near ; ...
                mov     si, offset magic_projectiles
                mov     cx, 4

next_magic_projectile:                  ; ...
                cmp     [si+magic_projectile.mp_x_rel], 0FFFFh
                jnz     short loc_897A
                retn
; ---------------------------------------------------------------------------

loc_897A:                               ; ...
                push    cx
                call    projectile_erase_old_tiles
                cmp     byte ptr [si+1], 0FFh
                jnz     short loc_898B
                mov     [si+magic_projectile.mp_x_rel], 0FFFFh
                jmp     loc_8A2B
; ---------------------------------------------------------------------------

loc_898B:                               ; ...
                mov     bl, [si+magic_projectile.field_5]
                add     bl, bl
                add     bl, bl
                xor     bh, bh
                mov     al, ds:current_magic_spell
                dec     al
                add     al, al
                xor     ah, ah
                mov     di, offset sequences0
                test    [si+magic_projectile.field_3], 0FFh
                jnz     short loc_89A9
                mov     di, offset sequences1

loc_89A9:                               ; ...
                add     di, ax
                mov     di, [di]
                add     di, bx
                mov     ax, [si+magic_projectile.mp_x_rel]
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jb      short loc_8A2B
                mov     [si+magic_projectile.field_6], bl
                mov     al, [si+magic_projectile.mp_y_rel]
                sub     al, ds:viewport_top_row_y
                and     al, 3Fh
                mov     [si+magic_projectile.mp_field_7], al
                mov     bh, al
                xchg    bh, bl
                push    si
                add     si, 8
                mov     bp, offset byte_8C79
                mov     cx, 4

loc_89D3:                               ; ...
                push    cx
                push    bx
                push    bp
                add     bh, ds:[bp+0]
                mov     al, bh
                sub     al, 4
                cmp     al, 28
                jnb     short outside_viewport
                inc     bp
                add     bl, ds:[bp+0]
                and     bl, 3Fh
                cmp     bl, 18
                jnb     short outside_viewport
                mov     al, [di]
                push    di
                push    ax
                mov     ax, bx
                push    ax
                call    proximity_map_coords_to_viewport_offset ; AL: proximity map relative y
                                        ; AH: proximity map relative x
                                        ; Return: address in DI
                pop     ax
                cmp     byte ptr [di], 0FFh
                jz      short loc_8A1E
                cmp     byte ptr [di], 0FCh
                jz      short loc_8A1E
                call    cs:Viewport_Coords_To_Screen_Addr_proc ; AL: y
                                        ; AH: x
                                        ; Returns video memory address in DI
                or      di, 8000h
                mov     [si], di
                and     di, 7FFFh
                pop     ax
                push    si
                call    cs:Uncompress_And_Render_Tile_proc ; AL: tile index
                                        ; DI: screen address
                pop     si
                pop     di
                jmp     short outside_viewport
; ---------------------------------------------------------------------------

loc_8A1E:                               ; ...
                pop     ax
                pop     di

outside_viewport:                       ; ...
                pop     bp
                inc     si
                inc     si
                inc     di
                inc     bp
                inc     bp
                pop     bx
                pop     cx
                loop    loc_89D3
                pop     si

loc_8A2B:                               ; ...
                add     si, 16
                pop     cx
                loop    next_magic_projectile_
                jmp     short locret_8A36
; ---------------------------------------------------------------------------

next_magic_projectile_:                 ; ...
                jmp     next_magic_projectile
; ---------------------------------------------------------------------------

locret_8A36:                            ; ...
                retn
update_active_projectiles_render endp


; =============== S U B R O U T I N E =======================================


projectile_erase_old_tiles proc near    ; ...
                test    word ptr [si+8], 8000h
                jz      short loc_8A51
                and     word ptr [si+8], 7FFFh
                mov     dx, [si+8]
                mov     ah, [si+6]
                mov     al, [si+7]
                push    si
                call    restore_bg_tile_at_given_position
                pop     si

loc_8A51:                               ; ...
                test    word ptr [si+0Ah], 8000h
                jz      short loc_8A6D
                and     word ptr [si+0Ah], 7FFFh
                mov     dx, [si+0Ah]
                mov     ah, [si+6]
                inc     ah
                mov     al, [si+7]
                push    si
                call    restore_bg_tile_at_given_position
                pop     si

loc_8A6D:                               ; ...
                test    word ptr [si+0Ch], 8000h
                jz      short loc_8A8B
                and     word ptr [si+0Ch], 7FFFh
                mov     dx, [si+0Ch]
                mov     ah, [si+6]
                mov     al, [si+7]
                inc     al
                and     al, 3Fh
                push    si
                call    restore_bg_tile_at_given_position
                pop     si

loc_8A8B:                               ; ...
                test    word ptr [si+0Eh], 8000h
                jnz     short loc_8A93
                retn
; ---------------------------------------------------------------------------

loc_8A93:                               ; ...
                and     word ptr [si+0Eh], 7FFFh
                mov     dx, [si+0Eh]
                mov     ah, [si+6]
                inc     ah
                mov     al, [si+7]
                inc     al
                and     al, 3Fh
                push    si
                call    restore_bg_tile_at_given_position
                pop     si
                retn
projectile_erase_old_tiles endp


; =============== S U B R O U T I N E =======================================


dispatch_spell_projectile_movement proc near ; ...
                test    byte ptr ds:byte_FF3E, 0FFh
                jnz     short loc_8AB5
                retn
; ---------------------------------------------------------------------------

loc_8AB5:                               ; ...
                mov     si, offset magic_projectiles
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_8AC2[bx]
dispatch_spell_projectile_movement endp

; ---------------------------------------------------------------------------
funcs_8AC2      dw offset espada_move   ; ...
                dw offset saeta_move
                dw offset fuego_move
                dw offset saeta_move
                dw offset rascar_move
                dw offset agua_move
                dw offset locret_8B9C

; =============== S U B R O U T I N E =======================================


espada_move     proc near               ; ...
                test    [si+magic_projectile.field_3], 80h
                jz      short loc_8ADD
                jmp     loc_8BB5
; ---------------------------------------------------------------------------

loc_8ADD:                               ; ...
                inc     [si+magic_projectile.field_4]
                cmp     [si+magic_projectile.field_4], 5
                jb      short loc_8AE9
                jmp     loc_8BB5
; ---------------------------------------------------------------------------

loc_8AE9:                               ; ...
                call    sub_8BC2
                call    monster_is_in_spawn_range_and_clear
                jnb     short loc_8AF2
                retn
; ---------------------------------------------------------------------------

loc_8AF2:                               ; ...
                or      [si+magic_projectile.field_3], 80h
                retn
espada_move     endp


; =============== S U B R O U T I N E =======================================


saeta_move      proc near               ; ...
                inc     [si+magic_projectile.field_4]
                cmp     [si+magic_projectile.field_4], 0Ah
                jb      short loc_8B03
                jmp     loc_8BB5
; ---------------------------------------------------------------------------

loc_8B03:                               ; ...
                call    sub_8BC2
                jmp     monster_is_in_spawn_range_and_clear
saeta_move      endp


; =============== S U B R O U T I N E =======================================


fuego_move      proc near               ; ...
                inc     [si+magic_projectile.field_4]
                cmp     [si+magic_projectile.field_4], 0Ch
                jb      short loc_8B15
                jmp     loc_8BB5
; ---------------------------------------------------------------------------

loc_8B15:                               ; ...
                cmp     [si+magic_projectile.field_4], 4
                jnb     short loc_8B20
                call    loc_8BD0
                jmp     short loc_8B61
; ---------------------------------------------------------------------------

loc_8B20:                               ; ...
                and     [si+magic_projectile.field_5], 3
                inc     [si+magic_projectile.field_5]
                cmp     [si+magic_projectile.field_4], 3
                jz      short loc_8B61
                mov     ax, [si+magic_projectile.mp_x_rel]
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jb      short loc_8B61
                cmp     bl, 33
                jnb     short loc_8B61
                mov     ah, bl
                mov     al, [si+magic_projectile.mp_y_rel]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    si, di
                add     si, 72
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     al, [di]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_8B61
                mov     al, [di+1]
                call    is_non_blocking_tile ; ZF if can pass
                jnz     short loc_8B61
                inc     [si+magic_projectile.mp_y_rel]
                and     [si+magic_projectile.mp_y_rel], 3Fh

loc_8B61:                               ; ...
                jmp     monster_is_in_spawn_range_and_clear
fuego_move      endp


; =============== S U B R O U T I N E =======================================


rascar_move     proc near               ; ...
                inc     [si+magic_projectile.field_4]
                cmp     [si+magic_projectile.field_4], 0Ch
                jnb     short loc_8B9D
                mov     cx, 4

loc_8B70:                               ; ...
                push    cx
                add     [si+magic_projectile.mp_y_rel], 2
                and     [si+magic_projectile.mp_y_rel], 3Fh
                call    monster_is_in_spawn_range_and_clear
                add     si, 10h
                pop     cx
                loop    loc_8B70
                retn
rascar_move     endp


; =============== S U B R O U T I N E =======================================


agua_move       proc near               ; ...
                inc     [si+magic_projectile.field_4]
                cmp     [si+magic_projectile.field_4], 0Ah
                jnb     short loc_8BA5
                mov     cx, 3

loc_8B8F:                               ; ...
                push    cx
                call    sub_8BC2
                call    monster_is_in_spawn_range_and_clear
                add     si, 10h
                pop     cx
                loop    loc_8B8F

locret_8B9C:                            ; ...
                retn
; ---------------------------------------------------------------------------

loc_8B9D:                               ; ...
                mov     byte ptr [si+30h], 0
                mov     byte ptr [si+31h], 0FFh

loc_8BA5:                               ; ...
                mov     byte ptr [si+20h], 0
                mov     byte ptr [si+21h], 0FFh
                mov     byte ptr [si+10h], 0
                mov     byte ptr [si+11h], 0FFh

loc_8BB5:                               ; ...
                mov     byte ptr [si], 0
                mov     byte ptr [si+1], 0FFh
                mov     byte ptr ds:byte_FF3E, 0
                retn
agua_move       endp


; =============== S U B R O U T I N E =======================================


sub_8BC2        proc near               ; ...
                mov     al, [si+magic_projectile.field_5]
                inc     al
                cmp     al, 3
                jb      short loc_8BCD
                xor     al, al

loc_8BCD:                               ; ...
                mov     [si+magic_projectile.field_5], al

loc_8BD0:                               ; ...
                mov     ax, [si+magic_projectile.mp_x_rel]
                mov     bl, [si+magic_projectile.field_3]
                and     bx, 1
                add     bx, bx
                add     bx, bx
                dec     bx
                dec     bx
                add     ax, bx
                or      ax, ax
                jns     short loc_8BEA
                add     ax, ds:mapWidth
                jmp     short loc_8BF4
; ---------------------------------------------------------------------------

loc_8BEA:                               ; ...
                cmp     ax, ds:mapWidth
                jb      short loc_8BF4
                sub     ax, ds:mapWidth

loc_8BF4:                               ; ...
                mov     [si], ax
                retn
sub_8BC2        endp


; =============== S U B R O U T I N E =======================================


monster_is_in_spawn_range_and_clear proc near ; ...
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_8C07
                test    byte ptr ds:boss_being_hit, 0FFh
                stc
                jz      short loc_8C07
                retn
; ---------------------------------------------------------------------------

loc_8C07:                               ; ...
                mov     ax, [si+magic_projectile.mp_x_rel]
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jnb     short loc_8C0F
                retn
; ---------------------------------------------------------------------------

loc_8C0F:                               ; ...
                mov     ah, bl
                sub     bl, 2
                cmp     bl, 20h ; ' '
                cmc
                jnb     short loc_8C1B
                retn
; ---------------------------------------------------------------------------

loc_8C1B:                               ; ...
                mov     al, [si+magic_projectile.mp_y_rel]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                push    si
                xchg    di, si
                sub     si, 37
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                mov     ds:byte_9F2A, 0
                mov     cx, 3

loc_8C32:                               ; ...
                push    cx
                mov     cx, 3

loc_8C36:                               ; ...
                push    cx
                call    mark_proximity_monster_as_spell_target
                pop     cx
                inc     si
                loop    loc_8C36
                add     si, 33
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                pop     cx
                loop    loc_8C32
                pop     si
                mov     al, ds:byte_9F2A
                add     al, al
                cmc
                retn
monster_is_in_spawn_range_and_clear endp


; =============== S U B R O U T I N E =======================================


mark_proximity_monster_as_spell_target proc near ; ...
                call    get_dst_monster_flags ; CF: no monster
                                        ; NC: active monster; al=type, bx=monster struct
                jnb     short loc_8C55
                retn
; ---------------------------------------------------------------------------

loc_8C55:                               ; ...
                test    al, 20h
                jz      short loc_8C5A
                retn
; ---------------------------------------------------------------------------

loc_8C5A:                               ; ...
                test    [bx+monster.ai_flags], 20h
                jz      short loc_8C61
                retn
; ---------------------------------------------------------------------------

loc_8C61:                               ; ...
                mov     al, [bx+monster.ai_flags]
                or      al, 40h
                and     al, 0E0h
                mov     ah, ds:current_magic_spell
                inc     ah
                or      al, ah
                mov     [bx+monster.ai_flags], al
                mov     ds:byte_9F2A, 0FFh
                retn
mark_proximity_monster_as_spell_target endp

; ---------------------------------------------------------------------------
byte_8C79       db 0, 0, 1, 0, 0, 1, 1, 1 ; ...
sequences0      dw offset byte_8C99     ; ...
                dw offset byte_8CA5
                dw offset byte_8CBD
                dw offset byte_8CE5
                dw offset byte_8CFD
                dw offset byte_8D01
sequences1      dw offset byte_8C99     ; ...
                dw offset byte_8CB1
                dw offset byte_8CD1
                dw offset byte_8CF1
                dw offset byte_8CFD
                dw offset byte_8D0D
byte_8C99       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
byte_8CA5       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
byte_8CB1       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
byte_8CBD       db 67h, 68h, 69h, 6Ah, 6Fh, 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
byte_8CD1       db 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
byte_8CE5       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
byte_8CF1       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...
byte_8CFD       db 73h, 74h, 75h, 76h   ; ...
byte_8D01       db 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh, 70h, 71h, 72h ; ...
byte_8D0D       db 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh ; ...

; =============== S U B R O U T I N E =======================================


monsters_spawning proc near             ; ...
                mov     si, ds:monsters_table_addr ; d62e - *.mdt contains after the Place Name, the table of all monsters
                mov     al, ds:is_boss_cavern
                or      al, ds:is_jashiin_cavern
                jz      short loc_8D2B
                jmp     cs:Monster_AI_proc
; ---------------------------------------------------------------------------

loc_8D2B:                               ; ...
                mov     byte ptr ds:monster_index, 0

next_monster2:                           ; ...
                mov     ax, [si+monster.currX]
                cmp     ax, 0FFFFh      ; end-monsters-marker
                jnz     short loc_8D38
                retn                    ; all monsters processed
; ---------------------------------------------------------------------------

loc_8D38:                               ; ...
                mov     [si+monster.m_x_rel], 0FFh
                cmp     ah, 0FFh
                jz      short skip
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jb      short skip
                mov     [si+monster.m_x_rel], bl
                call    place_monster_in_proximity_and_run_ai
                cmp     byte ptr [si+1], 0FFh ; monster x coord high byte; ff => stationary item
                jz      short skip
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     bl, ds:monster_index
                xor     bh, bh
                mov     al, bl
                or      al, 80h
                xchg    al, [di]
                mov     ds:proximity_second_layer[bx], al ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                test    [si+monster.flags], 10001b
                jnz     short skip
                test    [si+monster.state_flags], 10000b
                jz      short skip
                xchg    si, di
                add     si, 72
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     bl, ds:monster_index
                inc     bl
                xor     bh, bh
                mov     al, bl
                or      al, 80h
                xchg    al, [di]
                mov     ds:proximity_second_layer[bx], al ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)

skip:                                   ; ...
                test    [si+monster.state_flags], 100000b
                jnz     short loc_8DA5
                mov     al, [si+monster.counter]
                inc     al
                jz      short loc_8DA0
                mov     [si+monster.counter], al

loc_8DA0:                               ; ...
                jnz     short loc_8DA5
                call    monster_activation

loc_8DA5:                               ; ...
                inc     byte ptr ds:monster_index
                add     si, 16
                jmp     short next_monster2
monsters_spawning endp


; =============== S U B R O U T I N E =======================================


place_monster_in_proximity_and_run_ai proc near ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, [si+monster.ai_flags]
                and     al, 0DFh
                test    al, 40h
                jz      short loc_8DC7
                test    [si+monster.flags], 20h
                jnz     short loc_8DC5
                or      al, 20h

loc_8DC5:                               ; ...
                and     al, 0BFh

loc_8DC7:                               ; ...
                mov     [si+monster.ai_flags], al
                mov     al, ds:monster_index
                mov     bx, offset proximity_second_layer ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                xlat
                mov     [di], al
                test    [si+monster.flags], 11h
                jnz     short loc_8DF1
                test    [si+monster.state_flags], 10h
                jz      short loc_8DF1
                xchg    si, di
                add     si, 2*36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     al, ds:monster_index
                inc     al
                xlat
                mov     [di], al

loc_8DF1:                               ; ...
                test    [si+monster.flags], 11000b
                jnz     short loc_8DFC
                jmp     cs:Monster_AI_proc
; ---------------------------------------------------------------------------

loc_8DFC:                               ; ...
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_8DFE:                               ; ...
                xor     bh, bh
                mov     bl, [si+monster.flags]
                and     bl, 1Fh
                sub     bl, 10h
                jnb     short loc_8E0E
                jmp     loc_90E6
; ---------------------------------------------------------------------------

loc_8E0E:                               ; ...
                add     bx, bx          ; switch 15 cases
                jmp     ds:jpt_8E10[bx] ; switch jump
; ---------------------------------------------------------------------------
jpt_8E10        dw offset flag_10       ; ...
                dw offset flag_11       ; jump table for switch statement
                dw offset flag_12
                dw offset flag_13
                dw offset flag_14_15_1b
                dw offset flag_14_15_1b
                dw offset flag_16
                dw offset flag_17
                dw offset flag_18
                dw offset flag_19
                dw offset flag_1a
                dw offset flag_14_15_1b
                dw offset flag_1c
                dw offset flag_1d
                dw offset flag_1e
; ---------------------------------------------------------------------------

flag_10:                                ; ...
                test    [si+monster.ai_timer], 1 ; jumptable 00008E10 case 0
                jnz     short loc_8E54
                test    [si+monster.ai_flags], 100000b
                jnz     short loc_8E3F
                retn
; ---------------------------------------------------------------------------

loc_8E3F:                               ; ...
                mov     byte ptr ds:soundFX_request, 12h
                and     [si+monster.ai_flags], 10010000b
                and     [si+monster.flags], 1111111b
                or      [si+monster.flags], 1100000b
                or      [si+monster.ai_timer], 1

loc_8E54:                               ; ...
                add     [si+monster.anim_counter], 80h
                jb      short loc_8E5B
                retn
; ---------------------------------------------------------------------------

loc_8E5B:                               ; ...
                inc     [si+monster.anim_counter]
                cmp     [si+monster.anim_counter], 4
                jnb     short loc_8E65
                retn
; ---------------------------------------------------------------------------

loc_8E65:                               ; ...
                mov     [si+monster.anim_counter], 0
                mov     al, [si+monster.ai_state]
                or      al, al
                jnz     short loc_8E73
                jmp     loc_914C
; ---------------------------------------------------------------------------

loc_8E73:                               ; ...
                test    al, 10h
                jz      short loc_8E81
                or      al, 60h
                or      [si+monster.state_flags], 80h
                mov     [si+monster.counter], 0

loc_8E81:                               ; ...
                mov     [si+monster.flags], al
                and     [si+monster.ai_flags], 80h
                mov     [si+monster.ai_state], 0
                retn
; ---------------------------------------------------------------------------

flag_11:                                ; ...
                test    [si+monster.ai_timer], 1 ; jumptable 00008E10 case 1
                jnz     short loc_8ECA
                mov     ah, [si+monster.currY]
                sub     ah, 3
                and     ah, 3Fh
                cmp     ah, ds:hero_y_absolute
                jz      short loc_8EA3
                retn
; ---------------------------------------------------------------------------

loc_8EA3:                               ; ...
                mov     al, ds:hero_x_in_viewport
                add     al, 3
                mov     ah, ds:facing_direction
                and     ah, 1
                add     ah, ah
                add     al, ah
                mov     cx, 2

loc_8EB6:                               ; ...
                cmp     al, [si+monster.m_x_rel]
                jz      short loc_8EC0
                inc     al
                loop    loc_8EB6
                retn
; ---------------------------------------------------------------------------

loc_8EC0:                               ; ...
                mov     byte ptr ds:soundFX_request, 12h
                or      [si+monster.ai_timer], 1
                retn
; ---------------------------------------------------------------------------

loc_8ECA:                               ; ...
                and     [si+monster.flags], 7Fh
                call    move_monster_S
                add     [si+monster.anim_counter], 80h
                jb      short loc_8ED8
                retn
; ---------------------------------------------------------------------------

loc_8ED8:                               ; ...
                inc     [si+monster.anim_counter]
                cmp     [si+monster.anim_counter], 4
                jnb     short loc_8EE2
                retn
; ---------------------------------------------------------------------------

loc_8EE2:                               ; ...
                mov     [si+monster.anim_counter], 0
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_12:                                ; ...
                inc     [si+monster.anim_counter] ; jumptable 00008E10 case 2
                cmp     [si+monster.anim_counter], 3
                jz      short loc_8EF3
                retn
; ---------------------------------------------------------------------------

loc_8EF3:                               ; ...
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_13:                                ; ...
                call    check_monster_aligned_to_hero_and_tick ; jumptable 00008E10 case 3
                jnb     short loc_8EFC
                retn
; ---------------------------------------------------------------------------

loc_8EFC:                               ; ...
                mov     byte ptr ds:soundFX_request, 14h
                test    [si+monster.anim_counter], 0Fh
                jnz     short chest
                mov     al, [si+monster.ai_state]
                test    al, 10h
                jz      short loc_8F18
                or      al, 60h
                or      [si+monster.state_flags], 80h
                mov     [si+monster.counter], 0

loc_8F18:                               ; ...
                mov     [si+monster.flags], al
                mov     [si+monster.ai_state], 0
                retn
; ---------------------------------------------------------------------------

chest:                                  ; ...
                call    loc_914C
                mov     bl, [si+monster.anim_counter]
                and     bl, 0Fh         ; 1..8
                dec     bl
                add     bl, bl
                xor     bh, bh
                jmp     ds:off_8F33[bx]
; ---------------------------------------------------------------------------
off_8F33        dw offset got_50_gold   ; ...
                dw offset got_100_gold
                dw offset loc_8F59
                dw offset got_500_gold
                dw offset got_1000_gold
                dw offset got_crest_of_glory
                dw offset loc_8F83
; ---------------------------------------------------------------------------

got_50_gold:                            ; ...
                mov     dx, offset you_get_50_gold_str
                call    render_notification_string
                mov     ax, 50
                jmp     hero_got_gold   ; ax: gold to add
; ---------------------------------------------------------------------------

got_100_gold:                           ; ...
                mov     dx, offset you_get_100_gold_str
                call    render_notification_string
                mov     ax, 100
                jmp     hero_got_gold   ; ax: gold to add
; ---------------------------------------------------------------------------

loc_8F59:                               ; ...
                mov     dx, offset nothing_in_the_box_str
                jmp     render_notification_string
; ---------------------------------------------------------------------------

got_500_gold:                           ; ...
                mov     dx, offset you_get_500_gold_str
                call    render_notification_string
                mov     ax, 500
                jmp     hero_got_gold   ; ax: gold to add
; ---------------------------------------------------------------------------

got_1000_gold:                          ; ...
                mov     dx, offset you_get_1000_gold_str
                call    render_notification_string
                mov     ax, 1000
                jmp     hero_got_gold   ; ax: gold to add
; ---------------------------------------------------------------------------

got_crest_of_glory:                     ; ...
                mov     dx, offset you_get_glory_crest_str
                call    render_notification_string
                mov     byte ptr ds:crest_of_glory, 0FFh
                retn
; ---------------------------------------------------------------------------

loc_8F83:                               ; ...
                mov     dx, offset get_enchantment_sword_str
                call    render_notification_string
                push    si
                call    cs:Flush_Ui_Element_If_Dirty_proc
                mov     byte ptr ds:sword_type, SWORD_ENCHANTMENT
                mov     al, 6
                mov     bx, 18ABh
                call    cs:word_201C
                mov     ah, ds:sword_type
                mov     al, 4           ; fn_4
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                pop     si
                retn
; ---------------------------------------------------------------------------

flag_14_15_1b:                          ; ...
                call    move_monster_S  ; jumptable 00008E10 cases 4,5,11
                inc     [si+monster.anim_counter]
                and     [si+monster.anim_counter], 3
                call    check_monster_aligned_to_hero_and_tick
                jnb     short almas_picked_up
                retn
; ---------------------------------------------------------------------------

almas_picked_up:                        ; ...
                mov     byte ptr ds:soundFX_request, 10h
                mov     al, [si+monster.flags]
                and     al, 0Fh         ; monster almas price:
                                        ; 4 => 1 almas
                                        ; 5 => 10 almas
                                        ; else => 100 almas
                cmp     al, 4
                jnz     short loc_8FD2
                mov     ax, 1
                call    hero_got_almas  ; ax: almas to add
                jmp     loc_914C
; ---------------------------------------------------------------------------

loc_8FD2:                               ; ...
                cmp     al, 5
                jnz     short got_100_almas
                mov     ax, 10
                call    hero_got_almas  ; ax: almas to add
                jmp     loc_914C
; ---------------------------------------------------------------------------

got_100_almas:                          ; ...
                mov     ax, 100
                call    hero_got_almas  ; ax: almas to add
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_16:                                ; ...
                mov     dx, offset you_get_key_str ; jumptable 00008E10 case 6
                call    loc_90D3
                jnb     short got_ordinary_key
                retn
; ---------------------------------------------------------------------------

got_ordinary_key:                       ; ...
                inc     byte ptr ds:keys_amount
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_17:                                ; ...
                mov     dx, offset get_lions_head_key_str ; jumptable 00008E10 case 7
                call    loc_90D3
                jnb     short got_lion_head_key
                retn
; ---------------------------------------------------------------------------

got_lion_head_key:                      ; ...
                inc     byte ptr ds:lion_head_keys
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_18:                                ; ...
                call    check_monster_aligned_to_hero_and_tick ; jumptable 00008E10 case 8
                jnb     short loc_900E
                retn
; ---------------------------------------------------------------------------

loc_900E:                               ; ...
                mov     dx, offset you_have_recovered_str
                call    render_notification_string
                add     byte ptr ds:healing_potion_timer, 0Ah
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_19:                                ; ...
                call    move_monster_S  ; jumptable 00008E10 case 9
                call    check_monster_aligned_to_hero_and_tick
                jnb     short loc_9025
                retn
; ---------------------------------------------------------------------------

loc_9025:                               ; ...
                mov     dx, offset you_have_recovered_full_str
                call    render_notification_string
                mov     ax, ds:heroMaxHp
                shr     ax, 1
                shr     ax, 1
                shr     ax, 1
                inc     ax
                add     ds:healing_potion_timer, ax
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_1c:                                ; ...
                mov     [si+monster.counter], 0 ; jumptable 00008E10 case 12
                test    [si+monster.ai_state], 1
                jnz     short loc_9070
                call    check_monster_aligned_to_hero_and_tick
                jnb     short loc_904C
                retn
; ---------------------------------------------------------------------------

loc_904C:                               ; ...
                mov     byte ptr ds:soundFX_request, 11h
                or      [si+monster.state_flags], 80h
                or      [si+monster.ai_state], 1
                mov     [si+monster.ai_timer], 0EBh
                mov     bl, [si+monster.anim_counter] ; sign index
                add     bl, bl
                xor     bh, bh
                add     bx, ds:cavern_signs_rendering_info
                push    si
                mov     si, [bx]
                call    render_cavern_signs
                pop     si
                retn
; ---------------------------------------------------------------------------

loc_9070:                               ; ...
                test    [si+monster.ai_timer], 0FFh
                jz      short loc_907A
                inc     [si+monster.ai_timer]
                retn
; ---------------------------------------------------------------------------

loc_907A:                               ; ...
                and     [si+monster.ai_state], 0FEh
                retn
; ---------------------------------------------------------------------------

flag_1d:                                ; ...
                mov     dx, offset get_heros_crest_str ; jumptable 00008E10 case 13
                call    loc_90D3
                jnb     short got_hero_crest
                retn
; ---------------------------------------------------------------------------

got_hero_crest:                         ; ...
                mov     byte ptr ds:hero_crest, 0FFh
                jmp     loc_914C
; ---------------------------------------------------------------------------

flag_1e:                                ; ...
                mov     dx, offset get_feruza_shoes_str ; jumptable 00008E10 case 14
                call    loc_90D3
                jnb     short loc_9099
                retn
; ---------------------------------------------------------------------------

loc_9099:                               ; ...
                mov     al, 1
                jmp     short loc_90B8
; ---------------------------------------------------------------------------

flag_1a:                                ; ...
                mov     al, ds:cavern_level ; jumptable 00008E10 case 10
                sub     al, 4
                mov     cl, 3
                mul     cl
                mov     di, offset shoes_strings_array
                add     di, ax
                mov     al, [di]
                mov     dx, [di+1]      ; different shoes strings
                push    ax
                call    loc_90D3
                pop     ax
                jnb     short loc_90B8
                retn
; ---------------------------------------------------------------------------

loc_90B8:                               ; ...
                push    ax
                mov     di, offset Feruza_Shoes

loc_90BC:                               ; ...
                test    byte ptr [di], 0FFh
                jz      short free_slot_found
                inc     di              ; next accessory
                jmp     short loc_90BC
; ---------------------------------------------------------------------------

free_slot_found:                        ; ...
                pop     ax
                mov     [di], al
                jmp     loc_914C
; ---------------------------------------------------------------------------
shoes_strings_array:                    ; ...
                db 4
                dw offset get_ruzeria_shoes_str
                db 2
                dw offset get_pirika_shoes_str
                db 3
                dw offset get_silkarn_shoes_str
; ---------------------------------------------------------------------------

loc_90D3:                               ; ...
                push    dx
                call    move_monster_S
                call    check_monster_aligned_to_hero_and_tick
                pop     dx
                jnb     short loc_90DE
                retn
; ---------------------------------------------------------------------------

loc_90DE:                               ; ...
                mov     byte ptr ds:soundFX_request, 11h
                jmp     render_notification_string
; ---------------------------------------------------------------------------

loc_90E6:                               ; ...
                add     byte ptr [si+6], 80h
                jb      short loc_90ED
                retn
; ---------------------------------------------------------------------------

loc_90ED:                               ; ...
                inc     byte ptr [si+6]
                cmp     byte ptr [si+6], 3
                jz      short loc_90F7
                retn
; ---------------------------------------------------------------------------

loc_90F7:                               ; ...
                mov     byte ptr [si+0Fh], 0
                test    byte ptr [si+7], 40h
                jz      short loc_9116
                and     byte ptr [si+7], 0BFh
                mov     al, [si+0Ah]
                mov     cl, 10h
                mul     cl
                add     ax, ds:monsters_table_addr
                mov     di, ax
                mov     byte ptr [di+2], 0

loc_9116:                               ; ...
                test    byte ptr [si+7], 10h
                jz      short loc_9122
                test    byte ptr [si+4], 1
                jz      short loc_914C

loc_9122:                               ; ...
                mov     byte ptr [si+6], 0
                mov     byte ptr [si+4], 72h ; 'r'
                mov     al, [si+7]
                and     al, 0Fh
                jnz     short loc_9132
                retn
; ---------------------------------------------------------------------------

loc_9132:                               ; ...
                cmp     al, 1
                jz      short loc_914C
                or      al, 70h
                or      byte ptr [si+7], 80h
                mov     byte ptr [si+0Fh], 4
                mov     [si+4], al
                and     byte ptr [si+5], 80h
                and     byte ptr [si+7], 0F0h
                retn
; ---------------------------------------------------------------------------

loc_914C:                               ; ...
                mov     word ptr [si], 0FF00h
                test    byte ptr [si+7], 20h
                jnz     short loc_9157
                retn
; ---------------------------------------------------------------------------

loc_9157:                               ; ...
                mov     di, [si+0Bh]
                cmp     di, 0FFFFh
                jnz     short loc_9160
                retn
; ---------------------------------------------------------------------------

loc_9160:                               ; ...
                mov     al, [si+0Dh]
                or      [di], al
                mov     word ptr [si+0Bh], 0FFFFh
                retn
place_monster_in_proximity_and_run_ai endp


; =============== S U B R O U T I N E =======================================

; ax: gold to add

hero_got_gold   proc near               ; ...
                add     ds:hero_gold_lo, ax
                adc     byte ptr ds:hero_gold_hi, 0
                push    si
                call    cs:Print_Gold_Decimal_proc
                pop     si
                retn
hero_got_gold   endp


; =============== S U B R O U T I N E =======================================

; ax: almas to add

hero_got_almas  proc near               ; ...
                add     ds:hero_almas, ax
                jnb     short loc_9188
                mov     ds:hero_almas, 0FFFFh

loc_9188:                               ; ...
                push    si
                call    cs:Print_Almas_Decimal_proc
                pop     si
                retn
hero_got_almas  endp


; =============== S U B R O U T I N E =======================================


check_monster_aligned_to_hero_and_tick proc near ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                stc
                jz      short loc_9199
                retn
; ---------------------------------------------------------------------------

loc_9199:                               ; ...
                mov     ah, [si+monster.currY]
                add     ah, 2
                mov     cx, 4

loc_91A2:                               ; ...
                dec     ah
                and     ah, 3Fh
                cmp     ah, ds:hero_y_absolute
                jz      short loc_91B5
                loop    loc_91A2
                and     [si+monster.state_flags], 7Fh
                stc
                retn
; ---------------------------------------------------------------------------

loc_91B5:                               ; ...
                mov     al, ds:hero_x_in_viewport
                add     al, 4
                mov     ah, [si+monster.m_x_rel]
                sub     ah, 3
                mov     cx, 4

loc_91C3:                               ; ...
                inc     ah
                cmp     ah, al
                jz      short loc_91D1
                loop    loc_91C3
                and     [si+monster.state_flags], 7Fh
                stc
                retn
; ---------------------------------------------------------------------------

loc_91D1:                               ; ...
                test    [si+monster.state_flags], 80h
                clc
                jnz     short loc_91D9
                retn
; ---------------------------------------------------------------------------

loc_91D9:                               ; ...
                inc     [si+monster.counter]
                test    [si+monster.counter], 111b
                jnz     short loc_91E3
                retn                    ; NC
; ---------------------------------------------------------------------------

loc_91E3:                               ; ...
                stc
                retn
check_monster_aligned_to_hero_and_tick endp


; =============== S U B R O U T I N E =======================================


move_monster_E  proc near               ; ...
                cmp     [si+monster.m_x_rel], 34 ; Movement State / Frame Counter
                                        ; if 0..33 => Carry
                cmc                     ; if 0..33 => no carry
                jnb     short loc_91ED
                retn                    ; phase >= 34
; ---------------------------------------------------------------------------

loc_91ED:                               ; ...
                call    check_collision_E2 ; case 0..33
                jnb     short loc_91F3
                retn
; ---------------------------------------------------------------------------

loc_91F3:                               ; ...
                jmp     incrementX
move_monster_E  endp


; =============== S U B R O U T I N E =======================================


move_monster_NE proc near               ; ...
                cmp     [si+monster.m_x_rel], 34 ; Movement State / Frame Counter
                                        ; if 0..33 => Carry
                cmc
                jnb     short loc_91FE
                retn                    ; phase >= 34
; ---------------------------------------------------------------------------

loc_91FE:                               ; ...
                call    check_collision_NE2
                jnb     short incX_decY
                retn
; ---------------------------------------------------------------------------

incX_decY:                              ; ...
                call    incrementX
                jmp     decrementY
move_monster_NE endp


; =============== S U B R O U T I N E =======================================


move_monster_N  proc near               ; ...
                mov     al, [si+monster.m_x_rel] ; Movement State / Frame Counter
                or      al, al
                stc
                jnz     short loc_9213
                retn                    ; zero phase
; ---------------------------------------------------------------------------

loc_9213:                               ; ...
                cmp     al, 35
                stc
                jnz     short loc_9219
                retn                    ; phase 35
; ---------------------------------------------------------------------------

loc_9219:                               ; ...
                call    check_collision_N2
                jnb     short loc_921F
                retn
; ---------------------------------------------------------------------------

loc_921F:                               ; ...
                jmp     decrementY
move_monster_N  endp


; =============== S U B R O U T I N E =======================================


move_monster_NW proc near               ; ...
                cmp     [si+monster.m_x_rel], 2
                jnb     short loc_9229
                retn                    ; phase < 2
; ---------------------------------------------------------------------------

loc_9229:                               ; ...
                call    check_collision_NW2
                jnb     short decX_decY
                retn
; ---------------------------------------------------------------------------

decX_decY:                              ; ...
                call    decrementX
                jmp     short decrementY
move_monster_NW endp


; =============== S U B R O U T I N E =======================================


move_monster_W  proc near               ; ...
                cmp     [si+monster.m_x_rel], 2
                jnb     short loc_923B
                retn                    ; phase < 2
; ---------------------------------------------------------------------------

loc_923B:                               ; ...
                call    check_collision_W2
                jnb     short loc_9241
                retn
; ---------------------------------------------------------------------------

loc_9241:                               ; ...
                jmp     short decrementX
move_monster_W  endp


; =============== S U B R O U T I N E =======================================


move_monster_SW proc near               ; ...
                cmp     [si+monster.m_x_rel], 2
                jnb     short loc_924A
                retn                    ; phase < 2
; ---------------------------------------------------------------------------

loc_924A:                               ; ...
                call    check_collision_SW2
                jnb     short decX_incY_
                retn
; ---------------------------------------------------------------------------

decX_incY_:                              ; ...
                call    decrementX
                jmp     short incrementY
move_monster_SW endp


; =============== S U B R O U T I N E =======================================


move_monster_S  proc near               ; ...
                mov     al, [si+monster.m_x_rel]
                or      al, al
                stc
                jnz     short non_zero
                retn                    ; phase=0
; ---------------------------------------------------------------------------

non_zero:                               ; ...
                cmp     al, 35
                stc
                jnz     short less_35
                retn                    ; phase=35
; ---------------------------------------------------------------------------

less_35:                                ; ...
                call    check_collision_S2
                jnb     short loc_926A
                retn
; ---------------------------------------------------------------------------

loc_926A:                               ; ...
                jmp     short incrementY
; ---------------------------------------------------------------------------

move_monster_SE:                        ; ...
                cmp     [si+monster.m_x_rel], 34
                cmc
                jnb     short phase0_33
                retn                    ; phase >= 34
; ---------------------------------------------------------------------------

phase0_33:                              ; ...
                call    check_collision_SE2
                jnb     short incX_incY_
                retn
; ---------------------------------------------------------------------------

incX_incY_:                              ; ...
                call    incrementX
                jmp     short incrementY
; ---------------------------------------------------------------------------

incrementX:                             ; ...
                mov     ax, [si]        ; current X coord
                inc     ax              ; try to move right
                mov     bx, ax
                sub     bx, ds:mapWidth
                jb      short loc_928C
                mov     ax, bx          ; wrap X

loc_928C:                               ; ...
                mov     [si+monster.currX], ax ; monster X coord update
                inc     [si+monster.m_x_rel]
                clc
                retn
; ---------------------------------------------------------------------------

decrementX:                             ; ...
                mov     ax, [si+monster.currX]
                or      ax, ax
                jnz     short loc_929C
                mov     ax, ds:mapWidth

loc_929C:                               ; ...
                dec     ax
                mov     [si+monster.currX], ax
                dec     [si+monster.m_x_rel]
                clc
                retn
; ---------------------------------------------------------------------------

incrementY:                             ; ...
                inc     [si+monster.currY]
                and     [si+monster.currY], 3Fh ; wrap Y: dungeon map height is always 64
                retn
move_monster_S  endp

; ---------------------------------------------------------------------------

decrementY:                             ; ...
                dec     [si+monster.currY]
                and     [si+monster.currY], 3Fh ; wrap Y: dungeon map height is always 64
                retn

; =============== S U B R O U T I N E =======================================


check_collision_E2 proc near            ; ...
                mov     ax, word ptr [si+monster.currY] ; monster Y coord
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                inc     di
                inc     di              ; x+=2, check (+2, 0)
                call    check_collision_E_including_danger5
                jnb     short loc_92C2
                retn
; ---------------------------------------------------------------------------

loc_92C2:                               ; ...
                xchg    si, di
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di          ; check (+2, +1)
                call    check_collision_E_including_danger5
                jnb     short loc_92D2
                retn
; ---------------------------------------------------------------------------

loc_92D2:                               ; ...
                xchg    si, di
                mov     al, [si]        ; (+2, +1)
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                or      al, [si]        ; (+2, +1)|(+2, 0)
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                or      al, [si]        ; (+2, +1)|(+2, 0)|(+2, -1)
                xchg    si, di
                add     al, al          ; ..?
                                        ; x.?
                                        ; ..?
                retn                    ; CF is only set if any of {(+2, +1), (+2, 0), (+2, -1)} has high bit set (negative)
check_collision_E2 endp

check_collision_E_including_danger5 proc near ; ...
                mov     al, [di]
                call    if_passable_set_ZF
                stc
                jz      short loc_92F4
                retn
; ---------------------------------------------------------------------------

loc_92F4:                               ; ...
                cmp     ds:cavern_level, 5
                clc
                jz      short loc_92FD
                retn
; ---------------------------------------------------------------------------

loc_92FD:                               ; ...
                push    si
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                pop     si
                dec     cl
                clc
                jz      short category_1
                retn
; ---------------------------------------------------------------------------

category_1:                             ; ...
                stc
                retn
check_collision_E_including_danger5 endp

; =============== S U B R O U T I N E =======================================


check_collision_W2 proc near            ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                dec     di              ; x--, check (-1, 0)
                call    check_collision_W_including_danger5
                jnb     short loc_9317
                retn                    ; CF if (-1, 0) unpassable, including danger 5
; ---------------------------------------------------------------------------

loc_9317:                               ; ...
                xchg    si, di
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di          ; check (-1, +1)
                call    check_collision_W_including_danger5
                jnb     short loc_9327
                retn                    ; CF if (-1, +1) unpassable, including danger 5
; ---------------------------------------------------------------------------

loc_9327:                               ; ...
                dec     di              ; x--
                xchg    si, di
                mov     al, [si]        ; (-2, +1)
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                or      al, [si]        ; (-2, +1)|(-2, 0)
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                or      al, [si]        ; (-2, +1)|(-2, 0)|(-2, -1)
                xchg    si, di          ; ?..
                                        ; ??x
                                        ; ??.
                add     al, al          ; CF is only set if any of {(-2, +1), (-2, 0), (-2, -1)} has high bit set (negative)
                retn
check_collision_W2 endp


; =============== S U B R O U T I N E =======================================


check_collision_W_including_danger5 proc near ; ...
                mov     al, [di]
                call    if_passable_set_ZF
                stc
                jz      short loc_934A
                retn
; ---------------------------------------------------------------------------

loc_934A:                               ; ...
                cmp     ds:cavern_level, 5
                clc
                jz      short danger_five
                retn                    ; no danger 5, NC
; ---------------------------------------------------------------------------

danger_five:                            ; ...
                push    si
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                pop     si
                dec     cl
                dec     cl
                clc
                jz      short category_2
                retn
; ---------------------------------------------------------------------------

category_2:                             ; ...
                stc                     ; non passable, CF
                retn
check_collision_W_including_danger5 endp


; =============== S U B R O U T I N E =======================================


check_collision_N2 proc near            ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                mov     al, [di]        ; check (0, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_937B
                retn
; ---------------------------------------------------------------------------

loc_937B:                               ; ...
                mov     al, [di+1]      ; check (+1, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_9385
                retn
; ---------------------------------------------------------------------------

loc_9385:                               ; ...
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                mov     al, [di+1]      ; (+1, -2)
                or      al, [di]        ; (+1, -2)|(0, -2)
                or      al, [di-1]      ; (+1, -2)|(0, -2)|(-1, -2)
                add     al, al          ; ???
                                        ; ?.?
                                        ; .x.
                retn                    ; CF is only set if any of {(+1, -2), (0, -2), (-1, -2)} has high bit set (negative)
check_collision_N2 endp


; =============== S U B R O U T I N E =======================================


check_collision_S2 proc near            ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    si, di
                add     si, 36*2
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     al, [di]        ; check (0, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_93B3
                retn                    ; tile (0, +2) is solid, CF set
; ---------------------------------------------------------------------------

loc_93B3:                               ; ...
                mov     al, [di+1]      ; check (+1, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_93BD
                retn                    ; tile (1, +2) is solid, CF set
; ---------------------------------------------------------------------------

loc_93BD:                               ; ...
                or      al, [di]        ; al=(+1, +2)|(0, +2)
                or      al, [di-1]      ; al=(+1, +2)|(0, +2)|(-1, +2)
                add     al, al          ; .x.
                                        ; ...
                                        ; ???
                retn                    ; CF is only set if any of {(+1, +2), (0, +2), (-1, +2)} has high bit set (negative)
check_collision_S2 endp


; =============== S U B R O U T I N E =======================================


check_collision_NE2 proc near           ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                inc     di
                inc     di              ; x+=2
                mov     al, [di]        ; check (+2, 0)
                call    if_passable_set_ZF
                stc
                jz      short loc_93D6
                retn
; ---------------------------------------------------------------------------

loc_93D6:                               ; ...
                mov     cl, al          ; cl=(+2, 0)
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                mov     al, [di]        ; check (+2, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_93EB
                retn
; ---------------------------------------------------------------------------

loc_93EB:                               ; ...
                or      cl, al          ; cl=(+2, 0)|(+2, -1)
                mov     al, [di-1]      ; check (+1, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_93F7
                retn
; ---------------------------------------------------------------------------

loc_93F7:                               ; ...
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                or      cl, [di]        ; cl=(+2, 0)|(+2, -1)|(+2, -2)
                or      cl, [di-1]      ; cl=(+2, 0)|(+2, -1)|(+2, -2)|(+1, -2)
                or      cl, [di-2]      ; cl=(+2, 0)|(+2, -1)|(+2, -2)|(+1, -2)|(0, -2)
                add     cl, cl          ; ???
                                        ; .??
                                        ; x.?
                retn
check_collision_NE2 endp


; =============== S U B R O U T I N E =======================================


check_collision_SE2 proc near           ; ...
                mov     ax, word ptr [si+monster.currY] ; al=currY, ah=phase
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                inc     di
                inc     di
                mov     cl, [di]        ; save tile (+2, 0)
                xchg    si, di          ; si: proximity map, di: monster struc
                add     si, 36          ; move 1 down
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di          ; di: proximity map, si: monster struc
                mov     al, [di]        ; check tile (+2, +1)
                call    if_passable_set_ZF
                stc
                jz      short loc_9429
                retn                    ; tile (+2, +1) is solid, CF set
; ---------------------------------------------------------------------------

loc_9429:                               ; ...
                or      cl, al          ; cl=(+2, 0)|(+2, +1)
                xchg    si, di          ; si: proximity map, di: monster struc
                add     si, 36          ; move 1 down
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di          ; di: proximity map, si: monster struc
                mov     al, [di]        ; check tile (+2, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_943E
                retn                    ; tile (+2, +2) is solid, CF set
; ---------------------------------------------------------------------------

loc_943E:                               ; ...
                or      cl, al          ; cl=(+2, 0)|(+2, +1)|(+2, +2)
                mov     al, [di-1]      ; check tile (+1, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_944A
                retn                    ; tile (+1, +2) is solid, CF set
; ---------------------------------------------------------------------------

loc_944A:                               ; ...
                or      cl, al          ; cl = (+2, 0) | (+2, +1) | (+2, +2) | (+1, +2)
                or      cl, [di-2]      ; cl = (+2, 0) | (+2, +1) | (+2, +2) | (+1, +2) | (0, +2)
                add     cl, cl          ; x.?
                                        ; ..?
                                        ; ???
                retn                    ; CF is only set if any of {(+2, 0), (+2, +1), (+2, +2), (+1, +2), (0, +2)} has high bit set (negative)
check_collision_SE2 endp


; =============== S U B R O U T I N E =======================================


check_collision_NW2 proc near           ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                dec     di              ; x--
                mov     al, [di]        ; check (-1, 0)
                call    if_passable_set_ZF
                stc
                jz      short loc_9462
                retn
; ---------------------------------------------------------------------------

loc_9462:                               ; ...
                dec     di              ; x--
                mov     cl, [di]        ; cl=(-2, 0)
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                or      cl, [di]        ; cl=(-2, 0)|(-2, -1)
                mov     al, [di+1]      ; check (-1, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_947B
                retn
; ---------------------------------------------------------------------------

loc_947B:                               ; ...
                mov     al, [di+2]      ; check (0, -1)
                call    if_passable_set_ZF
                stc
                jz      short loc_9485
                retn
; ---------------------------------------------------------------------------

loc_9485:                               ; ...
                xchg    si, di
                sub     si, 36          ; y--
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xchg    si, di
                or      cl, [di+2]      ; cl=(-2, 0)|(-2, -1)|(0, -2)
                or      cl, [di+1]      ; cl=(-2, 0)|(-2, -1)|(0, -2)|(-1, -2)
                or      cl, [di]        ; cl=(-2, 0)|(-2, -1)|(0, -2)|(-1, -2)|(-2, -2)
                add     cl, cl          ; ???
                                        ; ??.
                                        ; ??x
                retn                    ; CF is only set if any of {(-2, 0), (-2, -1), (0, -2), (-1, -2), (-2, -2)} has high bit set (negative)
check_collision_NW2 endp


; =============== S U B R O U T I N E =======================================


check_collision_SW2 proc near           ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                dec     di
                dec     di              ; x-=2
                mov     cl, [di]        ; check (-2, 0)
                xchg    si, di
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                or      cl, [di]        ; cl=(-2, 0)|(-2, +1)
                inc     di
                mov     al, [di]        ; check (-1, +1)
                call    if_passable_set_ZF
                stc
                jz      short loc_94BA
                retn
; ---------------------------------------------------------------------------

loc_94BA:                               ; ...
                xchg    si, di
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     al, [di]        ; check (-1, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_94CD
                retn
; ---------------------------------------------------------------------------

loc_94CD:                               ; ...
                or      cl, al          ; cl=(-2, 0)|(-2, +1)|(-1, +2)
                mov     al, [di+1]      ; check (0, +2)
                call    if_passable_set_ZF
                stc
                jz      short loc_94D9
                retn
; ---------------------------------------------------------------------------

loc_94D9:                               ; ...
                or      cl, al          ; cl=(-2, 0)|(-2, +1)|(-1, +2)|(0, +2)
                or      cl, [di-1]      ; cl=(-2, 0)|(-2, +1)|(-1, +2)|(0, +2)|(-2, +2)
                add     cl, cl          ; ?.x
                                        ; ?..
                                        ; ???
                retn                    ; CF is only set if any of {(-2, 0), (-2, +1), (-1, +2), (0, +2), (-2, +2)} has high bit set (negative)
check_collision_SW2 endp


; =============== S U B R O U T I N E =======================================


if_passable_set_ZF proc near            ; ...
                cmp     al, 73
                jb      short in_zero_to_72
                or      al, al
                jns     short in_73_to_127
                retn                    ; for >= 80h return NZ (non-passable item or monster)
; ---------------------------------------------------------------------------

in_73_to_127:                           ; ...
                cmp     al, al
                retn                    ; for 73..127 return NZ (non-passable)
; ---------------------------------------------------------------------------

in_zero_to_72:                          ; ...
                push    di
                push    cx
                mov     es, cs:game_segment
                assume es:nothing
                mov     di, 8000h
                mov     cx, 24
                repne scasb             ; al in (00 01 02 08 09 0A 0B 0C 0F 10 11 12 13 14 15 16 17 18 19 00 00 00 00 00)
                pop     cx
                pop     di
                retn                    ; ZF if one of predefined passable tiles; NZ otherwise
if_passable_set_ZF endp


; =============== S U B R O U T I N E =======================================


monster_activation proc near            ; ...
                cmp     byte ptr [si+1], 0FFh ; monster x coord high byte
                jz      short loc_9506
                retn
; ---------------------------------------------------------------------------

loc_9506:                               ; ...
                test    [si+monster.state_flags], 10h ; is big monster? (occupy 2 structs in table)
                jz      short loc_9513
                cmp     byte ptr [si+11h], 0FFh ; big monster's (second part) x coord high byte
                jz      short loc_9513
                retn
; ---------------------------------------------------------------------------

loc_9513:                               ; ...
                mov     ax, [si+monster.spwnX]
                cmp     ax, 0FFFFh
                jnz     short loc_951C
                retn
; ---------------------------------------------------------------------------

loc_951C:                               ; ...
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jnb     short loc_9522
                retn
; ---------------------------------------------------------------------------

loc_9522:                               ; ...
                or      bl, bl
                jnz     short loc_9527
                retn
; ---------------------------------------------------------------------------

loc_9527:                               ; ...
                cmp     bl, 35
                jnz     short loc_952D
                retn
; ---------------------------------------------------------------------------

loc_952D:                               ; ...
                mov     al, ds:viewport_top_row_y
                sub     al, 2
                and     al, 3Fh         ; wrap y
                sub     al, [si+monster.spwnY]
                neg     al
                and     al, 3Fh         ; wrap y
                cmp     al, 24
                jnb     short loc_954A
                cmp     bl, 3
                jb      short loc_954A
                cmp     bl, 32
                jnb     short loc_954A
                retn
; ---------------------------------------------------------------------------

loc_954A:                               ; ...
                test    [si+monster.state_flags], 10h
                jnz     short big_monster
                mov     [si+monster.m_x_rel], bl
                mov     al, [si+monster.spwnY]
                mov     ah, bl
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                push    di
                xchg    si, di
                sub     si, 37
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xor     al, al
                mov     cx, 3

loc_9569:                               ; ...
                or      al, byte ptr [si+monster.currX]
                or      al, [si+1]
                or      al, [si+monster.currY]
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                loop    loc_9569
                xchg    si, di
                pop     di
                or      al, al
                jns     short loc_9581
                retn
; ---------------------------------------------------------------------------

loc_9581:                               ; ...
                mov     al, ds:monster_index
                or      al, 80h
                mov     [di], al
                mov     ax, [si+monster.spwnX]
                mov     [si], ax
                mov     al, [si+monster.spwnY]
                mov     [si+monster.currY], al
                mov     al, [si+monster.type_]
                mov     [si+monster.flags], al
                mov     [si+monster.anim_counter], 10h
                mov     [si+monster.ai_flags], 0
                mov     word ptr [si+monster.ai_state], 0
                mov     [si+monster.hp], 0
                mov     bl, ds:monster_index
                xor     bh, bh
                mov     byte ptr ds:proximity_second_layer[bx], 0 ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                retn
; ---------------------------------------------------------------------------

big_monster:                            ; ...
                test    [si+monster.type_], 1
                jz      short big_type1
                retn
; ---------------------------------------------------------------------------

big_type1:                              ; ...
                mov     [si+monster.m_x_rel], bl
                mov     [si+(monster.m_x_rel+10h)], bl
                mov     al, [si+monster.spwnY]
                mov     ah, bl
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                push    di
                xchg    si, di
                sub     si, 37
                call    wrap_map_from_below ; if (si < 0E000h) si += 900h
                xor     al, al
                mov     cx, 5

loc_95D9:                               ; ...
                or      al, byte ptr [si+monster.currX]
                or      al, [si+1]
                or      al, [si+monster.currY]
                add     si, 36
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                loop    loc_95D9
                xchg    si, di
                pop     di
                or      al, al
                jns     short loc_95F1
                retn
; ---------------------------------------------------------------------------

loc_95F1:                               ; ...
                mov     al, ds:monster_index
                or      al, 80h
                mov     [di], al
                xchg    si, di
                add     si, 72
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                inc     al
                mov     [di], al
                mov     ax, [si+monster.spwnX]
                mov     [si+monster.currX], ax
                mov     [si+(monster.x+10h)], ax
                mov     al, [si+monster.spwnY]
                mov     [si+monster.currY], al
                add     al, 2
                and     al, 3Fh
                mov     [si+(monster.currY+10h)], al
                mov     al, [si+monster.type_]
                mov     [si+monster.flags], al
                inc     al
                mov     [si+(monster.flags+10h)], al
                mov     [si+monster.anim_counter], 10h
                mov     [si+(monster.anim_counter+10h)], 10h
                mov     [si+monster.ai_flags], 0
                mov     [si+(monster.ai_flags+10h)], 0
                mov     word ptr [si+monster.ai_state], 0
                mov     word ptr [si+(monster.ai_state+10h)], 0
                mov     [si+monster.hp], 0
                mov     [si+(monster.hp+10h)], 0
                and     [si+(monster.state_flags+10h)], 0F0h
                mov     bl, ds:monster_index
                xor     bh, bh
                mov     word ptr ds:proximity_second_layer[bx], 0 ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                retn
monster_activation endp


; =============== S U B R O U T I N E =======================================


update_all_monsters_in_map proc near    ; ...
                push    cs
                pop     es
                assume es:fight
                mov     di, offset proximity_second_layer ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
                mov     cx, 80h
                xor     al, al
                rep stosb
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_9667:                               ; ...
                mov     byte ptr ds:monster_index, 0
                mov     si, ds:monsters_table_addr

next_monster3:                           ; ...
                mov     ax, [si+monster.currX]
                cmp     ax, 0FFFFh
                jnz     short loc_9678
                retn                    ; no more monsters
; ---------------------------------------------------------------------------

loc_9678:                               ; ...
                cmp     ah, 0FFh
                jz      short loc_9698
                mov     [si+monster.m_x_rel], 0FFh
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                jb      short loc_9698
                mov     [si+monster.m_x_rel], bl
                mov     al, [si+monster.currY]
                mov     ah, bl
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                mov     al, ds:monster_index
                or      al, 80h
                mov     [di], al        ; put monster to map

loc_9698:                               ; ...
                inc     byte ptr ds:monster_index
                add     si, 10h
                jmp     short next_monster3
update_all_monsters_in_map endp


; =============== S U B R O U T I N E =======================================

; * Calculates distance to hero and checks if within a 35-unit range.
;  * Accounts for world-wrapping (map edges).
;  * * @param monster_x The X coordinate of the monster (AX)
;  * @return Positive value (35 - distance) if in range,
;  * Sets Carry Flag (CF=1) if out of range.

HorizDistToHero_35 proc near            ; ...
                mov     bx, ax          ; monster_x
                sub     ax, ds:proximity_map_left_col_x
                jnb     short loc_96BA
                mov     ax, 35
                sub     ax, bx
                jnb     short loc_96B1
                retn
; ---------------------------------------------------------------------------

loc_96B1:                               ; ...
                mov     ax, ds:mapWidth
                sub     ax, ds:proximity_map_left_col_x
                add     ax, bx

loc_96BA:                               ; ...
                xchg    ax, bx
                mov     ax, 35
                sub     ax, bx
                retn
HorizDistToHero_35 endp


; =============== S U B R O U T I N E =======================================


monster_split_or_die proc near          ; ...
                mov     al, [si+monster.flags]
                test    al, 10h
                jnz     short Check_Vertical_Distance_Between_Hero_And_Monster
                and     al, 0Fh
                mov     bx, 0A008h
                xlat
                xor     ah, ah
                call    update_hero_XP
                jmp     short $+2
; ---------------------------------------------------------------------------

Check_Vertical_Distance_Between_Hero_And_Monster: ; ...
                mov     [si+monster.anim_counter], 0
                or      [si+monster.flags], 68h
                and     [si+monster.ai_flags], 80h
                test    [si+monster.state_flags], 10h ; big monster?
                jz      short usual_monster
                test    [si+monster.flags], 1
                jnz     short usual_monster
                mov     [si+monster.anim_counter], 80h
                mov     [si+(monster.anim_counter+10h)], 0
                or      [si+(monster.flags+10h)], 68h
                and     [si+(monster.ai_flags+10h)], 80h

usual_monster:                          ; ...
                mov     al, [si+monster.currY]
                mov     ah, ds:viewport_top_row_y
                dec     ah
                sub     al, ah
                and     al, 3Fh
                cmp     al, 19
                jb      short monster_close_to_hero_vertically_19
                retn
; ---------------------------------------------------------------------------

monster_close_to_hero_vertically_19:    ; ...
                mov     byte ptr ds:soundFX_request, 7
                retn
monster_split_or_die endp


; =============== S U B R O U T I N E =======================================


update_hero_XP  proc near               ; ...
                add     ds:hero_xp, ax
                jb      short loc_971C
                retn
; ---------------------------------------------------------------------------

loc_971C:                               ; ...
                mov     ds:hero_xp, 0FFFFh
                retn
update_hero_XP  endp


; =============== S U B R O U T I N E =======================================

; al=angle starting from right, counter-clockwise

monster_move_in_direction proc near     ; ...
                and     al, 7
                mov     bl, al
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_972B[bx]
monster_move_in_direction endp

; ---------------------------------------------------------------------------
funcs_972B      dw offset move_monster_E ; ...
                dw offset move_monster_NE
                dw offset move_monster_N
                dw offset move_monster_NW
                dw offset move_monster_W
                dw offset move_monster_SW
                dw offset move_monster_S
                dw offset move_monster_SE

; =============== S U B R O U T I N E =======================================


Check_collision_in_direction proc near  ; ...
                and     al, 7
                mov     bl, al
                xor     bh, bh
                add     bx, bx
                jmp     ds:funcs_9747[bx]
Check_collision_in_direction endp

; ---------------------------------------------------------------------------
funcs_9747      dw offset check_collision_E2 ; ...
                dw offset check_collision_NE2
                dw offset check_collision_N2
                dw offset check_collision_NW2
                dw offset check_collision_W2
                dw offset check_collision_SW2
                dw offset check_collision_S2
                dw offset check_collision_SE2

; =============== S U B R O U T I N E =======================================

; si points to monster struc

Move_Monster_NWE_Depending_On_Whats_Below proc near ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    di, si
                add     si, 36          ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    di, si
                mov     cx, 2           ; monster occupies 2 tiles, so we check both tiles below monster

loc_976E:                               ; ...
                push    cx
                push    si
                mov     al, [di]
                call    get_airflow_direction ; Is input tile an airflow?
                                        ; Input: al
                                        ; Output:
                                        ; NZ, cl=0xff (no airflow)
                                        ; ZF, cl=0 (Up), 1 (Left), 2 (Right)
                mov     bl, cl          ; category
                pop     si
                pop     cx
                jz      short loc_977F
                inc     di
                loop    loc_976E
                retn
; ---------------------------------------------------------------------------

loc_977F:                               ; ...
                pop     ax
                xor     bh, bh
                add     bx, bx          ; switch 3 cases
                jmp     ds:jpt_9784[bx] ; switch jump
Move_Monster_NWE_Depending_On_Whats_Below endp

; ---------------------------------------------------------------------------
jpt_9784        dw offset category0_moveN ; ...
                dw offset category1_moveW ; jump table for switch statement
                dw offset category2_moveE
; ---------------------------------------------------------------------------

category2_moveE:                        ; ...
                call    move_monster_E  ; jumptable 00009784 case 2
                jmp     move_monster_E
; ---------------------------------------------------------------------------

category1_moveW:                        ; ...
                call    move_monster_W  ; jumptable 00009784 case 1
                jmp     move_monster_W
; ---------------------------------------------------------------------------

category0_moveN:                        ; ...
                call    move_monster_N  ; jumptable 00009784 case 0
                jmp     move_monster_N

; =============== S U B R O U T I N E =======================================


Check_Monster_Ids_Two_Rows_Below_Monster proc near ; ...
                mov     ax, word ptr [si+monster.currY]
                call    coords_in_ax_to_proximity_map_offset_in_di ; uint8_t y = AL
                                        ; uint8_t x = AH
                                        ; y &= 0x3F; // Clamp Y to 0-63
                                        ; uint16_t di = (y * 36) + x + 0xE000;
                xchg    si, di
                add     si, 2*36        ; y++
                call    wrap_map_from_above ; if (si >= 0E900h) si -= 900h
                xchg    si, di
                mov     al, [di]        ; monster_id
                jmp     find_al_in_four_bytes_at_8020
Check_Monster_Ids_Two_Rows_Below_Monster endp


; =============== S U B R O U T I N E =======================================


Hero_Hits_monster proc near             ; ...
                mov     al, [si+monster.ai_flags]
                and     al, 1Fh
                call    Get_Stats       ; al=0: return ah=hero_level/2
                                        ; al=1: return ah=sword_total_damage
                                        ; al=2..8: return ah=byte_98BE[al-2]
                                        ; al=9: NOP
                mov     al, [si+monster.hp]
                sub     al, ah
                jbe     short loc_97CD
                mov     [si+monster.hp], al
                mov     byte ptr ds:0FF75h, 6
                retn
; ---------------------------------------------------------------------------

loc_97CD:                               ; ...
                test    [si+monster.flags], 1
                jnz     short loc_97D9
                test    [si+monster.state_flags], 10h ; extended monsters? splitting ones?
                jnz     short loc_9815

loc_97D9:                               ; ...
                test    [si+monster.state_flags], 0Fh
                jz      short loc_97E2
                jmp     monster_split_or_die
; ---------------------------------------------------------------------------

loc_97E2:                               ; ...
                mov     di, ds:death_split_table_ptr
                mov     bl, [si+monster.flags]
                and     bl, 7
                xor     bh, bh
                add     bx, bx
                mov     di, [bx+di]     ; =a250
                call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
                                        ;
                                        ; mov     ax, cs:0FF1Bh
                                        ; add     al, ah          ; ax += ah
                                        ; adc     ah, 0
                                        ; add     ax, cs:word_92B
                                        ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
                mov     bl, al          ; =9d
                and     bx, 3           ; =1
                cmp     byte ptr ds:sword_hit_type, 2
                jnz     short loc_9805
                xor     bx, bx

loc_9805:                               ; ...
                mov     al, [bx+di]     ; [A251]=00
                mov     ah, [si+monster.state_flags]
                and     ah, 0F0h
                or      al, ah
                mov     [si+monster.state_flags], al
                jmp     monster_split_or_die
; ---------------------------------------------------------------------------

loc_9815:                               ; ...
                test    [si+(monster.state_flags+10h)], 0Fh
                jz      short loc_981E
                jmp     monster_split_or_die
; ---------------------------------------------------------------------------

loc_981E:                               ; ...
                mov     di, ds:death_split_table_ptr
                mov     bl, [si+monster.flags]
                and     bl, 7
                xor     bh, bh
                add     bx, bx
                mov     di, [bx+di]
                call    cs:Accumulate_folded_ff1b_proc ; offset accumulate_folded_ff1b
                                        ;
                                        ; mov     ax, cs:0FF1Bh
                                        ; add     al, ah          ; ax += ah
                                        ; adc     ah, 0
                                        ; add     ax, cs:word_92B
                                        ; mov     cs:word_92B, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
                mov     bl, al
                and     bx, 3
                cmp     byte ptr ds:sword_hit_type, 2
                jnz     short loc_9841
                xor     bx, bx

loc_9841:                               ; ...
                mov     al, [bx+di]
                mov     ah, [si+(monster.state_flags+10h)]
                and     ah, 0F0h
                or      al, ah
                mov     [si+(monster.state_flags+10h)], al
                jmp     monster_split_or_die
Hero_Hits_monster endp


; =============== S U B R O U T I N E =======================================

; al=0: return ah=hero_level/2
; al=1: return ah=sword_total_damage
; al=2..8: return ah=byte_98BE[al-2]
; al=9: NOP

Get_Stats       proc near               ; ...
                mov     ah, ds:hero_level
                shr     ah, 1
                inc     ah
                or      al, al
                jnz     short loc_985E
                retn
; ---------------------------------------------------------------------------

loc_985E:                               ; ...
                cmp     al, 1
                jz      short loc_9882
                mov     ah, ds:hero_level
                inc     ah
                add     ah, ah
                jb      short loc_9870
                add     ah, ah
                jnb     short loc_9872

loc_9870:                               ; ...
                mov     ah, 0FFh

loc_9872:                               ; ...
                cmp     al, 9
                jnz     short al_2_8
                retn
; ---------------------------------------------------------------------------

al_2_8:                                 ; ...
                sub     al, 2
                mov     bl, al
                xor     bh, bh
                mov     ah, ds:byte_98BE[bx]
                retn
; ---------------------------------------------------------------------------

loc_9882:                               ; ...
                mov     bl, ds:sword_type
                dec     bl
                xor     bh, bh
                mov     al, ds:sword_damages[bx]
                mov     bl, ds:hero_level
                shr     bl, 1
                add     al, bl          ; base_damage[sword_type] + hero_level/2
                jb      short loc_98A4
                mov     cl, ds:byte_E4
                inc     cl
                mul     cl
                or      ah, ah
                jz      short loc_98A6

loc_98A4:                               ; ...
                mov     al, 0FFh

loc_98A6:                               ; ...
                mov     ah, al
                cmp     byte ptr ds:sword_hit_type, 2
                jz      short loc_98B0
                retn
; ---------------------------------------------------------------------------

loc_98B0:                               ; ...
                add     ah, ah
                jb      short loc_98B5
                retn
; ---------------------------------------------------------------------------

loc_98B5:                               ; ...
                mov     ah, 0FFh
                retn
Get_Stats       endp

; ---------------------------------------------------------------------------
sword_damages   db 1, 2, 4, 8, 32, 127  ; ...
byte_98BE       db 2, 4, 8, 16, 32, 64, 255 ; ...

; =============== S U B R O U T I N E =======================================

; Return dl: number of monsters found nearby

Find_Monsters_Near_Hero proc near       ; ...
                xor     dl, dl
                mov     di, ds:monsters_table_addr

loc_98CB:                               ; ...
                cmp     word ptr [di], 0FFFFh ; monsters end marker
                stc
                jnz     short loc_98D2
                retn
; ---------------------------------------------------------------------------

loc_98D2:                               ; ...
                cmp     [di+monster.spwnX], 0FFFFh
                jnz     short loc_98ED
                cmp     byte ptr [di+1], 0FFh
                jz      short loc_98F4
                mov     ax, [di+monster.currX]
                push    dx
                call    HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
                                        ;  * Accounts for world-wrapping (map edges).
                                        ;  * * @param monster_x The X coordinate of the monster (AX)
                                        ;  * @return Positive value (35 - distance) if in range,
                                        ;  * Sets Carry Flag (CF=1) if out of range.
                pop     dx
                jnb     short loc_98ED
                test    [di+monster.flags], 10h
                jz      short loc_98FA

loc_98ED:                               ; ...
                inc     dl              ; monsters counter
                add     di, 10h
                jmp     short loc_98CB
; ---------------------------------------------------------------------------

loc_98F4:                               ; ...
                cmp     [di+monster.currY], 7Fh
                jz      short loc_98ED

loc_98FA:                               ; ...
                clc                     ; error
                retn
Find_Monsters_Near_Hero endp


; =============== S U B R O U T I N E =======================================


process_hero_death proc near            ; ...
                call    cs:Flush_Ui_Element_If_Dirty_proc
                mov     byte ptr ds:sword_swing_flag, 0
                mov     byte ptr ds:jump_phase_flags, 0 ; 0: on ground, ff: ascending, 7f: descending, 80h: climbing down off rope
                mov     byte ptr ds:squat_flag, 0
                mov     byte ptr ds:hero_damage_this_frame, 0
                mov     byte ptr ds:invincibility_flag, 0FFh
                mov     ds:byte_9F28, 0
                mov     ds:byte_9F29, 0
                call    cs:Draw_Hero_Health_proc

repeat:                                 ; ...
                mov     byte ptr ds:hero_animation_phase, 0
                mov     byte ptr ds:on_rope_flags, 0 ; 0: on ground, ff: on rope, 80h: transition from rope to ground
                mov     byte ptr ds:hero_sprite_hidden, 0
                call    main_update_render
                mov     ax, offset repeat
                push    ax
                call    airborne_movement
                pop     ax
                mov     byte ptr ds:hero_sprite_hidden, 0

loc_9948:                               ; ...
                call    main_update_render
                mov     byte ptr ds:hero_sprite_hidden, 0
                cmp     byte ptr ds:hero_animation_phase, 2
                jz      short loc_9972
                inc     ds:byte_9F28
                test    ds:byte_9F28, 7
                jnz     short loc_9948
                mov     al, ds:hero_animation_phase
                inc     al
                and     al, 3
                cmp     al, 3
                jz      short loc_9948
                mov     ds:hero_animation_phase, al
                jmp     short loc_9948
; ---------------------------------------------------------------------------

loc_9972:                               ; ...
                inc     ds:byte_9F29
                test    ds:byte_9F29, 0Fh
                jz      short loc_998B
                test    ds:byte_9F29, 1
                jz      short loc_9948
                mov     byte ptr ds:hero_sprite_hidden, 0FFh
                jmp     short loc_9948
; ---------------------------------------------------------------------------

loc_998B:                               ; ...
                mov     byte ptr ds:byte_FF24, 8
                mov     cx, 30

loc_9993:                               ; ...
                push    cx
                call    main_update_render
                pop     cx
                mov     al, cl
                and     al, 1
                dec     al
                mov     ds:hero_sprite_hidden, al
                loop    loc_9993
                mov     ax, 1
                int     60h             ; mscadlib.drv
                call    cs:Fade_To_Black_Dithered_proc
                test    byte ptr ds:is_death_already_processed, 0FFh
                jz      short loc_99BB
                mov     byte ptr ds:last_sage_visited, 80h
                jmp     short skip_death_math
; ---------------------------------------------------------------------------

loc_99BB:                               ; ...
                mov     al, ds:hero_level
                add     al, al
                neg     al
                add     al, 127         ; xp += (127 - 2 * level)
                xor     ah, ah
                call    update_hero_XP
                mov     byte ptr ds:hero_gold_hi, 0
                mov     word ptr ds:hero_gold_lo, 0
                shr     word ptr ds:hero_almas, 1

skip_death_math:                        ; ...
                mov     ax, ds:heroMaxHp
                mov     ds:hero_HP, ax
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_99E0:                               ; ...
                mov     byte ptr ds:heartbeat_volume, 0
                mov     ah, ds:last_sage_visited ; resurrect in sage's hut
                mov     ds:place_map_id, ah
                mov     al, 1           ; fn_1
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                mov     ax, ds:tear_x
                mov     ds:hero_x_in_proximity_map, ax
                mov     si, ds:mdt_buffer ; si=mdt_descr
                inc     si
                lodsb                   ; mman_grp_idx
                mov     bl, 11
                mul     bl
                add     ax, offset mman_grp
                mov     si, ax
                mov     es, cs:game_segment
                assume es:nothing
                mov     di, 4000h
                mov     al, 2           ; fn_2
                call    cs:res_dispatcher_proc ; fn0_buffer_swap_and_go
                                        ; fn1_load_mdt_idx_ah
                                        ; ...
                mov     bx, 6002h       ; town off_6002 = sub_601E
                jmp     transfer_to_town
process_hero_death endp

; ---------------------------------------------------------------------------
you_get_50_gold_str dw 26h              ; ...
aYouGet50Golds  db 'You get 50 golds.'
                db 0FFh
you_get_100_gold_str dw 22h             ; ...
aYouGet100Golds db 'You get 100 golds.'
                db 0FFh
you_get_500_gold_str dw 22h             ; ...
aYouGet500Golds db 'You get 500 golds.'
                db 0FFh
you_get_1000_gold_str dw 1Eh            ; ...
aYouGet1000Gold db 'You get 1000 golds.'
                db 0FFh
you_get_key_str dw 32h                  ; ...
aYouGetAKey     db 'You get a Key.'
                db 0FFh
you_have_recovered_str dw 1Ch           ; ...
aYouHaveRecover db 'You have recovered.'
                db 0FFh
you_have_recovered_full_str dw 8        ; ...
aYouHaveRecover_0 db 'You have recovered full.'
                db 0FFh
shield_broken_str dw 3Ch                ; ...
aShieldBroken   db 'Shield broken.'
                db 0FFh
cant_open_this_door_str dw 14h          ; ...
aCanTOpenThisDo db 'Can\t open this door.'
                db 0FFh
nothing_in_the_box_str dw 1Ch           ; ...
aNothingInTheBo db 'Nothing in the box.'
                db 0FFh
get_heros_crest_str dw 6                ; ...
aYouGetTheHeroS db 'You get the Hero\s Crest.'
                db 0FFh
get_ruzeria_shoes_str dw 0              ; ...
aYouGetTheRuzer db 'You get the Ruzeria shoes.'
                db 0FFh
you_get_glory_crest_str dw 8            ; ...
aYouGetTheGlory db 'You get the Glory Crest.'
                db 0FFh
get_pirika_shoes_str dw 6               ; ...
aYouGetThePirik db 'You get the Pirika shoes.'
                db 0FFh
get_feruza_shoes_str dw 6               ; ...
aYouGetTheFeruz db 'You get the Feruza shoes.'
                db 0FFh
get_silkarn_shoes_str dw 0              ; ...
aYouGetTheSilka db 'You get the Silkarn shoes.'
                db 0FFh
get_enchantment_sword_str dw 0          ; ...
aGetTheEnchantm db 'Get the Enchantment sword.'
                db 0FFh
its_too_hot_str dw 30h                  ; ...
aItSTooHot      db 'It\s too hot !!'
                db 0FFh
get_lions_head_key_str dw 8             ; ...
aGetTheLionSHea db 'Get the lion\s head Key.'
                db 0FFh
fman_grp        db 2                    ; ...
                db 34h
aFmanGrp        db 'FMAN.GRP',0
encnt_grp       db 2                    ; ...
                db 38h
aEncntGrp       db 'ENCNT.GRP',0
roka_grp_2      db 2                    ; ...
                db 35h
aRokaGrp        db 'ROKA.GRP',0
roka_grp_1      db 1                    ; ...
                db 3Ah
aRokaGrp_0      db 'ROKA.GRP',0
dchr_grp        db 2                    ; ...
                db 37h
aDchrGrp        db 'DCHR.GRP',0
rokademo_bin    db 2                    ; ...
                db 1
aRokademoBin    db 'ROKADEMO.BIN',0
mman_grp        db 1                    ; ...
                db 1Eh
aMmanGrp        db 'MMAN.GRP',0
                db 1
                db 1Fh
aCmanGrp        db 'CMAN.GRP',0
mpp_grp         db 2                    ; ...
                db 4Bh
aMpp1Grp        db 'MPP1.GRP',0
                db 2
                db 4Ch
aMpp2Grp        db 'MPP2.GRP',0
                db 2
                db 4Dh
aMpp3Grp        db 'MPP3.GRP',0
                db 2
                db 4Eh
aMpp4Grp        db 'MPP4.GRP',0
                db 2
                db 4Fh
aMpp5Grp        db 'MPP5.GRP',0
                db 2
                db 50h
aMpp6Grp        db 'MPP6.GRP',0
                db 2
                db 51h
aMpp7Grp        db 'MPP7.GRP',0
                db 2
                db 52h
aMpp8Grp        db 'MPP8.GRP',0
                db 2
                db 53h
aMpp9Grp        db 'MPP9.GRP',0
                db 2
                db 54h
aMppaGrp        db 'MPPA.GRP',0
                db 2
                db 55h
aMppbGrp        db 'MPPB.GRP',0
eai1_bin        db 2                    ; ...
                db 2
aEai1Bin        db 'EAI1.BIN',0
                db 2
                db 0Ah
aCrabBin        db 'CRAB.BIN',0
                db 2
                db 3
aEai2Bin        db 'EAI2.BIN',0
                db 2
                db 0Bh
aTakoBin        db 'TAKO.BIN',0
                db 2
                db 4
aEai3Bin        db 'EAI3.BIN',0
                db 2
                db 0Ch
aToriBin        db 'TORI.BIN',0
                db 2
                db 5
aEai4Bin        db 'EAI4.BIN',0
                db 2
                db 0Dh
aZelaBin        db 'ZELA.BIN',0
                db 2
                db 6
aEai5Bin        db 'EAI5.BIN',0
                db 2
                db 0Eh
aMedaBin        db 'MEDA.BIN',0
                db 2
                db 7
aEai6Bin        db 'EAI6.BIN',0
                db 2
                db 0Fh
aLegaBin        db 'LEGA.BIN',0
                db 2
                db 8
aEai7Bin        db 'EAI7.BIN',0
                db 2
                db 11h
aDrgnBin        db 'DRGN.BIN',0
                db 2
                db 9
aEai8Bin        db 'EAI8.BIN',0
                db 2
                db 12h
aAkmaBin        db 'AKMA.BIN',0
                db 2
                db 13h
aMao1Bin        db 'MAO1.BIN',0
                db 2
                db 14h
aMao2Bin        db 'MAO2.BIN',0
                db 2
                db 10h
aZel2Bin        db 'ZEL2.BIN',0
enp1_grp        db 2                    ; ...
                db 39h
aEnp1Grp        db 'ENP1.GRP',0
                db 2
                db 41h
aCrabGrp        db 'CRAB.GRP',0
                db 2
                db 3Ah
aEnp2Grp        db 'ENP2.GRP',0
                db 2
                db 42h
aTakoGrp        db 'TAKO.GRP',0
                db 2
                db 3Bh
aEnp3Grp        db 'ENP3.GRP',0
                db 2
                db 43h
aToriGrp        db 'TORI.GRP',0
                db 2
                db 3Ch
aEnp4Grp        db 'ENP4.GRP',0
                db 2
                db 44h
aZelaGrp        db 'ZELA.GRP',0
                db 2
                db 3Dh
aEnp5Grp        db 'ENP5.GRP',0
                db 2
                db 45h
aMedaGrp        db 'MEDA.GRP',0
                db 2
                db 3Eh
aEnp6Grp        db 'ENP6.GRP',0
                db 2
                db 46h
aLegaGrp        db 'LEGA.GRP',0
                db 2
                db 3Fh
aEnp7Grp        db 'ENP7.GRP',0
                db 2
                db 47h
aDrgnGrp        db 'DRGN.GRP',0
                db 2
                db 40h
aEnp8Grp        db 'ENP8.GRP',0
                db 2
                db 48h
aAkmaGrp        db 'AKMA.GRP',0
                db 2
                db 49h
aMao1Grp        db 'MAO1.GRP',0
                db 2
                db 4Ah
aMao2Grp        db 'MAO2.GRP',0
mgt1_msd        db 1                    ; ...
                db 2Fh
aMgt1Msd        db 'MGT1.MSD',0
                db 1
                db 31h
aUgm1Msd        db 'UGM1.MSD',0
                db 1
                db 30h
aMgt2Msd        db 'MGT2.MSD',0
                db 1
                db 32h
aUgm2Msd        db 'UGM2.MSD',0
                db 2
                db 56h
aMus1Msd        db 'MUS1.MSD',0
                db 2
                db 57h
aMus2Msd        db 'MUS2.MSD',0
                db 2
                db 58h
aMus3Msd        db 'MUS3.MSD',0
                db 2
                db 59h
aMus4Msd        db 'MUS4.MSD',0
                db 2
                db 5Ah
aMus5Msd        db 'MUS5.MSD',0
                db 2
                db 5Bh
aMus6Msd        db 'MUS6.MSD',0
                db 2
                db 5Ch
aMus7Msd        db 'MUS7.MSD',0
                db 2
                db 5Dh
aMus8Msd        db 'MUS8.MSD',0
                db 2
                db 5Eh
aMbosMsd        db 'MBOS.MSD',0
                db 2
                db 60h
aMmaoMsd        db 'MMAO.MSD',0
byte_9EED       db 0                    ; ...
byte_9EEE       db 0                    ; ...
byte_9EEF       db 0                    ; ...
byte_9EF0       db 0                    ; ...
byte_9EF1       db 0                    ; ...
word_9EF2       dw 0                    ; ...
byte_9EF4       db 0                    ; ...
byte_9EF5       db 0FFh                 ; ...
byte_9EF6       db 0                    ; ...
mpp_grp_index   db 0                    ; ...
byte_9EF8       db 0                    ; ...
byte_9EF9       db 0                    ; ...
byte_9EFA       db 0                    ; ...
                db    0
                db    0
                db    0
eai_bin_index   db 0FFh                 ; ...
enp_grp_index   db 0FFh                 ; ...
byte_9F00       db 0                    ; ...
byte_9F01       db 0                    ; ...
byte_9F02       db 0                    ; ...
packed_map_ptr_for_hero_x_minus_18 dw 0 ; ...
packed_map_ptr_for_hero_x_plus_18 dw 0  ; ...
byte_9F07       db 0                    ; ...
jump_height_counter db 0                ; ...
byte_9F09       db 0                    ; ...
frame_ticks     db 0                    ; ...
byte_9F0B       db 0                    ; ...
height_above_ground db 0                ; ...
feruza_shoes_four_else_two db 2         ; ...
word_9F0E       dw 0                    ; ...
word_9F10       dw 0                    ; ...
accumulated_contact_damage dw 0         ; ...
byte_9F14       db 0                    ; ...
air_up_tile_found db 0                  ; ...
ticks           db 0                    ; ...
byte_9F17       db 0                    ; ...
byte_9F18       db 0                    ; ...
byte_9F19       db 0                    ; ...
hero_x_in_proximity_map dw 0            ; ...
byte_9F1C       db 0                    ; ...
byte_9F1D       db 0                    ; ...
byte_9F1E       db 0                    ; ...
last_projectile_index db 0              ; ...
slide_ticks_remaining db 0              ; ...
horiz_movement_sub_tile_accum db 0      ; ...
byte_9F22       db 0                    ; ...
byte_9F23       db 0                    ; ...
byte_9F24       db 0                    ; ...
temperature_timer db 0                  ; ...
byte_9F26       db 0                    ; ...
byte_9F27       db 0                    ; ...
byte_9F28       db 0                    ; ...
byte_9F29       db 0                    ; ...
byte_9F2A       db 0                    ; ...
byte_9F2B       db 0                    ; ...
delta_x         db 0                    ; ...
delta_y         db 0                    ; ...
byte_9F2E       db 0D2h dup(?)          ; ...
                db 2000h dup(?)         ; ...
mdt_buffer      dw ?                    ; ...
                                        ; 29h
                dw ?                    ; mapWidth
vertical_platforms_table_addr dw ?      ; ...
collapsing_platforms_table_addr dw ?    ; ...
horiz_platforms_table_addr dw ?         ; ...
doors_table_addr dw ?                   ; ...
accomplished_items_checker dw ?         ; ...
cavern_name_rendering_info dw ?         ; ...
                dw ?                    ; monsters_table_addr
cavern_level    db ?                    ; ...
tear_x          dw ?                    ; ...
tear_y          db ?                    ; ...
hero_head_y_in_viewport_initial_from_mdt db ? ; ...
cavern_signs_rendering_info dw ?        ; ...
packed_map_end_ptr dw ?                 ; ...
packed_map_start db 1FE5h dup(?)        ; ...
proximity_map   db 900h dup(?)          ; ...
viewport_buffer_28x19 db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ; ...
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db    ? ;
magic_projectiles db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ; ...
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
spirit_sprite_0 db ?, ?, ?, ?, ?, ?, ?  ; ...
spirit_sprite_1 db ?, ?, ?, ?, ?, ?, ?  ; ...
spirit_sprite_2 db ?, ?, ?, ?, ?, ?, ?  ; ...
spirit_sprite_3 db ?, ?, ?, ?, ?, ?, ?  ; ...
                db    ? ;
                db    ? ;
                db    ? ;
                db    ? ;
projectiles_array db 416 dup(?)         ; 13*32
                db 80h dup(?)           ; proximity_second_layer
                                        ; proximity map is designed to keep only one item
                                        ; at given address. So when we need to put other object,
                                        ; when position is already occupied by monster,
                                        ; we use second layer: 128 bytes of additional buffer
                                        ; (1 byte per monster id)
is_boss_dead    db ?                    ; ...
fight           ends


                end      start
