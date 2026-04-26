
PAGE  59,132

;==========================================================================
;
;  310TAKO.BIN - Tako / Octopus Enemy Code Module (zelres3 chunk 11, 'Pulpo')
;
;  Tako (octopus) enemy sprite/logic module loaded by 200FIGHT.asm
;  alongside EAI2/EAI3 behavior handlers.  The Japanese name "tako" means
;  octopus; the Spanish marker 'Pulpo' ('octopus') appears as an 8-char
;  Pascal-string tag in the module's trailing data.
;
;  File layout (loaded at game_seg:0xA000 by 200FIGHT):
;    0x000..0x003 : file-size header word (= file_size - 4) + pad
;    0x004..0x007 : init src/dst pointers (tako_init_src=0xA27D,
;                   tako_init_dst=tako_row_pos_base 0xAA80)
;    0x008..0x013 : 12 zero bytes (initial state buffer)
;    0x014..0x033 : 32-byte template/state buffer (mostly 0Ah, 0x28 marker)
;    0x034..0x03F : tako_frame_ptr_tbl_a -- 6 word ptrs (0xA052..0xA1E2)
;    0x040..0x04F : 16 zero bytes (reserved)
;    0x050..0x055 : tako_frame_ptr_tbl_b -- 3 word ptrs (0xA255,0xA205,0xA25F)
;                   (last 4 bytes 0x52..0x55 alias into tako_frame_00 below)
;    0x052..0x280 : sprite frame data (5-byte tile rows w/ 00 terminators);
;                   tako_frame_00 starts at 0x052 (overlapping tail of tbl_b),
;                   not 0x056 -- see tbl_a[0]=0xA052
;    0x281..0x28F : tako_scan_prolog (mov si,fight_slot_list / clear state)
;    0x28F..0x506 : main scan-and-update code (was loc_1..loc_27)
;    0x507..0x533 : hp_dec helper (was sub_1)
;    0x534..0x580 : timeout/death-phase code (was loc_32..loc_34)
;    0x581..0x598 : sprite-source init block, reached via 200FIGHT
;                   DS-resident dispatch slot (no static caller in this module)
;    0x599..0x5C2 : tako_row_data_ptrs -- 21 word ptrs (last entry = 0x0000 end)
;    0x5C3..0x766 : tako_row_data_head -- 15 unreferenced 28-byte sub-blocks
;    0x767..0x9B2 : tako_row_data_blk_00..blk_19 -- ptr-targeted sub-blocks
;                   (sizes 32,36,34,34,28×15,32; 1008 bytes total for row_data)
;    0x9B3..0x9EE : tako_pattern_ptr_tbl -- 30 word ptrs into 7-byte patterns
;    0x9EF..0xA1F : tako_sprite_patterns -- 7-byte sprite-row patterns
;    0xA20..0xA84 : tako_row_template -- 100-byte row template table
;    0xA85..0xA94 : tako_tail_const -- 16 trailing timing/position constants
;    0xA95..0xA99 : 'Pulpo' name tag (5 chars, prefixed by length byte 5)
;    0xA9A..0xAA5 : 12 trailing zeros (padding)
;
;  Primary code entry: scan_slot_loop (at 0x28F) -- iterates the enemy
;  slot list (SI = fight_slot_list), drives octopus-specific frame/tentacle
;  animations via the fight callbacks, handles multi-arm sprite columns,
;  and respawns tentacle projectiles on timed phases.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; Fight-engine callback vectors / shared globals (DS at game_seg).


; Shared sprite pattern tables used by Tako (DS, game_seg).

sprite_pat_tbl_a	equ	0A57Dh			; sprite pattern table A
sprite_pat_tbl_b	equ	0A64Dh			; sprite pattern table B
dir_xlat_table		equ	0A725h			; direction lookup table (xlat base)
tako_vector_tbl		equ	0A9AFh			; tako render-vector table
sprite_src_base		equ	0E3A5h			; tako sprite-source base

; Tako-specific global state (DS at game_seg).

tako_row_pos_base	equ	0AA80h			; current row position (word base)
tako_row_delta		equ	0AA82h			; row delta byte
tako_hp			equ	0AA83h			; Tako HP counter
tako_phase_a		equ	0AA96h			; phase counter A
tako_flag_a		equ	0AA97h			; flag byte A (direction base)
tako_flag_b		equ	0AA98h			; flag byte B (state)
tako_flag_c		equ	0AA99h			; flag byte C (animation)
tako_frame_idx		equ	0AA9Ah			; frame index / slot index
tako_state		equ	0AA9Bh			; state byte
tako_alt_state		equ	0AA9Ch			; alternate state byte
tako_timer_a		equ	0AA9Eh			; timer A (word)
tako_timer_a_byte	equ	0AA9Fh			; timer A byte (low half)
tako_col_pos		equ	0AAA1h			; col position byte

; ----- Slot-record layout helpers (for readability in code below) -----
;   [si+0..1] = sprite tile word   [si+4] = attribute  [si+5] = flags
;   [si+2..3] = record indices     [si+6] = frame      [si+10h] = next

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

tako_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer forced `start:` here but no execution lands here; the bytes are
;  actually a 4-byte length header, a 4-byte init src/dst pair, and two
;  template blocks used to initialize the per-slot state buffer.
; -------------------------------------------------------------------------

start:

file_header:
		db	0A2h, 0Ah		; file length word: 0x0AA2 (= file_size - 4)
		db	 00h, 00h		; pad / flag word

tako_init_src_dst:
		db	 7Dh,0A2h		; init src ptr = 0xA27D (into row data)
		db	 80h,0AAh		; init dst ptr = tako_row_pos_base (0xAA80)

		db	12 dup (0)		; initial per-slot state buffer

tako_state_template:				; 32-byte template (mostly 0Ah)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; bytes 0-6   (0x014..0x01A)
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; bytes 7-13  (0x01B..0x021)
		db	0Ah, 0Ah, '(', 0Ah, 0Ah, 0Ah, 0Ah	; bytes 14-20 (0x022..0x028); '(' = 0x28 marker at offset 16
		db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah	; bytes 21-27 (0x029..0x02F)
		db	0Ah, 0Ah, 0Ah, 0Ah			; bytes 28-31 (0x030..0x033)

; -------------------------------------------------------------------------
;  Frame pointer tables (file 0x034..0x055).
;  Each entry = runtime address in game_seg (= 0xA000 + file offset).
; -------------------------------------------------------------------------

tako_frame_ptr_tbl_a	label	word		; 6 frame-data pointers (group A)
		db	 52h,0A0h, 0A2h,0A0h, 0F2h,0A0h	; -> 0xA052, 0xA0A2, 0xA0F2
		db	 42h,0A1h, 92h,0A1h, 0E2h,0A1h	; -> 0xA142, 0xA192, 0xA1E2
		db	16 dup (0)			; reserved / padding

tako_frame_ptr_tbl_b	label	word		; 3 frame-data pointers (group B)
		db	 55h,0A2h			; -> 0xA255 (tbl_b[0])
;		First 4 bytes of tako_frame_00 below (`05 A2 5F A2`) double as
;		the remaining 2 ptr-tbl entries: 0xA205 (tbl_b[1]), 0xA25F (tbl_b[2]).
;		Same overlap pattern as 309CRAB's crab_frame_00.

