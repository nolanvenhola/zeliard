include common.inc
                .286
                .model small

eai1            segment byte public 'CODE'
                assume cs:eai1, ds:eai1
                org 0A000h
                assume es:nothing, ss:nothing
start           dw offset Monster_AI
                dw 0
                db    0
                db    0
                dw offset death_split_descriptors
                db    3
                db    2
                db    5
                db    3
                db    0
                db    0
                db    0
                db    0
                db    5
                db    5
                db  0Fh
                db    8
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
                dw offset slug_walk_right_frames
                dw offset bat_fly_frames
                dw offset frog_jump_right_frames
                dw offset rat_run_right_frames
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                dw offset slug_idle_frames_set0
                dw offset slug_idle_frames_set1
                dw offset slug_idle_frames_set2
                dw offset slug_idle_frames_set3
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                dw offset bat_dive_frames
                dw offset bat_dive_frames
                dw offset common_death_frames
                dw offset frog_land_frames
                dw offset common_hit_frames
                dw offset common_hit_frames_alt
                dw offset rat_obstacle_frames
                db    0
                db    0
                dw offset rat_jump_up_frames
                dw offset rat_jump_up_frames_alt
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
                dw offset slug_walk_right_alt_frames
                dw offset bat_fly_alt_frames
                dw offset frog_jump_left_frames
                dw offset rat_run_left_frames
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                dw offset slug_idle_frames_set0
                dw offset slug_idle_frames_set1
                dw offset slug_idle_frames_set2
                dw offset slug_idle_frames_set3
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                dw offset bat_dive_frames
                dw offset bat_dive_frames
                dw offset common_death_frames
                dw offset frog_land_frames
                dw offset common_hit_frames
                dw offset common_hit_frames_alt
                dw offset rat_obstacle_frames
                db    0
                db    0
                dw offset rat_jump_up_frames
                dw offset rat_jump_up_frames_alt
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
slug_walk_right_frames db 0, 19h, 1Ah, 1Bh, 1Ch ; ...
                db 0, 1Dh, 1Eh, 1Fh, 20h
                db 0, 21h, 22h, 23h, 24h
                db 0, 25h, 26h, 27h, 28h
                db 0, 29h, 2Ah, 2Bh, 2Ch
                db 0, 2Dh, 2Eh, 2Fh, 30h
                db 0, 31h, 32h, 33h, 34h
slug_walk_right_alt_frames db 0, 19h, 1Ah, 1Bh, 1Ch ; ...
                db 0, 35h, 36h, 37h, 38h
                db 0, 39h, 3Ah, 3Bh, 3Ch
                db 0, 3Dh, 3Eh, 3Fh, 40h
                db 0, 41h, 42h, 43h, 44h
                db 0, 45h, 46h, 47h, 48h
                db 0, 49h, 4Ah, 4Bh, 4Ch
bat_fly_frames  db 0, 4Dh, 0, 4Fh, 50h  ; ...
                db 0, 51h, 0, 52h, 53h
                db 0, 54h, 55h, 4Fh, 50h
                db 0, 56h, 57h, 58h, 59h
bat_fly_alt_frames db 0, 0, 5Bh, 5Ch, 5Dh ; ...
                db 0, 0, 5Eh, 5Fh, 60h
                db 0, 61h, 62h, 5Ch, 5Dh
                db 0, 63h, 64h, 65h, 66h
frog_jump_right_frames db 0, 75h, 76h, 77h, 78h ; ...
                db 0, 75h, 76h, 79h, 78h
                db 0, 7Ah, 7Bh, 7Ch, 7Dh
                db 0, 7Eh, 7Bh, 7Fh, 80h
                db 0, 81h, 82h, 83h, 84h
                db 0, 85h, 86h, 87h, 88h
                db 0, 89h, 8Ah, 8Bh, 8Ch
frog_jump_left_frames db 0, 8Dh, 8Eh, 8Fh, 90h ; ...
                db 0, 8Dh, 8Eh, 8Fh, 91h
                db 0, 92h, 93h, 94h, 95h
                db 0, 92h, 96h, 97h, 98h
                db 0, 99h, 9Ah, 9Bh, 9Ch
                db 0, 9Dh, 9Eh, 9Fh, 0A0h
                db 0, 0A1h, 0A2h, 0A3h, 0A4h
