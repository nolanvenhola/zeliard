
PAGE  59,132

;==========================================================================
;
;  GMTGA.BIN - Tandy Graphics Adapter 16-Color Driver (Mode 9, 320x200)
;
;  TGA variant of the graphics driver API. Uses Tandy's linear 16-color
;  framebuffer with nibble-packed pixels (2 pixels per byte).
;
;  Connections:
;    Loads:        none (pure renderer; loaded chunks fight/select read tile
;                  src buffers from driver_base + offset)
;    Calls into:   palette_xlat_jmp (CS dispatch slot for palette mode jmp),
;                  render_fn_ptr (CS dispatch slot set by caller)
;    Called by:    zeliad.exe loader (when RESOURCE.CFG selects TGA mode);
;                  game.bin invokes via gfx_call_a/b/c at game_seg:0x201C/E/2020;
;                  fight.bin/town.bin call gfx_* dispatch entries
;    Reads/writes: gvar_game_seg (FF2C) [zeliad-owned], anim_ptr_0..4
;                  (E200/E202/E206/E20A/E20C, fight-owned), font_ptr_a/b/c
;                  (F500/F502/F504, font.grp-owned)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  stdply.inc

; Tail of the small-tilemap dispatch fns: SI gets the precomputed source
; offset (from prior add ax,ds:anim_ptr_N), then call into the small
; tilemap renderer and restore DS. 4-instr tail at 4 sprite-selector
; functions.
tga_call_tile_small	MACRO
		mov	si,ax
		call	render_tilemap_small
		pop	ds
		retn
		ENDM

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
palette_state	equ	0FF01h			;*
gvar_game_seg	equ	0FF2Ch			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
anim_ptr_0	equ	0E200h			;*
anim_ptr_1	equ	0E202h			;*
anim_ptr_5	equ	0E204h			;*
anim_ptr_2	equ	0E206h			;*
anim_ptr_6	equ	0E208h			;*
anim_ptr_3	equ	0E20Ah			;*
anim_ptr_4	equ	0E20Ch			;*
tile_src_base	equ	21A7h			;*
tile_color_tbl	equ	262Eh			;*
pixel_mask_tbl	equ	2999h			;*
tile_offset_tbl	equ	2CB7h			;*
tile_color_tbl_b equ	2CB9h			;*
tile_fg_mask	equ	2E6Ch			;*
tile_bg_mask	equ	2E6Dh			;*
char_color	equ	2E6Eh			;*
char_src_ptr	equ	2E6Fh			;*
bitplane_0	equ	2E72h			;*
bitplane_1	equ	2E74h			;*
bitplane_2	equ	2E76h			;*
tga_wrap	equ	80A0h			;*
dispatch_tbl	equ	0A721h			;*
tile_col_tbl	equ	0EB22h			;*
font_ptr_a	equ	0F500h			;*
font_ptr_b	equ	0F502h			;*
font_ptr_c	equ	0F504h			;*
tga_hud_ofs	equ	41F8h
driver_base	equ	2000h			; driver loads at game_seg:2000h
tga_seg		equ	80A0h			; Tandy framebuffer segment (0x8000 area)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
plot_mode	equ	22A6h			;*
char_bit_idx	equ	2E71h			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
zero_offset	equ	0			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gmtga		proc	far

start:
		; Function dispatch table (36 CS-relative word pointers, driver loads at game_seg:2000h).
		dw	2046h			; fn  0
		dw	20F0h			; fn  1
		dw	21B7h			; fn  2
		dw	22A7h			; fn  3
		dw	22E1h			; fn  4
		dw	22B1h			; fn  5
		dw	22EBh			; fn  6
		dw	2378h			; fn  7
		dw	2386h			; fn  8
		dw	24DCh			; fn  9
		dw	24E6h			; fn 10
		dw	2503h			; fn 11
		dw	2523h			; fn 12
		dw	254Ch			; fn 13
		dw	26B0h			; fn 14
		dw	2771h			; fn 15
		dw	278Bh			; fn 16
		dw	29D9h			; fn 17
		dw	2A68h			; fn 18
		dw	2ABBh			; fn 19
		dw	2B0Fh			; fn 20
		dw	2B65h			; fn 21
		dw	2BAEh			; fn 22
		dw	2BFCh			; fn 23
		dw	25FAh			; fn 24
		dw	2591h			; fn 25
		dw	27A5h			; fn 26
		dw	27C6h			; fn 27
		dw	2394h			; fn 28
		dw	28A7h			; fn 29
		dw	28BFh			; fn 30
		dw	2C5Bh			; fn 31
		dw	2124h			; fn 32
		dw	2DC3h			; fn 33
		dw	2DF6h			; fn 34

fn_0:
		dw	0250h			; fn 35
; Dispatch mechanism: AL=fn#, BH=row, BL=col; computes TGA pixel address and branches.

dispatch_call:
		db	0FFh			; alt encoding (FF = table sentinel / dispatch prefix)
		call	bitplane_to_pixels	; compute pixel address from BH/BL ?-> AX
		mov	di,ax			; DI = pixel address
		pop	ax			; AL = function number (pushed by caller)
		or	al,al			; test fn=0?
		jz	clear_screen		; fn 0 ?-> clear screen only
		push	di			; save pixel address
		sub	cl,4			; adjust bank selector
		add	di,4000h		; add bank offset
		cmp	di,8000h		; check for TGA segment wrap
		jc	init_draw_border	; no wrap needed ?-> dispatch_wrap_done
		add	di,tga_wrap		; apply TGA wrap (80A0h)

init_draw_border:
		call	clear_screen
		pop	di
		mov	ax,0
		call	fill_horizontal_line
		mov	ax,0F00Fh
		call	fill_horizontal_line
		push	cx
		push	bx
		mov	bl,ch
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

border_row_loop:
									mov	byte ptr es:[di],0FFh
									mov	byte ptr es:[bx+di+1],0FFh
									add	di,2000h
									cmp	di,8000h
									jb	border_row_wrap		; Jump if below
									add	di,tga_wrap

border_row_wrap:
									loop	border_row_loop		; Loop if cx > 0

		pop	bx
		pop	cx
		mov	ax,0F00Fh
		call	fill_horizontal_line
		mov	ax,0

gmtga		endp

fill_horizontal_line		proc	near
		push	di
		or	es:[di],al
		inc	di
		push	cx
		mov	cl,ch
		xor	ch,ch			; Zero register
		dec	cx
		add	cx,cx
		mov	al,0FFh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		or	es:[di],ah
		pop	cx
		pop	di
		add	di,2000h
		cmp	di,8000h
		jb	fhl_wrap_done		; Jump if below
		add	di,80A0h

