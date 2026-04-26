PAGE  59,132

;==========================================================================
;
;  OPENING_SCENE - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

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
palette_data_a	equ	953Dh		; palette data A (resource table: nec.grp, zelres1 chunk 23)
palette_data_b	equ	9547h		; palette data B (resource table: nec.grp entry ref)
scene_data_c	equ	9551h		; scene data C (resource table: hou.grp, zelres1 chunk 18)
glyph_small	equ	955Dh		; small glyph data (resource table: dmaou.grp, zelres1 chunk 15)
res_zopn_msd	equ	9568h		; resource ref: zopn.msd (opening music, zelres1 chunk 40)
glyph_large	equ	9573h		; large glyph data (resource table: ttl1.grp, zelres1 chunk 30)
scene_data_d	equ	957Eh		; scene data D (resource table: ttl2.grp, zelres1 chunk 31)
res_ttl3_grp	equ	9589h		; resource ref: ttl3.grp (Zeliard logo, zelres1 chunk 32)
res_zend_msd	equ	9594h		; resource ref: zend.msd (ending music, zelres1 chunk 39)
scene_data_e	equ	959Fh		; scene data E (resource table: waku.grp, zelres1 chunk 33)
res_ame_grp	equ	95A9h		; resource ref: ame.grp (sky/rain scene, zelres1 chunk 14)
scene_data_f	equ	95B4h		; scene data F (resource table: hime.grp, zelres1 chunk 16)
res_isi_grp	equ	95BEh		; resource ref: isi.grp (stone scene, zelres1 chunk 19)
res_oui_grp	equ	95C8h		; resource ref: oui.grp (zelres1 chunk 26)
res_sei_grp	equ	95D2h		; resource ref: sei.grp (zelres1 chunk 28)
res_yuu1_grp	equ	95DDh		; resource ref: yuu1.grp (hero anim frame 1, zelres1 chunk 34)
res_yuu2_grp	equ	95E8h		; resource ref: yuu2.grp (hero anim frame 2, zelres1 chunk 35)
res_yuu3_grp	equ	95F3h		; resource ref: yuu3.grp (hero anim frame 3, zelres1 chunk 36)
scene_data_g	equ	95FEh		; scene data G (resource table: yuu4.grp, zelres1 chunk 37)
scene_data_h	equ	9609h		; scene data H (resource table: yuup.grp, zelres1 chunk 38)
res_oup_grp	equ	9613h		; resource ref: oup.grp (zelres1 chunk 27)
res_maop_grp	equ	961Eh		; resource ref: maop.grp (enemy image, zelres1 chunk 20)
scene_data_i	equ	97C0h		; scene data I (runtime buffer, not in resource table)
aux_buf_seg	equ	0B000h		; auxiliary buffer segment (0xB000)
cga_text_seg	equ	0B800h		; CGA text mode VGA segment (0xB800)
ext_seg_d000	equ	0D000h		; extended segment 0xD000
gvar_timer_lo	equ	0FF1Ah		; timer counter low word (0xFF1A)
gvar_skip_input	equ	0FF1Dh		; input skip flag (zeliard.inc: gvar_skip_input)
gvar_enable_all	equ	0FF26h		; enable all flag (zeliard.inc: gvar_enable_all)
gvar_key_state	equ	0FF29h		; key state (0xFF29)
gvar_game_seg	equ	0FF2Ch		; game data segment (zeliard.inc: gvar_game_seg)
gvar_volume_b	equ	0FF75h		; volume B (zeliard.inc: gvar_volume_b)
null_ofs	equ	0		; null/zero offset
font_plane_b	equ	660h		; character font data plane B
font_plane_c	equ	0CC0h		; character font data plane C

; Bytes 0x01-0x08 and 0x80-0x9F appear between individual characters in
; animated speech to advance a color-cycle counter, making the text shimmer.
; Named by hex value for clarity.
ANIM_01	equ	001h
ANIM_02	equ	002h
ANIM_03	equ	003h
ANIM_04	equ	004h
ANIM_05	equ	005h
ANIM_06	equ	006h
ANIM_07	equ	007h
ANIM_08	equ	008h
ANIM_80	equ	080h
ANIM_81	equ	081h
ANIM_82	equ	082h
ANIM_83	equ	083h
ANIM_84	equ	084h
ANIM_85	equ	085h
ANIM_86	equ	086h
ANIM_87	equ	087h
ANIM_88	equ	088h
ANIM_89	equ	089h
ANIM_8A	equ	08Ah
ANIM_8B	equ	08Bh
ANIM_8C	equ	08Ch
ANIM_8D	equ	08Dh
ANIM_8E	equ	08Eh
ANIM_8F	equ	08Fh
ANIM_90	equ	090h
ANIM_91	equ	091h
ANIM_92	equ	092h
ANIM_93	equ	093h
ANIM_94	equ	094h
ANIM_95	equ	095h
ANIM_96	equ	096h
ANIM_97	equ	097h
ANIM_98	equ	098h
ANIM_99	equ	099h
ANIM_9A	equ	09Ah
ANIM_9B	equ	09Bh
ANIM_9C	equ	09Ch
ANIM_9D	equ	09Dh
ANIM_9E	equ	09Eh
ANIM_9F	equ	09Fh

; Used in narration db sequences between text strings.
SCR_END_SCRIPT	equ	0FFh	; end of script / page terminator
CR		equ	0Dh	; carriage return (line break in prologue text)
ENTER_KEY	equ	0Dh	; Enter key scancode (same byte, different context)
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
		call	word ptr cs:disp_narr_chap3
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
		call	word ptr cs:disp_game_fn
		mov	byte ptr cs:gvar_volume_b,4
		mov	si,scene_sprite_a
		call	word ptr cs:disp_data_6F59
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
						call	word ptr cs:disp_narr_chap2
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
		call	word ptr cs:disp_narr_chap2
		WAIT_FRAME 0Fh
		mov	al,3
		mov	bx,1720h
		call	word ptr cs:disp_narr_chap2
		WAIT_FRAME 0F0h
		xor	al,al			; Zero register
		mov	bx,94h
		mov	cx,501Eh
		call	word ptr cs:jashiin_speech_2+80h	; ('es')
		LOAD_DATA res_zopn_msd, vga_seg
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
		mov	si,gfx_plane_b
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		call	word ptr cs:disp_drv_seg_3
		mov	al,0F0h
		call	timer_wait_loop
		xor	al,al			; Zero register
		mov	bx,0B48h
		mov	cx,3180h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
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
		mov	di,scene_framebuf
		call	word ptr cs:disp_narr_chap3
		mov	byte ptr ds:gvar_timer_lo,0
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	fill_buffer
		mov	si,scene_sprite_d
		call	word ptr cs:disp_narr_open
		mov	al,0F0h
		call	timer_wait_loop
		mov	ax,0C7h
		mov	cx,64h

scene_color_rotate_loop:
						push	cx
						mov	byte ptr ds:gvar_timer_lo,0
						push	ax
						call	word ptr cs:disp_set_drv_seg
						pop	ax
						push	ax
						mov	al,ah
						call	word ptr cs:disp_set_drv_seg
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
										call	word ptr cs:disp_chap2_call
										pop	si
										jmp	short anim_read_byte

anim_char_render:
						call	char_render_proc
						mov	al,14h
						call	timer_wait_loop
						jmp	short anim_main_loop

sprite_anim_proc		endp

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
		call	word ptr cs:disp_narr_chap4
		pop	ax
		mov	bx,ds:render_state_a
		mov	cl,ds:render_state_b
		mov	ah,7
		call	word ptr cs:disp_narr_chap4
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

