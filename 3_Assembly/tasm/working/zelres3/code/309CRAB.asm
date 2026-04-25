
PAGE  59,132

;==========================================================================
;
;  309CRAB.BIN - Crab Enemy Code Module (zelres3 chunk 10, 'Cangrejo')
;
;  Crab-type enemy sprite/logic module loaded by 200FIGHT.asm alongside
;  301EAI1 (Crab AI handler).  The Spanish name 'Cangrejo' ('crab')
;  appears as an 8-char name tag in the module's trailing data.
;
;  File layout (loaded at game_seg:0xA000 by 200FIGHT):
;    0x000..0x003 : file-size header word + pad (NOT executable code -
;                   Sourcer mis-decodes as `out dx,al / pop es / add [bx+si],al`)
;    0x004..0x007 : init src/dst pointers (crab_init_src=0xA2F0, crab_init_dst=fight_hp)
;    0x008..0x013 : 12 zero bytes (initial state buffer)
;    0x014..0x029 : template byte 06h x 21  (per-slot default state)
;    0x029..0x02A : 0Fh marker
;    0x02A..0x034 : template byte 06h x 10  (extended slots)
;    0x034..0x045 : crab_frame_ptr_tbl_a  -- 9 pointers to sprite frame rows
;    0x046..0x053 : 14 zero bytes (reserved)
;    0x054..0x05F : crab_frame_ptr_tbl_b  -- 5 pointers (+1 empty slot)
;    0x05C..0x301 : 14 sprite frame data rows (45..50 bytes each, tile indices)
;    0x302 onward : executable code (entered via 200FIGHT dispatch tables in DS)
;    ~0x7D8       : 8-byte name tag 'Cangrejo'
;
;  Primary code entry: scan_slot_loop (at 0x0302) -- iterates the enemy
;  slot list (SI = fight_slot_list), updates each live slot via fight-
;  engine callbacks, then drives crab spawn/animation phases.  The
;  helpers hp_dec/hp_inc adjust fight_hp; emit_sprite_rows writes crab
;  sprite rows into the slot buffer.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; Fight-engine callback vectors / shared globals (DS at game_seg).

fight_cb_prep		equ	200Ch			; prep/init callback
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_anim_step	equ	6036h			; animation advance callback
fight_cb_hit_check	equ	6038h			; per-slot hit/collision query
sprite_src_alt		equ	8080h			; alternate sprite-source base
sprite_src_aux		equ	80A1h			; auxiliary sprite-source base

; Crab-specific global state (DS, game_seg).

crab_spawn_limit	equ	0A481h			; max simultaneous crab spawns
crab_anim_tbl_a		equ	0A5B6h			; crab animation sequence A
crab_anim_tbl_b		equ	0A5F5h			; crab animation sequence B (misc)
crab_anim_tbl_c		equ	0A5F9h			; crab animation sequence C
crab_pos_tbl		equ	0A70Ah			; crab spawn position/grid table
fight_hp		equ	0A7C3h			; current fight HP (crab counter)
crab_phase_base		equ	0A7C5h			; phase-base byte
crab_phase_limit	equ	0A7C6h			; phase-limit byte
crab_slot_idx		equ	0A7DCh			; current slot index
crab_state_bits		equ	0A7DDh			; packed state bits
crab_frame_idx		equ	0A7DEh			; frame index (0..5)
crab_flag_d		equ	0A7DFh			; flag byte (phase selector)
crab_dir_flag		equ	0A7E0h			; direction flag
crab_sub_phase		equ	0A7E1h			; sub-phase counter
crab_flag_g		equ	0A7E2h			; crab activity flag
crab_flag_h		equ	0A7E3h			; crab persistent flag (spawn counter)
crab_alt_phase		equ	0A7E4h			; alt-phase flag (idle/alternate mode)
crab_idx_e		equ	0A7E5h			; crab helper index E
crab_anim_idx		equ	0A7E6h			; animation step index
crab_anim_frame		equ	0A7E7h			; current animation frame
crab_row_pos		equ	0A7E8h			; current row position
crab_col_pos		equ	0A7E9h			; current col position
crab_anim_base		equ	0A7EAh			; animation base (word)
crab_timer_a		equ	0A7ECh			; phase timer A
crab_timer_b		equ	0A7EDh			; phase timer B (death animation)
fight_state_max		equ	0C002h			; max state index (for wrap)
fight_slot_list		equ	0C010h			; base of enemy/crab slot list
sprite_idx_table	equ	0ED20h			; sprite index mapping table
gvar_death_flag		equ	0FF2Eh			; crab death flag global
gvar_dir_toggle		equ	0FF2Fh			; dir-toggle flag global
gvar_completion		equ	0FF30h			; completion/stage flag global
gvar_spawn_fx_flag	equ	0FF75h			; flag byte for spawn VFX

; ----- Slot-record layout helpers (for readability in code below) -----
;   [si+0..1] = sprite tile word   [si+4] = attribute  [si+5] = flags
;   [si+2..3] = record indices     [si+6] = frame      [si+10h] = next

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

crab_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer forced `start:` here but no execution lands here; the bytes are
;  actually a 4-byte length header, a 4-byte init src/dst pair, and two
;  template blocks used to initialize the per-slot state buffer.
; -------------------------------------------------------------------------

