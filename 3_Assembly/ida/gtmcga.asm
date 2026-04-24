include common.inc
include town.inc
                .286
                .model small

gtmcga          segment byte public 'CODE' use16
                assume cs:gtmcga
                org 3000h
                assume es:gtmcga, ds:gtmcga

start           dw offset apply_screen_xor_grid
                dw offset backup_upper_town_3_tiles ; skips top 8 tiles (sky, distant mountains)
                                        ; saves town top (3 tiles of 8) to screen buffer
                dw offset render_town_tiles_28_columns
                dw offset scroll_hud_right_8px
                dw offset scroll_hud_right_4px
                dw offset scroll_hud_left_8px
                dw offset scroll_hud_left_4px
                dw offset unpack_to_shadow_memory_six_tiles
                dw offset ui_draw_routine_dispatcher
                dw offset blit_6_tiles_to_shadow_memory
                dw offset get_sprite_vram_address
                dw offset draw_tile_to_screen ; AL: glyph id
                                        ; seg1:8000 packed 48-byte tiles
                                        ; BH: x in tiles
                                        ; BL: y in screen coords
                dw offset draw_arrow_icon_or_ui_symbol
                dw offset format_string_to_buffer
                dw offset draw_string_buffer_to_screen ; BL=y
                                        ; BH=x
                dw offset scroll_hud_up
                dw offset scroll_hud_down
                dw offset render_numeric_score
                dw offset decompress_patterns
                dw offset apply_sprite_mask

; =============== S U B R O U T I N E =======================================

; skips top 8 tiles (sky, distant mountains)
; saves town top (3 tiles of 8) to screen buffer

backup_upper_town_3_tiles proc near
                push    ds
                mov     si, 48+(14+8*8)*320 ;skip 8 top tiles (sky)
                mov     di, screen_buffer
                push    cs
                pop     es
                mov     ax, 0A000h
                mov     ds, ax          ;
                                        ; Screen dimensions:
                                        ; Vert: 14 + 18*8 + 42
                                        ; Horiz: 48 + 28*8 + 48
                mov     cx, 28          ; entire viewport width = 28 tiles

loc_3039:
                push    cx
                push    si
                mov     cx, 24          ; 3 tiles vertically

next_8pix:
                movsw
                movsw
                movsw
                movsw
                add     si, 312
                loop    next_8pix
                pop     si
                pop     cx
                add     si, 8
                loop    loc_3039
                pop     ds
                retn
backup_upper_town_3_tiles endp


; =============== S U B R O U T I N E =======================================


render_town_tiles_28_columns proc near
                push    cs
                pop     es
                mov     di, offset blit_cache
                xor     ax, ax
                mov     cx, 100h
                rep stosw
                mov     si, ds:proximity_start_tiles
                cmp     byte ptr [si+29], 0FDh
                jnz     short loc_306A
                call    pre_pass_special_column_initializer

loc_306A:
                mov     ds:current_column_screen_addr, 48+(14+8*8)*320
                mov     si, ds:proximity_start_tiles
                add     si, 20h ; ' '
                push    cs
                pop     es
                mov     di, 0E000h
                mov     ds:column_counter, 0

next_column:
                call    hero_column_shadow_blitter_guard
                xor     bl, bl
                cmpsb
                jz      short loc_308C
                call    tile_render_and_animate

loc_308C:
                inc     bl
                cmpsb
                jz      short loc_3094
                call    tile_render_and_animate

loc_3094:
                inc     bl
                cmpsb
                jz      short loc_309C
                call    tile_render_and_animate

loc_309C:
                inc     bl
                cmpsb
                jz      short loc_30A4
                call    background_tile_render_with_blit_cache

loc_30A4:
                inc     bl
                cmpsb
                jz      short loc_30AC
                call    background_tile_render_with_blit_cache

loc_30AC:
                inc     bl
                cmpsb
                jz      short loc_30B4
                call    special_tile_dispatcher

loc_30B4:
                inc     bl
                cmpsb
                jz      short loc_30BC
                call    background_tile_render_with_blit_cache

loc_30BC:
                inc     bl
                cmpsb
                jz      short loc_30C4
                call    background_tile_render_with_blit_cache

loc_30C4:
                add     ds:current_column_screen_addr, 8
                inc     ds:column_counter
                cmp     ds:column_counter, 28
                jnz     short next_column
                retn
render_town_tiles_28_columns endp


; =============== S U B R O U T I N E =======================================


hero_column_shadow_blitter_guard proc near
                cmp     ds:column_counter, 27
                jnz     short loc_30DD
                retn
; ---------------------------------------------------------------------------

loc_30DD:                               ; ...
                mov     al, ds:hero_x_in_viewport
                cmp     ds:column_counter, al
                jz      short loc_30E7
                retn
; ---------------------------------------------------------------------------

loc_30E7:                               ; ...
                push    di
                push    es
                push    si
                push    ds
                mov     al, ds:hero_x_in_viewport
                add     al, al
                add     al, al
                add     al, al
                xor     ah, ah
                mov     di, ax
                add     di, 48+(14+13*8)*320
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     si, 64000      ; shadow memory buffer
                mov     cx, 2

loc_3109:                               ; ...
                push    cx
                push    di
                call    copy_3_vert_tiles
                pop     di
                add     di, 8
                pop     cx
                loop    loc_3109
                pop     ds
                pop     si
                pop     es
                pop     di
                retn
hero_column_shadow_blitter_guard endp


; =============== S U B R O U T I N E =======================================


special_tile_dispatcher proc near
                cmp     byte ptr [si-1], 0FDh
                jnz     short background_tile_render_with_blit_cache
                jmp     special_multi_tile_column_renderer
special_tile_dispatcher endp


; =============== S U B R O U T I N E =======================================


background_tile_render_with_blit_cache proc near ; ...
                mov     al, [di-1]
                mov     byte ptr [di-1], 0FEh
                inc     al
                jnz     short loc_312F
                retn
; ---------------------------------------------------------------------------

loc_312F:                               ; ...
                dec     di
                dec     si
                mov     dl, [si]
                movsb
                push    es
                push    ds
                push    di
                push    si
                push    bx
                push    dx
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                add     bx, bx
                mov     ax, 320
                mul     bx
                add     ax, ds:current_column_screen_addr
                mov     di, ax
                pop     dx
                mov     bl, dl
                xor     bh, bh
                add     bx, bx
                test    word ptr ds:blit_cache[bx], 0FFFFh
                jnz     short loc_31B6
                mov     word ptr ds:blit_cache[bx], di
                mov     ax, 48          ; 6 bits per pixel × 8 pixels × 8 rows = 48 bytes
                mul     dl
                mov     si, ax
                add     si, 8100h       ; packed_tile_graphics
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 8

