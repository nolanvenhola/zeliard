
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
;  State machine (Type 8 -- AKMA boss-class aggressive attacker):
;
;    Primary dispatch by [si+4]&0xF (DS table at 0xA2C7):
;      idx 1 -> eai8_phase_reset_stub  (clear [si+6], retn)
;      idx 2 -> eai8_sub01_handler     (advance/charge, cooldown=0x30)
;      idx 3 -> eai8_sub02_handler     (multi-pass strafe-attack, =0x40)
;      idx 4 -> eai8_sub03_handler     (xlat-driven aim/fire, =0x60)
;
;    sub01 (advance):
;       hidden? --yes--> ai_fire
;       blocked --no--> retn
;            |yes
;            v
;       [si+9]&1 ? --no--> state0: distance_check_5 sets facing,
;            |yes              FF -> phase_inc; phase wraps -> step pos/neg;
;            |                 step blocked -> [si+9]=0, flip facing.
;            v
;       state1: dec [si+0Ah]; every 4 ticks recheck dist + step;
;       blocked -> [si+9]=0 (back to state0).
;
;    sub02 (multi-pass attack):
;       hidden? --> ai_fire;  blocked? --no--> retn
;       [si+9]&4 ? --yes--> spawn_setup (3-tick gather -> spawn_emit:
;            |              despawn into enemy_spawn_tile_*, [si+9]|=2)
;            |no
;       [si+9]&1 ? --yes--> state1_active (8-phase advance ->
;            |                set_state2: rng pick strafe fwd/back;
;            |                cmp_tile gates step pos/neg)
;            |              [si+9]&2 -> state2_clear ([si+9]&=~1, phase=0)
;            |no
;       attack_chk: rng_pick_facing -> phase_advance_helper;
;            rng_gate -> [si+9]=1 (advance phase).
;
;    sub03 (aim/fire): phase_inc; on phase-carry distance_check_8
;       drives rng_facing or aim_apply -> map_fwd/blocked + xlat
;       direction (dir_xlat_alt / dir_xlat_table) -> fight_cb_range;
;       carry -> flip facing.
;
;  Connections:
;    Loads:        none (loaded as data by 200FIGHT; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_range (6004h), fight_cb_step_neg (6008h),
;                  fight_cb_map_fwd (600Ch), fight_cb_step_pos (6010h),
;                  fight_cb_blocked (6014h), fight_cb_record_ofs (6028h),
;                  fight_cb_mark_adj (602Ah), fight_cb_tile_index (602Ch),
;                  fight_cb_cmp_tile (602Eh), fight_cb_fire (6034h),
;                  fight_cb_despawn (603Ah).
;    Called by:    200FIGHT enemy AI dispatch table (AKMA-type enemy slot;
;                  paired with sprite/arena module 317AKMA.BIN).
;    Reads/writes: gvar_hero_x (0FF35h aliased gvar_frame_cnt),
;                  gvar_proj_flag (0FFA2h); enemy slot record fields
;                  [si+0..si+16h]; spawn-cell tables enemy_spawn_tile_hi
;                  (0A666h), enemy_spawn_col_hi (0A667h),
;                  enemy_spawn_tile_lo (0A673h), enemy_spawn_col_lo
;                  (0A674h); direction xlats dir_xlat_alt (0A71Bh) and
;                  dir_xlat_table (0A723h).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Local macro: walk back along the 5-row vertical tile column and OR
; the tile-index byte onto the running collision mask in AL. Repeats
; 8 times in the bilateral collide_check_{left,right} unrolled loops.
; ----------------------------------------------------------------------
eai_or_tile	macro
		sub	si,24h
		call	word ptr cs:fight_cb_tile_index
		or	al,[si]
		endm

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_* not in zr3com.inc)
; ----------------------------------------------------------------------
gvar_hero_x		equ	0FF35h			; hero X tile position (global)
gvar_proj_flag		equ	0FFA2h			; projectile spawn flag


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
enemy_spawn_tile_hi	equ	0A666h			; spawn-cell row (phase hi)
enemy_spawn_col_hi	equ	0A667h			; spawn-cell col (phase hi)
enemy_spawn_tile_lo	equ	0A673h			; spawn-cell row (phase lo)
enemy_spawn_col_lo	equ	0A674h			; spawn-cell col (phase lo)
dir_xlat_table		equ	0A723h			; direction lookup table (xlat base)


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
dir_xlat_alt		equ	0A71Bh			; direction lookup table (alt facing)


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
; ----------------------------------------------------------------
; eai8_init_params  -- spawn parameter block (init/timer constants)
; ----------------------------------------------------------------

