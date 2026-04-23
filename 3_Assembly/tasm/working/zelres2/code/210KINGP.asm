
PAGE  59,132

;==========================================================================
;
;  210KINGP - King's Palace Dialog Program (KINGPRO.BIN, zelres2 chunk 10)
;
;  Throne-room dialog module for the King of Felishika. Runs when the
;  player enters the palace in Felishika town. Drives a script bytecode
;  loop with king-portrait animation (eyes/mouth) and three branches:
;    * First visit  - quest briefing, awards 1000 gold
;    * Return visit - reminder / "have you defeated Jashiin?"
;    * Post-victory - thanks + direction to Princess Felicia's chamber
;
;  Uses the standard town-building dispatch: chunk loader fills scratch
;  buffer, graphics driver renders the portrait tile-grid, and the game
;  script interpreter at cs:[6004] walks the dialog bytestream. Returns
;  to town via jmp cs:[2040] (gfx_return).
;
;  Module loads at game_seg:0A000h (CS=DS).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; External data references (outside this module's CS segment).

; --- Graphics driver function table (drv_seg base 2000h) -------------------
gfx_fill_rect		equ	2000h		;* fill tile-rect (bx=pos, cx=size, al=color)
gfx_init_a		equ	2002h		;* graphics init A (shop entry)
gfx_draw_banner		equ	2010h		;* draw title banner/string (si=text ptr)
gfx_init_b		equ	2012h		;* graphics init B (post-load)
gfx_wait_refresh	equ	2016h		;* wait-frame / refresh panel
gfx_return		equ	2040h		;* jmp target on script end (leave palace)
gfx_copy_buffer		equ	2044h		;* copy cx bytes from si to panel buffer

draw_glyph_tile		equ	3016h		;* draw single glyph at bx=row/col, al=glyph

; --- Game API (cs:[6004..6012]) script/menu subsystem ---------------------
script_read_byte	equ	6004h		;* read next script command byte -> al

; --- Game-segment global variables (game_seg:0FFxx via DS) ----------------
gvar_frame_timer	equ	0FF1Ah		;* frame timer counter (incremented by ISR)
gvar_game_seg		equ	0FF2Ch		;* game data segment selector word
gvar_script_ip		equ	0FF4Ch		;* current script byte-pointer (word)
gvar_text_x		equ	0FF4Eh		;* text/menu flag A (zeroed at init)
gvar_text_y		equ	0FF4Fh		;* text/menu flag B (zeroed at init)
gvar_menu_step		equ	0FF50h		;* generic step counter (word, compared to 4)
gvar_volume		equ	0FF75h		;* music/effect volume byte

; --- Internal module labels (CS-relative = module_offset + 0A000h) --------
; The module is loaded at game_seg:0A000h, so cs:0A0xxh addresses map to
; module offset 0xxxh. These EQUs pin the offsets Sourcer generated.

dispatch_tbl_base	equ	0A078h		;* script-cmd dispatch table base (words @ +4..+0B)
shop_entry_init		equ	0A302h		;* module header byte (probes whole module)
face_frame_seq		equ	0A0F8h		;* face/crown frame sequence (12 bytes)
portrait_tile_src	equ	0A16Eh		;* king portrait tile indices (96 bytes = 8×12)
portrait_ptr_tbl	equ	0A1CEh		;* per-variant portrait pointer table (word array)
face_phase_xlat		equ	0A360h		;* XLAT: frame-counter -> face phase (26 bytes)
face_anim_tbl		equ	0A37Ah		;* face-anim glyph sets (4 bytes/set × N)
mouth_anim_tbl		equ	0A3D4h		;* mouth-anim glyph sets (10 bytes × 2)

; --- Animation state variables (CS-resident, in padding after code) -------
mouth_mode_flag		equ	0A79Dh		;* mouth animation enable flag byte
mouth_phase_cnt		equ	0A79Eh		;* mouth animation phase counter byte
mouth_set_idx		equ	0A79Fh		;* mouth animation set index byte
face_mode_flag		equ	0A7A0h		;* face animation enable flag byte
face_phase_cnt		equ	0A7A1h		;* face animation phase counter byte

; --- Chunk-loader parameter fields (game_seg:[5]/[6]) ---------------------
dialog_done_flag	equ	5		;* game-state: dialog complete flag byte
dialog_done_flag_b	equ	6		;* game-state: dialog complete flag byte B

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

kingp_main	proc	far

start:
		mov	byte ptr ds:[7],al
		add	[si],al
		mov	al,ds:shop_entry_init
		mov	es,ds:gvar_game_seg
		mov	di,8000h
		mov	si,0A40Fh		; chunk-ref for portrait/background
		mov	al,2
		call	word ptr cs:[10Ch]	; SAR chunk loader
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:gfx_copy_buffer
		pop	ds
		mov	byte ptr ds:gvar_text_x,0
		mov	byte ptr ds:gvar_text_y,0
		call	word ptr cs:gfx_init_a
		call	word ptr cs:gfx_init_b
		mov	si,0A41Ah		; title-banner text ('King of Felishika')
		call	word ptr cs:gfx_draw_banner
		call	render_portrait
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:gfx_fill_rect
		call	select_script_branch
		mov	ds:gvar_script_ip,si
script_loop:
		call	word ptr cs:script_read_byte
		cmp	al,0FFh
		je	script_exit		; 0FFh = end of script
		call	script_cmd_dispatch
		jmp	short script_loop
script_exit:
		jmp	word ptr cs:gfx_return

kingp_main	endp


script_cmd_dispatch	proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:dispatch_tbl_base[bx]	; dispatch on script cmd byte
script_cmd_dispatch	endp

; -- Dispatch table words at module offset 0x7C-0x83 (indexed by bl=al*2).
; -- Only cmd values 2..5 hit defined handlers; other values are garbage-
; -- bounded by the enclosing script.
;
; Byte layout at 0x7C-0x83 (TASM emits as 'in al,0A0h' + 'call far' bogus
; decodes because Sourcer tried to disassemble the table as code):
;   [7C] E4 A0  -> 0xA0E4 = dispatch_cmd_wait_long  (cmd 2, wait 150 frames)
;   [7E] 9A A0  -> 0xA09A = dispatch_cmd_face_on    (cmd 3, jmps loc_mouth_tick)
;   [80] D4 A0  -> 0xA0D4 = dispatch_cmd_set_done   (cmd 4, set dialog_done_flag)
;   [82] 92 A0  -> 0xA092 = dispatch_cmd_mouth_off  (cmd 5, jmps loc_mouth_tick)

		;* dispatch table entries at 0x7C (decoded bogusly as instructions)
		in	al,0A0h			; 0x7C: E4 A0 = dispatch word 0xA0E4 (wait_long)
		db	09Ah, 0A0h, 0D4h, 0A0h, 092h	; 0x7E-0x82: words A09A, A0D4, partial A092

; -- Orphan handler: script cmd 5 (mouth-anim disable + tick).
; Reached via dispatch[5] = 0xA092 which lands at the jmp below. The three
; preceding instructions (xor al,al / mov mouth_mode_flag,al) execute only
; by fall-through from the garbage-decoded table bytes above, and are a
; separate dispatch target that the script can patch in at runtime.
;
; Layout: 0x83-0x8C form the fall-through mouth-off helper, 0x92 is the
; actual dispatch[5] target (jmp-only).
		mov	al,ds:[0A084h]		; 0x83: reads dispatch table word (self-ref garbage)
		mov	ah,data_portrait_tail[bx+si]	; 0x86: 8A A0 C5 06  (bogus decode of table)
		popf				; 0x8A: 9D  (table byte)
		cmpsw				; 0x8B: A7  (table byte)
		db	0FFh, 0C3h		; 0x8C: inc bx (alt encoding: FF /0 not 43 short form)

mouth_anim_disable:				; fall-through entry: clears mouth anim flag
		xor	al,al			; Zero register
		mov	ds:mouth_mode_flag,al
		jmp	loc_mouth_tick		; 0x92: jmp (dispatch[5] target)

; -- Orphan handler: script cmd 3 (face-anim enable + tick).
; Reached via dispatch[3] = 0xA09A which lands at the jmp at 0x9A.
; The 5 preceding bytes (mov al,0FFh / mov face_mode_flag,al) are the
; face-enable prologue.
face_anim_enable:
		mov	al,0FFh
		mov	ds:face_mode_flag,al
		jmp	loc_mouth_tick		; 0x9A: jmp (dispatch[3] target)

; -- Orphan entry: award 1000 gold.
; Falls through into gold_add_loop which runs 10 iterations adding 100
; gold each + waiting 0x0F frames. Total: 1000 gold, ~150 frames.
		db	0B9h, 0Ah, 00h		; mov cx, 10  (alt encoding entry to loop)

gold_add_loop:
		push	cx
		mov	ax,word ptr ds:[86h]	; gold low word
		mov	dl,byte ptr ds:[85h]	; gold high byte
		add	ax,64h			; += 100
		adc	dl,0
		mov	word ptr ds:[86h],ax
		mov	byte ptr ds:[85h],dl
		call	word ptr cs:gfx_wait_refresh
		mov	byte ptr ds:gvar_volume,13h
		mov	byte ptr ds:gvar_frame_timer,0
gold_add_wait:
		call	face_anim_tick
		cmp	byte ptr ds:gvar_frame_timer,0Fh
		jb	gold_add_wait		; Jump if below
		pop	cx
		loop	gold_add_loop		; Loop if cx > 0

		mov	byte ptr ds:dialog_done_flag,0FFh
		retn

; -- Orphan entry: initialize frame-timer before wait.
; This 5-byte block `mov [gvar_frame_timer],0` (C6 06 1A FF 00) is the
; prologue for the long-wait handler at dispatch_cmd_wait_long.
		db	0C6h, 06h, 1Ah, 0FFh, 00h	; mov byte ptr ds:[gvar_frame_timer],0

dispatch_cmd_wait_long:				; dispatch[2] = 0xA0E4: wait 150 frames
		call	face_anim_tick
		cmp	byte ptr ds:gvar_frame_timer,96h	; 150 frames
		jb	dispatch_cmd_wait_long	; Jump if below
		retn

; -- Orphan entry: render portrait frame sequence.
; 15-byte helper that walks face_frame_seq (12 bytes) calling
; render_portrait_variant + short_wait for each. Used as an alternate
; dispatch entry point.
portrait_play_seq:
		mov	si,face_frame_seq
		mov	cx,0Ch			; 12 frames

portrait_play_loop:
		push	cx
		lodsb				; String [si] to al
		push	si
		call	render_portrait_variant
		call	short_wait
		pop	si
		pop	cx
		loop	portrait_play_loop	; Loop if cx > 0

		retn
		db	0, 0, 1, 2, 2, 1	; portrait frame phase pattern
		db	0, 3, 4, 4, 5, 6	; portrait frame phase pattern


short_wait	proc	near
		mov	byte ptr ds:gvar_frame_timer,0
short_wait_loop:
		call	face_anim_tick
		cmp	byte ptr ds:gvar_frame_timer,19h	; 25 frames
		jb	short_wait_loop		; Jump if below
		retn
short_wait	endp


render_portrait	proc	near
		mov	si,portrait_tile_src
		mov	bx,0E17h			; start row/col position (bh=row, bl=col-ish)
		mov	cx,8				; 8 rows

portrait_row_loop:
		push	cx
		mov	cx,0Ch			; 12 tiles per row

portrait_col_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:draw_glyph_tile
		pop	bx
		inc	bh
		pop	cx
		loop	portrait_col_loop	; Loop if cx > 0

		sub	bh,0Ch
		add	bl,8
		pop	cx
		loop	portrait_row_loop	; Loop if cx > 0

		test	byte ptr ds:[49h],0FFh	; quest-complete flag?
		jnz	render_portrait_alt	; Jump if not zero
		retn
render_portrait_alt:
		mov	al,6			; alternate portrait variant
render_portrait	endp
		; fall-through into render_portrait_variant


render_portrait_variant	proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:portrait_ptr_tbl[bx]
		mov	bx,1117h
		mov	cx,7			; 7 rows

portrait_var_row_loop:
		push	cx
		mov	cx,6			; 6 cells per row

portrait_var_col_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:draw_glyph_tile
		pop	bx
		inc	bh
		pop	cx
		loop	portrait_var_col_loop	; Loop if cx > 0

		sub	bh,6
		add	bl,8
		pop	cx
		loop	portrait_var_row_loop	; Loop if cx > 0

		retn
render_portrait_variant	endp

; -- Portrait variant tile data (8 frames × variable layout).
; Indexed via portrait_ptr_tbl. Each record is 7 rows × 6 glyphs.
; Glyph indices point into the game's tile/character set.
portrait_variant_data:
		db	 00h, 01h, 02h, 03h, 3Eh, 3Fh	; base frame row 0
		db	 40h, 41h, 18h, 19h, 1Ah, 1Bh	; row 1
		db	 04h, 05h, 06h, 07h, 42h, 43h	; row 2
		db	 44h, 45h, 1Ch, 1Dh, 1Eh, 1Fh	; row 3
		db	8, 9, 0Ah, 'FGHIJK !"'		; row 4 (mix of tile ids + text glyphs)
		db	0Bh
		db	0Ch, 0Dh, 'LMNOPQ#$'		; row 5
		db	'%'
		db	 0Eh, 0Fh, 10h
		db	'RSTUVW&', 27h, '('		; row 6
		db	 11h, 12h, 13h
		db	'XYZ[\)*+,'
		db	 14h, 15h, 16h, 17h
		db	']^_-./0123456789:;<='
		db	0DCh,0A1h, 06h,0A2h, 30h,0A2h	; variant pointer words (embedded)
		db	 5Ah,0A2h, 84h,0A2h,0AEh,0A2h
		db	0D8h,0A2h, 03h, 3Eh, 3Fh, 40h	; variant 2 data begins
		db	 41h, 18h, 07h, 42h, 43h, 44h
		db	 45h, 1Ch
		db	'FGHIJKLMNOPQRSTUVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 3Eh, 3Fh, 40h, 41h, 18h
		db	 07h, 42h, 43h, 44h, 45h, 1Ch
		db	'FGHIJKLMNOPQR`abVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 3Eh, 3Fh, 40h, 41h, 18h
		db	 07h, 42h, 43h, 44h, 45h, 1Ch
		db	'FGHIJKLMNOPQRcdeVWXYZ[\)'
		db	 17h, 5Dh, 5Eh, 5Fh, 2Dh, 2Eh
		db	 03h, 66h, 67h, 68h, 69h, 18h
		db	 07h, 6Ah, 6Bh, 6Ch, 6Dh, 1Ch
		db	'nopqrstuvwxyz{|}~'
		db	 7Fh, 80h, 81h, 82h, 83h, 84h
		db	 29h, 17h, 85h, 86h, 87h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h,0ADh,0ABh,0AEh, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h,0AAh,0ABh,0ACh, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h, 2Dh
		db	 2Eh, 03h, 88h, 89h, 8Ah, 8Bh
		db	 18h, 07h, 8Ch, 8Dh, 8Eh, 8Fh
		db	 1Ch, 90h, 91h, 92h, 93h, 94h
		db	 95h, 96h, 97h, 98h, 99h, 9Ah
		db	 9Bh, 9Ch, 9Dh, 9Eh, 9Fh,0A0h
		db	0A1h,0A2h,0A3h,0A4h,0A5h,0A6h
		db	 29h, 17h,0A7h,0A8h,0A9h
		db	 2Dh, 2Eh


face_anim_tick	proc	near
		cmp	word ptr ds:gvar_menu_step,4
		jae	face_anim_run		; Jump if above or =
		retn
face_anim_run:
		mov	word ptr ds:gvar_menu_step,0
		call	face_mode_update
		jmp	short mouth_mode_update

; -- Entry used by fall-through from gfx refresh path -------------------
face_mode_update:
		test	byte ptr ds:face_mode_flag,0FFh
		jnz	face_phase_inc		; Jump if not zero
		retn
face_phase_inc:
		inc	byte ptr ds:face_phase_cnt
		cmp	byte ptr ds:face_phase_cnt,1Ah	; 26-frame cycle
		jb	face_phase_apply	; Jump if below
		call	word ptr cs:[11Ah]	; driver fn: check input / next page
		or	al,al			; Zero ?
		jz	face_phase_reset	; Jump if zero
		retn
face_phase_reset:
		mov	byte ptr ds:face_phase_cnt,0FFh
		retn
face_phase_apply:
		mov	bx,face_phase_xlat
		mov	al,ds:face_phase_cnt
		xlat				; al = face_phase_xlat[face_phase_cnt]
		xor	ah,ah			; Zero register
		add	ax,ax			; ax *= 4 (4 bytes per face glyph set)
		add	ax,ax
		mov	si,ax
		add	si,face_anim_tbl	; si -> current face glyph set
		mov	bx,112Fh		; screen position for face area
		mov	cx,4			; 4 glyphs per face row

face_glyph_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:draw_glyph_tile
		pop	bx
		inc	bh
		pop	cx
		loop	face_glyph_loop		; Loop if cx > 0

		retn
; -- face_phase_xlat: 26 bytes at 0x360, maps face_phase_cnt to glyph-set
;    index (values 0/1/2). Falls under face_anim_tick so label is reached
;    via XLAT (mov bx,face_phase_xlat + xlat).
		db	 00h, 00h, 00h, 00h, 00h, 00h	; face_phase_xlat[0..5]
		db	 01h, 01h, 01h, 01h, 01h, 02h	; [6..11]
		db	 02h, 02h, 02h, 02h, 01h, 01h	; [12..17]
		db	 01h, 01h, 01h, 00h, 00h, 00h	; [18..23]
		db	 00h, 00h, 96h, 97h, 98h, 99h	; [24..25] + face_anim_tbl[0..3] (set 0)
		db	 96h,0AAh,0ABh,0ACh, 96h,0ADh	; face_anim_tbl[4..11] (sets 1,2a)
		db	0ABh,0AEh			; face_anim_tbl[12..13] continues
mouth_mode_update:
		test	byte ptr ds:mouth_mode_flag,0FFh
		jnz	mouth_phase_inc		; Jump if not zero
		retn
mouth_phase_inc:
		inc	byte ptr ds:mouth_phase_cnt
		cmp	byte ptr ds:mouth_phase_cnt,6	; 6-frame cycle
		jae	mouth_phase_apply	; Jump if above or =
		retn
mouth_phase_apply:
		mov	byte ptr ds:mouth_phase_cnt,0
		inc	byte ptr ds:mouth_set_idx
		mov	al,ds:mouth_set_idx
loc_mouth_tick:					; external jmp target (dispatch[3],[5])
		and	al,1			; select set 0 or 1
		mov	cl,0Ah
		mul	cl			; ax = al * 10 (10 bytes per mouth set)
		mov	si,ax
		add	si,mouth_anim_tbl	; si -> current mouth glyph set
		mov	bx,113Fh		; screen position for mouth area
		mov	cx,2			; 2 rows

mouth_row_loop:
		push	cx
		mov	cx,5			; 5 glyphs per row

mouth_glyph_loop:
		push	cx
		push	bx
		lodsb				; String [si] to al
		call	word ptr cs:draw_glyph_tile
		pop	bx
		inc	bh
		pop	cx
		loop	mouth_glyph_loop	; Loop if cx > 0

		sub	bh,5
		add	bl,8
		pop	cx
		loop	mouth_row_loop		; Loop if cx > 0

		retn
face_anim_tick	endp

; -- Tail bytes of mouth_anim_tbl (starts at 0x3D4 inside the code above).
;    The 20-byte mouth table occupies 0x3D4-0x3E7. Bytes 0x3D7-0x3EB are
;    Sourcer-decoded instructions that are actually mouth glyph data.
		;* Mouth glyph data tail (Sourcer decoded as instructions)
		mov	ds:[0A4A3h],al		; 0x3D7: A2 A3 A4 = mouth glyph bytes
		movsw				; 0x3DA: A5 = mouth glyph 0xA5
		cmpsb				; 0x3DB: A6 = mouth glyph 0xA6
		pop	ss			; 0x3DC: 17 = separator 0x17
		cmpsw				; 0x3DD: A7 = mouth glyph 0xA7
		test	al,0A9h			; 0x3DE: A8 A9 = mouth glyphs
		sub	ax,0B0AFh		; 0x3E0: 2D AF B0 = 0x2D separator + mouth 0xAF,0xB0
		mov	cl,0B2h			; 0x3E3: B1 B2 = mouth glyphs 0xB1,0xB2
		mov	bl,17h			; 0x3E5: B3 17 = mouth 0xB3 + separator 0x17
		mov	ah,0B5h			; 0x3E7: B4 B5 = mouth glyphs 0xB4,0xB5
		mov	dh,2Dh			; 0x3E9: B6 2D = mouth 0xB6 + separator 0x2D


; -- Select dialog script address based on current quest state ------------
; Flags tested (game-segment DS):
;   [5]:  dialog-done flag (set to FF by dispatch_cmd_set_done)
;   [6]:  dialog-done flag B
;   [49h]: quest-complete flag (Tears of Esmesanti returned)
; Returns si = script_ip to run.
select_script_branch	proc	near
		mov	si,0A42Fh		; default: first-visit briefing script
		mov	al,byte ptr ds:dialog_done_flag
		or	al,byte ptr ds:dialog_done_flag_b
		jnz	branch_chk_flag_b	; first visit: return default
		retn
branch_chk_flag_b:
		mov	si,0A53Ch		; second visit: "did you forget..."
		test	byte ptr ds:dialog_done_flag_b,0FFh
		jnz	branch_chk_quest_done	; Jump if not zero
		retn
branch_chk_quest_done:
		mov	si,0A5D2h		; third visit: "please hurry" nag
		test	byte ptr ds:[49h],0FFh	; quest-complete flag
		jnz	branch_post_victory	; Jump if not zero
		retn
branch_post_victory:
		mov	si,0A6C1h		; post-victory: thank you + Felicia
		retn
select_script_branch	endp

; -- Orphan: reached via the 6th dispatch case (byte pattern that Sourcer
;    decoded as 'add [bp+di],dx' etc. are part of the script text tail).
;    These 6 bytes (01 13 4B 49 4E 47 = ??? 'KING') align with a chunk
;    reference header 'KING' spilling into script data. Kept as db-bytes
;    with the script data that follows.
		;* Script-data tail header bytes decoded as instructions by Sourcer
		db	 01h, 13h		; script seg+offset (01=kind, 13=offset?)
		db	 4Bh, 49h, 4Eh, 47h	; 'KING'
		db	 2Eh, 47h, 52h, 50h, 00h, 13h	; '.GRP',00,13 chunk header
		db	0AFh, 00h, 11h		; 00 11 = layout/clear

; -- Script bytecode for King's Palace dialog (first visit) --------------
; Control codes: 0xFF = function call, 0x0C = scroll/clear, 0x0D = CR,
; 0x11 = small-pause? 0xFFxx = two-byte dispatch. Strings are rendered
; as text between control sequences.
		db	'King of Felishika', 0Ch
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Brave Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'you\ll need money for your journ'
		db	'ey./I&hereby bestow upon you 100'
		db	'0&Go'
		db	 6Ch, 64h, 73h, 2Eh,0FFh, 05h	; 'lds.', 0FF, 05
		db	0FFh, 02h,0FFh, 01h, 0Dh,0FFh
		db	 04h
		db	'Go to town and outfit yourself, '
		db	'then make haste to the labyrinth'
		db	' to defeat the forces of Jashiin'
		db	'. My kingdom and the life of my '
		db	'daughter are at stake.'
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
; -- Second-visit script: "did you forget something?" --------------------
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Brave Duke, did you forget somet'
		db	'hing?'
		db	0FFh, 05h,0FFh, 02h, 0Dh,0FFh
		db	 04h
		db	'The entrance to the labyrinth is'
		db	' at the edge of town.'
		db	0FFh, 05h, 0Dh,0FFh, 04h
		db	'Please hurry, before it\s too la'
		db	'te! '
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
; -- Third-visit script: "I am in debt to you" (quest incomplete) --------
		db	0FFh, 00h,0FFh, 03h,0FFh, 04h
		db	'Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'I am in debt to you for your eff'
		db	'orts. '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'Have you not yet succeeded in va'
		db	'nquishing Jash'
		db	 69h, 69h, 6Eh, 3Fh, 20h,0FFh	; 'iin? ', 0FF
		db	 05h,0FFh, 02h, 0Dh,0FFh, 04h
		db	'I pray that the spirits will gui'
		db	'de you. Please don\t give up, th'
		db	'e people of Zeliard are dependin'
		db	'g on you!'
		db	0FFh, 05h, 11h,0FFh,0FFh, 0Ch
; -- Post-victory script at 0x6C5: "You have conquered Jashiin" ----------
data_portrait_tail	db	0FFh		; ah-table base (referenced via [bx+si+06C5] XLAT)
		db	 03h,0FFh, 04h
		db	'Duke Garland, '
		db	0FFh, 05h,0FFh, 02h,0FFh, 04h
		db	'you are a brave man. You have co'
		db	'nquered Jashiin and returned the'
		db	' nine Tears of Esmesanti. '
		db	0FFh, 05h,0FFh, 02h, 0Dh,0FFh
		db	 04h
		db	'Now go quickly to the chamber of'
		db	' Princess Felicia. The&crystals '
		db	'will bring her back to life. '
		db	0FFh, 05h, 11h,0FFh,0FFh, 00h
		db	 00h, 00h, 00h, 00h		; module trailing padding

seg_a		ends



		end	start
