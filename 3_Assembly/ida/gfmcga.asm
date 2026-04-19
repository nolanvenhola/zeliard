include common.inc
include dungeon.inc
                .286
                .model small

gfmcga          segment byte public 'CODE' use16
                assume cs:gfmcga
                org 3000h
                assume es:nothing, ss:nothing, ds:nothing
start:                
                dw offset Refresh_Dirty_Tiles
                dw offset Sample_Neighborhood_Attributes
                dw offset Flush_Ui_Element_If_Dirty
                dw offset Render_Scrolling_Transition_Overlay
                dw offset Uncompress_And_Render_Tile ; AL: tile index
                                        ; DI: screen address
                dw offset Viewport_Coords_To_Screen_Addr ; AL: y
                                        ; AH: x
                                        ; Returns video memory address in DI
                dw offset Scrolling_Overlay_EntryPoint
                dw offset Cached_Tile_Drawer ; AL: Tile Index
                                        ; DX: Screen destination
                dw offset Active_Entity_Sprite_Renderer
                dw offset Render_Viewport_Tiles ; ;
                dw offset Copy_Tile_Buffer_To_VRAM
                dw offset Update_Local_Attribute_Cache
                dw offset Render_Viewport_Border_Walls
                dw offset Load_Sprite_Sheet
                dw offset Render_Animated_Tile_Strip
                dw offset Render_Tilemap_With_Palette
                dw offset Calculate_Tile_VRAM_Address
                dw offset Render_16x16_Sprite
                dw offset Render_Status_Indicator
                dw offset Render_Entity_Sprite
                dw offset Decompress_Tile_Data
                dw offset nullsub_1

; =============== S U B R O U T I N E =======================================


Refresh_Dirty_Tiles proc near           ; ...
                push    cs
                pop     es
                mov     di, 501Dh
                xor     ax, ax
                mov     cx, 80h
                rep stosw
                inc     ds:tile_anim_frame_counter
                mov     ds:viewport_row_vram_addr, 11B0h
                mov     si, ds:viewport_left_top_addr
                sub     si, 33
                call    wrap_e000_from_below
                xor     bx, bx
                test    byte ptr [si], 80h
                jz      short loc_3056
                call    Render_Top_Left_Corner_Entity

loc_3056:                               ; ...
                inc     si
                mov     cx, 6

loc_305A:                               ; ...
                push    cx
                test    byte ptr [si], 80h
                jz      short loc_3063
                call    Render_Tile_With_Attribute_Cache

loc_3063:                               ; ...
                inc     si
                inc     bx
                test    byte ptr [si], 80h
                jz      short loc_306D
                call    Render_Tile_With_Attribute_Cache

loc_306D:                               ; ...
                inc     si
                inc     bx
                test    byte ptr [si], 80h
                jz      short loc_3077
                call    Render_Tile_With_Attribute_Cache

loc_3077:                               ; ...
                inc     si
                inc     bx
                test    byte ptr [si], 80h
                jz      short loc_3081
                call    Render_Tile_With_Attribute_Cache

loc_3081:                               ; ...
                inc     si
                inc     bx
                pop     cx
                loop    loc_305A
                test    byte ptr [si], 80h
                jz      short loc_308E
                call    Render_Tile_With_Attribute_Cache

loc_308E:                               ; ...
                inc     si
                inc     bx
                test    byte ptr [si], 80h
                jz      short loc_3098
                call    Render_Tile_With_Attribute_Cache

loc_3098:                               ; ...
                inc     si
                inc     bx
                test    byte ptr [si], 80h
                jz      short loc_30A2
                call    Render_Tile_With_Attribute_Cache

loc_30A2:                               ; ...
                inc     si
                test    byte ptr [si], 80h
                jz      short loc_30AB
                call    Render_Bottom_Right_Corner_Entity

loc_30AB:                               ; ...
                mov     si, ds:viewport_left_top_addr
                mov     di, viewport_buffer_28x19
                mov     ds:viewport_rows_remaining, 12h

loc_30B7:                               ; ...
                call    render_hero_sword
                xor     bx, bx
                add     si, 3
                lodsb
                or      al, al
                jns     short loc_30C7
                call    Render_Tile_With_Dual_Cache

loc_30C7:                               ; ...
                mov     cx, 6

loc_30CA:                               ; ...
                push    cx
                cmpsb
                jz      short loc_30D1
                call    Process_Dirty_Tile_With_Animation

loc_30D1:                               ; ...
                inc     bx
                cmpsb
                jz      short loc_30D8
                call    Process_Dirty_Tile_With_Animation

loc_30D8:                               ; ...
                inc     bx
                cmpsb
                jz      short loc_30DF
                call    Process_Dirty_Tile_With_Animation

loc_30DF:                               ; ...
                inc     bx
                cmpsb
                jz      short loc_30E6
                call    Process_Dirty_Tile_With_Animation

loc_30E6:                               ; ...
                inc     bx
                pop     cx
                loop    loc_30CA
                cmpsb
                jz      short loc_30F0
                call    Process_Dirty_Tile_With_Animation

loc_30F0:                               ; ...
                inc     bx
                cmpsb
                jz      short loc_30F7
                call    Process_Dirty_Tile_With_Animation

loc_30F7:                               ; ...
                inc     bx
                cmpsb
                jz      short loc_30FE
                call    Process_Dirty_Tile_With_Animation

loc_30FE:                               ; ...
                inc     bx
                lodsb
                inc     di
                or      al, al
                jns     short loc_3108
                jmp     Render_Tile_And_Update_Cache
; ---------------------------------------------------------------------------

loc_3108:                               ; ...
                cmp     al, es:[di-1]
                jz      short loc_3111
                call    Process_Dirty_Tile_With_Animation

loc_3111:                               ; ...
                add     si, 4
                call    wrap_e900_from_above
                add     ds:viewport_row_vram_addr, 0A00h
                dec     ds:viewport_rows_remaining
                jnz     short loc_30B7
                retn
Refresh_Dirty_Tiles endp


; =============== S U B R O U T I N E =======================================


Process_Dirty_Tile_With_Animation proc near ; ...
                mov     al, [si-1]
                or      al, al
                jns     short loc_312E
                jmp     Render_Tile_With_Border_Check
; ---------------------------------------------------------------------------

loc_312E:                               ; ...
                cmp     byte ptr es:[di-1], 0FCh
                jnz     short loc_313C
                mov     byte ptr es:[di-1], 0FFh
                jmp     short loc_315C
; ---------------------------------------------------------------------------

loc_313C:                               ; ...
                inc     byte ptr es:[di-1]
                mov     byte ptr es:[di-1], 0FEh
                jz      short loc_315C
                mov     es:[di-1], al
                mov     dx, bx
                add     dx, dx
                add     dx, dx
                add     dx, dx
                add     dx, ds:viewport_row_vram_addr
                shr     dx, 1
                call    Cached_Tile_Drawer ; AL: Tile Index
                                        ; DX: Screen destination

loc_315C:                               ; ...
                mov     al, ds:cavern_level
                sub     al, 5
                jnb     short loc_3164
                retn
; ---------------------------------------------------------------------------

loc_3164:                               ; ...
                cmp     al, 4
                jb      short loc_3169
                retn
; ---------------------------------------------------------------------------

loc_3169:                               ; ...
                push    bx
                mov     bl, al
                xor     bh, bh
                add     bx, bx
                call    ds:funcs_3170[bx]
                pop     bx
                retn
Process_Dirty_Tile_With_Animation endp

; ---------------------------------------------------------------------------
funcs_3170      dw offset Animate_Door_Tile_Type0 ; ...
                dw offset Animate_Chest_Lever_Tile
                dw offset Animate_Special_Tiles
                dw offset AnimateWaterTile

; =============== S U B R O U T I N E =======================================


Animate_Door_Tile_Type0 proc near       ; ...
                mov     al, [si-1]
                sub     al, 1Bh
                cmp     al, 2
                jb      short loc_3188
                retn
; ---------------------------------------------------------------------------

loc_3188:                               ; ...
                mov     byte ptr [di-1], 0FEh
                test    ds:tile_anim_frame_counter, 1
                jnz     short loc_3194
                retn
; ---------------------------------------------------------------------------

loc_3194:                               ; ...
                inc     al
                and     al, 1
                add     al, 1Bh
                mov     [si-1], al
                retn
Animate_Door_Tile_Type0 endp


; =============== S U B R O U T I N E =======================================


Animate_Chest_Lever_Tile proc near      ; ...
                mov     al, [si-1]
                sub     al, 1Dh
                cmp     al, 6
                jb      short loc_31A8
                retn
; ---------------------------------------------------------------------------

loc_31A8:                               ; ...
                mov     byte ptr [di-1], 0FEh
                cmp     al, 4
                jnb     short loc_31CA
                or      al, al
                jnz     short loc_31C0
                push    ax
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 3
                pop     ax
                jz      short loc_31C0
                retn
; ---------------------------------------------------------------------------

loc_31C0:                               ; ...
                inc     al
                and     al, 3
                add     al, 1Dh
                mov     [si-1], al
                retn
; ---------------------------------------------------------------------------

loc_31CA:                               ; ...
                inc     al
                and     al, 1
                add     al, 21h ; '!'
                mov     [si-1], al
                retn
Animate_Chest_Lever_Tile endp


; =============== S U B R O U T I N E =======================================


Animate_Special_Tiles proc near         ; ...
                mov     al, [si-1]
                sub     al, 2Ch ; ','
                cmp     al, 2
                jnb     short loc_31F3
                mov     byte ptr [di-1], 0FEh
                test    ds:tile_anim_frame_counter, 1
                jnz     short loc_31E9
                retn
; ---------------------------------------------------------------------------

loc_31E9:                               ; ...
                inc     al
                and     al, 1
                add     al, 2Ch ; ','
                mov     [si-1], al
                retn
; ---------------------------------------------------------------------------

loc_31F3:                               ; ...
                mov     al, [si-1]
                cmp     al, 3Eh ; '>'
                jb      short loc_31FB
                retn
; ---------------------------------------------------------------------------

loc_31FB:                               ; ...
                mov     bl, 33h ; '3'
                cmp     al, 0Eh
                jz      short loc_3242
                mov     bl, 36h ; '6'
                cmp     al, 0Dh
                jz      short loc_3242
                mov     bl, 39h ; '9'
                cmp     al, 0Fh
                jz      short loc_3242
                mov     bl, 3Ch ; '<'
                cmp     al, 0Ch
                jz      short loc_3242
                mov     bl, 3Dh ; '='
                cmp     al, 10h
                jz      short loc_3242
                sub     al, 33h ; '3'
                jnb     short loc_321E
                retn
; ---------------------------------------------------------------------------

loc_321E:                               ; ...
                mov     bl, 0Eh
                cmp     al, 2
                jz      short loc_3242
                mov     bl, 0Dh
                cmp     al, 5
                jz      short loc_3242
                mov     bl, 0Fh
                cmp     al, 8
                jz      short loc_3242
                mov     bl, 0Ch
                cmp     al, 9
                jz      short loc_3242
                mov     bl, 10h
                cmp     al, 0Ah
                jz      short loc_3242
                inc     al
                add     al, 33h ; '3'
                mov     bl, al

loc_3242:                               ; ...
                mov     byte ptr [di-1], 0FEh
                test    ds:tile_anim_frame_counter, 1
                jnz     short loc_324E
                retn
; ---------------------------------------------------------------------------

loc_324E:                               ; ...
                mov     [si-1], bl
                retn
Animate_Special_Tiles endp


; =============== S U B R O U T I N E =======================================


AnimateWaterTile proc near              ; ...
                mov     al, [si-1]
                sub     al, 25h ; '%'
                cmp     al, 4
                jb      short loc_325C
                retn
; ---------------------------------------------------------------------------

loc_325C:                               ; ...
                mov     byte ptr [di-1], 0FEh
                test    ds:tile_anim_frame_counter, 1
                jnz     short loc_3268
                retn
; ---------------------------------------------------------------------------

loc_3268:                               ; ...
                inc     al
                and     al, 3
                add     al, 25h ; '%'
                mov     [si-1], al
                retn
AnimateWaterTile endp


; =============== S U B R O U T I N E =======================================

; AL: Tile Index
; DX: Screen destination

Cached_Tile_Drawer proc near            ; ...
                push    es
                push    ds
                push    di
                push    si
                push    bx
                add     dx, dx
                mov     di, dx
                or      al, al
                jnz     short loc_3282
                jmp     loc_330C
; ---------------------------------------------------------------------------

loc_3282:                               ; ...
                mov     bl, al
                xor     bh, bh
                add     bx, bx
                test    ds:tile_vram_cache[bx], 0FFFFh
                jnz     short loc_32EA
                dec     al
                mov     ds:tile_vram_cache[bx], di
                mov     cl, 30h ; '0'
                mul     cl
                add     ax, 8030h
                mov     si, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     cx, 8

loc_32AC:                               ; ...
                push    cx
                mov     cx, 2

loc_32B0:                               ; ...
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1
                mov     es:[di], dh
                shr     dl, 1
                shr     dl, 1
                mov     es:[di+1], dl
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh
                mov     es:[di+2], bh
                and     al, 3Fh
                mov     es:[di+3], al
                add     di, 4
                loop    loc_32B0
                add     di, 138h
                pop     cx
                loop    loc_32AC
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                assume es:nothing
                retn
; ---------------------------------------------------------------------------

loc_32EA:                               ; ...
                mov     si, ds:tile_vram_cache[bx]
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     ds, ax
                assume ds:nothing
                mov     cx, 8

loc_32F8:                               ; ...
                movsw
                movsw
                movsw
                movsw
                add     di, 312
                add     si, 312
                loop    loc_32F8
                pop     bx
                pop     si
                pop     di
                pop     ds
                assume ds:nothing
                pop     es
                assume es:nothing
                retn
; ---------------------------------------------------------------------------

loc_330C:                               ; ...
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                xor     ax, ax
                mov     cx, 8