fhl_wrap_done:
		retn

fill_horizontal_line		endp

clear_screen		proc	near

clear_seg_init:
		mov	ax,0B800h
		mov	es,ax
		push	cx

clear_row_loop:
									push	di
									push	cx
									mov	cl,ch
									xor	ch,ch			; Zero register
									xor	ax,ax			; Zero register
									rep	stosw			; Rep when cx >0 Store ax to es:[di]
									pop	cx
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	clear_row_wrap			; Jump if below
									add	di,80A0h

clear_row_wrap:
									dec	cl
									jnz	clear_row_loop			; Jump if not zero
		pop	cx
		retn

clear_screen		endp

fn_hud_clear:					; CS:20F0 ?-- host-callable HUD clear (parallel to clear_screen); sets ES=B800h, DI=tga_hud_ofs
		mov	ax,0B800h
		mov	es,ax
		mov	di,tga_hud_ofs
		mov	cx,8

hud_clear_pass_loop:
									push	cx
									push	di
									mov	cx,12h

hud_clear_row_loop:
																push	cx
																push	di
																mov	cx,38h
																xor	ax,ax			; Zero register
																rep	stosw			; Rep when cx >0 Store ax to es:[di]
																pop	di
																add	di,140h
																pop	cx
																loop	hud_clear_row_loop		; Loop if cx > 0

									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	hud_clear_wrap			; Jump if below
									add	di,80A0h

hud_clear_wrap:
									pop	cx
									loop	hud_clear_pass_loop		; Loop if cx > 0

		retn

fn23_tile_mask:					; dispatch fn 23 (CS:2124) ?-- HUD fade-wipe: loads AND masks from tile_src_base, applies to 8 passes
		mov	ax,0B800h
		mov	es,ax
		mov	si,tile_src_base
		mov	cx,8

fn_1:

tile_mask_pass_loop:
									push	cx
									mov	di,tga_hud_ofs
									lodsw				; String [si] to ax
									push	di
									mov	cx,48h

tile_mask_row_loop_a:
																push	cx
																push	di
																mov	cx,38h

tile_mask_inner_a:
																and	es:[di],ax
																inc	di
																inc	di
																loop	tile_mask_inner_a		; Loop if cx > 0

																pop	di
																add	di,4000h
																cmp	di,8000h
																jb	tile_mask_wrap_a			; Jump if below
																add	di,80A0h

tile_mask_wrap_a:
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																pop	cx
																loop	tile_mask_row_loop_a		; Loop if cx > 0

fn_32:
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	tile_mask_wrap_b			; Jump if below
									add	di,tga_wrap

tile_mask_wrap_b:
									mov	cx,48h

tile_mask_row_loop_b:
																push	cx
																push	di
																mov	cx,38h

tile_mask_inner_b:
																and	es:[di],ax
																inc	di
																inc	di
																loop	tile_mask_inner_b		; Loop if cx > 0

																pop	di
																pop	cx
																add	di,4000h
																cmp	di,8000h
																jb	tile_mask_wrap_c			; Jump if below
																add	di,tga_wrap

tile_mask_wrap_c:
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																rol	ax,1			; Rotate
																loop	tile_mask_row_loop_b		; Loop if cx > 0

									mov	cx,3E80h

delay_loop:
																loop	delay_loop		; Loop if cx > 0

									pop	cx
									loop	tile_mask_pass_loop		; Loop if cx > 0

		retn
	; tile_mask_data: 8-entry Tandy fade table (16 bytes); tile_src_base equ points here.
; lodsw reads 8 word pairs as AND masks: full-white ?-> black fade wipe for HUD.
; First byte (0FCh) is dual-use: CLD opcode + tile_src_base[0] mask byte.

tile_mask_data:
		db	0FCh			; tile_src_base[0]  AX hi: cld opcode / mask 0FCh
		db	0FFh,0FCh,0FCh,0CCh,0FCh,0CCh
		db	0CCh,0C0h,0CCh,0C0h,0C0h, 00h
		db	0C0h, 00h, 00h		; tile_src_base[15]: mask 00h (full black)

draw_sprite_entry:
		mov	cs:plot_mode,al
		mov	ax,0B800h
		mov	es,ax
		add	bl,9Eh
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
		mov	di,ax
		mov	dl,bh
		and	bh,1
		shr	dl,1			; Shift w/zeros fill
		add	dl,18h
		xor	dh,dh			; Zero register
		add	di,dx
		mov	cl,bh
		add	cl,cl
		add	cl,cl
		mov	ax,0FF0Fh
		shr	ah,cl			; Shift w/zeros fill
		shr	al,cl			; Shift w/zeros fill
		neg	bh
		add	bh,1
		sub	ch,bh

fn_2:
		push	cx
		call	plot_pixel
		pop	cx
		inc	di
		mov	cl,ch
		shr	cl,1			; Shift w/zeros fill
		test	cl,0FFh
		jz	draw_pixel_done			; Jump if zero

draw_pixel_loop:
									push	cx
									mov	ax,0FFFFh
									call	plot_pixel
									pop	cx
									inc	di
									dec	cl
									jnz	draw_pixel_loop			; Jump if not zero

draw_pixel_done:
		and	ch,1
		jnz	draw_pixel_partial			; Jump if not zero
		retn

draw_pixel_partial:
		mov	cl,ch
		add	cl,cl
		add	cl,cl
		mov	ah,0FFh
		shr	ah,cl			; Shift w/zeros fill
		not	ah
		mov	al,ah

plot_pixel		proc	near
		test	byte ptr cs:plot_mode,0FFh
		jnz	plot_mode_check			; Jump if not zero
		push	di
		not	ah
		mov	dl,al
		and	dl,11h
		mov	cx,9

plot_pixel_loop:
									and	es:[di],ah
									or	es:[di],dl
									add	di,2000h
									cmp	di,8000h
									jb	plot_pixel_wrap			; Jump if below
									add	di,tga_wrap

plot_pixel_wrap:
									loop	plot_pixel_loop		; Loop if cx > 0

		and	es:[di],ah
		and	al,99h
		or	es:[di],al
		pop	di
		retn

plot_mode_check:
		cmp	byte ptr cs:plot_mode,80h
		je	plot_erase_mode			; Jump if equal
		push	di
		mov	ah,al
		not	ah
		and	al,77h			; 'w'
		mov	cx,0Ah

