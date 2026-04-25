
PAGE  59,132

;==========================================================================
;
;  313MEDA / _313MAPBT - Bosque Town Map Program (zelres3 chunk)
;
;  Map-program code module for Bosque Town (the "Vista" sub-area). Loaded
;  together with the town data file map_bosque_town.bin. Pairs with the
;  MEDA AI handler in 305EAI5.asm (jellyfish enemy controller).
;
;  Structure mirrors sibling 312ZELA (Satono Town):
;    - Header / pointer table (file 0x00..~0x100) mis-decoded by Sourcer
;    - Large embedded tile/layout data block (bulk of the file)
;    - Per-frame NPC cell scan loop (npc_scan_loop..npc_scan_done)
;    - Phase / state machine + scroll / tile-fill helpers
;    - Trailer string 'Vista' is the in-game town sub-location name
;
;  Note: "MEDA" is a prior-pass working nickname for this chunk; the
;  disassembler-stored proc name _313MAPBT is authoritative.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.
; Shared references across the 312-319 map-program family:
;   200Ch..603Ch   - game-segment dispatch callback fn ptrs
;   0C002h/0C010h  - sprite attribute / entity record base
;   0ED20h         - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Game-segment dispatch callbacks (CS-relative ptrs in game DS) ---
meda_cb_scroll		equ	200Ch		; scroll / dispatch callback
meda_cb_tile_query	equ	6028h		; tile-at-cell callback fn A
meda_cb_npc_step	equ	6036h		; NPC step / cell-iter callback fn B
meda_cb_entity_act	equ	6038h		; entity action callback fn C
meda_cb_init_tiles	equ	603Ah		; init-tile-row callback fn D
meda_cb_finalize	equ	603Ch		; finalize / jmp target fn E

; --- Internal tile/render data tables (game-seg DS, addressed by hard offset) ---
meda_tile_src_a		equ	0A5DCh		; tile source base A (passed to render_tiles)
meda_tile_src_b		equ	0A606h		; tile mask base B
meda_tile_src_c		equ	0A613h		; tile source base C
meda_tile_src_d		equ	0A623h		; tile mask base D
meda_tile_src_e_tbl	equ	0A62Eh		; tile source E (indexed table)
meda_tile_src_f		equ	0A682h		; tile mask F
meda_tile_src_g_tbl	equ	0A687h		; tile source G (indexed table)
meda_tile_src_h_tbl	equ	0A6C7h		; tile mask H (indexed table)

; --- Sprite/cell write fields (DS) ---
meda_cell_x		equ	0A6E0h		; cell write X (low byte at sprite base)
meda_cell_phase		equ	0A6E1h		; cell phase byte
meda_anim_xlat_tbl	equ	0A6EDh		; per-state animation xlat table

; --- Scroll / phase state bytes (DS) ---
meda_scroll_x		equ	0A716h		; scroll X position (word)
meda_scroll_phase	equ	0A718h		; scroll phase counter byte
meda_scroll_x_max	equ	0A719h		; scroll X max / extra (word)

; --- Sub_8 (render_tiles) parameter slots (DS) ---
meda_tile_param_row	equ	0A72Ch		; tile param: row index (passed in DS)
meda_tile_param_col	equ	0A72Dh		; tile param: col index (passed in DS)
meda_tile_param_attr	equ	0A72Eh		; tile param: attribute byte

; --- Phase / state machine bytes (DS) ---
meda_phase_dir		equ	0A72Fh		; phase direction selector
meda_phase_step		equ	0A730h		; phase step counter (mod 5)
meda_npc_idx		equ	0A731h		; NPC scan index byte
meda_anim_byte		equ	0A732h		; current animation/speaker byte
meda_idle_step		equ	0A733h		; idle step counter (0..0x28)
meda_phase_active	equ	0A734h		; phase-active flag
meda_phase_subflag	equ	0A735h		; phase sub-flag
meda_phase_locked	equ	0A736h		; phase-locked flag (clamp boundary)
meda_phase_delay	equ	0A737h		; phase delay countdown

; --- Tile/render buffer (CS-relative, written via push cs/pop es) ---
meda_render_buf		equ	0A738h		; tile render buffer base (336 bytes)

