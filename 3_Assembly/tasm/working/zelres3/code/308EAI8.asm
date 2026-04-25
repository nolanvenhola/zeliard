
PAGE  59,132

;==========================================================================
;
;  308EAI8.BIN - Enemy AI Behavior Type 8 (zelres3 chunk 9)
;
;  Enemy AI handler loaded by 200FIGHT.asm and paired with DRGN/AKMA
;  boss-class enemy sprite sets.  Behavior type 8 is the aggressive
;  attack variant: multi-pass advance with rapid fire, range-gated
;  projectile spawning, and alternating fire/retreat cycles.
;
;  Enemy record layout (SI-relative) shared by all EAI modules:
;    [si+0]    x-position word
;    [si+2]    x-tile (col index)
;    [si+3]    y-tile (row index, used in aim tests)
;    [si+4]    state index (low nibble selects sub-handler via DS table)
;    [si+5]    flags byte B (80h = facing, 20h = hidden, 60h = visible)
;    [si+6]    frame counter / phase
;    [si+8]    cooldown / init-timer
;    [si+9]    AI state bits (1=advancing, 2=return, 4=attack, 70h=phase mask)
;    [si+0Ah]  sub-phase counter
;    [si+10h..16h]  echo/render fields copied back at retn
;
;  Dispatch via DS word-pointer table at file offset 0x02CB
;  (jumped to via 'jmp ds:[bx+0xA2C7]' in dispatch prologue, where
;  bx = ([si+4]&0xF)*2).  Sub-state handlers eai8_subNN_handler
;  implement the per-state behaviour.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; Fight-engine callback vector table (in game_seg DS at 6004h..603Ah).

fight_cb_range		equ	6004h			; aim/range/hit check callback
fight_cb_step_neg	equ	6008h			; step -x callback
fight_cb_map_fwd	equ	600Ch			; map-fwd move callback
fight_cb_step_pos	equ	6010h			; step +x callback
fight_cb_blocked	equ	6014h			; blocked/obstacle query
fight_cb_record_ofs	equ	6028h			; compute record addr from tile
fight_cb_mark_adj	equ	602Ah			; mark adjacent cell busy
fight_cb_tile_index	equ	602Ch			; tile-index conversion
fight_cb_cmp_tile	equ	602Eh			; compare tile type
fight_cb_fire		equ	6034h			; fire / attack dispatch
fight_cb_despawn	equ	603Ah			; clear/remove enemy

; Shared enemy spawn/state globals in game_seg DS.

enemy_spawn_tile_hi	equ	0A666h			; spawn-cell row (phase hi)
enemy_spawn_col_hi	equ	0A667h			; spawn-cell col (phase hi)
enemy_spawn_tile_lo	equ	0A673h			; spawn-cell row (phase lo)
enemy_spawn_col_lo	equ	0A674h			; spawn-cell col (phase lo)
dir_xlat_alt		equ	0A71Bh			; direction lookup table (alt facing)
dir_xlat_table		equ	0A723h			; direction lookup table (xlat base)
fight_state_max		equ	0C002h			; max state index (for wrap)
gvar_hero_x		equ	0FF35h			; hero X tile position (global)
gvar_proj_flag		equ	0FFA2h			; projectile spawn flag

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

eai8_main	proc	far

