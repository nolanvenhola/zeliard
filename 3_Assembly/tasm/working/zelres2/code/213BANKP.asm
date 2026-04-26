
PAGE  59,132

;==========================================================================
;
;  213BANKP - Bank Dialog Program (zelres2 chunk 15)
;
;  Bank NPC program: "The Bank" menu with options:
;    Go outside / Exchange almas / Deposit money / Withdraw money /
;    Check balance
;  Loaded at gvar_game_seg:loaded_code_a (0x3000) by town.bin when
;  player enters the bank building.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; restored after factoring (consensus value, but not all files agree):
gvar_menu_sel            equ     0C006h

; gvar_timer_word, script_step, script_format_num, script_display_page,
; script_take_item, script_give_item are defined in zr2com.inc.

; The following equates show data references outside the range of the program.

bank_drv_2014	equ	2014h			;*
drv_draw_string	equ	301Ch			;*
drv_set_text_pos	equ	3022h			;*
show_menu_items	equ	600Eh			;*
opcode_dispatch_tbl	equ	0A0B8h			;*
intro_tile_map	equ	0A6C8h			;*
intro_text_ptr_list	equ	0A839h			;*
welcome_text_ptr	equ	0A8BBh			;*
bank_grp_ref	equ	0A8E3h			;*
bank_title_hdr	equ	0A8EEh			;*
exch_denom_in_tbl	equ	0A8FAh			;*
exch_denom_out_tbl	equ	0A8FBh			;*
menu_items_deposit	equ	0A951h			;*
menu_items_withdraw	equ	0A96Dh			;*
entered_flag	equ	0AD1Eh			;*
anim_src_ptr	equ	0AD1Fh			;*
anim_active_flag	equ	0AD21h			;*
anim_frame_counter	equ	0AD22h			;*
checked_balance_flag	equ	0AD23h			;*
goodbye_flag	equ	0AD24h			;*
cur_exch_in	equ	0AD25h			;*
cur_exch_out	equ	0AD26h			;*
script_char_buf	equ	0AD27h			;*
amount_hi	equ	0AD29h			;*
amount_lo	equ	0AD2Ah			;*
amount_max_hi	equ	0AD2Ch			;*
amount_max_lo	equ	0AD2Dh			;*
input_repeat_delay	equ	0AD2Fh			;*
gvar_game_seg	equ	0FF2Ch			;*
; gvar_dlg_cols, gvar_dlg_rows, gvar_dlg_pos defined in zr2com.inc.
gvar_ui_misc_byte	equ	0FF57h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

bank_main		proc	far

start:
		cmp	[di],cl
		add	[bx+si],al
		add	al,0A0h
		sub	byte ptr ds:[68Eh][bx],ah
		sub	al,0FFh
		mov	di,8000h
		mov	si,bank_grp_ref
		mov	al,2
		call	word ptr cs:data_7
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,sprite_buf_ofs
		mov	cx,100h
		call	word ptr cs:drv_ds_copy
		pop	ds
		mov	byte ptr ds:gvar_init_flag_a,0
		mov	byte ptr ds:gvar_init_flag_b,0
		mov	byte ptr ds:entered_flag,0
		call	word ptr cs:drv_screen_init_a
		call	word ptr cs:drv_screen_init_b
		mov	si,bank_title_hdr
		call	word ptr cs:drv_load_msg_header
		call	draw_intro_12x8
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	byte ptr ds:anim_active_flag,0FFh
		mov	word ptr ds:anim_src_ptr,0A773h
		mov	word ptr ds:gvar_script_ptr,0A989h
		call	word ptr cs:script_step
		mov	cx,5

locloop_1:
			push	cx
			mov	byte ptr ds:[0FF1Ah],0
			mov	word ptr ds:gvar_script_ptr,0A98Bh
			call	word ptr cs:script_step

