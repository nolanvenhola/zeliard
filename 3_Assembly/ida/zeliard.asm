include common.inc

                .286
                .model small

; ===========================================================================

; Segment type: Pure code
seg000          segment byte public 'CODE'
                assume cs:seg000, ds:seg000
                assume ss:seg001

; =============== S U B R O U T I N E =======================================


                public start
start           proc near
                cld
                mov     ah, 30h
                int     21h             ; DOS - GET DOS VERSION
                                        ; Return: AL = major version number (00h for DOS 1.x)
                cmp     al, 2
                jnb     short loc_1000B
                int     20h             ; DOS - PROGRAM TERMINATION
                                        ; returns to DOS--identical to INT 21/AH=00h
; ---------------------------------------------------------------------------

loc_1000B:
                mov     ax, seg seg000
                mov     ds, ax
                call    Parse_Command_Line
                mov     dx, offset g_szResourceCfg ; "RESOURCE.CFG"
                mov     ax, 3D00h
                int     21h             ; DOS - 2+ - OPEN DISK FILE WITH HANDLE
                                        ; DS:DX -> ASCIZ filename
                                        ; AL = access mode
                                        ; 0 - read
                jnb     short loc_10025
                call    Print_File_Error
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
                                        ; AL = exit code
; ---------------------------------------------------------------------------

loc_10025:
                mov     bx, ax              ; file handle
                call    Parse_Config_Token
                jnb     short loc_1002F
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

loc_1002F:
                call    Parse_Video_drv
                call    Parse_Config_Token
                jnb     short loc_1003A
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

loc_1003A:
                call    Parse_Music_Driver
                call    Parse_Config_Token
                jnb     short loc_10045
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

loc_10045:
                call    Parse_Sound_FX_Driver
                call    Parse_Config_Token
                jnb     short loc_10050
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

loc_10050:
                call    Parse_joystick_yesno
                mov     ah, 3Eh
                int     21h             ; DOS - 2+ - CLOSE A FILE WITH HANDLE
                                        ; BX = file handle
                mov     bx, 4000h
                mov     ah, 48h
                int     21h             ; DOS - 2+ - ALLOCATE MEMORY
                                        ; BX = number of 16-byte paragraphs desired
                                        ; Return: AX = segment address of allocated memory
                jnb     short alloc_success
                cmp     ax, 8
                jnz     short loc_10071
                mov     dx, offset g_szNotEnoughMemory ; "Not enough memory to run 'ZELIARD'.\r\n"...
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
                                        ; AL = exit code
; ---------------------------------------------------------------------------

loc_10071:
                mov     dx, offset g_szMemoryError ; "Memory error !!!\r\n$"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
                                        ; AL = exit code
; ---------------------------------------------------------------------------

alloc_success:
                mov     game_cseg, ax   ; 40000h bytes allocated, starting game_cseg
                call    flush_keyb_buf
                mov     dx, offset g_szTitleString ; "The Fantasy Action Game ZELIARD Version"...
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                test    cs:music_is_mt32_flag, 0FFh
                jz      short init_done_or_not_needed
                mov     cs:keep_sp, sp
                mov     cs:keep_ss, ss
                mov     di, offset g_szMtinitCom-2
                mov     dx, offset g_szMtinitCom ; "MTINIT.COM"
                mov     bx, offset param_block
                mov     ax, 4B00h
                int     21h             ; DOS - 2+ - LOAD OR EXECUTE (EXEC)
                                        ; DS:DX -> ASCIZ filename
                                        ; ES:BX -> parameter block
                                        ; AL = subfunc: load & execute program
                cli
                mov     sp, cs:keep_sp
                mov     ss, cs:keep_ss
                sti
                jnb     short init_done_or_not_needed
                call    Print_File_Error
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
                                        ; AL = exit code
; ---------------------------------------------------------------------------