plot_and_loop:
									and	es:[di],ah
									or	es:[di],al
									add	di,2000h
									cmp	di,8000h
									jb	plot_and_wrap			; Jump if below
									add	di,tga_wrap

plot_and_wrap:
									loop	plot_and_loop		; Loop if cx > 0

		pop	di
		retn

plot_erase_mode:
		push	di
		not	al
		mov	cx,0Ah

plot_erase_loop:
									and	es:[di],al
									add	di,2000h
									cmp	di,8000h
									jb	plot_erase_wrap			; Jump if below
									add	di,80A0h

plot_erase_wrap:
									loop	plot_erase_loop		; Loop if cx > 0

		pop	di
		retn

plot_pixel		endp

; Self-modifying text-draw entry: byte 0 = plot_mode initial value (0 = normal).
; Entry A: patches [bx+792Ah] with BH (self-mod), loads char_src_ptr, jumps to common.
; Entry B: sets DI to alternate text column offset, jumps to common.

draw_text_mode_fn:
		add	byte ptr [bx+792Ah],bh	; 00 BF 2A 79  self-mod: byte 0 = plot_mode=0
		mov	bx,word ptr cs:player_hp_max	; load char position from CS:0B2h
		jmp	short draw_text_common	; ?-> common setup

draw_text_alt:
		mov	di,7B0Ah		; alternate DI offset
		jmp	short draw_text_common	; ?-> common setup

draw_text_common:
		mov	ax,0B800h		; Tandy FB segment
		mov	es,ax
		call	calc_text_width		; compute column widths ?-> AX
		push	ax			; save for draw_cols_loop

draw_cols_loop:
									or	bl,bl			; Zero ?
									jz	draw_cols_done			; Jump if zero
									push	di
									mov	bh,6
									mov	al,44h			; 'D'
									mov	ah,33h			; '3'
									call	fill_vertical_line
									dec	bl
									pop	di
									inc	di
									jmp	short draw_cols_loop

draw_cols_done:
		pop	ax
		or	al,al			; Zero ?
		jnz	draw_partial_col			; Jump if not zero
		retn

draw_partial_col:
		and	al,44h			; 'D'
		mov	ah,33h			; '3'
		mov	bh,6
		jmp	short fvl_loop

draw_text_mode_fn_b:				; self-mod entry B (CS:22E1) ?-- patches DI=792Ah from CS:[90h], mirrors draw_text_mode_fn
		mov	di,792Ah
		mov	bx,word ptr cs:player_HP
		jmp	short draw_entry_b

draw_text_alt_b:
		mov	di,7B0Ah		; alternate DI offset (entry B)
		jmp	short draw_entry_b	; EB 00 ?-> draw_entry_b

draw_entry_b:
		mov	ax,0B800h
		mov	es,ax
		call	calc_text_width
		push	ax

fn_4:
		push	bx

draw_cols_loop_b:

fn_6:
									or	bl,bl			; Zero ?
									jz	draw_cols_done_b			; Jump if zero
									push	di
									mov	bh,5
									mov	al,0AAh
									mov	ah,0FFh
									call	fill_vertical_line
									dec	bl
									pop	di
									inc	di
									jmp	short draw_cols_loop_b

draw_cols_done_b:
		pop	bx
		pop	ax
		or	al,al			; Zero ?
		jz	draw_pad_start			; Jump if zero
		push	di
		mov	bh,5
		and	al,0AAh
		mov	ah,0FFh
		call	fill_vertical_line
		pop	di
		inc	di
		inc	bl

draw_pad_start:
		mov	bh,32h			; '2'
		sub	bh,bl
		jnz	draw_pad_loop_start			; Jump if not zero
		retn

draw_pad_loop_start:
		mov	bl,bh

draw_pad_loop:
									push	di
									mov	bh,5
									xor	al,al			; Zero register
									mov	ah,44h			; 'D'
									call	fill_vertical_line
									pop	di
									inc	di
									dec	bl
									jnz	draw_pad_loop			; Jump if not zero
		retn

calc_text_width		proc	near
		mov	ax,320h
		sub	ax,bx
		jc	text_too_wide			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	cl,bl
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		and	cl,2
		add	cl,cl
		mov	al,0FFh
		shr	al,cl			; Shift w/zeros fill
		not	al
		retn

text_too_wide:
		mov	bx,32h
		xor	al,al			; Zero register
		retn

calc_text_width		endp

fill_vertical_line		proc	near

fvl_loop:
									and	es:[di],ah
									or	es:[di],al
									add	di,2000h
									cmp	di,8000h
									jb	fvl_wrap			; Jump if below
									add	di,80A0h

fvl_wrap:
									dec	bh
									jnz	fvl_loop			; Jump if not zero
		retn

fill_vertical_line		endp

text_color_mode_a:				; CS:2378 ?-- text color mode A: fg=0AAh (yellow), bg=44h (dark); falls through to text_entry_xy
		mov	byte ptr cs:tile_fg_mask,0AAh
		mov	byte ptr cs:tile_bg_mask,44h	; 'D'
		jmp	short text_entry_xy

text_color_mode_b:				; CS:2386 ?-- text color mode B: fg=0FFh (white), bg=88h (dark blue); falls through to text_entry_xy
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,88h
		jmp	short text_entry_xy

fn19_text_render:				; dispatch fn 19 (CS:2394) ?-- text render: fg=0FFh, bg=00h (transparent); bh doubled for pixel addr
		mov	byte ptr cs:tile_fg_mask,0FFh
		mov	byte ptr cs:tile_bg_mask,0
		add	bh,bh

fn_7:
		call	bitplane_to_pixels
		mov	di,ax
		mov	bl,cl
		shr	bx,1			; Shift w/zeros fill
		and	bx,1
		add	di,bx
		mov	bl,cl

fn_8:
		mov	ax,0B800h
		mov	es,ax

text_render_loop:

fn_28:
									lodsb				; String [si] to al
									or	al,al			; Zero ?
									jnz	text_render_char			; Jump if not zero
									retn

text_render_char:
									push	bx
									push	ds
									push	si
									and	bl,1
									call	render_text_char
									pop	si
									pop	ds
									pop	bx
									inc	bl
									jmp	short text_render_loop

text_entry_xy:
		lodsb				; String [si] to al
		mov	bh,al
		add	bh,bh
		lodsb				; String [si] to al
		mov	bl,al
		call	bitplane_to_pixels
		mov	di,ax
		lodsb				; String [si] to al
		mov	bl,al
		shr	ax,1			; Shift w/zeros fill
		and	ax,1
		add	di,ax
		lodsb				; String [si] to al
		xor	ch,ch			; Zero register
		mov	cl,al
		mov	ax,0B800h
		mov	es,ax