start:
		xchg	bx,ax
		pop	es
		add	[bx+si],al
		mov	cx,0A2h
		add	[bx+si],al
		db	00h, 9Fh, 0A2h, 0FFh	; add ds:gvar_proj_flag[bx],bl (force disp16; TASM picks disp8)
		db	0FFh,0FFh,0FFh,0FFh, 00h, 00h
		db	 00h,0A0h,0A0h
		db	 3Ch, 50h, 50h
		db	27 dup (0)
		db	0B0h,0A0h,0FBh,0A0h, 46h,0A1h
		db	0A5h,0A1h,0E6h,0A1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0ECh,0A0h
		db	 37h,0A1h, 96h,0A1h,0D7h,0A1h
		db	0FAh,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 86h,0A2h, 00h, 00h
		db	 09h,0A2h, 54h,0A2h, 18h,0A2h
		db	 2Ch,0A2h, 7Ch,0A2h, 81h,0A2h
		db	 72h,0A2h, 77h,0A2h, 00h, 00h
		db	 40h,0A2h, 9Ah,0A2h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0CEh,0A0h
		db	 19h,0A1h, 6Eh,0A1h,0BEh,0A1h
		db	0E6h,0A1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0ECh,0A0h, 37h,0A1h
		db	 96h,0A1h,0D7h,0A1h,0FAh,0A1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 86h,0A2h, 00h, 00h, 09h,0A2h
		db	 54h,0A2h, 18h,0A2h, 2Ch,0A2h
		db	 7Ch,0A2h, 81h,0A2h, 72h,0A2h
		db	 77h,0A2h, 00h, 00h, 40h,0A2h
		db	 9Ah,0A2h
		db	7 dup (0)
		db	 01h, 02h, 03h, 04h, 00h, 01h
		db	 02h, 03h, 04h, 00h, 01h, 02h
		db	 03h, 04h, 00h, 01h, 02h, 11h
		db	 04h, 00h, 01h, 02h, 16h, 04h
		db	 00h, 01h, 02h, 1Bh, 04h, 00h
		db	20h
		db	'!"#', 0
		db	' !"#', 0
		db	' !"#', 0
		db	' !"0', 0
		db	' !"5', 0
		db	' !":', 0
		db	'?@AB'
		db	 02h, 47h, 48h, 49h, 4Ah, 02h
		db	 4Fh, 50h, 51h, 52h, 02h, 05h
		db	 06h, 07h, 08h, 02h, 09h, 0Ah
		db	 0Bh, 0Ch, 02h, 0Dh, 0Eh, 0Fh
		db	 10h, 02h, 12h, 13h, 14h, 15h
		db	 02h, 17h, 18h, 19h, 1Ah, 02h
		db	 1Ch
