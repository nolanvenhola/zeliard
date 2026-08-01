
PAGE  59,132

;==========================================================================
;
;  216INNAP - Inn Dialog Program (zelres2 chunk 16)
;
;  Inn NPC program: "The Inn" dialog with rest menu:
;    Welcome / Stay at the inn (cost-based) / Come back later /
;    Insufficient funds / Thank-you-enjoy-your-stay / Morning greeting
;  Loaded at gvar_game_seg:loaded_code_a (0x3000) by town.bin when
;  player enters the inn building. Plays the rest/heal/save logic and
;  chains back to town via gvar_script_ptr.
;
;  Connections:
;    Loads:        INN.GRP (zelres2 chunk 19h) via cs:[sar_loader_fn] SAR loader
;                  with AL=2 (fill_buffer decode) into game_seg:8000h.
;    Calls into:   drv_fill_rect, drv_screen_init_a/b, drv_load_msg_header,
;                  drv_frame_commit, drv_palette_push, drv_anim_step,
;                  drv_draw_glyph, drv_ds_copy, drv_fade_to_black
;                    (graphics driver dispatch slots, cs:[2000h..30xxh])
;                  script_step (cs:[6004h]) -- script bytecode advancer
;                  opcode_dispatch_tbl (DS-resident, A080h) -- script opcode
;                    handler table populated at runtime by town dispatcher.
;    Called by:    106TOWN building dispatch when player enters the inn
;                  (chunk_ref points at 216INNAP via SAR loader; loaded as
;                  loaded_code_a at game_seg:3000h, entered via far call).
;    Reads/writes: gvar_script_ptr (DS:0FF4Ch), gvar_init_flag_a/b
;                  (DS:0FF4Eh/0FF4Fh), gvar_timer_word (DS:0FF50h),
;                  gvar_game_seg (CS:0FF2Ch).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in zr2com.inc
; ----------------------------------------------------------------------
gvar_menu_sel            equ     0C006h
gvar_game_seg		equ	0FF2Ch			;*

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
opcode_dispatch_tbl	equ	0A080h			;*
intro_tile_map		equ	0A1CFh			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
anim_active_flag	equ	0A505h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_inn_main	proc	far

start:
;--------------------------------------------------------------------------
; SAR chunk header + init-table fragment (12 bytes, offsets 0x0000-0x000B).
; The first 4 bytes are the SAR chunk-size word + flag bytes; the next 8
; bytes are the chunk-init stub patched at load time.  Real module entry
; begins at 0x000C below.
;--------------------------------------------------------------------------
chunk_header_and_init_stub:
		db	10h, 05h			; chunk_size lo word (1296 = file_size-4)
		db	00h, 00h			; chunk_size hi word
		db	04h, 0A0h			; init byte pair
		db	2Fh				; init flag
		db	0A2h, 8Eh, 06h			; init-stub: "mov ds:[068Eh],al"
		db	2Ch, 0FFh			; init-stub: "sub al,0FFh"

		mov	di,8000h			; --- real entry point begins here (offs 0x000C) ---
		mov	si,0A2E1h			; inn.grp chunk reference (archive 01, chunk_A)
		mov	al,2
		call	word ptr cs:[sar_loader_fn]		; SAR chunk loader (AL=2: fill_buffer decode)
		push	ds
		mov	ds,cs:[gvar_game_seg]
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:[drv_ds_copy]
		pop	ds
		mov	byte ptr ds:[gvar_init_flag_a],0
		mov	byte ptr ds:[gvar_init_flag_b],0
		call	word ptr cs:[drv_screen_init_a]
		call	word ptr cs:[drv_screen_init_b]
		mov	si,0A2EBh			; inn title header ptr
		call	word ptr cs:[drv_load_msg_header]
		call	draw_intro_banner
		mov	word ptr ds:[gvar_script_ptr],0A2F6h