start:

file_header:
		db	0EEh, 07h		; file length word: 0x07EE (= file_size - 4)
		db	 00h, 00h		; pad / flag word

crab_init_src_dst:
		db	0F0h,0A2h		; init src ptr = 0xA2F0 (into frame data)
		db	0C3h,0A7h		; init dst ptr = fight_hp (0xA7C3)

		db	12 dup (0)		; initial per-slot state buffer
		db	21 dup (6)		; template byte 06h x 21 (slot defaults)
		db	0Fh			; section marker
		db	10 dup (6)		; template byte 06h x 10 (extended)

; -------------------------------------------------------------------------
;  Animation frame pointer tables (word ptr[], into frame data below).
;  Each word = runtime address in game_seg (= 0xA000 + file offset).
; -------------------------------------------------------------------------

crab_frame_ptr_tbl_a	label	word		; indexed frame pointers (group A)
		db	 5Ch,0A0h, 8Eh,0A0h,0BBh,0A0h	; -> 0xA05C, 0xA08E, 0xA0BB
		db	0EDh,0A0h, 1Fh,0A1h, 4Ch,0A1h	; -> 0xA0ED, 0xA11F, 0xA14C
		db	 7Eh,0A1h,0B0h,0A1h,0E2h,0A1h	; -> 0xA17E, 0xA1B0, 0xA1E2
		db	14 dup (0)			; reserved / padding

crab_frame_ptr_tbl_b	label	word		; indexed frame pointers (group B)
		db	 14h,0A2h, 46h,0A2h, 73h,0A2h	; -> 0xA214, 0xA246, 0xA273
		db	 00h, 00h,0A5h,0A2h,0D7h,0A2h	; slot0=empty, -> 0xA2A5, 0xA2D7

; -------------------------------------------------------------------------
;  Sprite frame data (file offsets 0x05C..0x301).
;  Fourteen blocks of 45 or 50 bytes each, indexed by the pointer tables
;  above.  Each block is a run of tile-index bytes (0..0xFF) that define
;  one crab animation frame laid out as a small tile grid.  Zero bytes
;  mark row-terminator positions within a frame.
; -------------------------------------------------------------------------

crab_frame_00:					; offset 0x05C -> ptr 0xA05C
		db	 00h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 26h, 27h, 00h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 26h, 27h, 00h, 00h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 26h, 27h
		db	 00h, 00h
crab_const_2600	dw	2600h			; shared word constant (used via `mov ax`)
		db	 27h, 00h, 00h, 00h, 26h, 27h
		db	 00h, 00h, 00h, 00h, 00h, 00h

crab_frame_01:					; offset 0x08E -> ptr 0xA08E
		db	 01h, 02h, 0Ah, 0Bh, 00h, 00h
		db	 00h, 02h, 00h, 00h, 00h, 00h
		db	 28h, 29h, 00h, 00h, 00h, 02h
		db	 00h, 00h, 00h, 00h, 28h, 29h
		db	 00h, 00h, 00h, 02h, 00h, 00h
		db	 00h, 00h, 28h, 29h, 00h, 00h
		db	 00h, 28h, 29h, 00h, 00h, 00h
		db	 28h, 29h, 00h, 00h

crab_frame_02:					; offset 0x0BB -> ptr 0xA0BB
		db	 00h, 00h, 00h, 00h, 03h, 04h, 00h, 05h
		db	 00h, 2Ah, 2Bh, 2Ch, 2Dh, 00h
		db	 03h, 04h, 00h, 47h, 00h, 2Ah
		db	 2Bh, 2Ch, 58h, 00h, 03h, 04h
		db	 00h, 69h, 00h, 2Ah, 2Bh, 2Ch
		db	 72h, 00h, 03h, 04h, 00h, 05h
		db	 00h, 03h, 04h, 00h, 05h, 00h
		db	 8Fh, 90h, 00h, 91h, 00h

crab_frame_03:					; offset 0x0ED -> ptr 0xA0ED
		db	0ADh
		db	0AEh,0AFh,0B0h, 00h, 06h, 07h
		db	 08h, 09h, 00h, 06h, 2Fh, 30h
		db	 31h, 00h, 06h, 07h, 48h, 49h
		db	 00h, 06h, 2Fh, 59h, 5Ah, 00h
		db	 06h, 07h, 59h, 5Ah, 00h, 06h
		db	 2Fh, 73h, 74h, 00h, 06h, 2Fh
		db	 08h, 09h, 00h, 06h, 2Fh, 08h
		db	 09h, 00h

crab_frame_04:					; offset 0x11F -> ptr 0xA11F
crab_const_2692	dw	2692h			; shared word constant (also used via `call word ptr cs:`)
		db	 93h, 94h, 00h,0B1h, 07h,0B2h
		db	0B3h, 00h, 0Ah, 0Bh, 0Ch, 0Dh
		db	 00h, 32h, 33h, 0Ch, 0Dh, 00h
		db	 0Ah, 0Bh, 0Ch, 0Dh, 00h, 32h
		db	 33h, 0Ch, 0Dh, 00h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 00h, 32h, 33h, 0Ch
		db	 0Dh, 00h, 32h, 33h,0C5h,0C6h

