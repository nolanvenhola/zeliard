include common.inc
                .286
                .model small

gmmcga          segment byte public 'CODE'
                assume cs:gmmcga
                org 2000h
                assume es:nothing, ss:nothing, ds:gmmcga
start:                
                dw offset Draw_Bordered_Rectangle
                dw offset Clear_Viewport
                dw offset Clear_HUD_Bar
                dw offset Draw_Hero_Max_Health
                dw offset Draw_Hero_Health
                dw offset Draw_Boss_Max_Health ; bx: boss maxHP
                dw offset Draw_Boss_Health ; bx: boss health
                dw offset Render_Pascal_String_0 ; [si]: left margin; [si+1]: top margin
                dw offset Render_Pascal_String_1 ; [si]: left margin; [si+1]: top margin
                dw offset Clear_Place_Enemy_Bar
                dw offset Print_Almas_Decimal
                dw offset Print_Gold_Decimal
                dw offset Print_Magic_Left_Decimal
                dw offset Print_ShieldHP_Decimal
                dw offset Render_Sword_Item_Sprite_20x18
                dw offset Render_Magic_Spell_Item_Sprite_16x16
                dw offset Render_Shield_Item_Sprite_16x16
                dw offset Render_Font_Glyph ; AL: ASCII character code
                                        ; AH: Palette/colour index
                                        ; BX: X pixel coordinate in framebuffer
                                        ; CX: Y pixel coordinate (row)
                                        ; CS:0xFF77: Flag: 0 = normal colour mode, nonzero = "bright/highlight" mode
                dw offset Scroll_Screen_Rect_Down
                dw offset Capture_Screen_Rect_to_seg3 ; AH: x in tiles
                                        ; AL: y in pixels
                                        ; CL: height of the rectangle in pixels
                                        ; CH: width of the rectangle in tiles
                                        ; DI: destination Offset in seg3
                dw offset Put_Image     ; AH: x in tiles
                                        ; AL: y in pixels
                                        ; CL: height of the rectangle in pixels
                                        ; CH: width of the rectangle in tiles
                                        ; DI: source Offset in seg3
                dw offset Render_String_FF_Terminated ; BX: starting x coord
                                        ; CL: starting y coord
                                        ; SI: string pointer
                dw offset Copy_Screen_Rect_VRAM
                dw offset Draw_Status_Frame
                dw offset Render_Decimal_Digits ; al: marginTop
                                        ; ah: marginLeft4
                dw offset Convert_32bit_To_Decimal_Digits
                dw offset Render_Wearable_Item_Sprite_16x16
                dw offset Render_Magic_Potion_Item_Sprite_16x16
                dw offset Render_C_String ; bh: left margin; bl: top margin
                dw offset Render_Key_Item_Sprite_16x16
                dw offset Render_Crest_Item_Sprite_16x16
                dw offset Render_Tear_Icon
                dw offset Fade_To_Black_Dithered
                dw offset Clear_Screen
                dw offset Reassemble_3_Planes_To_Packed_Bitmap ; si: src
                                        ; cx: number of 48-byte elements to reassemble

; =============== S U B R O U T I N E =======================================


; Draws a bordered rectangle or fills with black
; BH: left margin
; BL: top margin
; CL: height (rows)
; CH: width (words × 2 = pixels)
; AL: 0 = fill black, non-zero = draw border

Draw_Bordered_Rectangle proc near
                push    ax
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, ax
                pop     ax
                or      al, al
                jnz     short loc_2062
                jmp     clear_rectangular_region ; Input:
                                        ; DI = start offset in framebuffer,
                                        ; cl=row count,
                                        ; ch=width-in-words (×2 = pixels, so width must be even).
                                        ; Fills cl rows × ch*2 pixels with black (0)
; ---------------------------------------------------------------------------

loc_2062:                               ; ...
                mov     dx, 909h
                test    byte ptr cs:font_highlight_flag, 0FFh
                jz      short loc_2070
                mov     dx, 0FFFFh

loc_2070:                               ; ...
                push    di
                sub     cl, 4
                add     di, 280h
                call    clear_rectangular_region ; Input:
                                        ; DI = start offset in framebuffer,
                                        ; cl=row count,
                                        ; ch=width-in-words (×2 = pixels, so width must be even).
                                        ; Fills cl rows × ch*2 pixels with black (0)
                pop     di
                xor     ax, ax
                xor     bx, bx
                call    draw_one_scanline_of_bordered_horiz_bar
                mov     ax, 0FF00h
                mov     bx, 0FFh
                call    draw_one_scanline_of_bordered_horiz_bar
                push    cx
                push    bx
                mov     bl, ch
                dec     bl
                add     bx, bx
                add     bx, bx
                xor     bh, bh
                xor     ch, ch

loc_209A:                               ; ...
                mov     es:[di], dx
                mov     es:[bx+di+2], dx
                add     di, 140h
                loop    loc_209A
                pop     bx
                pop     cx
                mov     ax, 0FF00h
                mov     bx, 0FFh
                call    draw_one_scanline_of_bordered_horiz_bar
                xor     ax, ax
                xor     bx, bx
Draw_Bordered_Rectangle endp


; =============== S U B R O U T I N E =======================================


draw_one_scanline_of_bordered_horiz_bar proc near ; ...
                push    di
                push    cx
                not     ax
                and     es:[di], ax
                not     ax
                and     ax, dx
                or      es:[di], ax
                inc     di
                inc     di
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                sub     cx, 4
                mov     al, dl
                rep stosb
                not     bx
                and     es:[di], bx
                not     bx
                and     bx, dx
                or      es:[di], bx
                pop     cx
                pop     di
                add     di, 140h
                retn
draw_one_scanline_of_bordered_horiz_bar endp


; =============== S U B R O U T I N E =======================================

; Input:
; DI = start offset in framebuffer,
; cl=row count,
; ch=width-in-words (×2 = pixels, so width must be even).
; Fills cl rows × ch*2 pixels with black (0)

clear_rectangular_region proc near      ; ...
                mov     ax, 0A000h
                mov     es, ax
                push    cx
                xor     ax, ax

loc_20F0:                               ; ...
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                rep stosw
                pop     cx
                pop     di
                add     di, 140h
                dec     cl
                jnz     short loc_20F0
                pop     cx
                retn