; -------------------------------------------------------------------------
;  Sprite frame data (file 0x052..0x280).
;  5-byte tile-row records (4 tile bytes + 0x00 row-terminator), grouped
;  into 9 frames by tako_frame_ptr_tbl_a/b.  tako_frame_00's leading 4
;  bytes alias the tail of tako_frame_ptr_tbl_b above (`05 A2 5F A2` =
;  ptrs 0xA205, 0xA25F).  Most frames are 16 rows (80 bytes); frame_05 is
;  7 rows, frame_b0 is 2 rows, frame_b2 is 6+1 rows ending with 0x02
;  terminators (rather than 0x00).
; -------------------------------------------------------------------------

tako_frame_00:					; offset 0x052 -> ptr 0xA052 (tbl_a[0])
		db	 05h,0A2h, 5Fh,0A2h, 00h	; row 0  (overlaps tbl_b tail: ptrs 0xA205,0xA25F)
		db	 00h, 00h, 01h, 00h, 00h	; row 1
		db	 02h, 03h, 04h, 05h, 00h	; row 2
		db	 00h, 00h, 06h, 07h, 00h	; row 3
		db	 00h, 00h, 08h, 09h, 00h	; row 4
		db	 0Ah, 0Bh, 0Ch, 0Dh, 00h	; row 5
		db	 0Eh, 0Fh, 10h, 11h, 00h	; row 6
		db	 00h, 00h, 00h, 16h, 00h	; row 7
		db	 17h, 18h, 19h, 1Ah, 00h	; row 8
		db	 1Bh, 1Ch, 1Dh, 1Eh, 00h	; row 9
		db	 00h, 00h, 1Fh, 20h, 00h	; row 10
		db	 00h, 00h, 21h, 22h, 00h	; row 11
		db	 23h, 24h, 25h, 26h, 00h	; row 12
		db	 27h, 28h, 29h, 2Ah, 00h	; row 13
		db	 00h, 00h, 2Bh, 2Ch, 00h	; row 14
		db	 2Dh, 2Eh, 2Fh, 30h, 00h	; row 15

tako_frame_01:					; offset 0x0A2 -> ptr 0xA0A2 (tbl_a[1])
		db	 31h, 32h, 33h, 34h, 00h	; row 0
		db	 00h, 00h, 00h, 35h, 00h	; row 1
		db	 36h, 37h, 38h, 39h, 00h	; row 2
		db	 3Ah, 3Bh, 3Ch, 3Dh, 00h	; row 3
		db	 00h, 00h, 00h, 3Eh, 00h	; row 4
		db	 3Fh, 40h, 41h, 42h, 00h	; row 5
		db	 43h, 44h, 45h, 1Ah, 00h	; row 6
		db	 00h, 00h, 46h, 47h, 00h	; row 7
		db	 48h, 24h, 25h, 26h, 00h	; row 8
		db	 00h, 00h, 49h, 4Ah, 00h	; row 9
		db	 4Bh, 4Ch, 4Dh, 4Eh, 00h	; row 10
		db	 00h, 00h, 4Fh, 4Ah, 00h	; row 11
		db	 50h, 4Ch, 4Dh, 4Eh, 00h	; row 12
		db	 00h, 00h, 21h, 51h, 00h	; row 13
		db	 23h, 52h, 25h, 26h, 00h	; row 14
		db	 53h, 00h, 54h, 55h, 00h	; row 15

tako_frame_02:					; offset 0x0F2 -> ptr 0xA0F2 (tbl_a[2])
		db	 00h, 56h, 57h, 58h, 00h	; row 0
		db	 00h, 00h, 03h, 00h, 00h	; row 1
		db	 59h, 5Ah, 5Bh, 5Ch, 00h	; row 2
		db	 0Eh, 5Dh, 5Eh, 5Fh, 00h	; row 3
		db	 00h, 00h, 63h, 00h, 00h	; row 4
		db	 64h, 65h, 66h, 67h, 00h	; row 5
		db	 68h, 69h, 6Ah, 6Bh, 00h	; row 6
		db	 0Eh, 6Ch, 6Dh, 5Fh, 00h	; row 7
		db	 71h, 44h, 45h, 1Ah, 00h	; row 8
		db	 00h, 00h, 72h, 73h, 00h	; row 9
		db	 74h, 00h, 75h, 76h, 00h	; row 10
		db	 00h, 00h, 77h, 78h, 00h	; row 11
		db	 79h, 7Ah, 7Bh, 7Ch, 00h	; row 12
		db	 7Fh, 18h, 19h, 1Ah, 00h	; row 13
		db	 80h, 00h, 81h, 82h, 00h	; row 14
		db	 00h, 00h, 00h, 83h, 00h	; row 15

tako_frame_03:					; offset 0x142 -> ptr 0xA142 (tbl_a[3])
		db	 00h, 00h, 77h, 78h, 00h	; row 0
		db	 84h, 85h, 86h, 87h, 00h	; row 1
		db	 00h, 00h, 00h, 17h, 00h	; row 2
		db	 8Ah, 8Bh, 8Ch, 8Dh, 00h	; row 3
		db	 00h, 00h, 8Eh, 8Fh, 00h	; row 4
		db	 90h, 91h, 92h, 93h, 00h	; row 5
		db	 00h, 95h, 96h, 97h, 00h	; row 6
		db	 66h, 00h, 98h, 99h, 00h	; row 7
		db	 9Ah, 00h, 9Bh, 9Ch, 00h	; row 8
		db	 00h, 9Dh, 9Eh, 9Fh, 00h	; row 9
		db	0A2h,0A3h, 00h,0A4h, 00h	; row 10
		db	 00h, 00h,0A5h,0A6h, 00h	; row 11
		db	0C5h,0CCh,0C6h, 15h, 00h	; row 12
		db	 0Ah,0A9h,0AAh, 0Dh, 00h	; row 13
		db	 0Ah,0ACh,0ADh,0AEh, 00h	; row 14
		db	 0Eh, 0Fh,0AFh, 11h, 00h	; row 15

tako_frame_04:					; offset 0x192 -> ptr 0xA192 (tbl_a[4])
		db	 00h, 56h, 00h, 00h, 00h	; row 0
		db	 59h,0B1h, 00h,0B2h, 00h	; row 1
		db	 0Eh, 5Dh,0B3h, 5Fh, 00h	; row 2
		db	0B5h,0B6h, 00h, 67h, 00h	; row 3
		db	0B7h,0B8h, 6Ah, 6Bh, 00h	; row 4
		db	 00h, 00h, 75h, 76h, 00h	; row 5
		db	 00h,0BAh, 7Bh, 7Ch, 00h	; row 6
		db	0BCh,0BDh, 86h, 87h, 00h	; row 7
		db	0CEh,0CFh, 8Ch, 00h, 00h	; row 8
		db	 90h,0BFh, 00h,0C0h, 00h	; row 9
		db	 00h, 9Dh, 00h,0C2h, 00h	; row 10
		db	 0Ah,0ACh,0ADh,0AEh, 00h	; row 11
		db	 0Eh, 5Dh,0C4h, 5Fh, 00h	; row 12
		db	 0Eh, 0Fh,0C4h, 11h, 00h	; row 13
		db	 0Eh, 6Ch,0C4h, 5Fh, 00h	; row 14
		db	 0Eh, 0Fh,0C4h,0C7h, 00h	; row 15

