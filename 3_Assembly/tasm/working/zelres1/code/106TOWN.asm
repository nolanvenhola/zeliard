
PAGE  59,132

;==========================================================================
;
;  PLAYER_ADVANCED - 106TOWN Town/Overworld Engine (zelres1 chunk 7, town.bin)
;
;  Drives the town/overworld game state: tile-based map walking, NPC
;  interaction, dialog boxes, save-file management, item menus, magic
;  selection, and chapter transitions. Loaded by game.bin at game_seg:0x6000
;  (LOAD_CHUNK chunk_ref_town). Calls back into the active gfx-mode tile
;  renderer (107-111 GT*.bin) for drawing.
;
;  Connections:
;    Loads:        SAR chunks via sar_loader_fn (cs:[10Ch]) for additional
;                  resources (font.grp ch13, magic.grp/sword.grp/itemp.grp
;                  pre-loaded by game.bin); various map/data chunks loaded
;                  on town entry
;    Calls into:   sar_loader_fn (cs:[10Ch] in stick.bin),
;                  gfx_fill/clear/draw/render_*/scroll_*/sel_*/copy/blit_fn
;                  (CS:0x2000-0x3026 dispatch slots in gd*/gt* drivers),
;                  player_jump_fn (CS:0xA004), town_npc_fn_ptr (CS:0x7C47),
;                  music_fn_ptr (CS:0x6AE9), game_exit_fn (CS:0x7686)
;    Called by:    game.bin LOAD_CHUNK chunk_ref_town (loaded_code_b at
;                  game_seg:0x6000 entry)
;    Reads/writes: gvar_fn_tbl (FF00), gvar_joy_state (FF18),
;                  gvar_frame_timer (FF1A), gvar_spacebar_state (FF1D),
;                  gvar_enable_all (FF26), gvar_enter_key (FF29),
;                  gvar_tile_ptr (FF2A), gvar_game_seg (FF2C),
;                  gvar_anim_frames (FF33), gvar_dialog_ptr (FF4C),
;                  gvar_save_name (FF6C), gvar_volume (FF75),
;                  gvar_load_flag (FF78) - zeliad-owned shared state
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr1com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in shared inc
; ----------------------------------------------------------------------
gvar_fn_tbl	equ	0FF00h			;*
gvar_joy_state	equ	0FF18h			;*
gvar_frame_timer	equ	0FF1Ah			;*
gvar_spacebar_state	equ	0FF1Dh			;*
gvar_skip_flag2	equ	0FF1Eh			;*
gvar_enable_all	equ	0FF26h			;*
gvar_enter_key	equ	0FF29h			;* ENTER-key ASCII buffer (canonical zeliard.inc;
						;  was misnamed gvar_enter_key — FF0B is the real gvar_enter_key)
gvar_tile_ptr	equ	0FF2Ah			;*
gvar_game_seg	equ	0FF2Ch			;*
gvar_anim_frames	equ	0FF33h			;*
gvar_dialog_ptr	equ	0FF4Ch			;*
gvar_text_x	equ	0FF4Eh			;*
gvar_text_y	equ	0FF4Fh			;*
gvar_dlg_cols	equ	0FF52h			;*
gvar_dlg_rows	equ	0FF53h			;*
gvar_dlg_pos	equ	0FF54h			;*
gvar_sel_row	equ	0FF56h			;*
gvar_sel_flag	equ	0FF57h			;*
gvar_sel_xlat	equ	0FF58h			;*
gvar_dlg_timer	equ	0FF6Ah			;*
gvar_save_name	equ	0FF6Ch			;*
gvar_input_lock	equ	0FF74h			;* input-mode lock (canonical zeliard.inc); set during save-name dialog
gvar_volume	equ	0FF75h			;*
gvar_load_flag	equ	0FF78h			;*
gvar_music_idx	equ	0FF14h			;*
gvar_input_timer	equ	0FF17h			;*

; ----------------------------------------------------------------------
; Section 4: Shared dispatch slot references (file-local)
; ----------------------------------------------------------------------
save_draw_fn	equ	6014h			;*
save_scroll_up_fn	equ	6018h			;*
save_scroll_dn_fn	equ	601Ah			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
town_base_4100		equ	4100h			;*
npc_list_ptr		equ	8002h			;*
town_desc_0C000		equ	0C000h			;*
gfx_fill_fn	equ	2000h			;*
gfx_clear_fn	equ	2002h			;*
gfx_draw_tile_fn	equ	2004h			;*
gfx_render_a_fn	equ	2006h			;*
gfx_render_b_fn	equ	2008h			;*
gfx_load_img_fn	equ	200Eh			;*
gfx_draw_map_fn	equ	2010h			;*
gfx_draw_player_fn	equ	2012h			;*
gfx_render_c_fn	equ	2014h			;*
gfx_render_d_fn	equ	2016h			;*
gfx_draw_icon_a_fn	equ	2018h			;*
gfx_draw_icon_b_fn	equ	201Ah			;*
gfx_draw_char_fn	equ	2022h			;*
gfx_scroll_row_fn	equ	2024h			;*
gfx_text_layout_a_fn	equ	2026h			;*
gfx_text_layout_b_fn	equ	2028h			;*
gfx_draw_str_fn	equ	202Ah			;*
gfx_clear_row_fn	equ	2038h			;*
gfx_blit_fn	equ	2040h			;*
gfx_refresh_fn	equ	2042h			;*
ui_str_tbl	equ	278Bh			;*
gfx_draw_fn	equ	3002h			;*
gfx_update_fn	equ	3004h			;*
gfx_scroll_left_fn	equ	3006h			;*
gfx_scroll_right_fn	equ	3008h			;*
gfx_scroll_right2_fn	equ	300Ah			;*
gfx_scroll_left2_fn	equ	300Ch			;*
gfx_npc_draw_fn	equ	300Eh			;*
gfx_npc_update_fn	equ	3010h			;*
gfx_fn_3012	equ	3012h			;*
gfx_fn_3014	equ	3014h			;*
gfx_cursor_fn	equ	3018h			;*
gfx_sel_init_fn	equ	301Ah			;*
gfx_sel_draw_fn	equ	301Ch			;*
gfx_sel_scroll_up_fn	equ	301Eh			;*
gfx_sel_scroll_dn_fn	equ	3020h			;*
gfx_ret_fn	equ	3024h			;*
gfx_copy_fn	equ	3026h			;*
snd_id_4D4D	equ	4D4Dh			;*
snd_id_534D	equ	534Dh			;*
npc_walk_left	equ	6A59h			;*
gseg_chunk_ptr	equ	6AEBh			;*
icon_data_a	equ	6C93h			;*
icon_data_b	equ	6C9Bh			;*
icon_data_c	equ	6CA4h			;*
icon_data_d	equ	6CACh			;*
sar_chunk_tbl	equ	6D88h			;*
scene_map_data	equ	6FEDh			;*
save_default_name	equ	77BAh			;*
char_width_tbl	equ	7B82h			;*
char_glyph_tbl	equ	7BE2h			;*
town_map_side	equ	7C45h			;*
town_npc_fn_ptr	equ	7C47h			;*
town_npc_col	equ	7C49h			;*
text_draw_x	equ	7C4Eh			;*
text_draw_x2	equ	7C50h			;*
text_line_ctr	equ	7C52h			;*
text_box_cols	equ	7C54h			;*
text_str_ptr	equ	7C58h			;*
text_layout_cx	equ	7C5Ah			;*
save_name_len	equ	7C5Eh			;*
save_name_maxlen	equ	7C5Fh			;*
save_cursor_x	equ	7C60h			;*
save_cursor_y	equ	7C62h			;*
save_name_buf	equ	7C67h			;*
save_name_end	equ	7C6Eh			;*
npc_anim_buf	equ	7C74h			;*
npc_col_buf	equ	7C7Ah			;*
vga_seg_A000	equ	0A000h			;*
player_draw_fn	equ	0A002h			;*
player_jump_fn	equ	0A004h			;*
town_walk_hdr	equ	0C000h			;*
town_map_width	equ	0C002h			;*
town_tile_ptr	equ	0C004h			;*
town_exit_ptr	equ	0C007h			;*
town_event_tbl	equ	0C009h			;*
town_item_tbl	equ	0C00Dh			;*
npc_obj_list	equ	0C00Fh			;*
town_map_xlim	equ	0C011h			;*
town_key_event	equ	0C015h			;*
tile_collision_map	equ	0C01Ch			;*
cursor_buf	equ	0E000h			;*
cursor_buf_cnt	equ	0E001h			;*
cursor_buf_end	equ	0E1FDh			;*
cursor_buf_tail	equ	0E1FFh			;*
font_disp_data	equ	0F605h			;*
music_fn_ptr	equ	6AE9h			;*
game_exit_fn	equ	7686h			;*

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
screen_pos_481C	equ	481Ch			;*
town_scene_flag	equ	7C42h			;*
town_init_flag	equ	7C43h			;*
town_load_flag	equ	7C44h			;*
town_palette_idx	equ	7C46h			;*
town_exit_flag	equ	7C4Bh			;*
town_char_idx	equ	7C4Ch			;*
text_col_pos	equ	7C53h			;*
text_box_flag	equ	7C55h			;*
text_anim_step	equ	7C56h			;*
text_row_flag	equ	7C57h			;*
text_done_flag	equ	7C5Ch			;*
text_wrap_flag	equ	7C5Dh			;*
save_del_flag	equ	7C63h			;*
save_new_flag	equ	7C64h			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
area_load_flag	equ	49h			;*
player_col	equ	83h			;*
player_facing	equ	0C2h			;*

;-----------------------------------------------------------------------------
; Local macros
;
; fill_cursor_buf: fill the cursor overlay buffer (0xE000, 224 bytes) with 0xFE
; Appears 4 times in the rendering/dialog code to reset the cursor overlay.
fill_cursor_buf	macro
		push	cs
		pop	es
		mov	al,0FEh
		mov	di,cursor_buf
		mov	cx,0E0h
		rep	stosb
		endm
; SET_ES_2000
;   Compute ES = CS + 2000h (load ES with the secondary code/data segment).
SET_ES_2000	MACRO
		mov	ax, cs
		add	ax, 2000h
		mov	es, ax
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

townb_main	proc	far

start:
		; Hardware capability probe header (CPU/hardware detection)
		; jge jumps to init_entry when running normally; fall-through bytes are a probe sequence
		jge	init_entry			; Jump if > or =  (normal execution path)
		add	[bx+si],al			; probe: test word write
		db	 26h, 60h			; ES: prefix + PUSHA (80286 opcode probe)
data_5		db	1Eh				; PUSH DS (hardware probe byte)
		db	 60h, 6Ch, 70h,0C7h, 72h,0D3h	; probe continuation bytes
		db	 74h, 70h, 75h, 89h, 75h, 1Ah	; probe continuation bytes
		db	'uDs9uitBp{t'			; probe data / version key bytes

init_entry:
		cmpsw				; Cmp [si] to es:[di]
		jz	$-6Ch			; Jump if zero
		jnz	main_loop			; Jump if not zero
		mov	byte ptr ds:town_init_flag,0FFh
		jmp	short init_load_tiles
			                        ;* No entry point to code  (dead path: clear init_flag via cs: override)
		mov	byte ptr cs:town_init_flag,0

init_load_tiles:
		mov	ds,cs:gvar_game_seg
		mov	si,4100h
		SET_ES_2000
		mov	di,7000h
		mov	cx,0A4h
		call	word ptr cs:gfx_copy_fn
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds

main_loop:
		call	player_func_33
		mov	byte ptr ds:gvar_pose_idx,0
		test	byte ptr ds:[49h],0FFh
		jz	main_clear_flag			; Jump if zero
		mov	byte ptr ds:init_complete_flag,0

main_clear_flag:
		call	word ptr cs:gfx_clear_fn
		mov	si,ds:town_walk_hdr
		inc	si

walk_skip_loop:
								lodsb				; String [si] to al
								inc	al
								jnz	walk_skip_loop			; Jump if not zero
		lodsb				; String [si] to al
		mov	ds:town_map_side,al
		lodsb				; String [si] to al
		mov	ds:town_palette_idx,al
		mov	byte ptr ds:town_load_flag,0
		test	byte ptr ds:init_complete_flag,0FFh
		jnz	frame_update			; Jump if not zero
		test	byte ptr ds:town_map_side,1
		jz	check_load_chunk			; Jump if zero
		test	byte ptr ds:town_init_flag,0FFh
		jnz	check_load_chunk			; Jump if not zero
		mov	byte ptr ds:town_load_flag,0FFh

check_load_chunk:
		call	player_load_chunk
		call	player_func_22
		call	word ptr cs:gfx_draw_fn
		test	byte ptr ds:[49h],0FFh
		jnz	frame_update			; Jump if not zero
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds

