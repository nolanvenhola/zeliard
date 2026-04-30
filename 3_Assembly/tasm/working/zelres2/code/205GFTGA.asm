
PAGE  59,132

;==========================================================================
;
;  205GFTGA.BIN - Tandy Graphics Fill Driver (zelres2 chunk 5)
;
;  Tandy 1000 (TGA) graphics variant of the battle/gameplay sprite-fill
;  driver. Renders sprites, tiles, scrolling backgrounds, and hero/enemy
;  graphics for Tandy's 16-color 320x200 mode. Parallels 202GFEGA in
;  structure (same dispatch table layout, same drv_init_stub patchable
;  byte, same sprite-scan loop).
;
;  Connections:
;    Loads:        none -- driver is resident; sprite/tile data staged by
;                  200FIGHT into game_seg buffers (sprite_src_base at
;                  0B000h, pattern_buf_d000 at 0D000h, tga_buf_8cf0).
;    Calls into:   ds:dispatch_tbl[bx] (game-DS animation handler table);
;                  cs:copy_fn_tbl entries (Tandy plane copy variants);
;                  internal frame_row_driver / anim_refresh_all /
;                  projectile_spawn_check dispatchers; cs:[11Ah] -- driver
;                  fn (input/page advance); no cross-chunk calls outside
;                  its own driver fn table.
;    Called by:    200FIGHT (and 201SELCT) via the graphics-driver dispatch
;                    slots at cs:[2000h..303Ch] -- this module IS the Tandy
;                    driver. Loaded at game_seg:9000h by game.asm when
;                    gvar_gfx_mode selects Tandy. Entry via drv_init_stub
;                    at cs:[10Ch].
;    Reads/writes: sprite_src_base / plane_alt_b17e / pattern_buf_d000
;                    (DS:0B000h / 0B17Eh / 0D000h), tga_vram_wrap (80A0h),
;                    cur_color_pair + vga_row_ptr / scroll_vga_ofs /
;                    row_counter (CS-resident driver state at CS:522Fh+),
;                    Tandy 16-color framebuffer (port 3D8h/3D9h color regs,
;                    +80A0h vram wrap delta).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
tga_vram_wrap		equ	80A0h			;*
tga_buf_8cf0		equ	8CF0h			;*
sprite_src_base		equ	0B000h			;*
plane_alt_b17e		equ	0B17Eh			;*
pattern_buf_d000		equ	0D000h			;*
dispatch_tbl	equ	3172h			;*
pattern_ptr_tbl	equ	39E8h			;*
color_map_tbl	equ	4264h			;*
bg_tile_src	equ	4771h			;*
copy_fn_tbl	equ	489Dh			;*
hero_gfx_tbl	equ	4BFBh			;*
color_pair_tbl	equ	51D2h			;*
cur_color_pair	equ	522Fh			;*
vga_row_ptr	equ	5231h			;*
scroll_vga_ofs	equ	5233h			;*
scroll_src_ofs	equ	5235h			;*
scroll_gfx_ptr	equ	523Dh			;*
scroll_delta	equ	523Fh			;*
shift_count	equ	5244h			;*
sprite_row_buf	equ	5245h			;*
sprite_pos	equ	5259h			;*
sprite_cache_tbl	equ	5262h			;*
bg_save_buf	equ	5362h			;*
tga_sprite_buf	equ	5562h			;*
tga_decode_buf	equ	5682h			;*
tga_offs_723b	equ	723Bh			;*
tga_vram_wrap_b	equ	80A0h			;*
tga_vram_buf	equ	41F8h
tga_vram_wrap_c	equ	80A0h

; ----------------------------------------------------------------------
; Section 6: File-internal state variables
; ----------------------------------------------------------------------
row_counter	equ	5237h			;*
col_idx	equ	5238h			;*
row_idx	equ	5239h			;*
palette_byte	equ	523Ah			;*
bitmask_word	equ	523Bh			;*
mask_word	equ	5241h			;*
sprite_state_a	equ	5255h			;*
sprite_state_b	equ	5256h			;*

; ----------------------------------------------------------------------
; Section 7: Constants
; ----------------------------------------------------------------------
anim_frame_tbl	equ	3915h			;*
anim_phase	equ	5243h			;*
tga_row_stride	equ	0A0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gftga_main		proc	far

start:
		mov	byte ptr ds:[26h],al
		add	[si],ch
		xor	ds:tga_offs_723b,al
		inc	ax
		db	 7Fh, 3Fh		; (proc-header bytes; Sourcer decoded as 'jg' but no real target)
		mov	cx,9E42h
		inc	si
		sub	[bx+di+6Eh],ax
		xor	bl,[di]
		cmp	[bx+di],cx
		inc	bx
		db	 7Ah, 42h		; (proc-header bytes; Sourcer decoded as 'jp' but no real target)
                           lock	cmp	al,[bx+di+44h]
		mov	bx,546h
		inc	di
		std				; Set direction flag
		inc	di
		jo	loc_6			; Jump if overflow=1
		dec	bp
		dec	bx
		nop
		dec	bx
		daa				; Decimal adjust
		dec	bp
		call	$+2E53h
		push	dx
		push	cs
		pop	es
		mov	di,sprite_cache_tbl
		xor	ax,ax			; Zero register
		mov	cx,80h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
; drv_init_stub: label is at instruction start, opcode byte FEh patched by caller.

drv_init_stub:
		inc	byte ptr ds:anim_phase		; FE 06 43 52  (opcode byte patched by caller)
		mov	word ptr ds:vga_row_ptr,tga_vram_buf
		mov	si,ds:sprite_data_ptr
		sub	si,21h
; [0x004D-0x004F] call with mid-instruction label: tga_row_ofs labels the displacement bytes.
; Callers patch the displacement (tga_row_ofs) to redirect this call at runtime.
; Current target: 0050h + 16ADh = 16FDh (si_wrap_lo).
		db	0E8h				; call near opcode
tga_row_ofs	db	0ADh,16h			; displacement (patch target); initially calls 16FDh (si_wrap_lo)
		xor	bx,bx			; Zero register
		test	byte ptr [si],80h
		jz	init_scan_next			; Jump if zero
		call	sprite_slot_remove

init_scan_next:
		inc	si
		mov	cx,6

sprite_scan_loop:
				push	cx
				test	byte ptr [si],80h
				jz	loc_5			; Jump if zero
				call	sprite_slot_init

loc_5:
				inc	si

loc_6:
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
				inc	bx
				test	byte ptr [si],80h
				jz	loc_9			; Jump if zero
				call	sprite_slot_init

loc_9:
				inc	si
				inc	bx
				pop	cx
				loop	sprite_scan_loop		; Loop if cx > 0

		test	byte ptr [si],80h
		jz	loc_10			; Jump if zero
		call	sprite_slot_init

loc_10:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_11			; Jump if zero
		call	sprite_slot_init

loc_11:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	loc_12			; Jump if zero
		call	sprite_slot_init

loc_12:
		inc	si
		test	byte ptr [si],80h
		jz	row_scan_done			; Jump if zero
		call	sprite_blit_dispatch

row_scan_done:
		mov	si,ds:sprite_data_ptr
		mov	di,sprite_buf
		mov	byte ptr ds:row_counter,12h

row_render_loop:
				call	frame_row_driver
				xor	bx,bx			; Zero register
				add	si,3
				lodsb				; String [si] to al
				or	al,al			; Zero ?
				jns	loc_15			; Jump if not sign
				call	sprite_wide_row_render

loc_15:
				mov	cx,6

col_scan_loop:
						push	cx
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
						cmpsb				; Cmp [si] to es:[di]
						jz	loc_20			; Jump if zero
						call	sprite_state_update

loc_20:
						inc	bx
						pop	cx
						loop	col_scan_loop		; Loop if cx > 0

				cmpsb				; Cmp [si] to es:[di]
				jz	loc_21			; Jump if zero
				call	sprite_state_update

loc_21:
				inc	bx
				cmpsb				; Cmp [si] to es:[di]
				jz	loc_22			; Jump if zero
				call	sprite_state_update

loc_22:
				inc	bx
				cmpsb				; Cmp [si] to es:[di]
				jz	loc_23			; Jump if zero
				call	sprite_state_update

loc_23:
				inc	bx
				lodsb				; String [si] to al
				inc	di
				or	al,al			; Zero ?
				jns	row_advance			; Jump if not sign
				jmp	player_offscreen

row_advance:
				cmp	al,es:[di-1]
				je	row_advance_done			; Jump if equal
				call	sprite_state_update

row_advance_done:
				add	si,4
				call	si_wrap_hi
				add	word ptr ds:vga_row_ptr,140h
				dec	byte ptr ds:row_counter
				jnz	row_render_loop			; Jump if not zero
		retn

gftga_main		endp

sprite_state_update		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_26			; Jump if not sign
		jmp	sprite_neg_handler

loc_26:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_27			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_28

loc_27:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_28			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		call	tga_sprite_blit

loc_28:
		mov	al,ds:sprite_attr_b
		sub	al,5
		jnc	loc_29			; Jump if carry=0
		retn

loc_29:
		cmp	al,4
		jb	loc_30			; Jump if below
		retn

loc_30:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:dispatch_tbl[bx]	;*
		pop	bx
		retn

sprite_state_update		endp

; Dispatch handler 0: 2-frame cycle from base 0x1B (parallels EGA anim_cycle_2frame_1B).
; Reached via call word ptr ds:dispatch_tbl[bx]. Sourcer mis-decoded the entry preamble
; (0x0176..0x017C) as code; the real entry is at offset 0x017D after the preamble bytes.
; Preamble bytes are a shared-entry overlapping-instruction block (see EGA variant).

anim_cycle_2frame_1B:
		db	 7Ah, 31h		;  jp (shared-entry overlap trick; decoded as db)
		db	9Ah			;  call far opcode (part of overlap)
		dw	0D031h, 4E31h		;  far-call displacement bytes (part of overlap)
		xor	cl,ss:restore_pending[bp+si] ; 32 8A FF 44  (final shared-prologue bytes)
		sub	al,1Bh
		cmp	al,2
		jb	cycle_1B_active			; Jump if below
		retn

cycle_1B_active:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	cycle_1B_advance		; Jump if not zero
		retn

cycle_1B_advance:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn

; Dispatch handler 1: 6-frame bidirectional cycle from base 0x1D
; (parallels EGA anim_cycle_6frame_1D). Frames 0x1D..0x22.

anim_cycle_6frame_1D:
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	cycle_1D_active			; Jump if below
		retn

cycle_1D_active:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	cycle_1D_extended		; Jump if above or =
		or	al,al			; Zero ?
		jnz	cycle_1D_advance		; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	cycle_1D_advance		; Jump if zero
		retn

cycle_1D_advance:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn

cycle_1D_extended:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn

; Dispatch handler 2: 2-frame cycle from base 0x2C plus extended range
; (parallels EGA anim_cycle_2frame_2C). Handles frames 0x2C, 0x2D and
; 0x3E+ mapped through a lookup table.

anim_cycle_2frame_2C:
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	cycle_2C_extended		; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	cycle_2C_advance		; Jump if not zero
		retn

cycle_2C_advance:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn

cycle_2C_extended:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	cycle_2C_map		; Jump if below
		retn

cycle_2C_map:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	cycle_2C_commit		; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	cycle_2C_commit		; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	cycle_2C_commit		; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	cycle_2C_commit		; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	cycle_2C_commit		; Jump if equal
		sub	al,33h			; '3'
		jnc	cycle_2C_map_hi		; Jump if carry=0
		retn

cycle_2C_map_hi:
		mov	bl,0Eh
		cmp	al,2
		je	cycle_2C_commit		; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	cycle_2C_commit		; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	cycle_2C_commit		; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	cycle_2C_commit		; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	cycle_2C_commit		; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al

cycle_2C_commit:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	cycle_2C_write		; Jump if not zero
		retn

