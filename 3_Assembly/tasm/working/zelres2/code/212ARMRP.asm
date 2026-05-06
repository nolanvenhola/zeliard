
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
;  Connections:
;    Loads:        ARMR.GRP (zelres2 chunk 15h) via cs:[sar_loader_fn] SAR loader
;                  with AL=2 (fill_buffer decode) into chunk_load_buf
;                  (game_seg:8000h).
;    Calls into:   drv_fill_rect, drv_screen_init_a/b, drv_load_msg_header,
;                  drv_frame_commit, drv_ds_copy, drv_return_to_caller,
;                  gfx_set_color_fn (cs:[2004h]), gfx_present_fn (cs:[201Ah]),
;                  gfx_render_scene_fn (cs:[201Ch]), gfx_draw_hud_fn
;                  (cs:[2020h])
;                    (graphics driver dispatch slots)
;                  script_step (cs:[6004h]), script_format_num,
;                  script_display_page, script_take_item, script_give_item,
;                  menu_init_fn (cs:[600Eh]), menu_nav_fn (cs:[6010h]),
;                  menu_render_fn (cs:[6012h])
;                    (script interpreter / menu dispatch slots)
;                  shop_dispatch_a/b/c (CS- and DS-relative jump tables
;                    for buy-weapon, buy-shield, explain-goods paths).
;    Called by:    106TOWN building dispatch when player enters the
;                    weapon/armour shop (loaded as loaded_code_a at
;                    game_seg:3000h via SAR loader, far call).
;    Reads/writes: gvar_script_ip (DS:0FF4Ch) -- chained between sub-scripts
;                  gvar_dlg_pos (DS:0FF54h), gvar_text_x/y, gvar_frame_timer,
;                  gvar_game_seg (CS:0FF2Ch),
;                  player gold word at ds:[shield_max_HP], shop price word at ds:[shield_HP]
;                    (game-segment financial state),
;                  honor-crest flag (mid-game "knight's sword" event check).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in zr2com.inc
; ----------------------------------------------------------------------
gvar_game_seg		equ	0FF2Ch			;* game segment selector word
gvar_sel_row		equ	0FF56h			;* current menu row byte
gvar_sel_flag		equ	0FF57h			;* menu selection flag byte
gvar_sel_xlat		equ	0FF58h			;* menu selection translate byte
gvar_dlg_timer		equ	0FF6Ah			;* dialog timer word

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
chunk_load_buf	equ	8000h			;* temp buffer for loading chunk into game_seg
gfx_set_color_fn	equ	2004h			;* set drawing color/palette for bar
gfx_present_fn		equ	201Ah			;* present / update current frame
gfx_render_scene_fn	equ	201Ch			;* render scene (jmp indirect, end of transaction)
gfx_draw_hud_fn		equ	2020h			;* draw HUD/money panel (bx=pos/al=side)
menu_init_fn		equ	600Eh			;* menu init (cx=rows,si=str tbl)
menu_nav_fn		equ	6010h			;* menu navigate (bl=cur row -> updated bl,CY=cancel)
menu_render_fn		equ	6012h			;* menu render (si=strs,cl=rows,al=color)
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
goods_icon_map		equ	0AC9Ch			;* goods icon index lookup base
explain_dispatch_a	equ	0ACA2h			;* explain-goods text offsets (part A)
explain_dispatch_b	equ	0ACAEh			;* explain-goods text offsets (part B)
weapon_name_offs	equ	0AD05h			;* weapon name table offsets (base for si computation)
shield_name_offs	equ	0AD11h			;* shield name table offsets
explain_text_tbl	equ	0B3DEh			;* explain-goods text address table (per-item)
weapon_dlg_tbl		equ	0BAA7h			;* weapon dialog base table (indexed by equipped slot)
last_menu_choice	equ	0BC21h			;* last menu choice byte
sub_menu_choice_a	equ	0BC22h			;* sub-menu choice A byte
trade_gold_tmp		equ	0BC29h			;* trade-in gold temporary (byte)
trade_gold_buf_hi	equ	0BC2Ch			;* trade-in gold scratch byte
trade_gold_buf_hi2	equ	0BC2Dh			;* trade-in gold scratch byte 2
mouth_anim_A		equ	0BC3Bh			;* mouth anim packed bits A (6 bytes)
mouth_anim_B		equ	0BC41h			;* mouth anim packed bits B (6 bytes)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
cur_weapon_idx		equ	0BBFDh			;* selected weapon slot index byte
cur_weapon_flag		equ	0BBFEh			;* selected weapon flag byte
cur_shield_idx		equ	0BC0Fh			;* selected shield slot index byte
cur_shield_flag		equ	0BC10h			;* selected shield flag byte
trade_active_flag	equ	0BC23h			;* transaction in progress flag
trade_weapon_flag	equ	0BC28h			;* trade/swap weapon flag byte
new_item_flag		equ	0BC2Fh			;* new-item/equip flag byte
new_item_idx		equ	0BC30h			;* new-item slot index byte
weapon_cnt		equ	0BC31h			;* number of weapons for sale byte
shield_cnt		equ	0BC32h			;* number of shields for sale byte
town_npc_state		equ	0C006h			;* town-map NPC/room state byte

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
anim_seq_closed		equ	0AAD0h			;* shopkeeper animation seq (mouth closed)
anim_seq_open		equ	0AB68h			;* shopkeeper animation seq (mouth open)
anim_state_0		equ	0BC24h			;* shopkeeper anim state byte 0
anim_state_1		equ	0BC25h			;* shopkeeper anim state byte 1
anim_state_2		equ	0BC26h			;* shopkeeper anim state byte 2
anim_state_3		equ	0BC27h			;* shopkeeper anim state byte 3

