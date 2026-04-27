
PAGE  59,132

;==========================================================================
;
;  309CRAB.BIN - Crab Boss Module (zelres3 chunk 10, 'Cangrejo')
;
;  Per IDA decompilation in 3_Assembly/ida/crab.asm: this is a SELF-
;  CONTAINED boss module — it has its own AI proc (Cangrejo_AI_proc)
;  AND its own sprite frame data (frames_body_walk0..5,
;  frames_body_descent0..2, frames_body_recoil0..2, frames_body_hit,
;  frames_body_dead). It is NOT paired with 301EAI1; the alternating
;  EAI1/CRAB/EAI2/TAKO/... ordering in resource_name_table is
;  alphabetical, not pairing.
;
;  The Spanish name 'Cangrejo' ('crab') appears as an 8-char name tag
;  in the module's trailing data.
;
;  File layout (loaded at game_seg:0xA000 by 200FIGHT):
;    0x000..0x003 : file-size header word + pad (NOT executable code -
;                   Sourcer mis-decodes as `out dx,al / pop es / add [bx+si],al`)
;    0x004..0x007 : init src/dst pointers (crab_init_src=0xA2F0, crab_init_dst=fight_hp)
;    0x008..0x013 : 12 zero bytes (initial state buffer)
;    0x014..0x029 : template byte 06h x 21  (per-slot default state)
;    0x029..0x02A : 0Fh marker
;    0x02A..0x034 : template byte 06h x 10  (extended slots)
;    0x034..0x045 : crab_frame_ptr_tbl_a  -- 9 pointers to sprite frame rows
;    0x046..0x053 : 14 zero bytes (reserved)
;    0x054..0x05F : crab_frame_ptr_tbl_b  -- 5 pointers (+1 empty slot)
;    0x05C..0x301 : 14 sprite frame data rows (45..50 bytes each, tile indices)
;    0x302 onward : executable code (entered via 200FIGHT dispatch tables in DS)
;    ~0x7D8       : 8-byte name tag 'Cangrejo'
;
;  Primary code entry: scan_slot_loop (at 0x0302) -- iterates the enemy
;  slot list (SI = fight_slot_list), updates each live slot via fight-
;  engine callbacks, then drives crab spawn/animation phases.  The
;  helpers hp_dec/hp_inc adjust fight_hp; emit_sprite_rows writes crab
;  sprite rows into the slot buffer.
;
;  Connections:
;    Loads:        none (loaded as data/code by 200FIGHT; no SAR loads)
;    Calls into:   200FIGHT export table via cs:[fight_cb_*] dispatch slots:
;                  fight_cb_prep (200Ch), fight_cb_anim_step (6036h),
;                  fight_cb_hit_check (6038h), fight_cb_record_ofs (6028h).
;    Called by:    200FIGHT boss-fight dispatch when the Crab boss is
;                  loaded for an encounter. Self-contained (no separate
;                  AI handler module).
;    Reads/writes: gvar_death_flag (0FF2Eh), gvar_dir_toggle (0FF2Fh),
;                  gvar_completion (0FF30h), gvar_spawn_fx_flag (0FF75h);
;                  enemy slot list at fight_slot_list (0C010h);
;                  crab state vars crab_spawn_limit (0A481h),
;                  crab_anim_tbl_a/b/c, crab_pos_tbl (0A70Ah), fight_hp
;                  (0A7C3h), and crab phase/state bytes 0A7C5h..0A7E4h.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
crab_anim_tbl_a		equ	0A5B6h			; crab animation sequence A
crab_anim_tbl_b		equ	0A5F5h			; crab animation sequence B (misc)
crab_anim_tbl_c		equ	0A5F9h			; crab animation sequence C
crab_pos_tbl		equ	0A70Ah			; crab spawn position/grid table
crab_phase_base		equ	0A7C5h			; phase-base byte
crab_anim_base		equ	0A7EAh			; animation base (word)


; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
crab_spawn_limit	equ	0A481h			; max simultaneous crab spawns
fight_hp		equ	0A7C3h			; current fight HP (crab counter)
crab_phase_limit	equ	0A7C6h			; phase-limit byte
crab_slot_idx		equ	0A7DCh			; current slot index
crab_state_bits		equ	0A7DDh			; packed state bits
crab_frame_idx		equ	0A7DEh			; frame index (0..5)
crab_flag_d		equ	0A7DFh			; flag byte (phase selector)
crab_dir_flag		equ	0A7E0h			; direction flag
crab_sub_phase		equ	0A7E1h			; sub-phase counter
crab_flag_g		equ	0A7E2h			; crab activity flag
crab_flag_h		equ	0A7E3h			; crab persistent flag (spawn counter)
crab_alt_phase		equ	0A7E4h			; alt-phase flag (idle/alternate mode)
crab_idx_e		equ	0A7E5h			; crab helper index E
crab_anim_idx		equ	0A7E6h			; animation step index
crab_anim_frame		equ	0A7E7h			; current animation frame
crab_row_pos		equ	0A7E8h			; current row position
crab_col_pos		equ	0A7E9h			; current col position
crab_timer_a		equ	0A7ECh			; phase timer A
crab_timer_b		equ	0A7EDh			; phase timer B (death animation)


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

crab_main	proc	far

; -------------------------------------------------------------------------
;  Module header (file offsets 0x000-0x033) -- loaded as data by 200FIGHT.
;  Sourcer forced `start:` here but no execution lands here; the bytes are
;  actually a 4-byte length header, a 4-byte init src/dst pair, and two
;  template blocks used to initialize the per-slot state buffer.
; -------------------------------------------------------------------------

start:

file_header:
		db	0EEh, 07h		; file length word: 0x07EE (= file_size - 4)
		db	 00h, 00h		; pad / flag word

crab_init_src_dst:
		db	0F0h,0A2h		; init src ptr = 0xA2F0 (into frame data)
		db	0C3h,0A7h		; init dst ptr = fight_hp (0xA7C3)

		db	12 dup (0)		; initial per-slot state buffer
		db	21 dup (6)		; template byte 06h x 21 (slot defaults)
		db	0Fh			; section marker
		db	10 dup (6)		; template byte 06h x 10 (extended)

; -------------------------------------------------------------------------
;  Animation frame pointer tables (word ptr[], into frame data below).
;  Each word = runtime address in game_seg (= 0xA000 + file offset).
; -------------------------------------------------------------------------

