include common.inc
include dungeon.inc
                .286
                .model small

crab            segment byte public 'CODE'
                assume cs:crab, ds:crab
                org 0A000h
                assume es:nothing, ss:nothing
start           dw offset Cangrejo_AI_proc
                dw offset boss_x        ; boss_state_block_ptr
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
encounter_hp_table db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
                db 6, 6, 6, 0Fh, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
anim_frame_table_ptrs0_8 dw offset frames_body_walk0 ; normal movement animation states
                dw offset frames_body_walk1
                dw offset frames_body_walk2
                dw offset frames_body_walk3
                dw offset frames_body_walk4
                dw offset frames_body_walk5
                dw offset frames_body_descent0
                dw offset frames_body_descent1
                dw offset frames_body_descent2
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
anim_frame_table_ptrs9_15 dw offset frames_body_recoil0 ; death/recoil states and acid-drop body variants
                dw offset frames_body_recoil1
                dw offset frames_body_recoil2
                db    0
                db    0
                dw offset frames_body_hit
                dw offset frames_body_dead
frames_body_walk0 db 0, 0, 0, 0, 1, 0, 0, 0, 26h, 27h, 0, 0, 0, 0, 1, 0 ; ...
                db 0, 0, 26h, 27h, 0, 0, 0, 0, 1, 0, 0, 0, 26h, 27h, 0 ; movement phase 0 (rightmost leg position)
                db 0, 0, 26h, 27h, 0, 0, 0, 26h, 27h, 0, 0, 0, 0, 0, 0
                db 1, 2, 0Ah, 0Bh
frames_body_walk1 db 0, 0, 0, 2, 0, 0, 0, 0, 28h, 29h, 0, 0, 0, 2, 0, 0 ; ...
                db 0, 0, 28h, 29h, 0, 0, 0, 2, 0, 0, 0, 0, 28h, 29h, 0
                db 0, 0, 28h, 29h, 0, 0, 0, 28h, 29h, 0, 0, 0, 0, 0
frames_body_walk2 db 0, 3, 4, 0, 5, 0, 2Ah, 2Bh, 2Ch, 2Dh, 0, 3, 4, 0, 47h ; ...
                db 0, 2Ah, 2Bh, 2Ch, 58h, 0, 3, 4, 0, 69h, 0, 2Ah, 2Bh
                db 2Ch, 72h, 0, 3, 4, 0, 5, 0, 3, 4, 0, 5, 0, 8Fh, 90h
                db 0, 91h, 0, 0ADh, 0AEh, 0AFh, 0B0h
frames_body_walk3 db 0, 6, 7, 8, 9, 0, 6, 2Fh, 30h, 31h, 0, 6, 7, 48h, 49h ; ...
                db 0, 6, 2Fh, 59h, 5Ah, 0, 6, 7, 59h, 5Ah, 0, 6, 2Fh, 73h
                db 74h, 0, 6, 2Fh, 8, 9, 0, 6, 2Fh, 8, 9, 0, 92h, 26h
                db 93h, 94h, 0, 0B1h, 7, 0B2h, 0B3h
frames_body_walk4 db 0, 0Ah, 0Bh, 0Ch, 0Dh, 0, 32h, 33h, 0Ch, 0Dh, 0, 0Ah ; ...
                db 0Bh, 0Ch, 0Dh, 0, 32h, 33h, 0Ch, 0Dh, 0, 0Ah, 0Bh, 0Ch
                db 0Dh, 0, 32h, 33h, 0Ch, 0Dh, 0, 32h, 33h, 0C5h, 0C6h
                db 0, 32h, 33h, 0Ch, 0Dh, 0, 27h, 28h, 32h, 33h
frames_body_walk5 db 0, 0Eh, 35h, 10h, 11h, 0, 34h, 35h, 36h, 37h, 0, 0Eh ; ...
                db 35h, 4Ah, 4Bh, 0, 34h, 35h, 5Bh, 5Ch, 0, 0Eh, 35h, 5Bh ; movement phase 5 (leftmost leg position)
                db 5Ch, 0, 34h, 35h, 75h, 76h, 0, 34h, 35h, 84h, 85h, 0
                db 34h, 35h, 84h, 85h, 0, 29h, 95h, 96h, 97h, 0, 0Eh, 0B4h
                db 0B5h, 0B6h