; FORMAT_AND_RUN
;   Format AX/DL (number) into the dialog buffer at 0BC33h (script_format_num),
;   save current script_ip, run the formatted script, then restore script_ip.
FORMAT_AND_RUN	MACRO
		mov	di, 0BC33h
		call	word ptr cs:script_format_num
		mov	si, ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip, 0BC33h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip, si
		ENDM
; FILL_DLG_RECT
;   Fill the dialog rectangle (0FFh) and prep gvar_dlg_pos at 302Eh,
;   then call script_display_page.
FILL_DLG_RECT	MACRO
		mov	bx, 2F2Bh
		mov	cx, 0C19h
		mov	al, 0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos, 302Eh
		call	word ptr cs:script_display_page
		ENDM

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
		call	word ptr cs:[sar_loader_fn]
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
		test	byte ptr ds:crest_glory,0FFh
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
		test	byte ptr ds:[shield_type],0FFh
		jnz	check_change_wallet			; Jump if not zero
		mov	word ptr ds:gvar_script_ip,0AE4Ah
		retn

check_change_wallet:
		mov	ax,word ptr ds:[shield_max_HP]
		sub	ax,word ptr ds:[shield_HP]
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
		FORMAT_AND_RUN
		call	word ptr cs:script_step
		FILL_DLG_RECT
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
		mov	byte ptr ds:[player_gold_hi],dl
		mov	word ptr ds:[player_gold_lo],ax
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
		FORMAT_AND_RUN
		call	word ptr cs:script_step
		mov	byte ptr ds:trade_gold_tmp,0
		mov	word ptr ds:trade_gold_tmp+1,0
		test	byte ptr ds:[equipped_weapon],0FFh
		jz	skip_weapon_swap			; Jump if zero
		mov	al,byte ptr ds:[equipped_weapon]
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
		FORMAT_AND_RUN
		call	word ptr cs:script_step

skip_weapon_swap:
		mov	word ptr ds:gvar_script_ip,0B0EDh
		call	word ptr cs:script_step
		FILL_DLG_RECT
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	weapon_commit			; Jump if carry=0
		retn

weapon_commit:
		mov	word ptr ds:gvar_script_ip,0AE1Ch
		mov	dl,ds:trade_gold_buf_hi
		mov	ax,ds:trade_gold_buf_hi2
		mov	byte ptr ds:[player_gold_hi],dl
		mov	word ptr ds:[player_gold_lo],ax
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
		mov	byte ptr ds:[equipped_weapon],al
		cmp	al,6
		jne	skip_slot_clear			; Jump if not equal
		mov	bl,ds:town_npc_state
		dec	bl
		xor	bh,bh			; Zero register
		and	byte ptr ds:[0D2h][bx],0FBh

skip_slot_clear:
		call	build_mouth_bitmap_a
		mov	ah,byte ptr ds:[equipped_weapon]
		mov	al,4
		call	word ptr cs:[sar_loader_fn]
		mov	al,byte ptr ds:[equipped_weapon]
		mov	bx,18ABh
		jmp	word ptr cs:gfx_render_scene_fn

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
		FORMAT_AND_RUN
		call	word ptr cs:script_step
		mov	byte ptr ds:trade_gold_tmp,0
		mov	word ptr ds:trade_gold_tmp+1,0
		test	byte ptr ds:[shield_type],0FFh
		jz	skip_shield_swap			; Jump if zero
		mov	al,byte ptr ds:[shield_type]
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
		FORMAT_AND_RUN
		call	word ptr cs:script_step

skip_shield_swap:
		mov	word ptr ds:gvar_script_ip,0B0EDh
		call	word ptr cs:script_step
		FILL_DLG_RECT
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	shield_commit			; Jump if carry=0
		retn

shield_commit:
		mov	word ptr ds:gvar_script_ip,0AE1Ch
		mov	dl,ds:trade_gold_buf_hi
		mov	ax,ds:trade_gold_buf_hi2
		mov	byte ptr ds:[player_gold_hi],dl
		mov	word ptr ds:[player_gold_lo],ax
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
		mov	byte ptr ds:[shield_type],al
		call	build_mouth_bitmap_b
		mov	al,byte ptr ds:[shield_type]
		mov	bx,3EA4h
		call	word ptr cs:gfx_draw_hud_fn
		mov	bx,0C61Ch
		xor	al,al			; Zero register
		mov	ch,17h
		call	word ptr cs:gfx_set_color_fn
		mov	bl,byte ptr ds:[shield_type]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:shield_price_tbl[bx]
		mov	word ptr ds:[shield_max_HP],ax
		mov	word ptr ds:[shield_HP],ax
		jmp	word ptr cs:gfx_present_fn
			                        ;* No entry point to code
		push	ds
		db	00h, 50h, 00h		; add [bx+si+0],dl (alt encoding: mod=01 disp8 not mod=00)
