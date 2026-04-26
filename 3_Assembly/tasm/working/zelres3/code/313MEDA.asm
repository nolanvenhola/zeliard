
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
include  zr3com.inc

; The following equates show data references outside the range of the program.
; Shared references across the 312-319 map-program family:
;   200Ch..603Ch   - game-segment dispatch callback fn ptrs
;   0C002h/0C010h  - sprite attribute / entity record base
;   0ED20h         - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Game-segment dispatch callbacks (CS-relative ptrs in game DS) ---

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
		db	11 dup (0)			; reserved / padding in header
		db	32 dup (1Eh)			; palette/colour fill descriptor (one record)
; Pointer table (4 word entries) into module (0xA0xx absolute addresses)
meda_ptr_table_a:
		db	 50h,0A0h,0A0h,0A0h,0F0h,0A0h	; ptrs[0..2]: A050, A0A0, A0F0
		db	 40h,0A1h			; ptrs[3]: A140
		db	20 dup (0)			; reserved gap (zero fill)
; second pointer pair / tail of header pointer block
meda_ptr_table_b:
		db	 8Bh,0A1h,0DBh,0A1h, 00h	; ptrs: A18B, A1DB + trailing zero
header_tile_row_a		db	1			; Data table (indexed access)
; tile/index map A - groups of 6-byte rows (cell index lookup, 00 = empty cell)
meda_tile_map_a:
		db	 00h, 02h, 03h, 00h, 00h, 04h	; row 0
		db	 05h, 06h, 00h, 00h, 07h, 16h	; row 1
		db	 09h, 00h, 08h, 0Bh, 0Ah, 0Ch	; row 2
		db	 00h, 0Dh, 0Eh, 0Fh, 10h, 00h	; row 3
		db	 11h, 12h, 13h, 0Ah, 00h, 14h	; row 4
		db	 00h, 0Ah, 15h, 00h, 00h, 17h	; row 5
		db	 18h, 19h, 00h, 1Ah, 1Bh, 1Ch	; row 6 (last row before const word)
header_const_word_a		dw	0Ah
		db	 1Dh, 1Eh, 1Fh			; row 7 trailing cells
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
; raw cell index rows continuing the index/text mapping
		db	 00h, 00h, 00h, 37h, 38h, 00h	; row continuation
		db	 00h, 39h, 3Ah, 3Bh, 00h, 00h	; row continuation
		db	 00h				; pad / row terminator
		db	3Ch				; cell index
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
; tile/index map B - 6-byte rows continuing the cell-index lookup
meda_tile_map_b:
		db	 7Eh, 7Fh, 68h, 69h, 00h, 80h	; row B0
		db	 81h, 6Ch, 6Dh, 00h, 82h, 83h	; row B1
		db	 70h, 71h, 00h, 72h, 84h, 85h	; row B2
		db	 86h, 00h, 76h, 87h, 88h, 89h	; row B3
		db	 00h, 62h, 63h, 8Ah, 8Bh, 00h	; row B4
		db	 8Ch, 8Dh, 68h, 69h, 00h, 8Eh	; row B5
		db	 8Fh, 6Ch, 6Dh, 00h, 90h, 91h	; row B6
		db	 70h, 71h, 00h, 92h, 84h, 93h	; row B7
		db	 94h, 00h, 95h, 96h, 97h, 98h	; row B8
		db	 00h, 99h, 63h, 8Ah, 9Ah, 00h	; row B9
		db	 9Bh, 9Ch, 68h, 69h, 00h, 9Dh	; row B10
		db	 9Eh, 6Ch, 6Dh, 00h, 9Fh,0A0h	; row B11
		db	 70h, 71h, 00h, 72h,0A1h,0A2h	; row B12
		db	0A3h, 00h, 76h, 77h,0A4h,0A5h	; row B13
		db	 00h, 62h, 63h,0A6h,0A7h, 00h	; row B14
		db	0A8h,0A9h, 68h, 69h, 00h, 6Ah	; row B15
		db	0AAh, 6Ch, 6Dh, 00h,0ABh,0ACh	; row B16
		db	 70h, 71h, 00h, 5Ah,0ADh,0AEh	; row B17
		db	0AFh, 00h,0B0h,0B1h,0B2h,0B3h	; row B18
		db	 00h,0B4h, 7Bh,0B5h,0B6h, 00h	; row B19
		db	0B7h,0B8h,0B9h,0BAh, 00h,0BBh	; row B20
		db	0BCh, 6Ch,0BDh, 00h,0BEh,0BFh	; row B21
		db	 70h, 71h, 00h, 42h, 43h, 44h	; row B22
		db	0CCh, 00h, 4Ah, 4Bh, 4Ch, 4Dh	; row B23
		db	 00h, 4Eh, 4Fh, 50h, 51h, 00h	; row B24
		db	 52h, 53h, 54h, 55h, 00h, 56h	; row B25
		db	 57h, 58h, 59h, 00h,0C0h,0C1h	; row B26
		db	0C2h,0C3h, 00h,0C4h,0C5h,0C6h	; row B27
		db	0C7h, 00h, 00h, 00h,0C8h,0C9h	; row B28
		db	 00h, 00h, 00h,0CAh,0CBh, 00h	; row B29
		db	0C0h,0C1h,0CDh,0CEh, 00h,0CFh	; row B30
		db	0C5h,0C6h,0C7h, 00h,0C0h,0C1h	; row B31
		db	0D0h,0D1h, 00h,0D2h,0C5h,0C6h	; row B32
		db	0C7h, 00h, 00h, 00h,0C8h,0D3h	; row B33
		db	 00h, 00h, 00h, 00h,0D4h, 00h	; row B34
		db	0C0h,0C1h,0D5h,0D6h, 00h,0D7h	; row B35
		db	0C5h,0D8h,0C7h, 00h, 00h,0D9h	; row B36
		db	0DAh,0DBh, 00h,0C0h,0C1h,0C2h	; row B37
		db	0DCh, 00h,0DDh,0C5h,0DEh,0C7h	; row B38 (last row before main_resume)
