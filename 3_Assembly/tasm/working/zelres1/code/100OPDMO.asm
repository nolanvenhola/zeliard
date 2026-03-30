
PAGE  59,132

;==========================================================================
;
;  OPENING_SCENE - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Graphics driver function table offsets (in loaded CS segment)
gfx_init_fn		equ	02042h		; graphics initialisation function
gfx_draw_fn		equ	03002h		; graphics draw function
gfx_update_fn		equ	03004h		; graphics update/display function
gfx_mode_fn		equ	03006h		; graphics mode setup function
gfx_palette_fn		equ	03008h		; graphics palette switch (driver_fn4)

; The following equates show data references outside the range of the program.

font_plane_a		equ	660h		; character font data plane A
font_scanline_ofs		equ	819h		; font scanline offset
pixel_mask_a		equ	0D20h		; pixel mask plane A
font_row_ofs		equ	0EE0h		; font row vertical offset
pixel_mask_b		equ	1A40h		; pixel mask plane B
plane_data_a		equ	1D40h		; rendering plane data A
gfx_plane_b		equ	3000h		; graphics plane B buffer (0x3000)
plane_data_b		equ	3A80h		; rendering plane data B
framebuffer_a		equ	4000h		; frame buffer A (0x4000)
temp_decode_buf	equ	46D3h		; temporary decode buffer
framebuffer_b	equ	6000h		; frame buffer B (0x6000)
sprite_buf_a	equ	9C40h		; sprite buffer A
sprite_buf_b	equ	0A9C0h		; sprite buffer B
sprite_buf_c	equ	0AB40h		; sprite buffer C
ext_segment	equ	0D000h		; extended segment (0xD000)
scene_framebuf	equ	4000h		; scene frame buffer (0x4000)
scene_data_a	equ	64EAh		; scene initialisation data A
render_state_a	equ	653Dh		; render state A (word)
render_state_b	equ	653Fh		; render state B (byte, x-advance)
scene_data_b	equ	6A73h		; scene data B
script_pc	equ	6D56h		; script program counter (execution pointer)
text_x_pos	equ	6D58h		; text cursor X position
text_y_pos	equ	6D5Ah		; text cursor Y / layout mode
text_color_fg	equ	6D5Bh		; text foreground color
text_color_bg	equ	6D5Ch		; text background color
text_attr	equ	6D5Dh		; text attribute / speaker style code
ui_overlay_buf	equ	75A0h		; UI overlay buffer
screen_buf_1	equ	8000h		; screen buffer 1 (0x8000)
screen_buf_2	equ	9000h		; screen buffer 2 (0x9000)
scene_sprite_a	equ	9060h		; scene sprite data A
scene_sprite_b	equ	9096h		; scene sprite data B
scene_sprite_c	equ	911Eh		; scene sprite data C
scene_sprite_d	equ	912Bh		; scene sprite data D
char_width_tbl	equ	947Dh		; character width lookup table
char_glyph_tbl	equ	94DDh		; character glyph/font table
palette_data_a	equ	953Dh		; palette data A
palette_data_b	equ	9547h		; palette data B
scene_data_c	equ	9551h		; scene data C
glyph_small	equ	955Dh		; small glyph data
glyph_large	equ	9573h		; large glyph data
scene_data_d	equ	957Eh		; scene data D
scene_data_e	equ	959Fh		; scene data E
scene_data_f	equ	95B4h		; scene data F
scene_data_g	equ	95FEh		; scene data G
scene_data_h	equ	9609h		; scene data H
scene_data_i	equ	97C0h		; scene data I
vga_seg	equ	0A000h		; VGA segment / game data (0xA000)
aux_buf_seg	equ	0B000h		; auxiliary buffer segment (0xB000)
cga_text_seg	equ	0B800h		; CGA text mode VGA segment (0xB800)
ext_seg_d000	equ	0D000h		; extended segment 0xD000
gvar_timer_lo	equ	0FF1Ah		; timer counter low word (0xFF1A)
gvar_skip_input	equ	0FF1Dh		; input skip flag (zeliard.inc: gvar_skip_input)
gvar_state_flag	equ	0FF24h		; game state flag (0xFF24)
gvar_enable_all	equ	0FF26h		; enable all flag (zeliard.inc: gvar_enable_all)
gvar_key_state	equ	0FF29h		; key state (0xFF29)
gvar_game_seg	equ	0FF2Ch		; game data segment (zeliard.inc: gvar_game_seg)
gvar_volume_b	equ	0FF75h		; volume B (zeliard.inc: gvar_volume_b)
null_ofs	equ	0		; null/zero offset
font_plane_b	equ	660h		; character font data plane B
font_plane_c	equ	0CC0h		; character font data plane C

; ── Opening scene script control codes ─────────────────────────────────────
; Used in narration db sequences between text strings.
SCR_END_SCRIPT	equ	0FFh	; end of script / page terminator
SCR_SCROLL	equ	0FEh	; scroll text up (advance display)
SCR_BREAK	equ	0FDh	; section break / return
SCR_BOLD	equ	0FBh	; text style: color 7 bold
SCR_NORMAL	equ	0FAh	; text style: color 7 normal
SCR_COLOR6	equ	0F9h	; text style: color 6
SCR_DIRECT	equ	0F7h	; layout mode 0 (direct write)
SCR_WAIT3	equ	0F6h	; long pause (3x)
SCR_WAIT	equ	0F5h	; pause
SCR_PARA	equ	0F3h	; layout mode 1 (paragraph)
SCR_MODE2	equ	0F2h	; layout mode 2
SCR_MODE3	equ	0F1h	; layout mode 3
SCR_RESET	equ	0F0h	; reset text attribute
SCR_SPK_UNK	equ	0EFh	; speaker: unknown (attr '=')
SCR_SPK_KING	equ	0EEh	; speaker: King Felishika (attr '>')
SCR_SPK_NARR	equ	0EDh	; speaker: narrator / Jashiin (attr '?')
SCR_SPK_DEMON	equ	0ECh	; speaker: Jashiin demon (attr '@')
SCR_SPK_PRINC	equ	0EBh	; speaker: Princess Felicia (attr 'A')
SCR_ATTR_RST	equ	0A0h	; attribute restore
SCR_ATTR_RST2	equ	0A2h	; attribute restore (variant)

; ── Macros ───────────────────────────────────────────────────────────────────

; WAIT_FRAME delay
;   Reset the frame timer and wait for 'delay' timer units.
WAIT_FRAME	MACRO	delay
		mov	byte ptr ds:gvar_timer_lo, 0
		mov	al, delay
		call	timer_wait_loop
		ENDM

; LOAD_DATA src, dst
;   Load a data chunk via the chunk loader (call cs:[10Ch], AL=2).
LOAD_DATA	MACRO	src, dst
		push	cs
		pop	es
		mov	si, src
		mov	di, dst
		mov	al, 2
		call	word ptr cs:[10Ch]
		ENDM

; RESET_STACK
;   Atomically reset SP to 2000h (interrupts disabled during the write).
RESET_STACK	MACRO
		cli
		mov	sp, 2000h
		sti
		ENDM

; GFX_BLIT bx_val, cx_val, di_val
;   Set up registers and call gfx_update_fn.
GFX_BLIT	MACRO	bx_val, cx_val, di_val
		mov	al, 0FFh
		mov	bx, bx_val
		mov	cx, cx_val
		mov	es, cs:gvar_game_seg
		mov	di, di_val
		call	word ptr cs:gfx_update_fn
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

; ============================================================
; INITIALIZATION & SCENE ORCHESTRATION
; Main entry point for the opening demo sequence
; ============================================================

; ============================================================
; INITIALIZATION & SCENE ORCHESTRATION
; Main entry point for the opening demo sequence.
; ============================================================

opening_scene_main		proc	far

start:
		sub	word ptr ds:[0],si
		add	ah,[bx+si-6]
		mov	sp,2000h
		sti				; Enable interrupts
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		push	cs
		pop	ds
		call	word ptr cs:gfx_init_fn
		push	cs
		pop	ds
		LOAD_DATA scene_data_d, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	fill_buffer
		mov	ax,4
		call	word ptr cs:gfx_palette_fn
		xor	bx,bx			; Zero register
		mov	cl,96h
		mov	si,scene_data_a
		call	word ptr cs:narration_stone_scene+0Eh	; ('f ')
		mov	bx,70Fh
		mov	cx,4170h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:gspeech_nt
		LOAD_DATA palette_data_a, vga_seg
		mov	si,palette_data_b
		mov	di,cga_text_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		call	word ptr cs:gfx_init_fn
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	ax,1
		call	word ptr cs:gfx_palette_fn
		mov	al,0FFh
		mov	bx,1220h
		mov	cx,2C68h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:gfx_draw_fn
		call	animate_scanline
		mov	ax,2
		call	word ptr cs:gfx_palette_fn
		GFX_BLIT 1220h, 2C68h, 4000h
		mov	es,cs:gvar_game_seg
		mov	si,cga_text_seg
		mov	di,screen_buf_2
		call	decompress_image
		mov	bx,2048h
		mov	cx,1040h
		mov	es,cs:gvar_game_seg
		mov	di,ui_overlay_buf
		call	word ptr cs:garland_speech
		mov	byte ptr cs:gvar_volume_b,4
		mov	si,scene_sprite_a
		call	word ptr cs:gspeech_yo
		LOAD_DATA scene_data_c, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_data_i
		call	decompress_image
		call	palette_lookup
		mov	bx,1220h
		mov	cx,2C68h
		call	word ptr cs:gfx_mode_fn
		mov	ax,3
		call	word ptr cs:gfx_palette_fn
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	al,0FFh
		mov	bx,1720h
		mov	cx,2270h
		mov	di,0
		call	word ptr cs:gfx_update_fn
		mov	si,scene_sprite_c
scene_sprite_loop:
		mov	byte ptr ds:gvar_timer_lo,0
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	scene_after_anim			; Jump if zero
		push	si
		dec	al
		mov	bx,1720h
		call	word ptr cs:gspeech_u_
		pop	si
		mov	al,14h
		call	timer_wait_loop
		jmp	short scene_sprite_loop
