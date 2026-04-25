
PAGE  59,132

;==========================================================================
;
;  304EAI4.BIN - Enemy AI Handler: ZELA (zelres3 chunk 5)
;
;  Per-enemy AI controller for the ZELA enemy, loaded alongside
;  312ZELA.BIN sprites. ZELA is a mid-game enemy with segmented body
;  (this file spawns linked body parts in enemy_data_ext[bx] starting
;  at 0ED20h and chains them via the enemy table at 0C010h).
;
;  Dispatch model matches the EAI* family (see 301EAI1.asm).
;
;  Resource table constants (DS offsets in game_seg):
;    6004h..603Eh = ZELA movement/collision/spawn dispatch table slots.
;    0A45Eh / 0A756h = ZELA attack-pattern and movement direction tables.
;    0C002h = shared active projectile count (gvar_proj_cnt).
;    0C010h = enemy slot record base (enemy_attr_base).
;    0ED20h = extended enemy data area (body segment/chain tracking).
;    0FF35h / 0FF4Ah = global frame / sub-frame counters.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- ZELA enemy AI dispatch table (game_seg:6004h..603Eh, DS-relative) ---
ai_fn_tbl_a	equ	6004h			; AI fn
ai_fn_tbl_b	equ	6008h			; AI fn
ai_fn_tbl_c	equ	6010h			; AI fn
ai_fn_tbl_d	equ	6012h			; AI fn
ai_fn_tbl_e	equ	6014h			; AI fn
ai_fn_tbl_f	equ	6016h			; AI fn
ai_fn_tbl_g	equ	6028h			; AI fn
ai_fn_tbl_h	equ	602Ah			; AI fn
ai_fn_tbl_i	equ	602Ch			; AI fn
ai_fn_tbl_j	equ	602Eh			; AI fn
ai_fn_tbl_k	equ	6032h			; AI fn
ai_hide_fn	equ	6034h			; AI fn: hide / despawn
ai_spawn_fn	equ	603Eh			; AI fn: spawn body segment

; --- ZELA lookup tables / battle globals ---
zela_tbl_a	equ	0A45Eh			; ZELA pattern/direction lookup A (east-facing)
zela_tbl_a_alt	equ	0A456h			; ZELA pattern/direction lookup A (west-facing, alt)
zela_tbl_b	equ	0A756h			; ZELA pattern/direction lookup B (east-facing)
zela_tbl_b_alt	equ	0A7CEh			; ZELA pattern/direction lookup B (west-facing, alt)
gvar_proj_cnt	equ	0C002h			; shared projectile count
enemy_attr_base	equ	0C010h			; enemy slot record base (DS:0C010h)
enemy_data_ext	equ	0ED20h			; extended enemy data area (body chain)
gvar_frame_cnt	equ	0FF35h			; frame counter byte
gvar_sub_frame	equ	0FF4Ah			; sub-frame counter byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zela_ai_main	proc	far

start:
		inc	si
		or	[bx+si],al
		add	[bx+di-5Eh],ch
		db	 00h, 00h, 00h, 00h, 4Fh,0A2h
		db	 0Ah, 0Ah, 00h, 00h, 14h, 00h
		db	 00h, 00h, 14h, 04h
		db	 50h, 50h, 50h
		db	27 dup (0)
		db	0B0h,0A0h, 5Fh,0A1h, 96h,0A1h
		db	0A0h,0A1h,0B9h,0A1h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 50h,0A1h
		db	 87h,0A1h,0AAh,0A1h,0AAh,0A1h
		db	0CDh,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 2Ch,0A2h, 2Ch,0A2h
		db	0DCh,0A1h, 13h,0A2h,0EBh,0A1h
		db	0FFh,0A1h, 27h,0A2h, 00h, 00h
		db	 45h,0A2h, 4Ah,0A2h, 40h,0A2h
		db	 00h, 00h
		db	9 dup (0)
		db	0A1h, 5Fh,0A1h, 96h,0A1h,0A0h
		db	0A1h,0B9h,0A1h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 50h,0A1h, 87h
		db	0A1h,0AAh,0A1h,0AAh,0A1h,0CDh
		db	0A1h, 00h, 00h, 00h, 00h
