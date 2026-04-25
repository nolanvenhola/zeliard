
PAGE  59,132

;==========================================================================
;
;  305EAI5.BIN - Enemy AI Handler: MEDA (zelres3 chunk 6)
;
;  Per-enemy AI controller for the MEDA enemy, loaded alongside
;  313MEDA.BIN sprites. MEDA uses a jellyfish / phasing behaviour with
;  alternating attack/hover phases. Like ZELA it spawns projectiles
;  into the extended enemy area (enemy_data_ext at 0ED20h).
;
;  Dispatch model matches the EAI* family (see 301EAI1.asm).
;
;  Resource table constants (DS offsets in game_seg):
;    6008h..6040h = MEDA movement/collision/attack dispatch table slots.
;    0A1E6h..0A429h = MEDA behaviour lookup tables (phase, direction, attack).
;    0A2AEh / 0B5B4h = code-relative references into the 200FIGHT binary.
;    0C002h = shared projectile count (gvar_proj_cnt).
;    0ED20h = extended enemy data area (enemy_data_ext).
;    0FF35h / 0FF4Ah = global frame / sub-frame counters.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- References into the 200FIGHT battle binary (caller segment) ---
battle_ref_a	equ	0A2AEh			; ref into 200FIGHT code (battle entry A)
battle_ref_b	equ	0B5B4h			; ref into 200FIGHT code (battle entry B)

; --- MEDA enemy AI dispatch table (game_seg:1312h..6040h, DS-relative) ---
ai_fn_intro	equ	1312h			; intro/spawn fn (early table)
ai_fn_tbl_a	equ	6008h			; AI fn
ai_fn_tbl_b	equ	600Ah			; AI fn
ai_fn_tbl_c	equ	600Ch			; AI fn
ai_fn_tbl_d	equ	600Eh			; AI fn
ai_fn_tbl_e	equ	6010h			; AI fn
ai_fn_tbl_f	equ	6014h			; AI fn
ai_fn_tbl_g	equ	6028h			; AI fn
ai_fn_tbl_h	equ	602Ah			; AI fn
ai_fn_tbl_i	equ	602Ch			; AI fn
ai_fn_tbl_j	equ	602Eh			; AI fn
ai_hide_fn	equ	6034h			; AI fn: hide / despawn
ai_attack_fn	equ	603Ah			; AI fn: attack
ai_fn_tbl_k	equ	603Eh			; AI fn
ai_fn_tbl_l	equ	6040h			; AI fn

; --- MEDA lookup tables (game_seg DS) ---
meda_tbl_a	equ	0A1E6h			; MEDA behaviour lookup A
meda_tbl_b	equ	0A268h			; MEDA behaviour lookup B
meda_tbl_c	equ	0A29Ah			; MEDA behaviour lookup C
meda_tbl_d	equ	0A31Ch			; MEDA behaviour lookup D
meda_tbl_e	equ	0A41Bh			; MEDA behaviour lookup E
meda_tbl_f	equ	0A41Ch			; MEDA behaviour lookup F
meda_tbl_g	equ	0A428h			; MEDA behaviour lookup G
meda_tbl_h	equ	0A429h			; MEDA behaviour lookup H
gvar_proj_cnt	equ	0C002h			; shared projectile count
enemy_data_ext	equ	0ED20h			; extended enemy data area
gvar_frame_cnt	equ	0FF35h			; frame counter byte
gvar_sub_frame	equ	0FF4Ah			; sub-frame counter byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

meda_ai_main	proc	far

start:
		db	0F7h, 09h, 00h, 00h, 37h,0A3h
		db	 00h, 00h, 00h, 00h, 21h,0A3h
		db	 32h, 32h, 14h, 0Ah, 0Ah, 00h
		db	 00h, 00h, 28h, 28h, 14h, 14h
		db	 0Ah, 00h
		db	26 dup (0)
		db	0B0h,0A0h, 37h,0A1h,0BEh,0A1h
		db	0F5h,0A1h, 40h,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h,0A1h

init_inline_1:
		scasw				; Scan es:[di] for ax
		mov	ax,ds:meda_tbl_a
		xor	ss:meda_tbl_b[bp+si],sp
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0EAh,0A2h,0FEh,0A2h, 77h,0A2h

init_retn_marker:
		retn	86A2h
; ----------------------------------------------------------------
; Above 'retn 86A2h' is actually data bytes (frame ptr table tail),
; mis-decoded by Sourcer as code. The real bytes form pointers into
; meda_tbl_c/d/a tables. The block below is also data, NOT code:
; ----------------------------------------------------------------
		mov	ds:meda_tbl_c,al
		in	ax,0A2h			; port 0A2h ??I/O Non-standard
		add	[bx+si],al
		pop	ss
		mov	ds:meda_tbl_d,ax
		adc	ah,ss:battle_ref_a[bp+di]
		db	8 dup (0)
		db	0ECh,0A0h, 73h,0A1h,0BEh,0A1h
		db	 13h,0A2h, 40h,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 28h,0A1h
		db	0AFh,0A1h,0E6h,0A1h, 31h,0A2h
		db	 68h,0A2h, 00h, 00h
