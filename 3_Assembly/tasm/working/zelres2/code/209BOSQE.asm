
PAGE  59,132

;==========================================================================
;
;  209BOSQE.BIN - Boss Sprite Renderer (zelres2 chunk 10)
;
;  Renders a large multi-frame boss sprite to EGA (0A000h) and CGA (0B800h)
;  framebuffers. The module contains two dispatchers and nine renderer
;  variants, all driven by the mode byte at cs:bos_mode.
;
;  Entry / setup:
;    bos_render_main         - far entry: zero work RAM, RLE-unpack boss
;                              gfx from bos_gfx_hdr / bos_gfx_src_b / ...
;                              into a +1000h segment, then call
;                              render_dispatch_2 and bos_frame_dispatch.
;
;  Dispatchers:
;    bos_frame_dispatch      - jmp ds:[bos_anim_tbl + 2*bos_mode]
;                              (table in game DS, selects frame_handler_a..e)
;    render_dispatch_2       - jmp cs:[36A5h + 2*bos_mode]
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
;                              decode via nibble_decode_inner.
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
;    nibble_decode_inner / _2 - inner 4/2-iteration nibble-pair decode loop.
;
;  The second half of the file (from file offset ~0x5D4 to end) is packed
;  sprite bitmap pixel data, color LUTs (referenced by bos_color_lut_a..d
;  at CS 3497h/3654h/3753h/38D0h = file+1497h/1654h/1753h/18D0h) and the
;  CS-relative dispatch table at 36A5h (file+16A5h). Sourcer misidentifies
;  many bytes as x86 code because the pixel bytes form valid instruction
;  patterns; the entire region is kept as raw db with data_10..data_22
;  labels preserved for the few cross-references from the real code above.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- External data references (game DS segment; accessed via ds:) ---
bos_src_col_a	equ	4F25h			;* sprite source column A (hi-nibble)
bos_src_col_b	equ	50E5h			;* sprite source column B (lo-nibble)
cga_wrap_c	equ	0A05Ah			;* CGA/planar wrap offset C
bos_var_25e	equ	2022h			;* boss state var 25 (ds-relative)
bos_var_26e	equ	2208h			;* boss state var 26
bos_var_27e	equ	2222h			;* boss state var 27
bos_var_28e	equ	2A11h			;* boss state var 28
bos_var_29e	equ	2A42h			;* boss state var 29
bos_mode	equ	3388h			;* current boss render mode byte (CS-relative)
bos_anim_tbl	equ	3395h			;* animation frame dispatch table (word array)
bos_color_lut_a	equ	3497h			;* EGA color LUT A (16 bytes)
bos_color_lut_b	equ	3654h			;* EGA color LUT B
bos_var_34e	equ	3694h			;* render state var 34
bos_color_lut_c	equ	3753h			;* EGA color LUT C
bos_color_lut_d	equ	38D0h			;* CGA color LUT D
bos_gfx_hdr	equ	38E0h			;* boss sprite graphics header
bos_var_38e	equ	3F03h			;* boss var 38
bos_var_39e	equ	3FE8h			;* boss var 39
bos_var_40e	equ	410Ah			;* boss var 40
bos_var_41e	equ	413Bh			;* boss var 41
bos_var_42e	equ	41A0h			;* boss var 42
bos_gfx_src_b	equ	426Ah			;* boss gfx source B
bos_var_44e	equ	43A8h			;* boss var 44
bos_src_d	equ	4C6Dh			;* sprite source D
bos_src_e	equ	4DB8h			;* sprite source E
bos_src_f	equ	4F25h			;* sprite source F (= bos_src_col_a)
bos_src_g	equ	50E5h			;* sprite source G (= bos_src_col_b)
bos_dst_vga	equ	53C1h			;* VGA destination offset
bos_limit_6000	equ	6000h			;* wrap boundary (6000h)
bos_var_51e	equ	8041h			;* boss var 51
bos_limit_wrap	equ	80A0h			;* wrap delta 80A0h
bos_var_53e	equ	8808h			;* boss var 53
bos_var_54e	equ	8A28h			;* boss var 54
cga_wrap_55e	equ	0A05Ah			;* CGA wrap 55 (= cga_wrap_c)
bos_var_56e	equ	0A202h			;* boss var 56
bos_var_57e	equ	0A211h			;* boss var 57
bos_var_58e	equ	0A841h			;* boss var 58
bos_var_59e	equ	0A88Ah			;* boss var 59
bos_var_60e	equ	0AB41h			;* boss var 60
bos_var_61e	equ	0BA80h			;* boss var 61
bos_var_62e	equ	0BAEAh			;* boss var 62
bos_var_63e	equ	0C003h			;* boss var 63
bos_wrap_c050	equ	0C050h			;* wrap delta C050h
bos_var_65e	equ	0FA41h			;* boss var 65
bos_dst_zero	equ	0			;* zero offset (for clear loop)

; --- Internal (CS-relative) table offsets, within this binary ---
rle_src_46c	equ	46Ch			; RLE-decoded sprite dest A (used by ega mode a)
rle_dst_488	equ	488h			; EGA row dest offset (init = 0488h)
cga_src_11b0	equ	11B0h			; CGA mode-a source offset
cga_dst_1220	equ	1220h			; CGA mode-a destination offset
cga_dst_2c6c	equ	2C6Ch			; CGA mode-b destination offset
cga_src_23c	equ	23Ch			; CGA mode-b source offset (= 0x23C)
vga_dst_163c	equ	163Ch			; VGA/EGA dest offset 163Ch
vga_dst_41f8	equ	41F8h			; VGA dest 41F8h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

bos_render_main		proc	far

start:
		movsw				; Mov [si] to es:[di]
		pop	ds
		add	[bx+si],al
		mov	cs:bos_mode,al

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
		mov	di,offset data_14
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
		call	render_dispatch_2
		pop	ds
		mov	byte ptr ds:bos_var_34e,1Ch
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
		call	render_dispatch_2
		pop	ds
		call	bos_frame_dispatch
		retf				; Return far
		db	0

bos_render_main		endp

bos_frame_dispatch		proc	near
		xor	bx,bx			; Zero register
		mov	bl,ds:bos_mode
		add	bx,bx
		jmp	word ptr ds:bos_anim_tbl[bx]	;*

bos_frame_dispatch		endp

; --- Frame handler A: EGA render with Map Mask + Bit Mask sequence ---
; Dispatched via ds:bos_anim_tbl (game-DS resident table). First 5 bytes
; ('mov ax,data_21 / xor al,12h / xor al,0A7h / xor al,48h / xor ax,35C2h')
; are a decoy/NOP-equivalent pattern that sets AX=0 for the subsequent setup.

frame_handler_a:
		mov	ax,data_21
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
						mov	al,ds:bos_src_f[si]
						mov	es:[di],al
						mov	es:[di+1Ch],al
						mov	al,4
						out	dx,al			; port 3C5h, EGA sequencr func
						mov	al,ds:bos_src_g[si]
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
						mov	ah,ds:bos_src_g[si]
						mov	al,ds:bos_src_f[si]
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
						or	dl,ds:bos_color_lut_a[bx]
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
		db	 00h, 02h, 03h, 01h, 00h, 03h
		db	 02h, 01h, 00h, 02h, 03h, 01h
		db	 00h, 02h, 03h, 01h
; --- Frame handler C entry (falls through to cga_copy_loop) ---

frame_handler_c:
		db	 1Eh			    ; push ds
		db	 0B8h, 00h,0B0h		    ; mov ax,0B000h
		db	 8Eh,0C0h		    ; mov es,ax
		db	 8Eh,0D8h		    ; mov ds,ax
		db	 0BEh,0FDh, 04h		    ; mov si,04FDh
		db	 0B4h, 10h		    ; mov ah,10h

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
						mov	ah,ds:bos_src_col_b[si]
						mov	al,ds:bos_src_col_a[si]
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
						or	dl,ds:bos_color_lut_a[bx]
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
						mov	dl,ds:bos_src_f[si]
						mov	dh,ds:bos_src_g[si]
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
; then decodes 16x28 into CGA at 0x55F8 through nibble_decode_inner + bos_color_lut_b.

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
						mov	dh,ds:bos_src_g[si]
						mov	dl,ds:bos_src_f[si]
						call	nibble_decode_inner
						mov	es:[di+38h],al
						stosb				; Store al to es:[di]
						call	nibble_decode_inner
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

nibble_decode_inner		proc	near
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
				or	al,ds:bos_color_lut_b[bx]
				loop	nibble_decode_step		; Loop if cx > 0

		retn

nibble_decode_inner		endp

		db	 00h, 04h, 03h, 02h, 04h, 0Ch
		db	 05h, 06h, 03h, 05h, 0Bh, 0Ah
		db	 02h, 06h, 0Ah, 0Eh

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

		db	38h

render_dispatch_2		proc	near
		xor	ax,ax			; Zero register
		mov	al,cs:bos_mode
		add	ax,ax
		add	ax,36A5h
		mov	di,ax
		jmp	word ptr cs:[di]	;*

render_dispatch_2		endp

; --- Mode handler F: dispatch stub and prologue bytes ---
; These bytes are reached via render_dispatch_2's 'jmp [cs:36A5h + 2*bos_mode]'.
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
		db	0F3h, 37h, 51h, 38h,0B8h, 50h
		db	 00h,0F6h,0E3h, 8Ah,0DFh, 32h
		db	0FFh, 03h,0C3h, 8Bh,0F8h,0B8h
		db	 00h,0A0h, 8Eh,0C0h,0BAh,0C4h
		db	 03h,0B0h, 02h,0EEh, 42h, 8Bh
		db	0D9h

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
						or	dl,cs:bos_color_lut_c[bx]
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
		db	 00h, 03h, 02h, 01h, 01h, 03h
		db	 02h, 01h, 00h, 03h, 02h, 01h
		db	 01h, 03h, 02h, 01h, 33h,0C0h
		db	 8Ah,0C3h, 05h, 1Ch, 00h,0B2h
		db	 03h,0F6h,0F2h, 8Ah,0F4h,0D0h
		db	0CEh,0D0h,0CEh,0D0h,0CEh,0B4h
		db	 5Ah,0F6h,0E4h, 81h,0E2h, 00h
		db	 60h, 03h,0C2h, 80h,0C7h, 05h
		db	 8Ah,0DFh, 32h,0FFh, 03h,0C3h
		db	 8Bh,0F8h,0B8h, 00h,0B0h, 8Eh
		db	0C0h, 8Bh,0D9h

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
						or	dl,cs:bos_color_lut_c[bx]
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
; Uses nibble_decode_inner_2 with cs:bos_color_lut_d.

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
						call	nibble_decode_inner_2
						stosb				; Store al to es:[di]
						call	nibble_decode_inner_2
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

nibble_decode_inner_2		proc	near
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
				or	al,cs:bos_color_lut_d[bx]
				loop	nibble_decode_step_2		; Loop if cx > 0

		retn

