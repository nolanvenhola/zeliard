                .286
                .model tiny

ympd            segment byte public 'CODE'
                assume cs:ympd, ds:ympd

                org     100h
start:                
                mov     ax, 13h
                int     10h         ; set video mode

                mov ax, 1012h
                xor bx, bx          ; Start at index 0
                mov cx, 256         ; Update all 256 colors
                mov dx, offset palette
                push cs
                pop es
                int 10h             ; set palette

                call    Blit32x32SpriteToVram

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

; use sprite_32x32.bin as source
Blit32x32SpriteToVram proc near
                mov     di, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     si, offset region_32x32
                mov     cx, 32
loc_3F77:
                push    cx
                mov     cx, 16
                rep movsw
                add     di, 320-32
                pop     cx
                loop    loc_3F77
                retn
Blit32x32SpriteToVram endp


region_32x32: duke upper half
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 08h, 00h, 00h, 09h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 12h, 12h, 12h, 12h, 09h, 09h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 12h, 12h, 12h, 12h, 01h, 09h, 01h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Ah, 00h, 0Ah, 12h, 09h, 01h, 01h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 11h, 00h, 11h
db 12h, 01h, 01h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 0Ah, 0Ah, 0Ah, 0Ah, 12h, 10h, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 11h, 11h, 12h, 10h, 10h, 10h, 00h, 00h, 11h, 11h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 12h, 12h, 12h, 00h, 00h, 12h, 0Ah, 0Ah, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 11h, 12h, 12h, 10h, 10h, 12h, 10h, 0Ah, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 10h, 09h, 12h, 00h, 12h, 10h, 10h, 0Ah, 12h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Ah, 10h, 12h, 00h, 10h, 10h, 10h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0Ah, 00h, 10h, 10h
db 10h, 10h, 10h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 1Bh, 1Bh, 03h, 03h, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 09h, 08h, 01h, 11h, 12h, 02h, 02h, 02h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 08h, 08h, 09h, 01h, 01h, 01h, 18h, 18h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 1Bh, 01h, 01h, 09h, 01h, 01h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

Copy_Tile_Buffer_To_VRAM proc near
                push    es
                push    ds
                push    si
                push    di
                push    bx
                mov     ax, 0A000h
                mov     es, ax
                mov     si, offset sprite24
                mov     di, 0
                mov     cx, 3
loc_4112:
                push    cx
                mov     cx, 3
loc_4116:
                push    cx
                push    di
                call    Copy_tile    ; 8x8
                pop     di
                add     di, 8
                pop     cx
                loop    loc_4116
                add     di, 320*8-24
                pop     cx
                loop    loc_4112
                pop     bx
                pop     di
                pop     si
                pop     ds
                pop     es
                retn
Copy_Tile_Buffer_To_VRAM endp

Copy_tile       proc near
                mov     cx, 8
loc_368D:
                movsw
                movsw
                movsw
                movsw
                add     di, 320-8
                loop    loc_368D
                retn
Copy_tile       endp

