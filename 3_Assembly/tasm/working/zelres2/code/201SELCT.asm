
PAGE  59,132

;==========================================================================
;
;  CHARACTER_SELECT - Code Module
;
;  Character selection / inventory screen (zelres2 chunk 1).
;  Displays character portraits with weapon, magic, and item panels.
;  Player navigates with joystick (int 61h) or keyboard.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; Graphics driver function table (driver loads at game_seg:2000h).
; Each entry is a CS-relative word pointer into the driver dispatch table.
drv_fn_dispatch		equ	2000h			;* fn  0: coordinate dispatch (clear/fill rect)
drv_fn_12		equ	2018h			;* fn 12: timestamp init area
drv_fn_13		equ	201Ah			;* fn 13: time decode entry
drv_fn_14		equ	201Ch			;* fn 14: render tile from anim_ptr_4
drv_fn_15		equ	201Eh			;* fn 15: sprite source selector A
drv_fn_16		equ	2020h			;* fn 16: sprite source selector B
drv_fn_render_char	equ	2022h			;* fn 17: render_text_char_alt (BX=pos, CL=col, AL=char, AH=color)
drv_fn_19		equ	2026h			;* fn 19: char render pipeline entry
drv_fn_20		equ	2028h			;* fn 20: VGA block copy (stride loop)
drv_fn_sprite		equ	202Eh			;* fn 23: sprite_anim_data dispatch (BX=sprite offset)
drv_fn_render_bg	equ	2030h			;* fn 24: render_tilemap_large
drv_fn_num_fmt		equ	2032h			;* fn 25: number formatter (DI=buf, DX=value)
drv_fn_26		equ	2034h			;* fn 26: render_tilemap_small
drv_fn_27		equ	2036h			;* fn 27: display text string row (BX=pos, AL=char)
drv_fn_28		equ	2038h			;* fn 28: text render helper A
drv_fn_29		equ	203Ah			;* fn 29: text render helper B
drv_fn_30		equ	203Ch			;* fn 30: fill_rectangle helper
drv_fn_32		equ	2040h			;* fn 32: palette/sync call

; Game segment data references (outside module address range).
gvar_selct_state	equ	0A00Bh			;* game-seg byte: character select entry state
panel_dispatch_tbl	equ	0A0C4h			;* jump table: panel_idx ?-> handler (words)
selct_param		equ	0A2B9h			;* game-seg word: selection screen parameter
item_use_dispatch_tbl	equ	0A452h			;* jump table: item_cursor-1 ?-> use handler (words)
item_effect_tbl		equ	0A520h			;* item effect value table (words, indexed by item type)
portrait_rect_tbl	equ	0A9FCh			;* portrait display rect table (4 ?? 5 bytes: BX,CL,mode)
weapon_name_ptrs	equ	0AAB8h			;* weapon name string pointer table (words)
magic_name_ptrs		equ	0AAF3h			;* magic name string pointer table (words)
item_detail_ptrs	equ	0AB62h			;* item detail string pointer table (words)
item_name_ptrs		equ	0AC32h			;* item name string pointer table (words)
weapon_detail_ptrs	equ	0ACD9h			;* weapon detail string pointer table (words)
magic_detail_ptrs	equ	0AD67h			;* magic detail string pointer table (words)
portrait_data_tbl	equ	0ADE8h			;* portrait rect data table (4 ?? 4 bytes: BX/CX pairs)
has_items_flag		equ	0ADF8h			;* byte: non-zero if character has usable items
cur_panel_idx		equ	0ADF9h			;* byte: current panel (0=weapon, 1=magic, 2=item)
weapon_count		equ	0ADFAh			;* byte: number of available weapons
weapon_cursor		equ	0ADFBh			;* byte: current weapon selection cursor (0-based)
magic_count		equ	0ADFCh			;* byte: number of available magic spells
magic_cursor		equ	0ADFDh			;* byte: current magic selection cursor
item_count		equ	0ADFEh			;* byte: number of available items
item_cursor		equ	0ADFFh			;* byte: current item selection cursor
item_sel_idx		equ	0AE00h			;* byte: item select confirm index
exit_queued		equ	0AE01h			;* byte: non-zero ?-> queue exit on next poll
portrait_vis		equ	0AE02h			;* byte: portrait box visible flag (0=hidden, FF=shown)
weapon_idx_tbl		equ	0AE03h			;* 7-byte table: available weapon indices (1-based)
magic_idx_tbl		equ	0AE0Ah			;* 6-byte table: available magic indices (1-based)
item_idx_tbl		equ	0AE10h			;* 5-byte table: available item indices (1-based)
entity_list_ptr		equ	0C00Ah			;* game-seg word: entity list pointer (unused here)
gvar_timer_counter	equ	0FF18h			;* global: timer counter (compared to joy threshold)
gvar_frame_timer	equ	0FF1Ah			;* global: frame timer tick counter
gvar_item_result	equ	0FF4Bh			;* global: selected item result (written on use)
gvar_volume_b		equ	0FF75h			;* global: display region / rendering mode byte

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

selct_main		proc	far

start:
		sbb	ax,0Eh
		add	[si],al
		mov	al,ds:gvar_selct_state
		mov	byte ptr ds:has_items_flag,0
		jmp	short init_continue
		db	0C6h, 06h,0F8h,0ADh,0FFh