loc_3316:                               ; ...
                stosw
                stosw
                stosw
                stosw
                add     di, 312
                loop    loc_3316
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                assume es:nothing
                retn
Cached_Tile_Drawer endp


; =============== S U B R O U T I N E =======================================


Render_Top_Left_Corner_Entity proc near ; ...
                cmp     byte ptr ds:viewport_buffer_28x19, 0FFh
                jnz     short loc_332E
                retn

loc_332E:                               ; ...
                cmp     byte ptr ds:viewport_buffer_28x19, 0FCh
                jnz     short loc_3336
                retn

loc_3336:
                push    si
                push    bx
                mov     byte ptr ds:viewport_buffer_28x19, 0FFh
                mov     cl, [si]
                add     si, 36+1
                call    wrap_e900_from_above
                mov     al, [si]
                or      al, al
                jns     short loc_334E
                call    Translate_Tile_Index
loc_334E:
                push    ax
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                add     si, 3
                pop     ax
                mov     ah, [si]
                mov     dx, 11B0h
                call    Decode_And_Render_Tile_With_Blit ; AH: nible-compressed tile idx
                                                         ; AL: 6bit-packed tile idx
                pop     bx
                pop     si
                retn
Render_Top_Left_Corner_Entity endp


; =============== S U B R O U T I N E =======================================


Render_Tile_With_Attribute_Cache proc near ; ...
                push    si
                push    bx
                mov     cx, bx
                mov     di, bx
                add     di, viewport_buffer_28x19
                mov     bx, offset tile_cache_dirty_flags
                mov     al, 0FFh
                xchg    al, [di]
                mov     [bx], al
                mov     byte ptr [bx+1], 0
                mov     byte ptr [di+1], 0FFh
                mov     dx, cx
                add     dx, dx
                add     dx, dx
                add     dx, dx
                add     dx, 11B0h
                mov     cl, [si]
                add     si, 24h ; '$'
                call    wrap_e900_from_above
                mov     bx, offset tile_neighborhood_buffer
                lodsw
                mov     [bx], ax
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                inc     si
                inc     si
                mov     di, offset tile_neighborhood_buffer
                mov     bp, offset tile_cache_dirty_flags
                call    Render_Tile_Neighborhood_Cell
                pop     bx
                pop     si
                retn
Render_Tile_With_Attribute_Cache endp


; =============== S U B R O U T I N E =======================================


Render_Bottom_Right_Corner_Entity proc near ; ...
                cmp     byte ptr ds:[viewport_buffer_28x19+1Bh], 0FFh
                jnz     short loc_33B3
                retn
; ---------------------------------------------------------------------------

loc_33B3:                               ; ...
                cmp     byte ptr ds:[viewport_buffer_28x19+1Bh], 0FCh
                jnz     short loc_33BB
                retn
; ---------------------------------------------------------------------------

loc_33BB:                               ; ...
                mov     byte ptr ds:[viewport_buffer_28x19+1Bh], 0FFh
                mov     cl, [si]
                add     si, 24h ; '$'
                call    wrap_e900_from_above
                mov     al, [si]
                or      al, al
                jns     short loc_33D1
                call    Translate_Tile_Index

loc_33D1:                               ; ...
                push    ax
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                add     si, 2
                pop     ax
                mov     ah, [si]
                mov     dx, 1288h
                jmp     Decode_And_Render_Tile_With_Blit
Render_Bottom_Right_Corner_Entity endp


; =============== S U B R O U T I N E =======================================


Render_Tile_With_Dual_Cache proc near   ; ...
                push    si
                push    di
                push    bx
                push    bx
                mov     bx, offset tile_cache_dirty_flags
                mov     al, 0FFh
                xchg    al, [di]
                mov     [bx], al
                mov     al, 0FFh
                xchg    al, [di+1Ch]
                mov     [bx+1], al
                mov     cl, [si-1]
                mov     dl, [si]
                add     si, 24h ; '$'
                call    wrap_e900_from_above
                mov     dh, [si]
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                inc     si
                mov     bx, dx
                pop     dx
                add     dx, dx
                add     dx, dx
                add     dx, dx
                add     dx, ds:viewport_row_vram_addr
                cmp     ds:tile_cache_dirty_flags, 0FFh
                jz      short loc_343A
                cmp     ds:tile_cache_dirty_flags, 0FCh
                jz      short loc_343A
                mov     ah, [si]
                mov     al, bl
                push    bx
                push    si
                push    dx
                or      al, al
                jns     short loc_3434
                call    Translate_Tile_Index

loc_3434:                               ; ...
                call    Decode_And_Render_Tile_With_Blit
                pop     dx
                pop     si
                pop     bx

loc_343A:                               ; ...
                add     dx, 0A00h
                cmp     ds:viewport_rows_remaining, 1
                jz      short loc_3464
                cmp     ds:tile_cache_row1_dirty_flags, 0FFh
                jz      short loc_3464
                cmp     ds:tile_cache_row1_dirty_flags, 0FCh
                jz      short loc_3464
                inc     si
                inc     si
                lodsb
                mov     ah, al
                mov     al, bh
                or      al, al
                jns     short loc_3461
                call    Translate_Tile_Index

loc_3461:                               ; ...
                call    Decode_And_Render_Tile_With_Blit

loc_3464:                               ; ...
                pop     bx
                pop     di
                pop     si
                retn
Render_Tile_With_Dual_Cache endp


; =============== S U B R O U T I N E =======================================


Render_Tile_With_Border_Check proc near ; ...
                push    si
                push    di
                push    bx
                push    bx
                mov     bx, offset tile_cache_dirty_flags
                mov     ax, 0FFFEh
                xchg    ax, [di-1]
                mov     [bx], ax
                mov     ax, 0FFFFh
                xchg    ax, [di+1Bh]
                mov     [bx+2], ax
                mov     cl, [si-1]
                mov     bx, offset tile_neighborhood_buffer
                mov     al, [si]
                mov     [bx+1], al
                add     si, 24h ; '$'
                call    wrap_e900_from_above
                mov     ax, [si-1]
                mov     [bx+2], ax
                pop     dx
                mov     ds:hero_tile_col_idx, dl
                mov     al, ds:viewport_rows_remaining
                neg     al
                add     al, 12h
                mov     ds:hero_tile_row_idx, al
                add     dx, dx
                add     dx, dx
                add     dx, dx
                add     dx, ds:viewport_row_vram_addr
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                mov     di, offset tile_neighborhood_buffer
                mov     [di], al
                mov     bp, offset tile_cache_dirty_flags
                call    Render_Tile_Neighborhood_Cell
                cmp     ds:viewport_rows_remaining, 1
                jz      short loc_34DF
                add     dx, 9F0h
                call    Render_Tile_Neighborhood_Cell
                test    byte ptr ds:is_boss_cavern, 0FFh
                jz      short loc_34DF
                test    byte ptr ds:sprite_flash_flag, 0FFh
                jz      short loc_34DF
                call    Spawn_Map_Entity

loc_34DF:                               ; ...
                pop     bx
                pop     di
                pop     si
                retn
Render_Tile_With_Border_Check endp


; =============== S U B R O U T I N E =======================================


Render_Tile_And_Update_Cache proc near  ; ...
                push    si
                push    di
                push    bx
                push    bx
                mov     bx, offset tile_cache_dirty_flags
                mov     al, 0FEh
                xchg    al, [di-1]
                mov     [bx], al
                mov     al, 0FFh
                xchg    al, [di+1Bh]
                mov     [bx+1], al
                mov     cl, [si-1]
                add     si, 24h ; '$'
                call    wrap_e900_from_above
                mov     dl, [si-1]
                mov     al, cl
                call    Lookup_Monster_Tile_Attributes
                mov     bl, al
                mov     bh, dl
                pop     dx
                add     dx, dx
                add     dx, dx
                add     dx, dx
                add     dx, ds:viewport_row_vram_addr
                cmp     ds:tile_cache_dirty_flags, 0FFh
                jz      short loc_353B
                cmp     ds:tile_cache_dirty_flags, 0FCh
                jz      short loc_353B
                mov     ah, [si]
                mov     al, bl
                push    bx
                push    si
                push    dx
                or      al, al
                jns     short loc_3535
                call    Translate_Tile_Index

loc_3535:                               ; ...
                call    Decode_And_Render_Tile_With_Blit
                pop     dx
                pop     si
                pop     bx

loc_353B:                               ; ...
                add     dx, 0A00h
                cmp     ds:viewport_rows_remaining, 1
                jz      short loc_3565
                cmp     ds:tile_cache_row1_dirty_flags, 0FFh
                jz      short loc_3565
                cmp     ds:tile_cache_row1_dirty_flags, 0FCh
                jz      short loc_3565
                inc     si
                inc     si
                lodsb
                mov     ah, al
                mov     al, bh
                or      al, al
                jns     short loc_3562
                call    Translate_Tile_Index

loc_3562:                               ; ...
                call    Decode_And_Render_Tile_With_Blit

loc_3565:                               ; ...
                pop     bx
                pop     di
                pop     si
                jmp     loc_3111
Render_Tile_And_Update_Cache endp


; =============== S U B R O U T I N E =======================================


Render_Tile_Neighborhood_Cell proc near ; ...
                call    $+3
                cmp     byte ptr ds:[bp+0], 0FFh
                jz      short loc_3592
                cmp     byte ptr ds:[bp+0], 0FCh
                jz      short loc_3592
                mov     ah, [si]
                mov     al, [di]
                or      al, al
                jns     short loc_3587
                call    Translate_Tile_Index

loc_3587:                               ; ...
                push    bp
                push    si
                push    di
                push    dx
                call    Decode_And_Render_Tile_With_Blit
                pop     dx
                pop     di
                pop     si
                pop     bp

loc_3592:                               ; ...
                inc     si
                inc     di
                inc     bp
                add     dx, 8
                retn
Render_Tile_Neighborhood_Cell endp ; sp-analysis failed


; =============== S U B R O U T I N E =======================================

; AH: nible-compressed tile idx
; AL: 6bit-packed tile idx
Decode_And_Render_Tile_With_Blit proc near
                push    es
                push    ds
                mov     bl, ds:tile_blit_mode ; blit mode
                or      al, al
                jz      short loc_35A8
                js      short loc_35A8
                or      bl, 80h
loc_35A8:
                mov     cl, al
                mov     al, ah ; compressed tile idx
                mov     ch, 32 ; 32 bytes (64 nibbles) per compressed tile
                mul     ch
                mov     si, ax
                add     si, 4000h ; seg1:4000h - nible-compressed tiles
                shr     ax, 1
                shr     ax, 1
                mov     bp, ax
                add     bp, 0A000h
                mov     ds, word ptr cs:seg1
                mov     di, dx   ; VRAM destination address
                mov     ax, 0A000h
                mov     es, ax
                mov     ch, bl
                and     bl, 7Fh
                xor     bh, bh
                add     bx, bx
                mov     ax, cs:pal_decode_tbl[bx]
                mov     cs:nibble_decode_lut, ax ; 16 bytes table addr, indexed by nibbles
                mov     al, cl
                or      ch, ch
                js      short with_blit
                push    di
                mov     di, 64000 ; di: render address (shadow VRAM)
                call    render_nibble_compressed_tile ; si: src (compressed) - 32 bytes (64 nibbles)
                pop     di
                mov     si, 64000 ; from shadow VRAM
                mov     ax, 0A000h
                mov     ds, ax
                call    Copy_tile
                pop     ds
                pop     es
                retn
; ---------------------------------------------------------------------------

with_blit:
                push    di
                mov     di, 64000
                call    decode_and_render_tile_with_blitting
                pop     di
                mov     si, 64000
                mov     ax, 0A000h
                mov     ds, ax
                call    Copy_tile
                pop     ds
                pop     es
                retn
Decode_And_Render_Tile_With_Blit endp


; =============== S U B R O U T I N E =======================================

; CL: tile idx + 1 (in seg1:8030h packed)
decode_and_render_tile_with_blitting proc near
                push    bp
                push    si
                push    di
                dec     cl ; packed tile idx
                mov     al, 48
                mul     cl
                add     ax, 8030h
                mov     si, ax ; source addr of packed tile
                call    render_48bytes_packed_tile
                pop     di
                pop     si
                pop     bp
                jmp     short $+2

loc_3626:
                mov     cx, 8

loc_3629:
                push    cx
                mov     dl, ds:[bp+0]      ; blit mask
                lodsw                      ; 4 nibbles for extracting and blitting
                call    four_pixels_or_blit
                lodsw                      ; next 4 nibbles
                call    four_pixels_or_blit
                inc     bp
                pop     cx
                loop    loc_3629
                retn
decode_and_render_tile_with_blitting endp


; =============== S U B R O U T I N E =======================================

; DL:
; AX:
four_pixels_or_blit proc near
                mov     cx, 4
loc_363E:
                add     dl, dl ; extract dl bit7
                sbb     dh, dh
                and     dh, es:[di]
                call    get_pixel_from_table_by_ah_hi ; BL = cs:nibble_decode_lut[AH 7...4]
                or      bl, dh
                mov     es:[di], bl ; OR-blit dest. pixel with extracted
                inc     di
                loop    loc_363E
                retn
four_pixels_or_blit endp


; =============== S U B R O U T I N E =======================================

; si: src (compressed) - 32 bytes (64 nibbles)
; di: render address
render_nibble_compressed_tile proc near
                mov     cx, 8
loc_3654:
                push    cx
                lodsw
                call    draw_4_pix_from_table_by_ax
                lodsw
                call    draw_4_pix_from_table_by_ax
                pop     cx
                loop    loc_3654
                retn
render_nibble_compressed_tile endp


; =============== S U B R O U T I N E =======================================


draw_4_pix_from_table_by_ax proc near
                mov     cx, 4
loc_3664:
                call    get_pixel_from_table_by_ah_hi ; BL = cs:nibble_decode_lut[AH 7...4]
                mov     es:[di], bl
                inc     di
                loop    loc_3664
                retn