; -- Repair-shield price thresholds + inline x86 (orphan handler reached via
;    DS dispatch).  First 8 bytes are 4 thresholds; remainder is x86 code.
armrp_repair_thresholds:
		db	0B4h, 00h, 2Ch, 01h, 2Ch, 01h	; thresholds: 0x00B4(180), 0x012C(300), 0x012C(300)
		db	 58h, 02h,0C6h, 06h, 23h,0BCh	; threshold 0x0258(600); mov byte [BC23]..
		db	 00h,0F6h, 06h, 26h,0BCh,0FFh	; ..,00; test byte [BC26],FF
		db	 74h, 08h,0B0h, 01h,0E8h,0F3h	; jz +8; mov al,01; call rel
		db	 02h,0E8h, 91h, 01h,0BEh,0FDh	; rel hi; call rel; mov si,..
		db	0A6h				; (high byte of si)

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
		mov	ax,word ptr ds:[shield_max_HP]
		mov	word ptr ds:[shield_HP],ax
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
		FILL_DLG_RECT
		mov	word ptr ds:gvar_script_ip,0ADEFh
		jnc	explain_continue			; Jump if carry=0
		retn

explain_continue:
		mov	word ptr ds:gvar_script_ip,0B17Eh
		call	word ptr cs:script_step
		jmp	explain_menu_top

frame_delay		proc	near
		mov	byte ptr ds:gvar_frame_timer,0

frame_delay_loop:
			call	shopkeeper_anim_tick
			cmp	byte ptr ds:gvar_frame_timer,32h	; '2'
			jb	frame_delay_loop			; Jump if below
		retn

frame_delay		endp
		FILL_DLG_RECT
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
		mov	byte ptr ds:[equipped_weapon],4
		mov	byte ptr ds:crest_glory,0
		mov	al,4
		mov	bx,18ABh
		call	word ptr cs:gfx_render_scene_fn
		and	byte ptr ds:[0D6h],0EFh
		or	byte ptr ds:[24h],2
		mov	ah,byte ptr ds:[equipped_weapon]
		mov	al,4
		call	word ptr cs:[sar_loader_fn]
		retn

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

		db	0B0h, 03h,0E9h,0CDh, 00h	; mov al,03; jmp far +00CD (orphan dispatch tail)

clear_menu_rect		proc	near
		mov	bx,2717h
		mov	cx,1C41h
		xor	al,al			; Zero register
		jmp	word ptr cs:drv_fill_rect

clear_menu_rect		endp

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
		call	word ptr cs:[stick_subsample_tick_handler]
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

shopkeeper_anim_tick		endp

render_shopkeeper_frame		proc	near

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

render_shopkeeper_frame		endp

			                        ;* No entry point to code
		add	al,[bx+si-56h]
		push	es
		mov	ss:chunk_load_param[bp+si],ch
		stosb				; Store al to es:[di]
		push	es
; -- shopkeeper_anim_seq tables (2 sequences, A=closed mouth, B=open mouth).
;    Each entry: 6 bytes = (anim_addr_lo, hi, ...). Sequenced by mouth_anim_A/B.
armrp_anim_seq_tbl:
		db	0D8h,0AAh, 02h, 40h,0AAh, 06h	; entry A0: AAD8, anim AA40 + 06 frames
		db	 20h,0ABh, 04h, 58h,0AAh, 04h	; entry A1: AB20 + AA58 + 04 frames
		db	 70h,0ABh, 03h, 58h,0AAh, 05h	; entry A2: AB70 + AA58 + 05 frames
		db	0A0h,0ABh, 08h,0DCh,0ABh, 00h	; entry A3: ABA0 + ABDC + 00
		db	 00h, 00h, 04h, 58h,0AAh, 04h	; entry A4: 00 + 00 + 04 + AA58 + 04 frames
		db	 3Ch,0ACh, 04h, 58h,0AAh, 04h	; entry A5: AC3C + AA58 + 04 frames
		db	 6Ch,0ACh, 00h, 01h, 02h, 03h	; entry A6: AC6C + (00,01,02,03 anim phases)
