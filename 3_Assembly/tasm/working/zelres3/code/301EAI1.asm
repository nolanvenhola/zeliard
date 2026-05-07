
PAGE  59,132

;==========================================================================
;
;  301EAI1.BIN - Multi-Enemy AI Handler (zelres3 chunk 2)
;
;  Per IDA decompilation in 3_Assembly/ida/eai1.asm: this is a SHARED
;  AI handler used by multiple regular enemies (slug, bat, frog, rat),
;  not a CRAB-specific handler. The enemy-type discrimination happens
;  via frame-pointer tables embedded in the chunk header:
;    slug_walk_right_frames, bat_fly_frames, frog_jump_right_frames,
;    rat_run_right_frames, bat_dive_frames, slug_idle_frames_set0..3.
;
;  CRAB has its own self-contained AI in 309CRAB.BIN (Cangrejo_AI_proc
;  per IDA crab.asm) and is NOT paired with this module despite the
;  resource_name_table listing them in alternating order.
;
;  The battle engine calls into these handlers via a state-dispatch
;  jump table stored in the enemy slot record (si+9 = state byte).
;
;  Shared calling convention (same across EAI1..EAI8):
;    SI -> active enemy slot record (game_seg:...)
;    [si+0]  = X position (word)
;    [si+2]  = tile X / row coord (byte)
;    [si+3]  = tile Y / col coord (byte)
;    [si+5]  = attribute/facing byte (bit7 = direction, bit6 = visible, bit5 = hit)
;    [si+6]  = animation phase / tick counter
;    [si+7]  = aux state
;    [si+8]  = attack cooldown
;    [si+9]  = state/substate (rotated nibbles used as dispatch index)
;    [si+Ah] = secondary counter
;
;  Each handler block is entered by dispatch (jmp word ptr ds:[...+bx])
;  where each block ends in 'retn' and is marked ';* No entry point'
;  by Sourcer because static analysis cannot see the tables in DS.
;
;  Resource table references visible in the header data (addresses 6004h..6034h):
;    6004-603A are function pointers in the shared fight-engine callback
;    table (used by every EAI handler).
;    0A2xxh / 0A7xxh are lookup tables in this chunk's data area.
;    0FF2Eh / 0FF35h / 0FF36h are shared game-state byte flags.
;
;  State machine (generic regular-enemy AI, supports slug/bat/frog/rat
;  per IDA — labels below were originally crab-specific guesses, the
;  actual enemy-type-specific behavior is selected via frame-table
;  pointers stored in the chunk header):
;
;    Primary dispatch by [si+4]&0xF (table at 0xA266):
;      idx 2 -> crab_ai_main_entry      (walk/seek main)
;      idx 3 -> crab_attack_state_a     (jump-attack pattern A)
;      idx 4 -> crab_attack_state_b     (jump-attack pattern B)
;      idx 5 -> crab_pincer_state       (pincer/grab sequence)
;
;    crab_ai_main_entry: secondary dispatch by [si+9] hi-nibble bits 6:5
;    via crab_tbl_a[bx]:
;
;      sub00 (idle)  --visible+pos_ok--> sub01 (phase advance to 0x80)
;        |                                   |
;        |  pos!=ok  -> [si+9]=0x40          v
;                                        sub02 (chase / range select)
;                                            |
;            +-------blocked-----------------+
;            v                               v
;        sub02 jumps to [si+9]=0xC0      sub03 (step cycle)
;                                            |
;                                       step done -> [si+9]=0
;                                       (phase wraps back to sub00)
;
;    Attack pattern handlers seed [si+8] cooldown then either:
;      - jmp ai_hide_fn (when [si+5] & 0x20 visibility flag)
;      - run xlat-driven step pattern via crab_rotate_a/b tables
;      - dist_check_8 / dist_check_6 gate transitions back to walk
;
;  Connections:
;    Loads:        none (loaded as data by 200FIGHT; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_range (6004h), fight_cb_alt_b (6006h),
;                  fight_cb_step_neg (6008h), fight_cb_step_neg_2 (600Ah),
;                  fight_cb_map_fwd (600Ch), fight_cb_map_back (600Eh),
;                  fight_cb_step_pos (6010h), fight_cb_step_pos_2 (6012h),
;                  fight_cb_blocked (6014h), fight_cb_dist_check (6016h),
;                  fight_cb_aux_18 (6018h), fight_cb_aux_1a (601Ah),
;                  fight_cb_record_ofs (6028h), fight_cb_mark_adj (602Ah),
;                  fight_cb_cmp_tile (602Eh), fight_cb_alt (6030h),
;                  fight_cb_spawn (6032h); also a local function pointer
;                  crab_facing_fn_ptr stored in DS.
;    Called by:    200FIGHT enemy AI dispatch table for the regular-enemy
;                  slots (slug/bat/frog/rat per IDA eai1.asm). Frame data
;                  for those enemies lives in ENPx.GRP graphics chunks,
;                  loaded separately by the fight engine.
;    Reads/writes: gvar_rng_state (0FF2Eh aliased gvar_death_flag),
;                  gvar_frame_cnt (0FF35h), gvar_enemy_cnt (0FF36h);
;                  enemy slot record fields [si+0..si+Ah] (X pos, tile
;                  coords, facing, anim phase, attack cooldown, state);
;                  CRAB lookup tables crab_tbl_a (0A29Dh), crab_tbl_b
;                  (0A2D0h), crab_rotate_a (0A723h), crab_rotate_b (0A72Fh).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_* not in zr3com.inc)
; ----------------------------------------------------------------------
gvar_rng_state	equ	0FF2Eh			; random/LFSR state word


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
crab_dispatch_tbl_base	equ	0A262h		; JMP base for `[0A262h][bx]` — first valid entry at +4 (idx 0/1 garbage)
crab_tbl_a	equ	0A29Dh			; crab movement/direction lookup table
crab_tbl_b	equ	0A2D0h			; crab secondary lookup table
crab_rotate_a	equ	0A723h			; crab rotation/swap pattern table
crab_rotate_b	equ	0A72Fh			; crab rotation/swap pattern table B


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

