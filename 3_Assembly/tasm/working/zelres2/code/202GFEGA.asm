
PAGE  59,132

;==========================================================================
;
;  202GFEGA.BIN - EGA Graphics Fill Driver (zelres2 chunk 2)
;
;  EGA variant of the battle/gameplay sprite-fill driver.
;  Renders sprites, tiles, scrolling backgrounds, and hero/enemy graphics
;  using EGA planar memory at A000h with Map Mask (3C4h/3C5h), Bit Mask
;  (3CEh/3CFh), and Data Rotate registers.
;
;  Key subsystems:
;    gfega_main          - main per-frame entry: scan sprite slots, render rows
;    ega_sprite_blit     - sprite blit to EGA with plane-select cache
;    sprite_src_setup    - resolve sprite source address + palette_byte
;    ega_sprite_blit_ex  - expanded sprite blit with phase-based plane offset
;    ega_sprite_render_blended - bit-blend sprite render (xchg+rotate)
;    ega_sprite_render_solid   - solid sprite render (xchg without blend)
;    ega_blit_2bytes_8rows     - 8-row straight copy with EGA plane stride
;    frame_row_driver    - per-frame row dispatcher: scrolling, BG save/restore
;    tile_blit_3x3       - blit 3x3 tile grid into EGA at scroll_vga_ofs
;    draw_ui_tiles       - draw 5??28 UI tile grid from bg_tile_src
;    ega_bg_tile_blit    - blit single background tile at vga_row_ptr
;    hero_sprite_col_blit- blit hero sprite columns from game_seg data
;    anim_refresh_all    - full 8-pass animation refresh loop
;    ega_tile_anim_update- per-tile animation phase update with bit mask
;    fade_gradient_loop  - 9-pass EGA color gradient fade effect
;    projectile_spawn_check - check row position, spawn new projectile
;
;  Animation dispatch via dispatch_tbl (game DS): 5 handler procs at
;  CS:0174h..0250h for 2-/4-/6-frame cycling and removal.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; restored after factoring (consensus value, but not all files agree):
dispatch_tbl             equ     3170h


