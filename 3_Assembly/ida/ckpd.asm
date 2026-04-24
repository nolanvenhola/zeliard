include common.inc
                .286
                .model tiny

ckpd            segment byte public 'CODE'
                assume cs:ckpd, ds:ckpd

; I added this startup code to make it standalone .com file
; It shows the extracted bitmaps exactly as in Zeliard
                ;org     100h
start:
COMMENT #
                mov     ax, 13h
                int     10h         ; set video mode

                mov ax, 1012h
                xor bx, bx          ; Start at index 0
                mov cx, 256         ; Update all 256 colors
                mov dx, offset palette
                push cs
                pop es
                int 10h             ; set palette

                mov     al, 4       ; this is how exactly Zeliard calls sub_3300
                call    sub_3300
wait_for_esc:   in      al, 60h
                dec     al
                jnz     short wait_for_esc
                mov     ax, 3
                int     10h
                retn

; this is standard Zeliard MCGA palette
palette:
db  00h, 00h, 00h, 1Fh, 1Fh, 1Fh, 1Fh, 00h, 00h, 00h, 1Fh, 00h, 00h, 1Fh, 1Fh, 00h, 00h, 1Fh, 1Fh, 1Fh, 00h, 1Fh, 00h, 1Fh
db  1Fh, 1Fh, 1Fh, 3Eh, 3Eh, 3Eh, 3Eh, 1Fh, 1Fh, 1Fh, 3Eh, 1Fh, 1Fh, 3Eh, 3Eh, 1Fh, 1Fh, 3Eh, 3Eh, 3Eh, 1Fh, 3Eh, 1Fh, 3Eh
db  1Fh, 00h, 00h, 3Eh, 1Fh, 1Fh, 3Eh, 00h, 00h, 1Fh, 1Fh, 00h, 1Fh, 1Fh, 1Fh, 1Fh, 00h, 1Fh, 3Eh, 1Fh, 00h, 3Eh, 00h, 1Fh
db  00h, 1Fh, 00h, 1Fh, 3Eh, 1Fh, 1Fh, 1Fh, 00h, 00h, 3Eh, 00h, 00h, 3Eh, 1Fh, 00h, 1Fh, 1Fh, 1Fh, 3Eh, 00h, 1Fh, 1Fh, 1Fh
db  00h, 1Fh, 1Fh, 1Fh, 3Eh, 3Eh, 1Fh, 1Fh, 1Fh, 00h, 3Eh, 1Fh, 00h, 3Eh, 3Eh, 00h, 1Fh, 3Eh, 1Fh, 3Eh, 1Fh, 1Fh, 1Fh, 3Eh
db  00h, 00h, 1Fh, 1Fh, 1Fh, 3Eh, 1Fh, 00h, 1Fh, 00h, 1Fh, 1Fh, 00h, 1Fh, 3Eh, 00h, 00h, 3Eh, 1Fh, 1Fh, 1Fh, 1Fh, 00h, 3Eh
db  1Fh, 1Fh, 00h, 3Eh, 3Eh, 1Fh, 3Eh, 1Fh, 00h, 1Fh, 3Eh, 00h, 1Fh, 3Eh, 1Fh, 1Fh, 1Fh, 1Fh, 3Eh, 3Eh, 00h, 3Eh, 1Fh, 1Fh
db  1Fh, 00h, 1Fh, 3Eh, 1Fh, 3Eh, 3Eh, 00h, 1Fh, 1Fh, 1Fh, 1Fh, 1Fh, 1Fh, 3Eh, 1Fh, 00h, 3Eh, 3Eh, 1Fh, 1Fh, 3Eh, 00h, 3Eh
db  3Fh, 1Fh, 1Fh, 3Fh, 27h, 1Fh, 3Fh, 2Fh, 1Fh, 3Fh, 37h, 1Fh, 3Fh, 3Fh, 1Fh, 37h, 3Fh, 1Fh, 2Fh, 3Fh, 1Fh, 27h, 3Fh, 1Fh
db  1Fh, 3Fh, 1Fh, 1Fh, 3Fh, 27h, 1Fh, 3Fh, 2Fh, 1Fh, 3Fh, 37h, 1Fh, 3Fh, 3Fh, 1Fh, 37h, 3Fh, 1Fh, 2Fh, 3Fh, 1Fh, 27h, 3Fh
db  2Dh, 2Dh, 3Fh, 31h, 2Dh, 3Fh, 36h, 2Dh, 3Fh, 3Ah, 2Dh, 3Fh, 3Fh, 2Dh, 3Fh, 3Fh, 2Dh, 3Ah, 3Fh, 2Dh, 36h, 3Fh, 2Dh, 31h
db  3Fh, 2Dh, 2Dh, 3Fh, 31h, 2Dh, 3Fh, 36h, 2Dh, 3Fh, 3Ah, 2Dh, 3Fh, 3Fh, 2Dh, 3Ah, 3Fh, 2Dh, 36h, 3Fh, 2Dh, 31h, 3Fh, 2Dh
db  2Dh, 3Fh, 2Dh, 2Dh, 3Fh, 31h, 2Dh, 3Fh, 36h, 2Dh, 3Fh, 3Ah, 2Dh, 3Fh, 3Fh, 2Dh, 3Ah, 3Fh, 2Dh, 36h, 3Fh, 2Dh, 31h, 3Fh
db  00h, 00h, 1Ch, 07h, 00h, 1Ch, 0Eh, 00h, 1Ch, 15h, 00h, 1Ch, 1Ch, 00h, 1Ch, 1Ch, 00h, 15h, 1Ch, 00h, 0Eh, 1Ch, 00h, 07h
db  1Ch, 00h, 00h, 1Ch, 07h, 00h, 1Ch, 0Eh, 00h, 1Ch, 15h, 00h, 1Ch, 1Ch, 00h, 15h, 1Ch, 00h, 0Eh, 1Ch, 00h, 07h, 1Ch, 00h
db  00h, 1Ch, 00h, 00h, 1Ch, 07h, 00h, 1Ch, 0Eh, 00h, 1Ch, 15h, 00h, 1Ch, 1Ch, 00h, 15h, 1Ch, 00h, 0Eh, 1Ch, 00h, 07h, 1Ch
db  0Eh, 0Eh, 1Ch, 11h, 0Eh, 1Ch, 15h, 0Eh, 1Ch, 18h, 0Eh, 1Ch, 1Ch, 0Eh, 1Ch, 1Ch, 0Eh, 18h, 1Ch, 0Eh, 15h, 1Ch, 0Eh, 11h
db  1Ch, 0Eh, 0Eh, 1Ch, 11h, 0Eh, 1Ch, 15h, 0Eh, 1Ch, 18h, 0Eh, 1Ch, 1Ch, 0Eh, 18h, 1Ch, 0Eh, 15h, 1Ch, 0Eh, 11h, 1Ch, 0Eh
db  0Eh, 1Ch, 0Eh, 0Eh, 1Ch, 11h, 0Eh, 1Ch, 15h, 0Eh, 1Ch, 18h, 0Eh, 1Ch, 1Ch, 0Eh, 18h, 1Ch, 0Eh, 15h, 1Ch, 0Eh, 11h, 1Ch
db  14h, 14h, 1Ch, 16h, 14h, 1Ch, 18h, 14h, 1Ch, 1Ah, 14h, 1Ch, 1Ch, 14h, 1Ch, 1Ch, 14h, 1Ah, 1Ch, 14h, 18h, 1Ch, 14h, 16h
db  1Ch, 14h, 14h, 1Ch, 16h, 14h, 1Ch, 18h, 14h, 1Ch, 1Ah, 14h, 1Ch, 1Ch, 14h, 1Ah, 1Ch, 14h, 18h, 1Ch, 14h, 16h, 1Ch, 14h
db  14h, 1Ch, 14h, 14h, 1Ch, 16h, 14h, 1Ch, 18h, 14h, 1Ch, 1Ah, 14h, 1Ch, 1Ch, 14h, 1Ah, 1Ch, 14h, 18h, 1Ch, 14h, 16h, 1Ch
db  00h, 00h, 10h, 04h, 00h, 10h, 08h, 00h, 10h, 0Ch, 00h, 10h, 10h, 00h, 10h, 10h, 00h, 0Ch, 10h, 00h, 08h, 10h, 00h, 04h
db  10h, 00h, 00h, 10h, 04h, 00h, 10h, 08h, 00h, 10h, 0Ch, 00h, 10h, 10h, 00h, 0Ch, 10h, 00h, 08h, 10h, 00h, 04h, 10h, 00h
db  00h, 10h, 00h, 00h, 10h, 04h, 00h, 10h, 08h, 00h, 10h, 0Ch, 00h, 10h, 10h, 00h, 0Ch, 10h, 00h, 08h, 10h, 00h, 04h, 10h
db  08h, 08h, 10h, 0Ah, 08h, 10h, 0Ch, 08h, 10h, 0Eh, 08h, 10h, 10h, 08h, 10h, 10h, 08h, 0Eh, 10h, 08h, 0Ch, 10h, 08h, 0Ah
db  10h, 08h, 08h, 10h, 0Ah, 08h, 10h, 0Ch, 08h, 10h, 0Eh, 08h, 10h, 10h, 08h, 0Eh, 10h, 08h, 0Ch, 10h, 08h, 0Ah, 10h, 08h
db  08h, 10h, 08h, 08h, 10h, 0Ah, 08h, 10h, 0Ch, 08h, 10h, 0Eh, 08h, 10h, 10h, 08h, 0Eh, 10h, 08h, 0Ch, 10h, 08h, 0Ah, 10h
db  0Bh, 0Bh, 10h, 0Ch, 0Bh, 10h, 0Dh, 0Bh, 10h, 0Fh, 0Bh, 10h, 10h, 0Bh, 10h, 10h, 0Bh, 0Fh, 10h, 0Bh, 0Dh, 10h, 0Bh, 0Ch
db  10h, 0Bh, 0Bh, 10h, 0Ch, 0Bh, 10h, 0Dh, 0Bh, 10h, 0Fh, 0Bh, 10h, 10h, 0Bh, 0Fh, 10h, 0Bh, 0Dh, 10h, 0Bh, 0Ch, 10h, 0Bh
db  0Bh, 10h, 0Bh, 0Bh, 10h, 0Ch, 0Bh, 10h, 0Dh, 0Bh, 10h, 0Fh, 0Bh, 10h, 10h, 0Bh, 0Fh, 10h, 0Bh, 0Dh, 10h, 0Bh, 0Ch, 10h
db  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
#

; Original ypmd.bin source code starts here
                org 3300h

sub_3300        proc far
                mov     cs:video_mode, al
                mov     dx, cs
                mov     ds, dx
                add     dx, 1000h
                mov     es, dx          ; seg1
                cld
                mov     di, 0
                mov     cx, 0FC0h
                xor     ax, ax
                rep stosw
                mov     dx, cs
                add     dx, 1000h
                mov     es, dx          ; seg1
                mov     di, 0
                mov     si, offset stalactites0
                call    sub_3664
                mov     di, 0FC0h
                mov     si, offset stalactites1
                call    sub_3664
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx          ; seg1
                mov     si, 0
                mov     bp, 0FC0h
                mov     bx, 0C1Eh
                mov     cx, 3848h
                call    render_something
                pop     ds
                ; stalactites rendered. Now the ground
                mov     byte_3694, 28   ; C6 06 94 36 1C
                mov     dx, cs
                add     dx, 1000h
                mov     es, dx          ; seg1
                mov     di, 0           ; ceiling0
                mov     si, offset byte_4C6D
                call    sub_3664
                mov     di, 1C0h       ; ceiling1
                mov     si, offset byte_4DB8
                call    sub_3664
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx          ; seg1
                mov     si, 0           ; 
                mov     bp, 1C0h        ; BP = offset of second table
                mov     bx, 0C0Eh       ; BH = x in 4px units, BL = y
                mov     cx, 1C10h       ; CH = hsize in 4px units, CL = vsize
                call    render_something ; fn m4_mcga
                pop     ds
                call    sub_3389
                retf
sub_3300        endp

; ---------------------------------------------------------------------------
video_mode      db 0

; =============== S U B R O U T I N E =======================================


sub_3389        proc near               ; ...

                xor     bx, bx
                mov     bl, video_mode
                add     bx, bx          ; switch 6 cases
                jmp     jpt_3391[bx]    ; switch jump
sub_3389        endp

; ---------------------------------------------------------------------------
jpt_3391        dw offset loc_33A1
                dw offset loc_3412
                dw offset loc_3412
                dw offset sub_34A7
                dw offset mode4_mcga
                dw offset loc_35C2
; ---------------------------------------------------------------------------

loc_33A1:
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     dx, 3C4h
                mov     ax, 702h
                out     dx, ax          ; EGA: sequencer address reg

                mov     dx, 3CEh
                mov     ax, 105h
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:

                mov     si, 46Ch
                mov     di, 488h
                mov     ah, 10h

loc_33BF:                               ; ...
                mov     cx, 1Ch
                rep movsb
                add     si, 34h ; '4'
                add     di, 34h ; '4'
                dec     ah
                jnz     short loc_33BF
                mov     dx, 3CEh
                mov     ax, 5
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; mode register.Data bits:
                                        ; 0-1: Write mode 0-2
                                        ; 2: test condition
                                        ; 3: read mode: 1=color compare, 0=direct
                                        ; 4: 1=use odd/even RAM addressing
                                        ; 5: 1=use CGA mid-res map (2-bits/pixel)
                pop     ds
                xor     si, si
                mov     di, 2C6Ch
                mov     dx, 3C4h
                mov     al, 2
                out     dx, al          ; EGA: sequencer address reg
                                        ; map mask: data bits 0-3 enable writes to bit planes 0-3
                inc     dx
                mov     cx, 10h

