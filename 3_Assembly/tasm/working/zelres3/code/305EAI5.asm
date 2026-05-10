
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
;  State machine (MEDA -- jellyfish, 4 sub-handlers):
;
;    Primary dispatch by [si+4]&0xF (table at 0xA345):
;      idx 4/5 -> sub01_handler  (idle/hover, cooldown=0x18)
;      idx 6   -> sub02_handler  (projectile spawn, cooldown=0x10)
;      idx 7   -> sub03_handler  (chase/dist4, cooldown=8)
;      idx 8   -> sub04_handler  (boundary patrol, cooldown=8)
;
;    sub01 (idle/hover):
;       collide_outer --no--> retn
;            |yes
;            v
;       [si+9]&1 ? --no--> distance_check_4 ? --yes--> rng-gate -> [si+9]|=1
;            |yes                              --no--> phase step pos/neg
;            v                                          (face hero, cycle)
;       phase_inc -> anim 8..0xB then [si+9]&=~1 (back to idle)
;       advance_xy -> ai_attack_fn (xlat via meda_tbl_e..h)
;
;    sub02 (proj spawn): visibility/anim-id checks (1/4/5/6/8 -> hide);
;       fight_cb_spawn_alt -> emit clone projectile to enemy_data_ext;
;       phase_advance -> step toward hero, [si+9]&=~2 done.
;
;    sub03 (chase): [si+9].4 -> alt double-step branch
;       [si+9].2 -> phase 4 = sets state via dist4 then rng-gate -> state0
;       no bits -> phase advance + step pos/neg, sets state2 on success.
;
;    sub04 (patrol): [si+9].1 -> branch_b (block + anim_inc -> state2)
;       [si+9].2 -> branch_c (low/high range alt step branches)
;       no bits -> anim_step + map_fwd/step_neg/pos cycle.
;
;  Connections:
;    Loads:        none (loaded as data by 200FIGHT; no SAR loads of its own)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_step_neg (6008h), fight_cb_step_neg_2 (600Ah),
;                  fight_cb_map_fwd (600Ch), fight_cb_map_back (600Eh),
;                  fight_cb_step_pos (6010h), fight_cb_step_pos_2 (6012h),
;                  fight_cb_blocked (6014h), fight_cb_record_ofs (6028h),
;                  fight_cb_mark_adj (602Ah), fight_cb_tile_index (602Ch),
;                  fight_cb_cmp_tile (602Eh), fight_cb_aux_40 (6040h),
;                  fight_cb_spawn_alt (603Eh) for body-segment / projectile
;                  spawn; also references battle_ref_a (0A2AEh) and
;                  battle_ref_b (0B5B4h) into the 200FIGHT binary, and a
;                  local intro-fn pointer at ai_fn_intro (1312h).
;    Called by:    200FIGHT enemy AI dispatch table (MEDA enemy slot;
;                  paired with sprite/arena module 313MEDA.BIN).
;    Reads/writes: gvar_proj_cnt (0C002h), gvar_frame_cnt (0FF35h),
;                  gvar_sub_frame (0FF4Ah); enemy slot record fields
;                  [si+0..si+Ah]; MEDA behaviour tables meda_tbl_a..h
;                  (0A1E6h..0A429h); extended enemy_data_ext at 0ED20h.
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
; Section 2: Module-local exports
; ----------------------------------------------------------------------
ai_fn_intro	equ	1312h			; intro/spawn fn (early table)


; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
meda_tbl_a	equ	0A1E6h			; MEDA behaviour lookup A
meda_tbl_b	equ	0A268h			; MEDA behaviour lookup B
meda_tbl_c	equ	0A29Ah			; MEDA behaviour lookup C
meda_tbl_d	equ	0A31Ch			; MEDA behaviour lookup D
meda_tbl_e	equ	0A41Bh			; MEDA behaviour lookup E
meda_tbl_f	equ	0A41Ch			; MEDA behaviour lookup F
meda_tbl_g	equ	0A428h			; MEDA behaviour lookup G
meda_tbl_h	equ	0A429h			; MEDA behaviour lookup H


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
battle_ref_a	equ	0A2AEh			; ref into 200FIGHT code (battle entry A)
battle_ref_b	equ	0B5B4h			; ref into 200FIGHT code (battle entry B)


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_meda_ai_main	proc	far

