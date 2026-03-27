
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
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; zeliad loads game.bin at this offset in the game segment.
; All internal labels use: GAME_CODE_BASE + (offset label)
GAME_CODE_BASE  equ     0A000h

; Runtime addresses in other loaded segments (fixed at load time, not linkable)

music_player_fn	equ	18ABh			; Music player function
gfx_call_a	equ	201Ch			; Graphics driver call A
gfx_call_b	equ	201Eh			; Graphics driver call B
gfx_call_c	equ	2020h			; Graphics driver call C
sound_load_track_fn equ	203Eh			; Sound driver: load/init music track
loaded_code_a	equ	3000h			; Loaded chunk code entry A
tile_gfx_base	equ	37A4h			; Tile graphics base address
font_gfx_base	equ	3EA4h			; Font graphics base address
loaded_code_b	equ	6000h			; Loaded chunk code entry B
loaded_code_b_fn equ	6002h			; Loaded chunk function B
save_data_base	equ	0C000h			; Save data load address

; Internal data table addresses — calculated from labels defined later in this file.
; Adding/removing code above a label automatically updates its absolute address.
gfx_mode_tbl_ega equ	GAME_CODE_BASE + (offset gfx_mode_tbl_ega_lbl)
gfx_mode_tbl_cga equ	GAME_CODE_BASE + (offset gfx_mode_tbl_cga_lbl)
gfx_mode_tbl_all equ	GAME_CODE_BASE + (offset gfx_mode_tbl_all_lbl)
level_system_ref equ	GAME_CODE_BASE + (offset level_system_ref_lbl)
level_data_ref	equ	GAME_CODE_BASE + (offset level_data_ref_lbl)
palette_base_tbl equ	GAME_CODE_BASE + (offset palette_base_tbl_lbl)
game_init_fn	equ	GAME_CODE_BASE + (offset game_init_fn_lbl)
save_mode_flag	equ	GAME_CODE_BASE + (offset save_mode_flag_lbl)
level_chunk_ref	equ	GAME_CODE_BASE + (offset save_mode_flag_lbl)

; Game state variables (0xFF00+ in game segment, shared with zeliad.exe)
gvar_timer_ticks equ	0FF08h			; Timer tick counter
gvar_game_phase	equ	0FF14h			; Current game phase / graphics mode
gvar_music_vol	equ	0FF36h			; Music volume setting
gvar_music_a	equ	0FF38h			; Music state A
gvar_music_b	equ	0FF39h			; Music state B
gvar_music_c	equ	0FF3Ah			; Music state C
gvar_palette_st	equ	0FF3Ch			; Palette state
gvar_palette_a	equ	0FF3Dh			; Palette value A
gvar_palette_b	equ	0FF3Eh			; Palette value B
gvar_debug_mode	equ	0FF40h			; Debug mode
gvar_debug_val	equ	0FF42h			; Debug value
gvar_joystick	equ	0FF43h			; Joystick state
gvar_joy_data	equ	0FF44h			; Joystick data (7 bytes)
gvar_joy_count	equ	0FF4Bh			; Joystick count
gvar_volume_a	equ	0FF74h			; Volume setting A
gvar_volume_b	equ	0FF77h			; Volume setting B

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

;==========================================================================
;
;  Game Entry Point
;
;  Called from zeliad.exe with AX = mode flag:
;    AX = 0      New game
;    AX = 0xFFFF Load saved game
;
;  Initialization flow:
;    1. Load SAR chunk loader / jump table
;    2. Clear all game state variables
;    3. Load graphics driver for current video mode
;    4. Branch: new game vs. load save
;    5. Load all game subsystems (physics, combat, AI, etc.)
;    6. Initialize palette, music, level data
;    7. Jump to main game loop
;
;==========================================================================

game		proc	far

start:
		mov	cs:save_mode_flag,ax	; Save new/load flag
		mov	ax,cs
		mov	ds,ax
		push	cs
		pop	es

		; Load SAR chunk loader from zelres2
		mov	di,0F500h
		mov	si,0A21Dh		; Chunk ref for loader code
		mov	al,2			; Archive 2 = zelres2
		call	word ptr cs:[10Ch]	; call chunk_load()

		; Fix up loaded code's jump table (relocate pointers)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di

		; Call loaded chunk initialization, then install flat-file loader
		call	flat_init_wrapper	; replaces: call word ptr cs:[120h]
		nop				; padding (was 5-byte indirect call)
		nop

		; Clear all game state variables
		xor	al,al
		mov	ds:gvar_music_b,al
		mov	ds:gvar_music_c,al
		mov	ds:gvar_joystick,al
		mov	ds:gvar_joy_data,al
		mov	ds:gvar_palette_st,al
		mov	ds:gvar_palette_a,al
		mov	ds:gvar_music_a,al
		mov	ds:gvar_music_vol,al
		mov	ds:gvar_palette_b,al
		mov	ds:gvar_joy_count,al
		mov	ds:gvar_timer_ticks,al
		mov	byte ptr ds:[0E7h],al	; Unknown state var
		mov	ds:gvar_volume_a,al
		mov	ds:gvar_volume_b,al
		mov	ds:gvar_debug_mode,al
		mov	ds:gvar_debug_val,al

		; Load graphics driver chunk for current video mode
		mov	ax,cs
		mov	es,ax
		xor	bx,bx
		mov	bl,ds:gvar_game_phase	; BL = graphics mode index
		add	bx,bx
		mov	si,ds:gfx_mode_tbl_all[bx] ; SI = chunk ref for this mode
		mov	di,3000h		; Load to offset 0x3000
		mov	al,3			; Archive 3 = zelres3
		call	word ptr cs:[10Ch]	; Load graphics driver chunk

		; Call graphics driver init
		call	word ptr cs:loaded_code_a

		; Check: new game or load save?