frames_body_descent0 db 0, 12h, 13h, 14h, 15h, 0, 38h, 39h, 3Ah, 0, 0, 12h ; ...
                db 13h, 4Ch, 15h, 0, 38h, 39h, 5Dh, 0, 0, 12h, 13h, 5Dh ; descending phase 0 (boss lowering to drop acid)
                db 15h, 0, 38h, 39h, 77h, 0, 0, 12h, 13h, 14h, 15h, 0
                db 12h, 13h, 14h, 15h, 0, 98h, 99h, 9Ah, 0, 0, 0B7h, 0B8h
                db 0B9h, 0BAh
frames_body_descent1 db 0, 0, 16h, 0, 17h, 0, 0, 3Bh, 3Ch, 3Dh, 0, 0, 4Dh, 0 ; ...
                db 4Eh, 0, 5Eh, 5Fh, 0, 60h, 0, 0Fh, 2Eh, 6Ah, 6Bh, 0
                db 78h, 79h, 7Ah, 7Bh, 0, 86h, 87h, 0, 88h, 0, 86h, 87h
                db 0, 88h, 0, 9Bh, 9Ch, 9Dh, 9Eh, 0, 0BBh, 0BFh, 0BCh
                db 0
frames_body_descent2 db 0, 23h, 24h, 25h, 0, 0, 3Eh, 0, 3Fh, 0, 0, 55h, 0, 56h ; ...
                db 57h, 0, 65h, 66h, 67h, 68h, 0, 6Fh, 70h, 71h, 0, 0 ; descending phase 2
                db 80h, 81h, 82h, 83h, 0, 8Bh, 8Ch, 8Dh, 8Eh, 0, 8Bh, 8Ch
                db 8Dh, 8Eh, 0, 0A9h, 0AAh, 0ABh, 0ACh, 0, 0, 0C1h, 0
                db 0C2h
frames_body_recoil0 db 0, 18h, 19h, 1Ah, 1Bh, 0, 40h, 19h, 42h, 43h, 0, 4Fh ; ...
                db 19h, 50h, 51h, 0, 61h, 19h, 62h, 1Bh, 0, 6Ch, 19h, 6Dh ; retract phase 0 (pulling back up after drop)
                db 43h, 0, 7Ch, 19h, 7Dh, 43h, 0, 18h, 19h, 0, 1Bh, 0
                db 18h, 19h, 0, 1Bh, 0, 9Fh, 0A0h, 0A1h, 0A2h, 0, 0BDh
                db 19h, 0BFh, 43h
frames_body_recoil1 db 0, 1Ch, 1Dh, 1Eh, 0, 0, 1Ch, 1Dh, 0, 44h, 0, 1Ch, 1Dh ; ...
                db 1Eh, 44h, 0, 1Ch, 1Dh, 1Eh, 0, 0, 1Ch, 1Dh, 0, 0, 0
                db 1Ch, 1Dh, 0, 44h, 0, 1Ch, 1Dh, 1Eh, 0, 0, 1Ch, 1Dh
                db 1Eh, 0, 0, 0Ch, 0Dh, 0A3h, 0A4h
frames_body_recoil2 db 0, 1Fh, 20h, 21h, 22h, 0, 1Fh, 41h, 45h, 46h, 0, 1Fh ; ...
                db 52h, 53h, 54h, 0, 1Fh, 63h, 21h, 64h, 0, 1Fh, 63h, 21h ; retract phase 2
                db 6Eh, 0, 1Fh, 7Eh, 53h, 7Fh, 0, 1Fh, 89h, 21h, 8Ah, 0
                db 1Fh, 89h, 21h, 8Ah, 0, 0A5h, 0A6h, 0A7h, 0A8h, 0, 1Fh
                db 0BEh, 21h, 0C0h