crab_frame_05:					; offset 0x14C -> ptr 0xA14C
		db	 00h, 32h, 33h, 0Ch, 0Dh, 00h
		db	 27h, 28h, 32h, 33h, 00h, 0Eh
		db	 35h, 10h, 11h, 00h, 34h, 35h
		db	 36h, 37h, 00h, 0Eh, 35h, 4Ah
		db	 4Bh, 00h, 34h, 35h, 5Bh, 5Ch
		db	 00h, 0Eh, 35h, 5Bh, 5Ch, 00h
		db	 34h, 35h, 75h, 76h, 00h, 34h
		db	 35h, 84h, 85h, 00h, 34h

crab_frame_06:					; offset 0x17E -> ptr 0xA17E
		db	 35h
		db	 84h, 85h, 00h, 29h, 95h, 96h
		db	 97h, 00h, 0Eh,0B4h,0B5h,0B6h
		db	 00h, 12h, 13h, 14h, 15h, 00h
		db	 38h, 39h, 3Ah, 00h, 00h, 12h
		db	 13h, 4Ch, 15h, 00h, 38h, 39h
		db	 5Dh, 00h, 00h, 12h, 13h, 5Dh
		db	 15h, 00h, 38h, 39h, 77h, 00h
		db	 00h, 12h, 13h, 14h, 15h, 00h

crab_frame_07:					; offset 0x1B0 -> ptr 0xA1B0
		db	 12h, 13h, 14h, 15h, 00h, 98h
		db	 99h, 9Ah, 00h, 00h,0B7h,0B8h
		db	0B9h,0BAh, 00h, 00h, 16h, 00h
		db	 17h, 00h, 00h, 3Bh, 3Ch, 3Dh
		db	 00h, 00h, 4Dh, 00h, 4Eh, 00h
		db	 5Eh, 5Fh, 00h, 60h, 00h, 0Fh
		db	 2Eh, 6Ah, 6Bh, 00h, 78h, 79h
		db	 7Ah, 7Bh, 00h, 86h, 87h, 00h
		db	 88h, 00h

crab_frame_08:					; offset 0x1E2 -> ptr 0xA1E2
		db	 86h, 87h, 00h, 88h
		db	 00h, 9Bh, 9Ch, 9Dh, 9Eh, 00h
		db	0BBh,0BFh,0BCh, 00h, 00h, 23h
		db	 24h, 25h, 00h, 00h, 3Eh, 00h
		db	 3Fh, 00h, 00h, 55h, 00h, 56h
		db	 57h, 00h, 65h, 66h, 67h, 68h
		db	 00h, 6Fh, 70h, 71h, 00h, 00h
		db	 80h, 81h, 82h, 83h, 00h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 00h

crab_frame_09:					; offset 0x214 -> ptr 0xA214
		db	 8Bh, 8Ch
		db	 8Dh, 8Eh, 00h,0A9h,0AAh,0ABh
		db	0ACh, 00h, 00h,0C1h, 00h,0C2h
		db	 00h, 18h, 19h, 1Ah, 1Bh, 00h
		db	 40h, 19h, 42h, 43h, 00h, 4Fh
		db	 19h, 50h, 51h, 00h, 61h, 19h
		db	 62h, 1Bh, 00h, 6Ch, 19h, 6Dh
		db	 43h, 00h, 7Ch, 19h, 7Dh, 43h
		db	 00h, 18h, 19h, 00h, 1Bh, 00h

crab_frame_10:					; offset 0x246 -> ptr 0xA246
		db	 18h, 19h, 00h, 1Bh, 00h, 9Fh
		db	0A0h,0A1h,0A2h, 00h,0BDh, 19h
		db	0BFh, 43h, 00h, 1Ch, 1Dh, 1Eh
		db	 00h, 00h, 1Ch, 1Dh, 00h, 44h
		db	 00h, 1Ch, 1Dh, 1Eh, 44h, 00h
		db	 1Ch, 1Dh, 1Eh, 00h, 00h, 1Ch
		db	 1Dh, 00h, 00h, 00h, 1Ch, 1Dh
		db	 00h, 44h, 00h

crab_frame_11:					; offset 0x273 -> ptr 0xA273
		db	 1Ch, 1Dh, 1Eh
		db	 00h, 00h, 1Ch, 1Dh, 1Eh, 00h
		db	 00h, 0Ch, 0Dh,0A3h,0A4h, 00h
		db	 1Fh, 20h, 21h, 22h, 00h, 1Fh
		db	 41h, 45h, 46h, 00h, 1Fh, 52h
		db	 53h, 54h, 00h, 1Fh, 63h, 21h
		db	 64h, 00h, 1Fh, 63h, 21h, 6Eh
		db	 00h, 1Fh, 7Eh, 53h, 7Fh, 00h
		db	 1Fh, 89h, 21h, 8Ah, 00h

crab_frame_12:					; offset 0x2A5 -> ptr 0xA2A5
		db	 1Fh
		db	 89h, 21h, 8Ah, 00h,0A5h,0A6h
		db	0A7h,0A8h, 00h, 1Fh,0BEh, 21h
		db	0C0h, 00h,0C7h,0C8h, 1Ch, 1Dh
		db	 00h,0C9h,0CAh, 1Ch, 1Dh, 00h
		db	0CBh,0CCh,0CDh,0CEh, 00h,0CFh
		db	0D0h,0D1h,0D2h, 00h,0D3h,0D4h
		db	0D5h,0D6h, 00h,0C3h,0C4h, 1Ch
		db	 1Dh, 00h,0C5h,0C6h, 1Ch, 1Dh

