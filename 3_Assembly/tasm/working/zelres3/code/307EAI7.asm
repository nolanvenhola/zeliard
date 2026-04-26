
PAGE  59,132

;==========================================================================
;
;  307EAI7.BIN - Enemy AI Behavior Type 7 (zelres3 chunk 8)
;
;  Enemy AI handler loaded by 200FIGHT.asm and paired with LEGA/DRGN
;  enemy sprite sets.  Behavior type 7 is a multi-phase pursuer that
;  combines directional stepping, randomised strafe, XLAT-table animation,
;  aim-refresh timers, and multi-state dispatching through [si+9] phase bits.
;
;  Enemy record layout (SI-relative) shared by all EAI modules:
;    [si+0]    x-position word
;    [si+2]    x-tile (col index)
;    [si+3]    y-tile (row index, used in aim tests)
;    [si+5]    flags byte B (80h = facing, 20h = hidden)
;    [si+6]    frame counter / phase
;    [si+8]    cooldown / init-timer
;    [si+9]    AI state bits (1=advancing, 2=return, 4=attack, 18h=phase4 mask)
;    [si+0Ah]  sub-phase counter
;    [si+10h..16h]  echo/render fields copied back at retn
;
;  Dispatch via DS word-pointer table at file offset 0xFF.  The init prologue
;  (mov bl,[si+4]; and bl,0Fh; xor bh,bh; add bx,bx; jmp ds:[bx+0xA2FF])
;  selects sub-state by ([si+4]&0xF):
;    idx 4 -> sub01_handler  (in eai7_main proc body)
;    idx 5 -> sub01_alt_entry (just retn)
;    idx 6 -> sub02_handler
;    idx 7 -> sub02_handler alt entry (offset -1)
;    idx 8 -> sub03_handler
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; Fight-engine callback vector table (in game_seg DS at 6004h..603Ah).

; Shared enemy spawn/state globals in game_seg DS.

path_tbl_a		equ	8A89h			; path/route data table A
path_tbl_b		equ	8B8Ah			; path/route data table B
path_tbl_c		equ	9291h			; path/route data table C
sprite_src_base		equ	0A1A0h			; enemy-sprite source table base
enemy_spawn_tile_a	equ	0A460h			; spawn-cell row (path A)
enemy_spawn_col_a	equ	0A461h			; spawn-cell col (path A)
enemy_spawn_tile_b	equ	0A46Dh			; spawn-cell row (path B)
enemy_spawn_col_b	equ	0A46Eh			; spawn-cell col (path B)
aim_delta_pos		equ	0A491h			; positive aim delta threshold
aim_delta_neg		equ	0A492h			; negative aim delta threshold
ai_phase_table		equ	0A701h			; ai phase/wait table
spawn_cell_row_hi	equ	0A704h			; alt spawn row (phase hi)
spawn_cell_col_hi	equ	0A705h			; alt spawn col (phase hi)
spawn_cell_row_lo	equ	0A711h			; alt spawn row (phase lo)
spawn_cell_col_lo	equ	0A712h			; alt spawn col (phase lo)
dir_xlat_alt		equ	0A8C7h			; direction xlat (alt state)
gvar_hero_x		equ	0FF35h			; hero X tile position (global)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

eai7_main	proc	far

start:
		iret				; Interrupt return
; ----------------------------------------------------------------
; eai7_init_params  -- spawn parameter block (init/timer constants)
; ----------------------------------------------------------------

eai7_init_params:
		db	 08h, 00h, 00h,0F1h,0A2h, 00h	; row 0
		db	 00h, 00h, 00h,0DBh,0A2h, 50h	; row 1
		db	 50h,0C8h,0C8h, 32h, 00h, 00h	; row 2
		db	 00h, 50h, 50h, 50h, 50h, 28h	; row 3
		db	 00h				; row 4
		db	26 dup (0)
; ----------------------------------------------------------------
; eai7_jump_tbl_a  -- DS pointer table (CS-relative addresses A0xx..A2xx)
; Bank A: dispatch entries at sub-state idx 0,2,4,6,8 etc.
; ----------------------------------------------------------------

