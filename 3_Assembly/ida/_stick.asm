include common.inc
                .286
                .model small

stick           segment byte public 'CODE' use16
                assume cs:stick
                org 100h
                assume es:nothing, ss:nothing, ds:stick
start:                
                jmp     near ptr Keyboard_ISR_Hook
                jmp     near ptr timer_ISR_int8_chained
                jmp     near ptr Quiet_Critical_Error_Handler
                jmp     near ptr Int_61_handler
; ---------------------------------------------------------------------------
                dw offset res_dispatcher                
                dw offset reserved_nop
                dw offset Confirm_Exit_Dialog
                dw offset Handle_Pause_State
                dw offset Handle_Speed_Change
                dw offset Joystick_Calibration
                dw offset Joystick_Deactivator
                dw offset accumulate_folded_ff1b
                dw offset Scan_Saved_Games
                dw offset Handle_Restore_Game
                dw offset raw_joystick_calibration_read

; =============== S U B R O U T I N E =======================================


space_alt_edge_detector proc near
                test    cs:space_prev_state, 0FFh
                jz      short loc_140
                test    byte ptr cs:____Alt_Space, 1
                jz      short loc_14E
                mov     cs:space_prev_state, 0
                mov     byte ptr cs:spacebar_latch, 0FFh
                jmp     short loc_14E

loc_140:
                test    byte ptr cs:____Alt_Space, 1
                jnz     short loc_14E
                mov     cs:space_prev_state, 0FFh

loc_14E:
                test    cs:alt_prev_state, 0FFh
                jz      short loc_16C
                test    byte ptr cs:____Alt_Space, 2
                jnz     short loc_15F
                retn

loc_15F:
                mov     cs:alt_prev_state, 0
                mov     byte ptr cs:altkey_latch, 0FFh
                retn

loc_16C:
                test    byte ptr cs:____Alt_Space, 2
                jz      short loc_175
                retn

loc_175:
                mov     cs:alt_prev_state, 0FFh
                retn
space_alt_edge_detector endp


; =============== S U B R O U T I N E =======================================


joystick_buttons_edge_detectors proc near

                test    byte ptr cs:joystick_calibrated_flag, 0FFh
                jnz     short loc_185
                retn

loc_185:
                test    byte ptr cs:joystick_enabled_flag, 0FFh
                jnz     short loc_18E
                retn

loc_18E:
                mov     dx, 201h
                in      al, dx          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                call    joystick_btn1_edge_detector
                jmp     short joystick_btn2_edge_detector
joystick_buttons_edge_detectors endp


; =============== S U B R O U T I N E =======================================


joystick_btn1_edge_detector proc near   ; ...
                test    cs:joy_btn1_prev_state, 0FFh
                jz      short loc_1B1
                test    al, 10h
                jz      short loc_1A4
                retn

loc_1A4:
                mov     cs:joy_btn1_prev_state, 0
                mov     byte ptr cs:spacebar_latch, 0FFh
                retn

loc_1B1:
                test    al, 10h
                jnz     short loc_1B6
                retn

loc_1B6:
                mov     cs:joy_btn1_prev_state, 0FFh
                retn
joystick_btn1_edge_detector endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR joystick_buttons_edge_detectors

joystick_btn2_edge_detector:  
                test    cs:joy_btn2_prev_state, 0FFh
                jz      short loc_1D7
                test    al, 20h
                jz      short loc_1CA
                retn
; ---------------------------------------------------------------------------

loc_1CA:
                mov     cs:joy_btn2_prev_state, 0
                mov     byte ptr cs:altkey_latch, 0FFh
                retn
; ---------------------------------------------------------------------------

loc_1D7:
                test    al, 20h
                jnz     short loc_1DC
                retn
; ---------------------------------------------------------------------------

loc_1DC:
                mov     cs:joy_btn2_prev_state, 0FFh
                retn
; END OF FUNCTION CHUNK FOR joystick_buttons_edge_detectors

; =============== S U B R O U T I N E =======================================


F1_F2_edge_detector proc near
                test    cs:f1_prev_state, 0FFh
                jz      short loc_20C
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1000h
                jnz     short loc_21B
                mov     byte ptr cs:soundFX_request, 1
                mov     cs:f1_prev_state, 0
                mov     cl, cs:music_channel_param
                mov     ax, 2
                int     60h             ; adlib: AX=2 starts a channel (CL = channel)
                jmp     short loc_21B

loc_20C:
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1000h
                jz      short loc_21B
                mov     cs:f1_prev_state, 0FFh

loc_21B:
                test    cs:f2_prev_state, 0FFh
                jz      short loc_23F
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 2000h
                jz      short loc_22D
                retn

loc_22D:
                mov     cs:f2_prev_state, 0
                not     byte ptr cs:sound_fx_toggle_by_f2
                mov     byte ptr cs:soundFX_request, 1
                retn

loc_23F:
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 2000h
                jnz     short loc_249
                retn

loc_249:
                mov     cs:f2_prev_state, 0FFh
                retn
F1_F2_edge_detector endp


; =============== S U B R O U T I N E =======================================


timer_ISR_int8_chained proc far
                push    ax
                push    bx
                push    cx
                push    dx
                push    di
                push    si
                push    bp
                push    ds
                push    es
                cld
                call    dword ptr cs:fn_per_tick_callback2
                call    dword ptr cs:fn_per_tick_callback
                dec     cs:tick_divider
                jnz     short loc_27A
                mov     cs:tick_divider, 5
                call    F1_F2_edge_detector
                call    space_alt_edge_detector
                call    joystick_buttons_edge_detectors

loc_27A:
                inc     byte ptr cs:frame_timer
                inc     word ptr cs:tick_counter
                inc     word ptr cs:anim_timer
                inc     cs:disk_retry_timer
                test    byte ptr cs:per_tick_user_enabled, 0FFh
                jz      short loc_29B
                call    word ptr cs:fn_per_tick_user_ptr

loc_29B:
                pop     es
                pop     ds
                pop     bp
                pop     si
                pop     di
                pop     dx
                pop     cx
                pop     bx
                dec     cs:kbd_chain_divider
                jz      short loc_2B0
                mov     al, 20h
                out     20h, al         ; Interrupt controller, 8259A.
                pop     ax
                iret

loc_2B0:
                mov     cs:kbd_chain_divider, 0Dh
                pop     ax
                jmp     dword ptr cs:fn_timer_chain_ptr
timer_ISR_int8_chained endp ; sp-analysis failed

; ---------------------------------------------------------------------------
tick_divider        db 10
kbd_chain_divider   db 13
space_prev_state    db 0 
alt_prev_state      db 0 
joy_btn1_prev_state db 0 
joy_btn2_prev_state db 0 
f1_prev_state       db 0 
f2_prev_state       db 0 
disk_retry_timer    db 0 

; =============== S U B R O U T I N E =======================================


Keyboard_ISR_Hook proc far    
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                mov     ax, cs
                mov     ds, ax
                in      al, 60h         ; 8042 keyboard controller data register
                cmp     al, 0FFh        ; error
                jz      short loc_2F7
                cmp     al, 0FEh        ; Resend command
                jz      short loc_2F7
                call    scan_code_dispatcher