;*		cmp	word ptr cs:save_mode_flag,0FFFFh
		db	 2Eh, 83h, 3Eh, 74h,0A4h,0FFh	;  Fixup - byte match
		jz	start_new_game

		; --- LOAD SAVED GAME ---
		mov	byte ptr cs:gvar_volume_b,0FFh
		mov	si,0A27Bh		; Saved game chunk ref
		mov	di,6000h
		mov	al,3			; Archive 3
		call	word ptr cs:[10Ch]	; Load save handler
		jmp	word ptr ds:loaded_code_b ; Jump to save loader

start_new_game:
		; --- NEW GAME ---
		call	set_vga_palette

		; Load main game graphics driver
		mov	ax,cs
		mov	es,ax
		xor	bx,bx
		mov	bl,ds:gvar_game_phase
		add	bx,bx
		mov	si,ds:gfx_mode_tbl_cga[bx]
		mov	di,3000h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Load gameplay code chunk
		mov	si,0A270h
		mov	di,6000h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Load tile graphics (+0x2000 segment)
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		xor	bx,bx
		mov	bl,ds:gvar_game_phase
		add	bx,bx
		mov	si,ds:gfx_mode_tbl_ega[bx]
		mov	di,9000h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Load more graphics data
		mov	si,0A264h
		mov	di,0C000h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Load combat/physics system (+0x1000 segment)
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	si,0A23Fh
		mov	di,0C000h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Load enemy AI / animation system
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	si,0A233h
		mov	di,0E200h
		mov	al,2			; Archive 2 = zelres2
		call	word ptr cs:[10Ch]

		; Fix up loaded enemy system jump table (7 entries)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di
		add	es:[di+6],di
		add	es:[di+8],di
		add	es:[di+0Ah],di
		add	es:[di+0Ch],di

		; Load sprite system (+0x2000 segment)
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	si,0A24Ch
		mov	al,2
		call	word ptr cs:[10Ch]

		; Load input/UI system
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,0A258h
		mov	di,1800h
		mov	al,2
		call	word ptr cs:[10Ch]

		; Fix up input system jump table (3 entries)
		add	es:[di],di
		add	es:[di+2],di
		add	es:[di+4],di

		; Load SAR archive (zelres1 opening data)
		mov	ah,byte ptr ds:[92h]	; Archive number from config
		mov	al,4			; Function 4 = load archive
		call	word ptr cs:[10Ch]

		; Load level/world system (+0x3000 segment)
		mov	ax,cs
		mov	ds,ax
		add	ax,3000h
		mov	word ptr ds:game_init_fn+2,ax ; Set segment for game init
		mov	es,ax
		mov	di,0
		mov	si,0A228h
		mov	al,3
		call	word ptr cs:[10Ch]

		; Call game initialization (level setup)
		mov	al,ds:gvar_game_phase
		push	ds
		call	dword ptr ds:game_init_fn
		pop	ds

		; Initialize music system
		call	load_music_tracks

		; Initialize graphics driver systems
		mov	ax,cs
		mov	ds,ax
		test	byte ptr ds:[92h],0FFh
		jz	skip_gfx_init_a
		mov	al,byte ptr ds:[92h]
		mov	bx,music_player_fn
		call	word ptr cs:gfx_call_a
skip_gfx_init_a:
		test	byte ptr ds:[93h],0FFh
		jz	skip_gfx_init_b
		mov	al,byte ptr ds:[93h]
		mov	bx,font_gfx_base
		call	word ptr cs:gfx_call_c
skip_gfx_init_b:
		test	byte ptr ds:[9Dh],0FFh
		jz	skip_gfx_init_c
		mov	al,byte ptr ds:[9Dh]
		mov	bx,tile_gfx_base
		call	word ptr cs:gfx_call_b
skip_gfx_init_c:

		; Load first level chunks
		mov	ah,byte ptr cs:[0C4h]	; Level/area number
		mov	al,1			; Function 1 = load level
		call	word ptr cs:[10Ch]

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
		mov	byte ptr cs:[0C8h],al	; Store level tileset index
		mov	cl,0Bh
		mul	cl			; Calculate chunk ref offset
		mov	si,ax
		add	si,0A363h		; Level tileset chunk refs
		mov	di,3000h
		mov	al,5			; Archive 5?
		call	word ptr cs:[10Ch]	; Load tileset

		; Load level map data
		pop	si
		lodsb
		mov	cl,0Bh
		mul	cl
		mov	si,ax
		add	si,0A38Fh		; Level map chunk refs
		mov	di,4000h
		mov	al,2			; Archive 2
		call	word ptr cs:[10Ch]	; Load level map

		; Jump to main game loop!
		jmp	word ptr ds:loaded_code_b_fn