loc_3178:                               ; ...
                push    cx
                mov     cx, 2

loc_317C:                               ; ...
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
                loop    loc_317C
                add     di, 312
                pop     cx
                loop    loc_3178
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                retn
; ---------------------------------------------------------------------------

loc_31B6:                               ; ...
                mov     si, word ptr ds:blit_cache[bx]
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     cx, 8

loc_31C4:                               ; ...
                movsw
                movsw
                movsw
                movsw
                add     di, 312
                add     si, 312
                loop    loc_31C4
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                retn
background_tile_render_with_blit_cache endp


; =============== S U B R O U T I N E =======================================


tile_render_and_animate proc near
                mov     al, [di-1]
                mov     byte ptr [di-1], 0FEh
                inc     al
                jnz     short loc_31E4
                retn
; ---------------------------------------------------------------------------
loc_31E4:
                push    bx
                push    es
                mov     dl, [si-1]
                mov     bl, dl
                xor     bh, bh
                mov     es, word ptr cs:seg1
                add     bx, es:tile_anim_count_table    ; word ptr seg1:8000 -> address of packed tiles
                mov     dh, es:[bx]
                pop     es
                pop     bx
                or      dh, dh
                jnz     short loc_3203
                jmp     background_tile_render_with_blit_cache
; ---------------------------------------------------------------------------
loc_3203:
                dec     di
                dec     si
                movsb
                push    es
                push    ds
                push    di
                push    si
                push    bx
                push    dx
                xor     bh, bh          ; bx: y in tiles
                add     bx, bx
                add     bx, bx
                add     bx, bx          ; y in screen rows
                mov     ax, 320
                mul     bx
                add     ax, ds:current_column_screen_addr
                mov     di, ax
                pop     dx
                mov     ax, 8
                mul     dl      ; 8 bytes mask per tile
                mov     bp, ax
                mov     ax, 48
                mul     dl
                mov     si, ax
                add     si, packed_tile_graphics ; in seg1
                add     bp, sprite_transparency_masks      ; in seg1
                mov     ax, 192
                mul     ds:column_counter
                add     bx, bx
                add     bx, bx
                add     bx, bx
                add     bx, ax  ; y*64 + column_counter*192
                add     bx, 0A000h      ; bx points to background tile
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 8
eight_scanlines_loop:
                push    cx
                mov     ah, ds:[bp+0]   ; mask  seg1:[d6bc]
                inc     bp
                mov     cx, 2
two_nibbles_loop:
                push    cx
                lodsb                   ; seg1:[a965]=65h
                mov     dl, al          ; dl=65h
                lodsb                   ; seg1:[a966]=59h
                mov     dh, al          ; dh=59h
                lodsb                   ; seg1:[a967]=96h
                mov     cl, al          ; cl=96h
                mov     ch, dl          ; ch=65h
                shr     dx, 1
                shr     dx, 1           ; 1659h
                add     ah, ah          ; 0 -> 0, NC
                jnb     short loc_3276
                mov     dh, cs:[bx]     ; background plane
loc_3276:
                inc     bx              ; aa58 -> aa59; aa5c -> aa5d
                mov     es:[di], dh     ; vram:79d8 <- 28h; vram:79dc <- 16h
                shr     dl, 1
                shr     dl, 1           ; 
                add     ah, ah
                jnb     short loc_3285
                mov     dl, cs:[bx]     ; background plane
loc_3285:
                inc     bx              ; aa59 -> aa5a
                mov     es:[di+1], dl   ; vram:79d9 <- 0
                add     cx, cx          ; 36h -> 6ch
                add     cx, cx          ; 6ch -> d8h
                and     ch, 3Fh         ; 0
                add     ah, ah          ; 0 -> 0, NC
                jnb     short loc_3298
                mov     ch, cs:[bx]
loc_3298:
                inc     bx              ; aa5a -> aa5b
                mov     es:[di+2], ch   ; vram:79da <- 0
                and     al, 3Fh         ; 36h
                add     ah, ah          ; 0 -> 0, NC
                jnb     short loc_32A6
                mov     al, cs:[bx]
loc_32A6:
                inc     bx              ; aa5b -> aa5c
                mov     es:[di+3], al   ; vram:79db <- 36h
                add     di, 4           ; 79dc
                pop     cx
                loop    two_nibbles_loop
                pop     cx
                add     di, 320-8
                loop    eight_scanlines_loop
                pop     bx
                pop     si
                pop     di
                pop     ds
                pop     es
                mov     ah, [di-1]
                or      ah, ah
                jnz     short loc_32C5
                retn
; ---------------------------------------------------------------------------
loc_32C5:
                cmp     ah, 19h
                jb      short loc_32CB
                retn
; ---------------------------------------------------------------------------
loc_32CB:
                push    di
                push    es
                mov     es, word ptr cs:seg1
                mov     di, es:tile_animation_replacement_table
                mov     cl, es:[di]
                or      cl, cl
                jz      short loc_32F9
                inc     di
loc_32DF:
                mov     al, es:[di]
                cmp     al, 0FFh
                jz      short loc_32F9
                cmp     ah, al
                jnz     short loc_32F3
                mov     al, es:[di+1]
                mov     [si-1], al
                jmp     short loc_32F9
; ---------------------------------------------------------------------------
loc_32F3:
                inc     di
                inc     di
                dec     cl
                jnz     short loc_32DF
loc_32F9:
                pop     es
                pop     di
                retn
tile_render_and_animate endp


; =============== S U B R O U T I N E =======================================


unpack_to_shadow_memory_six_tiles proc near ; ...
                mov     di, 64000
unpack_to_shadow_memory_six_tiles endp


; =============== S U B R O U T I N E =======================================


unpack_six_tiles proc near              ; ...
                mov     cx, 6
unpack_six_tiles endp


; =============== S U B R O U T I N E =======================================


unpack_cx_tiles proc near               ; ...
                mov     ax, 0A000h
                mov     es, ax

loc_3307:                               ; ...
                push    cx
                lodsb                   ; tile id points to 48-byte block of packed pixels
                push    ds
                push    si
                mov     cl, 48
                mul     cl
                mov     si, ax
                add     si, packed_tile_graphics
                mov     ds, word ptr cs:seg1
                mov     cx, 16