init_done_or_not_needed:
                mov     ax, 3508h
                int     21h             ; DOS - 2+ - GET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; Return: ES:BX = value of interrupt vector
                mov     word ptr int8_old, bx
                mov     word ptr int8_old+2, es
                mov     ax, 3509h
                int     21h             ; DOS - 2+ - GET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; Return: ES:BX = value of interrupt vector
                mov     word ptr int9_old, bx
                mov     word ptr int9_old+2, es
                mov     ax, 3560h
                int     21h             ; DOS - 2+ - GET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; Return: ES:BX = value of interrupt vector
                mov     word ptr int60_old, bx
                mov     word ptr int60_old+2, es
                mov     ax, 3561h
                int     21h             ; DOS - 2+ - GET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; Return: ES:BX = value of interrupt vector
                mov     word ptr int61_old, bx
                mov     word ptr int61_old+2, es
                mov     es, cs:game_cseg
                mov     word ptr es:fn_exit_far_ptr, offset Handle_Game_Exit ; handle_game_exit_off
                mov     word ptr es:fn_exit_far_ptr+2, cs                    ; handle_game_exit_seg
                lds     dx, cs:int8_old
                mov     es:fn_timer_chain_ptr, dx            ; int8_old_off
                mov     word ptr es:fn_timer_chain_ptr+2, ds ; int8_old_seg
                lds     dx, cs:int9_old
                mov     es:fn_kbd_chain_ptr, dx              ; int9_old_off
                mov     word ptr es:fn_kbd_chain_ptr+2, ds   ; int9_old_seg
                mov     byte ptr es:____Alt_Space, 0
                mov     byte ptr es:____right_left_down_up, 0
                mov     word ptr es:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 0
                mov     byte ptr es:spacebar_latch, 0
                mov     byte ptr es:altkey_latch, 0
                mov     word ptr es:fn_per_tick_user_ptr, 0
                mov     byte ptr es:byte_FF26, 0FFh
                mov     byte ptr es:exit_pending_flag, 0FFh
                mov     byte ptr es:sound_fx_toggle_by_f2, 0
                mov     byte ptr es:music_channel_param, 0
                mov     byte ptr es:byte_FF0B, 0
                mov     byte ptr es:heartbeat_volume, 0
                mov     byte ptr es:soundFX_request, 0
                mov     byte ptr es:speed_const, 5
                mov     byte ptr es:is_boss_cavern, 0
                mov     byte ptr es:squat_flag, 0
                mov     byte ptr es:on_rope_flags, 0
                mov     byte ptr es:hero_hidden_flag, 0
                mov     byte ptr es:sword_swing_flag, 0
                mov     byte ptr es:spell_active_flag, 0
                mov     byte ptr es:joystick_calibrated_flag, 0
                mov     byte ptr es:keyboard_alt_mode_flag, 0
                mov     byte ptr es:shield_anim_active, 0
                mov     byte ptr es:slope_direction, 0
                mov     byte ptr es:disk_swap_suppressed, 0
                mov     al, cs:use_joystick_flag
                mov     es:joystick_enabled_flag, al
                mov     al, cs:music_is_mt32_flag
                mov     es:mt32_enabled, al
                mov     di, save_name
                xor     al, al
                mov     cx, 8
                rep stosb
                push    cs
                pop     ds
                mov     si, offset user_savegame_to_restore
                mov     di, save_name
                mov     cx, 8

loc_101E0:
                lodsb
                cmp     al, '.'
                jz      short loc_101F2
                cmp     al, 'a'
                jb      short loc_101EF
                cmp     al, '{'
                jnb     short loc_101EF
                and     al, 5Fh                ; uppercase

loc_101EF:
                stosb
                loop    loc_101E0

loc_101F2:
                mov     al, cs:video_mode
                mov     es:video_drv_id, al
                mov     ax, cs:game_cseg
                add     ax, 1000h
                mov     es:seg1, ax
                push    cs
                pop     ds
                mov     es, cs:game_cseg
                mov     di, offset vfs_stdply_bin
                test    restore_on_startup_flag, 0FFh
                jz      short loc_10219
                mov     di, offset vfs_savename