frame_update:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
		call	player_func_25
		xor	al,al			; Zero register
		mov	ds:gvar_spacebar_state,al
		mov	ds:gvar_skip_flag2,al
		mov	byte ptr ds:[0E4h],al
		mov	byte ptr ds:[9Fh],al
		mov	bx,204h
		xor	al,al			; Zero register
		mov	ch,21h			; '!'
		call	word ptr cs:gfx_draw_tile_fn
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:gfx_draw_tile_fn
		mov	bx,screen_pos_481C
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:gfx_draw_tile_fn
		call	word ptr cs:gfx_draw_player_fn
		call	player_func_29
		call	word ptr cs:gfx_render_a_fn
		call	word ptr cs:gfx_render_b_fn
		call	word ptr cs:gfx_render_c_fn
		call	word ptr cs:gfx_render_d_fn
		test	byte ptr ds:[9Dh],0FFh
		jz	draw_icon_a			; Jump if zero
		mov	bx,0AA1Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:gfx_draw_tile_fn
		call	word ptr cs:gfx_draw_icon_a_fn

draw_icon_a:
		test	byte ptr ds:[93h],0FFh
		jz	draw_icon_b			; Jump if zero
		mov	bx,0C61Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:gfx_draw_tile_fn
		call	word ptr cs:gfx_draw_icon_b_fn

draw_icon_b:
		mov	si,ds:town_walk_hdr
		inc	si

walk_skip_loop2:
								lodsb				; String [si] to al
								inc	al
								jnz	walk_skip_loop2			; Jump if not zero
		inc	si
		lodsb				; String [si] to al
		mov	ds:town_palette_idx,al
		mov	si,ds:town_tile_ptr
		call	word ptr cs:gfx_draw_map_fn
		mov	al,byte ptr ds:[80h]
		xor	ah,ah			; Zero register
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ax,0C017h
		mov	ds:gvar_tile_ptr,ax
		call	player_func_27
		test	byte ptr ds:init_complete_flag,0FFh
		jz	portal_check			; Jump if zero
		mov	byte ptr ds:init_complete_flag,0
		call	player_load_chunk
		mov	bx,61FCh
		push	bx
		mov	bx,6EAFh
		push	bx
		mov	si,6F23h
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:gfx_blit_fn
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:town_scene_flag,0FFh
		jmp	word ptr cs:player_jump_fn

portal_check:
		fill_cursor_buf
		call	player_multiply_2
		test	byte ptr ds:town_load_flag,0FFh
		jz	npc_col_clear			; Jump if zero
		mov	word ptr ds:town_npc_fn_ptr,6781h
		test	byte ptr ds:player_facing,1
		jnz	npc_fn_adjust			; Jump if not zero
		mov	word ptr ds:town_npc_fn_ptr,67F4h

npc_fn_adjust:
		mov	cx,4

npc_update_loop:
								push	cx
								call	word ptr cs:town_npc_fn_ptr
								call	player_multiply_2
								pop	cx
								loop	npc_update_loop		; Loop if cx > 0

		call	word ptr cs:town_npc_fn_ptr

npc_col_clear:
		mov	byte ptr ds:town_exit_flag,0
		test	byte ptr ds:area_load_flag,0FFh
		jz	scroll_check			; Jump if zero
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds

scroll_check:
		call	player_multiply_2
		call	fill_buffer
		call	player_func_30
		call	player_func_1
		test	byte ptr ds:town_exit_flag,0FFh
		jnz	exit_flag_skip			; Jump if not zero
		call	player_func_2

exit_flag_skip:
		mov	byte ptr ds:town_exit_flag,0
		mov	dx,61FCh
		push	dx
		int	61h			; ??INT Non-standard interrupt
		cmp	al,1
		jne	dispatch_exit			; Jump if not equal
		jmp	door_scan_entry

dispatch_exit:
		and	al,0Ch
		cmp	al,4
		jne	dispatch_left			; Jump if not equal
		jmp	walk_left_entry

dispatch_left:
		cmp	al,8
		jne	dispatch_right			; Jump if not equal
		jmp	walk_right_entry

dispatch_right:
		or	byte ptr ds:gvar_pose_idx,1
		mov	byte ptr ds:town_exit_flag,0FFh
		retn

townb_main	endp

player_func_1		proc	near
		test	byte ptr ds:gvar_spacebar_state,0FFh
		jnz	pf1_do			; Jump if not zero
		retn

pf1_do:
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	bl,byte ptr ds:town_player_col
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:gvar_tile_ptr
		test	byte ptr ds:[0C2h],1
		jnz	pf1_left_check			; Jump if not zero
		inc	dx
		cmp	byte ptr [bx+8],0FDh
		je	pf1_found_tile			; Jump if equal
		inc	dx
		cmp	byte ptr [bx+10h],0FDh
		je	pf1_found_tile			; Jump if equal
		inc	dx
		cmp	byte ptr [bx+18h],0FDh
		je	pf1_found_tile			; Jump if equal
		retn

pf1_found_tile:
		call	player_func_20
		mov	al,[si+6]
		and	al,0C0h
		jz	pf1_enter_right			; Jump if zero
		retn

pf1_enter_right:
		mov	al,[si+2]
		mov	ah,[si+5]
		push	ax
		mov	byte ptr [si+5],7
		or	byte ptr [si+2],80h
		or	byte ptr [si+4],1
		call	player_func_3
		pop	ax
		mov	[si+5],ah
		mov	[si+2],al
		retn

pf1_left_check:
		dec	dx
		cmp	byte ptr [bx-8],0FDh
		je	pf1_found_tile_l			; Jump if equal
		dec	dx
		cmp	byte ptr [bx-10h],0FDh
		je	pf1_found_tile_l			; Jump if equal
		dec	dx
		cmp	byte ptr [bx-18h],0FDh
		je	pf1_found_tile_l			; Jump if equal
		retn

pf1_found_tile_l:
		call	player_func_20
		mov	al,[si+6]
		and	al,0C0h
		jz	pf1_enter_left			; Jump if zero
		retn

pf1_enter_left:
		mov	al,[si+2]
		mov	ah,[si+5]
		push	ax
		mov	byte ptr [si+5],7
		and	byte ptr [si+2],7Fh
		or	byte ptr [si+4],1
		call	player_func_3
		pop	ax
		mov	[si+5],ah
		mov	[si+2],al
		retn

player_func_1		endp

