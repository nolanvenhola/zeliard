
PAGE  59,132

;==========================================================================
;
;  302EAI2.BIN - Enemy AI Handler 2: TAKO (zelres3 chunk 3, 'Pulpo')
;
;  Per-enemy AI controller for the TAKO (octopus) enemy, loaded by
;  200FIGHT alongside 310TAKO.BIN sprites. Controls swim/walk locomotion,
;  multi-tentacle attack dispatch, distance-based seek/hide, and
;  collision tests for the octopus enemy.
;
;  Same calling convention as 301EAI1 (CRAB):
;    SI = active enemy slot record (16 bytes at game_seg:0C010h+).
;      [si+0..1] = X position (word)
;      [si+2]    = tile-X / row coord (frame counter axis)
;      [si+3]    = tile-Y / col coord
;      [si+5]    = attribute byte (bit7=facing, bit5=hit, bit6=visible)
;      [si+6]    = animation phase / sub-counter (high+low nibbles)
;      [si+8]    = attack cooldown
;      [si+9]    = state/substate (rotated nibbles -> dispatch index)
;      [si+0Ah]  = secondary phase counter
;      [si+10h]  = mirror of [si+0..1]
;      [si+13h]  = tile counter (kept in sync with [si+3])
;      [si+15h]  = persistent attribute (bit6=hit/visible)
;      [si+16h]  = animation frame mirror of [si+6]
;
;  Each "No entry point to code" handler block is entered through the
;  fight-engine state dispatch: `jmp word ptr ds:tako_state_dispatch[bx]`
;  with bx = 2 * (rotated [si+9] bits 6:5).  Sourcer cannot trace these
;  jumps because the dispatch tables live in DS.
;
;  State machine (TAKO):
;
;    Primary dispatch by [si+4]&0xF (table at 0xA37B):
;      idx 2/3 -> tako_ai_main_entry   (idle/swim/attack)
;      idx 4   -> tako_alt_state_a     (tentacle launch A, cooldown=4)
;      idx 5   -> tako_alt_state_b     (tentacle launch B, cooldown=2)
;      idx 6/7 -> tako_seek_state      (4-substate seek dispatcher)
;
;    Main entry flow:
;
;      check_hit ([si+15h]&0x40) --hit--> enter_hide_state
;          |
;       step_swim_y (vertical drift)
;          |
;          v
;      [si+9]&1 ? -- yes --> state_swim_active (phase 6=launch tentacles,
;          | no                                phase 8=finish)
;          v
;      state_idle_branch (distance_check_5)
;          |
;       close: aim toward hero, set_swim_targets -> [si+9]|=1
;       far : phase advance, step pos/neg
;          |
;       random_attack_test --gate--> enter_attack_state ([si+9]|=3)
;
;    seek_state secondary dispatch via tako_state_dispatch (DS 0xA956),
;    bx = 2 * (rotated [si+9] bits 6:5):
;      sub00 (idle/decel) -> sub01 -> sub02 (chase) -> sub03 (step) -> sub00
;
;  Connections:
;    Loads:        none (loaded as data by 200FIGHT; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_range (6004h), fight_cb_step_neg (6008h),
;                  fight_cb_step_neg_2 (600Ah), fight_cb_map_fwd (600Ch),
;                  fight_cb_map_back (600Eh), fight_cb_step_pos (6010h),
;                  fight_cb_step_pos_2 (6012h), fight_cb_blocked (6014h),
;                  fight_cb_dist_check (6016h), fight_cb_record_ofs (6028h),
;                  fight_cb_mark_adj (602Ah), fight_cb_tile_index (602Ch),
;                  fight_cb_cmp_tile (602Eh), fight_cb_alt (6030h),
;                  fight_cb_spawn (6032h); plus tako_facing_fn_ptr
;                  CS-relative pseudo-fn for facing/sign returns.
;    Called by:    200FIGHT enemy AI dispatch table (TAKO enemy slot;
;                  paired with sprite module 310TAKO.BIN).
;    Reads/writes: gvar_proj_cnt (0C002h), gvar_frame_cnt (0FF35h),
;                  gvar_enemy_cnt (0FF36h); enemy slot record fields
;                  [si+0..si+16h]; TAKO swim/tentacle pattern tables
;                  tako_tbl_a..p (0A4FDh..0A956h) and tako_state_dispatch
;                  at 0A956h (4-entry word-ptr table).
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
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
tako_tbl_a	equ	0A4FDh			; swim pattern table 1 hi
tako_tbl_b	equ	0A4FEh			; swim pattern table 1 lo
tako_tbl_c	equ	0A50Ah			; swim pattern table 2 hi
tako_tbl_d	equ	0A50Bh			; swim pattern table 2 lo
tako_tbl_e	equ	0A517h			; swim pattern table 3 hi
tako_tbl_f	equ	0A518h			; swim pattern table 3 lo
tako_tbl_g	equ	0A524h			; swim pattern table 4 hi
tako_tbl_h	equ	0A525h			; swim pattern table 4 lo
tako_tbl_i	equ	0A6D6h			; swim direction param hi
tako_tbl_j	equ	0A6D7h			; swim direction param lo
tako_tbl_k	equ	0A8D2h			; tentacle pattern A (default)
tako_tbl_l	equ	0A8D3h			; tentacle pattern A lo
tako_tbl_m	equ	0A8DFh			; tentacle pattern B
tako_tbl_n	equ	0A8E0h			; tentacle pattern B lo
tako_tbl_o	equ	0A8F0h			; tentacle xlat table (default west)
tako_tbl_p	equ	0A956h			; tako_state_dispatch (4 word-ptr)
tako_facing_fn_ptr	equ	(offset data_6) + 4	; CS-relative: pseudo-fn used by
							; `call word ptr cs:[...]` -- returns
							; AL with sign-bit set as facing/dir


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

tako_ai_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer mis-decoded these as code (`mov al,[data_1] / add [bx+di-5Dh],ch
;  / db 0,0,0,0 / data_1 db 49h / ...`) but the bytes are a 4-byte length
;  header, an init src/dst pointer pair, and a small state buffer
;  (matches 309CRAB / 310TAKO module-header pattern).
; -------------------------------------------------------------------------

start:

file_header:
		db	0A0h, 0Ah		; file length word: 0x0AA0 (= file_size - 4)
		db	 00h, 00h		; pad / flag word

tako_init_src_dst:
		db	 69h,0A3h		; init src ptr = 0xA369 (frame data tail)
		db	 00h, 00h		; pad
		db	 00h, 00h		; pad
		db	 49h,0A3h		; init dst ptr = 0xA349

		db	 0Ah, 0Ah, 04h, 0Ah, 04h, 0FFh	; per-slot template byte block
		db	 00h, 00h			; pad
		db	 0Ah, 0Ah, 08h, 0Ah, 08h, 28h	; per-slot template byte block 2
		db	26 dup (0)			; reserved / padding (offsets 0x01A-0x033)

; -------------------------------------------------------------------------
;  Animation frame pointer tables (word ptr[], in DS at game_seg).
;  Each word = runtime address of a frame data block within this file.
;  Same dual-table layout as 309CRAB -- groups A..F with empty slot
;  reserves between them.
; -------------------------------------------------------------------------

tako_frame_ptr_tbl_a	label	word		; offset 0x034 -- group A pointers
		db	0B0h,0A0h, 0Fh,0A1h, 6Eh,0A1h	; -> 0xA0B0, 0xA10F, 0xA16E
		db	0B9h,0A1h, 18h,0A2h, 6Dh,0A2h	; -> 0xA1B9, 0xA218, 0xA26D
		db	 00h, 00h, 00h, 00h		; reserved
		db	 00h,0A1h, 5Fh,0A1h,0AAh,0A1h	; -> 0xA100, 0xA15F, 0xA1AA
		db	 09h,0A2h, 5Eh,0A2h,0B3h,0A2h	; -> 0xA209, 0xA25E, 0xA2B3
		db	 00h, 00h, 00h, 00h		; reserved

tako_frame_ptr_tbl_b	label	word		; offset 0x054 -- group B pointers
		db	 26h,0A3h, 26h,0A3h		; -> 0xA326, 0xA326 (dup)
		db	0C2h,0A2h, 0Dh,0A3h,0D1h,0A2h	; -> 0xA2C2, 0xA30D, 0xA2D1
		db	0E5h,0A2h, 21h,0A3h		; -> 0xA2E5, 0xA321
		db	 00h, 00h			; empty slot
		db	 3Fh,0A3h, 44h,0A3h		; -> 0xA33F, 0xA344
		db	 00h, 00h			; empty slot
		db	0F9h,0A2h, 3Ah,0A3h		; -> 0xA2F9, 0xA33A
		db	 00h, 00h, 00h, 00h, 00h, 00h	; reserved (note: only 6 bytes -> 0x07A)

tako_frame_ptr_tbl_c	label	word		; offset 0x07A -- group C pointers
		db	0D8h,0A0h, 37h,0A1h, 6Eh,0A1h	; -> 0xA0D8, 0xA137, 0xA16E
		db	0E1h,0A1h, 3Bh,0A2h, 90h,0A2h	; -> 0xA1E1, 0xA23B, 0xA290
		db	 00h, 00h, 00h, 00h		; reserved

tako_frame_ptr_tbl_d	label	word		; offset 0x08C -- group D pointers
		db	 00h,0A1h, 5Fh,0A1h		; -> 0xA100, 0xA15F
		db	0AAh,0A1h, 09h,0A2h, 5Eh,0A2h	; -> 0xA1AA, 0xA209, 0xA25E
		db	0B3h,0A2h			; -> 0xA2B3

tako_frame_ptr_tbl_e_marker	label	byte	; offset 0x097 -- group E start marker
data_3		db	0			; (Sourcer's data_3) referenced as `add si,offset data_3`
		db	 00h, 00h, 00h			; reserved (3 bytes)
		db	 26h,0A3h, 26h,0A3h		; -> 0xA326, 0xA326
		db	0C2h,0A2h, 0Dh,0A3h, 0D1h,0A2h	; -> 0xA2C2, 0xA30D, 0xA2D1
		db	0E5h,0A2h, 21h,0A3h		; -> 0xA2E5, 0xA321
		db	 00h, 00h			; empty slot
		db	 3Fh,0A3h, 44h,0A3h		; -> 0xA33F, 0xA344
		db	 00h, 00h			; empty slot
		db	0F9h,0A2h, 3Ah,0A3h		; -> 0xA2F9, 0xA33A
		db	7 dup (0)			; reserved (offsets 0x0B5-0x0BB)

; -------------------------------------------------------------------------
;  Tako sprite/tile-index frame data (file offsets 0x0BC..0x247).
;  Each frame is a sequence of tile bytes terminated by 00h (row markers).
;  The frame pointer tables above index into this region.  Mid-stream the
;  table also serves as the AI helper jump anchor `tako_ai_dispatch_data`,
;  which is loaded into a register pair (e.g. `mov bx, ds:tako_tbl_x`)
;  and used by inline xlat / call patterns.
; -------------------------------------------------------------------------

tako_frame_data:				; offset 0x0B4 (frame at 0xA0B0 starts 4 bytes earlier in pad)
		db	'!"#$'				; tako_frame_A0_tail (0xA0B4): tiles 21-24
		db	0				; row term (closes A[0] / 0xA0B0 frame -- A[0]=A0B0 idle pose)

tako_frame_A0D8	label	byte			; 0xA0D8 -- C[0] pose (group C[0] body alt)
		db	'%&', 27h, '(', 0		; row 0: tiles 25-28 + term
		db	')*+,', 0			; row 1: tiles 29-2C + term
		db	'%&', 27h, '(', 0		; row 2 (re-uses tiles 25-28)
		db	'%&', 27h, '(', 0		; row 3 (re-uses tiles 25-28)
		db	'%&', 27h, '(', 0		; row 4 (re-uses tiles 25-28)
		db	'%&', 27h, '(', 0		; row 5 (re-uses tiles 25-28)
		db	'%&', 27h, '(', 0		; row 6 (re-uses tiles 25-28)

tako_frame_A100	label	byte			; 0xA100 -- A[6]/D[0] -- start of mid-pose group (line cont. inside)
		db	'-./0', 0			; row 0: tiles 2D-30 + term
		db	'1234', 0			; row 1: tiles 31-34 + term
		db	'5678', 0			; row 2: tiles 35-38 + term
		db	'1234', 0			; row 3 (re-uses tiles 31-34)
		db	'1234', 0			; row 4 (re-uses tiles 31-34) -- A1 frame at 0xA10F starts mid-row
		db	'1234', 0			; row 5 (re-uses tiles 31-34)
		db	'1234', 0			; row 6 (re-uses tiles 31-34)
		db	'1234', 0			; row 7 (re-uses tiles 31-34)
		db	'9:;<', 0			; row 8: tiles 39-3C + term
		db	'=', 0				; row 9: tile 3D + term
		db	'>?'				; row 10 head: tiles 3E-3F (no term, frame ends here)
		db	0, 0, 0, 0, 0, 0		; offset 0x108-0x10D: zero pad (5 bytes also serve as row terms for A1@0xA10F frame head)
		db	 40h, 41h			; offset 0x10E-0x10F: tiles 40-41 (last 2 bytes feed A1 frame at 0xA10F)

tako_helper_anchor	label	byte		; helper xlat anchor (used as `cs:data_6+4`)
data_6		db	'BC', 0			; (Sourcer's data_6) -- referenced as `cs:data_6+4`
		db	'DEFG', 0
		db	'HIJK', 0
		db	'DELM', 0
		db	'DEFN', 0
		db	'^EFN', 0
		db	'_EFN', 0
		db	'^EFN', 0
		db	'OPQR', 0
		db	'STUV', 0
		db	'WXYZ', 0
		db	'ST[\', 0
		db	'ST]V', 0
		db	'S`]V', 0
		db	'Sa]V', 0
		db	'S`]V', 0
		db	'bcde', 0
		db	'fghi', 0
		db	'jklm'				; 0x165: tiles 6A-6D (data_6 last entry head, no term)
		db	 02h, 00h, 00h, 7Dh, 7Eh, 02h	; 0x169: row 0 (B-table content begins; tiles 7D-7E)
		db	 00h, 00h, 7Fh, 80h, 02h, 00h	; 0x16F: row 1 (tiles 7F-80)
		db	 00h, 83h, 84h, 02h, 85h, 86h	; 0x175: row 2 (tiles 83-86) -- A2/C2 frame at 0xA16E starts mid-row
		db	 87h, 88h, 02h, 85h, 86h, 87h	; 0x17B: row 3 (tiles 87-88, 85-87)
		db	 88h, 02h, 00h, 00h, 83h, 84h	; 0x181: row 4 (tile 88; tiles 83-84)
		db	 02h, 00h, 00h, 7Fh, 80h, 02h	; 0x187: row 5 (tiles 7F-80)
		db	 00h, 00h, 7Dh, 7Eh, 02h, 00h	; 0x18D: row 6 (tiles 7D-7E)
		db	 00h, 89h, 8Ah, 02h, 00h, 00h	; 0x193: row 7 (tiles 89-8A)
		db	 8Bh, 8Ch, 02h, 00h, 00h, 89h	; 0x199: row 8 (tiles 8B-8C; tile 89)
		db	 8Ah, 02h, 00h, 00h, 8Dh, 8Eh	; 0x19F: row 9 (tile 8A; tiles 8D-8E)
		db	 02h, 00h, 00h, 91h, 92h, 02h	; 0x1A5: row 10 (tiles 91-92) -- A8/D2 frame at 0xA1AA starts mid-row
		db	 93h, 94h, 95h, 96h, 02h, 97h	; 0x1AB: row 11 (tiles 93-96; tile 97)
		db	 98h, 99h, 9Ah, 00h, 9Bh, 9Ch	; 0x1B1: row 12 (tiles 98-9A; tiles 9B-9C)

tako_frame_A1B9	label	byte			; 0xA1B9 -- A[3] (frame start mid-row at offset 0x1B9)
		db	 9Dh, 9Eh, 00h, 9Bh, 9Ch, 9Fh	; 0x1B7: row 13 (tiles 9D-9E; tiles 9B-9C, 9F)
		db	 9Eh, 00h,0A1h,0A2h,0A3h,0A4h	; 0x1BD: row 14 (tile 9E; tiles A1-A4)
		db	 00h,0A5h,0A2h,0A6h,0A7h, 00h	; 0x1C3: row 15 (tiles A5,A2,A6,A7)
		db	0A8h,0A9h,0AAh,0ABh, 00h,0ACh	; 0x1C9: row 16 (tiles A8-AB; tile AC)
		db	0ADh,0AEh,0AFh, 00h, 9Bh, 9Ch	; 0x1CF: row 17 (tiles AD-AF; tiles 9B-9C)
		db	 9Dh, 9Eh, 00h, 9Bh, 9Ch,0A0h	; 0x1D5: row 18 (tiles 9D-9E; tiles 9B-9C,A0)
		db	 9Eh, 00h,0B4h,0B5h,0B6h,0B7h	; 0x1DB: row 19 (tile 9E; tiles B4-B7) -- C3 frame at 0xA1E1 starts mid-row

tako_frame_A1E1	label	byte			; 0xA1E1 -- C[3] (frame ptr lands cleanly at line start below)
		db	 00h,0B4h,0B5h,0B6h,0B8h, 00h	; 0x1E1: row 20 (tiles B4-B6, B8)
		db	0BAh,0BBh,0BCh,0BDh, 00h,0BAh	; 0x1E7: row 21 (tiles BA-BD; tile BA)
		db	0BEh,0BFh,0C0h, 00h,0C1h,0C2h	; 0x1ED: row 22 (tiles BE-C0; tiles C1-C2)
		db	0C3h,0C4h, 00h,0C5h,0C6h,0C7h	; 0x1F3: row 23 (tiles C3-C4; tiles C5-C7)
		db	0C8h, 00h,0B4h,0B5h,0B6h,0B7h	; 0x1F9: row 24 (tile C8; tiles B4-B7)
		db	 00h,0B4h,0B5h,0B6h,0B9h, 00h	; 0x1FF: row 25 (tiles B4-B6, B9)
		db	0CDh,0CEh,0CFh,0D0h, 00h,0D1h	; 0x205: row 26 (tiles CD-D0; tile D1) -- A9/D3 frame at 0xA209 starts mid-row
		db	0D2h,0D3h,0D4h, 00h, 00h, 00h	; 0x20B: row 27 (tiles D2-D4; pad)
		db	0D7h,0D8h, 00h,0D9h,0DAh,0DBh	; 0x211: row 28 (tiles D7-D8; tiles D9-DB)
		db	0DCh, 00h,0E1h,0E2h,0E3h,0E4h	; 0x217: row 29 (tile DC; tiles E1-E4) -- A4 frame at 0xA218 starts mid-row
		db	 00h,0E1h,0E2h,0E3h,0E4h, 00h	; 0x21D: row 30 (tiles E1-E4)
		db	0E5h,0E6h,0E7h,0E8h, 00h,0E9h	; 0x223: row 31 (tiles E5-E8; tile E9)
		db	0EAh,0EBh,0ECh, 00h,0E5h,0E6h	; 0x229: row 32 (tiles EA-EC; tiles E5-E6)
		db	0E7h,0E8h, 00h,0EDh,0EEh,0EFh	; 0x22F: row 33 (tiles E7-E8; tiles ED-EF)
		db	0F0h, 00h,0D9h,0DAh,0DBh,0DCh	; 0x235: row 34 (tile F0; tiles D9-DC)

tako_frame_A23B	label	byte			; 0xA23B -- C[4] (frame ptr lands cleanly at line start below)
		db	 00h,0DDh,0DEh,0DFh,0E0h, 00h	; 0x23B: row 35 (tiles DD-E0)
		db	0DDh,0DEh,0DFh,0E0h, 00h, 81h	; 0x241: row 36 (tiles DD-E0; tile 81)
		db	 82h, 8Fh, 90h, 00h,0B0h,0B1h	; 0x247: row 37 (tiles 82, 8F-90; tiles B0-B1)
		db	0B2h,0B3h, 00h, 81h, 82h, 8Fh	; 0x24D: row 38 (tiles B2-B3; tiles 81-82, 8F)
		db	 90h, 00h,0C9h,0CAh,0CBh,0CCh	; 0x253: row 39 (tile 90; tiles C9-CC)
		db	 00h,0D5h,0D6h,0F1h,0F2h, 00h	; 0x259: row 40 (tiles D5-D6, F1-F2) -- A10/D4 frame at 0xA25E starts mid-row
		db	0F3h,0F4h,0F5h,0F6h, 00h,0F7h	; 0x25F: row 41 (tiles F3-F6; tile F7)
		db	0F8h,0F9h,0FAh, 01h,0D9h,0DAh	; 0x265: row 42 (tiles F8-FA; row-marker 01; tiles D9-DA)
		db	0DBh,0DCh, 01h,0E1h,0E2h,0E3h	; 0x26B: row 43 (tiles DB-DC; tiles E1-E3) -- A5 frame at 0xA26D starts mid-row
		db	0E4h, 01h,0E1h,0E2h,0E3h,0E4h	; 0x271: row 44 (tile E4; tiles E1-E4)
		db	 01h,0E5h,0E6h,0E7h,0E8h, 01h	; 0x277: row 45 (tiles E5-E8)
		db	0E9h,0EAh,0EBh,0ECh, 01h,0E5h	; 0x27D: row 46 (tiles E9-EC; tile E5)
		db	0E6h,0E7h,0E8h, 01h,0EDh,0EEh	; 0x283: row 47 (tiles E6-E8; tiles ED-EE)
		db	0EFh,0F0h, 01h,0D9h,0DAh,0DBh	; 0x289: row 48 (tiles EF-F0; tiles D9-DB)
		db	0DCh, 01h,0DDh,0DEh,0DFh,0E0h	; 0x28F: row 49 (tile DC; tiles DD-E0) -- C5 frame at 0xA290 starts mid-row
		db	 01h,0DDh,0DEh,0DFh,0E0h, 01h	; 0x295: row 50 (tiles DD-E0)
		db	 81h, 82h, 8Fh, 90h, 01h,0B0h	; 0x29B: row 51 (tiles 81-82, 8F-90; tile B0)
		db	0B1h,0B2h,0B3h, 01h, 81h, 82h	; 0x2A1: row 52 (tiles B1-B3; tiles 81-82)
		db	 8Fh, 90h, 01h,0C9h,0CAh,0CBh	; 0x2A7: row 53 (tiles 8F-90; tiles C9-CB)
		db	0CCh, 01h,0D5h,0D6h,0F1h,0F2h	; 0x2AD: row 54 (tile CC; tiles D5-D6, F1-F2)

tako_frame_A2B3	label	byte			; 0xA2B3 -- A[11]/D[5] (frame ptr lands cleanly at line start below)
		db	 01h,0F3h,0F4h,0F5h,0F6h, 01h	; 0x2B3: row 55 (tiles F3-F6)
		db	0F7h,0F8h,0F9h,0FAh, 01h, 01h	; 0x2B9: row 56 (tiles F7-FA)
		db	 02h, 03h, 04h, 01h, 05h, 06h	; 0x2BF: row 57 (tiles 02-04; tiles 05-06) -- B2 frame at 0xA2C2 starts mid-row
		db	 07h, 08h, 01h, 09h, 0Ah, 0Bh	; 0x2C5: row 58 (tiles 07-08; tiles 09-0B)
		db	 0Ch, 00h, 0Dh, 0Eh, 0Fh, 10h	; 0x2CB: row 59 (tile 0C; tiles 0D-10)

tako_frame_A2D1	label	byte			; 0xA2D1 -- B[4] (frame ptr lands cleanly at line start below)
		db	 00h, 11h, 12h, 13h, 14h, 00h	; 0x2D1: row 60 (tiles 11-14)
		db	 15h, 16h, 17h, 18h, 00h, 11h	; 0x2D7: row 61 (tiles 15-18; tile 11)
		db	 12h, 13h, 14h, 02h, 0Dh, 0Eh	; 0x2DD: row 62 (tiles 12-14; tiles 0D-0E)
		db	 0Fh, 10h, 02h, 11h, 12h, 13h	; 0x2E3: row 63 (tiles 0F-10; tiles 11-13) -- B5 frame at 0xA2E5 starts mid-row
		db	 14h, 02h, 15h, 16h, 17h, 18h	; 0x2E9: row 64 (tile 14; tiles 15-18)
		db	 02h, 11h, 12h, 13h, 14h, 01h	; 0x2EF: row 65 (tiles 11-14)
		db	 0Dh, 0Eh, 0Fh, 10h, 01h, 11h	; 0x2F5: row 66 (tiles 0D-10; tile 11) -- B9 frame at 0xA2F9 starts mid-row
		db	 12h, 13h, 14h, 01h, 15h, 16h	; 0x2FB: row 67 (tiles 12-14; tiles 15-16)
		db	 17h, 18h, 01h, 11h, 12h, 13h	; 0x301: row 68 (tiles 17-18; tiles 11-13)
		db	 14h, 00h, 19h, 1Ah, 1Bh, 1Ch	; 0x307: row 69 (tile 14; tiles 19-1C)

tako_frame_A30D	label	byte			; 0xA30D -- B[3] (frame ptr lands cleanly at line start below)
		db	 00h, 19h, 1Ah, 1Bh, 1Ch, 00h	; 0x30D: row 70 (tiles 19-1C)
		db	 19h, 1Ah, 1Bh, 1Ch, 00h, 19h	; 0x313: row 71 (tiles 19-1C; tile 19)
		db	 1Ah, 1Bh, 1Ch, 01h, 1Dh, 1Eh	; 0x319: row 72 (tiles 1A-1C; tiles 1D-1E)
		db	 1Fh, 20h, 01h, 6Eh, 6Eh, 6Eh	; 0x31F: row 73 (tiles 1F-20; tile 6E ??3) -- B6 frame at 0xA321 starts mid-row
		db	 6Eh, 01h, 6Fh, 70h, 71h, 72h	; 0x325: row 74 (tile 6E; tiles 6F-72) -- B0 frame at 0xA326 starts mid-row
		db	 01h, 73h, 74h, 75h, 76h, 01h	; 0x32B: row 75 (tiles 73-76)
		db	 00h, 00h, 77h, 78h, 02h, 79h	; 0x331: row 76 (tiles 77-78; tile 79)
		db	 7Ah, 7Bh, 7Ch, 00h,0FBh,0FCh	; 0x337: row 77 (tiles 7A-7C; tiles FB-FC) -- B10 frame at 0xA33A starts mid-row
		db	0FDh,0FEh, 02h,0FBh,0FCh,0FDh	; 0x33D: row 78 (tiles FD-FE; tiles FB-FD) -- B7 frame at 0xA33F starts mid-row
		db	0FEh				; 0x343: row 79 tail (tile FE; B8 frame at 0xA344 follows in aux ptr tbl)

; -------------------------------------------------------------------------
;  Tentacle / aux ptr table (offset 0x34D..0x358) + 4-byte aux records
;  (offset 0x359..0x368) + 4-byte trailing pad (0x369..0x36C).
;  The first 2 ptr entries (0xA355, 0xA355) point INTO the ptr table at
;  entry 4's offset -- the bytes there serve as a 4-byte "data record"
;  to entries 0/1 (overlap pattern, same idea as 301EAI1's
;  crab_data_block_2).
; -------------------------------------------------------------------------

tako_aux_ptr_tbl	label	word		; offset 0x34D
		db	 55h,0A3h			; entry 0 -> 0xA355 (overlap into self)
		db	 55h,0A3h			; entry 1 -> 0xA355 (dup)
		db	 59h,0A3h			; entry 2 -> 0xA359
		db	 5Dh,0A3h			; entry 3 -> 0xA35D
		db	 61h,0A3h			; entry 4 -> 0xA361
		db	 65h,0A3h			; entry 5 -> 0xA365

tako_aux_records:				; offset 0x359 -- 4-byte records
		db	 05h, 05h, 05h, 05h	; entry 2 record
		db	 04h, 00h, 04h, 00h	; entry 3 record
		db	 05h, 04h, 04h, 00h	; entry 4 record
		db	 05h, 04h, 05h, 00h	; entry 5 record
		db	 09h, 09h, 09h, 09h	; trailing pad / extra record

; -------------------------------------------------------------------------
;  Trailing AI primary dispatch (file offset 0x36D) -- runs straight into
;  the state-byte dispatch.  Mirrors 301EAI1's `crab_data_block_2` layout:
;  the JMP indexes a table whose first 4 bytes overlap with the JMP
;  encoding itself, making the first 2 entries unreachable placeholders.
; -------------------------------------------------------------------------

tako_ai_dispatch_pre:				; offset 0x36D -- entry from primary dispatch
		mov	bl,[si+4]		; bytes 8A 5C 04
		and	bl,0Fh			; bytes 80 E3 0F  (mask state nibble)
		xor	bh,bh			; bytes 32 FF
		add	bx,bx			; bytes 03 DB     (scale to word index)
		jmp	word ptr ds:[bx+0A377h]	; bytes FF A7 77 A3 -- table at 0xA377

; AI primary dispatch table (4 valid handlers; first 2 entries overlap the
; JMP bytes so they're unreachable).  Indexed by [si+4]&0x0F (post-shift bx).

tako_ai_dispatch_tbl:				; offset 0x37B (= 0xA37B in DS)
		db	 84h,0A3h		; idx 2 -> tako_ai_main_entry (0xA384)
		db	 83h,0A3h		; idx 3 -> (alt entry, one byte earlier)
		db	 0D8h,0A6h		; idx 4 -> tako_alt_state_a   (0xA6D8)
		db	 0A4h,0A7h		; idx 5 -> tako_alt_state_b   (0xA7A4)
		db	 23h,0A9h		; idx 6 -> tako_seek_state    (0xA923)
		db	 23h,0A9h		; idx 7 -> tako_seek_state (dup)

; Inline AI-entry tail (file offsets 0x387..0x395) -- pre-roll for
; tako_ai_main_entry.  Same shape as 301EAI1 but with [si+8]=8 cooldown.

		db	 0C3h			; offset 0x387 -- retn (filler / pad)
		db	 0F6h, 44h, 08h,0FFh	; test byte ptr [si+8], 0FFh
		db	 75h, 04h		; jnz  tako_ai_main_entry
		db	 0C6h, 44h, 08h, 08h	; mov  byte ptr [si+8], 8 (cooldown=8)
		db	 0F6h, 44h, 05h, 20h	; test byte ptr [si+5], 20h
		db	 74h, 03h		; jz   tako_ai_main_entry (next instruction)
		db	 0E9h, 14h, 03h		; jmp  enter_hide_state (hide handler)

tako_ai_main_entry:				; offset 0x396 (= 0xA396 in DS)

check_hit_flag:
		test	byte ptr [si+15h],40h	; '@'
		jz	check_swim_y			; Jump if zero
		jmp	enter_hide_state

check_swim_y:
		call	step_swim_y
		jc	after_swim_check			; Jump if carry Set
		retn

after_swim_check:
		test	byte ptr [si+9],1
		jz	state_idle_branch			; Jump if zero
		jmp	state_swim_active

state_idle_branch:
		call	distance_check_5
		jc	state_idle_close			; Jump if carry Set
		cmp	al,0FFh
		je	after_distance_check			; Jump if equal
		xor	byte ptr [si+5],80h

after_distance_check:
		add	byte ptr [si+6],80h
		jc	phase_high_carry			; Jump if carry Set
		jmp	common_writeback

phase_high_carry:
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		test	byte ptr [si+5],80h
		jnz	try_step_east			; Jump if not zero
		call	step_neg_x
		jc	set_facing_east_done			; Jump if carry Set
		jmp	common_writeback

set_facing_east_done:
		or	byte ptr [si+5],80h
		jmp	common_writeback

try_step_east:
		call	step_pos_x
		jc	clear_facing_east			; Jump if carry Set
		jmp	common_writeback

clear_facing_east:
		and	byte ptr [si+5],7Fh
		jmp	common_writeback

state_idle_close:
		and	byte ptr [si+5],7Fh
		mov	al,11h
		cmp	al,[si+3]
		jb	check_facing_for_step			; Jump if below
		or	byte ptr [si+5],80h

check_facing_for_step:
		test	byte ptr [si+5],80h
		jz	west_path_check			; Jump if zero
		sub	al,[si+3]
		cmp	al,ds:tako_tbl_i
		je	set_swim_targets			; Jump if equal
		jc	east_far_step_neg			; Jump if carry Set
		call	step_pos_x
		jc	set_swim_targets			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	common_writeback

east_far_step_neg:
		call	step_neg_x
		jc	random_attack_test			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	common_writeback

west_path_check:
		mov	ah,[si+3]
		sub	ah,al
		cmp	ah,ds:tako_tbl_j
		je	set_swim_targets			; Jump if equal
		jc	west_far_step_pos			; Jump if carry Set
		call	step_neg_x
		jc	set_swim_targets			; Jump if carry Set
		inc	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	common_writeback

west_far_step_pos:
		call	step_pos_x
		jc	random_attack_test			; Jump if carry Set
		dec	byte ptr [si+6]
		and	byte ptr [si+6],3
		jmp	common_writeback

set_swim_targets:
		call	word ptr cs:tako_facing_fn_ptr	; (data_6+4 -- inline pseudo-fn, returns AL with sign for facing)
		and	al,3
		dec	al
		add	al,8
		mov	ds:tako_tbl_i,al
		call	word ptr cs:tako_facing_fn_ptr	; (data_6+4 -- inline pseudo-fn, returns AL with sign for facing)
		and	al,3
		sub	al,2
		add	al,9
		mov	ds:tako_tbl_j,al
		call	distance_check_5
		jc	enter_swim_state			; Jump if carry Set
		jmp	common_writeback

enter_swim_state:
		or	byte ptr [si+9],1
		mov	byte ptr [si+6],4
		jmp	common_writeback

random_attack_test:
		call	word ptr cs:tako_facing_fn_ptr	; (data_6+4 -- inline pseudo-fn, returns AL with sign for facing)
		and	al,1
		jz	enter_attack_state			; Jump if zero
		retn

enter_attack_state:
		or	byte ptr [si+9],3
		mov	byte ptr [si+6],4
		jmp	common_writeback

state_swim_active:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],6
		je	swim_launch_tentacles			; Jump if equal
		cmp	byte ptr [si+6],8
		je	swim_finish_phase8			; Jump if equal
		jmp	common_writeback

swim_finish_phase8:
		and	byte ptr [si+9],0FCh
		mov	byte ptr [si+6],0
		jmp	common_writeback

swim_launch_tentacles:
		mov	al,[si+3]
		mov	ds:tako_tbl_c,al
		mov	ds:tako_tbl_g,al
		inc	al
		mov	ds:tako_tbl_a,al
		mov	ds:tako_tbl_e,al
		mov	al,[si+2]
		add	al,2
		mov	ds:tako_tbl_d,al
		mov	ds:tako_tbl_b,al
		mov	ds:tako_tbl_h,al
		mov	ds:tako_tbl_f,al
		mov	bx,0A4FDh
		mov	ax,0A517h
		test	byte ptr [si+5],80h
		jnz	swim_facing_west_picked			; Jump if not zero
		mov	bx,0A50Ah
		mov	ax,0A524h

swim_facing_west_picked:
		test	byte ptr [si+9],2
		jz	swim_state_dispatch			; Jump if zero
		xchg	bx,ax

swim_state_dispatch:
		call	word ptr cs:ai_attack_fn
		jmp	common_writeback

; -------------------------------------------------------------------------
;  Tentacle launch parameter blocks (offset 0x546..0x583).
;  Two ~16-byte parameter records used by the tentacle-launch attack.
;  Format appears to be: position+offset bytes, then a `9A 00` flag
;  pair, an animation count byte, length+pad bytes, then a target ptr
;  word (0xA531 / 0xA53D / 0xA541) followed by a per-row mask table
;  (0xFF terminated).  Indexed by [si+5] bit 7 (facing).
; -------------------------------------------------------------------------

tako_tentacle_params:				; offset 0x546
		db	 00h, 00h, 9Ah, 00h, 0FFh, 40h, 08h, 00h	; record 1: hdr + flag + anim
		db	 00h, 31h,0A5h, 00h, 00h, 00h			;   target ptr 0xA531 + pad
		db	 00h, 9Ah, 00h, 0FFh, 40h, 08h, 00h, 00h	; record 2: hdr (offset 0x554)
		db	 3Dh,0A5h, 00h, 00h, 00h, 00h			;   target ptr 0xA53D + pad
		db	 9Ah, 00h, 07h, 00h, 14h			; record 3: short hdr (offset 0x560)
		db	8 dup (0)					;   pad
		db	 9Ah, 00h, 07h, 04h, 14h, 00h, 00h, 00h, 00h	; record 4
tako_tentacle_mask_a	db	 00h, 00h, 01h, 01h, 01h, 00h, 00h	; per-frame mask A (offset 0x575)
tako_tentacle_mask_b	db	 07h, 07h, 07h, 07h, 07h, 07h, 0FFh	; per-frame mask B (offset 0x57C)
		db	 03h, 03h, 03h, 04h, 04h, 05h, 05h		; per-frame mask C
		db	 05h, 05h, 05h, 05h, 0FFh			;   end marker

tako_ai_main	endp

step_pos_x		proc	near
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	step_pos_x_after_test			; Jump if carry=0
		retn

step_pos_x_after_test:
		call	collide_check_right
		jnc	step_pos_x_collision_ok			; Jump if carry=0
		retn

step_pos_x_collision_ok:
		mov	bx,[si]
		inc	bx
		mov	ax,ds:gvar_proj_cnt
		sub	ax,bx
		jnz	step_pos_x_no_wrap			; Jump if not zero
		xchg	bx,ax

step_pos_x_no_wrap:
		mov	[si],bx
		mov	[si+10h],bx
		inc	byte ptr [si+3]
		inc	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

step_pos_x		endp

collide_check_right		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		inc	di
		inc	di
		mov	cx,4

collide_right_loop:
				mov	al,[di]
				call	word ptr cs:fight_cb_cmp_tile
				stc				; Set carry flag
				jz	collide_right_continue			; Jump if zero
				retn

collide_right_continue:
				xchg	si,di
				add	si,24h
				call	word ptr cs:fight_cb_mark_adj
				xchg	si,di
				loop	collide_right_loop		; Loop if cx > 0

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

collide_check_right		endp

step_neg_x		proc	near
		cmp	byte ptr [si+3],2
		jae	step_neg_x_after_test			; Jump if above or =
		retn

step_neg_x_after_test:
		call	collide_check_left
		jnc	step_neg_x_collision_ok			; Jump if carry=0
		retn

step_neg_x_collision_ok:
		mov	ax,[si]
		dec	ax
		cmp	ax,0FFFFh
		jne	step_neg_x_no_wrap			; Jump if not equal
		mov	ax,ds:gvar_proj_cnt
		dec	ax

step_neg_x_no_wrap:
		mov	[si],ax
		mov	[si+10h],ax
		dec	byte ptr [si+3]
		dec	byte ptr [si+13h]
		clc				; Clear carry flag
		retn

step_neg_x		endp

collide_check_left		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		dec	di
		mov	cx,4

collide_left_loop:
				mov	al,[di]
				call	word ptr cs:fight_cb_cmp_tile
				stc				; Set carry flag
				jz	collide_left_continue			; Jump if zero
				retn

collide_left_continue:
				xchg	si,di
				add	si,24h
				call	word ptr cs:fight_cb_mark_adj
				xchg	si,di
				loop	collide_left_loop		; Loop if cx > 0

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

collide_check_left		endp

step_swim_y		proc	near
		test	byte ptr [si+3],0FFh
		stc				; Set carry flag
		jnz	swim_y_after_zero			; Jump if not zero
		retn

swim_y_after_zero:
		cmp	byte ptr [si+3],23h	; '#'
		stc				; Set carry flag
		jnz	swim_y_after_max			; Jump if not zero
		retn

swim_y_after_max:
		call	collide_check_y
		jnc	swim_y_collision_ok			; Jump if carry=0
		retn

swim_y_collision_ok:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn

step_swim_y		endp

collide_check_y		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	si,di
		add	si,offset data_3
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	cx,2

collide_y_loop:
				mov	al,[di]
				call	word ptr cs:fight_cb_cmp_tile
				stc				; Set carry flag
				jz	collide_y_continue			; Jump if zero
				retn

collide_y_continue:
				inc	di
				loop	collide_y_loop		; Loop if cx > 0

		dec	di
		mov	al,[di]
		or	al,[di-1]
		or	al,[di-1]
		add	al,al
		retn

collide_check_y		endp

enter_hide_state:
		mov	al,[si+15h]
		and	al,0BFh
		or	al,20h			; ' '
		mov	[si+5],al
		or	al,60h			; '`'
		mov	[si+15h],al
		jmp	word ptr cs:ai_hide_fn

common_writeback:
		mov	al,[si+6]
		mov	[si+16h],al
		mov	al,[si+5]
		and	al,80h
		mov	ah,[si+15h]
		and	ah,7Fh
		or	al,ah
		mov	[si+15h],al
		retn

; AI primary dispatch handler (idx 4: tako_alt_state_a, target 0xA6D8).
; Entry bytes overlap the previous instruction's displacement byte; first
; few bytes (`08 08`) decode bogusly but are harmless before the cooldown
; test.  Sourcer can't trace this from the dispatch table in DS.

tako_alt_state_a:				; offset 0xA6D8 (entry overlap with retn above)
		or	[bx+si],cl		; bytes 08 08 -- benign filler
		test	byte ptr [si+8],0FFh
		jnz	alt_a_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],4

alt_a_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	alt_a_check_idle			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

alt_a_check_idle:
		call	word ptr cs:fight_cb_blocked
		jc	alt_a_idle_done			; Jump if carry Set
		retn

alt_a_idle_done:
		test	byte ptr [si+9],1
		jnz	alt_a_state1_active			; Jump if not zero
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		jz	alt_a_set_state_1			; Jump if zero
		retn

alt_a_set_state_1:
		or	byte ptr [si+9],1
		and	byte ptr [si+9],0FDh
		mov	byte ptr [si+0Ah],0
		retn

alt_a_state1_active:
		test	byte ptr [si+9],2
		jnz	alt_a_state2_active			; Jump if not zero
		mov	al,[si+0Ah]
		and	al,3
		add	al,8
		mov	[si+6],al
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],8
		je	alt_a_state2_pick			; Jump if equal
		retn

alt_a_state2_pick:
		or	byte ptr [si+9],2
		call	word ptr cs:tako_facing_fn_ptr	; (data_6+4 -- inline pseudo-fn, returns AL with sign for facing)
		or	al,al			; Zero ?
		js	alt_a_pat_b_branch			; Jump if sign=1
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	si,di
		add	si,4Ah
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		jz	alt_a_pick_pat_a			; Jump if zero
		jmp	word ptr cs:fight_cb_step_neg

alt_a_pick_pat_a:
		jmp	word ptr cs:fight_cb_step_pos

alt_a_pat_b_branch:
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	si,di
		add	si,47h
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	al,[di]
		call	word ptr cs:fight_cb_cmp_tile
		jz	alt_a_pat_a_alt			; Jump if zero
		jmp	word ptr cs:fight_cb_step_pos

alt_a_pat_a_alt:
		jmp	word ptr cs:fight_cb_step_neg

alt_a_state2_active:
		mov	al,[si+0Ah]
		and	al,3
		add	al,8
		mov	[si+6],al
		inc	byte ptr [si+0Ah]
		cmp	byte ptr [si+0Ah],0Ch
		je	alt_a_state2_finish			; Jump if equal
		retn

alt_a_state2_finish:
		and	byte ptr [si+9],0FEh
		mov	byte ptr [si+6],0
		retn

; AI primary dispatch handler (idx 5: tako_alt_state_b, target 0xA7A4).
; Same dispatch path as alt_state_a but with cooldown=2.

tako_alt_state_b:				; offset 0xA7A4
		call	word ptr cs:fight_cb_alt
		jnz	alt_b_after_check			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

alt_b_after_check:
		test	byte ptr [si+8],0FFh
		jnz	alt_b_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],2