inn_main_loop:
					call	word ptr cs:[script_step]
					cmp	al,0FFh
					je	inn_main_exit			; Jump if equal
					call	inn_opcode_dispatch
					jmp	short inn_main_loop

inn_main_exit:
		jmp	word ptr cs:[drv_fade_to_black]

run_inn_main	endp

;--------------------------------------------------------------------------
;  draw_intro_banner -- draw title banner + fill dialog area, then mark
;  anim_active_flag. Called once from run_inn_main before the script loop.
;--------------------------------------------------------------------------

draw_intro_banner	proc	near
		call	draw_intro_tile_map
		mov	bx,0D60h
		mov	cx,3637h
		mov	al,0FFh
		call	word ptr cs:[drv_fill_rect]
		mov	byte ptr ds:[anim_active_flag],0FFh
		retn

draw_intro_banner	endp

;--------------------------------------------------------------------------
;  inn_opcode_dispatch -- dispatch inn-script opcode through the
;  opcode_dispatch_tbl in game DS. AL is the opcode byte.
;--------------------------------------------------------------------------

inn_opcode_dispatch	proc	near
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:[opcode_dispatch_tbl][bx]	; DS-resident fn-ptr table

inn_opcode_dispatch	endp

;--------------------------------------------------------------------------
;  Opcode handler table + handler bodies (0x0084..0x0104).
;
;  These 5 handlers implement the inn's menu opcodes. The DS-segment
;  opcode_dispatch_tbl at A080 stores CS-offsets into this block. Each
;  handler is reached via inn_opcode_dispatch's indirect jmp above.
;
;  The first 10 bytes (0084..008D) are 5 word pointers into the game-
;  segment text area (strings at A08A, A0BE, A114, A12A, A15F) used by
;  one of the handlers. The remaining bytes are x86 code.
;--------------------------------------------------------------------------

; -- 5-word pointer table (0x0084..0x008D) referenced by handler A --
;    Points to text strings in the game data segment (A08A, A0BE, A114, A12A, A15F).
;    inn_patch_slot_1/inn_patch_slot_2 are patch targets used by inn_script_patch_ptr to substitute
;    dl/ax into the first two ptr bytes.
		db	 8Ah				; 0084: ptr 0 low byte (= A08A low)
inn_patch_slot_1		db	0A0h				; 0085: ptr 0 high byte (patched)
inn_patch_slot_2		dw	0A0BEh				; 0086: ptr 1 word (patched)
		db	 14h,0A1h, 2Ah,0A1h, 5Fh,0A1h	; 0088..008D: ptr 2..4 (A114, A12A, A15F)

; -- Handler A (0x008E): menu amount-selection handler --
;    Dense inline x86 code; inn_patch_slot_3..inn_handler_src_buf are patch points within this code.
		db	 8Ah, 1Eh			; 008E: mov bl, [mem]
inn_patch_slot_3		dw	0C006h				; 0090: = gvar_menu_sel (operand of above mov)
		db	0FEh,0CBh, 32h,0FFh, 03h,0DBh	; 0092: dec bl; xor bh,bh; add bx,bx
		db	 8Bh, 97h,0D1h,0A2h, 89h	; 0098: mov dx,[bx+A2D1]; + partial mov
inn_patch_flag		db	 16h				; 009D: (bit-tested by inn_cleanup_and_return)
		db	 06h,0A5h, 8Bh,0C2h, 32h,0D2h	; 009E: [ds:A506]; mov ax,dx; xor dl,dl
		db	 0BFh, 08h,0A5h, 2Eh,0FFh, 16h	; 00A4: mov di,A508; call cs:[...
		db	 06h				; 00AA: ...6006] (fmt_num_to_str)
inn_handler_dst_buf		db	 60h				; 00AB: rep-movsb dst byte (patched to copy handler-B header)
		db	 8Bh, 36h, 4Ch,0FFh, 56h,0C7h	; 00AC: mov si,[FF4C]; push si; mov...