cycle_2C_write:
		mov	[si-1],bl
		retn

; Dispatch handler 3: 4-frame cycle from base 0x25 (parallels EGA anim_cycle_4frame_25).
; On odd anim_phase, advance frame mod 4.

anim_cycle_4frame_25:
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	cycle_25_active		; Jump if below
		retn

cycle_25_active:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	cycle_25_advance	; Jump if not zero
		retn

cycle_25_advance:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

tga_sprite_blit		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_45			; Jump if not zero
		jmp	loc_64

loc_45:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:sprite_cache_tbl[bx],0FFFFh
		jnz	loc_49			; Jump if not zero
		dec	al
		mov	ds:sprite_cache_tbl[bx],di
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,4

plane_blit_loop:
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				add	di,1FFCh
				cmp	di,8000h
				jb	loc_47			; Jump if below
				add	di,tga_vram_wrap_c

loc_47:
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				add	di,1FFCh
				cmp	di,8000h
				jb	loc_48			; Jump if below
				add	di,tga_vram_wrap_c

loc_48:
				loop	plane_blit_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_49:
		mov	si,ds:sprite_cache_tbl[bx]
		mov	ax,0B800h
		mov	es,ax
		mov	ds,ax
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_50			; Jump if below
		add	di,tga_vram_wrap_c

loc_50:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_51			; Jump if below
		add	si,tga_vram_wrap_c

loc_51:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_52			; Jump if below
		add	di,tga_vram_wrap_c

loc_52:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_53			; Jump if below
		add	si,tga_vram_wrap_c

loc_53:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_54			; Jump if below
		add	di,tga_vram_wrap_c

loc_54:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_55			; Jump if below
		add	si,tga_vram_wrap_c

loc_55:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_56			; Jump if below
		add	di,tga_vram_wrap_c

loc_56:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_57			; Jump if below
		add	si,tga_vram_wrap_c

loc_57:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_58			; Jump if below
		add	di,tga_vram_wrap_c

loc_58:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_59			; Jump if below
		add	si,tga_vram_wrap_c

loc_59:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_60			; Jump if below
		add	di,tga_vram_wrap_c

loc_60:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_61			; Jump if below
		add	si,tga_vram_wrap_c

loc_61:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_62			; Jump if below
		add	di,tga_vram_wrap_c

loc_62:
		add	si,1FFCh
		cmp	si,8000h
		jb	loc_63			; Jump if below
		add	si,tga_vram_wrap_c

loc_63:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_64:
		mov	ax,0B800h
		mov	es,ax
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_65			; Jump if below
		add	di,tga_vram_wrap_c

loc_65:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_66			; Jump if below
		add	di,tga_vram_wrap_c

loc_66:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_67			; Jump if below
		add	di,tga_vram_wrap_c

loc_67:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_68			; Jump if below
		add	di,tga_vram_wrap_c

loc_68:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_69			; Jump if below
		add	di,tga_vram_wrap_c

loc_69:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_70			; Jump if below
		add	di,tga_vram_wrap_c

loc_70:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_71			; Jump if below
		add	di,tga_vram_wrap_c

loc_71:
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

tga_sprite_blit		endp

sprite_slot_remove		proc	near
		cmp	byte ptr ds:sprite_buf,0FFh
		jne	loc_72			; Jump if not equal
		retn

loc_72:
		cmp	byte ptr ds:sprite_buf,0FCh
		jne	loc_73			; Jump if not equal
		retn

loc_73:
		push	si
		push	bx
		mov	byte ptr ds:sprite_buf,0FFh
		mov	cl,[si]
		add	si,25h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_74			; Jump if not sign
		call	sprite_get_value

loc_74:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,41F8h
		call	sprite_cell_render
		pop	bx
		pop	si
		retn

sprite_slot_remove		endp

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
		add	dx,dx
		add	dx,41F8h
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
		jne	loc_75			; Jump if not equal
		retn

loc_75:
		cmp	byte ptr ds:sprite_buf_b,0FCh
		jne	loc_76			; Jump if not equal
		retn

loc_76:
		mov	byte ptr ds:sprite_buf_b,0FFh
		mov	cl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_77			; Jump if not sign
		call	sprite_get_value

loc_77:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,4264h
		jmp	loc_91

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
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_79			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_79			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_78			; Jump if not sign
		call	sprite_get_value

loc_78:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_79:
		add	dx,140h
		cmp	byte ptr ds:row_counter,1
		je	loc_81			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_81			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_81			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_80			; Jump if not sign
		call	sprite_get_value

loc_80:
		call	sprite_cell_render

loc_81:
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
		add	dx,dx
		add	dx,ds:vga_row_ptr
		mov	al,cl
		call	sprite_src_setup
		mov	di,sprite_pos
		mov	[di],al
		mov	bp,sprite_state_a
		call	sprite_pos_pair_iter
		cmp	byte ptr ds:row_counter,1
		je	loc_83			; Jump if equal
		add	dx,138h
		call	sprite_pos_pair_iter
		test	byte ptr ds:flag_equip_b,0FFh
		jz	loc_83			; Jump if zero
		test	byte ptr ds:flag_shadow,0FFh
		jz	loc_83			; Jump if zero
		call	projectile_spawn_check

loc_83:
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
		add	si,24h
		call	si_wrap_hi
		mov	dl,[si-1]
		mov	al,cl
		call	sprite_src_setup
		mov	bl,al
		mov	bh,dl
		pop	dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_86			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_86			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_85			; Jump if not sign
		call	sprite_get_value

loc_85:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_86:
		add	dx,140h
		cmp	byte ptr ds:row_counter,1
		je	loc_88			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_88			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_88			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_87			; Jump if not sign
		call	sprite_get_value

loc_87:
		call	sprite_cell_render

loc_88:
		pop	bx
		pop	di
		pop	si
		jmp	row_advance_done

sprite_wide_row_render		endp

sprite_pos_pair_iter		proc	near
		call	sprite_pos_blit

sprite_pos_blit:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_90			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_90			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_89			; Jump if not sign
		call	sprite_get_value

loc_89:
		push	bp
		push	si
		push	di
		push	dx
		call	sprite_cell_render
		pop	dx
		pop	di
		pop	si
		pop	bp

loc_90:
		inc	si
		inc	di
		inc	bp
		add	dx,4
		retn

sprite_pos_pair_iter		endp

sprite_cell_render		proc	near

loc_91:
		push	es
		push	ds
		mov	bl,ds:palette_byte
		or	al,al			; Zero ?
		jz	loc_92			; Jump if zero
		js	loc_92			; Jump if sign=1
		or	bl,80h

loc_92:
		mov	cl,al
		mov	al,ah
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,sprite_gfx_base
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
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
		js	loc_93			; Jump if sign=1
		push	di
		mov	di,5682h
		call	tga_sprite_inner_blit
		pop	di
		mov	si,tga_decode_buf
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	tga_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

loc_93:
		push	di
		mov	di,tga_decode_buf
		call	tga_sprite_render_blended
		pop	di
		mov	si,tga_decode_buf
		push	cs
		pop	ds
		mov	ax,0B800h
		mov	es,ax
		call	tga_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

sprite_cell_render		endp

tga_sprite_render_blended		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_16words
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

tga_sprite_render_blended		endp

tile_blend_inner_loop		proc	near
		mov	cx,8

blend_row_loop:
				push	cx
				mov	dl,ds:[bp]
				call	nibble_pack_ax
				and	es:[di],ax
				push	dx
				lodsw				; String [si] to ax
				call	color_nibble_expand
				or	es:[di],ax
				pop	dx
				call	nibble_pack_ax
				and	es:[di+2],ax
				lodsw				; String [si] to ax
				call	color_nibble_expand
				or	es:[di+2],ax
				inc	bp
				add	di,4
				pop	cx
				loop	blend_row_loop		; Loop if cx > 0

		retn

tile_blend_inner_loop		endp

tga_sprite_inner_blit		proc	near
		mov	cx,8

solid_row_loop:
				lodsw				; String [si] to ax
				call	color_nibble_expand
				stosw				; Store ax to es:[di]
				lodsw				; String [si] to ax
				call	color_nibble_expand
				stosw				; Store ax to es:[di]
				loop	solid_row_loop		; Loop if cx > 0

		retn

tga_sprite_inner_blit		endp

color_nibble_expand		proc	near
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

color_nibble_expand		endp

tga_blit_2bytes_8rows		proc	near
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_96			; Jump if below
		add	di,tga_vram_wrap_c

loc_96:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_97			; Jump if below
		add	di,tga_vram_wrap_c

loc_97:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_98			; Jump if below
		add	di,tga_vram_wrap_c

loc_98:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_99			; Jump if below
		add	di,tga_vram_wrap_c

loc_99:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_100			; Jump if below
		add	di,tga_vram_wrap_c

loc_100:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_101			; Jump if below
		add	di,tga_vram_wrap_c

loc_101:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		add	di,1FFCh
		cmp	di,8000h
		jb	loc_102			; Jump if below
		add	di,tga_vram_wrap_c

loc_102:
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		retn

tga_blit_2bytes_8rows		endp

copy_16words		proc	near
		mov	cx,10h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn

copy_16words		endp

fill_16words_zero		proc	near
		xor	ax,ax			; Zero register
		mov	cx,10h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

fill_16words_zero		endp

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
		jnz	loc_103			; Jump if not zero
		mov	si,sprite_src_b

loc_103:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:flag_equip_b,0FFh
		jnz	loc_104			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_104			; Jump if zero
		add	al,3

loc_104:
		mov	ds:palette_byte,al
		mov	al,cl
		retn

sprite_src_setup		endp

projectile_spawn_check		proc	near
		cmp	byte ptr ds:row_idx,10h
		jb	loc_105			; Jump if below
		retn

loc_105:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_106			; Jump if above or =
		retn

loc_106:
		mov	di,projectile_list
		xor	cl,cl			; Zero register

loc_107:
				cmp	byte ptr [di],0FFh
				je	loc_108			; Jump if equal
				add	di,4
				inc	cl
				jmp	short loc_107

loc_108:
		cmp	cl,20h			; ' '
		jb	loc_109			; Jump if below
		retn

loc_109:
				call	word ptr cs:[11Ah]
				and	al,3
				cmp	al,3
				je	loc_109			; Jump if equal
		dec	al
		add	al,ds:col_idx
		cmp	al,0FFh
		jne	loc_110			; Jump if not equal
		mov	al,4

loc_110:
		cmp	al,1Bh
		jb	loc_111			; Jump if below
		mov	al,1Ah

loc_111:
		stosb				; Store al to es:[di]

loc_112:
				call	word ptr cs:[11Ah]
				and	al,3
				cmp	al,3
				je	loc_112			; Jump if equal
		dec	al
		add	al,ds:row_idx
		cmp	al,0FFh
		jne	loc_113			; Jump if not equal
		xor	al,al			; Zero register

loc_113:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,7
		mov	bx,anim_frame_tbl
		xlat				; al=[al+[bx]] table
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

projectile_spawn_check		endp

; projectile_blit: entry reached by fall-through from projectile_spawn_check's tail
; (via the dispatch chain). 18-byte preamble is leftover compare-mask table data,
; not executed. Real entry is projectile_scan_loop just below.

projectile_blit:
		out	dx,al			; port 0 -- first byte of preamble (not executed)
		inc	sp
		push	bp
		db	 66h,0CCh,0DDh,0EEh,0CCh, 0Eh	; preamble bytes (table data)
		db	 07h,0BFh,0A0h,0EDh, 8Bh,0F7h	; preamble bytes (table data)

projectile_scan_loop:
		cmp	byte ptr [si],0FFh
		jne	loc_115			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn

loc_115:
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
		add	cx,cx
		add	ax,cx
		add	ax,41F8h
		push	si
		push	di
		push	es
		push	ax
		mov	al,[si+3]
		mov	ah,al
		mov	ds:bitmask_word,ax
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
				xchg	ah,al
				call	tga_plane_decode
				not	bp
				and	es:[di],bp
				or	es:[di],dx
				call	tga_plane_decode
				not	bp
				and	es:[di+2],bp
				or	es:[di+2],dx
				lodsw				; String [si] to ax
				xchg	ah,al
				call	tga_plane_decode
				not	bp
				and	es:[di+4],bp
				or	es:[di+4],dx
				call	tga_plane_decode
				not	bp
				and	es:[di+6],bp
				or	es:[di+6],dx
				add	di,2000h
				cmp	di,8000h
				jb	loc_117			; Jump if below
				add	di,tga_vram_wrap_b

loc_117:
				loop	proj_blit_row_loop		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_118			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4

loc_118:
		add	si,4
		jmp	projectile_scan_loop

; sprite_shape_tbl: projectile sprite shape/mask bitmap table.
; Referenced by projectile_blit via pattern_ptr_tbl[bx]. Each entry is a
; 16-bit shape bitmap stored as 16x (word-aligned) pairs. The first bytes
; look like code to Sourcer but are really shape/mask header bytes.

sprite_shape_tbl:				; 9-byte header ?-- Sourcer mis-decoded as code
		db	0B0h, 3Ah, 70h, 3Ah, 30h, 3Ah,0F0h, 39h, 00h	; shape ptrs: 3AB0,3A70,3A30,39F0 + 00 term
		db	16 dup (0)
; --- TGA shape 0: small projectile / spark (5 rows x 6 bytes) ---
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh			; shape 0 row 0
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h			; shape 0 row 1
		db	0F0h, 0Fh, 00h, 00h,0F0h, 0Fh			; shape 0 row 2
		db	 00h, 00h,0FCh, 3Fh, 00h, 00h			; shape 0 row 3
		db	 3Fh,0FCh, 00h, 00h, 0Fh,0F0h			; shape 0 row 4
		db	26 dup (0)
; --- TGA shape 1: medium projectile / star (8 rows x 6 bytes) ---
		db	 0Fh,0F0h, 00h, 00h, 3Fh,0FCh			; shape 1 row 0
		db	 00h, 00h,0FFh,0FFh, 00h, 00h			; shape 1 row 1
		db	0FCh, 3Fh, 00h, 03h,0F0h, 0Fh			; shape 1 row 2
		db	0C0h, 03h,0C0h, 03h,0C0h, 03h			; shape 1 row 3 (center)
		db	0C0h, 03h,0C0h, 03h,0F0h, 0Fh			; shape 1 row 4
		db	0C0h, 00h,0FCh, 3Fh, 00h, 00h			; shape 1 row 5
		db	0FFh,0FFh, 00h, 00h, 3Fh,0FCh			; shape 1 row 6
		db	 00h, 00h, 0Fh,0F0h			; shape 1 row 7 (4-byte partial)
		db	10 dup (0)
; --- TGA shape 2: large explosion / spell burst (~21 rows x 6 bytes) ---
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

; shift_blit_setup: alternate init entry (parallels EGA shift_blit_setup).
; Appears to be dead code -- no reachable caller. Decoded bytes show an
; inline init: zero sprite_pos/sprite_row_buf, then call/jmp to tile
; dispatch. Left as db bytes because flow reaches ui_tile_row_loop via
; fall-through from jmp +3Ch which is part of this same block.

shift_blit_setup:
		db	 00h			; padding / low byte of BF 59

shift_blit_setup_entry:
		mov	di,sprite_pos
		push	cs
		pop	es
		xor	ax,ax
		stosw
		stosw
		stosw
		stosw
		stosb
		mov	di,sprite_row_buf
		mov	cx,8
		rep	stosw
		jmp	short ui_tile_postloop	; jumps past the loops to 0B46
		db	0E8h, 0Eh, 04h		; call +40Eh (preserves bytes; orphan in dead path)
		mov	di,sprite_row_buf
		mov	dl,byte ptr ds:[0FF35h]	; enemy_counter
		dec	dl
		mov	cx,4

ui_tile_row_loop:
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

ui_tile_col_loop:
						mov	al,[bx]
						or	al,al			; Zero ?
						js	loc_122			; Jump if sign=1
						xor	al,al			; Zero register

loc_122:
						mov	[di],al
						inc	bx
						inc	di
						loop	ui_tile_col_loop		; Loop if cx > 0

				inc	dl
				pop	cx
				loop	ui_tile_row_loop		; Loop if cx > 0

ui_tile_postloop:
		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,140h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,41F8h
		mov	ds:scroll_vga_ofs,ax
		mov	byte ptr ds:col_idx,0
		mov	si,5259h
		mov	di,sprite_row_buf
		mov	cx,3

tile_3x3_row_loop:
				push	cx
				mov	cx,3

tile_3x3_col_loop:
						push	cx
						mov	ax,3BD3h
						push	ax
						mov	al,[di]
						or	al,[di+1]
						or	al,[di+4]
						or	al,[di+5]
						jnz	loc_125			; Jump if not zero
						jmp	loc_162

loc_125:
						test	byte ptr [di],0FFh
						jz	loc_126			; Jump if zero
						mov	al,[di]
						push	si
						call	sprite_src_setup
						inc	si
						inc	si
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_164

loc_126:
						test	byte ptr [di+1],0FFh
						jz	loc_127			; Jump if zero
						mov	al,[di+1]
						push	si
						call	sprite_src_setup
						inc	si
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_164

loc_127:
						test	byte ptr [di+4],0FFh
						jz	loc_128			; Jump if zero
						mov	al,[di+4]
						push	si
						call	sprite_src_setup
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_164

loc_128:
						mov	al,[di+5]
						push	si
						call	sprite_src_setup
						mov	cl,[si]
						pop	si
						mov	[si],al
						mov	al,cl
						jmp	loc_164

; tile_3x3_step: common continuation after any of the four loc_125-128 blit branches.
; Each branch jumps to loc_164 (the blitter) which itself falls through here.

tile_3x3_step:
						inc	byte ptr ds:col_idx
						inc	di
						inc	si
						pop	cx
						loop	tile_3x3_col_loop		; Loop if cx > 0

				pop	cx
				inc	di
				loop	tile_3x3_row_loop		; Loop if cx > 0

		mov	bl,ds:color_sel
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	es,cs:game_seg
		mov	al,byte ptr ds:init_complete_flag
		or	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_129			; Jump if zero
		jmp	loc_139

loc_129:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_130			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h

loc_130:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_134			; Jump if zero
		inc	cl
		jnz	loc_131			; Jump if not zero
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
		jmp	short loc_137

loc_131:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_132			; Jump if not zero
		add	ax,24h
		jmp	short loc_133

loc_132:
		dec	dl
		jnz	loc_133			; Jump if not zero
		mov	ax,63h

loc_133:
		add	si,ax
		jmp	short loc_137

loc_134:
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_136			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_136			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:flag_shield
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_135			; Jump if zero
		add	ax,1Bh

loc_135:
		add	si,ax
		jmp	short loc_137

loc_136:
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_139			; Jump if not zero
		mov	al,byte ptr ds:gvar_pose_idx
		cmp	al,80h
		je	loc_139			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_139			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_138

loc_137:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_138			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		call	tga_sprite_render_solid
		jmp	short loc_139

loc_138:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	tga_sprite_render_solid

loc_139:
		mov	si,610Eh
		test	byte ptr ds:flag_riding,0FFh
		jnz	loc_144			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:flag_climbing,0FFh
		jnz	loc_142			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_140			; Jump if not zero
		mov	si,game_data_base

loc_140:
		test	byte ptr ds:init_complete_flag,0FFh
		jz	loc_141			; Jump if zero
		add	si,5Ah
		jmp	short loc_142

loc_141:
		mov	ax,2Dh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_143			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:equip_byte,80h
		jnz	loc_143			; Jump if not zero
		mov	cl,ds:shield_sel
		mov	ax,48h
		dec	cl
		jz	loc_143			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_143			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:equip_byte,7Fh
		je	loc_143			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:gvar_pose_idx,80h
		je	loc_143			; Jump if equal

loc_142:
		mov	al,byte ptr ds:gvar_pose_idx
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al

loc_143:
		add	si,ax

loc_144:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	tga_sprite_render_solid
		test	byte ptr ds:init_complete_flag,0FFh
		jz	loc_145			; Jump if zero
		retn

loc_145:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_146			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h

loc_146:
		mov	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_148			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jnz	loc_147			; Jump if not zero
		retn

loc_147:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_155

loc_148:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_152			; Jump if zero
		inc	cl
		jnz	loc_149			; Jump if not zero
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
		jmp	short loc_156

loc_149:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_150			; Jump if not zero
		add	ax,24h
		jmp	short loc_151

loc_150:
		dec	dl
		jnz	loc_151			; Jump if not zero
		mov	ax,63h

loc_151:
		add	si,ax
		jmp	short loc_156

loc_152:
		test	byte ptr ds:[0C2h],1
		jz	loc_154			; Jump if zero
		call	hero_tier_get
		or	al,al			; Zero ?
		jz	loc_154			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:flag_shield
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_153			; Jump if zero
		add	ax,1Bh

loc_153:
		add	si,ax
		jmp	short loc_156

loc_154:
		mov	ax,1Bh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_155			; Jump if not zero
		mov	cl,byte ptr ds:gvar_pose_idx
		cmp	cl,80h
		je	loc_155			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al

loc_155:
		add	si,ax

loc_156:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_157			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		jmp	short locloop_158

loc_157:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		jmp	short locloop_158

tga_sprite_render_solid		proc	near

locloop_158:
				push	cx
				mov	al,es:[si]
				or	al,al			; Zero ?
				jz	loc_159			; Jump if zero
				push	es
				push	ds
				push	si
				push	di
				mov	ch,20h			; ' '
				mul	ch			; ax = reg * al
				mov	si,ax
				add	si,6333h
				shr	ax,1			; Shift w/zeros fill
				shr	ax,1			; Shift w/zeros fill
				mov	bp,ax
				add	bp,pattern_buf_d000
				mov	ds,cs:game_seg
				mov	di,dx
				push	cs
				pop	es
				mov	al,cs:col_idx
				mov	cl,20h			; ' '
				mul	cl			; ax = reg * al
				add	ax,5562h
				mov	di,ax
				call	tile_blend_inner_loop
				pop	di
				pop	si
				pop	ds
				pop	es

loc_159:
				inc	si
				inc	byte ptr ds:col_idx
				pop	cx
				loop	locloop_158		; Loop if cx > 0

		retn

tga_sprite_render_solid		endp

hero_tier_get		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_160			; Jump if not zero
		retn

loc_160:
		cmp	al,4
		mov	al,1
		jnc	loc_161			; Jump if carry=0
		retn

loc_161:
		mov	al,2
		retn

hero_tier_get		endp

loc_162:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:game_seg
		push	cs
		pop	es
		mov	al,cs:col_idx
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,5562h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_163			; Jump if zero
		dec	al
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_16words
		pop	di
		pop	si
		pop	ds
		retn

loc_163:
		call	fill_16words_zero
		pop	di
		pop	si
		pop	ds
		retn

loc_164:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_165			; Jump if not sign
		call	sprite_get_value

loc_165:
		push	ax
		mov	bl,ds:palette_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:color_pair_tbl[bx]
		mov	cs:cur_color_pair,dx
		mov	al,cl
		mov	ch,20h			; ' '
		mul	ch			; ax = reg * al
		mov	si,ax
		add	si,sprite_gfx_base
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1			; Shift w/zeros fill
		mov	bp,ax
		add	bp,0A000h
		mov	ds,cs:game_seg
		push	cs
		pop	es
		mov	al,cs:col_idx
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,5562h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_166			; Jump if zero
		mov	cl,al
		call	tga_sprite_render_blended
		pop	di
		pop	si
		pop	ds
		retn

