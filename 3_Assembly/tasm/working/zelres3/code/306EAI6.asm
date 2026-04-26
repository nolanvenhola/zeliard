
PAGE  59,132

;==========================================================================
;
;  306EAI6.BIN - Enemy AI Behavior Type 6 (zelres3 chunk 7)
;
;  Enemy AI handler loaded by 200FIGHT.asm and invoked per-tick to update
;  enemy state (position, frame, direction).  The EAI module is paired
;  at runtime with one of several enemy sprite sets (MEDA, LEGA-type
;  enemies).  Behavior type 6 implements a mid-range patroller with
;  range checking, XLAT-table animation cycling, and aim/intercept logic.
;
;  Enemy record layout (SI-relative) shared by all EAI modules:
;    [si+0]    x-position word
;    [si+2]    x-tile (row index in aim tests)
;    [si+3]    y-tile / column
;    [si+4]    flags byte A (60h bit = anim enable)
;    [si+5]    flags byte B (80h = facing, 20h = hidden, 60h = visible)
;    [si+6]    frame counter / phase
;    [si+8]    cooldown/init-timer
;    [si+9]    AI state bits (1=advancing, 2=return, 4=attack, 70h=phase mask)
;    [si+0Ah]  sub-phase counter
;    [si+10h..16h]  echo/render fields copied back at retn
;
;  Dispatch via DS word-pointer table at file offset 0x107 (jumped to
;  via 'jmp ds:[bx+0xA407]' in init prologue, where bx = ([si+4]&0xF)*2).
;  Sub-state handlers sub01..sub04 implement the per-state behaviour;
;  helper subs do range check, step fwd/back, turn handler, collision
;  detection, and wall scan.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; Fight-engine callback vector table (in game_seg DS at 6004h..603Ah).
; These word pointers are the EAI module's only interface to 200FIGHT.

; Shared enemy spawn/state globals in game_seg DS (0xA4xx range).

enemy_spawn_tile_hi	equ	0A4DDh			; spawn-cell row (set for hatch)
enemy_spawn_col_hi	equ	0A4DEh			; spawn-cell col (set for hatch)
enemy_spawn_tile_lo	equ	0A4EAh			; alt spawn row (non-hatch path)
enemy_spawn_col_lo	equ	0A4EBh			; alt spawn col (non-hatch path)
dir_xlat_table		equ	0A766h			; direction lookup table (xlat base)
gvar_hero_x		equ	0FF35h			; hero X tile position (global)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

eai6_main	proc	far

start:
		ror	byte ptr [bx+di],cl	; Rotate
		add	[bx+si],al
		stc				; Set carry flag
		mov	word ptr ds:[0],ax
		add	[bx+si],al
		db	0DFh,0A3h, 64h, 64h, 32h, 32h	; row 0
		db	 00h, 00h, 00h, 00h	; row 1
		db	 50h, 50h, 28h, 28h, 50h	; row 2
		db	27 dup (0)
		db	0B0h,0A0h, 5Fh,0A1h, 0Eh,0A2h	; row 3
		db	0BDh,0A2h, 1Ch,0A3h, 00h, 00h	; row 4
		db	 00h, 00h, 00h, 00h, 50h,0A1h	; row 5
		db	0FFh,0A1h,0AEh,0A2h, 0Dh,0A3h	; row 6
		db	 30h,0A3h, 00h, 00h, 00h, 00h	; row 7
		db	 00h, 00h,0C1h,0A3h,0C1h,0A3h	; row 8
		db	 3Fh,0A3h, 8Ah,0A3h, 4Eh,0A3h	; row 9
		db	 62h,0A3h,0B2h,0A3h, 00h, 00h	; row 10
		db	0B7h,0A3h,0BCh,0A3h,0D5h,0A3h	; row 11
		db	 76h,0A3h, 00h, 00h, 00h, 00h	; row 12
		db	0DAh,0A3h, 00h, 00h, 00h,0A1h	; row 13
		db	0AFh,0A1h, 5Eh,0A2h,0E5h,0A2h	; row 14
		db	 1Ch,0A3h, 00h, 00h, 00h, 00h	; row 15
eai6_anim_phase		db	0
		db	 00h, 50h,0A1h,0FFh,0A1h,0AEh	; row 16
		db	0A2h, 0Dh,0A3h, 30h,0A3h, 00h	; row 17
		db	 00h	; row 18