;==========================================================================
;  File Reference Table
;
;  Original development filenames with chunk number associations.
;  Format: [chunk_num_byte] 'filename.ext' [null] [flags]
;  These strings are vestigial - not used at runtime.
;==========================================================================

		db	0
		db	0Dh, 'font.grp'	; Chunk 13: bitmap font
		db	0, 1
		db	8, 'mole.bin'		; Chunk 8: mole enemy data
		db	 00h, 01h, 1Ch
		db	'itemp.grp'		; Item panel graphics
		db	0, 1, 2
		db	'select.bin'		; Selection UI data
		db	 00h, 01h, 1Dh
		db	'magic.grp'		; Magic effect graphics
		db	0, 1
		db	1Bh, 'sword.grp'	; Chunk 27: sword/weapon sprite
		db	0, 1, 1
		db	'fight.bin'		; Combat data
		db	0, 0, 7
		db	'town.bin'		; Town data
		db	0, 0, 1
		db	'opdemo.bin'		; Opening demo
		db	 00h			; null terminator
gfx_mode_tbl_ega_lbl	label	word
		db	 94h,0A2h,0A0h,0A2h,0A0h
		db	0A2h,0ACh,0A2h,0B8h,0A2h,0C5h
		db	0A2h, 01h, 03h
		db	'gfega.bin'		; Chunk 3: font/frame (EGA)
		db	0, 1, 4
		db	'gfcga.bin'		; Chunk 4: font/frame (CGA)
		db	0, 1, 5
		db	'gfhgc.bin'		; Chunk 5: font/frame (HGC)
		db	0, 1, 7
		db	'gfmcga.bin'		; Chunk 7: font/frame (MCGA)
		db	0, 1, 6
		db	'gftga.bin'		; Chunk 6: font/frame (TGA)
		db	 00h			; null terminator
gfx_mode_tbl_cga_lbl	label	word
		db	0DDh,0A2h,0E9h,0A2h,0E9h
		db	0A2h,0F5h,0A2h, 01h,0A3h, 0Eh
		db	0A3h, 00h
		db	8, 'gtega.bin'		; Chunk 8: tile graphics (EGA)
		db	0, 0
		db	9, 'gtcga.bin'		; Chunk 9: tile graphics (CGA)
		db	0, 0
		db	0Ah, 'gthgc.bin'	; Chunk 10: tile graphics (HGC)
		db	0, 0
		db	0Ch, 'gtmcga.bin'	; Chunk 12: tile graphics (MCGA)
		db	 00h, 00h, 0Bh
		db	'gttga.bin'		; Chunk 11: tile graphics (TGA)
		db	 00h			; null terminator
gfx_mode_tbl_all_lbl	label	word
		db	 26h,0A3h, 32h,0A3h, 32h
		db	0A3h, 3Eh,0A3h, 4Ah,0A3h, 57h
		db	0A3h, 00h, 02h
		db	'gdega.bin'		; Chunk 2: graphics driver (EGA)
		db	0, 0, 3
		db	'gdcga.bin'		; Chunk 3: graphics driver (CGA)
		db	0, 0, 4
		db	'gdhgc.bin'		; Chunk 4: graphics driver (HGC)
		db	0, 0, 6
		db	'gdmcga.bin'		; Chunk 6: graphics driver (MCGA)
		db	0, 0, 5
		db	'gdtga.bin'		; Chunk 5: graphics driver (TGA)
		db	0, 1
		db	'/MGT1.MSD'		; MT-32 music track 1
		db	0, 1
		db	'1UGM1.MSD'		; General MIDI music track 1
		db	0, 1
		db	'0MGT2.MSD'		; MT-32 music track 2
		db	0, 1
		db	'2UGM2.MSD'		; General MIDI music track 2
		db	 00h, 01h, 1Eh
		db	'MMAN.GRP'		; Chunk 30: manual graphics (mono)
		db	 00h, 01h, 1Fh
		db	'CMAN.GRP'		; Chunk 31: manual graphics (color)
		db	0

game		endp


;==========================================================================
;  load_music_tracks - Load all configured music tracks
;
;  Reads music track count from [ds:0xA0], iterates through track table
;  at level_data_ref (0xA3F2), and calls sound driver track-load fn for each.
;  Track 8 gets special flag (AL=1) for background music.
;==========================================================================

load_music_tracks proc	near
		test	byte ptr ds:[0A0h],0FFh
		jnz	has_tracks
		retn

has_tracks:
		mov	cl,byte ptr ds:[0A0h]	; Track count
		xor	ch,ch
		xor	bx,bx			; Track index

load_track_loop:
		push	cx
		push	bx
		mov	dx,bx
		add	bx,bx
		mov	bx,ds:level_system_ref[bx] ; Get track chunk ref
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

		; Padding / unknown data
level_system_ref_lbl	label	word
		db	 00h, 0Fh, 00h, 3Dh, 00h, 15h
		db	 00h, 37h, 00h, 1Bh, 00h, 31h
		db	 00h, 21h, 00h, 2Bh, 00h
		db	26h


;==========================================================================
;  set_vga_palette - Set VGA DAC palette based on graphics mode
;
;  Uses gvar_game_phase as index into mode-specific palette setup.
;  For MCGA mode: programs 64 VGA DAC registers (8 base colors x 8 shades)
;  using RGB triplets from a base color table + shade offset table.
;==========================================================================

