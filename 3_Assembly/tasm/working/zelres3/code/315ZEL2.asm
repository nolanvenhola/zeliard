
PAGE  59,132

;==========================================================================
;
;  315ZEL2 / run_mapht_main - Helada Town Map Program (zelres3 chunk)
;
;  Map-program code module for Helada Town. Loaded together with the town
;  data file map_helada_town.bin (315MAPHT.bin). Helada is one of the
;  overworld towns visited in zelres3 (the late-game desert/winter town).
;
;  Structure:
;    - Header / pointer table (file 0x00..~0x80) mis-decoded by Sourcer
;    - Large embedded tile/layout data block
;    - Per-frame tile scan / NPC-cell update loop
;    - Dispatch / scroll / phase-helper sub-procs
;
;  Sibling map-program modules: 312ZELA (Satono), 313MEDA (Bosque/Vista),
;  314LEGA (Tarso). All four share the same game-segment dispatch ABI
;  and per-map global state byte layout (0FF2Eh..0FF75h).
;
;  Trailer string 'aguro' is the Helada speaker / label name fragment.
;
;  Connections:
;    Loads:        none (loaded as data/code by 200FIGHT alongside ZEL2
;                  arena/map data; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_prep (200Ch), fight_cb_record_ofs (6028h),
;                  fight_cb_anim_step (6036h), fight_cb_hit_check (6038h),
;                  fight_cb_despawn (603Ah), fight_cb_shutdown (603Ch).
;    Called by:    200FIGHT level/arena dispatch (ZEL2 boss arena;
;                  no dedicated EAI handler -- shares EAI handlers with
;                  earlier ZELA/MEDA bosses).
;    Reads/writes: gvar_death_flag (0FF2Eh), gvar_dir_toggle (0FF2Fh),
;                  gvar_spawn_fx_flag (0FF75h); enemy slot list at
;                  fight_slot_list (0C010h); ZEL2 anim dispatch table
;                  zel2_anim_dispatch_tbl (0A2F8h), phase xlat
;                  (0A4DBh), per-segment slots zel2_anim_seg_a (0A543h),
;                  scroll/phase state zel2_scroll_x..zel2_phase_a_subflag
;                  (0A5DFh..0A5FAh).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_* not in zr3com.inc)
; ----------------------------------------------------------------------
zel2_state_ff30		equ	0FF30h		; per-map state flag (idle-out marker)


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
zel2_unk_c0b		equ	0C0Bh		; trailer-decoded internal addr (data ref via [bx+si])
zel2_anim_dispatch_tbl	equ	0A2F8h		; per-anim dispatch table base (call ds:[base+bx])
zel2_phase_xlat_tbl	equ	0A4DBh		; phase xlat / index table base
zel2_render_buf		equ	0A603h		; tile render buffer base (12 words)
zel2_sprite_attr_ptr	equ	0C002h		; sprite attribute scan ptr (DS word)


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
zel2_anim_state_a	equ	0A32Fh		; anim state slot A (word, written by 'and ax,2FA3h')
zel2_anim_state_b	equ	0A334h		; anim state slot B (referenced via [bp+di])
zel2_anim_state_c	equ	0A339h		; anim state slot C (word)
zel2_anim_seg_a		equ	0A543h		; anim segment slot base (idx*0Dh added)
zel2_anim_seg_a_byte_b	equ	0A544h		; anim segment slot, +01 (byte field 'al')
zel2_anim_seg_a_byte_c	equ	0A550h		; anim segment slot, +0Dh (byte field)
zel2_anim_seg_a_byte_d	equ	0A551h		; anim segment slot, +0Eh (byte field)
zel2_scroll_x		equ	0A5DFh		; scroll X position byte/word
zel2_phase_step		equ	0A5E1h		; phase step counter (mod 3Fh)
zel2_scroll_x_max	equ	0A5E2h		; scroll X max (word)
zel2_phase_byte		equ	0A5F6h		; phase byte (cycle mod 7/8)
zel2_phase_dir		equ	0A5F7h		; phase 0/1/2 selector
zel2_phase_a_flag	equ	0A5F8h		; phase-A flag
zel2_death_handler_flag	equ	0A5F9h		; death-handler flag (reset path)
zel2_phase_a_subflag	equ	0A5FAh		; phase-A subflag
zel2_anim_handler_idx	equ	0A5FBh		; anim-handler dispatch index
zel2_anim_subcounter	equ	0A5FCh		; anim sub-counter (mod 4)
zel2_npc_idx		equ	0A5FDh		; NPC scan index byte
zel2_anim_countdown	equ	0A5FEh		; anim countdown (3..0)
zel2_anim_byte		equ	0A5FFh		; current animation/speaker byte
zel2_attr_tmp		equ	0A600h		; tile attribute scratch byte
zel2_idle_step		equ	0A601h		; idle step counter (0..0x28)
zel2_phase_locked	equ	0A602h		; phase-locked flag
zel2_render_attr_a	equ	0A606h		; render attr slot A
zel2_render_attr_b	equ	0A60Ch		; render attr slot B
zel2_render_attr_c	equ	0A612h		; render attr slot C
zel2_render_attr_d	equ	0A618h		; render attr slot D


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_mapht_main	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header fields as x86 instructions; real entry
; is via dispatch from game DS. Below is a 12-byte reserved area,
; then a 32-byte 0x1Eh descriptor row.
; ------------------------------------------------------------------