meda_collide_marker		db	0
		db	0
meda_anim_state_ref		db	0
		db	 00h,0EAh,0A2h,0FEh,0A2h, 77h
		db	0A2h,0C2h,0A2h, 86h,0A2h, 9Ah
		db	0A2h,0E5h,0A2h, 00h, 00h, 17h
		db	0A3h, 1Ch,0A3h, 12h,0A3h,0AEh
		db	0A2h
		db	8 dup (0)
		db	 01h, 8Fh, 90h, 79h, 7Ah, 01h
		db	 7Fh, 80h, 81h, 82h, 01h, 87h
		db	 88h, 89h, 8Ah, 01h, 7Fh, 80h
		db	 99h, 9Ah, 01h, 8Fh, 90h, 91h
		db	 92h, 01h, 7Fh, 80h, 99h, 9Ah
		db	 01h, 87h, 88h, 89h, 8Ah, 01h
		db	 7Fh, 80h, 81h, 82h, 01h,0C7h
		db	 88h,0C9h, 8Ah, 01h,0C7h, 88h
		db	0CBh, 8Ah, 01h,0C7h, 88h,0CDh
		db	 8Ah, 01h,0C7h, 88h,0C9h, 8Ah
		db	 01h,0B7h,0B8h,0A1h,0A2h, 01h
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh
		db	0B0h,0B1h,0B2h, 01h,0A7h,0A8h
		db	0C1h,0C2h, 01h,0B7h,0B8h,0B9h
		db	0BAh, 01h,0A7h,0A8h,0C1h,0C2h
		db	 01h,0AFh,0B0h,0B1h,0B2h, 01h
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh
meda_rng_fn_ptr		dw	0B1CFh
		db	0D1h, 01h,0AFh,0CFh,0B1h,0D2h
		db	 01h,0AFh,0CFh,0B1h,0D3h, 01h
		db	0AFh,0CFh,0B1h,0D1h, 01h,0D4h
		db	0D5h,0D6h,0D7h, 01h, 00h, 00h
		db	0DAh,0DBh, 01h, 00h, 00h, 00h
		db	 00h, 01h, 7Bh, 7Ch, 7Dh, 7Eh
		db	 01h, 83h, 84h, 85h, 86h, 01h
		db	 7Bh, 7Ch, 7Dh, 7Eh, 01h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 01h, 93h, 94h
		db	 95h, 96h, 01h, 9Bh, 9Ch, 9Dh
		db	 9Eh, 01h, 93h, 94h, 95h, 96h
		db	 01h, 8Bh, 8Ch, 8Dh, 8Eh, 01h
		db	 8Bh, 8Ch, 8Dh, 8Eh, 01h, 8Bh
		db	 8Ch, 8Dh, 8Eh, 01h, 8Bh, 8Ch
		db	 8Dh, 8Eh, 01h, 8Bh, 8Ch, 8Dh
		db	 8Eh, 01h,0A3h,0A4h,0A5h,0A6h
		db	 01h,0ABh,0A4h,0ADh,0AEh, 01h
meda_anim_idx_a		db	0A3h			; Data table (indexed access)
		db	0A4h,0A5h,0A6h, 01h,0B3h,0B4h
		db	0B5h
meda_anim_idx_b		db	0B6h			; Data table (indexed access)
		db	 01h,0BBh,0BCh,0BDh,0BEh, 01h
		db	0C3h,0BCh,0C5h,0C6h, 01h,0BBh

init_inline_loop:
			mov	sp,0BEBDh
			add	ss:battle_ref_b[bp+di],si
			mov	dh,1
			mov	bl,0B4h
			mov	ch,0B6h
			add	ss:battle_ref_b[bp+di],si
			mov	dh,1
			mov	bl,0B4h
			mov	ch,0B6h
			add	ss:battle_ref_b[bp+di],si
			mov	dh,1
			loopnz	init_inline_loop		; Loop if zf=0, cx>0

;*		loop	locloop_4		;*Loop if cx > 0

		db	0E2h,0E3h		;  Fixup - byte match