; ============================================================
; TIMING & INPUT LOOPS
; ============================================================

timer_wait_loop		proc	near

timer_check_input:
						test	byte ptr cs:gvar_skip_input,0FFh
						jnz	timer_exit_to_game			; Jump if not zero
						cmp	byte ptr cs:gvar_key_state,ENTER_KEY
						je	timer_exit_to_game			; Jump if equal
						call	interrupt_handler_cascade
						cmp	cs:gvar_timer_lo,al
						jb	timer_check_input			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

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
		mov	si,res_ttl3_grp
		mov	es,cs:gvar_game_seg
		mov	di,gfx_plane_b
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:gvar_timer_lo,0
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,gfx_plane_b
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	ax,1
		call	word ptr cs:gfx_palette_fn
		call	credits_scroll_display
		jmp	short trans_exit

scene_transition_wait:

trans_wait_timer:
						test	byte ptr cs:gvar_skip_input,0FFh
						jnz	trans_exit			; Jump if not zero
						cmp	byte ptr cs:gvar_key_state,ENTER_KEY
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
		db	ANIM_87, ' '	; animation code + space (script entry point)
		db	'   Copyright (C)1987,1990 GAME ARTS    ', CR, '    Copyright (C)1990 Sierra On-Line    '
		db	SCR_END_SCRIPT		; end of script / copyright page terminator
		db	3 dup (0)		; padding before begin_gameplay code

begin_gameplay:
		RESET_STACK
		mov	byte ptr cs:gvar_skip_input,0
		mov	byte ptr cs:gvar_key_state,0
		mov	word ptr cs:script_pc,79C6h
		mov	ax,5
		call	word ptr cs:gfx_palette_fn
		LOAD_DATA res_zend_msd, vga_seg
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
		call	word ptr cs:disp_game_fn
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:disp_game_fn
		call	script_interpreter
		mov	ax,9
		call	word ptr cs:gfx_palette_fn
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:disp_game_fn
		LOAD_DATA res_ame_grp, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		call	script_interpreter
		xor	ax,ax			; Zero register
		call	word ptr cs:disp_font_inv
		mov	ax,6
		call	word ptr cs:gfx_palette_fn
		mov	bx,410h
		mov	cx,4868h
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		call	word ptr cs:disp_game_fn
		LOAD_DATA scene_data_c, vga_seg
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
		mov	di,scene_framebuf
		call	word ptr cs:disp_game_fn
		call	script_interpreter
		call	script_interpreter
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	di,0
		mov	bx,1728h
		mov	cx,2230h
		mov	al,7
		call	word ptr cs:disp_data_7420
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
		call	word ptr cs:disp_game_fn
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
		call	word ptr cs:disp_game_fn
		LOAD_DATA scene_data_f, vga_seg
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
		LOAD_DATA res_isi_grp, vga_seg
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
		LOAD_DATA res_oui_grp, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	di,scene_framebuf
		mov	bx,1610h
		mov	cx,2468h
		mov	al,5
		call	word ptr cs:disp_data_7420
		call	script_interpreter
		xor	ax,ax			; Zero register
		call	word ptr cs:disp_font_inv
		call	script_interpreter
		LOAD_DATA res_sei_grp, vga_seg
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
		call	word ptr cs:disp_font_inv
		mov	ax,6
		call	word ptr cs:gfx_palette_fn
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:disp_load_setup
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:disp_game_fn
		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:disp_load_setup
		mov	es,cs:gvar_game_seg
		mov	di,screen_buf_1
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:disp_game_fn
		call	script_interpreter
		call	script_interpreter
		LOAD_DATA res_oup_grp, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,screen_buf_1
		call	decompress_image
		xor	ax,ax			; Zero register
		call	word ptr cs:disp_font_inv
		mov	ax,8
		call	word ptr cs:gfx_palette_fn
		mov	bx,1515h
		mov	cx,315Dh
		call	word ptr cs:disp_load_setup
		mov	es,cs:gvar_game_seg
		mov	di,screen_buf_1
		mov	bx,1618h
		call	word ptr cs:disp_script_area
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
						call	word ptr cs:disp_load_setup
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
		call	word ptr cs:disp_load_setup
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:disp_load_setup
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:disp_game_fn
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
						call	word ptr cs:disp_load_setup
						mov	al,0Fh
						call	gameplay_timer_loop
						pop	bx
						pop	dx
						inc	bh
						dec	dh
						pop	cx
						loop	gameplay_input_loop		; Loop if cx > 0

		xor	ax,ax			; Zero register
		call	word ptr cs:disp_font_inv
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		LOAD_DATA res_yuu1_grp, vga_seg
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,scene_framebuf
		call	decompress_image
		mov	es,cs:gvar_game_seg
		mov	di,scene_framebuf
		mov	bx,1010h
		mov	cx,3160h
		call	word ptr cs:disp_game_fn
		call	script_interpreter
		LOAD_DATA res_yuu2_grp, vga_seg
		mov	si,res_yuu3_grp
		mov	di,ext_seg_d000
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
		mov	di,scene_framebuf
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
		mov	di,scene_framebuf
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

gameplay_timer_loop:

gameplay_wait_elapsed:
						call	gameplay_input_handler
						cmp	cs:gvar_timer_lo,al
						jb	gameplay_wait_elapsed			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

gameplay_input_handler:
		test	byte ptr cs:gvar_skip_input,0FFh
		jnz	gameplay_exit_to_menu			; Jump if not zero
		cmp	byte ptr cs:gvar_key_state,ENTER_KEY
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
		mov	si,res_maop_grp
		mov	di,vga_seg
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	ax,0FFFFh
		jmp	word ptr cs:scene_data_b

timer_wait_loop		endp

		; Two padding bytes between timer_wait_loop and script_interpreter.
		; Unreachable: timer_wait_loop ends with jmp word ptr cs:scene_data_b.
		db	00h			; padding
		db	SCR_ATTR_RST		; padding (0xA0)

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
		call	word ptr cs:disp_narr_chap4
		pop	cx
		pop	bx
		pop	ax
		mov	ah,ds:text_color_bg
		call	word ptr cs:disp_narr_chap4
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
		call	word ptr cs:disp_game_fn
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
		call	word ptr cs:disp_game_fn
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
		call	word ptr cs:disp_game_fn
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
		call	word ptr cs:disp_game_fn
		jmp	script_refetch

script_interpreter		endp

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
		; 0x79C6 = initial script_pc value pointing to opening_narration
		dw	79C6h			; initial script_pc (opening_narration)
		dw	0			; initial text_x_pos
		dw	0			; initial text_y_pos / text_color_fg / text_color_bg
		dw	0			; initial text_attr / reserved

; ============================================================
; IMAGE PROCESSING
; ============================================================