eai8_rng_fn_ptr		dw	1E1Dh
		db	 1Fh, 02h, 24h, 25h, 26h, 27h
		db	 02h, 28h, 29h, 2Ah, 2Bh, 02h
		db	 2Ch, 2Dh, 2Eh, 2Fh, 02h, 31h
		db	 32h, 33h, 34h, 02h, 36h, 37h
		db	 38h, 39h, 02h, 3Bh, 3Ch, 3Dh
		db	 3Eh, 00h, 43h, 44h, 45h, 46h
		db	 02h, 4Bh, 4Ch, 4Dh, 4Eh, 02h
		db	 53h, 54h
		db	'UV', 0
		db	'WXYZ', 0
		db	'[\]^', 0
		db	'_`ab', 0
		db	'cdef', 0
		db	'WXYZ', 0
		db	'[\]^', 0
		db	'ghij', 0
		db	'klmn', 0
		db	'opqr', 0
		db	'stuv', 0
		db	'wxyz', 0
		db	'{|}~', 0
		db	'opqr', 0
		db	'stuv', 0
		db	 7Fh, 80h, 81h, 82h, 00h, 83h
		db	 84h, 85h, 86h, 00h, 87h, 88h
		db	 89h, 8Ah, 00h, 8Bh, 8Ch, 8Dh
		db	 8Eh, 02h, 8Fh, 90h, 91h, 92h
		db	 00h, 93h, 94h, 95h, 96h, 00h
		db	 97h, 98h, 99h, 9Ah, 00h, 9Bh
		db	 9Ch, 9Dh, 9Eh, 00h,0A3h,0A4h
		db	 95h, 96h, 00h,0A5h,0A6h, 95h
		db	 96h, 00h, 93h, 94h, 95h, 96h
		db	 00h, 97h, 98h, 99h, 9Ah, 00h
		db	 9Bh, 9Ch, 9Dh, 9Eh, 00h, 9Fh
		db	0A0h, 95h, 96h, 00h,0A1h,0A2h
		db	 95h, 96h, 00h,0A7h,0A8h, 95h
		db	 96h, 00h,0A9h,0AAh,0ABh,0ACh
		db	 00h,0ADh,0AEh,0AFh,0B0h, 02h
		db	0B1h,0B2h,0B3h,0B4h, 02h,0B5h
		db	0B6h,0B7h,0B8h, 02h,0B9h,0BAh
		db	0BBh,0BCh, 02h,0BDh,0BEh,0BFh
		db	0C0h, 02h,0C1h,0C2h,0C3h,0C4h
		db	 02h,0C5h,0C6h,0C7h,0C8h, 02h
		db	0C9h,0CAh, 00h, 00h, 01h,0CBh
		db	0CCh,0CDh,0CEh, 01h,0CFh,0D0h
		db	0D1h,0D2h, 01h,0D3h,0D4h,0D5h
		db	0D6h, 00h,0D7h,0D8h,0D9h,0DAh
		db	 00h,0DBh,0DCh,0DDh,0DEh, 00h
		db	0DFh,0E0h,0E1h,0E2h, 00h,0DBh
		db	0DCh,0DDh,0DEh, 02h,0D7h,0D8h
		db	0D9h,0DAh, 02h,0DBh,0DCh,0DDh
		db	0DEh, 02h,0DFh,0E0h,0E1h,0E2h
		db	 02h,0DBh,0DCh,0DDh,0DEh, 01h
		db	0D7h,0D8h,0D9h,0DAh, 01h,0DBh
		db	0DCh,0DDh,0DEh, 01h,0DFh,0E0h
		db	0E1h,0E2h, 01h,0DBh,0DCh,0DDh
		db	0DEh, 00h,0E3h,0E4h,0E5h,0E6h
		db	 00h,0E3h,0E4h,0E5h,0E6h, 00h
		db	0E3h,0E4h,0E5h,0E6h, 00h,0E3h
		db	0E4h,0E5h,0E6h, 00h,0E3h,0E4h
		db	0E5h,0E6h, 00h,0E3h,0E4h,0E5h
		db	0E6h, 00h,0EBh,0ECh,0EDh,0EEh
		db	 02h,0EBh,0ECh,0EDh,0EEh, 01h
		db	0E7h,0E8h,0E9h,0EAh, 01h,0EFh
		db	0F0h,0F1h,0F2h, 02h,0F3h,0F3h
		db	0F3h,0F3h, 02h,0F4h,0F4h,0F5h
		db	0F5h, 02h,0F6h, 00h,0F3h,0F7h
		db	 02h, 00h, 00h,0F7h,0F8h, 02h
		db	0F9h,0FAh,0FBh,0FCh,0A9h,0A2h
		db	0A9h,0A2h,0ADh,0A2h,0B1h,0A2h
		db	0B5h,0A2h, 0Bh, 0Bh, 0Bh, 0Bh
		db	 05h, 05h, 00h, 00h, 0Bh, 0Bh
		db	 05h, 05h, 0Bh, 05h, 00h, 00h
		db	 8Ah, 5Ch, 04h, 80h,0E3h, 0Fh
		db	 32h,0FFh, 03h,0DBh,0FFh,0A7h
		db	0C7h,0A2h,0D2h,0A2h,0D1h,0A2h
		db	 83h,0A4h, 38h,0A5h, 8Fh,0A6h
		db	0C3h,0F6h, 44h, 08h,0FFh, 75h
		db	 04h,0C6h, 44h, 08h, 64h,0F6h
		db	 44h, 05h, 20h, 74h, 03h,0E9h
		db	 80h, 00h, 80h, 64h, 15h,0BFh
		db	0F6h, 44h, 09h, 01h, 75h, 2Ah
		db	 80h, 44h, 06h, 80h, 73h, 03h
		db	0E8h, 4Bh, 00h,0C6h, 44h, 0Ah
		db	 00h,0E8h, 5Eh, 04h, 72h, 0Dh
		db	 3Ch,0FFh, 74h, 4Dh, 80h, 64h
		db	 05h, 7Fh, 08h, 44h, 05h,0EBh
		db	 44h, 80h,0FCh, 0Fh, 73h, 3Fh
		db	 80h, 4Ch, 09h, 01h,0EBh, 39h
		db	0FEh, 44h, 0Ah, 8Ah, 44h, 0Ah
		db	 3Ch, 10h, 74h, 1Ah,0F6h, 44h
		db	 05h, 80h, 75h, 0Ah,0E8h,0D2h
		db	 00h, 72h, 0Fh,0E8h, 12h, 00h
		db	0EBh, 1Fh,0E8h, 43h, 00h, 72h
		db	 05h,0E8h, 08h, 00h,0EBh, 15h
		db	 80h, 64h, 09h,0FEh,0EBh, 0Fh
		db	0FEh, 44h, 06h, 80h, 7Ch, 06h
		db	 06h, 73h, 01h,0C3h