player_func_2		proc	near
		mov	bl,byte ptr ds:town_player_col
		add	bl,4
		xor	bh,bh			; Zero register
		mov	dx,bx
		add	dx,word ptr ds:[80h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,5
		add	bx,ds:gvar_tile_ptr
		test	byte ptr ds:[0C2h],1
		jnz	pf2_left_path			; Jump if not zero
		inc	dx
		inc	dx
		cmp	byte ptr [bx+10h],0FDh
		je	pf2_found_center			; Jump if equal
		retn

pf2_found_center:
		call	player_func_20
		test	byte ptr [si+2],80h
		jnz	pf2_facing_right			; Jump if not zero
		retn

pf2_facing_right:
		test	byte ptr [si+6],80h
		jnz	pf2_set_done_r			; Jump if not zero
		retn

pf2_set_done_r:
		or	byte ptr [si+4],1
		mov	byte ptr ds:text_done_flag,0FFh
		jmp	short text_start

pf2_left_path:
		dec	dx
		dec	dx
		cmp	byte ptr [bx-10h],0FDh
		je	pf2_found_center_l			; Jump if equal
		retn

pf2_found_center_l:
		call	player_func_20
		test	byte ptr [si+2],80h
		jz	pf2_facing_left			; Jump if zero
		retn

pf2_facing_left:
		test	byte ptr [si+6],80h
		jnz	pf2_set_done_l			; Jump if not zero
		retn

pf2_set_done_l:
		or	byte ptr [si+4],1
		mov	byte ptr ds:text_done_flag,0FFh
		jmp	short text_start

player_func_2		endp

player_func_3		proc	near

text_start:
		and	byte ptr [si+6],7Fh
		mov	al,[si+7]
		push	si
		push	ax
		mov	byte ptr ds:gvar_frame_timer,28h	; '('
		call	player_func_14
		mov	byte ptr ds:gvar_volume,1Eh
		mov	ax,718h
		test	byte ptr ds:[0C2h],1
		jnz	text_pos_right			; Jump if not zero
		mov	ax,0B18h

text_pos_right:
		mov	ds:town_char_idx,ax
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:gfx_text_layout_a_fn
		mov	byte ptr ds:gvar_spacebar_state,0
		pop	bx
		mov	ax,ds:town_char_idx
		call	player_multiply
		mov	ax,ds:town_char_idx
		xor	di,di			; Zero register
		mov	cx,1658h
		call	word ptr cs:gfx_text_layout_b_fn
		pop	si
		mov	byte ptr ds:gvar_spacebar_state,0
		fill_cursor_buf
		mov	byte ptr ds:text_done_flag,0
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		retn

player_func_3		endp

player_multiply		proc	near

render_set_dirty:
		or	byte ptr ds:gvar_pose_idx,1
player_multiply		endp

player_func_5		proc	near
		mov	ds:text_draw_x2,ax
		mov	ds:text_draw_x,ax
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,ds:town_item_tbl
		mov	si,[bx]
		mov	byte ptr ds:text_col_pos,0
		mov	byte ptr ds:text_box_cols,0
		mov	byte ptr ds:text_box_flag,0
		mov	byte ptr ds:text_row_flag,0
		mov	ds:text_str_ptr,si
		call	player_func_8
		mov	al,cl
		mov	ds:text_anim_step,al
		cmp	al,8
		jb	render_clamp_8			; Jump if below
		mov	al,8

render_clamp_8:
		push	ax
		mov	cl,0Ah
		mul	cl			; ax = reg * al
		add	al,6
		mov	cl,al
		mov	ch,2Ch			; ','
		mov	ds:text_layout_cx,cx
		mov	al,56h			; 'V'
		sub	al,cl
		mov	bx,ds:text_draw_x
		add	bl,al
		pop	ax
		and	al,0FEh
		add	al,al
		add	al,al
		add	al,al
		mov	ah,40h			; '@'
		sub	ah,al
		shr	ah,1			; Shift w/zeros fill
		sub	bl,ah
		mov	ds:text_draw_x,bx
		add	bh,bh
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn

render_char_loop:
		mov	si,ds:text_str_ptr
		lodsb				; String [si] to al
		mov	ds:text_str_ptr,si
		cmp	al,2Fh			; '/'
		jne	render_not_slash			; Jump if not equal
		jmp	render_newline

render_not_slash:
		cmp	al,81h
		jne	render_not_81			; Jump if not equal
		jmp	ctrl_81_header

render_not_81:
		cmp	al,83h
		jne	render_not_83			; Jump if not equal
		jmp	ctrl_83_portrait

render_not_83:
		cmp	al,85h
		jne	render_not_85			; Jump if not equal
		jmp	ctrl_85_set_done

render_not_85:
		cmp	al,87h
		jne	render_not_87			; Jump if not equal
		jmp	ctrl_87_call_func6

render_not_87:
		cmp	al,89h
		jne	render_not_89			; Jump if not equal
		jmp	ctrl_89_dialog

render_not_89:
		cmp	al,8Bh
		jne	render_not_8B			; Jump if not equal
		jmp	ctrl_set_bit4

render_not_8B:
		cmp	al,0FFh
		jne	render_not_FF			; Jump if not equal
		jmp	text_end_seq

render_not_FF:
		push	ax
		mov	cx,ds:text_draw_x
		xor	bh,bh			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		add	bx,bx
		mov	al,ds:text_col_pos
		xor	ah,ah			; Zero register
		add	bx,ax
		add	bx,4
		mov	al,ds:text_box_cols
		mov	dl,0Ah
		mul	dl			; ax = reg * al
		add	cl,al
		add	cl,4
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
		mov	ah,1
		call	word ptr cs:gfx_draw_char_fn
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:char_glyph_tbl[bx]
		add	ds:text_col_pos,cl
		cmp	al,20h			; ' '
		je	render_space_check			; Jump if equal
		jmp	render_char_loop

render_space_check:
		mov	si,ds:text_str_ptr
		call	player_func_7
		mov	dl,ds:text_col_pos
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0A8h
		jae	render_newline			; Jump if above or =
		jmp	render_char_loop

render_newline:
		mov	byte ptr ds:text_col_pos,0
		inc	byte ptr ds:text_box_cols
		cmp	byte ptr ds:text_box_cols,8
		jne	render_row_inc			; Jump if not equal
		dec	byte ptr ds:text_box_cols
		mov	cx,0Ah

render_scroll_loop:
								push	cx
								mov	bx,ds:text_draw_x
								add	bl,4
								mov	cx,ds:text_layout_cx
								shr	ch,1			; Shift w/zeros fill
								sub	cl,8
								call	word ptr cs:gfx_scroll_row_fn
								pop	cx
								loop	render_scroll_loop		; Loop if cx > 0

render_row_inc:
		inc	byte ptr ds:text_row_flag
		cmp	byte ptr ds:text_row_flag,7
		jae	render_row_check			; Jump if above or =
		jmp	render_char_loop

render_row_check:
		cmp	byte ptr ds:text_anim_step,8
		jne	render_page_scroll			; Jump if not equal
		jmp	render_char_loop

render_page_scroll:
		sub	byte ptr ds:text_anim_step,7
		mov	cx,ds:text_draw_x
		xor	bh,bh			; Zero register
		mov	bl,ch
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,54h
		add	cl,4Ah			; 'J'
		push	cx
		push	bx
		mov	ax,27Ch
		call	word ptr cs:gfx_draw_char_fn
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		pop	bx
		pop	cx

render_page_loop:
								push	cx
								push	bx
								call	math_calc
								call	player_multiply_2
								pop	bx
								pop	cx
								test	byte ptr ds:text_done_flag,0FFh
								jnz	render_page_done			; Jump if not zero
								test	byte ptr ds:gvar_skip_flag2,0FFh
								jz	render_page_done			; Jump if zero
								retn

render_page_done:
								test	byte ptr ds:gvar_spacebar_state,0FFh
								jz	render_page_loop			; Jump if zero
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		mov	bh,bl
		mov	bl,cl
		xor	al,al			; Zero register
		mov	cx,208h
		call	word ptr cs:gfx_fill_fn
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:text_row_flag,0
		mov	byte ptr ds:gvar_volume,1Dh
		jmp	render_char_loop

player_func_5		endp

player_func_6		proc	near

text_end_seq:
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0

text_end_loop:
								call	math_calc
								call	player_multiply_2
								test	byte ptr ds:gvar_spacebar_state,0FFh
								jz	text_end_wait_a			; Jump if zero
								retn

text_end_wait_a:
								test	byte ptr ds:gvar_skip_flag2,0FFh
								jz	text_end_wait_b			; Jump if zero
								retn

text_end_wait_b:
								test	byte ptr ds:gvar_input_timer,0FFh
								jnz	text_end_loop			; Jump if not zero

text_end_loop2:
								call	math_calc
								call	player_multiply_2
								test	byte ptr ds:gvar_spacebar_state,0FFh
								jz	text_end_wait2_a			; Jump if zero
								retn

text_end_wait2_a:
								test	byte ptr ds:gvar_skip_flag2,0FFh
								jz	text_end_wait2_b			; Jump if zero
								retn

text_end_wait2_b:
								test	byte ptr ds:gvar_input_timer,0FFh
								jz	text_end_loop2			; Jump if zero
		retn

player_func_6		endp

player_func_7		proc	near
		xor	cx,cx			; Zero register

wwidth_loop:
														lodsb				; String [si] to al
														or	al,al			; Zero ?
														jns	wwidth_char			; Jump if not sign
														retn

wwidth_char:
														cmp	al,20h			; ' '
														jne	wwidth_not_space			; Jump if not equal
														retn

wwidth_not_space:
														cmp	al,2Fh			; '/'
														jne	wwidth_not_slash			; Jump if not equal
														retn

wwidth_not_slash:
														sub	al,20h			; ' '
														jc	wwidth_loop			; Jump if carry Set
								mov	bl,al
								xor	bh,bh			; Zero register
								add	cl,cs:char_glyph_tbl[bx]
								adc	ch,bh
								jmp	short wwidth_loop

player_func_7		endp

player_func_8		proc	near
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register

linecnt_loop:
														lodsb				; String [si] to al
														or	al,al			; Zero ?
														js	linecnt_end			; Jump if sign=1
														cmp	al,2Fh			; '/'
														jne	linecnt_char			; Jump if not equal
														inc	cx
														xor	dx,dx			; Zero register
														jmp	short linecnt_loop

linecnt_char:
														push	cx
														mov	bl,al
														sub	bl,20h			; ' '
														xor	bh,bh			; Zero register
														mov	cl,ds:char_glyph_tbl[bx]
														mov	ch,bh
														add	dx,cx
														pop	cx
														cmp	al,20h			; ' '
														jne	linecnt_loop			; Jump if not equal
														push	cx
														push	si
														push	dx
														call	player_func_7
														add	dx,cx
														cmp	dx,0A8h
														pop	dx
														pop	si
														pop	cx
														jc	linecnt_loop			; Jump if carry Set
								xor	dx,dx			; Zero register
								inc	cx
								jmp	short linecnt_loop

linecnt_end:
		or	dx,dx			; Zero ?
		jnz	linecnt_inc			; Jump if not zero
		retn

linecnt_inc:
		inc	cx
		retn

player_func_8		endp

ctrl_set_bit4:
		or	byte ptr ds:[4],80h
		jmp	evt_walk_entry

ctrl_81_header:
		mov	bx,ds:town_char_idx
		add	bh,bh
		add	bx,193Fh
		push	bx
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		pop	bx
		add	bx,103h
		mov	ds:gvar_dlg_pos,bx
		call	player_func_47
		mov	ax,ds:town_char_idx
		mov	bl,0Dh
		jnc	ctrl_81_dir			; Jump if carry=0
		jmp	render_set_dirty

ctrl_81_dir:
		mov	bl,0Ch
		jmp	render_set_dirty

ctrl_83_portrait:
		or	byte ptr ds:[34h],80h
		mov	byte ptr ds:[9Ah],0FFh
		call	player_func_25
		jmp	text_end_seq

ctrl_85_set_done:
		mov	byte ptr ds:text_done_flag,0FFh
		mov	bl,4
		mov	ax,word ptr ds:text_draw_x2
		jmp	render_set_dirty

ctrl_87_call_func6:
		call	player_func_6
		mov	bl,5
		mov	ax,word ptr ds:text_draw_x2
		jmp	render_set_dirty

ctrl_89_dialog:
		mov	bx,ds:town_char_idx
		add	bh,bh
		add	bx,1832h
		push	bx
		mov	cx,1219h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		pop	bx
		add	bx,203h
		mov	ds:gvar_dlg_pos,bx
		call	player_func_9
		mov	ax,ds:town_char_idx
		mov	bl,6
		jnc	ctrl_89_cost_check			; Jump if carry=0
		jmp	render_set_dirty

ctrl_89_cost_check:
		mov	dx,word ptr ds:[8Bh]
		sub	dx,9C4h
		mov	bl,7
		jnc	ctrl_89_deduct			; Jump if carry=0
		jmp	render_set_dirty

ctrl_89_deduct:
		mov	word ptr ds:[8Bh],dx
		call	word ptr cs:gfx_render_c_fn
		or	byte ptr ds:[34h],40h	; '@'
		mov	si,0A1h

ctrl_89_slot_find:
								test	byte ptr [si],0FFh
								jz	ctrl_89_slot_set			; Jump if zero
								inc	si
								jmp	short ctrl_89_slot_find

ctrl_89_slot_set:
		mov	byte ptr [si],5
		call	player_func_25
		mov	ax,ds:town_char_idx
		mov	bl,8
		jmp	render_set_dirty

player_func_9		proc	near
		mov	byte ptr ds:gvar_dlg_cols,2
		mov	byte ptr ds:gvar_dlg_rows,2
		mov	cx,2
		mov	si,6736h
		call	player_multiply_6
		mov	byte ptr ds:gvar_sel_row,0
		xor	bl,bl			; Zero register
		call	player_func_43
		jnc	shop_no_take			; Jump if carry=0
		mov	bl,1

shop_no_take:
		or	bl,bl			; Zero ?
		jnz	shop_take			; Jump if not zero
		retn

shop_take:
		stc				; Set carry flag
		retn

player_func_9		endp
		; UI strings: Take/No Take prompt
		db	'Take', 0		; 0x0000
		db	'No Take', 0		; 0x0005

math_calc		proc	near
		mov	ax,ds:text_draw_x
		sub	ah,6
		mov	cx,ds:text_layout_cx
		add	al,cl
		cmp	al,56h			; 'V'
		jae	cursor_fill_setup			; Jump if above or =
		retn

cursor_fill_setup:
		push	ax
		xor	ah,ah			; Zero register
		sub	al,4Eh			; 'N'
		mov	cx,8
		div	cl			; al, ah rem = ax/reg
		mov	cl,al
		pop	ax
		push	cs
		pop	es
		mov	di,cursor_buf
		mov	al,ah
		mov	dl,8
		mul	dl			; ax = reg * al
		add	di,ax
		mov	al,0FFh

cursor_col_loop:
								push	cx
								push	di
								mov	cx,16h

cursor_row_loop:
														stosb				; Store al to es:[di]
														add	di,7
														loop	cursor_row_loop		; Loop if cx > 0

								pop	di
								inc	di
								pop	cx
								loop	cursor_col_loop		; Loop if cx > 0

		retn

math_calc		endp

walk_left_entry:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:town_player_col
		add	bl,3
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:gvar_tile_ptr
		mov	al,[bx+7]
		call	player_scan_loop
		jnz	walk_left_tile_ok			; Jump if not zero
		retn

walk_left_tile_ok:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:town_player_col
		add	bl,4
		add	bx,word ptr ds:[80h]
		dec	bx
		call	player_func_12
		jz	walk_left_move			; Jump if zero
		retn

walk_left_move:
		inc	byte ptr ds:gvar_pose_idx
		and	byte ptr ds:gvar_pose_idx,3
		or	byte ptr ds:[0C2h],1
		cmp	byte ptr ds:town_player_col,0Bh
		jb	walk_left_col_clamp			; Jump if below
		dec	byte ptr ds:town_player_col
		retn

walk_left_col_clamp:
		test	word ptr ds:[80h],0FFFFh
		jnz	walk_left_scroll			; Jump if not zero
		dec	byte ptr ds:town_player_col
		retn

walk_left_scroll:
		dec	word ptr ds:[80h]
		sub	word ptr ds:gvar_tile_ptr,8
		call	word ptr cs:gfx_scroll_left_fn
		cmp	byte ptr ds:town_map_side,1
		je	walk_left_audio			; Jump if equal
		retn

walk_left_audio:
		call	word ptr cs:gfx_scroll_right_fn
		retn

walk_right_entry:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:town_player_col
		add	bl,6
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:gvar_tile_ptr
		mov	al,[bx+7]
		call	player_scan_loop
		jnz	walk_right_tile_ok			; Jump if not zero
		retn

walk_right_tile_ok:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:town_player_col
		add	bl,4
		add	bx,word ptr ds:[80h]
		inc	bx
		call	player_func_12
		jz	walk_right_move			; Jump if zero
		retn

walk_right_move:
		inc	byte ptr ds:gvar_pose_idx
		and	byte ptr ds:gvar_pose_idx,3
		and	byte ptr ds:[0C2h],0FEh
		cmp	byte ptr ds:town_player_col,10h
		jae	walk_right_edge			; Jump if above or =
		inc	byte ptr ds:town_player_col
		retn

walk_right_edge:
		mov	ax,ds:town_map_width
		sub	ax,23h
		mov	bx,word ptr ds:[80h]
		inc	bx
		cmp	ax,bx
		jne	walk_right_scroll			; Jump if not equal
		inc	byte ptr ds:town_player_col
		retn

walk_right_scroll:
		inc	word ptr ds:[80h]
		add	word ptr ds:gvar_tile_ptr,8
		call	word ptr cs:gfx_scroll_right2_fn
		cmp	byte ptr ds:town_map_side,1
		je	walk_right_audio			; Jump if equal
		retn

walk_right_audio:
		call	word ptr cs:gfx_scroll_left2_fn
		retn

player_scan_loop		proc	near
		mov	es,cs:gvar_game_seg
		mov	si,es:npc_list_ptr
		mov	cl,es:[si]
		or	cl,cl			; Zero ?
		jz	scan_not_found			; Jump if zero
		xor	ch,ch			; Zero register
		inc	si

scan_npc_loop:
								cmp	al,es:[si]
								jne	scan_npc_next			; Jump if not equal
								retn

scan_npc_next:
								inc	si
								loop	scan_npc_loop		; Loop if cx > 0

scan_not_found:
		not	cl
		or	cl,cl			; Zero ?
		retn

player_scan_loop		endp

player_func_12		proc	near
		mov	si,ds:npc_obj_list

npc_find_loop:
								mov	ax,[si]
								cmp	ax,0FFFFh
								jne	npc_check_pos			; Jump if not equal
								retn

npc_check_pos:
								sub	ax,bx
								jnz	npc_next_entry			; Jump if not zero
								test	byte ptr [si+6],40h	; '@'
								jz	npc_next_entry			; Jump if zero
								retn

npc_next_entry:
								add	si,8
								jmp	short npc_find_loop

player_func_12		endp

player_multiply_2		proc	near
		call	player_func_26
player_multiply_2		endp

player_func_14		proc	near
		call	player_func_18
		call	player_func_17
		call	word ptr cs:gfx_update_fn
		mov	cl,ds:gvar_anim_frames
		mov	al,4
		mul	cl			; ax = reg * al

frame_dispatch_loop:
								push	ax
								call	word ptr cs:[110h]
								call	word ptr cs:[112h]
								call	word ptr cs:[114h]
								call	word ptr cs:[116h]
								call	word ptr cs:[118h]
								call	word ptr cs:[11Eh]
								jnc	frame_no_clear			; Jump if carry=0
								call	clear_buffer

frame_no_clear:
								pop	ax
								cmp	ds:gvar_frame_timer,al
								jb	frame_dispatch_loop			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

player_func_14		endp

fill_buffer		proc	near
		test	word ptr ds:gvar_joy_state,1
		jnz	fillbuf_active			; Jump if not zero
		retn

fillbuf_active:
		mov	byte ptr ds:gvar_volume,0Bh
		call	word ptr cs:gfx_clear_fn
		call	player_process_loop
		call	word ptr cs:player_draw_fn
		call	player_process_loop
		call	word ptr cs:gfx_clear_fn
		call	player_func_23
		call	word ptr cs:gfx_draw_fn
		fill_cursor_buf
		call	player_func_14
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		retn

fill_buffer		endp

player_process_loop		proc	near
		mov	es,cs:gvar_game_seg
		mov	di,town_desc_0C000
		mov	si,vga_seg_A000
		mov	cx,800h

proc_copy_loop:
								mov	ax,es:[di]
								movsw				; Mov [si] to es:[di]
								mov	[si-2],ax
								loop	proc_copy_loop		; Loop if cx > 0

		retn

player_process_loop		endp

player_func_17		proc	near
		mov	al,byte ptr ds:town_player_col
		cmp	al,1Bh
		jb	anim_player_do			; Jump if below
		retn

anim_player_do:
		add	al,al
		add	al,al
		add	al,al
		add	al,5
		xor	ah,ah			; Zero register
		add	ax,cursor_buf
		mov	di,ax
		push	cs
		pop	es
		mov	al,0FFh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	di,5
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		retn

player_func_17		endp

player_func_18		proc	near
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:town_player_col
		add	al,4
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,5
		add	ax,ds:gvar_tile_ptr
		push	ax
		mov	si,ax
		mov	di,npc_anim_buf
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	si,5
		mov	cx,3
		movsw				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		xor	dx,dx			; Zero register
		mov	dl,byte ptr ds:town_player_col
		add	dl,4
		add	dx,word ptr ds:[80h]
		push	dx
		mov	si,npc_anim_buf
		mov	cx,2

npc_draw_setup_loop:
								push	si
								mov	al,[si]
								cmp	al,0FDh
								jne	npc_write_slot			; Jump if not equal
								call	player_func_20

npc_chain_check:
														mov	al,[si+3]
														cmp	al,0FDh
														jne	npc_write_slot			; Jump if not equal
														add	si,8
														call	player_func_21
														jmp	short npc_chain_check

npc_write_slot:
								pop	si
								mov	[si],al
								add	si,3
								inc	dx
								loop	npc_draw_setup_loop		; Loop if cx > 0

		mov	si,npc_anim_buf
		call	word ptr cs:gfx_npc_draw_fn
		pop	dx
		dec	dx
		mov	ds:town_npc_col,dx
		pop	si
		push	cs
		pop	es
		mov	di,npc_col_buf
		mov	al,[si-8]
		stosb				; Store al to es:[di]
		mov	al,[si]
		stosb				; Store al to es:[di]
		mov	al,[si+8]
		stosb				; Store al to es:[di]
		mov	si,ds:npc_obj_list

scan_npc2_loop:
								call	player_scan_loop_2
								or	al,al			; Zero ?
								jz	scan_npc2_skip			; Jump if zero
								push	ax
								call	word ptr cs:gfx_fn_3014
								pop	bx
								mov	es,cs:gvar_game_seg
								push	si
								mov	si,npc_anim_buf
								call	word ptr cs:gfx_npc_update_fn
								pop	si

scan_npc2_skip:
								add	si,8
;*		cmp	word ptr [si],0FFFFh
										cmp word ptr [si],-1			; was: db 083h,03Ch,0FFh
								jnz	scan_npc2_loop			; Jump if not zero
		mov	si,6A3Bh
		test	byte ptr ds:[0C2h],1
		jnz	walk_dir_select			; Jump if not zero
		mov	si,npc_walk_left

walk_dir_select:
		xor	ax,ax			; Zero register
		mov	al,byte ptr ds:gvar_pose_idx
		add	ax,ax
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		add	si,ax
		call	word ptr cs:gfx_fn_3012
		retn

player_func_18		endp

		; NPC animation frame permutation table (48 entries)
		; Maps NPC walk-cycle step to sprite frame index
		db	 00h, 02h, 04h, 01h, 03h, 05h	; step 0-5  (right: frame 0,2,4,1,3,5)
		db	 06h, 08h, 0Ah, 07h, 09h, 0Bh	; step 6-11 (right: frame 6,8,A,7,9,B)
		db	 00h, 0Ch, 0Eh, 01h, 0Dh, 0Fh	; step 12-17
		db	 06h, 10h, 12h, 07h, 11h, 13h	; step 18-23
		db	 14h, 16h, 18h, 15h, 17h, 19h	; step 24-29
		db	 1Ah, 1Ch, 1Eh, 1Bh, 1Dh, 1Fh	; step 30-35
		db	 20h, 22h, 24h, 21h, 23h, 25h	; step 36-41
		db	 1Ah				; step 42 (frame 26h prefix)
		db	'&(', 1Bh, 27h, ') *,!+-'	; step 43-47 (mixed text/control codes as frame ids)
		db	 14h, 16h, 18h, 15h, 17h, 19h	; step 48-53 (tail / wrap-around)

player_scan_loop_2		proc	near
		mov	cx,3
		mov	dx,ds:town_npc_col
		mov	di,npc_col_buf

npc_col_scan_loop:
								cmp	byte ptr [di],0FDh
								jne	npc_col_next			; Jump if not equal
								mov	al,cl
								cmp	dx,[si]
								jne	npc_col_next			; Jump if not equal
								retn

npc_col_next:
								inc	di
								inc	dx
								loop	npc_col_scan_loop		; Loop if cx > 0

		xor	al,al			; Zero register
		retn

player_scan_loop_2		endp

player_func_20		proc	near
		mov	si,ds:npc_obj_list
player_func_20		endp

player_func_21		proc	near

npc_dx_loop:
								cmp	dx,[si]
								jne	npc_dx_next			; Jump if not equal
								retn

npc_dx_next:
								add	si,8
								jmp	short npc_dx_loop

player_func_21		endp

player_func_22		proc	near
		call	player_func_32
player_func_22		endp

player_func_23		proc	near
		mov	al,ds:gvar_music_idx
		push	ds
		call	dword ptr ds:music_fn_ptr
		pop	ds
		retn

player_func_23		endp

player_load_chunk		proc	near
		mov	al,ds:town_map_side
		and	al,1
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,6AD3h
		mov	ax,cs
		add	ax,2000h
		mov	ds:gseg_chunk_ptr,ax
		mov	es,ax
		mov	di,3300h
		mov	al,3
		call	word ptr cs:[10Ch]
		retn

player_load_chunk		endp

			                        ;* No entry point to code  (data: SAR chunk ref table, reachable via sar_chunk_tbl ptr)
		add	[bx+di],cx
		pop	cx
		; SAR chunk references: YMPD.BIN, CKPD.BIN
		db	'YMPD.BIN', 0		; 0x0000
		db	001h, 00Ah		; 0x0009
		db	'CKPD.BIN', 0		; 0x000B
		db	'3', 0		; 0x0015

player_func_25		proc	near

evt_walk_entry:
		mov	si,ds:town_key_event

evt_outer_loop:
								lodsw				; String [si] to ax
								mov	bx,ax
								and	al,ah
								inc	al
								jnz	evt_outer_active			; Jump if not zero
								retn

evt_outer_active:
								lodsb				; String [si] to al
								and	al,[bx]
								jnz	evt_inner_write			; Jump if not zero

evt_skip_inner:
														lodsw				; String [si] to ax
														and	al,ah
														inc	al
														jz	evt_outer_end			; Jump if zero
														inc	si
														jmp	short evt_skip_inner

evt_inner_write:
														lodsw				; String [si] to ax
														mov	bx,ax
														and	al,ah
														inc	al
														jz	evt_outer_end			; Jump if zero
														mov	al,[si]
														mov	[bx],al
														inc	si
														jmp	short evt_inner_write

evt_outer_end:
								jmp	short evt_outer_loop

player_func_25		endp

player_func_26		proc	near
		call	player_func_28
		mov	si,ds:npc_obj_list
		mov	dx,[si]
;*		cmp	dx,0FFFFh
				cmp dx,-1			; was: db 083h,0FAh,0FFh
		jnz	$+5			; Jump if not zero
		jmp	npc_restore_entry
			                        ;* No entry point to code  (npc_dispatch_loop: called via player_func_26 dispatch)
		mov	bl,[si+5]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,word ptr ds:[6B41h][bx]
		call	ax			;* indirect call via NPC-type dispatch table at 0x6B41
		mov	[si],dx
		add	si,8
		jmp	short $-1Ch
			                        ;* No entry point to code  (npc_dispatch_tbl: NPC type fn-ptr table + shared movement code at 0x6B41)
		push	cx				; start of shared NPC movement code block
		db	 6Bh, 6Ch, 6Bh,0A6h, 6Bh,0B7h	; fn ptrs (LE words): npc_type0=6C6Bh, type1=6BA6h, type2=6BB7h
		db	 6Bh,0D2h, 6Bh,0ECh, 6Bh, 19h	; fn ptrs (LE words): type3=6BD2h, type4=6BECh, type5=6C19h
		db	 6Ch, 2Ah, 6Ch, 80h, 4Ch, 02h	; fn ptrs: type6=6C2Ah, type7=6C80h + shared code start
		db	 80h, 8Ah, 1Eh, 83h, 00h, 80h	; npc shared code: cmp+mov bl,ds:[8300h]; cmp byte ptr...
		db	0C3h, 04h, 32h,0FFh, 03h, 1Eh	; shared code: add bl,4; xor bh,bh; add bx,...
		db	 80h, 00h, 3Bh,0DAh, 72h, 6Ch	; shared code: 8000h offset; cmp bx,dx; jb +6Ch
		db	 80h, 64h, 02h, 7Fh,0EBh, 66h	; shared code: and byte ptr [si+2],7Fh; jmp +66h
		db	 8Ah, 44h, 04h, 04h, 10h, 88h	; shared code: mov al,[si+4]; add al,10h; mov [si+4]...
		db	 44h, 04h, 8Ah,0E8h, 24h, 10h	; shared code: mov [si+4],al; mov ch,al; and al,10h
		db	 74h, 01h,0C3h			; shared code: jz +1; ret

npc_anim_advance:
								inc	ch
								and	ch,0Fh
								or	ch,al
								mov	[si+4],ch
								mov	bx,ds:town_map_xlim
								test	byte ptr [si+2],80h
								jz	npc_hit_right_wall			; Jump if zero
								dec	dx
								cmp	[bx],dx
								jae	npc_hit_left_wall			; Jump if above or =
								retn

npc_hit_left_wall:
								and	byte ptr [si+2],7Fh
								retn

npc_hit_right_wall:
								inc	dx
								cmp	[bx+2],dx
								jb	npc_set_right_dir			; Jump if below
								retn

npc_set_right_dir:
								or	byte ptr [si+2],80h
								retn
									                        ;* No entry point to code  (npc_type1_fn: NPC type-1 walk, called via dispatch table)

npc_type1_fn:
								mov	al,[si+4]
								add	al,10h
								mov	[si+4],al
								mov	ch,al
								and	al,30h			; '0'
								jz	npc_anim_loop2			; Jump if zero
								retn

npc_anim_loop2:
								jmp	short npc_anim_advance
			                        ;* No entry point to code  (npc_type2_fn: NPC type-2 walk with player-relative check)

npc_type2_fn:
		or	byte ptr [si+2],80h
		mov	bl,byte ptr ds:town_player_col
		add	bl,4
		xor	bh,bh			; Zero register
		add	bx,word ptr ds:[80h]
		cmp	bx,dx
		jae	npc_set_left_chk			; Jump if above or =
		retn

npc_set_left_chk:
		and	byte ptr [si+2],7Fh
		retn
			                        ;* No entry point to code  (npc_type3_fn: NPC type-3 walk, called via dispatch table)

npc_type3_fn:
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,30h			; '0'
		jz	npc_anim_loop3			; Jump if zero
		retn

npc_anim_loop3:
		inc	ch
		and	ch,1
		or	al,ch
		mov	[si+4],al
		retn
			                        ;* No entry point to code  (npc_type4_fn: NPC type-4 walk cycle, called via dispatch table)

npc_type4_fn:
		mov	al,[si+4]
		add	al,10h
		mov	[si+4],al
		mov	ch,al
		and	al,10h
		jz	npc_anim_cycle			; Jump if zero
		retn

npc_anim_cycle:
								inc	ch
								and	ch,0Fh
								or	ch,al
								mov	[si+4],ch
								and	ch,7
								jnz	npc_anim_loop4			; Jump if not zero
								xor	byte ptr [si+2],80h
								retn

npc_anim_loop4:
								test	byte ptr [si+2],80h
								jz	npc_anim_fwd			; Jump if zero
								dec	dx
								retn

npc_anim_fwd:
								inc	dx
								retn
									                        ;* No entry point to code  (npc_type5_fn: NPC type-5 walk, called via dispatch table)

npc_type5_fn:
								mov	al,[si+4]
								add	al,10h
								mov	[si+4],al
								mov	ch,al
								and	al,30h			; '0'
								jz	npc_anim_loop5			; Jump if zero
								retn

npc_anim_loop5:
								jmp	short npc_anim_cycle
		db	0C3h				; retn (tail of npc_type5_fn / padding before player_func_27)

player_func_26		endp

player_func_27		proc	near

npc_restore_entry:
		mov	si,ds:npc_obj_list

npc_restore_loop:
								mov	bx,[si]
;*		cmp	bx,0FFFFh
										cmp bx,-1			; was: db 083h,0FBh,0FFh
								jnz	npc_restore_next			; Jump if not zero
								retn

npc_restore_next:
								add	bx,bx
								add	bx,bx
								add	bx,bx
								mov	al,ds:tile_collision_map[bx]
								mov	byte ptr ds:tile_collision_map[bx],0FDh
								mov	[si+3],al
								add	si,8
								jmp	short npc_restore_loop

player_func_27		endp

player_func_28		proc	near
		mov	si,ds:npc_obj_list

npc_save_loop:
								mov	bx,[si]
;*		cmp	bx,0FFFFh
										cmp bx,-1			; was: db 083h,0FBh,0FFh
								jnz	npc_save_check			; Jump if not zero
								retn

npc_save_check:
								mov	al,[si+3]
								cmp	al,0FDh
								je	npc_save_next			; Jump if equal
								add	bx,bx
								add	bx,bx
								add	bx,bx
								add	bx,tile_collision_map
								mov	[bx],al

npc_save_next:
								add	si,8
								jmp	short npc_save_loop

player_func_28		endp

player_func_29		proc	near
		mov	si,icon_data_a
		call	word ptr cs:gfx_load_img_fn
		mov	si,icon_data_b
		call	word ptr cs:gfx_load_img_fn
		mov	si,icon_data_c
		call	word ptr cs:gfx_load_img_fn
		mov	si,icon_data_d
		call	word ptr cs:gfx_load_img_fn
		retn

player_func_29		endp

			                        ;* No entry point to code  (data: NPC/town data block, reached via indirect ptr)
		push	cs
		mov	word ptr ds:[400h],ax
		dec	sp
		dec	cx
		inc	si
		inc	bp
		push	ds
		mov	bx,503h
		inc	cx
		dec	sp
		dec	bp
		inc	cx
		push	bx
		or	ax,1BBh
		add	al,47h			; 'G'
		dec	di
		dec	sp
		inc	sp
		or	ax,1AFh
		add	ax,4C50h
		inc	cx
		inc	bx
		inc	bp

player_func_30		proc	near
		mov	al,ds:player_col
		inc	al
		jnz	door_alt_check			; Jump if not zero
		call	player_func_28
		mov	byte ptr ds:gvar_frame_timer,28h	; '('
		call	player_func_14
		mov	si,ds:town_exit_ptr

door_seek_loop:
								test	byte ptr [si],1
								jnz	door_found			; Jump if not zero
								add	si,4
								jmp	short door_seek_loop

door_found:
		lodsb				; String [si] to al
		mov	ah,al
		lodsb				; String [si] to al
		and	ah,0FEh
		jz	door_execute			; Jump if zero
;*		jmp	pf30_exec			;*
				db 0E9h, 17h, 03h		; jmp near +0x317 (unaligned target 0FFBh)

door_execute:
		call	player_func_31
		mov	byte ptr ds:town_player_col,1Ah
		mov	ax,ds:town_map_width
		sub	ax,24h
		mov	word ptr ds:[80h],ax
		jmp	frame_update

door_alt_check:
		cmp	al,1Ch
		je	door_alt_seek			; Jump if equal
		retn

door_alt_seek:
		call	player_func_28
		mov	byte ptr ds:gvar_frame_timer,28h	; '('
		call	player_func_14
		mov	si,ds:town_exit_ptr

door_alt_loop:
								test	byte ptr [si],1
								jz	door_alt_found			; Jump if zero
								add	si,4
								jmp	short door_alt_loop

door_alt_found:
		lodsb				; String [si] to al
		mov	ah,al
		lodsb				; String [si] to al
		and	ah,0FEh
		jz	door_alt_execute			; Jump if zero
;*		jmp	pf30_exec			;*
				db 0E9h, 0D9h, 02h		; jmp near +0x2D9 (unaligned target 0FFBh)

door_alt_execute:
		call	player_func_31
		mov	byte ptr ds:town_player_col,0
		mov	word ptr ds:[80h],0
		jmp	frame_update

player_func_31		proc	near
		or	al,80h
		mov	byte ptr ds:[0C4h],al
		lodsw				; String [si] to ax
		push	ax
		mov	ah,byte ptr ds:[0C4h]
		mov	al,1
		call	word ptr cs:[10Ch]
		pop	ax
		push	ax
		mov	cl,0Bh
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,sar_chunk_tbl
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,town_base_4100
		SET_ES_2000
		mov	di,7000h
		mov	cx,0A0h
		call	word ptr cs:gfx_copy_fn
		pop	ds
		pop	ax
		cmp	ah,ds:town_palette_idx
		je	pf31_done		; Jump if equal
		mov	ds:town_palette_idx,ah
		call	player_func_32

pf31_done:
		retn

player_func_31		endp
			                        ;* No entry point to code  (data: sprite file reference table, reachable via sar_chunk_tbl)
		add	ds:snd_id_4D4D,bx
		; Sprite file references: MMAN.GRP, CMAN.GRP
		db	'MMAN.GRP', 0		; 0x0000
		db	001h, 01Fh		; 0x0009
		db	'CMAN.GRP', 0		; 0x000B

player_func_32		proc	near
		mov	al,0Bh
		mul	byte ptr ds:town_palette_idx	; ax = data * al
		add	ax,6DCEh
		mov	si,ax
		mov	es,cs:gvar_game_seg
		mov	di,8000h
		mov	al,2
		call	word ptr cs:[10Ch]
		add	word ptr es:[di],8000h
		add	word ptr es:[di+2],8000h
		add	word ptr es:[di+4],8000h
		jmp	word ptr cs:gfx_ret_fn

player_func_32		endp
			                        ;* No entry point to code  (data: pattern/sprite file reference table)
		add	[bp+si],sp
		inc	bx
		push	ax
		; Pattern/sprite file references: MPAT.GRP, DPAT.GRP
		db	080h		; 0x0001
		db	'.', 0		; 0x0002
		db	'&$0', 0		; 0x0004
		db	'"CPAT.GRP', 0		; 0x0008
		db	001h		; 0x0012
		db	'#MPAT.GRP', 0		; 0x0013
		db	001h		; 0x001D
		db	'$DPAT.GRP', 0		; 0x001E

player_func_33		proc	near
		mov	es,cs:gvar_game_seg
		mov	si,6E1Eh
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,6000h
		SET_ES_2000
		mov	di,8000h
		mov	cx,2Eh
		call	word ptr cs:gfx_copy_fn
		pop	ds
		retn

player_func_33		endp
			                        ;* No entry point to code  (data: .GRP file reference stub before door table)
		add	[bx+si],sp
		push	sp
		dec	bp
		inc	cx
		dec	si
		db	 2Eh, 47h, 52h, 50h, 00h	; ".GRP" filename suffix + null terminator

door_scan_entry:
		or	byte ptr ds:gvar_pose_idx,1
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:town_player_col
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,4
		mov	si,ds:town_event_tbl

door_scan_loop:
;*		cmp	word ptr [si],0FFFFh
										cmp word ptr [si],-1			; was: db 083h,03Ch,0FFh
								jnz	door_scan_next			; Jump if not zero
								retn

door_scan_next:
								cmp	[si],ax
								je	door_action			; Jump if equal
								inc	ax
								cmp	[si],ax
								je	door_action			; Jump if equal
								dec	ax
								dec	ax
								cmp	[si],ax
								je	door_action			; Jump if equal
								inc	ax
								add	si,3
								jmp	short door_scan_loop

door_action:
		mov	byte ptr ds:gvar_pose_idx,4
		push	si
		call	player_func_28
		mov	byte ptr ds:gvar_frame_timer,28h	; '('
		call	player_func_14
		pop	si
		mov	al,[si+2]
		cmp	al,0FFh
		jne	door_type_sub8			; Jump if not equal
		jmp	door_type_special

door_type_sub8:
		sub	al,8
		jc	door_type_shop			; Jump if carry Set
		jmp	pf30_exec			; was: db 0E9h, 7Ah, 01h

door_type_shop:
		mov	byte ptr ds:gvar_state_flag,4
		mov	bl,[si+2]
		mov	al,0Eh
		mul	bl			; ax = reg * al
		add	ax,6F07h
		mov	si,ax
		push	cs
		pop	es
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:gfx_blit_fn
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:town_scene_flag,0FFh
		call	word ptr cs:vga_seg_A000
		call	word ptr cs:gfx_clear_fn
		mov	byte ptr ds:town_scene_flag,0
		call	word ptr cs:gfx_draw_player_fn
		call	player_func_29
		mov	si,ds:town_tile_ptr
		call	word ptr cs:gfx_draw_map_fn
		call	player_func_22
		call	word ptr cs:gfx_draw_fn
		fill_cursor_buf
		call	player_func_25
		mov	byte ptr ds:gvar_frame_timer,28h	; '('
		call	player_func_14
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		mov	byte ptr ds:gvar_pose_idx,1
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		retn
			                        ;* No entry point to code  (data: building/shop program file reference table)
		add	[bp+di],cx
		dec	bx
		dec	cx
		dec	si
		inc	di
		push	ax
		push	dx
		dec	di
		; Building program file references (OMOYPRO, KENJPRO, ARMRPRO...)
		db	001h, 00Bh		; 0x0000
		db	'KINGPRO.BIN', 0		; 0x0002
		db	001h, 00Ch		; 0x000E
		db	'OMOYPRO.BIN', 0		; 0x0010
		db	001h, 012h		; 0x001C
		db	'KENJPRO.BIN', 0		; 0x001E
		db	001h, 00Dh		; 0x002A
		db	'ARMRPRO.BIN', 0		; 0x002C
		db	001h, 010h		; 0x0038
		db	'DRUGPRO.BIN', 0		; 0x003A
		db	001h, 00Fh		; 0x0046
		db	'CHURPRO.BIN', 0		; 0x0048
		db	001h, 00Eh		; 0x0054
		db	'BANKPRO.BIN', 0		; 0x0056
		db	001h, 011h		; 0x0062
		db	'INNAPRO.BIN', 0		; 0x0064

door_type_special:
		mov	byte ptr ds:gvar_pose_idx,4
		call	player_func_14
		test	byte ptr ds:[45h],80h
		jnz	special_door_load			; Jump if not zero
		mov	byte ptr ds:text_done_flag,0FFh
		mov	ax,918h
		xor	bl,bl			; Zero register
		call	player_func_5
		mov	byte ptr ds:text_done_flag,0
		or	byte ptr ds:[45h],80h

special_door_load:
		mov	byte ptr ds:gvar_state_flag,4
		mov	ah,86h
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	si,sar_chunk_tbl
		mov	es,cs:gvar_game_seg
		mov	di,4000h
		mov	al,2
		call	word ptr cs:[10Ch]

special_door_wait:
								test	byte ptr ds:gvar_enable_all,0FFh
								jz	special_door_wait			; Jump if zero
		mov	si,scene_map_data
		mov	es,cs:gvar_game_seg
		mov	di,3000h
		mov	al,5
		call	word ptr cs:[10Ch]
		mov	word ptr ds:[80h],84h
		mov	byte ptr ds:town_player_col,0Dh
		call	word ptr cs:gfx_blit_fn
;*		jmp	loc_2			;*
				db 0E9h, 31h, 0F0h		; jmp near -0xFCF (unaligned target 36h)
			                        ;* No entry point to code  (data: padding before pf30_exec)
		add	[bp+si],si

pf30_exec:
		push	bp
		inc	di
		dec	bp
		xor	ch,ds:snd_id_534D
		inc	sp
		add	ss:font_disp_data[bp+di],dh
		jcxz	pf30_no_scroll			; Jump if cx=0
		push	es
		or	ax,ax			; Zero ?

pf30_no_scroll:
		mov	si,ax
		lodsw				; String [si] to ax
		push	ax
		lodsb				; String [si] to al
		sub	al,0Ah
		and	al,3Fh			; '?'
		mov	byte ptr ds:[82h],al
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		mov	byte ptr ds:boss_intro_flag,al
		lodsb				; String [si] to al
		mov	byte ptr ds:[0C4h],al
		mov	ah,al
		mov	al,1
		call	word ptr cs:[10Ch]
		pop	ax
		add	ax,0FFF0h
		jns	dlg_char_fetch			; Jump if not sign
		add	ax,ds:town_map_width

dlg_char_fetch:
		mov	word ptr ds:[80h],ax
		mov	data_5,0FFh
		call	word ptr cs:gfx_blit_fn
		mov	bx,6002h
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]

