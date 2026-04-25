
PAGE  59,132

;==========================================================================
;
;  303EAI3.BIN - Enemy AI Handler: TORI (zelres3 chunk 4)
;
;  Per-enemy AI controller for the TORI (bird) enemy, loaded alongside
;  311TORI.BIN sprites. Manages flight path, swoop attack, and collision
;  for the flying bird enemy. The TORI uses a more elaborate set of
;  animation substates (0..7) than ground enemies because it transitions
;  between hover / dive / retreat behaviours.
;
;  Dispatch model matches the EAI* family (see 301EAI1.asm for full
;  description of the enemy slot record at DS:SI).
;
;  Resource table constants (DS offsets in game_seg):
;    6004h..603Ah = TORI movement/collision/attack dispatch table slots.
;    0A4EAh..0A662h = TORI flight-pattern / attack-decision lookup tables.
;    0FF35h = shared gvar_frame_cnt.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- TORI enemy AI dispatch table (game_seg:6004h..603Ah, in DS at runtime) ---
ai_fn_tbl_a	equ	6004h			; AI fn (dive / swoop)
ai_fn_tbl_b	equ	6008h			; AI fn
ai_fn_tbl_c	equ	600Ah			; AI fn
ai_fn_tbl_d	equ	600Ch			; AI fn
ai_fn_tbl_e	equ	600Eh			; AI fn
ai_fn_tbl_f	equ	6010h			; AI fn
ai_fn_tbl_g	equ	6012h			; AI fn
ai_fn_tbl_h	equ	6014h			; AI fn
ai_fn_tbl_i	equ	6016h			; AI fn
ai_fn_tbl_j	equ	601Ch			; AI fn
ai_fn_tbl_k	equ	6028h			; AI fn
ai_fn_tbl_l	equ	602Ah			; AI fn
ai_fn_tbl_m	equ	602Eh			; AI fn
ai_hide_fn	equ	6034h			; AI fn: hide / despawn
ai_attack_fn	equ	603Ah			; AI fn: attack / release projectile

; --- TORI lookup tables (game_seg DS) ---
tori_tbl_a	equ	0A4EAh			; TORI flight-pattern base table
tori_tbl_b	equ	0A519h
tori_tbl_c	equ	0A5A3h
tori_tbl_d	equ	0A654h
tori_tbl_e	equ	0A655h
tori_tbl_f	equ	0A661h
tori_tbl_g	equ	0A662h
gvar_frame_cnt	equ	0FF35h			; frame counter byte

; Backwards-compat aliases

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

tori_ai_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer mis-decoded the leading bytes as code (`aaa / pop es /
;  add [bx+si],al / mov dl, 0A2h`).  The bytes are actually a 4-byte
;  length header, an init src/dst pointer pair, and a small per-slot
;  template buffer (matches 309CRAB / 310TAKO module-header pattern).
;
;  Following the header (offsets 0x034..0x09F) are 5 animation frame
;  pointer tables (groups A..E) -- word ptrs into the frame data area.
; -------------------------------------------------------------------------

start:

file_header:
		aaa				; byte 0x37: file length word lo
		pop	es			; byte 0x07: file length word hi -> length = 0x0737
		add	[bx+si],al		; bytes 00 00: pad
		mov	dl,0A2h			; bytes B2 A2: init pointer hi (Sourcer mis-decode)
		db	 00h, 00h, 00h, 00h, 9Ah,0A2h	; init src/dst ptr table
		db	 14h, 0Ah, 0Ah, 14h, 00h, 00h	; per-slot template A
		db	 00h, 00h, 28h, 28h, 10h, 28h	; per-slot template B
		db	 00h
		db	27 dup (0)			; reserved / padding (offsets 0x019-0x033)

tori_frame_ptr_tbl_a	label	word		; offset 0x034 -- group A pointers
		db	0B0h,0A0h, 55h,0A1h,0A5h,0A1h	; -> 0xA0B0, 0xA155, 0xA1A5
		db	0D7h,0A1h, 00h, 00h, 00h, 00h	; -> 0xA1D7, slot4=empty, slot5=empty
		db	 00h, 00h, 00h, 00h, 28h,0A1h	; slots 6,7 empty, -> 0xA128
		db	 73h,0A1h,0C8h,0A1h, 13h,0A2h	; -> 0xA173, 0xA1C8, 0xA213
		db	8 dup (0)			; reserved