sprite24: ; Duke with shield facing left
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 09h, 0Bh, 1Bh, 18h, 00h
db 00h, 00h, 00h, 08h, 00h, 00h, 09h, 00h, 00h, 12h, 12h, 12h, 12h, 12h, 09h, 09h
db 12h, 12h, 12h, 12h, 12h, 01h, 09h, 01h, 00h, 0Ah, 00h, 0Ah, 12h, 09h, 01h, 01h
db 00h, 11h, 00h, 11h, 12h, 01h, 01h, 00h, 0Ah, 0Ah, 0Ah, 0Ah, 12h, 10h, 02h, 00h
db 00h, 11h, 11h, 12h, 10h, 10h, 10h, 00h, 00h, 00h, 12h, 12h, 12h, 12h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 11h, 11h, 00h, 00h, 00h, 00h, 00h, 12h, 0Ah, 0Ah, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 0Ah, 02h, 02h, 03h, 00h, 00h, 00h, 00h, 0Ah, 12h, 02h, 1Bh, 00h
db 00h, 00h, 00h, 19h, 1Bh, 02h, 1Bh, 0Ah, 00h, 00h, 00h, 0Ah, 02h, 1Bh, 03h, 0Ah
db 00h, 00h, 00h, 0Ah, 12h, 02h, 03h, 00h, 00h, 00h, 00h, 0Ah, 12h, 02h, 03h, 00h
db 00h, 00h, 00h, 0Ah, 12h, 02h, 18h, 00h, 00h, 00h, 00h, 1Bh, 1Bh, 18h, 00h, 00h
db 00h, 00h, 11h, 12h, 12h, 10h, 10h, 12h, 10h, 09h, 12h, 00h, 12h, 10h, 10h, 0Ah
db 0Ah, 10h, 12h, 00h, 10h, 10h, 10h, 00h, 0Ah, 00h, 10h, 10h, 10h, 10h, 10h, 00h
db 00h, 00h, 1Bh, 1Bh, 03h, 03h, 03h, 00h, 09h, 08h, 01h, 11h, 12h, 02h, 02h, 02h
db 08h, 08h, 09h, 01h, 01h, 01h, 18h, 18h, 00h, 00h, 1Bh, 01h, 01h, 09h, 01h, 01h
db 10h, 0Ah, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h
db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 02h
db 00h, 00h, 1Bh, 18h, 1Bh, 01h, 01h, 09h, 00h, 1Bh, 18h, 18h, 18h, 1Bh, 1Bh, 18h
db 1Bh, 18h, 18h, 18h, 00h, 1Bh, 1Bh, 18h, 02h, 18h, 18h, 00h, 00h, 12h, 12h, 12h
db 02h, 02h, 00h, 00h, 00h, 10h, 12h, 12h, 02h, 02h, 00h, 00h, 00h, 00h, 10h, 10h
db 02h, 02h, 00h, 00h, 00h, 00h, 00h, 10h, 02h, 02h, 00h, 00h, 00h, 00h, 12h, 12h
db 08h, 08h, 00h, 00h, 00h, 00h, 00h, 00h, 08h, 09h, 08h, 08h, 00h, 00h, 00h, 00h
db 00h, 00h, 08h, 09h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
db 12h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 10h, 00h, 00h, 00h, 00h, 00h, 00h
db 10h, 12h, 10h, 00h, 00h, 00h, 00h, 00h, 12h, 10h, 10h, 00h, 00h, 00h, 00h, 00h

;      Input     |    Output   |
;----------------+------+------+
; ax_15_14_13_12 |  bp  |  dx  |
;----------------+------+------+
;    0  0  0  0  | 0000 | 0000 |
;    0  0  0  1  | ff00 | 0100 |
;    0  0  1  0  | ff00 | 0100 |
;    0  0  1  1  | ff00 | 0900 |
;    0  1  0  0  | 00ff | 0001 |
;    0  1  0  1  | ffff | 0101 |
;    0  1  1  0  | ffff | 0101 |
;    0  1  1  1  | ffff | 0901 |
;    1  0  0  0  | 00ff | 0001 |
;    1  0  0  1  | ffff | 0101 |
;    1  0  1  0  | ffff | 0101 |
;    1  0  1  1  | ffff | 0901 |
;    1  1  0  0  | 00ff | 0009 |
;    1  1  0  1  | ffff | 0109 |
;    1  1  1  0  | ffff | 0109 |
;    1  1  1  1  | ffff | 0909 |
CalculateSpriteBitmask proc near
                xor     bp, bp
                xor     dx, dx
                xor     bl, bl
                add     ax, ax
                adc     bl, bl
                add     ax, ax
                adc     bl, bl    ; ax15_ax14
                jz      short loc_40B5
                or      bp, 00FFh
                mov     dl, byte ptr cs:entity_dim_info+1
                cmp     bl, 3
                je      short loc_40B5
                mov     dl, byte ptr cs:entity_dim_info
loc_40B5:
                xor     bl, bl
                add     ax, ax
                adc     bl, bl
                add     ax, ax
                adc     bl, bl    ; ax13_ax12
                jnz     short loc_40C2
                retn
; ---------------------------------------------------------------------------
loc_40C2:
                or      bp, 0FF00h
                mov     dh, byte ptr cs:entity_dim_info+1
                cmp     bl, 3
                jne     short loc_40D1
                retn
; ---------------------------------------------------------------------------
loc_40D1:
                mov     dh, byte ptr cs:entity_dim_info
                retn
CalculateSpriteBitmask endp

entity_dim_info     dw 0       ; <- entity_render_tbl[sword_type]
entity_render_tbl   dw 0901h   ; white
                    dw 2404h   ; blue
                    dw 1B03h   ; yellow
                    dw 0901h   ; white
                    dw 2404h   ; blue
                    dw 3606h   ; lt yellow
; mov     bl, cs:sword_type
; dec     bl
; add     bx, bx
; mov     ax, cs:entity_render_tbl[bx] ; use 0901h for sword #1
; mov     cs:entity_dim_info, ax


ympd            ends

                end     start