; -- 26-byte anim phase remap table (0x0..0x19): used by shopkeeper_anim_tick.
armrp_anim_phase_remap:
		db	 01h, 01h, 01h, 01h, 01h, 04h	; phase[0..5]: mostly idle (1) then frame 4
		db	 05h, 06h, 07h, 08h, 09h, 0Ah	; phase[6..11]: frames 5-10
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh	; phase[12..17]: frames 11, 12 (held), 13
		db	 0Eh, 0Fh, 00h, 01h, 02h, 03h	; phase[18..23]: frames 14-15, then loop start
		db	 01h, 01h, 01h, 01h, 01h, 04h	; phase[24..25] + 4 extra (idle pad)
		db	 05h, 06h, 07h, 08h, 09h, 0Ah	; (extension cont)
		db	 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Dh	; (extension cont)
		db	 0Eh, 0Fh, 10h, 11h, 12h, 13h	; (extension cont, frames 16-19)
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h	; (extension cont, frames 20-23)
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 8Fh	; (extension cont, frames 24-27 + tile 8F)
		db	 90h, 1Eh, 91h, 92h, 93h, 21h	; (extension cont)
		db	 22h, 23h, 10h, 11h, 12h, 13h	; (extension cont)
		db	 14h, 15h, 16h, 0Ch, 0Ch, 17h	; (extension cont)
		db	 18h, 19h, 1Ah, 1Bh, 0Ch, 1Ch	; (extension cont)
		db	 1Dh, 1Eh, 1Fh			; (extension end)
		db	' ', 0Ch, '!"#$'
		db	'%', 0Ch, '&', 27h, '()*+,-./0123'
		db	'456789:;<=>?@ABCDEFGHIJKLMNOPQRP'
		db	'QPQPQST'
; -- Sub-frame tile data (variant 1) for shopkeeper anim.
		db	 10h, 11h, 12h, 13h, 55h, 56h	; row 0 cols 0-5
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h	; row 0 cols 6-11
		db	 1Ah, 1Bh, 0Ch, 1Ch		; row 1 partial (4 tiles)
		db	'XYZ[', 0Ch, '!"#$'			; row 1 ASCII glyphs
		db	'%', 0Ch, '\]^_`a,-./0bcdefghi9:;'	; row 2 ASCII glyphs
		db	'<jklmnopqEFGrstuvwxyz{R'	; row 3 ASCII glyphs
; -- Sub-frame tile data (variant 2) for shopkeeper anim.
		db	 10h, 11h, 12h, 13h, 55h, 56h	; row 0 cols 0-5
		db	 57h, 0Ch, 0Ch, 17h, 18h, 19h	; row 0 cols 6-11
		db	 1Ah, 1Bh, 0Ch, 1Ch		; row 1 partial
		db	'XYZ[', 0Ch, '!"#$'			; row 1 ASCII glyphs
		db	'%', 0Ch, '|]^_}~,-./0j'		; row 2 ASCII glyphs
		db	 80h, 81h, 82h, 83h, 84h, 85h	; row 3 tile glyphs (80-85)
		db	 69h, 39h, 3Ah, 3Bh, 3Ch, 0Ch	; row 3 cont
		db	 7Fh, 86h, 87h, 88h, 89h, 8Ah	; row 3 cont
		db	'qEFGrsJKLMNyz{R]'			; row 4 ASCII glyphs
		db	 81h, 5Dh, 81h, 5Dh, 81h, 8Dh	; row 5 tile glyphs (alternating 81/5D pattern)
		db	 8Eh, 24h, 25h, 94h, 95h, 96h	; row 5 cont
		db	 28h, 97h, 98h, 99h, 2Ch, 2Dh	; row 6
		db	 2Eh, 2Fh, 30h, 9Ah, 9Bh, 9Ch	; row 6 cont
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h	; row 7
		db	 3Ah, 3Bh, 3Ch,0A2h,0A3h,0A4h	; row 7 cont
		db	0A5h,0A6h,0A7h,0A8h,0A9h, 45h	; row 8
		db	 46h, 47h, 72h,0AAh,0ABh, 4Bh	; row 8 cont
		db	 4Ch, 4Dh, 4Eh,0ACh,0ADh, 7Bh	; row 9
		db	 52h, 1Ah, 1Bh, 0Ch,0AEh,0AFh	; row 9 cont
		db	 1Eh, 91h,0B0h,0B1h, 21h, 22h	; row 10
		db	 23h, 24h,0B2h,0B3h,0B4h,0B5h	; row 10 cont
		db	0B6h, 97h,0B7h,0B8h,0B9h, 2Dh	; row 11
		db	 2Eh, 2Fh,0BAh,0BBh,0BCh, 9Ch	; row 11 cont
		db	 9Dh, 9Eh,0BDh,0BEh,0BFh, 39h	; row 12
		db	 3Ah, 3Bh, 3Ch, 0Ch, 0Ch,0C0h	; row 12 cont
		db	0A5h,0A6h,0C1h, 8Ah		; row 13 (last 4 tiles)
		db	'qEFGrsJKLMNyz{R'