tori_frame_ptr_tbl_b	label	word		; offset 0x054 -- group B pointers
		db	 72h,0A2h, 72h,0A2h, 22h,0A2h	; -> 0xA272, 0xA272 (dup), 0xA222
		db	 59h,0A2h, 31h,0A2h, 45h,0A2h	; -> 0xA259, 0xA231, 0xA245
		db	 6Dh,0A2h, 00h, 00h, 8Bh,0A2h	; -> 0xA26D, slot empty, 0xA28B
		db	 90h,0A2h, 00h, 00h, 00h, 00h	; -> 0xA290, slots empty
		db	 86h,0A2h, 95h,0A2h, 00h, 00h	; -> 0xA286, 0xA295

tori_frame_ptr_tbl_c	label	word		; offset 0x070 -- group C pointers
		db	 00h, 00h,0ECh,0A0h, 37h,0A1h	; pad, -> 0xA0EC, 0xA137
		db	 82h,0A1h,0F5h,0A1h, 00h	; -> 0xA182, 0xA1F5, slot empty
		db	7 dup (0)			; reserved

tori_frame_ptr_tbl_d	label	word		; offset 0x084 -- group D pointers (mirrors A tail)
		db	 28h,0A1h, 73h,0A1h,0C8h,0A1h	; -> 0xA128, 0xA173, 0xA1C8
		db	 13h,0A2h			; -> 0xA213
		db	8 dup (0)			; reserved

tori_frame_ptr_tbl_e	label	word		; offset 0x094 -- group E pointers (mirrors B)
		db	 72h,0A2h, 72h,0A2h, 22h,0A2h	; -> 0xA272, 0xA272, 0xA222
		db	 59h,0A2h, 31h,0A2h, 45h,0A2h	; -> 0xA259, 0xA231, 0xA245
		db	 6Dh,0A2h, 00h, 00h, 8Bh,0A2h	; -> 0xA26D, slot empty, 0xA28B
		db	 90h,0A2h, 00h, 00h, 00h, 00h	; -> 0xA290, slots empty
		db	 86h,0A2h, 95h,0A2h, 00h, 00h	; -> 0xA286, 0xA295
		db	 00h, 00h, 00h, 01h, 02h, 03h
		db	 04h, 00h, 05h, 06h, 07h, 08h
		db	 00h, 09h, 0Ah, 0Bh, 0Ch, 00h
		db	 0Dh, 0Eh, 0Fh, 10h, 00h, 11h
		db	 12h, 13h, 14h, 00h, 15h, 16h
		db	 17h, 18h, 00h, 19h, 1Ah, 1Bh
		db	 1Ch, 00h, 1Dh, 1Eh, 0Fh, 10h
		db	 00h, 21h, 22h, 00h, 00h, 00h
		db	 00h, 00h, 21h, 22h, 00h, 00h
		db	 00h, 23h, 24h, 00h, 25h, 26h
		db	 27h, 28h, 00h, 1Dh, 1Eh, 0Fh
		db	 10h, 00h,0BFh, 1Ah,0C0h, 1Ch
		db	 00h, 15h, 16h,0C1h,0C2h, 00h
		db	 11h, 12h, 13h, 14h, 00h, 0Dh
		db	 0Eh, 0Fh, 10h, 00h,0C3h, 0Ah
		db	0C4h, 1Ch, 00h, 05h, 06h, 20h
		db	 1Fh, 00h, 01h, 02h, 03h, 04h
		db	 00h, 21h, 22h, 00h, 00h, 00h
		db	 00h, 00h, 21h, 22h, 00h, 00h
		db	 00h, 23h, 24h, 00h, 25h, 26h
		db	 27h, 28h, 00h, 29h, 2Ah, 2Bh
		db	 2Ch, 00h, 2Dh, 2Eh, 2Fh, 30h
		db	 00h, 31h, 32h, 33h, 34h, 00h
		db	 00h, 00h, 35h, 36h, 00h, 37h
		db	 38h, 39h, 3Ah, 00h, 3Bh, 3Ch
		db	 3Dh, 3Eh, 00h, 3Fh, 40h, 41h
		db	 42h, 00h, 43h, 44h, 45h, 46h
		db	 00h, 43h, 44h, 45h, 46h, 00h
		db	 00h, 00h, 47h, 48h, 00h
		db	 49h, 4Ah
		db	'KL', 0
		db	'MNOP', 0
		db	'QRST', 0
		db	'UVWX', 0
		db	'UVWX', 0
		db	'YZ[\', 0
		db	']^_`', 0
		db	'abcd'
		db	 00h, 00h, 00h, 65h, 66h, 00h
		db	 00h, 00h, 67h, 68h, 00h, 00h
		db	 00h, 69h, 6Ah, 00h, 00h, 00h
		db	 6Bh, 6Ch, 00h, 6Dh, 6Eh, 6Fh
		db	 70h, 00h, 76h, 77h, 73h, 74h
		db	 00h, 76h, 78h, 73h, 74h, 00h
		db	 00h, 00h, 65h, 66h, 00h, 00h
		db	 00h, 67h, 68h, 00h, 00h, 00h
		db	 69h, 6Ah, 00h, 00h, 00h, 6Bh
		db	 6Ch, 00h, 6Dh, 6Eh, 6Fh, 70h
		db	 00h, 71h, 72h, 73h, 74h, 00h
		db	 75h, 72h, 73h, 74h, 00h, 7Bh
		db	 7Ch, 7Dh, 7Eh, 00h, 7Fh, 80h
		db	 81h, 82h, 00h, 83h, 84h, 85h
		db	 86h, 01h, 87h, 88h, 89h, 8Ah
		db	 01h, 8Bh, 8Ch, 8Dh, 8Eh, 01h
		db	 8Fh, 90h, 91h, 92h, 01h, 93h
		db	 94h, 95h, 96h, 01h, 97h, 98h
		db	 99h, 9Ah, 01h, 9Bh, 9Ch, 9Dh
		db	 9Eh, 01h, 87h, 88h, 89h, 8Ah
		db	 01h, 9Fh,0A0h,0A1h,0A2h, 01h
		db	0A3h,0A4h,0A5h,0A6h, 01h,0A7h
		db	0A8h,0A9h,0AAh, 01h,0ABh,0ACh
		db	0ADh,0AEh, 01h,0AFh,0B0h,0B1h
		db	0B2h, 01h,0B3h,0B4h,0B5h,0B6h
		db	 01h,0B7h,0B8h,0B9h,0BAh, 01h
		db	0BBh,0BCh,0BDh,0BEh, 01h,0EFh
		db	0F0h,0F1h,0F2h, 01h,0F3h,0C5h
		db	0C6h,0C7h, 01h,0C8h,0C9h,0CAh
		db	0CBh, 00h,0CCh,0CDh,0CEh,0CFh
		db	 00h,0D0h,0D1h,0D2h,0D3h, 00h
		db	0D4h,0D5h,0D6h,0D7h, 00h,0D0h
		db	0D1h,0D2h,0D3h, 02h,0CCh,0CDh
		db	0CEh,0CFh, 02h,0D0h,0D1h,0D2h
		db	0D3h, 02h,0D4h,0D5h,0D6h,0D7h
		db	 02h,0D0h,0D1h,0D2h,0D3h, 00h
		db	0D8h,0D9h,0DAh,0DBh, 00h,0D8h
		db	0D9h,0DAh,0DBh, 00h,0D8h,0D9h
		db	0DAh,0DBh, 00h,0D8h,0D9h,0DAh
		db	0DBh, 01h,0DCh,0DDh,0DEh,0DFh
		db	 01h,0E4h,0ECh,0E4h,0ECh, 01h
		db	0E5h,0ECh,0E6h,0ECh, 01h,0E7h
		db	0E8h,0E9h,0EAh, 01h, 00h, 00h
		db	 00h,0EBh, 02h,0E0h,0E1h,0E2h
		db	0E3h, 00h,0EDh,0EEh, 79h, 7Ah
		db	 02h,0EDh,0EEh, 79h, 7Ah, 01h
		db	0F4h,0F5h,0F6h,0F7h			; -- end of frame data (offsets 0x29C..0x29F)