draw_4_pix_from_table_by_ax endp


; =============== S U B R O U T I N E =======================================

; BL = cs:nibble_decode_lut[AH 7...4]
get_pixel_from_table_by_ah_hi proc near
                add     ax, ax
                adc     bx, bx
                add     ax, ax
                adc     bx, bx
                add     ax, ax
                adc     bx, bx
                add     ax, ax
                adc     bx, bx
                and     bx, 0Fh
                add     bx, cs:nibble_decode_lut ; 16 bytes table addr
                mov     bl, cs:[bx]
                retn
get_pixel_from_table_by_ah_hi endp


; =============== S U B R O U T I N E =======================================


Copy_tile       proc near
                mov     cx, 8
loc_368D:
                movsw
                movsw
                movsw
                movsw
                add     di, 312
                loop    loc_368D
                retn
Copy_tile       endp


; =============== S U B R O U T I N E =======================================

; SI: source (packed) - 48 bytes
; DI: render address, advances while rendering
render_48bytes_packed_tile proc near
                mov     cx, 16
loc_369B:
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1
                mov     es:[di], dh
                shr     dl, 1
                shr     dl, 1
                mov     es:[di+1], dl
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh
                mov     es:[di+2], bh
                and     al, 3Fh
                mov     es:[di+3], al
                add     di, 4
                loop    loc_369B
                retn
render_48bytes_packed_tile endp


; =============== S U B R O U T I N E =======================================


Clear_Tile_Buffer proc near             ; ...
                xor     ax, ax
                mov     cx, 20h ; ' '
                rep stosw
                retn
Clear_Tile_Buffer endp


; =============== S U B R O U T I N E =======================================


Translate_Tile_Index proc near          ; ...
                and     al, 7Fh
                mov     bx, offset proximity_second_layer
                xlat
                retn
Translate_Tile_Index endp


; =============== S U B R O U T I N E =======================================


Lookup_Monster_Tile_Attributes proc near ; ...
                and     al, 7Fh
                mov     bl, al
                xor     bh, bh
                mov     cl, [bx+proximity_second_layer]
                mov     ch, 16
                mul     ch
                add     ax, ds:monsters_table_addr
                mov     bp, ax
                mov     al, ds:[bp+6]   ; monster.anim_counter
                and     al, 0Fh
                mov     ch, 5
                mul     ch
                mov     si, 0A070h
                test    byte ptr ds:[bp+5], 80h ; monster.ai_flags
                jnz     short loc_3703
                mov     si, 0A030h

loc_3703:                               ; ...
                mov     bl, ds:[bp+4]   ; monster.flags
                and     bl, 1Fh
                add     bl, bl
                xor     bh, bh
                add     ax, [bx+si]
                mov     si, ax
                lodsb
                test    byte ptr ds:is_boss_cavern, 0FFh ; is_boss_cavern
                jnz     short loc_3723
                test    byte ptr ds:[bp+5], 20h ; monster.ai_flags
                jz      short loc_3723
                add     al, 3

loc_3723:                               ; ...
                mov     ds:tile_blit_mode, al
                mov     al, cl
                retn
Lookup_Monster_Tile_Attributes endp


; =============== S U B R O U T I N E =======================================


Spawn_Map_Entity proc near              ; ...
                cmp     ds:hero_tile_row_idx, 10h
                jb      short loc_3731
                retn
; ---------------------------------------------------------------------------

loc_3731:                               ; ...
                push    cs
                pop     es
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 0Fh
                cmp     al, 0Eh
                jnb     short loc_373F
                retn
; ---------------------------------------------------------------------------

loc_373F:                               ; ...
                mov     di, 0EDA0h      ; is_boss_dead ??
                xor     cl, cl

loc_3744:                               ; ...
                cmp     byte ptr [di], 0FFh
                jz      short loc_3750
                add     di, 4
                inc     cl
                jmp     short loc_3744
; ---------------------------------------------------------------------------

loc_3750:                               ; ...
                cmp     cl, 20h ; ' '
                jb      short loc_3756
                retn
; ---------------------------------------------------------------------------

loc_3756:                               ; ...
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 3
                cmp     al, 3
                jz      short loc_3756
                dec     al
                add     al, ds:hero_tile_col_idx
                cmp     al, 0FFh
                jnz     short loc_376D
                mov     al, 4

loc_376D:                               ; ...
                cmp     al, 1Bh
                jb      short loc_3773
                mov     al, 1Ah

loc_3773:                               ; ...
                stosb

loc_3774:                               ; ...
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 3
                cmp     al, 3
                jz      short loc_3774
                dec     al
                add     al, ds:hero_tile_row_idx
                cmp     al, 0FFh
                jnz     short loc_378B
                xor     al, al

loc_378B:                               ; ...
                stosb
                mov     al, 3
                stosb
                call    word ptr cs:Accumulate_folded_ff1b_proc
                and     al, 3
                stosb
                mov     al, 0FFh
                stosb
                retn
Spawn_Map_Entity endp


; =============== S U B R O U T I N E =======================================


Active_Entity_Sprite_Renderer proc near ; ...
                push    cs
                pop     es
                mov     di, 0EDA0h      ; Active Entity Table
                mov     si, di

loc_37A2:                               ; ...
                cmp     byte ptr [si], 0FFh
                jnz     short loc_37AB
                mov     byte ptr [di], 0FFh
                retn
; ---------------------------------------------------------------------------

loc_37AB:                               ; ...
                mov     al, [si+1]
                mov     cl, 1Ch
                mul     cl
                mov     cl, [si]
                xor     ch, ch
                add     ax, cx
                push    di
                add     ax, viewport_buffer_28x19
                mov     di, ax
                mov     al, 0FEh
                stosb
                stosb
                add     di, 1Ah
                stosb
                stosb
                pop     di
                mov     al, [si+1]
                xor     ah, ah
                mov     dx, 0A00h
                mul     dx
                mov     cl, [si]
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                add     cx, cx
                add     ax, cx
                add     ax, 11B0h
                push    si
                push    di
                push    es
                push    ax
                mov     bl, [si+3]
                xor     bh, bh
                add     bx, bx
                mov     ax, ds:entity_render_fn_tbl[bx]
                mov     ds:entity_dim_info, ax
                mov     bl, [si+2]
                and     bl, 3
                add     bl, bl
                xor     bh, bh
                mov     si, ds:entity_mask_tbl[bx]
                pop     di
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     cx, 10h

loc_380A:                               ; ...
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di], bp
                or      es:[di], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+2], bp
                or      es:[di+2], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+4], bp
                or      es:[di+4], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+6], bp
                or      es:[di+6], dx
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+8], bp
                or      es:[di+8], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Ah], bp
                or      es:[di+0Ah], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Ch], bp
                or      es:[di+0Ch], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Eh], bp
                or      es:[di+0Eh], dx
                add     di, 140h
                loop    loc_380A
                pop     es
                assume es:nothing
                pop     di
                pop     si
                dec     byte ptr [si+2]
                cmp     byte ptr [si+2], 0FFh
                jz      short loc_388D
                movsw
                movsw
                sub     si, 4

loc_388D:                               ; ...
                add     si, 4
                jmp     loc_37A2
Active_Entity_Sprite_Renderer endp

; ---------------------------------------------------------------------------
entity_render_fn_tbl       dw 1210h                ; ...
                dw 3630h
                dw 3F38h
                dw 3630h
entity_mask_tbl       dw 3963h                ; ...
                dw 3923h
                dw 38E3h
                dw 38A3h
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
                dw 0D00Bh
                db    0
                db    0
                dw 0FA5Fh
                db    0
                db    0
                dw 0FE7Fh
                db    0
                db    0
                dw 0FFFFh
                db    0
                db    0
                dw 0FFFFh
                db    0
                db    0
                dw 0FE7Fh
                db    0
                db    0
                dw 0FA5Fh
                db    0
                db    0
                dw 0D00Bh
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
                dw 0F42Fh
                db    0
                db    0
                dw 0FFFFh
                db    0
                db    3
                db 0FFh
                db 0FFh
                db 0C0h
                db    7
                db 0FFh
                db 0FFh
                db 0E0h
                db  0Fh
                db 0FAh
                db  5Fh ; _
                db 0F0h
                db  0Fh
                db 0F0h
                db  0Fh
                db 0F0h
                db  0Fh
                db 0F0h
                db  0Fh
                db 0F0h
                db  0Fh
                db 0FAh
                db  5Fh ; _
                db 0F0h
                db    7
                db 0FFh
                db 0FFh
                db 0E0h
                db    3
                db 0FFh
                db 0FFh
                db 0C0h
                db    0
                db 0FFh
                db 0FFh
                db    0
                db    0
                db  2Fh ; /
                db 0F4h
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
                db  2Fh ; /
                db 0F4h
                db    0
                db    1
                db  7Fh ; 
                db 0FEh
                db  80h
                db    7
                db 0FFh
                db 0FFh
                db 0E0h
                db  0Fh
                db 0FFh
                db 0FFh
                db 0F0h
                db  3Fh ; ?
                db 0F4h
                db  2Fh ; /
                db 0FCh
                db  7Fh ; 
                db 0A0h
                db    5
                db 0FEh
                db  7Fh ; 
                db  80h
                db    1
                db 0FEh
                db 0FFh
                db    0
                db    0
                db 0FFh
                db 0FFh
                db    0
                db    0
                db 0FFh
                db  7Fh ; 
                db  80h
                db    1
                db 0FEh
                db  7Fh ; 
                db 0A0h
                db    5
                db 0FEh
                db  3Fh ; ?
                db 0F4h
                db  2Fh ; /
                db 0FCh
                db  0Fh
                db 0FFh
                db 0FFh
                db 0F0h
                db    7
                db 0FFh
                db 0FFh
                db 0E0h
                db    1
                db  7Fh ; 
                db 0FEh
                db  80h
                db    0
                db  2Fh ; /
                db 0F4h
                db    0
                db 0
                db  2Fh ; /
                db 0F4h
                db    0
                db    1
                db  7Fh ; 
                db 0FEh
                db  80h
                db    7
                db 0D0h
                db  0Bh
                db 0E0h
                db  0Fh
                db    0
                db    0
                db 0F0h
                db  3Ch ; <
                db    0
                db    0
                db  3Ch ; <
                db  78h ; x
                db    0
                db    0
                db  1Eh
                db  70h ; p
                db    0
                db    0
                db  0Eh
                db 0F0h
                db    0
                db    0
                db  0Fh
                db 0F0h
                db    0
                db    0
                db  0Fh
                db  70h ; p
                db    0
                db    0
                db  0Eh
                db  78h ; x
                db    0
                db    0
                db  1Eh
                db  3Ch ; <
                db    0
                db    0
                db  3Ch ; <
                db  0Fh
                db    0
                db    0
                db 0F0h
                db    7
                db 0D0h
                db  0Bh
                db 0E0h
                db    1
                db  7Fh ; 
                db 0FEh
                db  80h
                db    0
                db  2Fh ; /
                db 0F4h
                db    0

; =============== S U B R O U T I N E =======================================


Update_Local_Attribute_Cache proc near  ; ...
                mov     di, offset tile_neighborhood_buffer
                push    cs
                pop     es
                xor     ax, ax
                stosw
                stosw
                stosw
                stosw
                stosb
                mov     di, offset tile_load_buffer
                mov     cx, 8
                rep stosw
                jmp     short loc_39F5
; ---------------------------------------------------------------------------

Sample_Neighborhood_Attributes:         ; ...
                call    load_3x3_tiles
                mov     di, offset tile_load_buffer
                mov     dl, ds:hero_y_absolute
                dec     dl
                mov     cx, 4

loc_39C8:                               ; ...
                push    cx
                and     dl, 3Fh
                mov     al, 24h ; '$'
                mul     dl
                mov     bx, ax
                add     bx, 0E000h
                mov     al, ds:hero_x_in_viewport
                add     al, 3
                xor     ah, ah
                add     bx, ax
                mov     cx, 4

loc_39E2:                               ; ...
                mov     al, [bx]
                or      al, al
                js      short loc_39EA
                xor     al, al

loc_39EA:                               ; ...
                mov     [di], al
                inc     bx
                inc     di
                loop    loc_39E2
                inc     dl
                pop     cx
                loop    loc_39C8

loc_39F5:                               ; ...
                mov     al, ds:hero_head_y_in_viewport
                xor     ah, ah
                mov     cx, 0A00h
                mul     cx
                mov     cl, ds:hero_x_in_viewport
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                add     cx, cx
                add     ax, cx
                add     ax, 11B0h
                mov     ds:hero_vram_base, ax
                mov     ds:hero_tile_col_idx, 0
                mov     si, offset tile_neighborhood_buffer
                mov     di, offset tile_load_buffer
                mov     cx, 3

loc_3A21:                               ; ...
                push    cx
                mov     cx, 3

loc_3A25:                               ; ...
                push    cx
                mov     ax, offset choose_hero_sprite
                push    ax
                mov     al, [di]
                or      al, [di+1]
                or      al, [di+4]
                or      al, [di+5]
                jnz     short loc_3A3A
                jmp     Render_Empty_Or_Cached_Tile
; ---------------------------------------------------------------------------

loc_3A3A:                               ; ...
                test    byte ptr [di], 0FFh
                jz      short loc_3A4E
                mov     al, [di]
                push    si
                call    Lookup_Monster_Tile_Attributes
                inc     si
                inc     si
                inc     si
                mov     al, [si]
                pop     si
                jmp     Render_Tile_With_Palette
; ---------------------------------------------------------------------------

loc_3A4E:                               ; ...
                test    byte ptr [di+1], 0FFh
                jz      short loc_3A63
                mov     al, [di+1]
                push    si
                call    Lookup_Monster_Tile_Attributes
                inc     si
                inc     si
                mov     al, [si]
                pop     si
                jmp     Render_Tile_With_Palette