decompress_image		proc	near
		call	rle_unpack_core
		jmp	short decomp_palette_transform

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

		db	'           Two thousand years, ', CR, 'from the dark reaches of another galaxy,', CR, '        a demon with not a shred', CR
		db	'      of compassion for humankind,', CR, '         descended upon earth.', CR, CR, '          He defiled the land,', CR
		db	'  sending vile creatures to live in it,', CR, '   and thus became ruler of the world.', CR, CR, '         The King of Felishika,', CR
		db	'     appalled by what had happened,', CR, '          prayed to the Spirit', CR, '      of the Holy Land of Zeliard', CR
		db	'    for help in defeating this monster.', CR, CR, '    With the help of the holy crystals', CR, '       called Tears of Esmesanti,', CR
		db	'    the King managed to wrest power', CR, '    from the fiend and seal him deep', CR, '     within the bowels of the earth.', CR
		db	CR, '            And once again,', CR, ' the light of peace came to shine upon', CR, '              the earth.', CR
		db	CR, CR, 'However, it is written in', CR, '       the Sixth Book of Esmesanti:', CR, '                    The Age of Darkness.', CR
		db	SCR_END_SCRIPT, ' '
		db	'               At last,                ', CR, '     the door of destiny was opened.    ', CR, '        The labyrinths are deep,        ', CR
		db	'          and the way is long.          ', CR, '     Will Duke Garland be successful    ', CR, '   in dethroning the Emperor of Chaos?  ', CR
		db	SCR_END_SCRIPT, ' '
		db	'         Fantasy Action Game           ', CR, '               ZELIARD                  ', CR, CR, '             -- STAFF --                ', CR
		db	CR, 'Producer -- Japanese Version', CR, '                      Mitsuhiro Mazda   ', CR, CR, 'Producer -- English Version', CR
		db	'                        Josh Mandel     ', CR, CR, 'Lead Programmer      Tomoyuki Shimada   ', CR, CR, 'Graphic Designers     Akihiko Yoshida   ', CR
		db	'                      Masatoshi Azumi   ', CR, CR, 'English Text Translation by', CR, '                       Marti McKenna    ', CR
		db	CR, 'Music Composers  -- MECANO ASSOCIATES --', CR, '                    Fumihito Kasatani   ', CR, '                    Nobuyuki Aoshima    ', CR
		db	CR, 'Story Maker           Masaru Takeuchi   ', CR, CR, 'Sound Effects by     Tomoyuki Shimada   ', CR, CR
		db	'Advisers               Osamu Harada     ', CR, '                       Hiromi Ohba      ', CR, '                       Greg Miyaji      ', CR
		db	CR, 'System Designer      Rocky Cave Maker   ', CR, CR, 'Special Thanks to', CR, '                    Toshiyuki Uchida    ', CR
		db	'                       Yuzo Sunaga      ', CR, '                     Takeshi Miyaji     ', CR, '                     Naozumi Honma      ', CR
		db	'                     Toshi Masubuchi    ', CR, '                     Ray E. Nakazato    ', CR, '                     Hiroyuki Koyama    ', CR
		db	'                     Satoshi Uesaka     ', CR, '              Sierra On-Line Japan, Inc.', CR, '                    Eiji (Ed) Nagano    ', CR
		db	CR, CR, CR, '    Copyright (C)1987,1990 GAME ARTS    ', CR, '    Copyright (C)1990 Sierra On-Line    ', CR
		db	'  This edition first published 1987 by  ', CR, '  GAME ARTS Co.,Ltd./ Tomoyuki Shimada  ', CR
		db	SCR_END_SCRIPT				; end of script
		db	'P'				; scene page ID (parameter after SCR_END_SCRIPT)
		db	SCR_RESET				; reset style
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'Once, long ago, a terrible storm came to the land of Zeliard. '
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'Dark clouds filled the sky; lightning flashed and thunder crashed. '
		db	SCR_MODE2		; layout-mode 2
		db	'Day after day, rain poured from the heavens as if in lament.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_WAIT				; pause
		db	'On the seventh day of rain, a beautiful young girl stood on her balcony watching this dark, sad rain.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'The girl was Princess Felicia la Felishika.  She was the only daughter of King Felishika, and the light of his life.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_WAIT		; pause
		db	'Her smiles were like sunshine, her voice as beautiful as that of an angel.  She was adored by the people of the kingdom.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause

dialogue_scene_start:
		db	SCR_SPK_PRINC				; speaker: Princess Felicia
		db	SCR_SCROLL				; scroll text up
		db	SCR_WAIT				; pause
		db	SCR_PARA				; layout: paragraph
		db	SCR_BOLD				; bold text
		db	SCR_ATTR_RST				; attr restore
		db	'"What a dreadful storm!  Will it never end?"'
		db	SCR_RESET				; reset style
		db	SCR_WAIT3				; long pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_WAIT				; pause
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'Just as the princess spoke these words, the raindrops turned to grains of sand which covered the ground below her. '
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_SCROLL				; scroll text up
		db	SCR_WAIT				; pause
		db	SCR_PARA				; layout: paragraph
		db	'As she watched, a startling transformation began to take place.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'In an instant, the green hills and plains turned a dusty brown. '
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'Trees and flowers crumpled and were buried. '
		db	SCR_PARA		; layout-mode 1
		db	'Rivers and lakes disappeared beneath the sand.'
		db	SCR_MODE3		; layout-mode 3
		db	'This ever-green land was turning to desert before her very eyes.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_WAIT				; pause
		db	SCR_PARA				; layout: paragraph
		db	SCR_BOLD				; bold text
		db	SCR_SPK_PRINC				; speaker: Princess Felicia
		db	SCR_ATTR_RST2		; attr-restore
		db	'"How can this be?" '
		db	SCR_RESET				; reset style
		db	SCR_NORMAL				; normal text
		db	'she cried, '
		db	SCR_SPK_PRINC				; speaker: Princess Felicia
		db	SCR_BOLD				; bold text
		db	'"What evil power could cause such a terrible thing to happen?"'
		db	SCR_RESET				; reset style
		db	SCR_WAIT3				; long pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'Princess Felicia shivered as she felt a dark presence near her, '
		db	SCR_BREAK		; end-of-section
		db	'and suddenly, a terrifying voice bellowed as loud as thunder...'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	SCR_COLOR6				; color 6 text
		db	SCR_SPK_NARR				; speaker: narrator
		db	'"I am Jashiin, the Emperor of Chaos.  The descendants of those who imprisoned me under the earth shall know that my wrath has smoldered for two thousand years!"'
		db	SCR_RESET				; reset style
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_BREAK				; end of section
		db	SCR_BREAK				; end of section
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	SCR_SPK_NARR				; speaker: narrator
jashiin_speech_2		db	'"Beautiful Princess Felicia, you'
		db	' will make a lovely and terrifying symbol of my awakening.  Your father will not make the mistakes of his ancestors!"'
		db	SCR_RESET				; reset style
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL		; text-style: color 7 normal
narration_stone_scene		db	'As the words of the demon resoun'
		db	'ded over the land, Princess Felicia was turned to stone.'

; ============================================================
; DATA SECTION -- Opening Scene Script & Narration
; ============================================================

opening_narration:
		db	SCR_BREAK			; script ctrl: FD

narration_chapter_2:
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	'The rain of sand continued for 108 days and transformed the once-fertile land into desert.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'The people of the kingdom wept at the terrible fate of their country, and of their princess.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	SCR_NORMAL				; normal text
		db	'The King wept most of all. '
		db	SCR_PARA				; layout: paragraph
		db	SCR_SPK_KING				; speaker: King Felishika
		db	SCR_BOLD				; bold text
		db	'"Oh, my beloved Felicia!  I fear the Age of Darkness is upon us.  I am powerless to stop it ... and powerless to help you."'
		db	SCR_RESET				; reset style
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'But the tears of the King and his people soon awakened another power.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	'As the King grieved, an apparition appeared before him.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_SPK_DEMON				; speaker: Jashiin demon
		db	SCR_DIRECT				; layout: direct
		db	SCR_BOLD				; bold text
		db	'"I am the Guardian Spirit of the Holy Land of Zeliard.  The demon Jashiin has been resurrected, and indeed his evil magic will plunge this world into the Age of Darkness once again."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'"Heed my words, King Felishika: There is but one way to stop this demon.  A brave warrior must venture into the labyrinths and recover the nine Holy Crystals, the Tears of Esmesanti."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'"'
		db	'Many terrible creatures dwell within the labyrinths, all of them'
		db	' Jashiin', 27h, 's minions.  No '
		db	'mortal man could defeat these deadly beasts and wrest the crystals from them."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'"However, there is one with the power to oppose Jashiin.'
		db	SCR_MODE2		; layout-mode 2
		db	'The man who is destined to fight him will soon arrive in your kingdom."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'"This man is the only being strong enough to banish Jashiin forever."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'"'
		db	'You must await the arrival of this brave and noble knight, and tell him everything.  Only with his help can you hope to restore this land to its former beauty, and free your daughter from her terrible curse."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_RESET				; reset style
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'Having spoken these words, the Spirit disappeared.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	'King Felishika could not believe what he had seen.'
		db	SCR_MODE2				; layout: mode 2
		db	SCR_BOLD				; bold text
		db	'"Surely my mind is playing trick'
		db	's on me!  I', 27h, 'm afraid I h'
		db	'ave gone mad with grief."'
		db	SCR_NORMAL				; normal text
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA		; layout-mode 1
		db	'But the next day, a stranger appeared in the kingdom...'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_SPK_UNK				; speaker: Duke Garland
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	SCR_BOLD				; bold text
		db	'"What a desolate place!  Why has the Spirit led me here?"'
		db	SCR_WAIT		; pause

