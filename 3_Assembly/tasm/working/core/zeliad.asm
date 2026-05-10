
PAGE  59,132

;==========================================================================
;
;  ZELIAD.EXE - Main Executable Loader
;
;  Reads RESOURCE.CFG, loads graphics/input/music drivers,
;  initializes game state, sets video mode, then jumps to game.bin
;
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;  Connections:
;    Loads:        stdply.bin (player config, game_seg:0x0000) or save file,
;                  stick.bin (input driver, game_seg:0x0100),
;                  gm{ega,cga,hgc,tga,mcga}.bin (graphics-mode driver per
;                  RESOURCE.CFG, game_seg:driver_offset_table[mode]),
;                  music driver (.bin, e.g. mt32/sblaster/adlib music engine),
;                  joystick driver, then game.bin at game_seg:0xA000
;    Calls into:   game.bin entry (jmp dword ptr cs:game_entry_ofs),
;                  video_mode_table[bx] for INT 10h video-mode setup,
;                  zeliad_callback (own SAR chunk loader exposed via
;                  gvar_chunk_load_fn / gvar_chunk_load_seg)
;    Called by:    DOS COMMAND.COM (program entry, MZ exe)
;    Reads/writes: gvar_* family at FF00-FF7B (input/gfx fn ptrs, timer,
;                  game phase, save state, music, joystick) - the canonical
;                  owner of these globals; drivers + game.bin consume them
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zeliard.inc

; Prologue used by the per-line CFG parsers (parse_graphics_mode, etc.):
; ES = CS, locate the colon separator in the current line buffer, then
; reduce CX so it counts the chars BEFORE the colon. 4 sites, all four
; CFG parsers use this exact preroll.
setup_parse_line	MACRO
		push	cs
		pop	es
		call	find_colon_in_line
		dec	cx
		ENDM

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_chunk_load_fn	equ	0FF00h		; Chunk loader function pointer
gvar_chunk_load_seg	equ	0FF02h		; Chunk loader code segment
gvar_old_int08_ofs	equ	0FF04h		; Saved INT 08h offset
gvar_old_int08_seg	equ	0FF06h		; Saved INT 08h segment
gvar_timer_ticks	equ	0FF08h		; Timer tick counter (byte)
gvar_key_released	equ	0FF09h		; Key released flag
gvar_last_key		equ	0FF0Ah		; Last key scancode
gvar_key_state		equ	0FF0Bh		; Current key state
gvar_input_fn_ofs	equ	0FF0Ch		; Input handler function offset
gvar_input_fn_seg	equ	0FF0Eh		; Input handler function segment
gvar_gfx_fn_ofs		equ	0FF10h		; Graphics handler function offset
gvar_gfx_fn_seg		equ	0FF12h		; Graphics handler function segment
gvar_gfx_mode		equ	0FF14h		; Graphics/display mode
gvar_game_phase		equ	0FF15h		; Game phase/state
gvar_skip_flag		equ	0FF16h		; Skip flag
gvar_timer_flag		equ	0FF17h		; Timer flag
gvar_timer_counter	equ	0FF18h		; Timer counter
gvar_spacebar_state		equ	0FF1Dh		; Input skip flag
gvar_state_a		equ	0FF1Dh		; Game state variable A
gvar_state_b		equ	0FF1Eh		; Game state variable B
gvar_state_c		equ	0FF1Fh		; Game state variable C
gvar_enable_all		equ	0FF26h		; Enable all flag (0xFF=enabled)
gvar_sound_flag		equ	0FF27h		; Sound enabled flag
gvar_key_pressed	equ	0FF28h		; Key pressed scancode
gvar_game_seg		equ	0FF2Ch		; Game data segment
gvar_save_filename	equ	0FF33h		; Save file name (8 bytes)
gvar_save_flag		equ	0FF33h		; Save file flag
; FF38..FF3A: misnamed gvar_music_flag_a/b/c in earlier sweeps.  All 5
; gf*.asm graphics drivers gate sprite rendering on these bytes; they are
; PLAYER POSE STATE flags, not music state.  zeliad.asm only zero-clears
; them at boot.
flag_shield	equ	0FF38h		; shield-up render flag (5 gf*.asm)
gvar_music_flag_a	equ	0FF38h		; alias — earlier name
flag_climbing	equ	0FF39h		; climbing-pose render flag (5 gf*.asm)
gvar_music_flag_b	equ	0FF39h		; alias — earlier name
flag_riding	equ	0FF3Ah		; riding-pose render flag (5 gf*.asm)
gvar_music_flag_c	equ	0FF3Ah		; alias — earlier name
gvar_music_flag_d	equ	0FF3Bh		; Music state D (TBD)
gvar_palette_flag	equ	0FF3Ch		; Palette state
gvar_debug_mode		equ	0FF40h		; Debug mode flag (TBD; zeliard.inc canonical, but see 200FIGHT — likely flag_hero_state)
gvar_debug_val		equ	0FF42h		; Debug value
; FF43: misnamed gvar_joystick_flag.  All 5 gf*.asm drivers test it as
; scroll_active; zeliad.asm only zero-clears at boot.
scroll_active	equ	0FF43h		; scroll/transition active gate (5 gf*.asm)
gvar_joystick_flag equ	0FF43h		; alias — earlier name
gvar_save_name_buf	equ	0FF6Ch		; Save file name buffer (8 bytes)
gvar_input_lock		equ	0FF74h		; Input-mode lock (canonical zeliard.inc); zero-init only here
gvar_volume_b		equ	0FF75h		; Volume/audio setting B
gvar_disk_swap_suppressed equ	0FF78h	; alias matching zeliard.inc canonical
gvar_old_int09_ofs	equ	0FF79h		; Saved INT 09h offset
gvar_old_int09_seg	equ	0FF7Bh		; Saved INT 09h segment

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
; Driver entry-point offsets within the music driver segment (CS + 0xFF0h)
stick_input_fn_ofs	equ	100h		; stick.bin input handler entry point
stdply_gfx_fn_ofs	equ	1100h		; stdply.bin graphics handler entry point

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
PSP_cmd_size		equ	80h
PSP_cmd_line		equ	81h
zero_offset		equ	0

