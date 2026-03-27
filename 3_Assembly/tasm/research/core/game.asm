
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


; External references - addresses in other loaded segments

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
; zeliad loads game.bin at this offset in the game segment.
; Using GAME_CODE_BASE + (offset label) makes these auto-update
; when code is added or removed above each label.
GAME_CODE_BASE  equ     0A000h
gfx_mode_tbl_ega equ	GAME_CODE_BASE + (offset gfx_mode_tbl_ega_lbl)
gfx_mode_tbl_cga equ	GAME_CODE_BASE + (offset gfx_mode_tbl_cga_lbl)
gfx_mode_tbl_all equ	GAME_CODE_BASE + (offset gfx_mode_tbl_all_lbl)
level_system_ref equ	GAME_CODE_BASE + (offset level_system_ref_lbl)
level_data_ref	equ	GAME_CODE_BASE + (offset level_data_ref_lbl)
palette_base_tbl equ	GAME_CODE_BASE + (offset palette_base_tbl_lbl)
game_init_fn	equ	GAME_CODE_BASE + (offset game_init_fn_lbl)
save_mode_flag	equ	GAME_CODE_BASE + (offset save_mode_flag_lbl)
level_chunk_ref	equ	GAME_CODE_BASE + (offset save_mode_flag_lbl)
save_data_base	equ	0C000h			; Save data load address

; Game state variables (0xFF00+ range, shared with zeliad.exe)
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

		; Call loaded chunk initialization
		call	word ptr cs:[120h]

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
		db	 00h
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
		db	 00h
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
		db	 00h
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
		db	0C3h,0C3h
game_init_fn_lbl	label	dword
		db	 00h, 00h, 00h, 30h
save_mode_flag_lbl	label	word
		db	 00h, 00h

seg_a		ends



		end	start