crab_frame_ptr_tbl_a	label	word		; indexed frame pointers (group A)
		db	 5Ch,0A0h, 8Eh,0A0h,0BBh,0A0h	; -> 0xA05C, 0xA08E, 0xA0BB
		db	0EDh,0A0h, 1Fh,0A1h, 4Ch,0A1h	; -> 0xA0ED, 0xA11F, 0xA14C
		db	 7Eh,0A1h,0B0h,0A1h,0E2h,0A1h	; -> 0xA17E, 0xA1B0, 0xA1E2
		db	14 dup (0)			; reserved / padding

crab_frame_ptr_tbl_b	label	word		; indexed frame pointers (group B)
		db	 14h,0A2h, 46h,0A2h, 73h,0A2h	; -> 0xA214, 0xA246, 0xA273
		db	 00h, 00h,0A5h,0A2h,0D7h,0A2h	; slot0=empty, -> 0xA2A5, 0xA2D7

; -------------------------------------------------------------------------
;  Sprite frame data (file offsets 0x05C..0x301).
;  Fourteen blocks of 45 or 50 bytes each, indexed by the pointer tables
;  above.  Each block is a run of tile-index bytes (0..0xFF) that define
;  one crab animation frame laid out as a small tile grid.  Zero bytes
;  mark row-terminator positions within a frame.
;
;  ROLE TABLE (frame_idx -> dispatch state -> visual role).
;  Frames are selected via `crab_frame_idx` (0xA7DE) which is set by the
;  dispatch chain in crab_main and consumed by emit_sprite_rows
;  (`mov di, ds:crab_pos_tbl[bx]`).  Roles below are inferred from which
;  dispatch path writes each frame_idx value -- they are best-guess
;  semantic labels, not runtime-traced.
;
;    frames 00..05 : walk cycle, 6-step (walk_dir0_advance / walk_dir1_advance
;                    cycle frame_idx 0->5->0).  ptr_tbl_a[0..5].  Two
;                    "directions" (dir_flag) share the same frames; sub_phase
;                    toggles between step and pause.  Likely 6 sideways
;                    walking poses (claws/legs alternating) used for both
;                    leftward and rightward movement.
;    frame 06     : extra walk pose / spawn-formation pose; reachable via
;                    walk_dir0_advance pre-wrap (frame_idx==6 wraps to 0)
;                    and via spawn_subloop reading crab_spawn_limit[bx]
;                    (formation-cell bias).  ptr_tbl_a[6].
;    frame 07     : hit/transition pose; ptr_tbl_a[7].  Reached only via
;                    spawn_subloop's crab_spawn_limit[bx] index, suggesting
;                    a non-walk one-shot pose (spawn arrival or stagger).
;    frame 08     : DEATH pose; explicitly set by death_frame8 when
;                    crab_timer_b >= 0x14 in death_anim.  ptr_tbl_a[8].
;                    Final corpse / static death sprite held until
;                    gvar_completion fires at timer_b==0x28.
;    frame 09     : SPAWN/ARM pose; explicitly set by anim_step_entry
;                    (`mov crab_frame_idx, 9`) when crab_anim_idx is armed
;                    (post-spawn animation start frame).  ptr_tbl_b[1].
;    frames 10..13: IDLE animation cycle, 4 frames; selected by
;                    idle_dispatch reading `crab_anim_tbl_b[crab_idx_e]`
;                    where idx_e cycles 0..3.  ptr_tbl_b[2..5].  The
;                    alt-phase (crab_alt_phase) gates this animation and
;                    likely represents the crab "pincer-snap" or breathing
;                    idle loop played when no other state is active.
; -------------------------------------------------------------------------

crab_frame_00:					; offset 0x05C -> ptr 0xA05C (first 4 bytes alias into ptr_tbl_b tail: A5 A2 D7 A2)
						; ROLE: walk cycle frame 0/6 (start pose)
						; (referenced by ptr_tbl_a[0]; used in walk_dir0/walk_dir1 phases)
		db	 00h, 00h, 00h, 00h, 01h, 00h   ; row 0
		db	 00h, 00h, 26h, 27h, 00h, 00h   ; row 1
		db	 00h, 00h, 01h, 00h, 00h, 00h   ; row 2
		db	 26h, 27h, 00h, 00h, 00h, 00h   ; row 3
		db	 01h, 00h, 00h, 00h, 26h, 27h   ; row 4
		db	 00h, 00h                       ; row 5
crab_const_2600	dw	2600h           ; shared word constant (used via `mov ax`)
		db	 27h, 00h, 00h, 00h, 26h, 27h   ; row 6
		db	 00h, 00h, 00h, 00h, 00h, 00h   ; row 7

crab_frame_01:					; offset 0x08E -> ptr 0xA08E
						; ROLE: walk cycle frame 1/6 (forward step a)
						; (referenced by ptr_tbl_a[1]; used in walk_dir0/walk_dir1 phases)
		db	 01h, 02h, 0Ah, 0Bh, 00h, 00h   ; row 0
		db	 00h, 02h, 00h, 00h, 00h, 00h   ; row 1
		db	 28h, 29h, 00h, 00h, 00h, 02h   ; row 2
		db	 00h, 00h, 00h, 00h, 28h, 29h   ; row 3
		db	 00h, 00h, 00h, 02h, 00h, 00h   ; row 4
		db	 00h, 00h, 28h, 29h, 00h, 00h   ; row 5
		db	 00h, 28h, 29h, 00h, 00h, 00h   ; row 6
		db	 28h, 29h, 00h                  ; row 7

crab_frame_02:					; offset 0x0BB -> ptr 0xA0BB
						; ROLE: walk cycle frame 2/6 (forward step b)
						; (referenced by ptr_tbl_a[2]; used in walk_dir0/walk_dir1 phases)
		db	 00h, 00h, 00h, 00h, 00h, 03h   ; row 0
		db	 04h, 00h, 05h, 00h, 2Ah, 2Bh   ; row 1
		db	 2Ch, 2Dh, 00h, 03h, 04h, 00h   ; row 2
		db	 47h, 00h, 2Ah, 2Bh, 2Ch, 58h   ; row 3
		db	 00h, 03h, 04h, 00h, 69h, 00h   ; row 4
		db	 2Ah, 2Bh, 2Ch, 72h, 00h, 03h   ; row 5
		db	 04h, 00h, 05h, 00h, 03h, 04h   ; row 6
		db	 00h, 05h, 00h, 8Fh, 90h, 00h   ; row 7
		db	 91h, 00h                       ; row 8