; -------------------------------------------------------------------------
;  Aux ptr table (offset 0x29C) + 4-byte aux records (offset 0x2A4).
;  Same overlap pattern as 302EAI2 / 301EAI1 -- 4 ptr entries followed by
;  4 4-byte records.
; -------------------------------------------------------------------------

tori_aux_ptr_tbl	label	word		; offset 0x29C -- aux ptr table (4 entries)
		db	0A2h,0A2h			; -> 0xA2A2 (overlaps into aux records below)
		db	0A6h,0A2h			; -> 0xA2A6
		db	0AAh,0A2h			; -> 0xA2AA
		db	0AEh,0A2h			; -> 0xA2AE

tori_aux_records:				; offset 0x2A4 -- 4-byte aux records
		db	 04h, 04h, 00h, 00h	; record 0
		db	 05h, 05h, 00h, 00h	; record 1
		db	 04h, 04h, 04h, 04h	; record 2
		db	 05h, 05h, 05h, 05h	; record 3

; -------------------------------------------------------------------------
;  Trailing AI primary dispatch (offset 0x2B4) -- runs straight into the
;  state-byte dispatch.  Mirrors 302EAI2's `tako_ai_dispatch_pre` pattern:
;  the JMP indexes a table whose first 4 bytes overlap with the JMP
;  encoding itself, making the first 2 entries unreachable placeholders.
; -------------------------------------------------------------------------