loc_166:
		call	tga_sprite_inner_blit
		pop	di
		pop	si
		pop	ds
		retn

; load_sprite_pos_triplet: copies 3 sprite-position records from game_seg
; into CS:sprite_pos (12 bytes). Called by scroll_blit_dispatch preamble.
; Entry is reachable only via fall-through or CS-relative call site
; below (frame_row_driver -> scroll_blit_dispatch chain).

load_sprite_pos_triplet:
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

sprite_pos_copy_loop:
				movsw				; Mov [si] to es:[di]
				movsb				; Mov [si] to es:[di]
				add	si,21h
				call	si_wrap_hi
				loop	sprite_pos_copy_loop	; Loop if cx > 0

		retn

frame_row_driver		proc	near
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_169			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_168		; Jump if not equal
		call	hero_sprite_col_blit

loc_ret_168:
		retn

loc_169:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	scroll_step_nonzero			; Jump if above or =
		retn

scroll_step_nonzero:
		jnz	loc_171			; Jump if not zero
		call	bg_restore
		jmp	scroll_blit_entry

loc_171:
		add	al,0Ah
		cmp	al,cl
		je	loc_172			; Jump if equal
		retn

loc_172:
		jmp	scroll_blit_dispatch

; scroll_step_update: inner scroll advance (entry point for scroll_blit_dispatch).
; Called when scroll is active and we need to advance scroll position/tiles.

scroll_step_update:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_173			; Jump if not zero
		retn

loc_173:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:game_seg
		inc	byte ptr ds:scroll_step
		mov	al,ds:scroll_phase
		or	al,al			; Zero ?
		jz	loc_177			; Jump if zero
		dec	al
		jz	loc_175			; Jump if zero
		cmp	byte ptr ds:scroll_step,5
		jb	loc_174			; Jump if below
		jmp	loc_181

loc_174:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:mask_word,0FF01h
		mov	dx,13Ch
		test	byte ptr ds:[0C2h],1
		jnz	loc_179			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:mask_word,1
		mov	dx,140h
		jmp	short loc_179

loc_175:
		cmp	byte ptr ds:scroll_step,5
		jb	loc_176			; Jump if below
		jmp	loc_181

loc_176:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_178			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_178

loc_177:
		cmp	byte ptr ds:scroll_step,7
		jae	loc_181			; Jump if above or =
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_178			; Jump if not zero
		mov	di,plane_alt_b17e
		mov	si,0B01Eh

loc_178:
		mov	bx,es:[bx+di]
		mov	ds:mask_word,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,140h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	ax,ax
		add	dx,ax

loc_179:
		mov	di,ds:scroll_vga_ofs
		add	di,dx
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_180			; Jump if zero
		add	di,140h

loc_180:
		mov	ds:scroll_gfx_ptr,di
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	si,cx
		mov	ds:scroll_delta,si
		pop	bx
		pop	di
		pop	si
		pop	es
		jmp	scroll_blit_dispatch

loc_181:
		mov	byte ptr ds:scroll_active,0
		mov	byte ptr ds:scroll_step,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

frame_row_driver		endp

bg_restore		proc	near
		test	byte ptr ds:restore_pending,0FFh
		jnz	loc_182			; Jump if not zero
		retn

loc_182:
		push	es
		push	di
		push	si
		push	bx
		call	bg_restore_impl
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:restore_pending,0
		retn

bg_restore		endp

bg_save		proc	near
		push	ds
		push	cs
		pop	es
		mov	si,cs:scroll_gfx_ptr
		mov	ax,0B800h
		mov	ds,ax
		mov	di,bg_save_buf
		mov	cx,20h

bg_restore_row_loop:
				push	cx
				mov	cx,8
				rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
				add	si,1FF0h
				cmp	si,8000h
				jb	loc_184			; Jump if below
				add	si,80A0h

loc_184:
				pop	cx
				loop	bg_restore_row_loop		; Loop if cx > 0

		pop	ds
		retn

bg_save		endp

bg_restore_impl		proc	near
		mov	di,cs:scroll_gfx_ptr
		mov	ax,0B800h
		mov	es,ax
		mov	si,bg_save_buf
		mov	cx,20h

bg_save_row_loop:
				push	cx
				mov	cx,8
				rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
				add	di,1FF0h
				cmp	di,8000h
				jb	loc_186			; Jump if below
				add	di,80A0h

loc_186:
				pop	cx
				loop	bg_save_row_loop		; Loop if cx > 0

		retn

bg_restore_impl		endp

scroll_cache_invalidate		proc	near
		mov	al,byte ptr ds:[84h]
		add	al,ds:mask_word
		and	al,3Fh			; '?'
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		mov	cl,byte ptr ds:[83h]
		add	cl,byte ptr ds:mask_word+1
		add	cl,4
		xor	ch,ch			; Zero register
		add	ax,cx
		mov	si,ax
		add	si,ds:sprite_data_ptr
		call	si_wrap_hi
		mov	cx,4

sc_inv_outer_loop:
				push	cx
				mov	cx,4

sc_inv_inner_loop:
						push	cx
						mov	bl,[si]
						inc	si
						and	bl,7Fh
						xor	bh,bh			; Zero register
						add	bx,bx
						mov	word ptr ds:sprite_cache_tbl[bx],0
						pop	cx
						loop	sc_inv_inner_loop		; Loop if cx > 0

				add	si,20h
				call	si_wrap_hi
				pop	cx
				loop	sc_inv_outer_loop		; Loop if cx > 0

		retn

scroll_blit_dispatch:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_190			; Jump if not zero
		retn

loc_190:
		mov	byte ptr ds:restore_pending,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	scroll_cache_invalidate
		call	bg_save
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[92h]
		dec	bl
		add	bx,bx
		mov	ax,cs:color_map_tbl[bx]
		mov	cs:bitmask_word,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:scroll_gfx_ptr
		mov	si,cs:scroll_delta
		mov	cx,4

tile_3x3_outer_loop:
				push	cx
				push	di
				mov	cx,4

tile_3x3_mid_loop:
						push	cx
						lodsb				; String [si] to al
						cmp	al,0FFh
						jne	loc_193			; Jump if not equal
						add	di,140h
						jmp	short loc_196

loc_193:
						push	si
						xor	ah,ah			; Zero register
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ax
						mov	si,ax
						add	si,ds:sprite_src_base
						mov	cx,8

tile_3x3_blit_loop:
						push	cx
						lodsw				; String [si] to ax
						xchg	ah,al
						call	tga_plane_decode
						not	bp
						and	es:[di],bp
						or	es:[di],dx
						call	tga_plane_decode
						not	bp
						and	es:[di+2],bp
						or	es:[di+2],dx
						add	di,2000h
						cmp	di,8000h
						jb	loc_195			; Jump if below
						add	di,80A0h

loc_195:
						pop	cx
						loop	tile_3x3_blit_loop		; Loop if cx > 0

						pop	si

loc_196:
						pop	cx
						loop	tile_3x3_mid_loop		; Loop if cx > 0

				pop	di
				add	di,4
				pop	cx
				loop	tile_3x3_outer_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

scroll_cache_invalidate		endp

tga_plane_decode		proc	near
		xor	bp,bp			; Zero register
		xor	dx,dx			; Zero register
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_198			; Jump if zero
		or	bp,0F0h
		mov	bh,byte ptr cs:bitmask_word+1
		cmp	bl,3
		je	loc_197			; Jump if equal
		mov	bh,cs:bitmask_word

loc_197:
		and	bh,0F0h
		mov	dl,bh

loc_198:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_200			; Jump if zero
		or	bp,0Fh
		mov	bh,byte ptr cs:bitmask_word+1
		cmp	bl,3
		je	loc_199			; Jump if equal
		mov	bh,cs:bitmask_word

loc_199:
		and	bh,0Fh
		or	dl,bh

loc_200:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_202			; Jump if zero
		or	bp,0F000h
		mov	bh,byte ptr cs:bitmask_word+1
		cmp	bl,3
		je	loc_201			; Jump if equal
		mov	bh,cs:bitmask_word

loc_201:
		and	bh,0F0h
		mov	dh,bh

loc_202:
		xor	bx,bx			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jnz	loc_203			; Jump if not zero
		retn

loc_203:
		or	bp,0F00h
		mov	bh,byte ptr cs:bitmask_word+1
		cmp	bl,3
		je	loc_204			; Jump if equal
		mov	bh,cs:bitmask_word

loc_204:
		and	bh,0Fh
		or	dh,bh
		retn

tga_plane_decode		endp

; TGA color/blend lookup table (12 bytes) + trailing code stub
; Pattern matches tga_plane_decode bitmask_word usage
gf_tga_blend_tbl:
		db	 77h,0FFh, 33h,0BBh, 22h,0AAh			; blend pairs: 77/FF, 33/BB, 22/AA
		db	 77h,0FFh, 33h,0BBh, 88h,0EEh			; blend pairs: 77/FF, 33/BB, 88/EE
; --- trailing TGA blit code stub (Sourcer mis-decoded) ---
		db	 02h,0FFh,0E8h, 3Fh, 0Fh,0A3h			; code: add bh,bh; call rel; mov [...],ax
		db	 33h, 52h,0EBh			; code: xor dx; push dx; jmp short
		db	0Dh			; code: trailing offset byte for jmp short

hero_sprite_col_blit		proc	near

scroll_blit_entry:
		test	byte ptr ds:redraw_lock,0FFh
		jz	loc_206			; Jump if zero
		retn

loc_206:
		mov	byte ptr ds:redraw_lock,0FFh

loc_207:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B800h
		mov	es,ax
		mov	si,tga_sprite_buf
		mov	di,cs:scroll_vga_ofs
		mov	cx,3

hero_col_outer_loop:
				push	cx
				mov	cx,3

hero_col_inner_loop:
						push	cx
						push	di
						call	tga_blit_2bytes_8rows
						pop	di
						add	di,4
						pop	cx
						loop	hero_col_inner_loop		; Loop if cx > 0

				add	di,134h
				pop	cx
				loop	hero_col_outer_loop		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn

hero_sprite_col_blit		endp

; sprite_blit_with_holes: writes a 16x8 sprite from game_seg into B800,
; skipping zero pixels (preserves underlying background). Called via
; fall-through or indirect from anim-refresh path.

sprite_blit_with_holes:
		push	ds
		push	si
		dec	al
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	cx,8

sprite_erase_loop:
				push	cx
				lodsw				; String [si] to ax
				or	al,al			; Zero ?
				jz	loc_211			; Jump if zero
				mov	es:[di],al

loc_211:
				or	ah,ah			; Zero ?
				jz	loc_212			; Jump if zero
				mov	es:[di+1],ah

loc_212:
				lodsw				; String [si] to ax
				or	al,al			; Zero ?
				jz	loc_213			; Jump if zero
				mov	es:[di+2],al

loc_213:
				or	ah,ah			; Zero ?
				jz	loc_214			; Jump if zero
				mov	es:[di+3],ah

loc_214:
				add	di,2000h
				cmp	di,8000h
				jb	loc_215			; Jump if below
				add	di,80A0h

loc_215:
				pop	cx
				loop	sprite_erase_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

; anim_refresh_all_frames: 8-pass per-frame animation refresh (parallel to
; anim_refresh_all in EGA). Walks all sprite slots 8 times, decrementing
; anim_phase. Reached via indirect call from game code (CS-relative).

anim_refresh_all_frames:
		mov	byte ptr ds:restore_pending,0
		mov	ax,0B800h
		mov	es,ax
		mov	byte ptr ds:anim_phase,8

anim_pass_start:
				mov	word ptr ds:vga_row_ptr,41F8h
				mov	byte ptr ds:gvar_frame_timer,0
				mov	si,ds:sprite_data_ptr
				mov	di,sprite_buf
				mov	cx,12h