scene_after_anim:
		WAIT_FRAME 0F0h
		mov	si,scene_sprite_b
		call	sprite_anim_proc
		WAIT_FRAME 0F0h
		mov	al,2
		mov	bx,1720h
		call	word ptr cs:gspeech_u_
		WAIT_FRAME 0Fh
		mov	al,3
		mov	bx,1720h
		call	word ptr cs:gspeech_u_
		WAIT_FRAME 0F0h
		xor	al,al			; Zero register
		mov	bx,94h
		mov	cx,501Eh
		call	word ptr cs:jashiin_speech_2+80h	; ('es')
		LOAD_DATA 9568h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	fill_buffer
		LOAD_DATA glyph_large, vga_seg
		mov	si,scene_data_d
		mov	di,aux_buf_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,glyph_small
		mov	es,cs:gvar_game_seg
		mov	di,offset jashiin_disappear_text+32h	; (' ')
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	bx,1720h
		mov	cx,2270h
		call	word ptr cs:gfx_mode_fn
		mov	ax,4
		call	word ptr cs:gfx_palette_fn
		mov	byte ptr ds:gvar_timer_lo,0
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		call	word ptr cs:gspeech_ve
		mov	al,0F0h
		call	timer_wait_loop
		xor	al,al			; Zero register
		mov	bx,0B48h
		mov	cx,3180h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:gfx_update_fn
		mov	byte ptr ds:gvar_timer_lo,0
		mov	es,cs:gvar_game_seg
		mov	si,aux_buf_seg
		mov	di,scene_framebuf
		call	fill_buffer
		mov	al,0F0h
		call	timer_wait_loop
		mov	bx,70Fh
		mov	cx,4170h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:gspeech_nt
		mov	byte ptr ds:gvar_timer_lo,0
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	fill_buffer
		mov	si,scene_sprite_d
		call	word ptr cs:gspeech_t_
		mov	al,0F0h
		call	timer_wait_loop
		mov	ax,0C7h
		mov	cx,64h

scene_color_rotate_loop:
		push	cx
		mov	byte ptr ds:gvar_timer_lo,0
		push	ax
		call	word ptr cs:gspeech_se
		pop	ax
		push	ax
		mov	al,ah
		call	word ptr cs:gspeech_se
		mov	al,50h			; 'P'
		call	timer_wait_loop
		pop	ax
		add	ah,2
		sub	al,2
		pop	cx
		loop	scene_color_rotate_loop		; Loop if cx > 0

scene_wait_gfx_enabled:
		call	interrupt_handler_cascade
		test	byte ptr ds:gvar_enable_all,0FFh
		jz	scene_wait_gfx_enabled			; Jump if zero
		jmp	timer_exit_to_game

opening_scene_main		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; SPRITE & CHARACTER RENDERING
; ============================================================


; ============================================================
; SPRITE & CHARACTER RENDERING
; ============================================================

sprite_anim_proc		proc	near
		mov	byte ptr ds:render_state_b,8Ah
anim_main_loop:
		mov	byte ptr ds:gvar_timer_lo,0
anim_read_byte:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	anim_check_frame_opcode			; Jump if not zero
		retn
anim_check_frame_opcode:
		cmp	al,5
		jae	anim_char_render			; Jump if above or =
		push	si
		dec	al
		mov	bx,1F70h
		call	word ptr cs:gspeech_ha
		pop	si
		jmp	short anim_read_byte
anim_char_render:
		call	char_render_proc
		mov	al,14h
		call	timer_wait_loop
		jmp	short anim_main_loop
sprite_anim_proc		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

char_render_proc		proc	near
		cmp	al,0FFh
		jne	char_render_glyph			; Jump if not equal
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	char_check_anim_data			; Jump if not zero
		retn
char_check_anim_data:
		cmp	al,1
		je	char_process_anim_cmd			; Jump if equal
		retn
char_process_anim_cmd:
		xor	ax,ax			; Zero register
		lodsb				; String [si] to al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	ds:render_state_a,ax
		add	byte ptr ds:render_state_b,0Ah
		retn
char_render_glyph:
		push	ax
		push	si
		push	ax
		mov	bx,ds:render_state_a
		add	bx,2
		mov	cl,ds:render_state_b
		add	cl,1
		mov	ah,2
		call	word ptr cs:gspeech_e_
		pop	ax
		mov	bx,ds:render_state_a
		mov	cl,ds:render_state_b
		mov	ah,7
		call	word ptr cs:gspeech_e_
		pop	si
		add	word ptr ds:render_state_a,8
		pop	ax
		cmp	al,20h			; ' '
		jne	char_check_space			; Jump if not equal
		retn
char_check_space:
		mov	byte ptr ds:gvar_volume_b,3Fh	; '?'
		retn
char_render_proc		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; SCREEN TRANSITION ANIMATIONS
; ============================================================


; ============================================================
; SCREEN TRANSITION ANIMATIONS
; ============================================================

animate_scanline		proc	near
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_wipe
		mov	si,6FF0h
scanline_data_loop:
		call	word ptr cs:anim_fn_fade
		push	si
		mov	cx,0Ah

scanline_frame_loop:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	timer_wait_loop
		pop	cx
		loop	scanline_frame_loop		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	scanline_data_loop			; Jump if not equal
		mov	cx,78h

scanline_fade_loop:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	timer_wait_loop
		pop	cx
		loop	scanline_fade_loop		; Loop if cx > 0

		retn
animate_scanline		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; TIMING & INPUT LOOPS
; ============================================================


; ============================================================
; TIMING & INPUT LOOPS
; ============================================================

timer_wait_loop		proc	near
timer_check_input:
		test	byte ptr cs:gvar_skip_input,0FFh
		jnz	timer_exit_to_game			; Jump if not zero
		cmp	byte ptr cs:gvar_key_state,0Dh
		je	timer_exit_to_game			; Jump if equal
		call	interrupt_handler_cascade
		cmp	cs:gvar_timer_lo,al
		jb	timer_check_input			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

;���� External Entry into Subroutine ��������������������������������������

interrupt_handler_cascade:
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn
timer_exit_to_game:
		mov	byte ptr ds:gvar_state_flag,8
		mov	al,0FFh
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:gfx_mode_fn
timer_wait_gfx:
		test	byte ptr ds:gvar_enable_all,0FFh
		jz	timer_wait_gfx			; Jump if zero
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		jmp	short $+2		; delay for I/O
		RESET_STACK
		push	cs
		pop	ds
		call	word ptr cs:gfx_init_fn
		mov	si,9589h
		mov	es,cs:gvar_game_seg
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:gvar_timer_lo,0
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	ax,1
		call	word ptr cs:gfx_palette_fn
		call	credits_scroll_display
		jmp	short trans_exit

;���� External Entry into Subroutine ��������������������������������������

scene_transition_wait:
trans_wait_timer:
		test	byte ptr cs:gvar_skip_input,0FFh
		jnz	trans_exit			; Jump if not zero
		cmp	byte ptr cs:gvar_key_state,0Dh
		je	trans_exit			; Jump if equal
		call	interrupt_handler_cascade
		cmp	cs:gvar_timer_lo,al
		jb	trans_wait_timer			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn
trans_exit:
		mov	byte ptr ds:gvar_state_flag,8
		call	word ptr cs:gfx_init_fn
trans_wait_gfx:
		test	byte ptr ds:gvar_enable_all,0FFh
		jz	trans_wait_gfx			; Jump if zero
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		jmp	begin_gameplay

;���� External Entry into Subroutine ��������������������������������������

credits_scroll_display:
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_wipe
		mov	si,742Fh
credits_scanline_loop:
		call	word ptr cs:anim_fn_fade
		push	si
		mov	cx,0Ah

credits_frame_loop:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	scene_transition_wait
		pop	cx
		loop	credits_frame_loop		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	credits_scanline_loop			; Jump if not equal
		mov	cx,78h

credits_fade_loop:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	scene_transition_wait
		pop	cx
		loop	credits_fade_loop		; Loop if cx > 0

		retn
		db	 87h, 20h
		db	'   Copyright (C)1987,1990 GAME ARTS    ', 0Dh, '    Copyright (C)1990 Sierra On-Line    '
		db	0FFh, 00h, 00h, 00h
begin_gameplay:
		RESET_STACK
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	word ptr cs:script_pc,79C6h
		mov	ax,5
		call	word ptr cs:gfx_palette_fn
		LOAD_DATA 9594h, 0A000h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,vga_seg
		mov	di,0
		call	decompress_image
		LOAD_DATA scene_data_e, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	bx,0
		mov	cx,5088h
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		call	word ptr cs:garland_speech
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:garland_speech
		call	script_interpreter
		mov	ax,9
		call	word ptr cs:gfx_palette_fn
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:garland_speech
		LOAD_DATA 95A9h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		call	script_interpreter
		xor	ax,ax			; Zero register
		call	word ptr cs:gspeech_en
		mov	ax,6
		call	word ptr cs:gfx_palette_fn
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:garland_speech
		LOAD_DATA 9551h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_data_i
		call	decompress_image
		call	script_interpreter
		mov	al,4
		call	busy_wait_delay
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		call	palette_blend
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:garland_speech
		call	script_interpreter
		call	script_interpreter
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		mov	al,7
		call	word ptr cs:gspeech_t2_
		call	script_interpreter
		call	script_interpreter
		mov	al,2
		call	busy_wait_delay
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		call	word ptr cs:garland_speech
		mov	byte ptr cs:gvar_timer_lo,0
		mov	al,0Fh
		call	gameplay_timer_loop
		mov	al,3
		call	busy_wait_delay
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		call	word ptr cs:garland_speech
		LOAD_DATA scene_data_f, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	bx,410h
		mov	cx,4868h
		call	word ptr cs:gfx_mode_fn
		call	script_interpreter
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		GFX_BLIT 410h, 4868h, 4000h
		call	script_interpreter
		LOAD_DATA 95BEh, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		xor	al,al			; Zero register
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:gfx_update_fn
		call	script_interpreter
		call	script_interpreter
		LOAD_DATA 95C8h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	di,scene_framebuf
		mov	bx,1610h
		mov	cx,2468h
		mov	al,5
		call	word ptr cs:gspeech_t2_
		call	script_interpreter
		xor	ax,ax			; Zero register
		call	word ptr cs:gspeech_en
		call	script_interpreter
		LOAD_DATA 95D2h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		GFX_BLIT 410h, 4868h, scene_framebuf
		LOAD_DATA scene_data_g, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		LOAD_DATA scene_data_h, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,screen_buf_1
		call	decompress_image
		call	script_interpreter
		call	script_interpreter
		xor	ax,ax			; Zero register
		call	word ptr cs:gspeech_en
		mov	ax,6
		call	word ptr cs:gfx_palette_fn
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:gspeech_he
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:garland_speech
		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:gspeech_he
		mov	es,cs:gvar_game_seg
		mov	di,8000h
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:garland_speech
		call	script_interpreter
		call	script_interpreter
		LOAD_DATA 9613h, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,screen_buf_1
		call	decompress_image
		xor	ax,ax			; Zero register
		call	word ptr cs:gspeech_en
		mov	ax,8
		call	word ptr cs:gfx_palette_fn
		mov	bx,1515h
		mov	cx,315Dh
		call	word ptr cs:gspeech_he
		mov	es,cs:gvar_game_seg
		mov	di,screen_buf_1
		mov	bx,1618h
		call	word ptr cs:gspeech_l_
		call	script_interpreter
		call	script_interpreter
		mov	bx,1515h
		mov	dx,315Dh
		mov	cx,18h