start:
; -------------------------------------------------------------------------
;  meda_header_data -- 52-byte preamble at file offset 0x000.
;  First 6 bytes form ptr fragment (F7 09 00 00 37 A3 -> ptr 0xA337);
;  followed by 16 bytes of small init params, then 26 zero pad bytes.
;  Mirrors zela_header_data in 304EAI4.asm.
; -------------------------------------------------------------------------
		db	0F7h, 09h, 00h, 00h, 37h,0A3h	; offset 0x00: header (ptr fragment 0xA337)
		db	 00h, 00h, 00h, 00h, 21h,0A3h	; offset 0x06: header tail (ptr 0xA321)
		db	 32h, 32h, 14h, 0Ah, 0Ah, 00h	; offset 0x0C: init params row 0
		db	 00h, 00h, 28h, 28h, 14h, 14h	; offset 0x12: init params row 1
		db	 0Ah, 00h			; offset 0x18: spacing values
		db	26 dup (0)			; offset 0x1A: 26-byte zero pad

; -------------------------------------------------------------------------
;  meda_frame_ptr_tbl_a -- east-facing sprite-frame pointer table
;  (DS-relative). Entries are 2-byte LE pointers into the MEDA sprite
;  atlas (0xA0xx-0xA2xx). Zero entries are sentinels for unused slots.
; -------------------------------------------------------------------------

meda_frame_ptr_tbl_a:
		db	0B0h,0A0h, 37h,0A1h,0BEh,0A1h	; ptrs 0xA0B0,0xA137,0xA1BE
		db	0F5h,0A1h, 40h,0A2h, 00h, 00h	; ptrs 0xA1F5,0xA240 + sentinel
		db	 00h, 00h, 00h, 00h, 28h,0A1h	; sentinels + ptr 0xA128

; ----------------------------------------------------------------
; Sourcer mis-decoded this section as code; it is the tail of
; meda_frame_ptr_tbl_a interleaved with the start of a parallel
; pointer table (the 'AF A1 E6 A1 31 A2 68 A2' / 'EA A2 FE A2'
; sequences are LE pointers, not opcodes).  Bytes are preserved
; bit-perfect via mixed code/db emission.
; ----------------------------------------------------------------

init_inline_1:
		scasw				; was AF A1   -- ptr 0xA1AF (frag)
		mov	ax,ds:meda_tbl_a	; was A1 E6 A1 -- ptr 0xA1E6 (frag)
		xor	ss:meda_tbl_b[bp+si],sp	; was 31 A2 68 A2 -- ptrs 0xA231, 0xA268
		db	 00h, 00h, 00h, 00h, 00h, 00h	; sentinels (6 zero bytes)
		db	0EAh,0A2h,0FEh,0A2h, 77h,0A2h	; ptrs 0xA2EA,0xA2FE,0xA277

; -------------------------------------------------------------------------
;  meda_frame_ptr_tbl_a_tail -- continuation pointers for atlas refs.
;  Decoded as 'retn 86A2h / mov ds:[A29A],al / in ax,0A2 / ...' but the
;  real bytes form pointers 0xA286, 0xA29A, 0xA2E5 + sentinels + a tail
;  pointer table (0xA317, 0xA31C, 0xA312, 0xA2AE).
; -------------------------------------------------------------------------

init_retn_marker:
		retn	86A2h			; was C2 A2 86 A2 -- ptrs 0xA2C2, 0xA286
		mov	ds:meda_tbl_c,al	; was 9A A2     -- ptr 0xA29A (frag)
		in	ax,0A2h			; was E5 A2     -- ptr 0xA2E5 (frag)
		add	[bx+si],al		; was 00 00     -- sentinel
		pop	ss			; was 17        -- ptr fragment
		mov	ds:meda_tbl_d,ax	; was A3 1C A3  -- ptr 0xA31C (frag)
		adc	ah,ss:battle_ref_a[bp+di] ; was 12 A3 AE A2 -- ptrs 0xA312, 0xA2AE
		db	8 dup (0)			; 8-byte zero pad

; -------------------------------------------------------------------------
;  meda_frame_ptr_tbl_b -- west-facing mirror table (parallel to tbl_a).
;  Pointers 0xA0EC, 0xA173, 0xA1BE, 0xA213, 0xA240 + sentinels for
;  unused indices, then second-half pointers 0xA128, 0xA1AF, 0xA1E6,
;  0xA231, 0xA268.  Trailing meda_collide_marker / meda_anim_state_ref
;  are inline scalars used by sub01/sub02 collision tests.
; -------------------------------------------------------------------------