unpack_next_3_bytes:                    ; ...
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al          ; dh=p23_16, dl=p15_8, bl=al=p7_0
                mov     bh, dl          ; bh=p15_8
                shr     dx, 1
                shr     dx, 1           ; dh=p23_18, dl=p17_10
                mov     es:[di], dh     ; u0=p23_18
                shr     dl, 1
                shr     dl, 1           ; dl=p17_12
                mov     es:[di+1], dl   ; u1=p17_12
                add     bx, bx
                add     bx, bx          ; bh=p13_6, bl=p5_0
                and     bh, 3Fh         ; bh=p11_6
                mov     es:[di+2], bh   ; u2=p11_6
                and     al, 3Fh         ; al=p5_0
                mov     es:[di+3], al   ; u3=p5_0
                add     di, 4
                loop    unpack_next_3_bytes ;
                                        ; tile unpacked to 64 bytes
                pop     si
                pop     ds
                pop     cx
                loop    loc_3307
                retn
unpack_cx_tiles endp


; =============== S U B R O U T I N E =======================================


special_multi_tile_column_renderer proc near ; ...
                push    ds
                push    si
                push    es
                push    di
                mov     di, offset word_3C9C
                movsw
                add     si, 5
                movsw
                movsb
                mov     dl, cs:column_counter
                add     dl, 4
                xor     dh, dh
                add     dx, cs:proximity_map_left_col_x
                mov     ds:sprite_x_coord, dx
                call    sprite_descriptor_table_scanner
                mov     es:tile_id_staging_buffer, al
                cmp     es:byte_3C9E, 0FDh
                jnz     short loc_3387
                inc     dx
                call    sprite_descriptor_table_scanner
                mov     es:byte_3C9E, al

loc_3387:                               ; ...
                mov     si, offset tile_id_staging_buffer
                mov     di, 64000+48*8
                call    unpack_six_tiles
                mov     si, cs:npc_array_addr

loc_3395:                               ; ...
                call    sprite_x_coordinate_lookup
                or      bl, bl
                jz      short loc_33AE
                push    si
                push    bx
                call    get_sprite_vram_address
                pop     bx
                mov     es, word ptr cs:seg1
                mov     si, offset tile_id_staging_buffer
                call    sprite_compositor_dispatcher
                pop     si

loc_33AE:                               ; ...
                add     si, 8
                cmp     word ptr [si], 0FFFFh
                jnz     short loc_3395
                pop     di
                pop     es
                mov     ch, es:[di-1]
                mov     cl, es:[di+7]
                push    es
                push    di
                push    cx
                mov     di, cs:current_column_screen_addr
                add     di, 5*8*320
                push    di
                mov     si, 64000 + 192*2
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                inc     ch
                jz      short loc_33DE
                call    copy_3_vert_tiles

loc_33DE:                               ; ...
                pop     di
                pop     cx
                cmp     cs:column_counter, 1Bh
                jz      short loc_33F5
                mov     si, 64000 + 192*3
                add     di, 8
                inc     cl
                jz      short loc_33F5
                call    copy_3_vert_tiles

loc_33F5:                               ; ...
                pop     di
                pop     es
                mov     al, 0FFh
                mov     byte ptr es:[di-1], 0FEh
                mov     es:[di], al
                mov     es:[di+1], al
                mov     es:[di+7], al
                mov     es:[di+8], al
                mov     es:[di+9], al
                pop     si
                pop     ds
                retn
special_multi_tile_column_renderer endp


; =============== S U B R O U T I N E =======================================


pre_pass_special_column_initializer proc near ; ...
                push    es
                push    ds
                mov     si, ds:proximity_start_tiles
                add     si, 36+1
                mov     di, offset tile_id_staging_buffer
                movsw
                movsb
                mov     dx, ds:proximity_map_left_col_x
                add     dx, 3
                mov     ds:sprite_x_coord, dx
                cmp     ds:tile_id_staging_buffer, 0FDh
                jnz     short loc_343B
                inc     dx
                call    sprite_descriptor_table_scanner
                mov     ds:tile_id_staging_buffer, al

loc_343B:                               ; ...
                mov     si, offset tile_id_staging_buffer
                mov     di, 64000 + 192*2
                mov     cx, 3
                call    unpack_cx_tiles
                mov     si, cs:npc_array_addr

loc_344C:                               ; ...
                call    sprite_x_coordinate_lookup
                or      bl, bl
                jz      short loc_3472
                push    si
                dec     bl
                mov     al, 3
                mul     bl
                push    ax
                call    get_sprite_vram_address
                pop     ax
                add     di, ax
                mov     bp, di
                mov     es, word ptr cs:seg1
                mov     si, offset tile_id_staging_buffer
                mov     di, 64000 + 192*2
                call    npc_3_tiles_to_shadow_buffer
                pop     si

loc_3472:                               ; ...
                add     si, 8
                cmp     word ptr [si], 0FFFFh
                jnz     short loc_344C
                mov     di, 48+(14+13*8)*320 ; skip 13 upper tiles
                mov     si, 64000 + 192*2
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                call    copy_3_vert_tiles
                pop     ds
                pop     es
                mov     di, cache_bytes_ptr
                mov     al, 0FFh
                stosb
                stosb
                stosb
                retn
pre_pass_special_column_initializer endp


; =============== S U B R O U T I N E =======================================


sprite_descriptor_table_scanner proc near ; ...
                call    reset_sprite_table_pointer
                mov     al, [si+3]
                cmp     al, 0FDh
                jz      short loc_34A0
                retn
; ---------------------------------------------------------------------------

loc_34A0:                               ; ...
                add     si, 8
                call    advance_sprite_table_to_matching_x
                mov     al, [si+3]
                cmp     al, 0FDh
                jz      short loc_34A0
                retn
sprite_descriptor_table_scanner endp


; =============== S U B R O U T I N E =======================================


reset_sprite_table_pointer proc near    ; ...
                mov     si, ds:npc_array_addr
reset_sprite_table_pointer endp


; =============== S U B R O U T I N E =======================================


advance_sprite_table_to_matching_x proc near ; ...
                cmp     dx, [si]
                jnz     short loc_34B7
                retn
; ---------------------------------------------------------------------------

loc_34B7:                               ; ...
                add     si, 8
                jmp     short advance_sprite_table_to_matching_x
advance_sprite_table_to_matching_x endp


; =============== S U B R O U T I N E =======================================


copy_3_vert_tiles proc near
                mov     cx, 24
next_8pix_:
                movsw
                movsw
                movsw
                movsw
                add     di, 320-8
                loop    next_8pix_
                retn
