include common.inc
                .286
                .model small
select          segment byte public 'CODE' use16
                assume cs:select, ds:select
                org 0A000h
start:
                dw offset Inventory_Screen
                dw offset Inventory_Screen_Full

; =============== S U B R O U T I N E =======================================


; Input: None (reads inventory state from savegame variables)
; Output: Returns when user exits inventory screen
; Clobbers: All registers
; Notes: Entry point 0 — displays inventory in normal mode
Inventory_Screen        proc near

                mov     inventory_mode, 0
                jmp     short loc_A010
; ---------------------------------------------------------------------------

; Input: None (reads inventory state from savegame variables)
; Output: Returns when user exits inventory screen
; Clobbers: All registers
; Notes: Entry point 1 — displays inventory with all items visible
Inventory_Screen_Full:
                mov     inventory_mode, 0FFh

loc_A010:
                mov     screen_backed_up_flag, 0
                mov     si, offset menu_label_positions
                mov     cx, 4

loc_A01B:
                push    cx
                lodsw
                mov     bx, ax
                lodsw
                mov     cx, ax
                push    si
                mov     al, 0FFh
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                pop     si
                pop     cx
                loop    loc_A01B
                call    Render_Menu_Labels
                push    cs
                pop     es
                assume es:nothing
                mov     si, offset espada_active
                mov     di, offset spells_active
                xor     cl, cl
                mov     ch, 1

loc_A03D:                               ; espada_active, saeta_active, fuego_active, lanzar_active, rascar_active, agua_active, guerra_active
                lodsb
                or      al, al
                jz      short loc_A047
                mov     al, ch
                stosb
                inc     cl

loc_A047:
                inc     ch
                cmp     ch, 8
                jnz     short loc_A03D
                mov     active_magic_count, cl
                mov     si, offset Feruza_Shoes
                mov     di, offset wearables
                xor     al, al
                stosb
                xor     cl, cl
                mov     ch, 5

loc_A05F:                               ; Feruza_Shoes, Pirika_Shoes, Silkarn_Shoes, Ruzeria_Shoes, Asbestos_Cape
                lodsb
                or      al, al
                jz      short loc_A067
                stosb
                inc     cl

loc_A067:
                dec     ch
                jnz     short loc_A05F
                or      cl, cl
                jz      short loc_A071
                inc     cl

loc_A071:
                mov     active_wearable_count, cl
                call    Collect_Active_Items
                call    Render_Magics_Panel
                call    Render_Wearables_Panel
                call    Render_Items_Panel
                call    Render_Equipment_Panel
                call    Check_Menu_Exit
                sbb     al, al
                mov     exit_pending_flag_inv, al
                xor     cl, cl
                test    active_magic_count, 0FFh
                jnz     short loc_A0B4
                inc     cl
                test    active_wearable_count, 0FFh
                jnz     short loc_A0B4
                test    inventory_mode, 0FFh
                jnz     short loc_A0AE
                inc     cl
                test    active_item_count, 0FFh
                jnz     short loc_A0B4

loc_A0AE:
                call    Check_Menu_Exit
                jnb     short loc_A0AE
                retn
; ---------------------------------------------------------------------------

loc_A0B4:
                mov     current_tab, cl

loc_A0B8:
                mov     bl, current_tab
                xor     bh, bh
                add     bx, bx          ; switch 3 cases
                jmp     tab_switch_jump_table[bx]    ; switch jump
; ---------------------------------------------------------------------------
tab_switch_jump_table dw offset loc_magic_tab
                dw offset loc_wear_tab
                dw offset loc_use_tab
; ---------------------------------------------------------------------------

loc_magic_tab:                          ; jumptable case 0 - magic selection tab
                call    Render_Menu_Labels
                mov     al, 2
                call    Draw_Magic_Status_Frame

wait_up_down_release:                   ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 11b
                jnz     short wait_up_down_release

loc_A0D8:
                call    Check_Menu_Exit
                jnb     short loc_A0DE
                retn
; ---------------------------------------------------------------------------

loc_A0DE:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 1110b
                jz      short loc_A0D8
                and     al, 1100b
                jnz     short loc_A0EB
                jmp     loc_A190
; ---------------------------------------------------------------------------

loc_A0EB:
                test    al, 100b
                jnz     short loc_A116
                mov     al, selected_magic_index
                inc     al
                mov     ah, active_magic_count
                dec     ah
                cmp     ah, al
                jb      short loc_A0D8
                xor     al, al
                call    Draw_Magic_Status_Frame
                inc     selected_magic_index
                mov     al, 2
                call    Draw_Magic_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Magic_Detail
                jmp     short loc_A0D8
; ---------------------------------------------------------------------------

loc_A116:
                test    selected_magic_index, 0FFh
                jz      short loc_A0D8
                xor     al, al
                call    Draw_Magic_Status_Frame
                dec     selected_magic_index
                mov     al, 2
                call    Draw_Magic_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Magic_Detail
                jmp     short loc_A0D8
Inventory_Screen        endp


; =============== S U B R O U T I N E =======================================


; Input: selected_magic_index = index of magic to display
; Output: Renders magic spell detail panel at fixed position
Render_Selected_Magic_Detail        proc near
                mov     bx, offset spells_active
                mov     al, selected_magic_index
                xlat
                mov     ds:current_magic_spell, al
                mov     bx, 2711h
                mov     cx, 1009h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     si, magic_names_table[bx]
                mov     bx, 9Eh
                mov     cl, 12h
                mov     ah, 1
                call    Render_String_At_Position
                mov     al, ds:current_magic_spell
                mov     bx, 37A4h
                call    word ptr cs:201Eh ; Render_Magic_Spell_Item_Sprite_16x16_proc
                call    word ptr cs:2018h ; Print_Magic_Left_Decimal_proc

