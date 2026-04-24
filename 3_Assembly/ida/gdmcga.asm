include common.inc
                .286
                .model small
gdmcga          segment byte public 'CODE' use16
                assume cs:gdmcga
                org 3000h
start:                
                dw offset NoOp
                dw offset Decompress_3Plane_2Row
                dw offset Decompress_3Plane_Interleaved
                dw offset Render_With_MaskErase_Callback
                dw offset GDMCGA_Fade_To_Black
                dw offset Clear_Seg2_Buffer
                dw offset Render_Text_String
                dw offset Blit_Sprite_To_Screen
                dw offset Decompress_And_Copy_To_VRAM
                dw offset Animate_Sprites
                dw offset Load_Tiles_From_Big_Block
                dw offset Load_Tiles_From_Small_Block
                dw offset GDMCGA_Clear_Viewport
                dw offset Decompress_3Plane_XOR
                dw offset Render_Tile_Grid
                dw offset Blit_And_Or_Xor_Masked
                dw offset Render_Scrolling_Border
                dw offset Render_Animated_Tiles
                dw offset GDMCGA_Draw_Bordered_Rect
                dw offset Pack_3Plane_And_Render
                dw offset Render_Animated_Tile_Rows
                dw offset Render_Tile_Rows_TopDown
                dw offset Render_Tile_Rows_BottomUp
                dw offset GDMCGA_Clear_HUD_Bar
                dw offset GDMCGA_Font_Glyph_Thunk

; =============== S U B R O U T I N E =======================================
; Decompress 3-plane graphics, 2 source rows per dest row
;   Input:
;     CH = height (number of tile rows)
;     CL = width (number of tile columns)
;     DI = source data pointer (DS:DI)
;   Output:
;     ES = seg3 buffer, decompressed 2bpp bitmap at ES:0
Decompress_3Plane_2Row        proc near
                push    ax
                push    bx
                push    cx
                push    ds
                mov     al, ch
                mul     cl
                mov     bp, ax
                push    es
                pop     ds
                mov     si, di
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                assume es:nothing
                mov     di, 0
                mov     cs:decomp_plane1, 0
                mov     cs:decomp_plane2, 0
                mov     cx, bp
                shr     cx, 1

loc_305C:                               ; ...
                mov     ax, ds:[bp+si]
                xchg    ah, al
                mov     cs:decomp_plane3, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_305C
                pop     ds
                pop     cx
                pop     bx
                pop     ax
                mov     di, 0
                jmp     loc_3189
; ---------------------------------------------------------------------------

; Decompress 3-plane graphics, interleaved source addressing
;   Input:
;     CH = height (number of tile rows)
;     CL = width (number of tile columns)
;     DI = source data pointer (DS:DI)
;   Output:
;     ES = seg3 buffer, decompressed 2bpp bitmap at ES:0
Decompress_3Plane_Interleaved:
                push    ax
                push    bx
                push    cx
                push    ds
                mov     al, ch
                mul     cl
                mov     bp, ax
                push    es
                pop     ds
                assume ds:nothing
                mov     si, di
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     di, 0
                mov     cs:decomp_plane3, 0
                mov     cx, bp
                shr     cx, 1

loc_30AB:                               ; ...
                add     bp, bp
                mov     ax, ds:[bp+si]
                xchg    al, ah
                mov     cs:decomp_plane2, ax
                shr     bp, 1
                mov     ax, ds:[bp+si]
                xchg    al, ah
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    al, ah
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_30AB
                pop     ds
                assume ds:nothing
                pop     cx
                pop     bx
                pop     ax
                mov     di, 0
                jmp     loc_3189
; ---------------------------------------------------------------------------

; Render with MaskErase callback (2bpp erase via NOT+AND)
;   Input:
;     CH = height
;     CL = width
;     BH = screen Y coordinate
;     BL = screen X coordinate / 4
Render_With_MaskErase_Callback:
                push    ds
                push    ax
                push    es
                push    di
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     si
                pop     ds
                pop     ax
                mov     cs:render_callback, offset Render_MaskErase_2bpp
                call    Render_8Plane_Loop
                pop     ds
                retn
; ---------------------------------------------------------------------------

; Decompress 3-plane graphics with XOR logic (AND+OR blend)
;   Input:
;     CH = height
;     CL = width
;     DI = source data pointer (DS:DI)
Decompress_3Plane_XOR:
                push    bx
                push    cx
                push    ds
                mov     al, ch
                mul     cl
                mov     bp, ax
                push    es
                pop     ds
                assume ds:nothing
                mov     si, di
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     di, 0
                mov     cs:decomp_plane0, 0
                mov     cx, bp
                shr     cx, 1

loc_311E:                               ; ...
                push    cx
                mov     bx, ds:[bp+si]
                xchg    bh, bl
                lodsw
                xchg    ah, al
                mov     dx, bx
                and     dx, ax
                mov     cx, bx
                or      cx, ax
                not     dx
                and     ax, dx
                and     bx, dx
                mov     cs:decomp_plane2, bx
                mov     cs:decomp_plane1, ax
                mov     cs:decomp_plane3, cx
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                pop     cx
                loop    loc_311E
                pop     ds
                assume ds:nothing
                pop     cx
                pop     bx
                xor     ax, ax
                mov     di, 0
                push    ds
                push    ax
                push    es
                push    di
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     si
                pop     ds
                pop     ax
                mov     cs:render_callback, offset Render_SetOr_Transparent
                mov     cs:render_mode, 0
                or      al, al
                jnz     short loc_317E
                call    Render_8Plane_Loop

loc_317E:                               ; ...
                mov     cs:render_mode, 0FFh
                call    Render_8Plane_Loop
                pop     ds
                retn
; ---------------------------------------------------------------------------

loc_3189:                               ; ...
                push    ds
                push    ax
                push    es
                push    di
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     si
                pop     ds
                pop     ax
                mov     cs:render_callback, offset Render_SetOr_Pixel
                mov     cs:render_mode, 0
                or      al, al
                jnz     short loc_31A9
                call    Render_8Plane_Loop

loc_31A9:                               ; ...
                mov     cs:render_mode, 0FFh
                call    Render_8Plane_Loop
                pop     ds
                retn
Decompress_3Plane_2Row        endp


; =============== S U B R O U T I N E =======================================


; Core 8-plane render loop: iterates 8 bit-plane groups, calls render_callback per row
;   Input:
;     CH = tile width (columns)
;     render_callback = function pointer (Render_SetOr_Pixel / Render_SetOr_Transparent / Render_MaskErase_2bpp)
;     render_mode = mode flag for callbacks
;     decomp_plane0..3 = pre-loaded decompressed plane data
;   Clobbers: ES:DI (VRAM), SI, AX, CX, flags
Render_8Plane_Loop        proc near
                mov     cs:plane_group, 0
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     bp, 8

loc_31C2:                               ; ...
                mov     al, cs:plane_group
                mov     cs:plane_row, al
                mov     byte ptr cs:frame_timer, 0
                push    cx
                push    si
                push    di

loc_31D3:                               ; ...
                mov     bl, cs:plane_row
                and     bx, 7
                mov     bl, cs:byte_32B9[bx]
                call    cs:render_callback
                inc     cs:plane_row
                mov     al, ch
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     si, ax
                add     di, 320
                dec     cl
                jz      short loc_3225
                mov     bl, cs:plane_row
                and     bx, 7
                mov     bl, cs:byte_32C1[bx]
                call    cs:render_callback
                inc     cs:plane_row
                mov     al, ch
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     si, ax
                add     di, 320
                dec     cl
                jnz     short loc_31D3

loc_3225:                               ; ...
                pop     di
                pop     si
                pop     cx
                inc     cs:plane_group

loc_322D:                               ; ...
                cmp     byte ptr cs:frame_timer, 20
                jb      short loc_322D
                dec     bp
                jnz     short loc_31C2
                retn
Render_8Plane_Loop        endp


; =============== S U B R O U T I N E =======================================


; Render a single row of pixels with set-or-OR logic (callback for Render_8Plane_Loop)
;   Input:
;     SI = source pixel data pointer
;     DI = VRAM destination
;     CH = number of pixels to render
;     BL = bitmask (from byte_32B9/byte_32C1 lookup table)
;     render_mode = 0 = OR onto VRAM, 0FFh = direct write
;   Clobbers: AX, CX, SI, DI, flags
Render_SetOr_Pixel        proc near
                test    cs:render_mode, 0FFh
                jz      short loc_325B
                push    si
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx

loc_324C:                               ; ...
                lodsb
                rol     bl, 1
                jnb     short loc_3254
                mov     es:[di], al

loc_3254:                               ; ...
                inc     di
                loop    loc_324C
                pop     cx
                pop     di
                pop     si
                retn
; ---------------------------------------------------------------------------