crab_frame_03:					; offset 0x0ED -> ptr 0xA0ED
						; ROLE: walk cycle frame 3/6 (mid stride)
						; (referenced by ptr_tbl_a[3]; used in walk_dir0/walk_dir1 phases)
		db	0ADh,0AEh,0AFh,0B0h, 00h, 06h   ; row 0
		db	 07h, 08h, 09h, 00h, 06h, 2Fh   ; row 1
		db	 30h, 31h, 00h, 06h, 07h, 48h   ; row 2
		db	 49h, 00h, 06h, 2Fh, 59h, 5Ah   ; row 3
		db	 00h, 06h, 07h, 59h, 5Ah, 00h   ; row 4
		db	 06h, 2Fh, 73h, 74h, 00h, 06h   ; row 5
		db	 2Fh, 08h, 09h, 00h, 06h, 2Fh   ; row 6
		db	 08h, 09h, 00h                  ; row 7
crab_const_2692	dw	2692h           ; shared word constant (also used via `call word ptr cs:`)
		db	 93h, 94h, 00h                  ; row 8

crab_frame_04:					; offset 0x11F -> ptr 0xA11F
						; ROLE: walk cycle frame 4/6 (back step a)
						; (referenced by ptr_tbl_a[4]; used in walk_dir0/walk_dir1 phases)
		db	0B1h, 07h,0B2h,0B3h, 00h, 0Ah   ; row 0
		db	 0Bh, 0Ch, 0Dh, 00h, 32h, 33h   ; row 1
		db	 0Ch, 0Dh, 00h, 0Ah, 0Bh, 0Ch   ; row 2
		db	 0Dh, 00h, 32h, 33h, 0Ch, 0Dh   ; row 3
		db	 00h, 0Ah, 0Bh, 0Ch, 0Dh, 00h   ; row 4
		db	 32h, 33h, 0Ch, 0Dh, 00h, 32h   ; row 5
		db	 33h,0C5h,0C6h, 00h, 32h, 33h   ; row 6
		db	 0Ch, 0Dh, 00h                  ; row 7

crab_frame_05:					; offset 0x14C -> ptr 0xA14C
						; ROLE: walk cycle frame 5/6 (back step b; wrap pose for dir1)
						; (referenced by ptr_tbl_a[5]; used in walk_dir0/walk_dir1 phases)
		db	 27h, 28h, 32h, 33h, 00h, 0Eh   ; row 0
		db	 35h, 10h, 11h, 00h, 34h, 35h   ; row 1
		db	 36h, 37h, 00h, 0Eh, 35h, 4Ah   ; row 2
		db	 4Bh, 00h, 34h, 35h, 5Bh, 5Ch   ; row 3
		db	 00h, 0Eh, 35h, 5Bh, 5Ch, 00h   ; row 4
		db	 34h, 35h, 75h, 76h, 00h, 34h   ; row 5
		db	 35h, 84h, 85h, 00h, 34h, 35h   ; row 6
		db	 84h, 85h, 00h, 29h, 95h, 96h   ; row 7
		db	 97h, 00h                       ; row 8

crab_frame_06:					; offset 0x17E -> ptr 0xA17E
						; ROLE: spawn-formation pose / extra walk pose
						; (referenced by ptr_tbl_a[6]; reached via spawn_subloop's
						;  crab_spawn_limit[bx] index and as walk_dir0_advance pre-wrap)
						; (inferred from dispatch -- not 100% confirmed)
		db	 0Eh,0B4h,0B5h,0B6h, 00h, 12h   ; row 0
		db	 13h, 14h, 15h, 00h, 38h, 39h   ; row 1
		db	 3Ah, 00h, 00h, 12h, 13h, 4Ch   ; row 2
		db	 15h, 00h, 38h, 39h, 5Dh, 00h   ; row 3
		db	 00h, 12h, 13h, 5Dh, 15h, 00h   ; row 4
		db	 38h, 39h, 77h, 00h, 00h, 12h   ; row 5
		db	 13h, 14h, 15h, 00h, 12h, 13h   ; row 6
		db	 14h, 15h, 00h, 98h, 99h, 9Ah   ; row 7
		db	 00h, 00h                       ; row 8

crab_frame_07:					; offset 0x1B0 -> ptr 0xA1B0
						; ROLE: hit/stagger pose (one-shot; spawn arrival)
						; (referenced by ptr_tbl_a[7]; only reached via spawn_subloop's
						;  crab_spawn_limit[bx] formation index)
						; (inferred -- could alternatively be an extra walk frame)
		db	0B7h,0B8h,0B9h,0BAh, 00h, 00h   ; row 0
		db	 16h, 00h, 17h, 00h, 00h, 3Bh   ; row 1
		db	 3Ch, 3Dh, 00h, 00h, 4Dh, 00h   ; row 2
		db	 4Eh, 00h, 5Eh, 5Fh, 00h, 60h   ; row 3
		db	 00h, 0Fh, 2Eh, 6Ah, 6Bh, 00h   ; row 4
		db	 78h, 79h, 7Ah, 7Bh, 00h, 86h   ; row 5
		db	 87h, 00h, 88h, 00h, 86h, 87h   ; row 6
		db	 00h, 88h, 00h, 9Bh, 9Ch, 9Dh   ; row 7
		db	 9Eh, 00h                       ; row 8

crab_frame_08:					; offset 0x1E2 -> ptr 0xA1E2
						; ROLE: DEATH pose (corpse / final death sprite)
						; (referenced by ptr_tbl_a[8]; explicitly set by death_frame8
						;  when crab_timer_b >= 0x14 -- held until gvar_completion at 0x28)
		db	0BBh,0BFh,0BCh, 00h, 00h, 23h   ; row 0
		db	 24h, 25h, 00h, 00h, 3Eh, 00h   ; row 1
		db	 3Fh, 00h, 00h, 55h, 00h, 56h   ; row 2
		db	 57h, 00h, 65h, 66h, 67h, 68h   ; row 3
		db	 00h, 6Fh, 70h, 71h, 00h, 00h   ; row 4
		db	 80h, 81h, 82h, 83h, 00h, 8Bh   ; row 5
		db	 8Ch, 8Dh, 8Eh, 00h, 8Bh, 8Ch   ; row 6
		db	 8Dh, 8Eh, 00h,0A9h,0AAh,0ABh   ; row 7
		db	0ACh, 00h                       ; row 8