crab_ai_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer forced 'start:' here as code, but the bytes are a 4-byte length
;  header, an init src ptr, and a small state buffer (matches 309CRAB layout).
;  The "instructions" Sourcer prints below assemble to the original data
;  bytes; they do not execute.
; -------------------------------------------------------------------------

start:

file_header:
		aaa				; byte 37h (file_size word lo)
		pop	es			; byte 07h (file_size word hi -> 0x0737)
		add	[bx+si],al		; bytes 00 00 (pad)

crab_ai_init_src:
		push	sp			; byte 54h
		mov	byte ptr ds:[0],al	; bytes A2 00 00 -> init src ptr 0xA254 + 0
		add	[bx+si],al		; bytes 00 00
		inc	ax			; byte 40h
		mov	crab_anim_phase_marker,al	; bytes A2 03 02 -> ptr to anim marker
		add	ax,3			; bytes 05 03 00
		add	[bx+si],al		; bytes 00 00
		add	[di],al			; bytes 00 05
		add	ax,80Fh			; bytes 05 0F 08

		db	28 dup (0)		; reserved / padding (offsets 0x018-0x033)

; -------------------------------------------------------------------------
;  Animation frame pointer tables (word ptr[], in DS at game_seg).
;  Each word = runtime address of a frame data block within this file.
;  Same dual-table layout as 309CRAB.
; -------------------------------------------------------------------------

crab_frame_ptr_tbl_a	label	word		; offset 0x034 -- group A pointers
		db	0B0h,0A0h,0F6h,0A0h, 1Eh,0A1h	; -> 0xA0B0, 0xA0F6, 0xA11E
		db	 64h,0A1h, 00h, 00h, 00h, 00h	; -> 0xA164, slot4=empty
		db	 00h, 00h, 00h, 00h,0A0h,0A1h	; slots 5-7 empty, -> 0xA1A0
		db	0AFh,0A1h,0BEh,0A1h,0CDh,0A1h	; -> 0xA1AF, 0xA1BE, 0xA1CD
		db	8 dup (0)			; reserved

crab_frame_ptr_tbl_b	label	word		; offset 0x048 -- group B pointers
		db	 2Ch,0A2h, 2Ch,0A2h,0DCh,0A1h	; -> 0xA22C, 0xA22C (dup), 0xA1DC
		db	 13h,0A2h,0EBh,0A1h,0FFh,0A1h	; -> 0xA213, 0xA1EB, 0xA1FF
		db	 1Dh,0A2h, 00h, 00h, 22h,0A2h	; -> 0xA21D, slot4=empty, 0xA222
		db	 27h,0A2h			; -> 0xA227
		db	12 dup (0)			; reserved

crab_frame_ptr_tbl_c	label	word		; offset 0x06C -- group C pointers
		db	0D3h,0A0h, 0Ah,0A1h, 41h,0A1h	; -> 0xA0D3, 0xA10A, 0xA141
		db	 82h,0A1h			; -> 0xA182
		db	8 dup (0)			; reserved

crab_frame_ptr_tbl_d	label	word		; offset 0x07C -- group D pointers (mirrors A tail)
		db	0A0h,0A1h,0AFh,0A1h,0BEh,0A1h	; -> 0xA1A0, 0xA1AF, 0xA1BE
		db	0CDh,0A1h			; -> 0xA1CD
		db	8 dup (0)			; reserved

crab_frame_ptr_tbl_e	label	word		; offset 0x08C -- group E pointers (mirrors B)
		db	 2Ch,0A2h, 2Ch,0A2h,0DCh,0A1h	; -> 0xA22C, 0xA22C, 0xA1DC
		db	 13h,0A2h,0EBh,0A1h,0FFh,0A1h	; -> 0xA213, 0xA1EB, 0xA1FF
		db	 1Dh,0A2h, 00h, 00h, 22h,0A2h	; -> 0xA21D, empty, 0xA222
		db	 27h,0A2h			; -> 0xA227
		db	13 dup (0)			; reserved

; -------------------------------------------------------------------------
;  Sprite/tile-index frame data (file offsets 0x0B5..0x248, with the 5-byte
;  tail of the preceding `13 dup(0)` padding aliased as the leading row of
;  crab_frame_00 via ptr 0xA0B0).  Each frame is a sequence of tile-index
;  bytes terminated by 00h/01h/02h row markers (matches 303EAI3/309CRAB
;  layout).  The frame ptr tables above index into this region.
;  Two ptr targets land mid-frame and are aliased as code-side data refs:
;    - word at 0x11A (`crab_facing_fn_ptr`)  = 5C62h, called via
;        `call cs:crab_facing_fn_ptr` (returns AL with bit7 = facing dir).
;    - byte at 0x203 (`crab_anim_phase_marker`) = 2, written via
;        `mov crab_anim_phase_marker, al` in the bogus prologue.
; -------------------------------------------------------------------------