loc_2:
				call	anim_scroll_step
				cmp	byte ptr ds:[0FF1Ah],3Fh	; '?'
				jb	loc_2			; Jump if below
			pop	cx
			loop	locloop_1		; Loop if cx > 0

		mov	byte ptr ds:anim_active_flag,0
		mov	word ptr ds:gvar_script_ptr,0A98Dh

loc_3:
			call	word ptr cs:script_step
			cmp	al,0FFh
			je	loc_4			; Jump if equal
			call	script_opcode_dispatch
			jmp	short loc_3

loc_4:
		jmp	word ptr cs:drv_return_to_caller

bank_main		endp

script_opcode_dispatch		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:opcode_dispatch_tbl[bx]	;*

script_opcode_dispatch		endp

		db	0C0h,0A0h,0D2h,0A0h,0F3h,0A5h
		db	 19h,0A6h,0C6h, 06h, 1Ah,0FFh
		db	 00h, 80h, 3Eh, 1Ah,0FFh, 3Ch
		db	 72h,0F9h,0BEh, 2Fh,0A8h,0E9h
		db	 41h, 07h,0E8h, 4Ah, 05h,0BBh
		db	 1Dh, 28h,0B9h, 37h, 1Ah,0B0h
		db	0FFh, 2Eh,0FFh, 16h, 00h, 20h
		db	0C7h, 06h, 54h,0FFh, 20h, 28h
		db	0C6h, 06h, 52h,0FFh, 05h,0C6h
		db	 06h, 53h,0FFh, 05h,0B9h, 05h
		db	 00h,0BEh, 0Ch,0A9h, 2Eh,0FFh
		db	 16h, 0Eh, 60h,0C6h, 06h, 56h
		db	0FFh, 00h, 8Ah, 1Eh, 1Eh,0ADh
		db	 2Eh,0FFh
data_7		dw	1016h
		db	 60h, 73h, 02h, 32h,0DBh, 88h
		db	 1Eh, 1Eh,0ADh, 32h,0FFh, 03h
		db	0DBh,0FFh,0A7h, 1Bh,0A1h, 25h
		db	0A1h, 4Bh,0A1h, 3Bh,0A2h,0D0h
		db	0A3h, 95h,0A5h,0E8h,0F7h, 04h
		db	0C7h, 06h, 4Ch,0FFh,0D4h,0ACh
		db	0F6h, 06h, 24h,0ADh,0FFh, 74h
		db	 01h,0C3h

loc_5:
		mov	word ptr ds:gvar_script_ptr,0AC9Dh
		test	byte ptr ds:checked_balance_flag,0FFh
		jz	loc_6			; Jump if zero
		retn

loc_6:
		mov	word ptr ds:gvar_script_ptr,0AC5Ah
		retn
			                        ;* No entry point to code
		call	clear_dialog_area
		mov	byte ptr ds:anim_active_flag,0
		mov	si,welcome_text_ptr
		call	draw_banner_8x5
		test	word ptr ds:[8Bh],0FFFFh
		mov	word ptr ds:gvar_script_ptr,0A9B2h
		jnz	loc_7			; Jump if not zero
		retn

loc_7:
		mov	bl,ds:gvar_menu_sel
		xor	bh,bh			; Zero register
		dec	bl
		add	bx,bx
		mov	al,ds:exch_denom_in_tbl[bx]
		mov	ds:cur_exch_in,al
		mov	al,ds:exch_denom_out_tbl[bx]
		mov	ds:cur_exch_out,al
		mov	word ptr ds:gvar_script_ptr,0A9D9h
		call	word ptr cs:script_step
		mov	al,ds:cur_exch_in
		add	al,30h			; '0'
		mov	ds:script_char_buf,al
		mov	word ptr ds:gvar_script_ptr,0AD27h
		call	word ptr cs:script_step
		mov	word ptr ds:gvar_script_ptr,0A9F1h
		call	word ptr cs:script_step
		mov	al,ds:cur_exch_out
		add	al,30h			; '0'
		mov	ds:script_char_buf,al
		mov	word ptr ds:gvar_script_ptr,0AD27h
		call	word ptr cs:script_step
		mov	word ptr ds:gvar_script_ptr,0A9FDh
		call	word ptr cs:script_step
		mov	bx,2F2Bh
		mov	cx,0C19h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,302Eh
		call	word ptr cs:script_display_page
		mov	word ptr ds:gvar_script_ptr,0AA48h
		jnc	loc_8			; Jump if carry=0
		retn