crab_frame_09:					; offset 0x214 -> ptr 0xA214
						; ROLE: SPAWN/ARM pose (animation-start frame)
						; (referenced by ptr_tbl_b[1]; explicitly set by anim_step_entry
						;  when crab_anim_idx is armed -- first frame after spawn arrives)
		db	 00h,0C1h, 00h,0C2h, 00h, 18h   ; row 0
		db	 19h, 1Ah, 1Bh, 00h, 40h, 19h   ; row 1
		db	 42h, 43h, 00h, 4Fh, 19h, 50h   ; row 2
		db	 51h, 00h, 61h, 19h, 62h, 1Bh   ; row 3
		db	 00h, 6Ch, 19h, 6Dh, 43h, 00h   ; row 4
		db	 7Ch, 19h, 7Dh, 43h, 00h, 18h   ; row 5
		db	 19h, 00h, 1Bh, 00h, 18h, 19h   ; row 6
		db	 00h, 1Bh, 00h, 9Fh,0A0h,0A1h   ; row 7
		db	0A2h, 00h                       ; row 8

crab_frame_10:					; offset 0x246 -> ptr 0xA246
						; ROLE: idle animation frame 1/4 (pincer-snap / breathing loop)
						; (referenced by ptr_tbl_b[2]; selected via crab_anim_tbl_b[idx_e]
						;  when crab_alt_phase is armed -- idle_dispatch path)
		db	0BDh, 19h,0BFh, 43h, 00h, 1Ch   ; row 0
		db	 1Dh, 1Eh, 00h, 00h, 1Ch, 1Dh   ; row 1
		db	 00h, 44h, 00h, 1Ch, 1Dh, 1Eh   ; row 2
		db	 44h, 00h, 1Ch, 1Dh, 1Eh, 00h   ; row 3
		db	 00h, 1Ch, 1Dh, 00h, 00h, 00h   ; row 4
		db	 1Ch, 1Dh, 00h, 44h, 00h, 1Ch   ; row 5
		db	 1Dh, 1Eh, 00h, 00h, 1Ch, 1Dh   ; row 6
		db	 1Eh, 00h, 00h                  ; row 7

crab_frame_11:					; offset 0x273 -> ptr 0xA273
						; ROLE: idle animation frame 2/4 (pincer-snap / breathing loop)
						; (referenced by ptr_tbl_b[3]; selected via crab_anim_tbl_b[idx_e]
						;  when crab_alt_phase is armed -- idle_dispatch path)
		db	 0Ch, 0Dh,0A3h,0A4h, 00h, 1Fh   ; row 0
		db	 20h, 21h, 22h, 00h, 1Fh, 41h   ; row 1
		db	 45h, 46h, 00h, 1Fh, 52h, 53h   ; row 2
		db	 54h, 00h, 1Fh, 63h, 21h, 64h   ; row 3
		db	 00h, 1Fh, 63h, 21h, 6Eh, 00h   ; row 4
		db	 1Fh, 7Eh, 53h, 7Fh, 00h, 1Fh   ; row 5
		db	 89h, 21h, 8Ah, 00h, 1Fh, 89h   ; row 6
		db	 21h, 8Ah, 00h,0A5h,0A6h,0A7h   ; row 7
		db	0A8h, 00h                       ; row 8

crab_frame_12:					; offset 0x2A5 -> ptr 0xA2A5
						; ROLE: idle animation frame 3/4 (pincer-snap / breathing loop)
						; (referenced by ptr_tbl_b[4]; selected via crab_anim_tbl_b[idx_e]
						;  when crab_alt_phase is armed -- idle_dispatch path)
		db	 1Fh,0BEh, 21h,0C0h, 00h,0C7h   ; row 0
		db	0C8h, 1Ch, 1Dh, 00h,0C9h,0CAh   ; row 1
		db	 1Ch, 1Dh, 00h,0CBh,0CCh,0CDh   ; row 2
		db	0CEh, 00h,0CFh,0D0h,0D1h,0D2h   ; row 3
		db	 00h,0D3h,0D4h,0D5h,0D6h, 00h   ; row 4
		db	0C3h,0C4h, 1Ch, 1Dh, 00h,0C5h   ; row 5
		db	0C6h, 1Ch, 1Dh, 00h, 0Ch, 0Dh   ; row 6
		db	 1Ch, 1Dh, 00h, 0Ch, 0Dh, 1Ch   ; row 7
		db	 1Dh, 00h                       ; row 8

crab_frame_13:					; offset 0x2D7 -> ptr 0xA2D7
						; ROLE: idle animation frame 4/4 (pincer-snap / breathing loop)
						; (referenced by ptr_tbl_b[5]; selected via crab_anim_tbl_b[idx_e]
						;  when crab_alt_phase is armed -- idle_dispatch wraps idx_e at 4)
		db	 0Ch, 0Dh, 1Ch, 1Dh, 00h,0D7h   ; row 0
		db	0D8h,0D9h, 00h, 00h,0DAh,0DBh   ; row 1
		db	0DCh,0DDh, 00h,0DEh,0DFh, 00h   ; row 2
		db	 00h, 00h,0E0h,0E1h, 00h, 00h   ; row 3
		db	 00h,0E2h,0E3h, 00h, 00h        ; row 4

; Small trailing tail before the first executable label (used by slot-setup).
;   Bytes: 8Bh 36h 10h 0C0h  C6h 06h DCh A7h 00h  C6h 06h DDh A7h 00h
;   = mov si,ds:[C010h]              ; mov si, fight_slot_list
;     mov byte ptr ds:[A7DCh], 0     ; crab_slot_idx = 0
;     mov byte ptr ds:[A7DDh], 0     ; crab_state_bits = 0
; These may be reused by 200FIGHT as a small setup-code stub; here they
; fall through directly into scan_slot_loop (loc_1) and so function as
; the actual prolog for every scan.

crab_scan_prolog:
		db	 8Bh, 36h, 10h,0C0h		; mov si, fight_slot_list
		db	0C6h, 06h,0DCh,0A7h, 00h	; mov byte ptr crab_slot_idx, 0
		db	0C6h, 06h,0DDh,0A7h, 00h	; mov byte ptr crab_state_bits, 0

