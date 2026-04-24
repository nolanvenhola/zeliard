
PAGE  59,132

;==========================================================================
;
;  214CHURP - Church Dialog Program (zelres2 chunk 16)
;
;  Church NPC program: "The Church" dialog for rest/healing.
;  Delivers the "Brave Knight..." lines inviting the hero to rest and
;  have the Holy Spirit heal him.  No menu -- the script runs through
;  a sequence of dialog pages, then returns to town.
;
;  Loaded at gvar_game_seg:loaded_code_a (0x3000) by town.bin when the
;  player enters the church building.
;
;  Related to 213BANKP / 215DRUGP / 217KENJP -- same building-program
;  template (load sprite, draw intro tile grid, fill rect, dispatch
;  script opcodes until 0xFF, return).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.

sprite_buf_ofs		equ	8000h			;* sprite staging buffer (game_seg)
drv_fill_rect		equ	2000h			;* driver: fill rect with color
drv_screen_init_a	equ	2002h			;* driver: screen init stage A
drv_palette_push	equ	2008h			;* driver: palette push / refresh panel
drv_load_msg_header	equ	2010h			;* driver: load message/title header
drv_screen_init_b	equ	2012h			;* driver: screen init stage B
drv_anim_step		equ	2018h			;* driver: advance background animation
drv_return_to_caller	equ	2040h			;* driver: return control to town.bin
drv_ds_copy		equ	2044h			;* driver: DS-based bulk byte copy
drv_draw_glyph		equ	3016h			;* driver: draw single glyph at bx
script_step		equ	6004h			;* script interpreter: step one byte
opcode_dispatch_tbl	equ	0A078h			;* script opcode dispatch table base
sermon_data_a		equ	0A089h			;* dialog/sermon glyph source A
sermon_data_b		equ	0A0CBh			;* dialog/sermon glyph source B
intro_tile_map		equ	0A177h			;* intro 12x8 tile glyph map
anim_text_ptr_a		equ	0A234h			;* animated title glyph source A
anim_text_ptr_b		equ	0A27Ch			;* animated title glyph source B
anim_phase_a		equ	0A3E4h			;* animation outer phase byte (0..4)
anim_phase_b		equ	0A3E5h			;* animation inner sub-phase byte (0..2)
gvar_timer_byte		equ	0FF1Ah			;* timer tick counter byte
gvar_game_seg		equ	0FF2Ch			;* game-code segment selector word
gvar_script_ptr		equ	0FF4Ch			;* script byte-stream pointer
gvar_init_flag_a	equ	0FF4Eh			;* init flag A (cleared on entry)
gvar_init_flag_b	equ	0FF4Fh			;* init flag B (cleared on entry)
gvar_timer_word		equ	0FF50h			;* timer word (frame-accumulator)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

church_main	proc	far

start:
	;; Offsets 0x0000-0x0009 are mis-decoded by Sourcer as `out/add/xlat` --
	;; they are actually the prelude for the 'mov ax,...; sub al,0FFh' sequence
	;; that stores the init-code pointer.  Keep as byte-perfect original bytes
	;; using the mnemonics Sourcer produced:
		out	3,al			; port 3, DMA-1 bas&cnt ch 1 (0E6h,03h)
		add	[bx+si],al		; 00h,00h
		add	al,0A0h			; 04h,0A0h  -- these bytes are the literal opcode stream
		xlat				; 0D7h       -- before sub-al runs
		mov	ax,ds:[068Eh]		; A1 8E 06 -- garbled by Sourcer; kept as raw word read
		sub	al,0FFh			; 2Ch,0FFh
		mov	di,sprite_buf_ofs
		mov	si,0A299h		; si = ref_church_grp - 4 (loader pattern)
		mov	al,2
		call	word ptr cs:[10Ch]	; chunk loader (al=2 -> SAR+fill_buffer)
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,sprite_buf_ofs
		mov	cx,100h
		call	word ptr cs:drv_ds_copy
		pop	ds
		mov	byte ptr ds:gvar_init_flag_a,0
		mov	byte ptr ds:gvar_init_flag_b,0
		call	word ptr cs:drv_screen_init_a
		call	word ptr cs:drv_screen_init_b
		mov	si,0A2A6h		; si = church_title_hdr
		call	word ptr cs:drv_load_msg_header
		call	draw_intro_12x8
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:drv_fill_rect
		call	pick_welcome_text
		mov	ds:gvar_script_ptr,si