alt_b_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	alt_b_check_state			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

alt_b_check_state:
		test	byte ptr [si+9],2
		jz	alt_b_state2_branch			; Jump if zero
		jmp	alt_b_state2_active

alt_b_state2_branch:
		test	byte ptr [si+9],4
		jz	alt_b_state8_branch			; Jump if zero
		jmp	alt_b_state4_branch

alt_b_state8_branch:
		test	byte ptr [si+9],8
		jnz	alt_b_state8_active			; Jump if not zero
		add	byte ptr [si+6],21h	; '!'
		and	byte ptr [si+6],0E1h
		call	word ptr cs:fight_cb_blocked
		jc	alt_b_phase_test			; Jump if carry Set
		retn

alt_b_phase_test:
		call	distance_check_5
		jc	alt_b_set_state8			; Jump if carry Set
		mov	al,[si+6]
		and	al,0E0h
		jz	alt_b_phase_zero_pick			; Jump if zero
		retn

alt_b_phase_zero_pick:
		call	distance_check_5
		cmp	al,0FFh
		je	alt_b_set_state8			; Jump if equal
		and	byte ptr [si+5],7Fh
		or	[si+5],al
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8
		retn

alt_b_set_state8:
		call	word ptr cs:tako_facing_fn_ptr	; (data_6+4 -- inline pseudo-fn, returns AL with sign for facing)
		and	al,1
		jnz	alt_b_phase_to_2			; Jump if not zero
		or	byte ptr [si+9],4
		mov	byte ptr [si+0Ah],0
		retn

