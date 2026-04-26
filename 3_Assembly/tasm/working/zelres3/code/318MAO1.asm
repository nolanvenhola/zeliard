
PAGE  59,132

;==========================================================================
;
;  318MAO1 / _318MAPA5 - Boss 5 Arena Map Program - Jashiin Dialog
;
;  Map-program code module for the Boss 5 arena (zelres3 chunk 18, 0-idx).
;  Loaded together with the arena data file map_boss5_arena.bin.
;
;  This is the pre-final-boss encounter module.  Contains the Jashiin
;  taunt dialog embedded as text data:
;    "Finally, you reached me."
;    "I enjoyed your show."
;    "Come on!  I'll kill you."
;  followed by the speaker-name string 'Jashiin'.
;
;  Structure:
;    - Header / dispatch pointer area + tile/cell layout descriptor data
;    - Main per-frame NPC scan + phase handler (mao1_npc_scan_loop)
;    - Phase handlers (palette/anim, scroll fill)
;    - Trailer: dialog handler tile-pair tables + Jashiin dialog text
;      block + 'Jashiin' speaker name
;
;  Note: "MAO1" stands for "demon lord 1" (Jp. "Mao") - this is the
;  pre-Mao boss. MAO2 (319MAO2 / _319MAPA6) is the FINAL boss arena.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr3com.inc

; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   2000h..2F2Eh  - driver/service callback functions
;   6028h..6036h  - game-seg dispatch callbacks
;   0C010h        - sprite attribute record base
;   0ED20h        - char/tile lookup table
;   0FF75h        - global state byte

; --- Driver dispatch / callback fn ptrs (CS-relative ptrs in driver/game DS) ---
mao1_drv_load_chunk	equ	2000h			; driver dispatch (load_chunk_ES or similar)
mao1_drv_dispatch_a	equ	201Fh			; driver dispatch entry
mao1_drv_blit_render	equ	202Ah			; driver dispatch entry (blit/render)
mao1_drv_text_render	equ	2928h			; driver callback (text render)
mao1_drv_misc_callback	equ	2F2Eh			; driver callback