copy_3_vert_tiles endp


; =============== S U B R O U T I N E =======================================


sprite_compositor_dispatcher proc near  ; ...
                mov     bp, di
                dec     bl
                xor     bh, bh
                add     bx, bx
                call    cs:funcs_34D2[bx]
                retn
sprite_compositor_dispatcher endp

; ---------------------------------------------------------------------------
funcs_34D2      dw offset single_sprite_shadow_compositor
                dw offset two_sprite_shadow_compositor

; =============== S U B R O U T I N E =======================================


two_sprite_shadow_compositor proc near
                mov     di, 64000 + 192*2
                call    npc_3_tiles_to_shadow_buffer
                jmp     short npc_3_tiles_to_shadow_buffer
two_sprite_shadow_compositor endp


; =============== S U B R O U T I N E =======================================


single_sprite_shadow_compositor proc near ; ...
                add     si, 3
                mov     di, 64000 + 192*3
                jmp     short npc_3_tiles_to_shadow_buffer
single_sprite_shadow_compositor endp


; =============== S U B R O U T I N E =======================================


get_sprite_vram_address proc near       ; ...
                mov     al, [si+2]
                mov     ch, al
                and     al, 7Fh
                mov     cl, 48
                mul     cl
                add     ax, 4000h
                mov     di, ax
                xor     dl, dl
                or      ch, ch
                js      short loc_3504
                mov     dl, 4

loc_3504:                               ; ...
                mov     al, [si+4]
                and     al, 3
                add     al, dl
                mov     cl, 6
                mul     cl
                add     di, ax
                retn
get_sprite_vram_address endp


; =============== S U B R O U T I N E =======================================


sprite_x_coordinate_lookup proc near    ; ...
                mov     cx, 2
                mov     dx, ds:sprite_x_coord

loc_3519:                               ; ...
                mov     bl, cl
                cmp     [si], dx
                jnz     short loc_3520
                retn
; ---------------------------------------------------------------------------

loc_3520:                               ; ...
                inc     dx
                loop    loc_3519
                mov     bl, cl
                retn
sprite_x_coordinate_lookup endp


; =============== S U B R O U T I N E =======================================


ui_draw_routine_dispatcher proc near    ; ...
                mov     bp, di
                dec     bl
                xor     bh, bh
                add     bx, bx
                call    cs:funcs_352E[bx]
                retn
ui_draw_routine_dispatcher endp

; ---------------------------------------------------------------------------
funcs_352E      dw offset sub_354A      ; ...
                dw offset sub_3542
                dw offset sub_353A

; =============== S U B R O U T I N E =======================================


sub_353A        proc near               ; ...
                add     bp, 3
                mov     di, 64000
                jmp     short npc_3_tiles_to_shadow_buffer
sub_353A        endp


; =============== S U B R O U T I N E =======================================


sub_3542        proc near               ; ...
                mov     di, 64000
                call    npc_3_tiles_to_shadow_buffer
                jmp     short npc_3_tiles_to_shadow_buffer
sub_3542        endp


; =============== S U B R O U T I N E =======================================


sub_354A        proc near               ; ...
                mov     di, 64000 + 192
                add     si, 3
                jmp     short $+2
sub_354A        endp


; =============== S U B R O U T I N E =======================================


npc_3_tiles_to_shadow_buffer proc near
                mov     cx, 3
loc_3555:
                push    cx
                mov     byte ptr [si], 0FFh  ; tile_id_staging_buffer
                inc     si
                push    ds
                push    si
                mov     al, es:[bp+0]        ; seg1:[40xx] - tile indices
                inc     bp
                push    es
                push    bp
                dec     al
                push    ax         ; tile id
                mov     cl, 48
                mul     cl
                mov     si, ax
                add     si, 4100h  ; color buffer: 48 bytes per tile (mman/cman)
                pop     ax         ; tile id
                mov     cl, 8
                mul     cl         ; transparency mask buffer: 8 bytes per tile
                add     ax, 7000h  ; transparency mask buffer
                mov     cs:blit_buffer_offset, ax
                mov     ax, cs
                add     ax, 2000h
                mov     cs:blit_buffer_seg, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                call    blit_tile_to_shadow_buffer
                pop     bp
                pop     es
                pop     si
                pop     ds
                pop     cx
                loop    loc_3555
                retn
npc_3_tiles_to_shadow_buffer endp


; =============== S U B R O U T I N E =======================================


blit_6_tiles_to_shadow_memory proc near ; ...
                mov     di, 64000
                mov     cx, 6
next_tile:
                push    cx
                lodsb                   ; tile id
                push    ds
                push    si
                push    ax
                mov     cl, 48
                mul     cl
                mov     si, ax
                add     si, 6000h       ; OR-blit buffer
                pop     ax
                mov     cl, 8
                mul     cl
                add     ax, 8000h       ; and-blit buffer in seg2
                mov     cs:blit_buffer_offset, ax ; AND-blit buffer
                mov     ax, cs
                add     ax, 2000h
                mov     cs:blit_buffer_seg, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                call    blit_tile_to_shadow_buffer
                pop     si
                pop     ds
                pop     cx
                loop    next_tile
                retn
blit_6_tiles_to_shadow_memory endp


; =============== S U B R O U T I N E =======================================

; Blit a single tile to shadow VRAM
;  ES:DI - dest VRAM address
;  DS:SI - tile colors data (48 bytes)
blit_tile_to_shadow_buffer proc near
                push    ds
                push    si
                push    di
                lds     si, dword ptr cs:blit_buffer_offset
                mov     cx, 8
blit_8_rows:
                push    cx
                lodsb
                mov     cx, 8
blit_row:
                add     al, al
                sbb     ah, ah          ; al bit7 -> ah all bits
                and     es:[di], ah     ; clear if al bit7 was 0 (AND-blit)
                inc     di
                loop    blit_row
                pop     cx
                loop    blit_8_rows
                pop     di
                pop     si
                pop     ds
                mov     cx, 16
next_4_bytes:
                lodsw
                mov     dx, ax
                lodsb
                mov     bl, al          ; dh=p23_16, dl=p15_8, bl=al=p7_0
                mov     bh, dl
                shr     dx, 1
                shr     dx, 1           ; dh=p23_18, dl=p17_10
                or      es:[di], dh
                shr     dl, 1
                shr     dl, 1           ; dl=p17_12
                or      es:[di+1], dl
                add     bx, bx
                add     bx, bx
                and     bh, 3Fh         ; bh=p11_6
                or      es:[di+2], bh
                and     al, 3Fh         ; al=p5_0
                or      es:[di+3], al
                add     di, 4
                loop    next_4_bytes
                retn