wait_left_right_release:                ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 1100b
                jnz     short wait_left_right_release
                retn
Render_Selected_Magic_Detail        endp


; =============== S U B R O U T I N E =======================================


; Input: selected_magic_index = magic index to highlight (bh)
; Output: Draws status frame around magic selection panel
Draw_Magic_Status_Frame        proc near
                mov     bh, selected_magic_index
                xor     bl, bl
                add     bx, bx
                add     bx, bx
                add     bx, bx
                add     bx, 0E1Ah
                jmp     word ptr cs:202Eh ; Draw_Status_Frame_proc
Draw_Magic_Status_Frame        endp

; ---------------------------------------------------------------------------

loc_A190:
                mov     cl, 1
                test    active_wearable_count, 0FFh
                jnz     short loc_A1AA
                test    inventory_mode, 0FFh
                mov     cl, 2
                test    active_item_count, 0FFh
                jnz     short loc_A1AA
                jmp     loc_A0D8
; ---------------------------------------------------------------------------

loc_A1AA:                               ; soundFX_request
                mov     byte ptr ds:soundFX_request, 0Dh
                mov     current_tab, cl
                mov     al, 5
                call    Draw_Magic_Status_Frame
                jmp     loc_A0B8
; ---------------------------------------------------------------------------

loc_wear_tab:                           ; jumptable case 1 - wear tab
                call    Render_Menu_Labels
                mov     al, 2
                call    Draw_Accessory_Status_Frame

loc_A1C3:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 3
                jnz     short loc_A1C3

loc_A1C9:
                call    Check_Menu_Exit
                jnb     short loc_A1CF
                retn
; ---------------------------------------------------------------------------

loc_A1CF:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 0Fh
                jz      short loc_A1C9
                mov     ah, al
                and     al, 0Ch
                jnz     short loc_A1DE
                jmp     loc_A27D
; ---------------------------------------------------------------------------

loc_A1DE:
                test    al, 4
                jnz     short loc_A209
                mov     al, selected_wearable_index
                inc     al
                mov     ah, active_wearable_count
                dec     ah
                cmp     ah, al
                jb      short loc_A1C9
                xor     al, al
                call    Draw_Accessory_Status_Frame
                inc     selected_wearable_index
                mov     al, 2
                call    Draw_Accessory_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Accessory_Detail
                jmp     short loc_A1C9
; ---------------------------------------------------------------------------

loc_A209:
                test    selected_wearable_index, 0FFh
                jz      short loc_A1C9
                xor     al, al
                call    Draw_Accessory_Status_Frame
                dec     selected_wearable_index
                mov     al, 2
                call    Draw_Accessory_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Accessory_Detail
                jmp     short loc_A1C9

; =============== S U B R O U T I N E =======================================


; Input: selected_wearable_index = wearable index to display
; Output: Renders accessory detail panel at fixed position
Render_Selected_Accessory_Detail        proc near
                mov     bx, offset wearables
                mov     al, selected_wearable_index
                xlat
                mov     ds:current_accessory, al
                mov     bx, 1742h
                mov     cx, 1611h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     bl, ds:current_accessory
                xor     bh, bh
                add     bx, bx
                mov     si, wearable_names_table[bx]
                mov     bx, 5Ch ; '\'
                mov     cl, 43h ; 'C'
                mov     ah, 1
                call    Render_String_At_Position
                mov     bx, 5Ch ; '\'
                mov     cl, 4Bh ; 'K'
                mov     ah, 1
                call    Render_String_At_Position

loc_A25F:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 0Ch
                jnz     short loc_A25F
                retn
Render_Selected_Accessory_Detail        endp


; =============== S U B R O U T I N E =======================================


; Input: selected_wearable_index = wearable index to highlight (bh)
; Output: Draws status frame around wearable selection panel
Draw_Accessory_Status_Frame        proc near
                mov     bh, selected_wearable_index
                xor     bl, bl
                mov     cx, bx
                add     bx, bx
                add     bx, bx
                add     bx, cx
                add     bx, 0E53h
                jmp     word ptr cs:202Eh ; Draw_Status_Frame_proc
Draw_Accessory_Status_Frame        endp

; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

loc_A27D:
                test    ah, 1
                jz      short loc_A293
                test    active_magic_count, 0FFh
                jnz     short loc_A28C
                jmp     loc_A1C9
; ---------------------------------------------------------------------------

loc_A28C:
                mov     current_tab, 0
                jmp     short loc_A2AC
; ---------------------------------------------------------------------------

loc_A293:
                test    inventory_mode, 0FFh
                jz      short loc_A29D
                jmp     loc_A1C9
; ---------------------------------------------------------------------------

loc_A29D:
                test    active_item_count, 0FFh
                jnz     short loc_A2A7
                jmp     loc_A1C9
; ---------------------------------------------------------------------------

loc_A2A7:
                mov     current_tab, 2

loc_A2AC:                               ;
                mov     byte ptr ds:soundFX_request, 0Dh
                mov     al, 5
                call    Draw_Accessory_Status_Frame
                jmp     loc_A0B8
; ---------------------------------------------------------------------------

loc_use_tab:                              ; jumptable case 2 - use tab
                call    Render_Menu_Labels
                mov     al, 2
                call    Draw_Item_Status_Frame

loc_A2C1:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 3
                jnz     short loc_A2C1

loc_A2C7:
                call    Check_Menu_Exit
                jnb     short loc_A2CD
                retn
; ---------------------------------------------------------------------------

loc_A2CD:                               ;
                cmp     word ptr ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1010000110b
                jnz     short loc_A2D8
                jmp     loc_A3B7
; ---------------------------------------------------------------------------

loc_A2D8:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     ah, 1
                jz      short space_pressed
                jmp     loc_A40D
; ---------------------------------------------------------------------------