eai6_collide_marker		db	0
		db	 00h, 00h, 00h,0C1h,0A3h,0C1h	; row 19
		db	0A3h, 3Fh,0A3h, 8Ah,0A3h, 4Eh	; row 20
		db	0A3h, 62h,0A3h,0B2h,0A3h, 00h	; row 21
		db	 00h,0B7h,0A3h,0BCh,0A3h,0D5h	; row 22
		db	0A3h, 76h,0A3h, 00h, 00h, 00h	; row 23
		db	 00h,0DAh,0A3h, 00h, 00h, 00h	; row 24
		db	 01h, 02h, 03h, 04h, 00h, 00h	; row 25
		db	 00h, 00h, 00h, 00h, 01h, 02h	; row 26
		db	 03h, 04h, 00h, 00h, 00h, 00h	; row 27
		db	 00h, 00h, 01h, 02h, 03h, 04h	; row 28
		db	 00h, 01h, 02h, 12h, 04h, 00h	; row 29
		db	 01h, 02h, 13h, 04h, 00h, 01h	; row 30
		db	 02h, 14h, 04h, 00h, 01h, 02h	; row 31
		db	 15h, 04h, 00h, 01h, 02h, 14h	; row 32
		db	 04h, 00h, 01h, 02h, 13h, 04h	; row 33
		db	 00h, 01h, 02h, 12h, 04h, 00h	; row 34
		db	 00h, 00h, 00h, 00h, 00h, 01h	; row 35
		db	 02h, 03h, 04h, 00h, 00h, 00h	; row 36
		db	 00h, 00h, 00h, 01h, 02h, 03h	; row 37
		db	 04h, 00h, 09h, 0Ah, 0Bh, 0Ch	; row 38
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 39
		db	 09h, 0Ah, 0Bh, 0Ch, 00h, 00h	; row 40
		db	 00h, 00h, 00h, 00h	; row 41
		db	9	; row 42