text_char_row_loop:
									push	cx
									lodsb				; String [si] to al
									push	bx
									push	ds
									push	si
									and	bl,1
									call	render_text_char
									pop	si
									pop	ds
									pop	bx
									inc	bl
									pop	cx
									loop	text_char_row_loop		; Loop if cx > 0

		retn

render_text_char		proc	near
		sub	al,20h			; ' '
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		mov	si,ax
		add	si,ds:font_ptr_c
		add	bl,bl
		add	bl,bl
		mov	cl,bl
		push	di
		mov	bl,8

char_row_loop:
		push	bx
		lodsb				; String [si] to al
		call	extract_bitplane_bit
		push	ax
		call	extract_bitplane_bit
		pop	bx
		mov	bl,ah
		mov	dh,bl
		xor	dl,dl			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	dx,cl			; Shift w/zeros fill
		mov	dh,dl
		xor	dl,dl			; Zero register
		push	bx
		push	dx
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		sbb	al,al
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		shr	dx,1			; Shift w/zeros fill
		and	al,0F0h
		or	dh,al
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:tile_bg_mask
		and	bl,ds:tile_bg_mask
		and	dh,ds:tile_bg_mask
		and	dl,ds:tile_bg_mask
		or	es:[di],bx
		or	es:[di+2],dx
		pop	dx
		pop	bx
		xchg	bh,bl
		xchg	dh,dl
		not	bx
		not	dx
		and	es:[di],bx
		and	es:[di+2],dx
		not	bx
		not	dx
		and	bh,ds:tile_fg_mask
		and	bl,ds:tile_fg_mask
		and	dh,ds:tile_fg_mask
		and	dl,ds:tile_fg_mask
		or	es:[di],bx
		or	es:[di+2],dx
		add	di,2000h
		cmp	di,8000h
		jb	char_row_wrap			; Jump if below
		add	di,80A0h

char_row_wrap:
		pop	bx
		dec	bl
		jz	char_row_done			; Jump if zero
		jmp	char_row_loop

char_row_done:
		pop	di
		inc	di
		inc	di
		cmp	cl,4
		je	char_advance_wide			; Jump if equal
		retn

char_advance_wide:
		inc	di
		retn

render_text_char		endp

extract_bitplane_bit		proc	near
		xor	ah,ah			; Zero register
		mov	dl,2

extract_bit_loop:
									add	al,al
									sbb	dh,dh
									and	dh,0Fh
									add	ah,ah
									add	ah,ah
									add	ah,ah
									add	ah,ah
									or	ah,dh
									dec	dl
									jnz	extract_bit_loop			; Jump if not zero
		retn

extract_bitplane_bit		endp

fn0_sprite_test:				; dispatch fn 0 (CS:24DC) ?-- test sprite entry: BX=0x210, AL=0, CH=0x88, then draw_sprite_entry
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,88h
		jmp	draw_sprite_entry

fn1_render_time_a:				; dispatch fn 1 (CS:24E6) ?-- render time display A: reads CS:[8Bh] timer, tilemap_src=26BBh
		push	ds
		mov	ax,word ptr cs:player_almas
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Ch
		mov	cx,105h
		mov	ax,26BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds

fn_9:
		retn

fn2_render_time_b:				; dispatch fn 2 (CS:2503) ?-- render time display B: reads CS:[86h]/CS:[85h] timer, tilemap_src=13BBh
		push	ds
		mov	ax,word ptr cs:player_gold_lo
		mov	dl,byte ptr cs:player_gold_hi
		call	init_timestamp
		push	cs

fn_10:
		pop	ds
		mov	di,258Bh
		mov	cx,106h
		mov	ax,13BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

fn3_render_time_c:				; dispatch fn 3 (CS:2523) ?-- render time display C: indexed by CS:[9Dh] frame, color LUT at CS:[0ABh], tilemap_src=37BBh
		push	ds
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:cur_weapon_idx
		dec	bl

fn_11:
		mov	al,byte ptr cs:weap_dur_cur[bx]
		xor	ah,ah			; Zero register
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Eh
		mov	cx,103h
		mov	ax,37BBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds
		retn

fn_12:

fn4_sprite_check:				; dispatch fn 4 (CS:254C) ?-- sprite visibility check: early-out if CS:[93h]==0, else render time display D (tilemap_src=3EBBh)
		test	byte ptr cs:shield_type,0FFh
		jnz	sprite_vis_check			; Jump if not zero
		retn

sprite_vis_check:
		push	ds
		mov	ax,word ptr cs:shield_HP
		xor	dx,dx			; Zero register
		call	init_timestamp
		push	cs
		pop	ds
		mov	di,258Eh
		mov	cx,103h
		mov	ax,3EBBh
		mov	bx,palette_state
		call	render_tilemap_large
		pop	ds

fn_13:
		retn

init_timestamp		proc	near
		mov	di,258Ah
		call	time_to_bcd
		mov	cx,6

timestamp_init_loop:
									test	byte ptr cs:[di],0FFh
									jz	timestamp_init_next			; Jump if zero
									retn

timestamp_init_next:
									mov	byte ptr cs:[di],0FFh
									inc	di
									loop	timestamp_init_loop		; Loop if cx > 0

		retn

init_timestamp		endp

		db	7 dup (0)

time_to_bcd		proc	near
		mov	cl,0Fh
		mov	bx,4240h
		call	modulo_divide_bcd
		mov	cs:[di],dh
		mov	cl,1
		mov	bx,86A0h
		call	modulo_divide_bcd
		mov	cs:[di+1],dh
		xor	cl,cl			; Zero register
		mov	bx,2710h
		call	modulo_divide_bcd
		mov	cs:[di+2],dh
		mov	bx,3E8h
		call	int_divide_bcd
		mov	cs:[di+3],dh
		mov	bx,64h
		call	int_divide_bcd
		mov	cs:[di+4],dh
		mov	bx,0Ah
		call	int_divide_bcd
		mov	cs:[di+5],dh
		mov	cs:[di+6],al
		retn

time_to_bcd		endp

modulo_divide_bcd		proc	near
		xor	dh,dh			; Zero register

div_loop:
									sub	dl,cl
									jc	div_done			; Jump if carry Set
									sub	ax,bx
									jnc	div_inc			; Jump if carry=0
									or	dl,dl			; Zero ?
									jz	div_adjust			; Jump if zero
									dec	dl