space_pressed:
                and     al, 1101b
                jz      short loc_A2C7
                push    ax
                call    Restore_Screen_From_Backup
                pop     ax
                and     al, 1100b
                jnz     short loc_A2F2
                jmp     loc_A391
; ---------------------------------------------------------------------------

loc_A2F2:
                test    al, 4
                jnz     short loc_A31D
                mov     al, current_item_for_use
                inc     al
                mov     ah, active_item_count
                dec     ah
                cmp     ah, al
                jb      short loc_A2C7
                xor     al, al
                call    Draw_Item_Status_Frame
                inc     current_item_for_use
                mov     al, 2
                call    Draw_Item_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Item_Detail
                jmp     short loc_A2C7
; ---------------------------------------------------------------------------

loc_A31D:
                test    current_item_for_use, 0FFh
                jz      short loc_A2C7
                xor     al, al
                call    Draw_Item_Status_Frame
                dec     current_item_for_use
                mov     al, 2
                call    Draw_Item_Status_Frame
                mov     byte ptr ds:soundFX_request, 0Ch
                call    Render_Selected_Item_Detail
                jmp     short loc_A2C7

; =============== S U B R O U T I N E =======================================


; Input: current_item_for_use = item index to display
; Output: Renders item detail panel (USE mode) at fixed position
Render_Selected_Item_Detail        proc near
                mov     bx, offset active_items_buffer
                mov     al, current_item_for_use
                xlat
                mov     selected_item_index, al
                mov     bx, 1570h
                mov     cx, 1811h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     bl, selected_item_index
                xor     bh, bh
                add     bx, bx
                mov     si, item_names_table[bx]
                mov     bx, 54h ; 'T'
                mov     cl, 70h ; 'p'
                mov     ah, 1
                call    Render_String_At_Position
                mov     bx, 54h ; 'T'
                mov     cl, 78h ; 'x'
                mov     ah, 1
                call    Render_String_At_Position

loc_A373:                               ; ah: ____Alt_Space
                int     61h             ; al: ____right_left_down_up
                and     al, 0Ch
                jnz     short loc_A373
                retn
Render_Selected_Item_Detail        endp


; =============== S U B R O U T I N E =======================================


; Input: current_item_for_use = item index to highlight (bh)
; Output: Draws status frame around item (USE) selection panel
Draw_Item_Status_Frame        proc near
                mov     bh, current_item_for_use
                xor     bl, bl
                mov     cx, bx
                add     bx, bx
                add     bx, bx
                add     bx, cx
                add     bx, 0E81h
                jmp     word ptr cs:202Eh ; Draw_Status_Frame_proc
Draw_Item_Status_Frame        endp

; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

loc_A391:
                mov     cl, 1
                test    active_wearable_count, 0FFh
                jnz     short loc_A3A6
                xor     cl, cl
                test    active_magic_count, 0FFh
                jnz     short loc_A3A6
                jmp     loc_A2C7
; ---------------------------------------------------------------------------

loc_A3A6:
                mov     current_tab, cl
                mov     byte ptr ds:soundFX_request, 0Dh
                mov     al, 5
                call    Draw_Item_Status_Frame
                jmp     loc_A0B8
; ---------------------------------------------------------------------------

loc_A3B7:
                test    screen_backed_up_flag, 0FFh
                jz      short loc_A3C1
                jmp     loc_A2C7
; ---------------------------------------------------------------------------

loc_A3C1:
                call    Capture_Screen_Backup
                mov     bx, 1B43h
                mov     cx, 1A24h
                mov     al, 0FFh
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     si, offset aLevel ; "LEVEL"
                mov     bx, 80h
                mov     cl, 4Ch ; 'L'
                mov     ah, 1
                call    Render_String_At_Position
                mov     al, ds:hero_level
                xor     ah, ah
                inc     ax
                mov     cx, 2
                mov     bl, 6
                mov     dx, 2C4Ch
                call    Render_Decimal_Number
                mov     si, offset aExp ; "EXP"
                mov     bx, 80h
                mov     cl, 56h ; 'V'
                mov     ah, 1
                call    Render_String_At_Position
                mov     ax, ds:hero_xp
                mov     cx, 5
                mov     bl, 6
                mov     dx, 2856h
                call    Render_Decimal_Number
                jmp     loc_A2C7
; ---------------------------------------------------------------------------

loc_A40D:
                test    selected_item_index, 0FFh
                jnz     short loc_A417
                jmp     loc_A2C7
; ---------------------------------------------------------------------------

loc_A417:
                call    Restore_Screen_From_Backup
                mov     ax, offset loc_A2C7
                push    ax
                mov     ax, offset Clear_Item_Panel
                push    ax
                mov     cl, current_item_for_use
                xor     ch, ch
                mov     bx, offset magic_items

loc_A42B:
                test    byte ptr [bx], 0FFh
                jz      short loc_A432
                inc     ch

loc_A432:
                inc     bx
                cmp     ch, cl
                jnz     short loc_A42B
                mov     byte ptr [bx-1], 0
                call    Collect_Active_Items
                mov     al, selected_item_index
                mov     ds:byte_FF4B, al
                mov     bl, selected_item_index
                dec     bl
                xor     bh, bh
                add     bx, bx          ; switch 8 cases
                jmp     item_effect_jump_table[bx]    ; switch jump
; ---------------------------------------------------------------------------
item_effect_jump_table dw offset item_heal_hp
                dw offset item_full_heal
                dw offset item_set_espada
                dw offset item_refresh_all_spells
                dw offset item_spirit_shield
                dw offset item_repair_shield
                dw offset item_enchant_sword
                dw offset item_exit_inventory
; ---------------------------------------------------------------------------

item_heal_hp:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                add     word ptr ds:hero_HP, 80
                mov     ax, ds:hero_HP
                sub     ax, ds:heroMaxHp
                jb      short loc_A47B
                mov     ax, ds:heroMaxHp
                mov     ds:hero_HP, ax

