
PAGE  59,132

;==========================================================================
;
;  CHARACTER_SELECT - Code Module
;
;  Character selection / inventory screen (zelres2 chunk 1).
;  Displays character portraits with weapon, magic, and item panels.
;  Player navigates with joystick (int 61h) or keyboard.
;
;  Connections:
;    Loads:        none directly -- inventory data already resident in
;                  game-segment DS (chr_/weap_/magic_/item_ flag arrays).
;    Calls into:   drv_fill_rect, drv_palette_push, drv_anim_step,
;                  drv_render_char, drv_return_to_caller, drv_fn_sprite,
;                  drv_fn_render_bg, drv_fn_num_fmt
;                    (graphics-driver dispatch slots, cs:[2000h..203Ch],
;                    populated by the active GFxxx driver).
;                  cs:[110h..118h] -- driver palette/save-state init
;                    sequence (run on entry/exit).
;                  panel_dispatch_tbl (DS:0A0C4h) -- weapon/magic/item
;                    panel handler jump table (filled by caller).
;                  item_use_dispatch_tbl (DS:0A452h) -- per-item use
;                    handler jump table.
;    Called by:    zeliad.exe game.asm at game start (character-select
;                    entry); re-entered mid-game when player opens the
;                    inventory/equip screen via menu.
;    Reads/writes: gvar_selct_state (DS:0A00Bh -- entry sub-state),
;                  gvar_volume_b (DS:0FF75h -- display/render mode),
;                  gvar_frame_timer / gvar_timer_counter
;                    (DS:0FF1Ah / 0FF18h -- joystick hold + Kioku Feather
;                    save delay), gvar_item_result (DS:0FF4Bh -- selected
;                    item code returned to caller), char stat block at
;                    DS:[80h..0E4h] (HP/EXP/equipped weapon/magic/items).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in zr2com.inc
; ----------------------------------------------------------------------
gvar_selct_state	equ	0A00Bh			;* game-seg byte: character select entry state
gvar_timer_counter	equ	0FF18h			;* global: joystick hold timer counter
gvar_frame_timer	equ	0FF1Ah			;* global: frame timer tick counter
gvar_item_result	equ	0FF4Bh			;* global: selected item result (written on use)
gvar_volume_b		equ	0FF75h			;* global: display region / rendering mode byte
gvar_display_mode	equ	0FF24h			;* global: display mode flag (set before save)