eai7_jump_tbl_a:
		db	0B0h,0A0h, 0Fh,0A1h, 6Eh,0A1h	; row 0: ptrs A0B0,A10F,A16E
		db	0CDh,0A1h, 2Ch,0A2h		; row 1: ptrs A1CD,A22C
		db	7 dup (0)
		db	0A1h, 5Fh,0A1h,0BEh,0A1h, 1Dh	; row 2: tail A1??, A15F, A1BE, A21D...
		db	0A2h, 54h,0A2h			; row 3: ...A254
		db	10 dup (0)
		db	 63h,0A2h,0AEh,0A2h, 72h,0A2h	; row 4: ptrs A263,A2AE,A272
		db	 86h,0A2h,0CCh,0A2h, 00h, 00h	; row 5: ptrs A286,A2CC + zero pad
		db	0D1h,0A2h,0D6h,0A2h, 00h, 00h	; row 6: ptrs A2D1,A2D6 + zero pad
		db	 9Ah,0A2h, 00h, 00h, 00h, 00h	; row 7: ptr A29A + zero pad
		db	 00h, 00h, 00h, 00h,0D8h,0A0h	; row 8: zero pad + ptr A0D8
		db	 37h,0A1h, 96h,0A1h,0F5h,0A1h	; row 9: ptrs A137,A196,A1F5
		db	 40h,0A2h, 00h, 00h, 00h, 00h	; row 10: ptr A240 + zero pad
		db	 00h, 00h, 00h,0A1h, 5Fh,0A1h	; row 11: tail ?A1, A15F
		db	0BEh,0A1h, 1Dh,0A2h, 54h,0A2h	; row 12: ptrs A1BE,A21D,A254
		db	0, 0				; zero pad before collide_marker
eai7_collide_marker		db	0
		db	7 dup (0)
		db	 63h,0A2h,0AEh,0A2h, 72h,0A2h	; row 13: ptrs A263,A2AE,A272
		db	 86h,0A2h,0CCh,0A2h, 00h, 00h	; row 14: ptrs A286,A2CC + zero pad
		db	0D1h,0A2h,0D6h,0A2h, 00h, 00h	; row 15: ptrs A2D1,A2D6 + zero pad
		db	 9Ah,0A2h, 00h, 00h, 00h, 00h	; row 16: ptr A29A + zero pad
; ----------------------------------------------------------------
; eai7_sprite_tbl_b0  -- sprite tile-index table (frames 0xB0..0xBF)
; ----------------------------------------------------------------

eai7_sprite_tbl_b0:
		db	 00h, 00h, 00h, 00h, 00h,0B0h	; frame 0 (5 zeros + B0)
		db	0B1h,0B2h,0B3h, 00h,0B8h,0B9h	; frame 1: B1,B2,B3,0,B8,B9
		db	0BAh,0BBh, 00h,0B0h,0B1h,0C0h	; frame 2: BA,BB,0,B0,B1,C0
		db	0B3h, 00h,0B8h,0B9h,0BAh,0BBh	; frame 3: B3,0,B8,B9,BA,BB
		db	 00h,0B0h,0B1h,0B2h,0B3h, 00h	; frame 4: 0,B0,B1,B2,B3,0
		db	0B0h,0B1h,0B2h,0B3h, 00h,0D1h	; frame 5/6: B0..B3,0,D1
		db	0D2h,0D3h,0D4h, 00h,0D1h,0D2h	; frame 6: D2,D3,D4,0,D1,D2
		db	0D3h,0D4h, 00h,0D7h,0D8h,0D9h	; frame 7: D3,D4,0,D7,D8,D9
		db	 11h, 00h, 26h, 27h, 28h, 35h	; frame 8: 11,0,26,27,28,35
		db	 00h,0D7h,0D8h,0D9h, 58h, 00h	; frame 9: 0,D7,D8,D9,58,0
		db	 26h, 27h, 28h, 35h, 00h,0D7h	; frame 10: 26,27,28,35,0,D7
		db	0D8h, 81h, 82h, 00h,0D7h,0D8h	; frame 11: D8,81,82,0,D7,D8
		db	 81h, 82h, 00h, 97h, 98h, 99h	; frame 12: 81,82,0,97,98,99
		db	 9Ah, 00h, 97h, 98h, 99h, 9Ah	; frame 13: 9A,0,97,98,99,9A
		db	 00h, 7Fh, 80h,0A9h,0CDh, 00h	; frame 14: 0,7F,80,A9,CD,0
		db	 00h, 00h,0CBh,0CCh, 00h, 00h	; frame 15: 0,0,CB,CC,0,0
		db	 00h, 00h, 00h, 00h,0B4h,0B5h	; frame 16: 0,0,0,0,B4,B5
		db	0B6h,0B7h, 00h,0BCh		; frame 17 partial: B6,B7,0,BC