crab_frame_00:					; offset 0x0B5 -> ptr 0xA0B0 (5 leading zeros from padding tail) -- group A[0] body pose
		db	 19h, 1Ah, 1Bh, 1Ch, 00h, 1Dh	; row 0
		db	 1Eh, 1Fh, 20h, 00h, 21h, 22h	; row 1
		db	 23h, 24h, 00h, 25h, 26h, 27h	; row 2
		db	 28h, 00h, 29h, 2Ah, 2Bh, 2Ch	; row 3
		db	 00h, 2Dh, 2Eh, 2Fh, 30h, 00h	; row 4

crab_frame_01:					; offset 0x0D3 -> ptr 0xA0D3 -- group C[0] body pose alt
		db	 31h, 32h, 33h, 34h, 00h, 19h	; row 0
		db	 1Ah, 1Bh, 1Ch, 00h		; row 1 tail (re-uses frame_00 row 0 head)
		db	'5678', 0			; row 2 (tile bytes 35-38 + term)
		db	'9:;<', 0			; row 3 (tiles 39-3C)
		db	'=>?@', 0			; row 4 (tiles 3D-40)
		db	'ABCD', 0			; row 5 (tiles 41-44)
		db	'EFGH', 0			; row 6 (tiles 45-48)

crab_frame_02:					; offset 0x0F6 -> ptr 0xA0F6 -- group A[1] short-pose
		db	'IJKL', 0			; row 0 (tiles 49-4C)
		db	'M', 0				; row 1 (single-tile + term)
		db	'OP', 0				; row 2 (tiles 4F-50)
		db	'Q', 0				; row 3 (single tile)
		db	'RS', 0				; row 4 (tiles 52-53)

crab_frame_03:					; offset 0x10A -> ptr 0xA10A -- group C[1] short-pose
		db	'TUOP', 0			; row 0 (tiles 54-55, 4F-50)
		db	'VWXY'				; row 1 head (tiles 56-59, no term)
		db	 00h, 00h, 5Bh, 5Ch, 5Dh, 00h	; row 1 tail / row 2 (5 leading zeros + tiles 5B-5D)
		db	 00h, 5Eh, 5Fh, 60h, 00h	; row 3 (tiles 5E-60)
		db	61h				; row 4 head (tile 61)
crab_facing_fn_ptr		dw	5C62h	; word at 0x11A: facing/dir helper fn ptr (overlaps tile bytes 62 5C)
		db	 5Dh, 00h		; row 4 tail (tile 5D + term)

crab_frame_04:					; offset 0x11E -> ptr 0xA11E -- group A[2] mid pose
		db	 63h, 64h, 65h, 66h		; row 0 head (tiles 63-66)
		db	 00h, 75h, 76h, 77h, 78h, 00h	; row 0 term + row 1 (tiles 75-78)
		db	 75h, 76h, 79h, 78h, 00h, 7Ah	; row 2 (tiles 75,76,79,78) + row 3 head (7A)
		db	 7Bh, 7Ch, 7Dh, 00h, 7Eh, 7Bh	; row 3 tail + row 4 head (7E,7B)
		db	 7Fh, 80h, 00h, 81h, 82h, 83h	; row 4 tail + row 5 head (81-83)
		db	 84h, 00h, 85h, 86h, 87h, 88h	; row 5 tail + row 6 head (85-88)
		db	 00h, 89h			; row 6 term + row 7 head (89)

crab_frame_05:					; offset 0x141 -> ptr 0xA141 -- group C[2] mid pose alt
		db	 8Ah, 8Bh, 8Ch, 00h, 8Dh	; row 0 (tiles 8A-8C) + row 1 head (8D)
		db	 8Eh, 8Fh, 90h, 00h, 8Dh	; row 1 tail + row 2 head (8D)
		db	 8Eh, 8Fh, 91h, 00h, 92h, 93h	; row 2 tail + row 3 head (92,93)
		db	 94h, 95h, 00h, 92h, 96h, 97h	; row 3 tail + row 4 head (92,96,97)
		db	 98h, 00h, 99h, 9Ah, 9Bh, 9Ch	; row 4 tail + row 5 head (99-9C)
		db	 00h, 9Dh, 9Eh, 9Fh,0A0h, 00h	; row 5 term + row 6 (tiles 9D-A0)

crab_frame_06:					; offset 0x164 -> ptr 0xA164 -- group A[3] long pose
		db	0A1h,0A2h,0A3h,0A4h, 00h, 67h	; row 0 (tiles A1-A4) + row 1 head (67)
		db	 68h, 69h, 6Ah, 00h, 6Bh, 6Ch	; row 1 tail + row 2 head (6B,6C)
		db	 6Dh, 6Eh, 00h, 6Fh, 70h, 71h	; row 2 tail + row 3 head (6F-71)
		db	 72h, 00h, 73h, 74h,0E0h,0E1h	; row 3 tail + row 4 head (73,74,E0,E1)
		db	 00h,0F2h,0F3h,0F4h,0F5h, 00h	; row 4 term + row 5 (tiles F2-F5)