; -------------------------------------------------------------------------
;  Main scan-and-update entry (file offset 0x302).
;  Walks the enemy slot list updating each live slot, then either spawns
;  new crabs (low fight_hp) or retires slots (high fight_hp), then
;  dispatches the per-frame phase (loc_27/loc_43/loc_44/loc_24/loc_23).
; -------------------------------------------------------------------------

scan_slot_loop:
;*		cmp	word ptr [si],0FFFFh
				db	 83h, 3Ch,0FFh		; cmp word ptr [si], 0FFFFh
								;  (alt encoding: sign-extended imm8 form;
								;   TASM emits 4-byte form, so keep as db)
				jz	scan_done		; end-of-list sentinel
				mov	ax,[si]
				call	word ptr cs:fight_cb_anim_step
				jc	scan_next_slot		; callback consumed slot -> skip
				mov	[si+3],bl
				mov	ax,[si+2]
				call	word ptr cs:fight_cb_record_ofs
				mov	bl,ds:crab_slot_idx
				xor	bh,bh			; Zero register
				mov	al,ds:sprite_idx_table[bx]
				mov	[di],al
				test	byte ptr [si+5],40h	; '@'  bit6 = active
				jz	scan_next_slot
				test	byte ptr ds:crab_state_bits,80h
				jnz	scan_next_slot
				mov	al,[si+5]
				and	al,1Fh
				test	byte ptr [si+4],10h
				jz	apply_state_bits
				or	al,80h

apply_state_bits:
				mov	ds:crab_state_bits,al

scan_next_slot:
				inc	byte ptr ds:crab_slot_idx
				add	si,10h
				jmp	short scan_slot_loop

scan_done:
		mov	si,ds:fight_slot_list
		mov	word ptr [si],0FFFFh
		test	byte ptr ds:gvar_death_flag,0FFh
		jnz	dispatch_phase		; death flag set -> skip adjust
		mov	al,ds:crab_state_bits
		or	al,al			; Zero ?
		jz	dispatch_phase
		push	ax
		and	al,1Fh
		call	word ptr cs:fight_cb_hit_check
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		pop	ax
		or	al,al			; Zero ?
		jns	hp_target_ready
		add	bx,bx

hp_target_ready:
		call	prep_phase
		mov	byte ptr ds:gvar_spawn_fx_flag,22h	; '"'
		mov	ax,crab_const_2600
		add	ax,0Ch
		mov	bx,ds:fight_state_max
		cmp	ax,bx
		jb	hp_target_clamped
		mov	ax,bx

hp_target_clamped:
		xchg	bx,ax
		mov	ax,ds:fight_hp
		add	ax,5
		cmp	ax,bx
		jae	hp_inc_two
		call	hp_dec
		call	hp_dec
		jmp	short dispatch_phase

hp_inc_two:
		call	hp_inc
		call	hp_inc

; -------------------------------------------------------------------------
;  Per-frame phase dispatch chain (loc_8..loc_12).
;  Tests several flags in priority order:
;    crab_anim_idx  set -> anim_step     (loc_27)
;    crab_alt_phase set -> idle_dispatch (loc_43)
;    gvar_death_flag   -> death_anim     (loc_44)
;    crab_flag_g       -> spawn_subloop  (loc_24)
;    else -> call cs:crab_const_2692 (RNG/timer) and walk / swap-dir.
; -------------------------------------------------------------------------

dispatch_phase:
		test	byte ptr ds:crab_anim_idx,0FFh
		jz	disp_try_alt
		jmp	anim_step_entry
disp_try_alt:
		test	byte ptr ds:crab_alt_phase,0FFh
		jz	disp_try_death
		jmp	idle_dispatch
disp_try_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	disp_try_spawn
		jmp	death_anim
disp_try_spawn:
		test	byte ptr ds:crab_flag_g,0FFh
		jz	disp_walk
		jmp	spawn_subloop
disp_walk:
		call	word ptr cs:crab_const_2692	; call RNG/timer fn
		and	al,7
		jnz	walk_active
		jmp	walk_reset
walk_active:
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	walk_dir1
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	walk_dir0_step
		jmp	emit_sprite_rows
walk_dir0_step:
		call	hp_dec
		jnc	walk_dir0_advance
		mov	byte ptr ds:crab_dir_flag,0FFh

walk_dir0_advance:
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jae	walk_dir0_wrap
		jmp	emit_sprite_rows

walk_dir0_wrap:
		mov	byte ptr ds:crab_frame_idx,0
		jmp	emit_sprite_rows

walk_dir1:
		inc	byte ptr ds:crab_sub_phase
		test	byte ptr ds:crab_sub_phase,1
		jz	walk_dir1_step
		jmp	emit_sprite_rows

walk_dir1_step:
		call	hp_inc
		jnc	walk_dir1_advance
		mov	byte ptr ds:crab_dir_flag,0

walk_dir1_advance:
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		je	walk_dir1_wrap
		jmp	emit_sprite_rows

walk_dir1_wrap:
		mov	byte ptr ds:crab_frame_idx,5
		jmp	emit_sprite_rows

crab_main	endp

; -------------------------------------------------------------------------
;  hp_dec -- decrement fight_hp by 1, floor at 0x10.  Sets CF if clamped.
;  (was sub_1)
; -------------------------------------------------------------------------

hp_dec		proc	near
		cmp	byte ptr ds:fight_hp,10h
		stc				; Set carry flag
		jnz	hp_dec_do
		retn

hp_dec_do:
		dec	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn

hp_dec		endp

; -------------------------------------------------------------------------
;  hp_inc -- increment fight_hp by 1, ceiling 0x31.  Sets CF if clamped.
;  (was sub_2)
; -------------------------------------------------------------------------

hp_inc		proc	near
		cmp	byte ptr ds:fight_hp,31h	; '1'
		stc				; Set carry flag
		jnz	hp_inc_do
		retn

hp_inc_do:
		inc	byte ptr ds:fight_hp
		clc				; Clear carry flag
		retn

hp_inc		endp

; -------------------------------------------------------------------------
;  walk_reset (loc_23) -- clear flag_h, set flag_g to drive spawn_subloop.
; -------------------------------------------------------------------------

walk_reset:
		mov	byte ptr ds:crab_flag_h,0
		mov	byte ptr ds:crab_flag_g,0FFh

spawn_subloop:
		inc	byte ptr ds:crab_flag_h
		cmp	byte ptr ds:crab_flag_h,8