narration_chapter_3:
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_RESET				; reset style
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'Guided by the light of the Spirit, brave Duke Garland had journeyed many days to the land of Zeliard.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	'Entering the castle, he was quickly escorted to the throne of the grieving King Felishika.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_SPK_KING				; speaker: King Felishika
		db	SCR_BREAK				; end of section
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BOLD				; bold text
		db	SCR_DIRECT				; layout: direct
		db	'"', ANIM_81
		; Style-encoded speech -- King Felishika
		; "Duke Garland! You must be the man of destiny of whom the Spirit spoke.
		;    I beg of you to destroy the demon Jashiin who has cursed my kingdom
		;    and turned my beloved daughter to stone."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	'Duke ', ANIM_80
		db	'Garla', ANIM_84
		db	'n', ANIM_83, 'd!  '
		db	ANIM_84, ANIM_85, 'Y', ANIM_87, 'o', ANIM_88
		db	'u', ANIM_87, ' ', ANIM_86, ANIM_80, 'm'
		db	'u', ANIM_81, 's', ANIM_83, 't '
		db	ANIM_82, 'be ', ANIM_81, 't'
		db	'he ', ANIM_80, 'ma'
		db	ANIM_84, 'n ', ANIM_83, 'o', ANIM_84
		db	'f ', ANIM_81, 'des'
		db	ANIM_82, 'tiny '
		db	ANIM_83, 'o', ANIM_84, 'f ', ANIM_83
		db	'who', ANIM_84, 'm '
		db	ANIM_81, 'the ', ANIM_83
		db	'S', ANIM_82, 'piri'
		db	't ', ANIM_83, 'spo'
		db	ANIM_81, 'ke.  '
		db	ANIM_84, ANIM_97, ANIM_80, 'I', ANIM_98, ANIM_87
		db	' ', ANIM_81, ANIM_88, 'b', ANIM_87, 'e'
		db	ANIM_85, ANIM_86, 'g ', ANIM_83, 'o'
		db	ANIM_84, 'f ', ANIM_85, 'yo'
		db	'u ', ANIM_83, 'to '
		db	ANIM_82, 'de', ANIM_85, 'st'
		db	'roy ', ANIM_81, 't'
		db	'he ', ANIM_83, 'de'
		db	ANIM_80, 'mon ', ANIM_84
		db	'J', ANIM_80, 'as', ANIM_82, 'h'
		db	'ii', ANIM_84, 'n ', ANIM_80
		db	ANIM_87, 'w', ANIM_88, 'h', ANIM_87, 'o'
		db	ANIM_86, ' ', ANIM_85, 'has'
		db	' ', ANIM_83, 'cu', ANIM_81, 'r'
		db	ANIM_83, 'sed ', ANIM_80
		db	'my ', ANIM_85, 'ki'
		db	ANIM_81, 'ngdom'
		db	' ', ANIM_85, 'a', ANIM_82, 'nd'
		db	' ', ANIM_84, 'tur', ANIM_81
		db	'ned ', ANIM_80, ANIM_87
		db	'm', ANIM_82, ANIM_88, 'y', ANIM_87, ' '
		db	ANIM_81, ANIM_86, 'be', ANIM_83, 'l'
		db	'o', ANIM_81, 've', ANIM_83, 'd'
		db	' ', ANIM_85, 'daug'
		db	'h', ANIM_80, 'ter '
		db	ANIM_85, 'to ', ANIM_83, ANIM_87
		db	's', ANIM_88, 't', ANIM_87, 'o', ANIM_84
		db	ANIM_86, 'ne."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_RESET				; reset style
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	SCR_NORMAL				; normal text
		db	'Duke Garland knelt before the King. '
		db	SCR_BOLD				; bold text
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_PARA				; layout: paragraph
		db	SCR_SPK_UNK				; speaker: Duke Garland
		; Style-encoded speech -- Duke Garland
		; "Your Majesty, I have followed the light of the Spirit to this place."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	ANIM_97, '"', ANIM_93, ANIM_96, 'Yo'
		db	ANIM_90, 'ur Ma'
		db	ANIM_91, 'je', ANIM_95, 'st'
		db	'y, ', ANIM_90, 'I '
		db	ANIM_91, 'ha', ANIM_93, 've'
		db	' ', ANIM_93, 'foll'
		db	'ow', ANIM_95, 'ed '
		db	ANIM_91, 'the ', ANIM_90
		db	'li', ANIM_92, 'gh', ANIM_93
		db	't ', ANIM_94, ANIM_93, 'of'
		db	' ', ANIM_91, 'the '
		db	ANIM_93, 'S', ANIM_92, 'pi', ANIM_91
		db	'r', ANIM_92, 'it ', ANIM_95
		db	'to ', ANIM_92, 'th'
		db	ANIM_92, 'i', ANIM_97, 's', ANIM_98, ' '
		db	ANIM_97, ANIM_95, 'p', ANIM_96, ANIM_90, 'l'
		db	'a', ANIM_93, 'ce."'
		db	ANIM_94
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		; Style-encoded speech -- Duke Garland
		; "I know not of this demon, nor what powers he may possess, but if
		;    there is none else who can defeat him, then I will dedicate my life to this task."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	'"', ANIM_90, 'I ', ANIM_93, 'k'
		db	ANIM_95, 'now', ANIM_94, ' '
		db	ANIM_93, 'not', ANIM_94, ' '
		db	ANIM_93, 'o', ANIM_95, 'f ', ANIM_92
		db	'thi', ANIM_95, 's '
		db	ANIM_91, 'de', ANIM_93, 'mo'
		db	ANIM_94, 'n, ', ANIM_93, 'n'
		db	'o', ANIM_90, 'r ', ANIM_93, 'w'
		db	'h', ANIM_90, 'a', ANIM_93, 't '
		db	ANIM_90, 'po', ANIM_95, 'we'
		db	'r', ANIM_93, 's ', ANIM_92, 'h'
		db	'e ', ANIM_91, ANIM_97, 'm', ANIM_98
		db	'a', ANIM_97, ANIM_92, 'y', ANIM_96, ' '
		db	ANIM_93, 'po', ANIM_91, 'ss'
		db	'e', ANIM_93, 'ss, '
		db	ANIM_90, 'bu', ANIM_93, 't '
		db	ANIM_92, 'i', ANIM_95, 'f ', ANIM_91
		db	'th', ANIM_90, 'ere'
		db	' ', ANIM_92, 'i', ANIM_93, 's '
		db	ANIM_93, 'no', ANIM_94, 'ne'
		db	' ', ANIM_91, 'el', ANIM_93, 's'
		db	'e ', ANIM_93, 'who'
		db	' ', ANIM_90, 'ca', ANIM_94, 'n'
		db	' ', ANIM_91, 'de', ANIM_92, 'f'
		db	'e', ANIM_93, 'at ', ANIM_92
		db	'hi', ANIM_93, 'm, '
		db	ANIM_99, ANIM_91, 'the', ANIM_94
		db	'n ', ANIM_90, 'I ', ANIM_93
		db	'w', ANIM_92, 'i', ANIM_93, 'll'
		db	' ', ANIM_91, 'de', ANIM_92, 'd'
		db	'i', ANIM_90, 'ca', ANIM_92, 't'
		db	'e ', ANIM_90, 'm', ANIM_92, 'y'
		db	' ', ANIM_90, 'l', ANIM_95, 'i', ANIM_94
		db	'fe ', ANIM_93, 'to'
		db	' ', ANIM_92, 'th', ANIM_93, 'i'
		db	's ', ANIM_90, 'ta', ANIM_97
		db	ANIM_93, 's', ANIM_98, 'k', ANIM_97, '.'
		db	ANIM_96, '"', ANIM_94, SCR_WAIT,SCR_WAIT,SCR_WAIT		; pause | pause | pause
		db	SCR_WAIT,SCR_SPK_KING,SCR_SCROLL,SCR_PARA, '"', ANIM_83		; pause | speaker: King Felishika (attr >) | scroll-text-up | layout-mode 1
		; Style-encoded speech -- King Felishika
		; "For the first time since the sandstorm began, you have brought hope
		;    into my heart, Duke Garland.  May God go with you on your quest."
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	'Fo', ANIM_80, 'r ', ANIM_81
		db	'the ', ANIM_80, 'f'
		db	'i', ANIM_83, 'rst '
		db	ANIM_80, 't', ANIM_82, 'i', ANIM_83, 'm'
		db	'e ', ANIM_82, 'si', ANIM_84
		db	'n', ANIM_83, 'ce ', ANIM_81
		db	'the ', ANIM_80, 's'
		db	'a', ANIM_84, 'n', ANIM_83, 'd', ANIM_85
		db	's', ANIM_83, 'to', ANIM_80, 'r'
		db	ANIM_84, 'm ', ANIM_82, 'b', ANIM_87
		db	'e', ANIM_88, ANIM_81, 'g', ANIM_87, 'a'
		db	ANIM_84, ANIM_86, 'n, ', ANIM_83
		db	'you ', ANIM_81, 'h'
		db	'a', ANIM_83, 've ', ANIM_80
		db	'b', ANIM_83, 'rou', ANIM_84
		db	'gh', ANIM_83, 't h'
		db	'o', ANIM_85, 'pe ', ANIM_82
		db	'i', ANIM_84, 'n', ANIM_83, 'to'
		db	' ', ANIM_80, 'm', ANIM_82, 'y '
		db	ANIM_80, 'hear', ANIM_83
		db	't, ', ANIM_80, 'Du'
		db	ANIM_83, 'ke ', ANIM_87, ANIM_80
		db	'G', ANIM_88, 'a', ANIM_87, 'r', ANIM_86
		db	ANIM_84, ANIM_80, 'la', ANIM_84, 'n'
		db	'd.  ', ANIM_80, 'M'
		db	'a', ANIM_82, 'y ', ANIM_83, 'G'
		db	'od', ANIM_84, ' ', ANIM_83, 'g'
		db	'o ', ANIM_82, 'wi', ANIM_83
		db	'th ', ANIM_83, 'y', ANIM_85
		db	'ou ', ANIM_83, 'o', ANIM_84
		db	'n ', ANIM_83, 'yo', ANIM_80
		db	'ur ', ANIM_83, 'qu'
		db	ANIM_81, 'es', ANIM_83, 't.'
		db	ANIM_84, '"', ANIM_84
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_RESET				; reset style
		db	SCR_BREAK				; end of section
		db	SCR_BREAK				; end of section
		db	SCR_NORMAL				; normal text
		db	SCR_PARA				; layout: paragraph
		db	'Suddenly, the room grew cold.  A black mist swirled around them, then took on a hideous shape.'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_SPK_NARR				; speaker: narrator
		db	SCR_BREAK				; end of section
		db	SCR_PARA				; layout: paragraph
		db	SCR_COLOR6				; color 6 text
		db	'"Are you the fool who dares to c'
		db	'hallenge me?  Don', 27h, 't be a'
		db	'bsurd!"'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_BREAK				; end of section
		db	ANIM_99
		db	SCR_WAIT				; pause
		db	SCR_SCROLL,SCR_PARA,SCR_BOLD,SCR_SPK_UNK, ANIM_9A, '"'		; scroll-text-up | layout-mode 1 | text-style: color 7 bold | speaker: unknown (attr =)
		; Style-encoded speech -- Jashiin (cont.)
		; "...And you must be the evil Jashiin!" (end of Jashiin speech)
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	ANIM_90, 'A', ANIM_94, 'n', ANIM_93, 'd'
		db	' ', ANIM_93
		db	'y'