eai6_rng_fn_ptr		dw	0B0Ah
		db	 0Ch, 00h, 09h, 0Ah, 0Bh, 17h	; row 43
		db	 00h, 09h, 0Ah, 0Bh, 18h, 00h	; row 44
		db	 09h, 0Ah, 0Bh, 19h, 00h, 09h	; row 45
		db	 0Ah, 0Bh, 1Ah, 00h, 09h, 0Ah	; row 46
		db	 0Bh, 19h, 00h, 09h, 0Ah, 0Bh	; row 47
		db	 18h, 00h, 09h, 0Ah, 0Bh, 17h	; row 48
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 49
		db	 09h, 0Ah, 0Bh, 0Ch, 00h, 00h	; row 50
		db	 00h, 00h, 00h, 00h, 09h, 0Ah	; row 51
		db	 0Bh, 0Ch, 00h, 1Bh, 1Ch, 1Dh	; row 52
		db	 1Eh, 00h, 00h, 00h, 1Bh, 1Ch	; row 53
		db	 00h, 00h, 00h, 26h, 27h, 00h	; row 54
		db	 11h, 06h, 07h, 08h, 00h, 00h	; row 55
		db	 00h, 00h, 00h, 00h, 11h, 06h	; row 56
		db	 07h, 08h, 00h, 00h, 00h, 00h	; row 57
		db	 00h, 00h, 11h, 06h, 07h, 08h	; row 58
		db	 00h, 11h, 06h, 07h, 08h, 00h	; row 59
		db	 11h, 06h, 07h, 08h, 00h, 11h	; row 60
		db	 06h, 07h, 08h, 00h, 11h, 06h	; row 61
		db	 07h, 08h, 00h, 11h, 06h, 07h	; row 62
		db	 08h, 00h, 11h, 06h, 07h, 08h	; row 63
		db	 00h, 11h, 06h, 07h, 08h, 00h	; row 64
		db	 00h, 00h, 00h, 00h, 00h, 11h	; row 65
		db	 06h, 07h, 08h, 00h, 00h, 00h	; row 66
		db	 00h, 00h, 00h, 11h, 06h, 07h	; row 67
		db	 08h, 00h, 0Dh, 16h, 0Fh, 10h	; row 68
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 69
		db	 0Dh, 16h, 0Fh, 10h, 00h, 00h	; row 70
		db	 00h, 00h, 00h, 00h, 0Dh, 16h	; row 71
		db	 0Fh, 10h, 00h, 0Dh, 16h, 0Fh	; row 72
		db	 10h, 00h, 0Dh, 16h, 0Fh, 10h	; row 73
		db	 00h, 0Dh, 16h, 0Fh, 10h, 00h	; row 74
		db	 0Dh, 16h, 0Fh, 10h, 00h, 0Dh	; row 75
		db	 16h, 0Fh, 10h, 00h, 0Dh, 16h	; row 76
		db	 0Fh, 10h, 00h, 0Dh, 16h, 0Fh	; row 77
		db	 10h, 00h, 00h, 00h, 00h, 00h	; row 78
		db	 00h, 0Dh, 16h, 0Fh, 10h, 00h	; row 79
		db	 00h, 00h, 00h, 00h, 00h, 0Dh	; row 80
		db	 16h, 0Fh, 10h, 00h, 1Fh, 20h	; row 81
		db	 21h, 22h, 00h, 1Dh	; row 82
		db	 23h, 24h	; row 83
		db	'%', 0
		db	'(#)%', 0
		db	'*+,-', 0
		db	'./01', 0
		db	'2345', 0
		db	'6789', 0
		db	'6789', 0
		db	'JKLM', 0
		db	'NOPQ', 0
		db	'c', 0
		db	 65h, 00h, 00h, 5Ah, 00h, 5Ch	; row 84
		db	 00h, 00h, 5Dh, 00h, 5Fh, 00h	; row 85
		db	 00h, 60h, 00h, 62h, 00h, 00h	; row 86
		db	 63h, 00h, 65h, 00h, 00h, 63h	; row 87
		db	 00h, 65h, 00h, 00h	; row 88
		db	 4Eh, 4Fh	; row 89
		db	'PQ', 0
		db	'JKLM', 0
		db	'6789', 0
		db	':;<=', 0
		db	'>?@A', 0
		db	'BCDE', 0
		db	'FGHI', 0
		db	'FGHI', 0
		db	'RSTU', 0
		db	'VWXY', 0
		db	'rstu', 0
		db	'fghi', 0
		db	'jklm', 0
		db	'nopq', 0
		db	'rstu', 0
		db	'rstu', 0
		db	'VWXY', 0
		db	'RSTU', 0
		db	'FGHI', 0
		db	'vwx9', 0
		db	'z{|}'
		db	 00h, 00h, 00h, 80h, 81h, 01h	; row 90
		db	0C2h,0C3h,0C4h,0C5h, 01h,0C6h	; row 91
		db	0C7h,0C8h,0C9h, 01h,0C2h,0C3h	; row 92
		db	0C4h,0CAh, 01h,0C6h,0C7h,0CBh	; row 93
		db	0CCh, 01h, 9Ch, 9Dh, 9Eh, 9Fh	; row 94
		db	 01h,0B7h,0B8h,0B9h,0BAh, 01h	; row 95
		db	 00h,0BBh,0BCh,0BDh, 01h,0BEh	; row 96
		db	0BFh,0C0h,0C1h, 01h,0CDh,0CEh	; row 97
		db	0CFh,0D0h, 01h,0D1h,0D2h,0D3h	; row 98
		db	0D4h, 01h,0CDh,0CEh,0D5h,0D0h	; row 99
		db	 01h,0D1h,0D2h,0D6h,0D7h, 01h	; row 100
		db	0A4h,0A5h,0A6h,0A7h, 01h,0ACh	; row 101
		db	0ADh,0AEh,0AFh, 01h,0B0h, 00h	; row 102
		db	0B1h,0B2h, 01h,0B3h,0B4h,0B5h	; row 103
		db	0B6h, 01h,0D8h,0D9h,0DAh,0DBh	; row 104
		db	 01h,0DCh,0DDh,0DEh,0DFh, 01h	; row 105
		db	0E0h,0E1h,0E2h,0E3h, 01h, 05h	; row 106
		db	 05h, 05h, 05h, 01h, 0Eh, 0Eh	; row 107
		db	 5Bh, 5Eh, 01h, 61h, 64h, 79h	; row 108
		db	 7Eh, 01h, 7Fh, 82h, 83h, 84h	; row 109
		db	 01h, 85h, 86h, 87h, 88h, 01h	; row 110
		db	 89h, 8Ah, 8Bh, 8Bh, 01h, 8Ch	; row 111
		db	 8Ch, 00h, 00h, 01h, 8Dh, 8Eh	; row 112
		db	 8Fh, 90h, 01h, 91h, 92h, 93h	; row 113
		db	 94h, 01h, 95h, 96h, 97h, 98h	; row 114
		db	 00h, 99h, 9Ah, 9Bh,0A0h, 00h	; row 115
		db	0A1h,0A2h,0A3h,0A8h, 00h,0A9h	; row 116
		db	0AAh,0ABh,0E4h, 00h,0A1h,0A2h	; row 117
		db	0A3h,0A8h, 02h, 99h, 9Ah, 9Bh	; row 118
		db	0A0h, 02h,0A1h,0A2h,0A3h,0A8h	; row 119
		db	 02h,0A9h,0AAh,0ABh,0E4h, 02h	; row 120
		db	0A1h,0A2h,0A3h,0A8h, 01h, 99h	; row 121
		db	 9Ah, 9Bh,0A0h, 01h,0A1h,0A2h	; row 122
		db	0A3h,0A8h, 01h,0A9h,0AAh,0ABh	; row 123
		db	0E4h, 01h,0A1h,0A2h,0A3h,0A8h	; row 124
		db	 00h,0E5h,0E6h,0E7h,0E8h, 00h	; row 125
		db	0E5h,0E6h,0E7h,0E8h, 00h,0E5h	; row 126
		db	0E6h,0E7h,0E8h, 00h,0E5h,0E6h	; row 127
		db	0E7h,0E8h, 00h,0E5h,0E6h,0E7h	; row 128
		db	0E8h, 00h,0E5h,0E6h,0E7h,0E8h	; row 129
		db	 00h,0E5h,0E6h,0E7h,0E8h, 00h	; row 130
		db	0E5h,0E6h,0E7h,0E8h, 01h,0E9h	; row 131
		db	0EAh,0EBh,0ECh, 00h,0EDh,0EEh	; row 132
		db	0EFh,0F0h, 02h,0EDh,0EEh,0EFh	; row 133
		db	0F0h, 01h,0FEh,0FEh,0FEh,0FEh	; row 134
		db	 01h,0F1h,0F2h,0F3h,0F4h, 01h	; row 135
		db	0F5h,0F6h,0F7h,0F7h, 01h, 00h	; row 136
		db	 00h,0F8h,0F8h, 00h, 00h, 00h	; row 137
		db	0F9h,0FAh, 01h, 00h,0FBh,0FCh	; row 138
		db	0FDh,0E9h,0A3h,0E9h,0A3h,0EDh	; row 139
		db	0A3h,0F1h,0A3h,0F5h,0A3h, 0Bh	; row 140
		db	 0Bh, 0Bh, 0Bh, 05h, 05h, 05h	; row 141
		db	 05h, 05h, 05h, 00h, 00h, 00h	; row 142
		db	 00h, 00h, 00h, 8Ah, 5Ch, 04h	; row 143
		db	 80h,0E3h, 0Fh, 32h,0FFh, 03h	; row 144
		db	0DBh,0FFh,0A7h, 07h,0A4h, 12h	; row 145
		db	0A4h, 11h,0A4h,0B8h,0A6h, 57h	; row 146
		db	0A8h, 5Fh,0A9h,0C3h,0F6h, 44h	; row 147
		db	 08h,0FFh, 75h, 04h,0C6h, 44h	; row 148
		db	 08h, 30h,0F6h, 44h, 05h, 20h	; row 149
		db	 74h, 10h, 8Ah, 44h, 05h, 24h	; row 150
		db	 1Fh, 3Ch, 01h, 75h, 03h,0E9h	; row 151
		db	0C9h, 00h	; row 152