blit_tile_to_shadow_buffer endp


; =============== S U B R O U T I N E =======================================


scroll_hud_right_8px proc near          ; ...
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                std
                mov     si, 48+222+(14+16*8)*320
                mov     al, 8

loc_3636:                               ; ...
                push    si
                mov     di, si
                sub     si, 8
                mov     cx, 108
                rep movsw
                add     si, 120
                mov     cx, 4
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_3636
                mov     si, 48+222+(14+17*8)*320
                mov     al, 8

loc_3657:                               ; ...
                push    si
                mov     di, si
                sub     si, 10h
                mov     cx, 104
                rep movsw
                add     si, 128
                mov     cx, 8
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_3657
                pop     ds
                cld
                retn
scroll_hud_right_8px endp


; =============== S U B R O U T I N E =======================================


scroll_hud_right_4px proc near          ; ...
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                std
                mov     si, 48+222+14*320
                mov     al, 10h

loc_3685:                               ; ...
                push    si
                mov     di, si
                sub     si, 4
                mov     cx, 110
                rep movsw
                add     si, 116
                mov     cx, 2
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_3685
                pop     ds
                cld
                retn
scroll_hud_right_4px endp


; =============== S U B R O U T I N E =======================================


scroll_hud_left_8px proc near           ; ...
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     si, 48+(14+16*8)*320
                mov     al, 8

loc_36B1:                               ; ...
                push    si
                mov     di, si
                add     si, 8
                mov     cx, 108
                rep movsw
                sub     si, 120
                mov     cx, 4
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_36B1
                mov     si, 48+(14+17*8)*320
                mov     al, 8

loc_36D2:                               ; ...
                push    si
                mov     di, si
                add     si, 10h
                mov     cx, 104
                rep movsw
                sub     si, 128
                mov     cx, 8
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_36D2
                pop     ds
                retn
scroll_hud_left_8px endp


; =============== S U B R O U T I N E =======================================


scroll_hud_left_4px proc near           ; ...
                push    ds
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     si, 48+14*320
                mov     al, 16

loc_36FE:                               ; ...
                push    si
                mov     di, si
                add     si, 4
                mov     cx, 110
                rep movsw
                sub     si, 116
                mov     cx, 2
                rep movsw
                pop     si
                add     si, 320
                dec     al
                jnz     short loc_36FE
                pop     ds
                retn
scroll_hud_left_4px endp


; =============== S U B R O U T I N E =======================================

; AL: glyph id
; seg1:8000 packed 48-byte tiles
; BH: x in tiles
; BL: y in screen coords

draw_tile_to_screen proc near           ; ...
                push    ds
                push    si
                mov     dl, 48          ; packed glyph 48 bytes
                mul     dl
                mov     si, ax
                add     si, packed_tile_ptr
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 320
                mul     bx              ; 320*y
                pop     di              ; x
                add     di, di
                add     di, di
                add     di, di          ; 8*x
                add     di, ax
                mov     ds, word ptr cs:seg1
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 8

next_scanline:                          ; ...
                push    cx
                mov     cx, 2

next_3_bytes:                           ; ...
                lodsw
                mov     dx, ax          ; dh=p23_p16, dl=p15_p8
                lodsb
                mov     bl, al          ; al=p7_p0, bl=p7_p0
                mov     bh, dl          ; bh=p15_p8
                shr     dx, 1
                shr     dx, 1           ; dh=..p23_p18, dl=p17_p10
                mov     es:[di], dh     ; p23_p18
                shr     dl, 1
                shr     dl, 1           ; dl=..p17_p12
                mov     es:[di+1], dl   ; p17_p12
                add     bx, bx
                add     bx, bx          ; bh=p13_p6, bl=p5_p0..
                and     bh, 3Fh
                mov     es:[di+2], bh   ; p11_p6
                and     al, 3Fh
                mov     es:[di+3], al   ; p5_p0
                add     di, 4
                loop    next_3_bytes
                add     di, 312
                pop     cx
                loop    next_scanline
                pop     si
                pop     ds
                retn
draw_tile_to_screen endp


; =============== S U B R O U T I N E =======================================


draw_arrow_icon_or_ui_symbol proc near  ; ...
                push    ds
                push    si
                push    di
                push    cs
                pop     ds
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
                mov     si, offset arrow_bitmap
                mov     cx, 9

loc_37A8:                               ; ...
                push    cx
                lodsb
                mov     ah, al
                mov     cx, 8

loc_37AF:                               ; ...
                add     ah, ah
                sbb     al, al
                and     al, 12h
                stosb
                loop    loc_37AF
                add     di, 320-8
                pop     cx
                loop    loc_37A8
                pop     di
                pop     si
                pop     ds
                retn
draw_arrow_icon_or_ui_symbol endp

; ---------------------------------------------------------------------------
arrow_bitmap    db 0
                db 01100000b
                db 01110000b
                db 01111000b
                db 01111100b
                db 01111000b
                db 01110000b
                db 01100000b
                db 0

; =============== S U B R O U T I N E =======================================

; BL=y
; BH=x

draw_string_buffer_to_screen proc near  ; ...
                xor     ax, ax
                mov     al, bh
                mov     bh, ah
                push    ax
                mov     ax, 320
                mul     bx              ; ax=320*y
                pop     di              ; x
                add     di, di
                add     di, di          ; x*4
                add     di, ax
                mov     si, offset string_render_buffer
                mov     ax, 0A000h
                mov     es, ax
                mov     cx, 9

nine_scanlines:                         ; ...
                push    cx
                push    di
                push    si
                mov     cx, ds:string_width_bytes
                add     cx, cx
                add     cx, cx
                rep movsb
                pop     si
                add     si, 160
                pop     di
                add     di, 320
                pop     cx
                loop    nine_scanlines
                retn
draw_string_buffer_to_screen endp


; =============== S U B R O U T I N E =======================================


format_string_to_buffer proc near       ; ...
                push    si
                push    di
                push    di
                xor     ah, ah
                push    ax
                push    cs
                pop     es
                mov     di, offset string_render_buffer
                xor     ax, ax
                mov     cx, 800
                rep stosw
                pop     ax
                push    ax
                add     ax, ax
                add     si, ax
                mov     si, [si]
                call    render_menu_asciiz_to_buffer1
                pop     ax
                pop     di
                test    byte ptr ds:menu_digits_render_flag, 0FFh 
                jz      short loc_383B
                mov     bx, ax
                add     ax, ax
                add     ax, bx
                add     di, ax          ; di += 3*ax (points to 24-bit number to display in decimal)
                mov     dl, [di]
                mov     ax, [di+1]
                call    render_dl_ax_to_buffer_as_decimal