frames_body_hit db 0, 0C7h, 0C8h, 1Ch, 1Dh, 0, 0C9h, 0CAh, 1Ch, 1Dh, 0 ; ...
                db 0CBh, 0CCh, 0CDh, 0CEh, 0, 0CFh, 0D0h, 0D1h, 0D2h, 0 ; taking damage / death flash
                db 0D3h, 0D4h, 0D5h, 0D6h, 0, 0C3h, 0C4h, 1Ch, 1Dh, 0
                db 0C5h, 0C6h, 1Ch, 1Dh, 0, 0Ch, 0Dh, 1Ch, 1Dh, 0, 0Ch
                db 0Dh, 1Ch, 1Dh, 0, 0Ch, 0Dh, 1Ch, 1Dh
frames_body_dead db 0, 0D7h, 0D8h, 0D9h, 0, 0, 0DAh, 0DBh, 0DCh, 0DDh, 0 ; ...
                db 0DEh, 0DFh, 0, 0, 0, 0E0h, 0E1h, 0, 0, 0, 0E2h, 0E3h ; final death pose
                db 0, 0

; =============== S U B R O U T I N E =======================================


Cangrejo_AI_proc proc near              ; ...

; FUNCTION CHUNK AT A45C SIZE 00000025 BYTES

                mov     si, ds:monsters_table_addr
                mov     active_sprite_count, 0
                mov     hit_monster_flags, 0

loc_A2FE:
                cmp     [si+monster.currX], 0FFFFh
                jz      short loc_A349
                mov     ax, [si+monster.currX]
                call    word ptr cs:HorizDistToHero_35_proc
                jb      short loc_A340
                mov     [si+monster.m_x_rel], bl
                mov     ax, word ptr [si+monster.currY]
                call    word ptr cs:coords_in_ax_to_proximity_map_offset_in_di_proc
                mov     bl, active_sprite_count
                xor     bh, bh
                mov     al, proximity_second_layer[bx]
                mov     [di], al
                test    [si+monster.ai_flags], 40h
                jz      short loc_A340
                test    hit_monster_flags, 80h
                jnz     short loc_A340
                mov     al, [si+monster.ai_flags]
                and     al, 1Fh
                test    [si+monster.flags], 10h
                jz      short loc_A33D
                or      al, 80h

loc_A33D:
                mov     hit_monster_flags, al

loc_A340:
                inc     active_sprite_count
                add     si, 10h
                jmp     short loc_A2FE
; ---------------------------------------------------------------------------

loc_A349:
                mov     si, ds:monsters_table_addr
                mov     word ptr [si], 0FFFFh
                test    byte ptr ds:boss_being_hit, 0FFh
                jnz     short loc_A3A7
                mov     al, hit_monster_flags
                or      al, al
                jz      short loc_A3A7
                push    ax
                and     al, 1Fh
                call    word ptr cs:Get_Stats_proc
                mov     bl, ah
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                pop     ax
                or      al, al
                jns     short loc_A376
                add     bx, bx

loc_A376:
                call    apply_damage_to_boss
                mov     byte ptr ds:soundFX_request, 22h
                mov     ax, ds:proximity_map_left_col_x
                add     ax, 0Ch
                mov     bx, ds:mapWidth
                cmp     ax, bx
                jb      short loc_A38E
                mov     ax, bx

loc_A38E:
                xchg    ax, bx
                mov     ax, boss_x      ; boss_state_block_ptr
                add     ax, 5
                cmp     ax, bx
                jnb     short loc_A3A1
                call    boss_move_left
                call    boss_move_left
                jmp     short loc_A3A7
; ---------------------------------------------------------------------------

loc_A3A1:
                call    boss_move_right
                call    boss_move_right

loc_A3A7:
                test    phase_placing_droplet, 0FFh
                jz      short loc_A3B1
                jmp     loc_A4B9
; ---------------------------------------------------------------------------

loc_A3B1:
                test    phase_recoil, 0FFh
                jz      short loc_A3BB
                jmp     loc_A5D3
; ---------------------------------------------------------------------------

loc_A3BB:
                test    byte ptr ds:boss_being_hit, 0FFh
                jz      short loc_A3C5
                jmp     death_sequence_handler
; ---------------------------------------------------------------------------

loc_A3C5:
                test    phase_acid_dropping, 0FFh
                jz      short loc_A3CF
                jmp     loc_A466
; ---------------------------------------------------------------------------

loc_A3CF:
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 7
                jnz     short loc_A3DB
                jmp     loc_A45C
; ---------------------------------------------------------------------------