tori_ai_dispatch_pre:				; offset 0x2B4 -- entry from primary dispatch
		mov	bl,[si+4]		; bytes 8A 5C 04
		and	bl,0Fh			; bytes 80 E3 0F  (mask state nibble)
		xor	bh,bh			; bytes 32 FF
		add	bx,bx			; bytes 03 DB     (scale to word index)
		jmp	word ptr ds:[bx+0A2C0h]	; bytes FF A7 C0 A2 -- table at 0xA2C0

; AI primary dispatch table (4 valid handlers; first 2 entries overlap the
; JMP bytes so they're unreachable).  Indexed by [si+4]&0x0F.

; AI primary dispatch table: idx 0,1 overlap with the JMP encoding above
; (FF A7 C0 A2 = JMP word ptr ds:[bx+0A2C0h]); only idx 2..5 are valid.
;
; tori_ai_dispatch_tbl  (conceptual layout at offset 0xA2C0)
;   idx 0,1 -> JMP encoding bytes (unreachable)
;   idx 2 -> tori_state2_entry (0xA2C8)
;   idx 3 -> tori_state3_entry (0xA44D)
;   idx 4 -> tori_state4_entry (0xA4F0)
;   idx 5 -> tori_state5_entry (0xA66E)

tori_ai_dispatch_tbl:				; offset 0x2C0 -- 4 valid entries (idx 2..5)
		db	 0C8h,0A2h		; idx 2 -> tori_state2_entry (0xA2C8)
		db	 4Dh,0A4h		; idx 3 -> tori_state3_entry (0xA44D)

; State-2 entry tail (offset 0x2C8).  Bytes at 0xA2C8 = `F0 A4 6E A6` are
; dispatch-table tail (idx 4,5) which decode as `lock movsb / outsb /
; cmpsb` -- harmless filler before the AI-entry preroll begins at 0xA2CC.

tori_state2_entry:				; offset 0x2C8 -- state 2 (idx 2 in primary)
		db	 0F0h,0A4h		; idx 4 -> tori_state4_entry (0xA4F0) (also: lock/movsb)
		db	 6Eh,0A6h		; idx 5 -> tori_state5_entry (0xA66E) (also: outsb/cmpsb)

tori_state2_preroll:				; offset 0x2CC
		test	byte ptr [si+8],0FFh	; bytes F6 44 08 FF
		jnz	tori_s2_pre_done		; bytes 75 04
		mov	byte ptr [si+8],2	; bytes C6 44 08 02 (cooldown=2)

tori_s2_pre_done:
		test	byte ptr [si+5],20h	; bytes F6 44 05 20
		jz	tori_s2_substate_dispatch	; bytes 74 05
		jmp	word ptr cs:ai_hide_fn	; bytes 2E FF 26 34 60

tori_s2_substate_dispatch:
		mov	bl,[si+9]		; bytes 8A 5C 09
		and	bx,7			; bytes 83 E3 07 (sign-ext 16-bit AND)
		add	bx,bx			; bytes 03 DB
		jmp	word ptr ds:[bx+0A2E9h]	; bytes FF A7 E9 A2 -- table at 0xA2E9

; State-2 substate dispatch table: idx 0,1 overlap with JMP encoding above
; (FF A7 E9 A2 = JMP word ptr ds:[bx+0A2E9h]); only idx 2..7 are valid.

tori_s2_substate_tbl:				; offset 0x2E9 -- 6 valid entries (idx 2..7)
		db	 0F9h,0A2h		; idx 2 -> tori_substate_2 (0xA2F9)
		db	 56h,0A3h		; idx 3 -> tori_substate_3 (0xA356)
		db	 67h,0A3h		; idx 4 -> tori_substate_4 (0xA367)
		db	 74h,0A3h		; idx 5 -> tori_substate_5 (0xA374)
		db	 0ACh,0A3h		; idx 6 -> tori_substate_6 (0xA3AC)
		db	 0E0h,0A3h		; idx 7 -> tori_substate_7 (0xA3E0)

; tori_substate_2 (idx 2 in state-2 substate table).  First 4 bytes are
; extended dispatch table entries (idx 8,9 unused due to &7 mask) which
; decode as harmless `add ax,0xA40E / movsb` filler before real code.

tori_substate_2:				; offset 0x2F9 -- substate 2 (range/phase check)
		db	 05h,0A4h, 0Eh,0A4h	; overlap (extended dispatch idx 8,9 -- unreachable)

tori_sub2_real:					; offset 0x2FD -- substate-2 main body
		inc	byte ptr [si+6]		; bytes FE 44 06
		and	byte ptr [si+6],7	; bytes 80 64 06 07
		call	word ptr cs:ai_fn_tbl_j	; bytes 2E FF 16 1C 60 (= cs:[601C])
		jnc	tori_sub2_set_state1	; bytes 73 46 (jnc +0x46 -> 0x351)
		test	byte ptr [si+6],1	; bytes F6 44 06 01
		jnz	tori_sub2_check_dist	; bytes 75 01
		retn				; byte C3

tori_sub2_check_dist:
		mov	al,[si+3]		; bytes 8A 44 03
		cmp	al,12h			; bytes 3C 12
		jb	tori_sub2_loc		; bytes 72 04 (-> 0x31D)
		cmp	al,15h			; bytes 3C 15
		jb	tori_sub2_set_state1	; bytes 72 34 (-> 0x351)

tori_sub2_loc:
		test	byte ptr [si+5],80h
		jnz	tori_sub2_facing_west			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_f
		jc	tori_sub2_advance_e			; Jump if carry Set
		retn

tori_sub2_advance_e:
		xor	al,al			; Zero register
		xchg	[si+0Ah],al
		xor	byte ptr [si+5],80h
		test	al,1
		jz	tori_sub2_skip_to_state1			; Jump if zero
		retn

tori_sub2_skip_to_state1:
		jmp	short tori_sub2_set_state1

tori_sub2_facing_west:
		call	word ptr cs:ai_fn_tbl_b
		jc	tori_sub2_advance_w			; Jump if carry Set
		retn

tori_sub2_advance_w:
		xor	al,al			; Zero register
		xchg	[si+0Ah],al
		xor	byte ptr [si+5],80h
		test	al,1
		jz	tori_sub2_set_state1			; Jump if zero
		retn

tori_sub2_set_state1:
		mov	byte ptr [si+9],1
		mov	byte ptr [si+6],8
		retn

; tori_substate_3 -- entered via tori_s2_substate_tbl[3] (DS:0xA2EF -> 0xA356); phase advance, then state 2.

tori_substate_3:				; was '* No entry point to code' marker
		call	word ptr cs:ai_fn_tbl_h
		jc	tori_sub3_advance			; Jump if carry Set
		retn

tori_sub3_advance:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],9
		retn

