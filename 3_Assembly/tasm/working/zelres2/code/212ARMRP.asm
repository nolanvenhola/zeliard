
PAGE  59,132

;==========================================================================
;
;  212ARMRP - Weapon & Armour Shop Program (ARMRPRO.BIN, zelres2 chunk 14)
;
;  Loaded at gvar_game_seg:loaded_code_a (0x3000) by town.bin when player
;  enters the weapon & armour shop building. Provides the shop menu loop:
;      Go outside / Repair shield / Buy weapon / Buy shield / Explain goods
;  along with trade-in pricing, dialog rendering, shopkeeper animation, and
;  the mid-game "knight's sword exchange" event (honor-crest check).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc


; External data references (outside this module's CS segment).

; --- Chunk loader scratch / temp buffer (game_seg) ---
chunk_load_buf	equ	8000h			;* temp buffer for loading chunk into game_seg

; --- Graphics driver function table (drv_seg base 2000h) ---
;   drv_fill_rect, drv_screen_init_a, drv_load_msg_header, drv_screen_init_b,
;   drv_frame_commit, drv_return_to_caller, drv_ds_copy, drv_draw_glyph
;   are defined in zr2com.inc.
gfx_set_color_fn	equ	2004h			;* set drawing color/palette for bar
gfx_present_fn		equ	201Ah			;* present / update current frame
gfx_render_scene_fn	equ	201Ch			;* render scene (jmp indirect, end of transaction)
gfx_draw_hud_fn		equ	2020h			;* draw HUD/money panel (bx=pos/al=side)

; --- Game-code function table (game_seg:6000h-6012h) ---
;   script_step, script_format_num, script_display_page, script_take_item,
;   script_give_item are defined in zr2com.inc.
menu_init_fn		equ	600Eh			;* menu init (cx=rows,si=str tbl)
menu_nav_fn		equ	6010h			;* menu navigate (bl=cur row -> updated bl,CY=cancel)
menu_render_fn		equ	6012h			;* menu render (si=strs,cl=rows,al=color)

; --- Game-segment data (game_seg-relative) ---
chunk_load_param	equ	4002h			;* chunk-load parameter field
rect_coord_291D		equ	291Dh			;* rect fill coord constant (bx param in rect_fill)
dialog_err_str		equ	7FE8h			;* error/not-enough-gold dialog string
dialog_tip_str		equ	9998h			;* hint/tooltip dialog string
shop_dispatch_a		equ	0A119h			;* dispatch tbl a (buy weapon path selector)
shop_dispatch_b		equ	0A176h			;* dispatch tbl b (buy shield path selector)
shop_dispatch_c		equ	0A198h			;* dispatch tbl c (explain-goods selector)
shop_status_a		equ	0A24Bh			;* shop status flag variable A
flag_trade_done		equ	0A498h			;* per-transaction "trade complete" flag byte
shield_price_tbl	equ	0A6BFh			;* shield price word array (per type)
shield_price_tbl_end	equ	0A8FDh			;* trade-in multiplier byte table (near shield_price_tbl+0x23E)
trade_multiplier_tbl_p	equ	0A90Fh			;* trade-in price formula word table pointer
anim_seq_closed		equ	0AAD0h			;* shopkeeper animation seq (mouth closed)
anim_seq_open		equ	0AB68h			;* shopkeeper animation seq (mouth open)
goods_icon_map		equ	0AC9Ch			;* goods icon index lookup base
explain_dispatch_a	equ	0ACA2h			;* explain-goods text offsets (part A)
explain_dispatch_b	equ	0ACAEh			;* explain-goods text offsets (part B)
weapon_name_offs	equ	0AD05h			;* weapon name table offsets (base for si computation)
shield_name_offs	equ	0AD11h			;* shield name table offsets
explain_text_tbl	equ	0B3DEh			;* explain-goods text address table (per-item)
weapon_dlg_tbl		equ	0BAA7h			;* weapon dialog base table (indexed by equipped slot)

; --- Dialog/menu state variables (game_seg local scratch) ---
cur_weapon_idx		equ	0BBFDh			;* selected weapon slot index byte
cur_weapon_flag		equ	0BBFEh			;* selected weapon flag byte
cur_shield_idx		equ	0BC0Fh			;* selected shield slot index byte
cur_shield_flag		equ	0BC10h			;* selected shield flag byte
last_menu_choice	equ	0BC21h			;* last menu choice byte
sub_menu_choice_a	equ	0BC22h			;* sub-menu choice A byte
trade_active_flag	equ	0BC23h			;* transaction in progress flag
anim_state_0		equ	0BC24h			;* shopkeeper anim state byte 0
anim_state_1		equ	0BC25h			;* shopkeeper anim state byte 1
anim_state_2		equ	0BC26h			;* shopkeeper anim state byte 2
anim_state_3		equ	0BC27h			;* shopkeeper anim state byte 3
trade_weapon_flag	equ	0BC28h			;* trade/swap weapon flag byte
trade_gold_tmp		equ	0BC29h			;* trade-in gold temporary (byte)
trade_gold_buf_hi	equ	0BC2Ch			;* trade-in gold scratch byte
trade_gold_buf_hi2	equ	0BC2Dh			;* trade-in gold scratch byte 2
new_item_flag		equ	0BC2Fh			;* new-item/equip flag byte
new_item_idx		equ	0BC30h			;* new-item slot index byte
weapon_cnt		equ	0BC31h			;* number of weapons for sale byte
shield_cnt		equ	0BC32h			;* number of shields for sale byte
mouth_anim_A		equ	0BC3Bh			;* mouth anim packed bits A (6 bytes)
mouth_anim_B		equ	0BC41h			;* mouth anim packed bits B (6 bytes)
town_npc_state		equ	0C006h			;* town-map NPC/room state byte

; --- Global variables (game_seg:0xFFxx) ---
;   gvar_frame_timer, gvar_dlg_cols, gvar_dlg_rows, gvar_dlg_pos
;   are defined in zr2com.inc.
gvar_game_seg		equ	0FF2Ch			;* game segment selector word
gvar_sel_row		equ	0FF56h			;* current menu row byte
gvar_sel_flag		equ	0FF57h			;* menu selection flag byte
gvar_sel_xlat		equ	0FF58h			;* menu selection translate byte
gvar_ff68		equ	0FF68h			;* (free slot) word
gvar_dlg_timer		equ	0FF6Ah			;* dialog timer word

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

armrp_main		proc	far

start:
		inc	di
		sbb	al,0
		add	[si],al
		mov	al,ds:trade_multiplier_tbl_p
		mov	es,ds:gvar_game_seg
		mov	di,8000h
		mov	si,explain_dispatch_a
		mov	al,2
		call	word ptr cs:[10Ch]
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,chunk_load_buf
		mov	cx,100h
		call	word ptr cs:drv_ds_copy
		pop	ds
		mov	byte ptr ds:gvar_text_x,0
		mov	byte ptr ds:gvar_text_y,0
		mov	byte ptr ds:last_menu_choice,0
		call	word ptr cs:drv_screen_init_a
		call	word ptr cs:drv_screen_init_b
		mov	si,explain_dispatch_b
		call	word ptr cs:drv_load_msg_header
		call	build_mouth_bitmap_a
		call	build_mouth_bitmap_b
		push	cs
		pop	es
		mov	bl,ds:town_npc_state
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:weapon_dlg_tbl[bx]
		mov	di,cur_weapon_idx
		mov	cx,12h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		call	render_shopkeeper_frame
		mov	byte ptr ds:trade_active_flag,0FFh
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_script_ip,0ADD3h
		test	byte ptr ds:[24h],2
		jnz	script_loop			; Jump if not zero
		cmp	byte ptr ds:town_npc_state,5
		jne	script_loop			; Jump if not equal
		test	byte ptr ds:[9Bh],0FFh
		jz	script_loop			; Jump if zero
		mov	word ptr ds:gvar_script_ip,0B2A2h
		mov	byte ptr ds:trade_active_flag,0
script_loop:
		call	word ptr cs:script_step
		cmp	al,0FFh
		je	shop_exit			; Jump if equal
		call	shop_menu_dispatch
		jmp	short script_loop
shop_exit:
		jmp	word ptr cs:drv_return_to_caller

armrp_main		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

build_mouth_bitmap_a		proc	near
		mov	si,0D2h
		mov	al,ds:town_npc_state
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,mouth_anim_A
		xor	dh,dh			; Zero register
		mov	cx,6

mouth_a_bit_loop:
		add	dl,dl
		jnc	mouth_a_skip			; Jump if carry=0
		mov	al,cl
		neg	al
		add	al,6
		stosb				; Store al to es:[di]
		inc	dh
mouth_a_skip:
		loop	mouth_a_bit_loop		; Loop if cx > 0

		mov	ds:weapon_cnt,dh
		retn
build_mouth_bitmap_a		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

build_mouth_bitmap_b		proc	near
		mov	si,0DBh
		mov	al,ds:town_npc_state
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,mouth_anim_B
		xor	dh,dh			; Zero register
		mov	cx,6

mouth_b_bit_loop:
		add	dl,dl
		jnc	mouth_b_skip			; Jump if carry=0
		mov	al,cl
		neg	al
		add	al,6
		stosb				; Store al to es:[di]
		inc	dh
mouth_b_skip:
		loop	mouth_b_bit_loop		; Loop if cx > 0

		mov	ds:shield_cnt,dh
		retn
build_mouth_bitmap_b		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

shop_menu_dispatch		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:shop_dispatch_a[bx]	;*
shop_menu_dispatch		endp

			                        ;* No entry point to code
		sub	ax,59A1h
		mov	ds:flag_trade_done,al
		retf
			                        ;* No entry point to code
		cmpsb				; Cmp [si] to es:[di]
		push	es
		cmpsw				; Cmp [si] to es:[di]
		push	ss
		cmpsw				; Cmp [si] to es:[di]
		pop	cx
		cmpsw				; Cmp [si] to es:[di]
		db	70h, 0A8h		; jo (rel8; absolute target, TASM won't compile as mnemonic)
		sub	byte ptr ds:shield_price_tbl_end[bx+si],0E8h
		rol	byte ptr [bx],cl	; Rotate
		mov	bx,rect_coord_291D
		mov	cx,1837h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,2920h
		mov	byte ptr ds:gvar_dlg_cols,5
		mov	byte ptr ds:gvar_dlg_rows,5
		mov	cx,5
		mov	si,0ACC8h
		call	word ptr cs:menu_init_fn
		mov	byte ptr ds:gvar_sel_row,0
		mov	bl,ds:last_menu_choice
		call	word ptr cs:menu_nav_fn
		jnc	menu_a_choice_ok			; Jump if carry=0
		xor	bl,bl			; Zero register
menu_a_choice_ok:
		mov	ds:last_menu_choice,bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:shop_dispatch_b[bx]	;*
			                        ;* No entry point to code
		and	byte ptr ds:shop_dispatch_c[bx+di],44h	; 'D'
		mov	ds:shop_status_a,al
		push	dx
		mov	ds:dialog_err_str,al
		pop	es
		mov	si,0B1DEh
		test	byte ptr ds:trade_weapon_flag,0FFh
		jnz	save_script_ip			; Jump if not zero
		db	0E8h, 76h, 05h		; call near (absolute; TASM won't compile as mnemonic)
		mov	si,0B1FFh
save_script_ip:
		mov	ds:gvar_script_ip,si
		retn
			                        ;* No entry point to code
		call	clear_menu_rect
		test	byte ptr ds:[93h],0FFh
		jnz	check_change_wallet			; Jump if not zero
		mov	word ptr ds:gvar_script_ip,0AE4Ah
		retn
check_change_wallet:
		mov	ax,word ptr ds:[96h]
		sub	ax,word ptr ds:[94h]
		jnz	calc_trade_price			; Jump if not zero
		mov	word ptr ds:gvar_script_ip,0AEB1h
		retn
calc_trade_price:
		mov	byte ptr ds:trade_weapon_flag,0FFh
		shr	ax,1			; Shift w/zeros fill
		adc	ax,0
		mov	ds:trade_gold_tmp,ax
		mov	word ptr ds:gvar_script_ip,0AEF8h
		call	word ptr cs:script_step
		xor	dl,dl			; Zero register
		mov	ax,ds:trade_gold_tmp
		mov	di,0BC33h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		pushf				; Push flags
		call	clear_menu_rect
		popf				; Pop flags
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	skip_price_fail			; Jump if carry=0
		retn
skip_price_fail:
		mov	ax,ds:trade_gold_tmp
		xor	dl,dl			; Zero register
		call	word ptr cs:script_take_item
		mov	word ptr ds:gvar_script_ip,0AF53h
		jnc	commit_trade_weapon			; Jump if carry=0
		retn
commit_trade_weapon:
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		call	word ptr cs:drv_frame_commit
		mov	word ptr ds:gvar_script_ip,0AFAFh
		retn
			                        ;* No entry point to code
		mov	word ptr ds:gvar_script_ip,0B026h
		retn
			                        ;* No entry point to code
		mov	word ptr ds:gvar_script_ip,0B081h
		retn
			                        ;* No entry point to code
		mov	word ptr ds:gvar_script_ip,0B11Fh
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:trade_weapon_flag,0FFh
		push	cs
		pop	es
		mov	di,gvar_sel_xlat
		mov	si,mouth_anim_A
		mov	cx,6
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:weapon_cnt
		mov	ds:gvar_dlg_rows,al
		cmp	al,3
		jb	cap_weapon_rows			; Jump if below
		mov	al,3
cap_weapon_rows:
		mov	ds:gvar_dlg_cols,al
		mov	byte ptr ds:gvar_sel_row,0
		mov	byte ptr ds:sub_menu_choice_a,0
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:gvar_sel_flag,0FFh
		mov	word ptr ds:gvar_dlg_pos,1571h
		mov	word ptr ds:gvar_dlg_timer,21h
		mov	word ptr ds:gvar_ff68,17h
		mov	si,0AD05h
		mov	di,0BBFDh
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:gvar_sel_row
		call	word ptr cs:menu_render_fn
		mov	bl,ds:sub_menu_choice_a
		call	word ptr cs:menu_nav_fn
		jnc	menu_weapon_sel_ok			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0ADEFh
		retn
menu_weapon_sel_ok:
		mov	ds:sub_menu_choice_a,bl
		mov	al,bl
		add	al,ds:gvar_sel_row
		mov	bx,gvar_sel_xlat
		xlat				; al=[al+[bx]] table
		call	knight_sword_hook_a
		push	ax
		mov	word ptr ds:gvar_script_ip,0B0DCh
		call	word ptr cs:script_step
		pop	ax
		push	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:weapon_name_offs[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		pop	ax
		push	ax
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		mov	si,cur_weapon_idx
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:trade_gold_tmp,dl
		mov	word ptr ds:trade_gold_tmp+1,ax
		call	word ptr cs:script_take_item
		pop	bx
		mov	word ptr ds:gvar_script_ip,0AF54h
		jnc	weapon_trade_ok			; Jump if carry=0
		retn
weapon_trade_ok:
		mov	ds:trade_gold_buf_hi,dl
		mov	ds:trade_gold_buf_hi2,ax
		inc	bl
		mov	ds:new_item_flag,bl
		mov	word ptr ds:gvar_script_ip,0B106h
		call	word ptr cs:script_step
		mov	dl,ds:trade_gold_tmp
		mov	ax,word ptr ds:trade_gold_tmp+1
		mov	di,0BC33h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		mov	byte ptr ds:trade_gold_tmp,0
		mov	word ptr ds:trade_gold_tmp+1,0
		test	byte ptr ds:[92h],0FFh
		jz	skip_weapon_swap			; Jump if zero
		mov	al,byte ptr ds:[92h]
		mov	ds:new_item_idx,al
		mov	word ptr ds:gvar_script_ip,0B046h
		call	word ptr cs:script_step
		mov	al,ds:new_item_idx
		dec	al
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	bx,ax
		mov	dl,ds:cur_weapon_idx[bx]
		mov	ax,ds:cur_weapon_flag[bx]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:trade_gold_tmp,dl
		mov	word ptr ds:trade_gold_tmp+1,ax
		mov	di,0BC33h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
skip_weapon_swap:
		mov	word ptr ds:gvar_script_ip,0B0EDh
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	weapon_commit			; Jump if carry=0
		retn
weapon_commit:
		mov	word ptr ds:gvar_script_ip,0AE1Ch
		mov	dl,ds:trade_gold_buf_hi
		mov	ax,ds:trade_gold_buf_hi2
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		mov	dl,ds:trade_gold_tmp
		mov	ax,word ptr ds:trade_gold_tmp+1
		call	word ptr cs:script_give_item
		call	word ptr cs:drv_frame_commit
		test	byte ptr ds:new_item_idx,0FFh
		jz	skip_weapon_slot_fix			; Jump if zero
		mov	al,ds:new_item_idx
		dec	al
		mov	bx,goods_icon_map
		xlat				; al=[al+[bx]] table
		mov	bl,ds:town_npc_state
		dec	bl
		xor	bh,bh			; Zero register
		or	byte ptr ds:[0D2h][bx],al
skip_weapon_slot_fix:
		mov	al,ds:new_item_flag
		mov	byte ptr ds:[92h],al
		cmp	al,6
		jne	skip_slot_clear			; Jump if not equal
		mov	bl,ds:town_npc_state
		dec	bl
		xor	bh,bh			; Zero register
		and	byte ptr ds:[0D2h][bx],0FBh
skip_slot_clear:
		call	build_mouth_bitmap_a
		mov	ah,byte ptr ds:[92h]
		mov	al,4
		call	word ptr cs:[10Ch]
		mov	al,byte ptr ds:[92h]
		mov	bx,18ABh
		jmp	word ptr cs:gfx_render_scene_fn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

knight_sword_hook_a		proc	near
		cmp	al,3
		je	knight_hook_a_pass1			; Jump if equal
		retn
knight_hook_a_pass1:
		test	byte ptr ds:[24h],2
		jz	knight_hook_a_pass2			; Jump if zero
		retn
knight_hook_a_pass2:
		cmp	byte ptr ds:town_npc_state,5
		je	knight_hook_a_pass3			; Jump if equal
		retn
knight_hook_a_pass3:
		pop	ax
		mov	word ptr ds:gvar_script_ip,0B24Ch
		retn
knight_sword_hook_a		endp

			                        ;* No entry point to code
		mov	byte ptr ds:trade_weapon_flag,0FFh
		push	cs
		pop	es
		mov	di,gvar_sel_xlat
		mov	si,mouth_anim_B
		mov	cx,6
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:shield_cnt
		mov	ds:gvar_dlg_rows,al
		cmp	al,3
		jb	cap_shield_rows			; Jump if below
		mov	al,3
cap_shield_rows:
		mov	ds:gvar_dlg_cols,al
		mov	byte ptr ds:gvar_sel_row,0
		mov	byte ptr ds:sub_menu_choice_a,0
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:gvar_sel_flag,0FFh
		mov	word ptr ds:gvar_dlg_pos,1571h
		mov	word ptr ds:gvar_dlg_timer,21h
		mov	word ptr ds:gvar_ff68,17h
		mov	si,0AD11h
		mov	di,0BC0Fh
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:gvar_sel_row
		call	word ptr cs:menu_render_fn
		mov	bl,ds:sub_menu_choice_a
		call	word ptr cs:menu_nav_fn
		jnc	menu_shield_sel_ok			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0ADEFh
		retn
menu_shield_sel_ok:
		mov	ds:sub_menu_choice_a,bl
		mov	word ptr ds:gvar_script_ip,0B0DCh
		call	word ptr cs:script_step
		mov	al,ds:sub_menu_choice_a
		add	al,ds:gvar_sel_row
		mov	bx,gvar_sel_xlat
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:shield_name_offs[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		pop	ax
		push	ax
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	ax,bx
		mov	si,cur_shield_idx
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:trade_gold_tmp,dl
		mov	word ptr ds:trade_gold_tmp+1,ax
		call	word ptr cs:script_take_item
		pop	bx
		mov	word ptr ds:gvar_script_ip,0AF54h
		jnc	shield_trade_ok			; Jump if carry=0
		retn
shield_trade_ok:
		mov	ds:trade_gold_buf_hi,dl
		mov	ds:trade_gold_buf_hi2,ax
		inc	bl
		mov	ds:new_item_flag,bl
		mov	word ptr ds:gvar_script_ip,0B106h
		call	word ptr cs:script_step
		mov	dl,ds:trade_gold_tmp
		mov	ax,word ptr ds:trade_gold_tmp+1
		mov	di,0BC33h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		mov	byte ptr ds:trade_gold_tmp,0
		mov	word ptr ds:trade_gold_tmp+1,0
		test	byte ptr ds:[93h],0FFh
		jz	skip_shield_swap			; Jump if zero
		mov	al,byte ptr ds:[93h]
		mov	ds:new_item_idx,al
		mov	word ptr ds:gvar_script_ip,0B0A1h
		call	word ptr cs:script_step
		mov	al,ds:new_item_idx
		dec	al
		xor	ah,ah			; Zero register
		mov	bx,ax
		add	ax,ax
		add	bx,ax
		mov	dl,ds:cur_shield_idx[bx]
		mov	ax,ds:cur_shield_flag[bx]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:trade_gold_tmp,dl
		mov	word ptr ds:trade_gold_tmp+1,ax
		mov	di,0BC33h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
skip_shield_swap:
		mov	word ptr ds:gvar_script_ip,0B0EDh
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	shield_commit			; Jump if carry=0
		retn
shield_commit:
		mov	word ptr ds:gvar_script_ip,0AE1Ch
		mov	dl,ds:trade_gold_buf_hi
		mov	ax,ds:trade_gold_buf_hi2
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		mov	dl,ds:trade_gold_tmp
		mov	ax,word ptr ds:trade_gold_tmp+1
		call	word ptr cs:script_give_item
		call	word ptr cs:drv_frame_commit
		test	byte ptr ds:new_item_idx,0FFh
		jz	skip_shield_slot_fix			; Jump if zero
		mov	al,ds:new_item_idx
		dec	al
		mov	bx,goods_icon_map
		xlat				; al=[al+[bx]] table
		mov	bl,ds:town_npc_state
		dec	bl
		xor	bh,bh			; Zero register
		or	byte ptr ds:[0DBh][bx],al
skip_shield_slot_fix:
		mov	al,ds:new_item_flag
		mov	byte ptr ds:[93h],al
		call	build_mouth_bitmap_b
		mov	al,byte ptr ds:[93h]
		mov	bx,3EA4h
		call	word ptr cs:gfx_draw_hud_fn
		mov	bx,0C61Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:gfx_set_color_fn
		mov	bl,byte ptr ds:[93h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:shield_price_tbl[bx]
		mov	word ptr ds:[96h],ax
		mov	word ptr ds:[94h],ax
		jmp	word ptr cs:gfx_present_fn
			                        ;* No entry point to code
		push	ds
		db	00h, 50h, 00h		; add [bx+si+0],dl (alt encoding: mod=01 disp8 not mod=00)
		db	0B4h, 00h, 2Ch, 01h, 2Ch, 01h
		db	 58h, 02h,0C6h, 06h, 23h,0BCh
		db	 00h,0F6h, 06h, 26h,0BCh,0FFh
		db	 74h, 08h,0B0h, 01h,0E8h,0F3h
		db	 02h,0E8h, 91h, 01h,0BEh,0FDh
		db	0A6h
explain_char_next:
		lodsb				; String [si] to al
		cmp	al,0FFh
		jne	explain_char_do			; Jump if not equal
		retn
explain_char_do:
		push	si
		or	al,al			; Zero ?
		jns	explain_char_no_pre			; Jump if not sign
		mov	byte ptr ds:gvar_volume,20h	; ' '
explain_char_no_pre:
		and	al,7
		call	render_shopkeeper_frame
		call	frame_delay
		pop	si
		jmp	short explain_char_next
			                        ;* No entry point to code
		add	ax,[si]
		add	ax,8605h
		push	es
		pop	es
		pop	es
		db	0FFh, 0C6h		; inc si (alt encoding: FF /0 not 46 short form)
		push	es
		sbb	bh,bh
		db	00h, 0E8h		; add al,ch (alt encoding: 00 r/m8,r8 not 02 r8,r/m8)
		add	[bp+si],ax
		cmp	byte ptr ds:gvar_frame_timer,96h
		db	72h, 0F6h		; jb (rel8; absolute target, TASM won't compile as mnemonic)
		retn
			                        ;* No entry point to code
		call	word ptr cs:drv_return_to_caller
		mov	word ptr ds:gvar_menu_step,0
wait_menu_exit:
		cmp	word ptr ds:gvar_menu_step,190h
		jb	wait_menu_exit			; Jump if below
		mov	ax,word ptr ds:[96h]
		mov	word ptr ds:[94h],ax
		call	word ptr cs:gfx_present_fn
		mov	byte ptr ds:anim_state_0,0
		mov	byte ptr ds:anim_state_1,0
		mov	byte ptr ds:anim_state_2,0
		mov	byte ptr ds:anim_state_3,0
		xor	al,al			; Zero register
		call	render_shopkeeper_frame
		mov	byte ptr ds:trade_active_flag,0FFh
		mov	word ptr ds:gvar_script_ip,0AFE0h
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:sub_menu_choice_a,0
		mov	byte ptr ds:gvar_sel_row,0
explain_menu_top:
		push	cs
		pop	es
		mov	cl,ds:weapon_cnt
		xor	ch,ch			; Zero register
		mov	si,mouth_anim_A
		mov	di,gvar_sel_xlat
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	cl,ds:shield_cnt
		mov	si,mouth_anim_B

copy_anim_b_loop:
		lodsb				; String [si] to al
		add	al,6
		stosb				; Store al to es:[di]
		loop	copy_anim_b_loop		; Loop if cx > 0

		mov	al,ds:weapon_cnt
		add	al,ds:shield_cnt
		mov	ds:gvar_dlg_rows,al
		mov	al,ds:gvar_dlg_rows
		cmp	al,6
		jb	cap_explain_rows			; Jump if below
		mov	al,6
cap_explain_rows:
		mov	ds:gvar_dlg_cols,al
		mov	bx,2717h
		mov	cx,1B41h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:gvar_sel_flag,0
		mov	word ptr ds:gvar_dlg_pos,271Ah
		mov	word ptr ds:gvar_dlg_timer,17h
		mov	si,weapon_name_offs
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:gvar_sel_row
		call	word ptr cs:menu_render_fn
		mov	bl,ds:sub_menu_choice_a
		call	word ptr cs:menu_nav_fn
		jnc	menu_explain_sel_ok			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0ADEFh
		retn
menu_explain_sel_ok:
		mov	ds:sub_menu_choice_a,bl
		mov	word ptr ds:gvar_script_ip,0B0EAh
		call	word ptr cs:script_step
		mov	al,ds:sub_menu_choice_a
		add	al,ds:gvar_sel_row
		mov	bx,gvar_sel_xlat
		xlat				; al=[al+[bx]] table
		call	knight_sword_hook_b
		push	ax
		push	ax
		mov	word ptr ds:gvar_script_ip,0B0DDh
		call	word ptr cs:script_step
		pop	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:weapon_name_offs[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		pop	ax
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:explain_text_tbl[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		mov	word ptr ds:gvar_script_ip,0B1A9h
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	explain_continue			; Jump if carry=0
		retn
explain_continue:
		mov	word ptr ds:gvar_script_ip,0B17Eh
		call	word ptr cs:script_step
		jmp	explain_menu_top

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

frame_delay		proc	near
		mov	byte ptr ds:gvar_frame_timer,0
frame_delay_loop:
		call	shopkeeper_anim_tick
		cmp	byte ptr ds:gvar_frame_timer,32h	; '2'
		jb	frame_delay_loop			; Jump if below
		retn
frame_delay		endp

			                        ;* No entry point to code
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		pushf				; Push flags
		call	clear_menu_rect
		popf				; Pop flags
		mov	word ptr ds:gvar_script_ip,0B336h
		jnc	reset_after_trade			; Jump if carry=0
		retn
reset_after_trade:
		xor	al,al			; Zero register
		call	render_shopkeeper_frame
		mov	word ptr ds:gvar_script_ip,0B375h
		call	word ptr cs:script_step
		mov	byte ptr ds:[92h],4
		mov	byte ptr ds:[9Bh],0
		mov	al,4
		mov	bx,18ABh
		call	word ptr cs:gfx_render_scene_fn
		and	byte ptr ds:[0D6h],0EFh
		or	byte ptr ds:[24h],2
		mov	ah,byte ptr ds:[92h]
		mov	al,4
		call	word ptr cs:[10Ch]
		retn

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

knight_sword_hook_b		proc	near
		cmp	al,3
		je	knight_hook_b_pass1			; Jump if equal
		retn
knight_hook_b_pass1:
		test	byte ptr ds:[24h],2
		jz	knight_hook_b_pass2			; Jump if zero
		retn
knight_hook_b_pass2:
		cmp	byte ptr ds:town_npc_state,5
		je	knight_hook_b_pass3			; Jump if equal
		retn
knight_hook_b_pass3:
		pop	ax
		mov	word ptr ds:gvar_script_ip,0B240h
		retn
knight_sword_hook_b		endp

		db	0B0h, 03h,0E9h,0CDh, 00h

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

clear_menu_rect		proc	near
		mov	bx,2717h
		mov	cx,1C41h
		xor	al,al			; Zero register
		jmp	word ptr cs:drv_fill_rect
clear_menu_rect		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

shopkeeper_anim_tick		proc	near
		test	byte ptr ds:trade_active_flag,0FFh
		jnz	anim_trade_active			; Jump if not zero
		retn
anim_trade_active:
		cmp	word ptr ds:gvar_menu_step,2
		jae	anim_frame_tick			; Jump if above or =
		retn
anim_frame_tick:
		mov	word ptr ds:gvar_menu_step,0
		inc	byte ptr ds:anim_state_0
		cmp	byte ptr ds:anim_state_0,1Eh
		jae	anim_half_second			; Jump if above or =
		retn
anim_half_second:
		mov	byte ptr ds:anim_state_0,0
		inc	byte ptr ds:anim_state_1
		test	byte ptr ds:anim_state_2,0FFh
		jz	anim_closed_pose			; Jump if zero
		cmp	byte ptr ds:anim_state_2,7Fh
		jne	anim_phase_7F			; Jump if not equal
		mov	byte ptr ds:anim_state_2,0FFh
		mov	al,2
		jmp	short render_frame_top
anim_phase_7F:
		cmp	byte ptr ds:anim_state_2,80h
		jne	anim_phase_80			; Jump if not equal
		mov	byte ptr ds:anim_state_2,0
		xor	al,al			; Zero register
		jmp	short render_frame_top
anim_phase_80:
		mov	si,anim_seq_open
		mov	al,ds:anim_state_1
		and	ax,3
		add	ax,ax
		add	si,ax
		mov	bx,0B37h
		mov	cx,2

vert_glyph_col_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:drv_draw_glyph
		pop	bx
		add	bl,8
		pop	cx
		loop	vert_glyph_col_loop		; Loop if cx > 0

		jmp	short anim_after_pose
anim_closed_pose:
		mov	si,anim_seq_closed
		mov	al,ds:anim_state_1
		and	ax,3
		add	ax,ax
		add	si,ax
		mov	bx,104Fh
		mov	cx,2

horiz_glyph_col_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:drv_draw_glyph
		pop	bx
		inc	bh
		pop	cx
		loop	horiz_glyph_col_loop		; Loop if cx > 0

anim_after_pose:
		call	word ptr cs:[11Ah]
		and	al,1
		jz	anim_skip_toggle			; Jump if zero
		retn
anim_skip_toggle:
		inc	byte ptr ds:anim_state_3
		cmp	byte ptr ds:anim_state_3,1Eh
		jae	anim_toggle_pose			; Jump if above or =
		retn
anim_toggle_pose:
		mov	byte ptr ds:anim_state_3,0
		mov	al,ds:anim_state_2
		not	al
		xor	al,80h
		mov	ds:anim_state_2,al
		mov	al,1
		jmp	short render_frame_top

;���� External Entry into Subroutine ��������������������������������������

render_shopkeeper_frame:
render_frame_top:
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	cx,ax
		add	ax,ax
		add	ax,cx
		add	ax,0AA10h
		mov	si,ax
		mov	bx,717h
		mov	cx,2

render_frame_outer_loop:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	render_frame_inner			; Jump if not zero
		retn
render_frame_inner:
		push	cx
		mov	cl,al
		lodsw				; String [si] to ax
		xchg	si,ax
		push	ax

render_frame_col_loop:
		push	cx
		mov	cx,0Ch

render_frame_glyph_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:drv_draw_glyph
		pop	bx
		inc	bh
		pop	cx
		loop	render_frame_glyph_loop		; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	render_frame_col_loop		; Loop if cx > 0

		pop	si
		pop	cx
		loop	render_frame_outer_loop		; Loop if cx > 0

		retn
shopkeeper_anim_tick		endp

			                        ;* No entry point to code
		add	al,[bx+si-56h]
		push	es
		mov	ss:chunk_load_param[bp+si],ch
		stosb				; Store al to es:[di]
		push	es
		db	0D8h,0AAh, 02h, 40h,0AAh, 06h
		db	 20h,0ABh, 04h, 58h,0AAh, 04h
		db	 70h,0ABh, 03h, 58h,0AAh, 05h
		db	0A0h,0ABh, 08h,0DCh,0ABh, 00h
		db	 00h, 00h, 04h, 58h,0AAh, 04h
		db	 3Ch,0ACh, 04h, 58h,0AAh, 04h
		db	 6Ch,0ACh, 00h, 01h, 02h, 03h
		db	 01h, 01h, 01h, 01h, 01h, 04h
		db	 05h, 06h, 07h, 08h, 09h, 0Ah
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh
		db	 0Eh, 0Fh, 00h, 01h, 02h, 03h
		db	 01h, 01h, 01h, 01h, 01h, 04h
		db	 05h, 06h, 07h, 08h, 09h, 0Ah
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh
		db	 0Eh, 0Fh, 10h, 11h, 12h, 13h
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 8Fh
		db	 90h, 1Eh, 91h, 92h, 93h, 21h
		db	 22h, 23h, 10h, 11h, 12h, 13h
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 1Ch
		db	 1Dh, 1Eh, 1Fh
		db	' ', 0Ch, '!"#$'
		db	'%', 0Ch, '&', 27h, '()*+,-./0123'
		db	'456789:;<=>?@ABCDEFGHIJKLMNOPQRP'
		db	'QPQPQST'
		db	 10h, 11h, 12h, 13h, 55h, 56h
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h
		db	 1Ah, 1Bh, 0Ch, 1Ch
		db	'XYZ[', 0Ch, '!"#$'
		db	'%', 0Ch, '\]^_`a,-./0bcdefghi9:;'
		db	'<jklmnopqEFGrstuvwxyz{R'
		db	 10h, 11h, 12h, 13h, 55h, 56h
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h
		db	 1Ah, 1Bh, 0Ch, 1Ch
		db	'XYZ[', 0Ch, '!"#$'
		db	'%', 0Ch, '|]^_}~,-./0j'
		db	 80h, 81h, 82h, 83h, 84h, 85h
		db	 69h, 39h, 3Ah, 3Bh, 3Ch, 0Ch
		db	 7Fh, 86h, 87h, 88h, 89h, 8Ah
		db	'qEFGrsJKLMNyz{R]'
		db	 81h, 5Dh, 81h, 5Dh, 81h, 8Dh
		db	 8Eh, 24h, 25h, 94h, 95h, 96h
		db	 28h, 97h, 98h, 99h, 2Ch, 2Dh
		db	 2Eh, 2Fh, 30h, 9Ah, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah, 3Bh, 3Ch,0A2h,0A3h,0A4h
		db	0A5h,0A6h,0A7h,0A8h,0A9h, 45h
		db	 46h, 47h, 72h,0AAh,0ABh, 4Bh
		db	 4Ch, 4Dh, 4Eh,0ACh,0ADh, 7Bh
		db	 52h, 1Ah, 1Bh, 0Ch,0AEh,0AFh
		db	 1Eh, 91h,0B0h,0B1h, 21h, 22h
		db	 23h, 24h,0B2h,0B3h,0B4h,0B5h
		db	0B6h, 97h,0B7h,0B8h,0B9h, 2Dh
		db	 2Eh, 2Fh,0BAh,0BBh,0BCh, 9Ch
		db	 9Dh, 9Eh,0BDh,0BEh,0BFh, 39h
		db	 3Ah, 3Bh, 3Ch, 0Ch, 0Ch,0C0h
		db	0A5h,0A6h,0C1h, 8Ah
		db	'qEFGrsJKLMNyz{R'
		db	 00h, 01h, 02h,0C2h,0C3h,0C4h
		db	0C5h,0C6h, 01h, 04h, 05h, 06h
		db	 07h, 08h,0C7h,0C8h,0C9h,0CAh
		db	0CBh,0CCh,0CDh, 0Dh, 0Eh, 0Fh
		db	 10h, 11h,0CEh,0CFh,0D0h,0D1h
		db	0D2h,0D3h,0D4h
		db	 17h, 18h, 19h, 1Ah, 1Bh, 0Ch
		db	0D5h,0D6h,0D7h,0D8h,0D9h,0DAh
		db	 21h, 22h, 23h, 24h, 25h, 0Ch
		db	0DBh,0B5h,0DCh,0DDh,0DEh
		db	0Ch, ',-./0', 0Ch, 'j'
		db	 9Ch, 9Dh,0DFh,0E0h, 0Ch, 69h
loc_61:
		cmp	[bp+si],di
		cmp	di,[si]
		or	al,0Ch
		db	0C0h,0E1h,0E2h,0C1h, 8Ah, 71h
loc_62:
		inc	bp
		inc	si
		inc	di
		jc	loc_65			; Jump if carry Set
		dec	dx
		dec	bx
		dec	sp
		dec	bp
		dec	si
		jns	loc_66			; Jump if not sign
		jnp	loc_64			; Jump if not parity
		jcxz	loc_61			; Jump if cx=0
		xchg	sp,ax
		xchg	bp,ax
		xchg	si,ax
		sub	ds:dialog_tip_str[bx],dl
		sub	al,2Dh			; '-'
		db	 2Eh,0E5h,0E6h,0E7h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah,0E8h,0E9h,0EAh,0EBh,0A4h
		db	0A5h,0A6h,0A7h,0ECh,0EDh, 45h
		db	 46h,0EEh,0EFh,0F0h,0F1h,0F2h
		db	0F3h,0F4h,0F5h,0F6h,0F7h,0F8h
		db	0F9h, 24h, 25h, 94h, 95h, 96h
		db	 28h, 97h, 98h
loc_63:
		cwd				; Word to double word
		sub	al,2Dh			; '-'
		db	 2Eh, 2Fh, 30h,0E7h, 9Bh, 9Ch
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h
		db	 3Ah,0FAh,0FBh,0EAh,0EBh,0A4h
		db	0A5h,0A6h,0A7h,0ECh,0EDh
loc_64:
		inc	bp
		inc	si
		cld				; Clear direction
		std				; Set direction flag
                           lock	dec	byte ptr [bp+di+4Ch]
		dec	bp
		dec	si
		idiv	bh			; al, ah rem = ax/reg
		jnp	$+54h			; Jump if not parity
		add	byte ptr [bx+si+20h],10h
		or	[si],al
		add	[di],dx
		inc	cx
		push	dx
loc_65:
		dec	bp
		dec	di
		push	dx
		db	 2Eh, 47h, 52h, 50h, 00h, 10h
		db	0AFh, 00h, 16h
		db	 57h, 65h
loc_66:
		db	'apon and Armour ShopGo outside', 0
		db	'Repair shield', 0
		db	'Buy weapon', 0
		db	'Bu'
		db	'y shield'
		db	0
		db	'Explain goods'
		db	 00h, 1Dh,0ADh, 2Ch,0ADh, 3Dh
		db	0ADh, 4Ah,0ADh, 59h,0ADh, 6Ch
		db	0ADh, 7Eh,0ADh, 8Ah,0ADh, 9Ch
		db	0ADh,0A9h,0ADh,0B6h,0ADh,0C3h
		db	0ADh
		db	'Training sword', 0
		db	'Wise man\s sword', 0
		db	'Spirit sword', 0
		db	'Knight\s sword', 0
		db	'Illumination sword', 0
		db	'Enchantment sword', 0
		db	'Clay shield', 0
		db	'Wise man\s shield', 0
		db	'Stone shield', 0
		db	'Honor shield', 0
		db	'Light shield', 0
		db	'Titanium Shield', 0
		db	'May I&be of service, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Is there something I&can do'
		db	' for you, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Will there be something els'
		db	'e for you, sir?/'
		db	0FFh, 00h
		db	0Ch, 'Sir, you aren\t carrying a '
		db	'shield -- however, I do have a f'
		db	'ine selection, if you\d like to '
		db	'buy one./'
		db	0FFh, 00h
		db	0Ch, 'Sir, your shield is not in '
		db	'need of repair. How else can I h'
		db	'elp you?/'
		db	0FFh, 00h
		db	0Ch, 'I\ll be glad to repair your'
		db	' shield, sir, for the low price '
		db	'of '
		db	0FFh, 00h
		db	'&golds. Shall I&proceed?'
		db	0FFh, 00h
		db	0Dh, 'I\m sorry sir, you aren\t c'
		db	'arrying enough gold. Perhaps aft'
		db	'er you\ve visited the bank.../'
		db	0FFh, 00h
		db	0Dh, 'Please wait h'
		db	'ere, I\ll only be a moment.'
		db	0FFh, 04h,0FFh, 04h,0FFh, 05h
		db	0FFh, 00h
		db	0Ch, 'The repairs'
		db	' to your armour are comple'
		db	'te. It is now as good as new./'
		db	0FFh, 00h
		db	0Ch, 'Something else for you, sir'
		db	'?/'
		db	0FFh, 01h
		db	'I\ll give you '
		db	0FFh, 00h
		db	'&gol'
		db	'ds on your old w'
		db	'eapon as a trade-in.', 0Dh
		db	0FFh, 00h
		db	0Ch, 'Something else for you, sir'
		db	'?/'
		db	0FFh, 02h
		db	'I\ll give you '
		db	0FFh, 00h
		db	'&go'
		db	'l'
		db	'ds on your old s'
		db	'hield as a trade-in.', 0Dh
		db	0FFh, 00h
		db	0Ch, 'Oh, the '
		db	0FFh, 00h, 3Fh, 2Fh,0FFh, 0Ch
		db	0FFh, 00h
		db	'Will that be all right?'
		db	0FFh, 00h
		db	'That will be '
		db	0FFh, 00h
		db	'&golds./'
		db	0FFh, 00h
		db	0Ch, 'All of my goods are of the '
		db	'highest quality. Which item woul'
		db	'd you like me to tell you a'
		db	 62h, 6Fh, 75h, 74h, 3Fh, 2Fh
		db	0FFh, 06h
		db	 0Ch, 57h
		db	'hich item would you like to know'
		db	' about?/'
		db	0FFh, 49h, 73h
		db	' there another item you would li'
		db	'ke to know about?/'
		db	0FFh
		db	0Ch, 'Thank you, please come agai'
		db	'n.'
		db	 11h,0FFh,0FFh, 0Ch
		db	'If you\re going to wa'
		db	'ste my time, please be on your w'
		db	'ay./'
		db	0FFh, 07h,0FFh, 03h, 11h,0FFh
		db	0FFh
		db	0Ch, 'Uh....../'
		db	0FFh, 00h
		db	0Ch, 'I do not sell that weapon. '
		db	'I haven\t a single one in stock.'
		db	' Please choose another./'
		db	0FFh, 00h
		db	0Ch, 'Well I\ll be... '
		db	0FFh, 04h,0FFh, 04h, 53h, 69h
		db	 72h, 21h, 20h,0FFh, 09h,0FFh
		db	 04h
		db	49h
		db	'sn\t that the crest of honor you'
		db	' bear? Please come in... I mean.'
		db	'..uh... /Might I trade you a kni'
		db	'ght\s sword for it?'
		db	0FFh, 08h
		db	0Ch, 'Oh, I&see. Well, if you cha'
		db	'nge your mind, please come back.'
		db	 11h,0FFh,0FFh, 0Ch
		db	'Oh, thank you, sir! As promised,'
		db	' here is your knight\s sword./'
		db	0FFh, 00h
		db	'Thank you, and please come back '
		db	'soon.'
		db	 11h,0FFh,0FFh,0F6h,0B3h, 9Fh
		db	0B4h, 66h,0B5h,0C9h,0B5h, 4Ch
		db	0B6h,0DBh,0B6h, 0Ch,0B7h,0BBh
		db	0B7h, 3Fh,0B8h,0CAh,0B8h, 58h
		db	0B9h, 0Fh,0BAh
		db	'Well, I\d say this sword is all '
		db	'right for a beginner./You get wh'
		db	'at you pay for./It\s your standa'
		db	'rd, maintenance-free sword. If m'
		db	'oney\s a problem, this one\s for'
		db	' you.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is one is just a bit better than'
		db	' the Training Sword. Once you ge'
		db	't the hang of it, it\s an easy o'
		db	'ne to wield. The price is a bit '
		db	'higher, but you can\t lose on th'
		db	'is one./Why not take it with you'
		db	'?'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh
		db	'u like this one?/A wise choice./'
		db	'This is a high grade product. It'
		db	'\s one of my biggest sellers.'
		db	 11h, 0Ch,0FFh,0FFh, 4Fh, 68h
		db	', I\d be more than happy to tell'
		db	' you about this one./This is a r'
		db	'eal man\s sword. It\ll topple mo'
		db	'nsters in the wink of an eye.'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh
		db	'u\ve got a lot of grit I\d say. '
		db	'This one really packs a punch. A'
		db	' top-of-the-line sword for a top'
		db	'-of-the-line-swordsman. Will you'
		db	' take it?'
		db	 11h, 0Ch,0FFh,0FFh, 49h, 73h
		db	'n\t that the sword you brought i'
		db	'n with you?'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield is small and has limit'
		db	'ed defense capability. It\s not '
		db	'very durable -- unless it\s used'
		db	' with great skill, it won\t last'
		db	' long. It\s better than nothing,'
		db	' I guess.'
		db	 11h, 0Ch,0FFh,0FFh, 57h, 65h
		db	'll, it\s slightly better than th'
		db	'e Clay Shield. Long ago, a well-'
		db	'known hero used it for a short t'
		db	'ime. You could do a lot worse.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is one is more of a general-use '
		db	'shield. It\s not the best one I '
		db	'carry. I can\t really recommend '
		db	'it, I think it will soon be obso'
		db	'lete.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield is in a class by itsel'
		db	'f. It is strong and light and ea'
		db	'sy to use. This is a superior sh'
		db	'ield, the least a brave man shou'
		db	'ld have.'
		db	 11h, 0Ch,0FFh,0FFh, 48h, 6Fh
		db	'! You\ve got quite an eye for th'
		db	'ese things, I see. This shield i'
		db	's not made of common iron. It is'
		db	' made of a magic metal called Ma'
		db	'gane. Against ordinary weapons, '
		db	'it\s unbreakable.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h
		db	'is shield makes the mightiest sw'
		db	'ords seem like paper. It\s light'
		db	' as a feather and hard as a diam'
		db	'ond. Used well, this one will la'
		db	'st you a lifetime.'
		db	 11h, 0Ch,0FFh,0FFh,0B9h,0BAh
		db	0DDh,0BAh, 01h,0BBh, 25h,0BBh
		db	 49h,0BBh, 6Dh,0BBh, 91h,0BBh
		db	0B5h,0BBh,0D9h,0BBh, 00h, 90h
		db	 01h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h, 90h
		db	 5Fh, 00h, 04h, 00h, 00h, 32h
		db	 00h, 00h, 96h, 00h, 00h,0A4h
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 20h
		db	 03h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 32h
		db	 00h, 00h, 96h, 00h, 00h,0A4h
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 20h
		db	 03h, 00h,0DCh, 05h, 00h, 90h
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 96h, 00h, 00h, 4Ch
		db	 09h, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 90h
		db	 01h, 00h,0B8h, 0Bh, 00h, 40h
		db	 15h, 00h, 48h, 26h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 32h, 00h, 00h,0F4h
		db	 06h, 00h, 48h, 26h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h, 90h
		db	 01h, 00h,0B8h, 0Bh, 00h, 98h
		db	 12h, 00h, 24h, 13h, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 32h, 00h, 00h,0F4h
		db	 06h, 00h,0A0h, 1Eh, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h
		db	 00h, 00h,0DCh, 05h, 00h, 48h
		db	 0Dh, 00h,0A0h, 1Eh, 01h,0A8h
		db	 10h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h,0F8h, 16h, 00h,0D0h
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h
		db	 00h, 00h,0DCh, 05h, 00h, 50h
		db	 05h, 00h,0F8h, 16h, 00h,0F0h
		db	 87h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h,0F8h, 16h, 00h, 78h
		db	 28h, 00h, 78h, 9Bh, 00h, 64h
		db	 00h, 00h,0E8h, 03h, 00h, 50h
		db	 05h, 00h, 50h, 0Fh, 00h, 20h
		db	 80h, 00h, 04h, 00h, 00h, 05h
		db	 00h, 00h, 14h, 00h, 00h, 7Ah
		db	 03h, 00h, 50h, 0Fh, 00h,0E8h
		db	 1Ch, 00h, 38h, 7Ch, 00h, 0Ah
		db	 00h, 00h, 64h, 00h, 00h,0A8h
		db	 02h, 00h,0A8h, 07h, 00h, 68h
		db	 74h, 00h, 04h, 00h, 00h, 02h
		db	 00h, 00h, 0Ah, 00h, 00h, 2Ah
		db	 01h, 00h,0A8h, 07h, 00h, 20h
		db	 17h, 00h,0F8h
		db	5Ch
		db	74 dup (0)

seg_a		ends



		end	start