clear_rectangular_region endp


; =============== S U B R O U T I N E =======================================


; Clears the viewport area (224x144, 28x18 tiles) to black
; No parameters

Clear_Viewport  proc near
                mov     ax, 0A000h
                mov     es, ax
                mov     di, viewport_top_left_vram_addr
                mov     cx, 8

loc_2111:                               ; ...
                push    cx
                push    di
                mov     cx, 12h

loc_2116:                               ; ...
                push    cx
                push    di
                mov     cx, 0E0h
                xor     al, al
                rep stosb
                pop     di
                add     di, 0A00h
                pop     cx
                loop    loc_2116
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_2111
                retn
Clear_Viewport  endp


; =============== S U B R O U T I N E =======================================


; Fades the viewport to black using a dithered pattern
; No parameters

Fade_To_Black_Dithered proc near
                mov     ax, 0A000h
                mov     es, ax
                mov     si, 218Dh
                mov     cx, 8

loc_213B:                               ; ...
                push    cx
                mov     di, viewport_top_left_vram_addr
                lodsb
                push    di
                mov     cx, 48h ; 'H'

loc_2144:                               ; ...
                push    cx
                mov     cx, 0E0h

loc_2148:                               ; ...
                rol     al, 1
                jnb     short loc_2150
                mov     byte ptr es:[di], 0

loc_2150:                               ; ...
                inc     di
                loop    loc_2148
                ror     al, 1
                ror     al, 1
                ror     al, 1
                pop     cx
                add     di, 1A0h
                loop    loc_2144
                pop     di
                add     di, 140h
                mov     cx, 48h ; 'H'

loc_2168:                               ; ...
                push    cx
                mov     cx, 0E0h

loc_216C:                               ; ...
                ror     al, 1
                jnb     short loc_2174
                mov     byte ptr es:[di], 0

loc_2174:                               ; ...
                inc     di
                loop    loc_216C
                rol     al, 1
                rol     al, 1
                rol     al, 1
                pop     cx
                add     di, 1A0h
                loop    loc_2168
                mov     cx, 1F40h

loc_2187:                               ; ...
                loop    loc_2187
                pop     cx
                loop    loc_213B
                retn
fade_to_black_dithered endp

; ---------------------------------------------------------------------------
                db 1, 3, 7, 0Fh, 1Fh, 3Fh, 7Fh, 0FFh

; =============== S U B R O U T I N E =======================================

; bh: paddingLeft
; bl: paddingTop
; al: masking mode

Clear_HUD_Bar   proc near               ; ...
                mov     cs:masking_mode, al
                mov     ax, 0A000h
                mov     es, ax
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                add     bx, 9Eh
                mov     ax, 140h
                mul     bx
                pop     bx
                add     ax, bx
                add     ax, 30h ; '0'
                mov     di, ax
                push    cx
                xor     ax, ax
                call    draw_HUD_column_width_1
                pop     cx
                inc     di
                mov     cl, ch

loc_21C0:                               ; ...
                push    cx
                mov     ax, 0FFFFh
                call    draw_HUD_column_width_1
                pop     cx
                inc     di
                dec     cl
                jnz     short loc_21C0
                retn
Clear_HUD_Bar   endp


; =============== S U B R O U T I N E =======================================


draw_HUD_column_width_1 proc near       ; ...
                test    cs:masking_mode, 0FFh
                jnz     short loc_21F5
                push    di
                and     ah, 5
                and     al, 2Dh
                mov     byte ptr es:[di], 0
                add     di, 140h
                mov     cx, 8

loc_21E7:                               ; ...
                mov     es:[di], ah
                add     di, 140h
                loop    loc_21E7
                mov     es:[di], al
                pop     di
                retn
; ---------------------------------------------------------------------------

loc_21F5:                               ; ...
                cmp     cs:masking_mode, 80h
                jz      short loc_2215
                push    di
                mov     ah, al
                not     ah
                and     al, 1
                mov     cx, 0Ah

loc_2207:                               ; ...
                and     es:[di], ah
                or      es:[di], al
                add     di, 140h
                loop    loc_2207
                pop     di
                retn
; ---------------------------------------------------------------------------

loc_2215:                               ; ...
                push    di
                not     al
                mov     cx, 0Ah

loc_221B:                               ; ...
                and     es:[di], al
                add     di, 140h
                loop    loc_221B
                pop     di
                retn
draw_HUD_column_width_1 endp

; ---------------------------------------------------------------------------
masking_mode    db 0                    ; ...

; =============== S U B R O U T I N E =======================================

; No parameters (uses global heroMaxHp)
Draw_Hero_Max_Health proc near
                mov     di, 0CC14h
                mov     bx, cs:heroMaxHp
                jmp     short draw_max_hp_gauge
; ---------------------------------------------------------------------------

Draw_Boss_Max_Health:                   ; ...
                mov     di, 0DB14h      ; bx: boss maxHP
                jmp     short $+2
; ---------------------------------------------------------------------------

draw_max_hp_gauge:                      ; ...
                mov     ax, 0A000h
                mov     es, ax
                call    normalize_health_to_100
                mov     cx, bx
                or      cx, cx
                jnz     short loc_2245
                retn
; ---------------------------------------------------------------------------

loc_2245:                               ; ...
                push    cx
                push    di
                mov     bh, 6
                mov     al, 12h
                mov     ah, 2Dh ; '-'
                call    draw_vertical_line
                pop     di
                inc     di
                pop     cx
                loop    loc_2245
                retn
Draw_Hero_Max_Health endp


; =============== S U B R O U T I N E =======================================


; Draws hero health gauge
; No parameters (uses global hero_HP)

Draw_Hero_Health proc near
                mov     di, 0CC14h
                mov     bx, cs:hero_HP
                jmp     short loc_2265
; ---------------------------------------------------------------------------

Draw_Boss_Health:                       ; ...
                mov     di, 0DB14h      ; bx: boss health
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_2265:                               ; ...
                mov     ax, 0A000h
                mov     es, ax
                call    normalize_health_to_100
                push    bx
                mov     cx, bx
                or      cx, cx
                jz      short loc_2284

loc_2274:                               ; ...
                push    cx
                push    di
                mov     bh, 5
                mov     al, 9
                mov     ah, 12h
                call    draw_vertical_line
                pop     di
                inc     di
                pop     cx
                loop    loc_2274

