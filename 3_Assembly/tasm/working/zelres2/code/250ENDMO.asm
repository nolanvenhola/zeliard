
PAGE  59,132

;==========================================================================
;
;  250ENDMO.BIN - Ending Demo / Credits Scene (zelres2 chunk 250)
;
;  The ending module shown after Jashiin is defeated. Structure mirrors the
;  opening demo (100OPDMO) but runs the post-boss narrative and credit roll:
;
;    1. Screen fade-in / wipe transitions between the preceding cinematic
;       screens loaded from zelres2 chunks (ref table at 813Dh..81D6h):
;         813Dh  kingprin.grp   (king + princess scene)
;         8148h  jashiin.grp    (Jashiin dying)
;         8152h  gualand2.grp   (Duke Garland + land recovering)
;         815Dh  palette data   (CGA mid-palette)
;         8168h  heromirage.grp (hero silhouette/walk-off)
;         8173h  heroclose.grp  (hero facing camera)
;         8189h  kingcrown.grp  (king / farewell)
;         8194h  felicia.grp    (Princess close-up)
;         819Fh..81D6h  credits tileset chunks (waku/sei/yuup/seip/himp/etc.)
;         81E0h  zend.msd       (ending music)
;    2. Narration pages rendered via the same script-byte interpreter as the
;       opening (SCR_* control codes, ANIM_* animated per-char color codes).
;    3. Credits roll using ending_credits_dispatch (7 per-scene handlers).
;    4. Final epilogue bitmap composed from a 6-plane OR/AND tile renderer.
;
;  Key subsystems:
;    ending_scene_main          - main entry: orchestrates scenes 1..7
;    wait_ticks                 - reset cs:frame_timer and spin N ticks
;    gfx_driver_tick            - call driver ISRs at cs:[110h..118h]
;    render_narration_page      - script-byte narration interpreter (page)
;    measure_script_word_width  - compute pixel width of next script word
;    credits_loop_main          - credits page state machine
;    credits_worker_tick        - per-tick driver tick for credits
;    rle_blit_pair              - decompress 2-plane RLE image into ES:DI
;    rle_interleave_planes      - merge decompressed planes into 4bpp form
;    tile_rle_blit              - alternate tile RLE decoder
;    fill_credits_triplane      - zero + copy a credit-page triplane
;    or_triplane_mask           - OR-in a mask over 3 contiguous planes
;    ending_credits_dispatch    - 7 per-credit-scene render handlers
;                                 (called via ds:credit_scene_fn_tbl[bx])
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; ------------------------------------------------------------------
; Graphics driver function table (in this module's CS segment, at 3000h+)
; ------------------------------------------------------------------
gfx_draw_fn		equ	3004h		; draw / blit rectangle (AL=colour)
gfx_update_fn		equ	3006h		; update / refresh rect
gfx_palette_fn		equ	3008h		; palette switch (AX=palette index)
gfx_blit_fn		equ	3010h		; blit with colour mask
gfx_scene_fn1		equ	3020h		; set scene state word 1
gfx_scene_fn2		equ	3022h		; set scene state word 2 (AL=mode)
gfx_scene_fn3		equ	3024h		; set scene state word 3
gfx_sprite_fn		equ	3028h		; sprite render
gfx_scroll_jmp		equ	302Eh		; scroll/credits jump vector
gfx_putchar_fn		equ	3030h		; render single char at (BX,CX)

; ------------------------------------------------------------------
; Narration / credits script data (in cs: if via cs:, else in DS/game_seg)
; ------------------------------------------------------------------
null_ofs		equ	0		; zero offset
rle_stride_a		equ	18D8h		; plane stride for rle_interleave_planes
plane_mid_ofs		equ	29E0h		; middle-plane base in OR/AND mask compose
framebuf_a		equ	4000h		; frame buffer A (game_seg:4000h)
or_mask_base		equ	4CE6h		; OR/AND mask table base in game_seg
plane_top_ofs		equ	53C0h		; top-plane base in OR/AND mask compose
script_src_a		equ	8000h		; narration script source (game_seg:8000h)
framebuf_b		equ	4000h		; alternate frame buffer (alias of framebuf_a)
script_src_b		equ	8000h		; script source alias
script_pc		equ	6630h		; narration: script program counter (word)
render_x_pos		equ	6632h		; narration: X pixel position (word)
text_layout		equ	6634h		; narration: layout mode (byte)
text_color_fg		equ	6635h		; narration: foreground colour byte
text_color_bg		equ	6636h		; narration: background colour byte
text_style		equ	6637h		; narration: speaker/attribute style
credit_scene_fn_tbl	equ	6820h		; credits: scene-dispatch fn pointer table
credits_pc		equ	6965h		; credits: script program counter (word)
credits_col_byte	equ	6967h		; credits: current column byte
credits_row_byte	equ	6968h		; credits: current row byte
credits_pause_ticks	equ	6969h		; credits: pause/delay word
credits_tick_delay	equ	696Bh		; credits: inter-tick delay
credits_scene_idx	equ	696Ch		; credits: scene handler index byte
glyph_advance_tbl	equ	807Dh		; character advance (width) table
glyph_space_tbl		equ	80DDh		; character space (width-inc) table
ref_gualand2_palette	equ	815Dh		; chunk ref: palette (815Dh)
ref_heroclose_grp	equ	8173h		; chunk ref: hero close-up grp
ref_felicia_grp		equ	8194h		; chunk ref: Felicia close-up grp
vga_seg			equ	0A000h		; VGA segment (A000h)
gvar_timer_lo		equ	0FF1Ah		; frame timer low byte (zeliard.inc)
gvar_skip_input		equ	0FF21h		; input skip flag (zeliard.inc)
gvar_game_seg		equ	0FF2Ch		; game data segment word (zeliard.inc)
gvar_credits_pos	equ	0FF50h		; credits scroll/row position word
gvar_volume_b		equ	0FF75h		; audio volume B (zeliard.inc)

; ------------------------------------------------------------------
; Script byte-stream control codes (shared with 100OPDMO; see skill).
; Appear in narration & credits scripts embedded in the data section.
; ------------------------------------------------------------------
SCR_END_SCRIPT	equ	0FFh	; end of script / page terminator
SCR_SCROLL	equ	0FEh	; scroll text up / page break
SCR_BREAK	equ	0FDh	; section break
SCR_FC		equ	0FCh	; credits: clear-screen / reset
SCR_BOLD	equ	0FBh	; text style: color 7 bold
SCR_NORMAL	equ	0FAh	; text style: color 7 normal
SCR_COLOR6	equ	0F9h	; text style: color 6
SCR_F8		equ	0F8h	; credits: set pause-ticks (word arg)
SCR_DIRECT	equ	0F7h	; layout mode 0 (direct write)
SCR_WAIT3	equ	0F6h	; long pause
SCR_WAIT	equ	0F5h	; pause
SCR_PARA	equ	0F3h	; layout mode 1 (paragraph)
SCR_MODE2	equ	0F2h	; layout mode 2
SCR_MODE3	equ	0F1h	; layout mode 3
SCR_RESET	equ	0F0h	; reset text attribute
SCR_SPK_UNK	equ	0EFh	; speaker: unknown (attr '=')
SCR_SPK_KING	equ	0EEh	; speaker: King Felishika (attr '>')
SCR_SPK_NARR	equ	0EDh	; speaker: narrator (attr '?')
SCR_SPK_DEMON	equ	0ECh	; speaker: Jashiin demon (attr '@')
SCR_SPK_PRINC	equ	0EBh	; speaker: Princess Felicia (attr 'A')
CR		equ	0Dh	; carriage return

; Per-character animated colour cycle codes (appear between glyphs).
ANIM_80		equ	080h
ANIM_81		equ	081h
ANIM_82		equ	082h
ANIM_83		equ	083h
ANIM_84		equ	084h
ANIM_85		equ	085h
ANIM_90		equ	090h
ANIM_91		equ	091h
ANIM_92		equ	092h
ANIM_93		equ	093h
ANIM_94		equ	094h
ANIM_95		equ	095h
ANIM_96		equ	096h
ANIM_97		equ	097h
ANIM_98		equ	098h
ANIM_A0		equ	0A0h
ANIM_A1		equ	0A1h
ANIM_A2		equ	0A2h
ANIM_A3		equ	0A3h
ANIM_A4		equ	0A4h
ANIM_A5		equ	0A5h
ANIM_B0		equ	0B0h
ANIM_B1		equ	0B1h
ANIM_B2		equ	0B2h
ANIM_B3		equ	0B3h
ANIM_B4		equ	0B4h
ANIM_B5		equ	0B5h
ANIM_B6		equ	0B6h
ANIM_B7		equ	0B7h
ANIM_B8		equ	0B8h
ANIM_C0		equ	0C0h
ANIM_C1		equ	0C1h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

ending_scene_main	proc	far

start:
		jmp	short main_entry
; --------------------------------------------------------------------
; Inline pre-entry init block (CS:0002..0022). Skipped at normal entry
; via the short-jmp above; executed on re-entry from credits loop or
; transition caller. Decoded instructions:
;   add [bx+si],al                       ; 00 00
;   add ah,[bx+si-6]                     ; 02 60 FA
;   mov sp,2000h                         ; BC 00 20
;   sti                                  ; FB
;   mov word ptr cs:[6630h], 6AA8h       ; 2E C7 06 30 66 A8 6A
;   mov ax,6                             ; B8 06 00
;   cs: call cs:[3008h] (gfx_palette_fn) ; 2E FF 16 08 30
;   push cs                              ; 0E
;   pop es                               ; 07
;   mov si,8152h                         ; BE 52 81
;   mov di,0A000h                        ; BF 00 A0
;   mov al,02h (not assembled here; fall-through into main_entry prologue)
; --------------------------------------------------------------------
		db	 00h, 00h, 02h, 60h,0FAh,0BCh	; +0x000
		db	 00h, 20h,0FBh, 2Eh,0C7h, 06h	; +0x006
		db	 30h, 66h,0A8h, 6Ah,0B8h, 06h	; +0x00C
		db	 00h, 2Eh,0FFh, 16h, 08h, 30h	; +0x012
		db	 0Eh, 07h,0BEh, 52h, 81h,0BFh	; +0x018
		db	 00h,0A0h,0B0h	; +0x01E

main_entry:
		add	ch,bitmap_row_byte
		or	al,1
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,framebuf_b
		call	rle_blit_pair
		push	cs
		pop	es
		mov	si,ref_heroclose_grp
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,script_src_b
		call	rle_blit_pair
		mov	es,cs:gvar_game_seg
		mov	di,framebuf_b
		mov	al,0FFh
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:gfx_draw_fn
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		push	ds
		mov	di,null_ofs
		mov	ds,cs:gvar_game_seg
		mov	si,script_src_a
		mov	ax,0B2h
		call	fill_credits_triplane
		pop	ds
		mov	di,0
		mov	al,0FFh
		mov	bx,2D71h
		mov	cx,1858h
		call	word ptr cs:gfx_draw_fn
		mov	byte ptr cs:gvar_timer_lo,0
		mov	al,0FFh
		call	timer_wait_loop
		mov	cx,59h

init_wipe_loop:
				push	cx
				mov	ax,cs
				add	ax,2000h
				mov	es,ax
				mov	ax,cx
				dec	ax
				add	ax,ax
				push	ds
				mov	di,null_ofs
				mov	ds,cs:gvar_game_seg
				mov	si,script_src_a
				call	fill_credits_triplane
				pop	ds
				pop	cx
				push	cx
				mov	bx,cx
				add	bx,17h
				mov	bh,2Dh			; '-'
				mov	di,0
				mov	cx,1858h
				call	word ptr cs:gfx_blit_fn
				mov	al,0Ah
				call	timer_wait_loop
				pop	cx
				loop	init_wipe_loop		; Loop if cx > 0

		push	cs
		pop	es
		mov	si,813Dh
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,vga_seg
		mov	di,0
		call	rle_blit_pair
		mov	di,0
		call	word ptr cs:gfx_sprite_fn
		call	render_narration_page
		push	cs
		pop	es
		mov	si,817Eh
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,framebuf_b
		call	rle_blit_pair
		mov	ax,1
		call	word ptr cs:gfx_scene_fn1
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		mov	es,cs:gvar_game_seg
		mov	di,framebuf_b
		mov	al,0FFh
		mov	bx,1D12h
		mov	cx,1C64h
		call	word ptr cs:gfx_draw_fn
		call	render_narration_page
		push	cs
		pop	es
		mov	si,8148h
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,framebuf_b
		call	rle_blit_pair
		mov	di,framebuf_b
		mov	bx,1610h
		mov	cx,2468h
		mov	al,5
		call	word ptr cs:gfx_scene_fn2
		call	render_narration_page
		push	cs
		pop	es
		mov	si,8152h
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,framebuf_b
		call	rle_blit_pair
		push	cs
		pop	es
		mov	si,ref_gualand2_palette
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,script_src_b
		call	rle_blit_pair
		xor	ax,ax			; Zero register
		call	word ptr cs:gfx_scene_fn1
		mov	ax,6
		call	word ptr cs:gfx_palette_fn
		mov	bx,0A15h
		mov	cx,1A5Dh
		call	word ptr cs:gfx_scene_fn3
		mov	es,cs:gvar_game_seg
		mov	di,framebuf_b
		mov	bx,0B18h
		mov	cx,1858h
		call	word ptr cs:gfx_blit_fn
		mov	bx,2C15h
		mov	cx,1A5Dh
		call	word ptr cs:gfx_scene_fn3
		mov	es,cs:gvar_game_seg
		mov	di,script_src_b
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:gfx_blit_fn
		call	render_narration_page
		push	cs
		pop	es
		mov	si,8168h
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,script_src_b
		call	rle_blit_pair
		mov	es,cs:gvar_game_seg
		mov	di,script_src_b
		mov	al,0FFh
		mov	bx,2D18h
		mov	cx,1858h
		call	word ptr cs:gfx_draw_fn
		call	render_narration_page
		push	cs
		pop	es
		mov	si,8189h
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,framebuf_b
		call	rle_blit_pair
		push	cs
		pop	es
		mov	si,ref_felicia_grp
		mov	di,vga_seg
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	es,cs:gvar_game_seg
		mov	si,vga_seg
		mov	di,script_src_b
		call	rle_blit_pair
		mov	ax,2
		call	word ptr cs:gfx_scene_fn1
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		mov	es,cs:gvar_game_seg
		mov	di,framebuf_b
		mov	al,0FFh
		mov	bx,0B12h
		mov	cx,1A64h
		call	word ptr cs:gfx_draw_fn
		mov	es,cs:gvar_game_seg
		mov	di,script_src_b
		mov	al,0FFh
		mov	bx,3325h
		mov	cx,1251h
		call	word ptr cs:gfx_draw_fn
		call	render_narration_page
		mov	es,cs:gvar_game_seg
		mov	di,framebuf_a
		xor	ax,ax			; Zero register
		mov	cx,0F3Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	di,framebuf_a
		mov	al,55h			; 'U'
		mov	cx,64h

gradient_fill_loop:
				push	cx
				mov	cx,1Ah
				rep	stosb			; Rep when cx >0 Store al to es:[di]
				ror	al,1			; Rotate
				pop	cx
				loop	gradient_fill_loop		; Loop if cx > 0

		xor	al,al			; Zero register
		mov	di,4000h
		mov	bx,0B12h
		mov	cx,1A64h
		call	word ptr cs:gfx_draw_fn
		call	render_narration_page
		mov	al,0FFh
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:gfx_update_fn
		jmp	credits_scene_start

ending_scene_main	endp

timer_wait_loop		proc	near

timer_wait_poll:
				call	gfx_driver_tick_full
				cmp	cs:gvar_timer_lo,al
				jb	timer_wait_poll			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

timer_wait_loop		endp

gfx_driver_tick_full		proc	near
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		pop	ax
		pop	si
		retn

gfx_driver_tick_full		endp

render_narration_page		proc	near
		mov	byte ptr cs:gvar_timer_lo,0

narration_tick_top:
		mov	al,10h
		call	timer_wait_loop

script_fetch_byte:
		push	cs
		pop	ds
		mov	si,ds:script_pc
		lodsb				; String [si] to al
		mov	ds:script_pc,si
		test	al,80h
		jz	non_space_char			; Jump if zero
		jmp	ctrl_code_branch

non_space_char:
		cmp	al,20h			; ' '
		je	render_char_glyph			; Jump if equal
		cmp	al,2Eh			; '.'
		je	render_char_glyph			; Jump if equal
		cmp	al,2Ch			; ','
		je	render_char_glyph			; Jump if equal
		cmp	al,22h			; '"'
		je	render_char_glyph			; Jump if equal
		cmp	al,27h			; '''
		je	render_char_glyph			; Jump if equal
		mov	ah,ds:text_style
		mov	ds:gvar_volume_b,ah

render_char_glyph:
		push	ax
		mov	bx,ds:render_x_pos
		add	bx,4
		mov	al,ds:text_layout
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	ax,8Fh
		mov	cx,ax
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:glyph_advance_tbl[bx]
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
		call	word ptr cs:gfx_putchar_fn
		pop	cx
		pop	bx
		pop	ax
		mov	ah,ds:text_color_bg
		call	word ptr cs:gfx_putchar_fn
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:glyph_space_tbl[bx]
		mov	ch,bh
		add	ds:render_x_pos,cx
		cmp	al,20h			; ' '
		je	after_word_end			; Jump if equal
		jmp	narration_tick_top

after_word_end:
		mov	si,ds:script_pc
		call	measure_script_word_width
		mov	dx,ds:render_x_pos
		add	dx,cx
		cmp	dx,138h
		jb	narration_fit_word			; Jump if below
		jmp	line_wrap

narration_fit_word:
		jmp	narration_tick_top

ctrl_code_branch:
		cmp	al,0FFh
		jne	not_FF			; Jump if not equal
		retn

not_FF:
		cmp	al,0FDh
		jne	not_FD			; Jump if not equal
		retn

not_FD:
		mov	ah,al
		and	ah,0F0h
		cmp	ah,80h
		jne	not_portrait_80			; Jump if not equal
		jmp	portrait_90

not_portrait_80:
		cmp	ah,90h
		jne	not_portrait_90			; Jump if not equal
		jmp	portrait_80

not_portrait_90:
		cmp	ah,0A0h
		jne	not_portrait_A0			; Jump if not equal
		jmp	portrait_A0

not_portrait_A0:
		cmp	ah,0B0h
		jne	not_portrait_B0			; Jump if not equal
		jmp	portrait_B0

not_portrait_B0:
		cmp	ah,0C0h
		jne	not_portrait_C0			; Jump if not equal
		jmp	portrait_C0

not_portrait_C0:
		mov	bx,701h
		cmp	al,0FBh
		jne	not_color_FB			; Jump if not equal
		jmp	set_color_pair

not_color_FB:
		mov	bx,700h
		cmp	al,0FAh
		jne	not_color_FA			; Jump if not equal
		jmp	set_color_pair

not_color_FA:
		mov	bx,602h
		cmp	al,0F9h
		je	set_color_pair			; Jump if equal
		cmp	al,0F5h
		jne	not_wait_F5			; Jump if not equal
		jmp	short_wait

not_wait_F5:
		cmp	al,0F6h
		jne	not_wait_F6			; Jump if not equal
		jmp	long_wait

not_wait_F6:
		xor	ah,ah			; Zero register
		cmp	al,0F7h
		je	new_line_reset			; Jump if equal
		inc	ah
		cmp	al,0F3h
		je	new_line_reset			; Jump if equal
		inc	ah
		cmp	al,0F2h
		je	new_line_reset			; Jump if equal
		inc	ah
		cmp	al,0F1h
		je	new_line_reset			; Jump if equal
		cmp	al,0FEh
		je	full_scroll			; Jump if equal
		mov	ah,ds:text_style
		mov	byte ptr ds:text_style,0
		cmp	al,0F0h
		jne	not_style_F0			; Jump if not equal
		jmp	narration_tick_top

not_style_F0:
		mov	byte ptr ds:text_style,3Dh	; '='
		cmp	al,0EFh
		jne	not_spk_EF			; Jump if not equal
		jmp	narration_tick_top

not_spk_EF:
		mov	byte ptr ds:text_style,3Eh	; '>'
		cmp	al,0EEh
		jne	not_spk_EE			; Jump if not equal
		jmp	narration_tick_top

not_spk_EE:
		mov	byte ptr ds:text_style,3Fh	; '?'
		cmp	al,0EDh
		jne	not_spk_ED			; Jump if not equal
		jmp	narration_tick_top

not_spk_ED:
		mov	byte ptr ds:text_style,40h	; '@'
		cmp	al,0ECh
		jne	not_spk_EC			; Jump if not equal
		jmp	narration_tick_top

not_spk_EC:
		mov	byte ptr ds:text_style,41h	; 'A'
		cmp	al,0EBh
		jne	not_spk_EB			; Jump if not equal
		jmp	narration_tick_top

not_spk_EB:
		mov	ds:text_style,ah
		jmp	narration_tick_top

set_color_pair:
		mov	ds:text_color_fg,bl
		mov	ds:text_color_bg,bh
		jmp	narration_tick_top

new_line_reset:
				mov	word ptr ds:render_x_pos,0
				mov	ds:text_layout,ah
				jmp	narration_tick_top

line_wrap:
				mov	word ptr ds:render_x_pos,0
				inc	byte ptr ds:text_layout
				jmp	narration_tick_top

full_scroll:
				mov	bx,8Fh
				mov	cx,5039h
				xor	al,al			; Zero register
				call	word ptr cs:full_scroll_fn_ptr
				xor	ah,ah			; Zero register
				jmp	short new_line_reset

short_wait:
		mov	al,0F0h
		call	timer_wait_loop
		jmp	narration_tick_top

long_wait:
		mov	al,0F0h
		call	timer_wait_loop
		mov	al,0F0h
		call	timer_wait_loop
		mov	al,0F0h
		call	timer_wait_loop
		jmp	narration_tick_top

portrait_80:
		mov	es,cs:gvar_game_seg
		and	al,0Fh
		cmp	al,6
		jae	portrait_80_alt			; Jump if above or =
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
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_80_alt:
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
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_A0:
		push	cs
		pop	es
		and	al,0Fh
		cmp	al,3
		jae	portrait_A0_alt			; Jump if above or =
		mov	ah,0A5h
		mul	ah			; ax = reg * al
		add	ax,7437h
		mov	di,ax
		mov	bx,3548h
		mov	cx,50Bh
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_A0_alt:
		sub	al,3
		mov	ah,0A8h
		mul	ah			; ax = reg * al
		add	ax,7626h
		mov	di,ax
		mov	bx,343Eh
		mov	cx,708h
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_90:
		mov	es,cs:gvar_game_seg
		and	al,0Fh
		mov	ah,3Fh			; '?'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3850h
		mov	cx,718h
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_B0:
		mov	es,cs:gvar_game_seg
		and	al,0Fh
		cmp	al,6
		jae	portrait_B0_alt			; Jump if above or =
		mov	ah,51h			; 'Q'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,98C0h
		mov	di,ax
		mov	bx,3450h
		mov	cx,918h
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_B0_alt:
		sub	al,6
		mov	ah,2Dh			; '-'
		mul	ah			; ax = reg * al
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,0A7F0h
		mov	di,ax
		mov	bx,3338h
		mov	cx,0A18h
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

portrait_C0:
		and	al,0Fh
		push	cs
		pop	es
		mov	ah,30h			; '0'
		mul	ah			; ax = reg * al
		add	ax,781Eh
		mov	di,ax
		mov	bx,3840h
		mov	cx,208h
		call	word ptr cs:gfx_blit_fn
		jmp	script_fetch_byte

render_narration_page		endp

measure_script_word_width		proc	near
		xor	cx,cx			; Zero register

measure_next:
						lodsb				; String [si] to al
						cmp	al,20h			; ' '
						jne	measure_not_FF			; Jump if not equal
						retn

measure_not_FF:
						cmp	al,0FFh
						jne	measure_not_FE			; Jump if not equal
						retn

measure_not_FE:
						cmp	al,0FEh
						jne	measure_not_FD			; Jump if not equal
						retn

measure_not_FD:
						cmp	al,0FDh
						jne	measure_not_F7			; Jump if not equal
						retn

measure_not_F7:
						cmp	al,0F7h
						jne	measure_not_F3			; Jump if not equal
						retn

measure_not_F3:
						cmp	al,0F3h
						jne	measure_not_F2			; Jump if not equal
						retn

measure_not_F2:
						cmp	al,0F2h
						jne	measure_not_F1			; Jump if not equal
						retn

measure_not_F1:
						cmp	al,0F1h
						jne	measure_add_glyph			; Jump if not equal
						retn

measure_add_glyph:
						or	al,al			; Zero ?
						js	measure_next			; Jump if sign=1
						sub	al,20h			; ' '
						jc	measure_next			; Jump if carry Set
				mov	bl,al
				xor	bh,bh			; Zero register
				add	cl,cs:glyph_space_tbl[bx]
				adc	ch,bh
				jmp	short measure_next

measure_script_word_width		endp

; ------------------------------------------------------------------
; 8 bytes of unreachable padding between narration-section procs and
; credits_scene_start. Appears as 'test al,6Ah; db 6 dup (0)' when
; Sourcer mis-decodes the alignment bytes as instructions.
; ------------------------------------------------------------------
		db	0A8h, 6Ah		; test al,6Ah  (alignment padding, never executed)
		db	0, 0, 0, 0, 0, 0	; alignment padding

credits_scene_start:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		mov	byte ptr ds:credits_scene_idx,0
		mov	si,81E0h
		mov	es,cs:gvar_game_seg
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	ax,cs
		add	ax,2000h
		mov	es,ax
		mov	si,819Fh
		mov	di,0
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81AAh
		mov	di,3400h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81B5h
		mov	di,5E00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81C0h
		mov	di,8A00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81CBh
		mov	di,0B800h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	si,81D6h
		mov	di,0E200h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	ax,7
		call	word ptr cs:gfx_palette_fn
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	word ptr ds:credits_pc,787Eh
		call	credits_loop_main

credits_tick_loop:
				call	credits_driver_tick
				jmp	short credits_tick_loop

credits_loop_main		proc	near
		mov	byte ptr ds:gvar_timer_lo,0

credits_fetch_byte:
		mov	si,ds:credits_pc
		lodsb				; String [si] to al
		mov	ds:credits_pc,si
		cmp	al,0F7h
		je	credits_wait_skip			; Jump if equal
		cmp	al,0F8h
		jne	credits_not_F8			; Jump if not equal
		jmp	credits_set_pause

credits_not_F8:
		cmp	al,0F9h
		jne	credits_not_F9			; Jump if not equal
		jmp	credits_delay_page

credits_not_F9:
		cmp	al,0FAh
		jne	credits_not_FA			; Jump if not equal
		jmp	credits_set_delay

credits_not_FA:
		cmp	al,0FBh
		jne	credits_not_FB			; Jump if not equal
		jmp	credits_set_fg_bg

credits_not_FB:
		cmp	al,0FCh
		jne	credits_not_FC			; Jump if not equal
		jmp	credits_clear_screen

credits_not_FC:
		cmp	al,0FDh
		jne	credits_not_FD			; Jump if not equal
		jmp	credits_new_line

credits_not_FD:
		cmp	al,0FEh
		jne	credits_not_FE			; Jump if not equal
		jmp	credits_scene_next

credits_not_FE:
		cmp	al,0FFh
		jne	credits_not_FF			; Jump if not equal
		jmp	credits_end_page

credits_not_FF:
		cmp	al,9
		jne	credits_render_char			; Jump if not equal
		jmp	credits_tab_indent

credits_render_char:
		push	ax
		xor	al,al			; Zero register
		call	credits_putchar
		mov	al,ds:credits_row_byte
		mov	cl,0Eh
		mul	cl			; ax = reg * al
		mov	cl,al
		add	cl,90h
		mov	bl,ds:credits_col_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		pop	ax
		mov	ah,7
		call	word ptr cs:gfx_putchar_fn
		inc	byte ptr ds:credits_col_byte

credits_after_newline:
		mov	al,0FFh
		call	credits_putchar
		mov	al,ds:credits_tick_delay
		call	credits_wait_tick
		jmp	credits_fetch_byte

credits_wait_skip:
				call	credits_driver_tick
				test	byte ptr ds:gvar_skip_input,0FFh
				jz	credits_wait_skip			; Jump if zero
		mov	byte ptr ds:gvar_skip_input,0
		mov	word ptr ds:gvar_credits_pos,0
		jmp	credits_fetch_byte

credits_set_pause:
		lodsw				; String [si] to ax
		mov	ds:credits_pc,si
		mov	ds:credits_pause_ticks,ax
		jmp	credits_fetch_byte

credits_delay_page:
		xor	al,al			; Zero register
		call	credits_putchar

credits_delay_poll:
				call	credits_driver_tick
				mov	ax,ds:gvar_credits_pos
				cmp	ax,ds:credits_pause_ticks
				jb	credits_delay_poll			; Jump if below
		mov	word ptr ds:gvar_credits_pos,0
		jmp	credits_fetch_byte

credits_set_delay:
		lodsb				; String [si] to al
		mov	ds:credits_pc,si
		mov	ds:credits_tick_delay,al
		jmp	credits_fetch_byte

credits_set_fg_bg:
		lodsw				; String [si] to ax
		mov	ds:credits_row_byte,al
		mov	ds:credits_col_byte,ah
		mov	ds:credits_pc,si
		jmp	credits_fetch_byte

credits_clear_screen:
		mov	bx,8Ch
		mov	cx,503Ch
		xor	al,al			; Zero register
		call	word ptr cs:full_scroll_fn_ptr
		mov	byte ptr ds:credits_col_byte,0
		mov	byte ptr ds:credits_row_byte,0
		jmp	credits_fetch_byte

credits_new_line:
		xor	al,al			; Zero register
		call	credits_putchar
		mov	byte ptr ds:credits_col_byte,0
		inc	byte ptr ds:credits_row_byte
		jmp	credits_fetch_byte

credits_tab_indent:
		xor	al,al			; Zero register
		call	credits_putchar
		add	byte ptr ds:credits_col_byte,4
		and	byte ptr ds:credits_col_byte,0FCh
		jmp	credits_after_newline

credits_putchar:
		push	ax
		mov	al,ds:credits_row_byte
		mov	cl,0Eh
		mul	cl			; ax = reg * al
		add	al,90h
		mov	ah,ds:credits_col_byte
		add	ah,ah
		mov	bx,ax
		pop	ax
		jmp	word ptr cs:gfx_scroll_jmp

credits_end_page:
		xor	al,al			; Zero register
		call	credits_putchar
		retn

credits_scene_next:
		xor	al,al			; Zero register
		call	credits_putchar
		mov	bl,ds:credits_scene_idx
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:credit_scene_fn_tbl[bx]	;*
		inc	byte ptr ds:credits_scene_idx
		jmp	credits_fetch_byte

credits_loop_main		endp

; =====================================================================
; ending_credits_dispatch - 7 per-scene handler procs called via
;   call word ptr ds:credit_scene_fn_tbl[bx]   (where BX = scene_idx * 2)
;
; The first 14 bytes (CS:0824..0831) are the dispatch-init word-table
; template. The table is copied/relocated into ds:6820 at runtime; each
; handler decompresses a pre-loaded credit sprite/tile chunk via
; rle_blit_pair then calls/jmps gfx_draw_fn/gfx_update_fn/gfx_blit_fn
; or the gfx_scene_fn* dispatch entries to commit to VGA.
;
; Handler entry points (CS-relative, reached via ds:credit_scene_fn_tbl[bx]):
;     0x0832 - credit_scene_0_impl  (first credit page)
;     0x085E - credit_scene_1_impl  (second page: producer/translator)
;     0x0895 - credit_scene_2_impl  (lead programmer/graphics)
;     0x08B9 - credit_scene_3_impl  (music composers)
;     0x08C6 - credit_scene_4_impl  (story/sfx)
;     0x08D3 - credit_scene_5_impl  (special thanks)
;     0x0936 - credit_scene_6_impl  (final copyright page)
;
; Handlers end in indirect far-jmps through the cs:gfx_*_fn table, so
; decoding to mnemonics would re-encode with different prefix bytes.
; Kept as db for bit-perfect output.
; =====================================================================

ending_credits_dispatch:
; Dispatch table template (14 bytes) at CS:0824:
;   dw 682Eh, 685Ah, 6891h, 68B5h, 68C2h, 68CFh, 6932h
		db	 2Eh, 68h, 5Ah, 68h, 91h, 68h	; +0x000
		db	0B5h, 68h,0C2h, 68h,0CFh, 68h	; +0x006
		db	 32h, 69h	; +0x00C
; credit_scene_0_impl @ CS:0832:
;   push ds; mov ax,cs; add ax,2000h; mov ds,ax; mov es,cs:gvar_game_seg;
;   mov si,0; mov di,4000h; call rle_blit_pair; pop ds;
;   mov es,cs:gvar_game_seg; mov di,4000h; mov al,0FFh;
;   mov bx,0B08h; mov cx,399Ah; jmp cs:gfx_draw_fn
		db	 1Eh, 8Ch,0C8h, 05h	; +0x00E
		db	 00h, 20h, 8Eh,0D8h, 2Eh, 8Eh	; +0x012
		db	 06h, 2Ch,0FFh,0BEh, 00h, 00h	; +0x018
		db	0BFh, 00h, 40h,0E8h, 29h, 01h	; +0x01E
		db	 1Fh, 2Eh, 8Eh, 06h, 2Ch,0FFh	; +0x024
		db	0BFh, 00h, 40h,0B0h,0FFh,0BBh	; +0x02A
		db	 08h, 0Bh,0B9h, 9Ah, 39h, 2Eh	; +0x030
		db	0FFh, 26h, 04h, 30h	; +0x036
; credit_scene_1_impl @ CS:085E:
;   similar to scene_0 but dst=3400h, then calls gfx_update_fn twice,
;   then mov bx,2114h/cx,2F72h and jmps gfx_draw_fn
		db	 1Eh, 8Ch	; +0x03A
		db	0C8h, 05h, 00h, 20h, 8Eh,0D8h	; +0x03C
		db	 2Eh, 8Eh, 06h, 2Ch,0FFh,0BFh	; +0x042
		db	 00h, 40h,0BEh, 00h, 34h,0E8h	; +0x048
		db	0FDh, 00h, 1Fh,0BBh, 08h, 0Bh	; +0x04E
		db	0B9h, 9Ah, 39h, 2Eh,0FFh, 16h	; +0x054
		db	 06h, 30h, 2Eh, 8Eh, 06h, 2Ch	; +0x05A
		db	0FFh,0BFh, 00h, 40h,0B0h,0FFh	; +0x060
		db	0BBh, 14h, 21h,0B9h, 72h, 2Fh	; +0x066
		db	 2Eh,0FFh, 26h, 04h, 30h	; +0x06C
; credit_scene_2_impl @ CS:0895:
;   dst=4000h src=5E00h, after rle_blit jmps cs:[302Ah]
		db	 1Eh	; +0x071
		db	 8Ch,0C8h, 05h, 00h, 20h, 8Eh	; +0x072
		db	0D8h, 2Eh, 8Eh, 06h, 2Ch,0FFh	; +0x078
		db	0BEh, 00h, 5Eh,0BFh, 00h, 40h	; +0x07E
		db	0E8h,0C6h, 00h, 1Fh, 2Eh, 8Eh	; +0x084
		db	 06h, 2Ch,0FFh,0BFh, 00h, 40h	; +0x08A
		db	 2Eh,0FFh, 26h, 2Ah, 30h	; +0x090
; credit_scene_3_impl @ CS:08B9:
;   mov es,cs:gvar_game_seg; mov di,4000h; jmp cs:[302Ch]
		db	 2Eh	; +0x095
		db	 8Eh, 06h, 2Ch,0FFh,0BFh, 00h	; +0x096
		db	 40h, 2Eh,0FFh, 26h, 2Ch, 30h	; +0x09C
; credit_scene_4_impl @ CS:08C6:
;   mov al,0FFh; mov bx,0; mov cx,50C8h; jmp cs:gfx_update_fn
		db	0B0h,0FFh,0BBh, 00h, 00h,0B9h	; +0x0A2
		db	0C8h, 50h, 2Eh,0FFh, 26h, 06h	; +0x0A8
		db	 30h	; +0x0AE
; credit_scene_5_impl @ CS:08D3:
;   large handler -- loads two chunks, rep movsw/stosw to copy VGA buffer,
;   then chains two gfx_* calls ending with a near jmp to the final page
		db	 1Eh, 8Ch,0C8h, 05h, 00h	; +0x0AF
		db	 20h, 8Eh,0D8h, 2Eh, 8Eh, 06h	; +0x0B4
		db	 2Ch,0FFh,0BEh, 00h, 8Ah,0BFh	; +0x0BA
		db	 00h, 40h,0E8h, 88h, 00h,0BEh	; +0x0C0
		db	 00h,0B8h,0BFh,0C0h, 93h,0B9h	; +0x0C6
		db	0F0h, 14h,0F3h,0A5h, 1Fh,0BFh	; +0x0CC
		db	 00h, 40h, 33h,0C0h,0B9h, 28h	; +0x0D2
		db	 00h,0F3h,0ABh, 2Eh, 8Eh, 06h	; +0x0D8
		db	 2Ch,0FFh,0BFh, 00h, 40h,0B0h	; +0x0DE
		db	0FFh,0BBh, 00h, 00h,0B9h, 86h	; +0x0E4
		db	 50h, 2Eh,0FFh, 16h, 04h, 30h	; +0x0EA
		db	 1Eh, 8Ch,0C8h, 05h, 00h, 20h	; +0x0F0
		db	 8Eh,0D8h, 2Eh, 8Eh, 06h, 2Ch	; +0x0F6
		db	0FFh,0BEh, 00h,0E2h,0BFh,0A0h	; +0x0FC
		db	0BDh,0E8h, 4Ch, 00h, 1Fh, 2Eh	; +0x102
		db	 8Eh, 06h, 2Ch,0FFh,0BFh,0A0h	; +0x108
		db	0BDh,0E9h, 20h, 01h	; +0x10E
; credit_scene_6_impl @ CS:0936:
;   mov es,cs:gvar_game_seg; mov di,4000h; mov bx,0; mov cx,5086h;
;   jmp cs:[3010h] (=gfx_blit_fn)
		db	 2Eh, 8Eh	; +0x112
		db	 06h, 2Ch,0FFh,0BFh, 00h, 40h	; +0x114
		db	0BBh, 00h, 00h,0B9h, 86h, 50h	; +0x11A
		db	 2Eh,0FFh, 26h, 10h	; +0x120
		db	30h	; +0x124

credits_wait_tick		proc	near

credits_wait_poll:
				call	credits_driver_tick
				cmp	cs:gvar_timer_lo,al
				jb	credits_wait_poll			; Jump if below
		mov	byte ptr cs:gvar_timer_lo,0
		retn

credits_wait_tick		endp

credits_driver_tick		proc	near
		push	si
		push	ax
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		pop	ax
		pop	si
		retn

credits_driver_tick		endp

		db	8 dup (0)

rle_blit_pair		proc	near
		call	rle_decode_plane
		jmp	short rle_interleave_planes

rle_decode_plane:
		push	di
		lodsw				; String [si] to ax
		mov	cx,ax
		push	cx
		mov	bp,si
		add	si,cx

rle_word_loop:
				push	cx
				xor	al,al			; Zero register
				mov	cx,8

rle_bit_loop:
						rol	byte ptr ds:[bp],1	; Rotate
						jc	rle_bit_one			; Jump if carry Set
						stosb				; Store al to es:[di]
						loop	rle_bit_loop		; Loop if cx > 0

						jmp	short rle_word_tail

rle_bit_one:
						movsb				; Mov [si] to es:[di]
						loop	rle_bit_loop		; Loop if cx > 0

rle_word_tail:
				inc	bp
				pop	cx
				loop	rle_word_loop		; Loop if cx > 0

		pop	cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		pop	di
		retn

rle_interleave_planes:
		xor	dh,dh			; Zero register

interleave_plane_loop:
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
				loop	interleave_plane_loop		; Loop if cx > 0

		retn

rle_blit_pair		endp

tile_rle_blit:
						test	byte ptr [si],40h	; '@'
						jz	tile_rle_byte_mode			; Jump if zero
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cx,ax
						cmp	ax,0FFFFh
						jne	tile_rle_word_mode			; Jump if not equal
						retn

tile_rle_word_mode:
						and	cx,3FFFh
						test	ax,8000h
						jz	tile_rle_copy			; Jump if zero

tile_rle_fill:
						lodsb				; String [si] to al
						rep	stosb			; Rep when cx >0 Store al to es:[di]
						jmp	short tile_rle_blit

tile_rle_copy:
						rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
						jmp	short tile_rle_blit

tile_rle_byte_mode:
						lodsb				; String [si] to al
						mov	cl,al
						and	cx,3Fh
						test	al,80h
						jz	tile_rle_copy			; Jump if zero
				jmp	short tile_rle_fill

fill_credits_triplane		proc	near
		mov	bx,18h
		mul	bx			; dx:ax = reg * ax
		add	si,ax
		xor	ax,ax			; Zero register
		push	si
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	si
		add	si,rle_stride_a
		push	si
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		pop	si
		add	si,rle_stride_a
		mov	cx,414h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	cx,0Ch
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

fill_credits_triplane		endp

; =====================================================================
; or_triplane_mask - OR-then-AND composite mask into 3 parallel planes.
; Entered (indirectly) from the narration/credits scene handler code
; via the cs:gfx_scene_fn* dispatch. Consumes ES:DI (destination base)
; and DS:SI (set up in-line from caller) then writes mask words into
; three interleaved planes at offsets 0, plane_mid_ofs, and
; plane_top_ofs within game_seg.
; =====================================================================

or_triplane_mask:
		push	ds
		push	es
		pop	ds
		push	di
		pop	si
		mov	es,cs:gvar_game_seg
		mov	di,or_mask_base
		mov	cx,35h

triplane_row_loop:
				push	cx
				push	di
				mov	cx,13h

triplane_or_inner:
						lodsw				; String [si] to ax
						or	es:[di],ax
						or	es:plane_mid_ofs[di],ax
						or	es:plane_top_ofs[di],ax
						inc	di
						inc	di
						loop	triplane_or_inner		; Loop if cx > 0

				pop	di
				add	di,50h
				pop	cx
				loop	triplane_row_loop		; Loop if cx > 0

		mov	di,or_mask_base
		mov	cx,35h

triplane_and_loop:
				push	cx
				push	di
				mov	cx,13h

triplane_and_inner:
						lodsw				; String [si] to ax
						not	ax
						and	es:[di],ax
						and	es:plane_mid_ofs[di],ax
						and	es:plane_top_ofs[di],ax
						inc	di
						inc	di
						loop	triplane_and_inner		; Loop if cx > 0

				pop	di
				add	di,50h
				pop	cx
				loop	triplane_and_loop		; Loop if cx > 0

		pop	ds
		retn

; =====================================================================
; narration_script_page_1 - Ending narration text (Page 1: Jashiin's
; defeat, Felicia restored, Duke reunited with father).
; Consumed by render_narration_page, which interprets each byte via
; the SCR_* control codes and ANIM_* per-character color animators.
; =====================================================================

narration_script_page_1:
		db	SCR_RESET, SCR_NORMAL, SCR_PARA	; +0x000
		db	'At long last, Jashiin was destro'
		db	'yed and the nine Tears of Esmesa'
		db	'nti were returned to their right'
		db	'ful place.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA	; +0x06D
		db	'Princess Felicia was restored to'
		db	' her true form.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_BOLD,SCR_SCROLL,SCR_PARA	; +0x0A1
		db	SCR_SPK_UNK, 22h, ANIM_95, 59h, 6Fh, 75h	; +0x0A7
		db	 20h, ANIM_90, 61h, 72h, 65h, ANIM_94	; +0x0AD
		db	 20h, ANIM_90, 61h, ANIM_95, 73h, 20h	; +0x0B3
		db	 ANIM_92, 62h, 65h, ANIM_95, 61h, 75h	; +0x0B9
		db	 ANIM_92, 74h, 69h, ANIM_95, 66h, 75h	; +0x0BF
		db	 ANIM_93, 6Ch, 20h, ANIM_90, 61h, ANIM_95	; +0x0C5
		db	 73h, 20h, ANIM_90, 61h, 20h, ANIM_93	; +0x0CB
		db	 72h, 6Fh, ANIM_91, 73h, 65h, 20h	; +0x0D1
		db	 ANIM_92, 69h, ANIM_94, 6Eh, 20h, ANIM_93	; +0x0D7
		db	 62h, ANIM_95, 6Ch, 6Fh, 6Fh, ANIM_94	; +0x0DD
		db	 6Dh, 21h, 22h,SCR_WAIT,SCR_MODE2,SCR_SPK_PRINC	; +0x0E3
		db	ANIM_A3, 22h,ANIM_A4,ANIM_A0, 54h,ANIM_A5	; +0x0E9
		db	 68h,ANIM_A4, 61h,ANIM_A3,ANIM_A2, 6Eh	; +0x0EF
		db	ANIM_A1, 6Bh, 20h,ANIM_A2, 79h, 6Fh	; +0x0F5
		db	 75h, 2Ch, 20h,ANIM_A1,ANIM_A3, 44h	; +0x0FB
		db	ANIM_A4, 75h,ANIM_A5, 6Bh,ANIM_A4, 65h	; +0x101
		db	ANIM_A3, 20h,ANIM_A0, 47h, 61h, 72h	; +0x107
		db	ANIM_A1, 6Ch, 61h,ANIM_A2, 6Eh, 64h	; +0x10D
		db	 2Eh, 22h,ANIM_A1,SCR_WAIT,SCR_WAIT,SCR_WAIT	; +0x113
		db	SCR_SCROLL,SCR_PARA, 22h,ANIM_A1, 59h, 6Fh	; +0x119
		db	 75h, 20h,ANIM_A0, 68h, 61h,ANIM_A2	; +0x11F
		db	 76h, 65h, 20h,ANIM_A1, 64h, 6Fh	; +0x125
		db	ANIM_A2, 6Eh, 65h, 20h,ANIM_A0, 61h	; +0x12B
		db	 20h,ANIM_A1, 67h, 72h, 65h,ANIM_A0	; +0x131
		db	 61h, 74h, 20h,ANIM_A1, 64h, 65h	; +0x137
		db	 65h, 64h, 20h,ANIM_A2, 69h, 6Eh	; +0x13D
		db	 20h,ANIM_A0, 64h, 65h, 66h, 65h	; +0x143
		db	 61h,ANIM_A1, 74h,ANIM_A2, 69h, 6Eh	; +0x149
		db	 67h, 20h,ANIM_A1, 4Ah, 61h, 73h	; +0x14F
		db	 68h, 69h,ANIM_A2, 69h, 6Eh, 2Eh	; +0x155
		db	ANIM_A1, 20h, 20h,SCR_WAIT,ANIM_A0,ANIM_A4	; +0x15B
		db	 41h,ANIM_A5, 6Ch,ANIM_A4,ANIM_A2, 74h	; +0x161
		db	ANIM_A3, 68h, 6Fh, 75h,ANIM_A1, 67h	; +0x167
		db	 68h, 20h,ANIM_A0, 6Dh, 79h, 20h	; +0x16D
		db	ANIM_A1, 62h, 6Fh, 64h,ANIM_A1, 79h	; +0x173
		db	 20h,ANIM_A0, 77h, 61h,ANIM_A1, 73h	; +0x179
		db	 20h,ANIM_A1, 68h,ANIM_A0, 65h, 72h	; +0x17F
		db	 65h, 2Ch, 20h,ANIM_A4, 6Dh,ANIM_A5	; +0x185
		db	ANIM_A1, 79h,ANIM_A4, 20h,ANIM_A3,ANIM_A1	; +0x18B
		db	 73h, 6Fh,ANIM_A2, 75h, 6Ch, 20h	; +0x191
		db	ANIM_A0, 77h, 61h,ANIM_A2, 73h, 20h	; +0x197
		db	ANIM_A2, 77h,ANIM_A1, 69h, 74h, 68h	; +0x19D
		db	 20h,ANIM_A0, 74h, 68h, 65h, 20h	; +0x1A3
		db	ANIM_A1, 48h, 6Fh,ANIM_A2, 6Ch, 79h	; +0x1A9
		db	 20h,ANIM_A2, 53h,ANIM_A1, 70h, 69h	; +0x1AF
		db	ANIM_A0, 72h,ANIM_A2, 69h, 74h, 2Ch	; +0x1B5
		db	 20h,ANIM_A0, 77h, 61h, 74h,ANIM_A1	; +0x1BB
		db	 63h, 68h,ANIM_A2, 69h, 6Eh, 67h	; +0x1C1
		db	 20h,ANIM_A1, 79h, 6Fh, 75h, 2Eh	; +0x1C7
		db	 22h,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA	; +0x1CD
		db	 22h,ANIM_A0, 49h, 20h,ANIM_A1, 64h	; +0x1D3
		db	 6Fh,ANIM_A2, 6Eh, 27h, 74h, 20h	; +0x1D9
		db	ANIM_A1, 6Bh,ANIM_A2, 6Eh, 6Fh, 77h	; +0x1DF
		db	 20h,ANIM_A0, 68h, 6Fh,ANIM_A2, 77h	; +0x1E5
		db	 20h,ANIM_A1, 74h, 6Fh, 20h,ANIM_A0	; +0x1EB
		db	 74h, 68h, 61h,ANIM_A2, 6Eh, 6Bh	; +0x1F1
		db	 20h,ANIM_A1, 79h, 6Fh, 75h, 20h	; +0x1F7
		db	ANIM_A2, 66h, 6Fh, 72h, 20h,ANIM_A1	; +0x1FD
		db	 72h, 65h,ANIM_A2, 73h, 63h, 75h	; +0x203
		db	ANIM_A1, 69h, 6Eh, 67h, 20h,ANIM_A2	; +0x209
		db	 6Dh, 65h, 20h,ANIM_A0, 61h, 6Eh	; +0x20F
		db	 64h, 20h,ANIM_A1, 73h, 61h, 76h	; +0x215
		db	ANIM_A2, 69h, 6Eh, 67h, 20h,ANIM_A0	; +0x21B
		db	 6Dh, 79h, 20h,ANIM_A1, 63h, 6Fh	; +0x221
		db	ANIM_A0, 75h, 6Eh,ANIM_A2, 74h, 72h	; +0x227
		db	 79h, 2Eh, 22h,ANIM_A1,SCR_WAIT,SCR_WAIT	; +0x22D
		db	SCR_WAIT,SCR_SCROLL,SCR_BREAK,SCR_PARA	; +0x233
		db	'"Father!"'
		db	SCR_WAIT,SCR_WAIT,SCR_MODE2,SCR_SPK_KING	; +0x240
		db	'"My darling Felicia!  '
		db	SCR_WAIT	; +0x25A
		db	'Ho'
		db	'w I'
		db	27h, 've longed to hold you in my'
		db	' arms and hear your sweet voice!'
		db	'"'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_NORMAL,SCR_SCROLL,SCR_PARA	; +0x29D
		db	SCR_RESET	; +0x2A3
		db	'Outside, the land cursed by the '
		db	'evil magic of Jashiin began to r'
		db	'esume its original lushness.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA	; +0x300
		db	'The dreadful power of Jashiin wa'
		db	's washed from the earth, and the'
		db	' land of Zeliard was peaceful on'
		db	'ce more.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK,SCR_NORMAL	; +0x36D
		db	SCR_PARA	; +0x373
		db	'The Guardian Spirit of the Holy '
		db	'Land of Zeliard appeared before '
		db	'Duke Garland once again.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA,SCR_BOLD	; +0x3CC
		db	SCR_SPK_DEMON	; +0x3D2
		db	'"You have suffered many hardship'
		db	's to defeat Jashiin, Duke Garlan'
		db	'd."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_BREAK,SCR_BOLD	; +0x416
		db	SCR_PARA, 22h, ANIM_83, 59h, 6Fh, 75h	; +0x41C
		db	 20h, ANIM_81, 66h, 6Fh, 75h, ANIM_82	; +0x422
		db	 67h, 68h, 74h, 20h, ANIM_83, 62h	; +0x428
		db	 ANIM_81, 72h, 61h, ANIM_83, 76h, 65h	; +0x42E
		db	 ANIM_82, 6Ch, 79h, 20h, ANIM_83, 74h	; +0x434
		db	 6Fh, 20h, ANIM_80, 61h, ANIM_83, 63h	; +0x43A
		db	 63h, 6Fh, ANIM_84, 6Dh, ANIM_82, 70h	; +0x440
		db	 6Ch, 69h, ANIM_83, 73h, 68h, 20h	; +0x446
		db	 ANIM_82, 74h, 68h, 69h, ANIM_83, 73h	; +0x44C
		db	 20h, ANIM_83, 71h, 75h, ANIM_81, 65h	; +0x452
		db	 ANIM_83, 73h, 74h, 2Eh, 20h, 20h	; +0x458
		db	SCR_WAIT, ANIM_80, 42h, 75h, ANIM_83, 74h	; +0x45E
		db	 20h, ANIM_82, 74h, 68h, 69h, ANIM_83	; +0x464
		db	 73h, 20h, ANIM_80, 77h, 61h, ANIM_83	; +0x46A
		db	 73h, 20h, 6Fh, ANIM_84, 6Eh, ANIM_82	; +0x470
		db	 6Ch, 79h, 20h, ANIM_81, 74h, 68h	; +0x476
		db	 65h, 20h, ANIM_82, 62h, 65h, 67h	; +0x47C
		db	 69h, 6Eh, ANIM_84, 6Eh, 69h, 6Eh	; +0x482
		db	 ANIM_83, 67h, 2Eh, 20h, 20h, ANIM_84	; +0x488
		db	SCR_WAIT, ANIM_83, 59h, 6Fh, 75h, ANIM_80	; +0x48E
		db	 72h, 20h, ANIM_81, 6Eh, 65h, ANIM_83	; +0x494
		db	 78h, 74h, 20h, ANIM_82, 6Dh, 69h	; +0x49A
		db	 ANIM_83, 73h, 73h, ANIM_82, 69h, 6Fh	; +0x4A0
		db	 ANIM_84, 6Eh, 20h, ANIM_80, 61h, 77h	; +0x4A6
		db	 61h, ANIM_82, 69h, ANIM_83, 74h, 73h	; +0x4AC
		db	 20h, ANIM_83, 79h, 6Fh, 75h, 20h	; +0x4B2
		db	 ANIM_82, 69h, ANIM_84, 6Eh, 20h, ANIM_80	; +0x4B8
		db	 61h, 20h, ANIM_82, 6Eh, 65h, ANIM_83	; +0x4BE
		db	 77h, 20h, ANIM_80, 6Ch, 61h, ANIM_84	; +0x4C4
		db	 6Eh, 64h, 2Eh, 22h,SCR_WAIT,SCR_WAIT	; +0x4CA
		db	SCR_WAIT,SCR_SCROLL,SCR_DIRECT,SCR_SPK_UNK, 22h, ANIM_90	; +0x4D0
		db	 4Dh, ANIM_92, 79h, 20h, ANIM_91, 6Eh	; +0x4D6
		db	 65h, ANIM_93, 78h, 74h, 20h, ANIM_92	; +0x4DC
		db	 6Dh, 69h, ANIM_93, 73h, 73h, 69h	; +0x4E2
		db	 6Fh, ANIM_94, 6Eh, 3Fh, 22h, ANIM_97	; +0x4E8
		db	 20h, ANIM_98, 20h, ANIM_97, 20h, ANIM_96	; +0x4EE
		db	SCR_WAIT,SCR_PARA,SCR_SPK_DEMON, 22h, ANIM_81, 54h	; +0x4F4
		db	 68h, 65h, ANIM_80, 72h, 65h, 20h	; +0x4FA
		db	 ANIM_80, 61h, 72h, 65h, 20h, ANIM_81	; +0x500
		db	 6Dh, 61h, ANIM_84, 6Eh, 79h, 20h	; +0x506
		db	 ANIM_83, 77h, 68h, 6Fh, 20h, ANIM_81	; +0x50C
		db	 68h, 61h, ANIM_83, 76h, 65h, 20h	; +0x512
		db	 ANIM_82, 6Eh, 65h, 65h, ANIM_83, 64h	; +0x518
		db	 20h, 6Fh, 66h, ANIM_84, 20h, ANIM_83	; +0x51E
		db	 79h, 6Fh, ANIM_80, 75h, 72h, 20h	; +0x524
		db	 ANIM_83, 73h, ANIM_81, 70h, 65h, ANIM_82	; +0x52A
		db	 63h, 69h, ANIM_80, 61h, ANIM_83, 6Ch	; +0x530
		db	 20h, ANIM_80, 74h, 61h, ANIM_81, 6Ch	; +0x536
		db	 65h, ANIM_84, 6Eh, ANIM_82, 74h, 73h	; +0x53C
		db	 2Eh, 20h, 20h, ANIM_84,SCR_WAIT, ANIM_83	; +0x542
		db	 46h, 6Fh, 6Ch, 6Ch, 6Fh, 77h	; +0x548
		db	 20h, ANIM_82, 6Dh, 65h, 20h, ANIM_80	; +0x54E
		db	 61h, ANIM_84, 6Eh, 64h, 20h, ANIM_80	; +0x554
		db	 49h, 20h, ANIM_83, 77h, ANIM_82, 69h	; +0x55A
		db	 6Ch, 6Ch, 20h, ANIM_83, 73h, 68h	; +0x560
		db	 6Fh, 77h, ANIM_81, 20h, ANIM_85, 79h	; +0x566
		db	 6Fh, 75h, 20h, ANIM_81, 74h, 68h	; +0x56C
		db	 65h, 20h, ANIM_83, 77h, ANIM_80, 61h	; +0x572
		db	 ANIM_82, 79h, 2Eh, ANIM_84, 20h,SCR_WAIT	; +0x578
		db	 ANIM_83, 57h, ANIM_82, 65h, 20h, ANIM_80	; +0x57E
		db	 6Dh, 75h, ANIM_83, 73h, 74h, 20h	; +0x584
		db	 ANIM_81, 64h, 65h, ANIM_80, 70h, 61h	; +0x58A
		db	 72h, ANIM_83, 74h, 20h, ANIM_85, 71h	; +0x590
		db	 75h, ANIM_82, 69h, 63h, ANIM_83, 6Bh	; +0x596
		db	 ANIM_82, 6Ch, 79h, 2Eh, 22h, ANIM_84	; +0x59C
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_RESET,SCR_PARA	; +0x5A2
		db	SCR_NORMAL	; +0x5A8
		db	'There was no time to rest, '
		db	 ANIM_97, 61h, 6Eh, ANIM_98	; +0x5C4
		db	'd no time t'
		db	'o stay in this peaceful land.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_BREAK,SCR_SCROLL,SCR_PARA	; +0x5F0
		db	SCR_BOLD,SCR_SPK_PRINC, ANIM_97, 22h, ANIM_96,ANIM_B0	; +0x5F6
		db	 4Dh, 75h,ANIM_B3, 73h,ANIM_B4, 74h	; +0x5FC
		db	 20h, 79h, 6Fh, 75h, 20h,ANIM_B2	; +0x602
		db	 6Ch, 65h,ANIM_B1, 61h,ANIM_B3, 76h	; +0x608
		db	 65h,ANIM_B4, 20h,ANIM_B3, 73h, 6Fh	; +0x60E
		db	 20h,ANIM_B5, 73h, 6Fh, 6Fh,ANIM_B4	; +0x614
		db	 6Eh, 2Ch, 20h,ANIM_B7,ANIM_B3, 44h	; +0x61A
		db	ANIM_B8, 75h,ANIM_B1,ANIM_B7, 6Bh,ANIM_B6	; +0x620
		db	 65h, 20h,ANIM_B0, 47h, 61h, 72h	; +0x626
		db	 6Ch, 61h,ANIM_B4, 6Eh, 64h, 3Fh	; +0x62C
		db	 20h, 20h,SCR_WAIT,SCR_MODE2,ANIM_B7,ANIM_B0	; +0x632
		db	 49h,ANIM_B8, 20h,ANIM_B7,ANIM_B5, 77h	; +0x638
		db	ANIM_B6,ANIM_B0, 61h, 73h, 20h,ANIM_B3	; +0x63E
		db	 68h, 6Fh, 70h,ANIM_B2, 69h,ANIM_B4	; +0x644
		db	 6Eh,ANIM_B3, 67h, 2Eh, 2Eh, 2Eh	; +0x64A
		db	ANIM_B4, 22h,SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL	; +0x650
		db	SCR_DIRECT,SCR_SPK_UNK, 22h, ANIM_95, 50h, 72h	; +0x656
		db	 ANIM_92, 69h, ANIM_94, 6Eh, ANIM_91, 63h	; +0x65C
		db	 65h, ANIM_93, 73h, 73h, 20h, ANIM_91	; +0x662
		db	 46h, 65h, ANIM_92, 6Ch, 69h, 63h	; +0x668
		db	 69h, ANIM_90, 61h, 2Ch, 20h, ANIM_97	; +0x66E
		db	 ANIM_90, 49h, ANIM_98, ANIM_92, 20h, ANIM_97	; +0x674
		db	 ANIM_90, 6Dh, ANIM_96, 75h, ANIM_93, 73h	; +0x67A
		db	 74h, 20h, ANIM_92, 62h, 69h, ANIM_93	; +0x680
		db	 64h, 20h, ANIM_93, 79h, 6Fh, 75h	; +0x686
		db	 20h, ANIM_91, 66h, 61h, ANIM_90, 72h	; +0x68C
		db	 65h, ANIM_91, 77h, 65h, ANIM_93, 6Ch	; +0x692
		db	 6Ch, 2Eh, ANIM_94, 20h, 20h,SCR_WAIT	; +0x698
		db	 ANIM_93, 4Dh, 6Fh, 72h, ANIM_94, 6Eh	; +0x69E
		db	 69h, 6Eh, ANIM_95, 67h, 20h, ANIM_92	; +0x6A4
		db	 69h, ANIM_95, 73h, 20h, ANIM_90, 63h	; +0x6AA
		db	 6Fh, 6Dh, ANIM_92, 69h, ANIM_94, 6Eh	; +0x6B0
		db	 67h, 20h, ANIM_93, 73h, 6Fh, 6Fh	; +0x6B6
		db	 ANIM_94, 6Eh, 2Ch, 20h, ANIM_90, 61h	; +0x6BC
		db	 ANIM_94, 6Eh, 64h, 20h, ANIM_90, 49h	; +0x6C2
		db	 ANIM_92, 20h, ANIM_97, ANIM_92, 77h, ANIM_98	; +0x6C8
		db	 69h, ANIM_93, ANIM_97, 6Ch, ANIM_96, 6Ch	; +0x6CE
		db	 20h, ANIM_92, 6Dh, 69h, ANIM_93, 73h	; +0x6D4
		db	 73h, 20h, ANIM_91, 74h, 68h, 65h	; +0x6DA
		db	 20h, ANIM_90, 6Ch, ANIM_91, 69h, 67h	; +0x6E0
		db	 ANIM_93, 68h, 74h, 20h, 6Fh, ANIM_95	; +0x6E6
		db	 66h, 20h, ANIM_93, 53h, ANIM_92, 70h	; +0x6EC
		db	 69h, 72h, 69h, ANIM_93, 74h, 20h	; +0x6F2
		db	 75h, ANIM_94, 6Eh, ANIM_91, 6Ch, 65h	; +0x6F8
		db	 ANIM_93, 73h, 73h, 20h, ANIM_90, 49h	; +0x6FE
		db	 ANIM_92, 20h, 73h, ANIM_90, 74h, 61h	; +0x704
		db	 72h, ANIM_94, 74h, 20h, ANIM_91, 62h	; +0x70A
		db	 65h, ANIM_93, 66h, 6Fh, ANIM_90, 72h	; +0x710
		db	 65h, 20h, ANIM_91, 74h, 68h, 65h	; +0x716
		db	 20h, ANIM_90, 64h, 61h, ANIM_94, 77h	; +0x71C
		db	 6Eh, 2Eh, 22h,SCR_WAIT,SCR_WAIT,SCR_WAIT	; +0x722
		db	SCR_SCROLL,SCR_RESET,SCR_PARA,SCR_NORMAL	; +0x728
		db	'Th'
		db	'e Duke answered quickly, as if t'
		db	'o head off the'
		db	' next words of Princess Felicia.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_BREAK,SCR_SCROLL,SCR_PARA	; +0x77C
		db	SCR_NORMAL	; +0x782
		db	'For if he heard those words, he '
		db	'might not be able to leave, as h'
		db	'e knew '
		db	'he must.  '
		db	SCR_WAIT	; +0x7D4
		db	'He turned and walked away...'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT,SCR_BOLD	; +0x7F1
		db	SCR_SPK_PRINC, 22h,ANIM_C0, 44h, 6Fh,ANIM_C1	; +0x7F7
		db	 6Eh, 27h, 74h, 20h,ANIM_C0, 67h	; +0x7FD
		db	 6Fh, 2Ch, 20h,ANIM_C1, 44h, 75h	; +0x803
		db	ANIM_C0, 6Bh, 65h, 20h,ANIM_C0, 47h	; +0x809
		db	 61h, 72h,ANIM_C1, 6Ch, 61h, 6Eh	; +0x80F
		db	ANIM_C0, 64h, 21h, 22h,SCR_WAIT,SCR_RESET	; +0x815
		db	SCR_PARA,SCR_NORMAL	; +0x81B
		db	'... and did not look back.'
		db	SCR_WAIT,SCR_BREAK,SCR_MODE2	; +0x837
		db	'Duke Garlan'
		db	'd lef'
		db	't t'
		db	'he castle, and he felt as if his'
		db	' heart might break.'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_DIRECT	; +0x880
		db	 41h, 73h, 20h, 73h	; +0x885
		db	'he watched him go, Princess Feli'
		db	'cia said to herself, '
		db	SCR_WAIT,SCR_MODE2,SCR_BOLD	; +0x8BE
		db	'"He will return.  '
		db	SCR_WAIT	; +0x8D3
		db	'The road to his destiny, began h'
		db	'ere, and it shall end here."'
		db	SCR_WAIT,SCR_WAIT,SCR_WAIT,SCR_SCROLL,SCR_PARA	; +0x910
		db	'"When his work in the world is d'
		db	'one, he', 27h, 'l'
		db	'l come back to me.  '
		db	SCR_WAIT	; +0x952
		db	'Until then, I can only believe i'
		db	't, and wait for him."'
		db	SCR_WAIT, SCR_WAIT, SCR_WAIT, SCR_WAIT, SCR_WAIT, SCR_BREAK	; +0x988
		db	SCR_END_SCRIPT	; +0x98E

; =====================================================================
; end_portrait_bitmap - Packed 3-plane character-portrait bitmap used
; to render the Princess/Duke/King faces during the narration pages.
; Rendered by rle_blit_pair / tile_rle_blit before each page of text
; is drawn by render_narration_page. Terminated by the FAh byte that
; transitions into the STAFF credits banner bitmap.
; =====================================================================

end_portrait_bitmap:
		db	 77h, 00h, 77h, 77h, 70h	; +0x000
		db	 5Dh,0DDh,0DDh,0DDh,0DCh, 3Fh	; +0x005
		db	0E0h, 94h, 77h, 70h, 1Dh,0D9h	; +0x00B
		db	0E3h,0DDh,0C0h, 07h, 75h, 07h	; +0x011
		db	 77h, 00h, 01h,0DCh, 1Dh,0DCh	; +0x017
		db	 00h, 80h, 77h, 77h, 70h, 04h	; +0x01D
		db	 88h, 1Dh,0DDh, 80h, 08h,0B2h	; +0x023
		db	 03h, 70h, 00h, 74h,0FCh, 00h	; +0x029
		db	 00h, 00h,0D8h,0D6h, 00h, 00h	; +0x02F
		db	 07h, 74h,0FFh,0E0h, 7Fh,0FFh	; +0x035
		db	0F1h, 7Fh,0FFh,0FFh,0FFh,0FCh	; +0x03B
		db	 3Fh,0F9h,0F7h,0FFh,0F8h, 9Fh	; +0x041
		db	0F9h,0EFh,0FFh,0E0h,0C7h,0FFh	; +0x047
		db	0FFh,0FFh, 84h,0F1h,0FEh, 1Fh	; +0x04D
		db	0FEh, 0Ch,0FCh, 7Fh,0FFh,0F0h	; +0x053
		db	 1Ch,0FFh, 1Fh,0FFh, 80h, 7Ch	; +0x059
		db	0FFh, 03h,0F8h, 01h,0FCh,0FFh	; +0x05F
		db	 30h, 00h, 07h,0FCh,0FFh, 30h	; +0x065
		db	 00h, 1Fh,0FCh,0FFh,0A0h, 7Fh	; +0x06B
		db	0FFh,0F1h, 7Fh,0FFh,0FFh,0FFh	; +0x071
		db	0FCh, 3Fh,0F0h, 83h,0FFh,0F8h	; +0x077
		db	 9Fh,0E1h,0E0h,0FFh,0E0h,0C7h	; +0x07D
		db	0F9h, 03h,0FFh, 84h,0F1h,0FEh	; +0x083
		db	 1Fh,0FEh, 08h,0F4h, 7Fh,0FFh	; +0x089
		db	0F0h, 14h,0FDh, 1Fh,0FFh, 80h	; +0x08F
		db	 28h,0F7h, 03h,0F8h, 01h, 74h	; +0x095
		db	0FDh, 20h, 00h, 02h,0F8h,0F7h	; +0x09B
		db	 20h, 00h, 17h,0FCh, 77h, 00h	; +0x0A1
		db	 77h, 77h, 70h, 5Dh,0DDh,0DDh	; +0x0A7
		db	0DDh,0DCh, 3Fh,0FFh,0FCh, 77h	; +0x0AD
		db	 70h, 1Dh,0D9h,0C3h,0DDh,0C0h	; +0x0B3
		db	 07h, 77h,0FFh, 77h, 00h, 01h	; +0x0B9
		db	0DCh, 1Dh,0DCh, 00h, 80h, 77h	; +0x0BF
		db	 77h, 70h, 04h, 88h, 1Dh,0DDh	; +0x0C5
		db	 80h, 08h,0B2h, 03h, 70h, 00h	; +0x0CB
		db	 74h,0FCh, 00h, 00h, 00h,0D8h	; +0x0D1
		db	0D6h, 00h, 00h, 07h, 74h,0FFh	; +0x0D7
		db	0E0h, 7Fh,0FFh,0F1h, 7Fh,0FFh	; +0x0DD
		db	0FFh,0FFh,0FCh, 3Fh,0FFh,0FFh	; +0x0E3
		db	0FFh,0F8h, 9Fh,0F9h,0EFh,0FFh	; +0x0E9
		db	0E0h,0C7h,0FFh,0FFh,0FFh, 84h	; +0x0EF
		db	0F1h,0FEh, 1Fh,0FEh, 0Ch,0FCh	; +0x0F5
		db	 7Fh,0FFh,0F0h, 1Ch,0FFh, 1Fh	; +0x0FB
		db	0FFh, 80h, 7Ch,0FFh, 03h,0F8h	; +0x101
		db	 01h,0FCh,0FFh, 30h, 00h, 07h	; +0x107
		db	0FCh,0FFh, 30h, 00h, 1Fh,0FCh	; +0x10D
		db	0FFh,0A0h, 7Fh,0FFh,0F1h, 7Fh	; +0x113
		db	0FFh,0FFh,0FFh,0FCh, 3Fh,0FFh	; +0x119
		db	0FFh,0FFh,0F8h, 9Fh,0E1h,0C0h	; +0x11F
		db	0FFh,0E0h,0C7h,0FFh, 87h,0FFh	; +0x125
		db	 84h,0F1h,0FEh, 1Fh,0FEh, 08h	; +0x12B
		db	0F4h, 7Fh,0FFh,0F0h, 14h,0FDh	; +0x131
		db	 1Fh,0FFh, 80h, 28h,0F7h, 03h	; +0x137
		db	0F8h, 01h, 74h,0FDh, 20h, 00h	; +0x13D
		db	 02h,0F8h,0F7h, 20h, 00h, 17h	; +0x143
		db	0FCh, 77h, 00h, 77h, 77h, 70h	; +0x149
		db	 5Dh,0DDh,0DDh,0DDh,0DCh, 37h	; +0x14F
		db	0E0h, 94h, 77h, 70h, 1Dh,0D1h	; +0x155
		db	0E3h,0DDh,0D0h, 07h, 70h, 03h	; +0x15B
		db	 77h, 40h, 05h,0DDh, 0Dh,0DDh	; +0x161
		db	 00h, 81h, 76h, 17h, 74h, 04h	; +0x167
		db	 88h, 5Dh,0DDh,0D0h, 08h,0B2h	; +0x16D
		db	 17h, 77h, 00h, 74h,0FCh, 01h	; +0x173
		db	0D8h, 00h,0D8h,0D6h, 00h, 00h	; +0x179
		db	 07h, 74h,0FFh,0E0h, 7Fh,0FFh	; +0x17F
		db	0F1h, 7Fh,0FFh,0FFh,0FFh,0FCh	; +0x185
		db	 3Fh,0F9h,0F7h,0FFh,0F8h, 9Fh	; +0x18B
		db	0F9h,0E3h,0FFh,0F0h,0CFh,0FEh	; +0x191
		db	 0Fh,0FFh,0C4h,0E7h,0FFh,0FFh	; +0x197
		db	0FFh, 0Ch,0F9h,0FFh, 1Fh,0FCh	; +0x19D
		db	 1Ch,0FEh, 7Fh,0FFh,0F0h, 7Ch	; +0x1A3
		db	0FFh, 1Fh,0FFh, 81h,0FCh,0FFh	; +0x1A9
		db	 23h,0F8h, 07h,0FCh,0FFh, 30h	; +0x1AF
		db	 00h, 1Fh,0FCh,0FFh,0A0h, 7Fh	; +0x1B5
		db	0FFh,0F1h, 7Fh,0FFh,0FFh,0FFh	; +0x1BB
		db	0FCh, 3Fh,0F0h, 83h,0FFh,0F8h	; +0x1C1
		db	 9Fh,0E1h,0E0h,0FFh,0F0h,0CFh	; +0x1C7
		db	0F8h, 01h,0FFh,0C4h,0E7h,0FDh	; +0x1CD
		db	 07h,0FFh, 08h,0F1h,0FFh, 0Fh	; +0x1D3
		db	0FCh, 14h,0FCh, 7Fh,0FFh,0F0h	; +0x1D9
		db	 28h,0F7h, 1Fh,0FFh, 81h, 74h	; +0x1DF
		db	0FDh, 23h,0F8h, 02h,0F8h,0F7h	; +0x1E5
		db	 20h, 00h, 17h,0FCh, 20h, 00h	; +0x1EB
		db	 70h, 00h, 00h, 03h, 02h, 88h	; +0x1F1
		db	 00h, 0Dh,0D8h, 00h, 01h,0C0h	; +0x1F7
		db	 02h, 00h, 07h, 77h, 19h, 81h	; +0x1FD
		db	 40h, 00h, 26h, 05h,0DDh,0FCh	; +0x203
		db	0A9h, 80h, 00h, 75h, 03h, 77h	; +0x209
		db	 7Fh, 77h, 00h, 00h, 3Fh, 03h	; +0x20F
		db	0DDh,0D4h, 5Dh,0C0h, 03h, 6Ah	; +0x215
		db	 03h, 77h,0FFh, 77h, 08h, 01h	; +0x21B
		db	0FDh, 03h,0DFh,0FDh,0C5h, 18h	; +0x221
		db	0F1h, 78h, 78h, 27h,0E0h, 1Fh	; +0x227
		db	 1Fh,0F8h, 03h,0BFh,0FFh, 80h	; +0x22D
		db	 07h,0C0h, 1Eh, 00h,0F7h,0FFh	; +0x233
		db	 11h, 81h,0CCh, 00h, 06h, 7Fh	; +0x239
		db	0FFh,0F0h, 23h, 90h, 27h, 41h	; +0x23F
		db	 7Bh,0FFh,0F8h, 17h, 82h, 23h	; +0x245
		db	0B0h, 73h,0FFh,0F4h, 5Fh,0CEh	; +0x24B
		db	 23h,0EAh,0F3h,0FFh,0FFh,0FFh	; +0x251
		db	 8Eh, 63h,0FFh,0E3h,0FFh,0FFh	; +0x257
		db	0E7h, 1Ch, 71h, 50h, 78h, 22h	; +0x25D
		db	0A0h, 0Bh, 17h,0D8h, 02h,0AFh	; +0x263
		db	0FDh, 00h, 07h,0C0h, 16h, 00h	; +0x269
		db	 57h,0FFh, 11h, 81h,0CCh, 00h	; +0x26F
		db	 06h, 2Fh,0FFh,0F0h, 23h, 90h	; +0x275
		db	 25h, 41h, 53h,0FFh,0F8h, 17h	; +0x27B
		db	 82h, 22h,0B0h, 63h,0FFh,0F4h	; +0x281
		db	 5Fh,0CEh, 23h,0EAh,0D3h,0FFh	; +0x287
		db	0FFh,0FFh, 8Eh, 63h,0FFh,0A3h	; +0x28D
		db	0FFh,0FFh,0E7h, 1Ch, 20h, 00h	; +0x293
		db	 70h, 00h, 00h, 03h, 02h, 88h	; +0x299
		db	 00h, 0Dh,0D8h, 00h, 01h,0C0h	; +0x29F
		db	 02h, 00h, 07h, 77h, 00h, 01h	; +0x2A5
		db	 40h, 00h, 00h, 05h,0DDh,0FCh	; +0x2AB
		db	 29h, 80h, 00h, 61h, 03h, 77h	; +0x2B1
		db	 7Fh, 77h, 00h, 00h, 3Fh, 03h	; +0x2B7
		db	0DDh,0D4h, 5Dh,0C0h, 03h, 6Ah	; +0x2BD
		db	 03h	; +0x2C3
bitmap_row_byte		db	77h
		db	0FFh, 77h, 08h, 01h,0FDh, 03h	; +0x2C5
		db	0DFh,0FDh,0C5h, 18h,0F1h, 78h	; +0x2CB
		db	 78h, 27h,0FFh,0FFh, 1Fh,0F8h	; +0x2D1
		db	 5Bh,0BFh,0FFh,0F4h, 07h,0C0h	; +0x2D7
		db	 1Eh, 26h,0F7h,0FFh, 40h, 01h	; +0x2DD
		db	0CCh, 00h, 00h, 7Fh,0FFh,0F0h	; +0x2E3
		db	 23h, 90h, 27h, 41h, 7Bh,0FFh	; +0x2E9
		db	0F8h, 17h, 82h, 23h,0B0h, 73h	; +0x2EF
		db	0FFh,0F4h, 5Fh,0CEh, 23h,0EAh	; +0x2F5
		db	0F3h,0FFh,0FFh,0FFh, 8Eh, 63h	; +0x2FB
		db	0FFh,0E3h,0FFh,0FFh,0E7h, 1Ch	; +0x301
		db	 71h, 50h, 78h, 22h,0A0h, 0Bh	; +0x307
		db	 17h,0D8h, 02h,0AFh,0FDh, 00h	; +0x30D
		db	 07h,0C0h, 16h, 00h, 57h,0FFh	; +0x313
		db	 00h, 01h,0CCh, 00h, 00h, 2Fh	; +0x319
		db	0FFh,0F0h, 23h, 90h, 25h, 41h	; +0x31F
		db	 53h,0FFh,0F8h, 17h, 82h, 22h	; +0x325
		db	0B0h, 63h,0FFh,0F4h, 5Fh,0CEh	; +0x32B
		db	 23h,0EAh,0D3h,0FFh,0FFh,0FFh	; +0x331
		db	 8Eh, 63h,0FFh,0A3h,0FFh,0FFh	; +0x337
		db	0E7h, 1Ch, 20h, 00h, 70h, 00h	; +0x33D
		db	 00h, 02h, 02h, 88h, 00h, 0Dh	; +0x343
		db	0D8h, 00h, 01h, 40h, 02h, 00h	; +0x349
		db	 07h, 77h, 00h, 01h, 40h, 00h	; +0x34F
		db	 00h, 05h,0DDh, 80h, 01h, 80h	; +0x355
		db	 00h, 00h, 03h, 77h, 40h, 03h	; +0x35B
		db	 00h, 00h, 00h, 03h,0DDh,0D0h	; +0x361
		db	 0Dh,0C0h, 03h, 40h, 03h, 77h	; +0x367
		db	0FFh, 77h, 08h, 01h,0FDh, 03h	; +0x36D
		db	0DFh,0FDh,0C5h, 18h,0F1h, 78h	; +0x373
		db	 78h, 27h,0E7h, 5Fh, 1Fh,0F9h	; +0x379
		db	0EFh,0BFh,0FFh, 3Fh,0F7h,0C0h	; +0x37F
		db	 1Eh,0BFh,0F7h,0FFh,0FFh,0FFh	; +0x385
		db	0CCh, 00h, 7Fh,0FFh,0FFh, 9Fh	; +0x38B
		db	0E1h, 90h, 27h, 3Fh, 7Bh,0FFh	; +0x391
		db	0C0h, 03h, 82h, 23h, 00h, 73h	; +0x397
		db	0FFh,0F0h, 0Fh,0CEh, 23h,0C0h	; +0x39D
		db	0F3h,0FFh,0FFh,0FFh, 8Eh, 63h	; +0x3A3
		db	0FFh,0E3h,0FFh,0FFh,0E7h, 1Ch	; +0x3A9
		db	 71h, 50h, 78h, 22h,0A2h, 0Ah	; +0x3AF
		db	 17h,0D8h,0AAh,0AFh,0FDh, 1Dh	; +0x3B5
		db	 23h, 40h, 16h, 18h, 57h,0FFh	; +0x3BB
		db	0BAh, 41h,0CCh, 00h, 30h, 2Fh	; +0x3C1
		db	0FFh, 94h, 01h, 90h, 25h, 00h	; +0x3C7
		db	 13h,0FFh,0C0h, 03h, 82h, 22h	; +0x3CD
		db	 00h, 63h,0FFh,0F0h, 0Fh,0CEh	; +0x3D3
		db	 23h,0C0h,0D3h,0FFh,0FFh,0FFh	; +0x3D9
		db	 8Eh, 63h,0FFh,0A3h,0FFh,0FFh	; +0x3DF
		db	0E7h, 1Ch,0AAh,0AAh, 5Fh, 55h	; +0x3E5
		db	0B1h,0AAh, 56h, 54h, 0Ah,0A0h	; +0x3EB
		db	 05h, 00h, 80h, 00h, 40h, 00h	; +0x3F1
		db	0FFh,0FFh,0FFh,0FFh,0F9h,0FFh	; +0x3F7
		db	 7Fh,0FEh, 1Fh,0F0h, 8Fh, 83h	; +0x3FD
		db	0C0h, 07h,0C0h, 1Eh,0FFh,0FFh	; +0x403
		db	0E6h,0FFh,0E0h, 7Fh, 79h,0FCh	; +0x409
		db	 1Fh,0F0h, 8Fh, 80h,0C0h, 05h	; +0x40F
		db	0C0h, 0Ah,0AAh,0AAh, 55h,0D5h	; +0x415
		db	0A0h, 2Ah, 56h, 54h, 0Ah,0A0h	; +0x41B
		db	 05h, 00h, 80h, 00h, 40h, 00h	; +0x421
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh	; +0x427
		db	 7Fh,0FEh, 1Fh,0F0h, 8Fh, 83h	; +0x42D
		db	0C0h, 07h,0C0h, 1Eh,0FFh,0FFh	; +0x433
		db	0E4h, 7Fh,0FFh,0FFh, 79h,0FCh	; +0x439
		db	 1Fh,0F0h, 8Fh, 80h,0C0h, 05h	; +0x43F
		db	0C0h, 0Ah,0FEh,0F7h,0F8h, 00h	; +0x445
		db	 04h,0FEh,0FCh	; +0x44B

; =====================================================================
; credits_script - Script interpreted by credits_loop_main. Uses the
; same SCR_* control codes as the narration scripts plus a few extra
; credit-specific codes (F8=set-pause, FC=clear-screen). Tab byte (09h)
; triggers credits_tab_indent. Runs through each credit scene, calling
; the corresponding handler in credit_scene_fn_tbl after each F7h.
; =====================================================================

credits_script:
		db	SCR_BOLD, 01h, 11h	; +0x000
		db	SCR_NORMAL, 00h, 'STAFF'
		db	SCR_COLOR6, SCR_FC, SCR_F8, 20h, 01h	; +0x00A
		db	SCR_COLOR6, SCR_FC, SCR_NORMAL, 07h, SCR_F8, 25h	; +0x00F
		db	 05h, SCR_BREAK	; +0x015
		db	9, 'PRODUCER - JAPANESE VERSION'
		db	0FDh	; +0x033
		db	9, 9, 9, 9, '   Mitsuhiro Mazda'
		db	0F9h,0FCh,0FDh	; +0x04A
		db	9, 'PRODUCER - ENGLISH VERSION'
		db	0FDh	; +0x068
		db	9, 9, 9, 9, '     Josh Mandel'
		db	0F9h,0FCh,0FDh	; +0x07D
		db	9, 'LEAD PROGRAMMER'
		db	0FDh	; +0x090
		db	9, 9, 9, 9, 9, 'Tomoyuki Shimada'
		db	0F9h,0FCh,0FDh	; +0x0A6
		db	9, 'GRAPHIC DESIGNERS'
		db	0FDh	; +0x0BB
		db	9, 9, 9, 9, 9, 'Akihiko Yoshida'
		db	0FDh	; +0x0D0
		db	9, 9, 9, 9, 9, 'Masatoshi Azumi'
		db	0F9h,0FCh,0FDh	; +0x0E5
		db	9, 'ENGLISH TEXT TRANSLATION'
		db	0FDh	; +0x101
		db	9, 9, 9, 9, 9, ' Marti McKenna'
		db	0F9h,0FCh	; +0x115
		db	9, 'MUSIC COMPOSERS'
		db	0FDh	; +0x127
		db	9, 9, 9, 9, '-- MECANO ASSOCIATES'
		db	' --'
		db	0FDh	; +0x143
		db	9, 9, 9, 9, '   Fumihito Kasatani'
		db	0FDh	; +0x15C
		db	9, 9, 9, 9, '   Nobuyuki Aoshima'
		db	0F9h,0FCh,0FDh	; +0x174
		db	9, 'STORY MAKER'
		db	0FDh	; +0x183
		db	9, 9, 9, 9, 9, 'Masaru Takeuchi'
		db	0F9h,0FCh,0FDh	; +0x198
		db	9, 'SOUND EFFECTS'
		db	0FDh	; +0x1A9
		db	9, 9, 9, 9, 9, 'Tomoyuki Shimada'
		db	0F9h,0F8h, 00h, 03h,0FCh,0FEh	; +0x1BF
		db	0F7h,0FEh,0FBh, 01h, 0Dh,0FAh	; +0x1C5
		db	 00h	; +0x1CB
		db	'SPECIAL THANKS'
		db	0F9h,0FCh,0F8h, 20h, 01h,0F9h	; +0x1DA
		db	0FCh,0FAh, 07h,0F8h, 00h, 07h	; +0x1E0
		db	0FDh	; +0x1E6
		db	9, 'Toshiyuki Uchida', 9, 'Yuzo S'
		db	'unaga'
		db	0FDh	; +0x204
		db	9, 'Takeshi Miyaji', 9, 9, 'Naozu'
		db	'mi Honma'
		db	0FDh	; +0x223
		db	9, 'Ray E'
		db	'. Nakazato', 9, 9, 'Toshi Masubu'
		db	'chi'
		db	0F9h,0FCh,0FDh	; +0x245
		db	9, 'Hiroyuki Koyama', 9, 9, 'Sato'
		db	'shi Uesaka'
		db	0FDh	; +0x268
		db	'   '
		db	'  -- Si'
		db	'erra On-Line Japan, Inc. --'
		db	0FDh	; +0x28E
		db	9, 9, 9, ' Eiji (Ed) Nagano'
		db	0F9h,0FCh	; +0x2A3
		db	9, 'ADVISERS'
		db	0FDh	; +0x2AE
		db	9, 9, 9, 9, 9, '  Osamu Harada'
		db	0FDh	; +0x2C2
		db	9, 9, 9, 9, 9, '  Hiromi Ohba'
		db	0FDh	; +0x2D5
		db	9, 9, 9, 9, 9, '  Greg Miyaji'
		db	0F9h,0FCh,0F8h, 80h, 05h,0FDh	; +0x2E8
		db	9, 'SYSTEM DESIGNER'
		db	0FDh	; +0x2FE
		db	9, 9, 9, 9, 9, 'Rocky Cave Maker'
		db	0F9h,0F8h, 20h, 01h,0FCh,0F9h	; +0x314
		db	0F8h, 00h, 03h,0FCh,0FBh, 01h	; +0x31A
		db	 0Ch,0FAh, 00h	; +0x320
		db	'SERVING MONSTERS'
		db	0F9h,0FCh,0F8h, 20h, 01h,0F9h	; +0x333
		db	0FCh,0FAh, 07h,0F8h, 40h, 01h	; +0x339
		db	9, 'Cavern of Maricia', 9, 9, 'CA'
		db	'NGREJO'
		db	0F9h,0FDh	; +0x35B
		db	9, 9, 'Peligro', 9, 9, 9, 9, 'PUL'
		db	'PO'
		db	0F9h,0FDh	; +0x36F
		db	9, 9, 'Riza', 9, 9, 9, 9, 'POLLO'
		db	0F9h,0F9h,0FCh	; +0x380
		db	9, 'Cavern of Glacial', 9, 9, 'AG'
		db	'ER'
		db	0F9h,0FDh	; +0x39B
		db	9, 9, 'Cementar', 9, 9, 9, 'VISTA'
		db	0F9h,0FDh	; +0x3AF
		db	9, 9, 'Tesoro', 9, 9, 9, 9, 'TARS'
		db	'O'
		db	0F9h,0F9h,0FCh	; +0x3C2
		db	9, 9, 'Llama Town', 9, 9, 9, 'PAG'
		db	'URO'
		db	0F9h,0FDh	; +0x3DA
		db	9, 'Cavern of Caliente', 9, 9, 'D'
		db	'RAGON'
		db	0F9h,0FDh	; +0x3F7
		db	9, 9, 'Absor', 9, 9, 9, 9, 'ALGUI'
		db	'EN'
		db	0F9h,0F9h,0FCh,0FAh, 00h,0FEh	; +0x40B
		db	9, 'Copyright (C)1987,19'
		db	'90 GAME ARTS'
		db	0FDh	; +0x432
		db	9, 'Copyright ('
		db	'C)1990 Sierra On-Line'
		db	0FDh	; +0x454
		db	'  This edition first publ'
		db	'ished 1987 by'
		db	0FDh	; +0x47B
		db	'  GAME ARTS Co.,Ltd./ Tomoyuki S'
		db	'himada'
		db	SCR_SCROLL, SCR_DIRECT, SCR_SCROLL, SCR_END_SCRIPT	; +0x4A2

; =====================================================================
; credits_glyph_index_tbl - ASCII-to-glyph index lookup used by the
; credits renderer. Sparse: positions for unrepresented chars are 0.
; Mapped characters follow roughly the visible ASCII range used by
; the STAFF/SERVING MONSTERS credits pages.
; =====================================================================

credits_glyph_index_tbl:
		db	 00h, 00h	; +0x000
		db	 00h, 00h, 00h, 00h, 01h, 02h	; +0x002
		db	 03h, 04h, 00h, 00h, 00h, 00h	; +0x008
		db	 00h, 00h, 05h, 06h, 07h, 08h	; +0x00E
		db	 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh	; +0x014
		db	 0Fh, 10h, 11h, 12h, 13h, 14h	; +0x01A
		db	 15h, 16h, 00h, 00h, 00h, 17h	; +0x020
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh	; +0x026
		db	 1Eh, 1Fh	; +0x02C
		db	' !"#$'
		db	'%&', 27h, '()*+,-.'
		db	 00h, 00h, 2Fh, 30h, 31h, 32h	; +0x03D
		db	 33h, 00h, 00h, 34h, 35h, 36h	; +0x043
		db	 37h, 38h, 00h, 39h, 26h, 3Ah	; +0x049
		db	 00h	; +0x04F
		db	18 dup (0)
		db	 3Bh, 3Ch, 3Dh, 00h, 00h, 00h	; +0x062
		db	 3Eh, 3Fh, 40h, 41h	; +0x068
		db	30 dup (0)
		db	 42h, 43h, 44h, 45h	; +0x08A
		db	30 dup (0)
		db	 46h, 47h, 16h	; +0x0AC
		db	31 dup (0)
		db	 48h, 49h, 4Ah	; +0x0CE
		db	97 dup (0)
		db	 4Bh, 4Ch, 4Dh	; +0x132
		db	31 dup (0)
		db	 4Eh, 4Fh, 50h	; +0x154
		db	32 dup (0)
		db	51h	; +0x177
		db	33 dup (0)
		db	 52h, 53h	; +0x199
		db	32 dup (0)
		db	 54h, 55h, 56h	; +0x1BB
		db	31 dup (0)
		db	 57h, 58h, 59h, 5Ah	; +0x1DD
		db	30 dup (0)
		db	 5Bh, 5Ch, 5Dh, 5Eh	; +0x1FF
		db	30 dup (0)
		db	 5Fh, 60h, 61h, 62h	; +0x221
		db	30 dup (0)
		db	 63h, 64h	; +0x243
		db	32 dup (0)
		db	 65h, 66h, 67h, 68h, 69h	; +0x265
		db	29 dup (0)
		db	'jklmnopqrs'
		db	24 dup (0)
		db	'tuvwxyz{|}'
		db	24 dup (0)
		db	 7Eh, 7Fh, 80h, 81h, 82h, 83h	; +0x2CB
full_scroll_fn_ptr		dw	8584h
		db	 86h, 87h, 88h, 89h, 00h, 00h	; +0x2D3
		db	 00h, 00h, 0Fh, 8Ah, 8Bh, 8Ch	; +0x2D9
		db	 00h	; +0x2DF
		db	13 dup (0)
		db	 2Fh, 8Dh, 8Eh, 8Fh, 90h, 91h	; +0x2ED
		db	 92h, 93h, 94h, 95h, 96h, 97h	; +0x2F3
		db	 00h, 00h, 00h, 98h, 99h, 9Ah	; +0x2F9
		db	 9Bh, 9Ch, 9Dh	; +0x2FF
		db	14 dup (0)
		db	 9Eh, 9Fh,0A0h,0A1h,0A2h,0A3h	; +0x310
		db	0A4h,0A5h,0A6h,0A7h,0A8h,0A9h	; +0x316
		db	 16h, 00h,0AAh,0ABh,0ACh,0ADh	; +0x31C
		db	0AEh,0AFh	; +0x322
		db	14 dup (0)
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h	; +0x332
		db	0B6h,0B7h,0B8h, 26h, 26h,0B9h	; +0x338
		db	0BAh,0BBh,0BCh,0BDh,0BEh,0BFh	; +0x33E
		db	0C0h,0C1h	; +0x344
		db	13 dup (0)

; =====================================================================
; credits_glyph_width_tbl - Width delta table per glyph index; consumed
; by credits_putchar to advance the credits-column cursor.
; =====================================================================

credits_glyph_width_tbl:
		db	2, 2, 3, 1, 0, 0	; +0x000
		db	2, 2, 3, 1, 1, 1	; +0x006
		db	2, 2, 0, 1, 2, 1	; +0x00C
		db	7 dup (1)
		db	3, 2, 1, 1, 2, 1	; +0x019
		db	9 dup (0)
		db	2, 0	; +0x028
		db	9 dup (0)
		db	1, 0, 0, 0, 0, 0	; +0x033
		db	1, 2, 2, 2, 1, 1	; +0x039
		db	1, 0, 0, 1, 0, 1	; +0x03F
		db	1, 0, 0, 2, 1, 0	; +0x045
		db	2, 0, 1, 1, 0, 0	; +0x04B
		db	0, 1, 1, 0, 0, 0	; +0x051
		db	1, 1, 1, 2, 0, 3	; +0x057
		db	1, 0, 5, 4, 4, 4	; +0x05D
		db	6, 8, 5, 3, 4, 4	; +0x063
		db	6, 6, 6, 5, 6, 8	; +0x069
		db	7, 5, 7, 7, 7, 7	; +0x06F
		db	7, 7, 7, 7, 3, 4	; +0x075
		db	6, 6, 6, 7	; +0x07B
		db	9 dup (8)
		db	5, 8, 8	; +0x088
		db	8 dup (8)
		db	7, 8, 8, 8, 8, 8	; +0x093
		db	7, 5, 3, 5, 6, 7	; +0x099
		db	7, 8, 8, 7, 8, 7	; +0x09F
		db	7, 8, 8, 5, 6, 8	; +0x0A5
		db	5, 8, 7, 7, 8, 8	; +0x0AB
		db	8, 7, 6, 8, 8, 8	; +0x0B1
		db	7, 7, 7, 4, 8, 4	; +0x0B7
		db	7, 8, 0	; +0x0BD

; =====================================================================
; credits_chunk_refs - Chunk reference table for credit-scene graphics.
; Each entry is [archive_index, chunk_index, 'filename.grp', 0]. These
; are the per-scene graphics loaded into VGA/aux buffers before the
; credit_scene_N_impl handler runs for each credit page.
; Loaded from offset 819Fh..81DBh range via cs:[10Ch] (chunk loader).
; =====================================================================

credits_chunk_refs:
; Each record: [chunk_high, 'filename', 00h, 00h]; filename is the
; zelres2 chunk name. Loaded via cs:[10Ch] chunk loader at runtime
; with SI = CS-relative offset of the record.
ref_waku_grp	db	'!waku.grp'			; waku.grp (corridor frame)
		db	 00h, 00h	; +0x009
ref_sei_grp	db	 1Ch, 'sei.grp'			; sei.grp
		db	 00h, 00h	; +0x013
ref_yuup_grp	db	'&yuup.grp'			; yuup.grp (hero portrait)
		db	 00h, 00h, 1Dh	; +0x01E
		db	'seip.grp'
		db	 00h, 00h, 11h	; +0x029
		db	'himp.grp'
		db	 00h, 00h, 18h	; +0x034
		db	'new1.grp'
		db	 00h, 00h, 19h	; +0x03F
		db	'new2.grp'
		db	 00h, 00h, 15h	; +0x04A
		db	'ne80.grp'
		db	 00h, 00h, 16h	; +0x055
		db	'ne81.grp'
		db	0, 1	; +0x060
		db	'6end5.grp'
		db	0, 1	; +0x06B
		db	'5end4.grp'
		db	0, 1	; +0x076
		db	'7end6.grp'
		db	0, 1	; +0x081
		db	'8end7.grp'
		db	0, 1	; +0x08C
		db	'4en72.grp'
		db	0, 1	; +0x097
		db	'9fin.grp'
		db	0, 0	; +0x0A1
		db	27h, 'zend.msd'
		db	0	; +0x0AC

seg_a		ends

		end	start