loc_A3DB:
                test    movement_direction_flag, 0FFh
                jnz     short loc_A410
                inc     movement_tick_counter
                test    movement_tick_counter, 1
                jz      short loc_A3F0
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A3F0:
                call    boss_move_left
                jnb     short loc_A3FA
                mov     movement_direction_flag, 0FFh

loc_A3FA:
                inc     body_anim_state
                cmp     body_anim_state, 6
                jnb     short loc_A408
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A408:
                mov     body_anim_state, 0
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A410:
                inc     movement_tick_counter
                test    movement_tick_counter, 1
                jz      short loc_A41E
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A41E:
                call    boss_move_right
                jnb     short loc_A428
                mov     movement_direction_flag, 0

loc_A428:
                dec     body_anim_state
                cmp     body_anim_state, 0FFh
                jz      short loc_A436
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A436:
                mov     body_anim_state, 5
                jmp     render_body_sprites
Cangrejo_AI_proc endp


; =============== S U B R O U T I N E =======================================


boss_move_left  proc near               ; ...
                cmp     byte ptr boss_x, 10h ; boss_state_block_ptr
                stc
                jnz     short loc_A447
                retn
; ---------------------------------------------------------------------------

loc_A447:
                dec     byte ptr boss_x ; boss_state_block_ptr
                clc
                retn
boss_move_left  endp


; =============== S U B R O U T I N E =======================================


boss_move_right proc near               ; ...
                cmp     byte ptr boss_x, 31h ; '1' ; boss_state_block_ptr
                stc
                jnz     short loc_A456
                retn
; ---------------------------------------------------------------------------

loc_A456:
                inc     byte ptr boss_x ; boss_state_block_ptr
                clc
                retn
boss_move_right endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR Cangrejo_AI_proc

loc_A45C:
                mov     acid_step_index, 0
                mov     phase_acid_dropping, 0FFh

loc_A466:
                inc     acid_step_index
                cmp     acid_step_index, 8
                jz      short trigger_acid_drop
                mov     bl, acid_step_index
                xor     bh, bh
                mov     al, acid_approach_body_states[bx]
                mov     body_anim_state, al
                jmp     render_body_sprites
; END OF FUNCTION CHUNK FOR Cangrejo_AI_proc
; ---------------------------------------------------------------------------
acid_approach_body_states db 7, 7, 8, 8, 8, 8, 8, 6 ; ...

; =============== S U B R O U T I N E =======================================


trigger_acid_drop proc near             ; ...
                mov     ax, ds:proximity_map_left_col_x
                add     ax, 12
                mov     bx, ds:mapWidth
                mov     cx, ax
                sub     cx, bx
                xchg    ax, bx
                jb      short loc_A49C
                xchg    bx, cx

loc_A49C:
                mov     ax, boss_x      ; boss_state_block_ptr
                add     ax, 5
                sub     ax, bx
                sbb     dl, dl
                mov     movement_direction_flag, dl
                mov     phase_acid_dropping, 0
                mov     descent_seq_index, 0
                mov     phase_placing_droplet, 0FFh

loc_A4B9:
                mov     body_anim_state, 9
                mov     bl, descent_seq_index
                xor     bh, bh
                mov     al, acid_descent_sequence[bx]
                cmp     al, 0FFh
                jnz     short loc_A4CF
                jmp     begin_recoil
; ---------------------------------------------------------------------------

loc_A4CF:
                mov     ah, al
                and     al, 0Fh
                cmp     al, 8
                jz      short loc_A4E4
                shr     al, 1
                sbb     al, 0
                add     al, boss_y
                and     al, 3Fh
                mov     boss_y, al

loc_A4E4:
                mov     al, ah
                and     al, 0F0h
                jz      short loc_A4F9
                test    movement_direction_flag, 0FFh
                jnz     short loc_A4F6
                call    boss_move_left
                jmp     short loc_A4F9
; ---------------------------------------------------------------------------

loc_A4F6:
                call    boss_move_right

loc_A4F9:
                call    render_body_sprites
                inc     descent_seq_index
                retn
trigger_acid_drop endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR render_body_sprites