narration_chapter_4:
		; Style-encoded speech -- Jashiin (cont.)
		; "...you must be the evil Jashiin!"
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	'ou ', ANIM_90, 'mu'
		db	ANIM_93, 'st ', ANIM_92, 'b'
		db	'e ', ANIM_90, 'the'
		db	' ', ANIM_91, 'e', ANIM_92, 'vi'
		db	ANIM_93, 'l ', ANIM_90, 'Ja'
		db	ANIM_92, 'shi', ANIM_94, 'i'
		db	'n!"'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SPK_NARR				; speaker: narrator
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_COLOR6				; color 6 text
		db	'"You shall address me as the Emperor of Chaos... '
		db	ANIM_9B
		db	'THE EMPEROR OF CHAOS!"'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_DIRECT				; layout: direct
		db	22h				; 22h
		db	'Young fool, I could destroy you now, but I need a little amusement.  I will give you some time to perform your little quest, but you must promise not to bore me."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'"Of course, you have no hope of defeating me."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SPK_UNK				; speaker: Duke Garland
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_BOLD, '"', ANIM_9A, ANIM_90, 'Ma'		; text-style: color 7 bold
		; Style-encoded speech -- Duke Garland
		; "Mark my words, evil one: I will not stop until I have reclaimed the
		;    nine holy crystals, and sealed you under the earth once again!"
		; (0x80-0x97 between chars = per-character color-cycle animation)
		db	'r', ANIM_95, 'k ', ANIM_90, 'm'
		db	ANIM_92, 'y ', ANIM_90, 'wo'
		db	'r', ANIM_93, 'ds, '
		db	ANIM_91, 'e', ANIM_92, 'vi', ANIM_93
		db	'l ', ANIM_90, 'o', ANIM_94, 'n'
		db	'e: ', ANIM_90, 'I '
		db	ANIM_95, 'w', ANIM_92, 'i', ANIM_93, 'l'
		db	'l ', ANIM_93, 'not'
		db	ANIM_94, ' ', ANIM_93, 'sto'
		db	ANIM_94, 'p ', ANIM_90, 'u', ANIM_94
		db	'n', ANIM_92, 'ti', ANIM_93, 'l'
		db	' ', ANIM_90, 'I ', ANIM_91, 'h'
		db	'a', ANIM_93, 've ', ANIM_91
		db	're', ANIM_93, 'cl', ANIM_90
		db	'ai', ANIM_93, 'med'
		db	' ', ANIM_91, 'the '
		db	ANIM_90, 'ni', ANIM_94, 'ne'
		db	' ', ANIM_93, 'ho', ANIM_92, 'l'
		db	'y ', ANIM_93, 'cr', ANIM_92
		db	'ys', ANIM_90, 'tal'
		db	ANIM_93, 's, ', ANIM_90, 'a'
		db	ANIM_94, 'n', ANIM_93, 'd ', ANIM_92
		db	'sea', ANIM_93, 'le'
		db	'd ', ANIM_95, 'you'
		db	' ', ANIM_90, 'u', ANIM_94, 'n', ANIM_90
		db	'der ', ANIM_91, 't'
		db	'he ', ANIM_90, 'ea'
		db	'r', ANIM_93, 'th ', ANIM_90
		db	'o', ANIM_94, 'n', ANIM_93, 'ce'
		db	' ', ANIM_90
		db	'a'