sub01_main:
		and	byte ptr [si+5],9Fh

sub01_main_clear_render:
		and	byte ptr [si+15h],0BFh
		call	sub01_collide_outer
		jc	sub01_state0_path			; Jump if carry Set
		retn

sub01_state0_path:
		test	byte ptr [si+9],1
		jnz	sub01_state1_active			; Jump if not zero
		call	distance_check_4
		jc	sub01_check_phase_hi			; Jump if carry Set

sub01_advance_phase:
				inc	byte ptr [si+0Ah]
				mov	byte ptr [si+6],1
				or	byte ptr [si+4],60h	; '`'
				call	word ptr cs:eai6_rng_fn_ptr
				and	al,1
				jnz	sub01_step_back_branch			; Jump if not zero
				call	phase_step_fwd
				jnc	sub01_face_west			; Jump if carry=0
				jmp	sub01_finalize

sub01_face_west:
				or	byte ptr [si+5],80h
				jmp	sub01_finalize

sub01_step_back_branch:
				call	phase_step_back
				jnc	sub01_face_east			; Jump if carry=0
				jmp	sub01_finalize

sub01_face_east:
				and	byte ptr [si+5],7Fh
				jmp	sub01_finalize

sub01_check_phase_hi:
				test	byte ptr [si+0Ah],0F0h
				jz	sub01_advance_phase			; Jump if zero
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],1
		jmp	short sub01_finalize