eai8_init_params:
		db	0FFh,0FFh,0FFh,0FFh, 00h, 00h	; row 0: 4xFF guard + zero pad
		db	 00h,0A0h,0A0h			; row 1: pad + A0,A0
		db	 3Ch, 50h, 50h			; row 2: timer constants 3C,50,50
		db	27 dup (0)
; ----------------------------------------------------------------
; eai8_jump_tbl_a  -- DS pointer table (CS-relative addresses A0xx..A2xx)
; Bank A: dispatch entries for sub-state idx 0..N (low-nibble of [si+4]).
; ----------------------------------------------------------------

eai8_jump_tbl_a:
		db	0B0h,0A0h,0FBh,0A0h, 46h,0A1h	; row 0: ptrs A0B0,A0FB,A146
		db	0A5h,0A1h,0E6h,0A1h, 00h, 00h	; row 1: ptrs A1A5,A1E6 + zero pad
		db	 00h, 00h, 00h, 00h,0ECh,0A0h	; row 2: zero pad + ptr A0EC
		db	 37h,0A1h, 96h,0A1h,0D7h,0A1h	; row 3: ptrs A137,A196,A1D7
		db	0FAh,0A1h, 00h, 00h, 00h, 00h	; row 4: ptr A1FA + zero pad
		db	 00h, 00h, 86h,0A2h, 00h, 00h	; row 5: zero pad + ptr A286
		db	 09h,0A2h, 54h,0A2h, 18h,0A2h	; row 6: ptrs A209,A254,A218
		db	 2Ch,0A2h, 7Ch,0A2h, 81h,0A2h	; row 7: ptrs A22C,A27C,A281
		db	 72h,0A2h, 77h,0A2h, 00h, 00h	; row 8: ptrs A272,A277 + zero pad
		db	 40h,0A2h, 9Ah,0A2h, 00h, 00h	; row 9: ptrs A240,A29A + zero pad
		db	 00h, 00h, 00h, 00h,0CEh,0A0h	; row 10: zero pad + ptr A0CE
		db	 19h,0A1h, 6Eh,0A1h,0BEh,0A1h	; row 11: ptrs A119,A16E,A1BE
		db	0E6h,0A1h, 00h, 00h, 00h, 00h	; row 12: ptr A1E6 + zero pad
		db	 00h, 00h,0ECh,0A0h, 37h,0A1h	; row 13: zero pad + ptrs A0EC,A137
		db	 96h,0A1h,0D7h,0A1h,0FAh,0A1h	; row 14: ptrs A196,A1D7,A1FA
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 15: zero pad
		db	 86h,0A2h, 00h, 00h, 09h,0A2h	; row 16: ptr A286 + pad + A209
		db	 54h,0A2h, 18h,0A2h, 2Ch,0A2h	; row 17: ptrs A254,A218,A22C
		db	 7Ch,0A2h, 81h,0A2h, 72h,0A2h	; row 18: ptrs A27C,A281,A272
		db	 77h,0A2h, 00h, 00h, 40h,0A2h	; row 19: ptr A277 + pad + A240
		db	 9Ah,0A2h			; row 20: ptr A29A
		db	7 dup (0)
; ----------------------------------------------------------------
; eai8_anim_idx_a  -- animation index/dispatch index table
; Small constants (01..04 grouped by 5) used as XLAT lookup feeding
; the state-dispatch jump table.
; ----------------------------------------------------------------

eai8_anim_idx_a:
		db	 01h, 02h, 03h, 04h, 00h, 01h	; row 0: 01,02,03,04,00,01
		db	 02h, 03h, 04h, 00h, 01h, 02h	; row 1: 02,03,04,00,01,02
		db	 03h, 04h, 00h, 01h, 02h, 11h	; row 2: 03,04,00,01,02,11
		db	 04h, 00h, 01h, 02h, 16h, 04h	; row 3: 04,00,01,02,16,04
		db	 00h, 01h, 02h, 1Bh, 04h, 00h	; row 4: 00,01,02,1B,04,00