loc_325B:                               ; ...
                push    si
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx

loc_3266:                               ; ...
                lodsb
                rol     bl, 1
                sbb     ah, ah
                and     al, ah
                or      es:[di], al
                inc     di
                loop    loc_3266
                pop     cx
                pop     di
                pop     si
                retn
Render_SetOr_Pixel        endp


; =============== S U B R O U T I N E =======================================


; Like Render_SetOr_Pixel but skips zero-value source pixels (transparent pixel handling)
;   Input:
;     SI = source pixel data pointer
;     DI = VRAM destination
;     CH = number of pixels to render
;     BL = bitmask
;     render_mode = 0 = OR onto VRAM, 0FFh = direct write
;   Clobbers: AX, CX, SI, DI, flags
Render_SetOr_Transparent        proc near
                test    cs:render_mode, 0FFh
                jz      short loc_325B
                push    si
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx

loc_328A:                               ; ...
                lodsb
                rol     bl, 1
                jnb     short loc_3296
                or      al, al
                jz      short loc_3296
                mov     es:[di], al

loc_3296:                               ; ...
                inc     di
                loop    loc_328A
                pop     cx
                pop     di
                pop     si
                retn
Render_SetOr_Transparent        endp


; =============== S U B R O U T I N E =======================================


; Erase 2bpp pixels in VRAM using NOT+AND masking
;   Input:
;     DI = VRAM destination
;     CH = number of 2bpp pixels to erase
;     BL = bitmask (inverted)
;   Clobbers: AX, CX, SI, DI, flags
Render_MaskErase_2bpp        proc near
                push    di
                push    cx
                not     bl
                mov     cl, ch
                xor     ch, ch
                add     cx, cx

loc_32A7:                               ; ...
                rol     bl, 1
                sbb     al, al
                rol     bl, 1
                sbb     ah, ah
                and     es:[di], ax
                inc     di
                inc     di
                loop    loc_32A7
                pop     cx
                pop     di
                retn
Render_MaskErase_2bpp        endp

; ---------------------------------------------------------------------------
byte_32B9       db 80h, 20h, 8, 2, 40h, 10h, 4, 1 ; ...
byte_32C1       db 1, 4, 10h, 40h, 2, 8, 20h, 80h ; ...

; =============== S U B R O U T I N E =======================================


; Render text string to seg3 text buffer using 8x8 font
;   Input:
;     SI = pointer to FF-terminated string
;   Output:
;     text_buffer = rendered 2bpp bitmap
Render_Text_String        proc near
                push    cs
                pop     es
                assume es:nothing
                mov     di, offset text_buffer
                xor     ax, ax
                mov     cx, 1600
                rep stosw
                mov     di, offset text_buffer

loc_32D8:                               ; ...
                lodsb
                cmp     al, 0FFh
                jnz     short loc_32DE
                retn
; ---------------------------------------------------------------------------

loc_32DE:                               ; ...
                sub     al, 20h ; ' '
                jnb     short loc_32E3
                retn
; ---------------------------------------------------------------------------

loc_32E3:                               ; ...
                jz      short loc_331E
                push    si
                push    di
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     ax, ax
                add     ax, ds:0F500h   ; bold_font_8x8
                mov     si, ax
                mov     cx, 8

loc_32F8:                               ; ...
                push    cx
                lodsb
                call    Expand_1bpp_To_2bpp
                mov     es:[di], dx
                call    Expand_1bpp_To_2bpp
                mov     es:[di+2], dx
                call    Expand_1bpp_To_2bpp
                mov     es:[di+4], dx
                call    Expand_1bpp_To_2bpp
                mov     es:[di+6], dx
                add     di, 320
                pop     cx
                loop    loc_32F8
                pop     di
                pop     si

loc_331E:                               ; ...
                add     di, 8
                jmp     short loc_32D8
Render_Text_String        endp


; =============== S U B R O U T I N E =======================================


; Convert 1bpp to 2bpp: takes low 2 bits of AL, expands each to full byte in DX
;   Input:
;     AL = 1bpp source byte (bits 0-1 used)
;   Output:
;     DH:DL = expanded 2bpp (each bit duplicated to byte)
;   Clobbers: AX, DX, flags
Expand_1bpp_To_2bpp        proc near
                add     al, al
                sbb     dl, dl
                add     al, al
                sbb     dh, dh
                retn
Expand_1bpp_To_2bpp        endp


; =============== S U B R O U T I N E =======================================


; Blit sprite to screen with AND/OR composite masking
;   Input:
;     CH = sprite height
;     CL = sprite width
;     BH = screen Y coordinate
;     BL = screen X coordinate / 160
Blit_Sprite_To_Screen        proc near
                push    ds
                push    cx
                push    bx
                mov     dl, 160
                mul     dl
                add     ax, ax
                add     ax, offset text_buffer
                mov     si, ax
                add     cl, bl
                mov     al, 160
                mul     cl
                add     ax, ax
                add     ax, 0
                push    ax
                push    si
                mov     ax, cs
                add     ax, 2000h
                mov     ds, ax          ; seg2
                assume ds:nothing
                push    ds
                pop     es
                assume es:nothing
                mov     di, 0
                mov     si, 320
                mov     cx, 7F60h
                rep movsw
                pop     si
                pop     di
                push    cs
                pop     ds
                assume ds:nothing
                mov     cx, 160
                rep movsw
                pop     bx
                push    bx
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     bx
                mov     al, 160
                mul     bl
                add     ax, ax
                mov     bl, bh
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                add     ax, bx
                mov     si, ax
                add     si, 0
                mov     ax, cs
                add     ax, 2000h
                mov     ds, ax          ; seg2
                assume ds:nothing
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                pop     cx
                mov     dx, 1001100110011001b
                mov     bp, 0110011001100110b
                xor     bx, bx
                mov     bl, ch
                add     bx, bx
                xor     ch, ch

loc_339C:                               ; ...
                push    cx
                push    di
                mov     cx, bx

loc_33A0:                               ; ...
                and     es:[di], dx
                lodsw
                and     ax, bp
                or      es:[di], ax
                inc     di
                inc     di
                loop    loc_33A0
                pop     di
                add     di, 320
                pop     cx
                loop    loc_339C
                pop     ds
                assume ds:nothing
                retn
Blit_Sprite_To_Screen        endp


; =============== S U B R O U T I N E =======================================


; Decompress 3-plane graphics and copy directly to VRAM
;   Input:
;     CH = height
;     CL = width
;     DI = source data pointer (DS:DI)
;     ES = destination segment (VRAM)
;     BH = screen Y
;     BL = screen X
Decompress_And_Copy_To_VRAM        proc near
                push    ds
                push    ax
                push    bx
                push    cx
                mov     al, ch
                mul     cl
                mov     bp, ax
                push    es
                pop     ds
                assume ds:nothing
                mov     si, di
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                assume es:nothing
                mov     di, 0
                mov     cs:decomp_plane3, 0
                mov     cx, bp
                shr     cx, 1

loc_33DA:                               ; ...
                add     bp, bp
                mov     ax, ds:[bp+si]
                xchg    ah, al
                mov     cs:decomp_plane2, ax
                shr     bp, 1
                mov     ax, ds:[bp+si]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_33DA
                pop     cx
                pop     bx
                pop     ax
                pop     ds
                assume ds:nothing

loc_340D:                               ; ...
                push    ds
                call    Calc_VRAM_Addr
                mov     di, ax
                mov     si, 0
                push    es
                pop     ds
                assume ds:nothing
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                xor     bx, bx
                mov     bl, ch
                add     bx, bx
                add     bx, bx
                xor     ch, ch

loc_3427:                               ; ...
                push    cx
                push    di
                mov     cx, bx
                rep movsb
                pop     di
                pop     cx
                add     di, 320
                loop    loc_3427
                pop     ds
                assume ds:nothing
                retn
Decompress_And_Copy_To_VRAM        endp


; =============== S U B R O U T I N E =======================================


; Animate 9 on-screen entities with frame-timer pacing
;   Input: none (uses entity data at VRAM A000:0000)
Animate_Sprites        proc near
                push    cs
                pop     es
                assume es:nothing
                mov     di, 0A000h
                xor     dx, dx
                mov     cx, 9

loc_3441:                               ; ...
                mov     al, 1
                stosb
                mov     ax, dx
                stosw
                movsw
                stosw
                mov     ax, 101h
                stosw
                movsb
                movsb
                xor     al, al
                stosb
                stosb
                movsb
                movsb
                add     dx, 300h
                loop    loc_3441
                mov     ds:plane_row, 0
                mov     byte ptr ds:frame_timer, 0

loc_3465:                               ; ...
                mov     si, 0A000h
                mov     cx, 9