start:
		sbb	ax,word ptr ds:[0]	; header field bytes
		mov	dh,0A1h			; header field
		db	0DFh,0A5h		;  header field (Sourcer left as bytes)
		db	12 dup (0)		; reserved / padding
		db	32 dup (1Eh)		; 32-byte 0x1Eh descriptor row
; --- pointer/jump-table words (5 entries: A03A, A08A, A0D0, A116, A166) ---

zel2_ptr_table_a:
		db	 3Ah,0A0h, 8Ah,0A0h,0D0h,0A0h	; ptrs[0..2]: A03A,A08A,A0D0
		db	 16h,0A1h, 66h,0A1h, 00h, 01h	; ptrs[3..4]: A116,A166 + 0001
; --- cell index map A: 6-byte rows (00 = empty cell) ---

zel2_cell_map_a:
		db	 02h, 03h, 04h, 00h, 11h, 07h	; row A0
		db	 12h, 13h, 00h, 1Eh, 16h, 1Fh	; row A1
		db	 20h, 00h, 05h, 06h, 07h, 08h	; row A2
		db	 00h, 14h, 15h, 16h, 17h, 00h	; row A3
		db	 21h, 22h, 23h, 24h, 00h, 09h	; row A4
		db	 0Ah, 0Bh, 0Ch, 00h, 18h, 19h	; row A5
		db	 1Ah, 1Bh, 00h, 25h, 26h, 27h	; row A6
		db	 1Dh, 00h, 0Dh, 0Eh, 0Fh, 10h	; row A7
		db	 00h, 1Ch, 10h, 1Dh, 10h, 00h	; row A8
		db	 28h, 10h, 29h, 2Ah, 00h, 18h	; row A9
		db	 2Bh, 1Ah, 2Ch, 00h		; row A10 (4 bytes; merges with target_base word)
zel2_scroll_target_base		dw	102Dh
; --- cell index map A continuation (post-target_base) ---

zel2_cell_map_a_cont:
		db	 2Eh, 10h, 00h, 11h, 07h, 12h	; row A11
		db	 2Fh, 00h			; row A12 head (2 bytes)
		db	30h				; row A12 byte (merges with data_word)
zel2_data_word_3115		dw	3115h			; Data table (indexed access)
; --- cell index map A tail rows (3 rows ?? 6) and ASCII tile glyph table ---

zel2_cell_map_a_tail:
		db	 17h, 00h, 32h, 33h, 34h, 35h	; row A13
		db	 00h, 41h, 42h, 43h, 44h, 00h	; row A14
		db	 1Eh, 50h, 1Fh			; row A15 head (3 bytes)