alt_b_phase_to_2:
		mov	byte ptr [si+6],2
		or	byte ptr [si+9],8

alt_b_state8_active:
		mov	al,[si+6]
		mov	ah,al
		inc	al
		and	al,7
		cmp	al,7
		jae	alt_b_finish_phase			; Jump if above or =
		mov	ch,ah
		and	ch,0F0h
		or	al,ch
		mov	[si+6],al
		mov	bx,0A8ECh
		test	byte ptr [si+5],80h
		jnz	alt_b_use_default_tbl			; Jump if not zero
		mov	bx,tako_tbl_o

alt_b_use_default_tbl:
		mov	al,ah
		sub	al,2
		xlat				; al=[al+[bx]] table
		call	word ptr cs:fight_cb_range
		jc	alt_b_xlat_step			; Jump if carry Set
		retn

alt_b_xlat_step:
		call	distance_check_5
		jc	alt_b_finish_phase			; Jump if carry Set
		xor	byte ptr [si+5],80h

alt_b_finish_phase:
		and	byte ptr [si+9],0F7h
		mov	byte ptr [si+6],0
		jmp	word ptr cs:fight_cb_blocked

alt_b_state4_branch:
		inc	byte ptr [si+0Ah]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		cmp	byte ptr [si+0Ah],4
		je	alt_b_state4_phase4			; Jump if equal
		retn