loc_2284:                               ; ...
                pop     bx
                mov     cx, 64h ; 'd'
                sub     cx, bx
                jnz     short loc_228D
                retn
; ---------------------------------------------------------------------------

loc_228D:                               ; ...
                push    cx
                push    di
                mov     bh, 5
                xor     al, al
                mov     ah, 12h
                call    draw_vertical_line
                pop     di
                inc     di
                pop     cx
                loop    loc_228D
                retn
Draw_Hero_Health endp


; =============== S U B R O U T I N E =======================================


normalize_health_to_100 proc near       ; ...
                mov     ax, 320h
                sub     ax, bx
                jb      short loc_22AC
                shr     bx, 1
                shr     bx, 1
                shr     bx, 1
                retn
; ---------------------------------------------------------------------------

loc_22AC:                               ; ...
                mov     bx, 64h ; 'd'
                retn
normalize_health_to_100 endp


; =============== S U B R O U T I N E =======================================


draw_vertical_line proc near            ; ...
                and     es:[di], ah
                or      es:[di], al
                add     di, 140h
                dec     bh
                jnz     short draw_vertical_line
                retn
draw_vertical_line endp


; =============== S U B R O U T I N E =======================================

; [si]: left margin; [si+1]: top margin

; Renders a Pascal-style length-prefixed string with bright colors (1Bh/12h)
; SI: pointer to Pascal string
;   [SI+0]: width in chars
;   [SI+1]: left margin
;   [SI+2]: top margin
;   [SI+3]: height in rows
;   [SI+4..]: character data

Render_Pascal_String_0 proc near
                mov     cs:primary_color, 1Bh
                mov     cs:shadow_color, 12h
                jmp     short loc_2312
; ---------------------------------------------------------------------------

; Renders a Pascal-style length-prefixed string with dim colors (9/2Dh)
; SI: pointer to Pascal string (same format as Render_Pascal_String_0)

Render_Pascal_String_1:
                mov     cs:primary_color, 9
                mov     cs:shadow_color, 2Dh
                jmp     short loc_2312
; ---------------------------------------------------------------------------

; Renders a null-terminated C string with dim colors (9/0)
; BH: left margin
; BL: top margin
; CX: X pixel offset within the row

Render_C_String:
                mov     cs:primary_color, 9
                mov     cs:shadow_color, 0
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, ax
                xor     ch, ch
                add     di, cx
                mov     ax, 0A000h
                mov     es, ax

loc_2303:                               ; ...
                lodsb
                or      al, al
                jnz     short loc_2309
                retn
; ---------------------------------------------------------------------------

loc_2309:                               ; ...
                push    ds
                push    si
                call    render_glyph
                pop     si
                pop     ds
                jmp     short loc_2303
; ---------------------------------------------------------------------------

loc_2312:                               ; ...
                lodsb
                mov     dl, al
                xor     dh, dh
                push    dx
                lodsb
                xor     ah, ah
                mov     bx, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, ax
                lodsb
                xor     ah, ah
                mov     bl, al
                add     di, ax
                lodsb
                xor     ch, ch
                mov     cl, al
                mov     ax, 0A000h
                mov     es, ax

loc_2338:                               ; ...
                push    cx
                lodsb
                push    ds
                push    si
                call    render_glyph
                pop     si
                pop     ds
                pop     cx
                loop    loc_2338
                retn
Render_Pascal_String_0 endp


; =============== S U B R O U T I N E =======================================


render_glyph    proc near               ; ...
                sub     al, 20h ; ' '
                xor     ah, ah
                shl     ax, 1
                shl     ax, 1
                shl     ax, 1
                mov     si, ax
                add     si, ds:thin_font
                push    di
                mov     bl, 8

loc_2358:                               ; ...
                push    bx
                lodsb
                push    di
                mov     dh, al
                mov     dl, 4

loc_235F:                               ; ...
                add     dh, dh
                jnb     short loc_2371
                mov     al, shadow_color
                mov     es:[di+1], al
                mov     ah, primary_color
                mov     es:[di], ah

loc_2371:                               ; ...
                inc     di
                dec     dl
                jnz     short loc_235F
                pop     di
                add     di, 140h
                pop     bx
                dec     bl
                jnz     short loc_2358
                pop     di
                add     di, 5
                retn
render_glyph    endp


; =============== S U B R O U T I N E =======================================


; Clears the place/enemy name bar area of the HUD
; No parameters (uses fixed position: BX=210h, CH=88h, AL=0)

Clear_Place_Enemy_Bar proc near
                mov     bx, 210h
                xor     al, al
                mov     ch, 88h
                jmp     Clear_HUD_Bar   ; bh: paddingLeft
Clear_Place_Enemy_Bar endp              ; bl: paddingTop
                                        ; al: masking mode

; =============== S U B R O U T I N E =======================================


; Prints hero Almas count as decimal number
; No parameters (uses global hero_almas)

Print_Almas_Decimal proc near
                push    ds
                mov     ax, cs:hero_almas
                xor     dx, dx
                call    Prepare_Decimal_Display_Buffer
                push    cs
                pop     ds
                mov     di, 2435h
                mov     cx, 105h
                mov     ax, 26BBh
                mov     bx, 0FF01h
                call    Render_Decimal_Digits
                pop     ds
                retn
Print_Almas_Decimal endp


; =============== S U B R O U T I N E =======================================


; Prints hero gold count as decimal number
; No parameters (uses global hero_gold_hi/lo)

Print_Gold_Decimal proc near
                push    ds
                mov     ax, cs:hero_gold_lo
                mov     dl, cs:hero_gold_hi
                call    Prepare_Decimal_Display_Buffer
                push    cs
                pop     ds
                mov     di, 2434h
                mov     cx, 106h
                mov     ax, 13BBh
                mov     bx, 0FF01h
                call    Render_Decimal_Digits
                pop     ds
                retn
Print_Gold_Decimal endp


; =============== S U B R O U T I N E =======================================


; Prints current magic spell count as decimal number
; No parameters (uses global current_magic_spell and spells_espada table)