; External data references (outside this module's CS segment).

; --- Game-segment data pointers (in game_seg via DS) ---
ega_sprite_src	equ	0B000h			;* EGA sprite source data base
ega_plane_alt	equ	0B17Eh			;* EGA alternate plane offset

; --- Internal driver tables (CS-relative) ---
anim_frame_tbl	equ	3863h			;* animation frame offset table
pattern_ptr_tbl	equ	3929h			;* pattern pointer table
sprite_tmp_buf	equ	3E80h			;* sprite temporary pixel buffer
color_map_tbl	equ	4199h			;* EGA color map table
phase_offset_tbl equ	43C8h			;* phase/shift offset table
bg_tile_src	equ	472Eh			;* background tile source pointer
copy_fn_tbl	equ	485Ch			;* VGA copy function pointer table (word array)
hero_gfx_tbl	equ	4B88h			;* hero graphics data table

; --- Driver state variables (CS-segment scratch area) ---
color_pair_tbl	equ	505Ah			;* EGA color pair lookup table (word array)
cur_color_pair	equ	5067h			;* current EGA color pair word (set from table)
vga_row_ptr	equ	5069h			;* current VGA row byte offset (word, +0x280/row)
scroll_vga_ofs	equ	506Bh			;* scroll destination VGA byte offset (word)
row_counter	equ	506Dh			;* row countdown (0x12 rows per frame)
col_idx		equ	506Eh			;* current column index (byte)
row_idx		equ	506Fh			;* current row index (byte)
palette_byte	equ	5070h			;* EGA color/palette byte for current sprite
bitmask_byte	equ	5071h			;* EGA bit mask byte for blitter
scroll_src_ofs	equ	5072h			;* scroll source VGA byte offset (word)
scroll_gfx_ptr	equ	5074h			;* scroll graphics data pointer (word)
scroll_delta	equ	5076h			;* scroll delta (word: col byte + row byte)
anim_phase	equ	5078h			;* animation pass counter (0-7, decremented)
shift_count	equ	5079h			;* EGA shift count byte
sprite_row_buf	equ	507Ah			;* sprite row intermediate buffer (word)
sprite_state_a	equ	508Ah			;* sprite slot state byte A (0xFF=empty, 0xFC=hidden)
sprite_state_b	equ	508Bh			;* sprite slot state byte B
sprite_pos	equ	508Eh			;* sprite position word (col/row packed)
sprite_cache_tbl equ	5097h			;* sprite EGA cache table (word array, indexed by slot*2)

; --- Game-segment lookup tables ---

; --- Sprite attribute table ---
sprite_flags	equ	0AF3Fh			;* sprite flags byte (used for initialization)

; --- Pattern/background data ---

; --- Global variables (game_seg:0xFFxx) ---

; --- Fixed EGA/VGA layout constants ---
ega_row_stride	equ	140h			; EGA bytes per row (320 dec)
ega_2row_stride	equ	280h			; EGA stride for 2 rows (640 dec)
ega_plane_row	equ	50h			; EGA planar row stride (80 bytes = 320px / 4 planes)
ega_plane_stride equ	4Eh			; EGA planar stride after movsw (plane_row - 2)
sprite_data_stride equ	30h			; sprite data stride per row (48 bytes = 3 planes * 2 bytes * 8px)
sprite_record_size equ	24h			; sprite attribute record size (36 bytes)
sprite_slot_stride equ	1Ch			; sprite slot stride within sprite_buf (28 bytes)
hud_ofs		equ	46Ch			; HUD area starting byte offset in EGA framebuffer
ui_ofs		equ	0C8Ch			; UI area byte offset
vga_buf_ofs	equ	1B04h			; VGA work buffer byte offset
sprite_tmp2	equ	3E80h			; sprite temporary buffer (same as sprite_tmp_buf)
tile_ega_buf	equ	3E90h			; tile EGA staging buffer offset
bg_buf		equ	3F20h			; background save/restore buffer offset
sprite_src_base	equ	8000h			; sprite source graphics base offset in game_seg

ega_seg		equ	0A000h			; EGA framebuffer segment

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gfega_main	proc	far

start:
		xchg	di,ax
		and	[bx+si],ax
		add	[si],ch
		xor	[bx+3Ah],al
		mov	al,ds:sprite_flags
; gfega_main inline init block (0x000B-0x005D):
; -- The labels 'start:','drv_init_stub', and 'ega_row_ofs' land mid-instruction,
;    so mnemonics cannot be used for the full block. Keeping as db with decode notes.
;
; [0x000B] ds:out dx,al       -- write sprite_flags byte to EGA port in DX
		db	 3Eh,0EEh		;  ds: out dx,al  (DS-overridden OUT; writes sprite_flags to port)
; [0x000D-0x002F] EGA init table: port/register pairs used by self-init code above
		db	'AZFi@l2g8'		;  EGA reg init table: 'A'=inc cx, 'Z'=pop dx, 'F'=inc si...
		db	 8Ah, 42h,0AEh, 41h, 31h, 3Ah  ;   (garbled as code by Sourcer; treated as table data)
		db	0D0h, 43h, 75h, 46h,0BDh, 46h	;  (EGA init table cont.)
		db	0BAh, 47h, 9Fh, 41h,0DDh, 4Ah	;  (EGA init table cont.)
		db	 2Dh, 4Bh,0B4h, 4Ch, 66h, 50h	;  (EGA init table cont.)
		db	 66h, 50h			;  (EGA init table cont.) -- 66h/50h are data values, not instructions
; [0x0030] Real init code (common to all GF* drivers):
		push	cs
		pop	es
		mov	di,sprite_cache_tbl
		xor	ax,ax
		mov	cx,80h
		rep	stosw				; zero sprite_cache_tbl (0x80 words)
; [0x003C] drv_init_stub: label is at instruction start, so full mnemonic is valid.
; The opcode byte (FEh) is a patch target — callers may overwrite it to skip or alter init.
drv_init_stub:
		inc	byte ptr ds:[anim_phase]	; FE 06 78 50  (opcode byte patched by caller)
		mov	word ptr ds:[vga_row_ptr],046Ch
		mov	si,word ptr ds:[sprite_data_ptr]
		sub	si,21h
; [0x004D-0x004F] call with mid-instruction label: ega_row_ofs labels the displacement bytes.
; Callers patch the displacement (ega_row_ofs) to redirect this call at runtime.
; Current target: 0050h + 1665h = 16B5h.
		db	0E8h				; call near opcode
ega_row_ofs	db	65h,16h			; displacement (patch target); initially calls 16B5h
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
		jz	row_scan_done		; Jump if zero
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
							jns	loc_20			; Jump if not sign
							jmp	player_offscreen

loc_20:
							cmp	al,es:[di-1]
							je	row_advance		; Jump if equal
							call	sprite_state_update

row_advance:
							add	si,4
							call	si_wrap_hi
							add	word ptr ds:vga_row_ptr,ega_2row_stride
							dec	byte ptr ds:row_counter
							jnz	row_render_loop		; Jump if not zero
		retn

gfega_main	endp

sprite_state_update		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_22			; Jump if not sign
		jmp	sprite_neg_handler

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
		call	ega_sprite_blit

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
; Called via dispatch_tbl[bx]; called with SI=sprite_data, DI=sprite_buf slot.

anim_cycle_2frame_1B:
		js	loc_29+1		; Overlapping-instruction trick: jumps to byte 1 of the 4-byte MOV at loc_29.
					; CPU reads: 45h=inc bp / FF FEh=dec si / 3C 04h=cmp al,4 (shared path).
					; JB path (loc_29+0): mov byte ptr [di-1],0FEh then cmp al,4.
					; JS path (loc_29+1): inc bp / dec si / cmp al,4 — deliberate code-density trick.
		cbw				; Convrt byte to word
		db	 31h,0CEh		; xor si, cx  (alt encoding: 31/CE = XOR r/m16,r16; TASM uses 33/C6)
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
; Frames 0x21..0x23 handled separately; on odd anim_phase, advance frame.

anim_cycle_6frame_1D:
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_29			; Jump if below
		retn

loc_29:				; Entry +0: JB path — marks sprite slot active, then checks frame phase.
		mov	byte ptr [di-1],0FEh	; +0: slot marker (JS path enters at +1: inc bp / dec si)
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

; Dispatch handler: complex multi-direction animation (frame base 0x2C, 2 frames + extended range).
; Handles frames 0x2C, 0x2D with bidirectional cycling; higher frames map through lookup table.

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
; On odd anim_phase, advance frame mod 4.

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

ega_sprite_blit		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_41			; Jump if not zero
		jmp	loc_44

loc_41:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:sprite_cache_tbl[bx],0FFFFh
		jnz	loc_43			; Jump if not zero
		mov	ds:sprite_cache_tbl[bx],di
		mov	cl,sprite_data_stride
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,offset ega_row_ofs
		mov	cx,4

plane_1_2_4_loop:
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							dec	di
							dec	di
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							add	di,bx
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							dec	di
							dec	di
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							add	di,bx
							loop	plane_1_2_4_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_43:
		mov	si,ds:sprite_cache_tbl[bx]
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	bx,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,bx
		add	si,bx
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_44:
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	ax,ax			; Zero register
		mov	bx,ega_plane_stride
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		stosw				; Store ax to es:[di]
		add	di,bx
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

ega_sprite_blit		endp

; Dispatch handler: sprite slot remove/restore check.
; If sprite_buf slot is empty (0xFF) or hidden (0xFC), skip; else blit and restore.

sprite_slot_remove:
		cmp	byte ptr ds:sprite_buf,0FFh
		jne	loc_45			; Jump if not equal
		retn

loc_45:
		cmp	byte ptr ds:sprite_buf,0FCh
		jne	loc_46			; Jump if not equal
		retn

loc_46:
		push	si
		push	bx
		mov	byte ptr ds:sprite_buf,0FFh
		mov	cl,[si]
		add	si,25h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_47			; Jump if not sign
		call	sprite_get_value

loc_47:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,46Ch
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
		add	dx,46Ch
		mov	cl,[si]
		add	si,sprite_record_size
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
		jne	loc_48			; Jump if not equal
		retn

loc_48:
		cmp	byte ptr ds:sprite_buf_b,0FCh
		jne	loc_49			; Jump if not equal
		retn

loc_49:
		mov	byte ptr ds:sprite_buf_b,0FFh
		mov	cl,[si]
		add	si,sprite_record_size
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_50			; Jump if not sign
		call	sprite_get_value

loc_50:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,4A2h
		jmp	sprite_cell_render

sprite_wide_row_render:
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
		add	si,sprite_record_size
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
		je	loc_52			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_52			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_51			; Jump if not sign
		call	sprite_get_value

loc_51:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_52:
		add	dx,280h
		cmp	byte ptr ds:row_counter,1
		je	loc_54			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_54			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_54			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_53			; Jump if not sign
		call	sprite_get_value

loc_53:
		call	sprite_cell_render

loc_54:
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
		add	si,sprite_record_size
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
		je	loc_56			; Jump if equal
		add	dx,27Ch
		call	sprite_pos_pair_iter
		test	byte ptr ds:flag_equip_b,0FFh
		jz	loc_56			; Jump if zero
		test	byte ptr ds:flag_shadow,0FFh
		jz	loc_56			; Jump if zero
		call	projectile_spawn_check

loc_56:
		pop	bx
		pop	di
		pop	si
		retn

player_offscreen:
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
		add	si,sprite_record_size
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
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_59			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		call	sprite_get_value

loc_58:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_59:
		add	dx,280h
		cmp	byte ptr ds:row_counter,1
		je	loc_61			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_61			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_61			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_60			; Jump if not sign
		call	sprite_get_value

loc_60:
		call	sprite_cell_render

loc_61:
		pop	bx
		pop	di
		pop	si
		jmp	row_advance

sprite_pos_pair_iter:
		call	sprite_pos_blit

sprite_pos_blit:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_63			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_63			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_62			; Jump if not sign
		call	sprite_get_value

loc_62:
		push	bp
		push	si
		push	di
		push	dx
		call	sprite_cell_render
		pop	dx
		pop	di
		pop	si
		pop	bp

loc_63:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

sprite_cell_render:
		push	es
		push	ds
		mov	bl,ds:palette_byte
		or	al,al			; Zero ?
		jz	loc_65			; Jump if zero
		js	loc_65			; Jump if sign=1
		or	bl,80h

loc_65:
		mov	cl,al
		mov	al,ah
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		add	ax,sprite_gfx_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	di,dx
		mov	ax,0A000h
		mov	es,ax
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_66			; Jump if sign=1
		push	di
		mov	di,sprite_tmp2
		call	ega_sprite_render_solid
		pop	di
		mov	si,sprite_tmp2
		mov	ax,0A000h
		mov	ds,ax
		call	ega_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

loc_66:
		push	di
		mov	di,sprite_tmp_buf
		call	ega_sprite_blit_ex
		pop	di
		mov	si,sprite_tmp2
		mov	ax,0A000h
		mov	ds,ax
		call	ega_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

sprite_blit_dispatch		endp

ega_sprite_blit_ex		proc	near
		push	si
		push	di
		mov	al,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		call	ega_3plane_copy
		pop	di
		pop	si
		jmp	short $+2		; delay for I/O

ega_sprite_render_blended:
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

blend_row_loop:
							push	cx
							lodsw				; String [si] to ax
							xchg	al,ah
							mov	bx,ax
							lodsw				; String [si] to ax
							xchg	al,ah
							mov	cx,ax
							mov	ax,3
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	al,8
							out	dx,al			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							inc	dx
							mov	ax,bx
							or	ax,cx
							mov	bp,ax
							shl	bp,1			; Shift w/zeros fill
							or	ax,bp
							shr	bp,1			; Shift w/zeros fill
							shr	bp,1			; Shift w/zeros fill
							or	ax,bp
							xchg	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							xor	al,al			; Zero register
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							xor	al,al			; Zero register
							xchg	es:[di+1],al
							dec	dx
							mov	ax,1003h
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	al,8
							out	dx,al			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							inc	dx
							mov	al,bh
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,cs:cur_color_pair
							xchg	es:[di],al
							mov	al,bl
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,cs:cur_color_pair
							xchg	es:[di+1],al
							mov	al,ch
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,byte ptr cs:cur_color_pair+1
							xchg	es:[di],al
							mov	al,cl
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,byte ptr cs:cur_color_pair+1
							xchg	es:[di+1],al
							dec	dx
							inc	di
							inc	di
							pop	cx
							loop	blend_row_loop		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_sprite_blit_ex		endp

ega_sprite_render_solid		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,8

solid_row_loop:
							mov	ax,3
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	ax,0FF08h
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							xor	al,al			; Zero register
							xchg	es:[di],al
							xor	al,al			; Zero register
							xchg	es:[di+1],al
							mov	ax,1003h
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	al,8
							out	dx,al			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							inc	dx
							lodsw				; String [si] to ax
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,cs:cur_color_pair
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,cs:cur_color_pair
							xchg	es:[di+1],al
							lodsw				; String [si] to ax
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,byte ptr cs:cur_color_pair+1
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,byte ptr cs:cur_color_pair+1
							xchg	es:[di+1],al
							dec	dx
							inc	di
							inc	di
							loop	solid_row_loop		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_sprite_render_solid		endp

ega_blit_2bytes_8rows		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		add	di,ega_plane_stride
		movsb				; Mov [si] to es:[di]
		movsb				; Mov [si] to es:[di]
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

ega_blit_2bytes_8rows		endp

ega_3plane_copy		proc	near
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	cx,8

plane_copy_loop:
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							dec	di
							dec	di
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							loop	plane_copy_loop		; Loop if cx > 0

		retn

ega_3plane_copy		endp

ega_clear_16bytes		proc	near
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		retn

ega_clear_16bytes		endp

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
		jnz	loc_70			; Jump if not zero
		mov	si,sprite_src_b

loc_70:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:flag_equip_b,0FFh
		jnz	loc_71			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_71			; Jump if zero
		add	al,3

loc_71:
		mov	ds:palette_byte,al
		mov	al,cl
		retn

sprite_src_setup		endp

projectile_spawn_check		proc	near
		cmp	byte ptr ds:row_idx,10h
		jb	loc_72			; Jump if below
		retn

loc_72:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_73			; Jump if above or =
		retn

loc_73:
		mov	di,projectile_list
		xor	cl,cl			; Zero register

loc_74:
							cmp	byte ptr [di],0FFh
							je	loc_75			; Jump if equal
							add	di,4
							inc	cl
							jmp	short loc_74

loc_75:
		cmp	cl,20h			; ' '
		jb	loc_76			; Jump if below
		retn

loc_76:
							call	word ptr cs:[11Ah]
							and	al,3
							cmp	al,3
							je	loc_76			; Jump if equal
		dec	al
		add	al,ds:col_idx
		cmp	al,0FFh
		jne	loc_77			; Jump if not equal
		mov	al,4

loc_77:
		cmp	al,1Bh
		jb	loc_78			; Jump if below
		mov	al,1Ah

loc_78:
		stosb				; Store al to es:[di]

loc_79:
							call	word ptr cs:[11Ah]
							and	al,3
							cmp	al,3
							je	loc_79			; Jump if equal
		dec	al
		add	al,ds:row_idx
		cmp	al,0FFh
		jne	loc_80			; Jump if not equal
		xor	al,al			; Zero register

loc_80:
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

; Dispatch handler: projectile slot mark and render.
; Marks projectile slot as 0xFE and blits pattern to EGA from pattern_ptr_tbl.

projectile_blit:
		add	al,byte ptr ds:[607h]
		push	cs
		pop	es
		mov	di,projectile_list
		mov	si,di
		cmp	byte ptr [si],0FFh
		jne	loc_81			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn

loc_81:
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
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,46Ch
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
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,10h

proj_blit_row_loop:
							lodsw				; String [si] to ax
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,ds:bitmask_byte
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,ds:bitmask_byte
							xchg	es:[di+1],al
							lodsw				; String [si] to ax
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,ds:bitmask_byte
							xchg	es:[di+2],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,ds:bitmask_byte
							xchg	es:[di+3],al
							add	di,ega_plane_row
							loop	proj_blit_row_loop		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	$+7			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4
		add	si,4
		jmp	$-0B8h

; EGA sprite bitmask shape data -- accessed by fade_gradient_loop and similar.
; Sourcer decodes surrounding code as garbled instructions; this is pure table data.
; First 9 bytes: 4 pointer words (CS-relative offsets to shape groups) + 0x00 terminator.
; Remaining: EGA 4-byte bitmask rows, 2 bytes per EGA plane pair, zero-padded between groups.
; Groups alternate diamond/circle shapes; each row = (plane1_hi, plane1_lo, plane2_hi, plane2_lo).

sprite_bitmask_tbl:
		db	0F1h, 39h,0B1h, 39h, 71h, 39h	; ptr[0]=0x39F1, ptr[1]=0x39B1, ptr[2]=0x3971
		db	 31h, 39h, 00h			; ptr[3]=0x3931, terminator
		db	16 dup (0)			; padding (16 bytes)
		db	 0Bh,0D0h, 00h, 00h, 5Fh,0FAh	; group shape rows: narrow diamond
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h	;  (cont.)
		db	0FFh,0FFh, 00h, 00h,0FFh,0FFh	;  (cont.)
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h	;  (cont.)
		db	 5Fh,0FAh, 00h, 00h, 0Bh,0D0h	;  (cont. last row)
		db	26 dup (0)			; padding between groups
		db	 2Fh,0F4h, 00h, 00h,0FFh,0FFh	; group shape rows: wide diamond
		db	 00h, 03h,0FFh,0FFh,0C0h, 07h	;  (cont.)
		db	0FFh,0FFh,0E0h, 0Fh,0FAh, 5Fh	;  (cont.)
		db	0F0h, 0Fh,0F0h, 0Fh,0F0h, 0Fh	;  (cont.)
		db	0F0h, 0Fh,0F0h, 0Fh,0FAh, 5Fh	;  (cont.)
		db	0F0h, 07h,0FFh,0FFh,0E0h, 03h	;  (cont.)
		db	0FFh,0FFh,0C0h, 00h,0FFh,0FFh	;  (cont.)
		db	 00h, 00h, 2Fh,0F4h		;  (cont. last row)
		db	10 dup (0)			; padding between groups
		db	 2Fh,0F4h, 00h, 01h, 7Fh,0FEh	; group shape rows: full circle
		db	 80h, 07h,0FFh,0FFh,0E0h, 0Fh	;  (cont.)
		db	0FFh,0FFh,0F0h, 3Fh,0F4h, 2Fh	;  (cont.)
		db	0FCh, 7Fh,0A0h, 05h,0FEh, 7Fh	;  (cont.)
		db	 80h, 01h,0FEh,0FFh, 00h, 00h	;  (cont.)
		db	0FFh,0FFh, 00h, 00h,0FFh, 7Fh	;  (cont.)
		db	 80h, 01h,0FEh, 7Fh,0A0h, 05h	;  (cont.)
		db	0FEh, 3Fh,0F4h, 2Fh,0FCh, 0Fh	;  (cont.)
		db	0FFh,0FFh,0F0h, 07h,0FFh,0FFh	;  (cont.)
		db	0E0h, 01h, 7Fh,0FEh, 80h, 00h	;  (cont.)
		db	 2Fh,0F4h, 00h, 00h, 2Fh,0F4h	;  (cont.)
		db	 00h, 01h			;  (cont. last bytes)

loc_83:
							jg	loc_83			; Jump if >
		add	byte ptr [bx],0D0h
		or	sp,ax
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
                           lock	cmp	al,0
		add	[si],bh
		js	$+2			; delay for I/O
		add	byte ptr ds:[70h],bl
		add	byte ptr ds:[0F0h],cl
		add	[bx],cl
                           lock	add	[bx+si],al
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		jo	$+2			; delay for I/O
		add	byte ptr ds:[78h],cl
		add	byte ptr drv_init_stub,bl
		add	[si],bh
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
                           lock	pop	es
		ror	byte ptr [bp+di],1	; Rotate
;*		loopnz	locloop_85		;*Loop if zf=0, cx>0

		db	0E0h, 01h		;  Fixup - byte match

loc_84:
							jg	loc_84			; Jump if >
		add	byte ptr [bx+si],2Fh	; '/'
		hlt				; Halt processor
		add	ds:sprite_pos[bx],bh
		push	cs
		pop	es
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosb				; Store al to es:[di]
		mov	di,sprite_row_buf
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		jmp	short loc_89

; Dispatch handler: scroll row build ?-- loads enemy positions into sprite_row_buf
; and computes scroll_vga_ofs from player position.

scroll_row_build:
		call	scroll_pos_load
		mov	di,sprite_row_buf
		mov	dl,ds:enemy_counter
		dec	dl
		mov	cx,4

enemy_row_scan_loop:
							push	cx
							and	dl,3Fh			; '?'
							mov	al,sprite_record_size
							mul	dl			; ax = reg * al
							mov	bx,ax
							add	bx,pattern_base
							mov	al,byte ptr ds:[83h]
							add	al,3
							xor	ah,ah			; Zero register
							add	bx,ax
							mov	cx,4

enemy_slot_scan_loop:
												mov	al,[bx]
												or	al,al			; Zero ?
												js	loc_88			; Jump if sign=1
												xor	al,al			; Zero register

loc_88:
												mov	[di],al
												inc	bx
												inc	di
												loop	enemy_slot_scan_loop		; Loop if cx > 0

							inc	dl
							pop	cx
							loop	enemy_row_scan_loop		; Loop if cx > 0

loc_89:
		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,280h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	ax,cx
		add	ax,46Ch
		mov	ds:scroll_vga_ofs,ax
		mov	byte ptr ds:col_idx,0
		mov	si,508Eh
		mov	di,sprite_row_buf
		mov	cx,3

sprite_row_blit_loop:
							push	cx
							mov	cx,3

sprite_col_blit_loop:
												push	cx
												mov	ax,3B12h
												push	ax
												mov	al,[di]
												or	al,[di+1]
												or	al,[di+4]
												or	al,[di+5]
												jnz	loc_92			; Jump if not zero
												jmp	loc_129

loc_92:
												test	byte ptr [di],0FFh
												jz	loc_93			; Jump if zero
												mov	al,[di]
												push	si
												call	sprite_src_setup
												inc	si
												inc	si
												inc	si
												mov	al,[si]
												pop	si
												jmp	loc_131

loc_93:
												test	byte ptr [di+1],0FFh
												jz	loc_94			; Jump if zero
												mov	al,[di+1]
												push	si
												call	sprite_src_setup
												inc	si
												inc	si
												mov	al,[si]
												pop	si
												jmp	loc_131

loc_94:
												test	byte ptr [di+4],0FFh
												jz	loc_95			; Jump if zero
												mov	al,[di+4]
												push	si
												call	sprite_src_setup
												inc	si
												mov	al,[si]
												pop	si
												jmp	loc_131

loc_95:
												mov	al,[di+5]
												push	si
												call	sprite_src_setup
												mov	cl,[si]
												pop	si
												mov	[si],al
												mov	al,cl
												jmp	loc_131

; Inner loop continuation: reached after loc_129/loc_131 return to sprite_col_blit_loop caller.
; Sourcer marks unreachable because it cannot trace through the jmp-then-retn pattern.

loc_col_advance:
												inc	byte ptr ds:col_idx
												inc	di
												inc	si
												pop	cx
												loop	sprite_col_blit_loop		; Loop if cx > 0

							pop	cx
							inc	di
							loop	sprite_row_blit_loop		; Loop if cx > 0

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
		jz	loc_96			; Jump if zero
		jmp	loc_106

loc_96:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_97			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h

loc_97:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_101			; Jump if zero
		inc	cl
		jnz	loc_98			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	hero_tier_get
		mov	cl,sprite_record_size
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_104

loc_98:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_99			; Jump if not zero
		add	ax,24h
		jmp	short loc_100

loc_99:
		dec	dl
		jnz	loc_100			; Jump if not zero
		mov	ax,63h

loc_100:
		add	si,ax
		jmp	short loc_104

loc_101:
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_103			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_103			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:flag_shield
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_102			; Jump if zero
		add	ax,1Bh

loc_102:
		add	si,ax
		jmp	short loc_104

loc_103:
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_106			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_106			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_106			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_105

loc_104:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_105			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		call	hero_sprite_col_blit
		jmp	short loc_106

loc_105:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	hero_sprite_col_blit

loc_106:
		mov	si,610Eh
		test	byte ptr ds:flag_riding,0FFh
		jnz	loc_111			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:flag_climbing,0FFh
		jnz	loc_109			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_107			; Jump if not zero
		mov	si,game_data_base

loc_107:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_108			; Jump if zero
		add	si,5Ah
		jmp	short loc_109

loc_108:
		mov	ax,2Dh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_110			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:equip_byte,80h
		jnz	loc_110			; Jump if not zero
		mov	cl,ds:shield_sel
		mov	ax,48h
		dec	cl
		jz	loc_110			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_110			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:equip_byte,7Fh
		je	loc_110			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_110			; Jump if equal

loc_109:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al

loc_110:
		add	si,ax

loc_111:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	hero_sprite_col_blit
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_112			; Jump if zero
		retn

loc_112:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_113			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h

loc_113:
		mov	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_115			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jnz	loc_114			; Jump if not zero
		retn

loc_114:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_122

loc_115:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_119			; Jump if zero
		inc	cl
		jnz	loc_116			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	hero_tier_get
		mov	cl,sprite_record_size
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_123

loc_116:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_117			; Jump if not zero
		add	ax,24h
		jmp	short loc_118

loc_117:
		dec	dl
		jnz	loc_118			; Jump if not zero
		mov	ax,63h

loc_118:
		add	si,ax
		jmp	short loc_123

loc_119:
		test	byte ptr ds:[0C2h],1
		jz	loc_121			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_121			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:flag_shield
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_120			; Jump if zero
		add	ax,1Bh

loc_120:
		add	si,ax
		jmp	short loc_123

loc_121:
		mov	ax,1Bh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_122			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_122			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al

loc_122:
		add	si,ax

loc_123:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_124			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		jmp	short hero_col_blit_loop

loc_124:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		jmp	short hero_col_blit_loop

hero_sprite_col_blit		proc	near

hero_col_blit_loop:
							push	cx
							mov	al,es:[si]
							or	al,al			; Zero ?
							jz	loc_126			; Jump if zero
							push	es
							push	ds
							push	si
							push	di
							mov	ch,20h			; ' '
							mul	ch			; ax = reg * al
							add	ax,6333h
							mov	si,ax
							mov	ds,cs:game_seg
							mov	di,dx
							mov	ax,0A000h
							mov	es,ax
							mov	al,cs:col_idx
							mov	cl,10h
							mul	cl			; ax = reg * al
							add	ax,3E90h
							mov	di,ax
							call	ega_sprite_render_blended
							pop	di
							pop	si
							pop	ds
							pop	es

loc_126:
							inc	si
							inc	byte ptr ds:col_idx
							pop	cx
							loop	hero_col_blit_loop		; Loop if cx > 0

		retn

hero_sprite_col_blit		endp

hero_tier_get		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_127			; Jump if not zero
		retn

loc_127:
		cmp	al,4
		mov	al,1
		jnc	loc_128			; Jump if carry=0
		retn

loc_128:
		mov	al,2
		retn

hero_tier_get		endp

loc_129:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	al,cs:col_idx
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,3E90h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_130			; Jump if zero
		mov	cl,sprite_data_stride
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		call	ega_3plane_copy
		pop	di
		pop	si
		pop	ds
		retn

loc_130:
		call	ega_clear_16bytes
		pop	di
		pop	si
		pop	ds
		retn

loc_131:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_132			; Jump if not sign
		call	sprite_get_value

loc_132:
		push	ax
		mov	bl,ds:palette_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,dx
		mov	al,cl
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		add	ax,sprite_gfx_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	al,cs:col_idx
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,3E90h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_133			; Jump if zero
		mov	cl,al
		call	ega_sprite_blit_ex
		pop	di
		pop	si
		pop	ds
		retn

loc_133:
		call	ega_sprite_render_solid
		pop	di
		pop	si
		pop	ds
		retn

scroll_pos_load		proc	near
		mov	cl,byte ptr ds:[84h]
		mov	al,sprite_record_size
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

scroll_pos_mov_loop:
							movsw				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							add	si,21h
							call	si_wrap_hi
							loop	scroll_pos_mov_loop		; Loop if cx > 0

		retn

scroll_pos_load		endp

frame_row_driver		proc	near
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_136			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_135		; Jump if not equal
		call	tile_blit_3x3

loc_ret_135:
		retn

loc_136:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_137			; Jump if above or =
		retn

loc_137:
		jnz	loc_138			; Jump if not zero
		call	bg_restore
		jmp	loc_164

loc_138:
		add	al,0Ah
		cmp	al,cl
		je	loc_139			; Jump if equal
		retn

loc_139:
		jmp	loc_154

; Dispatch handler: scroll step state machine ?-- increments scroll_step,
; computes scroll_delta and scroll_src_ofs based on scroll_phase.

scroll_step_update:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_140			; Jump if not zero
		retn

loc_140:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:game_seg
		inc	byte ptr ds:scroll_step
		mov	al,ds:scroll_phase
		or	al,al			; Zero ?
		jz	loc_144			; Jump if zero
		dec	al
		jz	loc_142			; Jump if zero
		cmp	byte ptr ds:scroll_step,5
		jb	loc_141			; Jump if below
		jmp	loc_148

loc_141:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:scroll_delta,0FF01h
		mov	dx,27Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_146			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:scroll_delta,1
		mov	dx,280h
		jmp	short loc_146

loc_142:
		cmp	byte ptr ds:scroll_step,5
		jb	loc_143			; Jump if below
		jmp	loc_148

loc_143:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_145			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_145

loc_144:
		cmp	byte ptr ds:scroll_step,7
		jae	loc_148			; Jump if above or =
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_145			; Jump if not zero
		mov	di,ega_plane_alt
		mov	si,0B01Eh

loc_145:
		mov	bx,es:[bx+di]
		mov	ds:scroll_delta,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,280h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	dx,ax

loc_146:
		mov	di,ds:scroll_vga_ofs
		add	di,dx
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_147			; Jump if zero
		add	di,280h

loc_147:
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
		jmp	loc_154

loc_148:
		mov	byte ptr ds:scroll_active,0
		mov	byte ptr ds:scroll_step,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

bg_restore:
		test	byte ptr ds:restore_pending,0FFh
		jnz	loc_149			; Jump if not zero
		retn

loc_149:
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	bg_restore_impl
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		mov	byte ptr ds:restore_pending,0
		retn

bg_save:
		mov	si,cs:scroll_src_ofs
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	di,bg_buf
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,20h

bg_save_row_loop:
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							add	si,48h
							loop	bg_save_row_loop		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

bg_restore_impl:
		mov	di,cs:scroll_src_ofs
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,bg_buf
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,105h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	cx,20h

bg_restore_row_loop:
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							movsb				; Mov [si] to es:[di]
							add	di,48h
							loop	bg_restore_row_loop		; Loop if cx > 0

		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

scroll_cache_invalidate:
		mov	al,byte ptr ds:[84h]
		add	al,ds:scroll_delta
		and	al,3Fh			; '?'
		mov	cl,sprite_record_size
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

scroll_cache_row_loop:
							push	cx
							mov	cx,4

scroll_cache_col_loop:
												push	cx
												mov	bl,[si]
												inc	si
												and	bl,7Fh
												xor	bh,bh			; Zero register
												add	bx,bx
												mov	word ptr ds:sprite_cache_tbl[bx],0
												pop	cx
												loop	scroll_cache_col_loop		; Loop if cx > 0

							add	si,20h
							call	si_wrap_hi
							pop	cx
							loop	scroll_cache_row_loop		; Loop if cx > 0

		retn

loc_154:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_155			; Jump if not zero
		retn

loc_155:
		mov	byte ptr ds:restore_pending,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	scroll_cache_invalidate
		call	bg_save
		mov	bl,byte ptr cs:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		mov	al,cs:color_map_tbl[bx]
		mov	cs:bitmask_byte,al
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:scroll_src_ofs
		mov	si,cs:scroll_gfx_ptr
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,4

loc_156:
		push	cx
		mov	cx,4

loc_157:
		push	cx
		lodsb				; String [si] to al
		push	si
		mov	bx,280h
		cmp	al,0FFh
		jne	loc_158			; Jump if not equal
		jmp	loc_159

loc_158:
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	ax,ax
		mov	si,ax
		add	si,ds:ega_sprite_src
		mov	cl,cs:bitmask_byte
		mov	bx,ega_plane_row
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al
		add	di,bx
		lodsw				; String [si] to ax
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di],al
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,cl
		xchg	es:[di+1],al