loc_1:
			call	word ptr cs:script_step
			cmp	al,0FFh
			je	loc_2			; Jump if equal
			call	script_opcode_dispatch
			jmp	short loc_1

loc_2:
		jmp	word ptr cs:drv_return_to_caller

church_main	endp

script_opcode_dispatch	proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:opcode_dispatch_tbl[bx]	; dispatch by opcode

script_opcode_dispatch	endp

;-- Dispatch-table handlers ------------------------------------------------
;  The following blocks are reached via opcode_dispatch_tbl[bx] in
;  script_opcode_dispatch above.  Sourcer cannot trace them statically
;  because the table lives in DS (game code segment), so each one is
;  marked "No entry point to code" in the raw disassembly.

;-- Handler: opcode 0x26 (approx) -- "Go outside" / fall-through return.
;  Note: the first three bytes decoded as 'in ax,0A0h' are actually a
;  patched jump target, but the canonical byte stream is kept literal.

op_handler_a:					; reached via opcode_dispatch_tbl[bx]
		in	ax,0A0h			; port 0A0h ??I/O Non-standard
;*	and	byte ptr ds:data_25e[bx+si],99h
		and	byte ptr [bx+si-5F77h],99h	;  was: db 082h,0A0h,089h,0A0h,099h
		mov	al,ds:sermon_data_b	; reads sermon_data_b = A0CBh
		mov	word ptr ds:gvar_script_ptr,0A36Ah
		retn

;-- Handler: "rest loop" -- busy-wait until gvar_timer_byte >= 0xFA,
;  advancing the background animation each frame.  The first 3 bytes
;  decode as the start of `mov byte ptr ds:[0FF1Ah],0` but Sourcer
;  treated the 0FFh byte as the start of a word constant.
		db	0C6h, 06h, 1Ah		; mov byte ptr ds:[FF1A],... (alt encoding prefix)
rest_wait_loop	dw	00FFh			; sentinel word -- also mid-instruction 'FF 00' bytes

loc_3:
			call	anim_scroll_step
			cmp	byte ptr ds:gvar_timer_byte,0FAh
			jb	loc_3			; Jump if below
		retn

;-- Handler: bump rest_wait_loop sentinel (+8), fall through after delay.

loc_4:
			mov	ax,word ptr rest_wait_loop
			add	ax,8
			cmp	ax,word ptr ds:[0B2h]
			jae	loc_6			; Jump if above or =
			mov	word ptr rest_wait_loop,ax
			call	word ptr cs:drv_palette_push
			mov	byte ptr ds:gvar_timer_byte,0

loc_5:
				call	anim_scroll_step
				cmp	byte ptr ds:gvar_timer_byte,14h
				jb	loc_5			; Jump if below
			jmp	short loc_4

loc_6:
		mov	ax,word ptr ds:[0B2h]
		mov	word ptr rest_wait_loop,ax
		call	word ptr cs:drv_palette_push
		jmp	short $+2		; delay for I/O
		push	cs
		pop	es
		mov	si,0B4h
		mov	di,0ABh
		mov	cx,7
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		test	byte ptr ds:[9Dh],0FFh
		jz	loc_ret_7		; Jump if zero
		call	word ptr cs:drv_anim_step

loc_ret_7:
		retn

;-- Handler: sermon line 3 -- 'Brave Knight, you look fatigued from battle...'
;  Reached via opcode_dispatch_tbl.  The first 5 db bytes form the
;  `mov byte ptr ds:[anim_phase_a],0` instruction (0C6 06 E4 A3 00).
		mov	byte ptr ds:anim_phase_a,0

loc_8:						; continuation label for outer loop below
			mov	byte ptr ds:gvar_timer_byte,0
			cmp	byte ptr ds:anim_phase_a,5
			jb	loc_9			; Jump if below
			retn