eai7_rng_fn_ptr		dw	0BEBDh
		db	0BFh, 00h,0C1h,0C2h,0C3h,0C4h	; frame 18: BF,0,C1,C2,C3,C4
		db	 00h,0BCh,0BDh,0BEh,0BFh, 00h	; frame 19: 0,BC,BD,BE,BF,0
		db	0C7h,0C8h,0C9h,0CAh, 00h,0C7h	; frame 20: C7,C8,C9,CA,0,C7
		db	0C8h,0C9h,0CAh, 00h,0D5h,0D6h	; frame 21: C8,C9,CA,0,D5,D6
		db	0C9h,0CAh, 00h,0D5h,0D6h,0C9h	; frame 22: C9,CA,0,D5,D6,C9
		db	0CAh, 00h, 12h, 13h, 14h, 25h	; frame 23: CA,0,12,13,14,25
		db	 00h, 3Ch, 43h, 4Ah, 51h, 00h	; frame 24: 0,3C,43,4A,51,0
		db	 5Fh, 66h, 7Dh, 7Eh, 00h, 3Ch	; frame 25: 5F,66,7D,7E,0,3C
		db	 43h, 4Ah, 51h, 00h, 83h, 94h	; frame 26: 43,4A,51,0,83,94
		db	 95h, 96h, 00h, 83h, 94h, 95h	; frame 27: 95,96,0,83,94,95
		db	 96h, 00h, 9Bh,0AFh, 95h, 96h	; frame 28: 96,0,9B,AF,95,96
		db	 00h, 9Bh,0AFh, 95h, 96h, 00h	; frame 29: 0,9B,AF,95,96,0
		db	0CEh,0C5h,0C6h, 00h, 00h,0CDh	; frame 30: CE,C5,C6,0,0,CD
		db	0C5h,0CEh, 00h, 00h,0CFh,0D0h	; frame 31: C5,CE,0,0,CF,D0
		db	0DAh,0DBh, 01h, 00h, 00h, 36h	; frame 32: DA,DB,01,0,0,36
		db	 37h, 01h, 00h, 00h, 3Dh, 3Eh	; frame 33: 37,01,0,0,3D,3E
		db	 01h, 00h, 00h, 44h, 45h, 01h	; frame 34: 01,0,0,44,45,01
		db	 00h, 00h, 4Bh, 4Ch, 01h	; frame 35 partial: 0,0,4B,4C,01
eai7_anim_state_ref		dw	6Dh			; Data table (indexed access)
		db	 6Fh, 70h, 01h, 6Dh, 00h, 6Fh	; frame 36: 6F,70,01,6D,0,6F
		db	 70h, 01h, 75h, 76h, 77h, 78h	; frame 37: 70,01,75,76,77,78
		db	 01h, 75h, 76h, 77h, 78h, 01h	; frame 38: 01,75,76,77,78,01
		db	 00h, 00h, 52h, 53h, 01h, 00h	; frame 39: 0,0,52,53,01,0
		db	 00h, 59h, 5Ah, 01h, 00h, 00h	; frame 40: 0,59,5A,01,0,0
		db	 60h, 61h, 01h, 00h, 00h, 67h	; frame 41: 60,61,01,0,0,67
		db	 68h, 01h, 00h, 85h, 86h, 87h	; frame 42: 68,01,0,85,86,87
		db	 01h, 00h, 85h, 86h, 87h, 01h	; frame 43: 01,0,85,86,87,01
		db	 8Ch, 8Dh, 8Eh, 8Fh, 01h, 8Ch	; frame 44: 8C..8F,01,8C
		db	 8Dh, 8Eh, 8Fh, 01h, 00h, 9Ch	; frame 45: 8D,8E,8F,01,0,9C
		db	 9Dh, 9Eh, 01h,0A3h,0A4h,0A5h	; frame 46: 9D,9E,01,A3,A4,A5
		db	0A6h, 01h,0AAh,0ABh,0ACh, 00h	; frame 47: A6,01,AA,AB,AC,0
		db	 01h, 38h, 39h, 3Ah, 3Bh, 01h	; frame 48: 01,38,39,3A,3B,01
		db	 3Fh, 40h, 41h, 42h, 01h, 46h	; frame 49: 3F,40,41,42,01,46
		db	 47h, 48h, 49h, 01h, 4Dh, 4Eh	; frame 50: 47,48,49,01,4D,4E
		db	 4Fh, 50h, 01h, 71h, 72h, 73h	; frame 51: 4F,50,01,71,72,73
		db	 74h, 01h, 71h, 72h, 73h, 74h	; frame 52: 74,01,71,72,73,74
		db	 01h, 79h, 7Ah, 7Bh, 7Ch, 01h	; frame 53: 01,79,7A,7B,7C,01
		db	 79h, 7Ah, 7Bh, 7Ch, 01h, 54h	; frame 54: 79,7A,7B,7C,01,54
		db	 55h, 56h, 57h, 01h, 5Bh, 5Ch	; frame 55: 55,56,57,01,5B,5C
		db	 5Dh, 5Eh, 01h, 62h, 63h, 64h	; frame 56: 5D,5E,01,62,63,64
		db	 65h, 01h			; frame 57 partial: 65,01
		db	 69h, 6Ah, 6Bh, 6Ch		; frame 57 tail: 69,6A,6B,6C