loc_2DE:
                mov     ah, 1
                int     16h             ; KEYBOARD - CHECK BUFFER, DO NOT CLEAR
                                        ; Return: ZF clear if character in buffer
                                        ; AH = scan code, AL = character
                                        ; ZF set if no character in buffer
                jz      short loc_2EA   ; leftArrow -> 01e0
                xor     ah, ah
                int     16h             ; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
                                        ; Return: AH = scan code, AL = character
                jmp     short loc_2DE

loc_2EA:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     dword ptr cs:fn_kbd_chain_ptr

loc_2F7:
                in      al, 61h         ; PC/XT PPI port B bits:
                                        ; 0: Tmr 2 gate ═╦═► OR 03H=spkr ON
                                        ; 1: Tmr 2 data ═╝  AND 0fcH=spkr OFF
                                        ; 3: 1=read high switches
                                        ; 4: 0=enable RAM parity checking
                                        ; 5: 0=enable I/O channel check
                                        ; 6: 0=hold keyboard clock low
                                        ; 7: 0=enable kbrd
                or      al, 80h
                out     61h, al         ; PC/XT PPI port B bits:
                                        ; 0: Tmr 2 gate ═╦═► OR 03H=spkr ON
                                        ; 1: Tmr 2 data ═╝  AND 0fcH=spkr OFF
                                        ; 3: 1=read high switches
                                        ; 4: 0=enable RAM parity checking
                                        ; 5: 0=enable I/O channel check
                                        ; 6: 0=hold keyboard clock low
                                        ; 7: 0=enable kbrd
                and     al, 7Fh
                out     61h, al         ; PC/XT PPI port B bits:
                                        ; 0: Tmr 2 gate ═╦═► OR 03H=spkr ON
                                        ; 1: Tmr 2 data ═╝  AND 0fcH=spkr OFF
                                        ; 3: 1=read high switches
                                        ; 4: 0=enable RAM parity checking
                                        ; 5: 0=enable I/O channel check
                                        ; 6: 0=hold keyboard clock low
                                        ; 7: 0=enable kbrd
                mov     cs:arrows_bits_0123, 0
                mov     cs:diagonal_bits_0_7, 0
                mov     cs:arrowsHKUM_bits_0123, 0
                mov     cs:diagonalYINComma_bits_0_7, 0
                mov     al, 20h ; ' '
                out     20h, al         ; Interrupt controller, 8259A.
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                iret
Keyboard_ISR_Hook endp


; =============== S U B R O U T I N E =======================================


scan_code_dispatcher proc near
                push    ax
                call    Map_ScanCode_To_ASCII
                pop     ax
                cmp     al, 0E0h
                jb      short loc_330
                retn

loc_330:
                mov     ah, al          ; leftArrow=4b
                and     al, 7Fh
                mov     cl, 8
                cmp     al, 4Dh ; 'M'   ; rightArrow
                jz      short loc_35C
                cmp     al, 4Eh ; 'N'
                jz      short loc_35C
                mov     cl, 4
                cmp     al, 4Bh ; 'K'   ; leftArrow
                jz      short loc_35C
                cmp     al, 2Bh ; '+'
                jz      short loc_35C
                mov     cl, 2
                cmp     al, 50h ; 'P'   ; downArrow
                jz      short loc_35C
                cmp     al, 4Ah ; 'J'
                jz      short loc_35C
                mov     cl, 1
                cmp     al, 48h ; 'H'   ; upArrow
                jz      short loc_35C
                cmp     al, 29h ; ')'
                jnz     short loc_36F

loc_35C:
                or      arrows_bits_0123, cl ; arrows: right=8, left=4, down=2, up=1
                test    ah, 80h         ; pressed/released
                jnz     short loc_368
                jmp     loc_497

loc_368:
                xor     arrows_bits_0123, cl
                jmp     loc_497

loc_36F:
                mov     cl, 101b
                cmp     al, 47h ; 'G'   ; Left+Up
                jz      short loc_387
                mov     cl, 10010000b
                cmp     al, 49h ; 'I'   ; Right+Up
                jz      short loc_387
                mov     cl, 1100000b
                cmp     al, 4Fh ; 'O'   ; Left+Down
                jz      short loc_387
                mov     cl, 1010b
                cmp     al, 51h ; 'Q'   ; Right+Down
                jnz     short loc_39A

loc_387:
                or      diagonal_bits_0_7, cl
                test    ah, 80h
                jnz     short loc_393
                jmp     loc_497

loc_393:
                xor     diagonal_bits_0_7, cl
                jmp     loc_497

loc_39A:
                test    byte ptr ds:keyboard_alt_mode_flag, 0FFh
                jz      short loc_3AD
                mov     arrowsHKUM_bits_0123, 0
                mov     diagonalYINComma_bits_0_7, 0
                jmp     short loc_3FB

loc_3AD:
                mov     cl, 8
                cmp     al, 25h ; '%'   ; K
                jz      short loc_3C5
                mov     cl, 4
                cmp     al, 23h ; '#'   ; H
                jz      short loc_3C5
                mov     cl, 2
                cmp     al, 32h ; '2'   ; M
                jz      short loc_3C5
                mov     cl, 1
                cmp     al, 16h         ; U
                jnz     short loc_3D4

loc_3C5:
                or      arrowsHKUM_bits_0123, cl
                test    ah, 80h
                jz      short loc_416
                xor     arrowsHKUM_bits_0123, cl
                jmp     short loc_416

loc_3D4:
                mov     cl, 101b
                cmp     al, 15h
                jz      short loc_3EC
                mov     cl, 10010000b
                cmp     al, 17h
                jz      short loc_3EC
                mov     cl, 1100000b
                cmp     al, 31h ; '1'
                jz      short loc_3EC
                mov     cl, 1010b
                cmp     al, 33h ; '3'
                jnz     short loc_3FB

loc_3EC:
                or      diagonalYINComma_bits_0_7, cl
                test    ah, 80h
                jz      short loc_416
                xor     diagonalYINComma_bits_0_7, cl
                jmp     short loc_416

loc_3FB:
                mov     cl, 1
                cmp     al, 39h ; '9'   ; Space
                jz      short loc_407
                mov     cl, 2
                cmp     al, 38h ; '8'   ; Alt
                jnz     short loc_416

loc_407:
                or      ds:____Alt_Space, cl
                test    ah, 80h
                jz      short loc_416
                xor     ds:____Alt_Space, cl
                jmp     short $+2

loc_416:
                mov     cx, 800h
                cmp     al, 25h ; '%'   ; K
                jz      short loc_48A
                mov     cx, 400h
                cmp     al, 13h         ; R
                jz      short loc_48A
                mov     cx, 200h
                cmp     al, 12h         ; E
                jz      short loc_48A
                mov     cx, 100h
                cmp     al, 24h ; '$'   ; J
                jz      short loc_48A
                mov     cx, 80h
                cmp     al, 1Fh         ; S
                jz      short loc_48A
                mov     cx, 40h ; '@'
                cmp     al, 31h ; '1'   ; N
                jz      short loc_48A
                mov     cx, 20h ; ' '
                cmp     al, 15h         ; Y
                jz      short loc_48A
                mov     cx, 10h
                cmp     al, 10h         ; Q
                jz      short loc_48A
                mov     cx, 8
                cmp     al, 1           ; Esc
                jz      short loc_48A
                mov     cx, 4
                cmp     al, 1Dh         ; LCtrl
                jz      short loc_48A
                mov     cx, 2
                cmp     al, 36h ; '6'   ; RShift
                jz      short loc_48A
                cmp     al, 2Ah ; '*'   ; LShift
                jz      short loc_48A
                mov     cx, 1
                cmp     al, 1Ch         ; Enter
                jz      short loc_48A
                mov     cx, 1000h
                cmp     al, 3Bh ; ';'   ; F1
                jz      short loc_48A
                mov     cx, 2000h
                cmp     al, 3Ch ; '<'   ; F2
                jz      short loc_48A
                mov     cx, 4000h
                cmp     al, 41h ; 'A'   ; F7
                jz      short loc_48A
                mov     cx, 8000h
                cmp     al, 43h ; 'C'   ; F9
                jnz     short loc_497