set_vga_palette	proc	near
		mov	bl,ds:gvar_game_phase	; Graphics mode index
		xor	bh,bh
		add	bx,bx
		jmp	word ptr cs:level_data_ref[bx] ; Jump to mode handler
set_vga_palette	endp

		; Jump table + palette setup code (mode-specific handlers)
level_data_ref_lbl	label	word
		db	0FEh,0A3h, 1Ah,0A4h, 1Ah,0A4h
		db	 6Fh,0A4h, 1Bh,0A4h, 6Eh,0A4h

		; EGA/CGA palette handler - set text mode and return
		db	 0Eh, 07h,0BAh, 09h,0A4h,0B8h
		db	 02h, 10h,0CDh, 10h,0C3h

		; Mode index table
		db	 00h
		db	 3Fh, 24h, 12h, 1Bh, 09h, 36h
		db	 2Dh, 38h, 07h, 04h, 02h, 03h
		db	 01h, 06h, 05h, 00h

		; MCGA palette setup: Programs 64 DAC registers
		; Reads 8 base RGB triplets, adds 8 shade offsets per base
		db	0C3h, 0Eh
		db	 1Fh,0BEh, 56h,0A4h, 33h,0DBh
		db	0B9h, 08h, 00h

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

		; Default shade offsets (8 RGB triplets: black to white ramp)
palette_base_tbl_lbl	label	byte
		db	 00h, 00h, 00h, 1Fh, 1Fh, 1Fh
		db	 1Fh, 00h, 00h, 00h, 1Fh, 00h
		db	 00h, 1Fh, 1Fh, 00h, 00h, 1Fh
		db	 1Fh, 1Fh, 00h, 1Fh, 00h, 1Fh
		db	0C3h,0C3h		; retn padding
game_init_fn_lbl	label	dword		; game init far pointer (offset:seg)
		db	 00h, 00h, 00h, 30h	; = 0x3000:0x0000 (loaded_code_a)
save_mode_flag_lbl	label	word		; new/load game flag + level chunk ref
		db	 00h, 00h


;==========================================================================
;
;  flat_init_wrapper - Call fight.bin init then install the flat-file loader
;
;  Replaces the original "call word ptr cs:[120h]" at game startup.
;  fight.bin init installs its own SAR loader at CS:[010Ch]; we immediately
;  overwrite that pointer with flat_file_loader so all subsequent chunk
;  loads go to flat files instead of SAR archives.
;
;==========================================================================

flat_init_wrapper	proc	near
		call	word ptr cs:[120h]		; fight.bin initialisation (original)
		mov	word ptr cs:[10Ch], offset flat_file_loader ; install our loader
		retn
flat_init_wrapper	endp


;==========================================================================
;
;  flat_file_loader - Load a chunk from a flat file on disk
;
;  Called with same convention as fight.bin SAR loader:
;    AL  = function (2=load+decomp, 3=load raw, 4=open archive, 1=load level)
;    DS:SI -> [archive_0idx byte, chunk_1indexed byte]
;    ES:DI = destination buffer
;
;  AL=4 (open archive) and AL=1 (load level) are no-ops — flat files need
;  no archive open step and level loading falls through to original code.
;  AL=2 and AL=3 both read the pre-decompressed file; no distinction needed.
;
;==========================================================================

FFL_ENTRY_SZ	equ	24		; bytes per filename table entry (max 23 + null)

flat_file_loader	proc	near
		cmp	al,4			; open archive = no-op
		je	ffl_ret
		cmp	al,1			; load level = no-op (uses original path)
		je	ffl_ret

		; AL=2 or AL=3: load flat file
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es

		; Compute filename table pointer: base + chunk_0idx * FFL_ENTRY_SZ
		xor	bh,bh
		mov	bl,byte ptr [si]	; BL = archive index (0-2)
		mov	cl,byte ptr [si+1]	; CL = chunk 1-indexed
		dec	cl			; CL = chunk 0-indexed
		xor	ch,ch

		; BX = archive base offset
		cmp	bl,0
		je	ffl_arc0
		cmp	bl,1
		je	ffl_arc1
		mov	bx, offset ffl_names_z3	; archive 2 (zelres3)
		jmp	short ffl_got_base
ffl_arc0:
		mov	bx, offset ffl_names_z1	; archive 0 (zelres1)
		jmp	short ffl_got_base
ffl_arc1:
		mov	bx, offset ffl_names_z2	; archive 1 (zelres2)

ffl_got_base:
		; DX = BX + CX * FFL_ENTRY_SZ
		mov	ax,FFL_ENTRY_SZ
		mul	cx			; AX = chunk_0idx * 24
		add	bx,ax			; BX = table base + chunk offset

		push	cs
		pop	ds
		mov	dx,bx			; DS:DX = null-terminated filename

		; Open file (read-only)
		mov	ax,3D00h
		int	21h
		jc	ffl_error

		mov	bx,ax			; BX = file handle

		; Read entire file to ES:DI
		push	es
		pop	ds			; DS = destination segment
		mov	dx,di			; DS:DX = destination
		mov	cx,0FFFFh		; read up to 64 KB
		mov	ah,3Fh
		int	21h

		; Close file
		mov	ah,3Eh
		int	21h

		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