rat_run_right_frames db 0, 67h, 68h, 69h, 6Ah ; ...
                db 0, 6Bh, 6Ch, 6Dh, 6Eh
                db 0, 6Fh, 70h, 71h, 72h
                db 0, 73h, 74h, 0E0h, 0E1h
                db 0, 0F2h, 0F3h, 0F4h, 0F5h
                db 0, 0F6h, 0F7h, 0F4h, 0F5h
rat_run_left_frames db 0, 0E2h, 0E3h, 0E4h, 0E5h ; ...
                db 0, 0E6h, 0E7h, 0E8h, 0E9h
                db 0, 0EAh, 0EBh, 0ECh, 0EDh
                db 0, 0EEh, 0EFh, 0F0h, 0F1h
                db 0, 0F2h, 0F3h, 0F4h, 0F5h
                db 0, 0F6h, 0F7h, 0F4h, 0F5h
slug_idle_frames_set0 db 0, 0A5h, 0A6h, 0A7h, 0A8h ; ...
                db 0, 0A9h, 0AAh, 0ABh, 0ACh
                db 0, 0ADh, 0AEh, 0AFh, 0B0h
slug_idle_frames_set1 db 0, 0B1h, 0B2h, 0B3h, 0B4h ; ...
                db 0, 0B5h, 0B6h, 0B7h, 0B8h
                db 0, 0B9h, 0BAh, 0BBh, 0BCh
slug_idle_frames_set2 db 0, 0BDh, 0BEh, 0BFh, 0C0h ; ...
                db 0, 0C1h, 0C2h, 0C3h, 0C4h
                db 0, 0, 0, 0C7h, 0C8h
slug_idle_frames_set3 db 0, 0F8h, 0F9h, 0FAh, 0FBh ; ...
                db 0, 0FCh, 0FDh, 5Ah, 4Eh
                db 0, 0, 0, 0C5h, 0C6h
common_death_frames db 1, 1, 2, 3, 4    ; ...
                db 1, 5, 6, 7, 8
                db 1, 9, 0Ah, 0Bh, 0Ch
common_hit_frames db 0, 0Dh, 0Eh, 0Fh, 10h ; ...
                db 0, 11h, 12h, 13h, 14h
                db 0, 15h, 16h, 17h, 18h
                db 0, 11h, 12h, 13h, 14h
common_hit_frames_alt db 2, 0Dh, 0Eh, 0Fh, 10h ; ...
                db 2, 11h, 12h, 13h, 14h
                db 2, 15h, 16h, 17h, 18h
                db 2, 11h, 12h, 13h, 14h
frog_land_frames db 0, 0C9h, 0CAh, 0CBh, 0CCh ; ...
                db 0, 0C9h, 0CAh, 0CBh, 0CCh
rat_obstacle_frames db 1, 0CDh, 0CEh, 0CFh, 0D0h ; ...
rat_jump_up_frames db 0, 0D1h, 0D2h, 0D3h, 0D4h ; ...
rat_jump_up_frames_alt db 2, 0D1h, 0D2h, 0D3h, 0D4h ; ...
bat_dive_frames db 1, 0D5h, 0D5h, 0D5h, 0D5h ; ...
                db 1, 0D6h, 0D7h, 0D8h, 0D9h
                db 1, 0DAh, 0DBh, 0DCh, 0DDh
                db 1, 0, 0, 0DEh, 0DFh
death_split_descriptors dw offset slug_death_desc ; ...
                dw offset frog_rat_death_desc
                dw offset frog_rat_death_desc
                dw offset bat_death_desc
bat_death_desc  db 5, 0, 0, 0           ; ...
slug_death_desc db 5, 4, 4, 0           ; ...
frog_rat_death_desc db 4, 0, 4, 0       ; ...

; =============== S U B R O U T I N E =======================================


Monster_AI      proc near               ; ...

; FUNCTION CHUNK AT A3E7 SIZE 00000101 BYTES
; FUNCTION CHUNK AT A517 SIZE 000001D9 BYTES

                mov     bl, [si+monster.flags]
                and     bl, 0Fh
                xor     bh, bh
                add     bx, bx          ; switch 4 cases
                jmp     jpt_A25E[bx]    ; switch jump
; ---------------------------------------------------------------------------
jpt_A25E        dw offset flags00       ; ...
                dw offset flags01       ; jump table for switch statement
                dw offset flags10
                dw offset flags11
; ---------------------------------------------------------------------------