seg_a		segment	byte public
		assume cs:seg_a  , ds:seg_a , ss:stack_seg_b

;==========================================================================
;
;  Program Entry Point
;
;  1. Check DOS version >= 2.0
;  2. Parse RESOURCE.CFG (graphics mode, music driver, joystick, options)
;  3. Allocate memory, load driver files
;  4. Initialize game state variables
;  5. Set video mode
;  6. Jump to game.bin entry point
;
;==========================================================================

run_zeliad_main		proc	far

start:
		cld
		mov	ah,30h
		int	21h			; Get DOS version
		cmp	al,2
		jae	dos_version_ok
		int	20h			; Exit if DOS < 2.0

dos_version_ok:
		mov	ax,seg_a
		mov	ds,ax
		call	parse_command_line
		mov	dx,offset cfg_filename	; 'RESOURCE.CFG'
		mov	ax,3D00h
		int	21h			; Open RESOURCE.CFG for reading
		jnc	cfg_opened
		call	display_file_error
		mov	ax,4C00h
		int	21h			; Exit on error

cfg_opened:
		mov	bx,ax			; BX = file handle
		call	read_config_line	; Read line 1: graphics mode
		jnc	cfg_gfx_line_read
		jmp	cfg_error

cfg_gfx_line_read:
		call	parse_graphics_mode
		call	read_config_line	; Read line 2: music driver
		jnc	cfg_music_line_read
		jmp	cfg_error

cfg_music_line_read:
		call	parse_music_driver
		call	read_config_line	; Read line 3: joystick driver
		jnc	cfg_joy_line_read
		jmp	cfg_error

cfg_joy_line_read:
		call	parse_joystick_name
		call	read_config_line	; Read line 4: joystick enable
		jnc	cfg_joyenable_line_read
		jmp	cfg_error

cfg_joyenable_line_read:
		call	parse_joystick_enable	; Does not return on error
		mov	ah, 3Eh
		int	21h			; Close RESOURCE.CFG (BX = handle)
		mov	bx, 4000h		; Request 256KB (0x4000 paragraphs)
		mov	ah, 48h
		int	21h			; DOS: allocate memory block
		jnb	memory_allocated	; Success ?-> continue
		cmp	ax, 8			; Error 8 = not enough memory
		jnz	memory_error		; Other error ?-> generic handler
		mov	dx, offset str_not_enough_mem
		mov	ah, 9
		int	21h			; Print "Not enough memory..."
		mov	ax, 4C00h
		int	21h			; Exit to DOS

memory_error:
		mov	dx,offset str_memory_error
		mov	ah,9
		int	21h			; Display "Memory error !!!"
		mov	ax,4C00h
		int	21h			; Exit

memory_allocated:
		mov	word ptr game_entry_seg,ax
		call	flush_keyboard
		mov	dx,offset str_game_title
		mov	ah,9
		int	21h			; Display game title/copyright

		; Initialize music system if enabled
		test	byte ptr cs:mt32_enabled,0FFh
		jz	skip_music_init
		mov	cs:saved_sp,sp
		mov	cs:saved_ss,ss
		mov	di,offset mtinit_filename - 2
		mov	dx,offset mtinit_filename
		mov	bx,offset exec_param_block
		mov	ax,4B00h
		int	21h			; EXEC MTINIT.COM (music init)
		cli
		mov	sp,cs:saved_sp
		mov	ss,cs:saved_ss
		sti
		jnc	skip_music_init
		call	display_file_error
		mov	ax,4C00h
		int	21h			; Exit on music init error