player_func_30		endp

player_func_34		proc	near
		push	si
		push	di
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[11Eh]
		jnc	dlg_char_skip			; Jump if carry=0
		call	clear_buffer

dlg_char_skip:
		pop	di
		pop	si
		test	byte ptr ds:town_scene_flag,0FFh
		jnz	dlg_char_idle			; Jump if not zero
		retn

dlg_char_idle:
		push	si
		push	di
		call	word ptr cs:player_draw_fn
		pop	di
		pop	si
		retn

player_func_34		endp

			                        ;* No entry point to code  (dlg_setup: dialog outer entry, called indirectly via event handler)

dlg_setup:
		mov	si,ds:gvar_dialog_ptr
		call	player_check_state
		mov	dl,ds:gvar_text_x
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	dlg_main_loop			; Jump if below
		call	player_scan_loop_3

dlg_main_loop:
														mov	byte ptr ds:gvar_frame_timer,0

dlg_frame_wait:
														call	player_func_34
														cmp	byte ptr ds:gvar_frame_timer,6
														jb	dlg_frame_wait			; Jump if below
														mov	si,ds:gvar_dialog_ptr
														lodsb				; String [si] to al
														mov	ds:gvar_dialog_ptr,si
														cmp	al,2Fh			; '/'
														jne	dlg_char_dispatch			; Jump if not equal
														jmp	dlg_newline