nibble_decode_inner_2		endp

		db	 00h, 07h, 09h, 01h, 07h, 0Fh
		db	 0Bh, 07h, 09h, 0Bh, 0Bh, 03h
		db	 01h, 07h, 03h, 09h, 4Ch,0A8h
		db	0A0h, 43h, 88h, 2Ah, 4Fh, 4Fh
		db	 4Fh, 41h,0A0h,0A2h, 43h,0A0h
		db	 43h, 8Ah, 4Fh, 4Bh,0A8h, 02h
		db	 4Dh,0A8h, 2Ah, 43h, 0Ah, 41h
		db	 11h, 46h, 80h, 45h, 80h, 0Ah
		db	 4Fh, 43h,0A0h, 11h, 22h, 0Ah
		db	 43h, 80h, 2Ah, 46h,0EBh,0C0h
		db	 0Ah, 42h,0A0h, 41h, 13h, 2Ah
		db	 44h,0A0h,0ABh,0EAh, 42h,0A0h
		db	 02h, 11h, 0Ah,0AEh, 49h,0AFh
		db	 42h,0BEh, 42h,0A0h, 11h, 02h
		db	 8Ah, 80h, 2Ah, 41h,0A0h, 11h
		db	 02h, 45h,0AEh,0ACh, 02h, 80h
		db	 42h, 8Ah, 80h, 02h, 02h, 80h
		db	 03h, 20h, 2Ah, 42h,0A8h, 2Ah
		db	0BAh, 42h, 88h, 08h, 20h, 11h
		db	 43h, 80h, 0Ah, 41h,0ABh, 43h
		db	0A0h, 3Ah,0ABh, 11h, 41h,0A8h
		db	 11h, 02h, 20h, 28h, 08h, 0Ah
		db	 41h, 11h, 0Ah,0A0h, 46h,0E8h
		db	 0Ah,0A8h, 0Ah, 41h, 88h, 11h
		db	 88h, 2Ah, 41h,0BCh, 0Ch, 08h
		db	 2Ah, 42h, 02h, 42h,0A8h, 22h
		db	 22h,0A0h,0A2h, 2Bh, 41h,0A0h
		db	 11h, 20h, 0Fh, 41h,0EAh, 41h
		db	0F8h, 08h, 02h,0A0h, 02h, 0Ah
		db	0A8h, 11h, 88h,0A0h, 08h,0A2h
		db	 02h,0A0h, 02h, 88h, 11h, 0Eh
		db	0BFh, 43h,0AEh, 11h, 2Ah, 41h
		db	 82h, 41h, 28h, 02h, 20h, 41h
		db	0ABh, 80h, 30h, 11h, 22h, 42h
		db	0A0h,0ABh, 41h,0A0h
		db	8

; --- Sprite bitmap + embedded dispatch table data ---
; This region contains packed sprite bitmap pixel data for the boss,
; plus the CS-relative animation dispatch table at offset 36A5h
; (file+16A5h) referenced by render_dispatch_2 above, plus color LUTs
; at offsets matching bos_color_lut_a..d (3497h, 3654h, 3753h, 38D0h).
; Sourcer misidentifies many bytes as x86 code because the data bytes
; happen to form valid instruction patterns. All kept as raw db.

sprite_bitmap_data:
		db	 41h, 0Ah, 43h, 11h, 08h, 8Ah
		db	 80h,0BAh,0BAh,0AEh, 12h, 08h
		db	0F0h, 80h, 02h,0A0h, 02h, 22h
		db	 41h, 80h, 02h, 82h, 80h, 20h
		db	 2Ah,0A0h, 03h,0C0h,0FEh, 42h
		db	0B0h, 02h, 41h,0A2h, 82h, 41h
		db	0A0h, 22h, 11h, 22h,0AEh, 41h
		db	 30h, 11h, 02h, 42h,0A8h, 2Bh
		db	 41h,0A0h, 41h, 20h, 41h, 80h
		db	 0Ah,0EAh, 88h, 41h,0A8h, 28h
		db	 0Bh,0BAh,0E0h, 11h, 22h, 08h
		db	 02h,0A2h, 02h,0A2h, 02h, 41h
		db	0A2h, 80h, 22h, 80h, 82h, 8Ah
		db	 11h, 02h, 8Ch, 11h, 23h, 42h
		db	0A0h, 0Ah, 41h, 2Ah, 82h, 41h
		db	 80h, 0Ah, 20h, 43h,0E2h,0A0h
		db	 11h,0A8h, 42h, 2Ah, 41h,0A0h
		db	0A0h, 41h,0A0h, 11h, 0Ah,0E8h
		db	 2Ah, 41h,0A8h, 80h, 11h,0EAh
		db	 11h, 82h, 08h, 22h, 8Ah,0A0h
		db	 11h,0A2h, 82h, 41h, 2Ah, 20h
		db	 2Ah,0A8h, 08h, 22h, 8Ah, 41h
		db	 2Ch, 02h, 41h,0ABh, 41h,0A0h
		db	 8Ah,0A8h, 41h, 80h,0C8h, 11h
		db	 0Ah, 28h, 8Ah, 42h,0A8h, 8Ah
		db	 80h,0A8h, 43h,0EAh, 82h,0A2h
		db	 41h, 12h, 0Ah,0A8h, 11h, 2Ah
		db	 41h, 88h, 08h,0EAh, 11h, 88h
		db	 80h,0A8h, 0Ah,0A8h, 08h, 88h
		db	 80h, 88h, 41h,0A8h, 0Ah, 08h
		db	 80h, 11h, 0Ah, 88h,0B0h, 28h
		db	 8Ah, 02h, 41h, 80h, 22h, 22h
		db	 22h, 82h,0CAh, 11h, 88h, 20h
		db	 22h,0EAh, 41h,0A2h, 22h, 20h
		db	 2Ah, 2Ah, 41h,0AEh, 41h, 8Ah
		db	 8Ah, 28h, 12h, 03h,0A0h, 11h
		db	 0Ah,0BAh, 22h, 41h, 38h, 20h
		db	 22h, 8Ah, 22h, 22h, 22h, 41h
		db	 22h, 20h, 22h, 41h, 22h, 12h
		db	 0Ah, 22h, 22h, 22h,0B0h, 02h
		db	 22h, 11h,0EAh,0CAh, 42h, 8Ah
		db	 8Bh,0C8h, 28h, 20h,0A8h, 41h
		db	0FAh, 41h,0EAh, 41h,0A8h, 0Ah
		db	 2Ah, 41h,0ABh, 41h, 8Ah, 88h
		db	 80h, 12h, 03h, 41h, 88h, 02h
		db	 42h, 20h, 88h,0A8h, 2Ah, 8Ah
		db	0A0h, 2Bh, 41h, 20h, 42h, 0Ah
		db	 42h,0A0h, 2Ah, 20h, 43h,0C0h
		db	 2Ah, 41h, 11h,0EAh,0E2h, 22h
		db	0A2h, 2Ah, 03h, 20h, 20h, 08h
		db	 20h, 3Ah,0F2h, 41h, 22h, 22h
		db	 20h, 22h, 44h, 0Ah, 2Ah, 80h
		db	 02h, 22h, 22h,0A2h, 22h, 11h
		db	0AEh, 22h,0EAh, 22h, 22h, 22h
		db	 0Ah, 02h, 2Ah, 22h, 2Bh, 22h
		db	 22h, 02h, 2Ah,0A0h, 11h, 22h
		db	 2Ah, 22h, 22h, 3Fh, 0Ah, 02h
		db	 22h, 80h, 45h, 0Bh,0A8h, 20h
		db	 80h, 22h,0BAh,0FAh, 43h,0ABh
		db	0E2h, 82h, 42h,0EAh, 2Ah,0A2h
		db	 11h, 0Ah, 42h,0EAh, 41h,0A0h
		db	0EAh, 41h,0BAh, 42h, 2Ah, 8Ah
		db	 2Ah,0EEh, 44h,0A0h, 41h, 80h
		db	 44h,0BFh,0C0h, 2Ah, 82h, 41h
		db	 20h,0ABh,0A2h, 22h,0A2h
data_10		db	0A8h			; data table (indexed access)
		db	 0Fh, 20h, 20h, 22h,0A2h, 22h
		db	0EAh,0ABh, 22h, 22h,0FEh, 28h
		db	 2Ah, 42h,0A8h, 2Ah,0A0h, 02h
		db	 20h, 11h, 22h,0E2h, 22h, 20h
		db	 22h, 23h,0EBh,0E2h, 32h, 02h
		db	 11h, 22h,0AEh, 22h, 2Ah,0A3h
		db	 22h, 2Ah, 22h, 02h, 22h, 22h
		db	 2Ah,0FFh,0C0h, 02h, 22h, 20h
		db	 22h, 80h, 2Bh, 88h, 8Ah, 88h
		db	 88h, 3Bh, 80h, 88h, 80h, 80h
		db	 8Bh,0EAh,0A8h,0A8h, 8Fh, 88h
		db	 88h, 82h, 42h,0BAh,0A8h,0A8h
		db	 08h, 11h, 88h, 88h, 88h, 88h
		db	 88h, 3Ah, 8Ch,0BFh,0BFh, 8Bh
		db	0C0h, 11h, 8Bh, 8Ch,0C8h, 8Ah
		db	0F8h, 88h,0C8h, 80h, 08h, 88h
		db	 88h,0BFh, 12h, 80h, 88h, 88h
		db	 08h, 20h, 2Ah,0A2h, 41h, 2Ah
		db	0A8h, 2Fh, 02h, 22h, 0Ah, 82h
		db	0ABh,0E2h, 2Eh
data_11		dw	0BAA2h			; data table (indexed access)
		db	 22h, 2Ah,0A2h,0FEh, 41h,0BAh
		db	 41h,0A0h, 20h, 2Ah,0A2h, 41h
		db	 22h, 2Ah,0A2h, 3Ah, 2Eh, 2Fh
		db	0EBh,0BAh, 32h, 0Ah,0AEh,0B3h
		db	 32h, 2Ah,0EEh,0EAh, 2Ah, 0Ah
		db	0A2h,0EAh, 2Fh,0C0h, 02h, 12h
		db	 22h,0A2h, 0Ah, 88h, 2Ch, 88h
		db	0A8h, 41h,0A0h,0BBh, 08h, 80h
		db	 08h, 88h,0CBh, 88h,0B8h, 88h
		db	0C8h, 88h, 88h, 88h,0AEh, 42h
		db	0A2h, 11h, 80h, 88h, 88h, 88h
		db	 88h, 88h, 88h, 0Eh,0B8h, 88h
		db	0CAh,0BFh, 88h, 0Ah,0CBh,0C3h
		db	0B8h, 88h,0BFh,0CCh, 8Ah, 08h
		db	 88h,0ABh,0F0h, 3Ch, 88h, 88h
		db	 08h, 08h, 88h, 88h, 41h, 22h
		db	 2Ah, 41h,0EAh, 82h, 3Bh, 0Ah
		db	 82h, 20h, 0Ah,0ABh, 41h,0A2h
		db	 41h,0EAh, 41h,0F3h, 2Ah,0AEh
		db	 42h, 8Ah, 02h,0A2h,0A2h, 2Ah
		db	 42h,0A2h, 2Ah, 8Eh,0EAh,0A2h
		db	0EAh,0BAh,0EEh,0AEh, 3Ch, 11h
		db	0FAh,0B2h, 2Bh,0AEh, 41h,0A2h
		db	 2Ah,0B8h, 11h, 03h,0C2h,0A8h
		db	 02h, 02h, 2Ah, 82h, 88h, 02h
		db	 41h,0A8h,0A8h, 0Bh,0EEh, 20h
		db	 11h,0A8h, 41h,0AEh, 8Ah, 42h
		db	0E0h, 8Fh, 42h,0ABh, 42h, 88h
		db	 11h, 88h, 42h,0A0h, 88h, 42h
		db	 88h,0C8h, 41h,0BAh,0A0h, 41h
		db	0BEh,0C0h, 11h,0CCh,0BAh, 41h
		db	0F8h, 8Ah, 42h,0C0h, 08h, 80h
		db	 28h, 2Ah, 88h,0A2h, 41h,0A0h
		db	 22h, 0Ah, 2Ah, 41h, 80h, 2Bh
		db	0F8h, 28h, 20h, 28h, 2Bh,0ABh
		db	0EAh, 2Ah, 2Bh,0ABh,0F2h, 2Fh
		db	0FFh, 08h, 42h, 88h, 0Ah, 22h
		db	 2Ah, 11h, 0Ah, 20h, 2Ah, 2Ah
		db	0A2h, 22h, 2Ah, 3Ah, 41h, 3Eh
		db	0EBh, 11h, 20h,0EEh, 3Ah, 2Ah
		db	0AEh, 22h, 2Ah, 2Ah, 02h, 20h
		db	 11h, 02h, 02h, 22h, 2Ah, 2Ah
		db	0A2h, 88h, 88h,0BAh,0A8h, 11h
		db	0BCh, 11h, 88h, 11h, 80h,0ABh
		db	 8Eh,0F8h, 88h, 8Bh, 8Ch, 8Bh
		db	0F0h, 11h, 0Ah, 42h, 28h, 08h
		db	 80h, 11h, 08h, 88h, 88h, 12h
		db	 8Ah, 88h, 88h, 8Ch, 88h, 88h
		db	0A0h, 08h, 11h,0B8h,0A8h, 88h
		db	 8Ch, 8Ah, 88h,0ACh, 88h, 88h
		db	 88h, 11h, 88h, 8Ah, 88h, 8Ah
		db	 80h, 22h, 2Ah,0EAh, 28h, 02h
		db	 3Ch, 11h, 20h, 02h, 0Ah,0A2h
		db	 2Bh, 32h, 2Ah, 2Eh,0F2h,0FCh
		db	 12h, 0Eh, 2Ah, 41h, 20h, 11h
		db	 02h, 2Ah, 22h, 22h, 22h, 02h
		db	 20h, 02h, 22h, 2Ah, 2Eh,0E2h
		db	 2Ah,0C0h, 02h, 20h, 32h,0EAh
		db	 22h, 22h, 2Ah, 2Ah,0AEh, 22h
		db	0E2h, 2Ah, 20h,0A2h, 22h, 41h
		db	 22h, 22h, 88h, 88h,0EBh,0A0h
		db	 08h
