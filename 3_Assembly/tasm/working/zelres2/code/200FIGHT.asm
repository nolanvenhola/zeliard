
PAGE  59,132

;==========================================================================
;
;  MAIN_GAME_LOOP - Code Module
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; Mapped addresses (auto-fixed from original chunk)
game_func_142		equ	036E8h

; The following equates show data references outside the range of the program.

enemy_id_table		equ	8000h			;*
fire1_slot_table		equ	8018h			;*
fire2_slot_table		equ	801Ch			;*
atk_slot_table		equ	8020h			;*
move_slot_a_table		equ	8024h			;*
move_slot_b_table		equ	8028h			;*
move_slot_c_table		equ	802Ch			;*
entity_ptr_table		equ	0B002h			;*
world_state_base		equ	0C000h			;*
sprite_load_dest	equ	4000h			;*
scroll_dispatch_a	equ	6CFEh			;*
scroll_dispatch_b	equ	6D17h			;*
area_lookup_tbl	equ	7516h			;*
entity_dispatch_tbl	equ	76CEh			;*
atk_speed_tbl_a	equ	77C7h			;*
atk_speed_tbl_b	equ	77D7h			;*
combat_data_tbl	equ	79B4h			;*
combat_byte_a	equ	79B6h			;*
combat_byte_b	equ	79CAh			;*
entity_fn_tbl_a	equ	8244h			;*
entity_type_map	equ	83D7h			;*
entity_fn_tbl_b	equ	8581h			;*
entity_fn_tbl_c	equ	85C2h			;*
entity_rotate_buf	equ	85EEh			;*
entity_data_base	equ	8790h			;*
entity_fn_tbl_d	equ	883Fh			;*
boss_data_buf	equ	8C79h			;*
boss_sprite_buf	equ	8C8Dh			;*
entity_fn_tbl_e	equ	8F33h			;*
boss_render_buf	equ	90CAh			;*
collision_map_tbl	equ	9185h			;*
entity_state_tbl	equ	920Ah			;*
entity_attr_tbl	equ	9234h			;*
entity_fn_tbl_f	equ	972Fh			;*
boss_fn_tbl	equ	9788h			;*
anim_frame_tbl_a	equ	98B8h			;*
anim_frame_tbl_b	equ	98BEh			;*
hitbox_map_tbl	equ	9985h			;*
spawn_data_tbl	equ	9C1Eh			;*
anim_ctr_x	equ	9EEDh			;*
anim_ctr_y	equ	9EEEh			;*
enemy_scroll_flag	equ	9EEFh			;*
player_scroll_flag	equ	9EF0h			;*
scroll_row_cnt	equ	9EF1h			;*
scroll_bx_save	equ	9EF2h			;*
scroll_cx_save	equ	9EF4h			;*
combat_active	equ	9EF5h			;*
combat_flag2	equ	9EF6h			;*
tile_set_id	equ	9EF7h			;*
player_chr_id	equ	9EF8h			;*
player_spr_id	equ	9EF9h			;*
music_track_id	equ	9EFAh			;*
prev_chr_id	equ	9EFEh			;*
prev_spr_id	equ	9EFFh			;*
room_count	equ	9F00h			;*
loaded_flag	equ	9F01h			;*
loading_flag	equ	9F02h			;*
map_cur_ptr	equ	9F03h			;*
scroll_cur_ptr	equ	9F05h			;*
state_byte_9F07	equ	9F07h			;*
state_byte_9F08	equ	9F08h			;*
hp_countdown	equ	9F09h			;*
frame_parity	equ	9F0Ah			;*
action_pending	equ	9F0Bh			;*
hp_midpoint	equ	9F0Ch			;*
hp_max	equ	9F0Dh			;*
entity_slot_tbl	equ	9F0Eh			;*
state_word_9F10	equ	9F10h			;*
state_word_9F12	equ	9F12h			;*
any_entity_active	equ	9F14h			;*
escape_flag	equ	9F15h			;*
state_byte_9F16	equ	9F16h			;*
state_byte_9F17	equ	9F17h			;*
state_byte_9F18	equ	9F18h			;*
state_byte_9F19	equ	9F19h			;*
scroll_count	equ	9F1Ah			;*
scroll_dir	equ	9F1Ch			;*
state_byte_9F1D	equ	9F1Dh			;*
state_byte_9F1E	equ	9F1Eh			;*
state_byte_9F1F	equ	9F1Fh			;*
invul_timer	equ	9F20h			;*
pending_invul	equ	9F21h			;*
move_dir	equ	9F22h			;*
move_axis	equ	9F23h			;*
input_prev	equ	9F24h			;*
frame_ctr	equ	9F25h			;*
scene_trans_flag	equ	9F26h			;*
level_load_flag	equ	9F27h			;*
state_byte_9F28	equ	9F28h			;*
state_byte_9F29	equ	9F29h			;*
state_byte_9F2A	equ	9F2Ah			;*
state_byte_9F2B	equ	9F2Bh			;*
atk_dist_x	equ	9F2Ch			;*
atk_dist_y	equ	9F2Dh			;*
entity_extra_tbl	equ	9F85h			;*
game_fn_vtable	equ	0A000h			;*
obj_data_ptr	equ	0A002h			;*
render_dest_ptr	equ	0A006h			;*
tile_data_ptr	equ	0A008h			;*
tile_type_map	equ	0A010h			;*
map_data_ptr	equ	0C000h			;*
map_width	equ	0C002h			;*
map_top_ptr	equ	0C004h			;*
map_bot_ptr	equ	0C006h			;*
map_extra_ptr	equ	0C008h			;*
map_seg_ptr	equ	0C00Ch			;*
bg_data_ptr	equ	0C00Eh			;*
object_list_ptr	equ	0C010h			;*
area_num	equ	0C012h			;*
target_id	equ	0C013h			;*
target_y	equ	0C015h			;*
player_y	equ	0C016h			;*
state_byte_C017	equ	0C017h			;*
scroll_end_ptr	equ	0C019h			;*
map_col_ptr	equ	0C01Bh			;*
scroll_buf	equ	0E000h			;*
scroll_buf_p1	equ	0E001h			;*
scroll_buf_end1	equ	0E8FEh			;*
scroll_buf_end	equ	0E8FFh			;*
hud_buf	equ	0E900h			;*
hud_enemy_area	equ	0E921h			;*
hud_player_area	equ	0E939h			;*
sprite_work_buf	equ	0EB60h			;*
enemy_data_buf	equ	0EB80h			;*
enemy_data_ext	equ	0ED20h			;*
enemy_data_buf2	equ	0EDA0h			;*
gvar_timer_ff08	equ	0FF08h			;* was gvar_timer_ticks
gvar_timer_counter	equ	0FF18h			;*
gvar_frame_timer	equ	0FF1Ah			;*
gvar_skip_input	equ	0FF1Dh			;*
gvar_state_b	equ	0FF1Eh			;*
gvar_state_FF24	equ	0FF24h			;*
gvar_game_seg	equ	0FF2Ch			;*
gvar_flag_FF2E	equ	0FF2Eh			;*
gvar_flag_FF2F	equ	0FF2Fh			;*
gvar_flag_FF30	equ	0FF30h			;*
gvar_scroll_pos	equ	0FF31h			;*
gvar_save_flag	equ	0FF33h			;*
gvar_save_flag_1	equ	0FF34h			;*
gvar_save_flag_2	equ	0FF35h			;*
gvar_save_flag_3	equ	0FF36h			;*
gvar_save_flag_4	equ	0FF37h			;*
gvar_music_flag_a	equ	0FF38h			;*
gvar_music_flag_b	equ	0FF39h			;*
gvar_music_flag_c	equ	0FF3Ah			;*
gvar_palette_flag	equ	0FF3Ch			;*
gvar_combat_ff3D	equ	0FF3Dh			;*
gvar_flag_FF3E	equ	0FF3Eh			;*
gvar_flag_FF3F	equ	0FF3Fh			;*
gvar_debug_mode	equ	0FF40h			;*
gvar_flag_FF41	equ	0FF41h			;*
gvar_debug_val	equ	0FF42h			;*
gvar_joystick_flag	equ	0FF43h			;*
gvar_flag_FF44	equ	0FF44h			;*
gvar_flag_FF45	equ	0FF45h			;*
gvar_flag_FF46	equ	0FF46h			;*
gvar_flag_FF47	equ	0FF47h			;*
gvar_flag_FF4A	equ	0FF4Ah			;*
gvar_flag_FF4B	equ	0FF4Bh			;*
gvar_volume_b	equ	0FF75h			;*

music_ref_tbl		equ	9E53h			;* chunk ref table base for music tracks (indexed by id*11)
sar_ref_bg		equ	9BF1h			;* SAR reference pointer for background load
spr_ref_tbl		equ	9D8Dh			;* chunk ref table base for sprite sets (indexed by spr_id*11)
joy_port_a		equ	629Ch			;* joystick port A (int 61h arg)
joy_port_b		equ	65BAh			;* joystick port B (int 61h arg)
joy_port_c		equ	69E0h			;* joystick port C (int 61h arg)
scroll_init_a		equ	6C44h			;* scroll initialisation data table A
scroll_init_b		equ	6C4Ch			;* scroll initialisation data table B
scroll_init_c		equ	6C8Fh			;* scroll initialisation data table C
entity_snd_tbl		equ	9BB9h			;* entity sound/AI data table
enemy_ai_data		equ	9BCBh			;* enemy AI data (dead code ref)
entity_fn_a		equ	7651h			;* entity dispatch function A
entity_fn_b		equ	763Eh			;* entity dispatch function B
level_ref_a		equ	601Ch			;* level start SAR reference A
scroll_tile_src		equ	6333h			;* scroll tile source data base
hit_snd_ref		equ	9AC5h			;* hit sound data reference
sar_ref_scroll		equ	9BE6h			;* SAR reference for scroll chunk
sar_ref_enemy		equ	9BFDh			;* SAR reference for enemy/boss map chunk
sar_ref_boss		equ	9C08h			;* SAR reference for boss data chunk
sar_ref_map		equ	9C2Dh			;* SAR reference for map tile chunk
sar_ref_tileset		equ	9C43h			;* SAR reference for tileset chunk
chr_ref_tbl		equ	9CBCh			;* chunk ref table base for character sprites (indexed by chr_id*11)

; Load a SAR chunk into the game segment.
; SI must already point to the SAR chunk reference descriptor.
; ES:DI = destination in game segment, AL = archive type (2=zelres2, 5=other).
LOAD_CHUNK_ES   MACRO   dest_offset, archive
                mov     es, cs:gvar_game_seg
                mov     di, dest_offset
                mov     al, archive
                call    word ptr cs:[10Ch]
                ENDM

; Load a SAR chunk using a reference table.
; AX must already contain BL * stride (from preceding 'mul bl').
; ref_tbl = EQU for the table base address.
LOAD_CHUNK_REF  MACRO   ref_tbl, dest_offset, archive
                add     ax, ref_tbl
                mov     si, ax
                LOAD_CHUNK_ES dest_offset, archive
                ENDM

; Swap SI/DI, add offset to SI, call fn, restore SI/DI.
; Used for tile/sprite coordinate offset operations.
SWAP_CALL       MACRO   ofs, fn
                xchg    si, di
                add     si, ofs
                call    fn
                xchg    si, di
                ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zr2_00		proc	far

start:
; Module init header: word-pair table of internal function addresses
; (loaded by zeliad dispatcher; each pair is an offset in this code segment)
		dw	3F2Eh		; init fn 0
		dw	0000h		; init fn 1
		dw	6042h		; init fn 2
		dw	79DCh		; init fn 3
		dw	9723h		; init fn 4
		dw	973Fh		; init fn 5
		dw	91E5h		; init fn 6
		dw	91F6h		; init fn 7
		dw	920Ah		; init fn 8
		dw	9222h		; init fn 9
		dw	9234h		; init fn 10
		dw	9243h		; init fn 11
		dw	9255h		; init fn 12
		dw	926Ch		; init fn 13
		dw	92B4h		; init fn 14
		dw	930Ah		; init fn 15
		dw	9362h		; init fn 16
		dw	939Ah		; init fn 17
		dw	93C5h		; init fn 18
		dw	940Ch		; init fn 19
		dw	9452h		; init fn 20
		dw	949Ah		; init fn 21
		dw	6D6Eh		; init fn 22
		dw	6D82h		; init fn 23
		dw	6D8Eh		; init fn 24
		dw	94E1h		; init fn 25
		dw	97A0h		; init fn 26
		dw	96D5h		; init fn 27
		dw	97B5h		; init fn 28
		dw	96A1h		; init fn 29
		dw	9851h		; init fn 30
		dw	8611h		; init fn 31
		dw	83DBh		; init fn 32
		dw	98C5h		; init fn 33
		dw	975Bh		; init fn 34

module_init:
		cli				; Disable interrupts
		mov	sp,2000h
		sti				; Enable interrupts
		push	cs
		pop	ds
		mov	byte ptr ds:invul_timer,0
		mov	byte ptr ds:pending_invul,0
		mov	byte ptr ds:move_dir,0
		mov	ax,0FFFFh
		mov	ds:enemy_data_buf,al
		mov	ds:enemy_data_buf2,al
		mov	word ptr ds:[0EB15h],ax
		mov	byte ptr ds:gvar_flag_FF2E,0
		mov	byte ptr ds:gvar_flag_FF2F,0
		mov	byte ptr ds:gvar_flag_FF30,0
		mov	byte ptr ds:loaded_flag,0
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jnz	save_game_load			; Jump if not zero
		jmp	new_game_init

save_game_load:
		call	game_func_29
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:loading_flag,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF music_ref_tbl, 3000h, 5
		mov	si,sar_ref_bg
		LOAD_CHUNK_ES sprite_load_dest, 2
		call	word ptr cs:gfx_fn_clear
		mov	byte ptr ds:gvar_save_flag_4,0
		call	word ptr cs:gfx_fn_render_bg
		call	word ptr cs:gfx_fn_map_load
		call	game_multiply_2
		mov	byte ptr ds:loading_flag,0
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	cx,6

timer_wait_loop:
										push	cx
										mov	byte ptr ds:gvar_frame_timer,0

frame_wait_loop_a:
																		cmp	byte ptr ds:gvar_frame_timer,41h	; 'A'
																		jb	frame_wait_loop_a			; Jump if below
										mov	bx,0C28h
										mov	cx,3828h
										xor	al,al			; Zero register
										call	word ptr cs:[2000h]
										mov	byte ptr ds:gvar_frame_timer,0

frame_wait_loop_b:
																		cmp	byte ptr ds:gvar_frame_timer,41h	; 'A'
																		jb	frame_wait_loop_b			; Jump if below
										call	word ptr cs:gfx_fn_clear
										pop	cx
										loop	timer_wait_loop		; Loop if cx > 0

		mov	si,ds:map_data_ptr
		add	si,5
		mov	al,[si]
		mov	[si-1],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,spr_ref_tbl
		mov	si,ax

zr2_00		endp

vga_operation		proc	near
		LOAD_CHUNK_ES sprite_load_dest, 2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,sprite_load_dest
		mov	bp,game_fn_vtable
		mov	cx,100h
		call	word ptr cs:gfx_fn_memcpy
		pop	ds

main_loop_entry:
		mov	si,ds:obj_data_ptr
		add	si,8
		lodsb				; String [si] to al
		mov	ds:loaded_flag,al
		mov	si,[si]
		call	word ptr cs:[2010h]
		mov	si,ds:obj_data_ptr
		add	si,3
		mov	bx,[si]
		push	bx
		call	word ptr cs:[200Ah]
		pop	bx
		call	word ptr cs:[200Ch]
		jmp	short main_loop_body

new_game_init:
		call	word ptr cs:[2012h]
		call	game_get_value_2
		mov	si,ds:bg_data_ptr
		call	word ptr cs:[2010h]
		call	word ptr cs:[2016h]

main_loop_body:
		call	word ptr cs:[2006h]
		call	word ptr cs:[2008h]
		call	word ptr cs:[2014h]
		test	byte ptr ds:[0E6h],0FFh
		jnz	scene_transition			; Jump if not zero
		jmp	normal_frame

scene_transition:
		mov	byte ptr ds:scene_trans_flag,0FFh
		mov	word ptr ds:[80h],29h
		mov	byte ptr ds:[83h],5
		call	vga_operation0
		call	fill_buffer

scene_exit_wait:
										call	game_check_state_3
										test	byte ptr ds:[0E6h],0FFh
										jnz	scene_exit_wait			; Jump if not zero
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds
		mov	byte ptr ds:loading_flag,0
		mov	ah,1Eh
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	byte ptr ds:gvar_save_flag_1,0FFh
		mov	byte ptr ds:level_load_flag,0FFh
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		call	copy_buffer
		call	vga_operation_2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:gfx_fn_map_scroll
		pop	ds
		push	ds
		call	word ptr cs:gfx_fn_palette
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	word ptr ds:scroll_count,18h
		mov	byte ptr ds:scroll_dir,0Dh
		mov	byte ptr ds:[83h],0Ch
		mov	byte ptr ds:room_count,0Ch
		call	game_func_70
		call	game_func_29
		jmp	main_loop_entry

normal_frame:
		call	vga_operation0
		test	byte ptr ds:level_load_flag,0FFh
		jz	check_new_game			; Jump if zero
		call	fill_buffer
		call	game_check_state_3
		mov	byte ptr ds:scene_trans_flag,0
		jmp	short check_game_over

check_new_game:
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	fill_and_clear			; Jump if zero
		call	word ptr cs:gfx_fn_init

fill_and_clear:
		call	fill_buffer
		call	clear_buffer

check_game_over:
		test	byte ptr ds:[49h],0FFh
		jz	check_loading			; Jump if zero
		jmp	game_over_sequence

check_loading:
		test	byte ptr ds:loading_flag,0FFh
		jz	clear_skip_state			; Jump if zero
		mov	byte ptr ds:loading_flag,0
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,3000h
		xor	ax,ax			; Zero register
		int	60h			; ??INT Non-standard interrupt
		pop	ds

clear_skip_state:
		xor	al,al			; Zero register
		mov	ds:gvar_skip_input,al
		mov	ds:gvar_state_b,al
		mov	byte ptr ds:gvar_frame_timer,0
		mov	byte ptr ds:level_load_flag,0

frame_loop:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jnz	music_active_branch			; Jump if not zero
		call	game_func_43
		call	game_func_9
		call	game_check_state_3
;*		call	game_func_107			;*
		call	sub_27B4
		db	00Ch			; was: db 0E8h, 001h, 025h
		call	game_func_7
		call	game_func_8
		inc	byte ptr ds:frame_parity
		cmp	byte ptr ds:frame_parity,2
		jne	check_joystick			; Jump if not equal
		mov	byte ptr ds:gvar_music_flag_a,0

check_joystick:
		mov	dx,joy_port_a
		push	dx
		int	61h			; ??INT Non-standard interrupt
		test	al,2
		jz	call_frame_check			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh

call_frame_check:
		call	game_func_20
		call	game_check_state
		retn

music_active_branch:
																		mov	byte ptr ds:gvar_music_flag_a,0
																		mov	byte ptr ds:gvar_combat_ff3D,0
																		mov	byte ptr ds:gvar_debug_val,0
																		mov	byte ptr ds:gvar_palette_flag,0
																		call	word ptr cs:gfx_fn_render_tile
																		mov	byte ptr ds:gvar_joystick_flag,0
																		call	game_check_state_3
																		call	game_func_8
																		call	game_check_state
																		cmp	byte ptr ds:gvar_music_flag_b,0FFh
																		jne	music_end_cleanup			; Jump if not equal
																		call	vga_operation8
																		inc	si
																		call	game_get_value
																		jc	music_active_branch			; Jump if carry Set
										add	si,24h
										call	vga_operation5
										call	game_get_value
										jc	music_active_branch			; Jump if carry Set

music_end_cleanup:
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:gvar_music_flag_b,0
		mov	byte ptr ds:gvar_skip_input,0
		mov	byte ptr ds:gvar_state_b,0
		mov	byte ptr ds:invul_timer,0
		mov	byte ptr ds:pending_invul,0
		mov	byte ptr ds:[0E7h],7Fh
		jmp	frame_loop

vga_operation		endp

game_check_state		proc	near
		mov	byte ptr ds:move_dir,0
		int	61h			; ??INT Non-standard interrupt
		cmp	al,5
		jne	check_state_9			; Jump if not equal
		jmp	state5_branch

check_state_9:
		cmp	al,9
		jne	check_state_1			; Jump if not equal
		jmp	state9_branch

check_state_1:
		cmp	al,1
		jne	check_combat_mode			; Jump if not equal
		jmp	state1_entry

check_combat_mode:
		mov	ah,al
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jnz	input_compare			; Jump if not zero
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	input_compare			; Jump if zero
		test	byte ptr ds:action_pending,0FFh
		jnz	action_pending_check			; Jump if not zero
		jmp	fight_reset_soft

action_pending_check:
		mov	byte ptr ds:action_pending,0
		test	byte ptr ds:[0C2h],2
		jnz	check_player_side			; Jump if not zero
		jmp	fight_reset_soft

check_player_side:
		mov	dx,joy_port_b
		push	dx
		test	byte ptr ds:[0C2h],1
		jnz	dispatch_advance			; Jump if not zero
		jmp	scroll_retreat

dispatch_advance:
		jmp	player_action_taken

input_compare:
		push	ax
		mov	al,byte ptr ds:[0C2h]
		and	al,1
		cmp	al,ds:input_prev
		mov	ds:input_prev,al
		jz	input_changed			; Jump if zero
		call	game_func_10

input_changed:
		pop	ax
		mov	al,ah
		push	ax
		cmp	al,2
		jne	check_state_2			; Jump if not equal
		call	game_func_22

check_state_2:
		pop	ax
		and	al,0Ch
		cmp	al,4
		jne	check_state_8			; Jump if not equal
		jmp	player_action_taken

check_state_8:
		cmp	al,8
		jne	call_func10			; Jump if not equal
		jmp	scroll_retreat

call_func10:
		call	game_func_10
		mov	al,ds:gvar_music_flag_b
		or	al,ds:gvar_music_flag_a
		jz	set_e7_80			; Jump if zero
		retn

set_e7_80:
		mov	byte ptr ds:[0E7h],80h
		retn

game_func_7:
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jz	check_music_a			; Jump if zero
		retn

check_music_a:
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	check_combat_ff3d			; Jump if zero
		retn

check_combat_ff3d:
		call	vga_operation8
		mov	al,[si]
		call	game_check_state_2
		jnz	check_forward_dir			; Jump if not zero
		retn

check_forward_dir:
		inc	si
		inc	si
		mov	al,[si]
		call	game_check_state_2
		jnz	check_back_dir			; Jump if not zero
		retn

check_back_dir:
		add	si,24h
		call	vga_operation5
		mov	al,[si]
		call	game_check_state_2
		jz	jmp_loc124			; Jump if zero
		jmp	scroll_pos_dec

jmp_loc124:
		jmp	scroll_pos_inc

game_func_8:
		test	byte ptr ds:any_entity_active,0FFh
		jnz	check_loaded			; Jump if not zero
		retn

check_loaded:
		test	byte ptr ds:loaded_flag,0FFh
		jnz	check_music_b			; Jump if not zero
		mov	si,entity_slot_tbl
		mov	al,[si]
		or	al,[si+1]
		mov	ah,[si+2]
		or	ah,[si+3]
		test	al,ah
		jz	check_any_slot			; Jump if zero
		test	byte ptr ds:[0C2h],1
		jnz	check_music_b			; Jump if not zero
		jmp	short check_music_b2

check_any_slot:
		or	al,al			; Zero ?
		jnz	check_music_b2			; Jump if not zero

check_music_b:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	double_func15			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		or	byte ptr ds:[0C2h],1
		mov	byte ptr ds:gvar_combat_ff3D,7Fh
		mov	byte ptr ds:gvar_skip_input,0

double_func15:
		call	game_func_15
		call	game_func_15
		jmp	short check_combat_end

check_music_b2:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	double_process			; Jump if zero
		and	byte ptr ds:[0C2h],0FCh
		mov	byte ptr ds:gvar_combat_ff3D,7Fh
		mov	byte ptr ds:gvar_skip_input,0

double_process:
		call	game_process_loop
		call	game_process_loop
		jmp	short check_combat_end

check_combat_end:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_escape			; Jump if zero
		mov	byte ptr ds:gvar_music_flag_b,80h
		mov	byte ptr ds:gvar_combat_ff3D,0

check_escape:
		test	byte ptr ds:escape_flag,0FFh
		jz	check_combat_80			; Jump if zero
		retn

check_combat_80:
		test	byte ptr ds:gvar_combat_ff3D,80h
		jz	check_hp_clamp			; Jump if zero
		retn

check_hp_clamp:
		call	game_func_24
		jnc	check_hp_countdown			; Jump if carry=0
		retn

check_hp_countdown:
		test	byte ptr ds:hp_countdown,0FFh
		jnz	decrement_hp			; Jump if not zero
		jmp	process_loop_end

decrement_hp:
		dec	byte ptr ds:hp_countdown
		inc	byte ptr ds:[84h]
		retn

game_func_9:
		call	vga_operation7
		jz	check_combat_ff3d_b			; Jump if zero
		retn

check_combat_ff3d_b:
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	check_invul			; Jump if zero
		retn

check_invul:
		test	byte ptr ds:invul_timer,0FFh
		jnz	decrement_invul			; Jump if not zero
		retn

decrement_invul:
		dec	byte ptr ds:invul_timer
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	al,[si]
		cmp	al,40h			; '@'
		jb	check_move_axis			; Jump if below
		cmp	al,49h			; 'I'
		jae	check_move_axis			; Jump if above or =
		mov	byte ptr ds:invul_timer,0
		retn

check_move_axis:
		mov	al,ds:move_dir
		test	byte ptr ds:move_axis,1
		jz	check_move_dir2			; Jump if zero
		cmp	al,1
		jne	jmp_map_scan			; Jump if not equal
		retn

jmp_map_scan:
		jmp	map_scan_loop_entry

check_move_dir2:
		cmp	al,2
		jne	jmp_scroll_adv			; Jump if not equal
		retn

jmp_scroll_adv:
		jmp	scroll_advance

game_func_10:
		call	vga_operation7
		jz	check_invul_b			; Jump if zero
		retn

check_invul_b:
		test	byte ptr ds:invul_timer,0FFh
		jz	check_music_b3			; Jump if zero
		retn

check_music_b3:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_pending			; Jump if zero
		retn

check_pending:
		mov	al,ds:pending_invul
		shr	al,1			; Shift w/zeros fill
		or	al,al			; Zero ?
		jnz	clamp_invul			; Jump if not zero
		retn

clamp_invul:
		cmp	al,0Ah
		jb	set_invul			; Jump if below
		mov	al,0Ah