eai7_anim_idx_a:
		add	ds:path_tbl_a[bx+si],cx
		mov	ax,[bx+di]
		mov	ds:path_tbl_b[bx+di],cl
		add	ds:path_tbl_c[bx+si],dx
		xchg	bx,ax
		add	ds:path_tbl_c[bx+si],dx
		xchg	bx,ax
		add	ds:sprite_src_base[bx],bx
		mov	ds:ai_phase_table,al
		test	al,0
		add	[bx+di],al
		db	 00h, 00h, 00h, 00h, 02h, 01h	; row 0: idx-a entry 0
		db	 02h, 03h, 04h, 02h, 05h, 06h	; row 1: idx-a entry 1
		db	 07h, 08h, 02h, 09h, 0Ah, 0Bh	; row 2: idx-a entry 2
		db	 0Ch, 02h, 0Dh, 0Eh, 0Fh, 10h	; row 3: idx-a entry 3
		db	 02h, 15h, 16h, 17h, 18h, 02h	; row 4: idx-a entry 4
		db	 19h, 1Ah, 1Bh, 1Ch, 02h, 1Dh	; row 5: idx-a entry 5
		db	 1Eh, 1Fh, 20h, 02h, 21h, 22h	; row 6: idx-a entry 6
		db	 23h, 24h, 02h, 29h, 2Ah, 2Bh	; row 7: idx-a entry 7
		db	 2Ch, 02h, 2Dh, 2Eh, 2Fh, 30h	; row 8: idx-a entry 8
		db	 02h, 31h, 32h, 33h, 34h, 01h	; row 9: idx-a entry 9
		db	0DCh,0DDh,0DEh,0DFh, 01h,0E0h	; row 10: idx-a tail
		db	0E1h,0E2h			; row 11: idx-a tail end

eai7_anim_idx_b:
;*		jcxz	loc_4			;*Jump if cx=0
		db	0E3h, 01h		;  Fixup - byte match
		in	al,0E5h			; port 0E5h ??I/O Non-standard
		out	0E7h,al			; port 0E7h ??I/O Non-standard
;*		add	al,ch
		db	 00h,0E8h		;  Fixup - byte match
		jmp	$-1413h
		db	 00h,0ECh,0EDh,0EEh,0EFh, 00h	; row 0: idx-b entries
		db	0F0h,0F1h,0F2h,0F3h, 00h,0ECh	; row 1: idx-b entries
		db	0EDh,0EEh,0EFh, 02h,0E8h,0E9h	; row 2: idx-b entries
		db	0EAh,0EBh, 02h,0ECh,0EDh,0EEh	; row 3: idx-b entries
		db	0EFh, 02h,0F0h,0F1h,0F2h,0F3h	; row 4: idx-b entries
		db	 02h,0ECh,0EDh,0EEh,0EFh, 01h	; row 5: idx-b entries
		db	0E8h,0E9h,0EAh,0EBh, 01h,0ECh	; row 6: idx-b entries
		db	0EDh,0EEh,0EFh, 01h,0F0h,0F1h	; row 7: idx-b entries
		db	0F2h,0F3h, 01h,0ECh,0EDh,0EEh	; row 8: idx-b entries
		db	0EFh, 00h,0F4h,0F5h,0F6h,0F7h	; row 9: idx-b entries
		db	 00h,0F4h,0F5h,0F6h,0F7h, 00h	; row 10: idx-b entries
		db	0F4h,0F5h,0F6h,0F7h, 00h,0F4h	; row 11: idx-b entries
		db	0F5h,0F6h,0F7h, 00h,0F4h,0F5h	; row 12: idx-b entries
		db	0F6h,0F7h, 00h,0F4h,0F5h,0F6h	; row 13: idx-b entries
		db	0F7h, 01h,0F8h,0F9h,0FAh,0FBh	; row 14: idx-b tail