loc_10219:
                call    Load_Resource_File
                mov     es, cs:game_cseg
                mov     di, offset vfs_stick_bin
                call    Load_Resource_File
                mov     es, cs:game_cseg
                mov     di, offset vfs_game_bin
                call    Load_Resource_File
                mov     es, cs:game_cseg
                xor     bx, bx
                mov     bl, video_mode
                add     bx, bx
                mov     di, video_drivers_vfs[bx]
                call    Load_Resource_File
                mov     ax, cs:game_cseg
                add     ax, 1000h-10h        ; game_cseg:0FF00h..0FFFFh is mapped to music_seg:0..0FFh
                mov     es, ax
                mov     di, offset vfs_music_drv
                call    Load_Resource_File
                mov     ax, cs:game_cseg
                add     ax, 1000h-10h        ; game_cseg:0FF00h..0FFFFh is mapped to music_seg:0..0FFh
                mov     es, ax
                mov     di, offset vfs_snd_fx_drv
                call    Load_Resource_File
                cli
                push    cs
                pop     ds
                mov     dx, offset int23_new
                mov     ax, 2523h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     ds, cs:game_cseg
                mov     dx, int8_new_proc ; game_cseg:int8_new
                mov     ax, 2508h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     dx, int9_new_proc ; game_cseg:int9_new
                mov     ax, 2509h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     dx, int24_new_proc        ; game_cseg:int24_new
                mov     ax, 2524h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     dx, int61_new_proc
                mov     ax, 2561h       ; game_cseg:int61_new
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     ax, cs:game_cseg
                mov     es, ax
                add     ax, 1000h-10h
                mov     ds, ax           ; seg1
                mov     word ptr es:fn_per_tick_callback, 100h
                mov     word ptr es:fn_per_tick_callback+2, ds
                mov     word ptr es:fn_per_tick_callback2, 1100h
                mov     word ptr es:fn_per_tick_callback2+2, ds
                mov     dx, 103h         ; seg1:music_drv entry for int60
                mov     ax, 2560h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt

                mov     al, 36h         ; 7-6  Select counter  00 = Timer 0
                                        ; 5-4  Read/Write operation  11 = LSB then MSB
                                        ; 3-1  Mode  011 = Mode 3 (Square Wave Generator)
                                        ; 0  Counting format  0 = Binary (not BCD)
                out     43h, al         ; Write Control Word to PIT Command Register
                mov     al, 0B1h
                out     40h, al         ; Write LSB of new count
                mov     al, 13h
                out     40h, al         ; Write MSB of new count
; The 16-bit reload value loaded into Timer 0 is 0x13B1 = 5041 decimal.
; Timer 0 now runs in square-wave mode (output toggles high/low every 5041 input clocks).
; The PIT input clock on a PC/AT is 1,193,182 Hz.
; New output frequency = 1,193,182 / 5041 ≈ 236.70 Hz.
; This means IRQ0 will now fire ≈236.7 times per second instead of the normal ~18.2 Hz.

                sti
                call    Set_Video_Mode
                mov     al, cs:restore_on_startup_flag
                cbw
                jmp     dword ptr cs:game_bin_off
start           endp


; =============== S U B R O U T I N E =======================================


Handle_Game_Exit proc near

                push    ax
                mov     ax, 2
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                mov     ax, 2
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                call    flush_keyb_buf
                mov     ax, 1
                int     60h             ; adlib fn_1
                pop     ax
                or      ax, ax
                jnz     short loc_102FC
                push    cs
                pop     ds
                mov     dx, offset g_szThankYou ; "Thank you for playing.\r\n$"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                jmp     short quit_game
; ---------------------------------------------------------------------------

loc_102FC:
                cmp     ax, 0FFFFh
                jnz     short loc_1030C
                push    cs
                pop     ds
                mov     dx, offset g_szUserFileNothing ; "USER file nothing.$"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                jmp     short quit_game