meda_frame_ptr_tbl_b:
		db	0ECh,0A0h, 73h,0A1h,0BEh,0A1h	; ptrs 0xA0EC,0xA173,0xA1BE
		db	 13h,0A2h, 40h,0A2h, 00h, 00h	; ptrs 0xA213,0xA240 + sentinel
		db	 00h, 00h, 00h, 00h, 28h,0A1h	; sentinels + ptr 0xA128
		db	0AFh,0A1h,0E6h,0A1h, 31h,0A2h	; ptrs 0xA1AF,0xA1E6,0xA231
		db	 68h,0A2h, 00h, 00h		; ptr 0xA268 + sentinel
meda_collide_marker		db	0	; offset 0x96: collide marker scalar
		db	0				; offset 0x97: pad
meda_anim_state_ref		db	0	; offset 0x98: anim-state ref scalar

; -------------------------------------------------------------------------
;  meda_frame_ptr_tbl_c -- attack/projectile pointer table (12 entries).
;  Pointers into MEDA atlas at 0xA2EA..0xA3AE plus tail 0xA317/A31C/A312.
; -------------------------------------------------------------------------

meda_frame_ptr_tbl_c:
		db	 00h,0EAh,0A2h,0FEh,0A2h, 77h	; pad + ptrs 0xA2EA,0xA2FE + frag
		db	0A2h,0C2h,0A2h, 86h,0A2h, 9Ah	; ptrs 0xA277,0xA2C2,0xA286 + frag
		db	0A2h,0E5h,0A2h, 00h, 00h, 17h	; ptrs 0xA29A,0xA2E5 + sentinel + frag
		db	0A3h, 1Ch,0A3h, 12h,0A3h,0AEh	; ptrs 0xA317,0xA31C,0xA312 + frag
		db	0A2h				; ptr 0xA2AE tail byte
		db	8 dup (0)			; 8-byte zero pad
; -------------------------------------------------------------------------
;  meda_anim_table_a -- east-facing pose/tile index table read in 5-byte
;  rows by fight_cb_step_pos.  Each row begins with the 01h separator and is
;  followed by 4 sprite-tile indices (atlas tile offsets).
;  Sourcer rendered a few rows as ASCII for tile values 0x5D..0x7E but
;  these are tile indices, not text.
; -------------------------------------------------------------------------

meda_anim_table_a:
		db	 01h, 8Fh, 90h, 79h, 7Ah, 01h	; row 0: tiles 8F 90 79 7A + sep
		db	 7Fh, 80h, 81h, 82h, 01h, 87h	; row 1 + row 2 head
		db	 88h, 89h, 8Ah, 01h, 7Fh, 80h	; row 2 tail + row 3 head
		db	 99h, 9Ah, 01h, 8Fh, 90h, 91h	; row 3 tail + row 4 head
		db	 92h, 01h, 7Fh, 80h, 99h, 9Ah	; row 4 tail + row 5
		db	 01h, 87h, 88h, 89h, 8Ah, 01h	; row 6 + sep
		db	 7Fh, 80h, 81h, 82h, 01h,0C7h	; row 7 + row 8 head
		db	 88h,0C9h, 8Ah, 01h,0C7h, 88h	; row 8 tail + row 9 head
		db	0CBh, 8Ah, 01h,0C7h, 88h,0CDh	; row 9 tail + row 10 head
		db	 8Ah, 01h,0C7h, 88h,0C9h, 8Ah	; row 10 tail + row 11 (dup of row 8)
		db	 01h,0B7h,0B8h,0A1h,0A2h, 01h	; row 12 + sep
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh	; row 13 + row 14 head
		db	0B0h,0B1h,0B2h, 01h,0A7h,0A8h	; row 14 tail + row 15 head
		db	0C1h,0C2h, 01h,0B7h,0B8h,0B9h	; row 15 tail + row 16 head
		db	0BAh, 01h,0A7h,0A8h,0C1h,0C2h	; row 16 tail + row 17
		db	 01h,0AFh,0B0h,0B1h,0B2h, 01h	; row 18 + sep
		db	0A7h,0A8h,0A9h,0AAh, 01h,0AFh	; row 19 + row 20 head
