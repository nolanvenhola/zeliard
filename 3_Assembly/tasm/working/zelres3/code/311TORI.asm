
PAGE  59,132

;==========================================================================
;
;  311TORI.BIN - Tori / Bird Enemy Code Module (zelres3 chunk 12, 'Pollo')
;
;  Tori (bird) enemy sprite/logic module loaded by 200FIGHT.asm alongside
;  303EAI3 (Tori AI handler).  The Japanese name "tori" means bird; the
;  Spanish marker 'Pollo' ('chicken/bird') appears as a 5-char Pascal
;  string in the module's trailing data.
;
;  File layout (loaded at game_seg:0xA000 by 200FIGHT):
;    0x000..0x003 : file-size header word (= 0x07E4 = file_size - 4) + pad
;    0x004..0x007 : init src/dst pointers (tori_init_src=0xA1D4,
;                   tori_init_dst=tori_hp 0xA773)
;    0x008..0x013 : 12 zero bytes (initial state buffer)
;    0x014..0x033 : 32-byte template (38h marker + 31x 12h)
;    0x034..0x051 : tori_frame_ptr_tbl_a -- 15 word ptrs (0xA04E..0xA1C5)
;    0x052..0x176 : sprite frame data (5/4-byte tile rows w/ 00 terminators)
;                   plus 2 dual-use bytes (tori_scan_acc_a, tori_scan_acc_b) and embedded
;                   word constant tori_extern_fn_ptr (= 0x0900) used as a fn ptr
;    0x177..0x1D7 : tail of frame data
;    0x1D7..0x1E5 : tori_scan_prolog -- inline mov si,fight_slot_list /
;                   clear tori_slot_idx, tori_cycle_idx
;    0x1E5..0x645 : main scan-and-update code (was tori_main / loc_1..loc_57)
;    0x507..0x57F : sub_1..sub_6 (sprite renderer + hp/altitude helpers)
;    0x648..0x6C7 : orphan code/data block (no static caller; called via
;                   200FIGHT DS-resident dispatch slot - reached as a
;                   per-handler init/setup vector)
;    0x650..0x66E : 16 word ptrs into the orphan block itself
;    0x6CE..0x77F : trailing const table (timing/position constants)
;    0x780..0x787 : 'Pollo' name tag (length-prefixed Pascal string)
;    0x788..0x7E7 : 91 zero bytes of file padding
;
;  Primary entry (via 200FIGHT dispatch): tori_scan_prolog -- iterates
;  the enemy slot list (SI = fight_slot_list), drives bird-specific
;  flight/glide phases, composes multi-plane sprite rows via sub_1
;  (bit-stream row plotter), and spawns swoop/dive projectiles when in
;  range.  Helpers sub_2..sub_5 manage glide/turn/swoop counters; sub_6
;  performs HP-decrement plus death/spawn-FX bookkeeping.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; Fight-engine callback vectors / shared globals (DS, game_seg).

fight_cb_prep		equ	200Ch			; prep/init callback
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_anim_step	equ	6036h			; animation advance callback
fight_cb_hit_check	equ	6038h			; per-slot hit/collision query
fight_cb_aim		equ	603Ah			; aim/target callback
fight_cb_shutdown	equ	603Ch			; shutdown callback

; Shared sprite-pattern / AI tables (DS).

sprite_pat_tbl		equ	0A64Dh			; sprite pattern-pointer table
glide_table_a		equ	0A682h			; glide path A
glide_table_b		equ	0A688h			; glide path B
glide_table_c		equ	0A68Eh			; glide path C
ai_column_tbl		equ	0A6CBh			; AI column-index table

; Tori-specific global state (DS).

tori_spawn_tile		equ	0A766h			; spawn-cell tile
tori_spawn_col		equ	0A767h			; spawn-cell col
tori_hp			equ	0A773h			; Tori HP counter
tori_row_hi		equ	0A775h			; row hi byte
tori_row_lo		equ	0A776h			; row lo byte (word at A776h)
tori_slot_idx		equ	0A789h			; current slot index
tori_dir_state		equ	0A78Ah			; direction state byte
tori_phase_a		equ	0A78Bh			; phase byte A
tori_glide_flag		equ	0A78Ch			; gliding-active flag
tori_sub_phase		equ	0A78Dh			; sub-phase counter
tori_attack_flag	equ	0A78Eh			; attack mode flag
tori_swoop_ctr		equ	0A78Fh			; swoop counter
tori_turn_flag		equ	0A790h			; turning flag
tori_cycle_idx		equ	0A791h			; cycle index byte
tori_frame_idx		equ	0A792h			; frame-index byte
tori_anim_state		equ	0A793h			; animation state byte
tori_pattern_idx	equ	0A794h			; pattern index
tori_anim_timer		equ	0A795h			; anim-timer byte
tori_phase_count	equ	0A796h			; phase counter
tori_phase_limit	equ	0A797h			; phase limit
tori_dive_flag		equ	0A798h			; dive-flag byte
tori_turn_cooldown	equ	0A799h			; turn cooldown
tori_altitude		equ	0A79Ah			; altitude (y) position byte
tori_alt_state		equ	0A79Bh			; alternate state byte
tori_tmp_buf		equ	0A79Ch			; temp render buffer (0x48 bytes)
fight_state_max		equ	0C002h			; max state index (for wrap)
fight_slot_list		equ	0C010h			; base of enemy slot list
sprite_idx_table	equ	0ED20h			; sprite index mapping table
gvar_death_flag		equ	0FF2Eh			; tori death flag global
gvar_dir_toggle		equ	0FF2Fh			; dir-toggle flag global
gvar_completion		equ	0FF30h			; completion/stage flag global
gvar_spawn_fx_flag	equ	0FF75h			; flag byte for spawn VFX