dlg_char_dispatch:
														cmp	al,0Dh
														jne	dlg_not_slash			; Jump if not equal
														jmp	dlg_newline

dlg_not_slash:
														cmp	al,0Ch
														jne	dlg_not_0D			; Jump if not equal
														jmp	dlg_ctrl_0C

dlg_not_0D:
														cmp	al,0Fh
														jne	dlg_not_0C			; Jump if not equal
														jmp	dlg_ctrl_0F

dlg_not_0C:
														cmp	al,11h
														jne	dlg_not_0F			; Jump if not equal
														jmp	dlg_ctrl_11

dlg_not_0F:
														cmp	al,13h
														jne	dlg_not_11			; Jump if not equal
														mov	byte ptr ds:text_wrap_flag,0FFh
														jmp	short dlg_main_loop

dlg_not_11:
								cmp	al,15h
								jne	dlg_not_13			; Jump if not equal
								mov	byte ptr ds:text_wrap_flag,0
								jmp	short dlg_main_loop

dlg_not_13:
		cmp	al,0FFh
		jne	dlg_not_15			; Jump if not equal
		lodsb				; String [si] to al
		mov	ds:gvar_dialog_ptr,si
		retn

dlg_not_15:
		or	al,al			; Zero ?
		jnz	dlg_put_char			; Jump if not zero
		retn