loc_A47B:                               ;
                call    word ptr cs:2008h ; Draw_Hero_Health_proc
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------

item_full_heal:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                mov     ax, ds:heroMaxHp
                mov     ds:hero_HP, ax
                call    word ptr cs:2008h ; Draw_Hero_Health_proc
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------

item_set_espada:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                test    byte ptr ds:current_magic_spell, 0FFh
                jnz     short loc_A4A3
                retn
; ---------------------------------------------------------------------------

loc_A4A3:                               ;
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                mov     al, [bx+espada_count]
                mov     [bx+spells_espada], al
                call    word ptr cs:2018h ; Print_Magic_Left_Decimal_proc
                call    Render_Magic_Counts_Panel
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------

item_refresh_all_spells:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                push    cs
                pop     es
                mov     si, offset espada_count
                mov     di, offset spells_espada
                mov     cx, 7
                rep movsb
                call    word ptr cs:2018h ; Print_Magic_Left_Decimal_proc
                call    Render_Magic_Counts_Panel
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------

item_enchant_sword:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                inc     byte ptr ds:byte_E4
                call    Render_Enchantment_Count
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------

item_repair_shield:                               ;
                mov     byte ptr ds:soundFX_request, 0Eh
                test    byte ptr ds:shield_type, 0FFh
                jnz     short loc_A4F7
                retn
; ---------------------------------------------------------------------------

loc_A4F7:                               ;
                mov     bl, ds:shield_type
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     ax, shield_hp_values[bx]
                add     ds:shield_HP, ax
                mov     ax, ds:shield_HP
                sub     ax, ds:shield_max_HP
                jb      short loc_A518
                mov     ax, ds:shield_max_HP
                mov     ds:shield_HP, ax

loc_A518:                               ;
                call    word ptr cs:201Ah ; Print_ShieldHP_Decimal_proc
                jmp     Render_Item_Usage_Text
; ---------------------------------------------------------------------------
shield_hp_values       dw 50h, 5Ah, 64h, 6Eh, 73h, 78h
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

item_spirit_shield:
                push    cs
                pop     es
                mov     byte ptr ds:soundFX_request, 0Eh
                mov     spirit_copy_src, 0
                mov     spirit_copy_flag, 1
                mov     si, offset spirit_copy_src
                mov     di, 0EB60h
                mov     cx, 7
                rep movsb
                mov     spirit_copy_src, 4
                mov     spirit_copy_flag, 0FFh
                mov     si, offset spirit_copy_src
                mov     di, 0EB67h
                mov     cx, 7
                rep movsb
                mov     spirit_copy_src, 8
                mov     si, offset spirit_copy_src
                mov     di, 0EB6Eh
                mov     cx, 7
                rep movsb
                mov     spirit_copy_src, 0Ch
                mov     spirit_copy_flag, 1
                mov     si, offset spirit_copy_src
                mov     di, 0EB75h
                mov     cx, 7
                rep movsb
                jmp     short Render_Item_Usage_Text
; ---------------------------------------------------------------------------
spirit_copy_src       db 0
spirit_copy_flag       db 0
                db  50h ; P
                db    0
                db    0
                db    0
                db    0
; ---------------------------------------------------------------------------

item_exit_inventory:                               ;
                mov     byte ptr ds:soundFX_request, 0Fh
                call    Render_Item_Usage_Text
                call    Clear_Item_Panel
                pop     ax
                pop     ax
                mov     byte ptr ds:byte_FF24, 8
                mov     byte ptr ds:frame_timer, 0

loc_A5A2:
                cmp     byte ptr ds:frame_timer, 78h ; 'x'
                jb      short loc_A5A2
                call    word ptr cs:2040h ; Fade_To_Black_Dithered_proc
                mov     ax, 1
                int     60h             ; adlib fn_1
                retn

; =============== S U B R O U T I N E =======================================


; Output: Clears item panel, shows "NO USE" or "NOTHING", renders items
Clear_Item_Panel        proc near
                xor     al, al
                call    Draw_Item_Status_Frame
                mov     bx, 0E83h
                mov     cx, 1E10h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                test    active_item_count, 0FFh
                jnz     short loc_A5D2
                mov     active_item_count, 1

loc_A5D2:
                call    Render_Items_Panel
                mov     al, 2
                jmp     Draw_Item_Status_Frame
Clear_Item_Panel        endp


; =============== S U B R O U T I N E =======================================


; Input: selected_item_index = item that was consumed
; Output: Captures screen, renders "I have used..." text for item
Render_Item_Usage_Text        proc near
                call    Capture_Screen_Backup
                mov     bx, 0F43h
                mov     cx, 3224h
                mov     al, 0FFh
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     si, offset aIHaveUsed ; "I have used"
                mov     bx, 44h ; 'D'
                mov     cl, 4Ch ; 'L'
                mov     ah, 1
                call    Render_String_At_Position
                mov     bl, selected_item_index
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     si, item_use_text_table[bx]
                mov     bx, 48h ; 'H'
                mov     cl, 56h ; 'V'
                mov     ah, 1
                jmp     Render_String_At_Position
Render_Item_Usage_Text        endp


; =============== S U B R O U T I N E =======================================


; Input: screen_backed_up_flag = check if already backed up
; Output: Captures screen rectangle to seg3, sets flag
Capture_Screen_Backup        proc near
                test    screen_backed_up_flag, 0FFh
                jz      short loc_A617
                retn
; ---------------------------------------------------------------------------

loc_A617:
                mov     screen_backed_up_flag, 0FFh
                mov     ax, 643h
                xor     di, di
                mov     cx, 1C24h
                jmp     word ptr cs:2026h ; Capture_Screen_Rect_to_seg3_proc
Capture_Screen_Backup        endp


; =============== S U B R O U T I N E =======================================