; ----------------------------------------------------------------
; eai7_unk_data_at_0x276  -- mixed sprite/ptr table (frames 6E/84/A2)
; Sprite indices interleaved with CS-relative pointers (A2E5..A2ED).
; ----------------------------------------------------------------

eai7_unk_data_at_0x276:
		db	 00h,0FCh,0FDh, 6Eh, 84h, 02h	; row 0: sprite frames + flag
		db	0FCh,0FDh, 6Eh, 84h,0E5h,0A2h	; row 1: ptrs A2E5
		db	0E5h,0A2h,0E9h,0A2h,0E9h,0A2h	; row 2: ptrs A2E5,A2E9,A2E9
		db	0EDh,0A2h, 0Bh, 0Bh, 0Bh, 05h	; row 3: ptr A2ED + RNG-shift constants
		db	 0Bh, 0Bh, 0Bh, 05h, 0Bh, 05h	; row 4: RNG-shift constants
		db	 05h, 00h, 8Ah, 5Ch, 04h, 80h	; row 5: const + opcode bytes
		db	0E3h, 0Fh, 32h,0FFh, 03h,0DBh	; row 6: opcode bytes
		db	0FFh,0A7h,0FFh,0A2h, 0Ah,0A3h	; row 7: opcode + ptrs A2FF,A30A
		db	 09h,0A3h, 39h,0A6h, 38h,0A6h	; row 8: ptrs A309,A639,A638
		db	 49h,0A7h,0C3h,0F6h, 44h, 08h	; row 9: ptr A749 + opcode tail
		db	0FFh, 75h, 04h,0C6h, 44h, 08h	; row 10: opcode tail
		db	 10h				; row 11: trailing byte

sub01_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub01_visible			; Jump if zero
		jmp	sub01_hide_branch

sub01_visible:
		test	byte ptr [si+15h],40h	; '@'
		jz	sub01_collide_chk			; Jump if zero
		jmp	sub01_hide_branch

sub01_collide_chk:
		call	sub01_collide_outer
		jc	sub01_state_dispatch			; Jump if carry Set
		retn

sub01_state_dispatch:
		test	byte ptr [si+9],1
		jz	sub01_state0_path			; Jump if zero
		jmp	sub01_state1_active

sub01_state0_path:
		call	distance_check_5
		jc	sub01_aim_setup			; Jump if carry Set
		cmp	al,0FFh
		je	sub01_xor_facing_done			; Jump if equal
		xor	byte ptr [si+5],80h

sub01_xor_facing_done:
		add	byte ptr [si+6],80h
		jc	sub01_phase_inc			; Jump if carry Set
		jmp	sub01_finalize

sub01_phase_inc:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+5],80h
		jnz	sub01_step_fwd_branch			; Jump if not zero
		call	phase_step_back
		jc	sub01_set_facing			; Jump if carry Set
		jmp	sub01_finalize

sub01_set_facing:
		or	byte ptr [si+5],80h
		jmp	sub01_finalize

sub01_step_fwd_branch:
		call	phase_step_fwd
		jc	sub01_clear_facing			; Jump if carry Set
		jmp	sub01_finalize

sub01_clear_facing:
		and	byte ptr [si+5],7Fh
		jmp	sub01_finalize

sub01_aim_setup:
		and	byte ptr [si+5],7Fh
		mov	al,11h
		cmp	al,[si+3]
		jb	sub01_aim_facing_chk			; Jump if below
		or	byte ptr [si+5],80h

sub01_aim_facing_chk:
		test	byte ptr [si+5],80h
		jz	sub01_aim_neg			; Jump if zero
		sub	al,[si+3]
		cmp	al,ds:aim_delta_pos
		je	sub01_aim_refresh			; Jump if equal
		jc	sub01_aim_pos_neg			; Jump if carry Set
		call	phase_step_fwd
		jc	sub01_aim_refresh			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	sub01_finalize

sub01_aim_pos_neg:
		call	phase_step_back
		jc	sub01_aim_rng_gate			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	sub01_finalize

sub01_aim_neg:
		mov	ah,[si+3]
		sub	ah,al
		cmp	ah,ds:aim_delta_neg
		je	sub01_aim_refresh			; Jump if equal
		jc	sub01_aim_neg_back			; Jump if carry Set
		call	phase_step_back
		jc	sub01_aim_refresh			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	sub01_finalize