loc_33E5:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_33EA:                               ; ...
                mov     al, 2
                out     dx, al          ; EGA port: sequencer data register
                mov     al, [si+4F25h]
                mov     es:[di], al
                mov     es:[di+1Ch], al
                mov     al, 4
                out     dx, al          ; EGA port: sequencer data register
                mov     al, [si+50E5h]
                mov     es:[di], al
                mov     es:[di+1Ch], al
                inc     di
                inc     si
                loop    loc_33EA
                pop     di
                add     di, 50h ; 'P'
                pop     cx
                loop    loc_33E5
                retn
; ---------------------------------------------------------------------------

loc_3412:
                push    ds
                mov     ax, 0B800h
                mov     es, ax
                mov     ds, ax
                mov     si, 23Ch
                mov     ah, 10h

loc_341F:                               ; ...
                push    si
                mov     di, si
                add     di, 1Ch
                mov     cx, 0Eh
                rep movsw
                pop     si
                add     si, 2000h
                cmp     si, 4000h
                jb      short loc_3439
                add     si, 0C050h

loc_3439:                               ; ...
                dec     ah
                jnz     short loc_341F
                pop     ds
                xor     si, si
                mov     di, 163Ch
                mov     cx, 10h

loc_3446:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_344B:                               ; ...
                push    cx
                mov     ah, [si+50E5h]
                mov     al, [si+4F25h]
                inc     si
                xor     dl, dl
                mov     cx, 4

loc_345A:                               ; ...
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     dl, dl
                add     dl, dl
                or      dl, byte_3497[bx]
                loop    loc_345A
                mov     es:[di], dl
                mov     es:[di+1Ch], dl
                inc     di
                pop     cx
                loop    loc_344B
                pop     di
                add     di, 2000h
                cmp     di, 4000h
                jb      short loc_3493
                add     di, 0C050h

loc_3493:                               ; ...
                pop     cx
                loop    loc_3446
                retn
; ---------------------------------------------------------------------------
byte_3497       db  0, 2, 3, 1, 0, 3, 2, 1, 0, 2, 3, 1, 0, 2, 3, 1

; =============== S U B R O U T I N E =======================================


sub_34A7        proc near               ; ...
                push    ds
                mov     ax, 0B000h
                mov     es, ax
                mov     ds, ax
                mov     si, 4FDh
                mov     ah, 10h

loc_34B4:                               ; ...
                call    sub_353B
                add     si, 2000h
                cmp     si, 6000h
                jb      short loc_34C8
                call    sub_353B
                add     si, 0A05Ah

loc_34C8:                               ; ...
                dec     ah
                jnz     short loc_34B4
                pop     ds
                xor     si, si
                mov     di, 53C1h
                mov     cx, 10h

loc_34D5:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_34DA:                               ; ...
                push    cx
                mov     ah, [si+50E5h]
                mov     al, [si+4F25h]
                inc     si
                xor     dl, dl
                mov     cx, 4

loc_34E9:                               ; ...
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     dl, dl
                add     dl, dl
                or      dl, byte_3497[bx]
                loop    loc_34E9
                mov     es:[di], dl
                mov     es:[di+1Ch], dl
                inc     di
                pop     cx
                loop    loc_34DA
                pop     di
                add     di, 2000h
                cmp     di, 6000h
                jb      short loc_3537
                push    ds
                push    si
                push    cx
                push    di
                push    es
                pop     ds
                mov     si, di
                sub     si, 2000h
                mov     cx, 38h ; '8'
                rep movsb
                pop     di
                pop     cx
                pop     si
                pop     ds
                add     di, 0A05Ah

loc_3537:                               ; ...
                pop     cx
                loop    loc_34D5
                retn
sub_34A7        endp


; =============== S U B R O U T I N E =======================================


sub_353B        proc near               ; ...
                push    si
                mov     di, si
                add     di, 28
                mov     cx, 14
                rep movsw
                pop     si
                retn
sub_353B        endp

; ---------------------------------------------------------------------------

mode4_mcga:
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     si, viewport_top_left_vram_addr
                mov     di, 1220h
                mov     ah, 16

loc_3558:
                mov     cx, 56
                rep movsw
                add     si, 0D0h
                add     di, 0D0h
                dec     ah
                jnz     short loc_3558
                pop     ds
                xor     si, si
                mov     di, 0B1B0h
                mov     cx, 16

loc_3572:                               ; ...
                push    cx
                push    di
                mov     cx, 28

loc_3577:                               ; ...
                mov     dl, byte_4F25[si]
                mov     dh, byte_50E5[si]
                call    sub_35AB
                stosb
                mov     es:[di+112-1], al
                call    sub_35AB
                stosb
                mov     es:[di+112-1], al
                call    sub_35AB
                stosb
                mov     es:[di+112-1], al
                call    sub_35AB
                stosb
                mov     es:[di+112-1], al
                inc     si
                loop    loc_3577
                pop     di
                add     di, 320
                pop     cx
                loop    loc_3572
                retn

; =============== S U B R O U T I N E =======================================


sub_35AB        proc near               ; ...
                xor     al, al
                add     dh, dh
                adc     al, al
                add     dl, dl
                adc     al, al
                add     al, al
                add     dh, dh
                adc     al, al
                add     dl, dl
                adc     al, al
                add     al, al
                retn
sub_35AB        endp

; ---------------------------------------------------------------------------

loc_35C2:
                push    ds
                mov     ax, 0B800h
                mov     es, ax
                mov     ds, ax
                mov     si, 41F8h
                mov     ah, 10h

loc_35CF:                               ; ...
                push    si
                mov     di, si
                add     di, 38h ; '8'
                mov     cx, 1Ch
                rep movsw
                pop     si
                add     si, 2000h
                cmp     si, 8000h
                jb      short loc_35E9
                add     si, 80A0h

loc_35E9:                               ; ...
                dec     ah
                jnz     short loc_35CF
                pop     ds
                xor     si, si
                mov     di, 55F8h
                mov     cx, 10h

loc_35F6:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_35FB:                               ; ...
                push    cx
                mov     dh, [si+50E5h]
                mov     dl, [si+4F25h]
                call    sub_362B
                mov     es:[di+38h], al
                stosb
                call    sub_362B
                mov     es:[di+38h], al
                stosb
                inc     si
                pop     cx
                loop    loc_35FB
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_3627
                add     di, 80A0h

loc_3627:                               ; ...
                pop     cx
                loop    loc_35F6
                retn

; =============== S U B R O U T I N E =======================================


sub_362B        proc near               ; ...
                xor     al, al
                mov     cx, 2

loc_3630:                               ; ...
                add     dh, dh
                adc     bl, bl
                add     dl, dl
                adc     bl, bl
                add     dh, dh
                adc     bl, bl
                add     dl, dl
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     al, al
                add     al, al
                add     al, al
                add     al, al
                or      al, byte_3654[bx]
                loop    loc_3630
                retn
sub_362B        endp

; ---------------------------------------------------------------------------
byte_3654       db 0, 4, 3, 2, 4, 0Ch, 5, 6, 3, 5, 0Bh, 0Ah, 2, 6, 0Ah, 0Eh

; =============== S U B R O U T I N E =======================================


sub_3664        proc near               ; ...
                mov     bx, di

loc_3666:                               ; ...
                lodsb
                or      al, al
                jnz     short loc_366C
                retn
; ---------------------------------------------------------------------------

loc_366C:                               ; ...
                mov     ah, al
                and     ah, 0F0h
                cmp     ah, 10h
                jnz     short loc_367E
                and     al, 0Fh
                mov     ah, al
                xor     al, al
                jmp     short loc_368D
; ---------------------------------------------------------------------------

loc_367E:                               ; ...
                cmp     ah, 40h ; '@'
                jnz     short loc_368B
                and     al, 0Fh
                mov     ah, al
                mov     al, 0AAh
                jmp     short loc_368D
; ---------------------------------------------------------------------------

loc_368B:                               ; ...
                mov     ah, 1

loc_368D:                               ; ...
                stosb
                dec     ah
                jnz     short loc_368D
                jmp     short loc_3666
sub_3664        endp

; ---------------------------------------------------------------------------
byte_3694       db      56

; =============== S U B R O U T I N E =======================================


render_something        proc near               ; ...

                xor     ax, ax
                mov     al, cs:video_mode
                add     ax, ax           ; switch 6 cases
                add     ax, offset jpt_36A2
                mov     di, ax
                jmp     word ptr cs:[di] ; switch jump
render_something        endp

; ---------------------------------------------------------------------------
jpt_36A2        dw offset m0_ega      ; EGA or VGA planar
                dw offset m1_2_cga    ; CGA or Tandy
                dw offset m1_2_cga
                dw offset m3_hgc      ; Hercules
                dw offset m4_mcga     ; MCGA: video_mode=4
                dw offset m5_cga_alt
; ---------------------------------------------------------------------------

m0_ega:
                mov     ax, 50h ; 'P'
                mul     bl
                mov     bl, bh
                xor     bh, bh
                add     ax, bx
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     dx, 3C4h
                mov     al, 2
                out     dx, al          ; EGA: sequencer address reg
                                        ; map mask: data bits 0-3 enable writes to bit planes 0-3
                inc     dx
                mov     bx, cx

loc_36CC:                               ; ...
                push    di

loc_36CD:                               ; ...
                mov     al, 1
                out     dx, al          ; EGA port: sequencer data register
                mov     ah, ds:[bp+si]
                movsb
                mov     al, 4
                out     dx, al          ; EGA port: sequencer data register
                mov     es:[di-1], ah
                dec     bh
                jnz     short loc_36CD
                pop     di
                add     di, 50h ; 'P'
                mov     bh, ch
                dec     bl
                jnz     short loc_36CC
                retn
; ---------------------------------------------------------------------------

m1_2_cga:                               ; ...
                mov     ax, 50h ; 'P'   ; jumptable 000036A2 cases 1,2
                shr     bl, 1
                sbb     dx, dx
                mul     bl
                and     dx, 2000h
                add     ax, dx
                mov     bl, bh
                xor     bh, bh
                add     ax, bx
                mov     di, ax
                mov     ax, 0B800h
                mov     es, ax
                mov     bx, cx

loc_3708:                               ; ...
                push    di
                push    cx

loc_370A:                               ; ...
                push    bx
                mov     ah, ds:[bp+si]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_3714:                               ; ...
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     dl, dl
                add     dl, dl
                or      dl, cs:byte_3753[bx]
                loop    loc_3714
                mov     al, dl
                stosb
                pop     bx
                dec     bh
                jnz     short loc_370A
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 4000h
                jb      short loc_374C
                add     di, 0C050h

loc_374C:                               ; ...
                mov     bh, ch
                dec     bl
                jnz     short loc_3708
                retn
; ---------------------------------------------------------------------------
byte_3753       db 0, 3, 2, 1, 1, 3, 2, 1, 0, 3, 2, 1, 1, 3, 2, 1 ; ...
; ---------------------------------------------------------------------------

m3_hgc:                               ; ...
                xor     ax, ax          ; jumptable 000036A2 case 3
                mov     al, bl
                add     ax, 1Ch
                mov     dl, 3
                div     dl
                mov     dh, ah
                ror     dh, 1
                ror     dh, 1
                ror     dh, 1
                mov     ah, 5Ah ; 'Z'
                mul     ah
                and     dx, 6000h
                add     ax, dx
                add     bh, 5
                mov     bl, bh
                xor     bh, bh
                add     ax, bx
                mov     di, ax
                mov     ax, 0B000h
                mov     es, ax
                mov     bx, cx

loc_3792:                               ; ...
                push    di
                push    cx

loc_3794:                               ; ...
                push    bx
                mov     ah, ds:[bp+si]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_379E:                               ; ...
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                add     ah, ah
                adc     bl, bl
                add     al, al
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     dl, dl
                add     dl, dl
                or      dl, cs:byte_3753[bx]
                loop    loc_379E
                mov     al, dl
                stosb
                pop     bx
                dec     bh
                jnz     short loc_3794
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 6000h
                jb      short loc_37EC
                push    ds
                push    si
                push    cx
                push    di
                push    es
                pop     ds
                mov     si, di
                sub     si, 2000h
                mov     cl, ch
                xor     ch, ch
                rep movsb
                pop     di
                pop     cx
                pop     si
                pop     ds
                add     di, 0A05Ah

loc_37EC:                               ; ...
                mov     bh, ch
                dec     bl
                jnz     short loc_3792
                retn
; ---------------------------------------------------------------------------
; Input:
; BP = offset of second table
; BH = x in 4px units
; BL = y
; CH = hsize in 4px units
; CL = vsize
m4_mcga:
                xor     dx, dx
                mov     dl, bh
                mov     bh, dh
                push    dx
                mov     ax, 320
                mul     bx              ; ax = y*320
                pop     dx
                add     dx, dx
                add     dx, dx          ; bh*4
                add     ax, dx
                mov     di, ax          ; di = y*320+bx
                mov     ax, 0A000h
                mov     es, ax
                mov     bx, cx          ; bl = vsize, bh = hsize in 4px units
next_scanline:
                push    di
                push    cx
next_4px:
                push    bx
                mov     dl, [si]
                mov     dh, ds:[bp+si]
                call    dh7_0_dl7_dh6_0_dl6_to_al
                stosb
                call    dh7_0_dl7_dh6_0_dl6_to_al
                stosb
                call    dh7_0_dl7_dh6_0_dl6_to_al
                stosb
                call    dh7_0_dl7_dh6_0_dl6_to_al
                stosb
                inc     si
                pop     bx
                dec     bh
                jnz     short next_4px
                pop     cx
                pop     di
                add     di, 320
                mov     bh, ch
                dec     bl
                jnz     short next_scanline
                retn

; =============== S U B R O U T I N E =======================================


dh7_0_dl7_dh6_0_dl6_to_al  proc near
                xor     al, al
                add     dh, dh
                adc     al, al          ; al = dh7
                add     al, al          ; al = dh7_0
                add     dl, dl
                adc     al, al          ; al = dh7_0_dl7
                add     dh, dh
                adc     al, al          ; al = dh7_0_dl7_dh6
                add     al, al          ; al = dh7_0_dl7_dh6_0
                add     dl, dl
                adc     al, al          ; al = dh7_0_dl7_dh6_0_dl6
                retn