; ----------------------------------------------------------------
; eai8_sprite_tbl_20  -- sprite tile-index table (frames 0x20..0x54)
; Frames stored as 4-byte ASCII-printable runs separated by 0x00.
; ----------------------------------------------------------------

eai8_sprite_tbl_20:
		db	20h				; frame 0 lead byte (' ')
		db	'!"#', 0			; frame 0 tail: 21,22,23 + sep
		db	' !"#', 0			; frame 1: 20,21,22,23 + sep
		db	' !"#', 0			; frame 2: 20,21,22,23 + sep
		db	' !"0', 0			; frame 3: 20,21,22,30 + sep
		db	' !"5', 0			; frame 4: 20,21,22,35 + sep
		db	' !":', 0			; frame 5: 20,21,22,3A + sep
		db	'?@AB'				; frame 6: 3F,40,41,42
		db	 02h, 47h, 48h, 49h, 4Ah, 02h	; row 0: flag + 47,48,49,4A + flag
		db	 4Fh, 50h, 51h, 52h, 02h, 05h	; row 1: 4F,50,51,52,flag,05
		db	 06h, 07h, 08h, 02h, 09h, 0Ah	; row 2: 06,07,08,flag,09,0A
		db	 0Bh, 0Ch, 02h, 0Dh, 0Eh, 0Fh	; row 3: 0B,0C,flag,0D,0E,0F
		db	 10h, 02h, 12h, 13h, 14h, 15h	; row 4: 10,flag,12,13,14,15
		db	 02h, 17h, 18h, 19h, 1Ah, 02h	; row 5: flag,17,18,19,1A,flag
		db	 1Ch				; row 6 lead: 1C
eai8_rng_fn_ptr		dw	1E1Dh
		db	 1Fh, 02h, 24h, 25h, 26h, 27h	; row 7: 1F,flag,24,25,26,27
		db	 02h, 28h, 29h, 2Ah, 2Bh, 02h	; row 8: flag,28,29,2A,2B,flag
		db	 2Ch, 2Dh, 2Eh, 2Fh, 02h, 31h	; row 9: 2C,2D,2E,2F,flag,31
		db	 32h, 33h, 34h, 02h, 36h, 37h	; row 10: 32,33,34,flag,36,37
		db	 38h, 39h, 02h, 3Bh, 3Ch, 3Dh	; row 11: 38,39,flag,3B,3C,3D
		db	 3Eh, 00h, 43h, 44h, 45h, 46h	; row 12: 3E,00,43,44,45,46
		db	 02h, 4Bh, 4Ch, 4Dh, 4Eh, 02h	; row 13: flag,4B,4C,4D,4E,flag
		db	 53h, 54h			; row 14: 53,54
; ----------------------------------------------------------------
; eai8_sprite_tbl_55  -- sprite tile-index table (frames 0x55..0xAC)
; Frames stored as 4-byte ASCII-printable runs separated by 0x00.
; ----------------------------------------------------------------