; ---- real instruction stream resumes here ----
; mov si,word ptr ds:[10C0h]; clears at meda_tile_src_e_tbl[0..1]
meda_main_resume:
		db	 8Bh, 36h, 10h,0C0h			; mov si,word ptr ds:[10C0h]  (Sourcer Fixup absolute)
		db	 0C6h, 06h, 31h,0A7h, 00h		; mov byte ptr ds:[A731h],0   (meda_npc_idx clear)
		db	 0C6h, 06h, 32h,0A7h, 00h		; mov byte ptr ds:[A732h],0   (meda_anim_byte clear)

npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		;  Fixup - byte match
			jz	npc_scan_done			; Jump if zero
			mov	ax,[si]
			call	word ptr cs:fight_cb_anim_step
			jc	npc_scan_next			; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
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
		call	word ptr cs:fight_cb_hit_check
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
		call	word ptr cs:fight_cb_anim_step
		jc	clear_cells_second			; Jump if carry Set
		mov	ds:meda_cell_x,bl
		mov	al,ds:meda_scroll_phase
		add	al,0Ch
		and	al,3Fh			; '?'
		mov	ds:meda_cell_phase,al
		mov	bx,0A6E0h
		call	word ptr cs:fight_cb_despawn

clear_cells_second:
		mov	ax,ds:meda_scroll_x
		add	ax,7
		call	word ptr cs:fight_cb_anim_step
		jnc	clear_cells_finalize			; Jump if carry=0
		retn