dh7_0_dl7_dh6_0_dl6_to_al  endp

; ---------------------------------------------------------------------------

m5_cga_alt:
                mov     dh, bl
                ror     dh, 1
                ror     dh, 1
                ror     dh, 1
                and     dx, 6000h
                shr     bl, 1
                shr     bl, 1
                mov     ax, 0A0h
                mul     bl
                add     ax, dx
                mov     bl, bh
                xor     bh, bh
                add     bx, bx
                add     ax, bx
                mov     di, ax
                mov     ax, 0B800h
                mov     es, ax
                mov     bx, cx

loc_3879:                               ; ...
                push    di
                push    cx

loc_387B:                               ; ...
                push    bx
                mov     dh, ds:[bp+si]
                mov     dl, [si]
                call    sub_38A6
                stosb
                call    sub_38A6
                stosb
                inc     si
                pop     bx
                dec     bh
                jnz     short loc_387B
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_389F
                add     di, 80A0h

loc_389F:                               ; ...
                mov     bh, ch
                dec     bl
                jnz     short loc_3879
                retn

; =============== S U B R O U T I N E =======================================


sub_38A6        proc near               ; ...
                xor     al, al
                mov     cx, 2

loc_38AB:                               ; ...
                add     dh, dh
                adc     bl, bl
                add     dl, dl
                adc     bl, bl
                add     dh, dh
                adc     bl, bl
                add     dl, dl
                adc     bl, bl
                and     bl, 0Fh
                xor     bh, bh
                add     al, al
                add     al, al
                add     al, al
                add     al, al
                or      al, cs:byte_38D0[bx]
                loop    loc_38AB
                retn
sub_38A6        endp

; ---------------------------------------------------------------------------
byte_38D0       db 0, 7, 9, 1, 7, 0Fh, 0Bh, 7, 9, 0Bh, 0Bh, 3, 1, 7, 3 ; ...
                db 9