eai8_sprite_tbl_55:
		db	'UV', 0				; frame 0 tail: 55,56 + sep
		db	'WXYZ', 0			; frame 1: 57,58,59,5A + sep
		db	'[\]^', 0			; frame 2: 5B,5C,5D,5E + sep
		db	'_`ab', 0			; frame 3: 5F,60,61,62 + sep
		db	'cdef', 0			; frame 4: 63,64,65,66 + sep
		db	'WXYZ', 0			; frame 5: 57,58,59,5A + sep
		db	'[\]^', 0			; frame 6: 5B,5C,5D,5E + sep
		db	'ghij', 0			; frame 7: 67,68,69,6A + sep
		db	'klmn', 0			; frame 8: 6B,6C,6D,6E + sep
		db	'opqr', 0			; frame 9: 6F,70,71,72 + sep
		db	'stuv', 0			; frame 10: 73,74,75,76 + sep
		db	'wxyz', 0			; frame 11: 77,78,79,7A + sep
		db	'{|}~', 0			; frame 12: 7B,7C,7D,7E + sep
		db	'opqr', 0			; frame 13: 6F,70,71,72 + sep
		db	'stuv', 0			; frame 14: 73,74,75,76 + sep
		db	 7Fh, 80h, 81h, 82h, 00h, 83h	; row 0: 7F,80,81,82,00,83
		db	 84h, 85h, 86h, 00h, 87h, 88h	; row 1: 84,85,86,00,87,88
		db	 89h, 8Ah, 00h, 8Bh, 8Ch, 8Dh	; row 2: 89,8A,00,8B,8C,8D
		db	 8Eh, 02h, 8Fh, 90h, 91h, 92h	; row 3: 8E,flag,8F,90,91,92
		db	 00h, 93h, 94h, 95h, 96h, 00h	; row 4: 00,93,94,95,96,00
		db	 97h, 98h, 99h, 9Ah, 00h, 9Bh	; row 5: 97,98,99,9A,00,9B
		db	 9Ch, 9Dh, 9Eh, 00h,0A3h,0A4h	; row 6: 9C,9D,9E,00,A3,A4
		db	 95h, 96h, 00h,0A5h,0A6h, 95h	; row 7: 95,96,00,A5,A6,95
		db	 96h, 00h, 93h, 94h, 95h, 96h	; row 8: 96,00,93,94,95,96
		db	 00h, 97h, 98h, 99h, 9Ah, 00h	; row 9: 00,97,98,99,9A,00
		db	 9Bh, 9Ch, 9Dh, 9Eh, 00h, 9Fh	; row 10: 9B,9C,9D,9E,00,9F
		db	0A0h, 95h, 96h, 00h,0A1h,0A2h	; row 11: A0,95,96,00,A1,A2
		db	 95h, 96h, 00h,0A7h,0A8h, 95h	; row 12: 95,96,00,A7,A8,95
		db	 96h, 00h,0A9h,0AAh,0ABh,0ACh	; row 13: 96,00,A9,AA,AB,AC
; ----------------------------------------------------------------
; eai8_sprite_tbl_ad  -- sprite tile-index table (frames 0xAD..0xFC)
; Boss-class extended frame set with 00/01/02 phase-flag separators.
; ----------------------------------------------------------------

eai8_sprite_tbl_ad:
		db	 00h,0ADh,0AEh,0AFh,0B0h, 02h	; row 0: 00,AD,AE,AF,B0,flag
		db	0B1h,0B2h,0B3h,0B4h, 02h,0B5h	; row 1: B1,B2,B3,B4,flag,B5
		db	0B6h,0B7h,0B8h, 02h,0B9h,0BAh	; row 2: B6,B7,B8,flag,B9,BA
		db	0BBh,0BCh, 02h,0BDh,0BEh,0BFh	; row 3: BB,BC,flag,BD,BE,BF
		db	0C0h, 02h,0C1h,0C2h,0C3h,0C4h	; row 4: C0,flag,C1,C2,C3,C4
		db	 02h,0C5h,0C6h,0C7h,0C8h, 02h	; row 5: flag,C5,C6,C7,C8,flag
		db	0C9h,0CAh, 00h, 00h, 01h,0CBh	; row 6: C9,CA,00,00,01,CB
		db	0CCh,0CDh,0CEh, 01h,0CFh,0D0h	; row 7: CC,CD,CE,01,CF,D0
		db	0D1h,0D2h, 01h,0D3h,0D4h,0D5h	; row 8: D1,D2,01,D3,D4,D5
		db	0D6h, 00h,0D7h,0D8h,0D9h,0DAh	; row 9: D6,00,D7,D8,D9,DA
		db	 00h,0DBh,0DCh,0DDh,0DEh, 00h	; row 10: 00,DB,DC,DD,DE,00
		db	0DFh,0E0h,0E1h,0E2h, 00h,0DBh	; row 11: DF,E0,E1,E2,00,DB
		db	0DCh,0DDh,0DEh, 02h,0D7h,0D8h	; row 12: DC,DD,DE,flag,D7,D8
		db	0D9h,0DAh, 02h,0DBh,0DCh,0DDh	; row 13: D9,DA,flag,DB,DC,DD
		db	0DEh, 02h,0DFh,0E0h,0E1h,0E2h	; row 14: DE,flag,DF,E0,E1,E2
		db	 02h,0DBh,0DCh,0DDh,0DEh, 01h	; row 15: flag,DB,DC,DD,DE,01
		db	0D7h,0D8h,0D9h,0DAh, 01h,0DBh	; row 16: D7,D8,D9,DA,01,DB
		db	0DCh,0DDh,0DEh, 01h,0DFh,0E0h	; row 17: DC,DD,DE,01,DF,E0
		db	0E1h,0E2h, 01h,0DBh,0DCh,0DDh	; row 18: E1,E2,01,DB,DC,DD
		db	0DEh, 00h,0E3h,0E4h,0E5h,0E6h	; row 19: DE,00,E3,E4,E5,E6
		db	 00h,0E3h,0E4h,0E5h,0E6h, 00h	; row 20: 00,E3,E4,E5,E6,00
		db	0E3h,0E4h,0E5h,0E6h, 00h,0E3h	; row 21: E3,E4,E5,E6,00,E3
		db	0E4h,0E5h,0E6h, 00h,0E3h,0E4h	; row 22: E4,E5,E6,00,E3,E4
		db	0E5h,0E6h, 00h,0E3h,0E4h,0E5h	; row 23: E5,E6,00,E3,E4,E5
		db	0E6h, 00h,0EBh,0ECh,0EDh,0EEh	; row 24: E6,00,EB,EC,ED,EE
		db	 02h,0EBh,0ECh,0EDh,0EEh, 01h	; row 25: flag,EB,EC,ED,EE,01
		db	0E7h,0E8h,0E9h,0EAh, 01h,0EFh	; row 26: E7,E8,E9,EA,01,EF
		db	0F0h,0F1h,0F2h, 02h,0F3h,0F3h	; row 27: F0,F1,F2,flag,F3,F3
		db	0F3h,0F3h, 02h,0F4h,0F4h,0F5h	; row 28: F3,F3,flag,F4,F4,F5
		db	0F5h, 02h,0F6h, 00h,0F3h,0F7h	; row 29: F5,flag,F6,00,F3,F7
		db	 02h, 00h, 00h,0F7h,0F8h, 02h	; row 30: flag,00,00,F7,F8,flag
		db	0F9h,0FAh,0FBh,0FCh		; row 31 tail: F9,FA,FB,FC