loc_8:
		mov	ax,word ptr ds:[8Bh]
		mov	dl,ds:cur_exch_in
		xor	dh,dh			; Zero register
		sub	ax,dx
		mov	word ptr ds:gvar_script_ptr,0AA1Dh
		jnc	loc_9			; Jump if carry=0
		retn

loc_9:
		push	dx
		call	clear_dialog_area
		pop	dx
		mov	byte ptr ds:checked_balance_flag,0FFh
		mov	word ptr ds:gvar_script_ptr,0AA82h

loc_10:
			xor	cx,cx			; Zero register

loc_11:
				mov	ax,word ptr ds:[8Bh]
				sub	ax,dx
				jnc	loc_12			; Jump if carry=0
				retn

loc_12:
				push	cx
				mov	word ptr ds:[8Bh],ax
				push	dx
				xor	dl,dl			; Zero register
				mov	al,ds:cur_exch_out
				xor	ah,ah			; Zero register
				call	word ptr cs:script_give_item
				call	word ptr cs:drv_frame_commit
				call	word ptr cs:bank_drv_2014
				pop	dx
				pop	cx
				inc	cx
				and	cx,7
				jnz	loc_11			; Jump if not zero
			jmp	short loc_10
			                        ;* No entry point to code
		call	clear_dialog_area
		mov	byte ptr ds:anim_active_flag,0
		mov	si,welcome_text_ptr
		call	draw_banner_8x5
		mov	word ptr ds:gvar_script_ptr,0AAA1h
		mov	ax,word ptr ds:[86h]
		mov	dl,byte ptr ds:[85h]
		or	dl,al
		or	dl,ah
		jnz	loc_13			; Jump if not zero
		retn

loc_13:
		mov	word ptr ds:gvar_script_ptr,0AACAh
		call	word ptr cs:script_step
		mov	bx,2C1Dh
		mov	cx,1237h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,2A20h
		mov	byte ptr ds:gvar_dlg_cols,4
		mov	byte ptr ds:gvar_dlg_rows,4
		mov	byte ptr ds:gvar_ui_misc_byte,0
		mov	cx,4
		mov	si,menu_items_deposit
		call	word ptr cs:show_menu_items
		mov	byte ptr ds:amount_hi,0
		mov	word ptr ds:amount_lo,0
		mov	dl,byte ptr ds:[85h]
		mov	ax,word ptr ds:[86h]
		mov	ds:amount_max_hi,dl
		mov	ds:amount_max_lo,ax

loc_14:
				mov	dl,ds:amount_hi
				mov	ax,ds:amount_lo
				push	dx
				push	ax
				call	word ptr cs:script_take_item
				call	word ptr cs:drv_set_text_pos
				mov	bx,312Eh
				call	word ptr cs:drv_draw_string
				pop	ax
				pop	dx
				call	word ptr cs:drv_set_text_pos
				mov	bx,3148h
				call	word ptr cs:drv_draw_string
				int	61h			; ??INT Non-standard interrupt
				call	adjust_amount_by_input
				test	ah,1
				jnz	loc_18			; Jump if not zero
				mov	word ptr ds:gvar_script_ptr,0AA48h
				test	ah,2
				jz	loc_15			; Jump if zero
				retn

loc_15:
				or	al,al			; Zero ?
				jnz	loc_16			; Jump if not zero
				mov	byte ptr ds:input_repeat_delay,23h	; '#'
				jmp	short loc_14

