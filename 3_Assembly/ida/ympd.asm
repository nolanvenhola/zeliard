                .286
                .model tiny

ympd            segment byte public 'CODE'
                assume cs:ympd, ds:ympd

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
                mov     cx, 2680h
                xor     ax, ax
                rep stosw
                mov     dx, cs
                add     dx, 1000h
                mov     es, dx          ; seg1
                mov     si, offset mountains0
                mov     di, 0           ; unpack mountains0 to seg1:0
                call    RLE_decode_88_x_56_bytes
                mov     si, offset mountains1
                mov     di, 1340h       ; unpack mountains1 to seg1:1340h
                call    RLE_decode_88_x_56_bytes
                call    render_mountains
                mov     dx, cs
                add     dx, 1000h
                mov     es, dx          ; seg1
                mov     di, 0
                mov     si, offset ground
                mov     cx, 16
loc_3347:
                call    RLE_extract_28_bytes
                loop    loc_3347        ; 16*28 = 448 bytes
                mov     si, offset ground1
                mov     cx, 16
loc_3352:
                call    RLE_extract_28_bytes
                loop    loc_3352        ; 16*28 = 448 bytes

                call    render_ground
                retf
sub_3300        endp

; ---------------------------------------------------------------------------
video_mode      db 0                    ; ...

; =============== S U B R O U T I N E =======================================


RLE_decode_88_x_56_bytes  proc near
                xor     cx, cx
loc_335E:
                lodsb                   ; [0]
                cmp     al, 6
                mov     ah, 1
                jne     short ah_times  ; non 6 => put [0]
                ; [0]==6 => (put [1]) [2] times
                lodsw                   ; [1]: al = pixel, [2]: ah = count
ah_times:
                stosb
                inc     ch
                cmp     ch, 56
                jnz     short loc_3378
                xor     ch, ch
                inc     cl
                cmp     cl, 88
                jnz     short loc_3378
                retn
loc_3378:
                dec     ah
                jnz     short ah_times
                jmp     short loc_335E
RLE_decode_88_x_56_bytes  endp


; =============== S U B R O U T I N E =======================================


render_mountains        proc near
                xor     bx, bx
                mov     bl, ds:video_mode
                add     bx, bx          ; switch 6 cases
                jmp     ds:jpt_3386[bx] ; switch jump
render_mountains        endp

; ---------------------------------------------------------------------------
jpt_3386        dw offset mode0_ega     ; EGA or VGA planar
                dw offset mode1_2_cga   ; CGA or Tandy
                dw offset mode1_2_cga
                dw offset mode3_hgc     ; Hercules
                dw offset mode4_mcga    ; MCGA: video_mode=4
                dw offset mode5_cga_alt
; ---------------------------------------------------------------------------
mode0_ega:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     dx, 3C4h
                mov     al, 2
                out     dx, al          ; EGA: sequencer address reg
                                        ; map mask: data bits 0-3 enable writes to bit planes 0-3
                inc     dx
                mov     al, 1
                out     dx, al          ; EGA port: sequencer data register
                call    sub_33BC
                mov     al, 4
                out     dx, al
                call    sub_33BC
                pop     ds
                retn

; =============== S U B R O U T I N E =======================================


sub_33BC        proc near
                mov     di, 46Ch
                mov     cx, 88
loc_33C2:
                push    cx
                push    di
                mov     cx, 38h ; '8'
                rep movsb
                pop     di
                add     di, 50h ; 'P'
                pop     cx
                loop    loc_33C2
                retn
sub_33BC        endp

; ---------------------------------------------------------------------------

mode1_2_cga:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B800h
                mov     es, ax
                mov     di, 23Ch
                mov     cx, 58h ; 'X'

loc_33E8:                               ; ...
                push    cx
                push    di
                mov     cx, 38h ; '8'

loc_33ED:                               ; ...
                push    cx
                mov     ah, [si+1340h]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_33F8:                               ; ...
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
                or      dl, cs:byte_3432[bx]
                loop    loc_33F8
                mov     al, dl
                stosb
                pop     cx
                loop    loc_33ED
                pop     di
                add     di, 2000h
                cmp     di, 4000h
                jb      short loc_342D
                add     di, 0C050h

loc_342D:                               ; ...
                pop     cx
                loop    loc_33E8
                pop     ds
                retn
; ---------------------------------------------------------------------------
byte_3432       db 0, 3, 1, 2, 0, 3, 1, 2, 0, 3, 1, 2, 0, 3, 1, 2
; ---------------------------------------------------------------------------

mode3_hgc:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B000h
                mov     es, ax
                mov     di, 4FDh
                mov     cx, 58h ; 'X'

loc_3459:                               ; ...
                push    cx
                push    di
                mov     cx, 38h ; '8'

loc_345E:                               ; ...
                push    cx
                mov     ah, [si+1340h]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_3469:                               ; ...
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
                or      dl, cs:byte_3432[bx]
                loop    loc_3469
                mov     al, dl
                stosb
                pop     cx
                loop    loc_345E
                pop     di
                add     di, 2000h
                cmp     di, 6000h
                jb      short loc_34B3
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

loc_34B3:                               ; ...
                pop     cx
                loop    loc_3459
                pop     ds
                retn
; ---------------------------------------------------------------------------

mode4_mcga:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx          ; seg1
                mov     si, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     di, 48+14*320
                mov     cx, 88
mountains_11_rows_of_tiles:
                push    cx
                push    di
                mov     cx, 56
row_28_tiles:
                push    cx
                mov     dh, [si+1340h]
                mov     dl, [si]
                inc     si
                call    sub_34F9
                stosb
                call    sub_34F9
                stosb
                call    sub_34F9
                stosb
                call    sub_34F9
                stosb
                pop     cx
                loop    row_28_tiles
                pop     di
                add     di, 320
                pop     cx
                loop    mountains_11_rows_of_tiles
                pop     ds
                retn

; =============== S U B R O U T I N E =======================================


sub_34F9        proc near               ; ...
                xor     al, al
                add     dh, dh
                adc     al, al
                add     al, al
                add     dl, dl
                adc     al, al
                add     dh, dh
                adc     al, al
                add     al, al
                add     dl, dl
                adc     al, al
                retn
sub_34F9        endp

; ---------------------------------------------------------------------------

mode5_cga_alt:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B800h
                mov     es, ax
                mov     di, 41F8h
                mov     cx, 58h ; 'X'

loc_3527:                               ; ...
                push    cx
                push    di
                mov     cx, 38h ; '8'

loc_352C:                               ; ...
                push    cx
                mov     dh, [si+1340h]
                mov     dl, [si]
                inc     si
                call    sub_3553
                stosb
                call    sub_3553
                stosb
                pop     cx
                loop    loc_352C
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_354E
                add     di, 80A0h

loc_354E:                               ; ...
                pop     cx
                loop    loc_3527
                pop     ds
                retn

; =============== S U B R O U T I N E =======================================


sub_3553        proc near               ; ...
                xor     al, al
                mov     cx, 2

loc_3558:
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
                or      al, cs:byte_357D[bx]
                loop    loc_3558
                retn
sub_3553        endp

; ---------------------------------------------------------------------------
byte_357D       db 0, 7, 9, 1, 7, 0Fh, 0Bh, 7, 9, 0Bh, 0Bh, 3, 1, 7, 3, 9

; =============== S U B R O U T I N E =======================================

; Input: SI points to RLE encoded data, variable length
;        DI points to destination buffer, 28 bytes
RLE_extract_28_bytes  proc near
                xor     bl, bl
loc_358F:
                lodsb
                mov     ah, al
                and     ah, 0F0h
                cmp     ah, 60h  ; high nibble is 6?
                mov     ah, 1
                jne     short repeat_ah_times ; non 6 => no repetition
                ; high nibble is 6 => put low_nibble zeroes
                and     al, 0Fh  ; low nibble
                mov     ah, al
                xor     al, al
repeat_ah_times:
                stosb
                inc     bl
                dec     ah
                jnz     short repeat_ah_times
                cmp     bl, 28
                jnz     short loc_358F
                retn
RLE_extract_28_bytes  endp


; =============== S U B R O U T I N E =======================================


render_ground   proc near
                xor     bx, bx
                mov     bl, video_mode
                add     bx, bx          ; switch 6 cases
                jmp     jpt_35B7[bx]    ; switch jump
render_ground   endp

; ---------------------------------------------------------------------------
jpt_35B7        dw offset m0_ega        ; EGA or VGA planar
                dw offset m1_2_cga      ; CGA or Tandy
                dw offset m1_2_cga      ;
                dw offset m3_hgc        ; Hercules
                dw offset m4_mcga       ; MCGA: video_mode=4
                dw offset m5_cga_alt    ;
; ---------------------------------------------------------------------------

m0_ega:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     di, 2C6Ch
                mov     dx, 3C4h
                mov     al, 2
                out     dx, al          ; EGA: sequencer address reg
                                        ; map mask: data bits 0-3 enable writes to bit planes 0-3
                inc     dx
                mov     cx, 8

loc_35E5:                               ; ...
                mov     al, 4
                out     dx, al          ; EGA port: sequencer data register
                call    sub_3639
                mov     al, 2
                out     dx, al
                call    sub_3639
                add     di, 50h ; 'P'
                loop    loc_35E5
                mov     di, 2EECh
                mov     cx, 8

loc_35FC:                               ; ...
                mov     al, 1
                out     dx, al
                call    sub_3639
                mov     al, 2
                out     dx, al
                call    sub_3639
                add     di, 50h ; 'P'
                loop    loc_35FC
                mov     al, 7
                out     dx, al
                mov     dx, 3CEh
                mov     ax, 105h
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:
                                        ; unknown register
                push    es
                pop     ds
                mov     si, 2C6Ch
                mov     di, 2C88h
                mov     ah, 10h

loc_3621:                               ; ...
                mov     cx, 1Ch
                rep movsb
                add     di, 34h ; '4'
                add     si, 34h ; '4'
                dec     ah
                jnz     short loc_3621
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
                retn

; =============== S U B R O U T I N E =======================================


sub_3639        proc near               ; ...
                push    di
                push    cx
                mov     cx, 1Ch
                rep movsb
                pop     cx
                pop     di
                retn
sub_3639        endp

; ---------------------------------------------------------------------------

m1_2_cga:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B800h
                mov     es, ax
                mov     di, 163Ch
                mov     cx, 10h

loc_365A:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_365F:                               ; ...
                push    cx
                mov     ah, [si+1Ch]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_3669:                               ; ...
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
                or      dl, cs:byte_36B6[bx]
                loop    loc_3669
                mov     al, dl
                stosb
                pop     cx
                loop    loc_365F
                push    ds
                push    si
                push    es
                pop     ds
                mov     si, di
                sub     si, 1Ch
                mov     cx, 0Eh
                rep movsw
                pop     si
                pop     ds
                add     si, 1Ch
                pop     di
                add     di, 2000h
                cmp     di, 4000h
                jb      short loc_36B1
                add     di, 0C050h

loc_36B1:                               ; ...
                pop     cx
                loop    loc_365A
                pop     ds
                retn
; ---------------------------------------------------------------------------
byte_36B6       db 0, 3, 2, 1, 1, 3, 3, 3, 2, 3, 1, 2, 2, 3, 3, 3 ; ...
; ---------------------------------------------------------------------------

m3_hgc:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B000h
                mov     es, ax
                mov     di, 53C1h
                mov     cx, 10h

loc_36DD:
                push    cx
                push    di
                mov     cx, 1Ch

loc_36E2:                               ; ...
                push    cx
                mov     ah, [si+1Ch]
                lodsb
                xor     dl, dl
                mov     cx, 4

loc_36EC:                               ; ...
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
                or      dl, cs:byte_36B6[bx]
                loop    loc_36EC
                mov     al, dl
                stosb
                pop     cx
                loop    loc_36E2
                push    ds
                push    si
                push    es
                pop     ds
                mov     si, di
                sub     si, 1Ch
                mov     cx, 0Eh
                rep movsw
                pop     si
                pop     ds
                add     si, 1Ch
                pop     di
                add     di, 2000h
                cmp     di, 6000h
                jb      short loc_3749
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

loc_3749:                               ; ...
                pop     cx
                loop    loc_36DD
                pop     ds
                retn
; ---------------------------------------------------------------------------

m4_mcga:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx          ; seg1
                mov     si, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     di, 48+(14+16*8)*320 ; row 16 is first ground row
                mov     cx, 8
row_14_tiles:
                push    cx
                push    si
                push    di
                mov     cx, 14
line_112px:
                push    cx
                mov     dx, [si]
                mov     bx, [si+28]
                xchg    dl, dh
                xchg    bl, bh
                mov     cx, 8
line_8px:
                xor     al, al
                add     dx, dx
                adc     al, al          ; al = dh7
                add     bx, bx
                adc     al, al          ; al = dh7_bh7
                add     al, al          ; al = dh7_bh7_0
                add     dx, dx
                adc     al, al          ; al = dh7_bh7_0_dh6
                add     bx, bx
                adc     al, al          ; al = dh7_bh7_0_dh6_bh6
                add     al, al          ; al = dh7_bh7_0_dh6_bh6_0
                stosb
                loop    line_8px
                inc     si
                inc     si
                pop     cx
                loop    line_112px
                pop     di
                add     di, 320         ; next scanline
                pop     si
                add     si, 56
                pop     cx
                loop    row_14_tiles
                mov     di, 48+(14+17*8)*320 ; row 17 is second ground row (bottom of viewport)
                mov     cx, 8
row_14_tiles_:
                push    cx
                push    si
                push    di
                mov     cx, 14
line_112px_:
                push    cx
                mov     bx, [si]
                mov     dx, [si+28]
                xchg    dl, dh
                xchg    bl, bh
                mov     cx, 8
line_8px_:
                xor     al, al
                add     dx, dx
                adc     al, al
                add     bx, bx
                adc     al, al
                add     al, al
                add     dx, dx
                adc     al, al
                add     bx, bx
                adc     al, al
                stosb
                loop    line_8px_
                inc     si
                inc     si
                pop     cx
                loop    line_112px_
                pop     di
                add     di, 320
                pop     si
                add     si, 56
                pop     cx
                loop    row_14_tiles_
                push    es
                pop     ds
                mov     si, 48+(14+16*8)*320
                mov     di, 48+(14+16*8)*320 + 112
                mov     ah, 16
duplicate_ground_half:
                mov     cx, 56
                rep movsw
                add     di, (320-112)
                add     si, (320-112)
                dec     ah
                jnz     short duplicate_ground_half
                pop     ds
                retn
; ---------------------------------------------------------------------------

m5_cga_alt:
                push    ds
                mov     dx, cs
                add     dx, 1000h
                mov     ds, dx
                mov     si, 0
                mov     ax, 0B800h
                mov     es, ax
                mov     di, 55F8h
                mov     cx, 8

loc_3817:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_381C:                               ; ...
                push    cx
                mov     dh, [si+1Ch]
                mov     dl, [si]
                inc     si
                mov     bp, offset byte_38C7
                call    sub_389D
                stosb
                call    sub_389D
                stosb
                pop     cx
                loop    loc_381C
                push    ds
                push    si
                push    es
                pop     ds
                mov     si, di
                sub     si, 38h ; '8'
                mov     cx, 1Ch
                rep movsw
                pop     si
                pop     ds
                add     si, 1Ch
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_3853
                add     di, 80A0h

loc_3853:                               ; ...
                pop     cx
                loop    loc_3817
                mov     di, 5738h
                mov     cx, 8

loc_385C:                               ; ...
                push    cx
                push    di
                mov     cx, 1Ch

loc_3861:                               ; ...
                push    cx
                mov     dh, [si+1Ch]
                mov     dl, [si]
                inc     si
                mov     bp, offset byte_38D7
                call    sub_389D
                stosb
                call    sub_389D
                stosb
                pop     cx
                loop    loc_3861
                push    ds
                push    si
                push    es
                pop     ds
                mov     si, di
                sub     si, 38h ; '8'
                mov     cx, 1Ch
                rep movsw
                pop     si
                pop     ds
                add     si, 1Ch
                pop     di
                add     di, 2000h
                cmp     di, 8000h
                jb      short loc_3898
                add     di, 80A0h

loc_3898:                               ; ...
                pop     cx
                loop    loc_385C
                pop     ds
                retn

; =============== S U B R O U T I N E =======================================