sub01_state1_active:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0Fh
		jnz	sub01_state1_phase_check			; Jump if not zero
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],1
		or	byte ptr [si+4],60h	; '`'
		jmp	short sub01_finalize

sub01_state1_phase_check:
		cmp	byte ptr [si+6],4
		jb	sub01_finalize			; Jump if below
		and	byte ptr [si+4],1Fh
		cmp	byte ptr [si+6],8
		jne	sub01_finalize			; Jump if not equal
		mov	al,[si+3]
		mov	ds:enemy_spawn_tile_lo,al
		inc	al
		mov	ds:enemy_spawn_tile_hi,al
		mov	al,[si+2]
		inc	al
		mov	ds:enemy_spawn_col_lo,al
		mov	ds:enemy_spawn_col_hi,al
		mov	bx,0A4DDh
		test	byte ptr [si+5],80h
		jnz	sub01_despawn_call			; Jump if not zero
		mov	bx,0A4EAh

sub01_despawn_call:
		call	word ptr cs:fight_cb_despawn
		jmp	short sub01_finalize

; ----------------------------------------------------------------
; eai6_sub01_state1_inline_data -- 21 inline bytes between
; sub01_despawn_call (jmp short sub01_finalize at 344) and
; sub01_hide_branch.  Read by sibling sub-handlers via offset
; arithmetic; treated here as raw byte tables.
; ----------------------------------------------------------------

eai6_sub01_state1_inline_data:
		db	 00h, 00h, 63h, 00h, 14h, 00h	; row 0
		db	 14h	; row 1
		db	8 dup (0)
		db	 63h, 00h, 14h, 04h, 14h, 00h	; row 2
		db	 00h, 00h, 00h, 00h, 00h	; row 3

sub01_hide_branch:
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:fight_cb_fire

sub01_finalize:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+4]
		and	al,60h			; '`'
		and	byte ptr [si+14h],9Fh
		or	[si+14h],al
		mov	al,[si+5]
		and	al,80h
		and	byte ptr [si+15h],7Fh
		or	[si+15h],al
		retn

eai6_main	endp

distance_check_4		proc	near
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jnc	dc4_abs_done			; Jump if carry=0
		neg	al

dc4_abs_done:
		cmp	al,4
		mov	al,0FFh
		jc	dc4_in_range			; Jump if carry Set
		retn

dc4_in_range:
		cmp	byte ptr [si+3],11h
		jae	dc4_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dc4_near_clear			; Jump if zero
		retn

dc4_near_clear:
		clc				; Clear carry flag
		retn

dc4_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dc4_far_clear			; Jump if not zero
		retn

dc4_far_clear:
		clc				; Clear carry flag
		retn

distance_check_4		endp

phase_step_fwd		proc	near
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

phase_step_fwd		endp

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

phase_step_back		proc	near
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

phase_step_back		endp

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

sub01_collide_outer		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	sco_test1			; Jump if not zero
		retn

sco_test1:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	sco_test2			; Jump if not zero
		retn

sco_test2:
		call	sub01_collide_inner
		jnc	sco_apply			; Jump if carry=0
		retn

