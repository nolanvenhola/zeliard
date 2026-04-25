
PAGE  59,132

;==========================================================================
;
;  316DRGN - Map / Arena Program Code Module (zelres3 chunk 16, 0-indexed)
;
;  Per-frame map-program code module. Trailer string fragment 'gon' is the
;  tail of "dragon" or speaker name "Aragon"; the module follows the same
;  structural template as the 312-319 sibling map-program family
;  (312ZELA Satono, 313MEDA Bosque/Vista, 314LEGA Tarso, 315ZEL2 Helada).
;
;  The entry runs an NPC-scan loop over the sprite-attribute record table
;  (0C010h), walks the per-map phase state machine, and emits cell updates
;  into a render buffer at 0AA69h. Two helper procs scroll the view by
;  +/- 1 cell; a third packs render rows by 0Ah.
;
;  Structure:
;    - Header + embedded tile/cell layout data block (~file 0x00..0x270)
;    - Main per-frame update proc (drgn_main: NPC scan, phase machine,
;      death handler, render-row build)
;    - drgn_scroll_dec / drgn_scroll_inc helpers
;    - drgn_render_col_pack helper (mul-by-10 row addressing)
;    - drgn_phase_step_cb (phase callback that resets state on success)
;    - Trailer: dispatch-table data + 'gon' name fragment + zero pad
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..6038h  - game-segment dispatch callback fn ptrs
;   0C010h        - sprite attribute record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Game-segment dispatch callbacks (CS-relative ptrs in game DS) ---
drgn_cb_scroll		equ	200Ch		; scroll / dispatch callback
drgn_cb_tile_dispatch	equ	6028h		; tile-at-cell callback fn A
drgn_cb_tile_at_pos	equ	6036h		; NPC step / cell-iter callback fn B
drgn_cb_anim_lookup	equ	6038h		; entity action / anim-lookup callback fn C

; --- Internal tile/render data tables (DS, addressed by hard offset) ---
drgn_buf_tile_src	equ	8000h		; external tile source base (test sp,ds:[8000h+bx])
drgn_xlat_tbl_a4bb	equ	0A4BBh		; xlat table base (alternate render mode)
drgn_phase_si_tbl	equ	0A783h		; SI per-phase tbl base (indexed by drgn_phase_dir<<1)
drgn_phase_bp_tbl	equ	0A810h		; BP per-phase tbl base (indexed by drgn_phase_dir<<1)
drgn_si_a87a		equ	0A87Ah		; SI tile source (used standalone)
drgn_bp_a87d		equ	0A87Dh		; BP tile source (used standalone)
drgn_phase_si_tbl_b	equ	0A881h		; SI per-phase tbl B (indexed by drgn_phase_substep<<1)
drgn_phase_bp_tbl_b	equ	0A89Ah		; BP per-phase tbl B (indexed by drgn_phase_substep<<1)
drgn_phase_si_tbl_c	equ	0A8B7h		; SI per-phase tbl C (indexed by drgn_phase_substep<<1)
drgn_bp_a8d7		equ	0A8D7h		; BP tile source standalone
drgn_phase_si_tbl_d	equ	0A8DEh		; SI per-phase tbl D (indexed by drgn_phase_step&1<<1)
drgn_phase_bp_tbl_d	equ	0A8FDh		; BP per-phase tbl D
drgn_phase_di_tbl_e	equ	0A96Ch		; DI per-phase tbl E (phase-B render path)
drgn_phase_bp_tbl_e	equ	0A985h		; BP per-phase tbl E (phase-B render path)

; --- State / scroll (DS) ---
drgn_scroll_x		equ	0AA3Ch		; scroll X position word
drgn_scroll_x_hi	equ	0AA3Eh		; scroll X high byte
drgn_scroll_max		equ	0AA3Fh		; scroll max word
drgn_render_row	equ	0AA53h		; render row counter (bx component lo)
drgn_render_col	equ	0AA54h		; render col counter (bx component hi)
drgn_attr_tmp		equ	0AA55h		; attribute scratch byte
drgn_phase_b_active	equ	0AA56h		; phase-B active flag
drgn_phase_b_idx	equ	0AA57h		; phase-B index byte (cycles 2..3)
drgn_death_step		equ	0AA58h		; death animation step counter
drgn_npc_idx		equ	0AA59h		; NPC scan index byte
drgn_anim_byte		equ	0AA5Ah		; current animation/speaker byte
drgn_phase_dir		equ	0AA5Bh		; phase direction byte
drgn_phase_step		equ	0AA5Ch		; phase step counter (mod table)
drgn_phase_substep	equ	0AA5Dh		; phase substep
drgn_phase_delay	equ	0AA5Eh		; phase delay countdown (carry-tick)
drgn_phase_locked	equ	0AA5Fh		; phase-locked flag
drgn_phase_lock_ttl	equ	0AA60h		; phase lock TTL countdown
drgn_phase_a_active	equ	0AA61h		; phase-A active flag
drgn_phase_a_dir	equ	0AA62h		; phase-A direction
drgn_phase_a_step	equ	0AA63h		; phase-A step
drgn_phase_b_step	equ	0AA64h		; phase-B step counter
drgn_init_render	equ	0AA65h		; init-render flag
drgn_render_mode	equ	0AA66h		; render mode flag (toggles xlat table)
drgn_xlat_idx		equ	0AA67h		; xlat index byte
drgn_xlat_done		equ	0AA68h		; xlat-done flag
drgn_render_buf		equ	0AA69h		; render buffer base