loc_16:
				mov	byte ptr ds:[0FF1Ah],0

loc_17:
				int	61h			; ??INT Non-standard interrupt
				or	al,al			; Zero ?
				jz	loc_14			; Jump if zero
				mov	al,ds:input_repeat_delay
				cmp	byte ptr ds:[0FF1Ah],al
				jb	loc_17			; Jump if below
				sub	byte ptr ds:input_repeat_delay,1
				jnc	loc_14			; Jump if carry=0
			mov	byte ptr ds:input_repeat_delay,1
			jmp	short loc_14

loc_18:
		mov	word ptr ds:gvar_script_ptr,0AA48h
		mov	ax,ds:amount_lo
		mov	dl,ds:amount_hi
		mov	cl,dl
		or	cl,al
		or	cl,ah
		jnz	loc_19			; Jump if not zero
		retn

loc_19:
		or	dl,dl			; Zero ?
		jnz	loc_20			; Jump if not zero
		cmp	ax,3E8h
		jb	loc_21			; Jump if below

loc_20:
		mov	byte ptr ds:anim_active_flag,0FFh
		mov	word ptr ds:anim_src_ptr,0A7C3h

loc_21:
		add	word ptr ds:[89h],ax
		adc	byte ptr ds:[88h],dl
		mov	dl,ds:amount_hi
		mov	ax,ds:amount_lo
		call	word ptr cs:script_take_item
		mov	byte ptr ds:[85h],dl
		mov	word ptr ds:[86h],ax
		call	word ptr cs:drv_frame_commit
		mov	byte ptr ds:checked_balance_flag,0FFh
		test	byte ptr ds:anim_active_flag,0FFh
		jnz	loc_24			; Jump if not zero
		mov	word ptr ds:gvar_script_ptr,0ABF7h
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		or	dl,ah
		or	dl,al
		jnz	loc_22			; Jump if not zero
		retn

loc_22:
		mov	word ptr ds:gvar_script_ptr,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_23			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_23			; Jump if not equal
		retn

loc_23:
		mov	word ptr ds:gvar_script_ptr,0AAF4h
		call	word ptr cs:script_step
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ptr
		push	si
		mov	word ptr ds:gvar_script_ptr,0AD30h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ptr,si
		retn

loc_24:
		mov	word ptr ds:gvar_script_ptr,0AB10h
		retn
			                        ;* No entry point to code
		call	clear_dialog_area
		mov	byte ptr ds:anim_active_flag,0
		mov	si,welcome_text_ptr
		call	draw_banner_8x5
		mov	word ptr ds:gvar_script_ptr,0AB32h
		mov	ax,word ptr ds:[89h]
		mov	dl,byte ptr ds:[88h]
		or	dl,al
		or	dl,ah
		jnz	loc_25			; Jump if not zero
		retn

loc_25:
		mov	word ptr ds:gvar_script_ptr,0AB80h
		call	word ptr cs:script_step
		mov	bx,2C1Dh
		mov	cx,1237h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		mov	word ptr ds:gvar_dlg_pos,2A20h
		mov	byte ptr ds:gvar_dlg_cols,4
		mov	byte ptr ds:gvar_dlg_rows,4
		mov	byte ptr ds:gvar_ui_misc_byte,0
		mov	cx,4
		mov	si,menu_items_withdraw
		call	word ptr cs:show_menu_items
		mov	byte ptr ds:amount_hi,0
		mov	word ptr ds:amount_lo,0
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	ds:amount_max_hi,dl
		mov	ds:amount_max_lo,ax