loc_159:
		add	di,bx
		pop	si
		pop	cx
		loop	scroll_blit_col_loop		; Loop if cx > 0

		jmp	short loc_161

scroll_blit_col_loop:
		jmp	loc_157

loc_161:
		add	di,0F602h
		pop	cx
		loop	scroll_blit_row_loop		; Loop if cx > 0

		jmp	short loc_163

scroll_blit_row_loop:
		jmp	loc_156

loc_163:
		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

frame_row_driver		endp

	; Dispatch handler: compute scroll_vga_ofs from packed row/col in BL/BH,
; then fall through into tile_blit_3x3 (loc_166) bypassing the redraw_lock check.

scroll_vga_pos_blit:
		add	[si],ax
		add	ax,[bx+di]
		add	al,6
		mov	al,50h			; 'P'
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	ds:scroll_vga_ofs,ax
		jmp	short loc_166

tile_blit_3x3		proc	near

loc_164:
		test	byte ptr ds:redraw_lock,0FFh
		jz	loc_165			; Jump if zero
		retn

loc_165:
		mov	byte ptr ds:redraw_lock,0FFh

loc_166:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,tile_ega_buf
		mov	di,cs:scroll_vga_ofs
		mov	cx,3

tile_3x3_row_loop:
							push	cx
							mov	cx,3