zela_anim_state_marker		db	0
		db	 00h, 2Ch,0A2h, 2Ch,0A2h,0DCh
		db	0A1h, 13h,0A2h,0EBh,0A1h,0FFh
		db	0A1h, 27h,0A2h, 00h, 00h, 45h
		db	0A2h, 4Ah,0A2h, 40h,0A2h, 00h
		db	 00h
		db	8 dup (0)
		db	 01h, 00h, 01h, 02h, 03h, 01h
		db	 00h, 01h, 05h, 06h, 01h, 00h
		db	 01h, 08h, 09h, 01h, 00h, 01h
		db	 0Bh, 0Ch, 01h, 00h, 01h, 0Eh
		db	 0Fh, 01h, 00h, 01h, 11h, 12h
		db	 01h, 00h, 01h, 14h, 15h, 01h
		db	 00h, 01h, 17h, 18h, 01h, 00h
		db	 01h, 32h, 33h, 01h, 00h, 00h
		db	 34h, 35h, 01h, 00h, 00h, 36h
		db	 37h, 01h, 00h, 00h, 38h, 39h
		db	 01h, 00h, 00h,0E2h,0A4h, 01h
		db	 3Ah, 3Bh, 3Ch, 3Dh, 01h, 3Eh
		db	 00h, 3Fh, 00h, 01h, 40h, 00h
		db	 41h, 00h, 01h, 19h, 00h, 1Ah
		db	 1Bh, 01h, 19h, 00h, 1Dh, 1Eh
		db	 01h, 19h, 00h, 20h, 21h, 01h
		db	 19h, 00h, 23h, 24h, 01h, 19h
zela_rng_fn_ptr		dw	2600h
		db	 27h, 01h, 19h, 00h, 29h, 2Ah
		db	 01h, 19h, 00h
		db	 2Ch, 2Dh
zela_phase_marker		db	1
		db	 19h, 00h, 2Fh, 30h, 01h, 19h
		db	 00h, 43h, 44h, 01h, 00h, 00h
		db	 45h, 46h, 01h, 00h, 00h, 47h
		db	 48h, 01h, 00h, 00h, 49h, 4Ah
		db	 01h, 00h, 00h,0A3h,0A2h, 01h
		db	 4Bh, 4Ch, 4Dh, 4Eh, 01h, 00h
		db	 4Fh, 00h, 50h, 01h, 00h, 51h
		db	 00h, 52h, 01h, 53h, 54h, 55h
		db	 56h, 01h, 57h, 58h, 59h, 5Ah
		db	 01h
		db	 5Bh, 5Ch
		db	']^', 0
		db	'_`ab', 0
		db	'c`ef', 0
		db	'ghij', 0
		db	'_lmn', 0
		db	'o`qr', 0
		db	'stuv', 0
		db	'cxyz', 0
		db	'{l}~', 0
		db	 7Fh, 80h, 81h, 82h, 00h, 83h
		db	 84h, 85h, 86h, 00h, 87h, 88h
		db	 89h, 8Ah, 02h, 8Bh, 8Ch, 8Dh
		db	 8Eh, 02h, 8Fh, 90h