stalactites0       db 4Ch, 0A8h, 0A0h, 43h, 88h, 2Ah, 4Fh, 4Fh, 4Fh, 41h ; ...
                db 0A0h, 0A2h, 43h, 0A0h, 43h, 8Ah, 4Fh, 4Bh, 0A8h, 2
                db 4Dh, 0A8h, 2Ah, 43h, 0Ah, 41h, 11h, 46h, 80h, 45h, 80h
                db 0Ah, 4Fh, 43h, 0A0h, 11h, 22h, 0Ah, 43h, 80h, 2Ah, 46h
                db 0EBh, 0C0h, 0Ah, 42h, 0A0h, 41h, 13h, 2Ah, 44h, 0A0h
                db 0ABh, 0EAh, 42h, 0A0h, 2, 11h, 0Ah, 0AEh, 49h, 0AFh
                db 42h, 0BEh, 42h, 0A0h, 11h, 2, 8Ah, 80h, 2Ah, 41h, 0A0h
                db 11h, 2, 45h, 0AEh, 0ACh, 2, 80h, 42h, 8Ah, 80h, 2, 2
                db 80h, 3, 20h, 2Ah, 42h, 0A8h, 2Ah, 0BAh, 42h, 88h, 8
                db 20h, 11h, 43h, 80h, 0Ah, 41h, 0ABh, 43h, 0A0h, 3Ah
                db 0ABh, 11h, 41h, 0A8h, 11h, 2, 20h, 28h, 8, 0Ah, 41h
                db 11h, 0Ah, 0A0h, 46h, 0E8h, 0Ah, 0A8h, 0Ah, 41h, 88h
                db 11h, 88h, 2Ah, 41h, 0BCh, 0Ch, 8, 2Ah, 42h, 2, 42h
                db 0A8h, 22h, 22h, 0A0h, 0A2h, 2Bh, 41h, 0A0h, 11h, 20h
                db 0Fh, 41h, 0EAh, 41h, 0F8h, 8, 2, 0A0h, 2, 0Ah, 0A8h
                db 11h, 88h, 0A0h, 8, 0A2h, 2, 0A0h, 2, 88h, 11h, 0Eh
                db 0BFh, 43h, 0AEh, 11h, 2Ah, 41h, 82h, 41h, 28h, 2, 20h
                db 41h, 0ABh, 80h, 30h, 11h, 22h, 42h, 0A0h, 0ABh, 41h
                db 0A0h, 8, 41h, 0Ah, 43h, 11h, 8, 8Ah, 80h, 0BAh, 0BAh
                db 0AEh, 12h, 8, 0F0h, 80h, 2, 0A0h, 2, 22h, 41h, 80h
                db 2, 82h, 80h, 20h, 2Ah, 0A0h, 3, 0C0h, 0FEh, 42h, 0B0h
                db 2, 41h, 0A2h, 82h, 41h, 0A0h, 22h, 11h, 22h, 0AEh, 41h
                db 30h, 11h, 2, 42h, 0A8h, 2Bh, 41h, 0A0h, 41h, 20h, 41h
                db 80h, 0Ah, 0EAh, 88h, 41h, 0A8h, 28h, 0Bh, 0BAh, 0E0h
                db 11h, 22h, 8, 2, 0A2h, 2, 0A2h, 2, 41h, 0A2h, 80h, 22h
                db 80h, 82h, 8Ah, 11h, 2, 8Ch, 11h, 23h, 42h, 0A0h, 0Ah
                db 41h, 2Ah, 82h, 41h, 80h, 0Ah, 20h, 43h, 0E2h, 0A0h
                db 11h, 0A8h, 42h, 2Ah, 41h, 0A0h, 0A0h, 41h, 0A0h, 11h
                db 0Ah, 0E8h, 2Ah, 41h, 0A8h, 80h, 11h, 0EAh, 11h, 82h
                db 8, 22h, 8Ah, 0A0h, 11h, 0A2h, 82h, 41h, 2Ah, 20h, 2Ah
                db 0A8h, 8, 22h, 8Ah, 41h, 2Ch, 2, 41h, 0ABh, 41h, 0A0h
                db 8Ah, 0A8h, 41h, 80h, 0C8h, 11h, 0Ah, 28h, 8Ah, 42h
                db 0A8h, 8Ah, 80h, 0A8h, 43h, 0EAh, 82h, 0A2h, 41h, 12h
                db 0Ah, 0A8h, 11h, 2Ah, 41h, 88h, 8, 0EAh, 11h, 88h, 80h
                db 0A8h, 0Ah, 0A8h, 8, 88h, 80h, 88h, 41h, 0A8h, 0Ah, 8
                db 80h, 11h, 0Ah, 88h, 0B0h, 28h, 8Ah, 2, 41h, 80h, 22h
                db 22h, 22h, 82h, 0CAh, 11h, 88h, 20h, 22h, 0EAh, 41h
                db 0A2h, 22h, 20h, 2Ah, 2Ah, 41h, 0AEh, 41h, 8Ah, 8Ah
                db 28h, 12h, 3, 0A0h, 11h, 0Ah, 0BAh, 22h, 41h, 38h, 20h
                db 22h, 8Ah, 22h, 22h, 22h, 41h, 22h, 20h, 22h, 41h, 22h
                db 12h, 0Ah, 22h, 22h, 22h, 0B0h, 2, 22h, 11h, 0EAh, 0CAh
                db 42h, 8Ah, 8Bh, 0C8h, 28h, 20h, 0A8h, 41h, 0FAh, 41h
                db 0EAh, 41h, 0A8h, 0Ah, 2Ah, 41h, 0ABh, 41h, 8Ah, 88h
                db 80h, 12h, 3, 41h, 88h, 2, 42h, 20h, 88h, 0A8h, 2Ah
                db 8Ah, 0A0h, 2Bh, 41h, 20h, 42h, 0Ah, 42h, 0A0h, 2Ah
                db 20h, 43h, 0C0h, 2Ah, 41h, 11h, 0EAh, 0E2h, 22h, 0A2h
                db 2Ah, 3, 20h, 20h, 8, 20h, 3Ah, 0F2h, 41h, 22h, 22h
                db 20h, 22h, 44h, 0Ah, 2Ah, 80h, 2, 22h, 22h, 0A2h, 22h
                db 11h, 0AEh, 22h, 0EAh, 22h, 22h, 22h, 0Ah, 2, 2Ah, 22h
                db 2Bh, 22h, 22h, 2, 2Ah, 0A0h, 11h, 22h, 2Ah, 22h, 22h
                db 3Fh, 0Ah, 2, 22h, 80h, 45h, 0Bh, 0A8h, 20h, 80h, 22h
                db 0BAh, 0FAh, 43h, 0ABh, 0E2h, 82h, 42h, 0EAh, 2Ah, 0A2h
                db 11h, 0Ah, 42h, 0EAh, 41h, 0A0h, 0EAh, 41h, 0BAh, 42h
                db 2Ah, 8Ah, 2Ah, 0EEh, 44h, 0A0h, 41h, 80h, 44h, 0BFh
                db 0C0h, 2Ah, 82h, 41h, 20h, 0ABh, 0A2h, 22h, 0A2h, 0A8h
                db 0Fh, 20h, 20h, 22h, 0A2h, 22h, 0EAh, 0ABh, 22h, 22h
                db 0FEh, 28h, 2Ah, 42h, 0A8h, 2Ah, 0A0h, 2, 20h, 11h, 22h
                db 0E2h, 22h, 20h, 22h, 23h, 0EBh, 0E2h, 32h, 2, 11h, 22h
                db 0AEh, 22h, 2Ah, 0A3h, 22h, 2Ah, 22h, 2, 22h, 22h, 2Ah
                db 0FFh, 0C0h, 2, 22h, 20h, 22h, 80h, 2Bh, 88h, 8Ah, 88h
                db 88h, 3Bh, 80h, 88h, 80h, 80h, 8Bh, 0EAh, 0A8h, 0A8h
                db 8Fh, 88h, 88h, 82h, 42h, 0BAh, 0A8h, 0A8h, 8, 11h, 88h
                db 88h, 88h, 88h, 88h, 3Ah, 8Ch, 0BFh, 0BFh, 8Bh, 0C0h
                db 11h, 8Bh, 8Ch, 0C8h, 8Ah, 0F8h, 88h, 0C8h, 80h, 8, 88h
                db 88h, 0BFh, 12h, 80h, 88h, 88h, 8, 20h, 2Ah, 0A2h, 41h
                db 2Ah, 0A8h, 2Fh, 2, 22h, 0Ah, 82h, 0ABh, 0E2h, 2Eh, 0A2h
                db 0BAh, 22h, 2Ah, 0A2h, 0FEh, 41h, 0BAh, 41h, 0A0h, 20h
                db 2Ah, 0A2h, 41h, 22h, 2Ah, 0A2h, 3Ah, 2Eh, 2Fh, 0EBh
                db 0BAh, 32h, 0Ah, 0AEh, 0B3h, 32h, 2Ah, 0EEh, 0EAh, 2Ah
                db 0Ah, 0A2h, 0EAh, 2Fh, 0C0h, 2, 12h, 22h, 0A2h, 0Ah
                db 88h, 2Ch, 88h, 0A8h, 41h, 0A0h, 0BBh, 8, 80h, 8, 88h
                db 0CBh, 88h, 0B8h, 88h, 0C8h, 88h, 88h, 88h, 0AEh, 42h
                db 0A2h, 11h, 80h, 88h, 88h, 88h, 88h, 88h, 88h, 0Eh, 0B8h
                db 88h, 0CAh, 0BFh, 88h, 0Ah, 0CBh, 0C3h, 0B8h, 88h, 0BFh
                db 0CCh, 8Ah, 8, 88h, 0ABh, 0F0h, 3Ch, 88h, 88h, 8, 8
                db 88h, 88h, 41h, 22h, 2Ah, 41h, 0EAh, 82h, 3Bh, 0Ah, 82h
                db 20h, 0Ah, 0ABh, 41h, 0A2h, 41h, 0EAh, 41h, 0F3h, 2Ah
                db 0AEh, 42h, 8Ah, 2, 0A2h, 0A2h, 2Ah, 42h, 0A2h, 2Ah
                db 8Eh, 0EAh, 0A2h, 0EAh, 0BAh, 0EEh, 0AEh, 3Ch, 11h, 0FAh
                db 0B2h, 2Bh, 0AEh, 41h, 0A2h, 2Ah, 0B8h, 11h, 3, 0C2h
                db 0A8h, 2, 2, 2Ah, 82h, 88h, 2, 41h, 0A8h, 0A8h, 0Bh
                db 0EEh, 20h, 11h, 0A8h, 41h, 0AEh, 8Ah, 42h, 0E0h, 8Fh
                db 42h, 0ABh, 42h, 88h, 11h, 88h, 42h, 0A0h, 88h, 42h
                db 88h, 0C8h, 41h, 0BAh, 0A0h, 41h, 0BEh, 0C0h, 11h, 0CCh
                db 0BAh, 41h, 0F8h, 8Ah, 42h, 0C0h, 8, 80h, 28h, 2Ah, 88h
                db 0A2h, 41h, 0A0h, 22h, 0Ah, 2Ah, 41h, 80h, 2Bh, 0F8h
                db 28h, 20h, 28h, 2Bh, 0ABh, 0EAh, 2Ah, 2Bh, 0ABh, 0F2h
                db 2Fh, 0FFh, 8, 42h, 88h, 0Ah, 22h, 2Ah, 11h, 0Ah, 20h
                db 2Ah, 2Ah, 0A2h, 22h, 2Ah, 3Ah, 41h, 3Eh, 0EBh, 11h
                db 20h, 0EEh, 3Ah, 2Ah, 0AEh, 22h, 2Ah, 2Ah, 2, 20h, 11h
                db 2, 2, 22h, 2Ah, 2Ah, 0A2h, 88h, 88h, 0BAh, 0A8h, 11h
                db 0BCh, 11h, 88h, 11h, 80h, 0ABh, 8Eh, 0F8h, 88h, 8Bh
                db 8Ch, 8Bh, 0F0h, 11h, 0Ah, 42h, 28h, 8, 80h, 11h, 8
                db 88h, 88h, 12h, 8Ah, 88h, 88h, 8Ch, 88h, 88h, 0A0h, 8
                db 11h, 0B8h, 0A8h, 88h, 8Ch, 8Ah, 88h, 0ACh, 88h, 88h
                db 88h, 11h, 88h, 8Ah, 88h, 8Ah, 80h, 22h, 2Ah, 0EAh, 28h
                db 2, 3Ch, 11h, 20h, 2, 0Ah, 0A2h, 2Bh, 32h, 2Ah, 2Eh
                db 0F2h, 0FCh, 12h, 0Eh, 2Ah, 41h, 20h, 11h, 2, 2Ah, 22h
                db 22h, 22h, 2, 20h, 2, 22h, 2Ah, 2Eh, 0E2h, 2Ah, 0C0h
                db 2, 20h, 32h, 0EAh, 22h, 22h, 2Ah, 2Ah, 0AEh, 22h, 0E2h
                db 2Ah, 20h, 0A2h, 22h, 41h, 22h, 22h, 88h, 88h, 0EBh
                db 0A0h, 8, 0FCh, 12h, 88h, 8, 0A8h, 0FBh, 0A8h, 88h, 0AFh
                db 8Bh, 13h, 2, 2Ah, 41h, 20h, 11h, 88h, 8Fh, 0CBh, 0C8h
                db 0F8h, 88h, 88h, 80h, 88h, 11h, 8Ch, 0B8h, 8Eh, 0C0h
                db 88h, 88h, 3Ch, 0E8h, 88h, 0AFh, 0A8h, 88h, 0BBh, 88h
                db 0C8h, 8Bh, 80h, 28h, 0FCh, 0A8h, 88h, 0A8h, 22h, 0A2h
                db 23h, 20h, 22h, 0F2h, 20h, 22h, 20h, 22h, 0A2h, 0A3h
                db 0A2h, 0A2h, 32h, 2Ch, 11h, 2, 11h, 22h, 42h, 0AEh, 22h
                db 22h, 0AEh, 0FFh, 23h, 22h, 0A2h, 22h, 20h, 11h, 0A0h
                db 2, 0A2h, 32h, 22h, 20h, 11h, 2Eh, 0FAh, 22h, 2Bh, 0E2h
                db 0A2h, 32h, 0E2h, 0EAh, 0E2h, 20h, 22h, 0C3h, 0A2h, 22h
                db 2Ah, 88h, 8Bh, 88h, 0A0h, 88h, 0B0h, 11h, 80h, 11h
                db 0ABh, 8Eh, 8Fh, 0C8h, 88h, 0CBh, 0B0h, 13h, 0Ah, 42h
                db 0ACh, 88h, 8Bh, 0CBh, 0BCh, 0FCh, 8Bh, 88h, 88h, 88h
                db 88h, 88h, 8Ah, 0B8h, 0BBh, 8, 11h, 88h, 88h, 0CAh, 88h
                db 0CBh, 0B8h, 8Ah, 0C8h, 0CAh, 41h, 0E8h, 88h, 0Bh, 11h
                db 0FAh, 88h, 8Ah, 22h, 23h, 0AEh, 80h, 23h, 0F2h, 20h
                db 11h, 2Eh, 0A2h, 32h, 23h, 20h, 0Fh, 2Eh, 30h, 20h, 11h
                db 22h, 22h, 42h, 0AEh, 22h, 20h, 3Eh, 0FEh, 0E3h, 0ECh
                db 2, 22h, 22h, 22h, 22h, 22h, 0AEh, 0E3h, 2, 22h, 22h
                db 2Ah, 0EFh, 0E3h, 22h, 0E8h, 22h, 0E2h, 3Ah, 0AFh, 0A2h
                db 22h, 0Bh, 11h, 0Eh, 22h, 22h, 88h, 88h, 8Ch, 0C0h, 8Ch
                db 0Ch, 0C0h, 88h, 0F8h, 8Bh, 80h, 88h, 83h, 0F0h, 0Ch
                db 0C0h, 11h, 88h, 80h, 88h, 42h, 0ACh, 88h, 88h, 3, 0BFh
                db 8Ch, 13h, 88h, 88h, 88h, 82h, 0B8h, 0C0h, 12h, 88h
                db 8Ah, 0CEh, 0C3h, 88h, 0B8h, 88h, 0C0h, 0BBh, 0AEh, 88h
                db 80h, 80h, 11h, 8, 11h, 88h, 22h, 23h, 22h, 82h, 2Fh
                db 20h, 3Eh, 2, 22h, 0FCh, 2, 22h, 0FEh, 20h, 0Eh, 0C2h
                db 2, 20h, 2, 22h, 0BBh, 42h, 22h, 22h, 11h, 0BEh, 30h
                db 22h, 20h, 2, 22h, 22h, 20h, 2, 0AEh, 0E2h, 20h, 2, 22h
                db 23h, 33h, 83h, 22h, 41h, 23h, 2, 3Bh, 41h, 0A0h, 2
                db 22h, 22h, 8, 82h, 22h, 11h, 8Bh, 0BAh, 12h, 0FFh, 0C8h
                db 0Bh, 3Fh, 0A8h, 88h, 3Fh, 11h, 0A8h, 0B8h, 0C0h, 11h
                db 88h, 88h, 11h, 8Ah, 41h, 0B8h, 12h, 88h, 0ACh, 0C0h
                db 11h, 88h, 88h, 12h, 88h, 8Ah, 0B3h, 11h, 88h, 88h, 12h
                db 0ABh, 0CBh, 0C0h, 0F8h, 0ABh, 88h, 0Ah, 41h, 88h, 88h
                db 12h, 2, 88h, 11h, 22h, 2Ch, 23h, 2, 22h, 3, 3Eh, 2Ah
                db 0E2h, 80h, 3, 0E2h, 22h, 20h, 0C3h, 11h, 22h, 11h, 2
                db 22h, 8Ah, 0EAh, 0B2h, 22h, 22h, 11h, 0EEh, 0E2h, 22h
                db 11h, 2, 22h, 22h, 11h, 2, 0AFh, 22h, 11h, 2, 22h, 22h
                db 23h, 0CEh, 32h, 0BAh, 83h, 2, 2Eh, 0BAh, 11h, 2, 22h
                db 22h, 2, 0Fh, 22h, 8Ah, 88h, 0ABh, 8, 88h, 88h, 0CBh
                db 8Fh, 8Bh, 88h, 0BCh, 0C8h, 88h, 0A8h, 0CBh, 11h, 8
                db 88h, 88h, 88h, 0BAh, 0EAh, 0B8h, 88h, 88h, 88h, 0A8h
                db 88h, 88h, 88h, 88h, 2, 88h, 88h, 88h, 0BBh, 88h, 88h
                db 88h, 88h, 88h, 8Bh, 8Ch, 0B8h, 0BBh, 8Ch, 88h, 8Ah
                db 0BAh, 88h, 88h, 88h, 88h, 82h, 0B0h, 0C8h, 2, 2Ah, 0ACh
                db 2, 22h, 2, 0E3h, 2Eh, 2, 22h, 0E0h, 0E2h, 22h, 0A3h
                db 23h, 15h, 88h, 82h, 80h, 2, 0A0h, 11h, 22h, 0C0h, 14h
                db 20h, 12h, 0EBh, 12h, 2, 0E0h, 0A0h, 8, 0CCh, 0Fh, 8
                db 20h, 2, 22h, 0BAh, 22h, 0A0h, 11h, 8, 80h, 0A0h, 3Ch
                db 8Ah, 0A8h, 0B0h, 8, 88h, 8, 0B8h, 0CCh, 8Ch, 8Bh, 80h
                db 0F8h, 41h, 8Bh, 8Bh, 11h, 0Ah, 0Ah, 8, 28h, 22h, 2
                db 0B0h, 0A0h, 11h, 88h, 3Ah, 80h, 2Ah, 8, 20h, 11h, 2
                db 11h, 20h, 0FFh, 20h, 88h, 20h, 88h, 22h, 0Fh, 32h, 20h
                db 41h, 28h, 88h, 0Ah, 0BAh, 20h, 80h, 22h, 22h, 20h, 80h
                db 3, 11h, 2Ah, 11h, 0A8h, 0A2h, 0Ah, 0B0h, 0F0h, 8, 0Ch
                db 0C0h, 30h, 41h, 83h, 0Ch, 13h, 2, 80h, 0Ch, 0Ah, 0B0h
                db 12h, 8, 41h, 82h, 13h, 22h, 11h, 22h, 11h, 0CBh, 11h
                db 82h, 8, 80h, 20h, 2, 0F0h, 88h, 2Ah, 80h, 8, 82h, 0E8h
                db 2, 2, 13h, 80h, 11h, 8Ah, 80h, 22h, 22h, 20h, 0Bh, 0A8h
                db 0F8h, 88h, 8Ch, 0C0h, 0Ch, 41h, 8Ch, 8Ch, 16h, 8, 0B0h
                db 13h, 28h, 0C0h, 15h, 2, 20h, 0FBh, 15h, 2, 0F0h, 11h
                db 0Ah, 80h, 11h, 0Ah, 0E8h, 11h, 20h, 15h, 20h, 12h, 88h
                db 0A0h, 2Bh, 0A0h, 30h, 30h, 30h, 0C0h, 3, 8, 0Ch, 0Ch
                db 15h, 2Bh, 8Ah, 0B0h, 13h, 2Ah, 80h, 14h, 2, 12h, 0CEh
                db 15h, 3, 20h, 11h, 2, 12h, 0Ah, 0E8h, 17h, 0A0h, 8, 82h
                db 2Ah, 88h, 2Eh, 0B8h, 0B8h, 0A8h, 0BBh, 11h, 3, 88h
                db 0B8h, 0B0h, 15h, 0Bh, 8Ah, 0A0h, 13h, 2Ah, 18h, 0FEh
                db 16h, 80h, 11h, 2, 12h, 0Ah, 0E8h, 11h, 20h, 15h, 80h
                db 11h, 28h, 0A8h, 8Ah, 41h, 0CFh, 30h, 20h, 0C2h, 11h
                db 3, 0Bh, 33h, 0C0h, 15h, 2Ah, 41h, 0C0h, 13h, 2Ah, 18h
                db 0F2h, 16h, 80h, 14h, 0Ah, 0E8h, 17h, 88h, 88h, 22h
                db 0A2h, 8Ah, 0ABh, 0B0h, 0F8h, 0CBh, 8Ah, 11h, 3, 8Bh
                db 8Ch, 16h, 0Ah, 0A2h, 0C0h, 13h, 3Ah, 18h, 0CEh, 16h
                db 80h, 14h, 0Ah, 0E8h, 17h, 80h, 41h, 82h, 41h, 2Bh, 41h
                db 11h, 0Fh, 3, 2, 12h, 0C3h, 0Ch, 16h, 0Ah, 0A2h, 0C0h
                db 13h, 2Bh, 18h, 0CEh, 16h, 80h, 14h, 0Ah, 0A8h, 17h
                db 88h, 0A2h, 22h, 0A2h, 2Ah, 0A8h, 12h, 0FCh, 0A8h, 12h
                db 0CBh, 8Ch, 16h, 0Ah, 82h, 0C0h, 13h, 22h, 18h, 0EEh
                db 1Bh, 2, 0E8h, 17h, 2Ah, 28h, 0Ah, 88h, 41h, 0E0h, 12h
                db 0Fh, 88h, 12h, 0C3h, 0Ch, 17h, 0A2h, 80h, 13h, 2Ah
                db 17h, 3, 0B3h, 1Bh, 2, 0EAh, 17h, 28h, 2, 0A2h, 82h
                db 41h, 13h, 3, 28h, 12h, 0CCh, 0Ch, 16h, 2Ah, 20h, 0B0h
                db 13h, 0FAh, 17h, 3, 0CBh, 1Bh, 2, 3Ah, 17h, 2, 0A8h
                db 11h, 41h, 0ABh, 13h, 3, 12h, 3, 0Ch, 30h, 16h, 0Ah
                db 88h, 0B0h, 13h, 8Bh, 17h, 3, 23h, 1Ch, 41h, 17h, 82h
                db 41h, 0A2h, 41h, 0BEh, 14h, 0A8h, 11h, 3, 8Ch, 0B0h
                db 16h, 8, 88h, 0B0h, 13h, 0ABh, 17h, 3, 23h, 1Bh, 2, 32h
                db 17h, 22h, 0BFh, 0A8h, 41h, 0E8h, 14h, 88h, 11h, 2, 8
                db 30h, 16h, 2, 28h, 0B0h, 13h, 8Ah, 17h, 3, 23h, 1Ch
                db 88h, 80h, 16h, 8Bh, 0C8h, 0F2h, 41h, 0ECh, 14h, 0B0h
                db 11h, 2, 0Ah, 0A0h, 16h, 22h, 28h, 0B0h, 13h, 0BBh, 17h
                db 3, 23h, 1Bh, 2, 2, 17h, 2Ch, 11h, 38h, 41h, 0F0h, 13h
                db 2, 28h, 11h, 2, 28h, 0A0h, 16h, 2Ah, 8Ah, 0B0h, 12h
                db 3, 2, 17h, 3, 30h, 0C0h, 1Ah, 8, 80h, 80h, 16h, 2Ch
                db 11h, 0Ah, 2Bh, 0A0h, 14h, 88h, 11h, 2, 2Ah, 0A0h, 16h
                db 2Ah, 8Ah, 0ACh, 12h, 2, 30h, 80h, 16h, 0Ch, 80h, 0C0h
                db 1Ah, 2, 88h, 17h, 0B0h, 11h, 8, 0ABh, 0A0h, 13h, 8
                db 28h, 11h, 3, 2Ch, 8Ch, 16h, 0Ah, 8Ah, 0A8h, 12h, 2
                db 8Ch, 80h, 16h, 0Fh, 80h, 0C0h, 1Ah, 8, 2, 20h, 16h
                db 0B0h, 11h, 0Eh, 2Bh, 0B0h, 14h, 28h, 11h, 8, 22h, 88h
                db 16h, 0Ah, 0A8h, 88h, 12h, 8, 20h, 20h, 16h, 2, 8Ch
                db 80h, 1Ah, 2, 20h, 20h, 16h, 0B0h, 11h, 8, 0ABh, 80h
                db 14h, 8, 11h, 0Ch, 8, 28h, 16h, 0Ah, 8Ah, 28h, 13h, 82h
                db 17h, 0Ah, 0C8h, 80h, 1Ah, 28h, 2, 8, 16h, 0B0h, 11h
                db 2, 2Ah, 80h, 13h, 8, 2, 12h, 0Ch, 8, 16h, 0Ah, 88h
                db 88h, 12h, 0Ah, 0Ah, 80h, 16h, 0Ch, 0C8h, 0A0h, 1Ah
                db 28h, 20h, 82h, 16h, 0C0h, 11h, 8, 0AEh, 0C0h, 13h, 8
                db 12h, 8, 0Ch, 8, 16h, 0Ah, 2Ah, 28h, 12h, 2, 11h, 80h
                db 16h, 3Ah, 8, 20h, 1Ah, 80h, 11h, 8, 20h, 15h, 0C0h
                db 11h, 22h, 2Eh, 0C0h, 16h, 8, 88h, 88h, 16h, 0Ah, 8
                db 88h, 12h, 8, 18h, 22h, 11h, 20h, 19h, 0Ah, 19h, 0C0h
                db 11h, 28h, 0AEh, 14h, 80h, 12h, 8, 88h, 2, 16h, 0Ah
                db 22h, 2, 1Bh, 23h, 8, 8, 1Fh, 16h, 22h, 2Eh, 17h, 8
                db 82h, 2, 16h, 0Ah, 41h, 82h, 1Bh, 0E0h, 2, 1Eh, 28h
                db 17h, 8, 0ABh, 19h, 80h, 80h, 15h, 8, 41h, 2, 1Bh, 0A0h
                db 2, 1Eh, 0Ah, 17h, 2Ah, 0BBh, 17h, 2, 2, 20h, 80h, 15h
                db 0Ah, 2Ah, 80h, 80h, 19h, 3, 80h, 11h, 80h, 1Dh, 2, 17h
                db 0Ah, 0ACh, 17h, 80h, 8, 80h, 20h, 15h, 22h, 28h, 80h
                db 1Fh, 1Fh, 15h, 3Ah, 0B8h, 16h, 0Ah, 8, 2, 8, 0Ah, 15h
                db 28h, 28h, 11h, 80h, 1Fh, 1Fh, 14h, 32h, 0B8h, 19h, 82h
                db 16h, 28h, 22h, 2, 1Fh, 1Fh, 15h, 0Eh, 0B8h, 1Fh, 11h
                db 0A0h, 0A8h, 80h, 88h, 1Fh, 1Fh, 14h, 0Ah, 0BCh, 1Fh
                db 11h, 0A0h, 28h, 11h, 20h, 1Fh, 1Fh, 14h, 0Ah, 8Ch, 1Fh
                db 2, 11h, 82h, 1Fh, 1Fh, 16h, 8, 20h, 1Fh, 12h, 2, 1Fh
                db 1Fh, 16h, 8, 0A0h, 1Fh, 12h, 8, 1Fh, 1Fh, 17h, 30h
                db 1Fh, 11h, 20h, 1Fh, 1Fh, 18h, 30h, 0