tile_3x3_col_loop:
												push	cx
												push	di
												call	ega_blit_2bytes_8rows
												pop	di
												inc	di
												inc	di
												pop	cx
												loop	tile_3x3_col_loop		; Loop if cx > 0

							add	di,27Ah
							pop	cx
							loop	tile_3x3_row_loop		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn

tile_blit_3x3		endp

; Dispatch handler: draw sprite using 3-plane EGA interleave with bit-mask blend.
; AL=sprite index; each plane written separately to EGA with rotate/mask registers.

draw_sprite_3plane:
		push	ds
		push	si
		mov	cl,sprite_data_stride
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

sprite_3plane_row_loop:
							push	cx
							mov	ax,3
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	al,8
							out	dx,al			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							inc	dx
							lodsw				; String [si] to ax
							mov	cx,ax
							lodsw				; String [si] to ax
							mov	bx,ax
							lodsw				; String [si] to ax
							mov	bp,ax
							or	ax,cx
							or	ax,bx
							out	dx,al			; port 3CFh, EGA graphic func
							xor	al,al			; Zero register
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							xor	al,al			; Zero register
							xchg	es:[di+1],al
							dec	dx
							mov	ax,1003h
							out	dx,ax			; port 3CEh, EGA graphic index
											;  al = 3, data rotate
							mov	al,8
							out	dx,al			; port 3CEh, EGA graphic index
											;  al = 8, data bit mask
							inc	dx
							mov	al,cl
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di],al
							mov	al,ch
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di+1],al
							mov	al,bl
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,2
							xchg	es:[di],al
							mov	al,bh
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,2
							xchg	es:[di+1],al
							mov	ax,bp
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,4
							xchg	es:[di],al
							mov	al,ah
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,4
							xchg	es:[di+1],al
							dec	dx
							add	di,ega_plane_row
							pop	cx
							loop	sprite_3plane_row_loop		; Loop if cx > 0

		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	al,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	si
		pop	ds
		retn

; Dispatch handler: full animation refresh ?-- clears restore_pending, sets 8 anim passes,
; then iterates all 0x12 rows ?? 0x1C sprite slots calling ega_tile_anim_update per slot.

anim_refresh_all:
		mov	byte ptr ds:restore_pending,0
		mov	ax,0A000h
		mov	es,ax
		mov	byte ptr ds:anim_phase,8

anim_pass_start:
							mov	word ptr ds:vga_row_ptr,46Ch
							mov	byte ptr ds:gvar_frame_timer,0
							mov	si,ds:sprite_data_ptr
							mov	di,sprite_buf
							mov	cx,12h

anim_row_loop:
												push	cx
												add	si,4
												xor	bx,bx			; Zero register
												mov	cx,1Ch

anim_slot_loop:
												push	cx
												lodsb				; String [si] to al
												call	ega_tile_anim_update
												inc	di
												inc	bl
												pop	cx
												loop	anim_slot_loop		; Loop if cx > 0

												add	si,4
												call	si_wrap_hi
												add	word ptr ds:vga_row_ptr,ega_2row_stride
												pop	cx
												loop	anim_row_loop		; Loop if cx > 0

wait_frame_timer:
												cmp	byte ptr ds:gvar_frame_timer,10h
												jb	wait_frame_timer	; Jump if below
							dec	byte ptr ds:anim_phase
							jnz	anim_pass_start		; Jump if not zero
		mov	dx,3CEh
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_tile_anim_update		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_174			; Jump if not equal
		retn

loc_174:
		cmp	byte ptr [di],0FCh
		jne	loc_175			; Jump if not equal
		retn

loc_175:
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
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		add	bx,bx
		add	bx,ds:vga_row_ptr
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_177			; Jump if zero
		mov	cl,sprite_data_stride
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		push	si
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	phase_ptr_advance
		call	ega_plane_write_2row
		pop	di
		pop	si
		mov	al,cs:anim_phase
		call	phase_ptr_advance
		inc	di
		inc	si
		call	ega_plane_write_2row
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

ega_plane_write_2row:
		mov	cx,2

plane_write_2row_loop:
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsb				; String [si] to al
							xchg	es:[di],al
							inc	si
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsb				; String [si] to al
							xchg	es:[di],al
							inc	si
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsb				; String [si] to al
							xchg	es:[di],al
							add	di,140h
							add	si,13h
							loop	plane_write_2row_loop		; Loop if cx > 0

		retn

loc_177:
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	phase_ptr_advance
		call	ega_clear_pixel_pair
		pop	di
		mov	al,cs:anim_phase
		call	phase_ptr_advance
		inc	di
		call	ega_clear_pixel_pair
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

ega_tile_anim_update		endp

ega_clear_pixel_pair		proc	near
		xor	al,al			; Zero register
		xchg	es:[di],al
		add	di,ega_row_stride
		xor	al,al			; Zero register
		xchg	es:[di],al
		retn

ega_clear_pixel_pair		endp

phase_ptr_advance		proc	near
		and	al,3
		add	al,al
		xor	ah,ah			; Zero register
		mov	bx,phase_offset_tbl
		add	bx,ax
		mov	al,cs:[bx]
		add	si,ax
		mov	al,cs:[bx+1]
		add	di,ax
		retn