narration_chapter_5:
		db	ANIM_94, 'n', ANIM_93, 'd ', ANIM_93, 'f'		; small-portrait[4]
		db	'o', ANIM_90, 'r ', ANIM_95, 'a'
		db	ANIM_93, 'll!', ANIM_99, ANIM_94
		db	22h				; 22h
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_RESET				; reset style
		db	SCR_WAIT				; pause
		db	SCR_DIRECT				; layout: direct
		db	SCR_NORMAL				; normal text
		db	'The demon laughed, and the sound was like breaking glass.'
		db	SCR_MODE2				; layout: mode 2
		db	SCR_COLOR6				; color 6 text
		db	SCR_SPK_NARR				; speaker: narrator
		db	'"My labyrinths are immense, and '
		db	'run deep into the earth.  You', 27h
		db	'll soon lose your way, and then my underlings will finish you off."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	'"It', 27h, 's been many years si'
		db	'nce a stray mortal has wandered into their realm. They are hungry for human flesh."'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_RESET				; reset style
		db	SCR_BREAK				; end of section
		db	SCR_SCROLL				; scroll text up
		db	SCR_PARA				; layout: paragraph
		db	SCR_NORMAL				; normal text
		db	'With that, '
jashiin_disappear_text		db	'Jashiin disappeared leaving echo'
		db	'es of earsplitting laughter.'