skip_music_init:
		; Save original interrupt vectors
		mov	ax,3508h
		int	21h			; Get INT 08h (timer)
		mov	saved_int08_ofs,bx
		mov	word ptr saved_int08_ofs+2,es
		mov	ax,3509h
		int	21h			; Get INT 09h (keyboard)
		mov	saved_int09_ofs,bx
		mov	word ptr saved_int09_ofs+2,es
		mov	ax,3560h
		int	21h			; Get INT 60h (game use)
		mov	saved_int60_ofs,bx
		mov	word ptr saved_int60_ofs+2,es
		mov	ax,3561h
		int	21h			; Get INT 61h (game use)
		mov	saved_int61_ofs,bx
		mov	saved_int61_seg,es

		; Initialize game state variables in game.bin segment
		mov	es,word ptr cs:game_entry_seg
		mov	word ptr es:gvar_chunk_load_fn,zeliad_callback_ofs
		mov	es:gvar_chunk_load_seg,cs
		lds	dx,dword ptr cs:saved_int08_ofs
		mov	es:gvar_old_int08_ofs,dx
		mov	es:gvar_old_int08_seg,ds
		lds	dx,dword ptr cs:saved_int09_ofs
		mov	es:gvar_old_int09_ofs,dx
		mov	es:gvar_old_int09_seg,ds
		mov	byte ptr es:gvar_skip_flag,0
		mov	byte ptr es:gvar_timer_flag,0
		mov	word ptr es:gvar_timer_counter,0
		mov	byte ptr es:gvar_spacebar_state,0
		mov	byte ptr es:gvar_state_b,0
		mov	word ptr es:gvar_state_c,0
		mov	byte ptr es:gvar_enable_all,0FFh
		mov	byte ptr es:gvar_key_released,0FFh
		mov	byte ptr es:gvar_sound_flag,0
		mov	byte ptr es:gvar_key_pressed,0
		mov	byte ptr es:gvar_key_state,0
		mov	byte ptr es:gvar_timer_ticks,0
		mov	byte ptr es:gvar_volume_b,0
		mov	byte ptr es:gvar_save_flag,5
		mov	byte ptr es:gvar_save_flag+1,0
		mov	byte ptr es:flag_shield,0
		mov	byte ptr es:flag_climbing,0
		mov	byte ptr es:flag_riding,0
		mov	byte ptr es:scroll_active,0
		mov	byte ptr es:gvar_palette_flag,0
		mov	byte ptr es:gvar_music_flag_d,0
		mov	byte ptr es:gvar_input_lock,0
		mov	byte ptr es:gvar_debug_mode,0
		mov	byte ptr es:gvar_debug_val,0
		mov	byte ptr es:gvar_disk_swap_suppressed,0
		mov	al,cs:joystick_enabled
		mov	es:gvar_last_key,al
		mov	al,cs:mt32_enabled
		mov	es:gvar_game_phase,al

		; Copy save filename to game state
		mov	di,gvar_save_name_buf
		xor	al,al
		mov	cx,8
		rep	stosb			; Clear save name buffer
		push	cs
		pop	ds
		mov	si,offset cmdline_savefile
		mov	di,gvar_save_name_buf
		mov	cx,8

copy_save_name:
				lodsb
				cmp	al,2Eh			; '.'
				je	save_name_done
				cmp	al,61h			; 'a'
				jb	not_lowercase
				cmp	al,7Bh			; '{'
				jae	not_lowercase
				and	al,5Fh			; Convert to uppercase

not_lowercase:
				stosb
				loop	copy_save_name

save_name_done:
		mov	al,cs:graphics_mode
		mov	es:gvar_gfx_mode,al
		mov	ax,word ptr cs:game_entry_seg
		add	ax,1000h
		mov	es:gvar_game_seg,ax

		; Load driver files into memory
		push	cs
		pop	ds
		mov	es,word ptr cs:game_entry_seg

		; Load player config (stdply.bin or save file) at game_entry_seg:0000h
		mov	di,offset entry_stdply_nosave
		test	byte ptr has_savefile,0FFh
		jz	load_gfx_driver
		mov	di,offset cmdline_savefile