crab_frame_07:					; offset 0x182 -> ptr 0xA182 -- group C[3] long pose alt
		db	0F6h,0F7h,0F4h,0F5h, 00h,0E2h	; row 0 (tiles F6,F7,F4,F5) + row 1 head (E2)
		db	0E3h,0E4h,0E5h, 00h,0E6h,0E7h	; row 1 tail + row 2 head (E6,E7)
		db	0E8h,0E9h, 00h,0EAh,0EBh,0ECh	; row 2 tail + row 3 head (EA-EC)
		db	0EDh, 00h,0EEh,0EFh,0F0h,0F1h	; row 3 tail + row 4 head (EE-F1)
		db	 00h,0F2h,0F3h,0F4h,0F5h, 00h	; row 4 term + row 5 (tiles F2-F5)

crab_frame_08:					; offset 0x1A0 -> ptr 0xA1A0 (group A[4] / D[0]) -- attack frame head
		db	0F6h,0F7h,0F4h,0F5h, 00h,0A5h	; row 0 (tiles F6,F7,F4,F5) + row 1 head (A5)
		db	0A6h,0A7h,0A8h, 00h,0A9h,0AAh	; row 1 tail + row 2 head (A9,AA)
		db	0ABh,0ACh, 00h			; row 2 tail (tiles AB,AC + term)

crab_frame_09:					; offset 0x1AF -> ptr 0xA1AF (group A[5] / D[1]) -- attack frame mid
		db	0ADh,0AEh,0AFh			; row 0 head (tiles AD-AF)
		db	0B0h, 00h,0B1h,0B2h,0B3h,0B4h	; row 0 tail + row 1 head (B1-B4)
		db	 00h,0B5h,0B6h,0B7h,0B8h, 00h	; row 1 term + row 2 (tiles B5-B8)

crab_frame_0a:					; offset 0x1BE -> ptr 0xA1BE (group A[6] / D[2]) -- attack frame tail
		db	0B9h,0BAh,0BBh,0BCh, 00h,0BDh	; row 0 (tiles B9-BC) + row 1 head (BD)
		db	0BEh,0BFh,0C0h, 00h,0C1h,0C2h	; row 1 tail + row 2 head (C1,C2)
		db	0C3h,0C4h, 00h			; row 2 tail (tiles C3,C4 + term)

crab_frame_0b:					; offset 0x1CD -> ptr 0xA1CD (group A[7] / D[3]) -- aux pose
		db	 00h, 00h,0C7h			; row 0 (2 leading zeros + tile C7)
		db	0C8h, 00h,0F8h,0F9h,0FAh,0FBh	; row 1 (tile C8 + term) + row 2 head (F8-FB)
		db	 00h,0FCh,0FDh, 5Ah, 4Eh, 00h	; row 2 term + row 3 (tiles FC,FD,5A,4E)
		db	 00h, 00h,0C5h,0C6h		; row 4 (2 leading zeros + tiles C5,C6)

crab_frame_0c:					; offset 0x1DC -> ptr 0xA1DC (group B[2]) -- pincer/walk frame A (rows separated by 01h)
		db	 01h, 01h			; row 0 separator + row 1 separator (empty rows)
		db	 02h, 03h, 04h, 01h, 05h, 06h	; row 2 (tiles 02-04) + row 3 head (05,06)
		db	 07h, 08h, 01h			; row 3 tail (tiles 07,08 + sep)

crab_frame_0d:					; offset 0x1EB -> ptr 0xA1EB (group B[4]) -- walk step
		db	 09h, 0Ah, 0Bh			; row 0 head (tiles 09-0B)
		db	 0Ch, 00h, 0Dh, 0Eh, 0Fh, 10h	; row 0 tail + row 1 (tiles 0D-10)
		db	 00h, 11h, 12h, 13h, 14h, 00h	; row 2 (tiles 11-14)
		db	 15h, 16h, 17h, 18h, 00h	; row 3 (tiles 15-18)

crab_frame_0e:					; offset 0x1FF -> ptr 0xA1FF (group B[5]) -- walk step alt
		db	 11h				; row 0 head (tile 11)
		db	 12h, 13h, 14h			; row 0 tail (tiles 12-14)
crab_anim_phase_marker		db	2	; byte at 0x203: anim phase initializer (also a tile byte for frame 0e row 0 term)
		db	 0Dh, 0Eh, 0Fh, 10h, 02h, 11h	; row 1 (tiles 0D-10, sep 02) + row 2 head (11)
		db	 12h, 13h, 14h, 02h, 15h, 16h	; row 2 tail + row 3 head (15,16)
		db	 17h, 18h, 02h, 11h, 12h, 13h	; row 3 tail + row 4 head (11-13)

crab_frame_0f:					; offset 0x213 -> ptr 0xA213 (group B[3]) -- pincer attack frame
		db	 14h, 00h,0C9h,0CAh,0CBh,0CCh	; row 0 (tiles 14, then C9-CC)
		db	 00h,0C9h,0CAh,0CBh,0CCh, 01h	; row 1 (tiles C9-CC + sep)

crab_frame_10:					; offset 0x21D -> ptr 0xA21D (group B[6]) -- pincer recovery
		db	0CDh,0CEh,0CFh,0D0h, 00h	; row 0 (tiles CD-D0)