gameplay_timer_loop_start:
		push	cx
		push	dx
		push	bx
		mov	byte ptr cs:gvar_timer_lo,0
		mov	cx,dx
		call	word ptr cs:gspeech_he
		mov	al,0Fh
		call	gameplay_timer_loop
		pop	bx
		pop	dx
		inc	bh
		dec	dh
		pop	cx
		loop	gameplay_timer_loop_start		; Loop if cx > 0

		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:gspeech_he
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:gspeech_he
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:garland_speech
		call	script_interpreter
		call	script_interpreter
		mov	bx,2C15h
		mov	dx,1A5Dh
		mov	cx,18h

gameplay_input_loop:
		push	cx
		push	dx
		push	bx
		mov	byte ptr cs:gvar_timer_lo,0
		mov	cx,dx
		call	word ptr cs:gspeech_he
		mov	al,0Fh
		call	gameplay_timer_loop
		pop	bx
		pop	dx
		inc	bh
		dec	dh
		pop	cx
		loop	gameplay_input_loop		; Loop if cx > 0

		xor	ax,ax			; Zero register
		call	word ptr cs:gspeech_en
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		LOAD_DATA 95DDh, 0A000h
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		mov	bx,1010h
		mov	cx,3160h
		call	word ptr cs:garland_speech
		call	script_interpreter
		LOAD_DATA 95E8h, 0A000h
		mov	si,95F3h
		mov	di,0D000h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:gfx_mode_fn
		mov	bx,808h
		mov	es,cs:gvar_game_seg
		mov	di,framebuffer_a
		call	merge_gfx_planes
		mov	es,cs:gvar_game_seg
		mov	si,ext_seg_d000
		mov	di,ext_seg_d000
		call	decompress_image
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		mov	si,ext_segment
		call	xor_mask_render
		GFX_BLIT 808h, 40C0h, 4000h
		mov	byte ptr cs:gvar_timer_lo,0
		mov	al,0F0h
		call	gameplay_timer_loop
		mov	al,0FFh
		mov	bx,808h
		mov	cx,40C0h
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		call	word ptr cs:gfx_draw_fn
		mov	ax,1
		call	word ptr cs:gfx_palette_fn
		mov	si,7338h
		call	animate_scanline_alt
		mov	cx,0Ah

gameplay_frame_loop:
		push	cx
		mov	al,0C8h
		call	gameplay_timer_loop
		pop	cx
		loop	gameplay_frame_loop		; Loop if cx > 0

		jmp	short gameplay_exit_to_menu

;���� External Entry into Subroutine ��������������������������������������

gameplay_timer_loop:
gameplay_wait_elapsed:
		call	gameplay_input_handler
		cmp	cs:gvar_timer_lo,al
		jb	gameplay_wait_elapsed			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

;���� External Entry into Subroutine ��������������������������������������

gameplay_input_handler:
		test	byte ptr cs:gvar_skip_input,0FFh
		jnz	gameplay_exit_to_menu			; Jump if not zero
		cmp	byte ptr cs:gvar_key_state,0Dh
		je	gameplay_exit_to_menu			; Jump if equal
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn
gameplay_exit_to_menu:
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:gfx_mode_fn
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	si,961Eh
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,0FFFFh
		jmp	word ptr cs:scene_data_b
timer_wait_loop		endp

		db	 00h,0A0h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; SCRIPT INTERPRETER
; Reads scene script bytecode and dispatches to handlers.
; Control codes: 0xF0-0xFF (timing, layout, color, scroll)
;                0x80-0x9F (character portrait sprites)
;                0xEB-0xEF (speaker / text attribute codes)
; ============================================================


; ============================================================
; SCRIPT INTERPRETER
; Reads scene script bytecode and dispatches to handlers.
; Control codes 0xF0-0xFF: timing, layout, color, scroll
; Control codes 0x80-0x9F: character portrait sprites
; Control codes 0xEB-0xEF: speaker / text attribute codes
; ============================================================

script_interpreter		proc	near
		mov	byte ptr cs:gvar_timer_lo,0
script_loop:
		mov	al,10h
		call	gameplay_timer_loop
script_refetch:
		push	cs
		pop	ds
		mov	si,ds:script_pc
		lodsb				; String [si] to al
		mov	ds:script_pc,si
		test	al,80h
		jz	script_check_sprite_code			; Jump if zero
		jmp	script_dispatch_ctrl