meda_rng_fn_ptr		dw	0B1CFh			; offset 0x11A: RNG fn ptr (CF B1)
		db	0D1h, 01h,0AFh,0CFh,0B1h,0D2h	; row 20 tail + row 21 head
		db	 01h,0AFh,0CFh,0B1h,0D3h, 01h	; row 21 tail + sep
		db	0AFh,0CFh,0B1h,0D1h, 01h,0D4h	; row 22 + row 23 head
		db	0D5h,0D6h,0D7h, 01h, 00h, 00h	; row 23 tail + zero gap head
		db	0DAh,0DBh, 01h, 00h, 00h, 00h	; row 24 + zero pad
		db	 00h, 01h, 7Bh, 7Ch, 7Dh, 7Eh	; pad sep + row 25

; -------------------------------------------------------------------------
;  meda_anim_table_b -- west-facing tile index mirror table.  Same row
;  structure (5-byte rows, 01h separator, 4 tile indices).  Indexes
;  symmetric pose set to anim_table_a (e.g. 7B 7C 7D 7E mirrors 8F 90 79 7A).
; -------------------------------------------------------------------------

meda_anim_table_b:
		db	 01h, 83h, 84h, 85h, 86h, 01h	; row 0 + sep
		db	 7Bh, 7Ch, 7Dh, 7Eh, 01h, 8Bh	; row 1 + row 2 head
		db	 8Ch, 8Dh, 8Eh, 01h, 93h, 94h	; row 2 tail + row 3 head
		db	 95h, 96h, 01h, 9Bh, 9Ch, 9Dh	; row 3 tail + row 4 head
		db	 9Eh, 01h, 93h, 94h, 95h, 96h	; row 4 tail + row 5
		db	 01h, 8Bh, 8Ch, 8Dh, 8Eh, 01h	; row 6 + sep
		db	 8Bh, 8Ch, 8Dh, 8Eh, 01h, 8Bh	; row 7 (dup) + row 8 head
		db	 8Ch, 8Dh, 8Eh, 01h, 8Bh, 8Ch	; row 8 tail (dup) + row 9 head
		db	 8Dh, 8Eh, 01h, 8Bh, 8Ch, 8Dh	; row 9 tail + row 10 head
		db	 8Eh, 01h,0A3h,0A4h,0A5h,0A6h	; row 10 tail + row 11
		db	 01h,0ABh,0A4h,0ADh,0AEh, 01h	; row 12 + sep
meda_anim_idx_a		db	0A3h		; Data table (indexed access) -- row 13 head
		db	0A4h,0A5h,0A6h, 01h,0B3h,0B4h	; row 13 tail + row 14 head
		db	0B5h				; row 14 mid byte
meda_anim_idx_b		db	0B6h		; Data table (indexed access) -- row 14 tail
		db	 01h,0BBh,0BCh,0BDh,0BEh, 01h	; row 15 + sep
		db	0C3h,0BCh,0C5h,0C6h, 01h,0BBh	; row 16 + row 17 head

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

; -------------------------------------------------------------------------
;  meda_anim_table_b_cont -- continuation tile-index rows for anim_table_b.
;  Mis-decoded as 'loopnz' / 'add sp,sp' etc. because tile values look like
;  jump opcodes; they are sprite tile indices, not code.
; -------------------------------------------------------------------------
		db	0E2h,0E3h		; row 17 tail (tiles E2 E3) -- mis-decoded as loopnz
;*		add	sp,sp
		db	 01h,0E4h		; sep + row 18 head (tile E4) -- mis-decoded as add sp,sp
		in	ax,0E6h			; was E5 E6   -- tiles E5 E6 (row 18)
		out	1,ax			; was E7 01   -- tile E7 + sep
		call	$-1514h			; was E8 E9 EA EB -- tiles E8-EB (row 19)
		jmp	short $+2		; was EB 00   -- tile EB + sep (delay-for-IO mis-decode)

; -------------------------------------------------------------------------
;  meda_anim_table_c -- 5-byte rows of pose tile indices (sep=00h).
;  Rows of 4 tile indices (atlas tiles 0x0D..0x76) for animation phase
;  sequences.  Mis-decoded as code by Sourcer; raw db form preserved.
; -------------------------------------------------------------------------