; ----- Slot-record layout helpers (for readability in code below) -----
;   [si+0..1] = sprite tile word   [si+4] = attribute  [si+5] = flags
;   [si+2..3] = record indices     [si+6] = frame      [si+10h] = next

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

tori_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file 0x000..0x033) -- loaded as data by 200FIGHT.
;  Sourcer forced `start:` here but no execution lands here; the bytes
;  are a 4-byte file-length header, a 4-byte init src/dst pair, then
;  two state-buffer blocks consumed by 200FIGHT's per-slot init.
; -------------------------------------------------------------------------

start:

file_header:
		db	 0E4h, 07h		; file length word: 0x07E4 (= file_size - 4)
		db	 00h, 00h		; pad / flag word

tori_init_src_dst:
		db	 0D4h,0A1h		; init src ptr = 0xA1D4 (into frame data)
		db	 73h,0A7h		; init dst ptr = tori_hp (0xA773)

		db	12 dup (0)		; initial per-slot state buffer

tori_state_template:				; 32-byte template
		db	 38h			; marker byte
		db	30 dup (12h)		; 30x 12h (slot defaults)
		db	 12h			; final 12h

; -------------------------------------------------------------------------
;  Frame pointer tables (file 0x034..0x051).
;  Each entry = runtime address in game_seg (= 0xA000 + file offset).
; -------------------------------------------------------------------------

tori_frame_ptr_tbl_a	label	word		; 15 frame-data pointers
		db	 4Eh,0A0h, 67h,0A0h, 94h,0A0h	; -> 0xA04E, 0xA067, 0xA094
		db	0BCh,0A0h,0DAh,0A0h, 02h,0A1h	; -> 0xA0BC, 0xA0DA, 0xA102
		db	 16h,0A1h, 2Ah,0A1h, 3Eh,0A1h	; -> 0xA116, 0xA12A, 0xA13E
		db	 52h,0A1h, 57h,0A1h, 70h,0A1h	; -> 0xA152, 0xA157, 0xA170
		db	 8Eh,0A1h,0ACh,0A1h,0C5h,0A1h	; -> 0xA18E, 0xA1AC, 0xA1C5

; -------------------------------------------------------------------------
;  Sprite frame data (file 0x052..0x176).
;  Tile-index rows (variable length, 0x00 row-terminators) indexed by
;  tori_frame_ptr_tbl_a.  Two single bytes (tori_scan_acc_a, tori_scan_acc_b) are dual-use
;  loop counters referenced from the main scan code.  The word constant
;  tori_extern_fn_ptr (= 0x0900) embedded mid-table is invoked via `call cs:tori_extern_fn_ptr`
;  as a function pointer (the runtime resolves it via game-segment fixup;
;  static analysis cannot trace it).
; -------------------------------------------------------------------------

tori_frame_00:					; -> 0xA052
		db	 00h, 01h, 02h, 03h, 04h, 00h
		db	 9Ch, 02h, 9Dh, 04h, 00h, 29h
		db	 2Ah, 2Bh, 2Ch, 00h, 6Ah, 6Bh
		db	 6Ch, 6Dh, 00h, 6Ah, 6Bh, 8Ah
		db	 6Dh, 00h, 0Eh, 0Fh, 12h, 13h
		db	 00h, 2Dh, 32h, 2Eh, 2Fh, 00h
		db	 2Dh, 49h, 2Eh, 50h, 00h, 2Dh
		db	 00h, 2Eh, 58h, 00h
tori_scan_acc_a		db	 00h			; dual-use: scan-loop accumulator
		db	 62h, 66h
tori_scan_acc_b		db	 67h			; dual-use: scan-loop accumulator
		db	 00h, 7Dh, 7Eh, 00h, 87h, 00h
		db	 7Dh, 7Eh