Print_Magic_Left_Decimal proc near
                push    ds
                xor     bx, bx
                mov     bl, cs:current_magic_spell
                dec     bl
                mov     al, cs:spells_espada[bx]
                xor     ah, ah
                xor     dx, dx
                call    Prepare_Decimal_Display_Buffer
                push    cs
                pop     ds
                mov     di, 2437h
                mov     cx, 103h
                mov     ax, 37BBh
                mov     bx, 0FF01h
                call    Render_Decimal_Digits
                pop     ds
                retn
Print_Magic_Left_Decimal endp


; =============== S U B R O U T I N E =======================================


; Prints hero shield HP as decimal number (NOP if no shield equipped)
; No parameters (uses global shield_type and shield_HP)

Print_ShieldHP_Decimal proc near
                test    byte ptr cs:shield_type, 0FFh
                jnz     short loc_23FE
                retn
; ---------------------------------------------------------------------------

loc_23FE:                               ; ...
                push    ds
                mov     ax, cs:shield_HP
                xor     dx, dx
                call    Prepare_Decimal_Display_Buffer
                push    cs
                pop     ds
                mov     di, 2437h
                mov     cx, 103h
                mov     ax, 3EBBh
                mov     bx, 0FF01h
                call    Render_Decimal_Digits
                pop     ds
                retn
Print_ShieldHP_Decimal endp


; =============== S U B R O U T I N E =======================================


; Initializes decimal digit display buffer at 2433h with 0FFh sentinels
; DI: pointer into the decimal digit buffer
Prepare_Decimal_Display_Buffer proc near
                mov     di, 2433h
                call    Convert_32bit_To_Decimal_Digits
                mov     cx, 6

loc_2424:                               ; ...
                test    byte ptr cs:[di], 0FFh
                jz      short loc_242B
                retn
; ---------------------------------------------------------------------------

loc_242B:                               ; ...
                mov     byte ptr cs:[di], 0FFh
                inc     di
                loop    loc_2424
                retn
Prepare_Decimal_Display_Buffer endp

; ---------------------------------------------------------------------------
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0

; =============== S U B R O U T I N E =======================================


; Converts 32-bit value in DX:AX into 7 decimal digit bytes at [di]
; No return value

Convert_32bit_To_Decimal_Digits proc near

                mov     cl, 0Fh
                mov     bx, 4240h
                call    _Divide_By_Rounding
                mov     cs:[di], dh
                mov     cl, 1
                mov     bx, 86A0h
                call    _Divide_By_Rounding
                mov     cs:[di+1], dh
                xor     cl, cl
                mov     bx, 2710h
                call    _Divide_By_Rounding
                mov     cs:[di+2], dh
                mov     bx, 1000
                call    _Divide_16_Get_High_Byte
                mov     cs:[di+3], dh
                mov     bx, 100 ; 'd'
                call    _Divide_16_Get_High_Byte
                mov     cs:[di+4], dh
                mov     bx, 10
                call    _Divide_16_Get_High_Byte
                mov     cs:[di+5], dh
                mov     cs:[di+6], al
                retn
Convert_32bit_To_Decimal_Digits endp


; =============== S U B R O U T I N E =======================================

; Private: divide AX by BX with rounding, quotient→DH
_Divide_By_Rounding proc near           
                xor     dh, dh

loc_2482:                               ; ...
                sub     dl, cl
                jb      short loc_2496
                sub     ax, bx
                jnb     short loc_2490
                or      dl, dl
                jz      short loc_2494
                dec     dl

loc_2490:                               ; ...
                inc     dh
                jmp     short loc_2482
; ---------------------------------------------------------------------------

loc_2494:                               ; ...
                add     ax, bx

loc_2496:                               ; ...
                add     dl, cl
                retn
_Divide_By_Rounding endp


; =============== S U B R O U T I N E =======================================


_Divide_16_Get_High_Byte proc near      ; Private: AX/BX, returns high byte of remainder in DH
                xor     dh, dh
                div     bx
                xchg    ax, dx
                mov     dh, dl
                xor     dl, dl
                retn
_Divide_16_Get_High_Byte endp


; =============== S U B R O U T I N E =======================================

; Renders 7-digit decimal from pre-computed buffer [di] using digit font
; AL: marginTop (row offset)
; AH: marginLeft4 (column offset × 4)

Render_Decimal_Digits proc near
                mov     shadow_color, bh
                xor     bh, bh
                mov     dl, mul9[bx]
                mov     primary_color, dl
                xor     bx, bx
                mov     bl, ah
                mov     ah, bh
                push    bx
                mov     bx, 140h
                mul     bx
                pop     bx
                add     bx, bx
                add     bx, bx
                add     bx, ax
                shr     ch, 1
                sbb     ax, ax
                and     ax, 2
                add     bx, ax
                mov     ax, 0A000h
                mov     es, ax

loc_24D2:                               ; ...
                mov     al, [di]
                inc     di
                push    bx
                push    cx
                push    di
                push    ds
                mov     di, bx
                call    _Render_Single_Digit_Glyph
                pop     ds
                pop     di
                pop     cx
                pop     bx
                add     bx, 6
                dec     cl
                jnz     short loc_24D2
                retn
Render_Decimal_Digits endp

; ---------------------------------------------------------------------------
mul9            db 0, 9, 12h, 1Bh, 24h, 2Dh, 36h, 3Fh ; ...

; =============== S U B R O U T I N E =======================================


; Renders a single decimal digit glyph from the digit font
; AL: digit value (0-9)
; BH: screen X position
; BP: screen offset

_Render_Single_Digit_Glyph proc near
                test    shadow_color, 0FFh
                jz      short loc_2512
                push    ax
                push    di
                mov     ax, 505h
                mov     cx, 7

loc_2501:                               ; ...
                push    cx
                push    di
                mov     cx, 3
                rep stosw
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_2501
                pop     di
                pop     ax

loc_2512:                               ; ...
                inc     al
                jnz     short loc_2517
                retn
; ---------------------------------------------------------------------------

loc_2517:                               ; ...
                dec     al
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     ax, ax
                add     ax, cs:digits_font
                mov     si, ax
                push    cs
                pop     ds
                mov     cx, 7

loc_252D:                               ; ...
                lodsb
                add     al, al
                add     al, al
                mov     ah, 6

loc_2534:                               ; ...
                add     al, al
                jnb     short loc_2540
                mov     bl, cs:primary_color
                mov     es:[di], bl