load_gfx_driver:
		call	load_driver_file

		; Load input driver (stick.bin)
		mov	es,word ptr cs:game_entry_seg
		mov	di,offset entry_stick
		call	load_driver_file

		; Load game data (game.bin)
		mov	es,word ptr cs:game_entry_seg
		mov	di,offset entry_game
		call	load_driver_file

		; Load graphics mode driver (gm*.bin) at offset from driver_offset_table
		mov	es,word ptr cs:game_entry_seg
		xor	bx,bx
		mov	bl,graphics_mode
		add	bx,bx
		mov	di,driver_offset_table[bx]
		call	load_driver_file

		; Load music interrupt handler
		mov	ax,word ptr cs:game_entry_seg
		add	ax,0FF0h
		mov	es,ax
		mov	di,offset music_driver_name
		call	load_driver_file

		; Load secondary music handler
		mov	ax,word ptr cs:game_entry_seg
		add	ax,0FF0h
		mov	es,ax
		mov	di,offset joystick_driver_name
		call	load_driver_file

		; Install interrupt handlers
		cli
		push	cs
		pop	ds
		mov	dx,offset ctrl_c_handler
		mov	ax,2523h
		int	21h			; Set INT 23h (Ctrl+C = ignore)

		mov	ds,word ptr cs:game_entry_seg
		mov	dx,isr_timer			; stick.bin timer stub
		mov	ax,2508h
		int	21h			; Set INT 08h (timer handler)
		mov	dx,isr_keyboard			; stick.bin keyboard stub
		mov	ax,2509h
		int	21h			; Set INT 09h (keyboard handler)
		mov	dx,isr_critical			; stick.bin critical-error stub
		mov	ax,2524h
		int	21h			; Set INT 24h (critical error)
		mov	dx,isr_music			; stick.bin music stub
		mov	ax,2561h
		int	21h			; Set INT 61h (music handler)

		; Set up function pointers in game state
		mov	ax,word ptr cs:game_entry_seg
		mov	es,ax
		add	ax,0FF0h
		mov	ds,ax
		mov	word ptr es:gvar_input_fn_ofs,stick_input_fn_ofs
		mov	es:gvar_input_fn_seg,ds
		mov	word ptr es:gvar_gfx_fn_ofs,stdply_gfx_fn_ofs
		mov	es:gvar_gfx_fn_seg,ds
		mov	dx,isr_timer			; stick.bin game-services stub
		mov	ax,2560h
		int	21h			; Set INT 60h (game services)

		; Set timer to ~65.5 Hz (18.2 Hz * 3.6 = game tick rate)
		mov	al,36h
		out	43h,al			; 8253 timer control
		mov	al,0B1h
		out	40h,al			; Timer 0 low byte
		mov	al,13h
		out	40h,al			; Timer 0 high byte (0x13B1 = 5041)
		sti

		; Set video mode and jump to game
		call	set_video_mode
		mov	al,cs:has_savefile
		cbw
		jmp	dword ptr cs:game_entry_ofs	; Jump to game.bin!

		;--- Return from game ---
		                        ;* No entry point to code
		push	ax
		mov	ax,2
		int	10h			; Reset video mode (text 80x25)
		mov	ax,2
		int	10h
		call	flush_keyboard
		mov	ax,1
		int	60h			; Shutdown game services
		pop	ax

		; Display exit message based on return code
		or	ax,ax
		jnz	check_exit_error
		push	cs
		pop	ds
		mov	dx,offset str_thank_you
		mov	ah,9
		int	21h			; "Thank you for playing."
		jmp	short cleanup_and_exit

check_exit_error:
		cmp	ax,0FFFFh
		jne	check_disk_error
		push	cs
		pop	ds
		mov	dx,offset str_user_file_error
		mov	ah,9
		int	21h			; "USER file nothing."
		jmp	short cleanup_and_exit

check_disk_error:
		push	ds
		push	dx
		mov	dx,offset str_file_not_found
		cmp	ax,2
		je	show_error_filename
		mov	dx,offset str_disk_error

show_error_filename:
		push	cs
		pop	ds
		mov	ah,9
		int	21h
		mov	dl,20h
		mov	ah,2
		int	21h			; Display space
		mov	dl,3Ah
		mov	ah,2
		int	21h			; Display colon
		mov	dl,20h
		mov	ah,2
		int	21h			; Display space
		pop	di
		pop	ds

print_error_name:
				mov	dl,[di]
				or	dl,dl
				jz	cleanup_and_exit
				mov	ah,2
				int	21h
				inc	di
				jmp	short print_error_name

cleanup_and_exit:
		; Restore original interrupt vectors
		cli
		lds	dx,dword ptr cs:saved_int08_ofs
		mov	ax,2508h
		int	21h			; Restore INT 08h
		lds	dx,dword ptr cs:saved_int09_ofs
		mov	ax,2509h
		int	21h			; Restore INT 09h
		lds	dx,dword ptr cs:saved_int60_ofs
		mov	ax,2560h
		int	21h			; Restore INT 60h

		; Restore standard timer rate
		mov	al,36h
		out	43h,al
		xor	al,al
		out	40h,al			; Timer 0 = 0x0000 (65536 = 18.2 Hz)
		out	40h,al
		sti

		; Free game memory and exit
		mov	ax,seg_a
		mov	ds,ax
		mov	es,word ptr game_entry_seg
		mov	ah,49h
		int	21h			; Free memory block
		jnc	exit_program
		mov	dx,offset str_memory_error
		mov	ah,9
		int	21h