loc_48A:
                or      ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, cx
                test    ah, 80h
                jz      short loc_497
                xor     ds:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, cx

loc_497:
                mov     al, arrows_bits_0123 ; arrows: right=8, left=4, down=2, up=1
                or      al, arrowsHKUM_bits_0123
                mov     ah, diagonal_bits_0_7
                and     ah, 0Fh
                or      al, ah
                mov     ah, diagonal_bits_0_7
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                or      al, ah
                mov     ah, diagonalYINComma_bits_0_7
                and     ah, 0Fh
                or      al, ah
                mov     ah, diagonalYINComma_bits_0_7
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                or      al, ah
                mov     ds:____right_left_down_up, al
                retn
scan_code_dispatcher endp


; =============== S U B R O U T I N E =======================================


Map_ScanCode_To_ASCII proc near         ; ...
                cmp     al, 0E0h
                jb      short loc_4DB
                mov     cs:Extended_Key_Flag, 0FFh ; for leftArrow, etc
                retn

loc_4DB:
                test    cs:Extended_Key_Flag, 0FFh
                mov     cs:Extended_Key_Flag, 0
                jz      short loc_4EA
                retn

loc_4EA:
                or      al, al
                jns     short loc_4EF
                retn

loc_4EF:
                cmp     al, 84
                jb      short loc_4F4
                retn

loc_4F4:
                dec     al
                xor     bx, bx
                mov     bl, al
                mov     di, offset normal_keys
                test    word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 2
                jz      short loc_509
                mov     di, offset shifted_keys

loc_509:
                mov     al, cs:[bx+di]
                mov     cs:Current_ASCII_Char, al
                retn
Map_ScanCode_To_ASCII endp

; ---------------------------------------------------------------------------
normal_keys     db 0          
a1234567890     db '1234567890',0
                db    0
                db    8
                db    0
aQwertyuiop     db 'QWERTYUIOP',0
                db    0
                db  0Dh
                db    0
aAsdfghjkl      db 'ASDFGHJKL',0
                db    0
                db    0
                db    0
                db    0
aZxcvbnm        db 'ZXCVBNM',0
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
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
shifted_keys    db 0          
                db  21h ; !
                db  40h ; @
                db    0
                db  24h ; $
                db  25h ; %
                db    0
                db    0
                db    0
                db  28h ; (
                db  29h ; )
                db    0
                db    0
                db    8
                db    0
aQwertyuiop_0   db 'QWERTYUIOP{}',0Dh,0
aAsdfghjkl_0    db 'ASDFGHJKL:',0
                db    0
                db    0
                db    0
aZxcvbnm_0      db 'ZXCVBNM',0
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
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
arrows_bits_0123          db 0 ; Primary Directional Buffer
diagonal_bits_0_7         db 0        
arrowsHKUM_bits_0123      db 0     
diagonalYINComma_bits_0_7 db 0
Extended_Key_Flag         db 0        
joystick_center_x         db 0        
                          db    0
joystick_center_y         db 0        
                          db    0

; =============== S U B R O U T I N E =======================================


Read_Joystick_Axes proc near  
                mov     dx, 201h
                xor     si, si
                xor     di, di
                mov     cl, 1
                mov     ch, 2
                xor     bh, bh
                cli
                mov     ah, 3
                out     dx, al          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                mov     bl, 6

loc_5DD:
                in      al, dx          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                xor     al, ah
                jz      short loc_5E6
                dec     bl
                jnz     short loc_5DD

loc_5E6:
                in      al, dx          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                mov     ah, al
                and     ah, ch
                shr     ah, 1
                mov     bl, al
                and     bl, cl
                add     si, bx          ; SI (X-coordinate)
                mov     bl, ah
                add     di, bx          ; DI (Y-coordinate)
                and     al, 3
                jnz     short loc_5E6
                sti
                retn
Read_Joystick_Axes endp


; =============== S U B R O U T I N E =======================================


Int_61_handler  proc far      
                push    bx
                push    cx
                push    dx
                mov     byte ptr cs:joystick_direction_bits, 0
                mov     byte ptr cs:joystick_button_bits, 0
                mov     al, cs:joystick_calibrated_flag
                and     al, ds:joystick_enabled_flag
                jz      short loc_619
                call    joystick_axis_direction_bits

loc_619:
                mov     al, cs:____right_left_down_up   ; right_left_down_up
                or      al, cs:joystick_direction_bits
                mov     ah, cs:____Alt_Space   ; Alt_Space
                or      ah, cs:joystick_button_bits
                pop     dx
                pop     cx
                pop     bx
                iret
Int_61_handler  endp


; =============== S U B R O U T I N E =======================================


joystick_axis_direction_bits proc near  ; ...
                push    si
                push    di
                push    cx
                call    Read_Joystick_Axes
                mov     cx, word ptr cs:joystick_center_x
                add     cx, 8
                jnb     short loc_643
                mov     cx, 0FFFFh

loc_643:
                cmp     si, cx
                jb      short loc_64D
                or      byte ptr cs:joystick_direction_bits, 8

loc_64D:
                mov     cx, word ptr cs:joystick_center_x
                shr     cx, 1
                sub     cx, 8
                jnb     short loc_65B
                xor     cx, cx

loc_65B:
                cmp     si, cx
                ja      short loc_665
                or      byte ptr cs:joystick_direction_bits, 4

loc_665:
                mov     cx, word ptr cs:joystick_center_y
                add     cx, 8
                jnb     short loc_672
                mov     cx, 0FFFFh

loc_672:
                cmp     di, cx
                jb      short loc_67C
                or      byte ptr cs:joystick_direction_bits, 2

loc_67C:
                mov     cx, word ptr cs:joystick_center_y
                shr     cx, 1
                sub     cx, 8
                jnb     short loc_68A
                xor     cx, cx

loc_68A:
                cmp     di, cx
                ja      short loc_694
                or      byte ptr cs:joystick_direction_bits, 1

loc_694:
                mov     dx, 201h
                in      al, dx          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                not     al
                shr     al, 1
                shr     al, 1
                shr     al, 1
                shr     al, 1
                and     al, 3
                mov     cs:joystick_button_bits, al
                pop     cx
                pop     di
                pop     si
                retn
joystick_axis_direction_bits endp


; =============== S U B R O U T I N E =======================================


Confirm_Exit_Dialog proc near 
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 10100b ; Ctrl+Q
                jz      short ctrl_q_pressed
                retn

ctrl_q_pressed:               
                push    ds
                call    draw_dialog_overlay_background
                mov     cl, 0FFh
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=FF: mute)
                push    cs
                pop     ds
                mov     si, offset aExitToDosSureY ; "Exit to DOS.\r Sure?(Y/N)"
                mov     bx, 74h ; 't'
                mov     cl, 52h ; 'R'
                call    word ptr cs:Render_String_FF_Terminated_proc
                pop     ds