zel2_glyph_table:
		db	'Q', 0				; glyph row [0]
		db	'6789', 0			; glyph row [1]
		db	'EFGH', 0			; glyph row [2]
		db	'RST$'				; glyph row [3]
		db	0				; (terminator)
		db	':;<=', 0			; glyph row [4]
		db	'IJKL', 0			; glyph row [5]
		db	'UOVW', 0			; glyph row [6]
		db	'>', 0				; glyph row [7]
		db	'?@', 0				; glyph row [8]
		db	'MNO'				; glyph row [9]
; --- cell index map B: 6-byte rows (00 = empty cell) ---

zel2_cell_map_b:
		db	 10h, 00h, 58h, 10h, 59h, 2Ah	; row B0
		db	 00h, 49h, 5Ah, 4Bh, 5Bh, 00h	; row B1
		db	 5Ch, 4Eh, 5Dh, 5Eh, 00h, 00h	; row B2
		db	 32h, 5Fh, 60h, 00h, 6Bh, 6Ch	; row B3
		db	 6Dh, 6Eh, 00h, 79h, 7Ah, 7Bh	; row B4
		db	 7Ch, 00h, 61h, 62h, 63h, 64h	; row B5
		db	 00h, 6Fh, 70h, 71h, 72h, 00h	; row B6
		db	 7Dh, 7Eh, 7Fh, 24h, 00h, 65h	; row B7
		db	 66h, 67h, 68h, 00h, 73h, 1Dh	; row B8
		db	 74h, 75h, 00h, 80h, 4Fh, 81h	; row B9
		db	 59h, 00h, 69h, 00h, 6Ah, 00h	; row B10
		db	 00h, 76h, 77h, 4Fh, 78h, 00h	; row B11
		db	 82h, 10h, 59h, 2Ah, 00h, 73h	; row B12
		db	 83h, 74h, 84h, 00h		; row B13 (4 bytes)
		db	 76h, 77h, 4Fh, 78h		; row B14 (4 bytes; precedes rng_fn_ptr)
zel2_rng_fn_ptr		dw	0
; --- cell index map C: 6-byte rows continuing post-rng_fn_ptr ---

zel2_cell_map_c:
		db	 85h, 86h, 87h, 00h, 93h, 94h	; row C0
		db	 95h, 96h, 00h, 1Eh,0A1h,0A2h	; row C1
		db	0A3h, 00h, 88h, 89h, 8Ah, 8Bh	; row C2
		db	 00h, 97h, 98h, 99h, 9Ah, 00h	; row C3
		db	0A4h,0A5h,0A6h,0A7h, 00h, 8Ch	; row C4
		db	 8Dh, 8Eh, 67h, 00h, 9Bh, 9Ch	; row C5
		db	 9Dh, 9Eh, 00h, 25h, 26h, 27h	; row C6
		db	 1Dh, 00h, 8Fh, 90h, 91h, 92h	; row C7
		db	 00h, 1Dh, 9Fh,0A0h, 10h, 00h	; row C8
		db	 28h, 10h			; row C9 head (2 bytes)
		db	 29h, 2Ah			; row C9 tail (2 bytes)
		db	11 dup (0)			; padding to next descriptor
; --- cell index map D: 6-byte rows ---

zel2_cell_map_d:
		db	 93h,0A8h, 95h,0A9h, 00h,0AAh	; row D0
		db	0ABh,0ACh,0ADh, 00h, 00h,0AEh	; row D1
		db	 00h,0AFh, 00h,0BBh,0BCh,0BDh	; row D2
		db	0BEh, 00h, 1Eh,0CAh,0A2h,0CBh	; row D3
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h	; row D4
		db	0BFh,0C0h,0C1h,0C2h, 00h,0CCh	; row D5
		db	0CDh,0CEh,0CFh, 00h,0B4h,0B5h	; row D6
		db	0B6h,0B7h, 00h,0C3h,0C4h,0C5h	; row D7
		db	0C6h, 00h,0D0h,0D1h,0D2h,0D3h	; row D8
		db	 00h,0B8h, 00h,0B9h,0BAh, 00h	; row D9
		db	0C7h,0C8h, 4Fh,0C9h, 00h,0D4h	; row D10
		db	 10h, 1Dh, 2Ah, 00h		; row D11 (4 bytes)
		db	10 dup (0)			; padding