zela_anim_phase_idx		db	91h			; Data table (indexed access)
		db	 92h, 02h, 9Dh, 9Dh, 9Eh, 9Eh
		db	 02h,0A1h,0A1h, 9Eh, 9Eh, 02h
		db	 95h, 96h, 98h, 99h, 02h, 99h
		db	 9Ah, 9Bh, 9Ch, 02h, 00h, 00h
		db	 9Fh,0A0h, 00h,0A8h,0A9h,0AAh
		db	0ABh, 00h,0ACh,0ADh,0AEh,0AFh
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h
		db	0B4h,0B5h,0B6h,0B7h, 00h,0B8h
		db	0B9h,0BAh,0BBh, 00h,0BCh,0BDh
		db	0BEh,0BFh, 00h,0C0h,0C1h,0C2h
		db	0C3h, 01h, 04h, 07h, 0Ah, 0Dh
		db	 01h, 10h, 13h, 16h, 1Ch, 01h
		db	 1Fh, 22h, 25h, 28h, 00h, 2Bh
		db	 2Eh, 31h, 42h, 00h, 64h, 6Bh
		db	 70h, 77h, 00h, 7Ch,0C4h,0C5h
		db	0C6h, 00h, 64h, 6Bh, 70h, 77h
		db	 02h, 2Bh, 2Eh, 31h, 42h, 02h
		db	 64h, 6Bh, 70h, 77h, 02h, 7Ch
		db	0C4h,0C5h,0C6h, 02h, 64h, 6Bh
		db	 70h, 77h, 00h,0C7h,0C8h,0C9h
		db	0CAh, 00h,0C7h,0C8h,0C9h,0CAh
		db	 00h,0C7h,0C8h,0C9h,0CAh, 00h
		db	0C7h,0C8h,0C9h,0CAh, 01h,0CBh
		db	0CCh,0CDh,0CEh, 02h,0D7h,0D7h
		db	0D7h,0D7h, 02h,0D8h,0D9h,0DAh
		db	0DBh, 02h,0DCh,0DDh,0DEh,0DFh
		db	 02h, 00h, 00h,0E0h,0E1h, 00h
		db	0CFh,0D0h,0D1h,0D2h, 00h,0D3h
		db	0D4h,0D5h,0D6h, 02h,0D3h,0D4h
		db	0D5h,0D6h, 59h,0A2h, 5Dh,0A2h
		db	 61h,0A2h, 61h,0A2h, 65h,0A2h
		db	 05h, 04h, 04h, 05h, 04h, 04h
		db	 04h, 04h, 01h, 01h, 01h, 01h
		db	 05h, 05h, 05h, 04h, 8Ah, 5Ch
		db	 04h, 80h,0E3h, 0Fh, 32h,0FFh
		db	 03h,0DBh,0FFh,0A7h, 77h,0A2h
		db	 81h,0A2h, 66h,0A4h,0B1h,0A6h
		db	0B1h,0A6h,0F0h,0A6h,0F6h, 44h
		db	 08h,0FFh, 75h, 04h,0C6h
		db	 44h, 08h, 08h

dispatch_by_state_hi:
		test	byte ptr [si+5],20h	; ' '
		jz	state_test_bit3			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

state_test_bit3:
		test	byte ptr [si+9],8
		jz	state_test_bit2			; Jump if zero
		jmp	state_bit3_anim_inc

state_test_bit2:
		test	byte ptr [si+9],4
		jz	state_default_call			; Jump if zero
		jmp	state_bit2_anim_step

state_default_call:
		call	word ptr cs:ai_fn_tbl_e
		jc	state_default_post			; Jump if carry Set
		retn

state_default_post:
		test	byte ptr [si+9],1
		jnz	state_bit0_anim_inc			; Jump if not zero
		test	byte ptr [si+9],2
		jz	phase_advance_lo			; Jump if zero
		jmp	state_bit1_anim_dec

phase_advance_lo:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		and	ah,0F0h
		or	al,ah
		add	al,80h
		mov	[si+6],al
		jc	phase_check_frame			; Jump if carry Set
		retn

phase_check_frame:
		mov	al,ds:gvar_frame_cnt
		mov	ah,[si+2]
		cmp	al,ah
		je	phase_match_branch			; Jump if equal
		inc	al
		and	al,3Fh			; '?'
		cmp	al,ah
		je	phase_match_branch			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	phase_set_dir_west_a			; Jump if not zero
		jmp	short phase_clear_dir_a

phase_match_branch:
		call	word ptr cs:zela_rng_fn_ptr
		and	al,3
		jnz	phase_skip_state5			; Jump if not zero
		mov	byte ptr [si+9],5

phase_skip_state5:
		cmp	byte ptr [si+3],11h
		jb	phase_set_dir_west_a			; Jump if below

phase_clear_dir_a:
		and	byte ptr [si+5],7Fh
		call	word ptr cs:ai_fn_tbl_c
		jc	phase_set_state9_a			; Jump if carry Set
		retn

phase_set_state9_a:
		mov	byte ptr [si+9],9
		retn