; ---------------------------------------------------------------------------

loc_3A63:                               ; ...
                test    byte ptr [di+4], 0FFh
                jz      short loc_3A77
                mov     al, [di+4]
                push    si
                call    Lookup_Monster_Tile_Attributes
                inc     si
                mov     al, [si]
                pop     si
                jmp     Render_Tile_With_Palette
; ---------------------------------------------------------------------------

loc_3A77:                               ; ...
                mov     al, [di+5]
                push    si
                call    Lookup_Monster_Tile_Attributes
                mov     cl, [si]
                pop     si
                mov     [si], al
                mov     al, cl
                jmp     Render_Tile_With_Palette
Update_Local_Attribute_Cache endp


; =============== S U B R O U T I N E =======================================


choose_hero_sprite proc near            ; ...
                inc     ds:hero_tile_col_idx
                inc     di
                inc     si
                pop     cx
                loop    loc_3A25
                pop     cx
                inc     di
                loop    loc_3A21
                mov     bl, ds:hero_damage_this_frame
                and     bl, 3
                xor     bh, bh
                add     bx, bx
                mov     ax, cs:pal_decode_tbl[bx]
                mov     cs:nibble_decode_lut, ax
                mov     es, word ptr cs:seg1 ; seg1
                mov     al, ds:invincibility_flag
                or      al, ds:on_rope_flags
                or      al, ds:hero_hidden_flag
                jz      short loc_3ABE
                jmp     loc_3B80
; ---------------------------------------------------------------------------

loc_3ABE:                               ; ...
                mov     cl, 0FFh
                mov     si, 6117h
                test    byte ptr ds:facing_direction, 1
                jz      short loc_3ACF
                xor     cl, cl
                mov     si, 61B9h

loc_3ACF:                               ; ...
                test    byte ptr ds:shield_anim_active, 0FFh
                jz      short loc_3B18
                inc     cl
                jnz     short loc_3AF4
                mov     al, ds:shield_anim_phase
                shr     al, 1
                mov     cl, 9
                mul     cl
                push    ax
                call    get_player_shield_category
                mov     cl, 24h ; '$'
                mul     cl
                pop     si
                add     si, ax
                add     si, 62C7h
                jmp     short loc_3B61
; ---------------------------------------------------------------------------

loc_3AF4:                               ; ...
                mov     al, ds:shield_anim_phase
                shr     al, 1
                mov     cl, 9
                mul     cl
                add     ax, 24h ; '$'
                mov     dl, ds:shield_variant_index
                dec     dl
                jnz     short loc_3B0D
                add     ax, 24h ; '$'
                jmp     short loc_3B14
; ---------------------------------------------------------------------------

loc_3B0D:                               ; ...
                dec     dl
                jnz     short loc_3B14
                mov     ax, 63h ; 'c'

loc_3B14:                               ; ...
                add     si, ax
                jmp     short loc_3B61
; ---------------------------------------------------------------------------

loc_3B18:                               ; ...
                call    get_player_shield_category
                or      al, al
                jz      short loc_3B43
                dec     al
                mov     cl, al
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3B43
                mov     ax, 6Ch ; 'l'
                mov     dl, ds:squat_flag   ; squat_flag
                and     dl, 9
                xor     dh, dh
                add     ax, dx
                or      cl, cl
                jz      short loc_3B3F
                add     ax, 1Bh

loc_3B3F:                               ; ...
                add     si, ax
                jmp     short loc_3B61
; ---------------------------------------------------------------------------

loc_3B43:                               ; ...
                test    byte ptr ds:squat_flag, 0FFh ; squat_flag
                jnz     short loc_3B80
                mov     al, ds:hero_animation_phase
                cmp     al, 80h
                jz      short loc_3B80
                add     al, 2
                and     al, 3
                test    al, 1
                jnz     short loc_3B80
                mov     cl, 9
                mul     cl
                add     si, ax
                jmp     short loc_3B75
; ---------------------------------------------------------------------------

loc_3B61:                               ; ...
                test    byte ptr ds:squat_flag, 0FFh ; squat_flag
                jz      short loc_3B75
                mov     cx, 6
                mov     ds:hero_tile_col_idx, 3
                call    Render_Scrolling_Tile
                jmp     short loc_3B80
; ---------------------------------------------------------------------------

loc_3B75:                               ; ...
                mov     cx, 9
                mov     ds:hero_tile_col_idx, 0
                call    Render_Scrolling_Tile

loc_3B80:                               ; ...
                mov     si, 610Eh
                test    byte ptr ds:hero_hidden_flag, 0FFh
                jnz     short loc_3BF2
                mov     si, 60EAh
                test    byte ptr ds:on_rope_flags, 0FFh
                jnz     short loc_3BE7
                mov     si, 6075h
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3BA1
                mov     si, 6000h

loc_3BA1:                               ; ...
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_3BAD
                add     si, 5Ah ; 'Z'
                jmp     short loc_3BE7
; ---------------------------------------------------------------------------

loc_3BAD:                               ; ...
                mov     ax, 2Dh ; '-'
                test    byte ptr ds:squat_flag, 0FFh ; squat_flag
                jnz     short loc_3BF0
                mov     ax, 3Fh ; '?'
                test    byte ptr ds:jump_phase_flags, 80h
                jnz     short loc_3BF0
                mov     cl, ds:slope_direction
                mov     ax, 48h ; 'H'
                dec     cl
                jz      short loc_3BF0
                mov     ax, 51h ; 'Q'
                dec     cl
                jz      short loc_3BF0
                mov     ax, 36h ; '6'
                cmp     byte ptr ds:jump_phase_flags, 7Fh
                jz      short loc_3BF0
                mov     ax, 24h ; '$'
                cmp     byte ptr ds:hero_animation_phase, 80h
                jz      short loc_3BF0

loc_3BE7:                               ; ...
                mov     al, ds:hero_animation_phase
                and     al, 3
                mov     cl, 9
                mul     cl

loc_3BF0:                               ; ...
                add     si, ax

loc_3BF2:                               ; ...
                mov     cx, 9
                mov     ds:hero_tile_col_idx, 0
                call    Render_Scrolling_Tile
                test    byte ptr ds:invincibility_flag, 0FFh
                jz      short loc_3C05
                retn
; ---------------------------------------------------------------------------

loc_3C05:                               ; ...
                mov     cl, 0FFh
                mov     si, 61B9h
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3C16
                xor     cl, cl
                mov     si, 6117h

loc_3C16:                               ; ...
                mov     al, ds:on_rope_flags
                or      al, ds:hero_hidden_flag
                jz      short loc_3C36
                call    get_player_shield_category
                or      al, al
                jnz     short loc_3C27
                retn
; ---------------------------------------------------------------------------

loc_3C27:                               ; ...
                dec     al
                shr     al, 1
                sbb     al, al
                and     al, 1Bh
                add     al, 7Eh ; '~'
                xor     ah, ah
                jmp     loc_3CBF
; ---------------------------------------------------------------------------

loc_3C36:                               ; ...
                test    byte ptr ds:shield_anim_active, 0FFh
                jz      short loc_3C7F
                inc     cl
                jnz     short loc_3C5B
                mov     al, ds:shield_anim_phase
                shr     al, 1
                mov     cl, 9
                mul     cl
                push    ax
                call    get_player_shield_category
                mov     cl, 24h ; '$'
                mul     cl
                pop     si
                add     si, ax
                add     si, 625Bh
                jmp     short loc_3CC1
; ---------------------------------------------------------------------------

loc_3C5B:                               ; ...
                mov     al, ds:shield_anim_phase
                shr     al, 1
                mov     cl, 9
                mul     cl
                add     ax, 24h ; '$'
                mov     dl, ds:shield_variant_index
                dec     dl
                jnz     short loc_3C74
                add     ax, 24h ; '$'
                jmp     short loc_3C7B
; ---------------------------------------------------------------------------

loc_3C74:                               ; ...
                dec     dl
                jnz     short loc_3C7B
                mov     ax, 63h ; 'c'

loc_3C7B:                               ; ...
                add     si, ax
                jmp     short loc_3CC1
; ---------------------------------------------------------------------------

loc_3C7F:                               ; ...
                test    byte ptr ds:facing_direction, 1
                jz      short loc_3CA5
                call    get_player_shield_category
                or      al, al
                jz      short loc_3CA5
                dec     al
                mov     cl, al
                mov     al, ds:squat_flag   ; squat_flag
                and     al, 9
                add     al, 6Ch ; 'l'
                xor     ah, ah
                or      cl, cl
                jz      short loc_3CA1
                add     ax, 1Bh

loc_3CA1:                               ; ...
                add     si, ax
                jmp     short loc_3CC1
; ---------------------------------------------------------------------------

loc_3CA5:                               ; ...
                mov     ax, 1Bh
                test    byte ptr ds:squat_flag, 0FFh ; squat_flag
                jnz     short loc_3CBF
                mov     cl, ds:hero_animation_phase
                cmp     cl, 80h
                jz      short loc_3CBF
                and     cl, 3
                mov     al, 9
                mul     cl

loc_3CBF:                               ; ...
                add     si, ax

loc_3CC1:                               ; ...
                test    byte ptr ds:squat_flag, 0FFh ; squat_flag
                jz      short loc_3CD2
                mov     cx, 6
                mov     ds:hero_tile_col_idx, 3
                jmp     short Render_Scrolling_Tile
; ---------------------------------------------------------------------------

loc_3CD2:                               ; ...
                mov     cx, 9
                mov     ds:hero_tile_col_idx, 0
                jmp     short $+2
choose_hero_sprite endp ; sp-analysis failed


; =============== S U B R O U T I N E =======================================


Render_Scrolling_Tile proc near         ; ...
                push    cx
                mov     al, es:[si]
                or      al, al
                jz      short loc_3D19
                push    es
                push    ds
                push    si
                push    di
                mov     ch, 20h ; ' '
                mul     ch
                mov     si, ax
                add     si, 6333h
                shr     ax, 1
                shr     ax, 1
                mov     bp, ax
                add     bp, 0D000h
                mov     ds, word ptr cs:seg1 ; seg1
                mov     di, dx
                push    cs
                pop     es
                mov     al, cs:hero_tile_col_idx
                mov     cl, 40h ; '@'
                mul     cl
                add     ax, offset sword_anim_frames
                mov     di, ax
                call    loc_3626
                pop     di
                pop     si
                pop     ds
                pop     es

loc_3D19:                               ; ...
                inc     si
                inc     ds:hero_tile_col_idx
                pop     cx
                loop    Render_Scrolling_Tile
                retn
Render_Scrolling_Tile endp


; =============== S U B R O U T I N E =======================================


get_player_shield_category proc near    ; ...
                mov     al, ds:shield_type      ; shield_type
                or      al, al
                jnz     short loc_3D2A
                retn                    ; 0: no shield
; ---------------------------------------------------------------------------

loc_3D2A:                               ; ...
                cmp     al, 4           ; Honor Shield
                mov     al, 1
                jnb     short loc_3D31
                retn                    ; 1: Clay, WiseMans, Stone shield
; ---------------------------------------------------------------------------

loc_3D31:                               ; ...
                mov     al, 2           ; 2: Honor, Light, Titanium shield
                retn
get_player_shield_category endp


; =============== S U B R O U T I N E =======================================


Render_Empty_Or_Cached_Tile proc near   ; ...
                mov     al, [si]
                push    ds
                push    si
                push    di
                push    ax
                mov     ds, word ptr cs:seg1 ; seg1
                push    cs
                pop     es
                mov     al, cs:hero_tile_col_idx
                mov     cl, 40h ; '@'
                mul     cl
                add     ax, offset sword_anim_frames
                mov     di, ax
                pop     ax
                or      al, al
                jz      short loc_3D65
                dec     al
                mov     cl, 30h ; '0'
                mul     cl
                add     ax, 8030h
                mov     si, ax
                call    render_48bytes_packed_tile
                pop     di
                pop     si
                pop     ds
                retn
; ---------------------------------------------------------------------------

loc_3D65:                               ; ...
                call    Clear_Tile_Buffer
                pop     di
                pop     si
                pop     ds
                retn
Render_Empty_Or_Cached_Tile endp


; =============== S U B R O U T I N E =======================================


Render_Tile_With_Palette proc near      ; ...
                push    ds
                push    si
                push    di
                mov     cl, al
                mov     al, [si]
                or      al, al
                jns     short loc_3D7A
                call    Translate_Tile_Index

loc_3D7A:                               ; ...
                push    ax
                mov     bl, ds:tile_blit_mode
                xor     bh, bh
                add     bx, bx
                mov     dx, cs:pal_decode_tbl[bx]
                mov     cs:nibble_decode_lut, dx
                mov     al, cl
                mov     ch, 20h ; ' '
                mul     ch
                mov     si, ax
                add     si, 4000h
                shr     ax, 1
                shr     ax, 1
                mov     bp, ax
                add     bp, 0A000h
                mov     ds, word ptr cs:seg1 ; seg1
                push    cs
                pop     es
                mov     al, cs:hero_tile_col_idx
                mov     cl, 40h ; '@'
                mul     cl
                add     ax, offset sword_anim_frames
                mov     di, ax
                pop     ax
                or      al, al
                jz      short loc_3DC5
                mov     cl, al
                call    decode_and_render_tile_with_blitting
                pop     di
                pop     si
                pop     ds
                retn

loc_3DC5:
                call    render_nibble_compressed_tile ; si: src (compressed) - 32 bytes (64 nibbles)
                                                      ; di: render address
                pop     di
                pop     si
                pop     ds
                retn
Render_Tile_With_Palette endp


; =============== S U B R O U T I N E =======================================


load_3x3_tiles  proc near               ; ...
                mov     cl, ds:hero_head_y_in_viewport      ; hero_head_y_in_viewport
                mov     al, 36
                mul     cl
                mov     cl, ds:hero_x_in_viewport      ; hero_x_in_viewport
                add     cl, 4           ; x relative to proximity left
                xor     ch, ch
                add     ax, cx
                add     ax, ds:viewport_left_top_addr
                mov     si, ax
                call    wrap_e900_from_above
                mov     di, offset tile_neighborhood_buffer
                push    cs
                pop     es
                mov     cx, 3