init_continue:
		mov	byte ptr ds:portrait_vis,0
		mov	si,portrait_data_tbl
		mov	cx,4

draw_portraits_loop:
					push	cx
					lodsw				; String [si] to ax
					mov	bx,ax
					lodsw				; String [si] to ax
					mov	cx,ax
					push	si
					mov	al,0FFh
					call	word ptr cs:drv_fn_dispatch
					pop	si
					pop	cx
					loop	draw_portraits_loop		; Loop if cx > 0

		call	draw_portrait_tabs
		push	cs
		pop	es
		mov	si,0BBh
		mov	di,weapon_idx_tbl
		xor	cl,cl			; Zero register
		mov	ch,1

scan_weapon_flags:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jz	scan_weapon_next			; Jump if zero
					mov	al,ch
					stosb				; Store al to es:[di]
					inc	cl

scan_weapon_next:
					inc	ch
					cmp	ch,8
					jne	scan_weapon_flags			; Jump if not equal
		mov	ds:weapon_count,cl
		mov	si,0A1h
		mov	di,magic_idx_tbl
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		xor	cl,cl			; Zero register
		mov	ch,5

scan_item_flags:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jz	scan_item_next			; Jump if zero
					stosb				; Store al to es:[di]
					inc	cl

scan_item_next:
					dec	ch
					jnz	scan_item_flags			; Jump if not zero
		or	cl,cl			; Zero ?
		jz	init_panels			; Jump if zero
		inc	cl

init_panels:
		mov	ds:magic_count,cl
		call	rebuild_item_idx
		call	draw_weapon_panel
		call	draw_magic_panel
		call	draw_item_panel
		call	draw_char_stats
		call	poll_input
		sbb	al,al
		mov	ds:exit_queued,al
		xor	cl,cl			; Zero register
		test	byte ptr ds:weapon_count,0FFh
		jnz	set_panel			; Jump if not zero
		inc	cl
		test	byte ptr ds:magic_count,0FFh
		jnz	set_panel			; Jump if not zero
		test	byte ptr ds:has_items_flag,0FFh
		jnz	wait_confirm_loop			; Jump if not zero
		inc	cl
		test	byte ptr ds:item_count,0FFh
		jnz	set_panel			; Jump if not zero

wait_confirm_loop:
					call	poll_input
					jnc	wait_confirm_loop			; Jump if carry=0
		retn

set_panel:
		mov	ds:cur_panel_idx,cl

panel_dispatch:
		mov	bl,ds:cur_panel_idx
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:panel_dispatch_tbl[bx]	;*
			                        ;* No entry point to code
		retf	0BBA0h
			                        ;* No entry point to code
		mov	ax,ds:selct_param
		call	draw_portrait_tabs
		mov	al,2
		call	show_weapon_portrait

wait_joy_neutral:
					int	61h			; ??INT Non-standard interrupt
					and	al,3
					jnz	wait_joy_neutral			; Jump if not zero

weapon_input_loop:
								call	poll_input
								jnc	weapon_poll_input			; Jump if carry=0
								retn

weapon_poll_input:
								int	61h			; ??INT Non-standard interrupt
								and	al,0Eh
								jz	weapon_input_loop			; Jump if zero
								and	al,0Ch
								jnz	weapon_joy_down			; Jump if not zero
								jmp	weapon_confirm

weapon_joy_down:
								test	al,4
								jnz	weapon_joy_up			; Jump if not zero
								mov	al,ds:weapon_cursor
								inc	al
								mov	ah,ds:weapon_count
								dec	ah
								cmp	ah,al
								jb	weapon_input_loop			; Jump if below
								xor	al,al			; Zero register
								call	show_weapon_portrait
								inc	byte ptr ds:weapon_cursor
								mov	al,2
								call	show_weapon_portrait
								mov	byte ptr ds:gvar_volume_b,0Ch
								call	draw_weapon_cursor
								jmp	short weapon_input_loop

weapon_joy_up:
								test	byte ptr ds:weapon_cursor,0FFh
								jz	weapon_input_loop			; Jump if zero
					xor	al,al			; Zero register
					call	show_weapon_portrait
					dec	byte ptr ds:weapon_cursor
					mov	al,2
					call	show_weapon_portrait
					mov	byte ptr ds:gvar_volume_b,0Ch
					call	draw_weapon_cursor
					jmp	short weapon_input_loop

selct_main		endp