flags00:                                ; ...
                call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 0
                jnz     short loc_A276
                jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
; ---------------------------------------------------------------------------

loc_A276:                               ; ...
                test    [si+monster.hp], 0FFh
                jnz     short loc_A280
                mov     [si+monster.hp], 2

loc_A280:                               ; ...
                test    [si+monster.ai_flags], 20h
                jz      short loc_A28B
                jmp     cs:Hero_Hits_monster_proc
; ---------------------------------------------------------------------------

loc_A28B:                               ; ...
                mov     bl, [si+monster.ai_state]
                rol     bl, 1
                rol     bl, 1
                and     bl, 3
                xor     bh, bh
                add     bx, bx          ; switch 4 cases
                jmp     jpt_A299[bx]    ; switch jump
; ---------------------------------------------------------------------------
jpt_A299        dw offset ai_state_00   ; ...
                dw offset ai_state_40   ; jump table for switch statement
                dw offset ai_state_80
                dw offset ai_state_c0
; ---------------------------------------------------------------------------

ai_state_00:                            ; ...
                call    cs:move_monster_N_proc ; jumptable 0000A299 case 0
                test    [si+monster.anim_counter], 0FFh
                jz      short loc_A2B5
                sub     [si+monster.anim_counter], 10h
                retn
; ---------------------------------------------------------------------------

loc_A2B5:                               ; ...
                mov     al, [si+monster.m_x_rel]
                sub     al, 17
                cmp     al, 10
                jb      short loc_A2C7
                mov     al, 17
                sub     al, [si+monster.m_x_rel]
                cmp     al, 7
                jnb     short loc_A2CB

loc_A2C7:                               ; ...
                mov     [si+monster.ai_state], 40h ; '@'

loc_A2CB:                               ; ...
                mov     [si+monster.anim_counter], 0
                retn
; ---------------------------------------------------------------------------

ai_state_40:                            ; ...
                inc     [si+monster.anim_counter] ; jumptable 0000A299 case 1
                and     [si+monster.anim_counter], 7
                cmp     [si+monster.anim_counter], 3
                jz      short loc_A2DE
                retn
; ---------------------------------------------------------------------------

loc_A2DE:                               ; ...
                mov     [si+monster.ai_state], 80h
                retn
; ---------------------------------------------------------------------------

ai_state_80:                            ; ...
                call    bat_step_throttle ; jumptable 0000A299 case 2
                test    byte ptr ds:hero_damage_this_frame, 0FFh
                jz      short loc_A2F2
                mov     [si+monster.ai_state], 0C0h
                retn
; ---------------------------------------------------------------------------

loc_A2F2:                               ; ...
                mov     al, ds:hero_y_absolute ; hero_y_absolute
                sub     al, [si+monster.currY]
                add     al, 21
                and     al, 3Fh
                cmp     al, 18
                jb      short loc_A350
                cmp     al, 24
                jb      short loc_A32A
                cmp     [si+monster.m_x_rel], 11h
                jz      short loc_A376
                cmp     [si+monster.m_x_rel], 10h
                jz      short loc_A376
                jnb     short loc_A31E
                call    cs:move_monster_SE_proc
                jb      short loc_A338
                or      [si+monster.ai_flags], 80h
                retn
; ---------------------------------------------------------------------------

loc_A31E:                               ; ...
                call    cs:move_monster_SW_proc
                jb      short loc_A344
                and     [si+monster.ai_flags], 7Fh
                retn
; ---------------------------------------------------------------------------

loc_A32A:                               ; ...
                cmp     [si+monster.m_x_rel], 11h
                jz      short loc_A376
                cmp     [si+monster.m_x_rel], 10h
                jz      short loc_A376
                jnb     short loc_A344

loc_A338:                               ; ...
                call    cs:move_monster_E_proc
                jb      short loc_A376
                or      [si+monster.ai_flags], 80h
                retn
; ---------------------------------------------------------------------------

loc_A344:                               ; ...
                call    cs:move_monster_W_proc
                jb      short loc_A376
                and     [si+monster.ai_flags], 7Fh
                retn
; ---------------------------------------------------------------------------

loc_A350:                               ; ...
                cmp     [si+monster.m_x_rel], 11h
                jz      short loc_A376
                cmp     [si+monster.m_x_rel], 10h
                jz      short loc_A376
                jnb     short loc_A36A
                call    cs:move_monster_NE_proc
                jb      short loc_A338
                or      [si+monster.ai_flags], 80h
                retn