eai8_phase_reset_stub:				; dispatched via DS table @ 0xA2CB (idx 1)
		mov	byte ptr [si+6],0
		retn

; ----------------------------------------------------------------
; eai8_finalize  -- export sub-state to render fields ([si+16h] / [si+15h]).
; Called via tail-jmp from sub-handlers; copies frame to render slot
; and merges facing flag into [si+15h]'s low 7 bits.
; ----------------------------------------------------------------

eai8_finalize:				; * No entry point in static analysis (tail-call from handlers)
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		and	byte ptr [si+15h],7Fh
		or	[si+15h],al
		retn

; ----------------------------------------------------------------
; eai8_hide_branch  -- common 'enemy hidden' tail.  Sets hidden flags
; in [si+5]/[si+15h] and tail-jumps to fight_cb_fire.
; ----------------------------------------------------------------

eai8_hide_branch:				; * No entry point in static analysis (tail-call from handlers)
		mov	al,[si+5]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:fight_cb_fire

; ----------------------------------------------------------------
; phase_step_fwd  -- advance enemy by one tile in +x direction
; if [si+3] > 0x22 and forward tile is clear; wraps around at
; fight_state_max boundary.  Returns CF=0 on success, CF=1 on block.
; ----------------------------------------------------------------

phase_step_fwd:				; * No entry point in static analysis (called from sub-handlers)
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	psf_chk			; Jump if carry=0
		retn

psf_chk:
		call	collide_check_fwd
		jnc	psf_apply			; Jump if carry=0
		retn

psf_apply:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:fight_state_max
		sub	ax,bx
		jnz	psf_wrap			; Jump if not zero
		xchg	bx,ax

psf_wrap:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

eai8_main	endp

collide_check_fwd		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		inc	di
		inc	di
		mov	cx,4

collide_fwd_loop:
			mov	al,[di]
			call	word ptr cs:fight_cb_cmp_tile
			stc				; Set carry flag
			jz	collide_fwd_iter			; Jump if zero
			retn

collide_fwd_iter:
			xchg	si,di
			add	si,24h
			call	word ptr cs:fight_cb_mark_adj
			xchg	si,di
			loop	collide_fwd_loop		; Loop if cx > 0

		xchg	si,di
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

collide_check_fwd		endp

; ----------------------------------------------------------------
; phase_step_back  -- step enemy by one tile in -x direction
; if [si+3] >= 2 and reverse tile is clear; wraps at state 0.
; Returns CF=0 on success, CF=1 on block.
; ----------------------------------------------------------------

phase_step_back:				; * No entry point in static analysis (called from sub-handlers)
		cmp	byte ptr [si+3],2
		jae	psb_chk			; Jump if above or =
		retn