loc_26:
				mov	dl,ds:amount_hi
				mov	ax,ds:amount_lo
				push	dx
				push	ax
				mov	cl,byte ptr ds:[88h]
				mov	bx,word ptr ds:[89h]
				sub	bx,ax
				sbb	cl,dl
				xchg	bx,ax
				xchg	dl,cl
				call	word ptr cs:drv_set_text_pos
				mov	bx,312Eh
				call	word ptr cs:drv_draw_string
				pop	ax
				pop	dx
				call	word ptr cs:drv_set_text_pos
				mov	bx,3148h
				call	word ptr cs:drv_draw_string
				int	61h			; ??INT Non-standard interrupt
				call	adjust_amount_by_input
				test	ah,1
				jnz	loc_30			; Jump if not zero
				mov	word ptr ds:gvar_script_ptr,0AA48h
				test	ah,2
				jz	loc_27			; Jump if zero
				retn

loc_27:
				or	al,al			; Zero ?
				jnz	loc_28			; Jump if not zero
				mov	byte ptr ds:input_repeat_delay,23h	; '#'
				jmp	short loc_26

loc_28:
				mov	byte ptr ds:[0FF1Ah],0

loc_29:
				int	61h			; ??INT Non-standard interrupt
				or	al,al			; Zero ?
				jz	loc_26			; Jump if zero
				mov	al,ds:input_repeat_delay
				cmp	byte ptr ds:[0FF1Ah],al
				jb	loc_29			; Jump if below
				sub	byte ptr ds:input_repeat_delay,1
				jnc	loc_26			; Jump if carry=0
			mov	byte ptr ds:input_repeat_delay,1
			jmp	short loc_26

loc_30:
		mov	word ptr ds:gvar_script_ptr,0AA48h
		mov	ax,ds:amount_lo
		mov	dl,ds:amount_hi
		mov	cl,dl
		or	cl,al
		or	cl,ah
		jnz	loc_31			; Jump if not zero
		retn

loc_31:
		mov	byte ptr ds:checked_balance_flag,0FFh
		mov	word ptr ds:gvar_script_ptr,0ABC1h
		mov	dl,ds:amount_hi
		mov	ax,ds:amount_lo
		or	dl,dl			; Zero ?
		jnz	loc_32			; Jump if not zero
		cmp	ax,1
		je	loc_33			; Jump if equal

loc_32:
		mov	word ptr ds:gvar_script_ptr,0ABA4h
		call	word ptr cs:script_step
		mov	dl,ds:amount_hi
		mov	ax,ds:amount_lo
		mov	di,0AD30h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ptr
		push	si
		mov	word ptr ds:gvar_script_ptr,0AD30h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ptr,si

loc_33:
		call	word ptr cs:script_step
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		sub	ax,ds:amount_lo
		sbb	dl,ds:amount_hi
		mov	byte ptr ds:[88h],dl
		mov	word ptr ds:[89h],ax
		mov	word ptr ds:gvar_script_ptr,0ABDEh
		or	dl,ah
		or	dl,al
		jz	loc_35			; Jump if zero
		mov	word ptr ds:gvar_script_ptr,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_34			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_34			; Jump if not equal
		retn

loc_34:
		mov	word ptr ds:gvar_script_ptr,0AAF4h
		call	word ptr cs:script_step
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ptr
		push	si
		mov	word ptr ds:gvar_script_ptr,0AD30h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ptr,si

loc_35:
		mov	dl,ds:amount_hi
		mov	ax,ds:amount_lo
		call	word ptr cs:script_give_item
		jmp	word ptr cs:drv_frame_commit
			                        ;* No entry point to code
		call	clear_dialog_area
		mov	word ptr ds:gvar_script_ptr,0ABF7h
		mov	al,byte ptr ds:[88h]
		xor	ah,ah			; Zero register
		or	ax,word ptr ds:[89h]
		jnz	loc_36			; Jump if not zero
		retn

loc_36:
		mov	byte ptr ds:checked_balance_flag,0FFh
		mov	word ptr ds:gvar_script_ptr,0AC35h
		test	al,byte ptr ds:[88h]
		jnz	loc_37			; Jump if not zero
		cmp	word ptr ds:[89h],1
		jne	loc_37			; Jump if not equal
		retn