sub_389D        proc near               ; ...
                xor     al, al
                mov     cx, 2

loc_38A2:                               ; ...
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
                add     bx, bp
                or      al, cs:[bx]
                loop    loc_38A2
                retn
sub_389D        endp

; ---------------------------------------------------------------------------
byte_38C7       db 0, 3, 4, 7, 3, 0Bh, 5, 0Ah, 4, 5, 0Ch, 6, 7, 0Ah, 6 ; ...
                db 0Eh
byte_38D7       db 0, 7, 4, 2, 7, 0Fh, 0Ch, 0Eh, 4, 0Ch, 0Ch, 2, 2, 0Eh ; ...
                db 2, 0Ah
mountains0       db 6, 0AAh, 70h, 0BBh, 0FBh, 0BFh, 0BBh, 0BFh, 0BBh, 0BBh ; ...
                db 0FFh, 0BBh, 0BBh, 0BFh, 6, 0BBh, 8, 0FBh, 0FFh, 0FFh
                db 0BBh, 0BFh, 0FBh, 6, 0BBh, 10h, 0FFh, 0FFh, 0FBh, 6
                db 0BBh, 0Ch, 0FEh, 0FEh, 0FEh, 0FFh, 0FEh, 0EFh, 0FFh
                db 0FFh, 0FFh, 0EFh, 0FFh, 0FFh, 0EEh, 0EEh, 0EFh, 0FEh
                db 0EFh, 0FFh, 0FFh, 0FEh, 0FFh, 0EEh, 0EFh, 0FFh, 0FFh
                db 0FFh, 0EEh, 0EFh, 0EEh, 0EFh, 0FEh, 0FFh, 0EFh, 0FEh
                db 0EFh, 0EFh, 0FFh, 0FEh, 0FFh, 0EFh, 0FFh, 0FFh, 0FEh
                db 0FFh, 0EEh, 6, 0EFh, 4, 0FEh, 0FFh, 0FFh, 0FEh, 0EEh
                db 0EEh, 0EEh, 6, 0FFh, 32h, 0EFh, 0FBh, 6, 0FFh, 77h
                db 0BBh, 0BBh, 0BBh, 6, 0FFh, 0Dh, 0FEh, 0EAh, 0BBh, 0FFh
                db 0FFh, 0FEh, 0EAh, 0EFh, 0FFh, 0FFh, 0EEh, 0EEh, 0EEh
                db 6, 0FFh, 10h, 0FEh, 0EEh, 0EEh, 6, 0FFh, 5, 0BBh, 0FBh
                db 0AEh, 6, 0EEh, 4, 0EFh, 0FFh, 0FFh, 0FBh, 0BAh, 0BEh
                db 0BEh, 0EFh, 0FBh, 0FBh, 0BBh, 6, 0FFh, 0Eh, 6, 0BBh
                db 0Bh, 0BFh, 0FFh, 0FFh, 0BBh, 0BBh, 0BBh, 0FBh, 0BBh
                db 0BBh, 0BFh, 0BFh, 0FFh, 0BBh, 0EEh, 0EEh, 0EAh, 0AAh
                db 0AAh, 0AAh, 0EEh, 0FEh, 0EEh, 0EEh, 0EFh, 0FFh, 0EAh
                db 0EAh, 0ABh, 0AAh, 0BFh, 0EEh, 0EEh, 0AAh, 6, 0BBh, 4
                db 0BFh, 0FFh, 0FEh, 6, 0EEh, 7, 0FEh, 0AAh, 0AEh, 0EEh
                db 0AAh, 0AAh, 0AEh, 0EEh, 0FFh, 0FFh, 0FFh, 6, 0EEh, 4
                db 0EFh, 0EEh, 0FFh, 0FFh, 0FFh, 0EEh, 0FFh, 0BBh, 0BBh
                db 0BBh, 0BAh, 0ABh, 0ABh, 6, 0BBh, 5, 0BAh, 0ABh, 0AAh
                db 0AAh, 0ABh, 0ABh, 0BBh, 6, 0AAh, 6, 0ABh, 6, 0BBh, 7
                db 0AAh, 0ABh, 6, 0BBh, 13h, 0BFh, 0FFh, 0BFh, 6, 0EEh
                db 8, 6, 0AAh, 0Dh, 0EEh, 0AEh, 0AAh, 0EEh, 0EEh, 0EAh
                db 0AAh, 0EEh, 0AAh, 0AAh, 0EAh, 0EEh, 0EAh, 0AAh, 0EEh
                db 0EEh, 0FEh, 0AAh, 0EAh, 0AAh, 0AEh, 0EEh, 0EAh, 0AAh
                db 0EEh, 0AAh, 0EAh, 0AEh, 6, 0EEh, 6, 0EFh, 0FBh, 6, 0AAh
                db 2Dh, 0BBh, 0AAh, 0BAh, 0AAh, 0ABh, 6, 0BBh, 5, 0EAh
                db 0EEh, 6, 0AAh, 35h, 0EEh, 0ABh, 0AAh, 0AAh, 0AAh, 0EAh
                db 0EEh, 0EAh, 0AEh, 0ABh, 6, 0AAh, 2Fh, 0EAh, 6, 0AAh
                db 8, 0ABh, 0AAh, 0BAh, 0EAh, 6, 0AAh, 0B6h, 0AFh, 0FEh
                db 0EFh, 6, 0AAh, 4, 0BFh, 0EEh, 0EFh, 0FAh, 6, 0AAh, 2Dh
                db 0BEh, 0AFh, 0FEh, 0EEh, 0BBh, 0FAh, 0AAh, 0BAh, 0FBh
                db 0BAh, 6, 0AAh, 1Fh, 3Fh, 0FEh, 0EEh, 0EAh, 0BBh, 6
                db 0AAh, 9, 0ABh, 0FEh, 0AEh, 0EAh, 6, 0AAh, 4, 0FAh, 0BEh
                db 6, 0AAh, 20h, 3Eh, 0EAh, 6, 0AAh, 0Ch, 0AFh, 0FEh, 0ABh
                db 0BBh, 0BAh, 0AAh, 0AAh, 0AAh, 0FAh, 0BAh, 6, 0AAh, 1Fh
                db 0ABh, 0BAh, 6, 0AAh, 0Dh, 0AFh, 0FAh, 0AAh, 0EAh, 0AAh
                db 0AAh, 0AAh, 0ABh, 0FBh, 0EEh, 6, 0AAh, 10h, 0BFh, 0FFh
                db 0FFh, 0EFh, 6, 0AAh, 0Bh, 0AFh, 0AEh, 0EEh, 0EFh, 0FEh
                db 0BAh, 0AAh, 0EEh, 0EEh, 0FFh, 0FBh, 0BBh, 0AAh, 0AAh
                db 0AAh, 0FFh, 0EAh, 0AAh, 0EAh, 0AAh, 0AAh, 0AAh, 0ABh
                db 0EEh, 0BAh, 0AAh, 0AAh, 0ABh, 0FFh, 0FBh, 0FFh, 0BBh
                db 0BBh, 0AAh, 0EEh, 6, 0AAh, 5, 0BFh, 0EEh, 0ABh, 0FFh
                db 0BAh, 6, 0AAh, 7, 0FFh, 0FEh, 0EEh, 0AAh, 0AFh, 0AFh
                db 0BBh, 0BBh, 0AAh, 0AAh, 0AEh, 0EEh, 6, 0AAh, 4, 0AEh
                db 0EEh, 0EFh, 0BFh, 0EAh, 6, 0AAh, 5, 0AFh, 0ECh, 0BAh
                db 0AAh, 0AAh, 0AFh, 0FFh, 0FFh, 0BBh, 0FFh, 0EAh, 6, 0AAh
                db 6, 0BFh, 0FFh, 0EEh, 0AAh, 0ABh, 0AAh, 0BFh, 0BFh, 0EBh
                db 0FBh, 0BBh, 0BBh, 0BBh, 6, 0AAh, 4, 0AFh, 2Bh, 0FAh
                db 0AAh, 0AAh, 0AAh, 6, 0BBh, 4, 0AAh, 0AEh, 0EAh, 0AAh
                db 0FAh, 0BFh, 0EAh, 0AAh, 0BBh, 0BFh, 0FBh, 0BBh, 0BFh
                db 0E8h, 0BAh, 0AAh, 0AAh, 0AFh, 0FEh, 0ABh, 0EFh, 0FEh
                db 0FFh, 0FEh, 0EAh, 0AAh, 0AFh, 6, 0FFh, 4, 0EEh, 0AAh
                db 0AAh, 0AAh, 0FFh, 0AEh, 0EEh, 0FFh, 0EAh, 0AEh, 0EEh
                db 0FBh, 0BAh, 0FFh, 0FFh, 0EEh, 0EAh, 0BEh, 0EEh, 0EEh
                db 0EEh, 0BFh, 0FFh, 0EBh, 0FFh, 0FEh, 0BAh, 0EAh, 0ABh
                db 0EBh, 0FFh, 6, 0AAh, 6, 0FEh, 0ECh, 8Eh, 0AAh, 0AAh
                db 0BFh, 0FEh, 0AFh, 0BAh, 6, 0FFh, 5, 0FAh, 0BFh, 0BEh
                db 0FFh, 0FFh, 0EEh, 0AAh, 0AAh, 0AAh, 6, 0FFh, 5, 0ABh
                db 6, 0FFh, 4, 0FEh, 0BFh, 0AAh, 0AFh, 6, 0FFh, 8, 0FBh
                db 0FFh, 0EFh, 0AFh, 0FFh, 0AAh, 0A8h, 0BFh, 0FFh, 0FBh
                db 0FFh, 0BEh, 0EEh, 2Eh, 0FFh, 0FFh, 0BFh, 0FEh, 0AFh
                db 0BBh, 0FEh, 0AAh, 0EEh, 0BEh, 0FBh, 0AAh, 0BFh, 0EBh
                db 0BFh, 0FFh, 0EEh, 6, 0AAh, 7, 0AFh, 0ABh, 0EAh, 0AAh
                db 0AAh, 0AAh, 0A8h, 0BFh, 0AAh, 0AEh, 0EEh, 0EBh, 0AAh
                db 0AEh, 0EEh, 0ABh, 0BBh, 0AFh, 0AFh, 0EAh, 0BFh, 0AFh
                db 0FEh, 0AAh, 0A8h, 0AAh, 0AAh, 0AFh, 0EEh, 0EAh, 0EEh
                db 22h, 0AAh, 0AAh, 0FFh, 0FEh, 0EBh, 0BAh, 0BEh, 0AAh
                db 0EEh, 0FEh, 0FBh, 0BAh, 0AFh, 0AAh, 0BFh, 0FFh, 0EEh
                db 0AAh, 0AAh, 0AAh, 0FFh, 0FFh, 0FFh, 0EBh, 0FAh, 0AAh
                db 0FFh, 0FFh, 0FFh, 0FEh, 0A2h, 0FDh, 0E8h, 0AFh, 0FEh
                db 0ABh, 6, 0FFh, 6, 0EFh, 0BFh, 0BEh, 0EFh, 0FAh, 0AAh
                db 0A8h, 2Bh, 0FFh, 0EFh, 0FFh, 0EBh, 0BEh, 8Ah, 0BFh
                db 0FEh, 0FFh, 0FEh, 0EBh, 0BEh, 0BAh, 0AAh, 0FAh, 0BEh
                db 0FBh, 0BAh, 0BEh, 0EAh, 0BFh, 0FFh, 0AEh, 0AAh, 0AAh
                db 0AAh, 0AEh, 0BAh, 0AAh, 0FAh, 0AAh, 0BBh, 0FEh, 0AAh
                db 0BFh, 0FAh, 82h, 0FBh, 0E8h, 0ABh, 0FEh, 0ABh, 0FFh
                db 0EBh, 6, 0FFh, 4, 0EFh, 0BFh, 0BFh, 0AFh, 0FAh, 0AAh
                db 0AAh, 0Bh, 0FFh, 0EEh, 0FFh, 0ABh, 0BAh, 0A8h, 0BFh
                db 0FBh, 0FFh, 0FBh, 0ABh, 0FEh, 0BAh, 0AAh, 0FAh, 0FEh
                db 0FBh, 0BAh, 0BBh, 0AAh, 0BFh, 0FFh, 0BAh, 0AAh, 0AAh
                db 0AAh, 0BEh, 0BFh, 0EFh, 0AAh, 0AAh, 0AFh, 0FFh, 0AAh
                db 0FFh, 0FAh, 22h, 0FFh, 0E8h, 0AAh, 0FAh, 0ABh, 0FFh
                db 0ABh, 6, 0FFh, 4, 0BEh, 0FFh, 0BEh, 0AFh, 0EAh, 0AAh
                db 0AAh, 8Ah, 0FFh, 0BFh, 0FAh, 0AEh, 0AEh, 88h, 0ABh
                db 0FBh, 0FFh, 0EBh, 0AAh, 0FAh, 0BAh, 0AAh, 0FAh, 0EEh
                db 0FBh, 0AAh, 0BEh, 0AAh, 0BFh, 0FFh, 0BAh, 6, 0AAh, 4
                db 0BEh, 0AAh, 0AAh, 0AAh, 0AEh, 0FFh, 0EAh, 0FEh, 0FAh
                db 0CBh, 0FFh, 0A8h, 8Ah, 0AAh, 0AEh, 0EEh, 0ABh, 0FFh
                db 0FFh, 0FFh, 0FEh, 0FFh, 0AEh, 0FFh, 0BFh, 0EAh, 0AAh
                db 0AAh, 0Ah, 0FEh, 0FBh, 0BAh, 0EEh, 0FEh, 80h, 0AAh
                db 0FFh, 0FFh, 0EBh, 0AAh, 0EAh, 0AEh, 0AAh, 0EBh, 0BEh
                db 0EEh, 0BAh, 0BEh, 0AAh, 0BFh, 0FFh, 0FAh, 6, 0AAh, 4
                db 0FEh, 0AAh, 0AEh, 0AAh, 0AFh, 0BFh, 0ABh, 0FFh, 0E8h
                db 0C3h, 0FFh, 98h, 0Ah, 0AAh, 0ABh, 0FAh, 0BBh, 0FFh
                db 0FFh, 0FFh, 0FEh, 0FFh, 0ABh, 0FAh, 0BEh, 0EAh, 0AAh
                db 0AAh, 82h, 0BEh, 0EFh, 0EBh, 0BBh, 0EEh, 82h, 2Ah, 0FFh
                db 0FFh, 0AFh, 0AAh, 0EAh, 0AAh, 0ABh, 0BBh, 0FEh, 0EEh
                db 0BAh, 0BAh, 0AAh, 0BFh, 0FFh, 0AEh, 6, 0AAh, 4, 0BEh
                db 0AAh, 0BAh, 0AAh, 0ABh, 0FEh, 0BBh, 0AFh, 0FBh, 0CFh
                db 0FEh, 98h, 8, 88h, 0AAh, 0FAh, 0AFh, 0FEh, 0FFh, 0FFh
                db 0FEh, 0FEh, 0ABh, 0EEh, 0FEh, 0EAh, 0AAh, 0AAh, 88h
                db 0ABh, 0FFh, 0EAh, 0AFh, 0BAh, 82h, 23h, 0FFh, 0FFh
                db 0AEh, 0AAh, 0BBh, 0AEh, 0ABh, 0EBh, 0FFh, 0AEh, 0BAh
                db 0AEh, 0AAh, 0BFh, 0FFh, 0EEh, 0AAh, 0AAh, 0AAh, 2Ah
                db 0FAh, 0AAh, 0EAh, 0AAh, 0ABh, 0FAh, 0FBh, 0FFh, 0EFh
                db 0CFh, 0F9h, 0A8h, 20h, 0A2h, 2Ah, 0EAh, 0BFh, 0FFh
                db 0FFh, 0FFh, 0EBh, 0FFh, 0AFh, 0BAh, 0FBh, 0AAh, 0AAh
                db 0AAh, 0A2h, 0ABh, 0BEh, 0EFh, 0BFh, 0BEh, 88h, 83h
                db 0FFh, 0FFh, 0BAh, 0AAh, 0FBh, 0BAh, 0AEh, 0EEh, 0FFh
                db 0AEh, 0EAh, 0BAh, 0AAh, 0BFh, 0FFh, 0EEh, 0AAh, 0AAh
                db 0AAh, 2Bh, 0FAh, 0ABh, 0AAh, 0AAh, 0BBh, 0FEh, 0EFh
                db 0BBh, 0EFh, 0BFh, 0F9h, 0AAh, 8, 28h, 0AAh, 0ABh, 0BFh
                db 0FFh, 0FFh, 0FFh, 0FEh, 0FAh, 0EFh, 0EBh, 0FBh, 0AAh
                db 0AAh, 0AAh, 82h, 0AAh, 0FFh, 0AEh, 0BEh, 0BAh, 80h
                db 8Fh, 0FFh, 0FFh, 0BAh, 0AAh, 0EBh, 0AAh, 0FBh, 0ABh
                db 0BFh, 0AEh, 0EAh, 0BAh, 0AAh, 0BFh, 0FFh, 0AEh, 0AAh
                db 0AAh, 0AAh, 0EBh, 0FAh, 0AFh, 0AAh, 0AAh, 0BEh, 0EAh
                db 0FBh, 0BAh, 0FFh, 3Fh, 0FAh, 0AAh, 0Ah, 88h, 0, 0BFh
                db 6, 0FFh, 4, 0FBh, 0EFh, 0ABh, 0ABh, 0EBh, 0AAh, 0AAh
                db 0AAh, 0A0h, 0AAh, 0FBh, 0BEh, 0EAh, 0FAh, 0A0h, 0Fh
                db 0FFh, 0FEh, 0BAh, 0AAh, 0EFh, 0BBh, 0AEh, 0AEh, 0EEh
                db 0EEh, 0EAh, 0AEh, 0AAh, 0EFh, 0FFh, 0AEh, 0AAh, 0AAh
                db 0AAh, 0Bh, 0EAh, 0BBh, 0AAh, 0AAh, 0BFh, 0FBh, 0AEh
                db 0FFh, 0BCh, 0FFh, 0FAh, 0AAh, 82h, 0A0h, 0Fh, 6, 0FFh
                db 5, 0EFh, 0ABh, 0AEh, 0AFh, 0EBh, 0AAh, 0AAh, 0AAh, 0A8h
                db 2Ah, 0BEh, 0BBh, 0BAh, 0FAh, 0A2h, 3Fh, 0FFh, 0EFh
                db 0BAh, 0AAh, 0EFh, 0AEh, 0BAh, 0ABh, 0EFh, 0AEh, 0EAh
                db 0AEh, 0AAh, 0BFh, 0FFh, 6, 0AAh, 4, 0CFh, 0BAh, 0AEh
                db 0AAh, 0AAh, 0EFh, 0ABh, 0BAh, 0BEh, 0BFh, 0FFh, 0FAh
                db 6Ah, 82h, 80h, 6, 0FFh, 6, 0AFh, 0BAh, 0BEh, 0BFh, 0AEh
                db 0AAh, 0AAh, 0AAh, 0A2h, 0Ah, 0AEh, 0AFh, 0AAh, 0EEh
                db 0A0h, 3Fh, 0FBh, 0EBh, 0EAh, 0AAh, 0BBh, 0AEh, 0BAh
                db 0AFh, 0EFh, 0EEh, 0EAh, 0AEh, 0AAh, 0AFh, 0FFh, 0AEh
                db 0AAh, 0AAh, 0AAh, 8Fh, 0EAh, 0BAh, 0AAh, 0ABh, 0BFh
                db 0AAh, 0BAh, 0FEh, 0BFh, 0FFh, 0EAh, 0AAh, 0A8h, 83h
                db 6, 0FFh, 5, 0FEh, 0AFh, 0BAh, 0FAh, 0FEh, 0AEh, 0AAh
                db 0AAh, 0AAh, 0A8h, 0Ah, 0AAh, 0BFh, 0ABh, 0EEh, 0A2h
                db 3Fh, 0EFh, 0AFh, 0EAh, 0AAh, 0AFh, 0FAh, 0EAh, 0BFh
                db 0FFh, 0EEh, 0EAh, 0AEh, 0AAh, 0AFh, 0FEh, 0AEh, 0AAh
                db 0AAh, 0AAh, 0CEh, 0EBh, 0EAh, 0AAh, 0ABh, 0FAh, 0AAh
                db 0EAh, 0EEh, 0B3h, 0FFh, 0A9h, 0AAh, 22h, 87h, 6, 0FFh
                db 5, 0FEh, 0FFh, 0BAh, 0BBh, 0FEh, 0AEh, 0AAh, 0AAh, 0AAh
                db 0A8h, 82h, 0AAh, 0FFh, 0AFh, 0EEh, 88h, 3Fh, 0EEh, 0BEh
                db 0FAh, 0AAh, 0BFh, 0AFh, 0AAh, 0BFh, 0BFh, 0AAh, 0EAh
                db 0AAh, 0AAh, 0AFh, 0FEh, 0AEh, 0AAh, 0AAh, 0AAh, 83h
                db 0AEh, 0EAh, 0AAh, 0AFh, 0AAh, 0EFh, 0AAh, 0AEh, 0F3h
                db 0FFh, 0A9h, 0AAh, 0Ah, 5, 7Fh, 0FFh, 5Fh, 0FFh, 0FFh
                db 0FBh, 0EEh, 0FAh, 0EBh, 0FEh, 0BAh, 6, 0AAh, 4, 0, 0AAh
                db 0FEh, 0BFh, 0BEh, 0A0h, 0FFh, 0AEh, 0EFh, 0BAh, 0AAh
                db 0FFh, 0BAh, 0AAh, 0BFh, 0BEh, 0BAh, 0BAh, 0AEh, 0AAh
                db 0AFh, 0FEh, 0BAh, 0AAh, 0AAh, 0AAh, 82h, 0AFh, 0AAh
                db 0AAh, 0BEh, 0AAh, 0EFh, 0AAh, 0AAh, 0FFh, 0FFh, 0A6h
                db 0AAh, 0Ah, 7, 0D5h, 7Dh, 0FFh, 0FFh, 0FFh, 0FEh, 0FBh
                db 0EBh, 0AFh, 0FEh, 0BAh, 6, 0AAh, 4, 0, 0AAh, 0FAh, 0EFh
                db 0EEh, 88h, 0FFh, 0AAh, 0BEh, 0BAh, 0AAh, 0FEh, 0EAh
                db 0AAh, 0FEh, 0BEh, 0BAh, 0BAh, 0ABh, 0AAh, 0ABh, 0FEh
                db 0BAh, 0AAh, 0AAh, 0AAh, 0C3h, 0BAh, 0EAh, 0AAh, 0FEh
                db 0AAh, 0BFh, 0AAh, 0ABh, 0FFh, 0FEh, 0A6h, 8Ah, 0Ah
                db 87h, 75h, 0D7h, 5Fh, 0FFh, 0FFh, 0EBh, 0EFh, 0AAh, 0AFh
                db 0FAh, 0BAh, 6, 0AAh, 4, 8, 2Bh, 0BEh, 0EFh, 0BFh, 0A8h
                db 0FFh, 0BAh, 0EFh, 0FAh, 0AAh, 0FBh, 0AAh, 0AEh, 0FEh
                db 0BEh, 0BAh, 0BAh, 0ABh, 0EAh, 0ABh, 0FEh, 0BAh, 0AAh
                db 0AAh, 0AAh, 0CEh, 0AFh, 0AAh, 0AEh, 0FAh, 0AAh, 0BBh
                db 0EBh, 0ABh, 0FFh, 0FAh, 0AAh, 8Ah, 0Ah, 7, 7Fh, 0FDh
                db 0FFh, 0FFh, 0FEh, 0AEh, 0FBh, 0ABh, 0BFh, 0FAh, 0EAh
                db 6, 0AAh, 4, 0Ah, 0AFh, 0EFh, 0ABh, 0FFh, 0A8h, 0FEh
                db 0AEh, 0EEh, 0FAh, 0AAh, 0FBh, 0AAh, 0AEh, 0FEh, 0BAh
                db 0BAh, 0BAh, 0ABh, 0EAh, 0ABh, 0FEh, 0BAh, 0AAh, 0AAh
                db 0AAh, 20h, 0BEh, 0AAh, 0BBh, 0FAh, 0AAh, 0BFh, 0EBh
                db 0BBh, 0FEh, 0AAh, 0AAh, 8Ah, 20h, 0Fh, 7Fh, 0FFh, 0FFh
                db 0FFh, 0FEh, 0BBh, 0AFh, 0AEh, 0FFh, 0EAh, 6, 0AAh, 5
                db 8Bh, 0AFh, 0EAh, 0EFh, 0EFh, 0A0h, 0FEh, 0EAh, 0FBh
                db 0EAh, 0ABh, 0EEh, 0AAh, 0BAh, 0EEh, 0BEh, 0BAh, 0BAh
                db 0ABh, 0EAh, 0ABh, 0FEh, 0FAh, 0AAh, 0AAh, 0AAh, 0, 0FAh
                db 0AAh, 0EFh, 0FAh, 0ABh, 0EEh, 0EFh, 2Fh, 0FEh, 0A6h
                db 9Ah, 2Ah, 0Ah, 3Dh, 0FFh, 0DDh, 0FFh, 0FFh, 0FEh, 0AFh
                db 0AEh, 0AAh, 0FFh, 0EAh, 6, 0AAh, 5, 2Bh, 0FFh, 0EAh
                db 0BBh, 0EFh, 0A2h, 0FEh, 0FBh, 0FBh, 0AAh, 0ABh, 0FBh
                db 0AAh, 0BAh, 0FEh, 0EEh, 0BAh, 0BAh, 0ABh, 0BAh, 0ABh
                db 0FEh, 0EEh, 0AAh, 0AAh, 0AAh, 2, 0BAh, 0AFh, 0BFh, 0EAh
                db 0ABh, 0FEh, 0ECh, 3Fh, 0FEh, 6Ah, 0AAh, 2Ah, 20h, 1Dh
                db 0FFh, 0F7h, 0DFh, 0F7h, 0FAh, 0EFh, 0BAh, 0AFh, 0FFh
                db 6, 0AAh, 6, 2Ah, 0BFh, 0AAh, 0AFh, 0BAh, 0A2h, 0FBh
                db 0EFh, 0AFh, 0EAh, 0ABh, 0FBh, 0AEh, 0EEh, 0FAh, 0FAh
                db 0AEh, 0AEh, 0BBh, 0EAh, 0ABh, 0FEh, 0EEh, 0AAh, 0AAh
                db 0AAh, 8, 0AAh, 0FAh, 0FBh, 0BAh, 0AFh, 0EFh, 0BCh, 0FFh
                db 0FAh, 69h, 0AAh, 28h, 0A0h, 0F5h, 0F7h, 0DFh, 0DFh
                db 5Fh, 0EBh, 0BEh, 0FEh, 0AEh, 0FEh, 6, 0AAh, 6, 0Fh
                db 0FFh, 0AAh, 0ABh, 0EEh, 0BBh, 0FBh, 0AFh, 0EFh, 0BAh
                db 0AFh, 0EBh, 0AAh, 0BBh, 0BEh, 0EEh, 0AEh, 0AEh, 0BBh
                db 0AAh, 0ABh, 0FEh, 0EEh, 0AAh, 0AAh, 0AAh, 0C0h, 0AFh
                db 0EBh, 0FEh, 0EAh, 0AFh, 0FFh, 0BCh, 0FFh, 0EAh, 0A9h
                db 6Ah, 28h, 88h, 0D5h, 77h, 5Fh, 0DDh, 5Fh, 0EBh, 0FBh
                db 0FAh, 0EFh, 0FEh, 6, 0AAh, 6, 3Fh, 0FEh, 0BAh, 0ABh
                db 0EBh, 0ABh, 0EFh, 0ABh, 0FFh, 0BAh, 0BFh, 0EEh, 0AEh
                db 0BEh, 0BEh, 0EEh, 0AEh, 0AEh, 0AEh, 0FEh, 0AAh, 0FBh
                db 6, 0AAh, 4, 8, 3Bh, 0BFh, 0EBh, 0EAh, 0AFh, 0EEh, 0F3h
                db 0FFh, 0E9h, 0A5h, 0AAh, 0A8h, 0A1h, 0F7h, 0F7h, 0DFh
                db 55h, 7Fh, 0AEh, 0BEh, 0EAh, 0BFh, 0FEh, 6, 0AAh, 6
                db 3Fh, 0EAh, 0EAh, 0AAh, 0BBh, 0EBh, 0BAh, 0AEh, 0FFh
                db 0EAh, 0AFh, 0EEh, 0AEh, 0BAh, 0EEh, 0FAh, 0AEh, 0AEh
                db 0ABh, 0EBh, 0AAh, 0FBh, 0AEh, 0AAh, 0AAh, 0AAh, 30h
                db 0Fh, 0FFh, 0AEh, 0AAh, 0BFh, 0FEh, 0FFh, 0FFh, 0F9h
                db 0A5h, 0A8h, 0A0h, 89h, 77h, 0DFh, 0DDh, 55h, 0FAh, 0BFh
                db 0BAh, 0EAh, 0FFh, 0FAh, 6, 0AAh, 5, 0A8h, 0FFh, 0AEh
                db 0EAh, 0AAh, 0AAh, 0BFh, 0FEh, 0AAh, 0FEh, 0EAh, 0BEh
                db 0EEh, 0AEh, 0AEh, 0FAh, 0EEh, 0AAh, 0ABh, 0AAh, 0EFh
                db 0AEh, 0FBh, 0AEh, 0AAh, 0AAh, 0AAh, 30h, 0Bh, 0FEh
                db 0FAh, 0AAh, 0FFh, 0FBh, 0FCh, 0FFh, 0F9h, 0A6h, 0A8h
                db 88h, 81h, 7Dh, 5Fh, 0FDh, 5Fh, 0FAh, 0FEh, 0ABh, 0EBh
                db 0BFh, 6, 0AAh, 7, 0FFh, 0ABh, 0AAh, 0AAh, 0AAh, 0ABh
                db 0FFh, 0EAh, 0FBh, 0AAh, 0BEh, 0EBh, 0ABh, 0BBh, 0BAh
                db 0FAh, 0ABh, 0ABh, 0AAh, 0EFh, 0ABh, 0FBh, 0AEh, 0AAh
                db 0AAh, 0AAh, 33h, 83h, 0FFh, 0EEh, 0EFh, 0FFh, 0FBh
                db 0FFh, 0FFh, 0FAh, 0AAh, 0A2h, 8Ah, 8Dh, 5Fh, 5Fh, 0F5h
                db 5Fh, 0FAh, 0EEh, 0EBh, 0AAh, 0FAh, 6, 0AAh, 4, 0AEh
                db 0AAh, 0BFh, 0FFh, 0BAh, 0AAh, 0AAh, 0A8h, 0AAh, 0AFh
                db 0FAh, 0EEh, 0FAh, 0AEh, 0FBh, 0AAh, 0FEh, 0FEh, 0EAh
                db 0AFh, 0ABh, 0AAh, 0EAh, 0AEh, 0FBh, 0AEh, 0AAh, 0AAh
                db 0AAh, 30h, 23h, 0FFh, 0FBh, 0FFh, 0FFh, 0EFh, 0FFh
                db 0FFh, 0FAh, 0AAh, 0A2h, 88h, 8Fh, 75h, 0FFh, 0D5h, 7Fh
                db 0BBh, 0ABh, 0AFh, 0ABh, 0EAh, 6, 0AAh, 4, 0BFh, 0FFh
                db 0EFh, 0FEh, 0FAh, 0AAh, 0AAh, 0A8h, 8Ah, 0ABh, 0FEh
                db 0BFh, 0FEh, 0AEh, 0FBh, 0ABh, 0EFh, 0EEh, 0FAh, 0AFh
                db 0ABh, 0AAh, 0EBh, 0AFh, 0FEh, 0AEh, 0EAh, 0AAh, 0AAh
                db 88h, 0C0h, 6, 0FFh, 4, 0E3h, 0FFh, 0FFh, 0E6h, 0AAh
                db 0AAh, 2Ah, 0Fh, 0FFh, 0FFh, 0D5h, 0FFh, 0EFh, 0AAh
                db 0BEh, 0AFh, 0EAh, 0AAh, 0AAh, 0AAh, 0ABh, 0BFh, 0FFh
                db 0AFh, 0FAh, 0EAh, 0AAh, 0AAh, 0AAh, 22h, 0AAh, 0BFh
                db 0EFh, 0BAh, 0ABh, 0EEh, 0AFh, 0BBh, 0EEh, 0FAh, 9Fh
                db 0ABh, 0AAh, 0EBh, 0BBh, 0FEh, 0BAh, 0AAh, 0AAh, 0AAh
                db 8Ah, 38h, 3Fh, 0FFh, 0FFh, 0FFh, 0ECh, 0FFh, 0FFh, 0E6h
                db 0AAh, 0AAh, 0A8h, 0Fh, 0FFh, 0FFh, 57h, 0FFh, 0BBh
                db 0AAh, 0EAh, 0AFh, 0BAh, 0AAh, 0AAh, 0AAh, 0ABh, 0FFh
                db 0FAh, 0BFh, 0ABh, 0EAh, 0AAh, 0AAh, 0AAh, 22h, 0AAh
                db 0ABh, 0FBh, 0EEh, 0FBh, 0AAh, 0FBh, 0FEh, 0FAh, 0FAh
                db 0ABh, 0EBh, 0AAh, 0BBh, 0BFh, 0FEh, 0BBh, 0AAh, 0AAh
                db 0AAh, 0B3h, 38h, 2Fh, 0FEh, 0FFh, 0FBh, 0E3h, 0FFh
                db 0FFh, 0AAh, 0AAh, 0A8h, 0A0h, 2Fh, 0FFh, 0FDh, 5Fh
                db 0FAh, 0AEh, 0AAh, 0FAh, 0AFh, 0EAh, 0AAh, 0AAh, 0AAh
                db 0AFh, 0FEh, 0ABh, 0FFh, 0ABh, 6, 0AAh, 4, 28h, 2Ah
                db 0AAh, 0BBh, 0FBh, 0BEh, 0FFh, 0BEh, 0FBh, 0BAh, 0EAh
                db 7Bh, 0EAh, 0EAh, 0BBh, 0BFh, 0BAh, 0BEh, 0AAh, 0AAh
                db 0AAh, 0FCh, 8Eh, 0Ah, 0FBh, 0FFh, 0FEh, 0ECh, 0FFh
                db 0FFh, 0AAh, 0AAh, 88h, 89h, 7Fh, 0FFh, 0F5h, 5Fh, 0EBh
                db 0BAh, 0ABh, 0EAh, 0BEh, 0FAh, 0AAh, 0AAh, 0AAh, 0ABh
                db 0FAh, 0EEh, 0FEh, 0AFh, 6, 0AAh, 4, 0Ah, 0, 0AAh, 0AEh
                db 0FFh, 0EBh, 0AFh, 0FAh, 0FFh, 0BBh, 0BAh, 7Bh, 0EAh
                db 0EAh, 0BAh, 0AFh, 0FAh, 0BEh, 0AAh, 0AAh, 0AAh, 0BCh
                db 0A2h, 3, 0FFh, 0FFh, 0FAh, 0F3h, 0FFh, 0FEh, 9Ah, 6Ah
                db 82h, 17h, 0FFh, 0FFh, 0F5h, 7Fh, 0AFh, 0EEh, 0ABh, 0EAh
                db 0FBh, 0EAh, 6, 0AAh, 4, 0FBh, 0BBh, 0FEh, 0AEh, 0AAh
                db 0EAh, 0AAh, 0AAh, 0Ah, 80h, 0, 0ABh, 0BEh, 0BFh, 0AFh
                db 0EBh, 0BBh, 0BBh, 0EAh, 0AFh, 0EAh, 0EAh, 0BBh, 0AFh
                db 0EEh, 0BAh, 0AAh, 0AAh, 0AAh, 0FAh, 2Ch, 83h, 0FFh
                db 0FFh, 0AEh, 0F3h, 0FFh, 0FEh, 6Ah, 6Ah, 28h, 5Fh, 0FFh
                db 0FFh, 0D5h, 0FBh, 0BEh, 0EEh, 0ABh, 0ABh, 0BFh, 0BAh
                db 6, 0AAh, 4, 0EAh, 0EFh, 0FEh, 0BEh, 0ABh, 0FAh, 0AAh
                db 0A8h, 80h, 0AAh, 80h, 2Ah, 0ABh, 0FAh, 0FEh, 0BBh, 0FEh
                db 0EBh, 0EAh, 6Fh, 0EAh, 0EAh, 0BBh, 0ABh, 0EEh, 0BEh
                db 0AAh, 0AAh, 0AAh, 0FEh, 8Ah, 0E0h, 0EAh, 0EAh, 0EBh
                db 8Fh, 0FFh, 0FEh, 6Ah, 0AAh, 28h, 57h, 0FFh, 0FFh, 0D5h
                db 0EEh, 0BAh, 0BAh, 0AFh, 0AAh, 0FBh, 0EAh, 6, 0AAh, 4
                db 0ABh, 0AFh, 0FAh, 0BAh, 0AFh, 0FAh, 0AAh, 0AAh, 22h
                db 2, 0AAh, 8Ah, 0AFh, 0FEh, 0EBh, 0EBh, 0BAh, 0EBh, 0A9h
                db 0AFh, 0EAh, 0EAh, 0AFh, 0AEh, 0EEh, 0EEh, 0AAh, 0AAh
                db 0AAh, 0AFh, 0F0h, 0B8h, 2, 0AAh, 0EAh, 8Fh, 0FFh, 0FEh
                db 0AAh, 0A8h, 0A0h, 57h, 0FFh, 0FFh, 57h, 0EFh, 0ABh
                db 0EAh, 0EFh, 0ABh, 0FFh, 0BAh, 0AAh, 0AAh, 0AAh, 0FAh
                db 0ABh, 0BFh, 0FAh, 0BAh, 0AFh, 0AEh, 0AAh, 0AAh, 0A8h
                db 20h, 0Ah, 2Ah, 8Fh, 0FAh, 0AFh, 0AEh, 0FEh, 0AEh, 0AAh
                db 0BBh, 0EAh, 0EAh, 0AFh, 0ABh, 0FAh, 0FAh, 6, 0AAh, 4
                db 0BFh, 0Ah, 20h, 3Bh, 0ABh, 0CFh, 0FBh, 0FEh, 0AAh, 68h
                db 0A1h, 75h, 0FFh, 0FDh, 76h, 0BFh, 0AFh, 0ABh, 0FFh
                db 0AFh, 0FFh, 0EAh, 0AAh, 0AAh, 0AAh, 0EFh, 0AEh, 0FEh
                db 0EAh, 0BEh, 0BFh, 0ABh, 0AAh, 0AAh, 0Ah, 0, 20h, 2Ah
                db 8Fh, 0EEh, 0AEh, 0AFh, 0BAh, 0AEh, 0A9h, 0BBh, 0EAh
                db 0EAh, 0AFh, 0ABh, 0FAh, 0EEh, 0AAh, 0AAh, 0AAh, 2Ah
                db 0AAh, 0E0h, 2Ch, 0Ah, 0AFh, 3Fh, 0FBh, 0FEh, 0AAh, 98h
                db 1, 0F7h, 0FFh, 0FDh, 0DAh, 0EEh, 0BAh, 0AEh, 0FEh, 0AFh
                db 0FFh, 0EAh, 0AAh, 0AAh, 0ABh, 0FFh, 0AFh, 0FFh, 0ABh
                db 0FAh, 0FEh, 0EBh, 0AAh, 0AAh, 0A2h, 80h, 80h, 0AEh
                db 3Fh, 0FAh, 0AEh, 0AEh, 0EAh, 0EEh, 0AAh, 0BBh, 0EAh
                db 0EAh, 0AEh, 0AAh, 0FAh, 0AEh, 0AAh, 0AAh, 0AAh, 8Ah
                db 0AAh, 0BAh, 80h, 0A8h, 0Bh, 3Fh, 0FFh, 0FEh, 0A9h, 0A0h
                db 15h, 0FFh, 0FFh, 55h, 0DBh, 0AEh, 0BAh, 0BBh, 0FEh
                db 0BFh, 0FFh, 0EAh, 0AAh, 0AAh, 0ABh, 0EFh, 0AFh, 0EEh
                db 0FEh, 0EFh, 0FAh, 0EAh, 0EBh, 0EAh, 0A8h, 2Ah, 8Ah
                db 0FBh, 3Fh, 0AAh, 0BEh, 0ABh, 0EAh, 0AEh, 0A6h, 0BBh
                db 0EAh, 0EAh, 0ABh, 0AEh, 0EAh, 0FAh, 0AAh, 0AAh, 0AAh
                db 80h, 0AAh, 0ABh, 0FBh, 0Ah, 0ACh, 0FFh, 0EFh, 0FFh
                db 0AAh, 81h, 7Fh, 0FFh, 0F5h, 0FDh, 5Bh, 0EAh, 0EAh, 0BBh
                db 0EAh, 0FBh, 0FFh, 0AAh, 0AAh, 0AAh, 0ABh, 0BEh, 0BFh
                db 0FFh, 0AFh, 0BFh, 0EBh, 0AAh, 0EEh, 0FFh, 0AAh, 80h
                db 0Ah, 0BEh, 8Fh, 0EAh, 0BAh, 0AEh, 0EAh, 0BAh, 0A6h
                db 0BFh, 0EAh, 0EAh, 0AEh, 0AFh, 0BAh, 0FAh, 0AAh, 0AAh
                db 0AAh, 0A0h, 2Ah, 0AAh, 0AEh, 0FAh, 0F0h, 0FFh, 0AFh
                db 0FFh, 0BFh, 95h, 7Fh, 0FFh, 0F7h, 0D6h, 0EFh, 0AAh
                db 0AAh, 0EFh, 0EBh, 0FFh, 0FBh, 0EAh, 0AAh, 0AAh, 0AFh
                db 0BEh, 0BFh, 0FAh, 0EEh, 0EEh, 0BEh, 0A2h, 0BAh, 0BFh
                db 0FEh, 0AAh, 0Bh, 0FEh, 3Fh, 0B6h, 0EEh, 0AFh, 0AAh
                db 0BAh, 99h, 0BFh, 0EAh, 0EAh, 0AEh, 0AFh, 0EAh, 0FAh
                db 6, 0AAh, 4, 2, 0AAh, 0AAh, 0ABh, 0EFh, 0FAh, 0BFh, 0FEh
                db 0BAh, 0FFh, 0FFh, 0EEh, 0FEh, 0AFh, 0EFh, 0AEh, 0AAh
                db 0AEh, 0AAh, 0EFh, 0FAh, 0AAh, 0AAh, 0AAh, 0BBh, 0EEh
                db 0ABh, 0EEh, 0FBh, 0BAh, 0FAh, 0A2h, 0BBh, 0EEh, 0FEh
                db 0EAh, 8Ah, 0FAh, 3Bh, 5Ah, 0EAh, 0BBh, 0AAh, 0AAh, 0AAh
                db 0AFh, 0EAh, 0BAh, 0AAh, 0AAh, 0EAh, 0FAh, 0AAh, 0AAh
                db 0AAh, 0A8h, 0A0h, 2, 0AAh, 0AEh, 0FBh, 0EEh, 0BBh, 0FAh
                db 0AEh, 0FFh, 0BFh, 0EBh, 0BEh, 0AFh, 0FBh, 0BBh, 0AAh
                db 0BEh, 0AAh, 0BFh, 0EBh, 0AAh, 0AAh, 0AAh, 0BFh, 0EAh
                db 0AEh, 0BFh, 0AEh, 0FAh, 0EEh, 0A8h, 0AFh, 0BBh, 0FBh
                db 0AAh, 0AAh, 0F8h, 3Eh, 0B6h, 0AAh, 0BEh, 0AAh, 0AAh
                db 0AAh, 0EFh, 0EAh, 0BAh, 0AAh, 0AEh, 0EAh, 0EAh, 6, 0AAh
                db 4, 8, 0, 2, 0AFh, 0AFh, 0AEh, 0FEh, 0FEh, 0BAh, 0FFh
                db 0EEh, 0AFh, 0FAh, 0BBh, 0FFh, 0EBh, 0AAh, 0BAh, 0AAh
                db 0BFh, 0ABh, 0AAh, 0AAh, 0AAh, 0BEh, 0EAh, 0AEh, 0BEh
                db 3Fh, 0E8h, 0FAh, 0A8h, 0BAh, 0BEh, 0BEh, 0FFh, 0AAh
                db 0A8h, 0FFh, 5Ah, 0EAh, 6, 0AAh, 4, 0BFh, 0EAh, 0BAh
                db 0AAh, 0BBh, 0AAh, 0BAh, 6, 0AAh, 4, 0A0h, 0Ah, 0AAh
                db 0FEh, 0FBh, 0ABh, 0EAh, 0BAh, 0BBh, 0FFh, 0FAh, 0AFh
                db 0EAh, 0BFh, 0BBh, 0AAh, 0AAh, 0FEh, 0AAh, 0BEh, 0AEh
                db 0AAh, 0AAh, 0AAh, 0FBh, 0AAh, 0AEh, 0BAh, 3Fh, 0F8h
                db 0FEh, 0A2h, 2Fh, 0BBh, 0FAh, 0BFh, 0FBh, 0A8h, 0EEh
                db 6Ah, 0AAh, 0BAh, 0AAh, 0AAh, 0AAh, 0FFh, 0EAh, 0BAh
                db 0AAh, 0BEh, 0AAh, 0FAh, 6, 0AAh, 5, 0A0h, 2Fh, 0EFh
                db 0EAh, 0AFh, 0ABh, 0EAh, 0ABh, 0FBh, 0AAh, 0BFh, 0EAh
                db 0BFh, 0BEh, 0AAh, 0AAh, 0BAh, 0AAh, 0BEh, 0AEh, 0AAh
                db 0AAh, 0AAh, 0EEh, 0EAh, 0BAh, 0B8h, 3Fh, 0B8h, 0BFh
                db 0A8h, 8Bh, 0AAh, 0ABh, 0EEh, 0BEh, 83h, 0BFh, 6, 0AAh
                db 6, 0EFh, 0EAh, 0BAh, 0AAh, 0BEh, 0AAh, 0FAh, 6, 0AAh
                db 6, 0BEh, 0EFh, 0AAh, 0BAh, 0AAh, 0EAh, 0ABh, 0FEh, 0AAh
                db 0BFh, 0EAh, 0EEh, 0BFh, 0AEh, 0AAh, 0EAh, 0AAh, 0FAh
                db 0BAh, 0AAh, 0AAh, 0AAh, 0FBh, 0AAh, 0EAh, 0A8h, 2Ah
                db 0E8h, 0FAh, 0A8h, 0A0h, 0BEh, 0AAh, 0AAh, 0A2h, 23h
                db 0EFh, 0AAh, 0EAh, 0BAh, 0AAh, 0AAh, 0AAh, 0FAh, 0EAh
                db 0BAh, 0AAh, 0BAh, 0AAh, 0EAh, 6, 0AAh, 6, 0EFh, 0BAh
                db 0AAh, 0AAh, 0ABh, 0AAh, 0ABh, 0BBh, 0AAh, 0FFh, 0BAh
                db 0BEh, 0EEh, 0AAh, 0AAh, 0EAh, 0AAh, 0EAh, 6, 0AAh, 4
                db 0FBh, 0AAh, 0BAh, 0BAh, 3Ah, 0E8h, 3Eh, 0A8h, 2Ah, 20h
                db 0Fh, 0BAh, 0, 0FFh, 0BAh, 0ABh, 6, 0AAh, 5, 0EBh, 0AAh
                db 0BAh, 0AAh, 0EEh, 0AAh, 0EAh, 6, 0AAh, 6, 0BFh, 0EAh
                db 6, 0AAh, 4, 0AFh, 0FEh, 0ABh, 0FFh, 0EAh, 0FEh, 0FEh
                db 0AAh, 0ABh, 0AAh, 0ABh, 0EAh, 0AAh, 0AAh, 0AAh, 0ABh
                db 0BEh, 0AAh, 0EAh, 0A8h, 3Ah, 0A0h, 0FAh, 0AAh, 0Ah
                db 0AAh, 2Ah, 0A0h, 3Fh, 0AFh, 0EAh, 0AEh, 6, 0AAh, 4
                db 0ABh, 0BBh, 0AAh, 0BAh, 0AAh, 0FAh, 6, 0AAh, 7, 0BAh
                db 0FBh, 0AAh, 0EAh, 0AAh, 0BAh, 0AAh, 0FFh, 0EAh, 0ABh
                db 0FEh, 0AAh, 0FAh, 0FBh, 0AAh, 0AFh, 6, 0AAh, 6, 0ABh
                db 0EEh, 0AAh, 0EAh, 0A2h, 3Eh, 0A8h, 0FEh, 0AAh, 0A2h
                db 0A0h, 80h, 3Fh, 0EFh, 0AAh, 0AAh, 0AEh, 6, 0AAh, 7
                db 0BAh, 0AAh, 0FAh, 6, 0AAh, 7, 0BEh, 0FEh, 0AFh, 0AAh
                db 0AAh, 0BAh, 0ABh, 0FEh, 0AEh, 0AFh, 0FEh, 0AAh, 0EAh
                db 0EBh, 0AAh, 0AFh, 0AAh, 0ABh, 6, 0AAh, 4, 0AEh, 0EAh
                db 0ABh, 0AAh, 0A8h, 0AEh, 0A2h, 0FAh, 0AAh, 0AAh, 8, 0Ch
                db 0EFh, 0BAh, 0AAh, 0AAh, 0BAh, 6, 0AAh, 5, 0AEh, 0AAh
                db 0EAh, 0AAh, 0FAh, 6, 0AAh, 6, 0ABh, 0EBh, 0AAh, 0BAh
                db 0AAh, 0AAh, 0BAh, 0ABh, 0FAh, 0BAh, 0BFh, 0FAh, 0ABh
                db 0AAh, 0EAh, 0AAh, 0BEh, 6, 0AAh, 6, 0AFh, 0AAh, 0ABh
                db 0AAh, 0A2h, 0EAh, 0A0h, 0FAh, 0AAh, 0A0h, 20h, 0FFh
                db 0BAh, 6, 0AAh, 0Bh, 0EAh, 0AAh, 0EAh, 6, 0AAh, 6, 0BEh
                db 0AAh, 0AAh, 0BAh, 0AAh, 0EAh, 0EAh, 0AAh, 0EBh, 0EAh
                db 0BFh, 0BAh, 0AAh, 0AAh, 0ABh, 0AAh, 0BBh, 0AAh, 0AEh
                db 6, 0AAh, 4, 0AFh, 0AAh, 0AAh, 0AAh, 0A8h, 0EAh, 0A2h
                db 0AAh, 0AAh, 22h, 0AEh, 0EEh, 0AAh, 0AAh, 0AAh, 0ABh
                db 6, 0AAh, 6, 0AEh, 0AAh, 0AAh, 0AAh, 0FAh, 6, 0AAh, 6
                db 0EEh, 0AAh, 0AAh, 0EAh, 0ABh, 0AAh, 0EAh, 0ABh, 0BEh
                db 0AAh, 0FEh, 0EAh, 0AAh, 0AAh, 0EBh, 0AAh, 0AEh, 6, 0AAh
                db 6, 0BEh, 6, 0AAh, 5, 8Bh, 0AAh, 0AAh, 0AAh, 0AFh, 0BAh
                db 6, 0AAh, 0Bh, 0ABh, 0AAh, 0ABh, 0BAh, 6, 0AAh, 5, 0ABh
                db 6, 0AAh, 4, 0ABh, 0ABh, 0AAh, 0ABh, 0EEh, 0AAh, 0FAh
                db 0AAh, 0AAh, 0ABh, 0ABh, 0AAh, 0BAh, 0AAh, 0BAh, 6, 0AAh
                db 4, 0BFh, 6, 0AAh, 5, 0A3h, 0AAh, 0AAh, 0AAh, 0BAh, 6
                db 0AAh, 0Bh, 0AEh, 0ABh, 0AAh, 0ABh, 0EAh, 6, 0AAh, 5
                db 0BAh, 6, 0AAh, 4, 0AFh, 0AAh, 0AAh, 0ABh, 0BAh, 0ABh
                db 0EEh, 0AAh, 0AAh, 0AAh, 0AEh, 0AAh, 0BAh, 0AAh, 0BAh
                db 6, 0AAh, 4, 0BBh, 0AAh, 0AAh, 0AAh, 0AEh, 0AAh, 0ABh
                db 6, 0AAh, 0Fh, 0BAh, 0AEh, 0AAh, 0ABh, 0EAh, 6, 0AAh
                db 5, 0EAh, 6, 0AAh, 4, 0BEh, 0AAh, 0AAh, 0ABh, 0BAh, 0ABh
                db 0EAh, 6, 0AAh, 7, 0EAh, 6, 0AAh, 4, 0EEh, 6, 0AAh, 9
                db 0BAh, 6, 0AAh, 0Eh, 0ABh, 0EAh, 6, 0AAh, 9, 0AFh, 0EAh
                db 0AAh, 0AAh, 0ABh, 0AAh, 0ABh, 6, 0AAh, 0Dh, 0FAh, 6
                db 0AAh, 8, 0ABh, 0EAh, 6, 0AAh, 0Ch, 0FAh, 6, 0AAh, 0Ch
                db 0BAh, 0AAh, 0AAh, 0AAh, 0AEh, 6, 0AAh, 0Fh, 0BAh, 6
                db 0AAh, 8, 0BEh, 6, 0AAh, 0Fh, 0ABh, 6, 0AAh, 1Eh, 0EAh
                db 6, 0AAh, 7, 0ABh, 6, 0AAh, 17h