loc_6D0:
                mov     ax, cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter
                test    ax, 60h
                jz      short loc_6D0
                test    ax, 20h
                jnz     short loc_6FB
                call    restore_dialog_overlay_background
                xor     cl, cl
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=0: all)
                mov     byte ptr cs:____right_left_down_up, 0
                mov     byte ptr cs:spacebar_latch, 0
                mov     byte ptr cs:altkey_latch, 0
                retn
; ---------------------------------------------------------------------------

loc_6FB:
                test    byte ptr cs:exit_pending_flag, 0FFh
                jz      short loc_6FB
                xor     ax, ax
                jmp     dword ptr cs:fn_exit_far_ptr
Confirm_Exit_Dialog endp

; ---------------------------------------------------------------------------
aExitToDosSureY db 'Exit to DOS.',0Dh,' Sure?(Y/N)' ; ...
                db 0FFh

; =============== S U B R O U T I N E =======================================


Handle_Pause_State proc near  
                test    word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 8
                jnz     short esc_pressed
                retn

esc_pressed:                  
                push    ds
                mov     byte ptr cs:soundFX_request, 2
                mov     ax, 101Eh
                mov     cx, 810h
                mov     di, 3C80h
                call    word ptr cs:Capture_Screen_Rect_to_seg3_proc
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1110b
                jz      short loc_766
                mov     bx, 201Eh
                mov     cx, 1010h
                mov     al, 0FFh
                call    word ptr cs:Draw_Bordered_Rectangle_proc
                push    cs
                pop     ds
                mov     si, offset aPause ; "PAUSE"
                mov     bx, 8Ch
                mov     cl, 22h ; '"'
                call    word ptr cs:Render_String_FF_Terminated_proc

loc_766:
                mov     cl, 0FFh
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=FF: mute)
                pop     ds

loc_76E:
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 1110b
                jnz     short loc_779
                call    restore_dialog_background

loc_779:
                test    byte ptr cs:spacebar_latch, 0FFh
                jnz     short loc_78B
                test    byte ptr cs:altkey_latch, 0FFh
                jnz     short loc_78B
                jmp     short loc_76E
; ---------------------------------------------------------------------------

loc_78B:
                call    restore_dialog_background
                mov     byte ptr cs:spacebar_latch, 0
                mov     byte ptr cs:altkey_latch, 0
                xor     cl, cl
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=0: all)
                retn
Handle_Pause_State endp


; =============== S U B R O U T I N E =======================================


restore_dialog_background proc near     ; ...
                mov     ax, 101Eh
                mov     cx, 810h
                mov     di, 3C80h
                jmp     word ptr cs:Put_Image_proc
restore_dialog_background endp

; ---------------------------------------------------------------------------
aPause          db 'PAUSE'    
                db 0FFh

; =============== S U B R O U T I N E =======================================


Handle_Speed_Change proc near 
                test    word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 8000h
                jnz     short loc_7C0
                retn
; ---------------------------------------------------------------------------

loc_7C0:
                call    draw_dialog_overlay_background
                push    cs
                pop     ds
                mov     si, offset aSpeedChangeSel ; "Speed change\rSelect 0-9:"
                mov     bx, 74h ; 't'
                mov     cl, 52h ; 'R'
                call    word ptr cs:Render_String_FF_Terminated_proc

loc_7D2:
                test    word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 8000h
                jnz     short loc_7D2
                mov     al, ds:speed_const
                neg     al
                add     al, 0Ah
                call    wait_digit_or_Esc
                push    ax
                add     al, 30h ; '0'
                mov     ah, 1
                mov     bx, 0CCh
                mov     cl, 5Ah ; 'Z'
                call    word ptr cs:Render_Font_Glyph_proc
                pop     ax
                neg     al
                add     al, 0Ah
                mov     ds:speed_const, al
                mov     byte ptr cs:soundFX_request, 1
                call    flush_console_input
                mov     byte ptr cs:____right_left_down_up, 0
                mov     byte ptr cs:spacebar_latch, 0
                mov     byte ptr cs:altkey_latch, 0

loc_817:
                mov     dl, 0FFh
                mov     ah, 6
                int     21h             ; DOS - DIRECT CONSOLE I/O CHARACTER OUTPUT
                                        ; DL = character <> FFh
                                        ;  Return: ZF set = no character
                                        ;   ZF clear = character recieved, AL = character
                jnz     short loc_82F
                mov     al, cs:____right_left_down_up
                or      al, cs:spacebar_latch
                or      al, cs:altkey_latch
                jz      short loc_817

loc_82F:
                call    restore_dialog_overlay_background
                mov     byte ptr cs:____right_left_down_up, 0
                mov     byte ptr cs:spacebar_latch, 0
                mov     byte ptr cs:altkey_latch, 0
                retn
Handle_Speed_Change endp

; ---------------------------------------------------------------------------
aSpeedChangeSel db 'Speed change',0Dh,'Select 0-9:' ; ...
                db 0FFh

; =============== S U B R O U T I N E =======================================


wait_digit_or_Esc proc near   
                mov     byte ptr ds:Current_ASCII_Char, 0

wait_keypress:                
                test    byte ptr ds:Current_ASCII_Char, 0FFh
                jz      short wait_keypress
                mov     ah, ds:Current_ASCII_Char
                cmp     ah, 1Bh
                stc
                jnz     short loc_875
                retn

loc_875:
                sub     ah, 30h ; '0'
                cmp     ah, 0Ah
                jnb     short wait_keypress
                clc
                mov     al, ah
                retn
wait_digit_or_Esc endp


; =============== S U B R O U T I N E =======================================


Joystick_Calibration proc near
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 100000100b ; Ctrl+J
                jz      short loc_88B
                retn

loc_88B:
                call    raw_joystick_calibration_read
                mov     byte ptr cs:____right_left_down_up, 0

loc_894:
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 100000100b ; Ctrl+J
                jz      short loc_894
                retn
Joystick_Calibration endp


; =============== S U B R O U T I N E =======================================


raw_joystick_calibration_read proc near ; ...
                test    byte ptr cs:joystick_calibrated_flag, 0FFh
                jz      short loc_8A7
                retn

loc_8A7:
                test    byte ptr cs:joystick_enabled_flag, 0FFh
                jnz     short loc_8B0
                retn

loc_8B0:
                mov     cx, 103h
                shl     ch, cl
                xchg    ax, cx
                mov     cx, 0FFFFh
                mov     dx, 201h

loc_8BC:
                in      al, dx          ; Game I/O port
                                        ; bits 0-3: Coordinates (resistive, time-dependent inputs)
                                        ; bits 4-7: Buttons/Triggers (digital inputs)
                test    al, ah
                loopne  loc_8BC
                jcxz    short locret_8EE
                call    Read_Joystick_Axes
                cmp     si, 0FFFFh
                jz      short locret_8EE
                cmp     di, 0FFFFh
                jz      short locret_8EE
                or      si, si
                jz      short locret_8EE
                or      di, di
                jz      short locret_8EE
                mov     word ptr cs:joystick_center_x, si
                mov     word ptr cs:joystick_center_y, di
                mov     byte ptr cs:joystick_calibrated_flag, 0FFh
                mov     byte ptr cs:soundFX_request, 1

