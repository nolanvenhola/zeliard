
PAGE  59,132

;==========================================================================
;
;  217KENJP - Sage (Kenja) Dialog Program (zelres2 chunk 17)
;
;  NPC program for the 8 Sages (Marid, Yasmin, Hajjar, Chiriga, Hisham,
;  Maryam, Saied, Indihar). Per-sage dispatch is keyed off gvar_sage_id
;  (DS:0C006h, set by caller from 1..8).
;
;  Menu options (selected via joystick -> gvar_sage_cmd):
;    0 "See Power"        - evaluate HP/EXP and display blessing tier
;    1 "Listen Knowledge" - display sage's hint text about the world
;    2 "Record Experience" - write save file (*.usr) via INT 21h (3Ch/40h/3Eh)
;
;  Key subsystems:
;    run_kenja_main              - far entry; load chunk, draw UI, dispatch loop
;    kenja_cmd_dispatch      - jump to handler based on AL (menu selection)
;    sage_scan_attrs         - scan HP/EXP thresholds for blessing tier
;    sage_hp_check           - return AX = tier (0..4) based on HP vs threshold
;    sage_text_anim          - scroll multi-line sage speech with delay
;    save_name_input_loop    - read player name from joystick, write *.usr
;    sage_portrait_blit      - copy 7-byte portrait color LUT to VGA palette
;    input_name_prompt       - prompt handler ("Input name:")
;
;  Sage-specific dispatch via jump tables (game-seg, filled by caller):
;    sage_cmd_tbl   (0A0AFh) - main command jump table
;    sage_init_tbl  (0A114h) - per-sage init / intro jump table
;    sage_intro_tbl (0AC18h) - per-sage portrait intro addresses (8 entries)
;    sage_hint_tbl  (0ACBDh) - per-sage knowledge-hint text addresses
;
;  Connections:
;    Loads:        KENJA.GRP (zelres2 chunk 1Ah) via cs:[sar_loader_fn] SAR loader
;                  with AL=2 (fill_buffer decode) into game_seg:8000h
;                  (chunk-ref record at module offset 0CB4h).
;                  STDPLY.BIN ref also embedded (used indirectly via the
;                  inline music-init code sequence -- see ref_stdply at
;                  module offset ~0x4C2).
;    Calls into:   drv_fill_rect, drv_screen_init_a/b, drv_load_msg_header,
;                  drv_ds_copy (graphics driver dispatch slots)
;                  script_step at cs:[6004h] (script interpreter step)
;                  script_display_page at cs:[6008h] (raw db-encoded call)
;                  sage_cmd_tbl[bx] (CS-relative dispatch by AL menu cmd)
;                  sage_init_tbl[bx] (DS-resident, indexed by gvar_sage_id)
;                  INT 21h functions 3Ch (create), 40h (write), 3Eh (close)
;                    -- write *.usr save file (record_experience handler).
;    Called by:    106TOWN building dispatch when player visits a Sage
;                    (loaded as loaded_code_a at game_seg:3000h via SAR
;                    loader; per-sage selection via gvar_sage_id 1..8).
;    Reads/writes: gvar_sage_id (DS:0C006h) -- caller-set sage index
;                  gvar_script_ip (DS:0FF4Ch), gvar_text_x/y, gvar_dlg_pos,
;                  gvar_frame_timer, gvar_game_seg, state_script_ptr,
;                  game-state HP word at ds:[experience], EXP word at ds:[player_almas],
;                  player gold at ds:[gold_carried_x1], current sage state at DS:[BB14h].
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc


; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in zr2com.inc
; ----------------------------------------------------------------------
gvar_sage_id	equ	0C006h			;* global: sage id (1..8), set by caller
gvar_save_buf	equ	0E000h			;* global: save-file buffer base (256 bytes)
gvar_save_data	equ	0E801h			;* global: save-file data area
gvar_key_flag	equ	0FF1Dh			;* global: key-pressed flag
gvar_enter_flag	equ	0FF1Eh			;* global: ENTER-pressed flag
gvar_key_code	equ	0FF29h			;* global: last key code byte
gvar_game_seg	equ	0FF2Ch			;* global: game segment selector word
gvar_name_page	equ	0FF56h			;* global: name entry page counter
gvar_ui_delay	equ	0FF6Ah			;* global: UI delay counter word (0Ah)
gvar_name_prev	equ	0FF6Ch			;* global: previous name buffer (8 bytes, for resume)
gvar_input_lock	equ	0FF74h			;* global: input-locked flag (FFh=locked)

; ----------------------------------------------------------------------
; Section 4: Shared dispatch slot references (file-local overrides)
; ----------------------------------------------------------------------
drv_fn_palette_a	equ	2006h			;* fn 3: palette push A (writes 7-byte LUT)
drv_fn_blit_on	equ	2026h			;* fn 13h: enable blit / show dialog area
drv_fn_blit_off	equ	2028h			;* fn 14h: disable blit / hide dialog area
drv_fn_draw_str	equ	202Ah			;* fn 15h: draw text string (BX=pos, CL=col, SI=str)
drv_tbl_a	equ	2802h			;* driver lookup table A (indexed by sage/state)
drv_tbl_b	equ	2C02h			;* driver lookup table B (indexed by sage/state)
drv_fn2_init	equ	3000h			;* fn2 0: init ancillary hardware
drv_fn2_text_setup	equ	301Ah			;* fn2 D: text position setup (AL=x)
drv_fn2_text_render	equ	301Ch			;* fn2 E: text render entry
drv_fn2_cursor_draw	equ	301Eh			;* fn2 F: cursor draw (BX=pos, AL=phase)
drv_fn2_cursor_clear	equ	3020h			;* fn2 10: cursor clear (BX=pos, AL=phase)
drv_ident_val	equ	362Ch			;* driver identity/version byte
drv_init_val	equ	51E8h			;* driver init parameter byte (read by start)

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
script_fn_menu_init	equ	6014h			;* menu: init selection list
script_fn_menu_poll	equ	6016h			;* menu: poll input / advance
script_fn_menu_up	equ	6018h			;* menu: cursor up (BL=cur_idx)
script_fn_menu_dn	equ	601Ah			;* menu: cursor down (BL=cur_idx)
sage_cmd_tbl	equ	0A0AFh			;* cmd-code jump table (BL=cmd, used in kenja_cmd_dispatch)
sage_init_tbl	equ	0A114h			;* per-state jump table (used in main dispatch)
sage_anim_a	equ	0A1FDh			;* sage intro animation pattern A (3 entries)
sage_anim_b	equ	0A1FEh			;* sage intro animation pattern B (2 entries)
sage_hp_thresh	equ	0A28Ch			;* HP threshold table (16 words, indexed by sage_level)
sage_cmp_thresh	equ	0A2ACh			;* comparison threshold table (bytes, indexed by sage_id-1)
sage_palette_tbl	equ	0A380h			;* 9-byte palette rows (indexed by sage_level*9)
sage_scan_data	equ	0A9B6h			;* sage scan/scroll data (96 bytes: 8 x 12B rows)
sage_glyph_tbl	equ	0AA47h			;* sage glyph data (indexed by char*32)
sage_music_id	equ	0AB47h			;* music ID byte to play on sage entry
sage_blink_a	equ	0ABFDh			;* cursor blink sequence A (2 bytes)
sage_blink_b	equ	0ABFFh			;* cursor blink sequence B (2 bytes)
sage_intro_tbl	equ	0AC18h			;* per-sage intro jump table (8 entries, via sage_id-1)
sage_intro_lo	equ	0AC39h			;* sage intro low/offset table
sage_cmd_msg_tbl	equ	0ACBDh			;* sage 'How can I help' message pointer table
sage_result_tbl	equ	0B029h			;* menu-result jump table (state code -> next handler)
sage_indihar_hint	equ	0B51Eh			;* Indihar-specific hint text base
sage_blessing_tbl	equ	0B5EBh			;* blessing text pointer table (indexed by sage_id-1)
disk_error_prompt	equ	0B9FFh			;* disk error prompt area
state_script_ptr	equ	0BB12h			;* current script pointer (word)
state_indihar_flg	equ	0BB17h			;* Indihar-only flag byte (final sage)
state_record_flg	equ	0BB19h			;* "Record Experience" flag byte
state_listen_flg	equ	0BB1Ah			;* "Listen Knowledge" flag byte
state_blink_sel	equ	0BB1Bh			;* cursor-blink selector (which table)
state_anim_col	equ	0BB1Dh			;* animation column counter
state_blink_parity	equ	0BB1Eh			;* cursor blink parity byte
state_blink_ctr	equ	0BB1Fh			;* cursor blink wait counter
state_see_ctr	equ	0BB20h			;* "See Power" wait counter
state_name_box_x	equ	0BB21h			;* save-name input box X position (word)
state_name_box_y	equ	0BB23h			;* save-name input box Y position (byte)
state_name_cursor	equ	0BB24h			;* save-name cursor x (within entry)
state_name_len	equ	0BB25h			;* save-name current length
state_name_maxlen	equ	0BB26h			;* save-name maximum length seen
state_name_buf	equ	0BB27h			;* save-name buffer base (8 bytes + terminator)
state_name_term	equ	0BB2Eh			;* save-name terminator byte (at +7)
state_color_tmp_cs	equ	0BB34h			;* CS-side temporary color word (src for palette xfer)
state_color_tmp_cs2	equ	0BB36h			;* CS-side temporary color word 2 (7-byte buffer)

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
state_cmd_byte	equ	0BB14h			;* current command byte
state_sage_flag	equ	0BB15h			;* general per-sage flag byte
state_see_flag	equ	0BB18h			;* "See Power" flag byte
state_anim_phase	equ	0BB1Ch			;* main animation phase (0..0Fh)
kenjp_timer_ff18	equ	0FF18h			;* global: timer word (tested for bit 0 parity)