;*		add	sp,sp
		db	 01h,0E4h		;  Fixup - byte match
		in	ax,0E6h			; port 0E6h ??I/O Non-standard
		out	1,ax			; port 1, DMA-1 bas&cnt ch 0
		call	$-1514h
		jmp	short $+2		; delay for I/O
		or	ax,0F0Eh
		adc	[bx+si],al
		adc	ds:ai_fn_intro,cx
		add	[si],dl
		adc	ax,1716h
		add	[di],cl
		sbb	[bx+di],bl
		sbb	al,[bx+si]
		add	[bx+si],al
		add	[bp+si],ax
		add	[bx+si],al
		add	[si],al
		add	ax,0
		add	[bx],al
		or	[bx+si],al
		add	[bx+si],al
		or	cx,[si]
		add	[bp+di],bl
		sbb	al,1Dh
		push	ds
		add	[bx],bl
		and	[bx+di],ah
		and	al,[bx+si]
		and	sp,[si]
		and	ax,0
		db	27h, '()*', 0
		db	'+,-.', 0
		db	'/012', 0
		db	'3456', 0
		db	'789:', 0
		db	';<=>', 0
		db	27h, '()*', 0
		db	'+,-.', 0
		db	'/012', 0
		db	'3456', 0
		db	'789:', 0
		db	'?@AB', 0
		db	'CDEF', 0
		db	'GHIJ', 0
		db	'KLMN', 0
		db	'OPQR', 0
		db	'STUV', 0
		db	'WXQR', 0
		db	'YZQR', 0
		db	'[\]^', 0
		db	'_`ab', 0
		db	'cdef'
		db	 00h, 00h, 00h, 69h, 6Ah, 00h
		db	 6Bh, 6Ch, 6Dh, 6Eh, 00h, 4Bh
		db	 4Ch, 4Dh, 4Eh, 00h, 73h, 74h
		db	 75h, 76h, 01h, 03h, 06h, 0Ah
		db	 26h, 01h, 67h, 68h, 6Fh, 70h
		db	 01h, 71h, 72h,0A0h,0C0h, 00h
		db	 77h, 78h, 97h, 98h, 00h, 9Fh
		db	0ACh,0BFh,0C4h, 00h,0C8h,0CAh
		db	0CCh,0CEh, 00h, 9Fh,0ACh,0BFh
		db	0C4h, 02h, 77h, 78h, 97h, 98h
		db	 02h, 9Fh,0ACh,0BFh,0C4h, 02h
		db	0C8h,0CAh,0CCh,0CEh, 02h, 9Fh
		db	0ACh,0BFh,0C4h, 01h, 77h, 78h
		db	 97h, 98h, 01h, 9Fh,0ACh,0BFh
		db	0C4h, 01h,0C8h,0CAh,0CCh,0CEh
		db	 01h, 9Fh,0ACh,0BFh,0C4h, 00h
		db	0D0h,0D8h,0D9h,0DCh, 00h,0D0h
		db	0D8h,0D9h,0DCh, 00h,0D0h,0D8h
		db	0D9h,0DCh, 00h,0D0h,0D8h,0D9h
		db	0DCh, 00h,0D0h,0D8h,0D9h,0DCh
		db	 00h,0D0h,0D8h,0D9h,0DCh, 00h
		db	0D0h,0D8h,0D9h,0DCh, 01h,0DDh
		db	0DEh,0DFh,0ECh, 00h,0F1h,0F1h
		db	0F1h,0F1h, 00h,0F1h,0F1h,0F3h
		db	0F3h, 00h,0F4h,0F4h,0F6h,0F6h
		db	 00h,0F8h,0F8h,0FAh,0FAh, 00h
		db	0F2h,0F2h,0F1h,0F1h, 00h,0F2h
		db	0F2h,0F3h,0F3h, 00h,0FCh,0FDh
		db	0F6h,0F6h, 00h,0FEh,0FEh,0FAh
		db	0FAh, 02h,0F5h,0F7h,0F9h,0FBh
		db	 00h,0EDh,0EEh,0EFh,0F0h, 02h
		db	0EDh,0EEh,0EFh,0F0h, 2Bh,0A3h
		db	 2Bh,0A3h, 2Fh,0A3h, 33h,0A3h
		db	 33h,0A3h, 0Bh, 05h, 05h, 05h
		db	 05h, 04h, 05h, 04h, 05h, 00h
		db	 05h, 00h
