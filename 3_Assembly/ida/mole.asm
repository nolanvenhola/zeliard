                .286
                .model tiny

mole            segment byte public 'CODE'
                assume cs:mole, ds:mole

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

                mov     al, 4       ; this is how exactly Zeliard calls InitTitleScreen
                call    InitTitleScreen
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
                org 0
InitTitleScreen proc far
                mov     cs:video_mode, al    ; 4 = MCGA
                mov     ax, cs
                mov     ds, ax
                mov     es, ax
                cld
                call    SetGraphicsMode
                mov     si, offset title_logo_data
                mov     di, buf1
                call    DecompressRLE
                mov     si, offset title_demo_text_data
                mov     di, buf2
                call    DecompressRLE
                mov     si, buf1
                mov     bp, 960h
                mov     bx, 0C00h
                mov     cx, 380Dh
                call    DecompressToVRAM
                mov     ds:rle_marker_high, 10h
                mov     si, offset title_border1_data
                mov     di, buf1
                call    DecompressRLE
                mov     si, offset title_border2_data
                mov     di, buf2
                call    DecompressRLE
                mov     si, buf1
                mov     bp, 960h
                mov     bx, 0
                mov     cx, 0CC8h
                call    DecompressToVRAM
                mov     si, offset title_frame1_data
                mov     di, buf1
                call    DecompressRLE
                mov     si, offset title_frame2_data
                mov     di, buf2
                call    DecompressRLE
                mov     si, buf1
                mov     bp, 960h
                mov     bx, 4400h
                mov     cx, 0CC8h
                call    DecompressToVRAM
                mov     ds:rle_flag, 0FFh
                mov     ds:rle_marker_high, 50h ; 'P'
                mov     si, offset title_screen_final_data
                mov     di, buf1
                call    DecompressRLE
                mov     di, buf2
                mov     cx, 4B0h
                xor     ax, ax
                rep stosw
                mov     bp, 960h
                mov     bx, 0C9Eh
                mov     cx, 382Ah
                call    DecompressToVRAM
                call    DrawTitleFrame
                retf
InitTitleScreen endp


; =============== S U B R O U T I N E =======================================


SetGraphicsMode proc near
                test    ds:video_mode, 0FFh
                jz      short loc_AB
                retn
; ---------------------------------------------------------------------------

loc_AB:
                mov     dx, 3CCh
                xor     al, al
                out     dx, al          ; EGA port: graphics 1 position (must be 1 for EGA)
                inc     dx
                inc     al
                out     dx, al
                mov     dx, 3CEh
                mov     ax, 0
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; set/reset.
                                        ; Data bits 0-3 select planes for write mode 00
                inc     al
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; enable set/reset
                mov     ax, 0F02h
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; unknown register
                mov     ax, 3
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; data rotate and function select for write mode 00. Bits:
                                        ; 0-2: set rotate count for write mode 00
                                        ; 3-4: fn for write modes 00 and 02
                                        ;      00=no change; 01=AND; 10=OR; 11=XOR
                mov     ax, 5
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; mode register.Data bits:
                                        ; 0-1: Write mode 0-2
                                        ; 2: test condition
                                        ; 3: read mode: 1=color compare, 0=direct
                                        ; 4: 1=use odd/even RAM addressing
                                        ; 5: 1=use CGA mid-res map (2-bits/pixel)
                mov     ax, 0FF08h
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; unknown register
                retn
SetGraphicsMode endp


; =============== S U B R O U T I N E =======================================


DecompressToVRAM proc near

                xor     ax, ax
                mov     al, ds:video_mode
                add     ax, ax          ; switch 6 cases
                add     ax, offset jpt_DecompressToVRAM
                mov     di, ax
                jmp     word ptr [di]   ; switch jump
DecompressToVRAM endp

; ---------------------------------------------------------------------------
jpt_DecompressToVRAM          dw offset mode0_ega       ; EGA or VGA planar
                dw offset mode1_2_cga     ; CGA or Tandy
                dw offset mode1_2_cga     ;
                dw offset mode3_hgc       ; Hercules
                dw offset mode4_mcga      ; MCGA: video_mode=4
                dw offset mode5_cga_alt   ;
; ---------------------------------------------------------------------------

mode0_ega:                                 ; jumptable 000000DC case 0
                push    es
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

loc_106:
                push    di
                push    cx

loc_108:
                mov     ah, ds:[bp+si]
                lodsb
                mov     cl, ah
                or      cl, al
                xor     cl, al
                mov     ch, cl
                or      al, ch
                not     ch
                and     ah, ch
                mov     ch, al
                mov     al, 1
                out     dx, al          ; EGA port: sequencer data register
                mov     es:[di], ch
                mov     al, 2
                out     dx, al          ; EGA port: sequencer data register
                mov     es:[di], ah
                mov     al, 4
                out     dx, al          ; EGA port: sequencer data register
                mov     es:[di], cl
                inc     di
                dec     bh
                jnz     short loc_108
                pop     cx
                pop     di
                add     di, 50h ; 'P'
                mov     bh, ch
                dec     bl
                jnz     short loc_106
                pop     es
                retn
; ---------------------------------------------------------------------------

mode1_2_cga:                                ; jumptable 000000DC cases 1,2
                push    es
                mov     ax, 50h ; 'P'
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

loc_15F:
                push    di
                push    cx

loc_161:
                push    bx
                mov     ah, ds:[bp+si]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_16B:
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
                or      dl, ds:cga_bit_interleave_table[bx]
                loop    loc_16B
                mov     al, dl
                stosb
                pop     bx
                dec     bh
                jnz     short loc_161
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 4000h
                jb      short loc_1A2
                add     di, 0C050h

loc_1A2:
                mov     bh, ch
                dec     bl
                jnz     short loc_15F
                pop     es
                retn
; ---------------------------------------------------------------------------
cga_bit_interleave_table        db 0, 3, 2, 1, 1, 3, 2, 1, 0, 3, 2, 1, 1, 3, 2, 1
; ---------------------------------------------------------------------------

mode3_hgc:                                ; jumptable 000000DC case 3
                push    es
                xor     ax, ax
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

loc_1EA:
                push    di
                push    cx

loc_1EC:
                push    bx
                mov     ah, ds:[bp+si]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_1F6:
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
                or      dl, ds:cga_bit_interleave_table[bx]
                loop    loc_1F6
                mov     al, dl
                stosb
                pop     bx
                dec     bh
                jnz     short loc_1EC
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 6000h
                jb      short loc_243
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

loc_243:
                mov     bh, ch
                dec     bl
                jnz     short loc_1EA
                pop     es
                retn
; ---------------------------------------------------------------------------

mode4_mcga:                                ; jumptable 000000DC case 4
                push    es
                xor     dx, dx
                mov     dl, bh
                mov     bh, dh
                push    dx
                mov     ax, 320
                mul     bx
                pop     dx
                add     dx, dx
                add     dx, dx
                add     ax, dx
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     bx, cx

loc_268:
                push    di
                push    cx

loc_26A:
                push    bx
                mov     dh, ds:[bp+si]
                mov     dl, [si]
                call    Unpack2bppTo4bit_MCGA
                stosb
                call    Unpack2bppTo4bit_MCGA
                stosb
                call    Unpack2bppTo4bit_MCGA
                stosb
                call    Unpack2bppTo4bit_MCGA
                stosb
                inc     si
                pop     bx
                dec     bh
                jnz     short loc_26A
                pop     cx
                pop     di
                add     di, 320
                mov     bh, ch
                dec     bl
                jnz     short loc_268
                pop     es
                retn

; =============== S U B R O U T I N E =======================================


Unpack2bppTo4bit_MCGA proc near
                add     dh, dh
                adc     bl, bl          ; bl = dh7
                add     dl, dl
                adc     bl, bl          ; bl = dh7_dl7
                add     dh, dh
                adc     bl, bl          ; bl = dh7_dl7_dh6
                add     dl, dl
                adc     bl, bl          ; bl = dh7_dl7_dh6_dl6
                and     bl, 0Fh
                xor     bh, bh
                mov     al, unpack_table_2bpp_to_4bit[bx]
                retn
Unpack2bppTo4bit_MCGA endp

; ---------------------------------------------------------------------------
unpack_table_2bpp_to_4bit        db 0, 1, 5, 3, 8, 9, 0Dh, 0Bh, 28h, 29h, 2Dh, 2Bh, 18h
                db 19h, 1Dh, 1Bh
; ---------------------------------------------------------------------------

mode5_cga_alt:                                ; jumptable 000000DC case 5
                push    es
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

loc_2E7:
                push    di
                push    cx

loc_2E9:
                push    bx
                mov     dh, ds:[bp+si]
                mov     dl, [si]
                call    UnpackPixels_CGA_Alt
                stosb
                call    UnpackPixels_CGA_Alt
                stosb
                inc     si
                pop     bx
                dec     bh
                jnz     short loc_2E9
                pop     cx
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_30D
                add     di, 80A0h

loc_30D:
                mov     bh, ch
                dec     bl
                jnz     short loc_2E7
                pop     es
                retn

; =============== S U B R O U T I N E =======================================


UnpackPixels_CGA_Alt proc near
                xor     al, al
                mov     cx, 2

loc_31A:
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
                or      al, cga_alt_unpack_table[bx]
                loop    loc_31A
                retn
UnpackPixels_CGA_Alt endp

; ---------------------------------------------------------------------------
cga_alt_unpack_table        db 0, 7, 1, 2, 7, 0Fh, 3, 0Ah, 1, 3, 9, 0Bh, 2, 0Ah, 0Bh
                db 0Eh

; =============== S U B R O U T I N E =======================================


DrawTitleFrame proc near


                xor     ax, ax
                mov     al, video_mode
                add     ax, ax          ; switch 6 cases
                add     ax, offset jpt_DrawTitleFrame
                mov     di, ax
                jmp     word ptr [di]   ; switch jump
DrawTitleFrame endp

; ---------------------------------------------------------------------------
jpt_DrawTitleFrame         dw offset m0_ega            ; EGA or VGA planar
                dw offset m1_2_3_cga_hgc    ; CGA or Tandy
                dw offset m1_2_3_cga_hgc    ;
                dw offset m1_2_3_cga_hgc    ; Hercules
                dw offset m4_mcga           ; MCGA: video_mode=4
                dw offset m5_cga_alt
; ---------------------------------------------------------------------------

m0_ega:
                mov     ax, 0A000h
                mov     es, ax
                mov     dx, 3C4h
                mov     ax, 402h
                out     dx, ax          ; EGA: sequencer address reg
                                        ; unknown register
                mov     si, 49Ah
                mov     di, 0EB2h
                call    CopyFrameBytes_EGA
                mov     di, 0EFCh

; =============== S U B R O U T I N E =======================================


CopyFrameBytes_EGA proc near
                mov     cx, 5

loc_383:
                movsb
                movsb
                add     di, 4Eh ; 'N'
                loop    loc_383
                retn
CopyFrameBytes_EGA endp

; ---------------------------------------------------------------------------

m1_2_3_cga_hgc:
                retn
; ---------------------------------------------------------------------------

m4_mcga:                                ; jumptable 0000035A case 4
                mov     ax, 0A000h
                mov     es, ax
                mov     si, 49Ah
                mov     di, 3AC8h
                call    RenderFrameRows_MCGA
                mov     di, 3BF0h

; =============== S U B R O U T I N E =======================================


RenderFrameRows_MCGA proc near
                mov     cx, 5

loc_3A0:
                push    cx
                push    di
                lodsb
                call    ExpandByteToPixels_MCGA
                lodsb
                call    ExpandByteToPixels_MCGA
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_3A0
                retn
RenderFrameRows_MCGA endp


; =============== S U B R O U T I N E =======================================


ExpandByteToPixels_MCGA proc near
                mov     cx, 4

loc_3B6:
                xor     ah, ah
                add     al, al
                adc     ah, ah
                add     ah, ah
                add     ah, ah
                add     al, al
                adc     ah, ah
                add     ah, ah
                add     ah, ah
                or      es:[di], ah
                inc     di
                loop    loc_3B6
                retn
ExpandByteToPixels_MCGA endp

; ---------------------------------------------------------------------------

m5_cga_alt:
                mov     ax, 0B800h
                mov     es, ax
                mov     di, 66E4h
                mov     dh, 0FFh
                call    RenderFrameRows_CGA_Alt
                mov     di, 6778h
                xor     dh, dh

; =============== S U B R O U T I N E =======================================


RenderFrameRows_CGA_Alt proc near
                mov     cx, 5

loc_3E4:
                push    cx
                push    di
                xor     dl, dl
                mov     cx, 4

loc_3EB:
                mov     al, es:[di]
                call    ProcessPixel_CGA_Alt
                stosb
                loop    loc_3EB
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_403
                add     di, 80A0h

loc_403:
                pop     cx
                loop    loc_3E4
                retn
RenderFrameRows_CGA_Alt endp


; =============== S U B R O U T I N E =======================================


ProcessPixel_CGA_Alt proc near
                test    dl, 0FFh
                jz      short loc_40D
                retn
; ---------------------------------------------------------------------------

loc_40D:
                mov     ah, al
                mov     bl, ah
                shr     bl, 1
                shr     bl, 1
                shr     bl, 1
                shr     bl, 1
                xor     bh, bh
                mov     si, bx
                mov     al, cs:cga_alt_pixel_table[bx]
                add     al, al
                add     al, al
                add     al, al
                add     al, al
                mov     bl, ah
                and     bl, 0Fh
                or      al, cs:cga_alt_pixel_table[bx]
                or      si, si
                jz      short loc_439
                retn
; ---------------------------------------------------------------------------

loc_439:
                test    dh, 0FFh
                jnz     short loc_43F
                retn
; ---------------------------------------------------------------------------

loc_43F:
                mov     al, ah
                mov     dl, 0FFh
                retn
ProcessPixel_CGA_Alt endp

; ---------------------------------------------------------------------------
cga_alt_pixel_table        db 0, 4, 5, 5, 4, 5, 5, 7, 8, 0Ch, 0Dh, 0Dh, 0Ch, 0Dh, 0Dh, 0Fh

; =============== S U B R O U T I N E =======================================


DecompressRLE proc near
                lodsb
                or      al, al
                jnz     short loc_45A
                retn
; ---------------------------------------------------------------------------

loc_45A:
                mov     ah, al
                and     ah, 0F0h
                cmp     ah, rle_marker_high
                jnz     short loc_46D
                and     al, 0Fh
                mov     ah, al
                mov     al, 0AAh
                jmp     short loc_490
; ---------------------------------------------------------------------------

loc_46D:
                cmp     ah, 40h ; '@'
                jnz     short loc_47A
                and     al, 0Fh
                mov     ah, al
                xor     al, al
                jmp     short loc_490
; ---------------------------------------------------------------------------

loc_47A:
                test    rle_flag, 0FFh
                jz      short loc_48E
                cmp     ah, 0D0h
                jnz     short loc_48E
                and     al, 0Fh
                mov     ah, al
                mov     al, 0FFh
                jmp     short loc_490
; ---------------------------------------------------------------------------

loc_48E:
                mov     ah, 1

loc_490:
                stosb
                dec     ah
                jnz     short loc_490
                jmp     short DecompressRLE
DecompressRLE endp