dlg_put_char:
		push	ax
		cmp	byte ptr ds:gvar_text_x,0D0h
		jb	dlg_put_char2			; Jump if below
		call	player_scan_loop_3

dlg_put_char2:
		mov	bl,byte ptr ds:gvar_text_x
		xor	bh,bh			; Zero register
		mov	cl,byte ptr ds:gvar_text_y
		mov	al,0Ah
		mul	cl			; ax = reg * al
		mov	cl,al
		pop	ax
		push	bx
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	dl,ds:char_width_tbl[bx]
		mov	dh,bh
		pop	bx
		push	bx
		push	ax
		sub	bx,dx
		mov	ah,1
		add	bx,38h
		add	cl,63h			; 'c'
		call	word ptr cs:gfx_draw_char_fn
		pop	ax
		mov	bl,al
		sub	bl,20h			; ' '
		xor	bh,bh			; Zero register
		mov	cl,ds:char_glyph_tbl[bx]
		mov	ch,bh
		pop	bx
		add	bx,cx
		mov	byte ptr ds:gvar_text_x,bl
		test	byte ptr ds:text_wrap_flag,0FFh
		jnz	dlg_check_overflow			; Jump if not zero
		cmp	al,20h			; ' '
		je	dlg_check_overflow			; Jump if equal
		mov	byte ptr ds:gvar_volume,5
		jmp	dlg_main_loop

dlg_check_overflow:
		mov	si,ds:gvar_dialog_ptr
		call	player_check_state
		mov	dl,byte ptr ds:gvar_text_x
		xor	dh,dh			; Zero register
		add	dx,cx
		cmp	dx,0D0h
		jb	dlg_cont			; Jump if below
		call	player_scan_loop_3

dlg_cont:
		jmp	dlg_main_loop

dlg_newline:
		call	player_scan_loop_3
		jmp	dlg_main_loop

player_scan_loop_3		proc	near
		mov	byte ptr ds:gvar_text_x,0
		inc	byte ptr ds:text_line_ctr
		inc	byte ptr ds:gvar_text_y
		cmp	byte ptr ds:text_line_ctr,4
		jb	dlg_indent_check			; Jump if below
		call	player_check_state_2
		push	cx
		call	player_func_36
		pop	cx
		cmp	cx,2
		jb	dlg_skip_scroll		; Jump if below (cx<2: only 1 page, skip scroll)
		call	player_func_37

dlg_skip_scroll:
		retn

player_scan_loop_3		endp

player_func_36		proc	near

dlg_indent_check:
		cmp	byte ptr ds:gvar_text_y,5
		jae	dlg_do_indent			; Jump if above or =
		retn

dlg_do_indent:
		dec	byte ptr ds:gvar_text_y
		mov	cx,0Ah

dlg_indent_loop:
								push	cx
								call	player_func_34
								mov	bx,762h
								mov	cx,1A32h
								call	word ptr cs:gfx_scroll_row_fn
								pop	cx
								loop	dlg_indent_loop		; Loop if cx > 0

		retn

player_func_36		endp

dlg_ctrl_0F:
		call	player_func_37
		jmp	dlg_main_loop

dlg_ctrl_11:
		call	player_func_38
		jmp	dlg_main_loop

player_func_37		proc	near
		mov	bx,9Ch
		mov	cl,8Bh
		mov	ax,27Ch
		call	word ptr cs:gfx_draw_char_fn
		call	player_func_38
		mov	bx,ui_str_tbl
		mov	cx,20Ah
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fill_fn
		mov	byte ptr ds:text_line_ctr,0
		retn

player_func_37		endp

player_func_38		proc	near
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0

dlg_sel_wait_loop:
								call	player_func_34
								mov	al,ds:gvar_spacebar_state
								or	al,ds:gvar_skip_flag2
								jz	dlg_sel_wait_loop			; Jump if zero
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		mov	byte ptr ds:gvar_volume,1Dh
		retn

player_func_38		endp

dlg_ctrl_0C:
		mov	byte ptr ds:gvar_text_x,0
		mov	byte ptr ds:gvar_text_y,0
		mov	byte ptr ds:text_line_ctr,0
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		jmp	dlg_main_loop

player_check_state		proc	near
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register

chkstate_loop:
														lodsb				; String [si] to al
														or	al,al			; Zero ?
														jz	chkstate_end			; Jump if zero
														cmp	al,0FFh
														je	chkstate_end			; Jump if equal
														cmp	al,20h			; ' '
														je	chkstate_end			; Jump if equal
														cmp	al,2Fh			; '/'
														je	chkstate_end			; Jump if equal
														cmp	al,0Dh
														je	chkstate_end			; Jump if equal
														cmp	al,0Ch
														je	chkstate_end			; Jump if equal
														mov	ah,al
														sub	al,20h			; ' '
														jc	chkstate_loop			; Jump if carry Set
								inc	dx
								mov	bl,al
								xor	bh,bh			; Zero register
								add	cl,cs:char_glyph_tbl[bx]
								adc	ch,bh
								jmp	short chkstate_loop

chkstate_end:
		cmp	dx,1
		je	chkstate_single			; Jump if equal
		retn

chkstate_single:
		cmp	ah,2Eh			; '.'
		je	chkstate_punct			; Jump if equal
		cmp	ah,2Ch			; ','
		je	chkstate_punct			; Jump if equal
		retn

chkstate_punct:
		xor	cx,cx			; Zero register
		retn

player_check_state		endp

player_check_state_2		proc	near
		mov	si,ds:gvar_dialog_ptr
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register

chkstate2_loop:
														lodsb				; String [si] to al
														or	al,al			; Zero ?
														jz	chkstate2_end			; Jump if zero
														cmp	al,0FFh
														jne	chkstate2_ctrl			; Jump if not equal
														lodsb				; String [si] to al
														cmp	al,0FFh
														je	chkstate2_end			; Jump if equal
														jmp	short chkstate2_loop

chkstate2_ctrl:
														cmp	al,0Ch
														je	chkstate2_end			; Jump if equal
														cmp	al,2Fh			; '/'
														jne	chkstate2_slash			; Jump if not equal
														xor	dx,dx			; Zero register
														inc	cx
														jmp	short chkstate2_loop

chkstate2_slash:
														cmp	al,0Dh
														jne	chkstate2_0D			; Jump if not equal
														xor	dx,dx			; Zero register
														inc	cx
														jmp	short chkstate2_loop

chkstate2_0D:
														mov	bl,al
														sub	bl,20h			; ' '
														xor	bh,bh			; Zero register
														mov	bl,ds:char_glyph_tbl[bx]
														add	dx,bx
														cmp	al,20h			; ' '
														jne	chkstate2_loop			; Jump if not equal
														push	cx
														push	si
														push	dx
														push	dx
														call	player_check_state
														pop	dx
														add	dx,cx
														cmp	dx,0D0h
														pop	dx
														pop	si
														pop	cx
														jc	chkstate2_loop			; Jump if carry Set
								xor	dx,dx			; Zero register
								inc	cx
								jmp	short chkstate2_loop

chkstate2_end:
		or	dx,dx			; Zero ?
		jnz	chkstate2_inc			; Jump if not zero
		retn

chkstate2_inc:
		inc	cx
		retn

player_check_state_2		endp

			                        ;* No entry point to code  (num_to_str: convert AX to decimal string, called via event handler)

num_to_str:
		push	ds
		pop	es
		push	di
		mov	bl,0Fh
		mov	cx,4240h
		call	player_func_41
		mov	bl,1
		mov	cx,86A0h
		call	player_func_41
		xor	bl,bl			; Zero register
		mov	cx,2710h
		call	player_func_41
		mov	cx,3E8h
		call	player_func_42
		mov	cx,64h
		call	player_func_42
		mov	cx,0Ah
		call	player_func_42
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		pop	di
		mov	si,di
		mov	cx,7

numfmt_leading_skip:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jnz	numfmt_first_digit			; Jump if not zero
								loop	numfmt_leading_skip		; Loop if cx > 0

numfmt_first_digit:
		add	al,30h			; '0'
		stosb				; Store al to es:[di]
		jcxz	numfmt_done			; Jump if cx=0
		dec	cx
		jz	numfmt_done			; Jump if zero

numfmt_digit_loop:
								lodsb				; String [si] to al
								add	al,30h			; '0'
								stosb				; Store al to es:[di]
								loop	numfmt_digit_loop		; Loop if cx > 0

numfmt_done:
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

player_func_41		proc	near
		xor	dh,dh			; Zero register

div_loop:
								sub	dl,bl
								jc	div_done			; Jump if carry Set
								sub	ax,cx
								jnc	div_inc			; Jump if carry=0
								or	dl,dl			; Zero ?
								jz	div_add_back			; Jump if zero
								dec	dl

div_inc:
								inc	dh
								jmp	short div_loop

div_add_back:
		add	ax,cx

div_done:
		add	dl,bl
		push	ax
		mov	al,dh
		stosb				; Store al to es:[di]
		pop	ax
		retn

player_func_41		endp

player_func_42		proc	near
		xor	dh,dh			; Zero register
		div	cx			; ax,dx rem=dx:ax/reg
		xchg	dx,ax
		mov	dh,dl
		xor	dl,dl			; Zero register
		push	ax
		mov	al,dh
		stosb				; Store al to es:[di]
		pop	ax
		retn

player_func_42		endp

player_func_43		proc	near
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		push	bx
		call	player_multiply_3
		pop	bx
		push	bx
		call	player_func_34
		pop	bx
		mov	byte ptr ds:gvar_frame_timer,0
		test	byte ptr ds:gvar_skip_flag2,0FFh
		stc				; Set carry flag
		jz	sel_check_skip			; Jump if zero
		retn

sel_check_skip:
		test	byte ptr ds:gvar_spacebar_state,0FFh
		jz	sel_poll_joy			; Jump if zero
		clc				; Clear carry flag
		mov	byte ptr ds:gvar_volume,1Fh
		retn

sel_poll_joy:
		mov	ax,7353h
		push	ax
		int	61h			; ??INT Non-standard interrupt
		and	al,3
		cmp	al,1
		jne	sel_not_up			; Jump if not equal
		or	bl,bl			; Zero ?
		jz	sel_no_cursor			; Jump if zero
		push	bx
		call	player_multiply_4
		pop	bx
		dec	bl
		retn

sel_no_cursor:
		test	byte ptr ds:gvar_sel_row,0FFh
		jnz	sel_scroll_up			; Jump if not zero
		retn

sel_scroll_up:
		push	di
		push	si
		push	bx
		dec	byte ptr ds:gvar_sel_row
		mov	al,ds:gvar_sel_row
		add	al,bl
		mov	bx,gvar_sel_xlat
		xlat				; al=[al+[bx]] table
		call	word ptr cs:gfx_sel_init_fn
		mov	cx,0Ah

sel_scroll_up_anim:
								push	cx
								mov	bx,ds:gvar_dlg_pos
								add	bx,301h
								mov	al,cl
								dec	al
								mov	cl,ds:gvar_dlg_cols
								add	cl,cl
								mov	dl,cl
								add	cl,cl
								add	cl,cl
								add	cl,dl
								sub	cl,2
								mov	ch,ds:gvar_dlg_timer
								call	word ptr cs:gfx_sel_scroll_up_fn

sel_anim_wait_u:
														call	player_func_34
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	sel_anim_wait_u			; Jump if below
								mov	byte ptr ds:gvar_frame_timer,0
								pop	cx
								loop	sel_scroll_up_anim		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn

sel_not_up:
		cmp	al,2
		je	sel_down_check			; Jump if equal
		retn

sel_down_check:
		mov	al,ds:gvar_dlg_cols
		dec	al
		cmp	bl,al
		jae	sel_bottom_check			; Jump if above or =
		push	bx
		call	player_multiply_5
		pop	bx
		inc	bl
		retn