; ---------------------------------------------------------------------------

loc_A36A:                               ; ...
                call    cs:move_monster_NW_proc
                jb      short loc_A344
                and     [si+monster.ai_flags], 7Fh
                retn
; ---------------------------------------------------------------------------

loc_A376:                               ; ...
                call    cs:move_monster_S_proc
                jb      short loc_A37E
                retn
; ---------------------------------------------------------------------------

loc_A37E:                               ; ...
                mov     [si+monster.ai_state], 0C0h
                retn
; ---------------------------------------------------------------------------

ai_state_c0:                            ; ...
                test    [si+monster.ai_state], 20h ; jumptable 0000A299 case 3
                jnz     short loc_A3BD
                call    bat_step_throttle
                test    [si+monster.ai_flags], 80h
                jz      short loc_A3A0
                call    cs:move_monster_NE_proc
                jb      short loc_A39A
                retn
; ---------------------------------------------------------------------------

loc_A39A:                               ; ...
                and     [si+monster.ai_flags], 7Fh
                jmp     short loc_A3AC
; ---------------------------------------------------------------------------

loc_A3A0:                               ; ...
                call    cs:move_monster_NW_proc
                jb      short loc_A3A8
                retn
; ---------------------------------------------------------------------------

loc_A3A8:                               ; ...
                or      [si+monster.ai_flags], 80h

loc_A3AC:                               ; ...
                call    cs:move_monster_N_proc
                jb      short loc_A3B4
                retn
; ---------------------------------------------------------------------------

loc_A3B4:                               ; ...
                or      [si+monster.ai_state], 20h
                mov     [si+monster.anim_counter], 2
                retn
; ---------------------------------------------------------------------------

loc_A3BD:                               ; ...
                dec     [si+monster.anim_counter]
                and     [si+monster.anim_counter], 7
                test    [si+monster.anim_counter], 0FFh
                jz      short loc_A3CB
                retn
; ---------------------------------------------------------------------------

loc_A3CB:                               ; ...
                mov     [si+monster.anim_counter], 70h ; 'p'
                mov     [si+monster.ai_state], 0
                retn
Monster_AI      endp


; =============== S U B R O U T I N E =======================================


bat_step_throttle proc near             ; ...
                inc     [si+monster.anim_counter]
                and     [si+monster.anim_counter], 7
                cmp     [si+monster.anim_counter], 7
                jnb     short loc_A3E2
                retn
; ---------------------------------------------------------------------------

loc_A3E2:                               ; ...
                mov     [si+monster.anim_counter], 3
                retn
bat_step_throttle endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR Monster_AI

flags01:                                ; ...
                call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 1
                jnz     short loc_A3F3
                jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
; ---------------------------------------------------------------------------

loc_A3F3:                               ; ...
                test    [si+monster.hp], 0FFh
                jnz     short loc_A3FD
                mov     [si+monster.hp], 2

loc_A3FD:                               ; ...
                test    [si+monster.ai_flags], 20h
                jz      short loc_A408
                jmp     cs:Hero_Hits_monster_proc
; ---------------------------------------------------------------------------

loc_A408:                               ; ...
                call    cs:move_monster_S_proc
                jb      short loc_A410
                retn
; ---------------------------------------------------------------------------

loc_A410:                               ; ...
                add     [si+monster.anim_counter], 41h ; 'A'
                and     [si+monster.anim_counter], 11000011b
                test    [si+monster.anim_counter], 0F0h
                jz      short loc_A41F
                retn
; ---------------------------------------------------------------------------

loc_A41F:                               ; ...
                cmp     [si+monster.m_x_rel], 17
                jnb     short loc_A432
                call    cs:move_monster_E_proc
                jnb     short loc_A42D
                retn
; ---------------------------------------------------------------------------

loc_A42D:                               ; ...
                or      [si+monster.ai_flags], 80h
                retn
; ---------------------------------------------------------------------------

loc_A432:                               ; ...
                call    cs:move_monster_W_proc
                jnb     short loc_A43A
                retn
; ---------------------------------------------------------------------------

loc_A43A:                               ; ...
                and     [si+monster.ai_flags], 7Fh
                retn
; ---------------------------------------------------------------------------

flags10:                                ; ...
                call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 2
                jnz     short loc_A44B
                jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
; ---------------------------------------------------------------------------