crab_frame_13:					; offset 0x2D7 -> ptr 0xA2D7
		db	 00h, 0Ch, 0Dh, 1Ch, 1Dh, 00h
		db	 0Ch, 0Dh, 1Ch, 1Dh, 00h, 0Ch
		db	 0Dh, 1Ch, 1Dh, 00h,0D7h,0D8h
		db	0D9h, 00h, 00h,0DAh,0DBh,0DCh
		db	0DDh, 00h,0DEh,0DFh, 00h, 00h
		db	 00h,0E0h,0E1h, 00h, 00h, 00h
		db	0E2h,0E3h, 00h, 00h

; Small trailing tail before the first executable label (used by slot-setup).
;   Bytes: 8Bh 36h 10h 0C0h  C6h 06h DCh A7h 00h  C6h 06h DDh A7h 00h
;   = mov si,ds:[C010h]              ; mov si, fight_slot_list
;     mov byte ptr ds:[A7DCh], 0     ; crab_slot_idx = 0
;     mov byte ptr ds:[A7DDh], 0     ; crab_state_bits = 0
; These may be reused by 200FIGHT as a small setup-code stub; here they
; fall through directly into scan_slot_loop (loc_1) and so function as
; the actual prolog for every scan.

crab_scan_prolog:
		db	 8Bh, 36h, 10h,0C0h		; mov si, fight_slot_list
		db	0C6h, 06h,0DCh,0A7h, 00h	; mov byte ptr crab_slot_idx, 0
		db	0C6h, 06h,0DDh,0A7h, 00h	; mov byte ptr crab_state_bits, 0

; -------------------------------------------------------------------------
;  Main scan-and-update entry (file offset 0x302).
;  Walks the enemy slot list updating each live slot, then either spawns
;  new crabs (low fight_hp) or retires slots (high fight_hp), then
;  dispatches the per-frame phase (loc_27/loc_43/loc_44/loc_24/loc_23).
; -------------------------------------------------------------------------