clear_cells_finalize:
		mov	ds:meda_cell_x,bl
		mov	al,ds:meda_scroll_phase
		add	al,0Ah
		and	al,3Fh			; '?'
		mov	ds:meda_cell_phase,al
		mov	bx,0A6E0h
		jmp	word ptr cs:fight_cb_despawn

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
			call	word ptr cs:fight_cb_anim_step
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
				call	word ptr cs:fight_cb_record_ofs
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
		call	word ptr cs:fight_cb_prep
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
		jmp	word ptr cs:fight_cb_shutdown

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
; ====================================================================
; Tile / mask render data tables (referenced by render_tiles_main / render_tile_row)
; All loaded at logical DS offsets 0xA5DC.. (game-segment 0xA000 base).
; Each "src" block holds 1bpp tile bitmasks; render_tile_row scans them
; bit-by-bit and emits 16-pixel words to the meda_render_buf.
; ====================================================================
; meda_tile_src_a (DS:0xA5DC) - tile source A: 42 bytes of cell-pair data
; (passed to render_tile_row at row=0,col=0,len=0xD)
meda_tile_src_a_data:
		db	 00h, 07h, 00h, 08h, 00h, 09h	; cell pairs A0..A2
		db	 00h, 00h, 00h, 02h, 00h, 0Ah	; cell pairs A3..A5
		db	 00h, 0Bh, 00h, 0Ch, 00h, 03h	; cell pairs A6..A8
		db	 01h, 07h, 00h, 04h, 00h, 05h	; cell pairs A9..A11
		db	 01h, 09h, 00h, 06h, 00h, 0Dh	; cell pairs A12..A14
		db	 00h, 0Eh, 00h, 0Fh, 00h, 01h	; cell pairs A15..A17
		db	 01h, 00h, 01h, 01h, 01h, 02h	; cell pairs A18..A20
; meda_tile_src_b (DS:0xA606) - tile mask B: 13 bytes (mirror-symmetric pattern)
meda_tile_src_b_data:
		db	 2Ah, 80h, 55h, 00h, 41h, 00h	; mask bits B0..B5
		db	 40h, 00h, 41h, 00h, 55h, 80h	; mask bits B6..B11 (mirror of B5..B0)
		db	 2Ah				; mask centre B12
; meda_tile_src_c (DS:0xA613) - tile source C: 16 bytes (row=1,col=8,len=0xB)
meda_tile_src_c_data:
		db	 01h, 03h, 01h, 04h, 0Eh, 02h	; cell pairs C0..C2
		db	 0Eh, 00h, 0Eh, 01h, 0Eh, 03h	; cell pairs C3..C5
		db	 01h, 05h, 01h, 06h		; cell pairs C6..C7
; meda_tile_src_d (DS:0xA623) - tile mask D: 11 bytes
meda_tile_src_d_data:
		db	0C0h, 10h, 40h, 00h, 00h, 00h	; mask bits D0..D5
		db	 00h, 00h, 40h, 10h,0C0h	; mask bits D6..D10
; meda_tile_src_e_tbl (DS:0xA62E) - 6-entry word ptr table indexed by phase_dir×2
; Entries point at 5 sub-arrays of 12-byte tile data each (per direction set)
meda_tile_src_e_tbl_data:
		db	 3Ah,0A6h, 46h,0A6h, 52h,0A6h	; ptrs[0..2]: A63A, A646, A652
		db	 5Eh,0A6h, 6Ah,0A6h, 76h,0A6h	; ptrs[3..5]: A65E, A66A, A676
; --- phase-dir tile data sets (5 × 12 bytes, pointed-to by tile_src_e_tbl) ---
meda_tile_src_e_sets:
		db	 01h, 0Ah, 01h, 0Dh, 01h, 0Bh	; set 0 (dir 0): cell pairs
		db	 01h, 0Eh, 01h, 0Ch, 01h, 0Fh	; set 0 (cont)
		db	 02h, 00h, 02h, 03h, 02h, 01h	; set 1 (dir 1): cell pairs
		db	 02h, 04h, 02h, 02h, 02h, 05h	; set 1 (cont)
		db	 02h, 06h, 02h, 09h, 02h, 07h	; set 2 (dir 2): cell pairs
		db	 02h, 0Ah, 02h, 08h, 02h, 0Bh	; set 2 (cont)
		db	 02h, 0Ch, 02h, 0Fh, 02h, 0Dh	; set 3 (dir 3): cell pairs
		db	 03h, 00h, 02h, 0Eh, 03h, 01h	; set 3 (cont)
		db	 03h, 02h, 03h, 05h, 03h, 03h	; set 4 (dir 4): cell pairs
		db	 03h, 06h, 03h, 04h, 03h, 07h	; set 4 (cont)
		db	 03h, 08h, 03h, 0Bh, 03h, 09h	; trailing/extra set
		db	 03h, 0Ch, 03h, 0Ah, 03h, 0Dh	; trailing/extra (cont)
