
PAGE  59,132

;==========================================================================
;
;  314LEGA - Level / Map Renderer Code Module - Tarso (zelres3 chunk)
;
;  Level renderer and per-frame map update program for the Tarso area
;  (town name 'Tarso' embedded near the module trailer). Sibling of
;  312ZELA (Satono) and 313MEDA (Bosque/Vista); shares the
;  game-segment dispatch ABI and per-map state byte layout.
;
;  Structure:
;    - Header pointer / descriptor area (file 0x00..0x80) mis-decoded by
;      Sourcer as sbb/and x86 instructions; preserved as raw bytes
;    - Large tile/cell layout data block (lega_tile_data_block_*)
;    - Per-frame NPC scan loop (lega_npc_scan_loop..lega_npc_scan_done)
;    - Phase / state machine + scroll helpers
;    - Trailer: 10-word handler jump-table + continuation tile data
;      + 'Tarso' town-name string fragment
;
;  Connections:
;    Loads:        none (loaded as data/code by 200FIGHT alongside LEGA
;                  arena/map data; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_prep (200Ch), fight_cb_record_ofs (6028h),
;                  fight_cb_anim_step (6036h), fight_cb_hit_check (6038h).
;    Called by:    200FIGHT level/arena dispatch (LEGA boss arena;
;                  paired with AI module 306EAI6.BIN).
;    Reads/writes: gvar_death_flag (0FF2Eh), gvar_dir_toggle (0FF2Fh),
;                  gvar_spawn_fx_flag (0FF75h), gvar_unk_ff3c (0FF3Ch);
;                  enemy slot list at fight_slot_list (0C010h);
;                  LEGA tables lega_tbl_a41b (0A41Bh), npc state scan
;                  tables a/b (0A41Fh/0A424h), anim dx/dy tables
;                  (0A5D8h/0A5D9h), phase xlat a/b (0A69Bh/0A6BCh),
;                  dispatch table (0A744h), and scroll/NPC state bytes
;                  lega_scroll_x..lega_phase_dir_b (0A7A0h..0A7BAh).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_* not in zr3com.inc)
; ----------------------------------------------------------------------
; 0xFF3C is canonically gvar_palette_flag (set during palette transitions
; per 200FIGHT; also referred to as gvar_palette_st in game.asm).
; 314LEGA's single use is `add ss:gvar_palette_flag[bp+di], al` which is a
; STACK-FRAME local access (ss:[bp+di+offset]) — the offset happens to
; be 0xFF3C but the access targets a stack slot, not the global.
; Aliased for compile compatibility.
gvar_unk_ff3c		equ	0FF3Ch		; alias for gvar_palette_flag (note: 314LEGA's site is a stack ref)


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
lega_tbl_a3c7		equ	0A3C7h		; (unresolved data ref)
lega_tbl_a41b		equ	0A41Bh		; xlat table base (mov bx, 0A41Bh + xlat)
lega_anim_dx_tbl	equ	0A5D8h		; per-phase delta-X table base
lega_anim_dy_tbl	equ	0A5D9h		; per-phase delta-Y table base
lega_phase_xlat_a	equ	0A69Bh		; phase-A xlat table (xlat-indexed)
lega_phase_xlat_b	equ	0A6BCh		; phase-B xlat table (xlat-indexed)
lega_dispatch_tbl	equ	0A744h		; trailer dispatch jump-table base
lega_render_buf		equ	0A7C9h		; tile render buffer base
lega_render_buf_b	equ	0A7CBh		; tile render buffer +2


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
lega_npc_state_a	equ	0A41Fh		; cell-state scan table A (5 bytes, scasb)
lega_npc_state_b	equ	0A424h		; cell-state scan table B (5 bytes, scasb)
lega_unk_a6c8		equ	0A6C8h		; (unresolved table ref)
lega_scroll_x		equ	0A7A0h		; scroll X position (word)
lega_scroll_phase	equ	0A7A2h		; scroll phase counter byte
lega_scroll_x_max	equ	0A7A3h		; scroll X max (word)
lega_npc_idx		equ	0A7B6h		; NPC scan index byte
lega_anim_byte		equ	0A7B7h		; current animation/speaker byte
lega_idle_step		equ	0A7B8h		; idle step counter (0..0x28)
lega_phase_step		equ	0A7B9h		; phase step counter (mod 8)
lega_phase_dir_b	equ	0A7BAh		; per-frame xlat output (written after xlat)
lega_phase_substep	equ	0A7BBh		; phase sub-step (mod 4)
lega_attr_tmp		equ	0A7BCh		; tile attribute scratch byte
lega_phase_locked	equ	0A7BDh		; phase-locked flag
lega_phase_subflag	equ	0A7BEh		; phase sub-flag
lega_phase_delay	equ	0A7BFh		; phase delay countdown
lega_phase_active	equ	0A7C0h		; phase-active flag
lega_phase_active_b	equ	0A7C1h		; phase-active sub-flag
lega_anim2_active	equ	0A7C2h		; secondary animation active flag
lega_anim2_x		equ	0A7C3h		; secondary anim X position (word)
lega_anim2_y		equ	0A7C5h		; secondary anim Y position
lega_anim2_frame	equ	0A7C6h		; secondary anim frame index
lega_anim2_phase	equ	0A7C7h		; secondary anim phase counter
lega_anim2_subflag	equ	0A7C8h		; secondary anim sub-flag
lega_extra_attr		equ	0A7F1h		; extra-attr byte at scan tail


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

lega_main		proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; The leading "sbb/add/and" x86 decode is Sourcer mis-parsing the
; module header fields; real code entry is via dispatch from game
; DS. The 12 zero bytes below are the reserved / padding header area.
; ------------------------------------------------------------------

start:
		sbb	[bx+si],cx		; header field bytes
		add	[bx+si],al		; header field bytes
		and	sp,ss:lega_scroll_x[bp+si]	; header field bytes
		db	12 dup (0)		; reserved / padding
; --- header A0h-fill descriptor + initial tile-row constants ---
lega_hdr_fill_a		db	0A0h,0A0h,0A0h,0A0h,0A0h,0A0h	; A0h palette/colour fill descriptor
lega_hdr_const_50	db	 50h			; header constant byte
lega_hdr_const_0a_pair	db	 0Ah, 0Ah		; header constant pair
; --- tile-data block A: long 0Ah run (cell-empty default fill) ---
lega_tile_data_block_a		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; Data table (indexed access)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; 0Ah-fill row 1
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; 0Ah-fill row 2
		db	0Ah, 0Ah, '>'			; trailing terminator '>'
; --- pointer/jump-table words (6 entries: A08E, A0DE, A12E, A17E, A1CE, A205) ---
lega_ptr_table_a	db	0A0h, 8Eh,0A0h,0DEh,0A0h, 2Eh	; ptrs[0..2]: A08E,A0DE,A12E
		db	0A1h, 7Eh,0A1h,0CEh,0A1h, 05h	; ptrs[3..5]: A17E,A1CE,A205
		db	0A2h			; trailing high-byte
; --- cell index map A: 6-byte rows (00 = empty cell) ---

lega_cell_map_a:
		db	 02h, 00h, 00h, 00h, 03h	; row A header (5 bytes)
		db	 02h, 00h, 00h, 04h, 00h, 02h	; row 0
		db	 00h, 00h, 00h, 05h, 02h, 00h	; row 1
		db	 00h, 06h, 00h, 02h, 00h, 00h	; row 2
		db	 00h, 07h, 02h, 00h, 00h, 08h	; row 3
		db	 00h, 02h, 00h,0ADh, 00h,0AFh	; row 4
		db	 02h,0AEh, 00h,0B0h, 00h, 02h	; row 5
		db	0B1h,0B2h,0B5h,0B6h, 02h,0B3h	; row 6
		db	0B4h,0B7h,0B8h, 02h,0B9h,0BAh	; row 7
		db	 39h, 01h, 02h, 75h,0AAh, 02h	; row 8
		db	 38h, 02h, 00h, 00h, 00h, 01h	; row 9
		db	 02h, 00h, 00h, 02h, 00h, 02h	; row 10
		db	 00h, 00h, 00h,0BBh, 02h, 00h	; row 11
		db	 00h,0BCh, 00h, 00h, 09h, 0Ah	; row 12
		db	 0Bh, 0Ch, 00h, 0Dh, 0Eh, 10h	; row 13
		db	 11h, 00h, 0Eh, 0Fh, 11h, 12h	; row 14
lega_tile_data_block_b		db	0			; Data table (indexed access)
		db	 13h, 14h			; trailing pair
lega_tile_data_block_c		dw	1615h			; Data table (indexed access)
; --- cell index map B: 6-byte rows continuing the lookup ---

lega_cell_map_b:
		db	 00h, 17h, 18h, 19h, 1Ah, 00h	; row B0
		db	 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah	; row B1
		db	 1Bh, 1Dh, 1Eh, 00h, 1Fh, 13h	; row B2
		db	 20h, 21h, 00h, 13h, 14h, 21h	; row B3
		db	 16h, 00h, 20h, 21h, 22h, 23h	; row B4
		db	 00h, 21h, 16h, 23h, 18h, 00h	; row B5
		db	 24h, 1Ah, 25h, 1Dh, 00h, 1Ah	; row B6
		db	 1Bh, 1Dh, 1Eh, 00h, 0Dh, 0Eh	; row B7
		db	 26h, 27h, 00h, 0Fh, 00h, 28h	; row B8
; --- cell index map C: dense 12-byte rows (Sourcer mis-split as strings) ---

lega_cell_map_c:
		db	29h, 00h, 2Ah, 2Bh, 2Eh, 2Fh, 00h, 2Ch, 2Dh, 30h, 31h, 00h	; row C0
		db	32h, 33h, 36h, 37h, 00h, 34h, 35h, 19h, 1Ah, 00h, 36h, 37h	; row C1
		db	3Ah, 3Bh, 00h, 19h, 1Ah, 1Ch, 1Dh, 00h, 1Ah, 00h, 1Dh, 1Eh	; row C2
		db	00h, 0Dh, 0Eh, 3Dh, 27h, 00h, 3Ch, 3Dh, 3Eh, 3Fh, 00h, 3Fh	; row C3
		db	40h, 43h, 44h, 00h, 41h, 42h, 45h, 46h, 00h, 47h, 48h, 49h	; row C4
		db	00h, 00h, 4Ah, 0Eh, 4Dh, 27h, 00h, 34h, 35h, 58h, 59h, 00h	; row C5
		db	4Bh, 4Ch, 4Eh, 4Fh, 00h, 50h, 51h, 00h, 44h, 00h, 58h, 59h	; row C6
		db	5Ah, 5Bh, 00h, 53h, 54h, 56h, 57h, 00h, 4Eh, 4Fh, 54h, 55h	; row C7
		db	00h, 00h, 00h, 52h, 53h, 00h, 0Dh, 0Eh, 5Dh, 27h, 00h, 0Eh	; row C8
		db	0Fh, 27h, 28h, 00h, 61h, 2Ch, 6Ah, 6Bh, 00h, 2Ch, 69h, 6Bh	; row C9
		db	6Ch, 00h, 6Bh, 6Ch		; row C10 partial
; --- cell index map D: 6-byte rows (resumes after C) ---

lega_cell_map_d:
		db	 6Dh, 6Eh, 00h, 6Eh, 6Fh, 70h	; row D0
		db	 71h, 00h, 70h, 71h, 5Ah, 72h	; row D1
		db	 00h, 00h, 5Ch, 5Eh, 5Fh, 00h	; row D2
		db	 5Ch, 5Dh, 5Fh, 60h, 00h, 62h	; row D3
		db	 63h, 65h, 66h, 00h, 64h, 65h	; row D4
		db	 67h, 68h, 00h, 0Dh, 0Eh, 73h	; row D5
		db	 74h, 00h, 0Eh, 0Fh, 74h, 12h	; row D6
		db	 00h, 76h, 77h, 7Ah, 7Bh, 00h	; row D7
		db	 78h, 79h, 7Ch, 7Dh, 00h, 17h	; row D8
		db	 7Ah, 19h, 1Ah, 00h, 19h, 1Ah	; row D9
		db	 1Ch, 1Dh, 00h, 1Ah, 1Bh, 1Dh	; row D10
		db	 1Eh, 00h, 7Eh, 7Fh, 82h, 83h	; row D11
		db	 00h, 80h, 81h, 84h, 85h, 00h	; row D12
		db	 19h, 1Ah,0A2h,0A3h, 00h, 1Ah	; row D13
		db	 1Bh,0A3h,0A4h, 00h, 7Eh, 7Fh	; row D14
		db	0A5h, 83h, 00h, 00h, 00h,0A0h	; row D15
		db	0A1h, 00h, 7Eh, 7Fh,0ACh, 83h	; row D16
		db	 00h, 1Ah, 1Bh, 1Dh,0ABh, 00h	; row D17
		db	 19h, 1Ah,0A9h, 1Dh, 00h, 00h	; row D18
		db	0A6h,0A7h,0A8h, 00h, 86h, 87h	; row D19
		db	 88h, 89h, 00h, 8Bh, 8Ch, 8Eh	; row D20
		db	 8Fh, 00h, 89h, 8Ah, 8Ch, 8Dh	; row D21
		db	 00h, 92h, 93h, 96h, 97h, 00h	; row D22
		db	 8Fh, 90h, 93h, 94h, 00h, 98h	; row D23
		db	 99h, 1Ah, 9Bh, 00h, 99h, 9Ah	; row D24
		db	 9Bh, 9Ch, 00h, 1Ah, 9Bh, 9Dh	; row D25
		db	 9Eh, 00h, 9Bh, 9Ch, 9Eh, 9Fh	; row D26
		db	 00h, 91h, 92h, 95h, 96h, 00h	; row D27
		db	 17h, 98h, 19h, 1Ah, 00h, 19h	; row D28
		db	 1Ah, 1Ch, 9Dh, 02h,0BDh,0BEh	; row D29
		db	0BFh,0C0h, 02h,0C1h,0C2h,0C3h	; row D30
		db	0C4h, 02h,0C5h,0C6h,0C7h,0C8h	; row D31
		db	 02h,0C9h,0CAh,0CBh,0CCh, 02h	; row D32
		db	0CDh,0CEh,0CFh,0D0h, 02h, 00h	; row D33
		db	 00h,0D1h,0D2h			; row D34 trailing
; --- real instruction stream resumes here (Sourcer split it across data) ---
; mov si,word ptr ds:[10C0h]; mov byte ptr ds:[A7B6h],0; mov byte ptr ds:[A7B7h],0

lega_main_resume:
		db	 8Bh, 36h, 10h			; mov si,...
		db	0C0h,0C6h, 06h,0B6h,0A7h, 00h	; mov byte ptr ds:[A7B6h],0  (lega_npc_idx clear)
		db	0C6h				; opcode prefix for following instruction

lega_npc_scan_loop:
		push	es
		mov	bh,0A7h
		add	ss:gvar_unk_ff3c[bp+di],al
		jz	lega_npc_scan_done			; Jump if zero
		mov	ax,[si]
		call	word ptr cs:fight_cb_anim_step
		jc	lega_npc_scan_next			; Jump if carry Set
		mov	[si+3],bl
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:lega_npc_idx
		xor	bh,bh			; Zero register
		mov	al,ds:sprite_xlat_tbl[bx]
		mov	[di],al
		test	byte ptr [si+5],40h	; '@'
		jz	lega_npc_scan_next			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		mov	ds:lega_anim_byte,al

lega_npc_scan_next:
		inc	byte ptr ds:lega_npc_idx
		add	si,10h
;*		jmp	short loc_2		;*
		db	0EBh, 0C4h		; jmp short 235h (absolute)

lega_npc_scan_done:
		mov	si,ds:enemy_attr_base
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:lega_anim_byte,0FFh
		jz	lega_post_scan_check_death			; Jump if zero
		mov	al,ds:lega_anim_byte
		push	ax
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		cmp	al,9
		je	lega_anim_apply_scroll			; Jump if equal
		cmp	al,1
		jne	lega_anim_dispatch_other			; Jump if not equal
		add	bx,bx
		jmp	short lega_anim_apply_scroll

lega_anim_dispatch_other:
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill

lega_anim_apply_scroll:
		call	lega_scroll_finalize
		mov	byte ptr ds:gvar_spawn_fx_flag,2Fh	; '/'
		cmp	byte ptr ds:lega_scroll_x,2Fh	; '/'
		jae	lega_post_scan_check_death			; Jump if above or =
		mov	byte ptr ds:lega_phase_delay,14h
		mov	byte ptr ds:lega_phase_locked,0FFh

lega_post_scan_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	lega_phase_check_active			; Jump if zero
		jmp	lega_idle_or_spawn

lega_phase_check_active:
		test	byte ptr ds:lega_phase_active,0FFh
		jz	lega_phase_check_anim2			; Jump if zero
		jmp	lega_phase_active_handler

lega_phase_check_anim2:
		test	byte ptr ds:lega_anim2_active,0FFh
		jz	lega_phase_check_locked			; Jump if zero
		cmp	byte ptr ds:lega_anim2_phase,0Dh
		jae	lega_phase_check_locked			; Jump if above or =
		jmp	lega_phase_check_step6

lega_phase_check_locked:
		test	byte ptr ds:lega_phase_locked,0FFh
		jnz	lega_phase_locked_branch			; Jump if not zero
		mov	byte ptr ds:lega_phase_delay,3Ch	; '<'
		inc	byte ptr ds:lega_phase_step
		and	byte ptr ds:lega_phase_step,7
		mov	al,ds:lega_phase_step
		push	cs
		pop	es
		mov	di,lega_npc_state_a
		mov	cx,5
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jnz	lega_phase_a_done			; Jump if not zero
		push	ax
		call	lega_scroll_dec_step
		sbb	al,al
		mov	ds:lega_phase_locked,al
		pop	ax
		cmp	al,7
		jne	lega_phase_a_done			; Jump if not equal
		call	lega_scroll_dec_step
		sbb	al,al
		mov	ds:lega_phase_locked,al

lega_phase_a_done:
		jmp	short lega_phase_check_step6

lega_phase_locked_branch:
		dec	byte ptr ds:lega_phase_delay
		jnz	lega_phase_b_step			; Jump if not zero
		mov	byte ptr ds:lega_phase_locked,0
		jmp	short lega_phase_check_step6

lega_phase_b_step:
				mov	al,ds:lega_phase_step
				or	al,al			; Zero ?
				jnz	lega_phase_b_skip0			; Jump if not zero
				mov	al,8

lega_phase_b_skip0:
				cmp	al,6
				jne	lega_phase_b_skip6			; Jump if not equal
				sub	al,2

lega_phase_b_skip6:
				dec	al
				mov	ds:lega_phase_step,al
				push	cs
				pop	es
				mov	di,lega_npc_state_b
				mov	cx,5
				repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
				jnz	lega_phase_check_step6			; Jump if not zero
				push	ax
				call	lega_scroll_inc_step
				cmc				; Complement carry
				sbb	al,al
				mov	ds:lega_phase_locked,al
				pop	ax
				cmp	al,6
				je	lega_phase_b_apply			; Jump if equal
				cmp	al,3
				jne	lega_phase_b_step			; Jump if not equal

lega_phase_b_apply:
		call	lega_scroll_inc_step
		cmc				; Complement carry
		sbb	al,al
		mov	ds:lega_phase_locked,al

lega_phase_check_step6:
		test	byte ptr ds:lega_phase_locked,0FFh
		jnz	lega_phase_dir_apply			; Jump if not zero
		cmp	byte ptr ds:lega_phase_step,6
		jne	lega_phase_dir_apply			; Jump if not equal
		call	word ptr cs:[stick_subsample_tick_handler]	; was: call word ptr cs:data_6 (fn ptr at offset 11Ah)
		and	al,1
		jnz	lega_phase_dir_apply			; Jump if not zero
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_phase_dir_apply			; Jump if not zero
		mov	ax,cs:lega_scroll_x
		sub	ax,14h
		jc	lega_phase_dir_apply			; Jump if carry Set
		mov	byte ptr ds:lega_phase_active,0FFh
		mov	byte ptr ds:lega_phase_active_b,0
		mov	byte ptr ds:lega_phase_subflag,0
		mov	byte ptr ds:lega_phase_step,8
		mov	byte ptr ds:gvar_spawn_fx_flag,30h	; '0'

lega_phase_dir_apply:
		inc	byte ptr ds:lega_phase_substep
		and	byte ptr ds:lega_phase_substep,3
		mov	al,ds:lega_phase_substep
		mov	bx,lega_tbl_a41b
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$+9Ah

lega_phase_active_handler:
; --- phase-active state machine code (mis-decoded by Sourcer, raw bytes) ---
; inc/mov/dec/test/sub/mov sequences manipulating lega_phase_active_b,
; lega_phase_dir_b, lega_phase_step, lega_phase_active and gvar_spawn_fx_flag
		db	0FEh, 06h,0C1h,0A7h, 8Ah, 1Eh	; inc byte ptr [A7C1h]; mov bl,[..
		db	0C1h,0A7h,0FEh,0CBh, 32h,0FFh	; ..A7C1h]; dec bl; xor bh,bh
		db	 03h,0DBh,0FFh,0A7h,0C7h,0A3h	; add bx,bx; jmp word ptr [bx+A3C7h]
		db	0CDh,0A3h,0FEh,0A3h, 0Ah,0A4h	; jump-table entries
		db	0C6h, 06h,0BAh,0A7h, 06h,0C6h	; mov byte ptr [A7BAh],6; mov..
		db	 06h,0B9h,0A7h, 08h,0C6h, 06h	; ..byte ptr [A7B9h],8; mov..
		db	0C2h,0A7h,0FFh,0A1h,0A0h,0A7h	; ..byte ptr [A7C2h],FFh; mov ax,[A7A0h]
		db	 05h, 04h, 00h,0A3h,0C3h,0A7h	; add ax,4; mov [A7C3h],ax
		db	0A0h,0A2h,0A7h, 24h, 3Fh,0A2h	; mov al,[A7A2h]; and al,3Fh
		db	0C5h,0A7h,0C6h, 06h,0C6h,0A7h	; mov [A7C5h],al; mov [A7C6h],..
		db	 00h,0C6h, 06h,0C7h,0A7h, 00h	; ..0; mov byte ptr [A7C7h],0
		db	0C6h, 06h,0C8h,0A7h, 00h,0EBh	; mov byte ptr [A7C8h],0; jmp short
		db	 4Eh,0C6h, 06h,0BAh,0A7h, 07h	; +0x4E; mov byte ptr [A7BAh],7
		db	0C6h, 06h,0B9h,0A7h, 06h,0EBh	; mov byte ptr [A7B9h],6; jmp short
		db	 42h,0C6h, 06h,0BAh,0A7h, 00h	; +0x42; mov byte ptr [A7BAh],0
		db	0C6h, 06h,0C0h,0A7h, 00h,0C6h	; mov byte ptr [A7C0h],0; mov..
		db	 06h,0B9h,0A7h, 06h,0EBh, 31h	; ..byte ptr [A7B9h],6; jmp short +0x31
; --- phase-step xlat tables (indexed by lega_phase_active_b) ---
lega_phase_step_tbl_a	db	 00h, 01h, 02h, 01h, 02h, 05h	; phase_a entries [0..5]
			db	 06h, 07h, 00h, 01h		; phase_a entries [6..9]
lega_phase_step_tbl_b	db	 03h, 06h			; phase_b entries [0..1]
			db	 07h, 07h			; phase_b entries [2..3]

lega_main		endp

lega_scroll_dec_step		proc	near
		mov	ax,ds:lega_scroll_x
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		mov	ds:lega_scroll_x,ax
		cmc				; Complement carry
		jnc	$+3			; Jump if carry=0
		retn

lega_scroll_dec_step		endp

		db	0F8h,0C3h			; clc; retn (mis-decoded tail of dec_step)

lega_scroll_inc_step		proc	near
		mov	ax,ds:lega_scroll_x
		inc	ax
		mov	bx,32h
		sub	bx,ax
		jnc	$+3			; Jump if carry=0
		retn

lega_scroll_inc_step		endp

; --- Sourcer mis-decoded tail: mov [A7A0h],ax; clc; retn ---
		db	0A3h,0A0h,0A7h,0F8h,0C3h	; mov ds:[A7A0h],ax; clc; retn
; --- render-buffer init: push cs; pop es; mov di,A7C9h; mov cx,28h ---
		db	 0Eh, 07h			; push cs; pop es
		db	0BFh,0C9h,0A7h,0B9h, 28h, 00h	; mov di,A7C9h; mov cx,28h
; --- render-buffer fill: mov ax,FFFFh; rep stosw; mov bl,[A7B9h]; xor bh,bh; add bx,bx ---
		db	0B8h,0FFh,0FFh,0F3h,0ABh, 8Ah	; mov ax,FFFFh; rep stosw; mov bl,..
		db	 1Eh,0B9h,0A7h, 32h,0FFh, 03h	; ..[A7B9h]; xor bh,bh; add..
		db	0DBh, 8Bh,0B7h,0C8h,0A6h, 8Bh	; ..bx,bx; mov si,[bx+A6C8h]; mov..
		db	0AFh, 44h,0A7h			; ..bp,[bx+A744h]
; --- render outer loop init: mov di,A7CBh; mov cx,8 ---
		db	0BFh,0CBh,0A7h,0B9h, 08h, 00h	; mov di,A7CBh; mov cx,8

lega_render_outer_loop:
				push	cx
				mov	cx,8

lega_render_inner_loop:
						rol	byte ptr ds:[bp],1	; Rotate
						jnc	lega_render_inner_advance			; Jump if carry=0
						movsb				; Mov [si] to es:[di]
						dec	di

lega_render_inner_advance:
						inc	di
						loop	lega_render_inner_loop		; Loop if cx > 0

				inc	di
				inc	di
				inc	bp
				pop	cx
				loop	lega_render_outer_loop		; Loop if cx > 0

		mov	al,byte ptr ds:[0A7BAh]
		add	al,al
		mov	di,lega_extra_attr
		cmp	byte ptr ds:lega_phase_step,6
		je	lega_extra_attr_step			; Jump if equal
		cmp	byte ptr ds:lega_phase_step,8
		jb	lega_extra_attr_done			; Jump if below

lega_extra_attr_step:
		inc	di

lega_extra_attr_done:
		stosb				; Store al to es:[di]
		add	di,13h
		inc	al
		stosb				; Store al to es:[di]
		mov	byte ptr ds:lega_npc_idx,0
		mov	ax,ds:lega_scroll_x
		mov	si,ds:enemy_attr_base
		mov	di,0A7C9h
		mov	cx,8

lega_render_scan_loop:
		push	cx
		push	di
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		mov	ds:lega_attr_tmp,bl
		jc	lega_render_scan_outer_advance			; Jump if carry Set
		xor	cl,cl			; Zero register

lega_render_scan_inner:
				push	cx
				push	ax
				cmp	byte ptr [di],0FFh
				je	lega_render_scan_advance			; Jump if equal
				mov	[si],ax
				mov	al,ds:lega_scroll_phase
				add	al,cl
				and	al,3Fh			; '?'
				mov	[si+2],al
				mov	al,ds:lega_attr_tmp
				mov	[si+3],al
				mov	al,[di]
				mov	[si+6],al
				mov	ah,al
				add	al,al
				sbb	al,al
				and	al,60h			; '`'
				mov	bl,ah
				shr	bl,1			; Shift w/zeros fill
				shr	bl,1			; Shift w/zeros fill
				shr	bl,1			; Shift w/zeros fill
				shr	bl,1			; Shift w/zeros fill
				and	bl,7
				or	al,bl
				mov	[si+4],al
				mov	byte ptr [si+5],0
				test	byte ptr ds:lega_anim_byte,0FFh
				jz	lega_render_scan_xlat			; Jump if zero
				or	byte ptr [si+5],20h	; ' '

lega_render_scan_xlat:
				push	di
				mov	ax,[si+2]
				call	word ptr cs:fight_cb_record_ofs
				mov	bl,ds:lega_npc_idx
				xor	bh,bh			; Zero register
				mov	al,bl
				or	al,80h
				xchg	[di],al
				mov	ds:sprite_xlat_tbl[bx],al
				pop	di
				add	si,10h
				inc	byte ptr ds:lega_npc_idx

lega_render_scan_advance:
				inc	di
				pop	ax
				pop	cx
				inc	cl
				cmp	cl,0Ah
				jne	lega_render_scan_inner			; Jump if not equal

lega_render_scan_outer_advance:
		inc	ax
		pop	di
		add	di,0Ah
		pop	cx
		loop	lega_render_scan_loop_target		; Loop if cx > 0

		jmp	short lega_render_scan_done

lega_render_scan_loop_target:
		jmp	lega_render_scan_loop

lega_render_scan_done:
		call	lega_render_anim2_cell
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_anim2_check_subflag			; Jump if not zero
		retn

lega_anim2_check_subflag:
		test	byte ptr ds:lega_anim2_subflag,0FFh
		jnz	lega_anim2_subflag_branch			; Jump if not zero
		cmp	byte ptr ds:lega_anim2_x,12h
		jae	lega_anim2_step			; Jump if above or =
		mov	byte ptr ds:lega_anim2_subflag,0FFh
		mov	byte ptr ds:lega_anim2_frame,3
		mov	byte ptr ds:gvar_spawn_fx_flag,32h	; '2'
		retn

lega_anim2_step:
		mov	bl,ds:lega_anim2_phase
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	al,ds:lega_anim_dx_tbl[bx]
		add	ds:lega_anim2_x,al
		mov	al,ds:lega_anim_dy_tbl[bx]
		add	ds:lega_anim2_y,al
		cmp	byte ptr ds:lega_anim2_phase,10h
		adc	byte ptr ds:lega_anim2_phase,0
		mov	al,ds:lega_anim2_frame
		inc	al
		cmp	al,3
		jb	lega_anim2_frame_clamp			; Jump if below
		xor	al,al			; Zero register

lega_anim2_frame_clamp:
		mov	ds:lega_anim2_frame,al
		cmp	byte ptr ds:lega_anim2_phase,9
		jne	lega_anim2_check_phase_c			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_check_phase_c:
		cmp	byte ptr ds:lega_anim2_phase,0Ch
		jne	lega_anim2_check_phase_f			; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_check_phase_f:
		cmp	byte ptr ds:lega_anim2_phase,0Fh
		jne	lega_anim2_finalize_ret		; Jump if not equal
		mov	byte ptr ds:gvar_spawn_fx_flag,31h	; '1'

lega_anim2_finalize_ret:
		retn

lega_anim2_subflag_branch:
		inc	byte ptr ds:lega_anim2_frame
		cmp	byte ptr ds:lega_anim2_frame,6
		jae	lega_anim2_clear_active			; Jump if above or =
		retn

lega_anim2_clear_active:
		mov	byte ptr ds:lega_anim2_active,0
		retn
; --- anim2 per-phase delta table (lega_anim_dx_tbl/dy_tbl base = A5D8h) ---
; 17 (dx,dy) pairs as signed bytes; phase 0..0x10 indexed via bx*=2 above

lega_anim2_dxdy_tbl:
		db	0FFh, 00h,0FFh, 00h,0FFh, 01h	; phase 0..2: (-1,0)(-1,0)(-1,1)
		db	 00h, 02h,0FFh, 02h, 00h, 02h	; phase 3..5: (0,2)(-1,2)(0,2)
		db	0FFh, 02h,0FFh,0FEh,0FFh, 00h	; phase 6..8: (-1,2)(-1,-2)(-1,0)
		db	0FFh, 02h,0FFh,0FFh,0FFh, 00h	; phase 9..0Bh: (-1,2)(-1,-1)(-1,0)
		db	0FFh, 01h,0FFh, 00h,0FFh, 00h	; phase 0Ch..0Eh: (-1,1)(-1,0)(-1,0)
		db	0FFh, 00h,0FFh, 00h		; phase 0Fh..10h: (-1,0)(-1,0)

lega_render_anim2_cell		proc	near
		test	byte ptr ds:lega_anim2_active,0FFh
		jnz	lega_anim2_cell_query			; Jump if not zero
		retn

lega_anim2_cell_query:
		mov	ax,ds:lega_anim2_x
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		jnc	lega_anim2_cell_write			; Jump if carry=0
		retn

lega_anim2_cell_write:
		mov	[si],ax
		mov	al,ds:lega_anim2_y
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],26h	; '&'
		mov	byte ptr [si+5],0
		mov	al,ds:lega_anim2_frame
		mov	[si+6],al
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:lega_npc_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:sprite_xlat_tbl[bx],al
		add	si,10h
		retn