scan_slot_loop:					; was loc_1
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		; cmp word ptr [si], 0FFFFh
							;  (alt encoding: sign-extended imm8 form;
							;   TASM emits 4-byte form, so keep as db)
			jz	scan_done		; end-of-list sentinel
			mov	ax,[si]
			call	word ptr cs:fight_cb_anim_step
			jc	scan_next_slot		; callback consumed slot -> skip
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:crab_slot_idx
			xor	bh,bh			; Zero register
			mov	al,ds:sprite_idx_table[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'  bit6 = active
			jz	scan_next_slot
			test	byte ptr ds:crab_state_bits,80h
			jnz	scan_next_slot
			mov	al,[si+5]
			and	al,1Fh
			test	byte ptr [si+4],10h
			jz	apply_state_bits	; was loc_2
			or	al,80h

apply_state_bits:				; was loc_2
			mov	ds:crab_state_bits,al

scan_next_slot:					; was loc_3
			inc	byte ptr ds:crab_slot_idx
			add	si,10h
			jmp	short scan_slot_loop

scan_done:					; was loc_4
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:gvar_death_flag,0FFh
		jnz	dispatch_phase		; death flag set -> skip adjust
		mov	al,ds:crab_state_bits
		or	al,al			; Zero ?
		jz	dispatch_phase
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		pop	ax
		or	al,al			; Zero ?
		jns	hp_target_ready		; was loc_5
		add	bx,bx

hp_target_ready:				; was loc_5
		call	prep_phase
		mov	byte ptr ds:gvar_spawn_fx_flag,22h	; '"'
		mov	ax,crab_const_2600
		add	ax,0Ch
		mov	bx,ds:fight_state_max
		cmp	ax,bx
		jb	hp_target_clamped	; was loc_6
		mov	ax,bx

hp_target_clamped:				; was loc_6
		xchg	bx,ax
		mov	ax,ds:fight_hp
		add	ax,5
		cmp	ax,bx
		jae	hp_inc_two		; was loc_7
		call	hp_dec
		call	hp_dec
		jmp	short dispatch_phase

hp_inc_two:					; was loc_7
		call	hp_inc
		call	hp_inc

; -------------------------------------------------------------------------
;  Per-frame phase dispatch chain (loc_8..loc_12).
;  Tests several flags in priority order:
;    crab_anim_idx  set -> anim_step     (loc_27)
;    crab_alt_phase set -> idle_dispatch (loc_43)
;    gvar_death_flag   -> death_anim     (loc_44)
;    crab_flag_g       -> spawn_subloop  (loc_24)
;    else -> call cs:crab_const_2692 (RNG/timer) and walk / swap-dir.
; -------------------------------------------------------------------------

dispatch_phase:					; was loc_8
		test	byte ptr ds:crab_anim_idx,0FFh
		jz	disp_try_alt		; was loc_9
		jmp	anim_step_entry		; was loc_27

disp_try_alt:					; was loc_9
		test	byte ptr ds:crab_alt_phase,0FFh
		jz	disp_try_death		; was loc_10
		jmp	idle_dispatch		; was loc_43

disp_try_death:					; was loc_10
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	disp_try_spawn		; was loc_11
		jmp	death_anim		; was loc_44

disp_try_spawn:					; was loc_11
		test	byte ptr ds:crab_flag_g,0FFh
		jz	disp_walk		; was loc_12
		jmp	spawn_subloop		; was loc_24

disp_walk:					; was loc_12
		call	word ptr cs:crab_const_2692	; call RNG/timer fn
		and	al,7
		jnz	walk_active		; was loc_13
		jmp	walk_reset		; was loc_23

walk_active:					; was loc_13
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	walk_dir1		; was loc_17
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	walk_dir0_step		; was loc_14
		jmp	emit_sprite_rows	; was loc_49

walk_dir0_step:					; was loc_14
		call	hp_dec
		jnc	walk_dir0_advance	; was loc_15
		mov	byte ptr ds:crab_dir_flag,0FFh

walk_dir0_advance:				; was loc_15
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jae	walk_dir0_wrap		; was loc_16
		jmp	emit_sprite_rows

walk_dir0_wrap:					; was loc_16
		mov	byte ptr ds:crab_frame_idx,0
		jmp	emit_sprite_rows

walk_dir1:					; was loc_17
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	walk_dir1_step		; was loc_18
		jmp	emit_sprite_rows

walk_dir1_step:					; was loc_18
		call	hp_inc
		jnc	walk_dir1_advance	; was loc_19
		mov	byte ptr ds:crab_dir_flag,0

walk_dir1_advance:				; was loc_19
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		je	walk_dir1_wrap		; was loc_20
		jmp	emit_sprite_rows

walk_dir1_wrap:					; was loc_20
		mov	byte ptr ds:crab_frame_idx,5
		jmp	emit_sprite_rows

crab_main	endp

; -------------------------------------------------------------------------
;  hp_dec -- decrement fight_hp by 1, floor at 0x10.  Sets CF if clamped.
;  (was sub_1)
; -------------------------------------------------------------------------

hp_dec		proc	near
		cmp	byte ptr ds:fight_hp,10h
		stc				; Set carry flag
		jnz	hp_dec_do		; was loc_21
		retn

hp_dec_do:					; was loc_21
		dec	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn

hp_dec		endp

; -------------------------------------------------------------------------
;  hp_inc -- increment fight_hp by 1, ceiling 0x31.  Sets CF if clamped.
;  (was sub_2)
; -------------------------------------------------------------------------

hp_inc		proc	near
		cmp	byte ptr ds:fight_hp,31h	; '1'
		stc				; Set carry flag
		jnz	hp_inc_do		; was loc_22
		retn

hp_inc_do:					; was loc_22
		inc	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn

hp_inc		endp

; -------------------------------------------------------------------------
;  walk_reset (loc_23) -- clear flag_h, set flag_g to drive spawn_subloop.
; -------------------------------------------------------------------------

walk_reset:					; was loc_23
		mov	byte ptr ds:crab_flag_h,0
		mov	byte ptr ds:crab_flag_g,0FFh

spawn_subloop:					; was loc_24
		inc	byte ptr ds:crab_flag_h
		cmp	byte ptr ds:crab_flag_h,8
;*		je	spawn_phase_reset	; target = loc_25 (orphan block below)
		db	 74h, 18h		; je +0x18 -> spawn_phase_reset @ 0x48D
						;  (Sourcer dropped the label; byte-form jump)
		mov	bl,ds:crab_flag_h
		xor	bh,bh			; Zero register
		mov	al,ds:crab_spawn_limit[bx]
		mov	ds:crab_frame_idx,al
		jmp	emit_sprite_rows

; -------------------------------------------------------------------------
;  Small sprite-count / slot-stride lookup table (8 bytes, file 0x485..0x48C).
;  Sits between spawn_subloop's `jmp emit_sprite_rows` and the
;  spawn_phase_reset entry.  Indexed by something in 200FIGHT (exact
;  consumer unknown from static analysis; bytes 07,07,08,08,08,08,08,06
;  are crab-row widths for 8 spawn formations).
; -------------------------------------------------------------------------

crab_row_widths:				; was ';* No entry point' #1
		db	 07h, 07h, 08h, 08h	; 4 bytes
		db	 08h, 08h, 08h, 06h	; 4 bytes

; -------------------------------------------------------------------------
;  spawn_phase_reset -- target of `je` in spawn_subloop when flag_h
;  reaches 8.  Re-reads crab_const_2600, clamps against fight_state_max,
;  derives dir_flag from the signed diff, resets flag_g / anim_frame,
;  and arms crab_anim_idx = 0xFF (triggers anim_step_entry next frame).
; -------------------------------------------------------------------------

spawn_phase_reset:				; was loc_25 (orphan from je fixup)
		mov	ax,crab_const_2600
		add	ax,0Ch
		mov	bx,ds:fight_state_max
		mov	cx,ax
		sub	cx,bx
		xchg	bx,ax
		jc	reset_dir_ready		; was loc_26
		xchg	bx,cx

reset_dir_ready:				; was loc_26
		mov	ax,ds:fight_hp
		add	ax,5
		sub	ax,bx
		sbb	dl,dl
		mov	ds:crab_dir_flag,dl
		mov	byte ptr ds:crab_flag_g,0
		mov	byte ptr ds:crab_anim_frame,0
		mov	byte ptr ds:crab_anim_idx,0FFh

anim_step_entry:				; was loc_27
		mov	byte ptr ds:crab_frame_idx,9
		mov	bl,ds:crab_anim_frame
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_c[bx]
		cmp	al,0FFh
		jne	anim_step_do		; was loc_28
;*		jmp	anim_step_end		; target = loc_42 (dead-code / data region)
		db	0E9h,0F1h, 00h		; jmp +0xF1 -> 0x5C4 (inside orphan block
						;  between emit_sprite_rows tail and idle_dispatch)

anim_step_do:					; was loc_28
		mov	ah,al
		and	al,0Fh
		cmp	al,8
		je	anim_step_no_phase	; was loc_29
		shr	al,1			; Shift w/zeros fill
		sbb	al,0
		add	al,ds:crab_phase_base
		and	al,3Fh			; '?'
		mov	ds:crab_phase_base,al

anim_step_no_phase:				; was loc_29
		mov	al,ah
		and	al,0F0h
		jz	anim_step_emit		; was loc_31
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	anim_step_inc		; was loc_30
		call	hp_dec
		jmp	short anim_step_emit

anim_step_inc:					; was loc_30
		call	hp_inc

anim_step_emit:					; was loc_31
		call	emit_sprite_rows_proc
		inc	byte ptr ds:crab_anim_frame
		retn

emit_from_grid:					; was loc_32
		test	byte ptr ds:crab_row_pos,0FFh
		jnz	emit_cell		; was loc_37
		test	byte ptr ds:crab_anim_idx,0FFh
		jnz	emit_find_slot		; was loc_33
		retn

emit_find_slot:					; was loc_33
		mov	di,ds:fight_slot_list

emit_find_slot_loop:				; was loc_34
			cmp	byte ptr [di+4],14h
			je	emit_slot_found		; was loc_35
			add	di,10h
			jmp	short emit_find_slot_loop

emit_slot_found:				; was loc_35
		mov	al,ds:crab_anim_frame
		mov	[di+6],al
		cmp	byte ptr ds:crab_anim_frame,4
		je	emit_grid_init		; was loc_36
		retn

emit_grid_init:					; was loc_36
		mov	byte ptr ds:crab_col_pos,0
		mov	byte ptr ds:crab_row_pos,0FFh
		mov	ax,ds:fight_hp
		add	ax,4
		mov	ds:crab_anim_base,ax
		mov	al,ds:crab_phase_base
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:crab_timer_a,al

emit_cell:					; was loc_37
		mov	bl,ds:crab_col_pos
		xor	bh,bh			; Zero register
		inc	byte ptr ds:crab_col_pos
		mov	al,ds:crab_anim_tbl_a[bx]
		cmp	al,0FFh
		jne	emit_cell_nonend	; was loc_38
		mov	byte ptr ds:crab_row_pos,0
		retn

emit_cell_nonend:				; was loc_38
		or	al,al			; Zero ?
		jns	emit_cell_step		; was loc_40
		inc	byte ptr ds:crab_timer_a
		and	byte ptr ds:crab_timer_a,3Fh	; '?'

emit_cell_step:					; was loc_40
		push	ax
		mov	ax,ds:crab_anim_base
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		pop	cx
		jnc	emit_cell_write		; was loc_41
		retn

emit_cell_write:				; was loc_41
		mov	[si],ax
		mov	dl,ds:crab_timer_a
		mov	[si+2],dl
		mov	[si+3],bl
		mov	byte ptr [si+4],35h	; '5'
		and	cl,7Fh
		mov	[si+6],cl
		mov	byte ptr [si+5],0
		mov	word ptr [si+10h],0FFFFh
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:crab_slot_idx
		mov	al,bl
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:sprite_idx_table[bx],al
		retn

; -------------------------------------------------------------------------
;  Orphan bytes between emit_cell_write's retn (0x5B9) and idle_dispatch
;  (0x5D7).  These 0x1E bytes decode as nominal x86 but are NOT reachable
;  via any direct call/jump visible in this module - Sourcer attempted to
;  disassemble them and hit a `loopnz` byte-form (Fixup 4).
;
;  The jmp from anim_step_do (E9 F1 00 at 0x4D0) targets 0x5C4 which lands
;  inside these bytes; treated as a soft-end (falls out of anim_step_entry).
;  Bytes also likely double as small constants consumed by 200FIGHT
;  through DS-resident dispatch tables (cannot resolve statically).
; -------------------------------------------------------------------------

crab_orphan_data_a:				; was ';* No entry point' #2
		db	 80h, 80h, 80h, 80h, 80h	; 5 bytes
		db	 81h, 82h, 03h, 04h		; 4 bytes
		db	 0FFh				; 1 byte (soft jmp-anim_step_end target at 0x5C4)
		db	 0F6h				; 1 byte
		db	 16h				; push ss (in aligned decode)
;*		loopnz	$-87			; target = mid-instruction (orphan)
		db	0E0h,0A7h		; loopne -89  (alt-encoding; stays as Fixup)
		mov	byte ptr ds:crab_anim_idx,0
		mov	byte ptr ds:crab_idx_e,0
		mov	byte ptr ds:crab_alt_phase,0FFh	; arm alt-phase -> idle_dispatch

idle_dispatch:					; was loc_43
		mov	bl,ds:crab_idx_e
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_b[bx]
		mov	ds:crab_frame_idx,al
		inc	byte ptr ds:crab_idx_e
		cmp	byte ptr ds:crab_idx_e,4
		je	$+5			; skip the next `jmp` -> falls into idle_done_clear
		jmp	emit_sprite_rows	; was loc_49

; idle_done_clear: reached by the `je $+5` above when crab_idx_e == 4.
; Clears alt-phase and jumps into the sprite-emit stage.

idle_done_clear:				; was ';* No entry point' #3 (reached via je $+5)
		mov	byte ptr ds:crab_alt_phase,0
		jmp	short emit_sprite_rows

; -------------------------------------------------------------------------
;  Orphan data block before death_anim.  14 bytes, mixture of small
;  values; Sourcer decodes as `pop es / or [bx+si],cl / add cl,dh (alt) /
;  db F1..F1 F8..F8 F2..F2 FF`.  Likely a timing/flicker lookup table
;  consumed indirectly by death_anim's state machine (exact consumer
;  not visible to static analysis).
; -------------------------------------------------------------------------