; ---------------------------------------------------------------------------

loc_1030C:
                push    ds
                push    dx
                mov     dx, offset g_szFileNotFound ; "File not found.$"
                cmp     ax, 2
                jz      short loc_10319
                mov     dx, offset g_szDiskReadError ; "DISK read Error!!$"

loc_10319:
                push    cs
                pop     ds
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                mov     dl, ' '
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                mov     dl, ':'
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                mov     dl, ' '
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                pop     di
                pop     ds

loc_10333:
                mov     dl, [di]
                or      dl, dl
                jz      short quit_game
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                inc     di
                jmp     short loc_10333
Handle_Game_Exit endp

quit_game:
                cli
                lds     dx, cs:int8_old
                mov     ax, 2508h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                lds     dx, cs:int9_old
                mov     ax, 2509h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                lds     dx, cs:int60_old
                mov     ax, 2560h
                int     21h             ; DOS - SET INTERRUPT VECTOR
                                        ; AL = interrupt number
                                        ; DS:DX = new vector to be used for specified interrupt
                mov     al, 36h ;
                out     43h, al         ; Timer 8253-5 (AT: 8254.2).
                xor     al, al
                out     40h, al         ; Divider 10000h => restore timer to normal 18.2 Hz
                out     40h, al
                sti
                mov     ax, seg seg000
                mov     ds, ax
                mov     es, game_cseg
                mov     ah, 49h
                int     21h             ; DOS - 2+ - FREE MEMORY
                                        ; ES = segment address of area to be freed
                jnb     short loc_10380
                mov     dx, offset g_szMemoryError ; "Memory error !!!\r\n$"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"

loc_10380:
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
                                        ; AL = exit code

; =============== S U B R O U T I N E =======================================


flush_keyb_buf  proc near
                push    dx

loc_10386:
                mov     dl, 0FFh
                mov     ah, 6
                int     21h             ; DOS - DIRECT CONSOLE I/O CHARACTER OUTPUT
                                        ; DL = character <> FFh
                                        ;  Return: ZF set = no character
                                        ;   ZF clear = character recieved, AL = character
                jnz     short loc_10386
                pop     dx
                retn
flush_keyb_buf  endp


; =============== S U B R O U T I N E =======================================


Parse_Config_Token proc near
                push    cs
                pop     ds
                mov     dx, offset file_buf
                mov     token_length, 0

skip_special_chars:
                mov     cx, 1
                mov     ah, 3Fh
                int     21h             ; DOS - 2+ - READ FROM FILE WITH HANDLE
                                        ; BX = file handle, CX = number of bytes to read
                                        ; DS:DX -> buffer
                or      ax, ax
                stc
                jnz     short loc_103A7
                retn                    ; EOF reached
; ---------------------------------------------------------------------------

loc_103A7:
                mov     si, dx
                cmp     byte ptr [si], ' '
                jb      short skip_special_chars

loc_103AE:
                inc     token_length
                or      byte ptr [si], 20h ; ':' not changed, letters -> toLower
                inc     dx

skip_spaces:
                mov     cx, 1
                mov     ah, 3Fh
                int     21h             ; DOS - 2+ - READ FROM FILE WITH HANDLE
                                        ; BX = file handle, CX = number of bytes to read
                                        ; DS:DX -> buffer
                or      ax, ax
                jz      short loc_103CA
                mov     si, dx
                cmp     byte ptr [si], ' '
                je      short skip_spaces
                jnb     short loc_103AE

loc_103CA:
                clc
                retn
Parse_Config_Token endp


; =============== S U B R O U T I N E =======================================


Parse_Video_drv proc near
                push    cs
                pop     es
                call    Find_Colon_In_Token
                dec     cx
                cmp     cx, 3
                je      short mode_strlen_3
                cmp     cx, 4
                je      short mode_strlen_4
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

mode_strlen_4:
                mov     di, offset aCga2 ; "cga2"
                mov     cx, 2

