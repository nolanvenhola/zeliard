
PAGE  59,132

;==========================================================================
;
;  317AKMA / _317MAPA4 - Boss 4 Arena Map Program (zelres3 chunk 17, 0-idx)
;
;  Map-program code module for the Boss 4 arena. Same structural template
;  as the 312-319 sibling map-program family (312ZELA Satono, 313MEDA
;  Bosque/Vista, 314LEGA Tarso, 315ZEL2 Helada, 316DRGN). Trailer string
;  fragment 'Alguien' is Spanish "Someone" -- dialog speaker tag for an
;  anonymous NPC in the arena.
;
;  The entry runs an NPC-scan loop over the sprite-attribute record table
;  (0C010h), walks the per-map phase state machine, and emits cell updates
;  into a render buffer at 0AA2Ah. Two helper procs scroll the view by
;  +/- 2 cells; a third packs render rows; akma_phase_step_cb is the phase callback.
;
;  Structure:
;    - Header + embedded tile/cell layout data block (~file 0x00..0x270)
;    - Main per-frame update proc (akma_main: NPC scan, phase machine,
;      death handler, render-row build)
;    - akma_scroll_dec / akma_scroll_inc helpers
;    - akma_render_col_pack helper (mul-by-13 row addressing)
;    - akma_phase_step_cb (phase callback that resets state on success)
;    - Trailer: dispatch-table data + 'Alguien' name + zero pad
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..6038h  - game-segment dispatch callback fn ptrs
;   0C002h/0C010h - sprite attribute / entity record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Game-segment dispatch callbacks (CS-relative ptrs in game DS) ---
akma_cb_scroll		equ	200Ch		; scroll / dispatch callback
akma_cb_tile_dispatch	equ	6028h		; tile-at-cell callback fn A
akma_cb_tile_at_pos	equ	6036h		; NPC step / cell-iter callback fn B
akma_cb_anim_lookup	equ	6038h		; entity action / anim-lookup callback fn C

; --- Internal per-phase tile-source tables (DS, addressed by hard offset) ---
akma_phase_si_tbl_a	equ	0A7EEh		; SI per-phase tbl A (phase-A render path)
akma_phase_di_tbl_a	equ	0A870h		; DI per-phase tbl A
akma_phase_si_tbl_b	equ	0A918h		; SI per-phase tbl B (active-mode swap)
akma_phase_si_tbl_c	equ	0A940h		; SI per-phase tbl C (mid-stage)
akma_xlat_tbl_a969	equ	0A969h		; xlat table base (active-mode alt)

; --- State / scroll (DS) ---
akma_scroll_x		equ	0AA06h		; scroll X position word
akma_scroll_x_hi	equ	0AA08h		; scroll X high byte
akma_scroll_max	equ	0AA09h		; scroll max word
akma_npc_idx		equ	0AA1Eh		; NPC scan index byte
akma_anim_byte		equ	0AA1Fh		; current animation/speaker byte
akma_phase_dir		equ	0AA20h		; phase direction byte
akma_phase_active	equ	0AA21h		; phase active flag
akma_attr_tmp		equ	0AA22h		; attribute scratch byte
akma_phase_step	equ	0AA23h		; phase step counter (mod table)
akma_phase_b_active	equ	0AA24h		; phase-B active flag
akma_phase_b_step	equ	0AA25h		; phase-B step counter
akma_phase_b_idx	equ	0AA26h		; phase-B index byte
akma_render_mode	equ	0AA27h		; render mode flag (toggles xlat table)
akma_death_step	equ	0AA28h		; death animation step counter
akma_death_subcnt	equ	0AA29h		; death sub-counter (cmp 28h / 1Eh)
akma_render_buf	equ	0AA2Ah		; render buffer base
akma_render_buf_b	equ	0AA33h		; secondary render buffer base
akma_render_buf_c	equ	0AA87h		; tertiary render buffer base

; --- Shared game-segment globals (used across map-program family) ---
akma_sprite_attr_cnt	equ	0C002h		; sprite attribute count (DS)
akma_sprite_attr_ptr	equ	0C010h		; sprite attribute record ptr (DS)
akma_sprite_xlat_tbl	equ	0ED20h		; char/tile xlat table (shared)
gvar_state_ff30	equ	0FF30h		; per-map state byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_317MAPA4	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header fields as x86 instructions; real entry
; is via dispatch from game DS. First bytes = header field words.
; The 33-byte '((((..' row is a 0x28h descriptor fill (one tile row).
; ------------------------------------------------------------------

start:
		cli				; header field byte (FA)
		or	al,[bx+si]		; header field bytes
		add	[bp+di],ch		; header field bytes
		mov	ds:akma_scroll_x,ax		; header field bytes
		db	12 dup (0)		; reserved / padding
akma_descr_row_a:				; descriptor row: 28h ('(') with 50h ('P') in slot 7
		db	'((((((P((((((((((((((((((((((((('	; descriptor bytes
		db	'~'				; row terminator

akma_ptr_tbl_a:					; word ptr table A: 7 entries into A0xx..A2xx data
		db	0A0h,0E2h,0A0h, 78h,0A1h, 0Eh	; ptrs[0..2]: A0E2,A078,A10E (LE)
		db	0A2h, 54h,0A2h, 9Fh,0A2h,0B3h	; ptrs[3..5]: ...A254,A29F,A2B3
		db	0A2h				; ptr trailing byte
		db	50 dup (0)			; reserved padding tail