; --- Shared game-segment globals (used across map-program family) ---
drgn_sprite_attr_ptr	equ	0C010h		; sprite attribute record ptr (DS)
drgn_sprite_xlat_tbl	equ	0ED20h		; char/tile xlat table (shared)
gvar_death_flag		equ	0FF2Eh		; global death flag
gvar_dir_toggle		equ	0FF2Fh		; global dir-toggle flag
gvar_state_ff30		equ	0FF30h		; per-map state byte
gvar_spawn_fx_flag	equ	0FF75h		; spawn VFX flag

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

drgn_main		proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header fields as x86 instructions; real entry
; is via dispatch from game DS. First byte patterns are pointer/
; descriptor fields; 12 zero bytes follow as reserved area.
; ------------------------------------------------------------------

start:
		test	ax,0Bh			; header field bytes
;*		add	ch,bl
		db	000h, 0DDh		; add ch,bl (alt encoding) -- header bytes
		mov	ds:drgn_scroll_x,al		; header field bytes
		db	12 dup (0)		; reserved / padding
		db	 28h, 1Eh, 1Eh, 1Eh, 1Eh, 1Eh
		db	 1Eh, 1Eh
		db	 28h, 28h
		db	22 dup (0)
		db	 44h,0A0h, 6Ch,0A0h,0BCh,0A0h
		db	 07h,0A1h, 52h,0A1h, 8Eh,0A1h
		db	0DEh,0A1h, 1Fh,0A2h, 47h,0A2h
		db	 97h,0A2h, 00h, 66h, 00h, 67h
		db	 6Ch, 00h, 68h, 69h, 6Dh, 6Eh
		db	 00h, 6Ch, 6Dh, 72h, 73h, 00h
		db	 83h, 84h, 00h, 86h, 00h, 95h
		db	0B1h, 98h, 99h, 00h, 9Ah, 9Bh
		db	 9Dh, 9Eh, 00h, 68h, 90h, 6Dh
		db	 91h, 00h, 9Ah, 9Bh, 9Dh,0FEh
		db	 00h, 73h, 74h, 00h, 00h
drgn_tile_data_a		db	0			; Data table (indexed access)
		db	 6Ah, 6Bh, 6Fh, 70h, 00h, 70h
		db	 71h, 75h, 76h, 00h
drgn_tile_data_b		db	77h
		db	 78h, 7Ah, 7Bh, 00h, 78h, 79h
		db	 7Bh, 7Ch, 00h, 7Dh, 7Eh, 77h
		db	 10h, 00h, 7Fh, 01h, 0Ch, 0Dh
		db	 00h, 77h, 10h, 00h, 0Eh, 00h
		db	 97h, 00h
		db	70h
drgn_tile_data_c		db	71h			; Data table (indexed access)
		db	0

drgn_tile_block_b:
		mov	bl,75h			; 'u'
;*		add	[bx+0],dh
		db	000h, 077h, 000h	; add [bx+0],dh (3-byte form)
		db	 76h, 00h, 78h, 79h, 00h,0A6h
		db	 9Fh, 87h,0A1h, 00h, 99h
drgn_tile_data_d		db	87h			; Data table (indexed access)
		db	0B3h, 88h, 00h,0A1h,0A3h, 8Ch
		db	 89h, 00h, 8Ah, 00h,0ADh, 8Dh
		db	 00h,0ADh, 8Dh, 8Bh, 10h, 00h
		db	 8Dh, 8Fh, 10h, 7Eh, 00h,0A6h
		db	 01h, 0Ch, 0Dh, 00h, 8Eh, 10h
		db	 67h, 0Eh, 00h, 6Eh, 6Fh, 73h
		db	0A7h, 00h, 6Ah, 6Bh, 6Fh,0A0h
		db	 00h,0A0h,0A1h,0A8h,0A9h, 00h
		db	 9Fh, 9Fh,0A1h,0A2h, 00h,0A2h
		db	0A3h,0AAh,0ABh, 00h,0A4h,0A5h
		db	0ACh,0ADh, 00h,0ACh,0ADh, 67h
		db	 0Eh, 00h
		db	 6Eh, 6Fh

drgn_tile_block_c:
		test	sp,ds:drgn_buf_tile_src[bx]
;*		add	drgn_tile_data_d[bx+di],0B4h
		db	082h, 081h, 0AEh, 000h, 0B4h	; add byte ptr [bx+di+0AEh],0B4h (alt encoding)
		rol	sp,cl			; Rotate
		xchg	sp,ax
;*		add	bl,dl
		db	000h, 0D3h		; add bl,dl (alt encoding)
		add	drgn_tile_data_c[si],dl
;*		test	si,[si+0]
		db	085h, 074h, 000h	; test [si+0],si (alt encoding)
		db	 00h, 00h, 00h,0DFh,0E8h,0E9h
		db	 00h,0E0h,0E1h,0EAh,0EAh, 00h
		db	0E2h,0E2h,0EAh,0EBh
drgn_tile_dispatch_word		dw	0E300h
		db	0E4h, 00h, 00h, 00h