meda_anim_table_c:
		or	ax,0F0Eh		; was 0D 0E 0F 10 -- tiles row 0
		adc	[bx+si],al		; was 00 11        -- sep + tile row 1 head
		adc	ds:ai_fn_intro,cx	; was 0E 12 13 00  -- tiles row 1 + sep
		add	[si],dl			; was 14 15        -- tiles row 2 head
		adc	ax,1716h		; was 16 17        -- tiles row 2 tail
		add	[di],cl			; was 00 0D        -- sep + tile row 3 head
		sbb	[bx+di],bl		; was 18 19        -- tiles row 3
		sbb	al,[bx+si]		; was 1A 00        -- tile + sep
		add	[bx+si],al		; was 00 00        -- zero pad
		add	[bp+si],ax		; was 01 02        -- tiles row 4
		add	[bx+si],al		; was 00 00        -- sep + zero
		add	[si],al			; was 00 04        -- pad + tile row 5
		add	ax,0			; was 05 00 00 00  -- tile + sep + pad
		add	[bx],al			; was 07 08        -- tiles row 6
		or	[bx+si],al		; was 00 00        -- sep + zero
		add	[bx+si],al		; was 00 0B        -- pad + tile row 7
		or	cx,[si]			; was 0C 00 1B     -- tile + sep + tile
		add	[bp+di],bl		; was 1C 1D        -- tiles row 8
		sbb	al,1Dh			; was 1E 00 1F     -- tile + sep + tile row 9
		push	ds			; was 20           -- tile
		add	[bx],bl			; was 21 22        -- tiles row 9 tail
		and	[bx+di],ah		; was 00 23 24     -- sep + tile row 10
		and	al,[bx+si]		; was 25 00        -- tile + sep
		and	sp,[si]			; was 00 27        -- pad + tile row 11

; -------------------------------------------------------------------------
;  meda_anim_table_d -- ASCII-rendered tile index rows (sep=00h).
;  Tile values 0x27..0x66 happen to be printable ASCII so Sourcer
;  emitted them as strings, but they are sprite-tile indices.
;  Each row = 4 tile indices + 00h separator.
; -------------------------------------------------------------------------

meda_anim_table_d:
		and	ax,0			; was 28 29 -- tile row 11 tail (continues from above)
		db	27h, '()*', 0			; row 12: tiles 27 28 29 2A
		db	'+,-.', 0			; row 13: tiles 2B 2C 2D 2E
		db	'/012', 0			; row 14: tiles 2F 30 31 32
		db	'3456', 0			; row 15: tiles 33 34 35 36
		db	'789:', 0			; row 16: tiles 37 38 39 3A
		db	';<=>', 0			; row 17: tiles 3B 3C 3D 3E
		db	27h, '()*', 0			; row 18 (dup row 12)
		db	'+,-.', 0			; row 19 (dup row 13)
		db	'/012', 0			; row 20 (dup row 14)
		db	'3456', 0			; row 21 (dup row 15)
		db	'789:', 0			; row 22 (dup row 16)
		db	'?@AB', 0			; row 23: tiles 3F 40 41 42
		db	'CDEF', 0			; row 24: tiles 43 44 45 46
		db	'GHIJ', 0			; row 25: tiles 47 48 49 4A
		db	'KLMN', 0			; row 26: tiles 4B 4C 4D 4E
		db	'OPQR', 0			; row 27: tiles 4F 50 51 52
		db	'STUV', 0			; row 28: tiles 53 54 55 56
		db	'WXQR', 0			; row 29: tiles 57 58 51 52 (Q,R reused)
		db	'YZQR', 0			; row 30: tiles 59 5A 51 52
		db	'[\]^', 0			; row 31: tiles 5B 5C 5D 5E
		db	'_`ab', 0			; row 32: tiles 5F 60 61 62
		db	'cdef'				; row 33 head: tiles 63 64 65 66
		db	 00h, 00h, 00h, 69h, 6Ah, 00h	; sep + zero pad + tiles row 34 + sep
		db	 6Bh, 6Ch, 6Dh, 6Eh, 00h, 4Bh	; row 35 + row 36 head (tile 4B)
		db	 4Ch, 4Dh, 4Eh, 00h, 73h, 74h	; row 36 tail + row 37 head
		db	 75h, 76h, 01h, 03h, 06h, 0Ah	; row 37 tail (sep=01) + row 38 head

; -------------------------------------------------------------------------
;  meda_anim_table_e -- secondary tile-index table (sep=01h or 02h).
;  Continues with phase-attack pose indices and projectile sprite
;  references (tiles 0xA0..0xFB span the projectile/effect range).
; -------------------------------------------------------------------------