tako_frame_05:					; offset 0x1E2 -> ptr 0xA1E2 (tbl_a[5]; 7 rows)
		db	 17h, 18h,0C8h,0C9h, 00h	; row 0
		db	0CAh,0CBh, 1Dh, 1Eh, 00h	; row 1
		db	 0Eh, 5Dh,0C4h,0CDh, 00h	; row 2
		db	 43h, 44h,0C8h,0C9h, 00h	; row 3
		db	 0Eh, 6Ch,0C4h,0CDh, 00h	; row 4
		db	 71h, 44h,0C8h,0C9h, 00h	; row 5
		db	 7Fh, 18h,0C8h,0C9h, 00h	; row 6

tako_frame_b1:					; offset 0x205 -> ptr 0xA205 (tbl_b[1])
		db	 00h, 00h, 08h,0A8h, 00h	; row 0
		db	 12h, 13h, 14h, 15h, 00h	; row 1
		db	 60h, 61h, 62h, 15h, 00h	; row 2
		db	 6Eh, 6Fh, 70h, 15h, 00h	; row 3
		db	 7Dh, 6Fh, 7Eh, 15h, 00h	; row 4
		db	 88h, 6Fh, 89h, 15h, 00h	; row 5
		db	 94h, 6Fh, 89h, 15h, 00h	; row 6
		db	0A0h, 6Fh,0A1h, 15h, 00h	; row 7
		db	0ABh, 6Fh, 14h, 15h, 00h	; row 8
		db	0B0h, 13h, 14h, 15h, 00h	; row 9
		db	0B4h, 61h, 62h, 15h, 00h	; row 10
		db	0B9h, 6Fh, 70h, 15h, 00h	; row 11
		db	0BBh, 6Fh, 7Eh, 15h, 00h	; row 12
		db	0BEh, 6Fh, 89h, 15h, 00h	; row 13
		db	0C1h, 6Fh, 89h, 15h, 00h	; row 14
		db	0C3h, 6Fh, 89h, 15h, 00h	; row 15

tako_frame_b0:					; offset 0x255 -> ptr 0xA255 (tbl_b[0]; 2 rows)
		db	0C5h, 6Fh, 14h, 15h, 00h	; row 0
		db	0C5h, 13h,0C6h, 15h, 00h	; row 1

tako_frame_b2:					; offset 0x25F -> ptr 0xA25F (tbl_b[2]; rows end in 0x02)
		db	 00h, 00h,0A7h,0A8h, 02h	; row 0  (terminator 0x02, not 0x00)
		db	 00h,0D0h, 00h,0D1h, 02h	; row 1
		db	0D2h,0D3h,0D4h,0D5h, 02h	; row 2
		db	 00h, 00h,0D6h,0D7h, 02h	; row 3
		db	0D8h,0D9h,0DAh,0DBh, 02h	; row 4
		db	0DCh,0DDh,0DEh,0DFh, 02h	; row 5
		db	0E0h,0E1h,0E2h,0E3h		; row 6 (4 bytes; no terminator -- followed by code)

; -------------------------------------------------------------------------
;  Small inline scan-prolog (file 0x280..0x28E) -- decoded x86, NOT data.
;  Falls through directly into scan_slot_loop.  Same structure as
;  309CRAB's crab_scan_prolog.
; -------------------------------------------------------------------------

tako_scan_prolog:
		mov	si,ds:fight_slot_list		; was: 8B 36 10 C0
		mov	byte ptr ds:tako_frame_idx,0	; was: C6 06 9A AA 00
		mov	byte ptr ds:tako_state,0	; was: C6 06 9B AA 00

scan_slot_loop:					; was loc_1 (file 0x28F)
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		; cmp word ptr [si],0FFFFh
							;  (alt encoding: sign-extended imm8 form;
							;   TASM emits 4-byte form, so keep as db)
			jz	scan_done		; was loc_4 -- end of slot list
			mov	ax,[si]
			call	word ptr cs:fight_cb_anim_step
			jc	scan_next_slot		; was loc_3 -- callback consumed slot
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:tako_frame_idx
			xor	bh,bh			; Zero register
			mov	al,ds:sprite_idx_table[bx]
			mov	[di],al
			test	byte ptr [si+5],40h	; '@'  bit6 = active
			jz	scan_next_slot
			test	byte ptr ds:tako_state,80h
			jnz	scan_next_slot
			mov	al,[si+5]
			and	al,1Fh
			cmp	byte ptr [si+4],0Eh
			jb	apply_state_bits	; was loc_2
			or	al,80h

apply_state_bits:				; was loc_2
			mov	ds:tako_state,al

scan_next_slot:					; was loc_3
			inc	byte ptr ds:tako_frame_idx
			add	si,10h
			jmp	short scan_slot_loop

scan_done:					; was loc_4
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFFh
		mov	al,ds:tako_state
		or	al,al			; Zero ?
		jz	prep_phase_check	; was loc_7
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		pop	ax
		or	al,al			; Zero ?
		jns	hit_pos_branch		; was loc_5
		mov	byte ptr ds:gvar_spawn_fx_flag,24h	; '$'
		add	bx,bx
		jmp	short hit_apply		; was loc_6

hit_pos_branch:					; was loc_5
		mov	byte ptr ds:gvar_spawn_fx_flag,25h	; '%'

hit_apply:					; was loc_6
		call	hp_dec			; was sub_1
		test	byte ptr ds:tako_flag_b,10h
		jnz	prep_phase_check	; was loc_7
		mov	bx,tako_flag_a
		cmp	byte ptr [bx],10h
		je	prep_phase_check
		add	byte ptr [bx],8
		mov	byte ptr ds:tako_flag_b,10h
		or	byte ptr ds:tako_flag_c,20h	; ' '
		mov	byte ptr ds:gvar_spawn_fx_flag,26h	; '&'

prep_phase_check:				; was loc_7
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	dispatch_phase		; was loc_8
		jmp	death_phase		; was loc_32

dispatch_phase:					; was loc_8
		inc	byte ptr ds:tako_phase_a
		and	byte ptr ds:tako_phase_a,7
		mov	dl,ds:tako_flag_a
		mov	bx,tako_flag_b
		test	byte ptr [bx],10h
		jz	flag_b_skip		; was loc_10
		xor	byte ptr [bx],20h	; ' '
		test	byte ptr [bx],20h	; ' '
		jnz	flag_b_step		; was loc_9
		sub	dl,8

flag_b_step:					; was loc_9
		mov	al,[bx]
		mov	ah,al
		and	al,0F0h
		inc	ah
		and	ah,0Fh
		or	al,ah
		mov	[bx],al
		or	ah,ah			; Zero ?
		jnz	flag_b_skip
		and	byte ptr [bx],0EFh
		and	byte ptr ds:tako_flag_c,0DFh