lega_render_anim2_cell		endp

lega_scroll_finalize		proc	near
		mov	ax,ds:lega_scroll_x_max
		sub	ax,bx
		jnc	lega_scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

lega_scroll_clamp_zero:
		mov	ds:lega_scroll_x_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	lega_scroll_set_death			; Jump if zero
		retn

lega_scroll_set_death:
		mov	byte ptr ds:lega_idle_step,0
		mov	byte ptr ds:lega_anim2_active,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn

lega_scroll_finalize		endp

lega_idle_or_spawn:
		cmp	byte ptr ds:lega_idle_step,28h	; '('
;*		jae	loc_50			;*Jump if above or =
		db	073h, 04Dh		; jnc 6C6h (absolute)
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:lega_idle_step
		cmp	byte ptr ds:lega_idle_step,0Ah
		jae	lega_idle_late_phase			; Jump if above or =
		mov	al,ds:lega_idle_step
		mov	bx,lega_phase_xlat_a
		xlat				; al=[al+[bx]] table
		mov	ds:lega_phase_step,al
		cmp	al,3
		jb	lega_idle_apply			; Jump if below
		mov	byte ptr ds:gvar_spawn_fx_flag,33h	; '3'

lega_idle_apply:
		jmp	lega_phase_dir_apply