data_12		dw	12FCh			; data table (indexed access)
		db	 88h, 08h,0A8h,0FBh,0A8h, 88h
		db	0AFh, 8Bh, 13h, 02h, 2Ah, 41h
		db	 20h, 11h, 88h, 8Fh,0CBh,0C8h
		db	0F8h, 88h, 88h, 80h, 88h, 11h
		db	 8Ch,0B8h, 8Eh,0C0h, 88h, 88h
		db	 3Ch,0E8h, 88h,0AFh,0A8h, 88h
		db	0BBh, 88h,0C8h, 8Bh, 80h, 28h
		db	0FCh,0A8h, 88h,0A8h, 22h,0A2h
		db	 23h, 20h, 22h,0F2h, 20h, 22h
		db	 20h, 22h,0A2h,0A3h,0A2h,0A2h
		db	 32h, 2Ch, 11h, 02h, 11h, 22h
		db	 42h,0AEh, 22h, 22h,0AEh,0FFh
		db	 23h, 22h,0A2h, 22h, 20h, 11h
		db	0A0h, 02h,0A2h, 32h, 22h, 20h
		db	 11h, 2Eh,0FAh, 22h, 2Bh,0E2h
		db	0A2h, 32h,0E2h,0EAh,0E2h, 20h
		db	 22h,0C3h,0A2h, 22h, 2Ah, 88h
		db	 8Bh, 88h,0A0h, 88h,0B0h, 11h
		db	 80h, 11h,0ABh, 8Eh, 8Fh,0C8h
		db	 88h,0CBh,0B0h, 13h, 0Ah, 42h
		db	0ACh, 88h, 8Bh,0CBh,0BCh,0FCh
		db	 8Bh, 88h, 88h, 88h, 88h, 88h
		db	 8Ah,0B8h,0BBh, 08h, 11h, 88h
		db	 88h,0CAh, 88h,0CBh,0B8h, 8Ah
		db	0C8h,0CAh, 41h,0E8h, 88h, 0Bh
		db	 11h,0FAh, 88h, 8Ah, 22h, 23h
		db	0AEh, 80h, 23h,0F2h, 20h, 11h
		db	 2Eh,0A2h, 32h, 23h, 20h, 0Fh
		db	 2Eh, 30h, 20h, 11h, 22h, 22h
		db	 42h,0AEh, 22h, 20h, 3Eh,0FEh
		db	0E3h,0ECh, 02h, 22h, 22h, 22h
		db	 22h, 22h,0AEh,0E3h, 02h, 22h
		db	 22h, 2Ah,0EFh,0E3h, 22h,0E8h
		db	 22h,0E2h, 3Ah,0AFh,0A2h, 22h
		db	 0Bh, 11h, 0Eh, 22h, 22h, 88h
		db	 88h, 8Ch,0C0h, 8Ch, 0Ch,0C0h
		db	 88h,0F8h, 8Bh, 80h, 88h, 83h
		db	0F0h, 0Ch,0C0h, 11h, 88h, 80h
		db	 88h, 42h,0ACh, 88h, 88h, 03h
		db	0BFh, 8Ch, 13h, 88h, 88h, 88h
		db	 82h,0B8h,0C0h, 12h, 88h, 8Ah
		db	0CEh,0C3h, 88h,0B8h, 88h,0C0h
		db	0BBh,0AEh, 88h, 80h, 80h, 11h
		db	 08h, 11h, 88h, 22h, 23h, 22h
		db	 82h, 2Fh, 20h, 3Eh, 02h, 22h
		db	0FCh, 02h, 22h,0FEh, 20h, 0Eh
		db	0C2h, 02h, 20h, 02h, 22h,0BBh
		db	 42h, 22h, 22h, 11h,0BEh, 30h
		db	 22h, 20h, 02h, 22h, 22h, 20h
		db	 02h,0AEh,0E2h, 20h, 02h, 22h
		db	 23h, 33h, 83h, 22h, 41h, 23h
		db	 02h, 3Bh, 41h,0A0h, 02h, 22h
		db	 22h, 08h, 82h, 22h, 11h, 8Bh
		db	0BAh, 12h,0FFh,0C8h, 0Bh, 3Fh
		db	0A8h, 88h, 3Fh, 11h,0A8h,0B8h
		db	0C0h, 11h, 88h, 88h, 11h, 8Ah
		db	 41h,0B8h, 12h, 88h,0ACh,0C0h
		db	 11h, 88h, 88h, 12h, 88h, 8Ah
		db	0B3h, 11h, 88h, 88h, 12h,0ABh
		db	0CBh,0C0h,0F8h,0ABh, 88h, 0Ah
		db	 41h, 88h, 88h, 12h, 02h, 88h
		db	 11h, 22h, 2Ch, 23h, 02h, 22h
		db	 03h, 3Eh, 2Ah,0E2h, 80h, 03h
		db	0E2h, 22h, 20h,0C3h, 11h, 22h
		db	 11h, 02h, 22h, 8Ah,0EAh,0B2h
		db	 22h, 22h, 11h,0EEh,0E2h, 22h
		db	 11h, 02h, 22h, 22h, 11h, 02h
		db	0AFh, 22h, 11h, 02h, 22h, 22h
		db	 23h,0CEh, 32h,0BAh, 83h, 02h
		db	 2Eh,0BAh, 11h, 02h, 22h, 22h
		db	 02h, 0Fh, 22h, 8Ah, 88h,0ABh
		db	 08h, 88h, 88h,0CBh, 8Fh, 8Bh
		db	 88h,0BCh,0C8h, 88h,0A8h,0CBh
		db	 11h, 08h, 88h, 88h, 88h,0BAh
		db	0EAh,0B8h, 88h, 88h, 88h,0A8h
		db	 88h, 88h, 88h, 88h, 02h, 88h
		db	 88h, 88h,0BBh, 88h, 88h, 88h
		db	 88h, 88h, 8Bh, 8Ch,0B8h,0BBh
		db	 8Ch, 88h, 8Ah,0BAh, 88h, 88h
		db	 88h, 88h, 82h,0B0h,0C8h, 02h
		db	 2Ah,0ACh, 02h, 22h, 02h,0E3h
		db	 2Eh, 02h, 22h,0E0h,0E2h, 22h
		db	0A3h, 23h, 15h, 88h, 82h, 80h
		db	 02h,0A0h, 11h, 22h,0C0h, 14h
		db	 20h, 12h,0EBh, 12h, 02h,0E0h
		db	0A0h, 08h,0CCh, 0Fh, 08h, 20h
		db	 02h, 22h,0BAh, 22h,0A0h, 11h
		db	 08h, 80h,0A0h, 3Ch, 8Ah,0A8h
		db	0B0h, 08h, 88h, 08h,0B8h,0CCh
		db	 8Ch, 8Bh, 80h,0F8h, 41h, 8Bh
		db	 8Bh, 11h, 0Ah, 0Ah, 08h, 28h
		db	 22h, 02h,0B0h,0A0h, 11h, 88h
		db	 3Ah, 80h, 2Ah, 08h, 20h, 11h
		db	 02h, 11h, 20h,0FFh, 20h, 88h
		db	 20h, 88h, 22h, 0Fh, 32h, 20h
		db	 41h, 28h, 88h, 0Ah,0BAh, 20h
		db	 80h, 22h, 22h, 20h, 80h, 03h
		db	 11h, 2Ah, 11h,0A8h,0A2h, 0Ah
		db	0B0h,0F0h, 08h, 0Ch,0C0h, 30h
		db	 41h, 83h, 0Ch, 13h, 02h, 80h
		db	 0Ch, 0Ah,0B0h, 12h, 08h, 41h
		db	 82h, 13h, 22h, 11h, 22h, 11h
		db	0CBh, 11h, 82h, 08h, 80h, 20h
		db	 02h,0F0h, 88h, 2Ah, 80h, 08h
		db	 82h,0E8h, 02h, 02h, 13h, 80h
		db	 11h, 8Ah, 80h, 22h, 22h, 20h
		db	 0Bh,0A8h,0F8h, 88h, 8Ch,0C0h
		db	 0Ch, 41h, 8Ch, 8Ch, 16h, 08h
		db	0B0h, 13h, 28h,0C0h, 15h, 02h
		db	 20h,0FBh, 15h, 02h,0F0h, 11h
		db	 0Ah, 80h, 11h, 0Ah,0E8h, 11h
		db	 20h, 15h, 20h, 12h, 88h,0A0h
		db	 2Bh,0A0h, 30h, 30h, 30h,0C0h
		db	 03h, 08h, 0Ch, 0Ch, 15h, 2Bh
		db	 8Ah,0B0h, 13h, 2Ah, 80h, 14h
		db	 02h, 12h,0CEh, 15h, 03h, 20h
		db	 11h, 02h, 12h, 0Ah,0E8h, 17h
		db	0A0h, 08h, 82h, 2Ah, 88h, 2Eh
		db	0B8h,0B8h,0A8h,0BBh, 11h, 03h
		db	 88h,0B8h,0B0h, 15h, 0Bh, 8Ah
		db	0A0h, 13h, 2Ah, 18h,0FEh, 16h
		db	 80h, 11h, 02h, 12h, 0Ah,0E8h
		db	 11h, 20h, 15h, 80h, 11h, 28h
		db	0A8h, 8Ah, 41h,0CFh, 30h, 20h
		db	0C2h, 11h, 03h, 0Bh, 33h,0C0h
		db	 15h, 2Ah, 41h,0C0h, 13h, 2Ah
		db	 18h,0F2h, 16h, 80h, 14h, 0Ah
		db	0E8h, 17h, 88h, 88h, 22h,0A2h
		db	 8Ah,0ABh,0B0h,0F8h,0CBh, 8Ah
		db	 11h, 03h, 8Bh, 8Ch, 16h, 0Ah
		db	0A2h,0C0h, 13h, 3Ah, 18h,0CEh
		db	 16h, 80h, 14h, 0Ah,0E8h, 17h
		db	 80h, 41h, 82h, 41h, 2Bh, 41h
		db	 11h, 0Fh, 03h, 02h, 12h,0C3h
		db	 0Ch, 16h, 0Ah,0A2h,0C0h, 13h
		db	 2Bh, 18h,0CEh, 16h, 80h, 14h
		db	 0Ah,0A8h, 17h, 88h,0A2h, 22h
		db	0A2h, 2Ah,0A8h, 12h,0FCh,0A8h
		db	 12h,0CBh, 8Ch, 16h, 0Ah, 82h
		db	0C0h, 13h, 22h, 18h,0EEh, 1Bh
		db	 02h,0E8h, 17h, 2Ah, 28h, 0Ah
		db	 88h, 41h,0E0h, 12h, 0Fh, 88h
		db	 12h,0C3h, 0Ch, 17h,0A2h, 80h
		db	 13h, 2Ah, 17h, 03h,0B3h, 1Bh
		db	 02h,0EAh, 17h, 28h, 02h,0A2h
		db	 82h, 41h, 13h, 03h, 28h, 12h
		db	0CCh, 0Ch, 16h, 2Ah, 20h,0B0h
		db	 13h,0FAh, 17h, 03h,0CBh, 1Bh
		db	 02h, 3Ah, 17h, 02h,0A8h, 11h
		db	 41h,0ABh, 13h, 03h, 12h, 03h
		db	 0Ch, 30h, 16h, 0Ah, 88h,0B0h
		db	 13h, 8Bh, 17h, 03h, 23h, 1Ch
		db	 41h, 17h, 82h, 41h,0A2h, 41h
		db	0BEh, 14h,0A8h, 11h, 03h, 8Ch
		db	0B0h, 16h, 08h, 88h,0B0h, 13h
		db	0ABh, 17h, 03h, 23h, 1Bh, 02h
		db	 32h, 17h, 22h,0BFh,0A8h, 41h
		db	0E8h, 14h, 88h, 11h, 02h, 08h
		db	 30h, 16h, 02h, 28h,0B0h, 13h
		db	 8Ah, 17h, 03h, 23h, 1Ch, 88h
		db	 80h, 16h, 8Bh,0C8h,0F2h, 41h
		db	0ECh, 14h,0B0h, 11h, 02h, 0Ah
		db	0A0h, 16h, 22h, 28h,0B0h, 13h
		db	0BBh, 17h, 03h, 23h, 1Bh, 02h
		db	 02h, 17h, 2Ch, 11h, 38h, 41h
		db	0F0h, 13h, 02h, 28h, 11h, 02h
		db	 28h,0A0h, 16h, 2Ah, 8Ah,0B0h
		db	 12h, 03h, 02h, 17h, 03h