; BANNER_FILL_RECT
;   Fill the dialog banner rectangle (BX=0D60h, CX=3637h, AL=0FFh) and
;   call drv_fill_rect.  The standard "draw the title-bar background"
;   used by all building-dialog modules.
BANNER_FILL_RECT	MACRO
		mov	bx, 0D60h
		mov	cx, 3637h
		mov	al, 0FFh
		call	word ptr cs:[drv_fill_rect]
		ENDM

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_kenja_main		proc	far

start:
		cmp	ax,1Bh
		add	[bx],ah
		mov	al,ds:[sage_music_id]
		push	es
		mov	al,ds:[drv_init_val]
		db	00h, 0C7h		; add bh,al (alt encoding: 00 r/m8,r8 not 02 r8,r/m8)
		push	es
		adc	bh,byte ptr ss:[kenj_str_spirits_anchor]+0Ah[bp+di]	; ('ll upon the Spirits and ')
		call	draw_sage_tile_grid
		BANNER_FILL_RECT
		mov	word ptr ds:[gvar_script_ip],0BA67h
		jmp	short script_run_loop
			                        ;* No entry point to code
		call	load_sage_chunk
		mov	word ptr ds:[state_script_ptr],717h
		call	draw_sage_tile_grid
		BANNER_FILL_RECT
		call	sage_intro_dispatch
		mov	ds:[gvar_script_ip],si

script_run_loop:
			call	word ptr cs:[script_step]
			cmp	al,0FFh
			je	kenja_exit			; Jump if equal
			call	kenja_cmd_dispatch
			jmp	short script_run_loop

kenja_exit:
		jmp	word ptr cs:[drv_fade_to_black]

run_kenja_main		endp

load_sage_chunk		proc	near
		mov	es,ds:[gvar_game_seg]
		mov	di,8000h
		mov	si,0ACB0h
		mov	al,2
		call	word ptr cs:[sar_loader_fn]
		push	ds
		mov	ds,cs:[gvar_game_seg]
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:[drv_ds_copy]
		pop	ds
		mov	byte ptr ds:[gvar_text_x],0
		mov	byte ptr ds:[gvar_text_y],0
		call	word ptr cs:[drv_screen_init_a]
		call	word ptr cs:[drv_screen_init_b]
		mov	bl,ds:[gvar_sage_id]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[sage_cmd_msg_tbl][bx]
		jmp	word ptr cs:[drv_load_msg_header]

load_sage_chunk		endp

kenja_cmd_dispatch		proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:[sage_cmd_tbl][bx]	;*

kenja_cmd_dispatch		endp

			                        ;* No entry point to code
; -- sage_cmd_tbl word table (8 entries for 4 cmds + jump targets), referenced
;    via DS:[bx]; Sourcer can't follow.  Bytes are kept literal.
		retf				; first byte CB (table sentinel; far-ret used as marker)
kenj_inplace_buf		db	0A0h			; cmd entry low byte
		db	 8Eh,0A1h, 14h,0A9h, 62h,0A8h	; cmd ptrs A18E, A914, A862
db	10h			; cmd-result lookup table (indexed by state)
		db	0A4h,0B4h,0A2h, 20h,0A4h, 3Bh	; entries A410, A2B4, A420, A93B (split byte)
		db	0A9h, 3Fh,0A9h, 43h,0A9h, 47h	; ptrs A93F, A943, A947
		db	0A9h, 4Bh,0A9h, 4Fh,0A9h, 53h	; ptrs A94B, A94F, A953
		db	0A9h,0E8h,0B5h, 08h,0BBh, 22h	; ptr A9 + call rel B5E8 + start of inline x86
		db	 27h,0B9h, 2Dh, 1Ch,0B0h,0FFh	; ...mov bx,2722; mov cx,1C2D; mov al,FF
		db	 2Eh,0FFh, 16h, 00h, 20h,0C7h	; call cs:[2000] (drv_fill_rect); mov word..
		db	 06h, 54h,0FFh			; ..[FF54],..
		db	 25h, 27h			; ..,2725 (gvar_dlg_pos)
kenj_input_flags		db	0C6h				; mov byte... (start of next opcode)
		db	 06h, 52h,0FFh, 04h,0C6h, 06h	; mov [FF52],04 (gvar_dlg_cols); mov..
		db	 53h,0FFh, 04h,0B9h, 04h, 00h	; ..[FF53],04 (gvar_dlg_rows); mov cx,4
		db	0BEh, 65h,0ADh, 2Eh,0FFh, 16h	; mov si,AD65; call cs:..
		db	 0Eh, 60h,0C6h, 06h, 56h,0FFh	; ...[600E] (show_menu_items); mov [FF56]..
		db	 00h, 8Ah, 1Eh, 14h,0BBh, 2Eh	; ..,00; mov bl,[BB14] (state_cmd_byte)
		db	0FFh, 16h, 10h, 60h, 73h, 02h	; call cs:[6010] (menu_show_list); pushf; jnc +2
		db	 32h,0DBh			; xor bl,bl

sage_state_jump:
		mov	ds:[state_cmd_byte],bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[sage_init_tbl][bx]	;*
; -- sage_init_tbl partial entries + inline orphan x86 code.  Reached only via
;    DS dispatch; Sourcer can't follow statically.
		db	 1Ch,0A1h, 26h,0A1h		; sage_init_tbl entries: A11C, A126
kenj_dispatch_fn_ptr		dw	0A157h				; sage_init_tbl entry: A157
		db	 78h,0A1h,0E8h, 64h, 08h,0C7h	; entry A178; call rel; mov word..
		db	 06h, 4Ch,0FFh,0EBh,0ADh,0C3h	; ..[FF4C],ADEB; retn
		db	0E8h, 5Ah, 08h,0F6h, 06h, 15h	; call rel; test byte [BB15]
		db	0BBh,0FFh, 75h, 07h,0C7h, 06h	; ..,FF; jnz +7; mov word..
		db	 4Ch,0FFh, 08h,0AEh,0C3h,0F6h	; ..[FF4C],AE08; retn; test byte..
		db	 06h, 16h,0BBh,0FFh, 75h, 12h	; ..[BB16],FF; jnz +18
		db	0BFh,0A7h,0AEh,0F6h, 06h, 17h	; mov di,AEA7; test byte [BB17]
		db	0BBh,0FFh, 74h, 03h,0BFh, 03h	; ..,FF; jz +3; mov di,AF03
		db	0AFh				; (last byte of mov di,xxx)

ret_save_state_ptr:
		mov	ds:[gvar_script_ip],di
		retn

set_ptr_AE42:
		mov	word ptr ds:[gvar_script_ip],0AE42h
		retn
			                        ;* No entry point to code
		call	clear_sage_region
		mov	bl,ds:[gvar_sage_id]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:[sage_blessing_tbl][bx]
		mov	ds:[gvar_script_ip],si
		call	word ptr cs:[script_step]
		mov	word ptr ds:[gvar_script_ip],0ADBFh
		retn

cmd_record_entry:
		call	clear_sage_region
		call	log_experience_entry
		mov	word ptr ds:[gvar_script_ip],0ADBFh
		jnc	cmd_record_cancel			; Jump if carry=0
		retn

cmd_record_cancel:
		mov	word ptr ds:[gvar_script_ip],0AF7Ch
		retn
			                        ;* No entry point to code
		mov	byte ptr ds:[state_sage_flag],0FFh
		call	scan_blessing_attrs
		call	wait_frames_140
		mov	byte ptr ds:[state_see_flag],0FFh
		mov	byte ptr ds:[state_record_flg],0FFh
		mov	word ptr ds:[gvar_script_ip],0AFDEh