; ----------------------------------------------------------------
; meda_dispatch_entry  -- main AI dispatch (file offset 0x33B):
;   mov bl,[si+4] ; and bl,0Fh ; xor bh,bh ; add bx,bx
;   jmp word ptr ds:[bx+0xA345]
; Dispatch table at 0xA345 (DS) selects sub-state by ([si+4]&0xF):
;   idx 4 -> 0xA350 (sub01_handler, prologue at 0xA354)
;   idx 5 -> 0xA34F (alt entry into same handler A region)
;   idx 6 -> 0xA5F1 (sub02_handler)
;   idx 7 -> 0xA812 (sub03_handler)
;   idx 8 -> 0xA91A (sub04_handler)
; First two table entries (idx 0/1, 2/3) overlap the JMP bytes and
; are unreachable in practice. Bytes below are the dispatch sequence
; followed by the table words and the sub01_handler prologue, all
; emitted as raw db so Sourcer's mis-decode is preserved bit-perfect.
; Decoded:
;   8A 5C 04           mov bl,[si+4]
;   80 E3 0F           and bl,0Fh
;   32 FF              xor bh,bh
;   03 DB              add bx,bx
;   FF A7 45 A3        jmp word ptr ds:[bx+0xA345]
;   50 A3              ; dw sub01_handler-1   (idx 4)
;   4F A3              ; dw sub01_handler-2   (idx 5)
;   F1 A5              ; dw sub02_handler-4   (idx 6)
;   12 A8              ; dw sub03_handler-4   (idx 7)
;   1A A9              ; dw sub04_handler-4   (idx 8)
;   C3                 retn (table padding)
; sub01_handler prologue (file offset 0x354):
;   F6 44 08 FF        test [si+8],0FFh
;   75 04              jnz sub01_main
;   C6 44 08 18        mov [si+8],18h
; sub01_main entry test (file offset 0x35E):
;   F6 44 05 20        test [si+5],20h    (visibility)
;   74 03              jz +3 -> sub01_main
;   E9 D2 00           jmp sub01_finalize
; Falls through to sub01_main at 0x367.
; ----------------------------------------------------------------
		db	 8Ah, 5Ch, 04h, 80h
		db	0E3h, 0Fh, 32h,0FFh, 03h,0DBh
		db	0FFh,0A7h, 45h,0A3h, 50h,0A3h
		db	 4Fh,0A3h,0F1h,0A5h, 12h,0A8h
		db	 1Ah,0A9h,0C3h,0F6h, 44h, 08h
		db	0FFh, 75h, 04h,0C6h, 44h, 08h
		db	 18h,0F6h, 44h, 05h, 20h, 74h
		db	 03h,0E9h,0D2h, 00h

sub01_main:
		and	byte ptr [si+15h],0BFh
		call	sub01_collide_outer
		jc	sub01_state0_path			; Jump if carry Set
		retn

sub01_state0_path:
		test	byte ptr [si+9],1
		jnz	sub01_state0_set			; Jump if not zero
		call	distance_check_4
		jc	sub01_state0_alt			; Jump if carry Set
		add	byte ptr [si+6],80h
		jc	sub01_phase_inc			; Jump if carry Set
		jmp	sub01_finalize

sub01_phase_inc:
				inc	byte ptr [si+6]
				and	byte ptr [si+6],7
				test	byte ptr [si+6],3
				jz	sub01_check_x_lo			; Jump if zero
				jmp	sub01_finalize

sub01_check_x_lo:
				mov	al,10h
				cmp	al,[si+3]
				jb	sub01_check_x_hi			; Jump if below
				call	phase_step_fwd
				jnc	sub01_face_west			; Jump if carry=0
				jmp	sub01_finalize

sub01_face_west:
				or	byte ptr [si+5],80h
				jmp	sub01_finalize

sub01_check_x_hi:
				call	phase_step_back
				jnc	sub01_face_east			; Jump if carry=0
				jmp	sub01_finalize

sub01_face_east:
				and	byte ptr [si+5],7Fh
				jmp	sub01_finalize

sub01_state0_alt:
				call	word ptr cs:meda_rng_fn_ptr
				and	al,0C0h
				jnz	sub01_phase_inc			; Jump if not zero
			mov	al,[si+6]
			not	al
			and	al,3
			jnz	sub01_phase_inc			; Jump if not zero
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],8
		jmp	short sub01_finalize

sub01_state0_set:
		add	byte ptr [si+6],80h
		jnc	sub01_finalize			; Jump if carry=0
		inc	byte ptr [si+6]
		mov	al,[si+6]
		and	al,0Fh
		cmp	al,0Bh
		je	sub01_advance_xy			; Jump if equal
		cmp	al,0Ch
		jne	sub01_finalize			; Jump if not equal
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],3
		jmp	short sub01_finalize

sub01_advance_xy:
		mov	al,[si+3]
		mov	ds:meda_tbl_g,al
		inc	al
		mov	ds:meda_tbl_e,al
		mov	al,[si+2]
		inc	al
		mov	ds:meda_tbl_h,al
		mov	ds:meda_tbl_f,al
		mov	bx,0A41Bh
		test	byte ptr [si+5],80h
		jnz	sub01_xlat_call			; Jump if not zero
		mov	bx,0A428h

sub01_xlat_call:
		call	word ptr cs:ai_attack_fn
		jmp	short sub01_finalize
		db	 00h, 00h,0B1h, 00h, 14h, 00h
		db	 28h, 00h
		db	7 dup (0)
		db	0B1h, 00h, 14h, 04h, 28h, 00h
		db	 00h, 00h, 00h, 00h, 00h

sub01_hide_branch:
		mov	al,[si+5]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:ai_hide_fn

sub01_finalize:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn

meda_ai_main	endp