loc_346B:                               ; ...
                push    cx
                test    byte ptr [si], 0FFh
                jz      short loc_34CD
                mov     al, [si+0Dh]
                cmp     al, [si+0Eh]
                jz      short loc_3485
                inc     byte ptr [si+0Ch]
                test    byte ptr [si+0Ch], 1
                jnz     short loc_3485
                inc     byte ptr [si+0Dh]

loc_3485:                               ; ...
                xor     bx, bx
                mov     bl, [si+0Dh]
                add     bx, bx
                add     bx, bx
                mov     cx, ds:word_3619[bx]
                mov     [si+7], cx
                mov     al, [si+4]
                add     al, [si+0Ah]
                mov     [si+4], al
                mov     bh, al
                mov     al, [si+3]
                add     al, [si+9]
                mov     [si+3], al
                mov     bl, al
                call    Calc_VRAM_Addr
                mov     [si+5], ax
                mov     di, ax
                mov     bp, [si+1]
                push    ds
                push    si
                mov     ax, 0A000h
                mov     ds, ax
                assume ds:nothing
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                assume es:nothing
                mov     si, di
                mov     di, bp
                call    Copy_VRAM_Block_Fwd
                pop     si
                pop     ds
                assume ds:nothing

loc_34CD:                               ; ...
                pop     cx
                add     si, 0Fh
                loop    loc_346B
                mov     si, 0A000h
                mov     cx, 9

loc_34D9:                               ; ...
                push    cx
                push    si
                mov     al, ds:plane_row
                and     al, 7
                mov     ah, 3
                mul     ah
                add     ax, offset byte_3637
                mov     si, ax
                lodsb
                mov     ds:byte_4289, al
                lodsb
                mov     ds:byte_428A, al
                lodsb
                mov     ds:byte_428B, al
                inc     ds:plane_row
                xor     ax, ax
                call    GDMCGA_Fade_To_Black
                pop     si
                test    byte ptr cs:[si], 0FFh
                jz      short loc_353E
                xor     bx, bx
                mov     bl, [si+0Dh]
                add     bx, bx
                add     bx, bx
                mov     bp, ds:word_3617[bx]
                mov     cx, [si+7]
                mov     dl, [si]
                mov     byte ptr [si], 0
                mov     ax, [si+3]
                cmp     ah, 4Bh ; 'K'
                jnb     short loc_353E
                cmp     al, 0A0h
                jnb     short loc_353E
                mov     [si], dl
                mov     di, [si+5]
                push    ds
                push    si
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     ds, word ptr cs:seg1
                mov     si, bp
                call    Blit_Masked_OR_From_Seg1
                pop     si
                pop     ds

loc_353E:                               ; ...
                pop     cx
                add     si, 0Fh
                loop    loc_34D9

loc_3544:                               ; ...
                cmp     byte ptr cs:frame_timer, 1Eh
                jb      short loc_3544
                mov     byte ptr cs:frame_timer, 0
                mov     si, 0A000h
                mov     cx, 9

loc_3558:                               ; ...
                push    cx
                mov     bp, [si+1]
                mov     di, [si+5]
                mov     cx, [si+7]
                push    ds
                push    si
                mov     ax, 0A000h
                mov     es, ax
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax          ; seg3
                assume ds:nothing
                mov     si, bp
                call    Copy_VRAM_Block_Rev
                pop     si
                pop     ds
                assume ds:nothing
                pop     cx
                add     si, 0Fh
                loop    loc_3558
                mov     si, 0A000h
                mov     cx, 9

loc_3583:                               ; ...
                test    byte ptr [si], 0FFh
                jz      short loc_358B
                jmp     loc_3465
; ---------------------------------------------------------------------------

loc_358B:                               ; ...
                add     si, 0Fh
                loop    loc_3583
                mov     ax, 2
                jmp     GDMCGA_Fade_To_Black
Animate_Sprites        endp


; =============== S U B R O U T I N E =======================================


; Copy a rectangular block forward within VRAM (SI source → DI dest, 8 rows tall)
;   Input:
;     SI = source VRAM address
;     DI = dest VRAM address
;     CH = width in pixels
;   Output: SI, DI unchanged
;   Clobbers: AX, CX, flags
Copy_VRAM_Block_Fwd        proc near
                push    si
                push    cx

loc_3598:                               ; ...
                push    si
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                rep movsb
                pop     cx
                pop     si
                add     si, 320
                dec     cl
                jnz     short loc_3598
                pop     cx
                pop     si
                retn
Copy_VRAM_Block_Fwd        endp


; =============== S U B R O U T I N E =======================================


; Copy a rectangular block within VRAM with DI as outer loop (reverse direction restore)
;   Input:
;     SI = source VRAM address
;     DI = dest VRAM address
;     CH = width in pixels
;   Output: SI unchanged, DI advanced by rows
;   Clobbers: AX, CX, DI, flags
Copy_VRAM_Block_Rev        proc near
                push    di
                push    cx

loc_35B3:                               ; ...
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                rep movsb
                pop     cx
                pop     di
                add     di, 320
                dec     cl
                jnz     short loc_35B3
                pop     cx
                pop     di
                retn
Copy_VRAM_Block_Rev        endp


; =============== S U B R O U T I N E =======================================


; Read 3 planes from seg1 source, decompress, OR onto VRAM
;   Input:
;     CH = height
;     CL = width
;     SI = source data offset in seg1
;     BX = row stride within source
;     DI = dest VRAM address
;   Clobbers: AX, BX, CX, SI, DI, flags
Blit_Masked_OR_From_Seg1        proc near
                push    di
                push    cx
                mov     al, ch
                mul     cl
                mov     bx, ax
                mov     cs:decomp_plane3, 0

loc_35DB:                               ; ...
                push    di
                push    cx
                mov     cl, ch
                xor     ch, ch

loc_35E1:                               ; ...
                xor     al, al
                mov     ah, [bx+si]
                mov     cs:decomp_plane1, ax
                mov     ah, [si]
                mov     cs:decomp_plane0, ax
                mov     cs:decomp_plane2, ax
                inc     si
                push    bx
                call    Decompress_3Plane_To_2bpp
                pop     bx
                or      es:[di], ax
                push    bx
                call    Decompress_3Plane_To_2bpp
                pop     bx
                or      es:[di+2], ax
                add     di, 4
                loop    loc_35E1
                pop     cx
                pop     di
                add     di, 320
                dec     cl
                jnz     short loc_35DB
                pop     cx
                pop     di
                retn
Blit_Masked_OR_From_Seg1        endp

; ---------------------------------------------------------------------------
word_3617       dw 9000h                ; ...
word_3619       dw 620h                 ; ...
                db  80h
                db  91h
                db  20h
                db    6
                db    0
                db  93h
                db  20h
                db    6
                db  80h
                db  94h
                db  20h
                db    6
                db    0
                db  96h
                db  18h
                db    4
                db 0C0h
                db  96h
                db  18h
                db    4
                db  80h
                db  97h
                db  18h
                db    4
                db  40h ; @
                db  98h
                db  18h
                db    4
byte_3637       db 1Fh, 1Fh, 0, 0Fh, 0Fh, 0, 1Fh, 1Fh, 1Fh, 0Fh, 0Fh, 0Fh ; ...
                db 1Fh, 0, 1Fh, 0Fh, 0, 0Fh, 1Fh, 0, 0, 0Fh, 0, 0

; =============== S U B R O U T I N E =======================================


; Load and render tiles from large block (seg1+0AB40h, 0x330 tiles)
;   Input:
;     AL = tile index (0-based)
Load_Tiles_From_Big_Block        proc near
                push    ds
                push    bx
                xor     ah, ah
                mov     dx, 0CC0h
                mul     dx
                add     ax, 0AB40h
                mov     ds, word ptr cs:seg1
                mov     si, ax
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                assume es:nothing
                mov     di, 0
                mov     cs:decomp_plane3, 0
                mov     cs:decomp_plane2, 0
                mov     cx, 330h

loc_367D:                               ; ...
                mov     ax, [si+660h]
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_367D
                pop     bx
                pop     ds
                mov     di, 0
                mov     cx, 2230h
                jmp     loc_340D
Load_Tiles_From_Big_Block        endp


; =============== S U B R O U T I N E =======================================


; Load and render tiles from small block (seg1+097C0h, 0x120 tiles)
;   Input:
;     AL = tile index (0-based)
Load_Tiles_From_Small_Block        proc near
                push    ds
                push    bx
                xor     ah, ah
                mov     dx, 480h
                mul     dx
                add     ax, 97C0h
                mov     ds, word ptr cs:seg1
                mov     si, ax
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax
                mov     di, 0
                mov     cs:decomp_plane3, 0
                mov     cs:decomp_plane2, 0
                mov     cx, 120h

loc_36D9:                               ; ...
                mov     ax, [si+240h]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_36D9
                pop     bx
                pop     ds
                mov     di, 0
                mov     cx, 1220h
                jmp     loc_340D