inn_patch_word_6		dw	4C06h				; 00B2: FF4C literal (captured by inn_cleanup_and_return)
inn_handler_src_buf		db	 0FFh				; 00B4: rep-movsb src (copied to inn_handler_dst_buf)
		db	 08h,0A5h, 2Eh,0FFh, 16h, 04h	; 00B5: ...A508; call cs:[6004]
		db	 60h, 5Eh, 89h, 36h, 4Ch,0FFh	; 00BB: pop si; mov [FF4C],si
; -- Handler B (0x00C1..): retn; then call-fill + menu branch --
		db	 0C3h,0BBh, 2Bh, 2Fh,0B9h, 19h	; 00C1: retn; mov bx,2F2B; mov cx,...
		db	 0Ch,0B0h,0FFh, 2Eh,0FFh, 16h	; 00C7: 0C19; mov al,FF; call cs:[...
		db	 00h, 20h,0C7h, 06h, 54h,0FFh	; 00CD: 2000]; mov [FF54],...
		db	 2Eh, 30h, 2Eh,0FFh, 16h, 08h	; 00D3: 302E; call cs:[6008]
		db	 60h, 9Ch,0BBh, 2Bh, 2Fh,0B9h	; 00D9: ; pushf; mov bx,2F2B...
		db	 19h, 0Ch, 32h,0C0h, 2Eh,0FFh	; 00DF: cx,0C19; xor al,al; call cs:..
		db	 16h, 00h, 20h, 9Dh,0C7h, 06h	; 00E5: [2000]; popf; mov...
		db	 4Ch,0FFh,0BDh,0A3h, 73h, 01h	; 00EB: [FF4C],A3BD; jnc +1
		db	 0C3h,0A1h, 06h,0A5h, 32h,0D2h	; 00F1: retn; mov ax,[A506]; xor dl
		db	 2Eh,0FFh, 16h, 0Ah, 60h,0C7h	; 00F7: call cs:[600A]; mov...
		db	 06h, 4Ch,0FFh, 1Ah,0A4h, 73h	; 00FD: [FF4C],A41A; jnc
		db	 01h,0C3h			; 0103: +1; retn

;--------------------------------------------------------------------------
;  inn_script_patch_ptr (0x0105) -- called after certain opcode sequences
;  to patch dl/ax into the handler-table entry bytes, then step the script.
;
;  NOTE: writes use DS addressing but at runtime DS == game_seg (not CS);
;  the bytes (A3/88) match the original binary regardless of actual target.
;--------------------------------------------------------------------------

inn_script_patch_ptr:
		mov	inn_patch_slot_1,dl
		mov	inn_patch_slot_2,ax
		call	word ptr cs:[drv_frame_commit]
		mov	word ptr ds:[gvar_script_ptr],0A483h
		retn

		; Short tail block (0x011A..0x0120) -- encoded x86 bytes that
		; form another mini-handler entry. Reached via DS dispatch
		; (preceding retn at 0x0119 prevents fall-through). Fragment:
		;   mov byte ptr [A505], 0    ; 0C6h 06h A5h 05h 00h
		;   xor al, al                ; 32h 0C0h
		; Labelled via inn_anim_scan_fn_ptr because inn_anim_scan does a
		; "call word ptr cs:inn_anim_scan_fn_ptr" using these bytes as a
		; patched function pointer.
		db	 0C6h, 06h			;  mov byte ptr [mem],imm prefix
inn_anim_scan_fn_ptr		dw	0A505h				;  = anim_active_flag address (also doubles
						        ;  as fn-ptr target of cs:inn_anim_scan_fn_ptr call)
		db	 00h				;  imm value for mov above
		db	 32h,0C0h			;  xor al,al

;--------------------------------------------------------------------------
;  rest_loop (0x011F) -- play the "sleep animation" 4x by calling
;  inn_anim_step + inn_wait_short. Restores AL between iterations.
;--------------------------------------------------------------------------