; ---------------------------------------------------------------------------
rle_marker_high        db 90h
rle_flag        db 0
video_mode      db 0
                db  20h
                db    0
                db  12h
                db    0
                db 0ABh
                db    0
                db 0AFh
                db    0
                db 0A0h
                db    0
                db    0
                db  28h ; (
                db    0
                db  2Ah ; *
                db    2
                db 0ABh
                db    2
                db 0BFh
                db    0
                db  0Fh
title_logo_data db 3Ah, 93h, 0FFh, 0FCh, 2Ah, 93h, 0FFh, 0FCh, 2Ah, 93h
                db 0FFh, 0FCh, 2Ah, 93h, 0FFh, 0FCh, 2Bh, 0AFh, 80h, 3
                db 0E0h, 3, 0EBh, 0FAh, 0FFh, 0FCh, 2Ah, 93h, 0FFh, 0FCh
                db 2Ah, 93h, 0FFh, 0FCh, 2Ah, 93h, 0FFh, 0FCh, 2Ah, 92h
                db 0ACh, 0EAh, 43h, 0EAh, 0A8h, 44h, 0EAh, 0A8h, 44h, 0EAh
                db 0A8h, 44h, 0EAh, 0A8h, 42h, 0B0h, 28h, 0Ch, 0Eh, 42h
                db 0EAh, 0A8h, 44h, 0EAh, 0A8h, 44h, 0EAh, 0A8h, 44h, 0EAh
                db 0A8h, 43h, 0ABh, 0E8h, 0AFh, 0FAh, 0EFh, 0E8h, 28h
                db 2Bh, 0AFh, 0FAh, 0FFh, 0E8h, 28h, 3Eh, 0FAh, 0AEh, 0BBh
                db 0E8h, 28h, 2Ah, 0AFh, 0FAh, 0FFh, 0E8h, 28h, 3Ah, 91h
                db 0ECh, 0C0h, 3, 3Bh, 91h, 0AEh, 0E8h, 28h, 2Ah, 0AFh
                db 0FAh, 91h, 0E8h, 28h, 3Ah, 91h, 0FFh, 0AFh, 0E8h, 28h
                db 3Fh, 0AFh, 0FAh, 91h, 0E8h, 28h, 7Bh, 0AFh, 0FAh, 2Bh
                db 0A8h, 0BAh, 0AFh, 0FAh, 0E2h, 0B8h, 3Ah, 0FAh, 0AFh
                db 91h, 0E2h, 0B8h, 3Bh, 0ABh, 0BBh, 0BAh, 0E2h, 0B8h
                db 3Ah, 0FAh, 0AFh, 0EAh, 0E2h, 0B8h, 2Ah, 0EAh, 0EBh
                db 5, 50h, 0EBh, 0ABh, 91h, 0E2h, 0B8h, 3Ah, 0FAh, 0AFh
                db 0AFh, 0E2h, 0B8h, 2Fh, 0AFh, 91h, 0FAh, 0E2h, 0B8h
                db 2Ah, 0FAh, 0AFh, 0AFh, 0E2h, 0B8h, 2Fh, 0FAh, 0AEh
                db 2Ah, 0F8h, 0EAh, 0EFh, 91h, 0CAh, 0ACh, 2Bh, 0ABh, 91h
                db 0FAh, 0CAh, 0ACh, 2Ah, 0FEh, 0AFh, 0ABh, 0CAh, 0ACh
                db 2Fh, 0ABh, 91h, 0EBh, 0CAh, 0ACh, 2Ah, 0BEh, 0EAh, 10h
                db 4, 6Bh, 0BAh, 0EAh, 0CAh, 0ACh, 2Fh, 92h, 0FAh, 0CAh
                db 0ACh, 2Ah, 0FAh, 0AFh, 91h, 0CAh, 0ACh, 2Fh, 92h, 0FAh
                db 0CAh, 0ACh, 2Ah, 0FBh, 0ABh, 2Fh, 0E8h, 0EAh, 0FAh
                db 91h, 0C8h, 2Ch, 2Ah, 92h, 0AFh, 0C8h, 2Ch, 2Ah, 93h
                db 0C8h, 2Ch, 3Ah, 92h, 0AEh, 0C8h, 2Ch, 0Ah, 0ABh, 0ECh
                db 10h, 34h, 3Bh, 0EAh, 0A0h, 0C8h, 2Ch, 3Ah, 0BAh, 91h
                db 0AFh, 0C8h, 2Ch, 2Ah, 0AFh, 0FAh, 91h, 0C8h, 2Ch, 3Ah
                db 0BAh, 91h, 0AFh, 0C8h, 2Ch, 2Ah, 0AFh, 0ABh, 2Bh, 0A8h
                db 0EFh, 0ABh, 0A0h, 0C8h, 0ECh, 2Bh, 0A0h, 0Ah, 0EAh
                db 0C8h, 0ECh, 0Ah, 0EAh, 0ABh, 0A0h, 0C8h, 0ECh, 2Bh
                db 0A0h, 0Ah, 0AEh, 0C8h, 0ECh, 2, 0A8h, 0ECh, 11h, 74h
                db 3Bh, 2Ah, 80h, 0C8h, 0ECh, 2Ah, 0E0h, 0Ah, 91h, 0C8h
                db 0ECh, 0Ah, 91h, 0AEh, 0A0h, 0C8h, 0ECh, 2Bh, 0A0h, 0Ah
                db 0EAh, 0C8h, 0ECh, 0Ah, 0EAh, 0FBh, 2Ah, 0A8h, 92h, 0Ah
                db 0CAh, 0ACh, 3Ah, 0Ah, 0A0h, 0ABh, 0CAh, 0ACh, 20h, 92h
                db 8Ah, 0CAh, 0ACh, 2Ah, 0Bh, 0A2h, 91h, 0CAh, 0ACh, 2Ah
                db 83h, 0EAh, 17h, 0F4h, 6Bh, 82h, 0B8h, 0CAh, 0ACh, 2Ah
                db 0Ah, 0A0h, 0AEh, 0CAh, 0ACh, 20h, 92h, 0Ah, 0CAh, 0ACh
                db 2Ah, 0Ah, 0A0h, 91h, 0CAh, 0ACh, 20h, 92h, 2Ah, 0E8h
                db 0CAh, 0A0h, 91h, 0E2h, 0B8h, 28h, 91h, 0Ah, 0Ah, 0E2h
                db 0B8h, 0Ah, 0Ah, 0A0h, 91h, 0E2h, 0B8h, 20h, 0BAh, 0Ah
                db 0Ah, 0E2h, 0B8h, 20h, 2Eh, 0EBh, 5, 50h, 0EBh, 0A8h
                db 0Ah, 0E2h, 0B8h, 20h, 0A0h, 91h, 0Ah, 0E2h, 0B8h, 2Ah
                db 0Ah, 0A0h, 0A0h, 0E2h, 0B8h, 20h, 0A0h, 91h, 0Ah, 0E2h
                db 0B8h, 2Ah, 0Ah, 0A3h, 2Bh, 0A8h, 0A0h, 0Ah, 41h, 0EBh
                db 0E8h, 0Ah, 41h, 91h, 0A0h, 0EBh, 0E8h, 2Eh, 0A0h, 0Ah
                db 41h, 0EBh, 0E8h, 0Ah, 28h, 91h, 0EAh, 0EBh, 0E8h, 0Ah
                db 0EAh, 0E0h, 80h, 3, 2Bh, 91h, 0A0h, 0EBh, 0E8h, 2Ah
                db 91h, 41h, 0A0h, 0EBh, 0E8h, 41h, 0A0h, 0Ah, 91h, 0EBh
                db 0E8h, 0Ah, 0EEh, 41h, 0A0h, 0EBh, 0E8h, 41h, 0A0h, 0Ah
                db 2Ah, 0EAh, 0EEh, 0EFh, 0ABh, 0EAh, 0A8h, 3Eh, 0FFh
                db 0EEh, 0EBh, 0EAh, 0A8h, 3Fh, 0EFh, 0FAh, 0BBh, 0EAh
                db 0A8h, 3Bh, 0FFh, 0FFh, 0FFh, 0EAh, 0A8h, 3Fh, 0FFh
                db 80h, 28h, 0Ch, 0Ah, 0FAh, 0BFh, 0EAh, 0A8h, 3Fh, 0EFh
                db 0FFh, 91h, 0EAh, 0A8h, 3Bh, 0EFh, 0BBh, 0BFh, 0EAh
                db 0A8h, 2Eh, 0FBh, 0FBh, 0AFh, 0EAh, 0A8h, 6Ah, 0FBh
                db 0BBh, 0ABh, 94h, 42h, 2Ah, 93h, 42h, 2Ah, 93h, 42h
                db 2Ah, 93h, 42h, 2Ah, 91h, 41h, 2, 0E0h, 2, 92h, 42h
                db 2Ah, 93h, 42h, 2Ah, 93h, 42h, 2Ah, 92h, 0EAh, 42h, 2Ah
                db 93h, 0EEh, 0AEh, 0EAh, 0AEh, 0BEh, 0FAh, 0FAh, 0BEh
                db 0EEh, 0AFh, 0FAh, 0BEh, 0EEh, 0AFh, 0FAh, 0BEh, 0EEh
                db 0AFh, 0FAh, 0BEh, 0EEh, 0AFh, 0FAh, 0AEh, 0EEh, 0AFh
                db 0FAh, 0BEh, 0BEh, 0AFh, 0FAh, 0BBh, 0BEh, 0ABh, 0FAh
                db 0BBh, 0BEh, 0ABh, 0FAh, 0BBh, 0BEh, 0AFh, 0FAh, 0BBh
                db 0BEh, 0AFh, 0FAh, 0BBh, 0BEh, 0AFh, 0FAh, 0BBh, 3Ah
                db 0ABh, 0BAh, 0BAh, 0
title_demo_text_data db 80h, 0A8h, 2, 80h, 42h, 20h, 80h, 28h, 2, 42h, 2, 8
                db 20h, 80h, 43h, 28h, 0Ah, 28h, 43h, 83h, 91h, 0A8h, 0Ah
                db 0A8h, 28h, 43h, 2, 80h, 2Ah, 2, 42h, 20h, 2Ah, 0Ah
                db 8, 43h, 8, 0Ah, 80h, 42h, 2, 80h, 2Ah, 2, 4Fh, 4Bh
                db 0Ah, 80h, 2, 0A0h, 4Fh, 4Bh, 8, 0A0h, 2, 0E0h, 42h
                db 3, 80h, 44h, 0Eh, 0Ah, 2Eh, 0B8h, 49h, 0A8h, 2, 42h
                db 88h, 0A0h, 2, 42h, 2Ah, 46h, 0A0h, 45h, 20h, 44h, 0Bh
                db 80h, 0Ah, 20h, 20h, 80h, 4Ah, 38h, 23h, 8Bh, 80h, 45h
                db 0C0h, 42h, 0Ah, 20h, 20h, 42h, 20h, 83h, 0A8h, 42h
                db 30h, 4Bh, 8, 47h, 2, 8, 30h, 41h, 0E0h, 8, 42h, 8, 45h
                db 8, 0Eh, 0A0h, 20h, 44h, 2, 23h, 48h, 38h, 0E2h, 42h
                db 20h, 41h, 2, 46h, 2, 42h, 20h, 45h, 20h, 0Bh, 41h, 0Ch
                db 20h, 0Ah, 44h, 28h, 45h, 8, 0Ah, 0A0h, 20h, 44h, 2
                db 2, 42h, 2, 20h, 45h, 80h, 43h, 3Ah, 44h, 2, 41h, 2
                db 44h, 38h, 20h, 45h, 0A0h, 8, 28h, 41h, 3, 80h, 42h
                db 20h, 46h, 8, 20h, 80h, 45h, 8Ch, 42h, 2, 80h, 48h, 8
                db 0E0h, 41h, 22h, 44h, 2Eh, 80h, 42h, 3, 80h, 41h, 0C0h
                db 42h, 2, 0C0h, 41h, 28h, 8, 80h, 8, 43h, 38h, 46h, 2
                db 41h, 80h, 43h, 0Bh, 2, 8, 42h, 2Ah, 3, 44h, 80h, 38h
                db 42h, 20h, 42h, 0Eh, 44h, 2, 44h, 2, 41h, 2, 43h, 20h
                db 2, 20h, 8, 0C2h, 80h, 28h, 42h, 8, 46h, 2, 45h, 0B0h
                db 41h, 0Ah, 43h, 0Eh, 44h, 0A0h, 0Ah, 42h, 20h, 41h, 2Ah
                db 2, 48h, 20h, 20h, 44h, 28h, 2, 83h, 20h, 20h, 0A0h
                db 0Ah, 43h, 8, 45h, 0Eh, 45h, 0Ah, 28h, 41h, 0EAh, 42h
                db 2, 0EAh, 2, 42h, 80h, 0A8h, 0A0h, 42h, 2Ah, 0A0h, 4Ah
                db 2, 0EEh, 45h, 0A0h, 0Ah, 8, 41h, 2Eh, 20h, 0A8h, 42h
                db 2, 41h, 22h, 28h, 43h, 20h, 0Ah, 88h, 42h, 8, 41h, 0Ch
                db 45h, 0Ah, 80h, 2, 0A0h, 0Ah, 80h, 43h, 20h, 41h, 91h
                db 42h, 8, 20h, 8Bh, 80h, 42h, 2Eh, 8, 0Bh, 0A0h, 42h
                db 2Ah, 8, 0B8h, 41h, 8, 0Ah, 20h, 20h, 42h, 2, 41h, 2
                db 8, 43h, 20h, 2, 43h, 8, 41h, 8, 45h, 2Ah, 0A8h, 0Ah
                db 0A8h, 2, 8, 43h, 20h, 41h, 28h, 43h, 20h, 22h, 43h
                db 8, 41h, 2, 0C0h, 42h, 8, 8, 0A0h, 20h, 20h, 2, 20h
                db 20h, 4Ah, 2, 43h, 8, 44h, 20h, 47h, 8, 41h, 8, 43h
                db 8, 44h, 2, 47h, 2, 41h, 8, 8, 80h, 8, 0
title_border1_data db 4Dh, 0A3h, 0EEh, 33h, 0A8h, 38h, 0E2h, 0A8h, 38h, 0FEh
                db 8Eh, 0Ah, 3, 0BEh, 13h, 0ABh, 11h, 0Ah, 0EEh, 0E8h
                db 0BBh, 8Ah, 0Eh, 12h, 0A2h, 0A8h, 11h, 0A2h, 11h, 0E8h
                db 0E2h, 0AEh, 0A2h, 0Ah, 0A8h, 11h, 23h, 0B8h, 11h, 2Eh
                db 8Ah, 0A8h, 0A2h, 2Ah, 0A2h, 0Eh, 0A2h, 0A2h, 0A3h, 0B8h
                db 0AEh, 28h, 0ABh, 22h, 0E2h, 2Ah, 22h, 0Ah, 0A3h, 0A2h
                db 0A3h, 0ACh, 0EAh, 0ACh, 0CAh, 8Ah, 8Ah, 2Ah, 0A2h, 3
                db 0ABh, 0A2h, 0A3h, 11h, 0B2h, 11h, 0CAh, 0EAh, 8Ah, 0FAh
                db 8Ah, 3, 0E8h, 0A2h, 0A3h, 11h, 0A2h, 11h, 0CBh, 11h
                db 0A8h, 0A8h, 8Ah, 2, 0AEh, 0EAh, 0A8h, 0EBh, 0A3h, 0A8h
                db 88h, 11h, 0A8h, 0E8h, 8Ch, 2, 0ABh, 0EBh, 0A8h, 0EEh
                db 0A3h, 11h, 8Bh, 11h, 0A8h, 0A8h, 8Ch, 41h, 0EAh, 2Bh
                db 0A8h, 0EAh, 0A3h, 11h, 0ABh, 11h, 0A2h, 11h, 32h, 41h
                db 0EAh, 2Ah, 0A8h, 0EEh, 0A3h, 11h, 0A8h, 0ABh, 0A2h
                db 0A2h, 0Ah, 41h, 11h, 3Ah, 0A8h, 0EAh, 0A0h, 0A2h, 0A8h
                db 11h, 0A2h, 0A2h, 0Bh, 41h, 11h, 3Ah, 0E8h, 0EAh, 0A3h
                db 11h, 0A8h, 11h, 8Bh, 0A3h, 33h, 41h, 3Ah, 3Ah, 0A8h
                db 0EAh, 0A3h, 11h, 0A8h, 11h, 8Eh, 88h, 0AFh, 41h, 3Ah
                db 8Eh, 0A8h, 0EAh, 83h, 11h, 88h, 11h, 8Eh, 8Ch, 0ACh
                db 41h, 2Ah, 8Eh, 0ACh, 0EAh, 23h, 0A8h, 0A2h, 11h, 2
                db 0Ch, 0B3h, 41h, 2Ah, 8Eh, 88h, 0EAh, 80h, 11h, 82h
                db 0A8h, 8Fh, 8Ch, 0CBh, 41h, 0Eh, 8Eh, 0A0h, 0EAh, 23h
                db 0ABh, 22h, 0A2h, 3Ah, 32h, 0CAh, 41h, 0Eh, 0A2h, 88h
                db 0E8h, 80h, 0A0h, 8Eh, 0A8h, 88h, 32h, 0B2h, 41h, 0Ah
                db 2Eh, 20h, 0EBh, 23h, 0A2h, 2, 23h, 0Ah, 32h, 0ACh, 41h
                db 8, 83h, 80h, 0E8h, 3, 0A8h, 0Eh, 8Ah, 30h, 32h, 0ACh
                db 41h, 2, 0ACh, 0FBh, 3Ah, 0A8h, 0EBh, 0A3h, 0EEh, 0CFh
                db 82h, 0B2h, 41h, 0Ah, 11h, 0AEh, 12h, 0BAh, 0A2h, 0BAh
                db 0ABh, 0A0h, 0CBh, 41h, 3Ah, 0A8h, 0BAh, 2Ah, 11h, 0A2h
                db 8Ah, 0A8h, 11h, 88h, 0CBh, 41h, 2Ah, 0A2h, 0A8h, 11h
                db 8Bh, 22h, 8Ah, 0A8h, 11h, 0A8h, 33h, 41h, 0E2h, 0A2h
                db 13h, 8Ah, 11h, 0A8h, 11h, 0A2h, 2Fh, 41h, 8Ah, 8Ah
                db 12h, 0A8h, 8Ah, 13h, 0A2h, 2Fh, 41h, 13h, 0A2h, 28h
                db 13h, 20h, 82h, 33h, 41h, 2Ah, 13h, 0A8h, 88h, 88h, 88h
                db 88h, 8, 0Bh, 41h, 2Ah, 20h, 20h, 0A2h, 0A2h, 22h, 20h
                db 2, 41h, 8, 0CBh, 41h, 0Ah, 80h, 8, 46h, 32h, 11h, 41h
                db 2, 11h, 0BBh, 0FBh, 0A8h, 0AEh, 0FAh, 0ABh, 0ABh, 0C2h
                db 0CBh, 42h, 2Ah, 11h, 0EBh, 11h, 0BAh, 13h, 0Bh, 0A3h
                db 41h, 2, 0A8h, 22h, 0BAh, 2Ah, 0CEh, 0A3h, 12h, 0A3h
                db 0A3h, 41h, 0Eh, 0A2h, 0BAh, 11h, 2Ah, 82h, 0A2h, 11h
                db 0A8h, 22h, 0CBh, 41h, 3Ah, 2Ah, 0ABh, 12h, 83h, 8Eh
                db 8Ah, 0A2h, 0A2h, 0BBh, 41h, 28h, 0BAh, 0ABh, 2Ah, 88h
                db 0E8h, 0EAh, 88h, 0A2h, 22h, 0CAh, 41h, 0E2h, 0FAh, 0A2h
                db 2Eh, 80h, 0EAh, 0Eh, 88h, 11h, 83h, 0A2h, 41h, 0E2h
                db 0A2h, 22h, 11h, 83h, 11h, 0A3h, 0A8h, 11h, 23h, 0A3h
                db 41h, 0EAh, 0B8h, 0A2h, 0ACh, 83h, 11h, 0A3h, 0A8h, 11h
                db 0A2h, 0CBh, 41h, 0Ah, 22h, 11h, 0A8h, 83h, 11h, 0E0h
                db 3Ah, 11h, 22h, 0ABh, 41h, 3, 12h, 0A8h, 0A3h, 11h, 0A3h
                db 8Eh, 0EAh, 82h, 0CBh, 41h, 22h, 0C2h, 11h, 0ABh, 83h
                db 0ABh, 0A3h, 0A0h, 0A2h, 23h, 0A3h, 41h, 8, 8Bh, 2Ah
                db 11h, 0A3h, 0ABh, 0A3h, 12h, 83h, 0A3h, 42h, 2, 0Ah
                db 11h, 83h, 11h, 0A2h, 11h, 8Ah, 22h, 0CBh, 41h, 2, 0A0h
                db 8Eh, 11h, 83h, 11h, 8Eh, 12h, 82h, 0EBh, 41h, 0Eh, 0D2h
                db 22h, 11h, 83h, 14h, 0A2h, 0CBh, 41h, 3Ah, 0ABh, 8Bh
                db 11h, 83h, 8Ah, 12h, 0A8h, 0A3h, 0A2h, 41h, 0EAh, 0AFh
                db 80h, 0EAh, 23h, 0BAh, 2Ah, 12h, 3, 0A3h, 3, 11h, 0AFh
                db 0E2h, 0A8h, 82h, 12h, 0A2h, 0A8h, 22h, 0CBh, 3, 0ABh
                db 0FAh, 8Eh, 0A8h, 23h, 8Ah, 11h, 0A2h, 8Ah, 22h, 0ABh
                db 0Eh, 0ABh, 0A0h, 0FAh, 0A2h, 83h, 0BAh, 0ABh, 12h, 82h
                db 0C8h, 0Eh, 11h, 0CFh, 8Ah, 0A2h, 0Bh, 11h, 2Ah, 2Ah
                db 11h, 23h, 0A2h, 0Eh, 11h, 3Ah, 2Ah, 11h, 83h, 8Ah, 11h
                db 8Ah, 2Ah, 83h, 0A3h, 0Eh, 0A0h, 0E8h, 11h, 0A8h, 0A3h
                db 12h, 0A2h, 11h, 2, 0CAh, 3Ah, 83h, 0C8h, 11h, 0BAh
                db 83h, 8Ah, 0A8h, 0A2h, 0A2h, 0A2h, 0ABh, 3Ah, 0A2h, 82h
                db 2Ah, 88h, 0A2h, 0BAh, 0ABh, 8Ah, 11h, 22h, 0CBh, 3Ah
                db 82h, 2Eh, 3Ah, 2Ah, 2, 11h, 8Ah, 12h, 0A3h, 0A3h, 3Ah
                db 20h, 11h, 2Ah, 11h, 83h, 11h, 0BAh, 11h, 22h, 3, 0A2h
                db 3Ah, 82h, 0EEh, 0EAh, 8Eh, 0A3h, 14h, 82h, 0CBh, 3Ah
                db 20h, 0EAh, 0BAh, 2Ah, 80h, 13h, 2Ah, 22h, 0ABh, 38h
                db 80h, 0BAh, 12h, 20h, 0BAh, 12h, 88h, 22h, 0CBh, 3Ah
                db 0C0h, 3Bh, 0BAh, 11h, 83h, 13h, 88h, 0A3h, 0A2h, 41h
                db 8, 3Eh, 12h, 83h, 0BAh, 12h, 0A2h, 3, 0A3h, 41h, 22h
                db 3Bh, 0AEh, 0EAh, 23h, 0BAh, 0EAh, 0AEh, 0A8h, 22h, 0CBh
                db 41h, 0C8h, 3Eh, 12h, 80h, 13h, 8Ah, 22h, 0ABh, 3, 0A2h
                db 0Bh, 0AEh, 11h, 20h, 0BAh, 12h, 0A8h, 2, 0C8h, 2, 0A8h
                db 8Eh, 11h, 0AEh, 83h, 0BAh, 13h, 23h, 0A2h, 0Ah, 0BAh
                db 0Eh, 0EAh, 11h, 0Bh, 0BAh, 0EAh, 11h, 20h, 3, 0A3h
                db 41h, 11h, 8Ah, 12h, 83h, 0BAh, 12h, 8Ah, 2, 0CAh, 41h
                db 0Ah, 0Eh, 0BAh, 11h, 20h, 13h, 0A0h, 2, 0ABh, 41h, 2
                db 0BAh, 11h, 0BAh, 83h, 0BAh, 12h, 8Ah, 22h, 0CBh, 3
                db 0FAh, 0CBh, 12h, 20h, 0BAh, 0ABh, 0ABh, 0A8h, 23h, 0A3h
                db 0Eh, 0EAh, 0CEh, 12h, 41h, 13h, 22h, 3, 0A2h, 0Eh, 0BAh
                db 0EEh, 0EAh, 11h, 83h, 0BEh, 0BAh, 11h, 88h, 2, 0CBh
                db 3, 11h, 0EAh, 11h, 0AEh, 3, 0BAh, 11h, 0BAh, 22h, 22h
                db 0ABh, 2, 0EBh, 2Eh, 11h, 0EAh, 80h, 0BAh, 12h, 88h
                db 22h, 0CBh, 41h, 0ABh, 2Ah, 12h, 41h, 0BAh, 12h, 22h
                db 22h, 0CBh, 41h, 0EBh, 3Bh, 11h, 80h, 3, 0BAh, 12h, 88h
                db 0A3h, 0A2h, 41h, 11h, 2Eh, 0BAh, 20h, 3, 0EAh, 12h
                db 0A2h, 3, 0A3h, 41h, 0EBh, 3Bh, 0A8h, 41h, 8, 12h, 0A0h
                db 0A8h, 22h, 0CBh, 41h, 0ABh, 2Eh, 20h, 41h, 23h, 0EAh
                db 0A0h, 0FFh, 0F0h, 11h, 0ABh, 41h, 0A8h, 88h, 80h, 8
                db 88h, 11h, 0Fh, 0FEh, 0EEh, 0F2h, 0ABh, 2, 0A0h, 20h
                db 41h, 22h, 23h, 0A8h, 0FBh, 0FAh, 0BBh, 0BBh, 2Ah, 0Ah
                db 2, 41h, 8, 88h, 8Bh, 0ABh, 0EEh, 0EEh, 0EAh, 0AEh, 8Bh
                db 8, 41h, 22h, 2, 22h, 22h, 0AFh, 0BBh, 11h, 0AEh, 0ABh
                db 0A2h, 42h, 80h, 88h, 88h, 8Fh, 0EFh, 11h, 0EAh, 0BAh
                db 11h, 0A3h, 41h, 2, 22h, 22h, 23h, 0FAh, 8Fh, 13h, 0BAh
                db 0A3h, 42h, 88h, 88h, 0FFh, 11h, 8Eh, 0EAh, 13h, 83h
                db 41h, 2, 0A2h, 3Fh, 0BAh, 11h, 8Fh, 13h, 0BAh, 0A3h
                db 41h, 3, 8Fh, 0EAh, 0BEh, 8Eh, 8Eh, 13h, 0EAh, 0A2h
                db 41h, 3, 3Ah, 11h, 0AEh, 0A3h, 8Fh, 14h, 83h, 41h, 3
                db 0BAh, 13h, 0Eh, 14h, 82h, 41h, 2, 3Ah, 12h, 0A8h, 0CEh
                db 14h, 23h, 41h, 0Eh, 0EAh, 13h, 8Eh, 14h, 0A3h, 41h
                db 3Ah, 0E0h, 12h, 0A8h, 0Eh, 14h, 0A3h, 3, 0FFh, 0ABh
                db 8Eh, 11h, 80h, 2Eh, 14h, 0A2h, 0Eh, 12h, 0A0h, 0E8h
                db 2, 2Eh, 0A3h, 13h, 83h, 0Eh, 11h, 0EAh, 0BAh, 80h, 22h
                db 82h, 8Bh, 13h, 0A3h, 0Eh, 13h, 3Bh, 0CAh, 2Ah, 8Bh
                db 13h, 83h, 0Eh, 12h, 0A8h, 0EAh, 0BCh, 0AEh, 8Eh, 11h
                db 0AEh, 11h, 0A3h, 0Eh, 12h, 0A0h, 11h, 0ABh, 0EEh, 14h
                db 0A3h, 0Eh, 11h, 0BAh, 8Eh, 2Ah, 11h, 8Eh, 14h, 0B3h
                db 41h, 11h, 0A8h, 3Ah, 8Eh, 11h, 8Eh, 12h, 0ABh, 11h
                db 0A2h, 0Ah, 2Ah, 11h, 0EEh, 8Eh, 11h, 82h, 0BAh, 13h
                db 0A3h, 0Ah, 2Ah, 12h, 0BAh, 11h, 0Eh, 14h, 0A3h, 2, 8Ah
                db 14h, 82h, 14h, 82h, 0Ah, 8Ah, 11h, 0EAh, 11h, 0A2h
                db 8Eh, 14h, 82h, 0Ah, 0EAh, 0BAh, 0ABh, 11h, 8, 0Eh, 0ABh
                db 13h, 0A3h, 0Bh, 13h, 0A2h, 80h, 2Eh, 14h, 0A3h, 0Eh
                db 13h, 80h, 2, 0AEh, 13h, 2Ah, 83h, 0Eh, 13h, 41h, 2Ah
                db 2Eh, 14h, 0A3h, 0Eh, 12h, 0A2h, 0ABh, 0C8h, 8Eh, 14h
                db 0A2h, 0Eh, 11h, 0EAh, 0AEh, 11h, 0BEh, 2Ah, 14h, 83h
                db 0Eh, 14h, 0ABh, 0CEh, 14h, 0A3h, 0Eh, 15h, 8Eh, 14h
                db 0A3h, 0Eh, 15h, 8Ah, 12h, 2Ah, 11h, 83h, 0Eh, 11h, 0BAh
                db 13h, 0Ah, 12h, 0EAh, 11h, 83h, 0Eh, 14h, 0A8h, 8Ah
                db 14h, 83h, 0Eh, 13h, 0A8h, 11h, 8Eh, 14h, 0A2h, 41h
                db 0A0h, 0A2h, 2Ah, 22h, 8, 0Ah, 14h, 83h, 46h, 0Eh, 14h
                db 83h, 41h, 2, 22h, 22h, 2, 41h, 0Eh, 13h, 0A2h, 2, 42h
                db 88h, 88h, 88h, 41h, 0Eh, 12h, 0A2h, 88h, 82h, 42h, 11h
                db 0A2h, 22h, 20h, 0Eh, 13h, 22h, 0Fh, 41h, 2, 2Ah, 0A8h
                db 88h, 88h, 0Ch, 44h, 0Fh, 41h, 2, 13h, 22h, 3, 0FFh
                db 0FEh, 0FBh, 0A8h, 0Bh, 41h, 2, 13h, 88h, 3, 13h, 0A2h
                db 0Bh, 41h, 3Fh, 0FFh, 0F3h, 0FFh, 0FFh, 0CEh, 2Ah, 11h
                db 0A8h, 80h, 23h, 41h, 0EAh, 11h, 8Eh, 12h, 8Eh, 2Ah
                db 11h, 82h, 20h, 23h, 3, 12h, 8Eh, 0BAh, 11h, 8Fh, 44h
                db 83h, 3, 12h, 8Fh, 0EAh, 11h, 0BEh, 14h, 2, 3, 8Ah, 11h
                db 8Eh, 12h, 0EAh, 12h, 0ABh, 11h, 83h, 3, 12h, 8Eh, 11h
                db 0ABh, 11h, 2Ah, 12h, 0BAh, 83h, 3, 12h, 8Eh, 11h, 0ABh
                db 0A8h, 14h, 0A3h, 3, 11h, 0A3h, 8Eh, 11h, 0AEh, 0A2h
                db 12h, 0EAh, 11h, 0A3h, 3, 11h, 0AEh, 8Eh, 11h, 0AEh
                db 0A3h, 11h, 2Ah, 11h, 0A2h, 0A3h, 3, 12h, 8Eh, 11h, 0AEh
                db 83h, 11h, 0A8h, 12h, 0E3h, 3, 12h, 8Eh, 11h, 0AEh, 0A3h
                db 0A8h, 0EAh, 3Ah, 0Eh, 0A3h, 3, 12h, 80h, 11h, 0AEh
                db 83h, 0A8h, 0EAh, 3Ah, 0Eh, 0A2h, 3, 0A2h, 11h, 82h
                db 0EAh, 0ACh, 0A3h, 28h, 0EAh, 3Ah, 8Eh, 0A2h, 3, 12h
                db 82h, 0EAh, 0AEh, 83h, 88h, 0CAh, 3Ah, 8Ch, 0A3h, 3
                db 12h, 82h, 0EAh, 0ACh, 3, 0A8h, 0E8h, 32h, 8Eh, 83h
                db 3, 12h, 8Fh, 11h, 2Ah, 0Bh, 20h, 0CAh, 3Ah, 0Ch, 0A2h
                db 3, 11h, 0A3h, 8Fh, 11h, 8Ah, 0ABh, 0A0h, 0E8h, 3Ah
                db 0Ch, 0A3h, 3, 11h, 8Eh, 8Eh, 11h, 8Eh, 8Fh, 28h, 0E8h
                db 38h, 8Eh, 83h, 3, 0A0h, 3Ah, 8Eh, 11h, 30h, 0Fh, 0A0h
                db 0E2h, 3Ah, 0Eh, 23h, 41h, 0Ch, 0EAh, 8Eh, 0A8h, 0A3h
                db 8Fh, 0A0h, 0E8h, 32h, 0Eh, 82h, 3, 11h, 0Eh, 8Eh, 0A8h
                db 0CEh, 8Fh, 80h, 0E0h, 30h, 8Eh, 3, 3, 11h, 0A3h, 8Eh
                db 0A3h, 11h, 0Eh, 0C2h, 0B0h, 8Ch, 2Bh, 0Bh, 3, 12h, 0Eh
                db 12h, 8Eh, 12h, 8Eh, 11h, 0A2h, 3, 12h, 8Eh, 12h, 0Eh
                db 12h, 0Eh, 11h, 0A2h, 3, 12h, 8Eh, 12h, 0Eh, 12h, 8Eh
                db 11h, 83h, 3, 12h, 0Eh, 12h, 8Eh, 12h, 0Eh, 11h, 0A3h
                db 3, 11h, 0A2h, 0Eh, 12h, 0Eh, 12h, 0Eh, 11h, 83h, 3
                db 12h, 8Eh, 11h, 0A8h, 0Eh, 12h, 8Eh, 11h, 23h, 41h, 8Ah
                db 0A2h, 0Eh, 11h, 8Ah, 0Eh, 11h, 88h, 0Eh, 0A8h, 3, 41h
                db 22h, 8, 0Ah, 82h, 20h, 0Eh, 88h, 20h, 0Eh, 82h, 2, 4Bh
                db 0Ah, 41h, 0Eh, 17h, 0A0h, 41h, 0A2h, 41h, 0FAh, 18h
                db 20h, 0CAh, 3, 19h, 88h, 3Ah, 0Eh, 15h, 0A8h, 0A0h, 0A2h
                db 22h, 20h, 0Eh, 0Fh, 0FFh, 0EAh, 0CBh, 0EBh, 0EEh, 0EEh
                db 0BAh, 0BAh, 0BEh, 11h, 0BEh, 0Eh, 12h, 0A3h, 11h, 0BAh
                db 0B8h, 0A8h, 11h, 0EAh, 82h, 0A2h, 0Eh, 12h, 0A3h, 14h
                db 22h, 0AEh, 2Ah, 82h, 0Eh, 12h, 0A8h, 12h, 0A3h, 88h
                db 0E2h, 11h, 3Ah, 0A2h, 0Eh, 11h, 0A8h, 0A8h, 0EAh, 11h
                db 0Eh, 0A8h, 0EAh, 0A8h, 22h, 82h, 0Eh, 12h, 0A8h, 0EAh
                db 0A8h, 0E3h, 0A3h, 11h, 20h, 3Ah, 0A2h, 0Eh, 13h, 0Ah
                db 0A8h, 0E8h, 8Eh, 0A0h, 0Ah, 8Ah, 0A2h, 0Eh, 13h, 0A0h
                db 0E3h, 11h, 3Ah, 0Eh, 0A3h, 11h, 0A2h, 0Eh, 12h, 2Ah
                db 8Eh, 33h, 11h, 28h, 0EAh, 83h, 0A8h, 2, 0Eh, 12h, 38h
                db 2Ah, 22h, 11h, 83h, 11h, 0A2h, 0A3h, 82h, 2, 11h, 0ABh
                db 83h, 8Eh, 8Ah, 13h, 8Eh, 0A2h, 82h, 41h, 12h, 3Ah, 0A2h
                db 8Ah, 11h, 82h, 11h, 8Eh, 11h, 22h, 3, 11h, 0ABh, 11h
                db 0A3h, 0A3h, 0A8h, 28h, 11h, 23h, 11h, 82h, 2, 13h, 8Ch
                db 0A3h, 3, 8Bh, 0A2h, 0A8h, 0EAh, 22h, 0Eh, 12h, 8Ah
                db 2Ah, 0A8h, 0EAh, 8Bh, 0AEh, 11h, 3Ah, 82h, 0Eh, 11h
                db 2Ah, 8Ah, 11h, 0A2h, 11h, 0AEh, 12h, 3Ah, 2, 0Eh, 0ACh
                db 28h, 8Ah, 11h, 0A3h, 11h, 0ABh, 0AEh, 2Ah, 2Ah, 82h
                db 0Eh, 0A8h, 0A8h, 8Ah, 13h, 0ABh, 0A2h, 2Ah, 8Eh, 22h
                db 3, 0A8h, 11h, 2Ah, 13h, 0AEh, 0A2h, 2Ah, 8Eh, 82h, 0Eh
                db 12h, 8Ah, 11h, 2Ah, 11h, 0BAh, 11h, 2Ah, 3Ah, 2, 0Eh
                db 11h, 0A2h, 12h, 2Ah, 0AFh, 0FAh, 0AEh, 2Ah, 0A8h, 82h
                db 0Eh, 11h, 0AEh, 2Ah, 11h, 2Eh, 0BAh, 12h, 8Ah, 0A2h
                db 2, 3, 12h, 2Ah, 0ABh, 0FBh, 0EAh, 11h, 0AEh, 8Ah, 0A8h
                db 2, 3, 0A8h, 11h, 8Ah, 13h, 82h, 8Ah, 0Ah, 22h, 2, 0Eh
                db 0A8h, 2Bh, 8Ah, 0ABh, 8Ah, 8Ah, 88h, 0BAh, 8Ah, 88h
                db 2, 0Eh, 0B8h, 0ABh, 8Ah, 0AEh, 0Ah, 0EEh, 2Ah, 0E2h
                db 2, 22h, 2, 0Eh, 0A8h, 0BAh, 82h, 0A8h, 8Bh, 0A2h, 0A8h
                db 11h, 80h, 8, 2, 0Eh, 0B8h, 11h, 0A2h, 3Ah, 3, 88h, 0BAh
                db 0A2h, 20h, 22h, 2, 0Eh, 0A8h, 0BAh, 82h, 3Ah, 88h, 0A0h
                db 0CAh, 2, 88h, 41h, 2, 0Eh, 0ACh, 0ABh, 28h, 11h, 0Ah
                db 28h, 0E2h, 2, 88h, 22h, 2, 0Eh, 0A8h, 2Bh, 88h, 0E8h
                db 82h, 82h, 0CAh, 8Ah, 20h, 80h, 2, 0Eh, 0B8h, 0Ah, 8
                db 0EAh, 8, 8Ah, 0A8h, 0A2h, 28h, 2, 2, 0Eh, 0EAh, 8, 8Eh
                db 0A8h, 0A3h, 8, 82h, 88h, 8, 80h, 2, 0Eh, 11h, 0A2h
                db 22h, 22h, 2, 2, 22h, 20h, 22h, 41h, 2, 0Eh, 8, 88h
                db 0Ah, 82h, 20h, 2, 8, 8, 42h, 2, 0
title_border2_data db 1Dh, 0ABh, 0E2h, 0BBh, 11h, 0BAh, 0EAh, 0A2h, 0BAh
                db 0FEh, 0AEh, 0A0h, 0ABh, 0BEh, 13h, 0ABh, 11h, 8, 0EEh
                db 0E8h, 0BBh, 0A0h, 0ACh, 12h, 0A2h, 0A8h, 11h, 0A2h
                db 0A8h, 0E8h, 0E0h, 2Eh, 0A0h, 11h, 0A8h, 2Ah, 20h, 38h
                db 0Ah, 0Eh, 8Ah, 0A8h, 0A0h, 0Ah, 0A0h, 0A0h, 20h, 22h
                db 41h, 38h, 0Eh, 8, 83h, 0A0h, 0E2h, 22h, 20h, 0A0h, 20h
                db 22h, 20h, 0Ch, 0Ah, 0Ch, 0C2h, 80h, 82h, 28h, 0A0h
                db 0A8h, 80h, 20h, 0A0h, 41h, 30h, 8, 0C0h, 41h, 82h, 30h
                db 80h, 0A8h, 0E0h, 20h, 0A0h, 41h, 20h, 41h, 0C0h, 2
                db 8, 20h, 80h, 0A8h, 0Ch, 20h, 28h, 3, 20h, 41h, 80h
                db 2, 8, 0C0h, 80h, 0A8h, 28h, 3, 8, 0Eh, 80h, 41h, 80h
                db 20h, 8, 88h, 80h, 11h, 22h, 23h, 8, 2, 41h, 20h, 80h
                db 22h, 2, 2Ah, 41h, 11h, 2, 22h, 42h, 20h, 42h, 3, 2
                db 2, 41h, 11h, 2, 2, 42h, 20h, 42h, 2, 41h, 22h, 41h
                db 11h, 41h, 2, 41h, 20h, 41h, 20h, 20h, 20h, 43h, 11h
                db 80h, 43h, 80h, 41h, 80h, 42h, 8, 41h, 11h, 80h, 44h
                db 20h, 8, 8, 41h, 80h, 41h, 11h, 80h, 42h, 8, 20h, 41h
                db 20h, 20h, 2, 41h, 30h, 11h, 80h, 42h, 8, 42h, 80h, 20h
                db 3, 41h, 0C8h, 11h, 0A0h, 43h, 20h, 41h, 20h, 41h, 2
                db 41h, 2, 11h, 0A0h, 43h, 80h, 41h, 80h, 8, 80h, 41h
                db 30h, 11h, 0A0h, 42h, 3, 20h, 2, 41h, 23h, 0Ah, 41h
                db 20h, 11h, 0A0h, 42h, 8, 41h, 28h, 41h, 8Ah, 42h, 0ACh
                db 11h, 0A8h, 0A0h, 38h, 3Ah, 0A8h, 2Bh, 0A0h, 2Eh, 41h
                db 82h, 80h, 13h, 0AEh, 12h, 0BAh, 0A2h, 0BAh, 0A3h, 0A0h
                db 8, 11h, 0BAh, 0A8h, 0BAh, 2Ah, 11h, 0A0h, 80h, 8, 41h
                db 88h, 41h, 12h, 0A0h, 8, 2, 8Bh, 20h, 80h, 8, 41h, 20h
                db 41h, 11h, 0E2h, 0A0h, 42h, 0Ah, 80h, 80h, 8, 43h, 11h
                db 80h, 80h, 42h, 8, 80h, 41h, 8, 42h, 20h, 11h, 41h, 80h
                db 42h, 8, 42h, 8, 43h, 11h, 80h, 46h, 8, 43h, 11h, 80h
                db 4Ah, 11h, 0A0h, 4Ah, 11h, 0A8h, 42h, 38h, 0A8h, 0AEh
                db 0FAh, 0ABh, 0A3h, 41h, 8, 13h, 8Ah, 0EBh, 11h, 0BAh
                db 13h, 42h, 12h, 0A8h, 22h, 0B2h, 0Ah, 0C2h, 0A3h, 11h
                db 2Ah, 42h, 11h, 0AEh, 0A0h, 32h, 0A2h, 2, 80h, 0A2h
                db 11h, 0A8h, 41h, 8, 11h, 0BAh, 20h, 2Bh, 0A0h, 0Ah, 80h
                db 8Eh, 8Ah, 0A0h, 80h, 0B8h, 11h, 0A8h, 32h, 0Bh, 20h
                db 88h, 0C8h, 0Ah, 88h, 20h, 2, 8, 11h, 20h, 3Ah, 0A2h
                db 41h, 80h, 0CAh, 41h, 88h, 41h, 80h, 41h, 11h, 20h, 22h
                db 22h, 2, 80h, 88h, 41h, 8, 2, 42h, 11h, 2, 0B8h, 41h
                db 0Ch, 80h, 80h, 41h, 8, 2, 2, 41h, 11h, 82h, 22h, 41h
                db 8, 80h, 80h, 0C0h, 41h, 2, 2, 80h, 11h, 83h, 22h, 41h
                db 8, 80h, 2, 0A0h, 2, 0E0h, 2, 8, 11h, 82h, 42h, 80h
                db 80h, 3, 80h, 41h, 0A0h, 42h, 11h, 0A0h, 88h, 42h, 80h
                db 3, 41h, 0Ah, 0A8h, 41h, 20h, 11h, 0A8h, 2, 41h, 80h
                db 41h, 2, 41h, 0Ah, 88h, 41h, 8, 11h, 0A8h, 0A0h, 80h
                db 80h, 42h, 80h, 2, 20h, 41h, 0E0h, 11h, 0A2h, 3Ah, 20h
                db 0A2h, 80h, 8, 45h, 11h, 0B8h, 0FBh, 88h, 2, 80h, 0Ah
                db 80h, 42h, 20h, 41h, 11h, 0E0h, 0EFh, 80h, 8, 41h, 3Ah
                db 45h, 0A8h, 0A0h, 0A0h, 2, 28h, 41h, 2Ah, 88h, 20h, 41h
                db 20h, 41h, 0A8h, 41h, 2, 82h, 28h, 41h, 0Ah, 80h, 20h
                db 41h, 20h, 41h, 0A0h, 41h, 20h, 0FAh, 0A0h, 41h, 3Ah
                db 3, 41h, 0A0h, 42h, 0A2h, 2, 0Fh, 80h, 0A0h, 41h, 28h
                db 2, 41h, 0A0h, 20h, 41h, 0AEh, 0Ah, 3Ah, 20h, 28h, 41h
                db 8, 41h, 80h, 43h, 0ACh, 41h, 0E8h, 20h, 8, 41h, 8, 80h
                db 0A0h, 0Ah, 42h, 88h, 41h, 0C8h, 20h, 8, 41h, 0Ah, 41h
                db 0A0h, 43h, 88h, 22h, 82h, 22h, 88h, 41h, 32h, 41h, 80h
                db 2, 20h, 41h, 80h, 2, 2, 41h, 8, 41h, 22h, 42h, 20h
                db 20h, 41h, 0B8h, 20h, 2, 43h, 2, 41h, 0Ah, 2, 42h, 0B8h
                db 42h, 2, 80h, 41h, 8, 41h, 0Ah, 43h, 88h, 20h, 41h, 2
                db 42h, 8, 0Ah, 2, 41h, 20h, 41h, 80h, 41h, 2, 44h, 0Ah
                db 20h, 43h, 82h, 42h, 0Ah, 28h, 42h, 20h, 44h, 80h, 42h
                db 2, 28h, 80h, 41h, 20h, 44h, 11h, 2, 43h, 20h, 42h, 0Ch
                db 41h, 20h, 41h, 11h, 42h, 20h, 42h, 2, 20h, 0Ah, 2, 42h
                db 0A8h, 2, 41h, 20h, 41h, 20h, 2, 0Ah, 8, 28h, 42h, 11h
                db 43h, 2, 42h, 8, 41h, 2, 20h, 41h, 0A8h, 30h, 42h, 2
                db 8, 2, 45h, 0A0h, 0A0h, 41h, 0Ah, 8, 41h, 2, 42h, 8
                db 42h, 11h, 8, 41h, 0Ah, 0Ah, 20h, 2, 8, 0A0h, 43h, 11h
                db 0A0h, 42h, 8, 80h, 42h, 0A0h, 2, 20h, 41h, 0A8h, 42h
                db 20h, 2, 20h, 42h, 3, 8, 20h, 41h, 0A0h, 0E2h, 42h, 20h
                db 44h, 2, 42h, 0A0h, 8Ah, 42h, 20h, 80h, 41h, 2, 41h
                db 8, 42h, 0A8h, 8, 41h, 8, 44h, 30h, 2, 20h, 41h, 0A8h
                db 43h, 2, 42h, 20h, 41h, 88h, 20h, 41h, 11h, 42h, 82h
                db 2, 41h, 2, 42h, 2, 20h, 41h, 11h, 8, 41h, 20h, 43h
                db 22h, 44h, 11h, 2, 2, 2, 43h, 2, 44h, 11h, 42h, 28h
                db 41h, 8, 0Ah, 8, 44h, 11h, 8, 41h, 20h, 41h, 20h, 0Ah
                db 45h, 11h, 28h, 80h, 80h, 41h, 8, 43h, 2, 42h, 0A8h
                db 0A0h, 20h, 41h, 20h, 20h, 41h, 0F0h, 41h, 8, 88h, 41h
                db 0A2h, 42h, 8, 8, 88h, 23h, 42h, 2, 2, 80h, 0A0h, 41h
                db 22h, 41h, 20h, 41h, 0AFh, 42h, 0Eh, 41h, 20h, 11h, 0A8h
                db 80h, 41h, 80h, 41h, 0Ch, 41h, 8, 38h, 20h, 20h, 11h
                db 0A8h, 20h, 22h, 3, 0C2h, 80h, 42h, 8, 30h, 20h, 11h
                db 0A8h, 41h, 8, 0F3h, 80h, 80h, 2, 41h, 20h, 8, 80h, 11h
                db 0A8h, 80h, 41h, 30h, 80h, 41h, 8, 20h, 20h, 38h, 20h
                db 11h, 0A8h, 42h, 3Ch, 42h, 28h, 42h, 0E0h, 41h, 11h
                db 0A8h, 41h, 20h, 0Ch, 42h, 20h, 41h, 80h, 0A0h, 41h
                db 11h, 0A8h, 8, 28h, 0Ah, 42h, 20h, 41h, 80h, 20h, 41h
                db 11h, 0A8h, 41h, 20h, 2, 42h, 8, 8, 8, 8, 41h, 11h, 0A0h
                db 42h, 0A0h, 22h, 80h, 42h, 8, 42h, 11h, 82h, 43h, 28h
                db 46h, 0A8h, 43h, 0Ah, 80h, 2, 80h, 41h, 82h, 2, 41h
                db 0A0h, 43h, 28h, 41h, 22h, 80h, 44h, 0A0h, 44h, 2, 80h
                db 43h, 20h, 41h, 0A0h, 20h, 2, 42h, 8, 20h, 42h, 20h
                db 80h, 41h, 0A0h, 41h, 20h, 42h, 80h, 0A2h, 41h, 20h
                db 0Eh, 80h, 41h, 0A0h, 80h, 42h, 8, 0A8h, 20h, 42h, 0Ah
                db 42h, 0A0h, 80h, 43h, 2Ah, 41h, 2, 41h, 22h, 41h, 30h
                db 0A0h, 2, 80h, 42h, 28h, 43h, 3, 80h, 20h, 0A0h, 41h
                db 80h, 42h, 2, 41h, 2, 42h, 80h, 20h, 0A0h, 44h, 8, 42h
                db 20h, 8, 2, 41h, 0A0h, 42h, 20h, 80h, 28h, 82h, 41h
                db 20h, 8, 42h, 0A0h, 2, 42h, 8, 2, 82h, 80h, 44h, 0A0h
                db 41h, 8, 80h, 41h, 8, 2, 42h, 2, 41h, 20h, 0A0h, 41h
                db 8, 20h, 2, 80h, 45h, 20h, 0A0h, 8, 41h, 8, 80h, 2, 20h
                db 41h, 80h, 42h, 80h, 0A0h, 44h, 8, 20h, 41h, 20h, 42h
                db 0A0h, 0ACh, 41h, 80h, 41h, 28h, 8, 80h, 42h, 80h, 2
                db 80h, 0ACh, 41h, 20h, 41h, 2, 82h, 20h, 43h, 2, 80h
                db 0A0h, 41h, 2, 42h, 0A8h, 42h, 8, 42h, 0A0h, 0ACh, 80h
                db 42h, 20h, 0Ah, 80h, 43h, 22h, 20h, 0A0h, 43h, 2, 8
                db 80h, 44h, 80h, 0A0h, 82h, 43h, 2, 43h, 2, 41h, 80h
                db 0A0h, 8, 41h, 8, 20h, 88h, 80h, 43h, 2, 80h, 0A0h, 41h
                db 0Ah, 2, 88h, 22h, 80h, 41h, 80h, 8, 41h, 20h, 0A8h
                db 41h, 20h, 2Ah, 22h, 8, 42h, 20h, 0Ah, 41h, 80h, 11h
                db 47h, 20h, 41h, 2, 80h, 11h, 0A8h, 2, 22h, 2, 47h, 11h
                db 0A8h, 42h, 8, 46h, 80h, 12h, 8, 41h, 20h, 20h, 44h
                db 2, 41h, 11h, 0A8h, 41h, 80h, 80h, 88h, 46h, 12h, 43h
                db 2, 46h, 11h, 0A8h, 0A8h, 8Ah, 11h, 88h, 45h, 8, 11h
                db 80h, 49h, 20h, 11h, 2Ah, 2, 80h, 0Ah, 0A8h, 45h, 20h
                db 0A8h, 0A8h, 41h, 80h, 41h, 0A0h, 80h, 44h, 80h, 0A8h
                db 80h, 8, 80h, 20h, 2, 80h, 41h, 2Ah, 28h, 2Ah, 41h, 0A8h
                db 42h, 2, 88h, 0Ah, 42h, 8, 41h, 0Ah, 80h, 0A8h, 41h
                db 80h, 2, 41h, 8, 44h, 2, 80h, 0A8h, 41h, 80h, 42h, 8
                db 45h, 0A0h, 0A8h, 80h, 42h, 2, 42h, 20h, 43h, 80h, 0A8h
                db 0A0h, 42h, 2, 44h, 22h, 41h, 80h, 0A8h, 80h, 42h, 20h
                db 20h, 43h, 0A0h, 41h, 20h, 0A8h, 43h, 20h, 20h, 20h
                db 44h, 20h, 0A8h, 43h, 2, 42h, 20h, 2, 42h, 20h, 0A8h
                db 41h, 0Ah, 43h, 20h, 41h, 0Ah, 8, 41h, 20h, 0A8h, 41h
                db 0Ah, 43h, 80h, 8, 0Ah, 0Ah, 41h, 20h, 0A8h, 80h, 41h
                db 2, 8, 42h, 8, 43h, 80h, 0A8h, 80h, 42h, 8, 46h, 0A0h
                db 0A8h, 8, 44h, 28h, 44h, 20h, 0A8h, 45h, 80h, 8, 42h
                db 80h, 41h, 0A8h, 42h, 80h, 20h, 42h, 20h, 22h, 42h, 20h
                db 11h, 42h, 80h, 43h, 20h, 28h, 2, 41h, 80h, 0A8h, 43h
                db 80h, 45h, 82h, 41h, 0A8h, 46h, 2, 80h, 80h, 20h, 41h
                db 0A8h, 0Ah, 42h, 8, 80h, 80h, 80h, 8Ah, 82h, 80h, 41h
                db 0A8h, 0Ah, 41h, 2, 20h, 80h, 41h, 80h, 2, 2, 2, 20h
                db 0A8h, 41h, 8, 41h, 0A0h, 28h, 41h, 2, 41h, 82h, 20h
                db 41h, 0A8h, 8, 42h, 20h, 0A0h, 80h, 42h, 2, 8, 20h, 0A8h
                db 8, 43h, 88h, 41h, 8, 2, 41h, 8, 80h, 0A8h, 44h, 8, 42h
                db 8Ah, 80h, 22h, 20h, 11h, 43h, 0A0h, 0Ah, 41h, 0Ah, 88h
                db 41h, 28h, 41h, 11h, 80h, 41h, 0Ah, 82h, 20h, 41h, 88h
                db 20h, 41h, 82h, 41h, 11h, 0A8h, 49h, 8, 11h, 0A2h, 0A8h
                db 28h, 28h, 2Ah, 82h, 12h, 0A0h, 41h, 0A0h, 11h, 0Ah
                db 80h, 42h, 0Ah, 41h, 0Ah, 20h, 0A8h, 41h, 8, 0A8h, 0A8h
                db 2, 2, 80h, 43h, 80h, 42h, 8, 0A0h, 8Ah, 80h, 2Ah, 2
                db 0A2h, 82h, 0Ah, 44h, 0A0h, 41h, 2Ah, 0C8h, 2Bh, 0E2h
                db 0EEh, 0BAh, 0BAh, 0BEh, 11h, 80h, 0A0h, 0A8h, 43h, 3Ah
                db 3Ah, 12h, 0EAh, 80h, 41h, 0A2h, 80h, 42h, 8, 8, 42h
                db 20h, 0AEh, 82h, 41h, 0A0h, 2, 80h, 41h, 0A0h, 43h, 20h
                db 0Ah, 2, 20h, 0A2h, 2, 80h, 41h, 20h, 44h, 0Ah, 42h
                db 0A2h, 41h, 2, 42h, 20h, 42h, 20h, 42h, 20h, 0A2h, 45h
                db 20h, 41h, 20h, 8, 8, 20h, 0A2h, 45h, 20h, 43h, 28h
                db 41h, 0A0h, 41h, 82h, 43h, 80h, 8, 20h, 43h, 0A0h, 41h
                db 82h, 41h, 8, 41h, 80h, 41h, 82h, 2, 42h, 0A8h, 41h
                db 3, 80h, 42h, 0A0h, 8, 80h, 43h, 11h, 41h, 2, 42h, 82h
                db 0A8h, 43h, 80h, 41h, 0A8h, 41h, 23h, 42h, 80h, 0A0h
                db 20h, 80h, 43h, 0A8h, 41h, 2, 45h, 8Eh, 8, 41h, 20h
                db 0A0h, 2, 2, 80h, 41h, 20h, 42h, 0Eh, 80h, 8, 80h, 0A0h
                db 2, 2, 80h, 42h, 80h, 80h, 2, 80h, 8, 41h, 0A0h, 0Eh
                db 2, 80h, 80h, 41h, 80h, 41h, 8Eh, 42h, 80h, 0A0h, 8
                db 2, 80h, 41h, 20h, 20h, 41h, 8Eh, 41h, 82h, 20h, 0A8h
                db 8, 2, 41h, 22h, 20h, 42h, 0Eh, 41h, 2, 80h, 0A0h, 8
                db 2, 80h, 2, 41h, 80h, 8, 0Ah, 41h, 2, 41h, 0A0h, 41h
                db 0Ah, 80h, 2, 42h, 8, 0Eh, 0C0h, 8, 80h, 0A0h, 41h, 0Eh
                db 41h, 82h, 42h, 28h, 0Ah, 80h, 2, 41h, 0A8h, 8, 0Ah
                db 41h, 0Bh, 43h, 0Eh, 80h, 28h, 41h, 0A8h, 0Ah, 2, 80h
                db 0Ah, 80h, 41h, 80h, 3Ah, 41h, 22h, 41h, 0A0h, 8, 8Bh
                db 80h, 0Bh, 82h, 80h, 88h, 3Ah, 82h, 88h, 41h, 0A0h, 38h
                db 0Bh, 80h, 0Eh, 0Ah, 0EEh, 0Ah, 0E2h, 2, 22h, 41h, 0A0h
                db 28h, 3Ah, 80h, 0A8h, 8Bh, 0A2h, 0A8h, 11h, 80h, 8, 41h
                db 0A0h, 38h, 22h, 0A0h, 3Ah, 3, 88h, 0BAh, 0A2h, 20h
                db 22h, 41h, 0A2h, 8, 3Ah, 80h, 0BAh, 88h, 0A0h, 0CAh
                db 82h, 88h, 8, 41h, 0A2h, 0Ch, 2Bh, 2Ah, 11h, 0Ah, 2Ah
                db 0E2h, 22h, 88h, 22h, 41h, 0A2h, 8, 0ABh, 88h, 0E8h
                db 82h, 0A2h, 0CAh, 8Ah, 20h, 88h, 41h, 0A2h, 38h, 11h
                db 8, 0EAh, 8, 11h, 0A8h, 0A2h, 28h, 2, 41h, 0A0h, 0EAh
                db 28h, 8Eh, 0A8h, 0A3h, 0A8h, 82h, 88h, 88h, 80h, 41h
                db 0A2h, 11h, 0A2h, 22h, 22h, 2, 0A2h, 22h, 22h, 22h, 42h
                db 0A2h, 8, 88h, 0Ah, 82h, 20h, 2, 8, 8, 43h, 0
title_frame1_data db 4Ch, 0A0h, 43h, 3Ah, 0EBh, 0EEh, 0A0h, 44h, 0A0h, 42h
                db 3, 13h, 0AEh, 44h, 0A0h, 41h, 0EAh, 8Eh, 0A8h, 8Ah
                db 0EAh, 0A8h, 8Fh, 0A8h, 42h, 0A0h, 0Eh, 11h, 3Eh, 22h
                db 88h, 0A8h, 0A8h, 3Ah, 0A2h, 80h, 41h, 0A0h, 3Ah, 28h
                db 3Ah, 8Eh, 8Ah, 0A2h, 11h, 3Ah, 0BAh, 20h, 41h, 0A0h
                db 0EAh, 0A2h, 3Ah, 22h, 11h, 0A2h, 0A8h, 28h, 0ABh, 88h
                db 41h, 0A3h, 0A2h, 28h, 0E8h, 0A3h, 11h, 0A8h, 0EAh, 8
                db 8Ah, 0B2h, 41h, 0A3h, 11h, 20h, 0EAh, 0A8h, 0EAh, 0A3h
                db 0A8h, 8Ah, 0ABh, 0A2h, 41h, 0AEh, 8Ah, 28h, 0EAh, 28h
                db 0E8h, 0Eh, 11h, 0Eh, 11h, 8, 80h, 0AEh, 2Eh, 0A0h, 0EAh
                db 0EAh, 3, 0A3h, 0A8h, 8Eh, 11h, 0A0h, 80h, 0ACh, 0AEh
                db 0A8h, 0EAh, 11h, 0A8h, 0EAh, 11h, 0Eh, 8Ah, 88h, 80h
                db 0ACh, 0AEh, 0A0h, 3Ah, 11h, 0A8h, 0EAh, 0A8h, 3Ah, 0BAh
                db 0A8h, 80h, 0A0h, 0BAh, 0A8h, 3Ah, 11h, 23h, 11h, 0A2h
                db 3Ah, 11h, 82h, 41h, 0A3h, 0EAh, 11h, 3Ah, 0AEh, 83h
                db 0A8h, 0A8h, 3Ah, 11h, 22h, 41h, 0A3h, 11h, 0A8h, 8Eh
                db 0BAh, 8Eh, 0ABh, 0A0h, 0EAh, 11h, 82h, 41h, 0E2h, 0EAh
                db 11h, 0Eh, 11h, 2Ah, 11h, 0A8h, 0E8h, 11h, 8, 41h, 0A0h
                db 0EAh, 11h, 8Eh, 0A8h, 0ABh, 11h, 20h, 0EBh, 0A8h, 88h
                db 41h, 0E2h, 3Ah, 11h, 23h, 13h, 83h, 11h, 0A2h, 20h
                db 41h, 0E0h, 0BAh, 11h, 83h, 13h, 23h, 11h, 0A8h, 20h
                db 41h, 0E2h, 2Eh, 0A2h, 23h, 12h, 88h, 83h, 0A8h, 80h
                db 80h, 41h, 0E0h, 8Eh, 88h, 80h, 0EAh, 0A2h, 22h, 0Eh
                db 0A2h, 20h, 80h, 41h, 0A2h, 23h, 42h, 0C8h, 80h, 41h
                db 0Ch, 20h, 2, 42h, 0E0h, 0FEh, 0BEh, 0F3h, 0FBh, 0EAh
                db 0EEh, 0EAh, 0EBh, 0FAh, 0E8h, 41h, 0E2h, 0FAh, 11h
                db 0A3h, 13h, 0AEh, 12h, 88h, 41h, 0A0h, 0EAh, 11h, 8Eh
                db 11h, 0ABh, 14h, 88h, 41h, 0A2h, 0EAh, 11h, 8Eh, 0A8h
                db 14h, 0EAh, 0A8h, 41h, 0A0h, 0EAh, 11h, 3Ah, 0ABh, 12h
                db 8Ah, 12h, 88h, 41h, 0E2h, 11h, 0A8h, 0EAh, 13h, 0BAh
                db 12h, 8, 41h, 0E0h, 0EAh, 0A3h, 16h, 88h, 88h, 41h, 0E2h
                db 11h, 0A3h, 11h, 0A2h, 8Ah, 28h, 22h, 22h, 22h, 8, 41h
                db 0E2h, 11h, 3, 80h, 8, 45h, 8, 41h, 0E2h, 49h, 20h, 41h
                db 0E0h, 88h, 0FAh, 0EAh, 0AEh, 0BAh, 0AEh, 0AFh, 12h
                db 80h, 41h, 0E2h, 23h, 11h, 0A8h, 0BAh, 0BAh, 22h, 41h
                db 11h, 0A8h, 42h, 0E0h, 8Eh, 0AEh, 8Ah, 11h, 28h, 80h
                db 2Ah, 0A8h, 11h, 80h, 41h, 0E2h, 3Ah, 0A8h, 82h, 11h
                db 0A2h, 2, 0A8h, 0A8h, 11h, 30h, 41h, 0A0h, 11h, 0A2h
                db 0Eh, 11h, 88h, 0Ah, 12h, 0EAh, 8Ch, 41h, 0E2h, 0E8h
                db 0A8h, 3Ah, 11h, 20h, 2Ah, 13h, 8, 41h, 0E0h, 0EEh, 80h
                db 0EAh, 11h, 80h, 12h, 0BAh, 11h, 82h, 41h, 0E2h, 0EAh
                db 88h, 0EAh, 0A8h, 80h, 11h, 0Ah, 11h, 8Ah, 22h, 41h
                db 0A3h, 0A2h, 83h, 11h, 0A2h, 2, 0A8h, 0BAh, 11h, 0A8h
                db 82h, 41h, 0E3h, 8Ah, 83h, 11h, 0A8h, 2, 11h, 0EAh, 11h
                db 22h, 2, 41h, 0E3h, 8Bh, 23h, 11h, 0A0h, 0Ah, 12h, 0A8h
                db 88h, 2, 41h, 0E3h, 8Ah, 83h, 11h, 88h, 0Ah, 12h, 0A2h
                db 41h, 28h, 41h, 0A3h, 0EAh, 0A3h, 11h, 0A0h, 0Ah, 12h
                db 0A8h, 3Eh, 88h, 41h, 0A3h, 8Ah, 83h, 11h, 88h, 2Ah
                db 0ABh, 11h, 83h, 80h, 8, 41h, 0E2h, 8Ah, 0A0h, 0EAh
                db 0A0h, 2Ah, 11h, 2Ah, 0Ch, 28h, 20h, 41h, 0E2h, 8Eh
                db 88h, 0EAh, 88h, 8Ah, 0BAh, 2Ah, 30h, 0EAh, 20h, 41h
                db 0E8h, 0CAh, 0A0h, 0EAh, 0A0h, 2Ch, 0EAh, 8, 0C2h, 0ABh
                db 20h, 41h, 0E0h, 0E2h, 0A8h, 3Ah, 0A8h, 8Ah, 11h, 8
                db 82h, 0BFh, 20h, 41h, 0E8h, 0A2h, 0A8h, 3Eh, 11h, 22h
                db 0A0h, 0Ah, 33h, 0EFh, 8, 41h, 0A0h, 83h, 0A8h, 0Eh
                db 12h, 88h, 2Ah, 2Ah, 0AEh, 88h, 41h, 0E8h, 3Eh, 0EAh
                db 0Bh, 2Ah, 22h, 20h, 2Ah, 8Eh, 0A2h, 82h, 41h, 0E2h
                db 38h, 0A8h, 0Ah, 0C8h, 88h, 80h, 11h, 0A2h, 0A8h, 82h
                db 41h, 0E0h, 0E2h, 0BAh, 0Ah, 0B0h, 20h, 2, 11h, 0A8h
                db 0F2h, 20h, 80h, 0A3h, 8Ah, 2Ah, 0Ah, 0AFh, 41h, 0Ah
                db 11h, 0BAh, 8, 88h, 80h, 0E3h, 8Ch, 38h, 8Ah, 83h, 0FAh
                db 12h, 8Ah, 0A2h, 22h, 20h, 0E2h, 0A3h, 11h, 0Ah, 0Eh
                db 8, 13h, 88h, 0C8h, 20h, 0E2h, 11h, 88h, 23h, 38h, 0FAh
                db 2Ah, 0EAh, 11h, 0A0h, 0E2h, 8, 0E0h, 0A2h, 20h, 33h
                db 33h, 8, 2Ah, 12h, 88h, 0A8h, 80h, 0E2h, 20h, 3, 83h
                db 3Bh, 8, 2Ah, 0EAh, 11h, 20h, 11h, 41h, 0E8h, 8Eh, 0CAh
                db 80h, 0F2h, 0A0h, 2Ah, 2Ah, 11h, 80h, 0E8h, 80h, 0E2h
                db 2Ah, 0A2h, 23h, 0ECh, 41h, 13h, 41h, 88h, 41h, 0EAh
                db 0EBh, 0A3h, 0A3h, 2Eh, 0A8h, 13h, 80h, 80h, 41h, 0EBh
                db 80h, 0A0h, 0E0h, 0A8h, 2, 13h, 82h, 42h, 0EEh, 82h
                db 0A0h, 0A8h, 2Eh, 0A8h, 13h, 0A2h, 88h, 41h, 0EEh, 0Ah
                db 0A8h, 0A8h, 0BAh, 11h, 2Ah, 12h, 82h, 0A0h, 41h, 0EEh
                db 82h, 0A0h, 0A8h, 3Ah, 0A8h, 2Ah, 2Eh, 11h, 0Ah, 0A8h
                db 41h, 0ACh, 11h, 88h, 0A0h, 0BAh, 0A0h, 2Ah, 82h, 11h
                db 8Ah, 0A2h, 41h, 0EBh, 0Ah, 41h, 0A8h, 3Ah, 0A8h, 11h
                db 8Ah, 11h, 0Ah, 0A8h, 41h, 0EAh, 0C0h, 3, 0A0h, 0BAh
                db 0A0h, 2Ah, 8Ah, 0AEh, 8Ah, 0A0h, 41h, 0EAh, 0BEh, 0BAh
                db 0A8h, 3Ah, 0A8h, 11h, 2Ah, 0A2h, 0Ah, 80h, 41h, 0ABh
                db 0EAh, 11h, 0A0h, 0BAh, 0A0h, 0EEh, 12h, 82h, 8Ah, 80h
                db 0EEh, 0A0h, 2Ah, 88h, 3Ah, 88h, 0A2h, 11h, 2Ah, 0A2h
                db 0A8h, 20h, 0FAh, 8Ah, 0CAh, 0A0h, 0BAh, 0A0h, 0EAh
                db 12h, 82h, 0A2h, 20h, 0BAh, 2Ah, 0BAh, 80h, 3Ah, 88h
                db 13h, 0A0h, 0A8h, 20h, 0EAh, 3Ah, 0EAh, 22h, 0BAh, 20h
                db 11h, 0A2h, 11h, 0A8h, 0A0h, 80h, 0EAh, 8Fh, 0A8h, 82h
                db 3Ah, 80h, 8Ah, 13h, 28h, 80h, 0EAh, 11h, 0A2h, 8, 0B2h
                db 20h, 88h, 12h, 0A2h, 20h, 80h, 0B2h, 0A8h, 88h, 2, 28h
                db 0Ah, 30h, 8, 11h, 8Ah, 82h, 41h, 0FCh, 2, 41h, 8, 12h
                db 8Eh, 80h, 22h, 0A2h, 2, 41h, 0E3h, 0C0h, 3, 22h, 0A2h
                db 11h, 0A0h, 3Bh, 41h, 88h, 82h, 41h, 88h, 88h, 88h, 8Ah
                db 11h, 8Ah, 88h, 80h, 0E8h, 41h, 8, 41h, 0E2h, 2Fh, 0FFh
                db 0FFh, 0Ah, 11h, 0A2h, 22h, 3, 0A0h, 8, 41h, 0C8h, 0FAh
                db 12h, 0A0h, 0A2h, 2Ah, 88h, 80h, 0Ah, 0A0h, 41h, 0E3h
                db 0AEh, 2Eh, 0BAh, 2Ah, 2Ah, 11h, 0A2h, 20h, 43h, 0CEh
                db 0EAh, 28h, 0A8h, 0A8h, 8Ah, 0BFh, 0E8h, 88h, 43h, 2Ah
                db 0A8h, 0A8h, 0A8h, 11h, 0Ah, 0EAh, 0BAh, 22h, 43h, 0BAh
                db 8Ah, 0A8h, 0A8h, 11h, 0A3h, 11h, 20h, 88h, 43h, 0FAh
                db 2Ah, 0A8h, 12h, 83h, 11h, 82h, 2Fh, 3, 0F0h, 41h, 0FAh
                db 2Ah, 0A8h, 12h, 0A3h, 11h, 23h, 0BAh, 0A2h, 0A8h, 41h
                db 0FAh, 2Ah, 11h, 0AEh, 11h, 3, 0A2h, 2, 0EAh, 88h, 0EAh
                db 41h, 0FAh, 2Ch, 11h, 0A2h, 0AEh, 22h, 28h, 0Ah, 2Ah
                db 0A0h, 88h, 41h, 0FAh, 14h, 3, 80h, 28h, 2Ah, 80h, 8Ah
                db 41h, 0FAh, 11h, 0A8h, 11h, 0A8h, 0A2h, 0C0h, 80h, 22h
                db 20h, 20h, 41h, 0BAh, 0ABh, 11h, 0A2h, 11h, 82h, 0B0h
                db 20h, 0B8h, 2, 42h, 0BAh, 0A8h, 11h, 0E2h, 11h, 82h
                db 0ACh, 8, 0A0h, 8, 42h, 0BAh, 11h, 0ABh, 11h, 0A8h, 82h
                db 0ABh, 0C0h, 22h, 22h, 42h, 0BAh, 12h, 8Ah, 0A2h, 20h
                db 11h, 0BFh, 44h, 0BAh, 13h, 0A8h, 2, 12h, 0FFh, 0FFh
                db 0FFh, 0C0h, 0BAh, 11h, 82h, 20h, 22h, 41h, 11h, 0A2h
                db 13h, 20h, 0BAh, 20h, 43h, 2, 2Ah, 8Ah, 2Ah, 12h, 20h
                db 0BFh, 0FFh, 0BFh, 0EBh, 0EEh, 0B8h, 8Ah, 8Ah, 11h, 0A2h
                db 11h, 20h, 0EAh, 0BAh, 0BAh, 11h, 0A8h, 0E8h, 2Ah, 0BAh
                db 11h, 0A2h, 11h, 20h, 0EAh, 0AFh, 0EAh, 8Ah, 0A8h, 0E0h
                db 8Ah, 12h, 8Ah, 28h, 20h, 0EAh, 11h, 2Ah, 11h, 83h, 88h
                db 2Ah, 12h, 8Ah, 0EAh, 20h, 0E2h, 8Ah, 2Bh, 11h, 3Ah
                db 0A0h, 8Ah, 13h, 0A8h, 20h, 0E0h, 2Ah, 28h, 0A8h, 0EAh
                db 88h, 2Ah, 8Ah, 0A2h, 11h, 0A2h, 20h, 0E3h, 11h, 2Ah
                db 80h, 0EAh, 0A0h, 8Ah, 8Ah, 0AEh, 11h, 0A8h, 20h, 0EAh
                db 11h, 28h, 38h, 0EAh, 88h, 2Ah, 2Ah, 12h, 0A2h, 20h
                db 0EAh, 0A8h, 0A3h, 12h, 0A0h, 8Ah, 13h, 0A8h, 20h, 0EAh
                db 14h, 0A8h, 14h, 0A2h, 20h, 0EAh, 14h, 0A8h, 14h, 0A8h
                db 20h, 0C0h, 44h, 2, 14h, 0A2h, 20h, 0EAh, 11h, 0AEh
                db 12h, 0A2h, 12h, 2Ah, 11h, 0A8h, 20h, 0B2h, 0BAh, 2Ah
                db 2Bh, 8Ah, 0A2h, 12h, 2Ah, 8Ah, 0A2h, 20h, 0B8h, 11h
                db 2Ah, 11h, 2Ah, 0A2h, 14h, 28h, 20h, 0BCh, 0AEh, 2Ah
                db 2Ah, 11h, 0A2h, 14h, 0A2h, 20h, 0B8h, 11h, 2Ah, 0EAh
                db 11h, 0A2h, 0A8h, 11h, 0A8h, 0A2h, 0A8h, 20h, 0FAh, 0A8h
                db 13h, 0A2h, 0A2h, 11h, 0A8h, 11h, 0A2h, 20h, 0BAh, 0A8h
                db 12h, 8Ah, 0A2h, 13h, 2Ah, 0A8h, 20h, 0BAh, 0ABh, 12h
                db 0BAh, 0A2h, 11h, 0A2h, 0AEh, 2Ah, 22h, 20h, 0EAh, 14h
                db 2, 11h, 0A2h, 0AEh, 2Ah, 88h, 20h, 0EAh, 13h, 0A8h
                db 0A2h, 11h, 0E2h, 11h, 2Ah, 20h, 20h, 14h, 0A8h, 0B2h
                db 2Ah, 11h, 88h, 88h, 88h, 20h, 0EAh, 13h, 82h, 0B2h
                db 8Ah, 0A8h, 43h, 20h, 0EAh, 13h, 2Bh, 0C3h, 11h, 45h
                db 0FEh, 0FBh, 0AFh, 0A8h, 41h, 2, 0A0h, 2, 2, 43h, 0EAh
                db 8Ah, 12h, 0A2h, 42h, 11h, 0A8h, 88h, 42h, 8Ah, 11h
                db 2Ah, 11h, 88h, 0Bh, 0FFh, 0FFh, 0Fh, 0FFh, 0C0h, 41h
                db 0CAh, 0A8h, 82h, 22h, 20h, 13h, 8Eh, 11h, 0A8h, 41h
                db 0C2h, 80h, 43h, 2Ah, 11h, 0A2h, 8Eh, 12h, 41h, 80h
                db 0EAh, 13h, 82h, 11h, 0A8h, 0Eh, 12h, 41h, 0C3h, 11h
                db 0EAh, 12h, 0A8h, 12h, 8Eh, 11h, 0A2h, 41h, 0C3h, 0AEh
                db 12h, 0ABh, 11h, 2Ah, 11h, 8Eh, 12h, 41h, 0CEh, 13h
                db 0A8h, 0EAh, 2Ah, 11h, 8Eh, 12h, 41h, 0CAh, 11h, 0ABh
                db 12h, 3Ah, 8Ah, 11h, 8Eh, 0CAh, 11h, 41h, 0FAh, 8Ah
                db 11h, 0A8h, 11h, 3Ah, 8Ah, 11h, 8Eh, 0BAh, 11h, 41h
                db 0FBh, 0A2h, 11h, 2Ah, 11h, 32h, 8Ah, 11h, 8Eh, 12h
                db 41h, 0FAh, 8Ch, 0A3h, 0A8h, 0EAh, 3Ah, 8Ah, 11h, 8Eh
                db 12h, 41h, 0BAh, 8Ch, 0A3h, 0A8h, 0EAh, 32h, 8Ah, 11h
                db 0Eh, 12h, 41h, 0BAh, 8Eh, 0A3h, 0A8h, 0E8h, 3Ah, 0Ah
                db 0ABh, 8Eh, 11h, 8Ah, 41h, 0FAh, 0Eh, 0A3h, 0A0h, 0E2h
                db 0Eh, 8Ah, 0ABh, 8Eh, 12h, 41h, 0F2h, 8Eh, 83h, 28h
                db 0EAh, 41h, 3Ah, 0ABh, 8Fh, 12h, 41h, 0BAh, 0Ch, 0A3h
                db 0A0h, 0C8h, 20h, 0A8h, 11h, 0CEh, 0EAh, 11h, 41h, 0FAh
                db 0Ch, 0A3h, 28h, 0CAh, 2Ah, 0A2h, 11h, 0CEh, 0EAh, 11h
                db 41h, 0F2h, 8Eh, 23h, 28h, 0E8h, 0Eh, 0B2h, 11h, 8Eh
                db 0BAh, 11h, 41h, 0F8h, 8Ch, 0A3h, 88h, 0CAh, 0Ch, 0Ch
                db 11h, 8Eh, 0BAh, 11h, 41h, 0B2h, 8Ch, 83h, 28h, 0CAh
                db 0Eh, 0CAh, 2Ah, 8Eh, 0BAh, 11h, 41h, 0F0h, 0Eh, 3, 8
                db 0C2h, 0Eh, 0B3h, 2Ah, 8Eh, 0EAh, 11h, 41h, 0FCh, 2Bh
                db 0Eh, 0C2h, 0B0h, 8Ch, 11h, 0CAh, 8Fh, 12h, 41h, 0BAh
                db 11h, 8Eh, 12h, 8Eh, 12h, 8Ch, 12h, 41h, 0BAh, 11h, 8Ch
                db 12h, 8Ch, 12h, 8Eh, 12h, 41h, 0F2h, 11h, 8Eh, 12h, 8Ch
                db 12h, 8Eh, 11h, 0A8h, 41h, 0FAh, 11h, 8Ch, 12h, 8Eh
                db 12h, 8Ch, 11h, 0A8h, 41h, 0F2h, 11h, 8Ch, 12h, 8Ch
                db 12h, 8Ch, 8Ah, 0A8h, 41h, 0F8h, 11h, 8Eh, 12h, 8Ch
                db 2Ah, 11h, 8Eh, 11h, 0A2h, 41h, 0F0h, 2Ah, 8Ch, 22h
                db 11h, 8Ch, 0A2h, 11h, 8Ch, 82h, 20h, 41h, 0F0h, 82h
                db 8Ch, 8, 22h, 8Ch, 8, 82h, 0BCh, 20h, 42h, 0C8h, 80h
                db 4Ah, 0E2h, 3Ah, 17h, 80h, 42h, 0CBh, 0EAh, 17h, 0A8h
                db 82h, 41h, 0EEh, 19h, 20h, 80h, 0BAh, 15h, 0A2h, 82h
                db 88h, 88h, 80h, 41h, 0FFh, 0FFh, 0EBh, 3Fh, 0FFh, 0BBh
                db 0BAh, 0EBh, 0EAh, 0FAh, 11h, 80h, 0FAh, 11h, 0BAh, 8Fh
                db 11h, 0E8h, 0E2h, 0A2h, 0ABh, 12h, 80h, 0BAh, 0BAh, 0A8h
                db 8Ah, 11h, 0A2h, 12h, 8Ah, 0B8h, 11h, 41h, 0BAh, 11h
                db 2Ah, 0A2h, 0E8h, 13h, 8Ah, 11h, 0EAh, 80h, 0FBh, 8Ah
                db 12h, 0E2h, 14h, 0A2h, 8Ah, 41h, 0FBh, 8Ah, 11h, 0A6h
                db 0A2h, 15h, 0EAh, 80h, 0FEh, 8Ah, 11h, 0AFh, 0A2h, 15h
                db 2Ah, 80h, 0FAh, 8Ah, 11h, 0AEh, 0E2h, 14h, 0AEh, 11h
                db 80h, 0BEh, 11h, 0A8h, 0AEh, 0A2h, 14h, 0AEh, 0A0h, 41h
                db 0FAh, 11h, 0A8h, 0E6h, 16h, 8Eh, 41h, 0EAh, 11h, 0AEh
                db 0Eh, 15h, 0BAh, 8Ah, 41h, 0C2h, 11h, 0A8h, 0EAh, 15h
                db 3Ah, 0A8h, 80h, 0CEh, 11h, 0AEh, 11h, 0Ah, 13h, 0A8h
                db 8Eh, 11h, 41h, 0CAh, 12h, 0A8h, 0A2h, 11h, 0A0h, 0ABh
                db 8Ah, 0A3h, 0A8h, 80h, 0BAh, 12h, 28h, 0AEh, 11h, 0Bh
                db 11h, 0BAh, 0A8h, 0EAh, 41h, 0BAh, 0A8h, 11h, 2Ah, 3Ah
                db 0A8h, 0ABh, 12h, 0A8h, 0E8h, 41h, 0BAh, 0B0h, 0A2h
                db 2Ah, 11h, 0A0h, 0AEh, 11h, 0B8h, 0A8h, 11h, 41h, 0FAh
                db 0A2h, 0A2h, 2Ah, 11h, 0A2h, 0AEh, 11h, 88h, 11h, 38h
                db 80h, 0CEh, 0A2h, 0A8h, 12h, 0A8h, 0FAh, 11h, 88h, 11h
                db 3Ah, 41h, 0FAh, 12h, 2Ah, 11h, 2Ah, 12h, 0A8h, 0A8h
                db 0E8h, 41h, 0BAh, 11h, 8Ah, 12h, 2Ah, 12h, 0B8h, 11h
                db 0A2h, 41h, 0BAh, 2Ah, 0B8h, 12h, 2Ah, 13h, 2Ah, 88h
                db 41h, 0CAh, 2Ah, 0A8h, 11h, 0ABh, 13h, 0BAh, 2Ah, 0A0h
                db 41h, 0CAh, 22h, 11h, 2Ah, 13h, 82h, 28h, 28h, 88h, 41h
                db 0BAh, 20h, 0AEh, 2Ah, 0ABh, 8Ah, 8Ah, 88h, 0EAh, 2Ah
                db 20h, 41h, 0FAh, 0E2h, 0AEh, 2Ah, 0AEh, 0Ah, 0EEh, 2Ah
                db 88h, 8, 88h, 41h, 0FAh, 22h, 0EAh, 0Ah, 0A8h, 8Bh, 0A2h
                db 0A8h, 11h, 41h, 20h, 41h, 0FAh, 0E2h, 11h, 88h, 3Ah
                db 3, 88h, 0BAh, 88h, 80h, 88h, 41h, 0FAh, 22h, 0EAh, 8
                db 3Ah, 88h, 0A0h, 0CAh, 0Ah, 20h, 42h, 0BAh, 0B2h, 0ACh
                db 0A0h, 11h, 0Ah, 28h, 0E2h, 0Ah, 20h, 88h, 41h, 0BAh
                db 0A0h, 0AEh, 20h, 0E8h, 82h, 82h, 0CAh, 28h, 82h, 42h
                db 0FAh, 0E0h, 28h, 20h, 0EAh, 8, 8Ah, 0A8h, 88h, 0A0h
                db 8, 41h, 0BBh, 0A8h, 22h, 38h, 0A8h, 0A3h, 8, 82h, 20h
                db 22h, 42h, 0BAh, 11h, 88h, 88h, 22h, 2, 2, 22h, 80h
                db 88h, 42h, 0F8h, 22h, 20h, 28h, 82h, 20h, 2, 8, 20h
                db 43h, 0
title_frame2_data db 1Ch, 0Ah, 13h, 0BAh, 0EBh, 0EEh, 15h, 0Ah, 12h, 0ABh
                db 13h, 0AEh, 14h, 0Ah, 11h, 0EAh, 0AEh, 0A8h, 8Ah, 0EAh
                db 0A8h, 0AFh, 13h, 0Ah, 0AEh, 11h, 3Eh, 20h, 88h, 0A8h
                db 41h, 3Ah, 0A2h, 12h, 0Ah, 0BAh, 28h, 3Ah, 80h, 80h
                db 20h, 20h, 3Ah, 0BAh, 2Ah, 11h, 0Ah, 0EAh, 0A2h, 3Ah
                db 42h, 20h, 20h, 28h, 0ABh, 8Ah, 11h, 8, 0A2h, 8, 0E8h
                db 42h, 20h, 41h, 8, 82h, 0B2h, 11h, 8, 0A2h, 41h, 0E0h
                db 44h, 88h, 83h, 0A2h, 11h, 41h, 82h, 28h, 46h, 2, 8
                db 11h, 42h, 20h, 45h, 80h, 2, 41h, 11h, 41h, 20h, 88h
                db 41h, 20h, 42h, 82h, 42h, 8, 11h, 41h, 20h, 41h, 2, 2
                db 42h, 88h, 8, 2, 8, 11h, 8, 80h, 88h, 41h, 0Ah, 42h
                db 2, 8, 41h, 2, 11h, 8, 2, 82h, 2, 2Eh, 80h, 20h, 8, 8
                db 0A0h, 22h, 11h, 8, 42h, 80h, 3Ah, 80h, 41h, 20h, 20h
                db 0A0h, 2, 11h, 41h, 2, 88h, 41h, 2Ah, 42h, 28h, 20h
                db 41h, 0Ah, 11h, 41h, 20h, 80h, 41h, 88h, 3, 80h, 20h
                db 20h, 41h, 8Ah, 11h, 41h, 8, 20h, 20h, 8, 2, 80h, 80h
                db 80h, 2, 2Ah, 11h, 41h, 88h, 41h, 80h, 41h, 80h, 2, 20h
                db 88h, 8, 2Ah, 11h, 2, 22h, 80h, 20h, 0Ah, 41h, 8, 80h
                db 41h, 80h, 12h, 41h, 82h, 88h, 80h, 41h, 22h, 22h, 2
                db 0A2h, 20h, 12h, 2, 20h, 43h, 80h, 42h, 20h, 2, 12h
                db 41h, 0FEh, 0BEh, 0F0h, 0FBh, 0EAh, 0EEh, 0EAh, 0EBh
                db 0FAh, 0EAh, 11h, 2, 0Ah, 11h, 0A0h, 0A0h, 11h, 0A0h
                db 2Eh, 41h, 2Ah, 8Ah, 11h, 41h, 2Ah, 20h, 80h, 80h, 0Bh
                db 80h, 28h, 41h, 0Ah, 0Ah, 11h, 41h, 20h, 82h, 80h, 80h
                db 2, 41h, 8, 41h, 8, 0Ah, 11h, 42h, 82h, 42h, 2, 44h
                db 0Ah, 11h, 45h, 2, 44h, 0Ah, 11h, 4Ah, 0Ah, 11h, 4Ah
                db 0Ah, 11h, 2, 49h, 0Ah, 11h, 2, 49h, 2Ah, 11h, 41h, 88h
                db 0FAh, 0EAh, 0AEh, 0BAh, 0AEh, 0AFh, 14h, 2, 3, 11h
                db 0A8h, 3Ah, 0BAh, 22h, 41h, 0A2h, 13h, 41h, 0Eh, 0AEh
                db 80h, 0Ah, 28h, 80h, 41h, 8, 2, 12h, 2, 3Ah, 0A8h, 41h
                db 0Ah, 43h, 8, 41h, 3Ah, 11h, 41h, 2Ah, 0A0h, 41h, 2
                db 44h, 0E0h, 0Eh, 11h, 41h, 0E8h, 0A8h, 43h, 2, 41h, 8
                db 0A0h, 0Ah, 11h, 41h, 0ECh, 80h, 41h, 80h, 43h, 38h
                db 42h, 11h, 41h, 0EAh, 80h, 2, 47h, 11h, 3, 0A0h, 80h
                db 48h, 11h, 3, 80h, 80h, 45h, 80h, 42h, 11h, 3, 83h, 41h
                db 0Ah, 42h, 20h, 44h, 11h, 3, 82h, 41h, 8Ah, 43h, 8, 42h
                db 2, 11h, 3, 0C2h, 41h, 80h, 41h, 2, 44h, 2, 11h, 3, 44h
                db 0Ah, 80h, 43h, 2, 11h, 43h, 0Ah, 41h, 2, 2, 42h, 38h
                db 0Ah, 11h, 45h, 80h, 3Ah, 42h, 3Ah, 0Ah, 11h, 45h, 2Ch
                db 0E8h, 41h, 3, 0EFh, 0Ah, 11h, 45h, 0Ah, 0A0h, 41h, 2
                db 0BFh, 0Ah, 11h, 8, 41h, 8, 41h, 0A0h, 44h, 0Fh, 2, 11h
                db 41h, 80h, 0A8h, 41h, 20h, 45h, 2, 11h, 8, 41h, 2Ah
                db 48h, 11h, 2, 41h, 88h, 44h, 0Ah, 43h, 11h, 41h, 2, 8Ah
                db 48h, 2Ah, 41h, 0Ah, 2, 2, 47h, 2Ah, 43h, 8Ah, 47h, 0Ah
                db 42h, 0Ah, 8, 42h, 8, 2, 43h, 0Ah, 42h, 8, 20h, 43h
                db 0E0h, 8, 42h, 2, 47h, 0A0h, 8, 42h, 82h, 2, 49h, 2
                db 41h, 8, 80h, 44h, 8, 2, 42h, 28h, 80h, 2, 49h, 88h
                db 2, 41h, 8, 43h, 0A8h, 41h, 80h, 20h, 42h, 0Ah, 47h
                db 80h, 20h, 42h, 11h, 41h, 82h, 20h, 42h, 0A8h, 45h, 11h
                db 41h, 0Ah, 28h, 42h, 2Ah, 43h, 2, 41h, 11h, 42h, 20h
                db 41h, 2, 8, 2, 42h, 8, 41h, 2Ah, 41h, 0A0h, 88h, 41h
                db 2, 41h, 2, 80h, 41h, 8, 41h, 2Ah, 41h, 0Ah, 43h, 88h
                db 82h, 80h, 41h, 8, 41h, 2Ah, 8, 44h, 80h, 41h, 80h, 41h
                db 8, 41h, 11h, 2Ah, 80h, 44h, 80h, 42h, 8, 2, 11h, 28h
                db 2, 80h, 41h, 2, 42h, 2, 80h, 2, 2, 11h, 20h, 20h, 22h
                db 80h, 2, 41h, 80h, 2, 41h, 2, 41h, 0Ah, 41h, 80h, 2
                db 80h, 2, 41h, 0C0h, 42h, 2, 41h, 2Ah, 2, 0Ah, 80h, 41h
                db 2, 41h, 80h, 44h, 2Ah, 41h, 0Ah, 2, 20h, 8, 20h, 80h
                db 44h, 11h, 42h, 8, 80h, 0Ah, 80h, 80h, 41h, 2, 41h, 20h
                db 11h, 2, 41h, 2, 41h, 2, 20h, 80h, 41h, 2, 41h, 20h
                db 11h, 41h, 0A8h, 88h, 41h, 8, 0Ah, 42h, 8Ah, 2, 82h
                db 11h, 41h, 2, 42h, 2, 11h, 80h, 41h, 22h, 0A2h, 2, 11h
                db 46h, 0A0h, 42h, 88h, 82h, 11h, 8, 88h, 88h, 8Ah, 0A0h
                db 41h, 8, 80h, 42h, 0Ah, 11h, 22h, 2Ch, 0F0h, 0FCh, 43h
                db 22h, 41h, 0A0h, 0Ah, 11h, 8, 0Ah, 12h, 0A0h, 41h, 2
                db 41h, 80h, 2Ah, 12h, 23h, 0AEh, 0Eh, 0BAh, 42h, 2, 41h
                db 20h, 2Ah, 12h, 0Eh, 0EAh, 8, 28h, 44h, 8, 2Ah, 12h
                db 2Ah, 0A8h, 8, 28h, 44h, 22h, 2Ah, 12h, 8Ah, 80h, 8
                db 28h, 43h, 20h, 8, 2Ah, 12h, 0Ah, 41h, 8, 44h, 80h, 41h
                db 8, 2, 11h, 0Ah, 41h, 8, 43h, 2, 20h, 43h, 11h, 0Ah
                db 41h, 8, 41h, 2, 41h, 22h, 43h, 2, 2Ah, 0Ah, 0Ch, 42h
                db 0Eh, 41h, 28h, 2, 20h, 0A0h, 8, 2Ah, 0Ah, 43h, 0Ah
                db 42h, 28h, 0Ah, 80h, 8Ah, 2Ah, 42h, 8, 41h, 8, 2, 42h
                db 22h, 20h, 20h, 2Ah, 43h, 20h, 41h, 2, 80h, 20h, 8, 42h
                db 11h, 41h, 20h, 41h, 0E0h, 41h, 2, 0A0h, 43h, 2, 11h
                db 41h, 20h, 3, 0A0h, 80h, 2, 0A8h, 43h, 2, 11h, 41h, 20h
                db 2, 80h, 42h, 11h, 80h, 43h, 11h, 45h, 2, 8Ah, 11h, 43h
                db 2Ah, 46h, 80h, 0A2h, 13h, 0Ah, 45h, 2, 20h, 82h, 2Ah
                db 8Ah, 11h, 0Ah, 3, 0FFh, 0BFh, 0EBh, 0EEh, 0B8h, 80h
                db 80h, 2, 0A2h, 8Ah, 0Ah, 2Ah, 0B2h, 0B2h, 11h, 0A8h
                db 28h, 20h, 41h, 2, 0A0h, 82h, 0Ah, 2Ah, 0AFh, 0EAh, 8Ah
                db 0A8h, 41h, 80h, 41h, 2, 80h, 41h, 0Ah, 2Ah, 11h, 41h
                db 2, 80h, 43h, 82h, 80h, 41h, 0Ah, 22h, 8Ah, 41h, 2, 42h
                db 80h, 41h, 80h, 42h, 0Ah, 20h, 0Ah, 44h, 2, 80h, 43h
                db 0Ah, 20h, 0Ah, 44h, 2, 80h, 41h, 2, 41h, 0Ah, 20h, 0Ah
                db 47h, 80h, 41h, 0Ah, 41h, 8, 47h, 80h, 41h, 0Ah, 4Bh
                db 0Ah, 4Bh, 0Ah, 4Bh, 0Ah, 2Ah, 11h, 0AEh, 12h, 0A0h
                db 41h, 0Ah, 43h, 0Ah, 2, 0BAh, 0Ah, 0Bh, 82h, 0A0h, 41h
                db 0Ah, 41h, 80h, 2, 0Ah, 8, 2Ah, 41h, 2, 41h, 20h, 45h
                db 0Ah, 0Ch, 0Eh, 43h, 20h, 8, 43h, 2, 0Ah, 8, 0Ah, 43h
                db 20h, 28h, 41h, 8, 41h, 28h, 0Ah, 8, 8, 44h, 20h, 41h
                db 8, 41h, 22h, 0Ah, 8, 47h, 0Ah, 41h, 8, 0Ah, 8, 46h
                db 0A0h, 0Eh, 41h, 2, 0Ah, 20h, 46h, 0A0h, 0Eh, 41h, 88h
                db 0Ah, 28h, 41h, 2, 80h, 41h, 2, 41h, 0E0h, 0Ah, 0Ah
                db 20h, 0Ah, 28h, 8, 2, 80h, 28h, 2, 2, 11h, 88h, 88h
                db 88h, 0Ah, 28h, 42h, 0Ah, 80h, 2, 8Ah, 0A8h, 43h, 0Ah
                db 2Ah, 80h, 12h, 28h, 3, 11h, 44h, 2Ah, 45h, 2, 0A0h
                db 2, 2, 41h, 2Ah, 11h, 20h, 41h, 0Ah, 11h, 0A2h, 42h
                db 11h, 0A8h, 88h, 2Ah, 11h, 8, 43h, 88h, 45h, 2, 11h
                db 8, 42h, 2, 20h, 0A0h, 2Ah, 0A0h, 2, 80h, 0A8h, 11h
                db 2, 44h, 2, 0Ah, 41h, 2, 41h, 2Ah, 2Ah, 41h, 0E8h, 28h
                db 0A8h, 41h, 2, 80h, 8, 2, 20h, 2, 2Ah, 3, 0A0h, 41h
                db 20h, 42h, 0A0h, 22h, 80h, 42h, 2Ah, 3, 80h, 44h, 20h
                db 41h, 80h, 2, 41h, 2Ah, 0Eh, 45h, 20h, 42h, 2, 41h, 2Ah
                db 2, 43h, 8, 42h, 80h, 42h, 2, 2Ah, 2, 41h, 88h, 44h
                db 80h, 42h, 0Ah, 2Ah, 8, 41h, 0Ah, 43h, 8, 8, 42h, 2
                db 2Ah, 8, 44h, 8, 8, 8, 43h, 2Ah, 8, 42h, 80h, 8, 42h
                db 80h, 43h, 2Ah, 8, 41h, 20h, 0A0h, 41h, 8, 43h, 0A0h
                db 41h, 2Ah, 8, 41h, 0A0h, 0A0h, 20h, 2, 43h, 0A0h, 41h
                db 2Ah, 2, 43h, 20h, 42h, 20h, 80h, 41h, 2, 2Ah, 0Ah, 46h
                db 20h, 42h, 2, 2Ah, 8, 44h, 28h, 44h, 20h, 2Ah, 41h, 2
                db 42h, 20h, 2, 45h, 2Ah, 8, 42h, 88h, 8, 42h, 8, 2, 42h
                db 2Ah, 2, 41h, 80h, 28h, 8, 43h, 2, 42h, 11h, 41h, 2
                db 45h, 2, 43h, 2Ah, 41h, 8, 2, 2, 80h, 46h, 2Ah, 41h
                db 2, 82h, 0A2h, 2, 2, 2, 20h, 42h, 0A0h, 2Ah, 8, 80h
                db 80h, 80h, 2, 41h, 2, 8, 80h, 41h, 0A0h, 2Ah, 41h, 8
                db 82h, 41h, 80h, 41h, 28h, 0Ah, 41h, 20h, 41h, 2Ah, 8
                db 20h, 80h, 42h, 2, 0Ah, 8, 42h, 20h, 2Ah, 2, 20h, 41h
                db 80h, 20h, 41h, 22h, 43h, 20h, 2Ah, 8, 88h, 2, 0A2h
                db 42h, 20h, 44h, 2Ah, 41h, 28h, 41h, 22h, 0A0h, 41h, 0A0h
                db 0Ah, 43h, 2Ah, 41h, 82h, 41h, 8, 22h, 41h, 8, 82h, 80h
                db 42h, 11h, 4Bh, 11h, 41h, 0Ah, 0A0h, 0A0h, 0A0h, 11h
                db 0Ah, 0A8h, 11h, 80h, 2, 11h, 41h, 2Ah, 43h, 28h, 41h
                db 28h, 82h, 0A0h, 41h, 11h, 2, 0A0h, 8, 0Ah, 43h, 2, 43h
                db 2Ah, 2, 2Ah, 41h, 11h, 0Ah, 8Ah, 8, 28h, 43h, 0Ah, 3
                db 3Fh, 0EBh, 3Fh, 0FFh, 8Bh, 0BAh, 0E8h, 0EAh, 0FAh, 11h
                db 0Ah, 0Ah, 11h, 0BAh, 8Fh, 11h, 0E8h, 0EAh, 0A8h, 0ABh
                db 11h, 41h, 0Ah, 3Ah, 0BAh, 0A8h, 0Ah, 11h, 0A0h, 42h
                db 82h, 0BAh, 8, 0Ah, 0Ah, 11h, 41h, 2, 0E8h, 42h, 2, 80h
                db 28h, 8, 8Ah, 3Bh, 80h, 41h, 2, 0E0h, 44h, 28h, 41h
                db 0Ah, 3Bh, 80h, 8, 2, 0A0h, 80h, 42h, 80h, 42h, 8Ah
                db 0Eh, 80h, 41h, 3, 0A0h, 41h, 80h, 41h, 80h, 20h, 20h
                db 8Ah, 3Ah, 80h, 41h, 2, 0E0h, 41h, 80h, 43h, 0A0h, 0Ah
                db 3Eh, 82h, 8, 2, 0A0h, 2, 41h, 20h, 80h, 42h, 0Ah, 0Ah
                db 2, 8, 41h, 0A0h, 2, 42h, 8, 8, 41h, 0Ah, 28h, 41h, 0Eh
                db 42h, 2, 80h, 20h, 43h, 0Ah, 42h, 8, 42h, 82h, 0A8h
                db 42h, 2, 41h, 0Ah, 42h, 8Ch, 42h, 80h, 0A0h, 20h, 43h
                db 0Ah, 42h, 8, 45h, 38h, 20h, 41h, 8Ah, 41h, 8, 0Ah, 42h
                db 20h, 42h, 3Ah, 41h, 22h, 0Ah, 41h, 8, 0Ah, 43h, 80h
                db 80h, 0Ah, 41h, 20h, 0Ah, 41h, 38h, 0Ah, 41h, 80h, 41h
                db 80h, 41h, 38h, 41h, 2, 0Ah, 41h, 20h, 0Ah, 42h, 20h
                db 20h, 41h, 38h, 2, 8, 8Ah, 41h, 20h, 8, 41h, 22h, 20h
                db 42h, 38h, 41h, 0Ah, 0Ah, 41h, 20h, 0Ah, 41h, 2, 41h
                db 80h, 8, 28h, 41h, 8, 0Ah, 2, 41h, 2Ah, 41h, 2, 42h
                db 8, 3Bh, 41h, 22h, 0Ah, 2, 41h, 38h, 41h, 82h, 42h, 28h
                db 2Ah, 41h, 8, 0Ah, 0Ah, 20h, 28h, 41h, 0Bh, 43h, 3Ah
                db 41h, 0A0h, 0Ah, 0Ah, 28h, 0Ah, 41h, 0Ah, 80h, 41h, 80h
                db 0E8h, 41h, 88h, 0Ah, 0Ah, 22h, 2Eh, 41h, 0Bh, 82h, 80h
                db 88h, 0EAh, 0Ah, 20h, 0Ah, 0Ah, 0E0h, 2Eh, 41h, 0Eh
                db 0Ah, 0EEh, 0Ah, 88h, 8, 88h, 0Ah, 0Ah, 20h, 0EAh, 41h
                db 0A8h, 8Bh, 0A2h, 0A8h, 11h, 41h, 20h, 0Ah, 0Ah, 0E0h
                db 8Ah, 82h, 3Ah, 3, 88h, 0BAh, 88h, 80h, 88h, 0Ah, 0Ah
                db 20h, 0EAh, 2, 0BAh, 88h, 0A0h, 0CAh, 0Ah, 20h, 20h
                db 0Ah, 0Ah, 0B0h, 0ACh, 12h, 0Ah, 2Ah, 0E2h, 8Ah, 20h
                db 88h, 0Ah, 0Ah, 0A2h, 0AEh, 22h, 0E8h, 82h, 0A2h, 0CAh
                db 28h, 82h, 20h, 0Ah, 0Ah, 0E2h, 0A8h, 22h, 0EAh, 8, 11h
                db 0A8h, 88h, 0A0h, 8, 0Ah, 0Bh, 0A8h, 0A2h, 3Ah, 0A8h
                db 0A3h, 0A8h, 82h, 22h, 22h, 41h, 0Ah, 0Ah, 11h, 88h
                db 8Ah, 22h, 2, 0A2h, 22h, 88h, 88h, 41h, 0Ah, 8, 22h
                db 20h, 2Ah, 82h, 20h, 2, 8, 20h, 42h, 0Ah, 0
title_screen_final_data db 0DFh, 0DFh, 0DFh, 0DBh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh
                db 5Fh, 5Fh, 5Fh, 5Fh, 54h, 0AFh, 0D5h, 0F2h, 0AFh, 0D5h
                db 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 0D5h, 0F2h, 0AFh
                db 0D5h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 4Fh, 4Ah, 2, 57h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 59h, 0C0h, 45h, 30h, 45h, 0Ch, 45h
                db 3, 46h, 0C2h, 0AFh, 0D5h, 0F2h, 0AFh, 45h, 0F2h, 0AFh
                db 45h, 0F2h, 59h, 0C0h, 30h, 0Ch, 3, 41h, 0C0h, 30h, 0Ch
                db 3, 41h, 0C0h, 30h, 0Ch, 3, 41h, 0C0h, 30h, 0Ch, 3, 41h
                db 0C0h, 30h, 0Ch, 3, 41h, 0C2h, 0AFh, 0D5h, 0F2h, 0AFh
                db 45h, 0F2h, 0AFh, 45h, 0F2h, 59h, 0DFh, 0DAh, 0C2h, 0AFh
                db 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh
                db 55h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h
                db 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh
                db 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 0AFh, 45h
                db 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh
                db 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh
                db 55h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h
                db 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 0AFh
                db 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 0AFh, 45h
                db 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h
                db 0AFh, 45h, 0F2h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 55h, 0AFh
                db 45h, 0F2h, 0AFh, 0D5h, 0F2h, 0AFh, 0D5h, 0F2h, 5Fh
                db 5Fh, 55h, 0AFh, 45h, 0F2h, 0AFh, 0D5h, 0F2h, 0AFh, 0D5h
                db 0F2h, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 0A0h, 45h, 2
                db 0A0h, 45h, 2, 5Fh, 5Fh, 55h, 0AFh, 45h, 0F2h, 5Fh, 5Fh
                db 5Fh, 54h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 5Fh, 54h, 0AFh
                db 45h, 0F2h, 5Fh, 5Fh, 5Fh, 54h, 0AFh, 45h, 0F2h, 5Fh
                db 5Fh, 5Fh, 54h, 0AFh, 45h, 0F2h, 5Fh, 5Fh, 5Fh, 54h
                db 0AFh, 0D5h, 0F2h, 5Fh, 5Fh, 5Fh, 54h, 0AFh, 0D5h, 0F2h
                db 5Fh, 5Fh, 5Fh, 54h, 0A0h, 45h, 2, 5Fh, 5Fh, 5Fh, 5Fh
                db 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh
                db 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 5Fh
                db 5Fh, 5Fh, 5Fh, 5Fh, 5Ch, 0

buf1            equ    offset title_screen_final_data + 2926h - 2799h ;db 960h dup(?)
buf2            equ    buf1 + 960h ;db (?)


mole            ends
                end    start