; tori_substate_4 -- entered via tori_s2_substate_tbl[4] (DS:0xA2F1 -> 0xA367); init state 3 with phase 0xA.

tori_substate_4:				; was '* No entry point to code' marker
		mov	byte ptr [si+9],3
		mov	byte ptr [si+6],0Ah
		mov	byte ptr [si+0Ah],0
		retn

; tori_substate_5 -- entered via tori_s2_substate_tbl[5] (DS:0xA2F3 -> 0xA374); counter step with state-4 advance.

tori_substate_5:				; was '* No entry point to code' marker
		cmp	byte ptr [si+0Ah],1
		jne	tori_sub5_set_phase			; Jump if not equal
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0FFh

tori_sub5_set_phase:
		mov	byte ptr [si+6],0Bh
		test	byte ptr [si+5],80h
		jnz	tori_sub5_west_branch			; Jump if not zero
		inc	byte ptr [si+0Ah]
		call	word ptr cs:ai_fn_tbl_e
		jc	tori_sub5_flip_a			; Jump if carry Set
		retn

tori_sub5_flip_a:
		xor	byte ptr [si+5],80h
		retn

tori_sub5_west_branch:
		inc	byte ptr [si+0Ah]
		call	word ptr cs:ai_fn_tbl_c
		jc	tori_sub5_flip_b			; Jump if carry Set
		retn

tori_sub5_flip_b:
		xor	byte ptr [si+5],80h
		retn

; tori_substate_6 -- entered via tori_s2_substate_tbl[6] (DS:0xA2F5 -> 0xA3AC); counter step alt with state-5 advance.

tori_substate_6:				; was '* No entry point to code' marker
		cmp	byte ptr [si+0Ah],1
		jne	tori_sub6_set_phase			; Jump if not equal
		mov	byte ptr [si+9],5

tori_sub6_set_phase:
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	tori_sub6_west_branch			; Jump if not zero
		inc	byte ptr [si+0Ah]
		call	word ptr cs:ai_fn_tbl_f
		jc	tori_sub6_flip_a			; Jump if carry Set
		retn

tori_sub6_flip_a:
		xor	byte ptr [si+5],80h
		retn

tori_sub6_west_branch:
		inc	byte ptr [si+0Ah]
		call	word ptr cs:ai_fn_tbl_b
		jc	tori_sub6_flip_b			; Jump if carry Set
		retn