;*		je	spawn_phase_reset	; target = loc_25 (Sourcer dropped label, code below)
		db	 74h, 18h		; je +0x18 -> spawn_phase_reset @ 0x48D
						;  (Sourcer dropped the label; byte-form jump)
		mov	bl,ds:crab_flag_h
		xor	bh,bh			; Zero register
		mov	al,ds:crab_spawn_limit[bx]
		mov	ds:crab_frame_idx,al
		jmp	emit_sprite_rows

; -------------------------------------------------------------------------
;  Small sprite-count / slot-stride lookup table (8 bytes, file 0x485..0x48C).
;  Sits between spawn_subloop's `jmp emit_sprite_rows` and the
;  spawn_phase_reset entry.  Indexed by something in 200FIGHT (exact
;  consumer unknown from static analysis; bytes 07,07,08,08,08,08,08,06
;  are crab-row widths for 8 spawn formations).
; -------------------------------------------------------------------------

crab_row_widths:				; was ';* No entry point' #1
		db	 07h, 07h, 08h, 08h	; 4 bytes
		db	 08h, 08h, 08h, 06h	; 4 bytes

; -------------------------------------------------------------------------
;  spawn_phase_reset -- target of `je` in spawn_subloop when flag_h
;  reaches 8.  Re-reads crab_const_2600, clamps against fight_state_max,
;  derives dir_flag from the signed diff, resets flag_g / anim_frame,
;  and arms crab_anim_idx = 0xFF (triggers anim_step_entry next frame).
; -------------------------------------------------------------------------

spawn_phase_reset:				; was loc_25 (label restored from byte-form je fixup)
		mov	ax,crab_const_2600
		add	ax,0Ch
		mov	bx,ds:fight_state_max
		mov	cx,ax
		sub	cx,bx
		xchg	bx,ax
		jc	reset_dir_ready
		xchg	bx,cx

reset_dir_ready:
		mov	ax,ds:fight_hp
		add	ax,5
		sub	ax,bx
		sbb	dl,dl
		mov	ds:crab_dir_flag,dl
		mov	byte ptr ds:crab_flag_g,0
		mov	byte ptr ds:crab_anim_frame,0
		mov	byte ptr ds:crab_anim_idx,0FFh

anim_step_entry:
		mov	byte ptr ds:crab_frame_idx,9
		mov	bl,ds:crab_anim_frame
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_c[bx]
		cmp	al,0FFh
		jne	anim_step_do
;*		jmp	anim_step_end		; target = loc_42 (dead-code / data region)
		db	0E9h,0F1h, 00h		; jmp +0xF1 -> 0x5C4 (lands inside crab_alt_phase_arm
						;  between emit_sprite_rows tail and idle_dispatch)

anim_step_do:
		mov	ah,al
		and	al,0Fh
		cmp	al,8
		je	anim_step_no_phase
		shr	al,1			; Shift w/zeros fill
		sbb	al,0
		add	al,ds:crab_phase_base
		and	al,3Fh			; '?'
		mov	ds:crab_phase_base,al

anim_step_no_phase:
		mov	al,ah
		and	al,0F0h
		jz	anim_step_emit
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	anim_step_inc
		call	hp_dec
		jmp	short anim_step_emit

anim_step_inc:
		call	hp_inc

anim_step_emit:
		call	emit_sprite_rows_proc
		inc	byte ptr ds:crab_anim_frame
		retn

emit_from_grid:
		test	byte ptr ds:crab_row_pos,0FFh
		jnz	emit_cell
		test	byte ptr ds:crab_anim_idx,0FFh
		jnz	emit_find_slot
		retn

emit_find_slot:
		mov	di,ds:fight_slot_list

emit_find_slot_loop:
				cmp	byte ptr [di+4],14h
				je	emit_slot_found
				add	di,10h
				jmp	short emit_find_slot_loop

emit_slot_found:
		mov	al,ds:crab_anim_frame
		mov	[di+6],al
		cmp	byte ptr ds:crab_anim_frame,4
		je	emit_grid_init
		retn

emit_grid_init:
		mov	byte ptr ds:crab_col_pos,0
		mov	byte ptr ds:crab_row_pos,0FFh
		mov	ax,ds:fight_hp
		add	ax,4
		mov	ds:crab_anim_base,ax
		mov	al,ds:crab_phase_base
		add	al,3
		and	al,3Fh			; '?'
		mov	ds:crab_timer_a,al

emit_cell:
		mov	bl,ds:crab_col_pos
		xor	bh,bh			; Zero register
		inc	byte ptr ds:crab_col_pos
		mov	al,ds:crab_anim_tbl_a[bx]
		cmp	al,0FFh
		jne	emit_cell_nonend
		mov	byte ptr ds:crab_row_pos,0
		retn

emit_cell_nonend:
		or	al,al			; Zero ?
		jns	emit_cell_step
		inc	byte ptr ds:crab_timer_a
		and	byte ptr ds:crab_timer_a,3Fh	; '?'

emit_cell_step:
		push	ax
		mov	ax,ds:crab_anim_base
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		pop	cx
		jnc	emit_cell_write
		retn

emit_cell_write:
		mov	[si],ax
		mov	dl,ds:crab_timer_a
		mov	[si+2],dl
		mov	[si+3],bl
		mov	byte ptr [si+4],35h	; '5'
		and	cl,7Fh
		mov	[si+6],cl
		mov	byte ptr [si+5],0
		mov	word ptr [si+10h],0FFFFh
		mov	ax,[si+2]
		call	word ptr cs:fight_cb_record_ofs
		mov	bl,ds:crab_slot_idx
		mov	al,bl
		or	al,80h
		xchg	[di],al
		xor	bh,bh			; Zero register
		mov	ds:sprite_idx_table[bx],al
		retn

; -------------------------------------------------------------------------
;  crab_alt_phase_arm (file 0x5BA..0x5D6) -- entered via the absolute jmp
;  E9 F1 00 from anim_step_do at 0x4D0 (target 0x5C4, lands AFTER the
;  leading 13-byte constants table).  The leading bytes are small data
;  constants consumed by 200FIGHT through a DS-resident dispatch slot
;  (Sourcer's `loopnz $-87` mnemonic is a misdecode of the byte-form
;  alt-encoding E0 A7); the trailing instructions (mov crab_anim_idx,0
;  / mov crab_idx_e,0 / mov crab_alt_phase,0FFh) are the live entry
;  point that arms the alt-phase before falling into idle_dispatch.
; -------------------------------------------------------------------------