Load_Tiles_From_Small_Block        endp


; =============== S U B R O U T I N E =======================================


; Fill viewport with alternating pattern (0x1000/0x0010 per row pair)
;   Input: none
GDMCGA_Clear_Viewport        proc near
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                xor     di, di
                mov     cx, 100

loc_3711:                               ; ...
                push    cx
                push    di
                mov     ax, 1000h
                mov     cx, 160
                rep stosw
                pop     di
                add     di, 320
                push    di
                mov     ax, 10h
                mov     cx, 160
                rep stosw
                pop     di
                add     di, 320
                pop     cx
                loop    loc_3711
                retn
GDMCGA_Clear_Viewport        endp


; =============== S U B R O U T I N E =======================================


; Render 22x19 tile grid of character glyphs to viewport
;   Input:
;     SI = pointer to tile grid data (22x19 byte array)
Render_Tile_Grid        proc near
                xor     bx, bx
                mov     cx, 19h

loc_3737:                               ; ...
                push    cx
                mov     cx, 22h ; '"'

loc_373B:                               ; ...
                push    cx
                lodsb
                push    bx
                push    ds
                push    si
                call    Render_Font_Glyph_8x8
                pop     si
                pop     ds
                pop     bx
                inc     bh
                pop     cx
                loop    loc_373B
                xor     bh, bh
                inc     bl
                pop     cx
                loop    loc_3737
                retn
Render_Tile_Grid        endp


; =============== S U B R O U T I N E =======================================


; Render a single 8x8 character glyph to screen coordinates
;   Input:
;     AL = ASCII character code
;     BX = screen X,Y (BH=row, BL=col in tiles, each tile 18x22 pixels)
;     SI = font glyph data base in seg1 (bold_font_8x8)
;   Output: glyph rendered to VRAM via seg2 buffer
;   Clobbers: AX, BX, CX, DX, SI, DI, DS, ES
Render_Font_Glyph_8x8        proc near
                mov     ds, word ptr cs:seg1
                mov     dx, cs
                add     dx, 2000h
                mov     es, dx          ; seg2
                assume es:nothing
                xor     ah, ah

loc_3762:                               ; ...
                sub     al, 28h ; '('
                jb      short loc_376A
                inc     ah
                jmp     short loc_3762
; ---------------------------------------------------------------------------

loc_376A:                               ; ...
                add     al, 28h ; '('
                mov     cl, al
                mov     al, ah
                xor     ah, ah
                mov     dx, 320
                mul     dx
                xor     ch, ch
                add     ax, cx
                add     ax, 4000h
                push    ax
                mov     dx, bx
                xor     dh, dh
                mov     ax, 110h
                mul     dx
                mov     dl, bh
                xor     dh, dh
                add     ax, dx
                add     ax, 0
                mov     di, ax
                pop     si
                mov     cx, 3

loc_3797:                               ; ...
                push    cx
                push    di
                push    si
                mov     cx, 8

loc_379D:                               ; ...
                movsb
                add     di, 33
                add     si, 39
                loop    loc_379D
                pop     si
                pop     di
                add     di, 1A90h
                add     si, 640h
                pop     cx
                loop    loc_3797
                retn
Render_Font_Glyph_8x8        endp


; =============== S U B R O U T I N E =======================================


; Blit sprite with AND/OR/XOR composite masking (2-pass: top-down then bottom-up)
;   Input:
;     CH = height
;     CL = width
;     BH = screen Y
;     BL = screen X
;     SI = source sprite pointer (seg1)
;     DI = dest VRAM address
Blit_And_Or_Xor_Masked        proc near
                push    ds
                mov     dx, cs
                mov     es, dx
                assume es:nothing
                add     dx, 2000h
                mov     ds, dx          ; seg2
                assume ds:nothing
                push    ax
                mov     dl, 22h ; '"'
                mul     dl
                add     ax, 0
                mov     si, ax
                push    si
                mov     di, 5191h
                mov     cx, 22h ; '"'
                rep movsb
                add     si, 1A6Eh
                mov     cx, 22h ; '"'
                rep movsb
                mov     di, 5191h
                mov     cx, 44h ; 'D'

loc_37E1:                               ; ...
                mov     al, es:[di]
                mov     dx, 8

loc_37E7:                               ; ...
                ror     al, 1
                adc     ah, ah
                dec     dx
                jnz     short loc_37E7
                mov     es:[di], ah
                inc     di
                loop    loc_37E1
                pop     si
                pop     ax
                mov     bl, al
                xor     bh, bh
                call    Calc_VRAM_Addr
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                push    di
                mov     cx, 11h

loc_3808:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                mov     bx, [si+1A8Eh]
                xchg    bh, bl
                mov     dx, ax
                and     dx, bx
                mov     cs:decomp_plane0, dx
                or      dx, bx
                mov     cs:decomp_plane1, dx
                mov     cs:decomp_plane2, dx
                mov     cs:decomp_plane3, dx
                or      ax, bx
                not     ax
                mov     cs:and_mask_val, ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+2], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+2], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+4], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+4], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+6], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+6], ax
                add     di, 8
                pop     cx
                loop    loc_3808
                pop     di
                add     di, 312
                push    cs
                pop     ds
                assume ds:nothing
                mov     si, 5191h
                mov     cx, 11h

loc_387D:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                mov     bx, [si+20h]
                xchg    bh, bl
                mov     dx, ax
                and     dx, bx
                mov     cs:decomp_plane0, dx
                or      dx, bx
                mov     cs:decomp_plane1, dx
                mov     cs:decomp_plane2, dx
                mov     cs:decomp_plane3, dx
                or      ax, bx
                not     ax
                mov     cs:and_mask_val, ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+4], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+4], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+6], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+6], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di], ax
                call    Generate_AND_Mask_From_2bpp
                and     es:[di+2], ax
                call    Decompress_3Plane_To_2bpp
                or      es:[di+2], ax
                sub     di, 8
                pop     cx
                loop    loc_387D
                pop     ds
                retn
Blit_And_Or_Xor_Masked        endp


; =============== S U B R O U T I N E =======================================


; Render scrolling border/frame animation with frame-timer pacing
;   Input:
;     DI = VRAM start address
;     SI = pointer to border pattern data table
Render_Scrolling_Border        proc near
                mov     bx, ax
                add     bx, bx
                mov     al, ds:byte_3C16[bx]
                mov     ds:plane_group, al
                mov     al, ds:byte_3C17[bx]
                mov     ds:plane_row, al
                mov     ax, 0A000h
                mov     es, ax
                mov     di, 1410h
                mov     si, offset byte_3B1F

loc_3903:                               ; ...
                lodsb
                or      al, al
                jz      short loc_3911
                call    Render_Scrolling_Border_Row
                add     di, 500h
                jmp     short loc_3903
; ---------------------------------------------------------------------------

loc_3911:                               ; ...
                add     di, 0FB04h

loc_3915:                               ; ...
                lodsb
                or      al, al
                jz      short loc_3922
                call    Render_Scrolling_Border_Row
                add     di, 4
                jmp     short loc_3915
; ---------------------------------------------------------------------------

loc_3922:                               ; ...
                add     di, 0FAFCh

loc_3926:                               ; ...
                lodsb
                or      al, al
                jz      short loc_3934
                call    Render_Scrolling_Border_Row
                add     di, 0FB00h
                jmp     short loc_3926
; ---------------------------------------------------------------------------

loc_3934:                               ; ...
                add     di, 4FCh

loc_3938:                               ; ...
                lodsb
                or      al, al
                jz      short loc_3945
                call    Render_Scrolling_Border_Row
                sub     di, 4
                jmp     short loc_3938
; ---------------------------------------------------------------------------

loc_3945:                               ; ...
                add     di, 504h
                mov     si, offset word_3BE3

loc_394C:                               ; ...
                mov     byte ptr cs:frame_timer, 0
                lodsb
                or      al, al
                jnz     short loc_3958
                retn
; ---------------------------------------------------------------------------

loc_3958:                               ; ...
                xor     cx, cx
                mov     cl, al

loc_395C:                               ; ...
                push    cx
                mov     al, 18h
                call    Render_Scrolling_Border_Row
                add     di, 500h
                pop     cx
                loop    loc_395C
                add     di, 0FB00h
                lodsb
                or      al, al
                jnz     short loc_3973
                retn
; ---------------------------------------------------------------------------

loc_3973:                               ; ...
                xor     cx, cx
                mov     cl, al

loc_3977:                               ; ...
                push    cx
                mov     al, 18h
                call    Render_Scrolling_Border_Row
                add     di, 4
                pop     cx
                loop    loc_3977
                sub     di, 4
                lodsb
                or      al, al
                jnz     short loc_398C
                retn
; ---------------------------------------------------------------------------