alt_b_state4_phase4:
		mov	byte ptr [si+6],7
		mov	al,[si+3]
		mov	ds:tako_tbl_m,al
		inc	al
		mov	ds:tako_tbl_k,al
		mov	al,[si+2]
		inc	al
		and	al,3Fh			; '?'
		mov	ds:tako_tbl_n,al
		mov	ds:tako_tbl_l,al
		mov	bx,0A8D2h
		test	byte ptr [si+5],80h
		jnz	alt_b_state4_use_default			; Jump if not zero
		mov	bx,0A8DFh

alt_b_state4_use_default:
		call	word ptr cs:ai_attack_fn
		and	byte ptr [si+9],0FBh
		or	byte ptr [si+9],2
		mov	byte ptr [si+0Ah],0
		retn

alt_b_state2_active:
		inc	byte ptr [si+0Ah]
		inc	byte ptr [si+6]
		and	byte ptr [si+6],1
		cmp	byte ptr [si+0Ah],6
		je	alt_b_state2_finish			; Jump if equal
		retn

alt_b_state2_finish:
		and	byte ptr [si+9],0FDh
		retn

; Tentacle attack parameter block (alternate set).  Same layout as
; tako_tentacle_params above but with 0x9E flag byte and shorter
; mask tables.

tako_tentacle_params_alt:			; offset 0x991
		db	 00h, 00h, 9Eh, 00h, 06h, 00h, 14h	; record header
		db	8 dup (0)				;   pad
		db	 9Eh, 00h, 06h, 04h, 14h, 00h		; second record
		db	 00h, 00h, 00h, 00h, 00h, 01h		;   target/pad bytes
		db	 00h, 00h, 07h, 03h, 04h, 04h, 05h	;   per-frame mask