anim_fn_wipe		dw	0F5F5h		; runtime fn ptr (placeholder = SCR_WAIT,SCR_WAIT)
anim_fn_fade		dw	0FEFDh		; runtime fn ptr (placeholder = SCR_BREAK,SCR_SCROLL)
anim_fn_draw		dw	0F3EFh		; runtime fn ptr (placeholder = SCR_SPK_UNK,SCR_PARA)
; Dual-use dispatch/speech table (disp_game_fn .. disp_narr_chap4)
; Each entry serves two purposes simultaneously:
;  1. DISPATCH - called via "call word ptr cs:ftbl_NN": the 2-byte value is
;     read as a 16-bit address. Most targets (0x6168, 0x6F59 etc.) are
;     runtime-loaded driver functions in the upper CS segment; disp_game_fn/02/05/06/12
;     call into narration chapters directly.
;  2. TEXT - reading all bytes sequentially produces the speech:
;     SCR_BOLD + '"You haven''t seen the last of me, Jashiin!"'
;     (Duke Garland's final threat to Jashiin)
; The character byte pairs were deliberately chosen to match driver addresses.
disp_game_fn		db	SCR_BOLD, '"'		; start bold quoted speech
disp_data_6F59		db	'Y', 'o'
disp_narr_chap2		dw	offset narration_chapter_2	; 'u ', encoded as chapter offset
disp_chap2_call		db	'h', 'a'
disp_drv_seg_3		db	'v', 'e'
disp_narr_chap3		dw	offset narration_chapter_3	; "n'", encoded as chapter offset
disp_narr_open		dw	offset opening_narration	; 't ', encoded as narration offset
disp_set_drv_seg		db	's', 'e'
disp_font_inv		db	'e', 'n'
disp_data_7420		db	' ', 't'
disp_load_setup		db	'h', 'e'
disp_script_area		db	' ', 'l'
		db	'ast of m'
disp_narr_chap4	dw	offset narration_chapter_4	; 'e,', encoded as chapter offset
		db	' Jashiin!'
		db	SCR_MODE2		; layout-mode 2
		db	'Your reign of evil is near its end!"'
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_WAIT				; pause
		db	SCR_END_SCRIPT				; end of script (page break; caller re-invokes script_interpreter from here)
		; Script continuation (0x00-0x1F = custom font glyphs / animation codes; 0xFC = no-op)
		db	'X', '%', SCR_RESET
		db	0, 0, ANIM_03, 'h', '!'
		db	0FCh, 0FCh
		db	ANIM_04, ANIM_07, 'p', '#', ANIM_01
		db	SCR_BREAK
		db	ANIM_04, ANIM_07, 'p', '$', ANIM_04
		db	SCR_BREAK
		db	ANIM_04, ANIM_07, 'x', '%', ANIM_06
		db	SCR_SCROLL
		db	ANIM_04, ANIM_07, 'x', '(', ANIM_06, ANIM_02
		db	ANIM_04, ANIM_07, 'p', ')', ANIM_04, ANIM_03
		db	ANIM_04, ANIM_07, 'p', '*', ANIM_01, ANIM_03
		db	ANIM_04, ANIM_07, 'h', ',', 0FCh
		db	ANIM_04, ANIM_04, ANIM_07
		db	SCR_END_SCRIPT
		db	ANIM_01

		; Style-encoded speech -- Jashiin (departing threat)
		; "Beware, for I shall wake from my sleep of 2,000 years
		;  and once again reign over the world."
		; (0x01-0x08 between chars = per-character color-cycle animation)
		db	ANIM_08, ANIM_01, 'Be', ANIM_03, 'w'
		db	'a', ANIM_04, 're, '
		db	ANIM_03, 'fo', ANIM_04, 'r '
		db	ANIM_04, 'I ', ANIM_01, 'sh'
		db	'a', ANIM_03, 'll w'
		db	ANIM_04, 'ak', ANIM_03, 'e'
		db	SCR_END_SCRIPT				; end of script
		db	ANIM_01, ANIM_06, ANIM_03, 'fro'
		db	ANIM_03, 'm ', ANIM_02, 'm', ANIM_01
		db	'y ', ANIM_03, 's', ANIM_01, 'l'
		db	'ee', ANIM_01, 'p o'
		db	'f ', ANIM_03, '2,', ANIM_04
		db	'000 ', ANIM_01, 'y'
		db	'e', ANIM_04, 'ar', ANIM_03, 's'
		db	SCR_END_SCRIPT				; end of script
		db	ANIM_01, ANIM_02, ANIM_04, 'a', ANIM_02
		db	'n', ANIM_03, 'd ', ANIM_03, 'o'
		db	ANIM_02, 'nce ', ANIM_04
		db	'aga', ANIM_01, 'in'
		db	' ', ANIM_02, 're', ANIM_04, 'i'
		db	ANIM_01, 'gn ', ANIM_03, 'o'
		db	'v', ANIM_04, 'er ', ANIM_01
		db	'the ', ANIM_04, 'w'
		db	'or', ANIM_03, 'ld.'
		db	ANIM_02

		; Animation frame timing sequence (end-of-chapter transition)
		; First byte is a null terminator consumed by caller; sequence follows
		db	000h			; list terminator (consumed by caller)
		db	ANIM_01				; ANIM_01
		db	ANIM_01				; ANIM_01
		db	ANIM_01				; ANIM_01
		db	ANIM_02				; ANIM_02
		db	ANIM_02				; ANIM_02
		db	ANIM_01				; ANIM_01
		db	ANIM_01				; ANIM_01
		db	ANIM_02				; ANIM_02
		db	ANIM_02				; ANIM_02
		db	ANIM_03				; ANIM_03
		db	ANIM_03				; ANIM_03
		db	ANIM_05
		; Maps ASCII codes (0x00 to 0xC1) to glyph indices in the font sheet.
		; Index 0 = no glyph (space/unprintable). Used by the text renderer
		; to look up which glyph bitmap to draw for each character.

char_glyph_index:
		db	7 dup (0)
		db	001h, 002h, 003h, 004h
		db	6 dup (0)
		db	005h, 006h, 007h, 008h
		db	009h, 00Ah, 00Bh, 00Ch, 00Dh
		db	0Eh				; 0Eh
		db	0Fh				; 0Fh
		db	10h				; 10h
		db	11h				; 11h
		db	12h				; 12h
		db	13h				; 13h
		db	14h				; 14h
		db	15h				; 15h
		db	16h				; 16h
		db	00h				; 00h
		db	00h				; 00h
		db	00h				; 00h
		db	17h				; 17h
		db	18h				; 18h
		db	19h				; 19h
		db	1Ah				; 1Ah
		db	1Bh				; 1Bh
		db	1Ch				; 1Ch
		db	1Dh				; 1Dh
		db	1Eh				; 1Eh
		db	1Fh				; 1Fh
		db	' !"#$'
		db	'%&', 27h, '()*+,-.'
		db	000h, 000h, '/012'
		db	'3', 000h, 000h, '456'
		db	'78', 000h, '9&:'
		db	 00h
		db	18 dup (0)
		db	';<=', 000h, 000h, 000h
		db	'>?@A'
		db	30 dup (0)
		db	'BCDE'
		db	30 dup (0)
		db	'FG', 016h
		db	31 dup (0)
		db	'HIJ'
		db	97 dup (0)
		db	'KLM'
		db	31 dup (0)
		db	'NOP'
		db	32 dup (0)
		db	'Q'
		db	33 dup (0)
		db	'RS'
		db	32 dup (0)
		db	'TUV'
		db	31 dup (0)
		db	'WXYZ'
		db	30 dup (0)
		db	'[\]^'
		db	30 dup (0)
		db	'_`ab'
		db	30 dup (0)
		db	'cd'
		db	32 dup (0)
		db	'efghi'
		db	29 dup (0)
		db	'jklmnopqrs'
		db	24 dup (0)
		db	'tuvwxyz{|}'
		db	24 dup (0)
		db	'~', 07Fh, 080h, 081h, 082h, 083h
		db	084h, 085h, 086h, 087h, 088h, 089h
		db	0, 0, 0, 0
		db	00Fh
		db	08Ah, 08Bh, 08Ch
		db	0
		db	13 dup (0)
		db	'/', 08Dh, 08Eh, 08Fh, 090h, 091h
		db	092h, 093h, 094h, 095h, 096h, 097h
		db	0, 0, 0
		db	098h, 099h, 09Ah, 09Bh, 09Ch, 09Dh
		db	14 dup (0)
		db	09Eh, 09Fh
		db	0A0h
		db	0A1h
		db	0A2h
		db	0A3h				; 0A3h
		db	0A4h				; 0A4h
		db	0A5h				; 0A5h
		db	0A6h				; 0A6h
		db	0A7h				; 0A7h
		db	0A8h				; 0A8h
		db	0A9h				; 0A9h
		db	16h				; 16h
		db	00h				; 00h
		db	0AAh				; 0AAh
		db	0ABh				; 0ABh
		db	0ACh				; 0ACh
		db	0ADh				; 0ADh
		db	0AEh				; 0AEh
		db	0AFh				; 0AFh
		db	14 dup (0)
		db	0B0h				; 0B0h
		db	0B1h				; 0B1h
		db	0B2h				; 0B2h
		db	0B3h				; 0B3h
		db	0B4h				; 0B4h
		db	0B5h				; 0B5h
		db	0B6h, 0B7h, 0B8h, '&&', 0B9h		; ctrl 0xB6 | ctrl 0xB7 | ctrl 0xB8 | ctrl 0xB9
		db	0BAh				; 0BAh
		db	0BBh				; 0BBh
		db	0BCh				; 0BCh
		db	0BDh				; 0BDh
		db	0BEh				; 0BEh
		db	0BFh				; 0BFh
		db	0C0h				; 0C0h
		db	0C1h				; 0C1h
		db	13 dup (0)
		; Character pixel width table
		; One db per glyph index. Width = pixel advance after drawing.

glyph_advance_tbl:
		db	2				; glyph   0  [(no ASCII mapping)]
		db	2				; glyph   1  [0x07]
		db	3				; glyph   2  [0x08]
		db	1				; glyph   3  [0x09]
		db	0				; glyph   4  [0x0A]
		db	0				; glyph   5  [0x11]
		db	2				; glyph   6  [0x12]
		db	2				; glyph   7  [0x13]
		db	3				; glyph   8  [0x14]
		db	1				; glyph   9  [0x15]
		db	1				; glyph  10  [0x16]
		db	1				; glyph  11  [0x17]
		db	2				; glyph  12  [0x18]
		db	2				; glyph  13  [0x19]
		db	0				; glyph  14  [0x1A]
		db	1				; glyph  15  [0x1B]
		db	2				; glyph  16  [0x1C]
		db	1				; glyph  17  [0x1D]
		db	1				; glyph  18  [0x1E]
		db	1				; glyph  19  [0x1F]
		db	1				; glyph  20  [' ']
		db	1				; glyph  21  ['!']
		db	1				; glyph  22  ['"', 0xAF]
		db	1				; glyph  23  ['&']
		db	1				; glyph  24  [''']
		db	3				; glyph  25  ['(']
		db	2				; glyph  26  [')']
		db	1				; glyph  27  ['*']
		db	1				; glyph  28  ['+']
		db	2				; glyph  29  [',']
		db	1				; glyph  30  ['-']
		db	0				; glyph  31  ['.']
		db	0				; glyph  32  ['/']
		db	0				; glyph  33  ['0']
		db	0				; glyph  34  ['1']
		db	0				; glyph  35  ['2']
		db	0				; glyph  36  ['3']
		db	0				; glyph  37  ['4']
		db	0				; glyph  38  ['5', 'N']
		db	0				; glyph  39  ['6']
		db	2				; glyph  40  ['7']
		db	0				; glyph  41  ['8']
		db	0				; glyph  42  ['9']
		db	0				; glyph  43  [':']
		db	0				; glyph  44  [';']
		db	0				; glyph  45  ['<']
		db	0				; glyph  46  ['=']
		db	0				; glyph  47  ['@']
		db	0				; glyph  48  ['A']
		db	0				; glyph  49  ['B']
		db	0				; glyph  50  ['C']
		db	1				; glyph  51  ['D']
		db	0				; glyph  52  ['G']
		db	0				; glyph  53  ['H']
		db	0				; glyph  54  ['I']
		db	0				; glyph  55  ['J']
		db	0				; glyph  56  ['K']
		db	1				; glyph  57  ['M']
		db	2				; glyph  58  ['O']
		db	2				; glyph  59  ['c']
		db	2				; glyph  60  ['d']
		db	1				; glyph  61  ['e']
		db	1				; glyph  62  ['i']
		db	1				; glyph  63  ['j']
		db	0				; glyph  64  ['k']
		db	0				; glyph  65  ['l']
		db	1				; glyph  66  [0x8B]
		db	0				; glyph  67  [0x8C]
		db	1				; glyph  68  [0x8D]
		db	1				; glyph  69  [0x8E]
		db	0				; glyph  70  [0xAD]
		db	0				; glyph  71  [0xAE]
		db	2				; glyph  72  [(no ASCII mapping)]
		db	1				; glyph  73  [(no ASCII mapping)]
		db	0				; glyph  74  [(no ASCII mapping)]
		db	2				; glyph  75  [(no ASCII mapping)]
		db	0				; glyph  76  [(no ASCII mapping)]
		db	1				; glyph  77  [(no ASCII mapping)]
		db	1				; glyph  78  [(no ASCII mapping)]
		db	0				; glyph  79  [(no ASCII mapping)]
		db	0				; glyph  80  [(no ASCII mapping)]
		db	0				; glyph  81  [(no ASCII mapping)]
		db	1				; glyph  82  [(no ASCII mapping)]
		db	1				; glyph  83  [(no ASCII mapping)]
		db	0				; glyph  84  [(no ASCII mapping)]
		db	0				; glyph  85  [(no ASCII mapping)]
		db	0				; glyph  86  [(no ASCII mapping)]
		db	1				; glyph  87  [(no ASCII mapping)]
		db	1				; glyph  88  [(no ASCII mapping)]
		db	1				; glyph  89  [(no ASCII mapping)]
		db	2				; glyph  90  [(no ASCII mapping)]
		db	0				; glyph  91  [(no ASCII mapping)]
		db	3				; glyph  92  [(no ASCII mapping)]
		db	1				; glyph  93  [(no ASCII mapping)]
		db	0				; glyph  94  [(no ASCII mapping)]
		db	5				; glyph  95  [(no ASCII mapping)]
		db	4				; glyph  96  [(no ASCII mapping)]
		db	4				; glyph  97  [(no ASCII mapping)]
		db	4				; glyph  98  [(no ASCII mapping)]
		db	6				; glyph  99  [(no ASCII mapping)]
		db	8				; glyph 100  [(no ASCII mapping)]
		db	5				; glyph 101  [(no ASCII mapping)]
		db	3				; glyph 102  [(no ASCII mapping)]
		db	4				; glyph 103  [(no ASCII mapping)]
		db	4				; glyph 104  [(no ASCII mapping)]
		db	6				; glyph 105  [(no ASCII mapping)]
		db	6				; glyph 106  [(no ASCII mapping)]
		db	6				; glyph 107  [(no ASCII mapping)]
		db	5				; glyph 108  [(no ASCII mapping)]
		db	6				; glyph 109  [(no ASCII mapping)]
		db	8				; glyph 110  [(no ASCII mapping)]
		db	7				; glyph 111  [(no ASCII mapping)]
		db	5				; glyph 112  [(no ASCII mapping)]
		db	7				; glyph 113  [(no ASCII mapping)]
		db	7				; glyph 114  [(no ASCII mapping)]
		db	7				; glyph 115  [(no ASCII mapping)]
		db	7				; glyph 116  [(no ASCII mapping)]
		db	7				; glyph 117  [(no ASCII mapping)]
		db	7				; glyph 118  [(no ASCII mapping)]
		db	7				; glyph 119  [(no ASCII mapping)]
		db	7				; glyph 120  [(no ASCII mapping)]
		db	3				; glyph 121  [(no ASCII mapping)]
		db	4				; glyph 122  [(no ASCII mapping)]
		db	6				; glyph 123  [(no ASCII mapping)]
		db	6				; glyph 124  [(no ASCII mapping)]
		db	6				; glyph 125  [(no ASCII mapping)]
		db	7				; glyph 126  [(no ASCII mapping)]
		db	8				; glyph 127  [(no ASCII mapping)]
		db	8				; glyph 128  [(no ASCII mapping)]
		db	8				; glyph 129  [(no ASCII mapping)]
		db	8				; glyph 130  [(no ASCII mapping)]
		db	8				; glyph 131  [(no ASCII mapping)]
		db	8				; glyph 132  [(no ASCII mapping)]
		db	8				; glyph 133  [(no ASCII mapping)]
		db	8				; glyph 134  [(no ASCII mapping)]
		db	8				; glyph 135  [(no ASCII mapping)]
		db	5				; glyph 136  [(no ASCII mapping)]
		db	8				; glyph 137  [(no ASCII mapping)]
		db	8				; glyph 138  [(no ASCII mapping)]
		db	8				; glyph 139  [(no ASCII mapping)]
		db	8				; glyph 140  [(no ASCII mapping)]
		db	8				; glyph 141  [(no ASCII mapping)]
		db	8				; glyph 142  [(no ASCII mapping)]
		db	8				; glyph 143  [(no ASCII mapping)]
		db	8				; glyph 144  [(no ASCII mapping)]
		db	8				; glyph 145  [(no ASCII mapping)]
		db	8				; glyph 146  [(no ASCII mapping)]
		db	7				; glyph 147  [(no ASCII mapping)]
		db	8				; glyph 148  [(no ASCII mapping)]
		db	8				; glyph 149  [(no ASCII mapping)]
		db	8				; glyph 150  [(no ASCII mapping)]
		db	8				; glyph 151  [(no ASCII mapping)]
		db	8				; glyph 152  [(no ASCII mapping)]
		db	7				; glyph 153  [(no ASCII mapping)]
		db	5				; glyph 154  [(no ASCII mapping)]
		db	3				; glyph 155  [(no ASCII mapping)]
		db	5				; glyph 156  [(no ASCII mapping)]
		db	6				; glyph 157  [(no ASCII mapping)]
		db	7				; glyph 158  [(no ASCII mapping)]
		db	7				; glyph 159  [(no ASCII mapping)]
		db	8				; glyph 160  [(no ASCII mapping)]
		db	8				; glyph 161  [(no ASCII mapping)]
		db	7				; glyph 162  [(no ASCII mapping)]
		db	8				; glyph 163  [(no ASCII mapping)]
		db	7				; glyph 164  [(no ASCII mapping)]
		db	7				; glyph 165  [(no ASCII mapping)]
		db	8				; glyph 166  [(no ASCII mapping)]
		db	8				; glyph 167  [(no ASCII mapping)]
		db	5				; glyph 168  [(no ASCII mapping)]
		db	6				; glyph 169  [(no ASCII mapping)]
		db	8				; glyph 170  [(no ASCII mapping)]
		db	5				; glyph 171  [(no ASCII mapping)]
		db	8				; glyph 172  [(no ASCII mapping)]
		db	7				; glyph 173  [(no ASCII mapping)]
		db	7				; glyph 174  [(no ASCII mapping)]
		db	8				; glyph 175  [(no ASCII mapping)]
		db	8				; glyph 176  [(no ASCII mapping)]
		db	8				; glyph 177  [(no ASCII mapping)]
		db	7				; glyph 178  [(no ASCII mapping)]
		db	6				; glyph 179  [(no ASCII mapping)]
		db	8				; glyph 180  [(no ASCII mapping)]
		db	8				; glyph 181  [(no ASCII mapping)]
		db	8				; glyph 182  [(no ASCII mapping)]
		db	7				; glyph 183  [(no ASCII mapping)]
		db	7				; glyph 184  [(no ASCII mapping)]
		db	7				; glyph 185  [(no ASCII mapping)]
		db	4				; glyph 186  [(no ASCII mapping)]
		db	8				; glyph 187  [(no ASCII mapping)]
		db	4				; glyph 188  [(no ASCII mapping)]
		db	7				; glyph 189  [(no ASCII mapping)]
		db	8				; glyph 190  [(no ASCII mapping)]
						; (end of char width table)

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