tori_sub6_flip_b:
		xor	byte ptr [si+5],80h
		retn

; tori_substate_7 -- entered via tori_s2_substate_tbl[7] (DS:0xA2F7 -> 0xA3E0); alt step + state-6 advance.

tori_substate_7:				; was '* No entry point to code' marker
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	tori_sub7_west_branch			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_g
		jc	tori_sub7_advance_state6			; Jump if carry Set
		retn

tori_sub7_advance_state6:
			mov	byte ptr [si+6],9
			mov	byte ptr [si+9],6
			retn

tori_sub7_west_branch:
			call	word ptr cs:ai_fn_tbl_i
			jc	tori_sub7_advance_alt			; Jump if carry Set
			retn

tori_sub7_advance_alt:
			jmp	short tori_sub7_advance_state6

; tori_alt_state_a -- fall-through after `jmp short tori_sub7_advance_state6` -- alt phase setup (phase=0xA, state=7).

tori_alt_state_a:				; was '* No entry point to code' marker
		mov	byte ptr [si+6],0Ah
		mov	byte ptr [si+9],7
		retn

; tori_alt_state_b -- fall-through after retn above -- alt state-7 with attack-callback chain.

tori_alt_state_b:				; was '* No entry point to code' marker
		mov	byte ptr [si+6],8
		test	byte ptr [si+5],80h
		jnz	tori_alt_b_west			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_e
		jc	tori_alt_b_chain_a			; Jump if carry Set
		retn

tori_alt_b_chain_a:
		call	word ptr cs:ai_fn_tbl_j
		jc	tori_alt_b_reset			; Jump if carry Set
		xor	byte ptr [si+5],80h
		retn

tori_alt_b_reset:
			mov	byte ptr [si+9],0
			mov	byte ptr [si+6],0
			mov	byte ptr [si+0Ah],1
			retn

tori_alt_b_west:
			call	word ptr cs:ai_fn_tbl_c
			jc	tori_alt_b_chain_b			; Jump if carry Set
			retn

tori_alt_b_chain_b:
			call	word ptr cs:ai_fn_tbl_d
			jc	tori_alt_b_reset			; Jump if carry Set
		xor	byte ptr [si+5],80h
		retn

; tori_state3_entry -- entered via tori_ai_dispatch_tbl[3] (DS:0xA2C6 -> 0xA44D); state 3 (cooldown=2).

tori_state3_entry:				; was '* No entry point to code' marker
		test	byte ptr [si+8],0FFh
		jnz	tori_s3_pre_done			; Jump if not zero
		mov	byte ptr [si+8],2

tori_s3_pre_done:
		test	byte ptr [si+5],20h	; ' '
		jz	tori_s3_check_state			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

tori_s3_check_state:
		test	byte ptr [si+9],8
		jnz	tori_s3_state8_active			; Jump if not zero
		test	byte ptr [si+9],4
		jnz	tori_s3_step			; Jump if not zero
		or	byte ptr [si+5],80h
		cmp	byte ptr [si+3],11h
		jb	tori_s3_step			; Jump if below
		xor	byte ptr [si+5],80h

tori_s3_step:
		call	word ptr cs:ai_fn_tbl_h
		jc	tori_s3_phase_carry			; Jump if carry Set
		retn

tori_s3_phase_carry:
		and	byte ptr [si+6],0F0h
		add	byte ptr [si+6],80h
		jc	tori_s3_phase_high			; Jump if carry Set
		retn

tori_s3_phase_high:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn

tori_s3_state8_active:
		and	byte ptr [si+9],0FBh
		mov	al,[si+6]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],6
		jb	tori_s3_xlat_step			; Jump if below
		mov	byte ptr [si+6],0
		and	byte ptr [si+9],0F7h

tori_s3_xlat_step:
		mov	bx,0A4E4h
		test	byte ptr [si+5],80h
		jnz	tori_s3_xlat_call			; Jump if not zero
		mov	bx,tori_tbl_a

tori_s3_xlat_call:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:ai_fn_tbl_a
		jc	tori_s3_xlat_ok			; Jump if carry Set
		retn

tori_s3_xlat_ok:
		and	byte ptr [si+9],0F7h
		cmp	byte ptr [si+6],1
		jne	tori_s3_clear_phase			; Jump if not equal
		or	byte ptr [si+9],4
		xor	byte ptr [si+5],80h

tori_s3_clear_phase:
		mov	byte ptr [si+6],0
		jmp	word ptr cs:ai_fn_tbl_h