sco_apply:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn

sub01_collide_outer		endp

sub01_collide_inner		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	si,di
		add	si,offset eai6_collide_marker
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	cx,2

collide_inner_loop:
				mov	al,[di]
				call	word ptr cs:fight_cb_cmp_tile
				stc				; Set carry flag
				jz	collide_inner_step			; Jump if zero
				retn

collide_inner_step:
				inc	di
				loop	collide_inner_loop		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn

sub01_collide_inner		endp

; ----------------------------------------------------------------
; sub02_handler  -- AI sub-state 2 dispatch entry (DS-table -> +0xB8 from base)
; Reached via dispatch JMP in eai6_main when ([si+4]&0xF) selects this slot.
; Cooldown-seed prologue, then visibility check, then dispatch by state bits
; into one of: phase-2 retreat (sub_phase2), phase-1 swerve (sub_phase1),
; phase-4 hide reset (sub_phase4), or default attack/aim path.
; ----------------------------------------------------------------

sub02_handler:				; * No entry point to code (called via DS dispatch table)
		test	byte ptr [si+8],0FFh
		jnz	sub02_main			; Jump if not zero
		mov	byte ptr [si+8],10h

sub02_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub02_state_check			; Jump if zero
		mov	byte ptr [si+6],3
		mov	byte ptr [si+9],1
		jmp	word ptr cs:fight_cb_fire

sub02_state_check:
		test	byte ptr [si+9],2
		jz	sub02_check_state1			; Jump if zero
		jmp	sub02_phase2_entry

sub02_check_state1:
		test	byte ptr [si+9],1
		jz	sub02_check_state4			; Jump if zero
		jmp	sub02_phase1_entry

sub02_check_state4:
		test	byte ptr [si+9],4
		jz	sub02_attack_branch			; Jump if zero
		jmp	sub02_phase4_entry

sub02_attack_branch:
		call	distance_check_8
		jc	sub02_attack_aim			; Jump if carry Set
		test	byte ptr [si+9],70h	; 'p'
		jnz	sub02_attack_apply			; Jump if not zero
		cmp	al,0FFh
		je	sub02_attack_rng			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short sub02_attack_aim

sub02_attack_rng:
		call	word ptr cs:eai6_rng_fn_ptr
		add	al,al
		and	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al

sub02_attack_aim:
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jns	sub02_attack_blocked			; Jump if not sign
		call	word ptr cs:fight_cb_map_fwd
		jmp	short sub02_attack_apply

sub02_attack_blocked:
		call	word ptr cs:fight_cb_blocked

sub02_attack_apply:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		add	byte ptr [si+9],10h
		mov	al,[si+9]
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,7
		mov	bx,0A75Eh
		test	byte ptr [si+5],80h
		jnz	sub02_xlat_call			; Jump if not zero
		mov	bx,dir_xlat_table

sub02_xlat_call:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	sub02_flip_facing			; Jump if carry Set
		retn

sub02_flip_facing:
		xor	byte ptr [si+5],80h
		retn

; ----------------------------------------------------------------
; eai6_sub02_inline_data -- 16 inline bytes after sub02_flip_facing.
; Read by phase2/phase4 logic via fixed offsets.
; ----------------------------------------------------------------

eai6_sub02_inline_data:
		db	0, 0, 1, 0, 0, 0	; padding/leftover bytes
		db	7, 0, 4, 4, 3, 4	; row 0
		db	4, 4, 5, 4	; row 1

sub02_phase1_entry:
		or	byte ptr [si+4],60h	; '`'
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],7
		jae	sub02_phase1_done			; Jump if above or =
		retn

sub02_phase1_done:
		mov	byte ptr [si+6],8
		mov	byte ptr [si+0Ah],0
		mov	byte ptr [si+9],2
		retn

sub02_phase2_entry:
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],0Fh
		jae	sub02_phase2_done			; Jump if above or =
		call	distance_check_8
		jnc	sub02_phase2_aim			; Jump if carry=0
		test	byte ptr [si+9],70h	; 'p'
		jnz	sub02_phase2_apply			; Jump if not zero
		cmp	al,0FFh
		je	sub02_phase2_rng			; Jump if equal
		xor	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short sub02_phase2_aim