loc_3DF0:                               ; ...
                movsw
                movsb
                add     si, 33
                call    wrap_e900_from_above
                loop    loc_3DF0
                retn
load_3x3_tiles  endp


; =============== S U B R O U T I N E =======================================


render_hero_sword proc near             ; ...

; FUNCTION CHUNK AT 3FD0 SIZE 000000B6 BYTES

                mov     al, ds:viewport_rows_remaining
                neg     al
                add     al, 12h
                mov     cl, al
                test    byte ptr ds:sword_swing_flag, 0FFh
                jnz     short loc_3E18
                mov     al, ds:hero_head_y_in_viewport      ; hero_head_y_in_viewport
                sub     al, 2
                cmp     al, cl
                jnz     short locret_3E17
                call    Copy_Tile_Buffer_To_VRAM

locret_3E17:                            ; ...
                retn
; ---------------------------------------------------------------------------

loc_3E18:                               ; ...
                mov     al, ds:hero_head_y_in_viewport      ; hero_head_y_in_viewport
                sub     al, 5
                cmp     cl, al
                jnb     short loc_3E22
                retn
; ---------------------------------------------------------------------------

loc_3E22:                               ; ...
                jnz     short loc_3E2A
                call    Flush_Ui_Element_If_Dirty
                jmp     Copy_Tile_Buffer_To_VRAM
; ---------------------------------------------------------------------------

loc_3E2A:                               ; ...
                add     al, 0Ah
                cmp     al, cl
                jz      short loc_3E31
                retn
; ---------------------------------------------------------------------------

loc_3E31:                               ; ...
                jmp     Scrolling_Overlay_EntryPoint
render_hero_sword endp


; =============== S U B R O U T I N E =======================================


Render_Scrolling_Transition_Overlay proc near ; ...

; FUNCTION CHUNK AT 3FD0 SIZE 000000B6 BYTES

                test    byte ptr ds:sword_swing_flag, 0FFh
                jnz     short loc_3E3C
                retn
; ---------------------------------------------------------------------------

loc_3E3C:                               ; ...
                push    es
                push    si
                push    di
                push    bx
                mov     es, word ptr cs:seg1
                inc     byte ptr ds:sword_down_thrust
                mov     al, ds:sword_hit_type
                or      al, al
                jz      short loc_3EAC
                dec     al
                jz      short loc_3E81
                cmp     byte ptr ds:sword_down_thrust, 5
                jb      short loc_3E5E
                jmp     loc_3F1A
; ---------------------------------------------------------------------------

loc_3E5E:                               ; ...
                xor     cl, cl
                mov     si, 0B16Eh
                mov     ds:hero_sprite_offset, 0FF01h
                mov     dx, 9F8h
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3EEE
                mov     si, 0B0BEh
                mov     ds:hero_sprite_offset, 1
                mov     dx, 0A00h
                jmp     short loc_3EEE
; ---------------------------------------------------------------------------

loc_3E81:                               ; ...
                cmp     byte ptr ds:sword_down_thrust, 5
                jb      short loc_3E8B
                jmp     loc_3F1A
; ---------------------------------------------------------------------------

loc_3E8B:                               ; ...
                mov     bl, ds:sword_down_thrust
                dec     bl
                xor     bh, bh
                mov     cl, bl
                add     bx, bx
                mov     di, 0B19Eh
                mov     si, 0B12Eh
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3ED2
                mov     di, 0B18Ah
                mov     si, 0B07Eh
                jmp     short loc_3ED2
; ---------------------------------------------------------------------------

loc_3EAC:                               ; ...
                cmp     byte ptr ds:sword_down_thrust, 7
                jnb     short loc_3F1A
                mov     bl, ds:sword_down_thrust
                dec     bl
                xor     bh, bh
                mov     cl, bl
                add     bx, bx
                mov     di, 0B192h
                mov     si, 0B0CEh
                test    byte ptr ds:facing_direction, 1
                jnz     short loc_3ED2
                mov     di, 0B17Eh
                mov     si, 0B01Eh

loc_3ED2:                               ; ...
                mov     bx, es:[bx+di]
                mov     ds:hero_sprite_offset, bx
                mov     al, bl
                cbw
                mov     dx, 0A00h
                imul    dx
                mov     dx, ax
                mov     al, bh
                cbw
                add     ax, ax
                add     ax, ax
                add     ax, ax
                add     dx, ax

loc_3EEE:                               ; ...
                mov     di, ds:hero_vram_base
                add     di, dx
                test    byte ptr ds:squat_flag, 0FFh
                jz      short loc_3EFF
                add     di, 0A00h

loc_3EFF:                               ; ...
                mov     ds:entity_vram_src, di
                xor     ch, ch
                add     cx, cx
                add     cx, cx
                add     cx, cx
                add     cx, cx
                add     si, cx
                mov     ds:entity_shadow_src, si
                pop     bx
                pop     di
                pop     si
                pop     es
                jmp     Scrolling_Overlay_EntryPoint
; ---------------------------------------------------------------------------

loc_3F1A:                               ; ...
                mov     byte ptr ds:sword_swing_flag, 0
                mov     byte ptr ds:sword_down_thrust, 0
                pop     bx
                pop     di
                pop     si
                pop     es
                retn
Render_Scrolling_Transition_Overlay endp


; =============== S U B R O U T I N E =======================================


Flush_Ui_Element_If_Dirty proc near     ; ...
                test    byte ptr ds:ui_element_dirty, 0FFh
                jnz     short loc_3F31
                retn
; ---------------------------------------------------------------------------

loc_3F31:                               ; ...
                push    es
                push    di
                push    si
                push    bx
                call    Blit32x32SpriteToVram
                pop     bx
                pop     si
                pop     di
                pop     es
                mov     byte ptr ds:ui_element_dirty, 0
                retn
Flush_Ui_Element_If_Dirty endp


; =============== S U B R O U T I N E =======================================


CopyTempBufferToVRAM_RowMajor proc near ; ...
                push    ds
                mov     si, cs:entity_vram_src
                mov     ax, 0A000h
                mov     ds, ax
                assume ds:nothing
                mov     es, ax
                assume es:nothing
                mov     di, 64064
                mov     cx, 20h ; ' '

loc_3F55:                               ; ...
                push    cx
                mov     cx, 10h
                rep movsw
                add     si, 120h
                pop     cx
                loop    loc_3F55
                pop     ds
                assume ds:nothing
                retn
CopyTempBufferToVRAM_RowMajor endp


; =============== S U B R O U T I N E =======================================


Blit32x32SpriteToVram proc near         ; ...
                push    ds
                mov     di, cs:entity_vram_src
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                assume ds:nothing
                mov     si, 64064
                mov     cx, 20h ; ' '

loc_3F77:                               ; ...
                push    cx
                mov     cx, 10h
                rep movsw
                add     di, 120h
                pop     cx
                loop    loc_3F77
                pop     ds
                assume ds:nothing
                retn
Blit32x32SpriteToVram endp


; =============== S U B R O U T I N E =======================================


Clear_Tile_Cache_Around_Hero        proc near               ; ...
                mov     al, ds:hero_head_y_in_viewport      ; hero_head_y_in_viewport
                add     al, byte ptr ds:hero_sprite_offset
                and     al, 3Fh
                mov     cl, 36
                mul     cl
                mov     cl, ds:hero_x_in_viewport      ; hero_x_in_viewport
                add     cl, byte ptr ds:hero_sprite_offset+1
                add     cl, 4
                xor     ch, ch
                add     ax, cx
                mov     si, ax
                add     si, ds:viewport_left_top_addr
                call    wrap_e900_from_above
                mov     cx, 4

loc_3FAE:                               ; ...
                push    cx
                mov     cx, 4

loc_3FB2:                               ; ...
                push    cx
                mov     bl, [si]
                inc     si
                and     bl, 7Fh
                xor     bh, bh
                add     bx, bx
                mov     word ptr ds:tile_vram_cache[bx], 0
                pop     cx
                loop    loc_3FB2
                add     si, 32
                call    wrap_e900_from_above
                pop     cx
                loop    loc_3FAE
                retn
Clear_Tile_Cache_Around_Hero        endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR render_hero_sword
;   ADDITIONAL PARENT FUNCTION Render_Scrolling_Transition_Overlay

Scrolling_Overlay_EntryPoint:           ; ...
                test    byte ptr ds:sword_swing_flag, 0FFh
                jnz     short loc_3FD8
                retn
; ---------------------------------------------------------------------------

loc_3FD8:                               ; ...
                mov     byte ptr ds:ui_element_dirty, 0FFh
                push    es
                push    ds
                push    di
                push    si
                push    bx
                call    Clear_Tile_Cache_Around_Hero
                call    CopyTempBufferToVRAM_RowMajor
                xor     bx, bx
                mov     bl, cs:92h
                dec     bl
                add     bx, bx
                mov     ax, cs:entity_render_tbl[bx]
                mov     cs:entity_dim_info, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     di, cs:entity_vram_src
                mov     si, cs:entity_shadow_src
                mov     cx, 4

loc_4013:                               ; ...
                push    cx
                push    di
                mov     cx, 4

loc_4018:                               ; ...
                push    cx
                lodsb
                cmp     al, 0FFh
                jnz     short loc_4024
                add     di, 0A00h
                jmp     short loc_4076
; ---------------------------------------------------------------------------

loc_4024:                               ; ...
                push    si
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     ax, ax
                add     ax, ax
                mov     si, ax
                add     si, ds:0B000h
                mov     cx, 8

loc_4038:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di], bp
                or      es:[di], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+2], bp
                or      es:[di+2], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+4], bp
                or      es:[di+4], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+6], bp
                or      es:[di+6], dx
                add     di, 140h
                pop     cx
                loop    loc_4038
                pop     si

loc_4076:                               ; ...
                pop     cx
                loop    loc_4018
                pop     di
                add     di, 8
                pop     cx
                loop    loc_4013
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                assume es:nothing
                retn
; END OF FUNCTION CHUNK FOR render_hero_sword
; ---------------------------------------------------------------------------
entity_render_tbl       dw 901h                 ; ...
                dw 2404h
                dw 1B03h
                dw 901h
                dw 2404h
                dw 3606h

; =============== S U B R O U T I N E =======================================


CalculateSpriteBitmask proc near        ; ...
                xor     bp, bp
                xor     dx, dx
                xor     bl, bl
                add     ax, ax
                adc     bl, bl
                add     ax, ax
                adc     bl, bl
                jz      short loc_40B5
                or      bp, 0FFh
                mov     dl, byte ptr cs:entity_dim_info+1
                cmp     bl, 3
                jz      short loc_40B5
                mov     dl, byte ptr cs:entity_dim_info

loc_40B5:                               ; ...
                xor     bl, bl
                add     ax, ax
                adc     bl, bl
                add     ax, ax
                adc     bl, bl
                jnz     short loc_40C2
                retn
; ---------------------------------------------------------------------------

loc_40C2:                               ; ...
                or      bp, 0FF00h
                mov     dh, byte ptr cs:entity_dim_info+1
                cmp     bl, 3
                jnz     short loc_40D1
                retn
; ---------------------------------------------------------------------------

loc_40D1:                               ; ...
                mov     dh, byte ptr cs:entity_dim_info
                retn
CalculateSpriteBitmask endp


; =============== S U B R O U T I N E =======================================


Calculate_Tile_VRAM_Address proc near   ; ...
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
                mov     ds:hero_vram_base, di
                jmp     short loc_40FD
Calculate_Tile_VRAM_Address endp


; =============== S U B R O U T I N E =======================================


Copy_Tile_Buffer_To_VRAM proc near      ; ...
                test    byte ptr ds:hero_sprite_hidden, 0FFh
                jz      short loc_40F8
                retn
; ---------------------------------------------------------------------------

loc_40F8:                               ; ...
                mov     byte ptr ds:hero_sprite_hidden, 0FFh

loc_40FD:                               ; ...
                push    es
                push    ds
                push    si
                push    di
                push    bx
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     si, 511Dh
                mov     di, cs:hero_vram_base
                mov     cx, 3

loc_4112:                               ; ...
                push    cx
                mov     cx, 3

loc_4116:                               ; ...
                push    cx
                push    di
                call    Copy_tile
                pop     di
                add     di, 8
                pop     cx
                loop    loc_4116
                add     di, 9E8h
                pop     cx
                loop    loc_4112
                pop     bx
                pop     di
                pop     si
                pop     ds
                pop     es
                assume es:nothing
                retn
Copy_Tile_Buffer_To_VRAM endp


; =============== S U B R O U T I N E =======================================

; AL: tile index
; DI: screen address

Uncompress_And_Render_Tile proc near    ; ...
                push    ds
                push    si
                dec     al
                mov     cl, 30h ; '0'
                mul     cl
                add     ax, 8030h
                mov     si, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                add     di, di
                mov     cx, 8

loc_414B:                               ; ...
                push    cx
                mov     cx, 2

loc_414F:                               ; ...
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1
                or      dh, dh
                jz      short loc_4162
                mov     es:[di], dh

loc_4162:                               ; ...
                shr     dl, 1
                shr     dl, 1
                or      dl, dl
                jz      short loc_416E
                mov     es:[di+1], dl

loc_416E:                               ; ...
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh
                jz      short loc_417B
                mov     es:[di+2], bh

loc_417B:                               ; ...
                and     al, 3Fh
                jz      short loc_4183
                mov     es:[di+3], al

loc_4183:                               ; ...
                add     di, 4
                loop    loc_414F
                add     di, 312
                pop     cx
                loop    loc_414B
                pop     si
                pop     ds
                retn
Uncompress_And_Render_Tile endp


; =============== S U B R O U T I N E =======================================