crab_alt_phase_consts:				; was crab_orphan_data_a (DS-dispatch consts)
		db	 80h, 80h, 80h, 80h, 80h	; 5 bytes (200FIGHT DS-dispatch)
		db	 81h, 82h, 03h, 04h		; 4 bytes (200FIGHT DS-dispatch)
		db	 0FFh				; jmp target 0x5C4 lands inside next loopne
		db	 0F6h				; 1 byte
		db	 16h				; push ss (in aligned decode)
;*		loopnz	$-87			; target = mid-instruction (alt-encoding fixup)
		db	0E0h,0A7h		; loopne -89  (alt-encoding; stays as Fixup)

crab_alt_phase_arm:				; live entry: jmp from anim_step_do lands here
		mov	byte ptr ds:crab_anim_idx,0
		mov	byte ptr ds:crab_idx_e,0
		mov	byte ptr ds:crab_alt_phase,0FFh	; arm alt-phase -> idle_dispatch

idle_dispatch:
		mov	bl,ds:crab_idx_e
		xor	bh,bh			; Zero register
		mov	al,ds:crab_anim_tbl_b[bx]
		mov	ds:crab_frame_idx,al
		inc	byte ptr ds:crab_idx_e
		cmp	byte ptr ds:crab_idx_e,4
		je	$+5			; skip the next `jmp` -> falls into idle_done_clear
		jmp	emit_sprite_rows
; idle_done_clear: reached by the `je $+5` above when crab_idx_e == 4.
; Clears alt-phase and jumps into the sprite-emit stage.

idle_done_clear:				; was ';* No entry point' #3 (reached via je $+5)
		mov	byte ptr ds:crab_alt_phase,0
		jmp	short emit_sprite_rows

; -------------------------------------------------------------------------
;  Orphan data block before death_anim.  14 bytes, mixture of small
;  values; Sourcer decodes as `pop es / or [bx+si],cl / add cl,dh (alt) /
;  db F1..F1 F8..F8 F2..F2 FF`.  Likely a timing/flicker lookup table
;  consumed indirectly by death_anim's state machine (exact consumer
;  not visible to static analysis).
; -------------------------------------------------------------------------

crab_death_aux_tbl:				; was ';* No entry point' #4
		db	 07h				; 1 byte
		db	 08h, 08h			; 2 bytes
;*		add	cl,dh			; alt encoding (00 F1) -- TASM emits 02 CE
		db	 00h,0F1h			; keep as db to preserve exact byte form
		db	0F1h,0F1h,0F1h,0F1h,0F8h,0F8h	; flicker pattern (F1 x4, F8 x2)
		db	0F8h,0F2h,0F2h,0F2h,0F2h,0F2h	; flicker pattern (F8, F2 x5)
		db	0FFh				; sentinel terminator

; -------------------------------------------------------------------------
;  death_anim (loc_44) -- runs when gvar_death_flag is set.  crab_timer_b
;  counts up to 0x28; at 0x1E it sets gvar_spawn_fx_flag=0x23, at 0x14 it
;  switches to frame 8, and at 0x28 it sets gvar_completion.
; -------------------------------------------------------------------------

death_anim:
		mov	al,ds:crab_timer_b
		cmp	al,28h			; '('
		jae	death_complete
		cmp	al,1Eh
		jae	death_walk
		and	al,1
		jnz	death_walk
		mov	byte ptr ds:gvar_spawn_fx_flag,23h	; '#'

death_walk:
		mov	byte ptr ds:gvar_dir_toggle,0FFh
		cmp	byte ptr ds:crab_timer_b,14h
		jae	death_frame8
		inc	byte ptr ds:crab_timer_b
		test	byte ptr ds:crab_dir_flag,0FFh
		jnz	death_step_down
		inc	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,6
		jb	emit_sprite_rows
		mov	byte ptr ds:crab_frame_idx,5
		mov	byte ptr ds:crab_dir_flag,0FFh
		jmp	short emit_sprite_rows

death_step_down:
		dec	byte ptr ds:crab_frame_idx
		cmp	byte ptr ds:crab_frame_idx,0FFh
		jb	emit_sprite_rows
		mov	byte ptr ds:crab_frame_idx,0
		mov	byte ptr ds:crab_dir_flag,0
		jmp	short emit_sprite_rows

death_frame8:
		inc	byte ptr ds:crab_timer_b
		mov	byte ptr ds:crab_frame_idx,8
		jmp	short emit_sprite_rows

death_complete:
		mov	byte ptr ds:gvar_completion,0FFh
		retn

; -------------------------------------------------------------------------
;  emit_sprite_rows (sub_3) -- the main sprite-emission routine.  Uses
;  crab_frame_idx to index into crab_pos_tbl, then walks a 6*10 grid
;  calling fight_cb_anim_step for each cell; successful cells are
;  written into the fight_slot_list and registered in sprite_idx_table.
;  Entry label emit_sprite_rows == loc_49 is the common jump target for
;  nearly every phase path above.  After emit_sprite_rows finishes
;  iterating, it tail-jumps to emit_from_grid (loc_32) to handle grid
;  overflow / respawn.
; -------------------------------------------------------------------------

emit_sprite_rows_proc	proc	near

emit_sprite_rows:
		mov	bl,ds:crab_frame_idx
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	di,ds:crab_pos_tbl[bx]
		mov	al,ds:crab_phase_base
		mov	ds:crab_flag_d,al
		mov	si,ds:fight_slot_list
		xor	al,al			; Zero register
		mov	ds:crab_slot_idx,al

emit_row_outer:
				push	di
				push	ax
				mov	bl,0Ah
				mul	bl			; ax = reg * al
				add	di,ax
				mov	ax,ds:fight_hp
				mov	cx,0Ah

emit_row_loop:
						push	cx
						mov	[si],ax
						push	di
						push	ax
						call	word ptr cs:fight_cb_anim_step
						jc	emit_row_next
						mov	al,[di]
						cmp	al,0FFh
						je	emit_row_next
						mov	[si+4],al
						mov	al,ds:crab_flag_d
						mov	[si+2],al
						mov	[si+3],bl
						mov	byte ptr [si+5],0
						test	byte ptr ds:crab_state_bits,0FFh
						jz	emit_row_no_bit
						or	byte ptr [si+5],20h	; ' '