sub02_phase2_rng:
		call	word ptr cs:eai6_rng_fn_ptr
		add	al,al
		and	al,80h
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		jmp	short sub02_phase2_aim

sub02_phase2_aim:
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		js	sub02_phase2_blocked			; Jump if sign=1
		call	word ptr cs:fight_cb_map_fwd
		jmp	short sub02_phase2_apply

sub02_phase2_blocked:
		call	word ptr cs:fight_cb_blocked

sub02_phase2_apply:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		or	byte ptr [si+6],8
		add	byte ptr [si+9],10h
		mov	al,[si+9]
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,7
		mov	bx,0A75Eh
		test	byte ptr [si+5],80h
		jnz	sub02_phase2_xlat			; Jump if not zero
		mov	bx,dir_xlat_table

sub02_phase2_xlat:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	sub02_phase2_flip			; Jump if carry Set
		retn

sub02_phase2_flip:
		xor	byte ptr [si+5],80h
		retn

sub02_phase2_done:
		mov	byte ptr [si+6],0Ch
		mov	byte ptr [si+9],4
		retn

sub02_phase4_entry:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0Fh
		jz	sub02_phase4_reset			; Jump if zero
		retn

sub02_phase4_reset:
		mov	byte ptr [si+9],0
		and	byte ptr [si+4],1Fh
		retn

distance_check_8		proc	near
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jnc	dc8_abs_done			; Jump if carry=0
		neg	al

dc8_abs_done:
		cmp	al,8
		mov	al,0FFh
		jc	dc8_in_range			; Jump if carry Set
		retn

dc8_in_range:
		cmp	byte ptr [si+3],11h
		jae	dc8_far_branch			; Jump if above or =
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

; ----------------------------------------------------------------
; sub03_handler  -- AI sub-state 3 dispatch entry. Called via DS dispatch
; table (no static caller). Cooldown-seed prologue, then visibility check,
; then dispatches to step/charge logic by state bit 1, charge/swerve by
; bit 2, etc. Uses sub02_flip_to_state2 helper to flip facing+state.
; ----------------------------------------------------------------

sub03_handler:				; * No entry point to code (called via DS dispatch table)
		test	byte ptr [si+8],0FFh
		jnz	sub03_main			; Jump if not zero
		mov	byte ptr [si+8],8

sub03_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub03_visible			; Jump if zero
		jmp	word ptr cs:fight_cb_fire

sub03_visible:
		test	byte ptr [si+9],1
		jnz	sub03_state1_path			; Jump if not zero
		call	word ptr cs:fight_cb_blocked
		jc	sub03_blocked			; Jump if carry Set
		retn

sub03_blocked:
		call	distance_check_8
		jc	sub03_in_range			; Jump if carry Set
		add	byte ptr [si+6],80h
		jc	sub03_step_branch			; Jump if carry Set
		retn

sub03_step_branch:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],0F3h
		test	byte ptr [si+5],80h
		jnz	sub03_step_neg_branch			; Jump if not zero
		call	word ptr cs:fight_cb_step_pos
		jnc	sub03_step_done			; Jump if carry=0
		xor	byte ptr [si+5],80h
		jmp	short sub03_step_done

sub03_step_neg_branch:
		call	word ptr cs:fight_cb_step_neg
		jnc	sub03_step_done			; Jump if carry=0
		xor	byte ptr [si+5],80h

sub03_step_done:
		dec	byte ptr [si+0Ah]
		test	byte ptr [si+0Ah],0Fh
		jz	sub03_step_flip			; Jump if zero
		retn

sub03_step_flip:
		xor	byte ptr [si+5],80h
		retn

sub03_in_range:
		mov	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0
		retn

sub03_state1_path:
		test	byte ptr [si+9],2
		jnz	sub03_state2_path			; Jump if not zero
		call	distance_check_8
		cmp	al,0FFh
		je	sub03_dist_check_again			; Jump if equal
		mov	byte ptr [si+6],4
		test	byte ptr [si+5],80h
		jnz	sub03_charge_neg			; Jump if not zero
		call	word ptr cs:fight_cb_step_pos
		call	word ptr cs:fight_cb_step_pos
		jnc	sub03_charge_done			; Jump if carry=0
		call	sub02_block_or_advance
		jc	sub02_flip_to_state2_entry			; Jump if carry Set
		jmp	short sub03_charge_done