drgn_tile_block_d:
		in	al,0E5h			; port 0E5h ??I/O Non-standard
		db	 00h, 00h, 00h, 00h,0E7h,0ECh
		db	0EDh, 00h, 00h,0F5h,0F9h,0FAh
		db	 00h,0EDh,0EEh,0F6h,0F7h, 00h
		db	0EFh,0F0h,0F8h,0EAh, 00h,0F1h
		db	0F2h,0EAh,0EBh, 00h,0F3h,0F4h
		db	 00h, 00h, 00h, 00h, 00h,0F4h
		db	 00h, 00h,0FBh,0FCh,0B2h, 96h
		db	 00h,0FDh,0FDh,0EAh,0EAh, 00h
		db	0FDh,0F3h,0E6h,0A6h, 00h, 00h
		db	 92h,0F9h,0FAh, 00h, 93h,0BBh
		db	0BAh,0BFh, 00h, 00h,0CCh,0C8h
		db	0E9h, 00h,0CFh,0CFh,0EAh,0EBh
		db	 00h,0D0h,0D1h, 00h, 00h, 00h
		db	0AFh, 00h, 00h,0B0h, 00h,0BCh
		db	0C1h,0B2h, 96h, 00h,0CAh,0F1h
		db	0FDh,0FDh, 00h,0F2h,0F3h,0FDh
		db	0F3h, 00h,0F3h,0F4h,0F3h,0F4h
		db	 00h,0FDh,0FDh,0EAh,0EAh, 00h
		db	0FDh,0F3h,0E6h,0A6h, 00h, 00h
		db	 0Eh, 20h, 21h, 00h, 0Fh, 10h
		db	 22h, 23h, 00h, 02h, 03h, 19h
		db	 10h, 00h, 04h, 05h, 1Ah, 1Bh
		db	 00h, 1Ch, 1Dh, 24h, 25h, 00h
		db	 1Eh, 1Fh, 26h, 27h, 00h, 0Eh
		db	 0Fh, 20h, 12h, 00h, 0Fh, 10h
		db	 12h, 3Ch, 00h, 02h, 03h, 19h
		db	 28h, 00h, 04h, 05h, 29h, 2Ah
		; Tile pattern tables (Sourcer mis-split strings; raw bytes from reference)
		db	00h, 1Ch, 2Bh, 3Dh, 26h, 00h, 2Ch, 11h, 27h, 31h, 00h, 0Fh
		db	10h, 37h, 38h, 00h, 02h, 03h, 32h, 33h, 00h, 04h, 05h, 34h
		db	35h, 00h, 36h, 2Ch, 26h, 27h, 00h, 11h, 11h, 31h, 39h, 00h
		db	06h, 07h, 11h, 5Ch, 00h, 11h, 42h, 3Bh, 48h, 00h, 08h, 09h
		db	3Eh, 3Fh, 00h, 43h, 44h, 49h, 4Ah, 00h, 45h, 46h, 4Bh, 4Ch
		db	00h, 47h, 16h, 4Dh, 4Eh, 00h, 11h, 4Fh, 55h, 56h, 00h, 54h
		db	 16h, 5Bh, 4Eh, 00h, 50h, 51h
		db	 57h, 58h, 00h, 52h, 53h, 59h
		db	 5Ah, 00h, 11h, 5Eh, 64h, 65h
		db	 00h, 08h, 09h, 5Dh, 3Fh, 00h
		db	 5Fh, 60h, 2Dh, 2Eh, 00h, 61h
		db	 62h, 2Fh, 30h, 00h, 63h, 16h
		db	 3Ah, 4Eh, 00h, 0Ah, 0Bh, 40h
		db	 41h, 00h, 00h, 00h, 14h, 15h
		db	 00h, 06h, 07h, 11h, 11h, 00h
		db	 13h, 75h, 17h, 77h, 00h, 17h
		db	 77h, 18h, 7Ah, 01h, 00h,0B6h
		db	0B7h, 00h, 01h, 00h,0B5h,0B6h
		db	 00h, 01h, 00h,0B6h,0B7h, 00h
		db	 01h, 00h,0B7h,0B8h, 00h, 01h
		db	 00h,0B6h,0B5h, 00h, 01h,0B9h
		db	0B6h,0B8h, 00h, 01h,0BEh,0B8h
		db	0B8h,0C0h, 01h,0B8h,0C0h,0C5h
		db	0C6h, 01h, 00h, 00h,0C2h,0C7h
		db	 01h,0BDh,0BEh,0C5h,0C3h, 01h
		db	 00h, 00h,0BDh,0C2h, 01h,0C9h
		db	0B7h,0CBh, 00h, 01h,0C9h,0CDh
		db	0CDh,0CEh, 01h, 00h,0C9h,0BEh
		db	0D2h, 01h, 00h,0CDh,0C2h,0D2h
		db	 01h,0CEh, 00h,0C2h,0D4h, 01h
		db	 00h, 00h,0D5h,0D8h, 01h, 00h
		db	 00h,0D8h,0D9h, 01h, 00h, 00h
		db	0DAh,0DCh, 01h, 00h, 00h,0DBh
		db	0DCh, 01h, 00h, 00h,0DBh,0DEh
		db	 01h, 00h, 00h,0D5h,0D6h, 01h
		db	 00h, 00h,0D6h,0D6h, 01h, 00h
		db	 00h,0D7h,0D7h, 01h, 00h, 00h
		db	0D6h,0D7h, 01h, 00h, 00h,0D8h
		db	0D9h, 01h, 00h, 00h,0DAh,0DBh
		db	 01h, 00h, 00h,0DBh,0DCh, 01h
		db	 00h, 00h,0DCh,0DBh, 01h, 00h
		db	 00h,0DDh,0DEh, 8Bh, 36h, 10h
		db	0C0h,0C6h, 06h, 59h,0AAh, 00h
		db	0C6h, 06h, 5Ah,0AAh, 00h