psb_chk:
		call	collide_check_back
		jnc	psb_apply			; Jump if carry=0
		retn

psb_apply:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	psb_wrap			; Jump if not equal
		mov	ax,ds:fight_state_max
		dec	ax

psb_wrap:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

collide_check_back		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		dec	di
		mov	cx,4

collide_back_loop:
			mov	al,[di]
			call	word ptr cs:fight_cb_cmp_tile
			stc				; Set carry flag
			jz	collide_back_iter			; Jump if zero
			retn

collide_back_iter:
			xchg	si,di
			add	si,24h
			call	word ptr cs:fight_cb_mark_adj
			xchg	si,di
			loop	collide_back_loop		; Loop if cx > 0

		dec	di
		xchg	si,di
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		mov	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

collide_check_back		endp

; ----------------------------------------------------------------
; eai8_sub01_handler  -- AI sub-state 1 dispatch entry (DS table @ 0xA2CF).
; Cooldown-seed prologue (init [si+8]=0x30), visibility check, blocked
; check, then range-gated facing/step state machine using [si+9].1.
; ----------------------------------------------------------------

eai8_sub01_handler:				; * No entry point in static analysis (dispatched via DS table)
		test	byte ptr [si+8],0FFh
		jnz	sub01_main			; Jump if not zero
		mov	byte ptr [si+8],30h	; '0'

sub01_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub01_blocked_chk			; Jump if zero
		jmp	word ptr cs:fight_cb_fire

sub01_blocked_chk:
		call	word ptr cs:fight_cb_blocked
		jc	sub01_state_dispatch			; Jump if carry Set
		retn

sub01_state_dispatch:
		test	byte ptr [si+9],1
		jnz	sub01_state1_active			; Jump if not zero
		call	distance_check_5
		sbb	ah,ah
		neg	ah
		mov	[si+9],ah
		cmp	al,0FFh
		je	sub01_phase_inc			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al

sub01_phase_inc:
		add	byte ptr [si+6],80h
		jc	sub01_step_branch			; Jump if carry Set
		retn

sub01_step_branch:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+5],80h
		jnz	sub01_step_neg_path			; Jump if not zero
		call	word ptr cs:fight_cb_step_pos
		jc	sub01_step_blocked			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn

sub01_step_neg_path:
		call	word ptr cs:fight_cb_step_neg
		jc	sub01_step_blocked			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn

sub01_step_blocked:
		mov	byte ptr [si+9],0
		xor	byte ptr [si+5],80h
		retn

sub01_state1_active:
		dec	byte ptr [si+0Ah]
		test	byte ptr [si+0Ah],3
		jnz	sub01_active_step			; Jump if not zero
		call	distance_check_5
		sbb	ah,ah
		neg	ah
		mov	[si+9],ah
		cmp	al,0FFh
		je	sub01_active_step			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al

sub01_active_step:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+5],80h
		jnz	sub01_active_neg_path			; Jump if not zero
		call	word ptr cs:fight_cb_step_pos
		jc	sub01_active_blocked			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn

sub01_active_neg_path:
		call	word ptr cs:fight_cb_step_neg
		jc	sub01_active_blocked			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn

sub01_active_blocked:
		mov	byte ptr [si+9],0
		retn
; ----------------------------------------------------------------
; eai8_sub02_handler  -- AI sub-state 2 dispatch entry (DS table @ 0xA2D1).
; Cooldown-seed prologue (init [si+8]=0x40), visibility/blocked checks,
; then phase machine using [si+9].4 (attack), [si+9].1 (advance),
; [si+9].2 (return) - implements multi-pass strafe-attack pattern.
; ----------------------------------------------------------------

eai8_sub02_handler:				; * No entry point in static analysis (dispatched via DS table)
		test	byte ptr [si+8],0FFh
		jnz	sub02_main			; Jump if not zero
		mov	byte ptr [si+8],40h	; '@'