sub01_aim_neg_back:
		call	phase_step_fwd
		jc	sub01_aim_rng_gate			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	sub01_finalize

sub01_aim_refresh:
		call	word ptr cs:eai7_rng_fn_ptr
		and	al,3
		dec	al
		add	al,8
		mov	ds:aim_delta_pos,al
		call	word ptr cs:eai7_rng_fn_ptr
		and	al,3
		sub	al,2
		add	al,9
		mov	ds:aim_delta_neg,al
		call	distance_check_5
		jnc	sub01_finalize			; Jump if carry=0
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short sub01_finalize

sub01_aim_rng_gate:
		call	word ptr cs:eai7_rng_fn_ptr
		and	al,1
		jz	sub01_aim_set_state3			; Jump if zero
		retn

sub01_aim_set_state3:
		or	byte ptr [si+9],3
		mov	byte ptr [si+6],4
		jmp	short sub01_finalize

sub01_state1_active:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		je	sub01_spawn_setup			; Jump if equal
		cmp	byte ptr [si+6],8
		jne	sub01_finalize			; Jump if not equal
		and	byte ptr [si+9],0FCh
		mov	byte ptr [si+6],0
		jmp	short sub01_finalize

sub01_spawn_setup:
		mov	al,[si+3]
		mov	ds:enemy_spawn_tile_b,al
		inc	al
		mov	ds:enemy_spawn_tile_a,al
		mov	al,[si+2]
		inc	al
		mov	ds:enemy_spawn_col_b,al
		mov	ds:enemy_spawn_col_a,al
		mov	bx,0A460h
		test	byte ptr [si+5],80h
		jnz	sub01_despawn_call			; Jump if not zero
		mov	bx,0A46Dh

sub01_despawn_call:
		call	word ptr cs:fight_cb_despawn
		jmp	short sub01_finalize
; ----------------------------------------------------------------
; sub01_spawn_param_tbl  -- spawn-cell offset/coord block (sub01)
; Two parallel records: facing+/facing- variants (row,col,row,col,...)
; ----------------------------------------------------------------

sub01_spawn_param_tbl:
		db	 00h, 00h, 30h, 00h, 14h, 00h	; row 0: rec A header
		db	 28h, 00h			; row 1: rec A tail
		db	7 dup (0)
		db	 2Fh, 00h, 14h, 04h, 28h, 00h	; row 2: rec B header
		db	 00h, 00h, 00h, 00h, 00h	; row 3: rec B tail

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
		db	8, 8				; trailing pad after eai7_main retn

eai7_main	endp

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
		add	si,offset eai7_collide_marker
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

sub01_hide_branch:
		mov	al,[si+15h]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:fight_cb_fire

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
		cmp	byte ptr [si+3],11h
		jae	dc5_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dc5_near_clear			; Jump if zero
		retn

dc5_near_clear:
		clc				; Clear carry flag
		retn

dc5_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dc5_far_clear			; Jump if not zero
		retn

dc5_far_clear:
		clc				; Clear carry flag
		retn

distance_check_5		endp

; ----------------------------------------------------------------
; sub01_alt_entry  -- dispatch idx 5 target (DS table entry A309).
; This slot maps to a single 'retn' (no-op state); reached via the
; init prologue 'jmp ds:[bx+0xA2FF]' when ([si+4]&0xF) == 5.
; ----------------------------------------------------------------

sub01_alt_entry:				; * No entry point in static analysis (dispatched via DS table)
		retn

; ----------------------------------------------------------------
; sub02_handler  -- AI sub-state 2 dispatch entry (DS table idx 6).
; Cooldown-seed prologue, visibility check, then phase/state machine
; for distance-check + RNG-gated facing flip.
; ----------------------------------------------------------------

sub02_handler:				; * No entry point in static analysis (dispatched via DS table)
		test	byte ptr [si+8],0FFh
		jnz	sub02_main			; Jump if not zero
		mov	byte ptr [si+8],40h	; '@'

sub02_main:
		test	byte ptr [si+5],20h	; ' '
		jz	sub02_visible			; Jump if zero
		jmp	sub02_hide_branch

sub02_visible:
		and	byte ptr [si+15h],0BFh
		call	sub01_collide_outer
		jc	sub02_collide_chk			; Jump if carry Set
		retn