sel_bottom_check:
		mov	al,bl
		add	al,ds:gvar_sel_row
		inc	al
		mov	ah,ds:gvar_dlg_rows
		dec	ah
		cmp	ah,al
		jae	sel_scroll_down			; Jump if above or =
		retn

sel_scroll_down:
		push	di
		push	si
		push	bx
		inc	byte ptr ds:gvar_sel_row
		mov	al,ds:gvar_sel_row
		add	al,bl
		mov	bx,gvar_sel_xlat
		xlat				; al=[al+[bx]] table
		call	word ptr cs:gfx_sel_init_fn
		mov	cx,0Ah

sel_scroll_dn_anim:
								push	cx
								mov	bx,ds:gvar_dlg_pos
								add	bx,301h
								mov	al,cl
								neg	al
								add	al,0Ah
								mov	cl,ds:gvar_dlg_cols
								add	cl,cl
								mov	dl,cl
								add	cl,cl
								add	cl,cl
								add	cl,dl
								sub	cl,2
								mov	ch,ds:gvar_dlg_timer
								call	word ptr cs:gfx_sel_scroll_dn_fn

sel_anim_wait_d:
														call	player_func_34
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	sel_anim_wait_d			; Jump if below
								mov	byte ptr ds:gvar_frame_timer,0
								pop	cx
								loop	sel_scroll_dn_anim		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		retn

player_func_43		endp

player_multiply_3		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:gvar_dlg_pos
		add	ax,100h
		mov	bx,ax
		jmp	word ptr cs:gfx_cursor_fn

player_multiply_3		endp

player_multiply_4		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:gvar_dlg_pos
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

del_anim_loop:
								push	cx
								mov	byte ptr ds:gvar_frame_timer,0
								dec	bx
								push	bx
								call	word ptr cs:gfx_cursor_fn

del_anim_wait:
														call	player_func_34
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	del_anim_wait			; Jump if below
								pop	bx
								pop	cx
								loop	del_anim_loop		; Loop if cx > 0

		retn

player_multiply_4		endp

player_multiply_5		proc	near
		mov	al,0Ah
		mul	bl			; ax = reg * al
		add	ax,ds:gvar_dlg_pos
		add	ax,100h
		mov	bx,ax
		mov	cx,0Ah

ins_anim_loop:
								push	cx
								mov	byte ptr ds:gvar_frame_timer,0
								inc	bx
								push	bx
								call	word ptr cs:gfx_cursor_fn

ins_anim_wait:
														call	player_func_34
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	ins_anim_wait			; Jump if below
								pop	bx
								pop	cx
								loop	ins_anim_loop		; Loop if cx > 0

		retn

player_multiply_5		endp

player_func_47		proc	near
		mov	al,ds:gvar_dlg_cols
		mov	ah,ds:gvar_dlg_rows
		push	ax
		mov	al,ds:gvar_sel_row
		push	ax
		mov	byte ptr ds:gvar_dlg_cols,2
		mov	byte ptr ds:gvar_dlg_rows,2
		mov	cx,2
		mov	si,7513h
		call	player_multiply_6
		mov	byte ptr ds:gvar_sel_row,0
		xor	bl,bl			; Zero register
		call	player_func_43
		jnc	shop_sel_no			; Jump if carry=0
		mov	bl,1

shop_sel_no:
		pop	ax
		mov	ds:gvar_sel_row,al
		pop	ax
		mov	ds:gvar_dlg_cols,al
		mov	ds:gvar_dlg_rows,ah
		or	bl,bl			; Zero ?
		jnz	shop_sel_yes			; Jump if not zero
		retn

shop_sel_yes:
		stc				; Set carry flag
		retn

player_func_47		endp

		; Shop Yes/No prompt strings
		db	'Yes', 0		; 0x0000 - "Yes" response
		db	'No',  0		; 0x0004 - "No" response

player_multiply_6		proc	near
		xor	dl,dl			; Zero register

shop_draw_loop:
								push	cx
								push	dx
								mov	al,0Ah
								mul	dl			; ax = reg * al
								add	ax,ds:gvar_dlg_pos
								add	ax,301h
								mov	bx,ax
								xor	cl,cl			; Zero register
								call	word ptr cs:gfx_clear_row_fn
								pop	dx
								pop	cx
								inc	dl
								loop	shop_draw_loop		; Loop if cx > 0

		retn

player_multiply_6		endp

		db	 32h,0E4h		; xor ah,ah (entry prologue for shop_sel_anim_loop, reached via indirect call)

shop_sel_anim_loop:
								push	cx
								push	si
								push	di
								push	ax
								mov	bx,gvar_sel_xlat
								xlat				; al=[al+[bx]] table
								call	word ptr cs:gfx_sel_init_fn
								pop	ax
								push	ax
								mov	al,ah
								xor	ah,ah			; Zero register
								add	ax,ax
								mov	bx,ax
								add	ax,ax
								add	ax,ax
								add	bx,ax
								add	bx,ds:gvar_dlg_pos
								add	bx,300h
								call	word ptr cs:gfx_sel_draw_fn
								pop	ax
								inc	al
								inc	ah
								pop	di
								pop	si
								pop	cx
								loop	shop_sel_anim_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code  (gold_sub_fn: subtract gold cost, called via dispatch)

gold_sub_fn:
		mov	bl,byte ptr ds:[85h]
		sub	bl,dl
		jnc	coll_sub_ok			; Jump if carry=0
		retn

coll_sub_ok:
		mov	dl,bl
		mov	bx,word ptr ds:[86h]
		xchg	bx,ax
		sub	ax,bx
		jc	coll_sub_borrow			; Jump if carry Set
		retn

coll_sub_borrow:
		sub	dl,1
		retn
			                        ;* No entry point to code  (gold_add_fn: add to gold, called via dispatch)

gold_add_fn:
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],dl
		retn

clear_buffer		proc	near

savegame_entry:
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		push	cs
		pop	es
		mov	si,7688h
		mov	al,6
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:gvar_sel_flag,0
		call	copy_buffer
		push	cs
		pop	es
		test	byte ptr cs:save_new_flag,0FFh
		jz	load_no_new			; Jump if zero
		mov	di,gvar_save_name
		xor	al,al			; Zero register
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	si,7688h
		jmp	short load_open_file

load_no_new:
		mov	si,gvar_save_name
		mov	di,save_name_buf
		mov	cx,8

load_name_copy_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	load_append_ext			; Jump if zero
								stosb				; Store al to es:[di]
								loop	load_name_copy_loop		; Loop if cx > 0

load_append_ext:
		mov	byte ptr es:[di],2Eh	; '.'
		mov	byte ptr es:[di+1],55h	; 'U'
		mov	byte ptr es:[di+2],53h	; 'S'
		mov	byte ptr es:[di+3],52h	; 'R'
		mov	byte ptr es:[di+4],0
		mov	si,7C65h
		mov	byte ptr cs:gvar_load_flag,0FFh

load_open_file:
		mov	di,0
		mov	al,3
		call	word ptr cs:[10Ch]
		mov	byte ptr cs:gvar_load_flag,0
		jc	load_not_found			; Jump if carry Set
		mov	si,767Bh
		mov	di,0A000h
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:gfx_refresh_fn
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		mov	ax,0FFFFh
		jmp	word ptr ds:game_exit_fn

load_not_found:
		mov	bx,1A46h
		mov	cx,1E1Ah
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		push	cs
		pop	ds
		mov	si,7667h
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		call	word ptr cs:gfx_draw_str_fn
		mov	byte ptr cs:gvar_spacebar_state,0

load_wait_input:
								call	word ptr cs:[110h]
								test	byte ptr cs:gvar_spacebar_state,0FFh
								jz	load_wait_input			; Jump if zero
		mov	byte ptr cs:gvar_spacebar_state,0
		jmp	savegame_entry

clear_buffer		endp
		; Game loader reference: GAME.BIN
		db	0FFh		; 0x0000
		db	'User File', 0		; 0x0001
		db	'Not Found', 0		; 0x000B
		db	'GAME.BI', 0		; 0x0017
		db	0			; final string-terminator pad

copy_buffer		proc	near
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	di,cursor_buf
		mov	dx,77A8h
		call	word ptr cs:[11Ch]
		mov	di,cursor_buf
		inc	byte ptr [di]
		jnz	savescr_setup			; Jump if not zero
		dec	byte ptr [di]

savescr_setup:
		std				; Set direction flag
		mov	si,cursor_buf_end
		mov	di,cursor_buf_tail
		mov	cx,0FFh
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	word ptr ds:cursor_buf_cnt,save_default_name
		mov	bx,0D38h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		mov	bx,0D38h
		mov	cx,2637h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_fn
		push	cs
		pop	es
		mov	di,save_name_buf
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:save_name_len,0
		mov	si,gvar_save_name
		mov	di,save_name_buf
		mov	cx,8

savescr_name_copy:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	savescr_name_done			; Jump if zero
								inc	byte ptr ds:save_name_len
								stosb				; Store al to es:[di]
								loop	savescr_name_copy		; Loop if cx > 0

savescr_name_done:
		mov	al,ds:save_name_len
		mov	ds:save_name_maxlen,al
		push	cs
		pop	es
		mov	di,save_name_buf
		mov	al,60h			; '`'
		mov	cx,8

savescr_blank_scan:
								scasb				; Scan es:[di] for al
								jnz	savescr_draw_slot			; Jump if not zero
								loop	savescr_blank_scan		; Loop if cx > 0

		mov	si,save_default_name
		mov	di,save_name_buf
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

savescr_draw_slot:
		mov	bx,3Ch
		mov	cl,44h			; 'D'
		mov	si,77AEh
		call	word ptr cs:gfx_draw_str_fn
		mov	word ptr ds:save_cursor_x,60h
		mov	byte ptr ds:save_cursor_y,56h	; 'V'
		mov	word ptr ds:gvar_dlg_pos,343Bh
		mov	word ptr ds:gvar_dlg_timer,0Ah
		mov	al,ds:cursor_buf
		or	al,al			; Zero ?
		jz	savescr_no_saves			; Jump if zero
		cmp	al,5
		jb	savescr_count_clamp			; Jump if below
		mov	al,5

savescr_count_clamp:
		xor	ah,ah			; Zero register
		mov	cx,ax
		xor	al,al			; Zero register
		mov	si,cursor_buf_cnt
		jcxz	savescr_load_prev			; Jump if cx=0
		call	player_process_loop_2

savescr_load_prev:
		mov	si,cursor_buf_cnt
		mov	al,ds:cursor_buf
		mov	ds:gvar_dlg_rows,al
		mov	byte ptr ds:gvar_dlg_cols,5
		call	player_copy_buf
		push	cs
		pop	es
		mov	di,gvar_save_name
		mov	cx,8
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		cmp	byte ptr ds:save_name_maxlen,0
		stc				; Set carry flag
		jnz	savescr_has_name			; Jump if not zero
		retn

savescr_has_name:
		mov	si,save_name_buf
		mov	di,gvar_save_name

savescr_name_loop:
								lodsb				; String [si] to al
								cmp	al,0FFh
								clc				; Clear carry flag
								jnz	savescr_name_char			; Jump if not zero
								retn

savescr_name_char:
								cmp	al,60h			; '`'
								clc				; Clear carry flag
								jnz	savescr_name_next			; Jump if not zero
								retn

savescr_name_next:
								stosb				; Store al to es:[di]
								jmp	short savescr_name_loop

savescr_no_saves:
		mov	ax,0FFFFh
		jmp	dword ptr cs:gvar_fn_tbl

copy_buffer		endp
		; Input/user string data
		db	'.', 0		; 0x0000
		db	0FFh		; 0x0002
		db	'*.usr', 0		; 0x0003
		db	'Input name:', 0		; 0x0009
		db	'Re-Start', 0		; 0x0015
player_func_51		proc	near
		mov	byte ptr cs:save_new_flag,0
		push	cs
		pop	es
		mov	di,save_name_buf
		mov	al,2Dh			; '-'
		mov	cx,8
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		jz	newgame_found			; Jump if zero
		retn

newgame_found:
		mov	byte ptr cs:save_new_flag,0FFh
		mov	byte ptr cs:save_name_len,0
		retn

player_func_51		endp

fill_buffer_2		proc	near
		test	byte ptr cs:save_new_flag,0FFh
		jnz	clearbuf_active			; Jump if not zero
		retn

clearbuf_active:
		mov	byte ptr cs:save_new_flag,0
		push	cs
		pop	es
		mov	di,save_name_buf
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	byte ptr cs:save_name_maxlen,0
		retn

fill_buffer_2		endp

player_process_loop_2		proc	near
		xor	ah,ah			; Zero register

sel_item_loop:
								push	cx
								push	si
								push	ax
								call	word ptr cs:gfx_sel_init_fn
								pop	ax
								push	ax
								mov	al,ah
								xor	ah,ah			; Zero register
								add	ax,ax
								mov	bx,ax
								add	ax,ax
								add	ax,ax
								add	bx,ax
								add	bx,ds:gvar_dlg_pos
								add	bx,300h
								call	word ptr cs:gfx_sel_draw_fn
								pop	ax
								inc	al
								inc	ah
								pop	si
								pop	cx
								loop	sel_item_loop		; Loop if cx > 0

		retn