mountains1       db 6, 0AAh, 70h, 0BBh, 0FBh, 0BFh, 0BBh, 0BFh, 0BBh, 0BBh ; ...
                db 0FFh, 0BBh, 0BBh, 0BFh, 6, 0BBh, 8, 0FBh, 0FFh, 0FFh
                db 0BBh, 0BFh, 0FBh, 6, 0BBh, 10h, 0FFh, 0FFh, 0FBh, 6
                db 0BBh, 0Ch, 0FEh, 0FEh, 0FEh, 0FFh, 0FEh, 0EFh, 0FFh
                db 0FFh, 0FFh, 0EFh, 0FFh, 0FFh, 0EEh, 0EEh, 0EFh, 0FEh
                db 0EFh, 0FFh, 0FFh, 0FEh, 0FFh, 0EEh, 0EFh, 0FFh, 0FFh
                db 0FFh, 0EEh, 0EFh, 0EEh, 0EFh, 0FEh, 0FFh, 0EFh, 0FEh
                db 0EFh, 0EFh, 0FFh, 0FEh, 0FFh, 0EFh, 0FFh, 0FFh, 0FEh
                db 0FFh, 0EEh, 6, 0EFh, 4, 0FEh, 0FFh, 0FFh, 0FEh, 0EEh
                db 0EEh, 0EEh, 6, 0FFh, 32h, 0EFh, 0FBh, 6, 0FFh, 0FFh
                db 6, 0FFh, 0FFh, 6, 0FFh, 0F9h, 0F0h, 2Bh, 0BAh, 6, 0FFh
                db 4, 0C2h, 0BBh, 0BAh, 0AFh, 6, 0FFh, 2Dh, 0C3h, 0EAh
                db 0ABh, 0BBh, 0EEh, 0AFh, 0FFh, 0CEh, 0AEh, 0EFh, 6, 0FFh
                db 1Eh, 0FDh, 6Ah, 0ABh, 0BBh, 0BFh, 0EEh, 6, 0FFh, 9
                db 0FCh, 3, 0EBh, 0BFh, 6, 0FFh, 4, 0Bh, 0ABh, 6, 0FFh
                db 1Fh, 0FDh, 2Bh, 0BFh, 6, 0FFh, 0Ch, 0F0h, 3, 0EAh, 0EEh
                db 0EFh, 0FFh, 0FFh, 0FFh, 0Eh, 0AFh, 6, 0FFh, 1Fh, 0F4h
                db 0AFh, 6, 0FFh, 0Dh, 0F0h, 0Fh, 0EAh, 0BFh, 0FFh, 0FFh
                db 0FFh, 0FCh, 0Fh, 0FBh, 6, 0FFh, 10h, 0C0h, 2, 0AAh
                db 0BAh, 6, 0FFh, 0Bh, 0F4h, 2Bh, 0BBh, 0BAh, 0ABh, 0EFh
                db 0FFh, 0BBh, 0BBh, 0AAh, 0AEh, 0EEh, 0FFh, 0FFh, 0FFh
                db 0, 3Fh, 0EAh, 0BFh, 0FFh, 0FFh, 0FFh, 0FCh, 3Eh, 0BFh
                db 0FFh, 0FFh, 0FCh, 2, 0AEh, 0AAh, 0EEh, 0EEh, 0FFh, 0BBh
                db 6, 0FFh, 5, 0C0h, 33h, 0FCh, 2, 0EFh, 6, 0FFh, 7, 0AAh
                db 0ABh, 0BBh, 0FFh, 0F4h, 0AAh, 0EEh, 0EEh, 0FFh, 0FFh
                db 0FBh, 0BBh, 6, 0FFh, 4, 0FBh, 0BBh, 0B0h, 0C0h, 3Eh
                db 0EAh, 6, 0FFh, 4, 0F0h, 3Ch, 0BFh, 0FFh, 0FFh, 0F0h
                db 0, 2, 0EEh, 0AAh, 0BFh, 6, 0FFh, 6, 0C0h, 0, 33h, 0FBh
                db 0A8h, 0AFh, 0EAh, 0EAh, 0BEh, 0AEh, 0EEh, 0EEh, 0EEh
                db 6, 0FFh, 4, 0D8h, 2Ah, 0AFh, 0FFh, 0FFh, 0FFh, 6, 0EEh
                db 4, 0FFh, 0FBh, 0BFh, 0FFh, 0Fh, 0C0h, 3Fh, 0EAh, 0AEh
                db 0EAh, 0AEh, 0EEh, 0C0h, 3Ch, 0BFh, 0FFh, 0FFh, 0F0h
                db 3, 0FFh, 0F0h, 0CFh, 0AAh, 0ABh, 0BFh, 0FFh, 0F0h, 6
                db 0, 4, 33h, 0FBh, 0AAh, 0ABh, 0AAh, 0FBh, 0BBh, 0AAh
                db 0BFh, 0FBh, 0BBh, 0AEh, 0EFh, 0AAh, 0AAh, 90h, 2Ah
                db 0ABh, 0BBh, 0BBh, 0BBh, 0EAh, 0AAh, 0BEh, 0AAh, 0ABh
                db 0EFh, 0BFh, 0FCh, 3Ch, 0, 0FEh, 0FAh, 0BFh, 0FFh, 0FFh
                db 0FFh, 3, 3Ch, 8Fh, 0FFh, 0FFh, 0C0h, 3, 0FFh, 0CBh
                db 0FFh, 0, 0, 0F0h, 0, 0Fh, 0C0h, 0C3h, 0, 0, 33h, 0FFh
                db 0AAh, 0ABh, 6, 0AAh, 5, 0D7h, 6, 0AAh, 4, 0ABh, 42h
                db 6, 0AAh, 0Ah, 0ACh, 0AAh, 0B0h, 0F0h, 0, 0FFh, 0B8h
                db 0AAh, 0AAh, 0ACh, 0, 0C3h, 3Eh, 2Eh, 0AAh, 0AAh, 0C0h
                db 3, 6, 0FFh, 4, 33h, 0F3h, 0Ch, 0FFh, 0C0h, 3Ch, 0C0h
                db 0, 33h, 0FBh, 0AAh, 0ABh, 6, 0FFh, 4, 0D0h, 57h, 6
                db 0FFh, 5, 42h, 0AAh, 0ABh, 0BBh, 0B6h, 0FFh, 0FBh, 0BBh
                db 0FEh, 0EEh, 0FAh, 0F0h, 3Fh, 0C0h, 0F0h, 3, 0FEh, 0E8h
                db 0AFh, 0FFh, 0F0h, 33h, 3Fh, 3Eh, 22h, 0FFh, 0FFh, 0
                db 3, 3Fh, 0FFh, 0FFh, 0FFh, 33h, 0F3h, 0Ch, 0CFh, 0F0h
                db 0FFh, 0C0h, 0, 33h, 0FBh, 0BAh, 0ABh, 0AAh, 0AAh, 0AAh
                db 0B4h, 5, 55h, 0FAh, 0AAh, 0AAh, 0ABh, 7Dh, 4, 28h, 0AAh
                db 0ABh, 56h, 6, 0AAh, 6, 0B0h, 0CAh, 0C3h, 30h, 0Fh, 0FEh
                db 0E8h, 2Ah, 0AAh, 0B0h, 0, 3Ch, 0FEh, 8Ah, 0AAh, 0ABh
                db 0, 3, 3Fh, 0FFh, 0FFh, 0FFh, 0Fh, 0F3h, 0Ch, 0CFh, 0C3h
                db 3Fh, 0C0h, 0, 0F3h, 0FBh, 0AAh, 0ABh, 0D1h, 7Fh, 0FDh
                db 5, 5Dh, 77h, 0FFh, 0F5h, 0EAh, 0ADh, 7Dh, 88h, 0E8h
                db 0AAh, 0ABh, 57h, 0AAh, 0B6h, 6, 0AAh, 4, 0B0h, 0CAh
                db 0C0h, 0F0h, 0Fh, 0FEh, 0EAh, 0Ah, 0AAh, 0B3h, 0, 0FCh
                db 0FAh, 0A8h, 0AAh, 0ACh, 0, 0Ch, 6, 0FFh, 4, 0Fh, 0F3h
                db 0Ch, 0CFh, 0CCh, 0FFh, 0C0h, 0, 0CFh, 0FFh, 0AAh, 0EAh
                db 41h, 0FFh, 0D0h, 5Fh, 75h, 5Fh, 0FFh, 0D7h, 0FAh, 0ADh
                db 0DDh, 8Bh, 28h, 0AAh, 0ADh, 57h, 0EAh, 0D7h, 6, 0AAh
                db 4, 0C3h, 0Ah, 0C3h, 0F0h, 3Fh, 0FFh, 0AEh, 8Ah, 0AAh
                db 0C0h, 0Fh, 0F3h, 0EEh, 88h, 0AAh, 0ACh, 0, 3Ch, 6, 0FFh
                db 4, 0Fh, 0F3h, 0Ch, 0FFh, 0C3h, 0FFh, 0C0h, 0, 0CFh
                db 0FEh, 0AAh, 0AAh, 57h, 0FFh, 55h, 7Dh, 0F7h, 7Fh, 0FFh
                db 0DFh, 0FFh, 0ADh, 35h, 30h, 0A8h, 8Ah, 0A9h, 5Dh, 0FBh
                db 57h, 0EAh, 0AAh, 0AAh, 0ABh, 0, 0F3h, 0, 0C0h, 3Fh
                db 0FBh, 0AEh, 0Ah, 0ABh, 0Ch, 0CFh, 33h, 0FEh, 80h, 0AAh
                db 0A0h, 0, 3Ch, 6, 0FFh, 4, 3Fh, 0C3h, 33h, 0CFh, 0C3h
                db 0FFh, 0C0h, 0, 0Fh, 0FEh, 0AAh, 0AAh, 75h, 0FFh, 55h
                db 0FDh, 0D7h, 7Fh, 0FFh, 0DFh, 0FFh, 0F7h, 7Dh, 0, 0B8h
                db 0Ah, 0AAh, 57h, 0FDh, 77h, 0FAh, 0A8h, 0AAh, 0ABh, 0
                db 0FCh, 0Fh, 0C3h, 3Fh, 0FBh, 0AEh, 82h, 0ABh, 30h, 3Ch
                db 0CFh, 0EEh, 82h, 2Ah, 0, 0, 0F0h, 0FFh, 0FFh, 0FFh
                db 0FCh, 0CFh, 0C3h, 33h, 0CFh, 0CFh, 0FFh, 0C0h, 0, 0F3h
                db 0FFh, 0AAh, 0BAh, 0D7h, 0FFh, 77h, 0F5h, 5Dh, 6, 0FFh
                db 4, 0C4h, 30h, 0C2h, 0B8h, 8, 88h, 0A9h, 0F5h, 5Fh, 0FFh
                db 0C0h, 0Ah, 0ABh, 3, 0FCh, 33h, 3, 3Fh, 0FBh, 0BEh, 88h
                db 0ACh, 0, 3Fh, 0FFh, 0BAh, 82h, 20h, 0, 0, 0F3h, 0FFh
                db 0FFh, 0FFh, 0FCh, 3Fh, 0C0h, 0F3h, 0CFh, 0F3h, 0FFh
                db 0C0h, 0, 33h, 0FFh, 0EAh, 0EAh, 1Fh, 0FFh, 0DFh, 0D7h
                db 75h, 6, 0FFh, 4, 0D0h, 30h, 4Bh, 0A8h, 20h, 0A2h, 2Ah
                db 0D5h, 7Fh, 0F0h, 0, 0, 3Ch, 0, 0F0h, 0CFh, 0Ch, 0FFh
                db 0FFh, 0AEh, 0A2h, 0ACh, 0C3h, 30h, 0FFh, 0BEh, 88h
                db 80h, 0, 0, 0CFh, 0FFh, 0FFh, 0FFh, 0F3h, 3Fh, 0C0h
                db 0F3h, 3Fh, 0CFh, 0FFh, 0C0h, 0, 33h, 0FEh, 0EBh, 0AEh
                db 3Fh, 0FFh, 0DFh, 55h, 57h, 6, 0FFh, 4, 0D0h, 0C1h, 0EBh
                db 0AAh, 8, 28h, 0AAh, 0A8h, 0B0h, 0, 0, 0, 3, 0Fh, 30h
                db 3Ch, 0Ch, 0FFh, 0EFh, 0BBh, 82h, 0AAh, 0, 0F3h, 0FEh
                db 0BAh, 80h, 80h, 0, 0, 0CFh, 0FFh, 0FFh, 0FFh, 0Ch, 0FFh
                db 0C0h, 0F3h, 3Fh, 0CFh, 0FFh, 0C0h, 0, 0F3h, 0FEh, 0EAh
                db 0AEh, 0FFh, 0FFh, 7Fh, 5Dh, 57h, 6, 0FFh, 4, 0C1h, 0C9h
                db 4Ah, 0AAh, 0Ah, 88h, 0, 80h, 6, 0, 4, 0Ch, 30h, 0FCh
                db 0FCh, 3Ch, 0FFh, 0FFh, 0BBh, 0A0h, 0AAh, 0Ch, 0C3h
                db 0EAh, 0FAh, 0A0h, 0, 0, 3, 0CFh, 0FFh, 0FFh, 0FCh, 0F3h
                db 0FFh, 33h, 33h, 3Fh, 0F3h, 0FFh, 30h, 0, 0F3h, 0FEh
                db 0EAh, 0AFh, 0Fh, 0FDh, 0FFh, 75h, 77h, 6, 0FFh, 4, 43h
                db 13h, 0Ah, 0AAh, 82h, 0A0h, 6, 0, 6, 30h, 0FCh, 0F3h
                db 0F0h, 3Ch, 0FFh, 0EEh, 0FAh, 0A8h, 2Ah, 83h, 0CFh, 0BAh
                db 0FAh, 0A2h, 0, 0, 30h, 0CFh, 0FFh, 0FFh, 0F3h, 0CFh
                db 0FFh, 30h, 0F3h, 3Fh, 0F3h, 0FFh, 0C0h, 0, 0FFh, 0FEh
                db 0EBh, 0AEh, 0CFh, 0FFh, 0FDh, 77h, 5Fh, 6, 0FFh, 4
                db 40h, 16h, 0CAh, 0EAh, 82h, 80h, 6, 0, 4, 0Ch, 0, 0F0h
                db 0CFh, 0C3h, 0C0h, 0F3h, 0FFh, 0BEh, 0BBh, 0E2h, 0Ah
                db 0B3h, 0FFh, 0AAh, 0EEh, 0A0h, 0, 0Ch, 3Ch, 3Fh, 0FFh
                db 0FFh, 0F3h, 0CFh, 0FFh, 30h, 33h, 3Fh, 0F3h, 0FFh, 0F0h
                db 0, 0F3h, 0FEh, 0EBh, 0AEh, 8Fh, 0FFh, 0F5h, 0DDh, 0DFh
                db 6, 0FFh, 4, 40h, 24h, 2Ah, 0AAh, 0A8h, 80h, 0, 0, 0
                db 0C0h, 0C0h, 3, 0F0h, 0CFh, 0Fh, 0C3h, 0F3h, 0FFh, 0BEh
                db 0BFh, 0E8h, 0Ah, 0AFh, 0FFh, 0ABh, 0EEh, 0A2h, 0, 30h
                db 0F0h, 3Fh, 0FFh, 0FFh, 0Fh, 3Fh, 0FFh, 0, 33h, 3Fh
                db 0F3h, 0FFh, 0F0h, 3, 0F3h, 0FEh, 0EBh, 0AAh, 0CFh, 0FFh
                db 0F5h, 7Fh, 0FFh, 0F5h, 77h, 0FFh, 0FDh, 4Fh, 8, 0ABh
                db 0AAh, 22h, 88h, 0, 0, 0Fh, 0, 30h, 3, 0, 0CFh, 0CFh
                db 0C3h, 0F3h, 0FFh, 0BAh, 0FBh, 0E8h, 82h, 0AFh, 0FFh
                db 0AFh, 0EEh, 88h, 0, 33h, 0C3h, 0Fh, 0FFh, 0FCh, 0F0h
                db 0FFh, 0FCh, 0C0h, 0FFh, 3Fh, 0FFh, 0FFh, 0F0h, 3, 0F3h
                db 0FEh, 0EAh, 0ABh, 83h, 0FFh, 0D7h, 0DFh, 7Fh, 57h, 0FFh
                db 0FFh, 0FDh, 0Fh, 33h, 0ABh, 0AAh, 0Ah, 0Ah, 80h, 0
                db 0ACh, 33h, 30h, 0Ch, 33h, 0Fh, 3Fh, 0C3h, 0CFh, 0FFh
                db 0FEh, 0BBh, 0FAh, 0, 0AAh, 0FEh, 0BFh, 0BEh, 0A0h, 0
                db 0F3h, 30h, 0CFh, 0FFh, 0C0h, 0CFh, 0FFh, 0FCh, 0C3h
                db 0CFh, 0CFh, 0F3h, 0FFh, 0F0h, 3, 0CFh, 0FEh, 0EAh, 0BAh
                db 83h, 0FFh, 0D7h, 0DFh, 0FDh, 0DDh, 0FFh, 0FFh, 0F5h
                db 0Ch, 3Ch, 0AEh, 0AAh, 0Ah, 0Bh, 0EAh, 82h, 0F0h, 30h
                db 0F0h, 3, 0Ch, 3Ch, 0FFh, 3, 0CFh, 0FEh, 0FAh, 0BFh
                db 0BAh, 0, 0AAh, 0FAh, 0EFh, 0EEh, 88h, 0, 0FFh, 0C3h
                db 0CFh, 0FFh, 0C3h, 3Fh, 0FFh, 0F3h, 0C3h, 0CFh, 0CFh
                db 0FCh, 0FFh, 0FCh, 3, 0CFh, 0FFh, 0EBh, 0EBh, 0C3h, 0FFh
                db 0DFh, 7Dh, 0FDh, 77h, 0FFh, 0FDh, 54h, 0, 32h, 0AEh
                db 8Ah, 0Ah, 8Bh, 0BAh, 0EBh, 0A3h, 0, 0C0h, 3Ch, 30h
                db 0FFh, 0FFh, 0Fh, 0CFh, 0FEh, 0FAh, 0EEh, 0AEh, 8, 28h
                db 0BEh, 0EFh, 0BFh, 0A8h, 0, 0FFh, 30h, 0Fh, 0FFh, 0Ch
                db 0FFh, 0FFh, 0F3h, 0C3h, 0CFh, 0CFh, 0FCh, 3Fh, 0FCh
                db 3, 0CFh, 0FFh, 0EEh, 0ABh, 0CFh, 0FFh, 7Dh, 0FFh, 0F5h
                db 0FFh, 0FFh, 0F4h, 54h, 30h, 0CAh, 0AAh, 8Ah, 0Ah, 0Bh
                db 0BCh, 0CEh, 0, 0C3h, 0CFh, 0F3h, 0Ch, 0FCh, 0FCh, 0Fh
                db 3Fh, 0FEh, 0EAh, 0EEh, 0EEh, 0Ah, 0ACh, 2Fh, 0ABh, 0FFh
                db 0A8h, 3, 0FFh, 33h, 0Fh, 0FFh, 0Ch, 0FFh, 0FFh, 0F3h
                db 0CFh, 0CFh, 0CFh, 0FCh, 3Fh, 0FCh, 3, 0CFh, 0FFh, 0BAh
                db 0EBh, 20h, 0FFh, 0FFh, 0FFh, 0F5h, 0FFh, 0FFh, 0F4h
                db 44h, 0C2h, 0AAh, 0AAh, 8Ah, 20h, 3, 0B0h, 0F0h, 0CCh
                db 0C0h, 0C3h, 0CCh, 0F0h, 0F3h, 0FCh, 3Fh, 0FFh, 0FEh
                db 0FAh, 0BEh, 0EEh, 88h, 0A0h, 2Ah, 0EFh, 0EFh, 0A0h
                db 3, 3Fh, 0Ch, 3Fh, 0FCh, 33h, 0FFh, 0FFh, 0F3h, 0C3h
                db 0CFh, 0CFh, 0FCh, 3Fh, 0FCh, 3, 0Fh, 0FFh, 0BAh, 0EBh
                db 0, 0FFh, 0FDh, 0FFh, 0F7h, 0FFh, 0FFh, 0D0h, 0D0h, 0C2h
                db 0AEh, 0BAh, 2Ah, 0Ah, 2, 30h, 0E2h, 0, 33h, 33h, 0F0h
                db 0F3h, 0FFh, 0F0h, 3Fh, 0FFh, 0FEh, 0EAh, 0AFh, 0EEh
                db 28h, 30h, 2Ah, 0BBh, 0EFh, 0A2h, 3, 3Ch, 0Ch, 0FFh
                db 0FCh, 0Ch, 0FFh, 0FFh, 0F3h, 33h, 0CFh, 0CFh, 0FCh
                db 0CFh, 0FCh, 3, 33h, 0FFh, 0BAh, 0ABh, 2, 0FFh, 0FFh
                db 0FFh, 0D7h, 0FFh, 0FFh, 0D3h, 0C3h, 0CEh, 0EAh, 0AAh
                db 2Ah, 20h, 22h, 3, 38h, 0E0h, 8, 0CFh, 30h, 0CFh, 0F3h
                db 0C0h, 0FFh, 0FFh, 0FBh, 0AAh, 0BBh, 0EAh, 2Bh, 0C0h
                db 0AAh, 0AFh, 0BAh, 0A2h, 0Ch, 0F0h, 0F0h, 3Fh, 0FFh
                db 0Ch, 0FFh, 0FFh, 0CFh, 0Fh, 0F3h, 0F3h, 0FCh, 3Fh, 0FCh
                db 3, 33h, 0FFh, 0FBh, 0AEh, 8, 0BFh, 0FFh, 0FFh, 7Fh
                db 0FFh, 0FFh, 43h, 0Fh, 3Ah, 0EBh, 0AAh, 28h, 0A0h, 0Ah
                db 0CBh, 0E0h, 0E0h, 0A3h, 3Ch, 0C3h, 3, 0FFh, 0C3h, 0EFh
                db 0FFh, 0FBh, 0AAh, 0AFh, 0BAh, 0, 0, 0BAh, 0ABh, 0EEh
                db 0BBh, 0Ch, 0F0h, 30h, 0CFh, 0FFh, 3Ch, 0FFh, 0FFh, 83h
                db 33h, 0F3h, 0F3h, 0FCh, 0FFh, 0FCh, 3, 33h, 0FFh, 0FAh
                db 0EEh, 0C0h, 0BFh, 6, 0FFh, 5, 43h, 30h, 0EAh, 0ABh
                db 0EAh, 28h, 88h, 2Ah, 8Bh, 0A3h, 0E2h, 0AFh, 3Ch, 0Ch
                db 0Fh, 0FFh, 0C3h, 0EFh, 0FFh, 0FBh, 0AEh, 0AFh, 0BAh
                db 0, 2, 0BAh, 0ABh, 0EBh, 0A8h, 33h, 0FCh, 0, 0CFh, 0F0h
                db 33h, 0FFh, 0FFh, 83h, 33h, 0F3h, 0F3h, 0FFh, 3, 0FFh
                db 0Ch, 0FFh, 0FFh, 0BAh, 0EEh, 8, 3Fh, 6, 0FFh, 4, 0FDh
                db 0Ch, 0, 2Bh, 0AFh, 0AAh, 0A8h, 0A2h, 0Bh, 0Bh, 0EFh
                db 0AAh, 83h, 0F3h, 0C3h, 3Fh, 0FFh, 3, 0BEh, 0FFh, 0AEh
                db 0AEh, 0EFh, 0BAh, 0, 3Eh, 0EAh, 0AAh, 0BBh, 0E8h, 8Fh
                db 0F3h, 0, 3Fh, 0FCh, 0F3h, 0FFh, 0FAh, 33h, 0Fh, 0F3h
                db 0F3h, 0FFh, 0FCh, 0FFh, 0Ch, 0F3h, 0FFh, 0BAh, 0AEh
                db 30h, 0Fh, 6, 0FFh, 4, 0FDh, 0, 0, 0CBh, 0AFh, 0A8h
                db 0A0h, 8Ah, 88h, 2Ch, 0EEh, 0AAh, 0Fh, 0C0h, 0CFh, 3Fh
                db 0FFh, 0Fh, 0ABh, 0FFh, 0AAh, 0AAh, 0BFh, 0ECh, 0, 0FEh
                db 0EAh, 0AAh, 0AAh, 0B0h, 0CFh, 0FFh, 3, 3Fh, 0F3h, 0F3h
                db 0FFh, 0EEh, 0Fh, 33h, 0FFh, 0FCh, 0FFh, 0F0h, 0FFh
                db 0Ch, 0F3h, 0FFh, 0FBh, 0AFh, 30h, 0Bh, 6, 0FFh, 4, 0F4h
                db 3, 0, 3Bh, 0AEh, 0A8h, 88h, 82h, 82h, 0AFh, 3Eh, 0A0h
                db 0Fh, 3, 0FCh, 3Fh, 0FCh, 0FFh, 0BAh, 0FEh, 0AAh, 0AEh
                db 0BEh, 0AAh, 0, 0FBh, 0AAh, 0ABh, 0AAh, 0ABh, 0FFh, 0FFh
                db 0Ch, 0FFh, 0F3h, 0FCh, 0FBh, 0B8h, 0CFh, 0Fh, 0FCh
                db 0FCh, 0FFh, 0F0h, 0FFh, 0Ch, 0F3h, 0FFh, 0BAh, 0EBh
                db 33h, 83h, 6, 0FFh, 4, 0F4h, 0, 0C0h, 0CAh, 0AAh, 0A2h
                db 8Ah, 82h, 0A0h, 0AFh, 0FAh, 0A0h, 0Fh, 33h, 3Ch, 0FFh
                db 0FFh, 0FEh, 0EFh, 0FEh, 0E9h, 52h, 0AAh, 80h, 0, 0FAh
                db 0AAh, 0AFh, 0E8h, 0AAh, 0AFh, 0FFh, 33h, 0Fh, 0FFh
                db 0FCh, 0EEh, 3, 3, 3Fh, 0FCh, 0FCh, 0FFh, 0FFh, 0FFh
                db 0Ch, 0F3h, 0FFh, 0BAh, 0AFh, 30h, 23h, 6, 0FFh, 4, 0D0h
                db 0, 3, 3Ah, 0AAh, 0A2h, 88h, 80h, 8Ah, 3Fh, 2Ah, 80h
                db 0CCh, 0FCh, 0F0h, 0FFh, 0FFh, 0FEh, 0EBh, 0FEh, 0E5h
                db 40h, 0, 3Ch, 3, 0FAh, 0EAh, 0AFh, 0A8h, 8Ah, 0ABh, 0FFh
                db 0C0h, 3, 0FFh, 0FBh, 0A8h, 30h, 33h, 0Fh, 0FCh, 0F8h
                db 0FFh, 0FCh, 0FFh, 3, 0F3h, 3Fh, 0BAh, 0BBh, 0C8h, 0C0h
                db 6, 0FFh, 4, 0DCh, 3, 3, 2Eh, 0AAh, 0AAh, 2Ah, 0, 3
                db 3Ch, 0EAh, 0, 30h, 0FFh, 0C3h, 0FFh, 0FFh, 0EAh, 0BFh
                db 0FEh, 0A4h, 40h, 0, 0FFh, 0Fh, 0EAh, 0AAh, 0AEh, 0BAh
                db 22h, 0AAh, 0BFh, 0FCh, 0CFh, 0FFh, 0EEh, 0A0h, 0CCh
                db 33h, 0Fh, 0FCh, 0F8h, 0FFh, 0FFh, 0FFh, 3, 0CFh, 0FFh
                db 0BAh, 0BBh, 0CAh, 38h, 3Fh, 0FFh, 0FFh, 0FFh, 0D3h
                db 0Ch, 0Ch, 0EEh, 0AAh, 0AAh, 0A8h, 3, 0Fh, 0Ch, 0A8h
                db 0, 0CCh, 0FFh, 3Fh, 0FFh, 0FFh, 0EBh, 0BFh, 0BEh, 94h
                db 0, 0Fh, 0FCh, 0FFh, 0EBh, 0AAh, 0BEh, 0EAh, 22h, 0AAh
                db 0ABh, 0FCh, 33h, 0Fh, 0AAh, 0Ch, 3, 0Fh, 0Fh, 0FFh
                db 38h, 0FFh, 0FFh, 0FFh, 3, 0CCh, 0FFh, 0BAh, 0FBh, 0F3h
                db 38h, 2Fh, 0FDh, 0FFh, 0F7h, 0DCh, 0Ch, 3, 0AAh, 0AAh
                db 0A8h, 0A0h, 30h, 3, 32h, 0A0h, 0Fh, 0F3h, 0FFh, 0Fh
                db 0FFh, 0FFh, 0EEh, 0BFh, 0BAh, 90h, 3, 0FFh, 0F0h, 0FFh
                db 0ABh, 0AAh, 0AAh, 0AAh, 28h, 2Ah, 0AAh, 0BBh, 0Ch, 0FEh
                db 0Ch, 0C3h, 0Ch, 0CFh, 3Fh, 0FFh, 3Ah, 3Fh, 0FFh, 0FCh
                db 0CFh, 0C3h, 0FFh, 0BBh, 0BBh, 0FCh, 8Eh, 0Ah, 86h, 83h
                db 1, 0D3h, 33h, 0Fh, 0AAh, 0AAh, 88h, 8Ah, 80h, 0Ch, 0Ah
                db 0A0h, 3Ch, 0CFh, 0FCh, 3Fh, 0FFh, 0FEh, 0BEh, 0BEh
                db 0BAh, 94h, 0Fh, 0FFh, 0C3h, 0FFh, 0AAh, 0AAh, 0BAh
                db 0EAh, 0Ah, 0, 0AAh, 0AEh, 0FFh, 0E8h, 0F0h, 0Fh, 0
                db 0CCh, 0CFh, 0FFh, 3Bh, 3Fh, 0FFh, 0BCh, 0Fh, 0C3h, 0FFh
                db 0FEh, 0FBh, 0FCh, 0A2h, 3, 0EBh, 0A2h, 85h, 8Ch, 0F0h
                db 0C2h, 0BAh, 0EAh, 82h, 28h, 0Ch, 3Ch, 0Ah, 80h, 0F0h
                db 33h, 0FCh, 3Fh, 0FFh, 0FEh, 0EAh, 0FEh, 0EAh, 55h, 0Fh
                db 0FFh, 33h, 0FEh, 0ABh, 2Ah, 0AEh, 0AAh, 0Ah, 80h, 0
                db 0ABh, 0BEh, 80h, 0F0h, 2Ch, 0CCh, 0CCh, 3Fh, 0FFh, 3Eh
                db 3Fh, 0FFh, 0B0h, 33h, 0CFh, 0FFh, 0EEh, 0ABh, 0FFh
                db 2Ch, 83h, 0, 0, 53h, 0CCh, 0F0h, 0CEh, 0EAh, 0EAh, 28h
                db 0A0h, 0, 3Fh, 2Ah, 0Ch, 0C3h, 33h, 0FCh, 0FFh, 0FFh
                db 0FAh, 0BBh, 0FAh, 0EAh, 55h, 3Fh, 0FFh, 3, 0FEh, 0A8h
                db 0Ah, 0BAh, 0A8h, 80h, 0AAh, 80h, 2Ah, 0A8h, 0Fh, 2
                db 8Ch, 3, 3Ch, 3Fh, 0FFh, 3Ah, 3Fh, 0FFh, 0BCh, 33h, 0C3h
                db 0FFh, 0EEh, 0EBh, 0FFh, 0CAh, 0E0h, 0D5h, 95h, 17h
                db 70h, 0F3h, 0CEh, 0EAh, 0AAh, 28h, 0A8h, 0Ch, 0CFh, 0EAh
                db 33h, 0CFh, 0CFh, 0F0h, 0FFh, 0FFh, 0FAh, 0FBh, 0FBh
                db 0A9h, 55h, 7Fh, 0FCh, 0Fh, 0FAh, 0A0h, 0Ah, 0AAh, 0EAh
                db 22h, 2, 0AAh, 8Ah, 0A0h, 3, 28h, 3Ch, 0CFh, 3Ch, 0FFh
                db 0FFh, 3Ah, 3Fh, 0FFh, 0B3h, 33h, 33h, 0FFh, 0EEh, 0EBh
                db 0AFh, 0F0h, 0B8h, 3, 5Fh, 17h, 73h, 0C3h, 0FEh, 0AAh
                db 0A8h, 0A0h, 0A8h, 0C0h, 0FFh, 0A8h, 30h, 0FCh, 3Fh
                db 30h, 0FFh, 0FFh, 0FBh, 0FAh, 0FBh, 0A9h, 5, 7Fh, 0FCh
                db 0Fh, 0FAh, 0A0h, 0F2h, 0ABh, 0EAh, 0A8h, 20h, 0Ah, 2Ah
                db 80h, 0Fh, 0A0h, 0F3h, 3, 0F3h, 0FFh, 0FFh, 3Eh, 3Fh
                db 0FFh, 0ECh, 0Fh, 0Fh, 0FFh, 0EEh, 0EBh, 0AAh, 0BFh
                db 0Ah, 20h, 4, 0DFh, 33h, 0C7h, 0CEh, 0AAh, 0E8h, 0A2h
                db 8Ah, 33h, 3Eh, 8Bh, 0C0h, 0F0h, 0FCh, 0, 0FFh, 0FFh
                db 0FBh, 0EAh, 0FBh, 0A5h, 10h, 0FFh, 0FFh, 3Fh, 0FEh
                db 80h, 0F8h, 0AAh, 0FAh, 0Ah, 0, 20h, 2Ah, 80h, 32h, 0E3h
                db 0E0h, 0CFh, 0F3h, 0FFh, 0FFh, 3Bh, 3Fh, 0FFh, 0BCh
                db 0Fh, 33h, 0FFh, 0EEh, 0EBh, 2Eh, 0AAh, 0E0h, 2Ch, 0Bh
                db 7Ch, 0C3h, 0C7h, 0C2h, 0AAh, 0B8h, 2, 0Bh, 0CFh, 0C2h
                db 2Fh, 33h, 0CFh, 0F3h, 3, 0FFh, 0FFh, 0EFh, 0AFh, 0FAh
                db 0A4h, 0, 0FFh, 0C0h, 0FCh, 0Ah, 3, 38h, 0AAh, 0AAh
                db 0A2h, 80h, 80h, 0AAh, 0, 0Fh, 0A3h, 0F3h, 3Fh, 33h
                db 0FFh, 0FFh, 3Ah, 3Fh, 0FEh, 0EFh, 0Fh, 0F3h, 0FFh, 0FAh
                db 0AAh, 8Ah, 0AAh, 0BAh, 80h, 0A8h, 4, 0CFh, 0CFh, 0C2h
                db 0ABh, 0A0h, 2Ah, 0Fh, 0FCh, 0AAh, 2Ch, 0F3h, 0CFh, 0CCh
                db 3, 0FFh, 0FFh, 0EEh, 0EBh, 0EAh, 0A4h, 10h, 0FFh, 33h
                db 3, 30h, 0Fh, 2Ah, 28h, 0FAh, 0A8h, 2Ah, 8Ah, 0AAh, 0
                db 0FEh, 83h, 0E8h, 3Fh, 0F3h, 0FFh, 0FFh, 3Ah, 3Fh, 0FFh
                db 0A3h, 3Fh, 0Fh, 0FFh, 0FAh, 0EBh, 80h, 0AAh, 0ABh, 0FBh
                db 0Ah, 53h, 3Fh, 1Fh, 0C0h, 0AAh, 82h, 80h, 3Fh, 3Ah
                db 2, 0ACh, 3Fh, 3Fh, 0CCh, 3Fh, 0FFh, 0FFh, 0AFh, 0AAh
                db 0EAh, 94h, 43h, 0FFh, 0C0h, 0F0h, 0C0h, 3Ch, 0FAh, 23h
                db 0FFh, 0AAh, 80h, 0Ah, 82h, 80h, 3Bh, 8Fh, 0A3h, 3Fh
                db 0CFh, 0FFh, 0FFh, 3Ah, 3Fh, 0FEh, 0E0h, 0CFh, 0Fh, 0FFh
                db 0EEh, 0EAh, 0A0h, 2Ah, 0AAh, 0AEh, 0F5h, 0Fh, 0FCh
                db 5Fh, 0CCh, 0BFh, 0AAh, 80h, 0FCh, 0F8h, 2Bh, 30h, 0FFh
                db 0FFh, 30h, 3Fh, 0FFh, 0FFh, 0EEh, 0AEh, 0EEh, 90h, 43h
                db 0FCh, 0Fh, 33h, 3Fh, 0C3h, 0A2h, 0CFh, 0FFh, 0FEh, 0AAh
                db 0Ah, 2Ah, 0, 0CEh, 32h, 0E0h, 0FFh, 0CFh, 0FFh, 0FFh
                db 2Eh, 3Fh, 0FEh, 0A0h, 3Fh, 0Fh, 0FFh, 0EEh, 0ABh, 0AAh
                db 2, 0AAh, 0AAh, 0A4h, 10h, 0F9h, 0BFh, 3Eh, 0BAh, 0
                db 3Fh, 0EEh, 1, 60h, 23h, 0FFh, 0FFh, 0F2h, 0FEh, 0EFh
                db 0FEh, 0AEh, 0BBh, 0EEh, 88h, 33h, 0B8h, 22h, 8, 8Ah
                db 0Bh, 0A2h, 8Bh, 0EEh, 0FEh, 0EAh, 8Ah, 2Ah, 8, 0FEh
                db 3Fh, 88h, 0EEh, 0BFh, 0FFh, 0FFh, 2Ah, 8Fh, 0FEh, 0EBh
                db 3Bh, 0Fh, 0EEh, 0FAh, 0EBh, 0A8h, 0A0h, 2, 0AAh, 91h
                db 7, 0E2h, 7Bh, 3Ah, 0AEh, 0, 0BFh, 0E8h, 81h, 63h, 0CBh
                db 0FCh, 0FFh, 0C3h, 0BAh, 0BFh, 0FBh, 0AAh, 0ABh, 0BAh
                db 80h, 3Eh, 0E2h, 80h, 0A2h, 3Ah, 23h, 0A8h, 0A3h, 0BBh
                db 0FBh, 0AAh, 0AAh, 0A8h, 2, 0CFh, 0BEh, 83h, 0FBh, 0BEh
                db 0FBh, 0FFh, 3Bh, 8Fh, 0FAh, 0E3h, 3Ah, 2Fh, 0BAh, 0FEh
                db 0AAh, 0AAh, 8, 0, 2, 50h, 5Fh, 0A1h, 0FEh, 3Eh, 0BAh
                db 33h, 0EEh, 0A0h, 9, 88h, 0CCh, 0E8h, 0FFh, 8Eh, 0FAh
                db 0BFh, 0FBh, 0AEh, 0BBh, 0EEh, 83h, 3Bh, 0A2h, 82h, 0
                db 0E8h, 0Eh, 0A8h, 0BAh, 0BEh, 0BEh, 0FFh, 0AAh, 0A8h
                db 0, 0FBh, 3Bh, 0AEh, 0EEh, 0BBh, 0BFh, 0FFh, 2Eh, 8Fh
                db 0BBh, 8Ch, 0EEh, 8Fh, 0BAh, 0FAh, 0EAh, 0AAh, 0A0h
                db 0Ah, 0A5h, 1, 0FBh, 97h, 0EAh, 0BAh, 0B8h, 0Ch, 0FAh
                db 0A0h, 26h, 83h, 88h, 0EAh, 0FEh, 3, 0AAh, 0BFh, 0AEh
                db 0BAh, 0ABh, 0EEh, 8, 0EBh, 0A2h, 8Ah, 3, 0F8h, 2, 0A2h
                db 2Fh, 0BBh, 0FAh, 0BFh, 0FBh, 0A8h, 22h, 0FAh, 0FEh
                db 8Fh, 0FAh, 0BFh, 0BEh, 0FFh, 3Fh, 8Fh, 0BBh, 83h, 0FEh
                db 0Bh, 0BAh, 0EAh, 0BEh, 0AAh, 0AAh, 0A0h, 10h, 1Fh, 0EAh
                db 5Fh, 0A8h, 0EAh, 0A8h, 3Bh, 0AAh, 83h, 26h, 83h, 82h
                db 0EAh, 0FEh, 8Eh, 0AEh, 0BFh, 0AEh, 0AAh, 0AEh, 0FAh
                db 23h, 3Eh, 8Ah, 88h, 0Fh, 0B8h, 8Ch, 0A8h, 8Bh, 0AAh
                db 0ABh, 0EEh, 0BEh, 80h, 80h, 0BBh, 0EEh, 0AEh, 0EAh
                db 0EBh, 0AEh, 0EFh, 2Eh, 0CEh, 0EAh, 83h, 0FEh, 0Eh, 0BAh
                db 0ABh, 0EEh, 0AAh, 0AAh, 0AAh, 41h, 0EFh, 0A9h, 0BAh
                db 0AAh, 0EAh, 0A8h, 0Eh, 0AAh, 80h, 0E6h, 2Eh, 83h, 0E2h
                db 0EEh, 2Eh, 0AAh, 0FBh, 0BAh, 0BAh, 0AFh, 0BAh, 8, 0FAh
                db 2Ah, 0A8h, 2Ah, 0E8h, 0Ah, 0A8h, 0A0h, 0BEh, 0AAh, 0AAh
                db 0A2h, 20h, 20h, 0EEh, 3Eh, 8Fh, 0AFh, 0ABh, 0BAh, 0FAh
                db 2Bh, 0CEh, 0EAh, 8Eh, 0EEh, 3Eh, 0AAh, 0EAh, 0EFh, 0AAh
                db 0AAh, 0AAh, 1Fh, 0BAh, 0A6h, 0AAh, 0A7h, 0AAh, 0A8h
                db 8Bh, 0AAh, 3, 0BAh, 8Eh, 23h, 0AAh, 0BAh, 3Ah, 0BAh
                db 0EEh, 0AAh, 0EEh, 0AAh, 0BAh, 8, 0EAh, 8Ah, 8Ah, 0Ah
                db 0E8h, 0Eh, 0A8h, 2Ah, 20h, 0Fh, 0BAh, 0, 0, 8Bh, 0A8h
                db 0FAh, 0BBh, 0BAh, 0AEh, 0AAh, 0E8h, 0ABh, 8Fh, 0EAh
                db 32h, 0FAh, 3Bh, 0BAh, 0AFh, 0BAh, 0AAh, 0AAh, 0A9h
                db 7Fh, 0EAh, 6, 0AAh, 4, 0A3h, 3Eh, 0A8h, 33h, 0EAh, 3Eh
                db 0Fh, 0ABh, 0E8h, 0EAh, 0EBh, 0EEh, 0ABh, 0FAh, 0AEh
                db 0E8h, 82h, 0BAh, 2Ah, 0A8h, 0Ah, 0A0h, 0Ah, 0AAh, 0Ah
                db 0AAh, 2Ah, 0A0h, 0, 0A0h, 3Eh, 0A3h, 0EAh, 0AEh, 0EAh
                db 0AAh, 0ABh, 0B8h, 0AEh, 0CFh, 0EAh, 0Eh, 0EEh, 0BEh
                db 0BAh, 0ABh, 0BAh, 0AAh, 0AAh, 85h, 0FBh, 0AAh, 0EAh
                db 0AAh, 0BAh, 0AAh, 3, 0EAh, 0A8h, 0Eh, 0AAh, 3Ah, 3Bh
                db 0AEh, 0A0h, 0FAh, 0EAh, 0AAh, 0ABh, 0EAh, 0BAh, 0A8h
                db 23h, 0EAh, 2Ah, 0A2h, 0Eh, 0A8h, 0Eh, 0AAh, 0A2h, 0A0h
                db 80h, 0, 20h, 0AFh, 0EAh, 0A3h, 0AAh, 0BAh, 0EAh, 0AAh
                db 0AAh, 0AAh, 0ABh, 8Eh, 0AEh, 0Eh, 0FAh, 0FAh, 0AAh
                db 0AEh, 0EAh, 0AAh, 0A9h, 7Eh, 0FEh, 0AFh, 0AAh, 0AAh
                db 0BAh, 0A8h, 3Eh, 0AEh, 0A0h, 3Eh, 0AAh, 0EAh, 0EBh
                db 0AEh, 0A0h, 0EAh, 0ABh, 0AAh, 0ABh, 0AAh, 0BAh, 0E2h
                db 2Eh, 0B8h, 0AAh, 0A8h, 0AEh, 0A2h, 3Ah, 0AAh, 0AAh
                db 8, 0, 20h, 8Fh, 0BAh, 0AAh, 8Ah, 0AAh, 0BBh, 0AAh, 0AAh
                db 0AAh, 0A2h, 0ABh, 2Fh, 0AEh, 0Bh, 0AAh, 0EAh, 0EAh
                db 0AEh, 0EAh, 0AAh, 0A7h, 0EBh, 0AAh, 0BAh, 0AAh, 0AAh
                db 0BAh, 0A8h, 3Ah, 0BAh, 80h, 0FAh, 0A8h, 0AAh, 0EAh
                db 0AEh, 83h, 0FAh, 0AAh, 0AAh, 0AEh, 0AAh, 0EBh, 0A0h
                db 0AEh, 0E8h, 0AAh, 0A2h, 2Ah, 0A0h, 3Ah, 0AAh, 0A0h
                db 20h, 0, 8Fh, 0AAh, 0AAh, 0AAh, 0AFh, 0AAh, 0BBh, 0AAh
                db 0AAh, 0BAh, 0AAh, 0ABh, 3Bh, 0AEh, 3Fh, 0BAh, 0BAh
                db 0EAh, 0BAh, 0EAh, 0AAh, 7Eh, 0AAh, 0AAh, 0BAh, 0AAh
                db 0EAh, 0EAh, 0AAh, 0EBh, 0EAh, 8Fh, 0BAh, 0AAh, 0AAh
                db 0ABh, 0EEh, 8Ch, 0EAh, 0AEh, 6, 0AAh, 4, 0A0h, 0AFh
                db 0AAh, 0AAh, 0A8h, 2Ah, 0A2h, 0AAh, 0AAh, 22h, 0A3h
                db 33h, 0EAh, 0AAh, 0AAh, 0A8h, 0BAh, 0AAh, 0BBh, 0AAh
                db 0AAh, 0FAh, 0A2h, 0AEh, 0FBh, 0AAh, 0Fh, 0EAh, 0EAh
                db 0EFh, 0EAh, 0EAh, 0AAh, 0EEh, 0AAh, 0AAh, 0EAh, 0ABh
                db 0AAh, 0EAh, 0A8h, 0BEh, 0AAh, 3Eh, 0EAh, 0AAh, 0AAh
                db 0EBh, 0EAh, 0A3h, 6, 0AAh, 5, 0EBh, 82h, 0BBh, 6, 0AAh
                db 4, 8Bh, 0AAh, 0AAh, 0AAh, 0A0h, 0CAh, 6, 0AAh, 4, 0EAh
                db 0AAh, 0AEh, 0AAh, 0ABh, 0BAh, 0AAh, 0A8h, 0FAh, 0A8h
                db 8Bh, 0AAh, 0EAh, 0BAh, 0ABh, 0BAh, 0A7h, 6, 0AAh, 4
                db 0A7h, 0ABh, 0AAh, 0ABh, 0EEh, 0AAh, 3Ah, 0AAh, 0AAh
                db 0ABh, 0ABh, 0AEh, 8Eh, 0EAh, 0BAh, 0AAh, 0AAh, 0ABh
                db 0AAh, 80h, 0BEh, 6, 0AAh, 4, 0A3h, 0AAh, 0AAh, 0AAh
                db 8Fh, 6, 0AAh, 4, 0BAh, 0AAh, 0AAh, 0AEh, 0AAh, 0AEh
                db 0EAh, 0A2h, 0A8h, 0EAh, 0E8h, 2Bh, 0EAh, 0EBh, 0AAh
                db 0ABh, 0AAh, 0BAh, 6, 0AAh, 4, 9Fh, 0AAh, 0AAh, 0ABh
                db 0BAh, 0A8h, 0EEh, 0AAh, 0AAh, 0AAh, 0AFh, 0AAh, 8Fh
                db 0AAh, 0BAh, 0AAh, 0AAh, 0ABh, 0AEh, 88h, 0BAh, 0AAh
                db 0AAh, 0A2h, 0AAh, 0ABh, 0AAh, 0AAh, 0AAh, 0AEh, 0EAh
                db 6, 0AAh, 8, 0FFh, 0AAh, 8Ah, 0A2h, 0EBh, 0A8h, 2Bh
                db 0AAh, 0EAh, 0AAh, 0AEh, 0EAh, 0EAh, 0AAh, 0AAh, 0AAh
                db 0A5h, 7Eh, 0AAh, 0AAh, 0ABh, 0BAh, 0A8h, 0EAh, 0AAh
                db 0AAh, 0AAh, 0BEh, 0AAh, 0AFh, 0AAh, 0EAh, 0AAh, 0AAh
                db 0AAh, 0AEh, 22h, 0BAh, 6, 0AAh, 8, 8Fh, 6, 0AAh, 8
                db 0ABh, 0FAh, 0AAh, 0AAh, 0ABh, 0ABh, 0A8h, 2Bh, 0AAh
                db 0AAh, 0AAh, 0FFh, 6, 0AAh, 5, 9Fh, 0EAh, 0AAh, 0AAh
                db 0ABh, 0AAh, 0A8h, 0AAh, 0AAh, 0AAh, 0ABh, 0EAh, 6, 0AAh
                db 7, 0BAh, 0Ah, 0EAh, 6, 0AAh, 7, 0A8h, 3Ah, 6, 0AAh
                db 0Ch, 0Ah, 0AEh, 0AAh, 0AEh, 0AAh, 0EAh, 0ABh, 0BAh
                db 6, 0AAh, 5, 7Ah, 0AAh, 0AAh, 0AAh, 0AEh, 6, 0AAh, 8
                db 0AEh, 6, 0AAh, 5, 0BAh, 8Ah, 6, 0AAh, 8, 82h, 0EEh
                db 6, 0AAh, 0Dh, 0AEh, 0A8h, 0AAh, 0AAh, 0AAh, 0AEh, 6
                db 0AAh, 1Ah, 2Ah, 6, 0AAh, 7, 0A8h, 6, 0AAh, 14h, 0AEh
                db 0AAh, 0AAh