; ----------------------------------------------------------------
; eai8_phase_ptr_tbl  -- 5-entry phase-jump pointer table (CS-relative)
; Indexed by sub-phase counter [si+0Ah]; entries at A2A9..A2B5.
; ----------------------------------------------------------------

eai8_phase_ptr_tbl:
		db	0A9h,0A2h			; row 0: ptr A2A9
		db	0A9h,0A2h,0ADh,0A2h,0B1h,0A2h	; row 1: ptrs A2A9,A2AD,A2B1
		db	0B5h,0A2h			; row 2: ptr A2B5
; ----------------------------------------------------------------
; eai8_rng_shift_const  -- RNG output shift/mask constants
; Used by RNG-driven facing/attack pick (and cooldown gating).
; ----------------------------------------------------------------

eai8_rng_shift_const:
		db	 0Bh, 0Bh, 0Bh, 0Bh		; row 0: 0B x4
		db	 05h, 05h, 00h, 00h, 0Bh, 0Bh	; row 1: 05,05,00,00,0B,0B
		db	 05h, 05h, 0Bh, 05h, 00h, 00h	; row 2: 05,05,0B,05,00,00
; ----------------------------------------------------------------
; eai8_unk_data_at_0x276  -- mixed opcode/ptr block (boss-attack helper)
; Bank-A pointers (A2C7..A68F) embedded in raw inline opcode stream
; that is patched/copied at runtime (likely a self-modified handler
; for the boss multi-pass attack pattern).  Tail is opcode bytes for
; the dispatch prologue (mov bl,[si+4]; and bl,0F; jmp ds:[bx+...]).
; ----------------------------------------------------------------