akma_ptr_tbl_b:					; word ptr table B: 6 entries into A0xx..A2xx data
		db	0B0h,0A0h, 2Dh,0A1h,0C3h,0A1h	; ptrs[0..2]: A0B0,A12D,A1C3
		db	 31h,0A2h, 77h,0A2h,0A9h,0A2h	; ptrs[3..5]: A231,A277,A2A9
akma_data_word_a		dw	0A2EFh
		db	0				; ptr terminator
akma_data_byte_b		db	0

akma_cell_map_a:				; tile/cell run-list (00h-separated rows)
		db	 02h, 03h, 04h, 00h, 05h, 06h	; tile cell run
		db	 07h, 08h, 00h, 09h, 0Ah, 0Dh	; tile cell run
		db	 0Eh, 00h, 0Bh, 0Ch, 0Fh, 10h	; tile cell run
		db	 00h, 0Fh, 10h, 11h,0BDh, 00h	; tile cell run
		db	0F3h, 00h,0BBh,0F4h, 00h	; tile cell run
akma_data_byte_c		db	0BBh
		db	0F4h,0BEh,0BFh, 00h,0F4h,0BCh	; tile cell run
		db	0BFh,0C0h, 00h,0BBh, 5Ah,0BEh	; tile cell run
		db	0BFh, 00h, 5Ah, 5Bh,0BFh,0C0h	; tile cell run
		db	 00h, 12h, 00h, 15h, 16h, 00h	; tile cell run
		db	 13h, 14h, 17h, 18h, 00h, 1Ch	; tile cell run
		db	 1Dh, 20h, 21h, 00h, 1Ah, 1Bh	; tile cell run
		db	 1Eh, 1Fh, 00h, 1Eh, 1Fh,0C6h	; tile cell run
		db	 22h, 00h, 00h,0F5h,0F6h,0C2h	; tile cell run
		db	 00h,0F6h,0C2h,0C4h,0C5h, 00h	; tile cell run
		db	0C1h,0F6h,0C3h,0C4h, 00h,0A6h	; tile cell run
		db	0A7h,0C3h,0C4h, 00h,0A7h,0C2h	; tile cell run
		db	0C4h,0C5h, 00h, 00h, 35h, 3Ch	; tile cell run
		db	 3Dh, 00h, 3Dh, 3Eh, 41h, 42h	; tile cell run
		db	 00h, 31h, 32h, 35h, 36h, 00h	; tile cell run
		db	 00h, 2Ah, 2Eh, 23h, 00h, 24h	; tile cell run
		db	 25h, 2Ah, 00h, 00h, 00h	; tile cell run
		db	',/-', 0
		db	'3#78', 0
		db	'##C#', 0
		db	'DEFG', 0
		db	'&', 27h, '-#', 0
		db	'####', 0
		db	'9:#@', 0
		db	'#@@'

akma_cell_map_b:				; tile/cell run-list (continued)
		db	 00h, 00h, 00h, 29h, 27h, 28h	; tile cell run
		db	 00h, 23h, 00h, 3Ah, 3Bh, 00h	; tile cell run
		db	 71h, 00h, 00h, 73h, 00h, 73h	; tile cell run
		db	 74h, 77h, 78h, 00h, 77h, 70h	; tile cell run
		db	 77h, 70h, 00h, 82h, 83h, 88h	; tile cell run
		db	 70h, 00h, 88h, 70h, 00h, 88h	; tile cell run
		db	 00h, 00h, 77h, 81h, 82h, 00h	; tile cell run
		db	 79h, 7Ah, 78h, 79h, 00h, 70h	; tile cell run
		db	 78h, 84h, 85h, 00h, 70h, 70h	; tile cell run
		db	 70h, 8Ch, 00h, 8Fh, 90h, 91h	; tile cell run
		db	 92h, 00h, 75h, 76h, 7Ah, 7Bh	; tile cell run
		db	 00h, 7Bh, 00h, 7Ch, 7Dh, 00h	; tile cell run
		db	 7Fh, 80h, 86h, 87h, 00h, 89h	; tile cell run
		db	 8Ah, 8Dh, 8Eh, 00h, 87h, 00h	; tile cell run
		db	 8Ah, 8Bh, 00h, 00h, 00h, 48h	; tile cell run
		db	 49h, 00h, 00h, 00h, 00h, 4Bh	; tile cell run
		db	 00h				; tile cell run terminator
		db	'NOST', 0
		db	'LMPQ', 0
		db	'U#WX', 0
		db	'R', 0
		db	'#V', 0
		db	'#Y[Y', 0
		db	'K^gh', 0
		db	'_`i#', 0
		db	'DnF'