drgn_npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
					cmp word ptr [si],-1			; was: db 083h,03Ch,0FFh
			jz	drgn_npc_scan_done			; Jump if zero
			mov	ax,[si]
			call	word ptr cs:drgn_cb_tile_at_pos
			jc	drgn_npc_scan_next			; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:drgn_cb_tile_dispatch
			mov	bl,ds:drgn_npc_idx
			xor	bh,bh			; Zero register
			mov	al,ds:drgn_sprite_xlat_tbl[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'
			jz	drgn_npc_scan_next			; Jump if zero
			test	byte ptr ds:drgn_anim_byte,80h
			jnz	drgn_npc_scan_next			; Jump if not zero
			mov	al,[si+5]
			and	al,1Fh
			test	byte ptr [si+4],1Fh
			jnz	drgn_anim_set_high_bit			; Jump if not zero
			or	al,80h

drgn_anim_set_high_bit:
			mov	ds:drgn_anim_byte,al

drgn_npc_scan_next:
			inc	byte ptr ds:drgn_npc_idx
			add	si,10h
			jmp	short drgn_npc_scan_loop

drgn_npc_scan_done:
		mov	si,ds:drgn_sprite_attr_ptr
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:drgn_anim_byte,0FFh
		jz	drgn_check_death			; Jump if zero
		mov	al,ds:drgn_anim_byte
		push	ax
		and	al,1Fh
		call	word ptr cs:drgn_cb_anim_lookup
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		mov	ah,al
		and	ah,7Fh
		shr	bx,1			; Shift w/zeros fill
		sub	ah,2
		jc	drgn_anim_no_extra_shift			; Jump if carry Set
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill

drgn_anim_no_extra_shift:
		test	al,80h
		jz	drgn_anim_phase_b			; Jump if zero
		mov	byte ptr ds:drgn_init_render,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,34h	; '4'
		add	bx,bx
		jmp	short drgn_anim_phase_apply

drgn_anim_phase_b:
		mov	byte ptr ds:drgn_phase_locked,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,35h	; '5'

drgn_anim_phase_apply:
		call	drgn_phase_step_cb
		test	byte ptr ds:drgn_init_render,0FFh
		jz	drgn_anim_skip_reset			; Jump if zero
		mov	al,ds:drgn_phase_dir
		cmp	al,6
		sbb	al,al
		neg	al
		mov	ds:drgn_render_mode,al
		mov	byte ptr ds:drgn_xlat_idx,0
		mov	byte ptr ds:drgn_phase_b_active,0
		mov	byte ptr ds:drgn_phase_a_active,0
		mov	byte ptr ds:drgn_phase_locked,0FFh
		mov	byte ptr ds:drgn_xlat_done,0FFh
		mov	byte ptr ds:drgn_phase_lock_ttl,8

drgn_anim_skip_reset:
		mov	byte ptr ds:drgn_init_render,0

drgn_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	drgn_phase_step_advance			; Jump if zero
		jmp	drgn_death_handler

drgn_phase_step_advance:
		inc	byte ptr ds:drgn_phase_step
		test	byte ptr ds:drgn_phase_b_active,0FFh
		jz	drgn_phase_a_check			; Jump if zero
		jmp	drgn_phase_b_step_loop

drgn_phase_a_check:
		test	byte ptr ds:drgn_phase_a_active,0FFh
		jz	drgn_phase_delay_tick			; Jump if zero
		jmp	drgn_phase_inc_dir		; absolute jmp 0x4C6h

drgn_phase_delay_tick:
		add	byte ptr ds:drgn_phase_delay,80h
		jnc	drgn_phase_check_xlat			; Jump if carry=0
		test	byte ptr ds:drgn_phase_locked,0FFh
		jnz	drgn_phase_unlock_tick			; Jump if not zero
		call	drgn_scroll_dec
		jc	drgn_phase_check_xlat			; Jump if carry Set
		inc	byte ptr ds:drgn_phase_substep
		jmp	short drgn_phase_check_xlat

drgn_phase_unlock_tick:
		dec	byte ptr ds:drgn_phase_lock_ttl
		jnz	drgn_phase_locked_step			; Jump if not zero
		mov	byte ptr ds:drgn_phase_locked,0
		jmp	short drgn_phase_check_xlat

drgn_phase_locked_step:
		call	drgn_scroll_inc
		sbb	al,al
		not	al
		mov	ds:drgn_phase_locked,al
		dec	byte ptr ds:drgn_phase_substep

drgn_phase_check_xlat:
		test	byte ptr ds:drgn_xlat_done,0FFh
		jnz	drgn_xlat_advance			; Jump if not zero
		call	word ptr cs:drgn_tile_dispatch_word
		and	al,0C0h
		jnz	drgn_phase_clamp_high			; Jump if not zero
		test	byte ptr ds:drgn_phase_dir,0FFh
		jz	drgn_phase_set_active			; Jump if zero
		cmp	byte ptr ds:drgn_phase_dir,4
		je	drgn_phase_set_active			; Jump if equal
		cmp	byte ptr ds:drgn_phase_dir,7
		jne	drgn_phase_clamp_high			; Jump if not equal

drgn_phase_set_active:
		mov	al,ds:drgn_phase_dir
		mov	ds:drgn_phase_a_dir,al
		mov	byte ptr ds:drgn_phase_a_step,0
		mov	byte ptr ds:drgn_phase_a_active,0FFh
		jmp	drgn_render_begin

drgn_phase_clamp_high:
		mov	al,drgn_tile_data_b
		add	al,10h
		cmp	al,ds:drgn_scroll_x
		jae	drgn_phase_clamp_low			; Jump if above or =
		mov	al,6
		cmp	byte ptr ds:drgn_phase_dir,6
		jb	drgn_phase_clamp_high_a			; Jump if below
		mov	al,7

drgn_phase_clamp_high_a:
		mov	ds:drgn_phase_dir,al
		jmp	drgn_render_begin

drgn_phase_clamp_low:
		sub	al,5
		cmp	al,ds:drgn_scroll_x
		jae	drgn_phase_clamp_def			; Jump if above or =
		mov	al,0
		cmp	byte ptr ds:drgn_phase_dir,7
		jb	drgn_phase_clamp_low_a			; Jump if below
		mov	al,6

drgn_phase_clamp_low_a:
		mov	ds:drgn_phase_dir,al
		jmp	drgn_render_begin

drgn_phase_clamp_def:
		mov	al,4
		cmp	byte ptr ds:drgn_phase_dir,7
		jb	drgn_phase_set_dir			; Jump if below
		mov	al,6

drgn_phase_set_dir:
		mov	ds:drgn_phase_dir,al
		jmp	drgn_render_begin

drgn_xlat_advance:
		mov	bx,0A4B4h
		test	byte ptr ds:drgn_render_mode,0FFh
		jnz	drgn_xlat_use_tbl_a			; Jump if not zero
		mov	bx,drgn_xlat_tbl_a4bb

drgn_xlat_use_tbl_a:
		mov	al,ds:drgn_xlat_idx
		xlat				; al=[al+[bx]] table
		or	al,al			; Zero ?
		jns	$+9			; Jump if not sign
		and	al,7Fh
		mov	byte ptr ds:drgn_xlat_done,0
		mov	ds:drgn_phase_dir,al
		inc	byte ptr ds:drgn_xlat_idx
		jmp	drgn_render_begin
; Dead-byte gap (14 bytes, file 0x4B8..0x4C5). Sourcer mis-decoded this
; as x86 (or/push/add/cmp dh,6); the bytes are not executed -- control
; reaches drgn_phase_inc_dir at file 0x4C6 only via the absolute jmp
; from drgn_phase_a_check. Likely leftover from an earlier compile.
		db	0Ah, 09h			; orphan: or cl,[bx+di]
		db	06h				; orphan: push es
		db	03h, 02h			; orphan: add ax,[bp+si]
		db	03h, 82h, 03h, 02h		; orphan: add ax,[bp+si+0203h]
		db	03h, 02h			; orphan: add ax,[bp+si]
		db	01h, 03h			; orphan: add [bp+di],ax
		db	82h				; orphan tail byte (mis-decode prefix)

drgn_phase_inc_dir:				; entry: jmp drgn_phase_a_check->here when phase_a_active
		inc	byte ptr ds:drgn_phase_a_step	; fe 06 63 aa
		mov	al,ds:drgn_phase_a_step		; a0 63 aa
		and	al,1				; 24 01
		add	al,ds:drgn_phase_a_dir		; 02 06 62 aa
		mov	ds:drgn_phase_dir,al		; a2 5b aa
		mov	al,ds:drgn_phase_a_step		; a0 63 aa
		cmp	al,6				; 3c 06
		db	72h, 69h			; jc drgn_render_begin (rel +0x69, target inside drgn_render_begin path)
		mov	al,ds:drgn_phase_a_dir		; a0 62 aa
		inc	al				; fe c0
		mov	ds:drgn_phase_dir,al		; a2 5b aa
		mov	byte ptr ds:drgn_phase_b_idx,0	; c6 06 57 aa 00
		mov	byte ptr ds:drgn_phase_b_step,0	; c6 06 64 aa 00
		mov	byte ptr ds:drgn_phase_a_active,0	; c6 06 61 aa 00
		mov	byte ptr ds:drgn_phase_b_active,0FFh	; c6 06 56 aa ff
		mov	byte ptr ds:gvar_spawn_fx_flag,36h	; c6 06 75 ff 36 ('6')
		jmp	short drgn_render_begin		; eb 46 (target 0x546)

drgn_phase_b_step_loop:
		mov	byte ptr ds:gvar_spawn_fx_flag,36h	; '6'
		mov	al,ds:drgn_phase_b_idx
		inc	al
		cmp	al,4
		jb	drgn_phase_b_idx_set			; Jump if below
		mov	al,2

drgn_phase_b_idx_set:
		mov	ds:drgn_phase_b_idx,al
		inc	byte ptr ds:drgn_phase_b_step
		mov	al,ds:drgn_phase_b_step
		cmp	al,0Ah
		jb	drgn_render_begin			; Jump if below
		mov	byte ptr ds:drgn_phase_b_active,0
		jmp	short drgn_render_begin

drgn_main		endp

drgn_scroll_dec		proc	near
		mov	ax,ds:drgn_scroll_x
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		cmc				; Complement carry
		jnc	drgn_scroll_save_a			; Jump if carry=0
		retn

drgn_scroll_save_a:
		mov	ds:drgn_scroll_x,ax
		retn

drgn_scroll_dec		endp

drgn_scroll_inc		proc	near
		mov	ax,ds:drgn_scroll_x
		inc	ax
		mov	bx,1Eh
		sub	bx,ax
		jnc	drgn_scroll_save_b			; Jump if carry=0
		retn

drgn_scroll_save_b:
		mov	ds:drgn_scroll_x,ax
		retn

drgn_scroll_inc		endp

drgn_render_begin:
		push	cs
		pop	es
		mov	di,drgn_render_buf
		mov	ax,0FFFFh
		mov	cx,0A0h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	byte ptr ds:drgn_render_row,0
		mov	byte ptr ds:drgn_render_col,1
		mov	bl,ds:drgn_phase_dir
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:drgn_phase_si_tbl[bx]
		mov	bp,ds:drgn_phase_bp_tbl[bx]
		mov	cx,0Ch
		call	drgn_render_col_pack
		mov	byte ptr ds:drgn_render_row,0Ch
		mov	byte ptr ds:drgn_render_col,0
		mov	bl,ds:drgn_phase_step
		and	bl,1
		add	bl,bl
		mov	si,ds:drgn_phase_si_tbl_d[bx]
		mov	bp,ds:drgn_phase_bp_tbl_d[bx]
		mov	cx,0Bh
		call	drgn_render_col_pack
		mov	byte ptr ds:drgn_render_row,9
		mov	byte ptr ds:drgn_render_col,6
		mov	bl,ds:drgn_phase_substep
		and	bl,3
		add	bl,bl
		mov	si,ds:drgn_phase_si_tbl_b[bx]
		mov	bp,ds:drgn_phase_bp_tbl_b[bx]
		mov	cx,7
		call	drgn_render_col_pack
		mov	byte ptr ds:drgn_render_row,11h
		mov	byte ptr ds:drgn_render_col,6
		mov	bl,ds:drgn_phase_substep
		and	bl,3
		add	bl,bl
		mov	si,ds:drgn_phase_si_tbl_c[bx]
		mov	bp,drgn_bp_a8d7
		mov	cx,7
		call	drgn_render_col_pack
		mov	byte ptr ds:drgn_render_row,19h
		mov	byte ptr ds:drgn_render_col,8
		mov	si,drgn_si_a87a
		mov	bp,drgn_bp_a87d
		mov	cx,4
		call	drgn_render_col_pack
		mov	byte ptr ds:drgn_npc_idx,0
		mov	ax,ds:drgn_scroll_x
		mov	si,ds:drgn_sprite_attr_ptr
		mov	di,drgn_render_buf
		mov	cx,1Dh

drgn_render_row_loop:
		push	cx
		push	di
		push	ax
		call	word ptr cs:drgn_cb_tile_at_pos
		pop	ax
		mov	ds:drgn_attr_tmp,bl
		jc	drgn_render_row_advance			; Jump if carry Set
		xor	cl,cl			; Zero register

drgn_render_cell_loop:
			push	cx
			push	ax
			cmp	byte ptr [di],0FFh
			je	drgn_render_cell_skip			; Jump if equal
			mov	[si],ax
			mov	al,ds:drgn_scroll_x_hi
			add	al,cl
			and	al,3Fh			; '?'
			mov	[si+2],al
			mov	al,ds:drgn_attr_tmp
			mov	[si+3],al
			mov	al,[di]
			mov	ah,al
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			mov	bl,ds:gvar_death_flag
			not	bl
			and	bl,80h
			or	al,bl
			mov	[si+4],al
			mov	[si+6],ah
			mov	byte ptr [si+5],0
			test	byte ptr ds:drgn_anim_byte,0FFh
			jz	drgn_render_apply_anim			; Jump if zero
			or	byte ptr [si+5],20h	; ' '

drgn_render_apply_anim:
			push	di
			mov	ax,[si+2]
			call	word ptr cs:drgn_cb_tile_dispatch
			mov	bl,ds:drgn_npc_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:drgn_sprite_xlat_tbl[bx],al
			add	si,10h
			inc	byte ptr ds:drgn_npc_idx
			pop	di

drgn_render_cell_skip:
			inc	di
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,0Ah
			jne	drgn_render_cell_loop			; Jump if not equal

drgn_render_row_advance:
		inc	ax
		pop	di
		add	di,0Ah
		pop	cx
		loop	drgn_render_row_loop_jmp		; Loop if cx > 0

		jmp	short drgn_render_terminate

drgn_render_row_loop_jmp:
		jmp	drgn_render_row_loop

drgn_render_terminate:
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:drgn_phase_b_active,0FFh
		jnz	drgn_render_phase_b			; Jump if not zero
		retn

drgn_render_phase_b:
		mov	di,0A917h
		mov	bp,0A930h
		cmp	byte ptr ds:drgn_phase_dir,6
		jb	drgn_render_phase_b_pick			; Jump if below
		mov	di,drgn_phase_di_tbl_e
		mov	bp,drgn_phase_bp_tbl_e

drgn_render_phase_b_pick:
		mov	bl,ds:drgn_phase_b_idx
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	di,[bx+di]
		push	di
		mov	di,bp
		mov	bp,[bx+di]
		pop	di
		mov	ax,ds:drgn_scroll_x
		sub	ax,0Ah
		cmp	byte ptr ds:drgn_phase_dir,5
		jne	drgn_render_phase_b_no_off			; Jump if not equal
		add	ax,4

drgn_render_phase_b_no_off:
		mov	cx,0Dh

drgn_phase_b_row_loop:
		push	cx
		push	ax
		call	word ptr cs:drgn_cb_tile_at_pos
		pop	ax
		mov	ds:drgn_attr_tmp,bl
		jnc	drgn_phase_b_emit			; Jump if carry=0
		mov	cx,8

drgn_phase_b_emit_skip_loop:
			rol	byte ptr ds:[bp],1	; Rotate
			jnc	drgn_phase_b_skip_carry			; Jump if carry=0
			inc	di

drgn_phase_b_skip_carry:
			loop	drgn_phase_b_emit_skip_loop		; Loop if cx > 0

		jmp	short drgn_phase_b_row_advance

drgn_phase_b_emit:
		xor	cl,cl			; Zero register

drgn_phase_b_emit_loop:
			push	cx
			push	ax
			rol	byte ptr ds:[bp],1	; Rotate
			jnc	drgn_phase_b_skip_emit			; Jump if carry=0
			mov	[si],ax
			mov	al,ds:drgn_scroll_x_hi
			add	al,cl
			add	al,4
			and	al,3Fh			; '?'
			mov	[si+2],al
			mov	al,ds:drgn_attr_tmp
			mov	[si+3],al
			mov	al,[di]
			mov	ah,al
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			or	al,20h			; ' '
			mov	[si+4],al
			mov	[si+6],ah
			mov	byte ptr [si+5],0
			push	di
			mov	ax,[si+2]
			call	word ptr cs:drgn_cb_tile_dispatch
			mov	bl,ds:drgn_npc_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:drgn_sprite_xlat_tbl[bx],al
			add	si,10h
			inc	byte ptr ds:drgn_npc_idx
			pop	di
			inc	di

drgn_phase_b_skip_emit:
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,8
			jne	drgn_phase_b_emit_loop			; Jump if not equal

drgn_phase_b_row_advance:
		inc	ax
		inc	bp
		pop	cx
		loop	drgn_phase_b_row_loop_jmp		; Loop if cx > 0

		jmp	short drgn_phase_b_done

drgn_phase_b_row_loop_jmp:
		jmp	drgn_phase_b_row_loop

drgn_phase_b_done:
		mov	word ptr [si],0FFFFh
		retn

drgn_render_col_pack		proc	near
		mov	al,ds:drgn_render_row
		mov	bl,0Ah
		mul	bl			; ax = reg * al
		mov	bl,ds:drgn_render_col
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,0AA69h
		mov	di,ax

drgn_mul_outer_loop:
			push	cx
			mov	cx,8

drgn_mul_inner_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	drgn_mul_skip			; Jump if carry=0
				lodsb				; String [si] to al
				mov	[di],al

drgn_mul_skip:
				inc	di
				loop	drgn_mul_inner_loop		; Loop if cx > 0

			inc	di
			inc	di
			inc	bp
			pop	cx
			loop	drgn_mul_outer_loop		; Loop if cx > 0

		retn

drgn_render_col_pack		endp

; Trailer data block (file 0x788..end).  Loaded into game DS at the
; module's data-segment slot; the EQUs at the top of the file
; (drgn_phase_si_tbl @ 0xA783, etc.) point into this region at runtime.
; Sourcer mis-decoded the leading bytes as cwd/cmpsw/scasw/mov/iret;
; they are pure data -- preserved verbatim below.

drgn_data_trailer	label	byte
		db	099h, 0A7h, 0AFh, 0A7h	; cwd cmpsw scasw cmpsw mis-decode
		db	0A4h, 0A7h, 0BAh, 0A7h	; movsb cmpsw  mov dx,xxx mis-decode
		db	0C5h, 0A7h, 0CFh	; ... cmpsw iret mis-decode
		db	0A7h			; cmpsw mis-decode (No-entry #3)
		db	0DAh,0A7h,0E4h,0A7h,0FAh,0A7h
		db	0EFh,0A7h, 05h,0A8h, 00h, 02h
		db	 01h, 10h, 11h, 12h, 13h, 14h
		db	 15h, 17h, 16h, 00h, 02h, 06h
		db	 10h, 11h, 12h, 13h, 14h, 15h
		db	 17h, 16h, 00h, 03h, 01h, 2Eh
		db	 11h, 12h, 13h, 14h, 15h, 17h
		db	 16h, 00h, 03h, 06h, 2Eh, 11h
		db	 12h, 13h, 14h, 15h, 17h, 16h
		db	 05h, 04h, 19h, 18h, 13h, 1Ah
		db	 14h, 15h, 17h, 16h, 07h, 04h
		db	 76h, 77h, 18h, 13h, 1Ah, 14h
		db	 15h, 17h, 16h, 05h, 04h, 1Ch
		db	 1Bh, 1Dh, 1Eh, 1Fh, 20h, 22h
		db	 16h, 00h, 02h, 01h
		db	'#$'
		db	'%&', 27h, '()!'
		db	0, 2, 6
		db	'#$'
		db	'%&', 27h, '()!'
		db	0, 3, 1
		db	'*$'
		db	'%&', 27h, '()!'
		db	0, 3, 6
		db	'*$'
		db	'%&', 27h, '()!&'
		db	0A8h, 32h,0A8h, 26h,0A8h, 32h
		db	0A8h, 3Eh,0A8h, 4Ah,0A8h, 56h
		db	0A8h, 62h,0A8h, 6Eh,0A8h, 62h
		db	0A8h, 6Eh,0A8h, 00h, 00h, 00h
		db	 80h, 40h, 80h, 20h, 80h, 50h
		db	 16h, 00h, 04h, 00h, 00h, 00h
		db	 80h, 20h, 80h, 20h, 80h, 50h
		db	 16h, 00h, 04h, 00h, 00h, 00h
		db	 00h, 00h, 20h, 80h, 20h, 90h
		db	 36h, 00h, 04h, 00h, 00h, 00h
		db	 00h, 00h, 20h, 80h, 30h, 90h
		db	 36h, 00h, 04h, 00h, 00h, 08h
		db	 20h, 10h, 20h, 10h, 00h, 18h
		db	 0Ah, 00h, 04h, 08h, 04h, 08h
		db	 04h, 08h, 04h, 08h, 04h, 00h
		db	 06h, 00h, 04h, 08h, 02h, 08h
		db	 04h, 08h, 04h, 08h, 04h, 00h
		db	 06h, 00h, 04h, 2Bh, 2Ch, 2Dh
		db	 80h, 00h, 80h, 80h, 89h,0A8h
		db	 8Fh,0A8h, 95h,0A8h, 8Fh,0A8h
		db	'PQRTSUVWXZY[\]_^`'
		db	0A2h,0A8h,0A9h,0A8h,0B0h,0A8h
		db	0A9h,0A8h, 20h, 00h, 20h, 00h
		db	0A0h, 00h,0A0h, 00h, 20h, 20h
		db	 00h,0A0h, 00h,0A0h, 00h, 00h
		db	 20h, 00h,0A0h, 00h,0A0h,0BFh
		db	0A8h,0C7h,0A8h,0CFh,0A8h,0C7h
		db	0A8h
		db	'ubcdsetfugcisjthaklpsqtr'
		db	0A0h, 00h,0A0h, 00h,0A0h, 00h
		db	0A0h,0E2h,0A8h,0F1h,0A8h
		db	'657<08=19>2:;34@AFBGJCHKIDE'
		db	 01h,0A9h, 0Ch,0A9h, 10h, 40h
		db	 28h, 80h, 28h, 80h, 28h, 80h
		db	 30h, 80h, 80h, 10h, 00h, 28h
		db	 00h, 58h, 00h, 58h, 10h, 40h
		db	 00h, 40h, 1Fh,0A9h, 20h,0A9h
		db	 23h,0A9h, 2Ah,0A9h, 80h, 83h
		db	 82h, 81h, 8Ah, 89h, 86h, 87h
		db	 85h, 88h, 84h, 8Dh, 8Eh, 8Ch
		db	 8Fh, 8Bh, 81h, 38h,0A9h, 45h
		db	0A9h, 52h,0A9h, 5Fh,0A9h
		db	12 dup (0)
		db	 80h, 00h, 00h
		db	7 dup (0)
		db	 10h, 00h, 40h, 80h, 00h, 00h
		db	 00h, 00h, 00h, 08h, 00h, 08h
		db	 00h, 18h, 20h, 08h, 80h, 00h
		db	 00h, 00h, 00h, 00h, 08h, 00h
		db	 08h, 10h, 08h, 20h, 00h, 80h
		db	 74h,0A9h, 76h,0A9h, 79h,0A9h
		db	 7Fh,0A9h, 90h, 91h, 92h, 93h
		db	 94h, 95h, 96h, 97h, 98h, 96h
		db	 99h, 9Ah, 9Bh, 9Bh, 9Ch, 9Bh
		db	 9Dh, 8Dh,0A9h, 9Ah,0A9h,0A7h
		db	0A9h,0A7h,0A9h
		db	8 dup (0)
		db	 20h, 20h
		db	8 dup (0)
		db	 20h, 00h, 20h, 00h, 20h, 00h
		db	 00h, 00h, 20h, 20h, 00h, 20h
		db	 00h, 20h, 00h, 20h, 00h, 20h
		db	 00h, 00h, 00h

drgn_phase_step_cb		proc	near
		mov	ax,ds:drgn_scroll_max
		sub	ax,bx
		jnc	drgn_scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

drgn_scroll_clamp_zero:
		mov	ds:drgn_scroll_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:drgn_cb_scroll
		pop	ax
		or	ax,ax			; Zero ?
		jz	drgn_scroll_reset_state			; Jump if zero
		retn

drgn_scroll_reset_state:
		mov	byte ptr ds:drgn_death_step,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		mov	byte ptr ds:drgn_death_step,0
		mov	byte ptr ds:drgn_init_render,0
		mov	byte ptr ds:drgn_xlat_idx,0
		mov	byte ptr ds:drgn_phase_b_active,0
		mov	byte ptr ds:drgn_phase_a_active,0
		retn

drgn_phase_step_cb		endp

drgn_death_handler:
		cmp	byte ptr ds:drgn_death_step,28h	; '('
		jae	drgn_death_finish			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:drgn_death_step
		cmp	byte ptr ds:drgn_death_step,1Eh
		jae	drgn_death_phase_done			; Jump if above or =
		inc	byte ptr ds:drgn_phase_step
		mov	al,ds:drgn_phase_step
		and	al,1
		add	al,2
		mov	ds:drgn_phase_dir,al
		mov	al,ds:drgn_phase_step
		and	al,3
		jz	drgn_death_set_phase_x			; Jump if zero
		jmp	drgn_render_begin

drgn_death_set_phase_x:
		mov	byte ptr ds:gvar_spawn_fx_flag,37h	; '7'
		jmp	drgn_render_begin

drgn_death_phase_done:
		mov	byte ptr ds:drgn_phase_step,1
		mov	byte ptr ds:drgn_phase_dir,0Ah
		jmp	drgn_render_begin

drgn_death_finish:
		mov	byte ptr ds:gvar_state_ff30,0FFh
		retn

; ------------------------------------------------------------------
; Module trailer: dispatch-table data + 'gon' string fragment
; (suffix of "dragon" or a location/speaker name like "Aragon"),
; followed by 342 zero padding bytes.  Sourcer mis-decoded the leading
; bytes as push/add/and/loopne/etc.; they are pure data preserved here.
; ------------------------------------------------------------------

drgn_trailer_data	label	byte
		db	1Eh			; push ds (mis-decode of data)
		db	00h, 08h		; add [bx+si],cl mis-decode
		db	20h, 03h		; and [bp+di],al mis-decode
		db	0E0h, 2Eh		; loopne mis-decode
		db	05h, 00h, 49h		; add ax,4900h mis-decode
		db	0AAh			; stosb mis-decode
		db	0C4h, 09h		; les cx,[bx+di] mis-decode
		db	11h, 0BBh, 00h, 06h	; adc ss:[bp+di+0600h],di mis-decode
		db	44h			; inc sp mis-decode
		db	72h, 61h		; jc mis-decode (lands on 'a' of 'agon')
		db	'gon'			; tail of 'dragon' / 'aragon' name
		db	342 dup (0)		; pad to module end

seg_a		ends

		end	start