ffl_ret:
		retn

ffl_error:
		; File open failed — restore stack and return
		; (game will likely crash, but at least registers are clean)
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
flat_file_loader	endp


;==========================================================================
;  Flat-file filename tables
;  Format: null-terminated path string, padded to FFL_ENTRY_SZ (24) bytes
;  Paths are relative to current directory (ZELRES1\, ZELRES2\, ZELRES3\)
;==========================================================================

; ── zelres1 (archive 0, 40 chunks) ────────────────────────────────────────
ffl_names_z1	label	byte
		db 'ZELRES1\opdemo.bin',  0,0,0,0,0  ; chunk_00
		db 'ZELRES1\gdega.bin',   0,0,0,0,0,0 ; chunk_01
		db 'ZELRES1\gdcga.bin',   0,0,0,0,0,0 ; chunk_02
		db 'ZELRES1\gdhgc.bin',   0,0,0,0,0,0 ; chunk_03
		db 'ZELRES1\gdtga.bin',   0,0,0,0,0,0 ; chunk_04
		db 'ZELRES1\gdmcga.bin',  0,0,0,0,0  ; chunk_05
		db 'ZELRES1\town.bin',    0,0,0,0,0,0,0 ; chunk_06
		db 'ZELRES1\gtega.bin',   0,0,0,0,0,0 ; chunk_07
		db 'ZELRES1\gtcga.bin',   0,0,0,0,0,0 ; chunk_08
		db 'ZELRES1\gthgc.bin',   0,0,0,0,0,0 ; chunk_09
		db 'ZELRES1\gttga.bin',   0,0,0,0,0,0 ; chunk_10
		db 'ZELRES1\gtmcga.bin',  0,0,0,0,0  ; chunk_11
		db 'ZELRES1\font.grp',    0,0,0,0,0,0,0 ; chunk_12
		db 'ZELRES1\ame.grp',     0,0,0,0,0,0,0,0 ; chunk_13
		db 'ZELRES1\dmaou.grp',   0,0,0,0,0,0 ; chunk_14
		db 'ZELRES1\hime.grp',    0,0,0,0,0,0,0 ; chunk_15
		db 'ZELRES1\himp.grp',    0,0,0,0,0,0,0 ; chunk_16
		db 'ZELRES1\hou.grp',     0,0,0,0,0,0,0,0 ; chunk_17
		db 'ZELRES1\isi.grp',     0,0,0,0,0,0,0,0 ; chunk_18
		db 'ZELRES1\maop.grp',    0,0,0,0,0,0,0 ; chunk_19
		db 'ZELRES1\ne80.grp',    0,0,0,0,0,0,0 ; chunk_20
		db 'ZELRES1\ne81.grp',    0,0,0,0,0,0,0 ; chunk_21
		db 'ZELRES1\nec.grp',     0,0,0,0,0,0,0,0 ; chunk_22
		db 'ZELRES1\new1.grp',    0,0,0,0,0,0,0 ; chunk_23
		db 'ZELRES1\new2.grp',    0,0,0,0,0,0,0 ; chunk_24
		db 'ZELRES1\oui.grp',     0,0,0,0,0,0,0,0 ; chunk_25
		db 'ZELRES1\oup.grp',     0,0,0,0,0,0,0,0 ; chunk_26
		db 'ZELRES1\sei.grp',     0,0,0,0,0,0,0,0 ; chunk_27
		db 'ZELRES1\seip.grp',    0,0,0,0,0,0,0 ; chunk_28
		db 'ZELRES1\ttl1.grp',    0,0,0,0,0,0,0 ; chunk_29
		db 'ZELRES1\ttl2.grp',    0,0,0,0,0,0,0 ; chunk_30
		db 'ZELRES1\ttl3.grp',    0,0,0,0,0,0,0 ; chunk_31
		db 'ZELRES1\waku.grp',    0,0,0,0,0,0,0 ; chunk_32
		db 'ZELRES1\yuu1.grp',    0,0,0,0,0,0,0 ; chunk_33
		db 'ZELRES1\yuu2.grp',    0,0,0,0,0,0,0 ; chunk_34
		db 'ZELRES1\yuu3.grp',    0,0,0,0,0,0,0 ; chunk_35
		db 'ZELRES1\yuu4.grp',    0,0,0,0,0,0,0 ; chunk_36
		db 'ZELRES1\yuup.grp',    0,0,0,0,0,0,0 ; chunk_37
		db 'ZELRES1\zend.msd',    0,0,0,0,0,0,0 ; chunk_38
		db 'ZELRES1\zopn.msd',    0,0,0,0,0,0,0 ; chunk_39

