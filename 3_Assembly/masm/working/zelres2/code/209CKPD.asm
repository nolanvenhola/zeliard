
PAGE  59,132

;==========================================================================
;
;  209CKPD - Boss Sprite Renderer (CKPD.BIN, zelres2 chunk 10)
;
;  Renders a large multi-frame boss sprite to EGA (0A000h) and CGA (0B800h)
;  framebuffers. The module contains two dispatchers and nine renderer
;  variants, all driven by the mode byte at cs:bos_mode.
;
;  Entry / setup:
;    bos_render_main         - far entry: zero work RAM, RLE-unpack boss
;                              gfx from bos_gfx_hdr / bos_gfx_src_b / ...
;                              into a +1000h segment, then call
;                              render_dispatch_layer2 and bos_frame_dispatch.
;
;  Dispatchers:
;    bos_frame_dispatch      - jmp ds:[bos_anim_tbl + 2*bos_mode]
;                              (table in game DS, selects frame_handler_a..e)
;    render_dispatch_layer2       - jmp cs:[36A5h + 2*bos_mode]
;                              (selects mode_handler_f..i)
;
;  Frame handlers (game-DS dispatch):
;    frame_handler_a         - EGA: Map Mask + Graphics Mode 5 row copy,
;                              then nibble-pair decode to 0xA000.
;    frame_handler_b         - CGA: block copy from cga_src_23c, nibble
;                              decode into 0xB800 via bos_color_lut_a.
;    frame_handler_c         - second CGA variant (push ds / mov ax,0B000h
;                              prologue embedded in data bytes).
;    frame_handler_d         - VGA (0xA000) block copy then 4x column
;                              decode via nibble_expand_8.
;    frame_handler_e         - CGA (0xB800) block copy then 2x column
;                              decode via decode_nibble_pair.
;
;  Mode handlers (CS dispatch):
;    mode_handler_f          - EGA Write Mode 1 blit (ports 3C4h/3C5h).
;    mode_handler_g          - CGA interlaced (2000h banks) sprite blit.
;    mode_handler_h          - VGA 320-byte-stride blit (A000h).
;    mode_handler_i          - CGA 4-bank interlaced blit.
;
;  Helpers / decoders:
;    vga_row_copy            - copy one 28-byte row (used by frame_handler_c).
;    sprite_rle_decode       - 2-byte RLE: 0x1n = run-of-zero count n,
;                              0x4n = run-of-AA count n, else single literal.
;    nibble_expand_8 / _b    - 2-byte nibble-pair to 8-bit color index.
;    decode_nibble_pair / _2 - inner 4/2-iteration nibble-pair decode loop.
;
;  The second half of the file (from file offset ~0x5D4 to end) is packed
;  sprite bitmap pixel data, color LUTs (referenced by bos_color_lut_a..d
;  at CS 3497h/3654h/3753h/38D0h = file+1497h/1654h/1753h/18D0h) and the
;  CS-relative dispatch table at 36A5h (file+16A5h). Sourcer misidentifies
;  many bytes as x86 code because the pixel bytes form valid instruction
;  patterns; the entire region is kept as raw db with ckpd_raw_region_anchor_a..ckpd_raw_region_anchor_b
;  labels preserved for the few cross-references from the real code above.
;
;  Connections:
;    Loads:        none -- module is itself the loaded chunk; boss
;                  sprite RLE-packed bitmaps + per-mode color LUTs are
;                  embedded in this binary's data section (file+1497h..
;                  file+18D0h LUTs; file+5D4h..end pixel bytes).
;    Calls into:   none cross-chunk. Internal: bos_frame_dispatch ->
;                    ds:[bos_anim_tbl + 2*bos_mode] (5 frame_handler_a..e
;                    in game DS, populated by the boss-arena entry code);
;                    render_dispatch_layer2 -> cs:[36A5h + 2*bos_mode]
;                    (mode_handler_f..i CS-resident); sprite_rle_decode
;                    + nibble_expand_8 / decode_nibble_pair helpers.
;    Called by:    106TOWN dispatch (boss-arena entry path) -- loaded
;                    raw into the game segment via SAR loader and
;                    invoked by far call with bos_mode preset by the
;                    arena setup code (zelres3 boss handler chunks).
;                    Returns far to the boss-arena driver after rendering
;                    the frame.
;    Reads/writes: bos_mode (CS:3388h -- frame/mode selector byte set
;                  by caller); bos_anim_tbl (CS:3395h -- frame handler
;                  pointer table); bos_color_lut_a..d (CS:3497h/3654h/
;                  3753h/38D0h); bos_src_col_a/_b (DS:4F25h/50E5h --
;                  sprite source columns) + bos_var_25e..29e boss-state
;                  vars in game DS; CS+1000h decompression scratch
;                  segment; A000h (EGA/VGA) and B800h (CGA) framebuffers
;                  via Map Mask / Graphics Mode 5 register writes.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
bos_src_col_a	equ	4F25h			;* sprite source column A (hi-nibble)
bos_src_col_b	equ	50E5h			;* sprite source column B (lo-nibble)
cga_wrap_c	equ	0A05Ah			;* CGA/planar wrap offset C
bos_anim_tbl	equ	3395h			;* animation frame dispatch table (word array)
bos_color_lut_a	equ	3497h			;* EGA color LUT A (16 bytes)
bos_color_lut_b	equ	3654h			;* EGA color LUT B
bos_color_lut_c	equ	3753h			;* EGA color LUT C
bos_color_lut_d	equ	38D0h			;* CGA color LUT D
bos_gfx_hdr	equ	38E0h			;* boss sprite graphics header
bos_gfx_src_b	equ	426Ah			;* boss gfx source B
bos_src_d	equ	4C6Dh			;* sprite source D
bos_src_e	equ	4DB8h			;* sprite source E
bos_src_f	equ	4F25h			;* sprite source F (= bos_src_col_a)
bos_src_g	equ	50E5h			;* sprite source G (= bos_src_col_b)
bos_dst_vga	equ	53C1h			;* VGA destination offset
bos_limit_6000	equ	6000h			;* wrap boundary (6000h)
bos_limit_wrap	equ	80A0h			;* wrap delta 80A0h
cga_wrap_55e	equ	0A05Ah			;* CGA wrap 55 (= cga_wrap_c)
bos_wrap_c050	equ	0C050h			;* wrap delta C050h
rle_src_46c	equ	46Ch			; RLE-decoded sprite dest A (used by ega mode a)
rle_dst_488	equ	488h			; EGA row dest offset (init = 0488h)
cga_src_11b0	equ	11B0h			; CGA mode-a source offset
cga_dst_1220	equ	1220h			; CGA mode-a destination offset
cga_dst_2c6c	equ	2C6Ch			; CGA mode-b destination offset
cga_src_23c	equ	23Ch			; CGA mode-b source offset (= 0x23C)
vga_dst_163c	equ	163Ch			; VGA/EGA dest offset 163Ch
vga_dst_41f8	equ	41F8h			; VGA dest 41F8h

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
bos_var_25e	equ	2022h			;* boss state var 25 (ds-relative)
bos_var_26e	equ	2208h			;* boss state var 26
bos_var_27e	equ	2222h			;* boss state var 27
bos_var_28e	equ	2A11h			;* boss state var 28
bos_var_29e	equ	2A42h			;* boss state var 29
bos_mode	equ	3388h			;* current boss render mode byte (CS-relative)
bos_var_34e	equ	3694h			;* render state var 34
bos_var_38e	equ	3F03h			;* boss var 38
bos_var_39e	equ	3FE8h			;* boss var 39
bos_var_40e	equ	410Ah			;* boss var 40
bos_var_41e	equ	413Bh			;* boss var 41
bos_var_42e	equ	41A0h			;* boss var 42
bos_var_44e	equ	43A8h			;* boss var 44
bos_var_51e	equ	8041h			;* boss var 51
bos_var_53e	equ	8808h			;* boss var 53
bos_var_54e	equ	8A28h			;* boss var 54
bos_var_56e	equ	0A202h			;* boss var 56
bos_var_57e	equ	0A211h			;* boss var 57
bos_var_58e	equ	0A841h			;* boss var 58
bos_var_59e	equ	0A88Ah			;* boss var 59
bos_var_60e	equ	0AB41h			;* boss var 60
bos_var_61e	equ	0BA80h			;* boss var 61
bos_var_62e	equ	0BAEAh			;* boss var 62
bos_var_63e	equ	0C003h			;* boss var 63
bos_var_65e	equ	0FA41h			;* boss var 65

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
bos_dst_zero	equ	0			;* zero offset (for clear loop)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

bos_render_main		proc	far

start:
		movsw				; Mov [si] to es:[di]
		pop	ds
		add	[bx+si],al
		mov	cs:[bos_mode],al

init_clear_buf:
		mov	dx,cs
		mov	ds,dx
		add	dx,1000h
		mov	es,dx
		cld				; Clear direction
		mov	di,bos_dst_zero
		mov	cx,0FC0h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	dx,cs
		add	dx,1000h
		mov	es,dx
		mov	di,0
		mov	si,bos_gfx_hdr
		call	sprite_rle_decode
		mov	di,offset ckpd_pattern_dst_buf
		mov	si,bos_gfx_src_b
		call	sprite_rle_decode
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	bp,0FC0h
		mov	bx,0C1Eh
		mov	cx,3848h
		call	render_dispatch_layer2
		pop	ds
		mov	byte ptr ds:[bos_var_34e],1Ch
		mov	dx,cs
		add	dx,1000h
		mov	es,dx
		mov	di,0
		mov	si,bos_src_d
		call	sprite_rle_decode
		mov	di,1C0h
		mov	si,bos_src_e
		call	sprite_rle_decode
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	bp,1C0h
		mov	bx,0C0Eh
		mov	cx,1C10h
		call	render_dispatch_layer2
		pop	ds
		call	bos_frame_dispatch
		retf				; Return far
		db	0	; +0x000

bos_render_main		endp

bos_frame_dispatch		proc	near
		xor	bx,bx			; Zero register
		mov	bl,ds:[bos_mode]
		add	bx,bx
		jmp	word ptr ds:[bos_anim_tbl][bx]	;*

bos_frame_dispatch		endp

; --- Frame handler A: EGA render with Map Mask + Bit Mask sequence ---
; Dispatched via ds:bos_anim_tbl (game-DS resident table). First 5 bytes
; ('mov ax,ckpd_obfuscated_value / xor al,12h / xor al,0A7h / xor al,48h / xor ax,35C2h')
; are a decoy/NOP-equivalent pattern that sets AX=0 for the subsequent setup.

frame_handler_a:
		mov	ax,ckpd_obfuscated_value
		xor	al,12h
		xor	al,0A7h
		xor	al,48h			; 'H'
		xor	ax,35C2h
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	si,rle_src_46c
		mov	di,rle_dst_488
		mov	ah,10h

ega_mode_a_row_loop:
					mov	cx,1Ch
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					add	si,34h
					add	di,34h
					dec	ah
					jnz	ega_mode_a_row_loop			; Jump if not zero
		mov	dx,3CEh
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		xor	si,si			; Zero register
		mov	di,cga_dst_2c6c
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,10h

ega_mode_a_outer:
					push	cx
					push	di
					mov	cx,1Ch

ega_mode_a_col_loop:
								mov	al,2
								out	dx,al			; port 3C5h, EGA sequencr func
								mov	al,ds:[bos_src_f][si]
								mov	es:[di],al
								mov	es:[di+1Ch],al
								mov	al,4
								out	dx,al			; port 3C5h, EGA sequencr func
								mov	al,ds:[bos_src_g][si]
								mov	es:[di],al
								mov	es:[di+1Ch],al
								inc	di
								inc	si
								loop	ega_mode_a_col_loop		; Loop if cx > 0

					pop	di
					add	di,50h
					pop	cx
					loop	ega_mode_a_outer		; Loop if cx > 0

		retn

; --- Frame handler B: CGA render to segment 0B800h, with nibble-pair decode ---
; Dispatched via bos_anim_tbl. Copies 16 rows from cga_src_23c, then decodes
; a 16x28 block through bos_color_lut_a into VGA/CGA memory.

frame_handler_b:
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,cga_src_23c
		mov	ah,10h

cga_mode_a_loop:
					push	si
					mov	di,si
					add	di,1Ch
					mov	cx,0Eh
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,4000h
					jb	cga_mode_a_skip			; Jump if below
					add	si,bos_wrap_c050

cga_mode_a_skip:
					dec	ah
					jnz	cga_mode_a_loop			; Jump if not zero
		pop	ds
		xor	si,si			; Zero register
		mov	di,vga_dst_163c
		mov	cx,10h

cga_mode_a_outer:
					push	cx
					push	di
					mov	cx,1Ch

cga_mode_a_col_loop:
								push	cx
								mov	ah,ds:[bos_src_g][si]
								mov	al,ds:[bos_src_f][si]
								inc	si
								xor	dl,dl			; Zero register
								mov	cx,4

cga_mode_a_decode_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,ds:[bos_color_lut_a][bx]
								loop	cga_mode_a_decode_loop		; Loop if cx > 0

								mov	es:[di],dl
								mov	es:[di+1Ch],dl
								inc	di
								pop	cx
								loop	cga_mode_a_col_loop		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	cga_mode_a_branch			; Jump if below
					add	di,0C050h

cga_mode_a_branch:
					pop	cx
					loop	cga_mode_a_outer		; Loop if cx > 0

		retn