phase_step_fwd		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	phase_step_fwd_chk			; Jump if carry=0
		retn

phase_step_fwd_chk:
		call	collide_check_fwd
		jnc	phase_step_fwd_apply			; Jump if carry=0
		retn

phase_step_fwd_apply:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:gvar_proj_cnt
		sub	ax,bx
		jnz	phase_step_fwd_wrap			; Jump if not zero
		xchg	bx,ax

phase_step_fwd_wrap:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

phase_step_fwd		endp

collide_check_fwd		proc	near
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_g
		inc	di
		inc	di
		mov	cx,4

collide_fwd_loop:
			mov	al,[di]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jz	collide_fwd_iter			; Jump if zero
			retn

collide_fwd_iter:
			xchg	si,di
			add	si,24h
			call	word ptr cs:ai_fn_tbl_h
			xchg	si,di
			loop	collide_fwd_loop		; Loop if cx > 0

		xchg	si,di
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

collide_check_fwd		endp

phase_step_back		proc	near
		cmp	byte ptr [si+3],2
		jae	phase_step_back_chk			; Jump if above or =
		retn

phase_step_back_chk:
		call	collide_check_back
		jnc	phase_step_back_apply			; Jump if carry=0
		retn

phase_step_back_apply:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	phase_step_back_wrap			; Jump if not equal
		mov	ax,ds:gvar_proj_cnt
		dec	ax

phase_step_back_wrap:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

phase_step_back		endp

collide_check_back		proc	near
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_g
		dec	di
		mov	cx,4

collide_back_loop:
			mov	al,[di]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jz	collide_back_iter			; Jump if zero
			retn

collide_back_iter:
			xchg	si,di
			add	si,24h
			call	word ptr cs:ai_fn_tbl_h
			xchg	si,di
			loop	collide_back_loop		; Loop if cx > 0

		dec	di
		xchg	si,di
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

collide_check_back		endp

sub01_collide_outer		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	sub01_collide_test1			; Jump if not zero
		retn

sub01_collide_test1:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	sub01_collide_test2			; Jump if not zero
		retn

sub01_collide_test2:
		call	sub01_collide_inner
		jnc	sub01_collide_apply			; Jump if carry=0
		retn

sub01_collide_apply:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn

sub01_collide_outer		endp

sub01_collide_inner		proc	near
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_g
		xchg	si,di
		add	si,offset meda_collide_marker
		call	word ptr cs:ai_fn_tbl_h
		xchg	si,di
		mov	cx,2

sub01_collide_loop:
			mov	al,[di]
			call	word ptr cs:ai_fn_tbl_j
			stc				; Set carry flag
			jz	sub01_collide_step			; Jump if zero
			retn

sub01_collide_step:
			inc	di
			loop	sub01_collide_loop		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn

sub01_collide_inner		endp

distance_check_4		proc	near
		mov	al,ds:gvar_frame_cnt
		sub	al,[si+2]
		jnc	dist4_abs_done			; Jump if carry=0
		neg	al

dist4_abs_done:
		cmp	al,4
		mov	al,0FFh
		jc	dist4_in_range			; Jump if carry Set
		retn

dist4_in_range:
		cmp	byte ptr [si+3],11h
		jae	dist4_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dist4_clear_carry			; Jump if zero
		retn

dist4_clear_carry:
		clc				; Clear carry flag
		retn

dist4_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dist4_far_clear			; Jump if not zero
		retn

dist4_far_clear:
		clc				; Clear carry flag
		retn

distance_check_4		endp

; ----------------------------------------------------------------
; sub02_handler  -- AI sub-state 2 dispatch entry (DS-table 0xA34D -> 0xA5F1)
; Reached via 'jmp word ptr ds:[bx+0xA345]' in meda_ai_main where
; bx = ([si+4] & 0xF) * 2 selects the sub-state. Entry preroll:
;   test [si+8], FFh ; jnz +4 ; mov [si+8], 10h  (seed cooldown)
; falling through into sub02_main.
; ----------------------------------------------------------------

sub02_handler:
		test	byte ptr [si+8],0FFh
		jnz	sub02_main			; Jump if not zero
		mov	byte ptr [si+8],10h

sub02_main:
		test	byte ptr [si+5],20h	; ' '
		jnz	sub02_visible			; Jump if not zero
		jmp	sub02_finalize

sub02_visible:
		mov	al,[si+5]
		and	al,1Fh
		cmp	al,4
		jne	sub02_anim_check_5			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

sub02_anim_check_5:
		cmp	al,5
		jne	sub02_anim_check_8			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

sub02_anim_check_8:
		cmp	al,8
		jne	sub02_anim_check_1			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

sub02_anim_check_1:
		cmp	al,1
		jne	sub02_clear_vis			; Jump if not equal
		cmp	meda_anim_state_ref,6
		jne	sub02_clear_vis			; Jump if not equal
		jmp	word ptr cs:ai_hide_fn