exit_program:
		mov	ax,4C00h
		int	21h			; Exit to DOS

run_zeliad_main		endp

;==========================================================================
;  flush_keyboard - Drain all pending keystrokes from keyboard buffer
;==========================================================================

flush_keyboard	proc	near
		push	dx

flush_loop:
				mov	dl,0FFh
				mov	ah,6
				int	21h			; Direct console I/O (check key)
				jnz	flush_loop		; Loop while keys available
		pop	dx
		retn

flush_keyboard	endp

;==========================================================================
;  read_config_line - Read one line from RESOURCE.CFG
;  Input:  BX = file handle
;  Output: CF=1 if EOF, CF=0 if line read
;          DS:SI points to parsed content, CX = length
;==========================================================================

read_config_line proc	near
		push	cs
		pop	ds
		mov	dx,offset cfg_line_buffer
		mov	byte ptr cfg_line_length,0

skip_whitespace:
				mov	cx,1
				mov	ah,3Fh
				int	21h			; Read 1 byte
				or	ax,ax
				stc				; Set CF (EOF)
				jnz	got_char
				retn

got_char:
				mov	si,dx
				cmp	byte ptr [si],20h	; Skip control chars
				jb	skip_whitespace

read_next_char:
				inc	cfg_line_length
				or	byte ptr [si],20h	; Force lowercase
				inc	dx

read_more:
						mov	cx,1
						mov	ah,3Fh
						int	21h			; Read 1 byte
						or	ax,ax
						jz	line_done
						mov	si,dx
						cmp	byte ptr [si],20h	; Space = separator
						je	read_more		; Skip spaces
				jnc	read_next_char		; Continue if printable

line_done:
		clc				; Clear CF (success)
		retn

read_config_line endp

;==========================================================================
;  parse_graphics_mode - Parse graphics adapter name from config
;  Matches: ega, cga, hgc, mcga, tga (3 or 4 char names)
;  Sets graphics_mode to 0-5
;==========================================================================

parse_graphics_mode proc near
		setup_parse_line
		cmp	cx,3
		je	try_3char_modes
		cmp	cx,4
		je	try_4char_modes
		jmp	cfg_error

try_4char_modes:
		mov	di,offset mode_4char_table
		mov	cx,2

match_4char_loop:
				push	cx
				push	si
				push	di
				mov	cx,4
				repe	cmpsb
				pop	di
				pop	si
				pop	cx
				jz	found_4char_mode
				add	di,5
				loop	match_4char_loop
		jmp	cfg_error

found_4char_mode:
		add	di,4
		mov	al,es:[di]
		mov	graphics_mode,al
		retn

try_3char_modes:
		mov	di,offset mode_3char_table
		mov	cx,4

match_3char_loop:
				push	cx
				push	si
				push	di
				mov	cx,3
				repe	cmpsb
				pop	di
				pop	si
				pop	cx
				jz	found_3char_mode
				add	di,4
				loop	match_3char_loop
		jmp	cfg_error

found_3char_mode:
		add	di,3
		mov	al,es:[di]
		mov	graphics_mode,al
		retn

parse_graphics_mode endp

; Mode lookup tables: 4 or 3 ASCII name bytes followed by mode index byte
mode_4char_table db	'cga2', 02h	; CGA 2-color ?-> mode 2
		db	'mcga', 04h	; MCGA        ?-> mode 4
mode_3char_table db	'cga',  01h	; CGA         ?-> mode 1
		db	'ega',  00h	; EGA         ?-> mode 0
		db	'hgc',  03h	; HGC         ?-> mode 3
		db	'tga',  05h	; TGA         ?-> mode 5

;==========================================================================
;  parse_music_driver - Parse music driver name from config line
;  If name matches "mscmt.drv" (the MT-32 driver), sets mt32_enabled=0xFF
;  to gate MTINIT.COM exec + propagate to gvar_game_phase.
;==========================================================================

parse_music_driver proc	near
		mov	byte ptr cs:mt32_enabled,0
		setup_parse_line
		cmp	cx,0Fh
		jb	music_name_clamped
		mov	cx,0Fh

music_name_clamped:
		mov	di,offset music_driver_name
		rep	movsb
		xor	al,al
		stosb				; Null-terminate
		mov	di,offset music_driver_name
		mov	si,offset str_mscmt_drv
		mov	cx,9
		repe	cmpsb
		jz	music_is_mt32
		retn

music_is_mt32:
		mov	byte ptr mt32_enabled,0FFh
		retn

parse_music_driver endp

str_mscmt_drv	db	'mscmt.drv'

;==========================================================================
;  parse_joystick_name - Parse joystick driver name from config
;==========================================================================