stalactites1       db 4Ch, 0ABh, 0AFh, 43h, 0C8h, 3Ah, 4Fh, 4Bh, 0ABh, 0FEh ; ...
                db 48h, 0FFh, 44h, 0ABh, 0EAh, 41h, 0BAh, 41h, 0AFh, 0AEh
                db 0FFh, 42h, 0AFh, 43h, 8Fh, 45h, 0BFh, 0FAh, 0FEh, 44h
                db 0BEh, 46h, 0AFh, 45h, 0AFh, 0FCh, 3, 0FAh, 41h, 0EAh
                db 41h, 0BFh, 0EAh, 41h, 0AFh, 0BAh, 43h, 0AEh, 0BCh, 3Ah
                db 0FAh, 0EAh, 41h, 0FAh, 0FFh, 11h, 0FFh, 0EAh, 0BEh
                db 0AEh, 0AFh, 41h, 80h, 0EEh, 0EAh, 42h, 0AFh, 0C0h, 0Fh
                db 0FBh, 0FAh, 43h, 0ABh, 0FEh, 43h, 0ABh, 0EAh, 41h, 0EAh
                db 43h, 0AFh, 0F0h, 11h, 22h, 0Fh, 0EEh, 0BAh, 0AFh, 0C0h
                db 3Eh, 41h, 0FBh, 0EAh, 0BEh, 42h, 38h, 11h, 0Fh, 0AFh
                db 0BAh, 0AFh, 0BFh, 13h, 3Fh, 0EAh, 0FFh, 41h, 0FAh, 0A0h
                db 0E8h, 3Fh, 42h, 0B0h, 2, 11h, 0Fh, 0A2h, 41h, 0FAh
                db 0BFh, 0FAh, 0ABh, 0FAh, 41h, 0EBh, 0EEh, 0A0h, 0EAh
                db 0BAh, 0C3h, 0BAh, 0ABh, 0F0h, 11h, 2, 8Ah, 80h, 3Bh
                db 41h, 0F0h, 11h, 3, 0AFh, 0BEh, 41h, 0ABh, 0AEh, 0A3h
                db 0A0h, 2, 80h, 0FEh, 0EAh, 0BBh, 0C0h, 2, 2, 80h, 3
                db 3Fh, 0FAh, 0FEh, 0ABh, 0A8h, 3Eh, 8Eh, 0EAh, 0ABh, 0C8h
                db 8, 20h, 11h, 0EBh, 0ABh, 0AFh, 0C0h, 0Fh, 0FBh, 0ACh
                db 41h, 0BEh, 0ABh, 0F0h, 0Eh, 0ACh, 11h, 0FFh, 0ACh, 11h
                db 2, 20h, 28h, 8, 0Eh, 0EFh, 11h, 0Ah, 0A0h, 0FBh, 0EAh
                db 41h, 0AFh, 0AEh, 0BAh, 38h, 0Ah, 0E8h, 0Eh, 0AEh, 0BCh
                db 11h, 88h, 2Ah, 41h, 0BCh, 0Ch, 0Fh, 0EBh, 0EAh, 41h
                db 3, 0EBh, 0BAh, 0ACh, 22h, 22h, 0F0h, 0E2h, 38h, 0AEh
                db 0F0h, 11h, 20h, 11h, 0BEh, 2Eh, 41h, 0Ch, 8, 3, 0B0h
                db 2, 0Eh, 0ECh, 11h, 88h, 0A0h, 8, 0A2h, 3, 0F0h, 2, 88h
                db 11h, 0Eh, 0BFh, 41h, 0FAh, 0EEh, 0A3h, 11h, 3Ah, 0EAh
                db 0C3h, 0EFh, 0ECh, 2, 20h, 41h, 0ABh, 0C0h, 30h, 11h
                db 3Eh, 0BAh, 41h, 0A0h, 0E8h, 0BAh, 0B0h, 8, 0AFh, 0Ah
                db 0BFh, 0FAh, 0EBh, 11h, 8, 0CAh, 80h, 0CBh, 8Ah, 0A3h
                db 12h, 8, 11h, 80h, 3, 0B0h, 2, 22h, 41h, 80h, 2, 83h
                db 80h, 20h, 2Ah, 0A0h, 3, 0C0h, 0FEh, 41h, 0EAh, 80h
                db 2, 0AFh, 0A2h, 0C3h, 0FEh, 0B0h, 22h, 11h, 22h, 0AFh
                db 41h, 30h, 11h, 3, 42h, 0A8h, 38h, 0BAh, 0B0h, 41h, 30h
                db 0AFh, 0C0h, 0Fh, 2Bh, 0C8h, 41h, 0A8h, 28h, 0Ch, 8Ah
                db 30h, 11h, 22h, 8, 2, 0A2h, 3, 0B2h, 2, 41h, 0A2h, 80h
                db 22h, 80h, 0C2h, 8Ah, 11h, 2, 8Ch, 11h, 23h, 0AFh, 0EEh
                db 0B0h, 0Ah, 0BAh, 2Bh, 0C3h, 0BAh, 0C0h, 0Ah, 20h, 0ABh
                db 0AEh, 41h, 0E2h, 0A0h, 11h, 0EBh, 42h, 3Bh, 41h, 0B0h
                db 0A0h, 0BAh, 0F0h, 11h, 0Eh, 2Ch, 3Fh, 0EAh, 0E8h, 80h
                db 11h, 2Fh, 11h, 82h, 8, 22h, 8Ah, 0A0h, 11h, 0F2h, 82h
                db 41h, 2Ah, 20h, 2Ah, 0A8h, 8, 22h, 8Ah, 41h, 2Ch, 2
                db 41h, 0F8h, 0BAh, 0B0h, 8Ah, 0B8h, 0ABh, 0C0h, 0FBh
                db 11h, 0Ah, 28h, 8Bh, 0AEh, 41h, 0E8h, 8Ah, 80h, 0EBh
                db 42h, 0BAh, 2Ah, 0C2h, 0A2h, 0EBh, 12h, 0Bh, 0ACh, 11h
                db 3Ah, 0BAh, 88h, 8, 2Bh, 11h, 88h, 80h, 0A8h, 0Ah, 0B8h
                db 8, 0C8h, 80h, 88h, 41h, 0A8h, 0Ah, 8, 80h, 11h, 0Ah
                db 88h, 0B0h, 28h, 8Ah, 3, 0BAh, 0C0h, 23h, 32h, 23h, 0C2h
                db 0FBh, 11h, 88h, 20h, 22h, 0EEh, 41h, 0E2h, 22h, 20h
                db 3Ah, 0FAh, 41h, 0A2h, 0EAh, 0CAh, 8Bh, 0FCh, 13h, 0B0h
                db 11h, 0Eh, 8Eh, 22h, 41h, 0Ch, 20h, 22h, 8Ah, 22h, 22h
                db 22h, 41h, 22h, 20h, 22h, 41h, 22h, 12h, 0Ah, 22h, 22h
                db 22h, 0B0h, 2, 22h, 11h, 3Ah, 0Ah, 41h, 0FAh, 8Eh, 0CBh
                db 0FCh, 28h, 20h, 0A8h, 41h, 0FAh, 41h, 0EAh, 41h, 0A8h
                db 3Eh, 0EFh, 41h, 0A8h, 0BAh, 0CAh, 8Fh, 0C0h, 13h, 0FAh
                db 88h, 3, 0BAh, 41h, 20h, 8Ch, 0A8h, 2Ah, 8Ah, 0A0h, 2Bh
                db 0EAh, 20h, 42h, 0Ah, 42h, 0A0h, 2Ah, 20h, 43h, 0C0h
                db 2Ah, 41h, 11h, 2Eh, 22h, 22h, 0E2h, 2Fh, 3, 30h, 20h
                db 8, 20h, 3Eh, 0F2h, 0ABh, 22h, 22h, 20h, 3Fh, 0BAh, 0EAh
                db 0ABh, 0BBh, 0Ah, 3Ah, 0C0h, 2, 22h, 23h, 0F2h, 22h
                db 11h, 0E2h, 22h, 0EAh, 22h, 22h, 22h, 0Ah, 2, 3Fh, 22h
                db 2Bh, 22h, 22h, 2, 2Ah, 0A0h, 11h, 22h, 2Ah, 22h, 22h
                db 3Fh, 0Ah, 2, 22h, 80h, 0FBh, 42h, 0EAh, 0BBh, 0Bh, 0B8h
                db 20h, 80h, 22h, 0BEh, 0FAh, 0AFh, 42h, 0ABh, 0EEh, 0FEh
                db 0BAh, 0EAh, 3Bh, 2Ah, 0EFh, 11h, 0Ah, 42h, 2Ah, 41h
                db 0A0h, 2Eh, 41h, 0BAh, 42h, 2Ah, 8Ah, 2Ah, 0EEh, 43h
                db 0AEh, 0E0h, 41h, 80h, 44h, 0BFh, 0C0h, 2Ah, 82h, 41h
                db 20h, 0ECh, 0A2h, 22h, 0E2h, 0ECh, 0Fh, 20h, 20h, 22h
                db 0A2h, 32h, 0FAh, 0BFh, 22h, 22h, 0FEh, 2Bh, 0EAh, 0BAh
                db 0EAh, 0ECh, 2Ah, 0ECh, 2, 20h, 11h, 22h, 22h, 22h, 20h
                db 33h, 23h, 0EBh, 0E2h, 32h, 2, 11h, 23h, 0EEh, 22h, 2Ah
                db 0A3h, 22h, 3Eh, 22h, 2, 22h, 22h, 2Ah, 0FFh, 0C0h, 2
                db 22h, 20h, 22h, 80h, 38h, 88h, 8Bh, 88h, 0CCh, 3Bh, 80h
                db 88h, 80h, 80h, 0CBh, 0FAh, 0ACh, 0B8h, 8Fh, 88h, 88h
                db 0BEh, 0AEh, 0EAh, 8Eh, 0A8h, 0ECh, 8, 11h, 88h, 88h
                db 0C8h, 88h, 88h, 0Bh, 8Ch, 0BFh, 0BFh, 8Bh, 0C0h, 11h
                db 8Bh, 8Ch, 0C8h, 8Bh, 0F8h, 88h, 0CCh, 80h, 8, 88h, 88h
                db 0BFh, 12h, 80h, 88h, 88h, 8, 20h, 3Bh, 0A2h, 0ABh, 2Fh
                db 0ECh, 2Fh, 2, 22h, 0Ah, 82h, 0EBh, 0E2h, 3Eh, 0E2h
                db 0BAh, 22h, 2Ah, 0A3h, 0CEh, 0BAh, 8Eh, 0ABh, 0B0h, 20h
                db 2Ah, 0A2h, 41h, 22h, 2Ah, 0A2h, 0Ah, 2Eh, 2Fh, 0FFh
                db 0BAh, 32h, 0Ah, 0FEh, 0B3h, 32h, 2Ah, 0FFh, 0EAh, 2Eh
                db 0Eh, 0A2h, 0EAh, 2Fh, 0C0h, 2, 12h, 22h, 0A2h, 0Ah
                db 88h, 30h, 88h, 0BCh, 0BBh, 0B0h, 0BBh, 8, 80h, 8, 88h
                db 0CBh, 0C8h, 0BCh, 0C8h, 0C8h, 88h, 88h, 88h, 0EEh, 0BAh
                db 0BAh, 0A3h, 0C0h, 80h, 88h, 88h, 88h, 88h, 88h, 88h
                db 3, 0B8h, 88h, 0CBh, 0FFh, 8Ch, 0Fh, 0CBh, 0C3h, 0B8h
                db 88h, 0BFh, 0CCh, 8Bh, 0Ch, 88h, 0BBh, 0F0h, 3Ch, 0C8h
                db 88h, 8, 8, 88h, 88h, 41h, 32h, 2Bh, 0EBh, 0EFh, 0C2h
                db 3Bh, 0Ah, 82h, 20h, 0Ah, 0EBh, 0EBh, 0F2h, 0EBh, 0EAh
                db 41h, 0F3h, 2Ah, 0B3h, 0BAh, 41h, 8Fh, 0C2h, 0A2h, 0A2h
                db 2Ah, 42h, 0A2h, 2Ah, 83h, 0EAh, 0A2h, 0EAh, 0BFh, 0EFh
                db 0BEh, 3Ch, 11h, 0FAh, 0B2h, 2Bh, 0BEh, 0AEh, 0A2h, 2Eh
                db 0FCh, 11h, 3, 0C3h, 0B8h, 2, 2, 2Ah, 82h, 88h, 2, 0AEh
                db 0ACh, 0BCh, 0Bh, 0EEh, 20h, 11h, 0A8h, 41h, 0EFh, 0CFh
                db 0ABh, 0AEh, 0E0h, 8Fh, 42h, 0B8h, 0AEh, 41h, 8Fh, 11h
                db 88h, 42h, 0A0h, 88h, 42h, 8Ch, 0C8h, 41h, 0BAh, 0A0h
                db 0BBh, 0BEh, 0C0h, 11h, 0CCh, 0BAh, 41h, 0FCh, 8Fh, 41h
                db 0ABh, 0C0h, 8, 80h, 3Ch, 2Fh, 0C8h, 0A2h, 0EAh, 0A0h
                db 22h, 0Ah, 2Eh, 0BBh, 0C0h, 2Bh, 0F8h, 28h, 20h, 28h
                db 3Bh, 0AFh, 0EEh, 2Ah, 3Fh, 0ABh, 0F2h, 2Fh, 0FFh, 0Fh
                db 0AEh, 0BAh, 8Fh, 0Ah, 22h, 2Ah, 11h, 0Ah, 20h, 2Ah
                db 2Ah, 0A3h, 22h, 2Ah, 3Ah, 41h, 3Fh, 0EFh, 11h, 20h
                db 0EEh, 3Ah, 2Ah, 0AEh, 22h, 2Ah, 3Fh, 2, 20h, 11h, 3
                db 2, 33h, 2Ah, 3Eh, 0A2h, 88h, 88h, 8Fh, 0BCh, 11h, 0BCh
                db 11h, 88h, 11h, 80h, 0BBh, 8Fh, 0F8h, 8Ch, 0CBh, 8Ch
                db 8Bh, 0F0h, 11h, 0Fh, 0ABh, 41h, 2Fh, 8, 80h, 11h, 8
                db 88h, 88h, 12h, 8Bh, 88h, 88h, 8Ch, 88h, 8Ch, 0B0h, 8
                db 11h, 0B8h, 0B8h, 88h, 8Ch, 8Fh, 88h, 0BCh, 88h, 88h
                db 88h, 11h, 0C8h, 8Bh, 88h, 8Bh, 0C0h, 22h, 2Ah, 2Fh
                db 2Ch, 2, 3Ch, 11h, 20h, 2, 0Ah, 0E3h, 3Fh, 32h, 2Eh
                db 3Eh, 0F2h, 0FCh, 12h, 0Eh, 0EBh, 0BAh, 3Ch, 11h, 2
                db 2Ah, 22h, 22h, 22h, 2, 20h, 2, 22h, 2Ah, 2Eh, 0E2h
                db 2Fh, 0C0h, 2, 20h, 32h, 0FAh, 22h, 22h, 2Eh, 2Ah, 0EEh
                db 22h, 0E2h, 2Ah, 20h, 0E2h, 22h, 0EAh, 22h, 32h, 88h
                db 88h, 38h, 0B0h, 8, 0FCh, 12h, 88h, 8, 0BCh, 0FFh, 0B8h
                db 88h, 0FFh, 8Bh, 13h, 3, 0EAh, 0BAh, 3Ch, 11h, 88h, 8Fh
                db 0CBh, 0C8h, 0F8h, 88h, 88h, 80h, 88h, 11h, 8Ch, 0B8h
                db 8Fh, 0C0h, 88h, 88h, 3Ch, 0F8h, 88h, 0BFh, 0B8h, 88h
                db 0BBh, 88h, 0C8h, 8Bh, 80h, 38h, 0FCh, 0BCh, 88h, 0B8h
                db 22h, 0A2h, 30h, 30h, 22h, 0F2h, 20h, 22h, 20h, 22h
                db 0E2h, 0F3h, 0E2h, 0B3h, 32h, 2Ch, 11h, 2, 11h, 23h
                db 0BBh, 0BAh, 0FEh, 22h, 22h, 0AEh, 0FFh, 23h, 22h, 0A2h
                db 22h, 20h, 11h, 0A0h, 2, 0A2h, 33h, 22h, 20h, 11h, 2Eh
                db 0FEh, 22h, 2Fh, 0F2h, 0A2h, 32h, 0E2h, 0EAh, 0E2h, 20h
                db 32h, 0C3h, 0A2h, 22h, 2Eh, 88h, 88h, 0CCh, 0B0h, 88h
                db 0B0h, 11h, 80h, 11h, 0BFh, 8Fh, 8Fh, 0C8h, 0CCh, 0CBh
                db 0B0h, 13h, 0Bh, 0EFh, 0ABh, 0ECh, 88h, 8Bh, 0CBh, 0BCh
                db 0FCh, 8Bh, 88h, 88h, 88h, 88h, 88h, 8Ah, 0B8h, 0BBh
                db 8, 11h, 88h, 8Ch, 0CFh, 88h, 0CFh, 0BCh, 0CBh, 0C8h
                db 0CAh, 41h, 0E8h, 88h, 0Fh, 11h, 0FBh, 88h, 8Bh, 22h
                db 20h, 0E2h, 0C0h, 23h, 0F2h, 20h, 11h, 3Fh, 0E2h, 32h
                db 23h, 20h, 0Fh, 2Eh, 30h, 20h, 11h, 22h, 23h, 0BFh, 41h
                db 0EEh, 22h, 20h, 3Eh, 0FEh, 0E3h, 0ECh, 2, 22h, 22h
                db 22h, 22h, 22h, 0AEh, 0E3h, 2, 22h, 22h, 2Eh, 0EFh, 0E3h
                db 23h, 0ECh, 33h, 0E2h, 3Ah, 0AFh, 0A2h, 22h, 0Fh, 11h
                db 0Fh, 22h, 23h, 88h, 88h, 0C0h, 11h, 8Ch, 0Ch, 0C0h
                db 88h, 0F8h, 8Bh, 0C0h, 88h, 83h, 0F0h, 0Ch, 0C0h, 11h
                db 88h, 80h, 88h, 0FBh, 0EFh, 0ACh, 88h, 88h, 3, 0BFh
                db 8Ch, 13h, 88h, 88h, 88h, 82h, 0B8h, 0C0h, 12h, 88h
                db 8Bh, 0CFh, 0C3h, 88h, 0FCh, 0CCh, 0C0h, 0BBh, 0AEh
                db 88h, 80h, 80h, 11h, 0Ch, 11h, 88h, 22h, 20h, 32h, 0C2h
                db 2Fh, 20h, 3Eh, 3, 22h, 0FCh, 2, 22h, 0FEh, 20h, 0Eh
                db 0C2h, 2, 20h, 2, 22h, 0C8h, 0EFh, 0AEh, 22h, 22h, 11h
                db 0BEh, 30h, 22h, 20h, 2, 22h, 22h, 20h, 2, 0AEh, 0E2h
                db 20h, 2, 22h, 23h, 33h, 0C3h, 22h, 0EEh, 33h, 2, 3Bh
                db 41h, 0A0h, 2, 22h, 22h, 0Ch, 0C2h, 22h, 11h, 88h, 8Bh
                db 12h, 0FFh, 0C8h, 0Fh, 3Fh, 0B8h, 88h, 3Fh, 11h, 0A8h
                db 0B8h, 0C0h, 11h, 88h, 88h, 11h, 0FAh, 0FAh, 0B8h, 12h
                db 88h, 0ACh, 0C0h, 11h, 88h, 88h, 12h, 88h, 8Ah, 0B3h
                db 11h, 88h, 88h, 12h, 0BBh, 0CBh, 0C0h, 0FCh, 0FBh, 88h
                db 0Ah, 41h, 88h, 88h, 12h, 3, 0C8h, 11h, 22h, 30h, 30h
                db 2, 22h, 3, 3Eh, 2Eh, 0E2h, 0C0h, 3, 0E2h, 22h, 20h
                db 0C3h, 11h, 22h, 11h, 2, 22h, 0FAh, 2Ah, 0B2h, 22h, 22h
                db 11h, 0EEh, 0E2h, 22h, 11h, 2, 22h, 22h, 11h, 2, 0AFh
                db 22h, 11h, 2, 22h, 22h, 33h, 0CEh, 32h, 0FEh, 0C3h, 2
                db 2Eh, 0BAh, 11h, 2, 22h, 22h, 3, 0Fh, 22h, 8Bh, 0C8h
                db 0B8h, 8, 88h, 88h, 0CBh, 8Fh, 8Bh, 88h, 0BCh, 0C8h
                db 88h, 0A8h, 0CBh, 11h, 8, 88h, 88h, 88h, 0CAh, 2Ah, 0B8h
                db 88h, 88h, 88h, 0A8h, 88h, 88h, 88h, 88h, 2, 88h, 88h
                db 88h, 0BBh, 88h, 88h, 88h, 88h, 88h, 8Fh, 8Ch, 0B8h
                db 0FBh, 0CCh, 88h, 8Ah, 0BAh, 88h, 88h, 88h, 88h, 83h
                db 0B0h, 0C8h, 2, 2Fh, 0E0h, 2, 22h, 2, 0E3h, 2Eh, 3, 22h
                db 0E0h, 0E2h, 22h, 0A3h, 23h, 15h, 0CCh, 0C2h, 0C0h, 2
                db 0A0h, 11h, 22h, 0C0h, 14h, 20h, 12h, 0EBh, 12h, 2, 0E0h
                db 0A0h, 0Ch, 0CCh, 0Fh, 0Ch, 20h, 2, 22h, 0BAh, 22h, 0A0h
                db 11h, 8, 80h, 0F0h, 3Ch, 8Bh, 0F8h, 0C0h, 8, 88h, 8
                db 0B8h, 0CCh, 8Ch, 8Bh, 80h, 0F8h, 41h, 8Bh, 8Bh, 11h
                db 0Ah, 0Ah, 8, 28h, 3Fh, 2, 0F0h, 0A0h, 11h, 88h, 3Ah
                db 80h, 2Ah, 8, 20h, 11h, 2, 11h, 20h, 0FFh, 20h, 88h
                db 20h, 88h, 22h, 0Fh, 32h, 20h, 0BBh, 28h, 88h, 0Ah, 0BAh
                db 20h, 80h, 22h, 22h, 20h, 0C0h, 3, 11h, 3Fh, 11h, 0A8h
                db 0A2h, 0Ah, 0B0h, 0F0h, 0Ch, 0Ch, 0C0h, 30h, 41h, 83h
                db 0Ch, 13h, 2, 80h, 33h, 0Ah, 0B0h, 12h, 8, 41h, 82h
                db 13h, 22h, 11h, 22h, 11h, 0CBh, 11h, 82h, 8, 80h, 20h
                db 3, 0F0h, 88h, 3Ah, 80h, 8, 82h, 0E8h, 2, 2, 13h, 0C0h
                db 11h, 8Fh, 0C0h, 22h, 22h, 20h, 0Bh, 0B8h, 0F8h, 8Ch
                db 8Ch, 0C0h, 0Ch, 41h, 8Ch, 8Ch, 15h, 33h, 8, 0B0h, 13h
                db 28h, 0C0h, 15h, 2, 20h, 0FBh, 15h, 3, 0F0h, 11h, 0Bh
                db 80h, 11h, 0Ah, 0E8h, 11h, 20h, 15h, 30h, 12h, 88h, 0A0h
                db 2Bh, 0B0h, 30h, 30h, 30h, 0C0h, 3, 8, 0Ch, 0Ch, 15h
                db 3Ch, 0CAh, 0B0h, 13h, 2Ah, 80h, 14h, 2, 12h, 0CEh, 15h
                db 3, 30h, 11h, 2, 12h, 0Ah, 0E8h, 17h, 0B0h, 8, 82h, 2Ah
                db 88h, 2Fh, 0B8h, 0B8h, 0B8h, 0BBh, 11h, 3, 88h, 0B8h
                db 0B0h, 15h, 3Ch, 8Ah, 0B0h, 13h, 2Ah, 18h, 0FEh, 16h
                db 0C0h, 11h, 2, 12h, 0Ah, 0E8h, 11h, 20h, 15h, 0C0h, 11h
                db 28h, 0A8h, 8Ah, 0AEh, 0CFh, 30h, 30h, 0C2h, 11h, 3
                db 0Bh, 33h, 0C0h, 15h, 3Eh, 0EAh, 0C0h, 13h, 2Ah, 18h
                db 0F2h, 16h, 0C0h, 14h, 0Ah, 0E8h, 17h, 0C8h, 88h, 22h
                db 0A2h, 8Ah, 0BBh, 0F0h, 0F8h, 0CBh, 8Ah, 11h, 3, 8Bh
                db 8Ch, 16h, 3Bh, 0E2h, 0C0h, 13h, 3Ah, 18h, 0CEh, 16h
                db 0C0h, 14h, 0Ah, 0E8h, 17h, 0C0h, 41h, 82h, 41h, 2Bh
                db 0EBh, 11h, 0Fh, 3, 2, 12h, 0C3h, 0Ch, 16h, 3Bh, 0B2h
                db 0C0h, 13h, 2Bh, 18h, 0CEh, 16h, 0C0h, 14h, 0Ah, 0A8h
                db 17h, 88h, 0A2h, 22h, 0A2h, 2Eh, 0ACh, 12h, 0FCh, 0A8h
                db 12h, 0CBh, 8Ch, 16h, 3Bh, 82h, 0C0h, 13h, 22h, 18h
                db 0EEh, 1Bh, 2, 0E8h, 17h, 2Ah, 28h, 0Ah, 88h, 0AEh, 0F0h
                db 12h, 0Fh, 88h, 12h, 0C3h, 0Ch, 16h, 30h, 0E2h, 0C0h
                db 13h, 2Ah, 17h, 3, 0B3h, 1Bh, 2, 0EAh, 17h, 28h, 2, 0A2h
                db 82h, 0BBh, 13h, 3, 28h, 12h, 0CCh, 0Ch, 16h, 3Eh, 20h
                db 0B0h, 13h, 0FAh, 17h, 3, 0CBh, 1Bh, 2, 3Ah, 17h, 2
                db 0A8h, 11h, 41h, 0BBh, 13h, 3, 12h, 3, 0Ch, 30h, 16h
                db 3Eh, 8Ch, 0B0h, 13h, 8Bh, 17h, 3, 23h, 1Ch, 41h, 17h
                db 82h, 41h, 0A2h, 41h, 0BFh, 14h, 0A8h, 11h, 3, 8Ch, 0B0h
                db 16h, 3Ch, 8Ch, 0B0h, 13h, 0ABh, 17h, 3, 23h, 1Bh, 2
                db 32h, 17h, 22h, 0BFh, 0A8h, 41h, 0ECh, 14h, 88h, 11h
                db 2, 8, 30h, 16h, 33h, 2Ch, 0B0h, 13h, 8Ah, 17h, 3, 23h
                db 1Ch, 88h, 80h, 16h, 8Bh, 0C8h, 0F2h, 0ABh, 0ECh, 14h
                db 0B0h, 11h, 2, 0Ah, 0A0h, 16h, 32h, 2Ch, 0B0h, 13h, 0BBh
                db 17h, 3, 23h, 1Bh, 2, 2, 17h, 2Ch, 11h, 38h, 0ABh, 0F0h
                db 13h, 2, 28h, 11h, 2, 28h, 0A0h, 16h, 3Ah, 0BAh, 0B0h
                db 12h, 3, 2, 17h, 3, 30h, 0C0h, 1Ah, 8, 80h, 80h, 16h
                db 2Ch, 11h, 0Ah, 2Bh, 0B0h, 14h, 88h, 11h, 2, 2Ah, 0A0h
                db 16h, 3Eh, 0BEh, 0ACh, 12h, 2, 30h, 80h, 16h, 0Ch, 80h
                db 0C0h, 1Ah, 2, 88h, 17h, 0B0h, 11h, 8, 0AFh, 0B0h, 13h
                db 8, 28h, 11h, 3, 2Ch, 8Ch, 16h, 0Eh, 0BEh, 0A8h, 12h
                db 2, 8Ch, 80h, 16h, 0Fh, 80h, 0C0h, 1Ah, 8, 2, 20h, 16h
                db 0B0h, 11h, 0Eh, 2Fh, 0B0h, 14h, 28h, 11h, 8, 22h, 88h
                db 16h, 0Ah, 0ACh, 88h, 12h, 8, 20h, 20h, 16h, 2, 8Ch
                db 80h, 1Ah, 2, 20h, 20h, 16h, 0B0h, 11h, 8, 0AFh, 0C0h
                db 14h, 8, 11h, 0Ch, 8, 28h, 16h, 0Ah, 0BAh, 28h, 13h
                db 82h, 17h, 0Ah, 0C8h, 80h, 1Ah, 28h, 2, 8, 16h, 0B0h
                db 11h, 2, 2Eh, 0C0h, 13h, 8, 2, 12h, 0Ch, 8, 16h, 0Eh
                db 0B8h, 88h, 12h, 0Ah, 0Ah, 80h, 16h, 0Ch, 0C8h, 0A0h
                db 1Ah, 28h, 20h, 82h, 16h, 0C0h, 11h, 8, 0AEh, 0C0h, 13h
                db 8, 12h, 8, 0Ch, 8, 16h, 0Eh, 3Ah, 28h, 12h, 2, 11h
                db 80h, 16h, 3Ah, 8, 20h, 1Ah, 80h, 11h, 8, 20h, 15h, 0C0h
                db 11h, 22h, 2Eh, 0C0h, 16h, 8, 88h, 88h, 16h, 0Ah, 8
                db 88h, 12h, 8, 18h, 22h, 11h, 20h, 19h, 0Ah, 19h, 0C0h
                db 11h, 28h, 0BFh, 14h, 80h, 12h, 8, 88h, 2, 16h, 0Ah
                db 22h, 2, 1Bh, 23h, 8, 8, 1Fh, 16h, 22h, 3Fh, 17h, 8
                db 82h, 2, 16h, 0Eh, 0AEh, 82h, 1Bh, 0E0h, 2, 1Eh, 28h
                db 17h, 8, 0BBh, 19h, 80h, 80h, 15h, 8, 41h, 2, 1Bh, 0A0h
                db 2, 1Eh, 0Ah, 17h, 2Ah, 0BFh, 17h, 2, 2, 20h, 80h, 15h
                db 0Eh, 2Eh, 80h, 80h, 19h, 3, 80h, 11h, 80h, 1Dh, 2, 17h
                db 0Ah, 0FCh, 17h, 80h, 8, 80h, 20h, 15h, 32h, 28h, 80h
                db 1Fh, 1Fh, 15h, 3Ah, 0FCh, 16h, 0Ah, 8, 2, 8, 0Ah, 15h
                db 28h, 28h, 11h, 80h, 1Fh, 1Fh, 14h, 32h, 0FCh, 19h, 82h
                db 16h, 28h, 32h, 2, 1Fh, 1Fh, 15h, 0Eh, 0FCh, 1Fh, 11h
                db 0E0h, 0E8h, 80h, 88h, 1Fh, 1Fh, 14h, 0Ah, 0BCh, 1Fh
                db 11h, 0A0h, 28h, 11h, 20h, 1Fh, 1Fh, 14h, 0Ah, 0CCh
                db 1Fh, 3, 11h, 82h, 1Fh, 1Fh, 16h, 8, 30h, 1Fh, 12h, 2
                db 1Fh, 1Fh, 16h, 8, 0B0h, 1Fh, 12h, 8, 1Fh, 1Fh, 17h
                db 30h, 1Fh, 11h, 20h, 1Fh, 1Fh, 18h, 30h, 0