loc_A44B:                               ; ...
                test    [si+monster.hp], 0FFh
                jnz     short loc_A455
                mov     [si+monster.hp], 1

loc_A455:                               ; ...
                test    [si+monster.ai_flags], 20h
                jz      short loc_A460
                jmp     cs:Hero_Hits_monster_proc
; ---------------------------------------------------------------------------

loc_A460:                               ; ...
                test    [si+monster.ai_state], 8
                jnz     short loc_A4A2
                add     [si+monster.anim_counter], 21h ; '!'
                and     [si+monster.anim_counter], 11100001b
                call    cs:move_monster_S_proc
                jb      short loc_A476
                retn
; ---------------------------------------------------------------------------

loc_A476:                               ; ...
                call    frog_hero_proximity_and_direction
                jb      short loc_A49A
                mov     al, [si+monster.anim_counter]
                and     al, 11100000b
                jz      short loc_A483
                retn
; ---------------------------------------------------------------------------

loc_A483:                               ; ...
                call    frog_hero_proximity_and_direction
                cmp     al, 0FFh
                jz      short loc_A49A
                and     [si+monster.ai_flags], 7Fh
                or      [si+monster.ai_flags], al
                mov     [si+monster.anim_counter], 2
                or      [si+monster.ai_state], 8
                retn
; ---------------------------------------------------------------------------

loc_A49A:                               ; ...
                mov     [si+monster.anim_counter], 2
                or      [si+monster.ai_state], 8

loc_A4A2:                               ; ...
                mov     al, [si+monster.anim_counter]
                mov     ah, al
                inc     al
                and     al, 7
                cmp     al, 7
                jnb     short loc_A4DB
                mov     ch, ah
                and     ch, 0F0h
                or      al, ch
                mov     [si+monster.anim_counter], al
                mov     bx, offset jump_angles_right
                test    [si+monster.ai_flags], 80h
                jnz     short loc_A4C5
                mov     bx, offset jump_angles_left

loc_A4C5:                               ; ...
                mov     al, ah
                sub     al, 2
                xlat
                call    cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
                jb      short loc_A4D2
                retn
; ---------------------------------------------------------------------------

loc_A4D2:                               ; ...
                call    frog_hero_proximity_and_direction
                jb      short loc_A4DB
                xor     [si+monster.ai_flags], 80h

loc_A4DB:                               ; ...
                and     [si+monster.ai_state], 0F7h
                mov     [si+monster.anim_counter], 0
                jmp     cs:move_monster_S_proc
; END OF FUNCTION CHUNK FOR Monster_AI

; =============== S U B R O U T I N E =======================================


frog_hero_proximity_and_direction proc near ; ...
                mov     al, ds:hero_y_absolute ; hero_y_absolute
                sub     al, [si+monster.currY]
                jns     short loc_A4F2
                neg     al

loc_A4F2:                               ; ...
                cmp     al, 8
                mov     al, 0FFh
                jb      short loc_A4F9
                retn
; ---------------------------------------------------------------------------

loc_A4F9:                               ; ...
                cmp     [si+monster.m_x_rel], 11h
                jnb     short loc_A50B
                mov     al, 80h
                test    [si+monster.ai_flags], 80h
                stc
                jz      short loc_A509
                retn
; ---------------------------------------------------------------------------

loc_A509:                               ; ...
                clc
                retn
; ---------------------------------------------------------------------------

loc_A50B:                               ; ...
                xor     al, al
                test    [si+monster.ai_flags], 80h
                stc
                jnz     short loc_A515
                retn
; ---------------------------------------------------------------------------

loc_A515:                               ; ...
                clc
                retn
frog_hero_proximity_and_direction endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR Monster_AI

flags11:                                ; ...
                call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 3
                jnz     short loc_A523
                jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
; ---------------------------------------------------------------------------

loc_A523:                               ; ...
                test    [si+monster.hp], 0FFh
                jnz     short loc_A52D
                mov     [si+monster.hp], 1

loc_A52D:                               ; ...
                test    [si+monster.ai_flags], 20h
                jz      short loc_A538
                jmp     cs:Hero_Hits_monster_proc
; ---------------------------------------------------------------------------

loc_A538:                               ; ...
                test    [si+monster.ai_state], 8
                jz      short loc_A541
                jmp     loc_A649
; ---------------------------------------------------------------------------