div_inc:
									inc	dh
									jmp	short div_loop

div_adjust:
		add	ax,bx

div_done:
		add	dl,cl
		retn

modulo_divide_bcd		endp

int_divide_bcd		proc	near
		xor	dh,dh			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		retn

int_divide_bcd		endp

render_tilemap_large		proc	near
		mov	si,di
		mov	ds:tile_bg_mask,bh
		xor	bh,bh			; Zero register
		mov	dl,ds:tile_color_tbl[bx]
		mov	ds:tile_fg_mask,dl
		mov	bx,ax
		shr	ch,1			; Shift w/zeros fill
		adc	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		xor	ch,ch			; Zero register
		mov	ax,0B800h
		mov	es,ax

tilemap_large_loop:
									push	cx
									lodsb				; String [si] to al
									push	di
									push	si
									push	ds
									call	decode_bitplane_tile
									pop	ds
									pop	si
									pop	di
									add	di,3
									pop	cx
									loop	tilemap_large_loop		; Loop if cx > 0

		retn

render_tilemap_large		endp

; Dead code ?-- no callers found.
		db	 88h,0FFh		; mov bh, bh  (alt encoding: no-op)
		int	3			; Debug breakpoint
		stosb				; Store al to es:[di]
		mov	bx,0EE99h
		db	0DDh			; padding byte (ESC/FPU opcode; not reachable)

decode_bitplane_tile		proc	near
		test	byte ptr ds:tile_bg_mask,0FFh
		jz	tile_skip_clear			; Jump if zero
		push	di
		push	cx
		mov	cx,7

tile_clear_loop:
									mov	word ptr es:[di],1111h
									mov	byte ptr es:[di+2],11h
									add	di,2000h
									cmp	di,8000h
									jb	tile_clear_wrap			; Jump if below
									add	di,80A0h

tile_clear_wrap:
									loop	tile_clear_loop		; Loop if cx > 0

		pop	cx
		pop	di

tile_skip_clear:
		cmp	al,0FFh
		jne	tile_draw_start			; Jump if not equal
		retn

tile_draw_start:
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,cs:font_ptr_b
		mov	si,ax
		push	cs
		pop	ds
		mov	cx,7

tile_draw_loop:
									lodsb				; String [si] to al
									add	al,al
									add	al,al
									call	extract_bitplane_bit
									and	ah,cs:tile_fg_mask
									or	es:[di],ah
									call	extract_bitplane_bit
									and	ah,cs:tile_fg_mask
									or	es:[di+1],ah
									call	extract_bitplane_bit
									and	ah,cs:tile_fg_mask
									or	es:[di+2],ah
									add	di,2000h
									cmp	di,8000h
									jb	tile_draw_wrap			; Jump if below
									add	di,80A0h

tile_draw_wrap:
									loop	tile_draw_loop		; Loop if cx > 0

		retn

decode_bitplane_tile		endp

fn5_sprite_large:				; dispatch fn 5 (CS:26B0) ?-- render large sprite: AL=frame, anim_ptr_0 base, 18 rows ?? 15 bytes/row, 3 bitplanes
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,10Eh
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_0
		mov	si,ax
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,12h

sprite_large_row:
		push	cx
		mov	ax,[si]
		xchg	ah,al
		mov	cs:bitplane_0,ax
		mov	ax,[si+8]
		mov	cs:bitplane_1,ax
		mov	ax,[si+0Ah]
		xchg	ah,al
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp],dh
		mov	es:[bp+1],dl
		call	extract_bitplane_pixels
		mov	es:[bp+2],dh
		mov	es:[bp+3],dl
		mov	ax,[si+2]
		xchg	ah,al
		mov	cs:bitplane_0,ax
		mov	ax,[si+6]
		mov	cs:bitplane_1,ax
		mov	ax,[si+0Ch]
		xchg	ah,al
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp+4],dh
		mov	es:[bp+5],dl
		call	extract_bitplane_pixels
		mov	es:[bp+6],dh
		mov	es:[bp+7],dl
		xor	al,al			; Zero register
		mov	ah,[si+4]
		mov	cs:bitplane_0,ax
		mov	ah,[si+5]

fn_14:
		mov	cs:bitplane_1,ax
		mov	ah,[si+0Eh]
		mov	cs:bitplane_2,ax
		call	extract_bitplane_pixels
		mov	es:[bp+8],dh
		mov	es:[bp+9],dl
		add	si,0Fh
		add	bp,2000h
		cmp	bp,8000h
		jb	sprite_large_wrap			; Jump if below
		add	bp,80A0h

sprite_large_wrap:
		pop	cx
		loop	sprite_large_next		; Loop if cx > 0

		jmp	short sprite_large_done

sprite_large_next:
		jmp	sprite_large_row

sprite_large_done:
		pop	ds
		retn

fn6_small_anim_2:				; dispatch fn 6 (CS:2771) ?-- render small anim frame: AL=frame, anim_ptr_2 base, 16 rows
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_2
		tga_call_tile_small

fn7_small_anim_1:				; dispatch fn 7 (CS:278B) ?-- render small anim frame: AL=frame, anim_ptr_1 base, 16 rows
		push	ds
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_1
		tga_call_tile_small

fn17_small_anim_4:				; dispatch fn 17 (CS:27A5) ?-- render small anim frame: AL=frame or default (SI=27E7h if AL=0), anim_ptr_4
		push	ds
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	render_small_default_a			; Jump if zero
		mov	ds,cs:gvar_game_seg
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_4
		mov	si,ax

render_small_default_a:
		call	render_tilemap_small
		pop	ds
		retn

fn18_small_anim_3:				; dispatch fn 18 (CS:27C6) ?-- render small anim frame: AL=frame or default (SI=27E7h if AL=0), anim_ptr_3
		push	ds
		mov	si,27E7h
		or	al,al			; Zero ?
		jz	render_small_default_b			; Jump if zero
		mov	ds,cs:gvar_game_seg

fn_15:
		dec	al
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = reg * ax
		add	ax,ds:anim_ptr_3
		mov	si,ax

render_small_default_b:
		call	render_tilemap_small
		pop	ds
		retn
; sprite_anim_data: 32 rows x 6 bytes = 192 bytes of Tandy 3-bitplane animation frames.

fn_16:
; Each row: [bp0_lo, bp0_hi, bp1_lo, bp1_hi, bp2_lo, bp2_hi] (3 bitplanes x 16 pixels).
; Rows come in pairs; 00 00 00 00 FC FF / FF 3F 2A AA AA A8 = frame boundary markers.
; fn20 and fn21 stubs are embedded after the data (dispatch table points into this block).