sub02_collide_chk:
		test	byte ptr [si+9],1
		jnz	sub02_state1_active			; Jump if not zero
		call	distance_check_5
		jc	sub02_state0_alt			; Jump if carry Set

sub02_phase_inc:
						add	byte ptr [si+6],80h
						jc	sub02_phase_active			; Jump if carry Set
						jmp	sub02_finalize

sub02_phase_active:
						inc	byte ptr [si+6]
						and	byte ptr [si+6],3
						test	byte ptr [si+6],1
						jz	sub02_phase_low			; Jump if zero
						jmp	sub02_finalize

sub02_phase_low:
						mov	al,10h
						cmp	al,[si+3]
						jb	sub02_phase_high			; Jump if below
						call	phase_step_fwd
						jnc	sub02_set_facing			; Jump if carry=0
						jmp	sub02_finalize

sub02_set_facing:
						or	byte ptr [si+5],80h
						jmp	sub02_finalize

sub02_phase_high:
						call	phase_step_back
						jnc	sub02_clear_facing			; Jump if carry=0
						jmp	sub02_finalize

sub02_clear_facing:
						and	byte ptr [si+5],7Fh
						jmp	sub02_finalize

sub02_state0_alt:
						call	word ptr cs:eai7_rng_fn_ptr
						and	al,0C0h
						jnz	sub02_phase_inc			; Jump if not zero
				mov	al,[si+6]
				not	al
				and	al,1
				jnz	sub02_phase_inc			; Jump if not zero
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	short sub02_finalize

sub02_state1_active:
		add	byte ptr [si+6],80h
		jnc	sub02_finalize			; Jump if carry=0
		inc	byte ptr [si+6]
		mov	al,[si+6]
		and	al,7
		cmp	al,6
		je	sub02_spawn_setup			; Jump if equal
		or	al,al			; Zero ?
		jnz	sub02_finalize			; Jump if not zero
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],3
		jmp	short sub02_finalize

sub02_spawn_setup:
		mov	al,[si+3]
		mov	ds:spawn_cell_row_lo,al
		inc	al
		mov	ds:spawn_cell_row_hi,al
		mov	al,[si+2]
		inc	al
		mov	ds:spawn_cell_col_lo,al
		mov	ds:spawn_cell_col_hi,al
		mov	bx,0A704h
		test	byte ptr [si+5],80h
		jnz	sub02_despawn_call			; Jump if not zero
		mov	bx,0A711h

sub02_despawn_call:
		call	word ptr cs:fight_cb_despawn
		jmp	short sub02_finalize
; ----------------------------------------------------------------
; sub02_spawn_param_tbl  -- spawn-cell offset/coord block (sub02)
; Two parallel records: facing+/facing- variants (row,col,row,col,...)
; ----------------------------------------------------------------

sub02_spawn_param_tbl:
		db	 00h, 00h, 32h, 00h, 14h, 00h	; row 0: rec A header
		db	 28h, 00h			; row 1: rec A tail
		db	7 dup (0)
		db	 31h, 00h, 14h, 04h, 28h, 00h	; row 2: rec B header
		db	 00h, 00h, 00h, 00h, 00h	; row 3: rec B tail

sub02_hide_branch:
		mov	al,[si+5]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:fight_cb_fire

sub02_finalize:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn

; ----------------------------------------------------------------
; sub03_handler  -- AI sub-state 3 dispatch entry (DS table idx 8).
; Calls fight_cb_alt; if zero, tail-jumps to fight_cb_spawn.
; Otherwise runs cooldown-seed prologue, visibility check, then
; the multi-phase pursue/attack state machine using XLAT direction
; tables (dir_xlat_alt and 0xA8B1/0xA8B8/0xA8BFh anchors).
; ----------------------------------------------------------------

sub03_handler:				; * No entry point in static analysis (dispatched via DS table)
		call	word ptr cs:fight_cb_alt
		jnz	sub03_main			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

sub03_main:
		test	byte ptr [si+8],0FFh
		jnz	sub03_visible			; Jump if not zero
		mov	byte ptr [si+8],8

sub03_visible:
		test	byte ptr [si+5],20h	; ' '
		jz	sub03_state18_dispatch			; Jump if zero
		jmp	word ptr cs:fight_cb_fire

sub03_state18_dispatch:
		test	byte ptr [si+9],18h
		jz	sub03_blocked_chk			; Jump if zero
		jmp	sub03_state18_active

sub03_blocked_chk:
		call	word ptr cs:fight_cb_blocked
		jc	sub03_aim_chk			; Jump if carry Set
		retn