distance_check_5		proc	near
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
		jnz	dist5_far_clear_carry			; Jump if not zero
		retn

dist5_far_clear_carry:
		clc				; Clear carry flag
		retn

distance_check_5		endp

; AI primary dispatch handler (idx 6/7: tako_seek_state, target 0xA923).
; Multi-tentacle / seek state dispatcher -- jumps to one of 4 sub-state
; handlers via tako_state_dispatch (DS at 0xA956).  Cooldown=3.

tako_seek_state:				; offset 0xA923
		call	word ptr cs:fight_cb_alt
		jnz	seek_after_check			; Jump if not zero
		jmp	word ptr cs:fight_cb_spawn

seek_after_check:
		test	byte ptr [si+8],0FFh
		jnz	seek_seed_cooldown			; Jump if not zero
		mov	byte ptr [si+8],3

seek_seed_cooldown:
		test	byte ptr [si+5],20h	; ' '
		jz	seek_dispatch_by_state_hi			; Jump if zero
		jmp	word ptr cs:ai_hide_fn

seek_dispatch_by_state_hi:
		mov	bl,[si+9]
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:tako_tbl_p[bx]	;*

; tako_state_dispatch sub-state handlers (DS table at 0xA956).
; Bytes immediately after the JMP are the dispatch table itself (4 word
; ptrs) overlapping into the first few handler bytes -- Sourcer
; mis-decodes them as `pop si / test ax,0A989h / pushf / test ax,0AA3Ch`
; but the values are pointers 0xA95E, 0xA989, 0xA99C, 0xAA3C.