parse_joystick_name proc near
		setup_parse_line
		cmp	cx,0Fh
		jb	joy_name_clamped
		mov	cx,0Fh

joy_name_clamped:
		mov	di,offset joystick_driver_name
		rep	movsb
		xor	al,al
		stosb				; Null-terminate
		retn

parse_joystick_name endp

;==========================================================================
;  parse_joystick_enable - Parse "yes"/"no" from config
;  Sets joystick_enabled flag. Jumps to cfg_error on bad input.
;==========================================================================

parse_joystick_enable proc near
		setup_parse_line
		cmp	cx,2
		je	try_match_no
		cmp	cx,3
		jne	cfg_error
		mov	di,offset str_yes
		mov	cx,3
		repe	cmpsb
		jnz	cfg_error
		mov	byte ptr cs:joystick_enabled,0FFh
		retn

try_match_no:
		mov	di,offset str_no
		mov	cx,2
		repe	cmpsb
		jnz	cfg_error
		mov	byte ptr cs:joystick_enabled,0
		retn

parse_joystick_enable endp

str_yes		db	'yes'
str_no		db	'no'

cfg_error:
				mov	ah,3Eh
				int	21h			; Close file
				mov	dx,offset str_cfg_error
				mov	ah,9
				int	21h			; "Error in RESOURCE.CFG"
				mov	ax,4C00h
				int	21h			; Exit

;==========================================================================
;  find_colon_in_line - Find ':' delimiter in config line buffer
;  Output: DS:SI points after colon, CX = remaining length
;==========================================================================

find_colon_in_line proc	near
				push	cs
				pop	ds
				mov	si,offset cfg_line_buffer
				xor	cx,cx
				mov	cl,cfg_line_length

scan_for_colon:
						lodsb
						cmp	al,3Ah			; ':'
						jne	next_colon_char
						retn

next_colon_char:
						loop	scan_for_colon
				jmp	short cfg_error

find_colon_in_line endp

;==========================================================================
;  load_driver_file - Load a binary file into memory at ES:DI
;  Input:  ES:DI points to {offset_word, filename_string}
;  Output: File contents loaded at ES:[offset]
;==========================================================================

load_driver_file proc	near
		push	ds
		push	es
		push	di
		mov	dx,di
		add	dx,2			; Skip past offset word to filename
		mov	ax,3D00h
		int	21h			; Open file for reading
		jc	driver_load_error
		mov	bx,ax
		mov	dx,[di]			; Get load offset
		mov	cx,0FFFFh
		push	es
		pop	ds
		mov	ah,3Fh
		int	21h			; Read entire file
		jc	driver_load_error
		mov	ah,3Eh
		int	21h			; Close file
		jc	driver_load_error
		pop	di
		pop	es
		pop	ds
		retn

driver_load_error:
		pop	di
		pop	es
		pop	ds
		call	display_file_error
		jmp	cleanup_and_exit

load_driver_file endp

;==========================================================================
;  display_file_error - Show "File Error from <filename>" message
;  Input:  ES:DI = pointer to file entry (offset + name)
;          AX = DOS error code
;==========================================================================

display_file_error proc	near
		push	ds
		push	es
		push	di
		push	cs
		pop	ds
		push	ax
		mov	dx,offset str_file_error
		mov	ah,9
		int	21h			; "File Error from "
		pop	ax
		pop	di
		pop	es
		pop	ds
		push	ax
		add	di,2			; Skip to filename

print_filename:
				mov	dl,[di]
				or	dl,dl
				jz	show_error_code
				mov	ah,2
				int	21h
				inc	di
				jmp	short print_filename

show_error_code:
		pop	bx			; BX = error code
		push	cs
		pop	ds
		mov	dx,offset str_error_type
		mov	ah,9
		int	21h			; "     Error Type : "
		mov	dx,offset str_file_not_found
		cmp	bx,2
		je	show_error_string
		mov	dx,offset str_disk_error
		cmp	bx,5
		je	show_error_string
		shl	bx,1
		mov	dl,hex_digits_hi[bx]
		mov	ah,2
		int	21h
		mov	dl,byte ptr hex_digits_lo[bx]
		mov	ah,2
		int	21h
		mov	dl,48h			; 'H'
		mov	ah,2
		int	21h
		retn

show_error_string:
		mov	ah,9
		int	21h
		retn

display_file_error endp

;==========================================================================
;  set_video_mode - Initialize video hardware for selected graphics mode
;  Uses graphics_mode index to select: EGA/CGA/HGC/MCGA/TGA
;==========================================================================

set_video_mode	proc	near
		mov	bl,cs:graphics_mode
		xor	bh,bh
		add	bx,bx
		jmp	word ptr cs:video_mode_table[bx]