; Input: screen_backed_up_flag = check if backup exists
; Output: Restores screen from seg3 backup, clears flag
Restore_Screen_From_Backup        proc near
                test    screen_backed_up_flag, 0FFh
                jnz     short loc_A631
                retn
; ---------------------------------------------------------------------------

loc_A631:
                mov     screen_backed_up_flag, 0
                mov     ax, 643h
                xor     di, di
                mov     cx, 1C24h
                jmp     word ptr cs:2028h ; Put_Image_proc
Restore_Screen_From_Backup        endp


; =============== S U B R O U T I N E =======================================


; Output: Copies active magic items to active_items_buffer, sets active_item_count
Collect_Active_Items        proc near
                push    cs
                pop     es
                mov     si, offset magic_items
                mov     di, offset active_items_buffer
                xor     al, al
                stosb
                xor     cl, cl
                mov     ch, 5

loc_A652:
                lodsb
                or      al, al
                jz      short loc_A65A
                stosb
                inc     cl

loc_A65A:
                dec     ch
                jnz     short loc_A652
                or      cl, cl
                jz      short loc_A664
                inc     cl

loc_A664:
                mov     active_item_count, cl
                retn
Collect_Active_Items        endp


; =============== S U B R O U T I N E =======================================


; Input: active_item_count = number of active items, active_items_buffer
; Output: Renders item sprites in USE panel, or "NOTHING" / "NO USE"
Render_Items_Panel        proc near
                test    active_item_count, 0FFh
                jz      short loc_A6C4
                mov     cl, active_item_count
                xor     ch, ch
                mov     bx, 0E83h
                mov     si, offset active_items_buffer

loc_A67C:
                push    cx
                lodsb
                push    si
                push    bx
                call    word ptr cs:2036h ; Render_Magic_Potion_Item_Sprite_16x16_proc
                pop     bx
                pop     si
                add     bx, 500h
                pop     cx
                loop    loc_A67C
                mov     selected_item_index, 0
                mov     current_item_for_use, 0
                test    inventory_mode, 0FFh
                jz      short loc_A6A0
                retn
; ---------------------------------------------------------------------------

loc_A6A0:
                mov     bx, 0E81h
                mov     al, 5
                call    word ptr cs:202Eh ; Draw_Status_Frame_proc
                mov     bx, 1570h
                mov     cx, 1811h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     si, offset aNoUse ; "NO USE"
                mov     bx, 54h ; 'T'
                mov     cl, 71h ; 'q'
                mov     ah, 1
                jmp     Render_String_At_Position
; ---------------------------------------------------------------------------

loc_A6C4:
                mov     bx, 54h ; 'T'
                mov     cl, 71h ; 'q'
                mov     si, offset aNothing ; "NOTHING"
                mov     ah, 1
                jmp     Render_String_At_Position
Render_Items_Panel        endp


; =============== S U B R O U T I N E =======================================


; Input: active_wearable_count, wearables buffer
; Output: Renders wearable sprites in WEAR panel
Render_Wearables_Panel        proc near

                test    active_wearable_count, 0FFh
                jz      short loc_A745
                mov     cl, active_wearable_count
                xor     ch, ch
                mov     bx, 0E55h
                mov     si, offset wearables

loc_A6E4:
                push    cx
                lodsb
                push    si
                push    bx
                call    word ptr cs:2034h ; Render_Wearable_Item_Sprite_16x16_proc
                pop     bx
                pop     si
                add     bx, 500h
                pop     cx
                loop    loc_A6E4
Render_Wearables_Panel        endp


; =============== S U B R O U T I N E =======================================


; Input: current_accessory = selected accessory
; Output: Draws status frame and name for selected wearable
Render_Selected_Accessory        proc near
                push    cs
                pop     es
                mov     di, offset wearables
                mov     al, ds:current_accessory
                mov     cx, 6
                repne scasb
                neg     cx
                add     cx, 5
                mov     selected_wearable_index, cl
                mov     ch, cl
                xor     cl, cl
                mov     bx, cx
                add     cx, cx
                add     cx, cx
                add     cx, bx
                add     cx, 0E53h
                mov     bx, cx
                mov     al, 5
                call    word ptr cs:202Eh ; Draw_Status_Frame_proc
                mov     bl, ds:current_accessory
                xor     bh, bh
                add     bx, bx
                mov     si, wearable_names_table[bx]
                mov     bx, 5Ch ; '\'
                mov     cl, 43h ; 'C'
                mov     ah, 1
                call    Render_String_At_Position
                mov     bx, 5Ch ; '\'
                mov     cl, 4Bh ; 'K'
                mov     ah, 1
                jmp     Render_String_At_Position
Render_Selected_Accessory        endp

; ---------------------------------------------------------------------------
loc_A745:
                mov     bx, 5Ch ; '\'
                mov     cl, 43h ; 'C'
                mov     si, offset aNothing ; "NOTHING"
                mov     ah, 1
                jmp     Render_String_At_Position

; =============== S U B R O U T I N E =======================================


; Output: Renders sword, shield, keys, crests and their stats on equipment panel
Render_Equipment_Panel        proc near
                test    byte ptr ds:sword_type, 0FFh
                jz      short loc_A789
                mov     bx, 174Dh
                mov     al, ds:sword_type
                call    word ptr cs:201Ch ; Render_Sword_Item_Sprite_20x18_proc
                mov     bl, ds:sword_type
                xor     bh, bh
                dec     bl
                add     bx, bx
                mov     si, sword_names_table[bx] ; "Training"
                mov     bx, 344Eh
                xor     cl, cl
                call    word ptr cs:2038h ; Render_C_String_proc
                mov     bx, 3456h
                xor     cl, cl
                call    word ptr cs:2038h ; Render_C_String_proc
                call    Render_Enchantment_Count