sub02_clear_vis:
		and	byte ptr [si+5],0DFh
		test	byte ptr [si+9],2
		jz	sub02_call_27			; Jump if zero
		jmp	sub02_finalize

sub02_call_27:
		call	word ptr cs:ai_fn_tbl_k
		jnc	sub02_after_27			; Jump if carry=0
		jmp	sub02_finalize

sub02_after_27:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:ai_fn_tbl_g
		mov	bx,di
		pop	di
		test	byte ptr [si+5],80h
		jnz	sub02_west_branch			; Jump if not zero
		mov	al,[si+3]
		or	al,al			; Zero ?
		jns	sub02_neg_test			; Jump if not sign
		jmp	sub02_finalize

sub02_neg_test:
		cmp	al,20h			; ' '
		jb	sub02_decr_loop			; Jump if below
		jmp	sub02_finalize

sub02_decr_loop:
		inc	bx
		inc	bx
		xchg	bx,si
		sub	si,24h
		call	word ptr cs:ai_fn_tbl_i
		mov	cx,3

sub02_east_scan:
			lodsb				; String [si] to al
			call	word ptr cs:ai_fn_tbl_j
			xchg	bx,si
			jz	sub02_east_scan_2			; Jump if zero
			jmp	sub02_finalize

sub02_east_scan_2:
			xchg	bx,si
			lodsb				; String [si] to al
			call	word ptr cs:ai_fn_tbl_j
			xchg	bx,si
			jz	sub02_east_scan_3			; Jump if zero
			jmp	sub02_finalize

sub02_east_scan_3:
			xchg	bx,si
			add	si,22h
			call	word ptr cs:ai_fn_tbl_h
			loop	sub02_east_scan		; Loop if cx > 0

		sub	si,48h
		call	word ptr cs:ai_fn_tbl_i
		xchg	si,bx
		push	dx
		or	dl,80h
		xchg	[bx],dl
		pop	bx
		xor	bh,bh			; Zero register
		mov	ds:enemy_data_ext[bx],dl
		mov	dl,bl
		mov	bx,[si]
		inc	bx
		inc	bx
		mov	ax,ds:gvar_proj_cnt
		dec	ax
		sub	ax,bx
		jnc	sub02_east_apply			; Jump if carry=0
		not	ax
		xchg	bx,ax

sub02_east_apply:
		mov	[di],bx
		mov	al,[si+3]
		add	al,2
		mov	[di+3],al
		jmp	short sub02_emit_clone

sub02_west_branch:
		mov	al,[si+3]
		or	al,al			; Zero ?
		jns	sub02_west_chk1			; Jump if not sign
		jmp	sub02_finalize

sub02_west_chk1:
		cmp	al,4
		jae	sub02_west_iter			; Jump if above or =
		jmp	sub02_finalize

sub02_west_iter:
		dec	bx
		dec	bx
		xchg	bx,si
		sub	si,25h
		call	word ptr cs:ai_fn_tbl_i
		mov	cx,3

sub02_west_scan:
			lodsb				; String [si] to al
			call	word ptr cs:ai_fn_tbl_j
			xchg	bx,si
			jnz	sub02_finalize			; Jump if not zero
			xchg	bx,si
			lodsb				; String [si] to al
			call	word ptr cs:ai_fn_tbl_j
			xchg	bx,si
			jnz	sub02_finalize			; Jump if not zero
			xchg	bx,si
			add	si,22h
			call	word ptr cs:ai_fn_tbl_h
			loop	sub02_west_scan		; Loop if cx > 0

		sub	si,47h
		call	word ptr cs:ai_fn_tbl_i
		xchg	si,bx
		push	dx
		or	dl,80h
		xchg	[bx],dl
		pop	bx
		xor	bh,bh			; Zero register
		mov	ds:enemy_data_ext[bx],dl
		mov	dl,bl
		mov	bx,[si]
		sub	bx,2
		jnc	sub02_west_apply			; Jump if carry=0
		add	bx,ds:gvar_proj_cnt

sub02_west_apply:
		mov	[di],bx
		mov	al,[si+3]
		sub	al,2
		mov	[di+3],al

sub02_emit_clone:
		mov	al,[si+2]
		mov	[di+2],al
		mov	al,[si+4]
		or	al,60h			; '`'
		mov	[di+4],al
		mov	al,[si+5]
		and	al,80h
		mov	[di+5],al
		mov	byte ptr [di+6],4
		mov	al,[si+7]
		mov	[di+7],al
		mov	byte ptr [di+8],0
		mov	byte ptr [di+9],2
		mov	byte ptr [di+0Ah],0
		cmp	ds:gvar_sub_frame,dl
		jb	sub02_set_phase1			; Jump if below
		retn

sub02_set_phase1:
		or	byte ptr [si+9],1