; -- Sub-frame tile data (variant 3+) for shopkeeper anim.
		db	 00h, 01h, 02h,0C2h,0C3h,0C4h	; row a (with C2-C4 mid)
		db	0C5h,0C6h, 01h, 04h, 05h, 06h	; row a cont
		db	 07h, 08h,0C7h,0C8h,0C9h,0CAh	; row b (with C7-CA mid)
		db	0CBh,0CCh,0CDh, 0Dh, 0Eh, 0Fh	; row b cont
		db	 10h, 11h,0CEh,0CFh,0D0h,0D1h	; row c (with CE-D1 mid)
		db	0D2h,0D3h,0D4h			; row c cont (last 3)
		db	 17h, 18h, 19h, 1Ah, 1Bh, 0Ch	; row d
		db	0D5h,0D6h,0D7h,0D8h,0D9h,0DAh	; row d cont (D5-DA)
		db	 21h, 22h, 23h, 24h, 25h, 0Ch	; row e
		db	0DBh,0B5h,0DCh,0DDh,0DEh	; row e cont (DB,B5,DC-DE)
		db	0Ch, ',-./0', 0Ch, 'j'
		db	 9Ch, 9Dh,0DFh,0E0h, 0Ch, 69h	; row f tail (mixed glyphs + CR + 'i')

loc_61:
		cmp	[bp+si],di
		cmp	di,[si]
		or	al,0Ch
		db	0C0h,0E1h,0E2h,0C1h, 8Ah, 71h	; row g (mixed shopkeeper anim glyphs)

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
; -- Sub-frame tile data (variant 4) for shopkeeper anim.
		db	 2Eh,0E5h,0E6h,0E7h, 9Bh, 9Ch	; row a (with E5-E7 mid + 9B,9C)
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h	; row a cont
		db	 3Ah,0E8h,0E9h,0EAh,0EBh,0A4h	; row b (with E8-EB mid)
		db	0A5h,0A6h,0A7h,0ECh,0EDh, 45h	; row b cont
		db	 46h,0EEh,0EFh,0F0h,0F1h,0F2h	; row c (with EE-F2 mid)
		db	0F3h,0F4h,0F5h,0F6h,0F7h,0F8h	; row c cont
		db	0F9h, 24h, 25h, 94h, 95h, 96h	; row d
		db	 28h, 97h, 98h			; row d cont (last 3)

loc_63:
		cwd				; Word to double word
		sub	al,2Dh			; '-'
; -- Sub-frame tile data (variant 5) for shopkeeper anim.
		db	 2Eh, 2Fh, 30h,0E7h, 9Bh, 9Ch	; row a (with E7 mid + 9B,9C)
		db	 9Dh, 9Eh, 9Fh,0A0h,0A1h, 39h	; row a cont
		db	 3Ah,0FAh,0FBh,0EAh,0EBh,0A4h	; row b (with FA,FB mid)
		db	0A5h,0A6h,0A7h,0ECh,0EDh	; row b cont (last 5)

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
; -- ref_armr_grp: chunk-loader reference + title header.
		db	 2Eh, 47h, 52h, 50h, 00h, 10h	; '.GRP',00 + start of title hdr (pos 10 AF)
		db	0AFh, 00h, 16h			; title hdr cont: attr 00, len 16h ('Weapon and Armour Shop')
		db	 57h, 65h			; title text 'We' (start of 'Weapon and Armour Shop')

loc_66:
		db	'apon and Armour ShopGo outside', 0	; title remainder + first menu item
		db	'Repair shield', 0
		db	'Buy weapon', 0
		db	'Bu'
		db	'y shield'
		db	0				; null terminator for 'Buy shield'
		db	'Explain goods'