akma_cell_map_c:				; tile/cell run-list (continued)
		db	 47h, 00h, 00h, 00h, 4Bh, 4Ch	; tile cell run
		db	 00h, 61h, 62h, 23h, 6Bh, 00h	; tile cell run
		db	 00h, 00h, 4Ch, 4Dh, 00h, 63h	; tile cell run
		db	 64h, 6Ch, 6Dh, 00h, 00h, 00h	; tile cell run
		db	 65h, 66h, 00h, 00h, 98h, 00h	; tile cell run
		db	 9Dh, 00h,0A2h, 70h,0A2h,0A6h	; tile cell run
		db	 00h, 4Bh, 4Ch, 99h, 9Ah, 00h	; tile cell run
		db	 9Eh, 9Fh,0A3h,0A4h, 00h, 00h	; tile cell run
		db	 00h, 4Dh, 00h, 00h, 9Bh, 9Ch	; tile cell run
		db	0A0h,0A1h, 00h, 00h, 00h, 4Bh	; tile cell run
		db	 97h, 00h,0B1h,0B2h,0B8h,0B9h	; tile cell run
		db	 00h,0AFh,0B0h, 70h,0B7h, 00h	; tile cell run
		db	 8Fh, 90h, 91h, 92h, 00h, 00h	; tile cell run
		db	 00h, 4Ch, 4Dh, 00h,0ADh,0AEh	; tile cell run
		db	0B5h, 70h, 00h, 00h, 00h, 4Bh	; tile cell run
		db	 4Ch, 00h,0ABh,0ACh,0B3h,0B4h	; tile cell run
		db	 00h, 00h, 00h,0A9h,0AAh, 00h	; tile cell run
		db	0CBh,0CCh,0CDh,0CEh, 00h, 00h	; tile cell run
		db	0C9h,0CFh,0D0h, 00h,0C7h,0C8h	; tile cell run
		db	0C9h,0CAh, 00h,0D2h, 00h,0D4h	; tile cell run
		db	0D5h, 00h,0D4h,0D5h,0D6h,0D7h	; tile cell run
		db	 00h,0D5h,0C9h,0D7h,0D0h, 00h	; tile cell run
		db	0C7h,0C8h,0C9h,0CAh, 00h,0D8h	; tile cell run
		db	0D9h,0DAh,0DBh, 00h,0DBh, 00h	; tile cell run
		db	0DDh,0DEh, 00h,0E1h,0E2h,0DFh	; tile cell run
		db	0E0h, 00h,0D8h,0D9h,0DAh,0DBh	; tile cell run
		db	 00h,0E3h,0E4h,0E5h,0E6h, 00h	; tile cell run
		db	0DBh,0E5h,0DDh,0E7h, 00h,0E5h	; tile cell run
		db	0E6h				; tile cell run trailing byte

akma_unk_handler_2:
			out	0E8h,ax			; port 0E8h ??I/O Non-standard
			add	[bx+di],al
			jmpn	akma_unk_handler_3

akma_unk_handler_3:
;*		add	cl,ch
			db	 00h,0E9h		;  Fixup - byte match
;*		jmp	far ptr loc_1		;*
			db	0EAh			;  Fixup - byte match (jmp far prefix)
			dw	0, 100h			;  Fixup - byte match
			jmp	short $+2		; delay for I/O
			add	[bx+si],al
			jmp	short akma_unk_handler_2

akma_cell_map_d:				; tile/cell run-list (continued, EBh/F0h tile range)
		db	 00h,0EDh, 00h, 01h,0EBh,0F8h	; tile cell run
		db	0F7h, 00h, 01h,0EBh, 00h,0FAh	; tile cell run
		db	 00h, 01h,0EBh, 00h,0FCh, 00h	; tile cell run
		db	0EEh,0EFh, 00h, 00h, 00h,0EFh	; tile cell run
		db	 19h, 00h, 00h, 00h,0F0h,0F1h	; tile cell run
		db	0F2h, 00h, 00h,0F1h, 19h, 00h	; tile cell run
		db	 00h, 00h,0F0h,0F1h,0F2h, 4Ah	; tile cell run
		db	 00h,0F0h,0F1h,0F2h, 34h, 00h	; tile cell run
		db	0F0h,0F1h,0F2h,0FFh, 00h,0F1h	; tile cell run
		db	 19h, 4Ah, 5Ch, 00h, 00h, 6Fh	; tile cell run
		db	 6Ah, 93h, 00h, 72h, 7Eh, 94h	; tile cell run
		db	 95h, 00h, 96h,0A5h,0B6h,0BAh	; tile cell run
		db	 00h,0A8h, 00h,0D1h,0D3h, 00h	; tile cell run

akma_cell_map_e:				; tile/cell run-list (continued, EBh/F7h alt rows)
		db	 01h,0EBh,0F9h,0F7h, 00h, 01h	; tile cell run
		db	0EBh,0F8h,0F7h, 00h, 00h, 00h	; tile cell run
		db	0F9h,0F7h, 00h, 00h, 00h,0F8h	; tile cell run
		db	0F7h, 00h, 01h,0EBh, 00h,0FBh	; tile cell run
		db	 00h, 01h,0EBh, 00h,0FAh, 00h	; tile cell run
		db	 00h,0FAh,0FBh, 00h, 00h, 00h	; tile cell run
		db	0FAh,0FAh, 00h, 00h, 01h,0EBh	; tile cell run
		db	 00h,0FEh, 00h, 01h,0EBh, 00h	; tile cell run
		db	0FCh, 00h, 00h,0FDh,0FEh, 00h	; tile cell run
		db	 00h, 00h,0FDh,0FCh, 00h, 00h	; tile cell run

akma_cell_map_f:				; tile/cell run-list (continued, F1/19h state rows)
		db	0F1h, 19h, 4Ah, 5Dh, 00h,0F1h	; tile cell run
		db	 19h, 4Ah, 5Ch, 00h, 00h, 00h	; tile cell run
		db	 4Ah, 5Dh, 00h, 00h, 00h, 4Ah	; tile cell run
		db	 5Ch, 00h,0F1h, 19h, 3Fh, 00h	; tile cell run
		db	 00h,0F1h, 19h, 34h, 00h, 00h	; tile cell run
		db	 34h, 00h, 00h, 3Fh, 00h, 34h	; tile cell run
		db	 00h, 00h, 34h, 00h,0F1h, 19h	; tile cell run
		db	 30h, 00h, 00h,0F1h, 19h,0FFh	; tile cell run
		db	 00h, 00h, 2Bh, 00h, 00h, 30h	; tile cell run
		db	 00h, 2Bh, 00h, 00h,0FFh, 8Bh	; tile cell run + run trailer