phase_ptr_advance		endp

; ega_color_fade_init -- inline proc body (no proc label in Sourcer output).
; Reads color coords from DS:[0x83]/[0x84], multiplies by 8 to get EGA palette
; offsets, stores to cur_color_pair/cur_color_pair+1, then calls the EGA gradient
; blit proc (CS:0x1614) and fade_gradient_loop three times at three radii
; (0x19, 0x21, 0x29 pixel spread). Each call (ega_inner_fade) computes BL/BH/DL/DH
; bounds from cur_color_pair +/- radius and calls fade_gradient_loop.
;
;  0x13CC: 00 00           -- 2-byte null header / alignment
;  0x13CE: push es / push ax / or al,0xA0 / adc dh,al
;  0x13D4: mov al,[0x83]; shl al,3 (via 3x add al,al)
;  0x13DD: mov ah,[0x84]; shl ah,3
;  0x13E7: mov [cur_color_pair],al; mov [cur_color_pair+1],ah
;  0x13EE: call CS:0x1614  (EGA gradient blit core)
;  0x13F1: mov [anim_phase],6; call 0x1404; mov [anim_phase],0; call 0x1404; jmp 0x1614
;
; ega_inner_fade (at 0x1404 within this block):
;  Radius 0x19: BL=X-1, DL=X-1+0x19, BH=Y-1, DH=Y-1+0x19 -> call fade_gradient_loop
;  Radius 0x21: BL=X-5, DL=X-5+0x21, BH=Y-5, DH=Y-5+0x21 -> call fade_gradient_loop
;  Radius 0x29: BL=X-9, DL=X-9+0x29, BH=Y-9, DH=Y-9+0x29 -> call fade_gradient_loop

ega_color_fade_init:
		db	 00h, 00h		; 2-byte alignment header (decodes as 'add [bx+si],al'; not reached)
		push	es
		push	ax
		or	al,0A0h
		adc	dh,al
		mov	al,ds:[83h]		; X coord (game_seg global)
		add	al,al			; X * 2
		add	al,al			; X * 4
		add	al,al			; X * 8 -> EGA palette X offset
		mov	ah,ds:[84h]		; Y coord (game_seg global)
		add	ah,ah			; Y * 2
		add	ah,ah			; Y * 4
		add	ah,ah			; Y * 8 -> EGA palette Y offset
		mov	ds:cur_color_pair,al
		mov	byte ptr ds:[cur_color_pair+1],ah
		call	hud_clear		; clear HUD around fade region
		mov	byte ptr ds:[anim_phase],6
		call	ega_inner_fade
		mov	byte ptr ds:[anim_phase],0
		call	ega_inner_fade
		jmp	hud_clear

ega_inner_fade:					; radius loop: 3 passes (radii 0x19, 0x21, 0x29)
		mov	al,ds:cur_color_pair
		dec	al
		mov	bl,al
		add	al,19h
		mov	dl,al
		mov	al,ds:[cur_color_pair+1]
		dec	al
		mov	bh,al
		add	al,19h
		mov	dh,al
		call	fade_gradient_loop
		mov	al,ds:cur_color_pair
		sub	al,5
		mov	bl,al
		add	al,21h
		mov	dl,al
		mov	al,ds:[cur_color_pair+1]
		sub	al,5
		mov	bh,al
		add	al,21h
		mov	dh,al
		call	fade_gradient_loop
		mov	al,ds:cur_color_pair
		sub	al,9
		mov	bl,al
		add	al,29h
		mov	dl,al
		mov	al,ds:[cur_color_pair+1]
		sub	al,9
		mov	bh,al
		add	al,29h
		mov	dh,al
		; falls through to fade_gradient_loop

fade_gradient_loop		proc	near
		mov	cx,9

fade_pass_loop:
							push	cx
							push	dx
							push	bx
							call	ega_fade_blit
							pop	bx
							pop	dx
							sub	bl,0Ch
							jnc	loc_179			; Jump if carry=0
							xor	bl,bl			; Zero register

loc_179:
							sub	bh,0Ch
							jnc	loc_180			; Jump if carry=0
							xor	bh,bh			; Zero register

loc_180:
							add	dl,0Ch
							jnc	loc_181			; Jump if carry=0
							mov	dl,0FFh

loc_181:
							add	dh,0Ch
							jnc	loc_182			; Jump if carry=0
							mov	dh,0FFh

loc_182:
							push	dx
							push	bx
							call	frame_wait_loop
							pop	bx
							pop	dx
							pop	cx
							loop	fade_pass_loop		; Loop if cx > 0

		retn

fade_gradient_loop		endp

ega_fade_blit		proc	near
		push	dx
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	dx
		push	dx
		push	bx
		mov	dh,bh
		call	ega_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	ega_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	ega_fill_bit_range
		pop	bx
		pop	dx
		mov	bl,dl
		call	ega_fill_bit_range
		mov	dx,3CEh
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

ega_fade_blit		endp

ega_fill_bit_range		proc	near
		cmp	dh,bh
		jae	loc_183			; Jump if above or =
		xchg	dx,bx

loc_183:
		or	bl,bl			; Zero ?
		jnz	loc_184			; Jump if not zero
		retn

loc_184:
		cmp	bl,0DFh
		jb	loc_185			; Jump if below
		retn

loc_185:
		or	bh,bh			; Zero ?
		jnz	loc_186			; Jump if not zero
		mov	bh,1

loc_186:
		cmp	dh,8Fh
		jb	loc_187			; Jump if below
		mov	dh,8Eh

loc_187:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	ega_row_addr_calc
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_190			; Jump if zero
		cmp	bl,2
		jb	loc_189			; Jump if below
		jz	loc_188			; Jump if zero
		mov	ah,3
		jmp	short loc_191

loc_188:
		mov	ah,0Ch
		jmp	short loc_191

loc_189:
		mov	ah,30h			; '0'
		jmp	short loc_191

loc_190:
		mov	ah,0C0h

loc_191:
		mov	dx,3CEh
		mov	al,8
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask

fill_range_loop:
							mov	al,ds:anim_phase
							xchg	es:[di],al
							add	di,ega_plane_row
							loop	fill_range_loop		; Loop if cx > 0

		retn

ega_fill_bit_range		endp

ega_fill_bit_range_wide		proc	near
		cmp	dl,bl
		jae	loc_193			; Jump if above or =
		xchg	dx,bx

loc_193:
		or	bh,bh			; Zero ?
		jnz	loc_194			; Jump if not zero
		retn

loc_194:
		cmp	bh,8Fh
		jb	loc_195			; Jump if below
		retn

loc_195:
		or	bl,bl			; Zero ?
		jnz	loc_196			; Jump if not zero
		mov	bl,1

loc_196:
		cmp	dl,0DFh
		jb	loc_197			; Jump if below
		mov	dl,0DEh

loc_197:
		mov	al,bh
		call	ega_row_addr_calc
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
		jz	loc_200			; Jump if zero
		cmp	bl,2
		jb	loc_199			; Jump if below
		jz	loc_198			; Jump if zero
		mov	al,3
		jmp	short loc_201

loc_198:
		mov	al,0Fh
		jmp	short loc_201

loc_199:
		mov	al,3Fh			; '?'
		jmp	short loc_201

loc_200:
		mov	al,0FFh

loc_201:
		and	dl,3
		jz	loc_204			; Jump if zero
		cmp	dl,2
		jb	loc_203			; Jump if below
		jz	loc_202			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_205

loc_202:
		mov	ah,0FCh
		jmp	short loc_205

loc_203:
		mov	ah,0F0h
		jmp	short loc_205

loc_204:
		mov	ah,0C0h

loc_205:
		push	ax
		mov	dx,3CEh
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		pop	ax
		jcxz	loc_208			; Jump if cx=0
		dec	cx
		jcxz	loc_207			; Jump if cx=0
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:anim_phase
		xchg	es:[di],al
		inc	di
		mov	al,0FFh
		out	dx,al			; port 3CFh, EGA graphic func

fill_wide_center_loop:
							mov	al,ds:anim_phase
							xchg	es:[di],al
							inc	di
							loop	fill_wide_center_loop		; Loop if cx > 0

		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:anim_phase
		xchg	es:[di],al
		retn

loc_207:
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:anim_phase
		xchg	es:[di],al
		inc	di
		mov	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:anim_phase
		xchg	es:[di],al
		retn

loc_208:
		and	al,ah
		out	dx,al			; port 3CFh, EGA graphic func
		mov	al,ds:anim_phase
		xchg	es:[di],al
		retn

ega_fill_bit_range_wide		endp

ega_row_addr_calc		proc	near
		mov	ah,50h			; 'P'
		mul	ah			; ax = reg * al
		mov	di,46Ch
		add	di,ax
		retn

ega_row_addr_calc		endp

frame_wait_loop		proc	near
		mov	cl,ds:anim_speed
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al

loc_209:
							push	ax
							call	word ptr cs:[110h]
							call	word ptr cs:[112h]
							call	word ptr cs:[114h]
							call	word ptr cs:[116h]
							call	word ptr cs:[118h]
							pop	ax
							cmp	ds:gvar_frame_timer,al
							jb	loc_209			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

frame_wait_loop		endp

; Dispatch handler: clear HUD area ?-- fills 8 columns ?? 0x12 rows ?? 0x38 bytes
; with value 2 using EGA write mode 1 (data rotate 0x18) into hud_ofs region.

hud_clear:
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,1803h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	di,hud_ofs
		mov	cx,8

hud_col_loop:
							push	cx
							push	di
							mov	cx,12h

hud_row_loop:
												push	cx
												push	di
												mov	cx,38h

hud_fill_loop:
												mov	al,2
												xchg	es:[di],al
												inc	di
												loop	hud_fill_loop		; Loop if cx > 0

												pop	di
												add	di,280h
												pop	cx
												loop	hud_row_loop		; Loop if cx > 0

							pop	di
							add	di,ega_plane_row
							pop	cx
							loop	hud_col_loop		; Loop if cx > 0

		mov	dx,3CEh
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		retn

; Dispatch handler: compute EGA DI from packed row (AL bits 0..5) and col (AH) values.
; DI = (row * ega_2row_stride) + (col - 4)*2 + hud_ofs.

sprite_vga_pos_calc:
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,280h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,46Ch
		retn

; Dispatch handler: background layer copy ?-- copies 0x480 bytes from bg_copy_tbl[ds:[9Dh]-1]
; into bg_copy_dst using DS:2000h segment.

bg_copy_update:
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jnz	loc_213			; Jump if not zero
		retn

loc_213:
		cmp	bl,7
		jne	loc_214			; Jump if not equal
		retn

loc_214:
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		push	ds
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,bg_copy_dst
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn

si_wrap_hi		proc	near
		cmp	si,0E900h
		jae	loc_215			; Jump if above or =
		retn

loc_215:
		sub	si,900h
		retn

si_wrap_hi		endp