set_invul:
		mov	ds:invul_timer,al
		mov	byte ptr ds:pending_invul,0
		retn

state1_entry:
		mov	byte ptr ds:state_byte_9F18,0
		call	game_func_69
		call	game_func_80
		call	game_func_12

game_func_11:
		inc	byte ptr ds:invul_timer
		cmp	byte ptr ds:invul_timer,0Ah
		jb	invul_clamped			; Jump if below
		mov	byte ptr ds:invul_timer,0Ah

invul_clamped:
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_music_b4			; Jump if zero
		retn

check_music_b4:
		mov	byte ptr ds:gvar_music_flag_a,0
		mov	al,ds:hp_countdown
		cmp	al,ds:hp_max
		jae	fight_reset_soft			; Jump if above or =
		call	vga_operation8
		sub	si,23h
		call	vga_operation6
		mov	al,[si]
		call	game_check_state_2
		jnz	check_hp_zero			; Jump if not zero
		mov	byte ptr ds:[0E7h],0
		and	byte ptr ds:[0C2h],0FDh
		mov	byte ptr ds:gvar_combat_ff3D,0FFh
		mov	al,ds:hp_max
		shr	al,1			; Shift w/zeros fill
		mov	ds:hp_midpoint,al
		inc	byte ptr ds:hp_countdown
		cmp	byte ptr ds:[84h],7
		jae	decrement_84			; Jump if above or =
		jmp	pos_scroll_up

decrement_84:
		dec	byte ptr ds:[84h]
		retn

check_hp_zero:
		test	byte ptr ds:hp_countdown,0FFh
		jnz	fight_reset_soft			; Jump if not zero
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	set_e7_80b			; Jump if zero
		retn

set_e7_80b:
		mov	byte ptr ds:[0E7h],80h
		retn

fight_reset_soft:
		mov	byte ptr ds:gvar_debug_val,0
		mov	byte ptr ds:gvar_combat_ff3D,7Fh
		retn

game_func_12:
		call	vga_operation8
		inc	si
		call	game_get_value
		jc	set_music_loop			; Jump if carry Set
		dec	si
		call	game_get_value
		jnc	check_si_plus2			; Jump if carry=0
		test	byte ptr ds:[0C2h],1
		jnz	player_action_taken			; Jump if not zero
		retn

check_si_plus2:
		inc	si
		inc	si
		call	game_get_value
		jc	check_player_side2			; Jump if carry Set
		retn

check_player_side2:
		test	byte ptr ds:[0C2h],1
		jnz	retain_retreat		; Jump if not zero
		jmp	scroll_retreat

retain_retreat:
		retn

set_music_loop:
		mov	byte ptr ds:gvar_music_flag_b,0FFh
		mov	byte ptr ds:gvar_music_flag_a,0

music_anim_loop:
										call	vga_operation8
										sub	si,23h
										call	vga_operation6
										dec	byte ptr ds:[0E7h]
										call	game_get_value
										jc	func13_and_state			; Jump if carry Set
										or	byte ptr ds:[0E7h],1
										retn

func13_and_state:
										call	game_func_13
										call	game_check_state_3
										test	byte ptr ds:[0E7h],1
										jz	jmp_back_music_loop			; Jump if zero
										retn

jmp_back_music_loop:
										jmp	short music_anim_loop

game_func_13:

pos_scroll_up:
		dec	byte ptr ds:[82h]
		mov	si,ds:gvar_scroll_pos
		sub	si,24h
		call	vga_operation6
		mov	ds:gvar_scroll_pos,si
		retn

state5_branch:
		mov	byte ptr ds:action_pending,0FFh
		call	game_func_11
		jmp	short player_action_taken

player_action_taken:
		mov	byte ptr ds:state_byte_9F18,0
		test	byte ptr ds:[0C2h],1
		jnz	check_music_a2			; Jump if not zero
		jmp	toggle_c2_bit

check_music_a2:
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jz	check_debug1			; Jump if zero
		retn

check_debug1:
		cmp	byte ptr ds:gvar_debug_val,1
		jne	call_func15_check			; Jump if not equal
		jmp	clear_c2_bit

call_func15_check:
		call	game_func_15
		jnc	set_move_dir2			; Jump if carry=0
		jmp	clear_c2_bit

set_move_dir2:
		mov	byte ptr ds:move_dir,2
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_vga7			; Jump if zero
		retn

check_vga7:
		call	vga_operation7
		jnz	set_c2_bit2			; Jump if not zero
		test	byte ptr ds:invul_timer,0FFh
		jnz	set_c2_bit2			; Jump if not zero
		mov	byte ptr ds:move_axis,0
		inc	byte ptr ds:pending_invul

set_c2_bit2:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	inc_e7			; Jump if zero
		retn

inc_e7:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:state_byte_9F19,0
		retn

game_func_15:

scroll_advance:
		call	vga_operation8
		mov	di,si
		sub	si,24h
		call	vga_operation6
		dec	si
		mov	cx,4

tile_scan_4:
										call	vga_operation9
										add	al,al
										jnc	advance_si			; Jump if carry=0
										retn

advance_si:
										add	si,24h
										call	vga_operation5
										loop	tile_scan_4		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jnz	scan_2more			; Jump if not zero
		mov	al,[si]
		call	game_check_state_2
		stc				; Set carry flag
		jz	call_func16			; Jump if zero
		retn

call_func16:
		call	game_func_16
		jnc	scan_2more			; Jump if carry=0
		retn

scan_2more:
		mov	cx,2

scan_2_tiles:
										add	si,24h
										call	vga_operation5
										mov	al,[si]
										call	game_func_42
										stc				; Set carry flag
										jz	push_call16			; Jump if zero
										retn

push_call16:
										push	cx
										call	game_func_16
										pop	cx
										jnc	loop_continue			; Jump if carry=0
										retn

loop_continue:
										loop	scan_2_tiles		; Loop if cx > 0

scroll_pos_dec:
		dec	word ptr ds:[80h]
;*		cmp	word ptr ds:[80h],0FFFFh
			db	83h, 3Eh, 80h, 00h, 0FFh		; cmp word ptr [80h], -1 (sign-extended)
		jnz	scroll_wrap_check			; Jump if not zero
		mov	ax,ds:map_width
		dec	ax
		mov	word ptr ds:[80h],ax
		mov	si,ds:scroll_end_ptr
		mov	ds:map_cur_ptr,si

scroll_wrap_check:
		push	cs
		pop	es
		std				; Set direction flag
		mov	si,scroll_buf_end1
		mov	di,scroll_buf_end
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		mov	si,ds:map_cur_ptr
		dec	si
		mov	di,0E8DCh
		xor	dl,dl			; Zero register

fill_column_loop:
										call	vga_operation2
										dec	si
										add	dl,bh

fill_cell_loop:
																		mov	[di],bl
																		sub	di,24h
																		dec	bh
																		jnz	fill_cell_loop			; Jump if not zero
										cmp	dl,40h			; '@'
										jb	fill_column_loop			; Jump if below
		inc	si
		mov	ds:map_cur_ptr,si
		mov	si,ds:scroll_end_ptr
		dec	si
		mov	ax,word ptr ds:[80h]
		add	ax,24h
		cmp	ax,ds:map_width
		je	scroll_cur_update			; Jump if equal
		mov	si,ds:scroll_cur_ptr
		xor	dh,dh			; Zero register

scroll_col_loop:
										call	vga_operation2
										dec	si
										add	dh,bh
										cmp	dh,40h			; '@'
										jb	scroll_col_loop			; Jump if below

scroll_cur_update:
		mov	ds:scroll_cur_ptr,si
		call	game_func_100
		mov	bx,word ptr ds:[80h]
		mov	byte ptr ds:gvar_flag_FF4A,0
		mov	si,ds:object_list_ptr

obj_list_scan:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	obj_check_match			; Jump if not equal
										retn

obj_check_match:
										cmp	ah,0FFh
										je	obj_list_next			; Jump if equal
										cmp	ax,bx
										jne	obj_list_next			; Jump if not equal
										xor	ah,ah			; Zero register
										mov	al,[si+2]
										call	vga_operation4
										mov	al,ds:gvar_flag_FF4A
										or	al,80h
										mov	[di],al

obj_list_next:
										inc	byte ptr ds:gvar_flag_FF4A
										add	si,10h
										jmp	short obj_list_scan

game_func_16:
		cmp	byte ptr ds:area_num,7
		clc				; Clear carry flag
		jnz	boundary_check			; Jump if not zero
		retn

boundary_check:
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		cmp	cl,2
		stc				; Set carry flag
		jnz	boundary_false			; Jump if not zero
		retn

boundary_false:
		clc				; Clear carry flag
		retn

state9_branch:
		mov	byte ptr ds:action_pending,0FFh
		call	game_func_11
		jmp	short scroll_retreat

scroll_retreat:
		mov	byte ptr ds:state_byte_9F18,0
		test	byte ptr ds:[0C2h],1
		jnz	toggle_c2_bit			; Jump if not zero
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jz	check_debug2			; Jump if zero
		retn

check_debug2:
		cmp	byte ptr ds:gvar_debug_val,2
		je	clear_c2_bit			; Jump if equal
		call	game_process_loop
		jc	clear_c2_bit			; Jump if carry Set
		mov	byte ptr ds:move_dir,1
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_vga7b			; Jump if zero
		retn

check_vga7b:
		call	vga_operation7
		jnz	set_c2_bit2b			; Jump if not zero
		test	byte ptr ds:invul_timer,0FFh
		jnz	set_c2_bit2b			; Jump if not zero
		mov	byte ptr ds:move_axis,1
		inc	byte ptr ds:pending_invul

set_c2_bit2b:
		or	byte ptr ds:[0C2h],2
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	inc_e7b			; Jump if zero
		retn

inc_e7b:
		inc	byte ptr ds:[0E7h]
		and	byte ptr ds:[0E7h],7Fh
		mov	byte ptr ds:state_byte_9F19,0
		retn

game_func_17:

toggle_c2_bit:
		xor	byte ptr ds:[0C2h],1
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	set_e7_80c			; Jump if zero
		retn

set_e7_80c:
		mov	byte ptr ds:[0E7h],80h
		retn

clear_c2_bit:
		and	byte ptr ds:[0C2h],0FDh
		mov	al,ds:gvar_music_flag_b
		or	al,ds:gvar_combat_ff3D
		jz	check_combat_flags			; Jump if zero
		retn

check_combat_flags:
		mov	byte ptr ds:[0E7h],80h
		retn

game_check_state		endp

game_process_loop		proc	near

map_scan_loop_entry:
		call	vga_operation8
		inc	si
		inc	si
		mov	di,si
		sub	si,24h
		call	vga_operation6
		mov	cx,4

tile_scan_4b:
										call	vga_operation9
										add	al,al
										jnc	scan_tile_advance			; Jump if carry=0
										retn

scan_tile_advance:
										add	si,24h
										call	vga_operation5
										loop	tile_scan_4b		; Loop if cx > 0

		xchg	di,si
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jnz	scan_2more_b			; Jump if not zero
		mov	al,[si]
		call	game_check_state_2
		stc				; Set carry flag
		jz	check_music_a3			; Jump if zero
		retn

check_music_a3:
		call	game_func_19
		jnc	scan_2more_b			; Jump if carry=0
		retn

scan_2more_b:
		mov	cx,2

scan_2_tiles_b:
										add	si,24h
										call	vga_operation5
										mov	al,[si]
										call	game_func_42
										stc				; Set carry flag
										jz	push_call19			; Jump if zero
										retn

push_call19:
										push	cx
										call	game_func_19
										pop	cx
										jnc	loop_continue_b			; Jump if carry=0
										retn

loop_continue_b:
										loop	scan_2_tiles_b		; Loop if cx > 0

scroll_pos_inc:
		inc	word ptr ds:[80h]
		mov	ax,word ptr ds:[80h]
		add	ax,23h
		cmp	ax,ds:map_width
		jne	scroll_wrap_right			; Jump if not equal
		mov	word ptr ds:scroll_cur_ptr,0C01Ah

scroll_wrap_right:
		push	cs
		pop	es
		mov	si,scroll_buf_p1
		mov	di,scroll_buf
		mov	cx,8FFh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	si,ds:scroll_cur_ptr
		inc	si
		mov	di,0E023h
		call	vga_operation3
		dec	si
		mov	ds:scroll_cur_ptr,si
		mov	ax,word ptr ds:[80h]
		cmp	ax,ds:map_width
		jne	scroll_to_right			; Jump if not equal
		mov	word ptr ds:[80h],0
		mov	si,map_col_ptr
		jmp	short set_col_ptr

scroll_to_right:
		mov	si,ds:map_cur_ptr
		xor	dh,dh			; Zero register

fill_right_col:
										call	vga_operation1
										inc	si
										add	dh,bh
										cmp	dh,40h			; '@'
										jb	fill_right_col			; Jump if below

set_col_ptr:
		mov	ds:map_cur_ptr,si
		call	game_func_99
		mov	byte ptr ds:gvar_flag_FF4A,0
		mov	bx,word ptr ds:[80h]
		add	bx,23h
		mov	ax,bx
		sub	ax,ds:map_width
		jc	bx_wrap_check			; Jump if carry Set
		mov	bx,ax

bx_wrap_check:
		mov	si,ds:object_list_ptr

obj_list_scan_b:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	obj_check_match_b			; Jump if not equal
										retn

obj_check_match_b:
										cmp	ah,0FFh
										je	obj_list_next_b			; Jump if equal
										cmp	ax,bx
										jne	obj_list_next_b			; Jump if not equal
										mov	ah,23h			; '#'
										mov	al,[si+2]
										call	vga_operation4
										mov	al,ds:gvar_flag_FF4A
										or	al,80h
										mov	[di],al

obj_list_next_b:
										inc	byte ptr ds:gvar_flag_FF4A
										add	si,10h
										jmp	short obj_list_scan_b

game_process_loop		endp

game_func_19		proc	near
		cmp	byte ptr ds:area_num,7
		clc				; Clear carry flag
		jnz	area7_skip			; Jump if not zero
		retn

area7_skip:
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		dec	cl
		stc				; Set carry flag
		jnz	area7_stc			; Jump if not zero
		retn

area7_stc:
		clc				; Clear carry flag
		retn

game_func_19		endp

game_func_20		proc	near
		test	byte ptr ds:escape_flag,0FFh
		jz	check_escape_flag		; Jump if zero
		retn

check_escape_flag:
		test	byte ptr ds:gvar_combat_ff3D,80h
		jz	check_combat_ff3d_80		; Jump if zero
		retn

check_combat_ff3d_80:
		call	game_func_84
		call	game_func_21
		call	game_func_24
		jnc	step_count_ok			; Jump if carry=0
		jmp	check_combat_7f

step_count_ok:
		inc	byte ptr ds:state_byte_9F08
		test	byte ptr ds:hp_countdown,0FFh
		jz	check_hp_cnt			; Jump if zero
		pushf				; Push flags
		dec	byte ptr ds:hp_countdown
		inc	byte ptr ds:[84h]
		popf				; Pop flags

check_hp_cnt:
		pop	ax
		jnz	check_c2_bit2			; Jump if not zero
		call	game_func_23

check_c2_bit2:
		test	byte ptr ds:[0C2h],2
		jnz	e7_80_and_reset			; Jump if not zero
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		call	game_get_value
		jnc	e7_80_and_reset			; Jump if carry=0
		mov	byte ptr ds:gvar_music_flag_b,0FFh
		retn

e7_80_and_reset:
		mov	byte ptr ds:[0E7h],80h
		mov	al,ds:gvar_combat_ff3D
		mov	byte ptr ds:gvar_combat_ff3D,7Fh
		test	byte ptr ds:gvar_debug_val,0FFh
		jz	check_debug_val			; Jump if zero
		retn

check_debug_val:
		test	byte ptr ds:[0E8h],0FFh
		jz	check_e8			; Jump if zero
		retn

check_e8:
		test	al,0FFh
		jnz	combat_mode_active			; Jump if not zero
		mov	ax,joy_port_c
		push	ax
		test	byte ptr ds:[0C2h],1
		jz	dispatch_player_side			; Jump if zero
		jmp	player_action_taken

dispatch_player_side:
		jmp	scroll_retreat

c2_clear_bit1:
			                        ; Dead code -- confirmed unreachable (after jmp scroll_retreat)
		and	byte ptr ds:[0C2h],0FDh
		retn

combat_mode_active:
		int	61h			; ??INT Non-standard interrupt
		and	al,0Ch
		cmp	al,4
		je	right_no_c2b1			; Jump if equal
		cmp	al,8
		je	left_no_c2b1			; Jump if equal

check_c2_bit2b:
																		test	byte ptr ds:[0C2h],2
																		jnz	check_c2_bit1			; Jump if not zero
																		cmp	al,4
																		je	check_vga8_d			; Jump if equal
																		cmp	al,8
																		je	check_vga8_c			; Jump if equal
																		retn

check_c2_bit1:
																		test	byte ptr ds:[0C2h],1
																		jz	jmp_retreat			; Jump if zero
																		jmp	player_action_taken

jmp_retreat:
																		jmp	scroll_retreat

right_no_c2b1:
																		test	byte ptr ds:[0C2h],1
																		jnz	check_c2_bit2b			; Jump if not zero
										and	byte ptr ds:[0C2h],0FDh
										call	game_func_17

check_vga8_c:
										call	vga_operation8
										add	si,6Dh
										call	vga_operation5
										mov	al,[si]
										call	game_check_state_2
										jz	check_si_ok			; Jump if zero
										retn

check_si_ok:
										inc	si
										mov	al,[si]
										call	game_check_state_2
										jnz	jmp_map_scan_b			; Jump if not zero
										retn

jmp_map_scan_b:
										jmp	map_scan_loop_entry

left_no_c2b1:
										test	byte ptr ds:[0C2h],1
										jz	check_c2_bit2b			; Jump if zero
		and	byte ptr ds:[0C2h],0FDh
		call	game_func_17

check_vga8_d:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	al,[si]
		call	game_check_state_2
		jz	check_si_ok_b			; Jump if zero
		retn

check_si_ok_b:
		dec	si
		mov	al,[si]
		call	game_check_state_2
		jnz	jmp_scroll_adv_b			; Jump if not zero
		retn

jmp_scroll_adv_b:
		jmp	scroll_advance

game_func_21:
		mov	byte ptr ds:gvar_debug_val,0
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		call	game_scan_loop
		jz	clear_c2_and_debug			; Jump if zero
		retn

clear_c2_and_debug:
		and	byte ptr ds:[0C2h],0FDh
		mov	ds:gvar_debug_val,dl
		test	byte ptr ds:hp_midpoint,0FFh
		jnz	check_9E_eq3			; Jump if not zero
		mov	al,ds:state_byte_9F16
		inc	byte ptr ds:state_byte_9F16
		and	al,3
		jz	frame_parity_check			; Jump if zero
		retn

frame_parity_check:
		int	61h			; ??INT Non-standard interrupt
		cmp	byte ptr ds:gvar_debug_val,1
		je	check_debug1_b			; Jump if equal
		test	al,8
		jz	jmp_scroll_adv_c			; Jump if zero
		retn

jmp_scroll_adv_c:
		jmp	scroll_advance

check_debug1_b:
		test	al,4
		jz	jmp_map_scan_c			; Jump if zero
		retn

jmp_map_scan_c:
		jmp	map_scan_loop_entry

check_9E_eq3:
		mov	al,byte ptr ds:[9Eh]
		cmp	al,3
		jne	decrement_midpoint			; Jump if not equal
		retn

decrement_midpoint:
		dec	byte ptr ds:hp_midpoint
		cmp	byte ptr ds:gvar_debug_val,1
		jne	jmp_scroll_adv_d			; Jump if not equal
		jmp	map_scan_loop_entry

jmp_scroll_adv_d:
		jmp	scroll_advance

game_func_22:
		mov	byte ptr ds:state_byte_9F18,0
		test	byte ptr ds:gvar_debug_val,0FFh
		jz	check_debug_val_b			; Jump if zero
		retn

check_debug_val_b:
		call	game_func_78
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		call	game_get_value
		jc	music_advance_loop			; Jump if carry Set
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	set_music_a_flag			; Jump if zero
		mov	byte ptr ds:gvar_music_flag_b,80h
		mov	byte ptr ds:gvar_combat_ff3D,80h
		retn

set_music_a_flag:
		mov	byte ptr ds:frame_parity,0
		mov	byte ptr ds:gvar_music_flag_a,0FFh
		retn

music_advance_loop:
										call	vga_operation8
										add	si,6Dh
										call	vga_operation5
										inc	byte ptr ds:[0E7h]
										mov	al,[si]
										call	game_check_state_2
										jz	func13_and_state2			; Jump if zero
										or	byte ptr ds:[0E7h],1
										retn

func13_and_state2:
										call	game_func_23
										call	game_check_state_3
										test	byte ptr ds:[0E7h],1
										jz	jmp_back_adv_loop			; Jump if zero
										retn

jmp_back_adv_loop:
										jmp	short music_advance_loop

game_func_23:

process_loop_end:
		inc	byte ptr ds:[82h]
		mov	si,ds:gvar_scroll_pos
		add	si,24h
		call	vga_operation5
		mov	ds:gvar_scroll_pos,si
		retn

check_combat_7f:
		mov	al,ds:gvar_combat_ff3D
		xor	al,7Fh
		jz	pop_and_reset			; Jump if zero
		retn

pop_and_reset:
		pop	ax
		mov	dl,ds:state_byte_9F08
		mov	byte ptr ds:gvar_combat_ff3D,0
		mov	byte ptr ds:frame_parity,0
		mov	byte ptr ds:state_byte_9F08,0
		mov	byte ptr ds:[0E7h],80h
		test	byte ptr ds:gvar_debug_val,0FFh
		jz	check_step_count			; Jump if zero
		retn

check_step_count:
		cmp	dl,2
		jae	set_music_a_ff			; Jump if above or =
		retn

set_music_a_ff:
		mov	byte ptr ds:gvar_music_flag_a,0FFh
		retn

game_func_20		endp

game_func_24		proc	near
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	di,si
		call	vga_operation9
		add	al,al
		jnc	check_tile_right			; Jump if carry=0
		retn

check_tile_right:
		dec	si
		call	vga_operation9
		add	al,al
		jnc	check_tile_center			; Jump if carry=0
		retn

check_tile_center:
		mov	si,di
		mov	al,[si]
		call	game_func_42
		stc				; Set carry flag
		jz	check_e7_80			; Jump if zero
		retn

check_e7_80:
		cmp	byte ptr ds:[0E7h],80h
		clc				; Clear carry flag
		jnz	check_tile_left			; Jump if not zero
		retn

check_tile_left:
		dec	si
		mov	al,[si]
		call	game_func_42
		clc				; Clear carry flag
		jnz	check_tile_right2			; Jump if not zero
		retn

check_tile_right2:
		inc	si
		inc	si
		mov	al,[si]
		call	game_func_42
		stc				; Set carry flag
		jz	all_clear			; Jump if zero
		retn

all_clear:
		clc				; Clear carry flag
		retn

game_func_24		endp

game_get_value		proc	near
		mov	al,[si]
		dec	al
		cmp	al,2
		retn

game_get_value		endp

game_scan_loop		proc	near
		mov	es,cs:gvar_game_seg
		mov	al,[si]
		mov	di,fire1_slot_table
		mov	dl,2
		mov	cx,4

fire1_scan_loop:
										test	byte ptr es:[di],0FFh
										jz	check_fire2			; Jump if zero
										cmp	al,es:[di]
										jne	fire1_next			; Jump if not equal
										retn

fire1_next:
										inc	di
										loop	fire1_scan_loop		; Loop if cx > 0

check_fire2:
		mov	di,fire2_slot_table
		mov	dl,1
		mov	cx,4

fire2_scan_loop:
										test	byte ptr es:[di],0FFh
										jz	test_dl			; Jump if zero
										cmp	al,es:[di]
										jne	fire2_next			; Jump if not equal
										retn

fire2_next:
										inc	di
										loop	fire2_scan_loop		; Loop if cx > 0

test_dl:
		or	dl,dl			; Zero ?
		retn

game_scan_loop		endp

game_func_27		proc	near
		mov	si,ds:map_seg_ptr

seg_scan_loop:
										mov	di,[si]
;*		cmp	di,0FFFFh
												cmp di,-1			; was: db 083h,0FFh,0FFh
										jnz	seg_has_entry			; Jump if not zero
										retn

seg_has_entry:
										add	si,3
										mov	al,[si-1]
										and	al,[di]
										jnz	copy_seg_data			; Jump if not zero

skip_seg_scan:
																		mov	di,[si]
;*		cmp	di,0FFFFh
																				cmp di,-1			; was: db 083h,0FFh,0FFh
																		jz	seg_next			; Jump if zero
																		add	si,4
																		jmp	short skip_seg_scan

copy_seg_data:
																		mov	di,[si]
;*		cmp	di,0FFFFh
																				cmp di,-1			; was: db 083h,0FFh,0FFh
																		jz	seg_next			; Jump if zero
																		mov	ax,[si+2]
																		mov	[di],ax
																		add	si,4
																		jmp	short copy_seg_data

seg_next:
										inc	si
										inc	si
										jmp	short seg_scan_loop

game_func_27		endp

game_get_value_2		proc	near
		mov	si,scroll_init_a
		call	word ptr cs:[200Eh]
		mov	si,scroll_init_b
		call	word ptr cs:[200Eh]
		retn

game_get_value_2		endp

scroll_init_data_a:
			                        ; Scroll init data block A (dispatch table target or alignment padding)
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

game_func_29		proc	near
		mov	bx,210h
		xor	al,al			; Zero register
		mov	ch,21h			; '!'
		call	word ptr cs:[2004h]
		mov	bx,2310h
		mov	al,80h
		mov	ch,67h			; 'g'
		call	word ptr cs:[2004h]
		mov	bx,0AA9h
		mov	dx,0AB5h
		mov	cx,0E03h
		call	word ptr cs:[202Ch]
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:[2004h]
		mov	si,scroll_init_c
		jmp	word ptr cs:[200Eh]

game_func_29		endp

scroll_init_data_b:
			                        ; Scroll init data block B (dispatch table target or alignment padding)
		or	ax,2AFh
		add	ax,4E45h
		inc	bp
		dec	bp
		pop	cx

vga_operation0		proc	near
		mov	si,map_col_ptr
		mov	cx,word ptr ds:[80h]
		or	cx,cx			; Zero ?
		jz	map_col_done			; Jump if zero

map_col_scan:
										xor	dh,dh			; Zero register

map_col_inner:
																		call	vga_operation1
																		inc	si
																		add	dh,bh
																		cmp	dh,40h			; '@'
																		jb	map_col_inner			; Jump if below
										loop	map_col_scan		; Loop if cx > 0

map_col_done:
		mov	ds:map_cur_ptr,si
		mov	di,scroll_buf
		mov	ax,word ptr ds:[80h]
		mov	cx,24h