anim_row_stride_loop:
						push	cx
						add	si,4
						xor	bx,bx			; Zero register
						mov	cx,1Ch

anim_slot_loop:
						push	cx
						lodsb				; String [si] to al
						call	tga_tile_anim_update
						inc	di
						inc	bl
						pop	cx
						loop	anim_slot_loop		; Loop if cx > 0

						add	si,4
						call	si_wrap_hi
						add	word ptr ds:vga_row_ptr,140h
						pop	cx
						loop	anim_row_stride_loop		; Loop if cx > 0

loc_219:
						cmp	byte ptr ds:gvar_frame_timer,10h
						jb	loc_219			; Jump if below
				dec	byte ptr ds:anim_phase
				jnz	anim_pass_start		; Jump if not zero
		retn

tga_tile_anim_update		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_220			; Jump if not equal
		retn

loc_220:
		cmp	byte ptr [di],0FCh
		jne	loc_221			; Jump if not equal
		retn

loc_221:
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
		sbb	ax,ax
		xor	ax,0F0F0h
		mov	cs:mask_word,ax
		add	bx,bx
		add	bx,bx
		add	bx,ds:vga_row_ptr
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_223			; Jump if zero
		dec	al
		mov	cl,20h			; ' '
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
		call	tga_vram_advance_az
		call	tile_blend_row_pair
		pop	di
		pop	si
		mov	al,cs:anim_phase
		call	tga_vram_advance_az
		add	di,2
		add	si,2
		call	tile_blend_row_pair
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

tga_tile_anim_update		endp

tile_blend_row_pair		proc	near
		mov	cx,2

tile_blend_col_loop:
				mov	bx,cs:mask_word
				lodsw				; String [si] to ax
				and	ax,bx
				not	bx
				and	es:[di],bx
				or	es:[di],ax
				add	di,0A0h
				add	si,0Eh
				loop	tile_blend_col_loop		; Loop if cx > 0

		retn

loc_223:
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	tga_vram_advance_az
		call	tga_row_mask_clear
		pop	di
		mov	al,cs:anim_phase
		call	tga_vram_advance_az
		add	di,2
		call	tga_row_mask_clear
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

tile_blend_row_pair		endp

tga_row_mask_clear		proc	near
		mov	ax,cs:mask_word
		not	ax
		and	es:[di],ax
		add	di,tga_row_stride
		and	es:[di],ax
		retn

tga_row_mask_clear		endp

tga_vram_advance_az		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		add	ax,ax
		add	ax,ax
		add	si,ax
		pop	ax
		or	ax,ax			; Zero ?
		jnz	loc_224			; Jump if not zero
		retn

loc_224:
				add	di,2000h
				cmp	di,8000h
				jb	loc_225			; Jump if below
				add	di,80A0h

loc_225:
				dec	ax
				jnz	loc_224			; Jump if not zero
		retn

tga_vram_advance_az		endp

; fade_effect_init: entry for the 9-pass concentric fade gradient effect
; (parallel to ega_color_fade_init). Computes center color pair from
; col_idx/row_idx (bytes at DS:[83h]/[84h]), runs two concentric passes
; with different anim_phase values, then falls through to anim_refresh_all.

fade_effect_init:
		mov	al,byte ptr ds:[83h]
		add	al,al
		add	al,al
		add	al,al
		mov	ah,byte ptr ds:[84h]
		add	ah,ah
		add	ah,ah
		add	ah,ah
		mov	ds:cur_color_pair,al
		mov	byte ptr ds:cur_color_pair+1,ah
		call	anim_refresh_all
		mov	byte ptr ds:anim_phase,0EEh
		call	fade_concentric
		mov	byte ptr ds:anim_phase,0
		call	fade_concentric
		jmp	anim_refresh_start

fade_concentric		proc	near
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
		call	fade_radius_loop
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
		call	fade_radius_loop
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

fade_radius_loop:
		mov	cx,9

fade_radius_inner:
				push	cx
				push	dx
				push	bx
				call	fade_h_range
				pop	bx
				pop	dx
				sub	bl,0Ch
				jnc	loc_227			; Jump if carry=0
				xor	bl,bl			; Zero register

loc_227:
				sub	bh,0Ch
				jnc	loc_228			; Jump if carry=0
				xor	bh,bh			; Zero register

loc_228:
				add	dl,0Ch
				jnc	loc_229			; Jump if carry=0
				mov	dl,0FFh

loc_229:
				add	dh,0Ch
				jnc	loc_230			; Jump if carry=0
				mov	dh,0FFh

loc_230:
				push	dx
				push	bx
				call	fade_gradient_loop
				pop	bx
				pop	dx
				pop	cx
				loop	fade_radius_inner		; Loop if cx > 0

		retn

fade_concentric		endp

fade_h_range		proc	near
		mov	ax,0B800h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	fade_pixel_range
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	fade_pixel_range
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	fade_v_range
		pop	bx
		pop	dx
		mov	bl,dl

fade_v_range:
		cmp	dh,bh
		jae	loc_231			; Jump if above or =
		xchg	dx,bx

loc_231:
		or	bl,bl			; Zero ?
		jnz	loc_232			; Jump if not zero
		retn

loc_232:
		cmp	bl,0DFh
		jb	loc_233			; Jump if below
		retn

loc_233:
		or	bh,bh			; Zero ?
		jnz	loc_234			; Jump if not zero
		mov	bh,1

loc_234:
		cmp	dh,8Fh
		jb	loc_235			; Jump if below
		mov	dh,8Eh

loc_235:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	phase_ptr_advance
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,1
		jz	loc_236			; Jump if zero
		mov	ah,0Fh
		jmp	short loc_237

loc_236:
		mov	ah,0F0h

loc_237:
		mov	al,ah
		not	al
		and	ah,ds:anim_phase

fade_h_strip_loop:
				and	es:[di],al
				or	es:[di],ah
				add	di,2000h
				cmp	di,8000h
				jb	loc_239			; Jump if below
				add	di,80A0h

loc_239:
				loop	fade_h_strip_loop		; Loop if cx > 0

		retn

fade_h_range		endp

fade_pixel_range		proc	near
		cmp	dl,bl
		jae	loc_240			; Jump if above or =
		xchg	dx,bx

loc_240:
		or	bh,bh			; Zero ?
		jnz	loc_241			; Jump if not zero
		retn

loc_241:
		cmp	bh,8Fh
		jb	loc_242			; Jump if below
		retn

loc_242:
		or	bl,bl			; Zero ?
		jnz	loc_243			; Jump if not zero
		mov	bl,1

loc_243:
		cmp	dl,0DFh
		jb	loc_244			; Jump if below
		mov	dl,0DEh

loc_244:
		mov	al,bh
		call	phase_ptr_advance
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		shr	ah,1			; Shift w/zeros fill
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		and	bl,1
		jz	loc_245			; Jump if zero
		mov	al,0Fh
		jmp	short loc_246

loc_245:
		mov	al,0FFh

loc_246:
		and	dl,1
		jz	loc_247			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_248

loc_247:
		mov	ah,0F0h

loc_248:
		jcxz	loc_250			; Jump if cx=0
		dec	cx
		jcxz	loc_249			; Jump if cx=0
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

loc_249:
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

loc_250:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:anim_phase
		and	es:[di],dh
		or	es:[di],al
		retn

fade_pixel_range		endp

phase_ptr_advance		proc	near
		push	bx
		add	al,0Eh
		mov	bh,al
		ror	bh,1			; Rotate
		ror	bh,1			; Rotate
		ror	bh,1			; Rotate
		and	bx,6000h
		mov	di,bx
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	bl,0A0h
		mul	bl			; ax = reg * al
		add	ax,18h
		add	di,ax
		pop	bx
		retn

phase_ptr_advance		endp

fade_gradient_loop		proc	near
		mov	cl,ds:anim_speed
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al

loc_251:
				push	ax
				call	word ptr cs:[110h]
				call	word ptr cs:[112h]
				call	word ptr cs:[114h]
				call	word ptr cs:[116h]
				call	word ptr cs:[118h]
				pop	ax
				cmp	ds:gvar_frame_timer,al
				jb	loc_251			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

fade_gradient_loop		endp

anim_refresh_all		proc	near

anim_refresh_start:
		mov	ax,0B800h
		mov	es,ax
		mov	di,tga_vram_buf
		mov	cx,8

anim_pass_loop:
				push	cx
				push	di
				mov	cx,12h

anim_row_loop:
						push	cx
						push	di
						mov	cx,38h
						mov	ax,4444h

anim_col_loop:
						xor	es:[di],ax
						inc	di
						inc	di
						loop	anim_col_loop		; Loop if cx > 0

						pop	di
						add	di,140h
						pop	cx
						loop	anim_row_loop		; Loop if cx > 0

				pop	di
				add	di,2000h
				cmp	di,8000h
				jb	loc_256			; Jump if below
				add	di,80A0h

loc_256:
				pop	cx
				loop	anim_pass_loop		; Loop if cx > 0

		retn

anim_refresh_all		endp

; tile_row_addr_calc: small helper that takes a tile coordinate in AX
; and returns the TGA VRAM byte offset via ega_row_addr_calc.
; Called indirectly by code in the scroll/UI paths.

tile_row_addr_calc:
		and	al,3Fh			; '?'
		mov	bx,ax
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,0Eh
		sub	bh,4
		add	bh,bh
		add	bh,bh
		add	bh,18h
		call	ega_row_addr_calc
		mov	di,ax
		retn

; tile_src_load: copies 0x480 bytes of tile data from CS+0x2000 into
; game_seg:tga_buf_8cf0 (the 8CF0h buffer), selecting source by DS:[9Dh].
; Called via CS-relative call from the scroll/UI path.

tile_src_load:
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	tile_src_load_done	; Jump if zero
		cmp	bl,7
		je	tile_src_load_done	; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:game_seg
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,tga_buf_8cf0
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

tile_src_load_done:
		mov	ds,cs:game_seg
		mov	si,8CF0h
		retn

si_wrap_hi		proc	near
		cmp	si,0E900h
		jae	loc_258			; Jump if above or =
		retn

loc_258:
		sub	si,900h
		retn

si_wrap_hi		endp

si_wrap_lo		proc	near
		cmp	si,0E000h
		jb	loc_259			; Jump if below
		retn

loc_259:
		add	si,900h
		retn

si_wrap_lo		endp

; ega_bg_tile_blit: blit 5x28 tile grid from bg_tile_src into VGA at
; offset 0x658 (UI area). Uses bitmask_word=0xCC44 pattern. Parallels
; ega_bg_tile_blit in EGA. Called via CS-relative call.

ega_bg_tile_blit:
		push	si
		push	ds
		mov	word ptr cs:bitmask_word,0CC44h
		mov	si,bg_tile_src
		mov	di,658h
		mov	ax,0B800h
		mov	es,ax
		mov	cx,5

bg_blit_row_outer:
				push	cx
				mov	cx,1Ch

bg_blit_row_mid:
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

bg_blit_col_loop:
						push	cx
						lodsw				; String [si] to ax
						xchg	ah,al
						call	tga_plane_decode
						mov	es:[di],dx
						call	tga_plane_decode
						mov	es:[di+2],dx
						add	di,2000h
						cmp	di,8000h
						jb	loc_263			; Jump if below
						add	di,80A0h

loc_263:
						pop	cx
						loop	bg_blit_col_loop		; Loop if cx > 0

						pop	di
						add	di,4
						pop	si
						pop	ds
						pop	cx
						loop	bg_blit_row_mid		; Loop if cx > 0

				add	di,0D0h
				pop	cx
				loop	bg_blit_row_outer		; Loop if cx > 0

		pop	ds
		pop	si
		retn
