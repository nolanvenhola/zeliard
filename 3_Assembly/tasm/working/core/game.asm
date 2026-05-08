
PAGE  59,132

;==========================================================================
;
;  GAME.BIN - Main Game Initialization & Resource Loader
;
;  Loaded by zeliad.exe into memory, then called to start the game.
;  Loads SAR archive chunks, initializes graphics/sound drivers,
;  sets up palettes, and jumps to the main gameplay loop.
;
;  Code type: zero start (loaded at base of segment, runs from offset 0)
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;  Connections:
;    Loads:        zelres1 ch1 (opdemo.bin), ch7 (town.bin), ch13 (font.grp),
;                  zelres2 ch1 (fight.bin), ch2 (select.bin), ch8 (mole.bin),
;                  ch1B (sword.grp), ch1C (itemp.grp), ch1D (magic.grp);
;                  graphics/tile/font drivers per gfx_mode (gd*/gt*/gf* tables)
;    Calls into:   sar_loader_fn (CS:0x010C in stick.bin),
;                  loaded_code_a (CS:0x3000, gfx-driver init),
;                  loaded_code_b (CS:0x6000, fight.bin/town.bin entry),
;                  gfx_call_a/b/c (CS:0x201C/201E/2020 in gd*/gt*/gf* drivers),
;                  sound_load_track_fn (CS:0x203E in music driver),
;                  music_player_fn (CS:0x18AB)
;    Called by:    zeliad.exe (entry point at game_seg:0xA000 via game_entry_ofs)
;    Reads/writes: gvar_* family at FF08-FF77 (timer, music, palette, joystick,
;                  volume, debug) shared with zeliad.exe + drivers
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
; Player-record fields (DS-relative; canonical home is stdply.inc).
; 0xA0 was misnamed music_track_count.  Per cross-save data it tracks
; the count of spells the player has learned (== popcount(spell_known_*)).
; game.asm's load_music_tracks proc happens to use this same byte as a
; loop count, but the underlying semantic is spell-learn count (one
; spell learned per town transition, which is also when a music track
; might be added).
spells_learned_count equ 0A0h			; count of spells learned (canonical in stdply.inc)
music_track_count equ	0A0h			; alias — earlier name (kept; load_music_tracks reads via this)
stick_joy_poll_handler equ	120h			; stick.bin slot 120h dispatch (poll_joystick_buttons; canonical zr1com.inc/zr2com.inc)
sword	equ	92h			; equipped weapon idx (canonical in stdply.inc)
shield	equ	93h			; shield tier (canonical in stdply.inc)
; 0x9D = currently selected spell ID (user-corrected).
selected_spell	equ	9Dh			; currently chosen spell ID (canonical in stdply.inc)
weapon_tier_max	equ	9Dh			; alias — earlier (wrong) name
cur_weapon_idx	equ	9Dh			; alias — earlier (wrong) name
current_area_id	equ	0C4h			; current area (high bit=in-town, low 7=town/sage idx); Kioku Feather destination
player_level	equ	0C4h			; alias — earlier name (was misnomer; not character level)
player_tileset	equ	0C8h			; level tileset index (canonical in stdply.inc)
gvar_pose_idx	equ	0E7h			; player pose state (canonical in stdply.inc)
; Game state variables (0xFF00+ range, shared with zeliad.exe).
; Names below are synced to zeliard.inc canonical where one exists; game.asm
; doesn't include zeliard.inc directly (carries its own EQUs).
gvar_timer_ticks equ	0FF08h			; Timer tick counter
gvar_gfx_mode	equ	0FF14h			; Graphics/display mode (canonical zeliard.inc)
gvar_enemy_cnt	equ	0FF36h			; Active enemy count (canonical zr3com.inc).
						; game.asm only zero-inits this; was misnamed gvar_music_vol.
; FF38/FF39/FF3A: misnamed gvar_music_flag_a/b/c in earlier sweeps.  All 5
; gf*.asm graphics drivers gate sprite rendering on these bytes
; (flag_shield/flag_climbing/flag_riding) — they are PLAYER POSE STATE
; flags, not music state.  game.asm only zero-clears them at boot.
flag_shield	equ	0FF38h			; shield-up render flag (5 gf*.asm)
gvar_music_flag_a equ	0FF38h			; alias — earlier name
flag_climbing	equ	0FF39h			; climbing-pose render flag (5 gf*.asm)
gvar_music_flag_b equ	0FF39h			; alias — earlier name
flag_riding	equ	0FF3Ah			; riding-pose render flag (5 gf*.asm)
gvar_music_flag_c equ	0FF3Ah			; alias — earlier name
gvar_palette_flag	equ	0FF3Ch			; Palette state (canonical zeliard.inc)
equip_byte	equ	0FF3Dh			; Equipment byte (canonical zr2com.inc, 5-file consensus).
						; game.asm only zero-inits; was misnamed gvar_palette_a.