locret_8EE:                   
                retn
raw_joystick_calibration_read endp


; =============== S U B R O U T I N E =======================================


Joystick_Deactivator proc near
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 100000000100b ; Ctrl+K
                jz      short loc_8F9
                retn

loc_8F9:
                test    byte ptr cs:joystick_calibrated_flag, 0FFh
                jnz     short loc_902
                retn

loc_902:
                mov     byte ptr cs:soundFX_request, 1
                mov     byte ptr cs:joystick_calibrated_flag, 0

loc_90E:
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 100000000100b ; Ctrl+K
                jz      short loc_90E
                retn
Joystick_Deactivator endp


; =============== S U B R O U T I N E =======================================


accumulate_folded_ff1b proc near        ; ...
                mov     ax, cs:anim_timer
                add     al, ah          ; ax += ah
                adc     ah, 0
                add     ax, cs:anim_accum
                mov     cs:anim_accum, ax ; ACC = Σ (S_i + (S_i >> 8))   for i = 0 to N-1
                retn
accumulate_folded_ff1b endp

; ---------------------------------------------------------------------------
anim_accum      dw 0          

; =============== S U B R O U T I N E =======================================


Handle_Restore_Game proc near 
                cmp     word ptr cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter, 100000000000000b ; F7
                clc
                jz      short loc_938
                retn

loc_938:
                push    ds
                call    draw_dialog_overlay_background
                mov     cl, 0FFh
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=FF: mute)
                push    cs
                pop     ds
                mov     si, offset aRestoreGameSur ; "Restore Game\r Sure?(Y/N)"
                mov     bx, 74h ; 't'
                mov     cl, 52h ; 'R'
                call    word ptr cs:Render_String_FF_Terminated_proc
                pop     ds

wait_loop:   
                mov     ax, cs:F9_F7_F2_F1_KREJSNYQ_Esc_Ctrl_Shift_Enter
                test    ax, 1100000b ; Y
                jz      short wait_loop
                test    ax, 20h
                pushf
                call    restore_dialog_overlay_background
                mov     byte ptr cs:____right_left_down_up, 0
                mov     byte ptr cs:spacebar_latch, 0
                mov     byte ptr cs:altkey_latch, 0
                xor     cl, cl
                mov     ax, 3
                int     60h             ; adlib: AX=3 stops a channel (CL=0: all)
                popf
                stc
                jz      short loc_981
                retn

loc_981:
                clc
                retn
Handle_Restore_Game endp

; ---------------------------------------------------------------------------
aRestoreGameSur db 'Restore Game',0Dh,' Sure?(Y/N)' ; ...
                db 0FFh

; =============== S U B R O U T I N E =======================================


draw_dialog_overlay_background proc near ; ...
                mov     byte ptr cs:soundFX_request, 2

loc_9A2:
                mov     ax, 0C46h
                mov     cx, 1028h
                mov     di, 3C80h
                call    word ptr cs:Capture_Screen_Rect_to_seg3_proc
                mov     bx, 1A46h
                mov     cx, 1E28h
                mov     al, 0FFh
                jmp     word ptr cs:Draw_Bordered_Rectangle_proc
draw_dialog_overlay_background endp


; =============== S U B R O U T I N E =======================================


restore_dialog_overlay_background proc near
                mov     ax, 0C46h
                mov     cx, 1028h
                mov     di, 3C80h
                jmp     word ptr cs:Put_Image_proc
restore_dialog_overlay_background endp


; =============== S U B R O U T I N E =======================================


flush_console_input proc near 
                push    dx
loc_9CC:
                mov     dl, 0FFh
                mov     ah, 6
                int     21h             ; DOS - DIRECT CONSOLE I/O CHARACTER OUTPUT
                                        ; DL = character <> FFh
                                        ;  Return: ZF set = no character
                                        ;   ZF clear = character recieved, AL = character
                jnz     short loc_9CC
                pop     dx
                retn
flush_console_input endp


; =============== S U B R O U T I N E =======================================


Scan_Saved_Games proc near    
                push    ds
                mov     cs:scan_saved_games_buf_off, di
                mov     cs:scan_saved_games_buf_seg, es
                mov     cs:asciiz_filespec_off, dx
                mov     cs:asciiz_filespec_seg, ds
                mov     cx, 2806
                xor     al, al
                rep stosb
                mov     di, cs:scan_saved_games_buf_off
                mov     ax, di
                inc     di
                add     ax, 513
                mov     cx, 255

loc_A00:
                stosw
                add     ax, 9
                loop    loc_A00
                push    cs
                pop     ds
                mov     dx, offset dta_buffer
                mov     ah, 1Ah
                int     21h             ; DOS - SET DISK TRANSFER AREA ADDRESS
                                        ; DS:DX -> disk transfer buffer
                lds     dx, dword ptr cs:asciiz_filespec_off
                mov     cx, dx
                mov     ah, 4Eh
                int     21h             ; DOS - 2+ - FIND FIRST ASCIZ (FINDFIRST)
                                        ; CX = search attributes
                                        ; DS:DX -> ASCIZ filespec
                                        ; (drive, path, and wildcards allowed)
                jb      short loc_A4F
                push    cs
                pop     ds
                les     di, dword ptr cs:scan_saved_games_buf_off
                add     di, 513
                mov     cx, 254

loc_A2A:
                push    cx
                push    di
                mov     bx, cs:scan_saved_games_buf_off
                inc     byte ptr es:[bx]
                mov     si, offset filename_buf
                mov     cx, 8

loc_A3A:
                lodsb
                cmp     al, '.'
                jz      short loc_A42
                stosb
                loop    loc_A3A

loc_A42:
                pop     di
                pop     cx
                mov     ah, 4Fh
                int     21h             ; DOS - 2+ - FIND NEXT ASCIZ (FINDNEXT)
                                        ; [DTA] = data block from
                                        ; last AH = 4Eh/4Fh call
                jb      short loc_A4F
                add     di, 9
                loop    loc_A2A

loc_A4F:
                pop     ds
                retn
Scan_Saved_Games endp

; ---------------------------------------------------------------------------
scan_saved_games_buf_off dw 0
scan_saved_games_buf_seg dw 0
asciiz_filespec_off      dw 0
asciiz_filespec_seg      dw 0
dta_buffer               db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
filename_buf             db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; =============== S U B R O U T I N E =======================================

; DS:SI -> points to file descriptor
; ES:DI -> destination buffer to unpack
res_dispatcher  proc near     
                cmp     al, 0
                jnz     short loc_A8B
                jmp     fn0_swap_town_vs_cavern_gfx_drv_and_jmp_bx
; ---------------------------------------------------------------------------

loc_A8B:
                push    di
                push    si
                push    ds
                push    es
                mov     word ptr cs:packed_file_descriptor, si ; file descriptor (word, filename)
                mov     word ptr cs:packed_file_descriptor+2, ds
                mov     word ptr cs:virt_file_buffer, di ; unpack destination buffer
                mov     word ptr cs:virt_file_buffer+2, es
                pushf
                cld
                cmp     al, 7           ; fn
                jnb     short skip_unknown
                dec     al
                xor     cx, cx
                mov     cl, al
                mov     bp, cx
                add     bp, bp
                call    cs:func_selector[bp]