script_check_sprite_code:
		cmp	al,20h			; ' '
		je	script_render_char			; Jump if equal
		cmp	al,2Eh			; '.'
		je	script_render_char			; Jump if equal
		cmp	al,2Ch			; ','
		je	script_render_char			; Jump if equal
		cmp	al,22h			; '"'
		je	script_render_char			; Jump if equal
		cmp	al,27h			; '''
		je	script_render_char			; Jump if equal
		mov	ah,ds:text_attr
		mov	ds:gvar_volume_b,ah
script_render_char:
		push	ax
		mov	bx,ds:text_x_pos
		add	bx,4
		mov	al,ds:text_y_pos
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	ax,8Fh
		mov	cx,ax
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:char_width_tbl[bx]
		mov	dh,bh
		pop	bx
		push	ax
		sub	bx,dx
		push	ax
		push	bx
		push	cx
		inc	bx
		inc	cx
		mov	ah,ds:text_color_fg
		call	word ptr cs:gspeech_e_
		pop	cx
		pop	bx
		pop	ax
		mov	ah,ds:text_color_bg
		call	word ptr cs:gspeech_e_
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:char_glyph_tbl[bx]
		mov	ch,bh
		add	ds:text_x_pos,cx
		cmp	al,20h			; ' '
		je	script_check_line_width			; Jump if equal
		jmp	script_loop
script_check_line_width:
		mov	si,ds:script_pc
		call	calc_text_width
		mov	dx,ds:text_x_pos
		add	dx,cx
		cmp	dx,138h
		jb	script_continue			; Jump if below
		jmp	script_newline
script_continue:
		jmp	script_loop
script_dispatch_ctrl:
		cmp	al,0FFh
		jne	script_check_eof			; Jump if not equal
		retn
script_check_eof:
		cmp	al,0FDh
		jne	script_check_section_break			; Jump if not equal
		retn
script_check_section_break:
		mov	ah,al
		and	ah,0F0h
		cmp	ah,80h
		jne	script_check_portrait_sm			; Jump if not equal
		jmp	script_portrait_sm
script_check_portrait_sm:
		cmp	ah,90h
		jne	script_check_portrait_lg			; Jump if not equal
		jmp	script_portrait_lg
script_check_portrait_lg:
		mov	bx,701h
		cmp	al,0FBh
		jne	script_check_color_fb			; Jump if not equal
		jmp	script_set_colors
script_check_color_fb:
		mov	bx,700h
		cmp	al,0FAh
		jne	script_check_color_fa			; Jump if not equal
		jmp	script_set_colors
script_check_color_fa:
		mov	bx,602h
		cmp	al,0F9h
		je	script_set_colors			; Jump if equal
		cmp	al,0F5h
		jne	script_check_pause			; Jump if not equal
		jmp	script_do_pause
script_check_pause:
		cmp	al,0F6h
		jne	script_check_layout			; Jump if not equal
		jmp	script_do_long_pause
script_check_layout:
		xor	ah,ah			; Zero register
		cmp	al,0F7h
		je	script_reset_position			; Jump if equal
		inc	ah
		cmp	al,0F3h
		je	script_reset_position			; Jump if equal
		inc	ah
		cmp	al,0F2h
		je	script_reset_position			; Jump if equal
		inc	ah
		cmp	al,0F1h
		je	script_reset_position			; Jump if equal
		cmp	al,0FEh
		je	script_clear_screen			; Jump if equal
		mov	ah,ds:text_attr
		mov	byte ptr ds:text_attr,0
		cmp	al,0F0h
		jne	script_check_reset_attr			; Jump if not equal
		jmp	script_loop
script_check_reset_attr:
		mov	byte ptr ds:text_attr,3Dh	; '='
		cmp	al,0EFh
		jne	script_set_attr_ef			; Jump if not equal
		jmp	script_loop
script_set_attr_ef:
		mov	byte ptr ds:text_attr,3Eh	; '>'
		cmp	al,0EEh
		jne	script_set_attr_ee			; Jump if not equal
		jmp	script_loop
script_set_attr_ee:
		mov	byte ptr ds:text_attr,3Fh	; '?'
		cmp	al,0EDh
		jne	script_set_attr_ed			; Jump if not equal
		jmp	script_loop
script_set_attr_ed:
		mov	byte ptr ds:text_attr,40h	; '@'
		cmp	al,0ECh
		jne	script_set_attr_ec			; Jump if not equal
		jmp	script_loop
script_set_attr_ec:
		mov	byte ptr ds:text_attr,41h	; 'A'
		cmp	al,0EBh
		jne	script_set_attr_eb			; Jump if not equal
		jmp	script_loop
script_set_attr_eb:
		mov	ds:text_attr,ah
		jmp	script_loop
script_set_colors:
		mov	ds:text_color_fg,bl
		mov	ds:text_color_bg,bh
		jmp	script_loop
script_reset_position:
		mov	word ptr ds:text_x_pos,0
		mov	ds:text_y_pos,ah
		jmp	script_loop
script_newline:
		mov	word ptr ds:text_x_pos,0
		inc	byte ptr ds:text_y_pos
		jmp	script_loop
script_clear_screen:
		mov	bx,8Fh
		mov	cx,5039h
		xor	al,al			; Zero register
		call	word ptr cs:jashiin_speech_2+80h	; ('es')
		xor	ah,ah			; Zero register
		jmp	short script_reset_position
script_do_pause:
		mov	al,0F0h
		call	gameplay_timer_loop
		jmp	script_loop
script_do_long_pause:
		mov	al,0F0h
		call	gameplay_timer_loop
		mov	al,0F0h
		call	gameplay_timer_loop
		mov	al,0F0h
		call	gameplay_timer_loop
		jmp	script_loop
script_portrait_sm:
		mov	es,cs:gvar_game_seg
		and	al,0Fh
		cmp	al,6
		jae	script_portrait_sm_large			; Jump if above or =
		mov	ah,15h
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3350h
		mov	cx,0E20h
		call	word ptr cs:garland_speech
		jmp	script_refetch
script_portrait_sm_large:
		sub	al,6
		mov	ah,21h			; '!'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,0B840h
		mov	di,ax
		mov	bx,3338h
		mov	cx,0B10h
		call	word ptr cs:garland_speech
		jmp	script_refetch
script_portrait_lg:
		mov	es,cs:gvar_game_seg
		and	al,0Fh
		cmp	al,6
		jae	script_portrait_lg_large			; Jump if above or =
		mov	ah,1Bh
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,58C0h
		mov	di,ax
		mov	bx,1350h
		mov	cx,920h
		call	word ptr cs:garland_speech
		jmp	script_refetch
script_portrait_lg_large:
		sub	al,6
		mov	ah,21h			; '!'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,6D00h
		mov	di,ax
		mov	bx,1238h
		mov	cx,0B10h
		call	word ptr cs:garland_speech
		jmp	script_refetch
script_interpreter		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; TEXT RENDERING UTILITIES
; ============================================================


; ============================================================
; TEXT RENDERING UTILITIES
; ============================================================

calc_text_width		proc	near
		xor	cx,cx			; Zero register
width_char_loop:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		jne	width_end_on_space			; Jump if not equal
		retn
width_end_on_space:
		cmp	al,0FFh
		jne	width_end_on_eof			; Jump if not equal
		retn
width_end_on_eof:
		cmp	al,0FEh
		jne	width_end_on_fe			; Jump if not equal
		retn
width_end_on_fe:
		cmp	al,0FDh
		jne	width_end_on_fd			; Jump if not equal
		retn
width_end_on_fd:
		cmp	al,0F7h
		jne	width_end_on_f7			; Jump if not equal
		retn
width_end_on_f7:
		cmp	al,0F3h
		jne	width_end_on_f3			; Jump if not equal
		retn
width_end_on_f3:
		cmp	al,0F2h
		jne	width_end_on_f2			; Jump if not equal
		retn
width_end_on_f2:
		cmp	al,0F1h
		jne	width_end_on_f1			; Jump if not equal
		retn
width_end_on_f1:
		or	al,al			; Zero ?
		js	width_char_loop			; Jump if sign=1
		sub	al,20h			; ' '
		jc	width_char_loop			; Jump if carry Set
		mov	bl,al
		xor	bh,bh			; Zero register
		add	cl,cs:char_glyph_tbl[bx]
		adc	ch,bh
		jmp	short width_char_loop
calc_text_width		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

animate_scanline_alt		proc	near
		push	si
		mov	bx,20h
		mov	cx,5078h
		call	word ptr cs:anim_fn_wipe
		pop	si
alt_scanline_loop:
		call	word ptr cs:anim_fn_fade
		push	si
		mov	cx,0Ah

alt_frame_loop:
		push	cx
		mov	ax,cx
		neg	ax
		add	ax,0Ah
		mov	bx,14h
		mov	cx,50A0h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	gameplay_timer_loop
		pop	cx
		loop	alt_frame_loop		; Loop if cx > 0

		pop	si
		cmp	byte ptr [si-1],0FFh
		jne	alt_scanline_loop			; Jump if not equal
		mov	cx,0A0h

alt_fade_loop:
		push	cx
		xor	ax,ax			; Zero register
		mov	bx,14h
		mov	cx,50A0h
		call	word ptr cs:anim_fn_draw
		mov	al,1Ch
		call	gameplay_timer_loop
		pop	cx
		loop	alt_fade_loop		; Loop if cx > 0

		retn
animate_scanline_alt		endp

		; Static initial values for script state variables (loaded at CS:0x6000,
		; these bytes sit at segment offset 0x6D5A = script_pc+4 through +11)
		; 0x79C6 = initial script program counter (= opening_narration address in segment)
		db	0C6h, 79h	; script_pc initial lo/hi (0x79C6)
		db	0, 0		; text_x_pos initial = 0
		db	0, 0		; text_y_pos initial = 0
		db	0, 0		; text_color_fg/bg initial = 0

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; IMAGE PROCESSING
; ============================================================


; ============================================================
; IMAGE PROCESSING
; ============================================================

decompress_image		proc	near
		call	rle_unpack_core
		jmp	short decomp_palette_transform

;���� External Entry into Subroutine ��������������������������������������

rle_unpack_core:
		push	di
		lodsw				; String [si] to ax
		mov	cx,ax
		push	cx
		mov	bp,si
		add	si,cx

decomp_bit_scan_loop:
		push	cx
		xor	al,al			; Zero register
		mov	cx,8

decomp_bit_loop:
		rol	byte ptr ds:[bp],1	; Rotate
		jc	decomp_copy_literal			; Jump if carry Set
		stosb				; Store al to es:[di]
		loop	decomp_bit_loop		; Loop if cx > 0

		jmp	short decomp_next_bit
decomp_copy_literal:
		movsb				; Mov [si] to es:[di]
		loop	decomp_bit_loop		; Loop if cx > 0

decomp_next_bit:
		inc	bp
		pop	cx
		loop	decomp_bit_scan_loop		; Loop if cx > 0

		pop	cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		pop	di
		retn
decomp_palette_transform:
		xor	dh,dh			; Zero register

decomp_palette_loop:
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		mov	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		xor	al,al			; Zero register
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		rcl	byte ptr es:[di],1	; Rotate thru carry
		adc	al,al
		xor	dh,al
		add	ah,ah
		add	ah,ah
		or	ah,dh
		mov	al,ah
		stosb				; Store al to es:[di]
		loop	decomp_palette_loop		; Loop if cx > 0

		retn
decompress_image		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������


; ============================================================
; UTILITY ROUTINES
; ============================================================


; ============================================================
; UTILITY ROUTINES
; ============================================================

fill_buffer		proc	near
fill_loop:
		test	byte ptr [si],40h	; '@'
		jz	fill_raw_byte			; Jump if zero
		lodsw				; String [si] to ax
		xchg	ah,al
		mov	cx,ax
		cmp	ax,0FFFFh
		jne	fill_process_count			; Jump if not equal
		retn
fill_process_count:
		and	cx,3FFFh
		test	ax,8000h
		jz	fill_copy_bytes			; Jump if zero
fill_repeat_byte:
		lodsb				; String [si] to al
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short fill_loop
fill_copy_bytes:
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		jmp	short fill_loop
fill_raw_byte:
		lodsb				; String [si] to al
		mov	cl,al
		and	cx,3Fh
		test	al,80h
		jz	fill_copy_bytes			; Jump if zero
		jmp	short fill_repeat_byte
fill_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

palette_lookup		proc	near
		push	ds
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,null_ofs
		mov	cx,1650h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	ds,cs:gvar_game_seg
		mov	di,0
		mov	bx,0
		mov	cx,2230h
		mov	si,sprite_buf_c
		call	render_font_row_double
		mov	bx,0F30h
		mov	cx,620h
		mov	si,sprite_buf_b
		call	render_font_row_double
		mov	bx,850h
		mov	cx,1220h
		mov	si,sprite_buf_a
		call	render_font_row_inverse
		pop	ds
		retn
palette_lookup		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_font_row_double		proc	near
		push	di
		add	di,font_row_ofs
		call	copy_buffer
		pop	di
		push	di
		call	copy_buffer
		pop	di
		retn
render_font_row_double		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

render_font_row_inverse		proc	near
		push	di
		call	copy_buffer
		pop	di
		push	di
		add	di,font_row_ofs
		call	copy_buffer
		pop	di
		retn
render_font_row_inverse		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

copy_buffer		proc	near
		push	bx
		push	cx
		mov	al,22h			; '"'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		add	di,ax
copy_line_loop:
		push	cx
		push	di
		mov	cl,ch
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		add	di,22h
		pop	cx
		dec	cl
		jnz	copy_line_loop			; Jump if not zero
		pop	cx
		pop	bx
		retn
copy_buffer		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

busy_wait_delay		proc	near
		push	ds
		xor	ah,ah			; Zero register
		mov	dx,0CC0h
		mul	dx			; dx:ax = reg * ax
		add	ax,0AB40h
		mov	ds,cs:gvar_game_seg
		mov	si,ax
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,null_ofs
		call	color_rotation
		pop	ds
		retn
busy_wait_delay		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

color_rotation		proc	near
		mov	cx,30h

rotate_row_loop:
		push	cx
		mov	cx,22h

rotate_byte_loop:
		mov	ah,ds:font_plane_a[si]
		lodsb				; String [si] to al
		mov	bh,al
		not	bh
		and	bh,ah
		xor	ah,bh
		mov	es:[di],al
		mov	es:font_plane_b[di],bh
		mov	es:font_plane_c[di],ah
		inc	di
		loop	rotate_byte_loop		; Loop if cx > 0

		pop	cx
		loop	rotate_row_loop		; Loop if cx > 0

		retn
color_rotation		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

palette_blend		proc	near
		push	ds
		push	es
		pop	ds
		mov	si,di
		mov	es,cs:gvar_game_seg
		mov	di,temp_decode_buf
		mov	cx,30h

blend_row_loop:
		push	cx
		push	di
		mov	cx,11h

blend_word_loop:
		push	cx
		mov	ax,es:[di]
		mov	bx,es:plane_data_a[di]
		not	ax
		not	bx
		and	ax,bx
		and	ax,es:plane_data_b[di]
		mov	dx,ax
		not	dx
		mov	bx,ax
		and	ax,[si]
		and	es:[di],dx
		or	es:[di],ax
		mov	ax,bx
		and	ax,ds:font_plane_b[si]
		and	es:plane_data_a[di],dx
		or	es:plane_data_a[di],ax
		mov	ax,bx
		and	ax,ds:font_plane_c[si]
		and	es:plane_data_b[di],dx
		or	es:plane_data_b[di],ax
		add	di,2
		add	si,2
		pop	cx
		loop	blend_word_loop		; Loop if cx > 0

		pop	di
		add	di,48h
		pop	cx
		loop	blend_row_loop		; Loop if cx > 0

		pop	ds
		retn
palette_blend		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

xor_mask_render		proc	near
		add	di,font_scanline_ofs
		mov	cx,0A0h

mask_row_loop:
		push	cx
		push	di
		mov	cx,15h

mask_byte_loop:
		push	cx
		mov	al,es:[si]
		and	al,es:pixel_mask_a[si]
		mov	ah,es:pixel_mask_b[si]
		not	ah
		and	al,ah
		not	al
		mov	ah,es:[si]
		or	ah,es:pixel_mask_a[si]
		or	ah,es:pixel_mask_b[si]
		and	es:[si],al
		and	es:pixel_mask_a[si],al
		not	ah
		and	es:[di],ah
		and	es:gfx_plane_b[di],ah
		and	es:framebuffer_b[di],ah
		mov	al,es:[si]
		or	es:[di],al
		mov	al,es:pixel_mask_a[si]
		or	es:gfx_plane_b[di],al
		mov	al,es:pixel_mask_b[si]
		or	es:framebuffer_b[di],al
		inc	di
		inc	si
		pop	cx
		loop	mask_byte_loop		; Loop if cx > 0

		pop	di
		add	di,40h
		pop	cx
		loop	mask_row_loop		; Loop if cx > 0

		retn
xor_mask_render		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

merge_gfx_planes		proc	near
		push	bx
		push	es
		push	di
		mov	cx,3000h

merge_loop:
		mov	byte ptr es:framebuffer_b[di],0
		mov	al,es:gfx_plane_b[di]
		mov	ah,es:[di]
		not	ah
		and	al,ah
		or	es:[di],al
		or	es:framebuffer_b[di],al
		not	al
		and	es:gfx_plane_b[di],al
		mov	al,es:gfx_plane_b[di]
		and	al,es:[di]
		or	es:framebuffer_b[di],al
		inc	di
		loop	merge_loop		; Loop if cx > 0

		pop	di
		pop	es
		pop	bx
		mov	cx,40C0h
		mov	al,0FFh
		jmp	word ptr cs:gfx_update_fn
merge_gfx_planes		endp

		db	'           Two thousand years, ', 0Dh, 'from the dark reaches of another galaxy,', 0Dh, '        a demon with not a shred', 0Dh
		db	'      of compassion for humankind,', 0Dh, '         descended upon earth.', 0Dh, 0Dh, '          He defiled the land,', 0Dh
		db	'  sending vile creatures to live in it,', 0Dh, '   and thus became ruler of the world.', 0Dh, 0Dh, '         The King of Felishika,', 0Dh
		db	'     appalled by what had happened,', 0Dh, '          prayed to the Spirit', 0Dh, '      of the Holy Land of Zeliard', 0Dh
		db	'    for help in defeating this monster.', 0Dh, 0Dh, '    With the help of the holy crystals', 0Dh, '       called Tears of Esmesanti,', 0Dh
		db	'    the King managed to wrest power', 0Dh, '    from the fiend and seal him deep', 0Dh, '     within the bowels of the earth.', 0Dh
		db	0Dh, '            And once again,', 0Dh, ' the light of peace came to shine upon', 0Dh, '              the earth.', 0Dh
		db	0Dh, 0Dh, 'However, it is written in', 0Dh, '       the Sixth Book of Esmesanti:', 0Dh, '                    The Age of Darkness.', 0Dh
		db	0FFh, 20h		; end-of-script
		db	'               At last,                ', 0Dh, '     the door of destiny was opened.    ', 0Dh, '        The labyrinths are deep,        ', 0Dh
		db	'          and the way is long.          ', 0Dh, '     Will Duke Garland be successful    ', 0Dh, '   in dethroning the Emperor of Chaos?  ', 0Dh
		db	0FFh, 20h		; end-of-script
		db	'         Fantasy Action Game           ', 0Dh, '               ZELIARD                  ', 0Dh, 0Dh, '             -- STAFF --                ', 0Dh
		db	0Dh, 'Producer -- Japanese Version', 0Dh, '                      Mitsuhiro Mazda   ', 0Dh, 0Dh, 'Producer -- English Version', 0Dh
		db	'                        Josh Mandel     ', 0Dh, 0Dh, 'Lead Programmer      Tomoyuki Shimada   ', 0Dh, 0Dh, 'Graphic Designers     Akihiko Yoshida   ', 0Dh
		db	'                      Masatoshi Azumi   ', 0Dh, 0Dh, 'English Text Translation by', 0Dh, '                       Marti McKenna    ', 0Dh
		db	0Dh, 'Music Composers  -- MECANO ASSOCIATES --', 0Dh, '                    Fumihito Kasatani   ', 0Dh, '                    Nobuyuki Aoshima    ', 0Dh
		db	0Dh, 'Story Maker           Masaru Takeuchi   ', 0Dh, 0Dh, 'Sound Effects by     Tomoyuki Shimada   ', 0Dh, 0Dh
		db	'Advisers               Osamu Harada     ', 0Dh, '                       Hiromi Ohba      ', 0Dh, '                       Greg Miyaji      ', 0Dh
		db	0Dh, 'System Designer      Rocky Cave Maker   ', 0Dh, 0Dh, 'Special Thanks to', 0Dh, '                    Toshiyuki Uchida    ', 0Dh
		db	'                       Yuzo Sunaga      ', 0Dh, '                     Takeshi Miyaji     ', 0Dh, '                     Naozumi Honma      ', 0Dh
		db	'                     Toshi Masubuchi    ', 0Dh, '                     Ray E. Nakazato    ', 0Dh, '                     Hiroyuki Koyama    ', 0Dh
		db	'                     Satoshi Uesaka     ', 0Dh, '              Sierra On-Line Japan, Inc.', 0Dh, '                    Eiji (Ed) Nagano    ', 0Dh
		db	0Dh, 0Dh, 0Dh, '    Copyright (C)1987,1990 GAME ARTS    ', 0Dh, '    Copyright (C)1990 Sierra On-Line    ', 0Dh
		db	'  This edition first published 1987 by  ', 0Dh, '  GAME ARTS Co.,Ltd./ Tomoyuki Shimada  ', 0Dh
		db	0FFh, 50h,0F0h,0FEh,0F3h,0FAh		; end-of-script | reset text attribute | scroll-text-up | layout-mode 1 | text-style: color 7 normal
		db	'Once, long ago, a terrible storm came to the land of Zeliard. '
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h		; pause | pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'Dark clouds filled the sky; lightnin'
		db	'g flashed and thunder crashed. '
		db	0F2h		; layout-mode 2
		db	'Day after day, rain poured from the heavens as if in lament.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F5h		; pause | pause | pause | pause | scroll-text-up | pause
		db	0F5h,0FEh,0F3h,0F5h		; pause | scroll-text-up | layout-mode 1 | pause
		db	'On the seventh day of rain, a beautiful young girl stood on her balcony watching this dark, sad rain.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h		; pause | pause | pause | pause | scroll-text-up | layout-mode 1
		db	'The girl was Princess Felicia la Felishika.  She was the only daughter of King Felishika, and the light of his life.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h		; pause | pause | pause | pause | scroll-text-up | layout-mode 1
		db	0F5h		; pause
		db	'Her smiles were like sunshine, her voice as beautiful as that of an angel.  She was adored by the people of the kingdom.'
		db	0F5h,0F5h,0F5h,0F5h		; pause | pause | pause | pause
dialogue_scene_start:
		db	0EBh, 0FEh		; script ctrl: EB FE
		db	0F5h, 0F3h, 0FBh, 0A0h		; pause | layout-mode 1 | text-style: color 7 bold | attr-restore
		db	'"What a dreadful storm!  Will it never end?"'
		db	0F0h,0F6h,0FEh,0F5h,0F3h,0FAh		; reset text attribute | long-pause (3x) | scroll-text-up | pause | layout-mode 1 | text-style: color 7 normal
		db	'Just as the princess spoke these words, the raindrops turned to grains of sand which covered the ground below her. '
		db	0F5h,0F5h,0F5h,0F5h,0F5h,0FEh		; pause | pause | pause | pause | pause | scroll-text-up
		db	0FDh,0FEh,0F5h,0F3h		; end-of-section | scroll-text-up | pause | layout-mode 1
		db	'As she watched, a startling transformation began to take place.'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F3h		; pause | pause | pause | pause | scroll-text-up | layout-mode 1
		db	'In an instant, the green hills and plains turned a dusty brown. '
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h		; pause | pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'Trees and flowers crumpled and were buried. '
		db	0F3h		; layout-mode 1
		db	'Rivers and lakes disappeared beneath the sand.'
		db	0F1h		; layout-mode 3
		db	'This ever-green land was turning to desert before her very eyes.'
		db	0F5h,0F5h,0F5h,0F5h,0F5h,0F5h		; pause | pause | pause | pause | pause | pause
		db	0FEh,0FDh,0F5h,0F3h,0FBh,0EBh		; scroll-text-up | end-of-section | pause | layout-mode 1 | text-style: color 7 bold | speaker: Princess Felicia (attr A)
		db	0A2h		; attr-restore
		db	'"How can this be?" '
		db	0F0h,0FAh		; reset text attribute | text-style: color 7 normal
		db	'she cried, '
		db	0EBh,0FBh		; speaker: Princess Felicia (attr A) | text-style: color 7 bold
		db	'"What evil power could cause such a terrible thing to happen?"'
		db	0F0h,0F6h,0F5h,0F5h,0F5h,0FEh		; reset text attribute | long-pause (3x) | pause | pause | pause | scroll-text-up
		db	0F3h,0FAh		; layout-mode 1 | text-style: color 7 normal
		db	'Princess Felicia shivered as she felt a dark presence near her, '
		db	0FDh		; end-of-section
		db	'and suddenly, a terrifying voice bellowed as loud as thunder...'
		db	0F5h,0F5h,0F5h,0F5h,0FEh,0F7h		; pause | pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	0F9h,0EDh		; text-style: color 6 | speaker: Jashiin/narrator (attr ?)
		db	'"I am Jashiin, the Emperor of Chaos.  The descendants of those who imprisoned me under the earth shall know that my wrath has smoldered for two thousand years!"'
		db	0F0h,0F5h,0F5h,0FDh,0FDh,0FEh		; reset text attribute | pause | pause | end-of-section | end-of-section | scroll-text-up
		db	0F7h,0EDh		; layout-mode 0 (direct write) | speaker: Jashiin/narrator (attr ?)
jashiin_speech_2		db	'"Beautiful Princess Felicia, you'
		db	' will make a lovely and terrifying symbol of my awakening.  Your father will not make the mistakes of his ancestors!"'
		db	0F0h,0F5h,0F5h,0FEh,0FDh,0F3h		; reset text attribute | pause | pause | scroll-text-up | end-of-section | layout-mode 1
		db	0FAh		; text-style: color 7 normal
narration_stone_scene		db	'As the words of the demon resoun'
		db	'ded over the land, Princess Felicia was turned to stone.'

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

; ============================================================
; DATA SECTION -- Opening Scene Script & Narration
; ============================================================

opening_narration:
		db	SCR_BREAK			; script ctrl: FD

;���� External Entry into Subroutine ��������������������������������������

narration_chapter_2:
		db	SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_BREAK, SCR_PARA		; pause | pause | scroll-text-up | end-of-section | layout-mode 1
		db	'The rain of sand continued for 108 days and transformed the once-fertile land into desert.'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA		; pause | pause | scroll-text-up | layout-mode 1
		db	'The people of the kingdom wept at the terrible fate of their country, and of their princess.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK		; pause | pause | pause | pause | scroll-text-up | end-of-section
		db	SCR_SCROLL,SCR_DIRECT,SCR_NORMAL		; scroll-text-up | layout-mode 0 (direct write) | text-style: color 7 normal
		db	'The King wept most of all. '
		db	SCR_PARA,SCR_SPK_KING,SCR_BOLD		; layout-mode 1 | speaker: King Felishika (attr >) | text-style: color 7 bold
		db	'"Oh, my beloved Felicia!  I fear the Age of Darkness is upon us.  I am powerless to stop it ... and powerless to help you."'
		db	SCR_RESET,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK		; reset text attribute | pause | pause | pause | scroll-text-up | end-of-section
		db	SCR_PARA,SCR_NORMAL		; layout-mode 1 | text-style: color 7 normal
		db	'But the tears of the King and his people soon awakened another power.'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK,SCR_PARA		; pause | pause | scroll-text-up | end-of-section | layout-mode 1
		db	'As the King grieved, an apparition appeared before him.'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_SPK_DEMON,SCR_DIRECT,SCR_BOLD		; pause | pause | scroll-text-up | speaker: Jashiin (attr @) | layout-mode 0 (direct write) | text-style: color 7 bold
		db	'"I am the Guardian Spirit of the Holy Land of Zeliard.  The demon Jashiin has been resurrected, and indeed his evil magic will plunge this world into the Age of Darkness once again."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT, 22h		; pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'Heed my words, King Felishika: There is but one way to stop this demon.  A brave warrior must venture into the labyrinths and recover the nine Holy Crystals, the Tears of Esmesanti."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT		; pause | pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	 22h
		db	'Many terrible creatures dwell within the labyrinths, all of them'
		db	' Jashiin', 27h, 's minions.  No '
		db	'mortal man could defeat these deadly beasts and wrest the crystals from them."'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT, 22h		; pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'However, there is one with the power to oppose Jashiin.'
		db	SCR_MODE2		; layout-mode 2
		db	'The man who is destined to fight him will soon arrive in your kingdom."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA		; pause | pause | pause | scroll-text-up | layout-mode 1
		db	'"This man is the only being strong enough to banish Jashiin forever."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT		; pause | pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	 22h
		db	'You must await the arrival of this brave and noble knight, and tell him everything.  Only with his help can you hope to restore this land to its former beauty, and free your daughter from her terrible curse."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_RESET		; pause | pause | pause | pause | scroll-text-up | reset text attribute
		db	SCR_BREAK,SCR_PARA,SCR_NORMAL		; end-of-section | layout-mode 1 | text-style: color 7 normal
		db	'Having spoken these words, the Spirit disappeared.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT		; pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'King Felishika could not believe what he had seen.'
		db	SCR_MODE2,SCR_BOLD		; layout-mode 2 | text-style: color 7 bold
		db	'"Surely my mind is playing trick'
		db	's on me!  I', 27h, 'm afraid I h'
		db	'ave gone mad with grief."'
		db	SCR_NORMAL,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL		; text-style: color 7 normal | pause | pause | pause | pause | scroll-text-up
		db	SCR_PARA		; layout-mode 1
		db	'But the next day, a stranger appeared in the kingdom...'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_SPK_UNK,SCR_BREAK		; pause | pause | pause | scroll-text-up | speaker: unknown (attr =) | end-of-section
		db	SCR_PARA,SCR_BOLD		; layout-mode 1 | text-style: color 7 bold
		db	'"What a desolate place!  Why has the Spirit led me here?"'
		db	SCR_WAIT		; pause

;���� External Entry into Subroutine ��������������������������������������

narration_chapter_3:
		db	SCR_WAIT, SCR_WAIT, SCR_WAIT, SCR_SCROLL, SCR_RESET, SCR_PARA, SCR_NORMAL		; pause | pause | pause | scroll-text-up | reset text attribute | layout-mode 1 | text-style: color 7 normal
		db	'Guided by the light of the Spirit, brave Duke Garland had journeyed many days to the land of Zeliard.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK,SCR_PARA		; pause | pause | pause | scroll-text-up | end-of-section | layout-mode 1
		db	'Entering the castle, he was quickly escorted to the throne of the grieving King Felishika.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_SPK_KING,SCR_BREAK		; pause | pause | pause | scroll-text-up | speaker: King Felishika (attr >) | end-of-section
		db	SCR_WAIT,SCR_SCROLL,SCR_BOLD,SCR_DIRECT, 22h, 81h		; pause | scroll-text-up | text-style: color 7 bold | layout-mode 0 (direct write)
		; Style-encoded speech -- King Felishika
		; "Duke Garland! You must be the man of destiny of whom the Spirit spoke.
		;    I beg of you to destroy the demon Jashiin who has cursed my kingdom
		;    and turned my beloved daughter to stone."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 44h, 75h, 6Bh, 65h, 20h, 80h
		db	 47h, 61h, 72h, 6Ch, 61h, 84h
		db	 6Eh, 83h, 64h, 21h, 20h, 20h
		db	 84h, 85h, 59h, 87h, 6Fh, 88h
		db	 75h, 87h, 20h, 86h, 80h, 6Dh
		db	 75h, 81h, 73h, 83h, 74h, 20h
		db	 82h, 62h, 65h, 20h, 81h, 74h
		db	 68h, 65h, 20h, 80h, 6Dh, 61h
		db	 84h, 6Eh, 20h, 83h, 6Fh, 84h
		db	 66h, 20h, 81h, 64h, 65h, 73h
		db	 82h, 74h, 69h, 6Eh, 79h, 20h
		db	 83h, 6Fh, 84h, 66h, 20h, 83h
		db	 77h, 68h, 6Fh, 84h, 6Dh, 20h
		db	 81h, 74h, 68h, 65h, 20h, 83h
		db	 53h, 82h, 70h, 69h, 72h, 69h
		db	 74h, 20h, 83h, 73h, 70h, 6Fh
		db	 81h, 6Bh, 65h, 2Eh, 20h, 20h
		db	 84h, 97h, 80h, 49h, 98h, 87h
		db	 20h, 81h, 88h, 62h, 87h, 65h
		db	 85h, 86h, 67h, 20h, 83h, 6Fh
		db	 84h, 66h, 20h, 85h, 79h, 6Fh
		db	 75h, 20h, 83h, 74h, 6Fh, 20h
		db	 82h, 64h, 65h, 85h, 73h, 74h
		db	 72h, 6Fh, 79h, 20h, 81h, 74h
		db	 68h, 65h, 20h, 83h, 64h, 65h
		db	 80h, 6Dh, 6Fh, 6Eh, 20h, 84h
		db	 4Ah, 80h, 61h, 73h, 82h, 68h
		db	 69h, 69h, 84h, 6Eh, 20h, 80h
		db	 87h, 77h, 88h, 68h, 87h, 6Fh
		db	 86h, 20h, 85h, 68h, 61h, 73h
		db	 20h, 83h, 63h, 75h, 81h, 72h
		db	 83h, 73h, 65h, 64h, 20h, 80h
		db	 6Dh, 79h, 20h, 85h, 6Bh, 69h
		db	 81h, 6Eh, 67h, 64h, 6Fh, 6Dh
		db	 20h, 85h, 61h, 82h, 6Eh, 64h
		db	 20h, 84h, 74h, 75h, 72h, 81h
		db	 6Eh, 65h, 64h, 20h, 80h, 87h
		db	 6Dh, 82h, 88h, 79h, 87h, 20h
		db	 81h, 86h, 62h, 65h, 83h, 6Ch
		db	 6Fh, 81h, 76h, 65h, 83h, 64h
		db	 20h, 85h, 64h, 61h, 75h, 67h
		db	 68h, 80h, 74h, 65h, 72h, 20h
		db	 85h, 74h, 6Fh, 20h, 83h, 87h
		db	 73h, 88h, 74h, 87h, 6Fh, 84h
		db	 86h, 6Eh, 65h, 2Eh, 22h,SCR_WAIT		; pause
		db	SCR_WAIT,SCR_WAIT,SCR_RESET,SCR_SCROLL,SCR_DIRECT,SCR_NORMAL		; pause | pause | reset text attribute | scroll-text-up | layout-mode 0 (direct write) | text-style: color 7 normal
		db	'Duke Garland knelt before the King. '
		db	SCR_BOLD,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_PARA,SCR_SPK_UNK		; text-style: color 7 bold | pause | pause | pause | layout-mode 1 | speaker: unknown (attr =)
		; Style-encoded speech -- Duke Garland
		; "Your Majesty, I have followed the light of the Spirit to this place."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 97h, 22h, 93h, 96h, 59h, 6Fh
		db	 90h, 75h, 72h, 20h, 4Dh, 61h
		db	 91h, 6Ah, 65h, 95h, 73h, 74h
		db	 79h, 2Ch, 20h, 90h, 49h, 20h
		db	 91h, 68h, 61h, 93h, 76h, 65h
		db	 20h, 93h, 66h, 6Fh, 6Ch, 6Ch
		db	 6Fh, 77h, 95h, 65h, 64h, 20h
		db	 91h, 74h, 68h, 65h, 20h, 90h
		db	 6Ch, 69h, 92h, 67h, 68h, 93h
		db	 74h, 20h, 94h, 93h, 6Fh, 66h
		db	 20h, 91h, 74h, 68h, 65h, 20h
		db	 93h, 53h, 92h, 70h, 69h, 91h
		db	 72h, 92h, 69h, 74h, 20h, 95h
		db	 74h, 6Fh, 20h, 92h, 74h, 68h
		db	 92h, 69h, 97h, 73h, 98h, 20h
		db	 97h, 95h, 70h, 96h, 90h, 6Ch
		db	 61h, 93h, 63h, 65h, 2Eh, 22h
		db	 94h,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT		; pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		; Style-encoded speech -- Duke Garland
		; "I know not of this demon, nor what powers he may possess, but if
		;    there is none else who can defeat him, then I will dedicate my life to this task."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 22h, 90h, 49h, 20h, 93h, 6Bh
		db	 95h, 6Eh, 6Fh, 77h, 94h, 20h
		db	 93h, 6Eh, 6Fh, 74h, 94h, 20h
		db	 93h, 6Fh, 95h, 66h, 20h, 92h
		db	 74h, 68h, 69h, 95h, 73h, 20h
		db	 91h, 64h, 65h, 93h, 6Dh, 6Fh
		db	 94h, 6Eh, 2Ch, 20h, 93h, 6Eh
		db	 6Fh, 90h, 72h, 20h, 93h, 77h
		db	 68h, 90h, 61h, 93h, 74h, 20h
		db	 90h, 70h, 6Fh, 95h, 77h, 65h
		db	 72h, 93h, 73h, 20h, 92h, 68h
		db	 65h, 20h, 91h, 97h, 6Dh, 98h
		db	 61h, 97h, 92h, 79h, 96h, 20h
		db	 93h, 70h, 6Fh, 91h, 73h, 73h
		db	 65h, 93h, 73h, 73h, 2Ch, 20h
		db	 90h, 62h, 75h, 93h, 74h, 20h
		db	 92h, 69h, 95h, 66h, 20h, 91h
		db	 74h, 68h, 90h, 65h, 72h, 65h
		db	 20h, 92h, 69h, 93h, 73h, 20h
		db	 93h, 6Eh, 6Fh, 94h, 6Eh, 65h
		db	 20h, 91h, 65h, 6Ch, 93h, 73h
		db	 65h, 20h, 93h, 77h, 68h, 6Fh
		db	 20h, 90h, 63h, 61h, 94h, 6Eh
		db	 20h, 91h, 64h, 65h, 92h, 66h
		db	 65h, 93h, 61h, 74h, 20h, 92h
		db	 68h, 69h, 93h, 6Dh, 2Ch, 20h
		db	 99h, 91h, 74h, 68h, 65h, 94h
		db	 6Eh, 20h, 90h, 49h, 20h, 93h
		db	 77h, 92h, 69h, 93h, 6Ch, 6Ch
		db	 20h, 91h, 64h, 65h, 92h, 64h
		db	 69h, 90h, 63h, 61h, 92h, 74h
		db	 65h, 20h, 90h, 6Dh, 92h, 79h
		db	 20h, 90h, 6Ch, 95h, 69h, 94h
		db	 66h, 65h, 20h, 93h, 74h, 6Fh
		db	 20h, 92h, 74h, 68h, 93h, 69h
		db	 73h, 20h, 90h, 74h, 61h, 97h
		db	 93h, 73h, 98h, 6Bh, 97h, 2Eh
		db	 96h, 22h, 94h,SCR_WAIT,SCR_WAIT,SCR_WAIT		; pause | pause | pause
		db	SCR_WAIT,SCR_SPK_KING,SCR_SCROLL,SCR_PARA, 22h, 83h		; pause | speaker: King Felishika (attr >) | scroll-text-up | layout-mode 1
		; Style-encoded speech -- King Felishika
		; "For the first time since the sandstorm began, you have brought hope
		;    into my heart, Duke Garland.  May God go with you on your quest."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 46h, 6Fh, 80h, 72h, 20h, 81h
		db	 74h, 68h, 65h, 20h, 80h, 66h
		db	 69h, 83h, 72h, 73h, 74h, 20h
		db	 80h, 74h, 82h, 69h, 83h, 6Dh
		db	 65h, 20h, 82h, 73h, 69h, 84h
		db	 6Eh, 83h, 63h, 65h, 20h, 81h
		db	 74h, 68h, 65h, 20h, 80h, 73h
		db	 61h, 84h, 6Eh, 83h, 64h, 85h
		db	 73h, 83h, 74h, 6Fh, 80h, 72h
		db	 84h, 6Dh, 20h, 82h, 62h, 87h
		db	 65h, 88h, 81h, 67h, 87h, 61h
		db	 84h, 86h, 6Eh, 2Ch, 20h, 83h
		db	 79h, 6Fh, 75h, 20h, 81h, 68h
		db	 61h, 83h, 76h, 65h, 20h, 80h
		db	 62h, 83h, 72h, 6Fh, 75h, 84h
		db	 67h, 68h, 83h, 74h, 20h, 68h
		db	 6Fh, 85h, 70h, 65h, 20h, 82h
		db	 69h, 84h, 6Eh, 83h, 74h, 6Fh
		db	 20h, 80h, 6Dh, 82h, 79h, 20h
		db	 80h, 68h, 65h, 61h, 72h, 83h
		db	 74h, 2Ch, 20h, 80h, 44h, 75h
		db	 83h, 6Bh, 65h, 20h, 87h, 80h
		db	 47h, 88h, 61h, 87h, 72h, 86h
		db	 84h, 80h, 6Ch, 61h, 84h, 6Eh
		db	 64h, 2Eh, 20h, 20h, 80h, 4Dh
		db	 61h, 82h, 79h, 20h, 83h, 47h
		db	 6Fh, 64h, 84h, 20h, 83h, 67h
		db	 6Fh, 20h, 82h, 77h, 69h, 83h
		db	 74h, 68h, 20h, 83h, 79h, 85h
		db	 6Fh, 75h, 20h, 83h, 6Fh, 84h
		db	 6Eh, 20h, 83h, 79h, 6Fh, 80h
		db	 75h, 72h, 20h, 83h, 71h, 75h
		db	 81h, 65h, 73h, 83h, 74h, 2Eh
		db	 84h, 22h, 84h,SCR_WAIT,SCR_WAIT,SCR_SCROLL		; pause | pause | scroll-text-up
		db	SCR_RESET,SCR_BREAK,SCR_BREAK,SCR_NORMAL,SCR_PARA		; reset text attribute | end-of-section | end-of-section | text-style: color 7 normal | layout-mode 1
		db	'Suddenly, the room grew cold.  A black mist swirled around them, then took on a hideous shape.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_SPK_NARR,SCR_BREAK		; pause | pause | pause | scroll-text-up | speaker: Jashiin/narrator (attr ?) | end-of-section
		db	SCR_PARA,SCR_COLOR6		; layout-mode 1 | text-style: color 6
		db	'"Are you the fool who dares to c'
		db	'hallenge me?  Don', 27h, 't be a'
		db	'bsurd!"'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK, 99h,SCR_WAIT		; pause | pause | scroll-text-up | end-of-section | pause
		db	SCR_SCROLL,SCR_PARA,SCR_BOLD,SCR_SPK_UNK, 9Ah, 22h		; scroll-text-up | layout-mode 1 | text-style: color 7 bold | speaker: unknown (attr =)
		; Style-encoded speech -- Jashiin (cont.)
		; "...And you must be the evil Jashiin!" (end of Jashiin speech)
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 90h, 41h, 94h, 6Eh, 93h, 64h
		db	 20h, 93h
		db	79h

;���� External Entry into Subroutine ��������������������������������������

narration_chapter_4:
		; Style-encoded speech -- Jashiin (cont.)
		; "...you must be the evil Jashiin!"
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 6Fh, 75h, 20h, 90h, 6Dh, 75h
		db	 93h, 73h, 74h, 20h, 92h, 62h
		db	 65h, 20h, 90h, 74h, 68h, 65h
		db	 20h, 91h, 65h, 92h, 76h, 69h
		db	 93h, 6Ch, 20h, 90h, 4Ah, 61h
		db	 92h, 73h, 68h, 69h, 94h, 69h
		db	 6Eh, 21h, 22h,SCR_WAIT,SCR_WAIT,SCR_SPK_NARR		; pause | pause | speaker: Jashiin/narrator (attr ?)
		db	SCR_SCROLL,SCR_PARA,SCR_COLOR6		; scroll-text-up | layout-mode 1 | text-style: color 6
		db	'"You shall address me as the Emperor of Chaos... '
		db	9Bh
		db	'THE EMPEROR OF CHAOS!"'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT, 22h		; pause | pause | pause | scroll-text-up | layout-mode 0 (direct write)
		db	'Young fool, I could destroy you now, but I need a little amusement.  I will give you some time to perform your little quest, but you must promise not to bore me."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA		; pause | pause | pause | scroll-text-up | layout-mode 1
		db	'"Of course, you have no hope of defeating me."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SPK_UNK,SCR_SCROLL,SCR_PARA		; pause | pause | pause | speaker: unknown (attr =) | scroll-text-up | layout-mode 1
		db	SCR_BOLD, 22h, 9Ah, 90h, 4Dh, 61h		; text-style: color 7 bold
		; Style-encoded speech -- Duke Garland
		; "Mark my words, evil one: I will not stop until I have reclaimed the
		;    nine holy crystals, and sealed you under the earth once again!"
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	 72h, 95h, 6Bh, 20h, 90h, 6Dh
		db	 92h, 79h, 20h, 90h, 77h, 6Fh
		db	 72h, 93h, 64h, 73h, 2Ch, 20h
		db	 91h, 65h, 92h, 76h, 69h, 93h
		db	 6Ch, 20h, 90h, 6Fh, 94h, 6Eh
		db	 65h, 3Ah, 20h, 90h, 49h, 20h
		db	 95h, 77h, 92h, 69h, 93h, 6Ch
		db	 6Ch, 20h, 93h, 6Eh, 6Fh, 74h
		db	 94h, 20h, 93h, 73h, 74h, 6Fh
		db	 94h, 70h, 20h, 90h, 75h, 94h
		db	 6Eh, 92h, 74h, 69h, 93h, 6Ch
		db	 20h, 90h, 49h, 20h, 91h, 68h
		db	 61h, 93h, 76h, 65h, 20h, 91h
		db	 72h, 65h, 93h, 63h, 6Ch, 90h
		db	 61h, 69h, 93h, 6Dh, 65h, 64h
		db	 20h, 91h, 74h, 68h, 65h, 20h
		db	 90h, 6Eh, 69h, 94h, 6Eh, 65h
		db	 20h, 93h, 68h, 6Fh, 92h, 6Ch
		db	 79h, 20h, 93h, 63h, 72h, 92h
		db	 79h, 73h, 90h, 74h, 61h, 6Ch
		db	 93h, 73h, 2Ch, 20h, 90h, 61h
		db	 94h, 6Eh, 93h, 64h, 20h, 92h
		db	 73h, 65h, 61h, 93h, 6Ch, 65h
		db	 64h, 20h, 95h, 79h, 6Fh, 75h
		db	 20h, 90h, 75h, 94h, 6Eh, 90h
		db	 64h, 65h, 72h, 20h, 91h, 74h
		db	 68h, 65h, 20h, 90h, 65h, 61h
		db	 72h, 93h, 74h, 68h, 20h, 90h
		db	 6Fh, 94h, 6Eh, 93h, 63h, 65h
		db	 20h, 90h
		db	61h

;���� External Entry into Subroutine ��������������������������������������

narration_chapter_5:
		db	094h, 6Eh, 93h, 64h, 20h, 93h, 66h		; small-portrait[4]
		db	 6Fh, 90h, 72h, 20h, 95h, 61h
		db	 93h, 6Ch, 6Ch, 21h, 99h, 94h
		db	 22h,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL		; pause | pause | pause | pause | scroll-text-up
		db	SCR_RESET,SCR_WAIT,SCR_DIRECT,SCR_NORMAL		; reset text attribute | pause | layout-mode 0 (direct write) | text-style: color 7 normal
		db	'The demon laughed, and the sound was like breaking glass.'
		db	SCR_MODE2,SCR_COLOR6,SCR_SPK_NARR		; layout-mode 2 | text-style: color 6 | speaker: Jashiin/narrator (attr ?)
		db	'"My labyrinths are immense, and '
		db	'run deep into the earth.  You', 27h
		db	'll soon lose your way, and then my underlings will finish you off."'
		db	SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA		; pause | pause | scroll-text-up | layout-mode 1
		db	'"It', 27h, 's been many years si'
		db	'nce a stray mortal has wandered into their realm. They are hungry for human flesh."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_RESET,SCR_BREAK,SCR_SCROLL		; pause | pause | pause | reset text attribute | end-of-section | scroll-text-up
		db	SCR_PARA,SCR_NORMAL		; layout-mode 1 | text-style: color 7 normal
		db	'With that, '
jashiin_disappear_text		db	'Jashiin disappeared leaving echo'
		db	'es of earsplitting laughter.'
anim_fn_wipe		dw	0F5F5h
anim_fn_fade		dw	0FEFDh
anim_fn_draw		dw	0F3EFh
; �� Garland final speech word table ����������������������������������
; Duke Garland's threat: SCR_BOLD "You haven't seen the last of me, Jashiin!"
; Each dw stores 2 consecutive script bytes (little-endian).
; Referenced individually by code that builds the speech incrementally.
garland_speech		dw	22FBh			; SCR_BOLD + '"'
gspeech_yo		dw	6F59h
gspeech_u_		dw	offset narration_chapter_2
gspeech_ha		dw	6168h
gspeech_ve	dw	6576h
gspeech_nt	dw	offset narration_chapter_3
gspeech_t_	dw	offset opening_narration
gspeech_se	dw	6573h
gspeech_en	dw	6E65h
gspeech_t2_	dw	7420h
gspeech_he	dw	6568h
gspeech_l_	dw	6C20h
		db	'ast of m'
gspeech_e_	dw	offset narration_chapter_4
		db	' Jashiin!'
		db	SCR_MODE2		; layout-mode 2
		db	'Your reign of evil is near its end!"'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_END_SCRIPT, 58h, 25h		; pause | pause | pause | end-of-script
		db	SCR_RESET, 00h, 00h, 03h, 68h, 21h		; reset text attribute
		db	0FCh,0FCh, 04h, 07h, 70h, 23h		; ctrl 0xFC | ctrl 0xFC
		db	 01h,SCR_BREAK, 04h, 07h, 70h, 24h		; end-of-section
		db	 04h,SCR_BREAK, 04h, 07h, 78h, 25h		; end-of-section
		db	 06h,SCR_SCROLL, 04h, 07h, 78h, 28h		; scroll-text-up
		db	 06h, 02h, 04h, 07h, 70h, 29h
		db	 04h, 03h, 04h, 07h, 70h, 2Ah
		db	 01h, 03h, 04h, 07h, 68h, 2Ch
		db	0FCh, 04h, 04h, 07h,SCR_END_SCRIPT, 01h		; ctrl 0xFC | end-of-script

		; Style-encoded speech -- Jashiin (departing threat)
		; "Beware, for I shall wake from my sleep of 2,000 years
		;  and once again reign over the world."
		; (0x01-0x08 between chars = per-character color-cycle animation)
		db	 08h, 01h, 42h, 65h, 03h, 77h
		db	 61h, 04h, 72h, 65h, 2Ch, 20h
		db	 03h, 66h, 6Fh, 04h, 72h, 20h
		db	 04h, 49h, 20h, 01h, 73h, 68h
		db	 61h, 03h, 6Ch, 6Ch, 20h, 77h
		db	 04h, 61h, 6Bh, 03h, 65h,SCR_END_SCRIPT		; end-of-script
		db	 01h, 06h, 03h, 66h, 72h, 6Fh
		db	 03h, 6Dh, 20h, 02h, 6Dh, 01h
		db	 79h, 20h, 03h, 73h, 01h, 6Ch
		db	 65h, 65h, 01h, 70h, 20h, 6Fh
		db	 66h, 20h, 03h, 32h, 2Ch, 04h
		db	 30h, 30h, 30h, 20h, 01h, 79h
		db	 65h, 04h, 61h, 72h, 03h, 73h
		db	SCR_END_SCRIPT, 01h, 02h, 04h, 61h, 02h		; end-of-script
		db	 6Eh, 03h, 64h, 20h, 03h, 6Fh
		db	 02h, 6Eh, 63h, 65h, 20h, 04h
		db	 61h, 67h, 61h, 01h, 69h, 6Eh
		db	 20h, 02h, 72h, 65h, 04h, 69h
		db	 01h, 67h, 6Eh, 20h, 03h, 6Fh
		db	 76h, 04h, 65h, 72h, 20h, 01h
		db	 74h, 68h, 65h, 20h, 04h, 77h
		db	 6Fh, 72h, 03h, 6Ch, 64h, 2Eh
		db	 02h

		; Animation frame timing sequence (end-of-chapter transition)
		db	 00h, 01h, 01h, 01h, 02h, 02h
		db	 01h, 01h, 02h, 02h, 03h, 03h
		db	 05h
		; ── Character/font glyph index table ──────────────────────────────
		; Maps ASCII codes (0x00–0xC1) to glyph indices in the font sheet.
		; Index 0 = no glyph (space/unprintable). Used by the text renderer
		; to look up which glyph bitmap to draw for each character.
char_glyph_index:
		db	7 dup (0)
		db	 01h, 02h, 03h, 04h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 0Eh, 0Fh, 10h, 11h, 12h
		db	 13h, 14h, 15h, 16h, 00h, 00h
		db	 00h, 17h, 18h, 19h, 1Ah, 1Bh
		db	 1Ch, 1Dh, 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h, '()*+,-.'
		db	 00h, 00h, 2Fh, 30h, 31h, 32h
		db	 33h, 00h, 00h, 34h, 35h, 36h
		db	 37h, 38h, 00h, 39h, 26h, 3Ah
		db	 00h
		db	18 dup (0)
		db	 3Bh, 3Ch, 3Dh, 00h, 00h, 00h
		db	 3Eh, 3Fh, 40h, 41h
		db	30 dup (0)
		db	 42h, 43h, 44h, 45h
		db	30 dup (0)
		db	 46h, 47h, 16h
		db	31 dup (0)
		db	 48h, 49h, 4Ah
		db	97 dup (0)
		db	 4Bh, 4Ch, 4Dh
		db	31 dup (0)
		db	 4Eh, 4Fh, 50h
		db	32 dup (0)
		db	51h
		db	33 dup (0)
		db	 52h, 53h
		db	32 dup (0)
		db	 54h, 55h, 56h
		db	31 dup (0)
		db	 57h, 58h, 59h, 5Ah
		db	30 dup (0)
		db	 5Bh, 5Ch, 5Dh, 5Eh
		db	30 dup (0)
		db	 5Fh, 60h, 61h, 62h
		db	30 dup (0)
		db	 63h, 64h
		db	32 dup (0)
		db	 65h, 66h, 67h, 68h, 69h
		db	29 dup (0)
		db	'jklmnopqrs'
		db	24 dup (0)
		db	'tuvwxyz{|}'
		db	24 dup (0)
		db	 7Eh, 7Fh, 80h, 81h, 82h, 83h
		db	 84h, 85h, 86h, 87h, 88h, 89h
		db	 00h, 00h, 00h, 00h, 0Fh, 8Ah
		db	 8Bh, 8Ch, 00h
		db	13 dup (0)
		db	 2Fh, 8Dh, 8Eh, 8Fh, 90h, 91h
		db	 92h, 93h, 94h, 95h, 96h, 97h
		db	 00h, 00h, 00h, 98h, 99h, 9Ah
		db	 9Bh, 9Ch, 9Dh
		db	14 dup (0)
		db	 9Eh, 9Fh,SCR_ATTR_RST,0A1h,SCR_ATTR_RST2,0A3h		; attr-restore | ctrl 0xA1 | attr-restore | ctrl 0xA3
		db	0A4h,0A5h,0A6h,0A7h,0A8h,0A9h		; ctrl 0xA4 | ctrl 0xA5 | ctrl 0xA6 | ctrl 0xA7 | ctrl 0xA8 | ctrl 0xA9
		db	 16h, 00h,0AAh,0ABh,0ACh,0ADh		; ctrl 0xAA | ctrl 0xAB | ctrl 0xAC | ctrl 0xAD
		db	0AEh,0AFh		; ctrl 0xAE | ctrl 0xAF
		db	14 dup (0)
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h		; ctrl 0xB0 | ctrl 0xB1 | ctrl 0xB2 | ctrl 0xB3 | ctrl 0xB4 | ctrl 0xB5
		db	0B6h,0B7h,0B8h, 26h, 26h,0B9h		; ctrl 0xB6 | ctrl 0xB7 | ctrl 0xB8 | ctrl 0xB9
		db	0BAh,0BBh,0BCh,0BDh,0BEh,0BFh		; ctrl 0xBA | ctrl 0xBB | ctrl 0xBC | ctrl 0xBD | ctrl 0xBE | ctrl 0xBF
		db	0C0h,0C1h		; ctrl 0xC0 | ctrl 0xC1
		db	13 dup (0)
		; ── Character pixel width table ────────────────────────────────────
		; One byte per glyph index: pixel width used by text layout engine
		; to advance the cursor after drawing each character.
char_pixel_widths:
		db	2, 2, 3, 1, 0, 0
		db	2, 2, 3, 1, 1, 1
		db	2, 2, 0, 1, 2, 1
		db	7 dup (1)
		db	3, 2, 1, 1, 2, 1
		db	9 dup (0)
		db	2, 0
		db	9 dup (0)
		db	1, 0, 0, 0, 0, 0
		db	1, 2, 2, 2, 1, 1
		db	1, 0, 0, 1, 0, 1
		db	1, 0, 0, 2, 1, 0
		db	2, 0, 1, 1, 0, 0
		db	0, 1, 1, 0, 0, 0
		db	1, 1, 1, 2, 0, 3
		db	1, 0, 5, 4, 4, 4
		db	6, 8, 5, 3, 4, 4
		db	6, 6, 6, 5, 6, 8
		db	7, 5, 7, 7, 7, 7
		db	7, 7, 7, 7, 3, 4
		db	6, 6, 6, 7
		db	9 dup (8)
		db	5, 8, 8
		db	8 dup (8)
		db	 07h, 08h, 08h, 08h, 08h, 08h
		db	 07h, 05h, 03h, 05h, 06h, 07h
		db	 07h, 08h, 08h, 07h, 08h, 07h
		db	 07h, 08h, 08h, 05h, 06h, 08h
		db	 05h, 08h, 07h, 07h, 08h, 08h
		db	 08h, 07h, 06h, 08h, 08h, 08h
		db	 07h, 07h, 07h, 04h, 08h, 04h
		db	07h, 08h		; (end of char width table)

		; Opening scene resource file table
		; Format per entry: [archive_0indexed][chunk_1indexed][filename\0]
		db	00h, 17h, 'nec.grp',   0	; zelres1 chunk 23
		db	00h, 12h, 'hou.grp',   0	; zelres1 chunk 18
		db	00h, 0Fh, 'dmaou.grp', 0	; zelres1 chunk 15
		db	00h, 28h, 'zopn.msd',  0	; zelres1 chunk 40 (opening music)
		db	00h, 1Eh, 'ttl1.grp',  0	; zelres1 chunk 30
		db	00h, 1Fh, 'ttl2.grp',  0	; zelres1 chunk 31
		db	00h, 20h, 'ttl3.grp',  0	; zelres1 chunk 32 (Zeliard logo)
		db	00h, 27h, 'zend.msd',  0	; zelres1 chunk 39 (ending music)
		db	00h, 21h, 'waku.grp',  0	; zelres1 chunk 33
		db	00h, 0Eh, 'ame.grp',   0	; zelres1 chunk 14
		db	00h, 10h, 'hime.grp',  0	; zelres1 chunk 16
		db	00h, 13h, 'isi.grp',   0	; zelres1 chunk 19
		db	00h, 1Ah, 'oui.grp',   0	; zelres1 chunk 26
		db	00h, 1Ch, 'sei.grp',   0	; zelres1 chunk 28
		db	00h, 22h, 'yuu1.grp',  0	; zelres1 chunk 34
		db	00h, 23h, 'yuu2.grp',  0	; zelres1 chunk 35
		db	00h, 24h, 'yuu3.grp',  0	; zelres1 chunk 36
		db	00h, 25h, 'yuu4.grp',  0	; zelres1 chunk 37
		db	00h, 26h, 'yuup.grp',  0	; zelres1 chunk 38
		db	00h, 1Bh, 'oup.grp',   0	; zelres1 chunk 27
		db	00h, 14h, 'maop.grp',  0	; zelres1 chunk 20
		db	00h, 00h, 'game.bin',  0	; game main binary


seg_a		ends



		end	start