loc_383B:                               ; ...
                pop     di
                pop     si
                retn
format_string_to_buffer endp


; =============== S U B R O U T I N E =======================================


render_menu_asciiz_to_buffer1 proc near ; ...
                push    cs
                pop     es
                mov     di, offset string_render_buffer1
                xor     bl, bl

loc_3845:                               ; ...
                lodsb
                or      al, al
                jnz     short loc_384B
                retn
; ---------------------------------------------------------------------------

loc_384B:                               ; ...
                push    ds
                push    si
                call    render_menu_glyph_to_buffer1
                pop     si
                pop     ds
                jmp     short loc_3845
render_menu_asciiz_to_buffer1 endp


; =============== S U B R O U T I N E =======================================


render_menu_glyph_to_buffer1 proc near  ; ...
                sub     al, 20h ; ' '
                xor     ah, ah
                shl     ax, 1
                shl     ax, 1
                shl     ax, 1
                mov     si, ax
                push    cs
                pop     ds
                add     si, ds:thin_font
                push    di
                mov     bl, 8

next_scanline_:                          ; ...
                push    bx
                lodsb
                push    di
                mov     dh, al
                mov     dl, 4           ; font 4x8 (town menus)

loc_3870:                               ; ...
                add     dh, dh
                sbb     bl, bl
                and     bl, 9
                mov     es:[di], bl
                inc     di
                dec     dl
                jnz     short loc_3870
                pop     di
                add     di, 160
                pop     bx
                dec     bl
                jnz     short next_scanline_
                pop     di
                add     di, 5           ; 1 px gap between glyphs
                retn
render_menu_glyph_to_buffer1 endp


; =============== S U B R O U T I N E =======================================


render_numeric_score proc near          ; ...
                push    dx
                push    ax
                push    cs
                pop     es
                mov     di, offset string_render_buffer
                xor     ax, ax
                mov     cx, 320h
                rep stosw
                pop     ax
                pop     dx
                call    dl_ax_to_decimal ; Input: DL:AX
                                        ; Output: DI points to decimal digits buffer
                mov     di, offset generic_display_buffer
                mov     si, offset seven_digits_buf
                mov     cx, 7
                mov     bl, 1
                mov     word ptr ds:string_width_bytes, 11
                jmp     short next_digit
render_numeric_score endp


; =============== S U B R O U T I N E =======================================


render_dl_ax_to_buffer_as_decimal proc near ; ...
                call    dl_ax_to_decimal ; Input: DL:AX
                                        ; Output: DI points to decimal digits buffer
                push    cs
                pop     es
                mov     di, offset generic_display_buffer
                mov     ax, ds:numeric_display_x_offset  ;  (relative to generic buffer)
                add     ax, ax
                add     ax, ax
                add     di, ax          ; di=generic_display_buffer + numeric_display_x_offset
                mov     si, offset six_digits_buf
                mov     cx, 6

next_digit:                             ; ...
                push    cx
                push    di
                lodsb
                push    si
                call    render_digit_to_buffer
                pop     si
                pop     di
                add     di, 6
                pop     cx
                loop    next_digit
                retn
render_dl_ax_to_buffer_as_decimal endp


; =============== S U B R O U T I N E =======================================


render_digit_to_buffer proc near        ; ...
                inc     al
                jnz     short loc_38E0
                retn                    ; ff are leading zeroes, skip them
; ---------------------------------------------------------------------------

loc_38E0:                               ; ...
                dec     al              ; 0..9 digit
                xor     ah, ah
                add     ax, ax
                add     ax, ax
                add     ax, ax          ; each glyph = 8 bytes
                add     ax, cs:digits_font
                mov     si, ax
                mov     cx, 7

_next_scanline:                          ; ...
                lodsb
                add     al, al
                add     al, al
                mov     ah, 6           ; 7x6 font (deposit/withdraw money)

six_pixels:                             ; ...
                add     al, al
                sbb     bl, bl          ; bit5 of glyph scanline
                and     bl, 9
                mov     es:[di], bl     ; di=generic_display_buffer + numeric_display_x_offset + digit_index (buffer in cs)
                inc     di
                dec     ah
                jnz     short six_pixels
                add     di, 154         ; buffer is 160 pixels wide
                loop    _next_scanline
                retn
render_digit_to_buffer endp


; =============== S U B R O U T I N E =======================================

; Input: DL:AX
; Output: DI points to decimal digits buffer

dl_ax_to_decimal proc near              ; ...
                mov     di, offset seven_digits_buf
                call    dl_ax_to_seven_digits
                mov     cx, 6

skip_leading_zeroes:                    ; ...
                test    byte ptr cs:[di], 0FFh
                jz      short loc_3921
                retn                    ; di points to first non-zero digit
; ---------------------------------------------------------------------------

loc_3921:                               ; ...
                mov     byte ptr cs:[di], 0FFh
                inc     di
                loop    skip_leading_zeroes
                retn
dl_ax_to_decimal endp

; ---------------------------------------------------------------------------
seven_digits_buf db 0                   ; ...
six_digits_buf  db 0, 0, 0, 0, 0, 0     ; ...

; =============== S U B R O U T I N E =======================================


dl_ax_to_seven_digits proc near         ; ...
                mov     cl, 15
                mov     bx, 16960       ; 1000000 - 15*65536
                call    high_byte_decimal_digit_extractor ; DH = DL:AX / CL:BX
                                        ; AX = DL:AX % CL:BX
                mov     cs:[di], dh
                mov     cl, 1
                mov     bx, 34464       ; 100000-65536
                call    high_byte_decimal_digit_extractor ; DH = DL:AX / CL:BX
                                        ; AX = DL:AX % CL:BX
                mov     cs:[di+1], dh
                xor     cl, cl
                mov     bx, 10000
                call    high_byte_decimal_digit_extractor ; DH = DL:AX / CL:BX
                                        ; AX = DL:AX % CL:BX
                mov     cs:[di+2], dh
                mov     bx, 1000        ; dl:ax < 10000
                call    divmod24        ; DH = DL:AX / BX
                                        ; AX = DL:AX % BX
                mov     cs:[di+3], dh
                mov     bx, 100         ; dl:ax < 1000
                call    divmod24        ; DH = DL:AX / BX
                                        ; AX = DL:AX % BX
                mov     cs:[di+4], dh
                mov     bx, 10          ; dl:ax < 100
                call    divmod24        ; DH = DL:AX / BX
                                        ; AX = DL:AX % BX
                mov     cs:[di+5], dh
                mov     cs:[di+6], al
                retn