Render_Viewport_Tiles proc near         ; ...
                mov     byte ptr ds:ui_element_dirty, 0
                mov     ax, 0A000h
                mov     es, ax
                mov     ds:tile_anim_frame_counter, 8

loc_41A1:                               ; ...
                mov     ds:viewport_row_vram_addr, 11B0h
                mov     byte ptr ds:frame_timer, 0
                mov     si, ds:viewport_left_top_addr
                mov     di, viewport_buffer_28x19
                mov     cx, 18          ; rows

loc_41B6:                               ; ...
                push    cx
                add     si, 4           ; skip 4 tiles to the left of viewport
                xor     bx, bx
                mov     cx, 28          ; 28 tiles within viewport

loc_41BF:                               ; ...
                push    cx
                lodsb
                call    render_tile
                inc     di
                inc     bl
                pop     cx
                loop    loc_41BF
                add     si, 4           ; skip 4 tiles to the right of viewport
                call    wrap_e900_from_above
                add     ds:viewport_row_vram_addr, 0A00h
                pop     cx
                loop    loc_41B6

wait_frame_timer:
                cmp     byte ptr ds:frame_timer, 10h
                jb      short wait_frame_timer
                dec     ds:tile_anim_frame_counter
                jnz     short loc_41A1
                retn
Render_Viewport_Tiles endp


; =============== S U B R O U T I N E =======================================


render_tile     proc near               ; ...

; FUNCTION CHUNK AT 42A5 SIZE 00000024 BYTES

                cmp     byte ptr [di], 0FFh
                jnz     short loc_41ED
                retn
; ---------------------------------------------------------------------------

loc_41ED:                               ; ...
                cmp     byte ptr [di], 0FCh
                jnz     short loc_41F3
                retn
; ---------------------------------------------------------------------------

loc_41F3:                               ; ...
                push    ds
                push    di
                push    si
                push    bx
                push    ax
                mov     ah, ds:tile_anim_frame_counter
                dec     ah
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                sbb     ax, ax
                xor     ax, 0FF00h
                mov     ds:tile_render_mask, ax
                add     bx, bx
                add     bx, bx
                add     bx, bx
                add     bx, ds:viewport_row_vram_addr
                mov     di, bx
                pop     ax
                test    al, 0FFh
                jnz     short loc_4220
                jmp     RenderTileRowClear
; ---------------------------------------------------------------------------

loc_4220:                               ; ...
                dec     al
                mov     cl, 30h ; '0'
                mul     cl
                add     ax, 8030h
                mov     si, ax
                mov     ds, word ptr cs:seg1
                push    si
                push    di
                mov     al, cs:tile_anim_frame_counter
                and     al, 3
                neg     al
                add     al, 3
                call    CalculateTileOffset
                call    RenderTileRowWithMask
                pop     di
                pop     si
                mov     al, cs:tile_anim_frame_counter
                call    CalculateTileOffset
                add     di, 4
                add     si, 3
                call    RenderTileRowWithMask
                pop     bx
                pop     si
                pop     di
                pop     ds
                retn
render_tile     endp


; =============== S U B R O U T I N E =======================================


RenderTileRowWithMask proc near         ; ...
                mov     cx, 2

loc_425C:                               ; ...
                push    cx
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1
                shr     dl, 1
                shr     dl, 1
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh
                and     al, 3Fh
                mov     bl, al
                xchg    dh, dl
                xchg    bh, bl
                mov     ax, cs:tile_render_mask
                not     ax
                and     es:[di], ax
                and     es:[di+2], ax
                not     ax
                and     ax, dx
                or      es:[di], ax
                mov     ax, cs:tile_render_mask
                and     ax, bx
                or      es:[di+2], ax
                add     di, 500h
                add     si, 15h
                pop     cx
                loop    loc_425C
                retn
RenderTileRowWithMask endp

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR render_tile

RenderTileRowClear:                     ; ...
                push    di
                mov     al, cs:tile_anim_frame_counter
                and     al, 3
                neg     al
                add     al, 3
                call    CalculateTileOffset
                call    ClearTileRowWithMask
                pop     di
                mov     al, cs:tile_anim_frame_counter
                call    CalculateTileOffset
                add     di, 4
                call    ClearTileRowWithMask
                pop     bx
                pop     si
                pop     di
                pop     ds
                retn
; END OF FUNCTION CHUNK FOR render_tile

; =============== S U B R O U T I N E =======================================


ClearTileRowWithMask proc near          ; ...
                mov     ax, cs:tile_render_mask
                not     ax
                and     es:[di], ax
                and     es:[di+2], ax
                add     di, 500h
                and     es:[di], ax
                and     es:[di+2], ax
                retn
ClearTileRowWithMask endp


; =============== S U B R O U T I N E =======================================


CalculateTileOffset proc near           ; ...
                and     al, 3
                xor     ah, ah
                push    ax
                mov     bx, 6
                mul     bl
                add     si, ax
                pop     ax
                mov     bx, 140h
                mul     bx
                add     di, ax
                retn
CalculateTileOffset endp


; =============== S U B R O U T I N E =======================================


Render_Viewport_Border_Walls proc near  ; ...
                mov     al, ds:hero_x_in_viewport      ; hero_x_in_viewport
                add     al, al
                add     al, al
                add     al, al
                mov     ah, ds:hero_head_y_in_viewport      ; hero_head_y_in_viewport
                add     ah, ah
                add     ah, ah
                add     ah, ah
                mov     byte ptr ds:nibble_decode_lut, al
                mov     byte ptr ds:nibble_decode_lut+1, ah
                call    DrawDitheredPattern
                mov     ds:tile_anim_frame_counter, 36h ; '6'
                call    RenderBorderRings
                mov     ds:tile_anim_frame_counter, 0
                call    RenderBorderRings
                jmp     DrawDitheredPattern
Render_Viewport_Border_Walls endp


; =============== S U B R O U T I N E =======================================


RenderBorderRings proc near             ; ...
                mov     al, byte ptr ds:nibble_decode_lut
                dec     al
                mov     bl, al
                add     al, 19h
                mov     dl, al
                mov     al, byte ptr ds:nibble_decode_lut+1
                dec     al
                mov     bh, al
                add     al, 19h
                mov     dh, al
                call    RenderBorderSegment
                mov     al, byte ptr ds:nibble_decode_lut
                sub     al, 5
                mov     bl, al
                add     al, 21h ; '!'
                mov     dl, al
                mov     al, byte ptr ds:nibble_decode_lut+1
                sub     al, 5
                mov     bh, al
                add     al, 21h ; '!'
                mov     dh, al
                call    RenderBorderSegment
                mov     al, byte ptr ds:nibble_decode_lut
                sub     al, 9
                mov     bl, al
                add     al, 29h ; ')'
                mov     dl, al
                mov     al, byte ptr ds:nibble_decode_lut+1
                sub     al, 9
                mov     bh, al
                add     al, 29h ; ')'
                mov     dh, al
RenderBorderRings endp


; =============== S U B R O U T I N E =======================================


RenderBorderSegment proc near           ; ...
                mov     cx, 9

loc_4372:                               ; ...
                push    cx
                push    dx
                push    bx
                call    RenderOrthogonalSegments
                pop     bx
                pop     dx
                sub     bl, 0Ch
                jnb     short loc_4381
                xor     bl, bl

loc_4381:                               ; ...
                sub     bh, 0Ch
                jnb     short loc_4388
                xor     bh, bh

loc_4388:                               ; ...
                add     dl, 0Ch
                jnb     short loc_438F
                mov     dl, 0FFh

loc_438F:                               ; ...
                add     dh, 0Ch
                jnb     short loc_4396
                mov     dh, 0FFh

loc_4396:                               ; ...
                push    dx
                push    bx
                call    WaitForVBlankAndDelay
                pop     bx
                pop     dx
                pop     cx
                loop    loc_4372
                retn
RenderBorderSegment endp


; =============== S U B R O U T I N E =======================================


RenderOrthogonalSegments proc near      ; ...
                mov     ax, 0A000h
                mov     es, ax
                push    dx
                push    bx
                mov     dh, bh
                call    DrawHorizontalLine
                pop     bx
                pop     dx
                push    dx
                push    bx
                mov     bh, dh
                call    DrawHorizontalLine
                pop     bx
                pop     dx
                push    dx
                push    bx
                mov     dl, bl
                call    DrawVerticalLine
                pop     bx
                pop     dx
                mov     bl, dl
RenderOrthogonalSegments endp


; =============== S U B R O U T I N E =======================================


DrawVerticalLine proc near              ; ...
                cmp     dh, bh
                jnb     short loc_43C9
                xchg    dx, bx

loc_43C9:                               ; ...
                or      bl, bl
                jnz     short loc_43CE
                retn
; ---------------------------------------------------------------------------

loc_43CE:                               ; ...
                cmp     bl, 0DFh
                jb      short loc_43D4
                retn
; ---------------------------------------------------------------------------

loc_43D4:                               ; ...
                or      bh, bh
                jnz     short loc_43DA
                mov     bh, 1

loc_43DA:                               ; ...
                cmp     dh, 8Fh
                jb      short loc_43E1
                mov     dh, 8Eh

loc_43E1:                               ; ...
                mov     al, dh
                sub     al, bh
                inc     al
                push    ax
                mov     al, bh
                call    CalculateRowVRAMAddress
                mov     al, bl
                xor     ah, ah
                add     di, ax
                pop     cx
                xor     ch, ch
                mov     ah, ds:tile_anim_frame_counter

loc_43FA:                               ; ...
                mov     es:[di], ah
                add     di, 140h
                loop    loc_43FA
                retn
DrawVerticalLine endp


; =============== S U B R O U T I N E =======================================


DrawHorizontalLine proc near            ; ...
                cmp     dl, bl
                jnb     short loc_440A
                xchg    dx, bx

loc_440A:                               ; ...
                or      bh, bh
                jnz     short loc_440F
                retn
; ---------------------------------------------------------------------------

loc_440F:                               ; ...
                cmp     bh, 8Fh
                jb      short loc_4415
                retn
; ---------------------------------------------------------------------------

loc_4415:                               ; ...
                or      bl, bl
                jnz     short loc_441B
                mov     bl, 1

loc_441B:                               ; ...
                cmp     dl, 0DFh
                jb      short loc_4422
                mov     dl, 0DEh

loc_4422:                               ; ...
                mov     al, bh
                call    CalculateRowVRAMAddress
                mov     al, bl
                xor     ah, ah
                add     di, ax
                mov     ah, dl
                sub     ah, al
                mov     cl, ah
                xor     ch, ch
                mov     al, ds:tile_anim_frame_counter
                rep stosb
                retn
DrawHorizontalLine endp


; =============== S U B R O U T I N E =======================================


CalculateRowVRAMAddress proc near       ; ...
                push    dx
                xor     ah, ah
                mov     di, 140h
                mul     di
                add     ax, 11B0h
                mov     di, ax
                pop     dx
                retn
CalculateRowVRAMAddress endp


; =============== S U B R O U T I N E =======================================


WaitForVBlankAndDelay proc near         ; ...
                mov     cl, ds:speed_const
                shr     cl, 1
                inc     cl
                mov     al, 1
                mul     cl

loc_4456:                               ; ...
                push    ax
                call    word ptr cs:Confirm_Exit_Dialog_proc
                call    word ptr cs:Handle_Pause_State_proc
                call    word ptr cs:Handle_Speed_Change_proc
                call    word ptr cs:Joystick_Calibration_proc
                call    word ptr cs:Joystick_Deactivator_proc
                pop     ax
                cmp     ds:frame_timer, al
                jb      short loc_4456
                mov     byte ptr ds:frame_timer, 0 ; frame_timer
                retn
WaitForVBlankAndDelay endp


; =============== S U B R O U T I N E =======================================


DrawDitheredPattern proc near           ; ...
                mov     ax, 0A000h
                mov     es, ax
                mov     di, 11B0h
                mov     cx, 8

loc_4488:                               ; ...
                push    cx
                push    di
                mov     cx, 12h

loc_448D:                               ; ...
                push    cx
                push    di
                mov     ax, 1001000010010b
                mov     cx, 112         ; 28*8/2

loc_4495:                               ; ...
                xor     es:[di], ax
                inc     di
                inc     di
                loop    loc_4495
                pop     di
                add     di, 320*8
                pop     cx
                loop    loc_448D
                pop     di
                add     di, 320
                pop     cx
                loop    loc_4488
                retn
DrawDitheredPattern endp


; =============== S U B R O U T I N E =======================================

; AL: y
; AH: x
; Returns video memory address in DI

Viewport_Coords_To_Screen_Addr proc near ; ...
                and     al, 3Fh
                mov     bl, ah
                xor     ah, ah
                mov     dx, 8*320
                mul     dx
                sub     bl, 4
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                add     bx, bx
                add     ax, bx
                mov     di, ax
                add     di, 14*320+48
                shr     di, 1
                retn
Viewport_Coords_To_Screen_Addr endp


; =============== S U B R O U T I N E =======================================


Load_Sprite_Sheet proc near             ; ...
                mov     bl, ds:9Dh
                or      bl, bl
                jz      short loc_44F7
                cmp     bl, 7
                jz      short loc_44F7
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     es, word ptr cs:seg1
                assume es:nothing
                mov     ax, cs
                add     ax, 2000h
                mov     ds, ax
                assume ds:nothing
                mov     si, [bx]
                mov     di, 9350h
                mov     cx, 480h
                rep movsb

loc_44F7:                               ; ...
                mov     ds, word ptr cs:seg1
                assume ds:nothing
                mov     si, 9350h
                retn
Load_Sprite_Sheet endp


; =============== S U B R O U T I N E =======================================


wrap_e900_from_above proc near          ; ...
                cmp     si, viewport_buffer_28x19
                jnb     short loc_4507
                retn
; ---------------------------------------------------------------------------

loc_4507:                               ; ...
                sub     si, 900h
                retn