meda_anim_table_e:
		db	 26h, 01h, 67h, 68h, 6Fh, 70h	; row 38 tail + row 39 head
		db	 01h, 71h, 72h,0A0h,0C0h, 00h	; sep + row 40 + sep
		db	 77h, 78h, 97h, 98h, 00h, 9Fh	; row 41 + row 42 head
		db	0ACh,0BFh,0C4h, 00h,0C8h,0CAh	; row 42 tail + row 43 head
		db	0CCh,0CEh, 00h, 9Fh,0ACh,0BFh	; row 43 tail + row 44 head
		db	0C4h, 02h, 77h, 78h, 97h, 98h	; row 44 tail (sep=02) + row 45
		db	 02h, 9Fh,0ACh,0BFh,0C4h, 02h	; sep + row 46 + sep
		db	0C8h,0CAh,0CCh,0CEh, 02h, 9Fh	; row 47 + row 48 head
		db	0ACh,0BFh,0C4h, 01h, 77h, 78h	; row 48 tail (sep=01) + row 49 head
		db	 97h, 98h, 01h, 9Fh,0ACh,0BFh	; row 49 tail + row 50 head
		db	0C4h, 01h,0C8h,0CAh,0CCh,0CEh	; row 50 tail + row 51
		db	 01h, 9Fh,0ACh,0BFh,0C4h, 00h	; sep + row 52 + sep

; -------------------------------------------------------------------------
;  meda_phase_pose_tbl -- 4-byte phase-pose tile indices (sep=00h).
;  7 duplicate rows of {D0, D8, D9, DC} = idle/hover pose; final row
;  switches to {DD, DE, DF, EC} = attack-spawn pose.
; -------------------------------------------------------------------------

meda_phase_pose_tbl:
		db	0D0h,0D8h,0D9h,0DCh, 00h,0D0h	; row 0 + row 1 head
		db	0D8h,0D9h,0DCh, 00h,0D0h,0D8h	; row 1 tail + row 2 head
		db	0D9h,0DCh, 00h,0D0h,0D8h,0D9h	; row 2 tail + row 3
		db	0DCh, 00h,0D0h,0D8h,0D9h,0DCh	; row 3 tail + row 4
		db	 00h,0D0h,0D8h,0D9h,0DCh, 00h	; sep + row 5 + sep
		db	0D0h,0D8h,0D9h,0DCh, 01h,0DDh	; row 6 + sep + row 7 head

; -------------------------------------------------------------------------
;  meda_proj_pose_tbl -- projectile/effect pose tile indices (sep=00h).
;  4-byte rows with tile values 0xF1..0xFB (effect sprite range).
;  Last two rows use sep=02h (attack-emission marker).
; -------------------------------------------------------------------------

meda_proj_pose_tbl:
		db	0DEh,0DFh,0ECh, 00h,0F1h,0F1h	; row 7 tail + row 8 head
		db	0F1h,0F1h, 00h,0F1h,0F1h,0F3h	; row 8 tail + row 9 head
		db	0F3h, 00h,0F4h,0F4h,0F6h,0F6h	; row 9 tail + row 10
		db	 00h,0F8h,0F8h,0FAh,0FAh, 00h	; sep + row 11 + sep
		db	0F2h,0F2h,0F1h,0F1h, 00h,0F2h	; row 12 + row 13 head
		db	0F2h,0F3h,0F3h, 00h,0FCh,0FDh	; row 13 tail + row 14 head
		db	0F6h,0F6h, 00h,0FEh,0FEh,0FAh	; row 14 tail + row 15 head
		db	0FAh, 02h,0F5h,0F7h,0F9h,0FBh	; row 15 tail (sep=02) + row 16
		db	 00h,0EDh,0EEh,0EFh,0F0h, 02h	; sep + row 17 + sep=02
		db	0EDh,0EEh,0EFh,0F0h, 2Bh,0A3h	; row 18 (dup row 17) + ptr 0xA32B head

; -------------------------------------------------------------------------
;  meda_dispatch_jmp_tbl -- 5-entry word pointer table for AI dispatch.
;  Indexed by ([si+4]&0xF)*2.  Targets sub-state handlers:
;    0xA32B (idx?), 0xA32B (dup), 0xA32F, 0xA333, 0xA333 (dup).
; -------------------------------------------------------------------------

meda_dispatch_jmp_tbl:
		db	 2Bh,0A3h, 2Fh,0A3h, 33h,0A3h	; ptrs 0xA32B,0xA32F,0xA333
		db	 33h,0A3h			; ptr 0xA333 (dup)