data_13		dw	0C030h			; data table (indexed access)
		db	 1Ah, 08h, 80h, 80h, 16h, 2Ch
		db	 11h, 0Ah, 2Bh,0A0h, 14h, 88h
		db	 11h, 02h, 2Ah,0A0h, 16h, 2Ah
		db	 8Ah,0ACh, 12h, 02h, 30h, 80h
		db	 16h, 0Ch, 80h,0C0h, 1Ah, 02h
		db	 88h, 17h,0B0h, 11h, 08h,0ABh
		db	0A0h, 13h, 08h, 28h, 11h, 03h
		db	 2Ch, 8Ch, 16h, 0Ah, 8Ah,0A8h
		db	 12h, 02h, 8Ch, 80h, 16h, 0Fh
		db	 80h,0C0h, 1Ah, 08h, 02h, 20h
		db	 16h,0B0h, 11h, 0Eh, 2Bh,0B0h
		db	 14h, 28h, 11h, 08h, 22h, 88h
		db	 16h, 0Ah,0A8h, 88h, 12h, 08h
		db	 20h, 20h, 16h, 02h, 8Ch, 80h
		db	 1Ah, 02h, 20h, 20h, 16h,0B0h
		db	 11h, 08h,0ABh, 80h, 14h, 08h
		db	 11h, 0Ch, 08h, 28h, 16h, 0Ah
		db	 8Ah, 28h, 13h, 82h, 17h, 0Ah
		db	0C8h, 80h, 1Ah, 28h, 02h, 08h
		db	 16h,0B0h, 11h, 02h, 2Ah, 80h
		db	 13h, 08h, 02h, 12h, 0Ch, 08h
		db	 16h, 0Ah, 88h, 88h, 12h, 0Ah
		db	 0Ah, 80h, 16h, 0Ch,0C8h,0A0h
		db	 1Ah, 28h, 20h, 82h, 16h,0C0h
		db	 11h, 08h,0AEh,0C0h, 13h, 08h
		db	 12h, 08h, 0Ch, 08h, 16h, 0Ah
		db	 2Ah, 28h, 12h, 02h, 11h, 80h
		db	 16h, 3Ah, 08h, 20h, 1Ah, 80h
		db	 11h, 08h, 20h, 15h,0C0h, 11h
		db	 22h, 2Eh,0C0h, 16h, 08h, 88h
		db	 88h, 16h, 0Ah, 08h, 88h, 12h
		db	 08h, 18h, 22h, 11h, 20h, 19h
		db	 0Ah, 19h,0C0h, 11h, 28h,0AEh
		db	 14h, 80h, 12h, 08h, 88h, 02h
		db	 16h, 0Ah, 22h, 02h, 1Bh, 23h
		db	 08h, 08h, 1Fh, 16h, 22h, 2Eh
		db	 17h, 08h, 82h, 02h, 16h, 0Ah
		db	 41h, 82h, 1Bh,0E0h, 02h, 1Eh
		db	 28h, 17h, 08h,0ABh, 19h, 80h
		db	 80h, 15h, 08h, 41h, 02h, 1Bh
		db	0A0h, 02h, 1Eh, 0Ah, 17h, 2Ah
		db	0BBh, 17h, 02h, 02h, 20h, 80h
		db	 15h, 0Ah, 2Ah, 80h, 80h, 19h
		db	 03h, 80h, 11h, 80h, 1Dh, 02h
		db	 17h, 0Ah,0ACh, 17h, 80h, 08h
		db	 80h, 20h, 15h, 22h, 28h, 80h
		db	 1Fh, 1Fh, 15h, 3Ah,0B8h, 16h
		db	 0Ah, 08h, 02h, 08h, 0Ah, 15h
		db	 28h, 28h, 11h, 80h, 1Fh, 1Fh
		db	 14h, 32h,0B8h, 19h, 82h, 16h
		db	 28h, 22h, 02h, 1Fh, 1Fh, 15h
		db	 0Eh,0B8h, 1Fh, 11h,0A0h,0A8h
		db	 80h, 88h, 1Fh, 1Fh, 14h, 0Ah
		db	0BCh, 1Fh, 11h,0A0h, 28h, 11h
		db	 20h, 1Fh, 1Fh, 14h, 0Ah, 8Ch
		db	 1Fh, 02h, 11h, 82h, 1Fh, 1Fh
		db	 16h, 08h, 20h, 1Fh, 12h, 02h
		db	 1Fh, 1Fh, 16h, 08h,0A0h, 1Fh
		db	 12h, 08h, 1Fh, 1Fh, 17h, 30h
		db	 1Fh, 11h, 20h, 1Fh, 1Fh, 18h
		db	 30h, 00h, 4Ch,0ABh,0AFh, 43h
		db	0C8h, 3Ah, 4Fh, 4Bh,0ABh,0FEh
		db	 48h,0FFh, 44h,0ABh,0EAh, 41h
		db	0BAh, 41h,0AFh,0AEh,0FFh, 42h
		db	0AFh, 43h, 8Fh, 45h,0BFh,0FAh
		db	0FEh, 44h,0BEh, 46h,0AFh, 45h
		db	0AFh,0FCh, 03h,0FAh, 41h,0EAh
		db	 41h,0BFh,0EAh, 41h,0AFh,0BAh
		db	 43h,0AEh,0BCh, 3Ah,0FAh,0EAh
		db	 41h,0FAh,0FFh, 11h,0FFh,0EAh
		db	0BEh,0AEh,0AFh, 41h, 80h,0EEh
		db	0EAh, 42h,0AFh,0C0h, 0Fh,0FBh
		db	0FAh, 43h,0ABh,0FEh, 43h,0ABh
		db	0EAh, 41h,0EAh, 43h,0AFh,0F0h
data_14		db	 11h			; data table (indexed access)
		db	 22h, 0Fh,0EEh,0BAh,0AFh,0C0h
		db	 3Eh, 41h,0FBh,0EAh,0BEh, 42h
		db	 38h, 11h, 0Fh,0AFh,0BAh,0AFh
		db	0BFh, 13h, 3Fh,0EAh,0FFh, 41h
		db	0FAh,0A0h,0E8h, 3Fh, 42h,0B0h
		db	 02h, 11h, 0Fh,0A2h, 41h,0FAh
		db	0BFh,0FAh,0ABh,0FAh, 41h,0EBh
		db	0EEh,0A0h,0EAh,0BAh,0C3h,0BAh
		db	0ABh,0F0h, 11h, 02h, 8Ah, 80h
		db	 3Bh, 41h,0F0h, 11h, 03h,0AFh
		db	0BEh, 41h,0ABh,0AEh,0A3h,0A0h
		db	 02h, 80h,0FEh,0EAh,0BBh,0C0h
		db	 02h, 02h, 80h, 03h, 3Fh,0FAh
		db	0FEh,0ABh,0A8h, 3Eh, 8Eh,0EAh
		db	0ABh,0C8h, 08h, 20h, 11h,0EBh
		db	0ABh,0AFh,0C0h, 0Fh,0FBh,0ACh
		db	 41h,0BEh,0ABh,0F0h, 0Eh,0ACh
		db	 11h,0FFh,0ACh, 11h, 02h, 20h
		db	 28h, 08h, 0Eh,0EFh, 11h, 0Ah
		db	0A0h,0FBh,0EAh, 41h,0AFh,0AEh
		db	0BAh, 38h, 0Ah,0E8h, 0Eh,0AEh
		db	0BCh, 11h, 88h, 2Ah, 41h,0BCh
		db	 0Ch, 0Fh,0EBh,0EAh, 41h, 03h
		db	0EBh,0BAh,0ACh, 22h, 22h,0F0h
		db	0E2h, 38h,0AEh,0F0h, 11h, 20h
		db	 11h,0BEh, 2Eh, 41h, 0Ch, 08h
		db	 03h,0B0h, 02h, 0Eh,0ECh, 11h
		db	 88h,0A0h, 08h,0A2h, 03h,0F0h
		db	 02h, 88h, 11h, 0Eh,0BFh, 41h
		db	0FAh,0EEh,0A3h, 11h, 3Ah,0EAh
		db	0C3h,0EFh,0ECh, 02h, 20h, 41h
		db	0ABh,0C0h, 30h, 11h, 3Eh,0BAh
		db	 41h,0A0h,0E8h,0BAh,0B0h, 08h
		db	0AFh, 0Ah,0BFh,0FAh,0EBh, 11h
		db	 08h,0CAh, 80h,0CBh, 8Ah,0A3h
		db	 12h, 08h, 11h, 80h, 03h,0B0h
		db	 02h, 22h, 41h, 80h, 02h, 83h
		db	 80h, 20h, 2Ah,0A0h, 03h,0C0h
		db	0FEh, 41h,0EAh, 80h, 02h,0AFh
		db	0A2h,0C3h,0FEh,0B0h, 22h, 11h
		db	 22h,0AFh, 41h, 30h, 11h, 03h
		db	 42h,0A8h, 38h,0BAh,0B0h, 41h
		db	 30h,0AFh,0C0h, 0Fh, 2Bh,0C8h
		db	 41h,0A8h, 28h, 0Ch, 8Ah, 30h
		db	 11h, 22h, 08h, 02h,0A2h, 03h
		db	0B2h, 02h, 41h,0A2h, 80h, 22h
		db	 80h,0C2h, 8Ah, 11h, 02h, 8Ch
		db	 11h, 23h,0AFh,0EEh,0B0h, 0Ah
		db	0BAh, 2Bh,0C3h,0BAh,0C0h, 0Ah
		db	 20h,0ABh,0AEh, 41h,0E2h,0A0h
		db	 11h,0EBh, 42h, 3Bh, 41h,0B0h
		db	0A0h,0BAh,0F0h, 11h, 0Eh, 2Ch
		db	 3Fh,0EAh,0E8h, 80h, 11h, 2Fh
		db	 11h, 82h, 08h, 22h, 8Ah,0A0h
		db	 11h,0F2h, 82h