draw_weapon_cursor		proc	near
		mov	bx,weapon_idx_tbl
		mov	al,ds:weapon_cursor
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[9Dh],al
		mov	bx,2711h
		mov	cx,1009h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:weapon_name_ptrs[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0C7h, 008h
		mov	al,byte ptr ds:[9Dh]
		mov	bx,37A4h
		call	word ptr cs:drv_fn_15
		call	word ptr cs:drv_fn_12

wait_joy_clear_weapon:
					int	61h			; ??INT Non-standard interrupt
					and	al,0Ch
					jnz	wait_joy_clear_weapon			; Jump if not zero
		retn

draw_weapon_cursor		endp

show_weapon_portrait		proc	near
		mov	bh,ds:weapon_cursor
		xor	bl,bl			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,0E1Ah
		jmp	word ptr cs:drv_fn_sprite

show_weapon_portrait		endp

weapon_confirm:
		mov	cl,1
		test	byte ptr ds:magic_count,0FFh
		jnz	weapon_switch_panel			; Jump if not zero
		test	byte ptr ds:has_items_flag,0FFh
		mov	cl,2
		test	byte ptr ds:item_count,0FFh
		jnz	weapon_switch_panel			; Jump if not zero
		jmp	weapon_input_loop

weapon_switch_panel:
		mov	byte ptr ds:gvar_volume_b,0Dh
		mov	ds:cur_panel_idx,cl
		mov	al,5
		call	show_weapon_portrait
		jmp	panel_dispatch
			                        ;* No entry point to code
		call	draw_portrait_tabs
		mov	al,2
		call	show_magic_portrait

magic_wait_neutral:
					int	61h			; ??INT Non-standard interrupt
					and	al,3
					jnz	magic_wait_neutral			; Jump if not zero

magic_input_loop:
								call	poll_input
								jnc	magic_poll_input			; Jump if carry=0
								retn

magic_poll_input:
								int	61h			; ??INT Non-standard interrupt
								and	al,0Fh
								jz	magic_input_loop			; Jump if zero
								mov	ah,al
								and	al,0Ch
								jnz	magic_joy_down_chk			; Jump if not zero
								jmp	magic_check_confirm

magic_joy_down_chk:
								test	al,4
								jnz	magic_joy_up			; Jump if not zero
								mov	al,ds:magic_cursor
								inc	al
								mov	ah,ds:magic_count
								dec	ah
								cmp	ah,al
								jb	magic_input_loop			; Jump if below
								xor	al,al			; Zero register
								call	show_magic_portrait
								inc	byte ptr ds:magic_cursor
								mov	al,2
								call	show_magic_portrait
								mov	byte ptr ds:gvar_volume_b,0Ch
								call	draw_magic_cursor
								jmp	short magic_input_loop

magic_joy_up:
								test	byte ptr ds:magic_cursor,0FFh
								jz	magic_input_loop			; Jump if zero
					xor	al,al			; Zero register
					call	show_magic_portrait
					dec	byte ptr ds:magic_cursor
					mov	al,2
					call	show_magic_portrait
					mov	byte ptr ds:gvar_volume_b,0Ch
					call	draw_magic_cursor
					jmp	short magic_input_loop

draw_magic_cursor		proc	near
		mov	bx,magic_idx_tbl
		mov	al,ds:magic_cursor
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[9Eh],al
		mov	bx,1742h
		mov	cx,1611h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		mov	bl,byte ptr ds:[9Eh]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:magic_name_ptrs[bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0D6h, 007h
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0CCh, 007h

wait_joy_clear_magic:
					int	61h			; ??INT Non-standard interrupt
					and	al,0Ch
					jnz	wait_joy_clear_magic			; Jump if not zero
		retn

draw_magic_cursor		endp

show_magic_portrait		proc	near
		mov	bh,ds:magic_cursor
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,0E53h
		jmp	word ptr cs:drv_fn_sprite

show_magic_portrait		endp

magic_check_confirm:
		test	ah,1
		jz	magic_confirm_chk2			; Jump if zero
		test	byte ptr ds:weapon_count,0FFh
		jnz	magic_select_weapon_tab			; Jump if not zero
		jmp	magic_input_loop

magic_select_weapon_tab:
		mov	byte ptr ds:cur_panel_idx,0
		jmp	short magic_switch_panel

magic_confirm_chk2:
		test	byte ptr ds:has_items_flag,0FFh
		jz	magic_confirm_chk3			; Jump if zero
		jmp	magic_input_loop

magic_confirm_chk3:
		test	byte ptr ds:item_count,0FFh
		jnz	magic_select_item_tab			; Jump if not zero
		jmp	magic_input_loop

magic_select_item_tab:
		mov	byte ptr ds:cur_panel_idx,2

magic_switch_panel:
		mov	byte ptr ds:gvar_volume_b,0Dh
		mov	al,5
		call	show_magic_portrait
		jmp	panel_dispatch
			                        ;* No entry point to code
		call	draw_portrait_tabs
		mov	al,2
		call	show_item_portrait

item_wait_neutral:
					int	61h			; ??INT Non-standard interrupt
					and	al,3
					jnz	item_wait_neutral			; Jump if not zero

item_input_loop:
								call	poll_input
								jnc	item_poll_input			; Jump if carry=0
								retn

item_poll_input:
								cmp	word ptr ds:gvar_timer_counter,286h
								jne	item_not_confirm			; Jump if not equal
								jmp	item_confirm_chk

item_not_confirm:
								int	61h			; ??INT Non-standard interrupt
								and	ah,1
								jz	item_no_button			; Jump if zero
								jmp	item_button_select

item_no_button:
								and	al,0Dh
								jz	item_input_loop			; Jump if zero
								push	ax
								call	hide_portrait_box
								pop	ax
								and	al,0Ch
								jnz	item_joy_down_chk			; Jump if not zero
								jmp	item_check_tab

item_joy_down_chk:
								test	al,4
								jnz	item_joy_up			; Jump if not zero
								mov	al,ds:item_sel_idx
								inc	al
								mov	ah,ds:item_count
								dec	ah
								cmp	ah,al
								jb	item_input_loop			; Jump if below
								xor	al,al			; Zero register
								call	show_item_portrait
								inc	byte ptr ds:item_sel_idx
								mov	al,2
								call	show_item_portrait
								mov	byte ptr ds:gvar_volume_b,0Ch
								call	draw_item_cursor
								jmp	short item_input_loop

item_joy_up:
								test	byte ptr ds:item_sel_idx,0FFh
								jz	item_input_loop			; Jump if zero
					xor	al,al			; Zero register
					call	show_item_portrait
					dec	byte ptr ds:item_sel_idx
					mov	al,2
					call	show_item_portrait
					mov	byte ptr ds:gvar_volume_b,0Ch
					call	draw_item_cursor
					jmp	short item_input_loop

draw_item_cursor		proc	near
		mov	bx,item_idx_tbl
		mov	al,ds:item_sel_idx
		xlat				; al=[al+[bx]] table
		mov	ds:item_cursor,al
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		mov	bl,ds:item_cursor
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:item_name_ptrs[bx]
		mov	bx,54h
		mov	cl,70h			; 'p'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0C2h, 006h
		mov	bx,54h
		mov	cl,78h			; 'x'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0B8h, 006h

wait_joy_clear_item:
					int	61h			; ??INT Non-standard interrupt
					and	al,0Ch
					jnz	wait_joy_clear_item			; Jump if not zero
		retn

draw_item_cursor		endp

show_item_portrait		proc	near

show_item_portrait_entry:
		mov	bh,ds:item_sel_idx
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,0E81h
		jmp	word ptr cs:drv_fn_sprite

show_item_portrait		endp

item_check_tab:
		mov	cl,1
		test	byte ptr ds:magic_count,0FFh
		jnz	item_switch_panel			; Jump if not zero
		xor	cl,cl			; Zero register
		test	byte ptr ds:weapon_count,0FFh
		jnz	item_switch_panel			; Jump if not zero
		jmp	item_input_loop

item_switch_panel:
		mov	ds:cur_panel_idx,cl
		mov	byte ptr ds:gvar_volume_b,0Dh
		mov	al,5
		call	show_item_portrait
		jmp	panel_dispatch

item_confirm_chk:
		test	byte ptr ds:portrait_vis,0FFh
		jz	item_use_entry			; Jump if zero
		jmp	item_input_loop

item_use_entry:
		call	show_portrait_box
		mov	bx,1B43h
		mov	cx,1A24h
		mov	al,0FFh
		call	word ptr cs:drv_fn_dispatch
		mov	si,0AAA2h
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 04Dh, 006h
		mov	al,byte ptr ds:[8Dh]
		xor	ah,ah			; Zero register
		inc	ax
		mov	cx,2
		mov	bl,6
		mov	dx,2C4Ch
		call	fmt_number
		mov	si,0AAA8h
		mov	bx,80h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 02Fh, 006h
		mov	ax,word ptr ds:[8Eh]
		mov	cx,5
		mov	bl,6
		mov	dx,2856h
		call	fmt_number
		jmp	item_input_loop

item_button_select:
		test	byte ptr ds:item_cursor,0FFh
		jnz	item_use_action			; Jump if not zero
		jmp	item_input_loop

item_use_action:
		call	hide_portrait_box
		mov	ax,0A2C7h
		push	ax
		mov	ax,0A5B4h
		push	ax
		mov	cl,ds:item_sel_idx
		xor	ch,ch			; Zero register
		mov	bx,0A6h

find_item_by_idx:
					test	byte ptr [bx],0FFh
					jz	find_item_next			; Jump if zero
					inc	ch

find_item_next:
					inc	bx
					cmp	ch,cl
					jne	find_item_by_idx			; Jump if not equal
		mov	byte ptr [bx-1],0
		call	rebuild_item_idx
		mov	al,ds:item_cursor
		mov	ds:gvar_item_result,al
		mov	bl,ds:item_cursor
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:item_use_dispatch_tbl[bx]	;*
		db	 62h,0A4h, 83h,0A4h, 96h,0A4h
		db	0BEh,0A4h, 2Ch,0A5h,0EAh,0A4h
		db	0DBh,0A4h, 8Bh,0A5h,0C6h, 06h
		db	 75h,0FFh, 0Eh, 83h, 06h, 90h
		db	 00h, 50h,0A1h, 90h, 00h, 2Bh
		db	 06h,0B2h, 00h, 72h, 06h,0A1h
		db	0B2h, 00h,0A3h, 90h, 00h, 2Eh
		db	0FFh, 16h, 08h, 20h,0E9h, 57h
		db	 01h,0C6h, 06h, 75h,0FFh, 0Eh
		db	0A1h,0B2h, 00h,0A3h, 90h, 00h
		db	 2Eh,0FFh, 16h, 08h, 20h,0E9h
		db	 44h, 01h,0C6h, 06h, 75h,0FFh
		db	 0Eh,0F6h, 06h, 9Dh, 00h,0FFh
		db	 75h, 01h,0C3h

use_item_apply:
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[0B4h][bx]
		mov	byte ptr ds:[0ABh][bx],al
		call	word ptr cs:drv_fn_12
		call	draw_weapon_list
		jmp	draw_item_detail_entry
			                        ;* No entry point to code
		mov	byte ptr ds:gvar_volume_b,0Eh
		push	cs
		pop	es
		mov	si,0B4h
		mov	di,0ABh
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		call	word ptr cs:drv_fn_12
		call	draw_weapon_list
		jmp	draw_item_detail_entry
			                        ;* No entry point to code
		mov	byte ptr ds:gvar_volume_b,0Eh
		inc	byte ptr ds:[0E4h]
		call	draw_key_count
		jmp	draw_item_detail_entry
			                        ;* No entry point to code
		mov	byte ptr ds:gvar_volume_b,0Eh
		test	byte ptr ds:[93h],0FFh
		jnz	apply_item_exp			; Jump if not zero
		retn

apply_item_exp:
		mov	bl,byte ptr ds:[93h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:item_effect_tbl[bx]
		add	word ptr ds:[94h],ax
		mov	ax,word ptr ds:[94h]
		sub	ax,word ptr ds:[96h]
		jc	cap_exp			; Jump if carry Set
		mov	ax,word ptr ds:[96h]
		mov	word ptr ds:[94h],ax

cap_exp:
		call	word ptr cs:drv_fn_13
		jmp	draw_item_detail_entry
			                        ;* No entry point to code
		push	ax
		add	[bp+si+0],bl			; was: db 00h, 5Ah, 00h
		db	 64h, 00h, 6Eh, 00h, 73h, 00h
		db	 78h, 00h, 0Eh, 07h,0C6h, 06h
		db	 75h,0FFh, 0Eh,0C6h, 06h, 84h
		db	0A5h, 00h,0C6h, 06h, 85h,0A5h
		db	 01h,0BEh, 84h,0A5h,0BFh, 60h
		db	0EBh,0B9h, 07h, 00h,0F3h,0A4h
		db	0C6h, 06h, 84h,0A5h, 04h,0C6h
		db	 06h, 85h,0A5h,0FFh,0BEh, 84h
		db	0A5h,0BFh, 67h,0EBh,0B9h, 07h
		db	 00h,0F3h,0A4h,0C6h, 06h, 84h
		db	0A5h, 08h,0BEh, 84h,0A5h,0BFh
		db	 6Eh,0EBh,0B9h, 07h, 00h,0F3h
		db	0A4h,0C6h, 06h, 84h,0A5h, 0Ch
		db	0C6h, 06h, 85h,0A5h, 01h,0BEh
		db	 84h,0A5h,0BFh, 75h,0EBh,0B9h
		db	 07h, 00h,0F3h,0A4h,0EBh, 56h
		db	 00h, 00h, 50h, 00h, 00h, 00h
		db	 00h,0C6h, 06h, 75h,0FFh, 0Fh
		db	0E8h, 47h, 00h,0E8h, 1Eh, 00h
		db	 58h, 58h,0C6h, 06h, 24h,0FFh
		db	 08h,0C6h, 06h, 1Ah,0FFh, 00h

wait_timer_done:
					cmp	byte ptr ds:gvar_frame_timer,78h	; 'x'
					jb	wait_timer_done			; Jump if below
		call	word ptr cs:drv_fn_32
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		retn

init_item_panel		proc	near
		xor	al,al			; Zero register
		call	show_item_portrait
		mov	bx,0E83h
		mov	cx,1E10h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		test	byte ptr ds:item_count,0FFh
		jnz	check_item_present			; Jump if not zero
		mov	byte ptr ds:item_count,1

check_item_present:
		call	draw_item_panel
		mov	al,2
		jmp	show_item_portrait_entry

init_item_panel		endp

draw_item_detail		proc	near

draw_item_detail_entry:
		call	show_portrait_box
		mov	bx,0F43h
		mov	cx,3224h
		mov	al,0FFh
		call	word ptr cs:drv_fn_dispatch
		mov	si,0AAACh
		mov	bx,44h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 034h, 004h
		mov	bl,ds:item_cursor
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:item_detail_ptrs[bx]
		mov	bx,48h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		jmp	init_panels6			;*

draw_item_detail		endp

		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 01Ch, 004h

show_portrait_box		proc	near
		test	byte ptr ds:portrait_vis,0FFh
		jz	portrait_box_draw			; Jump if zero
		retn

portrait_box_draw:
		mov	byte ptr ds:portrait_vis,0FFh
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:drv_fn_19

show_portrait_box		endp

hide_portrait_box		proc	near
		test	byte ptr ds:portrait_vis,0FFh
		jnz	portrait_box_hide			; Jump if not zero
		retn

portrait_box_hide:
		mov	byte ptr ds:portrait_vis,0
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:drv_fn_20

hide_portrait_box		endp

rebuild_item_idx		proc	near
		push	cs
		pop	es
		mov	si,0A6h
		mov	di,item_idx_tbl
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		xor	cl,cl			; Zero register
		mov	ch,5

item_idx_scan:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jz	item_idx_skip			; Jump if zero
					stosb				; Store al to es:[di]
					inc	cl

item_idx_skip:
					dec	ch
					jnz	item_idx_scan			; Jump if not zero
		or	cl,cl			; Zero ?
		jz	item_idx_done			; Jump if zero
		inc	cl

item_idx_done:
		mov	ds:item_count,cl
		retn

rebuild_item_idx		endp

draw_item_panel		proc	near
		test	byte ptr ds:item_count,0FFh
		jz	item_panel_empty			; Jump if zero
		mov	cl,ds:item_count
		xor	ch,ch			; Zero register
		mov	bx,0E83h
		mov	si,item_idx_tbl

draw_item_panel_loop:
					push	cx
					lodsb				; String [si] to al
					push	si
					push	bx
					call	word ptr cs:drv_fn_27
					pop	bx
					pop	si
					add	bx,500h
					pop	cx
					loop	draw_item_panel_loop		; Loop if cx > 0

		mov	byte ptr ds:item_cursor,0
		mov	byte ptr ds:item_sel_idx,0
		test	byte ptr ds:has_items_flag,0FFh
		jz	item_panel_has_items			; Jump if zero
		retn

item_panel_has_items:
		mov	bx,0E81h
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		mov	si,0AA9Ah
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 067h, 003h

item_panel_empty:
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	si,0AA92h
		mov	ah,1
;*		jmp	init_panels6			;*

draw_item_panel		endp

		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 05Ah, 003h

draw_magic_panel		proc	near
		test	byte ptr ds:magic_count,0FFh
		jz	magic_panel_empty			; Jump if zero
		mov	cl,ds:magic_count
		xor	ch,ch			; Zero register
		mov	bx,0E55h
		mov	si,magic_idx_tbl

draw_magic_panel_loop:
					push	cx
					lodsb				; String [si] to al
					push	si
					push	bx
					call	word ptr cs:drv_fn_26
					pop	bx
					pop	si
					add	bx,500h
					pop	cx
					loop	draw_magic_panel_loop		; Loop if cx > 0

		push	cs
		pop	es
		mov	di,magic_idx_tbl
		mov	al,byte ptr ds:[9Eh]
		mov	cx,6
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,5
		mov	ds:magic_cursor,cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		mov	bx,cx
		add	cx,cx
		add	cx,cx
		add	cx,bx
		add	cx,0E53h
		mov	bx,cx
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bl,byte ptr ds:[9Eh]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:magic_name_ptrs[bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0F0h, 002h
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 0E6h, 002h

magic_panel_empty:
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	si,0AA92h
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 0D9h, 002h

draw_char_stats:
		test	byte ptr ds:[92h],0FFh
		jz	draw_stat_93h			; Jump if zero
		mov	bx,174Dh
		mov	al,byte ptr ds:[92h]
		call	word ptr cs:drv_fn_14
		mov	bl,byte ptr ds:[92h]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:weapon_detail_ptrs[bx]
		mov	bx,344Eh
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		mov	bx,3456h
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		call	draw_key_count

draw_stat_93h:
		test	byte ptr ds:[93h],0FFh
		jz	draw_stat_98h			; Jump if zero
		mov	bx,2E61h
		mov	al,byte ptr ds:[93h]
		call	word ptr cs:drv_fn_16
		mov	bl,byte ptr ds:[93h]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:magic_detail_ptrs[bx]
		mov	bx,3461h
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		mov	bx,3469h
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		call	draw_exp_bar

draw_stat_98h:
		test	byte ptr ds:[98h],0FFh
		jz	draw_stat_99h			; Jump if zero
		mov	bx,2E75h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_29
		mov	bx,0C8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:drv_fn_render_char
		mov	al,byte ptr ds:[98h]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,347Eh
		call	fmt_number

draw_stat_99h:
		test	byte ptr ds:[99h],0FFh
		jz	draw_abilities			; Jump if zero
		mov	bx,3A75h
		mov	al,1
		call	word ptr cs:drv_fn_29
		mov	bx,0F8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:drv_fn_render_char
		mov	al,byte ptr ds:[99h]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,407Eh
		call	fmt_number

draw_abilities:
		mov	si,9Ah
		mov	bx,3089h
		mov	cx,3

draw_ability_loop:
					push	cx
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jz	ability_row_skip			; Jump if zero
					mov	al,cl
					neg	al
					add	al,3
					push	bx
					push	si
					call	word ptr cs:drv_fn_30
					pop	si
					pop	bx
					add	bx,600h

ability_row_skip:
					pop	cx
					loop	draw_ability_loop		; Loop if cx > 0

		retn

draw_exp_bar:
		mov	ax,word ptr ds:[96h]
		mov	dx,3469h
		mov	cx,3
		mov	bl,4
		call	fmt_number
		mov	bx,0CAh
		mov	cl,69h			; 'i'
		mov	al,28h			; '('
		mov	ah,4
		call	word ptr cs:drv_fn_render_char
		mov	bx,0E0h
		mov	cl,69h			; 'i'
		mov	al,29h			; ')'
		mov	ah,4
		jmp	word ptr cs:drv_fn_render_char

draw_key_count:
		test	byte ptr ds:[0E4h],0FFh
		jnz	draw_key_count_body			; Jump if not zero
		retn

draw_key_count_body:
		mov	bx,3257h
		mov	cx,408h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_dispatch
		mov	bx,0CAh
		mov	cl,57h			; 'W'
		mov	al,28h			; '('
		mov	ah,1
		call	word ptr cs:drv_fn_render_char
		mov	al,byte ptr ds:[0E4h]
		xor	ah,ah			; Zero register
		mov	dx,3457h
		mov	bl,1
		mov	cx,1
		call	fmt_number
		mov	bx,0D4h
		mov	cl,57h			; 'W'
		mov	al,29h			; ')'
		mov	ah,1
		jmp	word ptr cs:drv_fn_render_char

draw_weapon_panel:
		test	byte ptr ds:weapon_count,0FFh
		jz	weapon_panel_empty			; Jump if zero
		mov	cl,ds:weapon_count
		xor	ch,ch			; Zero register
		mov	bx,0E1Ch
		mov	si,weapon_idx_tbl

draw_weapon_panel_loop:
					push	cx
					lodsb				; String [si] to al
					push	si
					push	bx
					call	word ptr cs:drv_fn_15
					pop	bx
					pop	si
					add	bx,800h
					pop	cx
					loop	draw_weapon_panel_loop		; Loop if cx > 0

		call	draw_weapon_list
		push	cs
		pop	es
		mov	di,weapon_idx_tbl
		mov	al,byte ptr ds:[9Dh]
		mov	cx,7
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,6
		mov	ds:weapon_cursor,cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,0E1Ah
		mov	bx,cx
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bl,byte ptr ds:[9Dh]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:weapon_name_ptrs[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 00Fh, 001h

weapon_panel_empty:
		mov	bx,9Eh
		mov	cl,12h
		mov	si,0AA92h
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 002h, 001h

draw_weapon_list:
		mov	dx,0E2Eh
		mov	si,weapon_idx_tbl
		mov	cl,ds:weapon_count
		xor	ch,ch			; Zero register

draw_weapon_list_loop:
					push	cx
					lodsb				; String [si] to al
					push	si
					push	dx
					dec	al
					mov	bl,al
					xor	bh,bh			; Zero register
					mov	al,byte ptr ds:[0ABh][bx]
					mov	ah,byte ptr ds:[0B4h][bx]
					push	ax
					push	dx
					push	ax
					push	dx
					mov	bx,dx
					mov	cx,508h
					xor	al,al			; Zero register
					call	word ptr cs:drv_fn_dispatch
					pop	dx
					pop	ax
					xor	ah,ah			; Zero register
					mov	bl,1
					mov	cx,3
					call	fmt_number
					pop	dx
					add	dx,9
					push	dx
					sub	dx,200h
					mov	cl,dl
					mov	bl,dh
					xor	bh,bh			; Zero register
					add	bx,bx
					add	bx,bx
					inc	bx
					inc	bx
					mov	al,28h			; '('
					mov	ah,4
					call	word ptr cs:drv_fn_render_char
					pop	dx
					pop	ax
					mov	al,ah
					push	dx
					xor	ah,ah			; Zero register
					mov	bl,4
					mov	cx,3
					call	fmt_number
					pop	dx
					add	dx,400h
					mov	cl,dl
					mov	bl,dh
					xor	bh,bh			; Zero register
					add	bx,bx
					add	bx,bx
					dec	bx
					mov	al,29h			; ')'
					mov	ah,4
					call	word ptr cs:drv_fn_render_char
					pop	dx
					add	dx,800h
					pop	si
					pop	cx
					loop	draw_weapon_list_loop		; Loop if cx > 0

		retn

fmt_number:
		push	bx
		push	dx
		push	cx
		xor	dl,dl			; Zero register
		mov	di,0AE16h
		call	word ptr cs:drv_fn_num_fmt
		pop	cx
		mov	di,0AE16h
		mov	al,7
		sub	al,cl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	ax
		pop	bx
		xor	bh,bh			; Zero register
		jmp	word ptr cs:drv_fn_render_bg

draw_portrait_tabs:
		mov	si,portrait_rect_tbl
		mov	cx,4

draw_tabs_loop:
					push	cx
					mov	dh,cl
					lodsw				; String [si] to ax
					mov	bx,ax
					lodsb				; String [si] to al
					mov	cl,al
					mov	dl,ds:cur_panel_idx
					neg	dh
					add	dh,4
					mov	ah,3
					cmp	dl,dh
					jne	tab_not_active			; Jump if not equal
					mov	ah,2

tab_not_active:
;*		call	draw_portrait_tabs_fn21			;*
					call	scan_draw_string
					db	00Ch			; was: db 0E8h, 033h, 000h
					pop	cx
					loop	draw_tabs_loop		; Loop if cx > 0

		retn
			                        ;* No entry point to code
		xor	al,0
		adc	dl,[bp+di+45h]
		; Menu shortcut table prefix entries
		db	'4', 0		; 0x0000
		db	012h		; 0x0002
		db	'SELT-MAGIC:', 0		; 0x0003
		db	'4', 0		; 0x000F
		db	'4', 0			; 0x0A2A: shortcut key '4'
		db	071h, 'USE:', 0		; 0x0A2C: 0x71 key -> USE
		db	0B8h, 0			; 0x0A32: (non-printable key)
		db	'CINVENTORY', 0		; 0x0A34: 'C' key -> INVENTORY
		db	00h				; 0x0A3E: null terminator

scan_draw_string:					; string-scan function entry point
					lodsb				; load byte from [DS:SI], advance SI
					or	al,al				; test if zero (null terminator)
					jnz	scan_char_notnull			; Jump if not zero
					retn

scan_char_notnull:
					push	si
					cmp	ah,1
					je	scan_char_draw			; Jump if equal
					push	bx
					push	cx
					push	ax
					inc	bx
					inc	cl
					mov	ah,5
					call	word ptr cs:drv_fn_render_char
					pop	ax
					pop	cx
					pop	bx

scan_char_draw:
					push	bx
					push	cx
					push	ax
					call	word ptr cs:drv_fn_render_char
					pop	ax
					pop	cx
					pop	bx
					pop	si
					add	bx,8
;*		jmp	short init_panels6		;*
					jmp	short scan_draw_string
		db	00Ch			; was: db 0EBh, 0D3h

poll_input:
		call	word ptr cs:[110h]
		call	word ptr cs:[112h]
		call	word ptr cs:[114h]
		call	word ptr cs:[116h]
		call	word ptr cs:[118h]
		test	byte ptr ds:exit_queued,0FFh
		jz	check_joy_neutral_entry			; Jump if zero
		call	check_joy_neutral
		cmc				; Complement carry
		jc	poll_exit_queued			; Jump if carry Set
		retn

poll_exit_queued:
		clc				; Clear carry flag
		mov	byte ptr ds:exit_queued,0
		retn

check_joy_neutral:

check_joy_neutral_entry:
		test	word ptr ds:gvar_timer_counter,1
		stc				; Set carry flag
		jz	joy_has_dir			; Jump if zero
		retn

joy_has_dir:
		clc				; Clear carry flag
		retn

draw_magic_panel		endp

		db	'NOTHING', 0
		db	'NO USE', 0
		db	00h			; padding
		db	'LEVEL', 0
		db	'EXP', 0
		db	'I have used'
		db	 00h,0C6h,0AAh,0CDh,0AAh,0D3h
		db	0AAh,0D9h,0AAh,0E0h,0AAh,0E7h
		db	0AAh,0ECh,0AAh
		db	'Espada', 0
		db	'Saeta', 0
		db	'Fuego', 0
		db	'Lanzar', 0
		db	'Rascar', 0
		db	'Agua', 0
		db	'Guerra', 0
		db	 9Ah,0AAh,0FFh,0AAh, 12h,0ABh
		db	 25h,0ABh, 39h,0ABh, 4Dh,0ABh
		db	'Feruza', 0
		db	'      shoes', 0
		db	'Pirika', 0
		db	'      shoes', 0
		db	'Silkarn', 0
		db	'      shoes', 0
		db	'Ruzeria', 0
		db	'      shoes', 0
		db	'Asbestos', 0
		db	'       cape', 0
		db	 72h,0ABh, 8Ah,0ABh,0A2h,0ABh
		db	0BAh,0ABh,0D2h,0ABh,0EAh,0ABh
		db	 02h,0ACh, 1Ah,0ACh
		db	'       a Ken\ko Potion.', 0
		db	'        a Juu-en Fruit.', 0
		db	'     a Elixir of Kashi.', 0
		db	'      a Chikara Powder.', 0
		db	'         a Magia Stone.', 0
		db	' a Holy Water of Acero.', 0
		db	'           a Sabre Oil.', 0
		db	'       a Kioku Feather.', 0
		db	 9Ah,0AAh, 44h,0ACh, 58h,0ACh
		db	 6Dh,0ACh, 81h,0ACh, 96h,0ACh
		db	0A3h,0ACh,0BBh,0ACh,0C6h,0ACh
		db	'Ken\ko', 0
		db	'      Potion', 0
		db	'Juu-en ', 0
		db	'       Fruit', 0
		db	'Elixir', 0
		db	'    of Kashi', 0
		db	'Chikara', 0
		db	'      Powder', 0
		db	'Magia Stone'
		db	0, 0
		db	'Holy Water', 0
		db	'    of Acero', 0
		db	'Sabre Oil', 0
		db	0			; padding
		db	'Kioku', 0
		db	'     feather'
		db	 00h,0E5h,0ACh,0F9h,0ACh, 10h
		db	0ADh, 21h,0ADh, 34h,0ADh, 4Eh
		db	0ADh
		db	'Training', 0
		db	'     Sword', 0
		db	'Wise man\s', 0
		db	'      Sword', 0
		db	'Spirit', 0
		db	'    Sword', 0
		db	'Knight\s', 0
		db	'    Sword', 0
		db	'Illumination', 0
		db	'       Sword', 0
		db	'Enchantment', 0
		db	'       Sword', 0
		db	 73h,0ADh, 84h,0ADh, 9Ch,0ADh
		db	0AEh,0ADh,0C0h,0ADh,0D2h,0ADh
		db	'Clay', 0
		db	'     Shield', 0
		db	'Wise Man\s', 0
		db	'      Shield', 0
		db	'Stone', 0
		db	'     Shield', 0
		db	'Honor', 0
		db	'     Shield', 0
		db	'Light', 0
		db	'     Shield', 0
		db	'Titanium', 0
		db	'      Shield', 0
		db	0Eh
		db	0Ch, '38?', 0Ch, '0"m', 0Ch, '0"?'
		db	'-^'
		db	17h
		db	37 dup (0)

seg_a		ends

		end	start