loc_A789:                               ; shield_type
                test    byte ptr ds:shield_type, 0FFh
                jz      short loc_A7C0
                mov     bx, 2E61h
                mov     al, ds:shield_type
                call    word ptr cs:2020h ; Render_Shield_Item_Sprite_16x16_proc
                mov     bl, ds:shield_type
                xor     bh, bh
                dec     bl
                add     bx, bx
                mov     si, shield_names_table[bx] ; "Clay"
                mov     bx, 3461h
                xor     cl, cl
                call    word ptr cs:2038h ; Render_C_String_proc
                mov     bx, 3469h
                xor     cl, cl
                call    word ptr cs:2038h ; Render_C_String_proc
                call    Render_Shield_HP_Detail

loc_A7C0:                               ;
                test    byte ptr ds:keys_amount, 0FFh
                jz      short loc_A7EF
                mov     bx, 2E75h
                xor     al, al
                call    word ptr cs:203Ah ; Render_Key_Item_Sprite_16x16_proc
                mov     bx, 0C8h
                mov     cl, 7Eh ; '~'
                mov     al, 5Eh ; '^'
                mov     ah, 1
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                mov     al, ds:keys_amount
                xor     ah, ah
                mov     cx, 1
                mov     bl, 1
                mov     dx, 347Eh
                call    Render_Decimal_Number

loc_A7EF:                               ;
                test    byte ptr ds:lion_head_keys, 0FFh
                jz      short loc_A81E
                mov     bx, 3A75h
                mov     al, 1
                call    word ptr cs:203Ah ; Render_Key_Item_Sprite_16x16_proc
                mov     bx, 0F8h
                mov     cl, 7Eh ; '~'
                mov     al, 5Eh ; '^'
                mov     ah, 1
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                mov     al, ds:lion_head_keys
                xor     ah, ah
                mov     cx, 1
                mov     bl, 1
                mov     dx, 407Eh
                call    Render_Decimal_Number

loc_A81E:                               ;
                mov     si, offset elf_crest
                mov     bx, 3089h
                mov     cx, 3

loc_A827:
                push    cx
                lodsb                   ; elf_crest, crest_of_glory, hero_crest
                or      al, al
                jz      short loc_A840
                mov     al, cl
                neg     al
                add     al, 3
                push    bx
                push    si
                call    word ptr cs:203Ch ; Render_Crest_Item_Sprite_16x16_proc
                pop     si
                pop     bx
                add     bx, 600h

loc_A840:
                pop     cx
                loop    loc_A827
                retn
Render_Equipment_Panel        endp


; =============== S U B R O U T I N E =======================================


; Output: Renders shield HP value in parentheses
Render_Shield_HP_Detail        proc near
                mov     ax, ds:shield_max_HP
                mov     dx, 3469h
                mov     cx, 3
                mov     bl, 4
                call    Render_Decimal_Number
                mov     bx, 0CAh
                mov     cl, 69h ; 'i'
                mov     al, 28h ; '('
                mov     ah, 4
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                mov     bx, 0E0h
                mov     cl, 69h ; 'i'
                mov     al, 29h ; ')'
                mov     ah, 4
                jmp     word ptr cs:2022h ; Render_Font_Glyph_proc
Render_Shield_HP_Detail        endp


; =============== S U B R O U T I N E =======================================


; Input: byte_E4 = enchantment count
; Output: Renders enchantment count in parentheses if non-zero
Render_Enchantment_Count        proc near
                test    byte ptr ds:byte_E4, 0FFh
                jnz     short loc_A876
                retn
; ---------------------------------------------------------------------------

loc_A876:
                mov     bx, 3257h
                mov     cx, 408h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                mov     bx, 0CAh
                mov     cl, 57h ; 'W'
                mov     al, 28h ; '('
                mov     ah, 1
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                mov     al, ds:byte_E4
                xor     ah, ah
                mov     dx, 3457h
                mov     bl, 1
                mov     cx, 1
                call    Render_Decimal_Number
                mov     bx, 0D4h
                mov     cl, 57h ; 'W'
                mov     al, 29h ; ')'
                mov     ah, 1
                jmp     word ptr cs:2022h ; Render_Font_Glyph_proc
Render_Enchantment_Count        endp


; =============== S U B R O U T I N E =======================================


; Input: active_magic_count, spells_active buffer
; Output: Renders magic spell sprites and names in SELECT-MAGIC panel
Render_Magics_Panel        proc near
                test    active_magic_count, 0FFh
                jz      short loc_A91C
                mov     cl, active_magic_count
                xor     ch, ch
                mov     bx, 0E1Ch
                mov     si, offset spells_active

loc_A8C2:
                push    cx
                lodsb
                push    si
                push    bx
                call    word ptr cs:201Eh ; Render_Magic_Spell_Item_Sprite_16x16_proc
                pop     bx
                pop     si
                add     bx, 800h
                pop     cx
                loop    loc_A8C2
                call    Render_Magic_Counts_Panel
                push    cs
                pop     es
                mov     di, offset spells_active
                mov     al, ds:current_magic_spell
                mov     cx, 7
                repne scasb
                neg     cx
                add     cx, 6
                mov     selected_magic_index, cl
                mov     ch, cl
                xor     cl, cl
                add     cx, cx
                add     cx, cx
                add     cx, cx
                add     cx, 0E1Ah
                mov     bx, cx
                mov     al, 5
                call    word ptr cs:202Eh ; Draw_Status_Frame_proc
                mov     bl, ds:current_magic_spell
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     si, magic_names_table[bx]
                mov     bx, 9Eh
                mov     cl, 12h
                mov     ah, 1
                jmp     Render_String_At_Position
; ---------------------------------------------------------------------------

loc_A91C:
                mov     bx, 9Eh
                mov     cl, 12h
                mov     si, offset aNothing ; "NOTHING"
                mov     ah, 1
                jmp     Render_String_At_Position