rest_loop:
					push	ax
					call	inn_anim_step
					call	inn_wait_short
					pop	ax
					inc	al
					cmp	al,4
					jne	rest_loop			; Jump if not equal
		retn

;--------------------------------------------------------------------------
;  inn_cleanup_and_return (0x012E) -- reached via dispatch table (not by
;  fall-through; the preceding retn ends the previous function). Restores
;  state, copies handler_bodies bytes from inn_handler_src_buf to inn_handler_dst_buf, then loops
;  back to draw_intro_tile_map.
;--------------------------------------------------------------------------

inn_cleanup_and_return:					;* dispatch table target (reachable via DS opcode_dispatch_tbl)
		call	inn_wait_long
		call	word ptr cs:[drv_fade_to_black]
		call	inn_wait_long
		call	inn_wait_long
		mov	ax,inn_patch_word_6
		mov	inn_patch_slot_3,ax
		call	word ptr cs:[drv_palette_push]
		push	cs
		pop	es
		mov	si,offset inn_handler_src_buf
		mov	di,offset inn_handler_dst_buf
		mov	cx,7
		rep	movsb				; Rep when cx >0 Mov [si] to es:[di]
		test	inn_patch_flag,0FFh
		jz	inn_skip_dispatch_update	; Jump if zero
		call	word ptr cs:[drv_anim_step]

inn_skip_dispatch_update:
		jmp	draw_intro_banner		; back to top of loop

;--------------------------------------------------------------------------
;  inn_wait_long (0x0163) -- poll timer until gvar_frame_timer reaches 0x96
;--------------------------------------------------------------------------

inn_wait_long	proc	near
		mov	byte ptr ds:[gvar_frame_timer],0

inn_wait_long_loop:
					call	inn_anim_scan
					cmp	byte ptr ds:[gvar_frame_timer],96h
					jb	inn_wait_long_loop		; Jump if below
		retn

inn_wait_long	endp

;--------------------------------------------------------------------------
;  inn_wait_short (0x0173) -- poll timer until gvar_frame_timer reaches 0x32
;--------------------------------------------------------------------------

inn_wait_short	proc	near
		mov	byte ptr ds:[gvar_frame_timer],0

inn_wait_short_loop:
					call	inn_anim_scan
					cmp	byte ptr ds:[gvar_frame_timer],32h	; '2'
					jb	inn_wait_short_loop		; Jump if below
		retn

inn_wait_short	endp

;--------------------------------------------------------------------------
;  inn_anim_step (0x0183) -- emit a 4-row x 5-col sprite block at (bx).
;  AL = frame index; each row writes 5 glyphs via drv_draw_glyph.
;--------------------------------------------------------------------------

inn_anim_step	proc	near
		mov	cl,14h
		mul	cl			; ax = reg * al
		add	ax,0A281h
		mov	si,ax
		mov	bx,827h
		mov	cx,4

anim_step_outer:
					push	cx
					mov	cx,5

anim_step_inner:
								push	cx
								push	bx
								lodsb				; String [si] to al
								call	word ptr cs:[drv_draw_glyph]
								pop	bx
								inc	bh
								pop	cx
								loop	anim_step_inner		; Loop if cx > 0

					sub	bh,5
					add	bl,8
					pop	cx
					loop	anim_step_outer		; Loop if cx > 0

		retn

inn_anim_step	endp

;--------------------------------------------------------------------------
;  draw_intro_tile_map (0x01AE) -- emit the 12x8 intro tile map
;  using intro_tile_map and drv_draw_glyph. Covers "The Inn" banner grid.
;--------------------------------------------------------------------------

draw_intro_tile_map	proc	near
		mov	si,intro_tile_map
		mov	bx,717h
		mov	cx,8

intro_map_outer:
					push	cx
					mov	cx,0Ch