video_mode_table dw	offset set_mode_ega
		dw	offset set_mode_cga
		dw	offset set_mode_cga2
		dw	offset set_mode_hgc
		dw	offset set_mode_mcga
		dw	offset set_mode_tga

set_mode_ega:
		mov	ax,0Eh			; EGA 640x200 16-color
		int	10h
		retn

set_mode_cga:
		mov	ax,5			; CGA 320x200 4-color
		int	10h
		retn

set_mode_cga2:
		mov	ax,6			; CGA 640x200 2-color
		int	10h
		retn

set_mode_mcga:
		mov	ax,13h			; MCGA/VGA 320x200 256-color
		int	10h
		retn

set_mode_tga:
		mov	ax,9			; Tandy 320x200 16-color
		int	10h
		retn

set_mode_hgc:
		; Hercules graphics mode setup
		push	cs
		pop	ds
		mov	dx,3B8h
		mov	al,2
		out	dx,al			; MDA video control
		mov	dx,3BFh
		mov	al,1
		out	dx,al			; Hercules config register
		mov	cx,0Ch
		mov	ah,0
		mov	si,offset hgc_crt_params
		mov	dx,3B4h

hgc_init_loop:
				mov	al,ah
				out	dx,al			; CRT register index
				lodsb
				inc	dx
				out	dx,al			; CRT register data
				dec	dx
				inc	ah
				loop	hgc_init_loop

		mov	al,2Ah
		mov	dx,3B8h
		out	dx,al			; Enable graphics mode
		mov	ax,0B000h
		mov	es,ax
		mov	di,zero_offset
		xor	ax,ax
		mov	cx,4000h
		rep	stosw			; Clear video memory
		retn

set_video_mode	endp

hgc_crt_params	db	35h, 2Dh, 2Eh, 07h, 5Bh, 02h	; HGC CRTC regs 0-5
		db	57h, 57h, 02h, 03h, 00h, 00h	; HGC CRTC regs 6-11

;==========================================================================
;  ctrl_c_handler - INT 23h handler (ignores Ctrl+C)
;==========================================================================

ctrl_c_handler	proc	far
		iret

ctrl_c_handler	endp

;==========================================================================
;  parse_command_line - Check PSP for command-line save file name
;  If found, appends ".USR" extension and sets has_savefile flag
;==========================================================================

parse_command_line proc	near
		test	byte ptr es:PSP_cmd_size,0FFh
		jnz	has_args
		retn

has_args:
		mov	di,offset cmdline_savefile
		xor	cx,cx
		mov	cl,es:PSP_cmd_size
		mov	si,PSP_cmd_line

skip_leading_spaces:
				cmp	byte ptr es:[si],20h
				jne	found_arg_start
				inc	si
				loop	skip_leading_spaces
		retn

found_arg_start:
		xor	ah,ah			; Flag: found non-space char

copy_arg_chars:
				mov	al,es:[si]
				cmp	al,20h			; Space = end
				je	next_arg_char
				cmp	al,0Dh			; CR = end
				je	next_arg_char
				mov	ah,0FFh			; Mark as having content
				mov	[di],al
				inc	di

next_arg_char:
				inc	si
				loop	copy_arg_chars

		or	ah,ah
		jnz	set_savefile_flag
		retn

set_savefile_flag:
		mov	byte ptr has_savefile,0FFh
		mov	byte ptr [di],2Eh	; '.'
		mov	byte ptr [di+1],55h	; 'U'
		mov	byte ptr [di+2],53h	; 'S'
		mov	byte ptr [di+3],52h	; 'R'
		mov	byte ptr [di+4],0
		retn

parse_command_line endp

;==========================================================================
;  String Constants
;==========================================================================

str_game_title	db	'The Fantasy Action Game ZELIARD '
		db	'Version 1.208', 0Dh, 0Ah, 'Copyr'
		db	'ight (C) 1987 ~ 1990 Game Arts C'
		db	'o.,Ltd.', 0Dh, 0Ah, 'Copyright ('
		db	'C) 1990 Sierra On-Line, Inc.', 0Dh
		db	0Ah, '$'
str_not_supported	db	'Not supported command !', 0Dh, 0Ah, '$'
str_special_mode	db	'Special mode !!', 0Dh, 0Ah, '$'
str_not_enough_mem db	'Not enough memory to run ', 27h, 'Z'
		db	'ELIARD', 27h, '.', 0Dh, 0Ah, '$'
str_memory_error db	'Memory error !!!', 0Dh, 0Ah, '$'
str_thank_you	db	'Thank you for playing.', 0Dh, 0Ah
		db	'$'
str_file_error	db	'File Error from $'
str_error_type	db	'     Error Type : $'
str_file_not_found db	'File not found.$'
str_disk_error	db	'DISK read Error!!$'
str_user_file_error db	'USER file nothing.$'
str_cfg_error	db	'Error in RESOURCE.CFG', 0Dh, 0Ah
		db	'$'