map_init_loop:
										push	di
										call	vga_operation3
										pop	di
										inc	di
										inc	ax
										cmp	ax,ds:map_width
										jne	map_col_wrap			; Jump if not equal
										mov	si,map_col_ptr
										xor	ax,ax			; Zero register

map_col_wrap:
										loop	map_init_loop		; Loop if cx > 0

		or	ax,ax			; Zero ?
		jnz	set_scroll_ptr			; Jump if not zero
		mov	si,ds:scroll_end_ptr

set_scroll_ptr:
		dec	si
		mov	ds:scroll_cur_ptr,si
		mov	al,byte ptr ds:[82h]
		xor	ah,ah			; Zero register
		call	vga_operation4
		mov	ds:gvar_scroll_pos,di
		retn

vga_operation0		endp

vga_operation1		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:scroll_dispatch_a[bx]	;*

vga_operation1		endp

scroll_op_a_0:
			                        ; scroll_dispatch_a target: entry 0 (indirect via scroll_dispatch_a table)
		pop	ds
		db	6Dh			; insw (port DX?->ES:[DI])
		db	2Fh			; das
		db	6Dh			; insw
		inc	di
		db	6Dh			; insw
		dec	di
		db	6Dh			; insw

vga_operation2		proc	near
		mov	bl,[si]
		and	bl,0C0h
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:scroll_dispatch_b[bx]	;*

vga_operation2		endp

scroll_op_b_0:
			                        ; scroll_dispatch_b target: entry 0 (indirect via scroll_dispatch_b table)
		daa				; Decimal adjust
		db	6Dh			; insw
		db	2Fh			; das
		db	6Dh			; insw
		inc	di
		db	6Dh			; insw
		dec	di
		db	6Dh			; insw
; scroll_rd_fwd_inc:
		mov	bh,[si]
		inc	bh
		inc	si
; scroll_rd_fwd:
		mov	bl,[si]
		retn
; scroll_rd_back:
		mov	bl,[si]
		dec	si
		mov	bh,[si]
		inc	bh
		retn
; scroll_rd_back2:
		mov	bl,[si]
		mov	bh,bl
		shr	bh,1			; D0 EF
		shr	bh,1			; D0 EF
		shr	bh,1			; D0 EF
		shr	bh,1			; D0 EF
		and	bh,03h
		add	bh,02h
		and	bl,0Fh
		inc	bl
		retn
; scroll_rd_back3:
		mov	bh,[si]
		and	bh,3Fh
		xor	bl,bl
		retn
; scroll_rd_fwd2:
		mov	bl,[si]
		and	bl,3Fh
		mov	bh,01h
		retn

vga_operation3		proc	near
		xor	dl,dl			; Zero register

col_fill_loop:
										call	vga_operation1
										inc	si
										add	dl,bh

cell_fill_loop:
																		mov	[di],bl
																		add	di,24h
																		dec	bh
																		jnz	cell_fill_loop			; Jump if not zero
										cmp	dl,40h			; '@'
										jb	col_fill_loop			; Jump if below
		retn

vga_operation3		endp

vga_operation4		proc	near
		push	bx
		and	al,3Fh			; '?'
		mov	bl,ah
		mov	bh,24h			; '$'
		mul	bh			; ax = reg * al
		xor	bh,bh			; Zero register
		add	ax,bx
		add	ax,scroll_buf
		mov	di,ax
		pop	bx
		retn

vga_operation4		endp

vga_operation5		proc	near

clamp_si_high:
										cmp	si,hud_buf
										jae	wrap_si_down			; Jump if above or =
										retn

wrap_si_down:
										sub	si,900h
										retn

vga_operation5		endp

vga_operation6		proc	near
										cmp	si,scroll_buf
										jb	wrap_si_up			; Jump if below
										retn

wrap_si_up:
										add	si,900h
										retn

vga_operation6		endp

vga_operation7		proc	near
										cmp	byte ptr ds:area_num,4
										je	area4_check			; Jump if equal
										retn

area4_check:
										cmp	byte ptr ds:[9Eh],4
										jne	area4_not4			; Jump if not equal
										mov	al,0FFh
										or	al,al			; Zero ?
										retn

area4_not4:
										xor	al,al			; Zero register
										retn

vga_operation7		endp

vga_operation8		proc	near
										mov	al,byte ptr ds:[84h]
										mov	cl,24h			; '$'
										mul	cl			; ax = reg * al
										mov	cl,byte ptr ds:[83h]
										add	cl,4
										xor	ch,ch			; Zero register
										add	ax,cx
										mov	si,ax
										add	si,ds:gvar_scroll_pos
										jmp	short clamp_si_high

vga_operation8		endp

vga_operation9		proc	near
		mov	al,[si]
		test	al,80h
		stc				; Set carry flag
		jnz	obj_slot_check			; Jump if not zero
		retn

obj_slot_check:
		and	al,7Fh
		mov	cl,10h
		mul	cl			; ax = reg * al
		mov	bx,ax
		add	bx,ds:object_list_ptr
		mov	al,[bx+4]
		or	al,al			; Zero ?
		retn

vga_operation9		endp

game_check_state_2		proc	near
		cmp	al,40h			; '@'
		jb	scan_enemy_table			; Jump if below
		cmp	al,al
		retn

game_func_41:
		cmp	al,49h			; 'I'
		jb	scan_enemy_table			; Jump if below
		cmp	al,al
		retn

scan_enemy_table:
		push	di
		push	cx
		mov	es,cs:gvar_game_seg
		mov	di,enemy_id_table
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		jnz	not_in_table			; Jump if not zero
		retn

not_in_table:
		and	al,9Fh
		cmp	al,90h
		je	set_al_ff			; Jump if equal
		cmp	al,91h
		je	set_al_ff			; Jump if equal
		and	al,80h
		cmp	al,80h
		retn

set_al_ff:
		mov	al,0FFh
		or	al,al			; Zero ?
		retn

game_check_state_2		endp

game_func_42		proc	near
		cmp	al,49h			; 'I'
		jb	scan_enemy_table_b			; Jump if below
		cmp	al,al
		retn

scan_enemy_table_b:
		push	di
		push	cx
		mov	es,cs:gvar_game_seg
		mov	di,enemy_id_table
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		jnz	not_in_table_b			; Jump if not zero
		retn

not_in_table_b:
		and	al,80h
		cmp	al,80h
		retn

game_func_42		endp

game_func_43		proc	near
		test	byte ptr ds:[92h],0FFh
		jnz	vol_btn_pressed			; Jump if not zero
		retn

vol_btn_pressed:
		int	61h			; ??INT Non-standard interrupt
		test	ah,1
		jz	check_state_loop			; Jump if zero
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jz	check_state_loop			; Jump if zero
		test	byte ptr ds:gvar_debug_val,0FFh
		jnz	check_state_loop			; Jump if not zero
		test	al,2
		jz	check_state_loop			; Jump if zero
		mov	byte ptr ds:gvar_flag_FF45,2
		mov	byte ptr ds:gvar_flag_FF46,2
		test	byte ptr ds:gvar_flag_FF47,0FFh
		jz	set_vol_flag			; Jump if zero
		jmp	clear_skip_joy

set_vol_flag:
		mov	byte ptr ds:gvar_flag_FF47,0FFh
		mov	byte ptr ds:gvar_volume_b,4
		jmp	short clear_skip_joy

check_state_loop:
		mov	byte ptr ds:gvar_flag_FF47,0
		test	byte ptr ds:gvar_skip_input,0FFh
		jnz	check_skip_input			; Jump if not zero
		retn

check_skip_input:
		test	byte ptr ds:gvar_joystick_flag,0FFh
		jz	check_joy_flag			; Jump if zero
		retn

check_joy_flag:
		test	byte ptr ds:gvar_palette_flag,0FFh
		jz	check_palette_flag			; Jump if zero
		retn

check_palette_flag:
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jnz	read_joystick			; Jump if not zero
		call	vga_operation8
		sub	si,93h
		call	vga_operation6
		xor	dl,dl			; Zero register
		mov	cx,4

outer_slot_scan:
										push	cx
										mov	cx,8

inner_slot_scan:
																		push	cx
																		call	vga_operation9
																		jc	slot_inner_next			; Jump if carry Set
																		test	al,60h			; '`'
																		jnz	slot_inner_next			; Jump if not zero
																		test	byte ptr [bx+7],10h
																		jnz	slot_inner_next			; Jump if not zero
																		mov	dl,0FFh

slot_inner_next:
																		inc	si
																		pop	cx
																		loop	inner_slot_scan		; Loop if cx > 0

										add	si,1Ch
										call	vga_operation5
										pop	cx
										loop	outer_slot_scan		; Loop if cx > 0

		or	dl,dl			; Zero ?
		jnz	set_flag45_1			; Jump if not zero

read_joystick:
		int	61h			; ??INT Non-standard interrupt
		test	al,1
		jz	set_flag45_0			; Jump if zero

set_flag45_1:
		mov	byte ptr ds:gvar_flag_FF45,1
		mov	byte ptr ds:gvar_flag_FF46,0
		jmp	short set_vol3

set_flag45_0:
		mov	byte ptr ds:gvar_flag_FF45,0
		mov	byte ptr ds:gvar_flag_FF46,0

set_vol3:
		mov	byte ptr ds:gvar_volume_b,3

clear_skip_joy:
		mov	byte ptr ds:gvar_skip_input,0
		mov	byte ptr ds:gvar_state_b,0
		mov	byte ptr ds:gvar_joystick_flag,0FFh
		retn

game_func_43		endp

game_func_44		proc	near
		test	byte ptr ds:gvar_joystick_flag,0FFh
		jnz	joy_flag_set			; Jump if not zero
		retn

joy_flag_set:
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	check_flag2e			; Jump if zero
		test	byte ptr ds:gvar_flag_FF2E,0FFh
		jz	check_flag2e			; Jump if zero
		retn

check_flag2e:
		call	vga_operation8
		mov	bx,90h
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jz	pick_offset			; Jump if zero
		mov	bx,6Ch

pick_offset:
		sub	si,bx
		call	vga_operation6
		mov	bl,byte ptr ds:[0C2h]
		and	bl,1
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,bl
		mov	al,ds:gvar_flag_FF45
		mov	ah,0
		or	al,al			; Zero ?
		jz	flag45_zero			; Jump if zero
		mov	ah,6
		dec	al
		jz	flag45_zero			; Jump if zero
		mov	al,bl
		add	al,0Ah
		jmp	short apply_mask

flag45_zero:
		mov	al,ds:gvar_flag_FF46
		or	al,bl
		add	al,ah

apply_mask:
		and	al,0FEh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	es,cs:gvar_game_seg
		mov	di,es:entity_ptr_table[bx]

entity_ptr_loop:
																		mov	al,es:[di]
																		inc	di
																		cmp	al,0FFh
																		jne	entity_ptr_check			; Jump if not equal
																		retn

entity_ptr_check:
																		xor	ah,ah			; Zero register
																		add	si,ax
																		call	vga_operation5
																		call	vga_operation9
																		jc	entity_ptr_loop			; Jump if carry Set
																		test	al,20h			; ' '
																		jnz	entity_ptr_loop			; Jump if not zero
																		test	byte ptr [bx+5],20h	; ' '
																		jnz	entity_ptr_loop			; Jump if not zero
										or	byte ptr [bx+5],40h	; '@'
										and	byte ptr [bx+5],0E0h
										or	byte ptr [bx+5],1
										jmp	short entity_ptr_loop

game_func_44		endp

game_check_state_3		proc	near

frame_state_update:
		mov	al,2
		cmp	byte ptr ds:[9Eh],1
		jne	hp_max_set			; Jump if not equal
		mov	al,4

hp_max_set:
		mov	ds:hp_max,al
		call	game_process_loop_2
		test	byte ptr ds:gvar_combat_ff3D,0FFh
		jnz	check_e6			; Jump if not zero
		mov	byte ptr ds:hp_countdown,0
		mov	al,ds:room_count
		cmp	al,byte ptr ds:[84h]
		je	check_e6			; Jump if equal
		jc	scroll_down_step			; Jump if carry Set
		call	game_func_13
		inc	byte ptr ds:[84h]
		jmp	short check_e6

scroll_down_step:
		call	game_func_23
		dec	byte ptr ds:[84h]

check_e6:
		test	byte ptr ds:[0E6h],0FFh
		jnz	obj_row_sync			; Jump if not zero
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	scroll_right_step			; Jump if zero

obj_row_sync:
		mov	si,ds:obj_data_ptr
		add	si,7
		mov	al,[si]
		cmp	byte ptr ds:[83h],al
		je	update_gvar			; Jump if equal
		call	game_process_loop
		dec	byte ptr ds:[83h]
		jmp	short update_gvar

scroll_right_step:
		mov	al,byte ptr ds:[83h]
		cmp	al,0Ch
		je	update_gvar			; Jump if equal
		call	game_func_15
		inc	byte ptr ds:[83h]

update_gvar:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	ds:gvar_save_flag_2,al
		call	game_check_state_4
		call	game_func_85
		call	game_scan_loop_4
		call	game_scan_loop_5
		call	game_func_66
		call	game_func_111
		test	byte ptr ds:gvar_flag_FF30,0FFh
		jnz	skip_func116			; Jump if not zero
		call	game_func_116

skip_func116:
		mov	byte ptr ds:gvar_save_flag_3,0
		mov	byte ptr ds:any_entity_active,0
;*		call	game_func_55			;*
			db	0E8h, 0E3h, 04h			; call near 1524h (mid-instruction target; keep as bytes)
		call	word ptr cs:gfx_fn_render_tile
		call	copy_buffer_2
		call	game_scan_loop_8
		call	word ptr cs:gfx_fn_render_col
		call	game_scan_loop_3
		cmp	byte ptr ds:area_num,7
		jne	post_key_check			; Jump if not equal
		cmp	byte ptr ds:[9Eh],5
		je	post_key_check			; Jump if equal
		inc	byte ptr ds:frame_ctr
		test	byte ptr ds:frame_ctr,3Fh	; '?'
		jnz	post_key_check			; Jump if not zero
		mov	byte ptr ds:gvar_save_flag_3,0FFh
		mov	byte ptr ds:gvar_volume_b,9
		mov	ax,0Fh
		call	game_func_60
		mov	dx,entity_snd_tbl
		call	game_func_51

post_key_check:
		call	game_func_47
		test	byte ptr ds:[0E8h],0FFh
		jz	clear_save_flag4			; Jump if zero
		mov	byte ptr ds:gvar_save_flag_3,0
		jmp	short set_debug_mode

game_func_46:

clear_save_flag4:
		mov	byte ptr ds:gvar_save_flag_4,0

set_debug_mode:
		mov	byte ptr ds:gvar_debug_mode,0
		test	byte ptr ds:gvar_joystick_flag,0FFh
		jz	check_palette			; Jump if zero
		mov	byte ptr ds:gvar_debug_mode,0FFh
		mov	al,ds:gvar_flag_FF45
		mov	ds:gvar_flag_FF41,al
		mov	al,ds:gvar_flag_FF46
		mov	ds:gvar_flag_FF3F,al
		jmp	short check_save_flag4

check_palette:
		test	byte ptr ds:gvar_palette_flag,0FFh
		jz	check_save_flag4			; Jump if zero
		mov	byte ptr ds:gvar_debug_mode,0FFh
		mov	al,ds:state_byte_9F2B
		mov	ds:gvar_flag_FF3F,al
		mov	byte ptr ds:gvar_flag_FF41,1

check_save_flag4:
		test	byte ptr ds:gvar_save_flag_4,0FFh
		jnz	call_combat_fx			; Jump if not zero
		call	game_multiply_2

call_combat_fx:
		call	word ptr cs:gfx_fn_combat_fx
		test	byte ptr ds:[0E8h],0FFh
		jnz	call_enemy_scroll			; Jump if not zero
		mov	ax,word ptr ds:[0C6h]
		or	ax,ax			; Zero ?
		jz	call_enemy_scroll			; Jump if zero
		dec	ax
		mov	word ptr ds:[0C6h],ax
		add	word ptr ds:[90h],8
		mov	ax,word ptr ds:[0B2h]
		cmp	ax,word ptr ds:[90h]
		jae	clamp_scroll_pos			; Jump if above or =
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr ds:[90h],ax
		mov	word ptr ds:[0C6h],0

clamp_scroll_pos:
		mov	byte ptr ds:gvar_volume_b,13h
		call	word ptr cs:[2008h]

call_enemy_scroll:
		call	word ptr cs:gfx_fn_enemy_scroll
		test	byte ptr ds:gvar_flag_FF2F,0FFh
		jz	frame_timer_wait			; Jump if zero
		call	word ptr cs:gfx_fn_player_scroll
		mov	byte ptr ds:gvar_state_FF24,0Ah

frame_timer_wait:
		mov	cl,ds:gvar_save_flag
		mov	al,2
		mul	cl			; ax = reg * al

frame_timer_loop:
										cmp	ds:gvar_frame_timer,al
										jb	frame_timer_loop			; Jump if below
		call	game_scan_loop_8
		call	word ptr cs:gfx_fn_render_tile
		call	game_check_state_5
		call	game_func_102
		call	game_func_109
		call	game_func_44
		call	word ptr cs:gfx_fn_render_col
		mov	cl,ds:gvar_save_flag
		mov	al,4
		mul	cl			; ax = reg * al

sound_update_loop:
										push	ax
										call	word ptr cs:[110h]
										call	word ptr cs:[112h]
										call	word ptr cs:[114h]
										call	word ptr cs:[116h]
										call	word ptr cs:[118h]
										call	word ptr cs:[11Eh]
										jnc	sound_wait_done			; Jump if carry=0
										call	game_func_65

sound_wait_done:
										pop	ax
										cmp	ds:gvar_frame_timer,al
										jb	sound_update_loop			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		test	byte ptr ds:[0E8h],0FFh
		jz	check_7f_90			; Jump if zero
		retn

check_7f_90:
		test	byte ptr ds:[7Fh],0FFh
		jnz	check_state18			; Jump if not zero
		test	word ptr ds:[90h],0FFFFh
		jnz	check_state18			; Jump if not zero
		jmp	game_over_sequence

check_state18:
		inc	byte ptr ds:state_byte_9F18
		cmp	byte ptr ds:state_byte_9F18,10h
		jb	check_state1e			; Jump if below
		mov	byte ptr ds:state_byte_9F18,0
		mov	ax,word ptr ds:[90h]
		cmp	ax,word ptr ds:[0B2h]
		jae	check_state1e			; Jump if above or =
		add	ax,2
		mov	word ptr ds:[90h],ax
		call	word ptr cs:[2008h]

check_state1e:
		test	byte ptr ds:state_byte_9F1E,0FFh
		jz	check_save1_flag30			; Jump if zero
		jmp	check_e8_flag

check_save1_flag30:
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	scroll_check_done			; Jump if zero
		test	byte ptr ds:gvar_flag_FF30,0FFh
		jz	scroll_check_done			; Jump if zero
		cmp	byte ptr ds:enemy_data_buf2,0FFh
		jne	scroll_check_done			; Jump if not equal
		mov	si,ds:obj_data_ptr
		add	si,5
		lodsw				; String [si] to ax
		push	si
		call	game_func_143
		pop	si
		add	si,4
		lodsw				; String [si] to ax
		call	game_func_120
		mov	byte ptr ds:state_byte_9F1E,0FFh

scroll_check_done:
		test	byte ptr ds:gvar_flag_FF2E,0FFh
		jz	check_timer_counter			; Jump if zero
		retn

check_timer_counter:
		test	word ptr ds:gvar_timer_counter,1
		jnz	check_combat_flags2			; Jump if not zero
		mov	byte ptr ds:combat_active,0
		retn

game_func_47:
		test	byte ptr ds:player_scroll_flag,0FFh
		jz	check_enemy_scroll		; Jump if zero
		mov	al,0FCh
		inc	byte ptr ds:anim_ctr_y
		test	byte ptr ds:anim_ctr_y,1Fh
		jnz	player_hud_fill_done		; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:player_scroll_flag,0

player_hud_fill_done:
		push	cs
		pop	es
		mov	di,hud_enemy_area
		mov	cl,ds:scroll_row_cnt
		xor	ch,ch			; Zero register

hud_enemy_fill:
										push	cx
										mov	cx,12h
										rep	stosb			; Rep when cx >0 Store al to es:[di]
										add	di,0Ah
										pop	cx
										loop	hud_enemy_fill		; Loop if cx > 0

check_enemy_scroll:
		test	byte ptr ds:enemy_scroll_flag,0FFh
		jnz	enemy_scroll_active		; Jump if not zero
		retn

enemy_scroll_active:
		mov	al,0FCh
		inc	byte ptr ds:anim_ctr_x
		and	byte ptr ds:anim_ctr_x,1Fh
		jnz	enemy_hud_fill_done		; Jump if not zero
		mov	al,0FEh
		mov	byte ptr ds:enemy_scroll_flag,0

enemy_hud_fill_done:
		push	ds
		pop	es
		mov	di,hud_player_area
		mov	cx,2

hud_player_fill:
										push	cx
										push	di
										mov	cx,1Ah
										rep	stosb			; Rep when cx >0 Store al to es:[di]
										pop	di
										add	di,1Ch
										pop	cx
										loop	hud_player_fill		; Loop if cx > 0

		retn

check_combat_flags2:
		mov	al,ds:combat_active
		or	al,ds:gvar_palette_flag
		or	al,ds:gvar_flag_FF3E
		or	al,ds:scene_trans_flag
		jz	do_combat_round			; Jump if zero
		retn

do_combat_round:
		mov	byte ptr ds:gvar_volume_b,0Bh
		call	word ptr cs:[2002h]
		call	game_func_48
		call	word ptr cs:game_fn_vtable
		call	game_func_48
		cmp	byte ptr ds:gvar_flag_FF4B,8
		jne	combat_palette_update			; Jump if not equal
		jmp	next_level_start

combat_palette_update:
		call	word ptr cs:[2002h]
		push	ds
		call	word ptr cs:gfx_fn_palette
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		mov	byte ptr ds:combat_active,0FFh
		call	fill_buffer
		mov	byte ptr ds:gvar_skip_input,0
		mov	byte ptr ds:gvar_state_b,0
		mov	byte ptr ds:enemy_scroll_flag,0
		mov	byte ptr ds:player_scroll_flag,0
		jmp	frame_state_update

game_func_48:
		mov	es,cs:gvar_game_seg
		mov	di,world_state_base
		mov	si,game_fn_vtable
		mov	cx,800h

world_state_swap:
										mov	ax,es:[di]
										movsw				; Mov [si] to es:[di]
										mov	[si-2],ax
										loop	world_state_swap		; Loop if cx > 0

		retn

check_e8_flag:
		test	byte ptr ds:[0E8h],0FFh
		jz	load_new_map			; Jump if zero
		retn

load_new_map:
		mov	si,ds:map_data_ptr
		add	si,6
		lodsb				; String [si] to al
		push	si
		mov	ds:prev_chr_id,al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		add	ax,chr_ref_tbl
		mov	si,ax
		push	cs
		pop	es
		mov	di,game_fn_vtable
		mov	al,3
		call	word ptr cs:[10Ch]
		pop	si
		lodsb				; String [si] to al
		mov	ds:prev_spr_id,al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF spr_ref_tbl, sprite_load_dest, 2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,sprite_load_dest
		mov	bp,game_fn_vtable
		mov	cx,100h
		call	word ptr cs:gfx_fn_memcpy
		pop	ds
		mov	byte ptr ds:gvar_save_flag_1,0
		mov	si,ds:map_data_ptr
		add	si,8

patch_table_loop:
										lodsw				; String [si] to ax
										cmp	ax,0FFFFh
										je	patch_done			; Jump if equal
										mov	bx,ax
										lodsw				; String [si] to ax
										mov	[bx],ax
										jmp	short patch_table_loop

patch_done:
		call	vga_operation8
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		xor	bh,bh			; Zero register
		add	ax,bx
		test	byte ptr [si-5],0FFh
		jz	scroll_edge_check			; Jump if zero
		add	ax,9

scroll_edge_check:
		mov	bx,ax
		sub	bx,ds:map_width
		jc	wrap_scroll			; Jump if carry Set
		mov	ax,bx

wrap_scroll:
		mov	si,ds:entity_list_ptr
		mov	[si],ax
		call	game_func_66
		call	game_func_47
		call	game_multiply_2
		call	word ptr cs:gfx_fn_init
		mov	bx,21Ch
		xor	al,al			; Zero register
		mov	ch,42h			; 'B'
		call	word ptr cs:[2004h]
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:state_byte_9F1E,0
		jmp	module_init

game_check_state_3		endp

fill_buffer		proc	near

hud_fill:
		push	cs
		pop	es
		mov	di,hud_buf
		mov	cx,214h
		mov	al,0FDh
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

fill_buffer		endp

game_scan_loop_2		proc	near

atk_slot_check:
		push	di
		mov	es,cs:gvar_game_seg
		mov	di,atk_slot_table
		mov	cx,4

atk_slot_scan:
										mov	ah,es:[di]
										inc	di
										or	ah,ah			; Zero ?
										jz	atk_not_found			; Jump if zero
										cmp	ah,al
										je	atk_found			; Jump if equal
										loop	atk_slot_scan		; Loop if cx > 0

atk_not_found:
		mov	ah,0FFh
		or	ah,ah			; Zero ?

atk_found:
		pop	di
		retn

game_scan_loop_2		endp

game_func_51		proc	near

entity_scan_start:
		push	si
		push	dx

entity_scan_skip_push:
		mov	bx,0E1Eh
		mov	cx,3410h
		mov	al,0FFh
		call	word ptr cs:[2000h]
		mov	byte ptr ds:anim_ctr_x,0
		mov	byte ptr ds:enemy_scroll_flag,0FFh
		mov	byte ptr ds:anim_ctr_y,0FFh
		pop	si
		lodsw				; String [si] to ax
		add	ax,3Ah
		mov	bx,ax
		mov	cl,22h			; '"'
		call	word ptr cs:[202Ah]
		pop	si
		retn

game_func_51		endp

game_multiply		proc	near
		lodsb				; String [si] to al
		add	al,19h
		mov	cl,al
		push	cx
		lodsb				; String [si] to al
		push	si
		add	al,2
		mov	ds:scroll_row_cnt,al
		mov	bl,8
		mul	bl			; ax = reg * al
		mov	bx,1616h
		mov	ch,24h			; '$'
		mov	cl,al
		mov	al,0FFh
		call	word ptr cs:[2000h]
		pop	si
		mov	byte ptr ds:anim_ctr_x,0
		mov	byte ptr ds:enemy_scroll_flag,0
		mov	byte ptr ds:anim_ctr_y,0
		mov	byte ptr ds:player_scroll_flag,0FFh
		mov	bx,58h
		pop	cx