loc_37:
		mov	word ptr ds:gvar_script_ptr,0AC10h
		call	word ptr cs:script_step
		mov	dl,byte ptr ds:[88h]
		mov	ax,word ptr ds:[89h]
		mov	di,0AD30h
		call	word ptr cs:script_format_num
		mov	si,ds:gvar_script_ptr
		push	si
		mov	word ptr ds:gvar_script_ptr,0AD30h
		call	word ptr cs:script_step
		pop	si
		mov	ds:gvar_script_ptr,si
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:anim_active_flag,0
		mov	si,intro_text_ptr_list
		call	iter_wait_msg_list
		mov	byte ptr ds:anim_active_flag,0FFh
		mov	word ptr ds:anim_src_ptr,0A773h
		mov	byte ptr ds:[0FF1Ah],0

loc_38:
			call	anim_scroll_step
			cmp	byte ptr ds:[0FF1Ah],64h	; 'd'
			jb	loc_38			; Jump if below
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:goodbye_flag,0FFh
		retn

clear_dialog_area		proc	near
		mov	bx,2717h
		mov	cx,1C41h
		xor	al,al			; Zero register
		jmp	word ptr cs:drv_fill_rect

clear_dialog_area		endp

adjust_amount_by_input		proc	near
		mov	dl,ds:amount_hi
		mov	bx,ds:amount_lo
		test	al,8
		jz	loc_39			; Jump if zero
		sub	bx,0Ah
		sbb	dl,0
		jnc	loc_42			; Jump if carry=0
		xor	bx,bx			; Zero register
		xor	dl,dl			; Zero register
		jmp	short loc_42

loc_39:
		test	al,4
		jz	loc_40			; Jump if zero
		add	bx,0Ah
		adc	dl,0
		mov	cx,bx
		sub	cx,ds:amount_max_lo
		mov	cl,dl
		sbb	cl,ds:amount_max_hi
		jc	loc_42			; Jump if carry Set
		mov	dl,ds:amount_max_hi
		mov	bx,ds:amount_max_lo
		jmp	short loc_42

loc_40:
		test	al,2
		jz	loc_41			; Jump if zero
		sub	bx,1
		sbb	dl,0
		jnc	loc_42			; Jump if carry=0
		xor	bx,bx			; Zero register
		xor	dl,dl			; Zero register
		jmp	short loc_42

loc_41:
		test	al,1
		jz	loc_42			; Jump if zero
		add	bx,1
		adc	dl,0
		mov	cx,bx
		sub	cx,ds:amount_max_lo
		mov	cl,dl
		sbb	cl,ds:amount_max_hi
		jc	loc_42			; Jump if carry Set
		mov	dl,ds:amount_max_hi
		mov	bx,ds:amount_max_lo

loc_42:
		mov	ds:amount_hi,dl
		mov	ds:amount_lo,bx
		retn

adjust_amount_by_input		endp

draw_intro_12x8		proc	near
		mov	si,intro_tile_map
		mov	bx,717h
		mov	cx,8

locloop_43:
			push	cx
			mov	cx,0Ch

locloop_44:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	locloop_44		; Loop if cx > 0

			sub	bh,0Ch
			add	bl,8
			pop	cx
			loop	locloop_43		; Loop if cx > 0

		retn

draw_intro_12x8		endp

		db	'lmnopqrstuvwxy'
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 7Ah, 7Bh, 7Ch, 7Dh
		db	 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh
		db	 0Eh, 0Fh, 7Eh, 7Fh, 80h, 81h
		db	 10h, 11h, 12h, 13h, 14h, 15h
		db	 16h, 17h, 82h, 83h, 84h, 85h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh, 86h, 87h, 88h, 89h
		db	' !"#$'
		db	'%&', 27h
		db	 8Ah, 8Bh, 8Ch, 8Dh, 8Eh, 8Fh
		db	 90h, 91h, 92h, 93h, 94h, 95h
		db	 96h, 97h, 98h, 99h, 9Ah, 9Bh
		db	 9Ch, 9Dh, 9Eh, 9Fh,0A0h,0A1h
		db	0A2h,0A3h