eai8_unk_data_at_0x276:
		db	 8Ah, 5Ch, 04h, 80h,0E3h, 0Fh	; row 0: opcode (mov bl,[si+4]; and bl,0F)
		db	 32h,0FFh, 03h,0DBh,0FFh,0A7h	; row 1: opcode (xor bh,bh; add bx,bx; jmp ds:[bx+...])
		db	0C7h,0A2h,0D2h,0A2h,0D1h,0A2h	; row 2: ptrs A2C7,A2D2,A2D1
		db	 83h,0A4h, 38h,0A5h, 8Fh,0A6h	; row 3: ptrs A483,A538,A68F
		db	0C3h,0F6h, 44h, 08h,0FFh, 75h	; row 4: opcode (retn; test [si+8],FF; jnz)
		db	 04h,0C6h, 44h, 08h, 64h,0F6h	; row 5: opcode (mov [si+8],64; test ...)
		db	 44h, 05h, 20h, 74h, 03h,0E9h	; row 6: opcode (test [si+5],20; jz; jmp far)
		db	 80h, 00h, 80h, 64h, 15h,0BFh	; row 7: opcode (and [si+15],BF disp)
		db	0F6h, 44h, 09h, 01h, 75h, 2Ah	; row 8: opcode (test [si+9],1; jnz +2A)
		db	 80h, 44h, 06h, 80h, 73h, 03h	; row 9: opcode (add [si+6],80; jnc +03)
		db	0E8h, 4Bh, 00h,0C6h, 44h, 0Ah	; row 10: opcode (call +4B; mov [si+0A],0)
		db	 00h,0E8h, 5Eh, 04h, 72h, 0Dh	; row 11: opcode (00; call +45E; jc +0D)
		db	 3Ch,0FFh, 74h, 4Dh, 80h, 64h	; row 12: opcode (cmp al,FF; jz +4D)
		db	 05h, 7Fh, 08h, 44h, 05h,0EBh	; row 13: opcode (and [si+5],7F; or ...)
		db	 44h, 80h,0FCh, 0Fh, 73h, 3Fh	; row 14: opcode (jmp; cmp ah,0F; jnc +3F)
		db	 80h, 4Ch, 09h, 01h,0EBh, 39h	; row 15: opcode (or [si+9],1; jmp +39)
		db	0FEh, 44h, 0Ah, 8Ah, 44h, 0Ah	; row 16: opcode (inc [si+0A]; mov al,[si+0A])
		db	 3Ch, 10h, 74h, 1Ah,0F6h, 44h	; row 17: opcode (cmp al,10; jz +1A)
		db	 05h, 80h, 75h, 0Ah,0E8h,0D2h	; row 18: opcode (test [si+5],80; jnz +0A)
		db	 00h, 72h, 0Fh,0E8h, 12h, 00h	; row 19: opcode (jc +0F; call +12)
		db	0EBh, 1Fh,0E8h, 43h, 00h, 72h	; row 20: opcode (jmp +1F; call +43; jc)
		db	 05h,0E8h, 08h, 00h,0EBh, 15h	; row 21: opcode (+05; call +08; jmp +15)
		db	 80h, 64h, 09h,0FEh,0EBh, 0Fh	; row 22: opcode (and [si+9],FE; jmp +0F)
		db	0FEh, 44h, 06h, 80h, 7Ch, 06h	; row 23: opcode (inc [si+6]; cmp al,06)
		db	 06h, 73h, 01h,0C3h		; row 24 tail: opcode (push es; jnc +01; retn)

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
		eai_or_tile
		eai_or_tile
		eai_or_tile
		eai_or_tile
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
		eai_or_tile
		eai_or_tile
		eai_or_tile
		eai_or_tile
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
; ----------------------------------------------------------------
; eai8_spawn_param_blk  -- spawn param block (post-spawn render record)
; Two 16-byte sub-blocks (path-A / path-B) with offsets, sprite ids,
; and trailing zero pad consumed by the projectile spawn callback.
; ----------------------------------------------------------------

eai8_spawn_param_blk:
		db	 00h, 00h, 2Ah, 00h, 12h, 00h	; row 0: x-offset 0, y-offset 2A, sprite 12
		db	 50h				; row 1: speed/timer 50
		db	8 dup (0)
		db	 2Bh, 00h, 12h, 04h, 01h, 00h	; row 2: alt y-offset 2B, sprite 12, flag 04, 01
		db	 00h, 00h, 00h, 00h, 00h	; row 3: zero pad (5 bytes)

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
; ----------------------------------------------------------------
; eai8_xlat_dir_tbl  -- 16-byte XLAT direction lookup table
; Local fallback table referenced by sub03 dir-translate path; maps
; phase-counter 0..F to a tile-step delta (0/1/3/4/5/7).
; ----------------------------------------------------------------

eai8_xlat_dir_tbl:
		db	0, 0, 1, 0, 0, 0		; row 0: 0,0,1,0,0,0
		db	7, 0, 4, 4, 3, 4		; row 1: 7,0,4,4,3,4
		db	4, 4, 5, 4			; row 2: 4,4,5,4

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