crab_frame_11:					; offset 0x222 -> ptr 0xA222 (group B[7]) -- recovery alt
		db	0D1h,0D2h,0D3h,0D4h, 02h,0D1h,0D2h	; row 0 (tiles D1-D4 + sep) + row 1 head (D1,D2)

crab_frame_12:					; offset 0x227 -> ptr 0xA227 (group B[8]) -- recovery aux
		db	0D3h,0D4h, 01h			; row 0 (tiles D3,D4 + sep)

crab_frame_13:					; offset 0x22C -> ptr 0xA22C (group B[0,1]) -- death/explode frame (used twice in tbl_b/e)
		db	0D5h,0D5h,0D5h			; row 0 head (4x tile D5)
		db	0D5h, 01h,0D6h,0D7h,0D8h,0D9h	; row 0 tail + row 1 head (D6-D9)
		db	 01h,0DAh,0DBh,0DCh,0DDh, 01h	; row 1 tail + row 2 (tiles DA-DD + sep)
		db	 00h, 00h,0DEh,0DFh, 4Ch,0A2h	; row 3 (2 zeros + tiles DE,DF,4C,A2)
		db	 50h,0A2h			; row 4 head (tiles 50,A2)
		db	50h				; row 4 tail (tile 50) -- runs into crab_data_block_2 tail bytes
; -------------------------------------------------------------------------
;  Trailing tail of the per-frame data tables (file offset 0x247) that runs
;  straight into the secondary AI dispatch entry.  The `jcxz` from
;  crab_substate_00 lands here when CX==0 (a calling-convention reset path).
;  Sourcer mis-decodes the first few bytes as `mov ds:[0xA248],al; add ax,0; ...`
;  but they're really tile-table tail bytes.  Real executable code begins at
;  `mov bl,[si+4]` (the AND/XOR/ADD/JMP dispatch sequence below); the JMP
;  indexes a 4-entry handler table that lives at offset 0xA266 in DS.
; -------------------------------------------------------------------------

crab_data_block_2:				; offset 0x247 (= jcxz target)
		;* 15-byte tail of the frame-pointer data block (Sourcer
		;  decoded as instructions; really data).  Real code resumes
		;  at the `mov bl,[si+4]` below, whose first byte (8Ah)
		;  follows immediately after the 0 separator at 0x255.
		db	0A2h, 48h, 0A2h			; 0x247-249
		db	05h, 00h, 00h			; 0x24A-24C
		db	00h, 05h			; 0x24D-24E
		db	04h, 04h			; 0x24F-250
		db	00h, 04h			; 0x251-252
		db	00h, 04h			; 0x253-254
		db	00h				; 0x255: separator (last data byte)

		mov	bl,[si+4]		; 0x256: 8A 5C 04 — real start of dispatch
		and	bl,0Fh			; 0x259: 80 E3 0F (mask state nibble)
		xor	bh,bh			; 0x25C: 32 FF
		add	bx,bx			; 0x25E: 03 DB (scale to word index)
		jmp	word ptr ds:[crab_dispatch_tbl_base][bx]	; 0x260: FF A7 62 A2

; CRAB AI primary dispatch table (4 valid handlers; first 2 entries overlap
; the JMP instruction's bytes so they're unreachable). Indexed by [si+4]&0xF.

crab_ai_dispatch_tbl:				; offset 0x266 (= 0xA266 in DS)
		dw	0A26Ah			; idx 2 -> crab_ai_main_entry
		dw	0A3E7h			; idx 3 -> crab_attack_state_a
		dw	0A43Fh			; idx 4 -> crab_attack_state_b
		dw	0A517h			; idx 5 -> crab_pincer_state

; Inline AI-entry tail (file offsets 0x26E..0x283) -- pre-roll for crab_ai_main_entry:
;   call cs:[fight_cb_alt]; jnz +5; jmp cs:[fight_cb_spawn]
;   test [si+8], 0FFh;     jnz +4; mov [si+8], 2
		db	 2Eh,0FFh, 16h, 30h, 60h	; call cs:[fight_cb_alt]
		db	 75h, 05h			; jnz  crab_ai_main_entry
		db	 2Eh,0FFh, 26h, 32h, 60h	; jmp  cs:[fight_cb_spawn]
		db	 0F6h, 44h, 08h,0FFh		; test byte ptr [si+8], 0FFh
		db	 75h, 04h			; jnz  crab_ai_main_entry
		db	 0C6h, 44h, 08h, 02h		; mov  byte ptr [si+8], 2

crab_ai_main_entry:				; offset 0x284 -- secondary entry (visibility/state dispatch)
		test	byte ptr [si+5],20h	; ' '
		jz	dispatch_by_state_hi			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

dispatch_by_state_hi:
		mov	bl,[si+9]
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:crab_tbl_a[bx]	;*

; AI sub-state 0 (dispatched via crab_tbl_a[0])

crab_substate_00:
		movsw				; Mov [si] to es:[di]
		mov	ds:crab_tbl_b,al
		jcxz	crab_data_block_2			; Jump if cx=0
		and	word ptr ss:gvar_rng_state[bp+di],16h
		or	al,60h			; '`'
		test	byte ptr [si+6],0FFh
		jz	sub00_check_position			; Jump if zero
		sub	byte ptr [si+6],10h
		retn

