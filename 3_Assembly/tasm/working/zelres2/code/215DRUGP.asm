
PAGE  59,132

;==========================================================================
;
;  215DRUGP - Witchcraft Implement Shop (DRUG.GRP)
;
;  Shop module for the magic-potion/witchcraft vendor. Player can Buy,
;  Sell, or Get description of 8 magic items (Ken'ko Potion, Juu-en
;  Fruit, Elixir of Kashi, Chikara Powder, Magia Stone, Holy Water of
;  Acero, Sabre Oil, Kioku Feather), or Go outside.
;
;  Runs script bytecode: cs:[6004] reads the next command byte, then
;  jumps through the command-dispatch table at shop_cmd_tbl.
;
;  Module loads at game_seg:0A000h in DS/CS.
;
;  Connections:
;    Loads:        DRUG.GRP (zelres2 chunk 18h) via cs:[10Ch] SAR loader
;                  with AL=2 (fill_buffer decode) into game_seg:8000h.
;    Calls into:   drv_fill_rect, drv_screen_init_a/b, drv_load_msg_header,
;                  drv_frame_commit, drv_ds_copy, drv_return_to_caller
;                    (graphics driver dispatch slots, cs:[2000h..])
;                  script_step (cs:[6004h]), script_format_num (cs:[6006h]),
;                  script_display_page (cs:[6008h]), script_take_item
;                  (cs:[600Ah]), script_give_item (cs:[600Ch]),
;                  menu_show_list (cs:[6010h]), menu_init (cs:[6012h])
;                    (script interpreter / menu dispatch slots)
;                  shop_cmd_tbl (DS-resident) -- per-menu-option opcode
;                    dispatch table populated by town dispatcher.
;    Called by:    106TOWN building dispatch when player enters the
;                    witchcraft shop (loaded as loaded_code_a at
;                    game_seg:3000h, entered through far call).
;    Reads/writes: gvar_script_ip (DS:0FF4Ch) -- chained between sub-scripts
;                    (welcome / buy / sell / describe / goodbye)
;                  gvar_dlg_pos (DS:0FF54h), gvar_text_x/y, gvar_timer_word,
;                  cur_shop_id (DS:0C006h, set by caller from 1..8 selecting
;                    the witchcraft vendor), inventory_list (DS:0FF58h),
;                  player gold word at DS:[86h], gvar_game_seg (DS:0FF2Ch).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; --- External addresses (outside module) -----------------------------------
; Driver functions at cs:[2000h..2044h] (set up by loader, same for all
; shop modules 210-217).

; drv_load_msg_header (2010h) defined in zr2com.inc -- was gfx_show_sprite

; Game API (cs:[6004..6012]) script/menu subsystem.
;   script_format_num, script_display_page, script_take_item, script_give_item
;   defined in zr2com.inc.
menu_show_list		equ	6010h		;* show menu (bl=idx) -> CF if cancel
menu_init		equ	6012h		;* init menu (bx=pos, di=buffer, cl=n, al=start)

; Game-segment global variables (game_seg:0FFxx, accessed via DS).
;   gvar_frame_timer, gvar_script_ip, gvar_text_x, gvar_text_y,
;   gvar_timer_word, gvar_dlg_cols, gvar_dlg_rows, gvar_dlg_pos
;   defined in zr2com.inc.

gvar_game_seg		equ	0FF2Ch		;* game data segment selector
menu_start_idx		equ	0FF56h		;* menu start index (byte)
flag_buy_mode		equ	0FF57h		;* 0FFh=buy mode, 0=sell/describe
inventory_list		equ	0FF58h		;* live inventory slot buffer (5 bytes)
menu_col_width		equ	0FF68h		;* menu column width (word)
menu_row_count		equ	0FF6Ah		;* menu row count (word)

; Current-shop selector (set by caller before entry).
cur_shop_id		equ	0C006h		;* current shop index (1-based)

; --- Internal module labels (CS-relative = module_offset + 0A000h) ---------
; The module is loaded at game_seg:0A000h, so cs:0A0xxh addresses map to
; module offset 0xxxh. The labels below are used with cs: overrides.

shop_cmd_tbl		equ	0A0C3h		;* command dispatch table (word array @ 0xC3)
shop_inv_bitmasks	equ	0A0C9h		;* inventory bitmasks @ data_4 (0xC9)
shop_subtitle_tbl	equ	0A494h		;* item subtitle/text lookup @ 0x494
banner_glyph_tbl	equ	0A5E4h		;* shop banner glyph-code table @ 0x5E4
shop_entry_init		equ	0A644h		;* shop entry-byte (module header byte) @ 0x644
price_gfx_tbl		equ	0A69Ch		;* item price/stat glyph table @ 0x69C
greet_str_tbl		equ	0A745h		;* greeting string table (word array) @ 0x745
desc_script_tbl		equ	0AB3Ah		;* item description script-ptr table @ 0xB3A