; --- gf_tga_phase_idx_tbl: animation phase index table (5 sets of ~28 entries) ---
gf_tga_phase_idx_tbl:
		db	 00h, 01h, 02h, 04h, 07h, 09h			; set 0 row 0: phase indices 0..5
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch			; set 0 row 1: phase indices 6..11
		db	 1Eh, 04h, 07h, 09h, 22h, 02h			; set 0 row 2: phase indices 12..17
		db	 25h, 08h, 02h, 28h, 02h, 2Dh			; set 0 row 3: phase indices 18..23
		db	 31h, 36h, 3Bh, 40h, 00h, 01h			; set 0 row 4 + start of set 1
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h			; set 1 row 0
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h			; set 1 row 1
		db	8, 0Ah, '#$'			; set 1 row 2 (chars '#$' = 0x23 0x24)
		db	'&', 8, 27h, ')*'			; set 1 row 3 (ASCII frame chars)
		db	 04h, 32h, 37h, 3Ch, 06h, 00h			; set 1 row 4 + start of set 2
		db	 01h, 02h, 05h, 08h, 02h, 0Eh			; set 2 row 0
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh			; set 2 row 1
		db	 04h, 08h, 02h, 23h, 24h, 26h			; set 2 row 2
		db	 08h, 25h, 29h, 02h, 2Eh, 33h			; set 2 row 3
		db	 38h, 3Dh, 06h, 00h, 01h, 03h			; set 2 row 4 + start of set 3
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h			; set 3 row 0
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h			; set 3 row 1
		db	 0Bh			; set 3 row 2 (1 byte)
		db	'#$'			; set 3 row 2 cont (chars '#$')
		db	'&', 8, 27h, ')+/49>'			; set 3 row 3: ASCII indices
		db	 06h, 00h, 01h, 02h, 04h, 08h			; set 3 row 4 + start of set 4
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh			; set 4 row 0
		db	 1Dh			; set 4 row 1 (1 byte)
		db	' !', 8, 0Ch, '#$'			; set 4 row 1 cont (chars ' !.#$')
		db	'&', 8			; set 4 row 2 (chars '&.')
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah			; set 4 row 3
; --- trailing TGA blit code stub (Sourcer mis-decoded) ---
		db	 3Fh, 06h,0A2h, 43h, 52h,0BEh			; code: cmp; push es; mov [5243h],al; mov si
		db	 55h, 49h,0C7h, 06h, 31h, 52h			; code: ...inc di; mov word [5231h]
		db	0F8h, 41h,0B9h, 12h, 00h			; code: clc; inc cx; mov cx,12h

anim_pass_outer:
				push	cx
				mov	cx,1Ch

anim_pass_mid:
						push	cx
						lodsb				; String [si] to al
						push	si
						call	bg_tile_blit_init
						pop	si
						add	word ptr ds:vga_row_ptr,4
						pop	cx
						loop	anim_pass_mid		; Loop if cx > 0

				add	word ptr ds:vga_row_ptr,0D0h
				pop	cx
				loop	anim_pass_outer		; Loop if cx > 0

		retn

bg_tile_blit_init		proc	near
		push	ds
		mov	cl,20h			; ' '
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B800h
		mov	es,ax
		mov	di,cs:vga_row_ptr
		mov	cx,8

anim_pass_inner:
				push	cx
				lodsw				; String [si] to ax
				call	plane_word_expand
				stosw				; Store ax to es:[di]
				lodsw				; String [si] to ax
				call	plane_word_expand
				stosw				; Store ax to es:[di]
				add	di,1FFCh
				cmp	di,8000h
				jb	loc_267			; Jump if below
				add	di,80A0h

loc_267:
				pop	cx
				loop	anim_pass_inner		; Loop if cx > 0

		pop	ds
		retn

bg_tile_blit_init		endp

plane_word_expand		proc	near
		or	ax,ax			; Zero ?
		jnz	loc_268			; Jump if not zero
		retn

loc_268:
		mov	cx,4

anim_phase_inner:
				push	cx
				add	ax,ax
				adc	cl,cl
				add	ax,ax
				adc	cl,cl
				add	ax,ax
				adc	cl,cl
				add	ax,ax
				adc	cl,cl
				and	cl,0Fh
				mov	bl,cs:anim_phase
				xor	bh,bh			; Zero register
				add	bx,bx
				call	word ptr cs:copy_fn_tbl[bx]	;*
				add	dx,dx
				add	dx,dx
				add	dx,dx
				add	dx,dx
				or	dl,cl
				pop	cx
				loop	anim_phase_inner		; Loop if cx > 0

		mov	ax,dx
		retn

plane_word_expand		endp

; ------------------------------------------------------------------------
; copy_fn_tbl handlers (dispatched via call word ptr cs:copy_fn_tbl[bx] in
; plane_word_expand, with bx=anim_phase*2). Each handler maps a nibble
; value in CL to a remapped nibble (returned in CL via mov cl,ch).
; The 14 bytes before copy_fn_phase_0 encode the word-ptr table itself
; (Sourcer mis-decodes them as cmpsw/dec ax/ror/... code).
; ------------------------------------------------------------------------

copy_fn_tbl_embed:				; 7 word entries (CS offsets)
		cmpsw				; table entries start here -- Sourcer decoded as code
		dec	ax
		ror	byte ptr [bx+si-21h],1	; Rotate
		dec	ax
		cld				; Clear direction
		dec	ax
		daa				; Decimal adjust
		dec	cx

copy_fn_phase_0:				; phase-0 nibble remap handler
		mov	ch,2
		cmp	cl,6
		jne	cfp0_check_E			; Jump if not equal
		jmp	copy_fn_commit

cfp0_check_E:
		mov	ch,0Ah
		cmp	cl,0Eh
		jne	cfp0_check_1			; Jump if not equal
		jmp	copy_fn_commit

cfp0_check_1:
		mov	ch,5
		cmp	cl,1
		jne	cfp0_check_9			; Jump if not equal
		jmp	copy_fn_commit

cfp0_check_9:
		mov	ch,0Dh
		cmp	cl,9
		jne	cfp0_ret			; Jump if not equal
		jmp	copy_fn_commit

cfp0_ret:
		retn

copy_fn_phase_1:
		mov	ch,4
		cmp	cl,3
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Ch
		cmp	cl,0Bh
		je	copy_fn_commit			; Jump if equal
		retn

copy_fn_phase_2:
		mov	ch,1
		cmp	cl,3
		je	copy_fn_commit			; Jump if equal
		mov	ch,9
		cmp	cl,0Bh
		je	copy_fn_commit			; Jump if equal
		mov	ch,3
		cmp	cl,5
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Bh
		cmp	cl,0Dh
		je	copy_fn_commit			; Jump if equal
		retn

copy_fn_phase_3:
		mov	ch,2
		cmp	cl,3
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Ah
		cmp	cl,0Bh
		je	copy_fn_commit			; Jump if equal
		mov	ch,1
		cmp	cl,5
		je	copy_fn_commit			; Jump if equal
		mov	ch,9
		cmp	cl,0Dh
		je	copy_fn_commit			; Jump if equal
		mov	ch,5
		cmp	cl,6
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Dh
		cmp	cl,0Eh
		je	copy_fn_commit			; Jump if equal
		retn

copy_fn_phase_4:
		mov	ch,1
		cmp	cl,5
		je	copy_fn_commit			; Jump if equal
		mov	ch,9
		cmp	cl,0Dh
		je	copy_fn_commit			; Jump if equal
		mov	ch,5
		cmp	cl,3
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Dh
		cmp	cl,0Bh
		je	copy_fn_commit			; Jump if equal
		mov	ch,3
		cmp	cl,6
		je	copy_fn_commit			; Jump if equal
		mov	ch,0Bh
		cmp	cl,0Eh
		je	copy_fn_commit			; Jump if equal
		retn

copy_fn_commit:
		mov	cl,ch
		retn

; anim_seq_tbl: animation sequence / frame index data (parallels EGA
; anim_seq_tbl). Referenced by sprite rendering code via CS-relative
; offsets. Sourcer mis-decodes the leading bytes as code. Real content
; is a series of frame/glyph-index bytes + a set of short descriptor
; tables; the trailing bytes transition into sprite_shape_tbl data.

anim_seq_tbl:					; 70 bytes of frame index data ?-- Sourcer mis-decoded as code
		db	 07h, 08h, 09h, 0Ah, 07h, 08h, 0Bh, 0Ch, 07h, 08h	; row 0: anim frame indices 0..9
		db	 09h, 0Ah, 19h, 3Dh, 61h, 27h, 1Dh, 1Eh, 1Dh, 1Eh	; row 1: anim frame indices 10..19
		db	 1Fh, 20h, 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h, 0Dh, 0Eh	; row 2: anim frame indices 20..29
		db	 0Fh, 10h, 0Fh, 10h, 0Dh, 0Eh, 0Fh, 10h, 17h, 18h	; row 3: anim frame indices 30..39
		db	 3Eh, 5Ch, 62h, 26h, 2Ah, 25h, 21h, 22h, 21h, 22h	; row 4: anim frame indices 40..49
		db	 23h, 24h, 21h, 22h, 21h, 22h, 09h, 0Ah, 07h, 08h	; row 5: anim frame indices 50..59
		db	 07h, 08h, 09h, 0Ah, 07h, 08h, 19h, 54h, 59h, 5Dh	; row 6: anim frame indices 60..69
		db	 63h, 32h, 2Fh, 2Eh, 1Fh, 20h			; row 7: continuation
		db	 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h			; row 8: continuation
		db	 1Fh, 20h, 0Fh, 10h, 11h, 12h			; row 9: continuation
		db	 0Fh, 10h, 0Dh, 0Eh, 17h, 18h			; row 10: continuation
		db	'PUZ^df(0#$'			; row 11: ASCII frame indices (10 bytes)
		db	'!"#$'			; row 12: ASCII frame indices (4 bytes)
		db	'!"#$'			; row 13: ASCII frame indices (4 bytes)
		db	 07h, 08h, 0Ah, 0Ch, 07h, 08h			; row 14: anim frame indices
		db	 09h, 0Ah, 1Ah			; row 15: 3-byte partial
		db	'4QV[_eg/-'			; row 16: ASCII frame indices (9 bytes)
		db	 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh			; row 17: anim frame indices
		db	 1Fh, 20h, 1Dh, 1Eh, 0Fh, 10h			; row 18: anim frame indices
		db	 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h			; row 19: anim frame indices
		db	 49h, 4Dh, 52h, 57h, 00h			; row 20: 5-byte partial + zero terminator
		db	'`ihjk(&!"+&!"!"'			; row 21: ASCII frame indices (15 bytes)
		db	7			; row 22: 1-byte
		db	8, 9, 0Ah, 9, 0Ah, 1Bh, 'FJNSX'			; row 23: anim indices + ASCII
		db	 00h, 00h, 00h, 00h, 69h, 6Ch			; row 24: 4 zeros + 0x69,0x6C
		db	 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh			; row 25: anim frame indices
		db	 1Fh, 20h, 1Fh, 20h, 13h, 14h			; row 26: anim frame indices
		db	 13h, 14h, 17h, 18h			; row 27: 4-byte partial
		db	 43h, 47h, 4Bh, 4Fh			; row 28: 4-byte partial
		db	7 dup (0)			; row 29: 7-byte zero pad
		db	'mno)&!"*%!"'			; row 30: ASCII frame indices (11 bytes)
		db	 15h, 16h, 15h, 16h, 1Ch			; row 31: 5-byte partial
		db	 35h, 44h, 48h, 4Ch			; row 32: 4-byte partial
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
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 3: (3,4) x3
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 4: (3,4) x3
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 5: (3,4) x3
		db	 03h, 04h, 05h, 06h, 05h, 06h			; tile pair lookup row 6: (3,4) + (5,6) x2
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 7: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 8: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 9: (5,6) x3
		db	 06h, 05h, 05h, 06h, 05h, 06h			; tile pair lookup row 10: swapped + (5,6) x2