crab_death_aux_tbl:				; was ';* No entry point' #4
		db	 07h				; 1 byte
		db	 08h, 08h			; 2 bytes
;*		add	cl,dh			; alt encoding (00 F1) -- TASM emits 02 CE
		db	 00h,0F1h		; keep as db to preserve exact byte form
		db	0F1h,0F1h,0F1h,0F1h,0F8h,0F8h
		db	0F8h,0F2h,0F2h,0F2h,0F2h,0F2h
		db	0FFh

; -------------------------------------------------------------------------
;  death_anim (loc_44) -- runs when gvar_death_flag is set.  crab_timer_b
;  counts up to 0x28; at 0x1E it sets gvar_spawn_fx_flag=0x23, at 0x14 it
;  switches to frame 8, and at 0x28 it sets gvar_completion.
; -------------------------------------------------------------------------

death_anim:					; was loc_44
		mov	al,ds:crab_timer_b
		cmp	al,28h			; '('
		jae	death_complete		; was loc_48
		cmp	al,1Eh
		jae	death_walk		; was loc_45
		and	al,1
		jnz	death_walk
		mov	byte ptr ds:gvar_spawn_fx_flag,23h	; '#'

death_walk:					; was loc_45
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		cmp	byte ptr ds:crab_timer_b,14h
		jae	death_frame8		; was loc_47
		inc	byte ptr ds:crab_timer_b
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	death_step_down		; was loc_46
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jb	emit_sprite_rows
		mov	byte ptr ds:crab_frame_idx,5
		mov	byte ptr ds:crab_dir_flag,0FFh
		jmp	short emit_sprite_rows