; --- Shared game-segment globals (used across map-program family) ---
gvar_proj_cnt		equ	0C002h		; sprite attribute count (shared)
enemy_attr_base		equ	0C010h		; sprite/entity record base (DS)
sprite_xlat_tbl		equ	0ED20h		; char/tile lookup table (shared)
gvar_death_flag		equ	0FF2Eh		; global death flag (shared)
gvar_dir_toggle		equ	0FF2Fh		; global dir-toggle flag
gvar_completion		equ	0FF30h		; completion/stage flag
gvar_spawn_fx_flag	equ	0FF75h		; spawn VFX flag

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_313MAPBT	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header bytes as x86 code; real entry is via
; dispatch from game DS. The far-ptr "jmp 0A7:16A1" Sourcer flagged
; is a header field word, not a real control-flow jump.
; ------------------------------------------------------------------

start:
		mov	[bx+si],cl		; header field bytes
		add	[bx+si],al		; header field bytes
;*		jmp	far ptr loc_1		;*
		db	0EAh			;  data byte (not real jmp opcode)
		dw	16A1h, 0A7h		;  header pointer words
		db	11 dup (0)
		db	32 dup (1Eh)
		db	 50h,0A0h,0A0h,0A0h,0F0h,0A0h
		db	 40h,0A1h
		db	20 dup (0)
		db	 8Bh,0A1h,0DBh,0A1h, 00h
header_tile_row_a		db	1			; Data table (indexed access)
		db	 00h, 02h, 03h, 00h, 00h, 04h
		db	 05h, 06h, 00h, 00h, 07h, 16h
		db	 09h, 00h, 08h, 0Bh, 0Ah, 0Ch
		db	 00h, 0Dh, 0Eh, 0Fh, 10h, 00h
		db	 11h, 12h, 13h, 0Ah, 00h, 14h
		db	 00h, 0Ah, 15h, 00h, 00h, 17h
		db	 18h, 19h, 00h, 1Ah, 1Bh, 1Ch
header_const_word_a		dw	0Ah
		db	 1Dh, 1Eh, 1Fh