loc_A501:
                test    phase_spawning_droplet, 0FFh
                jnz     short loc_A54A
                test    phase_placing_droplet, 0FFh
                jnz     short loc_A510
                retn
; ---------------------------------------------------------------------------

loc_A510:
                mov     di, ds:monsters_table_addr

next_monster:                           ; ...
                cmp     [di+monster.flags], 14h
                jz      short loc_A51F
                add     di, 10h
                jmp     short next_monster
; ---------------------------------------------------------------------------

loc_A51F:
                mov     al, descent_seq_index
                mov     [di+monster.anim_counter], al
                cmp     descent_seq_index, 4
                jz      short loc_A52D
                retn
; ---------------------------------------------------------------------------

loc_A52D:
                mov     spawn_seq_index, 0
                mov     phase_spawning_droplet, 0FFh
                mov     ax, boss_x      ; boss_state_block_ptr
                add     ax, 4
                mov     droplet_target_x, ax
                mov     al, boss_y
                add     al, 3
                and     al, 3Fh
                mov     droplet_target_y, al

loc_A54A:
                mov     bl, spawn_seq_index
                xor     bh, bh
                inc     spawn_seq_index
                mov     al, acid_droplet_spawn_sequence[bx]
                cmp     al, 0FFh
                jnz     short loc_A562
                mov     phase_spawning_droplet, 0
                retn
; ---------------------------------------------------------------------------

loc_A562:
                or      al, al
                jns     short loc_A56F
                inc     droplet_target_y
                and     droplet_target_y, 3Fh

loc_A56F:
                push    ax
                mov     ax, droplet_target_x
                push    ax
                call    word ptr cs:HorizDistToHero_35_proc
                pop     ax
                pop     cx
                jnb     short loc_A57E
                retn
; ---------------------------------------------------------------------------

loc_A57E:
                mov     [si], ax
                mov     dl, droplet_target_y
                mov     [si+2], dl
                mov     [si+3], bl
                mov     byte ptr [si+4], 35h ; '5'
                and     cl, 7Fh
                mov     [si+6], cl
                mov     byte ptr [si+5], 0
                mov     word ptr [si+10h], 0FFFFh
                mov     ax, [si+2]
                call    word ptr cs:coords_in_ax_to_proximity_map_offset_in_di_proc
                mov     bl, active_sprite_count
                mov     al, bl
                or      al, 80h
                xchg    al, [di]
                xor     bh, bh
                mov     ds:proximity_second_layer[bx], al
                retn
; END OF FUNCTION CHUNK FOR render_body_sprites
; ---------------------------------------------------------------------------
acid_droplet_spawn_sequence db 80h, 80h, 80h, 80h, 80h, 81h, 82h, 3, 4, 0FFh ; ...

; =============== S U B R O U T I N E =======================================


begin_recoil    proc near               ; ...
                not     movement_direction_flag
                mov     phase_placing_droplet, 0
                mov     recoil_step_index, 0
                mov     phase_recoil, 0FFh

loc_A5D3:
                mov     bl, recoil_step_index
                xor     bh, bh
                mov     al, recoil_body_states[bx]
                mov     body_anim_state, al
                inc     recoil_step_index
                cmp     recoil_step_index, 4
                jz      short loc_A5EE
                jmp     render_body_sprites
; ---------------------------------------------------------------------------

loc_A5EE:
                mov     phase_recoil, 0
                jmp     short render_body_sprites
begin_recoil    endp

; ---------------------------------------------------------------------------
recoil_body_states db 7, 8, 8, 0        ; ...
acid_descent_sequence db 0F1h, 0F1h, 0F1h, 0F1h, 0F1h, 0F8h, 0F8h, 0F8h, 0F2h ; ...
                db 0F2h, 0F2h, 0F2h, 0F2h, 0FFh

; =============== S U B R O U T I N E =======================================


death_sequence_handler proc near        ; ...
                mov     al, death_timer
                cmp     al, 28h ; '('
                jnb     short loc_A66B
                cmp     al, 1Eh
                jnb     short loc_A61B
                and     al, 1
                jnz     short loc_A61B
                mov     byte ptr ds:soundFX_request, 23h ; '#'