sprite_anim_data:
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row  0: frame boundary
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row  1: frame boundary
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row  2
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row  3
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row  4
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row  5
		db	 0Fh,0BBh, 8Eh, 00h, 03h, 00h	; row  6

fn_26:
		db	 00h,0C0h, 80h, 88h, 82h, 02h	; row  7
		db	 0Fh,0FBh, 8Eh, 00h, 03h, 00h	; row  8
		db	 00h,0C0h, 80h, 08h, 82h, 02h	; row  9
		db	 0Eh,0FBh, 8Eh, 00h, 03h, 00h	; row 10
		db	 00h,0C0h, 82h, 08h, 82h, 02h	; row 11
		db	 0Eh, 38h,0F8h, 00h, 03h, 00h	; row 12
		db	 00h,0C0h, 82h, 08h, 08h, 02h	; row 13
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row 14
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row 15
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row 16
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row 17
		db	 0Eh, 38h,0FBh,0F8h, 03h, 00h	; row 18
		db	 00h,0C0h, 82h, 08h, 08h, 0Ah	; row 19
		db	 0Eh, 3Bh, 83h, 80h, 03h, 00h	; row 20
		db	 00h,0C0h, 82h, 08h, 80h, 82h	; row 21
		db	 0Eh, 38h,0E3h,0C0h, 03h, 00h	; row 22

fn_27:
		db	 00h,0C0h, 82h, 08h, 20h, 02h	; row 23
		db	 0Eh, 38h, 3Bh, 80h, 03h, 00h	; row 24
		db	 00h,0C0h, 82h, 08h, 08h, 82h	; row 25
		db	 03h,0E3h,0E3h,0F8h, 03h, 00h	; row 26
		db	 00h,0C0h, 80h, 20h, 20h, 0Ah	; row 27
		db	 00h, 00h, 00h, 00h, 03h, 00h	; row 28
		db	 00h,0C0h, 80h, 00h, 00h, 02h	; row 29
		db	 00h, 00h, 00h, 00h,0FCh,0FFh	; row 30: frame boundary
		db	0FFh, 3Fh, 2Ah,0AAh,0AAh,0A8h	; row 31: frame boundary
; fn20 stub (dispatch fn 20): render anim_ptr_6 via render_tilemap_small

fn20_stub:
		push	ds
		mov	ds,word ptr cs:gvar_game_seg	; load game segment
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = al * 0C0h
		add	ax,ds:anim_ptr_6	; ax = base + anim_ptr_6 offset
		tga_call_tile_small
; fn21 stub (dispatch fn 21): render anim_ptr_5 via render_tilemap_small

fn21_stub:
		push	ds
		mov	ds,word ptr cs:gvar_game_seg	; load game segment
		xor	ah,ah			; Zero register
		mov	cx,0C0h
		mul	cx			; dx:ax = al * 0C0h
		add	ax,ds:anim_ptr_5	; ax = base + anim_ptr_5 offset
		tga_call_tile_small

render_tilemap_small		proc	near
		add	bh,bh
		call	bitplane_to_pixels
		inc	ax
		mov	bp,ax
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

tilemap_small_loop:
									push	cx

fn_29:
									mov	ax,[si]
									xchg	ah,al
									mov	cs:bitplane_0,ax
									mov	ax,[si+6]

fn_30:
									mov	cs:bitplane_1,ax
									mov	ax,[si+8]
									xchg	ah,al
									mov	cs:bitplane_2,ax
									call	extract_bitplane_pixels
									mov	es:[bp],dh
									mov	es:[bp+1],dl
									call	extract_bitplane_pixels
									mov	es:[bp+2],dh
									mov	es:[bp+3],dl
									mov	ax,[si+2]
									xchg	ah,al
									mov	cs:bitplane_0,ax
									mov	ax,[si+4]
									mov	cs:bitplane_1,ax
									mov	ax,[si+0Ah]
									xchg	ah,al
									mov	cs:bitplane_2,ax
									call	extract_bitplane_pixels
									mov	es:[bp+4],dh
									mov	es:[bp+5],dl
									call	extract_bitplane_pixels
									mov	es:[bp+6],dh
									mov	es:[bp+7],dl
									add	si,0Ch
									add	bp,2000h
									cmp	bp,8000h
									jb	tilemap_small_wrap			; Jump if below
									add	bp,80A0h

tilemap_small_wrap:
									pop	cx
									loop	tilemap_small_loop		; Loop if cx > 0

		retn

render_tilemap_small		endp

extract_bitplane_pixels		proc	near
		mov	cx,4

extract_pixels_loop:
									xor	bx,bx			; Zero register
									rol	word ptr cs:bitplane_2,1	; Rotate
									adc	bx,bx
									rol	word ptr cs:bitplane_1,1	; Rotate
									adc	bx,bx
									rol	word ptr cs:bitplane_0,1	; Rotate
									adc	bx,bx
									rol	word ptr cs:bitplane_2,1	; Rotate
									adc	bx,bx
									rol	word ptr cs:bitplane_1,1	; Rotate
									adc	bx,bx
									rol	word ptr cs:bitplane_0,1	; Rotate
									adc	bx,bx
									add	dx,dx
									add	dx,dx
									add	dx,dx
									add	dx,dx
									or	dl,cs:pixel_mask_tbl[bx]
									loop	extract_pixels_loop		; Loop if cx > 0

		retn

extract_bitplane_pixels		endp

; pixel_mask_tbl: 62-entry Tandy 4-bit color lookup table (pixel_mask_tbl equ 2999h).
; Indexed by 6-bit bitplane key (bp2<<5|bp2<<4|bp1<<3|bp1<<2|bp0<<1|bp0<<0).
; Each entry is a 4-bit nibble pixel color value for extract_bitplane_pixels.

pixel_mask_tbl_data:
		db	 00h, 07h, 04h, 02h, 03h, 01h	; indices  0- 5
		db	 08h, 05h, 07h, 0Fh, 0Ch, 0Eh	; indices  6-11
		db	 0Bh, 09h, 0Eh, 0Dh, 04h, 0Ch	; indices 12-17
		db	 0Ch, 0Eh, 07h, 05h, 06h, 0Ch	; indices 18-23
		db	 02h, 0Eh, 0Eh, 0Ah, 0Ah, 03h	; indices 24-29
		db	 0Ah, 07h, 03h, 0Bh, 07h, 0Ah	; indices 30-35
		db	 0Bh, 09h, 0Ah, 09h, 01h, 09h	; indices 36-41
		db	 05h, 03h, 09h, 09h, 07h, 05h	; indices 42-47
		db	 08h, 0Eh, 06h, 0Ah, 0Ah, 07h	; indices 48-53
		db	 0Eh, 0Ch, 05h, 0Dh, 0Ch, 07h	; indices 54-59
		db	 09h, 05h			; indices 60-61
		db	 0Ch, 0Dh			; indices 62-63 (padding to 64 entries)