wrap_e900_from_above endp


; =============== S U B R O U T I N E =======================================


wrap_e000_from_below proc near          ; ...
                cmp     si, 0E000h
                jb      short loc_4513
                retn
; ---------------------------------------------------------------------------

loc_4513:                               ; ...
                add     si, 900h
                retn
wrap_e000_from_below endp


; =============== S U B R O U T I N E =======================================


Render_Animated_Tile_Strip proc near    ; ...
                push    si
                push    ds
                mov     cs:entity_dim_info, 1210h
                mov     si, offset sword_hit_pattern_tbl
                mov     di, 3230h
                mov     ax, 0A000h
                mov     es, ax
                assume es:nothing
                mov     cx, 5

loc_452F:                               ; ...
                push    cx
                mov     cx, 28

loc_4533:                               ; ...
                push    cx
                lodsb
                push    ds
                push    si
                mov     ds, word ptr cs:seg1
                xor     ah, ah
                add     ax, ax          ; *2
                add     ax, ax          ; *4
                add     ax, ax          ; *8
                add     ax, ax          ; *16
                add     ax, 4000h
                mov     si, ax
                push    di
                mov     cx, 8

loc_454F:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                mov     es:[di], dx
                call    CalculateSpriteBitmask
                mov     es:[di+2], dx
                call    CalculateSpriteBitmask
                mov     es:[di+4], dx
                call    CalculateSpriteBitmask
                mov     es:[di+6], dx
                add     di, 140h
                pop     cx
                loop    loc_454F
                pop     di
                add     di, 8
                pop     si
                pop     ds
                pop     cx
                loop    loc_4533
                add     di, 920h
                pop     cx
                loop    loc_452F
                pop     ds
                pop     si
                retn
Render_Animated_Tile_Strip endp

; ---------------------------------------------------------------------------
sword_hit_pattern_tbl       db 0, 1, 2, 4, 7, 9, 0Dh, 10h, 4, 15h, 17h, 1Ch, 1Eh, 4 ; ...
                db 7, 9, 22h, 2, 25h, 8, 2, 28h, 2, 2Dh, 31h, 36h, 3Bh
                db 40h
                db 0, 1, 3, 6, 8, 0Ah, 0Eh, 11h, 6, 8, 18h, 0Eh, 1Eh, 4
                db 8, 0Ah, 23h, 24h, 26h, 8, 27h, 29h, 2Ah, 4, 32h, 37h
                db 3Ch, 6
                db 0, 1, 2, 5, 8, 2, 0Eh, 12h, 6, 8, 19h, 0Eh, 1Eh, 4
                db 8, 2, 23h, 24h, 26h, 8, 25h, 29h, 2, 2Eh, 33h, 38h
                db 3Dh, 6
                db 0, 1, 3, 6, 8, 0Bh, 0Eh, 13h, 6, 8, 1Ah, 0Eh, 1Fh, 4
                db 8, 0Bh, 23h, 24h, 26h, 8, 27h, 29h, 2Bh, 2Fh, 34h, 39h
                db 3Eh, 6
                db 0, 1, 2, 4, 8, 0Ch, 0Fh, 14h, 4, 16h, 1Bh, 1Dh, 20h
                db 21h, 8, 0Ch, 23h, 24h, 26h, 8, 2, 28h, 2Ch, 30h, 35h
                db 3Ah, 3Fh, 6

; =============== S U B R O U T I N E =======================================


Render_Tilemap_With_Palette proc near   ; ...
                mov     ds:tile_anim_frame_counter, al
                mov     si, offset tile_palette_map
                mov     ds:viewport_row_vram_addr, 11B0h
                mov     cx, 18

loc_4623:                               ; ...
                push    cx
                mov     cx, 28

loc_4627:                               ; ...
                push    cx
                lodsb
                push    si
                call    RenderTileFrom_seg1
                pop     si
                add     ds:viewport_row_vram_addr, 8
                pop     cx
                loop    loc_4627
                add     ds:viewport_row_vram_addr, 920h
                pop     cx
                loop    loc_4623
                retn
Render_Tilemap_With_Palette endp


; =============== S U B R O U T I N E =======================================


RenderTileFrom_seg1 proc near           ; ...
                push    ds
                mov     cl, 48
                mul     cl
                add     ax, 8000h
                mov     si, ax
                mov     ds, word ptr cs:seg1 ; seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     di, cs:viewport_row_vram_addr
                mov     cx, 8

loc_465C:                               ; ...
                push    cx
                call    RenderTileWithPaletteTransform
                add     di, 312
                pop     cx
                loop    loc_465C
                pop     ds
                retn
RenderTileFrom_seg1 endp


; =============== S U B R O U T I N E =======================================


RenderTileWithPaletteTransform proc near ; ...
                mov     cx, 2

loc_466C:                               ; ...
                push    cx
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1
                mov     es:[di], dh
                shr     dl, 1
                shr     dl, 1
                mov     es:[di+1], dl
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh
                mov     es:[di+2], bh
                and     al, 3Fh
                mov     es:[di+3], al
                mov     bl, cs:tile_anim_frame_counter
                xor     bh, bh
                add     bx, bx
                mov     cx, 4

loc_46A1:                               ; ...
                mov     al, es:[di]
                or      al, al
                jz      short loc_46CD
                mov     ah, al
                shr     ah, 1
                shr     ah, 1
                shr     ah, 1
                call    cs:PaletteTransformTable[bx]
                add     ah, ah
                add     ah, ah
                add     ah, ah
                and     al, 7
                or      al, ah
                mov     ah, al
                and     ah, 7
                call    cs:PaletteTransformTable[bx]
                and     al, 38h
                or      al, ah

loc_46CD:                               ; ...
                stosb
                loop    loc_46A1
                pop     cx
                loop    loc_466C
                retn
RenderTileWithPaletteTransform endp

; ---------------------------------------------------------------------------
PaletteTransformTable dw offset PaletteTransform_0 ; ...
                dw offset PaletteTransform_1
                dw offset PaletteTransform_2
                dw offset PaletteTransform_3
                dw offset PaletteTransform_4

; =============== S U B R O U T I N E =======================================


PaletteTransform_0 proc near            ; ...
                cmp     ah, 6
                jnz     short loc_46E6
                mov     ah, 3
                retn
; ---------------------------------------------------------------------------

loc_46E6:                               ; ...
                cmp     ah, 7
                jz      short loc_46EC
                retn
; ---------------------------------------------------------------------------

loc_46EC:                               ; ...
                mov     ah, 5
                retn
PaletteTransform_0 endp


; =============== S U B R O U T I N E =======================================


PaletteTransform_1 proc near            ; ...
                cmp     ah, 4
                jz      short loc_46F5
                retn
; ---------------------------------------------------------------------------

loc_46F5:                               ; ...
                mov     ah, 2
                retn
PaletteTransform_1 endp


; =============== S U B R O U T I N E =======================================


PaletteTransform_2 proc near            ; ...
                cmp     ah, 4
                jnz     short loc_4700
                mov     ah, 5
                retn
; ---------------------------------------------------------------------------

loc_4700:                               ; ...
                cmp     ah, 7
                jz      short loc_4706
                retn
; ---------------------------------------------------------------------------

loc_4706:                               ; ...
                mov     ah, 4
                retn
PaletteTransform_2 endp


; =============== S U B R O U T I N E =======================================


PaletteTransform_3 proc near            ; ...
                cmp     ah, 4
                jnz     short loc_4711
                mov     ah, 3
                retn
; ---------------------------------------------------------------------------

loc_4711:                               ; ...
                cmp     ah, 7
                jnz     short loc_4719
                mov     ah, 5
                retn
; ---------------------------------------------------------------------------

loc_4719:                               ; ...
                cmp     ah, 6
                jz      short loc_471F
                retn
; ---------------------------------------------------------------------------

loc_471F:                               ; ...
                mov     ah, 7
                retn
PaletteTransform_3 endp


; =============== S U B R O U T I N E =======================================


PaletteTransform_4 proc near            ; ...
                cmp     ah, 7
                jnz     short loc_472A
                mov     ah, 5
                retn
; ---------------------------------------------------------------------------

loc_472A:                               ; ...
                cmp     ah, 4
                jnz     short loc_4732
                mov     ah, 7
                retn
; ---------------------------------------------------------------------------

loc_4732:                               ; ...
                cmp     ah, 6
                jz      short loc_4738
                retn
; ---------------------------------------------------------------------------

loc_4738:                               ; ...
                mov     ah, 4
                retn
PaletteTransform_4 endp

; ---------------------------------------------------------------------------
tile_palette_map       db 7, 8, 9, 0Ah, 7, 8, 0Bh, 0Ch, 7, 8, 9, 0Ah, 19h, 3Dh ; ...
                db 61h, 27h, 1Dh, 1Eh, 1Dh, 1Eh, 1Fh, 20h, 1Fh, 20h, 1Dh
                db 1Eh, 1Fh, 20h
                db 0Dh, 0Eh, 0Fh, 10h, 0Fh, 10h, 0Dh, 0Eh, 0Fh, 10h, 17h
                db 18h, 3Eh, 5Ch, 62h, 26h, 2Ah, 25h, 21h, 22h, 21h, 22h
                db 23h, 24h, 21h, 22h, 21h, 22h
                db 9, 0Ah, 7, 8, 7, 8, 9, 0Ah, 7, 8, 19h, 54h, 59h, 5Dh
                db 63h, 32h, 2Fh, 2Eh, 1Fh, 20h, 1Fh, 20h, 1Dh, 1Eh, 1Fh
                db 20h, 1Fh, 20h
                db 0Fh, 10h, 11h, 12h, 0Fh, 10h, 0Dh, 0Eh, 17h, 18h, 50h
                db 55h, 5Ah, 5Eh, 64h, 66h, 28h, 30h, 23h, 24h, 21h, 22h
                db 23h, 24h, 21h, 22h, 23h, 24h
                db 7, 8, 0Ah, 0Ch, 7, 8, 9, 0Ah, 1Ah, 34h, 51h, 56h, 5Bh
                db 5Fh, 65h, 67h, 2Fh, 2Dh, 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh
                db 1Fh, 20h, 1Dh, 1Eh
                db 0Fh, 10h, 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h, 49h, 4Dh, 52h
                db 57h, 0, 60h, 69h, 68h, 6Ah, 6Bh, 28h, 26h, 21h, 22h
                db 2Bh, 26h, 21h, 22h, 21h, 22h
                db 7, 8, 9, 0Ah, 9, 0Ah, 1Bh, 46h, 4Ah, 4Eh, 53h, 58h
                db 0, 0, 0, 0, 69h, 6Ch, 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh
                db 1Fh, 20h, 1Fh, 20h
                db 13h, 14h, 13h, 14h, 17h, 18h, 43h, 47h, 4Bh, 4Fh, 0
                db 0, 0, 0, 0, 0, 0, 6Dh, 6Eh, 6Fh, 29h, 26h, 21h, 22h
                db 2Ah, 25h, 21h, 22h
                db 15h, 16h, 15h, 16h, 1Ch, 35h, 44h, 48h, 4Ch, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 69h, 71h, 73h, 74h, 1Fh, 20h, 2Ch
                db 27h, 1Fh, 20h
                db 17h, 18h, 38h, 3Ah, 3Fh, 42h, 45h, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 6Dh, 75h, 77h, 79h, 6Fh, 2Bh, 26h
                db 29h, 26h
                db 1Ah, 34h, 39h, 3Bh, 40h, 41h, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 76h, 78h, 7Ah, 7Bh, 31h, 32h, 2Fh
                db 2Dh
                db 33h, 36h, 37h, 3Ch, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 6Dh, 71h, 70h, 72h, 70h
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2
                db 1, 2, 1, 2, 1, 2, 1, 2, 1, 2
                db 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4
                db 3, 4, 3, 4, 3, 4, 3, 4, 3, 4
                db 5, 6, 5, 6, 5, 6, 5, 6, 5, 6, 5, 6, 5, 6, 5, 6, 5, 6
                db 5, 6, 5, 6, 6, 5, 5, 6, 5, 6

; =============== S U B R O U T I N E =======================================


Render_16x16_Sprite proc near           ; ...
                push    ds
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
                mov     cl, 20h ; ' '
                mul     cl
                add     ax, 6000h
                mov     si, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 8

loc_495F:                               ; ...
                push    cx
                lodsw
                mov     dx, ax
                call    Unpack_4MaskBytes
                lodsw
                mov     dx, ax
                call    Unpack_4MaskBytes
                add     di, 138h
                pop     cx
                loop    loc_495F
                pop     ds
                retn
Render_16x16_Sprite endp


; =============== S U B R O U T I N E =======================================


Unpack_4MaskBytes        proc near               ; ...
                mov     cx, 4

loc_4978:                               ; ...
                xor     ax, ax
                add     dx, dx
                adc     ax, ax
                add     dx, dx
                adc     ax, ax
                add     ax, ax
                add     dx, dx
                adc     ax, ax
                add     dx, dx
                adc     ax, ax
                stosb
                loop    loc_4978
                retn
Unpack_4MaskBytes        endp


; =============== S U B R O U T I N E =======================================


Render_Status_Indicator proc near       ; ...
                push    ds
                mov     cs:entity_dim_info, 908h
                mov     bl, ds:92h
                dec     bl
                xor     bh, bh
                add     bx, bx
                mov     si, ds:status_indicator_mask_tbl[bx]
                mov     di, 6C10h
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 18h

loc_49B1:                               ; ...
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di], bp
                or      es:[di], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+2], bp
                or      es:[di+2], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+4], bp
                or      es:[di+4], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+6], bp
                or      es:[di+6], dx
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+8], bp
                or      es:[di+8], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Ah], bp
                or      es:[di+0Ah], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Ch], bp
                or      es:[di+0Ch], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+0Eh], bp
                or      es:[di+0Eh], dx
                add     di, 320
                loop    loc_49B1
                pop     ds
                retn