phase_set_dir_west_a:
		or	byte ptr [si+5],80h
		call	word ptr cs:ai_fn_tbl_b
		jc	phase_set_state9_b			; Jump if carry Set
		retn

phase_set_state9_b:
		mov	byte ptr [si+9],9
		retn

state_bit0_anim_inc:
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,8
		jae	state_bit0_inc_post			; Jump if above or =
		mov	byte ptr [si+6],8
		retn

state_bit0_inc_post:
		inc	al
		mov	[si+6],al
		cmp	al,0Bh
		je	state_bit0_set_anim_b			; Jump if equal
		retn

state_bit0_set_anim_b:
		or	al,10h
		mov	[si+6],al
		and	byte ptr [si+9],0FEh
		retn

state_bit1_anim_dec:
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,0Ch
		jb	state_bit1_dec_post			; Jump if below
		mov	byte ptr [si+6],0Bh
		retn

state_bit1_dec_post:
		dec	al
		mov	[si+6],al
		cmp	al,8
		je	state_bit1_set_anim_8			; Jump if equal
		retn

state_bit1_set_anim_8:
		or	al,10h
		mov	[si+6],al
		and	byte ptr [si+9],0FDh
		retn

state_bit2_anim_step:
		mov	al,[si+6]
		and	al,0Fh
		inc	al
		cmp	al,0Fh
		jae	state_bit2_clamp_a			; Jump if above or =
		mov	[si+6],al
		retn

state_bit2_clamp_a:
		cmp	al,10h
		jb	state_bit2_set_anim			; Jump if below
		mov	al,0Eh

state_bit2_set_anim:
		mov	[si+6],al
		test	byte ptr [si+5],80h
		jz	state_bit2_west_branch			; Jump if zero
		call	word ptr cs:ai_fn_tbl_f
		call	word ptr cs:ai_fn_tbl_f
		jc	state_bit2_carry_a			; Jump if carry Set
		retn

state_bit2_carry_a:
		call	word ptr cs:ai_fn_tbl_b
		call	word ptr cs:ai_fn_tbl_b
		jc	state_bit2_carry_b			; Jump if carry Set
		retn

state_bit2_carry_b:
		and	byte ptr [si+5],7Fh
		jmp	short state_bit2_finish

state_bit2_west_branch:
		call	word ptr cs:ai_fn_tbl_d
		call	word ptr cs:ai_fn_tbl_d
		jc	state_bit2_west_carry_a			; Jump if carry Set
		retn

state_bit2_west_carry_a:
		call	word ptr cs:ai_fn_tbl_c
		call	word ptr cs:ai_fn_tbl_c
		jc	state_bit2_west_carry_b			; Jump if carry Set
		retn

state_bit2_west_carry_b:
		or	byte ptr [si+5],80h

state_bit2_finish:
		mov	byte ptr [si+6],1Dh
		mov	byte ptr [si+9],2
		retn

state_bit3_anim_inc:
		mov	al,[si+6]
		inc	al
		and	al,0Fh
		cmp	al,0Dh
		jb	state_bit3_set_anim			; Jump if below
		mov	al,0Bh

state_bit3_set_anim:
		mov	[si+6],al
		test	byte ptr [si+0Ah],1
		jnz	state_bit3_aux4_check			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_e
		add	byte ptr [si+9],10h
		test	byte ptr [si+9],0F0h
		jz	state_bit3_set_aux1			; Jump if zero
		retn

state_bit3_set_aux1:
		or	byte ptr [si+0Ah],1
		retn

state_bit3_aux4_check:
		test	byte ptr [si+0Ah],4
		jnz	state_bit3_lookup			; Jump if not zero
		or	byte ptr [si+0Ah],4
		test	byte ptr [si+0Ah],8
		jnz	state_bit3_aux8_jmp_c			; Jump if not zero
		jmp	word ptr cs:ai_fn_tbl_b

state_bit3_aux8_jmp_c:
		jmp	word ptr cs:ai_fn_tbl_c

state_bit3_lookup:
		mov	bx,zela_tbl_a_alt
		test	byte ptr [si+5],80h
		jnz	state_bit3_lookup_done			; Jump if not zero
		mov	bx,zela_tbl_a