render_text_char_alt		proc	near
		push	ds
		push	cs
		pop	ds
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,ah
		mov	ah,ds:tile_color_tbl[bx]
		mov	ds:tile_fg_mask,ah
		pop	bx
		xor	ah,ah			; Zero register
		sub	al,20h			; ' '
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ds:font_ptr_a
		push	ax
		mov	al,bl
		and	al,1
		mov	ds:tile_bg_mask,al
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		call	bitplane_to_pixels
		mov	di,ax
		pop	si
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

text_alt_row_loop:
									push	cx
									push	di
									lodsb				; String [si] to al
									push	ax
									mov	cl,cs:tile_bg_mask
									shr	al,cl			; Shift w/zeros fill
									call	extract_bitplane_bit
									not	ah
									and	es:[di],ah
									not	ah
									and	ah,cs:tile_fg_mask
									or	es:[di],ah
									pop	ax
									mov	cl,2
									sub	cl,cs:tile_bg_mask
									shl	al,cl			; Shift w/zeros fill
									inc	di
									mov	cx,3

text_alt_inner_loop:
																call	extract_bitplane_bit
																not	ah
																and	es:[di],ah
																not	ah
																and	ah,cs:tile_fg_mask
																or	es:[di],ah
																inc	di
																loop	text_alt_inner_loop		; Loop if cx > 0

									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	text_alt_wrap			; Jump if below
									add	di,80A0h

text_alt_wrap:
									pop	cx
									loop	text_alt_row_loop		; Loop if cx > 0

		pop	ds
		retn

render_text_char_alt		endp

fn9_sprite_copy:				; dispatch fn 9 (CS:2A68) ?-- TGA?->TGA sprite copy: BH/BL coords, CH=height, row-by-row rep movsw from src+2000h
		push	ds
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	si,di
		add	si,2000h
		cmp	si,8000h
		jb	sprite_copy_wrap			; Jump if below
		add	si,tga_wrap

sprite_copy_wrap:
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

sprite_copy_loop:
									push	cx
									push	di
									push	si
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	sprite_copy_wrap_di			; Jump if below
									add	di,tga_wrap

fn_18:

sprite_copy_wrap_di:
									add	si,2000h
									cmp	si,8000h
									jb	sprite_copy_wrap_si			; Jump if below
									add	si,tga_wrap

sprite_copy_wrap_si:
									pop	cx
									loop	sprite_copy_loop		; Loop if cx > 0

		pop	ds
		retn

fn10_sprite_save:				; dispatch fn 10 (CS:2ABB) ?-- save sprite BG: TGA framebuf ?-> CS+3000h scratch, AL=row AH=col, CH=height
		push	ds
		add	di,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	si,dx
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,0B800h
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

sprite_save_loop:
									push	cx
									push	si

fn_19:
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									add	si,2000h
									cmp	si,8000h
									jb	sprite_save_wrap			; Jump if below
									add	si,tga_wrap

sprite_save_wrap:
									pop	cx
									loop	sprite_save_loop		; Loop if cx > 0

		pop	ds
		retn

fn11_sprite_restore:				; dispatch fn 11 (CS:2B0F) ?-- restore sprite BG: CS+3000h scratch ?-> TGA framebuf, DI=src addr, AL=row AH=col, CH=height
		push	ds
		mov	si,di
		add	si,0
		mov	dh,al
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,ah
		mov	bh,0A0h
		mul	bh			; ax = reg * al
		add	dx,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	dx,bx
		mov	di,dx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ch,bh

fn_20:

sprite_restore_loop:
									push	cx
									push	di
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	sprite_restore_wrap			; Jump if below
									add	di,80A0h

sprite_restore_wrap:
									pop	cx
									loop	sprite_restore_loop		; Loop if cx > 0

		pop	ds
		retn

fn12_string_render:				; dispatch fn 12 (CS:2B65) ?-- render string: BX=char src ptr, CL=bit idx, SI=string (0xFF=end, 0x0D=newline, hi-bit=color)
		mov	cs:char_src_ptr,bx
		mov	cs:char_bit_idx,cl
		mov	byte ptr cs:char_color,1

string_char_loop:
																lodsb				; String [si] to al
																cmp	al,0FFh
																jne	string_not_eol			; Jump if not equal
																retn

string_not_eol:
																cmp	al,0Dh
																je	string_newline			; Jump if equal
																or	al,al			; Zero ?
																js	string_color_code			; Jump if sign=1
																push	cx
																push	bx
																push	si
																mov	ah,cs:char_color
																call	render_text_char_alt
																pop	si
																pop	bx
																pop	cx
																add	bx,8
																jmp	short string_char_loop

string_newline:

fn_21:
																add	byte ptr cs:char_bit_idx,8
																mov	cl,cs:char_bit_idx
																mov	bx,cs:char_src_ptr
																jmp	short string_char_loop

string_color_code:
									mov	cs:char_color,al
									jmp	short string_char_loop

tga_blit_bitplanes:
		push	ds
		push	dx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	si,ax
		pop	bx
		add	bh,bh
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		mov	bl,ch
		xor	bh,bh			; Zero register
		add	bx,bx
		xor	ch,ch			; Zero register

blit_copy_loop:
									push	cx
									push	di

fn_22:
									push	si
									mov	cx,bx
									rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
									pop	si
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	blit_wrap_di			; Jump if below
									add	di,80A0h

blit_wrap_di:
									add	si,2000h
									cmp	si,8000h
									jb	blit_wrap_si			; Jump if below
									add	si,80A0h

blit_wrap_si:
									pop	cx
									loop	blit_copy_loop		; Loop if cx > 0

		pop	ds
		retn

tga_fill_rect:
		push	bx
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	al,ds:tile_color_tbl[bx]
		sub	al,88h
		mov	ds:tile_fg_mask,al
		pop	bx
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		call	fill_rectangle
		mov	cx,10h

panel_side_loop:
									mov	al,ds:tile_fg_mask
									mov	es:[di],al
									mov	es:[di+9],al