skip_unknown:                 
                pop     bx
                pushf
                pop     ax
                and     bx, 0FFFEh
                and     ax, 1
                or      ax, bx
                push    ax
                popf
                pop     es
                pop     ds
                pop     si
                pop     di
                retn
res_dispatcher  endp

; ---------------------------------------------------------------------------
func_selector   dw offset fn1_load_mdt_idx_ah ; ...
                dw offset fn2_segmented_load
                dw offset fn3_read_virtual_file ; load binary resource to dest buffer
                dw offset fn4_load_sword_graphics ; AH: sword id (0..6)
                dw offset fn5_load_music
                dw offset fn6_get_virtual_file_size

; =============== S U B R O U T I N E =======================================


fn1_load_mdt_idx_ah proc near 
                mov     word ptr cs:virt_file_buffer, mdt_buffer
                mov     word ptr cs:virt_file_buffer+2, cs
                mov     al, ah
                or      al, al
                jns     short loc_AEC
                and     al, 7Fh
                add     al, 32          ; towns start at idx 32

loc_AEC:
                mov     cl, 11          ; each VFS file descriptor is 11 bytes
                mul     cl
                add     ax, offset mp10_id
                mov     word ptr cs:packed_file_descriptor, ax
                mov     word ptr cs:packed_file_descriptor+2, cs
                jmp     fn3_read_virtual_file
fn1_load_mdt_idx_ah endp


; =============== S U B R O U T I N E =======================================


fn2_segmented_load proc near  

                les     di, cs:virt_file_buffer
                push    di
                push    es
                mov     word ptr cs:virt_file_buffer, 0
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     word ptr cs:virt_file_buffer+2, ax ; seg3
                call    read_vfile_size ; to virt_file_size_lo, virt_file_size_hi
                mov     bx, ax          ; handle
                mov     cx, 1           ; read 1 byte
                call    read_vfile_to_buffer  ; virt_file_buffer -> seg3:0
                mov     cx, cs:virt_file_size_lo
                dec     cx
                cmp     byte ptr es:0, 0 ; seg3:0
                jz      short loc_B5B    ; 1st byte is 0 => go straight to reading contents
                mov     word ptr cs:virt_file_buffer, 0
                mov     cx, 4
                call    read_vfile_to_buffer ; virt_file_buffer -> seg3:0
                mov     cx, es:0
                cmp     byte ptr cs:video_drv_id, 0  ; 0: ega
                jz      short loc_B5B   ; ega: read all the contents
                mov     dx, cx          ; otherwise, skip ega stuff
                mov     al, 1
                mov     cx, 0           ; 0:dx = bytes to seek
                mov     ah, 42h
                int     21h             ; DOS - 2+ - MOVE FILE READ/WRITE POINTER (LSEEK)
                                        ; AL = method: offset from present location
                                        ; CX:DX = bytes to seek
                mov     cx, es:2        ; seg3:2 -> bytes to read

loc_B5B:
                mov     word ptr cs:virt_file_buffer, 0
                call    read_vfile_to_buffer ; read the file contents to ds:dx, cx=bytes to read
                push    ax
                call    fclose
                pop     dx              ; dx = packed size
                pop     es
                pop     di
                jmp     unpack
fn2_segmented_load endp


; =============== S U B R O U T I N E =======================================

; AH: sword id (0..6)
fn4_load_sword_graphics proc near
                mov     bl, ah
                xor     bh, bh
                add     bx, bx
                mov     si, cs:sword_ptrs[bx]
                mov     ax, cs
                add     ax, 1000h
                mov     es, ax          ; seg1
                add     ax, 1000h
                mov     ds, ax          ; seg2
                mov     si, [si]        ; seg2:[180x]
                mov     di, sword_animation_gfx
                mov     cx, 800h
                rep movsw
                mov     di, sword_animation_gfx
                mov     cx, 0Fh
loc_B96:
                add     word ptr es:[di], sword_animation_gfx
                inc     di
                inc     di
                loop    loc_B96
                retn
fn4_load_sword_graphics endp

; ---------------------------------------------------------------------------
sword_ptrs      dw 1800h ; no sword
                dw 1800h ; training
                dw 1800h ; wise_mans
                dw 1800h ; spirit
                dw 1802h ; knight
                dw 1802h ; illumination
                dw 1804h ; enchantment

; =============== S U B R O U T I N E =======================================


fn5_load_music  proc near     
                les     di, cs:virt_file_buffer
                push    di
                push    es
                mov     word ptr cs:virt_file_buffer, 0
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     word ptr cs:virt_file_buffer+2, ax
                call    read_vfile_size
                mov     bx, ax
                mov     cx, 4
                call    read_vfile_to_buffer
                mov     cx, es:0
                test    byte ptr cs:mt32_enabled, 0FFh
                jnz     short loc_BEF
                mov     dx, cx
                mov     al, 1
                mov     cx, 0
                mov     ah, 42h
                int     21h             ; DOS - 2+ - MOVE FILE READ/WRITE POINTER (LSEEK)
                                        ; AL = method: offset from present location
                mov     cx, es:2

loc_BEF:
                pop     es
                pop     di
                mov     word ptr cs:virt_file_buffer, di
                mov     word ptr cs:virt_file_buffer+2, es
                call    read_vfile_to_buffer
                jmp     fclose
fn5_load_music  endp


; =============== S U B R O U T I N E =======================================


fn0_swap_town_vs_cavern_gfx_drv_and_jmp_bx proc near
                push    ds
                push    bx
                mov     ax, cs
                add     ax, 2000h
                mov     ds, ax          ; seg2
                push    cs
                pop     es
                mov     si, 9000h
                mov     di, 3000h       ; gtmcga/gfmcga driver address
                mov     cx, 3800h
loc_C15:
                lodsw
                mov     dx, es:[di]
                stosw
                mov     [si-2], dx
                loop    loc_C15
                pop     bx
                pop     ds
                jmp     word ptr cs:[bx]
fn0_swap_town_vs_cavern_gfx_drv_and_jmp_bx endp


; =============== S U B R O U T I N E =======================================


fn6_get_virtual_file_size proc near
                call    read_vfile_size
                jnb     short loc_C2A
                retn

loc_C2A:
                mov     bx, ax
                jmp     fclose
fn6_get_virtual_file_size endp


; =============== S U B R O U T I N E =======================================


fn3_read_virtual_file proc near
                call    read_vfile_size
                jnb     short loc_C35
                retn

loc_C35:
                mov     cx, cs:virt_file_size_lo
                mov     bx, ax          ; opened zelres file handle
                call    read_vfile_to_buffer
                jmp     fclose
fn3_read_virtual_file endp


; =============== S U B R O U T I N E =======================================


read_vfile_size proc near     

                mov     cs:virt_file_size_lo, 0FFFFh
                mov     cs:virt_file_size_hi, 0FFFFh
                lds     bx, cs:packed_file_descriptor
                mov     word ptr [bx], '\0'
                mov     dx, bx          ; points to real file path (='0\CRAB.BIN')
                push    cs
                pop     ds
                mov     ax, 3D00h
                int     21h             ; DOS - 2+ - OPEN DISK FILE WITH HANDLE
                                        ; DS:DX -> ASCIZ filename
                                        ; AL = access mode
                                        ; 0 - read
                jnb     short open_ok
                jmp     VFS_fatal_error_handler