; Companion to si_wrap_hi: wraps SI upward (if SI < 0xE000, advance by 0x900).

si_wrap_lo:
		cmp	si,0E000h
		jb	loc_216			; Jump if below
		retn

loc_216:
		add	si,900h
		retn

; Dispatch handler: draw UI tile row from bg_tile_src into ui_ofs region.
; Reads 5 rows ?? 0x1C tiles, blitting each 8-row tile via EGA bit-mask register.

draw_ui_tiles:
		push	si
		push	ds
		mov	si,bg_tile_src
		mov	di,ui_ofs
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,5

ui_tile_row_loop:
							push	cx
							mov	cx,1Ch

ui_tile_col_loop:
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
												add	ax,sprite_gfx_base
												mov	si,ax
												push	di
												mov	cx,8

ui_tile_pixel_loop:
												lodsb				; String [si] to al
												out	dx,al			; port 3CFh, EGA graphic func
												mov	al,2
												xchg	es:[di],al
												inc	di
												lodsb				; String [si] to al
												out	dx,al			; port 3CFh, EGA graphic func
												mov	al,2
												xchg	es:[di],al
												add	di,4Fh
												loop	ui_tile_pixel_loop		; Loop if cx > 0

												pop	di
												inc	di
												inc	di
												pop	si
												pop	ds
												pop	cx
												loop	ui_tile_col_loop		; Loop if cx > 0

							add	di,248h
							pop	cx
							loop	ui_tile_row_loop		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		pop	si
		retn

; Tile index lookup table ?-- 4 rows of tile graphic indices, used by draw_ui_tiles.
; Each row is a sequence of sprite indices for the 5-row ?? 28-column UI tile grid.

ui_tile_idx_tbl:
; 4 rows of tile indices for the 5-row x 28-column UI tile grid (draw_ui_tiles).
; Sourcer encodes printable bytes as ASCII chars; all values are tile sprite indices.
		db	 00h, 01h, 02h, 04h, 07h, 09h	; row 0 tile indices [0..5]
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch	; row 0 tile indices [6..11]
		db	 1Eh, 04h, 07h, 09h, 22h, 02h	; row 0 tile indices [12..17]
		db	 25h, 08h, 02h, 28h, 02h, 2Dh	; row 0 tile indices [18..23]
		db	 31h, 36h, 3Bh, 40h, 00h, 01h	; row 0 [24..27] + row 1 [0..1]
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h	; row 1 tile indices [2..7]
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h	; row 1 tile indices [8..13]
		db	8, 0Ah, '#$'			; row 1 [14..17] (Sourcer ASCII encoding)
		db	'&', 8, 27h, ')*'		; row 1 [18..23]
		db	 04h, 32h, 37h, 3Ch, 06h, 00h	; row 1 [24..27] + row 2 [0..1]
		db	 01h, 02h, 05h, 08h, 02h, 0Eh	; row 2 tile indices [2..7]
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh	; row 2 tile indices [8..13]
		db	 04h, 08h, 02h, 23h, 24h, 26h	; row 2 [14..19]
		db	 08h, 25h, 29h, 02h, 2Eh, 33h	; row 2 [20..25]
		db	 38h, 3Dh, 06h, 00h, 01h, 03h	; row 2 [26..27] + row 3 [0..3]
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h	; row 3 tile indices [4..9]
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h	; row 3 [10..15]
		db	 0Bh				; row 3 [16]
		db	'#$'				; row 3 [17..18]
		db	'&', 8, 27h, ')+/49>'		; row 3 [19..27]
		db	 06h, 00h, 01h, 02h, 04h, 08h	; row 4 tile indices [0..5]
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh	; row 4 [6..11]
		db	 1Dh				; row 4 [12]
		db	' !', 8, 0Ch, '#$'		; row 4 [13..18]
		db	'&', 8				; row 4 [19..20]
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah	; row 4 [21..26]
; Inline init code: mov [anim_phase],al; mov si,0x48E5; mov [vga_row_ptr],hud_ofs; mov cx,0x12
; Followed by bg_tile_row_loop ?-- called as part of bg tile blit dispatch.

bg_tile_blit_init:
		aas				; (header byte; harmless side effect on AL)
		push	es
		mov	ds:[anim_phase],al
		mov	si,48E5h		; bg tile index table source
		mov	word ptr ds:[vga_row_ptr],046Ch
		mov	cx,12h			; 18 tile rows
		; falls through to bg_tile_row_loop

bg_tile_row_loop:
							push	cx
							mov	cx,1Ch

bg_tile_col_loop:
												push	cx
												lodsb				; String [si] to al
												push	si
												call	ega_bg_tile_blit
												pop	si
												add	word ptr ds:vga_row_ptr,2
												pop	cx
												loop	bg_tile_col_loop		; Loop if cx > 0

							add	word ptr ds:vga_row_ptr,248h
							pop	cx
							loop	bg_tile_row_loop		; Loop if cx > 0

		retn

ega_bg_tile_blit		proc	near
		push	ds
		mov	cl,sprite_data_stride
		mul	cl			; ax = reg * al
		add	ax,sprite_src_base
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:vga_row_ptr
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,offset ega_row_ofs
		mov	cx,4

bg_plane_copy_loop:
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							dec	di
							dec	di
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							add	di,bx
							mov	al,1
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 3C5h, EGA sequencr func
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							dec	di
							dec	di
							mov	al,4
							out	dx,al			; port 3C5h, EGA sequencr func
							movsw				; Mov [si] to es:[di]
							add	di,bx
							loop	bg_plane_copy_loop		; Loop if cx > 0

		mov	al,7
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	dx,3CEh
		mov	ax,0A05h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	bl,cs:anim_phase
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr cs:copy_fn_tbl[bx]	;*
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		mov	ax,0F02h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 2, color compare bits
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		pop	ds
		retn

ega_bg_tile_blit		endp

; ega_plane_mode_dispatch -- multi-entry EGA color plane/mode selector.
; Called via external dispatch (copy_fn_tbl or similar) with DX=3C4h (EGA sequencer),
; BL=plane mask. Selects MapMask register value and calls ega_col_write_loop.
; 10-byte entry-point header (0x1860-0x1869): branch targets for each EGA mode;
; decoded as code but they are dispatch offsets / jump-pad bytes.
; Each mode entry: mov ax,(seq_index<<8|map_mask); out dx,ax; mov bl,color; call/jmp ega_col_write_loop

ega_plane_mode_dispatch:
		db	 66h, 48h		; dec eax (32-bit prefix pad / dispatch header byte 0)
		db	 77h, 48h		; ja +0x48 -> entry 7 (dispatch header byte 1)
		db	 7Fh, 48h		; jg +0x48 -> entry 8 (dispatch header byte 2)
		db	 90h, 48h		; nop; dec ax  (dispatch header bytes 3-4)
		db	0AAh, 48h		; stosb; dec ax (dispatch header bytes 5-6: pad to entry 0)
					; -- Entry 0: MapMask=0x06, color=3
		mov	ax,0602h		; seq idx=2, map=6 (planes 1+2)
		out	dx,ax
		mov	bl,3
		call	ega_col_write_loop
					; -- Entry 1: MapMask=0x07, color=5
		mov	ax,0702h		; map=7 (all planes)
		out	dx,ax
		mov	bl,5
		jmp	short ega_col_write_loop
					; -- Entry 2: MapMask=0x04, color=2
		mov	ax,0402h		; map=4 (plane 2)
		out	dx,ax
		mov	bl,2
		jmp	short ega_col_write_loop
					; -- Entry 3: MapMask=0x04, color=5
		mov	ax,0402h
		out	dx,ax
		mov	bl,5
		call	ega_col_write_loop
					; -- Entry 4: MapMask=0x07, color=4
		mov	ax,0702h
		out	dx,ax
		mov	bl,4
		jmp	short ega_col_write_loop
					; -- Entry 5: MapMask=0x04, color=3
		mov	ax,0402h
		out	dx,ax
		mov	bl,3
		call	ega_col_write_loop
					; -- Entry 6: MapMask=0x07, color=5
		mov	ax,0702h
		out	dx,ax
		mov	bl,5
		call	ega_col_write_loop
					; -- Entry 7 (ja target): MapMask=0x06, color=7
		mov	ax,0602h
		out	dx,ax
		mov	bl,7
		jmp	short ega_col_write_loop
					; -- Entry 8 (jg target): MapMask=0x07, color=5
		mov	ax,0702h
		out	dx,ax
		mov	bl,5
		call	ega_col_write_loop
					; -- Entry 9: MapMask=0x04, color=7
		mov	ax,0402h
		out	dx,ax
		mov	bl,7
		call	ega_col_write_loop
					; -- Entry 10: MapMask=0x06, color=4 (falls into ega_col_write_loop)
		mov	ax,0602h
		out	dx,ax
		mov	bl,4
		jmp	short ega_col_write_loop	; assembles as EB 00 (fall-through)

ega_col_write_loop		proc	near

loc_223:
		mov	si,cs:vga_row_ptr
		mov	di,4Fh
		mov	al,8
		mov	cx,8

col_write_row_loop:
							mov	ah,es:[si]
							out	dx,ax			; port 0, DMA-1 bas&add ch 0
							mov	es:[si],bl
							inc	si
							mov	ah,es:[si]
							out	dx,ax			; port 0, DMA-1 bas&add ch 0
							mov	es:[si],bl
							add	si,di
							loop	col_write_row_loop		; Loop if cx > 0

		retn

ega_col_write_loop		endp

; Animation sequence table ?-- frame index pairs for sprite animation cycles.
; Sourcer decodes these bytes as code; they are data accessed via CS-relative pointer.