tako_substate_00:				; offset 0xA95E -- sub-state 0 (idle/decel)
		pop	si			; bytes 5E A9 89 A9 9C A9 3C AA --
		test	ax,0A989h		;   dispatch table values, not real code
		pushf				;   (decode is harmless until ZF check below)
		test	ax,0AA3Ch
		call	word ptr cs:fight_cb_map_fwd
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

; tako_substate_01 -- entered via dispatch (DS:[0xA95C] = 0xA989).  First
; 4 bytes overlap the prior `mov [si+6],0/retn` instruction's operand
; bytes; harmless `inc sp; push es; add bl,al` decode before real code.

tako_substate_01:				; offset 0xA989 -- sub-state 1 (phase advance)
		inc	byte ptr [si+6]
		and	byte ptr [si+6],7
		cmp	byte ptr [si+6],3
		je	sub01_advance_to_80			; Jump if equal
		retn

sub01_advance_to_80:
		mov	byte ptr [si+9],80h
		retn

; tako_substate_02 -- entered via dispatch (DS:[0xA95E] = 0xA99C).  This
; is the pursue/chase state: distance-based selection of pace and facing.

tako_substate_02:				; offset 0xA99C -- sub-state 2 (chase / range select)
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

; tako_substate_03 -- entered via dispatch (DS:[0xA960] = 0xAA3C).  Step
; cycle / walking state with [si+9] bit 5 = "cooldown" sub-flag.

tako_substate_03:				; offset 0xAA3C -- sub-state 3 (step cycle)
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

seg_a		ends

		end	start