; -------------------------------------------------------------------------
;  meda_phase_count_tbl -- 12-byte phase frame-count table
;  (5 frames per pose nominal, 4 for some, 0 for unused tail slots).
;  Read in parallel with meda_phase_pose_tbl during animation tick.
; -------------------------------------------------------------------------

meda_phase_count_tbl:
		db	 0Bh, 05h, 05h, 05h		; counts row 0: 0B, 05, 05, 05
		db	 05h, 04h, 05h, 04h, 05h, 00h	; counts row 1: 05, 04, 05, 04, 05, 00
		db	 05h, 00h			; counts row 2 (tail): 05, 00
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
		db	 8Ah, 5Ch, 04h, 80h	; mov bl,[si+4]; and bl,...
		db	0E3h, 0Fh, 32h,0FFh, 03h,0DBh	; ...0Fh; xor bh,bh; add bx,bx
		db	0FFh,0A7h, 45h,0A3h, 50h,0A3h	; jmp word ptr ds:[bx+0xA345] + tbl[0]=0xA350
		db	 4Fh,0A3h,0F1h,0A5h, 12h,0A8h	; tbl[1]=0xA34F, tbl[2]=0xA5F1, tbl[3]=0xA812
		db	 1Ah,0A9h,0C3h,0F6h, 44h, 08h	; tbl[4]=0xA91A; retn pad; sub01 prologue: test [si+8],..
		db	0FFh, 75h, 04h,0C6h, 44h, 08h	; ..0FFh; jnz +4; mov [si+8],..
		db	 18h,0F6h, 44h, 05h, 20h, 74h	; ..18h; sub01_main test [si+5],20h; jz..
		db	 03h,0E9h,0D2h, 00h		; ..+3; jmp sub01_finalize (E9 D2 00)

sub01_main:
		and	byte ptr [si+15h],0BFh
		call	check_collide_outer_eai5
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

; -------------------------------------------------------------------------
;  meda_attack_param_tbl -- 24-byte attack parameter block referenced by
;  the ai_attack_fn xlat call above.  Two 12-byte rows: each contains
;  (sentinel, sentinel, range_byte, _, vel_byte, _, dist_byte, ...).
;  Row 0 is east-facing, row 1 (with vel=04h) is west-facing.
; -------------------------------------------------------------------------

meda_attack_param_tbl:
		db	 00h, 00h,0B1h, 00h, 14h, 00h	; row 0: sentinels + 0xB1 + vel=14h
		db	 28h, 00h			; row 0 tail: 0x28 + sep
		db	7 dup (0)			; 7-byte zero pad (row 0 tail)
		db	0B1h, 00h, 14h, 04h, 28h, 00h	; row 1: 0xB1 + vel=14h(04) + 0x28
		db	 00h, 00h, 00h, 00h, 00h	; row 1 tail: 5-byte zero pad

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

run_meda_ai_main	endp

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

check_collide_outer_eai5		proc	near
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
		call	check_collide_inner_eai5
		jnc	sub01_collide_apply			; Jump if carry=0
		retn

sub01_collide_apply:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		inc	byte ptr [si+12h]
		and	byte ptr [si+12h],3Fh	; '?'
		clc				; Clear carry flag
		retn

check_collide_outer_eai5		endp

check_collide_inner_eai5		proc	near
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		xchg	si,di
		add	si,offset meda_collide_marker
		call	word ptr cs:fight_cb_mark_adj
		xchg	si,di
		mov	cx,2

sub01_collide_loop:
				mov	al,[di]
				call	word ptr cs:fight_cb_cmp_tile
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

check_collide_inner_eai5		endp

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
; Reached via 'jmp word ptr ds:[bx+0xA345]' in run_meda_ai_main where
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
		call	word ptr cs:fight_cb_spawn_alt
		jnc	sub02_after_27			; Jump if carry=0
		jmp	sub02_finalize

sub02_after_27:
		push	di
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
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
		call	word ptr cs:fight_cb_tile_index
		mov	cx,3

sub02_east_scan:
				lodsb				; String [si] to al
				call	word ptr cs:fight_cb_cmp_tile
				xchg	bx,si
				jz	sub02_east_scan_2			; Jump if zero
				jmp	sub02_finalize

sub02_east_scan_2:
				xchg	bx,si
				lodsb				; String [si] to al
				call	word ptr cs:fight_cb_cmp_tile
				xchg	bx,si
				jz	sub02_east_scan_3			; Jump if zero
				jmp	sub02_finalize