loc_103E5:
                push    cx
                push    si
                push    di
                mov     cx, 4
                repe cmpsb
                pop     di
                pop     si
                pop     cx
                je      short found_mcga_or_cga2
                add     di, 5
                loop    loc_103E5
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

found_mcga_or_cga2:
                add     di, 4
                mov     al, es:[di]
                mov     video_mode, al
                retn
; ---------------------------------------------------------------------------

mode_strlen_3:
                mov     di, offset aCga ; "cga"
                mov     cx, 4

loc_1040A:
                push    cx
                push    si
                push    di
                mov     cx, 3
                repe cmpsb
                pop     di
                pop     si
                pop     cx
                jz      short loc_1041F
                add     di, 4
                loop    loc_1040A
                jmp     print_cfg_err_and_exit
; ---------------------------------------------------------------------------

loc_1041F:
                add     di, 3
                mov     al, es:[di]
                mov     video_mode, al
                retn
Parse_Video_drv endp

; ---------------------------------------------------------------------------
aCga2           db 'cga2', 2
aMcga           db 'mcga', 4
aCga            db 'cga', 1
aEga            db 'ega', 0
aHgc            db 'hgc', 3
aTga            db 'tga', 5

; =============== S U B R O U T I N E =======================================


Parse_Music_Driver proc near
                mov     cs:music_is_mt32_flag, 0
                push    cs
                pop     es
                call    Find_Colon_In_Token
                dec     cx
                cmp     cx, 0Fh
                jb      short loc_10457
                mov     cx, 0Fh

loc_10457:
                mov     di, offset g_szMuzicDrv
                rep movsb
                xor     al, al
                stosb
                mov     di, offset g_szMuzicDrv
                mov     si, offset aMscmtDrv ; "mscmt.drv"
                mov     cx, 9
                repe cmpsb
                jz      short loc_1046D
                retn
; ---------------------------------------------------------------------------

loc_1046D:
                mov     music_is_mt32_flag, 0FFh
                retn
Parse_Music_Driver endp

; ---------------------------------------------------------------------------
aMscmtDrv       db 'mscmt.drv'

; =============== S U B R O U T I N E =======================================


Parse_Sound_FX_Driver proc near
                push    cs
                pop     es
                call    Find_Colon_In_Token
                dec     cx
                cmp     cx, 0Fh
                jb      short loc_1048A
                mov     cx, 0Fh

loc_1048A:
                mov     di, offset g_szSoundFxDrv
                rep movsb
                xor     al, al
                stosb
                retn
Parse_Sound_FX_Driver endp


; =============== S U B R O U T I N E =======================================


Parse_joystick_yesno proc near
                push    cs
                pop     es
                call    Find_Colon_In_Token
                dec     cx
                cmp     cx, 2
                jz      short check_no
                cmp     cx, 3
                jnz     short print_cfg_err_and_exit
                mov     di, offset aYes
                mov     cx, 3
                repe cmpsb
                jnz     short print_cfg_err_and_exit
                mov     cs:use_joystick_flag, 0FFh
                retn
; ---------------------------------------------------------------------------

check_no:
                mov     di, offset aNo  ; "no"
                mov     cx, 2
                repe cmpsb
                jnz     short print_cfg_err_and_exit
                mov     cs:use_joystick_flag, 0
                retn
; ---------------------------------------------------------------------------
aYes            db  'yes'
aNo             db  'no'
; ---------------------------------------------------------------------------

print_cfg_err_and_exit:
                mov     ah, 3Eh
                int     21h             ; DOS - 2+ - CLOSE A FILE WITH HANDLE
                                        ; BX = file handle
                mov     dx, offset g_szErrorInResource ; "Error in RESOURCE.CFG\r\n$"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                mov     ax, 4C00h
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)
Parse_joystick_yesno endp                 ; AL = exit code


; =============== S U B R O U T I N E =======================================