dl_ax_to_seven_digits endp


; =============== S U B R O U T I N E =======================================

; DH = DL:AX / CL:BX
; AX = DL:AX % CL:BX

high_byte_decimal_digit_extractor proc near ; ...
                xor     dh, dh

next_sub:                               ; ...
                sub     dl, cl          ; dl:ax -= cl:bx
                jb      short restore_dl
                sub     ax, bx
                jnb     short no_carry
                or      dl, dl
                jz      short restore_ax
                dec     dl

no_carry:                               ; ...
                inc     dh              ; subtractions counter
                jmp     short next_sub
; ---------------------------------------------------------------------------

restore_ax:                             ; ...
                add     ax, bx

restore_dl:                             ; ...
                add     dl, cl
                retn
high_byte_decimal_digit_extractor endp


; =============== S U B R O U T I N E =======================================

; DH = DL:AX / BX
; AX = DL:AX % BX

divmod24        proc near               ; ...
                xor     dh, dh
                div     bx              ; 00:DL:AX / BX -> AX
                                        ; 00:DL:AX % BX -> DX
                xchg    ax, dx          ; DX = /, AX = %
                mov     dh, dl          ; DH = /, AX = %
                xor     dl, dl
                retn
divmod24        endp


; =============== S U B R O U T I N E =======================================


scroll_hud_up   proc near               ; ...
                push    ds
                push    ax
                add     bl, cl
                dec     bl
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
                mov     si, di
                sub     si, 320
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     bl, ch
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                xor     ch, ch

loc_39C9:                               ; ...
                push    cx
                push    di
                push    si
                mov     cx, bx
                rep movsb
                pop     si
                pop     di
                sub     si, 320
                sub     di, 320
                pop     cx
                loop    loc_39C9
                pop     ax
                mov     dl, 0A0h
                mul     dl
                add     ax, offset string_render_buffer
                mov     si, ax
                push    cs
                pop     ds
                mov     cx, bx
                rep movsb
                pop     ds
                retn
scroll_hud_up   endp


; =============== S U B R O U T I N E =======================================


scroll_hud_down proc near               ; ...
                push    ds
                push    ax
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
                mov     si, di
                add     si, 320
                mov     ax, 0A000h
                mov     es, ax
                mov     ds, ax
                mov     bl, ch
                xor     bh, bh
                add     bx, bx
                add     bx, bx
                xor     ch, ch

loc_3A1B:                               ; ...
                push    cx
                push    di
                push    si
                mov     cx, bx
                rep movsb
                pop     si
                pop     di
                add     si, 320
                add     di, 320
                pop     cx
                loop    loc_3A1B
                pop     ax
                mov     dl, 0A0h
                mul     dl
                add     ax, offset string_render_buffer
                mov     si, ax
                push    cs
                pop     ds
                mov     cx, bx
                rep movsb
                pop     ds
                retn
scroll_hud_down endp


; =============== S U B R O U T I N E =======================================


apply_screen_xor_grid proc near         ; ...
                mov     ax, 0A000h
                mov     es, ax
                mov     di, viewport_top_left_vram_addr
                mov     cx, 8

loc_3A4C:                               ; ...
                push    cx
                push    di
                mov     cx, 18

loc_3A51:                               ; ...
                push    cx
                push    di
                mov     ax, 0011011000110110b
                mov     cx, 112

loc_3A59:                               ; ...
                xor     es:[di], ax
                inc     di
                inc     di
                loop    loc_3A59
                pop     di
                add     di, 0A00h
                pop     cx
                loop    loc_3A51
                pop     di
                add     di, 320
                pop     cx
                loop    loc_3A4C
                retn
apply_screen_xor_grid endp


; =============== S U B R O U T I N E =======================================
; Apply sprite mask to a 48-byte block of data, in place
; ds:si = source data pointer
; es:di = dest pointer for transparency info
; cx = number of 48-byte blocks
apply_sprite_mask proc near             ; ...
                mov     cs:blit_buffer_offset, di
                mov     cs:blit_buffer_seg, es
                push    cx
                push    ds
                push    si
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax   ; seg3
                mov     ax, 48
                mul     cx
                mov     cx, ax
                mov     di, 0    ; temp buffer in seg3
                rep movsb
                pop     di
                pop     es       ; es:di points to source data
                pop     cx
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax   ; seg3
                mov     si, 0
next_48_bytes_block:
                push    cx
                mov     cx, 8
loc_3AA2:
                push    cx
                lodsw
                mov     dx, ax
                lodsw
                mov     cx, ax
                lodsw
                mov     bx, ax
                mov     bp, ax
                or      ax, cx
                or      ax, dx
                and     bp, cx
                and     bp, dx
                not     bp
                and     dx, bp
                and     cx, bp
                and     bx, bp
                xchg    dh, dl
                mov     cs:r_plane_buffer, dx
                xchg    ch, cl
                mov     cs:g_plane_buffer, cx
                xchg    bh, bl
                mov     cs:b_plane_buffer, bx
                xchg    ah, al
                not     ax
                mov     cs:transparency_mask_bitplane, ax
                call    build_48_bits_packed_from_rgb_planes ; save 6 bytes to es:di
                push    es
                push    di
                les     di, dword ptr cs:blit_buffer_offset
                call    extract_transparency_byte_from_mask_plane
                mov     al, dl
                stosb
                mov     cs:blit_buffer_offset, di
                pop     di
                pop     es
                pop     cx
                loop    loc_3AA2
                pop     cx
                loop    next_48_bytes_block
                retn
apply_sprite_mask endp


; =============== S U B R O U T I N E =======================================

decompress_patterns proc near
                push    ds
                mov     ds, word ptr cs:seg1
                mov     si, packed_tile_graphics
                mov     ax, cs
                add     ax, 3000h
                mov     es, ax          ; seg3
                mov     cx, 12000
                mov     di, 0           ; temp buffer at seg3:0
                rep movsb
                mov     es, word ptr cs:seg1
                mov     ax, cs
                add     ax, 3000h
                mov     ds, ax          ; seg3
                mov     si, 0
                mov     di, packed_tile_graphics     ; 8100h
                mov     bx, es:tile_anim_count_table ; seg1:[8000h] - table of decompression functions for each tile index
                mov     bp, sprite_transparency_masks
                mov     cx, 256-6