emit_row_no_bit:
						mov	al,ds:crab_frame_idx
						mov	[si+6],al
						mov	ax,[si+2]
						call	word ptr cs:fight_cb_record_ofs
						mov	al,ds:crab_slot_idx
						mov	bl,al
						or	al,80h
						xchg	[di],al
						xor	bh,bh			; Zero register
						mov	ds:sprite_idx_table[bx],al
						inc	byte ptr ds:crab_slot_idx
						add	si,10h

emit_row_next:
						pop	ax
						inc	ax
						pop	di
						inc	di
						pop	cx
						loop	emit_row_loop

				inc	byte ptr ds:crab_flag_d
				and	byte ptr ds:crab_flag_d,3Fh	; '?'
				pop	ax
				pop	di
				inc	al
				cmp	al,6
				jne	emit_row_outer
		mov	word ptr [si],0FFFFh
		jmp	emit_from_grid

emit_sprite_rows_proc	endp

; -------------------------------------------------------------------------
;  Post-emit scratch tables (file 0x70E..0x79A, 140 bytes).
;  Two subsections:
;    [0x70E..0x71F]: 9 copies of word 0xA71E (= crab_anim_tbl_b base + 1,
;                    indirect self-pointer), then word 0xA75A.
;    [0x720..0x791]: four 0xFF-padded sparse sub-tables (sizes 14, 11,
;                    15, and 12 0xFF bytes plus interspersed small indices
;                    02..14, 03..14, 06, 90, etc.).  These are lookup
;                    tables indexed from 301EAI1/302EAI2 via DS-resident
;                    dispatch slots; static analysis cannot trace the
;                    exact consumer but the 0xFF padding is the standard
;                    crab-lookup "no entry" sentinel.
; -------------------------------------------------------------------------

crab_tail_ptrs:					; offset 0x70E -- 9 x word 0xA71E + word 0xA75A
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h	; ptrs[0..2] -> 0xA71E
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h	; ptrs[3..5] -> 0xA71E
		db	 1Eh,0A7h, 1Eh,0A7h, 1Eh,0A7h	; ptrs[6..8] -> 0xA71E
		db	 5Ah,0A7h,0FFh,0FFh,0FFh, 00h	; ptr[9] -> 0xA75A; FFh sentinels + pad

crab_lookup_a:					; offset 0x726 -- sparse index table, 0xFF sentinels
		db	0FFh, 01h			; entry 0=FF, 1=01
		db	14 dup (0FFh)			; entries 2..15 = FF
		db	 02h,0FFh, 03h,0FFh, 04h,0FFh	; entries 16,18,20 = 02,03,04
		db	 05h,0FFh, 06h			; entries 22=05, 24=06
		db	11 dup (0FFh)			; entries 25..35 = FF
		db	 07h,0FFh, 10h,0FFh, 11h,0FFh	; entries 36,38,40 = 07,10,11
		db	 12h,0FFh			; entry 42 = 12
		db	8				; entry 44 = 08
		db	15 dup (0FFh)			; entries 45..59 = FF

crab_lookup_b:					; offset 0x762 -- second sparse index table
		db	 00h,0FFh,0FFh,0FFh,0FFh,0FFh	; entry 0 = 00, then FF padding
		db	0FFh,0FFh, 03h,0FFh,0FFh,0FFh	; entry 8 = 03
		db	 05h,0FFh,0FFh,0FFh, 02h,0FFh	; entry 12 = 05, entry 16 = 02
		db	0FFh,0FFh, 14h,0FFh,0FFh,0FFh	; entry 20 = 14
		db	 06h,0FFh,0FFh,0FFh, 90h,0FFh	; entry 24 = 06, entry 28 = 90
		db	0FFh,0FFh, 12h,0FFh,0FFh,0FFh	; entry 32 = 12
		db	0FFh, 07h,0FFh,0FFh,0FFh,0FFh	; entry 37 = 07
		db	0FFh				; entry 42 = FF
		db	8				; entry 43 = 08
		db	12 dup (0FFh)			; entries 44..55 = FF

; -------------------------------------------------------------------------
;  prep_phase (sub_4) -- called from scan_done when the state bits need
;  refreshing.  Clamps crab_phase_limit (at 0xA7C6), invokes fight_cb_prep
;  to validate, and sets gvar_death_flag on first non-ok result.
; -------------------------------------------------------------------------

prep_phase	proc	near
		mov	ax,ds:crab_phase_limit
		sub	ax,bx
		jnc	prep_store
		xor	ax,ax			; Zero register

prep_store:
		mov	ds:crab_phase_limit,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:fight_cb_prep
		pop	ax
		or	ax,ax			; Zero ?
		jz	prep_check_death
		retn

prep_check_death:
		test	byte ptr ds:gvar_death_flag,0FFh
		jz	prep_arm_death
		retn

prep_arm_death:
		mov	byte ptr ds:crab_timer_b,0
		mov	byte ptr ds:gvar_death_flag,0FFh
		retn

prep_phase	endp

; -------------------------------------------------------------------------
;  Tail data:
;    [0x7C7..0x7D6]: 16 bytes of small integers (2B 00 0C 96 00 78 00 0C
;                    00 D0 A7 96 00 10 BB 00) -- likely crab spawn timing
;                    / position constants indexed by 200FIGHT at boot.
;                    The pair 0xA7D0 = addr of crab_anim_base-0x1A, and
;                    the surrounding small values (96h, 78h, 10h, BBh)
;                    match the sprite-row-width / animation-tick literals
;                    seen in sibling EAI modules.
;    [0x7D7..0x7DF]: 8-char name tag 'Cangrejo' with length-prefix byte 8.
;    [0x7E0..0x7F1]: 18 trailing zeros (padding to final file size 2034).
; -------------------------------------------------------------------------

crab_tail_const:				; 0x7C7 -- 16 timing/position constants
		db	 2Bh, 00h, 0Ch, 96h, 00h, 78h	; spawn-tick + position constants [0..5]
		db	 00h, 0Ch, 00h,0D0h,0A7h, 96h	; constants [6..11] (0xA7D0 = anim_base-0x1A)
		db	 00h, 10h,0BBh, 00h		; constants [12..15] (10h, BBh literals)

crab_name_tag:					; 0x7D7 -- 'Cangrejo' pascal string
		db	8, 'Cangrejo'
		db	18 dup (0)		; pad to end-of-file

seg_a		ends

		end	start