death_step_down:				; was loc_46
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		jb	emit_sprite_rows
		mov	byte ptr ds:crab_frame_idx,0
		mov	byte ptr ds:crab_dir_flag,0
		jmp	short emit_sprite_rows

death_frame8:					; was loc_47
		inc	byte ptr ds:crab_timer_b
		mov	byte ptr ds:crab_frame_idx,8
		jmp	short emit_sprite_rows

death_complete:					; was loc_48
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; -------------------------------------------------------------------------
;  emit_sprite_rows (sub_3) -- the main sprite-emission routine.  Uses
;  crab_frame_idx to index into crab_pos_tbl, then walks a 6*10 grid
;  calling fight_cb_anim_step for each cell; successful cells are
;  written into the fight_slot_list and registered in sprite_idx_table.
;  Entry label emit_sprite_rows == loc_49 is the common jump target for
;  nearly every phase path above.  After emit_sprite_rows finishes
;  iterating, it tail-jumps to emit_from_grid (loc_32) to handle grid
;  overflow / respawn.
; -------------------------------------------------------------------------

emit_sprite_rows_proc	proc	near

emit_sprite_rows:				; was loc_49
		mov	bl,ds:crab_frame_idx
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	di,ds:crab_pos_tbl[bx]
		mov	al,ds:crab_phase_base
		mov	ds:crab_flag_d,al
		mov	si,ds:fight_slot_list
		xor	al,al			; Zero register
		mov	ds:crab_slot_idx,al

emit_row_outer:					; was loc_50
			push	di
			push	ax
			mov	bl,0Ah
			mul	bl			; ax = reg * al
			add	di,ax
			mov	ax,ds:fight_hp
			mov	cx,0Ah

emit_row_loop:					; was locloop_51
				push	cx
				mov	[si],ax
				push	di
				push	ax
				call	word ptr cs:fight_cb_anim_step
				jc	emit_row_next		; was loc_53
				mov	al,[di]
				cmp	al,0FFh
				je	emit_row_next
				mov	[si+4],al
				mov	al,ds:crab_flag_d
				mov	[si+2],al
				mov	[si+3],bl
				mov	byte ptr [si+5],0
				test	byte ptr ds:crab_state_bits,0FFh
				jz	emit_row_no_bit		; was loc_52
				or	byte ptr [si+5],20h	; ' '