state_bit3_lookup_done:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		and	al,7
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],0E0h
		jnz	state_bit3_xlat_call			; Jump if not zero
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+9],2

state_bit3_xlat_call:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:ai_fn_tbl_a
		jc	state_bit3_attr_check			; Jump if carry Set
		retn

state_bit3_attr_check:
		mov	al,[si+9]
		and	al,0E0h
		jnz	state_bit3_attr_high			; Jump if not zero
		retn

state_bit3_attr_high:
		cmp	al,0C0h
		jb	state_bit3_flip_dir			; Jump if below
		retn

state_bit3_flip_dir:
		xor	byte ptr [si+5],80h
		retn

; -------------------------------------------------------------------------
;  zela_attack_state -- entered via DS state-dispatch table (same pattern as
;  303EAI3 / 309CRAB).  The block opens with 18 bytes that Sourcer mis-decoded
;  as code; they are actually data-table tail bytes (anim/state lookup) for
;  the preceding section.  The real attack-state preroll begins at the
;  `test [si+8],FFh / jnz +4 / mov [si+8],10h` sequence below.
; -------------------------------------------------------------------------

zela_attack_data_tail:				; trailing data (mis-decoded as code)
		db	 02h, 01h		; was "add al,[bx+di]"
		db	 01h, 00h		; was "add [bx+si],ax"
		db	 00h, 07h		; was "add [bx],al"
		db	 07h			; was "pop es"
		db	 06h			; was "push es"
		db	 02h, 03h		; was "add al,[bp+di]"
		db	 03h, 04h		; was "add ax,[si]"
		db	 04h, 05h		; was "add al,5"
		db	 05h, 06h,0F6h		; was "add ax,0F606h"
		db	 44h			; was "inc sp"

zela_attack_state:				; entered via DS state-dispatch table
		db	 08h,0FFh		; was Fixup; assembles as "or bh,bh" (zero test)
		jnz	attack_state_entry			; Jump if not zero
		mov	byte ptr [si+8],10h

attack_state_entry:
		test	byte ptr [si+5],20h	; ' '
		jz	attack_state_post_spawn			; Jump if zero
		mov	al,[si+5]
		and	al,1Fh
		cmp	al,4
		jne	attack_state_check_5			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

attack_state_check_5:
		cmp	al,5
		jne	attack_state_check_8			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

attack_state_check_8:
		cmp	al,8
		jne	attack_state_check_1			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

attack_state_check_1:
		cmp	al,1
		jne	attack_state_phase_check			; Jump if not equal
		cmp	zela_anim_state_marker,6
		jne	attack_state_phase_check			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

attack_state_phase_check:
		test	byte ptr [si+6],1
		jz	attack_state_spawn			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