loc_9:
			mov	al,ds:anim_phase_a
			mov	cl,6
			mul	cl			; ax = reg * al
			add	ax,0A134h
			mov	si,ax
			mov	bx,163Fh
			mov	cx,3

sermon_outer_loop:
				push	cx
				mov	cx,2

sermon_inner_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	sermon_inner_loop	; Loop if cx > 0

				sub	bh,2
				add	bl,8
				pop	cx
				loop	sermon_outer_loop	; Loop if cx > 0

loc_13:
				call	anim_scroll_step
				cmp	byte ptr ds:gvar_timer_byte,20h	; ' '
				jb	loc_13			; Jump if below
			inc	byte ptr ds:anim_phase_a
			jmp	short loc_8

;-- Glyph index table used indirectly by sermon handler (reached by si
;  computed as A134 + phase*6).  Printable bytes are the tile glyph
;  indices into the character ROM.
		db	'ABMNWXABklmnABopqrsBtuvwxyz{|w'

draw_intro_12x8	proc	near
		mov	si,intro_tile_map
		mov	bx,0E17h		; starting tile position (row 0x17, col 0x0E)
		mov	cx,8

intro_row_loop:
			push	cx
			mov	cx,0Ch

intro_col_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				call	word ptr cs:drv_draw_glyph
				pop	bx
				inc	bh
				pop	cx
				loop	intro_col_loop		; Loop if cx > 0

			sub	bh,0Ch
			add	bl,8
			pop	cx
			loop	intro_row_loop		; Loop if cx > 0

		retn

draw_intro_12x8	endp

;-- intro_tile_map data: 12 wide x 8 tall glyph indices drawn by
;  draw_intro_12x8.  Shows the church interior pixel art.
		db	 00h, 01h, 02h, 03h, 04h, 05h
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h
		db	 12h, 10h, 13h, 14h, 15h, 16h
		db	 17h, 18h, 19h, 1Ah, 1Bh, 1Ch
		db	 1Dh, 1Eh, 1Fh
		db	' !"#$'
		db	'%&&', 27h, '(&)*+,-./0123456789:'
		db	';'
		db	'<=>?'
		db	'@ABCDEFGHIJKLMNOPQRSTSUVSWXYZ'

anim_scroll_step	proc	near
		cmp	word ptr ds:gvar_timer_word,20h	; wait for 32+ ticks
		jae	loc_16			; Jump if above or =
		retn

loc_16:
		mov	word ptr ds:gvar_timer_word,0
		inc	byte ptr ds:anim_phase_b
		cmp	byte ptr ds:anim_phase_b,3
		jne	loc_17			; Jump if not equal
		mov	byte ptr ds:anim_phase_b,0

loc_17:
		call	anim_draw_a
		jmp	short anim_draw_b

;-- anim_draw_a: external entry into anim_scroll_step -- draws 2 rows x 3
;  cols of glyphs from anim_text_ptr_a[phase_b * 6].

anim_draw_a:
		mov	bl,ds:anim_phase_b
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,bx
		add	bx,bx
		add	bx,ax			; bx = phase_b * 6
		mov	si,bx
		add	si,anim_text_ptr_a
		mov	bx,1037h
		mov	cx,2

anim_a_row_loop:
			push	cx
			mov	cx,3

anim_a_col_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				cmp	al,0FFh
				je	anim_a_skip		; Jump if equal
				call	word ptr cs:drv_draw_glyph

anim_a_skip:
				pop	bx
				inc	bh
				pop	cx
				loop	anim_a_col_loop		; Loop if cx > 0

			sub	bh,3
			add	bl,8
			pop	cx
			loop	anim_a_row_loop		; Loop if cx > 0

		retn