anim_scroll_step		proc	near
		test	byte ptr ds:anim_active_flag,0FFh
		jnz	loc_45			; Jump if not zero
		retn

loc_45:
		cmp	word ptr ds:gvar_timer_word,1Eh
		jae	loc_46			; Jump if above or =
		retn

loc_46:
		mov	word ptr ds:gvar_timer_word,0
		inc	byte ptr ds:anim_frame_counter
		mov	al,ds:anim_frame_counter
		and	al,1
		mov	cl,28h			; '('
		mul	cl			; ax = reg * al
		mov	si,ax
		add	si,ds:anim_src_ptr

anim_scroll_step		endp

draw_banner_8x5		proc	near
		mov	bx,91Fh
		mov	cx,5

locloop_47:
			push	cx
			mov	cx,8

locloop_48:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	locloop_48		; Loop if cx > 0

			sub	bh,8
			add	bl,8
			pop	cx
			loop	locloop_47		; Loop if cx > 0

		retn

draw_banner_8x5		endp

		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	' !"#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 28h, 29h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 2Ah, 2Bh, 2Ch, 1Bh, 1Ch, 1Dh
		db	 1Eh, 1Fh
		db	' -.#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 41h, 42h
		db	 43h, 44h, 45h, 0Fh, 10h, 11h
		db	 46h, 4Dh, 4Eh, 49h, 4Ah, 39h
		db	 18h, 19h, 1Ah
		db	'OPQL= !"RS>?@'
		db	 00h, 01h, 54h, 55h, 56h, 05h
		db	 06h, 07h, 08h, 09h, 57h, 58h
		db	 59h, 5Ah, 5Bh, 0Fh, 10h, 5Ch
		db	 5Dh, 5Eh, 5Fh, 60h, 61h, 17h
		db	 18h, 19h
		db	'bcdefg !"hi>jk'

iter_wait_msg_list		proc	near
		mov	byte ptr ds:[0FF1Ah],0
		lodsw				; String [si] to ax
		cmp	ax,0FFFFh
		jne	loc_49			; Jump if not equal
		retn

loc_49:
		push	si
		mov	si,ax
		call	draw_banner_8x5
		cmp	byte ptr ds:[0FF1Ah],28h	; '('
		jb	$-5			; Jump if below
		pop	si
		jmp	short $-1Ah