player_process_loop_2		endp

player_copy_buf		proc	near
		call	player_func_51
		mov	byte ptr ds:gvar_input_lock,0FFh
		mov	byte ptr ds:gvar_enter_key,0
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	byte ptr ds:gvar_skip_flag2,0
		mov	byte ptr ds:gvar_sel_row,0
		mov	byte ptr ds:save_del_flag,0
		xor	bl,bl			; Zero register
		test	byte ptr ds:gvar_dlg_rows,0FFh
		jz	nameinput_draw			; Jump if zero
		call	word ptr cs:save_draw_fn

nameinput_draw:
		call	player_func_56
		xor	al,al			; Zero register
		call	player_func_55

nameinput_main_loop:
								mov	byte ptr ds:gvar_frame_timer,0
								test	word ptr cs:gvar_joy_state,1
								jz	nameinput_no_confirm			; Jump if zero
								push	cs
								pop	es
								mov	di,save_name_buf
								mov	al,60h			; '`'
								mov	cx,8

nameinput_blank_scan:
														scasb				; Scan es:[di] for al
														jnz	nameinput_done			; Jump if not zero
														loop	nameinput_blank_scan		; Loop if cx > 0

								push	si
								mov	si,save_default_name
								mov	di,save_name_buf
								mov	cx,8
								rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
								pop	si
								call	player_func_51
								call	player_func_56
								mov	byte ptr ds:gvar_volume,1

nameinput_blink_wait:
														test	word ptr cs:gvar_joy_state,1
														jnz	nameinput_blink_wait			; Jump if not zero
								jmp	short nameinput_main_loop

nameinput_done:
		mov	byte ptr ds:gvar_volume,1Fh
		mov	byte ptr ds:gvar_input_lock,0
		mov	byte ptr ds:gvar_skip_flag2,0
		retn

nameinput_no_confirm:
		test	byte ptr ds:gvar_spacebar_state,0FFh
		jz	nameinput_key_check			; Jump if zero
		mov	byte ptr ds:gvar_volume,1
		push	si
		xor	bh,bh			; Zero register
		mov	bl,ds:gvar_sel_row
		add	bl,ds:save_del_flag
		add	bx,bx
		mov	si,[bx+si]
		push	cs
		pop	es
		mov	di,save_name_buf
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:save_name_len,0
		mov	di,save_name_buf
		mov	cx,8

nameinput_copy_loop:
								lodsb				; String [si] to al
								or	al,al			; Zero ?
								jz	nameinput_copy_done			; Jump if zero
								inc	byte ptr ds:save_name_len
								stosb				; Store al to es:[di]
								loop	nameinput_copy_loop		; Loop if cx > 0

nameinput_copy_done:
		mov	al,ds:save_name_len
		mov	ds:save_name_maxlen,al
		pop	si
		call	player_func_51
		mov	byte ptr ds:gvar_spacebar_state,0
		mov	ax,ds:save_cursor_x
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:save_cursor_y
		mov	cx,1010h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fill_fn
		call	player_func_56
		xor	al,al			; Zero register
		call	player_func_55
		jmp	nameinput_main_loop

nameinput_key_check:
		mov	cx,786Fh
		push	cx
		test	byte ptr ds:gvar_enter_key,0FFh
		jz	nameinput_joy_check			; Jump if zero
		mov	byte ptr ds:gvar_volume,1
		mov	al,ds:gvar_enter_key
		mov	byte ptr ds:gvar_enter_key,0
		cmp	al,0Dh
		jne	nameinput_not_enter			; Jump if not equal
		retn

nameinput_not_enter:
		cmp	al,8
		jne	nameinput_not_bs			; Jump if not equal
		jmp	backspace_exec

nameinput_not_bs:
		push	ax
		call	fill_buffer_2
		pop	ax
		xor	bx,bx			; Zero register
		mov	bl,ds:save_name_len
		cmp	byte ptr ds:save_name_buf[bx],60h	; '`'
		jne	nameinput_append			; Jump if not equal
		inc	byte ptr ds:save_name_maxlen

nameinput_append:
		mov	ds:save_name_buf[bx],al
		call	player_func_56
		mov	byte ptr ds:gvar_volume,1
		mov	al,1
		jmp	cursor_draw

nameinput_joy_check:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jz	nameinput_joy_dn			; Jump if zero
		mov	byte ptr ds:gvar_volume,1
		mov	al,1
		call	player_func_55

nameinput_joy_wait_u:
								int	61h			; ??INT Non-standard interrupt
								test	al,8
								jnz	nameinput_joy_wait_u			; Jump if not zero
		mov	byte ptr ds:gvar_enter_key,0
		retn

nameinput_joy_dn:
		test	al,4
		jz	nameinput_joy_lr			; Jump if zero
		mov	byte ptr ds:gvar_volume,1
		mov	al,0FFh
		call	player_func_55

nameinput_joy_wait_d:
								int	61h			; ??INT Non-standard interrupt
								test	al,4
								jnz	nameinput_joy_wait_d			; Jump if not zero
		mov	byte ptr ds:gvar_enter_key,0
		retn

nameinput_joy_lr:
		test	byte ptr ds:gvar_dlg_rows,0FFh
		jnz	nameinput_joy_lr2			; Jump if not zero
		retn

nameinput_joy_lr2:
		and	al,3
		cmp	al,1
		jne	nameinput_not_left			; Jump if not equal
		test	byte ptr ds:save_del_flag,0FFh
		jz	nameinput_at_top			; Jump if zero
		mov	bl,ds:save_del_flag
		call	word ptr cs:save_scroll_up_fn
		dec	byte ptr ds:save_del_flag
		retn

nameinput_at_top:
		test	byte ptr ds:gvar_sel_row,0FFh
		jnz	nameinput_sel_up			; Jump if not zero
		retn

nameinput_sel_up:
		push	di
		push	si
		dec	byte ptr ds:gvar_sel_row
		mov	al,ds:gvar_sel_row
		add	al,ds:save_del_flag
		call	word ptr cs:gfx_sel_init_fn
		mov	cx,0Ah

nameinput_up_anim:
								push	cx
								mov	bx,ds:gvar_dlg_pos
								add	bx,301h
								mov	al,cl
								dec	al
								mov	cl,ds:gvar_dlg_cols
								add	cl,cl
								mov	dl,cl
								add	cl,cl
								add	cl,cl
								add	cl,dl
								sub	cl,2
								mov	ch,ds:gvar_dlg_timer
								call	word ptr cs:gfx_sel_scroll_up_fn

nameinput_up_wait:
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	nameinput_up_wait			; Jump if below
								mov	byte ptr ds:gvar_frame_timer,0
								pop	cx
								loop	nameinput_up_anim		; Loop if cx > 0

		pop	si
		pop	di
		retn

nameinput_not_left:
		cmp	al,2
		je	nameinput_down_go			; Jump if equal
		retn

nameinput_down_go:
		mov	al,ds:save_del_flag
		add	al,ds:gvar_sel_row
		inc	al
		mov	ah,ds:gvar_dlg_rows
		dec	ah
		cmp	ah,al
		jae	nameinput_at_bottom			; Jump if above or =
		retn

nameinput_at_bottom:
		mov	al,ds:gvar_dlg_cols
		dec	al
		cmp	ds:save_del_flag,al
		jae	nameinput_sel_dn			; Jump if above or =
		mov	bl,ds:save_del_flag
		call	word ptr cs:save_scroll_dn_fn
		inc	byte ptr ds:save_del_flag
		retn

nameinput_sel_dn:
		push	di
		push	si
		inc	byte ptr ds:gvar_sel_row
		mov	al,ds:gvar_sel_row
		add	al,ds:save_del_flag
		call	word ptr cs:gfx_sel_init_fn
		mov	cx,0Ah

nameinput_dn_anim:
								push	cx
								mov	bx,ds:gvar_dlg_pos
								add	bx,301h
								mov	al,cl
								neg	al
								add	al,0Ah
								mov	cl,ds:gvar_dlg_cols
								add	cl,cl
								mov	dl,cl
								add	cl,cl
								add	cl,cl
								add	cl,dl
								sub	cl,2
								mov	ch,ds:gvar_dlg_timer
								call	word ptr cs:gfx_sel_scroll_dn_fn

nameinput_dn_wait:
														cmp	byte ptr ds:gvar_frame_timer,4
														jb	nameinput_dn_wait			; Jump if below
								mov	byte ptr ds:gvar_frame_timer,0
								pop	cx
								loop	nameinput_dn_anim		; Loop if cx > 0

		pop	si
		pop	di
		retn

player_func_55		proc	near

cursor_draw:
		push	si
		push	ax
		mov	ax,ds:save_cursor_x
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	al,ds:save_name_len
		add	al,al
		add	bh,al
		mov	bl,ds:save_cursor_y
		add	bl,8
		mov	cx,208h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fill_fn
		pop	ax
		add	ds:save_name_len,al
		test	byte ptr ds:save_name_len,80h
		jz	cursor_no_overflow			; Jump if zero
		mov	byte ptr ds:save_name_len,0

cursor_no_overflow:
		cmp	byte ptr ds:save_name_len,8
		jb	cursor_clamp			; Jump if below
		dec	byte ptr ds:save_name_len

cursor_clamp:
		mov	al,ds:save_name_maxlen
		cmp	ds:save_name_len,al
		jb	cursor_place			; Jump if below
		mov	ds:save_name_len,al

cursor_place:
		mov	bx,ds:save_cursor_x
		mov	cl,ds:save_cursor_y
		xor	ax,ax			; Zero register
		mov	al,ds:save_name_len
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	cl,8
		mov	ax,67Fh
		call	word ptr cs:gfx_draw_char_fn
		pop	si
		retn

player_func_55		endp

player_func_56		proc	near
		push	si
		mov	ax,ds:save_cursor_x
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:save_cursor_y
		mov	cx,1008h
		xor	al,al			; Zero register
		call	word ptr cs:gfx_fill_fn
		mov	bx,ds:save_cursor_x
		mov	cl,ds:save_cursor_y
		mov	si,save_name_buf
		call	word ptr cs:gfx_draw_str_fn
		pop	si
		retn

player_func_56		endp

backspace_exec:
		call	fill_buffer_2
		push	si
		mov	bl,ds:save_name_len
		or	bl,bl			; Zero ?
		jnz	backspace_nonempty			; Jump if not zero
		inc	bl

backspace_nonempty:
		xor	bh,bh			; Zero register
		push	cs
		pop	es
		mov	si,save_name_buf
		add	si,bx
		mov	di,si
		dec	di
		mov	al,8
		sub	al,bl
		mov	cl,al
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:save_name_maxlen,0FFh
		jz	backspace_done			; Jump if zero
		dec	byte ptr ds:save_name_maxlen

backspace_done:
		mov	byte ptr ds:save_name_end,60h	; '`'
		mov	al,0FFh
		call	player_func_55
		call	player_func_56
		pop	si
		retn

player_copy_buf		endp

		; town_tile_attr_tbl: tile attribute / sector lookup table (town walking grid)
		; Each value 0..8 is a tile-class index used by player movement / NPC spawn checks.
		db	0, 2, 2, 3, 1, 0	; row 0  (cols 0-5)
		db	0, 2, 2, 3, 1, 1	; row 1  (cols 0-5)
		db	1, 2, 2, 0, 1, 2	; row 2  (cols 0-5)
		db	8 dup (1)		; row 3  (8 cols of class 1)
		db	3, 2, 1, 1, 2, 1	; row 4  (cols 0-5)
		db	9 dup (0)		; row 5  (9 cols of class 0)
		db	2, 0			; row 6  (cols 0-1)
		db	9 dup (0)		; row 7  (9 cols of class 0)
		db	1, 0, 0, 0, 0, 0	; row 8
		db	1, 2, 2, 2, 1, 1	; row 9
		db	1, 0, 0, 1, 0, 1	; row 10
		db	1, 0, 0, 2, 1, 0	; row 11
		db	2, 0, 1, 1, 0, 0	; row 12
		db	0, 1, 1, 0, 0, 0	; row 13
		db	1, 1, 1, 2, 0, 3	; row 14
		db	1, 0, 5, 4, 4, 4	; row 15
		db	6, 8, 5, 3, 4, 4	; row 16
		db	6, 6, 6, 5, 6, 8	; row 17
		db	7, 5, 7, 7, 7, 7	; row 18
		db	7, 7, 7, 7, 3, 4	; row 19
		db	6, 6, 6, 7		; row 20
		db	9 dup (8)		; row 21 (9 cols of class 8)
		db	5, 8, 8			; row 22
		db	8 dup (8)		; row 23 (8 cols of class 8)
		db	7, 8, 8, 8, 8, 8	; row 24
		db	7, 5, 3, 5, 6, 7	; row 25
		db	7, 8, 8, 7, 8, 7	; row 26
		db	7, 8, 8, 5, 6, 8	; row 27
		db	5, 8, 7, 7, 8, 8	; row 28
		db	8, 7, 6, 8, 8, 8	; row 29
		db	7, 7, 7, 4, 8, 4	; row 30
		db	7, 8, 0			; row 31
		db	58 dup (0)		; trailing zero pad to align block

seg_a		ends

		end	start