; meda_tile_src_f (DS:0xA682) - tile mask F: 5 bytes
meda_tile_src_f_data:
		db	0A0h, 00h,0A0h, 00h,0A0h	; mask bits F0..F4
; meda_tile_src_g_tbl (DS:0xA687) - 5-entry word ptr table indexed by phase_step×2
meda_tile_src_g_tbl_data:
		db	 91h,0A6h, 9Bh,0A6h,0A5h,0A6h	; ptrs[0..2]: A691, A69B, A6A5
		db	0B1h,0A6h,0BDh,0A6h		; ptrs[3..4]: A6B1, A6BD
; --- phase-step tile data sets (pointed-to by tile_src_g_tbl) ---
meda_tile_src_g_sets:
		db	 0Eh, 06h, 0Eh, 04h, 01h, 08h	; set 0
		db	 0Eh, 05h, 0Eh, 07h, 0Eh, 06h	; set 0 (cont)
		db	 0Eh, 08h, 03h, 0Eh, 0Eh, 09h	; set 1
		db	 0Eh, 07h, 0Eh, 0Ch, 0Eh, 0Ah	; set 1 (cont)
		db	 0Eh, 0Dh, 01h, 08h, 0Eh, 0Bh	; set 2
		db	 0Eh, 07h, 0Eh, 06h, 0Eh, 0Eh	; set 2 (cont)
		db	 0Fh, 00h, 01h, 08h, 0Eh, 0Fh	; set 3
		db	 0Eh, 07h, 0Eh, 06h, 0Fh, 01h	; set 3 (cont)
		db	 01h, 08h, 0Fh, 02h, 0Eh, 07h	; set 4
; meda_tile_src_h_tbl (DS:0xA6C7) - 5-entry word ptr table indexed by phase_step×2
meda_tile_src_h_tbl_data:
		db	0D1h,0A6h,0D1h,0A6h,0D6h,0A6h	; ptrs[0..2]: A6D1, A6D1, A6D6
		db	0DBh,0A6h,0D1h,0A6h		; ptrs[3..4]: A6DB, A6D1
; --- phase-step mask data sets (pointed-to by tile_src_h_tbl) ---
meda_tile_src_h_sets:
		db	 10h, 20h, 80h, 20h, 10h, 10h	; mask set 0/1 (shared at A6D1)
		db	 30h, 80h, 20h, 10h, 10h, 28h	; mask set 2 (A6D6) + set 3 start
		db	 80h, 20h, 10h			; mask set 3 (A6DB) tail
; --- sprite/cell write fields begin here (DS:0xA6E0 = meda_cell_x) ---
meda_cell_state_init:
		db	 00h, 00h, 30h, 00h		; initial cell state (cell_x, cell_phase + spare)
		db	 32h, 06h, 50h, 00h, 00h, 00h	; anim/state init bytes
		db	 00h, 00h, 00h			; padding/state zeros
; meda_anim_xlat_tbl (DS:0xA6ED) - 5-entry phase-to-state translation table
meda_anim_xlat_tbl_data:
		db	 0Ch, 0Bh, 0Ah, 09h, 08h	; xlat[0..4] (phase → state byte)
; padding fill (31 bytes of 7) - default state for unused phase slots
		db	31 dup (7)
; meda_anim_xlat_tbl trailer / counter sequence
		db	 08h, 09h, 0Ah, 0Bh, 0Ch		; xlat trailer (mirror of head)
; trailing setup data: scroll bounds + initial state seeding for module init
meda_init_seed:
		db	 30h, 00h, 0Bh,0BCh, 02h,0B8h	; init bytes / scroll-x_max seed
		db	 0Bh, 0Ch, 00h, 23h,0A7h, 20h	; cb_npc_step setup + addr A723
		db	 03h, 11h,0BBh, 02h, 05h	; final init args
; 'Vista' - string literal (Bosque town sub-location / vista name)
		db	'Vista'
; trailing zero padding to round module size up
		db	348 dup (0)

seg_a		ends

		end	start