Render_Magics_Panel        endp


; =============== S U B R O U T I N E =======================================


; Input: active_magic_count, spells_active
; Output: Renders individual magic count boxes with current/max values
Render_Magic_Counts_Panel        proc near
                mov     dx, 0E2Eh
                mov     si, offset spells_active
                mov     cl, active_magic_count
                xor     ch, ch

loc_A935:
                push    cx
                lodsb
                push    si
                push    dx
                dec     al
                mov     bl, al
                xor     bh, bh
                mov     al, [bx+spells_espada]
                mov     ah, [bx+espada_count]
                push    ax
                push    dx
                push    ax
                push    dx
                mov     bx, dx
                mov     cx, 508h
                xor     al, al
                call    word ptr cs:2000h ; Draw_Bordered_Rectangle_proc
                pop     dx
                pop     ax
                xor     ah, ah
                mov     bl, 1
                mov     cx, 3
                call    Render_Decimal_Number
                pop     dx
                add     dx, 9
                push    dx
                sub     dx, 200h
                mov     cl, dl
                mov     bl, dh
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                inc     bx
                inc     bx
                mov     al, 28h ; '('
                mov     ah, 4
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                pop     dx
                pop     ax
                mov     al, ah
                push    dx
                xor     ah, ah
                mov     bl, 4
                mov     cx, 3
                call    Render_Decimal_Number
                pop     dx
                add     dx, 400h
                mov     cl, dl
                mov     bl, dh
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                dec     bx
                mov     al, 29h ; ')'
                mov     ah, 4
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                pop     dx
                add     dx, 800h
                pop     si
                pop     cx
                loop    loc_A935
                retn
Render_Magic_Counts_Panel        endp


; =============== S U B R O U T I N E =======================================


; Input: al = value, cx = digit count, bl = stride, dx = position
; Output: Renders decimal number on screen
Render_Decimal_Number        proc near
                push    bx
                push    dx
                push    cx
                xor     dl, dl
                mov     di, offset decimal_digits_buffer
                call    word ptr cs:2032h ; Convert_32bit_To_Decimal_Digits_proc
                pop     cx
                mov     di, offset decimal_digits_buffer
                mov     al, 7
                sub     al, cl
                xor     ah, ah
                add     di, ax
                pop     ax
                pop     bx
                xor     bh, bh
                jmp     word ptr cs:2030h ; Render_Decimal_Digits_proc
Render_Decimal_Number        endp


; =============== S U B R O U T I N E =======================================


; Input: current_tab = highlights active menu label
; Output: Renders SELECT-MAGIC, WEAR, USE, INVENTORY labels
Render_Menu_Labels        proc near
                mov     si, offset select_magic
                mov     cx, 4

loc_A9DB:
                push    cx
                mov     dh, cl
                lodsw
                mov     bx, ax
                lodsb
                mov     cl, al
                mov     dl, current_tab
                neg     dh
                add     dh, 4
                mov     ah, 3
                cmp     dl, dh
                jnz     short loc_A9F5
                mov     ah, 2

loc_A9F5:
                call    Render_String_At_Position
                pop     cx
                loop    loc_A9DB
                retn
Render_Menu_Labels        endp

; ---------------------------------------------------------------------------
select_magic    db  34h ; 4
                db    0
                db  12h
aSelectMagic    db 'SELECT-MAGIC:',0
wear            db  34h ; 4
                db    0
                db  43h ; C
aWear           db 'WEAR:',0
use             db  34h ; 4
                db    0
                db  71h ; q
aUse            db 'USE:',0
inventory       db 0B8h
                db    0
                db  43h ; C
aInventory      db 'INVENTORY',0

; =============== S U B R O U T I N E =======================================


; Input: si = string pointer, bx = column, cl = row, ah = render mode
; Output: Renders null-terminated string character by character, advances bx
Render_String_At_Position        proc near
                lodsb
                or      al, al
                jnz     short loc_AA31
                retn
; ---------------------------------------------------------------------------

loc_AA31:
                push    si
                cmp     ah, 1
                jz      short loc_AA47
                push    bx
                push    cx
                push    ax
                inc     bx
                inc     cl
                mov     ah, 5
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                pop     ax
                pop     cx
                pop     bx

loc_AA47:
                push    bx
                push    cx
                push    ax
                call    word ptr cs:2022h ; Render_Font_Glyph_proc
                pop     ax
                pop     cx
                pop     bx
                pop     si
                add     bx, 8
                jmp     short Render_String_At_Position
Render_String_At_Position        endp


; =============== S U B R O U T I N E =======================================


; Output: Calls system menus, returns CF set if Enter pressed (exit pending)
Check_Menu_Exit        proc near
                call    word ptr cs:110h ; Confirm_Exit_Dialog_proc
                call    word ptr cs:112h ; Handle_Pause_State_proc
                call    word ptr cs:114h ; Handle_Speed_Change_proc
                call    word ptr cs:116h ; Joystick_Calibration_proc
                call    word ptr cs:118h ; Joystick_Deactivator_proc
                test    exit_pending_flag_inv, 0FFh
                jz      short Check_Enter_Pressed
                call    Check_Enter_Pressed
                cmc
                jb      short loc_AA7F
                retn
; ---------------------------------------------------------------------------

loc_AA7F:
                clc
                mov     exit_pending_flag_inv, 0
                retn
Check_Menu_Exit        endp


; =============== S U B R O U T I N E =======================================


; Output: CF = Enter key state (STC if pressed)
Check_Enter_Pressed proc near
                test    word ptr ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1
                stc
                jz      short loc_AA90
                retn
; ---------------------------------------------------------------------------

loc_AA90:
                clc
                retn
Check_Enter_Pressed endp

; ---------------------------------------------------------------------------
aNothing        db 'NOTHING',0
aNoUse          db 'NO USE',0
                db    0