; --- cell index map E + trailing init code stub ---

zel2_cell_map_e:
		db	0BBh,0BCh,0BDh,0BEh, 00h,0BFh	; row E0
		db	0D5h,0C1h,0D6h, 8Bh, 36h, 10h	; row E1 (last 3 bytes = 'mov si,...')

zel2_init_code_stub:
		db	0C0h,0C6h, 06h,0FDh,0A5h, 00h	; init stub bytes (mis-decoded)
		db	0C6h, 06h,0FFh,0A5h, 00h	; init stub bytes (continued)

zel2_npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
				db	 83h, 3Ch,0FFh		;  Fixup - byte match
				jz	zel2_npc_scan_done			; Jump if zero
				mov	ax,[si]
				call	word ptr cs:fight_cb_anim_step
				jc	zel2_npc_scan_next			; Jump if carry Set
				mov	[si+3],bl
				mov	ax,[si+2]
				call	word ptr cs:fight_cb_record_ofs
				mov	bl,ds:zel2_npc_idx
				xor	bh,bh			; Zero register
				mov	al,ds:sprite_xlat_tbl[bx]
				mov	[di],al
				test	byte ptr [si+5],40h	; '@'
				jz	zel2_npc_scan_next			; Jump if zero
				test	byte ptr ds:zel2_anim_byte,80h
				jnz	zel2_npc_scan_next			; Jump if not zero
				mov	al,[si+5]
				and	al,1Fh
				mov	ds:zel2_anim_byte,al

zel2_npc_scan_next:
				inc	byte ptr ds:zel2_npc_idx
				add	si,10h
				jmp	short zel2_npc_scan_loop

zel2_npc_scan_done:
		mov	si,ds:enemy_attr_base
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:zel2_anim_byte,0FFh
		jz	zel2_phase_check_dir			; Jump if zero
		mov	al,ds:zel2_anim_byte
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		mov	byte ptr ds:gvar_spawn_fx_flag,24h	; '$'
		call	zel2_scroll_finalize
		mov	ax,zel2_scroll_target_base
		add	ax,0Fh
		mov	bx,ax
		sub	ax,ds:zel2_sprite_attr_ptr
		jc	zel2_scroll_clamp_a			; Jump if carry Set
		xchg	bx,ax

zel2_scroll_clamp_a:
		mov	ax,ds:zel2_scroll_x
		sub	ax,bx
		jnc	zel2_scroll_dec_path			; Jump if carry=0
		call	zel2_scroll_dec_step
		call	zel2_scroll_dec_step
		jmp	short zel2_phase_check_dir

zel2_scroll_dec_path:
		call	zel2_scroll_inc_step
		call	zel2_scroll_inc_step

zel2_phase_check_dir:
		test	byte ptr ds:zel2_phase_dir,0FFh
		jz	zel2_phase_check_a_flag			; Jump if zero
		jmp	zel2_idle_or_spawn_entry

zel2_phase_check_a_flag:
		test	byte ptr ds:zel2_phase_a_flag,0FFh
		jnz	zel2_phase_a_advance			; Jump if not zero
		call	word ptr cs:zel2_rng_fn_ptr
		and	al,0Fh
		jz	zel2_phase_check_death			; Jump if zero
		jmp	zel2_idle_or_spawn_entry

zel2_phase_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	zel2_phase_a_init			; Jump if zero
		jmp	zel2_idle_or_spawn_entry

zel2_phase_a_init:
		mov	byte ptr ds:zel2_phase_a_flag,0FFh
		mov	byte ptr ds:zel2_phase_a_subflag,0FFh
		mov	byte ptr ds:zel2_death_handler_flag,0FFh
		mov	byte ptr ds:zel2_anim_handler_idx,0
		mov	byte ptr ds:zel2_anim_subcounter,0
		mov	ax,zel2_scroll_target_base
		add	ax,0Eh
		mov	bx,ax
		sub	ax,ds:zel2_sprite_attr_ptr
		jc	zel2_phase_a_clamp_done			; Jump if carry Set
		xchg	bx,ax