loc_2540:                               ; ...
                inc     di
                dec     ah
                jnz     short loc_2534
                add     di, 13Ah
                loop    loc_252D
                retn
_Render_Single_Digit_Glyph endp


; =============== S U B R O U T I N E =======================================


; Renders 20x18 sword item sprite with 3-plane decompression
; AL: sprite index
; BH: row offset
; itemp.grp
Render_Sword_Item_Sprite_20x18 proc near
                push    ds
                mov     ds, word ptr cs:seg1
                dec     al
                xor     ah, ah
                mov     cx, 15*18
                mul     cx
                add     ax, ds:sword_item_gfx
                mov     si, ax
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 320
                mul     bx
                pop     bp
                add     bp, bp
                add     bp, bp
                add     bp, bp
                add     bp, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 18
next_row_of_18:
                push    cx
                mov     ax, [si]
                xchg    ah, al
                mov     cs:plane1, ax
                mov     ax, [si+8]
                mov     cs:plane2, ax
                mov     ax, [si+10]
                xchg    ah, al
                mov     cs:plane3, ax
                call    _Decode_4_Pixels_From_3_Planes
                call    _Decode_4_Pixels_From_3_Planes
                mov     ax, [si+2]
                xchg    ah, al
                mov     cs:plane1, ax
                mov     ax, [si+6]
                mov     cs:plane2, ax
                mov     ax, [si+12]
                xchg    ah, al
                mov     cs:plane3, ax
                call    _Decode_4_Pixels_From_3_Planes
                call    _Decode_4_Pixels_From_3_Planes
                xor     al, al
                mov     ah, [si+4]
                mov     cs:plane1, ax
                mov     ah, [si+5]
                mov     cs:plane2, ax
                mov     ah, [si+14]
                mov     cs:plane3, ax
                call    _Decode_4_Pixels_From_3_Planes
                add     si, 15
                add     bp, 300
                pop     cx
                loop    next_row_of_18
                pop     ds
                retn
Render_Sword_Item_Sprite_20x18 endp


; =============== S U B R O U T I N E =======================================


; Renders magic spell item sprite with 3-plane decompression
; AL: sprite index
Render_Magic_Spell_Item_Sprite_16x16 proc near
                push    ds
                mov     ds, word ptr cs:seg1
                dec     al
                xor     ah, ah
                mov     cx, 0C0h
                mul     cx
                add     ax, ds:magic_spell_item_gfx
                mov     si, ax
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Magic_Spell_Item_Sprite_16x16 endp


; =============== S U B R O U T I N E =======================================


; Renders shield item sprite with 3-plane decompression
; AL: sprite index, starts at 1
Render_Shield_Item_Sprite_16x16 proc near
                push    ds
                mov     ds, word ptr cs:seg1
                dec     al
                xor     ah, ah
                mov     cx, 16*12
                mul     cx
                add     ax, ds:shield_item_gfx
                mov     si, ax
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Shield_Item_Sprite_16x16 endp


; =============== S U B R O U T I N E =======================================


; Render shoes/cape item sprite with 3-plane decompression
; AL: sprite index (0 = built-in "no use" icon, 1..5 = use seg1 buffer)
Render_Wearable_Item_Sprite_16x16 proc near
                push    ds
                mov     si, offset no_use_icon
                or      al, al
                jz      short loc_2632
                mov     ds, word ptr cs:seg1
                dec     al
                xor     ah, ah
                mov     cx, 0C0h
                mul     cx
                add     ax, ds:wearable_item_gfx
                mov     si, ax

loc_2632:
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Wearable_Item_Sprite_16x16 endp


; =============== S U B R O U T I N E =======================================


; Magic potion sprite render with 3-plane decompression
; AL: sprite index (0 = built-in "no use" icon, 1..8 = use seg1 buffer)
Render_Magic_Potion_Item_Sprite_16x16 proc near
                push    ds
                mov     si, offset no_use_icon
                or      al, al
                jz      short loc_2653
                mov     ds, word ptr cs:seg1
                dec     al
                xor     ah, ah
                mov     cx, 0C0h
                mul     cx
                add     ax, ds:magic_potion_item_gfx
                mov     si, ax
loc_2653:
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Magic_Potion_Item_Sprite_16x16 endp

; Built-in 16-row sprite data table (192 bytes = 16 rows × 12 bytes)
no_use_icon:
                db  0, 0, 0, 0, 0FCh, 0FFh, 0FFh, 3Fh, 2Ah, 0AAh, 0AAh, 0A8h ; ...
                db  0, 0, 0, 0, 3, 0, 0, 0C0h, 80h, 0, 0, 2
                db  0Eh, 38h, 0F8h, 0, 3, 0, 0, 0C0h, 82h, 8, 8, 2
                db  0Fh, 0BBh, 8Eh, 0, 3, 0, 0, 0C0h, 80h, 88h, 82h, 2
                db  0Fh, 0FBh, 8Eh, 0, 3, 0, 0, 0C0h, 80h, 8, 82h, 2
                db  0Eh, 0FBh, 8Eh, 0, 3, 0, 0, 0C0h, 82h, 8, 82h, 2
                db  0Eh, 38h, 0F8h, 0, 3, 0, 0, 0C0h, 82h, 8, 8, 2
                db  0, 0, 0, 0, 3, 0, 0, 0C0h, 80h, 0, 0, 2
                db  0, 0, 0, 0, 3, 0, 0, 0C0h, 80h, 0, 0, 2
                db  0Eh, 38h, 0FBh, 0F8h, 3, 0, 0, 0C0h, 82h, 8, 8, 0Ah
                db  0Eh, 3Bh, 83h, 80h, 3, 0, 0, 0C0h, 82h, 8, 80h, 82h
                db  0Eh, 38h, 0E3h, 0C0h, 3, 0, 0, 0C0h, 82h, 8, 20h, 2
                db  0Eh, 38h, 3Bh, 80h, 3, 0, 0, 0C0h, 82h, 8, 8, 82h
                db  3, 0E3h, 0E3h, 0F8h, 3, 0, 0, 0C0h, 80h, 20h, 20h, 0Ah
                db  0, 0, 0, 0, 3, 0, 0, 0C0h, 80h, 0, 0, 2
                db  0, 0, 0, 0, 0FCh, 0FFh, 0FFh, 3Fh, 2Ah, 0AAh, 0AAh, 0A8h