; --- trailing TGA blit code stub (Sourcer mis-decoded as data) ---
		db	 1Eh, 50h, 02h,0FFh,0E8h, 60h			; code: push ds; push ax; add bh,bh; call
		db	 06h, 8Bh,0F8h, 2Eh,0C7h, 06h			; code: push es; mov di,ax; cs prefix; mov word
		db	 2Fh, 52h,0DEh, 51h, 58h,0B1h			; code: ...mov [522F],...; push cx; pop ax; mov cl
		db	 20h,0F6h,0E1h, 05h, 00h, 60h			; code: cl=20h; mul cl; add ax,6000h
		db	 8Bh,0F0h, 2Eh, 8Eh, 1Eh, 2Ch			; code: mov si,ax; mov ds,cs:[2Ch]
		db	0FFh,0B8h, 00h,0B8h, 8Eh,0C0h			; code: ...mov ax,B800h; mov es,ax
		db	0B9h, 08h, 00h			; code: mov cx,8 immediate

shift_blit_row_loop:
				lodsw				; String [si] to ax
				call	color_nibble_expand
				stosw				; Store ax to es:[di]
				lodsw				; String [si] to ax
				call	color_nibble_expand
				stosw				; Store ax to es:[di]
				add	di,1FFCh
				cmp	di,8000h
				jb	loc_276			; Jump if below
				add	di,80A0h

loc_276:
				loop	shift_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

; draw_hero_gfx: blit hero graphics data (from hero_gfx_tbl) into VGA at
; offset 0x4D68 (hero sprite area). Uses bitmask_word=0xFF77 pattern.
; Parallels EGA draw_hero_gfx. Called via CS-relative call.

draw_hero_gfx:
		push	ds
		mov	word ptr cs:bitmask_word,0FF77h
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:hero_gfx_tbl[bx]
		mov	di,4D68h
		mov	ax,0B800h
		mov	es,ax
		mov	cx,18h

shift_blit_col_loop:
				lodsw				; String [si] to ax
				xchg	ah,al
				call	tga_plane_decode
				not	bp
				and	es:[di],bp
				or	es:[di],dx
				call	tga_plane_decode
				not	bp
				and	es:[di+2],bp
				or	es:[di+2],dx
				lodsw				; String [si] to ax
				xchg	ah,al
				call	tga_plane_decode
				not	bp
				and	es:[di+4],bp
				or	es:[di+4],dx
				call	tga_plane_decode
				not	bp
				and	es:[di+6],bp
				or	es:[di+6],dx
				add	di,2000h
				cmp	di,8000h
				jb	loc_278			; Jump if below
				add	di,80A0h

loc_278:
				loop	shift_blit_col_loop		; Loop if cx > 0

		pop	ds
		retn

; sprite_shape_tbl_2: second sprite shape/pattern table block. Like
; sprite_shape_tbl above, referenced via pattern_ptr_tbl. First 6 bytes
; are mis-decoded as 'pop es / dec sp / ...'; they are actually table
; header bytes (three word entries: 0x4C07 repeated thrice).

sprite_shape_tbl_2:
		pop	es			; data byte 07 (header)
		dec	sp			; data byte 4C
		pop	es			; data byte 07 (header)
		dec	sp			; data byte 4C
		pop	es			; data byte 07 (header)
		dec	sp			; data byte 4C
		db	 67h, 4Ch, 67h, 4Ch,0C7h, 4Ch			; sprite pointer trio (4C67 x2 + 4CC7)
		db	45 dup (0)
; --- gf_tga_proj_sprite_a: small TGA projectile bitmap ---
gf_tga_proj_sprite_a:
		db	 02h, 00h, 00h, 00h, 06h, 00h			; sprite a row 0
		db	 00h, 00h, 06h, 00h, 00h, 00h			; sprite a row 1
		db	 0Eh, 00h, 00h, 00h, 0Eh, 00h			; sprite a row 2
		db	 00h, 00h, 0Ch, 00h, 00h, 00h			; sprite a row 3
		db	 0Eh, 00h, 00h, 00h, 1Ch, 00h			; sprite a row 4
		db	 00h, 00h, 0Ch, 00h, 00h, 00h			; sprite a row 5
		db	 1Ch, 00h, 00h, 00h, 1Ch, 00h			; sprite a row 6
		db	 00h, 00h, 1Ch, 00h, 00h, 00h			; sprite a row 7
		db	 1Ch			; sprite a row 8 (1-byte trail)
		db	16 dup (0)
; --- gf_tga_proj_sprite_b: medium TGA projectile bitmap ---
gf_tga_proj_sprite_b:
		db	 80h, 00h, 00h, 01h, 80h, 00h			; sprite b row 0
		db	 00h, 03h, 80h, 00h, 00h, 03h			; sprite b row 1
		db	 00h, 00h, 00h, 07h, 80h, 00h			; sprite b row 2
		db	 00h, 07h, 00h, 00h, 00h, 07h			; sprite b row 3
		db	 00h, 00h, 00h, 0Fh, 00h, 00h			; sprite b row 4
		db	 00h, 0Eh, 00h, 00h, 00h, 0Fh			; sprite b row 5
		db	 00h, 00h, 00h, 1Eh, 00h, 00h			; sprite b row 6
		db	 00h, 0Eh, 00h, 00h, 00h, 1Fh			; sprite b row 7
		db	 00h, 00h, 00h, 1Eh, 00h, 00h			; sprite b row 8
		db	 00h, 1Fh, 00h, 00h, 00h, 1Eh			; sprite b row 9
		db	 00h, 00h, 00h, 1Eh, 00h, 00h			; sprite b row 10
		db	 00h, 1Eh, 00h, 00h, 00h, 1Eh			; sprite b row 11
		db	 00h, 00h, 00h, 1Ch, 00h, 00h			; sprite b row 12
		db	 00h			; sprite b row 13 (1 byte)
		db	3Fh			; sprite b terminator
		db	12 dup (0)
; --- gf_tga_proj_sprite_c: large TGA projectile bitmap ---
gf_tga_proj_sprite_c:
		db	 40h, 00h, 00h, 00h,0C0h, 00h			; sprite c row 0
		db	 00h, 01h,0C0h, 00h, 00h, 03h			; sprite c row 1
		db	 80h, 00h, 00h, 03h, 80h, 00h			; sprite c row 2
		db	 00h, 07h, 80h, 00h, 00h, 07h			; sprite c row 3
		db	 00h, 00h, 00h, 07h, 00h, 00h			; sprite c row 4
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh			; sprite c row 5
		db	 00h, 00h, 00h, 0Eh, 00h, 00h			; sprite c row 6
		db	 00h, 1Fh, 00h, 00h, 00h, 0Eh			; sprite c row 7
		db	 00h, 00h, 00h, 1Fh, 00h, 00h			; sprite c row 8
		db	 00h, 1Eh, 00h, 00h, 00h, 1Fh			; sprite c row 9
		db	 00h, 00h, 00h, 1Eh, 00h, 00h			; sprite c row 10
		db	 00h, 1Fh, 00h, 00h, 00h, 1Fh			; sprite c row 11
		db	 00h, 00h, 00h, 1Eh, 00h, 00h			; sprite c row 12
		db	 03h, 1Ch,0C0h, 00h, 00h,0FFh			; sprite c row 13 (last data row)
; --- trailing TGA blit code stub (Sourcer mis-decoded) ---
		db	 00h, 00h, 2Eh,0C7h, 06h, 3Bh			; code: cs prefix; mov word [523B],...
		db	 52h, 77h,0FFh, 1Eh, 0Ah,0C0h			; code: ja 0FFh; push ds; or al,c0h
		db	 78h, 10h, 24h, 03h,0B2h, 40h			; code: js +10; and al,3; mov dl,40h
		db	0F6h,0E2h, 05h,0E8h, 4Dh, 8Bh			; code: mul dl; add ax,4DE8h; mov si,ax
		db	0F0h,0BDh, 01h, 00h,0EBh, 0Eh			; code: ...mov bp,1; jmp short +0Eh
		db	 24h, 01h, 8Ah,0E0h, 32h,0C0h			; code: and al,1; mov ah,al; xor al,al
		db	 05h,0E8h, 4Eh, 8Bh,0F0h,0BDh			; code: add ax,4EE8h; mov si,ax; mov bp
		db	 04h, 00h, 8Ah,0C3h, 24h, 01h			; code: bp=4; mov al,bl; and al,1
		db	 02h,0C0h, 02h,0C0h,0A2h, 44h			; code: add al,al x2; mov [5244],al
		db	 52h,0D1h,0EBh, 8Ah,0FBh, 8Ah			; code: ...shr bx,1; mov bh,bl; mov bl
		db	0D9h,0E8h, 4Fh, 04h, 8Bh,0F8h			; code: ...call rel+044F; mov di,ax
		db	0B8h, 00h,0B8h, 8Eh,0C0h, 8Bh			; code: mov ax,B800h; mov es,ax; mov...
		db	0CDh			; code: ...cx (final byte)

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
						xchg	ah,al
						call	tga_plane_decode
						push	ax
						call	ega_fill_bit_range_wide
						pop	ax
						call	tga_plane_decode
						call	ega_fill_bit_range_wide
						pop	cx
						loop	shift_blit_inner		; Loop if cx > 0

						pop	di
						add	di,2000h
						cmp	di,8000h
						jb	loc_282			; Jump if below
						add	di,tga_vram_wrap

loc_282:
						pop	cx
						loop	shift_blit_mid		; Loop if cx > 0

				pop	di
				add	di,8
				pop	cx
				loop	shift_blit_outer		; Loop if cx > 0

		pop	ds
		retn

ega_fill_bit_range_wide		proc	near
		push	dx
		mov	cl,cs:shift_count
		mov	ax,bp
		mov	bh,al
		xor	bl,bl			; Zero register
		xor	al,al			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		not	bx
		not	ah
		and	es:[di],bh
		and	es:[di+1],bl
		and	es:[di+2],ah
		pop	ax
		mov	bh,al
		xor	bl,bl			; Zero register
		xor	al,al			; Zero register
		shr	bx,cl			; Shift w/zeros fill
		shr	ax,cl			; Shift w/zeros fill
		or	bl,ah
		mov	ah,al
		or	es:[di],bh
		inc	di
		or	es:[di],bl
		inc	di
		or	es:[di],ah
		retn

ega_fill_bit_range_wide		endp

		db	22 dup (0)
; --- gf_tga_tile_set: TGA tile/sprite frames ---
gf_tga_tile_set:
gf_tga_tile_00:
		db	 10h, 00h, 00h, 10h, 60h, 00h			; tile 00 row 0
		db	 00h, 07h,0C0h, 00h, 00h, 07h			; tile 00 row 1
		db	0C0h, 00h, 00h, 07h,0C0h, 00h			; tile 00 row 2
		db	 00h, 0Ch, 10h, 00h, 00h, 10h			; tile 00 row 3
		db	 00h			; tile 00 row 4 (1 byte trail)
		db	26 dup (0)
gf_tga_tile_01:
		db	 01h, 00h, 00h, 00h, 01h, 00h			; tile 01 row 0
		db	 00h, 00h, 40h, 04h, 00h, 00h			; tile 01 row 1
		db	 01h, 00h, 00h, 00h, 09h, 20h			; tile 01 row 2
		db	 00h, 00h, 03h, 80h, 00h, 04h			; tile 01 row 3
		db	 57h,0D4h, 80h, 00h, 03h, 80h			; tile 01 row 4
		db	 00h, 00h, 09h, 20h, 00h, 00h			; tile 01 row 5
		db	 01h, 00h, 00h, 00h, 40h, 04h			; tile 01 row 6
		db	 00h, 00h, 01h, 00h, 00h, 00h			; tile 01 row 7
		db	 01h			; tile 01 row 8 (1 byte trail)
		db	7 dup (0)