sub02_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub02_blocked_chk			; Jump if zero
		jmp	word ptr cs:fight_cb_fire

sub02_blocked_chk:
		call	word ptr cs:fight_cb_blocked
		jc	sub02_state_dispatch			; Jump if carry Set
		retn

sub02_state_dispatch:
		test	byte ptr [si+9],4
		jz	sub02_attack_chk			; Jump if zero
		jmp	sub02_spawn_setup

sub02_attack_chk:
		test	byte ptr [si+9],1
		jnz	sub02_state1_active			; Jump if not zero
		call	rng_pick_facing
		add	byte ptr [si+6],80h
		jc	sub02_phase_inc			; Jump if carry Set
		retn

sub02_phase_inc:
		call	phase_advance_helper
		jz	sub02_rng_gate			; Jump if zero
		retn

sub02_rng_gate:
		call	word ptr cs:eai8_rng_fn_ptr
		and	al,3
		jz	sub02_set_state1			; Jump if zero
		retn

sub02_set_state1:
		mov	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0
		retn

sub02_state1_active:
		test	byte ptr [si+9],2
		jnz	sub02_state2_clear			; Jump if not zero
		call	phase_advance_helper
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],8
		je	sub02_set_state2			; Jump if equal
		retn

sub02_set_state2:
		or	byte ptr [si+9],2
		call	word ptr cs:eai8_rng_fn_ptr
		or	al,al			; Zero ?
		js	sub02_strafe_back			; Jump if sign=1
		push	si
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	di,si
		add	si,4Ah
		call	word ptr cs:fight_cb_mark_adj
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		pop	si
		jz	sub02_strafe_fwd_pos			; Jump if zero
		jmp	word ptr cs:fight_cb_step_neg

sub02_strafe_fwd_pos:
		jmp	word ptr cs:fight_cb_step_pos

sub02_strafe_back:
		push	si
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	di,si
		add	si,47h
		call	word ptr cs:fight_cb_mark_adj
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		pop	si
		jz	sub02_strafe_back_neg			; Jump if zero
		jmp	word ptr cs:fight_cb_step_pos

sub02_strafe_back_neg:
		jmp	word ptr cs:fight_cb_step_neg

sub02_state2_clear:
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],0
		retn

rng_pick_facing		proc	near
		call	distance_check_5
		cmp	al,0FFh
		jne	rpf_apply			; Jump if not equal
		retn

rpf_apply:
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		call	word ptr cs:eai8_rng_fn_ptr
		and	al,7
		jz	rpf_set_attack			; Jump if zero
		retn

rpf_set_attack:
		or	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn

rng_pick_facing		endp

sub02_spawn_setup:
		mov	byte ptr [si+6],3
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],3
		je	sub02_spawn_emit			; Jump if equal
		retn

sub02_spawn_emit:
		mov	byte ptr [si+6],4
		mov	al,[si+3]
		mov	ds:enemy_spawn_tile_lo,al
		inc	al
		mov	ds:enemy_spawn_tile_hi,al
		mov	al,[si+2]
		and	al,3Fh			; '?'
		mov	ds:enemy_spawn_col_lo,al
		mov	ds:enemy_spawn_col_hi,al
		mov	bx,0A666h
		test	byte ptr [si+5],80h
		jnz	sub02_spawn_call			; Jump if not zero
		mov	bx,0A673h

sub02_spawn_call:
		call	word ptr cs:fight_cb_despawn
		and	byte ptr [si+9],0FBh
		or	byte ptr [si+9],2
		mov	byte ptr [si+0Ah],0
		retn
		db	 00h, 00h, 2Ah, 00h, 12h, 00h
		db	 50h
		db	8 dup (0)
		db	 2Bh, 00h, 12h, 04h, 01h, 00h
		db	 00h, 00h, 00h, 00h, 00h