; --- idle-step xlat table (10 bytes, lega_phase_xlat_a base = A69Bh) ---
; Maps lega_idle_step (0..9) -> phase_step value via xlat
lega_idle_xlat_tbl	db	0, 1, 2, 3, 6, 7		; entries [0..5]
			db	6, 3, 2, 1			; entries [6..9]

lega_idle_late_phase:
		mov	ah,ds:lega_idle_step
		mov	al,6
		cmp	ah,6
		jae	$+8			; Jump if above or =
		mov	al,ah
		mov	bx,lega_phase_xlat_b
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[0A7BAh],al
		jmp	$-26Dh

; ------------------------------------------------------------------
; Module trailer: dispatch-table handler body + jump-table words
; + tile/cell continuation data + 'Tarso' town-name fragment.
; Entered via dispatch call [lega_dispatch_tbl+bx] from main loop.
; ------------------------------------------------------------------
			                        ;* No entry point to code
		add	ax,[bp+di]		; data bytes
		add	al,4			; data bytes
		add	ax,0C605h		; data bytes
		push	es			; data byte
;*		xor	bh,bh			; Zero register
		db	030h, 0FFh		; xor bh,bh (alt encoding) -- data bytes
;*		inc	bx
		db	0FFh, 0C3h		; inc bx (alt encoding) -- data bytes