loc_A541:                               ; ...
                test    [si+monster.ai_state], 10h
                jz      short loc_A54A
                jmp     loc_A690
; ---------------------------------------------------------------------------

loc_A54A:                               ; ...
                call    cs:move_monster_S_proc
                jb      short loc_A552
                retn
; ---------------------------------------------------------------------------

loc_A552:                               ; ...
                test    [si+monster.ai_state], 4
                jz      short loc_A5C5
                and     [si+monster.anim_counter], 0F1h
                or      [si+monster.anim_counter], 4
                call    rat_hero_proximity_and_direction
                cmp     al, 0FFh
                jz      short loc_A57B
                and     [si+monster.ai_flags], 7Fh
                or      [si+monster.ai_flags], al
                mov     [si+monster.anim_counter], 0
                or      [si+monster.ai_state], 2
                and     [si+monster.ai_state], 11111011b
                retn
; ---------------------------------------------------------------------------

loc_A57B:                               ; ...
                add     [si+monster.anim_counter], 40h ; '@'
                jb      short loc_A582
                retn
; ---------------------------------------------------------------------------

loc_A582:                               ; ...
                mov     al, [si+monster.anim_counter]
                inc     al
                and     al, 1
                add     al, 4
                mov     [si+monster.anim_counter], al
                add     [si+monster.ai_state], 40h ; '@'
                jb      short loc_A595
                retn
; ---------------------------------------------------------------------------

loc_A595:                               ; ...
                and     [si+monster.ai_state], 0FBh
                and     [si+monster.ai_flags], 7Fh
                call    word ptr cs:11Ah ; Accumulate_folded_ff1b_proc
                and     al, 80h
                or      [si+monster.ai_flags], al
                or      al, al
                jns     short loc_A5B8
                call    cs:check_collision_E2_proc
                jb      short loc_A5B3
                retn
; ---------------------------------------------------------------------------

loc_A5B3:                               ; ...
                and     [si+monster.ai_flags], 7Fh
                retn
; ---------------------------------------------------------------------------

loc_A5B8:                               ; ...
                call    cs:check_collision_W2_proc
                jb      short loc_A5C0
                retn
; ---------------------------------------------------------------------------

loc_A5C0:                               ; ...
                or      [si+monster.ai_flags], 80h
                retn
; ---------------------------------------------------------------------------

loc_A5C5:                               ; ...
                mov     ax, word ptr [si+monster.currY]
                call    cs:coords_in_ax_to_proximity_map_offset_in_di_proc
                mov     ax, 48h ; 'H'
                test    [si+monster.ai_flags], 80h
                jz      short loc_A5D7
                inc     ax

loc_A5D7:                               ; ...
                xchg    si, di
                add     si, ax
                call    cs:wrap_map_from_above_proc
                xchg    si, di
                mov     al, [di]
                call    cs:if_passable_set_ZF_proc
                jnz     short loc_A5F4
                mov     [si+monster.anim_counter], 0
                or      [si+monster.ai_state], 8
                retn
; ---------------------------------------------------------------------------

loc_A5F4:                               ; ...
                inc     [si+monster.anim_counter]
                and     [si+monster.anim_counter], 3
                test    [si+monster.ai_state], 2
                jnz     short loc_A60C
                add     [si+monster.ai_timer], 10h
                jnb     short loc_A60C
                or      [si+monster.ai_state], 4
                retn
; ---------------------------------------------------------------------------

loc_A60C:                               ; ...
                call    rat_hero_proximity_and_direction
                jnb     short loc_A619
                and     [si+monster.ai_flags], 0FDh
                mov     [si+monster.ai_timer], 0

loc_A619:                               ; ...
                test    [si+monster.ai_flags], 80h
                jz      short loc_A634
                call    cs:move_monster_E_proc
                jb      short loc_A627
                retn
; ---------------------------------------------------------------------------

loc_A627:                               ; ...
                mov     [si+monster.anim_counter], 0
                or      [si+monster.ai_state], 10h
                and     [si+monster.ai_state], 1Fh
                retn
; ---------------------------------------------------------------------------

loc_A634:                               ; ...
                call    cs:move_monster_W_proc
                jb      short loc_A63C
                retn
; ---------------------------------------------------------------------------

loc_A63C:                               ; ...
                mov     [si+monster.anim_counter], 0
                or      [si+monster.ai_state], 10h
                and     [si+monster.ai_state], 1Fh
                retn