data_15		db	 41h			; data table (indexed access)
		db	 2Ah, 20h, 2Ah
data_16		dw	08A8h			; data table (indexed access)
		db	 22h, 8Ah, 41h, 2Ch, 02h, 41h
		db	0F8h,0BAh,0B0h, 8Ah,0B8h,0ABh
		db	0C0h,0FBh, 11h, 0Ah, 28h, 8Bh
		db	0AEh, 41h,0E8h, 8Ah, 80h,0EBh
		db	 42h,0BAh, 2Ah,0C2h,0A2h,0EBh
		db	 12h, 0Bh,0ACh, 11h, 3Ah,0BAh
		db	 88h, 08h, 2Bh, 11h, 88h, 80h
		db	0A8h, 0Ah,0B8h, 08h,0C8h, 80h
		db	 88h, 41h,0A8h, 0Ah, 08h, 80h
		db	 11h, 0Ah, 88h,0B0h, 28h, 8Ah
		db	 03h,0BAh,0C0h, 23h, 32h, 23h
		db	0C2h,0FBh, 11h, 88h, 20h, 22h
		db	0EEh, 41h,0E2h, 22h, 20h, 3Ah
		db	0FAh, 41h,0A2h,0EAh,0CAh, 8Bh
		db	0FCh, 13h,0B0h, 11h, 0Eh, 8Eh
		db	 22h, 41h, 0Ch, 20h, 22h, 8Ah
		db	 22h, 22h, 22h, 41h, 22h, 20h
		db	 22h, 41h, 22h, 12h, 0Ah, 22h
		db	 22h, 22h,0B0h, 02h, 22h, 11h
		db	 3Ah, 0Ah, 41h,0FAh, 8Eh,0CBh
		db	0FCh, 28h
data_17		dw	0A820h			; data table (indexed access)
		db	 41h,0FAh, 41h,0EAh, 41h,0A8h
		db	 3Eh,0EFh, 41h,0A8h,0BAh,0CAh
		db	 8Fh,0C0h, 13h,0FAh, 88h, 03h
		db	0BAh, 41h, 20h, 8Ch,0A8h, 2Ah
		db	 8Ah,0A0h, 2Bh,0EAh, 20h, 42h
		db	 0Ah, 42h,0A0h, 2Ah, 20h, 43h
		db	0C0h, 2Ah, 41h, 11h, 2Eh, 22h
		db	 22h,0E2h, 2Fh, 03h, 30h, 20h
		db	 08h, 20h, 3Eh,0F2h,0ABh, 22h
		db	 22h, 20h, 3Fh,0BAh,0EAh,0ABh
		db	0BBh, 0Ah, 3Ah,0C0h
data_18		db	 02h			; data table (indexed access)
		db	 22h, 23h,0F2h, 22h, 11h,0E2h
		db	 22h,0EAh, 22h, 22h, 22h, 0Ah
		db	 02h, 3Fh, 22h, 2Bh, 22h, 22h
		db	 02h, 2Ah,0A0h, 11h, 22h, 2Ah
		db	 22h, 22h, 3Fh, 0Ah, 02h, 22h
		db	 80h,0FBh, 42h,0EAh,0BBh, 0Bh
		db	0B8h
data_19		dw	8020h			; data table (indexed access)
		db	 22h,0BEh,0FAh,0AFh, 42h,0ABh
		db	0EEh,0FEh,0BAh,0EAh, 3Bh, 2Ah
		db	0EFh, 11h, 0Ah, 42h, 2Ah, 41h
		db	0A0h, 2Eh, 41h,0BAh, 42h, 2Ah
		db	 8Ah, 2Ah,0EEh, 43h,0AEh,0E0h
		db	 41h, 80h, 44h,0BFh,0C0h, 2Ah
		db	 82h, 41h, 20h,0ECh,0A2h, 22h
		db	0E2h,0ECh, 0Fh, 20h, 20h, 22h
		db	0A2h, 32h,0FAh,0BFh, 22h, 22h
data_20		db	0FEh			; data table (indexed access)
		db	 2Bh,0EAh,0BAh,0EAh,0ECh, 2Ah
		db	0ECh, 02h, 20h, 11h
data_21		dw	2222h			; data table (indexed access)
		db	 22h, 20h, 33h, 23h,0EBh,0E2h
		db	 32h, 02h, 11h, 23h,0EEh, 22h
		db	 2Ah,0A3h, 22h, 3Eh, 22h, 02h
		db	 22h, 22h, 2Ah,0FFh,0C0h, 02h
		db	 22h, 20h, 22h, 80h, 38h, 88h
		db	 8Bh, 88h,0CCh, 3Bh, 80h, 88h
		db	 80h, 80h,0CBh,0FAh,0ACh,0B8h
		db	 8Fh, 88h, 88h,0BEh,0AEh,0EAh
		db	 8Eh,0A8h,0ECh, 08h, 11h, 88h
		db	 88h,0C8h, 88h, 88h, 0Bh, 8Ch
		db	0BFh,0BFh, 8Bh,0C0h, 11h, 8Bh
		db	 8Ch,0C8h, 8Bh,0F8h, 88h,0CCh
		db	 80h, 08h, 88h, 88h,0BFh, 12h
		db	 80h, 88h, 88h, 08h, 20h, 3Bh
		db	0A2h,0ABh, 2Fh,0ECh, 2Fh, 02h
		db	 22h, 0Ah, 82h,0EBh,0E2h, 3Eh
		db	0E2h,0BAh, 22h, 2Ah,0A3h,0CEh
		db	0BAh, 8Eh,0ABh,0B0h, 20h, 2Ah
		db	0A2h, 41h, 22h, 2Ah,0A2h, 0Ah
		db	 2Eh, 2Fh,0FFh,0BAh, 32h, 0Ah
		db	0FEh,0B3h, 32h, 2Ah,0FFh,0EAh
		db	 2Eh, 0Eh,0A2h,0EAh, 2Fh,0C0h
		db	 02h, 12h, 22h,0A2h, 0Ah, 88h
		db	 30h, 88h,0BCh,0BBh,0B0h,0BBh
		db	 08h, 80h, 08h, 88h,0CBh,0C8h
		db	0BCh,0C8h,0C8h, 88h, 88h, 88h
		db	0EEh,0BAh,0BAh,0A3h,0C0h, 80h
		db	 88h, 88h, 88h, 88h, 88h, 88h
		db	 03h,0B8h, 88h,0CBh,0FFh, 8Ch
		db	 0Fh,0CBh,0C3h,0B8h, 88h,0BFh
		db	0CCh, 8Bh, 0Ch, 88h,0BBh,0F0h
		db	 3Ch,0C8h, 88h, 08h, 08h, 88h
		db	 88h, 41h, 32h, 2Bh,0EBh,0EFh
		db	0C2h, 3Bh, 0Ah, 82h, 20h, 0Ah
		db	0EBh,0EBh,0F2h,0EBh,0EAh, 41h
		db	0F3h, 2Ah,0B3h,0BAh, 41h, 8Fh
		db	0C2h,0A2h,0A2h, 2Ah, 42h,0A2h
		db	 2Ah, 83h,0EAh,0A2h,0EAh,0BFh
		db	0EFh,0BEh, 3Ch, 11h,0FAh,0B2h
		db	 2Bh,0BEh,0AEh,0A2h, 2Eh,0FCh
		db	 11h, 03h,0C3h,0B8h, 02h, 02h
		db	 2Ah, 82h, 88h, 02h,0AEh,0ACh
		db	0BCh, 0Bh,0EEh, 20h, 11h,0A8h
		db	 41h,0EFh,0CFh,0ABh,0AEh,0E0h
		db	 8Fh, 42h,0B8h,0AEh, 41h, 8Fh
		db	 11h, 88h, 42h,0A0h, 88h, 42h
		db	 8Ch,0C8h, 41h,0BAh,0A0h,0BBh
		db	0BEh,0C0h, 11h,0CCh,0BAh, 41h
		db	0FCh, 8Fh, 41h,0ABh,0C0h, 08h
		db	 80h, 3Ch, 2Fh,0C8h,0A2h,0EAh
		db	0A0h, 22h, 0Ah, 2Eh,0BBh,0C0h
		db	 2Bh,0F8h, 28h, 20h, 28h, 3Bh
		db	0AFh,0EEh, 2Ah, 3Fh,0ABh,0F2h
		db	 2Fh,0FFh, 0Fh,0AEh,0BAh, 8Fh
		db	 0Ah, 22h, 2Ah, 11h, 0Ah, 20h
		db	 2Ah, 2Ah,0A3h, 22h, 2Ah, 3Ah
		db	 41h, 3Fh,0EFh, 11h, 20h,0EEh
		db	 3Ah, 2Ah,0AEh, 22h, 2Ah, 3Fh
		db	 02h, 20h, 11h, 03h, 02h, 33h
		db	 2Ah, 3Eh,0A2h, 88h, 88h, 8Fh
		db	0BCh, 11h,0BCh, 11h, 88h, 11h
		db	 80h,0BBh, 8Fh,0F8h, 8Ch,0CBh
		db	 8Ch, 8Bh,0F0h, 11h, 0Fh,0ABh
		db	 41h, 2Fh, 08h, 80h, 11h, 08h
		db	 88h, 88h, 12h, 8Bh, 88h, 88h
		db	 8Ch, 88h, 8Ch,0B0h, 08h, 11h
		db	0B8h,0B8h, 88h, 8Ch, 8Fh, 88h
		db	0BCh, 88h, 88h, 88h, 11h,0C8h
		db	 8Bh, 88h, 8Bh,0C0h, 22h, 2Ah
		db	 2Fh, 2Ch, 02h, 3Ch, 11h, 20h
		db	 02h, 0Ah,0E3h, 3Fh, 32h, 2Eh
		db	 3Eh,0F2h,0FCh, 12h, 0Eh,0EBh
		db	0BAh, 3Ch, 11h, 02h, 2Ah, 22h
		db	 22h, 22h, 02h, 20h, 02h, 22h
		db	 2Ah, 2Eh,0E2h, 2Fh,0C0h, 02h
		db	 20h, 32h,0FAh, 22h, 22h, 2Eh
		db	 2Ah,0EEh, 22h,0E2h, 2Ah, 20h
		db	0E2h, 22h,0EAh, 22h, 32h, 88h
		db	 88h, 38h,0B0h, 08h,0FCh, 12h
		db	 88h, 08h,0BCh,0FFh,0B8h, 88h
		db	0FFh, 8Bh, 13h, 03h,0EAh,0BAh
		db	 3Ch, 11h, 88h, 8Fh,0CBh,0C8h
		db	0F8h, 88h, 88h, 80h, 88h, 11h
		db	 8Ch,0B8h, 8Fh,0C0h, 88h, 88h
		db	 3Ch,0F8h, 88h,0BFh,0B8h, 88h
		db	0BBh, 88h,0C8h, 8Bh, 80h, 38h
		db	0FCh,0BCh, 88h,0B8h, 22h,0A2h
		db	 30h, 30h, 22h,0F2h, 20h, 22h
		db	 20h, 22h,0E2h,0F3h,0E2h,0B3h
		db	 32h, 2Ch, 11h, 02h, 11h, 23h
		db	0BBh,0BAh,0FEh, 22h, 22h,0AEh
		db	0FFh, 23h, 22h,0A2h, 22h, 20h
		db	 11h,0A0h, 02h,0A2h, 33h, 22h
		db	 20h, 11h, 2Eh,0FEh, 22h, 2Fh
		db	0F2h,0A2h, 32h,0E2h,0EAh,0E2h
		db	 20h, 32h,0C3h,0A2h, 22h, 2Eh
		db	 88h, 88h,0CCh,0B0h, 88h,0B0h
		db	 11h, 80h, 11h,0BFh, 8Fh, 8Fh
		db	0C8h,0CCh,0CBh,0B0h, 13h, 0Bh
		db	0EFh,0ABh,0ECh, 88h, 8Bh,0CBh
		db	0BCh,0FCh, 8Bh, 88h, 88h, 88h
		db	 88h, 88h, 8Ah,0B8h,0BBh, 08h
		db	 11h, 88h, 8Ch,0CFh, 88h,0CFh
		db	0BCh,0CBh,0C8h,0CAh, 41h,0E8h
		db	 88h, 0Fh, 11h,0FBh, 88h, 8Bh
		db	 22h, 20h,0E2h,0C0h, 23h,0F2h
		db	 20h, 11h, 3Fh,0E2h, 32h, 23h
		db	 20h, 0Fh, 2Eh, 30h, 20h, 11h
		db	 22h, 23h,0BFh, 41h,0EEh, 22h
		db	 20h, 3Eh,0FEh,0E3h,0ECh, 02h
		db	 22h, 22h, 22h, 22h, 22h,0AEh
		db	0E3h, 02h, 22h, 22h, 2Eh,0EFh
		db	0E3h, 23h,0ECh, 33h,0E2h, 3Ah
		db	0AFh,0A2h, 22h, 0Fh, 11h, 0Fh
		db	 22h, 23h, 88h, 88h,0C0h, 11h
		db	 8Ch, 0Ch,0C0h, 88h,0F8h, 8Bh
		db	0C0h, 88h, 83h,0F0h, 0Ch,0C0h
		db	 11h, 88h, 80h, 88h,0FBh,0EFh
		db	0ACh, 88h, 88h, 03h,0BFh, 8Ch
		db	 13h, 88h, 88h, 88h, 82h,0B8h
		db	0C0h, 12h, 88h, 8Bh,0CFh,0C3h
		db	 88h,0FCh,0CCh,0C0h,0BBh,0AEh
		db	 88h, 80h, 80h, 11h, 0Ch, 11h
		db	 88h, 22h, 20h, 32h,0C2h, 2Fh
		db	 20h, 3Eh, 03h, 22h,0FCh, 02h