loc_A61B:
                mov     byte ptr ds:0FF2Fh, 0FFh
                cmp     death_timer, 14h
                jnb     short loc_A660
                inc     death_timer
                test    movement_direction_flag, 0FFh
                jnz     short loc_A649
                inc     body_anim_state
                cmp     body_anim_state, 6
                jb      short render_body_sprites
                mov     body_anim_state, 5
                mov     movement_direction_flag, 0FFh
                jmp     short render_body_sprites
; ---------------------------------------------------------------------------

loc_A649:
                dec     body_anim_state
                cmp     body_anim_state, 0FFh
                jb      short render_body_sprites
                mov     body_anim_state, 0
                mov     movement_direction_flag, 0
                jmp     short render_body_sprites
; ---------------------------------------------------------------------------

loc_A660:
                inc     death_timer
                mov     body_anim_state, 8
                jmp     short render_body_sprites
; ---------------------------------------------------------------------------

loc_A66B:
                mov     byte ptr ds:boss_is_dead, 0FFh
                retn
death_sequence_handler endp


; =============== S U B R O U T I N E =======================================


render_body_sprites proc near           ; ...

; FUNCTION CHUNK AT A501 SIZE 000000B5 BYTES

                mov     bl, body_anim_state
                add     bl, bl
                xor     bh, bh
                mov     di, body_state_to_layout_table[bx]
                mov     al, boss_y
                mov     col_y_render_offset, al
                mov     si, ds:monsters_table_addr
                xor     al, al
                mov     active_sprite_count, al

loc_A68C:
                push    di
                push    ax
                mov     bl, 0Ah
                mul     bl
                add     di, ax
                mov     ax, boss_x      ; boss_state_block_ptr
                mov     cx, 0Ah

loc_A69A:
                push    cx
                mov     [si], ax
                push    di
                push    ax
                call    word ptr cs:HorizDistToHero_35_proc
                jb      short loc_A6EB
                mov     al, [di]
                cmp     al, 0FFh
                jz      short loc_A6EB
                mov     [si+4], al
                mov     al, col_y_render_offset
                mov     [si+2], al
                mov     [si+3], bl
                mov     byte ptr [si+5], 0
                test    hit_monster_flags, 0FFh
                jz      short loc_A6C7
                or      byte ptr [si+5], 20h

loc_A6C7:
                mov     al, body_anim_state
                mov     [si+6], al
                mov     ax, [si+2]
                call    word ptr cs:coords_in_ax_to_proximity_map_offset_in_di_proc
                mov     al, active_sprite_count
                mov     bl, al
                or      al, 80h
                xchg    al, [di]
                xor     bh, bh
                mov     proximity_second_layer[bx], al
                inc     active_sprite_count
                add     si, 10h

loc_A6EB:
                pop     ax
                inc     ax
                pop     di
                inc     di
                pop     cx
                loop    loc_A69A
                inc     col_y_render_offset
                and     col_y_render_offset, 3Fh
                pop     ax
                pop     di
                inc     al
                cmp     al, 6
                jnz     short loc_A68C
                mov     word ptr [si], 0FFFFh
                jmp     loc_A501
render_body_sprites endp

; ---------------------------------------------------------------------------
body_state_to_layout_table dw offset col_layout_normal ; ...
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_normal
                dw offset col_layout_acid_drip
col_layout_normal db 0FFh, 0FFh, 0FFh, 0, 0FFh, 1, 0FFh, 0FFh, 0FFh, 0FFh ; ...
                db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                db 0FFh, 2, 0FFh, 3, 0FFh, 4, 0FFh, 5, 0FFh, 6, 0FFh, 0FFh
                db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                db 7, 0FFh, 10h, 0FFh, 11h, 0FFh, 12h, 0FFh, 8, 0FFh, 0FFh
                db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
col_layout_acid_drip db 0FFh, 0FFh, 0FFh, 0FFh, 0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh ; ...
                db 0FFh, 0FFh, 3, 0FFh, 0FFh, 0FFh, 5, 0FFh, 0FFh, 0FFh
                db 2, 0FFh, 0FFh, 0FFh, 14h, 0FFh, 0FFh, 0FFh, 6, 0FFh
                db 0FFh, 0FFh, 90h, 0FFh, 0FFh, 0FFh, 12h, 0FFh, 0FFh
                db 0FFh, 0FFh, 7, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 8, 0FFh
                db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                db 0FFh, 0FFh