;-- anim_text_ptr_a table: 2x3 glyph patterns used by anim_draw_a, one
;  row per anim_phase_b (0..2).  The decoded mnemonics below are Sourcer
;  mis-reading the index bytes as instructions; they are data, not code.
;  Original bytes FFh,30h,31h,3Bh,3Ch,3Dh and FFh,5Bh,5Ch,5Dh,5Eh,5Fh plus
;  60h..64h/FFh define the 3 phases.
		db	0FFh, 30h, 31h, 3Bh	; phase 0: FF skip + 3 glyph pairs
		db	 3Ch, 3Dh		; phase 0 cont.
		db	0FFh, 5Bh, 5Ch, 5Dh	; phase 1: FF skip + glyphs
		db	 5Eh, 5Fh		; phase 1 cont.
		db	0FFh, 60h, 61h, 62h	; phase 2: FF skip + glyphs
		db	 63h, 64h		; phase 2 cont.

;-- anim_draw_b: second rendering pass -- draws 2x2 block from anim_text_ptr_b.
;  Entered via `jmp short anim_draw_b` at end of loc_17 above.

anim_draw_b:
		mov	bl,ds:anim_phase_b
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx			; bx = phase_b * 4
		mov	si,bx
		add	si,anim_text_ptr_b
		mov	bx,1537h
		mov	cx,2

anim_b_row_loop:
			push	cx
			mov	cx,2

anim_b_col_loop:
				push	cx
				push	bx
				lodsb				; String [si] to al
				cmp	al,0FFh
				je	anim_b_skip		; Jump if equal
				call	word ptr cs:drv_draw_glyph

anim_b_skip:
				pop	bx
				inc	bh
				pop	cx
				loop	anim_b_col_loop		; Loop if cx > 0

			sub	bh,2
			add	bl,8
			pop	cx
			loop	anim_b_row_loop		; Loop if cx > 0

		retn

anim_scroll_step	endp

;-- anim_text_ptr_b table: 2x2 glyph patterns per anim_phase_b (0..2).
;  Also mis-decoded by Sourcer -- keep as data bytes.
		db	 34h, 35h, 40h,0FFh	; phase 0
		db	 65h, 66h, 67h,0FFh	; phase 1
		db	 68h, 69h, 6Ah,0FFh	; phase 2

pick_welcome_text	proc	near
;  Returns in SI the text pointer to use for the current entry:
;    first visit (rest_wait_loop == 0 at runtime)  -> si = 0xA2B4
;    repeat visit                                  -> si = 0xA2F2
		mov	ax,word ptr rest_wait_loop
		cmp	ax,word ptr ds:[0B2h]
		mov	si,0A2B4h		; first-visit text pointer
		jnz	loc_25			; Jump if not zero
		retn

loc_25:
		mov	si,0A2F2h		; repeat-visit text pointer
		retn

pick_welcome_text	endp

;-- Reference/data table: CHURCH.GRP reference + title header + dialog
;  script.  Begins with the 1-byte archive number + 1-based chunk index
;  (chunk_ref format) then the filename string.

;-- ref_church_grp: chunk-loader reference record (archive 1, chunk 17h,
;  filename "CHURCH.GRP",0) -- loaded by church_main at start.

ref_church_grp:
		db	 01h, 17h		; archive 1, chunk 17h
		db	'CHURCH.GRP', 0

;-- church_title_hdr: 2-byte load header (segment/offset) + 1-byte glyph
;  count + title string (spelled with control byte 0x0C = set color).
		db	 17h, 0AFh, 02h		; load header bytes
		db	 0Ah			; glyph count = 10

church_title_text:
		db	'The Church', 0Ch, 'Brave Knight,'
		db	' whenever you\re tired come to t'
		db	'his church./'
		db	0FFh, 04h,0FFh, 01h	; SCR_END + short pause (layout 4+1)
		db	0Ch, 'Brave Knight, whenever you\'
		db	're weary, come here to rest. '
		db	0FFh, 02h,0FFh, 02h	; SCR_END + pause
		db	'The Holy Spirit will help you to'
		db	' regain your strength.'
		db	0FFh, 03h, 0Dh,0FFh, 01h	; SCR_END + CR + SCR_END + 1
		db	'Brave Knight, you look fatigued '
		db	'from battle. Why not rest awhile'
		db	' and let the Spirit heal you. '
		db	0FFh, 02h		; SCR_END + layout 2
		db	'/May God go with you.'
		db	0FFh, 00h, 11h,0FFh,0FFh, 00h
		db	 00h

seg_a		ends

		end	start