; ── zelres2 (archive 1, 58 chunks) ────────────────────────────────────────
ffl_names_z2	label	byte
		db 'ZELRES2\fight.bin',   0,0,0,0,0,0 ; chunk_00
		db 'ZELRES2\select.bin',  0,0,0,0,0  ; chunk_01
		db 'ZELRES2\gfega.bin',   0,0,0,0,0,0 ; chunk_02
		db 'ZELRES2\gfcga.bin',   0,0,0,0,0,0 ; chunk_03
		db 'ZELRES2\gfhgc.bin',   0,0,0,0,0,0 ; chunk_04
		db 'ZELRES2\gftga.bin',   0,0,0,0,0,0 ; chunk_05
		db 'ZELRES2\gfmcga.bin',  0,0,0,0,0  ; chunk_06
		db 'ZELRES2\mole.bin',    0,0,0,0,0,0,0 ; chunk_07
		db 'ZELRES2\YMPD.BIN',    0,0,0,0,0,0,0 ; chunk_08
		db 'ZELRES2\CKPD.BIN',    0,0,0,0,0,0,0 ; chunk_09
		db 'ZELRES2\KINGPRO.BIN', 0,0,0,0  ; chunk_10
		db 'ZELRES2\OMOYPRO.BIN', 0,0,0,0  ; chunk_11
		db 'ZELRES2\ARMRPRO.BIN', 0,0,0,0  ; chunk_12
		db 'ZELRES2\BANKPRO.BIN', 0,0,0,0  ; chunk_13
		db 'ZELRES2\CHURPRO.BIN', 0,0,0,0  ; chunk_14
		db 'ZELRES2\DRUGPRO.BIN', 0,0,0,0  ; chunk_15
		db 'ZELRES2\INNAPRO.BIN', 0,0,0,0  ; chunk_16
		db 'ZELRES2\KENJPRO.BIN', 0,0,0,0  ; chunk_17
		db 'ZELRES2\KING.GRP',    0,0,0,0,0,0,0 ; chunk_18
		db 'ZELRES2\OMOYA.GRP',   0,0,0,0,0,0 ; chunk_19
		db 'ZELRES2\ARMOR.GRP',   0,0,0,0,0,0 ; chunk_20
		db 'ZELRES2\BANK.GRP',    0,0,0,0,0,0,0 ; chunk_21
		db 'ZELRES2\CHURCH.GRP',  0,0,0,0,0  ; chunk_22
		db 'ZELRES2\DRUG.GRP',    0,0,0,0,0,0,0 ; chunk_23
		db 'ZELRES2\INN.GRP',     0,0,0,0,0,0,0,0 ; chunk_24
		db 'ZELRES2\KENJYA.GRP',  0,0,0,0,0  ; chunk_25
		db 'ZELRES2\sword.grp',   0,0,0,0,0,0 ; chunk_26
		db 'ZELRES2\itemp.grp',   0,0,0,0,0,0 ; chunk_27
		db 'ZELRES2\magic.grp',   0,0,0,0,0,0 ; chunk_28
		db 'ZELRES2\MMAN.GRP',    0,0,0,0,0,0,0 ; chunk_29
		db 'ZELRES2\CMAN.GRP',    0,0,0,0,0,0,0 ; chunk_30
		db 'ZELRES2\TMAN.GRP',    0,0,0,0,0,0,0 ; chunk_31
		db 'ZELRES2\INNA.GRP',    0,0,0,0,0,0,0 ; chunk_32
		db 'ZELRES2\CPAT.GRP',    0,0,0,0,0,0,0 ; chunk_33
		db 'ZELRES2\MPAT.GRP',    0,0,0,0,0,0,0 ; chunk_34
		db 'ZELRES2\DPAT.GRP',    0,0,0,0,0,0,0 ; chunk_35
		db 'ZELRES2\CMAP.MDT',    0,0,0,0,0,0,0 ; chunk_36
		db 'ZELRES2\MRMP.MDT',    0,0,0,0,0,0,0 ; chunk_37
		db 'ZELRES2\STMP.MDT',    0,0,0,0,0,0,0 ; chunk_38
		db 'ZELRES2\BSMP.MDT',    0,0,0,0,0,0,0 ; chunk_39
		db 'ZELRES2\HLMP.MDT',    0,0,0,0,0,0,0 ; chunk_40
		db 'ZELRES2\TMMP.MDT',    0,0,0,0,0,0,0 ; chunk_41
		db 'ZELRES2\DRMP.MDT',    0,0,0,0,0,0,0 ; chunk_42
		db 'ZELRES2\LLMP.MDT',    0,0,0,0,0,0,0 ; chunk_43
		db 'ZELRES2\PRMP.MDT',    0,0,0,0,0,0,0 ; chunk_44
		db 'ZELRES2\ESMP.MDT',    0,0,0,0,0,0,0 ; chunk_45
		db 'ZELRES2\MGT1.MSD',    0,0,0,0,0,0,0 ; chunk_46
		db 'ZELRES2\MGT2.MSD',    0,0,0,0,0,0,0 ; chunk_47
		db 'ZELRES2\UGM1.MSD',    0,0,0,0,0,0,0 ; chunk_48
		db 'ZELRES2\UGM2.MSD',    0,0,0,0,0,0,0 ; chunk_49
		db 'ZELRES2\enddemo.bin', 0,0,0,0  ; chunk_50
		db 'ZELRES2\en72.grp',    0,0,0,0,0,0,0 ; chunk_51
		db 'ZELRES2\end4.grp',    0,0,0,0,0,0,0 ; chunk_52
		db 'ZELRES2\end5.grp',    0,0,0,0,0,0,0 ; chunk_53
		db 'ZELRES2\end6.grp',    0,0,0,0,0,0,0 ; chunk_54
		db 'ZELRES2\end7.grp',    0,0,0,0,0,0,0 ; chunk_55
		db 'ZELRES2\fin.grp',     0,0,0,0,0,0,0,0 ; chunk_56
		db 'ZELRES2\ROKA.GRP',    0,0,0,0,0,0,0 ; chunk_57