sub00_check_position:
		mov	al,[si+3]
		sub	al,11h
		cmp	al,0Ah
		jb	sub00_set_state_40			; Jump if below
		mov	al,11h
		sub	al,[si+3]
		cmp	al,7
		jae	sub00_clear_phase_ret			; Jump if above or =

sub00_set_state_40:
		mov	byte ptr [si+9],40h	; '@'

sub00_clear_phase_ret:
		mov	byte ptr [si+6],0
		retn

; AI sub-state 1 (dispatched via crab_tbl_a[1]): phase-advance to state 80h

crab_substate_01:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],3
		je	sub01_advance_to_80			; Jump if equal
		retn

sub01_advance_to_80:
		mov	byte ptr [si+9],80h
		retn

; AI sub-state 2 (dispatched via crab_tbl_a[2]): distance-check / transition

crab_substate_02:
		call	phase_advance_helper
		test	byte ptr ds:gvar_enemy_cnt,0FFh
		jz	sub02_compute_dx			; Jump if zero
		mov	byte ptr [si+9],0C0h
		retn

sub02_compute_dx:
		mov	al,ds:gvar_frame_cnt
		sub	al,[si+2]
		add	al,15h
		and	al,3Fh			; '?'
		cmp	al,12h
		jb	sub02_near_range			; Jump if below
		cmp	al,18h
		jb	sub02_mid_range			; Jump if below
		cmp	byte ptr [si+3],11h
		je	sub02_try_jump			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	sub02_try_jump			; Jump if equal
		jnc	sub02_try_west_far			; Jump if carry=0
		call	word ptr cs:fight_cb_dist_check
		jc	sub02_face_east_step			; Jump if carry Set
		or	byte ptr [si+5],80h
		retn

sub02_try_west_far:
		call	word ptr cs:fight_cb_step_pos_2
		jc	sub02_face_west_step			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn

sub02_mid_range:
		cmp	byte ptr [si+3],11h
		je	sub02_try_jump			; Jump if equal
		cmp	byte ptr [si+3],10h
		je	sub02_try_jump			; Jump if equal
		jnc	sub02_face_west_step			; Jump if carry=0

sub02_face_east_step:
				call	word ptr cs:fight_cb_step_neg
				jc	sub02_try_jump			; Jump if carry Set
				or	byte ptr [si+5],80h
				retn

sub02_face_west_step:
						call	word ptr cs:fight_cb_step_pos
						jc	sub02_try_jump			; Jump if carry Set
						and	byte ptr [si+5],7Fh
						retn

sub02_near_range:
						cmp	byte ptr [si+3],11h
						je	sub02_try_jump			; Jump if equal
						cmp	byte ptr [si+3],10h
						je	sub02_try_jump			; Jump if equal
						jnc	sub02_try_west_step			; Jump if carry=0
						call	word ptr cs:fight_cb_step_neg_2
						jc	sub02_face_east_step			; Jump if carry Set
				or	byte ptr [si+5],80h
				retn

sub02_try_west_step:
				call	word ptr cs:fight_cb_map_back
				jc	sub02_face_west_step			; Jump if carry Set
		and	byte ptr [si+5],7Fh
		retn

sub02_try_jump:
		call	word ptr cs:fight_cb_blocked
		jc	sub02_advance_to_C0			; Jump if carry Set
		retn

sub02_advance_to_C0:
		mov	byte ptr [si+9],0C0h
		retn

; AI sub-state 3 (dispatched via crab_tbl_a[3]): walking / step cycle

crab_substate_03:
		test	byte ptr [si+9],20h	; ' '
		jnz	sub03_count_down			; Jump if not zero
		call	phase_advance_helper
		test	byte ptr [si+5],80h
		jz	sub03_step_alt			; Jump if zero
		call	word ptr cs:fight_cb_step_neg_2
		jc	sub03_clear_facing			; Jump if carry Set
		retn

sub03_clear_facing:
		and	byte ptr [si+5],7Fh
		jmp	short sub03_apply_step

sub03_step_alt:
		call	word ptr cs:fight_cb_map_back
		jc	sub03_set_facing			; Jump if carry Set
		retn

sub03_set_facing:
		or	byte ptr [si+5],80h

sub03_apply_step:
		call	word ptr cs:fight_cb_map_fwd
		jc	sub03_set_step_state			; Jump if carry Set
		retn

sub03_set_step_state:
		or	byte ptr [si+9],20h	; ' '
		mov	byte ptr [si+6],2
		retn

sub03_count_down:
		dec	byte ptr [si+6]
		and	byte ptr [si+6],7
		test	byte ptr [si+6],0FFh
		jz	sub03_reset_phase			; Jump if zero
		retn

sub03_reset_phase:
		mov	byte ptr [si+6],70h	; 'p'
		mov	byte ptr [si+9],0
		retn

crab_ai_main	endp

phase_advance_helper		proc	near
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],7
		jae	phase7_wrap_to_3			; Jump if above or =
		retn

phase7_wrap_to_3:
		mov	byte ptr [si+6],3
		retn

phase_advance_helper		endp

; AI sub-state handler (dispatched from crab_tbl_b or crab_tbl_a -- attack pattern)

crab_attack_state_a:
		call	word ptr cs:fight_cb_alt
		jnz	atk_a_after_check			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

