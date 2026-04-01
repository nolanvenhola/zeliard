
                .686p
                .mmx
                .model small

; ===========================================================================

; Segment type: Regular
fight           segment byte public '' use16
                assume cs:fight
                ;org 6000h
                assume es:nothing, ss:nothing, ds:shared, fs:nothing, gs:nothing
00006000 Cavern_Game_Init_proc dw ?              ; offset Cavern_Game_Init
00006002 prepare_dungeon_proc dw ?               ; offset prepare_dungeon
00006004 monster_move_in_direction_proc dw ?     ; offset monster_move_in_direction ; al=angle starting from right, counter-clockwise
00006006 Check_collision_in_direction_proc dw ?  ; offset Check_collision_in_direction
00006008 move_monster_E_proc dw ?                ; offset move_monster_E
0000600A move_monster_NE_proc dw ?               ; offset move_monster_NE
0000600C move_monster_N_proc dw ?                ; offset move_monster_N
0000600E move_monster_NW_proc dw ?               ; offset move_monster_NW
00006010 move_monster_W_proc dw ?                ; offset move_monster_W
00006012 move_monster_SW_proc dw ?               ; offset move_monster_SW
00006014 move_monster_S_proc dw ?                ; offset move_monster_S
00006016 move_monster_SE_proc dw ?               ; offset move_monster_SE
00006018 check_collision_E2_proc dw ?            ; offset check_collision_E2
0000601A check_collision_W2_proc dw ?            ; offset check_collision_W2
0000601C check_collision_N2_proc dw ?            ; offset check_collision_N2
0000601E check_collision_S2_proc dw ?            ; offset check_collision_S2
00006020 check_collision_NE2_proc dw ?           ; offset check_collision_NE2
00006022 check_collision_SE2_proc dw ?           ; offset check_collision_SE2
00006024 check_collision_NW2_proc dw ?           ; offset check_collision_NW2
00006026 check_collision_SW2_proc dw ?           ; offset check_collision_SW2
00006028 coords_in_ax_to_map_offset_in_di_proc dw ? ; offset coords_in_ax_to_map_offset_in_di ; uint8_t y = AL
00006028                                         ;                      ; uint8_t x = AH
00006028                                         ;                      ; y &= 0x3F; // Clamp Y to 0-63
00006028                                         ;                      ; uint16_t di = (y * 36) + x + 0xE000;
0000602A wrap_map_from_above_proc dw ?           ; offset wrap_map_from_above ; if (si >= 0E900h) si -= 900h
0000602C wrap_map_from_below_proc dw ?           ; offset wrap_map_from_below ; if (si < 0E000h) si += 900h
0000602E if_passable_set_ZF_proc dw ?            ; offset if_passable_set_ZF
00006030 Check_Monster_Ids_Two_Rows_Below_Monster_proc dw ? ; offset Check_Monster_Ids_Two_Rows_Below_Monster
00006032 Check_Vertical_Distance_Between_Hero_And_Monster_proc dw ? ; offset Check_Vertical_Distance_Between_Hero_And_Monster
00006034 Hero_Hits_monster_proc dw ?             ; offset Hero_Hits_monster
00006036 HorizDistToHero_35_proc dw ?            ; offset HorizDistToHero_35 ; * Calculates distance to hero and checks if within a 35-unit range.
00006036                                         ;   * Accounts for world-wrapping (map edges).
00006036                                         ;   * * @param monster_x The X coordinate of the monster (AX)
00006036                                         ;   * @return Positive value (35 - distance) if in range,
00006036                                         ;   * Sets Carry Flag (CF=1) if out of range.
00006038 Get_Stats_proc  dw ?                    ; dw offset Get_Stats     ; al=0: return ah=hero_level/2
00006038                                         ;                         ; al=1: return ah=sword_total_damage
00006038                                         ;                         ; al=2..8: return ah=byte_98BE[al-2]
00006038                                         ;                         ; al=9: NOP
0000603A Move_13_Bytes_From_bx_Ptr_To_Free_Slot_proc dw ? ; dw offset Move_13_Bytes_From_bx_Ptr_To_Free_Slot
0000603C Browse_Slots_proc dw ?                  ; dw offset Browse_Slots
0000603E Find_Monsters_Near_Hero_proc dw ?       ; dw offset Find_Monsters_Near_Hero ; Return dl: number of monsters found nearby
00006040 Move_Monster_NWE_Depending_On_Whats_Below_proc dw ? ; dw offset Move_Monster_NWE_Depending_On_Whats_Below ; si points to monster struc
00006042                 db    ? ;
00006043                 db    ? ;
00006044                 db    ? ;
00006045                 db    ? ;
00006046                 db    ? ;
00006047                 db    ? ;
00006048                 db    ? ;
00006049                 db    ? ;
0000604A                 db    ? ;
0000604B                 db    ? ;
0000604C                 db    ? ;
0000604D                 db    ? ;
0000604E                 db    ? ;
0000604F                 db    ? ;
00006050                 db    ? ;
00006051                 db    ? ;
00006052                 db    ? ;
00006053                 db    ? ;
00006054                 db    ? ;
00006055                 db    ? ;
00006056                 db    ? ;
00006057                 db    ? ;
00006058                 db    ? ;
00006059                 db    ? ;
0000605A                 db    ? ;
0000605B                 db    ? ;
0000605C                 db    ? ;
0000605D                 db    ? ;
0000605E                 db    ? ;
0000605F                 db    ? ;
00006060                 db    ? ;
00006061                 db    ? ;
00006062                 db    ? ;
00006063                 db    ? ;
00006064                 db    ? ;
00006065                 db    ? ;
00006066                 db    ? ;
00006067                 db    ? ;
00006068                 db    ? ;
00006069                 db    ? ;
0000606A                 db    ? ;
0000606B                 db    ? ;
0000606C                 db    ? ;
0000606D                 db    ? ;
0000606E                 db    ? ;
0000606F                 db    ? ;
00006070                 db    ? ;
00006071                 db    ? ;
00006072                 db    ? ;
00006073                 db    ? ;
00006074                 db    ? ;
00006075                 db    ? ;
00006076                 db    ? ;
00006077                 db    ? ;
00006078                 db    ? ;
00006079                 db    ? ;
0000607A                 db    ? ;
0000607B                 db    ? ;
0000607C                 db    ? ;
0000607D                 db    ? ;
0000607E                 db    ? ;
0000607F                 db    ? ;
00006080                 db    ? ;
00006081                 db    ? ;
00006082                 db    ? ;
00006083                 db    ? ;
00006084                 db    ? ;
00006085                 db    ? ;
00006086                 db    ? ;
00006087                 db    ? ;
00006088                 db    ? ;
00006089                 db    ? ;
0000608A                 db    ? ;
0000608B                 db    ? ;
0000608C                 db    ? ;
0000608D                 db    ? ;
0000608E                 db    ? ;
0000608F                 db    ? ;
00006090                 db    ? ;
00006091                 db    ? ;
00006092                 db    ? ;
00006093                 db    ? ;
00006094                 db    ? ;
00006095                 db    ? ;
00006096                 db    ? ;
00006097                 db    ? ;
00006098                 db    ? ;
00006099                 db    ? ;
0000609A                 db    ? ;
0000609B                 db    ? ;
0000609C                 db    ? ;
0000609D                 db    ? ;
0000609E                 db    ? ;
0000609F                 db    ? ;
000060A0                 db    ? ;
000060A1                 db    ? ;
000060A2                 db    ? ;
000060A3                 db    ? ;
000060A4                 db    ? ;
000060A5                 db    ? ;
000060A6                 db    ? ;
000060A7                 db    ? ;
000060A8                 db    ? ;
000060A9                 db    ? ;
000060AA                 db    ? ;
000060AB                 db    ? ;
000060AC                 db    ? ;
000060AD                 db    ? ;
000060AE                 db    ? ;
000060AF                 db    ? ;
000060B0                 db    ? ;
000060B1                 db    ? ;
000060B2                 db    ? ;
000060B3                 db    ? ;
000060B4                 db    ? ;
000060B5                 db    ? ;
000060B6                 db    ? ;
000060B7                 db    ? ;
000060B8                 db    ? ;
000060B9                 db    ? ;
000060BA                 db    ? ;
000060BB                 db    ? ;
000060BC                 db    ? ;
000060BD                 db    ? ;
000060BE                 db    ? ;
000060BF                 db    ? ;
000060C0                 db    ? ;
000060C1                 db    ? ;
000060C2                 db    ? ;
000060C3                 db    ? ;
000060C4                 db    ? ;
000060C5                 db    ? ;
000060C6                 db    ? ;
000060C7                 db    ? ;
000060C8                 db    ? ;
000060C9                 db    ? ;
000060CA                 db    ? ;
000060CB                 db    ? ;
000060CC                 db    ? ;
000060CD                 db    ? ;
000060CE                 db    ? ;
000060CF                 db    ? ;
000060D0                 db    ? ;
000060D1                 db    ? ;
000060D2                 db    ? ;
000060D3                 db    ? ;
000060D4                 db    ? ;
000060D5                 db    ? ;
000060D6                 db    ? ;
000060D7                 db    ? ;
000060D8                 db    ? ;
000060D9                 db    ? ;
000060DA                 db    ? ;
000060DB                 db    ? ;
000060DC                 db    ? ;
000060DD                 db    ? ;
000060DE                 db    ? ;
000060DF                 db    ? ;
000060E0                 db    ? ;
000060E1                 db    ? ;
000060E2                 db    ? ;
000060E3                 db    ? ;
000060E4                 db    ? ;
000060E5                 db    ? ;
000060E6                 db    ? ;
000060E7                 db    ? ;
000060E8                 db    ? ;
000060E9                 db    ? ;
000060EA                 db    ? ;
000060EB                 db    ? ;
000060EC                 db    ? ;
000060ED                 db    ? ;
000060EE                 db    ? ;
000060EF                 db    ? ;
000060F0                 db    ? ;
000060F1                 db    ? ;
000060F2                 db    ? ;
000060F3                 db    ? ;
000060F4                 db    ? ;
000060F5                 db    ? ;
000060F6                 db    ? ;
000060F7                 db    ? ;
000060F8                 db    ? ;
000060F9                 db    ? ;
000060FA                 db    ? ;
000060FB                 db    ? ;
000060FC                 db    ? ;
000060FD                 db    ? ;
000060FE                 db    ? ;
000060FF                 db    ? ;
000060FF fight           ends
000060FF
0000A000 ; File Name   : /home/brox/Projects/zeliard/WORK/EAI1.BIN
0000A000 ; Format      : Binary file
0000A000 ; Base Address: 0000h Range: 0000h - 0737h Loaded length: 0737h
0000A000 ; ===========================================================================
0000A000
0000A000 ; Segment type: Pure code
0000A000 seg001          segment byte public 'CODE' use16
0000A000                 assume cs:seg001
0000A000                 ;org 0A000h
0000A000                 assume es:nothing, ss:nothing, ds:seg001, fs:nothing, gs:nothing
0000A000 Monster_AI_proc dw offset Monster_AI
0000A002                 dw 0
0000A004                 db    0
0000A005                 db    0
0000A006 death_split_table_ptr dw offset death_split_descriptors
0000A008                 db    3
0000A009                 db    2
0000A00A                 db    5
0000A00B                 db    3
0000A00C                 db    0
0000A00D                 db    0
0000A00E                 db    0
0000A00F                 db    0
0000A010                 db    5
0000A011                 db    5
0000A012                 db  0Fh
0000A013                 db    8
0000A014                 db    0
0000A015                 db    0
0000A016                 db    0
0000A017                 db    0
0000A018                 db    0
0000A019                 db    0
0000A01A                 db    0
0000A01B                 db    0
0000A01C                 db    0
0000A01D                 db    0
0000A01E                 db    0
0000A01F                 db    0
0000A020                 db    0
0000A021                 db    0
0000A022                 db    0
0000A023                 db    0
0000A024                 db    0
0000A025                 db    0
0000A026                 db    0
0000A027                 db    0
0000A028                 db    0
0000A029                 db    0
0000A02A                 db    0
0000A02B                 db    0
0000A02C                 db    0
0000A02D                 db    0
0000A02E                 db    0
0000A02F                 db    0
0000A030                 dw offset slug_walk_right_frames
0000A032                 dw offset bat_fly_frames
0000A034                 dw offset frog_jump_right_frames
0000A036                 dw offset rat_run_right_frames
0000A038                 db    0
0000A039                 db    0
0000A03A                 db    0
0000A03B                 db    0
0000A03C                 db    0
0000A03D                 db    0
0000A03E                 db    0
0000A03F                 db    0
0000A040                 dw offset slug_idle_frames_set0
0000A042                 dw offset slug_idle_frames_set1
0000A044                 dw offset slug_idle_frames_set2
0000A046                 dw offset slug_idle_frames_set3
0000A048                 db    0
0000A049                 db    0
0000A04A                 db    0
0000A04B                 db    0
0000A04C                 db    0
0000A04D                 db    0
0000A04E                 db    0
0000A04F                 db    0
0000A050                 dw offset bat_dive_frames
0000A052                 dw offset bat_dive_frames
0000A054                 dw offset common_death_frames
0000A056                 dw offset frog_land_frames
0000A058                 dw offset common_hit_frames
0000A05A                 dw offset common_hit_frames_alt
0000A05C                 dw offset rat_obstacle_frames
0000A05E                 db    0
0000A05F                 db    0
0000A060                 dw offset rat_jump_up_frames
0000A062                 dw offset rat_jump_up_frames_alt
0000A064                 db    0
0000A065                 db    0
0000A066                 db    0
0000A067                 db    0
0000A068                 db    0
0000A069                 db    0
0000A06A                 db    0
0000A06B                 db    0
0000A06C                 db    0
0000A06D                 db    0
0000A06E                 db    0
0000A06F                 db    0
0000A070                 dw offset slug_walk_right_alt_frames
0000A072                 dw offset bat_fly_alt_frames
0000A074                 dw offset frog_jump_left_frames
0000A076                 dw offset rat_run_left_frames
0000A078                 db    0
0000A079                 db    0
0000A07A                 db    0
0000A07B                 db    0
0000A07C                 db    0
0000A07D                 db    0
0000A07E                 db    0
0000A07F                 db    0
0000A080                 dw offset slug_idle_frames_set0
0000A082                 dw offset slug_idle_frames_set1
0000A084                 dw offset slug_idle_frames_set2
0000A086                 dw offset slug_idle_frames_set3
0000A088                 db    0
0000A089                 db    0
0000A08A                 db    0
0000A08B                 db    0
0000A08C                 db    0
0000A08D                 db    0
0000A08E                 db    0
0000A08F                 db    0
0000A090                 dw offset bat_dive_frames
0000A092                 dw offset bat_dive_frames
0000A094                 dw offset common_death_frames
0000A096                 dw offset frog_land_frames
0000A098                 dw offset common_hit_frames
0000A09A                 dw offset common_hit_frames_alt
0000A09C                 dw offset rat_obstacle_frames
0000A09E                 db    0
0000A09F                 db    0
0000A0A0                 dw offset rat_jump_up_frames
0000A0A2                 dw offset rat_jump_up_frames_alt
0000A0A4                 db    0
0000A0A5                 db    0
0000A0A6                 db    0
0000A0A7                 db    0
0000A0A8                 db    0
0000A0A9                 db    0
0000A0AA                 db    0
0000A0AB                 db    0
0000A0AC                 db    0
0000A0AD                 db    0
0000A0AE                 db    0
0000A0AF                 db    0
0000A0B0 slug_walk_right_frames db 0, 19h, 1Ah, 1Bh, 1Ch ; ...
0000A0B5                 db 0, 1Dh, 1Eh, 1Fh, 20h
0000A0BA                 db 0, 21h, 22h, 23h, 24h
0000A0BF                 db 0, 25h, 26h, 27h, 28h
0000A0C4                 db 0, 29h, 2Ah, 2Bh, 2Ch
0000A0C9                 db 0, 2Dh, 2Eh, 2Fh, 30h
0000A0CE                 db 0, 31h, 32h, 33h, 34h
0000A0D3 slug_walk_right_alt_frames db 0, 19h, 1Ah, 1Bh, 1Ch ; ...
0000A0D8                 db 0, 35h, 36h, 37h, 38h
0000A0DD                 db 0, 39h, 3Ah, 3Bh, 3Ch
0000A0E2                 db 0, 3Dh, 3Eh, 3Fh, 40h
0000A0E7                 db 0, 41h, 42h, 43h, 44h
0000A0EC                 db 0, 45h, 46h, 47h, 48h
0000A0F1                 db 0, 49h, 4Ah, 4Bh, 4Ch
0000A0F6 bat_fly_frames  db 0, 4Dh, 0, 4Fh, 50h  ; ...
0000A0FB                 db 0, 51h, 0, 52h, 53h
0000A100                 db 0, 54h, 55h, 4Fh, 50h
0000A105                 db 0, 56h, 57h, 58h, 59h
0000A10A bat_fly_alt_frames db 0, 0, 5Bh, 5Ch, 5Dh ; ...
0000A10F                 db 0, 0, 5Eh, 5Fh, 60h
0000A114                 db 0, 61h, 62h, 5Ch, 5Dh
0000A119                 db 0, 63h, 64h, 65h, 66h
0000A11E frog_jump_right_frames db 0, 75h, 76h, 77h, 78h ; ...
0000A123                 db 0, 75h, 76h, 79h, 78h
0000A128                 db 0, 7Ah, 7Bh, 7Ch, 7Dh
0000A12D                 db 0, 7Eh, 7Bh, 7Fh, 80h
0000A132                 db 0, 81h, 82h, 83h, 84h
0000A137                 db 0, 85h, 86h, 87h, 88h
0000A13C                 db 0, 89h, 8Ah, 8Bh, 8Ch
0000A141 frog_jump_left_frames db 0, 8Dh, 8Eh, 8Fh, 90h ; ...
0000A146                 db 0, 8Dh, 8Eh, 8Fh, 91h
0000A14B                 db 0, 92h, 93h, 94h, 95h
0000A150                 db 0, 92h, 96h, 97h, 98h
0000A155                 db 0, 99h, 9Ah, 9Bh, 9Ch
0000A15A                 db 0, 9Dh, 9Eh, 9Fh, 0A0h
0000A15F                 db 0, 0A1h, 0A2h, 0A3h, 0A4h
0000A164 rat_run_right_frames db 0, 67h, 68h, 69h, 6Ah ; ...
0000A169                 db 0, 6Bh, 6Ch, 6Dh, 6Eh
0000A16E                 db 0, 6Fh, 70h, 71h, 72h
0000A173                 db 0, 73h, 74h, 0E0h, 0E1h
0000A178                 db 0, 0F2h, 0F3h, 0F4h, 0F5h
0000A17D                 db 0, 0F6h, 0F7h, 0F4h, 0F5h
0000A182 rat_run_left_frames db 0, 0E2h, 0E3h, 0E4h, 0E5h ; ...
0000A187                 db 0, 0E6h, 0E7h, 0E8h, 0E9h
0000A18C                 db 0, 0EAh, 0EBh, 0ECh, 0EDh
0000A191                 db 0, 0EEh, 0EFh, 0F0h, 0F1h
0000A196                 db 0, 0F2h, 0F3h, 0F4h, 0F5h
0000A19B                 db 0, 0F6h, 0F7h, 0F4h, 0F5h
0000A1A0 slug_idle_frames_set0 db 0, 0A5h, 0A6h, 0A7h, 0A8h ; ...
0000A1A5                 db 0, 0A9h, 0AAh, 0ABh, 0ACh
0000A1AA                 db 0, 0ADh, 0AEh, 0AFh, 0B0h
0000A1AF slug_idle_frames_set1 db 0, 0B1h, 0B2h, 0B3h, 0B4h ; ...
0000A1B4                 db 0, 0B5h, 0B6h, 0B7h, 0B8h
0000A1B9                 db 0, 0B9h, 0BAh, 0BBh, 0BCh
0000A1BE slug_idle_frames_set2 db 0, 0BDh, 0BEh, 0BFh, 0C0h ; ...
0000A1C3                 db 0, 0C1h, 0C2h, 0C3h, 0C4h
0000A1C8                 db 0, 0, 0, 0C7h, 0C8h
0000A1CD slug_idle_frames_set3 db 0, 0F8h, 0F9h, 0FAh, 0FBh ; ...
0000A1D2                 db 0, 0FCh, 0FDh, 5Ah, 4Eh
0000A1D7                 db 0, 0, 0, 0C5h, 0C6h
0000A1DC common_death_frames db 1, 1, 2, 3, 4    ; ...
0000A1E1                 db 1, 5, 6, 7, 8
0000A1E6                 db 1, 9, 0Ah, 0Bh, 0Ch
0000A1EB common_hit_frames db 0, 0Dh, 0Eh, 0Fh, 10h ; ...
0000A1F0                 db 0, 11h, 12h, 13h, 14h
0000A1F5                 db 0, 15h, 16h, 17h, 18h
0000A1FA                 db 0, 11h, 12h, 13h, 14h
0000A1FF common_hit_frames_alt db 2, 0Dh, 0Eh, 0Fh, 10h ; ...
0000A204                 db 2, 11h, 12h, 13h, 14h
0000A209                 db 2, 15h, 16h, 17h, 18h
0000A20E                 db 2, 11h, 12h, 13h, 14h
0000A213 frog_land_frames db 0, 0C9h, 0CAh, 0CBh, 0CCh ; ...
0000A218                 db 0, 0C9h, 0CAh, 0CBh, 0CCh
0000A21D rat_obstacle_frames db 1, 0CDh, 0CEh, 0CFh, 0D0h ; ...
0000A222 rat_jump_up_frames db 0, 0D1h, 0D2h, 0D3h, 0D4h ; ...
0000A227 rat_jump_up_frames_alt db 2, 0D1h, 0D2h, 0D3h, 0D4h ; ...
0000A22C bat_dive_frames db 1, 0D5h, 0D5h, 0D5h, 0D5h ; ...
0000A231                 db 1, 0D6h, 0D7h, 0D8h, 0D9h
0000A236                 db 1, 0DAh, 0DBh, 0DCh, 0DDh
0000A23B                 db 1, 0, 0, 0DEh, 0DFh
0000A240 death_split_descriptors dw offset slug_death_desc ; ...
0000A242                 dw offset frog_rat_death_desc
0000A244                 dw offset frog_rat_death_desc
0000A246                 dw offset bat_death_desc
0000A248 bat_death_desc  db 5, 0, 0, 0           ; ...
0000A24C slug_death_desc db 5, 4, 4, 0           ; ...
0000A250 frog_rat_death_desc db 4, 0, 4, 0       ; ...
0000A254
0000A254 ; =============== S U B R O U T I N E =======================================
0000A254
0000A254
0000A254 Monster_AI      proc near               ; ...
0000A254
0000A254 ; FUNCTION CHUNK AT A3E7 SIZE 00000101 BYTES
0000A254 ; FUNCTION CHUNK AT A517 SIZE 000001D9 BYTES
0000A254
0000A254                 mov     bl, [si+monster.flags]
0000A257                 and     bl, 0Fh
0000A25A                 xor     bh, bh
0000A25C                 add     bx, bx          ; switch 4 cases
0000A25E                 jmp     jpt_A25E[bx]    ; switch jump
0000A25E ; ---------------------------------------------------------------------------
0000A262 jpt_A25E        dw offset flags00       ; ...
0000A264                 dw offset flags01       ; jumptable 0000A25E case 0
0000A266                 dw offset flags10
0000A268                 dw offset flags11
0000A26A ; ---------------------------------------------------------------------------
0000A26A
0000A26A flags00:                                ; ...
0000A26A                 call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 0
0000A26F                 jnz     short loc_A276
0000A271                 jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
0000A276 ; ---------------------------------------------------------------------------
0000A276
0000A276 loc_A276:                               ; ...
0000A276                 test    [si+monster.hp], 0FFh
0000A27A                 jnz     short loc_A280
0000A27C                 mov     [si+monster.hp], 2
0000A280
0000A280 loc_A280:                               ; ...
0000A280                 test    [si+monster.ai_flags], 20h
0000A284                 jz      short loc_A28B
0000A286                 jmp     cs:Hero_Hits_monster_proc
0000A28B ; ---------------------------------------------------------------------------
0000A28B
0000A28B loc_A28B:                               ; ...
0000A28B                 mov     bl, [si+monster.ai_state]
0000A28E                 rol     bl, 1
0000A290                 rol     bl, 1
0000A292                 and     bl, 3
0000A295                 xor     bh, bh
0000A297                 add     bx, bx          ; switch 4 cases
0000A299                 jmp     jpt_A299[bx]    ; switch jump
0000A299 ; ---------------------------------------------------------------------------
0000A29D jpt_A299        dw offset ai_state_00   ; ...
0000A29F                 dw offset ai_state_40   ; jumptable 0000A299 case 3
0000A2A1                 dw offset ai_state_80
0000A2A3                 dw offset ai_state_c0
0000A2A5 ; ---------------------------------------------------------------------------
0000A2A5
0000A2A5 ai_state_00:                            ; ...
0000A2A5                 call    cs:move_monster_N_proc
0000A2AA                 test    [si+monster.anim_counter], 0FFh
0000A2AE                 jz      short loc_A2B5
0000A2B0                 sub     [si+monster.anim_counter], 10h
0000A2B4                 retn
0000A2B5 ; ---------------------------------------------------------------------------
0000A2B5
0000A2B5 loc_A2B5:                               ; ...
0000A2B5                 mov     al, [si+monster.x_rel]
0000A2B8                 sub     al, 17
0000A2BA                 cmp     al, 10
0000A2BC                 jb      short loc_A2C7
0000A2BE                 mov     al, 17
0000A2C0                 sub     al, [si+monster.x_rel]
0000A2C3                 cmp     al, 7
0000A2C5                 jnb     short loc_A2CB
0000A2C7
0000A2C7 loc_A2C7:                               ; ...
0000A2C7                 mov     [si+monster.ai_state], 40h ; '@'
0000A2CB
0000A2CB loc_A2CB:                               ; ...
0000A2CB                 mov     [si+monster.anim_counter], 0
0000A2CF                 retn
0000A2D0 ; ---------------------------------------------------------------------------
0000A2D0
0000A2D0 ai_state_40:                            ; ...
0000A2D0                 inc     [si+monster.anim_counter]
0000A2D3                 and     [si+monster.anim_counter], 7
0000A2D7                 cmp     [si+monster.anim_counter], 3
0000A2DB                 jz      short loc_A2DE
0000A2DD                 retn
0000A2DE ; ---------------------------------------------------------------------------
0000A2DE
0000A2DE loc_A2DE:                               ; ...
0000A2DE                 mov     [si+monster.ai_state], 80h
0000A2E2                 retn
0000A2E3 ; ---------------------------------------------------------------------------
0000A2E3
0000A2E3 ai_state_80:                            ; ...
0000A2E3                 call    bat_step_throttle
0000A2E6                 test    ds:hero_damage_this_frame, 0FFh
0000A2EB                 jz      short loc_A2F2
0000A2ED                 mov     [si+monster.ai_state], 0C0h
0000A2F1                 retn
0000A2F2 ; ---------------------------------------------------------------------------
0000A2F2
0000A2F2 loc_A2F2:                               ; ...
0000A2F2                 mov     al, ds:hero_y_absolute ; hero_y_absolute
0000A2F5                 sub     al, [si+monster.currY]
0000A2F8                 add     al, 21
0000A2FA                 and     al, 3Fh
0000A2FC                 cmp     al, 18
0000A2FE                 jb      short loc_A350
0000A300                 cmp     al, 24
0000A302                 jb      short loc_A32A
0000A304                 cmp     [si+monster.x_rel], 11h
0000A308                 jz      short loc_A376
0000A30A                 cmp     [si+monster.x_rel], 10h
0000A30E                 jz      short loc_A376
0000A310                 jnb     short loc_A31E
0000A312                 call    cs:move_monster_SE_proc
0000A317                 jb      short loc_A338
0000A319                 or      [si+monster.ai_flags], 80h
0000A31D                 retn
0000A31E ; ---------------------------------------------------------------------------
0000A31E
0000A31E loc_A31E:                               ; ...
0000A31E                 call    cs:move_monster_SW_proc
0000A323                 jb      short loc_A344
0000A325                 and     [si+monster.ai_flags], 7Fh
0000A329                 retn
0000A32A ; ---------------------------------------------------------------------------
0000A32A
0000A32A loc_A32A:                               ; ...
0000A32A                 cmp     [si+monster.x_rel], 11h
0000A32E                 jz      short loc_A376
0000A330                 cmp     [si+monster.x_rel], 10h
0000A334                 jz      short loc_A376
0000A336                 jnb     short loc_A344
0000A338
0000A338 loc_A338:                               ; ...
0000A338                 call    cs:move_monster_E_proc
0000A33D                 jb      short loc_A376
0000A33F                 or      [si+monster.ai_flags], 80h
0000A343                 retn
0000A344 ; ---------------------------------------------------------------------------
0000A344
0000A344 loc_A344:                               ; ...
0000A344                 call    cs:move_monster_W_proc
0000A349                 jb      short loc_A376
0000A34B                 and     [si+monster.ai_flags], 7Fh
0000A34F                 retn
0000A350 ; ---------------------------------------------------------------------------
0000A350
0000A350 loc_A350:                               ; ...
0000A350                 cmp     [si+monster.x_rel], 11h
0000A354                 jz      short loc_A376
0000A356                 cmp     [si+monster.x_rel], 10h
0000A35A                 jz      short loc_A376
0000A35C                 jnb     short loc_A36A
0000A35E                 call    cs:move_monster_NE_proc
0000A363                 jb      short loc_A338
0000A365                 or      [si+monster.ai_flags], 80h
0000A369                 retn
0000A36A ; ---------------------------------------------------------------------------
0000A36A
0000A36A loc_A36A:                               ; ...
0000A36A                 call    cs:move_monster_NW_proc
0000A36F                 jb      short loc_A344
0000A371                 and     [si+monster.ai_flags], 7Fh
0000A375                 retn
0000A376 ; ---------------------------------------------------------------------------
0000A376
0000A376 loc_A376:                               ; ...
0000A376                 call    cs:move_monster_S_proc
0000A37B                 jb      short loc_A37E
0000A37D                 retn
0000A37E ; ---------------------------------------------------------------------------
0000A37E
0000A37E loc_A37E:                               ; ...
0000A37E                 mov     [si+monster.ai_state], 0C0h
0000A382                 retn
0000A383 ; ---------------------------------------------------------------------------
0000A383
0000A383 ai_state_c0:                            ; ...
0000A383                 test    [si+monster.ai_state], 20h ; jumptable 0000A299 case 3
0000A387                 jnz     short loc_A3BD
0000A389                 call    bat_step_throttle
0000A38C                 test    [si+monster.ai_flags], 80h
0000A390                 jz      short loc_A3A0
0000A392                 call    cs:move_monster_NE_proc
0000A397                 jb      short loc_A39A
0000A399                 retn
0000A39A ; ---------------------------------------------------------------------------
0000A39A
0000A39A loc_A39A:                               ; ...
0000A39A                 and     [si+monster.ai_flags], 7Fh
0000A39E                 jmp     short loc_A3AC
0000A3A0 ; ---------------------------------------------------------------------------
0000A3A0
0000A3A0 loc_A3A0:                               ; ...
0000A3A0                 call    cs:move_monster_NW_proc
0000A3A5                 jb      short loc_A3A8
0000A3A7                 retn
0000A3A8 ; ---------------------------------------------------------------------------
0000A3A8
0000A3A8 loc_A3A8:                               ; ...
0000A3A8                 or      [si+monster.ai_flags], 80h
0000A3AC
0000A3AC loc_A3AC:                               ; ...
0000A3AC                 call    cs:move_monster_N_proc
0000A3B1                 jb      short loc_A3B4
0000A3B3                 retn
0000A3B4 ; ---------------------------------------------------------------------------
0000A3B4
0000A3B4 loc_A3B4:                               ; ...
0000A3B4                 or      [si+monster.ai_state], 20h
0000A3B8                 mov     [si+monster.anim_counter], 2
0000A3BC                 retn
0000A3BD ; ---------------------------------------------------------------------------
0000A3BD
0000A3BD loc_A3BD:                               ; ...
0000A3BD                 dec     [si+monster.anim_counter]
0000A3C0                 and     [si+monster.anim_counter], 7
0000A3C4                 test    [si+monster.anim_counter], 0FFh
0000A3C8                 jz      short loc_A3CB
0000A3CA                 retn
0000A3CB ; ---------------------------------------------------------------------------
0000A3CB
0000A3CB loc_A3CB:                               ; ...
0000A3CB                 mov     [si+monster.anim_counter], 70h ; 'p'
0000A3CF                 mov     [si+monster.ai_state], 0
0000A3D3                 retn
0000A3D3 Monster_AI      endp
0000A3D3
0000A3D4
0000A3D4 ; =============== S U B R O U T I N E =======================================
0000A3D4
0000A3D4
0000A3D4 bat_step_throttle proc near             ; ...
0000A3D4                 inc     [si+monster.anim_counter]
0000A3D7                 and     [si+monster.anim_counter], 7
0000A3DB                 cmp     [si+monster.anim_counter], 7
0000A3DF                 jnb     short loc_A3E2
0000A3E1                 retn
0000A3E2 ; ---------------------------------------------------------------------------
0000A3E2
0000A3E2 loc_A3E2:                               ; ...
0000A3E2                 mov     [si+monster.anim_counter], 3
0000A3E6                 retn
0000A3E6 bat_step_throttle endp
0000A3E6
0000A3E7 ; ---------------------------------------------------------------------------
0000A3E7 ; START OF FUNCTION CHUNK FOR Monster_AI
0000A3E7
0000A3E7 flags01:                                ; ...
0000A3E7                 call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 1
0000A3EC                 jnz     short loc_A3F3
0000A3EE                 jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
0000A3F3 ; ---------------------------------------------------------------------------
0000A3F3
0000A3F3 loc_A3F3:                               ; ...
0000A3F3                 test    [si+monster.hp], 0FFh
0000A3F7                 jnz     short loc_A3FD
0000A3F9                 mov     [si+monster.hp], 2
0000A3FD
0000A3FD loc_A3FD:                               ; ...
0000A3FD                 test    [si+monster.ai_flags], 20h
0000A401                 jz      short loc_A408
0000A403                 jmp     cs:Hero_Hits_monster_proc
0000A408 ; ---------------------------------------------------------------------------
0000A408
0000A408 loc_A408:                               ; ...
0000A408                 call    cs:move_monster_S_proc
0000A40D                 jb      short loc_A410
0000A40F                 retn
0000A410 ; ---------------------------------------------------------------------------
0000A410
0000A410 loc_A410:                               ; ...
0000A410                 add     [si+monster.anim_counter], 41h ; 'A'
0000A414                 and     [si+monster.anim_counter], 11000011b
0000A418                 test    [si+monster.anim_counter], 0F0h
0000A41C                 jz      short loc_A41F
0000A41E                 retn
0000A41F ; ---------------------------------------------------------------------------
0000A41F
0000A41F loc_A41F:                               ; ...
0000A41F                 cmp     [si+monster.x_rel], 17
0000A423                 jnb     short loc_A432
0000A425                 call    cs:move_monster_E_proc
0000A42A                 jnb     short loc_A42D
0000A42C                 retn
0000A42D ; ---------------------------------------------------------------------------
0000A42D
0000A42D loc_A42D:                               ; ...
0000A42D                 or      [si+monster.ai_flags], 80h
0000A431                 retn
0000A432 ; ---------------------------------------------------------------------------
0000A432
0000A432 loc_A432:                               ; ...
0000A432                 call    cs:move_monster_W_proc
0000A437                 jnb     short loc_A43A
0000A439                 retn
0000A43A ; ---------------------------------------------------------------------------
0000A43A
0000A43A loc_A43A:                               ; ...
0000A43A                 and     [si+monster.ai_flags], 7Fh
0000A43E                 retn
0000A43F ; ---------------------------------------------------------------------------
0000A43F
0000A43F flags10:                                ; ...
0000A43F                 call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 2
0000A444                 jnz     short loc_A44B
0000A446                 jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
0000A44B ; ---------------------------------------------------------------------------
0000A44B
0000A44B loc_A44B:                               ; ...
0000A44B                 test    [si+monster.hp], 0FFh
0000A44F                 jnz     short loc_A455
0000A451                 mov     [si+monster.hp], 1
0000A455
0000A455 loc_A455:                               ; ...
0000A455                 test    [si+monster.ai_flags], 20h
0000A459                 jz      short loc_A460
0000A45B                 jmp     cs:Hero_Hits_monster_proc
0000A460 ; ---------------------------------------------------------------------------
0000A460
0000A460 loc_A460:                               ; ...
0000A460                 test    [si+monster.ai_state], 8
0000A464                 jnz     short loc_A4A2
0000A466                 add     [si+monster.anim_counter], 21h ; '!'
0000A46A                 and     [si+monster.anim_counter], 11100001b
0000A46E                 call    cs:move_monster_S_proc
0000A473                 jb      short loc_A476
0000A475                 retn
0000A476 ; ---------------------------------------------------------------------------
0000A476
0000A476 loc_A476:                               ; ...
0000A476                 call    frog_hero_proximity_and_direction
0000A479                 jb      short loc_A49A
0000A47B                 mov     al, [si+monster.anim_counter]
0000A47E                 and     al, 11100000b
0000A480                 jz      short loc_A483
0000A482                 retn
0000A483 ; ---------------------------------------------------------------------------
0000A483
0000A483 loc_A483:                               ; ...
0000A483                 call    frog_hero_proximity_and_direction
0000A486                 cmp     al, 0FFh
0000A488                 jz      short loc_A49A
0000A48A                 and     [si+monster.ai_flags], 7Fh
0000A48E                 or      [si+monster.ai_flags], al
0000A491                 mov     [si+monster.anim_counter], 2
0000A495                 or      [si+monster.ai_state], 8
0000A499                 retn
0000A49A ; ---------------------------------------------------------------------------
0000A49A
0000A49A loc_A49A:                               ; ...
0000A49A                 mov     [si+monster.anim_counter], 2
0000A49E                 or      [si+monster.ai_state], 8
0000A4A2
0000A4A2 loc_A4A2:                               ; ...
0000A4A2                 mov     al, [si+monster.anim_counter]
0000A4A5                 mov     ah, al
0000A4A7                 inc     al
0000A4A9                 and     al, 7
0000A4AB                 cmp     al, 7
0000A4AD                 jnb     short loc_A4DB
0000A4AF                 mov     ch, ah
0000A4B1                 and     ch, 0F0h
0000A4B4                 or      al, ch
0000A4B6                 mov     [si+monster.anim_counter], al
0000A4B9                 mov     bx, offset jump_angles_right
0000A4BC                 test    [si+monster.ai_flags], 80h
0000A4C0                 jnz     short loc_A4C5
0000A4C2                 mov     bx, offset jump_angles_left
0000A4C5
0000A4C5 loc_A4C5:                               ; ...
0000A4C5                 mov     al, ah
0000A4C7                 sub     al, 2
0000A4C9                 xlat
0000A4CA                 call    cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
0000A4CF                 jb      short loc_A4D2
0000A4D1                 retn
0000A4D2 ; ---------------------------------------------------------------------------
0000A4D2
0000A4D2 loc_A4D2:                               ; ...
0000A4D2                 call    frog_hero_proximity_and_direction
0000A4D5                 jb      short loc_A4DB
0000A4D7                 xor     [si+monster.ai_flags], 80h
0000A4DB
0000A4DB loc_A4DB:                               ; ...
0000A4DB                 and     [si+monster.ai_state], 0F7h
0000A4DF                 mov     [si+monster.anim_counter], 0
0000A4E3                 jmp     cs:move_monster_S_proc
0000A4E3 ; END OF FUNCTION CHUNK FOR Monster_AI
0000A4E8
0000A4E8 ; =============== S U B R O U T I N E =======================================
0000A4E8
0000A4E8
0000A4E8 frog_hero_proximity_and_direction proc near ; ...
0000A4E8                 mov     al, ds:hero_y_absolute ; hero_y_absolute
0000A4EB                 sub     al, [si+monster.currY]
0000A4EE                 jns     short loc_A4F2
0000A4F0                 neg     al
0000A4F2
0000A4F2 loc_A4F2:                               ; ...
0000A4F2                 cmp     al, 8
0000A4F4                 mov     al, 0FFh
0000A4F6                 jb      short loc_A4F9
0000A4F8                 retn
0000A4F9 ; ---------------------------------------------------------------------------
0000A4F9
0000A4F9 loc_A4F9:                               ; ...
0000A4F9                 cmp     [si+monster.x_rel], 11h
0000A4FD                 jnb     short loc_A50B
0000A4FF                 mov     al, 80h
0000A501                 test    [si+monster.ai_flags], 80h
0000A505                 stc
0000A506                 jz      short loc_A509
0000A508                 retn
0000A509 ; ---------------------------------------------------------------------------
0000A509
0000A509 loc_A509:                               ; ...
0000A509                 clc
0000A50A                 retn
0000A50B ; ---------------------------------------------------------------------------
0000A50B
0000A50B loc_A50B:                               ; ...
0000A50B                 xor     al, al
0000A50D                 test    [si+monster.ai_flags], 80h
0000A511                 stc
0000A512                 jnz     short loc_A515
0000A514                 retn
0000A515 ; ---------------------------------------------------------------------------
0000A515
0000A515 loc_A515:                               ; ...
0000A515                 clc
0000A516                 retn
0000A516 frog_hero_proximity_and_direction endp
0000A516
0000A517 ; ---------------------------------------------------------------------------
0000A517 ; START OF FUNCTION CHUNK FOR Monster_AI
0000A517
0000A517 flags11:                                ; ...
0000A517                 call    cs:Check_Monster_Ids_Two_Rows_Below_Monster_proc ; jumptable 0000A25E case 3
0000A51C                 jnz     short loc_A523
0000A51E                 jmp     cs:Check_Vertical_Distance_Between_Hero_And_Monster_proc
0000A523 ; ---------------------------------------------------------------------------
0000A523
0000A523 loc_A523:                               ; ...
0000A523                 test    [si+monster.hp], 0FFh
0000A527                 jnz     short loc_A52D
0000A529                 mov     [si+monster.hp], 1
0000A52D
0000A52D loc_A52D:                               ; ...
0000A52D                 test    [si+monster.ai_flags], 20h
0000A531                 jz      short loc_A538
0000A533                 jmp     cs:Hero_Hits_monster_proc
0000A538 ; ---------------------------------------------------------------------------
0000A538
0000A538 loc_A538:                               ; ...
0000A538                 test    [si+monster.ai_state], 8
0000A53C                 jz      short loc_A541
0000A53E                 jmp     loc_A649
0000A541 ; ---------------------------------------------------------------------------
0000A541
0000A541 loc_A541:                               ; ...
0000A541                 test    [si+monster.ai_state], 10h
0000A545                 jz      short loc_A54A
0000A547                 jmp     loc_A690
0000A54A ; ---------------------------------------------------------------------------
0000A54A
0000A54A loc_A54A:                               ; ...
0000A54A                 call    cs:move_monster_S_proc
0000A54F                 jb      short loc_A552
0000A551                 retn
0000A552 ; ---------------------------------------------------------------------------
0000A552
0000A552 loc_A552:                               ; ...
0000A552                 test    [si+monster.ai_state], 4
0000A556                 jz      short loc_A5C5
0000A558                 and     [si+monster.anim_counter], 0F1h
0000A55C                 or      [si+monster.anim_counter], 4
0000A560                 call    rat_hero_proximity_and_direction
0000A563                 cmp     al, 0FFh
0000A565                 jz      short loc_A57B
0000A567                 and     [si+monster.ai_flags], 7Fh
0000A56B                 or      [si+monster.ai_flags], al
0000A56E                 mov     [si+monster.anim_counter], 0
0000A572                 or      [si+monster.ai_state], 2
0000A576                 and     [si+monster.ai_state], 11111011b
0000A57A                 retn
0000A57B ; ---------------------------------------------------------------------------
0000A57B
0000A57B loc_A57B:                               ; ...
0000A57B                 add     [si+monster.anim_counter], 40h ; '@'
0000A57F                 jb      short loc_A582
0000A581                 retn
0000A582 ; ---------------------------------------------------------------------------
0000A582
0000A582 loc_A582:                               ; ...
0000A582                 mov     al, [si+monster.anim_counter]
0000A585                 inc     al
0000A587                 and     al, 1
0000A589                 add     al, 4
0000A58B                 mov     [si+monster.anim_counter], al
0000A58E                 add     [si+monster.ai_state], 40h ; '@'
0000A592                 jb      short loc_A595
0000A594                 retn
0000A595 ; ---------------------------------------------------------------------------
0000A595
0000A595 loc_A595:                               ; ...
0000A595                 and     [si+monster.ai_state], 0FBh
0000A599                 and     [si+monster.ai_flags], 7Fh
0000A59D                 call    word ptr cs:11Ah ; Accumulate_folded_ff1b_proc
0000A5A2                 and     al, 80h
0000A5A4                 or      [si+monster.ai_flags], al
0000A5A7                 or      al, al
0000A5A9                 jns     short loc_A5B8
0000A5AB                 call    cs:check_collision_E2_proc
0000A5B0                 jb      short loc_A5B3
0000A5B2                 retn
0000A5B3 ; ---------------------------------------------------------------------------
0000A5B3
0000A5B3 loc_A5B3:                               ; ...
0000A5B3                 and     [si+monster.ai_flags], 7Fh
0000A5B7                 retn
0000A5B8 ; ---------------------------------------------------------------------------
0000A5B8
0000A5B8 loc_A5B8:                               ; ...
0000A5B8                 call    cs:check_collision_W2_proc
0000A5BD                 jb      short loc_A5C0
0000A5BF                 retn
0000A5C0 ; ---------------------------------------------------------------------------
0000A5C0
0000A5C0 loc_A5C0:                               ; ...
0000A5C0                 or      [si+monster.ai_flags], 80h
0000A5C4                 retn
0000A5C5 ; ---------------------------------------------------------------------------
0000A5C5
0000A5C5 loc_A5C5:                               ; ...
0000A5C5                 mov     ax, word ptr [si+monster.currY]
0000A5C8                 call    cs:coords_in_ax_to_map_offset_in_di_proc
0000A5CD                 mov     ax, 48h ; 'H'
0000A5D0                 test    [si+monster.ai_flags], 80h
0000A5D4                 jz      short loc_A5D7
0000A5D6                 inc     ax
0000A5D7
0000A5D7 loc_A5D7:                               ; ...
0000A5D7                 xchg    si, di
0000A5D9                 add     si, ax
0000A5DB                 call    cs:wrap_map_from_above_proc
0000A5E0                 xchg    si, di
0000A5E2                 mov     al, [di]
0000A5E4                 call    cs:if_passable_set_ZF_proc
0000A5E9                 jnz     short loc_A5F4
0000A5EB                 mov     [si+monster.anim_counter], 0
0000A5EF                 or      [si+monster.ai_state], 8
0000A5F3                 retn
0000A5F4 ; ---------------------------------------------------------------------------
0000A5F4
0000A5F4 loc_A5F4:                               ; ...
0000A5F4                 inc     [si+monster.anim_counter]
0000A5F7                 and     [si+monster.anim_counter], 3
0000A5FB                 test    [si+monster.ai_state], 2
0000A5FF                 jnz     short loc_A60C
0000A601                 add     [si+monster.ai_timer], 10h
0000A605                 jnb     short loc_A60C
0000A607                 or      [si+monster.ai_state], 4
0000A60B                 retn
0000A60C ; ---------------------------------------------------------------------------
0000A60C
0000A60C loc_A60C:                               ; ...
0000A60C                 call    rat_hero_proximity_and_direction
0000A60F                 jnb     short loc_A619
0000A611                 and     [si+monster.ai_flags], 0FDh
0000A615                 mov     [si+monster.ai_timer], 0
0000A619
0000A619 loc_A619:                               ; ...
0000A619                 test    [si+monster.ai_flags], 80h
0000A61D                 jz      short loc_A634
0000A61F                 call    cs:move_monster_E_proc
0000A624                 jb      short loc_A627
0000A626                 retn
0000A627 ; ---------------------------------------------------------------------------
0000A627
0000A627 loc_A627:                               ; ...
0000A627                 mov     [si+monster.anim_counter], 0
0000A62B                 or      [si+monster.ai_state], 10h
0000A62F                 and     [si+monster.ai_state], 1Fh
0000A633                 retn
0000A634 ; ---------------------------------------------------------------------------
0000A634
0000A634 loc_A634:                               ; ...
0000A634                 call    cs:move_monster_W_proc
0000A639                 jb      short loc_A63C
0000A63B                 retn
0000A63C ; ---------------------------------------------------------------------------
0000A63C
0000A63C loc_A63C:                               ; ...
0000A63C                 mov     [si+monster.anim_counter], 0
0000A640                 or      [si+monster.ai_state], 10h
0000A644                 and     [si+monster.ai_state], 1Fh
0000A648                 retn
0000A649 ; ---------------------------------------------------------------------------
0000A649
0000A649 loc_A649:                               ; ...
0000A649                 mov     al, [si+monster.anim_counter]
0000A64C                 mov     ah, al
0000A64E                 inc     al
0000A650                 and     al, 3
0000A652                 jz      short loc_A683
0000A654                 and     ah, 0F0h
0000A657                 or      ah, al
0000A659                 mov     [si+monster.anim_counter], ah
0000A65C                 mov     bx, offset jump_angles_right
0000A65F                 test    [si+monster.ai_flags], 80h
0000A663                 jnz     short loc_A668
0000A665                 mov     bx, offset jump_angles_left
0000A668
0000A668 loc_A668:                               ; ...
0000A668                 mov     al, [si+monster.anim_counter]
0000A66B                 xlat
0000A66C                 push    ax
0000A66D                 call    cs:Check_collision_in_direction_proc
0000A672                 pop     ax
0000A673                 jb      short loc_A67A
0000A675                 jmp     cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
0000A67A ; ---------------------------------------------------------------------------
0000A67A
0000A67A loc_A67A:                               ; ...
0000A67A                 and     [si+monster.ai_state], 0F7h
0000A67E                 or      [si+monster.ai_state], 4
0000A682                 retn
0000A683 ; ---------------------------------------------------------------------------
0000A683
0000A683 loc_A683:                               ; ...
0000A683                 and     [si+monster.ai_state], 0F7h
0000A687                 mov     [si+monster.anim_counter], 3
0000A68B                 jmp     cs:move_monster_S_proc
0000A690 ; ---------------------------------------------------------------------------
0000A690
0000A690 loc_A690:                               ; ...
0000A690                 add     [si+monster.ai_state], 20h ; ' '
0000A694                 test    [si+monster.ai_state], 20h
0000A698                 jnz     short loc_A6AD
0000A69A                 mov     al, [si+monster.anim_counter]
0000A69D                 mov     ah, al
0000A69F                 inc     al
0000A6A1                 and     al, 3
0000A6A3                 jz      short loc_A6E3
0000A6A5                 and     ah, 0F0h
0000A6A8                 or      ah, al
0000A6AA                 mov     [si+monster.anim_counter], ah
0000A6AD
0000A6AD loc_A6AD:                               ; ...
0000A6AD                 mov     al, [si+monster.ai_state]
0000A6B0                 rol     al, 1
0000A6B2                 rol     al, 1
0000A6B4                 rol     al, 1
0000A6B6                 dec     al
0000A6B8                 and     al, 7
0000A6BA                 mov     bx, offset rat_jump_angles_right
0000A6BD                 test    [si+monster.ai_flags], 80h
0000A6C1                 jnz     short loc_A6C6
0000A6C3                 mov     bx, offset rat_jump_angles_left
0000A6C6
0000A6C6 loc_A6C6:                               ; ...
0000A6C6                 xlat
0000A6C7                 call    cs:monster_move_in_direction_proc ; monster_move_in_direction; al=angle starting from right, counter-clockwise
0000A6CC                 jb      short loc_A6CF
0000A6CE                 retn
0000A6CF ; ---------------------------------------------------------------------------
0000A6CF
0000A6CF loc_A6CF:                               ; ...
0000A6CF                 and     [si+monster.ai_state], 0EFh
0000A6D3                 or      [si+monster.ai_state], 4
0000A6D7                 test    [si+monster.anim_counter], 0FFh
0000A6DB                 jnz     short loc_A6DE
0000A6DD                 retn
0000A6DE ; ---------------------------------------------------------------------------
0000A6DE
0000A6DE loc_A6DE:                               ; ...
0000A6DE                 mov     [si+monster.anim_counter], 3
0000A6E2                 retn
0000A6E3 ; ---------------------------------------------------------------------------
0000A6E3
0000A6E3 loc_A6E3:                               ; ...
0000A6E3                 and     [si+monster.ai_state], 0EFh
0000A6E7                 mov     [si+monster.anim_counter], 3
0000A6EB                 jmp     cs:move_monster_S_proc
0000A6EB ; END OF FUNCTION CHUNK FOR Monster_AI
0000A6F0
0000A6F0 ; =============== S U B R O U T I N E =======================================
0000A6F0
0000A6F0
0000A6F0 rat_hero_proximity_and_direction proc near ; ...
0000A6F0                 mov     al, ds:hero_y_absolute ; hero_y_absolute
0000A6F3                 sub     al, [si+monster.currY]
0000A6F6                 jns     short loc_A6FA
0000A6F8                 neg     al
0000A6FA
0000A6FA loc_A6FA:                               ; ...
0000A6FA                 cmp     al, 6
0000A6FC                 mov     al, 0FFh
0000A6FE                 jb      short loc_A701
0000A700                 retn
0000A701 ; ---------------------------------------------------------------------------
0000A701
0000A701 loc_A701:                               ; ...
0000A701                 cmp     [si+monster.x_rel], 17
0000A705                 jnb     short loc_A713
0000A707                 mov     al, 80h
0000A709                 test    [si+monster.ai_flags], 80h
0000A70D                 stc
0000A70E                 jz      short loc_A711
0000A710                 retn
0000A711 ; ---------------------------------------------------------------------------
0000A711
0000A711 loc_A711:                               ; ...
0000A711                 clc
0000A712                 retn
0000A713 ; ---------------------------------------------------------------------------
0000A713
0000A713 loc_A713:                               ; ...
0000A713                 xor     al, al
0000A715                 test    [si+monster.ai_flags], 80h
0000A719                 stc
0000A71A                 jnz     short loc_A71D
0000A71C                 retn
0000A71D ; ---------------------------------------------------------------------------
0000A71D
0000A71D loc_A71D:                               ; ...
0000A71D                 clc
0000A71E                 retn
0000A71E rat_hero_proximity_and_direction endp
0000A71E
0000A71E ; ---------------------------------------------------------------------------
0000A71F jump_angles_right db 1, 0, 0, 7         ; ...
0000A71F                                         ; NE, E, E, SE
0000A723 jump_angles_left db 3, 4, 4, 5          ; ...
0000A723                                         ; NW, W, W, SW
0000A727 rat_jump_angles_right db 2, 1, 1, 0, 0, 7, 7, 6 ; ...
0000A727                                         ; N, NE, NE, E, E, SE, SE, S
0000A72F rat_jump_angles_left db 2, 3, 3, 4, 4, 5, 5, 6 ; ...
0000A72F seg001          ends                    ; N, NW, NW, W, W, SW, SW, S
0000A72F
0000E000 ; ===========================================================================
0000E000
0000E000 ; Segment type: Pure data
0000E000 buffers         segment byte public 'DATA' use16
0000E000                 assume cs:buffers
0000E000                 ;org 0E000h
0000E000                 db 0DA1h dup(?)
0000E000 buffers         ends
0000E000
0000F000 ; ===========================================================================
0000F000
0000F000 ; Segment type: Pure data
0000F000 shared          segment byte public 'DATA' use16
0000F000                 assume cs:shared
0000F000                 ;org 0F000h
0000F000                 db 0F35h dup(?)
0000FF35 hero_y_absolute db ?
0000FF36 hero_damage_this_frame db ?
0000FF37 hero_sprite_hidden db    ? ;
0000FF38                 db    ? ;
0000FF39                 db    ? ;
0000FF3A                 db    ? ;
0000FF3B                 db    ? ;
0000FF3C spell_active_flag db    ? ;
0000FF3D                 db 0C2h dup(?)
0000FF3D shared          ends
0000FF3D
0000FF3D
0000FF3D                 end