gvar_palette_b	equ	0FF3Eh			; alias — see 200FIGHT.asm spell_fx_active (game.asm only zero-clears it)
; FF40: misnamed gvar_debug_mode in zeliard.inc; all 5 gf*.asm drivers test
; it as flag_hero_state to gate which sprite-mode to render.  game.asm only
; zero-clears it at boot.
flag_hero_state	equ	0FF40h			; player-state render gate (5 gf*.asm)
gvar_debug_mode	equ	0FF40h			; alias — earlier name (NOT debug)
gvar_debug_val	equ	0FF42h			; Debug value (canonical zeliard.inc)
; FF43: misnamed gvar_joystick_flag in earlier sweeps.  All 5 gf*.asm
; drivers test it as scroll_active; 200FIGHT also uses it as a scroll/
; transition gate.  game.asm only zero-clears at boot.
scroll_active	equ	0FF43h			; scroll/transition active gate (5 gf*.asm)
gvar_joystick_flag equ	0FF43h			; alias — earlier name
; FF44h is the bg_restore pending flag (set by gf*.asm bg_save/bg_restore
; procs across 202GFEGA, 203GFCGA, 204GFHGC, 205GFTGA, 206GFMCA — 21
; read/write sites).  game.asm only zero-clears it during init.
restore_pending	equ	0FF44h			; bg_restore pending flag (gf*.asm)
gvar_item_result	equ	0FF4Bh			; Selected item / level-completion counter (canonical 201SELCT).
						; game.asm only zero-inits; was misnamed gvar_joy_count.
gvar_input_lock	equ	0FF74h			; Input-mode lock (canonical zeliard.inc).
						; game.asm only zero-inits; was misnamed gvar_volume_a.