Find_Colon_In_Token proc near
                push    cs
                pop     ds
                mov     si, offset file_buf
                xor     cx, cx
                mov     cl, token_length

loc_104E5:
                lodsb
                cmp     al, ':'
                jne     short loc_104EB
                retn
; ---------------------------------------------------------------------------

loc_104EB:
                loop    loc_104E5
                jmp     short print_cfg_err_and_exit
Find_Colon_In_Token endp


; =============== S U B R O U T I N E =======================================

; Reads a file into memory
; [DI]: buffer offset (relative to es)
; DI+2: file name
Load_Resource_File proc near

                push    ds
                push    es
                push    di
                mov     dx, di
                add     dx, 2
                mov     ax, 3D00h
                int     21h             ; DOS - 2+ - OPEN DISK FILE WITH HANDLE
                                        ; DS:DX -> ASCIZ filename
                                        ; AL = access mode
                                        ; 0 - read
                jb      short file_err
                mov     bx, ax          ; file handle
                mov     dx, [di]
                mov     cx, 0FFFFh
                push    es
                pop     ds
                mov     ah, 3Fh
                int     21h             ; DOS - 2+ - READ FROM FILE WITH HANDLE
                                        ; BX = file handle, CX = number of bytes to read
                                        ; DS:DX -> buffer
                jb      short file_err
                mov     ah, 3Eh
                int     21h             ; DOS - 2+ - CLOSE A FILE WITH HANDLE
                                        ; BX = file handle
                jb      short file_err
                pop     di
                pop     es
                pop     ds
                retn
; ---------------------------------------------------------------------------

file_err:
                pop     di
                pop     es
                pop     ds
                call    Print_File_Error
                jmp     quit_game
Load_Resource_File endp


; =============== S U B R O U T I N E =======================================


Print_File_Error proc near
                push    ds
                push    es
                push    di
                push    cs
                pop     ds
                push    ax
                mov     dx, offset g_szFileErrorFrom ; "File Error from $"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                pop     ax
                pop     di
                pop     es
                pop     ds
                push    ax
                add     di, 2

loc_10535:
                mov     dl, [di]
                or      dl, dl
                jz      short loc_10542
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                inc     di
                jmp     short loc_10535
; ---------------------------------------------------------------------------

loc_10542:
                pop     bx
                push    cs
                pop     ds
                mov     dx, offset g_szErrorType ; "     Error Type : $"
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                mov     dx, offset g_szFileNotFound ; "File not found.$"
                cmp     bx, 2
                jz      short loc_10575
                mov     dx, offset g_szDiskReadError ; "DISK read Error!!$"
                cmp     bx, 5
                jz      short loc_10575
                shl     bx, 1
                mov     dl, g_bErrorCodesHi[bx]
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                mov     dl, g_bErrorCodesLo[bx]
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                mov     dl, 'H'
                mov     ah, 2
                int     21h             ; DOS - DISPLAY OUTPUT
                                        ; DL = character to send to standard output
                retn
; ---------------------------------------------------------------------------

loc_10575:
                mov     ah, 9
                int     21h             ; DOS - PRINT STRING
                                        ; DS:DX -> string terminated by "$"
                retn
Print_File_Error endp


; =============== S U B R O U T I N E =======================================


Set_Video_Mode proc near
                mov     bl, cs:video_mode
                xor     bh, bh
                add     bx, bx          ; switch 6 cases
                jmp     cs:jpt_10583[bx] ; switch jump
; ---------------------------------------------------------------------------
jpt_10583       dw offset mode0_ega     ; jump table for switch statement
                dw offset mode1_cga
                dw offset mode2_cga2
                dw offset mode3_hgc
                dw offset mode4_mcga
                dw offset mode5_tga
; ---------------------------------------------------------------------------

mode0_ega:                              ; jumptable 00010583 case 0
                mov     ax, 0Eh
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                retn
; ---------------------------------------------------------------------------

mode1_cga:                              ; jumptable 00010583 case 1
                mov     ax, 5
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                retn
; ---------------------------------------------------------------------------