loc_398C:                               ; ...
                xor     cx, cx
                mov     cl, al

loc_3990:                               ; ...
                push    cx
                mov     al, 18h
                call    Render_Scrolling_Border_Row
                add     di, 0FB00h
                pop     cx
                loop    loc_3990
                add     di, 500h
                lodsb
                or      al, al
                jnz     short loc_39A7
                retn
; ---------------------------------------------------------------------------

loc_39A7:                               ; ...
                xor     cx, cx
                mov     cl, al

loc_39AB:                               ; ...
                push    cx
                mov     al, 18h
                call    Render_Scrolling_Border_Row
                sub     di, 4
                pop     cx
                loop    loc_39AB
                add     di, 4

loc_39BA:                               ; ...
                cmp     byte ptr cs:frame_timer, 0Ch
                jb      short loc_39BA
                jmp     short loc_394C
Render_Scrolling_Border        endp


; =============== S U B R O U T I N E =======================================


; Render a single scrolling border row with composite plane blending
;   Input:
;     AL = row index into border pattern table
;     DI = VRAM destination
;   Clobbers: AX, BX, SI, DI, DS, flags
Render_Scrolling_Border_Row        proc near
                push    si
                dec     al
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     ax, ax
                add     ax, offset byte_3A5F
                mov     si, ax
                push    di
                mov     bh, cs:plane_row
                call    Render_Border_Row_Composite
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                add     di, 316
                mov     bh, cs:plane_row
                ror     bh, 1
                call    Render_Border_Row_Composite
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                add     di, 316
                mov     bh, cs:plane_row
                call    Render_Border_Row_Composite
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                add     di, 316
                mov     bh, cs:plane_row
                ror     bh, 1
                call    Render_Border_Row_Composite
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                pop     di
                pop     si
                retn
Render_Scrolling_Border_Row        endp


; =============== S U B R O U T I N E =======================================


; Composite border row with plane blending for scrolling border
;   Input:
;     SI = border pattern data pointer
;     BH = plane_row (for bit masking)
;     plane_group = animation direction/phase
;   Output:
;     decomp_plane0..3 = blended plane data
;   Clobbers: AX, SI, flags
Render_Border_Row_Composite        proc near
                mov     ds:decomp_plane0, 0
                mov     ds:decomp_plane3, 0
                mov     ah, [si+4]
                mov     ds:decomp_plane2, ax
                mov     ds:decomp_plane1, ax
                lodsb
                and     al, bh
                mov     ah, al
                mov     al, ds:plane_group
                shr     al, 1
                jnb     short loc_3A4D
                or      ds:decomp_plane0, ax

loc_3A4D:                               ; ...
                shr     al, 1
                jnb     short loc_3A55
                or      ds:decomp_plane1, ax

loc_3A55:                               ; ...
                shr     al, 1
                jb      short loc_3A5A
                retn
; ---------------------------------------------------------------------------

loc_3A5A:                               ; ...
                or      ds:decomp_plane2, ax
                retn
Render_Border_Row_Composite        endp

; ---------------------------------------------------------------------------
byte_3A5F       db 0, 0, 0, 3, 80h, 80h, 85h, 84h, 3, 3, 3, 3, 84h, 84h ; ...
                db 84h, 84h, 3, 3, 3, 3, 84h, 84h, 84h, 0D4h, 0, 0, 0
                db 0FFh, 0, 0, 55h, 0, 0, 0, 1, 0FFh, 2, 2, 56h, 0, 0
                db 0, 0, 0FFh, 40h, 40h, 55h, 0, 0, 0, 0, 0C0h, 1, 1, 61h
                db 21h, 0C0h, 0C0h, 0C0h, 0C0h, 21h, 21h, 21h, 21h, 0C0h
                db 0C0h, 0C0h, 0C0h, 21h, 21h, 21h, 21h, 0C0h, 0E0h, 0E0h
                db 0E0h, 2Bh, 1, 1, 1, 3, 3, 3, 3, 0D4h, 84h, 84h, 84h
                db 3, 3, 3, 3, 84h, 84h, 84h, 84h, 3, 2, 0, 0, 84h, 85h
                db 80h, 80h, 0FFh, 0AAh, 0, 0, 0, 55h, 0, 0, 0FFh, 0A8h
                db 0, 0, 0, 56h, 2, 2, 0FFh, 0FFh, 0, 0, 0, 55h, 40h, 40h
                db 0C0h, 0C0h, 0C0h, 0C0h, 2Bh, 21h, 21h, 21h, 0C0h, 0C0h
                db 0C0h, 0C0h, 21h, 21h, 21h, 21h, 0C0h, 80h, 0, 0, 21h
                db 61h, 1, 1, 0, 0, 0FFh, 0FFh, 0, 0, 0, 0, 0FFh, 0FFh
                db 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 80h, 80h, 80h, 80h, 0E0h
                db 0E0h, 0E0h, 0E0h, 1, 1, 1, 1, 0FFh, 0FFh, 0FFh, 0FFh
                db 0, 0, 0, 0
byte_3B1F       db 1, 2, 3, 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h ; ...
                db 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h, 16h
                db 0Bh, 0Ch, 0Dh, 0, 0Eh, 0Fh, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
                db 15h, 15h, 15h, 15h, 15h, 15h, 10h, 0Eh, 13h, 0, 12h
                db 11h, 17h, 17h, 17h, 17h, 17h, 17h, 17h, 17h, 17h, 17h
                db 17h, 17h, 17h, 17h, 17h, 17h, 17h, 17h, 17h, 0Ah, 9
                db 8, 7, 0, 4, 6, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h, 14h
                db 14h, 14h, 14h, 5, 4, 0
word_3BE3       dw 4618h                ; ...
                dw 4518h
                dw 4417h
                dw 4316h
                dw 4215h
                dw 4114h
                dw 4013h
                dw 3F12h
                dw 3E11h
                dw 3D10h
                dw 3C0Fh
                dw 3B0Eh
                dw 3A0Dh
                dw 390Ch
                dw 380Bh
                dw 370Ah
                dw 3609h
                dw 3508h
                dw 3407h
                dw 3306h
                dw 3205h
                dw 3104h
                dw 3003h
                dw 2F02h
                dw 2E01h
                db    0
byte_3C16       db 2                    ; ...
byte_3C17       db 55h                  ; ...
                db    3
                db 0FFh
                db    1
                db  55h ; U

; =============== S U B R O U T I N E =======================================


; Render animated tiles with selective plane loading and frame-timer pacing
;   Input:
;     AL = plane-select bitfield (bits 0,1,2 for planes 0,1,2)
;     BX = tile width in bytes
;     CX = tile count
;     SI = source data pointer
Render_Animated_Tiles        proc near
                push    ds
                mov     cs:render_mode, al
                push    bx
                push    cx
                mov     al, ch
                mul     cl
                mov     bp, ax
                push    es
                pop     ds
                assume ds:nothing
                mov     si, di
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                assume es:nothing
                mov     di, 0
                mov     cs:decomp_plane3, 0
                mov     cs:decomp_plane0, 0
                mov     cs:decomp_plane1, 0
                mov     cs:decomp_plane2, 0
                mov     cx, bp
                shr     cx, 1

loc_3C57:                               ; ...
                push    si
                test    cs:render_mode, 1
                jz      short loc_3C6A
                mov     ax, [si]
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                add     si, bp

loc_3C6A:                               ; ...
                test    cs:render_mode, 2
                jz      short loc_3C7C
                mov     ax, [si]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                add     si, bp

loc_3C7C:                               ; ...
                test    cs:render_mode, 4
                jz      short loc_3C8C
                mov     ax, [si]
                xchg    ah, al
                mov     cs:decomp_plane2, ax

loc_3C8C:                               ; ...
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                pop     si
                inc     si
                inc     si
                loop    loc_3C57
                pop     cx
                pop     bx
                sub     bx, 410h
                mov     cs:plane_group, 0
                mov     cs:anim_frame, 0
                mov     cs:render_callback, cx
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax          ; seg3
                assume ds:nothing
                mov     si, 0
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     cx, 8

loc_3CCA:                               ; ...
                push    cx
                mov     al, cs:anim_frame
                mov     cs:plane_group, al
                mov     byte ptr cs:frame_timer, 0
                mov     cx, 0Dh

loc_3CDC:                               ; ...
                push    cx
                push    bx
                push    si
                call    Render_Anim_Tile_Row
                pop     si
                pop     bx
                pop     cx
                add     cs:plane_group, 8
                loop    loc_3CDC
                pop     cx

loc_3CEE:                               ; ...
                cmp     byte ptr cs:frame_timer, 20
                jb      short loc_3CEE
                inc     cs:anim_frame
                loop    loc_3CCA
                pop     ds
                assume ds:nothing
                retn
Render_Animated_Tiles        endp


; =============== S U B R O U T I N E =======================================