see_power_wait_loop:
			call	wait_frames_140
			call	word ptr cs:[script_step]
			cmp	al,4
			je	see_power_wait_loop			; Jump if equal
		mov	byte ptr ds:[state_listen_flg],0FFh
		db	0E8h, 43h, 00h		; call near (absolute; TASM won't compile as mnemonic)
		call	word ptr cs:[script_step]
		call	check_hp_exp_tier
		add	ax,ax
		mov	bx,ax
		mov	ax,ds:[sage_result_tbl][bx]
		mov	ds:[gvar_script_ip],ax
		retn

scan_blessing_attrs		proc	near
		mov	si,sage_anim_a
		mov	byte ptr ds:[state_record_flg],0FFh
		mov	byte ptr ds:[state_blink_sel],0FFh
		mov	cx,3

scan_anim_a_loop:
			push	cx
			mov	byte ptr ds:[gvar_frame_timer],0
			lodsb				; String [si] to al
			push	si
			call	render_glyph_32

scan_anim_a_delay:
				cmp	byte ptr ds:[gvar_frame_timer],19h
				jb	scan_anim_a_delay			; Jump if below
			pop	si
			pop	cx
			loop	scan_anim_a_loop		; Loop if cx > 0

		mov	byte ptr ds:[state_record_flg],0
		retn

scan_blessing_attrs		endp

			                        ;* No entry point to code
		add	[bx+di],al
		add	bh,ss:[sage_anim_b][bp]
		mov	byte ptr ds:[state_record_flg],0FFh
		mov	cx,2

scan_anim_b_loop:
			push	cx
			mov	byte ptr ds:[gvar_frame_timer],0
			mov	al,[si]
			dec	si
			push	si
			call	render_glyph_32

scan_anim_b_delay:
				cmp	byte ptr ds:[gvar_frame_timer],19h
				jb	scan_anim_b_delay			; Jump if below
			pop	si
			pop	cx
			loop	scan_anim_b_loop		; Loop if cx > 0

		mov	byte ptr ds:[state_record_flg],0
		mov	byte ptr ds:[state_blink_sel],0
		retn

check_hp_exp_tier		proc	near
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[hero_level]
		cmp	bl,0Fh
		jb	tier_clamp_a			; Jump if below
		mov	bl,0Fh

tier_clamp_a:
		add	bx,bx
		add	bx,sage_hp_thresh
		mov	dx,[bx]
		mov	cx,dx
		xor	ax,ax			; Zero register
		shr	cx,1			; Shift w/zeros fill
		cmp	word ptr ds:[experience],cx
		jae	tier_check_low			; Jump if above or =
		retn

tier_check_low:
		mov	ax,dx
		shr	cx,1			; Shift w/zeros fill
		sub	ax,cx
		mov	cx,ax
		mov	ax,1
		cmp	word ptr ds:[experience],cx
		jae	tier_check_high			; Jump if above or =
		retn

tier_check_high:
		mov	ax,2
		cmp	word ptr ds:[experience],dx
		jae	tier_final_test			; Jump if above or =
		retn

tier_final_test:
		xor	bx,bx			; Zero register
		mov	bl,ds:[gvar_sage_id]
		dec	bx
		add	bx,sage_cmp_thresh
		mov	ax,3
		mov	cl,byte ptr ds:[hero_level]
		cmp	cl,[bx]
		jae	tier_is_max			; Jump if above or =
		retn

tier_is_max:
		mov	byte ptr ds:[state_indihar_flg],0FFh
		mov	ax,4
		retn

check_hp_exp_tier		endp

			                        ;* No entry point to code
		xor	al,[bx+si]
		xchg	si,ax
		add	[si],ch
		add	ds:[gvar_save_data][si],sp
		add	bx,sp
		add	ax,offset anim_phase_wrap
		mov	[bp+di],dl
		jo	palette_fade_start			; Jump if overflow=1
		inc	ax
		pop	ds
		adc	[bx],ah
		cbw				; Convrt byte to word
		cmp	ah,[bx+si]
		dec	si
		inc	ax
		pushf				; Push flags
		push	ax
		retn
; -- 11-byte palette-fade delta table (referenced via SI in palette_fade loops).
;    Each byte is an HP/EXP delta value used to step palette indices.
kenjp_palette_fade_deltas:
		db	 60h,0EAh, 03h, 06h, 09h, 0Bh	; deltas 0-5
		db	 0Dh, 0Fh, 12h,0FFh,0C6h	; deltas 6-10 (last byte spills into next opcode)

palette_fade_start:
		push	es
		push	ss
		mov	bx,disk_error_prompt
		or	[bx+si],al

palette_fade_wait_loop:
			push	cx
			call	word ptr cs:[drv_fn2_init]
			mov	byte ptr ds:[gvar_frame_timer],0

palette_fade_delay:
				cmp	byte ptr ds:[gvar_frame_timer],0Ah
				jb	palette_fade_delay			; Jump if below
			pop	cx
			loop	palette_fade_wait_loop		; Loop if cx > 0

		push	cs
		pop	es
		mov	al,byte ptr ds:[hero_level]
		cmp	al,10h
		jb	palette_load_row			; Jump if below
		mov	word ptr ds:[state_color_tmp_cs],320h
		mov	cx,7
		mov	si,offset kenj_inplace_buf
		mov	di,state_color_tmp_cs2

palette_brighten_loop:
			lodsb				; String [si] to al
			add	al,2
			jnc	palette_clamp_ff			; Jump if carry=0
			mov	al,0FFh

palette_clamp_ff:
			stosb				; Store al to es:[di]
			loop	palette_brighten_loop		; Loop if cx > 0

		jmp	short palette_apply

palette_load_row:
		mov	bl,9
		mul	bl			; ax = reg * al
		mov	si,sage_palette_tbl
		add	si,ax
		mov	di,state_color_tmp_cs
		mov	cx,9
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

palette_apply:
		mov	al,byte ptr ds:[hero_level]
		inc	al
		jnz	palette_idx_wrap			; Jump if not zero
		mov	al,0FFh

palette_idx_wrap:
		mov	byte ptr ds:[hero_level],al
		mov	ax,ds:[state_color_tmp_cs]
		mov	word ptr ds:[player_hp_max],ax
		mov	word ptr ds:[player_HP],ax
		call	word ptr cs:[drv_fn_palette_a]
		call	word ptr cs:[drv_palette_push]
		push	cs
		pop	es
		mov	di,offset kenj_inplace_buf
		mov	si,state_color_tmp_cs2
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,0ABh
		mov	si,state_color_tmp_cs2
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:[selected_spell],0FFh
		jz	palette_post_xfer			; Jump if zero
		call	word ptr cs:[drv_anim_step]

palette_post_xfer:
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[hero_level]
		dec	bl
		cmp	bl,0Fh
		jb	palette_hp_clamp_a			; Jump if below
		mov	bl,0Fh

palette_hp_clamp_a:
		add	bx,bx
		mov	ax,ds:[sage_hp_thresh][bx]
		sub	word ptr ds:[experience],ax
		xor	bx,bx			; Zero register
		mov	bl,byte ptr ds:[hero_level]
		cmp	bl,0Fh
		jb	palette_hp_clamp_b			; Jump if below
		mov	bl,0Fh

palette_hp_clamp_b:
		add	bx,bx
		mov	ax,ds:[sage_hp_thresh][bx]
		cmp	word ptr ds:[experience],ax
		jb	palette_hp_done		; Jump if below
		dec	ax
		mov	word ptr ds:[experience],ax

palette_hp_done:
		retn
			                        ;* No entry point to code
		js	$+2			; delay for I/O
		or	al,6
		or	[bx+si],cl
		add	ax,[si]
		add	sp,kenj_phase_inc_table[bx+si]
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	cx,ax
		add	[si],cl
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	si,ax
		add	[si],cl
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	bx,[bx+si]
		add	[bx+si],dx
		push	es
		or	[bx+si],cl
		add	ax,[si]
		add	ax,[bx+si+1]
		adc	al,6
		or	[bx+si],cl
		add	ax,[si]
		add	di,[si+1]
		db	18h, 06h, 08h, 08h	; mis-decoded as `sbb [808h],al`; bytes are raw data
		add	ax,[si]
		add	cx,sp
		add	[si],bx
		or	al,8
		or	[bp+di],al
		add	al,3
		sbb	al,2
		and	[bp+si],dl
		or	al,8
		add	ax,[si]
		add	bx,[bx+si+2]
		and	al,18h
		adc	[bx+si],cl
		add	ax,[si]
		add	ax,ds:[drv_tbl_a][bx+si]
		push	ds
		adc	al,10h
		add	ax,[si]
		add	bp,ds:[drv_tbl_b][bx+si]
		and	al,18h
		sbb	[bp+di],al
		add	al,3
		rol	byte ptr [bp+si],1	; Rotate
		xor	[bp+si],ch
		sbb	al,20h			; ' '
		add	ax,[si]
		add	di,ax
		add	dh,[si]
		xor	[si],ah
		xor	[bx+di],cl
		db	08h, 06h, 0Ch, 03h	; mis-decoded as `or [30Ch],al`; bytes are raw data
		cmp	ds:[drv_ident_val],dh
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	al,9
		and	[bp+di],al
		cmp	al,3Ch			; '<'
		cmp	al,48h			; 'H'
		adc	ax,0C10h

wait_frames_140		proc	near
		mov	byte ptr ds:[gvar_frame_timer],0

wait_frames_tick:
			call	anim_tick
			cmp	byte ptr ds:[gvar_frame_timer],8Ch
			jb	wait_frames_tick			; Jump if below
		retn

wait_frames_140		endp

			                        ;* No entry point to code
		mov	word ptr ds:[gvar_script_ip],0ADBFh
		retn

log_experience_entry		proc	near
		push	cs
		pop	es
		mov	si,0A907h
		mov	al,6
		call	word ptr cs:[sar_loader_fn]
		mov	ax,cs
		mov	es,ax
		mov	ds,ax
		mov	di,0E000h
		mov	dx,0A516h
		call	word ptr cs:[kenj_dispatch_fn_ptr]
		mov	bx,offset kenj_str_outside_at_7+7	; ('e IndiharGo outside')
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:[drv_fill_rect]
		mov	bx,offset kenj_str_outside_at_7+7	; ('e IndiharGo outside')
		mov	cx,2637h
		mov	al,0FFh
		call	word ptr cs:[drv_fill_rect]
		push	cs
		pop	es
		mov	di,state_name_buf
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:[state_name_len],0
		mov	si,gvar_name_prev
		mov	di,state_name_buf
		mov	cx,8

name_prefill_loop:
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jz	name_prefill_done			; Jump if zero
			inc	byte ptr ds:[state_name_len]
			stosb				; Store al to es:[di]
			loop	name_prefill_loop		; Loop if cx > 0

name_prefill_done:
		mov	al,ds:[state_name_len]
		mov	ds:[state_name_maxlen],al
		mov	bx,3Ch
		mov	cl,6Ch			; 'l'
		mov	si,0A51Ch
		call	word ptr cs:[drv_fn_draw_str]
		mov	word ptr ds:[state_name_box_x],60h
		mov	byte ptr ds:[state_name_box_y],7Eh	; '~'
		mov	word ptr ds:[gvar_dlg_pos],3463h
		mov	word ptr ds:[gvar_ui_delay],0Ah
		mov	al,ds:[gvar_save_buf]
		cmp	al,5
		jb	name_clamp_5			; Jump if below
		mov	al,5

name_clamp_5:
		xor	ah,ah			; Zero register
		mov	cx,ax
		xor	al,al			; Zero register
		mov	si,0E001h
		jcxz	name_input_entry			; Jump if cx=0
		call	draw_char_row

name_input_entry:
		mov	si,0E001h
		mov	al,ds:[gvar_save_buf]
		mov	ds:[gvar_dlg_rows],al
		mov	byte ptr ds:[gvar_dlg_cols],5
		call	wait_name_input
		pushf				; Push flags
		BANNER_FILL_RECT
		popf				; Pop flags
		jnc	name_input_ok			; Jump if carry=0
		retn

name_input_ok:
		push	cs
		pop	es
		mov	di,gvar_name_prev
		mov	cx,8
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		cmp	byte ptr ds:[state_name_maxlen],0
		stc				; Set carry flag
		jnz	name_copy_to_prev			; Jump if not zero
		retn

name_copy_to_prev:
		mov	si,state_name_buf
		mov	di,gvar_name_prev

name_copy_loop:
			lodsb				; String [si] to al
			cmp	al,0FFh
			clc				; Clear carry flag
			jnz	name_copy_test_space			; Jump if not zero
			retn

name_copy_test_space:
			cmp	al,60h			; '`'
			clc				; Clear carry flag
			jnz	name_copy_store			; Jump if not zero
			retn

name_copy_store:
			stosb				; Store al to es:[di]
			jmp	short name_copy_loop

log_experience_entry		endp

; -- Save filename mask + input prompt strings.
kenjp_save_file_mask:
		db	 2Ah, 2Eh, 75h, 73h, 72h, 00h	; '*.usr',00 - DOS file-mask for save files
		db	'Input name:'			; prompt text drawn during name entry
		db	0FFh				; SCR_END terminator

draw_char_row		proc	near
		xor	ah,ah			; Zero register

draw_char_row_loop:
			push	cx
			push	si
			push	ax
			call	word ptr cs:[drv_fn2_text_setup]
			pop	ax
			push	ax
			mov	al,ah
			xor	ah,ah			; Zero register
			add	ax,ax
			mov	bx,ax
			add	ax,ax
			add	ax,ax
			add	bx,ax
			add	bx,ds:[gvar_dlg_pos]
			add	bx,300h
			call	word ptr cs:[drv_fn2_text_render]
			pop	ax
			inc	al
			inc	ah
			pop	si
			pop	cx
			loop	draw_char_row_loop		; Loop if cx > 0

		retn

draw_char_row		endp

wait_name_input		proc	near
		mov	byte ptr ds:[gvar_input_lock],0FFh
		mov	byte ptr ds:[gvar_key_code],0
		mov	byte ptr ds:[gvar_key_code],0
		mov	byte ptr ds:[gvar_key_flag],0
		mov	byte ptr ds:[gvar_enter_flag],0
		mov	byte ptr ds:[gvar_name_page],0
		mov	byte ptr ds:[state_name_cursor],0
		xor	bl,bl			; Zero register
		test	byte ptr ds:[gvar_dlg_rows],0FFh
		jz	name_in_init_ok			; Jump if zero
		call	word ptr cs:[script_fn_menu_init]

name_in_init_ok:
		call	render_name_field
		xor	al,al			; Zero register
		call	update_name_cursor

name_in_poll_loop:
		call	word ptr cs:[script_fn_menu_poll]
		mov	byte ptr ds:[gvar_frame_timer],0
		test	byte ptr ds:[gvar_enter_flag],0FFh
		stc				; Set carry flag
		jnz	name_in_exit			; Jump if not zero
		test	word ptr cs:[kenjp_timer_ff18],1
		jz	name_in_no_key			; Jump if zero
		clc				; Clear carry flag

name_in_exit:
		mov	byte ptr ds:[gvar_input_lock],0
		mov	byte ptr ds:[gvar_enter_flag],0
		retn

name_in_no_key:
		test	byte ptr ds:[gvar_key_flag],0FFh
		jz	name_in_joystick			; Jump if zero
		push	si
		xor	bh,bh			; Zero register
		mov	bl,ds:[gvar_name_page]
		add	bl,ds:[state_name_cursor]
		add	bx,bx
		mov	si,[bx+si]
		push	cs
		pop	es
		mov	di,state_name_buf
		mov	al,60h			; '`'
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		mov	byte ptr ds:[state_name_len],0
		mov	di,state_name_buf
		mov	cx,8

name_in_load_preset_loop:
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jz	name_in_load_preset_done			; Jump if zero
			inc	byte ptr ds:[state_name_len]
			stosb				; Store al to es:[di]
			loop	name_in_load_preset_loop		; Loop if cx > 0

name_in_load_preset_done:
		mov	al,ds:[state_name_len]
		mov	ds:[state_name_maxlen],al
		pop	si
		mov	byte ptr ds:[gvar_key_flag],0
		mov	ax,ds:[state_name_box_x]
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:[state_name_box_y]
		mov	cx,1010h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		call	render_name_field
		xor	al,al			; Zero register
		call	update_name_cursor
		jmp	name_in_poll_loop

name_in_joystick:
		mov	cx,0A592h
		push	cx
		test	byte ptr ds:[gvar_key_code],0FFh
		jz	name_in_joy_read			; Jump if zero
		mov	al,ds:[gvar_key_code]
		mov	byte ptr ds:[gvar_key_code],0
		cmp	al,0Dh
		jne	name_in_backspace			; Jump if not equal
		retn

name_in_backspace:
		cmp	al,8
		jne	name_in_append_char			; Jump if not equal
		jmp	name_in_backspace_impl

name_in_append_char:
		xor	bx,bx			; Zero register
		mov	bl,ds:[state_name_len]
		cmp	byte ptr ds:[state_name_buf][bx],60h	; '`'
		jne	name_in_append_len_ok			; Jump if not equal
		inc	byte ptr ds:[state_name_maxlen]

name_in_append_len_ok:
		mov	ds:[state_name_buf][bx],al
		call	render_name_field
		mov	al,1
		jmp	update_name_cursor_entry

name_in_joy_read:
		int	61h			; ??INT Non-standard interrupt
		test	al,8
		jz	name_in_joy_btn2			; Jump if zero
		mov	al,1
		call	update_name_cursor

name_in_joy_btn1_hold:
			int	61h			; ??INT Non-standard interrupt
			test	al,8
			jnz	name_in_joy_btn1_hold			; Jump if not zero
		mov	byte ptr ds:[gvar_key_code],0
		retn

name_in_joy_btn2:
		test	al,4
		jz	name_in_dir_test			; Jump if zero
		mov	al,0FFh
		call	update_name_cursor

name_in_joy_btn2_hold:
			int	61h			; ??INT Non-standard interrupt
			test	al,4
			jnz	name_in_joy_btn2_hold			; Jump if not zero
		mov	byte ptr ds:[gvar_key_code],0
		retn

name_in_dir_test:
		test	byte ptr ds:[gvar_dlg_rows],0FFh
		jnz	name_in_dir_check			; Jump if not zero
		retn

name_in_dir_check:
		and	al,3
		cmp	al,1
		jne	name_in_test_down			; Jump if not equal
		test	byte ptr ds:[state_name_cursor],0FFh
		jz	name_in_up_handler			; Jump if zero
		mov	bl,ds:[state_name_cursor]
		call	word ptr cs:[script_fn_menu_up]
		dec	byte ptr ds:[state_name_cursor]
		retn

name_in_up_handler:
		test	byte ptr ds:[gvar_name_page],0FFh
		jnz	name_in_page_up			; Jump if not zero
		retn

name_in_page_up:
		push	di
		push	si
		dec	byte ptr ds:[gvar_name_page]
		mov	al,ds:[gvar_name_page]
		add	al,ds:[state_name_cursor]
		call	word ptr cs:[drv_fn2_text_setup]
		mov	cx,0Ah

name_in_page_up_loop:
			push	cx
			mov	bx,ds:[gvar_dlg_pos]
			add	bx,301h
			mov	al,cl
			dec	al
			mov	cl,ds:[gvar_dlg_cols]
			add	cl,cl
			mov	dl,cl
			add	cl,cl
			add	cl,cl
			add	cl,dl
			sub	cl,2
			mov	ch,ds:[gvar_ui_delay]
			call	word ptr cs:[drv_fn2_cursor_draw]

name_in_page_up_wait:
				call	word ptr cs:[script_fn_menu_poll]
				cmp	byte ptr ds:[gvar_frame_timer],4
				jb	name_in_page_up_wait			; Jump if below
			mov	byte ptr ds:[gvar_frame_timer],0
			pop	cx
			loop	name_in_page_up_loop		; Loop if cx > 0

		pop	si
		pop	di
		retn

name_in_test_down:
		cmp	al,2
		je	name_in_down_ok			; Jump if equal
		retn

name_in_down_ok:
		mov	al,ds:[state_name_cursor]
		add	al,ds:[gvar_name_page]
		inc	al
		mov	ah,ds:[gvar_dlg_rows]
		dec	ah
		cmp	ah,al
		jae	name_in_down_handler			; Jump if above or =
		retn

name_in_down_handler:
		mov	al,ds:[gvar_dlg_cols]
		dec	al
		cmp	ds:[state_name_cursor],al
		jae	name_in_page_down			; Jump if above or =
		mov	bl,ds:[state_name_cursor]
		call	word ptr cs:[script_fn_menu_dn]
		inc	byte ptr ds:[state_name_cursor]
		retn

name_in_page_down:
		push	di
		push	si
		inc	byte ptr ds:[gvar_name_page]
		mov	al,ds:[gvar_name_page]
		add	al,ds:[state_name_cursor]
		call	word ptr cs:[drv_fn2_text_setup]
		mov	cx,0Ah

name_in_page_down_loop:
			push	cx
			mov	bx,ds:[gvar_dlg_pos]
			add	bx,301h
			mov	al,cl
			neg	al
			add	al,0Ah
			mov	cl,ds:[gvar_dlg_cols]
			add	cl,cl
			mov	dl,cl
			add	cl,cl
			add	cl,cl
			add	cl,dl
			sub	cl,2
			mov	ch,ds:[gvar_ui_delay]
			call	word ptr cs:[drv_fn2_cursor_clear]

name_in_page_down_wait:
				call	word ptr cs:[script_fn_menu_poll]
				cmp	byte ptr ds:[gvar_frame_timer],4
				jb	name_in_page_down_wait			; Jump if below
			mov	byte ptr ds:[gvar_frame_timer],0
			pop	cx
			loop	name_in_page_down_loop		; Loop if cx > 0

		pop	si
		pop	di
		retn

wait_name_input		endp

update_name_cursor		proc	near

update_name_cursor_entry:
		push	si
		push	ax
		mov	ax,ds:[state_name_box_x]
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	al,ds:[state_name_len]
		add	al,al
		add	bh,al
		mov	bl,ds:[state_name_box_y]
		add	bl,8
		mov	cx,208h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		pop	ax
		add	ds:[state_name_len],al
		test	byte ptr ds:[state_name_len],80h
		jz	cursor_len_wrap			; Jump if zero
		mov	byte ptr ds:[state_name_len],0

cursor_len_wrap:
		cmp	byte ptr ds:[state_name_len],8
		jb	cursor_len_clamp			; Jump if below
		dec	byte ptr ds:[state_name_len]

cursor_len_clamp:
		mov	al,ds:[state_name_maxlen]
		cmp	ds:[state_name_len],al
		jb	cursor_len_max			; Jump if below
		mov	ds:[state_name_len],al

cursor_len_max:
		mov	bx,ds:[state_name_box_x]
		mov	cl,ds:[state_name_box_y]
		xor	ax,ax			; Zero register
		mov	al,ds:[state_name_len]
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	bx,ax
		add	cl,8
		mov	ax,67Fh
		call	word ptr cs:[drv_render_char]
		pop	si
		retn

update_name_cursor		endp

render_name_field		proc	near
		push	si
		mov	ax,ds:[state_name_box_x]
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bh,al
		mov	bl,ds:[state_name_box_y]
		mov	cx,1008h
		xor	al,al			; Zero register
		call	word ptr cs:[drv_fill_rect]
		mov	bx,ds:[state_name_box_x]
		mov	cl,ds:[state_name_box_y]
		mov	si,0BB27h
		call	word ptr cs:[drv_fn_draw_str]
		pop	si
		retn

render_name_field		endp

name_in_backspace_impl:
		push	si
		mov	bl,ds:[state_name_len]
		or	bl,bl			; Zero ?
		jnz	name_backspace_min_one			; Jump if not zero
		inc	bl

name_backspace_min_one:
		xor	bh,bh			; Zero register
		push	cs
		pop	es
		mov	si,state_name_buf
		add	si,bx
		mov	di,si
		dec	di
		mov	al,8
		sub	al,bl
		mov	cl,al
		xor	ch,ch			; Zero register
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:[state_name_maxlen],0FFh
		jz	name_backspace_maxlen_dec			; Jump if zero
		dec	byte ptr ds:[state_name_maxlen]

name_backspace_maxlen_dec:
		mov	byte ptr ds:[state_name_term],60h	; '`'
		mov	al,0FFh
		call	update_name_cursor
		call	render_name_field
		pop	si
		retn

			                        ;* No entry point to code
		push	cs
		pop	es
		mov	si,gvar_name_prev
		mov	di,state_name_buf
		mov	cx,8

save_name_copy_loop:
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jz	save_name_ext_usr			; Jump if zero
			stosb				; Store al to es:[di]
			loop	save_name_copy_loop		; Loop if cx > 0

save_name_ext_usr:
		mov	byte ptr es:[di],2Eh	; '.'
		mov	byte ptr es:[di+1],75h	; 'u'
		mov	byte ptr es:[di+2],73h	; 's'
		mov	byte ptr es:[di+3],72h	; 'r'
		mov	byte ptr es:[di+4],0
		mov	dx,state_name_buf
		mov	cx,0
		mov	ah,3Ch
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		jc	save_disk_error			; Jump if carry Set
		push	ax
		mov	dx,0
		mov	cx,100h
		mov	bx,ax
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		pop	ax
		pushf				; Push flags
		mov	bx,ax
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		popf				; Pop flags
		jc	save_disk_error			; Jump if carry Set
		retn

save_disk_error:
		mov	ax,849h
		mov	cx,1926h
		xor	di,di			; Zero register
		call	word ptr cs:[drv_fn_blit_on]
		mov	bx,1049h
		mov	cx,3226h
		mov	al,0FFh
		call	word ptr cs:[drv_fill_rect]
		mov	bx,4Ch
		mov	cl,50h			; 'P'
		mov	si,0B5ACh
		call	word ptr cs:[drv_fn_draw_str]
		mov	byte ptr ds:[gvar_key_flag],0

save_wait_key_loop:
			test	byte ptr ds:[gvar_key_flag],0FFh
			jz	save_wait_key_loop			; Jump if zero
		mov	byte ptr ds:[gvar_key_flag],0
		mov	ax,849h
		mov	cx,1926h
		xor	di,di			; Zero register
		call	word ptr cs:[drv_fn_blit_off]
		BANNER_FILL_RECT
		jmp	cmd_record_entry
; -- ref_stdply: chunk-loader reference for STDPLY.BIN (audio driver) +
;    inline orphan x86 code for music init.  Sourcer can't follow.
ref_stdply:
		db	0, 0				; archive=0 (zelres1) + chunk=0 (placeholder bytes)
		db	'STDPLY.BIN'			; filename
		db	 00h,0BBh, 2Bh, 2Fh,0B9h, 19h	; filename term + mov bx,2F2B; mov cx,..
		db	 0Ch,0B0h,0FFh, 2Eh,0FFh, 16h	; ..,190C; mov al,FF; call cs:..
		db	 00h, 20h,0C7h, 06h, 54h,0FFh	; ..[2000] (drv_fill_rect); mov [FF54]..
		db	 2Eh, 30h, 2Eh,0FFh, 16h, 08h	; ..,302E; call cs:[6008] (script_display_page)
		db	 60h, 9Ch,0E8h, 53h, 00h, 9Dh	; pushf; pushf; call rel; popf
		db	 72h, 01h,0C3h, 33h,0C0h, 2Eh	; jc +1; retn; xor ax,ax; ..
		db	0FFh, 2Eh, 00h,0FFh,0B0h, 01h	; jmp far cs:[FF00]; mov al,01
		db	0EBh, 18h,0B0h, 02h,0EBh, 14h	; jmp +24; mov al,02; jmp +20
		db	0B0h, 03h,0EBh, 10h,0B0h, 04h	; mov al,03; jmp +16; mov al,04
		db	0EBh, 0Ch,0B0h, 05h,0EBh, 08h	; jmp +12; mov al,05; jmp +8
		db	0B0h, 06h,0EBh, 04h,0B0h, 07h	; mov al,06; jmp +4; mov al,07
		db	0EBh, 00h, 50h,0BBh, 1Ch,0AAh	; jmp +0; push ax; mov bx,AA1C
		db	 32h,0C0h,0B5h, 17h, 2Eh,0FFh	; xor al,al; mov ch,17; call cs:..
		db	 16h, 04h, 20h, 58h,0A2h, 9Dh	; ..[2004] (drv_fn_palette_a); pop ax; mov..
		db	 00h, 8Ah,0D8h,0FEh,0CBh, 32h	; ..[009D],al; mov bl,al; dec bl; xor..
		db	0FFh,0C6h, 87h,0BBh, 00h,0FFh	; bl,bh; mov [BB87],FFh
		db	0A0h, 9Dh, 00h,0BBh,0A4h, 37h	; mov al,[009D]; mov bx,A4 + cx,..
		db	 2Eh,0FFh, 16h, 1Eh, 20h, 2Eh	; ..; call cs:[201E] (drv_fn2_cursor_draw)
		db	0FFh, 26h, 18h			; jmp far cs:[18..]
		db	20h				; (operand high byte)

clear_sage_region		proc	near
		mov	bx,2717h
		mov	cx,1D41h
		xor	al,al			; Zero register
		jmp	word ptr cs:[drv_fill_rect]

clear_sage_region		endp

draw_sage_tile_grid		proc	near
		mov	si,sage_scan_data
		mov	bx,ds:[state_script_ptr]
		mov	cx,8

sage_tile_row_loop:
			push	cx
			mov	cx,0Ch

sage_tile_col_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:[drv_draw_glyph]
				pop	bx
				inc	bh
				pop	cx
				loop	sage_tile_col_loop		; Loop if cx > 0

			sub	bh,0Ch
			add	bl,8
			pop	cx
			loop	sage_tile_row_loop		; Loop if cx > 0

		retn

draw_sage_tile_grid		endp

; -- sage_scan_data: 12-wide x 8-tall tile glyph map for the sage tile grid.
;    Drawn by draw_sage_tile_grid using state_script_ptr as start position.
kenjp_sage_scan_data:
		db	 00h, 01h, 02h, 03h, 04h, 05h	; row 0 cols 0-5
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh	; row 0 cols 6-11
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h	; row 1 cols 0-5
		db	 12h, 13h, 14h, 15h, 16h, 17h	; row 1 cols 6-11
		db	 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh	; row 2 cols 0-5
		db	 1Eh, 1Fh			; row 2 cols 6-7
		db	1Bh, ' !"#$'			; row 2/3 cont (ASCII glyphs)
		db	'%', 1Bh, '&', 27h, '()', 1Bh, '+'	; row 3 ASCII glyphs (with 1B separators)
		db	',-./0123456789:;<=>?@ABCDEFGHIJK'	; rows 4-5 ASCII glyphs
		db	'LMNOPQRSTUVWXYZ[\]'		; row 6/7 ASCII glyphs (last 18 entries)

render_glyph_32		proc	near
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		mov	bx,ds:[state_script_ptr]
		add	bx,210h
		mov	si,ax
		add	si,sage_glyph_tbl
		mov	cx,4

glyph_row_loop:
			push	cx
			mov	cx,8

glyph_col_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:[drv_draw_glyph]
				pop	bx
				inc	bh
				pop	cx
				loop	glyph_col_loop		; Loop if cx > 0

			sub	bh,8
			add	bl,8
			pop	cx
			loop	glyph_row_loop		; Loop if cx > 0

		retn

render_glyph_32		endp

			                        ;* No entry point to code
		sbb	bl,[bp+di]
		sbb	al,1Dh
		push	ds
		pop	ds
		sbb	sp,[bx+si]
		and	ax,261Bh
		daa				; Decimal adjust
		sub	[bx+di],ch
		sbb	bp,[bp+di]
		xor	[bx+di],dh
		xor	dh,[bp+di]
		xor	al,35h			; '5'
; -- sage_glyph_tbl: 32-byte glyph blocks for each sage portrait variant.
;    Indexed via render_glyph_32 (cl=20h * char idx); 8 sages x 32 bytes each.
kenjp_sage_glyph_tbl:
; Variant 0 (Marid)
		db	'67<=>?@ABC'			; sage 0 row 0 ASCII glyphs
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh	; sage 0 row 0 cont (tile glyphs)
		db	1Bh, ' %', 1Bh, 'q', 27h, '(t', 1Bh	; sage 0 row 1 (mixed ASCII + 1B separators)
		db	'+01u34v67<=>?@ABC^_'		; sage 0 row 1/2 cont
; Variant 1 (Yasmin)
		db	 1Ch, 1Dh, 1Eh, 1Fh		; sage 1 row 0 (4 tile glyphs)
		db	'`abcdefgij0klmnop7<=>?@ABC'	; sage 1 row 0/1 cont (ASCII glyphs)
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh	; sage 1 row 2 (tile glyphs)
		db	'wx %', 1Bh, 'yezrs+0{|}~'	; sage 1 row 2 cont (ASCII)
; Variant 2 (Hajjar)
		db	 7Fh, 36h, 37h, 3Ch, 80h, 81h	; sage 2 row 0 (mixed glyphs)
		db	 3Fh, 40h, 41h, 42h, 43h, 1Ah	; sage 2 row 0 cont
		db	 1Bh, 1Ch, 1Dh, 1Eh, 1Fh, 1Bh	; sage 2 row 1 (tiles + 1B separators)
		db	 20h, 25h, 82h, 83h, 65h, 7Ah	; sage 2 row 1 cont
		db	 84h, 85h, 2Bh, 30h, 86h, 87h	; sage 2 row 2
		db	 7Dh, 88h, 89h			; sage 2 row 2 cont (last 3 glyphs)
; Variant 3 (Chiriga)
		db	'67<=>?@ABC'			; sage 3 row 0 ASCII
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh	; sage 3 row 0 cont
		db	 1Bh, 20h, 25h, 8Ah, 8Bh, 65h	; sage 3 row 1
		db	 66h, 8Ch, 8Dh, 2Bh, 30h, 8Eh	; sage 3 row 1 cont
		db	 8Fh, 7Dh, 90h, 91h, 92h	; sage 3 row 2 (last 5)
; Variant 4 (Hisham)
		db	'7<=>?@ABC'			; sage 4 row 0 ASCII (9 chars)
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh	; sage 4 row 0 cont
		db	 1Bh, 20h, 25h, 93h, 94h, 65h	; sage 4 row 1
		db	 95h, 96h, 97h, 2Bh, 30h, 31h	; sage 4 row 1 cont
		db	 98h, 7Dh, 88h, 99h, 9Ah	; sage 4 row 2 (5 entries)
; Variant 5 (Maryam)
		db	'7<=>?@ABC'			; sage 5 row 0 ASCII
		db	 1Ah, 9Bh, 9Ch, 1Dh, 1Eh, 1Fh	; sage 5 row 0 cont (with 9B,9C variants)
		db	 1Bh, 20h, 25h, 9Dh, 9Eh, 65h	; sage 5 row 1
		db	 95h, 9Fh, 1Bh, 2Bh, 30h,0A0h	; sage 5 row 1 cont
		db	0A1h, 7Dh, 6Eh,0A2h,0A3h, 37h	; sage 5 row 2
		db	 3Ch, 3Dh, 3Eh, 3Fh, 40h,0A4h	; sage 5 row 2/3
		db	0A5h				; sage 5 last glyph (A5)
		db	43h				; trailing pad (43h, used as filler)

anim_tick		proc	near
		cmp	word ptr ds:[gvar_timer_word],2
		jae	anim_tick_active			; Jump if above or =
		retn

anim_tick_active:
		mov	word ptr ds:[gvar_timer_word],0
		test	byte ptr ds:[state_see_flag],0FFh
		jz	anim_check_record			; Jump if zero
		test	byte ptr ds:[state_listen_flg],0FFh
		jz	anim_tick_listen			; Jump if zero
		inc	byte ptr ds:[state_anim_phase]
		and	byte ptr ds:[state_anim_phase],0Fh
		cmp	byte ptr ds:[state_anim_phase],1
		jne	anim_check_record			; Jump if not equal
		mov	byte ptr ds:[state_see_flag],0
		mov	byte ptr ds:[state_listen_flg],0
		mov	byte ptr ds:[state_anim_phase],0
		mov	byte ptr ds:[state_anim_col],0
		jmp	short anim_check_record

anim_tick_listen:
		inc	byte ptr ds:[state_see_ctr]
		cmp	byte ptr ds:[state_see_ctr],14h
		jae	anim_advance_column			; Jump if above or =
		retn

anim_advance_column:
		mov	byte ptr ds:[state_see_ctr],0
		inc	byte ptr ds:[state_anim_col]
		mov	bl,ds:[state_anim_col]
		dec	bl
		and	bl,7
		xor	bh,bh			; Zero register
		mov	al,ds:[sage_blink_b][bx]
		call	render_glyph_32
		inc	byte ptr ds:[state_anim_phase]

anim_phase_wrap:
		and	byte ptr ds:[state_anim_phase],0Fh

anim_check_record:
		test	byte ptr ds:[state_record_flg],0FFh
		jz	anim_record_wait			; Jump if zero
		retn

anim_record_wait:
		inc	byte ptr ds:[state_blink_ctr]
		cmp	byte ptr ds:[state_blink_ctr],14h
		jae	anim_record_tick			; Jump if above or =
		retn

anim_record_tick:
		mov	byte ptr ds:[state_blink_ctr],0
		mov	bl,ds:[state_blink_parity]
		not	byte ptr ds:[state_blink_parity]
		and	bl,1
		xor	bh,bh			; Zero register
		mov	di,0ABFBh
		test	byte ptr ds:[state_blink_sel],0FFh
		jz	anim_record_use_blink_b			; Jump if zero
		mov	di,sage_blink_a

anim_record_use_blink_b:
		mov	al,[bx+di]
		mov	bx,ds:[state_script_ptr]
		add	bx,718h
		jmp	word ptr cs:[drv_draw_glyph]

anim_tick		endp

; -- sage_anim_a/_b 9-byte phase table (used by anim_tick).
;    First word forms kenj_phase_inc_table; trailing 9 bytes are the phase increments.
		db	29h				; first byte of kenj_phase_inc_table word (low)
kenj_phase_inc_table		dw	672Ah			; data table sentinel word (672A)
		db	 68h, 05h, 06h, 07h, 06h, 05h	; phase incs 0-5
		db	 04h, 03h, 04h			; phase incs 6-8

sage_intro_dispatch		proc	near
		mov	si,0AD9Dh
		mov	bl,ds:[gvar_sage_id]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr ds:[sage_intro_tbl][bx]	;*

sage_intro_dispatch		endp

			                        ;* No entry point to code
		sub	ds:[sage_intro_lo][si],ch
		dec	dx
		lodsb				; String [si] to al
		pop	bx
		lodsb				; String [si] to al
; -- sage_intro_tbl ptrs + inline x86 hint-set bytes (orphan handlers reached
;    via DS-resident jump table; Sourcer can't follow).
		db	 6Ch,0ACh, 7Dh,0ACh, 8Eh,0ACh	; sage_intro_tbl entries 0-2: AC6C, AC7D, AC8E
		db	 9Fh,0ACh,0F6h, 06h,0E5h, 00h	; entry 3: AC9F + test byte [00E5]..
		db	 80h, 74h, 01h,0C3h,0BEh,0B8h	; ..,80; jz +1; retn; mov si,B1B8
		db	0B1h, 80h, 0Eh,0E5h, 00h, 80h	; ..; or byte [00E5],80
		db	0C3h,0F6h, 06h,0E5h, 00h, 40h	; retn; test byte [00E5],40
		db	 74h, 01h,0C3h			; jz +1; retn

hint_yasmin_set:
		mov	si,0B22Dh
		or	kenj_input_flags,40h		; '@'
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,20h		; ' '
		jz	hint_climb_set			; Jump if zero
		retn

hint_climb_set:
		mov	si,0B29Fh
		or	kenj_input_flags,20h		; ' '
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,10h
		jz	hint_exit_set			; Jump if zero
		retn

hint_exit_set:
		mov	si,0B317h
		or	kenj_input_flags,10h
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,8
		jz	hint_spirits_set			; Jump if zero
		retn

hint_spirits_set:
		mov	si,0B38Ch
		or	kenj_input_flags,8
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,4
		jz	hint_demons_set			; Jump if zero
		retn

hint_demons_set:
		mov	si,0B400h
		or	kenj_input_flags,4
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,2
		jz	hint_silkarn_set			; Jump if zero
		retn

hint_silkarn_set:
		mov	si,0B488h
		or	kenj_input_flags,2
		retn
			                        ;* No entry point to code
		test	kenj_input_flags,1
		jz	hint_indihar_set			; Jump if zero
		retn

hint_indihar_set:
		mov	si,sage_indihar_hint
		or	kenj_input_flags,1
		retn
			                        ;* No entry point to code
		add	[bp+si],bx
		dec	bx
		inc	bp
		dec	si
		dec	dx
		pop	cx
		inc	cx
; -- ref_kenja_grp_tail: trailing chars of "KENJ.GRP",0 + sage_cmd_msg_tbl.
;    sage_cmd_msg_tbl is an 8-entry word table -> per-sage banner-msg pointers.
		db	 2Eh, 47h, 52h, 50h, 00h,0CDh	; '.GRP',00 + first ptr lo (CD)
		db	0ACh,0DFh,0ACh,0F2h,0ACh, 05h	; ptrs ACCD, ACDF, ACF2, AD05 (sages 0-3)
		db	0ADh, 19h,0ADh, 2Ch,0ADh, 3Fh	; ptr cont + ptrs AD19, AD2C, AD3F (sages 4-6)
		db	0ADh, 51h,0ADh, 16h,0AFh, 00h	; ptr cont + AD51 (sage 7) + start of header AF16
		db	 0Eh				; banner len = 14 ('The Sage Marid')
		db	'The Sage Marid'
		db	 15h,0AFh, 00h, 0Fh		; banner hdr: pos AF15, attr 00, len 0F
		db	'The Sage Yasmin'
		db	 14h,0AFh, 00h, 0Fh		; banner hdr: pos AF14
		db	'The Sage Hajjar'
		db	 14h,0AFh, 02h, 10h		; banner hdr: pos AF14, attr 02, len 16 ('The Sage Chiriga')
		db	'The Sage Chiriga'
		db	 14h,0AFh, 00h, 0Fh		; banner hdr: pos AF14
		db	'The Sage Hisham'
		db	 14h,0AFh, 00h, 0Fh		; banner hdr
		db	'The Sage Maryam'
		db	 15h,0AFh, 00h, 0Eh		; banner hdr: len 14 ('The Sage Saied')
		db	'The Sage Saied'
		db	 14h,0AFh, 00h, 10h		; banner hdr: pos AF14, attr 00, len 16 ('The Sage Indihar')
kenj_str_outside_at_7		db	'The Sage IndiharGo outside', 0
		db	'See Power', 0
		db	'Listen Knowledge', 0
		db	'Record Experience', 0
		db	0Ch, 'How can I help you, Brav'		; CR + opening text
		db	 65h, 20h, 4Fh, 6Eh, 65h, 3Fh	; 'e One?'
		db	 2Fh,0FFh, 00h			; '/' + SCR_END opcode 00
		db	0Ch, 'Is there anything else I ca'	; CR + text
		db	'n do for you?/'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'The Spirits are with you.'	; CR + text (See Power success)
		db	 11h,0FFh,0FFh, 0Ch		; ANIM-prefix + SCR_END terminator + CR
kenj_str_spirits_anchor		db	'I shall call upon the Spirits an'
		db	'd their po'
		db	'wers..... /'
		db	0FFh, 04h,0FFh, 01h		; SCR_END opcode 04 + 01
		db	0Ch, 'I fear the spirits are no l'	; CR + text
		db	'onger with you. No matter how ma'
		db	'ny times I try, it comes out'
		db	' the same. '
		db	0FFh, 00h, 0Ch			; SCR_END 00 + CR
		db	'You are brave, but your experien'
		db	'ce is lacking. Come back when yo'
		db	'u have accomplished more.'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'I can no longer impart the '	; CR + text (max-blessing reached)
		db	'power of the Spirits to you. Con'
		db	'tinue on your quest. You will so'
		db	'on find others to help you.'
		db	0FFh, 00h			; SCR_END opcode 00
		db	0Ch, 'I shall record your experie'	; CR + text (Record Experience prompt)
		db	'nces./'
		db	0FFh, 03h			; SCR_END opcode 03
		db	'Place is saved on user disk. Wil'
		db	'l you continue your quest?'
		db	0FFh, 02h,0FFh, 06h, 13h,0FFh	; SCR_END 02 + 06 + 13h + SCR_END
		db	 04h				; SCR_END opcode 04 (continued)
		db	4Fh				; 'O' first char of next line
		db	'h, Holy Spirits, purify my thoug'
		db	'hts and grant me strength. '
		db	0FFh, 04h,0FFh, 04h, 0Dh, 15h	; SCR_END 04 + 04 + CR + 15
		db	0FFh, 00h,0FFh, 00h,0FFh,0FFh	; SCR_END 00 + 00 + SCR_END terminator
; -- sage_blessing_tbl: 5-entry word table -> blessing-tier text pointers
;    indexed by tier (0..4 from sage_hp_check).
kenjp_blessing_text_ptrs:
		db	 33h,0B0h, 69h,0B0h, 8Fh,0B0h	; tier 0..2: ptrs B033, B069, B08F
		db	0E2h,0B0h, 3Fh,0B1h		; tier 3..4: ptrs B0E2, B13F
		db	59h				; 'Y' first char of tier-0 text
		db	'our experience is lacking. Perse'
		db	'vere in your quest.'
		db	0FFh, 00h			; SCR_END opcode 00
		db	'You must accumulate more experie'
		db	'nce.'
		db	0FFh, 00h			; SCR_END opcode 00
		db	'I can see the faint light of the'
		db	' Spirits in you. You must endure'
		db	' a little longer.'
		db	0FFh, 00h			; SCR_END opcode 00
		db	'The light of the Spirits is burs'
		db	'ting forth within you. '
		db	0FFh, 04h			; SCR_END opcode 04
		db	0Dh, 'Indeed, your power has grow'	; CR + text (max-blessing)
		db	'n.'
		db	0FFh, 05h,0FFh, 04h,0FFh, 00h	; SCR_END 05 + 04 + 00
		db	'I can no longer impart the power'
		db	' of the Spirits to you. Continue'
		db	' on your quest. You'
		db	' wi'
		db	'll so'
		db	'on find others to help you. '
		db	0FFh, 00h, 49h, 20h		; SCR_END 00 + 'I '
		db	'am the Sage Marid./You are very '
		db	'brave to embark on such a danger'
		db	'ous journey. I&shall assist you '
		db	'i'
		db	'n your travels. '
		db	0FFh, 00h, 49h, 20h		; SCR_END 00 + 'I '
		db	'am the Sage Yasmin./I have been '
		db	'expecting you. I&shall teach you'
		db	' the Magic Spell of Throwing '
		db	'Swords: Espada.'
		db	0FFh, 07h,0FFh, 00h		; SCR_END opcode 07 + 00
		db	'I am the Sage Hajjar./I am happy'
		db	' to see you\ve made it this far.'
		db	' I&shall teach you the'
		db	' Magic Spell of Arrows: Saeta.'
		db	0FFh, 08h,0FFh, 00h		; SCR_END opcode 08 + 00
		db	'I am the Sage Chiriga./You have '
		db	'come far, and you must be cold. '
		db	'I&shall teach you the Magic '
		db	'Spell of Fire: Fuego.'
		db	0FFh, 09h,0FFh, 00h		; SCR_END opcode 09 + 00
		db	'I am the Sage Hisham./You are do'
		db	'ing well to stand before me. I&s'
		db	'hall teach you '
		db	'the Magic '
		db	'Spell of Flame: Lanzar.'
		db	0FFh, 0Ah,0FFh, 00h		; SCR_END opcode 0A + 00
		db	'I am the Sage Maryam./You have m'
		db	'ade the Spirits proud with your '
		db	'bravery. I&shall teach you the M'
		db	'agic Spell of Falling Rocks: Ras'
		db	'car.'
		db	0FFh, 0Bh,0FFh, 00h		; SCR_END opcode 0B + 00
		db	'I am the Sage Saied./You have li'
		db	'ved through much, but your journ'
		db	'ey is not over. You must be hot.'
		db	' I&shall teach you the Magic Spe'
		db	'll of Water: Agua.'
		db	0FFh, 0Ch,0FFh, 00h		; SCR_END opcode 0C + 00
		db	'I am the Sage of All Sages, Indi'
		db	'har./Brave lad, you\ve done well'
		db	' to get this far./'
		db	0Fh				; opcode 0F (Indihar special)
		db	'I&shall teach you the Magic Spel'
		db	'l of Lightning: Guerra.'
		db	0FFh, 0Dh,0FFh, 00h		; SCR_END opcode 0D + 00
		db	'      Disk error.', 0Dh, 'Please'
		db	' check your disk', 0Dh, '  and p'
		db	'ress spacebar.'
; -- sage_hint_ptr_tbl: 8-entry word table of per-sage knowledge-hint pointers,
;    indexed by sage_id-1 (matches the 8 hints below).
kenjp_sage_hint_ptr_tbl:
		db	0FFh,0FBh,0B5h, 70h,0B6h,0EBh	; SCR_END marker + ptrs B5FB, B670, B6EB
		db	0B6h, 6Dh,0B7h, 1Ch,0B8h,0B2h	; ptrs B66D (alias), B71C, B8B2
		db	0B8h, 54h,0B9h,0AFh,0B9h		; ptrs B8B2 cont, B954, B9AF
; -- per-sage hint texts (8 hints, each ends with 11h,FFh,00h,0C = ANIM + SCR_END + CR)
; Hint 0 (Marid)
		db	0Ch, 'My master, the Sage Yasmin,'	; CR + text
		db	' resides in the underground town'
		db	'. She is a person you can turn t'
		db	'o if you are in need. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM-prefix + SCR_END opcode 00 + CR
; Hint 1 (Yasmin)
		db	'When you leave the city, climb t'
		db	'o the plateau on the left. You\l'
		db	'l see a door that looks like the'
		db	' exit from this world. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
; Hint 2 (Hajjar)
		db	'The exit from this world is very'
		db	' near the exit from the village.'
		db	' However, before you go there yo'
		db	'u must have the Hero\s Crest. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
; Hint 3 (Chiriga)
		db	'This is a message from the Spiri'
		db	'ts: Bend when you walk a low roa'
		db	'd. Walk not on the steep path wi'
		db	'th the needles of ice, choose an'
		db	'other path instead. Heed well th'
		db	'ese words. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
; Hint 4 (Hisham)
		db	'You can\t defeat the demons at t'
		db	'he edge of the badlands without '
		db	'the Knight\s Sword. Until you ge'
		db	't that sword, do not open the do'
		db	'or of the demons. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
; Hint 5 (Maryam)
		db	'Once you leave this world, get t'
		db	'he Silkarn shoes made by the spi'
		db	'rits at the behest of Percel. If'
		db	' you do not get those, you canno'
		db	't travel far from this world. '
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
; Hint 6 (Saied)
		db	'That world is controlled by drag'
		db	'ons. To get there, you have to o'
		db	'pen three closed doors.'
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR
		db	'At the edge of this world is the'
		db	' final foe, Jashiin./To fight Ja'
		db	'shiin, you must have the Sword o'
		db	'f the Fairy Flame. And to get th'
		db	'ere, you must topple the invinci'
		db	'ble monster Alguien.'
		db	 11h,0FFh, 00h, 0Ch		; ANIM + SCR_END 00 + CR (end Indihar hint)
; -- "wake up" / departure script (post-record, played after save)
		db	'While you were unconscious, the '
		db	'spirits brought you here./'
		db	0FFh, 04h,0FFh, 04h		; SCR_END opcode 04 + 04
		db	'Be careful not to exhaust yourse'
		db	'lf in battle./'
		db	0FFh, 04h			; SCR_END opcode 04
		db	'Now be on your way. '
		db	0FFh, 04h, 54h			; SCR_END opcode 04 + 'T' (start of next phrase)
		db	'he spirits ar'
		db	'e looking after you. '
		db	 11h,0FFh,0FFh, 00h		; ANIM-prefix + SCR_END terminator + 00
		db	42 dup (0)			; trailing pad to chunk boundary

seg_a		ends

		end	start