mode2_cga2:                              ; jumptable 00010583 case 2
                mov     ax, 6
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                retn
; ---------------------------------------------------------------------------

mode4_mcga:                             ; jumptable 00010583 case 4
                mov     ax, 13h
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                retn
; ---------------------------------------------------------------------------

mode5_tga:                              ; jumptable 00010583 case 5
                mov     ax, 9
                int     10h             ; - VIDEO - SET VIDEO MODE
                                        ; AL = mode
                retn
; ---------------------------------------------------------------------------

mode3_hgc:                              ; jumptable 00010583 case 3
                push    cs
                pop     ds
                mov     dx, 3B8h
                mov     al, 2
                out     dx, al
                mov     dx, 3BFh
                mov     al, 1
                out     dx, al
                mov     cx, 0Ch
                mov     ah, 0
                mov     si, offset hgc_settings
                mov     dx, 3B4h

loc_105CB:
                mov     al, ah
                out     dx, al          ; Video: CRT cntrlr addr
                                        ; horizontal total
                lodsb
                inc     dx
                out     dx, al          ; Video: CRT controller internal registers
                dec     dx
                inc     ah
                loop    loc_105CB
                mov     al, 2Ah ; '*'
                mov     dx, 3B8h
                out     dx, al
                mov     ax, 0B000h
                mov     es, ax
                mov     di, 0
                xor     ax, ax
                mov     cx, 4000h
                rep stosw
                retn
Set_Video_Mode endp

; ---------------------------------------------------------------------------
hgc_settings    db 35h, 2Dh, 2Eh, 7, 5Bh, 2, 57h, 57h, 2, 3, 0, 0

; =============== S U B R O U T I N E =======================================


int23_new       proc far
                iret
int23_new       endp


; =============== S U B R O U T I N E =======================================


Parse_Command_Line proc near
                test    byte ptr es:80h, 0FFh
                jnz     short loc_10602
                retn
; ---------------------------------------------------------------------------

loc_10602:
                mov     di, offset user_savegame_to_restore
                xor     cx, cx
                mov     cl, es:80h
                mov     si, 81h

loc_1060F:
                cmp     byte ptr es:[si], ' '
                jnz     short loc_10619
                inc     si
                loop    loc_1060F
                retn
; ---------------------------------------------------------------------------

loc_10619:
                xor     ah, ah

loc_1061B:
                mov     al, es:[si]
                cmp     al, ' '
                jz      short loc_1062B
                cmp     al, 0Dh
                jz      short loc_1062B
                mov     ah, 0FFh
                mov     [di], al
                inc     di

loc_1062B:
                inc     si
                loop    loc_1061B
                or      ah, ah
                jnz     short loc_10633
                retn
; ---------------------------------------------------------------------------

loc_10633:
                mov     restore_on_startup_flag, 0FFh
                mov     byte ptr [di], '.'
                mov     byte ptr [di+1], 'U'
                mov     byte ptr [di+2], 'S'
                mov     byte ptr [di+3], 'R'
                mov     byte ptr [di+4], 0
                retn
Parse_Command_Line endp

; ---------------------------------------------------------------------------
g_szTitleString      db 'The Fantasy Action Game ZELIARD Version 1.208',0Dh,0Ah
                     db 'Copyright (C) 1987 ~ 1990 Game Arts Co.,Ltd.',0Dh,0Ah
                     db 'Copyright (C) 1990 Sierra On-Line, Inc.',0Dh,0Ah,'$'