; ---------------------------------------------------------------------------

loc_A649:                               ; ...
                mov     al, [si+monster.anim_counter]
                mov     ah, al
                inc     al
                and     al, 3
                jz      short loc_A683
                and     ah, 0F0h
                or      ah, al
                mov     [si+monster.anim_counter], ah
                mov     bx, offset jump_angles_right
                test    [si+monster.ai_flags], 80h
                jnz     short loc_A668
                mov     bx, offset jump_angles_left

loc_A668:                               ; ...
                mov     al, [si+monster.anim_counter]
                xlat
                push    ax
                call    cs:Check_collision_in_direction_proc
                pop     ax
                jb      short loc_A67A
                jmp     cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
; ---------------------------------------------------------------------------

loc_A67A:                               ; ...
                and     [si+monster.ai_state], 0F7h
                or      [si+monster.ai_state], 4
                retn
; ---------------------------------------------------------------------------

loc_A683:                               ; ...
                and     [si+monster.ai_state], 0F7h
                mov     [si+monster.anim_counter], 3
                jmp     cs:move_monster_S_proc
; ---------------------------------------------------------------------------

loc_A690:                               ; ...
                add     [si+monster.ai_state], 20h ; ' '
                test    [si+monster.ai_state], 20h
                jnz     short loc_A6AD
                mov     al, [si+monster.anim_counter]
                mov     ah, al
                inc     al
                and     al, 3
                jz      short loc_A6E3
                and     ah, 0F0h
                or      ah, al
                mov     [si+monster.anim_counter], ah

loc_A6AD:                               ; ...
                mov     al, [si+monster.ai_state]
                rol     al, 1
                rol     al, 1
                rol     al, 1
                dec     al
                and     al, 7
                mov     bx, offset rat_jump_angles_right
                test    [si+monster.ai_flags], 80h
                jnz     short loc_A6C6
                mov     bx, offset rat_jump_angles_left

loc_A6C6:                               ; ...
                xlat
                call    cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
                jb      short loc_A6CF
                retn
; ---------------------------------------------------------------------------

loc_A6CF:                               ; ...
                and     [si+monster.ai_state], 0EFh
                or      [si+monster.ai_state], 4
                test    [si+monster.anim_counter], 0FFh
                jnz     short loc_A6DE
                retn
; ---------------------------------------------------------------------------

loc_A6DE:                               ; ...
                mov     [si+monster.anim_counter], 3
                retn
; ---------------------------------------------------------------------------

loc_A6E3:                               ; ...
                and     [si+monster.ai_state], 0EFh
                mov     [si+monster.anim_counter], 3
                jmp     cs:move_monster_S_proc
; END OF FUNCTION CHUNK FOR Monster_AI

; =============== S U B R O U T I N E =======================================


rat_hero_proximity_and_direction proc near ; ...
                mov     al, ds:hero_y_absolute ; hero_y_absolute
                sub     al, [si+monster.currY]
                jns     short loc_A6FA
                neg     al

loc_A6FA:                               ; ...
                cmp     al, 6
                mov     al, 0FFh
                jb      short loc_A701
                retn
; ---------------------------------------------------------------------------

loc_A701:                               ; ...
                cmp     [si+monster.m_x_rel], 17
                jnb     short loc_A713
                mov     al, 80h
                test    [si+monster.ai_flags], 80h
                stc
                jz      short loc_A711
                retn
; ---------------------------------------------------------------------------

loc_A711:                               ; ...
                clc
                retn
; ---------------------------------------------------------------------------

loc_A713:                               ; ...
                xor     al, al
                test    [si+monster.ai_flags], 80h
                stc
                jnz     short loc_A71D
                retn
; ---------------------------------------------------------------------------

loc_A71D:                               ; ...
                clc
                retn
rat_hero_proximity_and_direction endp

; ---------------------------------------------------------------------------
jump_angles_right db 1, 0, 0, 7         ; ...
                                        ; NE, E, E, SE
jump_angles_left db 3, 4, 4, 5          ; ...
                                        ; NW, W, W, SW
rat_jump_angles_right db 2, 1, 1, 0, 0, 7, 7, 6 ; ...
                                        ; N, NE, NE, E, E, SE, SE, S
rat_jump_angles_left db 2, 3, 3, 4, 4, 5, 5, 6 ; ...
eai1            ends                    ; N, NW, NW, W, W, SW, SW, S


                end      start