;==========================================================================
;  Data Tables
;==========================================================================

hex_digits_hi	db	30h			; '0'-'F' high nibble
hex_digits_lo	db	'00102030405060708090A0B0C0D0E0F'

cfg_filename	db	'RESOURCE.CFG', 0
mtinit_filename	db	'MTINIT.COM', 0

; Graphics mode driver load offsets (indexed by graphics_mode * 2)
driver_offset_table dw	0812h		; mode 0: EGA  (gmega.bin)
		dw	081Eh		; mode 1: CGA  (gmcga.bin)
		dw	081Eh		; mode 2: CGA 2-color (shared with CGA)
		dw	082Ah		; mode 3: HGC  (gmhgc.bin)
		dw	0836h		; mode 4: MCGA (gmmcga.bin)
		dw	0843h		; mode 5: TGA  (gmtga.bin)
; Driver file entries: [dw load_ofs][filename\0]
; Load offset bytes interleave: each entry's trailing null = next entry's load_ofs low byte,
; and the next entry's leading ' ' = load_ofs high byte (0x20 ?-> 0x2000).
; The dw 0100h is BOTH driver_offset_table[6] AND stick.bin's load_ofs word.

entry_stick:
		dw	0100h		; DUAL-USE: table[6] AND stick.bin load offset (CS:0100h)
		db	'stick.bin'
		db	0, 0		; null + gmega load_ofs low (0x00)
		db	' gmega.bin'	; ' '=load_ofs high (0x20 ?-> 0x2000)
		db	0, 0	; row 0
		db	' gmcga.bin'
		db	0, 0	; row 1
		db	' gmhgc.bin'
		db	0, 0	; row 2
		db	' gmmcga.bin'
		db	0, 0	; row 3
		db	' gmtga.bin'
		db	0		; gmtga null

entry_game:
		db	0, 0A0h		; game.bin load_ofs (0xA000: lo=00 hi=A0)
		db	'game.bin'
		db	0		; game.bin null

entry_stdply_nosave:
		db	0, 0		; stdply load_ofs (0x0000)
		db	'stdply.bin'
		db	0, 0, 0		; null + 2 trailing bytes (empty entry area)

;==========================================================================
;  Runtime Variables
;==========================================================================

cmdline_savefile db	0			; Command-line save file name
		db	32 dup (0)
		db	1	; row 0
music_driver_name db	0			; Music driver filename
		db	16 dup (0)
		db	11h	; row 0
joystick_driver_name db	0			; Joystick driver filename
		db	15 dup (0)

game_entry_ofs	dw	0A000h			; Game entry point offset
game_entry_seg	dw	0			; Game entry point segment

saved_int08_ofs	dw	0, 0			; Original INT 08h vector
saved_int09_ofs	dw	0, 0			; Original INT 09h vector
saved_int60_ofs	dw	0, 0			; Original INT 60h vector
saved_int61_ofs	dw	0			; Original INT 61h offset
saved_int61_seg	dw	0			; Original INT 61h segment

has_savefile	db	0			; 0xFF if command-line save file
saved_sp	dw	0			; Saved SP for EXEC
saved_ss	dw	0			; Saved SS for EXEC

; DOS EXEC parameter block (INT 21h fn 4Bh)

exec_param_block:
		dw	0			; environment segment (0 = inherit)
		dw	offset exec_cmdline	; command line offset
		dw	seg_a			; command line segment
		dw	offset exec_fcb1	; FCB1 offset
		dw	seg_a			; FCB1 segment
		dw	offset exec_fcb1	; FCB2 offset (same block)
		dw	seg_a			; FCB2 segment

exec_cmdline:
		db	01h, ' ', 0Dh		; cmd: length=1, ' ', CR (blank args)

exec_fcb1:
		db	0, ' '			; FCB preamble
		db	14 dup (0)		; FCB data (blank)

graphics_mode	db	0			; 0=EGA 1=CGA 2=CGA2 3=HGC 4=MCGA 5=TGA
mt32_enabled	db	0			; 0xFF when configured driver is "mscmt.drv".
						; Two uses:
						; (1) gates the MTINIT.COM EXEC at startup (line ~209);
						; (2) propagates to gvar_game_phase (line 276) so game
						;     code can branch on MT-32 vs other music backends.
						; Was misnamed "mt32_enabled" — non-MT-32 drivers still
						; load and play music; this flag is MT-32-specific.
joystick_enabled db	0			; 0xFF = joystick enabled
cfg_line_length	db	0			; Current config line length
cfg_line_buffer	db	0			; Config line read buffer
		db	260 dup (0)

seg_a		ends

;------------------------------------------------------  stack_seg_b   ----

stack_seg_b	segment	word stack 'STACK'

		db	8192 dup (?)

stack_seg_b	ends

		end	start