hud_row_loop:
										mov	ds:scroll_bx_save,bx
										mov	ds:scroll_cx_save,cl
										lodsb				; String [si] to al
										xor	ah,ah			; Zero register
										add	bx,ax

hud_cell_loop:
																		lodsb				; String [si] to al
																		cmp	al,0FFh
																		jne	hud_draw_sprite			; Jump if not equal
																		retn

hud_draw_sprite:
																		cmp	al,2Fh			; '/'
																		je	hud_row_next			; Jump if equal
																		mov	ah,1
																		push	cx
																		push	bx
																		push	si
																		call	word ptr cs:[2022h]
																		pop	si
																		pop	bx
																		pop	cx
																		add	bx,8
																		jmp	short hud_cell_loop

hud_row_next:
										mov	bx,ds:scroll_bx_save
										mov	cl,ds:scroll_cx_save
										add	cl,0Ch
										jmp	short hud_row_loop

game_multiply		endp

game_multiply_2		proc	near
		mov	al,byte ptr ds:[84h]
		mov	cl,1Ch
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,hud_buf
		mov	di,ax
		push	cs
		pop	es
		mov	al,0FFh
		mov	cx,3

hud_col_fill:
										stosb				; Store al to es:[di]
										stosb				; Store al to es:[di]
										stosb				; Store al to es:[di]
										add	di,19h
										loop	hud_col_fill		; Loop if cx > 0

		retn

game_multiply_2		endp

game_scan_loop_3		proc	near
		cmp	byte ptr ds:[9Eh],2
		jne	area2_skip			; Jump if not equal
		retn

area2_skip:
		mov	byte ptr ds:state_byte_9F17,0
		call	vga_operation8
		mov	cx,3
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jz	slot_outer_loop		; Jump if zero
		add	si,24h
		call	vga_operation5
		dec	cx

slot_outer_loop:
										push	cx
										mov	cx,3

slot_inner_loop:
																		push	cx
																		mov	al,[si]
																		inc	si
																		call	game_scan_loop_2
																		jnz	slot_occupied			; Jump if not zero
																		mov	byte ptr ds:state_byte_9F17,0FFh

slot_occupied:
																		pop	cx
																		loop	slot_inner_loop		; Loop if cx > 0

										add	si,21h
										call	vga_operation5
										pop	cx
										loop	slot_outer_loop		; Loop if cx > 0

		test	byte ptr ds:gvar_music_flag_b,0FFh
		jnz	check_state17			; Jump if not zero
		inc	si
		mov	al,[si]
		call	game_scan_loop_2
		jnz	check_state17			; Jump if not zero
		mov	byte ptr ds:state_byte_9F17,0FFh

check_state17:
		test	byte ptr ds:state_byte_9F17,0FFh
		jnz	save_flag3_set			; Jump if not zero
		retn

save_flag3_set:
		mov	byte ptr ds:gvar_save_flag_3,0FFh
		mov	byte ptr ds:gvar_volume_b,9
		mov	bl,ds:area_num
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:area_lookup_tbl[bx]
		xor	ah,ah			; Zero register
		jmp	sub_score_and_call

entity_dispatch_fn_0:
			                        ; entity_dispatch_tbl target: entity fn 0
		add	[bx+di],ax
		add	al,8
		adc	al,14h
		adc	al,14h
		adc	al,0F6h
		push	es
		xor	al,0FFh
		push	word ptr [si+8]
		test	byte ptr ds:gvar_flag_FF2E,0FFh
		jz	check_flag2e_b			; Jump if zero
		retn

check_flag2e_b:
		mov	word ptr ds:state_word_9F12,0
		call	vga_operation8
		dec	si
		mov	di,entity_slot_tbl
		mov	bx,entity_fn_a
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jnz	push_and_call			; Jump if not zero
		mov	bx,entity_fn_b
		sub	si,24h
		call	vga_operation6

push_and_call:
		push	bx
		push	di
		push	si
		call	bx			;*
		sbb	al,al
		mov	[di],al
		jz	slot0_result			; Jump if zero
		call	game_func_56

slot0_result:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		push	bx
		push	di
		push	si
		call	bx			;*
		jc	slot1_carry			; Jump if carry Set
		call	game_func_59

slot1_carry:
		sbb	al,al
		mov	[di],al
		jz	slot1_result			; Jump if zero
		call	game_func_56

slot1_result:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		push	bx
		push	di
		push	si
		call	bx			;*
		jc	slot2_carry			; Jump if carry Set
		call	game_func_59

slot2_carry:
		sbb	al,al
		mov	[di],al
		jz	slot2_result			; Jump if zero
		call	game_func_57

slot2_result:
		pop	si
		pop	di
		pop	bx
		inc	si
		inc	di
		call	bx			;*
		sbb	al,al
		mov	[di],al
		jz	update_any_active			; Jump if zero
		call	game_func_57

update_any_active:
		mov	di,entity_slot_tbl
		mov	al,[di]
		or	al,[di+1]
		or	al,[di+2]
		or	al,[di+3]
		mov	ds:any_entity_active,al
		mov	ds:gvar_save_flag_3,al
		or	al,al			; Zero ?
		jz	all_slots_empty		; Jump if zero
		call	word ptr cs:[201Ah]

all_slots_empty:
		retn

game_func_56:
		test	byte ptr ds:[0E8h],0FFh
		jz	check_c2_bit1b			; Jump if zero
		retn

check_c2_bit1b:
		mov	ax,ds:state_word_9F12
		test	byte ptr ds:[0C2h],1
		jz	combat_check_done			; Jump if zero
		jmp	short check_93

game_func_57:
		test	byte ptr ds:[0E8h],0FFh
		jz	check_c2_bit1c			; Jump if zero
		retn

check_c2_bit1c:
		mov	ax,ds:state_word_9F12
		test	byte ptr ds:[0C2h],1
		jnz	combat_check_done			; Jump if not zero
		jmp	short check_93

check_93:
		test	byte ptr ds:[93h],0FFh
		jz	combat_check_done			; Jump if zero
		shr	ax,1			; Shift w/zeros fill
		mov	cl,byte ptr ds:[93h]
		inc	cl
		shr	cl,1			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		sub	word ptr ds:[94h],ax
		jc	sub_carried			; Jump if carry Set
		jnz	call_func60			; Jump if not zero

sub_carried:
		push	ax
		call	game_func_58
		mov	word ptr ds:[94h],0
		pop	ax

call_func60:
		call	game_func_60
		mov	byte ptr ds:gvar_volume_b,8
		retn

combat_check_done:
		call	game_func_60
		mov	byte ptr ds:gvar_volume_b,9
		retn

game_func_58:
		mov	byte ptr ds:[93h],0
		mov	bx,0C51Ch
		mov	al,0FFh
		mov	ch,18h
		call	word ptr cs:[2004h]
		mov	bx,3EA3h
		mov	cx,511h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		mov	dx,9AB4h
		jmp	entity_scan_start

entity_dispatch_fn_1:
			                        ; entity_dispatch_tbl target: entity fn 1
		call	vga_operation9
		jc	tile_down1			; Jump if carry Set
		test	al,40h			; '@'
		jnz	tile_down1			; Jump if not zero
		and	al,0Fh
		jmp	short add_tile_type

tile_down1:
		add	si,24h
		call	vga_operation5
		call	vga_operation9
		jc	tile_down2			; Jump if carry Set
		test	al,40h			; '@'
		jnz	tile_down2			; Jump if not zero
		and	al,0Fh
		jmp	short add_tile_type

game_func_59:

tile_down2:
		add	si,24h
		call	vga_operation5
		call	vga_operation9
		cmc				; Complement carry
		jc	check_bit40			; Jump if carry Set
		retn

check_bit40:
		clc				; Clear carry flag
		test	al,40h			; '@'
		jz	tile_type_lookup			; Jump if zero
		retn

tile_type_lookup:
		and	al,0Fh
		jmp	short add_tile_type

add_tile_type:
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	al,ds:tile_type_map[bx]
		xor	ah,ah			; Zero register
		add	ds:state_word_9F12,ax
		stc				; Set carry flag
		retn

game_func_60:

sub_score_and_call:
		sub	word ptr ds:[90h],ax
		jnc	push_and_update			; Jump if carry=0
		mov	word ptr ds:[90h],0

push_and_update:
		push	si
		call	word ptr cs:[2008h]
		pop	si
		retn

game_scan_loop_3		endp

game_process_loop_2		proc	near
		mov	byte ptr ds:escape_flag,0
		call	vga_operation8
		add	si,49h
		call	vga_operation5
		mov	cx,3

process_loop_3:
										push	cx
										call	game_func_62
										sub	si,24h
										call	vga_operation6
										pop	cx
										loop	process_loop_3		; Loop if cx > 0

		retn

game_process_loop_2		endp

game_func_62		proc	near
		mov	al,[si]
		push	si
		call	game_func_63
		pop	si
		jz	dispatch_entity			; Jump if zero
		retn

dispatch_entity:
		pop	ax
		pop	ax
		mov	bl,cl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:entity_dispatch_tbl[bx]	;*

game_func_62		endp

entity_dispatch_fn_2:
			                        ; entity_dispatch_tbl target: entity fn 2
;*		aam	76h			; 'v' undocumented inst
			db	0D4h, 76h			; aam 76h (non-standard immediate)
;*                         lock	jbe	loc_313			;*Jump if below or =
			db	0F0h, 76h, 0EAh			; lock jna 16C2h (unaligned target)
;*		jbe	loc_313			;*Jump if below or =
			db	76h, 0E8h			; jna 16C2h (unaligned target)
		dec	dx
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		call	game_func_13
		mov	byte ptr ds:escape_flag,0FFh
		mov	byte ptr ds:gvar_combat_ff3D,0
		mov	byte ptr ds:[0E7h],80h
		retn

entity_dispatch_fn_3:
			                        ; entity_dispatch_tbl target: entity fn 3
		call	game_process_loop
		jmp	map_scan_loop_entry

entity_dispatch_fn_4:
			                        ; entity_dispatch_tbl target: entity fn 4
		call	game_func_15
		jmp	scroll_advance

game_func_63		proc	near
		or	al,al			; Zero ?
		jz	slot_not_found			; Jump if zero
		mov	es,cs:gvar_game_seg
		mov	bh,al
		xor	cl,cl			; Zero register
		mov	si,move_slot_a_table
		mov	bl,4

slotA_scan_loop:
										mov	al,es:[si]
										inc	si
										or	al,al			; Zero ?
										jz	slotA_not_found			; Jump if zero
										cmp	al,bh
										jne	slotA_mismatch			; Jump if not equal
										retn

slotA_mismatch:
										dec	bl
										jnz	slotA_scan_loop			; Jump if not zero

slotA_not_found:
		inc	cl
		mov	si,move_slot_b_table
		mov	bl,4

slotB_scan_loop:
										mov	al,es:[si]
										inc	si
										or	al,al			; Zero ?
										jz	slotB_not_found			; Jump if zero
										cmp	al,bh
										jne	slotB_mismatch			; Jump if not equal
										retn

slotB_mismatch:
										dec	bl
										jnz	slotB_scan_loop			; Jump if not zero

slotB_not_found:
		inc	cl
		mov	si,move_slot_c_table
		mov	bl,4

slotC_scan_loop:
										mov	al,es:[si]
										inc	si
										or	al,al			; Zero ?
										jz	slot_not_found			; Jump if zero
										cmp	al,bh
										jne	slotC_mismatch			; Jump if not equal
										retn

slotC_mismatch:
										dec	bl
										jnz	slotC_scan_loop			; Jump if not zero

slot_not_found:
		mov	cl,0FFh
		or	cl,cl			; Zero ?
		retn

game_func_63		endp

game_check_state_4		proc	near
		mov	ax,ds:target_id
		cmp	ax,0FFFFh
		je	target_check_done			; Jump if equal
		call	game_func_141
		jc	target_check_done			; Jump if carry Set
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,al
		sub	al,bl
		jnc	target_dx			; Jump if carry=0
		neg	al

target_dx:
		mov	bh,al
		sub	bl,ah
		jnc	target_dy			; Jump if carry=0
		neg	bl

target_dy:
		cmp	bl,bh
		jb	atk_dist_clamp			; Jump if below
		mov	bl,bh

atk_dist_clamp:
		mov	ds:atk_dist_x,bl
		mov	bl,ds:target_y
		mov	bh,ds:gvar_save_flag_2
		mov	al,bh
		sub	al,bl
		and	al,3Fh			; '?'
		sub	bl,bh
		and	bl,3Fh			; '?'
		cmp	bl,al
		jb	atk_dist_y_set			; Jump if below
		mov	bl,al

atk_dist_y_set:
		mov	ds:atk_dist_y,bl
		cmp	byte ptr ds:atk_dist_x,10h
		jae	target_check_done			; Jump if above or =
		mov	al,ds:atk_dist_x
		mov	bx,atk_speed_tbl_a
		xlat				; al=[al+[bx]] table
		mov	dl,al
		cmp	byte ptr ds:atk_dist_y,10h
		jae	target_check_done			; Jump if above or =
		mov	al,ds:atk_dist_y
		mov	bx,atk_speed_tbl_a
		xlat				; al=[al+[bx]] table
		add	al,dl
		jc	target_check_done			; Jump if carry Set
		mov	bx,atk_speed_tbl_b
		xlat				; al=[al+[bx]] table
		mov	ds:gvar_timer_ff08,al
		retn

target_check_done:
		mov	byte ptr ds:gvar_timer_ff08,0
		retn

game_check_state_4		endp

; Attack speed/distance lookup tables (used by atk_speed_tbl_a xlat, atk_speed_tbl_b xlat)
; First 16 bytes: squared distance steps 0??..15?? (0,1,4,9,16,25,36,49,64,81,100,121,144,169,196,225)

atk_dist_sq_tbl:
		db	 00h, 01h, 04h, 09h, 10h, 19h
		db	 24h, 31h, 40h, 51h, 64h, 79h
		db	 90h,0A9h,0C4h,0E1h
; Attack speed step-down table by distance range
		db	17 dup (0Fh)
		db	20 dup (0Eh)
		db	28 dup (0Dh)
		db	36 dup (0Ch)
		db	44 dup (0Ah)
		db	52 dup (08h)
		db	59 dup (6)

game_func_65		proc	near
		mov	bx,level_ref_a
		jmp	level_start

game_func_65		endp

game_func_66		proc	near
		mov	bp,ds:entity_list_ptr

entity_list_loop:
										mov	ax,ds:[bp]
										cmp	ax,0FFFFh
										jne	entity_found			; Jump if not equal
										retn