iter_wait_msg_list		endp

			                        ;* No entry point to code
		inc	bx
		test	al,6Bh			; 'k'
		test	al,93h
		test	al,0BBh
		test	al,0FFh
		db	0FFh,0BBh,0A8h, 93h,0A8h, 6Bh
		db	0A8h, 43h,0A8h,0FFh,0FFh, 00h
		db	 01h, 02h, 03h, 04h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
		db	 0Dh, 0Eh, 0Fh, 10h, 11h, 12h
		db	 13h, 14h, 15h, 16h, 17h, 18h
		db	 19h, 1Ah, 2Fh, 30h, 1Dh, 1Eh
		db	 1Fh
		db	' !"#$'
		db	'%&', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 14h, 15h, 16h, 17h
		db	 18h, 19h, 1Ah, 2Fh, 30h, 1Dh
		db	 1Eh, 1Fh
		db	' !"#123', 27h
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 34h, 35h, 0Eh, 0Fh, 10h, 11h
		db	 12h, 13h, 36h, 37h, 38h, 39h
		db	 18h, 19h, 1Ah
		db	'/:;<= !"#$'
		db	'>?@'
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 41h, 42h
		db	 43h, 44h, 45h, 0Fh, 10h, 11h
		db	 46h, 47h, 48h, 49h, 4Ah, 39h
		db	 18h, 19h, 1Ah
		db	'/0KL= !"#$'
		db	'>?@'
		db	 01h, 16h
		db	'BANK.GRP'
		db	 00h, 18h,0AFh, 02h
		db	8, 'The Bank'
		db	1, 6, 1, 6, 1, 8
		db	1, 4, 1, 2, 1, 4
		db	4, 2, 1, 6, 1
		db	8
		db	'Go outside', 0
		db	'Exchange almas', 0
		db	'Deposit money', 0
		db	'Withdraw money', 0
		db	'Check balance', 0
		db	'GOLD CARRIED'
		db	0, 0, 0
		db	' DEPOSIT AMT'
		db	0
		db	'GOLD IN BANK'
		db	0, 0, 0
		db	'WITHDRAW AMT'
		db	 00h, 0Ch,0FFh, 2Eh,0FFh
		db	'Oh, excuse me. '
		db	0FFh, 00h
		db	'Can I help you?/'
		db	0FFh, 01h,0FFh,0FFh, 0Ch
		db	'Sir, you aren\t carryi'
		db	'ng any almas. '
		db	0FFh, 01h
		db	0Ch, 'Our exchange rate is '
		db	0FFh, 00h
		db	'&almas to '
		db	0FFh, 00h
		db	'&golds./Will that be all right?'
		db	0FFh, 0Ch
		db	'I\m sorry, you do'
		db	' not have enough almas.'
		db	0FFh, 01h
		db	0Ch, 'I don\'
		db	't'
		db	' und'
		db	'erstand'
		db	'. Please state'
		db	' your business clearly.'
		db	0FFh, 01h
		db	0Ch, 'Will there be anything else'
		db	'?'
		db	0FFh, 01h
		db	0Ch, 'You'
		db	' aren\t c'
		db	'arrying any gold, are you?'
		db	0FFh, 01h
		db	0Ch, 'How much gold w'
		db	'ould you like to deposit?'
		db	0FFh
		db	0Dh, 'Your balance is '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch
		db	 64h, 73h, 2Eh,0FFh, 01h
		db	0Ch, 'Thank you. Please come agai'
		db	'n.'
		db	0FFh, 03h,0FFh, 01h
		db	0Ch, 'I\m afrai'
		db	'd we have a p'
		db	'roblem here. You '
		db	'don\'
		db	't have any gold in your account.'
		db	0FFh, 01h
		db	0Ch, 'How mu'
		db	'ch do you wish to withdraw?/'
		db	0FFh
		db	'Here you are, sir. '
		db	0FFh, 00h, 26h, 67h, 6Fh, 6Ch
		db	 64h, 73h, 2Eh,0FFh
		db	'Here you are, sir. One gold.'
		db	0FFh
		db	0Dh, 'Your account is empty.'
		db	0FFh, 01h
		db	0Ch, 'Your account is empty.'
		db	0FFh, 01h
		db	0Ch, 'You have '
		db	0FFh, 00h
		db	'&golds in your account.'
		db	0FFh, 01h
		db	0Ch, 'You '
		db	'have one gold in your account.'
		db	0FFh, 01h
		db	0Ch, 'Unless'
		db	' you h'
		db	'ave bus'
		db	'ine'
		db	'ss, don\t com'
		db	'e in here. I\m a busy man.'
		db	0FFh, 02h, 11h,0FFh,0FFh, 0Ch
		db	'N'
		db	'ext '
		db	'time please depos'
		db	'it a large sum in savings. '
		db	0FFh, 02h, 11h,0FFh,0FFh, 0Ch
		db	'Th'
		db	'ank you. Come again t'
		db	'o make a deposit'
		db	' for a large sum in savings. '
		db	0FFh, 02h, 11h,0FFh,0FFh, 00h
		db	8 dup (0)
		db	 30h,0FFh
		db	15 dup (0)

seg_a		ends

		end	start