header_text_table		db	' ', 0
		db	'!"', 0Ah, '#', 0
		db	0Ah, '$'
		db	0Ah, '%', 0
		db	'&', 0Ah, 27h, 0Ah, 0
		db	'(', 0Ah, ')', 0Ah, 0
		db	'*', 0Ah, '+', 0Ah, 0
		db	0Ah, 0Ah, 0Ah, ',', 0
		db	'-', 0
		db	0Ah, '.', 0
		db	0Ah, '/', 0Ah, '0', 0
		db	0Ah, '123', 0
		db	'4', 0
		db	'56'
		db	 00h, 00h, 00h, 37h, 38h, 00h
		db	 00h, 39h, 3Ah, 3Bh, 00h, 00h
		db	 00h
		db	3Ch
		db	'=', 0
		db	'>?@A', 0
		db	'BCDE', 0
		db	'FGHI', 0
		db	'Z[\]', 0
		db	'^_`a', 0
		db	'bcde', 0
		db	'fghi', 0
		db	'jklm', 0
		db	'nopq', 0
		db	'rstu', 0
		db	'vwxy', 0
		db	'z{|}', 0
		db	 7Eh, 7Fh, 68h, 69h, 00h, 80h
		db	 81h, 6Ch, 6Dh, 00h, 82h, 83h
		db	 70h, 71h, 00h, 72h, 84h, 85h
		db	 86h, 00h, 76h, 87h, 88h, 89h
		db	 00h, 62h, 63h, 8Ah, 8Bh, 00h
		db	 8Ch, 8Dh, 68h, 69h, 00h, 8Eh
		db	 8Fh, 6Ch, 6Dh, 00h, 90h, 91h
		db	 70h, 71h, 00h, 92h, 84h, 93h
		db	 94h, 00h, 95h, 96h, 97h, 98h
		db	 00h, 99h, 63h, 8Ah, 9Ah, 00h
		db	 9Bh, 9Ch, 68h, 69h, 00h, 9Dh
		db	 9Eh, 6Ch, 6Dh, 00h, 9Fh,0A0h
		db	 70h, 71h, 00h, 72h,0A1h,0A2h
		db	0A3h, 00h, 76h, 77h,0A4h,0A5h
		db	 00h, 62h, 63h,0A6h,0A7h, 00h
		db	0A8h,0A9h, 68h, 69h, 00h, 6Ah
		db	0AAh, 6Ch, 6Dh, 00h,0ABh,0ACh
		db	 70h, 71h, 00h, 5Ah,0ADh,0AEh
		db	0AFh, 00h,0B0h,0B1h,0B2h,0B3h
		db	 00h,0B4h, 7Bh,0B5h,0B6h, 00h
		db	0B7h,0B8h,0B9h,0BAh, 00h,0BBh
		db	0BCh, 6Ch,0BDh, 00h,0BEh,0BFh
		db	 70h, 71h, 00h, 42h, 43h, 44h
		db	0CCh, 00h, 4Ah, 4Bh, 4Ch, 4Dh
		db	 00h, 4Eh, 4Fh, 50h, 51h, 00h
		db	 52h, 53h, 54h, 55h, 00h, 56h
		db	 57h, 58h, 59h, 00h,0C0h,0C1h
		db	0C2h,0C3h, 00h,0C4h,0C5h,0C6h
		db	0C7h, 00h, 00h, 00h,0C8h,0C9h
		db	 00h, 00h, 00h,0CAh,0CBh, 00h
		db	0C0h,0C1h,0CDh,0CEh, 00h,0CFh
		db	0C5h,0C6h,0C7h, 00h,0C0h,0C1h
		db	0D0h,0D1h, 00h,0D2h,0C5h,0C6h
		db	0C7h, 00h, 00h, 00h,0C8h,0D3h
		db	 00h, 00h, 00h, 00h,0D4h, 00h
		db	0C0h,0C1h,0D5h,0D6h, 00h,0D7h
		db	0C5h,0D8h,0C7h, 00h, 00h,0D9h
		db	0DAh,0DBh, 00h,0C0h,0C1h,0C2h
		db	0DCh, 00h,0DDh,0C5h,0DEh,0C7h
		db	 8Bh, 36h, 10h,0C0h,0C6h, 06h
		db	 31h,0A7h, 00h,0C6h, 06h, 32h
		db	0A7h, 00h

npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		;  Fixup - byte match
			jz	npc_scan_done			; Jump if zero
			mov	ax,[si]
			call	word ptr cs:meda_cb_npc_step
			jc	npc_scan_next			; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:meda_cb_tile_query
			mov	bl,ds:meda_npc_idx
			xor	bh,bh			; Zero register
			mov	al,ds:sprite_xlat_tbl[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'
			jz	npc_scan_next			; Jump if zero
			test	byte ptr ds:meda_anim_byte,80h
			jnz	npc_scan_next			; Jump if not zero
			mov	al,[si+5]
			and	al,1Fh
			test	byte ptr [si+4],8
			jz	npc_scan_set_anim			; Jump if zero
			or	al,80h

npc_scan_set_anim:
			mov	ds:meda_anim_byte,al

npc_scan_next:
			inc	byte ptr ds:meda_npc_idx
			add	si,10h
			jmp	short npc_scan_loop

npc_scan_done:
		mov	si,ds:enemy_attr_base
		mov	word ptr [si],0FFFFh
		mov	al,ds:meda_anim_byte
		and	al,1Fh
		jz	post_scan_check_death			; Jump if zero
		push	ax
		call	word ptr cs:meda_cb_entity_act
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		cmp	al,1
		jne	anim_dispatch_other			; Jump if not equal
		cmp	byte ptr header_text_table+0Dh,4	; ('')
		jb	anim_dispatch_other			; Jump if below
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	byte ptr ds:gvar_spawn_fx_flag,2Dh	; '-'
		jmp	short anim_apply_scroll

anim_dispatch_other:
		mov	byte ptr ds:gvar_spawn_fx_flag,2Eh	; '.'

anim_apply_scroll:
		call	scroll_step_finalize

post_scan_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	phase_check_active			; Jump if zero
		jmp	idle_or_spawn

phase_check_active:
		test	byte ptr ds:meda_phase_active,0FFh
		jnz	phase_active_branch			; Jump if not zero
		cmp	byte ptr ds:meda_scroll_phase,7
		jne	phase_check_locked			; Jump if not equal
		mov	ax,header_const_word_a
		add	ax,10h
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	phase_clamp_b1			; Jump if carry Set
		xchg	bx,ax

phase_clamp_b1:
		mov	ax,ds:meda_scroll_x
		add	ax,4
		sub	ax,bx
		jnc	phase_check_locked			; Jump if carry=0
		mov	ax,ds:meda_scroll_x
		add	ax,6
		sub	ax,bx
		jc	phase_check_locked			; Jump if carry Set
		mov	byte ptr ds:meda_phase_subflag,3
		mov	byte ptr ds:meda_phase_active,0FFh

phase_check_locked:
		test	byte ptr ds:meda_phase_locked,0FFh
		jnz	phase_locked_branch			; Jump if not zero
		call	bound_xpos_dec
		jnc	phase_apply_xlat			; Jump if carry=0
		mov	byte ptr ds:meda_phase_locked,0FFh
		jmp	short phase_apply_xlat

phase_locked_branch:
		call	bound_xpos_inc
		jnc	phase_apply_xlat			; Jump if carry=0
		mov	byte ptr ds:meda_phase_locked,0
		jmp	short phase_apply_xlat

phase_active_branch:
		test	byte ptr ds:meda_phase_subflag,0FFh
		jz	phase_subflag_done			; Jump if zero
		dec	byte ptr ds:meda_phase_subflag
		jmp	short phase_apply_xlat

phase_subflag_done:
		test	byte ptr ds:meda_phase_active,80h
		jz	phase_inc_dir_branch			; Jump if zero
		call	phase_inc_clamped
		jnc	phase_post_dir			; Jump if carry=0
		mov	byte ptr ds:meda_phase_active,7Fh
		jmp	short phase_post_dir

phase_inc_dir_branch:
		call	phase_dec_clamped
		jnc	phase_post_dir			; Jump if carry=0
		mov	byte ptr ds:meda_phase_active,0
		jmp	short phase_post_dir

phase_apply_xlat:
		mov	bx,ds:meda_scroll_x
		sub	bx,9
		mov	al,ds:meda_anim_xlat_tbl[bx]
		mov	ds:meda_scroll_phase,al

phase_post_dir:
		call	phase_dir_compute
		test	byte ptr ds:meda_phase_delay,0FFh
		jz	phase_inc_step			; Jump if zero
		dec	byte ptr ds:meda_phase_delay
		jmp	render_tiles_entry

phase_inc_step:
		inc	byte ptr ds:meda_phase_step
		cmp	byte ptr ds:meda_phase_step,5
		jne	phase_check_step4			; Jump if not equal
		mov	byte ptr ds:meda_phase_delay,3
		mov	byte ptr ds:meda_phase_step,0

phase_check_step4:
		cmp	byte ptr ds:meda_phase_step,4
		jne	phase_step_done			; Jump if not equal
		call	phase_clear_cells

phase_step_done:
		jmp	render_tiles_entry

_313MAPBT	endp

phase_dir_compute		proc	near
		mov	ax,header_const_word_a
		add	ax,10h
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	dir_compute_clamp_b			; Jump if carry Set
		xchg	bx,ax

dir_compute_clamp_b:
		mov	ax,ds:meda_scroll_x
		inc	ax
		sub	ax,bx
		jnc	dir_compute_check_low			; Jump if carry=0
		mov	ax,ds:meda_scroll_x
		add	ax,0Ah
		sub	ax,bx
		jc	dir_compute_check_low			; Jump if carry Set
		mov	byte ptr ds:meda_phase_dir,2
		retn

dir_compute_check_low:
		mov	ax,ds:meda_scroll_x
		add	ax,0FFFAh
		sub	ax,bx
		jnc	dir_compute_check_high			; Jump if carry=0
		mov	ax,ds:meda_scroll_x
		add	ax,11h
		sub	ax,bx
		jc	dir_compute_check_high			; Jump if carry Set
		mov	ax,ds:meda_scroll_x
		add	ax,7
		inc	bx
		sub	ax,bx
		jc	dir_compute_set3			; Jump if carry Set
		mov	byte ptr ds:meda_phase_dir,1
		retn

dir_compute_set3:
		mov	byte ptr ds:meda_phase_dir,3
		retn

dir_compute_check_high:
		mov	ax,ds:meda_scroll_x
		add	ax,7
		inc	bx
		sub	ax,bx
		jc	dir_compute_set4			; Jump if carry Set
		mov	byte ptr ds:meda_phase_dir,0
		retn

dir_compute_set4:
		mov	byte ptr ds:meda_phase_dir,4
		retn

phase_dir_compute		endp

phase_clear_cells		proc	near
		mov	ax,ds:meda_scroll_x
		add	ax,6
		call	word ptr cs:meda_cb_npc_step
		jc	clear_cells_second			; Jump if carry Set
		mov	ds:meda_cell_x,bl
		mov	al,ds:meda_scroll_phase
		add	al,0Ch
		and	al,3Fh			; '?'
		mov	ds:meda_cell_phase,al
		mov	bx,0A6E0h
		call	word ptr cs:meda_cb_init_tiles

clear_cells_second:
		mov	ax,ds:meda_scroll_x
		add	ax,7
		call	word ptr cs:meda_cb_npc_step
		jnc	clear_cells_finalize			; Jump if carry=0
		retn

clear_cells_finalize:
		mov	ds:meda_cell_x,bl
		mov	al,ds:meda_scroll_phase
		add	al,0Ah
		and	al,3Fh			; '?'
		mov	ds:meda_cell_phase,al
		mov	bx,0A6E0h
		jmp	word ptr cs:meda_cb_init_tiles

phase_clear_cells		endp

phase_dec_clamped		proc	near
		dec	byte ptr ds:meda_scroll_phase
		cmp	byte ptr ds:meda_scroll_phase,7
		retn

phase_dec_clamped		endp

phase_inc_clamped		proc	near
		inc	byte ptr ds:meda_scroll_phase
		cmp	byte ptr ds:meda_scroll_phase,0Bh
		cmc				; Complement carry
		retn

phase_inc_clamped		endp

bound_xpos_inc		proc	near
		cmp	byte ptr ds:meda_scroll_x,31h	; '1'
		cmc				; Complement carry
		jnc	xpos_inc_step			; Jump if carry=0
		retn

xpos_inc_step:
		inc	byte ptr ds:meda_scroll_x
		retn

bound_xpos_inc		endp

bound_xpos_dec		proc	near
		cmp	byte ptr ds:meda_scroll_x,0Ah
		jae	xpos_dec_step			; Jump if above or =
		retn

xpos_dec_step:
		dec	byte ptr ds:meda_scroll_x
		retn

bound_xpos_dec		endp

render_tiles_main		proc	near

render_tiles_entry:
		push	cs
		pop	es
		mov	di,meda_render_buf
		mov	al,0FFh
		mov	cx,150h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr ds:meda_tile_param_row,0
		mov	byte ptr ds:meda_tile_param_col,0
		mov	si,meda_tile_src_a
		mov	bp,meda_tile_src_b
		mov	cx,0Dh
		call	render_tile_row
		mov	byte ptr ds:meda_tile_param_row,1
		mov	byte ptr ds:meda_tile_param_col,8
		mov	si,meda_tile_src_c
		mov	bp,meda_tile_src_d
		mov	cx,0Bh
		call	render_tile_row
		mov	byte ptr ds:meda_tile_param_row,4
		mov	byte ptr ds:meda_tile_param_col,3
		mov	bl,ds:meda_phase_dir
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:meda_tile_src_e_tbl[bx]
		mov	bp,meda_tile_src_f
		mov	cx,5
		call	render_tile_row
		mov	byte ptr ds:meda_tile_param_col,7
		mov	bl,ds:meda_phase_step
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:meda_tile_src_g_tbl[bx]
		mov	bp,ds:meda_tile_src_h_tbl[bx]
		mov	cx,5
		call	render_tile_row
		mov	byte ptr ds:meda_npc_idx,0
		mov	ax,ds:meda_scroll_x
		mov	di,ds:enemy_attr_base
		mov	si,meda_render_buf
		mov	cx,0Eh

render_outer_loop:
			push	cx
			push	si
			push	ax
			call	word ptr cs:meda_cb_npc_step
			pop	ax
			mov	ds:meda_tile_param_attr,bl
			jc	render_outer_advance			; Jump if carry Set
			xor	cl,cl			; Zero register

render_inner_loop:
				push	cx
				push	ax
				cmp	byte ptr [si],0FFh
				je	render_advance_si			; Jump if equal
				mov	[di],ax
				mov	al,ds:meda_scroll_phase
				add	al,cl
				and	al,3Fh			; '?'
				mov	[di+2],al
				mov	al,ds:meda_tile_param_attr
				mov	[di+3],al
				mov	al,[si]
				mov	[di+4],al
				mov	al,[si+1]
				mov	[di+6],al
				mov	byte ptr [di+5],0
				test	byte ptr ds:meda_anim_byte,0FFh
				jz	render_attr_xlat			; Jump if zero
				or	byte ptr [di+5],20h	; ' '

render_attr_xlat:
				push	di
				mov	ax,[di+2]
				call	word ptr cs:meda_cb_tile_query
				mov	bl,ds:meda_npc_idx
				xor	bh,bh			; Zero register
				mov	al,bl
				or	al,80h
				xchg	[di],al
				mov	ds:sprite_xlat_tbl[bx],al
				pop	di
				add	di,10h
				inc	byte ptr ds:meda_npc_idx

render_advance_si:
				inc	si
				inc	si
				pop	ax
				pop	cx
				inc	cl
				cmp	cl,0Ch
				jne	render_inner_loop			; Jump if not equal

render_outer_advance:
			inc	ax
			pop	si
			add	si,18h
			pop	cx
			loop	render_outer_loop		; Loop if cx > 0

		mov	word ptr [di],0FFFFh
		retn

render_tiles_main		endp

render_tile_row		proc	near
		push	cs
		pop	es
		mov	al,ds:meda_tile_param_row
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	dx,ax
		add	ax,ax
		add	ax,dx
		mov	dl,ds:meda_tile_param_col
		xor	dh,dh			; Zero register
		add	dx,dx
		add	ax,dx
		mov	di,ax
		add	di,meda_render_buf

tile_row_loop:
			push	cx
			mov	cx,8

tile_bit_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	tile_row_advance			; Jump if carry=0
				movsw				; Mov [si] to es:[di]
				dec	di
				dec	di

tile_row_advance:
				inc	di
				inc	di
				loop	tile_bit_loop		; Loop if cx > 0

			add	di,8
			inc	bp
			pop	cx
			loop	tile_row_loop		; Loop if cx > 0

		retn

render_tile_row		endp

scroll_step_finalize		proc	near
		mov	ax,ds:meda_scroll_x_max
		sub	ax,bx
		jnc	scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

scroll_clamp_zero:
		mov	ds:meda_scroll_x_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:meda_cb_scroll
		pop	ax
		or	ax,ax			; Zero ?
		jz	scroll_check_death			; Jump if zero
		retn

scroll_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	scroll_set_finalize			; Jump if zero
		retn

scroll_set_finalize:
		mov	byte ptr ds:meda_idle_step,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		jmp	word ptr cs:meda_cb_finalize

scroll_step_finalize		endp

idle_or_spawn:
		cmp	byte ptr ds:meda_idle_step,28h	; '('
		jae	completion_done			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:meda_idle_step
		cmp	byte ptr ds:meda_idle_step,14h
		jae	idle_set_dir5			; Jump if above or =
		mov	byte ptr ds:meda_phase_step,0
		call	phase_dir_compute
		call	render_tiles_main
		mov	byte ptr ds:gvar_spawn_fx_flag,23h	; '#'
		retn

idle_set_dir5:
		mov	byte ptr ds:meda_phase_dir,5
		jmp	render_tiles_entry

completion_done:
		mov	byte ptr ds:gvar_completion,0FFh
		retn
		db	 00h, 07h, 00h, 08h, 00h, 09h
		db	 00h, 00h, 00h, 02h, 00h, 0Ah
		db	 00h, 0Bh, 00h, 0Ch, 00h, 03h
		db	 01h, 07h, 00h, 04h, 00h, 05h
		db	 01h, 09h, 00h, 06h, 00h, 0Dh
		db	 00h, 0Eh, 00h, 0Fh, 00h, 01h
		db	 01h, 00h, 01h, 01h, 01h, 02h
		db	 2Ah, 80h, 55h, 00h, 41h, 00h
		db	 40h, 00h, 41h, 00h, 55h, 80h
		db	 2Ah, 01h, 03h, 01h, 04h, 0Eh
		db	 02h, 0Eh, 00h, 0Eh, 01h, 0Eh
		db	 03h, 01h, 05h, 01h, 06h,0C0h
		db	 10h, 40h, 00h, 00h, 00h, 00h
		db	 00h, 40h, 10h,0C0h, 3Ah,0A6h
		db	 46h,0A6h, 52h,0A6h, 5Eh,0A6h
		db	 6Ah,0A6h, 76h,0A6h, 01h, 0Ah
		db	 01h, 0Dh, 01h, 0Bh, 01h, 0Eh
		db	 01h, 0Ch, 01h, 0Fh, 02h, 00h
		db	 02h, 03h, 02h, 01h, 02h, 04h
		db	 02h, 02h, 02h, 05h, 02h, 06h
		db	 02h, 09h, 02h, 07h, 02h, 0Ah
		db	 02h, 08h, 02h, 0Bh, 02h, 0Ch
		db	 02h, 0Fh, 02h, 0Dh, 03h, 00h
		db	 02h, 0Eh, 03h, 01h, 03h, 02h
		db	 03h, 05h, 03h, 03h, 03h, 06h
		db	 03h, 04h, 03h, 07h, 03h, 08h
		db	 03h, 0Bh, 03h, 09h, 03h, 0Ch
		db	 03h, 0Ah, 03h, 0Dh,0A0h, 00h
		db	0A0h, 00h,0A0h, 91h,0A6h, 9Bh
		db	0A6h,0A5h,0A6h,0B1h,0A6h,0BDh
		db	0A6h, 0Eh, 06h, 0Eh, 04h, 01h
		db	 08h, 0Eh, 05h, 0Eh, 07h, 0Eh
		db	 06h, 0Eh, 08h, 03h, 0Eh, 0Eh
		db	 09h, 0Eh, 07h, 0Eh, 0Ch, 0Eh
		db	 0Ah, 0Eh, 0Dh, 01h, 08h, 0Eh
		db	 0Bh, 0Eh, 07h, 0Eh, 06h, 0Eh
		db	 0Eh, 0Fh, 00h, 01h, 08h, 0Eh
		db	 0Fh, 0Eh, 07h, 0Eh, 06h, 0Fh
		db	 01h, 01h, 08h, 0Fh, 02h, 0Eh
		db	 07h,0D1h,0A6h,0D1h,0A6h,0D6h
		db	0A6h,0DBh,0A6h,0D1h,0A6h, 10h
		db	 20h, 80h, 20h, 10h, 10h, 30h
		db	 80h, 20h, 10h, 10h, 28h, 80h
		db	 20h, 10h, 00h, 00h, 30h, 00h
		db	 32h, 06h, 50h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 0Ch, 0Bh
		db	 0Ah, 09h, 08h
		db	31 dup (7)
		db	 08h, 09h, 0Ah, 0Bh, 0Ch, 30h
		db	 00h, 0Bh,0BCh, 02h,0B8h, 0Bh
		db	 0Ch, 00h, 23h,0A7h, 20h, 03h
		db	 11h,0BBh, 02h, 05h
; 'Vista' - string literal (Bosque town sub-location / vista name)
		db	'Vista'
; trailing zero padding to round module size up
		db	348 dup (0)

seg_a		ends

		end	start