entity_found:
										call	game_func_68
										jc	entity_list_next			; Jump if carry Set
										mov	al,ds:[bp+3]
										and	al,7
										add	al,61h			; 'a'
										mov	ds:combat_byte_a,al
										mov	ds:combat_byte_b,al
										mov	al,ds:[bp+2]
										xor	ah,ah			; Zero register
										call	vga_operation4
										cmp	bl,4
										jb	entity_hud_normal			; Jump if below
										mov	cx,bx
										sub	bl,27h			; '''
										neg	bl
										inc	bl
										mov	al,bl
										cmp	al,6
										jb	entity_hud_offset			; Jump if below
										mov	al,5

entity_hud_offset:
										sub	cl,4
										xor	ch,ch			; Zero register
										add	di,cx
										mov	si,79C8h
										test	byte ptr ds:[bp+3],80h
										jnz	entity_render_loop			; Jump if not zero
										mov	si,combat_data_tbl
										jmp	short entity_render_loop

entity_list_next:
																		add	bp,0Ch
																		jmp	short entity_list_loop

entity_hud_normal:
										mov	si,79C8h
										test	byte ptr ds:[bp+3],80h
										jnz	entity_hud_flip			; Jump if not zero
										mov	si,combat_data_tbl

entity_hud_flip:
										mov	al,bl
										inc	al
										mov	cl,5
										sub	cl,al
										xor	ch,ch			; Zero register
										add	si,cx

entity_render_loop:
										mov	cx,4

entity_render_rows:
																		push	cx
																		push	ax
																		push	di
																		push	si

hud_copy_loop:
																		call	game_get_value_3
																		inc	di
																		inc	si
																		dec	al
																		jnz	hud_copy_loop			; Jump if not zero
																		pop	si
																		add	si,5
																		xchg	si,di
																		pop	si
																		add	si,24h
																		call	vga_operation5
																		xchg	di,si
																		pop	ax
																		pop	cx
																		loop	entity_render_rows		; Loop if cx > 0

										jmp	short entity_list_next

game_func_66		endp

game_get_value_3		proc	near
		test	byte ptr [di],80h
		jz	copy_to_hud			; Jump if zero
		retn

copy_to_hud:
		mov	dl,[si]
		mov	[di],dl
		retn

game_get_value_3		endp

game_func_68		proc	near
		add	ax,3
		push	ax
		sub	ax,ds:map_width
		pop	bx
		jnc	entity_wrap_check			; Jump if carry=0
		xchg	bx,ax

entity_wrap_check:
		push	ax
		sub	ax,word ptr ds:[80h]
		pop	bx
		jc	entity_left_check			; Jump if carry Set
		xchg	bx,ax
		mov	ax,27h
		sub	ax,bx
		retn

entity_left_check:
		mov	ax,27h
		sub	ax,bx
		jnc	entity_right_wrap			; Jump if carry=0
		retn

entity_right_wrap:
		mov	ax,ds:map_width
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,27h
		sub	ax,bx
		retn

game_func_68		endp
		; ASCII sequence / lookup table
		db	'\'', 0		; 0x0000
		db	'+', 0		; 0x0002
		db	0C3h		; 0x0004
		db	'IJaKLMOPQN_RST`_UVW`IJaKLMX', 0		; 0x0005
		db	'YN_Z', 0		; 0x0021
		db	'[`_\\]^`', 0		; 0x0026
; orphaned scroll/load sequence (dead code, unaligned calls)
		mov	sp,0AAF3h		; BC F3 AA ?-- stack setup
		not	al			; F6 D0
		mov	byte ptr ds:combat_active,al	; A2 F5 9E
		mov	byte ptr ds:prev_chr_id,al	; A2 FE 9E
		mov	byte ptr ds:prev_spr_id,al	; A2 FF 9E
		call	game_func_73		; +0x457
		mov	al,0FFh
		mov	byte ptr ds:sprite_work_buf,al
		mov	byte ptr ds:[0EB67h],al
		mov	byte ptr ds:[0EB6Eh],al
		mov	byte ptr ds:[0EB75h],al
		mov	byte ptr ds:[0FF3Ah],0
		mov	es,cs:gvar_game_seg
		mov	si,sar_ref_scroll
		mov	di,6000h
		mov	al,02h
		call	word ptr cs:[010Ch]	; chunk loader
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,scroll_tile_src
		mov	bp,0D000h
		mov	cx,0E6h
		call	word ptr cs:[3028h]
		pop	ds
		mov	si,ds:map_data_ptr
		lodsb
		call	copy_buffer		; +0x44D
		call	word ptr cs:[2002h]
		mov	si,sar_ref_enemy
		LOAD_CHUNK_ES enemy_id_table, 02h
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,enemy_id_table
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		xor	al,al
		call	word ptr cs:[301Eh]
		mov	al,byte ptr ds:[0C4h]
		or	al,al
		js	$+5
		call	test_dl			; -0xE84 (backward)
		jmp	check_c3		; +0x1EB

game_func_69		proc	near
		call	vga_operation8
		sub	si,25h
		call	vga_operation6
		cmp	byte ptr [si],4Ah	; 'J'
		je	left_side_check			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	center_calc_dist			; Jump if equal
		inc	si
		cmp	byte ptr [si],4Ah	; 'J'
		je	center_no_player			; Jump if equal
		retn

center_no_player:
		test	byte ptr ds:[0C2h],1
		jz	jmp_map_scan_d			; Jump if zero
		retn

jmp_map_scan_d:
		pop	ax
		jmp	map_scan_loop_entry

left_side_check:
		test	byte ptr ds:[0C2h],1
		jnz	jmp_scroll_adv_e			; Jump if not zero
		retn

jmp_scroll_adv_e:
		pop	ax
		jmp	scroll_advance

center_calc_dist:
		mov	ax,word ptr ds:[80h]
		mov	bl,byte ptr ds:[83h]
		add	bl,4
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	bx,ds:map_width
		dec	bx
		sub	bx,ax
		jnc	dist_clamp			; Jump if carry=0
		not	bx
		mov	ax,bx

dist_clamp:
		mov	bl,byte ptr ds:[84h]
		dec	bl
		add	bl,byte ptr ds:[82h]
		and	bl,3Fh			; '?'
		mov	si,ds:entity_list_ptr

entity_search_loop:
;*		cmp	word ptr [si],0FFFFh
												cmp word ptr [si],-1			; was: db 083h,03Ch,0FFh
										jnz	entity_match_check			; Jump if not zero
										retn

entity_match_check:
										cmp	ax,[si]
										jne	entity_search_next			; Jump if not equal
										cmp	bl,[si+2]
										je	entity_match_found			; Jump if equal

entity_search_next:
										add	si,0Ch
										jmp	short entity_search_loop

entity_match_found:
		pop	ax
		test	byte ptr [si+3],80h
		jnz	boss_check			; Jump if not zero
		call	game_func_72
		jc	entity_hit_setup			; Jump if carry Set
		retn

entity_hit_setup:
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:pending_invul,0
		test	byte ptr ds:state_byte_9F19,0FFh
		jz	trigger_hit_snd			; Jump if zero
		retn

trigger_hit_snd:
		mov	byte ptr ds:state_byte_9F19,0FFh
		mov	byte ptr ds:gvar_volume_b,16h
		mov	dx,hit_snd_ref
		jmp	entity_scan_start

boss_check:
		mov	bx,[si+9]
;*		cmp	bx,0FFFFh
				cmp bx,-1			; was: db 083h,0FBh,0FFh
		jz	boss_link_check			; Jump if zero
		mov	al,[si+0Bh]
		or	[bx],al

boss_link_check:
		push	si
		call	game_func_91
		call	fill_buffer
		call	word ptr cs:gfx_fn_render_tile
		call	game_func_73
		call	game_func_46
		mov	si,ds:object_list_ptr
		mov	word ptr [si],0FFFFh
		pop	si
		mov	al,[si+3]
		and	al,7
		push	ax
		mov	ax,[si+5]
		mov	ds:scroll_count,ax
		mov	al,[si+7]
		mov	ds:scroll_dir,al
		mov	al,[si+3]
		and	al,40h			; '@'
		mov	byte ptr ds:[0C3h],al
		mov	al,[si+8]
		mov	ds:state_byte_9F1D,al
		mov	ah,[si+4]
		cmp	byte ptr [si+7],0FFh
		jne	boss_side_check			; Jump if not equal
		or	ah,80h

boss_side_check:
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		test	byte ptr ds:[0C4h],80h
		jnz	boss_func27			; Jump if not zero
		call	game_func_27

boss_func27:
		call	game_func_70
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		test	al,1
		jnz	load_boss_map			; Jump if not zero
		mov	si,sar_ref_boss
		LOAD_CHUNK_ES enemy_id_table, 2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,enemy_id_table
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:gfx_fn_blit
		mov	byte ptr ds:combat_flag2,0FFh
		mov	byte ptr ds:gvar_state_FF24,0Ah
		jmp	short boss_state_init

load_boss_map:
		mov	si,sar_ref_enemy
		LOAD_CHUNK_ES enemy_id_table, 2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,enemy_id_table
		mov	cx,80h
		call	word ptr cs:[2044h]
		pop	ds
		pop	ax
		call	word ptr cs:gfx_fn_blit
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		call	copy_buffer

boss_state_init:
		mov	byte ptr ds:gvar_music_flag_c,0
		mov	byte ptr ds:combat_active,0FFh
		mov	byte ptr ds:enemy_data_buf,0FFh
		test	byte ptr ds:state_byte_9F1D,80h
		jz	check_c3			; Jump if zero
		mov	si,spawn_data_tbl
		push	cs
		pop	es
		mov	di,game_fn_vtable
		mov	al,3
		call	word ptr cs:[10Ch]
		call	word ptr cs:game_fn_vtable
		mov	byte ptr ds:prev_spr_id,0FFh
		mov	byte ptr ds:prev_chr_id,0FFh
		mov	al,byte ptr ds:[0C8h]
		mov	ds:music_track_id,al
		mov	byte ptr ds:loading_flag,0FFh
		call	vga_operation_2
		mov	es,cs:gvar_game_seg
		mov	si,sar_ref_scroll
		mov	di,6000h
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,scroll_tile_src
		mov	bp,0D000h
		mov	cx,0E6h
		call	word ptr cs:gfx_fn_memcpy
		pop	ds
		jmp	check_map_flag

check_c3:
		test	byte ptr ds:[0C3h],0FFh
		jnz	c3_set_loop			; Jump if not zero
		and	byte ptr ds:[0C2h],0FEh
		mov	bx,0A6Eh
		mov	cx,1Ah

intro_left_loop:
										push	cx
										push	bx
										inc	byte ptr ds:[0E7h]
										call	word ptr cs:gfx_fn_render_bg
										pop	bx
										add	bh,2
										push	bx
										call	word ptr cs:gfx_fn_map_ref
										call	game_multiply_3
										pop	bx
										push	bx
										mov	cx,218h
										xor	al,al			; Zero register
										call	word ptr cs:[2000h]
										pop	bx
										pop	cx
										loop	intro_left_loop		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]
		jmp	short check_map_flag

c3_set_loop:
		or	byte ptr ds:[0C2h],1
		mov	bx,406Eh
		mov	cx,1Ah

intro_right_loop:
										push	cx
										push	bx
										inc	byte ptr ds:[0E7h]
										call	word ptr cs:gfx_fn_render_bg
										pop	bx
										sub	bh,2
										push	bx
										call	word ptr cs:gfx_fn_map_ref
										call	game_multiply_3
										pop	bx
										push	bx
										add	bh,4
										mov	cx,218h
										xor	al,al			; Zero register
										call	word ptr cs:[2000h]
										pop	bx
										pop	cx
										loop	intro_right_loop		; Loop if cx > 0

		mov	cx,618h
		xor	al,al			; Zero register
		call	word ptr cs:[2000h]

check_map_flag:
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		mov	ah,al
		and	al,1
		jz	load_map_data			; Jump if zero
		call	vga_operation_2
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		mov	ah,al
		add	ah,ah
		sbb	bl,bl
		mov	ds:gvar_save_flag_1,bl
		add	ah,ah
		sbb	bl,bl
		mov	byte ptr ds:[0E6h],bl
		mov	byte ptr ds:gvar_flag_FF2E,0
		mov	byte ptr ds:gvar_flag_FF2F,0
		call	word ptr cs:[2002h]
		mov	byte ptr ds:[83h],0Ch
		mov	al,ds:player_y
		mov	byte ptr ds:[84h],al
		mov	ds:room_count,al
		mov	byte ptr ds:[0E7h],80h
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,8030h
		mov	cx,66h
		call	word ptr cs:[2044h]
		call	word ptr cs:gfx_fn_map_scroll
		pop	ds
		push	ds
		call	word ptr cs:gfx_fn_palette
		mov	cx,18h
		call	word ptr cs:[2044h]
		pop	ds
		jmp	module_init

load_map_data:
		mov	si,ds:map_data_ptr
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF sar_ref_map, sprite_load_dest, 2
		mov	bx,6000h

level_start:
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		push	bx
		call	game_func_71
		mov	word ptr ds:[80h],ax
		mov	byte ptr ds:[83h],bl
		mov	si,ds:map_data_ptr
		lodsb				; String [si] to al
		shr	al,1			; Shift w/zeros fill
		and	al,1Fh
		mov	byte ptr ds:[0C8h],al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF music_ref_tbl, 3000h, 5
		pop	bx
		xor	al,al			; Zero register
		jmp	word ptr cs:[10Ch]

game_func_69		endp

game_func_70		proc	near
		mov	ax,ds:scroll_count
		add	ax,0FFF0h
		or	ah,ah			; Zero ?
		jns	scroll_pos_ok			; Jump if not sign
		add	ax,ds:map_width

scroll_pos_ok:
		mov	word ptr ds:[80h],ax
		mov	al,ds:scroll_dir
		inc	al
		sub	al,ds:player_y
		and	al,3Fh			; '?'
		mov	byte ptr ds:[82h],al
		retn

game_func_70		endp

game_func_71		proc	near
		mov	bx,0Dh
		mov	ax,ds:scroll_count
		mov	cx,ds:map_width
		sub	cx,bx
		sub	cx,ax
		jnc	scroll_near_end			; Jump if carry=0
		mov	ax,ds:map_width
		add	ax,0FFDCh
		mov	cx,ds:scroll_count
		sbb	cx,ax
		mov	bl,cl
		sub	bl,3
		retn

scroll_near_end:
		add	ax,0FFEFh
		or	ah,ah			; Zero ?
		jnz	scroll_at_start			; Jump if not zero
		retn

scroll_at_start:
		xor	ax,ax			; Zero register
		mov	bl,ds:scroll_count
		sub	bl,4
		retn

game_func_71		endp

game_func_72		proc	near
		mov	bl,[si+8]
		and	bl,1
		jnz	check_99			; Jump if not zero
		test	byte ptr ds:[98h],0FFh
		stc				; Set carry flag
		jnz	decrement_98			; Jump if not zero
		retn

decrement_98:
		dec	byte ptr ds:[98h]
		mov	byte ptr ds:gvar_volume_b,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn

check_99:
		test	byte ptr ds:[99h],0FFh
		stc				; Set carry flag
		jnz	decrement_99			; Jump if not zero
		retn

decrement_99:
		dec	byte ptr ds:[99h]
		mov	byte ptr ds:gvar_volume_b,15h
		or	byte ptr [si+3],80h
		mov	bx,[si+9]
		mov	al,[si+0Bh]
		or	[bx],al
		retn

game_func_72		endp

game_func_73		proc	near
		xor	al,al			; Zero register
		mov	ds:gvar_joystick_flag,al
		mov	ds:gvar_flag_FF44,al
		mov	ds:gvar_palette_flag,al
		mov	ds:gvar_combat_ff3D,al
		mov	ds:gvar_music_flag_a,al
		mov	ds:gvar_save_flag_3,al
		mov	ds:enemy_scroll_flag,al
		mov	ds:gvar_flag_FF3E,al
		mov	ds:gvar_flag_FF4B,al
		mov	ds:gvar_timer_ff08,al
		mov	byte ptr ds:[0E7h],al
		mov	ax,0FFFFh
		mov	ds:enemy_data_buf,al
		mov	ds:enemy_data_buf2,al
		mov	word ptr ds:[0EB15h],ax
		mov	ds:gvar_music_flag_c,al
		mov	ds:combat_active,al
		jmp	hud_fill

game_func_73		endp

copy_buffer		proc	near
		push	cs
		pop	es
		mov	di,combat_flag2
		mov	cx,4
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		shr	al,1			; Shift w/zeros fill
		and	al,0Fh
		mov	ah,al
		mov	al,0FFh
		cmp	ah,byte ptr ds:[0C8h]
		je	same_chr			; Jump if equal
		mov	byte ptr ds:gvar_state_FF24,0Ah
		mov	byte ptr ds:[0C8h],ah
		mov	al,ah

same_chr:
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

copy_buffer		endp

vga_operation_2		proc	near
		mov	es,cs:gvar_game_seg
		mov	si,9C13h
		mov	di,8C00h
		mov	al,2
		call	word ptr cs:[10Ch]
		mov	bl,ds:tile_set_id
		mov	al,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF sar_ref_tileset, enemy_id_table, 2
		mov	bl,ds:player_chr_id
		cmp	bl,0FFh
		jne	chr_changed			; Jump if not equal
		retn

chr_changed:
		cmp	bl,ds:prev_chr_id
		je	spr_check			; Jump if equal
		mov	ds:prev_chr_id,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		add	ax,chr_ref_tbl
		mov	si,ax
		push	cs
		pop	es
		mov	di,game_fn_vtable
		mov	al,3
		call	word ptr cs:[10Ch]

spr_check:
		mov	bl,ds:player_spr_id
		cmp	bl,0FFh
		jne	spr_changed			; Jump if not equal
		retn

spr_changed:
		cmp	bl,ds:prev_spr_id
		je	music_check			; Jump if equal
		mov	ds:prev_spr_id,bl
		mov	al,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF spr_ref_tbl, sprite_load_dest, 2
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,sprite_load_dest
		mov	bp,game_fn_vtable
		mov	cx,100h
		call	word ptr cs:gfx_fn_memcpy
		pop	ds

music_check:
		mov	bl,ds:music_track_id
		cmp	bl,0FFh
		jne	load_music			; Jump if not equal
		retn

load_music:
		push	bx
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr ds:loading_flag,0FFh
		pop	bx
		mov	al,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF music_ref_tbl, 3000h, 5
		retn

vga_operation_2		endp

game_multiply_3		proc	near
		mov	cl,ds:gvar_save_flag
		mov	al,4
		mul	cl			; ax = reg * al

frame_render_loop:
										push	ax
										call	word ptr cs:[110h]
										call	word ptr cs:[112h]
										call	word ptr cs:[114h]
										call	word ptr cs:[116h]
										call	word ptr cs:[118h]
										pop	ax
										cmp	ds:gvar_frame_timer,al
										jb	frame_render_loop			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

game_multiply_3		endp

game_scan_loop_4		proc	near
		mov	si,ds:map_top_ptr

top_list_loop:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	top_item_found			; Jump if not equal
										retn

top_item_found:
										call	game_func_87
										jc	top_item_next			; Jump if carry Set
										mov	ah,bl
										mov	al,[si+2]
										call	vga_operation4
										mov	cx,3
										mov	dl,40h			; '@'

top_draw_cells:
																		call	game_func_89
																		inc	di
																		inc	dl
																		loop	top_draw_cells		; Loop if cx > 0

top_item_next:
										add	si,3
										jmp	short top_list_loop

game_scan_loop_4		endp

game_func_78		proc	near
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_music_b5			; Jump if zero
		retn

check_music_b5:
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	dl,40h			; '@'
		call	game_func_82
		jz	top_find_entry			; Jump if zero
		retn

top_find_entry:
		mov	di,ds:map_top_ptr
		mov	dl,40h			; '@'
		call	game_process_loop_3
		jnc	check_vga9			; Jump if carry=0
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		jmp	process_loop_end

check_vga9:
		call	vga_operation9
		jnc	check_bits60			; Jump if carry=0
		retn

check_bits60:
		and	al,60h			; '`'
		jz	check_bit20			; Jump if zero
		retn

check_bit20:
		test	byte ptr [bx+5],20h	; ' '
		jz	mark_entity_40			; Jump if zero
		retn

mark_entity_40:
		or	byte ptr [bx+5],40h	; '@'
		and	byte ptr [bx+5],0E0h
		retn

game_func_78		endp

game_process_loop_3		proc	near
		push	dx
		call	game_func_81
		pop	dx
		mov	bx,si
		add	si,23h
		call	vga_operation5
		test	byte ptr [si],80h
		clc				; Clear carry flag
		jz	check_3slots			; Jump if zero
		retn

check_3slots:
		mov	cx,3

check_3_slots:
										inc	si
										test	byte ptr [si],0FFh
										jz	slot_empty_ok			; Jump if zero
										retn

slot_empty_ok:
										loop	check_3_slots		; Loop if cx > 0

		mov	si,bx
		add	si,24h
		call	vga_operation5
		push	di
		mov	di,si
		mov	cx,3

draw_3_cells:
										push	dx
										push	bx
										call	game_func_89
										pop	bx
										xchg	di,bx
										push	bx
										xor	dl,dl			; Zero register
										call	game_func_89
										pop	bx
										xchg	di,bx
										inc	di
										inc	bx
										pop	dx
										inc	dl
										loop	draw_3_cells		; Loop if cx > 0

		pop	di
		inc	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		stc				; Set carry flag
		retn

game_process_loop_3		endp

game_func_80		proc	near
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jz	check_music_b6			; Jump if zero
		retn

check_music_b6:
		call	vga_operation8
		sub	si,23h
		call	vga_operation6
		mov	al,[si]
		call	game_check_state_2
		jz	check_tile_valid			; Jump if zero
		retn

check_tile_valid:
		add	si,90h
		call	vga_operation5
		mov	dl,40h			; '@'
		call	game_func_82
		jz	find_bottom_entry			; Jump if zero
		retn

find_bottom_entry:
		mov	di,ds:map_top_ptr
		mov	dl,40h			; '@'
		push	dx
		call	game_func_81
		pop	dx
		mov	ax,si
		sub	si,24h
		call	vga_operation6
		mov	bx,si
		sub	si,24h
		call	vga_operation6
		mov	cx,3

check_bot_wall:
										test	byte ptr [si],80h
										jz	check_si_wall			; Jump if zero
										retn

check_si_wall:
										test	byte ptr [bx],0FFh
										jz	check_bx_empty			; Jump if zero
										retn

check_bx_empty:
										inc	si
										inc	bx
										loop	check_bot_wall		; Loop if cx > 0

		mov	bx,ax
		mov	si,bx
		sub	si,24h
		call	vga_operation6
		push	di
		mov	di,si
		mov	cx,3

draw_3_cells_b:
										push	dx
										push	bx
										call	game_func_89
										pop	bx
										xchg	di,bx
										push	bx
										xor	dl,dl			; Zero register
										call	game_func_89
										pop	bx
										xchg	di,bx
										inc	di
										inc	bx
										pop	dx
										inc	dl
										loop	draw_3_cells_b		; Loop if cx > 0

		pop	di
		dec	byte ptr [di+2]
		and	byte ptr [di+2],3Fh	; '?'
		pop	ax
		pop	ax
		mov	byte ptr ds:[0E7h],80h
		mov	byte ptr ds:gvar_combat_ff3D,0
		jmp	pos_scroll_up

game_func_80		endp

game_func_81		proc	near
		mov	al,byte ptr ds:[83h]
		add	al,4
		add	al,dh
		xor	ah,ah			; Zero register
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:map_width
		jb	map_col_calc			; Jump if below
		sub	ax,ds:map_width

map_col_calc:
		mov	cl,byte ptr ds:[82h]
		add	cl,byte ptr ds:[84h]
		add	cl,3
		and	cl,3Fh			; '?'

map_entry_search:
										cmp	ax,[di]
										jne	map_entry_next			; Jump if not equal
										cmp	cl,[di+2]
										je	map_entry_found			; Jump if equal

map_entry_next:
										add	di,3
										jmp	short map_entry_search

map_entry_found:
		call	game_func_87
		mov	al,[di+2]
		mov	ah,bl
		push	di
		call	vga_operation4
		mov	si,di
		pop	di
		retn

game_func_81		endp

game_func_82		proc	near
		mov	dh,1
		cmp	dl,[si]
		jne	col_match_b			; Jump if not equal
		retn

col_match_b:
		dec	dh
		inc	dl
		cmp	dl,[si]
		jne	col_match_c			; Jump if not equal
		retn

col_match_c:
		dec	dh
		inc	dl
		cmp	dl,[si]
		retn

game_func_82		endp

game_scan_loop_5		proc	near
		mov	si,ds:map_bot_ptr

bot_list_loop:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	bot_item_found			; Jump if not equal
										retn

bot_item_found:
										call	game_func_87
										jc	bot_item_next			; Jump if carry Set
										mov	ah,bl
										mov	al,[si+2]
										call	vga_operation4
										mov	cx,3
										mov	dl,43h			; 'C'

bot_draw_cells:
																		call	game_func_89
																		inc	di
																		inc	dl
																		loop	bot_draw_cells		; Loop if cx > 0

bot_item_next:
										add	si,3
										jmp	short bot_list_loop

game_scan_loop_5		endp

game_func_84		proc	near
		call	vga_operation8
		add	si,6Dh
		call	vga_operation5
		mov	dl,43h			; 'C'
		call	game_func_82
		jz	bot_find_entry			; Jump if zero
		retn

bot_find_entry:
		mov	di,ds:map_bot_ptr
		mov	dl,43h			; 'C'
		call	game_process_loop_3
		jc	jmp_process_end			; Jump if carry Set
		retn

jmp_process_end:
		jmp	process_loop_end

game_func_84		endp

game_func_85		proc	near
		inc	byte ptr ds:state_byte_9F07
		mov	si,ds:map_extra_ptr

extra_list_loop:
		mov	ax,[si]
		cmp	ax,0FFFFh
		jne	extra_item_found			; Jump if not equal
		retn

extra_item_found:
		and	ax,3FFFh
		call	game_func_88
		jc	extra_fn_check			; Jump if carry Set
		mov	cl,bl
		dec	bx
		dec	bx
		or	bh,bh			; Zero ?
		jns	extra_offset_ok			; Jump if not sign
		inc	cl
		mov	al,[si+2]
		xor	ah,ah			; Zero register
		call	vga_operation4
		jmp	short extra_draw_cells

extra_offset_ok:
		mov	ax,bx
		sub	ax,22h
		jc	extra_offset_small			; Jump if carry Set
		push	ax
		mov	al,[si+2]
		mov	ah,22h			; '"'
		call	vga_operation4
		pop	ax
		add	di,ax
		mov	cl,al
		neg	cl
		add	cl,2
		jmp	short extra_draw_cells

extra_offset_small:
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cl,3

extra_draw_cells:
		xor	ch,ch			; Zero register
		xor	dl,dl			; Zero register

extra_draw_loop:
										call	game_func_89
										inc	di
										loop	extra_draw_loop		; Loop if cx > 0

extra_fn_check:
		mov	ax,[si]
		mov	bl,ah
		and	ax,3FFFh
		rol	bl,1			; Rotate
		rol	bl,1			; Rotate
		and	bl,3
		jz	extra_draw_normal			; Jump if zero
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:entity_fn_tbl_a[bx]	;*

extra_draw_normal:
		call	game_func_87
		jc	extra_item_next			; Jump if carry Set
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		mov	cx,3
		mov	dl,46h			; 'F'

extra_normal_draw:
										call	game_func_89
										inc	di
										inc	dl
										loop	extra_normal_draw		; Loop if cx > 0

extra_item_next:
		add	si,7
		jmp	extra_list_loop

game_func_85		endp

entity_fn_a_0:
			                        ; entity_fn_tbl_a target: handler fn 0
		dec	dx
;*		adc	byte ptr [bp+si-7Eh],52h	; 'R'
			db	82h, 52h, 82h, 52h			; adc byte ptr [bp+si-7Eh],52h (alt opcode 82h)
;*		xor	dh,6
			db	82h, 0F6h, 06h			; xor dh, 6 (alt opcode 82h)
		pop	es
		lahf				; Load ah from flags
		add	[di+1],si
		retn

entity_fn_a_1:
			                        ; entity_fn_tbl_a target: handler fn 1 (bit-clear and direction update)
		mov	cl,[si+2]
		and	byte ptr [si+2],0BFh
		test	cl,40h			; '@'
		jz	extra_no_80			; Jump if zero
		retn

extra_no_80:
		test	byte ptr [si+2],80h
		jnz	extra_go_left			; Jump if not zero
		inc	ax
		mov	bx,ax
		sub	ax,ds:map_width
		jz	extra_wrap_check			; Jump if zero
		xchg	bx,ax

extra_wrap_check:
		push	si
		push	ax
		call	game_scan_loop_6
		jc	extra_scan_done			; Jump if carry Set
		call	game_process_loop

extra_scan_done:
		pop	ax
		pop	si
		mov	bx,[si+5]
		jmp	short extra_update_pos

extra_go_left:
		dec	ax
		cmp	ax,0FFFFh
		jne	extra_left_wrap			; Jump if not equal
		mov	ax,ds:map_width
		dec	ax

extra_left_wrap:
		push	si
		push	ax
		call	game_scan_loop_6
		jc	extra_scan_done2			; Jump if carry Set
		call	game_func_15

extra_scan_done2:
		pop	ax
		pop	si
		mov	bx,[si+3]

extra_update_pos:
		mov	dl,[si+1]
		and	dl,0C0h
		or	dl,ah
		mov	[si],al
		mov	[si+1],dl
		sub	bx,ax
		jz	extra_toggle_dir			; Jump if zero
		retn

extra_toggle_dir:
		xor	byte ptr [si+2],80h
		or	byte ptr [si+2],40h	; '@'
		retn

game_scan_loop_6		proc	near
		mov	dl,ds:gvar_combat_ff3D
		or	dl,ds:gvar_music_flag_b
		stc				; Set carry flag
		jz	check_row_match			; Jump if zero
		retn

check_row_match:
		mov	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		add	al,3
		and	al,3Fh			; '?'
		mov	ah,[si+2]
		and	ah,3Fh			; '?'
		cmp	al,ah
		stc				; Set carry flag
		jz	check_col_match			; Jump if zero
		retn

check_col_match:
		mov	ax,[si]
		and	ax,3FFFh
		call	game_func_87
		jnc	check_col_range			; Jump if carry=0
		retn

check_col_range:
		mov	dl,byte ptr ds:[83h]
		add	dl,4
		mov	cx,3

col_range_check:
										cmp	dl,al
										clc				; Clear carry flag
										jnz	col_range_next			; Jump if not zero
										retn

col_range_next:
										inc	dl
										loop	col_range_check		; Loop if cx > 0

		stc				; Set carry flag
		retn

game_scan_loop_6		endp

game_func_87		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	screen_left_check			; Jump if carry Set
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn

screen_left_check:
		mov	ax,21h
		sub	ax,bx
		jnc	screen_wrap_right			; Jump if carry=0
		retn

screen_wrap_right:
		mov	ax,ds:map_width
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,21h
		sub	ax,bx
		retn

game_func_87		endp

game_func_88		proc	near
		add	ax,2
		mov	bx,ax
		sub	ax,ds:map_width
		jnc	screen_left2			; Jump if carry=0
		xchg	bx,ax

screen_left2:
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jc	screen_wrap_left			; Jump if carry Set
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn

screen_wrap_left:
		mov	ax,25h
		sub	ax,bx
		jnc	screen_right_wrap			; Jump if carry=0
		retn

screen_right_wrap:
		mov	ax,ds:map_width
		sub	ax,word ptr ds:[80h]
		add	ax,bx
		xchg	bx,ax
		mov	ax,25h
		sub	ax,bx
		retn

game_func_88		endp

game_func_89		proc	near
		test	byte ptr [di],80h
		jnz	obj_slot_write			; Jump if not zero
		mov	[di],dl
		retn

obj_slot_write:
		mov	bl,[di]
		and	bl,7Fh
		xor	bh,bh			; Zero register
		mov	ds:enemy_data_ext[bx],dl
		retn

game_func_89		endp

game_check_state_5		proc	near
		mov	si,enemy_data_buf

enemy_scan_loop:
										cmp	byte ptr [si],0FFh
										jne	enemy_found			; Jump if not equal
										retn

enemy_found:
										push	si
										call	game_func_92
										pop	si
										mov	al,[si]
										mov	[si+0Bh],al
										sub	al,4
										cmp	al,1Ch
										jae	enemy_deactivate_here			; Jump if above or =
										mov	al,[si+1]
										sub	al,byte ptr ds:[82h]
										and	al,3Fh			; '?'
										cmp	al,12h
										jae	enemy_deactivate_here			; Jump if above or =
										mov	[si+0Ch],al
										mov	ah,[si+0Bh]
										push	ax
										call	game_multiply_4
										pop	ax
										cmp	byte ptr [di],0FFh
										je	enemy_next			; Jump if equal
										cmp	byte ptr [di],0FCh
										je	enemy_next			; Jump if equal
										call	word ptr cs:gfx_fn_77
										or	di,8000h
										mov	[si+7],di
										mov	al,[si+2]
										mov	bl,al
										rol	bl,1			; Rotate
										rol	bl,1			; Rotate
										and	bx,3
										mov	bl,ds:entity_type_map[bx]
										and	bl,[si+3]
										add	al,bl
										and	al,3Fh			; '?'
										and	di,7FFFh
										call	word ptr cs:gfx_fn_hud_draw

enemy_next:
																		add	si,0Dh
																		jmp	short enemy_scan_loop

enemy_deactivate_here:
										mov	byte ptr [si],0
										jmp	short enemy_next

game_check_state_5		endp

entity_fn_tbl_b_data:
			                        ; Padding/data block (dispatch table alignment)
		add	[bx+di],al
		add	ax,[bx]

game_func_91		proc	near
		mov	si,enemy_data_buf

enemy_all_scan:
										cmp	byte ptr [si],0FFh
										je	enemy_all_done			; Jump if equal
										push	si
										call	game_func_92
										pop	si
										add	si,0Dh
										jmp	short enemy_all_scan

enemy_all_done:
		mov	byte ptr ds:enemy_data_buf,0FFh
		retn

game_func_91		endp

game_func_92		proc	near
		test	word ptr [si+7],8000h
		jnz	enemy_blit_check			; Jump if not zero
		retn

enemy_blit_check:
		and	word ptr [si+7],7FFFh
		mov	dx,[si+7]
		mov	al,[si+0Ch]
		mov	ah,[si+0Bh]

game_func_92		endp

game_func_93		proc	near

enemy_blit_loop:
		push	ax
		call	game_multiply_4
		pop	ax
		cmp	byte ptr [di],0FCh
		jb	enemy_do_blit			; Jump if below
		retn

enemy_do_blit:
		add	al,byte ptr ds:[82h]
		call	vga_operation4
		mov	al,[di]
		jmp	word ptr cs:gfx_fn_78

game_func_93		endp

copy_buffer_2		proc	near
		mov	si,enemy_data_buf
		mov	di,enemy_data_buf
		push	cs
		pop	es
		mov	byte ptr ds:state_byte_9F1F,0

sprite_buf_scan:
										mov	al,[si]
										or	al,al			; Zero ?
										jnz	sprite_active			; Jump if not zero
										test	word ptr [si+7],8000h
										jz	sprite_buf_next			; Jump if zero

sprite_active:
										inc	al
										jnz	sprite_live			; Jump if not zero
										mov	byte ptr [di],0FFh
										retn

sprite_live:
										inc	byte ptr [si+3]
										push	es
										push	di
										call	game_scan_loop_7
										pop	di
										pop	es
										push	si
										mov	cx,0Dh
										rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
										pop	si
										test	byte ptr [si+5],40h	; '@'
										jnz	sprite_inc_1f			; Jump if not zero
										mov	al,[si+3]
										cmp	al,[si+4]
										jb	sprite_inc_1f			; Jump if below
										mov	byte ptr [si],0

sprite_inc_1f:
										inc	byte ptr ds:state_byte_9F1F

sprite_buf_next:
										add	si,0Dh
										jmp	short sprite_buf_scan

copy_buffer_2		endp

game_scan_loop_7		proc	near
		call	game_func_97
		test	byte ptr [si+5],8
		jnz	sprite_check_row			; Jump if not zero
		mov	ah,[si]
		or	ah,ah			; Zero ?
		jnz	sprite_check_col			; Jump if not zero
		retn

sprite_check_col:
		mov	al,[si+1]
		call	vga_operation4
		mov	al,[di]
		call	game_func_41
		jz	sprite_check_row			; Jump if zero
		mov	byte ptr [si],0
		retn

sprite_check_row:
		mov	al,byte ptr ds:[82h]
		add	al,byte ptr ds:[84h]
		test	byte ptr ds:gvar_music_flag_a,0FFh
		jnz	sprite_row_scan			; Jump if not zero
		and	al,3Fh			; '?'
		cmp	al,[si+1]
		je	sprite_row_match			; Jump if equal

sprite_row_scan:
		mov	cx,2

row_scan_loop:
										inc	al
										and	al,3Fh			; '?'
										cmp	al,[si+1]
										je	sprite_row_match			; Jump if equal
										loop	row_scan_loop		; Loop if cx > 0

		retn

sprite_row_match:
		mov	al,byte ptr ds:[83h]
		add	al,4
		test	byte ptr ds:[0C2h],1
		jz	sprite_col_adjust			; Jump if zero
		inc	al

sprite_col_adjust:
		cmp	al,[si]
		je	sprite_hit_check			; Jump if equal
		inc	al
		cmp	al,[si]
		je	sprite_hit_check			; Jump if equal
		retn

sprite_hit_check:
		mov	byte ptr [si],0
		test	byte ptr ds:[93h],0FFh
		jz	entity_kill			; Jump if zero
		test	byte ptr ds:gvar_joystick_flag,0FFh
		jnz	entity_kill			; Jump if not zero
		test	byte ptr ds:gvar_music_flag_b,0FFh
		jnz	entity_kill			; Jump if not zero
		mov	al,[si+5]
		and	al,7
		cmp	al,2
		je	entity_kill			; Jump if equal
		cmp	al,6
		je	entity_kill			; Jump if equal
		or	al,al			; Zero ?
		jz	entity_process_skip			; Jump if zero
		cmp	al,1
		je	entity_process_skip			; Jump if equal
		cmp	al,7
		je	entity_process_skip			; Jump if equal
		test	byte ptr ds:[0C2h],1
		jnz	entity_kill			; Jump if not zero
		jmp	short sprite_check_93

entity_process_skip:
		test	byte ptr ds:[0C2h],1
		jnz	sprite_check_93			; Jump if not zero

entity_kill:
										mov	al,[si+6]
										xor	ah,ah			; Zero register
										call	game_func_60
										mov	byte ptr ds:gvar_volume_b,9
										mov	al,0FFh
										mov	ds:any_entity_active,al
										mov	ds:gvar_save_flag_3,al
										mov	bx,0FFFFh
										mov	cx,0FFFFh
										mov	al,[si+5]
										and	al,7
										cmp	al,2
										je	entity_hit			; Jump if equal
										cmp	al,6
										je	entity_hit			; Jump if equal
										xor	bx,bx			; Zero register
										or	al,al			; Zero ?
										jz	entity_hit			; Jump if zero
										cmp	al,1
										je	entity_hit			; Jump if equal
										cmp	al,7
										je	entity_hit			; Jump if equal
										xchg	cx,bx

entity_hit:
										mov	ds:entity_slot_tbl,cx
										mov	ds:state_word_9F10,bx
										retn

sprite_check_93:
										cmp	byte ptr ds:[93h],4
										jae	set_vol_0a			; Jump if above or =
										mov	al,byte ptr ds:[84h]
										add	al,byte ptr ds:[82h]
										inc	al
										test	byte ptr ds:gvar_music_flag_a,0FFh
										jz	call_func96			; Jump if zero
										inc	al

call_func96:
										call	game_func_96
										jc	entity_kill			; Jump if carry Set

set_vol_0a:
		mov	byte ptr ds:gvar_volume_b,0Ah
		retn

game_scan_loop_7		endp

game_func_96		proc	near
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		and	al,3Fh			; '?'
		jmp	word ptr ds:entity_fn_tbl_b[bx]	;*

game_func_96		endp

entity_fn_b_0:
			                        ; entity_fn_tbl_b target: handler fn 0
		xchg	cx,ax
		test	bx,ds:hitbox_map_tbl[bx+di]
		test	bx,ds:collision_map_tbl[bx+di]
		test	bx,ds:entity_extra_tbl[bx]
		test	bx,gfx_fn_hitbox_data[bx]

entity_fn_return:
																		inc	sp
																		add	[di+1],si
																		retn

entity_fn_b_1:
																			                        ; entity_fn_tbl_b target: handler fn 1 (stc; retn)
																		stc				; Set carry flag
																		retn

entity_fn_b_2:
																			                        ; entity_fn_tbl_b target: handler fn 2 (dec al, mask)
																		dec	al
																		and	al,3Fh			; '?'
;*		jmp	short loc_469		;*
																			db	0EBh, 0F2h			; jmp short -0xE (mid-instruction target; keep as bytes)

entity_fn_b_3:
																			                        ; entity_fn_tbl_b target: handler fn 3 (inc al, mask)
																		inc	al
																		and	al,3Fh			; '?'
;*		jmp	short loc_469		;*
																		jmp	short entity_fn_return
																		jmp	short entity_fn_return
										jmp	short entity_fn_return
		db	0EBh			; was: db 0ECh, 00Ch

game_func_97		proc	near
		test	byte ptr [si+5],40h	; '@'
		jz	call_entity_fn			; Jump if zero
		call	game_func_98
		jnc	call_entity_fn			; Jump if carry=0
		retn

call_entity_fn:
		mov	bl,[si+5]
		and	bx,7
		add	bx,bx
		call	word ptr ds:entity_fn_tbl_c[bx]	;*
		and	byte ptr [si+1],3Fh	; '?'
		retn

game_func_97		endp

entity_fn_c_0:
			                        ; entity_fn_tbl_c target: handler fn 0 (rotate/dispatch block)
;*		aad	85h			; undocumented inst
				aad 85h			; was: db 0D5h,085h
		rol	byte ptr ds:entity_rotate_buf[di],cl	; Rotate
		dw	85DEh		; dispatch entry 0
		dw	85E1h		; dispatch entry 1
		dw	85E4h		; dispatch entry 2
		dw	85EAh		; dispatch entry 3
		dw	85D8h		; dispatch entry 4
; dispatch targets:
		dec	byte ptr [si+1]
		inc	byte ptr [si]
		retn
		inc	byte ptr [si+1]
		inc	byte ptr [si]
		retn
		dec	byte ptr [si+1]
		dec	byte ptr [si]
		retn
		inc	byte ptr [si+1]
		dec	byte ptr [si]
		retn
		inc	byte ptr [si+1]
		retn
		dec	byte ptr [si+1]
		retn

game_func_98		proc	near
		mov	bl,[si+3]
		xor	bh,bh			; Zero register
		mov	di,[si+9]
		mov	al,[bx+di]
		cmp	al,0FFh
		jne	update_dir_bits			; Jump if not equal
		mov	byte ptr ds:[80h][si],0
		stc				; Set carry flag
		retn

update_dir_bits:
		and	al,7
		and	byte ptr [si+5],0F8h
		or	[si+5],al
		retn

game_func_98		endp

entity_fn_c_1:
			                        ; entity_fn_tbl_c target: handler fn 1 (state byte 9F1F check)
		cmp	byte ptr ds:state_byte_9F1F,1Fh
		jb	check_state1f			; Jump if below
		retn

check_state1f:
		push	si
		push	cs
		pop	es
		mov	si,bx
		mov	di,enemy_data_buf

find_free_slot:
										cmp	byte ptr [di],0FFh
										je	free_slot_found			; Jump if equal
										add	di,0Dh
										jmp	short find_free_slot

free_slot_found:
		mov	cx,0Dh
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		inc	byte ptr ds:state_byte_9F1F
		pop	si
		retn

game_func_99		proc	near
		mov	si,enemy_data_buf

enemy_dec_scan:
										mov	al,[si]
										cmp	al,0FFh
										jne	enemy_dec_check			; Jump if not equal
										retn

enemy_dec_check:
										or	al,al			; Zero ?
										jz	enemy_dec_next			; Jump if zero
										dec	byte ptr [si]

enemy_dec_next:
										add	si,0Dh
										jmp	short enemy_dec_scan

game_func_99		endp

game_func_100		proc	near
		mov	si,enemy_data_buf

enemy_inc_scan:
										mov	al,[si]
										cmp	al,0FFh
										jne	enemy_inc_check			; Jump if not equal
										retn

enemy_inc_check:
										or	al,al			; Zero ?
										jz	enemy_inc_next			; Jump if zero
										inc	byte ptr [si]

enemy_inc_next:
										add	si,0Dh
										jmp	short enemy_inc_scan

game_func_100		endp

game_multiply_4		proc	near
		and	al,3Fh			; '?'
		mov	bl,ah
		mov	bh,1Ch
		mul	bh			; ax = reg * al
		sub	bl,4
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		add	di,hud_buf
		retn

game_multiply_4		endp

game_func_102		proc	near
		mov	si,sprite_work_buf
		mov	cx,4

sprite_wbuf_scan:
										push	cx
										cmp	byte ptr [si],0FFh
										je	entity_loop_next			; Jump if equal
										call	game_func_103
										test	byte ptr [si+2],0FFh
										jnz	sprite_entry_ok			; Jump if not zero
										mov	byte ptr [si],0FFh
										jmp	short entity_loop_next

sprite_entry_ok:
										mov	bl,[si]
										and	bl,0Fh
										xor	bh,bh			; Zero register
										add	bx,bx
										add	bx,entity_data_base
										mov	ah,byte ptr ds:[83h]
										add	ah,[bx]
										mov	[si+5],ah
										mov	al,byte ptr ds:[84h]
										add	al,[bx+1]
										and	al,3Fh			; '?'
										mov	[si+6],al
										push	ax
										call	game_multiply_4
										pop	ax
										cmp	byte ptr [di],0FFh
										je	entity_loop_next			; Jump if equal
										cmp	byte ptr [di],0FCh
										je	entity_loop_next			; Jump if equal
										call	word ptr cs:gfx_fn_77
										or	di,8000h
										mov	[si+3],di
										mov	al,66h			; 'f'
										and	di,7FFFh
										push	si
										call	word ptr cs:gfx_fn_hud_draw
										pop	si

entity_loop_next:
										add	si,7
										pop	cx
										loop	sprite_wbuf_scan		; Loop if cx > 0

		retn

game_func_102		endp

game_func_103		proc	near
		test	word ptr [si+3],8000h
		jnz	boss_sprite_blit			; Jump if not zero
		retn

boss_sprite_blit:
		and	word ptr [si+3],7FFFh
		mov	dx,[si+3]
		mov	ah,[si+5]
		mov	al,[si+6]
		jmp	enemy_blit_loop

game_func_103		endp

game_scan_loop_8		proc	near
		mov	si,sprite_work_buf
		mov	cx,4

sprite_update_loop:
										push	cx
										cmp	byte ptr [si],0FFh
										je	sprite_wbuf_next			; Jump if equal
										mov	bl,[si]
										add	bl,[si+1]
										and	bl,0Fh
										mov	[si],bl
										xor	bh,bh			; Zero register
										add	bx,bx
										add	bx,entity_data_base
										mov	ah,byte ptr ds:[83h]
										add	ah,[bx]
										mov	al,byte ptr ds:[84h]
										add	al,[bx+1]
										add	al,byte ptr ds:[82h]
										call	vga_operation4
										xchg	si,di
										sub	si,25h
										call	vga_operation6
										xchg	si,di
										call	game_func_105

sprite_wbuf_next:
										add	si,7
										pop	cx
										loop	sprite_update_loop		; Loop if cx > 0

		retn

game_scan_loop_8		endp

game_func_105		proc	near
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	check_flags_ok			; Jump if zero
		test	byte ptr ds:gvar_flag_FF30,0FFh
		jz	check_flags_ok			; Jump if zero
		retn

check_flags_ok:
		call	game_func_106
		inc	di
		call	game_func_106
		xchg	si,di
		add	si,23h
		call	vga_operation5
		xchg	si,di
		call	game_func_106
		inc	di

game_func_105		endp

game_func_106		proc	near
		test	byte ptr [si+2],0FFh
		jnz	check_vga9_b			; Jump if not zero
		retn

check_vga9_b:
		xchg	si,di
		call	vga_operation9
		xchg	si,di
		jnc	check_bit20_b			; Jump if carry=0
		retn

check_bit20_b:
		test	byte ptr [bx+4],20h	; ' '
		jz	check_bit20_c			; Jump if zero
		retn

check_bit20_c:
		test	byte ptr [bx+5],20h	; ' '
		jz	set_slot_bits			; Jump if zero
		retn

set_slot_bits:
		and	byte ptr [bx+5],0E0h
		or	byte ptr [bx+5],49h	; 'I'
		dec	byte ptr [si+2]
		retn

game_func_106		endp

entity_fn_d_data:
			                        ; Data block after game_func_106 (dispatch table alignment)
		add	al,[bx+di]
		add	al,[bx+si]
		add	di,di
		add	al,0FEh
		add	ax,6FEh
		inc	byte ptr [bx]
		dec	word ptr [bx+si]
		add	[bx+si],cl
		add	[bx+si],cx
		add	al,[bx]
		add	ax,word ptr ds:[504h]
		add	al,4

sub_27B4:
		add	al,3
		add	ax,[bp+si]
		add	dh,dh
		push	es
		popf				; Pop flags
;*		add	bh,bh
			db	00h, 0FFh			; add bh, bh (alt form: ADD r/m8, r8)
		jnz	palette_check			; Jump if not zero
		retn

palette_check:
		test	byte ptr ds:gvar_palette_flag,0FFh
		jnz	palette_step			; Jump if not zero
		test	byte ptr ds:gvar_state_b,0FFh
		jnz	state_b_active			; Jump if not zero
		retn

state_b_active:
		mov	byte ptr ds:gvar_skip_input,0
		mov	byte ptr ds:gvar_state_b,0
		test	byte ptr ds:gvar_joystick_flag,0FFh
		jz	check_flag3e			; Jump if zero
		retn

check_flag3e:
		test	byte ptr ds:gvar_flag_FF3E,0FFh
		jz	set_palette_ff			; Jump if zero
		retn

set_palette_ff:
		mov	byte ptr ds:state_byte_9F2B,0
		mov	byte ptr ds:gvar_palette_flag,0FFh
		mov	byte ptr ds:gvar_volume_b,17h
		retn

palette_step:
		add	byte ptr ds:state_byte_9F2B,2
		cmp	byte ptr ds:state_byte_9F2B,4
		je	check_ab_slot			; Jump if equal
		cmp	byte ptr ds:state_byte_9F2B,6
		jae	palette_end			; Jump if above or =
		retn

palette_end:
		mov	byte ptr ds:gvar_palette_flag,0
		retn

check_ab_slot:
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		test	byte ptr ds:[0ABh][bx],0FFh
		jnz	decrement_ab			; Jump if not zero
		retn

decrement_ab:
		dec	byte ptr ds:[0ABh][bx]
		call	word ptr cs:[2018h]
		mov	byte ptr ds:gvar_volume_b,18h
		mov	si,0EB15h
		mov	byte ptr ds:gvar_flag_FF3E,0FFh
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:entity_fn_tbl_d[bx]	;*

entity_fn_d_0:
			                        ; entity_fn_tbl_d target: handler fn 0 (fire slot init)
		dec	bp
		mov	[di-78h],cl
		dec	bp
		mov	[di-78h],cl
		test	al,88h
		clc				; Clear carry flag
		mov	[bx+si],bl
		mov	word ptr ds:[0C2h][bx+si],sp
		not	al
		and	al,1
		mov	[si+3],al
		mov	al,ds:gvar_music_flag_a
		and	al,1
		add	al,byte ptr ds:[84h]
		add	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	[si+2],al
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,[si+3]
		not	ah
		and	ah,1
		add	al,ah
		xor	ah,ah			; Zero register
		add	ax,word ptr ds:[80h]
		cmp	ax,ds:map_width
		jb	init_fire_entry			; Jump if below
		sub	ax,ds:map_width

init_fire_entry:
		mov	[si],ax
		mov	byte ptr [si+9],0
		mov	byte ptr [si+0Bh],0
		mov	byte ptr [si+0Dh],0
		mov	byte ptr [si+0Fh],0
		mov	byte ptr [si+4],0
		mov	byte ptr [si+5],0
		mov	word ptr [si+10h],0FFFFh
		retn
		mov	cx,4			; B9 04 00

fire_init_loop:
										push	cx
										mov	al,6
										mul	cl			; ax = reg * al
										add	ax,2
										add	ax,word ptr ds:[80h]
										cmp	ax,ds:map_width
										jb	fire_entry_col			; Jump if below
										sub	ax,ds:map_width

fire_entry_col:
										mov	[si],ax
										call	word ptr cs:[11Ah]
										and	al,3
										mov	ah,byte ptr ds:[82h]
										sub	ah,3
										sub	ah,al
										and	ah,3Fh			; '?'
										mov	[si+2],ah
										mov	byte ptr [si+9],0
										mov	byte ptr [si+0Bh],0
										mov	byte ptr [si+0Dh],0
										mov	byte ptr [si+0Fh],0
										mov	byte ptr [si+4],0
										mov	byte ptr [si+5],0
										add	si,10h
										pop	cx
										loop	fire_init_loop		; Loop if cx > 0

		retn
		push	si			; 56h
		mov	cx,3			; B9 03 00

fire_init_loop2:
										push	cx
;*		call	game_func_108			;*
											db	0E8h, 04Dh, 0FFh		; call near 2854h (mid-instruction target; keep as bytes)
										add	si,10h
										pop	cx
										loop	fire_init_loop2		; Loop if cx > 0

		pop	si
		sub	byte ptr [si+2],2
		and	byte ptr [si+2],3Fh	; '?'
		add	byte ptr [si+12h],2
		and	byte ptr [si+12h],3Fh	; '?'
		retn

boss_scroll_init:
			                        ; Boss scroll init handler (resets anim counters, dispatch target)
		mov	byte ptr ds:anim_ctr_x,0FFh
		mov	byte ptr ds:anim_ctr_y,0FFh
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	boss_scroll_scan			; Jump if zero
		test	byte ptr ds:gvar_flag_FF2E,0FFh
		jnz	boss_scroll_done			; Jump if not zero

boss_scroll_scan:
		mov	si,ds:gvar_scroll_pos
		sub	si,24h
		call	vga_operation6
		mov	cx,13h

boss_scroll_outer:
										push	cx
										mov	cx,24h

boss_scroll_inner:
																		push	cx
																		test	byte ptr [si],80h
																		jz	scan_for_obj			; Jump if zero
																		call	game_func_115

scan_for_obj:
																		inc	si
																		pop	cx
																		loop	boss_scroll_inner		; Loop if cx > 0

										call	vga_operation5
										pop	cx
										loop	boss_scroll_outer		; Loop if cx > 0

boss_scroll_done:
		mov	byte ptr ds:gvar_flag_FF3E,0
		mov	byte ptr ds:gvar_volume_b,19h
		call	word ptr cs:gfx_fn_83
		mov	byte ptr ds:gvar_state_b,0
		call	fill_buffer
		jmp	frame_state_update

game_func_109		proc	near
		mov	si,0EB15h
		mov	cx,4

boss_entry_check:
;*		cmp	word ptr [si],0FFFFh
				cmp word ptr [si],-1			; was: db 083h,03Ch,0FFh
		jnz	boss_entry_found			; Jump if not zero
		retn

boss_entry_found:
		push	cx
		call	game_func_110
		cmp	byte ptr [si+1],0FFh
		jne	boss_sprite_select			; Jump if not equal
		mov	word ptr [si],0FFFFh
		jmp	boss_entry_next

boss_sprite_select:
		mov	bl,[si+5]
		add	bl,bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[9Dh]
		dec	al
		add	al,al
		xor	ah,ah			; Zero register
		mov	di,8C81h
		test	byte ptr [si+3],0FFh
		jnz	boss_sprite_ptr			; Jump if not zero
		mov	di,boss_sprite_buf

boss_sprite_ptr:
		add	di,ax
		mov	di,[di]
		add	di,bx
		mov	ax,[si]
		call	game_func_141
		jc	boss_entry_next			; Jump if carry Set
		mov	[si+6],bl
		mov	al,[si+2]
		sub	al,byte ptr ds:[82h]
		and	al,3Fh			; '?'
		mov	[si+7],al
		mov	bh,al
		xchg	bh,bl
		push	si
		add	si,8
		mov	bp,boss_data_buf
		mov	cx,4

boss_cell_loop:
										push	cx
										push	bx
										push	bp
										add	bh,ds:[bp]
										mov	al,bh
										sub	al,4
										cmp	al,1Ch
										jae	boss_cell_next			; Jump if above or =
										inc	bp
										add	bl,ds:[bp]
										and	bl,3Fh			; '?'
										cmp	bl,12h
										jae	boss_cell_next			; Jump if above or =
										mov	al,[di]
										push	di
										push	ax
										mov	ax,bx
										push	ax
										call	game_multiply_4
										pop	ax
										cmp	byte ptr [di],0FFh
										je	boss_cell_skip			; Jump if equal
										cmp	byte ptr [di],0FCh
										je	boss_cell_skip			; Jump if equal
										call	word ptr cs:gfx_fn_77
										or	di,8000h
										mov	[si],di
										and	di,7FFFh
										pop	ax
										push	si
										call	word ptr cs:gfx_fn_hud_draw
										pop	si
										pop	di
										jmp	short boss_cell_next

boss_cell_skip:
										pop	ax
										pop	di

boss_cell_next:
										pop	bp
										inc	si
										inc	si
										inc	di
										inc	bp
										inc	bp
										pop	bx
										pop	cx
										loop	boss_cell_loop		; Loop if cx > 0

		pop	si

boss_entry_next:
		add	si,10h
		pop	cx
		loop	boss_entry_loop		; Loop if cx > 0

		jmp	short boss_entries_done

boss_entry_loop:
		jmp	boss_entry_check

boss_entries_done:
		retn

game_func_109		endp

game_func_110		proc	near
		test	word ptr [si+8],8000h
		jz	boss_blit_a			; Jump if zero
		and	word ptr [si+8],7FFFh
		mov	dx,[si+8]
		mov	ah,[si+6]
		mov	al,[si+7]
		push	si
		call	game_func_93
		pop	si

boss_blit_a:
		test	word ptr [si+0Ah],8000h
		jz	boss_blit_b			; Jump if zero
		and	word ptr [si+0Ah],7FFFh
		mov	dx,[si+0Ah]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		push	si
		call	game_func_93
		pop	si

boss_blit_b:
		test	word ptr [si+0Ch],8000h
		jz	boss_blit_c			; Jump if zero
		and	word ptr [si+0Ch],7FFFh
		mov	dx,[si+0Ch]
		mov	ah,[si+6]
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	game_func_93
		pop	si

boss_blit_c:
		test	word ptr [si+0Eh],8000h
		jnz	boss_blit_d			; Jump if not zero
		retn

boss_blit_d:
		and	word ptr [si+0Eh],7FFFh
		mov	dx,[si+0Eh]
		mov	ah,[si+6]
		inc	ah
		mov	al,[si+7]
		inc	al
		and	al,3Fh			; '?'
		push	si
		call	game_func_93
		pop	si
		retn

game_func_110		endp

game_func_111		proc	near
		test	byte ptr ds:gvar_flag_FF3E,0FFh
		jnz	$+3			; Jump if not zero
		retn

game_func_111		endp

entity_fn_d_1:
			                        ; entity_fn_tbl_d target: handler fn 1 (dispatch via [8AC6h][bx])
		mov	si,0EB15h
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[8AC6h][bx]	;*

entity_fn_d_1_data:
			                        ; Data: dispatch table for [8AC6h] (6 targets in game seg)
;*		aam	8Ah			; undocumented inst
				aam 8Ah			; was: db 0D4h,08Ah
		dw	8AF7h		; dispatch entry 0
		dw	8B09h		; dispatch entry 1
		dw	8AF7h		; dispatch entry 2
		dw	8B64h		; dispatch entry 3
		dw	8B83h		; dispatch entry 4
		dw	8B9Ch		; dispatch entry 5
; dispatch targets:
		test	byte ptr [si+3],80h
		je	$+5
		jmp	reset_main_slot		; +0xD8
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],05h
		jb	$+5
		jmp	reset_main_slot		; +0xCC
		call	game_func_112		; +0xD6
		call	check_flags_scan	; +0x108
		jnc	$+3
		retn

set_bit80_and_ret:
		or	byte ptr [si+3],80h
		retn

boss_ctr_0a_handler:
			                        ; Boss behavior handler: increment counter, check 0Ah threshold
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jb	check_ctr_0a			; Jump if below
		jmp	reset_main_slot

check_ctr_0a:
		call	game_func_112
		jmp	check_flags_scan

boss_ctr_0c_handler:
			                        ; Boss behavior handler: increment counter, check 0Ch threshold
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jb	check_ctr_0c			; Jump if below
		jmp	reset_main_slot

check_ctr_0c:
		cmp	byte ptr [si+4],4
		jae	update_dir5			; Jump if above or =
		call	game_func_113
		jmp	short fight_continue

update_dir5:
		and	byte ptr [si+5],3
		inc	byte ptr [si+5]
		cmp	byte ptr [si+4],3
		je	fight_continue			; Jump if equal
		mov	ax,[si]
		call	game_func_141
		jc	fight_continue			; Jump if carry Set
		cmp	bl,21h			; '!'
		jae	fight_continue			; Jump if above or =
		mov	ah,bl
		mov	al,[si+2]
		call	vga_operation4
		SWAP_CALL 48h, vga_operation5
		mov	al,[di]
		call	game_check_state_2
		jnz	fight_continue			; Jump if not zero
		mov	al,[di+1]
		call	game_check_state_2
		jnz	fight_continue			; Jump if not zero
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'

fight_continue:
		jmp	check_flags_scan

boss_fire4_handler:
			                        ; Boss fire behavior handler: move 4 projectiles per step
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ch
		jae	reset_slots_30			; Jump if above or =
		mov	cx,4

fire4_move_loop:
										push	cx
										add	byte ptr [si+2],2
										and	byte ptr [si+2],3Fh	; '?'
										call	game_scan_loop_9
										add	si,10h
										pop	cx
										loop	fire4_move_loop		; Loop if cx > 0

		retn

boss_fire3_handler:
			                        ; Boss fire behavior handler: move 3 projectiles per step
		inc	byte ptr [si+4]
		cmp	byte ptr [si+4],0Ah
		jae	reset_slots_20			; Jump if above or =
		mov	cx,3

fire3_move_loop:
										push	cx
										call	game_func_112
										call	game_scan_loop_9
										add	si,10h
										pop	cx
										loop	fire3_move_loop		; Loop if cx > 0

		retn

reset_slots_30:
		mov	byte ptr [si+30h],0
		mov	byte ptr [si+31h],0FFh

reset_slots_20:
		mov	byte ptr [si+20h],0
		mov	byte ptr [si+21h],0FFh
		mov	byte ptr [si+10h],0
		mov	byte ptr [si+11h],0FFh

reset_main_slot:
		mov	byte ptr [si],0
		mov	byte ptr [si+1],0FFh
		mov	byte ptr ds:gvar_flag_FF3E,0
		retn

game_func_112		proc	near
		mov	al,[si+5]
		inc	al
		cmp	al,3
		jb	wrap_dir			; Jump if below
		xor	al,al			; Zero register

wrap_dir:
		mov	[si+5],al

game_func_113:
		mov	ax,[si]
		mov	bl,[si+3]
		and	bx,1
		add	bx,bx
		add	bx,bx
		dec	bx
		dec	bx
		add	ax,bx
		or	ax,ax			; Zero ?
		jns	pos_ok			; Jump if not sign
		add	ax,ds:map_width
		jmp	short update_pos

pos_ok:
		cmp	ax,ds:map_width
		jb	update_pos			; Jump if below
		sub	ax,ds:map_width

update_pos:
		mov	[si],ax
		retn

game_func_112		endp

game_scan_loop_9		proc	near

check_flags_scan:
		test	byte ptr ds:gvar_save_flag_1,0FFh
		jz	check_pos_on_screen			; Jump if zero
		test	byte ptr ds:gvar_flag_FF2E,0FFh
		stc				; Set carry flag
		jz	check_pos_on_screen			; Jump if zero
		retn

check_pos_on_screen:
		mov	ax,[si]
		call	game_func_141
		jnc	adjust_col			; Jump if carry=0
		retn

adjust_col:
		mov	ah,bl
		sub	bl,2
		cmp	bl,20h			; ' '
		cmc				; Complement carry
		jnc	draw_3x3_cells			; Jump if carry=0
		retn

draw_3x3_cells:
		mov	al,[si+2]
		call	vga_operation4
		push	si
		xchg	di,si
		sub	si,25h
		call	vga_operation6
		mov	byte ptr ds:state_byte_9F2A,0
		mov	cx,3

draw_3x3_outer:
										push	cx
										mov	cx,3

draw_3x3_inner:
																		push	cx
																		call	game_func_115
																		pop	cx
																		inc	si
																		loop	draw_3x3_inner		; Loop if cx > 0

										add	si,21h
										call	vga_operation5
										pop	cx
										loop	draw_3x3_outer		; Loop if cx > 0

		pop	si
		mov	al,ds:state_byte_9F2A
		add	al,al
		cmc				; Complement carry
		retn

game_scan_loop_9		endp

game_func_115		proc	near
		call	vga_operation9
		jnc	check_bit20_d			; Jump if carry=0
		retn

check_bit20_d:
		test	al,20h			; ' '
		jz	check_obj_bit20			; Jump if zero
		retn

check_obj_bit20:
		test	byte ptr [bx+5],20h	; ' '
		jz	mark_obj_slot			; Jump if zero
		retn

mark_obj_slot:
		mov	al,[bx+5]
		or	al,40h			; '@'
		and	al,0E0h
		mov	ah,byte ptr ds:[9Dh]
		inc	ah
		or	al,ah
		mov	[bx+5],al
		mov	byte ptr ds:state_byte_9F2A,0FFh
		retn

game_func_115		endp

		db	00h, 00h, 01h, 00h, 00h, 01h, 01h, 01h	; 8 flag bytes
		dw	8C99h, 8CA5h, 8CBDh, 8CE5h, 8CFDh, 8D01h	; fn table A
		dw	8C99h, 8CB1h, 8CD1h, 8CF1h, 8CFDh, 8D0Dh	; fn table B
		db	67h, 68h					; table pad/end
		db	'ijklmnopqrghijklmnopqrstuvwxyz{|'
		db	'}~ghijopqrstuvwxyz{|}~klmnopqrst'
		db	'uvwxyz{|}~ghijklmnopqrstuvwxyz{|'
		db	'}~stuvghijklmnopqrstuvwxyz{|}~'

game_func_116		proc	near
		mov	si,ds:object_list_ptr
		mov	al,ds:gvar_save_flag_1
		or	al,byte ptr ds:[0E6h]
		jz	obj_list_init			; Jump if zero
		jmp	word ptr cs:game_fn_vtable

obj_list_init:
		mov	byte ptr ds:gvar_flag_FF4A,0

obj_list_loop:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	obj_check_entry			; Jump if not equal
										retn

obj_check_entry:
										mov	byte ptr [si+3],0FFh
										cmp	ah,0FFh
										je	score_update_done			; Jump if equal
										call	game_func_141
										jc	score_update_done			; Jump if carry Set
										mov	[si+3],bl
										call	game_func_117
										cmp	byte ptr [si+1],0FFh
										je	score_update_done			; Jump if equal
										mov	ax,[si+2]
										call	vga_operation4
										mov	bl,ds:gvar_flag_FF4A
										xor	bh,bh			; Zero register
										mov	al,bl
										or	al,80h
										xchg	[di],al
										mov	ds:enemy_data_ext[bx],al
										test	byte ptr [si+4],11h
										jnz	score_update_done			; Jump if not zero
										test	byte ptr [si+7],10h
										jz	score_update_done			; Jump if zero
										SWAP_CALL 48h, vga_operation5
										mov	bl,ds:gvar_flag_FF4A
										inc	bl
										xor	bh,bh			; Zero register
										mov	al,bl
										or	al,80h
										xchg	[di],al
										mov	ds:enemy_data_ext[bx],al

score_update_done:
										test	byte ptr [si+7],20h	; ' '
										jnz	obj_list_incr			; Jump if not zero
										mov	al,[si+0Fh]
										inc	al
										jz	obj_ctr_wrap			; Jump if zero
										mov	[si+0Fh],al

obj_ctr_wrap:
										jnz	obj_list_incr			; Jump if not zero
										call	game_check_state_6

obj_list_incr:
										inc	byte ptr ds:gvar_flag_FF4A
										add	si,10h
										jmp	short obj_list_loop

game_func_116		endp

game_func_117		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		mov	al,[si+5]
		and	al,0DFh
		test	al,40h			; '@'
		jz	update_obj_slot			; Jump if zero
		test	byte ptr [si+4],20h	; ' '
		jnz	apply_mask_bits			; Jump if not zero
		or	al,20h			; ' '

apply_mask_bits:
		and	al,0BFh

update_obj_slot:
		mov	[si+5],al
		mov	al,ds:gvar_flag_FF4A
		mov	bx,enemy_data_ext
		xlat				; al=[al+[bx]] table
		mov	[di],al
		test	byte ptr [si+4],11h
		jnz	check_obj_flags			; Jump if not zero
		test	byte ptr [si+7],10h
		jz	check_obj_flags			; Jump if zero
		SWAP_CALL 48h, vga_operation5
		mov	al,ds:gvar_flag_FF4A
		inc	al
		xlat				; al=[al+[bx]] table
		mov	[di],al

check_obj_flags:
		test	byte ptr [si+4],18h
		jnz	obj_special_fn			; Jump if not zero
		jmp	word ptr cs:game_fn_vtable

obj_special_fn:
		jmp	short $+2		; delay for I/O
		xor	bh,bh			; Zero register
		mov	bl,[si+4]
		and	bl,1Fh
		sub	bl,10h
		jnc	$+5			; Jump if carry=0
		jmp	anim_half_step

anim_dispatch_stub:
			                        ; Animation dispatch stub via [8E14h][bx]
		add	bx,bx
		jmp	word ptr ds:[8E14h][bx]	;*

anim_dispatch_data:
			                        ; Data: animation dispatch table entries (game seg targets)
		xor	cl,byte ptr ss:[8E8Dh][bp]
		jmp	$-96Fh
		dw	0AB8Eh		; anim dispatch entry 0
		dw	0AB8Fh		; anim dispatch entry 1
		dw	0E88Fh		; anim dispatch entry 2
		dw	0F88Fh		; anim dispatch entry 3
		dw	088Fh		; anim dispatch entry 4
		dw	1C90h		; anim dispatch entry 5
		dw	9D90h		; anim dispatch entry 6
		dw	0AB90h		; anim dispatch entry 7
		dw	3C8Fh		; anim dispatch entry 8
		dw	7F90h		; anim dispatch entry 9
		dw	9090h		; anim dispatch entry 10
		nop			; 90h pad
; anim handler:
		test	byte ptr [si+0Ah],01h
		jnz	$+30		; 75h 1Ch ?-- to offset 30 relative
		test	byte ptr [si+5],20h
		jnz	$+3
		retn
		mov	byte ptr ds:[0FF75h],12h
		and	byte ptr [si+5],90h
		and	byte ptr [si+4],7Fh
		or	byte ptr [si+4],60h
		or	byte ptr [si+0Ah],01h
		add	byte ptr [si+6],80h
		jb	$+3
		retn

anim_ctr_step:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	anim_ctr_wrap			; Jump if above or =
		retn

anim_ctr_wrap:
		mov	byte ptr [si+6],0
		mov	al,[si+9]
		or	al,al			; Zero ?
		jnz	check_anim_next			; Jump if not zero
		jmp	entity_deactivate

check_anim_next:
		test	al,10h
		jz	set_next_anim			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0

set_next_anim:
		mov	[si+4],al
		and	byte ptr [si+5],80h
		mov	byte ptr [si+9],0
		retn

entity_fn_e_0:
			                        ; entity_fn_tbl_e target: handler fn 0 (flag_0a and column match)
		test	byte ptr [si+0Ah],1
		jnz	flag_0a_set			; Jump if not zero
		mov	ah,[si+2]
		sub	ah,3
		and	ah,3Fh			; '?'
		cmp	ah,ds:gvar_save_flag_2
		je	check_col_match_b			; Jump if equal
		retn

check_col_match_b:
		mov	al,byte ptr ds:[83h]
		add	al,3
		mov	ah,byte ptr ds:[0C2h]
		and	ah,1
		add	ah,ah
		add	al,ah
		mov	cx,2

col_match_loop:
										cmp	al,[si+3]
										je	set_flag_12			; Jump if equal
										inc	al
										loop	col_match_loop		; Loop if cx > 0

		retn

set_flag_12:
		mov	byte ptr ds:gvar_volume_b,12h
		or	byte ptr [si+0Ah],1
		retn

flag_0a_set:
		and	byte ptr [si+4],7Fh
		call	game_func_125
		add	byte ptr [si+6],80h
		jc	anim_carry			; Jump if carry Set
		retn

anim_carry:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],4
		jae	anim_done			; Jump if above or =
		retn

anim_done:
		mov	byte ptr [si+6],0
		jmp	entity_deactivate

entity_fn_e_1:
			                        ; entity_fn_tbl_e target: handler fn 1 (anim counter 3-step)
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	anim3_done			; Jump if equal
		retn

anim3_done:
		jmp	entity_deactivate

entity_fn_e_2:
			                        ; entity_fn_tbl_e target: handler fn 2 (game_scan_loop_10 gated)
		call	game_scan_loop_10
		jnc	check_anim_timer			; Jump if carry=0
		retn

check_anim_timer:
		mov	byte ptr ds:gvar_volume_b,14h
		test	byte ptr [si+6],0Fh
		jnz	anim_fn_dispatch			; Jump if not zero
		mov	al,[si+9]
		test	al,10h
		jz	update_next_anim			; Jump if zero
		or	al,60h			; '`'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],0

update_next_anim:
		mov	[si+4],al
		mov	byte ptr [si+9],0
		retn

anim_fn_dispatch:
		call	game_func_119
		mov	bl,[si+6]
		and	bl,0Fh
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		jmp	word ptr ds:entity_fn_tbl_e[bx]	;*

entity_fn_e_tbl_data:
			                        ; Data: entity_fn_tbl_e dispatch entries (7 targets in game seg)
		inc	cx
; entity_fn_tbl_e dispatch table (7 entries)
		dw	4D8Fh		; fn 0
		dw	598Fh		; fn 1
		dw	5F8Fh		; fn 2
		dw	6B8Fh		; fn 3
		dw	778Fh		; fn 4
		dw	838Fh		; fn 5
		dw	0BA8Fh		; fn 6
; dispatch targets:
		push	ds			; 1Eh
		db	9Ah,0E8h,99h,0E4h,0B8h	; call far 0B8E4h:99E8h (unaligned)
		db	32h, 00h		; xor al,[bx+si] / pad
		jmp	game_func_119_body	; +0x21E
		mov	dx,9A32h
		call	entity_scan_skip_push	; -0x1B73
		mov	ax,64h
		jmp	game_func_119_body	; +0x212
		mov	dx,9ADDh
		jmp	entity_scan_skip_push	; -0x1B7F
		mov	dx,9A47h
		call	entity_scan_skip_push	; -0x1B85
		mov	ax,1F4h
		jmp	game_func_119_body	; +0x200
		mov	dx,9A5Ch
		call	entity_scan_skip_push	; -0x1B91
		mov	ax,3E8h
		jmp	game_func_119_body	; +0x1F4
		mov	dx,9B2Ch
		call	entity_scan_skip_push	; -0x1B9D
		mov	byte ptr ds:[9Bh],0FFh
		retn
		mov	dx,9B9Ch
		call	entity_scan_skip_push	; -0x1BA9
		push	si
		call	word ptr cs:[3004h]
		mov	byte ptr ds:[92h],06h
		mov	al,06h
		mov	bx,18ABh
		call	word ptr cs:[201Ch]
		mov	ah,byte ptr ds:[92h]
		mov	al,04h
		call	word ptr cs:[010Ch]	; chunk loader
		pop	si
		retn
		call	game_func_125		; +0x2A7
		inc	byte ptr [si+6]
		and	byte ptr [si+6],03h
		call	game_scan_loop_10	; +0x1D8
		jnc	$+3
		retn
		mov	byte ptr ds:[0FF75h],10h
		mov	al,byte ptr [si+4]
		and	al,0Fh
		cmp	al,04h
		jnz	$+11
		mov	ax,0001h
		call	game_func_120		; +0x1AD
		jmp	game_func_119		; +0x17A

score_small:
		cmp	al,5
		jne	score_large			; Jump if not equal
		mov	ax,0Ah
		call	game_func_120
		jmp	entity_deactivate

score_large:
		mov	ax,64h
		call	game_func_120
		jmp	entity_deactivate

entity_fn_e_3:
			                        ; entity_fn_tbl_e target: handler fn 3 (enemy trigger at 9A72h)
		mov	dx,9A72h
		call	game_func_118
		jnc	inc_98			; Jump if carry=0
		retn

inc_98:
		inc	byte ptr ds:[98h]
		jmp	entity_deactivate
		mov	dx,enemy_ai_data		; BA CB 9B
		db	0E8h			; call opcode (displacement = gfx_fn_enemy_scroll)
gfx_fn_enemy_scroll		dw	0D5h
gfx_fn_combat_fx		dw	173h
gfx_fn_render_tile		dw	0FEC3h
gfx_fn_render_col		dw	9906h
gfx_fn_hud_draw		dw	hud_buf
gfx_fn_77		dw	144h
		db	0E8h,85h		; call near lo-byte 85h, hi from gfx_fn_78 lo
gfx_fn_78		dw	7301h
gfx_fn_player_scroll		dw	0C301h
gfx_fn_init		dw	83BAh
gfx_fn_map_load		dw	0E89Ah
gfx_fn_render_bg		dw	0E3CCh
gfx_fn_83		dw	680h
gfx_fn_palette		dw	0C6h
gfx_fn_clear		dw	0E90Ah
gfx_fn_blit		dw	offset vga_operation
gfx_fn_map_ref		dw	offset game_func_142
		db	02h		; hi-byte of preceding jmp near displacement
		call	game_scan_loop_10	; +0x16E
		db	73h,01h		; jnc $+3
gfx_fn_memcpy		dw	0BAC3h
gfx_fn_map_scroll		dw	9A99h
		call	entity_scan_skip_push	; -0x1C4B
		mov	ax,word ptr ds:[0B2h]
		shr	ax,1
		shr	ax,1
		shr	ax,1
		inc	ax
		add	word ptr ds:[0C6h],ax
		jmp	game_func_119		; +0x110
		mov	byte ptr [si+0Fh],0
		test	byte ptr [si+9],01h
		jnz	$+44
		call	game_scan_loop_10	; +0x147
		jnc	$+3
		retn

start_boss_scroll:
		mov	byte ptr ds:gvar_volume_b,11h
		or	byte ptr [si+7],80h
		or	byte ptr [si+9],1
		mov	byte ptr [si+0Ah],0EBh
		mov	bl,[si+6]
		add	bl,bl
		xor	bh,bh			; Zero register
		add	bx,ds:state_byte_C017
		push	si
		mov	si,[bx]
		call	game_multiply
		pop	si
		retn

check_0a_flag:
		test	byte ptr [si+0Ah],0FFh
		jz	clear_dir_bit			; Jump if zero
		inc	byte ptr [si+0Ah]
		retn

clear_dir_bit:
		and	byte ptr [si+9],0FEh
		retn

entity_fn_e_4:
			                        ; entity_fn_tbl_e target: handler fn 4 (enemy trigger at 9AF3h)
		mov	dx,9AF3h
		call	game_func_118
		jnc	set_9c_ff			; Jump if carry=0
		retn

set_9c_ff:
		mov	byte ptr ds:[9Ch],0FFh
		jmp	entity_deactivate

entity_fn_e_5:
			                        ; entity_fn_tbl_e target: handler fn 5 (enemy trigger at 9B63h)
		mov	dx,9B63h
		call	game_func_118
		jnc	set_al_1			; Jump if carry=0
		retn

set_al_1:
		mov	al,1
		jmp	short search_free_slot

entity_fn_e_6:
			                        ; entity_fn_tbl_e target: handler fn 6 (area-based boss encounter)
		mov	al,ds:area_num
		sub	al,4
		mov	cl,3
		mul	cl			; ax = reg * al
		mov	di,boss_render_buf
		add	di,ax
		mov	al,[di]
		mov	dx,[di+1]
		push	ax
		call	game_func_118
		pop	ax
		jnc	search_free_slot			; Jump if carry=0
		retn

search_free_slot:
		push	ax
		mov	di,0A1h

slot_scan_loop:
										test	byte ptr [di],0FFh
										jz	slot_found			; Jump if zero
										inc	di
										jmp	short slot_scan_loop

slot_found:
		pop	ax
		mov	[di],al
		jmp	entity_deactivate

entity_fn_tbl_e_stub:
			                        ; Stub data between slot_found and game_func_118
		add	al,0Fh
		fwait				; 9Bh
		add	al,byte ptr [bx-65h]	; 02 47 9B
		add	di,word ptr [bx-65h]	; 03 7F 9B

game_func_118:
		push	dx
		call	game_func_125
		call	game_scan_loop_10
		pop	dx
		jnc	trigger_entity_scan			; Jump if carry=0
		retn

trigger_entity_scan:
		mov	byte ptr ds:gvar_volume_b,11h
		jmp	entity_scan_start

anim_half_step:
		add	byte ptr [si+6],80h
		jc	anim_3check			; Jump if carry Set
		retn

anim_3check:
		inc	byte ptr [si+6]
		cmp	byte ptr [si+6],3
		je	anim_3done_setup			; Jump if equal
		retn

anim_3done_setup:
		mov	byte ptr [si+0Fh],0
		test	byte ptr [si+7],40h	; '@'
		jz	check_bit40_b			; Jump if zero
		and	byte ptr [si+7],0BFh
		mov	al,[si+0Ah]
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,ds:object_list_ptr
		mov	di,ax
		mov	byte ptr [di+2],0

check_bit40_b:
		test	byte ptr [si+7],10h
		jz	check_death_cond			; Jump if zero
		test	byte ptr [si+4],1
		jz	entity_deactivate			; Jump if zero

check_death_cond:
		mov	byte ptr [si+6],0
		mov	byte ptr [si+4],72h	; 'r'
		mov	al,[si+7]
		and	al,0Fh
		jnz	check_fn_nibble			; Jump if not zero
		retn

check_fn_nibble:
		cmp	al,1
		je	entity_deactivate			; Jump if equal
		or	al,70h			; 'p'
		or	byte ptr [si+7],80h
		mov	byte ptr [si+0Fh],4
		mov	[si+4],al
		and	byte ptr [si+5],80h
		and	byte ptr [si+7],0F0h
		retn

game_func_119:

entity_deactivate:
		mov	word ptr [si],0FF00h
		test	byte ptr [si+7],20h	; ' '
		jnz	check_link_ptr			; Jump if not zero
		retn

check_link_ptr:
		mov	di,[si+0Bh]
;*		cmp	di,0FFFFh
				cmp di,-1			; was: db 083h,0FFh,0FFh
		jnz	apply_link_bits			; Jump if not zero
		retn

apply_link_bits:
		mov	al,[si+0Dh]
		or	[di],al
		mov	word ptr [si+0Bh],0FFFFh
		retn

game_func_117		endp

game_func_119_body:
			                        ; game_func_119 body: score update dispatch (via cs:[2016h])
		add	word ptr ds:[86h],ax
		adc	byte ptr ds:[85h],0
		push	si
		call	word ptr cs:[2016h]
		pop	si
		retn

game_func_120		proc	near
		add	word ptr ds:[8Bh],ax
		jnc	score_carry_done			; Jump if carry=0
		mov	word ptr ds:[8Bh],0FFFFh

score_carry_done:
		push	si
		call	word ptr cs:[2014h]
		pop	si
		retn

game_func_120		endp

game_scan_loop_10		proc	near
		test	byte ptr ds:[0E8h],0FFh
		stc				; Set carry flag
		jz	check_row_range			; Jump if zero
		retn

check_row_range:
		mov	ah,[si+2]
		add	ah,2
		mov	cx,4

row_range_scan:
										dec	ah
										and	ah,3Fh			; '?'
										cmp	ah,ds:gvar_save_flag_2
										je	check_col_range_b			; Jump if equal
										loop	row_range_scan		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn

check_col_range_b:
		mov	al,byte ptr ds:[83h]
		add	al,4
		mov	ah,[si+3]
		sub	ah,3
		mov	cx,4

col_range_scan:
										inc	ah
										cmp	ah,al
										je	check_bit80			; Jump if equal
										loop	col_range_scan		; Loop if cx > 0

		and	byte ptr [si+7],7Fh
		stc				; Set carry flag
		retn

check_bit80:
		test	byte ptr [si+7],80h
		clc				; Clear carry flag
		jnz	check_0f_bits			; Jump if not zero
		retn

check_0f_bits:
		inc	byte ptr [si+0Fh]
		test	byte ptr [si+0Fh],7
		jnz	set_carry_ret			; Jump if not zero
		retn

set_carry_ret:
		stc				; Set carry flag
		retn

game_scan_loop_10		endp

game_func_122		proc	near

check_col_22:
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	call_func128			; Jump if carry=0
		retn

call_func128:
		call	game_func_128
		jnc	jmp_loc620			; Jump if carry=0
		retn

jmp_loc620:
		jmp	inc_map_pos

game_func_122_b:
			                        ; game_func_122 variant B: check col 22h, dec_row
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	check_col_22b			; Jump if carry=0
		retn

check_col_22b:
		call	game_func_134
		jnc	call_func134_126			; Jump if carry=0
		retn

call_func134_126:
		call	game_func_126
		jmp	dec_row

game_func_123:

check_al_zero:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	check_al_23			; Jump if not zero
		retn

check_al_23:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	call_func132			; Jump if not zero
		retn

call_func132:
		call	game_func_132
		jnc	jmp_loc625			; Jump if carry=0
		retn

jmp_loc625:
		jmp	dec_row

game_func_123_b:
			                        ; game_func_123 variant B: check col >= 2, dec_row
		cmp	byte ptr [si+3],2
		jae	check_col_2			; Jump if above or =
		retn

check_col_2:
		call	game_func_136
		jnc	call_func136_127			; Jump if carry=0
		retn

call_func136_127:
		call	game_func_127
		jmp	short dec_row

game_func_124:

check_col_2b:
		cmp	byte ptr [si+3],2
		jae	call_func130			; Jump if above or =
		retn

call_func130:
		call	game_func_130
		jnc	jmp_loc622			; Jump if carry=0
		retn

jmp_loc622:
		jmp	short dec_map_pos

game_func_124_b:
			                        ; game_func_124 variant B: check col >= 2c, inc_row
		cmp	byte ptr [si+3],2
		jae	check_col_2c			; Jump if above or =
		retn

check_col_2c:
		call	game_func_137
		jnc	call_func137_127			; Jump if carry=0
		retn

call_func137_127:
		call	game_func_127
		jmp	short inc_row

game_func_125:
		mov	al,[si+3]
		or	al,al			; Zero ?
		stc				; Set carry flag
		jnz	check_al_zero_b			; Jump if not zero
		retn

check_al_zero_b:
		cmp	al,23h			; '#'
		stc				; Set carry flag
		jnz	check_al_23b			; Jump if not zero
		retn

check_al_23b:
		call	game_func_133
		jnc	jmp_loc624			; Jump if carry=0
		retn

jmp_loc624:
		jmp	short inc_row

game_func_125_b:
			                        ; game_func_125 variant B: check col 22h, inc_row
		cmp	byte ptr [si+3],22h	; '"'
		cmc				; Complement carry
		jnc	check_col_22c			; Jump if carry=0
		retn

check_col_22c:
		call	game_func_135
		jnc	call_func135_126			; Jump if carry=0
		retn

call_func135_126:
		call	game_func_126
		jmp	short inc_row

game_func_126:

inc_map_pos:
		mov	ax,[si]
		inc	ax
		mov	bx,ax
		sub	bx,ds:map_width
		jc	map_pos_wrap			; Jump if carry Set
		mov	ax,bx

map_pos_wrap:
		mov	[si],ax
		inc	byte ptr [si+3]
		clc				; Clear carry flag
		retn

game_func_127:

dec_map_pos:
		mov	ax,[si]
		or	ax,ax			; Zero ?
		jnz	map_pos_wrap2			; Jump if not zero
		mov	ax,ds:map_width

map_pos_wrap2:
		dec	ax
		mov	[si],ax
		dec	byte ptr [si+3]
		clc				; Clear carry flag
		retn

inc_row:
		inc	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn

dec_row:
		dec	byte ptr [si+2]
		and	byte ptr [si+2],3Fh	; '?'
		retn

game_func_122		endp

game_func_128		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		call	game_func_129
		jnc	check_row_up			; Jump if carry=0
		retn

check_row_up:
		SWAP_CALL 24h, vga_operation5
		call	game_func_129
		jnc	check_row_up2			; Jump if carry=0
		retn

check_row_up2:
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

game_func_128		endp

game_func_129		proc	near
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_area5			; Jump if zero
		retn

check_area5:
		cmp	byte ptr ds:area_num,5
		clc				; Clear carry flag
		jz	check_in_slot			; Jump if zero
		retn

check_in_slot:
		push	si
		call	game_func_63
		pop	si
		dec	cl
		clc				; Clear carry flag
		jz	slot_found_b			; Jump if zero
		retn

slot_found_b:
		stc				; Set carry flag
		retn

game_func_129		endp

game_func_130		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		call	game_func_131
		jnc	check_row_down			; Jump if carry=0
		retn

check_row_down:
		SWAP_CALL 24h, vga_operation5
		call	game_func_131
		jnc	check_row_down2			; Jump if carry=0
		retn

check_row_down2:
		dec	di
		xchg	si,di
		mov	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		sub	si,24h
		call	vga_operation6
		or	al,[si]
		xchg	si,di
		add	al,al
		retn

game_func_130		endp

game_func_131		proc	near
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_area5_b			; Jump if zero
		retn

check_area5_b:
		cmp	byte ptr ds:area_num,5
		clc				; Clear carry flag
		jz	check_in_slot_b			; Jump if zero
		retn

check_in_slot_b:
		push	si
		call	game_func_63
		pop	si
		dec	cl
		dec	cl
		clc				; Clear carry flag
		jz	slot_found_c			; Jump if zero
		retn

slot_found_c:
		stc				; Set carry flag
		retn

game_func_131		endp

game_func_132		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_tile_ok			; Jump if zero
		retn

check_tile_ok:
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_above_row			; Jump if zero
		retn

check_above_row:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di+1]
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn

game_func_132		endp

game_func_133		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		SWAP_CALL 48h, vga_operation5
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_tile_ok_b			; Jump if zero
		retn

check_tile_ok_b:
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_above_row_b			; Jump if zero
		retn

check_above_row_b:
		or	al,[di]
		or	al,[di-1]
		add	al,al
		retn

game_func_133		endp

game_func_134		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_main_tile			; Jump if zero
		retn

check_main_tile:
		mov	cl,al
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_sub_tile			; Jump if zero
		retn

check_sub_tile:
		or	cl,al
		mov	al,[di-1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_2rows			; Jump if zero
		retn

check_2rows:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di]
		or	cl,[di-1]
		or	cl,[di-2]
		add	cl,cl
		retn

game_func_134		endp

game_func_135		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		inc	di
		inc	di
		mov	cl,[di]
		SWAP_CALL 24h, vga_operation5
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_main_tile_b			; Jump if zero
		retn

check_main_tile_b:
		or	cl,al
		SWAP_CALL 24h, vga_operation5
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_sub_tile_b			; Jump if zero
		retn

check_sub_tile_b:
		or	cl,al
		mov	al,[di-1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_more_tiles			; Jump if zero
		retn

check_more_tiles:
		or	cl,al
		or	cl,[di-2]
		add	cl,cl
		retn

game_func_135		endp

game_func_136		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_left_tile			; Jump if zero
		retn

check_left_tile:
		dec	di
		mov	cl,[di]
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di]
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_left2			; Jump if zero
		retn

check_left2:
		mov	al,[di+2]
		call	game_func_138
		stc				; Set carry flag
		jz	check_left_rows			; Jump if zero
		retn

check_left_rows:
		xchg	si,di
		sub	si,24h
		call	vga_operation6
		xchg	si,di
		or	cl,[di+2]
		or	cl,[di+1]
		or	cl,[di]
		add	cl,cl
		retn

game_func_136		endp

game_func_137		proc	near
		mov	ax,[si+2]
		call	vga_operation4
		dec	di
		dec	di
		mov	cl,[di]
		SWAP_CALL 24h, vga_operation5
		or	cl,[di]
		inc	di
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_first_tile			; Jump if zero
		retn

check_first_tile:
		SWAP_CALL 24h, vga_operation5
		mov	al,[di]
		call	game_func_138
		stc				; Set carry flag
		jz	check_second_tile			; Jump if zero
		retn

check_second_tile:
		or	cl,al
		mov	al,[di+1]
		call	game_func_138
		stc				; Set carry flag
		jz	check_third_tile			; Jump if zero
		retn

check_third_tile:
		or	cl,al
		or	cl,[di-1]
		add	cl,cl
		retn

game_func_137		endp

game_func_138		proc	near
		cmp	al,49h			; 'I'
		jb	scan_enemy_tbl_b			; Jump if below
		or	al,al			; Zero ?
		jns	entity_type_valid			; Jump if not sign
		retn

entity_type_valid:
		cmp	al,al
		retn

scan_enemy_tbl_b:
		push	di
		push	cx
		mov	es,cs:gvar_game_seg
		mov	di,enemy_id_table
		mov	cx,18h
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		pop	cx
		pop	di
		retn

game_func_138		endp

game_check_state_6		proc	near
		cmp	byte ptr [si+1],0FFh
		je	check_slot1_ff			; Jump if equal
		retn

check_slot1_ff:
		test	byte ptr [si+7],10h
		jz	check_bit10			; Jump if zero
		cmp	byte ptr [si+11h],0FFh
		je	check_bit10			; Jump if equal
		retn

check_bit10:
		mov	ax,[si+0Bh]
		cmp	ax,0FFFFh
		jne	check_link_valid			; Jump if not equal
		retn

check_link_valid:
		call	game_func_141
		jnc	check_bl_zero			; Jump if carry=0
		retn

check_bl_zero:
		or	bl,bl			; Zero ?
		jnz	check_bl_23			; Jump if not zero
		retn

check_bl_23:
		cmp	bl,23h			; '#'
		jne	check_vertical_dist			; Jump if not equal
		retn

check_vertical_dist:
		mov	al,byte ptr ds:[82h]
		sub	al,2
		and	al,3Fh			; '?'
		sub	al,[si+0Dh]
		neg	al
		and	al,3Fh			; '?'
		cmp	al,18h
		jae	boss_check_next			; Jump if above or =
		cmp	bl,3
		jb	boss_check_next			; Jump if below
		cmp	bl,20h			; ' '
		jae	boss_check_next			; Jump if above or =
		retn

boss_check_next:
		test	byte ptr [si+7],10h
		jnz	boss_double_check			; Jump if not zero
		mov	[si+3],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	vga_operation4
		push	di
		xchg	si,di
		sub	si,25h
		call	vga_operation6
		xor	al,al			; Zero register
		mov	cx,3

check_3rows:
										or	al,[si]
										or	al,[si+1]
										or	al,[si+2]
										add	si,24h
										call	vga_operation5
										loop	check_3rows		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	place_entity			; Jump if not sign
		retn

place_entity:
		mov	al,ds:gvar_flag_FF4A
		or	al,80h
		mov	[di],al
		mov	ax,[si+0Bh]
		mov	[si],ax
		mov	al,[si+0Dh]
		mov	[si+2],al
		mov	al,[si+0Eh]
		mov	[si+4],al
		mov	byte ptr [si+6],10h
		mov	byte ptr [si+5],0
		mov	word ptr [si+9],0
		mov	byte ptr [si+8],0
		mov	bl,ds:gvar_flag_FF4A
		xor	bh,bh			; Zero register
		mov	byte ptr ds:enemy_data_ext[bx],0
		retn

boss_double_check:
		test	byte ptr [si+0Eh],1
		jz	setup_double_entity			; Jump if zero
		retn

setup_double_entity:
		mov	[si+3],bl
		mov	[si+13h],bl
		mov	al,[si+0Dh]
		mov	ah,bl
		call	vga_operation4
		push	di
		xchg	si,di
		sub	si,25h
		call	vga_operation6
		xor	al,al			; Zero register
		mov	cx,5

check_5rows:
										or	al,[si]
										or	al,[si+1]
										or	al,[si+2]
										add	si,24h
										call	vga_operation5
										loop	check_5rows		; Loop if cx > 0

		xchg	si,di
		pop	di
		or	al,al			; Zero ?
		jns	place_double			; Jump if not sign
		retn

place_double:
		mov	al,ds:gvar_flag_FF4A
		or	al,80h
		mov	[di],al
		SWAP_CALL 48h, vga_operation5
		inc	al
		mov	[di],al
		mov	ax,[si+0Bh]
		mov	[si],ax
		mov	[si+10h],ax
		mov	al,[si+0Dh]
		mov	[si+2],al
		add	al,2
		and	al,3Fh			; '?'
		mov	[si+12h],al
		mov	al,[si+0Eh]
		mov	[si+4],al
		inc	al
		mov	[si+14h],al
		mov	byte ptr [si+6],10h
		mov	byte ptr [si+16h],10h
		mov	byte ptr [si+5],0
		mov	byte ptr [si+15h],0
		mov	word ptr [si+9],0
		mov	word ptr [si+19h],0
		mov	byte ptr [si+8],0
		mov	byte ptr [si+18h],0
		and	byte ptr [si+17h],0F0h
		mov	bl,ds:gvar_flag_FF4A
		xor	bh,bh			; Zero register
		mov	word ptr ds:enemy_data_ext[bx],0
		retn

game_check_state_6		endp

clear_buffer		proc	near
		push	cs
		pop	es
		mov	di,enemy_data_ext
		mov	cx,80h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		jmp	short $+2		; delay for I/O
		mov	byte ptr ds:gvar_flag_FF4A,0
		mov	si,ds:object_list_ptr

obj_clear_scan:
										mov	ax,[si]
										cmp	ax,0FFFFh
										jne	obj_clear_found			; Jump if not equal
										retn

obj_clear_found:
										cmp	ah,0FFh
										je	obj_clear_next			; Jump if equal
										mov	byte ptr [si+3],0FFh
										call	game_func_141
										jc	obj_clear_next			; Jump if carry Set
										mov	[si+3],bl
										mov	al,[si+2]
										mov	ah,bl
										call	vga_operation4
										mov	al,ds:gvar_flag_FF4A
										or	al,80h
										mov	[di],al

obj_clear_next:
										inc	byte ptr ds:gvar_flag_FF4A
										add	si,10h
										jmp	short obj_clear_scan

clear_buffer		endp

game_func_141		proc	near
		mov	bx,ax
		sub	ax,word ptr ds:[80h]
		jnc	pos_to_screen			; Jump if carry=0
		mov	ax,23h
		sub	ax,bx
		jnc	check_left_bound			; Jump if carry=0
		retn

check_left_bound:
		mov	ax,ds:map_width
		sub	ax,word ptr ds:[80h]
		add	ax,bx

pos_to_screen:
		xchg	bx,ax
		mov	ax,23h
		sub	ax,bx
		retn

game_func_141		endp

boss_action_done:
		mov	al,[si+4]
		test	al,10h
		jnz	set_boss_anim			; Jump if not zero
		and	al,0Fh
		mov	bx,tile_data_ptr
		xlat				; al=[al+[bx]] table
		xor	ah,ah			; Zero register
		call	game_func_143
		jmp	short set_boss_anim

set_boss_anim:
		mov	byte ptr [si+6],0
		or	byte ptr [si+4],68h	; 'h'
		and	byte ptr [si+5],80h
		test	byte ptr [si+7],10h
		jz	check_boss_row			; Jump if zero
		test	byte ptr [si+4],1
		jnz	check_boss_row			; Jump if not zero
		mov	byte ptr [si+6],80h
		mov	byte ptr [si+16h],0
		or	byte ptr [si+14h],68h	; 'h'
		and	byte ptr [si+15h],80h

check_boss_row:
		mov	al,[si+2]
		mov	ah,byte ptr ds:[82h]
		dec	ah
		sub	al,ah
		and	al,3Fh			; '?'
		cmp	al,13h
		jb	play_sound7			; Jump if below
		retn

play_sound7:
		mov	byte ptr ds:gvar_volume_b,7
		retn

game_func_143		proc	near
		add	word ptr ds:[8Eh],ax
		jc	clamp_score			; Jump if carry Set
		retn

clamp_score:
		mov	word ptr ds:[8Eh],0FFFFh
		retn

game_func_143		endp

entity_fn_f_dispatch:
			                        ; entity_fn_tbl_f dispatch stub (al & 7, jmp via entity_fn_tbl_f[bx])
		and	al,7
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:entity_fn_tbl_f[bx]	;*

entity_fn_tbl_f_data:
			                        ; Data block after entity_fn_tbl_f dispatch
		in	ax,91h			; port 91h ??I/O Non-standard
		not	byte ptr ds:entity_state_tbl[bx+di]
		and	dl,ss:entity_attr_tbl[bp+si]
		inc	bx
		xchg	dx,ax
		push	bp
		xchg	dx,ax
		db	6Ch			; insb (port DX?->[ES:DI])
		xchg	ax,dx			; 92h
		and	al,07h
		mov	bl,al
		xor	bh,bh
		add	bx,bx
		jmp	word ptr ds:[bx+974Bh]	;* dispatch
; dispatch targets:
		mov	ah,92h			; B4 92
		db	0C5h,93h,62h,93h	; lds dx,[bp+di+9362h] (alt encoding)
		push	dx			; 52h
		xchg	ax,sp			; 94h
		db	0Ah,93h,9Ah,94h	; or dl,[bp+di+...] (complex)
		db	9Ah,93h,0Ch,94h	; (continuation)
		mov	ax,word ptr [si+2]
		db	0E8h,0Dh,0D6h		; call near -0x29F3 (mid-instruction target; keep as bytes)
		xchg	di,si
		add	si,24h
		db	0E8h,19h,0D6h		; call near -0x29E7 (mid-instruction target; keep as bytes)
		xchg	di,si
		mov	cx,0002h

boss_slot_scan:
										push	cx
										push	si
										mov	al,[di]
										call	game_func_63
										mov	bl,cl
										pop	si
										pop	cx
										jz	dispatch_boss_fn			; Jump if zero
										inc	di
										loop	boss_slot_scan		; Loop if cx > 0

		retn

dispatch_boss_fn:
		pop	ax
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:boss_fn_tbl[bx]	;*

boss_fn_0:
			                        ; boss_fn_tbl target: boss fn 0 (call far, col 22h check)
;*		call	far ptr game_func_155		;*
			db	9Ah, 97h, 94h, 97h, 8Eh		; call far ptr 8E97h:9497h
		xchg	di,ax
		call	game_func_122
		jmp	check_col_22

boss_fn_1:
			                        ; boss_fn_tbl target: boss fn 1 (game_func_124, check_col_2b)
		call	game_func_124
		jmp	check_col_2b

boss_fn_2:
			                        ; boss_fn_tbl target: boss fn 2 (game_func_123, check_al_zero)
		call	game_func_123
		jmp	check_al_zero

boss_fn_3:
			                        ; boss_fn_tbl target: boss fn 3 (position lookup, atk_slot_check)
		mov	ax,[si+2]
		call	vga_operation4
		SWAP_CALL 48h, vga_operation5
		mov	al,[di]
		jmp	atk_slot_check

boss_fn_4:
			                        ; boss_fn_tbl target: boss fn 4 (apply damage)
		mov	al,[si+5]
		and	al,1Fh
		call	game_multiply_5
		mov	al,[si+8]
		sub	al,ah
		jbe	hp_depleted			; Jump if below or =
		mov	[si+8],al
		mov	byte ptr ds:gvar_volume_b,6
		retn

hp_depleted:
		test	byte ptr [si+4],1
		jnz	check_boss_flags			; Jump if not zero
		test	byte ptr [si+7],10h
		jnz	boss_double_anim			; Jump if not zero

check_boss_flags:
		test	byte ptr [si+7],0Fh
		jz	select_anim			; Jump if zero
		jmp	boss_action_done

select_anim:
		mov	di,ds:render_dest_ptr
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:gvar_flag_FF45,2
		jne	apply_anim_top			; Jump if not equal
		xor	bx,bx			; Zero register

apply_anim_top:
		mov	al,[bx+di]
		mov	ah,[si+7]
		and	ah,0F0h
		or	al,ah
		mov	[si+7],al
		jmp	boss_action_done

boss_double_anim:
		test	byte ptr [si+17h],0Fh
		jz	select_anim_b			; Jump if zero
		jmp	boss_action_done

select_anim_b:
		mov	di,ds:render_dest_ptr
		mov	bl,[si+4]
		and	bl,7
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		call	word ptr cs:[11Ah]
		mov	bl,al
		and	bx,3
		cmp	byte ptr ds:gvar_flag_FF45,2
		jne	apply_anim_bot			; Jump if not equal
		xor	bx,bx			; Zero register

apply_anim_bot:
		mov	al,[bx+di]
		mov	ah,[si+17h]
		and	ah,0F0h
		or	al,ah
		mov	[si+17h],al
		jmp	boss_action_done

game_multiply_5		proc	near
		mov	ah,byte ptr ds:[8Dh]
		shr	ah,1			; Shift w/zeros fill
		inc	ah
		or	al,al			; Zero ?
		jnz	al_not_zero			; Jump if not zero
		retn

al_not_zero:
		cmp	al,1
		je	al_is_one			; Jump if equal
		mov	ah,byte ptr ds:[8Dh]
		inc	ah
		add	ah,ah
		jc	val_overflow			; Jump if carry Set
		add	ah,ah
		jnc	check_al9			; Jump if carry=0

val_overflow:
		mov	ah,0FFh

check_al9:
		cmp	al,9
		jne	anim_idx_calc			; Jump if not equal
		retn

anim_idx_calc:
		sub	al,2
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	ah,ds:anim_frame_tbl_b[bx]
		retn

al_is_one:
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,ds:anim_frame_tbl_a[bx]
		mov	bl,byte ptr ds:[8Dh]
		shr	bl,1			; Shift w/zeros fill
		add	al,bl
		jc	ah_overflow			; Jump if carry Set
		mov	cl,byte ptr ds:[0E4h]
		inc	cl
		mul	cl			; ax = reg * al
		or	ah,ah			; Zero ?
		jz	check_flag45			; Jump if zero

ah_overflow:
		mov	al,0FFh

check_flag45:
		mov	ah,al
		cmp	byte ptr ds:gvar_flag_FF45,2
		je	double_ah			; Jump if equal
		retn

double_ah:
		add	ah,ah
		jc	ah_carry			; Jump if carry Set
		retn

ah_carry:
		mov	ah,0FFh
		retn

game_multiply_5		endp

boss_fn_tbl_data:
			                        ; Data block after game_multiply_5 (table alignment bytes)
		add	[bp+si],ax
		add	al,8
		and	[bx+2],bh
		add	al,8
		adc	[bx+si],ah
		inc	ax
		push	word ptr [bp+si]
		ror	byte ptr ss:[103Eh][bp+di],cl	; Rotate
		db	0C0h

obj_link_scan:
;*		cmp	word ptr [di],0FFFFh
												cmp word ptr [di],-1			; was: db 083h,03Dh,0FFh
										stc				; Set carry flag
										jnz	obj_link_found			; Jump if not zero
										retn

obj_link_found:
;*		cmp	word ptr [di+0Bh],0FFFFh
												cmp word ptr [di+0Bh],-1			; was: db 083h,07Dh,00Bh,0FFh
										jnz	obj_link_next			; Jump if not zero
										cmp	byte ptr [di+1],0FFh
										je	check_slot_ff			; Jump if equal
										mov	ax,[di]
										push	dx
										call	game_func_141
										pop	dx
										jnc	obj_link_next			; Jump if carry=0
										test	byte ptr [di+4],10h
										jz	link_visible			; Jump if zero

obj_link_next:
																		inc	dl
																		add	di,10h
																		jmp	short obj_link_scan

check_slot_ff:
										cmp	byte ptr [di+2],7Fh
										je	obj_link_next			; Jump if equal

link_visible:
		clc				; Clear carry flag
		retn

game_over_sequence:
		call	word ptr cs:gfx_fn_render_tile
		mov	byte ptr ds:gvar_joystick_flag,0
		mov	byte ptr ds:gvar_combat_ff3D,0
		mov	byte ptr ds:gvar_music_flag_a,0
		mov	byte ptr ds:gvar_save_flag_3,0
		mov	byte ptr ds:[0E8h],0FFh
		mov	byte ptr ds:state_byte_9F28,0
		mov	byte ptr ds:state_byte_9F29,0
		call	word ptr cs:[2008h]
		mov	byte ptr ds:[0E7h],0
		mov	byte ptr ds:gvar_music_flag_b,0
		mov	byte ptr ds:gvar_save_flag_4,0
		call	game_check_state_3
		mov	ax,9929h
		push	ax
		call	game_func_20
		pop	ax
		mov	byte ptr ds:gvar_save_flag_4,0

cleanup_done:
																		call	game_check_state_3
																		mov	byte ptr ds:gvar_save_flag_4,0
																		cmp	byte ptr ds:[0E7h],2
																		je	wait_e7_2			; Jump if equal
																		inc	byte ptr ds:state_byte_9F28
																		test	byte ptr ds:state_byte_9F28,7
																		jnz	cleanup_done			; Jump if not zero
																		mov	al,byte ptr ds:[0E7h]
																		inc	al
																		and	al,3
																		cmp	al,3
																		je	cleanup_done			; Jump if equal
																		mov	byte ptr ds:[0E7h],al
																		jmp	short cleanup_done

wait_e7_2:
																		inc	byte ptr ds:state_byte_9F29
																		test	byte ptr ds:state_byte_9F29,0Fh
																		jz	fade_out			; Jump if zero
																		test	byte ptr ds:state_byte_9F29,1
																		jz	cleanup_done			; Jump if zero
										mov	byte ptr ds:gvar_save_flag_4,0FFh
										jmp	short cleanup_done

fade_out:
		mov	byte ptr ds:gvar_state_FF24,8
		mov	cx,1Eh

fade_step_loop:
										push	cx
										call	game_check_state_3
										pop	cx
										mov	al,cl
										and	al,1
										dec	al
										mov	ds:gvar_save_flag_4,al
										loop	fade_step_loop		; Loop if cx > 0

		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		call	word ptr cs:[2040h]
		test	byte ptr ds:[49h],0FFh
		jz	player_not_captured			; Jump if zero
		mov	byte ptr ds:[0C5h],80h
		jmp	short setup_next_level

player_not_captured:
		mov	al,byte ptr ds:[8Dh]
		add	al,al
		neg	al
		add	al,7Fh
		xor	ah,ah			; Zero register
		call	game_func_143
		mov	byte ptr ds:[85h],0
		mov	word ptr ds:[86h],0
		shr	word ptr ds:[8Bh],1	; Shift w/zeros fill

setup_next_level:
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr ds:[90h],ax
		jmp	short next_level_start

next_level_start:
		mov	byte ptr ds:gvar_timer_ff08,0
		mov	ah,byte ptr ds:[0C5h]
		mov	byte ptr ds:[0C4h],ah
		mov	al,1
		call	word ptr cs:[10Ch]
		mov	ax,ds:target_id
		mov	ds:scroll_count,ax
		mov	si,ds:map_data_ptr
		inc	si
		lodsb				; String [si] to al
		mov	bl,0Bh
		mul	bl			; ax = reg * al
		LOAD_CHUNK_REF sar_ref_map, sprite_load_dest, 2
		mov	bx,6002h
		jmp	level_start
; Treasure/item message table: [msg_id byte][message text][0FFh terminator][value_byte][00h]

item_msg_table:
		db	 26h, 00h			; table header: item count=0x26, terminator
		db	'You get 50 golds.'
		db	0FFh, 22h, 00h
		db	'You get 100 golds.'
		db	0FFh, 22h, 00h
		db	'You get 500 golds.'
		db	0FFh, 1Eh, 00h
		db	'You get 1000 golds.'
		db	0FFh, 32h, 00h
		db	'You get a Key'
; gfx_fn_hitbox_data: base of hitbox bitmask table (test bx,[base+bx] pattern).
; Dual-use: these bytes also form the end of 'You get a Key.' + its message terminator.

gfx_fn_hitbox_data	label	word		; hitbox bitmask table base (test bx,[base+bx])
		db	2Eh			; '.'  ?-- completes 'You get a Key.'
		db	0FFh, 1Ch, 00h		; message terminator, key item value, entry end
		db	'You have recovered.'
		db	0FFh, 08h, 00h
		db	'You have recovered full.'
		db	0FFh, 3Ch, 00h
		db	'Shield broken.'
		db	0FFh, 14h, 00h
		db	'Can\t open this door.'
		db	0FFh, 1Ch, 00h
		db	'Nothing in the box.'
		db	0FFh, 06h, 00h
		db	'You get the Hero\s Crest.'
		db	0FFh, 00h, 00h
		db	'You get the Ruzeria shoes.'
		db	0FFh, 08h, 00h
		db	'You get the Glory Crest.'
		db	0FFh, 06h, 00h
		db	'You get the Pirika shoes.'
		db	0FFh, 06h, 00h
		db	'You get the Feruza shoes.'
		db	0FFh, 00h, 00h
		db	'You get the Silkarn shoes.'
		db	0FFh, 00h, 00h
		db	'Get the Enchantment sword.'
		db	0FFh, 30h, 00h
		db	'It\s too hot !!'
		db	0FFh, 08h, 00h
		db	'Get the lion\s head Key.'
		db	0FFh, 02h
; Resource file name table: [chunk_id_byte][filename][NUL][archive_0based][chunk_1based]
; Each entry loads a SAR chunk (sprite or audio) for the corresponding enemy/music ID

resource_name_table:
		db	'4FMAN.GRP'
		db	0, 2
		db	'8ENCNT.GRP'
		db	0, 2
		db	'5ROKA.GRP'
		db	0, 1
		db	':ROKA.GRP'
		db	0, 2
		db	'7DCHR.GRP'
		db	0, 2, 1
		db	'ROKADEMO.BIN'
		db	 00h, 01h, 1Eh
		db	'MMAN.GRP'
		db	 00h, 01h, 1Fh
		db	'CMAN.GRP'
		db	0, 2
		db	'KMPP1.GRP'
		db	0, 2
		db	'LMPP2.GRP'
		db	0, 2
		db	'MMPP3.GRP'
		db	0, 2
		db	'NMPP4.GRP'
		db	0, 2
		db	'OMPP5.GRP'
		db	0, 2
		db	'PMPP6.GRP'
		db	0, 2
		db	'QMPP7.GRP'
		db	0, 2
		db	'RMPP8.GRP'
		db	0, 2
		db	'SMPP9.GRP'
		db	0, 2
		db	'TMPPA.GRP'
		db	0, 2
		db	'UMPPB.GRP'
		db	0, 2, 2
		db	'EAI1.BIN'
		db	0, 2
		db	0Ah, 'CRAB.BIN'
		db	0, 2, 3
		db	'EAI2.BIN'
		db	 00h, 02h, 0Bh
		db	'TAKO.BIN'
		db	0, 2, 4
		db	'EAI3.BIN'
		db	0, 2
		db	0Ch, 'TORI.BIN'
		db	0, 2, 5
		db	'EAI4.BIN'
		db	0, 2
		db	0Dh, 'ZELA.BIN'
		db	0, 2, 6
		db	'EAI5.BIN'
		db	 00h, 02h, 0Eh
		db	'MEDA.BIN'
		db	0, 2, 7
		db	'EAI6.BIN'
		db	 00h, 02h, 0Fh
		db	'LEGA.BIN'
		db	0, 2
		db	8, 'EAI7.BIN'
		db	 00h, 02h, 11h
		db	'DRGN.BIN'
		db	0, 2
		db	9, 'EAI8.BIN'
		db	 00h, 02h, 12h
		db	'AKMA.BIN'
		db	 00h, 02h, 13h
		db	'MAO1.BIN'
		db	 00h, 02h, 14h
		db	'MAO2.BIN'
		db	 00h, 02h, 10h
		db	'ZEL2.BIN'
		db	0, 2
		db	'9ENP1.GRP'
		db	0, 2
		db	'ACRAB.GRP'
		db	0, 2
		db	':ENP2.GRP'
		db	0, 2
		db	'BTAKO.GRP'
		db	0, 2
		db	';ENP3.GRP'
		db	0, 2
		db	'CTORI.GRP'
		db	0, 2
		db	'<ENP4.GRP'
		db	0, 2
		db	'DZELA.GRP'
		db	0, 2
		db	'=ENP5.GRP'
		db	0, 2
		db	'EMEDA.GRP'
		db	0, 2
		db	'>ENP6.GRP'
		db	0, 2
		db	'FLEGA.GRP'
		db	0, 2
		db	'?ENP7.GRP'
		db	0, 2
		db	'GDRGN.GRP'
		db	0, 2
		db	'@ENP8.GRP'
		db	0, 2
		db	'HAKMA.GRP'
		db	0, 2
		db	'IMAO1.GRP'
		db	0, 2
		db	'JMAO2.GRP'
		db	0, 1
		db	'/MGT1.MSD'
		db	0, 1
		db	'1UGM1.MSD'
		db	0, 1
		db	'0MGT2.MSD'
		db	0, 1
		db	'2UGM2.MSD'
		db	0, 2
		db	'VMUS1.MSD'
		db	0, 2
		db	'WMUS2.MSD'
		db	0, 2
		db	'XMUS3.MSD'
		db	0, 2
		db	'YMUS4.MSD'
		db	0, 2
		db	'ZMUS5.MSD'
		db	0, 2
		db	'[MUS6.MSD'
		db	0, 2
		db	'\MUS7.MSD'
		db	0, 2
		db	']MUS8.MSD'
		db	0, 2
		db	'^MBOS.MSD'
		db	0, 2
		db	'`MMAO.MSD'
		db	9 dup (0)
		db	0FFh, 00h
		db	7 dup (0)
		db	0FFh,0FFh, 00h
		db	12 dup (0)
		db	2, 0
		db	31 dup (0)

seg_a		ends

		end	start