atk_a_after_check:
		test	byte ptr [si+8],0FFh
		jnz	atk_a_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],2

atk_a_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	atk_a_check_jump			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

atk_a_check_jump:
		call	word ptr cs:fight_cb_blocked
		jc	atk_a_phase_advance			; Jump if carry Set
		retn

atk_a_phase_advance:
		add	byte ptr [si+6],41h	; 'A'
		and	byte ptr [si+6],0C3h
		test	byte ptr [si+6],0F0h
		jz	atk_a_phase_ready			; Jump if zero
		retn

atk_a_phase_ready:
		cmp	byte ptr [si+3],11h
		jae	atk_a_far_test			; Jump if above or =
		call	word ptr cs:fight_cb_step_neg
		jnc	atk_a_set_facing			; Jump if carry=0
		retn

atk_a_set_facing:
		or	byte ptr [si+5],80h
		retn

atk_a_far_test:
		call	word ptr cs:fight_cb_step_pos
		jnc	atk_a_clear_facing			; Jump if carry=0
		retn

atk_a_clear_facing:
		and	byte ptr [si+5],7Fh
		retn

; AI sub-state handler: alternate attack pattern (sibling of crab_attack_state_a)

crab_attack_state_b:
		call	word ptr cs:fight_cb_alt
		jnz	atk_b_after_check			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

atk_b_after_check:
		test	byte ptr [si+8],0FFh
		jnz	atk_b_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],1

atk_b_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	atk_b_check_phase			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

atk_b_check_phase:
		test	byte ptr [si+9],8
		jnz	atk_b_jump_active			; Jump if not zero
		add	byte ptr [si+6],21h	; '!'
		and	byte ptr [si+6],0E1h
		call	word ptr cs:fight_cb_blocked
		jc	atk_b_phase_jumped			; Jump if carry Set
		retn

atk_b_phase_jumped:
		call	distance_check_8
		jc	atk_b_set_jump_state			; Jump if carry Set
		mov	al,[si+6]
		and	al,0E0h
		jz	atk_b_check_dist			; Jump if zero
		retn

atk_b_check_dist:
		call	distance_check_8
		cmp	al,0FFh
		je	atk_b_set_jump_state			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
		retn

atk_b_set_jump_state:
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8

atk_b_jump_active:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		cmp	al,7
		jae	atk_b_finish_phase			; Jump if above or =
		mov	ch,ah
		and	ch,0F0h
		or	al,ch
		mov	[si+6],al
		mov	bx,0A71Fh
		test	byte ptr [si+5],80h
		jnz	atk_b_use_default_tbl			; Jump if not zero
		mov	bx,crab_rotate_a

atk_b_use_default_tbl:
		mov	al,ah
		sub	al,2
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	atk_b_xlat_failed			; Jump if carry Set
		retn

atk_b_xlat_failed:
		call	distance_check_8
		jc	atk_b_finish_phase			; Jump if carry Set
		xor	byte ptr [si+5],80h

atk_b_finish_phase:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],0
		jmp	word ptr cs:fight_cb_blocked

distance_check_8		proc	near
		mov	al,ds:gvar_frame_cnt
		sub	al,[si+2]
		jns	dist_abs_done			; Jump if not sign
		neg	al

dist_abs_done:
		cmp	al,8
		mov	al,0FFh
		jc	dist_in_range			; Jump if carry Set
		retn

dist_in_range:
		cmp	byte ptr [si+3],11h
		jae	dist_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dist_set_carry_clear			; Jump if zero
		retn

dist_set_carry_clear:
		clc				; Clear carry flag
		retn

dist_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dist_far_clear_carry			; Jump if not zero
		retn

dist_far_clear_carry:
		clc				; Clear carry flag
		retn

distance_check_8		endp

; AI sub-state handler: pincer/grab sequence

crab_pincer_state:
		call	word ptr cs:fight_cb_alt
		jnz	pincer_after_check			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

pincer_after_check:
		test	byte ptr [si+8],0FFh
		jnz	pincer_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],1

pincer_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	pincer_check_phase			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

pincer_check_phase:
		test	byte ptr [si+9],8
		jz	pincer_check_phase_alt			; Jump if zero
		jmp	pincer_jump_phase

pincer_check_phase_alt:
		test	byte ptr [si+9],10h
		jz	pincer_step_loop			; Jump if zero
		jmp	pincer_recovery

pincer_step_loop:
		call	word ptr cs:fight_cb_blocked
		jc	pincer_phase_active			; Jump if carry Set
		retn

pincer_phase_active:
		test	byte ptr [si+9],4
		jz	pincer_animate			; Jump if zero
		and	byte ptr [si+6],0F1h
		or	byte ptr [si+6],4
		call	distance_check_6
		cmp	al,0FFh
		je	pincer_phase_advance			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],2
		and	byte ptr [si+9],0FBh
		retn

pincer_phase_advance:
		add	byte ptr [si+6],40h	; '@'
		jc	pincer_subphase_inc			; Jump if carry Set
		retn

pincer_subphase_inc:
		mov	al,[si+6]
		inc	al
		and	al,1
		add	al,4
		mov	[si+6],al
		add	byte ptr [si+9],40h	; '@'
		jc	pincer_subphase_done			; Jump if carry Set
		retn