anim_seq_tbl:					; 70 bytes of frame index data — Sourcer mis-decoded as code
		db	 07h, 08h, 09h, 0Ah, 07h, 08h, 0Bh, 0Ch, 07h, 08h
		db	 09h, 0Ah, 19h, 3Dh, 61h, 27h, 1Dh, 1Eh, 1Dh, 1Eh
		db	 1Fh, 20h, 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h, 0Dh, 0Eh
		db	 0Fh, 10h, 0Fh, 10h, 0Dh, 0Eh, 0Fh, 10h, 17h, 18h
		db	 3Eh, 5Ch, 62h, 26h, 2Ah, 25h, 21h, 22h, 21h, 22h
		db	 23h, 24h, 21h, 22h, 21h, 22h, 09h, 0Ah, 07h, 08h
		db	 07h, 08h, 09h, 0Ah, 07h, 08h, 19h, 54h, 59h, 5Dh
		db	 63h, 32h, 2Fh, 2Eh, 1Fh, 20h	; anim frame index pairs (continued from above mnemonics)
		db	 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h	;  (cont.)
		db	 1Fh, 20h, 0Fh, 10h, 11h, 12h	;  (cont.)
		db	 0Fh, 10h, 0Dh, 0Eh, 17h, 18h	;  (cont.)
		db	'PUZ^df(0#$'				; frame indices as ASCII (Sourcer mixed encoding)
		db	'!"#$'					;  (cont.)
		db	'!"#$'					;  (cont.)
		db	 07h, 08h, 0Ah, 0Ch, 07h, 08h	;  (cont.)
		db	 09h, 0Ah, 1Ah				;  (cont.)
		db	'4QV[_eg/-'				; (cont.)
		db	 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh	;  (cont.)
		db	 1Fh, 20h, 1Dh, 1Eh, 0Fh, 10h	;  (cont.)
		db	 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h	;  (cont.)
		db	 49h, 4Dh, 52h, 57h, 00h		; (cont.)
		db	'`ihjk(&!"+&!"!"'			; (cont.)
		db	7					; (cont.)
		db	8, 9, 0Ah, 9, 0Ah, 1Bh, 'FJNSX'	; (cont.)
		db	 00h, 00h, 00h, 00h, 69h, 6Ch		; (cont.)
		db	 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh	;  (cont.)
		db	 1Fh, 20h, 1Fh, 20h, 13h, 14h	;  (cont.)
		db	 13h, 14h, 17h, 18h			;  (cont.)
		db	 43h, 47h, 4Bh, 4Fh			;  (cont.)
		db	7 dup (0)				;  padding
		db	'mno)&!"*%!"'				;  (cont.)
		db	 15h, 16h, 15h, 16h, 1Ch		;  (cont.)
		db	 35h, 44h, 48h, 4Ch			;  (cont. anim_seq_tbl end)
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
; EGA animation plane pair table -- pairs of (plane_A, plane_B) frame indices for animation.
; Values 0x01/0x02, 0x03/0x04, 0x05/0x06 = EGA plane bitmask pair indices for each cycle.
		db	 01h, 02h, 01h, 02h, 01h, 02h	; plane pair entries (pair 0: planes 1/2)
		db	 01h, 02h, 01h, 02h, 01h, 02h	;  (cont.)
		db	 01h, 02h, 01h, 02h, 01h, 02h	;  (cont.)
		db	 01h, 02h, 01h, 02h, 03h, 04h	;  (cont. + pair 1: planes 3/4)
		db	 03h, 04h, 03h, 04h, 03h, 04h	;  (cont.)
		db	 03h, 04h, 03h, 04h, 03h, 04h	;  (cont.)
		; Character encoding table (continued)
		db	'/-367<', 0		; 0x0000
		db	 03h, 04h, 05h, 06h, 05h, 06h	; plane pair entries (pair 2: planes 5/6)
		db	 05h, 06h, 05h, 06h, 05h, 06h	;  (cont.)
		db	 05h, 06h, 05h, 06h, 05h, 06h	;  (cont.)
		db	 05h, 06h, 05h, 06h, 05h, 06h	;  (cont.)
		db	 06h, 05h, 05h, 06h, 05h, 06h	;  (cont. last entries)

; plane_blit_init -- setup for plane_1_2_blit_loop.
; Computes sprite source SI from AL (sprite index) * 0x20 + 0x6000 (game_seg sprite base),
; and sprite dest DI from BH (row) * 0x50 + BL (col) offset into EGA framebuffer.
; Sets DS=game_seg, ES=EGA segment, DX=3C4h (EGA sequencer), BX=0x4E (stride), CX=4.

plane_blit_init:
		push	ds
		push	ax
		mov	ax,50h			; DI = BH*0x50 + BL
		mul	bl			; ax = col * 0x50
		mov	bl,bh			; bx = row
		xor	bh,bh			; zero high byte
		add	ax,bx			; ax = col*0x50 + row
		mov	di,ax			; DI = EGA row/col offset
		pop	ax
		mov	cl,20h			; ' '
		mul	cl			; ax = sprite_idx * 0x20
		add	ax,6000h		; + game_seg sprite base offset
		mov	si,ax			; SI = sprite source ptr
		mov	ds,cs:game_seg		; DS = game segment
		mov	ax,0A000h
		mov	es,ax			; ES = EGA framebuffer
		mov	dx,3C4h			; EGA sequencer index port
		mov	al,2			; map mask register
		out	dx,al			; select map mask
		inc	dx			; DX = 3C5h (EGA sequencer data)
		mov	bx,4Eh			; stride = 0x4E (plane row - 2)
		mov	cx,4			; 4 planes

plane_1_2_blit_loop:
							mov	al,1
							out	dx,al			; port 0, DMA-1 bas&add ch 0
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 0, DMA-1 bas&add ch 0
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							add	di,bx
							mov	al,1
							out	dx,al			; port 0, DMA-1 bas&add ch 0
							movsw				; Mov [si] to es:[di]
							mov	al,2
							out	dx,al			; port 0, DMA-1 bas&add ch 0
							lodsw				; String [si] to ax
							mov	es:[di-2],ax
							add	di,bx
							loop	plane_1_2_blit_loop		; Loop if cx > 0

		pop	ds
		retn

; Dispatch handler: draw hero graphics from hero_gfx_tbl[ds:[92h]-1] into vga_buf_ofs.
; Writes 0x18 rows ?? 4 bytes using EGA bit-mask register with plane 1.

draw_hero_gfx:
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:hero_gfx_tbl[bx]
		mov	di,vga_buf_ofs
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	ax,702h
		out	dx,ax			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3CEh
		mov	ax,205h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	al,8
		out	dx,al			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		inc	dx
		mov	cx,18h

hero_gfx_row_loop:
							lodsb				; String [si] to al
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di],al
							inc	di
							lodsb				; String [si] to al
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di],al
							inc	di
							lodsb				; String [si] to al
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di],al
							inc	di
							lodsb				; String [si] to al
							out	dx,al			; port 3CFh, EGA graphic func
							mov	al,1
							xchg	es:[di],al
							add	di,4Dh
							loop	hero_gfx_row_loop		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		pop	ds
		retn

; Sprite shape/gradient data table ?-- accessed via CS-relative pointer for
; fade_gradient_loop and ega_fill_bit_range operations. Sourcer decodes as code.

sprite_shape_tbl:				; 12-byte header + 45 zero-pad — Sourcer mis-decoded as code
		db	 94h, 4Bh, 94h, 4Bh, 94h, 4Bh	; header pair pattern
		db	0F4h, 4Bh,0F4h, 4Bh, 54h, 4Ch	; header pair pattern (cont.)
		db	45 dup (0)			; padding / zero-pad before shape group A
; sprite_shape_tbl shape group A (small diamond, left-aligned):
		db	 02h, 00h, 00h, 00h, 06h, 00h	; rows 0-1 (plane bitmasks)
		db	 00h, 00h, 06h, 00h, 00h, 00h	; rows 2-3
		db	 0Eh, 00h, 00h, 00h, 0Eh, 00h	; rows 4-5
		db	 00h, 00h, 0Ch, 00h, 00h, 00h	; rows 6-7
		db	 0Eh, 00h, 00h, 00h, 1Ch, 00h	; rows 8-9
		db	 00h, 00h, 0Ch, 00h, 00h, 00h	; rows 10-11
		db	 1Ch, 00h, 00h, 00h, 1Ch, 00h	; rows 12-13
		db	 00h, 00h, 1Ch, 00h, 00h, 00h	; rows 14-15
		db	 1Ch				;  last byte
		db	16 dup (0)			; padding between shape groups
; sprite_shape_tbl shape group B (larger diamond, right-aligned):
		db	 80h, 00h, 00h, 01h, 80h, 00h	; rows 0-1
		db	 00h, 03h, 80h, 00h, 00h, 03h	; rows 2-3
		db	 00h, 00h, 00h, 07h, 80h, 00h	; rows 4-5
		db	 00h, 07h, 00h, 00h, 00h, 07h	; rows 6-7
		db	 00h, 00h, 00h, 0Fh, 00h, 00h	; rows 8-9
		db	 00h, 0Eh, 00h, 00h, 00h, 0Fh	; rows 10-11
		db	 00h, 00h, 00h, 1Eh, 00h, 00h	; rows 12-13
		db	 00h, 0Eh, 00h, 00h, 00h, 1Fh	; rows 14-15
		db	 00h, 00h, 00h, 1Eh, 00h, 00h	; rows 16-17
		db	 00h, 1Fh, 00h, 00h, 00h, 1Eh	; rows 18-19
		db	 00h, 00h, 00h, 1Eh, 00h, 00h	; rows 20-21
		db	 00h, 1Eh, 00h, 00h, 00h, 1Eh	; rows 22-23
		db	 00h, 00h, 00h, 1Ch, 00h, 00h	; rows 24-25
		db	 00h				;  last byte
		db	3Fh				;  sentinel byte (0x3F)
		db	12 dup (0)			; padding between shape groups
; sprite_shape_tbl shape group C (asymmetric diamond):
		db	 40h, 00h, 00h, 00h,0C0h, 00h	; rows 0-1
		db	 00h, 01h,0C0h, 00h, 00h, 03h	; rows 2-3
		db	 80h, 00h, 00h, 03h, 80h, 00h	; rows 4-5
		db	 00h, 07h, 80h, 00h, 00h, 07h	; rows 6-7
		db	 00h, 00h, 00h, 07h, 00h, 00h	; rows 8-9
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh	; rows 10-11
		db	 00h, 00h, 00h, 0Eh, 00h, 00h	; rows 12-13
		db	 00h, 1Fh, 00h, 00h, 00h, 0Eh	; rows 14-15
		db	 00h, 00h, 00h, 1Fh, 00h, 00h	; rows 16-17
		db	 00h, 1Eh, 00h, 00h, 00h, 1Fh	; rows 18-19
		db	 00h, 00h, 00h, 1Eh, 00h, 00h	; rows 20-21
		db	 00h, 1Fh, 00h, 00h, 00h, 1Fh	; rows 22-23
		db	 00h, 00h, 00h, 1Eh, 00h, 00h	; rows 24-25
		db	 03h, 1Ch,0C0h, 00h, 00h,0FFh	; row 26 (last shape entry) + 0xFF sentinel
; shift_blit_setup -- sets up SI and BP for the shift-blit render path based on AL
; (sprite type/index). Two entry paths merge at shift_blit_src_set; falls into
; shift_blit_outer_loop.
;
; Dead code: searched all 137 zelres1/2/3 binaries for the byte sequence "33 1C"
; (LE for offset 0x1C33) — zero matches. No caller stores this address as a
; function pointer or near-call target. Likely leftover from an earlier driver
; version (the CGA variant 203GFCGA has the same structural pattern at this offset).

shift_blit_setup:
		db	 00h, 00h		; 2-byte alignment header (decodes as 'add [bx+si],al'; harmless)
		push	ds
		or	al,al			; test sign of sprite type byte
		js	shift_blit_neg		; if negative → type-B path (signed sprite)
		and	al,3			; mask to 2-bit index (0-3)
		mov	dl,40h			; multiplier = 64
		mul	dl			; ax = al * 0x40 (type-A sprite table stride)
		add	ax,4D5Ah		; + type-A sprite table base (CS:0x4D5A)
		mov	si,ax			; SI = sprite source ptr (type-A)
		mov	bp,1			; BP = 1 plane pass
		jmp	short shift_blit_src_set ; skip type-B path