; tori_state4_entry -- entered via tori_ai_dispatch_tbl[4] (DS:0xA2C8 -> 0xA4F0).
; Sourcer mis-decoded the leading bytes as `add [bx+di],ax / add [bx+si],al
; / pop es / pop es / ...`.  These bytes are actually overlap from the
; previous code block's tail; they execute as harmless filler before the
; real AI-entry preroll begins (`test [si+8], 0xFF / mov [si+8], 4`).

tori_state4_entry:				; offset 0x4F0 -- state 4 (idx 4 in primary)
		add	[bx+di],ax		; bytes 01 01 (overlap filler)
		add	[bx+si],al		; bytes 00 00 (overlap filler)
		pop	es			; byte 07 (overlap filler)
		pop	es			; byte 07 (overlap filler)
		add	ax,[bp+di]		; bytes 03 03 (overlap filler)
		add	al,4			; bytes 04 04
		add	ax,0F605h		; bytes 05 05 F6
		inc	sp			; byte 44
;*		or	bh,bh			; alt encoding for `test [si+8],0FFh` start
		db	 08h,0FFh		; (alt encoding; pairs with prior 'inc sp' byte)
		jnz	tori_s4_pre_done			; Jump if not zero
		mov	byte ptr [si+8],4

tori_s4_pre_done:
		test	byte ptr [si+5],20h	; ' '
		jz	tori_s4_step			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

tori_s4_step:
		call	word ptr cs:ai_fn_tbl_h
		jc	tori_s4_dispatch			; Jump if carry Set
		retn

tori_s4_dispatch:
		mov	bl,[si+9]
		and	bx,3
		add	bx,bx
		jmp	word ptr ds:tori_tbl_b[bx]	;*

; tori_s4_substate_dispatch -- entered after primary dispatch JMP (overlap of dispatch JMP encoding).

tori_s4_substate_dispatch:				; was '* No entry point to code' marker
		and	ds:tori_tbl_c[di],sp
		mov	dx,12A5h
		cmpsb				; Cmp [si] to es:[di]
		or	byte ptr [si+4],60h	; '`'
		add	byte ptr [si+6],80h
		jc	tori_s4a_phase_carry			; Jump if carry Set
		retn

tori_s4a_phase_carry:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		jz	tori_s4a_phase_zero			; Jump if zero
		retn

tori_s4a_phase_zero:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],7
		jb	tori_s4a_test_facing			; Jump if below
		mov	byte ptr [si+9],1
		mov	byte ptr [si+6],2

tori_s4a_test_facing:
		test	byte ptr [si+5],80h
		jz	tori_s4a_west			; Jump if zero
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_k
		xchg	si,di
		add	si,4Ah
		call	word ptr cs:ai_fn_tbl_l
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:ai_fn_tbl_m
		jz	tori_s4a_jmp_b			; Jump if zero
		jmp	word ptr cs:ai_fn_tbl_b

tori_s4a_jmp_b:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:ai_fn_tbl_f

tori_s4a_west:
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_k
		xchg	si,di
		add	si,47h
		call	word ptr cs:ai_fn_tbl_l
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:ai_fn_tbl_m
		jz	tori_s4a_jmp_f			; Jump if zero
		jmp	word ptr cs:ai_fn_tbl_f

tori_s4a_jmp_f:
		or	byte ptr [si+5],80h
		jmp	word ptr cs:ai_fn_tbl_b

; tori_s4_sub2 -- entered via tori_tbl_b[2] dispatch (DS:0xA51D -> 0xA5A3); phase counter substate.

tori_s4_sub2:				; was '* No entry point to code' marker
		and	byte ptr [si+4],1Fh
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],5
		je	tori_s4b_advance			; Jump if equal
		retn

tori_s4b_advance:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+0Ah],0
		retn

; tori_s4_sub3 -- entered via tori_tbl_b[3] dispatch (DS:0xA51F -> 0xA5BA); attack phase substate.

tori_s4_sub3:				; was '* No entry point to code' marker
		test	byte ptr [si+9],80h
		jnz	tori_atk_set_state3			; Jump if not zero
		add	byte ptr [si+6],40h	; '@'
		jc	tori_atk_phase_carry			; Jump if carry Set
		retn

tori_atk_phase_carry:
		xor	byte ptr [si+5],80h
		call	tori_dist_check_5
		jc	tori_atk_setup			; Jump if carry Set
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],3
		je	tori_atk_set_state3			; Jump if equal
		retn

tori_atk_set_state3:
		mov	byte ptr [si+9],3
		mov	byte ptr [si+6],5
		retn