; =============== S U B R O U T I N E =======================================


; Renders key item sprite with 3-plane decompression
; AL: key type index
Render_Key_Item_Sprite_16x16 proc near
                push    ds
                mov     ds, word ptr cs:seg1
                xor     ah, ah
                mov     cx, 16*12
                mul     cx
                add     ax, ds:key_item_gfx
                mov     si, ax
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Key_Item_Sprite_16x16 endp


; =============== S U B R O U T I N E =======================================


; Renders crest item sprite with 3-plane decompression
; AH: shield type index
Render_Crest_Item_Sprite_16x16 proc near
                push    ds
                mov     ds, word ptr cs:seg1
                xor     ah, ah
                mov     cx, 16*12
                mul     cx
                add     ax, ds:crest_item_gfx
                mov     si, ax
                call    Render_3plane_16x16_Sprite
                pop     ds
                retn
Render_Crest_Item_Sprite_16x16 endp


; =============== S U B R O U T I N E =======================================


; Core 3-plane→packed pixel decompressor
; Input:
; SI: source data pointer (12 bytes per 16 pixel line)
; BL: y
; BH: (x-2)/4
; Output:
; BP: computed destination screen address
Render_3plane_16x16_Sprite proc near
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 320
                mul     bx          ; ax=320*y
                pop     bp          ; x
                add     bp, bp
                add     bp, bp      ; x*4
                add     bp, 2       ; x*4+2
                add     bp, ax      ; x*4+y*320+2
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 16
loc_2766:
                push    cx
                mov     ax, [si]
                xchg    ah, al
                mov     cs:plane1, ax
                mov     ax, [si+6]
                mov     cs:plane2, ax
                mov     ax, [si+8]
                xchg    ah, al
                mov     cs:plane3, ax
                call    _Decode_4_Pixels_From_3_Planes
                call    _Decode_4_Pixels_From_3_Planes
                mov     dx, [si+2]
                xchg    dh, dl
                mov     cs:plane1, dx
                mov     dx, [si+4]
                mov     cs:plane2, dx
                mov     dx, [si+0Ah]
                xchg    dh, dl
                mov     cs:plane3, dx
                call    _Decode_4_Pixels_From_3_Planes
                call    _Decode_4_Pixels_From_3_Planes
                add     si, 12
                add     bp, 320-16     ; next pixel row
                pop     cx
                loop    loc_2766     ; 16 pixel rows
                retn
Render_3plane_16x16_Sprite endp


; =============== S U B R O U T I N E =======================================


_Decode_4_Pixels_From_3_Planes proc near
                mov     cx, 4
next_pixel_of_4:
                xor     ax, ax
                rol     cs:plane3, 1
                adc     ax, ax
                rol     cs:plane2, 1
                adc     ax, ax
                rol     cs:plane1, 1
                adc     ax, ax
                rol     cs:plane3, 1
                adc     ax, ax
                rol     cs:plane2, 1
                adc     ax, ax
                rol     cs:plane1, 1
                adc     ax, ax
                mov     es:[bp+0], al  ; render pixel to VRAM at bp addr
                inc     bp
                loop    next_pixel_of_4
                retn
_Decode_4_Pixels_From_3_Planes endp


; =============== S U B R O U T I N E =======================================

; AL: ASCII character code
; AH: Palette/colour index
; BX: X pixel coordinate in framebuffer
; CX: Y pixel coordinate (row)
; CS:0xFF77: Flag: 0 = normal colour mode, nonzero = "bright/highlight" mode

; Renders an 8x8 font glyph from the letters font table
; AL: ASCII character code
; AH: Palette/colour index
; BX: X pixel coordinate in framebuffer
; CX: Y pixel coordinate (row)
; CS:font_highlight_flag: 0 = normal colour mode, nonzero = "bright/highlight" mode

Render_Font_Glyph proc near
                push    ds
                push    cs
                pop     ds
                push    bx
                xor     bx, bx
                mov     bl, ah
                mov     ah, ds:mul9[bx]
                test    byte ptr cs:font_highlight_flag, 0FFh
                jz      short loc_2809
                mov     ah, bl
                add     ah, ah
                add     ah, ah
                add     ah, ah
                add     ah, ah
                or      ah, bl

loc_2809:                               ; ...
                mov     ds:primary_color, ah
                pop     bx
                xor     ah, ah
                sub     al, 20h ; ' '
                add     ax, ax
                add     ax, ax
                add     ax, ax          ; glyphId*8
                add     ax, word ptr ds:bold_font_8x8
                push    ax
                mov     al, bl
                and     al, 3
                add     al, al
                mov     ds:shadow_color, al
                mov     ax, 320
                xor     ch, ch
                mul     cx
                add     ax, bx
                mov     di, ax
                pop     si
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 8

loc_283A:
                push    cx
                lodsb
                mov     cx, 8

next_bit:
                add     al, al          ; al bit 7
                jnb     short skip_zero_bit
                mov     dl, cs:primary_color
                mov     es:[di], dl

skip_zero_bit:
                inc     di
                loop    next_bit
                pop     cx
                add     di, 320-8
                loop    loc_283A
                pop     ds
                retn
Render_Font_Glyph endp


; =============== S U B R O U T I N E =======================================


; Copies a rectangular region of the screen down by one row
; BH: left margin
; BL: top margin
; CL: height (rows)
; CH: width (words)

Scroll_Screen_Rect_Down proc near
                push    ds
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, di
                add     di, ax
                mov     si, di
                add     si, 140h
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     bl, ch
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                xor     ch, ch

loc_2884:                               ; ...
                push    cx
                push    di
                push    si
                mov     cx, bx
                rep movsw
                pop     si
                pop     di
                add     di, 140h
                add     si, 140h
                pop     cx
                loop    loc_2884
                pop     ds
                retn
Scroll_Screen_Rect_Down endp


; =============== S U B R O U T I N E =======================================

; AH: x in tiles
; AL: y in pixels
; CL: height of the rectangle in pixels
; CH: width of the rectangle in tiles
; DI: destination Offset in seg3