tori_glyph_tbl		db	 00h			; data table (indexed access)
		db	 19h, 00h, 00h, 00h, 8Fh, 90h
		db	 00h, 96h, 97h, 98h, 99h, 00h
		db	 10h, 11h, 14h, 00h, 00h, 00h
		db	 3Bh, 38h, 39h, 00h, 4Dh, 4Eh
		db	 49h, 4Ah, 00h, 00h, 00h, 59h
		db	 5Ah, 00h, 63h, 64h, 68h, 69h
		db	 00h, 00h, 72h, 6Eh, 6Fh, 00h
		db	 91h, 00h, 94h, 95h, 00h, 99h
		db	 9Ah, 28h, 9Bh, 00h, 00h, 05h
		db	 06h, 07h, 00h, 39h, 3Ah, 36h
		db	 37h, 00h, 4Fh, 00h, 4Bh, 4Ch
		db	 00h, 00h, 5Bh, 00h, 5Fh, 00h
		db	 65h, 00h,0A4h,0A5h, 00h, 7Ah
		db	 00h, 76h, 77h, 00h, 15h, 16h
		db	 17h, 18h, 00h, 35h, 36h, 33h
		db	 34h, 00h, 50h, 51h, 3Ch, 3Dh
		db	 00h, 5Ch, 5Dh, 60h, 61h, 00h
		db	 2Eh,0A6h, 00h, 3Ch, 00h, 7Bh
		db	 7Ch, 78h, 79h, 00h, 92h, 93h
		db	0ACh,0ABh, 00h,0AAh, 28h, 27h
		db	 26h, 00h, 08h, 09h, 19h, 1Ah
		db	 00h, 08h, 09h, 1Ch, 1Dh, 00h
		db	 08h, 09h, 19h, 1Fh, 00h
		db	 08h, 09h, 21h, 22h
tori_extern_fn_ptr		dw	900h			; embedded fn-ptr (used via call cs:tori_extern_fn_ptr)
		db	 0Ah, 1Ah, 1Bh, 00h, 09h, 0Ah
		db	 1Dh, 1Eh, 00h, 09h, 0Ah, 1Fh
		db	 20h, 00h, 09h, 0Ah, 22h, 23h
		db	 00h,0AFh,0B0h,0B1h,0B2h, 00h
		db	 0Bh, 00h, 8Bh,0BAh, 00h, 0Bh
		db	 00h, 8Bh, 8Ch, 00h, 0Bh,0B5h
		db	0B3h,0B4h, 00h, 0Bh,0B1h, 0Ch
		db	 0Dh, 00h, 00h,0ADh,0BBh,0AEh
		db	 00h, 00h, 00h, 8Dh, 8Eh, 00h
		db	0B6h,0B7h, 00h,0B8h, 00h,0B1h
		db	0B2h, 0Dh,0B9h, 00h, 2Fh, 30h
		db	 3Ch, 3Dh, 00h, 52h, 53h, 3Eh
		db	 3Fh, 00h, 5Eh, 3Fh, 42h, 43h
		db	 00h,0A7h,0A8h, 3Dh, 3Eh, 00h
		db	 73h, 74h, 70h, 71h, 00h, 31h
		db	 00h, 3Eh, 3Fh, 00h, 40h, 41h
		db	 00h, 00h, 00h, 9Eh, 9Fh,0A1h
		db	0A2h, 00h,0A9h, 00h, 3Fh, 00h
		db	 00h, 75h, 00h, 00h, 82h, 00h
		db	 75h, 00h, 00h, 00h, 00h, 40h
		db	 41h, 00h, 44h, 00h, 42h, 43h
		db	 54h, 46h, 00h,0A0h, 44h,0A3h
		db	 47h, 00h, 40h, 41h, 00h, 00h
		db	 00h, 85h, 86h, 83h, 84h, 00h
		db	 3Dh, 7Fh, 1Ah, 1Bh, 00h, 42h
		db	 43h, 45h, 46h, 00h, 55h, 00h
		db	 56h, 57h, 00h, 45h, 46h, 48h
		db	 00h, 00h, 3Dh, 7Fh, 88h, 89h
		db	 00h, 3Fh, 00h, 8Bh, 8Ch, 00h
		db	 44h, 45h, 47h, 48h, 00h, 80h
		db	 81h, 00h, 00h, 00h, 00h, 00h
		db	 8Dh, 8Eh

; -------------------------------------------------------------------------
;  Inline scan-prolog (file 0x1D7..0x1E4) -- decoded x86, NOT data.
;  Falls through directly into scan_slot_loop.  Same structure as
;  309CRAB / 310TAKO scan prologs.
; -------------------------------------------------------------------------

tori_scan_prolog:
		db	 8Bh, 36h, 10h,0C0h		; mov si, fight_slot_list
		db	0C6h, 06h, 89h,0A7h, 00h	; mov byte ptr tori_slot_idx, 0
		db	0C6h, 06h, 91h,0A7h, 00h	; mov byte ptr tori_cycle_idx, 0