tori_atk_setup:
		mov	byte ptr [si+6],6
		or	byte ptr [si+9],80h
		mov	al,[si+3]
		mov	ds:tori_tbl_f,al
		inc	al
		mov	ds:tori_tbl_d,al
		mov	al,[si+2]
		and	al,3Fh			; '?'
		mov	ds:tori_tbl_g,al
		mov	ds:tori_tbl_e,al
		mov	bx,0A654h
		test	byte ptr [si+5],80h
		jnz	tori_atk_jmp			; Jump if not zero
		mov	bx,0A661h

tori_atk_jmp:
		jmp	word ptr cs:ai_attack_fn

; tori_s4_decel -- fall-through after retn above -- decel/reset substate.

tori_s4_decel:				; was '* No entry point to code' marker
		dec	byte ptr [si+6]
		cmp	byte ptr [si+6],1
		je	tori_decel_reset			; Jump if equal
		retn

tori_decel_reset:
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn

tori_ai_main	endp

tori_dist_check_5		proc	near
		mov	al,ds:gvar_frame_cnt
		sub	al,[si+2]
		jns	dist5_abs_done			; Jump if not sign
		neg	al

dist5_abs_done:
		cmp	al,5
		mov	al,0FFh
		jc	dist5_in_range			; Jump if carry Set
		retn

dist5_in_range:
		cmp	byte ptr [si+3],11h
		jae	dist5_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dist5_clear_carry			; Jump if zero
		retn

dist5_clear_carry:
		clc				; Clear carry flag
		retn

dist5_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dist5_far_clear			; Jump if not zero
		retn

dist5_far_clear:
		clc				; Clear carry flag
		retn

tori_dist_check_5		endp

		db	 00h, 00h, 2Bh, 00h, 0Fh, 00h
		db	 28h
		db	8 dup (0)
		db	 2Bh, 00h, 0Fh, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h,0F6h
		db	 44h, 08h,0FFh, 75h, 04h,0C6h
		db	 44h, 08h, 04h,0F6h, 44h, 05h
		db	 20h, 74h, 05h, 2Eh,0FFh
		db	 26h, 34h, 60h

tori_s5_main:
		mov	al,[si+6]
		push	ax
		mov	byte ptr [si+6],0
		call	word ptr cs:ai_fn_tbl_h
		pop	ax
		jc	tori_s5_after_step			; Jump if carry Set
		retn

tori_s5_after_step:
		mov	[si+6],al
		test	byte ptr [si+9],1
		jnz	tori_s5_state1_active			; Jump if not zero
		mov	byte ptr [si+6],1
		mov	byte ptr [si+0Ah],0
		call	tori_dist_check_6
		jc	tori_s5_dist_carry			; Jump if carry Set
		cmp	al,0FFh
		jne	tori_s5_apply_facing			; Jump if not equal
		retn

tori_s5_apply_facing:
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		retn

tori_s5_dist_carry:
		cmp	ah,0Ah
		jb	tori_s5_set_state1			; Jump if below
		retn

tori_s5_set_state1:
		or	byte ptr [si+9],1
		retn

tori_s5_state1_active:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],14h
		je	tori_s5_state1_finish			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	tori_s5_state1_west			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_f
		jnc	tori_s5_state1_step			; Jump if carry=0
		call	word ptr cs:ai_fn_tbl_e
		jnc	tori_s5_state1_step			; Jump if carry=0

tori_s5_state1_finish:
			and	byte ptr [si+9],0FEh
			retn

tori_s5_state1_west:
			call	word ptr cs:ai_fn_tbl_b
			jnc	tori_s5_state1_step			; Jump if carry=0
			call	word ptr cs:ai_fn_tbl_c
			jc	tori_s5_state1_finish			; Jump if carry Set

tori_s5_state1_step:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		jae	tori_s5_state1_reset			; Jump if above or =
		retn

tori_s5_state1_reset:
		mov	byte ptr [si+6],1
		retn

tori_dist_check_6		proc	near
		mov	al,ds:gvar_frame_cnt
		sub	al,[si+2]
		jns	dist6_abs_done			; Jump if not sign
		neg	al

dist6_abs_done:
		cmp	al,6
		mov	al,0FFh
		jc	dist6_in_range			; Jump if carry Set
		retn

dist6_in_range:
		mov	al,11h
		sub	al,[si+3]
		jc	dist6_far_branch			; Jump if carry Set
		mov	ah,al
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dist6_clear_carry			; Jump if zero
		retn

dist6_clear_carry:
		clc				; Clear carry flag
		retn

dist6_far_branch:
		neg	al
		mov	ah,al
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dist6_far_clear			; Jump if not zero
		retn

dist6_far_clear:
		clc				; Clear carry flag
		retn

tori_dist_check_6		endp

seg_a		ends

		end	start