zel2_phase_a_clamp_done:
		mov	ax,ds:zel2_scroll_x
		sub	ax,bx
		jnc	zel2_phase_a_advance			; Jump if carry=0
		mov	byte ptr ds:zel2_death_handler_flag,0

zel2_phase_a_advance:
		add	byte ptr ds:zel2_phase_byte,2
		and	byte ptr ds:zel2_phase_byte,6
		test	byte ptr ds:zel2_phase_a_subflag,0FFh
		jz	zel2_phase_anim_dispatch			; Jump if zero
		inc	byte ptr ds:zel2_anim_subcounter
		and	byte ptr ds:zel2_anim_subcounter,3
		jz	zel2_phase_subcounter_zero			; Jump if zero
		jmp	zel2_phase_xlat_apply

zel2_phase_subcounter_zero:
		mov	byte ptr ds:zel2_phase_a_subflag,0
		test	byte ptr ds:zel2_phase_a_flag,80h
		jz	zel2_phase_a_clear			; Jump if zero
		jmp	zel2_phase_xlat_apply

zel2_phase_a_clear:
		mov	byte ptr ds:zel2_phase_a_flag,0
		jmp	zel2_phase_xlat_apply

zel2_phase_anim_dispatch:
		mov	bl,ds:zel2_anim_handler_idx
		inc	byte ptr ds:zel2_anim_handler_idx
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:zel2_anim_dispatch_tbl[bx]	;*
		jmp	zel2_phase_xlat_apply

; ------------------------------------------------------------------
; Anim-dispatch handler body (entered via call ds:zel2_anim_dispatch_tbl[bx]
; above; each handler ends in retn and falls into the next handler's
; body or returns to the caller).  Sourcer could not statically trace
; the call path because the dispatch table lives in DS at runtime.
; ------------------------------------------------------------------

zel2_anim_h_set_phase_max:
		and	ax,2FA3h
		mov	ds:zel2_anim_state_a,ax
		das				; Decimal adjust
		mov	ds:zel2_anim_state_c,ax
		cmp	ss:zel2_anim_state_b[bp+di],sp
		xor	al,0A3h
		xor	al,0A3h
		or	al,0A3h
		mov	byte ptr ds:zel2_phase_a_flag,7Fh
		mov	byte ptr ds:zel2_phase_a_subflag,7Fh
		mov	byte ptr ds:zel2_phase_locked,0
		inc	byte ptr ds:zel2_phase_step
		and	byte ptr ds:zel2_phase_step,3Fh	; '?'
		retn

run_mapht_main	endp

zel2_phase_step_dec		proc	near
		dec	byte ptr ds:zel2_phase_step
		and	byte ptr ds:zel2_phase_step,3Fh	; '?'
		retn

zel2_phase_step_dec		endp

; Anim-dispatch handler entries (called via ds:zel2_anim_dispatch_tbl[bx]).
; Both entries do "phase_step_dec then return", encoded as call+jmp pairs
; that fall through to zel2_phase_locked_check.  The second entry's bytes
; are kept as raw bytes because they re-encode the same instructions
; relative to a different position.

zel2_anim_h_phase_dec_a:
		call	zel2_phase_step_dec
		jmp	short zel2_phase_locked_check

zel2_anim_h_phase_dec_b:
		db	0E8h,0E4h,0FFh		; call zel2_phase_step_dec (rel -1Ch)
		db	0EBh, 00h		; jmp short zel2_phase_locked_check

zel2_phase_locked_check:
		test	byte ptr ds:zel2_phase_locked,0FFh
		jz	zel2_idle_recompute_bx			; Jump if zero
		retn

zel2_idle_recompute_bx:
		mov	ax,zel2_scroll_target_base
		add	ax,0Ch
		mov	bx,ax
		sub	ax,ds:zel2_sprite_attr_ptr
		jc	zel2_idle_compare_scroll			; Jump if carry Set
		xchg	bx,ax

zel2_idle_compare_scroll:
		mov	ax,ds:zel2_scroll_x
		sub	ax,bx
		jnz	zel2_idle_pop_path			; Jump if not zero
		retn

zel2_idle_pop_path:
		pop	ax
		test	byte ptr ds:zel2_death_handler_flag,0FFh
		jnz	zel2_idle_call_dec			; Jump if not zero
		jmp	short zel2_idle_call_inc