; Render a single animated tile row with partial plane selection
;   Input:
;     SI = source data pointer
;     render_callback = tile width info
;   Clobbers: AX, BX, CX, SI, DI, DS, ES, flags
Render_Anim_Tile_Row        proc near
                push    bx
                mov     bl, cs:plane_group
                add     bl, 10h
                mov     bh, 4
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     bx
                cmp     cs:plane_group, bl
                jb      short loc_3D71
                mov     al, bl
                add     al, byte ptr cs:render_callback
                cmp     cs:plane_group, al
                jnb     short loc_3D71
                mov     al, cs:plane_group
                sub     al, bl
                mul     byte ptr cs:render_callback+1
                add     ax, ax
                add     ax, ax
                add     si, ax
                mov     cs:plane_row, 0
                mov     cx, 48h ; 'H'

loc_3D3F:                               ; ...
                push    cx
                mov     word ptr es:[di], 0
                mov     word ptr es:[di+2], 0
                cmp     cs:plane_row, bh
                jb      short loc_3D65
                mov     al, bh
                add     al, byte ptr cs:render_callback+1
                cmp     cs:plane_row, al
                jnb     short loc_3D65
                movsw
                movsw
                sub     di, 4

loc_3D65:                               ; ...
                add     di, 4
                inc     cs:plane_row
                pop     cx
                loop    loc_3D3F
                retn
; ---------------------------------------------------------------------------

loc_3D71:                               ; ...
                mov     cx, 90h
                xor     ax, ax
                rep stosw
                retn
Render_Anim_Tile_Row        endp


; =============== S U B R O U T I N E =======================================


; Draw bordered rectangle with 0xFF border and 0x00 fill
;   Input:
;     BX = inner width
;     CX = inner height
;     DI = VRAM start address
GDMCGA_Draw_Bordered_Rect        proc near
                mov     cs:plane_group, bl
                call    Calc_VRAM_Addr
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     bl, ch
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                sub     bx, 4
                xor     ch, ch
                sub     cx, 5
                push    cx
                push    di
                call    Draw_BorderedRect_TopRow
                pop     di
                inc     cs:plane_group
                add     di, 320
                mov     cx, 2
                call    Draw_BorderedRect_SideRows
                pop     cx

loc_3DAE:                               ; ...
                push    cx
                call    Draw_BorderedRect_Corner
                mov     byte ptr es:[di], 0FFh
                mov     byte ptr es:[di+1], 0
                mov     byte ptr es:[di+2], 0
                mov     byte ptr es:[di+3], 0
                or      byte ptr es:[bx+di+3], 0FFh
                mov     byte ptr es:[bx+di+2], 0
                mov     byte ptr es:[bx+di+1], 0
                mov     byte ptr es:[bx+di], 0
                inc     cs:plane_group
                add     di, 140h
                pop     cx
                loop    loc_3DAE
                mov     cx, 1
                call    Draw_BorderedRect_SideRows
GDMCGA_Draw_Bordered_Rect        endp


; =============== S U B R O U T I N E =======================================


; Fill top border row with 0xFF (white border line)
;   Input:
;     DI = VRAM start address
;     BX = inner width
;   Clobbers: AX, CX, DI, flags
Draw_BorderedRect_TopRow        proc near
                call    Draw_BorderedRect_Corner
                mov     cx, bx
                add     cx, 4
                mov     al, 0FFh
                rep stosb
                retn
Draw_BorderedRect_TopRow        endp


; =============== S U B R O U T I N E =======================================


; Fill left/right border columns and clear interior (recursive per row)
;   Input:
;     DI = VRAM start address
;     BX = inner width
;     CX = row count remaining
;   Clobbers: AX, CX, DI, flags
Draw_BorderedRect_SideRows        proc near
                push    cx
                push    di
                call    Draw_BorderedRect_Corner
                mov     byte ptr es:[di], 0FFh
                inc     di
                mov     cx, bx
                add     cx, 2
                xor     al, al
                rep stosb
                mov     byte ptr es:[di], 0FFh
                pop     di
                inc     cs:plane_group
                add     di, 320
                pop     cx
                loop    Draw_BorderedRect_SideRows
                retn
Draw_BorderedRect_SideRows        endp


; =============== S U B R O U T I N E =======================================


; Write corner decoration pattern (0x0202 words) for bordered rectangle
;   Input:
;     DI = VRAM address (corners at di-7..di-1)
;   Clobbers: flags
Draw_BorderedRect_Corner        proc near
                mov     word ptr es:[di-7], 202h
                mov     word ptr es:[di-5], 202h
                mov     word ptr es:[di-3], 202h
                mov     word ptr es:[di-1], 202h
                retn
Draw_BorderedRect_Corner        endp


; =============== S U B R O U T I N E =======================================


; Pack 3-plane decompressed data and render to VRAM (jump to Decompress_And_Copy_To_VRAM)
;   Input:
;     DI = VRAM offset
;     ES = destination segment
Pack_3Plane_And_Render        proc near
                push    bx
                push    es
                push    di
                mov     cx, 1028h

loc_3E3B:                               ; ...
                mov     al, es:[di]
                and     al, es:[di+1028h]
                mov     ah, es:[di+2050h]
                not     ah
                and     al, ah
                not     al
                and     es:[di], al
                and     es:[di+1028h], al
                and     es:[di+2050h], al
                mov     al, es:[di+2050h]
                mov     ah, es:[di]
                not     ah
                and     al, ah
                mov     ah, es:[di+1028h]
                not     ah
                and     al, ah
                or      es:[di], al
                or      es:[di+1028h], al
                not     al
                and     es:[di+2050h], al
                inc     di
                loop    loc_3E3B
                pop     di
                pop     es
                assume es:nothing
                pop     bx
                mov     cx, 2F58h
                jmp     Decompress_And_Copy_To_VRAM
Pack_3Plane_And_Render        endp


; =============== S U B R O U T I N E =======================================


; Render animated tile rows with frame-timer pacing (dual-row)
;   Input:
;     DI = VRAM offset
;     ES = source segment
Render_Animated_Tile_Rows        proc near
                push    ds
                mov     ds:src_offset, di
                mov     ds:src_segment, es
                mov     di, 69Ah
                add     di, ds:src_offset
                call    Setup_HUD_Frame
                mov     di, 6BCh
                add     di, ds:src_offset
                call    Setup_HUD_Frame
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     ds, cs:src_segment
                mov     cx, 44h ; 'D'

loc_3EB5:                               ; ...
                push    cx
                mov     byte ptr cs:frame_timer, 0
                mov     ax, 44h ; 'D'
                sub     ax, cx
                add     ax, ax
                push    ax
                mov     bl, al
                mov     al, 50h ; 'P'
                mul     bl
                push    ax
                mov     bh, 0
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     ax
                add     ax, cs:src_offset
                mov     si, ax
                pop     ax
                cmp     ax, 16h
                jb      short loc_3EEA
                cmp     ax, 71h ; 'q'
                jnb     short loc_3EEA
                call    Render_Partial_Width_Tile
                jmp     short loc_3EED
; ---------------------------------------------------------------------------

loc_3EEA:                               ; ...
                call    Decompress_And_Render_Tile

loc_3EED:                               ; ...
                pop     cx
                push    cx
                mov     ax, cx
                add     ax, ax
                dec     ax
                push    ax
                mov     bl, al
                mov     al, 50h ; 'P'
                mul     bl
                push    ax
                mov     bh, 0
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     ax
                add     ax, cs:src_offset
                mov     si, ax
                pop     ax
                cmp     ax, 16h
                jb      short loc_3F1B
                cmp     ax, 71h ; 'q'
                jnb     short loc_3F1B
                call    Render_Partial_Width_Tile
                jmp     short loc_3F1E
; ---------------------------------------------------------------------------

loc_3F1B:                               ; ...
                call    Decompress_And_Render_Tile

loc_3F1E:                               ; ...
                cmp     byte ptr cs:frame_timer, 4
                jb      short loc_3F1E
                pop     cx
                loop    loc_3EB5
                pop     ds
                retn
Render_Animated_Tile_Rows        endp


; =============== S U B R O U T I N E =======================================


; Decompress 3 planes from seg1 offsets and render full-width tile to VRAM
;   Input:
;     SI = base data offset in seg1
;     DI = dest VRAM address
;   Clobbers: AX, CX, SI, DI, flags
Decompress_And_Render_Tile        proc near
                mov     cx, 28h ; '('
                mov     cs:decomp_plane3, 0

loc_3F35:                               ; ...
                mov     ax, [si+5500h]
                xchg    ah, al
                mov     cs:decomp_plane2, ax
                mov     ax, [si+2A80h]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_3F35
                retn
Decompress_And_Render_Tile        endp


; =============== S U B R O U T I N E =======================================