phase_advance_helper		proc	near
		mov	al,[si+6]
		inc	al
		cmp	al,3
		jb	pah_store			; Jump if below
		xor	al,al			; Zero register

pah_store:
		mov	[si+6],al
		retn

phase_advance_helper		endp

; ----------------------------------------------------------------
; eai8_sub03_handler  -- AI sub-state 3 dispatch entry (DS table @ 0xA2D3).
; Cooldown-seed prologue (init [si+8]=0x60), visibility check, then
; phase advance + RNG-driven facing pick + range-gated fire/move
; using XLAT direction tables (0xA71B / 0xA723).
; ----------------------------------------------------------------

eai8_sub03_handler:				; * No entry point in static analysis (dispatched via DS table)
		test	byte ptr [si+8],0FFh
		jnz	sub03_main			; Jump if not zero
		mov	byte ptr [si+8],60h	; '`'

sub03_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub03_phase_inc			; Jump if zero
		jmp	word ptr cs:fight_cb_fire

sub03_phase_inc:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		add	byte ptr [si+0Ah],80h
		jc	sub03_dist_chk			; Jump if carry Set
		retn

sub03_dist_chk:
		call	distance_check_8
		jc	sub03_aim_apply			; Jump if carry Set
		test	byte ptr [si+9],70h	; 'p'
		jnz	sub03_xlat_setup			; Jump if not zero
		cmp	al,0FFh
		je	sub03_rng_facing			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short sub03_aim_apply

sub03_rng_facing:
		call	word ptr cs:eai8_rng_fn_ptr
		add	al,al
		and	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short sub03_aim_apply

sub03_aim_apply:
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jns	sub03_blocked_path			; Jump if not sign
		call	word ptr cs:fight_cb_map_fwd
		jmp	short sub03_xlat_setup

sub03_blocked_path:
		call	word ptr cs:fight_cb_blocked

sub03_xlat_setup:
		add	byte ptr [si+9],10h
		mov	al,[si+9]
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,7
		mov	bx,dir_xlat_alt
		test	byte ptr [si+5],80h
		jnz	sub03_xlat_call			; Jump if not zero
		mov	bx,dir_xlat_table

sub03_xlat_call:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	sub03_flip_facing			; Jump if carry Set
		retn

sub03_flip_facing:
		xor	byte ptr [si+5],80h
		retn
		db	0, 0, 1, 0, 0, 0
		db	7, 0, 4, 4, 3, 4
		db	4, 4, 5, 4

distance_check_8		proc	near
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jns	dc8_abs_done			; Jump if not sign
		neg	al

dc8_abs_done:
		cmp	al,8
		mov	al,0FFh
		jc	dc8_in_range			; Jump if carry Set
		retn

dc8_in_range:
		mov	al,10h
		sub	al,[si+3]
		jc	dc8_far_branch			; Jump if carry Set
		mov	ah,al
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dc8_near_clear			; Jump if zero
		retn

dc8_near_clear:
		clc				; Clear carry flag
		retn

dc8_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dc8_far_clear			; Jump if not zero
		retn

dc8_far_clear:
		clc				; Clear carry flag
		retn

distance_check_8		endp

distance_check_5		proc	near
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jns	dc5_abs_done			; Jump if not sign
		neg	al

dc5_abs_done:
		cmp	al,5
		mov	al,0FFh
		jc	dc5_in_range			; Jump if carry Set
		retn

dc5_in_range:
		mov	al,11h
		sub	al,[si+3]
		jc	dc5_far_branch			; Jump if carry Set
		mov	ah,al
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dc5_near_clear			; Jump if zero
		retn

dc5_near_clear:
		clc				; Clear carry flag
		retn

dc5_far_branch:
		neg	al
		mov	ah,al
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dc5_far_clear			; Jump if not zero
		retn

dc5_far_clear:
		clc				; Clear carry flag
		retn

distance_check_5		endp

seg_a		ends

		end	start