zel2_idle_or_spawn_entry:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	zel2_idle_anim_count			; Jump if zero
		jmp	zel2_idle_or_spawn

zel2_idle_anim_count:
		dec	byte ptr ds:zel2_anim_countdown
		jnz	zel2_idle_phase_recompute			; Jump if not zero
		mov	byte ptr ds:zel2_anim_countdown,2
		inc	byte ptr ds:zel2_phase_byte
		and	byte ptr ds:zel2_phase_byte,7

zel2_idle_phase_recompute:
		mov	ax,zel2_scroll_target_base
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:zel2_sprite_attr_ptr
		jnc	zel2_idle_clamp_check			; Jump if carry=0
		xchg	bx,ax

zel2_idle_clamp_check:
		sub	ax,ds:zel2_scroll_x
		jnc	zel2_idle_phase_eq4			; Jump if carry=0
		test	byte ptr ds:zel2_phase_byte,0FFh
		jnz	zel2_phase_xlat_apply			; Jump if not zero

zel2_idle_call_dec:
		call	zel2_scroll_dec_step
		jnc	zel2_phase_xlat_apply			; Jump if carry=0
		mov	byte ptr ds:zel2_phase_locked,0FFh
		jmp	short zel2_phase_xlat_apply

zel2_idle_phase_eq4:
		cmp	byte ptr ds:zel2_phase_byte,4
		jne	zel2_phase_xlat_apply			; Jump if not equal

zel2_idle_call_inc:
		call	zel2_scroll_inc_step
		jnc	zel2_phase_xlat_apply			; Jump if carry=0
		mov	byte ptr ds:zel2_phase_locked,0FFh

zel2_phase_xlat_apply:
		mov	bl,ds:zel2_phase_byte
		xor	bh,bh			; Zero register
		mov	dl,ds:zel2_phase_xlat_tbl[bx]
		xor	dh,dh			; Zero register
		mov	di,zel2_render_buf
		mov	cx,0Ch

zel2_phase_render_loop:
				mov	[di],dx
				add	di,2
				inc	dh
				loop	zel2_phase_render_loop		; Loop if cx > 0

		test	byte ptr ds:zel2_phase_a_flag,0FFh
		jnz	zel2_npc_render_setup			; Jump if not zero
		test	byte ptr ds:zel2_phase_dir,0FFh
		jz	zel2_phase_dir_zero_path			; Jump if zero
		cmp	byte ptr ds:zel2_phase_dir,1
		je	zel2_phase_dir_b_path			; Jump if equal
		jmp	short zel2_phase_dir_set_attr_b

zel2_phase_dir_zero_path:
		call	word ptr cs:zel2_rng_fn_ptr
		and	al,1
		jnz	zel2_npc_render_setup			; Jump if not zero
		mov	ax,zel2_scroll_target_base
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:zel2_sprite_attr_ptr
		jc	zel2_phase_dir_clamp_a			; Jump if carry Set
		xchg	bx,ax

zel2_phase_dir_clamp_a:
		mov	ax,ds:zel2_scroll_x
		sub	ax,bx
		jnc	zel2_phase_dir_b_check			; Jump if carry=0
		dec	bx
		dec	bx
		mov	ax,ds:zel2_scroll_x
		add	ax,7
		sub	ax,bx
		jnc	zel2_npc_render_setup			; Jump if carry=0
		cmp	byte ptr ds:zel2_phase_byte,6
		jne	zel2_npc_render_setup			; Jump if not equal
		mov	byte ptr ds:zel2_phase_dir,2

zel2_phase_dir_set_attr_b:
		mov	byte ptr ds:zel2_render_attr_c,0Ch
		mov	byte ptr ds:zel2_render_attr_d,0Dh
		test	byte ptr ds:zel2_phase_byte,0FFh
		jnz	zel2_phase_dir_call_init			; Jump if not zero
		call	zel2_setup_anim_segment

zel2_phase_dir_call_init:
		jmp	short zel2_npc_render_setup