emit_row_no_bit:				; was loc_52
				mov	al,ds:crab_frame_idx
				mov	[si+6],al
				mov	ax,[si+2]
				call	word ptr cs:fight_cb_record_ofs
				mov	al,ds:crab_slot_idx
				mov	bl,al
				or	al,80h
				xchg	[di],al
				xor	bh,bh			; Zero register
				mov	ds:sprite_idx_table[bx],al
				inc	byte ptr ds:crab_slot_idx
				add	si,10h

emit_row_next:					; was loc_53
				pop	ax
				inc	ax
				pop	di
				inc	di
				pop	cx
				loop	emit_row_loop

			inc	byte ptr ds:crab_flag_d
			and	byte ptr ds:crab_flag_d,3Fh	; '?'
			pop	ax
			pop	di
			inc	al
			cmp	al,6
			jne	emit_row_outer
		mov	word ptr [si],0FFFFh
		jmp	emit_from_grid

emit_sprite_rows_proc	endp

; -------------------------------------------------------------------------
;  Post-emit scratch tables (file 0x70E..0x79A, 140 bytes).
;  Two subsections:
;    [0x70E..0x71F]: 9 copies of word 0xA71E (= crab_anim_tbl_b base + 1,
;                    indirect self-pointer), then word 0xA75A.
;    [0x720..0x791]: four 0xFF-padded sparse sub-tables (sizes 14, 11,
;                    15, and 12 0xFF bytes plus interspersed small indices
;                    02..14, 03..14, 06, 90, etc.).  These are lookup
;                    tables indexed from 301EAI1/302EAI2 via DS-resident
;                    dispatch slots; static analysis cannot trace the
;                    exact consumer but the 0xFF padding is the standard
;                    crab-lookup "no entry" sentinel.
; -------------------------------------------------------------------------

crab_tail_ptrs:					; offset 0x70E -- 9 x word 0xA71E + word 0xA75A
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h
		db	 5Ah,0A7h,0FFh,0FFh,0FFh, 00h

crab_lookup_a:					; offset 0x726 -- sparse index table, 0xFF sentinels
		db	0FFh, 01h
		db	14 dup (0FFh)
		db	 02h,0FFh, 03h,0FFh, 04h,0FFh
		db	 05h,0FFh, 06h
		db	11 dup (0FFh)
		db	 07h,0FFh, 10h,0FFh, 11h,0FFh
		db	 12h,0FFh
		db	8
		db	15 dup (0FFh)

crab_lookup_b:					; offset 0x762 -- second sparse index table
		db	 00h,0FFh,0FFh,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 03h,0FFh,0FFh,0FFh
		db	 05h,0FFh,0FFh,0FFh, 02h,0FFh
		db	0FFh,0FFh, 14h,0FFh,0FFh,0FFh
		db	 06h,0FFh,0FFh,0FFh, 90h,0FFh
		db	0FFh,0FFh, 12h,0FFh,0FFh,0FFh
		db	0FFh, 07h,0FFh,0FFh,0FFh,0FFh
		db	0FFh
		db	8
		db	12 dup (0FFh)

; -------------------------------------------------------------------------
;  prep_phase (sub_4) -- called from scan_done when the state bits need
;  refreshing.  Clamps crab_phase_limit (at 0xA7C6), invokes fight_cb_prep
;  to validate, and sets gvar_death_flag on first non-ok result.
; -------------------------------------------------------------------------

prep_phase	proc	near
		mov	ax,ds:crab_phase_limit
		sub	ax,bx
		jnc	prep_store		; was loc_54
		xor	ax,ax			; Zero register

prep_store:					; was loc_54
		mov	ds:crab_phase_limit,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	prep_check_death	; was loc_55
		retn

prep_check_death:				; was loc_55
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	prep_arm_death		; was loc_56
		retn

prep_arm_death:					; was loc_56
		mov	byte ptr ds:crab_timer_b,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn

prep_phase	endp

; -------------------------------------------------------------------------
;  Tail data:
;    [0x7C7..0x7D6]: 16 bytes of small integers (2B 00 0C 96 00 78 00 0C
;                    00 D0 A7 96 00 10 BB 00) -- likely crab spawn timing
;                    / position constants indexed by 200FIGHT at boot.
;                    The pair 0xA7D0 = addr of crab_anim_base-0x1A, and
;                    the surrounding small values (96h, 78h, 10h, BBh)
;                    match the sprite-row-width / animation-tick literals
;                    seen in sibling EAI modules.
;    [0x7D7..0x7DF]: 8-char name tag 'Cangrejo' with length-prefix byte 8.
;    [0x7E0..0x7F1]: 18 trailing zeros (padding to final file size 2034).
; -------------------------------------------------------------------------

crab_tail_const:				; 0x7C7 -- 16 timing/position constants
		db	 2Bh, 00h, 0Ch, 96h, 00h, 78h
		db	 00h, 0Ch, 00h,0D0h,0A7h, 96h
		db	 00h, 10h,0BBh, 00h

crab_name_tag:					; 0x7D7 -- 'Cangrejo' pascal string
		db	8, 'Cangrejo'
		db	18 dup (0)		; pad to end-of-file

seg_a		ends

		end	start