open_ok:
                mov     byte ptr cs:spacebar_latch, 0
                push    ax           
                   
                mov     bx, ax          ; file handle
                xor     cx, cx
                xor     dx, dx
                mov     ah, 42h         ; LSEEK function
                mov     al, 2           ; Sub-function: Move to end of file
                int     21h             ; Call DOS
                                        ; On return:
                                        ; DX = High word of file size
                                        ; AX = Low word of file size
                jnb     short fsize_success
                jmp     VFS_fatal_error_handler
fsize_success:
                mov     ds:virt_file_size_lo, ax
                mov     ds:virt_file_size_hi, dx

                xor     cx, cx          ; High word of offset = 0
                xor     dx, dx          ; Low word of offset = 0
                mov     al, 0           ; fseek from beginning
                mov     ah, 42h
                int     21h             ; DOS - 2+ - MOVE FILE READ/WRITE POINTER (LSEEK)
                                        ; AL = method: offset from beginning of file
                jnb     short fseek_success
                jmp     VFS_fatal_error_handler
fseek_success:
                pop     ax              ; file handle
                retn
read_vfile_size endp


; =============== S U B R O U T I N E =======================================


read_vfile_to_buffer proc near

                lds     dx, cs:virt_file_buffer
                mov     ah, 3Fh
                int     21h             ; DOS - 2+ - READ FROM FILE WITH HANDLE
                                        ; BX = file handle, CX = number of bytes to read
                                        ; DS:DX -> buffer; ax -> bytes read
                jnb     short locret_D92
                jmp     VFS_fatal_error_handler

locret_D92:                   
                retn
read_vfile_to_buffer endp


; =============== S U B R O U T I N E =======================================


fclose          proc near     

                mov     ah, 3Eh
                int     21h             ; DOS - 2+ - CLOSE A FILE WITH HANDLE
                                        ; BX = file handle
                jnb     short locret_D9C
                jmp     VFS_fatal_error_handler

locret_D9C:                   
                retn
fclose          endp

; ---------------------------------------------------------------------------
; Input: packed file at seg3:0, DX = packed size
; Output: unpacked file at es:di, DI = end of unpacked data
unpack: 
                push    ds
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax          ; seg3
                mov     si, 0
                call    unpack_dispatcher ; unpack from seg3:0 to es:di
                pop     ds
                retn

; =============== S U B R O U T I N E =======================================


; Input: packed file at DS:SI, DX = packed size
; Output: unpacked file at es:di, DI = end of unpacked data
unpack_dispatcher proc near   

                xor     bx, bx
                lodsb                   ; 1st byte: compression method
                dec     dx              ; packed_bytes_left--
                and     al, 7
                mov     bl, al
                add     bx, bx          ; switch 8 cases
                jmp     cs:jpt_DB7[bx]  ; switch jump
unpack_dispatcher endp

; ---------------------------------------------------------------------------
jpt_DB7         dw offset fn0_raw_copy
                dw offset fn1_RLE_with_lookup_table_hi_nib
                dw offset fn2_RLE_with_inline_marker_hi_nib
                dw offset fn3_RLE_with_lookup_table_lo_nib
                dw offset fn4_RLE_with_inline_marker_lo_nib
                dw offset fn5_byte_pair_RLE
                dw offset fn6_RLE_with_word_sentinel_table
                dw offset fn7_three_byte_run_encoding
; ---------------------------------------------------------------------------

fn0_raw_copy:                 
                mov     cx, dx
                rep movsb
                retn    ; di -> end of unpacked data

; =============== S U B R O U T I N E =======================================


fn1_RLE_with_lookup_table_hi_nib proc near ; ...
                mov     bp, si
                call    scan_till_sentinel_ff

loc_DD6:
                lodsb
                call    RLE_with_lookup_table_hi_nib_step
                rep stosb
                dec     dx
                jnz     short loc_DD6
                retn
fn1_RLE_with_lookup_table_hi_nib endp


; =============== S U B R O U T I N E =======================================

; Input: BP: lookup table, AL: byte to look up
; Output: CX: count (input byte low nibble + 2), AL: byte to output
RLE_with_lookup_table_hi_nib_step proc near
                push    bp
                mov     ah, al
                and     ah, 0F0h
                mov     cx, 1   ; count = 1 (of original byte) if no match
loc_DE9:
                test    byte ptr ds:[bp+0], 0Fh  ; Key == 0xFF means end of table
                jnz     short loc_E06
                ; lookup_table[i].Key low nibble is always 0
                cmp     ah, ds:[bp+0]
                je      short high_nibbles_match
                inc     bp
                inc     bp
                jmp     short loc_DE9
high_nibbles_match:
                mov     cl, al
                mov     al, ds:[bp+1] ; lookup_table[i].Value
                and     cx, 0Fh
                add     cx, 2
loc_E06:
                pop     bp
                retn
RLE_with_lookup_table_hi_nib_step endp


; =============== S U B R O U T I N E =======================================


scan_till_sentinel_ff proc near
                lodsb
                dec     dx
                cmp     al, 0FFh
                jne     short loc_E0F
                retn

loc_E0F:
                inc     si
                dec     dx
                jmp     short scan_till_sentinel_ff
scan_till_sentinel_ff endp

; ---------------------------------------------------------------------------

fn2_RLE_with_inline_marker_hi_nib:
                lodsb
                dec     dx
                mov     ah, al

loc_E17:
                lodsb
                mov     cx, 1
                mov     bl, al
                and     bl, 0F0h
                cmp     bl, ah
                jne     short loc_E2E
                mov     cl, al
                and     cx, 0Fh
                add     cx, 3
                lodsb
                dec     dx

loc_E2E:
                rep stosb
                dec     dx
                jnz     short loc_E17
                retn
; ---------------------------------------------------------------------------

fn3_RLE_with_lookup_table_lo_nib:
                mov     bp, si
                call    scan_till_sentinel_ff

loc_E39:
                lodsb
                call    RLE_with_lookup_table_lo_nib_step
                rep stosb
                dec     dx
                jnz     short loc_E39
                retn

; =============== S U B R O U T I N E =======================================


; Input: BP: lookup table, AL: byte to look up
; Output: CX: count (input byte high nibble + 2), AL: byte to output
RLE_with_lookup_table_lo_nib_step proc near
                push    bp
                mov     ah, al
                and     ah, 0Fh
                mov     cx, 1
loc_E4C:
                test    byte ptr ds:[bp+0], 0F0h
                jnz     short loc_E71
                cmp     ah, ds:[bp+0]
                je      short low_nibbles_match
                inc     bp
                inc     bp
                jmp     short loc_E4C
low_nibbles_match:
                shr     al, 1
                shr     al, 1
                shr     al, 1
                shr     al, 1
                mov     cl, al
                mov     al, ds:[bp+1] ; lookup_table[i].Value
                and     cx, 0Fh
                add     cx, 2

loc_E71:
                pop     bp
                retn
RLE_with_lookup_table_lo_nib_step endp

; ---------------------------------------------------------------------------

fn4_RLE_with_inline_marker_lo_nib:
                lodsb
                dec     dx
                mov     ah, al

loc_E77:
                lodsb
                mov     cx, 1
                mov     bl, al
                and     bl, 0Fh
                cmp     bl, ah
                jnz     short loc_E96
                shr     al, 1
                shr     al, 1
                shr     al, 1
                shr     al, 1
                mov     cl, al
                and     cx, 0Fh
                add     cx, 3
                lodsb
                dec     dx