intro_map_inner:
								push	cx
								push	bx
								lodsb				; String [si] to al
								call	word ptr cs:[drv_draw_glyph]
								pop	bx
								inc	bh
								pop	cx
								loop	intro_map_inner		; Loop if cx > 0

					sub	bh,0Ch
					add	bl,8
					pop	cx
					loop	intro_map_outer		; Loop if cx > 0

		retn

draw_intro_tile_map	endp

;--------------------------------------------------------------------------
;  Glyph index tables (0x01D3..0x0232) -- 2 rows of glyph indices used by
;  the intro_tile_map. Each row is 32 entries; the last 22 are ASCII
;  capitals 'HIJKLMNOPQRSTUVWXYZ[\]' from the game font.
;--------------------------------------------------------------------------

intro_glyph_row_a	label	byte		; 32 glyphs: '...'
		db	 00h, 01h, 02h, 03h, 04h, 05h	; row 0 cols 0-5  (intro tile glyph indices)
		db	 06h, 07h, 08h, 09h, 0Ah, 0Bh	; row 0 cols 6-11
		db	 0Ch, 0Dh, 0Eh, 0Fh, 10h, 11h	; row 1 cols 0-5
		db	 12h, 13h, 14h, 15h, 16h, 17h	; row 1 cols 6-11
		db	 18h, 19h, 1Ah, 1Bh, 10h, 1Ch	; row 2 cols 0-5
		db	 1Dh, 1Eh, 1Fh, 20h, 21h, 22h	; row 2 cols 6-11
		db	 23h, 24h, 25h, 26h, 10h	; row 3 cols 0-4
		db	 27h				; row 3 col 5; remaining cells are ASCII below

intro_glyph_row_b	label	byte		; printable ASCII 0x28..0x5D
		db	'()*+,-./0123456789:;<=>?@ABCDEFG'
		db	'HIJKLMNOPQRSTUVWXYZ[\]'

;--------------------------------------------------------------------------
;  inn_anim_scan (0x0233) -- core per-frame scanner. Early-exits unless
;  anim_active_flag is set AND gvar_timer_word >= 0x28, then runs a
;  2x2 glyph-blit using inn_anim_scan_fn_ptr as the 'coin-flip' random source.
;--------------------------------------------------------------------------

inn_anim_scan	proc	near
		test	byte ptr ds:[anim_active_flag],0FFh
		jnz	anim_scan_active		; Jump if not zero
		retn

anim_scan_active:
		cmp	word ptr ds:[gvar_timer_word],28h
		jae	anim_scan_ready			; Jump if above or =
		retn

anim_scan_ready:
		mov	word ptr ds:[gvar_timer_word],0
		call	word ptr cs:[inn_anim_scan_fn_ptr]
		and	al,1
		add	al,al
		add	al,al
		xor	ah,ah			; Zero register
		add	ax,0A279h
		mov	si,ax
		mov	bx,827h
		mov	cx,2

scan_outer:
					push	cx
					mov	cx,2

scan_inner:
								push	cx
								push	bx
								lodsb				; String [si] to al
								call	word ptr cs:[drv_draw_glyph]
								pop	bx
								inc	bh
								pop	cx
								loop	scan_inner		; Loop if cx > 0

					sub	bh,2
					add	bl,8
					pop	cx
					loop	scan_outer		; Loop if cx > 0

		retn

inn_anim_scan	endp

;--------------------------------------------------------------------------
;  Trailing tile/glyph tables (0x027D..0x02D4) -- additional glyph rows
;  used by the trailing frames of the anim loop. Decoded by Sourcer as
;  x86 but they are just byte data (e.g. 0x24 = '$', 0x25..0x26 etc.).
;--------------------------------------------------------------------------