sub02_finalize:
		call	word ptr cs:ai_fn_tbl_l
		mov	al,[si+9]
		and	byte ptr [si+9],0FEh
		test	al,1
		jz	sub02_phase_advance			; Jump if zero
		retn

sub02_phase_advance:
		test	byte ptr [si+9],2
		jnz	sub02_phase_inc_lo			; Jump if not zero
		mov	al,[si+6]
		inc	al
		and	al,0F3h
		mov	[si+6],al
		call	word ptr cs:ai_fn_tbl_f
		jc	sub02_phase_check			; Jump if carry Set
		retn

sub02_phase_check:
		mov	al,[si+6]
		sub	al,10h
		mov	ah,al
		mov	[si+6],al
		and	al,0F0h
		jz	sub02_phase_match			; Jump if zero
		retn

sub02_phase_match:
		or	ah,40h			; '@'
		mov	[si+6],ah
		mov	al,ds:gvar_frame_cnt
		cmp	al,[si+2]
		je	sub02_match_eq			; Jump if equal
		inc	al
		and	al,3Fh			; '?'
		cmp	al,[si+2]
		je	sub02_match_eq			; Jump if equal
		test	byte ptr [si+5],80h
		jnz	sub02_dir_set			; Jump if not zero
		jmp	short sub02_match_chk_dir

sub02_match_eq:
		mov	al,11h
		cmp	al,[si+3]
		jae	sub02_dir_set			; Jump if above or =

sub02_match_chk_dir:
		and	byte ptr [si+5],7Fh
		call	word ptr cs:ai_fn_tbl_e
		jc	sub02_dir_set			; Jump if carry Set
		retn

sub02_dir_set:
		or	byte ptr [si+5],80h
		call	word ptr cs:ai_fn_tbl_a
		jc	sub02_dir_clear			; Jump if carry Set
		retn

sub02_dir_clear:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:ai_fn_tbl_e

sub02_phase_inc_lo:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	sub02_phase_done			; Jump if zero
		retn

sub02_phase_done:
		and	byte ptr [si+9],0FDh
		and	byte ptr [si+4],9Fh
		retn

; ----------------------------------------------------------------
; sub03_handler  -- AI sub-state 3 dispatch entry (DS-table 0xA34F -> 0xA812)
; Same dispatch contract as sub02_handler. Entry preroll seeds
; the [si+8] cooldown to 8 if zero.
; ----------------------------------------------------------------

sub03_handler:
		test	byte ptr [si+8],0FFh
		jnz	sub03_main			; Jump if not zero
		mov	byte ptr [si+8],8

sub03_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub03_visible			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

sub03_visible:
		call	word ptr cs:ai_fn_tbl_l
		test	byte ptr [si+9],4
		jz	sub03_no_bit2			; Jump if zero
		jmp	sub03_alt_branch

sub03_no_bit2:
		call	word ptr cs:ai_fn_tbl_f
		jc	sub03_after_call_f			; Jump if carry Set
		retn

sub03_after_call_f:
		test	byte ptr [si+9],2
		jz	sub03_no_bit1			; Jump if zero
		mov	al,[si+6]
		and	al,7
		jnz	sub03_phase_test_4			; Jump if not zero
		and	byte ptr [si+9],0FEh

sub03_phase_test_4:
		cmp	al,4
		jne	sub03_phase_test_1			; Jump if not equal
		or	byte ptr [si+9],1

sub03_phase_test_1:
		test	byte ptr [si+9],1
		jnz	sub03_phase_dec			; Jump if not zero
		inc	byte ptr [si+6]
		jmp	short sub03_phase_apply

sub03_phase_dec:
		dec	byte ptr [si+6]

sub03_phase_apply:
		mov	al,[si+6]
		and	al,7
		jnz	sub03_phase_branch			; Jump if not zero
		and	byte ptr [si+5],7Fh
		jmp	short sub03_call_dist4

sub03_phase_branch:
		cmp	al,4
		je	sub03_set_dir			; Jump if equal
		retn

sub03_set_dir:
		or	byte ptr [si+5],80h

sub03_call_dist4:
		call	distance_check_4
		jnc	sub03_dist4_done			; Jump if carry=0
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn

sub03_dist4_done:
		call	word ptr cs:meda_rng_fn_ptr
		and	al,80h
		jnz	sub03_set_state0			; Jump if not zero
		retn

sub03_set_state0:
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn

sub03_no_bit1:
		call	distance_check_4
		jnc	sub03_aux_inc			; Jump if carry=0
		mov	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn

sub03_aux_inc:
		inc	byte ptr [si+0Ah]
		and	al,7
		jnz	sub03_check_carry			; Jump if not zero
		mov	byte ptr [si+9],2

sub03_check_carry:
		add	byte ptr [si+6],80h
		jc	sub03_dir_test			; Jump if carry Set
		retn