loc_3B2E:
                push    cx
                mov     al, es:[bx]     ; fn #
                cmp     al, 5
                jb      short loc_3B38
                xor     al, al
loc_3B38:
                push    bx
                xor     bx, bx
                mov     bl, al
                add     bx, bx
                call    cs:pat_decompress_fn[bx]
                pop     bx
                inc     bx
                pop     cx
                loop    loc_3B2E
                pop     ds
                retn
decompress_patterns endp

; ---------------------------------------------------------------------------
pat_decompress_fn   dw offset sprite_plane_decompressor_0
                    dw offset sprite_plane_decompressor_b
                    dw offset sprite_plane_decompressor_g
                    dw offset sprite_plane_decompressor_r
                    dw offset build_48_bytes_packed_tile_from_rgb_planes

; =============== S U B R O U T I N E =======================================


sprite_plane_decompressor_0 proc near
                mov     cx, 8
loc_3B58:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:r_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:g_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:b_plane_buffer, ax
                call    build_48_bits_packed_from_rgb_planes
                mov     byte ptr es:[bp+0], 0
                inc     bp
                pop     cx
                loop    loc_3B58
                retn
sprite_plane_decompressor_0 endp


; =============== S U B R O U T I N E =======================================


sprite_plane_decompressor_b proc near
                mov     cx, 8
loc_3B7E:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:r_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:g_plane_buffer, ax
                mov     cs:b_plane_buffer, 0
                lodsw
                xchg    ah, al
                mov     cs:transparency_mask_bitplane, ax
                call    build_48_bits_packed_from_rgb_planes
                call    extract_transparency_byte_from_mask_plane
                mov     es:[bp+0], dl
                inc     bp
                pop     cx
                loop    loc_3B7E
                retn
sprite_plane_decompressor_b endp


; =============== S U B R O U T I N E =======================================


sprite_plane_decompressor_g proc near
                mov     cx, 8
loc_3BAD:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:r_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:transparency_mask_bitplane, ax
                mov     cs:g_plane_buffer, 0
                lodsw
                xchg    ah, al
                mov     cs:b_plane_buffer, ax
                call    build_48_bits_packed_from_rgb_planes
                call    extract_transparency_byte_from_mask_plane
                mov     es:[bp+0], dl
                inc     bp
                pop     cx
                loop    loc_3BAD
                retn
sprite_plane_decompressor_g endp


; =============== S U B R O U T I N E =======================================


sprite_plane_decompressor_r proc near
                mov     cx, 8
loc_3BDC:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:transparency_mask_bitplane, ax
                mov     cs:r_plane_buffer, 0
                lodsw
                xchg    al, ah
                mov     cs:g_plane_buffer, ax
                lodsw
                xchg    al, ah
                mov     cs:b_plane_buffer, ax
                call    build_48_bits_packed_from_rgb_planes
                call    extract_transparency_byte_from_mask_plane
                mov     es:[bp+0], dl
                inc     bp
                pop     cx
                loop    loc_3BDC
                retn
sprite_plane_decompressor_r endp


; =============== S U B R O U T I N E =======================================


build_48_bytes_packed_tile_from_rgb_planes proc near
                mov     cx, 8
loc_3C0B:
                push    cx
                lodsw
                xchg    ah, al
                mov     cs:r_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:g_plane_buffer, ax
                lodsw
                xchg    ah, al
                mov     cs:b_plane_buffer, ax
                call    build_48_bits_packed_from_rgb_planes
                mov     byte ptr es:[bp+0], 0FFh
                inc     bp
                pop     cx
                loop    loc_3C0B
                retn
build_48_bytes_packed_tile_from_rgb_planes endp


; =============== S U B R O U T I N E =======================================

; Builds 48 bits of packed data from the 3 planes of RGB data.
; es:di - destination pointer to save 6 bytes
build_48_bits_packed_from_rgb_planes proc near
                mov     cx, 2
loc_3C31:
                call    extract_3_bits_from_rgb_planes
                call    extract_3_bits_from_rgb_planes
                call    extract_3_bits_from_rgb_planes
                call    extract_3_bits_from_rgb_planes
                call    extract_3_bits_from_rgb_planes
                rol     cs:b_plane_buffer, 1
                adc     ax, ax          ; got full 16 bits
                stosw
                rol     cs:g_plane_buffer, 1
                adc     ax, ax
                rol     cs:r_plane_buffer, 1
                adc     ax, ax
                call    extract_3_bits_from_rgb_planes
                call    extract_3_bits_from_rgb_planes
                stosb                   ; got 8 bits
                loop    loc_3C31
                retn
build_48_bits_packed_from_rgb_planes endp


; =============== S U B R O U T I N E =======================================


extract_3_bits_from_rgb_planes proc near ; ...
                rol     cs:b_plane_buffer, 1
                adc     ax, ax
                rol     cs:g_plane_buffer, 1
                adc     ax, ax
                rol     cs:r_plane_buffer, 1
                adc     ax, ax
                retn
extract_3_bits_from_rgb_planes endp


; =============== S U B R O U T I N E =======================================


extract_transparency_byte_from_mask_plane proc near
                mov     cx, 8
next_bit:
                xor     al, al
                rol     cs:transparency_mask_bitplane, 1
                adc     al, al
                rol     cs:transparency_mask_bitplane, 1
                adc     al, al
                cmp     al, 11b
                je      short loc_3C8F
                xor     al, al
loc_3C8F:
                and     al, 1
                add     dl, dl
                or      dl, al
                loop    next_bit
                retn
extract_transparency_byte_from_mask_plane endp

; ---------------------------------------------------------------------------
current_column_screen_addr dw 0      
column_counter  db 0                 
tile_id_staging_buffer db 0          
word_3C9C       dw 0                 
byte_3C9E       db 0, 0, 0           
sprite_x_coord  dw 0                 
r_plane_buffer  dw 0                 
g_plane_buffer  dw 0                 
b_plane_buffer  dw 0                 
transparency_mask_bitplane dw 0      
blit_buffer_offset        dw 0                 
blit_buffer_seg            dw 0                 
string_render_buffer db 0A0h dup(0)  
string_render_buffer1 db 0A0h dup(0) 
generic_display_buffer db 500h dup(0)
blit_cache      db 200h dup(0)       

screen_buffer   equ 0A000h

gtmcga          ends

                end     start