inn_tile_map_tail:					;* glyph index tail (reached via DS dispatch only)
		db	 19h, 1Ah, 24h, 25h		; tail row 0: sprite row tokens
		db	'^_$`'				; tail row 0 cont: ASCII glyphs 0x5E,0x5F,0x24,0x60
		db	 19h, 1Ah, 1Bh, 10h, 1Ch, 24h, 25h, 26h, 10h, 27h	; tail row 1: 10 sprite tokens
		db	'/0123;<=>?'			; tail row 1 cont: glyph indices 0x2F..0x3F
		db	 19h, 1Ah, 1Bh, 10h, 1Ch, 24h, 25h, 26h, 10h, 27h	; tail row 2: same 10 sprite tokens
		db	'/0123;<=>?'			; tail row 2 cont: glyph indices 0x2F..0x3F
		db	 19h, 1Ah, 1Bh, 10h, 1Ch, 24h	; tail row 3a: 6 sprite tokens
		db	'ab'				; tail row 3a cont: ASCII 'a','b'
		db	 10h				; tail row 3a cont: token 0x10
		db	 27h				; tail row 3a cont: token 0x27
		db	'/cd23;ef>?'			; tail row 3b: ASCII glyphs
		db	 19h, 1Ah, 1Bh, 10h, 1Ch		; tail row 4: 5 sprite tokens
		db	'$'				; tail row 4 cont: ASCII '$'
		db	'%&gh/ijkl;mno?'		; tail row 4 cont: ASCII glyphs

;--------------------------------------------------------------------------
;  inn_delay_tbl (0x02D5) -- 8-entry word table of delay counts used to
;  time the "sleep" sequence.
;--------------------------------------------------------------------------

inn_delay_tbl	label	word
		dw	0				;   0
		dw	001Eh				;  30
		dw	0032h				;  50
		dw	0046h				;  70
		dw	0064h				; 100
		dw	0096h				; 150
		dw	00C8h				; 200
		dw	0190h				; 400

;--------------------------------------------------------------------------
;  Inn chunk-ref record + title header + dialog script strings
;  (0x02E1..0x050D). Addressed at runtime as game_seg:A2E1 onward
;  (load offset A000 + file offset 02E1).
;--------------------------------------------------------------------------

ref_inn_grp	db	 01h, 19h			; archive=01 (zelres2), chunk=19h (25)
		db	'INN.GRP', 00h			; filename + null terminator
		db	 19h,0AFh, 00h			; title hdr: pos word + attr
		db	 07h				; title string length (7 = 'The Inn')
		db	'The Inn', 0Ch, 'Welcome, sir!/Yo'
		db	'u look like you\ve come a long w'
		db	'ay./One night of rest in my inn '
		db	'is all you need to recover your '
		db	'strength. You can have the best '
		db	'room in the house for only '
		db	 0FFh, 00h			; SCR_END + literal 0 (cost template)
		db	'&golds. Will you stay? '
		db	 0FFh, 01h, 0Ch			; SCR_END opcode 01, CR
		db	'Oh, I\m sorry to hear that./Well'
		db	', if you should ever need a'
		db	' place to rest, do come back. '
		db	 11h,0FFh,0FFh, 0Ch		; ANIM-prefix + SCR_END x2 + CR
		db	'I\m sorry sir, b'
		db	'ut I can\t accommodate you witho'
		db	'ut funds./'
		db	 0FFh, 04h			; SCR_END opcode 04
		db	'Please come back when you can af'
		db	'ford'
		db	' it. '
		db	 11h,0FFh,0FFh			; ANIM-prefix + SCR_END x2
		db	 0Ch				; CR
		db	'Thank you, sir. Enjoy your stay.'
		db	' '
		db	 0FFh, 02h			; SCR_END opcode 02
		db	 0FFh, 04h			; SCR_END opcode 04
		db	 0FFh, 03h			; SCR_END opcode 03
		db	 0Ch,0FFh, 04h			; CR + SCR_END opcode 04
		db	'I trust you had a good night\s sl'
		db	'eep. We\ll be looking forward to'
		db	' seeing you again./'
		db	 11h,0FFh,0FFh, 00h		; ANIM-prefix + SCR_END x2 + null
		db	10 dup (0)			; pad to chunk size

seg_a		ends

		end	start