g_szNotSupportedCmd  db 'Not supported command !',0Dh,0Ah,'$'
g_szSpecialMode      db 'Special mode !!',0Dh,0Ah,'$'
g_szNotEnoughMemory  db 'Not enough memory to run ',27h,'ZELIARD',27h,'.',0Dh,0Ah,'$'
g_szMemoryError      db 'Memory error !!!',0Dh,0Ah,'$'
g_szThankYou         db 'Thank you for playing.',0Dh,0Ah,'$'
g_szFileErrorFrom    db 'File Error from $'
g_szErrorType        db '     Error Type : $'
g_szFileNotFound     db 'File not found.$'
g_szDiskReadError    db 'DISK read Error!!$'
g_szUserFileNothing  db 'USER file nothing.$'
g_szErrorInResource  db 'Error in RESOURCE.CFG',0Dh,0Ah,'$'
g_bErrorCodesHi      db '0'
g_bErrorCodesLo      db '0'
                     db '0'
                     db '1'
                     db '0'
                     db '2'
                     db '0'
                     db '3'
                     db '0'
                     db '4'
                     db '0'
                     db '5'
                     db '0'
                     db '6'
                     db '0'
                     db '7'
                     db '0'
                     db '8'
                     db '0'
                     db '9'
                     db '0'
                     db 'A'
                     db '0'
                     db 'B'
                     db '0'
                     db 'C'
                     db '0'
                     db 'D'
                     db '0'
                     db 'E'
                     db '0'
                     db 'F'
g_szResourceCfg      db 'RESOURCE.CFG',0
g_szMtinitCom        db 'MTINIT.COM',0
video_drivers_vfs    dw offset vfs_gmega_bin
                     dw offset vfs_gmcga_bin
                     dw offset vfs_gmcga_bin
                     dw offset vfs_gmhgc_bin
                     dw offset vfs_gmmcga_bin
                     dw offset vfs_gmtga_bin
; game_cseg memory map:
; 0000h...00FFh - stdply.bin or savegame.usr
; 0100h - stick.bin
; 2000h - gmmcga.bin
; 0A000h - game.bin
vfs_stick_bin        dw 100h
g_szStickBin         db 'stick.bin',0
vfs_gmega_bin        dw 2000h
g_szGmegaBin         db 'gmega.bin',0
vfs_gmcga_bin        dw 2000h
g_szGmcgaBin         db 'gmcga.bin',0
vfs_gmhgc_bin        dw 2000h
g_szGmhgcBin         db 'gmhgc.bin',0
vfs_gmmcga_bin       dw 2000h
g_szGmmcgaBin        db 'gmmcga.bin',0
vfs_gmtga_bin        dw 2000h
g_szGmtgaBin         db 'gmtga.bin',0
vfs_game_bin         dw 0A000h
g_szGameBin          db 'game.bin',0
vfs_stdply_bin       dw 0
g_szStdplyBin        db 'stdply.bin',0
vfs_savename         dw 0
user_savegame_to_restore  db 0, 0, 0, 0, 0, 0, 0, 0
                     db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
; seg1 memory map:
; 0 - music drv. It is loaded to (seg1-10h):0100h, so (seg1-10h):0 is the same as game_cseg:0FF00h
; 1000h - soundFx drv. It is loaded to (seg1-10h):1100h, so (seg1-10h):0 is the same as game_cseg:0FF00h
vfs_music_drv        dw 100h
g_szMuzicDrv         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
vfs_snd_fx_drv       dw 1100h
g_szSoundFxDrv       db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
game_bin_off         dw 0A000h
game_cseg            dw 0
int8_old             dd 0
int9_old             dd 0
int60_old            dd 0
int61_old            dd 0
restore_on_startup_flag db 0
keep_sp              dw 0
keep_ss              dw 0
param_block          dw seg seg000
                     dd epb_cmdline
                     dd epb_fcb
                     dd epb_fcb
epb_cmdline          db 1, 20h, 0Dh
epb_fcb              db 0, 20h, 14 dup(0)
video_mode           db 0
music_is_mt32_flag   db 0
use_joystick_flag    db 0
token_length         db 0
file_buf             db 0FFh dup(0)
seg000          ends

; ===========================================================================

; Segment type: Uninitialized
seg001          segment byte stack 'STACK'
                assume cs:seg001
                db 2000h dup(?)
seg001          ends

                end start