flag_b_skip:					; was loc_10
		cmp	dl,10h
		jne	emit_setup		; was loc_14
		mov	bx,tako_flag_c
		test	byte ptr [bx],40h	; '@'
		jz	flag_c_check_a0		; was loc_11
		mov	al,20h			; ' '
		xor	al,[bx]
		mov	ah,al
		inc	al
		and	al,3
		and	ah,0E0h
		or	ah,al
		mov	[bx],ah
		or	al,al			; Zero ?
		jnz	flag_c_active		; was loc_12
		mov	byte ptr [bx],0A0h
		mov	ax,ds:tako_row_pos_base
		add	ax,4
		mov	ds:tako_timer_a_byte,ax
		mov	al,ds:tako_row_delta
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:tako_col_pos,al
		mov	byte ptr ds:gvar_spawn_fx_flag,27h	; '''

flag_c_check_a0:				; was loc_11
		test	byte ptr [bx],0A0h
		jnz	flag_c_active
		test	byte ptr ds:tako_flag_b,10h
		jnz	flag_c_active
		or	byte ptr [bx],40h	; '@'

flag_c_active:					; was loc_12
		test	byte ptr [bx],20h	; ' '
		jnz	flag_c_high		; was loc_13
		add	dl,8

flag_c_high:					; was loc_13
		test	byte ptr [bx],80h
		jz	emit_setup
		mov	al,[bx]
		mov	ah,al
		inc	ah
		and	ah,1Fh
		and	al,0E0h
		or	al,ah
		mov	[bx],al
		dec	word ptr ds:tako_timer_a_byte
		cmp	ah,19h
		jne	emit_setup
		mov	byte ptr [bx],0

emit_setup:					; was loc_14
		mov	byte ptr ds:tako_frame_idx,0
		mov	bl,ds:tako_phase_a
		xor	bh,bh			; Zero register
		add	bl,dl
		add	bl,bl
		mov	di,ds:sprite_pat_tbl_a[bx]
		mov	bx,ds:tako_vector_tbl[bx]
		mov	ax,ds:tako_row_pos_base
		mov	si,ds:fight_slot_list
		mov	cx,7

emit_outer_loop:				; was loc_15
		push	cx
		push	bx
		push	ax
		call	word ptr cs:fight_cb_anim_step
		mov	ds:tako_alt_state,bl
		pop	ax
		pop	bx
		jnc	emit_active_arm		; was loc_18
		mov	cx,8

emit_skip_arm_loop:				; was locloop_16
			rol	byte ptr [bx],1		; Rotate
			jnc	emit_skip_arm_next	; was loc_17
			inc	di
			inc	di

emit_skip_arm_next:				; was loc_17
			loop	emit_skip_arm_loop	; Loop if cx > 0

		jmp	short emit_outer_advance	; was loc_22

emit_active_arm:				; was loc_18
		xor	cx,cx			; Zero register

emit_arm_loop:					; was loc_19
			push	cx
			push	bx
			rol	byte ptr [bx],1		; Rotate
			jnc	emit_arm_next		; was loc_21
			mov	[si],ax
			add	cl,cl
			add	cl,ds:tako_row_delta
			and	cl,3Fh			; '?'
			mov	[si+2],cl
			mov	cl,ds:tako_alt_state
			mov	[si+3],cl
			mov	cl,[di]
			mov	[si+4],cl
			mov	cl,[di+1]
			mov	[si+6],cl
			mov	byte ptr [si+5],0
			test	byte ptr ds:tako_state,0FFh
			jz	emit_arm_no_bit		; was loc_20
			or	byte ptr [si+5],20h	; ' '

emit_arm_no_bit:				; was loc_20
			push	di
			push	ax
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:tako_frame_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:sprite_idx_table[bx],al
			pop	ax
			pop	di
			add	si,10h
			add	di,2
			inc	byte ptr ds:tako_frame_idx

emit_arm_next:					; was loc_21
			pop	bx
			pop	cx
			inc	cx
			cmp	cx,8
			jne	emit_arm_loop

emit_outer_advance:				; was loc_22
		inc	bx
		add	ax,2
		pop	cx
		loop	emit_outer_iter		; was locloop_23

		jmp	short emit_proj_phase	; was loc_24

emit_outer_iter:				; was locloop_23
		jmp	emit_outer_loop

emit_proj_phase:				; was loc_24
		mov	al,ds:tako_flag_c
		test	al,80h
		jz	emit_done		; was loc_27
		and	al,1Fh
		dec	al
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		add	ax,0AA20h		; tako_row_pos_base - 0x60 (proj base)
		mov	di,ax
		mov	ax,ds:tako_timer_a_byte
		mov	cx,4

emit_proj_loop:					; was locloop_25
			push	cx
			push	ax
			call	word ptr cs:fight_cb_anim_step
			pop	ax
			jc	emit_proj_next		; was loc_26
			mov	dl,[di]
			or	dl,dl			; Zero ?
			jz	emit_proj_next
			push	di
			push	ax
			mov	[si],ax
			mov	al,ds:tako_col_pos
			mov	[si+2],al
			mov	[si+3],bl
			mov	byte ptr [si+4],30h	; '0'
			dec	dl
			mov	[si+6],dl
			mov	byte ptr [si+5],0
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:tako_frame_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:sprite_idx_table[bx],al
			add	si,10h
			inc	byte ptr ds:tako_frame_idx
			pop	ax
			pop	di

emit_proj_next:					; was loc_26
			inc	di
			inc	ax
			pop	cx
			loop	emit_proj_loop

emit_done:					; was loc_27
		mov	word ptr [si],0FFFFh
		retn

tako_main	endp

; -------------------------------------------------------------------------
;  hp_dec -- decrement tako_hp by bx, floor at 0; calls fight_cb_prep to
;  validate; sets gvar_death_flag and clears tako_timer_a on first kill.
;  (was sub_1)
; -------------------------------------------------------------------------

hp_dec		proc	near
		mov	ax,ds:tako_hp
		sub	ax,bx
		jnc	hp_dec_store		; was loc_28
		xor	ax,ax			; Zero register

hp_dec_store:					; was loc_28
		mov	ds:tako_hp,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	hp_dec_check_death	; was loc_29
		retn

hp_dec_check_death:				; was loc_29
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	hp_dec_arm_death	; was loc_30
		retn

hp_dec_arm_death:				; was loc_30
		mov	byte ptr ds:tako_timer_a,0
		mov	byte ptr ds:gvar_death_flag,0FFh

hp_dec_ret:					; shared retn (used by jno in tako_sprite_src_init below)
		retn

hp_dec		endp

; -------------------------------------------------------------------------
;  death_phase (was loc_32) -- runs when gvar_death_flag is set.
;  tako_timer_a counts up to 0x28; at 0x14 it switches to alt swing,
;  and at 0x28 it sets gvar_completion (stage advance).
; -------------------------------------------------------------------------

death_phase:					; was loc_32
		mov	byte ptr ds:tako_flag_c,0
		cmp	byte ptr ds:tako_timer_a,28h	; '('
		jae	death_complete		; was loc_34
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		mov	bx,tako_timer_a
		cmp	byte ptr [bx],14h
		jae	death_alt_swing		; was loc_33
		inc	byte ptr [bx]
		mov	al,[bx]
		mov	bx,tako_phase_a
		inc	byte ptr [bx]
		and	byte ptr [bx],7
		and	al,1
		add	al,al
		add	al,al
		add	al,al
		add	al,ds:tako_flag_a
		mov	dl,al
		mov	byte ptr ds:gvar_spawn_fx_flag,28h	; '('
		jmp	emit_setup		; was loc_14

death_alt_swing:				; was loc_33
		inc	byte ptr [bx]
		mov	dl,ds:tako_flag_a
		add	dl,8
		jmp	emit_setup

death_complete:					; was loc_34
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; -------------------------------------------------------------------------
;  tako_sprite_src_init (file 0x581..0x598) -- sprite-source / pattern
;  init constants reached via 200FIGHT DS-resident dispatch slot (loaded
;  into game DS at runtime so static analysis cannot trace the call).
;  Sourcer decoded these 24 bytes as `mov bp,sprite_src_base / movsw /
;  pop es / cmpsb / sub ss:[..],sp / jno hp_dec_ret / xchg bp,ax / ...`,
;  consistent with sprite_src_base (0xE3A5) setup followed by stream-copy
;  pointers.  Kept as raw bytes since the consumer dispatch logic lives
;  in 200FIGHT and selects this slot at runtime.
; -------------------------------------------------------------------------

tako_sprite_src_init:				; DS-dispatch handler (reached via 200FIGHT)
		db	 0BDh,0A5h,0E3h			; mov bp, 0E3A5h (sprite_src_base)
		db	 0A5h				; movsw
		db	 07h				; pop es
		db	 0A6h				; cmpsb
		db	 29h,0A6h, 4Dh,0A6h		; sub ss:[bp+0A64Dh], sp
		db	 71h,0A6h			; jno -90  (lands on hp_dec_ret)
		db	 95h				; xchg bp,ax
		db	 0A6h				; cmpsb
		db	 0B9h,0A6h,0DDh			; mov cx, 0DDA6h
		db	 0A6h				; cmpsb
		db	 01h,0A7h,025h,0A7h		; add ds:[bx+0A725h], sp
		db	 47h				; inc di
		db	 0A7h				; cmpsw

; -------------------------------------------------------------------------
;  tako_row_data_ptrs (file 0x599..0x5C2) -- 21 word pointers into the
;  packed 5-byte row-data table that follows.  Last entry 0x0000 is
;  end-of-list.  Each entry's runtime address = 0xA000 + file_offset of
;  a row-data block of (typically) 28 bytes.
; -------------------------------------------------------------------------

tako_row_data_ptrs	label	word
		db	 67h,0A7h, 87h,0A7h, 0ABh,0A7h	; -> 0xA767, 0xA787, 0xA7AB
		db	 0CDh,0A7h, 0EFh,0A7h, 0Bh,0A8h	; -> 0xA7CD, 0xA7EF, 0xA80B
		db	 27h,0A8h, 43h,0A8h, 5Fh,0A8h	; -> 0xA827, 0xA843, 0xA85F
		db	 7Bh,0A8h, 97h,0A8h, 0B3h,0A8h	; -> 0xA87B, 0xA897, 0xA8B3
		db	 0CFh,0A8h, 0EBh,0A8h, 07h,0A9h	; -> 0xA8CF, 0xA8EB, 0xA907
		db	 23h,0A9h, 3Fh,0A9h, 5Bh,0A9h	; -> 0xA923, 0xA93F, 0xA95B
		db	 77h,0A9h, 93h,0A9h, 00h, 00h	; -> 0xA977, 0xA993, end

; -------------------------------------------------------------------------
;  tako_row_data (file 0x5C3..0x9B2, 1008 bytes).
;  Sub-divided into:
;    0x5C3..0x766 (420 bytes)  tako_row_data_head
;       15 unreferenced 28-byte sub-blocks; consumed by 200FIGHT directly
;       (no entry in tako_row_data_ptrs points here).
;    0x767..0x9B2 (588 bytes)  tako_row_data_blk_00..tako_row_data_blk_19
;       20 named sub-blocks targeted by tako_row_data_ptrs[0..19].
;       Sizes: blk_00=32, blk_01=36, blk_02=34, blk_03=34,
;              blk_04..blk_18=28 each, blk_19=32.
;    Each sub-block is laid out as 4-byte rows (`+OO` offset comments)
;    matching the natural stride observed in the data; common signatures
;    are `01 04 01 02` and `01 01 01 02` (header) followed by payload.
; -------------------------------------------------------------------------

tako_row_data_head:				; 0x5C3..0x766 (420 bytes, 15 unreferenced 28-byte sub-blocks)
;   No ptr-table entries point here -- consumed by other dispatch logic
;   in 200FIGHT (sprite-init or row template seed).
;--- head sub-block 0 (file 0x5C3, 28 bytes) ---
		db	 00h, 01h, 00h, 02h	; +00
		db	 00h, 03h, 00h, 04h	; +04
		db	 00h, 05h, 0Fh, 00h	; +08
		db	 00h, 06h, 00h, 07h	; +0C
		db	 00h, 08h, 00h, 0Ah	; +10
		db	 00h, 0Bh, 00h, 0Ch	; +14
		db	 00h, 0Dh, 00h, 0Eh	; +18
;--- head sub-block 1 (file 0x5DF, 28 bytes) ---
		db	 00h, 0Fh, 01h, 00h	; +00
		db	 01h, 01h, 01h, 02h	; +04
		db	 01h, 0Eh, 01h, 0Fh	; +08
		db	 02h, 00h, 02h, 01h	; +0C
		db	 02h, 02h, 0Fh, 01h	; +10
		db	 00h, 06h, 01h, 05h	; +14
		db	 00h, 08h, 01h, 06h	; +18
;--- head sub-block 2 (file 0x5FB, 28 bytes) ---
		db	 01h, 07h, 00h, 0Ch	; +00
		db	 01h, 08h, 01h, 09h	; +04
		db	 00h, 0Fh, 01h, 03h	; +08
		db	 01h, 01h, 01h, 02h	; +0C
		db	 02h, 03h, 02h, 04h	; +10
		db	 02h, 05h, 02h, 06h	; +14
		db	 0Fh, 02h, 00h, 09h	; +18
;--- head sub-block 3 (file 0x617, 28 bytes) ---
		db	 02h, 07h, 00h, 08h	; +00
		db	 01h, 06h, 01h, 07h	; +04
		db	 00h, 0Ch, 00h, 0Dh	; +08
		db	 00h, 0Eh, 00h, 0Fh	; +0C
		db	 01h, 03h, 01h, 04h	; +10
		db	 01h, 02h, 02h, 08h	; +14
		db	 02h, 09h, 02h, 0Ah	; +18
;--- head sub-block 4 (file 0x633, 28 bytes) ---
		db	 02h, 0Bh, 02h, 06h	; +00
		db	 0Fh, 03h, 00h, 09h	; +04
		db	 02h, 0Ch, 00h, 08h	; +08
		db	 00h, 0Ah, 00h, 0Bh	; +0C
		db	 00h, 0Ch, 01h, 08h	; +10
		db	 01h, 09h, 00h, 0Fh	; +14
		db	 01h, 00h, 01h, 04h	; +18
;--- head sub-block 5 (file 0x64F, 28 bytes) ---
		db	 01h, 02h, 02h, 0Dh	; +00
		db	 02h, 0Eh, 02h, 0Fh	; +04
		db	 03h, 00h, 02h, 06h	; +08
		db	 0Fh, 04h, 00h, 06h	; +0C
		db	 02h, 0Ch, 00h, 08h	; +10
		db	 01h, 0Ch, 01h, 0Dh	; +14
		db	 00h, 0Ch, 01h, 0Ah	; +18
;--- head sub-block 6 (file 0x66B, 28 bytes) ---
		db	 01h, 0Bh, 00h, 0Fh	; +00
		db	 01h, 00h, 01h, 01h	; +04
		db	 01h, 02h, 03h, 01h	; +08
		db	 03h, 02h, 03h, 03h	; +0C
		db	 03h, 04h, 02h, 06h	; +10
		db	 0Fh, 05h, 00h, 06h	; +14
		db	 02h, 07h, 00h, 08h	; +18
;--- head sub-block 7 (file 0x687, 28 bytes) ---
		db	 01h, 06h, 01h, 07h	; +00
		db	 00h, 0Ch, 01h, 08h	; +04
		db	 01h, 09h, 00h, 0Fh	; +08
		db	 01h, 03h, 01h, 01h	; +0C
		db	 01h, 02h, 03h, 05h	; +10
		db	 03h, 06h, 03h, 07h	; +14
		db	 03h, 08h, 02h, 06h	; +18
;--- head sub-block 8 (file 0x6A3, 28 bytes) ---
		db	 0Fh, 06h, 00h, 09h	; +00
		db	 02h, 07h, 00h, 08h	; +04
		db	 01h, 06h, 01h, 07h	; +08
		db	 00h, 0Ch, 00h, 0Dh	; +0C
		db	 00h, 0Eh, 00h, 0Fh	; +10
		db	 01h, 03h, 01h, 04h	; +14
		db	 01h, 02h, 03h, 09h	; +18
;--- head sub-block 9 (file 0x6BF, 28 bytes) ---
		db	 03h, 0Ah, 0Eh, 01h	; +00
		db	 03h, 0Ch, 02h, 02h	; +04
		db	 0Fh, 07h, 00h, 09h	; +08
		db	 00h, 07h, 00h, 08h	; +0C
		db	 00h, 0Ah, 00h, 0Bh	; +10
		db	 00h, 0Ch, 01h, 08h	; +14
		db	 01h, 09h, 00h, 0Fh	; +18
;--- head sub-block 10 (file 0x6DB, 28 bytes) ---
		db	 01h, 00h, 01h, 04h	; +00
		db	 01h, 02h, 00h, 00h	; +04
		db	 00h, 01h, 05h, 06h	; +08
		db	 03h, 0Dh, 03h, 0Eh	; +0C
		db	 0Fh, 08h, 00h, 06h	; +10
		db	 00h, 07h, 00h, 08h	; +14
		db	 00h, 0Ah, 00h, 0Bh	; +18
;--- head sub-block 11 (file 0x6F7, 28 bytes) ---
		db	 00h, 0Ch, 00h, 0Dh	; +00
		db	 00h, 0Eh, 00h, 0Fh	; +04
		db	 01h, 00h, 01h, 01h	; +08
		db	 01h, 02h, 01h, 0Eh	; +0C
		db	 03h, 0Fh, 02h, 00h	; +10
		db	 04h, 00h, 04h, 01h	; +14
		db	 0Fh, 09h, 00h, 06h	; +18
;--- head sub-block 12 (file 0x713, 28 bytes) ---
		db	 01h, 05h, 00h, 08h	; +00
		db	 01h, 06h, 01h, 07h	; +04
		db	 00h, 0Ch, 01h, 08h	; +08
		db	 01h, 09h, 00h, 0Fh	; +0C
		db	 01h, 03h, 01h, 01h	; +10
		db	 01h, 02h, 02h, 03h	; +14
		db	 04h, 02h, 04h, 03h	; +18
;--- head sub-block 13 (file 0x72F, 28 bytes) ---
		db	 02h, 06h, 0Fh, 0Ah	; +00
		db	 00h, 09h, 02h, 07h	; +04
		db	 00h, 08h, 01h, 06h	; +08
		db	 01h, 07h, 00h, 0Ch	; +0C
		db	 00h, 0Dh, 00h, 0Eh	; +10
		db	 00h, 0Fh, 01h, 03h	; +14
		db	 01h, 04h, 01h, 02h	; +18
;--- head sub-block 14 (file 0x74B, 28 bytes) ---
		db	 04h, 04h, 04h, 05h	; +00
		db	 02h, 06h, 0Fh, 0Bh	; +04
		db	 00h, 09h, 02h, 0Ch	; +08
		db	 00h, 08h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_00:				; 0x767..0x786 (32 bytes; ptr_tbl[0] -> 0xA767)
		db	 01h, 04h, 01h, 02h	; +00
		db	 02h, 0Eh, 04h, 06h	; +04
		db	 02h, 06h, 0Fh, 0Ch	; +08
		db	 00h, 06h, 02h, 0Ch	; +0C
		db	 00h, 08h, 01h, 0Ch	; +10
		db	 01h, 0Dh, 00h, 0Ch	; +14
		db	 01h, 0Ah, 01h, 0Bh	; +18
		db	 00h, 0Fh, 01h, 00h	; +1C

tako_row_data_blk_01:				; 0x787..0x7AA (36 bytes; ptr_tbl[1] -> 0xA787)
		db	 01h, 01h, 01h, 02h	; +00
		db	 03h, 01h, 04h, 07h	; +04
		db	 03h, 03h, 04h, 08h	; +08
		db	 02h, 06h, 0Fh, 0Dh	; +0C
		db	 00h, 06h, 02h, 07h	; +10
		db	 00h, 08h, 01h, 06h	; +14
		db	 01h, 07h, 00h, 0Ch	; +18
		db	 01h, 08h, 01h, 09h	; +1C
		db	 00h, 0Fh, 01h, 03h	; +20

tako_row_data_blk_02:				; 0x7AB..0x7CC (34 bytes; ptr_tbl[2] -> 0xA7AB)
		db	 01h, 01h, 01h, 02h	; +00
		db	 03h, 05h, 03h, 07h	; +04
		db	 04h, 09h, 02h, 06h	; +08
		db	 0Fh, 0Eh, 00h, 09h	; +0C
		db	 02h, 07h, 00h, 08h	; +10
		db	 01h, 06h, 01h, 07h	; +14
		db	 00h, 0Ch, 00h, 0Dh	; +18
		db	 00h, 0Eh, 00h, 0Fh	; +1C
		db	 01h, 03h		; +20  (2-byte tail)

tako_row_data_blk_03:				; 0x7CD..0x7EE (34 bytes; ptr_tbl[3] -> 0xA7CD)
		db	 01h, 04h, 01h, 02h	; +00
		db	 03h, 09h, 0Eh, 01h	; +04
		db	 04h, 0Ah, 04h, 0Bh	; +08
		db	 0Fh, 0Fh, 00h, 09h	; +0C
		db	 00h, 07h, 00h, 08h	; +10
		db	 00h, 0Ah, 00h, 0Bh	; +14
		db	 00h, 0Ch, 01h, 08h	; +18
		db	 01h, 09h, 00h, 0Fh	; +1C
		db	 01h, 00h		; +20  (2-byte tail)

tako_row_data_blk_04:				; 0x7EF..0x80A (28 bytes; ptr_tbl[4] -> 0xA7EF)
		db	 01h, 04h, 01h, 02h	; +00
		db	 04h, 0Ch, 0Eh, 00h	; +04
		db	 00h, 06h, 00h, 07h	; +08
		db	 00h, 08h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_05:				; 0x80B..0x826 (28 bytes; ptr_tbl[5] -> 0xA80B)
		db	 01h, 01h, 01h, 02h	; +00
		db	 04h, 0Bh, 0Eh, 00h	; +04
		db	 00h, 06h, 01h, 05h	; +08
		db	 00h, 08h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_06:				; 0x827..0x842 (28 bytes; ptr_tbl[6] -> 0xA827)
		db	 01h, 01h, 01h, 02h	; +00
		db	 04h, 0Dh, 0Eh, 00h	; +04
		db	 00h, 09h, 02h, 07h	; +08
		db	 00h, 08h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_07:				; 0x843..0x85E (28 bytes; ptr_tbl[7] -> 0xA843)
		db	 01h, 04h, 01h, 02h	; +00
		db	 04h, 0Dh, 0Eh, 00h	; +04
		db	 00h, 09h, 02h, 0Ch	; +08
		db	 00h, 08h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_08:				; 0x85F..0x87A (28 bytes; ptr_tbl[8] -> 0xA85F)
		db	 01h, 04h, 01h, 02h	; +00
		db	 04h, 0Dh, 0Eh, 00h	; +04
		db	 00h, 06h, 02h, 0Ch	; +08
		db	 00h, 08h, 01h, 0Ch	; +0C
		db	 01h, 0Dh, 00h, 0Ch	; +10
		db	 01h, 0Ah, 01h, 0Bh	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_09:				; 0x87B..0x896 (28 bytes; ptr_tbl[9] -> 0xA87B)
		db	 01h, 01h, 01h, 02h	; +00
		db	 04h, 0Dh, 0Eh, 00h	; +04
		db	 00h, 06h, 02h, 07h	; +08
		db	 00h, 08h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_10:				; 0x897..0x8B2 (28 bytes; ptr_tbl[10] -> 0xA897)
		db	 01h, 01h, 01h, 02h	; +00
		db	 04h, 0Dh, 0Eh, 00h	; +04
		db	 00h, 09h, 02h, 07h	; +08
		db	 00h, 08h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_11:				; 0x8B3..0x8CE (28 bytes; ptr_tbl[11] -> 0xA8B3)
		db	 01h, 04h, 01h, 02h	; +00
		db	 04h, 0Bh, 0Eh, 00h	; +04
		db	 00h, 09h, 00h, 07h	; +08
		db	 00h, 08h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_12:				; 0x8CF..0x8EA (28 bytes; ptr_tbl[12] -> 0xA8CF)
		db	 01h, 04h, 01h, 02h	; +00
		db	 04h, 0Eh, 03h, 0Bh	; +04
		db	 00h, 06h, 04h, 0Fh	; +08
		db	 05h, 00h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_13:				; 0x8EB..0x906 (28 bytes; ptr_tbl[13] -> 0xA8EB)
		db	 01h, 01h, 01h, 02h	; +00
		db	 05h, 01h, 03h, 0Bh	; +04
		db	 00h, 06h, 05h, 02h	; +08
		db	 05h, 00h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_14:				; 0x907..0x922 (28 bytes; ptr_tbl[14] -> 0xA907)
		db	 01h, 01h, 01h, 02h	; +00
		db	 05h, 03h, 03h, 0Bh	; +04
		db	 00h, 09h, 05h, 04h	; +08
		db	 05h, 00h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_15:				; 0x923..0x93E (28 bytes; ptr_tbl[15] -> 0xA923)
		db	 01h, 04h, 01h, 02h	; +00
		db	 05h, 03h, 03h, 0Bh	; +04
		db	 00h, 09h, 05h, 05h	; +08
		db	 05h, 00h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_16:				; 0x93F..0x95A (28 bytes; ptr_tbl[16] -> 0xA93F)
		db	 01h, 04h, 01h, 02h	; +00
		db	 05h, 03h, 03h, 0Bh	; +04
		db	 00h, 06h, 05h, 05h	; +08
		db	 05h, 00h, 01h, 0Ch	; +0C
		db	 01h, 0Dh, 00h, 0Ch	; +10
		db	 01h, 0Ah, 01h, 0Bh	; +14
		db	 00h, 0Fh, 01h, 00h	; +18

tako_row_data_blk_17:				; 0x95B..0x976 (28 bytes; ptr_tbl[17] -> 0xA95B)
		db	 01h, 01h, 01h, 02h	; +00
		db	 05h, 03h, 03h, 0Bh	; +04
		db	 00h, 06h, 05h, 04h	; +08
		db	 05h, 00h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_18:				; 0x977..0x992 (28 bytes; ptr_tbl[18] -> 0xA977)
		db	 01h, 01h, 01h, 02h	; +00
		db	 05h, 03h, 03h, 0Bh	; +04
		db	 00h, 09h, 05h, 04h	; +08
		db	 05h, 00h, 01h, 06h	; +0C
		db	 01h, 07h, 00h, 0Ch	; +10
		db	 00h, 0Dh, 00h, 0Eh	; +14
		db	 00h, 0Fh, 01h, 03h	; +18

tako_row_data_blk_19:				; 0x993..0x9B2 (32 bytes; ptr_tbl[19] -> 0xA993)
		db	 01h, 04h, 01h, 02h	; +00
		db	 05h, 01h, 03h, 0Bh	; +04
		db	 00h, 09h, 04h, 0Fh	; +08
		db	 05h, 00h, 00h, 0Ah	; +0C
		db	 00h, 0Bh, 00h, 0Ch	; +10
		db	 01h, 08h, 01h, 09h	; +14
		db	 00h, 0Fh, 01h, 00h	; +18
		db	 01h, 04h, 01h, 02h	; +1C

; -------------------------------------------------------------------------
;  tako_pattern_ptr_tbl + tako_sprite_patterns (file 0x9B3..0xA1F).
;  Dual-use byte block: the first 64 bytes form a word-pointer table
;  (32 entries) consumed by emit_setup; the SAME bytes from 0x9EF onward
;  also form 7-byte sprite-row patterns indexed via the table.  Pattern 0
;  starts at the 30th ptr-tbl entry (whose value 0xAA19 self-references
;  pattern 6's start), so the first two bytes of pattern 0 (`19h, 0AAh`)
;  are byte-shared with that entry.  Reproduced as the raw byte stream
;  to preserve the dual-use layout.
;
;  Pointer-table view (32 entries):
;    0xA9EF, 0xA9F6, 0xA9FD, 0xA9F6, 0xA9F6, 0xA9F6, 0xA9F6, 0xA9F6,
;    0xAA04, 0xA9F6, 0xA9FD, 0xAA0B, 0xAA0B, 0xA9F6, 0xAA12, 0xAA12,
;    0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19,
;    0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19, 0xAA19
;
;  Sprite-pattern view (7 patterns x 7 bytes, file 0x9EF..0xA1F):
;    pat 0 @ 0x9EF: 19 AA 19 AA 19 AA 19    (also serves as ptr-tbl tail)
;    pat 1 @ 0x9F6: AA 19 AA 19 AA E0 60    (overlaps tbl entries 28-31)
;    pat 2 @ 0x9FD: 60 E0 E0 E0 E0 60 60    (sprite-row payload)
;    pat 3 @ 0xA04: 60 E0 E0 E0 E0 60 20    (sprite-row payload)
;    pat 4 @ 0xA0B: 60 E0 E0 E0 E0 C0 60    (sprite-row payload)
;    pat 5 @ 0xA12: 60 E0 E0 E0 E0 20 20    (sprite-row payload)
;    pat 6 @ 0xA19: 60 E0 E0 E0 E0 40 60    (sprite-row payload)
; -------------------------------------------------------------------------

tako_pattern_ptr_tbl	label	word
		db	 0EFh,0A9h, 0F6h,0A9h, 0FDh,0A9h	; entries 0-2: -> 0xA9EF, 0xA9F6, 0xA9FD
		db	 0F6h,0A9h, 0F6h,0A9h, 0F6h,0A9h	; entries 3-5: -> 0xA9F6 x3
		db	 0F6h,0A9h, 0F6h,0A9h,  04h,0AAh	; entries 6-8: -> 0xA9F6, 0xA9F6, 0xAA04
		db	 0F6h,0A9h, 0FDh,0A9h,  0Bh,0AAh	; entries 9-11: -> 0xA9F6, 0xA9FD, 0xAA0B
		db	  0Bh,0AAh, 0F6h,0A9h,  12h,0AAh	; entries 12-14
		db	  12h,0AAh,  19h,0AAh,  19h,0AAh	; entries 15-17
		db	  19h,0AAh,  19h,0AAh,  19h,0AAh	; entries 18-20: 0xAA19 x3
		db	  19h,0AAh,  19h,0AAh,  19h,0AAh	; entries 21-23: 0xAA19 x3
		db	  19h,0AAh,  19h,0AAh,  19h,0AAh	; entries 24-26: 0xAA19 x3
		db	  19h,0AAh,  19h,0AAh,  19h,0AAh	; entries 27-29: 0xAA19 x3 (last 30 entries)

; tako_sprite_patterns (file 0x9EF..0xA1F): 49 bytes = 7 patterns x 7 bytes.
; Pattern 0 starts at file offset 0x9EF, sharing its first 4 bytes with
; the last 2 entries of tako_pattern_ptr_tbl above (0xAA19 self-pointer
; pattern -- the bytes `19 AA 19 AA` form both ptr-tbl tail and pat 0 head).

tako_sprite_patterns	label	word
		db	  19h,0AAh,  19h,0AAh,0E0h, 60h, 60h	; pat 0 @ 0x9EF: 19 aa 19 aa e0 60 60
		db	 0E0h,0E0h,0E0h,0E0h, 60h, 60h, 60h	; pat 1 @ 0x9F6: e0 e0 e0 e0 60 60 60
		db	 0E0h,0E0h,0E0h,0E0h, 60h, 20h, 60h	; pat 2 @ 0x9FD: e0 e0 e0 e0 60 20 60
		db	 0E0h,0E0h,0E0h,0E0h,0C0h, 60h, 60h	; pat 3 @ 0xA04: e0 e0 e0 e0 c0 60 60
		db	 0E0h,0E0h,0E0h,0E0h, 20h, 20h, 60h	; pat 4 @ 0xA0B: e0 e0 e0 e0 20 20 60
		db	 0E0h,0E0h,0E0h,0E0h, 40h, 60h, 60h	; pat 5 @ 0xA12: e0 e0 e0 e0 40 60 60
		db	 0E0h,0E0h,0E0h,0E0h, 00h, 00h, 60h	; pat 6 @ 0xA19: e0 e0 e0 e0 00 00 60

; -------------------------------------------------------------------------
;  tako_proj_pattern (file 0xA20..0xA26) -- 7-byte projectile pattern at
;  runtime address 0xAA20.  Loaded by emit_proj_phase via `add ax,0AA20h`
;  for the tentacle-tip projectile slot.
; -------------------------------------------------------------------------

tako_proj_pattern:				; runtime addr 0xAA20
		db	 0E0h,0E0h,0E0h,0E0h, 00h, 00h, 00h	; 7-byte projectile sprite row

; -------------------------------------------------------------------------
;  tako_row_template (file 0xA27..0xA83, 0x5D bytes = 93 bytes).
;  Per-row (0,N) byte pairs that render a vertical sequence of single-tile
;  columns; the (N) byte is a tile alpha index (00 -> background fill,
;  01..05 -> foreground tile, etc.).  Used by 200FIGHT's pre-init to seed
;  the per-slot row state buffer at tako_row_pos_base - 0x60.
; -------------------------------------------------------------------------

tako_row_template:				; 0xA27..0xA83 (93 bytes)
		db	  00h, 01h			; 0xA27..0xA28
		db	  00h, 00h, 00h, 02h, 00h, 00h	; 0xA29..0xA2E (header rows)
		db	  00h, 02h, 00h, 03h		; 0xA2F..0xA32
		db	16 dup (0, 2, 0, 3)		; 0xA33..0xA72 (64 bytes: 16 x 00 02 00 03)
		db	  00h, 04h, 00h, 03h, 00h, 00h	; 0xA73..0xA78
		db	  04h, 03h, 00h, 00h, 00h, 05h	; 0xA79..0xA7E
		db	  00h, 00h, 00h, 00h, 06h	; 0xA7F..0xA83

; -------------------------------------------------------------------------
;  Tail bytes (file 0xA84..0xA94) -- 17 bytes of timing/position
;  constants (0x24, 0x10, 0xFA, 0xC8, 0xFF...) followed by pointer
;  0xAA8D (= tako_row_pos_base + 0x0D, i.e. tako_alt_state - 1) and
;  small literals, consumed by 200FIGHT init.  Final byte (0x05) is
;  the Pascal-string length prefix for the 'Pulpo' name tag below.
; -------------------------------------------------------------------------

tako_tail_const:
		db	  24h, 00h, 10h,0FAh, 00h,0C8h	; 6 bytes
		db	  00h, 07h,0FFh, 8Dh,0AAh,0C8h	; 6 bytes; 8DAAh = ptr
		db	  00h, 12h,0BBh, 00h, 5		; 4 bytes + name-tag length 5

; -------------------------------------------------------------------------
;  'Pulpo' name tag (file 0xA95) -- 5-char Pascal string with
;  length-prefix byte 5 (last byte of tail_const above).  Plus 12 zero
;  bytes of trailing padding to file size 2726.
; -------------------------------------------------------------------------

tako_name_tag:
		db	 'Pulpo'		; 5 chars (length prefix is last byte of tail_const above)
		db	12 dup (0)		; pad to end-of-file

seg_a		ends

		end	start
