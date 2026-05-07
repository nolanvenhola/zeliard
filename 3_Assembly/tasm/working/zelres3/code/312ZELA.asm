
PAGE  59,132

;==========================================================================
;
;  312ZELA / _312MAPST - Satono Town Map Program (zelres3 chunk)
;
;  Map-program code module for Satono Town (the first major town-area
;  overworld map in zelres3). Loaded together with the town data file
;  map_satono_town.bin (312MAPST.bin / renamed from ZELA-prefixed chunk).
;
;  Header byte range (file 0x00..0x79) contains small fields + an embedded
;  data-pointer table; Sourcer mis-decoded the leading bytes as code. The
;  real executable entry is at main_entry (file 0x210) after the tile/layout
;  tables that Sourcer also misidentified as code bytes.
;
;  Main responsibilities:
;    - Per-frame tile scan / NPC-cell update loop (npc_scan_loop..npc_scan_done)
;    - Dispatch table at zela_dispatch_tbl (in game DS) invoking scripted handlers
;    - Map-limit and scroll step helpers (scroll_phase_dec..scroll_apply)
;    - Contains 'gar' string fragment near end (town-name substring)
;
;  Note: The name "ZELA" in the filename is a prior-pass working nickname;
;  the disassembler-stored proc identifier _312MAPST is authoritative.
;
;  Connections:
;    Loads:        none (loaded as data/code by 200FIGHT alongside ZELA
;                  arena/map data; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_prep (200Ch), fight_cb_record_ofs (6028h),
;                  fight_cb_anim_step (6036h), fight_cb_hit_check (6038h),
;                  fight_cb_despawn (603Ah), fight_cb_shutdown (603Ch).
;    Called by:    200FIGHT level/arena dispatch (ZELA boss arena;
;                  paired with AI module 304EAI4.BIN).
;    Reads/writes: gvar_proj_cnt (0C002h), gvar_death_flag (0FF2Eh),
;                  gvar_dir_toggle (0FF2Fh), gvar_completion (0FF30h),
;                  gvar_spawn_fx_flag (0FF75h); enemy slot list at
;                  fight_slot_list (0C010h); ZELA arena state including
;                  zela_dispatch_tbl (0A307h), zela_xlat_tbl (0A4EAh),
;                  zela_init_record (0A552h), zela_scroll_x (0A5EEh),
;                  zela_scroll_phase (0A5F0h).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Section 2: Module-local exports
; ----------------------------------------------------------------------
zela_ext_word_a	equ	8802h			; external data word (mis-decoded Fixup target)
zela_ext_byte_b	equ	8E8Dh			; external data byte
zela_ext_byte_c	equ	9302h			; external data byte (via xchg at start)
zela_ext_word_b	equ	28Bh			; external data word (mis-decoded as `mov ss:[zela_ext_word_b][bp+si],cx`)


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
zela_ext_addr_e	equ	6C6h			; internal address referenced from header
zela_dispatch_tbl	equ	0A307h		; dispatch word-table base (handler ptrs)
zela_unk_tbl_a		equ	0A33Eh		; unknown table A (referenced by header)
zela_unk_tbl_b		equ	0A343h		; unknown table B
zela_unk_tbl_c		equ	0A348h		; unknown table C
zela_xlat_tbl		equ	0A4EAh		; tile-index / xlat table base
zela_init_record	equ	0A552h		; init-record row (13-byte records, base)
zela_tile_buf_lbl	equ	0A610h		; DS-base for 12-word tile fill loop


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
zela_ext_far_d	equ	0A2A1h			; far-ptr target (Fixup call far)
zela_init_field_b	equ	0A553h		; init record field B
zela_init_field_c	equ	0A55Fh		; init record field C
zela_init_field_d	equ	0A560h		; init record field D
zela_scroll_x		equ	0A5EEh		; scroll X position (word)
zela_scroll_phase	equ	0A5F0h		; scroll phase counter byte
zela_scroll_y		equ	0A5F1h		; scroll Y-ish position (word)
zela_tile_phase		equ	0A603h		; tile phase counter (mod 8)
zela_walk_state		equ	0A604h		; walk/state flag byte
zela_phase_started	equ	0A605h		; phase-started flag
zela_phase_active	equ	0A606h		; phase-active flag
zela_phase_subflag	equ	0A607h		; phase sub-flag
zela_phase_step	equ	0A608h		; phase step counter
zela_phase_subcnt	equ	0A609h		; phase sub-counter
zela_npc_idx		equ	0A60Ah		; NPC scan index byte
zela_anim_timer	equ	0A60Bh		; animation timer counter
zela_anim_byte		equ	0A60Ch		; animation/speaker byte
zela_npc_ai_byte	equ	0A60Dh		; saved NPC AI byte
zela_death_timer	equ	0A60Eh		; death-anim timer
zela_attack_done	equ	0A60Fh		; attack-done flag
zela_tile_field_a	equ	0A613h		; tile-buf field A
zela_tile_field_b	equ	0A619h		; tile-buf field B
zela_tile_field_c	equ	0A61Fh		; tile-buf field C
zela_tile_field_d	equ	0A625h		; tile-buf field D


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_312MAPST	proc	far

; ------------------------------------------------------------------
; start: - entry header + embedded tile/cell layout data
; The first instruction-decoded bytes are NOT real code; Sourcer
; mis-parsed the file's header fields and pointer descriptors as
; x86 instructions. The actual executable entry is reached via the
; dispatch table in game DS; the real instruction stream begins at
; main_entry (file 0x210) after the tile layout data below.
; ------------------------------------------------------------------

start:
		sub	byte ptr ds:[0],al	; header word 0x0028 (file 0..3 as x86)
		mov	dh,0A1h			; header field
		out	dx,al			; header field (port 0A100h - not real I/O)
		movsw				; header field byte

; 12 zero bytes: reserved / padding in header
		db	12 dup (0)

; 32 bytes of 0x1Eh: palette/colour fill descriptor (one record)
		db	32 dup (1Eh)

; Pointer table (5 word entries) + descriptor bytes feeding the
; dispatch logic. Values point inside this module (0xA0xx absolute).

zela_ptr_table_a:				; 5 word ptrs into module (0xA0xx range)
		db	 3Ah,0A0h, 8Ah,0A0h,0D0h,0A0h	; ptrs[0..2]: A03A, A08A, A0D0
		db	 16h,0A1h, 66h,0A1h		; ptrs[3..4]: A116, A166
; tile/cell descriptor records: 5-byte rows, 02h marker + 4 cell indices.
; Rows enumerate sequential tile/animation cells used by the render loop.

zela_cell_records_a:				; cell descriptor table (records of 5 bytes each)
		db	 02h, 01h, 02h, 03h, 04h	; row  0
		db	 02h, 11h, 07h, 12h, 13h	; row  1
		db	 02h, 1Eh, 16h, 1Fh, 20h	; row  2
		db	 02h, 05h, 06h, 07h, 08h	; row  3
		db	 02h, 14h, 15h, 16h, 17h	; row  4
		db	 02h, 21h, 22h, 23h, 24h	; row  5
		db	 02h, 09h, 0Ah, 0Bh, 0Ch	; row  6
		db	 02h, 18h, 19h, 1Ah, 1Bh	; row  7
		db	 02h, 25h, 26h, 27h, 1Dh	; row  8
		db	 02h, 0Dh, 0Eh, 0Fh, 10h	; row  9
		db	 02h, 1Ch, 10h, 1Dh, 10h	; row 10
		db	 02h, 28h, 10h, 29h, 2Ah	; row 11
		db	 02h, 18h, 2Bh, 1Ah, 2Ch	; row 12 (last row before const word)
		db	 02h				; row-13 leading marker (split by const word)
zela_const_word_8		dw	102Dh		; embedded constant word inside cell-records
		db	 2Eh, 10h			; row 13 trailing cells
		db	 02h, 11h, 07h, 12h, 2Fh	; row 14
		db	 02h, 30h, 15h, 31h, 17h	; row 15
		db	 02h, 32h, 33h, 34h, 35h	; row 16
		db	 02h, 41h, 42h, 43h, 44h	; row 17
		db	 02h, 1Eh, 50h, 1Fh, 51h	; row 18
		db	 02h, 36h, 37h, 38h, 39h	; row 19
		db	 02h, 45h, 46h, 47h, 48h	; row 20
		db	 02h, 52h, 53h, 54h, 24h	; row 21
		db	 02h, 3Ah, 3Bh, 3Ch, 3Dh	; row 22
		db	 02h, 49h, 4Ah, 4Bh, 4Ch	; row 23
		db	 02h, 55h, 4Fh, 56h, 57h	; row 24
		db	 02h, 3Eh, 00h, 3Fh, 40h	; row 25
		db	 02h, 4Dh, 4Eh, 4Fh, 10h	; row 26
		db	 02h, 58h, 10h, 59h, 2Ah	; row 27
		db	 02h, 49h, 5Ah, 4Bh, 5Bh	; row 28
		db	 02h, 5Ch, 4Eh, 5Dh, 5Eh	; row 29
		db	 02h, 00h, 32h, 5Fh, 60h	; row 30
		db	 02h, 6Bh, 6Ch, 6Dh, 6Eh	; row 31
		db	 02h, 79h, 7Ah, 7Bh, 7Ch	; row 32
		db	 02h, 61h, 62h, 63h, 64h	; row 33
		db	 02h, 6Fh, 70h, 71h, 72h	; row 34
		db	 02h, 7Dh, 7Eh, 7Fh, 24h	; row 35
		db	 02h, 65h, 66h, 67h, 68h	; row 36
		db	 02h, 73h, 1Dh, 74h, 75h	; row 37
		db	 02h, 80h, 4Fh, 81h, 59h	; row 38
		db	 02h, 69h, 00h, 6Ah, 00h	; row 39
		db	 02h, 76h, 77h, 4Fh, 78h	; row 40
		db	 02h, 82h, 10h, 59h, 2Ah	; row 41
		db	 02h, 73h, 83h, 74h, 84h	; row 42
		db	 02h				; row-43 leading marker (split by RNG word)
		db	 76h, 77h, 4Fh, 78h		; row 43 trailing cells
zela_rng_fn_ptr		dw	2			; CS-relative RNG fn ptr (call thru cs:zela_rng_fn_ptr)
		db	85h				; trailing descriptor byte before main_entry

main_entry:
		xchg	byte ptr ds:[zela_ext_byte_c][bx],al
		xchg	sp,ax
		xchg	bp,ax
		xchg	si,ax
		add	bl,byte ptr ds:[zela_ext_far_d]
		mov	word ptr ds:[zela_ext_word_a],ax
		mov	word ptr ss:[zela_ext_word_b][bp+si],cx
		xchg	di,ax
		cbw				; Convrt byte to word
		cwd				; Word to double word
;*		call	far ptr zela_far_sub_7		;*
		db	9Ah					; opcode prefix (Sourcer Fixup)
		dw	0A402h, 0A6A5h			; Fixup - byte match
		cmpsw					; Cmp [si] to es:[di]
		add	cl,byte ptr ds:[zela_ext_byte_b][si]	; final mis-decoded insn before cell-records continuation

; ---- continuation of cell-descriptor table (cell_records_b) ----
; Same 5-byte-row layout as zela_cell_records_a above (02h marker + 4 cells).

zela_cell_records_b:
		db	 67h				; row-0 trailing byte (record split by Sourcer)
		db	 02h, 9Bh, 9Ch, 9Dh, 9Eh	; row  1
		db	 02h, 25h, 26h, 27h, 1Dh	; row  2
		db	 02h, 8Fh, 90h, 91h, 92h	; row  3
		db	 02h, 1Dh, 9Fh,0A0h, 10h	; row  4
		db	 02h, 28h, 10h, 29h, 2Ah	; row  5
		db	 02h, 00h, 00h, 00h, 00h	; row  6 (zero/empty cell)
		db	 02h, 00h, 00h, 00h, 00h	; row  7 (zero/empty cell)
		db	 02h, 93h,0A8h, 95h,0A9h	; row  8
		db	 02h,0AAh,0ABh,0ACh,0ADh	; row  9
		db	 02h, 00h,0AEh, 00h,0AFh	; row 10
		db	 02h,0BBh,0BCh,0BDh,0BEh	; row 11
		db	 02h, 1Eh,0CAh,0A2h,0CBh	; row 12
		db	 02h,0B0h,0B1h,0B2h,0B3h	; row 13
		db	 02h,0BFh,0C0h,0C1h,0C2h	; row 14
		db	 02h,0CCh,0CDh,0CEh,0CFh	; row 15
		db	 02h,0B4h,0B5h,0B6h,0B7h	; row 16
		db	 02h,0C3h,0C4h,0C5h,0C6h	; row 17
		db	 02h,0D0h,0D1h,0D2h,0D3h	; row 18
		db	 02h,0B8h, 00h,0B9h,0BAh	; row 19
		db	 02h,0C7h,0C8h, 4Fh,0C9h	; row 20
		db	 02h,0D4h, 10h, 1Dh, 2Ah	; row 21
		db	 02h, 00h, 00h, 00h, 00h	; row 22 (zero/empty)
		db	 02h, 00h, 00h, 00h, 00h	; row 23 (zero/empty)
		db	 02h,0BBh,0BCh,0BDh,0BEh	; row 24 (duplicate of row 11)
		db	 02h,0BFh,0D5h,0C1h,0D6h	; row 25
; ---- real instruction stream resumes here (mov si,[10C0h]; mov [A60Ah],0; mov [A60Ch],0) ----

zela_main_resume:				; first real instruction after cell_records_b
		db	 8Bh, 36h, 10h,0C0h		; mov si,word ptr ds:[10C0h]  (Sourcer Fixup absolute addr)
		db	 0C6h, 06h, 0Ah,0A6h, 00h	; mov byte ptr ds:[A60Ah],0   (zela_npc_idx clear)
		db	 0C6h, 06h, 0Ch,0A6h, 00h	; mov byte ptr ds:[A60Ch],0   (zela_anim_byte clear)

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
				mov	bl,ds:zela_npc_idx
				xor	bh,bh			; Zero register
				mov	al,ds:sprite_xlat_tbl[bx]
				mov	[di],al
				test	byte ptr [si+5],40h	; '@'
				jz	npc_scan_next			; Jump if zero
				test	byte ptr ds:zela_anim_byte,80h
				jnz	npc_scan_next			; Jump if not zero
				mov	al,[si+5]
				and	al,1Fh
				mov	ds:zela_anim_byte,al

npc_scan_next:
				inc	byte ptr ds:zela_npc_idx
				add	si,10h
				jmp	short npc_scan_loop

npc_scan_done:
		mov	si,ds:enemy_attr_base
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:zela_anim_byte,0FFh
		jz	post_scroll_check_walk			; Jump if zero
		mov	al,ds:zela_anim_byte
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		pop	ax
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		cmp	al,4
		jne	npc_anim_other			; Jump if not equal
		add	bx,bx
		add	bx,bx
		mov	byte ptr ds:gvar_spawn_fx_flag,24h	; '$'
		jmp	short npc_anim_apply_scroll

npc_anim_other:
		mov	byte ptr ds:gvar_spawn_fx_flag,25h	; '%'

npc_anim_apply_scroll:
		call	scroll_apply
		mov	ax,zela_const_word_8
		add	ax,0Fh
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	scroll_clamp_b			; Jump if carry Set
		xchg	bx,ax

scroll_clamp_b:
		mov	ax,ds:zela_scroll_x
		sub	ax,bx
		jnc	scroll_step_inc_x			; Jump if carry=0
		call	bound_xpos_dec
		call	bound_xpos_dec
		jmp	short post_scroll_check_walk

scroll_step_inc_x:
		call	bound_xpos_inc
		call	bound_xpos_inc

post_scroll_check_walk:
		test	byte ptr ds:zela_walk_state,0FFh
		jz	state_check_phase_started			; Jump if zero
		jmp	phase_check_death

state_check_phase_started:
		test	byte ptr ds:zela_phase_started,0FFh
		jnz	state_post_phase_set			; Jump if not zero
		call	word ptr cs:zela_rng_fn_ptr
		and	al,0Fh
		jz	state_check_death_flag			; Jump if zero
		jmp	phase_check_death

state_check_death_flag:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	state_set_phase_flags			; Jump if zero
		jmp	phase_check_death

state_set_phase_flags:
		mov	byte ptr ds:zela_phase_started,0FFh
		mov	byte ptr ds:zela_phase_subflag,0FFh
		mov	byte ptr ds:zela_phase_active,0FFh
		mov	byte ptr ds:zela_phase_step,0
		mov	byte ptr ds:zela_phase_subcnt,0
		mov	ax,zela_const_word_8
		add	ax,0Eh
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	state_phase_clamp_b			; Jump if carry Set
		xchg	bx,ax

state_phase_clamp_b:
		mov	ax,ds:zela_scroll_x
		sub	ax,bx
		jnc	state_post_phase_set			; Jump if carry=0
		mov	byte ptr ds:zela_phase_active,0

state_post_phase_set:
		add	byte ptr ds:zela_tile_phase,2
		and	byte ptr ds:zela_tile_phase,6
		test	byte ptr ds:zela_phase_subflag,0FFh
		jz	state_idle_advance_phase			; Jump if zero
		inc	byte ptr ds:zela_phase_subcnt
		and	byte ptr ds:zela_phase_subcnt,3
		jz	state_clear_subflag			; Jump if zero
		jmp	phase_set_tile_pattern

state_clear_subflag:
		mov	byte ptr ds:zela_phase_subflag,0
		test	byte ptr ds:zela_phase_started,80h
		jz	state_clear_phase_started			; Jump if zero
		jmp	phase_set_tile_pattern

state_clear_phase_started:
		mov	byte ptr ds:zela_phase_started,0
		jmp	phase_set_tile_pattern

state_idle_advance_phase:
		mov	bl,ds:zela_phase_step
		inc	byte ptr ds:zela_phase_step
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:zela_dispatch_tbl[bx]	;*
		jmp	phase_set_tile_pattern

; -------------------------------------------------------------------------
; zela_unk_handler_1 -- dispatch handler reached via DS dispatch table
; (call [zela_dispatch_tbl+bx]).  The bytes assemble to a sequence of
; mov-immediate stores into 0xA3xx state slots (Sourcer dropped the
; explicit 3E DS-override prefixes that TASM does not preserve verbatim;
; reference bytes kept as raw db so the encoding round-trips bit-perfect).
; Final 'C3' byte = retn.
; -------------------------------------------------------------------------

zela_unk_handler_1:				; entered via zela_dispatch_tbl
; Block of 10 words at A3xx (state slot pointers / target addresses):
		db	34h, 0A3h, 3Eh, 0A3h, 3Eh, 0A3h	; A334, A33E, A33E
		db	3Eh, 0A3h, 48h, 0A3h, 48h, 0A3h	; A33E, A348, A348
		db	43h, 0A3h, 43h, 0A3h, 43h, 0A3h	; A343, A343, A343
		db	1Bh, 0A3h			; A31B
; Three byte-immediate stores (Sourcer dropped 3E DS-override prefixes):
		db	0C6h, 06h, 05h, 0A6h, 7Fh	; mov byte ptr [A605h],7Fh  (zela_phase_started=7Fh)
		db	0C6h, 06h, 07h, 0A6h, 7Fh	; mov byte ptr [A607h],7Fh  (zela_phase_subflag=7Fh)
		db	0C6h, 06h, 0Fh, 0A6h, 00h	; mov byte ptr [A60Fh],00h  (zela_attack_done clear)
; Increment + mask scroll_phase, then return:
		db	0FEh, 06h, 0F0h, 0A5h		; inc byte ptr [A5F0h]      (zela_scroll_phase++)
		db	80h, 26h, 0F0h, 0A5h, 3Fh	; and byte ptr [A5F0h],3Fh  (zela_scroll_phase &= 63)
		db	0C3h				; retn

_312MAPST	endp

;==========================================================================
; scroll_phase_dec - decrement counter byte (zela_scroll_phase) modulo 64
;==========================================================================

scroll_phase_dec		proc	near
		dec	byte ptr ds:zela_scroll_phase
		and	byte ptr ds:zela_scroll_phase,3Fh	; '?'
		retn

scroll_phase_dec		endp

; ------------------------------------------------------------------
; zela_unk_handler_2 - dispatch handler entered via zela_dispatch_tbl[bx]:
; calls scroll_phase_dec then jumps into scroll_phase_dispatch which
; continues below. The 5 trailing db bytes are a duplicate
; "call scroll_phase_dec / jmp short +0" sequence used by an alternate
; caller (alt-encoding of call E8h).
; ------------------------------------------------------------------

zela_unk_handler_2:				; entered via zela_dispatch_tbl
		call	scroll_phase_dec
		jmp	short scroll_phase_dispatch
		db	0E8h,0E4h,0FFh,0EBh, 00h	; alt: call scroll_phase_dec / jmp short (alt-encoded entry)

scroll_phase_dispatch:
		test	byte ptr ds:zela_attack_done,0FFh
		jz	scroll_phase_check_clamp			; Jump if zero
		retn

scroll_phase_check_clamp:
		mov	ax,zela_const_word_8
		add	ax,0Ch
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	scroll_phase_check_xpos			; Jump if carry Set
		xchg	bx,ax

scroll_phase_check_xpos:
		mov	ax,ds:zela_scroll_x
		sub	ax,bx
		jnz	scroll_phase_pop_dispatch			; Jump if not zero
		retn

scroll_phase_pop_dispatch:
		pop	ax
		test	byte ptr ds:zela_phase_active,0FFh
		jnz	phase_dispatch_x_dec			; Jump if not zero
		jmp	short phase_dispatch_x_inc

phase_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	phase_check_anim_timer			; Jump if zero
		jmp	death_handler

phase_check_anim_timer:
		dec	byte ptr ds:zela_anim_timer
		jnz	phase_clamp_a			; Jump if not zero
		mov	byte ptr ds:zela_anim_timer,2
		inc	byte ptr ds:zela_tile_phase
		and	byte ptr ds:zela_tile_phase,7

phase_clamp_a:
		mov	ax,zela_const_word_8
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jnc	phase_check_xpos			; Jump if carry=0
		xchg	bx,ax

phase_check_xpos:
		sub	ax,ds:zela_scroll_x
		jnc	phase_check_tile_phase4			; Jump if carry=0
		test	byte ptr ds:zela_tile_phase,0FFh
		jnz	phase_set_tile_pattern			; Jump if not zero

phase_dispatch_x_dec:
		call	bound_xpos_dec
		jnc	phase_set_tile_pattern			; Jump if carry=0
		mov	byte ptr ds:zela_attack_done,0FFh
		jmp	short phase_set_tile_pattern

phase_check_tile_phase4:
		cmp	byte ptr ds:zela_tile_phase,4
		jne	phase_set_tile_pattern			; Jump if not equal

phase_dispatch_x_inc:
		call	bound_xpos_inc
		jnc	phase_set_tile_pattern			; Jump if carry=0
		mov	byte ptr ds:zela_attack_done,0FFh

phase_set_tile_pattern:
		mov	bl,ds:zela_tile_phase
		xor	bh,bh			; Zero register
		mov	dl,ds:zela_xlat_tbl[bx]
		xor	dh,dh			; Zero register
		mov	di,zela_tile_buf_lbl
		mov	cx,0Ch

tile_fill_loop:
				mov	[di],dx
				add	di,2
				inc	dh
				loop	tile_fill_loop		; Loop if cx > 0

		test	byte ptr ds:zela_phase_started,0FFh
		jnz	npc_state_done			; Jump if not zero
		test	byte ptr ds:zela_walk_state,0FFh
		jz	npc_state_idle			; Jump if zero
		cmp	byte ptr ds:zela_walk_state,1
		je	npc_state_walk1_set			; Jump if equal
		jmp	short npc_state_walk2_set

npc_state_idle:
		call	word ptr cs:zela_rng_fn_ptr
		and	al,1
		jnz	npc_state_done			; Jump if not zero
		mov	ax,zela_const_word_8
		add	ax,12h
		mov	bx,ax
		sub	ax,ds:gvar_proj_cnt
		jc	npc_state_clamp_b			; Jump if carry Set
		xchg	bx,ax

npc_state_clamp_b:
		mov	ax,ds:zela_scroll_x
		sub	ax,bx
		jnc	npc_state_check_walk1			; Jump if carry=0
		dec	bx
		dec	bx
		mov	ax,ds:zela_scroll_x
		add	ax,7
		sub	ax,bx
		jnc	npc_state_done			; Jump if carry=0
		cmp	byte ptr ds:zela_tile_phase,6
		jne	npc_state_done			; Jump if not equal
		mov	byte ptr ds:zela_walk_state,2

npc_state_walk2_set:
		mov	byte ptr ds:zela_tile_field_c,0Ch
		mov	byte ptr ds:zela_tile_field_d,0Dh
		test	byte ptr ds:zela_tile_phase,0FFh
		jnz	npc_state_walk2_skip_init			; Jump if not zero
		call	init_tile_slots

npc_state_walk2_skip_init:
		jmp	short npc_state_done

npc_state_check_walk1:
		cmp	byte ptr ds:zela_tile_phase,2
		jne	npc_state_done			; Jump if not equal
		mov	byte ptr ds:zela_walk_state,1

npc_state_walk1_set:
		mov	byte ptr ds:zela_tile_field_a,0Eh
		mov	byte ptr ds:zela_tile_field_b,0Fh
		cmp	byte ptr ds:zela_tile_phase,4
		jne	npc_state_done			; Jump if not equal
		call	init_tile_slots

npc_state_done:
		mov	byte ptr ds:zela_npc_idx,0
		mov	di,0A610h
		mov	si,ds:enemy_attr_base
		mov	ax,ds:zela_scroll_x
		mov	cx,4

npc_update_outer:
				push	cx
				push	ax
				call	word ptr cs:fight_cb_anim_step
				pop	ax
				mov	ds:zela_npc_ai_byte,bl
				jnc	npc_update_emit			; Jump if carry=0
				add	di,6
				jmp	short npc_update_outer_next

npc_update_emit:
				mov	bl,ds:zela_scroll_phase
				mov	cx,3

npc_update_inner:
						push	cx
						mov	[si],ax
						mov	[si+2],bl
						mov	dl,ds:zela_npc_ai_byte
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
						mov	bl,ds:zela_npc_idx
						xor	bh,bh			; Zero register
						mov	al,bl
						or	al,80h
						xchg	[di],al
						mov	ds:sprite_xlat_tbl[bx],al
						add	si,10h
						inc	byte ptr ds:zela_npc_idx
						pop	di
						pop	bx
						pop	ax
						add	bl,2
						and	bl,3Fh			; '?'
						pop	cx
						loop	npc_update_inner		; Loop if cx > 0

npc_update_outer_next:
				inc	ax
				inc	ax
				pop	cx
				loop	npc_update_outer		; Loop if cx > 0

		mov	word ptr [si],0FFFFh
		retn

; ------------------------------------------------------------------
; zela_dispatch_lookup_row -- 8 bytes of data between procs.  Small lookup
; row indexed by entries in zela_dispatch_tbl; values are 4 x 2-byte
; records (Sourcer mis-decoded as x86 code).  Kept as decoded mnemonics
; so byte sequence round-trips cleanly while showing the data layout.
; ------------------------------------------------------------------

zela_dispatch_lookup_row:			; data, referenced via dispatch table
		add	al,[bx+di]		; data: 02 01
		add	[bp+di],al		; data: 00 03
		add	al,3			; data: 04 03
		add	[bx+di],al		; data: 00 01

;==========================================================================
; init_tile_slots - initialise 3 tile-data slots (zela_init_field_d/27e/26e/28e)
;        from current scroll position, then dispatch per-column init
;==========================================================================

init_tile_slots		proc	near
		mov	al,ds:zela_scroll_phase
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:zela_init_field_d,al
		mov	ds:zela_init_field_b,al
		mov	ax,ds:zela_scroll_x
		inc	ax
		call	word ptr cs:fight_cb_anim_step
		mov	ds:zela_init_record,bl
		mov	ax,ds:zela_scroll_x
		add	ax,7
		call	word ptr cs:fight_cb_anim_step
		mov	ds:zela_init_field_c,bl
		mov	al,ds:zela_walk_state
		dec	al
		mov	cl,0Dh
		mul	cl			; ax = reg * al
		add	ax,0A552h
		mov	bx,ax
		call	word ptr cs:fight_cb_despawn
		mov	byte ptr ds:zela_walk_state,0
		retn

init_tile_slots		endp

bound_xpos_inc		proc	near
		cmp	byte ptr ds:zela_scroll_x,32h	; '2'
		stc				; Set carry flag
		jnz	xpos_inc_apply			; Jump if not zero
		retn

xpos_inc_apply:
		inc	byte ptr ds:zela_scroll_x
		clc				; Clear carry flag
		retn

bound_xpos_inc		endp

bound_xpos_dec		proc	near
		cmp	byte ptr ds:zela_scroll_x,11h
		stc				; Set carry flag
		jnz	xpos_dec_apply			; Jump if not zero
		retn

xpos_dec_apply:
		dec	byte ptr ds:zela_scroll_x
		clc				; Clear carry flag
		retn

bound_xpos_dec		endp

; ------------------------------------------------------------------
; zela_xpos_bounds_tbl -- inter-proc data block (29 bytes):
; small word/byte tables consulted by the scroll/xpos clamp helpers.
; Two parallel records of low/high bounds + zero-padding.
; ------------------------------------------------------------------

zela_xpos_bounds_tbl:
		db	 00h, 00h			; word 0000h (low bound base)
		db	 15h, 00h			; word 0015h (mid bound)
		db	 32h, 04h			; word 0432h (high bound)
		db	 50h				; lone byte 50h (extra step)
		db	8 dup (0)			; padding (8 zero bytes)
		db	 14h, 00h			; word 0014h
		db	 32h, 00h			; word 0032h
		db	 50h, 00h			; word 0050h
		db	 00h, 00h, 00h, 00h, 00h	; trailing zero pad

scroll_apply		proc	near
		mov	ax,ds:zela_scroll_y
		sub	ax,bx
		jnc	scroll_y_clamped			; Jump if carry=0
		xor	ax,ax			; Zero register

scroll_y_clamped:
		mov	ds:zela_scroll_y,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	scroll_apply_done			; Jump if zero
		retn

scroll_apply_done:
		mov	byte ptr ds:gvar_death_flag,0FFh
		mov	byte ptr ds:zela_death_timer,0
		mov	byte ptr ds:zela_walk_state,0
		jmp	word ptr cs:fight_cb_shutdown

scroll_apply		endp

death_handler:
		cmp	byte ptr ds:zela_death_timer,28h	; '('
		jae	death_done_set_completion			; Jump if above or =
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		inc	byte ptr ds:zela_death_timer
		cmp	byte ptr ds:zela_death_timer,15h
		jae	death_phase_reset			; Jump if above or =
		test	byte ptr ds:zela_death_timer,3
		jnz	death_phase_advance			; Jump if not zero
		mov	byte ptr ds:gvar_spawn_fx_flag,28h	; '('

death_phase_advance:
		inc	byte ptr ds:zela_tile_phase
		and	byte ptr ds:zela_tile_phase,7

death_tile_fill:
				mov	bx,zela_xlat_tbl
				mov	al,ds:zela_tile_phase
				xlat				; al=[al+[bx]] table
				xor	ah,ah			; Zero register
				mov	di,zela_tile_buf_lbl
				mov	cx,0Ch

death_tile_fill_loop:
						mov	[di],ax
						add	di,2
						inc	ah
						loop	death_tile_fill_loop		; Loop if cx > 0

				jmp	npc_state_done

death_phase_reset:
				mov	byte ptr ds:zela_tile_phase,2
				jmp	short death_tile_fill

death_done_set_completion:
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; ------------------------------------------------------------------
; zela_module_trailer -- module trailer (file 0x623..0x62B):
; data records + 'gar' string fragment.  Sourcer mis-decoded the
; first ~24 bytes as x86 code but they are table data feeding the
; dispatch entries above. The 'gar' bytes (file 0x643) are a
; speaker/name string fragment from a parent label table.
; ------------------------------------------------------------------

zela_module_trailer:				; module-tail data block
		xor	[bx+si],al		; data row
		or	al,0F4h			; data bytes
;*		add	ax,bp
		db	 01h,0E8h		;  data bytes (Sourcer Fixup)
		add	cx,[si]			; data row
;*		add	bl,bh
		db	 00h,0FBh		;  data bytes (Sourcer Fixup)
		movsw				; data byte
		pop	ax			; data byte
		add	dl,[bp+si]		; data bytes
		mov	bx,400h			; data bytes
		inc	cx			; data byte
		db	 'gar', 0		; speaker-name fragment
		db	7 dup (0)		; reserved
		db	2, 0			; trailer word
		db	27 dup (0)		; pad to module end

seg_a		ends

		end	start