zel2_phase_dir_b_check:
		cmp	byte ptr ds:zel2_phase_byte,2
		jne	zel2_npc_render_setup			; Jump if not equal
		mov	byte ptr ds:zel2_phase_dir,1

zel2_phase_dir_b_path:
		mov	byte ptr ds:zel2_render_attr_a,0Eh
		mov	byte ptr ds:zel2_render_attr_b,0Fh
		cmp	byte ptr ds:zel2_phase_byte,4
		jne	zel2_npc_render_setup			; Jump if not equal
		call	zel2_setup_anim_segment

zel2_npc_render_setup:
		mov	byte ptr ds:zel2_npc_idx,0
		mov	di,0A603h
		mov	si,ds:enemy_attr_base
		mov	ax,ds:zel2_scroll_x
		mov	cx,4

zel2_npc_render_outer_loop:
				push	cx
				push	ax
				call	word ptr cs:fight_cb_anim_step
				pop	ax
				mov	ds:zel2_attr_tmp,bl
				jnc	zel2_npc_render_inner_init			; Jump if carry=0
				add	di,6
				jmp	short zel2_npc_render_advance

zel2_npc_render_inner_init:
				mov	bl,ds:zel2_phase_step
				mov	cx,3

zel2_npc_render_inner_loop:
						push	cx
						mov	[si],ax
						mov	[si+2],bl
						mov	dl,ds:zel2_attr_tmp
						mov	[si+3],dl
						mov	dl,[di]
						mov	[si+4],dl
						mov	byte ptr [si+5],0
						mov	dl,[di+1]
						mov	[si+6],dl
						add	di,2
						push	ax
						push	bx
						push	di
						mov	ax,[si+2]
						call	word ptr cs:fight_cb_record_ofs
						mov	bl,ds:zel2_npc_idx
						xor	bh,bh			; Zero register
						mov	al,bl
						or	al,80h
						xchg	[di],al
						mov	ds:sprite_xlat_tbl[bx],al
						add	si,10h
						inc	byte ptr ds:zel2_npc_idx
						pop	di
						pop	bx
						pop	ax
						add	bl,2
						and	bl,3Fh			; '?'
						pop	cx
						loop	zel2_npc_render_inner_loop		; Loop if cx > 0

zel2_npc_render_advance:
				inc	ax
				inc	ax
				pop	cx
				loop	zel2_npc_render_outer_loop		; Loop if cx > 0

		mov	word ptr [si],0FFFFh
		retn

; 8-byte data table (phase delta / anim table).  Sourcer mis-decoded as
; x86 'add' instructions; preserved as raw data bytes.

zel2_anim_delta_tbl		label	byte
		db	02h, 01h, 00h, 03h		; deltas[0..3]
		db	04h, 03h, 00h, 01h		; deltas[4..7]

zel2_setup_anim_segment		proc	near
		mov	al,ds:zel2_phase_step
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:zel2_anim_seg_a_byte_d,al
		mov	ds:zel2_anim_seg_a_byte_b,al
		mov	ax,ds:zel2_scroll_x
		inc	ax
		call	word ptr cs:fight_cb_anim_step
		mov	ds:zel2_anim_seg_a,bl
		mov	ax,ds:zel2_scroll_x
		add	ax,7
		call	word ptr cs:fight_cb_anim_step
		mov	ds:zel2_anim_seg_a_byte_c,bl
		mov	al,ds:zel2_phase_dir
		dec	al
		mov	cl,0Dh
		mul	cl			; ax = reg * al
		add	ax,0A543h
		mov	bx,ax
		call	word ptr cs:fight_cb_despawn
		mov	byte ptr ds:zel2_phase_dir,0
		retn

zel2_setup_anim_segment		endp

zel2_scroll_inc_step		proc	near
		cmp	byte ptr ds:zel2_scroll_x,32h	; '2'
		stc				; Set carry flag
		jnz	zel2_scroll_inc_done			; Jump if not zero
		retn

zel2_scroll_inc_done:
		inc	byte ptr ds:zel2_scroll_x
		clc				; Clear carry flag
		retn

zel2_scroll_inc_step		endp

