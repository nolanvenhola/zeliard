
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
gvar_scene_mode	equ	0FF24h			; scene/mode indicator (save-state); 201SELCT writes 8 (was gvar_display_mode)
gvar_display_mode equ	0FF24h			; alias — earlier name

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
panel_dispatch_tbl	equ	0A0C4h			;* DBG: (offset panel_dispatch_tbl_lbl)
selct_param		equ	0A2B9h			;* DBG: (offset selct_param_lbl)
item_effect_tbl		equ	0A520h			;* DBG: (offset item_effect_tbl_lbl)
portrait_rect_tbl	equ	(offset portrait_rect_tbl_lbl)	;* = A9FCh (IMMED-only)
str_empty		equ	(offset str_empty_lbl)		;* blank panel text (empty/null string)
str_no_use_notice	equ	(offset str_no_use_notice_lbl)	;* item panel notice string (no-use hint)
str_item_used_count	equ	(offset str_item_used_count_lbl)	;* item-use box: count label
str_item_used_total	equ	(offset str_item_used_total_lbl)	;* item-use box: total label
str_item_detail_hdr	equ	(offset str_item_detail_hdr_lbl)	;* item detail header ("I have used...")
spell_name_ptrs	equ	(offset spell_name_ptrs_lbl)	;* weapon name string pointer table (7 words)
shoe_name_ptrs		equ	(offset shoe_name_ptrs_lbl)	;* magic name string pointer table (6 words)
item_detail_ptrs	equ	(offset item_detail_ptrs_lbl)	;* item detail string pointer table (8 words)
item_name_ptrs		equ	(offset item_name_ptrs_lbl)	;* item name string pointer table (9 words: NO_USE + 8 items)
spell_detail_ptrs	equ	(offset spell_detail_ptrs_lbl)	;* weapon detail string pointer table (6 words)
shield_detail_ptrs	equ	(offset shield_detail_ptrs_lbl)	;* magic detail string pointer table (6 words)
portrait_data_tbl	equ	(offset portrait_data_tbl_lbl)	;* = ADE8h (IMMED-only)
spell_count		equ	0ADFAh			;* DBG: (offset spell_count_lbl)
spell_cursor		equ	0ADFBh			;* DBG: (offset spell_cursor_lbl)
accessory_count		equ	0ADFCh			;* DBG: (offset accessory_count_lbl)
accessory_cursor		equ	0ADFDh			;* DBG: (offset accessory_cursor_lbl)
item_count		equ	0ADFEh			;* DBG: (offset item_count_lbl)
item_cursor		equ	0ADFFh			;* DBG: (offset item_cursor_lbl)
exit_queued		equ	0AE01h			;* DBG: (offset exit_queued_lbl)
portrait_vis		equ	0AE02h			;* DBG: (offset portrait_vis_lbl)
spell_idx_tbl		equ	(offset spell_idx_tbl_lbl)	;* = AE03h
accessory_idx_tbl		equ	(offset accessory_idx_tbl_lbl)	;* = AE0Ah
item_idx_tbl		equ	(offset item_idx_tbl_lbl)	;* = AE10h
num_fmt_buf		equ	(offset num_fmt_buf_lbl)	;* = AE16h
weap_spr_base		equ	0E1Ah			;* weapon portrait sprite table base (8 bytes/entry)
accessory_spr_base		equ	0E53h			;* magic portrait sprite table base (5 bytes/entry)
item_spr_base		equ	0E81h			;* item portrait sprite table base (5 bytes/entry)
joy_hold_threshold	equ	0286h			; joystick button hold count for item confirm (646 ticks)
item_use_dispatch_tbl	equ	0A452h			;* DBG: (offset item_use_dispatch_tbl_lbl)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
has_items_flag		equ	0ADF8h			;* DBG: (offset has_items_flag_lbl)
cur_panel_idx		equ	0ADF9h			;* DBG: (offset cur_panel_idx_lbl)
item_sel_idx		equ	0AE00h			;* DBG: (offset item_sel_idx_lbl)

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
SELCT_BASE		equ	9FFCh			; game-segment load address of this module
; 0xA1..0xA5: 5-byte WEARABLE-acquisition slot array (TCRF authoritative;
; earlier "accessory_slot" was a misnomer — these are shoes/cape, NOT magic).
; 0xA6..0xAA: 5-byte item inventory slots (TCRF: item_slot_1..5).
; 0xBB..0xC1: 7 per-spell "learned" flags (TCRF: spell_known_*).
accessory_slot		equ	0A1h			; 5-byte wearable acquisition slots (0xA1..0xA5)
item_slot		equ	0A6h			; 5-byte item inventory slots (0xA6..0xAA)
spell_known		equ	0BBh			; 7-byte spell-learned flag array (0xBB..0xC1)
magic_flags		equ	0A1h			; alias — earlier (wrong) name
item_flags		equ	0A6h			; alias — generic-enough that this name still works
weapon_flags		equ	0BBh			; alias — earlier (wrong) name
sword		equ	092h			;* byte: currently equipped weapon index (1-based, 0=none)
				; * shield tier (1-based, 0=no shield).  Used by use_magia_stone as item_effect_tbl index for shield repair amount
shield		equ	093h
player_HP			equ	090h			;* word: current character HP
player_hp_max		equ	0B2h			;* word: maximum character HP
shield_HP		equ	094h			;* current shield HP (16-bit); use_magia_stone adds repair amount, capped at shield_max_HP
shield_max_HP		equ	096h			;* shield max HP cap (16-bit); use_magia_stone clamps shield_HP to this
keys_normal		equ	098h			; normal key count (TCRF authoritative; was misnamed "player_speed" / "char_speed")
player_speed		equ	098h			; alias — earlier (wrong) name
player_power		equ	099h			;* byte: character power/attack stat
				; canonical names player_ability_1/2/3 in stdply.inc)