akma_init_code_a:				; embedded code-as-data: mov si,[10C0h] / mov [AA1Eh],0 / mov [AA1Fh],0
		db	 36h, 10h,0C0h,0C6h, 06h, 1Eh	; init code bytes
		db	0AAh, 00h,0C6h, 06h, 1Fh,0AAh	; init code bytes
		db	 00h				; init code byte

akma_npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		;  Fixup - byte match
			jz	akma_npc_scan_done			; Jump if zero
			mov	ax,[si]
			call	word ptr cs:akma_cb_tile_at_pos
			jc	akma_npc_scan_next			; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:akma_cb_tile_dispatch
			mov	bl,ds:akma_npc_idx
			xor	bh,bh			; Zero register
			mov	al,ds:akma_sprite_xlat_tbl[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'
			jz	akma_npc_scan_next			; Jump if zero
			test	byte ptr ds:akma_anim_byte,80h
			jnz	akma_npc_scan_next			; Jump if not zero
			mov	al,[si+5]
			and	al,1Fh
			cmp	byte ptr [si+4],5
			jne	akma_anim_set_high_bit			; Jump if not equal
			or	al,80h

akma_anim_set_high_bit:
			mov	ds:akma_anim_byte,al

akma_npc_scan_next:
			inc	byte ptr ds:akma_npc_idx
			add	si,10h
			jmp	short akma_npc_scan_loop

akma_npc_scan_done:
		mov	si,ds:akma_sprite_attr_ptr
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:akma_anim_byte,0FFh
		jz	akma_check_death			; Jump if zero
		mov	al,ds:akma_anim_byte
		push	ax
		and	al,1Fh
		call	word ptr cs:akma_cb_anim_lookup
		mov	bl,ah
		pop	ax
		xor	bh,bh			; Zero register
		mov	byte ptr ds:gvar_spawn_fx_flag,22h	; '"'
		call	akma_phase_step_cb

akma_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	akma_phase_advance			; Jump if zero
		jmp	akma_death_handler

akma_phase_advance:
		mov	byte ptr ds:akma_phase_b_active,0
		mov	al,ds:akma_phase_dir
		inc	al
		cmp	al,3
		jb	akma_phase_dir_set			; Jump if below
		xor	al,al			; Zero register

akma_phase_dir_set:
		mov	ds:akma_phase_dir,al
		cmp	al,1
		jne	akma_phase_step_advance			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,2Bh	; '+'

akma_phase_step_advance:
		inc	byte ptr ds:akma_phase_step
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_phase_active_branch			; Jump if not zero
		call	akma_scroll_dec
		jc	akma_scroll_dec_ok			; Jump if carry Set
		jmp	akma_xlat_lookup

akma_scroll_dec_ok:
		mov	al,ds:akma_scroll_x_hi
		sub	al,2
		and	al,3Fh			; '?'
		mov	ds:akma_scroll_x_hi,al
		cmp	al,3Dh			; '='
		je	akma_phase_active_init			; Jump if equal
		jmp	akma_check_phase_b

akma_phase_active_init:
		mov	byte ptr ds:akma_phase_active,0FFh
		mov	byte ptr ds:akma_render_mode,0
		mov	byte ptr ds:akma_phase_b_idx,0
		mov	byte ptr ds:akma_phase_b_step,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,34h	; '4'
		mov	ax,akma_data_word_a
		mov	bl,akma_data_byte_b
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ax
		sub	bx,ds:akma_sprite_attr_cnt
		jnc	akma_phase_active_swap			; Jump if carry=0
		xchg	bx,ax

akma_phase_active_swap:
		sub	bx,28h
		sbb	al,al
		and	al,1
		mov	ds:akma_death_step,al
		jmp	short akma_xlat_lookup

akma_phase_active_branch:
		call	akma_scroll_inc
		jnc	akma_xlat_lookup			; Jump if carry=0
		mov	al,ds:akma_scroll_x_hi
		sub	al,2
		and	al,3Fh			; '?'
		mov	ds:akma_scroll_x_hi,al
		cmp	al,3Dh			; '='
		jne	akma_check_phase_b			; Jump if not equal
		mov	byte ptr ds:akma_phase_active,0
		mov	byte ptr ds:akma_render_mode,0
		mov	byte ptr ds:akma_phase_b_idx,0
		mov	byte ptr ds:akma_phase_b_step,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,34h	; '4'
		mov	ax,akma_data_word_a
		mov	bl,akma_data_byte_b
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ax
		sub	bx,ds:akma_sprite_attr_cnt
		jnc	akma_phase_active_swap_b			; Jump if carry=0
		xchg	bx,ax

akma_phase_active_swap_b:
		sub	bx,14h
		sbb	al,al
		not	al
		and	al,1
		mov	ds:akma_death_step,al

akma_xlat_lookup:
		mov	bx,0A954h
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_xlat_use_active			; Jump if not zero
		mov	bx,akma_xlat_tbl_a969

akma_xlat_use_active:
		mov	al,ds:akma_scroll_x
		sub	al,0Ah
		shr	al,1			; Shift w/zeros fill
		xlat				; al=[al+[bx]] table
		mov	ds:akma_scroll_x_hi,al

akma_check_phase_b:
		test	byte ptr ds:akma_phase_b_step,0FFh
		jz	akma_render_begin			; Jump if zero
		mov	al,ds:akma_death_step
		add	al,2
		mov	ds:akma_phase_b_active,al
		test	byte ptr ds:akma_render_mode,0FFh
		jnz	akma_phase_b_dec			; Jump if not zero
		inc	byte ptr ds:akma_phase_b_idx
		mov	al,ds:akma_death_step
		not	al
		and	al,1
		add	al,7
		cmp	ds:akma_phase_b_idx,al
		jb	akma_render_begin			; Jump if below
		mov	byte ptr ds:akma_render_mode,0FFh
		jmp	short akma_render_begin

akma_phase_b_dec:
		dec	byte ptr ds:akma_phase_b_idx
		test	byte ptr ds:akma_phase_b_idx,0FFh
		jnz	akma_render_begin			; Jump if not zero
		mov	byte ptr ds:akma_phase_b_step,0
		jmp	short akma_render_begin

_317MAPA4	endp

akma_scroll_dec		proc	near
		mov	ax,ds:akma_scroll_x
		dec	ax
		dec	ax
		mov	bx,9
		sub	bx,ax
		cmc				; Complement carry
		jnc	akma_scroll_dec_save			; Jump if carry=0
		retn

akma_scroll_dec_save:
		mov	ds:akma_scroll_x,ax
		retn

akma_scroll_dec		endp

akma_scroll_inc		proc	near
		mov	ax,ds:akma_scroll_x
		inc	ax
		inc	ax
		mov	bx,33h
		sub	bx,ax
		jnc	akma_scroll_inc_save			; Jump if carry=0
		retn

akma_scroll_inc_save:
		mov	ds:akma_scroll_x,ax
		retn

akma_scroll_inc		endp

akma_render_begin:
		push	cs
		pop	es
		mov	di,akma_render_buf
		mov	ax,0FFFFh
		mov	cx,120h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,0A7F4h
		mov	di,0A876h
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_phase_active_pick			; Jump if not zero
		mov	si,akma_phase_si_tbl_a
		mov	di,akma_phase_di_tbl_a

akma_phase_active_pick:
		mov	bl,ds:akma_phase_dir
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,[bx+si]
		mov	bp,[bx+di]
		call	akma_render_col_pack
		mov	di,0AA67h
		mov	si,0A92Ch
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_phase_active_pick_b			; Jump if not zero
		mov	di,akma_render_buf_c
		mov	si,akma_phase_si_tbl_b

akma_phase_active_pick_b:
		mov	al,ds:akma_phase_step
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,0Ah
		xor	ah,ah			; Zero register
		add	si,ax
		mov	cx,5

akma_pick_loop:
			movsb				; Mov [si] to es:[di]
			movsb				; Mov [si] to es:[di]
			add	di,0Eh
			loop	akma_pick_loop		; Loop if cx > 0

		mov	di,0AAD3h
		mov	si,0A94Ah
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_pick_loop_b			; Jump if not zero
		mov	di,akma_render_buf_b
		mov	si,akma_phase_si_tbl_c

akma_pick_loop_b:
		mov	bl,ds:akma_phase_b_active
		add	bl,bl
		xor	bh,bh			; Zero register
		add	si,bx
		lodsb				; String [si] to al
		mov	[di],al
		add	di,10h
		lodsb				; String [si] to al
		mov	[di],al
		mov	byte ptr ds:akma_npc_idx,0
		mov	ax,ds:akma_scroll_x
		mov	si,ds:akma_sprite_attr_ptr
		mov	di,0AA2Ah
		mov	cx,0Dh

akma_render_row_loop:
		push	cx
		push	di
		push	ax
		call	word ptr cs:akma_cb_tile_at_pos
		pop	ax
		mov	ds:akma_attr_tmp,bl
		jc	akma_render_row_advance			; Jump if carry Set
		xor	cl,cl			; Zero register

akma_render_cell_loop:
			push	cx
			push	ax
			cmp	byte ptr [di],0FFh
			je	akma_render_cell_skip			; Jump if equal
			mov	[si],ax
			mov	al,ds:akma_scroll_x_hi
			add	al,cl
			and	al,3Fh			; '?'
			mov	[si+2],al
			mov	al,ds:akma_attr_tmp
			mov	[si+3],al
			mov	al,[di]
			mov	ah,al
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			and	al,0Fh
			mov	[si+4],al
			mov	[si+6],ah
			mov	al,ds:akma_phase_active
			and	al,80h
			mov	[si+5],al
			test	byte ptr ds:akma_anim_byte,0FFh
			jz	akma_render_apply_anim			; Jump if zero
			or	byte ptr [si+5],20h	; ' '

akma_render_apply_anim:
			push	di
			mov	ax,[si+2]
			call	word ptr cs:akma_cb_tile_dispatch
			mov	al,ds:akma_npc_idx
			mov	bl,al
			or	al,80h
			xchg	[di],al
			xor	bh,bh			; Zero register
			mov	ds:akma_sprite_xlat_tbl[bx],al
			inc	byte ptr ds:akma_npc_idx
			add	si,10h
			pop	di

akma_render_cell_skip:
			inc	di
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,10h
			jne	akma_render_cell_loop			; Jump if not equal

akma_render_row_advance:
		inc	ax
		pop	di
		add	di,10h
		pop	cx
		loop	akma_render_row_loop_jmp		; Loop if cx > 0

		jmp	short akma_render_terminate

akma_render_row_loop_jmp:
		jmp	akma_render_row_loop

akma_render_terminate:
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:akma_phase_b_step,0FFh
		jnz	akma_render_phase_b			; Jump if not zero
		retn

akma_render_phase_b:
		test	byte ptr ds:akma_phase_b_idx,0FFh
		jnz	akma_phase_b_render_check			; Jump if not zero
		retn

akma_phase_b_render_check:
		test	byte ptr ds:akma_death_step,0FFh
		jz	akma_phase_b_active_phase_a			; Jump if zero
		jmp	akma_phase_c_render

akma_phase_b_active_phase_a:
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_phase_b_active_b			; Jump if not zero
		mov	ax,ds:akma_scroll_x
		mov	dl,ds:akma_scroll_x_hi
		add	dl,9
		mov	cl,ds:akma_phase_b_idx
		dec	cl
		jz	akma_phase_b_a_final			; Jump if zero
		xor	ch,ch			; Zero register

akma_phase_b_a_loop:
			push	cx
			dec	ax
			dec	ax
			inc	dl
			push	dx
			push	ax
			call	word ptr cs:akma_cb_tile_at_pos
			pop	ax
			pop	dx
			mov	ds:akma_attr_tmp,bl
			jc	akma_phase_b_a_skip			; Jump if carry Set
			mov	bx,2603h
			call	akma_render_emit_cell

akma_phase_b_a_skip:
			pop	cx
			loop	akma_phase_b_a_loop		; Loop if cx > 0

akma_phase_b_a_final:
		dec	ax
		dec	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:akma_cb_tile_at_pos
		pop	ax
		pop	dx
		mov	ds:akma_attr_tmp,bl
		jc	akma_phase_b_a_done			; Jump if carry Set
		mov	bx,2602h
		call	akma_render_emit_cell

akma_phase_b_a_done:
		mov	word ptr [si],0FFFFh
		retn

akma_phase_b_active_b:
		mov	ax,ds:akma_scroll_x
		add	ax,0Bh
		mov	dl,ds:akma_scroll_x_hi
		add	dl,9
		mov	cl,ds:akma_phase_b_idx
		dec	cl
		jz	akma_phase_b_b_final			; Jump if zero
		xor	ch,ch			; Zero register

akma_phase_b_b_loop:
			push	cx
			inc	ax
			inc	ax
			inc	dl
			push	dx
			push	ax
			call	word ptr cs:akma_cb_tile_at_pos
			pop	ax
			pop	dx
			mov	ds:akma_attr_tmp,bl
			jc	akma_phase_b_b_skip			; Jump if carry Set
			mov	bx,2603h
			call	akma_render_emit_cell

akma_phase_b_b_skip:
			pop	cx
			loop	akma_phase_b_b_loop		; Loop if cx > 0

akma_phase_b_b_final:
		inc	ax
		inc	ax
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:akma_cb_tile_at_pos
		pop	ax
		pop	dx
		mov	ds:akma_attr_tmp,bl
		jc	akma_phase_b_b_done			; Jump if carry Set
		mov	bx,2602h
		call	akma_render_emit_cell

akma_phase_b_b_done:
		mov	word ptr [si],0FFFFh
		retn

akma_phase_c_render:
		test	byte ptr ds:akma_phase_active,0FFh
		jnz	akma_phase_c_b			; Jump if not zero
		mov	ax,ds:akma_scroll_x
		inc	ax
		mov	dl,ds:akma_scroll_x_hi
		add	dl,9
		mov	cl,ds:akma_phase_b_idx
		dec	cl
		jz	akma_phase_c_a_final			; Jump if zero
		xor	ch,ch			; Zero register

akma_phase_c_a_loop:
			push	cx
			dec	ax
			dec	ax
			inc	dl
			inc	dl
			push	dx
			push	ax
			call	word ptr cs:akma_cb_tile_at_pos
			pop	ax
			pop	dx
			mov	ds:akma_attr_tmp,bl
			jc	akma_phase_c_a_skip			; Jump if carry Set
			mov	bx,2607h
			call	akma_render_emit_cell

akma_phase_c_a_skip:
			pop	cx
			loop	akma_phase_c_a_loop		; Loop if cx > 0

akma_phase_c_a_final:
		dec	ax
		dec	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:akma_cb_tile_at_pos
		pop	ax
		pop	dx
		mov	ds:akma_attr_tmp,bl
		jc	akma_phase_c_a_done			; Jump if carry Set
		mov	bx,2606h
		call	akma_render_emit_cell

akma_phase_c_a_done:
		mov	word ptr [si],0FFFFh
		retn

akma_phase_c_b:
		mov	ax,ds:akma_scroll_x
		add	ax,0Ah
		mov	dl,ds:akma_scroll_x_hi
		add	dl,9
		mov	cl,ds:akma_phase_b_idx
		dec	cl
		jz	akma_phase_c_b_final			; Jump if zero
		xor	ch,ch			; Zero register

akma_phase_c_b_loop:
			push	cx
			inc	ax
			inc	ax
			inc	dl
			inc	dl
			push	dx
			push	ax
			call	word ptr cs:akma_cb_tile_at_pos
			pop	ax
			pop	dx
			mov	ds:akma_attr_tmp,bl
			jc	akma_phase_c_b_skip			; Jump if carry Set
			mov	bx,2607h
			call	akma_render_emit_cell

akma_phase_c_b_skip:
			pop	cx
			loop	akma_phase_c_b_loop		; Loop if cx > 0

akma_phase_c_b_final:
		inc	ax
		inc	ax
		inc	dl
		inc	dl
		push	dx
		push	ax
		call	word ptr cs:akma_cb_tile_at_pos
		pop	ax
		pop	dx
		mov	ds:akma_attr_tmp,bl
		jc	akma_phase_c_b_done			; Jump if carry Set
		mov	bx,2606h
		call	akma_render_emit_cell

akma_phase_c_b_done:
		mov	word ptr [si],0FFFFh
		retn

akma_render_emit_cell		proc	near
		push	ax
		push	dx
		mov	[si],ax
		and	dl,3Fh			; '?'
		mov	[si+2],dl
		mov	dh,ds:akma_attr_tmp
		mov	[si+3],dh
		mov	[si+4],bh
		mov	[si+6],bl
		mov	dh,ds:akma_phase_active
		and	dh,80h
		mov	[si+5],dh
		mov	ax,[si+2]
		call	word ptr cs:akma_cb_tile_dispatch
		mov	al,ds:akma_npc_idx
		mov	bl,al
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:akma_sprite_xlat_tbl[bx],al
		inc	byte ptr ds:akma_npc_idx
		add	si,10h
		pop	dx
		pop	ax
		retn

akma_render_emit_cell		endp

akma_render_col_pack		proc	near
		mov	di,akma_render_buf
		mov	cx,0Dh

akma_pack_outer_loop:
			push	cx
			mov	cx,2

akma_pack_mid_loop:
				push	cx
				mov	cx,8

akma_pack_inner_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	akma_pack_skip			; Jump if carry=0
				lodsb				; String [si] to al
				mov	[di],al

akma_pack_skip:
				inc	di
				loop	akma_pack_inner_loop		; Loop if cx > 0

				inc	bp
				pop	cx
				loop	akma_pack_mid_loop		; Loop if cx > 0

			pop	cx
			loop	akma_pack_outer_loop		; Loop if cx > 0

		retn

akma_render_col_pack		endp

; ------------------------------------------------------------------
; Data trailer block (file 0x350..0x3D2). Pure data despite Sourcer
; decoding leading bytes as cli/cmpsw/sub/dec/test/etc. The EQUs at
; top of file (akma_phase_si_tbl_a @ 0xA7EE, akma_phase_di_tbl_a @
; 0xA870, akma_phase_si_tbl_b @ 0xA918, akma_phase_si_tbl_c @ 0xA940,
; akma_xlat_tbl_a969 @ 0xA969) point INTO this region at runtime.
; Bytes preserved verbatim as Sourcer-decoded mnemonics (which sum to
; the same byte stream as raw db hex would).
; ------------------------------------------------------------------

akma_data_trailer	label	byte
		cli				; Disable interrupts
		cmpsw				; Cmp [si] to es:[di]
		sub	al,0A8h
		dec	sp
		test	al,13h
		test	al,3Ch			; '<'
		test	al,5Eh			; '^'
		test	al,0
		push	ax
		adc	[bp+di],dl
		adc	dl,[bx+di]
		add	[bp+si],ax
		push	cx
		adc	al,15h
		push	ss
		pop	ss
		sbb	[bp+di],al
		add	al,19h
		sbb	bl,[bp+di]
		sbb	al,5
		push	es
		sbb	ax,71Eh
		adc	[di],dl
		pop	es
		adc	[bp+si],dx
		adc	dx,[si]
		add	ax,1606h
		pop	ss
		sbb	[bx+di],bl
		add	ax,[si]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		add	[bp+si],ax
		push	ax
		push	ds
;*		add	[bx+di+0],dl
		db	 00h, 51h, 00h		;  Fixup - byte match

akma_trailer_pattern_a:				; index/state pattern bytes (00h/51h/50h tile-id markers)
		db	 50h, 20h, 01h, 02h, 51h, 21h	; pattern row
		db	 22h, 03h, 04h			; pattern row
		db	'#$'				; pattern bytes (23h,24h)
		db	8, 9, '%& !', 8, '"#', 9, '$'	; pattern bytes (08-09 tabs + ASCII run)
		db	'%'				; pattern byte (25h)
		db	 03h, 04h, 26h, 01h, 02h, 50h	; pattern row
		db	 00h, 51h, 00h, 50h, 27h, 01h	; pattern row
		db	 02h, 51h, 28h, 29h, 03h, 04h	; pattern row
		db	 2Ah, 2Bh, 05h, 06h, 07h, 2Ch	; pattern row
		db	 2Dh, 2Eh, 2Eh, 2Ch, 2Dh, 07h	; pattern row
		db	 2Ah, 2Bh, 05h, 06h, 28h, 29h	; pattern row
		db	 03h, 04h, 27h, 01h, 02h, 50h	; pattern row
		db	 00h, 51h			; pattern row tail

akma_phase_si_word_tbl:				; SI/DI word ptr table (entries into akma_phase_* @ A87Ch..)
		db	 7Ch,0A8h,0B0h,0A8h		; ptr A87C, A8B0
		db	0E4h,0A8h, 96h,0A8h,0CAh,0A8h	; ptr A8E4, A896, A8CA
		db	0FEh,0A8h			; ptr A8FE

akma_state_block_a:				; phase-state block A (3-row VFX coord matrix)
		db	 00h, 00h, 01h, 08h		; state row
		db	 04h, 00h, 2Ah,0A8h, 40h, 00h	; state row
		db	 2Ah,0B0h, 00h, 00h, 56h, 30h	; state row
		db	 88h, 10h			; state row tail
		db	14 dup (0)			; pad / reserved

akma_state_block_b:				; phase-state block B (mirror of block_a, reversed)
		db	 88h, 10h, 56h, 30h, 00h, 00h	; state row
		db	 2Ah,0B0h, 40h, 00h, 2Ah,0A8h	; state row
		db	 04h, 00h, 01h, 08h, 00h, 00h	; state row
		db	 00h, 00h, 00h, 00h, 01h, 08h	; state row
		db	 00h, 00h, 02h,0A8h, 00h, 00h	; state row
		db	 02h,0B0h, 00h, 00h, 01h, 50h	; state row
		db	 00h, 10h, 00h,0A0h, 00h, 00h	; state row
		db	9 dup (0)			; pad / reserved

akma_state_block_c:				; phase-state block C
		db	0A0h, 00h, 10h, 01h, 50h, 00h	; state row
		db	 00h, 02h,0B0h, 00h, 00h, 02h	; state row
		db	0A8h, 00h, 00h, 01h, 08h, 00h	; state row
		db	 00h, 00h, 00h, 00h, 00h, 01h	; state row
		db	 08h, 00h, 00h, 02h,0A8h, 00h	; state row
		db	 00h, 02h,0B0h, 00h, 00h, 0Ah	; state row
		db	 30h, 00h, 10h, 0Ah, 00h, 00h	; state row
		db	 00h, 04h, 00h, 00h, 00h, 04h	; state row
		db	 00h, 00h, 00h, 0Ah, 00h, 00h	; state row
		db	 10h, 0Ah, 30h, 00h, 00h, 02h	; state row
		db	0B0h, 00h, 00h, 02h,0A8h, 00h	; state row
		db	 00h, 01h, 08h, 00h, 00h, 00h	; state row
		db	 00h				; state row tail

akma_xlat_tbl_a969_data:			; xlat table @ A969h: tile-id remap with 0FFh masks
		db	0FFh, 30h,0FFh,0FFh,0FFh	; xlat row
		db	 31h, 32h,0FFh,0FFh,0FFh,0FFh	; xlat row
		db	0FFh, 33h, 34h,0FFh, 35h, 36h	; xlat row
		db	0FFh,0FFh,0FFh, 30h,0FFh,0FFh	; xlat row
		db	 31h,0FFh,0FFh,0FFh, 32h,0FFh	; xlat row
		db	0FFh, 33h,0FFh,0FFh, 35h, 34h	; xlat row
		db	 36h,0FFh,0FFh,0FFh,0FFh	; xlat row tail

akma_pattern_string_a:				; tile-id char pattern (40h..47h with mid-pattern)
		db	'@ABCDCECFC@ABCDGECFC<<=>??'	; tile pattern string

akma_pad_block_a:				; padding/pattern bytes (00..03h fillers)
		db	0, 0, 0, 1			; pad bytes
		db	23 dup (1)			; 23 fill 01h bytes
		db	0, 0, 0				; pad bytes
		db	 3Fh, 3Fh, 3Eh, 3Dh, 3Ch, 3Ch	; descending step pattern

akma_phase_step_cb		proc	near
		mov	ax,ds:akma_scroll_max
		sub	ax,bx
		jnc	akma_scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

akma_scroll_clamp_zero:
		mov	ds:akma_scroll_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:akma_cb_scroll
		pop	ax
		or	ax,ax			; Zero ?
		jz	akma_scroll_check_death			; Jump if zero
		retn

akma_scroll_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	akma_scroll_reset_state			; Jump if zero
		retn

akma_scroll_reset_state:
		mov	byte ptr ds:akma_death_subcnt,0
		mov	byte ptr ds:akma_phase_b_step,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn

akma_phase_step_cb		endp

akma_death_handler:
		mov	al,ds:akma_death_subcnt
		cmp	al,28h			; '('
		jae	akma_death_finish			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:akma_death_subcnt
		cmp	al,1Eh
		jae	akma_death_phase_done			; Jump if above or =
		inc	byte ptr ds:akma_phase_dir
		cmp	byte ptr ds:akma_phase_dir,3
		jb	akma_death_step_cont			; Jump if below
		mov	byte ptr ds:akma_phase_dir,0

akma_death_step_cont:
		inc	byte ptr ds:akma_phase_step
		inc	byte ptr ds:akma_phase_b_active
		and	byte ptr ds:akma_phase_b_active,1
		test	byte ptr ds:akma_phase_step,3
		jz	akma_death_set_phase_x			; Jump if zero
		jmp	akma_render_begin

akma_death_set_phase_x:
		mov	byte ptr ds:gvar_spawn_fx_flag,37h	; '7'
		jmp	akma_render_begin

akma_death_phase_done:
		mov	byte ptr ds:akma_phase_dir,1
		mov	byte ptr ds:akma_phase_b_active,1
		jmp	akma_render_begin

akma_death_finish:
		mov	byte ptr ds:gvar_state_ff30,0FFh
		retn

; ------------------------------------------------------------------
; Module trailer: boss-arena data bytes + 'Alguien' string
; ("Alguien" = Spanish for "Someone" - dialog speaker tag for an
; anonymous NPC or boss in the arena), then 216 zero padding bytes.
; The bytes here are pure data (Sourcer mis-decoded as sub/add/jnz/
; stosb mnemonics); kept verbatim since they assemble to the same
; byte stream.
; ------------------------------------------------------------------

akma_module_trailer	label	byte
		sub	al,[bx+si]		; data bytes
		add	[bx+si],ah		; data bytes
		add	si,[bx+si]		; data bytes
		jnz	$+0Eh			; data bytes
		add	[bp+di],dl		; data bytes
		stosb				; data byte
		db	0D8h, 0Eh, 10h,0BBh, 02h, 07h	; record header bytes
		db	'Alguien', 0, 0, 0, 0FFh	; 'Alguien' speaker name + terminator
		db	216 dup (0)			; pad to module end

seg_a		ends

		end	start