zel2_scroll_dec_step		proc	near
		cmp	byte ptr ds:zel2_scroll_x,11h
		stc				; Set carry flag
		jnz	zel2_scroll_dec_done			; Jump if not zero
		retn

zel2_scroll_dec_done:
		dec	byte ptr ds:zel2_scroll_x
		clc				; Clear carry flag
		retn

zel2_scroll_dec_step		endp

; --- scroll-state init record: 2 parallel 16-byte slots (record A / record B) ---

zel2_scroll_init_record_a:
		db	 00h, 00h, 05h, 00h, 32h, 04h	; record A bytes [0..5]
		db	 78h				; record A byte [6]
		db	8 dup (0)			; record A padding [7..14]

zel2_scroll_init_record_b:
		db	 04h, 00h, 32h, 00h, 78h, 00h	; record B bytes [0..5]
		db	 00h, 00h, 00h, 00h, 00h	; record B padding [6..10]

zel2_scroll_finalize		proc	near
		mov	ax,ds:zel2_scroll_x_max
		sub	ax,bx
		jnc	zel2_scroll_clamp_zero			; Jump if carry=0
		xor	ax,ax			; Zero register

zel2_scroll_clamp_zero:
		mov	ds:zel2_scroll_x_max,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	zel2_scroll_set_death			; Jump if zero
		retn

zel2_scroll_set_death:
		mov	byte ptr ds:gvar_death_flag,0FFh
		mov	byte ptr ds:zel2_idle_step,0
		mov	byte ptr ds:zel2_phase_dir,0
		jmp	word ptr cs:fight_cb_shutdown

zel2_scroll_finalize		endp

zel2_idle_or_spawn:
		cmp	byte ptr ds:zel2_idle_step,28h	; '('
		jae	zel2_idle_state_set			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:zel2_idle_step
		cmp	byte ptr ds:zel2_idle_step,15h
		jae	zel2_idle_phase_reset			; Jump if above or =
		test	byte ptr ds:zel2_idle_step,3
		jnz	zel2_idle_check_phase_dir			; Jump if not zero
		mov	byte ptr ds:gvar_spawn_fx_flag,28h	; '('

zel2_idle_check_phase_dir:
		inc	byte ptr ds:zel2_phase_byte
		and	byte ptr ds:zel2_phase_byte,7

zel2_idle_phase_xlat_apply:
				mov	bx,zel2_phase_xlat_tbl
				mov	al,ds:zel2_phase_byte
				xlat				; al=[al+[bx]] table
				xor	ah,ah			; Zero register
				mov	di,zel2_render_buf
				mov	cx,0Ch

zel2_idle_render_loop:
						mov	[di],ax
						add	di,2
						inc	ah
						loop	zel2_idle_render_loop		; Loop if cx > 0

				jmp	zel2_npc_render_setup

zel2_idle_phase_reset:
				mov	byte ptr ds:zel2_phase_byte,2
				jmp	short zel2_idle_phase_xlat_apply

zel2_idle_state_set:
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; ------------------------------------------------------------------
; Module trailer: data bytes + 'aguro' string fragment + record word
; + 27 zero padding bytes.  'aguro' is the Helada speaker / label name
; fragment used by the Helada dialog code.  Sourcer mis-decoded the
; leading bytes as x86 instructions; preserved here in their original
; mis-decoded form (each line ends in a unique byte sequence that the
; assembler reproduces verbatim).
; ------------------------------------------------------------------

zel2_trailer_data:
		xor	[bx+si],al		; data bytes
		or	al,58h			; 'X' -- data bytes
		add	bh,ds:zel2_unk_c0b[bx+si]	; data bytes
;*		add	ah,ch
		db	 00h,0ECh		;  data bytes (Sourcer Fixup)
		movsw				; data byte
		inc	ax			; data byte
		push	es			; data byte
		adc	ss:zel2_trailer_word[bp+di],di	; data bytes
		push	ax			; data byte
		db	'aguro'			; speaker/label name fragment
		db	0, 0, 0, 0, 0, 0	; reserved
zel2_trailer_word		dw	0			; record terminator word
		db	2, 0			; trailer word
		db	27 dup (0)		; pad to module end

seg_a		ends

		end	start