Capture_Screen_Rect_to_seg3 proc near   ; ...
                push    ds
                add     di, 0
                xor     bx, bx
                mov     bl, ah
                mov     ah, bh
                push    bx
                mov     bx, 140h
                mul     bx
                pop     si
                add     si, si
                add     si, si
                add     si, si
                add     si, ax
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax
                mov     ax, 0A000h
                mov     ds, ax
                mov     bl, ch
                xor     bh, bh
                mov     ch, bh
                add     bx, bx
                add     bx, bx

loc_28C9:                               ; ...
                push    cx
                push    si
                mov     cx, bx
                rep movsw
                pop     si
                add     si, 140h
                pop     cx
                loop    loc_28C9
                pop     ds
                retn
Capture_Screen_Rect_to_seg3 endp


; =============== S U B R O U T I N E =======================================

; AH: x in tiles
; AL: y in pixels
; CL: height of the rectangle in pixels
; CH: width of the rectangle in tiles
; DI: source Offset in seg3

Put_Image       proc near               ; ...
                push    ds
                mov     si, di
                add     si, 0
                xor     bx, bx
                mov     bl, ah
                mov     ah, bh
                push    bx
                mov     bx, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, di
                add     di, ax
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     bl, ch
                xor     bh, bh
                mov     ch, bh
                add     bx, bx
                add     bx, bx

loc_290A:                               ; ...
                push    cx
                push    di
                mov     cx, bx
                rep movsw
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_290A
                pop     ds
                retn
Put_Image       endp


; =============== S U B R O U T I N E =======================================

; BX: starting x coord
; CL: starting y coord
; SI: string pointer

; Renders a 0FFh-terminated string with control codes
; BX: starting X coord
; CL: starting Y coord
; SI: string pointer
;   Control codes: 0Dh = newline, 80h-87h = color change

Render_String_FF_Terminated proc near
                mov     cs:word_2CC0, bx
                mov     cs:byte_2CC2, cl
                mov     al, 1
                test    byte ptr cs:0FF77h, 0FFh
                jz      short loc_2930
                mov     al, 7

loc_2930:                               ; ...
                mov     cs:byte_2CBF, al

loc_2934:                               ; ...
                lodsb
                cmp     al, 0FFh
                jnz     short loc_293A
                retn
; ---------------------------------------------------------------------------

loc_293A:                               ; ...
                cmp     al, 0Dh
                jz      short loc_2955
                or      al, al
                js      short loc_2967
                push    cx
                push    bx
                push    si
                mov     ah, cs:byte_2CBF
                call    Render_Font_Glyph ; AL: ASCII character code
                                        ; AH: Palette/colour index
                                        ; BX: X pixel coordinate in framebuffer
                                        ; CX: Y pixel coordinate (row)
                                        ; CS:0xFF77: Flag: 0 = normal colour mode, nonzero = "bright/highlight" mode
                pop     si
                pop     bx
                pop     cx
                add     bx, 8
                jmp     short loc_2934
; ---------------------------------------------------------------------------

loc_2955:                               ; ...
                add     cs:byte_2CC2, 8
                mov     cl, cs:byte_2CC2
                mov     bx, cs:word_2CC0
                jmp     short loc_2934
; ---------------------------------------------------------------------------

loc_2967:                               ; ...
                and     al, 7
                mov     cs:byte_2CBF, al
                jmp     short loc_2934
Render_String_FF_Terminated endp


; =============== S U B R O U T I N E =======================================


; VRAM-to-VRAM screen rectangle copy (used in boss HUD rendering)
; BH: source X
; BL: source Y
; CH: width (words)

Copy_Screen_Rect_VRAM proc near
                push    ds
                push    dx
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     si
                add     si, si
                add     si, si
                add     si, si
                add     si, ax
                pop     bx
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, di
                add     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     bl, ch
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                xor     ch, ch

loc_29AD:                               ; ...
                push    cx
                push    di
                push    si
                mov     cx, bx
                rep movsw
                pop     si
                pop     di
                add     di, 140h
                add     si, 140h
                pop     cx
                loop    loc_29AD
                pop     ds
                retn
Copy_Screen_Rect_VRAM endp


; =============== S U B R O U T I N E =======================================


; Draws a status indicator frame/border
; AL: status index
; BH: left margin
; BL: top margin

Draw_Status_Frame proc near
                push    bx
                xor     bx, bx
                mov     bl, al
                mov     al, mul9[bx]
                mov     primary_color, al
                pop     bx
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 140h
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, ax
                mov     ax, 0A000h
                mov     es, ax
                call    _Draw_Status_Frame_Lines
                mov     al, primary_color
                mov     cx, 10h

loc_29F1:                               ; ...
                mov     es:[di], al
                mov     es:[di+1], al
                mov     es:[di+12h], al
                mov     es:[di+13h], al
                add     di, 140h
                loop    loc_29F1
Draw_Status_Frame endp


; =============== S U B R O U T I N E =======================================


; Draws horizontal border lines for status frame
; AL: primary color

_Draw_Status_Frame_Lines proc near
                mov     cx, 2

loc_2A09:
                push    cx
                push    di
                mov     al, primary_color
                mov     cx, 14h
                rep stosb
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_2A09
                retn
_Draw_Status_Frame_Lines endp


; =============== S U B R O U T I N E =======================================


; Renders a magic spell icon graphic (13 rows)
; AL: spell index (0-12, used with off_2A5D lookup table)
; BH: left margin
; BL: top margin

Render_Tear_Icon proc near
                push    ds
                push    si
                push    cs
                pop     ds
                xor     ah, ah
                add     ax, ax
                mov     si, ax
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 320
                mul     bx
                pop     di
                add     di, di
                add     di, di
                add     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     si, ds:off_2A5D[si]
                mov     cx, 13
next_row_of_13:
                push    cx
                mov     cx, 16

next_pixel_of_16:
                lodsb
                cmp     al, 80h     ; transparent pixel
                je      short skip_opaque
                stosb               ; put pixel in VRAM
                dec     di
skip_opaque:
                inc     di
                loop    next_pixel_of_16
                pop     cx
                add     di, 320-16
                loop    next_row_of_13
                pop     si
                pop     ds
                retn
Render_Tear_Icon endp

; ---------------------------------------------------------------------------
off_2A5D        dw offset byte_2A61
                dw offset byte_2B31
