
PAGE  59,132

;==========================================================================
;
;  203GFCGA.BIN - CGA Graphics Fill Driver (zelres2 chunk 3)
;
;  CGA variant of the battle/gameplay sprite-fill driver. Renders sprites,
;  tiles, scrolling backgrounds, and hero/enemy graphics for 4-color CGA
;  graphics mode at B800h. Parallels 202GFEGA in structure (same dispatch
;  table layout, same drv_init_stub patchable byte, same sprite-scan loop).
;
;  Key difference vs 202GFEGA: CGA uses interleaved 2-plane framebuffer at
;  B800h (1FFEh between even/odd plane words; wrap back +C050h) instead of
;  EGA planar mapped A000h with sequencer register writes.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; restored after factoring (consensus value, but not all files agree):
dispatch_tbl             equ     3170h

; External data references (outside this module's CS segment).

; --- Game-segment data pointers (in game_seg via DS) ---
cga_sprite_base equ	6333h			;* CGA sprite graphics base (stage2 lookup)
bg_save_buf_a	equ	8640h			;* background save buffer A
bg_save_buf_b	equ	8690h			;* background save buffer B
cga_sprite_src	equ	0B000h			;* CGA sprite source data base (16-byte blocks)
cga_plane_alt	equ	0B17Eh			;* CGA alternate plane offset
cga_sprite_mid	equ	0D000h			;* CGA mid-priority sprite source base

; --- Internal driver tables (CS-relative) ---
anim_frame_tbl	equ	38D1h			;* animation frame offset table
pattern_ptr_tbl	equ	397Dh			;* pattern pointer table
sprite_tmp_buf	equ	4643h			;* sprite temporary pixel buffer
color_map_tbl	equ	4777h			;* CGA color map table
phase_offset_tbl equ	47BEh			;* phase/shift offset table
bg_tile_src	equ	4A3Ah			;* background tile source pointer
copy_fn_tbl	equ	4F88h			;* CGA copy function pointer table (word array)
hero_gfx_tbl	equ	4FCFh			;* hero graphics data table

; --- Driver state variables (CS-segment scratch area) ---
color_pair_tbl	equ	500Fh			;* CGA color pair lookup table (word array)
cur_color_pair	equ	506Bh			;* current CGA color pair word (set from table)
vga_row_ptr	equ	506Dh			;* current CGA row byte offset (word, +0x140/row)
scroll_vga_ofs	equ	506Fh			;* scroll destination CGA byte offset (word)
cga_ofs_5071	equ	5071h			;* CGA offset 0x5071 (scratch word)
row_counter	equ	5073h			;* row countdown (0x12 rows per frame)
col_idx		equ	5074h			;* current column index (byte)
row_idx		equ	5075h			;* current row index (byte)
palette_byte	equ	5076h			;* CGA color/palette byte for current sprite
bitmask_byte	equ	5077h			;* CGA bit mask byte for blitter
scroll_src_ofs	equ	5078h			;* scroll source CGA byte offset (word)
scroll_gfx_ptr	equ	507Ah			;* scroll graphics data pointer (word)
scroll_delta	equ	507Ch			;* scroll delta (word: col byte + row byte)
sprite_row_buf	equ	507Eh			;* sprite row intermediate buffer (word)
anim_phase	equ	5080h			;* animation pass counter (decremented)
shift_count	equ	5081h			;* CGA shift count byte
sprite_work_buf	equ	5082h			;* sprite work buffer (word array)
sprite_state_a	equ	5092h			;* sprite slot state byte A (0xFF=empty, 0xFC=hidden)
sprite_state_b	equ	5093h			;* sprite slot state byte B
sprite_pos	equ	5096h			;* sprite position word (col/row packed)
sprite_cache_tbl equ	509Fh			;* sprite CGA cache table (word array)
cache_tbl_b	equ	519Fh			;* second cache table
cache_tbl_c	equ	529Fh			;* third cache table
cache_tbl_d	equ	532Fh			;* fourth cache table

; --- Game-segment lookup tables ---
sprite_src_base_ds equ	0A030h			;* sprite source table (game_seg)
vga_wrap_adj	equ	0C050h			;* VGA wrap adjust (+0xC050 when di >= 0x4000)

; --- Pattern/background data (game_seg) ---
enemy_spawn_ctrl equ	0FB3Ah			;* enemy spawn control byte

; --- Global variables (game_seg:0xFFxx) ---

; --- Fixed CGA layout constants ---
cga_col_stride	equ	0A0h			; CGA bytes per interleaved row (160)
hud_ofs		equ	23Ch			; HUD area starting byte offset in CGA framebuffer
ui_ofs		equ	0D94h			; UI area byte offset
cga_wrap_add	equ	0C050h			; CGA interleave wrap adjust (same as vga_wrap_adj)

cga_seg		equ	0B800h			; CGA framebuffer segment

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gfcga_main		proc	far

start:
; gfcga_main init block (0x0000-0x002F): header / dispatch init table.
; Sourcer mis-decodes these bytes as instructions. They are a word-pair pointer
; table of driver entry points, mapping dispatch function indices to CS-relative
; handler addresses (parallel to 202GFEGA.asm 0x000B-0x002F).
		db	 3Fh, 23h, 00h, 00h, 2Ch, 30h	; dispatch init bytes 0x00-0x05
		db	 9Bh, 3Ah,0FBh, 3Fh, 0Ah, 3Fh	; 0x06-0x0B
		db	 81h, 41h, 7Eh, 45h,0ACh, 40h	; 0x0C-0x11
		db	 6Ch, 32h,0D5h, 38h,0CDh, 41h	; 0x12-0x17
		db	 43h, 41h, 85h, 3Ah,0FCh, 42h	; 0x18-0x1D
		db	 99h, 45h,0E3h, 45h,0EDh, 46h	; 0x1E-0x23
		db	 29h, 41h,0B6h, 49h, 05h, 4Ah	; 0x24-0x29
		db	 66h, 4Bh,0F5h, 4Eh,0BAh, 4Fh	; 0x2A-0x2F
; gfcga_main inline init block (0x0030-0x005D): parallel to 202GFEGA.
		push	cs
		pop	es
		mov	di,sprite_cache_tbl
		xor	ax,ax
		mov	cx,80h
		rep	stosw				; zero sprite_cache_tbl (0x80 words)
; [0x003C] drv_init_stub: label is at instruction start; opcode byte (FEh) is a patch
; target ?-- callers may overwrite it to skip or alter init.

drv_init_stub:
		inc	byte ptr ds:anim_phase	; FE 06 80 50  (opcode byte patched by caller)
		mov	word ptr ds:vga_row_ptr,023Ch
		mov	si,word ptr ds:sprite_data_ptr
		sub	si,21h
; [0x004D-0x004F] call with mid-instruction label: cga_row_ofs labels the
; displacement bytes. Callers patch the displacement to redirect this call at runtime.
; Current target: 0050h + 158Bh = 15DBh (si_wrap_lo).
		db	0E8h				; call near opcode
cga_row_ofs	db	8Bh,15h			; displacement (patch target); initially calls 15DBh
; [0x0050] resumes as normal code:
		xor	bx,bx
		test	byte ptr [si],80h
		jz	init_scan_next			; skip if slot empty
		call	sprite_slot_remove

init_scan_next:
		inc	si
		mov	cx,6

sprite_scan_loop:
					push	cx
					test	byte ptr [si],80h
					jz	loc_2			; Jump if zero
					call	sprite_slot_init

loc_2:
					inc	si
					inc	bx
					test	byte ptr [si],80h
					jz	loc_3			; Jump if zero
					call	sprite_slot_init

loc_3:
					inc	si
					inc	bx
					test	byte ptr [si],80h
					jz	loc_4			; Jump if zero
					call	sprite_slot_init

loc_4:
					inc	si
					inc	bx
					test	byte ptr [si],80h
					jz	loc_5			; Jump if zero
					call	sprite_slot_init

loc_5:
					inc	si
					inc	bx
					pop	cx
					loop	sprite_scan_loop	; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_6			; Jump if zero
		call	sprite_slot_init

loc_6:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_7			; Jump if zero
		call	sprite_slot_init

loc_7:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_8			; Jump if zero
		call	sprite_slot_init

loc_8:
		inc	si
		test	byte ptr [si],80h
		jz	row_scan_done			; Jump if zero
		call	sprite_blit_dispatch

row_scan_done:
		mov	si,ds:sprite_data_ptr
		mov	di,0E900h
		mov	byte ptr ds:row_counter,12h

row_render_loop:
					call	frame_row_driver
					xor	bx,bx			; Zero register
					add	si,3
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jns	loc_11			; Jump if not sign
					call	sprite_wide_row_render

loc_11:
					mov	cx,6

col_scan_loop:
								push	cx
								cmpsb				; Cmp [si] to es:[di]
								jz	loc_13			; Jump if zero
								call	sprite_state_update

loc_13:
								inc	bx
								cmpsb				; Cmp [si] to es:[di]
								jz	loc_14			; Jump if zero
								call	sprite_state_update

loc_14:
								inc	bx
								cmpsb				; Cmp [si] to es:[di]
								jz	loc_15			; Jump if zero
								call	sprite_state_update

loc_15:
								inc	bx
								cmpsb				; Cmp [si] to es:[di]
								jz	loc_16			; Jump if zero
								call	sprite_state_update

loc_16:
								inc	bx
								pop	cx
								loop	col_scan_loop		; Loop if cx > 0

					cmpsb				; Cmp [si] to es:[di]
					jz	loc_17			; Jump if zero
					call	sprite_state_update

loc_17:
					inc	bx
					cmpsb				; Cmp [si] to es:[di]
					jz	loc_18			; Jump if zero
					call	sprite_state_update

loc_18:
					inc	bx
					cmpsb				; Cmp [si] to es:[di]
					jz	loc_19			; Jump if zero
					call	sprite_state_update

loc_19:
					inc	bx
					lodsb				; String [si] to al
					inc	di
					or	al,al			; Zero ?
					jns	row_advance			; Jump if not sign
					jmp	sprite_neg_handler

row_advance:
					cmp	al,es:[di-1]
					je	loc_21			; Jump if equal
					call	sprite_state_update

loc_21:
					add	si,4
					call	si_wrap_hi
					add	word ptr ds:vga_row_ptr,140h
					dec	byte ptr ds:row_counter
					jnz	row_render_loop			; Jump if not zero
		retn

gfcga_main		endp

sprite_state_update		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_22			; Jump if not sign
		jmp	loc_78

loc_22:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_23			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_24

loc_23:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_24			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		call	cga_sprite_blit

loc_24:
		mov	al,ds:sprite_attr_b
		sub	al,5
		jnc	loc_25			; Jump if carry=0
		retn

loc_25:
		cmp	al,4
		jb	loc_26			; Jump if below
		retn

loc_26:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:dispatch_tbl[bx]	;*
		pop	bx
		retn

sprite_state_update		endp

; Dispatch handler: 2-frame alternating animation (frame base 0x1B, 2 frames).
; Called via dispatch_tbl[bx].

anim_cycle_2frame_1B:
		js	loc_29+1		; Overlapping-instruction trick: jumps to byte 1 of the
						; 4-byte MOV at loc_29. See 202GFEGA for full analysis.
		cbw				; Convrt byte to word
		db	 31h,0CEh		; xor si, cx  (alt encoding: 31/CE; TASM uses 33/C6)
		xor	[si+32h],cx
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	loc_27			; Jump if below
		retn

loc_27:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_28			; Jump if not zero
		retn

loc_28:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn

; Dispatch handler: 6-frame bidirectional animation (frame base 0x1D, 6 frames 0x1D..0x22).

anim_cycle_6frame_1D:
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_29			; Jump if below
		retn

loc_29:				; Entry +0: JB path ?-- marks sprite slot active, then checks frame phase.
		mov	byte ptr [di-1],0FEh	; +0: slot marker (JS path enters at +1)
		cmp	al,4
		jae	loc_32			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_31			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_31			; Jump if zero
		retn

loc_31:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn

loc_32:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn

; Dispatch handler: complex multi-direction animation (frame base 0x2C).
; Handles 0x2C/0x2D bidirectional cycling; higher frames map through a lookup.

anim_cycle_2frame_2C:
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_34			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_33			; Jump if not zero
		retn

loc_33:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn

loc_34:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_35			; Jump if below
		retn

loc_35:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_37			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_37			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_37			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_37			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_37			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_36			; Jump if carry=0
		retn

loc_36:
		mov	bl,0Eh
		cmp	al,2
		je	loc_37			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_37			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_37			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_37			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_37			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al

loc_37:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_38			; Jump if not zero
		retn

loc_38:
		mov	[si-1],bl
		retn

; Dispatch handler: 4-frame cycling animation (frame base 0x25, 4 frames 0x25..0x28).

anim_cycle_4frame_25:
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_39			; Jump if below
		retn

loc_39:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_40			; Jump if not zero
		retn

loc_40:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

cga_sprite_blit		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_41			; Jump if not zero
		jmp	loc_60

loc_41:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:sprite_cache_tbl[bx],0FFFFh
		jnz	loc_45			; Jump if not zero
		dec	al
		mov	ds:sprite_cache_tbl[bx],di
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

blit_copy_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	loc_43			; Jump if below
					add	di,cga_wrap_add

loc_43:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	loc_44			; Jump if below
					add	di,cga_wrap_add

loc_44:
					loop	blit_copy_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_45:
		mov	si,ds:sprite_cache_tbl[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_46			; Jump if below
		add	di,cga_wrap_add

loc_46:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_47			; Jump if below
		add	si,cga_wrap_add

loc_47:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_48			; Jump if below
		add	di,cga_wrap_add

loc_48:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_49			; Jump if below
		add	si,cga_wrap_add

loc_49:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_50			; Jump if below
		add	di,cga_wrap_add

loc_50:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_51			; Jump if below
		add	si,cga_wrap_add

loc_51:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_52			; Jump if below
		add	di,cga_wrap_add

loc_52:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_53			; Jump if below
		add	si,cga_wrap_add

loc_53:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_54			; Jump if below
		add	di,cga_wrap_add

loc_54:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_55			; Jump if below
		add	si,cga_wrap_add

loc_55:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_56			; Jump if below
		add	di,cga_wrap_add

loc_56:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_57			; Jump if below
		add	si,cga_wrap_add

loc_57:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_58			; Jump if below
		add	di,cga_wrap_add

loc_58:
		add	si,1FFEh
		cmp	si,4000h
		jb	loc_59			; Jump if below
		add	si,cga_wrap_add

loc_59:
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_60:
		mov	ax,0B800h
		mov	es,ax
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_61			; Jump if below
		add	di,cga_wrap_add

loc_61:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_62			; Jump if below
		add	di,cga_wrap_add

loc_62:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_63			; Jump if below
		add	di,cga_wrap_add

loc_63:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_64			; Jump if below
		add	di,cga_wrap_add

loc_64:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_65			; Jump if below
		add	di,cga_wrap_add

loc_65:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_66			; Jump if below
		add	di,cga_wrap_add

loc_66:
		stosw				; Store ax to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_67			; Jump if below
		add	di,cga_wrap_add

loc_67:
		stosw				; Store ax to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

cga_sprite_blit		endp

; sprite_slot_remove -- called from gfcga_main init block via inline sprite-scan.
; If sprite_buf slot is empty (0xFF) or hidden (0xFC), skip; else blit and restore.

sprite_slot_remove:
		cmp	byte ptr ds:sprite_buf,0FFh
		jne	loc_68			; Jump if not equal
		retn

loc_68:
		cmp	byte ptr ds:sprite_buf,0FCh
		jne	loc_69			; Jump if not equal
		retn

loc_69:
		push	si
		push	bx
		mov	byte ptr ds:sprite_buf,0FFh
		mov	cl,[si]
		add	si,25h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_70			; Jump if not sign
		call	sprite_get_value

loc_70:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,23Ch
		call	sprite_cell_render
		pop	bx
		pop	si
		retn

sprite_slot_init		proc	near
		push	si
		push	bx
		mov	cx,bx
		mov	di,bx
		add	di,sprite_buf
		mov	bx,sprite_state_a
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	byte ptr [bx+1],0
		mov	byte ptr [di+1],0FFh
		mov	dx,cx
		add	dx,dx
		add	dx,23Ch
		mov	cl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	bx,sprite_pos
		lodsw				; String [si] to ax
		mov	[bx],ax
		mov	al,cl
		call	sprite_src_setup
		inc	si
		inc	si
		mov	di,sprite_pos
		mov	bp,sprite_state_a
		call	sprite_pos_pair_iter
		pop	bx
		pop	si
		retn

sprite_slot_init		endp

sprite_blit_dispatch		proc	near
		cmp	byte ptr ds:sprite_buf_b,0FFh
		jne	loc_71			; Jump if not equal
		retn

loc_71:
		cmp	byte ptr ds:sprite_buf_b,0FCh
		jne	loc_72			; Jump if not equal
		retn

loc_72:
		mov	byte ptr ds:sprite_buf_b,0FFh
		mov	cl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_73			; Jump if not sign
		call	sprite_get_value

loc_73:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,272h
		jmp	loc_87

sprite_blit_dispatch		endp

sprite_wide_row_render		proc	near
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,sprite_state_a
		mov	al,0FFh
		xchg	[di],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Ch],al
		mov	[bx+1],al
		mov	cl,[si-1]
		mov	dl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	dh,[si]
		mov	al,cl
		call	sprite_src_setup
		inc	si
		mov	bx,dx
		pop	dx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_75			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_75			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_74			; Jump if not sign
		call	sprite_get_value

loc_74:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_75:
		add	dx,140h
		cmp	byte ptr ds:row_counter,1
		je	loc_77			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_77			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_77			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_76			; Jump if not sign
		call	sprite_get_value

loc_76:
		call	sprite_cell_render

loc_77:
		pop	bx
		pop	di
		pop	si
		retn

loc_78:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,sprite_state_a
		mov	ax,0FFFEh
		xchg	[di-1],ax
		mov	[bx],ax
		mov	ax,0FFFFh
		xchg	[di+1Bh],ax
		mov	[bx+2],ax
		mov	cl,[si-1]
		mov	bx,sprite_pos
		mov	al,[si]
		mov	[bx+1],al
		add	si,24h
		call	si_wrap_hi
		mov	ax,[si-1]
		mov	[bx+2],ax
		pop	dx
		mov	ds:col_idx,dl
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	ds:row_idx,al
		add	dx,dx
		add	dx,ds:vga_row_ptr
		mov	al,cl
		call	sprite_src_setup
		mov	di,sprite_pos
		mov	[di],al
		mov	bp,sprite_state_a
		call	sprite_pos_pair_iter
		cmp	byte ptr ds:row_counter,1
		je	blit_disp_end			; Jump if equal
		add	dx,13Ch
		call	sprite_pos_pair_iter
		test	byte ptr ds:flag_equip_b,0FFh
		jz	blit_disp_end			; Jump if zero
		test	byte ptr ds:flag_shadow,0FFh
		jz	blit_disp_end			; Jump if zero
		call	projectile_spawn_check

blit_disp_end:
		pop	bx
		pop	di
		pop	si
		retn

sprite_neg_handler:
		push	si
		push	di
		push	bx
		push	bx
		mov	bx,sprite_state_a
		mov	al,0FEh
		xchg	[di-1],al
		mov	[bx],al
		mov	al,0FFh
		xchg	[di+1Bh],al
		mov	[bx+1],al
		mov	cl,[si-1]
		add	si,24h
		call	si_wrap_hi
		mov	dl,[si-1]
		mov	al,cl
		call	sprite_src_setup
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_82			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_82			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_81			; Jump if not sign
		call	sprite_get_value

loc_81:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_82:
		add	dx,140h
		cmp	byte ptr ds:row_counter,1
		je	loc_84			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_84			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_84			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_83			; Jump if not sign
		call	sprite_get_value

loc_83:
		call	sprite_cell_render

loc_84:
		pop	bx
		pop	di
		pop	si
		jmp	loc_21

sprite_wide_row_render		endp

sprite_pos_pair_iter		proc	near
		call	sprite_pos_blit

sprite_pos_blit:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_86			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_86			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_85			; Jump if not sign
		call	sprite_get_value

loc_85:
		push	bp
		push	si
		push	di
		push	dx
		call	sprite_cell_render
		pop	dx
		pop	di
		pop	si
		pop	bp

loc_86:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

sprite_pos_pair_iter		endp

sprite_cell_render		proc	near

loc_87:
		push	es
		push	ds
		mov	bl,ds:palette_byte
		or	al,al			; Zero ?
		jz	loc_88			; Jump if zero
		js	loc_88			; Jump if sign=1
		or	bl,80h

loc_88:
		mov	cl,al
		mov	al,ah
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,sprite_gfx_base
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:game_seg
		mov	di,dx
		push	cs
		pop	es
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_89			; Jump if sign=1
		push	di
		mov	di,532Fh
		call	cga_sprite_render_solid
		pop	di
		mov	si,cache_tbl_d
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	cga_blit_2rows_stride
		pop	ds
		pop	es
		retn

loc_89:
		push	di
		mov	di,cache_tbl_d
		call	cga_sprite_blit_ex
		pop	di
		mov	si,cache_tbl_d
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	cga_blit_2rows_stride
		pop	ds
		pop	es
		retn

sprite_cell_render		endp

cga_sprite_blit_ex		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	sprite_copy_8words
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

cga_sprite_blit_ex		endp

cga_sprite_render_blended		proc	near
		mov	cx,8

blend_row_loop:
					mov	ax,ds:[bp]
					and	es:[di],ax
					lodsw				; String [si] to ax
					call	sprite_bit_extract
					or	es:[di],ax
					inc	bp
					inc	bp
					inc	di
					inc	di
					loop	blend_row_loop		; Loop if cx > 0

		retn

cga_sprite_render_blended		endp

cga_sprite_render_solid		proc	near
		mov	cx,8

solid_row_loop:
					lodsw				; String [si] to ax
					call	sprite_bit_extract
					stosw				; Store ax to es:[di]
					loop	solid_row_loop		; Loop if cx > 0

		retn

cga_sprite_render_solid		endp

sprite_bit_extract		proc	near
		mov	bx,ax
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		shr	bh,1			; Shift w/zeros fill
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:cur_color_pair
		mov	dh,cs:[bx]
		add	dh,dh
		add	dh,dh
		add	dh,dh
		add	dh,dh
		mov	bx,ax
		and	bh,0Fh
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	bx,cs:cur_color_pair
		or	dh,cs:[bx]
		mov	bx,ax
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		add	bx,cs:cur_color_pair
		mov	dl,cs:[bx]
		add	dl,dl
		add	dl,dl
		add	dl,dl
		add	dl,dl
		mov	bx,ax
		and	bl,0Fh
		xor	bh,bh			; Zero register
		add	bx,cs:cur_color_pair
		or	dl,cs:[bx]
		mov	ax,dx
		retn

sprite_bit_extract		endp

cga_blit_2rows_stride		proc	near
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_92			; Jump if below
		add	di,cga_wrap_add

loc_92:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_93			; Jump if below
		add	di,cga_wrap_add

loc_93:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_94			; Jump if below
		add	di,cga_wrap_add

loc_94:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_95			; Jump if below
		add	di,cga_wrap_add

loc_95:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_96			; Jump if below
		add	di,cga_wrap_add

loc_96:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_97			; Jump if below
		add	di,cga_wrap_add

loc_97:
		movsw				; Mov [si] to es:[di]
		add	di,1FFEh
		cmp	di,4000h
		jb	loc_98			; Jump if below
		add	di,cga_wrap_add

loc_98:
		movsw				; Mov [si] to es:[di]
		retn

cga_blit_2rows_stride		endp

sprite_copy_8words		proc	near
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn

sprite_copy_8words		endp

sprite_clear_8words		proc	near
		xor	ax,ax			; Zero register
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

sprite_clear_8words		endp

sprite_get_value		proc	near
		and	al,7Fh
		mov	bx,char_lookup
		xlat				; al=[al+[bx]] table
		retn

sprite_get_value		endp

sprite_src_setup		proc	near
		and	al,7Fh
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	cl,ds:char_lookup[bx]
		mov	ch,10h
		mul	ch			; ax = reg * al
		add	ax,ds:sprite_attr_base
		mov	bp,ax
		mov	al,ds:[bp+6]
		and	al,0Fh
		mov	ch,5
		mul	ch			; ax = reg * al
		mov	si,0A070h
		test	byte ptr ds:[bp+5],80h
		jnz	loc_99			; Jump if not zero
		mov	si,sprite_src_base_ds

loc_99:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:flag_equip_b,0FFh
		jnz	loc_100			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_100			; Jump if zero
		add	al,3

loc_100:
		mov	ds:palette_byte,al
		mov	al,cl
		retn

sprite_src_setup		endp

projectile_spawn_check		proc	near
		cmp	byte ptr ds:row_idx,10h
		jb	loc_101			; Jump if below
		retn

loc_101:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_102			; Jump if above or =
		retn

loc_102:
		mov	di,projectile_list
		xor	cl,cl			; Zero register

loc_103:
					cmp	byte ptr [di],0FFh
					je	loc_104			; Jump if equal
					add	di,4
					inc	cl
					jmp	short loc_103

loc_104:
		cmp	cl,20h			; ' '
		jb	loc_105			; Jump if below
		retn

loc_105:
					call	word ptr cs:[11Ah]
					and	al,3
					cmp	al,3
					je	loc_105			; Jump if equal
		dec	al
		add	al,ds:col_idx
		cmp	al,0FFh
		jne	loc_106			; Jump if not equal
		mov	al,4

loc_106:
		cmp	al,1Bh
		jb	loc_107			; Jump if below
		mov	al,1Ah

loc_107:
		stosb				; Store al to es:[di]

loc_108:
					call	word ptr cs:[11Ah]
					and	al,3
					cmp	al,3
					je	loc_108			; Jump if equal
		dec	al
		add	al,ds:row_idx
		cmp	al,0FFh
		jne	loc_109			; Jump if not equal
		xor	al,al			; Zero register

loc_109:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		mov	bx,anim_frame_tbl
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

projectile_spawn_check		endp

; Dispatch-table prologue -- 11 dispatch bytes preceding proj_blit_entry.
; Sourcer mis-decodes as "push bp / stosb / jmp dword ptr ss:[70Eh][bp+si] / db ...".
; These are actually data bytes reached via patched call (cga_row_ofs) when
; projectile blit is selected.
		db	 55h,0AAh,0FFh,0AAh, 0Eh, 07h	; dispatch prologue bytes 0..5
		db	0BFh,0A0h,0EDh, 8Bh,0F7h	; dispatch prologue bytes 6..10

proj_blit_entry:
		cmp	byte ptr [si],0FFh
		jne	proj_row_build			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn

proj_row_build:
		mov	al,[si+1]
		mov	cl,1Ch
		mul	cl			; ax = reg * al
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	ax,cx
		push	di
		add	ax,0E900h
		mov	di,ax
		mov	al,0FEh
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		add	di,1Ah
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		pop	di
		mov	ah,[si+1]
		xor	al,al			; Zero register
		mov	bx,ax
		add	ax,ax
		shr	bx,1			; Shift w/zeros fill
		add	ax,bx
		shr	ax,1			; Shift w/zeros fill
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,23Ch
		push	si
		push	di
		push	es
		push	ax
		mov	al,[si+3]
		mov	ds:bitmask_byte,al
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:pattern_ptr_tbl[bx]
		pop	di
		mov	ax,0B800h
		mov	es,ax
		mov	cx,10h

proj_blit_row_loop:
					lodsw				; String [si] to ax
					and	al,ds:bitmask_byte
					and	ah,ds:bitmask_byte
					or	es:[di],ax
					lodsw				; String [si] to ax
					and	al,ds:bitmask_byte
					and	ah,ds:bitmask_byte
					or	es:[di+2],ax
					add	di,2000h
					cmp	di,4000h
					jb	loc_113			; Jump if below
					add	di,vga_wrap_adj

loc_113:
					loop	proj_blit_row_loop		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	proj_row_next			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4

proj_row_next:
		add	si,4
		jmp	proj_blit_entry

; sprite_shape_tbl -- 9-byte header + sprite bitmap data for various projectile / UI shapes.
; Sourcer can't trace entry, but this data is accessed via CS-relative pointer tables
; (sprite_tmp_buf, bg_tile_src, etc.) that index into this block.

sprite_shape_tbl:
		db	 45h, 3Ah, 05h, 3Ah,0C5h, 39h, 85h, 39h, 00h	; 9-byte header
		db	16 dup (0)					; 16-byte zero pad
; --- shape 0: small projectile / spark (5 rows x 6 bytes CGA 2bpp) ---
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh			; shape 0 row 0
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h			; shape 0 row 1
		db	0F0h, 0Fh, 00h, 00h,0F0h, 0Fh			; shape 0 row 2
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h			; shape 0 row 3
		db	 3Fh,0FCh, 00h, 00h, 0Fh,0F0h			; shape 0 row 4
		db	26 dup (0)					; pad before shape 1
; --- shape 1: medium projectile / star (8 rows x 6 bytes) ---
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh			; shape 1 row 0
		db	 00h, 00h,0FFh,0FFh, 00h, 00h			; shape 1 row 1
		db	0FCh, 3Fh, 00h, 03h,0F0h, 0Fh			; shape 1 row 2
		db	0C0h, 03h,0C0h, 03h,0C0h, 03h			; shape 1 row 3 (center bar)
		db	0C0h, 03h,0C0h, 03h,0F0h, 0Fh			; shape 1 row 4
		db	0C0h, 00h,0FCh, 3Fh, 00h, 00h			; shape 1 row 5
		db	0FFh,0FFh, 00h, 00h, 3Fh,0FCh			; shape 1 row 6
		db	 00h, 00h, 0Fh,0F0h				; shape 1 row 7 (partial 4 bytes)
		db	10 dup (0)					; pad before shape 2
; --- shape 2: large explosion / spell burst (~17 rows x 6 bytes) ---
		db	 0Fh,0F0h, 00h, 00h,0FFh,0FFh			; shape 2 row 0
		db	 00h, 03h,0FFh,0FFh,0C0h, 0Fh			; shape 2 row 1
		db	0FFh,0FFh,0F0h, 3Fh,0F0h, 0Fh			; shape 2 row 2
		db	0FCh, 3Fh,0C0h, 03h,0FCh,0FFh			; shape 2 row 3
		db	 00h, 00h,0FFh,0FFh, 00h, 00h			; shape 2 row 4
		db	0FFh,0FFh, 00h, 00h,0FFh,0FFh			; shape 2 row 5
		db	 00h, 00h,0FFh, 3Fh,0C0h, 03h			; shape 2 row 6
		db	0FCh, 3Fh,0F0h, 0Fh,0FCh, 0Fh			; shape 2 row 7
		db	0FFh,0FFh,0F0h, 03h,0FFh,0FFh			; shape 2 row 8
		db	0C0h, 00h,0FFh,0FFh, 00h, 00h			; shape 2 row 9
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh			; shape 2 row 10
		db	 00h, 03h,0FFh,0FFh,0C0h, 0Fh			; shape 2 row 11
		db	0C0h, 03h,0F0h, 3Fh, 00h, 00h			; shape 2 row 12
		db	0FCh, 3Ch, 00h, 00h, 3Ch,0FCh			; shape 2 row 13
		db	 00h, 00h, 3Fh,0F0h, 00h, 00h			; shape 2 row 14
		db	 0Fh,0F0h, 00h, 00h, 0Fh,0F0h			; shape 2 row 15
		db	 00h, 00h, 0Fh,0F0h, 00h, 00h			; shape 2 row 16
		db	 0Fh,0FCh, 00h, 00h, 3Fh, 3Ch			; shape 2 row 17
		db	 00h, 00h, 3Ch, 3Fh, 00h, 00h			; shape 2 row 18
		db	0FCh, 0Fh,0C0h, 03h,0F0h, 03h			; shape 2 row 19
		db	0FFh,0FFh,0C0h, 00h, 3Fh,0FCh			; shape 2 row 20
; --- trailing CGA blit code stub disassembled as data (Sourcer mis-decoded) ---
		db	 00h,0BFh, 96h, 50h, 0Eh, 07h			; code: stub mov bx, push bx, push es...
		db	 33h,0C0h,0ABh,0ABh,0ABh,0ABh			; code: xor ax,ax; stosw x4
		db	0AAh,0BFh, 82h, 50h,0B9h, 08h			; code: stosb; mov bx; mov cx,8
		db	 00h,0F3h,0ABh,0EBh, 3Ch,0E8h			; code: rep stosw; jmp short; call
		db	 04h, 04h,0BFh, 82h, 50h, 8Ah			; code: db 04,04; mov bx,5082h; mov...
		db	 16h, 35h,0FFh,0FEh,0CAh,0B9h			; code: ...mov dl,[35FFh]; dec dl; mov cx
		db	 04h, 00h					; code: cx=0x0004 immediate

pattern_build_row:
					push	cx
					and	dl,3Fh			; '?'
					mov	al,24h			; '$'
					mul	dl			; ax = reg * al
					mov	bx,ax
					add	bx,pattern_base
					mov	al,byte ptr ds:[83h]
					add	al,3
					xor	ah,ah			; Zero register
					add	bx,ax
					mov	cx,4

pattern_build_col:
								mov	al,[bx]
								or	al,al			; Zero ?
								js	loc_117			; Jump if sign=1
								xor	al,al			; Zero register

loc_117:
								mov	[di],al
								inc	bx
								inc	di
								loop	pattern_build_col		; Loop if cx > 0

					inc	dl
					pop	cx
					loop	pattern_build_row		; Loop if cx > 0

		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,140h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,23Ch
		mov	ds:scroll_vga_ofs,ax
		mov	byte ptr ds:col_idx,0
		mov	si,5096h
		mov	di,sprite_work_buf
		mov	cx,3

anim_check_outer:
					push	cx
					mov	cx,3

anim_check_inner:
								push	cx
								mov	ax,3B66h
								push	ax
								mov	al,[di]
								or	al,[di+1]
								or	al,[di+4]
								or	al,[di+5]
								jnz	loc_120			; Jump if not zero
								jmp	loc_157

loc_120:
								test	byte ptr [di],0FFh
								jz	loc_121			; Jump if zero
								mov	al,[di]
								push	si
								call	sprite_src_setup
								inc	si
								inc	si
								inc	si
								mov	al,[si]
								pop	si
								jmp	loc_159

loc_121:
								test	byte ptr [di+1],0FFh
								jz	loc_122			; Jump if zero
								mov	al,[di+1]
								push	si
								call	sprite_src_setup
								inc	si
								inc	si
								mov	al,[si]
								pop	si
								jmp	loc_159

loc_122:
								test	byte ptr [di+4],0FFh
								jz	loc_123			; Jump if zero
								mov	al,[di+4]
								push	si
								call	sprite_src_setup
								inc	si
								mov	al,[si]
								pop	si
								jmp	loc_159

loc_123:
								mov	al,[di+5]
								push	si
								call	sprite_src_setup
								mov	cl,[si]
								pop	si
								mov	[si],al
								mov	al,cl
								jmp	loc_159

; anim_check_continue -- fall-through from loc_117 branches (not directly
; reached, but the preceding jumps all exit via loc_159 leaving this code
; reachable from the anim check outer loop's natural continuation).

anim_check_continue:
								inc	byte ptr ds:col_idx
								inc	di
								inc	si
								pop	cx
								loop	anim_check_inner		; Loop if cx > 0

					pop	cx
					inc	di
					loop	anim_check_outer		; Loop if cx > 0

		mov	bl,ds:color_sel
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	es,cs:game_seg
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_124			; Jump if zero
		jmp	loc_134

loc_124:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_125			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h

loc_125:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_129			; Jump if zero
		inc	cl
		jnz	loc_126			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	hero_tier_get
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_132

loc_126:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_127			; Jump if not zero
		add	ax,24h
		jmp	short loc_128

loc_127:
		dec	dl
		jnz	loc_128			; Jump if not zero
		mov	ax,63h

loc_128:
		add	si,ax
		jmp	short loc_132

loc_129:
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_131			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_131			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:flag_shield
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_130			; Jump if zero
		add	ax,1Bh

loc_130:
		add	si,ax
		jmp	short loc_132

loc_131:
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_134			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_134			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_134			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_133

loc_132:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_133			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		call	sprite_col_render_loop
		jmp	short loc_134

loc_133:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	sprite_col_render_loop

loc_134:
		mov	si,610Eh
		test	byte ptr ds:flag_riding,0FFh
		jnz	loc_139			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:flag_climbing,0FFh
		jnz	loc_137			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_135			; Jump if not zero
		mov	si,game_data_base

loc_135:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_136			; Jump if zero
		add	si,5Ah
		jmp	short loc_137

loc_136:
		mov	ax,2Dh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_138			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:equip_byte,80h
		jnz	loc_138			; Jump if not zero
		mov	cl,ds:shield_sel
		mov	ax,48h
		dec	cl
		jz	loc_138			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_138			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:equip_byte,7Fh
		je	loc_138			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_138			; Jump if equal

loc_137:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al

loc_138:
		add	si,ax

loc_139:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	sprite_col_render_loop
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_140			; Jump if zero
		retn

loc_140:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_141			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h

loc_141:
		mov	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_143			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jnz	loc_142			; Jump if not zero
		retn

loc_142:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_150

loc_143:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_147			; Jump if zero
		inc	cl
		jnz	loc_144			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	hero_tier_get
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_151

loc_144:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_145			; Jump if not zero
		add	ax,24h
		jmp	short loc_146

loc_145:
		dec	dl
		jnz	loc_146			; Jump if not zero
		mov	ax,63h

loc_146:
		add	si,ax
		jmp	short loc_151

loc_147:
		test	byte ptr ds:[0C2h],1
		jz	loc_149			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_149			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:flag_shield
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_148			; Jump if zero
		add	ax,1Bh

loc_148:
		add	si,ax
		jmp	short loc_151

loc_149:
		mov	ax,1Bh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_150			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_150			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al

loc_150:
		add	si,ax

loc_151:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_152			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		jmp	short sprite_col_inner

loc_152:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		jmp	short sprite_col_inner

sprite_col_render_loop		proc	near

sprite_col_inner:
					push	cx
					mov	al,es:[si]
					or	al,al			; Zero ?
					jz	loc_154			; Jump if zero
					push	es
					push	ds
					push	si
					push	di
					mov	ch,10h
					mul	ch			; ax = reg * al
					mov	si,ax
					add	si,cga_sprite_base
					mov	bp,ax
					add	bp,cga_sprite_mid
					mov	ds,cs:game_seg
					mov	di,dx
					push	cs
					pop	es
					mov	al,cs:col_idx
					mov	cl,10h
					mul	cl			; ax = reg * al
					add	ax,529Fh
					mov	di,ax
					call	cga_sprite_render_blended
					pop	di
					pop	si
					pop	ds
					pop	es

loc_154:
					inc	si
					inc	byte ptr ds:col_idx
					pop	cx
					loop	sprite_col_inner		; Loop if cx > 0

		retn

sprite_col_render_loop		endp

hero_tier_get		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_155			; Jump if not zero
		retn

loc_155:
		cmp	al,4
		mov	al,1
		jnc	loc_156			; Jump if carry=0
		retn

loc_156:
		mov	al,2
		retn

hero_tier_get		endp

loc_157:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:game_seg
		push	cs
		pop	es
		mov	al,cs:col_idx
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,529Fh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_158			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	sprite_copy_8words
		pop	di
		pop	si
		pop	ds
		retn

loc_158:
		call	sprite_clear_8words
		pop	di
		pop	si
		pop	ds
		retn

loc_159:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_160			; Jump if not sign
		call	sprite_get_value

loc_160:
		push	ax
		mov	bl,ds:palette_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,dx
		mov	al,cl
		mov	ch,10h
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,sprite_gfx_base
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:game_seg
		push	cs
		pop	es
		mov	al,cs:col_idx
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,529Fh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_161			; Jump if zero
		mov	cl,al
		call	cga_sprite_blit_ex
		pop	di
		pop	si
		pop	ds
		retn

loc_161:
		call	cga_sprite_render_solid
		pop	di
		pop	si
		pop	ds
		retn
; sprite_row_ptr_fetch -- compute sprite_data_ptr + col + 0x24*row, then copy 3 records
; of 5 bytes each into sprite_pos (CS-relative) with si wrap.

sprite_row_ptr_fetch:
		mov	cl,byte ptr ds:[84h]
		mov	al,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		add	ax,ds:sprite_data_ptr
		mov	si,ax
		call	si_wrap_hi
		mov	di,sprite_pos
		push	cs
		pop	es
		mov	cx,3

sprite_ptr_copy_loop:
					movsw				; Mov [si] to es:[di]
					movsb				; Mov [si] to es:[di]
					add	si,21h
					call	si_wrap_hi
					loop	sprite_ptr_copy_loop		; Loop if cx > 0

		retn

frame_row_driver		proc	near
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:scroll_active,0FFh
		jnz	scroll_step_update			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_163		; Jump if not equal
		call	bg_tile_restore_3x3

loc_ret_163:
		retn

scroll_step_update:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_165			; Jump if above or =
		retn

loc_165:
		jnz	loc_166			; Jump if not zero
		call	scroll_restore
		jmp	bg_tile_restore_entry

loc_166:
		add	al,0Ah
		cmp	al,cl
		je	loc_167			; Jump if equal
		retn

loc_167:
		jmp	bg_restore_entry

; scroll_do_advance -- advance scrolling animation state machine.
; Called from frame_row_driver when scroll phase matches.

scroll_do_advance:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_168			; Jump if not zero
		retn

loc_168:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:game_seg
		inc	byte ptr ds:scroll_step
		mov	al,ds:scroll_phase
		or	al,al			; Zero ?
		jz	loc_172			; Jump if zero
		dec	al
		jz	loc_170			; Jump if zero
		cmp	byte ptr ds:scroll_step,5
		jb	loc_169			; Jump if below
		jmp	loc_176

loc_169:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:scroll_delta,0FF01h
		mov	dx,13Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_174			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:scroll_delta,1
		mov	dx,140h
		jmp	short loc_174

loc_170:
		cmp	byte ptr ds:scroll_step,5
		jb	loc_171			; Jump if below
		jmp	loc_176

loc_171:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_173			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_173

loc_172:
		cmp	byte ptr ds:scroll_step,7
		jae	loc_176			; Jump if above or =
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_173			; Jump if not zero
		mov	di,cga_plane_alt
		mov	si,0B01Eh

loc_173:
		mov	bx,es:[bx+di]
		mov	ds:scroll_delta,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,140h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	dx,ax

loc_174:
		mov	di,ds:scroll_vga_ofs
		add	di,dx
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_175			; Jump if zero
		add	di,140h

loc_175:
		mov	ds:scroll_src_ofs,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:scroll_gfx_ptr,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	bg_restore_entry

loc_176:
		mov	byte ptr ds:scroll_active,0
		mov	byte ptr ds:scroll_step,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

frame_row_driver		endp

scroll_restore		proc	near
		test	byte ptr ds:restore_pending,0FFh
		jnz	loc_177			; Jump if not zero
		retn

loc_177:
		push	es
		push	di
		push	si
		push	bx
		call	bg_restore
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:restore_pending,0
		retn

scroll_restore		endp

bg_save		proc	near
		push	ds
		push	cs
		pop	es
		mov	si,cs:scroll_src_ofs
		mov	ax,0B800h
		mov	ds,ax
		mov	di,cache_tbl_b
		mov	cx,20h

bg_save_loop:
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					add	si,1FF8h
					cmp	si,4000h
					jb	loc_179			; Jump if below
					add	si,0C050h

loc_179:
					loop	bg_save_loop		; Loop if cx > 0

		pop	ds
		retn

bg_save		endp

bg_restore		proc	near
		mov	di,cs:scroll_src_ofs
		mov	ax,0B800h
		mov	es,ax
		mov	si,cache_tbl_b
		mov	cx,20h

bg_restore_loop:
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					movsw				; Mov [si] to es:[di]
					add	di,1FF8h
					cmp	di,4000h
					jb	loc_181			; Jump if below
					add	di,0C050h

loc_181:
					loop	bg_restore_loop		; Loop if cx > 0

		retn

bg_restore		endp

scroll_pos_load		proc	near
		mov	al,byte ptr ds:[84h]
		add	al,ds:scroll_delta
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:scroll_delta+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:sprite_data_ptr
		call	si_wrap_hi
		mov	cx,4

scroll_pos_outer:
					push	cx
					mov	cx,4

scroll_pos_inner:
								push	cx
								mov	bl,[si]
								inc	si
								and	bl,7Fh
								xor	bh,bh			; Zero register
								add	bx,bx
								mov	word ptr ds:sprite_cache_tbl[bx],0
								pop	cx
								loop	scroll_pos_inner		; Loop if cx > 0

					add	si,20h
					call	si_wrap_hi
					pop	cx
					loop	scroll_pos_outer		; Loop if cx > 0

		retn

bg_restore_entry:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_185			; Jump if not zero
		retn

loc_185:
		mov	byte ptr ds:restore_pending,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	scroll_pos_load
		call	bg_save
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:scroll_src_ofs
		mov	si,cs:scroll_gfx_ptr
		mov	cx,4

scroll_blit_outer:
					push	cx
					push	di
					mov	cx,4

scroll_blit_mid:
								push	cx
								lodsb				; String [si] to al
								cmp	al,0FFh
								jne	loc_188			; Jump if not equal
								add	di,140h
								jmp	short loc_191

loc_188:
								push	si
								xor	ah,ah			; Zero register
								add	ax,ax
								add	ax,ax
								add	ax,ax
								add	ax,ax
								mov	si,ax
								add	si,ds:cga_sprite_src
								mov	cx,8

scroll_blit_inner:
								push	cx
								lodsw				; String [si] to ax
								call	cga_plane_mask_2bit
								or	es:[di],ax
								add	di,2000h
								cmp	di,4000h
								jb	loc_190			; Jump if below
								add	di,vga_wrap_adj

loc_190:
								pop	cx
								loop	scroll_blit_inner		; Loop if cx > 0

								pop	si

loc_191:
								pop	cx
								loop	scroll_blit_mid		; Loop if cx > 0

					pop	di
					inc	di
					inc	di
					pop	cx
					loop	scroll_blit_outer		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
; bg_tile_addr_calc -- alternate entry computing VGA address from BL/BH coords,
; then falls through to bg_tile_blit_3x3. Reached via external dispatch call.

bg_tile_addr_calc:
		shr	bl,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		add	di,ax
		mov	ds:scroll_vga_ofs,di
		jmp	short bg_tile_blit_3x3

scroll_pos_load		endp

bg_tile_restore_3x3		proc	near

bg_tile_restore_entry:
		test	byte ptr ds:redraw_lock,0FFh
		jz	bg_tile_restore_do			; Jump if zero
		retn

bg_tile_restore_do:
		mov	byte ptr ds:redraw_lock,0FFh

bg_tile_blit_3x3:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,cache_tbl_c
		mov	di,cs:scroll_vga_ofs
		mov	cx,3

tile_3x3_row_loop:
					push	cx
					mov	cx,3

tile_3x3_col_loop:
								push	cx
								push	di
								call	cga_blit_2rows_stride
								pop	di
								inc	di
								inc	di
								pop	cx
								loop	tile_3x3_col_loop		; Loop if cx > 0

					add	di,13Ah
					pop	cx
					loop	tile_3x3_row_loop		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn

bg_tile_restore_3x3		endp

; sprite_expand_blit -- loads sprite graphics from game_seg, expands each 3-color
; bitpair into a 3+1 mask and ORs into CGA framebuffer at [di] with stride 0x2000.

sprite_expand_blit:
		push	ds
		push	si
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

anim_render_row:
					push	cx
					lodsw				; String [si] to ax
					mov	bx,ax
					mov	dx,3
					mov	cx,8

anim_render_bits:
								test	bx,dx
								jz	loc_199			; Jump if zero
								or	bx,dx

loc_199:
								add	dx,dx
								add	dx,dx
								loop	anim_render_bits		; Loop if cx > 0

					not	bx
					and	es:[di],bx
					or	es:[di],ax
					add	di,2000h
					cmp	di,4000h
					jb	loc_200			; Jump if below
					add	di,0C050h

loc_200:
					pop	cx
					loop	anim_render_row		; Loop if cx > 0

		pop	si
		pop	ds
		retn
; anim_refresh_all -- full 8-pass animation refresh loop over 18 rows ?? 28 cols
; of sprite_data_ptr data, calling bg_col_blit_row per cell.

anim_refresh_all:
		mov	byte ptr ds:restore_pending,0
		mov	ax,0B800h
		mov	es,ax
		mov	byte ptr ds:anim_phase,8

anim_refresh_pass:
					mov	word ptr ds:vga_row_ptr,23Ch
					mov	byte ptr ds:gvar_frame_timer,0
					mov	si,ds:sprite_data_ptr
					mov	di,sprite_buf
					mov	cx,12h

anim_refresh_row_loop:
								push	cx
								add	si,4
								xor	bx,bx			; Zero register
								mov	cx,1Ch

anim_refresh_col_loop:
								push	cx
								lodsb				; String [si] to al
								call	bg_col_blit_row
								inc	di
								inc	bl
								pop	cx
								loop	anim_refresh_col_loop		; Loop if cx > 0

								add	si,4
								call	si_wrap_hi
								add	word ptr ds:vga_row_ptr,140h
								pop	cx
								loop	anim_refresh_row_loop		; Loop if cx > 0

loc_204:
								cmp	byte ptr ds:gvar_frame_timer,10h
								jb	loc_204			; Jump if below
					dec	byte ptr ds:anim_phase
					jnz	anim_refresh_pass			; Jump if not zero
		retn

bg_col_blit_row		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_205			; Jump if not equal
		retn

loc_205:
		cmp	byte ptr [di],0FCh
		jne	loc_206			; Jump if not equal
		retn

loc_206:
		push	ds
		push	di
		push	si
		push	bx
		push	ax
		mov	ah,ds:anim_phase
		dec	ah
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sbb	ah,ah
		xor	ah,0CCh
		mov	cs:shift_count,ah
		add	bx,bx
		add	bx,ds:vga_row_ptr
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_208			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		push	si
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	row_ofs_advance
		call	col_write_inner
		pop	di
		pop	si
		mov	al,cs:anim_phase
		call	row_ofs_advance
		inc	di
		inc	si
		call	col_write_inner
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

bg_col_blit_row		endp

col_write_inner		proc	near
		mov	cx,2

col_write_inner_loop:
					mov	bl,cs:shift_count
					lodsb				; String [si] to al
					and	al,bl
					not	bl
					and	es:[di],bl
					or	es:[di],al
					add	di,0A0h
					add	si,7
					loop	col_write_inner_loop		; Loop if cx > 0

		retn

loc_208:
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	row_ofs_advance
		call	cga_clear_2rows
		pop	di
		mov	al,cs:anim_phase
		call	row_ofs_advance
		inc	di
		call	cga_clear_2rows
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

col_write_inner		endp

cga_clear_2rows		proc	near
		mov	al,cs:shift_count
		not	al
		and	es:[di],al
		add	di,cga_col_stride
		and	es:[di],al
		retn

cga_clear_2rows		endp

row_ofs_advance		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		add	ax,ax
		add	si,ax
		pop	ax
		or	ax,ax			; Zero ?
		jnz	loc_209			; Jump if not zero
		retn

loc_209:
					add	di,2000h
					cmp	di,4000h
					jb	loc_210			; Jump if below
					add	di,0C050h

loc_210:
					dec	ax
					jnz	loc_209			; Jump if not zero
		retn

row_ofs_advance		endp

; cga_color_fade_init -- CGA-parallel of EGA color_fade_init.
; Reads X/Y coords from DS:[0x83]/[0x84], multiplies by 8 to get palette offsets,
; stores to cur_color_pair, clears HUD, then calls cga_inner_fade with
; anim_phase=0xAA (first pass, or-in) and 0x00 (second pass, xor), finally
; falls back to hud_clear_entry for final clear.

cga_color_fade_init:
		mov	al,byte ptr ds:[83h]
		add	al,al			; X * 2
		add	al,al			; X * 4
		add	al,al			; X * 8
		mov	ah,byte ptr ds:[84h]
		add	ah,ah			; Y * 2
		add	ah,ah			; Y * 4
		add	ah,ah			; Y * 8
		mov	ds:cur_color_pair,al
		mov	byte ptr ds:cur_color_pair+1,ah
		call	hud_clear
		mov	byte ptr ds:anim_phase,0AAh
		call	cga_inner_fade
		mov	byte ptr ds:anim_phase,0
		call	cga_inner_fade
		jmp	hud_clear_entry

cga_inner_fade		proc	near
		mov	al,ds:cur_color_pair
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,byte ptr ds:cur_color_pair+1
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	fade_gradient_loop
		mov	al,ds:cur_color_pair
		sub	al,5
		mov	bl,al
		add	al,21h			; '!'
		mov	dl,al
		mov	al,byte ptr ds:cur_color_pair+1
		sub	al,5
		mov	bh,al
		add	al,21h			; '!'
		mov	dh,al
		call	fade_gradient_loop
		mov	al,ds:cur_color_pair
		sub	al,9
		mov	bl,al
		add	al,29h			; ')'
		mov	dl,al
		mov	al,byte ptr ds:cur_color_pair+1
		sub	al,9
		mov	bh,al
		add	al,29h			; ')'
		mov	dh,al

fade_gradient_loop:
		mov	cx,9

fade_pass_loop:
					push	cx
					push	dx
					push	bx
					call	cga_fade_blit
					pop	bx
					pop	dx
					sub	bl,0Ch
					jnc	fade_bl_clamp			; Jump if carry=0
					xor	bl,bl			; Zero register

fade_bl_clamp:
					sub	bh,0Ch
					jnc	fade_bh_clamp			; Jump if carry=0
					xor	bh,bh			; Zero register

fade_bh_clamp:
					add	dl,0Ch
					jnc	fade_dl_clamp			; Jump if carry=0
					mov	dl,0FFh

fade_dl_clamp:
					add	dh,0Ch
					jnc	fade_dh_clamp			; Jump if carry=0
					mov	dh,0FFh

fade_dh_clamp:
					push	dx
					push	bx
					call	frame_wait_loop
					pop	bx
					pop	dx
					pop	cx
					loop	fade_pass_loop		; Loop if cx > 0

		retn

cga_inner_fade		endp

cga_fade_blit		proc	near
		mov	ax,0B800h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	cga_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	cga_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	cga_fill_bit_range
		pop	bx
		pop	dx
		mov	bl,dl

cga_fill_bit_range:
		cmp	dh,bh
		jae	loc_216			; Jump if above or =
		xchg	dx,bx

loc_216:
		or	bl,bl			; Zero ?
		jnz	loc_217			; Jump if not zero
		retn

loc_217:
		cmp	bl,0DFh
		jb	loc_218			; Jump if below
		retn

loc_218:
		or	bh,bh			; Zero ?
		jnz	loc_219			; Jump if not zero
		mov	bh,1

loc_219:
		cmp	dh,8Fh
		jb	loc_220			; Jump if below
		mov	dh,8Eh

loc_220:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	cga_row_addr_calc
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_223			; Jump if zero
		cmp	bl,2
		jb	loc_222			; Jump if below
		jz	loc_221			; Jump if zero
		mov	ah,3
		jmp	short loc_224

loc_221:
		mov	ah,0Ch
		jmp	short loc_224

loc_222:
		mov	ah,30h			; '0'
		jmp	short loc_224

loc_223:
		mov	ah,0C0h

loc_224:
		mov	al,ah
		not	al
		and	ah,ds:anim_phase

fade_bit_fill_loop:
					and	es:[di],al
					or	es:[di],ah
					add	di,2000h
					cmp	di,4000h
					jb	loc_226			; Jump if below
					add	di,0C050h

loc_226:
					loop	fade_bit_fill_loop		; Loop if cx > 0

		retn

cga_fade_blit		endp

cga_fill_bit_range_wide		proc	near
		cmp	dl,bl
		jae	loc_227			; Jump if above or =
		xchg	dx,bx

loc_227:
		or	bh,bh			; Zero ?
		jnz	loc_228			; Jump if not zero
		retn

loc_228:
		cmp	bh,8Fh
		jb	loc_229			; Jump if below
		retn

loc_229:
		or	bl,bl			; Zero ?
		jnz	loc_230			; Jump if not zero
		mov	bl,1

loc_230:
		cmp	dl,0DFh
		jb	loc_231			; Jump if below
		mov	dl,0DEh

loc_231:
		mov	al,bh
		call	cga_row_addr_calc
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_234			; Jump if zero
		cmp	bl,2
		jb	loc_233			; Jump if below
		jz	loc_232			; Jump if zero
		mov	al,3
		jmp	short loc_235

loc_232:
		mov	al,0Fh
		jmp	short loc_235

loc_233:
		mov	al,3Fh			; '?'
		jmp	short loc_235

loc_234:
		mov	al,0FFh

loc_235:
		and	dl,3
		jz	loc_238			; Jump if zero
		cmp	dl,2
		jb	loc_237			; Jump if below
		jz	loc_236			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_239

loc_236:
		mov	ah,0FCh
		jmp	short loc_239

loc_237:
		mov	ah,0F0h
		jmp	short loc_239

loc_238:
		mov	ah,0C0h

loc_239:
		jcxz	loc_241			; Jump if cx=0
		dec	cx
		jcxz	loc_240			; Jump if cx=0
		mov	dh,al
		not	dh
		and	al,ds:anim_phase
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	al,0FFh
		and	al,ds:anim_phase
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	dh,ah
		not	dh
		and	ah,ds:anim_phase
		and	es:[di],dh
		or	es:[di],ah
		retn

loc_240:
		mov	dh,al
		not	dh
		and	al,ds:anim_phase
		and	es:[di],dh
		or	es:[di],al
		inc	di
		mov	dh,ah
		not	dh
		and	ah,ds:anim_phase
		and	es:[di],dh
		or	es:[di],ah
		retn

loc_241:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:anim_phase
		and	es:[di],dh
		or	es:[di],al
		retn

cga_fill_bit_range_wide		endp

cga_row_addr_calc		proc	near
		shr	al,1			; Shift w/zeros fill
		sbb	di,di
		and	di,2000h
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		add	ax,23Ch
		add	di,ax
		retn

cga_row_addr_calc		endp

frame_wait_loop		proc	near
		mov	cl,ds:anim_speed
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al

frame_wait_poll:
					push	ax
					call	word ptr cs:[110h]
					call	word ptr cs:[112h]
					call	word ptr cs:[114h]
					call	word ptr cs:[116h]
					call	word ptr cs:[118h]
					pop	ax
					cmp	ds:gvar_frame_timer,al
					jb	frame_wait_poll			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

frame_wait_loop		endp

hud_clear		proc	near

hud_clear_entry:
		mov	ax,0B800h
		mov	es,ax
		mov	di,hud_ofs
		mov	cx,8

hud_clear_outer:
					push	cx
					push	di
					mov	cx,12h

hud_clear_mid:
								push	cx
								push	di
								mov	ax,0FFFFh
								mov	cx,1Ch

hud_clear_inner:
								xor	es:[di],ax
								inc	di
								inc	di
								loop	hud_clear_inner		; Loop if cx > 0

								pop	di
								add	di,140h
								pop	cx
								loop	hud_clear_mid		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	loc_247			; Jump if below
					add	di,0C050h

loc_247:
					pop	cx
					loop	hud_clear_outer		; Loop if cx > 0

		retn

hud_clear		endp

; cga_row_col_addr -- compute CGA row/col address from AL (col, low 6 bits), AH (row).
; Returns DI = row*0x140 + (col-4)*2 + 0x23C (CGA framebuffer offset).

cga_row_col_addr:
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,140h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,23Ch
		retn

; hero_cache_copy -- copy hero cached sprite data from driver CS+2000h to game_seg:bg_save_buf_b.
; Tier from ds:[9Dh] (0=skip, 7=skip); else dec?->index into word table at [bx], copy 0x480 bytes.

hero_cache_copy:
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_248			; Jump if zero
		cmp	bl,7
		je	loc_248			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:game_seg
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,bg_save_buf_b
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

loc_248:
		mov	ds,cs:game_seg
		mov	si,8690h
		retn

si_wrap_hi		proc	near
		cmp	si,0E900h
		jae	loc_249			; Jump if above or =
		retn

loc_249:
		sub	si,900h
		retn

si_wrap_hi		endp

; si_wrap_lo -- wrap SI back up if it underflows sprite_buf range.
; Called from cga_row_ofs (gfcga_main init block) when si is below 0xE000.

si_wrap_lo:
		cmp	si,0E000h
		jb	loc_250			; Jump if below
		retn

loc_250:
		add	si,900h
		retn

; hud_color_map -- copy/mask the sprite_tmp_buf data through 8 CGA plane rows
; to VGA offset 0x64C. Used for HUD area color map rendering.

hud_color_map:
		push	si
		push	ds
		mov	si,sprite_tmp_buf
		mov	di,64Ch
		mov	ax,0B800h
		mov	es,ax
		mov	cx,5

color_map_row_loop:
					push	cx
					mov	cx,1Ch

color_map_col_loop:
								push	cx
								lodsb				; String [si] to al
								push	ds
								push	si
								mov	ds,cs:game_seg
								xor	ah,ah			; Zero register
								add	ax,ax
								add	ax,ax
								add	ax,ax
								add	ax,ax
								add	ax,4000h
								mov	si,ax
								push	di
								mov	cx,8

color_map_plane_loop:
								push	cx
								lodsw				; String [si] to ax
								not	ax
								call	cga_plane_mask_2bit
								not	ax
								and	ax,0AAAAh
								stosw				; Store ax to es:[di]
								add	di,1FFEh
								cmp	di,4000h
								jb	loc_254			; Jump if below
								add	di,0C050h

loc_254:
								pop	cx
								loop	color_map_plane_loop		; Loop if cx > 0

								pop	di
								inc	di
								inc	di
								pop	si
								pop	ds
								pop	cx
								loop	color_map_col_loop		; Loop if cx > 0

					add	di,108h
					pop	cx
					loop	color_map_row_loop		; Loop if cx > 0

		pop	ds
		pop	si
		retn
; --- gf_cga_phase_idx_tbl: animation phase index table (4 sets of ~28 entries each) ---
gf_cga_phase_idx_tbl:
		db	 00h, 01h, 02h, 04h, 07h, 09h			; set 0 row 0: phase indices 0..5
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch			; set 0 row 1: phase indices 6..11
		db	 1Eh, 04h, 07h, 09h, 22h, 02h			; set 0 row 2: phase indices 12..17
		db	 25h, 08h, 02h, 28h, 02h, 2Dh			; set 0 row 3: phase indices 18..23
		db	 31h, 36h, 3Bh, 40h, 00h, 01h			; set 0 row 4 + start of set 1
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h			; set 1 row 0: phase indices 2..7
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h			; set 1 row 1: phase indices 8..13
		db	8, 0Ah, '#$'			; set 1 row 2 (chars '#$' = 0x23 0x24 mid-row)
		db	'&', 8, 27h, ')*'			; set 1 row 3 (chars '&...)*' frame chars)
		db	 04h, 32h, 37h, 3Ch, 06h, 00h			; set 1 row 4 + start of set 2
		db	 01h, 02h, 05h, 08h, 02h, 0Eh			; set 2 row 0: phase indices 1..6
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh			; set 2 row 1: phase indices 7..12
		db	 04h, 08h, 02h, 23h, 24h, 26h			; set 2 row 2: phase indices 13..18
		db	 08h, 25h, 29h, 02h, 2Eh, 33h			; set 2 row 3: phase indices 19..24
		db	 38h, 3Dh, 06h, 00h, 01h, 03h			; set 2 row 4 + start of set 3
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h			; set 3 row 0: phase indices 2..7
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h			; set 3 row 1: phase indices 8..13
		db	 0Bh			; set 3 row 2 (1 byte)
		db	'#$'			; set 3 row 2 (chars '#$' = indices 0x23,0x24)
		db	'&', 8, 27h, ')+/49>'			; set 3 row 3: indices 0x26,0x08,0x27,0x29,0x2B,0x2F,0x34,0x39,0x3E
		db	 06h, 00h, 01h, 02h, 04h, 08h			; set 3 row 4 + start of set 4
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh			; set 4 row 0: phase indices 2..7
		db	 1Dh			; set 4 row 1 (1 byte)
		db	' !', 8, 0Ch, '#$'			; set 4 row 1 cont (chars ' !.#$' = indices 0x20,0x21,0x08,0x0C,0x23,0x24)
		db	'&', 8			; set 4 row 2 (chars '&.' = indices 0x26,0x08)
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah			; set 4 row 3: phase indices 14..19
		db	 3Fh, 06h			; set 4 row 4 (terminator pair 0x3F,0x06)

cga_plane_mask_2bit		proc	near
		mov	dx,ax
		xor	ax,ax			; Zero register
		mov	cx,8

nibble_mask_expand_loop:
					xor	bl,bl			; Zero register
					add	dx,dx
					adc	bl,bl
					add	dx,dx
					adc	bl,bl
					jz	loc_256			; Jump if zero
					mov	bl,3

loc_256:
					add	ax,ax
					add	ax,ax
					or	al,bl
					loop	nibble_mask_expand_loop		; Loop if cx > 0

		retn

cga_plane_mask_2bit		endp

; bg_tile_blit_init -- setup for bg_tile_row_loop: set anim_phase from AL,
; point SI at phase_offset_tbl, reset vga_row_ptr to hud_ofs, CX=18 rows.

bg_tile_blit_init:
		mov	ds:anim_phase,al
		mov	si,phase_offset_tbl
		mov	word ptr ds:vga_row_ptr,23Ch
		mov	cx,12h

bg_tile_row_loop:
					push	cx
					mov	cx,1Ch

bg_tile_col_loop:
								push	cx
								lodsb				; String [si] to al
								push	si
								call	bg_tile_blit_inner
								pop	si
								add	word ptr ds:vga_row_ptr,2
								pop	cx
								loop	bg_tile_col_loop		; Loop if cx > 0

					add	word ptr ds:vga_row_ptr,108h
					pop	cx
					loop	bg_tile_row_loop		; Loop if cx > 0

		retn

bg_tile_blit_inner		proc	near
		push	ds
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:vga_row_ptr
		mov	cx,8

bg_plane_copy_loop:
					push	cx
					lodsw				; String [si] to ax
					call	cga_plane_mask_combine
					stosw				; Store ax to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	loc_260			; Jump if below
					add	di,0C050h

loc_260:
					pop	cx
					loop	bg_plane_copy_loop		; Loop if cx > 0

		pop	ds
		retn

bg_tile_blit_inner		endp

cga_plane_mask_combine		proc	near
		mov	cx,8

plane_combine_loop:
					push	cx
					add	ax,ax
					adc	cl,cl
					add	ax,ax
					adc	cl,cl
					and	cl,3
					mov	bl,cs:anim_phase
					xor	bh,bh			; Zero register
					add	bx,bx
					call	word ptr cs:color_map_tbl[bx]	;*
					add	dx,dx
					add	dx,dx
					or	dl,cl
					pop	cx
					loop	plane_combine_loop		; Loop if cx > 0

		mov	ax,dx
		retn

cga_plane_mask_combine		endp

; color_map_tbl dispatch entry bytes (11 bytes) -- word-indexed pointers for the
; animation plane-pair mapping, reached via call word ptr cs:color_map_tbl[bx].
; Sourcer mis-decodes as add/inc/movsb etc. ?-- they are actually jump-pad pointer
; bytes / fallthrough prelude for color_map handlers that follow.

color_map_prolog:
		db	 81h, 47h, 82h, 47h, 93h	; pointer table bytes 0..4
		db	 47h,0A4h, 47h,0B5h, 47h	; pointer table bytes 5..9
		db	0C3h				; pointer table byte 10 (fall-through retn for null handler)

; color_map_01_2 -- swap color 1 <-> 2 (no-op for other values).

color_map_01_2:
		cmp	cl,1
		jne	loc_262			; Jump if not equal
		mov	cl,2
		retn

loc_262:
		cmp	cl,2
		je	loc_263			; Jump if equal
		retn

loc_263:
		mov	cl,1
		retn

; color_map_01_0 -- swap 1?->0, 2?->1 mapping.

color_map_01_0:
		cmp	cl,1
		jne	loc_264			; Jump if not equal
		mov	cl,0
		retn

loc_264:
		cmp	cl,2
		je	loc_265			; Jump if equal
		retn

loc_265:
		mov	cl,1
		retn

; color_map_23_map -- swap 2?->3, 3?->2 mapping.

color_map_23_map:
		cmp	cl,2
		jne	loc_266			; Jump if not equal
		mov	cl,3
		retn

loc_266:
		cmp	cl,3
		je	loc_267			; Jump if equal
		retn

loc_267:
		mov	cl,2
		retn

; color_map_1_3 -- map 1?->3 only (other values unchanged).

color_map_1_3:
		cmp	cl,1
		je	loc_268			; Jump if equal
		retn

loc_268:
		mov	cl,3
		retn
; anim_seq_tbl -- frame index pairs / sprite animation cycle data.
; Sourcer mis-decodes these bytes as code; they are data accessed via CS-relative pointer.

anim_seq_tbl:					; data at CS:17C2h
		db	 07h, 08h, 09h, 0Ah, 07h, 08h	; anim frame index pairs
		db	 0Bh, 0Ch, 07h, 08h, 09h, 0Ah	;  (cont.)
		db	 19h, 3Dh, 61h, 27h, 1Dh, 1Eh	;  (cont.)
		db	 1Dh, 1Eh, 1Fh, 20h, 1Fh, 20h	;  (cont.)
		db	 1Dh, 1Eh, 1Fh, 20h, 0Dh, 0Eh	;  (cont.)
		db	 0Fh, 10h, 0Fh, 10h, 0Dh, 0Eh	;  (cont.)
		db	 0Fh, 10h, 17h, 18h, 3Eh, 5Ch	;  (cont.)
		db	 62h, 26h, 2Ah, 25h, 21h, 22h	;  (cont.)
		db	 21h, 22h, 23h, 24h, 21h, 22h	;  (cont.)
		db	 21h, 22h, 09h, 0Ah, 07h, 08h	;  (cont.)
		db	 07h, 08h, 09h, 0Ah, 07h, 08h	;  (cont.)
		db	 19h, 54h, 59h, 5Dh			;  (cont.)
		db	 63h, 32h, 2Fh, 2Eh, 1Fh, 20h			; row 12: anim frame indices
		db	 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h			; row 13: anim frame indices
		db	 1Fh, 20h, 0Fh, 10h, 11h, 12h			; row 14: anim frame indices
		db	 0Fh, 10h, 0Dh, 0Eh, 17h, 18h			; row 15: anim frame indices
		db	'PUZ^df(0#$'			; row 16: ASCII frame indices (Sourcer mixed encoding)
		db	'!"#$'			; row 17: ASCII frame indices
		db	'!"#$'			; row 18: ASCII frame indices
		db	 07h, 08h, 0Ah, 0Ch, 07h, 08h			; row 19: anim frame indices
		db	 09h, 0Ah, 1Ah			; row 20: 3-byte partial
		db	'4QV[_eg/-'			; row 21: ASCII frame indices
		db	 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh			; row 22: anim frame indices
		db	 1Fh, 20h, 1Dh, 1Eh, 0Fh, 10h			; row 23: anim frame indices
		db	 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h			; row 24: anim frame indices
		db	 49h, 4Dh, 52h, 57h, 00h			; row 25: 5-byte partial + zero terminator
		db	'`ihjk(&!"+&!"!"'			; row 26: ASCII frame indices (15 bytes)
		db	7			; row 27: 1-byte
		db	8, 9, 0Ah, 9, 0Ah, 1Bh, 'FJNSX'			; row 28: anim indices + ASCII
		db	 00h, 00h, 00h, 00h, 69h, 6Ch			; row 29: 4 zeros + 0x69,0x6C
		db	 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh			; row 30: anim frame indices
		db	 1Fh, 20h, 1Fh, 20h, 13h, 14h			; row 31: anim frame indices
		db	 13h, 14h, 17h, 18h			; row 32: 4-byte partial
		db	 43h, 47h, 4Bh, 4Fh			; row 33: 4-byte partial
		db	7 dup (0)			; row 34: 7-byte zero pad
		db	'mno)&!"*%!"'			; row 35: ASCII frame indices (11 bytes)
		db	 15h, 16h, 15h, 16h, 1Ch			; row 36: 5-byte partial
		db	 35h, 44h, 48h, 4Ch			; row 37: 4-byte partial
		; Character encoding / font lookup table
		db	'CGKO', 0		; 0x0000
		db	'mno)&!"*%!"', 0		; 0x000B
		db	016h, 015h, 016h, 01Ch		; 0x0017
		db	'5DHL', 0		; 0x001B
		db	'iqst', 0		; 0x0028
		db	' ,\'', 0		; 0x002D
		db	' ', 0		; 0x0031
		db	018h		; 0x0033
		db	'8:?BE', 0		; 0x0034
		db	'muwyo+&)&', 0		; 0x0045
		db	 01h, 02h, 01h, 02h, 01h, 02h			; tile pair lookup row 0: (1,2) x3
		db	 01h, 02h, 01h, 02h, 01h, 02h			; tile pair lookup row 1: (1,2) x3
		db	 01h, 02h, 01h, 02h, 01h, 02h			; tile pair lookup row 2: (1,2) x3
		; Character encoding table (continued)
		db	'49;@A', 0		; 0x0000
		db	'vxz{12', 0		; 0x0013
		; Character encoding table (continued)
		db	'/-367<', 0		; 0x0000
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 0: (3,4) x3
		db	 03h, 04h, 05h, 06h, 05h, 06h			; tile pair lookup row 1: (3,4)+(5,6) x2
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 2: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 3: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 4: (5,6) x3
		db	 06h, 05h, 05h, 06h, 05h, 06h			; tile pair lookup row 5: swapped + (5,6) x2
; --- trailing CGA blit code stub disassembled as data (Sourcer mis-decoded) ---
		db	 1Eh, 50h,0D0h,0EBh, 1Bh,0FFh			; code: push ds; push ax; shr bl,1; ...
		db	 81h,0E7h, 00h, 20h,0B0h, 50h			; code: and di,2000h; mov al,50h
		db	0F6h,0E3h, 8Ah,0DFh, 32h,0FFh			; code: mul bl; mov bl,bh; xor bh,bh
		db	 03h,0C3h, 03h,0F8h, 58h,0B1h			; code: add ax,bx; add di,ax; pop ax; mov cl
		db	 10h,0F6h,0E1h, 05h, 00h, 60h			; code: cl=10h; mul cl; add ax,6000h
		db	 8Bh,0F0h, 2Eh, 8Eh, 1Eh, 2Ch			; code: mov si,ax; mov ds,cs:[2Ch]
		db	0FFh,0B8h, 00h,0B8h, 8Eh,0C0h			; code: ...mov ax,0B800h; mov es,ax
		db	0B9h, 04h, 00h			; code: mov cx,4 immediate

bg_plane_2row_loop:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	loc_270			; Jump if below
					add	di,vga_wrap_adj

loc_270:
					movsw				; Mov [si] to es:[di]
					add	di,1FFEh
					cmp	di,4000h
					jb	loc_271			; Jump if below
					add	di,0C050h

loc_271:
					loop	bg_plane_2row_loop		; Loop if cx > 0

		pop	ds
		retn
; hero_sprite_col_blit -- blit 24 rows of hero sprite column from game_seg bg_tile_src
; indexed by [92h]-1 to CGA framebuffer at ui_ofs.

hero_sprite_col_blit:
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:bg_tile_src[bx]
		mov	di,ui_ofs
		mov	ax,0B800h
		mov	es,ax
		mov	cx,18h

hero_col_blit_loop:
					lodsw				; String [si] to ax
					or	es:[di],ax
					lodsw				; String [si] to ax
					or	es:[di+2],ax
					add	di,2000h
					cmp	di,4000h
					jb	loc_273			; Jump if below
					add	di,vga_wrap_adj

loc_273:
					loop	hero_col_blit_loop		; Loop if cx > 0

		pop	ds
		retn
; Sprite bitmap header -- mis-decoded by Sourcer as inc si / dec dx / cmpsb / push es / dec bx.
; These 12 bytes are sprite frame metadata preceding the 45-byte zero pad.
		db	 46h, 4Ah, 46h, 4Ah, 46h, 4Ah	; 46 4A 46 4A 46 4A (mis-decoded as inc si/dec dx x3)
		db	0A6h, 4Ah,0A6h, 4Ah, 06h, 4Bh	; A6 4A A6 4A 06 4B (cmpsb/dec dx/cmpsb/dec dx/push es/dec bx)
		db	45 dup (0)
; --- gf_cga_proj_sprite_a: small CGA projectile bitmap (column-major, 6B/row) ---
gf_cga_proj_sprite_a:
		db	 03h, 00h, 00h, 00h, 0Ch, 00h			; sprite a row 0
		db	 00h, 00h, 0Ch, 00h, 00h, 00h			; sprite a row 1
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h			; sprite a row 2
		db	 00h, 00h, 3Ch, 00h, 00h, 00h			; sprite a row 3
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h			; sprite a row 4
		db	 00h, 00h, 0Ch, 00h, 00h, 00h			; sprite a row 5
		db	 3Ch, 00h, 00h, 00h, 3Ch, 00h			; sprite a row 6
		db	 00h, 00h, 3Ch, 00h, 00h, 00h			; sprite a row 7
		db	 3Ch, 00h			; sprite a row 8 (2-byte partial)
		db	7 dup (0)			; pad before sprite b
; --- gf_cga_proj_sprite_b: medium CGA projectile bitmap ---
gf_cga_proj_sprite_b:
		db	 0Ch, 00h, 00h, 00h, 3Ch, 00h			; sprite b row 0
		db	 00h, 00h,0F0h, 00h, 00h, 00h			; sprite b row 1
		db	0F0h, 00h, 00h, 00h,0F0h, 00h			; sprite b row 2
		db	 00h, 03h,0F0h, 00h, 00h, 03h			; sprite b row 3
		db	0C0h, 00h, 00h, 03h,0C0h, 00h			; sprite b row 4
		db	 00h, 03h,0C0h, 00h, 00h, 0Fh			; sprite b row 5
		db	0C0h, 00h, 00h, 0Fh, 00h, 00h			; sprite b row 6
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite b row 7
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite b row 8
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite b row 9
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite b row 10
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite b row 11
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite b row 12
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite b row 13
		db	 00h, 00h, 00h			; sprite b row 14 (3-byte partial)
		db	3Fh			; sprite b terminator/marker byte
		db	12 dup (0)			; pad before sprite c
; --- gf_cga_proj_sprite_c: large CGA projectile bitmap (longer trail) ---
gf_cga_proj_sprite_c:
		db	0C0h, 00h, 00h, 00h,0C0h, 00h			; sprite c row 0
		db	 00h, 00h,0C0h, 00h, 00h, 03h			; sprite c row 1
		db	0C0h, 00h, 00h, 03h,0C0h, 00h			; sprite c row 2
		db	 00h, 0Fh,0C0h, 00h, 00h, 0Fh			; sprite c row 3
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite c row 4
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite c row 5
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite c row 6
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite c row 7
		db	 00h, 00h, 00h, 3Fh, 00h, 00h			; sprite c row 8
		db	 00h, 3Fh, 00h, 00h, 00h, 3Fh			; sprite c row 9
		db	 00h, 00h, 00h, 3Fh, 00h, 00h			; sprite c row 10
		db	 00h, 3Fh, 00h, 00h, 00h, 3Fh			; sprite c row 11
		db	 00h, 00h, 00h, 3Ch, 00h, 00h			; sprite c row 12
		db	 03h, 3Ch,0C0h, 00h, 00h,0FFh			; sprite c row 13 (last data row)
; --- trailing CGA blit code stub (Sourcer mis-decoded as data) ---
		db	 00h, 00h, 1Eh, 0Ah,0C0h, 78h			; code: push ds; or al,c0h; js short
		db	 10h, 24h, 03h,0B2h, 40h,0F6h			; code: adc; and al,3; mov dl,40h
		db	0E2h, 05h,0F5h, 4Bh, 8Bh,0F0h			; code: mul dl; add ax; cmc; dec bx; mov si,ax
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h			; code: mov bp,1; jmp short +0Eh
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h			; code: ...mov ah,al; xor al,al; add ax
		db	0F5h, 4Ch, 8Bh,0F0h,0BDh, 04h			; code: cmc; dec sp; mov si,ax; mov bp,4
		db	 00h, 8Ah,0C3h, 24h, 03h, 02h			; code: mov al,bl; and al,3; add al,...
		db	0C0h,0A2h, 81h, 50h,0D1h,0EBh			; code: ...mov ds:[5081h],al; shr bx,1
		db	0D1h,0EBh,0D0h,0E9h, 1Bh,0FFh			; code: shr bx,1; shr cl,1; sbb di,...
		db	 81h,0E7h, 00h, 20h,0B0h, 50h			; code: and di,2000h; mov al,50h
		db	0F6h,0E1h, 03h,0C3h, 03h,0F8h			; code: mul cl; add ax,bx; add di,ax
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 8Bh			; code: mov ax,B800h; mov es,ax; mov...
		db	0CDh			; code: ...cx (final byte before next routine)

shift_blit_outer:
					push	cx
					push	di
					mov	cx,10h

shift_blit_mid:
								push	cx
								push	di
								mov	cx,2

shift_blit_inner:
								push	cx
								lodsw				; String [si] to ax
								mov	bh,al
								xor	bl,bl			; Zero register
								mov	cl,cs:shift_count
								shr	bx,cl			; Shift w/zeros fill
								xor	al,al			; Zero register
								shr	ax,cl			; Shift w/zeros fill
								or	bl,ah
								mov	ah,al
								or	es:[di],bh
								inc	di
								or	es:[di],bl
								inc	di
								or	es:[di],ah
								pop	cx
								loop	shift_blit_inner		; Loop if cx > 0

								pop	di
								add	di,2000h
								cmp	di,4000h
								jb	loc_277			; Jump if below
								add	di,0C050h

loc_277:
								pop	cx
								loop	shift_blit_mid		; Loop if cx > 0

					pop	di
					add	di,4
					pop	cx
					loop	shift_blit_outer		; Loop if cx > 0

		pop	ds
		retn
		db	22 dup (0)
; --- gf_cga_tile_set: CGA tile/sprite frames (each ~5-9 rows of 6 bytes) ---
gf_cga_tile_set:
gf_cga_tile_00:
		db	 30h, 00h, 00h, 30h,0F0h, 00h			; tile 00 row 0
		db	 00h, 0Fh,0C0h, 00h, 00h, 0Fh			; tile 00 row 1
		db	0C0h, 00h, 00h, 0Fh,0C0h, 00h			; tile 00 row 2
		db	 00h, 0Ch, 30h, 00h, 00h, 30h			; tile 00 row 3
		db	 00h			; tile 00 row 4 (1 byte trail)
		db	26 dup (0)			; pad before tile 01
gf_cga_tile_01:
		db	 03h, 00h, 00h, 00h, 03h, 00h			; tile 01 row 0
		db	 00h, 00h,0C0h, 0Ch, 00h, 00h			; tile 01 row 1
		db	 03h, 00h, 00h, 00h, 1Bh, 30h			; tile 01 row 2
		db	 00h, 00h, 03h,0C0h, 00h, 0Ch			; tile 01 row 3
		db	0FFh,0FCh,0C0h, 00h, 03h,0C0h			; tile 01 row 4
		db	 00h, 00h, 33h, 30h, 00h, 00h			; tile 01 row 5
		db	 03h, 00h, 00h, 00h,0C0h, 0Ch			; tile 01 row 6
		db	 00h, 00h, 03h, 00h, 00h, 00h			; tile 01 row 7
		db	 03h			; tile 01 row 8 (1 byte trail)
		db	7 dup (0)			; pad before tile 02
gf_cga_tile_02:
		db	 03h, 00h, 00h, 00h, 03h, 00h			; tile 02 row 0
		db	 00h, 00h, 03h, 00h, 00h, 00h			; tile 02 row 1
		db	 0Ch,0C0h, 00h, 00h, 03h,0C0h			; tile 02 row 2
		db	 00h, 00h, 33h,0CCh, 00h, 00h			; tile 02 row 3
		db	 0Ch,0C0h, 00h, 00h, 33h,0CCh			; tile 02 row 4
		db	 00h,0CFh,0FFh,0FFh,0F3h, 00h			; tile 02 row 5 (center band)
		db	 33h,0CCh, 00h, 00h, 0Fh, 30h			; tile 02 row 6
		db	 00h, 00h, 33h, 0Ch, 00h, 00h			; tile 02 row 7
		db	 0Ch,0C0h, 00h, 00h, 03h, 00h			; tile 02 row 8
		db	 00h, 00h, 03h, 00h, 00h, 00h			; tile 02 row 9
		db	 03h, 00h			; tile 02 row 10 (2 byte trail)
		db	8 dup (0)			; pad before tile 03
gf_cga_tile_03:
		db	 30h, 30h, 00h, 00h, 00h, 0Ch			; tile 03 row 0
		db	 00h, 00h,0C0h, 00h,0C0h, 03h			; tile 03 row 1
		db	 00h, 00h,0F3h, 0Ch, 00h, 00h			; tile 03 row 2
		db	 3Fh, 3Ch, 00h, 00h, 0Fh,0F0h			; tile 03 row 3
		db	 00h, 00h, 3Fh,0F3h, 00h, 00h			; tile 03 row 4
		db	 0Fh,0F0h, 00h, 00h, 0Fh, 3Ch			; tile 03 row 5
		db	 00h, 00h, 33h, 0Ch, 00h, 00h			; tile 03 row 6
		db	0C3h, 03h,0C0h, 03h, 00h, 00h			; tile 03 row 7
		db	 30h, 0Ch, 00h, 00h, 0Ch, 30h			; tile 03 row 8
		db	 00h			; tile 03 row 9 (1 byte trail)
		db	34 dup (0)			; pad before tile 04
gf_cga_tile_04:
		db	0CFh,0FFh,0FFh,0FFh, 00h			; tile 04: solid horizontal bar (5 bytes)
		db	34 dup (0)			; pad before tile 05
gf_cga_tile_05:
		db	 03h, 00h, 00h, 00h, 03h, 00h			; tile 05 row 0
		db	 00h, 03h, 03h, 00h, 00h, 00h			; tile 05 row 1
		db	0C3h, 00h, 00h, 00h,0FFh, 00h			; tile 05 row 2
		db	 00h, 03h,0FFh, 0Ch,0CCh,0FFh			; tile 05 row 3
		db	0FFh,0FFh,0FFh,0FFh,0FFh, 0Ch			; tile 05 row 4 (full center)
		db	0CCh,0FFh,0FFh, 00h, 00h, 03h			; tile 05 row 5
		db	0FFh, 00h, 00h, 00h,0C3h, 00h			; tile 05 row 6
		db	 00h, 00h,0C3h, 00h, 00h, 00h			; tile 05 row 7
		db	 03h, 00h, 00h, 00h, 03h			; tile 05 row 8 (5 byte trail)
		db	20 dup (0)			; pad before tile 06
gf_cga_tile_06:
		db	0C3h, 00h, 00h, 00h,0CCh, 00h			; tile 06 row 0
		db	 00h, 00h,0FCh, 00h, 00h, 00h			; tile 06 row 1
		db	0FFh,0FFh,0FCh, 30h,0FFh,0FFh			; tile 06 row 2
		db	0FFh,0FFh,0FFh,0FFh, 3Ch, 30h			; tile 06 row 3
		db	0FFh,0C0h, 00h, 00h,0FFh, 00h			; tile 06 row 4
		db	 00h, 00h,0C0h,0C0h, 00h, 00h			; tile 06 row 5
		db	 00h			; tile 06 row 6 (1 byte)
		db	30h			; tile 06 trailing marker
		db	42 dup (0)			; pad before tile 07
gf_cga_tile_07:
		db	0FFh,0FFh,0FFh,0CFh			; tile 07: 4-byte solid bar
		db	60 dup (0)			; large pad before tile 08
gf_cga_tile_08:
		db	0CFh,0CCh,0CCh, 0Ch, 00h			; tile 08: 5-byte pattern
		db	37 dup (0)			; pad before tile 09
gf_cga_tile_09:
		db	 30h, 00h, 00h, 00h, 0Ch, 00h			; tile 09 row 0
		db	 00h, 00h, 00h, 80h, 00h, 00h			; tile 09 row 1
		db	 00h,0F3h, 00h, 00h, 00h, 3Fh			; tile 09 row 2
		db	 00h, 00h, 00h, 0Fh, 30h, 0Ch			; tile 09 row 3
		db	 00h,0FFh, 00h, 00h, 00h, 0Fh			; tile 09 row 4
		db	 00h, 00h, 00h, 3Fh, 00h, 00h			; tile 09 row 5
		db	 00h, 33h, 00h, 00h, 00h,0C3h			; tile 09 row 6
		db	 00h, 00h, 03h, 00h, 00h, 00h			; tile 09 row 7
		db	 0Ch, 00h, 00h, 00h, 30h, 00h			; tile 09 row 8
		db	 00h, 00h, 00h, 00h, 00h			; tile 09 row 9 (5 byte trail)
		db	30h			; tile 09 trailing marker
		db	7 dup (0)			; pad before tile 0A
gf_cga_tile_0A:
		db	0C0h, 00h, 00h, 03h, 00h, 00h			; tile 0A row 0
		db	 00h, 0Ch, 00h, 00h, 00h, 30h			; tile 0A row 1
		db	 00h, 00h, 00h,0F0h, 00h, 00h			; tile 0A row 2
		db	 00h,0F3h, 03h, 00h, 30h,0F0h			; tile 0A row 3
		db	 00h, 00h, 00h, 3Ch, 00h, 00h			; tile 0A row 4
		db	 00h, 0Fh, 00h, 00h, 00h, 00h			; tile 0A row 5
		db	0C0h, 00h, 00h, 00h, 30h, 00h			; tile 0A row 6
		db	 00h, 00h			; tile 0A row 7 (2 byte trail)
		db	0Ch			; tile 0A trailing marker
		db	38 dup (0)			; pad before tile 0B
gf_cga_tile_0B:
		db	 60h, 0Fh, 3Fh,0F3h			; tile 0B: 4-byte pattern
		db	28 dup (0)			; pad before nibble_outer_loop blit-init code stub
; --- nibble_outer_loop setup code stub (Sourcer mis-decoded) ---
		db	 51h, 1Eh, 56h, 8Ch,0C8h, 05h			; code: push cx; push ds; push si; mov ax,cs
		db	 00h, 30h, 8Eh,0C0h,0B8h, 20h			; code: add ax,3000h; mov es,ax; mov ax,20h
		db	 00h,0F7h,0E1h, 8Bh,0C8h,0BFh			; code: mul cx; mov cx,ax; mov di,...
		db	 00h, 00h,0F3h,0A4h, 5Fh, 07h			; code: rep movsb; pop di; pop es
		db	 59h, 8Ch,0C8h, 05h, 00h, 30h			; code: pop cx; mov ax,cs; add ax,3000h
		db	 8Eh,0D8h,0BEh, 00h, 00h			; code: mov ds,ax; mov si,0

nibble_outer_loop:
					push	cx
					mov	cx,8

nibble_inner_loop:
								push	cx
								lodsw				; String [si] to ax
								mov	dx,ax
								lodsw				; String [si] to ax
								mov	cx,ax
								mov	cs:vga_row_ptr,dx
								mov	cs:cga_ofs_5071,cx
								or	ax,dx
								xchg	al,ah
								mov	bx,ax
								shr	bx,1			; Shift w/zeros fill
								or	ax,bx
								add	bx,bx
								add	bx,bx
								or	ax,bx
								xchg	al,ah
								not	ax
								mov	cs:sprite_row_buf,ax
								call	cga_nibble_mask_advance
								mov	ax,dx
								stosw				; Store ax to es:[di]
								call	cga_nibble_mask_alt
								mov	es:[bp],dx
								inc	bp
								inc	bp
								pop	cx
								loop	nibble_inner_loop		; Loop if cx > 0

					pop	cx
					loop	nibble_outer_loop		; Loop if cx > 0

		retn

cga_nibble_mask_advance		proc	near
		mov	cx,8

cga_nibble_mask_8bit:
					xor	bx,bx			; Zero register
					rol	word ptr cs:cga_ofs_5071,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:vga_row_ptr,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:cga_ofs_5071,1	; Rotate
					adc	bx,bx
					rol	word ptr cs:vga_row_ptr,1	; Rotate
					adc	bx,bx
					add	dx,dx
					add	dx,dx
					or	dl,cs:copy_fn_tbl[bx]
					loop	cga_nibble_mask_8bit		; Loop if cx > 0

		retn

cga_nibble_mask_advance		endp

; copy_fn_tbl: 16-entry CGA color/copy lookup (4-bit BX index → 2-bit color via OR DL)
; Referenced by cga_nibble_mask_8bit `or dl,cs:copy_fn_tbl[bx]`
copy_fn_tbl_local:
		db	0, 1, 2, 1, 1, 3			; entries 0..5: 0,1,2,1,1,3
		db	3, 1, 2, 3, 2, 2			; entries 6..11: 3,1,2,3,2,2
		db	1, 1, 2, 3			; entries 12..15: 1,1,2,3

cga_nibble_mask_alt		proc	near
		mov	cx,8

cga_nibble_mask_alt_8bit:
					xor	al,al			; Zero register
					rol	word ptr cs:sprite_row_buf,1	; Rotate
					adc	al,al
					rol	word ptr cs:sprite_row_buf,1	; Rotate
					adc	al,al
					cmp	al,3
					je	loc_282			; Jump if equal
					xor	al,al			; Zero register

loc_282:
					add	dx,dx
					add	dx,dx
					or	dl,al
					loop	cga_nibble_mask_alt_8bit		; Loop if cx > 0

		retn

cga_nibble_mask_alt		endp

; hero_gfx_init -- copy 0x40 bytes from hero_gfx_tbl (CS) to bg_save_buf_a (game_seg).

hero_gfx_init:
		push	ds
		push	cs
		pop	ds
		mov	si,hero_gfx_tbl
		mov	es,cs:game_seg
		mov	di,bg_save_buf_a
		mov	cx,20h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

; pattern_tail_tbl -- 156 data bytes mis-decoded by Sourcer as 386 LOCK/OR
; prefix instructions (LOCK with OR AL,imm8 is invalid on older x86). These are
; actually sprite/pattern frame data, likely a fade-color lookup table.

pattern_tail_tbl:
		db	 3Fh,0F0h, 0Ch, 0Ch, 0Ch, 0Ch	; bytes 0..5
		db	 0Ch, 0Ch, 0Fh,0F0h, 0Ch,0C0h	; bytes 6..11
		db	 0Ch, 30h, 0Ch, 0Ch, 3Fh,0F0h	; bytes 12..17
		db	 0Ch, 0Ch, 0Ch, 0Ch, 0Fh,0F0h	; bytes 18..23
		db	 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch	; bytes 24..29
		db	 3Fh,0F0h, 0Fh,0F0h, 30h, 0Ch	; bytes 30..35
		db	 30h, 0Ch, 30h, 00h, 33h,0FCh	; bytes 36..41
		db	 30h, 0Ch, 30h, 0Ch, 0Fh,0F0h	; bytes 42..47
		db	 30h, 0Ch, 30h, 0Ch, 3Ch, 3Ch	; bytes 48..53
		db	 3Ch, 3Ch, 33h,0CCh, 33h,0CCh	; bytes 54..59
		db	 30h, 0Ch, 30h, 0Ch, 1Bh, 50h	; bytes 60..65
		db	 2Bh, 50h, 3Bh, 50h, 4Bh, 50h	; bytes 66..71
		db	 5Bh, 50h, 4Bh, 50h, 00h, 01h	; bytes 72..77
		db	 02h, 03h, 04h, 05h, 06h, 07h	; bytes 78..83
		db	 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh	; bytes 84..89
		db	 0Eh, 0Fh, 00h, 02h, 01h, 03h	; bytes 90..95
		db	 08h, 0Ah, 09h, 0Bh, 04h, 06h	; bytes 96..101
		db	 05h, 07h, 0Ch, 0Eh, 0Dh, 0Fh	; bytes 102..107
		db	 00h, 00h, 01h, 03h, 00h, 00h	; bytes 108..113
		db	 01h, 03h, 04h, 04h, 05h, 07h	; bytes 114..119
		db	 0Ch, 0Ch, 0Dh, 0Fh, 00h, 02h	; bytes 120..125
		db	 03h, 01h, 08h, 0Ah, 0Bh, 09h	; bytes 126..131
		db	 0Ch, 0Eh, 0Fh, 0Dh, 04h, 06h	; bytes 132..137
		db	 07h, 05h, 00h, 03h, 00h, 02h	; bytes 138..143
		db	 0Ch, 0Fh, 0Ch, 0Eh, 00h, 03h	; bytes 144..149
		db	 00h, 02h, 08h, 0Bh, 08h, 0Ah	; bytes 150..155
		db	724 dup (0)

seg_a		ends

		end	start