; ── zelres3 (archive 2, 96 chunks) ────────────────────────────────────────
ffl_names_z3	label	byte
		db 'ZELRES3\ROKADEMO.BIN',0,0,0  ; chunk_00
		db 'ZELRES3\EAI1.BIN',    0,0,0,0,0,0,0 ; chunk_01
		db 'ZELRES3\EAI2.BIN',    0,0,0,0,0,0,0 ; chunk_02
		db 'ZELRES3\EAI3.BIN',    0,0,0,0,0,0,0 ; chunk_03
		db 'ZELRES3\EAI4.BIN',    0,0,0,0,0,0,0 ; chunk_04
		db 'ZELRES3\EAI5.BIN',    0,0,0,0,0,0,0 ; chunk_05
		db 'ZELRES3\EAI6.BIN',    0,0,0,0,0,0,0 ; chunk_06
		db 'ZELRES3\EAI7.BIN',    0,0,0,0,0,0,0 ; chunk_07
		db 'ZELRES3\EAI8.BIN',    0,0,0,0,0,0,0 ; chunk_08
		db 'ZELRES3\CRAB.BIN',    0,0,0,0,0,0,0 ; chunk_09
		db 'ZELRES3\TAKO.BIN',    0,0,0,0,0,0,0 ; chunk_10
		db 'ZELRES3\TORI.BIN',    0,0,0,0,0,0,0 ; chunk_11
		db 'ZELRES3\ZELA.BIN',    0,0,0,0,0,0,0 ; chunk_12
		db 'ZELRES3\MEDA.BIN',    0,0,0,0,0,0,0 ; chunk_13
		db 'ZELRES3\LEGA.BIN',    0,0,0,0,0,0,0 ; chunk_14
		db 'ZELRES3\ZEL2.BIN',    0,0,0,0,0,0,0 ; chunk_15
		db 'ZELRES3\DRGN.BIN',    0,0,0,0,0,0,0 ; chunk_16
		db 'ZELRES3\AKMA.BIN',    0,0,0,0,0,0,0 ; chunk_17
		db 'ZELRES3\MAO1.BIN',    0,0,0,0,0,0,0 ; chunk_18
		db 'ZELRES3\MAO2.BIN',    0,0,0,0,0,0,0 ; chunk_19
		db 'ZELRES3\MP10.MDT',    0,0,0,0,0,0,0 ; chunk_20
		db 'ZELRES3\MP1D.MDT',    0,0,0,0,0,0,0 ; chunk_21
		db 'ZELRES3\MP20.MDT',    0,0,0,0,0,0,0 ; chunk_22
		db 'ZELRES3\MP21.MDT',    0,0,0,0,0,0,0 ; chunk_23
		db 'ZELRES3\MP2D.MDT',    0,0,0,0,0,0,0 ; chunk_24
		db 'ZELRES3\MP30.MDT',    0,0,0,0,0,0,0 ; chunk_25
		db 'ZELRES3\MP31.MDT',    0,0,0,0,0,0,0 ; chunk_26
		db 'ZELRES3\MP3D.MDT',    0,0,0,0,0,0,0 ; chunk_27
		db 'ZELRES3\MP40.MDT',    0,0,0,0,0,0,0 ; chunk_28
		db 'ZELRES3\MP41.MDT',    0,0,0,0,0,0,0 ; chunk_29
		db 'ZELRES3\MP4D.MDT',    0,0,0,0,0,0,0 ; chunk_30
		db 'ZELRES3\MP50.MDT',    0,0,0,0,0,0,0 ; chunk_31
		db 'ZELRES3\MP51.MDT',    0,0,0,0,0,0,0 ; chunk_32
		db 'ZELRES3\MP5D.MDT',    0,0,0,0,0,0,0 ; chunk_33
		db 'ZELRES3\MP60.MDT',    0,0,0,0,0,0,0 ; chunk_34
		db 'ZELRES3\MP61.MDT',    0,0,0,0,0,0,0 ; chunk_35
		db 'ZELRES3\MP62.MDT',    0,0,0,0,0,0,0 ; chunk_36
		db 'ZELRES3\MP6D.MDT',    0,0,0,0,0,0,0 ; chunk_37
		db 'ZELRES3\MP70.MDT',    0,0,0,0,0,0,0 ; chunk_38
		db 'ZELRES3\MP71.MDT',    0,0,0,0,0,0,0 ; chunk_39
		db 'ZELRES3\MP72.MDT',    0,0,0,0,0,0,0 ; chunk_40
		db 'ZELRES3\MP73.MDT',    0,0,0,0,0,0,0 ; chunk_41
		db 'ZELRES3\MP7D.MDT',    0,0,0,0,0,0,0 ; chunk_42
		db 'ZELRES3\MP80.MDT',    0,0,0,0,0,0,0 ; chunk_43
		db 'ZELRES3\MP81.MDT',    0,0,0,0,0,0,0 ; chunk_44
		db 'ZELRES3\MP82.MDT',    0,0,0,0,0,0,0 ; chunk_45
		db 'ZELRES3\MP83.MDT',    0,0,0,0,0,0,0 ; chunk_46
		db 'ZELRES3\MP84.MDT',    0,0,0,0,0,0,0 ; chunk_47
		db 'ZELRES3\MP8D.MDT',    0,0,0,0,0,0,0 ; chunk_48
		db 'ZELRES3\MP90.MDT',    0,0,0,0,0,0,0 ; chunk_49
		db 'ZELRES3\MPA0.MDT',    0,0,0,0,0,0,0 ; chunk_50
		db 'ZELRES3\FMAN.GRP',    0,0,0,0,0,0,0 ; chunk_51
		db 'ZELRES3\ROKA.GRP',    0,0,0,0,0,0,0 ; chunk_52
		db 'ZELRES3\DMAN.GRP',    0,0,0,0,0,0,0 ; chunk_53
		db 'ZELRES3\DCHR.GRP',    0,0,0,0,0,0,0 ; chunk_54
		db 'ZELRES3\ENCNT.GRP',   0,0,0,0,0,0 ; chunk_55
		db 'ZELRES3\ENP1.GRP',    0,0,0,0,0,0,0 ; chunk_56
		db 'ZELRES3\ENP2.GRP',    0,0,0,0,0,0,0 ; chunk_57
		db 'ZELRES3\ENP3.GRP',    0,0,0,0,0,0,0 ; chunk_58
		db 'ZELRES3\ENP4.GRP',    0,0,0,0,0,0,0 ; chunk_59
		db 'ZELRES3\ENP5.GRP',    0,0,0,0,0,0,0 ; chunk_60
		db 'ZELRES3\ENP6.GRP',    0,0,0,0,0,0,0 ; chunk_61
		db 'ZELRES3\ENP7.GRP',    0,0,0,0,0,0,0 ; chunk_62
		db 'ZELRES3\ENP8.GRP',    0,0,0,0,0,0,0 ; chunk_63
		db 'ZELRES3\CRAB.GRP',    0,0,0,0,0,0,0 ; chunk_64
		db 'ZELRES3\TAKO.GRP',    0,0,0,0,0,0,0 ; chunk_65
		db 'ZELRES3\TORI.GRP',    0,0,0,0,0,0,0 ; chunk_66
		db 'ZELRES3\ZELA.GRP',    0,0,0,0,0,0,0 ; chunk_67
		db 'ZELRES3\MEDA.GRP',    0,0,0,0,0,0,0 ; chunk_68
		db 'ZELRES3\LEGA.GRP',    0,0,0,0,0,0,0 ; chunk_69
		db 'ZELRES3\DRGN.GRP',    0,0,0,0,0,0,0 ; chunk_70
		db 'ZELRES3\AKMA.GRP',    0,0,0,0,0,0,0 ; chunk_71
		db 'ZELRES3\MAO1.GRP',    0,0,0,0,0,0,0 ; chunk_72
		db 'ZELRES3\MAO2.GRP',    0,0,0,0,0,0,0 ; chunk_73
		db 'ZELRES3\MPP1.GRP',    0,0,0,0,0,0,0 ; chunk_74
		db 'ZELRES3\MPP2.GRP',    0,0,0,0,0,0,0 ; chunk_75
		db 'ZELRES3\MPP3.GRP',    0,0,0,0,0,0,0 ; chunk_76
		db 'ZELRES3\MPP4.GRP',    0,0,0,0,0,0,0 ; chunk_77
		db 'ZELRES3\MPP5.GRP',    0,0,0,0,0,0,0 ; chunk_78
		db 'ZELRES3\MPP6.GRP',    0,0,0,0,0,0,0 ; chunk_79
		db 'ZELRES3\MPP7.GRP',    0,0,0,0,0,0,0 ; chunk_80
		db 'ZELRES3\MPP8.GRP',    0,0,0,0,0,0,0 ; chunk_81
		db 'ZELRES3\MPP9.GRP',    0,0,0,0,0,0,0 ; chunk_82
		db 'ZELRES3\MPPA.GRP',    0,0,0,0,0,0,0 ; chunk_83
		db 'ZELRES3\MPPB.GRP',    0,0,0,0,0,0,0 ; chunk_84
		db 'ZELRES3\MUS1.MSD',    0,0,0,0,0,0,0 ; chunk_85
		db 'ZELRES3\MUS2.MSD',    0,0,0,0,0,0,0 ; chunk_86
		db 'ZELRES3\MUS3.MSD',    0,0,0,0,0,0,0 ; chunk_87
		db 'ZELRES3\MUS4.MSD',    0,0,0,0,0,0,0 ; chunk_88
		db 'ZELRES3\MUS5.MSD',    0,0,0,0,0,0,0 ; chunk_89
		db 'ZELRES3\MUS6.MSD',    0,0,0,0,0,0,0 ; chunk_90
		db 'ZELRES3\MUS7.MSD',    0,0,0,0,0,0,0 ; chunk_91
		db 'ZELRES3\MUS8.MSD',    0,0,0,0,0,0,0 ; chunk_92
		db 'ZELRES3\MBOS.MSD',    0,0,0,0,0,0,0 ; chunk_93
		db 'ZELRES3\MFAN.MSD',    0,0,0,0,0,0,0 ; chunk_94
		db 'ZELRES3\MMAO.MSD',    0,0,0,0,0,0,0 ; chunk_95

seg_a		ends



		end	start