sub02_east_scan_3:
				xchg	bx,si
				add	si,22h
				call	word ptr cs:fight_cb_mark_adj
				loop	sub02_east_scan		; Loop if cx > 0

		sub	si,48h
		call	word ptr cs:fight_cb_tile_index
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
		call	word ptr cs:fight_cb_tile_index
		mov	cx,3

sub02_west_scan:
				lodsb				; String [si] to al
				call	word ptr cs:fight_cb_cmp_tile
				xchg	bx,si
				jnz	sub02_finalize			; Jump if not zero
				xchg	bx,si
				lodsb				; String [si] to al
				call	word ptr cs:fight_cb_cmp_tile
				xchg	bx,si
				jnz	sub02_finalize			; Jump if not zero
				xchg	bx,si
				add	si,22h
				call	word ptr cs:fight_cb_mark_adj
				loop	sub02_west_scan		; Loop if cx > 0

		sub	si,47h
		call	word ptr cs:fight_cb_tile_index
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
		call	word ptr cs:fight_cb_aux_40
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
		call	word ptr cs:fight_cb_blocked
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
		call	word ptr cs:fight_cb_step_pos
		jc	sub02_dir_set			; Jump if carry Set
		retn

sub02_dir_set:
		or	byte ptr [si+5],80h
		call	word ptr cs:fight_cb_step_neg
		jc	sub02_dir_clear			; Jump if carry Set
		retn

sub02_dir_clear:
		and	byte ptr [si+5],7Fh
		jmp	word ptr cs:fight_cb_step_pos

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
		call	word ptr cs:fight_cb_aux_40
		test	byte ptr [si+9],4
		jz	sub03_no_bit2			; Jump if zero
		jmp	sub03_alt_branch

sub03_no_bit2:
		call	word ptr cs:fight_cb_blocked
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
				call	word ptr cs:fight_cb_step_pos
				jc	sub03_dir_west			; Jump if carry Set
				retn

sub03_dir_west:
				mov	byte ptr [si+9],2
				retn

sub03_dir_east:
				call	word ptr cs:fight_cb_step_neg
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
		call	word ptr cs:fight_cb_step_pos
		call	word ptr cs:fight_cb_step_pos
		jc	sub03_alt_set2_a			; Jump if carry Set
		retn

sub03_alt_set2_a:
		mov	byte ptr [si+9],2
		mov	byte ptr [si+6],0
		retn

sub03_alt_set2_b:
		call	word ptr cs:fight_cb_step_neg
		call	word ptr cs:fight_cb_step_neg
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
		call	word ptr cs:fight_cb_aux_40
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
		call	word ptr cs:fight_cb_map_fwd
		add	byte ptr [si+6],80h
		jc	sub04_phase_test			; Jump if carry Set
		retn

sub04_phase_test:
		mov	al,10h
		cmp	al,[si+3]
		jb	sub04_call_e			; Jump if below
		call	word ptr cs:fight_cb_step_neg
		jc	sub04_branch_a			; Jump if carry Set
		retn

sub04_branch_a:
		jmp	word ptr cs:fight_cb_step_pos

sub04_call_e:
		call	word ptr cs:fight_cb_step_pos
		jc	sub04_call_e2			; Jump if carry Set
		retn

sub04_call_e2:
		jmp	word ptr cs:fight_cb_step_neg

sub04_branch_b:
		mov	al,[si+6]
		and	al,7
		cmp	al,5
		jae	sub04_call_f			; Jump if above or =
		inc	byte ptr [si+6]
		retn

sub04_call_f:
		call	word ptr cs:fight_cb_blocked
		call	word ptr cs:fight_cb_blocked
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
		call	word ptr cs:fight_cb_map_fwd
		call	word ptr cs:fight_cb_step_neg_2
		jc	sub04_call_c			; Jump if carry Set
		retn

sub04_call_c:
		call	word ptr cs:fight_cb_map_fwd
		jc	sub04_after_c			; Jump if carry Set
		retn

sub04_after_c:
		and	byte ptr [si+9],0FDh
		retn

sub04_low_anim:
		call	word ptr cs:fight_cb_map_fwd
		call	word ptr cs:fight_cb_map_back
		jc	sub04_low_anim_b			; Jump if carry Set
		retn

sub04_low_anim_b:
		call	word ptr cs:fight_cb_map_fwd
		jc	sub04_clear_bit1			; Jump if carry Set
		retn

sub04_clear_bit1:
		and	byte ptr [si+9],0FDh
		retn

seg_a		ends

		end	start