; --- dispatch jump-table: 10 word entries pointing into cs:A6DC..A798 handlers ---

lega_dispatch_tbl_data:
		db	0DCh,0A6h,0E3h,0A6h,0ECh,0A6h	; entries [0..2]: A6DC, A6E3, A6EC
		db	0F6h,0A6h, 01h,0A7h, 0Ch,0A7h	; entries [3..5]: A6F6, A701, A70C
		db	 18h,0A7h, 22h,0A7h, 2Eh,0A7h	; entries [6..8]: A718, A722, A72E
		db	 39h,0A7h			; entry [9]: A739
; --- tile-index bank A: 6-byte cell-index rows (continuation of cell maps) ---

lega_cell_map_e:
		db	 11h, 10h, 12h, 13h	; row E0 partial (4 cells)
		db	 14h, 15h, 16h, 11h, 17h, 19h	; row E1
		db	 10h, 12h, 18h, 1Ah, 1Bh, 1Ch	; row E2
		db	 1Dh, 1Fh, 21h, 23h, 10h, 1Eh	; row E3
		db	' "$'				; row E4 partial (3 cells: 20h,22h,24h)
		db	'%)*', 27h, '&('		; row E5 (6 cells)
		db	 10h, 1Eh			; row E6 partial
		db	' "$'				; row E6 cont.
		db	'%20-1+.'			; row E7 (7 cells)
		db	 10h, 1Eh			; row E8 partial
		db	' ,/=:<;3'			; row E8 cont. (8 cells)
		db	10h				; row E9 lead byte
		db	'456789BC@D>'			; row E9 (11 cells)
		db	10h				; row E10 lead byte
		db	'?AEFXYZOPRTVQSUW'		; row E10 (16 cells)