sub03_aim_chk:
		test	byte ptr [si+9],2
		jnz	sub03_step_setup			; Jump if not zero
		call	distance_check_6
		jc	sub03_step_setup			; Jump if carry Set
		cmp	al,0FFh
		je	sub03_step_setup			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		or	byte ptr [si+9],2
		retn

sub03_step_setup:
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	ax,48h
		test	byte ptr [si+5],80h
		jz	sub03_step_offset			; Jump if zero
		inc	ax

sub03_step_offset:
		xchg	si,di
		add	si,ax
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		jnz	sub03_phase_advance			; Jump if not zero
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn

sub03_phase_advance:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+9],2
		jnz	sub03_state2_chk			; Jump if not zero
		add	byte ptr [si+0Ah],10h
		jnc	sub03_state2_chk			; Jump if carry=0
		xor	byte ptr [si+9],80h
		retn

sub03_state2_chk:
		call	distance_check_6
		jnc	sub03_facing_branch			; Jump if carry=0
		and	byte ptr [si+9],0FDh

sub03_facing_branch:
		test	byte ptr [si+5],80h
		jz	sub03_step_pos_path			; Jump if zero
		call	word ptr cs:fight_cb_step_neg
		call	word ptr cs:fight_cb_step_neg
		jc	sub03_step_neg_done			; Jump if carry Set
		retn

sub03_step_neg_done:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		retn

sub03_step_pos_path:
		call	word ptr cs:fight_cb_step_pos
		call	word ptr cs:fight_cb_step_pos
		jc	sub03_step_pos_done			; Jump if carry Set
		retn

sub03_step_pos_done:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		retn

sub03_state18_active:
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],20h	; ' '
		jnz	sub03_xlat_setup			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	sub03_state_clear			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah

sub03_xlat_setup:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		dec	al
		and	al,7
		mov	bx,0A8BFh
		mov	cx,0A8B1h
		test	byte ptr [si+5],80h
		jnz	sub03_xlat_swap			; Jump if not zero
		mov	bx,dir_xlat_alt
		mov	cx,0A8B8h

sub03_xlat_swap:
		test	byte ptr [si+9],10h
		jnz	sub03_xlat_call			; Jump if not zero
		xchg	cx,bx

sub03_xlat_call:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	sub03_rng_gate			; Jump if carry Set
		retn

sub03_rng_gate:
		mov	byte ptr [si+9],0
		test	byte ptr [si+6],0FFh
		jnz	sub03_phase_reset			; Jump if not zero
		retn

sub03_phase_reset:
		mov	byte ptr [si+6],3
		retn

sub03_state_clear:
		and	byte ptr [si+9],0
		mov	byte ptr [si+6],3
		jmp	word ptr cs:fight_cb_blocked

distance_check_6		proc	near
		mov	al,ds:gvar_hero_x
		sub	al,[si+2]
		jns	dc6_abs_done			; Jump if not sign
		neg	al

dc6_abs_done:
		cmp	al,6
		mov	al,0FFh
		jc	dc6_in_range			; Jump if carry Set
		retn

dc6_in_range:
		cmp	byte ptr [si+3],11h
		jae	dc6_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dc6_near_clear			; Jump if zero
		retn

dc6_near_clear:
		clc				; Clear carry flag
		retn

dc6_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dc6_far_clear			; Jump if not zero
		retn

dc6_far_clear:
		clc				; Clear carry flag
		retn

distance_check_6		endp

; ----------------------------------------------------------------
; eai7_state_param_tail  -- trailing data table (no in-file caller).
; Sourcer mis-decodes these 30 bytes as 'add [bx+di],ax' etc. but
; they are actually a state/param lookup tail (small ints + 0/1
; flag bytes), referenced from external DS context via address
; arithmetic.  Kept as raw db to match the original byte layout.
; ----------------------------------------------------------------

eai7_state_param_tail:				; * No entry point in static analysis (data tail)
		db	 01h, 01h, 00h, 00h		; row 0: rec A start
		db	 00h, 07h, 07h, 03h		; row 1
		db	 03h, 04h, 04h, 04h		; row 2
		db	 05h, 05h, 02h, 01h		; row 3
		db	 01h, 00h, 00h, 07h		; row 4: rec B start
		db	 07h, 06h, 02h, 03h		; row 5
		db	 03h, 04h, 04h, 05h		; row 6
		db	 05h, 06h			; row 7: file ends here

seg_a		ends

		end	start