; Decompress and render partial-width tile (variable widths: 0x0B/0x05/0x0B)
;   Input:
;     SI = base data offset in seg1
;     DI = dest VRAM address
;   Clobbers: AX, CX, SI, DI, flags
Render_Partial_Width_Tile        proc near
                mov     cx, 0Bh
                mov     cs:decomp_plane3, 0

loc_3F6D:                               ; ...
                mov     ah, [si+5500h]
                mov     cs:decomp_plane2, ax
                mov     ah, [si+2A80h]
                mov     cs:decomp_plane1, ax
                lodsb
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_3F6D
                add     si, 18h
                add     di, 60h ; '`'
                mov     cx, 5

loc_3F97:                               ; ...
                mov     ax, [si+5500h]
                xchg    ah, al
                mov     cs:decomp_plane2, ax
                mov     ax, [si+2A80h]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_3F97
                add     si, 18h
                add     di, 60h ; '`'
                mov     cx, 0Bh

loc_3FCD:                               ; ...
                mov     ah, [si+5500h]
                mov     cs:decomp_plane2, ax
                mov     ah, [si+2A80h]
                mov     cs:decomp_plane1, ax
                lodsb
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_3FCD
                retn
Render_Partial_Width_Tile        endp


; =============== S U B R O U T I N E =======================================


; Initialize HUD frame structures in VRAM (top/bottom bars, side columns)
;   Input:
;     DI = VRAM offset base
;     ES = VRAM segment (0A000h)
;   Clobbers: AX, CX, DI, flags
Setup_HUD_Frame        proc near
                push    di
                mov     ax, 0FC3Fh
                call    Write_VRAM_HLine
                add     di, 36h ; '6'
                mov     cx, 5Bh ; '['

loc_3FFC:                               ; ...
                mov     byte ptr es:[di], 30h ; '0'
                mov     byte ptr es:[di+19h], 0Ch
                add     di, 50h ; 'P'
                loop    loc_3FFC
                mov     ax, 0FC3Fh
                call    Write_VRAM_HLine
                pop     di
                add     di, 2A80h
                push    di
                mov     ax, 0FD7Fh
                call    Write_VRAM_HLine
                add     di, 36h ; '6'
                mov     cx, 2Dh ; '-'

loc_4022:                               ; ...
                mov     byte ptr es:[di], 0B0h
                mov     byte ptr es:[di+19h], 0Eh
                add     di, 50h ; 'P'
                mov     byte ptr es:[di], 70h ; 'p'
                mov     byte ptr es:[di+19h], 0Dh
                add     di, 50h ; 'P'
                loop    loc_4022
                mov     byte ptr es:[di], 0B0h
                mov     byte ptr es:[di+19h], 0Eh
                add     di, 50h ; 'P'
                mov     ax, 0FD7Fh
                call    Write_VRAM_HLine
                pop     di
                add     di, 2A80h
                mov     ax, 0FC3Fh
                call    Write_VRAM_HLine
                add     di, 36h ; '6'
                mov     cx, 5Bh ; '['

loc_405F:                               ; ...
                mov     byte ptr es:[di], 30h ; '0'
                mov     byte ptr es:[di+19h], 0Ch
                add     di, 50h ; 'P'
                loop    loc_405F
                mov     ax, 0FC3Fh
                call    Write_VRAM_HLine
                retn
Setup_HUD_Frame        endp


; =============== S U B R O U T I N E =======================================


; Write a single horizontal line: 1 byte + 0xFF x 24 + 1 byte pattern
;   Input:
;     DI = VRAM destination
;     AH = end byte value
;   Clobbers: AL, CX, DI, flags
Write_VRAM_HLine        proc near
                stosb
                mov     al, 0FFh
                mov     cx, 18h
                rep stosb
                mov     al, ah
                stosb
                retn
Write_VRAM_HLine        endp


; =============== S U B R O U T I N E =======================================


; Render tile rows top-down with frame-timer pacing
;   Input:
;     DI = VRAM offset
;     ES = source segment
Render_Tile_Rows_TopDown        proc near
                push    ds
                mov     ds:src_offset, di
                mov     ds:src_segment, es
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, cs:src_segment
                mov     cx, 39h ; '9'

loc_4096:                               ; ...
                mov     byte ptr cs:frame_timer, 0
                push    cx
                mov     ax, cx
                neg     ax
                add     ax, 39h ; '9'
                add     ax, ax
                call    Render_TileRow_TopDown
                pop     ax
                push    ax
                add     ax, ax
                dec     ax
                call    Render_TileRow_TopDown

loc_40B1:                               ; ...
                cmp     byte ptr cs:frame_timer, 4
                jb      short loc_40B1
                pop     cx
                loop    loc_4096
                pop     ds
                retn
Render_Tile_Rows_TopDown        endp


; =============== S U B R O U T I N E =======================================


; Render single-row tile data top-down with width variation by row index
;   Input:
;     AL = row index (0-based)
;     DI = source data offset base
;     SI computed from src_offset + row * 0x2F
;   Output: rendered to VRAM via Calc_VRAM_Addr
;   Clobbers: AX, BX, CX, SI, DI, flags
Render_TileRow_TopDown        proc near
                push    ax
                mov     bl, al
                mov     al, 2Fh ; '/'
                mul     bl
                add     ax, cs:src_offset
                mov     si, ax
                xor     bh, bh
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     ax
                cmp     ax, 14h
                jnb     short loc_40DE
                mov     cx, 2Fh ; '/'
                jmp     short loc_40EE
; ---------------------------------------------------------------------------

loc_40DE:                               ; ...
                mov     cx, 23h ; '#'
                cmp     ax, 17h
                jb      short loc_40EE
                cmp     ax, 1Ch
                jb      short loc_4117
                mov     cx, 21h ; '!'

loc_40EE:                               ; ...
                mov     cs:decomp_plane3, 0

loc_40F5:                               ; ...
                mov     ah, [si+29DCh]
                mov     cs:decomp_plane2, ax
                mov     ah, [si+14EEh]
                mov     cs:decomp_plane1, ax
                lodsb
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_40F5
                retn
; ---------------------------------------------------------------------------

loc_4117:                               ; ...
                mov     cx, 21h ; '!'
                mov     cs:decomp_plane3, 0

loc_4121:                               ; ...
                mov     ah, [si+29DCh]
                mov     cs:decomp_plane2, ax
                mov     ah, [si+14EEh]
                mov     cs:decomp_plane1, ax
                lodsb
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_4121
                mov     ah, [si+29DCh]
                mov     cs:decomp_plane2, ax
                mov     ah, [si+14EEh]
                mov     cs:decomp_plane1, ax
                lodsb
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosb
                retn
Render_TileRow_TopDown        endp


; =============== S U B R O U T I N E =======================================


; Render tile rows bottom-up with frame-timer pacing
;   Input:
;     DI = VRAM offset
;     ES = source segment
Render_Tile_Rows_BottomUp        proc near
                push    ds
                mov     ds:src_offset, di
                mov     ds:src_segment, es
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, cs:src_segment
                mov     cx, 39h ; '9'

loc_4178:                               ; ...
                mov     byte ptr cs:frame_timer, 0
                push    cx
                mov     ax, cx
                neg     ax
                add     ax, 39h ; '9'
                add     ax, ax
                call    Render_TileRow_BottomUp
                pop     ax
                push    ax
                add     ax, ax
                dec     ax
                call    Render_TileRow_BottomUp

loc_4193:                               ; ...
                cmp     byte ptr cs:frame_timer, 4
                jb      short loc_4193
                pop     cx
                loop    loc_4178
                pop     ds
                retn
Render_Tile_Rows_BottomUp        endp


; =============== S U B R O U T I N E =======================================


; Render single-row tile data bottom-up with width variation by row index
;   Input:
;     AL = row index (0-based, reversed)
;     DI = source data offset base
;     SI computed from src_offset + 0x3CD + row * 0x2F
;   Output: rendered to VRAM via Calc_VRAM_Addr
;   Clobbers: AX, BX, CX, SI, DI, flags
Render_TileRow_BottomUp        proc near
                push    ax
                mov     bl, al
                mov     al, 2Fh ; '/'
                mul     bl
                add     ax, 3CDh
                add     ax, cs:src_offset
                mov     si, ax
                add     bl, 14h
                mov     bh, 21h ; '!'
                call    Calc_VRAM_Addr
                mov     di, ax
                pop     ax
                cmp     ax, 5Eh ; '^'
                mov     cx, 2Fh ; '/'
                jnb     short loc_41FE
                mov     cx, 7
                mov     cs:decomp_plane3, 0

loc_41CE:                               ; ...
                mov     ax, [si+29DCh]
                xchg    ah, al
                mov     cs:decomp_plane2, ax
                mov     ax, [si+14EEh]
                xchg    ah, al
                mov     cs:decomp_plane1, ax
                lodsw
                xchg    ah, al
                mov     cs:decomp_plane0, ax
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                call    Decompress_3Plane_To_2bpp
                stosw
                loop    loc_41CE
                mov     cx, 21h ; '!'