sub03_dir_test:
			test	byte ptr [si+5],80h
			jnz	sub03_dir_east			; Jump if not zero
			call	word ptr cs:ai_fn_tbl_e
			jc	sub03_dir_west			; Jump if carry Set
			retn

sub03_dir_west:
			mov	byte ptr [si+9],2
			retn

sub03_dir_east:
			call	word ptr cs:ai_fn_tbl_a
			jc	sub03_set_state2			; Jump if carry Set
			retn

sub03_set_state2:
			mov	byte ptr [si+9],2
			retn

sub03_alt_branch:
			inc	byte ptr [si+0Ah]
			cmp	byte ptr [si+0Ah],5
			jb	sub03_dir_test			; Jump if below
		mov	byte ptr [si+6],5
		test	byte ptr [si+5],80h
		jnz	sub03_alt_set2_b			; Jump if not zero
		call	word ptr cs:ai_fn_tbl_e
		call	word ptr cs:ai_fn_tbl_e
		jc	sub03_alt_set2_a			; Jump if carry Set
		retn

sub03_alt_set2_a:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],0
		retn

sub03_alt_set2_b:
		call	word ptr cs:ai_fn_tbl_a
		call	word ptr cs:ai_fn_tbl_a
		jc	sub03_alt_set2_c			; Jump if carry Set
		retn

sub03_alt_set2_c:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],4
		retn

; ----------------------------------------------------------------
; sub04_handler  -- AI sub-state 4 dispatch entry (DS-table 0xA351 -> 0xA91A)
; Same dispatch contract; preroll seeds the [si+8] cooldown to 8.
; ----------------------------------------------------------------

sub04_handler:
		test	byte ptr [si+8],0FFh
		jnz	sub04_main			; Jump if not zero
		mov	byte ptr [si+8],8

sub04_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub04_visible			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

sub04_visible:
		call	word ptr cs:ai_fn_tbl_l
		test	byte ptr [si+9],1
		jnz	sub04_branch_b			; Jump if not zero
		test	byte ptr [si+9],2
		jnz	sub04_branch_c			; Jump if not zero
		mov	al,0Fh
		cmp	al,[si+3]
		jae	sub04_anim_step			; Jump if above or =
		mov	al,12h
		cmp	al,[si+3]
		jb	sub04_anim_step			; Jump if below
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short sub04_anim_or

sub04_anim_step:
		mov	al,[si+6]
		inc	al
		and	al,3
		and	byte ptr [si+6],0F0h
		or	[si+6],al

sub04_anim_or:
		call	word ptr cs:ai_fn_tbl_c
		add	byte ptr [si+6],80h
		jc	sub04_phase_test			; Jump if carry Set
		retn

sub04_phase_test:
		mov	al,10h
		cmp	al,[si+3]
		jb	sub04_call_e			; Jump if below
		call	word ptr cs:ai_fn_tbl_a
		jc	sub04_branch_a			; Jump if carry Set
		retn

sub04_branch_a:
		jmp	word ptr cs:ai_fn_tbl_e

sub04_call_e:
		call	word ptr cs:ai_fn_tbl_e
		jc	sub04_call_e2			; Jump if carry Set
		retn

sub04_call_e2:
		jmp	word ptr cs:ai_fn_tbl_a

sub04_branch_b:
		mov	al,[si+6]
		and	al,7
		cmp	al,5
		jae	sub04_call_f			; Jump if above or =
		inc	byte ptr [si+6]
		retn

sub04_call_f:
		call	word ptr cs:ai_fn_tbl_f
		call	word ptr cs:ai_fn_tbl_f
		jc	sub04_anim_inc			; Jump if carry Set
		retn

sub04_anim_inc:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	sub04_set_state2			; Jump if zero
		retn

sub04_set_state2:
		mov	byte ptr [si+9],2
		retn

sub04_branch_c:
		mov	al,10h
		cmp	al,[si+3]
		jb	sub04_low_anim			; Jump if below
		call	word ptr cs:ai_fn_tbl_c
		call	word ptr cs:ai_fn_tbl_b
		jc	sub04_call_c			; Jump if carry Set
		retn

sub04_call_c:
		call	word ptr cs:ai_fn_tbl_c
		jc	sub04_after_c			; Jump if carry Set
		retn

sub04_after_c:
		and	byte ptr [si+9],0FDh
		retn

sub04_low_anim:
		call	word ptr cs:ai_fn_tbl_c
		call	word ptr cs:ai_fn_tbl_d
		jc	sub04_low_anim_b			; Jump if carry Set
		retn

sub04_low_anim_b:
		call	word ptr cs:ai_fn_tbl_c
		jc	sub04_clear_bit1			; Jump if carry Set
		retn

sub04_clear_bit1:
		and	byte ptr [si+9],0FDh
		retn

seg_a		ends

		end	start