loc_E96:
                rep stosb
                dec     dx
                jnz     short loc_E77
                retn
; ---------------------------------------------------------------------------

fn5_byte_pair_RLE:            
                lodsb
                mov     cx, 1
                cmp     [si], al
                jne     short loc_EB4
                mov     cl, [si+1]
                and     cx, 0FFh
                add     cx, 2
                add     si, 2
                sub     dx, 2

loc_EB4:
                rep stosb
                dec     dx
                jnz     short fn5_byte_pair_RLE
                retn
; ---------------------------------------------------------------------------

fn6_RLE_with_word_sentinel_table:
                mov     bp, si
loc_EBC:
                lodsw
                sub     dx, 2
                cmp     ax, 0FFFFh
                jnz     short loc_EBC
loc_EC5:
                lodsb
                call    lookup_byte_read_count
                rep stosb
                dec     dx
                jnz     short loc_EC5
                retn

; =============== S U B R O U T I N E =======================================


lookup_byte_read_count proc near        ; ...
                push    bp
                mov     cx, 1
loc_ED3:
                cmp     word ptr ds:[bp+0], 0FFFFh
                jz      short ffff_sentinel_reached
                cmp     al, ds:[bp+0]   ; lookup_table[i].Key
                je      short bytes_match
                inc     bp
                inc     bp
                jmp     short loc_ED3
bytes_match:
                lodsb
                dec     dx
                mov     cl, al
                mov     al, ds:[bp+1]
                and     cx, 0FFh
                add     cx, 2
ffff_sentinel_reached:        
                pop     bp
                retn
lookup_byte_read_count endp

; ---------------------------------------------------------------------------

fn7_three_byte_run_encoding:  
                lodsb
                dec     dx
                mov     ah, al
do_while_dx:
                lodsb
                mov     cx, 1
                cmp     al, ah
                jne     short loc_F11
                lodsb           ; al = value
                mov     cl, al  ; cl = value
                lodsb
                xchg    al, cl  ; cl = count, al = value
                and     cx, 0FFh
                add     cx, 3
                sub     dx, 2
loc_F11:
                rep stosb
                dec     dx
                jnz     short do_while_dx
                retn
; ---------------------------------------------------------------------------

reserved_nop:                 
                retn

; =============== S U B R O U T I N E =======================================


Quiet_Critical_Error_Handler proc far
                sti
                push    ax
                push    bx
                push    cx
                push    dx
                push    di
                push    si
                push    bp
                push    ds
                push    es
                push    di
                pop     ax
                or      al, al
                js      short loc_F2C
                cmp     al, 2
                jz      short loc_F38

loc_F2C:
                pop     es
                pop     ds
                pop     bp
                pop     si
                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                xor     al, al
                iret

loc_F38:
                mov     cs:disk_retry_timer, 0

loc_F3E:
                cmp     cs:disk_retry_timer, 0F0h
                jb      short loc_F3E
                pop     es
                pop     ds
                pop     bp
                pop     si
                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                mov     al, 1
                iret
Quiet_Critical_Error_Handler endp

; ---------------------------------------------------------------------------

VFS_fatal_error_handler:      
                lds     dx, cs:packed_file_descriptor
                jmp     dword ptr cs:fn_exit_far_ptr
; ---------------------------------------------------------------------------
packed_file_descriptor dd 0   
virt_file_buffer       dd 0         
virt_file_size_lo      dw 0        
virt_file_size_hi      dw 0        
mp10_id         db 2          
                db 15h
aMp10Mdt        db 'MP10.MDT',0         ; 0
                dw 1602h
aMp1dMdt        db 'MP1D.MDT',0         ; 1
                dw 1702h
aMp20Mdt        db 'MP20.MDT',0         ; 2
                dw 1802h
aMp21Mdt        db 'MP21.MDT',0         ; 3
                dw 1902h
aMp2dMdt        db 'MP2D.MDT',0         ; 4
                dw 1A02h
aMp30Mdt        db 'MP30.MDT',0         ; 5
                dw 1B02h
aMp31Mdt        db 'MP31.MDT',0         ; 6
                dw 1C02h
aMp3dMdt        db 'MP3D.MDT',0         ; 7
                dw 1D02h
aMp40Mdt        db 'MP40.MDT',0         ; 8
                dw 1E02h
aMp41Mdt        db 'MP41.MDT',0         ; 9
                dw 1F02h
aMp4dMdt        db 'MP4D.MDT',0         ; 10
                dw 2002h
aMp50Mdt        db 'MP50.MDT',0         ; 11
                dw 2102h
aMp51Mdt        db 'MP51.MDT',0         ; 12
                dw 2202h
aMp5dMdt        db 'MP5D.MDT',0         ; 13
                dw 2302h
aMp60Mdt        db 'MP60.MDT',0         ; 14
                dw 2402h
aMp61Mdt        db 'MP61.MDT',0         ; 15
                dw 2502h
aMp62Mdt        db 'MP62.MDT',0         ; 16
                dw 2602h
aMp6dMdt        db 'MP6D.MDT',0         ; 17
                dw 2702h
aMp70Mdt        db 'MP70.MDT',0         ; 18
                dw 2802h
aMp71Mdt        db 'MP71.MDT',0         ; 19
                dw 2902h
aMp72Mdt        db 'MP72.MDT',0         ; 20
                dw 2A02h
aMp73Mdt        db 'MP73.MDT',0         ; 21
                dw 2B02h
aMp7dMdt        db 'MP7D.MDT',0         ; 22
                dw 2C02h
aMp80Mdt        db 'MP80.MDT',0         ; 23
                dw 2D02h
aMp81Mdt        db 'MP81.MDT',0         ; 24
                dw 2E02h
aMp82Mdt        db 'MP82.MDT',0         ; 25
                dw 2F02h
aMp83Mdt        db 'MP83.MDT',0         ; 26
                dw 3002h
aMp84Mdt        db 'MP84.MDT',0         ; 27
                dw 3102h
aMp8dMdt        db 'MP8D.MDT',0         ; 28
                dw 3202h
aMp90Mdt        db 'MP90.MDT',0         ; 29
                dw 3302h
aMpa0Mdt        db 'MPA0.MDT',0         ; 30
                db    1
                db    0
                db '        ',0         ; 31
                db    1
                db  25h ; %
aCmapMdt        db 'CMAP.MDT',0         ; 32
                db    1
                db  26h ; &
aMrmpMdt        db 'MRMP.MDT',0         ; 33
                db    1
                db  27h ; '
aStmpMdt        db 'STMP.MDT',0         ; 34
                db    1
                db  28h ; (
aBsmpMdt        db 'BSMP.MDT',0         ; 35
                db    1
                db  29h ; )
aHlmpMdt        db 'HLMP.MDT',0         ; 36
                db    1
                db  2Ah ; *
aTmmpMdt        db 'TMMP.MDT',0         ; 37
                db    1
                db  2Bh ; +
aDrmpMdt        db 'DRMP.MDT',0         ; 38
                db    1
                db  2Ch ; ,
aLlmpMdt        db 'LLMP.MDT',0         ; 39
                db    1
                db  2Dh ; -
aPrmpMdt        db 'PRMP.MDT',0         ; 40
                db    1
                db  2Eh ; .
aEsmpMdt        db 'ESMP.MDT',0         ; 41
stick           ends

                end     start