gvar_cinematic_active	equ	0FF77h			; Cinematic/intro-mode flag (set 0xFF at start_new_game
						; before opdemo loads; cleared in start_load_game's gvar zero-pass).
						; Tested by gfx drivers to gate rendering paths (full-color cinematic
						; vs gameplay-mode rendering).  Was misnamed gvar_volume_b — that name
						; refers to a SEPARATE byte at FF75 (audio cue) used by the rest of
						; the project; this byte at FF77 has nothing to do with volume.

; ----------------------------------------------------------------------
; Section 4: Shared dispatch slot references (file-local)
; ----------------------------------------------------------------------
loaded_code_b_fn equ	6002h			; Loaded chunk function B

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; SAR chunk loader entry point (installed at runtime by font.grp init code)
sar_loader_fn	equ	010Ch			; call word ptr cs:sar_loader_fn
music_player_fn	equ	18ABh			; Music player function
gfx_call_a	equ	201Ch			; Graphics driver call A
gfx_call_b	equ	201Eh			; Graphics driver call B
gfx_call_c	equ	2020h			; Graphics driver call C
sound_load_track_fn equ	203Eh			; Sound driver: load/init music track
loaded_code_a	equ	3000h			; Loaded chunk code entry A
tile_gfx_base	equ	37A4h			; Tile graphics base address
font_gfx_base	equ	3EA4h			; Font graphics base address
loaded_code_b	equ	6000h			; Loaded chunk code entry B
font_grp_dest	equ	0F500h			; FONT.GRP chunk load destination (CS:F500h)

; Chunk reference table — see "Chunk Reference Table" comment block below.
; Each record is `[archive][chunk]['filename.ext'\0]`.  game.bin's chunk
; loader receives `mov si, <pointer-into-this-table>` and reads only the
; first 2 bytes (archive_index, chunk_index_1based).  The named offsets
; below correspond to specific runtime indexing arithmetic in this file.
chunk_ref_tbl_base	equ	0A21Dh		; base of chunk-ref records (cs:0A21Dh)
level_tileset_ref_tbl	equ	0A363h		; chunk_ref_tbl_base + 326
						; indexed by [current_level_idx]*11 (game.asm:413)
level_map_ref_tbl	equ	0A38Fh		; chunk_ref_tbl_base + 370
						; indexed by [current_level_idx]*11 (game.asm:424)
; zeliad loads game.bin at this offset in the game segment.
; Using GAME_CODE_BASE + (offset label) makes these auto-update
; when code is added or removed above each label.
GAME_CODE_BASE  equ     0A000h
gfx_mode_tbl_ega equ	GAME_CODE_BASE + (offset gfx_mode_tbl_ega_lbl)
gfx_mode_tbl_cga equ	GAME_CODE_BASE + (offset gfx_mode_tbl_cga_lbl)
gfx_mode_tbl_all equ	GAME_CODE_BASE + (offset gfx_mode_tbl_all_lbl)
music_track_ref_tbl equ	GAME_CODE_BASE + (offset music_track_ref_tbl_lbl)
palette_handler_jmp_tbl	equ	GAME_CODE_BASE + (offset palette_handler_jmp_tbl_lbl)
palette_base_tbl equ	GAME_CODE_BASE + (offset palette_base_tbl_lbl)
game_init_fn	equ	GAME_CODE_BASE + (offset game_init_fn_lbl)
; Chunk reference addresses (GAME_CODE_BASE + offset of [archive][chunk] record)
chunk_ref_font_grp equ	GAME_CODE_BASE + (offset ref_font_grp)
chunk_ref_mole	equ	GAME_CODE_BASE + (offset ref_mole)
chunk_ref_itemp	equ	GAME_CODE_BASE + (offset ref_itemp)
chunk_ref_select equ	GAME_CODE_BASE + (offset ref_select)
chunk_ref_magic	equ	GAME_CODE_BASE + (offset ref_magic)
chunk_ref_sword	equ	GAME_CODE_BASE + (offset ref_sword)
chunk_ref_fight	equ	GAME_CODE_BASE + (offset ref_fight)
chunk_ref_town	equ	GAME_CODE_BASE + (offset ref_town)
chunk_ref_opdemo equ	GAME_CODE_BASE + (offset ref_opdemo)
save_data_base	equ	0C000h			; Save data load address

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
save_mode_flag	equ	GAME_CODE_BASE + (offset save_mode_flag_lbl)

; Load a chunk from a SAR archive into ES:DI
; Usage: LOAD_CHUNK chunk_ref, dest_offset, archive_index
LOAD_CHUNK	MACRO	chunk_ref, dest_offset, archive
		mov	si, chunk_ref
		mov	di, dest_offset
		mov	al, archive
		call	word ptr cs:sar_loader_fn
		ENDM
; Set ES to CS + a segment paragraph offset (e.g. 1000h, 2000h, 3000h)
; Usage: SET_ES_SEG 2000h
SET_ES_SEG	MACRO	seg_offset
		mov	ax, cs
		add	ax, seg_offset
		mov	es, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

;==========================================================================
;
;  Game Entry Point
;
;  Called from zeliad.exe with AX = mode flag:
;    AX = 0      New game     (no cmdline arg)
;    AX = 0xFFFF Load saved   (cmdline arg = savefile name; zeliad.exe
;                              already loaded the .USR over stdply.bin
;                              at game_seg:0 before jumping here)
;
;  Initialization flow:
;    1. Load font.grp + chunk-loader fixup
;    2. Clear all game state variables
;    3. Load graphics driver for current video mode
;    4. Branch on save_mode_flag:
;       - NEW GAME (0)      -> load opdemo.bin (zelres1 ch1) at CS:6000;
;                              opdemo plays opening cinematic + title +
;                              story, then transitions to gameplay
;       - LOAD SAVED (0xFFFF) -> skip cinematic; load town/fight/select/
;                                items/magic/sword/mole chunks directly;
;                                jump to town.bin's main loop
;    5. (NEW GAME branch happens INSIDE opdemo.bin after the cinematic.)
;    6. (LOAD branch loads gameplay chunks here in game.bin.)
;
;==========================================================================

game		proc	far

start:
		mov	cs:save_mode_flag,ax	; Save new/load flag
		mov	ax,cs
		mov	ds,ax
		push	cs
		pop	es

		; Load font graphics (zelres1 ch13) ?-- compressed, to CS:F500h
		mov	di,font_grp_dest
		mov	si,chunk_ref_font_grp
		mov	al,2			; AL=2: compressed load
		call	word ptr cs:sar_loader_fn

		; Fix up loaded code's jump table (relocate pointers)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di

		; Call into stick.bin's slot at cs:[120h] (poll_joystick_buttons via stick_joy_poll_handler).
		; The semantic at this point in game.bin init is unclear — comment in
		; original disassembly said "Call loaded chunk initialization" but the
		; actual call target (per stick.bin driver_init_data) is poll_joystick_buttons.
		call	word ptr cs:stick_joy_poll_handler

		; Clear all game state variables
		xor	al,al
		mov	ds:flag_climbing,al
		mov	ds:flag_riding,al
		mov	ds:scroll_active,al
		mov	ds:restore_pending,al
		mov	ds:gvar_palette_flag,al
		mov	ds:equip_byte,al
		mov	ds:flag_shield,al
		mov	ds:gvar_enemy_cnt,al
		mov	ds:gvar_palette_b,al
		mov	ds:gvar_item_result,al
		mov	ds:gvar_timer_ticks,al
		mov	byte ptr ds:gvar_pose_idx,al	; clear gvar_pose_idx (player pose state)
		mov	ds:gvar_input_lock,al
		mov	ds:gvar_cinematic_active,al
		mov	ds:flag_hero_state,al
		mov	ds:gvar_debug_val,al

		; Load graphics driver chunk for current video mode
		mov	ax,cs
		mov	es,ax
		xor	bx,bx
		mov	bl,ds:gvar_gfx_mode	; BL = graphics mode index
		add	bx,bx
		mov	si,ds:gfx_mode_tbl_all[bx] ; SI = chunk ref for this mode
		mov	di,3000h		; Load to offset 0x3000
		mov	al,3			; Archive 3 = zelres3
		call	word ptr cs:sar_loader_fn	; Load graphics driver chunk

		; Call graphics driver init
		call	word ptr cs:loaded_code_a

		; Check: new game or load save?
		; save_mode_flag value comes from zeliad.exe: cbw(has_savefile) where
		; has_savefile=0xFF when a savefile name is on the cmdline.  So:
		;   save_mode_flag = 0      -> NEW GAME (no cmdline arg, full opening flow)
		;   save_mode_flag = 0xFFFF -> LOAD SAVE (player record was already
		;                              restored by zeliad.exe at game_seg:0)
		cmp	word ptr cs:save_mode_flag,-1	; -1 = 0xFFFF = LOAD mode
		jz	start_load_game

start_new_game:
		; --- NEW GAME (full opening: cinematic + title + intro) ---
		; Load opdemo (zelres1 ch1) at CS:6000 and jump to its entry.
		; opdemo plays the slideshow, builds the Zeliard logo, then
		; loads the gameplay chunks (town.bin etc.) itself before
		; transitioning to gameplay.
		mov	byte ptr cs:gvar_cinematic_active,0FFh
		LOAD_CHUNK chunk_ref_opdemo, 6000h, 3	; opening cinematic + title sequence
		jmp	word ptr ds:loaded_code_b ; Jump to opdemo entry (cinematic runner)

start_load_game:
		; --- LOAD SAVED GAME (skip cinematic, go straight to gameplay) ---
		; Player record at game_seg:0 was already restored from the .USR
		; file by zeliad.exe (load_driver_file with the cmdline name).
		; Now load all the gameplay chunks directly and start at the
		; saved location.
		call	set_vga_palette

		; Load main game graphics driver
		mov	ax,cs
		mov	es,ax
		xor	bx,bx
		mov	bl,ds:gvar_gfx_mode
		add	bx,bx
		mov	si,ds:gfx_mode_tbl_cga[bx]
		mov	di,3000h
		mov	al,3
		call	word ptr cs:sar_loader_fn

		; Load town/overworld code (zelres1 ch7) to CS:6000h
		LOAD_CHUNK chunk_ref_town, 6000h, 3

		; Load tile graphics (+0x2000 segment)
		SET_ES_SEG 2000h
		xor	bx,bx
		mov	bl,ds:gvar_gfx_mode
		add	bx,bx
		LOAD_CHUNK ds:gfx_mode_tbl_ega[bx], 9000h, 3

		; Load main game loop (zelres2 ch1 = fight.bin / 200FIGHT)
		LOAD_CHUNK chunk_ref_fight, 0C000h, 3

		; Load character select system (zelres2 ch2) (+0x1000 segment)
		SET_ES_SEG 1000h
		LOAD_CHUNK chunk_ref_select, 0C000h, 3

		; Load item panel graphics (zelres2 ch28) (+0x1000 segment, compressed)
		SET_ES_SEG 1000h
		LOAD_CHUNK chunk_ref_itemp, 0E200h, 2	; AL=2: compressed

		; Fix up loaded enemy system jump table (7 entries)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di
		add	es:[di+6],di
		add	es:[di+8],di
		add	es:[di+0Ah],di
		add	es:[di+0Ch],di

		; Load magic effect graphics (zelres2 ch29, compressed) (+0x2000 segment)
		SET_ES_SEG 2000h
		mov	di,0
		mov	si,chunk_ref_magic
		mov	al,2			; AL=2: compressed
		call	word ptr cs:sar_loader_fn

		; Load sword sprite (zelres2 ch27, compressed)
		SET_ES_SEG 2000h
		LOAD_CHUNK chunk_ref_sword, 1800h, 2	; AL=2: compressed

		; Fix up input system jump table (3 entries)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di

		; Load SAR archive (zelres1 opening data)
		mov	ah,byte ptr ds:sword	; Archive number from config
		mov	al,4			; Function 4 = load archive
		call	word ptr cs:sar_loader_fn

		; Load level/world system (+0x3000 segment)
		mov	ax,cs
		mov	ds,ax
		add	ax,3000h
		mov	word ptr ds:game_init_fn+2,ax ; Set segment for game init
		mov	es,ax
		mov	di,0				; di before si: use explicit movs
		mov	si,chunk_ref_mole
		mov	al,3
		call	word ptr cs:sar_loader_fn

		; Call game initialization (level setup)
		mov	al,ds:gvar_gfx_mode
		push	ds
		call	dword ptr ds:game_init_fn
		pop	ds

		; Initialize music system
		call	load_music_tracks

		; Initialize graphics driver systems
		mov	ax,cs
		mov	ds,ax
		test	byte ptr ds:sword,0FFh
		jz	gfx_init_after_music
		mov	al,byte ptr ds:sword
		mov	bx,music_player_fn
		call	word ptr cs:gfx_call_a

gfx_init_after_music:
		test	byte ptr ds:shield,0FFh
		jz	gfx_init_after_font
		mov	al,byte ptr ds:shield
		mov	bx,font_gfx_base
		call	word ptr cs:gfx_call_c

gfx_init_after_font:
		test	byte ptr ds:cur_weapon_idx,0FFh
		jz	gfx_init_after_tile
		mov	al,byte ptr ds:cur_weapon_idx
		mov	bx,tile_gfx_base
		call	word ptr cs:gfx_call_b

gfx_init_after_tile:

		; Load first level chunks
		mov	ah,byte ptr cs:current_area_id	; Level/area number
		mov	al,1			; Function 1 = load level
		call	word ptr cs:sar_loader_fn

		; Set up level rendering
		mov	ax,cs
		mov	ds,ax
		add	ax,1000h
		mov	es,ax
		mov	si,cs:save_data_base
		lodsb
		push	si
		shr	al,1
		and	al,1Fh
		mov	byte ptr cs:player_tileset,al	; Store level tileset index
		mov	cl,0Bh
		mul	cl			; Calculate chunk ref offset
		mov	si,ax
		add	si,level_tileset_ref_tbl	; Level tileset chunk refs
		mov	di,3000h
		mov	al,5			; Archive 5?
		call	word ptr cs:sar_loader_fn	; Load tileset

		; Load level map data
		pop	si
		lodsb
		mov	cl,0Bh
		mul	cl
		mov	si,ax
		add	si,level_map_ref_tbl	; Level map chunk refs
		mov	di,4000h
		mov	al,2			; Archive 2
		call	word ptr cs:sar_loader_fn	; Load level map

		; Jump to main game loop!
		jmp	word ptr ds:loaded_code_b_fn

;==========================================================================
;  Chunk Reference Table
;
;  The [archive][chunk] byte pairs at the start of each record ARE used at
;  runtime: the chunk_load calls above pass SI pointing directly into this
;  table (e.g. mov si, 0A21Dh). The loader reads only those 2 bytes.
;
;  The filename strings that follow each pair are vestigial development
;  annotations ?-- they document which file each chunk corresponds to but
;  are never read at runtime.
;
;  Format: [archive][chunk]['filename.ext'\0]
;    archive 00h = zelres1, 01h = zelres2
;  Music file entries use [01h]['path'\0] (no chunk byte ?-- DOS file path).
;==========================================================================

ref_font_grp	db	00h, 0Dh, 'font.grp', 0	; zelres1 ch13: font graphics
ref_mole	db	01h, 08h, 'mole.bin', 0	; zelres2 ch8:  mole enemy code
ref_itemp	db	01h, 1Ch, 'itemp.grp', 0	; zelres2 ch28: item panel graphics
ref_select	db	01h, 02h, 'select.bin', 0	; zelres2 ch2:  character select
ref_magic	db	01h, 1Dh, 'magic.grp', 0	; zelres2 ch29: magic effect graphics
ref_sword	db	01h, 1Bh, 'sword.grp', 0	; zelres2 ch27: sword sprite
ref_fight	db	01h, 01h, 'fight.bin', 0	; zelres2 ch1:  main game loop (200FIGHT)
ref_town	db	00h, 07h, 'town.bin', 0	; zelres1 ch7:  town/overworld code
ref_opdemo	db	00h, 01h, 'opdemo.bin', 0	; zelres1 ch1:  opening cinematic (new-game path; loads title/story/gameplay chunks)
; Game frame graphics (GF* series, zelres2) ?-- loaded into CS+2000h:9000h
; archive=1 (zelres2); modes 1 and 2 share the same CGA frame assets

gfx_mode_tbl_ega_lbl	label	word
		dw	GAME_CODE_BASE + (offset ref_gfega)	; mode 0: EGA      ?-> zelres2 ch3 (gfega.bin)
		dw	GAME_CODE_BASE + (offset ref_gfcga)	; mode 1: CGA      ?-> zelres2 ch4 (gfcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gfcga)	; mode 2: CGA 2clr (shared) ?-> zelres2 ch4 (shared with CGA)
		dw	GAME_CODE_BASE + (offset ref_gfhgc)	; mode 3: HGC      ?-> zelres2 ch5 (gfhgc.bin)
		dw	GAME_CODE_BASE + (offset ref_gfmcga)	; mode 4: MCGA     ?-> zelres2 ch7 (gfmcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gftga)	; mode 5: TGA      ?-> zelres2 ch6 (gftga.bin)
		ref_gfega	db	01h, 03h, 'gfega.bin', 0	; zelres2 ch3: EGA game frame
		ref_gfcga	db	01h, 04h, 'gfcga.bin', 0	; zelres2 ch4: CGA game frame
		ref_gfhgc	db	01h, 05h, 'gfhgc.bin', 0	; zelres2 ch5: HGC game frame
		ref_gfmcga	db	01h, 07h, 'gfmcga.bin', 0	; zelres2 ch7: MCGA game frame
		ref_gftga	db	01h, 06h, 'gftga.bin', 0	; zelres2 ch6: TGA game frame

; Tile renderer code (GT* series, zelres1) ?-- loaded into CS:3000h
; archive=0 (zelres1); modes 1 and 2 share the same CGA tile renderer

gfx_mode_tbl_cga_lbl	label	word
		dw	GAME_CODE_BASE + (offset ref_gtega)	; mode 0: EGA      ?-> zelres1 ch8  (gtega.bin)
		dw	GAME_CODE_BASE + (offset ref_gtcga)	; mode 1: CGA      ?-> zelres1 ch9  (gtcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gtcga)	; mode 2: CGA 2clr (shared) ?-> zelres1 ch9  (shared with CGA)
		dw	GAME_CODE_BASE + (offset ref_gthgc)	; mode 3: HGC      ?-> zelres1 ch10 (gthgc.bin)
		dw	GAME_CODE_BASE + (offset ref_gtmcga)	; mode 4: MCGA     ?-> zelres1 ch12 (gtmcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gttga)	; mode 5: TGA      ?-> zelres1 ch11 (gttga.bin)
		ref_gtega	db	00h, 08h, 'gtega.bin', 0	; zelres1 ch8:  EGA tile renderer
		ref_gtcga	db	00h, 09h, 'gtcga.bin', 0	; zelres1 ch9:  CGA tile renderer
		ref_gthgc	db	00h, 0Ah, 'gthgc.bin', 0	; zelres1 ch10: HGC tile renderer
		ref_gtmcga	db	00h, 0Ch, 'gtmcga.bin', 0	; zelres1 ch12: MCGA tile renderer
		ref_gttga	db	00h, 0Bh, 'gttga.bin', 0	; zelres1 ch11: TGA tile renderer

; Graphics driver code (GD* series, zelres1) ?-- loaded into CS:3000h at startup
; archive=0 (zelres1); modes 1 and 2 share the CGA driver

gfx_mode_tbl_all_lbl	label	word
		dw	GAME_CODE_BASE + (offset ref_gdega)	; mode 0: EGA      ?-> zelres1 ch2  (gdega.bin)
		dw	GAME_CODE_BASE + (offset ref_gdcga)	; mode 1: CGA      ?-> zelres1 ch3  (gdcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gdcga)	; mode 2: CGA 2clr (shared) ?-> zelres1 ch3  (shared with CGA)
		dw	GAME_CODE_BASE + (offset ref_gdhgc)	; mode 3: HGC      ?-> zelres1 ch4  (gdhgc.bin)
		dw	GAME_CODE_BASE + (offset ref_gdmcga)	; mode 4: MCGA     ?-> zelres1 ch6  (gdmcga.bin)
		dw	GAME_CODE_BASE + (offset ref_gdtga)	; mode 5: TGA      ?-> zelres1 ch5  (gdtga.bin)
		ref_gdega	db	00h, 02h, 'gdega.bin', 0	; zelres1 ch2:  EGA graphics driver
		ref_gdcga	db	00h, 03h, 'gdcga.bin', 0	; zelres1 ch3:  CGA graphics driver
		ref_gdhgc	db	00h, 04h, 'gdhgc.bin', 0	; zelres1 ch4:  HGC graphics driver
		ref_gdmcga	db	00h, 06h, 'gdmcga.bin', 0	; zelres1 ch6:  MCGA graphics driver
		ref_gdtga	db	00h, 05h, 'gdtga.bin', 0	; zelres1 ch5:  TGA graphics driver
		db	01h, '/MGT1.MSD', 0		; MT-32 music track 1
		db	01h, '1UGM1.MSD', 0		; General MIDI music track 1
		db	01h, '0MGT2.MSD', 0		; MT-32 music track 2
		db	01h, '2UGM2.MSD', 0		; General MIDI music track 2
		db	01h, 1Eh, 'MMAN.GRP', 0	; zelres2 ch30: manual graphics (mono)
		db	01h, 1Fh, 'CMAN.GRP', 0	; zelres2 ch31: manual graphics (color)

game		endp

;==========================================================================
;  load_music_tracks - Load all configured music tracks
;
;  Reads music track count from [ds:0xA0], iterates through track table
;  at music_track_ref_tbl, and calls sound driver track-load fn for each.
;  Track 8 gets special flag (AL=1) for background music.
;==========================================================================

load_music_tracks proc	near
		test	byte ptr ds:music_track_count,0FFh
		jnz	has_tracks
		retn

has_tracks:
		mov	cl,byte ptr ds:music_track_count	; Track count
		xor	ch,ch
		xor	bx,bx			; Track index

load_track_loop:
				push	cx
				push	bx
				mov	dx,bx
				add	bx,bx
				mov	bx,ds:music_track_ref_tbl[bx] ; Get track chunk ref
				xor	al,al
				cmp	dx,8			; Track 8 = background music
				jne	not_bg_music
				mov	al,1			; Flag for background track

not_bg_music:
				call	word ptr cs:sound_load_track_fn ; Load/init track via sound driver
				pop	bx
				inc	bx
				pop	cx
				loop	load_track_loop

		retn

load_music_tracks endp

; Music track chunk ref pointer table (9 tracks, index 0-8)
; Each word is an offset into the zeliad pre-populated data zone (DS < 0xA000)
; where the actual [archive, chunk] record for that track lives.
; Track 8 = background music (gets special AL=1 flag in load_music_tracks).

music_track_ref_tbl_lbl	label	word
		dw	0F00h		; track 0 chunk ref ptr
		dw	3D00h		; track 1 chunk ref ptr
		dw	1500h		; track 2 chunk ref ptr
		dw	3700h		; track 3 chunk ref ptr
		dw	1B00h		; track 4 chunk ref ptr
		dw	3100h		; track 5 chunk ref ptr
		dw	2100h		; track 6 chunk ref ptr
		dw	2B00h		; track 7 chunk ref ptr
		dw	2600h		; track 8 chunk ref ptr (background music)

;==========================================================================
;  set_vga_palette - Set VGA DAC palette based on graphics mode
;
;  Uses gvar_gfx_mode as index into mode-specific palette setup.
;  For MCGA mode: programs 64 VGA DAC registers (8 base colors x 8 shades)
;  using RGB triplets from a base color table + shade offset table.
;==========================================================================

set_vga_palette	proc	near
		mov	bl,ds:gvar_gfx_mode	; Graphics mode index
		xor	bh,bh
		add	bx,bx
		jmp	word ptr cs:palette_handler_jmp_tbl[bx] ; Jump to mode handler

set_vga_palette	endp

; VGA palette initialization jump table ?-- one entry per video mode

palette_handler_jmp_tbl_lbl	label	word
		dw	GAME_CODE_BASE + (offset ega_palette_handler)	; mode 0: EGA
		dw	GAME_CODE_BASE + (offset cga_palette_handler)	; mode 1: CGA
		dw	GAME_CODE_BASE + (offset cga_palette_handler)	; mode 2: CGA 2-color
		dw	GAME_CODE_BASE + (offset hgc_palette_handler)	; mode 3: HGC
		dw	GAME_CODE_BASE + (offset mcga_palette_handler)	; mode 4: MCGA
		dw	GAME_CODE_BASE + (offset tga_palette_handler)	; mode 5: TGA

; EGA palette handler: set all 16 attribute controller registers via INT 10h

ega_palette_handler:
		push	cs
		pop	es
		mov	dx, GAME_CODE_BASE + (offset ega_palette_data)	; ES:DX ?-> 17-byte table
		mov	ax, 1002h		; INT 10h fn 10h sub 02h: set all palette regs
		int	10h
		retn

; EGA attribute controller palette values (border + 16 palette registers)

ega_palette_data:
		db	00h			; border color
		db	3Fh, 24h, 12h, 1Bh, 09h, 36h, 2Dh, 38h	; regs 0-7
		db	07h, 04h, 02h, 03h, 01h, 06h, 05h, 00h	; regs 8-15

; CGA / CGA 2-color palette handler: no palette programming needed

cga_palette_handler:
		retn

; MCGA palette handler: program 64 VGA DAC entries (8 base colors x 8 shades)

mcga_palette_handler:
		push	cs
		pop	ds
		mov	si, palette_base_tbl	; SI = base color / shade offset table
		xor	bx, bx			; BX = first DAC register index
		mov	cx, 8			; 8 base colors

;  Inner palette loop: for each base color (8 iterations)

palette_base_loop:
				push	cx
				lodsb				; Red base
				mov	dh,al
				lodsb				; Green base
				mov	dl,al
				lodsb				; Blue base
				mov	ah,al
				push	si
				mov	si,palette_base_tbl	; Base RGB color table (8 triplets)
				mov	cx,8			; 8 shades per base

;  For each shade: add offset to base RGB, program DAC register

palette_shade_loop:
						push	cx
						push	ax
						push	dx
						lodsb				; Red offset
						add	dh,al			; Final red
						lodsb				; Green offset
						add	al,dl
						mov	ch,al			; Final green
						lodsb				; Blue offset
						add	al,ah
						mov	cl,al			; Final blue
						mov	ax,1010h
						int	10h			; VGA: Set DAC register BX
										;  DH=red, CH=green, CL=blue
						inc	bx			; Next register
						pop	dx
						pop	ax
						pop	cx
						loop	palette_shade_loop

				pop	si
				pop	cx
				loop	palette_base_loop

		retn

; VGA DAC base color table ?-- 8 RGB triplets (6-bit values, 0-3Fh)
; Used as both base colors (outer loop) and shade offsets (inner loop)
; to generate 64 DAC entries: entry[i*8+j] = color[i] + color[j]

palette_base_tbl_lbl	label	byte
		db	00h, 00h, 00h	; black
		db	1Fh, 1Fh, 1Fh	; white
		db	1Fh, 00h, 00h	; red
		db	00h, 1Fh, 00h	; green
		db	00h, 1Fh, 1Fh	; cyan
		db	00h, 00h, 1Fh	; blue
		db	1Fh, 1Fh, 00h	; yellow
		db	1Fh, 00h, 1Fh	; magenta

; TGA and HGC palette handlers: no palette programming needed

tga_palette_handler:
		retn			; mode 5: TGA

hgc_palette_handler:
		retn			; mode 3: HGC

game_init_fn_lbl	label	dword
		dw	0			; offset  (overwritten at runtime)
		dw	3000h			; segment CS+3000h (overwritten at runtime)

save_mode_flag_lbl	label	word
		dw	0			; 0 = new game, 0FFFFh = load save

seg_a		ends

		end	start