sub03_charge_neg:
		call	word ptr cs:fight_cb_step_neg
		call	word ptr cs:fight_cb_step_neg
		jnc	sub03_charge_done			; Jump if carry=0
		call	sub02_block_or_advance
		jc	sub02_flip_to_state2_entry			; Jump if carry Set

sub03_charge_done:
		inc	byte ptr [si+0Ah]
		mov	al,[si+0Ah]
		and	al,0Fh
		inc	al
		jnz	sub03_charge_phase_check			; Jump if not zero
		call	sub02_flip_to_state2

sub03_charge_phase_check:
		test	byte ptr [si+0Ah],1Fh
		jz	sub03_dist_check_again			; Jump if zero
		retn

sub03_dist_check_again:
		call	distance_check_8
		jnc	sub03_reset			; Jump if carry=0
		retn

sub03_reset:
		mov	byte ptr [si+6],0
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Ah],0
		retn

sub02_flip_to_state2		proc	near

sub02_flip_to_state2_entry:
		or	byte ptr [si+9],2
		xor	byte ptr [si+5],80h
		mov	byte ptr [si+6],5
		retn

sub02_flip_to_state2		endp

sub03_state2_path:
		inc	byte ptr [si+6]
		test	byte ptr [si+6],7
		jz	sub03_state2_reset			; Jump if zero
		retn

sub03_state2_reset:
		and	byte ptr [si+9],0FDh
		mov	byte ptr [si+6],4
		retn

sub02_block_or_advance		proc	near
		test	byte ptr [si+9],4
		jnz	sub02_boa_map_fwd			; Jump if not zero
		jmp	word ptr cs:fight_cb_blocked

sub02_boa_map_fwd:
		call	word ptr cs:fight_cb_map_fwd
		jc	sub02_boa_set_bit2			; Jump if carry Set
		retn

sub02_boa_set_bit2:
		or	byte ptr [si+9],4
		retn

sub02_block_or_advance		endp

; ----------------------------------------------------------------
; sub04_handler  -- AI sub-state 4 dispatch entry. Called via DS dispatch
; table (no static caller). Sets visibility flag bit 20h, then dispatches
; by state bits 1/2: state2 -> spawn projectile path; state1 -> blocked
; check + range check using eai6_anim_phase; default -> RNG-gated state set.
; ----------------------------------------------------------------

sub04_handler:				; * No entry point to code (called via DS dispatch table)
		or	byte ptr [si+4],20h	; ' '
		test	byte ptr [si+9],2
		jnz	sub04_state2_path			; Jump if not zero
		test	byte ptr [si+9],1
		jnz	sub04_state1_path			; Jump if not zero
		cmp	byte ptr [si+3],8
		jae	sub04_range_lo_chk			; Jump if above or =
		retn

sub04_range_lo_chk:
		cmp	byte ptr [si+3],13h
		jb	sub04_rng_check			; Jump if below
		retn

sub04_rng_check:
		call	word ptr cs:eai6_rng_fn_ptr
		and	al,3
		jz	sub04_set_state1			; Jump if zero
		retn

sub04_set_state1:
		or	byte ptr [si+9],1
		retn

sub04_state1_path:
		call	word ptr cs:fight_cb_blocked
		jc	sub04_state1_apply			; Jump if carry Set
		retn

sub04_state1_apply:
		or	byte ptr [si+9],2
		mov	byte ptr [si+6],1
		mov	ah,eai6_anim_phase
		dec	ah
		mov	al,[si+2]
		sub	al,ah
		and	al,3Fh			; '?'
		cmp	al,13h
		jb	sub04_set_spawn_fx			; Jump if below
		retn

sub04_set_spawn_fx:
		mov	byte ptr ds:gvar_spawn_fx_flag,21h	; '!'
		retn

sub04_state2_path:
		add	byte ptr [si+6],80h
		jc	sub04_state2_phase			; Jump if carry Set
		retn

sub04_state2_phase:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jz	sub04_spawn			; Jump if zero
		retn

sub04_spawn:
		and	byte ptr [si+7],0F0h
		or	byte ptr [si+7],1
		jmp	word ptr cs:fight_cb_spawn

seg_a		ends

		end	start