byte_4C6D       db 4Bh, 80h, 2Ah, 42h, 28h, 2Ah, 42h, 28h, 4Ah, 8Ah, 45h ; ...
                db 0A8h, 8Ah, 41h, 0A8h, 0Ah, 42h, 20h, 42h, 0A2h, 0A2h
                db 49h, 0A2h, 8Ah, 42h, 0A8h, 8Ah, 0A8h, 0Ah, 2Ah, 42h
                db 82h, 41h, 0A8h, 0A2h, 42h, 0A8h, 8Ah, 45h, 0A8h, 0A8h
                db 41h, 0Ah, 0ABh, 2Ah, 42h, 11h, 22h, 0B0h, 3, 0A0h, 42h
                db 0A0h, 41h, 0A8h, 8Ah, 43h, 2Ah, 41h, 0A2h, 20h, 8Ah
                db 42h, 0Ah, 2Ah, 11h, 41h, 0CAh, 41h, 3Ch, 3, 0CFh, 2
                db 3, 0C0h, 0Ah, 42h, 2Ah, 0A2h, 80h, 0A8h, 41h, 0A0h
                db 41h, 0A2h, 20h, 3Fh, 22h, 2Ah, 0A8h, 0F0h, 0A0h, 80h
                db 2Ah, 8Ah, 0ACh, 11h, 20h, 32h, 80h, 20h, 0C8h, 0Fh
                db 22h, 2Ah, 2Ah, 0A2h, 20h, 0CAh, 22h, 88h, 0A8h, 88h
                db 0CFh, 11h, 0Ch, 8Ah, 80h, 0Ch, 11h, 20h, 0C8h, 41h
                db 80h, 2Ah, 41h, 2, 20h, 0A0h, 0A2h, 20h, 0Fh, 8, 8Ah
                db 0A8h, 41h, 0Ch, 22h, 88h, 88h, 0F0h, 11h, 41h, 83h
                db 0Bh, 2, 0ABh, 0EAh, 41h, 32h, 2Ah, 11h, 3, 20h, 41h
                db 80h, 8Ah, 41h, 88h, 80h, 0Fh, 0C8h, 0A8h, 8Ah, 0A3h
                db 0C8h, 0A2h, 80h, 2, 43h, 0C2h, 43h, 2Ah, 30h, 0A8h
                db 42h, 32h, 22h, 0A2h, 8Ah, 32h, 41h, 22h, 11h, 32h, 2Ah
                db 0A8h, 28h, 80h, 0A0h, 0C2h, 42h, 8Ah, 41h, 8Ah, 41h
                db 8Ah, 2Ah, 88h, 0Ch, 43h, 0A8h, 0FCh, 0E2h, 8Ch, 0A8h
                db 0F2h, 22h, 88h, 83h, 0Ah, 82h, 8Ah, 22h, 22h, 41h, 0A0h
                db 0A8h, 22h, 82h, 0A8h, 88h, 41h, 0C2h, 22h, 0ACh, 2Ah
                db 43h, 0AFh, 38h, 2Ah, 41h, 0A3h, 0C8h, 88h, 0ABh, 28h
                db 0A3h, 22h, 32h, 8Ah, 41h, 0Ah, 83h, 0Ah, 28h, 0F2h
                db 22h, 2Ah, 0C0h, 0B2h, 0A3h, 0EAh, 44h, 0F2h, 41h, 8Ah
                db 41h, 0A3h, 0F0h, 22h, 0C8h, 0F8h, 8Fh, 0Eh, 38h, 8Ah
                db 0A0h, 2Ah, 0F2h, 2Ah, 0A3h, 32h, 28h, 0A0h, 0CAh, 0ABh
                db 2Ah, 44h, 0BAh, 45h, 0F0h, 0C2h, 42h, 0B0h, 20h, 0E2h
                db 82h, 41h, 8Ch, 42h, 0BCh, 0A2h, 0A8h, 2Ah, 0A8h, 0EAh
                db 45h, 0A2h, 45h, 0B2h, 42h, 0ACh, 41h, 32h, 2Ah, 41h
                db 0A2h, 0A0h, 41h, 0ACh, 22h, 43h, 0E8h, 2Ah, 4Ah, 8Ah
                db 44h, 8Ch, 45h, 0ABh, 0CAh, 43h, 2Ah, 4Fh, 41h, 0A2h
                db 46h, 2Ah, 41h, 0