fn_23:
									add	di,2000h
									cmp	di,8000h
									jb	panel_side_wrap			; Jump if below
									add	di,tga_wrap

panel_side_wrap:
									loop	panel_side_loop		; Loop if cx > 0

		call	fill_rectangle
		retn

fill_rectangle		proc	near
		mov	cx,2

fill_rect_loop:
									push	cx
									push	di
									mov	al,ds:tile_fg_mask
									mov	cx,0Ah
									rep	stosb			; Rep when cx >0 Store al to es:[di]
									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	fill_rect_wrap			; Jump if below
									add	di,80A0h

fill_rect_wrap:
									pop	cx
									loop	fill_rect_loop		; Loop if cx > 0

		retn

fill_rectangle		endp

render_font_ext:
		push	ds
		push	si
		push	cs
		pop	ds
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	bh,bh
		call	bitplane_to_pixels
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,ds:tile_offset_tbl[si]
		mov	si,ds:tile_color_tbl_b[si]
		mov	cx,0Dh

sprite_px_row_loop:
									push	cx
									push	di
									mov	dx,[bx]

fn_31:
									inc	bx
									inc	bx
									xchg	dh,dl
									mov	cx,8

sprite_px_inner_loop:
																add	dx,dx
																sbb	al,al
																and	al,0F0h
																add	dx,dx
																sbb	ah,ah
																and	ah,0Fh
																or	al,ah
																and	es:[di],al
																lodsb				; String [si] to al
																or	es:[di],al
																inc	di
																loop	sprite_px_inner_loop		; Loop if cx > 0

									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	sprite_px_wrap			; Jump if below
									add	di,80A0h

sprite_px_wrap:
									pop	cx
									loop	sprite_px_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

tga_sprite_row_start:
		mov	di,0F32Ch
		sub	al,0D9h
		sub	al,5Bh			; '['
		sub	ax,2FFCh
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 07h		; nibble pixel-mask pair (hi=0xF0, lo=0x07)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F0h, 0Fh		; nibble pixel-mask pair (hi=0xF0, lo=0x0F)
		db	0F2h, 2Fh,0FFh,0FFh,0FFh,0FFh
		db	0F0h, 0Fh,0E0h, 07h,0C0h, 03h
		db	0C0h, 03h, 80h, 01h, 80h, 01h
		db	 80h, 01h, 80h, 01h,0C0h, 03h
		db	0C0h, 03h,0E0h, 07h,0F0h, 0Fh
		db	0F8h, 1Fh
		db	11 dup (0)
		db	0DDh,0DCh, 00h, 00h, 00h, 00h
		db	 00h, 07h,0DFh,0F7h,0C0h, 00h
		db	 00h, 00h, 00h, 0Dh,0FFh,0F1h
		db	 54h, 00h, 00h, 00h, 00h, 75h
		db	 7Fh, 31h, 14h, 00h, 00h, 00h
		db	 00h, 74h, 11h, 91h, 1Ch, 00h
		db	 00h, 00h, 00h, 45h, 11h, 11h
		db	 1Ch, 00h, 00h, 00h, 00h, 0Ch
		db	 19h, 91h, 54h, 00h, 00h, 00h
		db	 00h, 04h, 49h, 91h,0C0h, 00h
		db	 00h, 00h, 00h, 00h, 4Ch,0CCh
		db	29 dup (0)
		db	 07h,0FFh,0FAh, 20h, 00h, 00h
		db	 00h, 00h,0FFh, 00h, 00h, 2Ah
		db	 00h, 00h, 00h, 0Fh, 70h, 7Fh
		db	 70h, 02h, 20h, 00h, 00h, 7Fh
		db	 0Fh,0F7h, 00h, 70h, 22h, 00h
		db	 00h,0F7h, 7Fh,0F0h, 00h, 07h
		db	 22h, 00h, 00h,0F0h,0F7h, 00h
		db	 44h, 00h, 0Ah, 00h, 00h,0F0h
		db	 70h, 04h, 44h, 44h, 4Ah, 00h

clear_area_entry:
		db	 00h,0F2h		; add dl, dh  (alt encoding: ADD r/m8,r8)
		jz	clear_area_row_done			; Jump if zero
		int	3			; Debug breakpoint
		db	0C4h, 7Ah, 00h		; les di, [bp+si+0]  (LES with disp8=0, alt encoding)
		db	 00h, 7Ah, 47h, 4Ch,0CCh,0C4h
		db	0F7h, 00h, 00h, 0Ah, 24h,0D7h
		db	0CCh,0C7h,0F0h, 00h, 00h, 00h
		db	0A2h, 40h, 44h, 7Fh, 00h, 00h
		db	 00h, 00h, 02h, 72h, 27h, 20h
		db	 00h
		db	9 dup (0)
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 33h
		db	0FFh,0B9h, 08h, 00h

clear_area_pass_loop:
									push	cx
									push	di
									mov	cx,19h

clear_area_row_loop:
																push	cx
																push	di
																mov	cx,50h
																xor	ax,ax			; Zero register
																rep	stosw			; Rep when cx >0 Store ax to es:[di]

clear_area_row_done:
																pop	di
																add	di,140h
																pop	cx
																loop	clear_area_row_loop		; Loop if cx > 0

									pop	di
									add	di,2000h
									cmp	di,8000h
									jb	clear_area_wrap			; Jump if below
									add	di,80A0h

clear_area_wrap:
									pop	cx

fn_33:
									loop	clear_area_pass_loop		; Loop if cx > 0

		retn

copy_from_level_seg:
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,30h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,zero_offset
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,zero_offset

sprite_decode_pass_loop:
									push	cx
									call	process_sprite_row
									pop	cx
									loop	sprite_decode_pass_loop		; Loop if cx > 0

		retn

fn_34:

process_sprite_row		proc	near
		mov	cx,8

sprite_decode_row_loop:
									push	cx
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:bitplane_0,ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:bitplane_1,ax
									lodsw				; String [si] to ax
									xchg	ah,al
									mov	cs:bitplane_2,ax
									call	extract_bitplane_pixels
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									call	extract_bitplane_pixels
									mov	ax,dx
									xchg	ah,al
									stosw				; Store ax to es:[di]
									pop	cx
									loop	sprite_decode_row_loop		; Loop if cx > 0

		retn

process_sprite_row		endp

bitplane_to_pixels		proc	near
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ax,0A0h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn

bitplane_to_pixels		endp

		db	12 dup (0)

seg_a		ends

		end	start