scan_slot_loop:					; was loc_1
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		; cmp word ptr [si], 0FFFFh
							;  (alt encoding: sign-extended imm8 form;
							;   TASM emits 4-byte form, so keep as db)
			jz	scan_done		; was loc_4 -- end of slot list
			mov	ax,[si]
			call	word ptr cs:fight_cb_anim_step
			jc	scan_next_slot		; was loc_3 -- callback consumed slot
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:tori_slot_idx
			xor	bh,bh			; Zero register
			mov	al,ds:sprite_idx_table[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'  bit6 = active
			jz	scan_next_slot
			test	byte ptr ds:tori_cycle_idx,80h
			jnz	scan_next_slot
			mov	al,[si+5]
			and	al,1Fh
			test	byte ptr [si+4],0FFh
			jnz	apply_cycle_bits	; was loc_2
			or	al,80h

apply_cycle_bits:				; was loc_2
			mov	ds:tori_cycle_idx,al

scan_next_slot:					; was loc_3
			inc	byte ptr ds:tori_slot_idx
			add	si,10h
			jmp	short scan_slot_loop

scan_done:					; was loc_4
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFh
		mov	al,ds:tori_cycle_idx
		or	al,al			; Zero ?
		jz	dispatch_phase		; was loc_8
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		pop	ax
		add	bx,bx
		or	al,al			; Zero ?
		jns	hit_pos_branch		; was loc_5
		add	bx,bx
		add	bx,bx

hit_pos_branch:					; was loc_5
		mov	byte ptr ds:gvar_spawn_fx_flag,29h	; ')'
		call	sub_6
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	hit_check_attack	; was loc_6
		mov	byte ptr ds:tori_glide_flag,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh

hit_check_attack:				; was loc_6
		jnz	hit_skip_alt_inc	; was loc_7
		call	sub_5

hit_skip_alt_inc:				; was loc_7
		mov	byte ptr ds:tori_anim_timer,4

dispatch_phase:					; was loc_8
		mov	byte ptr ds:tori_phase_a,0
		test	byte ptr ds:tori_anim_timer,0FFh
		jz	check_glide_branch	; was loc_9
		dec	byte ptr ds:tori_anim_timer
		mov	byte ptr ds:tori_phase_a,1

check_glide_branch:				; was loc_9
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	check_attack_branch	; was loc_14
		cmp	byte ptr ds:tori_row_hi,0Eh
		je	glide_skip_dec_row	; was loc_10
		dec	byte ptr ds:tori_row_hi

glide_skip_dec_row:				; was loc_10
		inc	byte ptr ds:tori_sub_phase
		and	byte ptr ds:tori_sub_phase,3
		cmp	byte ptr ds:tori_sub_phase,2
		jne	glide_skip_fx2b		; was loc_11
		mov	byte ptr ds:gvar_spawn_fx_flag,2Bh	; '+'

glide_skip_fx2b:				; was loc_11
		call	sub_4
		jc	glide_force_attack	; was loc_12
		test	byte ptr ds:tori_alt_state,0FFh
		jz	glide_force_attack
		dec	byte ptr ds:tori_alt_state
		test	byte ptr ds:tori_cycle_idx,0FFh
		jz	emit_setup_jmp		; was loc_13

glide_force_attack:				; was loc_12
		mov	byte ptr ds:tori_glide_flag,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'

emit_setup_jmp:					; was loc_13
		jmp	emit_setup		; was loc_30

check_attack_branch:				; was loc_14
		test	byte ptr ds:tori_attack_flag,0FFh
		jz	check_phase_limit	; was loc_17
		cmp	byte ptr ds:tori_sub_phase,1
		jne	attack_advance		; was loc_15
		mov	byte ptr ds:tori_attack_flag,0
		jmp	emit_setup

attack_advance:					; was loc_15
		mov	byte ptr ds:tori_sub_phase,1
		cmp	byte ptr ds:tori_row_hi,12h
		je	attack_skip		; was loc_16
		inc	byte ptr ds:tori_row_hi
		mov	byte ptr ds:tori_sub_phase,0
		call	sub_3

attack_skip:					; was loc_16
		jmp	emit_setup

check_phase_limit:				; was loc_17
		test	byte ptr ds:tori_phase_limit,0FFh
		jz	check_altitude		; was loc_20
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		call	sub_2
		jnc	dive_step_a		; was loc_18
		jmp	emit_setup

dive_step_a:					; was loc_18
		cmp	byte ptr ds:tori_dive_flag,4
		jae	dive_to_glide		; was loc_19
		inc	byte ptr ds:tori_dive_flag
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'
		mov	byte ptr ds:tori_anim_timer,4
		jmp	emit_setup

dive_to_glide:					; was loc_19
		mov	byte ptr ds:tori_phase_limit,0
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_glide_flag,0FFh
		mov	byte ptr ds:tori_alt_state,0Fh
		jmp	emit_setup

check_altitude:					; was loc_20
		test	byte ptr ds:tori_altitude,0FFh
		jz	check_death		; was loc_23
		call	sub_2
		jnc	dive_step_b		; was loc_21
		jmp	emit_setup

dive_step_b:					; was loc_21
		cmp	byte ptr ds:tori_dive_flag,2
		jae	land_aim		; was loc_22
		inc	byte ptr ds:tori_dive_flag
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ah	; '*'
		mov	byte ptr ds:tori_anim_timer,2
		jmp	emit_setup

land_aim:					; was loc_22
		mov	ax,ds:tori_hp
		add	ax,4
		call	word ptr cs:fight_cb_anim_step
		mov	ds:tori_spawn_tile,bl
		mov	al,ds:tori_row_hi
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:tori_spawn_col,al
		mov	bx,tori_spawn_tile
		call	word ptr cs:fight_cb_aim
		mov	byte ptr ds:tori_altitude,0
		jmp	emit_setup

check_death:					; was loc_23
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	walk_dispatch		; was loc_24
		jmp	death_phase		; was loc_55

walk_dispatch:					; was loc_24
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		test	byte ptr ds:tori_cycle_idx,0FFh
		jz	check_phase_arm		; was loc_25
		cmp	byte ptr ds:tori_hp,14h
		jb	check_phase_arm
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0

check_phase_arm:				; was loc_25
		test	byte ptr ds:tori_phase_limit,0FFh
		jnz	walk_count_step		; was loc_26
		call	word ptr cs:tori_extern_fn_ptr
		and	al,0Fh
		jnz	walk_count_step
		mov	byte ptr ds:tori_altitude,0FFh
		mov	byte ptr ds:tori_dive_flag,0

walk_count_step:				; was loc_26
		inc	byte ptr ds:tori_phase_count
		test	byte ptr ds:tori_phase_count,1
		jnz	emit_setup
		mov	al,tori_scan_acc_a
		add	al,tori_scan_acc_b
		xor	ah,ah			; Zero register
		mov	cx,ax
		sub	cx,ds:fight_state_max
		jc	walk_skip_swap		; was loc_27
		xchg	cx,ax

walk_skip_swap:					; was loc_27
		mov	bl,ds:tori_hp
		sub	bl,al
		cmp	bl,0Ch
		je	walk_random_arm		; was loc_29
		jnc	walk_dir_inc		; was loc_28
		dec	byte ptr ds:tori_dir_state
		and	byte ptr ds:tori_dir_state,3
		call	sub_5
		jnc	emit_setup
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0
		jmp	short emit_setup

walk_dir_inc:					; was loc_28
		inc	byte ptr ds:tori_dir_state
		and	byte ptr ds:tori_dir_state,3
		call	sub_3

walk_random_arm:				; was loc_29
		call	word ptr cs:tori_extern_fn_ptr
		and	al,1Fh
		jnz	emit_setup
		mov	byte ptr ds:tori_phase_limit,0FFh
		mov	byte ptr ds:tori_dive_flag,0

; -------------------------------------------------------------------------
;  emit_setup (was loc_30) -- common merge for all phase branches.
;  Stores anim_state, clears tmp render buffer (0x48 bytes), then runs
;  one of three sprite-row composers (turn/glide/normal) before falling
;  into the per-slot copy loop that scans the staging buffer into the
;  fight slot list.
; -------------------------------------------------------------------------

emit_setup:					; was loc_30
		mov	al,ds:tori_row_hi
		mov	ds:tori_anim_state,al
		push	cs
		pop	es
		mov	di,tori_tmp_buf
		mov	al,0FFh
		mov	cx,48h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		test	byte ptr ds:tori_turn_cooldown,0FFh
		jnz	turn_compose		; was loc_31
		test	byte ptr ds:tori_attack_flag,0FFh
		jz	check_glide_compose	; was loc_32

turn_compose:					; was loc_31
		mov	al,ds:tori_sub_phase
		and	al,1
		add	al,11h
		call	sub_1
		jmp	short copy_to_slots	; was loc_34

check_glide_compose:				; was loc_32
		test	byte ptr ds:tori_glide_flag,0FFh
		jz	normal_compose		; was loc_33
		mov	al,ds:tori_sub_phase
		and	al,3
		add	al,0Dh
		call	sub_1
		mov	al,ds:tori_sub_phase
		shr	al,1			; Shift w/zeros fill
		adc	byte ptr ds:tori_anim_state,0
		jmp	short copy_to_slots

normal_compose:					; was loc_33
		mov	al,ds:tori_phase_a
		call	sub_1
		mov	al,ds:tori_dir_state
		add	al,6
		call	sub_1
		mov	al,ds:tori_swoop_ctr
		add	al,0Ah
		call	sub_1
		mov	al,ds:tori_turn_flag
		add	al,2
		call	sub_1

copy_to_slots:					; was loc_34
		mov	byte ptr ds:tori_slot_idx,0
		mov	ax,ds:tori_hp
		mov	di,ds:fight_slot_list
		mov	si,tori_tmp_buf
		mov	cx,9

emit_outer_loop:				; was locloop_35
			push	cx
			push	si
			push	ax
			call	word ptr cs:fight_cb_anim_step
			pop	ax
			jc	emit_outer_advance	; was loc_39
			mov	ds:tori_frame_idx,bl
			xor	cx,cx			; Zero register

emit_inner_loop:				; was loc_36
				push	cx
				push	ax
				cmp	byte ptr [si],0FFh
				je	emit_inner_skip		; was loc_38
				mov	[di],ax
				mov	al,ds:tori_anim_state
				add	al,cl
				and	al,3Fh			; '?'
				mov	[di+2],al
				mov	al,ds:tori_frame_idx
				mov	[di+3],al
				mov	al,[si]
				mov	ah,al
				shr	al,1			; Shift w/zeros fill
				shr	al,1			; Shift w/zeros fill
				shr	al,1			; Shift w/zeros fill
				shr	al,1			; Shift w/zeros fill
				and	al,0Fh
				mov	[di+4],al
				mov	[di+6],ah
				mov	byte ptr [di+5],0
				test	byte ptr ds:tori_cycle_idx,0FFh
				jz	emit_no_cycle_bit	; was loc_37
				or	byte ptr [di+5],20h	; ' '

emit_no_cycle_bit:				; was loc_37
				mov	ax,[di+2]
				push	di
				call	word ptr cs:fight_cb_record_ofs
				mov	bl,ds:tori_slot_idx
				xor	bh,bh			; Zero register
				mov	al,bl
				or	al,80h
				xchg	[di],al
				mov	ds:sprite_idx_table[bx],al
				pop	di
				add	di,10h
				inc	byte ptr ds:tori_slot_idx

emit_inner_skip:				; was loc_38
				inc	si
				pop	ax
				pop	cx
				inc	cx
				cmp	cx,8
				jne	emit_inner_loop

emit_outer_advance:				; was loc_39
			inc	ax
			pop	si
			add	si,8
			pop	cx
			loop	emit_outer_loop		; Loop if cx > 0

		mov	word ptr [di],0FFFFh
		retn

tori_main	endp

; -------------------------------------------------------------------------
;  sub_1 -- bit-stream sprite row plotter.
;  AL = pattern index; expands a 2-pattern source via mask bits in
;  ai_column_tbl, writing tile bytes into tori_tmp_buf.  9 outer rows x
;  8 inner mask bits.
; -------------------------------------------------------------------------

sub_1		proc	near
		add	al,al
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	si,ds:sprite_pat_tbl[bx]
		mov	bp,ds:ai_column_tbl[bx]
		mov	di,tori_tmp_buf
		mov	cx,9

row_outer_loop:					; was locloop_40
			push	cx
			mov	cx,8

row_inner_loop:					; was locloop_41
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	row_inner_skip		; was loc_42
				lodsb				; String [si] to al
				mov	[di],al

row_inner_skip:					; was loc_42
				inc	di
				loop	row_inner_loop

			inc	bp
			pop	cx
			loop	row_outer_loop

		retn

sub_1		endp

; -------------------------------------------------------------------------
;  sub_2 -- swoop counter step (mod 3).  Sets CF when wrapping back to
;  0 (i.e. swoop tick complete).
; -------------------------------------------------------------------------

sub_2		proc	near
		inc	byte ptr ds:tori_swoop_ctr
		cmp	byte ptr ds:tori_swoop_ctr,3
		stc				; Set carry flag
		jz	swoop_wrap		; was loc_43
		retn

swoop_wrap:					; was loc_43
		mov	byte ptr ds:tori_swoop_ctr,0
		clc				; Clear carry flag
		retn

sub_2		endp

; -------------------------------------------------------------------------
;  sub_3 -- conditional HP decrement (only if hp >= 0Dh; clears CF).
; -------------------------------------------------------------------------

sub_3		proc	near
		cmp	byte ptr ds:tori_hp,0Dh
		jae	hp_dec_a		; was loc_44
		retn

hp_dec_a:					; was loc_44
		dec	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn

sub_3		endp

; -------------------------------------------------------------------------
;  sub_4 -- conditional HP decrement (only if hp >= 11h; clears CF).
; -------------------------------------------------------------------------

sub_4		proc	near
		cmp	byte ptr ds:tori_hp,11h
		jae	hp_dec_b		; was loc_45
		retn

hp_dec_b:					; was loc_45
		dec	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn

sub_4		endp

; -------------------------------------------------------------------------
;  sub_5 -- conditional HP increment (only if hp < 30h; clears CF).
;  Uses cmc to invert CF after the cmp so the early-exit is sense-flipped.
; -------------------------------------------------------------------------

sub_5		proc	near
		cmp	byte ptr ds:tori_hp,30h	; '0'
		cmc				; Complement carry
		jnc	hp_inc_a		; was loc_46
		retn

hp_inc_a:					; was loc_46
		inc	byte ptr ds:tori_hp
		clc				; Clear carry flag
		retn

sub_5		endp

; -------------------------------------------------------------------------
;  sub_6 -- damage-apply / death arming.
;  AX = current row word; BX = damage; subtracts and floors at 0; calls
;  fight_cb_prep to validate; on first true zero arms gvar_death_flag
;  and resets glide/sub_phase state.
; -------------------------------------------------------------------------

sub_6		proc	near
		mov	ax,ds:tori_row_lo
		sub	ax,bx
		jnc	sub6_store		; was loc_47
		xor	ax,ax			; Zero register

sub6_store:					; was loc_47
		mov	ds:tori_row_lo,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	sub6_arm_death		; was loc_48
		retn

sub6_arm_death:					; was loc_48
		mov	byte ptr ds:gvar_death_flag,0FFh
		call	word ptr cs:fight_cb_shutdown
		mov	byte ptr ds:tori_phase_limit,0
		mov	byte ptr ds:tori_altitude,0
		mov	byte ptr ds:tori_dive_flag,0
		test	byte ptr ds:tori_glide_flag,0FFh
		jnz	sub6_reset_glide	; was loc_49
		retn

sub6_reset_glide:				; was loc_49
		mov	byte ptr ds:tori_pattern_idx,0
		mov	byte ptr ds:tori_glide_flag,0

sub6_clear_phase:				; was loc_54
		mov	byte ptr ds:tori_sub_phase,0
		mov	byte ptr ds:tori_attack_flag,0FFh
		retn

sub_6		endp

; -------------------------------------------------------------------------
;  death_phase (was loc_55) -- runs when gvar_death_flag is set.
;  Increments tori_pattern_idx up to 0x28 driving a fixed turn/spawn
;  animation, then sets gvar_completion (stage advance).
; -------------------------------------------------------------------------

death_phase:					; was loc_55
		mov	al,ds:tori_pattern_idx
		cmp	al,28h			; '('
		jae	death_complete		; was loc_57
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		mov	byte ptr ds:tori_phase_a,1
		mov	al,ds:tori_pattern_idx
		inc	byte ptr ds:tori_pattern_idx
		cmp	al,14h
		jae	death_late_phase	; was loc_56
		call	sub_2
		inc	byte ptr ds:tori_turn_flag
		and	byte ptr ds:tori_turn_flag,3
		mov	byte ptr ds:gvar_spawn_fx_flag,2Ch	; ','
		jmp	emit_setup

death_late_phase:				; was loc_56
		mov	byte ptr ds:tori_turn_cooldown,0FFh
		mov	byte ptr ds:tori_sub_phase,1
		jmp	emit_setup

death_complete:					; was loc_57
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; -------------------------------------------------------------------------
;  Orphan / dispatch-table-only block (file 0x648..0x6C7).
;  Reached via a 200FIGHT DS-resident dispatch slot (no static caller in
;  this module).  Sourcer mis-decoded the leading bytes as a chain of
;  conditional jumps; the actual runtime role is a small init/setup
;  routine bundled with a 16-entry word-pointer table that indexes
;  positions inside this same orphan block.  Kept as raw bytes since
;  the consumer logic lives in 200FIGHT.
; -------------------------------------------------------------------------

tori_orphan_init:				; was ';* No entry point' marker
		db	 73h,0A6h			; jnc -90  (Sourcer fixup byte)
		db	 75h,0A6h			; jnz -90  (Sourcer fixup byte)
		db	 77h,0A6h			; ja  -90  (Sourcer fixup byte)
		db	 7Ah,0A6h			; jp  -90  (Sourcer fixup byte)
		db	 7Ch,0A6h			; jl  -90  (Sourcer fixup byte)
		db	 7Eh,0A6h			; jle -90  (Sourcer fixup byte)
		db	 80h,0A6h, 82h,0A6h		; cmp ss:[bp+0A682h], al
		db	 84h,0A6h, 86h,0A6h		; test ss:[bp+0A686h], al
		db	 88h,0A6h			; mov [bx+si-58h], al
		db	 8Bh,0A6h, 8Eh,0A6h, 91h,0A6h	; mov sp, ss:[bp+0A691h]
		db	 9Bh,0A6h			; wait / cmpsb sequence
		db	 0A4h,0A6h			; movsb (cmpsb at 0xA6A4)
		db	 0ADh,0A6h			; lodsw / cmpsb (lodsw at 0xA6AD)
		db	 0B7h,0A6h			; ... (further dispatch table refs)
		db	 0C1h,0A6h

tori_orphan_data:
		db	 00h, 30h, 01h, 30h, 80h, 70h
		db	 90h, 71h, 81h, 72h, 82h, 73h
		db	 83h
		db	'P`QaRbSc'
		db	 10h, 40h, 20h, 17h, 46h, 26h
		db	 18h, 47h, 27h, 02h, 11h,0A0h
		db	 0C0h, 21h, 41h,0E0h, 31h,0B0h
		db	 0D0h, 02h, 12h, 22h, 42h,0B1h
		db	 32h,0A1h,0C1h,0D1h, 02h, 33h
		db	 0B2h, 13h, 43h,0C2h, 23h,0A2h
		db	 0D2h, 02h, 14h, 44h,0C3h, 24h
		db	 0A3h,0C1h,0D1h, 34h,0B3h, 03h
		db	 25h, 15h, 35h,0A4h,0D3h, 45h
		db	 0B4h,0E1h,0C4h, 04h, 25h, 16h
		db	 35h,0A4h,0C5h, 45h,0B5h,0D4h
		db	 0E2h

; -------------------------------------------------------------------------
;  Secondary pointer table (file 0x6CD..0x6EF) -- 17 word ptrs into
;  the trailing constant table below (range 0xA6F1..0xA75D).  Referenced
;  by 200FIGHT through a DS-resident dispatch slot (consumer not in this
;  module).
; -------------------------------------------------------------------------

tori_const_ptr_tbl	label	word
		db	 0F1h,0A6h, 0F1h,0A6h, 0FAh,0A6h	; -> 0xA6F1, 0xA6F1, 0xA6FA
		db	 03h,0A7h,  03h,0A7h,  03h,0A7h	; -> 0xA703 x3
		db	 0Ch,0A7h,  0Ch,0A7h,  0Ch,0A7h	; -> 0xA70C x3
		db	 0Ch,0A7h,  15h,0A7h,  1Eh,0A7h	; -> 0xA70C, 0xA715, 0xA71E
		db	 27h,0A7h,  30h,0A7h,  39h,0A7h	; -> 0xA727, 0xA730, 0xA739
		db	 42h,0A7h,  4Bh,0A7h,  54h,0A7h	; -> 0xA742, 0xA74B, 0xA754
		db	 5Dh,0A7h,  00h, 00h			; -> 0xA75D, end-of-list

; -------------------------------------------------------------------------
;  Trailing constant table (file 0x6F1..0x77F) -- timing/position bytes
;  consumed by 200FIGHT during tori init/spawn (per-slot offset records).
; -------------------------------------------------------------------------

tori_const_table:					; runtime addr 0xA6F1
		db	 50h
		db	12 dup (0)
		db	 04h, 0Ch
		db	7 dup (0)
		db	  4,   0,   4,   0,   0,   0
		db	  4,   4
		db	8 dup (0)
		db	 50h, 00h, 40h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 50h, 00h, 20h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 50h, 20h, 00h, 00h, 00h, 10h
		db	 00h, 10h, 0Ah,0A1h, 4Ah, 00h
		db	 00h, 00h, 20h, 00h, 20h, 54h
		db	 00h, 55h, 00h, 00h, 00h, 10h
		db	 05h, 10h, 05h, 10h, 05h, 00h
		db	 00h, 00h, 20h, 00h, 50h, 04h
		db	 50h, 05h, 50h, 00h, 00h, 04h
		db	 00h, 14h, 00h, 54h, 00h, 54h
		db	 00h, 10h, 04h, 00h, 14h, 00h
		db	 54h, 00h, 54h, 00h, 04h, 00h
		db	 00h,0A7h, 00h, 32h, 04h, 28h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 2Eh, 00h, 12h,0F4h, 01h,0F4h
		db	 01h, 08h,0FFh, 80h,0A7h,0F4h
		db	 01h, 12h,0BBh, 00h, 5		; final 5 = Pascal-string len for 'Pollo'

; -------------------------------------------------------------------------
;  'Pollo' name tag (file 0x780) -- 5-char Pascal string with length-prefix
;  byte 5 (last byte of tori_const_table above).  Plus 91 zero bytes of
;  trailing padding to file size 2024 (0x7E8).
; -------------------------------------------------------------------------

tori_name_tag:
		db	'Pollo'			; 5 chars (length prefix is last byte of tori_const_table)
		db	91 dup (0)		; pad to end-of-file

seg_a		ends

		end	start