ground          db 7Dh, 17h, 0DDh, 47h, 55h, 35h, 54h, 7Dh, 1Fh, 45h, 0F5h ; ...
                db 0F4h, 7Dh, 51h, 0DFh, 0D5h, 54h, 1Dh, 54h, 53h, 0CFh
                db 4Fh, 74h, 0F7h, 37h, 0DFh, 4Fh, 4Fh, 7Dh, 17h, 0DDh
                db 47h, 55h, 35h, 54h, 7Dh, 1Fh, 45h, 0F5h, 0F4h, 7Dh
                db 51h, 0DFh, 0D5h, 54h, 1Dh, 54h, 53h, 0CFh, 4Fh, 74h
                db 0F7h, 37h, 0DFh, 4Fh, 4Fh, 15h, 4Dh, 55h, 1Dh, 55h
                db 43h, 41h, 0D5h, 45h, 44h, 1, 51h, 0D5h, 0D1h, 0D5h
                db 40h, 1, 0F5h, 55h, 0Dh, 45h, 4Dh, 53h, 55h, 35h, 55h
                db 35h, 34h, 15h, 4Dh, 55h, 1Dh, 55h, 43h, 41h, 0D5h, 45h
                db 44h, 1, 51h, 0D5h, 0D1h, 0D5h, 40h, 1, 0F5h, 55h, 0Dh
                db 45h, 4Dh, 53h, 55h, 35h, 55h, 35h, 34h, 5, 4Dh, 54h
                db 0, 5, 54h, 1Ch, 55h, 45h, 63h, 1, 54h, 55h, 3Dh, 0F4h
                db 55h, 55h, 35h, 1, 4Dh, 51h, 55h, 4Dh, 40h, 5, 10h, 85h
                db 4Dh, 54h, 0, 5, 54h, 1Ch, 55h, 45h, 1, 0F4h, 0, 1, 54h
                db 55h, 3Dh, 0F4h, 55h, 55h, 35h, 11h, 4Dh, 51h, 55h, 4Dh
                db 40h, 5, 11h, 65h, 5, 35h, 15h, 67h, 1, 54h, 55h, 40h
                db 50h, 0, 35h, 54h, 0D5h, 50h, 63h, 0E0h, 62h, 0FFh, 0A0h
                db 5, 35h, 15h, 0, 0BEh, 0EBh, 0EFh, 0B8h, 62h, 1, 54h
                db 55h, 40h, 50h, 0E8h, 35h, 54h, 0D5h, 50h, 3Fh, 0A0h
                db 3, 66h, 75h, 14h, 69h, 5, 3Dh, 63h, 54h, 50h, 64h, 57h
                db 7Dh, 7Fh, 0D5h, 5Dh, 0F0h, 75h, 14h, 1Fh, 55h, 0D5h
                db 0D5h, 55h, 0F5h, 0FDh, 0FCh, 0, 5, 3Dh, 7, 5Dh, 40h
                db 54h, 50h, 7, 0F5h, 0D5h, 0FDh, 66h, 15h, 40h, 68h, 6Ch
                db 0AEh, 0AAh, 0ABh, 0AAh, 0AAh, 0AEh, 15h, 43h, 0BAh
                db 0BAh, 0ABh, 0AAh, 0EAh, 0BAh, 0AAh, 0ABh, 0FEh, 0E0h
                db 0, 0FAh, 0EEh, 0AAh, 0, 0Fh, 0BAh, 0EAh, 0EBh, 0AAh
                db 6Eh, 6Eh, 55h, 55h, 57h, 55h, 55h, 55h, 40h, 1Dh, 75h
                db 55h, 55h, 55h, 55h, 75h, 55h, 0D5h, 0DDh, 5Dh, 0FDh
                db 55h, 0DDh, 55h, 75h, 5Dh, 75h, 0D5h, 57h, 55h, 6Eh
                db 6Eh, 0AEh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
                db 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0ABh, 0AAh
                db 0AAh, 0EAh, 0ABh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
                db 0AAh, 0AAh