; --- two extra-attr style 6-byte rows + 'CAh','CEh' separators ---

lega_cell_map_f:
		db	0CAh, 42h, 47h, 40h, 48h, 3Eh	; row F0
		db	 10h, 3Fh, 41h, 45h, 46h,0CEh	; row F1
		db	 42h, 4Dh, 40h, 4Ch, 3Eh, 10h	; row F2
		db	 3Fh, 41h, 45h, 46h		; row F3 partial (4 cells)
; --- secondary dispatch jump-table: 10 word entries A758..A798 ---

lega_dispatch_tbl_b:
		db	 58h,0A7h			; entry [0]: A758
		db	 60h,0A7h, 68h,0A7h, 70h,0A7h	; entries [1..3]: A760, A768, A770
		db	 78h,0A7h, 80h,0A7h, 88h,0A7h	; entries [4..6]: A778, A780, A788
		db	 90h,0A7h, 98h,0A7h, 98h,0A7h	; entries [7..9]: A790, A798, A798(dup)
; --- entity/spawn record block (6-byte records: position, flags, type) ---

lega_spawn_records:
		db	 00h, 00h, 00h, 00h, 20h,0ABh	; rec 0: spawn at (0,0), AB20
		db	 01h, 00h, 00h, 00h, 00h, 00h	; rec 1
		db	 2Ch,0ADh, 01h, 00h, 00h, 00h	; rec 2: AD2C
		db	 00h, 00h, 2Bh, 80h, 2Bh, 01h	; rec 3
		db	 00h, 00h, 05h, 10h, 28h, 80h	; rec 4
		db	 2Bh, 01h, 08h, 04h, 18h, 00h	; rec 5
		db	 28h, 80h, 2Bh, 00h, 00h, 02h	; rec 6
		db	 14h, 10h, 20h,0A8h, 0Ch, 03h	; rec 7
		db	 00h, 00h, 03h, 05h, 10h, 55h	; rec 8
		db	 00h, 01h, 00h, 00h, 00h, 00h	; rec 9
		db	 0Bh,0ABh, 53h, 00h, 01h, 00h	; rec 10
		db	 03h, 05h, 10h, 55h, 00h, 01h	; rec 11
		db	 26h, 00h, 07h, 80h, 02h, 70h	; rec 12
		db	 17h, 08h,0FFh,0ADh,0A7h,0DCh	; rec 13
		db	 05h, 11h,0BBh, 02h, 05h	; rec 14 trailing
; 'Tarso' - town-name / label string fragment
		db	'Tarso'
; trailing zero padding to round module size up
		db	99 dup (0)

seg_a		ends

		end	start