byte_4DB8       db 42h, 0EAh, 0BAh, 47h, 80h, 3Eh, 0BAh, 41h, 28h, 2Ah ; ...
                db 41h, 0ABh, 3Ch, 41h, 0FEh, 49h, 0EAh, 0EAh, 43h, 0ABh
                db 42h, 0A8h, 0Fh, 0AEh, 41h, 20h, 42h, 0B3h, 0E2h, 41h
                db 0ABh, 0FAh, 46h, 0AEh, 0ABh, 0AFh, 41h, 0ABh, 0BAh
                db 0ABh, 0FAh, 0EAh, 42h, 83h, 0EEh, 0A8h, 0A2h, 42h, 0ECh
                db 8Ah, 42h, 0AFh, 42h, 0ABh, 0ABh, 41h, 0FAh, 0A8h, 0ABh
                db 0BAh, 41h, 0FFh, 0EEh, 8Ch, 0Ch, 0AFh, 42h, 0A0h, 0FBh
                db 0A8h, 8Ah, 42h, 0EEh, 2Ah, 41h, 0AEh, 0EFh, 0BAh, 42h
                db 0FAh, 0EAh, 0Fh, 41h, 0Ah, 0FAh, 0C3h, 11h, 30h, 0C2h
                db 11h, 30h, 0FAh, 42h, 3Bh, 0A2h, 8Fh, 0ABh, 0ABh, 0B0h
                db 41h, 0AEh, 0EFh, 0C0h, 0EEh, 0EAh, 0ABh, 0Fh, 0AFh
                db 80h, 0EAh, 41h, 0F3h, 11h, 20h, 0Eh, 80h, 20h, 8, 11h
                db 0EEh, 0EAh, 0EFh, 0A2h, 20h, 3Ah, 0EEh, 88h, 0ABh, 0BBh
                db 30h, 11h, 33h, 0BAh, 0BCh, 3, 0F0h, 20h, 3Bh, 0ABh
                db 0C0h, 2Ah, 41h, 2, 20h, 0A0h, 0A2h, 20h, 30h, 0FBh
                db 0BEh, 0A8h, 41h, 3, 0EEh, 8Bh, 0BBh, 0Ch, 11h, 41h
                db 80h, 0F8h, 0C2h, 0A8h, 2Ah, 41h, 0Eh, 0EBh, 11h, 3Ch
                db 0EFh, 41h, 80h, 8Ah, 41h, 88h, 80h, 30h, 3Bh, 0A8h
                db 0BBh, 0E0h, 3Bh, 0AEh, 0BCh, 2, 43h, 3Eh, 43h, 0EAh
                db 0Fh, 0ACh, 42h, 0CEh, 0EEh, 0A2h, 8Ah, 0CEh, 41h, 22h
                db 11h, 0Eh, 0EAh, 0FCh, 2Bh, 8Fh, 0AFh, 2, 42h, 0BAh
                db 41h, 0BAh, 41h, 0BAh, 0EAh, 0BBh, 3, 0BEh, 42h, 0ABh
                db 3, 2Eh, 0B3h, 0ABh, 0Eh, 0EEh, 88h, 80h, 0FAh, 0C2h
                db 0BAh, 0EEh, 0EEh, 41h, 0AFh, 0ABh, 0EEh, 0BEh, 0ABh
                db 0BBh, 41h, 3Eh, 0EEh, 0A3h, 0FAh, 43h, 0A0h, 0CBh, 0EAh
                db 0EAh, 0ACh, 3Bh, 0BBh, 0A8h, 0E8h, 0ACh, 0EEh, 0CEh
                db 0BAh, 41h, 0FAh, 0BCh, 0FAh, 0EBh, 0Eh, 0EEh, 0EAh
                db 3Fh, 8Eh, 0ACh, 3Ah, 0ABh, 0EBh, 42h, 0Eh, 41h, 0EEh
                db 41h, 0ACh, 0Fh, 0EEh, 38h, 0Bh, 0B0h, 0F2h, 0CBh, 0BAh
                db 0AFh, 0EAh, 0Eh, 0EAh, 0ACh, 0CEh, 0EBh, 0AFh, 3Ah
                db 0A8h, 0FAh, 41h, 0BEh, 0EBh, 41h, 8Ah, 0BEh, 0BAh, 43h
                db 0Fh, 32h, 42h, 8Fh, 0EFh, 2Eh, 0BEh, 41h, 0B3h, 42h
                db 83h, 0AEh, 0ABh, 0EAh, 0ABh, 3Ah, 41h, 0ABh, 0FEh, 48h
                db 82h, 42h, 0A3h, 41h, 0CEh, 0EAh, 41h, 0AEh, 42h, 0A3h
                db 0EEh, 43h, 2Ah, 42h, 0BAh, 44h, 0EEh, 43h, 0BAh, 41h
                db 0BEh, 42h, 0B3h, 43h, 0AEh, 41h, 0A8h, 3Ah, 43h, 0EBh
                db 47h, 0BAh, 45h, 0AEh, 42h, 0AEh, 46h, 0EAh, 41h, 0