; ----------------------------------------------------------------------
; Section 4: Shared dispatch slot references (file-local overrides)
; ----------------------------------------------------------------------
drv_fn_13		equ	201Ah			;* fn 13: time decode entry
drv_fn_14		equ	201Ch			;* fn 14: render tile from anim_ptr_4
drv_fn_15		equ	201Eh			;* fn 15: sprite source selector A
drv_fn_16		equ	2020h			;* fn 16: sprite source selector B
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

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
panel_dispatch_tbl	equ	0A0C4h			;* jump table: panel_idx -> handler (words, filled by caller)
selct_param		equ	0A2B9h			;* game-seg word: selection screen parameter
item_effect_tbl		equ	0A520h			;* item effect value table (words, indexed by magic type)
portrait_rect_tbl	equ	0A9FCh			;* portrait display rect table (4 x 5 bytes: BX,CL,mode)
str_empty		equ	SELCT_BASE + (offset str_empty_lbl)		;* blank panel text (empty/null string)
str_no_use_notice	equ	SELCT_BASE + (offset str_no_use_notice_lbl)	;* item panel notice string (no-use hint)
str_item_used_count	equ	SELCT_BASE + (offset str_item_used_count_lbl)	;* item-use box: count label
str_item_used_total	equ	SELCT_BASE + (offset str_item_used_total_lbl)	;* item-use box: total label
str_item_detail_hdr	equ	SELCT_BASE + (offset str_item_detail_hdr_lbl)	;* item detail header ("I have used...")
spell_name_ptrs	equ	SELCT_BASE + (offset spell_name_ptrs_lbl)	;* weapon name string pointer table (7 words)
shoe_name_ptrs		equ	SELCT_BASE + (offset shoe_name_ptrs_lbl)	;* magic name string pointer table (6 words)
item_detail_ptrs	equ	SELCT_BASE + (offset item_detail_ptrs_lbl)	;* item detail string pointer table (8 words)
item_name_ptrs		equ	SELCT_BASE + (offset item_name_ptrs_lbl)	;* item name string pointer table (9 words: NO_USE + 8 items)
weapon_detail_ptrs	equ	SELCT_BASE + (offset weapon_detail_ptrs_lbl)	;* weapon detail string pointer table (6 words)
shield_detail_ptrs	equ	SELCT_BASE + (offset shield_detail_ptrs_lbl)	;* magic detail string pointer table (6 words)
portrait_data_tbl	equ	0ADE8h			;* portrait rect data table (4 x 4 bytes: BX/CX pairs)
weapon_count		equ	0ADFAh			;* byte: number of available weapons
weapon_cursor		equ	0ADFBh			;* byte: current weapon selection cursor (0-based)
magic_count		equ	0ADFCh			;* byte: number of available magic spells
magic_cursor		equ	0ADFDh			;* byte: current magic selection cursor
item_count		equ	0ADFEh			;* byte: number of available items
item_cursor		equ	0ADFFh			;* byte: current item selection cursor
exit_queued		equ	0AE01h			;* byte: non-zero -> queue exit on next poll
portrait_vis		equ	0AE02h			;* byte: portrait box visible flag (0=hidden, FFh=shown)
weapon_idx_tbl		equ	0AE03h			;* 7-byte table: available weapon indices (1-based)
magic_idx_tbl		equ	0AE0Ah			;* 6-byte table: available magic indices (1-based)
item_idx_tbl		equ	0AE10h			;* 5-byte table: available item indices (1-based)
num_fmt_buf		equ	0AE16h			;* 7-byte scratch buffer for fmt_number output
weap_spr_base		equ	0E1Ah			;* weapon portrait sprite table base (8 bytes/entry)
magic_spr_base		equ	0E53h			;* magic portrait sprite table base (5 bytes/entry)
item_spr_base		equ	0E81h			;* item portrait sprite table base (5 bytes/entry)
joy_hold_threshold	equ	0286h			; joystick button hold count for item confirm (646 ticks)
item_use_dispatch_tbl	equ	0A452h			;* jump table: item_cursor-1 -> use handler (words, filled by caller)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
has_items_flag		equ	0ADF8h			;* byte: non-zero if character has usable items
cur_panel_idx		equ	0ADF9h			;* byte: current panel (0=weapon, 1=magic, 2=item)
item_sel_idx		equ	0AE00h			;* byte: item select confirm index

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
SELCT_BASE		equ	9FEEh			; game-segment load address of this module
magic_flags		equ	0A1h			;* 5-byte table: magic spell possession flags (at DS:0A1h)
item_flags		equ	0A6h			;* 5-byte table: item possession flags (at DS:0A6h)
weapon_flags		equ	0BBh			;* 7-byte table: weapon possession flags (1-based, at DS:0BBh)
equipped_weapon		equ	092h			;* byte: currently equipped weapon index (1-based, 0=none)
equipped_magic		equ	093h			;* byte: currently equipped magic index (1-based, 0=none)
player_HP			equ	090h			;* word: current character HP
player_hp_max		equ	0B2h			;* word: maximum character HP
player_exp		equ	094h			;* word: current character experience
player_exp_cap		equ	096h			;* word: experience cap for current level
player_speed		equ	098h			;* byte: character speed stat
player_power		equ	099h			;* byte: character power/attack stat
player_abilities		equ	09Ah			;* 3-byte table: combat ability flags (DS:09Ah..09Ch)
weap_dur_cur		equ	0ABh			;* 7-byte table: current weapon durability (DS:0ABh..0B1h)
weap_dur_max		equ	0B4h			;* 7-byte table: maximum weapon durability (DS:0B4h..0BAh)
key_count		equ	0E4h			;* byte: number of keys held
cur_weapon_idx		equ	09Dh			;* byte: cached selected weapon type index (1-based)
cur_magic_idx		equ	09Eh			;* byte: cached selected magic type index (1-based)
item_qty_count		equ	08Dh			;* byte: item count value shown in use-confirm box
item_effect_val		equ	08Eh			;* word: item effect value shown in use-confirm box
anim_param_buf		equ	0A584h			;* 2-byte animation parameter staging buffer
anim_spr_tbl		equ	0EB60h			;* sprite animation table (7 bytes/entry, 4 entries)
timer_wait_feather	equ	078h			; frame timer target for Kioku Feather save delay (120 frames)

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
						call	word ptr cs:drv_fill_rect
						pop	si
						pop	cx
						loop	draw_portraits_loop		; Loop if cx > 0

		call	draw_portrait_tabs
		push	cs
		pop	es
		mov	si,weapon_flags
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
		mov	si,magic_flags
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
		mov	byte ptr ds:cur_weapon_idx,al
		mov	bx,2711h
		mov	cx,1009h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fill_rect
		mov	bl,byte ptr ds:cur_weapon_idx
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:spell_name_ptrs[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 0C7h, 008h
		mov	al,byte ptr ds:cur_weapon_idx
		mov	bx,37A4h
		call	word ptr cs:drv_fn_15
		call	word ptr cs:drv_anim_step

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
		add	bx,weap_spr_base
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
		mov	byte ptr ds:cur_magic_idx,al
		mov	bx,1742h
		mov	cx,1611h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fill_rect
		mov	bl,byte ptr ds:cur_magic_idx
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:shoe_name_ptrs[bx]
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
		add	bx,magic_spr_base
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
										cmp	word ptr ds:gvar_timer_counter,joy_hold_threshold
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
		call	word ptr cs:drv_fill_rect
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
		add	bx,item_spr_base
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
		call	word ptr cs:drv_fill_rect
		mov	si,str_item_used_count
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 04Dh, 006h
		mov	al,byte ptr ds:item_qty_count
		xor	ah,ah			; Zero register
		inc	ax
		mov	cx,2
		mov	bl,6
		mov	dx,2C4Ch
		call	fmt_number
		mov	si,str_item_used_total
		mov	bx,80h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		db	00Ch			; was: db 0E8h, 02Fh, 006h
		mov	ax,word ptr ds:item_effect_val
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
		mov	bx,item_flags

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
; Inline item-use handler pointer table (8 entries).
; Caller copies these words to DS:item_use_dispatch_tbl before calling this module.
; Each entry is the game-segment address of the corresponding item handler.
		dw	0A462h		; item 0 (Kensh\ko Potion)  -> use_hp_potion
		dw	0A483h		; item 1 (Juu-en Fruit)     -> use_hp_full
		dw	0A496h		; item 2 (Elixir of Kashi)  -> use_weapon_restore
		dw	0A4BEh		; item 3 (Chikara Powder)   -> use_all_weapons_restore
		dw	0A52Ch		; item 4 (Sabre Oil)        -> use_sabre_oil
		dw	0A4EAh		; item 5 (Magia Stone)      -> use_magia_stone
		dw	0A4DBh		; item 6 (Holy Water)       -> use_holy_water
		dw	0A58Bh		; item 7 (Kioku Feather)    -> use_kioku_feather

use_hp_potion:				; item 0: restore 80 HP (caps at max)
		mov	byte ptr ds:gvar_volume_b,0Eh
		add	word ptr ds:player_HP,50h		; heal +80 HP
		mov	ax,word ptr ds:player_HP
		sub	ax,word ptr ds:player_hp_max
		jc	hp_potion_nocap
		mov	ax,word ptr ds:player_hp_max
		mov	word ptr ds:player_HP,ax		; cap at max HP

hp_potion_nocap:
		call	word ptr cs:drv_palette_push
		jmp	draw_item_detail_entry+1	;* off-by-one: skips call show_portrait_box

use_hp_full:				; item 1: restore HP to maximum
		mov	byte ptr ds:gvar_volume_b,0Eh
		mov	ax,word ptr ds:player_hp_max
		mov	word ptr ds:player_HP,ax
		call	word ptr cs:drv_palette_push
		jmp	draw_item_detail_entry+1	;* off-by-one: skips call show_portrait_box

use_weapon_restore:			; item 2: restore equipped weapon durability
		mov	byte ptr ds:gvar_volume_b,0Eh
		test	byte ptr ds:cur_weapon_idx,0FFh
		jnz	use_item_apply
		retn				; no weapon equipped -> no-op

use_item_apply:
		mov	bl,byte ptr ds:cur_weapon_idx
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:weap_dur_max[bx]
		mov	byte ptr ds:weap_dur_cur[bx],al
		call	word ptr cs:drv_anim_step
		call	draw_weapon_list
		jmp	draw_item_detail_entry

use_all_weapons_restore:		; item 3: restore all 7 weapon durabilities
		mov	byte ptr ds:gvar_volume_b,0Eh
		push	cs
		pop	es
		mov	si,weap_dur_max
		mov	di,weap_dur_cur
		mov	cx,7
		rep	movsb			; copy all 7 max values -> cur values
		call	word ptr cs:drv_anim_step
		call	draw_weapon_list
		jmp	draw_item_detail_entry

use_holy_water:				; item 6: add one key to key_count
		mov	byte ptr ds:gvar_volume_b,0Eh
		inc	byte ptr ds:key_count
		call	draw_key_count
		jmp	draw_item_detail_entry

use_magia_stone:			; item 5: grant experience based on equipped magic level
		mov	byte ptr ds:gvar_volume_b,0Eh
		test	byte ptr ds:equipped_magic,0FFh
		jnz	apply_item_exp			; Jump if not zero
		retn				; no magic equipped -> no-op

apply_item_exp:
		mov	bl,byte ptr ds:equipped_magic
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:item_effect_tbl[bx]
		add	word ptr ds:player_exp,ax
		mov	ax,word ptr ds:player_exp
		sub	ax,word ptr ds:player_exp_cap
		jc	cap_exp			; Jump if carry Set
		mov	ax,word ptr ds:player_exp_cap
		mov	word ptr ds:player_exp,ax

cap_exp:
		call	word ptr cs:drv_fn_13
		jmp	draw_item_detail_entry
; Padding between use_magia_stone and use_sabre_oil (dead bytes).
		db	50h, 00h, 1Ah, 64h, 00h, 6Eh, 00h, 73h, 00h, 78h, 00h

use_sabre_oil:				; item 4: animate Sabre Oil effect (4 sprite passes)
		push	cs
		pop	es
		mov	byte ptr ds:gvar_volume_b,0Eh
		mov	byte ptr ds:anim_param_buf,0		; anim_id = 0, dir = forward
		mov	byte ptr ds:anim_param_buf+1,1
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+0			; entry 0
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:anim_param_buf,4		; anim_id = 4, dir = backward
		mov	byte ptr ds:anim_param_buf+1,0FFh
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+7			; entry 1
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:anim_param_buf,8		; anim_id = 8
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+14			; entry 2
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:anim_param_buf,0Ch		; anim_id = 12, dir = forward
		mov	byte ptr ds:anim_param_buf+1,1
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+21			; entry 3
		mov	cx,7
		rep	movsb
		jmp	short draw_item_detail_entry
; Padding between use_sabre_oil and use_kioku_feather (dead bytes).
		db	00h, 00h, 50h, 00h, 00h, 00h, 00h

use_kioku_feather:			; item 7: use Kioku Feather (memory feather / save game)
		mov	byte ptr ds:gvar_volume_b,0Fh
		call	draw_item_detail_entry		; refresh item detail panel
		call	init_item_panel			; reset item panel display
		pop	ax				; discard push ax from item_use_action
		pop	ax				; discard push ax from item_use_action
		mov	byte ptr ds:gvar_display_mode,8
		mov	byte ptr ds:gvar_frame_timer,0		; reset frame timer

wait_timer_done:
						cmp	byte ptr ds:gvar_frame_timer,timer_wait_feather	; 'x'
						jb	wait_timer_done			; Jump if below
		call	word ptr cs:drv_return_to_caller
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		retn

init_item_panel		proc	near
		xor	al,al			; Zero register
		call	show_item_portrait
		mov	bx,item_spr_base+2
		mov	cx,1E10h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fill_rect
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
		call	word ptr cs:drv_fill_rect
		mov	si,str_item_detail_hdr
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
		mov	si,item_flags
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
		mov	bx,item_spr_base+2
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
		mov	bx,item_spr_base
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fill_rect
		mov	si,str_no_use_notice
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 067h, 003h

item_panel_empty:
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	si,str_empty
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
		mov	bx,magic_spr_base+2
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
		mov	al,byte ptr ds:cur_magic_idx
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
		add	cx,magic_spr_base
		mov	bx,cx
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bl,byte ptr ds:cur_magic_idx
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:shoe_name_ptrs[bx]
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
		mov	si,str_empty
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 0D9h, 002h

draw_char_stats:
		test	byte ptr ds:equipped_weapon,0FFh
		jz	draw_stat_93h			; Jump if zero
		mov	bx,174Dh
		mov	al,byte ptr ds:equipped_weapon
		call	word ptr cs:drv_fn_14
		mov	bl,byte ptr ds:equipped_weapon
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
		test	byte ptr ds:equipped_magic,0FFh
		jz	draw_stat_98h			; Jump if zero
		mov	bx,2E61h
		mov	al,byte ptr ds:equipped_magic
		call	word ptr cs:drv_fn_16
		mov	bl,byte ptr ds:equipped_magic
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:shield_detail_ptrs[bx]
		mov	bx,3461h
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		mov	bx,3469h
		xor	cl,cl			; Zero register
		call	word ptr cs:drv_fn_28
		call	draw_exp_bar

draw_stat_98h:
		test	byte ptr ds:player_speed,0FFh
		jz	draw_stat_99h			; Jump if zero
		mov	bx,2E75h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fn_29
		mov	bx,0C8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:drv_render_char
		mov	al,byte ptr ds:player_speed
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,347Eh
		call	fmt_number

draw_stat_99h:
		test	byte ptr ds:player_power,0FFh
		jz	draw_abilities			; Jump if zero
		mov	bx,3A75h
		mov	al,1
		call	word ptr cs:drv_fn_29
		mov	bx,0F8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:drv_render_char
		mov	al,byte ptr ds:player_power
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,407Eh
		call	fmt_number

draw_abilities:
		mov	si,player_abilities
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

draw_magic_panel		endp

draw_exp_bar		proc	near
		mov	ax,word ptr ds:player_exp_cap
		mov	dx,3469h
		mov	cx,3
		mov	bl,4
		call	fmt_number
		mov	bx,0CAh
		mov	cl,69h			; 'i'
		mov	al,28h			; '('
		mov	ah,4
		call	word ptr cs:drv_render_char
		mov	bx,0E0h
		mov	cl,69h			; 'i'
		mov	al,29h			; ')'
		mov	ah,4
		jmp	word ptr cs:drv_render_char

draw_exp_bar		endp

draw_key_count		proc	near
		test	byte ptr ds:key_count,0FFh
		jnz	draw_key_count_body			; Jump if not zero
		retn

draw_key_count_body:
		mov	bx,3257h
		mov	cx,408h
		xor	al,al			; Zero register
		call	word ptr cs:drv_fill_rect
		mov	bx,0CAh
		mov	cl,57h			; 'W'
		mov	al,28h			; '('
		mov	ah,1
		call	word ptr cs:drv_render_char
		mov	al,byte ptr ds:key_count
		xor	ah,ah			; Zero register
		mov	dx,3457h
		mov	bl,1
		mov	cx,1
		call	fmt_number
		mov	bx,0D4h
		mov	cl,57h			; 'W'
		mov	al,29h			; ')'
		mov	ah,1
		jmp	word ptr cs:drv_render_char

draw_key_count		endp

draw_weapon_panel		proc	near
		test	byte ptr ds:weapon_count,0FFh
		jz	weapon_panel_empty			; Jump if zero
		mov	cl,ds:weapon_count
		xor	ch,ch			; Zero register
		mov	bx,weap_spr_base+2
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
		mov	al,byte ptr ds:cur_weapon_idx
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
		add	cx,weap_spr_base
		mov	bx,cx
		mov	al,5
		call	word ptr cs:drv_fn_sprite
		mov	bl,byte ptr ds:cur_weapon_idx
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:spell_name_ptrs[bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string
		db	00Ch			; was: db 0E9h, 00Fh, 001h

weapon_panel_empty:
		mov	bx,9Eh
		mov	cl,12h
		mov	si,str_empty
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
						mov	al,byte ptr ds:weap_dur_cur[bx]
						mov	ah,byte ptr ds:weap_dur_max[bx]
						push	ax
						push	dx
						push	ax
						push	dx
						mov	bx,dx
						mov	cx,508h
						xor	al,al			; Zero register
						call	word ptr cs:drv_fill_rect
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
						call	word ptr cs:drv_render_char
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
						call	word ptr cs:drv_render_char
						pop	dx
						add	dx,800h
						pop	si
						pop	cx
						loop	draw_weapon_list_loop		; Loop if cx > 0

		retn

draw_weapon_panel		endp

fmt_number		proc	near
		push	bx
		push	dx
		push	cx
		xor	dl,dl			; Zero register
		mov	di,num_fmt_buf
		call	word ptr cs:drv_fn_num_fmt
		pop	cx
		mov	di,num_fmt_buf
		mov	al,7
		sub	al,cl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	ax
		pop	bx
		xor	bh,bh			; Zero register
		jmp	word ptr cs:drv_fn_render_bg

fmt_number		endp

draw_portrait_tabs		proc	near
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
						call	word ptr cs:drv_render_char
						pop	ax
						pop	cx
						pop	bx

scan_char_draw:
						push	bx
						push	cx
						push	ax
						call	word ptr cs:drv_render_char
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

draw_portrait_tabs		endp

check_joy_neutral		proc	near

check_joy_neutral_entry:
		test	word ptr ds:gvar_timer_counter,1
		stc				; Set carry flag
		jz	joy_has_dir			; Jump if zero
		retn

joy_has_dir:
		clc				; Clear carry flag
		retn

check_joy_neutral		endp

; ---- String table (module data section, game_seg:SELCT_BASE + file offset) ----

str_empty_lbl		label	word		; str_empty ?-- blank/empty panel placeholder
		db	'NOTHING', 0

str_no_use_notice_lbl	label	word		; str_no_use_notice ?-- "no item/magic" hint line
		db	'NO USE', 0
		db	00h				; padding

str_item_used_count_lbl	label	word		; str_item_used_count ?-- count row label
		db	'LEVEL', 0

str_item_used_total_lbl	label	word		; str_item_used_total ?-- total row label
		db	'EXP', 0

str_item_detail_hdr_lbl	label	word		; str_item_detail_hdr ?-- item-use header prefix
		db	'I have used', 0

spell_name_ptrs_lbl	label	word		; attack spell name pointer table (7 entries, 1-based index)
		dw	SELCT_BASE + (offset spell_str_espada)	; [1] Espada
		dw	SELCT_BASE + (offset spell_str_saeta)	; [2] Saeta
		dw	SELCT_BASE + (offset spell_str_fuego)	; [3] Fuego
		dw	SELCT_BASE + (offset spell_str_lanzar)	; [4] Lanzar
		dw	SELCT_BASE + (offset spell_str_rascar)	; [5] Rascar
		dw	SELCT_BASE + (offset spell_str_agua)	; [6] Agua
		dw	SELCT_BASE + (offset spell_str_guerra)	; [7] Guerra

spell_str_espada:	db	'Espada', 0

spell_str_saeta:	db	'Saeta', 0

spell_str_fuego:	db	'Fuego', 0

spell_str_lanzar:	db	'Lanzar', 0

spell_str_rascar:	db	'Rascar', 0

spell_str_agua:		db	'Agua', 0

spell_str_guerra:	db	'Guerra', 0

shoe_name_ptrs_lbl	label	word		; footwear/clothing item name pointer table (6 entries, 0=none)
		dw	SELCT_BASE + (offset str_no_use_notice_lbl)	; [0] no item equipped
		dw	SELCT_BASE + (offset shoe_str_feruza)		; [1] Feruza shoes
		dw	SELCT_BASE + (offset shoe_str_pirika)		; [2] Pirika shoes
		dw	SELCT_BASE + (offset shoe_str_silkarn)		; [3] Silkarn shoes
		dw	SELCT_BASE + (offset shoe_str_ruzeria)		; [4] Ruzeria shoes
		dw	SELCT_BASE + (offset shoe_str_asbestos)		; [5] Asbestos cape

shoe_str_feruza:	db	'Feruza', 0
			db	'      shoes', 0

shoe_str_pirika:	db	'Pirika', 0
			db	'      shoes', 0

shoe_str_silkarn:	db	'Silkarn', 0
			db	'      shoes', 0

shoe_str_ruzeria:	db	'Ruzeria', 0
			db	'      shoes', 0

shoe_str_asbestos:	db	'Asbestos', 0
			db	'       cape', 0

item_detail_ptrs_lbl	label	word		; item detail pointer table (8 entries, 1-based)
		dw	SELCT_BASE + (offset item_det_str_kenko)	; [1] Ken\ko Potion
		dw	SELCT_BASE + (offset item_det_str_juuen)	; [2] Juu-en Fruit
		dw	SELCT_BASE + (offset item_det_str_elixir)	; [3] Elixir of Kashi
		dw	SELCT_BASE + (offset item_det_str_chikara)	; [4] Chikara Powder
		dw	SELCT_BASE + (offset item_det_str_magia)	; [5] Magia Stone
		dw	SELCT_BASE + (offset item_det_str_holywater)	; [6] Holy Water of Acero
		dw	SELCT_BASE + (offset item_det_str_sabreoil)	; [7] Sabre Oil
		dw	SELCT_BASE + (offset item_det_str_kioku)	; [8] Kioku Feather

item_det_str_kenko:	db	'       a Ken\ko Potion.', 0

item_det_str_juuen:	db	'        a Juu-en Fruit.', 0

item_det_str_elixir:	db	'     a Elixir of Kashi.', 0

item_det_str_chikara:	db	'      a Chikara Powder.', 0

item_det_str_magia:	db	'         a Magia Stone.', 0

item_det_str_holywater:	db	' a Holy Water of Acero.', 0

item_det_str_sabreoil:	db	'           a Sabre Oil.', 0

item_det_str_kioku:	db	'       a Kioku Feather.', 0

item_name_ptrs_lbl	label	word		; item name pointer table (9 entries: [0]=no item, [1-8]=items)
		dw	SELCT_BASE + (offset str_no_use_notice_lbl)	; [0] no item equipped
		dw	SELCT_BASE + (offset item_str_kenko)		; [1] Ken\ko
		dw	SELCT_BASE + (offset item_str_juuen)		; [2] Juu-en
		dw	SELCT_BASE + (offset item_str_elixir)		; [3] Elixir
		dw	SELCT_BASE + (offset item_str_chikara)		; [4] Chikara
		dw	SELCT_BASE + (offset item_str_magia)		; [5] Magia Stone
		dw	SELCT_BASE + (offset item_str_holywater)	; [6] Holy Water
		dw	SELCT_BASE + (offset item_str_sabreoil)		; [7] Sabre Oil
		dw	SELCT_BASE + (offset item_str_kioku)		; [8] Kioku

item_str_kenko:		db	'Ken\ko', 0
			db	'      Potion', 0

item_str_juuen:		db	'Juu-en ', 0
			db	'       Fruit', 0

item_str_elixir:	db	'Elixir', 0
			db	'    of Kashi', 0

item_str_chikara:	db	'Chikara', 0
			db	'      Powder', 0

item_str_magia:		db	'Magia Stone'
			db	0, 0

item_str_holywater:	db	'Holy Water', 0
			db	'    of Acero', 0

item_str_sabreoil:	db	'Sabre Oil', 0
			db	0			; padding

item_str_kioku:		db	'Kioku', 0
			db	'     feather', 0

weapon_detail_ptrs_lbl	label	word		; weapon detail pointer table (6 entries, 1-based)
		dw	SELCT_BASE + (offset weap_det_str_training)	; [1] Training Sword
		dw	SELCT_BASE + (offset weap_det_str_wisemans)	; [2] Wise man's Sword
		dw	SELCT_BASE + (offset weap_det_str_spirit)	; [3] Spirit Sword
		dw	SELCT_BASE + (offset weap_det_str_knights)	; [4] Knight's Sword
		dw	SELCT_BASE + (offset weap_det_str_illumination)	; [5] Illumination Sword
		dw	SELCT_BASE + (offset weap_det_str_enchantment)	; [6] Enchantment Sword

weap_det_str_training:		db	'Training', 0
				db	'     Sword', 0

weap_det_str_wisemans:		db	'Wise man\s', 0
				db	'      Sword', 0

weap_det_str_spirit:		db	'Spirit', 0
				db	'    Sword', 0

weap_det_str_knights:		db	'Knight\s', 0
				db	'    Sword', 0

weap_det_str_illumination:	db	'Illumination', 0
				db	'       Sword', 0

weap_det_str_enchantment:	db	'Enchantment', 0
				db	'       Sword', 0

shield_detail_ptrs_lbl	label	word		; shield detail pointer table (6 entries, 1-based; "magic" slot holds the shield)
		dw	SELCT_BASE + (offset shield_det_str_clay)	; [1] Clay Shield
		dw	SELCT_BASE + (offset shield_det_str_wisemans)	; [2] Wise Man's Shield
		dw	SELCT_BASE + (offset shield_det_str_stone)	; [3] Stone Shield
		dw	SELCT_BASE + (offset shield_det_str_honor)	; [4] Honor Shield
		dw	SELCT_BASE + (offset shield_det_str_light)	; [5] Light Shield
		dw	SELCT_BASE + (offset shield_det_str_titanium)	; [6] Titanium Shield

shield_det_str_clay:		db	'Clay', 0
				db	'     Shield', 0

shield_det_str_wisemans:	db	'Wise Man\s', 0
				db	'      Shield', 0

shield_det_str_stone:		db	'Stone', 0
				db	'     Shield', 0

shield_det_str_honor:		db	'Honor', 0
				db	'     Shield', 0

shield_det_str_light:		db	'Light', 0
				db	'     Shield', 0

shield_det_str_titanium:	db	'Titanium', 0
				db	'      Shield', 0
		db	0Eh
		db	0Ch, '38?', 0Ch, '0"m', 0Ch, '0"?'
		db	'-^'
		db	17h
		db	37 dup (0)

seg_a		ends

		end	start