byte_2A61       db 80h, 80h, 80h, 80h, 80h, 80h, 0, 0, 0, 0, 80h, 0, 80h
                db 80h, 80h, 80h, 80h, 80h, 80h, 80h, 0, 0, 11h, 11h, 11h, 12h
                db 0, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 0, 11h, 11h
                db 9, 9, 1, 12h, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h
                db 0, 11h, 9, 9, 9, 28h, 2Ah, 10h, 80h, 80h, 80h, 80h, 80h
                db 80h, 80h, 80h, 11h, 15h, 1, 9, 0Dh, 5, 5, 12h, 0, 80h
                db 80h, 80h, 80h, 80h, 80h, 80h, 11h, 10h, 28h, 28h, 2Dh, 28h, 28h
                db 12h, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 12h, 15h, 5, 5
                db 5, 5, 5, 12h, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 0
                db 12h, 5, 2Dh, 2Dh, 5, 15h, 2, 80h, 80h, 80h, 80h, 80h, 80h
                db 80h, 80h, 0, 2, 2, 2Dh, 2Dh, 5, 12h, 0, 80h, 80h, 80h
                db 80h, 80h, 80h, 80h, 80h, 0, 0, 2, 12h, 12h, 12h, 0, 0
                db 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 0, 0, 80h, 0, 0
                db 0, 80h, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h
                db 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h
                db 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 80h
                
byte_2B31       db 80h, 80h, 80h, 80h, 0, 1, 9, 9, 9, 1Bh, 3, 0, 80h
                db 80h, 80h, 80h, 80h, 80h, 80h, 0, 9, 9, 0, 0, 0, 0
                db 3, 1Bh, 0, 80h, 80h, 80h, 80h, 80h, 0, 9, 1, 0, 1
                db 9, 1, 0, 0, 3, 3, 0, 80h, 80h, 80h, 80h, 1, 9
                db 0, 9, 9, 1, 0, 0, 1, 0, 3, 3, 80h, 80h, 80h
                db 0, 9, 1, 1, 9, 9, 0, 0, 0, 0, 1, 3, 3
                db 0, 80h, 80h, 0, 9, 0, 9, 1, 0, 0, 2, 2, 0
                db 0, 0, 0Bh, 0, 80h, 80h, 0, 9, 0, 1, 0, 0, 2
                db 2, 2, 2, 2, 2, 0Bh, 0, 80h, 80h, 0, 9, 3, 1
                db 2, 2, 2, 12h, 12h, 12h, 2, 1, 0Bh, 0, 80h, 80h, 80h
                db 1, 1Bh, 2, 1, 2, 12h, 12h, 12h, 12h, 2, 9, 1, 80h
                db 80h, 80h, 80h, 0, 0Bh, 3, 2, 0Ah, 1, 12h, 12h, 12h, 1
                db 9, 0, 80h, 80h, 80h, 80h, 80h, 0, 1Bh, 3, 2, 0, 2
                db 2, 1, 9, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h, 0, 3
                db 1, 3, 3, 1, 3, 0, 80h, 80h, 80h, 80h, 80h, 80h, 80h
                db 80h, 80h, 0, 0, 0, 0, 0, 0, 80h, 80h, 80h, 80h, 80h

; =============== S U B R O U T I N E =======================================


; Clears entire screen (320x200) to black
; No parameters

Clear_Screen proc near
                mov     ax, 0A000h
                mov     es, ax
                xor     di, di
                mov     cx, 8

loc_2C0B:                               ; ...
                push    cx
                push    di
                mov     cx, 19h

loc_2C10:                               ; ...
                push    cx
                push    di
                mov     cx, 0A0h
                xor     ax, ax
                rep stosw
                pop     di
                add     di, 0A00h
                pop     cx
                loop    loc_2C10
                pop     di
                add     di, 140h
                pop     cx
                loop    loc_2C0B
                retn
Clear_Screen endp


; =============== S U B R O U T I N E =======================================

; si: src
; cx: number of 48-byte elements to reassemble

; Reassembles 3-plane sprite data into packed 6bpp bitmap in place
; DS:SI: source (3-plane data)
; CX: number of 48-byte elements to reassemble (24 for magic spells)
; Output: packed 6bpp bitmap in DS:SI
; Uses seg3:3000h as temporary buffer
Reassemble_3_Planes_To_Packed_Bitmap proc near
                push    cx
                push    ds
                push    si
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     ax, 48
                mul     cx
                mov     cx, ax
                mov     di, 0
                rep movsb              ; copy to seg3:0 buffer
                pop     di             ; es:di = source
                pop     es
                pop     cx
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax
                mov     si, 0
next_48_bytes:
                push    cx
                call    assemble_48_bytes
                pop     cx
                loop    next_48_bytes
                retn
Reassemble_3_Planes_To_Packed_Bitmap endp


; =============== S U B R O U T I N E =======================================


assemble_48_bytes proc near
                mov     cx, 8
eight_times:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:plane2, ax
                lodsw
                xchg    ah, al
                mov     cs:plane3, ax
                call    assemble_48_bits
                pop     cx
                loop    eight_times
                retn
assemble_48_bytes endp


; =============== S U B R O U T I N E =======================================


assemble_48_bits proc near
                mov     cx, 2
two_times:
                call    assemble_3_bits
                call    assemble_3_bits
                call    assemble_3_bits
                call    assemble_3_bits
                call    assemble_3_bits
                rol     cs:plane3, 1
                adc     ax, ax
                stosw
                rol     cs:plane2, 1
                adc     ax, ax
                rol     cs:plane1, 1
                adc     ax, ax
                call    assemble_3_bits
                call    assemble_3_bits
                stosb
                loop    two_times
                retn
assemble_48_bits endp


; =============== S U B R O U T I N E =======================================


assemble_3_bits proc near
                rol     cs:plane3, 1
                adc     ax, ax
                rol     cs:plane2, 1
                adc     ax, ax
                rol     cs:plane1, 1
                adc     ax, ax
                retn
assemble_3_bits endp

; ---------------------------------------------------------------------------
primary_color   db 0
shadow_color    db 0
byte_2CBF       db 0
word_2CC0       dw 0
byte_2CC2       db 0
plane1          dw 0
plane2          dw 0
plane3          dw 0

gmmcga          ends


                end     start