; RAM buffers at end of module (shared with the module's padding).
item_name_tbl		equ	0B08Ah		;* item name-offset table @ 0x108A
item_data_tbl		equ	0B10Ch		;* item data-record offset table @ 0x110C
item_data_records	equ	0B11Eh		;* item data records (9 items ?? 24 bytes)
shop_inv_state		equ	0B1F6h		;* shop inventory state (24 bytes RAM)

; Working state in padding area (data after inventory state).
inv_bit_count		equ	0B20Eh		;* count of set inventory bits
inv_slot_tbl		equ	0B20Fh		;* 8 inventory slot indices
timer_dispatch		equ	0B217h		;* timer dispatch flag (reset at start)
sel_item_idx		equ	0B218h		;* currently-selected item idx
item_anim_phase		equ	0B219h		;* item-name animation phase counter
item_anim_set		equ	0B21Ah		;* item-name animation set (0-2)
item_price_dl		equ	0B21Bh		;* saved item price high byte (dl)
item_price_ax		equ	0B21Ch		;* saved item price low word (ax)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

zr2_15		proc	far

start:
		adc	al,es:[bx+si]
		add	[si],al
		mov	al,ds:shop_entry_init
		mov	es,ds:gvar_game_seg
		mov	di,8000h
		mov	si,0A811h
		mov	al,2
		call	word ptr cs:data_5
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:drv_ds_copy
		pop	ds
		mov	byte ptr ds:gvar_text_x,0
		mov	byte ptr ds:gvar_text_y,0
		mov	byte ptr ds:timer_dispatch,0
		call	word ptr cs:drv_screen_init_a
		call	word ptr cs:drv_screen_init_b
		mov	si,0A81Ch
		call	word ptr cs:drv_load_msg_header
		call	wizard_process_loop
		push	cs
		pop	es
		mov	bl,ds:cur_shop_id
		dec	bl
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:item_data_tbl[bx]
		mov	di,shop_inv_state
		mov	cx,0Ch
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		call	wizard_process_loop_3
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_script_ip,0A86Bh

loc_2:
			call	word ptr cs:script_step
			cmp	al,0FFh
			je	loc_3			; Jump if equal
			call	wizard_func_2
			jmp	short loc_2

loc_3:
		jmp	word ptr cs:drv_return_to_caller

zr2_15		endp

wizard_process_loop		proc	near
		mov	si,offset data_4
		mov	al,ds:cur_shop_id
		dec	al
		xor	ah,ah			; Zero register
		add	si,ax
		mov	dl,[si]
		push	cs
		pop	es
		mov	di,inv_slot_tbl
		xor	dh,dh			; Zero register
		mov	cx,8

locloop_4:
			add	dl,dl
			jnc	loc_5			; Jump if carry=0
			mov	al,cl
			neg	al
			add	al,8
			stosb				; Store al to es:[di]
			inc	dh

loc_5:
			loop	locloop_4		; Loop if cx > 0

		mov	ds:inv_bit_count,dh
		retn

wizard_process_loop		endp

wizard_func_2		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:shop_cmd_tbl[bx]	;*

wizard_func_2		endp

; -- shop_cmd_tbl: word array (8 entries) of cmd-handler offsets, indexed by
;    next script byte * 2.  Sourcer mis-decoded entries 1-2 as data_4 + raw db.
		db	0D5h,0A0h			; cmd 0 -> 0xA0D5 (entry sentinel/nop)
data_4		db	0EBh				; cmd 1 lo (-> 0xA0EB) (also alias for data_4 ptr)
		db	0A0h, 0Ch,0A1h, 8Dh,0A1h,0AAh	; cmd 1 hi + cmd 2/3 (A10C, A18D) + cmd 4 lo (AA)
		db	0A1h, 00h,0A3h,0BAh,0A4h, 00h	; cmd 4 hi (A1AA) + cmd 5 (A300) + cmd 6 (A4BA) + cmd 7 lo
		db	0A1h, 06h,0A1h,0C6h, 06h, 1Ah	; cmd 7 hi + cmd 8 (A106) + start of 'mov [FF1A],imm' opcode
		db	0FFh, 00h			; (operand cont. + imm value)

loc_6:
			call	wizard_multiply
			cmp	byte ptr ds:gvar_frame_timer,50h	; 'P'
			jb	loc_6			; Jump if below
		mov	si,greet_str_tbl
		call	wizard_scan_loop
		retn
		db	0C6h, 06h, 1Ah,0FFh, 00h	; mov byte [FF1A],00 (gvar_frame_timer reset)

loc_7:
			call	wizard_multiply
			cmp	byte ptr ds:gvar_frame_timer,50h	; 'P'
			jb	loc_7			; Jump if below
		mov	si,0A74Fh
		jmp	loc_34
			                        ;* No entry point to code
		mov	si,0A759h
		jmp	loc_34
; -- Inline x86 code (orphan handler region 0x202..0x2BC).
;    Reached only via DS-resident dispatch + indirect-call patches; Sourcer
;    decodes most of it as data.  Keep as raw bytes with running comments.
drugp_orphan_handlers:
		db	0BEh, 61h			; mov si,xxxx (operand split across data_5 below)
data_5		dw	0E9A7h				; (continuation: si=A961 + jmp far via cs:[10C])
		db	0FCh, 05h,0E8h,0A3h, 04h,0BBh	; cld; .. ; call rel; mov bx,..
		db	 22h, 27h,0B9h, 2Dh, 1Ch,0B0h	; bx=2722; mov cx,1C2D; mov al,..
		db	0FFh, 2Eh,0FFh, 16h, 00h, 20h	; FF; call cs:[2000] (drv_fill_rect)
		db	0C7h, 06h, 54h,0FFh, 25h, 27h	; mov word [FF54],2725 (gvar_dlg_pos)
		db	0C6h, 06h, 52h,0FFh, 04h,0C6h	; mov byte [FF52],04 (gvar_dlg_cols)
		db	 06h, 53h,0FFh, 04h,0B9h, 04h	; mov byte [FF53],04 (gvar_dlg_rows); cx=4
		db	 00h,0BEh, 39h,0A8h, 2Eh,0FFh	; (cx hi); mov si,A839; call cs:..
		db	 16h, 0Eh, 60h,0C6h, 06h, 56h	; ...[600E] (show_menu_items); mov [FF56],..
		db	0FFh, 00h, 8Ah, 1Eh, 17h,0B2h	; ..,00; mov bl,[B217] (timer_dispatch)
		db	 2Eh,0FFh, 16h, 10h, 60h, 73h	; call cs:[6010] (menu_show_list); pushf; jnc +2
		db	 02h, 32h,0DBh, 88h, 1Eh, 17h	; (rel); xor bl,bl; mov [B217],bl
		db	0B2h, 32h,0FFh, 03h,0DBh,0FFh	; ..,bx; xor bh,bh; add bx,bx; jmp far
		db	0A7h, 55h,0A1h, 5Dh,0A1h, 67h	; jmp tbl entries: A155, A15D, A167
		db	0A1h, 6Eh,0A1h, 86h,0A1h,0E8h	; ...A16E, A186; call rel
		db	 52h, 04h,0C7h, 06h, 4Ch,0FFh	; rel +0452; mov word [FF4C] (gvar_script_ip)
		db	 0Eh,0ABh,0C3h,0C7h, 06h, 4Ch	; ..,AB0E; retn; mov word [FF4C],..
		db	0FFh, 8Ch,0A8h,0C3h,0E8h, 2Bh	; ..,A88C; retn; call rel
		db	 03h,0C7h, 06h, 4Ch,0FFh, 8Dh	; rel +032B; mov word [FF4C],..
		db	0A9h,0F6h, 06h, 53h,0FFh,0FFh	; ..,A98D; test byte [FF53],FF
		db	 74h, 01h,0C3h,0C7h, 06h, 4Ch	; jz +1; retn; mov word [FF4C],..
		db	0FFh, 79h,0AAh,0C3h,0C7h, 06h	; ..,AA79; retn; mov word..
		db	 4Ch,0FFh,0A6h,0AAh,0C3h, 0Eh	; [FF4C],AAA6; retn; push cs
		db	 07h,0BEh, 0Fh,0B2h,0BFh, 58h	; pop es; mov si,B20F (inv_slot_tbl); mov di,..
		db	0FFh,0B9h, 08h, 00h,0F3h,0A4h	; ..,FF58; mov cx,8; rep movsb
		db	0A0h, 0Eh,0B2h,0A2h, 53h,0FFh	; mov al,[B20E]; mov [FF53],al (inv_bit_count)
		db	0C6h, 06h, 56h,0FFh, 00h,0C6h	; mov byte [FF56],00; mov byte..
		db	 06h, 18h,0B2h, 00h,0A0h, 0Eh	; ..[B218],00 (sel_item_idx); mov al,[B20E]
		db	0B2h,0A2h, 53h,0FFh, 3Ch, 03h	; mov [FF53],al; cmp al,3
		db	 72h, 02h,0B0h, 03h		; jb +2; mov al,3

loc_8:
		mov	ds:gvar_dlg_cols,al
		mov	bx,156Eh
		mov	cx,2524h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:flag_buy_mode,0FFh
		mov	word ptr ds:gvar_dlg_pos,1571h
		mov	word ptr ds:menu_row_count,21h
		mov	word ptr ds:menu_col_width,17h
		mov	si,0B08Ah
		mov	di,0B1F6h
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:menu_start_idx
		call	word ptr cs:menu_init
		mov	bl,ds:sel_item_idx
		call	word ptr cs:menu_show_list
		jnc	loc_9			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0A965h
		retn

loc_9:
		mov	ds:sel_item_idx,bl
		mov	al,bl
		add	al,ds:menu_start_idx
		mov	bx,inventory_list
		xlat				; al=[al+[bx]] table
		push	ax
		mov	word ptr ds:gvar_script_ip,0A8C4h
		call	word ptr cs:script_step
		pop	ax
		push	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:item_name_tbl[bx]
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
		mov	si,shop_inv_state
		add	si,ax
		mov	dl,[si]
		mov	ax,[si+1]
		mov	ds:item_price_dl,dl
		mov	ds:item_price_ax,ax
		call	word ptr cs:script_take_item
		pop	bx
		mov	word ptr ds:gvar_script_ip,0A928h
		jc	loc_12			; Jump if carry Set
		push	dx
		push	ax
		mov	si,0A6h
		mov	cx,5

locloop_10:
			test	byte ptr [si],0FFh
			jz	loc_11			; Jump if zero
			inc	si
			loop	locloop_10		; Loop if cx > 0

		pop	ax
		pop	dx
		mov	word ptr ds:gvar_script_ip,0A940h
		retn

loc_11:
		pop	ax
		pop	dx
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		inc	bl
		mov	[si],bl
		mov	word ptr ds:gvar_script_ip,0A8F2h
		call	word ptr cs:script_step
		mov	dl,ds:item_price_dl
		mov	ax,ds:item_price_ax
		mov	di,0B21Eh
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0B21Eh
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si

loc_12:
		call	word ptr cs:script_step
		call	word ptr cs:drv_frame_commit
		mov	word ptr ds:gvar_script_ip,0A909h
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		pushf				; Push flags
		call	wizard_func_4
		popf				; Pop flags
		mov	word ptr ds:gvar_script_ip,0A8A8h
		jc	loc_13			; Jump if carry Set
		retn

loc_13:
		mov	word ptr ds:gvar_script_ip,0A965h
		retn
			                        ;* No entry point to code
		call	wizard_process_loop_2
		mov	byte ptr ds:menu_start_idx,0
		mov	al,ds:gvar_dlg_rows
		cmp	al,2
		jb	loc_14			; Jump if below
		mov	al,2

loc_14:
		mov	ds:gvar_dlg_cols,al
		mov	bx,1778h
		mov	cx,211Ah
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:flag_buy_mode,0
		mov	word ptr ds:gvar_dlg_pos,197Bh
		mov	word ptr ds:menu_row_count,19h
		mov	si,0B08Ah
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:menu_start_idx
		call	word ptr cs:menu_init
		xor	bl,bl			; Zero register
		call	word ptr cs:menu_show_list
		jnc	loc_15			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0A965h
		retn

loc_15:
		mov	ds:sel_item_idx,bl
		mov	word ptr ds:gvar_script_ip,0A8D7h
		call	word ptr cs:script_step
		mov	al,ds:sel_item_idx
		add	al,ds:menu_start_idx
		mov	bx,inventory_list
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:item_name_tbl[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		pop	ax
		mov	cl,3
		mul	cl			; ax = reg * al
		mov	bx,shop_inv_state
		add	bx,ax
		mov	dl,[bx]
		mov	ax,[bx+1]
		shr	dl,1			; Shift w/zeros fill
		rcr	ax,1			; Rotate thru carry
		mov	ds:item_price_dl,dl
		mov	ds:item_price_ax,ax
		push	ax
		push	dx
		mov	word ptr ds:gvar_script_ip,0A9C4h
		call	word ptr cs:script_step
		pop	dx
		pop	ax
		mov	di,0B21Eh
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ip
		push	si
		mov	word ptr ds:gvar_script_ip,0B21Eh
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		mov	bx,3421h
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,3524h
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ip,0A9FEh
		jnc	loc_16			; Jump if carry=0
		retn

loc_16:
		mov	dl,ds:item_price_dl
		mov	ax,ds:item_price_ax
		call	word ptr cs:script_give_item
		mov	word ptr ds:gvar_script_ip,0A9ADh
		call	word ptr cs:script_step
		mov	al,ds:sel_item_idx
		add	al,ds:menu_start_idx
		mov	bx,inventory_list
		xlat				; al=[al+[bx]] table
		inc	al
		mov	si,0A6h
		mov	cx,5

locloop_17:
			cmp	al,[si]
			je	loc_18			; Jump if equal
			inc	si
			loop	locloop_17		; Loop if cx > 0

loc_18:
		mov	byte ptr [si],0
		dec	al
		xor	ah,ah			; Zero register
		push	ax
		mov	al,ds:cur_shop_id
		dec	al
		mov	si,offset data_4
		add	si,ax
		pop	ax
		mov	di,shop_subtitle_tbl
		add	di,ax
		mov	al,[di]
		or	[si],al
		call	word ptr cs:drv_frame_commit
		call	wizard_process_loop_2
		mov	word ptr ds:gvar_script_ip,0A966h
		test	byte ptr ds:gvar_dlg_rows,0FFh
		jnz	loc_19			; Jump if not zero
		retn

loc_19:
		mov	word ptr ds:gvar_script_ip,0AA4Bh
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ip,0A965h
		jnc	loc_20			; Jump if carry=0
		retn

loc_20:
		call	wizard_func_4
		mov	word ptr ds:gvar_script_ip,0A98Dh
		retn
			                        ;* No entry point to code
		add	byte ptr [bx+si+20h],10h
		or	[si],al
		add	al,[bx+di]

wizard_process_loop_2		proc	near
		push	cs
		pop	es
		mov	si,0A6h
		mov	di,inventory_list
		mov	cx,5
		xor	dl,dl			; Zero register

locloop_21:
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jz	loc_22			; Jump if zero
			dec	al
			stosb				; Store al to es:[di]
			inc	dl

loc_22:
			loop	locloop_21		; Loop if cx > 0

		mov	ds:gvar_dlg_rows,dl
		retn

wizard_process_loop_2		endp

			                        ;* No entry point to code
		mov	byte ptr ds:sel_item_idx,0
		mov	byte ptr ds:menu_start_idx,0

loc_23:
		push	cs
		pop	es
		mov	si,inv_slot_tbl
		mov	di,inventory_list
		mov	cx,8
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	al,ds:inv_bit_count
		mov	ds:gvar_dlg_rows,al
		mov	al,ds:gvar_dlg_rows
		cmp	al,2
		jb	loc_24			; Jump if below
		mov	al,2

loc_24:
		mov	ds:gvar_dlg_cols,al
		mov	bx,1778h
		mov	cx,211Ah
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:flag_buy_mode,0
		mov	word ptr ds:gvar_dlg_pos,197Bh
		mov	word ptr ds:menu_row_count,19h
		mov	si,0B08Ah
		mov	cl,ds:gvar_dlg_cols
		xor	ch,ch			; Zero register
		mov	al,ds:menu_start_idx
		call	word ptr cs:menu_init
		mov	bl,ds:sel_item_idx
		call	word ptr cs:menu_show_list
		jnc	loc_25			; Jump if carry=0
		mov	word ptr ds:gvar_script_ip,0A965h
		retn

loc_25:
		mov	ds:sel_item_idx,bl
		mov	word ptr ds:gvar_script_ip,0AACAh
		call	word ptr cs:script_step
		mov	al,ds:sel_item_idx
		add	al,ds:menu_start_idx
		mov	bx,inventory_list
		xlat				; al=[al+[bx]] table
		push	ax
		mov	si,ds:gvar_script_ip
		push	si
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:item_name_tbl[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ip,si
		call	word ptr cs:script_step
		pop	ax
		xor	ah,ah			; Zero register
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:desc_script_tbl[bx]
		mov	ds:gvar_script_ip,ax
		call	word ptr cs:script_step
		mov	word ptr ds:gvar_script_ip,0AAE9h
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		pushf				; Push flags
		call	wizard_func_4
		popf				; Pop flags
		mov	word ptr ds:gvar_script_ip,0A965h
		jnc	loc_26			; Jump if carry=0
		retn

loc_26:
		mov	word ptr ds:gvar_script_ip,0AAA6h
		call	word ptr cs:script_step
		jmp	loc_23

wizard_func_4		proc	near
		mov	bx,2717h
		mov	cx,1D41h
		xor	al,al			; Zero register
		jmp	word ptr cs:drv_fill_rect

wizard_func_4		endp

wizard_process_loop_3		proc	near
		mov	si,banner_glyph_tbl
		mov	bx,717h
		mov	cx,8

locloop_27:
			push	cx
			mov	cx,0Ch

locloop_28:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	locloop_28		; Loop if cx > 0

			sub	bh,0Ch
			add	bl,8
			pop	cx
			loop	locloop_27		; Loop if cx > 0

		retn

wizard_process_loop_3		endp

; -- banner_glyph_tbl: 12-wide x 8-tall tile-glyph map for the wizard shop banner.
drugp_banner_glyph_tbl:
		db	 00h, 01h, 02h, 03h, 04h, 05h	; row 0 cols 0-5
		db	 1Ch, 1Dh, 1Eh, 1Fh, 20h, 21h	; row 0 cols 6-11
		db	 06h, 09h, 7Dh, 7Eh, 7Fh, 80h	; row 1 cols 0-5
		db	 22h, 23h, 24h, 25h, 26h, 27h	; row 1 cols 6-11
		db	 06h, 0Ah, 81h, 82h, 83h, 84h	; row 2 cols 0-5
		db	 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh	; row 2 cols 6-11
		db	 06h, 0Bh, 85h, 86h, 87h, 88h	; row 3 cols 0-5
		db	 2Eh, 2Fh, 30h, 31h, 32h, 33h	; row 3 cols 6-11
		db	 06h, 0Ch, 89h, 8Ah, 8Bh, 8Ch	; row 4 cols 0-5
		db	 34h, 35h, 36h, 37h, 38h, 39h	; row 4 cols 6-11
		db	 06h, 0Dh, 8Dh, 8Eh, 8Fh, 90h	; row 5 cols 0-5
		db	 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh	; row 5 cols 6-11
		db	 07h, 0Eh, 91h, 92h, 93h, 94h	; row 6 cols 0-5
		db	 10h, 11h, 12h, 13h, 14h, 15h	; row 6 cols 6-11
		db	 08h, 0Fh, 95h, 96h, 97h, 98h	; row 7 cols 0-5
		db	 16h, 17h, 18h, 19h, 1Ah	; row 7 cols 6-10
		db	1Bh				; row 7 col 11 (last glyph)

wizard_multiply		proc	near
		cmp	word ptr ds:gvar_timer_word,2
		jae	loc_29			; Jump if above or =
		retn

loc_29:
		mov	word ptr ds:gvar_timer_word,0
		inc	byte ptr ds:item_anim_phase
		cmp	byte ptr ds:item_anim_phase,14h
		jae	loc_30			; Jump if above or =
		retn

loc_30:
		mov	byte ptr ds:item_anim_phase,0
		mov	al,ds:item_anim_set
		inc	al
		cmp	al,3
		jb	loc_31			; Jump if below
		xor	al,al			; Zero register

loc_31:
		mov	ds:item_anim_set,al
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	si,price_gfx_tbl
		add	si,ax
		mov	bx,0D17h
		mov	cx,6

locloop_32:
			push	cx
			mov	cx,6

locloop_33:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	locloop_33		; Loop if cx > 0

			sub	bh,6
			add	bl,8
			pop	cx
			loop	locloop_32		; Loop if cx > 0

		retn

wizard_multiply		endp

; -- price_gfx_tbl: 6-wide x 6-tall x 3-set animated price banner glyphs (108 bytes).
;    Cycled by wizard_multiply (item_anim_set 0..2) to draw the price area.
drugp_price_gfx_tbl:
		db	 1Ch, 1Dh, 1Eh, 1Fh		; price banner set 0 row 0a (4 tiles)
		db	' !"#$'				; price banner set 0 row 0 cont (ASCII 0x20-0x24)
		db	'%&', 27h, '()*+,-./0123456789:;<'	; price banner set 0 rows 1-3 (ASCII)
		db	'=>?_`abcdefghij(klmno.p01R3qrstu'	; price banner set 1 (ASCII variants)
		db	'vwxyz{|@ABCDEFGHIJK(LMNOP.Q01RST'	; price banner set 2a
		db	'UV7WXYZ[\]^'			; price banner set 2 cont

wizard_scan_loop		proc	near

loc_34:
			mov	byte ptr ds:gvar_frame_timer,0
			lodsw				; String [si] to ax
			cmp	ax,0FFFFh
			jne	loc_35			; Jump if not equal
			retn

loc_35:
			push	si
			mov	si,ax
			mov	bx,91Fh
			mov	cx,7

locloop_36:
				push	cx
				mov	cx,4

locloop_37:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	locloop_37		; Loop if cx > 0

				sub	bh,4
				add	bl,8
				pop	cx
				loop	locloop_36		; Loop if cx > 0

loc_38:
				call	wizard_multiply
				cmp	byte ptr ds:gvar_frame_timer,28h	; '('
				jb	loc_38			; Jump if below
			pop	si
			jmp	short loc_34

wizard_scan_loop		endp

; -- greet_str_tbl: 4-entry ptr table + 0xFFFF terminator pairs for greetings,
;    walked by wizard_scan_loop (which draws each 4x7 banner from referenced ptr).
drugp_greet_str_tbl:
		db	 69h,0A7h, 85h,0A7h,0A1h,0A7h	; group 0: ptrs A769, A785, A7A1
		db	0BDh,0A7h,0FFh,0FFh,0BDh,0A7h	; group 0 ptr A7BD + FFFF terminator + group 1 first ptr A7BD
		db	0A1h,0A7h, 85h,0A7h, 69h,0A7h	; group 1 ptrs A7A1, A785, A769
		db	0FFh,0FFh,0BDh,0A7h,0D9h,0A7h	; group 1 terminator + group 2 ptrs A7BD, A7D9
		db	0F5h,0A7h,0FFh,0FFh,0F5h,0A7h	; group 2 ptr A7F5 + FFFF + group 3 first ptr A7F5
		db	0D9h,0A7h,0BDh,0A7h,0FFh,0FFh	; group 3 ptrs A7D9, A7BD + FFFF terminator
; -- 4x7 banner glyph data (referenced via greet_str_tbl entries above).
drugp_greet_banner_a:
		db	 7Dh, 7Eh, 7Fh, 80h, 81h, 82h	; banner A row 0
		db	 83h, 84h, 85h, 86h, 87h, 88h	; banner A row 1
		db	 89h, 8Ah, 8Bh, 8Ch, 8Dh, 8Eh	; banner A row 2
		db	 8Fh, 90h, 91h, 92h, 93h, 94h	; banner A row 3
		db	 95h, 96h, 97h, 98h, 99h, 9Ah	; banner A row 4
drugp_greet_banner_b:
		db	 7Fh, 80h, 9Bh, 9Ch, 83h, 84h	; banner B row 0 (variant: 9B,9C in cols 2-3)
		db	 9Dh, 9Eh, 9Fh, 88h,0A0h,0A1h	; banner B row 1
		db	0A2h,0A3h, 8Dh,0A4h,0A5h,0A6h	; banner B row 2
		db	 91h, 92h, 93h, 94h, 95h, 96h	; banner B row 3
		db	 97h, 98h, 99h, 9Ah, 7Fh, 80h	; banner B row 4 + start of banner C
drugp_greet_banner_c:
		db	 9Bh, 9Ch, 83h, 84h, 9Dh, 9Eh	; banner C row 0 cont
		db	 9Fh, 88h,0A0h,0A1h,0A2h,0A3h	; banner C row 1
		db	 8Dh,0A4h,0A5h,0A6h, 91h, 92h	; banner C row 2
		db	 93h, 94h, 95h, 96h, 97h, 98h	; banner C row 3
		db	 99h, 9Ah,0B8h,0BFh,0A7h,0B3h	; banner C row 4 + start of banner D (B8,BF,A7,B3)
drugp_greet_banner_d:
		db	0B9h,0C0h, 85h,0A9h,0BAh,0C1h	; banner D row 0 cont
		db	0ACh,0B4h,0BBh,0C2h, 8Dh,0B5h	; banner D row 1
		db	0BCh,0C3h, 91h,0B6h,0BDh,0C4h	; banner D row 2
		db	 95h,0B7h,0BEh,0C5h, 99h, 9Ah	; banner D row 3
drugp_greet_banner_e:
		db	0C7h,0C6h,0A7h,0CAh,0C9h,0C8h	; banner E row 0
		db	 85h,0A9h,0CCh,0CBh,0ACh,0B4h	; banner E row 1
		db	0BBh,0C2h, 8Dh,0B5h,0BCh,0C3h	; banner E row 2
		db	 91h,0B6h,0BDh,0C4h, 95h,0B7h	; banner E row 3
		db	0BEh,0C5h, 99h, 9Ah,0CEh,0CDh	; banner E row 4 + start of banner F (CE,CD)
drugp_greet_banner_f:
		db	0A7h,0D1h,0D0h,0CFh, 85h,0A9h	; banner F row 0
		db	0D3h,0D2h,0ACh,0B4h,0BBh,0C2h	; banner F row 1
		db	 8Dh,0B5h,0BCh,0C3h, 91h,0B6h	; banner F row 2
		db	0BDh,0C4h, 95h,0B7h,0BEh,0C5h	; banner F row 3
; -- ref_drug_grp: chunk-loader reference (archive 1, chunk 18h)
ref_drug_grp:
		db	 01h, 18h			; archive=1 (zelres2), chunk=18h
		db	'DRUG.GRP'			; filename
		db	 00h, 0Eh,0AFh, 00h, 19h, 57h	; filename term + title hdr (pos 0E AF, attr 00, len 19h, 'W')
		db	 69h				; 'i' (continuation of title text below)
		db	'tchcraft Implement shopGo outsid'	; title remainder + first menu item
		db	'e', 0
		db	'Buy item', 0
		db	'Sell item', 0
		db	'Description of item', 0
; -- drugp_dialog_scripts: bytecode for shop dialog branches.
;    Control codes: 0xFFnn = SCR_END opcode nn; 0x0C = clear/scroll; 0x0D = CR;
;    0x11 = ANIM-prefix; '&' = numeric placeholder; '/' = pause.
drugp_dialog_scripts:
		db	'Oh... '
		db	0FFh, 00h			; SCR_END opcode 00
		db	'hello, can I help you?/'
		db	0FFh, 02h			; SCR_END opcode 02
		db	0Ch, 'What are you looking for?'	; CR + text
		db	0FFh, 03h			; SCR_END opcode 03
		db	0Ch, 'What are you looking for?'	; CR + text
		db	0FFh, 04h			; SCR_END opcode 04
		db	0Ch, 'You\d like a '		; CR + text
		db	0FFh, 00h, 2Eh, 2Fh,0FFh		; SCR_END 00 + '.', '/', SCR_END marker
		db	0Ch, 'You\d like to sell a '	; CR + text
		db	0FFh, 00h, 2Eh, 2Fh,0FFh		; SCR_END 00 + '.', '/', SCR_END marker
		db	'That will be '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch	; SCR_END 00 + '&gol'
		db	 64h, 73h, 2Eh,0FFh		; 'ds.' + SCR_END marker
		db	0Dh, 'Will there be something els'	; CR + text
		db	'e?'
		db	0FFh				; SCR_END marker
		db	'You have no money, sir.'
		db	0FFh, 59h, 6Fh			; SCR_END marker + 'Yo' (start of next line)
		db	'u can\t po'
		db	'ssibly carry any more./'
		db	0FFh, 02h			; SCR_END opcode 02
		db	0Ch				; CR
		db	'Is ther'
		db	'e something I&can do for you?/'
		db	0FFh, 02h			; SCR_END opcode 02
		db	0Ch, 'What would you like to sell'	; CR + text
		db	'?/'
		db	0FFh, 05h			; SCR_END opcode 05
		db	0Ch, 'Thank you very much./'	; CR + text
		db	0FFh				; SCR_END marker
		db	'I\ll give you '
		db	0FFh, 00h			; SCR_END 00 (numeric placeholder)
		db	'&gol'
		db	'ds fo'
		db	'r that./Will that be all right?'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch				; CR
		db	'Oh, '
		db	'I'
		db	'&see. Well,'
		db	' th'
		db	'at\s the best'
		db	' I&can do. I\m sorr'
		db	'y it is\t satisfactory.'
		db	0FFh, 02h			; SCR_END opcode 02
		db	'Do you ha'
		db	've '
		db	'anyth'
		db	'ing else you\d like to sell?'
		db	0FFh, 0Ch			; SCR_END marker + CR
		db	'You aren\t carrying any magi'
		db	'c items, sir./'
		db	0FFh, 02h			; SCR_END opcode 02
		db	0Ch, 'W'				; CR + text
		db	'hich item can I tell you about?/'
		db	0FFh, 06h			; SCR_END opcode 06
		db	0Ch, 'You\re interested in the '	; CR + text
		db	0FFh, 00h, 2Eh, 2Fh,0FFh		; SCR_END 00 + '.', '/', SCR_END marker
		db	0Ch, 'Can I tell you about anythi'	; CR + text
		db	'ng else?'
		db	0FFh, 0Ch,0FFh, 07h		; SCR_END marker + CR + SCR_END opcode 07
		db	'Thank you, sir. '
		db	0FFh				; SCR_END marker
		db	8, 'Please come again.'
		db	0FFh, 01h, 11h,0FFh,0FFh, 4Ah	; SCR_END 01 + ANIM-prefix + SCR_END terminator + 'J' (start desc tbl)
; -- desc_script_tbl: 8-entry word table of description-script pointers.
;    Indexed by item index (0-7) when player picks "Description of item".
drugp_desc_script_tbl:
		db	0ABh,0C5h,0ABh, 9Ch,0ACh, 39h	; entries: AB4A (above-byte 4A) + ABC5, AC9C, AD39
		db	0ADh,0FDh,0ADh,0A6h,0AEh, 3Dh	; entries: ADFD, AEA6, AF3D
		db	0AFh,0D3h,0AFh			; entries: AFD3
; -- Item descriptions (8 magic items).  Each ends with 11h 0C FFh FFh = ANIM + CR + SCR_END terminator.
; Item 0: Ken'ko Potion
		db	'Well, it\s a special blend of yu'
		db	'nkel fruit and ripodi leaf./It\s'
		db	' low in price and as a mild heal'
		db	'th tonic, it\s perfect.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM-prefix + CR + SCR_END term + 'Th' (start of next item)
; Item 1: Juu-en Fruit
		db	'is is the fruit of the Juu-en tr'
		db	'ee which bears only once every t'
		db	'en years./The price is a bit hig'
		db	'h, but it provides excellent rel'
		db	'ief from wounds and exhaustion -'
		db	'- it\s quite a bit better than t'
		db	'he Ken\ko potion.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM + CR + SCR_END term + 'Th'
; Item 2: Elixir of Kashi
		db	'is potion is made from the broth'
		db	' of mistletoe simmered on the ni'
		db	'ght of a full moon./It restores '
		db	'magical powers. It\s very bitter'
		db	', but the price is low.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM + CR + SCR_END term + 'Th'
; Item 3: Chikara Powder
		db	'is is made from a mixture of the'
		db	' powdered dragon scales and crus'
		db	'hed Wise Man\s Stone steamed for'
		db	' one hundred days./It will fully'
		db	' restore your magical powers. Th'
		db	'e price, however..... is high.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM + CR + SCR_END term + 'Th'
; Item 4: Magia Stone
		db	'is stone protects the aura that '
		db	'living beings exude./It surround'
		db	's the aura to prevent interferen'
		db	'ce from other auras and acts as '
		db	'a protection against enemy attac'
		db	'ks.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM + CR + SCR_END term + 'Th'
; Item 5: Holy Water of Acero
		db	'is is a liquified metal made fro'
		db	'm mercury and iron./If you paint'
		db	' it on a shield weakened by batt'
		db	'le, the shield will regain its o'
		db	'riginal strength.'
		db	 11h, 0Ch,0FFh,0FFh, 48h, 6Dh	; ANIM + CR + SCR_END term + 'Hm' (start of Sabre Oil)
; Item 6: Sabre Oil
		db	'm... I don\t know much about thi'
		db	's one, but I do know that it inc'
		db	'reases the offensive power of a '
		db	'sword./Don\t worry, it hasn\t ki'
		db	'lled anyone yet.'
		db	 11h, 0Ch,0FFh,0FFh, 54h, 68h	; ANIM + CR + SCR_END term + 'Th'
; Item 7: Kioku Feather
		db	'is feather remembers the voice o'
		db	'f the last wise man who spoke to'
		db	' you./If you hold it in your rig'
		db	'ht hand and swing it once, you\l'
		db	'l return to him. It\s never fail'
		db	'ed anyone I know.'
		db	 11h, 0Ch,0FFh,0FFh, 9Ah,0B0h	; ANIM + CR + SCR_END term + start of item_name_tbl (B09A)
; -- item_name_tbl: 9-entry word table -> 8 magic-item name strings + 1 sentinel
drugp_item_name_tbl:
		db	0A8h,0B0h,0B5h,0B0h,0C5h,0B0h	; ptrs B0A8, B0B5, B0C5
		db	0D4h,0B0h,0E0h,0B0h,0F4h,0B0h	; ptrs B0D4, B0E0, B0F4
		db	0FEh,0B0h			; ptr B0FE
		db	4Bh				; 'K' first char of 'Ken\ko Potion' (overlaps name table tail)
		db	'en\ko Potion', 0
		db	'Juu-en Fruit', 0
		db	'Elixir of Kashi', 0
		db	'Chikara Powder', 0
		db	'Magia Stone', 0
		db	'Holy Water of Acero', 0
		db	'Sabre Oil', 0
		db	'Kioku Feather', 0
; -- item_data_tbl: 9-entry word table -> per-item data records (24 bytes each).
drugp_item_data_tbl:
		db	 1Eh,0B1h, 36h,0B1h, 4Eh,0B1h	; ptrs B11E, B136, B14E (item records 0-2)
		db	 66h,0B1h, 7Eh,0B1h, 96h,0B1h	; ptrs B166, B17E, B196 (item records 3-5)
		db	0AEh,0B1h,0C6h,0B1h,0DEh,0B1h	; ptrs B1AE, B1C6, B1DE (item records 6-8)
; -- item_data_records: 9 records x 24 bytes each = 216 bytes.
;    Each record = 8 entries x 3 bytes (3-byte little-endian price/stat values).
drugp_item_data_records:
; Record 0 (8 entries x 3 bytes)
		db	 00h, 32h, 00h, 00h,0F0h, 00h	; entry 0=0x000032(50), entry 1=0x0000F0(240)
		db	 00h, 3Ch, 00h, 00h, 40h, 01h	; entry 2=0x00003C(60), entry 3=0x000140(320)
		db	 00h,0E8h, 03h, 00h, 64h, 00h	; entry 4=0x0003E8(1000), entry 5=0x000064(100)
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h	; entry 6=0x0004B0(1200), entry 7=0x00015E(350)
; Record 1
		db	 00h, 32h, 00h, 00h,0F0h, 00h	; entries 0-1
		db	 00h, 3Ch, 00h, 00h, 40h, 01h	; entries 2-3
		db	 00h,0E8h, 03h, 00h, 64h, 00h	; entries 4-5
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h	; entries 6-7
; Record 2
		db	 00h, 32h, 00h, 00h,0F0h, 00h	; entries 0-1
		db	 00h, 3Ch, 00h, 00h, 40h, 01h	; entries 2-3
		db	 00h,0DCh, 05h, 00h, 64h, 00h	; entry 4=0x0005DC(1500), entry 5=100
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h	; entries 6-7
; Record 3
		db	 00h, 32h, 00h, 00h, 2Ch, 01h	; entry 0=50, entry 1=0x00012C(300)
		db	 00h, 78h, 00h, 00h, 40h, 01h	; entry 2=0x000078(120), entry 3=320
		db	 00h,0DCh, 05h, 00h, 64h, 00h	; entry 4=1500, entry 5=100
		db	 00h,0B0h, 04h, 00h, 5Eh, 01h	; entries 6-7
; Record 4
		db	 00h, 05h, 00h, 00h, 58h, 02h	; entry 0=5, entry 1=0x000258(600)
		db	 00h,0F0h, 00h, 00h,0E0h, 01h	; entry 2=240, entry 3=0x0001E0(480)
		db	 00h,0D0h, 07h, 00h,0C8h, 00h	; entry 4=0x0007D0(2000), entry 5=0x0000C8(200)
		db	 00h,0D0h, 07h, 00h, 5Eh, 01h	; entry 6=2000, entry 7=350
; Record 5
		db	 00h, 05h, 00h, 00h, 58h, 02h	; entries 0-1
		db	 00h,0F0h, 00h, 00h,0E0h, 01h	; entries 2-3
		db	 00h,0D0h, 07h, 00h,0C8h, 00h	; entries 4-5
		db	 00h,0D0h, 07h, 00h, 5Eh, 01h	; entries 6-7
; Record 6
		db	 00h, 05h, 00h, 00h, 84h, 03h	; entry 0=5, entry 1=0x000384(900)
		db	 00h, 68h, 01h, 00h,0C0h, 03h	; entry 2=0x000168(360), entry 3=0x0003C0(960)
		db	 00h,0C4h, 09h, 00h, 90h, 01h	; entry 4=0x0009C4(2500), entry 5=0x000190(400)
		db	 00h, 60h, 09h, 00h, 5Eh, 01h	; entry 6=0x000960(2400), entry 7=350
; Record 7
		db	 00h, 05h, 00h, 00h, 84h, 03h	; entries 0-1
		db	 00h, 68h, 01h, 00h,0C0h, 03h	; entries 2-3
		db	 00h,0C4h, 09h, 00h, 90h, 01h	; entries 4-5
		db	 00h, 60h, 09h, 00h, 5Eh, 01h	; entries 6-7
; Record 8
		db	 00h, 02h, 00h, 00h,0C8h, 00h	; entry 0=2, entry 1=200
		db	 00h, 28h, 00h, 00h, 18h, 01h	; entry 2=0x000028(40), entry 3=0x000118(280)
		db	 00h, 20h, 03h, 00h, 50h, 00h	; entry 4=0x000320(800), entry 5=0x000050(80)
		db	 00h,0E8h, 03h, 00h, 96h		; entry 6=1000, entry 7 (truncated: 96h)
		db	49 dup (0)			; trailing pad to chunk boundary

seg_a		ends

		end	start