pincer_subphase_done:
		and	byte ptr [si+9],0FBh
		and	byte ptr [si+5],7Fh
		call	word ptr cs:crab_facing_fn_ptr
		and	al,80h
		or	[si+5],al
		or	al,al			; Zero ?
		jns	pincer_face_east_step			; Jump if not sign
		call	word ptr cs:fight_cb_aux_18
		jc	pincer_clear_facing			; Jump if carry Set
		retn

pincer_clear_facing:
		and	byte ptr [si+5],7Fh
		retn

pincer_face_east_step:
		call	word ptr cs:fight_cb_aux_1a
		jc	pincer_set_facing			; Jump if carry Set
		retn

pincer_set_facing:
		or	byte ptr [si+5],80h
		retn

pincer_animate:
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	ax,48h
		test	byte ptr [si+5],80h
		jz	pincer_pos_offset_done			; Jump if zero
		inc	ax

pincer_pos_offset_done:
		xchg	si,di
		add	si,ax
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		jnz	pincer_count_phase			; Jump if not zero
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],8
		retn

pincer_count_phase:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+9],2
		jnz	pincer_aux_step			; Jump if not zero
		add	byte ptr [si+0Ah],10h
		jnc	pincer_aux_step			; Jump if carry=0
		or	byte ptr [si+9],4
		retn

pincer_aux_step:
		call	distance_check_6
		jnc	pincer_pick_attack			; Jump if carry=0
		and	byte ptr [si+5],0FDh
		mov	byte ptr [si+0Ah],0

pincer_pick_attack:
		test	byte ptr [si+5],80h
		jz	pincer_east_attack			; Jump if zero
		call	word ptr cs:fight_cb_step_neg
		jc	pincer_west_done			; Jump if carry Set
		retn

pincer_west_done:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		and	byte ptr [si+9],1Fh
		retn

pincer_east_attack:
		call	word ptr cs:fight_cb_step_pos
		jc	pincer_east_done			; Jump if carry Set
		retn

pincer_east_done:
		mov	byte ptr [si+6],0
		or	byte ptr [si+9],10h
		and	byte ptr [si+9],1Fh
		retn

pincer_jump_phase:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	pincer_jump_complete			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah
		mov	bx,0A71Fh
		test	byte ptr [si+5],80h
		jnz	pincer_jump_use_default			; Jump if not zero
		mov	bx,crab_rotate_a

pincer_jump_use_default:
		mov	al,[si+6]
		xlat				; al=[al+[bx]] table
		push	ax
		call	word ptr cs:fight_cb_alt_b
		pop	ax
		jc	pincer_jump_failed			; Jump if carry Set
		jmp	word ptr cs:fight_cb_range

pincer_jump_failed:
		and	byte ptr [si+9],0F7h
		or	byte ptr [si+9],4
		retn

pincer_jump_complete:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],3
		jmp	word ptr cs:fight_cb_blocked

pincer_recovery:
		add	byte ptr [si+9],20h	; ' '
		test	byte ptr [si+9],20h	; ' '
		jnz	pincer_recovery_step			; Jump if not zero
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,3
		jz	pincer_recover_finish			; Jump if zero
		and	ah,0F0h
		or	ah,al
		mov	[si+6],ah

pincer_recovery_step:
		mov	al,[si+9]
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		rol	al,1			; Rotate
		dec	al
		and	al,7
		mov	bx,0A727h
		test	byte ptr [si+5],80h
		jnz	pincer_recover_use_default			; Jump if not zero
		mov	bx,crab_rotate_b

pincer_recover_use_default:
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	pincer_recover_failed			; Jump if carry Set
		retn

pincer_recover_failed:
		and	byte ptr [si+9],0EFh
		or	byte ptr [si+9],4
		test	byte ptr [si+6],0FFh
		jnz	pincer_recover_set_phase3			; Jump if not zero
		retn

pincer_recover_set_phase3:
		mov	byte ptr [si+6],3
		retn

pincer_recover_finish:
		and	byte ptr [si+9],0EFh
		mov	byte ptr [si+6],3
		jmp	word ptr cs:fight_cb_blocked

distance_check_6		proc	near
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
		cmp	byte ptr [si+3],11h
		jae	dist6_far_branch			; Jump if above or =
		mov	al,80h
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jz	dist6_set_carry_clear			; Jump if zero
		retn

dist6_set_carry_clear:
		clc				; Clear carry flag
		retn

dist6_far_branch:
		xor	al,al			; Zero register
		test	byte ptr [si+5],80h
		stc				; Set carry flag
		jnz	dist6_far_clear_carry			; Jump if not zero
		retn

dist6_far_clear_carry:
		clc				; Clear carry flag
		retn

distance_check_6		endp

; Trailing data table ?-- frame/position lookup bytes (Sourcer mis-decoded as code).
; Pattern of 00h/01h..07h bytes suggests per-frame X-offset or tile-advance table.
; Preserved as emitted so bit-perfect assembly holds.

crab_trailing_tbl:
		add	[bx+si],ax
		add	[bx],al
		add	ax,[si]
		add	al,5
		add	al,[bx+di]
		add	[bx+si],ax
		add	[bx],al
		pop	es
		push	es
		add	al,[bp+di]
		add	ax,[si]
		add	al,5
		db	05h, 06h		; truncated 'add ax,6' ?-- file ends mid-instruction

seg_a		ends

		end	start