; --- Color remap LUT + frame handler C entry ---
; First 16 bytes: 4x4 nibble color remap (used by a following handler's lookup).
; Bytes 17-27 decode to 'push ds / mov ax,0B000h / mov es,ax / mov ds,ax /
; mov si,04FDh / mov ah,10h' ?-- frame handler C prologue. Sourcer did not
; mark a label here because the table bytes were fused into the preceding
; code block.

color_remap_lut_a:
		db	 00h, 02h, 03h, 01h, 00h, 03h	; +0x000
		db	 02h, 01h, 00h, 02h, 03h, 01h	; +0x006
		db	 00h, 02h, 03h, 01h	; +0x00C
; --- Frame handler C entry (falls through to cga_copy_loop) ---

frame_handler_c:
		push	ds
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	si,04FDh
		mov	ah,10h

cga_copy_loop:
					call	vga_row_copy
					add	si,2000h
					cmp	si,6000h
					jb	cga_copy_skip			; Jump if below
					call	vga_row_copy
					add	si,cga_wrap_c

cga_copy_skip:
					dec	ah
					jnz	cga_copy_loop			; Jump if not zero
		pop	ds
		xor	si,si			; Zero register
		mov	di,bos_dst_vga
		mov	cx,10h

cga_mode_b_outer:
					push	cx
					push	di
					mov	cx,1Ch

cga_mode_b_col_loop:
								push	cx
								mov	ah,ds:[bos_src_col_b][si]
								mov	al,ds:[bos_src_col_a][si]
								inc	si
								xor	dl,dl			; Zero register
								mov	cx,4

cga_mode_b_decode_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh

cga_mode_b_branch:
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,ds:[bos_color_lut_a][bx]
								loop	cga_mode_b_decode_loop		; Loop if cx > 0

								mov	es:[di],dl
								mov	es:[di+1Ch],dl
								inc	di
								pop	cx
								loop	cga_mode_b_col_loop		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,bos_limit_6000
					jb	cga_mode_b_skip			; Jump if below
					push	ds
					push	si
					push	cx
					push	di
					push	es
					pop	ds
					mov	si,di
					sub	si,2000h
					mov	cx,38h
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	di
					pop	cx
					pop	si
					pop	ds
					add	di,cga_wrap_55e

cga_mode_b_skip:
					pop	cx
					loop	cga_mode_b_outer		; Loop if cx > 0

		retn

vga_row_copy		proc	near
		push	si
		mov	di,si
		add	di,1Ch
		mov	cx,0Eh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	si
		retn

vga_row_copy		endp

; --- Frame handler D: VGA/EGA (0A000h) block copy then nibble decode ---
; Dispatched via bos_anim_tbl. Copies 56-word rows from cga_src_11b0 to
; cga_dst_1220 (16 rows), then decodes 16x28 into VGA at 0xB1B0 via
; nibble_expand_8 with per-pixel color duplication.

frame_handler_d:
		push	ds
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,cga_src_11b0
		mov	di,cga_dst_1220
		mov	ah,10h

vga_copy_loop:
					mov	cx,38h
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					add	si,0D0h
					add	di,0D0h
					dec	ah
					jnz	vga_copy_loop			; Jump if not zero
		pop	ds
		xor	si,si			; Zero register
		mov	di,0B1B0h
		mov	cx,10h

vga_mode_a_outer:
					push	cx
					push	di
					mov	cx,1Ch

vga_mode_a_col_loop:
								mov	dl,ds:[bos_src_f][si]
								mov	dh,ds:[bos_src_g][si]
								call	nibble_expand_8
								stosb				; Store al to es:[di]
								mov	es:[di+6Fh],al
								call	nibble_expand_8
								stosb				; Store al to es:[di]
								mov	es:[di+6Fh],al
								call	nibble_expand_8
								stosb				; Store al to es:[di]
								mov	es:[di+6Fh],al
								call	nibble_expand_8
								stosb				; Store al to es:[di]
								mov	es:[di+6Fh],al
								inc	si
								loop	vga_mode_a_col_loop		; Loop if cx > 0

					pop	di
					add	di,140h
					pop	cx
					loop	vga_mode_a_outer		; Loop if cx > 0

		retn

nibble_expand_8		proc	near
		xor	al,al			; Zero register
		add	dh,dh
		adc	al,al
		add	dl,dl
		adc	al,al
		add	al,al
		add	dh,dh
		adc	al,al
		add	dl,dl
		adc	al,al
		add	al,al
		retn

nibble_expand_8		endp

; --- Frame handler E: CGA (0B800h) block copy then nibble-pair render ---
; Dispatched via bos_anim_tbl. Copies 28-word rows from vga_dst_41f8 (16 rows),
; then decodes 16x28 into CGA at 0x55F8 through decode_nibble_pair + bos_color_lut_b.

frame_handler_e:
		push	ds
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	si,vga_dst_41f8
		mov	ah,10h

cga_mode_c_loop:
					push	si
					mov	di,si
					add	di,38h
					mov	cx,1Ch
					rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
					pop	si
					add	si,2000h
					cmp	si,8000h
					jb	cga_mode_c_skip			; Jump if below
					add	si,bos_limit_wrap

cga_mode_c_skip:
					dec	ah
					jnz	cga_mode_c_loop			; Jump if not zero
		pop	ds
		xor	si,si			; Zero register
		mov	di,55F8h
		mov	cx,10h

cga_mode_c_outer:
					push	cx
					push	di
					mov	cx,1Ch

cga_mode_c_col_loop:
								push	cx
								mov	dh,ds:[bos_src_g][si]
								mov	dl,ds:[bos_src_f][si]
								call	decode_nibble_pair
								mov	es:[di+38h],al
								stosb				; Store al to es:[di]
								call	decode_nibble_pair
								mov	es:[di+38h],al
								stosb				; Store al to es:[di]
								inc	si
								pop	cx
								loop	cga_mode_c_col_loop		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,8000h
					jb	cga_mode_c_branch			; Jump if below
					add	di,80A0h

cga_mode_c_branch:
					pop	cx
					loop	cga_mode_c_outer		; Loop if cx > 0

		retn

decode_nibble_pair		proc	near
		xor	al,al			; Zero register
		mov	cx,2

nibble_decode_step:
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					and	bl,0Fh
					xor	bh,bh			; Zero register
					add	al,al
					add	al,al
					add	al,al
					add	al,al
					or	al,ds:[bos_color_lut_b][bx]
					loop	nibble_decode_step		; Loop if cx > 0

		retn

decode_nibble_pair		endp

		db	 00h, 04h, 03h, 02h, 04h, 0Ch	; +0x000
		db	 05h, 06h, 03h, 05h, 0Bh, 0Ah	; +0x006
		db	 02h, 06h, 0Ah, 0Eh	; +0x00C

sprite_rle_decode		proc	near
		mov	bx,di

rle_read_next:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jnz	rle_check_op			; Jump if not zero
					retn

rle_check_op:
					mov	ah,al
					and	ah,0F0h
					cmp	ah,10h
					jne	rle_check_op40			; Jump if not equal
					and	al,0Fh
					mov	ah,al
					xor	al,al			; Zero register
					jmp	short rle_store_loop

rle_check_op40:
					cmp	ah,40h			; '@'
					jne	rle_single_literal			; Jump if not equal
					and	al,0Fh
					mov	ah,al
					mov	al,0AAh
					jmp	short rle_store_loop

rle_single_literal:
					mov	ah,1

rle_store_loop:
								stosb				; Store al to es:[di]
								dec	ah
								jnz	rle_store_loop			; Jump if not zero
					jmp	short rle_read_next

sprite_rle_decode		endp

		db	38h	; +0x000

render_dispatch_layer2		proc	near
		xor	ax,ax			; Zero register
		mov	al,cs:[bos_mode]
		add	ax,ax
		add	ax,36A5h
		mov	di,ax
		jmp	word ptr cs:[di]	;*

render_dispatch_layer2		endp

; --- Mode handler F: dispatch stub and prologue bytes ---
; These bytes are reached via render_dispatch_layer2's 'jmp [cs:36A5h + 2*bos_mode]'.
; The 6 bytes 'B1 36 EA 36 EA 36 63' (mov cl,36h / jmp far 0036:EA36h) form a
; dispatch stub that Sourcer could not disassemble cleanly. The remaining bytes
; set up EGA Data Rotate (port 3CEh/3CFh), Map Mask on port 3C4h/3C5h, a source
; address in SI, and fall through to ega_mode_b_outer (per-row EGA blit loop).

mode_handler_f:
		mov	cl,36h			; '6'
		db	0EAh, 36h, 0EAh, 36h, 63h	; jmp far (absolute; TASM won't compile as mnemonic)

; --- EGA Write Mode 1 setup + blit loop prologue (prologue for ega_mode_b_outer) ---
; Bytes decode as:
;   F6 37          -- (db 0F3h redundant prefix) div byte ptr [bx]  (sets up BH/BL from AX)
;   51             -- push cx
;   38 B8 50 00    -- cmp ds:[bx+si+50h],bh   (or similar - data-dependent)
;   F6 E3          -- mul bl
;   8A DF          -- mov bl,bh
;   32 FF          -- xor bh,bh
;   03 C3          -- add ax,bx
;   8B F8          -- mov di,ax
;   B8 00 A0       -- mov ax,0A000h
;   8E C0          -- mov es,ax
;   BA C4 03       -- mov dx,3C4h
;   B0 02          -- mov al,2
;   EE             -- out dx,al
;   42             -- inc dx
;   8B D9          -- mov bx,cx

mode_handler_f_setup:
		aaa				; Ascii adjust
		db	0F3h, 37h, 51h, 38h,0B8h, 50h	; +0x000
		db	 00h,0F6h,0E3h, 8Ah,0DFh, 32h	; +0x006
		db	0FFh, 03h,0C3h, 8Bh,0F8h,0B8h	; +0x00C
		db	 00h,0A0h, 8Eh,0C0h,0BAh,0C4h	; +0x012
		db	 03h,0B0h, 02h,0EEh, 42h, 8Bh	; +0x018
		db	0D9h	; +0x01E

ega_mode_b_outer:
					push	di

ega_mode_b_col_loop:
								mov	al,1
								out	dx,al			; port 0, DMA-1 bas&add ch 0
								mov	ah,ds:[bp+si]
								movsb				; Mov [si] to es:[di]
								mov	al,4
								out	dx,al			; port 0, DMA-1 bas&add ch 0
								mov	es:[di-1],ah
								dec	bh
								jnz	ega_mode_b_col_loop			; Jump if not zero
					pop	di
					add	di,50h
					mov	bh,ch
					dec	bl
					jnz	ega_mode_b_outer			; Jump if not zero
		retn

; --- Mode handler G: CGA (0B800h) sprite render with column/row address calc ---
; Dispatched via cs:[36A5h + 2*bos_mode]. Computes a CGA interlaced-memory
; target address from BX (column*80 with odd-row +2000h offset) and renders
; a nibble-decoded block via cs:bos_color_lut_c.

mode_handler_g:
		mov	ax,50h
		shr	bl,1			; Shift w/zeros fill
		sbb	dx,dx
		mul	bl			; ax = reg * al
		and	dx,2000h
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,cx

cga_mode_d_outer:
					push	di
					push	cx

cga_mode_d_col_loop:
								push	bx
								mov	ah,ds:[bp+si]
								lodsb				; String [si] to al
								xor	dl,dl			; Zero register
								mov	cx,4

cga_mode_d_decode_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,cs:[bos_color_lut_c][bx]
								loop	cga_mode_d_decode_loop		; Loop if cx > 0

								mov	al,dl
								stosb				; Store al to es:[di]
								pop	bx
								dec	bh
								jnz	cga_mode_d_col_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	cga_mode_d_skip			; Jump if below
					add	di,bos_wrap_c050

cga_mode_d_skip:
					mov	bh,ch
					dec	bl
					jnz	cga_mode_d_outer			; Jump if not zero
		retn
		db	 00h, 03h, 02h, 01h, 01h, 03h	; +0x000
		db	 02h, 01h, 00h, 03h, 02h, 01h	; +0x006
		db	 01h, 03h, 02h, 01h, 33h,0C0h	; +0x00C
		db	 8Ah,0C3h, 05h, 1Ch, 00h,0B2h	; +0x012
		db	 03h,0F6h,0F2h, 8Ah,0F4h,0D0h	; +0x018
		db	0CEh,0D0h,0CEh,0D0h,0CEh,0B4h	; +0x01E
		db	 5Ah,0F6h,0E4h, 81h,0E2h, 00h	; +0x024
		db	 60h, 03h,0C2h, 80h,0C7h, 05h	; +0x02A
		db	 8Ah,0DFh, 32h,0FFh, 03h,0C3h	; +0x030
		db	 8Bh,0F8h,0B8h, 00h,0B0h, 8Eh	; +0x036
		db	0C0h, 8Bh,0D9h	; +0x03C

cga_mode_e_outer:
					push	di
					push	cx

cga_mode_e_col_loop:
								push	bx
								mov	ah,ds:[bp+si]
								lodsb				; String [si] to al
								xor	dl,dl			; Zero register
								mov	cx,4

cga_mode_e_decode_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,cs:[bos_color_lut_c][bx]
								loop	cga_mode_e_decode_loop		; Loop if cx > 0

								mov	al,dl
								stosb				; Store al to es:[di]
								pop	bx
								dec	bh
								jnz	cga_mode_e_col_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,bos_limit_6000
					jb	cga_mode_e_branch			; Jump if below
					push	ds
					push	si
					push	cx
					push	di
					push	es
					pop	ds
					mov	si,di
					sub	si,2000h
					mov	cl,ch
					xor	ch,ch			; Zero register
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	di
					pop	cx
					pop	si
					pop	ds
					add	di,0A05Ah

cga_mode_e_branch:
					mov	bh,ch
					dec	bl
					jnz	cga_mode_e_outer			; Jump if not zero
		retn

; --- Mode handler H: VGA (0A000h) sprite render with 320-byte row stride ---
; Dispatched via cs:[36A5h + 2*bos_mode]. DI = BX*140h (320 * col_bl) + 4*bh,
; then decodes a block through nibble_expand_8_b at VGA 0xA000.

mode_handler_h:
		xor	dx,dx			; Zero register
		mov	dl,bh
		mov	bh,dh
		push	dx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	dx
		add	dx,dx
		add	dx,dx
		add	ax,dx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	bx,cx

vga_mode_b_outer:
					push	di
					push	cx

vga_mode_b_col_loop:
								push	bx
								mov	dl,[si]
								mov	dh,ds:[bp+si]
								call	nibble_expand_8_b
								stosb				; Store al to es:[di]
								call	nibble_expand_8_b
								stosb				; Store al to es:[di]
								call	nibble_expand_8_b
								stosb				; Store al to es:[di]
								call	nibble_expand_8_b
								stosb				; Store al to es:[di]
								inc	si
								pop	bx
								dec	bh
								jnz	vga_mode_b_col_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,140h
					mov	bh,ch
					dec	bl
					jnz	vga_mode_b_outer			; Jump if not zero
		retn

nibble_expand_8_b		proc	near
		xor	al,al			; Zero register
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		retn

nibble_expand_8_b		endp

; --- Mode handler I: CGA (0B800h) 4-bank interlaced render ---
; Dispatched via cs:[36A5h + 2*bos_mode]. Row mapped to one of 4 CGA interlace
; banks (2000h apart); column BL*A0 + BH*2 forms the destination offset.
; Uses decode_nibble_pair_alt with cs:bos_color_lut_d.

mode_handler_i:
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mov	ax,0A0h
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,cx

cga_mode_f_outer:
					push	di
					push	cx

cga_mode_f_col_loop:
								push	bx
								mov	dh,ds:[bp+si]
								mov	dl,[si]
								call	decode_nibble_pair_alt
								stosb				; Store al to es:[di]
								call	decode_nibble_pair_alt
								stosb				; Store al to es:[di]
								inc	si
								pop	bx
								dec	bh
								jnz	cga_mode_f_col_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,8000h
					jb	cga_mode_f_skip			; Jump if below
					add	di,80A0h

cga_mode_f_skip:
					mov	bh,ch
					dec	bl
					jnz	cga_mode_f_outer			; Jump if not zero
		retn

decode_nibble_pair_alt		proc	near
		xor	al,al			; Zero register
		mov	cx,2

nibble_decode_step_2:
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					and	bl,0Fh
					xor	bh,bh			; Zero register
					add	al,al
					add	al,al
					add	al,al
					add	al,al
					or	al,cs:[bos_color_lut_d][bx]
					loop	nibble_decode_step_2		; Loop if cx > 0

		retn

decode_nibble_pair_alt		endp

		db	 00h, 07h, 09h, 01h, 07h, 0Fh	; +0x000
		db	 0Bh, 07h, 09h, 0Bh, 0Bh, 03h	; +0x006
		db	 01h, 07h, 03h, 09h, 4Ch,0A8h	; +0x00C
		db	0A0h, 43h, 88h, 2Ah, 4Fh, 4Fh	; +0x012
		db	 4Fh, 41h,0A0h,0A2h, 43h,0A0h	; +0x018
		db	 43h, 8Ah, 4Fh, 4Bh,0A8h, 02h	; +0x01E
		db	 4Dh,0A8h, 2Ah, 43h, 0Ah, 41h	; +0x024
		db	 11h, 46h, 80h, 45h, 80h, 0Ah	; +0x02A
		db	 4Fh, 43h,0A0h, 11h, 22h, 0Ah	; +0x030
		db	 43h, 80h, 2Ah, 46h,0EBh,0C0h	; +0x036
		db	 0Ah, 42h,0A0h, 41h, 13h, 2Ah	; +0x03C
		db	 44h,0A0h,0ABh,0EAh, 42h,0A0h	; +0x042
		db	 02h, 11h, 0Ah,0AEh, 49h,0AFh	; +0x048
		db	 42h,0BEh, 42h,0A0h, 11h, 02h	; +0x04E
		db	 8Ah, 80h, 2Ah, 41h,0A0h, 11h	; +0x054
		db	 02h, 45h,0AEh,0ACh, 02h, 80h	; +0x05A
		db	 42h, 8Ah, 80h, 02h, 02h, 80h	; +0x060
		db	 03h, 20h, 2Ah, 42h,0A8h, 2Ah	; +0x066
		db	0BAh, 42h, 88h, 08h, 20h, 11h	; +0x06C
		db	 43h, 80h, 0Ah, 41h,0ABh, 43h	; +0x072
		db	0A0h, 3Ah,0ABh, 11h, 41h,0A8h	; +0x078
		db	 11h, 02h, 20h, 28h, 08h, 0Ah	; +0x07E
		db	 41h, 11h, 0Ah,0A0h, 46h,0E8h	; +0x084
		db	 0Ah,0A8h, 0Ah, 41h, 88h, 11h	; +0x08A
		db	 88h, 2Ah, 41h,0BCh, 0Ch, 08h	; +0x090
		db	 2Ah, 42h, 02h, 42h,0A8h, 22h	; +0x096
		db	 22h,0A0h,0A2h, 2Bh, 41h,0A0h	; +0x09C
		db	 11h, 20h, 0Fh, 41h,0EAh, 41h	; +0x0A2
		db	0F8h, 08h, 02h,0A0h, 02h, 0Ah	; +0x0A8
		db	0A8h, 11h, 88h,0A0h, 08h,0A2h	; +0x0AE
		db	 02h,0A0h, 02h, 88h, 11h, 0Eh	; +0x0B4
		db	0BFh, 43h,0AEh, 11h, 2Ah, 41h	; +0x0BA
		db	 82h, 41h, 28h, 02h, 20h, 41h	; +0x0C0
		db	0ABh, 80h, 30h, 11h, 22h, 42h	; +0x0C6
		db	0A0h,0ABh, 41h,0A0h	; +0x0CC
		db	8	; +0x0D0

; --- Sprite bitmap + embedded dispatch table data ---
; This region contains packed sprite bitmap pixel data for the boss,
; plus the CS-relative animation dispatch table at offset 36A5h
; (file+16A5h) referenced by render_dispatch_layer2 above, plus color LUTs
; at offsets matching bos_color_lut_a..d (3497h, 3654h, 3753h, 38D0h).
; Sourcer misidentifies many bytes as x86 code because the data bytes
; happen to form valid instruction patterns. All kept as raw db.

sprite_bitmap_data:
		db	 41h, 0Ah, 43h, 11h, 08h, 8Ah	; +0x000
		db	 80h,0BAh,0BAh,0AEh, 12h, 08h	; +0x006
		db	0F0h, 80h, 02h,0A0h, 02h, 22h	; +0x00C
		db	 41h, 80h, 02h, 82h, 80h, 20h	; +0x012
		db	 2Ah,0A0h, 03h,0C0h,0FEh, 42h	; +0x018
		db	0B0h, 02h, 41h,0A2h, 82h, 41h	; +0x01E
		db	0A0h, 22h, 11h, 22h,0AEh, 41h	; +0x024
		db	 30h, 11h, 02h, 42h,0A8h, 2Bh	; +0x02A
		db	 41h,0A0h, 41h, 20h, 41h, 80h	; +0x030
		db	 0Ah,0EAh, 88h, 41h,0A8h, 28h	; +0x036
		db	 0Bh,0BAh,0E0h, 11h, 22h, 08h	; +0x03C
		db	 02h,0A2h, 02h,0A2h, 02h, 41h	; +0x042
		db	0A2h, 80h, 22h, 80h, 82h, 8Ah	; +0x048
		db	 11h, 02h, 8Ch, 11h, 23h, 42h	; +0x04E
		db	0A0h, 0Ah, 41h, 2Ah, 82h, 41h	; +0x054
		db	 80h, 0Ah, 20h, 43h,0E2h,0A0h	; +0x05A
		db	 11h,0A8h, 42h, 2Ah, 41h,0A0h	; +0x060
		db	0A0h, 41h,0A0h, 11h, 0Ah,0E8h	; +0x066
		db	 2Ah, 41h,0A8h, 80h, 11h,0EAh	; +0x06C
		db	 11h, 82h, 08h, 22h, 8Ah,0A0h	; +0x072
		db	 11h,0A2h, 82h, 41h, 2Ah, 20h	; +0x078
		db	 2Ah,0A8h, 08h, 22h, 8Ah, 41h	; +0x07E
		db	 2Ch, 02h, 41h,0ABh, 41h,0A0h	; +0x084
		db	 8Ah,0A8h, 41h, 80h,0C8h, 11h	; +0x08A
		db	 0Ah, 28h, 8Ah, 42h,0A8h, 8Ah	; +0x090
		db	 80h,0A8h, 43h,0EAh, 82h,0A2h	; +0x096
		db	 41h, 12h, 0Ah,0A8h, 11h, 2Ah	; +0x09C
		db	 41h, 88h, 08h,0EAh, 11h, 88h	; +0x0A2
		db	 80h,0A8h, 0Ah,0A8h, 08h, 88h	; +0x0A8
		db	 80h, 88h, 41h,0A8h, 0Ah, 08h	; +0x0AE
		db	 80h, 11h, 0Ah, 88h,0B0h, 28h	; +0x0B4
		db	 8Ah, 02h, 41h, 80h, 22h, 22h	; +0x0BA
		db	 22h, 82h,0CAh, 11h, 88h, 20h	; +0x0C0
		db	 22h,0EAh, 41h,0A2h, 22h, 20h	; +0x0C6
		db	 2Ah, 2Ah, 41h,0AEh, 41h, 8Ah	; +0x0CC
		db	 8Ah, 28h, 12h, 03h,0A0h, 11h	; +0x0D2
		db	 0Ah,0BAh, 22h, 41h, 38h, 20h	; +0x0D8
		db	 22h, 8Ah, 22h, 22h, 22h, 41h	; +0x0DE
		db	 22h, 20h, 22h, 41h, 22h, 12h	; +0x0E4
		db	 0Ah, 22h, 22h, 22h,0B0h, 02h	; +0x0EA
		db	 22h, 11h,0EAh,0CAh, 42h, 8Ah	; +0x0F0
		db	 8Bh,0C8h, 28h, 20h,0A8h, 41h	; +0x0F6
		db	0FAh, 41h,0EAh, 41h,0A8h, 0Ah	; +0x0FC
		db	 2Ah, 41h,0ABh, 41h, 8Ah, 88h	; +0x102
		db	 80h, 12h, 03h, 41h, 88h, 02h	; +0x108
		db	 42h, 20h, 88h,0A8h, 2Ah, 8Ah	; +0x10E
		db	0A0h, 2Bh, 41h, 20h, 42h, 0Ah	; +0x114
		db	 42h,0A0h, 2Ah, 20h, 43h,0C0h	; +0x11A
		db	 2Ah, 41h, 11h,0EAh,0E2h, 22h	; +0x120
		db	0A2h, 2Ah, 03h, 20h, 20h, 08h	; +0x126
		db	 20h, 3Ah,0F2h, 41h, 22h, 22h	; +0x12C
		db	 20h, 22h, 44h, 0Ah, 2Ah, 80h	; +0x132
		db	 02h, 22h, 22h,0A2h, 22h, 11h	; +0x138
		db	0AEh, 22h,0EAh, 22h, 22h, 22h	; +0x13E
		db	 0Ah, 02h, 2Ah, 22h, 2Bh, 22h	; +0x144
		db	 22h, 02h, 2Ah,0A0h, 11h, 22h	; +0x14A
		db	 2Ah, 22h, 22h, 3Fh, 0Ah, 02h	; +0x150
		db	 22h, 80h, 45h, 0Bh,0A8h, 20h	; +0x156
		db	 80h, 22h,0BAh,0FAh, 43h,0ABh	; +0x15C
		db	0E2h, 82h, 42h,0EAh, 2Ah,0A2h	; +0x162
		db	 11h, 0Ah, 42h,0EAh, 41h,0A0h	; +0x168
		db	0EAh, 41h,0BAh, 42h, 2Ah, 8Ah	; +0x16E
		db	 2Ah,0EEh, 44h,0A0h, 41h, 80h	; +0x174
		db	 44h,0BFh,0C0h, 2Ah, 82h, 41h	; +0x17A
		db	 20h,0ABh,0A2h, 22h,0A2h	; +0x180
ckpd_raw_region_anchor_a		db	0A8h			; data table (indexed access)
		db	 0Fh, 20h, 20h, 22h,0A2h, 22h	; +0x186
		db	0EAh,0ABh, 22h, 22h,0FEh, 28h	; +0x18C
		db	 2Ah, 42h,0A8h, 2Ah,0A0h, 02h	; +0x192
		db	 20h, 11h, 22h,0E2h, 22h, 20h	; +0x198
		db	 22h, 23h,0EBh,0E2h, 32h, 02h	; +0x19E
		db	 11h, 22h,0AEh, 22h, 2Ah,0A3h	; +0x1A4
		db	 22h, 2Ah, 22h, 02h, 22h, 22h	; +0x1AA
		db	 2Ah,0FFh,0C0h, 02h, 22h, 20h	; +0x1B0
		db	 22h, 80h, 2Bh, 88h, 8Ah, 88h	; +0x1B6
		db	 88h, 3Bh, 80h, 88h, 80h, 80h	; +0x1BC
		db	 8Bh,0EAh,0A8h,0A8h, 8Fh, 88h	; +0x1C2
		db	 88h, 82h, 42h,0BAh,0A8h,0A8h	; +0x1C8
		db	 08h, 11h, 88h, 88h, 88h, 88h	; +0x1CE
		db	 88h, 3Ah, 8Ch,0BFh,0BFh, 8Bh	; +0x1D4
		db	0C0h, 11h, 8Bh, 8Ch,0C8h, 8Ah	; +0x1DA
		db	0F8h, 88h,0C8h, 80h, 08h, 88h	; +0x1E0
		db	 88h,0BFh, 12h, 80h, 88h, 88h	; +0x1E6
		db	 08h, 20h, 2Ah,0A2h, 41h, 2Ah	; +0x1EC
		db	0A8h, 2Fh, 02h, 22h, 0Ah, 82h	; +0x1F2
		db	0ABh,0E2h, 2Eh	; +0x1F8
dw	0BAA2h			; data table (indexed access)
		db	 22h, 2Ah,0A2h,0FEh, 41h,0BAh	; +0x1FD
		db	 41h,0A0h, 20h, 2Ah,0A2h, 41h	; +0x203
		db	 22h, 2Ah,0A2h, 3Ah, 2Eh, 2Fh	; +0x209
		db	0EBh,0BAh, 32h, 0Ah,0AEh,0B3h	; +0x20F
		db	 32h, 2Ah,0EEh,0EAh, 2Ah, 0Ah	; +0x215
		db	0A2h,0EAh, 2Fh,0C0h, 02h, 12h	; +0x21B
		db	 22h,0A2h, 0Ah, 88h, 2Ch, 88h	; +0x221
		db	0A8h, 41h,0A0h,0BBh, 08h, 80h	; +0x227
		db	 08h, 88h,0CBh, 88h,0B8h, 88h	; +0x22D
		db	0C8h, 88h, 88h, 88h,0AEh, 42h	; +0x233
		db	0A2h, 11h, 80h, 88h, 88h, 88h	; +0x239
		db	 88h, 88h, 88h, 0Eh,0B8h, 88h	; +0x23F
		db	0CAh,0BFh, 88h, 0Ah,0CBh,0C3h	; +0x245
		db	0B8h, 88h,0BFh,0CCh, 8Ah, 08h	; +0x24B
		db	 88h,0ABh,0F0h, 3Ch, 88h, 88h	; +0x251
		db	 08h, 08h, 88h, 88h, 41h, 22h	; +0x257
		db	 2Ah, 41h,0EAh, 82h, 3Bh, 0Ah	; +0x25D
		db	 82h, 20h, 0Ah,0ABh, 41h,0A2h	; +0x263
		db	 41h,0EAh, 41h,0F3h, 2Ah,0AEh	; +0x269
		db	 42h, 8Ah, 02h,0A2h,0A2h, 2Ah	; +0x26F
		db	 42h,0A2h, 2Ah, 8Eh,0EAh,0A2h	; +0x275
		db	0EAh,0BAh,0EEh,0AEh, 3Ch, 11h	; +0x27B
		db	0FAh,0B2h, 2Bh,0AEh, 41h,0A2h	; +0x281
		db	 2Ah,0B8h, 11h, 03h,0C2h,0A8h	; +0x287
		db	 02h, 02h, 2Ah, 82h, 88h, 02h	; +0x28D
		db	 41h,0A8h,0A8h, 0Bh,0EEh, 20h	; +0x293
		db	 11h,0A8h, 41h,0AEh, 8Ah, 42h	; +0x299
		db	0E0h, 8Fh, 42h,0ABh, 42h, 88h	; +0x29F
		db	 11h, 88h, 42h,0A0h, 88h, 42h	; +0x2A5
		db	 88h,0C8h, 41h,0BAh,0A0h, 41h	; +0x2AB
		db	0BEh,0C0h, 11h,0CCh,0BAh, 41h	; +0x2B1
		db	0F8h, 8Ah, 42h,0C0h, 08h, 80h	; +0x2B7
		db	 28h, 2Ah, 88h,0A2h, 41h,0A0h	; +0x2BD
		db	 22h, 0Ah, 2Ah, 41h, 80h, 2Bh	; +0x2C3
		db	0F8h, 28h, 20h, 28h, 2Bh,0ABh	; +0x2C9
		db	0EAh, 2Ah, 2Bh,0ABh,0F2h, 2Fh	; +0x2CF
		db	0FFh, 08h, 42h, 88h, 0Ah, 22h	; +0x2D5
		db	 2Ah, 11h, 0Ah, 20h, 2Ah, 2Ah	; +0x2DB
		db	0A2h, 22h, 2Ah, 3Ah, 41h, 3Eh	; +0x2E1
		db	0EBh, 11h, 20h,0EEh, 3Ah, 2Ah	; +0x2E7
		db	0AEh, 22h, 2Ah, 2Ah, 02h, 20h	; +0x2ED
		db	 11h, 02h, 02h, 22h, 2Ah, 2Ah	; +0x2F3
		db	0A2h, 88h, 88h,0BAh,0A8h, 11h	; +0x2F9
		db	0BCh, 11h, 88h, 11h, 80h,0ABh	; +0x2FF
		db	 8Eh,0F8h, 88h, 8Bh, 8Ch, 8Bh	; +0x305
		db	0F0h, 11h, 0Ah, 42h, 28h, 08h	; +0x30B
		db	 80h, 11h, 08h, 88h, 88h, 12h	; +0x311
		db	 8Ah, 88h, 88h, 8Ch, 88h, 88h	; +0x317
		db	0A0h, 08h, 11h,0B8h,0A8h, 88h	; +0x31D
		db	 8Ch, 8Ah, 88h,0ACh, 88h, 88h	; +0x323
		db	 88h, 11h, 88h, 8Ah, 88h, 8Ah	; +0x329
		db	 80h, 22h, 2Ah,0EAh, 28h, 02h	; +0x32F
		db	 3Ch, 11h, 20h, 02h, 0Ah,0A2h	; +0x335
		db	 2Bh, 32h, 2Ah, 2Eh,0F2h,0FCh	; +0x33B
		db	 12h, 0Eh, 2Ah, 41h, 20h, 11h	; +0x341
		db	 02h, 2Ah, 22h, 22h, 22h, 02h	; +0x347
		db	 20h, 02h, 22h, 2Ah, 2Eh,0E2h	; +0x34D
		db	 2Ah,0C0h, 02h, 20h, 32h,0EAh	; +0x353
		db	 22h, 22h, 2Ah, 2Ah,0AEh, 22h	; +0x359
		db	0E2h, 2Ah, 20h,0A2h, 22h, 41h	; +0x35F
		db	 22h, 22h, 88h, 88h,0EBh,0A0h	; +0x365
		db	 08h	; +0x36B
dw	12FCh			; data table (indexed access)
		db	 88h, 08h,0A8h,0FBh,0A8h, 88h	; +0x36E
		db	0AFh, 8Bh, 13h, 02h, 2Ah, 41h	; +0x374
		db	 20h, 11h, 88h, 8Fh,0CBh,0C8h	; +0x37A
		db	0F8h, 88h, 88h, 80h, 88h, 11h	; +0x380
		db	 8Ch,0B8h, 8Eh,0C0h, 88h, 88h	; +0x386
		db	 3Ch,0E8h, 88h,0AFh,0A8h, 88h	; +0x38C
		db	0BBh, 88h,0C8h, 8Bh, 80h, 28h	; +0x392
		db	0FCh,0A8h, 88h,0A8h, 22h,0A2h	; +0x398
		db	 23h, 20h, 22h,0F2h, 20h, 22h	; +0x39E
		db	 20h, 22h,0A2h,0A3h,0A2h,0A2h	; +0x3A4
		db	 32h, 2Ch, 11h, 02h, 11h, 22h	; +0x3AA
		db	 42h,0AEh, 22h, 22h,0AEh,0FFh	; +0x3B0
		db	 23h, 22h,0A2h, 22h, 20h, 11h	; +0x3B6
		db	0A0h, 02h,0A2h, 32h, 22h, 20h	; +0x3BC
		db	 11h, 2Eh,0FAh, 22h, 2Bh,0E2h	; +0x3C2
		db	0A2h, 32h,0E2h,0EAh,0E2h, 20h	; +0x3C8
		db	 22h,0C3h,0A2h, 22h, 2Ah, 88h	; +0x3CE
		db	 8Bh, 88h,0A0h, 88h,0B0h, 11h	; +0x3D4
		db	 80h, 11h,0ABh, 8Eh, 8Fh,0C8h	; +0x3DA
		db	 88h,0CBh,0B0h, 13h, 0Ah, 42h	; +0x3E0
		db	0ACh, 88h, 8Bh,0CBh,0BCh,0FCh	; +0x3E6
		db	 8Bh, 88h, 88h, 88h, 88h, 88h	; +0x3EC
		db	 8Ah,0B8h,0BBh, 08h, 11h, 88h	; +0x3F2
		db	 88h,0CAh, 88h,0CBh,0B8h, 8Ah	; +0x3F8
		db	0C8h,0CAh, 41h,0E8h, 88h, 0Bh	; +0x3FE
		db	 11h,0FAh, 88h, 8Ah, 22h, 23h	; +0x404
		db	0AEh, 80h, 23h,0F2h, 20h, 11h	; +0x40A
		db	 2Eh,0A2h, 32h, 23h, 20h, 0Fh	; +0x410
		db	 2Eh, 30h, 20h, 11h, 22h, 22h	; +0x416
		db	 42h,0AEh, 22h, 20h, 3Eh,0FEh	; +0x41C
		db	0E3h,0ECh, 02h, 22h, 22h, 22h	; +0x422
		db	 22h, 22h,0AEh,0E3h, 02h, 22h	; +0x428
		db	 22h, 2Ah,0EFh,0E3h, 22h,0E8h	; +0x42E
		db	 22h,0E2h, 3Ah,0AFh,0A2h, 22h	; +0x434
		db	 0Bh, 11h, 0Eh, 22h, 22h, 88h	; +0x43A
		db	 88h, 8Ch,0C0h, 8Ch, 0Ch,0C0h	; +0x440
		db	 88h,0F8h, 8Bh, 80h, 88h, 83h	; +0x446
		db	0F0h, 0Ch,0C0h, 11h, 88h, 80h	; +0x44C
		db	 88h, 42h,0ACh, 88h, 88h, 03h	; +0x452
		db	0BFh, 8Ch, 13h, 88h, 88h, 88h	; +0x458
		db	 82h,0B8h,0C0h, 12h, 88h, 8Ah	; +0x45E
		db	0CEh,0C3h, 88h,0B8h, 88h,0C0h	; +0x464
		db	0BBh,0AEh, 88h, 80h, 80h, 11h	; +0x46A
		db	 08h, 11h, 88h, 22h, 23h, 22h	; +0x470
		db	 82h, 2Fh, 20h, 3Eh, 02h, 22h	; +0x476
		db	0FCh, 02h, 22h,0FEh, 20h, 0Eh	; +0x47C
		db	0C2h, 02h, 20h, 02h, 22h,0BBh	; +0x482
		db	 42h, 22h, 22h, 11h,0BEh, 30h	; +0x488
		db	 22h, 20h, 02h, 22h, 22h, 20h	; +0x48E
		db	 02h,0AEh,0E2h, 20h, 02h, 22h	; +0x494
		db	 23h, 33h, 83h, 22h, 41h, 23h	; +0x49A
		db	 02h, 3Bh, 41h,0A0h, 02h, 22h	; +0x4A0
		db	 22h, 08h, 82h, 22h, 11h, 8Bh	; +0x4A6
		db	0BAh, 12h,0FFh,0C8h, 0Bh, 3Fh	; +0x4AC
		db	0A8h, 88h, 3Fh, 11h,0A8h,0B8h	; +0x4B2
		db	0C0h, 11h, 88h, 88h, 11h, 8Ah	; +0x4B8
		db	 41h,0B8h, 12h, 88h,0ACh,0C0h	; +0x4BE
		db	 11h, 88h, 88h, 12h, 88h, 8Ah	; +0x4C4
		db	0B3h, 11h, 88h, 88h, 12h,0ABh	; +0x4CA
		db	0CBh,0C0h,0F8h,0ABh, 88h, 0Ah	; +0x4D0
		db	 41h, 88h, 88h, 12h, 02h, 88h	; +0x4D6
		db	 11h, 22h, 2Ch, 23h, 02h, 22h	; +0x4DC
		db	 03h, 3Eh, 2Ah,0E2h, 80h, 03h	; +0x4E2
		db	0E2h, 22h, 20h,0C3h, 11h, 22h	; +0x4E8
		db	 11h, 02h, 22h, 8Ah,0EAh,0B2h	; +0x4EE
		db	 22h, 22h, 11h,0EEh,0E2h, 22h	; +0x4F4
		db	 11h, 02h, 22h, 22h, 11h, 02h	; +0x4FA
		db	0AFh, 22h, 11h, 02h, 22h, 22h	; +0x500
		db	 23h,0CEh, 32h,0BAh, 83h, 02h	; +0x506
		db	 2Eh,0BAh, 11h, 02h, 22h, 22h	; +0x50C
		db	 02h, 0Fh, 22h, 8Ah, 88h,0ABh	; +0x512
		db	 08h, 88h, 88h,0CBh, 8Fh, 8Bh	; +0x518
		db	 88h,0BCh,0C8h, 88h,0A8h,0CBh	; +0x51E
		db	 11h, 08h, 88h, 88h, 88h,0BAh	; +0x524
		db	0EAh,0B8h, 88h, 88h, 88h,0A8h	; +0x52A
		db	 88h, 88h, 88h, 88h, 02h, 88h	; +0x530
		db	 88h, 88h,0BBh, 88h, 88h, 88h	; +0x536
		db	 88h, 88h, 8Bh, 8Ch,0B8h,0BBh	; +0x53C
		db	 8Ch, 88h, 8Ah,0BAh, 88h, 88h	; +0x542
		db	 88h, 88h, 82h,0B0h,0C8h, 02h	; +0x548
		db	 2Ah,0ACh, 02h, 22h, 02h,0E3h	; +0x54E
		db	 2Eh, 02h, 22h,0E0h,0E2h, 22h	; +0x554
		db	0A3h, 23h, 15h, 88h, 82h, 80h	; +0x55A
		db	 02h,0A0h, 11h, 22h,0C0h, 14h	; +0x560
		db	 20h, 12h,0EBh, 12h, 02h,0E0h	; +0x566
		db	0A0h, 08h,0CCh, 0Fh, 08h, 20h	; +0x56C
		db	 02h, 22h,0BAh, 22h,0A0h, 11h	; +0x572
		db	 08h, 80h,0A0h, 3Ch, 8Ah,0A8h	; +0x578
		db	0B0h, 08h, 88h, 08h,0B8h,0CCh	; +0x57E
		db	 8Ch, 8Bh, 80h,0F8h, 41h, 8Bh	; +0x584
		db	 8Bh, 11h, 0Ah, 0Ah, 08h, 28h	; +0x58A
		db	 22h, 02h,0B0h,0A0h, 11h, 88h	; +0x590
		db	 3Ah, 80h, 2Ah, 08h, 20h, 11h	; +0x596
		db	 02h, 11h, 20h,0FFh, 20h, 88h	; +0x59C
		db	 20h, 88h, 22h, 0Fh, 32h, 20h	; +0x5A2
		db	 41h, 28h, 88h, 0Ah,0BAh, 20h	; +0x5A8
		db	 80h, 22h, 22h, 20h, 80h, 03h	; +0x5AE
		db	 11h, 2Ah, 11h,0A8h,0A2h, 0Ah	; +0x5B4
		db	0B0h,0F0h, 08h, 0Ch,0C0h, 30h	; +0x5BA
		db	 41h, 83h, 0Ch, 13h, 02h, 80h	; +0x5C0
		db	 0Ch, 0Ah,0B0h, 12h, 08h, 41h	; +0x5C6
		db	 82h, 13h, 22h, 11h, 22h, 11h	; +0x5CC
		db	0CBh, 11h, 82h, 08h, 80h, 20h	; +0x5D2
		db	 02h,0F0h, 88h, 2Ah, 80h, 08h	; +0x5D8
		db	 82h,0E8h, 02h, 02h, 13h, 80h	; +0x5DE
		db	 11h, 8Ah, 80h, 22h, 22h, 20h	; +0x5E4
		db	 0Bh,0A8h,0F8h, 88h, 8Ch,0C0h	; +0x5EA
		db	 0Ch, 41h, 8Ch, 8Ch, 16h, 08h	; +0x5F0
		db	0B0h, 13h, 28h,0C0h, 15h, 02h	; +0x5F6
		db	 20h,0FBh, 15h, 02h,0F0h, 11h	; +0x5FC
		db	 0Ah, 80h, 11h, 0Ah,0E8h, 11h	; +0x602
		db	 20h, 15h, 20h, 12h, 88h,0A0h	; +0x608
		db	 2Bh,0A0h, 30h, 30h, 30h,0C0h	; +0x60E
		db	 03h, 08h, 0Ch, 0Ch, 15h, 2Bh	; +0x614
		db	 8Ah,0B0h, 13h, 2Ah, 80h, 14h	; +0x61A
		db	 02h, 12h,0CEh, 15h, 03h, 20h	; +0x620
		db	 11h, 02h, 12h, 0Ah,0E8h, 17h	; +0x626
		db	0A0h, 08h, 82h, 2Ah, 88h, 2Eh	; +0x62C
		db	0B8h,0B8h,0A8h,0BBh, 11h, 03h	; +0x632
		db	 88h,0B8h,0B0h, 15h, 0Bh, 8Ah	; +0x638
		db	0A0h, 13h, 2Ah, 18h,0FEh, 16h	; +0x63E
		db	 80h, 11h, 02h, 12h, 0Ah,0E8h	; +0x644
		db	 11h, 20h, 15h, 80h, 11h, 28h	; +0x64A
		db	0A8h, 8Ah, 41h,0CFh, 30h, 20h	; +0x650
		db	0C2h, 11h, 03h, 0Bh, 33h,0C0h	; +0x656
		db	 15h, 2Ah, 41h,0C0h, 13h, 2Ah	; +0x65C
		db	 18h,0F2h, 16h, 80h, 14h, 0Ah	; +0x662
		db	0E8h, 17h, 88h, 88h, 22h,0A2h	; +0x668
		db	 8Ah,0ABh,0B0h,0F8h,0CBh, 8Ah	; +0x66E
		db	 11h, 03h, 8Bh, 8Ch, 16h, 0Ah	; +0x674
		db	0A2h,0C0h, 13h, 3Ah, 18h,0CEh	; +0x67A
		db	 16h, 80h, 14h, 0Ah,0E8h, 17h	; +0x680
		db	 80h, 41h, 82h, 41h, 2Bh, 41h	; +0x686
		db	 11h, 0Fh, 03h, 02h, 12h,0C3h	; +0x68C
		db	 0Ch, 16h, 0Ah,0A2h,0C0h, 13h	; +0x692
		db	 2Bh, 18h,0CEh, 16h, 80h, 14h	; +0x698
		db	 0Ah,0A8h, 17h, 88h,0A2h, 22h	; +0x69E
		db	0A2h, 2Ah,0A8h, 12h,0FCh,0A8h	; +0x6A4
		db	 12h,0CBh, 8Ch, 16h, 0Ah, 82h	; +0x6AA
		db	0C0h, 13h, 22h, 18h,0EEh, 1Bh	; +0x6B0
		db	 02h,0E8h, 17h, 2Ah, 28h, 0Ah	; +0x6B6
		db	 88h, 41h,0E0h, 12h, 0Fh, 88h	; +0x6BC
		db	 12h,0C3h, 0Ch, 17h,0A2h, 80h	; +0x6C2
		db	 13h, 2Ah, 17h, 03h,0B3h, 1Bh	; +0x6C8
		db	 02h,0EAh, 17h, 28h, 02h,0A2h	; +0x6CE
		db	 82h, 41h, 13h, 03h, 28h, 12h	; +0x6D4
		db	0CCh, 0Ch, 16h, 2Ah, 20h,0B0h	; +0x6DA
		db	 13h,0FAh, 17h, 03h,0CBh, 1Bh	; +0x6E0
		db	 02h, 3Ah, 17h, 02h,0A8h, 11h	; +0x6E6
		db	 41h,0ABh, 13h, 03h, 12h, 03h	; +0x6EC
		db	 0Ch, 30h, 16h, 0Ah, 88h,0B0h	; +0x6F2
		db	 13h, 8Bh, 17h, 03h, 23h, 1Ch	; +0x6F8
		db	 41h, 17h, 82h, 41h,0A2h, 41h	; +0x6FE
		db	0BEh, 14h,0A8h, 11h, 03h, 8Ch	; +0x704
		db	0B0h, 16h, 08h, 88h,0B0h, 13h	; +0x70A
		db	0ABh, 17h, 03h, 23h, 1Bh, 02h	; +0x710
		db	 32h, 17h, 22h,0BFh,0A8h, 41h	; +0x716
		db	0E8h, 14h, 88h, 11h, 02h, 08h	; +0x71C
		db	 30h, 16h, 02h, 28h,0B0h, 13h	; +0x722
		db	 8Ah, 17h, 03h, 23h, 1Ch, 88h	; +0x728
		db	 80h, 16h, 8Bh,0C8h,0F2h, 41h	; +0x72E
		db	0ECh, 14h,0B0h, 11h, 02h, 0Ah	; +0x734
		db	0A0h, 16h, 22h, 28h,0B0h, 13h	; +0x73A
		db	0BBh, 17h, 03h, 23h, 1Bh, 02h	; +0x740
		db	 02h, 17h, 2Ch, 11h, 38h, 41h	; +0x746
		db	0F0h, 13h, 02h, 28h, 11h, 02h	; +0x74C
		db	 28h,0A0h, 16h, 2Ah, 8Ah,0B0h	; +0x752
		db	 12h, 03h, 02h, 17h, 03h	; +0x758
dw	0C030h			; data table (indexed access)
		db	 1Ah, 08h, 80h, 80h, 16h, 2Ch	; +0x75F
		db	 11h, 0Ah, 2Bh,0A0h, 14h, 88h	; +0x765
		db	 11h, 02h, 2Ah,0A0h, 16h, 2Ah	; +0x76B
		db	 8Ah,0ACh, 12h, 02h, 30h, 80h	; +0x771
		db	 16h, 0Ch, 80h,0C0h, 1Ah, 02h	; +0x777
		db	 88h, 17h,0B0h, 11h, 08h,0ABh	; +0x77D
		db	0A0h, 13h, 08h, 28h, 11h, 03h	; +0x783
		db	 2Ch, 8Ch, 16h, 0Ah, 8Ah,0A8h	; +0x789
		db	 12h, 02h, 8Ch, 80h, 16h, 0Fh	; +0x78F
		db	 80h,0C0h, 1Ah, 08h, 02h, 20h	; +0x795
		db	 16h,0B0h, 11h, 0Eh, 2Bh,0B0h	; +0x79B
		db	 14h, 28h, 11h, 08h, 22h, 88h	; +0x7A1
		db	 16h, 0Ah,0A8h, 88h, 12h, 08h	; +0x7A7
		db	 20h, 20h, 16h, 02h, 8Ch, 80h	; +0x7AD
		db	 1Ah, 02h, 20h, 20h, 16h,0B0h	; +0x7B3
		db	 11h, 08h,0ABh, 80h, 14h, 08h	; +0x7B9
		db	 11h, 0Ch, 08h, 28h, 16h, 0Ah	; +0x7BF
		db	 8Ah, 28h, 13h, 82h, 17h, 0Ah	; +0x7C5
		db	0C8h, 80h, 1Ah, 28h, 02h, 08h	; +0x7CB
		db	 16h,0B0h, 11h, 02h, 2Ah, 80h	; +0x7D1
		db	 13h, 08h, 02h, 12h, 0Ch, 08h	; +0x7D7
		db	 16h, 0Ah, 88h, 88h, 12h, 0Ah	; +0x7DD
		db	 0Ah, 80h, 16h, 0Ch,0C8h,0A0h	; +0x7E3
		db	 1Ah, 28h, 20h, 82h, 16h,0C0h	; +0x7E9
		db	 11h, 08h,0AEh,0C0h, 13h, 08h	; +0x7EF
		db	 12h, 08h, 0Ch, 08h, 16h, 0Ah	; +0x7F5
		db	 2Ah, 28h, 12h, 02h, 11h, 80h	; +0x7FB
		db	 16h, 3Ah, 08h, 20h, 1Ah, 80h	; +0x801
		db	 11h, 08h, 20h, 15h,0C0h, 11h	; +0x807
		db	 22h, 2Eh,0C0h, 16h, 08h, 88h	; +0x80D
		db	 88h, 16h, 0Ah, 08h, 88h, 12h	; +0x813
		db	 08h, 18h, 22h, 11h, 20h, 19h	; +0x819
		db	 0Ah, 19h,0C0h, 11h, 28h,0AEh	; +0x81F
		db	 14h, 80h, 12h, 08h, 88h, 02h	; +0x825
		db	 16h, 0Ah, 22h, 02h, 1Bh, 23h	; +0x82B
		db	 08h, 08h, 1Fh, 16h, 22h, 2Eh	; +0x831
		db	 17h, 08h, 82h, 02h, 16h, 0Ah	; +0x837
		db	 41h, 82h, 1Bh,0E0h, 02h, 1Eh	; +0x83D
		db	 28h, 17h, 08h,0ABh, 19h, 80h	; +0x843
		db	 80h, 15h, 08h, 41h, 02h, 1Bh	; +0x849
		db	0A0h, 02h, 1Eh, 0Ah, 17h, 2Ah	; +0x84F
		db	0BBh, 17h, 02h, 02h, 20h, 80h	; +0x855
		db	 15h, 0Ah, 2Ah, 80h, 80h, 19h	; +0x85B
		db	 03h, 80h, 11h, 80h, 1Dh, 02h	; +0x861
		db	 17h, 0Ah,0ACh, 17h, 80h, 08h	; +0x867
		db	 80h, 20h, 15h, 22h, 28h, 80h	; +0x86D
		db	 1Fh, 1Fh, 15h, 3Ah,0B8h, 16h	; +0x873
		db	 0Ah, 08h, 02h, 08h, 0Ah, 15h	; +0x879
		db	 28h, 28h, 11h, 80h, 1Fh, 1Fh	; +0x87F
		db	 14h, 32h,0B8h, 19h, 82h, 16h	; +0x885
		db	 28h, 22h, 02h, 1Fh, 1Fh, 15h	; +0x88B
		db	 0Eh,0B8h, 1Fh, 11h,0A0h,0A8h	; +0x891
		db	 80h, 88h, 1Fh, 1Fh, 14h, 0Ah	; +0x897
		db	0BCh, 1Fh, 11h,0A0h, 28h, 11h	; +0x89D
		db	 20h, 1Fh, 1Fh, 14h, 0Ah, 8Ch	; +0x8A3
		db	 1Fh, 02h, 11h, 82h, 1Fh, 1Fh	; +0x8A9
		db	 16h, 08h, 20h, 1Fh, 12h, 02h	; +0x8AF
		db	 1Fh, 1Fh, 16h, 08h,0A0h, 1Fh	; +0x8B5
		db	 12h, 08h, 1Fh, 1Fh, 17h, 30h	; +0x8BB
		db	 1Fh, 11h, 20h, 1Fh, 1Fh, 18h	; +0x8C1
		db	 30h, 00h, 4Ch,0ABh,0AFh, 43h	; +0x8C7
		db	0C8h, 3Ah, 4Fh, 4Bh,0ABh,0FEh	; +0x8CD
		db	 48h,0FFh, 44h,0ABh,0EAh, 41h	; +0x8D3
		db	0BAh, 41h,0AFh,0AEh,0FFh, 42h	; +0x8D9
		db	0AFh, 43h, 8Fh, 45h,0BFh,0FAh	; +0x8DF
		db	0FEh, 44h,0BEh, 46h,0AFh, 45h	; +0x8E5
		db	0AFh,0FCh, 03h,0FAh, 41h,0EAh	; +0x8EB
		db	 41h,0BFh,0EAh, 41h,0AFh,0BAh	; +0x8F1
		db	 43h,0AEh,0BCh, 3Ah,0FAh,0EAh	; +0x8F7
		db	 41h,0FAh,0FFh, 11h,0FFh,0EAh	; +0x8FD
		db	0BEh,0AEh,0AFh, 41h, 80h,0EEh	; +0x903
		db	0EAh, 42h,0AFh,0C0h, 0Fh,0FBh	; +0x909
		db	0FAh, 43h,0ABh,0FEh, 43h,0ABh	; +0x90F
		db	0EAh, 41h,0EAh, 43h,0AFh,0F0h	; +0x915
ckpd_pattern_dst_buf		db	 11h			; data table (indexed access)
		db	 22h, 0Fh,0EEh,0BAh,0AFh,0C0h	; +0x91C
		db	 3Eh, 41h,0FBh,0EAh,0BEh, 42h	; +0x922
		db	 38h, 11h, 0Fh,0AFh,0BAh,0AFh	; +0x928
		db	0BFh, 13h, 3Fh,0EAh,0FFh, 41h	; +0x92E
		db	0FAh,0A0h,0E8h, 3Fh, 42h,0B0h	; +0x934
		db	 02h, 11h, 0Fh,0A2h, 41h,0FAh	; +0x93A
		db	0BFh,0FAh,0ABh,0FAh, 41h,0EBh	; +0x940
		db	0EEh,0A0h,0EAh,0BAh,0C3h,0BAh	; +0x946
		db	0ABh,0F0h, 11h, 02h, 8Ah, 80h	; +0x94C
		db	 3Bh, 41h,0F0h, 11h, 03h,0AFh	; +0x952
		db	0BEh, 41h,0ABh,0AEh,0A3h,0A0h	; +0x958
		db	 02h, 80h,0FEh,0EAh,0BBh,0C0h	; +0x95E
		db	 02h, 02h, 80h, 03h, 3Fh,0FAh	; +0x964
		db	0FEh,0ABh,0A8h, 3Eh, 8Eh,0EAh	; +0x96A
		db	0ABh,0C8h, 08h, 20h, 11h,0EBh	; +0x970
		db	0ABh,0AFh,0C0h, 0Fh,0FBh,0ACh	; +0x976
		db	 41h,0BEh,0ABh,0F0h, 0Eh,0ACh	; +0x97C
		db	 11h,0FFh,0ACh, 11h, 02h, 20h	; +0x982
		db	 28h, 08h, 0Eh,0EFh, 11h, 0Ah	; +0x988
		db	0A0h,0FBh,0EAh, 41h,0AFh,0AEh	; +0x98E
		db	0BAh, 38h, 0Ah,0E8h, 0Eh,0AEh	; +0x994
		db	0BCh, 11h, 88h, 2Ah, 41h,0BCh	; +0x99A
		db	 0Ch, 0Fh,0EBh,0EAh, 41h, 03h	; +0x9A0
		db	0EBh,0BAh,0ACh, 22h, 22h,0F0h	; +0x9A6
		db	0E2h, 38h,0AEh,0F0h, 11h, 20h	; +0x9AC
		db	 11h,0BEh, 2Eh, 41h, 0Ch, 08h	; +0x9B2
		db	 03h,0B0h, 02h, 0Eh,0ECh, 11h	; +0x9B8
		db	 88h,0A0h, 08h,0A2h, 03h,0F0h	; +0x9BE
		db	 02h, 88h, 11h, 0Eh,0BFh, 41h	; +0x9C4
		db	0FAh,0EEh,0A3h, 11h, 3Ah,0EAh	; +0x9CA
		db	0C3h,0EFh,0ECh, 02h, 20h, 41h	; +0x9D0
		db	0ABh,0C0h, 30h, 11h, 3Eh,0BAh	; +0x9D6
		db	 41h,0A0h,0E8h,0BAh,0B0h, 08h	; +0x9DC
		db	0AFh, 0Ah,0BFh,0FAh,0EBh, 11h	; +0x9E2
		db	 08h,0CAh, 80h,0CBh, 8Ah,0A3h	; +0x9E8
		db	 12h, 08h, 11h, 80h, 03h,0B0h	; +0x9EE
		db	 02h, 22h, 41h, 80h, 02h, 83h	; +0x9F4
		db	 80h, 20h, 2Ah,0A0h, 03h,0C0h	; +0x9FA
		db	0FEh, 41h,0EAh, 80h, 02h,0AFh	; +0xA00
		db	0A2h,0C3h,0FEh,0B0h, 22h, 11h	; +0xA06
		db	 22h,0AFh, 41h, 30h, 11h, 03h	; +0xA0C
		db	 42h,0A8h, 38h,0BAh,0B0h, 41h	; +0xA12
		db	 30h,0AFh,0C0h, 0Fh, 2Bh,0C8h	; +0xA18
		db	 41h,0A8h, 28h, 0Ch, 8Ah, 30h	; +0xA1E
		db	 11h, 22h, 08h, 02h,0A2h, 03h	; +0xA24
		db	0B2h, 02h, 41h,0A2h, 80h, 22h	; +0xA2A
		db	 80h,0C2h, 8Ah, 11h, 02h, 8Ch	; +0xA30
		db	 11h, 23h,0AFh,0EEh,0B0h, 0Ah	; +0xA36
		db	0BAh, 2Bh,0C3h,0BAh,0C0h, 0Ah	; +0xA3C
		db	 20h,0ABh,0AEh, 41h,0E2h,0A0h	; +0xA42
		db	 11h,0EBh, 42h, 3Bh, 41h,0B0h	; +0xA48
		db	0A0h,0BAh,0F0h, 11h, 0Eh, 2Ch	; +0xA4E
		db	 3Fh,0EAh,0E8h, 80h, 11h, 2Fh	; +0xA54
		db	 11h, 82h, 08h, 22h, 8Ah,0A0h	; +0xA5A
		db	 11h,0F2h, 82h	; +0xA60
db	 41h			; data table (indexed access)
		db	 2Ah, 20h, 2Ah	; +0xA64
dw	08A8h			; data table (indexed access)
		db	 22h, 8Ah, 41h, 2Ch, 02h, 41h	; +0xA69
		db	0F8h,0BAh,0B0h, 8Ah,0B8h,0ABh	; +0xA6F
		db	0C0h,0FBh, 11h, 0Ah, 28h, 8Bh	; +0xA75
		db	0AEh, 41h,0E8h, 8Ah, 80h,0EBh	; +0xA7B
		db	 42h,0BAh, 2Ah,0C2h,0A2h,0EBh	; +0xA81
		db	 12h, 0Bh,0ACh, 11h, 3Ah,0BAh	; +0xA87
		db	 88h, 08h, 2Bh, 11h, 88h, 80h	; +0xA8D
		db	0A8h, 0Ah,0B8h, 08h,0C8h, 80h	; +0xA93
		db	 88h, 41h,0A8h, 0Ah, 08h, 80h	; +0xA99
		db	 11h, 0Ah, 88h,0B0h, 28h, 8Ah	; +0xA9F
		db	 03h,0BAh,0C0h, 23h, 32h, 23h	; +0xAA5
		db	0C2h,0FBh, 11h, 88h, 20h, 22h	; +0xAAB
		db	0EEh, 41h,0E2h, 22h, 20h, 3Ah	; +0xAB1
		db	0FAh, 41h,0A2h,0EAh,0CAh, 8Bh	; +0xAB7
		db	0FCh, 13h,0B0h, 11h, 0Eh, 8Eh	; +0xABD
		db	 22h, 41h, 0Ch, 20h, 22h, 8Ah	; +0xAC3
		db	 22h, 22h, 22h, 41h, 22h, 20h	; +0xAC9
		db	 22h, 41h, 22h, 12h, 0Ah, 22h	; +0xACF
		db	 22h, 22h,0B0h, 02h, 22h, 11h	; +0xAD5
		db	 3Ah, 0Ah, 41h,0FAh, 8Eh,0CBh	; +0xADB
		db	0FCh, 28h	; +0xAE1
dw	0A820h			; data table (indexed access)
		db	 41h,0FAh, 41h,0EAh, 41h,0A8h	; +0xAE5
		db	 3Eh,0EFh, 41h,0A8h,0BAh,0CAh	; +0xAEB
		db	 8Fh,0C0h, 13h,0FAh, 88h, 03h	; +0xAF1
		db	0BAh, 41h, 20h, 8Ch,0A8h, 2Ah	; +0xAF7
		db	 8Ah,0A0h, 2Bh,0EAh, 20h, 42h	; +0xAFD
		db	 0Ah, 42h,0A0h, 2Ah, 20h, 43h	; +0xB03
		db	0C0h, 2Ah, 41h, 11h, 2Eh, 22h	; +0xB09
		db	 22h,0E2h, 2Fh, 03h, 30h, 20h	; +0xB0F
		db	 08h, 20h, 3Eh,0F2h,0ABh, 22h	; +0xB15
		db	 22h, 20h, 3Fh,0BAh,0EAh,0ABh	; +0xB1B
		db	0BBh, 0Ah, 3Ah,0C0h	; +0xB21
db	 02h			; data table (indexed access)
		db	 22h, 23h,0F2h, 22h, 11h,0E2h	; +0xB26
		db	 22h,0EAh, 22h, 22h, 22h, 0Ah	; +0xB2C
		db	 02h, 3Fh, 22h, 2Bh, 22h, 22h	; +0xB32
		db	 02h, 2Ah,0A0h, 11h, 22h, 2Ah	; +0xB38
		db	 22h, 22h, 3Fh, 0Ah, 02h, 22h	; +0xB3E
		db	 80h,0FBh, 42h,0EAh,0BBh, 0Bh	; +0xB44
		db	0B8h	; +0xB4A
dw	8020h			; data table (indexed access)
		db	 22h,0BEh,0FAh,0AFh, 42h,0ABh	; +0xB4D
		db	0EEh,0FEh,0BAh,0EAh, 3Bh, 2Ah	; +0xB53
		db	0EFh, 11h, 0Ah, 42h, 2Ah, 41h	; +0xB59
		db	0A0h, 2Eh, 41h,0BAh, 42h, 2Ah	; +0xB5F
		db	 8Ah, 2Ah,0EEh, 43h,0AEh,0E0h	; +0xB65
		db	 41h, 80h, 44h,0BFh,0C0h, 2Ah	; +0xB6B
		db	 82h, 41h, 20h,0ECh,0A2h, 22h	; +0xB71
		db	0E2h,0ECh, 0Fh, 20h, 20h, 22h	; +0xB77
		db	0A2h, 32h,0FAh,0BFh, 22h, 22h	; +0xB7D
db	0FEh			; data table (indexed access)
		db	 2Bh,0EAh,0BAh,0EAh,0ECh, 2Ah	; +0xB84
		db	0ECh, 02h, 20h, 11h	; +0xB8A
ckpd_obfuscated_value		dw	2222h			; data table (indexed access)
		db	 22h, 20h, 33h, 23h,0EBh,0E2h	; +0xB90
		db	 32h, 02h, 11h, 23h,0EEh, 22h	; +0xB96
		db	 2Ah,0A3h, 22h, 3Eh, 22h, 02h	; +0xB9C
		db	 22h, 22h, 2Ah,0FFh,0C0h, 02h	; +0xBA2
		db	 22h, 20h, 22h, 80h, 38h, 88h	; +0xBA8
		db	 8Bh, 88h,0CCh, 3Bh, 80h, 88h	; +0xBAE
		db	 80h, 80h,0CBh,0FAh,0ACh,0B8h	; +0xBB4
		db	 8Fh, 88h, 88h,0BEh,0AEh,0EAh	; +0xBBA
		db	 8Eh,0A8h,0ECh, 08h, 11h, 88h	; +0xBC0
		db	 88h,0C8h, 88h, 88h, 0Bh, 8Ch	; +0xBC6
		db	0BFh,0BFh, 8Bh,0C0h, 11h, 8Bh	; +0xBCC
		db	 8Ch,0C8h, 8Bh,0F8h, 88h,0CCh	; +0xBD2
		db	 80h, 08h, 88h, 88h,0BFh, 12h	; +0xBD8
		db	 80h, 88h, 88h, 08h, 20h, 3Bh	; +0xBDE
		db	0A2h,0ABh, 2Fh,0ECh, 2Fh, 02h	; +0xBE4
		db	 22h, 0Ah, 82h,0EBh,0E2h, 3Eh	; +0xBEA
		db	0E2h,0BAh, 22h, 2Ah,0A3h,0CEh	; +0xBF0
		db	0BAh, 8Eh,0ABh,0B0h, 20h, 2Ah	; +0xBF6
		db	0A2h, 41h, 22h, 2Ah,0A2h, 0Ah	; +0xBFC
		db	 2Eh, 2Fh,0FFh,0BAh, 32h, 0Ah	; +0xC02
		db	0FEh,0B3h, 32h, 2Ah,0FFh,0EAh	; +0xC08
		db	 2Eh, 0Eh,0A2h,0EAh, 2Fh,0C0h	; +0xC0E
		db	 02h, 12h, 22h,0A2h, 0Ah, 88h	; +0xC14
		db	 30h, 88h,0BCh,0BBh,0B0h,0BBh	; +0xC1A
		db	 08h, 80h, 08h, 88h,0CBh,0C8h	; +0xC20
		db	0BCh,0C8h,0C8h, 88h, 88h, 88h	; +0xC26
		db	0EEh,0BAh,0BAh,0A3h,0C0h, 80h	; +0xC2C
		db	 88h, 88h, 88h, 88h, 88h, 88h	; +0xC32
		db	 03h,0B8h, 88h,0CBh,0FFh, 8Ch	; +0xC38
		db	 0Fh,0CBh,0C3h,0B8h, 88h,0BFh	; +0xC3E
		db	0CCh, 8Bh, 0Ch, 88h,0BBh,0F0h	; +0xC44
		db	 3Ch,0C8h, 88h, 08h, 08h, 88h	; +0xC4A
		db	 88h, 41h, 32h, 2Bh,0EBh,0EFh	; +0xC50
		db	0C2h, 3Bh, 0Ah, 82h, 20h, 0Ah	; +0xC56
		db	0EBh,0EBh,0F2h,0EBh,0EAh, 41h	; +0xC5C
		db	0F3h, 2Ah,0B3h,0BAh, 41h, 8Fh	; +0xC62
		db	0C2h,0A2h,0A2h, 2Ah, 42h,0A2h	; +0xC68
		db	 2Ah, 83h,0EAh,0A2h,0EAh,0BFh	; +0xC6E
		db	0EFh,0BEh, 3Ch, 11h,0FAh,0B2h	; +0xC74
		db	 2Bh,0BEh,0AEh,0A2h, 2Eh,0FCh	; +0xC7A
		db	 11h, 03h,0C3h,0B8h, 02h, 02h	; +0xC80
		db	 2Ah, 82h, 88h, 02h,0AEh,0ACh	; +0xC86
		db	0BCh, 0Bh,0EEh, 20h, 11h,0A8h	; +0xC8C
		db	 41h,0EFh,0CFh,0ABh,0AEh,0E0h	; +0xC92
		db	 8Fh, 42h,0B8h,0AEh, 41h, 8Fh	; +0xC98
		db	 11h, 88h, 42h,0A0h, 88h, 42h	; +0xC9E
		db	 8Ch,0C8h, 41h,0BAh,0A0h,0BBh	; +0xCA4
		db	0BEh,0C0h, 11h,0CCh,0BAh, 41h	; +0xCAA
		db	0FCh, 8Fh, 41h,0ABh,0C0h, 08h	; +0xCB0
		db	 80h, 3Ch, 2Fh,0C8h,0A2h,0EAh	; +0xCB6
		db	0A0h, 22h, 0Ah, 2Eh,0BBh,0C0h	; +0xCBC
		db	 2Bh,0F8h, 28h, 20h, 28h, 3Bh	; +0xCC2
		db	0AFh,0EEh, 2Ah, 3Fh,0ABh,0F2h	; +0xCC8
		db	 2Fh,0FFh, 0Fh,0AEh,0BAh, 8Fh	; +0xCCE
		db	 0Ah, 22h, 2Ah, 11h, 0Ah, 20h	; +0xCD4
		db	 2Ah, 2Ah,0A3h, 22h, 2Ah, 3Ah	; +0xCDA
		db	 41h, 3Fh,0EFh, 11h, 20h,0EEh	; +0xCE0
		db	 3Ah, 2Ah,0AEh, 22h, 2Ah, 3Fh	; +0xCE6
		db	 02h, 20h, 11h, 03h, 02h, 33h	; +0xCEC
		db	 2Ah, 3Eh,0A2h, 88h, 88h, 8Fh	; +0xCF2
		db	0BCh, 11h,0BCh, 11h, 88h, 11h	; +0xCF8
		db	 80h,0BBh, 8Fh,0F8h, 8Ch,0CBh	; +0xCFE
		db	 8Ch, 8Bh,0F0h, 11h, 0Fh,0ABh	; +0xD04
		db	 41h, 2Fh, 08h, 80h, 11h, 08h	; +0xD0A
		db	 88h, 88h, 12h, 8Bh, 88h, 88h	; +0xD10
		db	 8Ch, 88h, 8Ch,0B0h, 08h, 11h	; +0xD16
		db	0B8h,0B8h, 88h, 8Ch, 8Fh, 88h	; +0xD1C
		db	0BCh, 88h, 88h, 88h, 11h,0C8h	; +0xD22
		db	 8Bh, 88h, 8Bh,0C0h, 22h, 2Ah	; +0xD28
		db	 2Fh, 2Ch, 02h, 3Ch, 11h, 20h	; +0xD2E
		db	 02h, 0Ah,0E3h, 3Fh, 32h, 2Eh	; +0xD34
		db	 3Eh,0F2h,0FCh, 12h, 0Eh,0EBh	; +0xD3A
		db	0BAh, 3Ch, 11h, 02h, 2Ah, 22h	; +0xD40
		db	 22h, 22h, 02h, 20h, 02h, 22h	; +0xD46
		db	 2Ah, 2Eh,0E2h, 2Fh,0C0h, 02h	; +0xD4C
		db	 20h, 32h,0FAh, 22h, 22h, 2Eh	; +0xD52
		db	 2Ah,0EEh, 22h,0E2h, 2Ah, 20h	; +0xD58
		db	0E2h, 22h,0EAh, 22h, 32h, 88h	; +0xD5E
		db	 88h, 38h,0B0h, 08h,0FCh, 12h	; +0xD64
		db	 88h, 08h,0BCh,0FFh,0B8h, 88h	; +0xD6A
		db	0FFh, 8Bh, 13h, 03h,0EAh,0BAh	; +0xD70
		db	 3Ch, 11h, 88h, 8Fh,0CBh,0C8h	; +0xD76
		db	0F8h, 88h, 88h, 80h, 88h, 11h	; +0xD7C
		db	 8Ch,0B8h, 8Fh,0C0h, 88h, 88h	; +0xD82
		db	 3Ch,0F8h, 88h,0BFh,0B8h, 88h	; +0xD88
		db	0BBh, 88h,0C8h, 8Bh, 80h, 38h	; +0xD8E
		db	0FCh,0BCh, 88h,0B8h, 22h,0A2h	; +0xD94
		db	 30h, 30h, 22h,0F2h, 20h, 22h	; +0xD9A
		db	 20h, 22h,0E2h,0F3h,0E2h,0B3h	; +0xDA0
		db	 32h, 2Ch, 11h, 02h, 11h, 23h	; +0xDA6
		db	0BBh,0BAh,0FEh, 22h, 22h,0AEh	; +0xDAC
		db	0FFh, 23h, 22h,0A2h, 22h, 20h	; +0xDB2
		db	 11h,0A0h, 02h,0A2h, 33h, 22h	; +0xDB8
		db	 20h, 11h, 2Eh,0FEh, 22h, 2Fh	; +0xDBE
		db	0F2h,0A2h, 32h,0E2h,0EAh,0E2h	; +0xDC4
		db	 20h, 32h,0C3h,0A2h, 22h, 2Eh	; +0xDCA
		db	 88h, 88h,0CCh,0B0h, 88h,0B0h	; +0xDD0
		db	 11h, 80h, 11h,0BFh, 8Fh, 8Fh	; +0xDD6
		db	0C8h,0CCh,0CBh,0B0h, 13h, 0Bh	; +0xDDC
		db	0EFh,0ABh,0ECh, 88h, 8Bh,0CBh	; +0xDE2
		db	0BCh,0FCh, 8Bh, 88h, 88h, 88h	; +0xDE8
		db	 88h, 88h, 8Ah,0B8h,0BBh, 08h	; +0xDEE
		db	 11h, 88h, 8Ch,0CFh, 88h,0CFh	; +0xDF4
		db	0BCh,0CBh,0C8h,0CAh, 41h,0E8h	; +0xDFA
		db	 88h, 0Fh, 11h,0FBh, 88h, 8Bh	; +0xE00
		db	 22h, 20h,0E2h,0C0h, 23h,0F2h	; +0xE06
		db	 20h, 11h, 3Fh,0E2h, 32h, 23h	; +0xE0C
		db	 20h, 0Fh, 2Eh, 30h, 20h, 11h	; +0xE12
		db	 22h, 23h,0BFh, 41h,0EEh, 22h	; +0xE18
		db	 20h, 3Eh,0FEh,0E3h,0ECh, 02h	; +0xE1E
		db	 22h, 22h, 22h, 22h, 22h,0AEh	; +0xE24
		db	0E3h, 02h, 22h, 22h, 2Eh,0EFh	; +0xE2A
		db	0E3h, 23h,0ECh, 33h,0E2h, 3Ah	; +0xE30
		db	0AFh,0A2h, 22h, 0Fh, 11h, 0Fh	; +0xE36
		db	 22h, 23h, 88h, 88h,0C0h, 11h	; +0xE3C
		db	 8Ch, 0Ch,0C0h, 88h,0F8h, 8Bh	; +0xE42
		db	0C0h, 88h, 83h,0F0h, 0Ch,0C0h	; +0xE48
		db	 11h, 88h, 80h, 88h,0FBh,0EFh	; +0xE4E
		db	0ACh, 88h, 88h, 03h,0BFh, 8Ch	; +0xE54
		db	 13h, 88h, 88h, 88h, 82h,0B8h	; +0xE5A
		db	0C0h, 12h, 88h, 8Bh,0CFh,0C3h	; +0xE60
		db	 88h,0FCh,0CCh,0C0h,0BBh,0AEh	; +0xE66
		db	 88h, 80h, 80h, 11h, 0Ch, 11h	; +0xE6C
		db	 88h, 22h, 20h, 32h,0C2h, 2Fh	; +0xE72
		db	 20h, 3Eh, 03h, 22h,0FCh, 02h	; +0xE78
ckpd_raw_region_anchor_b		db	 22h			; data table (indexed access)
		db	0FEh, 20h, 0Eh,0C2h, 02h, 20h	; +0xE7F
		db	 02h, 22h,0C8h,0EFh,0AEh, 22h	; +0xE85
		db	 22h, 11h,0BEh, 30h, 22h, 20h	; +0xE8B
		db	 02h, 22h, 22h, 20h, 02h,0AEh	; +0xE91
		db	0E2h, 20h, 02h, 22h, 23h, 33h	; +0xE97
		db	0C3h, 22h,0EEh, 33h, 02h, 3Bh	; +0xE9D
		db	 41h,0A0h, 02h, 22h, 22h, 0Ch	; +0xEA3
		db	0C2h, 22h, 11h, 88h, 8Bh, 12h	; +0xEA9
		db	0FFh,0C8h, 0Fh, 3Fh,0B8h, 88h	; +0xEAF
		db	 3Fh, 11h,0A8h,0B8h,0C0h, 11h	; +0xEB5
		db	 88h, 88h, 11h,0FAh,0FAh,0B8h	; +0xEBB
		db	 12h, 88h,0ACh,0C0h, 11h, 88h	; +0xEC1
		db	 88h, 12h, 88h, 8Ah,0B3h, 11h	; +0xEC7
		db	 88h, 88h, 12h,0BBh,0CBh,0C0h	; +0xECD
		db	0FCh,0FBh, 88h, 0Ah, 41h, 88h	; +0xED3
		db	 88h, 12h, 03h,0C8h, 11h, 22h	; +0xED9
		db	 30h, 30h, 02h, 22h, 03h, 3Eh	; +0xEDF
		db	 2Eh,0E2h,0C0h, 03h,0E2h, 22h	; +0xEE5
		db	 20h,0C3h, 11h, 22h, 11h, 02h	; +0xEEB
		db	 22h,0FAh, 2Ah,0B2h, 22h, 22h	; +0xEF1
		db	 11h,0EEh,0E2h, 22h, 11h, 02h	; +0xEF7
		db	 22h, 22h, 11h, 02h,0AFh, 22h	; +0xEFD
		db	 11h, 02h, 22h, 22h, 33h,0CEh	; +0xF03
		db	 32h,0FEh,0C3h, 02h, 2Eh,0BAh	; +0xF09
		db	 11h, 02h, 22h, 22h, 03h, 0Fh	; +0xF0F
		db	 22h, 8Bh,0C8h,0B8h, 08h, 88h	; +0xF15
		db	 88h,0CBh, 8Fh, 8Bh, 88h,0BCh	; +0xF1B
		db	0C8h, 88h,0A8h,0CBh, 11h, 08h	; +0xF21
		db	 88h, 88h, 88h,0CAh, 2Ah,0B8h	; +0xF27
		db	 88h, 88h, 88h,0A8h, 88h, 88h	; +0xF2D
		db	 88h, 88h, 02h, 88h, 88h, 88h	; +0xF33
		db	0BBh, 88h, 88h, 88h, 88h, 88h	; +0xF39
		db	 8Fh, 8Ch,0B8h,0FBh,0CCh, 88h	; +0xF3F
		db	 8Ah,0BAh, 88h, 88h, 88h, 88h	; +0xF45
		db	 83h,0B0h,0C8h, 02h, 2Fh,0E0h	; +0xF4B
		db	 02h, 22h, 02h,0E3h, 2Eh, 03h	; +0xF51
		db	 22h,0E0h,0E2h, 22h,0A3h, 23h	; +0xF57
		db	 15h,0CCh,0C2h,0C0h, 02h,0A0h	; +0xF5D
		db	 11h, 22h,0C0h, 14h, 20h, 12h	; +0xF63
		db	0EBh, 12h, 02h,0E0h,0A0h, 0Ch	; +0xF69
		db	0CCh, 0Fh, 0Ch, 20h, 02h, 22h	; +0xF6F
		db	0BAh, 22h,0A0h, 11h, 08h, 80h	; +0xF75
		db	0F0h, 3Ch, 8Bh,0F8h,0C0h, 08h	; +0xF7B
		db	 88h, 08h,0B8h,0CCh, 8Ch, 8Bh	; +0xF81
		db	 80h,0F8h, 41h, 8Bh, 8Bh, 11h	; +0xF87
		db	 0Ah, 0Ah, 08h, 28h, 3Fh, 02h	; +0xF8D
		db	0F0h,0A0h, 11h, 88h, 3Ah, 80h	; +0xF93
		db	 2Ah, 08h, 20h, 11h, 02h, 11h	; +0xF99
		db	 20h,0FFh, 20h, 88h, 20h, 88h	; +0xF9F
		db	 22h, 0Fh, 32h, 20h,0BBh, 28h	; +0xFA5
		db	 88h, 0Ah,0BAh, 20h, 80h, 22h	; +0xFAB
		db	 22h, 20h,0C0h, 03h, 11h, 3Fh	; +0xFB1
		db	 11h,0A8h,0A2h, 0Ah,0B0h,0F0h	; +0xFB7
		db	 0Ch, 0Ch,0C0h, 30h, 41h, 83h	; +0xFBD
		db	 0Ch, 13h, 02h, 80h, 33h, 0Ah	; +0xFC3
		db	0B0h, 12h, 08h, 41h, 82h, 13h	; +0xFC9
		db	 22h, 11h, 22h, 11h,0CBh, 11h	; +0xFCF
		db	 82h, 08h, 80h, 20h, 03h,0F0h	; +0xFD5
		db	 88h, 3Ah, 80h, 08h, 82h,0E8h	; +0xFDB
		db	 02h, 02h, 13h,0C0h, 11h, 8Fh	; +0xFE1
		db	0C0h, 22h, 22h, 20h, 0Bh,0B8h	; +0xFE7
		db	0F8h, 8Ch, 8Ch,0C0h, 0Ch, 41h	; +0xFED
		db	 8Ch, 8Ch, 15h, 33h, 08h,0B0h	; +0xFF3
		db	 13h, 28h,0C0h, 15h, 02h, 20h	; +0xFF9
		db	0FBh, 15h, 03h,0F0h, 11h, 0Bh	; +0xFFF
		db	 80h, 11h, 0Ah,0E8h, 11h, 20h	; +0x1005
		db	 15h, 30h, 12h, 88h,0A0h, 2Bh	; +0x100B
		db	0B0h, 30h, 30h, 30h,0C0h, 03h	; +0x1011
		db	 08h, 0Ch, 0Ch, 15h, 3Ch,0CAh	; +0x1017
		db	0B0h, 13h, 2Ah, 80h, 14h, 02h	; +0x101D
		db	 12h,0CEh, 15h, 03h, 30h, 11h	; +0x1023
		db	 02h, 12h, 0Ah,0E8h, 17h,0B0h	; +0x1029
		db	 08h, 82h, 2Ah, 88h, 2Fh,0B8h	; +0x102F
		db	0B8h,0B8h,0BBh, 11h, 03h, 88h	; +0x1035
		db	0B8h,0B0h, 15h, 3Ch, 8Ah,0B0h	; +0x103B
		db	 13h, 2Ah, 18h,0FEh, 16h,0C0h	; +0x1041
		db	 11h, 02h, 12h, 0Ah,0E8h, 11h	; +0x1047
		db	 20h, 15h,0C0h, 11h, 28h,0A8h	; +0x104D
		db	 8Ah,0AEh,0CFh, 30h, 30h,0C2h	; +0x1053
		db	 11h, 03h, 0Bh, 33h,0C0h, 15h	; +0x1059
		db	 3Eh,0EAh,0C0h, 13h, 2Ah, 18h	; +0x105F
		db	0F2h, 16h,0C0h, 14h, 0Ah,0E8h	; +0x1065
		db	 17h,0C8h, 88h, 22h,0A2h, 8Ah	; +0x106B
		db	0BBh,0F0h,0F8h,0CBh, 8Ah, 11h	; +0x1071
		db	 03h, 8Bh, 8Ch, 16h, 3Bh,0E2h	; +0x1077
		db	0C0h, 13h, 3Ah, 18h,0CEh, 16h	; +0x107D
		db	0C0h, 14h, 0Ah,0E8h, 17h,0C0h	; +0x1083
		db	 41h, 82h, 41h, 2Bh,0EBh, 11h	; +0x1089
		db	 0Fh, 03h, 02h, 12h,0C3h, 0Ch	; +0x108F
		db	 16h, 3Bh,0B2h,0C0h, 13h, 2Bh	; +0x1095
		db	 18h,0CEh, 16h,0C0h, 14h, 0Ah	; +0x109B
		db	0A8h, 17h, 88h,0A2h, 22h,0A2h	; +0x10A1
		db	 2Eh,0ACh, 12h,0FCh,0A8h, 12h	; +0x10A7
		db	0CBh, 8Ch, 16h, 3Bh, 82h,0C0h	; +0x10AD
		db	 13h, 22h, 18h,0EEh, 1Bh, 02h	; +0x10B3
		db	0E8h, 17h, 2Ah, 28h, 0Ah, 88h	; +0x10B9
		db	0AEh,0F0h, 12h, 0Fh, 88h, 12h	; +0x10BF
		db	0C3h, 0Ch, 16h, 30h,0E2h,0C0h	; +0x10C5
		db	 13h, 2Ah, 17h, 03h,0B3h, 1Bh	; +0x10CB
		db	 02h,0EAh, 17h, 28h, 02h,0A2h	; +0x10D1
		db	 82h,0BBh, 13h, 03h, 28h, 12h	; +0x10D7
		db	0CCh, 0Ch, 16h, 3Eh, 20h,0B0h	; +0x10DD
		db	 13h,0FAh, 17h, 03h,0CBh, 1Bh	; +0x10E3
		db	 02h, 3Ah, 17h, 02h,0A8h, 11h	; +0x10E9
		db	 41h,0BBh, 13h, 03h, 12h, 03h	; +0x10EF
		db	 0Ch, 30h, 16h, 3Eh, 8Ch,0B0h	; +0x10F5
		db	 13h, 8Bh, 17h, 03h, 23h, 1Ch	; +0x10FB
		db	 41h, 17h, 82h, 41h,0A2h, 41h	; +0x1101
		db	0BFh, 14h,0A8h, 11h, 03h, 8Ch	; +0x1107
		db	0B0h, 16h, 3Ch, 8Ch,0B0h, 13h	; +0x110D
		db	0ABh, 17h, 03h, 23h, 1Bh, 02h	; +0x1113
		db	 32h, 17h, 22h,0BFh,0A8h, 41h	; +0x1119
		db	0ECh, 14h, 88h, 11h, 02h, 08h	; +0x111F
		db	 30h, 16h, 33h, 2Ch,0B0h, 13h	; +0x1125
		db	 8Ah, 17h, 03h, 23h, 1Ch, 88h	; +0x112B
		db	 80h, 16h, 8Bh,0C8h,0F2h,0ABh	; +0x1131
		db	0ECh, 14h,0B0h, 11h, 02h, 0Ah	; +0x1137
		db	0A0h, 16h, 32h, 2Ch,0B0h, 13h	; +0x113D
		db	0BBh, 17h, 03h, 23h, 1Bh, 02h	; +0x1143
		db	 02h, 17h, 2Ch, 11h, 38h,0ABh	; +0x1149
		db	0F0h, 13h, 02h, 28h, 11h, 02h	; +0x114F
		db	 28h,0A0h, 16h, 3Ah,0BAh,0B0h	; +0x1155
		db	 12h, 03h, 02h, 17h, 03h, 30h	; +0x115B
		db	0C0h, 1Ah, 08h, 80h, 80h, 16h	; +0x1161
		db	 2Ch, 11h, 0Ah, 2Bh,0B0h, 14h	; +0x1167
		db	 88h, 11h, 02h, 2Ah,0A0h, 16h	; +0x116D
		db	 3Eh,0BEh,0ACh, 12h, 02h, 30h	; +0x1173
		db	 80h, 16h, 0Ch, 80h,0C0h, 1Ah	; +0x1179
		db	 02h, 88h, 17h,0B0h, 11h, 08h	; +0x117F
		db	0AFh,0B0h, 13h, 08h, 28h, 11h	; +0x1185
		db	 03h, 2Ch, 8Ch, 16h, 0Eh,0BEh	; +0x118B
		db	0A8h, 12h, 02h, 8Ch, 80h, 16h	; +0x1191
		db	 0Fh, 80h,0C0h, 1Ah, 08h, 02h	; +0x1197
		db	 20h, 16h,0B0h, 11h, 0Eh, 2Fh	; +0x119D
		db	0B0h, 14h, 28h, 11h, 08h, 22h	; +0x11A3
		db	 88h, 16h, 0Ah,0ACh, 88h, 12h	; +0x11A9
		db	 08h, 20h, 20h, 16h, 02h, 8Ch	; +0x11AF
		db	 80h, 1Ah, 02h, 20h, 20h, 16h	; +0x11B5
		db	0B0h, 11h, 08h,0AFh,0C0h, 14h	; +0x11BB
		db	 08h, 11h, 0Ch, 08h, 28h, 16h	; +0x11C1
		db	 0Ah,0BAh, 28h, 13h, 82h, 17h	; +0x11C7
		db	 0Ah,0C8h, 80h, 1Ah, 28h, 02h	; +0x11CD
		db	 08h, 16h,0B0h, 11h, 02h, 2Eh	; +0x11D3
		db	0C0h, 13h, 08h, 02h, 12h, 0Ch	; +0x11D9
		db	 08h, 16h, 0Eh,0B8h, 88h, 12h	; +0x11DF
		db	 0Ah, 0Ah, 80h, 16h, 0Ch,0C8h	; +0x11E5
		db	0A0h, 1Ah, 28h, 20h, 82h, 16h	; +0x11EB
		db	0C0h, 11h, 08h,0AEh,0C0h, 13h	; +0x11F1
		db	 08h, 12h, 08h, 0Ch, 08h, 16h	; +0x11F7
		db	 0Eh, 3Ah, 28h, 12h, 02h, 11h	; +0x11FD
		db	 80h, 16h, 3Ah, 08h, 20h, 1Ah	; +0x1203
		db	 80h, 11h, 08h, 20h, 15h,0C0h	; +0x1209
		db	 11h, 22h, 2Eh,0C0h, 16h, 08h	; +0x120F
		db	 88h, 88h, 16h, 0Ah, 08h, 88h	; +0x1215
		db	 12h, 08h, 18h, 22h, 11h, 20h	; +0x121B
		db	 19h, 0Ah, 19h,0C0h, 11h, 28h	; +0x1221
		db	0BFh, 14h, 80h, 12h, 08h, 88h	; +0x1227
		db	 02h, 16h, 0Ah, 22h, 02h, 1Bh	; +0x122D
		db	 23h, 08h, 08h, 1Fh, 16h, 22h	; +0x1233
		db	 3Fh, 17h, 08h, 82h, 02h, 16h	; +0x1239
		db	 0Eh,0AEh, 82h, 1Bh,0E0h, 02h	; +0x123F
		db	 1Eh, 28h, 17h, 08h,0BBh, 19h	; +0x1245
		db	 80h, 80h, 15h, 08h, 41h, 02h	; +0x124B
		db	 1Bh,0A0h, 02h, 1Eh, 0Ah, 17h	; +0x1251
		db	 2Ah,0BFh, 17h, 02h, 02h, 20h	; +0x1257
		db	 80h, 15h, 0Eh, 2Eh, 80h, 80h	; +0x125D
		db	 19h, 03h, 80h, 11h, 80h, 1Dh	; +0x1263
		db	 02h, 17h, 0Ah,0FCh, 17h, 80h	; +0x1269
		db	 08h, 80h, 20h, 15h, 32h, 28h	; +0x126F
		db	 80h, 1Fh, 1Fh, 15h, 3Ah,0FCh	; +0x1275
		db	 16h, 0Ah, 08h, 02h, 08h, 0Ah	; +0x127B
		db	 15h, 28h, 28h, 11h, 80h, 1Fh	; +0x1281
		db	 1Fh, 14h, 32h,0FCh, 19h, 82h	; +0x1287
		db	 16h, 28h, 32h, 02h, 1Fh, 1Fh	; +0x128D
		db	 15h, 0Eh,0FCh, 1Fh, 11h,0E0h	; +0x1293
		db	0E8h, 80h, 88h, 1Fh, 1Fh, 14h	; +0x1299
		db	 0Ah,0BCh, 1Fh, 11h,0A0h, 28h	; +0x129F
		db	 11h, 20h, 1Fh, 1Fh, 14h, 0Ah	; +0x12A5
		db	0CCh, 1Fh, 03h, 11h, 82h, 1Fh	; +0x12AB
		db	 1Fh, 16h, 08h, 30h, 1Fh, 12h	; +0x12B1
		db	 02h, 1Fh, 1Fh, 16h, 08h,0B0h	; +0x12B7
		db	 1Fh, 12h, 08h, 1Fh, 1Fh, 17h	; +0x12BD
		db	 30h, 1Fh, 11h, 20h, 1Fh, 1Fh	; +0x12C3
		db	 18h, 30h, 00h, 4Bh, 80h, 2Ah	; +0x12C9
		db	 42h, 28h, 2Ah, 42h, 28h, 4Ah	; +0x12CF
		db	 8Ah, 45h,0A8h, 8Ah, 41h,0A8h	; +0x12D5
		db	 0Ah, 42h, 20h, 42h,0A2h,0A2h	; +0x12DB
		db	 49h,0A2h, 8Ah, 42h,0A8h, 8Ah	; +0x12E1
		db	0A8h, 0Ah, 2Ah, 42h, 82h, 41h	; +0x12E7
		db	0A8h,0A2h, 42h,0A8h, 8Ah, 45h	; +0x12ED
		db	0A8h,0A8h, 41h, 0Ah,0ABh, 2Ah	; +0x12F3
		db	 42h, 11h, 22h,0B0h, 03h,0A0h	; +0x12F9
		db	 42h,0A0h, 41h,0A8h, 8Ah, 43h	; +0x12FF
		db	 2Ah, 41h,0A2h, 20h, 8Ah, 42h	; +0x1305
		db	 0Ah, 2Ah, 11h, 41h,0CAh, 41h	; +0x130B
		db	 3Ch, 03h,0CFh, 02h, 03h,0C0h	; +0x1311
		db	 0Ah, 42h, 2Ah,0A2h, 80h,0A8h	; +0x1317
		db	 41h,0A0h, 41h,0A2h, 20h, 3Fh	; +0x131D
		db	 22h, 2Ah,0A8h,0F0h,0A0h, 80h	; +0x1323
		db	 2Ah, 8Ah,0ACh, 11h, 20h, 32h	; +0x1329
		db	 80h, 20h,0C8h, 0Fh, 22h, 2Ah	; +0x132F
		db	 2Ah,0A2h, 20h,0CAh, 22h, 88h	; +0x1335
		db	0A8h, 88h,0CFh, 11h, 0Ch, 8Ah	; +0x133B
		db	 80h, 0Ch, 11h, 20h,0C8h, 41h	; +0x1341
		db	 80h, 2Ah, 41h, 02h, 20h,0A0h	; +0x1347
		db	0A2h, 20h, 0Fh, 08h, 8Ah,0A8h	; +0x134D
		db	 41h, 0Ch, 22h, 88h, 88h,0F0h	; +0x1353
		db	 11h, 41h, 83h, 0Bh, 02h,0ABh	; +0x1359
		db	0EAh, 41h, 32h, 2Ah, 11h, 03h	; +0x135F
		db	 20h, 41h, 80h, 8Ah, 41h, 88h	; +0x1365
		db	 80h, 0Fh,0C8h,0A8h, 8Ah,0A3h	; +0x136B
		db	0C8h,0A2h, 80h, 02h, 43h,0C2h	; +0x1371
		db	 43h, 2Ah, 30h,0A8h, 42h, 32h	; +0x1377
		db	 22h,0A2h, 8Ah, 32h, 41h, 22h	; +0x137D
		db	 11h, 32h, 2Ah,0A8h, 28h, 80h	; +0x1383
		db	0A0h,0C2h, 42h, 8Ah, 41h, 8Ah	; +0x1389
		db	 41h, 8Ah, 2Ah, 88h, 0Ch, 43h	; +0x138F
		db	0A8h,0FCh,0E2h, 8Ch,0A8h,0F2h	; +0x1395
		db	 22h, 88h, 83h, 0Ah, 82h, 8Ah	; +0x139B
		db	 22h, 22h, 41h,0A0h,0A8h, 22h	; +0x13A1
		db	 82h,0A8h, 88h, 41h,0C2h, 22h	; +0x13A7
		db	0ACh, 2Ah, 43h,0AFh, 38h, 2Ah	; +0x13AD
		db	 41h,0A3h,0C8h, 88h,0ABh, 28h	; +0x13B3
		db	0A3h, 22h, 32h, 8Ah, 41h, 0Ah	; +0x13B9
		db	 83h, 0Ah, 28h,0F2h, 22h, 2Ah	; +0x13BF
		db	0C0h,0B2h,0A3h,0EAh, 44h,0F2h	; +0x13C5
		db	 41h, 8Ah, 41h,0A3h,0F0h, 22h	; +0x13CB
		db	0C8h,0F8h, 8Fh, 0Eh, 38h, 8Ah	; +0x13D1
		db	0A0h, 2Ah,0F2h, 2Ah,0A3h, 32h	; +0x13D7
		db	 28h,0A0h,0CAh,0ABh, 2Ah, 44h	; +0x13DD
		db	0BAh, 45h,0F0h,0C2h, 42h,0B0h	; +0x13E3
		db	 20h,0E2h, 82h, 41h, 8Ch, 42h	; +0x13E9
		db	0BCh,0A2h,0A8h, 2Ah,0A8h,0EAh	; +0x13EF
		db	 45h,0A2h, 45h,0B2h, 42h,0ACh	; +0x13F5
		db	 41h, 32h, 2Ah, 41h,0A2h,0A0h	; +0x13FB
		db	 41h,0ACh, 22h, 43h,0E8h, 2Ah	; +0x1401
		db	 4Ah, 8Ah, 44h, 8Ch, 45h,0ABh	; +0x1407
		db	0CAh, 43h, 2Ah, 4Fh, 41h,0A2h	; +0x140D
		db	 46h, 2Ah, 41h, 00h, 42h,0EAh	; +0x1413
		db	0BAh, 47h, 80h, 3Eh,0BAh, 41h	; +0x1419
		db	 28h, 2Ah, 41h,0ABh, 3Ch, 41h	; +0x141F
		db	0FEh, 49h,0EAh,0EAh, 43h,0ABh	; +0x1425
		db	 42h,0A8h, 0Fh,0AEh, 41h, 20h	; +0x142B
		db	 42h,0B3h,0E2h, 41h,0ABh,0FAh	; +0x1431
		db	 46h,0AEh,0ABh,0AFh, 41h,0ABh	; +0x1437
		db	0BAh,0ABh,0FAh,0EAh, 42h, 83h	; +0x143D
		db	0EEh,0A8h,0A2h, 42h,0ECh, 8Ah	; +0x1443
		db	 42h,0AFh, 42h,0ABh,0ABh, 41h	; +0x1449
		db	0FAh,0A8h,0ABh,0BAh, 41h,0FFh	; +0x144F
		db	0EEh, 8Ch, 0Ch,0AFh, 42h,0A0h	; +0x1455
		db	0FBh,0A8h, 8Ah, 42h,0EEh, 2Ah	; +0x145B
		db	 41h,0AEh,0EFh,0BAh, 42h,0FAh	; +0x1461
		db	0EAh, 0Fh, 41h, 0Ah,0FAh,0C3h	; +0x1467
		db	 11h, 30h,0C2h, 11h, 30h,0FAh	; +0x146D
		db	 42h, 3Bh,0A2h, 8Fh,0ABh,0ABh	; +0x1473
		db	0B0h, 41h,0AEh,0EFh,0C0h,0EEh	; +0x1479
		db	0EAh,0ABh, 0Fh,0AFh, 80h,0EAh	; +0x147F
		db	 41h,0F3h, 11h, 20h, 0Eh, 80h	; +0x1485
		db	 20h, 08h, 11h,0EEh,0EAh,0EFh	; +0x148B
		db	0A2h, 20h, 3Ah,0EEh, 88h,0ABh	; +0x1491
		db	0BBh, 30h, 11h, 33h,0BAh,0BCh	; +0x1497
		db	 03h,0F0h, 20h, 3Bh,0ABh,0C0h	; +0x149D
		db	 2Ah, 41h, 02h, 20h,0A0h,0A2h	; +0x14A3
		db	 20h, 30h,0FBh,0BEh,0A8h, 41h	; +0x14A9
		db	 03h,0EEh, 8Bh,0BBh, 0Ch, 11h	; +0x14AF
		db	 41h, 80h,0F8h,0C2h,0A8h, 2Ah	; +0x14B5
		db	 41h, 0Eh,0EBh, 11h, 3Ch,0EFh	; +0x14BB
		db	 41h, 80h, 8Ah, 41h, 88h, 80h	; +0x14C1
		db	 30h, 3Bh,0A8h,0BBh,0E0h, 3Bh	; +0x14C7
		db	0AEh,0BCh, 02h, 43h, 3Eh, 43h	; +0x14CD
		db	0EAh, 0Fh,0ACh, 42h,0CEh,0EEh	; +0x14D3
		db	0A2h, 8Ah,0CEh, 41h, 22h, 11h	; +0x14D9
		db	 0Eh,0EAh,0FCh, 2Bh, 8Fh,0AFh	; +0x14DF
		db	 02h, 42h,0BAh, 41h,0BAh, 41h	; +0x14E5
		db	0BAh,0EAh,0BBh, 03h,0BEh, 42h	; +0x14EB
		db	0ABh, 03h, 2Eh,0B3h,0ABh, 0Eh	; +0x14F1
		db	0EEh, 88h, 80h,0FAh,0C2h,0BAh	; +0x14F7
		db	0EEh,0EEh, 41h,0AFh,0ABh,0EEh	; +0x14FD
		db	0BEh,0ABh,0BBh, 41h, 3Eh,0EEh	; +0x1503
		db	0A3h,0FAh, 43h,0A0h,0CBh,0EAh	; +0x1509
		db	0EAh,0ACh, 3Bh,0BBh,0A8h,0E8h	; +0x150F
		db	0ACh,0EEh,0CEh,0BAh, 41h,0FAh	; +0x1515
		db	0BCh,0FAh,0EBh, 0Eh,0EEh,0EAh	; +0x151B
		db	 3Fh, 8Eh,0ACh, 3Ah,0ABh,0EBh	; +0x1521
		db	 42h, 0Eh, 41h,0EEh, 41h,0ACh	; +0x1527
		db	 0Fh,0EEh, 38h, 0Bh,0B0h,0F2h	; +0x152D
		db	0CBh,0BAh,0AFh,0EAh, 0Eh,0EAh	; +0x1533
		db	0ACh,0CEh,0EBh,0AFh, 3Ah,0A8h	; +0x1539
		db	0FAh, 41h,0BEh,0EBh, 41h, 8Ah	; +0x153F
		db	0BEh,0BAh, 43h, 0Fh, 32h, 42h	; +0x1545
		db	 8Fh,0EFh, 2Eh,0BEh, 41h,0B3h	; +0x154B
		db	 42h, 83h,0AEh,0ABh,0EAh,0ABh	; +0x1551
		db	 3Ah, 41h,0ABh,0FEh, 48h, 82h	; +0x1557
		db	 42h,0A3h, 41h,0CEh,0EAh, 41h	; +0x155D
		db	0AEh, 42h,0A3h,0EEh, 43h, 2Ah	; +0x1563
		db	 42h,0BAh, 44h,0EEh, 43h,0BAh	; +0x1569
		db	 41h,0BEh, 42h,0B3h, 43h,0AEh	; +0x156F
		db	 41h,0A8h, 3Ah, 43h,0EBh, 47h	; +0x1575
		db	0BAh, 45h,0AEh, 42h,0AEh, 46h	; +0x157B
		db	0EAh, 41h, 00h,0FFh, 50h, 00h	; +0x1581
		db	 0Fh,0FDh,0D4h, 00h, 00h, 35h	; +0x1587
		db	 43h, 8Ah,0BFh,0FDh, 40h, 7Fh	; +0x158D
		db	0FFh,0F5h, 50h, 00h, 0Fh,0FDh	; +0x1593
		db	 50h, 00h, 0Fh,0F5h, 40h, 00h	; +0x1599
		db	 00h,0FFh,0F5h,0DFh,0FFh,0FFh	; +0x159F
		db	0FFh, 57h,0FFh,0FFh,0FFh, 55h	; +0x15A5
		db	0B9h,0DBh,0FFh,0FFh,0F7h,0FFh	; +0x15AB
		db	 77h, 5Fh,0FFh,0FFh,0D5h,0FDh	; +0x15B1
		db	 7Fh,0FFh, 75h, 5Dh,0FFh,0FFh	; +0x15B7
		db	0FFh,0D5h,0FFh,0FFh,0FFh, 5Fh	; +0x15BD
		db	0FFh,0DFh,0FFh,0FFh,0FDh, 7Fh	; +0x15C3
		db	0FFh,0FFh,0FFh,0FFh,0DDh, 5Fh	; +0x15C9
		db	0FDh, 55h,0FFh,0FDh,0FFh,0FFh	; +0x15CF
		db	0D7h,0FFh,0FFh,0FFh,0FFh, 55h	; +0x15D5
		db	0FFh,0FFh,0FFh,0F5h,0FFh,0F5h	; +0x15DB
		db	0FFh,0FFh, 77h,0DFh,0FFh,0DDh	; +0x15E1
		db	0D7h,0FFh, 75h,0FFh, 57h,0FFh	; +0x15E7
		db	0FFh,0FDh,0F7h,0FFh,0F5h, 7Fh	; +0x15ED
		db	0FFh,0FDh, 55h, 5Fh,0FDh,0DDh	; +0x15F3
		db	 5Fh,0FFh,0D7h,0FFh, 5Fh,0FFh	; +0x15F9
		db	0DDh, 7Fh,0FFh, 75h, 57h,0FFh	; +0x15FF
		db	 57h,0F5h, 7Fh,0FFh,0FFh,0FDh	; +0x1605
		db	0FFh,0DFh,0F7h, 5Fh,0F5h, 55h	; +0x160B
		db	0FFh,0FFh, 77h, 57h,0FFh,0FFh	; +0x1611
		db	0D7h,0FFh, 57h,0FFh, 57h,0FFh	; +0x1617
		db	0FDh, 55h, 7Fh,0D5h, 7Fh,0D7h	; +0x161D
		db	0FFh,0FFh,0FFh,0FDh,0FDh,0DFh	; +0x1623
		db	0FDh, 5Fh,0F5h,0FFh,0FDh,0D5h	; +0x1629
		db	 57h,0FFh,0FDh,0DDh, 5Fh,0F7h	; +0x162F
		db	 5Fh,0D5h, 7Fh,0FFh, 75h,0FFh	; +0x1635
		db	0FDh, 57h,0FFh, 5Fh,0FFh,0FFh	; +0x163B
		db	 5Fh,0F7h,0FFh,0FFh, 77h, 5Fh	; +0x1641
		db	 57h, 77h,0D5h, 7Fh,0FFh, 77h	; +0x1647
		db	 77h, 75h,0FDh,0DDh,0FDh,0DFh	; +0x164D
		db	0FDh,0DDh, 0Fh,0DDh, 55h,0FFh	; +0x1653
		db	 75h, 7Dh,0FDh,0D7h,0FDh,0D3h	; +0x1659
		db	0DDh,0FDh,0DCh, 3Dh, 7Fh, 55h	; +0x165F
		db	0FFh,0D5h, 55h, 55h, 55h, 4Fh	; +0x1665
		db	 55h, 53h, 55h,0F5h, 55h, 50h	; +0x166B
		db	0F5h, 43h,0FFh, 55h, 03h,0D5h	; +0x1671
		db	0D7h,0FDh, 55h, 0Dh, 53h, 75h	; +0x1677
		db	 43h,0D4h,0D5h,0FFh, 55h, 55h	; +0x167D
		db	 50h, 55h, 54h, 35h, 55h, 4Dh	; +0x1683
		db	 53h,0D5h, 55h, 4Fh, 54h, 3Dh	; +0x1689
		db	 55h, 40h,0FDh, 54h,0FDh, 55h	; +0x168F
		db	 40h,0F5h, 43h, 35h, 3Dh, 53h	; +0x1695
		db	 54h, 55h, 55h, 55h, 0Fh,0D5h	; +0x169B
		db	 53h,0D5h, 55h, 4Dh, 4Dh, 35h	; +0x16A1
		db	 55h, 35h, 53h,0D5h, 40h,0FFh	; +0x16A7
		db	 55h, 50h,0D5h, 50h, 3Fh, 54h	; +0x16AD
		db	 3Ch,0D4h,0D5h, 4Dh, 53h, 55h	; +0x16B3
		db	 55h, 53h,0F5h, 35h, 4Dh, 55h	; +0x16B9
		db	 55h, 4Dh, 35h, 4Dh, 54h,0D5h	; +0x16BF
		db	 4Dh, 50h,0FFh, 55h, 55h, 4Fh	; +0x16C5
		db	 55h, 0Fh,0D5h, 53h,0C3h, 53h	; +0x16CB
		db	 55h, 4Dh, 53h, 55h, 54h, 3Dh	; +0x16D1
		db	 55h, 35h, 4Dh, 55h, 55h, 75h	; +0x16D7
		db	 35h, 4Dh, 54h,0D5h, 35h, 4Fh	; +0x16DD
		db	 55h, 55h, 54h, 0Dh, 54h,0F5h	; +0x16E3
		db	 55h, 4Ch, 3Dh, 53h, 55h, 35h	; +0x16E9
		db	 4Dh, 55h, 03h,0D5h, 54h,0D5h	; +0x16EF
		db	 35h, 55h, 55h, 34h,0D5h, 35h	; +0x16F5
		db	 53h, 55h, 35h, 35h, 55h, 55h	; +0x16FB
		db	 0Fh,0FDh, 53h, 55h, 55h, 33h	; +0x1701
		db	0D5h, 4Dh, 55h, 35h, 4Dh, 00h	; +0x1707
		db	0FDh, 11h, 13h, 11h, 31h, 11h	; +0x170D
		db	 11h, 30h,0D1h, 31h, 13h, 10h	; +0x1713
		db	0D0h,0D1h, 11h, 13h,0F1h, 31h	; +0x1719
		db	 0Dh, 11h, 10h,0CDh, 11h, 0Dh	; +0x171F
		db	 11h, 31h, 13h,0FFh, 44h, 44h	; +0x1725
		db	 4Ch, 44h, 34h, 44h, 44h, 34h	; +0x172B
		db	0C4h, 34h, 43h, 44h,0C4h,0C4h	; +0x1731
		db	 44h, 3Ch, 44h,0C4h, 4Ch, 44h	; +0x1737
		db	 43h, 34h, 44h, 4Ch, 44h, 34h	; +0x173D
		db	 44h, 00h, 50h, 00h, 00h, 01h	; +0x1743
		db	 14h, 00h, 00h, 05h, 40h, 0Ah	; +0x1749
		db	 80h, 85h, 40h, 40h, 00h, 05h	; +0x174F
		db	 50h, 00h, 00h, 01h, 50h, 00h	; +0x1755
		db	 00h, 05h, 40h, 00h, 00h, 02h	; +0x175B
		db	 25h, 10h, 00h, 20h, 88h, 54h	; +0x1761
		db	 00h, 02h, 00h, 54h, 29h, 18h	; +0x1767
		db	 00h, 02h, 06h, 22h, 64h, 50h	; +0x176D
		db	 0Ah,0AAh, 85h, 01h, 4Ah, 2Ah	; +0x1773
		db	 45h, 51h, 00h, 08h, 88h, 14h	; +0x1779
		db	 0Ah, 00h, 0Ah, 50h, 20h, 90h	; +0x177F
		db	 22h,0A8h, 01h, 50h, 20h,0A8h	; +0x1785
		db	 00h, 8Ah, 99h, 00h,0A9h, 40h	; +0x178B
		db	 80h, 28h, 22h, 8Ah, 94h, 2Ah	; +0x1791
		db	0A2h, 22h,0AAh, 50h, 0Ah,0A8h	; +0x1797
		db	 00h,0A5h, 02h, 25h, 08h,0AAh	; +0x179D
		db	 66h,0C0h, 82h, 99h, 90h, 2Ah	; +0x17A3
		db	 64h, 0Ah, 50h, 00h, 2Ah,0A8h	; +0x17A9
		db	 20h, 8Ah,0A5h, 0Ah,0A8h,0A9h	; +0x17AF
		db	 11h, 00h, 28h, 89h, 02h, 2Ah	; +0x17B5
		db	 94h, 0Ah, 52h,0AAh, 99h, 02h	; +0x17BB
		db	 2Ah, 65h, 50h, 8Ah, 50h,0A5h	; +0x17C1
		db	 02h,0AAh,0AAh,0A8h, 28h, 82h	; +0x17C7
		db	0A6h, 42h,0A5h, 10h, 00h, 0Ah	; +0x17CD
		db	 22h, 14h, 08h,0AAh, 90h, 2Ah	; +0x17D3
		db	 10h,0AAh, 50h, 08h,0A9h, 44h	; +0x17D9
		db	 02h, 95h, 02h, 90h, 2Ah, 80h	; +0x17DF
		db	 0Ah,0A8h, 28h, 02h,0A9h, 52h	; +0x17E5
		db	0A4h, 00h,0A8h, 84h, 50h, 00h	; +0x17EB
		db	 28h, 89h, 42h,0A2h, 02h, 94h	; +0x17F1
		db	 02h,0AAh, 24h, 00h, 29h, 40h	; +0x17F7
		db	 2Ah, 42h,0A8h, 2Ah, 02h,0A0h	; +0x17FD
		db	0AAh, 22h, 22h, 42h, 10h, 22h	; +0x1803
		db	 80h, 40h, 00h, 02h, 22h, 20h	; +0x1809
		db	 08h, 88h, 08h, 80h,0A8h, 88h	; +0x180F
		db	 00h, 88h, 50h, 02h, 21h, 08h	; +0x1815
		db	 80h, 80h, 88h, 80h, 88h, 20h	; +0x181B
		db	 88h, 08h, 02h, 00h, 88h, 80h	; +0x1821
		db	 00h, 00h, 00h, 0Ah, 00h, 00h	; +0x1827
		db	 00h, 00h, 00h, 00h,0A0h, 00h	; +0x182D
		db	 82h, 00h, 02h, 80h, 02h, 28h	; +0x1833
		db	 00h, 08h, 00h, 20h, 02h, 80h	; +0x1839
		db	 80h, 8Ah, 00h, 00h, 00h, 00h	; +0x183F
		db	 00h, 00h, 00h, 08h, 02h, 80h	; +0x1845
		db	 00h, 02h, 00h, 08h, 00h, 00h	; +0x184B
		db	 88h, 00h,0A8h, 00h, 00h, 80h	; +0x1851
		db	 02h, 20h, 08h, 02h, 00h, 00h	; +0x1857
		db	 00h, 00h, 08h, 80h, 00h, 80h	; +0x185D
		db	 00h, 00h, 00h, 20h, 00h, 00h	; +0x1863
		db	 00h, 80h, 00h, 82h, 00h, 00h	; +0x1869
		db	 80h, 00h, 02h, 00h, 08h, 80h	; +0x186F
		db	 00h, 00h, 00h, 00h, 00h, 00h	; +0x1875
		db	0A0h, 20h, 00h, 00h, 00h, 08h	; +0x187B
		db	 20h, 08h, 00h, 00h, 00h, 00h	; +0x1881
		db	 0Ah, 00h, 00h, 00h, 00h, 08h	; +0x1887
		db	 80h, 00h, 82h, 00h, 00h, 08h	; +0x188D
		db	 02h, 00h, 00h, 28h, 00h, 20h	; +0x1893
		db	 08h, 00h, 00h, 00h, 00h, 00h	; +0x1899
		db	 00h, 80h, 00h, 02h, 00h, 00h	; +0x189F
		db	 00h, 00h, 00h, 80h, 00h, 08h	; +0x18A5
		db	 08h, 02h, 00h, 00h, 00h, 00h	; +0x18AB
		db	 00h, 80h, 00h, 80h, 00h, 00h	; +0x18B1
		db	 00h, 00h, 00h, 00h, 02h, 00h	; +0x18B7
		db	 20h, 00h, 00h, 00h, 00h, 88h	; +0x18BD
		db	 00h, 00h, 00h, 00h, 80h, 00h	; +0x18C3
		db	 00h, 00h, 08h, 00h, 88h, 00h	; +0x18C9
		db	 00h, 00h, 00h, 00h, 00h, 20h	; +0x18CF
		db	 00h, 00h, 00h, 00h, 00h, 00h	; +0x18D5
		db	 00h, 02h, 20h, 20h, 00h, 00h	; +0x18DB
		db	 00h, 00h, 00h, 00h, 00h, 20h	; +0x18E1
		db	 02h, 82h, 00h, 00h, 08h, 00h	; +0x18E7
		db	 20h, 00h, 00h, 20h, 80h, 20h	; +0x18ED
		db	 00h, 00h, 80h, 80h, 00h, 08h	; +0x18F3
		db	 00h, 80h, 08h, 00h, 02h, 20h	; +0x18F9
		db	 00h, 08h, 00h, 20h, 00h	; +0x18FF

seg_a		ends

		end	start