shift_blit_neg:
		and	al,1			; mask to 1-bit index (0-1)
		mov	ah,al			; AH = index
		xor	al,al			; AL = 0 → AX = index * 256
		add	ax,4E5Ah		; + type-B sprite table base (CS:0x4E5A)
		mov	si,ax			; SI = sprite source ptr (type-B)
		mov	bp,4			; BP = 4 plane passes
shift_blit_src_set:
		mov	al,bl			; AL = BL (X column byte)
		and	al,3			; mask to pixel-in-byte position (0-3)
		add	al,al			; double → shift amount (0,2,4,6)
		mov	byte ptr ds:shift_count,al
		shr	bx,1			; BX >>= 1 (byte address x/8 step 1)
		shr	bx,1			; BX >>= 1 (byte address x/8 step 2 → x/4 col byte)
		mov	al,50h			; row stride = 80 bytes
		mul	cl			; ax = row * 80
		add	ax,bx			; + col byte → VGA byte offset
		mov	di,ax			; DI = VGA framebuffer destination offset
		mov	ax,0A000h
		mov	es,ax			; ES = EGA framebuffer segment
		mov	dx,3C4h			; EGA sequencer index port
		mov	ax,702h			; AH=7 (write mode), AL=2 (map mask register)
		out	dx,ax			; write map mask + mode
		mov	dx,3CEh			; EGA graphics controller index port
		mov	ax,205h			; AH=2 (read mode 0+write mode 2), AL=5 (mode reg)
		out	dx,ax			; write graphics mode
		mov	al,8			; AL=8 (bit mask register index)
		out	dx,al			; select bit mask register
		inc	dx			; DX = 3CFh (EGA graphics controller data)
		mov	cx,bp			; CX = plane pass count (1 or 4)
		mov	bp,4Ch			; BP = 0x4C = 76 byte stride (EGA row advance)
shift_blit_outer_loop:
							push	cx
							push	di
							mov	cx,10h

shift_blit_mid_loop:
												push	cx
												mov	cx,2

shift_blit_inner_loop:
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
												mov	al,bh
												out	dx,al			; port 0, DMA-1 bas&add ch 0
												mov	al,1
												xchg	es:[di],al
												inc	di
												mov	al,bl
												out	dx,al			; port 0, DMA-1 bas&add ch 0
												mov	al,1
												xchg	es:[di],al
												inc	di
												mov	al,ah
												out	dx,al			; port 0, DMA-1 bas&add ch 0
												mov	al,1
												xchg	es:[di],al
												pop	cx
												loop	shift_blit_inner_loop		; Loop if cx > 0

												add	di,bp
												pop	cx
												loop	shift_blit_mid_loop		; Loop if cx > 0

							pop	di
							add	di,4
							pop	cx
							loop	shift_blit_outer_loop		; Loop if cx > 0

		dec	dx
		mov	ax,5
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		mov	ax,0FF08h
		out	dx,ax			; port 0FFFFh ??I/O Non-standard
		pop	ds
		retn

; shift_blit sprite shape tables (0x1CDB-end):
; EGA 4-byte bitmask rows for shift_blit rendering. Each 4-byte entry = one pixel row:
; bytes 0-1 = EGA plane 0/1 bitmask pair, bytes 2-3 = plane 2/3 bitmask pair.
; Multiple shape groups separated by zero-padding. Used by shift_blit_outer_loop via SI+table.

shift_blit_shape_tbl:
		db	22 dup (0)			; leading zero-pad (group 0 empty)
		db	 10h, 00h, 00h, 10h, 60h, 00h	; shape group 1 rows
		db	 00h, 07h,0C0h, 00h, 00h, 07h	;  (group 1 cont.)
		db	0C0h, 00h, 00h, 07h,0C0h, 00h	;  (group 1 cont.)
		db	 00h, 0Ch, 10h, 00h, 00h, 10h	;  (group 1 cont.)
		db	 00h				;  (group 1 last byte)
		db	26 dup (0)			; padding between groups
		db	 01h, 00h, 00h, 00h, 01h, 00h	; shape group 2 rows
		db	 00h, 00h, 40h, 04h, 00h, 00h	;  (cont.)
		db	 01h, 00h, 00h, 00h, 09h, 20h	;  (cont.)
		db	 00h, 00h, 03h, 80h, 00h, 04h	;  (cont.)
		db	 57h,0D4h, 80h, 00h, 03h, 80h	;  (cont.)
		db	 00h, 00h, 09h, 20h, 00h, 00h	;  (cont.)
		db	 01h, 00h, 00h, 00h, 40h, 04h	;  (cont.)
		db	 00h, 00h, 01h, 00h, 00h, 00h	;  (cont.)
		db	 01h				;  (group 2 last byte)
		db	7 dup (0)			; padding between groups
		db	 01h, 00h, 00h, 00h, 01h, 00h	; shape group 3 rows
		db	 00h, 00h, 01h, 00h, 00h, 00h	;  (cont.)
		db	 02h, 80h, 00h, 00h, 83h, 80h	;  (cont.)
		db	 00h, 00h, 23h, 88h, 00h, 00h	;  (cont.)
		db	 0Dh,0B0h, 00h, 00h, 0Bh,0E8h	;  (cont.)
		db	 00h, 96h,0FFh,0FFh,0B9h, 00h	;  (cont.)
		db	 17h,0E8h, 00h, 00h, 0Bh, 58h	;  (cont.)
		db	 00h, 00h, 23h, 82h, 00h, 00h	;  (cont.)
		db	 02h, 80h, 80h, 02h, 01h, 00h	;  (cont.)
		db	 00h, 00h, 01h, 00h, 00h, 00h	;  (cont.)
		db	 01h, 00h			;  (group 3 last bytes)
		db	8 dup (0)			; padding between groups
		db	 10h, 10h, 00h, 00h, 00h, 04h	; shape group 4 rows
		db	 00h, 00h, 80h, 00h, 80h, 03h	;  (cont.)
		db	 00h, 00h, 71h, 0Ch, 00h, 00h	;  (cont.)
		db	 3Dh, 38h, 00h, 00h, 07h,0F0h	;  (cont.)
		db	 00h, 00h, 97h,0E5h, 00h, 00h	;  (cont.)
		db	 0Fh,0F0h, 00h, 00h, 1Fh, 38h	;  (cont.)
		db	 00h, 00h, 39h, 0Eh, 00h, 00h	;  (cont.)
		db	0E1h, 01h, 80h, 01h, 00h, 00h	;  (cont.)
		db	 40h, 04h, 00h, 00h, 08h, 10h	;  (group 4 last row)
		db	35 dup (0)			; padding between groups
		db	 92h, 4Ah,0AAh,0EBh, 00h	; single-row sentinel entry + 1 byte
		db	34 dup (0)			; padding between groups
		db	 01h, 00h, 00h, 00h, 01h, 00h	; shape group 5 rows
		db	 00h, 01h, 01h, 00h, 00h, 00h	;  (cont.)
		db	 82h, 00h, 00h, 00h,0ABh, 00h	;  (cont.)
		db	 00h, 01h, 5Dh, 04h, 24h,0AEh	;  (cont.)
		db	0EFh,0FFh,0FFh,0FFh,0FFh, 04h	;  (cont.)
		db	 24h,0ABh,0EFh, 00h, 00h, 01h	;  (cont.)
		db	 5Dh, 00h, 00h, 00h, 22h, 00h	;  (cont.)
		db	 00h, 00h, 81h, 00h, 00h, 00h	;  (cont.)
		db	 01h, 00h, 00h, 00h, 01h, 00h	;  (group 5 last row)
		db	19 dup (0)			; padding between groups
		db	 81h, 00h, 00h, 00h,0C4h, 00h	; shape group 6 rows
		db	 00h, 00h,0BCh, 00h, 00h, 00h	;  (cont.)
		db	0EEh,0EAh, 24h, 20h,0FFh,0FFh	;  (cont.)
		db	0FFh,0FFh,0FBh,0AAh, 24h, 20h	;  (cont.)
		db	0FDh, 40h, 00h, 00h,0E6h, 00h	;  (cont.)
		db	 00h, 00h, 40h, 80h, 00h, 00h	;  (cont.)
		db	 00h				;  (group 6 last byte)
		db	20h				; single marker byte (0x20)
		db	42 dup (0)			; padding
		db	0D7h, 55h, 52h, 49h		; marker bytes (0xD7,'U','R','I')
		db	60 dup (0)			; padding
		db	0A7h, 54h, 90h, 04h, 00h	; marker bytes
		db	37 dup (0)			; padding
		db	 10h, 00h, 00h, 00h, 04h, 00h	; shape group 7 rows (4-byte stride)
		db	 00h, 00h, 00h, 80h, 00h, 00h	;  (cont.)
		db	 00h, 71h, 00h, 00h, 00h, 3Dh	;  (cont.)
		db	 00h, 00h, 00h, 07h, 10h, 04h	;  (cont.)
		db	 00h, 97h, 00h, 00h, 00h, 0Fh	;  (cont.)
		db	 00h, 00h, 00h, 1Fh, 00h, 00h	;  (cont.)
		db	 00h, 39h, 00h, 00h, 00h,0E1h	;  (cont.)
		db	 00h, 00h, 01h, 00h, 00h, 00h	;  (cont.)
		db	 04h, 00h, 00h, 00h, 10h, 00h	;  (cont.)
		db	 00h, 00h, 00h, 00h, 00h, 10h	;  (group 7 last row)
		db	7 dup (0)			; padding
		db	 80h, 00h, 00h, 03h, 00h, 00h	; shape group 8 rows
		db	 00h, 0Ch, 00h, 00h, 00h, 38h	;  (cont.)
		db	 00h, 00h, 00h,0F0h, 00h, 00h	;  (cont.)
		db	 00h,0E5h, 02h, 00h, 10h,0F0h	;  (cont.)
		db	 00h, 00h, 00h, 3Ch, 00h, 00h	;  (cont.)
		db	 00h, 07h, 00h, 00h, 00h, 00h	;  (cont.)
		db	0C0h, 00h, 00h, 00h, 20h, 00h	;  (cont.)
		db	 00h, 00h, 04h			;  (group 8 last byte)
		db	38 dup (0)			; trailing padding
		db	 20h, 09h, 2Ah,0E5h		; epilog marker bytes
		db	28 dup (0)			; padding
		db	 01h, 02h, 02h, 04h, 01h, 04h	; EGA plane pair table (shift_blit plane seq)
		db	 05h, 06h, 06h, 05h, 05h, 06h	;  (cont.)
		db	0C3h				; retn (function epilog / table terminator)
		db	304 dup (0)			; end-of-segment zero padding

seg_a		ends

		end	start