; --- External data ptrs (DS - addressed by hard offset in caller's DS) ---
mao1_ext_8e77		equ	8E77h			; external data ptr
mao1_ext_9893		equ	9893h			; external data ptr
mao1_ext_9a00		equ	9A00h			; external data ptr

; --- Internal phase / dispatch tables (DS, addressed by hard offset) ---
mao1_phase_tbl_a39f	equ	0A39Fh			; phase table base A
mao1_phase_tbl_a3bb	equ	0A3BBh			; phase table base B
mao1_dialog_lo_tbl	equ	0A442h			; dialog handler lo-byte table
mao1_phase_di_tbl	equ	0A495h			; DI per-phase table
mao1_phase_bp_tbl	equ	0A52Fh			; BP per-phase table

; --- State / scratch (DS) ---
mao1_speech_dx_base	equ	0A581h			; speech DX base word (write-target of dx after dispatch)
mao1_speech_dx_lo	equ	0A583h			; speech DX low (read by emit-cell to gate +cl)
mao1_npc_idx		equ	0A599h			; NPC scan index byte (incremented per-cell)
mao1_phase_dir		equ	0A59Ah			; phase direction byte (BL-saved cell attr)
mao1_phase_step	equ	0A59Bh			; phase step counter (incremented per-frame)
mao1_phase_substate	equ	0A59Ch			; phase substate (xlat result, signed dispatch)
mao1_attr_tmp		equ	0A5A1h			; attribute scratch byte (data_34e)
mao1_alt_buf		equ	0AEABh			; alternate buffer ptr
mao1_render_buf		equ	0B600h			; render buffer base

; --- Shared game-segment globals ---
mao1_sprite_attr_ptr	equ	0C010h			; sprite attribute record ptr (DS)
mao1_text_dst		equ	0E939h			; text-buffer destination
mao1_sprite_xlat_tbl	equ	0ED20h			; char/tile xlat table (shared)
mao1_gvar_state_byte	equ	0FF75h			; global state byte (per-map)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_318MAPA5	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Sourcer mis-decoded header fields as x86 instructions (popf/and/etc);
; real entry is via dispatch from game DS.  First bytes are pointer
; descriptor fields + a reserved 40-byte zero region.
; ------------------------------------------------------------------

start:
		popf				; header field byte
		add	ax,0			; header field bytes
		cmp	al,0A2h			; header field bytes
;*		and	word ptr ds:[0][di],0
		db	 81h,0A5h, 00h, 00h, 00h, 00h	;  header field bytes (Fixup)
		db	40 dup (0)		; reserved / padding

; --- Embedded tile/cell layout descriptor data block ---

mao1_layout_data	label	byte
mao1_layout_ptr_tbl	label	word
		db	 3Eh,0A0h, 8Eh,0A0h,0DEh,0A0h	; ptrs A03E/A08E/A0DE
		db	 2Eh,0A1h, 7Eh,0A1h,0CEh,0A1h	; ptrs A12E/A17E/A1CE
		db	 19h,0A2h			; ptr A219
mao1_layout_cells	label	byte		; per-row tile cell layout
		db	 01h, 01h, 02h, 03h	; tile cell run
		db	 04h, 01h, 05h, 06h, 0Ch, 00h	; tile cell run
		db	 01h, 00h, 00h, 0Ah, 0Bh, 01h	; tile cell run
		db	 00h, 00h, 08h, 09h, 01h, 0Eh	; tile cell run
		db	 00h, 00h, 00h, 01h, 07h, 0Dh	; tile cell run
		db	 0Fh, 10h, 01h, 00h, 00h, 01h	; tile cell run
		db	 02h, 01h, 03h, 04h, 11h, 12h	; tile cell run
		db	 01h, 00h, 00h, 13h, 00h, 01h	; tile cell run
		db	 18h, 19h, 1Eh, 00h, 01h, 16h	; tile cell run
		db	 17h, 0Ah, 1Dh, 01h, 00h, 15h	; tile cell run
		db	 1Ch, 09h, 01h, 20h, 00h, 00h	; tile cell run
		db	 00h, 01h, 00h, 14h, 1Ah, 1Bh	; tile cell run
		db	 01h, 07h, 1Fh, 0Fh, 10h, 01h	; tile cell run
		db	 28h, 00h, 2Fh, 30h, 01h, 26h	; tile cell run
		db	 27h, 2Dh, 2Eh, 01h, 13h, 00h	; tile cell run
		db	 18h, 22h, 01h	; tile cell run
mao1_data_word_a	dw	201h			; data table (indexed access)
		db	 03h, 04h, 01h, 11h, 12h, 16h	; tile cell run
		db	 21h, 01h	; tile cell run
		db	 24h, 25h	; tile cell run
mao1_data_word_b	dw	2C2Bh			; data table (indexed access)
		db	 01h, 34h, 00h, 00h, 00h, 01h	; tile cell run
		db	 00h	; tile cell run
		db	23h	; tile cell run
mao1_data_word_c	dw	2A29h			; data table (indexed access)
		db	 01h, 32h, 33h, 35h, 36h, 01h	; tile cell run
		db	 00h, 31h, 00h, 00h, 01h, 00h	; tile cell run
		db	 00h, 02h, 00h, 01h, 04h, 00h	; tile cell run
		db	 39h, 3Ah, 01h, 3Dh, 3Eh, 3Dh	; tile cell run
		db	 42h, 01h, 3Dh, 45h, 48h, 49h	; tile cell run
		db	 01h, 4Dh, 4Eh, 52h, 53h, 01h	; tile cell run
		db	 00h, 00h, 00h, 01h, 01h, 00h	; tile cell run
		db	 03h, 37h, 38h, 01h	; tile cell run
		db	 3Bh, 3Ch, 3Fh	; tile cell run
mao1_data_byte_d	db	40h			; data byte (indexed access)
		db	 01h, 43h, 44h, 46h, 47h, 01h	; tile cell run
		db	 4Bh, 4Ch, 50h, 51h, 01h, 00h	; tile cell run
		db	 4Ah, 00h, 4Fh, 01h, 00h, 03h	; tile cell run
		db	 54h, 38h, 01h	; tile cell run
		db	 57h, 3Ch, 58h, 40h	; tile cell run
mao1_data_byte_e	db	1			; data byte (indexed access)
mao1_layout_cells_ext	label	byte		; extended tile cell layout rows
		db	 59h, 44h, 46h, 47h, 01h, 55h	; tile cell run
		db	 56h, 00h, 00h, 01h, 00h, 03h	; tile cell run
		db	 5Dh, 38h, 01h, 58h, 3Ch, 58h	; tile cell run
		db	 40h, 01h, 00h, 00h, 5Bh, 5Ch	; tile cell run
		db	 01h, 00h, 00h, 00h, 5Ah, 01h	; tile cell run
		db	 04h, 00h, 61h, 3Ah, 01h, 62h	; tile cell run
		db	 3Eh, 3Dh, 42h, 01h, 00h, 03h	; tile cell run
		db	 5Eh, 38h, 01h, 5Fh, 60h, 58h	; tile cell run
		db	 40h, 01h, 04h, 00h, 67h, 68h	; tile cell run
		db	 01h, 00h, 03h, 65h, 66h, 01h	; tile cell run
		db	 00h, 00h, 63h, 64h, 01h, 6Ch	; tile cell run
		db	 6Dh, 6Fh, 70h, 01h, 6Ah, 6Bh	; tile cell run
		db	 69h, 6Eh, 01h, 00h, 69h, 00h	; tile cell run
		db	 00h, 01h, 71h, 45h, 72h, 73h	; tile cell run
		db	 01h, 00h, 69h, 00h, 47h, 01h	; tile cell run
		db	 74h, 75h, 77h, 78h, 01h, 00h	; tile cell run
		db	 4Ch, 76h, 51h, 01h, 04h, 00h	; tile cell run
		db	 83h, 84h, 01h, 86h, 87h, 71h	; tile cell run
		db	 88h, 01h, 89h, 8Ah, 85h, 71h	; tile cell run
		db	 01h, 00h, 00h, 8Bh, 00h, 01h	; tile cell run
		db	 8Ch, 8Dh, 77h, 8Eh, 01h, 7Dh	; tile cell run
		db	 03h, 81h, 82h, 01h, 80h, 71h	; tile cell run
		db	 85h, 80h, 01h, 00h, 85h, 00h	; tile cell run
		db	 47h, 01h, 00h, 00h, 41h, 79h	; tile cell run
		db	 01h, 7Bh, 7Ch, 7Fh, 80h, 01h	; tile cell run
		db	 00h, 7Ah, 00h, 7Eh, 01h, 00h	; tile cell run

; ------------------------------------------------------------------
; Layout-data block consumed as bytes by 200FIGHT/map dispatch through
; DS-resident handler tables (loaded into game DS at runtime).  Sourcer
; rendered these bytes as x86 mnemonics; preserved verbatim since they
; assemble to the same byte stream as raw db hex would.
; ------------------------------------------------------------------

mao1_layout_data_a	label	byte
		test	ax,[bx+si]
		add	[bx+di],al
		add	al,0
		cmpsw				; Cmp [si] to es:[di]
		add	[bx+di],al
		lodsb				; String [si] to al
		lodsw				; String [si] to ax
		mov	al,0B1h
		add	ds:mao1_render_buf[si],si
		add	[bx+di],al
		mov	ds:mao1_ext_8e77[di],cs
		add	ds:mao1_ext_9a00[si],dx
		add	[bx+di],ax
		mov	al,ds:mao1_attr_tmp
		cmpsb				; Cmp [si] to es:[di]
		add	ss:mao1_alt_buf[bp+si],bp
		scasw				; Scan es:[di] for ax
		add	ss:mao1_data_word_c[bp+si],si
		mov	ch,1
		add	[si+76h],cl
		push	cx
		add	ss:mao1_ext_9893[bp+si],dx
		cwd				; Word to double word
		add	ss:[bp+0A39Fh],bx	; references mao1_phase_tbl_a39f
		movsb				; Mov [si] to es:[di]
		add	mao1_data_word_b[bx+si],bp
		add	[bx+di],al
		nop
		xchg	cx,ax
		xchg	si,ax
		xchg	di,ax
		add	mao1_data_word_a[si],bx
		mov	byte ptr ds:[1],al
		pop	word ptr [bx+si]
		xchg	bp,ax
		add	[bx+si],ax
mao1_layout_cells_tail	label	byte		; trailing tile cell rows (layout-data continuation)
		db	 9Bh, 00h, 00h, 01h, 00h, 00h	; tile cell run (tail)
		db	0C4h,0C5h, 01h, 04h,0CAh,0CFh	; tile cell run (tail)
		db	0D0h, 01h,0ACh,0ADh,0B0h,0B1h	; tile cell run (tail)
		db	 01h,0B4h, 00h,0B6h, 00h, 01h	; tile cell run (tail)
		db	 8Ch, 8Dh, 77h, 8Eh, 01h,0BCh	; tile cell run (tail)
		db	0BDh,0C2h,0C3h, 01h,0C9h, 03h	; tile cell run (tail)
		db	 00h,0CEh, 01h, 00h,0D1h, 00h	; tile cell run (tail)
		db	0D2h, 01h, 00h,0B3h, 00h,0B5h	; tile cell run (tail)
		db	 01h, 00h, 00h, 00h,0B8h, 01h	; tile cell run (tail)
		db	 00h, 00h, 00h,0B7h, 01h,0BAh	; tile cell run (tail)
		db	0BBh,0C0h,0C1h, 01h, 00h,0B9h	; tile cell run (tail)
		db	0BEh,0BFh, 01h,0C7h,0C8h,0CCh	; tile cell run (tail)
		db	0CDh, 01h, 00h,0C6h, 00h,0CBh	; tile cell run (tail)
		db	 01h, 00h, 00h, 00h	; tile cell run (tail)
mao1_layout_cells_tail_end	label	byte
		db	 07h, 8Bh			; trailing init seed bytes
		db	 36h, 10h,0C0h,0C6h, 06h, 99h	; ss override + mov [bp]+const, mov ss:[06h],99h pattern
		db	0A5h, 00h	; trailing init seed bytes

; ------------------------------------------------------------------
; mao1_npc_scan_loop: walk sprite-attribute record table (0C010h),
; dispatch tile callback for each entry, terminate on FFFFh.
; ------------------------------------------------------------------

mao1_npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		;  Fixup - byte match
			jz	mao1_npc_scan_done	; Jump if zero
			mov	ax,[si]
			call	word ptr cs:fight_cb_anim_step
			jc	mao1_npc_scan_next	; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:mao1_npc_idx
			xor	bh,bh			; Zero register
			mov	al,ds:mao1_sprite_xlat_tbl[bx]
			mov	[di],al

mao1_npc_scan_next:
			inc	byte ptr ds:mao1_npc_idx
			add	si,10h
			jmp	short mao1_npc_scan_loop

mao1_npc_scan_done:
		mov	si,ds:mao1_sprite_attr_ptr
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:mao1_phase_substate
		mov	al,ds:mao1_phase_substate
		mov	bx,mao1_phase_tbl_a3bb
		xlat				; al=[al+[bx]] table
		or	al,al			; Zero ?
		jns	mao1_phase_dispatch_a	; Jump if not sign
		jmp	mao1_dispatch_high_byte

mao1_phase_dispatch_a:
		mov	ds:mao1_phase_step,al
		mov	al,ds:mao1_phase_step
		mov	dx,10h
		cmp	al,3
		jb	mao1_phase_set_dx_short	; Jump if below
		mov	dx,0Dh

mao1_phase_set_dx_short:
		mov	ds:mao1_speech_dx_base,dx
		mov	byte ptr ds:mao1_npc_idx,0
		mov	bl,ds:mao1_phase_step
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,cs:mao1_phase_di_tbl[bx]
		mov	bp,cs:mao1_phase_bp_tbl[bx]
		mov	ax,ds:mao1_speech_dx_base
		mov	si,ds:mao1_sprite_attr_ptr
		mov	cx,6

mao1_phase_outer_loop:
		push	cx
		push	ax
		call	word ptr cs:fight_cb_anim_step
		pop	ax
		mov	ds:mao1_phase_dir,bl	; data_31e: save attr byte
		jnc	mao1_phase_emit_cells	; Jump if carry=0
		mov	cx,8

mao1_phase_skip_inner_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	mao1_phase_skip_no_inc	; Jump if carry=0
				inc	di

mao1_phase_skip_no_inc:
				loop	mao1_phase_skip_inner_loop	; Loop if cx > 0

		jmp	short mao1_phase_inner_done

mao1_phase_emit_cells:
		xor	cl,cl			; Zero register

mao1_phase_emit_loop:
			push	cx
			push	ax
			rol	byte ptr ds:[bp],1	; Rotate
			jnc	mao1_phase_emit_skip	; Jump if carry=0
			mov	[si],ax
			add	cl,cl
			mov	al,ds:mao1_speech_dx_lo	; data_29e: speech dx low
			add	al,cl
			and	al,3Fh			; '?'
			mov	[si+2],al
			mov	al,ds:mao1_phase_dir
			mov	[si+3],al
			mov	al,[di]
			mov	ah,al
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			mov	[si+4],al
			and	ah,0Fh
			mov	[si+6],ah
			mov	byte ptr [si+5],0
			push	di
			mov	ax,[si+2]
			call	word ptr cs:fight_cb_record_ofs
			mov	bl,ds:mao1_npc_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:mao1_sprite_xlat_tbl[bx],al
			add	si,10h
			inc	byte ptr ds:mao1_npc_idx
			pop	di
			inc	di

mao1_phase_emit_skip:
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,8
			jne	mao1_phase_emit_loop	; Jump if not equal

mao1_phase_inner_done:
		inc	bp
		inc	ax
		inc	ax
		pop	cx
		loop	mao1_phase_outer_jmp	; Loop if cx > 0

		jmp	short mao1_phase_terminate

mao1_phase_outer_jmp:
		jmp	mao1_phase_outer_loop

mao1_phase_terminate:
		mov	word ptr [si],0FFFFh
		retn

; ------------------------------------------------------------------
; mao1_dispatch_high_byte: invoked when xlat result has bit7 set.
; Dispatches based on top nibble: 80h=show dialog, C0h=text fill,
; E0h=set state byte, FFh=clear data_byte.
; ------------------------------------------------------------------

mao1_dispatch_high_byte:
		mov	dx,0A290h
		push	dx
		mov	ah,al
		and	al,0F0h
		cmp	al,80h
		je	mao1_dispatch_show_dialog	; Jump if equal
		cmp	al,0C0h
		je	mao1_dispatch_text_fill	; Jump if equal
		cmp	al,0E0h
		je	mao1_dispatch_set_state	; Jump if equal
		cmp	ah,0FFh
		je	mao1_dispatch_clear_d	; Jump if equal
		retn

mao1_dispatch_clear_d:
		mov	mao1_data_byte_d,0
		retn

mao1_dispatch_set_state:
		mov	byte ptr ds:mao1_gvar_state_byte,38h	; '8'
		retn

mao1_dispatch_show_dialog:
		and	ah,0Fh
		xor	bx,bx			; Zero register
		add	ah,ah
		mov	bl,ah
		mov	dx,ds:mao1_dialog_lo_tbl[bx]	; data_25e (0xA442) ?-- dialog handler ptr table
		push	si
		push	dx
		mov	bx,0E1Eh
		mov	cx,3410h
		mov	al,0FFh
		call	word ptr cs:mao1_drv_load_chunk
		pop	si
		lodsw				; String [si] to ax
		add	ax,3Ah
		mov	bx,ax
		mov	cl,22h			; '"'
		call	word ptr cs:mao1_drv_blit_render
		pop	si
		retn

mao1_dispatch_text_fill:
		mov	al,0FEh
		push	ds
		pop	es
		mov	di,mao1_text_dst
		mov	cx,2

mao1_text_fill_loop:
				push	cx
				push	di
				mov	cx,1Ah
				rep	stosb			; Rep when cx >0 Store al to es:[di]
				pop	di
				add	di,1Ch
				pop	cx
				loop	mao1_text_fill_loop	; Loop if cx > 0

		retn

; ------------------------------------------------------------------
; Trailer-region tile/glyph/atlas data + Jashiin dialog text + tile
; pair table + 'Jashiin' speaker name.
; ------------------------------------------------------------------

mao1_trailer_data	label	byte
		db	10 dup (0)
		db	 80h, 00h, 00h			; xlat: 80h=show dialog opcode
		db	28 dup (0)
mao1_xlat_row_c0_a	label	byte		; xlat row: C0h=text fill opcode + level-1 tiles
		db	0C0h, 00h, 01h, 01h, 02h, 02h	; xlat row
		db	 03h, 03h, 03h, 03h, 03h, 81h	; 81h=show dialog (slot 1)
		db	 03h, 03h, 03h	; xlat row
		db	26 dup (3)
mao1_xlat_row_c0_b	label	byte		; xlat row: more level tiles + slot-2 dialog
		db	0C0h, 03h, 03h, 03h, 04h, 04h	; xlat row
		db	 05h, 82h, 05h, 05h		; 82h=show dialog (slot 2)
		db	28 dup (5)
mao1_xlat_row_c0_c	label	byte		; xlat row: trailing levels + state-set + terminator
		db	0C0h, 05h, 05h, 06h, 06h, 07h	; xlat row
		db	0E0h, 08h, 08h, 09h, 09h, 0Ah	; E0h=set state byte
		db	 0Ah, 0Ah,0FFh			; FFh=clear data_byte_d (terminator)
mao1_dialog_lo_tbl_data	label	byte	; dialog handler lo-byte ptrs (A448/A463/A47A)
		db	 48h,0A4h, 63h	; dialog handler ptr
		db	0A4h, 7Ah,0A4h	; dialog handler ptr
mao1_dialog_lead_in	label	byte		; speaker / anim code prefix bytes
		db	 08h, 00h	; speaker / anim prefix

; --- Jashiin (pre-final boss) dialog block. ---
; 0x08/0x18 are speaker-position / anim codes; 0xFF terminates each line.

mao1_dialog_jashiin	label	byte
		db	'Finally, you reached me.'
		db	0FFh, 18h, 00h	; dialog terminator + anim code
		db	'I enjoyed your show.'
		db	0FFh, 08h, 00h	; dialog terminator + anim code
		db	'Come on!  I\ll kill you.'
		db	0FFh	; dialog terminator + anim code

; --- Tile-pair table following the dialog (9 word entries pointing
;     to arena handlers in DS, by hard offset 0xA4xx) ---

mao1_dialog_handler_tbl	label	word	; 9 word ptrs (A4ABh..A4FFh) into arena handlers
		db	0ABh,0A4h,0B1h,0A4h,0BAh	; A4ABh, A4B1h, A4BA...
		db	0A4h,0C4h,0A4h,0CFh,0A4h,0DBh	; A4C4h, A4CFh, A4DB...
		db	0A4h,0E8h,0A4h,0F3h,0A4h,0FFh	; A4E8h, A4F3h, A4FF...
		db	0A4h	; arena handler ptr

; ------------------------------------------------------------------
; Trailer dialog-data block: more bytes consumed by the dialog handler
; via the dispatch tables above (mao1_dialog_handler_tbl entries point
; into this region).  Sourcer rendered the bytes as x86 mnemonics;
; preserved verbatim since they assemble to the same byte stream.
; ------------------------------------------------------------------

mao1_dialog_data_b	label	byte
		push	cs
		movsw				; Mov [si] to es:[di]
		pop	ds
		movsw				; Mov [si] to es:[di]
		add	ax,403h
		add	al,[bx+si]
		add	[di],cx
		push	cs
		or	cx,[si]
		push	es
		pop	es
		or	cl,[bx+si]
		or	[bx+si],bx
		push	ss
		pop	ss
		adc	dl,[bp+di]
		adc	al,15h
		adc	[bx+si],dx
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		and	bx,ds:mao1_drv_dispatch_a
		and	[bp+si],sp
		sbb	[bp+si],bx
		sbb	bx,[si]
		sbb	ax,2327h
		push	ds
		and	al,25h			; '%'
		and	bl,es:[bx+di]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		sub	bp,[bp+si]
		and	bx,ds:mao1_drv_text_render
		and	bl,es:[bx+di]
		sbb	bl,[bp+di]
		sbb	al,1Dh
		and	bx,ds:mao1_drv_misc_callback
		and	bl,es:[bx+di]
		sub	al,2Dh			; '-'
		sbb	al,1Dh
		xor	dh,[di]
		push	ds
		xor	[si],si
		aaa				; Ascii adjust
		cmp	[bx+di],bx
		xor	[bp+di],dh
		cmp	ss:[si+42h],al
		inc	bx
		inc	bp
		push	ds
		aas				; Ascii adjust
		inc	ax
		inc	cx
		cmp	[bx+di],bx
		cmp	bh,[bp+di]
		cmp	al,3Eh			; '>'
		cmp	ax,5554h
		push	dx
		push	bx
		dec	di
		push	ax
		push	cx
		dec	dx
		dec	bx
		dec	sp
		dec	bp
		dec	si
		sbb	[bp+47h],ax
		dec	ax
		dec	cx
		db	'ace`bd[\]^NVWXYZE'
mao1_arena_ptr_tbl	label	byte		; 11 word ptrs (A545h..A57Bh) into arena segment
		db	0A5h, 4Bh,0A5h, 51h,0A5h, 57h	; A545, A551, A557
		db	0A5h, 5Dh,0A5h, 63h,0A5h, 57h	; A55D, A563, A557 (dup)
		db	0A5h, 69h,0A5h, 6Fh,0A5h, 75h	; A569, A56F, A575
		db	0A5h, 7Bh,0A5h			; A57B
mao1_glyph_atlas	label	byte		; small 3-bpp glyph atlas (6-byte rows)
		db	 00h, 00h, 04h	; glyph atlas row
		db	 0Ch, 08h, 18h, 00h, 00h, 0Ch	; glyph atlas row
		db	 0Ch, 38h, 18h, 00h, 04h, 0Ch	; glyph atlas row
		db	 3Ch, 18h, 08h, 00h, 00h, 04h	; glyph atlas row
		db	 7Ch, 7Ch, 00h, 00h, 00h, 14h	; glyph atlas row
		db	 7Ch, 7Ch, 00h, 00h, 20h, 24h	; glyph atlas row
		db	 7Ch, 7Ch, 00h, 00h, 00h, 30h	; glyph atlas row
		db	 7Ch, 7Ch, 00h, 00h	; glyph atlas row
		db	' p||', 8, '``p||'
		db	 00h, 00h,0E0h,0E0h, 7Ch, 7Ch	; glyph atlas row
mao1_arena_init_params	label	byte	; arena init parameters (timer/coords/state seeds)
		db	 00h, 10h, 00h, 01h,0FAh, 00h	; arena init param
		db	0C8h, 00h, 05h,0FFh, 8Eh,0A5h	; FFh=stop marker, A58Eh=ptr fixup
		db	 00h, 00h, 11h,0BBh, 02h, 07h	; arena init param

; --- 'Jashiin' speaker name + terminator + zero pad ---

mao1_speaker_jashiin	label	byte
		db	'Jashiin', 0, 0, 0, 0

_318MAPA5	endp

seg_a		ends

		end	start