Render_Status_Indicator endp

; ---------------------------------------------------------------------------
status_indicator_mask_tbl        dw offset status_mask_null     ; ...
                dw offset status_mask_null
                dw offset status_mask_null
                dw offset status_mask_partial
                dw offset status_mask_partial
                dw offset status_mask_full
status_mask_null       db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; ...
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 6, 0, 0, 0, 6
                db 0, 0, 0, 0Eh, 0, 0, 0, 0Eh, 0, 0, 0, 0Ch, 0, 0, 0, 0Eh
                db 0, 0, 0, 1Ch, 0, 0, 0, 0Ch, 0, 0, 0, 1Ch, 0, 0, 0, 1Ch
                db 0, 0, 0, 1Ch, 0, 0, 0, 1Ch, 0, 0
status_mask_partial       db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 80h, 0, 0 ; ...
                db 1, 80h, 0, 0, 3, 80h, 0, 0, 3, 0, 0, 0, 7, 80h, 0, 0
                db 7, 0, 0, 0, 7, 0, 0, 0, 0Fh, 0, 0, 0, 0Eh, 0, 0, 0
                db 0Fh, 0, 0, 0, 1Eh, 0, 0, 0, 0Eh, 0, 0, 0, 1Fh, 0, 0
                db 0, 1Eh, 0, 0, 0, 1Fh, 0, 0, 0, 1Eh, 0, 0, 0, 1Eh, 0
                db 0, 0, 1Eh, 0, 0, 0, 1Eh, 0, 0, 0, 1Ch, 0, 0, 0, 3Fh
                db 0, 0
status_mask_full       db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40h, 0, 0, 0, 0C0h, 0 ; ...
                db 0, 1, 0C0h, 0, 0, 3, 80h, 0, 0, 3, 80h, 0, 0, 7, 80h
                db 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 0Fh, 0, 0, 0, 0Fh, 0
                db 0, 0, 0Eh, 0, 0, 0, 1Fh, 0, 0, 0, 0Eh, 0, 0, 0, 1Fh
                db 0, 0, 0, 1Eh, 0, 0, 0, 1Fh, 0, 0, 0, 1Eh, 0, 0, 0, 1Fh
                db 0, 0, 0, 1Fh, 0, 0, 0, 1Eh, 0, 0, 3, 1Ch, 0C0h, 0, 0
                db 0FFh, 0, 0

; =============== S U B R O U T I N E =======================================


Render_Entity_Sprite proc near          ; ...
                push    ds
                or      al, al
                js      short loc_4B66
                and     al, 3
                mov     dl, 40h ; '@'
                mul     dl
                add     ax, offset sprite_data_base_right
                mov     si, ax
                mov     bp, 1
                jmp     short loc_4B74
; ---------------------------------------------------------------------------

loc_4B66:                               ; ...
                and     al, 1
                mov     ah, al
                xor     al, al
                add     ax, offset sprite_data_base_left
                mov     si, ax
                mov     bp, 4

loc_4B74:                               ; ...
                mov     ax, 320
                xor     ch, ch
                mul     cx
                add     ax, bx
                mov     di, ax
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, bp

loc_4B86:                               ; ...
                push    cx
                push    di
                mov     cx, 16

loc_4B8B:                               ; ...
                push    cx
                push    di
                mov     cx, 2

loc_4B90:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di], bp
                or      es:[di], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+2], bp
                or      es:[di+2], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+4], bp
                or      es:[di+4], dx
                call    CalculateSpriteBitmask
                not     bp
                and     es:[di+6], bp
                or      es:[di+6], dx
                add     di, 8
                pop     cx
                loop    loc_4B90
                pop     di
                add     di, 320
                pop     cx
                loop    loc_4B8B
                pop     di
                add     di, 10h
                pop     cx
                loop    loc_4B86
                pop     ds
                retn
Render_Entity_Sprite endp

; ---------------------------------------------------------------------------
sprite_data_base_right       db 0                    ; ...
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
                db  10h
                db    0
                db    0
                db  10h
                db  60h ; `
                db    0
                db    0
                db    7
                db 0C0h
                db    0
                db    0
                db    7
                db 0C0h
                db    0
                db    0
                db    7
                db 0C0h
                db    0
                db    0
                db  0Ch
                db  10h
                db    0
                db    0
                db  10h
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
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db  40h ; @
                db    4
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    9
                db  20h
                db    0
                db    0
                db    3
                db  80h
                db    0
                db    4
                db  57h ; W
                db 0D4h
                db  80h
                db    0
                db    3
                db  80h
                db    0
                db    0
                db    9
                db  20h
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db  40h ; @
                db    4
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    2
                db  80h
                db    0
                db    0
                db  83h
                db  80h
                db    0
                db    0
                db  23h ; #
                db  88h
                db    0
                db    0
                db  0Dh
                db 0B0h
                db    0
                db    0
                db  0Bh
                db 0E8h
                db    0
                db  96h
                db 0FFh
                db 0FFh
                db 0B9h
                db    0
                db  17h
                db 0E8h
                db    0
                db    0
                db  0Bh
                db  58h ; X
                db    0
                db    0
                db  23h ; #
                db  82h
                db    0
                db    0
                db    2
                db  80h
                db  80h
                db    2
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db  10h
                db  10h
                db    0
                db    0
                db    0
                db    4
                db    0
                db    0
                db  80h
                db    0
                db  80h
                db    3
                db    0
                db    0
                db  71h ; q
                db  0Ch
                db    0
                db    0
                db  3Dh ; =
                db  38h ; 8
                db    0
                db    0
                db    7
                db 0F0h
                db    0
                db    0
                db  97h
                db 0E5h
                db    0
                db    0
                db  0Fh
                db 0F0h
                db    0
                db    0
                db  1Fh
                db  38h ; 8
                db    0
                db    0
                db  39h ; 9
                db  0Eh
                db    0
                db    0
                db 0E1h
                db    1
                db  80h
                db    1
                db    0
                db    0
                db  40h ; @
                db    4
                db    0
                db    0
                db    8
                db  10h
                db    0
                db    0
                db    0
sprite_data_base_left       db 0                    ; ...
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
                db  92h
                db  4Ah ; J
                db 0AAh
                db 0EBh
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
                db    1
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    1
                db    1
                db    0
                db    0
                db    0
                db  82h
                db    0
                db    0
                db    0
                db 0ABh
                db    0
                db    0
                db    1
                db  5Dh ; ]
                db    4
                db  24h ; $
                db 0AEh
                db 0EFh
                db 0FFh
                db 0FFh
                db 0FFh
                db 0FFh
                db    4
                db  24h ; $
                db 0ABh
                db 0EFh
                db    0
                db    0
                db    1
                db  5Dh ; ]
                db    0
                db    0
                db    0
                db  22h ; "
                db    0
                db    0
                db    0
                db  81h
                db    0
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    1
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
                db  81h
                db    0
                db    0
                db    0
                db 0C4h
                db    0
                db    0
                db    0
                db 0BCh
                db    0
                db    0
                db    0
                db 0EEh
                db 0EAh
                db  24h ; $
                db  20h
                db 0FFh
                db 0FFh
                db 0FFh
                db 0FFh
                db 0FBh
                db 0AAh
                db  24h ; $
                db  20h
                db 0FDh
                db  40h ; @
                db    0
                db    0
                db 0E6h
                db    0
                db    0
                db    0
                db  40h ; @
                db  80h
                db    0
                db    0
                db    0
                db  20h
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
                db    0
                db    0
                db    0
                db    0
                db    0
                db 0D7h
                db  55h ; U
                db  52h ; R
                db  49h ; I
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
                db 0A7h
                db  54h ; T
                db  90h
                db    4
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
                db    0
                db  10h
                db    0
                db    0
                db    0
                db    4
                db    0
                db    0
                db    0
                db    0
                db  80h
                db    0
                db    0
                db    0
                db  71h ; q
                db    0
                db    0
                db    0
                db  3Dh ; =
                db    0
                db    0
                db    0
                db    7
                db  10h
                db    4
                db    0
                db  97h
                db    0
                db    0
                db    0
                db  0Fh
                db    0
                db    0
                db    0
                db  1Fh
                db    0
                db    0
                db    0
                db  39h ; 9
                db    0
                db    0
                db    0
                db 0E1h
                db    0
                db    0
                db    1
                db    0
                db    0
                db    0
                db    4
                db    0
                db    0
                db    0
                db  10h
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db  10h
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db  80h
                db    0
                db    0
                db    3
                db    0
                db    0
                db    0
                db  0Ch
                db    0
                db    0
                db    0
                db  38h ; 8
                db    0
                db    0
                db    0
                db 0F0h
                db    0
                db    0
                db    0
                db 0E5h
                db    2
                db    0
                db  10h
                db 0F0h
                db    0
                db    0
                db    0
                db  3Ch ; <
                db    0
                db    0
                db    0
                db    7
                db    0
                db    0
                db    0
                db    0
                db 0C0h
                db    0
                db    0
                db    0
                db  20h
                db    0
                db    0
                db    0
                db    4
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
                db    0
                db  20h
                db    9
                db  2Ah ; *
                db 0E5h
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

; =============== S U B R O U T I N E =======================================


Decompress_Tile_Data proc near          ; ...
                push    cx
                push    ds
                push    si
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax
                assume es:nothing
                mov     ax, 20h ; ' '
                mul     cx
                mov     cx, ax
                mov     di, 0
                rep movsb
                pop     di
                pop     es
                assume es:nothing
                pop     cx
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax
                assume ds:nothing
                mov     si, 0

loc_4F00:                               ; ...
                push    cx
                mov     cx, 8

loc_4F04:                               ; ...
                push    cx
                lodsw
                xchg    ah, al
                mov     dx, ax
                lodsw
                xchg    ah, al
                mov     cx, ax
                mov     cs:viewport_row_vram_addr, dx
                mov     word ptr cs:vram_offset_accum, cx
                or      ax, dx
                mov     bx, ax
                shr     bx, 1
                or      ax, bx
                add     bx, bx
                add     bx, bx
                or      ax, bx
                not     ax
                mov     cs:entity_dim_info, ax
                call    DecodeBitstreamWord
                mov     ax, dx
                stosw
                call    DecodeBitstreamWord
                mov     ax, dx
                stosw
                call    DecodeVariableLengthCode
                mov     es:[bp+0], dl
                inc     bp
                pop     cx
                loop    loc_4F04
                pop     cx
                loop    loc_4F00
                retn
Decompress_Tile_Data endp


; =============== S U B R O U T I N E =======================================


DecodeBitstreamWord proc near           ; ...
                mov     cx, 4

loc_4F4B:                               ; ...
                rol     word ptr cs:vram_offset_accum, 1
                adc     dx, dx
                rol     cs:viewport_row_vram_addr, 1
                adc     dx, dx
                rol     word ptr cs:vram_offset_accum, 1
                adc     dx, dx
                rol     cs:viewport_row_vram_addr, 1
                adc     dx, dx
                loop    loc_4F4B
                retn
DecodeBitstreamWord endp


; =============== S U B R O U T I N E =======================================


DecodeVariableLengthCode proc near      ; ...
                mov     cx, 8

loc_4F6D:                               ; ...
                xor     al, al
                rol     cs:entity_dim_info, 1
                adc     al, al
                rol     cs:entity_dim_info, 1
                adc     al, al
                cmp     al, 3
                jz      short loc_4F83
                xor     al, al

loc_4F83:                               ; ...
                and     al, 1
                add     dl, dl
                or      dl, al
                loop    loc_4F6D
                retn
DecodeVariableLengthCode endp

; ---------------------------------------------------------------------------
pal_decode_tbl     dw offset pal_decode_data
                   dw offset pal_decode_data_1
                   dw offset pal_decode_data_2
                   dw offset pal_decode_data_3
                   dw offset pal_decode_data_4
                   dw offset pal_decode_data_3
pal_decode_data    db 0, 1, 2, 3, 8, 9, 0Ah, 0Bh, 10h, 11h, 12h, 13h, 18h ; ...
                   db 19h, 1Ah, 1Bh
pal_decode_data_1  db 0, 2, 4, 6, 10h, 12h, 14h, 16h, 20h, 22h, 24h, 26h ; ...
                   db 30h, 32h, 34h, 36h
pal_decode_data_2  db 0, 1, 4, 5, 8, 9, 0Ch, 0Dh, 20h, 21h, 24h, 25h, 28h ; ...
                   db 29h, 2Ch, 2Dh
pal_decode_data_3  db 0, 5, 6, 7, 28h, 2Dh, 2Eh, 2Fh, 30h, 35h, 36h, 37h ; ...
                   db 38h, 3Dh, 3Eh, 3Fh
pal_decode_data_4  db 0, 6, 5, 7, 30h, 36h, 35h, 37h, 28h, 2Eh, 2Dh, 2Fh ; ...
                   db 38h, 3Eh, 3Dh, 3Fh

; =============== S U B R O U T I N E =======================================


nullsub_1       proc near
                retn
nullsub_1       endp

; ---------------------------------------------------------------------------
nibble_decode_lut           dw 0       
viewport_row_vram_addr      dw 0       
hero_vram_base              dw 0       
vram_offset_accum           db 2 dup(0)
viewport_rows_remaining     db 0       
hero_tile_col_idx           db 0       
hero_tile_row_idx           db 0       
tile_blit_mode              db 0       
entity_dim_info             dw 0       
entity_vram_src             dw 0       
entity_shadow_src           dw 0       
hero_sprite_offset          dw 0       
tile_render_mask            dw 0       
tile_anim_frame_counter     db 0
tile_load_buffer            db 10h dup(0)
tile_cache_dirty_flags      db 0         
tile_cache_row1_dirty_flags db 0         
                            db    0
                            db    0
tile_neighborhood_buffer    db 9 dup(0)
tile_vram_cache             dw 128 dup(0)
sword_anim_frames           db 576 dup(0)

gfmcga          ends


                end    start