aLevel          db 'LEVEL',0
aExp            db 'EXP',0
aIHaveUsed      db 'I have used',0
magic_names_table        dw offset aEspada       ; "Espada"
                dw offset aSaeta        ; "Saeta"
                dw offset aFuego        ; "Fuego"
                dw offset aLanzar       ; "Lanzar"
                dw offset aRascar       ; "Rascar"
                dw offset aAgua         ; "Agua"
                dw offset aGuerra       ; "Guerra"
aEspada         db 'Espada',0
aSaeta          db 'Saeta',0
aFuego          db 'Fuego',0
aLanzar         db 'Lanzar',0
aRascar         db 'Rascar',0
aAgua           db 'Agua',0
aGuerra         db 'Guerra',0
wearable_names_table        dw offset aNoUse        ; "NO USE"
                dw offset aFeruza       ; "Feruza"
                dw offset aPirika       ; "Pirika"
                dw offset aSilkarn      ; "Silkarn"
                dw offset aRuzeria      ; "Ruzeria"
                dw offset aAsbestos     ; "Asbestos"
aFeruza         db 'Feruza',0
aShoes          db '      shoes',0
aPirika         db 'Pirika',0
aShoes_0        db '      shoes',0
aSilkarn        db 'Silkarn',0
aShoes_1        db '      shoes',0
aRuzeria        db 'Ruzeria',0
aShoes_2        db '      shoes',0
aAsbestos       db 'Asbestos',0
aCape           db '       cape',0
item_use_text_table dw offset aAKenKoPotion
                dw offset aAJuuEnFruit
                dw offset aAElixirOfKashi
                dw offset aAChikaraPowder
                dw offset aAMagiaStone
                dw offset aAHolyWaterOfAc
                dw offset aASabreOil
                dw offset aAKiokuFeather
aAKenKoPotion   db '       a Ken\ko Potion.',0
aAJuuEnFruit    db '        a Juu-en Fruit.',0
aAElixirOfKashi db '     a Elixir of Kashi.',0
aAChikaraPowder db '      a Chikara Powder.',0
aAMagiaStone    db '         a Magia Stone.',0
aAHolyWaterOfAc db ' a Holy Water of Acero.',0
aASabreOil      db '           a Sabre Oil.',0
aAKiokuFeather  db '       a Kioku Feather.',0
item_names_table        dw offset aNoUse
                dw offset aKenKo        ; "Ken\\ko"
                dw offset aJuuEn        ; "Juu-en "
                dw offset aElixir       ; "Elixir"
                dw offset aChikara      ; "Chikara"
                dw offset aMagiaStone   ; "Magia Stone"
                dw offset aHolyWater    ; "Holy Water"
                dw offset aSabreOil     ; "Sabre Oil"
                dw offset aKioku        ; "Kioku"
aKenKo          db 'Ken\ko',0
aPotion         db '      Potion',0
aJuuEn          db 'Juu-en ',0
aFruit          db '       Fruit',0
aElixir         db 'Elixir',0
aOfKashi        db '    of Kashi',0
aChikara        db 'Chikara',0
aPowder         db '      Powder',0
aMagiaStone     db 'Magia Stone',0
                db    0
aHolyWater      db 'Holy Water',0
aOfAcero        db '    of Acero',0
aSabreOil       db 'Sabre Oil',0
                db    0
aKioku          db 'Kioku',0
aFeather        db '     feather',0
sword_names_table        dw offset aTraining     ; "Training"
                dw offset aWiseManS     ; "Wise man\\s"
                dw offset aSpirit       ; "Spirit"
                dw offset aKnightS      ; "Knight\\s"
                dw offset aIllumination ; "Illumination"
                dw offset aEnchantment  ; "Enchantment"
aTraining       db 'Training',0
aSword          db '     Sword',0
aWiseManS       db 'Wise man\s',0
aSword_0        db '      Sword',0
aSpirit         db 'Spirit',0
aSword_1        db '    Sword',0
aKnightS        db 'Knight\s',0
aSword_2        db '    Sword',0
aIllumination   db 'Illumination',0
aSword_3        db '       Sword',0
aEnchantment    db 'Enchantment',0
aSword_4        db '       Sword',0
shield_names_table        dw offset aClay         ; "Clay"
                dw offset aWiseManS_0   ; "Wise Man\\s"
                dw offset aStone        ; "Stone"
                dw offset aHonor        ; "Honor"
                dw offset aLight        ; "Light"
                dw offset aTitanium     ; "Titanium"
aClay           db 'Clay',0
aShield         db '     Shield',0
aWiseManS_0     db 'Wise Man\s',0
aShield_0       db '      Shield',0
aStone          db 'Stone',0
aShield_1       db '     Shield',0
aHonor          db 'Honor',0
aShield_2       db '     Shield',0
aLight          db 'Light',0
aShield_3       db '     Shield',0
aTitanium       db 'Titanium',0
aShield_4       db '      Shield',0
menu_label_positions       db 0Eh, 0Ch, 33h, 38h, 3Fh, 0Ch, 30h, 22h, 6Dh, 0Ch, 30h
                db 22h, 3Fh, 2Dh, 5Eh, 17h
inventory_mode       db 0
current_tab       db 0
active_magic_count       db 0
selected_magic_index       db 0
active_wearable_count       db 0
selected_wearable_index       db 0
active_item_count       db 0
selected_item_index       db 0
current_item_for_use       db 0
exit_pending_flag_inv       db 0
screen_backed_up_flag       db 0
spells_active   db 7 dup(0)
wearables       db 0, 0, 0, 0, 0, 0
active_items_buffer       db 0, 0, 0, 0, 0, 0
decimal_digits_buffer       db 0, 0, 0, 0, 0, 0, 0

select          ends

                end     start