gf_tga_tile_02:
		db	 01h, 00h, 00h, 00h, 01h, 00h			; tile 02 row 0
		db	 00h, 00h, 01h, 00h, 00h, 00h			; tile 02 row 1
		db	 02h, 80h, 00h, 00h, 83h, 80h			; tile 02 row 2
		db	 00h, 00h, 23h, 88h, 00h, 00h			; tile 02 row 3
		db	 0Dh,0B0h, 00h, 00h, 0Bh,0E8h			; tile 02 row 4
		db	 00h, 96h,0FFh,0FFh,0B9h, 00h			; tile 02 row 5 (center)
		db	 17h,0E8h, 00h, 00h, 0Bh, 58h			; tile 02 row 6
		db	 00h, 00h, 23h, 82h, 00h, 00h			; tile 02 row 7
		db	 02h, 80h, 80h, 02h, 01h, 00h			; tile 02 row 8
		db	 00h, 00h, 01h, 00h, 00h, 00h			; tile 02 row 9
		db	 01h, 00h			; tile 02 row 10 (2 byte trail)
		db	8 dup (0)
gf_tga_tile_03:
		db	 10h, 10h, 00h, 00h, 00h, 04h			; tile 03 row 0
		db	 00h, 00h, 80h, 00h, 80h, 03h			; tile 03 row 1
		db	 00h, 00h, 71h, 0Ch, 00h, 00h			; tile 03 row 2
		db	 3Dh, 38h, 00h, 00h, 07h,0F0h			; tile 03 row 3
		db	 00h, 00h, 97h,0E5h, 00h, 00h			; tile 03 row 4
		db	 0Fh,0F0h, 00h, 00h, 1Fh, 38h			; tile 03 row 5
		db	 00h, 00h, 39h, 0Eh, 00h, 00h			; tile 03 row 6
		db	0E1h, 01h, 80h, 01h, 00h, 00h			; tile 03 row 7
		db	 40h, 04h, 00h, 00h, 08h, 10h			; tile 03 row 8
		db	35 dup (0)
gf_tga_tile_04:
		db	 92h, 4Ah,0AAh,0EBh, 00h			; tile 04: 5-byte solid pattern
		db	34 dup (0)
gf_tga_tile_05:
		db	 01h, 00h, 00h, 00h, 01h, 00h			; tile 05 row 0
		db	 00h, 01h, 01h, 00h, 00h, 00h			; tile 05 row 1
		db	 82h, 00h, 00h, 00h,0ABh, 00h			; tile 05 row 2
		db	 00h, 01h, 5Dh, 04h, 24h,0AEh			; tile 05 row 3
		db	0EFh,0FFh,0FFh,0FFh,0FFh, 04h			; tile 05 row 4 (full center)
		db	 24h,0ABh,0EFh, 00h, 00h, 01h			; tile 05 row 5
		db	 5Dh, 00h, 00h, 00h, 22h, 00h			; tile 05 row 6
		db	 00h, 00h, 81h, 00h, 00h, 00h			; tile 05 row 7
		db	 01h, 00h, 00h, 00h, 01h, 00h			; tile 05 row 8
		db	19 dup (0)
gf_tga_tile_06:
		db	 81h, 00h, 00h, 00h,0C4h, 00h			; tile 06 row 0
		db	 00h, 00h,0BCh, 00h, 00h, 00h			; tile 06 row 1
		db	0EEh,0EAh, 24h, 20h,0FFh,0FFh			; tile 06 row 2
		db	0FFh,0FFh,0FBh,0AAh, 24h, 20h			; tile 06 row 3
		db	0FDh, 40h, 00h, 00h,0E6h, 00h			; tile 06 row 4
		db	 00h, 00h, 40h, 80h, 00h, 00h			; tile 06 row 5
		db	 00h			; tile 06 row 6 (1 byte)
		db	20h			; tile 06 trailing marker
		db	42 dup (0)
gf_tga_tile_07:
		db	0D7h, 55h, 52h, 49h			; tile 07: 4-byte solid bar
		db	60 dup (0)
gf_tga_tile_08:
		db	0A7h, 54h, 90h, 04h, 00h			; tile 08: 5-byte pattern
		db	37 dup (0)
gf_tga_tile_09:
		db	 10h, 00h, 00h, 00h, 04h, 00h			; tile 09 row 0
		db	 00h, 00h, 00h, 80h, 00h, 00h			; tile 09 row 1
		db	 00h, 71h, 00h, 00h, 00h, 3Dh			; tile 09 row 2
		db	 00h, 00h, 00h, 07h, 10h, 04h			; tile 09 row 3
		db	 00h, 97h, 00h, 00h, 00h, 0Fh			; tile 09 row 4
		db	 00h, 00h, 00h, 1Fh, 00h, 00h			; tile 09 row 5
		db	 00h, 39h, 00h, 00h, 00h,0E1h			; tile 09 row 6
		db	 00h, 00h, 01h, 00h, 00h, 00h			; tile 09 row 7
		db	 04h, 00h, 00h, 00h, 10h, 00h			; tile 09 row 8
		db	 00h, 00h, 00h, 00h, 00h, 10h			; tile 09 row 9 (trailing 0x10)
		db	7 dup (0)
gf_tga_tile_0A:
		db	 80h, 00h, 00h, 03h, 00h, 00h			; tile 0A row 0
		db	 00h, 0Ch, 00h, 00h, 00h, 38h			; tile 0A row 1
		db	 00h, 00h, 00h,0F0h, 00h, 00h			; tile 0A row 2
		db	 00h,0E5h, 02h, 00h, 10h,0F0h			; tile 0A row 3
		db	 00h, 00h, 00h, 3Ch, 00h, 00h			; tile 0A row 4
		db	 00h, 07h, 00h, 00h, 00h, 00h			; tile 0A row 5
		db	0C0h, 00h, 00h, 00h, 20h, 00h			; tile 0A row 6
		db	 00h, 00h, 04h			; tile 0A row 7 (3-byte trail)
		db	38 dup (0)
gf_tga_tile_0B:
		db	 20h, 09h, 2Ah,0E5h			; tile 0B: 4-byte pattern
		db	28 dup (0)
; --- fade_outer_loop setup code stub (Sourcer mis-decoded) ---
		db	 51h, 1Eh, 56h, 8Ch,0C8h, 05h			; code: push cx; push ds; push si; mov ax,cs
		db	 00h, 30h, 8Eh,0C0h,0B8h, 20h			; code: add ax,3000h; mov es,ax; mov ax,20h
		db	 00h,0F7h,0E1h, 8Bh,0C8h,0BFh			; code: mul cx; mov cx,ax; mov di
		db	 00h, 00h,0F3h,0A4h, 5Fh, 07h			; code: rep movsb; pop di; pop es
		db	 59h, 8Ch,0C8h, 05h, 00h, 30h			; code: pop cx; mov ax,cs; add ax,3000h
		db	 8Eh,0D8h,0BEh, 00h, 00h			; code: mov ds,ax; mov si,0

fade_outer_loop:
				push	cx
				mov	cx,8

fade_mid_loop:
						push	cx
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	dx,ax
						lodsw				; String [si] to ax
						xchg	ah,al
						mov	cx,ax
						mov	cs:vga_row_ptr,dx
						mov	cs:scroll_src_ofs,cx
						or	ax,dx
						mov	bx,ax
						shr	bx,1			; Shift w/zeros fill
						or	ax,bx
						add	bx,bx
						add	bx,bx
						or	ax,bx
						not	ax
						mov	cs:bitmask_word,ax
						call	plane_pair_rol
						mov	ax,dx
						xchg	ah,al
						stosw				; Store ax to es:[di]
						call	plane_pair_rol
						mov	ax,dx
						xchg	ah,al
						stosw				; Store ax to es:[di]
						call	dither_bit_expand
						mov	es:[bp],dl
						inc	bp
						pop	cx
						loop	fade_mid_loop		; Loop if cx > 0

				pop	cx
				loop	fade_outer_loop		; Loop if cx > 0

		retn

plane_pair_rol		proc	near
		mov	cx,4

fade_mask_rot:
				rol	word ptr cs:scroll_src_ofs,1	; Rotate
				adc	dx,dx
				rol	word ptr cs:vga_row_ptr,1	; Rotate
				adc	dx,dx
				rol	word ptr cs:scroll_src_ofs,1	; Rotate
				adc	dx,dx
				rol	word ptr cs:vga_row_ptr,1	; Rotate
				adc	dx,dx
				loop	fade_mask_rot		; Loop if cx > 0

		retn

plane_pair_rol		endp

dither_bit_expand		proc	near
		mov	cx,8

fade_bit_loop:
				xor	al,al			; Zero register
				rol	word ptr cs:bitmask_word,1	; Rotate
				adc	al,al
				rol	word ptr cs:bitmask_word,1	; Rotate
				adc	al,al
				cmp	al,3
				je	loc_287			; Jump if equal
				xor	al,al			; Zero register

loc_287:
				and	al,1
				add	dl,dl
				or	dl,al
				loop	fade_bit_loop		; Loop if cx > 0

		retn

dither_bit_expand		endp

nibble_pack_ax		proc	near
		mov	cx,4

fade_nibble_loop:
				add	dl,dl
				sbb	dh,dh
				and	dh,0Fh
				add	ax,ax
				add	ax,ax
				add	ax,ax
				add	ax,ax
				or	al,dh
				loop	fade_nibble_loop		; Loop if cx > 0

		xchg	ah,al
		retn

nibble_pack_ax		endp

ega_row_addr_calc		proc	near
		mov	dh,bl
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		ror	dh,1			; Rotate
		and	dx,6000h
		mov	ax,0A0h
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		mul	bl			; ax = reg * al
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn

ega_row_addr_calc		endp

; --- gf_tga_color_jump_tbl: 6-entry word jump table for color decode dispatch ---
gf_tga_color_jump_tbl:
		db	0DEh, 51h,0EEh, 51h,0FEh, 51h			; jump entries 0..2: 51DE, 51EE, 51FE
		db	 0Eh, 52h, 1Eh, 52h, 0Eh, 52h			; jump entries 3..5: 520E, 521E, 520E
; --- gf_tga_color_lookup_tbl: 14 rows x 6-byte CGA-to-TGA color/shade mapping (84 bytes total) ---
gf_tga_color_lookup_tbl:
		db	 00h, 07h, 04h, 02h, 07h, 0Fh			; row 0: color/shade indices
		db	 0Ch, 0Eh, 04h, 0Ch, 0Ch, 0Eh			; row 1: color/shade indices
		db	 02h, 0Eh, 0Eh, 0Ah, 00h, 04h			; row 2: color/shade indices
		db	 03h, 08h, 04h, 0Ch, 07h, 06h			; row 3: color/shade indices
		db	 03h, 07h, 0Bh, 0Ah, 08h, 06h			; row 4: color/shade indices
		db	 0Ah, 0Eh, 00h, 07h, 03h, 01h			; row 5: color/shade indices
		db	 07h, 0Fh, 0Bh, 09h, 03h, 0Bh			; row 6: color/shade indices
		db	 0Bh, 09h, 01h, 09h, 09h, 09h			; row 7: color/shade indices
		db	 00h, 01h, 08h, 05h, 01h, 09h			; row 8: color/shade indices
		db	 07h, 05h, 08h, 07h, 0Eh, 0Ch			; row 9: color/shade indices
		db	 05h, 05h, 0Ch, 0Dh, 00h, 08h			; row 10: color/shade indices
		db	 01h, 05h, 08h, 0Eh, 07h, 0Ch			; row 11: color/shade indices
		db	 01h, 07h, 09h, 05h, 05h, 0Ch			; row 12: color/shade indices
		db	 05h, 0Dh,0C3h, 00h			; row 13 (4-byte trail with retn (0xC3) + zero pad)
		db	1138 dup (0)			; trailing zero pad to fill chunk

seg_a		ends

		end	start