; -- weapon_dlg_tbl: 12-entry word table -> per-item name strings (weapons + shields).
;    Note: 'Explain goods' is NOT null-terminated; the next byte is the high byte (00) of armrp_item_name_ptrs[0].
;    Indexed by sub-menu choice when displaying the item name in dialog.
armrp_item_name_ptrs:
		db	 00h, 1Dh,0ADh, 2Ch,0ADh, 3Dh	; ptrs: AD1D, AD2C, AD3D
		db	0ADh, 4Ah,0ADh, 59h,0ADh, 6Ch	; ptrs: AD4A, AD59, AD6C
		db	0ADh, 7Eh,0ADh, 8Ah,0ADh, 9Ch	; ptrs: AD7E, AD8A, AD9C
		db	0ADh,0A9h,0ADh,0B6h,0ADh,0C3h	; ptrs: ADA9, ADB6, ADC3
		db	0ADh				; (high byte of last ptr ADC3)
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
; -- armrp_dialog_scripts: shop dialog bytecode.  Control codes:
;    0xFFnn = SCR_END opcode nn; 0x0C = clear/scroll; 0x0D = CR;
;    0x11 = ANIM-prefix; '&' = numeric placeholder; '/' = pause.
		db	'May I&be of service, sir?/'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Is there something I&can do'	; CR + text
		db	' for you, sir?/'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Will there be something els'	; CR + text
		db	'e for you, sir?/'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Sir, you aren\t carrying a '	; CR + text
		db	'shield -- however, I do have a f'
		db	'ine selection, if you\d like to '
		db	'buy one./'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Sir, your shield is not in '	; CR + text
		db	'need of repair. How else can I h'
		db	'elp you?/'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'I\ll be glad to repair your'	; CR + text (repair price prompt)
		db	' shield, sir, for the low price '
		db	'of '
		db	0FFh, 00h			; SCR_END 00 (numeric placeholder)
		db	'&golds. Shall I&proceed?'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Dh, 'I\m sorry sir, you aren\t c'	; CR + text (insufficient funds)
		db	'arrying enough gold. Perhaps aft'
		db	'er you\ve visited the bank.../'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Dh, 'Please wait h'		; CR + text (repair in-progress)
		db	'ere, I\ll only be a moment.'
		db	0FFh, 04h,0FFh, 04h,0FFh, 05h	; SCR_END opcodes 04 + 04 + 05 (delay/anim sequence)
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'The repairs'			; CR + text (repair complete)
		db	' to your armour are comple'
		db	'te. It is now as good as new./'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Something else for you, sir'	; CR + text
		db	'?/'
		db	0FFh, 01h			; SCR_END opcode 01 (weapon trade-in path)
		db	'I\ll give you '
		db	0FFh, 00h			; SCR_END 00 (numeric placeholder)
		db	'&gol'
		db	'ds on your old w'
		db	'eapon as a trade-in.', 0Dh
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Something else for you, sir'	; CR + text
		db	'?/'
		db	0FFh, 02h			; SCR_END opcode 02 (shield trade-in path)
		db	'I\ll give you '
		db	0FFh, 00h			; SCR_END 00 (numeric placeholder)
		db	'&go'
		db	'l'
		db	'ds on your old s'
		db	'hield as a trade-in.', 0Dh
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Oh, the '			; CR + text (item name prompt)
		db	0FFh, 00h, 3Fh, 2Fh,0FFh, 0Ch	; SCR_END 00 + '?', '/', SCR_END marker + CR
		db	0FFh, 00h			; SCR_END opcode 00
		db	'Will that be all right?'
		db	0FFh, 00h			; SCR_END opcode 00
		db	'That will be '
		db	0FFh, 00h			; SCR_END 00 (numeric placeholder)
		db	'&golds./'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'All of my goods are of the '	; CR + text (explain goods intro)
		db	'highest quality. Which item woul'
		db	'd you like me to tell you a'
		db	 62h, 6Fh, 75h, 74h, 3Fh, 2Fh	; 'bout?/'
		db	0FFh, 06h			; SCR_END opcode 06
		db	 0Ch, 57h				; CR + 'W' (start of next prompt)
		db	'hich item would you like to know'
		db	' about?/'
		db	0FFh, 49h, 73h			; SCR_END marker + 'Is' (next prompt start)
		db	' there another item you would li'
		db	'ke to know about?/'
		db	0FFh				; SCR_END marker
		db	0Ch, 'Thank you, please come agai'	; CR + text (farewell)
		db	'n.'
		db	 11h,0FFh,0FFh, 0Ch		; ANIM-prefix + SCR_END terminator + CR
		db	'If you\re going to wa'
		db	'ste my time, please be on your w'
		db	'ay./'
		db	0FFh, 07h,0FFh, 03h, 11h,0FFh	; SCR_END opcodes 07 + 03 + ANIM-prefix + SCR_END
		db	0FFh				; SCR_END marker (terminator)
		db	0Ch, 'Uh....../'			; CR + text (item-not-stocked)
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'I do not sell that weapon. '	; CR + text
		db	'I haven\t a single one in stock.'
		db	' Please choose another./'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'Well I\ll be... '		; CR + text (knight's sword event)
		db	0FFh, 04h,0FFh, 04h, 53h, 69h	; SCR_END 04 + 04 + 'Si'
		db	 72h, 21h, 20h,0FFh, 09h,0FFh	; 'r! ' + SCR_END opcode 09 + SCR_END
		db	 04h				; SCR_END opcode 04 (continued)
		db	49h				; 'I' first char of next phrase
		db	'sn\t that the crest of honor you'
		db	' bear? Please come in... I mean.'
		db	'..uh... /Might I trade you a kni'
		db	'ght\s sword for it?'
		db	0FFh, 08h			; SCR_END opcode 08 (knight-sword trade prompt)
		db	0Ch, 'Oh, I&see. Well, if you cha'	; CR + text (decline)
		db	'nge your mind, please come back.'
		db	 11h,0FFh,0FFh, 0Ch		; ANIM-prefix + SCR_END terminator + CR
		db	'Oh, thank you, sir! As promised,'
		db	' here is your knight\s sword./'
		db	0FFh, 00h			; SCR_END opcode 00
		db	'Thank you, and please come back '
		db	'soon.'
; -- explain_text_tbl: per-item explain-text pointer table (12 weapons/shields).
;    Indexed by sub-menu choice when player picks "Explain goods".
		db	 11h,0FFh,0FFh,0F6h,0B3h, 9Fh	; ANIM + SCR_END terminator + ptrs B3F6, B49F
		db	0B4h, 66h,0B5h,0C9h,0B5h, 4Ch	; ptrs cont: B466, B5C9, B54C
		db	0B6h,0DBh,0B6h, 0Ch,0B7h,0BBh	; ptrs B6DB, B70C, B7BB
		db	0B7h, 3Fh,0B8h,0CAh,0B8h, 58h	; ptrs B73F, B8CA, B958
		db	0B9h, 0Fh,0BAh			; ptrs cont + B90F (last 1.5 ptrs spread)
		db	'Well, I\d say this sword is all '
		db	'right for a beginner./You get wh'
		db	'at you pay for./It\s your standa'
		db	'rd, maintenance-free sword. If m'
		db	'oney\s a problem, this one\s for'
		db	' you.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END terminator + 'Th' (start of next item)
		db	'is one is just a bit better than'
		db	' the Training Sword. Once you ge'
		db	't the hang of it, it\s an easy o'
		db	'ne to wield. The price is a bit '
		db	'higher, but you can\t lose on th'
		db	'is one./Why not take it with you'
		db	'?'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh	; ANIM + CR + SCR_END terminator + 'Yo' (next item)
		db	'u like this one?/A wise choice./'
		db	'This is a high grade product. It'
		db	'\s one of my biggest sellers.'
		db	 11h, 0Ch,0FFh,0FFh, 4Fh, 68h	; ANIM + CR + SCR_END terminator + 'Oh' (next item)
		db	', I\d be more than happy to tell'
		db	' you about this one./This is a r'
		db	'eal man\s sword. It\ll topple mo'
		db	'nsters in the wink of an eye.'
		db	 11h, 0Ch,0FFh,0FFh, 59h, 6Fh	; ANIM + CR + SCR_END terminator + 'Yo' (next item)
		db	'u\ve got a lot of grit I\d say. '
		db	'This one really packs a punch. A'
		db	' top-of-the-line sword for a top'
		db	'-of-the-line-swordsman. Will you'
		db	' take it?'
		db	 11h, 0Ch,0FFh,0FFh, 49h, 73h	; ANIM + CR + SCR_END terminator + 'Is' (next item)
		db	'n\t that the sword you brought i'
		db	'n with you?'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END terminator + 'Th' (start of next item)
		db	'is shield is small and has limit'
		db	'ed defense capability. It\s not '
		db	'very durable -- unless it\s used'
		db	' with great skill, it won\t last'
		db	' long. It\s better than nothing,'
		db	' I guess.'
		db	 11h, 0Ch,0FFh,0FFh, 57h, 65h	; ANIM + CR + SCR_END terminator + 'We' (next item)
		db	'll, it\s slightly better than th'
		db	'e Clay Shield. Long ago, a well-'
		db	'known hero used it for a short t'
		db	'ime. You could do a lot worse.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END terminator + 'Th' (start of next item)
		db	'is one is more of a general-use '
		db	'shield. It\s not the best one I '
		db	'carry. I can\t really recommend '
		db	'it, I think it will soon be obso'
		db	'lete.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END terminator + 'Th' (start of next item)
		db	'is shield is in a class by itsel'
		db	'f. It is strong and light and ea'
		db	'sy to use. This is a superior sh'
		db	'ield, the least a brave man shou'
		db	'ld have.'
		db	 11h, 0Ch,0FFh,0FFh, 48h, 6Fh	; ANIM + CR + SCR_END terminator + 'Ho' (next item)
		db	'! You\ve got quite an eye for th'
		db	'ese things, I see. This shield i'
		db	's not made of common iron. It is'
		db	' made of a magic metal called Ma'
		db	'gane. Against ordinary weapons, '
		db	'it\s unbreakable.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END terminator + 'Th' (start of next item)
		db	'is shield makes the mightiest sw'
		db	'ords seem like paper. It\s light'
		db	' as a feather and hard as a diam'
		db	'ond. Used well, this one will la'
		db	'st you a lifetime.'
		db	 11h, 0Ch,0FFh,0FFh,0B9h,0BAh	; ANIM + CR + SCR_END term + start of price ptr table (BAB9)
; -- shield_price_tbl: 12-entry word table -> per-item price/stat record pointers.
;    Indexed by sub-menu choice (weapon 0-5, shield 0-5).
armrp_price_record_ptrs:
		db	0DDh,0BAh, 01h,0BBh, 25h,0BBh	; ptrs: BADD, BB01, BB25
		db	 49h,0BBh, 6Dh,0BBh, 91h,0BBh	; ptrs: BB49, BB6D, BB91
		db	0B5h,0BBh,0D9h,0BBh, 00h, 90h	; ptrs: BBB5, BBD9 + start of record 0 (price 9000h)
; -- 12 item price/stat records (24 bytes each).  Each record holds buy/sell/repair
;    prices for one weapon or shield variant.  Format is 8 entries of 3-byte LE values.
armrp_price_records:
; Record 0 (Training sword)
		db	 01h, 00h,0DCh, 05h, 00h, 90h	; entries 0-1
		db	 1Ah, 00h, 48h, 26h, 01h, 90h	; entries 2-3
		db	 5Fh, 00h, 04h, 00h, 00h, 32h	; entries 4-5
		db	 00h, 00h, 96h, 00h, 00h,0A4h	; entries 6-7 (start)
; Record 1 (Wise man's sword)
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h	; entries 0-1
		db	 39h, 00h, 78h, 9Bh, 00h, 20h	; entries 2-3
		db	 03h, 00h,0DCh, 05h, 00h, 90h	; entries 4-5
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h	; entries 6-7
; Record 2 (Spirit sword)
		db	 10h, 00h, 04h, 00h, 00h, 32h	; entries 0-1
		db	 00h, 00h, 96h, 00h, 00h,0A4h	; entries 2-3
		db	 0Bh, 00h, 48h, 26h, 00h,0D0h	; entries 4-5
		db	 39h, 00h, 78h, 9Bh, 00h, 20h	; entries 6-7
; Record 3 (Knight's sword)
		db	 03h, 00h,0DCh, 05h, 00h, 90h	; entries 0-1
		db	 1Ah, 00h, 48h, 26h, 01h,0A8h	; entries 2-3
		db	 10h, 00h, 04h, 00h, 00h, 05h	; entries 4-5
		db	 00h, 00h, 96h, 00h, 00h, 4Ch	; entries 6-7
; Record 4 (Illumination sword)
		db	 09h, 00h, 48h, 26h, 00h,0D0h	; entries 0-1
		db	 39h, 00h, 78h, 9Bh, 00h, 90h	; entries 2-3
		db	 01h, 00h,0B8h, 0Bh, 00h, 40h	; entries 4-5
		db	 15h, 00h, 48h, 26h, 01h,0A8h	; entries 6-7
; Record 5 (Enchantment sword)
		db	 10h, 00h, 04h, 00h, 00h, 05h	; entries 0-1
		db	 00h, 00h, 32h, 00h, 00h,0F4h	; entries 2-3
		db	 06h, 00h, 48h, 26h, 00h,0D0h	; entries 4-5
		db	 39h, 00h, 78h, 9Bh, 00h, 90h	; entries 6-7
; Record 6 (Clay shield)
		db	 01h, 00h,0B8h, 0Bh, 00h, 98h	; entries 0-1
		db	 12h, 00h, 24h, 13h, 01h,0A8h	; entries 2-3
		db	 10h, 00h, 04h, 00h, 00h, 05h	; entries 4-5
		db	 00h, 00h, 32h, 00h, 00h,0F4h	; entries 6-7
; Record 7 (Wise man's shield)
		db	 06h, 00h,0A0h, 1Eh, 00h,0D0h	; entries 0-1
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h	; entries 2-3
		db	 00h, 00h,0DCh, 05h, 00h, 48h	; entries 4-5
		db	 0Dh, 00h,0A0h, 1Eh, 01h,0A8h	; entries 6-7
; Record 8 (Stone shield)
		db	 10h, 00h, 04h, 00h, 00h, 05h	; entries 0-1
		db	 00h, 00h, 14h, 00h, 00h, 7Ah	; entries 2-3
		db	 03h, 00h,0F8h, 16h, 00h,0D0h	; entries 4-5
		db	 39h, 00h, 78h, 9Bh, 00h,0C8h	; entries 6-7
; Record 9 (Honor shield)
		db	 00h, 00h,0DCh, 05h, 00h, 50h	; entries 0-1
		db	 05h, 00h,0F8h, 16h, 00h,0F0h	; entries 2-3
		db	 87h, 00h, 04h, 00h, 00h, 05h	; entries 4-5
		db	 00h, 00h, 14h, 00h, 00h, 7Ah	; entries 6-7
; Record 10 (Light shield)
		db	 03h, 00h,0F8h, 16h, 00h, 78h	; entries 0-1
		db	 28h, 00h, 78h, 9Bh, 00h, 64h	; entries 2-3
		db	 00h, 00h,0E8h, 03h, 00h, 50h	; entries 4-5
		db	 05h, 00h, 50h, 0Fh, 00h, 20h	; entries 6-7
; Record 11 (Titanium Shield)
		db	 80h, 00h, 04h, 00h, 00h, 05h	; entries 0-1
		db	 00h, 00h, 14h, 00h, 00h, 7Ah	; entries 2-3
		db	 03h, 00h, 50h, 0Fh, 00h,0E8h	; entries 4-5
		db	 1Ch, 00h, 38h, 7Ch, 00h, 0Ah	; entries 6-7
; Record 12 (extra slot)
		db	 00h, 00h, 64h, 00h, 00h,0A8h	; entries 0-1
		db	 02h, 00h,0A8h, 07h, 00h, 68h	; entries 2-3
		db	 74h, 00h, 04h, 00h, 00h, 02h	; entries 4-5
		db	 00h, 00h, 0Ah, 00h, 00h, 2Ah	; entries 6-7
; Record 13 (extra slot)
		db	 01h, 00h,0A8h, 07h, 00h, 20h	; entries 0-1
		db	 17h, 00h,0F8h			; entry 2 + start of trailing pad
		db	5Ch				; '\' final byte of last entry
		db	74 dup (0)			; module trailing padding

seg_a		ends

		end	start