ground1         db 69h, 0Ch, 6Fh, 63h, 55h, 55h, 55h, 55h, 55h, 55h, 55h ; ...
                db 55h, 55h, 5Dh, 45h, 55h, 55h, 5Dh, 75h, 55h, 55h, 55h
                db 55h, 55h, 55h, 55h, 55h, 55h, 55h, 55h, 55h, 55h, 69h
                db 30h, 64h, 0Fh, 0, 0Ch, 65h, 0C0h, 65h, 0AEh, 0AAh, 0BAh
                db 0BAh, 0AAh, 0AAh, 0AAh, 0BAh, 0BAh, 80h, 2Bh, 0AAh
                db 0AEh, 0AAh, 0AFh, 0AAh, 0AEh, 0AAh, 0AAh, 0ABh, 0AAh
                db 0AAh, 0EBh, 0AAh, 0EAh, 0EAh, 0AAh, 0AAh, 69h, 0C0h
                db 62h, 0Ch, 0C0h, 0F0h, 0, 0FCh, 30h, 63h, 0Fh, 66h, 55h
                db 55h, 0D5h, 55h, 57h, 55h, 0D5h, 75h, 55h, 5, 57h, 55h
                db 5Dh, 0D5h, 0F0h, 75h, 0CDh, 75h, 75h, 57h, 55h, 5Fh
                db 1Dh, 55h, 55h, 55h, 75h, 5Dh, 63h, 10h, 64h, 3, 30h
                db 0F0h, 3, 0CFh, 3, 0CCh, 0Fh, 0F3h, 63h, 0Fh, 50h, 0
                db 30h, 62h, 3, 0, 0AAh, 0AEh, 0AAh, 9Ah, 0EAh, 0ABh, 0AAh
                db 0EAh, 0ABh, 3Ah, 0F2h, 0A8h, 0E3h, 2Bh, 0Eh, 0ACh, 0F3h
                db 0AAh, 0AAh, 0AAh, 0A3h, 58h, 82h, 0BAh, 0ABh, 0AAh
                db 0ABh, 2Ah, 63h, 0C0h, 64h, 3Fh, 0Fh, 0, 0FCh, 30h, 0CFh
                db 30h, 0FDh, 0C1h, 0CCh, 0, 3Dh, 70h, 0Fh, 3, 0C0h, 62h
                db 0F0h, 3Ch, 55h, 55h, 0D5h, 55h, 0D5h, 55h, 55h, 55h
                db 73h, 13h, 5, 0CCh, 70h, 0D3h, 31h, 0C1h, 0C5h, 0DDh
                db 5Dh, 4Dh, 70h, 13h, 54h, 0C5h, 55h, 55h, 0F1h, 7Dh
                db 33h, 0, 3, 40h, 63h, 3, 0F5h, 0F7h, 0C0h, 3, 0D3h, 3Dh
                db 3Fh, 0FFh, 0C4h, 0Fh, 1, 0C0h, 0Fh, 0FFh, 0CCh, 3, 30h
                db 0Ch, 3, 0C0h, 0A0h, 2Eh, 0A9h, 4Ah, 0ABh, 0AAh, 0AAh
                db 0EBh, 35h, 0F7h, 0EAh, 0Bh, 0D3h, 0BDh, 0Fh, 0FFh, 0C4h
                db 2Fh, 29h, 0C0h, 8Fh, 0Fh, 0ECh, 28h, 32h, 0ACh, 0ABh
                db 0C2h, 0FCh, 0, 3, 10h, 62h, 0Ch, 3Bh, 5Fh, 5Fh, 0FDh
                db 0B0h, 0CCh, 0DFh, 77h, 5Fh, 7Fh, 31h, 34h, 3Fh, 0FDh
                db 0F5h, 30h, 3Dh, 3, 0C0h, 0FCh, 3Fh, 9Ch, 55h, 57h, 15h
                db 0D5h, 55h, 5Dh, 7Bh, 5Ch, 5Fh, 0F1h, 0B1h, 0CCh, 1Ch
                db 77h, 5Fh, 70h, 31h, 75h, 70h, 0FDh, 0F5h, 31h, 71h
                db 14h, 0C1h, 3Ch, 43h, 0FFh, 0A4h, 0Dh, 22h, 0, 45h, 0BFh
                db 0D5h, 7Dh, 0FDh, 5Fh, 5Fh, 5Fh, 55h, 0DDh, 7Dh, 7Fh
                db 0FFh, 0D7h, 0FFh, 5Fh, 57h, 0FDh, 77h, 7Ch, 3Dh, 5Fh
                db 75h, 0FFh, 0A4h, 0ADh, 2Ah, 0AAh, 0EFh, 0BFh, 0D5h
                db 71h, 0FDh, 5Fh, 5Fh, 5Fh, 55h, 0DDh, 7Dh, 7Fh, 0FFh
                db 0D7h, 0FFh, 5Fh, 57h, 0CDh, 77h, 7Eh, 0B1h, 5Fh, 75h
ympd          ends


                end     start