byte_4F25       db 0FFh, 50h, 0, 0Fh, 0FDh, 0D4h, 0, 0, 35h, 43h, 8Ah ; ...
                db 0BFh, 0FDh, 40h, 7Fh, 0FFh, 0F5h, 50h, 0, 0Fh, 0FDh
                db 50h, 0, 0Fh, 0F5h, 40h, 0, 0, 0FFh, 0F5h, 0DFh, 0FFh
                db 0FFh, 0FFh, 57h, 0FFh, 0FFh, 0FFh, 55h, 0B9h, 0DBh
                db 0FFh, 0FFh, 0F7h, 0FFh, 77h, 5Fh, 0FFh, 0FFh, 0D5h
                db 0FDh, 7Fh, 0FFh, 75h, 5Dh, 0FFh, 0FFh, 0FFh, 0D5h, 0FFh
                db 0FFh, 0FFh, 5Fh, 0FFh, 0DFh, 0FFh, 0FFh, 0FDh, 7Fh
                db 0FFh, 0FFh, 0FFh, 0FFh, 0DDh, 5Fh, 0FDh, 55h, 0FFh
                db 0FDh, 0FFh, 0FFh, 0D7h, 0FFh, 0FFh, 0FFh, 0FFh, 55h
                db 0FFh, 0FFh, 0FFh, 0F5h, 0FFh, 0F5h, 0FFh, 0FFh, 77h
                db 0DFh, 0FFh, 0DDh, 0D7h, 0FFh, 75h, 0FFh, 57h, 0FFh
                db 0FFh, 0FDh, 0F7h, 0FFh, 0F5h, 7Fh, 0FFh, 0FDh, 55h
                db 5Fh, 0FDh, 0DDh, 5Fh, 0FFh, 0D7h, 0FFh, 5Fh, 0FFh, 0DDh
                db 7Fh, 0FFh, 75h, 57h, 0FFh, 57h, 0F5h, 7Fh, 0FFh, 0FFh
                db 0FDh, 0FFh, 0DFh, 0F7h, 5Fh, 0F5h, 55h, 0FFh, 0FFh
                db 77h, 57h, 0FFh, 0FFh, 0D7h, 0FFh, 57h, 0FFh, 57h, 0FFh
                db 0FDh, 55h, 7Fh, 0D5h, 7Fh, 0D7h, 0FFh, 0FFh, 0FFh, 0FDh
                db 0FDh, 0DFh, 0FDh, 5Fh, 0F5h, 0FFh, 0FDh, 0D5h, 57h
                db 0FFh, 0FDh, 0DDh, 5Fh, 0F7h, 5Fh, 0D5h, 7Fh, 0FFh, 75h
                db 0FFh, 0FDh, 57h, 0FFh, 5Fh, 0FFh, 0FFh, 5Fh, 0F7h, 0FFh
                db 0FFh, 77h, 5Fh, 57h, 77h, 0D5h, 7Fh, 0FFh, 77h, 77h
                db 75h, 0FDh, 0DDh, 0FDh, 0DFh, 0FDh, 0DDh, 0Fh, 0DDh
                db 55h, 0FFh, 75h, 7Dh, 0FDh, 0D7h, 0FDh, 0D3h, 0DDh, 0FDh
                db 0DCh, 3Dh, 7Fh, 55h, 0FFh, 0D5h, 55h, 55h, 55h, 4Fh
                db 55h, 53h, 55h, 0F5h, 55h, 50h, 0F5h, 43h, 0FFh, 55h
                db 3, 0D5h, 0D7h, 0FDh, 55h, 0Dh, 53h, 75h, 43h, 0D4h
                db 0D5h, 0FFh, 55h, 55h, 50h, 55h, 54h, 35h, 55h, 4Dh
                db 53h, 0D5h, 55h, 4Fh, 54h, 3Dh, 55h, 40h, 0FDh, 54h
                db 0FDh, 55h, 40h, 0F5h, 43h, 35h, 3Dh, 53h, 54h, 55h
                db 55h, 55h, 0Fh, 0D5h, 53h, 0D5h, 55h, 4Dh, 4Dh, 35h
                db 55h, 35h, 53h, 0D5h, 40h, 0FFh, 55h, 50h, 0D5h, 50h
                db 3Fh, 54h, 3Ch, 0D4h, 0D5h, 4Dh, 53h, 55h, 55h, 53h
                db 0F5h, 35h, 4Dh, 55h, 55h, 4Dh, 35h, 4Dh, 54h, 0D5h
                db 4Dh, 50h, 0FFh, 55h, 55h, 4Fh, 55h, 0Fh, 0D5h, 53h
                db 0C3h, 53h, 55h, 4Dh, 53h, 55h, 54h, 3Dh, 55h, 35h, 4Dh
                db 55h, 55h, 75h, 35h, 4Dh, 54h, 0D5h, 35h, 4Fh, 55h, 55h
                db 54h, 0Dh, 54h, 0F5h, 55h, 4Ch, 3Dh, 53h, 55h, 35h, 4Dh
                db 55h, 3, 0D5h, 54h, 0D5h, 35h, 55h, 55h, 34h, 0D5h, 35h
                db 53h, 55h, 35h, 35h, 55h, 55h, 0Fh, 0FDh, 53h, 55h, 55h
                db 33h, 0D5h, 4Dh, 55h, 35h, 4Dh, 0, 0FDh, 11h, 13h, 11h
                db 31h, 11h, 11h, 30h, 0D1h, 31h, 13h, 10h, 0D0h, 0D1h
                db 11h, 13h, 0F1h, 31h, 0Dh, 11h, 10h, 0CDh, 11h, 0Dh
                db 11h, 31h, 13h, 0FFh, 44h, 44h, 4Ch, 44h, 34h, 44h, 44h
                db 34h, 0C4h, 34h, 43h, 44h, 0C4h, 0C4h, 44h, 3Ch, 44h
                db 0C4h, 4Ch, 44h, 43h, 34h, 44h, 4Ch, 44h, 34h, 44h
byte_50E5       db 0, 50h, 0, 0, 1, 14h, 0, 0, 5, 40h, 0Ah, 80h, 85h, 40h ; ...
                db 40h, 0, 5, 50h, 0, 0, 1, 50h, 0, 0, 5, 40h, 0, 0, 2
                db 25h, 10h, 0, 20h, 88h, 54h, 0, 2, 0, 54h, 29h, 18h
                db 0, 2, 6, 22h, 64h, 50h, 0Ah, 0AAh, 85h, 1, 4Ah, 2Ah
                db 45h, 51h, 0, 8, 88h, 14h, 0Ah, 0, 0Ah, 50h, 20h, 90h
                db 22h, 0A8h, 1, 50h, 20h, 0A8h, 0, 8Ah, 99h, 0, 0A9h
                db 40h, 80h, 28h, 22h, 8Ah, 94h, 2Ah, 0A2h, 22h, 0AAh
                db 50h, 0Ah, 0A8h, 0, 0A5h, 2, 25h, 8, 0AAh, 66h, 0C0h
                db 82h, 99h, 90h, 2Ah, 64h, 0Ah, 50h, 0, 2Ah, 0A8h, 20h
                db 8Ah, 0A5h, 0Ah, 0A8h, 0A9h, 11h, 0, 28h, 89h, 2, 2Ah
                db 94h, 0Ah, 52h, 0AAh, 99h, 2, 2Ah, 65h, 50h, 8Ah, 50h
                db 0A5h, 2, 0AAh, 0AAh, 0A8h, 28h, 82h, 0A6h, 42h, 0A5h
                db 10h, 0, 0Ah, 22h, 14h, 8, 0AAh, 90h, 2Ah, 10h, 0AAh
                db 50h, 8, 0A9h, 44h, 2, 95h, 2, 90h, 2Ah, 80h, 0Ah, 0A8h
                db 28h, 2, 0A9h, 52h, 0A4h, 0, 0A8h, 84h, 50h, 0, 28h
                db 89h, 42h, 0A2h, 2, 94h, 2, 0AAh, 24h, 0, 29h, 40h, 2Ah
                db 42h, 0A8h, 2Ah, 2, 0A0h, 0AAh, 22h, 22h, 42h, 10h, 22h
                db 80h, 40h, 0, 2, 22h, 20h, 8, 88h, 8, 80h, 0A8h, 88h
                db 0, 88h, 50h, 2, 21h, 8, 80h, 80h, 88h, 80h, 88h, 20h
                db 88h, 8, 2, 0, 88h, 80h, 0, 0, 0, 0Ah, 0, 0, 0, 0, 0
                db 0, 0A0h, 0, 82h, 0, 2, 80h, 2, 28h, 0, 8, 0, 20h, 2
                db 80h, 80h, 8Ah, 0, 0, 0, 0, 0, 0, 0, 8, 2, 80h, 0, 2
                db 0, 8, 0, 0, 88h, 0, 0A8h, 0, 0, 80h, 2, 20h, 8, 2, 0
                db 0, 0, 0, 8, 80h, 0, 80h, 0, 0, 0, 20h, 0, 0, 0, 80h
                db 0, 82h, 0, 0, 80h, 0, 2, 0, 8, 80h, 0, 0, 0, 0, 0, 0
                db 0A0h, 20h, 0, 0, 0, 8, 20h, 8, 0, 0, 0, 0, 0Ah, 0, 0
                db 0, 0, 8, 80h, 0, 82h, 0, 0, 8, 2, 0, 0, 28h, 0, 20h
                db 8, 0, 0, 0, 0, 0, 0, 80h, 0, 2, 0, 0, 0, 0, 0, 80h
                db 0, 8, 8, 2, 0, 0, 0, 0, 0, 80h, 0, 80h, 0, 0, 0, 0
                db 0, 0, 2, 0, 20h, 0, 0, 0, 0, 88h, 0, 0, 0, 0, 80h, 0
                db 0, 0, 8, 0, 88h, 0, 0, 0, 0, 0, 0, 20h, 0, 0, 0, 0
                db 0, 0, 0, 2, 20h, 20h, 0, 0, 0, 0, 0, 0, 0, 20h, 2, 82h
                db 0, 0, 8, 0, 20h, 0, 0, 20h, 80h, 20h, 0, 0, 80h, 80h
                db 0, 8, 0, 80h, 8, 0, 2, 20h, 0, 8, 0, 20h, 0

ckpd            ends

                end    start