loc_41FE:                               ; ...
                add     cx, cx
                xor     ax, ax
                rep stosw
                retn
Render_TileRow_BottomUp        endp


; =============== S U B R O U T I N E =======================================


; Clear 8x8 pixel block in VRAM (fill with 0x0000)
;   Input:
;     BH = screen Y
;     BL = screen X
GDMCGA_Clear_HUD_Bar        proc near
                push    ax
                call    Calc_VRAM_Addr
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                pop     ax
                mov     ah, al
                mov     cx, 8

loc_4216:                               ; ...
                stosw
                stosw
                stosw
                stosw
                add     di, 312
                loop    loc_4216
                retn
GDMCGA_Clear_HUD_Bar        endp


; =============== S U B R O U T I N E =======================================


; VGA palette fade to black via DAC ports 0x3C8/0x3C9
;   Input:
;     DS:SI = pointer to 16-block palette data sequence
GDMCGA_Fade_To_Black        proc near
                mov     dx, 30h ; '0'
                mul     dx
                add     ax, 4289h
                mov     si, ax
                mov     ds:fade_pal_ptr, si
                pushf
                cli
                mov     si, ds:fade_pal_ptr
                mov     ax, 40h ; '@'
                mov     es, ax
                assume es:nothing
                mov     dx, es:63h
                add     dx, 6
                push    dx
                in      al, dx          ; read Vertical Retrace
                mov     ds:fade_color_idx, 0
                mov     cx, 10h

loc_424C:                               ; ...
                push    cx
                lodsb
                mov     bh, al
                lodsb
                mov     bl, al
                lodsb
                mov     ah, al
                push    si
                mov     si, ds:fade_pal_ptr
                mov     cx, 10h

loc_425E:                               ; ...
                mov     dx, 3C8h        ; VGA Palette Address Register
                mov     al, ds:fade_color_idx
                out     dx, al          ; color index to change
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_4267:                               ; ...
                mov     dl, 0C9h        ; 3C9h: VGA Palette Data Register
                lodsb
                add     al, bh
                out     dx, al          ; modify red
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_426F:                               ; ...
                lodsb
                add     al, bl
                out     dx, al          ; modify green
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_4275:                               ; ...
                lodsb
                add     al, ah
                out     dx, al          ; modify blue
                jmp     short $+2
; ---------------------------------------------------------------------------

loc_427B:                               ; ...
                inc     ds:fade_color_idx
                loop    loc_425E
                pop     si
                pop     cx
                loop    loc_424C
                pop     dx
                in      al, dx
                popf
                retn
GDMCGA_Fade_To_Black        endp

; ---------------------------------------------------------------------------
byte_4289       db 0                    ; ...
byte_428A       db 0                    ; ...
byte_428B       db 0                    ; ...
                db    0
                db  0Fh
                db  0Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db  0Fh
                db  0Fh
                db  0Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  0Fh
                db  0Fh
                db    0
                db  0Fh
                db  0Fh
                db  0Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db  0Fh
                db  0Fh
                db  0Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db  0Fh
                db  0Fh
                db  0Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  0Fh
                db  0Fh
                db    0
                db  0Fh
                db  0Fh
                db  0Fh
                db    0
                db    0
                db    0
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  0Fh
                db  0Fh
                db  0Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  0Fh
                db  0Fh
                db    0
                db    0
                db  0Fh
                db    0
                db  0Fh
                db    0
                db  0Fh
                db  0Fh
                db    0
                db  0Fh
                db  0Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  0Fh
                db  0Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db  0Fh
                db  0Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db  0Fh
                db  0Fh
                db  0Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db    0
                db    0
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  0Fh
                db    0
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db    7
                db    7
                db    7
                db    0
                db    0
                db  1Fh
                db  1Fh
                db    0
                db    0
                db  1Fh
                db    0
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh
                db  1Fh
                db    0
                db  1Fh
                db  1Fh
                db  1Fh

; =============== S U B R O U T I N E =======================================


; Core 3-plane to 2bpp bit interleaver (decompressor)
;   Input:
;     decomp_plane0..3 = 4 plane words with bits to interleave
;   Output:
;     AX = decompressed 2bpp word (8 pixels × 2bpp)
;   Clobbers: AX, CX, flags, plane registers shifted
Decompress_3Plane_To_2bpp        proc near
                push    cx
                mov     cx, 2

loc_446D:                               ; ...
                rol     cs:decomp_plane3, 1
                adc     ax, ax
                rol     cs:decomp_plane2, 1
                adc     ax, ax
                rol     cs:decomp_plane1, 1
                adc     ax, ax
                rol     cs:decomp_plane0, 1
                adc     ax, ax
                rol     cs:decomp_plane3, 1
                adc     ax, ax
                rol     cs:decomp_plane2, 1
                adc     ax, ax
                rol     cs:decomp_plane1, 1
                adc     ax, ax
                rol     cs:decomp_plane0, 1
                adc     ax, ax
                loop    loc_446D
                xchg    ah, al
                pop     cx
                retn
Decompress_3Plane_To_2bpp        endp


; =============== S U B R O U T I N E =======================================


; Compute AND mask from 2bpp pixel data (generates transparency mask)
;   Input:
;     and_mask_val = 2bpp source word (shifted per call)
;   Output:
;     AH:AL = 1-bit AND mask (expanded to bytes)
;   Clobbers: AX, DX, and_mask_val, flags
Generate_AND_Mask_From_2bpp        proc near
                rol     cs:and_mask_val, 1
                sbb     al, al
                rol     cs:and_mask_val, 1
                sbb     ah, ah
                or      al, ah
                rol     cs:and_mask_val, 1
                sbb     dl, dl
                rol     cs:and_mask_val, 1
                sbb     ah, ah
                or      ah, dl
                retn
Generate_AND_Mask_From_2bpp        endp


; =============== S U B R O U T I N E =======================================


; Clear OR/AND blit buffer in seg2 (0x8000 words to zero)
;   Input: none
Clear_Seg2_Buffer        proc near
                mov     ax, cs
                add     ax, 2000h
                mov     es, ax          ; seg2
                assume es:nothing
                xor     ax, ax
                mov     di, 0
                mov     cx, 8000h
                rep stosw
                retn
Clear_Seg2_Buffer        endp


; =============== S U B R O U T I N E =======================================
; Thunk to font glyph renderer in gmmcga module (code seg offset 2022h)
;   Input: same as gmmcga's Render_Font_Glyph_proc (pass-through)
GDMCGA_Font_Glyph_Thunk        proc near
                jmp     word ptr cs:Render_Font_Glyph_proc
GDMCGA_Font_Glyph_Thunk        endp


; =============== S U B R O U T I N E =======================================


; Convert screen tile coordinates to VRAM address
;   Input:
;     BH = screen Y coordinate (rows, each row = 320 bytes)
;     BL = screen X coordinate (tiles, each tile = 4 bytes wide)
;   Output:
;     AX = VRAM offset (320 * BH + BL * 4)
;   Clobbers: AX, BX, DX, flags
Calc_VRAM_Addr        proc near
                mov     dl, bl
                mov     bl, bh
                xor     bh, bh
                mov     dh, bh
                add     bx, bx
                add     bx, bx
                mov     ax, 320
                mul     dx
                add     ax, bx
                retn
Calc_VRAM_Addr        endp


; =============== S U B R O U T I N E =======================================


; No-op stub
;   Input: none
NoOp       proc near
                retn
NoOp       endp

; ---------------------------------------------------------------------------
fade_pal_ptr    dw 0                    ; pointer to current palette data in fade sequence
fade_color_idx  db 0                    ; current VGA color index (0-255) during fade
decomp_plane0   dw 0                    ; plane 0 source for 3-plane decompression
decomp_plane1   dw 0                    ; plane 1 source for 3-plane decompression
decomp_plane2   dw 0                    ; plane 2 source for 3-plane decompression
decomp_plane3   dw 0                    ; plane 3 / accumulation shift register
and_mask_val    dw 0                    ; AND mask for composite blitting
plane_row       db 0                    ; current bit-plane row index (0-7) / animation phase
plane_group     db 0                    ; current bit-plane group (0-7) / animation direction
anim_frame      db 0                    ; animation frame counter
render_mode     db 0                    ; 0=OR mode, 0FFh=direct write; plane-select bitfield
                db    0
                db    0
render_callback dw 0                    ; render callback pointer / tile width
src_offset      dw 0                    ; source data offset
src_segment     dw 0                    ; source data segment
text_buffer     db 3200 dup(0)          ; off-screen text rendering buffer
                db 44h dup(0)
gdmcga          ends


                end     start