data_22		db	 22h			; data table (indexed access)
		db	0FEh, 20h, 0Eh,0C2h, 02h, 20h
		db	 02h, 22h,0C8h,0EFh,0AEh, 22h
		db	 22h, 11h,0BEh, 30h, 22h, 20h
		db	 02h, 22h, 22h, 20h, 02h,0AEh
		db	0E2h, 20h, 02h, 22h, 23h, 33h
		db	0C3h, 22h,0EEh, 33h, 02h, 3Bh
		db	 41h,0A0h, 02h, 22h, 22h, 0Ch
		db	0C2h, 22h, 11h, 88h, 8Bh, 12h
		db	0FFh,0C8h, 0Fh, 3Fh,0B8h, 88h
		db	 3Fh, 11h,0A8h,0B8h,0C0h, 11h
		db	 88h, 88h, 11h,0FAh,0FAh,0B8h
		db	 12h, 88h,0ACh,0C0h, 11h, 88h
		db	 88h, 12h, 88h, 8Ah,0B3h, 11h
		db	 88h, 88h, 12h,0BBh,0CBh,0C0h
		db	0FCh,0FBh, 88h, 0Ah, 41h, 88h
		db	 88h, 12h, 03h,0C8h, 11h, 22h
		db	 30h, 30h, 02h, 22h, 03h, 3Eh
		db	 2Eh,0E2h,0C0h, 03h,0E2h, 22h
		db	 20h,0C3h, 11h, 22h, 11h, 02h
		db	 22h,0FAh, 2Ah,0B2h, 22h, 22h
		db	 11h,0EEh,0E2h, 22h, 11h, 02h
		db	 22h, 22h, 11h, 02h,0AFh, 22h
		db	 11h, 02h, 22h, 22h, 33h,0CEh
		db	 32h,0FEh,0C3h, 02h, 2Eh,0BAh
		db	 11h, 02h, 22h, 22h, 03h, 0Fh
		db	 22h, 8Bh,0C8h,0B8h, 08h, 88h
		db	 88h,0CBh, 8Fh, 8Bh, 88h,0BCh
		db	0C8h, 88h,0A8h,0CBh, 11h, 08h
		db	 88h, 88h, 88h,0CAh, 2Ah,0B8h
		db	 88h, 88h, 88h,0A8h, 88h, 88h
		db	 88h, 88h, 02h, 88h, 88h, 88h
		db	0BBh, 88h, 88h, 88h, 88h, 88h
		db	 8Fh, 8Ch,0B8h,0FBh,0CCh, 88h
		db	 8Ah,0BAh, 88h, 88h, 88h, 88h
		db	 83h,0B0h,0C8h, 02h, 2Fh,0E0h
		db	 02h, 22h, 02h,0E3h, 2Eh, 03h
		db	 22h,0E0h,0E2h, 22h,0A3h, 23h
		db	 15h,0CCh,0C2h,0C0h, 02h,0A0h
		db	 11h, 22h,0C0h, 14h, 20h, 12h
		db	0EBh, 12h, 02h,0E0h,0A0h, 0Ch
		db	0CCh, 0Fh, 0Ch, 20h, 02h, 22h
		db	0BAh, 22h,0A0h, 11h, 08h, 80h
		db	0F0h, 3Ch, 8Bh,0F8h,0C0h, 08h
		db	 88h, 08h,0B8h,0CCh, 8Ch, 8Bh
		db	 80h,0F8h, 41h, 8Bh, 8Bh, 11h
		db	 0Ah, 0Ah, 08h, 28h, 3Fh, 02h
		db	0F0h,0A0h, 11h, 88h, 3Ah, 80h
		db	 2Ah, 08h, 20h, 11h, 02h, 11h
		db	 20h,0FFh, 20h, 88h, 20h, 88h
		db	 22h, 0Fh, 32h, 20h,0BBh, 28h
		db	 88h, 0Ah,0BAh, 20h, 80h, 22h
		db	 22h, 20h,0C0h, 03h, 11h, 3Fh
		db	 11h,0A8h,0A2h, 0Ah,0B0h,0F0h
		db	 0Ch, 0Ch,0C0h, 30h, 41h, 83h
		db	 0Ch, 13h, 02h, 80h, 33h, 0Ah
		db	0B0h, 12h, 08h, 41h, 82h, 13h
		db	 22h, 11h, 22h, 11h,0CBh, 11h
		db	 82h, 08h, 80h, 20h, 03h,0F0h
		db	 88h, 3Ah, 80h, 08h, 82h,0E8h
		db	 02h, 02h, 13h,0C0h, 11h, 8Fh
		db	0C0h, 22h, 22h, 20h, 0Bh,0B8h
		db	0F8h, 8Ch, 8Ch,0C0h, 0Ch, 41h
		db	 8Ch, 8Ch, 15h, 33h, 08h,0B0h
		db	 13h, 28h,0C0h, 15h, 02h, 20h
		db	0FBh, 15h, 03h,0F0h, 11h, 0Bh
		db	 80h, 11h, 0Ah,0E8h, 11h, 20h
		db	 15h, 30h, 12h, 88h,0A0h, 2Bh
		db	0B0h, 30h, 30h, 30h,0C0h, 03h
		db	 08h, 0Ch, 0Ch, 15h, 3Ch,0CAh
		db	0B0h, 13h, 2Ah, 80h, 14h, 02h
		db	 12h,0CEh, 15h, 03h, 30h, 11h
		db	 02h, 12h, 0Ah,0E8h, 17h,0B0h
		db	 08h, 82h, 2Ah, 88h, 2Fh,0B8h
		db	0B8h,0B8h,0BBh, 11h, 03h, 88h
		db	0B8h,0B0h, 15h, 3Ch, 8Ah,0B0h
		db	 13h, 2Ah, 18h,0FEh, 16h,0C0h
		db	 11h, 02h, 12h, 0Ah,0E8h, 11h
		db	 20h, 15h,0C0h, 11h, 28h,0A8h
		db	 8Ah,0AEh,0CFh, 30h, 30h,0C2h
		db	 11h, 03h, 0Bh, 33h,0C0h, 15h
		db	 3Eh,0EAh,0C0h, 13h, 2Ah, 18h
		db	0F2h, 16h,0C0h, 14h, 0Ah,0E8h
		db	 17h,0C8h, 88h, 22h,0A2h, 8Ah
		db	0BBh,0F0h,0F8h,0CBh, 8Ah, 11h
		db	 03h, 8Bh, 8Ch, 16h, 3Bh,0E2h
		db	0C0h, 13h, 3Ah, 18h,0CEh, 16h
		db	0C0h, 14h, 0Ah,0E8h, 17h,0C0h
		db	 41h, 82h, 41h, 2Bh,0EBh, 11h
		db	 0Fh, 03h, 02h, 12h,0C3h, 0Ch
		db	 16h, 3Bh,0B2h,0C0h, 13h, 2Bh
		db	 18h,0CEh, 16h,0C0h, 14h, 0Ah
		db	0A8h, 17h, 88h,0A2h, 22h,0A2h
		db	 2Eh,0ACh, 12h,0FCh,0A8h, 12h
		db	0CBh, 8Ch, 16h, 3Bh, 82h,0C0h
		db	 13h, 22h, 18h,0EEh, 1Bh, 02h
		db	0E8h, 17h, 2Ah, 28h, 0Ah, 88h
		db	0AEh,0F0h, 12h, 0Fh, 88h, 12h
		db	0C3h, 0Ch, 16h, 30h,0E2h,0C0h
		db	 13h, 2Ah, 17h, 03h,0B3h, 1Bh
		db	 02h,0EAh, 17h, 28h, 02h,0A2h
		db	 82h,0BBh, 13h, 03h, 28h, 12h
		db	0CCh, 0Ch, 16h, 3Eh, 20h,0B0h
		db	 13h,0FAh, 17h, 03h,0CBh, 1Bh
		db	 02h, 3Ah, 17h, 02h,0A8h, 11h
		db	 41h,0BBh, 13h, 03h, 12h, 03h
		db	 0Ch, 30h, 16h, 3Eh, 8Ch,0B0h
		db	 13h, 8Bh, 17h, 03h, 23h, 1Ch
		db	 41h, 17h, 82h, 41h,0A2h, 41h
		db	0BFh, 14h,0A8h, 11h, 03h, 8Ch
		db	0B0h, 16h, 3Ch, 8Ch,0B0h, 13h
		db	0ABh, 17h, 03h, 23h, 1Bh, 02h
		db	 32h, 17h, 22h,0BFh,0A8h, 41h
		db	0ECh, 14h, 88h, 11h, 02h, 08h
		db	 30h, 16h, 33h, 2Ch,0B0h, 13h
		db	 8Ah, 17h, 03h, 23h, 1Ch, 88h
		db	 80h, 16h, 8Bh,0C8h,0F2h,0ABh
		db	0ECh, 14h,0B0h, 11h, 02h, 0Ah
		db	0A0h, 16h, 32h, 2Ch,0B0h, 13h
		db	0BBh, 17h, 03h, 23h, 1Bh, 02h
		db	 02h, 17h, 2Ch, 11h, 38h,0ABh
		db	0F0h, 13h, 02h, 28h, 11h, 02h
		db	 28h,0A0h, 16h, 3Ah,0BAh,0B0h
		db	 12h, 03h, 02h, 17h, 03h, 30h
		db	0C0h, 1Ah, 08h, 80h, 80h, 16h
		db	 2Ch, 11h, 0Ah, 2Bh,0B0h, 14h
		db	 88h, 11h, 02h, 2Ah,0A0h, 16h
		db	 3Eh,0BEh,0ACh, 12h, 02h, 30h
		db	 80h, 16h, 0Ch, 80h,0C0h, 1Ah
		db	 02h, 88h, 17h,0B0h, 11h, 08h
		db	0AFh,0B0h, 13h, 08h, 28h, 11h
		db	 03h, 2Ch, 8Ch, 16h, 0Eh,0BEh
		db	0A8h, 12h, 02h, 8Ch, 80h, 16h
		db	 0Fh, 80h,0C0h, 1Ah, 08h, 02h
		db	 20h, 16h,0B0h, 11h, 0Eh, 2Fh
		db	0B0h, 14h, 28h, 11h, 08h, 22h
		db	 88h, 16h, 0Ah,0ACh, 88h, 12h
		db	 08h, 20h, 20h, 16h, 02h, 8Ch
		db	 80h, 1Ah, 02h, 20h, 20h, 16h
		db	0B0h, 11h, 08h,0AFh,0C0h, 14h
		db	 08h, 11h, 0Ch, 08h, 28h, 16h
		db	 0Ah,0BAh, 28h, 13h, 82h, 17h
		db	 0Ah,0C8h, 80h, 1Ah, 28h, 02h
		db	 08h, 16h,0B0h, 11h, 02h, 2Eh
		db	0C0h, 13h, 08h, 02h, 12h, 0Ch
		db	 08h, 16h, 0Eh,0B8h, 88h, 12h
		db	 0Ah, 0Ah, 80h, 16h, 0Ch,0C8h
		db	0A0h, 1Ah, 28h, 20h, 82h, 16h
		db	0C0h, 11h, 08h,0AEh,0C0h, 13h
		db	 08h, 12h, 08h, 0Ch, 08h, 16h
		db	 0Eh, 3Ah, 28h, 12h, 02h, 11h
		db	 80h, 16h, 3Ah, 08h, 20h, 1Ah
		db	 80h, 11h, 08h, 20h, 15h,0C0h
		db	 11h, 22h, 2Eh,0C0h, 16h, 08h
		db	 88h, 88h, 16h, 0Ah, 08h, 88h
		db	 12h, 08h, 18h, 22h, 11h, 20h
		db	 19h, 0Ah, 19h,0C0h, 11h, 28h
		db	0BFh, 14h, 80h, 12h, 08h, 88h
		db	 02h, 16h, 0Ah, 22h, 02h, 1Bh
		db	 23h, 08h, 08h, 1Fh, 16h, 22h
		db	 3Fh, 17h, 08h, 82h, 02h, 16h
		db	 0Eh,0AEh, 82h, 1Bh,0E0h, 02h
		db	 1Eh, 28h, 17h, 08h,0BBh, 19h
		db	 80h, 80h, 15h, 08h, 41h, 02h
		db	 1Bh,0A0h, 02h, 1Eh, 0Ah, 17h
		db	 2Ah,0BFh, 17h, 02h, 02h, 20h
		db	 80h, 15h, 0Eh, 2Eh, 80h, 80h
		db	 19h, 03h, 80h, 11h, 80h, 1Dh
		db	 02h, 17h, 0Ah,0FCh, 17h, 80h
		db	 08h, 80h, 20h, 15h, 32h, 28h
		db	 80h, 1Fh, 1Fh, 15h, 3Ah,0FCh
		db	 16h, 0Ah, 08h, 02h, 08h, 0Ah
		db	 15h, 28h, 28h, 11h, 80h, 1Fh
		db	 1Fh, 14h, 32h,0FCh, 19h, 82h
		db	 16h, 28h, 32h, 02h, 1Fh, 1Fh
		db	 15h, 0Eh,0FCh, 1Fh, 11h,0E0h
		db	0E8h, 80h, 88h, 1Fh, 1Fh, 14h
		db	 0Ah,0BCh, 1Fh, 11h,0A0h, 28h
		db	 11h, 20h, 1Fh, 1Fh, 14h, 0Ah
		db	0CCh, 1Fh, 03h, 11h, 82h, 1Fh
		db	 1Fh, 16h, 08h, 30h, 1Fh, 12h
		db	 02h, 1Fh, 1Fh, 16h, 08h,0B0h
		db	 1Fh, 12h, 08h, 1Fh, 1Fh, 17h
		db	 30h, 1Fh, 11h, 20h, 1Fh, 1Fh
		db	 18h, 30h, 00h, 4Bh, 80h, 2Ah
		db	 42h, 28h, 2Ah, 42h, 28h, 4Ah
		db	 8Ah, 45h,0A8h, 8Ah, 41h,0A8h
		db	 0Ah, 42h, 20h, 42h,0A2h,0A2h
		db	 49h,0A2h, 8Ah, 42h,0A8h, 8Ah
		db	0A8h, 0Ah, 2Ah, 42h, 82h, 41h
		db	0A8h,0A2h, 42h,0A8h, 8Ah, 45h
		db	0A8h,0A8h, 41h, 0Ah,0ABh, 2Ah
		db	 42h, 11h, 22h,0B0h, 03h,0A0h
		db	 42h,0A0h, 41h,0A8h, 8Ah, 43h
		db	 2Ah, 41h,0A2h, 20h, 8Ah, 42h
		db	 0Ah, 2Ah, 11h, 41h,0CAh, 41h
		db	 3Ch, 03h,0CFh, 02h, 03h,0C0h
		db	 0Ah, 42h, 2Ah,0A2h, 80h,0A8h
		db	 41h,0A0h, 41h,0A2h, 20h, 3Fh
		db	 22h, 2Ah,0A8h,0F0h,0A0h, 80h
		db	 2Ah, 8Ah,0ACh, 11h, 20h, 32h
		db	 80h, 20h,0C8h, 0Fh, 22h, 2Ah
		db	 2Ah,0A2h, 20h,0CAh, 22h, 88h
		db	0A8h, 88h,0CFh, 11h, 0Ch, 8Ah
		db	 80h, 0Ch, 11h, 20h,0C8h, 41h
		db	 80h, 2Ah, 41h, 02h, 20h,0A0h
		db	0A2h, 20h, 0Fh, 08h, 8Ah,0A8h
		db	 41h, 0Ch, 22h, 88h, 88h,0F0h
		db	 11h, 41h, 83h, 0Bh, 02h,0ABh
		db	0EAh, 41h, 32h, 2Ah, 11h, 03h
		db	 20h, 41h, 80h, 8Ah, 41h, 88h
		db	 80h, 0Fh,0C8h,0A8h, 8Ah,0A3h
		db	0C8h,0A2h, 80h, 02h, 43h,0C2h
		db	 43h, 2Ah, 30h,0A8h, 42h, 32h
		db	 22h,0A2h, 8Ah, 32h, 41h, 22h
		db	 11h, 32h, 2Ah,0A8h, 28h, 80h
		db	0A0h,0C2h, 42h, 8Ah, 41h, 8Ah
		db	 41h, 8Ah, 2Ah, 88h, 0Ch, 43h
		db	0A8h,0FCh,0E2h, 8Ch,0A8h,0F2h
		db	 22h, 88h, 83h, 0Ah, 82h, 8Ah
		db	 22h, 22h, 41h,0A0h,0A8h, 22h
		db	 82h,0A8h, 88h, 41h,0C2h, 22h
		db	0ACh, 2Ah, 43h,0AFh, 38h, 2Ah
		db	 41h,0A3h,0C8h, 88h,0ABh, 28h
		db	0A3h, 22h, 32h, 8Ah, 41h, 0Ah
		db	 83h, 0Ah, 28h,0F2h, 22h, 2Ah
		db	0C0h,0B2h,0A3h,0EAh, 44h,0F2h
		db	 41h, 8Ah, 41h,0A3h,0F0h, 22h
		db	0C8h,0F8h, 8Fh, 0Eh, 38h, 8Ah
		db	0A0h, 2Ah,0F2h, 2Ah,0A3h, 32h
		db	 28h,0A0h,0CAh,0ABh, 2Ah, 44h
		db	0BAh, 45h,0F0h,0C2h, 42h,0B0h
		db	 20h,0E2h, 82h, 41h, 8Ch, 42h
		db	0BCh,0A2h,0A8h, 2Ah,0A8h,0EAh
		db	 45h,0A2h, 45h,0B2h, 42h,0ACh
		db	 41h, 32h, 2Ah, 41h,0A2h,0A0h
		db	 41h,0ACh, 22h, 43h,0E8h, 2Ah
		db	 4Ah, 8Ah, 44h, 8Ch, 45h,0ABh
		db	0CAh, 43h, 2Ah, 4Fh, 41h,0A2h
		db	 46h, 2Ah, 41h, 00h, 42h,0EAh
		db	0BAh, 47h, 80h, 3Eh,0BAh, 41h
		db	 28h, 2Ah, 41h,0ABh, 3Ch, 41h
		db	0FEh, 49h,0EAh,0EAh, 43h,0ABh
		db	 42h,0A8h, 0Fh,0AEh, 41h, 20h
		db	 42h,0B3h,0E2h, 41h,0ABh,0FAh
		db	 46h,0AEh,0ABh,0AFh, 41h,0ABh
		db	0BAh,0ABh,0FAh,0EAh, 42h, 83h
		db	0EEh,0A8h,0A2h, 42h,0ECh, 8Ah
		db	 42h,0AFh, 42h,0ABh,0ABh, 41h
		db	0FAh,0A8h,0ABh,0BAh, 41h,0FFh
		db	0EEh, 8Ch, 0Ch,0AFh, 42h,0A0h
		db	0FBh,0A8h, 8Ah, 42h,0EEh, 2Ah
		db	 41h,0AEh,0EFh,0BAh, 42h,0FAh
		db	0EAh, 0Fh, 41h, 0Ah,0FAh,0C3h
		db	 11h, 30h,0C2h, 11h, 30h,0FAh
		db	 42h, 3Bh,0A2h, 8Fh,0ABh,0ABh
		db	0B0h, 41h,0AEh,0EFh,0C0h,0EEh
		db	0EAh,0ABh, 0Fh,0AFh, 80h,0EAh
		db	 41h,0F3h, 11h, 20h, 0Eh, 80h
		db	 20h, 08h, 11h,0EEh,0EAh,0EFh
		db	0A2h, 20h, 3Ah,0EEh, 88h,0ABh
		db	0BBh, 30h, 11h, 33h,0BAh,0BCh
		db	 03h,0F0h, 20h, 3Bh,0ABh,0C0h
		db	 2Ah, 41h, 02h, 20h,0A0h,0A2h
		db	 20h, 30h,0FBh,0BEh,0A8h, 41h
		db	 03h,0EEh, 8Bh,0BBh, 0Ch, 11h
		db	 41h, 80h,0F8h,0C2h,0A8h, 2Ah
		db	 41h, 0Eh,0EBh, 11h, 3Ch,0EFh
		db	 41h, 80h, 8Ah, 41h, 88h, 80h
		db	 30h, 3Bh,0A8h,0BBh,0E0h, 3Bh
		db	0AEh,0BCh, 02h, 43h, 3Eh, 43h
		db	0EAh, 0Fh,0ACh, 42h,0CEh,0EEh
		db	0A2h, 8Ah,0CEh, 41h, 22h, 11h
		db	 0Eh,0EAh,0FCh, 2Bh, 8Fh,0AFh
		db	 02h, 42h,0BAh, 41h,0BAh, 41h
		db	0BAh,0EAh,0BBh, 03h,0BEh, 42h
		db	0ABh, 03h, 2Eh,0B3h,0ABh, 0Eh
		db	0EEh, 88h, 80h,0FAh,0C2h,0BAh
		db	0EEh,0EEh, 41h,0AFh,0ABh,0EEh
		db	0BEh,0ABh,0BBh, 41h, 3Eh,0EEh
		db	0A3h,0FAh, 43h,0A0h,0CBh,0EAh
		db	0EAh,0ACh, 3Bh,0BBh,0A8h,0E8h
		db	0ACh,0EEh,0CEh,0BAh, 41h,0FAh
		db	0BCh,0FAh,0EBh, 0Eh,0EEh,0EAh
		db	 3Fh, 8Eh,0ACh, 3Ah,0ABh,0EBh
		db	 42h, 0Eh, 41h,0EEh, 41h,0ACh
		db	 0Fh,0EEh, 38h, 0Bh,0B0h,0F2h
		db	0CBh,0BAh,0AFh,0EAh, 0Eh,0EAh
		db	0ACh,0CEh,0EBh,0AFh, 3Ah,0A8h
		db	0FAh, 41h,0BEh,0EBh, 41h, 8Ah
		db	0BEh,0BAh, 43h, 0Fh, 32h, 42h
		db	 8Fh,0EFh, 2Eh,0BEh, 41h,0B3h
		db	 42h, 83h,0AEh,0ABh,0EAh,0ABh
		db	 3Ah, 41h,0ABh,0FEh, 48h, 82h
		db	 42h,0A3h, 41h,0CEh,0EAh, 41h
		db	0AEh, 42h,0A3h,0EEh, 43h, 2Ah
		db	 42h,0BAh, 44h,0EEh, 43h,0BAh
		db	 41h,0BEh, 42h,0B3h, 43h,0AEh
		db	 41h,0A8h, 3Ah, 43h,0EBh, 47h
		db	0BAh, 45h,0AEh, 42h,0AEh, 46h
		db	0EAh, 41h, 00h,0FFh, 50h, 00h
		db	 0Fh,0FDh,0D4h, 00h, 00h, 35h
		db	 43h, 8Ah,0BFh,0FDh, 40h, 7Fh
		db	0FFh,0F5h, 50h, 00h, 0Fh,0FDh
		db	 50h, 00h, 0Fh,0F5h, 40h, 00h
		db	 00h,0FFh,0F5h,0DFh,0FFh,0FFh
		db	0FFh, 57h,0FFh,0FFh,0FFh, 55h
		db	0B9h,0DBh,0FFh,0FFh,0F7h,0FFh
		db	 77h, 5Fh,0FFh,0FFh,0D5h,0FDh
		db	 7Fh,0FFh, 75h, 5Dh,0FFh,0FFh
		db	0FFh,0D5h,0FFh,0FFh,0FFh, 5Fh
		db	0FFh,0DFh,0FFh,0FFh,0FDh, 7Fh
		db	0FFh,0FFh,0FFh,0FFh,0DDh, 5Fh
		db	0FDh, 55h,0FFh,0FDh,0FFh,0FFh
		db	0D7h,0FFh,0FFh,0FFh,0FFh, 55h
		db	0FFh,0FFh,0FFh,0F5h,0FFh,0F5h
		db	0FFh,0FFh, 77h,0DFh,0FFh,0DDh
		db	0D7h,0FFh, 75h,0FFh, 57h,0FFh
		db	0FFh,0FDh,0F7h,0FFh,0F5h, 7Fh
		db	0FFh,0FDh, 55h, 5Fh,0FDh,0DDh
		db	 5Fh,0FFh,0D7h,0FFh, 5Fh,0FFh
		db	0DDh, 7Fh,0FFh, 75h, 57h,0FFh
		db	 57h,0F5h, 7Fh,0FFh,0FFh,0FDh
		db	0FFh,0DFh,0F7h, 5Fh,0F5h, 55h
		db	0FFh,0FFh, 77h, 57h,0FFh,0FFh
		db	0D7h,0FFh, 57h,0FFh, 57h,0FFh
		db	0FDh, 55h, 7Fh,0D5h, 7Fh,0D7h
		db	0FFh,0FFh,0FFh,0FDh,0FDh,0DFh
		db	0FDh, 5Fh,0F5h,0FFh,0FDh,0D5h
		db	 57h,0FFh,0FDh,0DDh, 5Fh,0F7h
		db	 5Fh,0D5h, 7Fh,0FFh, 75h,0FFh
		db	0FDh, 57h,0FFh, 5Fh,0FFh,0FFh
		db	 5Fh,0F7h,0FFh,0FFh, 77h, 5Fh
		db	 57h, 77h,0D5h, 7Fh,0FFh, 77h
		db	 77h, 75h,0FDh,0DDh,0FDh,0DFh
		db	0FDh,0DDh, 0Fh,0DDh, 55h,0FFh
		db	 75h, 7Dh,0FDh,0D7h,0FDh,0D3h
		db	0DDh,0FDh,0DCh, 3Dh, 7Fh, 55h
		db	0FFh,0D5h, 55h, 55h, 55h, 4Fh
		db	 55h, 53h, 55h,0F5h, 55h, 50h
		db	0F5h, 43h,0FFh, 55h, 03h,0D5h
		db	0D7h,0FDh, 55h, 0Dh, 53h, 75h
		db	 43h,0D4h,0D5h,0FFh, 55h, 55h
		db	 50h, 55h, 54h, 35h, 55h, 4Dh
		db	 53h,0D5h, 55h, 4Fh, 54h, 3Dh
		db	 55h, 40h,0FDh, 54h,0FDh, 55h
		db	 40h,0F5h, 43h, 35h, 3Dh, 53h
		db	 54h, 55h, 55h, 55h, 0Fh,0D5h
		db	 53h,0D5h, 55h, 4Dh, 4Dh, 35h
		db	 55h, 35h, 53h,0D5h, 40h,0FFh
		db	 55h, 50h,0D5h, 50h, 3Fh, 54h
		db	 3Ch,0D4h,0D5h, 4Dh, 53h, 55h
		db	 55h, 53h,0F5h, 35h, 4Dh, 55h
		db	 55h, 4Dh, 35h, 4Dh, 54h,0D5h
		db	 4Dh, 50h,0FFh, 55h, 55h, 4Fh
		db	 55h, 0Fh,0D5h, 53h,0C3h, 53h
		db	 55h, 4Dh, 53h, 55h, 54h, 3Dh
		db	 55h, 35h, 4Dh, 55h, 55h, 75h
		db	 35h, 4Dh, 54h,0D5h, 35h, 4Fh
		db	 55h, 55h, 54h, 0Dh, 54h,0F5h
		db	 55h, 4Ch, 3Dh, 53h, 55h, 35h
		db	 4Dh, 55h, 03h,0D5h, 54h,0D5h
		db	 35h, 55h, 55h, 34h,0D5h, 35h
		db	 53h, 55h, 35h, 35h, 55h, 55h
		db	 0Fh,0FDh, 53h, 55h, 55h, 33h
		db	0D5h, 4Dh, 55h, 35h, 4Dh, 00h
		db	0FDh, 11h, 13h, 11h, 31h, 11h
		db	 11h, 30h,0D1h, 31h, 13h, 10h
		db	0D0h,0D1h, 11h, 13h,0F1h, 31h
		db	 0Dh, 11h, 10h,0CDh, 11h, 0Dh
		db	 11h, 31h, 13h,0FFh, 44h, 44h
		db	 4Ch, 44h, 34h, 44h, 44h, 34h
		db	0C4h, 34h, 43h, 44h,0C4h,0C4h
		db	 44h, 3Ch, 44h,0C4h, 4Ch, 44h
		db	 43h, 34h, 44h, 4Ch, 44h, 34h
		db	 44h, 00h, 50h, 00h, 00h, 01h
		db	 14h, 00h, 00h, 05h, 40h, 0Ah
		db	 80h, 85h, 40h, 40h, 00h, 05h
		db	 50h, 00h, 00h, 01h, 50h, 00h
		db	 00h, 05h, 40h, 00h, 00h, 02h
		db	 25h, 10h, 00h, 20h, 88h, 54h
		db	 00h, 02h, 00h, 54h, 29h, 18h
		db	 00h, 02h, 06h, 22h, 64h, 50h
		db	 0Ah,0AAh, 85h, 01h, 4Ah, 2Ah
		db	 45h, 51h, 00h, 08h, 88h, 14h
		db	 0Ah, 00h, 0Ah, 50h, 20h, 90h
		db	 22h,0A8h, 01h, 50h, 20h,0A8h
		db	 00h, 8Ah, 99h, 00h,0A9h, 40h
		db	 80h, 28h, 22h, 8Ah, 94h, 2Ah
		db	0A2h, 22h,0AAh, 50h, 0Ah,0A8h
		db	 00h,0A5h, 02h, 25h, 08h,0AAh
		db	 66h,0C0h, 82h, 99h, 90h, 2Ah
		db	 64h, 0Ah, 50h, 00h, 2Ah,0A8h
		db	 20h, 8Ah,0A5h, 0Ah,0A8h,0A9h
		db	 11h, 00h, 28h, 89h, 02h, 2Ah
		db	 94h, 0Ah, 52h,0AAh, 99h, 02h
		db	 2Ah, 65h, 50h, 8Ah, 50h,0A5h
		db	 02h,0AAh,0AAh,0A8h, 28h, 82h
		db	0A6h, 42h,0A5h, 10h, 00h, 0Ah
		db	 22h, 14h, 08h,0AAh, 90h, 2Ah
		db	 10h,0AAh, 50h, 08h,0A9h, 44h
		db	 02h, 95h, 02h, 90h, 2Ah, 80h
		db	 0Ah,0A8h, 28h, 02h,0A9h, 52h
		db	0A4h, 00h,0A8h, 84h, 50h, 00h
		db	 28h, 89h, 42h,0A2h, 02h, 94h
		db	 02h,0AAh, 24h, 00h, 29h, 40h
		db	 2Ah, 42h,0A8h, 2Ah, 02h,0A0h
		db	0AAh, 22h, 22h, 42h, 10h, 22h
		db	 80h, 40h, 00h, 02h, 22h, 20h
		db	 08h, 88h, 08h, 80h,0A8h, 88h
		db	 00h, 88h, 50h, 02h, 21h, 08h
		db	 80h, 80h, 88h, 80h, 88h, 20h
		db	 88h, 08h, 02h, 00h, 88h, 80h
		db	 00h, 00h, 00h, 0Ah, 00h, 00h
		db	 00h, 00h, 00h, 00h,0A0h, 00h
		db	 82h, 00h, 02h, 80h, 02h, 28h
		db	 00h, 08h, 00h, 20h, 02h, 80h
		db	 80h, 8Ah, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 08h, 02h, 80h
		db	 00h, 02h, 00h, 08h, 00h, 00h
		db	 88h, 00h,0A8h, 00h, 00h, 80h
		db	 02h, 20h, 08h, 02h, 00h, 00h
		db	 00h, 00h, 08h, 80h, 00h, 80h
		db	 00h, 00h, 00h, 20h, 00h, 00h
		db	 00h, 80h, 00h, 82h, 00h, 00h
		db	 80h, 00h, 02h, 00h, 08h, 80h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0A0h, 20h, 00h, 00h, 00h, 08h
		db	 20h, 08h, 00h, 00h, 00h, 00h
		db	 0Ah, 00h, 00h, 00h, 00h, 08h
		db	 80h, 00h, 82h, 00h, 00h, 08h
		db	 02h, 00h, 00h, 28h, 00h, 20h
		db	 08h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 80h, 00h, 02h, 00h, 00h
		db	 00h, 00h, 00h, 80h, 00h, 08h
		db	 08h, 02h, 00h, 00h, 00h, 00h
		db	 00h, 80h, 00h, 80h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 02h, 00h
		db	 20h, 00h, 00h, 00h, 00h, 88h
		db	 00h, 00h, 00h, 00h, 80h, 00h
		db	 00h, 00h, 08h, 00h, 88h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 20h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 02h, 20h, 20h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 20h
		db	 02h, 82h, 00h, 00h, 08h, 00h
		db	 20h, 00h, 00h, 20h, 80h, 20h
		db	 00h, 00h, 80h, 80h, 00h, 08h
		db	 00h, 80h, 08h, 00h, 02h, 20h
		db	 00h, 08h, 00h, 20h, 00h

seg_a		ends

		end	start