attack_state_spawn:
		and	byte ptr [si+5],0DFh
		test	byte ptr [si+7],40h	; '@'
		jnz	attack_state_post_spawn			; Jump if not zero
		call	word ptr cs:ai_spawn_fn
		jc	attack_state_post_spawn			; Jump if carry Set
		mov	word ptr [di],0FF00h
		test	byte ptr [di+7],40h	; '@'
		jz	attack_state_after_clear			; Jump if zero
		and	byte ptr [di+7],0BFh
		mov	al,[di+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	bx,ax
		add	bx,ds:enemy_attr_base
		mov	byte ptr [bx+2],0

attack_state_after_clear:
		mov	byte ptr [di+2],7Fh
		mov	[si+0Ah],dl
		or	byte ptr [si+7],40h	; '@'

attack_state_post_spawn:
		test	byte ptr [si+9],1
		pushf				; Push flags
		and	byte ptr [si+9],0FEh
		popf				; Pop flags
		jz	attack_state_phase_proc			; Jump if zero
		retn

attack_state_phase_proc:
		test	byte ptr [si+7],40h	; '@'
		jnz	attack_state_secondary			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		and	ah,0F0h
		or	al,ah
		mov	[si+6],al
		mov	bx,si

attack_state_retry:
		mov	si,bx

attack_state_call_e:
			call	word ptr cs:ai_fn_tbl_e
			jc	attack_state_decrement			; Jump if carry Set
			retn

attack_state_decrement:
			sub	byte ptr [si+6],10h
			test	byte ptr [si+6],0F0h
			jz	attack_state_check_dir			; Jump if zero
			retn

attack_state_check_dir:
			or	byte ptr [si+6],40h	; '@'
			mov	al,ds:gvar_frame_cnt
			cmp	al,[si+2]
			je	attack_state_match			; Jump if equal
			inc	al
			and	al,3Fh			; '?'
			cmp	al,[si+2]
			je	attack_state_match			; Jump if equal
			test	byte ptr [si+5],80h
			jnz	attack_state_set_dir			; Jump if not zero
			jmp	short attack_state_clear_dir

attack_state_match:
			mov	al,10h
			cmp	al,[si+3]
			jae	attack_state_set_dir			; Jump if above or =

attack_state_clear_dir:
			and	byte ptr [si+5],7Fh
			call	word ptr cs:ai_fn_tbl_c
			jc	attack_state_set_dir			; Jump if carry Set
			retn

attack_state_set_dir:
			or	byte ptr [si+5],80h
			call	word ptr cs:ai_fn_tbl_b
			jc	attack_state_chain_c			; Jump if carry Set
			retn

attack_state_chain_c:
			and	byte ptr [si+5],7Fh
			jmp	word ptr cs:ai_fn_tbl_c

attack_state_secondary:
			mov	al,[si+6]
			mov	ah,al
			inc	al
			and	al,7
			and	ah,0F0h
			or	ah,al
			mov	[si+6],ah
			cmp	al,6
			jne	attack_state_call_e			; Jump if not equal
		and	[si+6],ah
		mov	al,[si+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,ds:enemy_attr_base
		mov	di,ax
		push	di
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_g
		mov	bx,si
		mov	si,di
		pop	di
		test	byte ptr [bx+5],80h
		jnz	attack_secondary_west			; Jump if not zero
		mov	al,[bx+3]
		or	al,al			; Zero ?
		jns	attack_secondary_pos			; Jump if not sign
		jmp	attack_state_retry

attack_secondary_pos:
		cmp	al,21h			; '!'
		jb	attack_secondary_pos_lt			; Jump if below
		jmp	attack_state_retry

attack_secondary_pos_lt:
		mov	ax,23h
		call	collide_check_dist
		jnc	attack_secondary_init_e			; Jump if carry=0
		jmp	attack_state_retry

attack_secondary_init_e:
		inc	si
		inc	si
		mov	cl,[si]
		mov	al,[bx+0Ah]
		or	al,80h
		mov	[si],al
		xchg	si,bx
		mov	al,[si+4]
		and	al,1Fh
		mov	[di+4],al
		mov	ax,[si]
		add	ax,2
		mov	dx,ds:gvar_proj_cnt
		dec	dx
		sub	dx,ax
		jnc	attack_secondary_set_pos			; Jump if carry=0
		not	dx
		mov	ax,dx

attack_secondary_set_pos:
		mov	[di],ax
		mov	al,[si+3]
		add	al,2
		mov	[di+3],al
		mov	byte ptr [si+6],16h
		mov	byte ptr [di+6],17h
		jmp	short attack_secondary_finish

attack_secondary_west:
		mov	al,[bx+3]
		or	al,al			; Zero ?
		jns	attack_secondary_west_pos			; Jump if not sign
		jmp	attack_state_retry

attack_secondary_west_pos:
		cmp	al,3
		jae	attack_secondary_west_pos_ge			; Jump if above or =
		jmp	attack_state_retry

attack_secondary_west_pos_ge:
		mov	ax,27h
		call	collide_check_dist
		jnc	attack_secondary_west_init			; Jump if carry=0
		jmp	attack_state_retry

attack_secondary_west_init:
		dec	si
		dec	si
		mov	cl,[si]
		mov	al,[bx+0Ah]
		or	al,80h
		mov	[si],al
		xchg	si,bx
		mov	al,[si+4]
		and	al,1Fh
		mov	[di+4],al
		mov	ax,[si]
		sub	ax,2
		or	ax,ax			; Zero ?
		jns	attack_secondary_west_set_pos			; Jump if not sign
		add	ax,ds:gvar_proj_cnt

attack_secondary_west_set_pos:
		mov	[di],ax
		mov	al,[si+3]
		sub	al,2
		mov	[di+3],al
		mov	byte ptr [si+6],17h
		mov	byte ptr [di+6],16h

attack_secondary_finish:
		mov	al,[si+2]
		mov	[di+2],al
		mov	bl,[si+0Ah]
		xor	bh,bh			; Zero register
		mov	ds:enemy_data_ext[bx],cl
		mov	byte ptr [di+7],0
		mov	byte ptr [di+8],0
		mov	byte ptr [di+9],0
		and	byte ptr [si+7],0BFh
		mov	al,ds:gvar_sub_frame
		cmp	al,[si+0Ah]
		jb	attack_secondary_set_active			; Jump if below
		retn

attack_secondary_set_active:
		or	byte ptr [di+9],1
		retn

zela_ai_main	endp

collide_check_dist		proc	near
		push	si
		sub	si,ax
		call	word ptr cs:ai_fn_tbl_i
		mov	cx,3

collide_check_loop:
			mov	al,[si]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jnz	collide_check_done			; Jump if not zero
			mov	al,[si+1]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jnz	collide_check_done			; Jump if not zero
			mov	al,[si+2]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jnz	collide_check_done			; Jump if not zero
			add	si,24h
			call	word ptr cs:ai_fn_tbl_h
			loop	collide_check_loop		; Loop if cx > 0

		clc				; Clear carry flag

collide_check_done:
		pop	si
		retn

collide_check_dist		endp

; -------------------------------------------------------------------------
;  zela_low_state -- entered via DS state-dispatch table.
;  Handles low-distance encounter logic (range/phase/attack init).
; -------------------------------------------------------------------------

zela_low_state:					; entered via DS state-dispatch table
		or	byte ptr [si+4],20h	; ' '
		test	byte ptr [si+9],1
		jnz	low_state_active			; Jump if not zero
		mov	al,[si+3]
		cmp	al,8
		jae	low_dist_check_a			; Jump if above or =
		retn

low_dist_check_a:
		cmp	al,13h
		jb	low_dist_check_b			; Jump if below
		retn

low_dist_check_b:
		call	word ptr cs:zela_rng_fn_ptr
		and	al,3
		jz	low_dist_set_phase			; Jump if zero
		retn

low_dist_set_phase:
		mov	byte ptr [si+6],1
		or	byte ptr [si+9],1
		retn

low_state_active:
		call	word ptr cs:ai_fn_tbl_e
		jc	low_state_init_attack			; Jump if carry Set
		retn

low_state_init_attack:
		and	byte ptr [si+7],0F0h
		or	byte ptr [si+7],1
		jmp	word ptr cs:ai_fn_tbl_k

; -------------------------------------------------------------------------
;  zela_spawn_state -- entered via DS state-dispatch table.
;  Cooldown preroll then range-gated lookup that selects new state/phase
;  via zela_lookup_state.  Spawns body segments via ai_spawn_fn.
; -------------------------------------------------------------------------

zela_spawn_state:				; entered via DS state-dispatch table
		test	byte ptr [si+8],0FFh
		jnz	spawn_state_pre_done			; Jump if not zero
		mov	byte ptr [si+8],2

spawn_state_pre_done:
		test	byte ptr [si+5],20h	; ' '
		jz	spawn_state_dist_a			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

spawn_state_dist_a:
		cmp	byte ptr [si+3],3
		jae	spawn_state_dist_b			; Jump if above or =
		retn

spawn_state_dist_b:
		cmp	byte ptr [si+3],21h	; '!'
		jb	spawn_state_lookup			; Jump if below
		retn

spawn_state_lookup:
		call	zela_lookup_state
		cmp	cl,3
		je	zela_lookup_state_alt			; Jump if equal
		retn

zela_lookup_state		proc	near

zela_lookup_state_alt:
		mov	bx,zela_tbl_b_alt
		test	byte ptr [si+5],80h
		jnz	zela_lookup_e			; Jump if not zero
		mov	bx,zela_tbl_b

zela_lookup_e:
		mov	al,0Fh
		mul	byte ptr [si+9]		; ax = data * al
		add	bx,ax
		mov	cx,5

zela_lookup_loop:
			push	cx
			push	bx
			mov	al,[bx]
			call	word ptr cs:ai_fn_tbl_a
			pop	bx
			pop	cx
			jnc	zela_lookup_match			; Jump if carry=0
			inc	bx
			inc	bx
			inc	bx
			loop	zela_lookup_loop		; Loop if cx > 0

		xor	byte ptr [si+5],80h
		retn

zela_lookup_match:
		mov	al,[bx+1]
		mov	[si+9],al
		mov	al,[bx+2]
		mov	[si+6],al
		retn

zela_lookup_state		endp

; -------------------------------------------------------------------------
;  zela_pattern_data -- 240 bytes of state-pattern data table referenced by
;  the DS table at zela_tbl_b (0xA756) / zela_tbl_b_alt (0xA7CE).
;  Each entry is a 3-byte (anim,state,phase) triplet read in groups of 5
;  by zela_lookup_state via 'mov cx,5 / inc bx 3x'.
;  Sourcer mis-decoded these bytes as code; they are pure data.
; -------------------------------------------------------------------------

zela_pattern_data:
		db	 06h, 02h, 01h, 07h, 01h, 02h
		db	 00h, 00h, 00h, 01h, 07h, 03h
		db	 02h, 06h, 01h, 05h, 03h, 03h
		db	 06h, 02h, 01h, 07h, 01h, 02h
		db	 00h, 00h, 00h, 01h, 07h, 03h
		db	 04h, 04h, 00h, 05h, 03h, 03h
		db	 06h, 02h, 01h, 07h, 01h, 02h
		db	 00h, 00h, 00h, 03h, 05h, 02h
		db	 04h, 04h, 00h, 05h, 03h, 03h
		db	 06h, 02h, 01h, 07h, 01h, 02h
		db	 02h, 06h, 01h, 03h, 05h, 02h
		db	 04h, 04h, 00h, 05h, 03h, 03h
		db	 06h, 02h, 01h, 01h, 07h, 03h
		db	 02h, 06h, 01h, 03h, 05h, 02h
		db	 04h, 04h, 00h, 05h, 03h, 03h
		db	 00h, 00h, 00h, 01h, 07h, 03h
		db	 02h, 06h, 01h, 03h, 05h, 02h
		db	 04h, 04h, 00h, 07h, 01h, 02h
		db	 00h, 00h, 00h, 01h, 07h, 03h
		db	 02h, 06h, 01h, 03h, 05h, 02h
		db	 06h, 06h, 00h, 05h, 07h, 03h
		db	 04h, 00h, 00h, 03h, 01h, 02h
		db	 02h, 02h, 00h, 05h, 07h, 02h
		db	 04h, 00h, 00h, 03h, 01h, 02h
		db	 02h, 02h, 01h, 01h, 03h, 02h
		db	 04h, 00h, 01h, 03h, 01h, 02h
		db	 02h, 02h, 01h, 01h, 03h, 03h
		db	 00h, 04h, 01h, 03h, 01h, 03h
		db	 02h, 02h, 01h, 01h, 03h, 03h
		db	 00h, 04h, 00h, 07h, 05h, 03h
		db	 02h, 02h, 00h, 01h, 03h, 03h
		db	 00h, 04h, 00h, 07h, 05h, 02h
		db	 06h, 06h, 00h, 01h, 03h, 02h
		db	 00h, 04h, 00h, 07h, 05h, 02h
		db	 06h, 06h, 01h, 05h, 07h, 02h
		db	 00h, 04h, 01h, 07h, 05h, 02h
		db	 06h, 06h, 01h, 05h, 07h, 03h
		db	 04h, 00h, 01h, 07h, 05h, 03h
		db	 06h, 06h, 01h, 05h, 07h, 03h
		db	 04h, 00h, 00h, 03h, 01h, 03h

seg_a		ends

		end	start