player_abilities		equ	09Ah			;* base of 3-byte ability table (slots at 9A/9B/9C
; 0xAB..0xB1: 7 spell-charge bytes (TCRF: spell_charge_espada..guerra).
; 0xB4..0xBA: 7 spell-charge-max bytes.  Earlier "weap_dur_*" was a
; misnomer — these are SPELL charges, not weapon durability.
spell_charge		equ	0ABh			; base of 7-byte spell-charge array (current)
spell_charge_max	equ	0B4h			; base of 7-byte spell-charge-max array
weap_dur_cur		equ	0ABh			; alias — earlier (wrong) name
weap_dur_max		equ	0B4h			; alias — earlier (wrong) name
key_count		equ	0E4h			;* byte: number of keys held
; 0x9D in this chunk is the SELECTED SPELL (TCRF: selected_spell).  Earlier
; "cur_weapon_idx" name was a misread — 0x9D drives spell-cast dispatch
; (entity_fn_tbl_d) + indexes spell_charge_* array; it has nothing to do
; with the equipped sword (equipped_weapon is at 0x92).  Kept as alias.
selected_spell		equ	09Dh			; currently chosen spell ID (0=none, 1..7)
cur_weapon_idx		equ	09Dh			; alias — earlier (wrong) name
; 0x9E in this chunk is the SELECTED WEARABLE (TCRF: selected_accessory).
; Earlier "cur_magic_idx" name was a misread — 0x9E is the equipped
; shoe/cape ID (1=Feruza, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=Cape).
; Drives per-area damage immunity gates in 200FIGHT (Ruzeria stops ice
; slide, Cape stops Pureza acid, etc.).
selected_accessory	equ	09Eh			; currently equipped wearable ID (0..5)
cur_magic_idx		equ	09Eh			; alias — earlier (wrong) name
item_qty_count		equ	08Dh			;* byte: item count value shown in use-confirm box
item_effect_val		equ	08Eh			;* word: item effect value shown in use-confirm box
anim_param_buf		equ	0A584h			;* DBG: (offset anim_param_buf_lbl)
anim_spr_tbl		equ	0EB60h			;* sprite animation table (7 bytes/entry, 4 entries)
timer_wait_feather	equ	078h			; frame timer target for Kioku Feather save delay (120 frames)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	9FFCh			; 201SELCT loads at CS:0x9FFC (SELCT_BASE)

run_selct_main		proc	far

start:
		sbb	ax,0Eh
		add	[si],al
		mov	al,ds:[gvar_selct_state]
		mov	byte ptr ds:[has_items_flag],0
		jmp	short init_continue
		db	0C6h, 06h,0F8h,0ADh,0FFh	; mis-decoded `mov byte ptr [0ADF8h],0FFh` opcode bytes (5 bytes, dead path)

init_continue:
		mov	byte ptr ds:[portrait_vis],0
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
						call	word ptr cs:[drv_fill_rect]
						pop	si
						pop	cx
						loop	draw_portraits_loop		; Loop if cx > 0

		call	draw_portrait_tabs
		push	cs
		pop	es
		mov	si,spell_known
		mov	di,spell_idx_tbl
		xor	cl,cl			; Zero register
		mov	ch,1

scan_spell_known:
						lodsb				; String [si] to al
						or	al,al			; Zero ?
						jz	scan_weapon_next			; Jump if zero
						mov	al,ch
						stosb				; Store al to es:[di]
						inc	cl

scan_weapon_next:
						inc	ch
						cmp	ch,8
						jne	scan_spell_known			; Jump if not equal
		mov	ds:[spell_count],cl
		mov	si,accessory_slot
		mov	di,accessory_idx_tbl
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
		mov	ds:[accessory_count],cl
		call	rebuild_item_idx
		call	draw_spell_panel
		call	draw_accessory_panel
		call	draw_item_panel
		call	draw_char_stats
		call	poll_input
		sbb	al,al
		mov	ds:[exit_queued],al
		xor	cl,cl			; Zero register
		test	byte ptr ds:[spell_count],0FFh
		jnz	set_panel			; Jump if not zero
		inc	cl
		test	byte ptr ds:[accessory_count],0FFh
		jnz	set_panel			; Jump if not zero
		test	byte ptr ds:[has_items_flag],0FFh
		jnz	wait_confirm_loop			; Jump if not zero
		inc	cl
		test	byte ptr ds:[item_count],0FFh
		jnz	set_panel			; Jump if not zero

wait_confirm_loop:
						call	poll_input
						jnc	wait_confirm_loop			; Jump if carry=0
		retn

set_panel:
		mov	ds:[cur_panel_idx],cl

panel_dispatch:
		mov	bl,ds:[cur_panel_idx]
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[panel_dispatch_tbl][bx]	;*
			                        ;* No entry point to code
panel_dispatch_tbl_lbl:
		retf	0BBA0h
			                        ;* No entry point to code
		mov	ax,ds:[selct_param]
selct_param_lbl:
		call	draw_portrait_tabs
		mov	al,2
		call	show_weapon_portrait

wait_joy_neutral:
						int	61h			; ??INT Non-standard interrupt
						and	al,3
						jnz	wait_joy_neutral			; Jump if not zero

spell_input_loop:
										call	poll_input
										jnc	spell_poll_input			; Jump if carry=0
										retn

spell_poll_input:
										int	61h			; ??INT Non-standard interrupt
										and	al,0Eh
										jz	spell_input_loop			; Jump if zero
										and	al,0Ch
										jnz	spell_joy_down			; Jump if not zero
										jmp	spell_confirm

spell_joy_down:
										test	al,4
										jnz	spell_joy_up			; Jump if not zero
										mov	al,ds:[spell_cursor]
										inc	al
										mov	ah,ds:[spell_count]
										dec	ah
										cmp	ah,al
										jb	spell_input_loop			; Jump if below
										xor	al,al			; Zero register
										call	show_weapon_portrait
										inc	byte ptr ds:[spell_cursor]
										mov	al,2
										call	show_weapon_portrait
										mov	byte ptr ds:[gvar_volume_b],0Ch
										call	draw_spell_cursor
										jmp	short spell_input_loop

spell_joy_up:
										test	byte ptr ds:[spell_cursor],0FFh
										jz	spell_input_loop			; Jump if zero
						xor	al,al			; Zero register
						call	show_weapon_portrait
						dec	byte ptr ds:[spell_cursor]
						mov	al,2
						call	show_weapon_portrait
						mov	byte ptr ds:[gvar_volume_b],0Ch
						call	draw_spell_cursor
						jmp	short spell_input_loop

run_selct_main		endp

draw_spell_cursor		proc	near
		mov	bx,spell_idx_tbl
		mov	al,ds:[spell_cursor]
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[selected_spell],al
		mov	bx,2711h
		mov	cx,1009h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	bl,byte ptr ds:[selected_spell]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[spell_name_ptrs][bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	al,byte ptr ds:[selected_spell]
		mov	bx,37A4h
		call	word ptr cs:[drv_fn_15]
		call	word ptr cs:[drv_anim_step]

wait_joy_clear_weapon:
						int	61h			; ??INT Non-standard interrupt
						and	al,0Ch
						jnz	wait_joy_clear_weapon			; Jump if not zero
		retn

draw_spell_cursor		endp

show_weapon_portrait		proc	near
		mov	bh,ds:[spell_cursor]
		xor	bl,bl			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,weap_spr_base
		jmp	word ptr cs:[drv_fn_sprite]

show_weapon_portrait		endp

spell_confirm:
		mov	cl,1
		test	byte ptr ds:[accessory_count],0FFh
		jnz	spell_switch_panel			; Jump if not zero
		test	byte ptr ds:[has_items_flag],0FFh
		mov	cl,2
		test	byte ptr ds:[item_count],0FFh
		jnz	spell_switch_panel			; Jump if not zero
		jmp	spell_input_loop

spell_switch_panel:
		mov	byte ptr ds:[gvar_volume_b],0Dh
		mov	ds:[cur_panel_idx],cl
		mov	al,5
		call	show_weapon_portrait
		jmp	panel_dispatch
			                        ;* No entry point to code
		call	draw_portrait_tabs
		mov	al,2
		call	show_accessory_portrait

accessory_wait_neutral:
						int	61h			; ??INT Non-standard interrupt
						and	al,3
						jnz	accessory_wait_neutral			; Jump if not zero

accessory_input_loop:
										call	poll_input
										jnc	accessory_poll_input			; Jump if carry=0
										retn

accessory_poll_input:
										int	61h			; ??INT Non-standard interrupt
										and	al,0Fh
										jz	accessory_input_loop			; Jump if zero
										mov	ah,al
										and	al,0Ch
										jnz	accessory_joy_down_chk			; Jump if not zero
										jmp	accessory_check_confirm

accessory_joy_down_chk:
										test	al,4
										jnz	accessory_joy_up			; Jump if not zero
										mov	al,ds:[accessory_cursor]
										inc	al
										mov	ah,ds:[accessory_count]
										dec	ah
										cmp	ah,al
										jb	accessory_input_loop			; Jump if below
										xor	al,al			; Zero register
										call	show_accessory_portrait
										inc	byte ptr ds:[accessory_cursor]
										mov	al,2
										call	show_accessory_portrait
										mov	byte ptr ds:[gvar_volume_b],0Ch
										call	draw_accessory_cursor
										jmp	short accessory_input_loop

accessory_joy_up:
										test	byte ptr ds:[accessory_cursor],0FFh
										jz	accessory_input_loop			; Jump if zero
						xor	al,al			; Zero register
						call	show_accessory_portrait
						dec	byte ptr ds:[accessory_cursor]
						mov	al,2
						call	show_accessory_portrait
						mov	byte ptr ds:[gvar_volume_b],0Ch
						call	draw_accessory_cursor
						jmp	short accessory_input_loop

draw_accessory_cursor		proc	near
		mov	bx,accessory_idx_tbl
		mov	al,ds:[accessory_cursor]
		xlat				; al=[al+[bx]] table
		mov	byte ptr ds:[selected_accessory],al
		mov	bx,1742h
		mov	cx,1611h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	bl,byte ptr ds:[selected_accessory]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[shoe_name_ptrs][bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string

wait_joy_clear_magic:
						int	61h			; ??INT Non-standard interrupt
						and	al,0Ch
						jnz	wait_joy_clear_magic			; Jump if not zero
		retn

draw_accessory_cursor		endp

show_accessory_portrait		proc	near
		mov	bh,ds:[accessory_cursor]
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,accessory_spr_base
		jmp	word ptr cs:[drv_fn_sprite]

show_accessory_portrait		endp

accessory_check_confirm:
		test	ah,1
		jz	magic_confirm_chk2			; Jump if zero
		test	byte ptr ds:[spell_count],0FFh
		jnz	accessory_select_spell_tab			; Jump if not zero
		jmp	accessory_input_loop

accessory_select_spell_tab:
		mov	byte ptr ds:[cur_panel_idx],0
		jmp	short accessory_switch_panel

magic_confirm_chk2:
		test	byte ptr ds:[has_items_flag],0FFh
		jz	magic_confirm_chk3			; Jump if zero
		jmp	accessory_input_loop

magic_confirm_chk3:
		test	byte ptr ds:[item_count],0FFh
		jnz	accessory_select_item_tab			; Jump if not zero
		jmp	accessory_input_loop

accessory_select_item_tab:
		mov	byte ptr ds:[cur_panel_idx],2

accessory_switch_panel:
		mov	byte ptr ds:[gvar_volume_b],0Dh
		mov	al,5
		call	show_accessory_portrait
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
										cmp	word ptr ds:[gvar_timer_counter],joy_hold_threshold
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
										mov	al,ds:[item_sel_idx]
										inc	al
										mov	ah,ds:[item_count]
										dec	ah
										cmp	ah,al
										jb	item_input_loop			; Jump if below
										xor	al,al			; Zero register
										call	show_item_portrait
										inc	byte ptr ds:[item_sel_idx]
										mov	al,2
										call	show_item_portrait
										mov	byte ptr ds:[gvar_volume_b],0Ch
										call	draw_item_cursor
										jmp	short item_input_loop

item_joy_up:
										test	byte ptr ds:[item_sel_idx],0FFh
										jz	item_input_loop			; Jump if zero
						xor	al,al			; Zero register
						call	show_item_portrait
						dec	byte ptr ds:[item_sel_idx]
						mov	al,2
						call	show_item_portrait
						mov	byte ptr ds:[gvar_volume_b],0Ch
						call	draw_item_cursor
						jmp	short item_input_loop

draw_item_cursor		proc	near
		mov	bx,item_idx_tbl
		mov	al,ds:[item_sel_idx]
		xlat				; al=[al+[bx]] table
		mov	ds:[item_cursor],al
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	bl,ds:[item_cursor]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[item_name_ptrs][bx]
		mov	bx,54h
		mov	cl,70h			; 'p'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	bx,54h
		mov	cl,78h			; 'x'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string

wait_joy_clear_item:
						int	61h			; ??INT Non-standard interrupt
						and	al,0Ch
						jnz	wait_joy_clear_item			; Jump if not zero
		retn

draw_item_cursor		endp

show_item_portrait		proc	near

show_item_portrait_entry:
		mov	bh,ds:[item_sel_idx]
		xor	bl,bl			; Zero register
		mov	cx,bx
		add	bx,bx
		add	bx,bx
		add	bx,cx
		add	bx,item_spr_base
		jmp	word ptr cs:[drv_fn_sprite]

show_item_portrait		endp

item_check_tab:
		mov	cl,1
		test	byte ptr ds:[accessory_count],0FFh
		jnz	item_switch_panel			; Jump if not zero
		xor	cl,cl			; Zero register
		test	byte ptr ds:[spell_count],0FFh
		jnz	item_switch_panel			; Jump if not zero
		jmp	item_input_loop

item_switch_panel:
		mov	ds:[cur_panel_idx],cl
		mov	byte ptr ds:[gvar_volume_b],0Dh
		mov	al,5
		call	show_item_portrait
		jmp	panel_dispatch

item_confirm_chk:
		test	byte ptr ds:[portrait_vis],0FFh
		jz	item_use_entry			; Jump if zero
		jmp	item_input_loop

item_use_entry:
		call	show_portrait_box
		mov	bx,1B43h
		mov	cx,1A24h
		mov	al,0FFh
		call	word ptr cs:[drv_fill_rect]
		mov	si,str_item_used_count
		mov	bx,80h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	al,byte ptr ds:[item_qty_count]
		xor	ah,ah			; Zero register
		inc	ax
		mov	cx,2
		mov	bl,6
		mov	dx,2C4Ch
		call	format_number
		mov	si,str_item_used_total
		mov	bx,80h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	ax,word ptr ds:[item_effect_val]
		mov	cx,5
		mov	bl,6
		mov	dx,2856h
		call	format_number
		jmp	item_input_loop

item_button_select:
		test	byte ptr ds:[item_cursor],0FFh
		jnz	item_use_action			; Jump if not zero
		jmp	item_input_loop

item_use_action:
		call	hide_portrait_box
		mov	ax,0A2C7h
		push	ax
		mov	ax,0A5B4h
		push	ax
		mov	cl,ds:[item_sel_idx]
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
		mov	al,ds:[item_cursor]
		mov	ds:[gvar_item_result],al
		mov	bl,ds:[item_cursor]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[item_use_dispatch_tbl][bx]	;*
; Inline item-use handler pointer table (8 entries).
; Caller copies these words to DS:item_use_dispatch_tbl before calling this module.
; Each entry is the game-segment address of the corresponding item handler.
item_use_dispatch_tbl_lbl:
		dw	0A462h		; item 0 (Kensh\ko Potion)  -> use_hp_potion
		dw	0A483h		; item 1 (Juu-en Fruit)     -> use_hp_full
		dw	0A496h		; item 2 (Elixir of Kashi)  -> use_weapon_restore
		dw	0A4BEh		; item 3 (Chikara Powder)   -> use_all_weapons_restore
		dw	0A52Ch		; item 4 (Sabre Oil)        -> use_sabre_oil
		dw	0A4EAh		; item 5 (Magia Stone)      -> use_magia_stone
		dw	0A4DBh		; item 6 (Holy Water)       -> use_holy_water
		dw	0A58Bh		; item 7 (Kioku Feather)    -> use_kioku_feather

use_hp_potion:				; item 0: restore 80 HP (caps at max)
		mov	byte ptr ds:[gvar_volume_b],0Eh
		add	word ptr ds:[player_HP],50h		; heal +80 HP
		mov	ax,word ptr ds:[player_HP]
		sub	ax,word ptr ds:[player_hp_max]
		jc	hp_potion_nocap
		mov	ax,word ptr ds:[player_hp_max]
		mov	word ptr ds:[player_HP],ax		; cap at max HP

hp_potion_nocap:
		call	word ptr cs:[drv_palette_push]
		jmp	draw_item_detail_entry

use_hp_full:				; item 1: restore HP to maximum
		mov	byte ptr ds:[gvar_volume_b],0Eh
		mov	ax,word ptr ds:[player_hp_max]
		mov	word ptr ds:[player_HP],ax
		call	word ptr cs:[drv_palette_push]
		jmp	draw_item_detail_entry

use_weapon_restore:			; item 2: restore equipped weapon durability
		mov	byte ptr ds:[gvar_volume_b],0Eh
		test	byte ptr ds:[selected_spell],0FFh
		jnz	use_item_apply
		retn				; no weapon equipped -> no-op

use_item_apply:
		mov	bl,byte ptr ds:[selected_spell]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[spell_charge_max][bx]
		mov	byte ptr ds:[spell_charge][bx],al
		call	word ptr cs:[drv_anim_step]
		call	draw_spell_list
		jmp	draw_item_detail_entry

use_all_weapons_restore:		; item 3: restore all 7 weapon durabilities
		mov	byte ptr ds:[gvar_volume_b],0Eh
		push	cs
		pop	es
		mov	si,spell_charge_max
		mov	di,spell_charge
		mov	cx,7
		rep	movsb			; copy all 7 max values -> cur values
		call	word ptr cs:[drv_anim_step]
		call	draw_spell_list
		jmp	draw_item_detail_entry

use_holy_water:				; item 6: add one key to key_count
		mov	byte ptr ds:[gvar_volume_b],0Eh
		inc	byte ptr ds:[key_count]
		call	draw_key_count
		jmp	draw_item_detail_entry

use_magia_stone:			; item 5: grant experience based on equipped magic level
		mov	byte ptr ds:[gvar_volume_b],0Eh
		test	byte ptr ds:[shield],0FFh
		jnz	apply_item_exp			; Jump if not zero
		retn				; no magic equipped -> no-op

apply_item_exp:
		mov	bl,byte ptr ds:[shield]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:[item_effect_tbl][bx]
		add	word ptr ds:[shield_HP],ax
		mov	ax,word ptr ds:[shield_HP]
		sub	ax,word ptr ds:[shield_max_HP]
		jc	cap_exp			; Jump if carry Set
		mov	ax,word ptr ds:[shield_max_HP]
		mov	word ptr ds:[shield_HP],ax

cap_exp:
		call	word ptr cs:[drv_fn_13]
		jmp	draw_item_detail_entry
; Word offset table between use_magia_stone and use_sabre_oil
; (Sourcer mis-decoded the high byte of the second entry).
item_effect_tbl_lbl:
		db	50h, 00h, 5Ah, 00h, 64h, 00h, 6Eh, 00h, 73h, 00h, 78h, 00h	; word offset tbl: 50h, 5Ah, 64h, 6Eh, 73h, 78h

use_sabre_oil:				; item 4: animate Sabre Oil effect (4 sprite passes)
		push	cs
		pop	es
		mov	byte ptr ds:[gvar_volume_b],0Eh
		mov	byte ptr ds:[anim_param_buf],0		; anim_id = 0, dir = forward
		mov	byte ptr ds:[anim_param_buf]+1,1
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+0			; entry 0
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:[anim_param_buf],4		; anim_id = 4, dir = backward
		mov	byte ptr ds:[anim_param_buf]+1,0FFh
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+7			; entry 1
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:[anim_param_buf],8		; anim_id = 8
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+14			; entry 2
		mov	cx,7
		rep	movsb
		mov	byte ptr ds:[anim_param_buf],0Ch		; anim_id = 12, dir = forward
		mov	byte ptr ds:[anim_param_buf]+1,1
		mov	si,anim_param_buf
		mov	di,anim_spr_tbl+21			; entry 3
		mov	cx,7
		rep	movsb
		jmp	short draw_item_detail_entry
; Padding between use_sabre_oil and use_kioku_feather (dead bytes).
anim_param_buf_lbl:
		db	00h, 00h, 50h, 00h, 00h, 00h, 00h	; padding bytes (7 dead bytes)

use_kioku_feather:			; item 7: use Kioku Feather (memory feather / save game)
		mov	byte ptr ds:[gvar_volume_b],0Fh
		call	draw_item_detail_entry		; refresh item detail panel
		call	init_item_panel			; reset item panel display
		pop	ax				; discard push ax from item_use_action
		pop	ax				; discard push ax from item_use_action
		mov	byte ptr ds:[gvar_scene_mode],8
		mov	byte ptr ds:[gvar_frame_timer],0		; reset frame timer

wait_timer_done:
						cmp	byte ptr ds:[gvar_frame_timer],timer_wait_feather	; 'x'
						jb	wait_timer_done			; Jump if below
		call	word ptr cs:[drv_return_to_caller]
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		retn

init_item_panel		proc	near
		xor	al,al			; Zero register
		call	show_item_portrait
		mov	bx,item_spr_base+2
		mov	cx,1E10h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		test	byte ptr ds:[item_count],0FFh
		jnz	check_item_present			; Jump if not zero
		mov	byte ptr ds:[item_count],1

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
		call	word ptr cs:[drv_fill_rect]
		mov	si,str_item_detail_hdr
		mov	bx,44h
		mov	cl,4Ch			; 'L'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	bl,ds:[item_cursor]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[item_detail_ptrs][bx]
		mov	bx,48h
		mov	cl,56h			; 'V'
		mov	ah,1
;*		jmp	init_panels6			;*

draw_item_detail		endp

		jmp	scan_draw_string

show_portrait_box		proc	near
		test	byte ptr ds:[portrait_vis],0FFh
		jz	portrait_box_draw			; Jump if zero
		retn

portrait_box_draw:
		mov	byte ptr ds:[portrait_vis],0FFh
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:[drv_fn_19]

show_portrait_box		endp

hide_portrait_box		proc	near
		test	byte ptr ds:[portrait_vis],0FFh
		jnz	portrait_box_hide			; Jump if not zero
		retn

portrait_box_hide:
		mov	byte ptr ds:[portrait_vis],0
		mov	ax,643h
		xor	di,di			; Zero register
		mov	cx,1C24h
		jmp	word ptr cs:[drv_fn_20]

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
		mov	ds:[item_count],cl
		retn

rebuild_item_idx		endp

draw_item_panel		proc	near
		test	byte ptr ds:[item_count],0FFh
		jz	item_panel_empty			; Jump if zero
		mov	cl,ds:[item_count]
		xor	ch,ch			; Zero register
		mov	bx,item_spr_base+2
		mov	si,item_idx_tbl

draw_item_panel_loop:
						push	cx
						lodsb				; String [si] to al
						push	si
						push	bx
						call	word ptr cs:[drv_fn_27]
						pop	bx
						pop	si
						add	bx,500h
						pop	cx
						loop	draw_item_panel_loop		; Loop if cx > 0

		mov	byte ptr ds:[item_cursor],0
		mov	byte ptr ds:[item_sel_idx],0
		test	byte ptr ds:[has_items_flag],0FFh
		jz	item_panel_has_items			; Jump if zero
		retn

item_panel_has_items:
		mov	bx,item_spr_base
		mov	al,5
		call	word ptr cs:[drv_fn_sprite]
		mov	bx,1570h
		mov	cx,1811h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	si,str_no_use_notice
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string

item_panel_empty:
		mov	bx,54h
		mov	cl,71h			; 'q'
		mov	si,str_empty
		mov	ah,1
;*		jmp	init_panels6			;*

draw_item_panel		endp

		jmp	scan_draw_string

draw_accessory_panel		proc	near
		test	byte ptr ds:[accessory_count],0FFh
		jz	accessory_panel_empty			; Jump if zero
		mov	cl,ds:[accessory_count]
		xor	ch,ch			; Zero register
		mov	bx,accessory_spr_base+2
		mov	si,accessory_idx_tbl

draw_accessory_panel_loop:
						push	cx
						lodsb				; String [si] to al
						push	si
						push	bx
						call	word ptr cs:[drv_fn_26]
						pop	bx
						pop	si
						add	bx,500h
						pop	cx
						loop	draw_accessory_panel_loop		; Loop if cx > 0

		push	cs
		pop	es
		mov	di,accessory_idx_tbl
		mov	al,byte ptr ds:[selected_accessory]
		mov	cx,6
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,5
		mov	ds:[accessory_cursor],cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		mov	bx,cx
		add	cx,cx
		add	cx,cx
		add	cx,bx
		add	cx,accessory_spr_base
		mov	bx,cx
		mov	al,5
		call	word ptr cs:[drv_fn_sprite]
		mov	bl,byte ptr ds:[selected_accessory]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[shoe_name_ptrs][bx]
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	ah,1
;*		call	draw_portrait_tabs_fn21			;*
		call	scan_draw_string
		mov	bx,5Ch
		mov	cl,4Bh			; 'K'
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string

accessory_panel_empty:
		mov	bx,5Ch
		mov	cl,43h			; 'C'
		mov	si,str_empty
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string

draw_char_stats:
		test	byte ptr ds:[sword],0FFh
		jz	draw_stat_93h			; Jump if zero
		mov	bx,174Dh
		mov	al,byte ptr ds:[sword]
		call	word ptr cs:[drv_fn_14]
		mov	bl,byte ptr ds:[sword]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:[spell_detail_ptrs][bx]
		mov	bx,344Eh
		xor	cl,cl			; Zero register
		call	word ptr cs:[drv_fn_28]
		mov	bx,3456h
		xor	cl,cl			; Zero register
		call	word ptr cs:[drv_fn_28]
		call	draw_key_count

draw_stat_93h:
		test	byte ptr ds:[shield],0FFh
		jz	draw_stat_98h			; Jump if zero
		mov	bx,2E61h
		mov	al,byte ptr ds:[shield]
		call	word ptr cs:[drv_fn_16]
		mov	bl,byte ptr ds:[shield]
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	si,ds:[shield_detail_ptrs][bx]
		mov	bx,3461h
		xor	cl,cl			; Zero register
		call	word ptr cs:[drv_fn_28]
		mov	bx,3469h
		xor	cl,cl			; Zero register
		call	word ptr cs:[drv_fn_28]
		call	draw_exp_bar

draw_stat_98h:
		test	byte ptr ds:[keys_normal],0FFh
		jz	draw_stat_99h			; Jump if zero
		mov	bx,2E75h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fn_29]
		mov	bx,0C8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:[drv_render_char]
		mov	al,byte ptr ds:[keys_normal]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,347Eh
		call	format_number

draw_stat_99h:
		test	byte ptr ds:[player_power],0FFh
		jz	draw_abilities			; Jump if zero
		mov	bx,3A75h
		mov	al,1
		call	word ptr cs:[drv_fn_29]
		mov	bx,0F8h
		mov	cl,7Eh			; '~'
		mov	al,5Eh			; '^'
		mov	ah,1
		call	word ptr cs:[drv_render_char]
		mov	al,byte ptr ds:[player_power]
		xor	ah,ah			; Zero register
		mov	cx,1
		mov	bl,1
		mov	dx,407Eh
		call	format_number

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
						call	word ptr cs:[drv_fn_30]
						pop	si
						pop	bx
						add	bx,600h

ability_row_skip:
						pop	cx
						loop	draw_ability_loop		; Loop if cx > 0

		retn

draw_accessory_panel		endp

draw_exp_bar		proc	near
		mov	ax,word ptr ds:[shield_max_HP]
		mov	dx,3469h
		mov	cx,3
		mov	bl,4
		call	format_number
		mov	bx,0CAh
		mov	cl,69h			; 'i'
		mov	al,28h			; '('
		mov	ah,4
		call	word ptr cs:[drv_render_char]
		mov	bx,0E0h
		mov	cl,69h			; 'i'
		mov	al,29h			; ')'
		mov	ah,4
		jmp	word ptr cs:[drv_render_char]

draw_exp_bar		endp

draw_key_count		proc	near
		test	byte ptr ds:[key_count],0FFh
		jnz	draw_key_count_body			; Jump if not zero
		retn

draw_key_count_body:
		mov	bx,3257h
		mov	cx,408h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	bx,0CAh
		mov	cl,57h			; 'W'
		mov	al,28h			; '('
		mov	ah,1
		call	word ptr cs:[drv_render_char]
		mov	al,byte ptr ds:[key_count]
		xor	ah,ah			; Zero register
		mov	dx,3457h
		mov	bl,1
		mov	cx,1
		call	format_number
		mov	bx,0D4h
		mov	cl,57h			; 'W'
		mov	al,29h			; ')'
		mov	ah,1
		jmp	word ptr cs:[drv_render_char]

draw_key_count		endp

draw_spell_panel		proc	near
		test	byte ptr ds:[spell_count],0FFh
		jz	spell_panel_empty			; Jump if zero
		mov	cl,ds:[spell_count]
		xor	ch,ch			; Zero register
		mov	bx,weap_spr_base+2
		mov	si,spell_idx_tbl

draw_spell_panel_loop:
						push	cx
						lodsb				; String [si] to al
						push	si
						push	bx
						call	word ptr cs:[drv_fn_15]
						pop	bx
						pop	si
						add	bx,800h
						pop	cx
						loop	draw_spell_panel_loop		; Loop if cx > 0

		call	draw_spell_list
		push	cs
		pop	es
		mov	di,spell_idx_tbl
		mov	al,byte ptr ds:[selected_spell]
		mov	cx,7
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		neg	cx
		add	cx,6
		mov	ds:[spell_cursor],cl
		mov	ch,cl
		xor	cl,cl			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,weap_spr_base
		mov	bx,cx
		mov	al,5
		call	word ptr cs:[drv_fn_sprite]
		mov	bl,byte ptr ds:[selected_spell]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[spell_name_ptrs][bx]
		mov	bx,9Eh
		mov	cl,12h
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string

spell_panel_empty:
		mov	bx,9Eh
		mov	cl,12h
		mov	si,str_empty
		mov	ah,1
;*		jmp	init_panels6			;*
		jmp	scan_draw_string

draw_spell_list:
		mov	dx,0E2Eh
		mov	si,spell_idx_tbl
		mov	cl,ds:[spell_count]
		xor	ch,ch			; Zero register

draw_spell_list_loop:
						push	cx
						lodsb				; String [si] to al
						push	si
						push	dx
						dec	al
						mov	bl,al
						xor	bh,bh			; Zero register
						mov	al,byte ptr ds:[spell_charge][bx]
						mov	ah,byte ptr ds:[spell_charge_max][bx]
						push	ax
						push	dx
						push	ax
						push	dx
						mov	bx,dx
						mov	cx,508h
						xor	al,al			; Zero register
						call	word ptr cs:[drv_fill_rect]
						pop	dx
						pop	ax
						xor	ah,ah			; Zero register
						mov	bl,1
						mov	cx,3
						call	format_number
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
						call	word ptr cs:[drv_render_char]
						pop	dx
						pop	ax
						mov	al,ah
						push	dx
						xor	ah,ah			; Zero register
						mov	bl,4
						mov	cx,3
						call	format_number
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
						call	word ptr cs:[drv_render_char]
						pop	dx
						add	dx,800h
						pop	si
						pop	cx
						loop	draw_spell_list_loop		; Loop if cx > 0

		retn

draw_spell_panel		endp

format_number		proc	near
		push	bx
		push	dx
		push	cx
		xor	dl,dl			; Zero register
		mov	di,num_fmt_buf
		call	word ptr cs:[drv_fn_num_fmt]
		pop	cx
		mov	di,num_fmt_buf
		mov	al,7
		sub	al,cl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	ax
		pop	bx
		xor	bh,bh			; Zero register
		jmp	word ptr cs:[drv_fn_render_bg]

format_number		endp

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
						mov	dl,ds:[cur_panel_idx]
						neg	dh
						add	dh,4
						mov	ah,3
						cmp	dl,dh
						jne	tab_not_active			; Jump if not equal
						mov	ah,2

tab_not_active:
;*		call	draw_portrait_tabs_fn21			;*
						call	scan_draw_string
						pop	cx
						loop	draw_tabs_loop		; Loop if cx > 0

		retn
		; Menu shortcut table.  Lines 1381-1382 above (`xor al,0; adc dl,
		; [bp+di+45h]`) were Sourcer mis-decodes of the table's first
		; 5 bytes (34 00 12 53 45) — deleted.  Line "SELT-MAGIC" was
		; missing its EC bytes; restored.  Missing 'CWEAR:' shortcut entry
		; restored between the two '4' entries.  Trailing `db 00h` removed.
portrait_rect_tbl_lbl:
		db	'4', 0			; 0x0A02: shortcut key '4'
		db	012h			; 0x0A04: 0x12 marker
		db	'SELECT-MAGIC:', 0	; 0x0A05: select-magic submenu label
		db	'4', 0			; 0x0A13: shortcut key '4'
		db	'CWEAR:', 0		; 0x0A15: 'C' key -> WEAR submenu
		db	'4', 0			; 0x0A1C: shortcut key '4'
		db	071h, 'USE:', 0		; 0x0A1E: 0x71 key -> USE
		db	0B8h, 0			; 0x0A24: (non-printable key)
		db	'CINVENTORY', 0		; 0x0A26: 'C' key -> INVENTORY

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
						call	word ptr cs:[drv_render_char]
						pop	ax
						pop	cx
						pop	bx

scan_char_draw:
						push	bx
						push	cx
						push	ax
						call	word ptr cs:[drv_render_char]
						pop	ax
						pop	cx
						pop	bx
						pop	si
						add	bx,8
;*		jmp	short init_panels6		;*
						jmp	short scan_draw_string

poll_input:
		call	word ptr cs:[stick_exit_dlg_handler]
		call	word ptr cs:[stick_pause_dlg_handler]
		call	word ptr cs:[stick_speed_change_handler]
		call	word ptr cs:[stick_joy_cal_handler]
		call	word ptr cs:[stick_joy_detect_handler]
		test	byte ptr ds:[exit_queued],0FFh
		jz	check_joy_neutral_entry			; Jump if zero
		call	check_joy_neutral
		cmc				; Complement carry
		jc	poll_exit_queued			; Jump if carry Set
		retn

poll_exit_queued:
		clc				; Clear carry flag
		mov	byte ptr ds:[exit_queued],0
		retn

draw_portrait_tabs		endp

check_joy_neutral		proc	near

check_joy_neutral_entry:
		test	word ptr ds:[gvar_timer_counter],1
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
		dw	(offset spell_str_espada)	; [1] Espada
		dw	(offset spell_str_saeta)	; [2] Saeta
		dw	(offset spell_str_fuego)	; [3] Fuego
		dw	(offset spell_str_lanzar)	; [4] Lanzar
		dw	(offset spell_str_rascar)	; [5] Rascar
		dw	(offset spell_str_agua)	; [6] Agua
		dw	(offset spell_str_guerra)	; [7] Guerra

spell_str_espada:	db	'Espada', 0

spell_str_saeta:	db	'Saeta', 0

spell_str_fuego:	db	'Fuego', 0

spell_str_lanzar:	db	'Lanzar', 0

spell_str_rascar:	db	'Rascar', 0

spell_str_agua:		db	'Agua', 0

spell_str_guerra:	db	'Guerra', 0

shoe_name_ptrs_lbl	label	word		; footwear/clothing item name pointer table (6 entries, 0=none)
		dw	(offset str_no_use_notice_lbl)	; [0] no item equipped
		dw	(offset shoe_str_feruza)		; [1] Feruza shoes
		dw	(offset shoe_str_pirika)		; [2] Pirika shoes
		dw	(offset shoe_str_silkarn)		; [3] Silkarn shoes
		dw	(offset shoe_str_ruzeria)		; [4] Ruzeria shoes
		dw	(offset shoe_str_asbestos)		; [5] Asbestos cape

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
		dw	(offset item_det_str_kenko)	; [1] Ken\ko Potion
		dw	(offset item_det_str_juuen)	; [2] Juu-en Fruit
		dw	(offset item_det_str_elixir)	; [3] Elixir of Kashi
		dw	(offset item_det_str_chikara)	; [4] Chikara Powder
		dw	(offset item_det_str_magia)	; [5] Magia Stone
		dw	(offset item_det_str_holywater)	; [6] Holy Water of Acero
		dw	(offset item_det_str_sabreoil)	; [7] Sabre Oil
		dw	(offset item_det_str_kioku)	; [8] Kioku Feather

item_det_str_kenko:	db	'       a Ken\ko Potion.', 0

item_det_str_juuen:	db	'        a Juu-en Fruit.', 0

item_det_str_elixir:	db	'     a Elixir of Kashi.', 0

item_det_str_chikara:	db	'      a Chikara Powder.', 0

item_det_str_magia:	db	'         a Magia Stone.', 0

item_det_str_holywater:	db	' a Holy Water of Acero.', 0

item_det_str_sabreoil:	db	'           a Sabre Oil.', 0

item_det_str_kioku:	db	'       a Kioku Feather.', 0

item_name_ptrs_lbl	label	word		; item name pointer table (9 entries: [0]=no item, [1-8]=items)
		dw	(offset str_no_use_notice_lbl)	; [0] no item equipped
		dw	(offset item_str_kenko)		; [1] Ken\ko
		dw	(offset item_str_juuen)		; [2] Juu-en
		dw	(offset item_str_elixir)		; [3] Elixir
		dw	(offset item_str_chikara)		; [4] Chikara
		dw	(offset item_str_magia)		; [5] Magia Stone
		dw	(offset item_str_holywater)	; [6] Holy Water
		dw	(offset item_str_sabreoil)		; [7] Sabre Oil
		dw	(offset item_str_kioku)		; [8] Kioku

item_str_kenko:		db	'Ken\ko', 0
			db	'      Potion', 0

item_str_juuen:		db	'Juu-en ', 0
			db	'       Fruit', 0

item_str_elixir:	db	'Elixir', 0
			db	'    of Kashi', 0

item_str_chikara:	db	'Chikara', 0
			db	'      Powder', 0

item_str_magia:		db	'Magia Stone'
			db	0, 0	; null terminator + padding

item_str_holywater:	db	'Holy Water', 0
			db	'    of Acero', 0

item_str_sabreoil:	db	'Sabre Oil', 0
			db	0			; padding

item_str_kioku:		db	'Kioku', 0
			db	'     feather', 0

spell_detail_ptrs_lbl	label	word		; weapon detail pointer table (6 entries, 1-based)
		dw	(offset weap_det_str_training)	; [1] Training Sword
		dw	(offset weap_det_str_wisemans)	; [2] Wise man's Sword
		dw	(offset weap_det_str_spirit)	; [3] Spirit Sword
		dw	(offset weap_det_str_knights)	; [4] Knight's Sword
		dw	(offset weap_det_str_illumination)	; [5] Illumination Sword
		dw	(offset weap_det_str_enchantment)	; [6] Enchantment Sword

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
		dw	(offset shield_det_str_clay)	; [1] Clay Shield
		dw	(offset shield_det_str_wisemans)	; [2] Wise Man's Shield
		dw	(offset shield_det_str_stone)	; [3] Stone Shield
		dw	(offset shield_det_str_honor)	; [4] Honor Shield
		dw	(offset shield_det_str_light)	; [5] Light Shield
		dw	(offset shield_det_str_titanium)	; [6] Titanium Shield

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
portrait_data_tbl_lbl:
		db	0Eh		; trailing control/format byte for shield detail block
		db	0Ch, '38?', 0Ch, '0"m', 0Ch, '0"?'
		db	'-^'
		db	17h		; trailing terminator/padding byte
; --- State variable block (37 bytes, zero-initialized, starting at ADF8h) ---
has_items_flag_lbl:
		db	0			; +0  ADF8 has_items_flag
cur_panel_idx_lbl:
		db	0			; +1  ADF9 cur_panel_idx
spell_count_lbl:
		db	0			; +2  ADFA spell_count
spell_cursor_lbl:
		db	0			; +3  ADFB spell_cursor
accessory_count_lbl:
		db	0			; +4  ADFC accessory_count
accessory_cursor_lbl:
		db	0			; +5  ADFD accessory_cursor
item_count_lbl:
		db	0			; +6  ADFE item_count
item_cursor_lbl:
		db	0			; +7  ADFF item_cursor
item_sel_idx_lbl:
		db	0			; +8  AE00 item_sel_idx
exit_queued_lbl:
		db	0			; +9  AE01 exit_queued
portrait_vis_lbl:
		db	0			; +10 AE02 portrait_vis
spell_idx_tbl_lbl:
		db	7 dup (0)		; +11 AE03 spell_idx_tbl (7 bytes)
accessory_idx_tbl_lbl:
		db	6 dup (0)		; +18 AE0A accessory_idx_tbl (6 bytes)
item_idx_tbl_lbl:
		db	6 dup (0)		; +24 AE10 item_idx_tbl (6 bytes)
num_fmt_buf_lbl:
		db	7 dup (0)		; +30 AE16 num_fmt_buf (7 bytes)

seg_a		ends

		end	start