; =============== S U B R O U T I N E =======================================


apply_damage_to_boss proc near          ; ...
                mov     ax, boss_hp
                sub     ax, bx
                jnb     short loc_A79F
                xor     ax, ax

loc_A79F:
                mov     boss_hp, ax
                mov     bx, ax
                push    ax
                call    word ptr cs:Draw_Boss_Health_proc
                pop     ax
                or      ax, ax
                jz      short loc_A7B0
                retn
; ---------------------------------------------------------------------------

loc_A7B0:
                test    byte ptr ds:boss_being_hit, 0FFh
                jz      short loc_A7B8
                retn
; ---------------------------------------------------------------------------

loc_A7B8:
                mov     death_timer, 0
                mov     byte ptr ds:boss_being_hit, 0FFh
                retn
apply_damage_to_boss endp

; ---------------------------------------------------------------------------
boss_x          dw 2Bh                  ; ...
                                        ; boss_state_block_ptr
boss_y          db 0Ch                  ; ...
boss_hp         dw 96h                  ; ...
xp_reward       dw 78h
arena_center_x  db 0Ch
                db    0
name_block_ptr  dw offset name_screen_x
almas_reward    db 150
                db    0
name_screen_x   db 10h                  ; ...
name_screen_y   db 0BBh
                db    0
boss_name_pstring db 8,'Cangrejo'
active_sprite_count db 0                ; ...
hit_monster_flags db 0                  ; ...
                                        ; Packed: bit 7 = hit monster was facing left (`flags & 0x10`); bits 4–0 = `ai_flags & 0x1F` of the monster that was hit this frame. Non-zero means a monster was struck; causes acid droplets to set their "flip" flag
body_anim_state db 0                    ; ...
                                        ; Selects which body column-layout table to use (0–8 → `col_layout_normal`; 9 → `col_layout_acid_drip`). Also drives leg-cycle animation: increments 0→5 when moving right, decrements 5→0 when moving left
col_y_render_offset db 0                ; ...
                                        ; Y-position offset cycled per outer row loop in `sub_A671`; produces the staggered vertical positioning of the 6 body rows
movement_direction_flag db 0            ; ...
                                        ; `0x00` = moving toward minimum X (left); `0xFF` = moving toward maximum X (right). Toggled when a boundary is hit
movement_tick_counter db 0              ; ...
phase_acid_dropping db 0                ; ...
                                        ; `0x00` = normal horizontal patrol; `0xFF` = acid-drop approach active
acid_step_index db 0                    ; ...
                                        ; Step counter (1–8) into `acid_approach_body_states`; at 8 triggers `sub_A489` (release droplet)
phase_recoil    db 0                    ; ...
                                        ; `0x00` = not recoiling; `0xFF` = post-drop recoil
recoil_step_index db 0                  ; ...
                                        ; Step counter (0–3) into `recoil_body_states`; at 4 clears `phase_recoil`
phase_placing_droplet db 0              ; ...
                                        ; `0x00` = idle; `0xFF` = boss has committed to a drop position
descent_seq_index db 0                  ; ...
                                        ; Index into `acid_descent_sequence` (`byte_A5F9`); advances each tick until `0xFF`
phase_spawning_droplet db 0             ; ...
                                        ; `0x00` = no active spawn; `0xFF` = acid droplet is being spawned
spawn_seq_index db 0                    ; ...
                                        ; Index into `acid_droplet_spawn_sequence` (`byte_A5B6`); advances each tick
droplet_target_x dw 0                   ; ...
                                        ; Absolute X tile coordinate where the acid droplet will be placed (set to `boss_x + 4` when the drop triggers)
droplet_target_y db 0                   ; ...
                                        ; Y tile coordinate for the droplet; initialized to `boss_y + 3`, then incremented each spawn tick as the droplet "falls"
death_timer     db 0                    ; ...
crab            ends                    ; Counts up from 0 during the death sequence. `< 20`: hit-flash and sound effect every other frame; `20–39`: body holds damaged pose; `≥ 40`: sets `byte_FF30 = 0xFF` (triggers `fight.bin` victory / XP award logic)


                end      start
