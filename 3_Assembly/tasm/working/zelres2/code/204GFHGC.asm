
PAGE  59,132

;==========================================================================
;
;  204GFHGC.BIN - Hercules Graphics Fill Driver (zelres2 chunk 4)
;
;  Hercules (HGC) monochrome graphics variant of the battle/gameplay
;  sprite-fill driver. Renders sprites, tiles, scrolling backgrounds, and
;  hero/enemy graphics for 720x348 1bpp Hercules mode. Parallels 202GFEGA
;  in structure (same dispatch table layout, same drv_init_stub patchable
;  byte, same sprite-scan loop).
;
;  Connections:
;    Loads:        none -- driver is resident; sprite/tile data staged by
;                  200FIGHT into game_seg buffers (hgc_sprite_src,
;                  hgc_extended_src, hgc_plane_buf_a).
;    Calls into:   ds:dispatch_tbl[bx] (game-DS animation handler table);
;                  cs:copy_fn_tbl entries (HGC plane copy variants);
;                  internal frame_row_driver / anim_refresh_all /
;                  projectile_spawn_check dispatchers; cs:[11Ah] -- driver
;                  fn (input/page advance); no cross-chunk calls outside
;                  its own driver fn table.
;    Called by:    200FIGHT (and 201SELCT) via the graphics-driver dispatch
;                    slots at cs:[2000h..303Ch] -- this module IS the HGC
;                    driver. Loaded at game_seg:9000h by game.asm when
;                    gvar_gfx_mode selects Hercules. Entry via drv_init_stub
;                    at cs:[10Ch].
;    Reads/writes: hgc_sprite_src / hgc_plane_alt / hgc_extended_src
;                    (DS:0B000h / 0B17Eh / 0D000h), hgc_plane_buf_a
;                    (DS:8640h, populated from internal_tbl_68), cur_color_pair
;                    + vga_row_ptr / scroll_vga_ofs / row_counter (CS-resident
;                    driver state at CS:4FE2h+), Hercules B000h framebuffer
;                    (1bpp, 4-bank interlace +2000h).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; External data references (outside this module's CS segment).

; --- Game-segment data pointers (in game_seg via DS) ---
hgc_src_base2	equ	6333h			;* secondary HGC source base in game_seg
hgc_plane_buf_a	equ	8640h			;* HGC plane buffer A (64-byte table)
sprite_src_base	equ	8690h			;* sprite source graphics base offset in game_seg
hgc_sprite_src	equ	0B000h			;* HGC sprite source data base (monochrome)
hgc_plane_alt	equ	0B17Eh			;* HGC alternate plane offset
hgc_extended_src equ	0D000h			;* HGC extended source buffer

; --- Internal driver tables (CS-relative) ---
dispatch_tbl	equ	317Eh			;* function dispatch table (word array)
anim_frame_tbl	equ	37A2h			;* animation frame offset table
pattern_ptr_tbl	equ	3844h			;* pattern pointer table
sprite_tmp_buf	equ	45ABh			;* sprite temporary pixel buffer
color_map_tbl	equ	46D0h			;* color map table (word array)
phase_offset_tbl equ	4982h			;* phase/shift offset table
bg_tile_src	equ	4C38h			;* background tile source pointer
copy_fn_tbl	equ	4EFFh			;* HGC copy function pointer table (word array)
internal_tbl_68	equ	4F46h			;* internal 64-byte table (copied to hgc_plane_buf_a)
hero_gfx_tbl	equ	4F86h			;* hero graphics data table

; --- Driver state variables (CS-segment scratch area) ---
cur_color_pair	equ	4FE2h			;* current color pair word (set from palette byte)
vga_row_ptr	equ	4FE4h			;* current VGA row byte offset (word)
scroll_vga_ofs	equ	4FE6h			;* scroll destination VGA byte offset (word)
scroll_state	equ	4FE8h			;* scroll state word
row_counter	equ	4FEAh			;* row countdown (0x12 rows per frame)
col_idx		equ	4FEBh			;* current column index (byte)
row_idx		equ	4FECh			;* current row index (byte)
palette_byte	equ	4FEDh			;* palette byte for current sprite
scroll_src_ofs	equ	4FEFh			;* scroll source VGA byte offset (word)
scroll_gfx_ptr	equ	4FF1h			;* scroll graphics data pointer (word)
scroll_delta	equ	4FF3h			;* scroll delta (word: col byte + row byte)
shift_count	equ	4FF5h			;* shift count byte
anim_phase	equ	4FF7h			;* animation pass counter (0-7, decremented)
hgc_mask_state	equ	4FF8h			;* HGC mask state byte (writer fill mask)
sprite_row_buf	equ	4FF9h			;* sprite row intermediate buffer (word)
sprite_state_a	equ	5009h			;* sprite slot state byte A (0xFF=empty, 0xFC=hidden)
sprite_state_b	equ	500Ah			;* sprite slot state byte B
sprite_pos	equ	500Dh			;* sprite position word (col/row packed)
sprite_cache_tbl equ	5016h			;* sprite HGC cache table (word array, indexed by slot*2)
sprite_cache_b	equ	5116h			;* sprite cache table B (32-entry word array)
sprite_ring_buf	equ	5216h			;* sprite ring buffer 0x90 bytes
pattern_buf	equ	52A6h			;* pattern scratch buffer

; --- Game-segment lookup tables ---
gvar_game_seg_b	equ	6000h			;* duplicate of game_data_base (type-A sprite tbl base)
sprite_src_c	equ	0A05Ah			;* sprite source table C (wrap constant)
hgc_plane_alt_b	equ	0B24Fh			;* alternate HGC plane offset B

; --- Pattern/background data ---

; --- Global variables (game_seg:0xFFxx) ---

; --- Fixed HGC/VGA layout constants ---
zero_ofs	equ	0			;* zero constant
hgc_hud_ofs	equ	4FDh			;* HUD/status area byte offset in HGC framebuffer
hgc_ui_ofs	equ	0D85h			;* UI area byte offset
hgc_draw_ofs	equ	47CDh			;* drawing area byte offset
hgc_wrap_limit	equ	6000h			;* HGC row-wrap test limit (same as game_data_base)
hgc_wrap_add_a	equ	0A058h			;* HGC row-wrap addend A
hgc_wrap_add_b	equ	0A05Ah			;* HGC row-wrap addend B (same as sprite_src_c)
level_seg_ofs	equ	2000h			;* segment offset for level/map data

hgc_seg		equ	0B000h			;* HGC framebuffer segment (monochrome)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gfhgc_main		proc	far

start:
; gfhgc_main inline init block (0x0000-0x005A):
; -- The first bytes are decoded by Sourcer as bogus mnemonics because a HGC-only
;    dispatch table at 0x0006-0x0035 lives before the real code begins.
;    Keeping those bytes as db with decode notes.
;
; [0x0000-0x0005] Sourcer decodes as: mov dh,22h / add [bx+si],al / sub al,30h ?-- data
		db	0B6h, 22h		; mov dh,22h (data value, not code)
		db	 00h, 00h		; table alignment
		db	 2Ch, 30h		; sub al,30h (data value, not code)
; [0x0006-0x0035] HGC internal pointer/address table (48 bytes of dispatch offsets)
		db	 62h, 39h, 15h, 3Fh,0D3h, 3Dh	; dispatch entries 0..2 (offsets 3962, 3F15, 3DD3)
		db	0ACh, 40h,0E4h, 44h,0D5h, 3Fh	; dispatch entries 3..5 (offsets 40AC, 44E4, 3FD5)
		db	 7Ah, 32h,0A6h, 37h,0FEh, 40h	; dispatch entries 6..8 (offsets 327A, 37A6, 40FE)
		db	 64h, 40h, 4Ch, 39h, 5Fh, 42h	; dispatch entries 9..11 (offsets 4064, 394C, 425F)
		db	0FEh, 44h, 48h, 45h, 37h, 46h	; dispatch entries 12..14 (offsets 44FE, 4548, 4637)
		db	 5Ch, 40h, 0Fh, 49h, 44h, 49h	; dispatch entries 15..17 (offsets 405C, 490F, 4944)
		db	0AEh, 4Ah, 6Ch, 4Eh, 31h, 4Fh	; dispatch entries 18..20 (offsets 4AAE, 4E6C, 4F31)
; [0x0030] Real init code (common to all GF* drivers):
		push	cs
		pop	es
		mov	di,sprite_cache_tbl
		xor	ax,ax
		mov	cx,80h
		rep	stosw				; zero sprite_cache_tbl (0x80 words)
; [0x003C] drv_init_stub: label is at instruction start, so full mnemonic is valid.
; The opcode byte (FEh) is a patch target -- callers may overwrite it to skip or alter init.

drv_init_stub:
		inc	byte ptr ds:[anim_phase]	; FE 06 F7 4F  (opcode byte patched by caller)
		mov	word ptr ds:[vga_row_ptr],hgc_hud_ofs
		mov	si,word ptr ds:[sprite_data_ptr]
		sub	si,21h
; [0x004D-0x004F] call with mid-instruction label: hgc_row_ofs labels the displacement bytes.
; Callers patch the displacement (hgc_row_ofs) to redirect this call at runtime.
; Current target: 0050h + 14F0h = 1540h (si_wrap_lo).
		db	0E8h				; call near opcode
hgc_row_ofs	db	0F0h, 14h			; displacement (patch target); initially calls 1540h
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
				jz	scan_s1			; Jump if zero
				call	sprite_slot_init

scan_s1:
				inc	si
				inc	bx
				test	byte ptr [si],80h
				jz	scan_s2			; Jump if zero
				call	sprite_slot_init

scan_s2:
				inc	si
				inc	bx
				test	byte ptr [si],80h
				jz	scan_s3			; Jump if zero
				call	sprite_slot_init

scan_s3:
				inc	si
				inc	bx
				test	byte ptr [si],80h
				jz	scan_s4			; Jump if zero
				call	sprite_slot_init

scan_s4:
				inc	si
				inc	bx
				pop	cx
				loop	sprite_scan_loop	; Loop if cx > 0

		test	byte ptr [si],80h
		jz	scan_tail_a		; Jump if zero
		call	sprite_slot_init

scan_tail_a:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	scan_tail_b		; Jump if zero
		call	sprite_slot_init

scan_tail_b:
		inc	si
		inc	bx
		test	byte ptr [si],80h
		jz	scan_tail_c		; Jump if zero
		call	sprite_slot_init

scan_tail_c:
		inc	si
		test	byte ptr [si],80h
		jz	row_scan_done		; Jump if zero
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
				jns	col_scan_enter		; Jump if not sign
				call	sprite_wide_row_render

col_scan_enter:
				mov	cx,6

col_scan_loop:
						push	cx
						cmpsb				; Cmp [si] to es:[di]
						jz	col_s1			; Jump if zero
						call	sprite_state_update

col_s1:
						inc	bx
						cmpsb				; Cmp [si] to es:[di]
						jz	col_s2			; Jump if zero
						call	sprite_state_update

col_s2:
						inc	bx
						cmpsb				; Cmp [si] to es:[di]
						jz	col_s3			; Jump if zero
						call	sprite_state_update

col_s3:
						inc	bx
						cmpsb				; Cmp [si] to es:[di]
						jz	col_s4			; Jump if zero
						call	sprite_state_update

col_s4:
						inc	bx
						pop	cx
						loop	col_scan_loop		; Loop if cx > 0

				cmpsb				; Cmp [si] to es:[di]
				jz	col_tail_a		; Jump if zero
				call	sprite_state_update

col_tail_a:
				inc	bx
				cmpsb				; Cmp [si] to es:[di]
				jz	col_tail_b		; Jump if zero
				call	sprite_state_update

col_tail_b:
				inc	bx
				cmpsb				; Cmp [si] to es:[di]
				jz	col_tail_c		; Jump if zero
				call	sprite_state_update

col_tail_c:
				inc	bx
				lodsb				; String [si] to al
				inc	di
				or	al,al			; Zero ?
				jns	col_compare		; Jump if not sign
				jmp	sprite_neg_handler

col_compare:
				cmp	al,es:[di-1]
				je	row_advance		; Jump if equal
				call	sprite_state_update

row_advance:
				add	si,4
				call	si_wrap_hi
				add	word ptr ds:vga_row_ptr,40B4h
				cmp	word ptr ds:vga_row_ptr,6000h
				jb	row_wrap_done		; Jump if below
				add	word ptr ds:vga_row_ptr,0A05Ah

row_wrap_done:
				dec	byte ptr ds:row_counter
				jnz	row_render_loop		; Jump if not zero
		retn

gfhgc_main		endp

sprite_state_update		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_28			; Jump if not sign
		jmp	loc_66

loc_28:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_29			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_30

loc_29:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_30			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		call	hgc_plane_or_blit

loc_30:
		mov	al,ds:sprite_attr_b
		sub	al,5
		jnc	loc_31			; Jump if carry=0
		retn

loc_31:
		cmp	al,4
		jb	loc_32			; Jump if below
		retn

loc_32:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:dispatch_tbl[bx]	;*
		pop	bx
		retn

sprite_state_update		endp

; Dispatch handler: 2-frame alternating animation (frame base 0x1B, 2 frames).
; Called via dispatch_tbl[bx]; entry point has mid-instruction compound header bytes
; that decode harmlessly on the normal entry path.

anim_cycle_2frame_1B:
		db	 86h, 31h		; xchg [bx+di],dh  (header byte pair; harmless)
		db	 0A6h			; cmpsb (header)
		db	 31h, 0DCh		; xor sp,bx (alt encoding; TASM uses 33/DC)
		db	 31h, 5Ah, 32h		; xor [bp+si+32h], bx  (header)
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	anim_2frame_1B_active	; Jump if below
		retn

anim_2frame_1B_active:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	anim_2frame_1B_step	; Jump if not zero
		retn

anim_2frame_1B_step:
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
		jb	anim_6frame_1D_active	; Jump if below
		retn

anim_6frame_1D_active:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	anim_6frame_high	; Jump if above or =
		or	al,al			; Zero ?
		jnz	anim_6frame_1D_step	; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	anim_6frame_1D_step	; Jump if zero
		retn

anim_6frame_1D_step:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn

anim_6frame_high:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn

; Dispatch handler: complex multi-direction animation (frame base 0x2C + extended range).

anim_cycle_2frame_2C:
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	anim_2C_extended	; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	anim_2C_step		; Jump if not zero
		retn

anim_2C_step:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn

anim_2C_extended:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	anim_2C_remap		; Jump if below
		retn

anim_2C_remap:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	anim_2C_apply		; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	anim_2C_apply		; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	anim_2C_apply		; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	anim_2C_apply		; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	anim_2C_apply		; Jump if equal
		sub	al,33h			; '3'
		jnc	anim_2C_remap_low	; Jump if carry=0
		retn

anim_2C_remap_low:
		mov	bl,0Eh
		cmp	al,2
		je	anim_2C_apply		; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	anim_2C_apply		; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	anim_2C_apply		; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	anim_2C_apply		; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	anim_2C_apply		; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al

anim_2C_apply:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	anim_2C_store		; Jump if not zero
		retn

anim_2C_store:
		mov	[si-1],bl
		retn

; Dispatch handler: 4-frame cycling animation (frame base 0x25, 4 frames 0x25..0x28).

anim_cycle_4frame_25:
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	anim_4frame_active	; Jump if below
		retn

anim_4frame_active:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	anim_4frame_step	; Jump if not zero
		retn

anim_4frame_step:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

hgc_plane_or_blit		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		mov	di,dx
		or	al,al			; Zero ?
		jz	loc_52			; Jump if zero
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:sprite_cache_tbl[bx],0FFFFh
		jnz	loc_48			; Jump if not zero
		dec	al
		mov	ds:sprite_cache_tbl[bx],di
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

locloop_46:
				movsw				; Mov [si] to es:[di]
				add	di,1FFEh
				cmp	di,hgc_wrap_limit
				jb	loc_47			; Jump if below
				mov	ax,[si-2]
				stosw				; Store ax to es:[di]
				add	di,hgc_wrap_add_a

loc_47:
				loop	locloop_46		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_48:
		mov	si,ds:sprite_cache_tbl[bx]
		mov	ax,0B000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

locloop_49:
				movsw				; Mov [si] to es:[di]
				add	di,1FFEh
				cmp	di,hgc_wrap_limit
				jb	loc_50			; Jump if below
				mov	ax,[si-2]
				stosw				; Store ax to es:[di]
				add	di,hgc_wrap_add_a

loc_50:
				add	si,1FFEh
				cmp	si,6000h
				jb	loc_51			; Jump if below
				add	si,0A05Ah

loc_51:
				loop	locloop_49		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_52:
		mov	ax,0B000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	cx,8

locloop_53:
				stosw				; Store ax to es:[di]
				add	di,1FFEh
				cmp	di,hgc_wrap_limit
				jb	loc_54			; Jump if below
				stosw				; Store ax to es:[di]
				add	di,0A058h

loc_54:
				loop	locloop_53		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

hgc_plane_or_blit		endp

sprite_slot_remove		proc	near
		cmp	byte ptr ds:sprite_buf,0FFh
		jne	loc_55			; Jump if not equal
		retn

loc_55:
		cmp	byte ptr ds:sprite_buf,0FCh
		jne	loc_56			; Jump if not equal
		retn

loc_56:
		push	si
		push	bx
		mov	byte ptr ds:sprite_buf,0FFh
		mov	cl,[si]
		add	si,25h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_57			; Jump if not sign
		call	translate_char

loc_57:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,4FDh
		call	hgc_sprite_blit
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
		add	dx,4FDh
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
		call	sprite_pair_blit
		pop	bx
		pop	si
		retn

sprite_slot_init		endp

sprite_blit_dispatch		proc	near
		cmp	byte ptr ds:sprite_buf_b,0FFh
		jne	loc_58			; Jump if not equal
		retn

loc_58:
		cmp	byte ptr ds:sprite_buf_b,0FCh
		jne	loc_59			; Jump if not equal
		retn

loc_59:
		mov	byte ptr ds:sprite_buf_b,0FFh
		mov	cl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_60			; Jump if not sign
		call	translate_char

loc_60:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,533h
		jmp	loc_77

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
		je	loc_62			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_62			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_61			; Jump if not sign
		call	translate_char

loc_61:
		call	hgc_sprite_blit
		pop	dx
		pop	si
		pop	bx

loc_62:
		add	dx,40B4h
		cmp	dx,6000h
		jb	loc_63			; Jump if below
		add	dx,0A05Ah

loc_63:
		cmp	byte ptr ds:row_counter,1
		je	loc_65			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_65			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_65			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_64			; Jump if not sign
		call	translate_char

loc_64:
		call	hgc_sprite_blit

loc_65:
		pop	bx
		pop	di
		pop	si
		retn

loc_66:
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
		call	sprite_pair_blit
		cmp	byte ptr ds:row_counter,1
		je	loc_68			; Jump if equal
		add	dx,40B0h
		cmp	dx,6000h
		jb	loc_67			; Jump if below
		add	dx,0A05Ah

loc_67:
		call	sprite_pair_blit
		test	byte ptr ds:flag_equip_b,0FFh
		jz	loc_68			; Jump if zero
		test	byte ptr ds:flag_shadow,0FFh
		jz	loc_68			; Jump if zero
		call	check_spawn_projectile

loc_68:
		pop	bx
		pop	di
		pop	si
		retn
; Alternate entry: sprite has negative palette byte ?-- use translate_char to fetch
; actual palette value, then blit via hgc_sprite_blit twice (left + right cells).
; Reached via `jns` skip in gfhgc_main's col_compare path.

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
		je	loc_71			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_71			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_70			; Jump if not sign
		call	translate_char

loc_70:
		call	hgc_sprite_blit
		pop	dx
		pop	si
		pop	bx

loc_71:
		add	dx,40B4h
		cmp	dx,6000h
		jb	loc_72			; Jump if below
		add	dx,0A05Ah

loc_72:
		cmp	byte ptr ds:row_counter,1
		je	loc_74			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_74			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_74			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_73			; Jump if not sign
		call	translate_char

loc_73:
		call	hgc_sprite_blit

loc_74:
		pop	bx
		pop	di
		pop	si
		jmp	row_advance

sprite_wide_row_render		endp

sprite_pair_blit		proc	near
		call	sprite_pair_blit_alt

sprite_pair_blit_alt:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_76			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_76			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_75			; Jump if not sign
		call	translate_char

loc_75:
		push	bp
		push	si
		push	di
		push	dx
		call	hgc_sprite_blit
		pop	dx
		pop	di
		pop	si
		pop	bp

loc_76:
		inc	si
		inc	di
		inc	bp
		inc	dx
		inc	dx
		retn

sprite_pair_blit		endp

hgc_sprite_blit		proc	near

loc_77:
		push	es
		push	ds
		mov	bl,ds:palette_byte
		or	al,al			; Zero ?
		jz	loc_78			; Jump if zero
		js	loc_78			; Jump if sign=1
		or	bl,80h

loc_78:
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
		mov	ax,cs:hero_gfx_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_79			; Jump if sign=1
		push	di
		mov	di,52A6h
		call	plane_copy_process
		pop	di
		mov	si,pattern_buf
		push	cs
		pop	ds
		mov	ax,0B000h
		mov	es,ax
		call	plane_scan_blit
		pop	ds
		pop	es
		retn

loc_79:
		push	di
		mov	di,pattern_buf
		call	sprite_or_into_cache
		pop	di
		mov	si,pattern_buf
		push	cs
		pop	ds
		mov	ax,0B000h
		mov	es,ax
		call	plane_scan_blit
		pop	ds
		pop	es
		retn

hgc_sprite_blit		endp

sprite_or_into_cache		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_8words
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

sprite_or_into_cache		endp

physics_func_11		proc	near
		mov	cx,8

locloop_80:
				mov	ax,ds:[bp]
				and	es:[di],ax
				lodsw				; String [si] to ax
				call	hgc_extract_4bits
				or	es:[di],ax
				inc	bp
				inc	bp
				inc	di
				inc	di
				loop	locloop_80		; Loop if cx > 0

		retn

physics_func_11		endp

plane_copy_process		proc	near
		mov	cx,8

locloop_81:
				lodsw				; String [si] to ax
				call	hgc_extract_4bits
				stosw				; Store ax to es:[di]
				loop	locloop_81		; Loop if cx > 0

		retn

plane_copy_process		endp

hgc_extract_4bits		proc	near
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

hgc_extract_4bits		endp

plane_scan_blit		proc	near
		mov	cx,8

locloop_82:
				movsw				; Mov [si] to es:[di]
				add	di,1FFEh
				cmp	di,hgc_wrap_limit
				jb	loc_83			; Jump if below
				mov	ax,[si-2]
				stosw				; Store ax to es:[di]
				add	di,0A058h

loc_83:
				loop	locloop_82		; Loop if cx > 0

		retn

plane_scan_blit		endp

copy_8words		proc	near
		mov	cx,8
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn

copy_8words		endp

zero_8words		proc	near
		xor	ax,ax			; Zero register
		mov	cx,8
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

zero_8words		endp

translate_char		proc	near
		and	al,7Fh
		mov	bx,char_lookup
		xlat				; al=[al+[bx]] table
		retn

translate_char		endp

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
		jnz	loc_84			; Jump if not zero
		mov	si,sprite_src_b

loc_84:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:flag_equip_b,0FFh
		jnz	loc_85			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_85			; Jump if zero
		add	al,3

loc_85:
		mov	ds:palette_byte,al
		mov	al,cl
		retn

sprite_src_setup		endp

check_spawn_projectile		proc	near
		cmp	byte ptr ds:row_idx,10h
		jb	loc_86			; Jump if below
		retn

loc_86:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_87			; Jump if above or =
		retn

loc_87:
		mov	di,projectile_list
		xor	cl,cl			; Zero register

loc_88:
				cmp	byte ptr [di],0FFh
				je	loc_89			; Jump if equal
				add	di,4
				inc	cl
				jmp	short loc_88

loc_89:
		cmp	cl,20h			; ' '
		jb	loc_90			; Jump if below
		retn

loc_90:
				call	word ptr cs:[11Ah]
				and	al,3
				cmp	al,3
				je	loc_90			; Jump if equal
		dec	al
		add	al,ds:col_idx
		cmp	al,0FFh
		jne	loc_91			; Jump if not equal
		mov	al,4

loc_91:
		cmp	al,1Bh
		jb	loc_92			; Jump if below
		mov	al,1Ah

loc_92:
		stosb				; Store al to es:[di]

loc_93:
				call	word ptr cs:[11Ah]
				and	al,3
				cmp	al,3
				je	loc_93			; Jump if equal
		dec	al
		add	al,ds:row_idx
		cmp	al,0FFh
		jne	loc_94			; Jump if not equal
		xor	al,al			; Zero register

loc_94:
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

check_spawn_projectile		endp

; projectile_loop -- mid-function header (0x07A6..0x07B0) is a jump-pad / alternate
; entry point. Decodes as `push bp / stosb / jmp dword [ss:70E][bp+si] / mov di, 0EDA0h /
; mov si, di` but these bytes are skipped in practice; real entry falls into loc_95.

projectile_loop_entry:
		db	 55h, 0AAh			; 0x07A6 header (push bp / stosb)
		db	 0FFh, 0AAh, 0Eh, 07h		; 0x07A8 jmp dword ptr ss:[70Eh][bp+si]
		db	0BFh,0A0h,0EDh, 8Bh,0F7h	; 0x07AC: mov di, projectile_list / mov si, di

loc_95:
		cmp	byte ptr [si],0FFh
		jne	loc_96			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn

loc_96:
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
		mov	al,[si]
		xor	ah,ah			; Zero register
		add	ax,ax
		add	ax,4FDh
		xor	cx,cx			; Zero register
		mov	cl,[si+1]
		jcxz	loc_99			; Jump if cx=0

locloop_97:
				add	ax,40B4h
				cmp	ax,6000h
				jb	loc_98			; Jump if below
				add	ax,0A05Ah

loc_98:
				loop	locloop_97		; Loop if cx > 0

loc_99:
		push	si
		push	di
		push	es
		push	ax
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:pattern_ptr_tbl[bx]
		pop	di
		mov	ax,0B000h
		mov	es,ax
		mov	cx,10h

locloop_100:
				lodsw				; String [si] to ax
				mov	bx,ax
				lodsw				; String [si] to ax
				or	es:[di],bx
				or	es:[di+2],ax
				add	di,2000h
				cmp	di,hgc_wrap_limit
				jb	loc_101			; Jump if below
				or	es:[di],bx
				or	es:[di+2],ax
				add	di,sprite_src_c

loc_101:
				loop	locloop_100		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_102			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4

loc_102:
		add	si,4
		jmp	loc_95

; sprite_shape_tbl -- HGC sprite shape / gradient data (like EGA's sprite_shape_tbl).
; Sourcer mis-decoded the 9-byte header as `or al,39h / int 3 / cmp ds:...`.

sprite_shape_tbl:
		db	 0Ch, 39h			; 0x0848 header
		db	 0CCh				; 0x084A
		db	 38h, 8Ch, 38h, 4Ch		; 0x084B (mem-op bytes)
		db	 38h, 00h			; 0x084F
		db	16 dup (0)
; --- HGC sprite shape 0: small projectile (5 rows x 6 bytes) ---
		db	 0Bh,0D0h, 00h, 00h, 5Fh,0FAh			; shape 0 row 0
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h			; shape 0 row 1
		db	0FFh,0FFh, 00h, 00h,0FFh,0FFh			; shape 0 row 2 (center)
		db	 00h, 00h, 7Fh,0FEh, 00h, 00h			; shape 0 row 3
		db	 5Fh,0FAh, 00h, 00h, 0Bh,0D0h			; shape 0 row 4
		db	26 dup (0)			; pad before shape 1
; --- HGC sprite shape 1: medium projectile / star (8 rows x 6 bytes) ---
		db	 2Fh,0F4h, 00h, 00h,0FFh,0FFh			; shape 1 row 0
		db	 00h, 03h,0FFh,0FFh,0C0h, 07h			; shape 1 row 1
		db	0FFh,0FFh,0E0h, 0Fh,0FAh, 5Fh			; shape 1 row 2
		db	0F0h, 0Fh,0F0h, 0Fh,0F0h, 0Fh			; shape 1 row 3 (center)
		db	0F0h, 0Fh,0F0h, 0Fh,0FAh, 5Fh			; shape 1 row 4
		db	0F0h, 07h,0FFh,0FFh,0E0h, 03h			; shape 1 row 5
		db	0FFh,0FFh,0C0h, 00h,0FFh,0FFh			; shape 1 row 6
		db	 00h, 00h, 2Fh,0F4h			; shape 1 row 7 (4-byte partial)
		db	10 dup (0)			; pad before shape 2
; --- HGC sprite shape 2: large explosion / spell burst (~13 rows x 6 bytes) ---
		db	 2Fh,0F4h, 00h, 01h, 7Fh,0FEh			; shape 2 row 0
		db	 80h, 07h,0FFh,0FFh,0E0h, 0Fh			; shape 2 row 1
		db	0FFh,0FFh,0F0h, 3Fh,0F4h, 2Fh			; shape 2 row 2
		db	0FCh, 7Fh,0A0h, 05h,0FEh, 7Fh			; shape 2 row 3
		db	 80h, 01h,0FEh,0FFh, 00h, 00h			; shape 2 row 4
		db	0FFh,0FFh, 00h, 00h,0FFh, 7Fh			; shape 2 row 5 (center)
		db	 80h, 01h,0FEh, 7Fh,0A0h, 05h			; shape 2 row 6
		db	0FEh, 3Fh,0F4h, 2Fh,0FCh, 0Fh			; shape 2 row 7
		db	0FFh,0FFh,0F0h, 07h,0FFh,0FFh			; shape 2 row 8
		db	0E0h, 01h, 7Fh,0FEh, 80h, 00h			; shape 2 row 9
		db	 2Fh,0F4h, 00h, 00h, 2Fh,0F4h			; shape 2 row 10
		db	 00h, 01h			; shape 2 row 11 (2-byte partial trailing)
; Sprite shape / lookup data continues (Sourcer mis-decoded as garbage mnemonics):
		db	 7Fh,0FEh			; 0x0915 shape bytes
		db	 80h, 07h, 0D0h			; 0x0917
		db	 0Bh, 0E0h			; 0x091A
		db	 0Fh				; 0x091C shape byte
		db	 00h, 00h			; 0x091D
		db	 0F0h, 3Ch, 00h			; 0x091F (lock prefix + cmp)
		db	 00h, 3Ch			; 0x0922
		db	 78h, 00h			; 0x0924
		db	 00h, 1Eh, 70h, 00h		; 0x0926
		db	 00h, 0Eh, 0F0h, 00h		; 0x092A
		db	 00h, 0Fh			; 0x092E
		db	 0F0h, 00h, 00h			; 0x0930
		db	 0Fh				; 0x0933 shape byte
		db	 70h, 00h			; 0x0934
		db	 00h, 0Eh, 78h, 00h		; 0x0936
		db	 00h, 1Eh, 3Ch, 00h		; 0x093A (=0x003C = drv_init_stub offset)
		db	 00h, 3Ch			; 0x093E
		db	 0Fh				; 0x0940 shape byte
		db	 00h, 00h			; 0x0941
		db	 0F0h, 07h			; 0x0943 (lock pop es)
		db	 0D0h, 0Bh			; 0x0945
		db	 0E0h, 01h			; 0x0947
		db	 7Fh, 0FEh			; 0x0949 shape bytes
		db	 80h, 00h, 2Fh			; 0x094B
		db	 0F4h				; 0x094E
		db	 00h, 0BFh, 0Dh, 50h		; 0x094F
; fade_color_init -- inline proc body (HGC variant). Sets up VGA color pair from
; DS:[83h]/[84h] (game_seg XY coords), calls hgc_xor_fill_region, does 3 fade passes
; at radii, and falls through into fade_color_init's inner loop.

fade_color_init:
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
		jmp	short fade_color_loop_start

; Alternate entry: fade_color_init_refs (entered via dispatch or mid-function call).
; Populates sprite_row_buf with 4x4 pattern bytes from pattern_base before main loop.

fade_color_init_refs:
		call	build_sprite_refs
		mov	di,sprite_row_buf
		mov	dl,ds:enemy_counter
		dec	dl
		mov	cx,4

pattern_row_loop:
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

pattern_col_loop:
						mov	al,[bx]
						or	al,al			; Zero ?
						js	pattern_store		; Jump if sign=1
						xor	al,al			; Zero register

pattern_store:
						mov	[di],al
						inc	bx
						inc	di
						loop	pattern_col_loop	; Loop if cx > 0

				inc	dl
				pop	cx
				loop	pattern_row_loop	; Loop if cx > 0

fade_color_loop_start:
		mov	bl,byte ptr ds:[84h]
		add	bl,bl
		add	bl,bl
		add	bl,bl
		add	bl,0Eh
		mov	bh,byte ptr ds:[83h]
		add	bh,6
		add	bh,bh
		call	hgc_pixel_addr_calc
		mov	ds:scroll_vga_ofs,ax
		mov	byte ptr ds:col_idx,0
		mov	si,500Dh
		mov	di,sprite_row_buf
		mov	cx,3

locloop_110:
				push	cx
				mov	cx,3

locloop_111:
						push	cx
						mov	ax,3A2Fh
						push	ax
						mov	al,[di]
						or	al,[di+1]
						or	al,[di+4]
						or	al,[di+5]
						jnz	loc_112			; Jump if not zero
						jmp	loc_149

loc_112:
						test	byte ptr [di],0FFh
						jz	loc_113			; Jump if zero
						mov	al,[di]
						push	si
						call	sprite_src_setup
						inc	si
						inc	si
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_151

loc_113:
						test	byte ptr [di+1],0FFh
						jz	loc_114			; Jump if zero
						mov	al,[di+1]
						push	si
						call	sprite_src_setup
						inc	si
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_151

loc_114:
						test	byte ptr [di+4],0FFh
						jz	loc_115			; Jump if zero
						mov	al,[di+4]
						push	si
						call	sprite_src_setup
						inc	si
						mov	al,[si]
						pop	si
						jmp	loc_151

loc_115:
						mov	al,[di+5]
						push	si
						call	sprite_src_setup
						mov	cl,[si]
						pop	si
						mov	[si],al
						mov	al,cl
						jmp	loc_151
; Alternate fall-through from locloop_111 (all-4-cells-empty path jmps to loc_149)

fade_cell_continue:
						inc	byte ptr ds:col_idx
						inc	di
						inc	si
						pop	cx
						loop	locloop_111		; Loop if cx > 0

				pop	cx
				inc	di
				loop	locloop_110		; Loop if cx > 0

		mov	bl,ds:color_sel
		and	bl,3
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:hero_gfx_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	es,cs:game_seg
		mov	al,byte ptr ds:[0E8h]
		or	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_116			; Jump if zero
		jmp	loc_126

loc_116:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_117			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h

loc_117:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_121			; Jump if zero
		inc	cl
		jnz	loc_118			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	get_step_direction
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_124

loc_118:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_119			; Jump if not zero
		add	ax,24h
		jmp	short loc_120

loc_119:
		dec	dl
		jnz	loc_120			; Jump if not zero
		mov	ax,63h

loc_120:
		add	si,ax
		jmp	short loc_124

loc_121:
		call	get_step_direction
		or	al,al			; Zero ?
		jz	loc_123			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_123			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:flag_shield
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_122			; Jump if zero
		add	ax,1Bh

loc_122:
		add	si,ax
		jmp	short loc_124

loc_123:
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_126			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_126			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_126			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_125

loc_124:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_125			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		call	sprite_write_range
		jmp	short loc_126

loc_125:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	sprite_write_range

loc_126:
		mov	si,610Eh
		test	byte ptr ds:flag_riding,0FFh
		jnz	loc_131			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:flag_climbing,0FFh
		jnz	loc_129			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_127			; Jump if not zero
		mov	si,game_data_base

loc_127:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_128			; Jump if zero
		add	si,5Ah
		jmp	short loc_129

loc_128:
		mov	ax,2Dh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_130			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:equip_byte,80h
		jnz	loc_130			; Jump if not zero
		mov	cl,ds:shield_sel
		mov	ax,48h
		dec	cl
		jz	loc_130			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_130			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:equip_byte,7Fh
		je	loc_130			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_130			; Jump if equal

loc_129:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al

loc_130:
		add	si,ax

loc_131:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	sprite_write_range
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_132			; Jump if zero
		retn

loc_132:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_133			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h

loc_133:
		mov	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_135			; Jump if zero
		call	get_step_direction
		or	al,al			; Zero ?
		jnz	loc_134			; Jump if not zero
		retn

loc_134:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_142

loc_135:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_139			; Jump if zero
		inc	cl
		jnz	loc_136			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	get_step_direction
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_143

loc_136:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_137			; Jump if not zero
		add	ax,24h
		jmp	short loc_138

loc_137:
		dec	dl
		jnz	loc_138			; Jump if not zero
		mov	ax,63h

loc_138:
		add	si,ax
		jmp	short loc_143

loc_139:
		test	byte ptr ds:[0C2h],1
		jz	loc_141			; Jump if zero
		call	get_step_direction
		or	al,al			; Zero ?
		jz	loc_141			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:flag_shield
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_140			; Jump if zero
		add	ax,1Bh

loc_140:
		add	si,ax
		jmp	short loc_143

loc_141:
		mov	ax,1Bh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_142			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_142			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al

loc_142:
		add	si,ax

loc_143:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_144			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		jmp	short locloop_145

loc_144:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		jmp	short locloop_145

sprite_write_range		proc	near

locloop_145:
				push	cx
				mov	al,es:[si]
				or	al,al			; Zero ?
				jz	loc_146			; Jump if zero
				push	es
				push	ds
				push	si
				push	di
				mov	ch,10h
				mul	ch			; ax = reg * al
				mov	si,ax
				add	si,hgc_src_base2
				mov	bp,ax
				add	bp,hgc_extended_src
				mov	ds,cs:game_seg
				mov	di,dx
				push	cs
				pop	es
				mov	al,cs:col_idx
				mov	cl,10h
				mul	cl			; ax = reg * al
				add	ax,5216h
				mov	di,ax
				call	physics_func_11
				pop	di
				pop	si
				pop	ds
				pop	es

loc_146:
				inc	si
				inc	byte ptr ds:col_idx
				pop	cx
				loop	locloop_145		; Loop if cx > 0

		retn

sprite_write_range		endp

get_step_direction		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_147			; Jump if not zero
		retn

loc_147:
		cmp	al,4
		mov	al,1
		jnc	loc_148			; Jump if carry=0
		retn

loc_148:
		mov	al,2
		retn

get_step_direction		endp

loc_149:
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
		add	ax,5216h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_150			; Jump if zero
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	copy_8words
		pop	di
		pop	si
		pop	ds
		retn

loc_150:
		call	zero_8words
		pop	di
		pop	si
		pop	ds
		retn

loc_151:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_152			; Jump if not sign
		call	translate_char

loc_152:
		push	ax
		mov	bl,ds:palette_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:hero_gfx_tbl[bx]
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
		add	ax,5216h
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_153			; Jump if zero
		mov	cl,al
		call	sprite_or_into_cache
		pop	di
		pop	si
		pop	ds
		retn

loc_153:
		call	plane_copy_process
		pop	di
		pop	si
		pop	ds
		retn

build_sprite_refs		proc	near
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

locloop_154:
				movsw				; Mov [si] to es:[di]
				movsb				; Mov [si] to es:[di]
				add	si,21h
				call	si_wrap_hi
				loop	locloop_154		; Loop if cx > 0

		retn

build_sprite_refs		endp

frame_row_driver		proc	near
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_156			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_155		; Jump if not equal
		call	load_bg_to_cache

loc_ret_155:
		retn

loc_156:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_157			; Jump if above or =
		retn

loc_157:
		jnz	loc_158			; Jump if not zero
		call	bg_restore_dispatch
		jmp	loc_194

loc_158:
		add	al,0Ah
		cmp	al,cl
		je	loc_159			; Jump if equal
		retn

loc_159:
		jmp	loc_185

; scroll_update_check -- alternate entry point into frame_row_driver scroll logic.
; Tests scroll_active flag; if active, runs the scroll-state update path.

scroll_update_check:
		test	byte ptr ds:scroll_active,0FFh
		jnz	scroll_update_active	; Jump if not zero
		retn

scroll_update_active:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:game_seg
		inc	byte ptr ds:scroll_step
		mov	al,ds:scroll_phase
		or	al,al			; Zero ?
		jz	loc_167			; Jump if zero
		dec	al
		jz	loc_165			; Jump if zero
		cmp	byte ptr ds:scroll_step,5
		jb	loc_161			; Jump if below
		jmp	loc_177

loc_161:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:scroll_delta,0FF01h
		mov	di,ds:scroll_vga_ofs
		add	di,40B2h
		cmp	di,6000h
		jb	loc_162			; Jump if below
		add	di,0A05Ah

loc_162:
		test	byte ptr ds:[0C2h],1
		jz	loc_163			; Jump if zero
		jmp	loc_175

loc_163:
		mov	si,0B0BEh
		mov	word ptr ds:scroll_delta,1
		mov	di,ds:scroll_vga_ofs
		add	di,40B4h
		cmp	di,6000h
		jb	loc_164			; Jump if below
		add	di,0A05Ah

loc_164:
		jmp	loc_175

loc_165:
		cmp	byte ptr ds:scroll_step,5
		jb	loc_166			; Jump if below
		jmp	loc_177

loc_166:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_169			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_169

loc_167:
		cmp	byte ptr ds:scroll_step,7
		jb	loc_168			; Jump if below
		jmp	loc_177

loc_168:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_169			; Jump if not zero
		mov	di,hgc_plane_alt
		mov	si,0B01Eh

loc_169:
		mov	bx,es:[bx+di]
		mov	di,ds:scroll_vga_ofs
		mov	ds:scroll_delta,bx
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	di,ax
		or	bl,bl			; Zero ?
		js	loc_172			; Jump if sign=1
		or	bl,bl			; Zero ?
		jz	loc_175			; Jump if zero

loc_170:
				add	di,40B4h
				cmp	di,6000h
				jb	loc_171			; Jump if below
				add	di,0A05Ah

loc_171:
				dec	bl
				jnz	loc_170			; Jump if not zero
		jmp	short loc_175

loc_172:
		neg	bl
		jz	loc_175			; Jump if zero

loc_173:
				sub	di,40B4h
				jnc	loc_174			; Jump if carry=0
				add	di,5FA6h

loc_174:
				dec	bl
				jnz	loc_173			; Jump if not zero

loc_175:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_176			; Jump if zero
		add	di,40B4h
		cmp	di,6000h
		jb	loc_176			; Jump if below
		add	di,0A05Ah

loc_176:
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
		jmp	loc_185

loc_177:
		mov	byte ptr ds:scroll_active,0
		mov	byte ptr ds:scroll_step,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

frame_row_driver		endp

bg_restore_dispatch		proc	near
		test	byte ptr ds:restore_pending,0FFh
		jnz	loc_178			; Jump if not zero
		retn

loc_178:
		push	es
		push	di
		push	si
		push	bx
		call	restore_bg_rows
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:restore_pending,0
		retn

bg_restore_dispatch		endp

save_bg_rows		proc	near
		push	ds
		push	cs
		pop	es
		mov	si,cs:scroll_src_ofs
		mov	ax,0B000h
		mov	ds,ax
		mov	di,sprite_cache_b
		mov	cx,20h

locloop_179:
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				add	si,1FF8h
				cmp	si,6000h
				jb	loc_180			; Jump if below
				add	si,0A05Ah

loc_180:
				loop	locloop_179		; Loop if cx > 0

		pop	ds
		retn

save_bg_rows		endp

restore_bg_rows		proc	near
		push	ds
		push	cs
		pop	ds
		mov	di,cs:scroll_src_ofs
		mov	ax,0B000h
		mov	es,ax
		mov	si,sprite_cache_b
		mov	cx,20h

locloop_181:
				push	si
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				pop	si
				add	di,1FF8h
				cmp	di,hgc_wrap_limit
				jb	loc_182			; Jump if below
				push	si
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				movsw				; Mov [si] to es:[di]
				pop	si
				add	di,0A052h

loc_182:
				add	si,8
				loop	locloop_181		; Loop if cx > 0

		pop	ds
		retn

restore_bg_rows		endp

clear_sprite_cache_block		proc	near
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

locloop_183:
				push	cx
				mov	cx,4

locloop_184:
						push	cx
						mov	bl,[si]
						inc	si
						and	bl,7Fh
						xor	bh,bh			; Zero register
						add	bx,bx
						mov	word ptr ds:sprite_cache_tbl[bx],0
						pop	cx
						loop	locloop_184		; Loop if cx > 0

				add	si,20h
				call	si_wrap_hi
				pop	cx
				loop	locloop_183		; Loop if cx > 0

		retn

loc_185:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_186			; Jump if not zero
		retn

loc_186:
		mov	byte ptr ds:restore_pending,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	clear_sprite_cache_block
		call	save_bg_rows
		mov	ds,cs:game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	di,cs:scroll_src_ofs
		mov	si,cs:scroll_gfx_ptr
		mov	cx,4

locloop_187:
				push	cx
				push	di
				mov	cx,4

locloop_188:
						push	cx
						lodsb				; String [si] to al
						cmp	al,0FFh
						jne	loc_190			; Jump if not equal
						add	di,40B4h
						cmp	di,6000h
						jb	loc_189			; Jump if below
						add	di,hgc_wrap_add_b

loc_189:
						jmp	short loc_193

loc_190:
						push	si
						xor	ah,ah			; Zero register
						add	ax,ax
						add	ax,ax
						add	ax,ax
						add	ax,ax
						mov	si,ax
						add	si,ds:hgc_sprite_src
						mov	cx,8

locloop_191:
						push	cx
						lodsw				; String [si] to ax
						or	es:[di],ax
						add	di,2000h
						cmp	di,hgc_wrap_limit
						jb	loc_192			; Jump if below
						or	es:[di],ax
						add	di,0A05Ah

loc_192:
						pop	cx
						loop	locloop_191		; Loop if cx > 0

						pop	si

loc_193:
						pop	cx
						loop	locloop_188		; Loop if cx > 0

				pop	di
				inc	di
				inc	di
				pop	cx
				loop	locloop_187		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
; Alternate entry: recalculate scroll_vga_ofs from BX/BH coords, then fall into
; projection restore path at loc_196.

scroll_vga_recompute:
		call	hgc_pixel_addr_calc
		mov	ds:scroll_vga_ofs,ax
		jmp	short loc_196

clear_sprite_cache_block		endp

load_bg_to_cache		proc	near

loc_194:
		test	byte ptr ds:redraw_lock,0FFh
		jz	loc_195			; Jump if zero
		retn

loc_195:
		mov	byte ptr ds:redraw_lock,0FFh

loc_196:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0B000h
		mov	es,ax
		mov	si,sprite_ring_buf
		mov	di,cs:scroll_vga_ofs
		mov	cx,3

locloop_197:
				push	cx
				mov	cx,3

locloop_198:
						push	cx
						push	di
						call	plane_scan_blit
						pop	di
						inc	di
						inc	di
						pop	cx
						loop	locloop_198		; Loop if cx > 0

				add	di,40AEh
				cmp	di,6000h
				jb	loc_199			; Jump if below
				add	di,0A05Ah

loc_199:
				pop	cx
				loop	locloop_197		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn

load_bg_to_cache		endp

; sprite_dim_blit -- dim/darken variant sprite blit. Reads 8 rows from
; sprite source (AL*0x10+0x8030), spreads bits upward (bx = src OR bit-expand)
; then masks and ORs into HGC framebuffer. Used for shadow/fade rendering.

sprite_dim_blit:
		push	ds
		push	si
		dec	al
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	cx,8

dim_row_loop:
				push	cx
				lodsw				; String [si] to ax
				mov	bx,ax
				mov	dx,3
				mov	cx,8

locloop_201:
						test	bx,dx
						jz	loc_202			; Jump if zero
						or	bx,dx

loc_202:
						add	dx,dx
						add	dx,dx
						loop	locloop_201		; Loop if cx > 0

				not	bx
				and	es:[di],bx
				or	es:[di],ax
				add	di,2000h
				cmp	di,hgc_wrap_limit
				jb	loc_203			; Jump if below
				and	es:[di],bx
				or	es:[di],ax
				add	di,0A05Ah

loc_203:
				pop	cx
				loop	dim_row_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn
; anim_refresh_all -- full 8-pass animation refresh loop (HGC equivalent of EGA).
; Invoked via dispatch for full-screen animation updates.

anim_refresh_all:
		mov	byte ptr ds:restore_pending,0
		mov	ax,0B000h
		mov	es,ax
		mov	byte ptr ds:anim_phase,8

anim_refresh_pass:
				mov	word ptr ds:vga_row_ptr,0C0Eh
				mov	byte ptr ds:gvar_frame_timer,0
				mov	si,ds:sprite_data_ptr
				mov	di,sprite_buf
				mov	cx,12h

locloop_205:
						push	cx
						add	si,4
						xor	bx,bx			; Zero register
						mov	cx,1Ch

locloop_206:
						push	cx
						lodsb				; String [si] to al
						call	anim_refresh_tile
						inc	di
						inc	bl
						pop	cx
						loop	locloop_206		; Loop if cx > 0

						add	si,4
						call	si_wrap_hi
						add	word ptr ds:vga_row_ptr,8
						pop	cx
						loop	locloop_205		; Loop if cx > 0

loc_207:
						cmp	byte ptr ds:gvar_frame_timer,10h
						jb	loc_207			; Jump if below
				dec	byte ptr ds:anim_phase
				jnz	anim_refresh_pass	; Jump if not zero
		retn

anim_refresh_tile		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_208			; Jump if not equal
		retn

loc_208:
		cmp	byte ptr [di],0FCh
		jne	loc_209			; Jump if not equal
		retn

loc_209:
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
		mov	cs:hgc_mask_state,ah
		add	bx,bx
		xchg	bh,bl
		add	bx,ds:vga_row_ptr
		mov	di,bx
		pop	ax
		test	al,0FFh
		jz	loc_212			; Jump if zero
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
		call	set_pixel_stride_offset
		call	hgc_write_row_masked
		pop	di
		pop	si
		mov	al,cs:anim_phase
		call	set_pixel_stride_offset
		add	di,100h
		inc	si
		call	hgc_write_row_masked
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

anim_refresh_tile		endp

hgc_write_row_masked		proc	near
		mov	cx,2

locloop_210:
				push	di
				mov	bx,di
				call	hgc_pixel_addr_calc
				mov	di,ax
				mov	bl,cs:hgc_mask_state
				lodsb				; String [si] to al
				and	al,bl
				not	bl
				and	es:[di],bl
				or	es:[di],al
				cmp	di,4000h
				jb	loc_211			; Jump if below
				add	di,level_seg_ofs
				and	es:[di],bl
				or	es:[di],al

loc_211:
				pop	di
				add	di,4
				add	si,7
				loop	locloop_210		; Loop if cx > 0

		retn

loc_212:
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	set_pixel_stride_offset
		call	hgc_clear_row_masked
		pop	di
		mov	al,cs:anim_phase
		call	set_pixel_stride_offset
		add	di,100h
		call	hgc_clear_row_masked
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

hgc_write_row_masked		endp

hgc_clear_row_masked		proc	near
		push	di
		mov	bx,di
		call	hgc_pixel_addr_calc
		mov	di,ax
		mov	al,cs:hgc_mask_state
		not	al
		and	es:[di],al
		cmp	di,4000h
		jb	loc_213			; Jump if below
		add	di,level_seg_ofs
		and	es:[di],al

loc_213:
		pop	bx
		push	ax
		add	bx,4
		call	hgc_pixel_addr_calc
		mov	di,ax
		pop	ax
		and	es:[di],al
		cmp	di,4000h
		jb	loc_ret_214		; Jump if below
		add	di,level_seg_ofs
		and	es:[di],al

loc_ret_214:
		retn

hgc_clear_row_masked		endp

set_pixel_stride_offset		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		add	di,ax
		add	ax,ax
		add	si,ax
		retn

set_pixel_stride_offset		endp

; color_fade_trigger -- dispatch handler: triggers a 2-pass color fade effect.
; Builds cur_color_pair from DS:[83h]/[84h] (game XY), clears fill region,
; then does two fade radius passes with anim_phase=0xAA then 0x00.

color_fade_trigger:
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
		call	hgc_xor_fill_region
		mov	byte ptr ds:anim_phase,0AAh
		call	fade_radius_loop
		mov	byte ptr ds:anim_phase,0
		call	fade_radius_loop
		jmp	loc_247

fade_radius_loop		proc	near
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

locloop_215:
				push	cx
				push	dx
				push	bx
				call	hgc_fade_blit
				pop	bx
				pop	dx
				sub	bl,0Ch
				jnc	loc_216			; Jump if carry=0
				xor	bl,bl			; Zero register

loc_216:
				sub	bh,0Ch
				jnc	loc_217			; Jump if carry=0
				xor	bh,bh			; Zero register

loc_217:
				add	dl,0Ch
				jnc	loc_218			; Jump if carry=0
				mov	dl,0FFh

loc_218:
				add	dh,0Ch
				jnc	loc_219			; Jump if carry=0
				mov	dh,0FFh

loc_219:
				push	dx
				push	bx
				call	frame_wait_loop
				pop	bx
				pop	dx
				pop	cx
				loop	locloop_215		; Loop if cx > 0

		retn

fade_radius_loop		endp

hgc_fade_blit		proc	near
		mov	ax,0B000h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	hgc_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	hgc_fill_bit_range_wide
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	hgc_fill_bit_range
		pop	bx
		pop	dx
		mov	bl,dl

hgc_fill_bit_range:
		cmp	dh,bh
		jae	loc_220			; Jump if above or =
		xchg	dx,bx

loc_220:
		or	bl,bl			; Zero ?
		jnz	loc_221			; Jump if not zero
		retn

loc_221:
		cmp	bl,0DFh
		jb	loc_222			; Jump if below
		retn

loc_222:
		or	bh,bh			; Zero ?
		jnz	loc_223			; Jump if not zero
		mov	bh,1

loc_223:
		cmp	dh,8Fh
		jb	loc_224			; Jump if below
		mov	dh,8Eh

loc_224:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	hgc_row_addr_calc
		mov	al,bl
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		and	bl,3
		jz	loc_227			; Jump if zero
		cmp	bl,2
		jb	loc_226			; Jump if below
		jz	loc_225			; Jump if zero
		mov	ah,3
		jmp	short loc_228

loc_225:
		mov	ah,0Ch
		jmp	short loc_228

loc_226:
		mov	ah,30h			; '0'
		jmp	short loc_228

loc_227:
		mov	ah,0C0h

loc_228:
		mov	al,ah
		not	al
		and	ah,ds:anim_phase

locloop_229:
				and	es:[di],al
				or	es:[di],ah
				add	di,2000h
				cmp	di,hgc_wrap_limit
				jb	loc_230			; Jump if below
				and	es:[di],al
				or	es:[di],ah
				add	di,0A05Ah

loc_230:
				loop	locloop_229		; Loop if cx > 0

		retn

hgc_fade_blit		endp

hgc_fill_bit_range_wide		proc	near
		cmp	dl,bl
		jae	loc_231			; Jump if above or =
		xchg	dx,bx

loc_231:
		or	bh,bh			; Zero ?
		jnz	loc_232			; Jump if not zero
		retn

loc_232:
		cmp	bh,8Fh
		jb	loc_233			; Jump if below
		retn

loc_233:
		or	bl,bl			; Zero ?
		jnz	loc_234			; Jump if not zero
		mov	bl,1

loc_234:
		cmp	dl,0DFh
		jb	loc_235			; Jump if below
		mov	dl,0DEh

loc_235:
		mov	al,bh
		call	hgc_row_addr_calc
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
		jz	loc_238			; Jump if zero
		cmp	bl,2
		jb	loc_237			; Jump if below
		jz	loc_236			; Jump if zero
		mov	al,3
		jmp	short loc_239

loc_236:
		mov	al,0Fh
		jmp	short loc_239

loc_237:
		mov	al,3Fh			; '?'
		jmp	short loc_239

loc_238:
		mov	al,0FFh

loc_239:
		and	dl,3
		jz	loc_242			; Jump if zero
		cmp	dl,2
		jb	loc_241			; Jump if below
		jz	loc_240			; Jump if zero
		mov	ah,0FFh
		jmp	short loc_243

loc_240:
		mov	ah,0FCh
		jmp	short loc_243

loc_241:
		mov	ah,0F0h
		jmp	short loc_243

loc_242:
		mov	ah,0C0h

loc_243:
		jcxz	loc_245			; Jump if cx=0
		dec	cx
		jcxz	loc_244			; Jump if cx=0
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

loc_244:
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

loc_245:
		and	al,ah
		mov	dh,al
		not	dh
		and	al,ds:anim_phase
		and	es:[di],dh
		or	es:[di],al
		retn

hgc_fill_bit_range_wide		endp

hgc_row_addr_calc		proc	near
		push	bx
		mov	bx,0C0Eh
		add	bl,al
		call	hgc_pixel_addr_calc
		mov	di,ax
		pop	bx
		retn

hgc_row_addr_calc		endp

frame_wait_loop		proc	near
		mov	cl,ds:anim_speed
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al

loc_246:
				push	ax
				call	word ptr cs:[110h]
				call	word ptr cs:[112h]
				call	word ptr cs:[114h]
				call	word ptr cs:[116h]
				call	word ptr cs:[118h]
				pop	ax
				cmp	ds:gvar_frame_timer,al
				jb	loc_246			; Jump if below
		mov	byte ptr ds:gvar_frame_timer,0
		retn

frame_wait_loop		endp

hgc_xor_fill_region		proc	near

loc_247:
		mov	ax,0B000h
		mov	es,ax
		mov	di,hgc_hud_ofs
		mov	cx,90h

locloop_248:
				push	cx
				push	di
				mov	ax,0FFFFh
				mov	cx,1Ch

locloop_249:
						xor	es:[di],ax
						inc	di
						inc	di
						loop	locloop_249		; Loop if cx > 0

				pop	di
				add	di,2000h
				cmp	di,hgc_wrap_limit
				jb	loc_251			; Jump if below
				push	di
				mov	ax,0FFFFh
				mov	cx,1Ch

locloop_250:
						xor	es:[di],ax
						inc	di
						inc	di
						loop	locloop_250		; Loop if cx > 0

				pop	di
				add	di,0A05Ah

loc_251:
				pop	cx
				loop	locloop_248		; Loop if cx > 0

		retn

hgc_xor_fill_region		endp

; sprite_vga_pos_calc -- compute HGC DI from packed (AL=row&0x3F, AH=col) values.
; Used as dispatch target by sprite rendering code.

sprite_vga_pos_calc:
		and	al,3Fh			; '?'
		add	al,al			; row * 2
		add	al,al			; row * 4
		add	al,al			; row * 8
		add	al,0Eh			; + row base offset
		sub	ah,4			; col -= 4
		add	ah,ah
		add	ah,0Ch
		mov	bx,ax
		call	hgc_pixel_addr_calc
		mov	di,ax
		retn

; bg_copy_update -- background-layer copy from CS:2000h+[ds:9Dh-1]
; into sprite_src_base. Used to page in background tile graphics.

bg_copy_update:
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	bg_copy_exit		; Jump if zero
		cmp	bl,7
		je	bg_copy_exit		; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:game_seg
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,sprite_src_base
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

bg_copy_exit:
		mov	ds,cs:game_seg
		mov	si,8690h
		retn

si_wrap_hi		proc	near
		cmp	si,0E900h
		jae	loc_253			; Jump if above or =
		retn

loc_253:
		sub	si,900h
		retn

si_wrap_hi		endp

si_wrap_lo		proc	near
		cmp	si,0E000h
		jb	loc_254			; Jump if below
		retn

loc_254:
		add	si,900h
		retn

si_wrap_lo		endp

; draw_ui_tiles -- draw 5 rows x 28 cols UI tile grid from sprite_tmp_buf
; into hgc_draw_ofs region (HGC equivalent of EGA's draw_ui_tiles).

draw_ui_tiles:
		push	si
		push	ds
		mov	si,sprite_tmp_buf
		mov	di,hgc_draw_ofs
		mov	ax,0B000h
		mov	es,ax
		mov	cx,5

ui_tile_row_loop:
				push	cx
				mov	cx,1Ch

locloop_256:
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

locloop_257:
						push	cx
						movsw				; Mov [si] to es:[di]
						add	di,1FFEh
						cmp	di,hgc_wrap_limit
						jb	loc_258			; Jump if below
						mov	ax,[si-2]
						stosw				; Store ax to es:[di]
						add	di,0A058h

loc_258:
						pop	cx
						loop	locloop_257		; Loop if cx > 0

						pop	di
						inc	di
						inc	di
						pop	si
						pop	ds
						pop	cx
						loop	locloop_256		; Loop if cx > 0

				add	di,407Ch
				cmp	di,6000h
				jb	loc_259			; Jump if below
				add	di,0A05Ah

loc_259:
				pop	cx
				loop	ui_tile_row_loop	; Loop if cx > 0

		pop	ds
		pop	si
		retn
; --- gf_hgc_phase_idx_tbl: animation phase index table (5 sets of ~28 entries) ---
gf_hgc_phase_idx_tbl:
		db	 00h, 01h, 02h, 04h, 07h, 09h			; set 0 row 0: phase indices 0..5
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch			; set 0 row 1: phase indices 6..11
		db	 1Eh, 04h, 07h, 09h, 22h, 02h			; set 0 row 2: phase indices 12..17
		db	 25h, 08h, 02h, 28h, 02h, 2Dh			; set 0 row 3: phase indices 18..23
		db	 31h, 36h, 3Bh, 40h, 00h, 01h			; set 0 row 4 + start of set 1
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h			; set 1 row 0: phase indices 2..7
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h			; set 1 row 1: phase indices 8..13
		db	8, 0Ah, '#$'			; set 1 row 2 (chars '#$' = 0x23 0x24 mid-row)
		db	'&', 8, 27h, ')*'			; set 1 row 3 (ASCII frame chars)
		db	 04h, 32h, 37h, 3Ch, 06h, 00h			; set 1 row 4 + start of set 2
		db	 01h, 02h, 05h, 08h, 02h, 0Eh			; set 2 row 0: phase indices 1..6
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh			; set 2 row 1: phase indices 7..12
		db	 04h, 08h, 02h, 23h, 24h, 26h			; set 2 row 2: phase indices 13..18
		db	 08h, 25h, 29h, 02h, 2Eh, 33h			; set 2 row 3: phase indices 19..24
		db	 38h, 3Dh, 06h, 00h, 01h, 03h			; set 2 row 4 + start of set 3
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h			; set 3 row 0: phase indices 2..7
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h			; set 3 row 1: phase indices 8..13
		db	 0Bh			; set 3 row 2 (1 byte)
		db	'#$'			; set 3 row 2 cont (chars '#$')
		db	'&', 8, 27h, ')+/49>'			; set 3 row 3: ASCII indices 0x26,0x08,...0x3E
		db	 06h, 00h, 01h, 02h, 04h, 08h			; set 3 row 4 + start of set 4
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh			; set 4 row 0: phase indices 2..7
		db	 1Dh			; set 4 row 1 (1 byte)
		db	' !', 8, 0Ch, '#$'			; set 4 row 1 cont (chars ' !.#$')
		db	'&', 8			; set 4 row 2 (chars '&.')
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah			; set 4 row 3: phase indices 14..19
; --- trailing HGC blit code stub (Sourcer mis-decoded) ---
		db	 3Fh, 06h,0A2h,0F7h, 4Fh,0BEh			; code: cmp; push es; mov [4FF7],al; mov si
		db	 17h, 47h,0C7h, 06h,0E4h, 4Fh			; code: ...inc di; mov word [4FE4],...
		db	0FDh, 04h,0B9h, 12h, 00h			; code: std; add al,4; mov cx,12h

locloop_260:
				push	cx
				mov	cx,1Ch

locloop_261:
						push	cx
						lodsb				; String [si] to al
						push	si
						call	hgc_fade_blit_entry
						pop	si
						add	word ptr ds:vga_row_ptr,2
						pop	cx
						loop	locloop_261		; Loop if cx > 0

				add	word ptr ds:vga_row_ptr,407Ch
				cmp	word ptr ds:vga_row_ptr,6000h
				jb	loc_262			; Jump if below
				add	word ptr ds:vga_row_ptr,0A05Ah

loc_262:
				pop	cx
				loop	locloop_260		; Loop if cx > 0

		retn

hgc_fade_blit_entry		proc	near
		push	ds
		mov	cl,10h
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0B000h
		mov	es,ax
		mov	di,cs:vga_row_ptr
		mov	cx,8

locloop_263:
				push	cx
				lodsw				; String [si] to ax
				call	rol_extract_loop
				stosw				; Store ax to es:[di]
				add	di,1FFEh
				cmp	di,hgc_wrap_limit
				jb	loc_264			; Jump if below
				stosw				; Store ax to es:[di]
				add	di,0A058h

loc_264:
				pop	cx
				loop	locloop_263		; Loop if cx > 0

		pop	ds
		retn

hgc_fade_blit_entry		endp

rol_extract_loop		proc	near
		mov	cx,8

locloop_265:
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
				loop	locloop_265		; Loop if cx > 0

		mov	ax,dx
		retn

rol_extract_loop		endp

; lane_selector_tbl -- 5-entry word table of lane-selector function pointers for
; rol_extract_loop. Each entry is a CS-relative near pointer (addresses into
; adjacent code). Referenced by color_map_tbl[bx] at runtime.

lane_selector_tbl:
		dw	46DAh			; lane 0 -- retn immediately (no-op)
		dw	46DBh			; lane 1 -- conditional cl swap (branch A)
		dw	46ECh			; lane 2 -- conditional cl swap (branch B)
		dw	46FDh			; lane 3 -- conditional cl swap (branch C)
		dw	470Eh			; lane 4 -- conditional cl swap (branch D)

; lane_selector_body -- 15 bytes of small lane-swap routines chained via jne/je
; fall-through. Each of the 5 selector pointers above jumps into one of these
; fragments; they share prologue/epilogue bytes via mid-instruction overlap.
; Sourcer cannot trace the entries (hence label below is at the head of a
; dispatch body).

lane_selector_body:

lane_sel_A:					; lane 0 entry (46DAh)
		retn

lane_sel_B:					; lane 1 entry (46DBh)
		cmp	cl,1
		jne	$+5
		mov	cl,2
		retn

lane_sel_cl_2_entry:				; lane 2 entry (46E2h)
		cmp	cl,2
		je	$+3
		retn

lane_sel_cl_1:					; reached when cmp above is cl=2 je
		mov	cl,1
		retn

; lane 3 entry (dispatch table dw 46FDh): swap cl 1<->0 (else fall through to lane 4)

lane_sel_C:
		cmp	cl,1
		jne	lane_sel_B_skip		; Jump if not equal
		mov	cl,0
		retn

lane_sel_B_skip:
		cmp	cl,2
		je	lane_sel_set_cl_1	; Jump if equal
		retn

lane_sel_set_cl_1:
		mov	cl,1
		retn

; lane 4 entry (dispatch table dw 470Eh): swap cl 2<->3 (else fall through to lane 5)

lane_sel_D:
		cmp	cl,2
		jne	lane_sel_C_skip		; Jump if not equal
		mov	cl,3
		retn

lane_sel_C_skip:
		cmp	cl,3
		je	lane_sel_set_cl_2	; Jump if equal
		retn

lane_sel_set_cl_2:
		mov	cl,2
		retn

; lane 5 entry (orphan tail): swap cl 1->3 only

lane_sel_E:
		cmp	cl,1
		je	lane_sel_set_cl_3	; Jump if equal
		retn

lane_sel_set_cl_3:
		mov	cl,3
		retn
; anim_seq_tbl -- frame-index / animation-offset data. Sourcer mis-decoded as code.
; Same function as EGA's anim_seq_tbl (accessed via CS-relative pointer from
; frame driver code). Approximately 70 bytes here + continuation below.

anim_seq_tbl:
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
		db	 01h, 02h, 01h, 02h, 03h, 04h			; tile pair lookup row 3: (1,2) x2 + (3,4)
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 4: (3,4) x3
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 5: (3,4) x3
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 6: (3,4) x3
		db	 03h, 04h, 03h, 04h, 03h, 04h			; tile pair lookup row 7: (3,4) x3
		db	 03h, 04h, 05h, 06h, 05h, 06h			; tile pair lookup row 8: (3,4) + (5,6) x2
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 9: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 10: (5,6) x3
		db	 05h, 06h, 05h, 06h, 05h, 06h			; tile pair lookup row 11: (5,6) x3
		db	 06h, 05h, 05h, 06h, 05h, 06h			; tile pair lookup row 12: swapped + (5,6) x2
; --- trailing HGC blit code stub (Sourcer mis-decoded) ---
		db	 1Eh, 50h,0E8h, 32h, 05h, 8Bh			; code: push ds; push ax; call ...; mov ...
		db	0F8h, 58h,0B1h, 10h,0F6h,0E1h			; code: mov di,ax; pop ax; mov cl,10h; mul cl
		db	 05h, 00h, 60h, 8Bh,0F0h, 2Eh			; code: add ax,6000h; mov si,ax; cs prefix
		db	 8Eh, 1Eh, 2Ch,0FFh,0B8h, 00h			; code: mov ds,cs:[2Ch]; mov ax,0...
		db	0B0h, 8Eh,0C0h,0B9h, 08h, 00h			; code: ...mov es,ax; mov cx,8

locloop_272:
				movsw				; Mov [si] to es:[di]
				add	di,1FFEh
				cmp	di,gvar_game_seg_b
				jb	loc_273			; Jump if below
				mov	ax,[si-2]
				stosw				; Store ax to es:[di]
				add	di,0A058h

loc_273:
				loop	locloop_272		; Loop if cx > 0

		pop	ds
		retn
; draw_hero_gfx -- draw hero graphics from phase_offset_tbl[ds:[92h]-1] into
; hgc_ui_ofs region. Writes 0x18 rows using OR into HGC framebuffer.

draw_hero_gfx:
		push	ds
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:phase_offset_tbl[bx]
		mov	di,hgc_ui_ofs
		mov	ax,0B000h
		mov	es,ax
		mov	cx,18h

locloop_274:
				lodsw				; String [si] to ax
				mov	bx,ax
				lodsw				; String [si] to ax
				or	es:[di],bx
				or	es:[di+2],ax
				add	di,2000h
				cmp	di,hgc_wrap_limit
				jb	loc_275			; Jump if below
				or	es:[di],bx
				or	es:[di+2],ax
				add	di,0A05Ah

loc_275:
				loop	locloop_274		; Loop if cx > 0

		pop	ds
		retn
; --- HGC sprite header (12 bytes mis-decoded by Sourcer as code) ---
		db	 8Eh, 49h, 8Eh, 49h, 8Eh, 49h			; sprite hdr: pointer entries 0..2 (498E x3)
		db	0EEh, 49h,0EEh			; sprite hdr: pointer entry 3 (49EE) + first byte of next
		db	 49h, 4Eh, 4Ah			; sprite hdr: tail (4E49,4A) -- end of 12-byte header
		db	45 dup (0)
; --- gf_hgc_proj_sprite_a: small HGC projectile bitmap (column-major, 6B/row) ---
gf_hgc_proj_sprite_a:
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
; --- gf_hgc_proj_sprite_b: medium HGC projectile bitmap ---
gf_hgc_proj_sprite_b:
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
; --- gf_hgc_proj_sprite_c: large HGC projectile bitmap (longer trail) ---
gf_hgc_proj_sprite_c:
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
; --- trailing HGC blit code stub (Sourcer mis-decoded as data) ---
		db	 00h, 00h, 1Eh, 0Ah,0C0h, 78h			; code: push ds; or al,c0h; js short
		db	 10h, 24h, 03h,0B2h, 40h,0F6h			; code: adc; and al,3; mov dl,40h
		db	0E2h, 05h, 46h, 4Bh, 8Bh,0F0h			; code: mul dl; add ax,4B46h; mov si,ax
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h			; code: mov bp,1; jmp short +0Eh
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h			; code: mov ah,al; xor al,al; add ax
		db	 46h, 4Ch, 8Bh,0F0h,0BDh, 04h			; code: ax+=4C46h; mov si,ax; mov bp,4
		db	 00h, 8Ah,0C3h, 24h, 03h, 02h			; code: mov al,bl; and al,3; add al
		db	0C0h,0A2h,0F8h, 4Fh,0D1h,0EBh			; code: ...mov [4FF8],al; shr bx,1
		db	0D1h,0EBh, 8Ah,0FBh, 8Ah,0D9h			; code: shr bx,1; mov bh,bl; mov bl,cl
		db	0E8h, 61h, 03h, 8Bh,0F8h,0B8h			; code: call rel; mov di,ax; mov ax
		db	 00h,0B0h, 8Eh,0C0h, 8Bh,0CDh			; code: ax=B000h; mov es,ax; mov cx,bp

locloop_276:
				push	cx
				push	di
				mov	cx,10h

locloop_277:
						push	cx
						push	si
						push	di
						call	shift_extract_loop
						pop	di
						pop	si
						add	di,2000h
						cmp	di,6000h
						jb	loc_278			; Jump if below
						push	si
						push	di
						call	shift_extract_loop
						pop	di
						pop	si
						add	di,sprite_src_c

loc_278:
						add	si,4
						pop	cx
						loop	locloop_277		; Loop if cx > 0

				pop	di
				add	di,4
				pop	cx
				loop	locloop_276		; Loop if cx > 0

		pop	ds
		retn

shift_extract_loop		proc	near
		mov	cx,2

locloop_279:
				push	cx
				lodsw				; String [si] to ax
				mov	bh,al
				xor	bl,bl			; Zero register
				mov	cl,cs:hgc_mask_state
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
				loop	locloop_279		; Loop if cx > 0

		retn

shift_extract_loop		endp

		db	22 dup (0)
; --- gf_hgc_tile_set: HGC tile/sprite frames ---
gf_hgc_tile_set:
gf_hgc_tile_00:
		db	 10h, 00h, 00h, 10h, 60h, 00h			; tile 00 row 0
		db	 00h, 07h,0C0h, 00h, 00h, 07h			; tile 00 row 1
		db	0C0h, 00h, 00h, 07h,0C0h, 00h			; tile 00 row 2
		db	 00h, 0Ch, 10h, 00h, 00h, 10h			; tile 00 row 3
		db	 00h			; tile 00 row 4 (1 byte trail)
		db	26 dup (0)
gf_hgc_tile_01:
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
gf_hgc_tile_02:
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
gf_hgc_tile_03:
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
gf_hgc_tile_04:
		db	 92h, 4Ah,0AAh,0EBh, 00h			; tile 04: 5-byte solid pattern
		db	34 dup (0)
gf_hgc_tile_05:
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
gf_hgc_tile_06:
		db	 81h, 00h, 00h, 00h,0C4h, 00h			; tile 06 row 0
		db	 00h, 00h,0BCh, 00h, 00h, 00h			; tile 06 row 1
		db	0EEh,0EAh, 24h, 20h,0FFh,0FFh			; tile 06 row 2
		db	0FFh,0FFh,0FBh,0AAh, 24h, 20h			; tile 06 row 3
		db	0FDh, 40h, 00h, 00h,0E6h, 00h			; tile 06 row 4
		db	 00h, 00h, 40h, 80h, 00h, 00h			; tile 06 row 5
		db	 00h			; tile 06 row 6 (1 byte)
		db	20h			; tile 06 trailing marker
		db	42 dup (0)
gf_hgc_tile_07:
		db	0D7h, 55h, 52h, 49h			; tile 07: 4-byte solid bar
		db	60 dup (0)
gf_hgc_tile_08:
		db	0A7h, 54h, 90h, 04h, 00h			; tile 08: 5-byte pattern
		db	37 dup (0)
gf_hgc_tile_09:
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
gf_hgc_tile_0A:
		db	 80h, 00h, 00h, 03h, 00h, 00h			; tile 0A row 0
		db	 00h, 0Ch, 00h, 00h, 00h, 38h			; tile 0A row 1
		db	 00h, 00h, 00h,0F0h, 00h, 00h			; tile 0A row 2
		db	 00h,0E5h, 02h, 00h, 10h,0F0h			; tile 0A row 3
		db	 00h, 00h, 00h, 3Ch, 00h, 00h			; tile 0A row 4
		db	 00h, 07h, 00h, 00h, 00h, 00h			; tile 0A row 5
		db	0C0h, 00h, 00h, 00h, 20h, 00h			; tile 0A row 6
		db	 00h, 00h, 04h			; tile 0A row 7 (3-byte trail)
		db	38 dup (0)
gf_hgc_tile_0B:
		db	 20h, 09h, 2Ah,0E5h			; tile 0B: 4-byte pattern
		db	28 dup (0)

hgc_pixel_addr_calc		proc	near
		xor	ax,ax			; Zero register
		mov	al,bl
		add	ax,1Ch
		mov	bl,3
		div	bl			; al, ah rem = ax/reg
		mov	bl,ah
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		ror	bl,1			; Rotate
		and	bl,60h			; '`'
		mov	ah,5Ah			; 'Z'
		mul	ah			; ax = reg * al
		add	ah,bl
		add	bh,5
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		retn

hgc_pixel_addr_calc		endp

; tile_decompress -- dispatch handler: copy CX*0x20 bytes from DS:SI into
; CS+0x3000h segment offset 0, then re-interpret those bytes as (dx,cx) word pairs
; and run through plane_pair_rol_loop + dispatch_shape_fill to produce blend values.
; Used for loading complex tile graphics with dithering.

tile_decompress:
		push	cx
		push	ds
		push	si
		mov	ax,cs
		add	ax,3000h
		mov	es,ax
		mov	ax,20h
		mul	cx			; dx:ax = reg * ax
		mov	cx,ax
		mov	di,zero_ofs
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	di
		pop	es
		pop	cx
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,zero_ofs

locloop_280:
				push	cx
				mov	cx,8

locloop_281:
						push	cx
						lodsw				; String [si] to ax
						mov	dx,ax
						lodsw				; String [si] to ax
						mov	cx,ax
						mov	cs:vga_row_ptr,dx
						mov	cs:scroll_state,cx
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
						mov	cs:shift_count,ax
						call	plane_pair_rol_loop
						mov	ax,dx
						stosw				; Store ax to es:[di]
						call	dispatch_shape_fill
						mov	es:[bp],dx
						inc	bp
						inc	bp
						pop	cx
						loop	locloop_281		; Loop if cx > 0

				pop	cx
				loop	locloop_280		; Loop if cx > 0

		retn

plane_pair_rol_loop		proc	near
		mov	cx,8

locloop_282:
				xor	bx,bx			; Zero register
				rol	word ptr cs:scroll_state,1	; Rotate
				adc	bx,bx
				rol	word ptr cs:vga_row_ptr,1	; Rotate
				adc	bx,bx
				rol	word ptr cs:scroll_state,1	; Rotate
				adc	bx,bx
				rol	word ptr cs:vga_row_ptr,1	; Rotate
				adc	bx,bx
				add	dx,dx
				add	dx,dx
				or	dl,cs:copy_fn_tbl[bx]
				loop	locloop_282		; Loop if cx > 0

		retn

plane_pair_rol_loop		endp

; copy_fn_tbl: 16-entry HGC color/copy lookup (4-bit BX index → 2-bit color via OR DL)
; Referenced by plane_pair_rol_loop `or dl,cs:copy_fn_tbl[bx]`
copy_fn_tbl_local:
		db	0, 1, 2, 1, 1, 3			; entries 0..5
		db	3, 1, 2, 3, 2, 2			; entries 6..11
		db	1, 1, 2, 3			; entries 12..15

dispatch_shape_fill		proc	near
		mov	cx,8

locloop_283:
				xor	al,al			; Zero register
				rol	word ptr cs:shift_count,1	; Rotate
				adc	al,al
				rol	word ptr cs:shift_count,1	; Rotate
				adc	al,al
				cmp	al,3
				je	loc_284			; Jump if equal
				xor	al,al			; Zero register

loc_284:
				add	dx,dx
				add	dx,dx
				or	dl,al
				loop	locloop_283		; Loop if cx > 0

		retn

dispatch_shape_fill		endp

; copy_internal_tbl_68 -- dispatch handler: copies 64-byte table from internal_tbl_68
; (CS) into hgc_plane_buf_a (game_seg). Used during driver setup.

copy_internal_tbl_68:
		push	ds
		push	cs
		pop	ds
		mov	si,internal_tbl_68
		mov	es,cs:game_seg
		mov	di,hgc_plane_buf_a
		mov	cx,20h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	ds
		retn
; --- Trailing data tables (0x1F4A..0x1FE5) ---
; Animation cycle / color ramp lookup tables. Sourcer mis-decoded as code.
; Referenced at runtime via CS-relative addressing from image decode routines.

cycle_tbl_a:
		db	 3Fh, 0F0h, 0Ch, 0Ch		; 0x1F4A: cycle entry 0
		db	 0Ch, 0Ch, 0Ch, 0Ch		; 0x1F4E
		db	 0Fh				; 0x1F52
		db	 0F0h, 0Ch, 0C0h		; 0x1F53
		db	 0Ch, 30h, 0Ch, 0Ch		; 0x1F56
		db	 3Fh				; 0x1F5A
		db	 0F0h, 0Ch, 0Ch			; 0x1F5B
		db	 0Ch, 0Ch			; 0x1F5E
		db	 0Fh				; 0x1F60
		db	 0F0h, 0Ch, 0Ch			; 0x1F61
		db	 0Ch, 0Ch, 0Ch, 0Ch		; 0x1F64
		db	 3Fh				; 0x1F68
		db	 0F0h, 0Fh			; 0x1F69
		db	 0F0h, 30h, 0Ch			; 0x1F6B
		db	 30h, 0Ch, 30h, 00h		; 0x1F6E
		db	 33h, 0FCh			; 0x1F72
		db	 30h, 0Ch, 30h, 0Ch		; 0x1F74
		db	 0Fh				; 0x1F78
		db	 0F0h, 30h, 0Ch			; 0x1F79
		db	 30h, 0Ch, 3Ch, 3Ch		; 0x1F7C
		db	 3Ch, 3Ch			; 0x1F80
		db	 33h, 0CCh, 33h, 0CCh		; 0x1F82
		db	 30h, 0Ch, 30h, 0Ch		; 0x1F86
		db	 92h, 4Fh			; 0x1F8A (runtime marker byte pair)
		db	 0A2h, 4Fh, 0B2h, 4Fh		; 0x1F8C (ptr word pattern)
		db	 0C2h, 4Fh, 0D2h, 4Fh		; 0x1F90
		db	 0C2h, 4Fh, 00h			; 0x1F94

cycle_tbl_b:
; 0x1F97: sequential animation frame indices / color ramp table (79 bytes)
		db	 01h, 02h			; 0x1F97
		db	 03h, 04h			; 0x1F99
		db	 05h, 06h, 07h			; 0x1F9B (`add ax, 0706h` = 05 06 07)
		db	 08h, 09h			; 0x1F9E
		db	 0Ah, 0Bh			; 0x1FA0
		db	 0Ch, 0Dh			; 0x1FA2
		db	 0Eh				; 0x1FA4
		db	 0Fh				; 0x1FA5
		db	 00h, 02h			; 0x1FA6
		db	 01h, 03h			; 0x1FA8
		db	 08h, 0Ah			; 0x1FAA
		db	 09h, 0Bh			; 0x1FAC
		db	 04h, 06h			; 0x1FAE
		db	 05h, 07h, 0Ch			; 0x1FB0 (`add ax, 0C07h` = 05 07 0C)
		db	 0Eh				; 0x1FB3
		db	 0Dh, 0Fh, 00h			; 0x1FB4 (`or ax, 0Fh` = 0D 0F 00)
		db	 00h, 01h			; 0x1FB7
		db	 03h, 00h			; 0x1FB9
		db	 00h, 01h			; 0x1FBB
		db	 03h, 04h			; 0x1FBD
		db	 04h, 05h			; 0x1FBF
		db	 07h				; 0x1FC1
		db	 0Ch, 0Ch			; 0x1FC2
		db	 0Dh, 0Fh, 00h			; 0x1FC4 (`or ax, 0Fh` = 0D 0F 00)
		db	 02h, 03h			; 0x1FC7
		db	 01h, 08h			; 0x1FC9
		db	 0Ah, 0Bh			; 0x1FCB
		db	 09h, 0Ch			; 0x1FCD
		db	 0Eh				; 0x1FCF
		db	 0Fh				; 0x1FD0
		db	 0Dh, 04h, 06h			; 0x1FD1 (`or ax, 0604h` = 0D 04 06)
		db	 07h				; 0x1FD4
		db	 05h, 00h, 03h			; 0x1FD5 (`add ax, 0300h` = 05 00 03)
		db	 00h, 02h			; 0x1FD8
		db	 0Ch, 0Fh			; 0x1FDA
		db	 0Ch, 0Eh			; 0x1FDC
		db	 00h, 03h			; 0x1FDE
		db	 00h, 02h			; 0x1FE0
		db	 08h, 0Bh			; 0x1FE2
		db	 08h, 0Ah			; 0x1FE4

		db	724 dup (0)			; end-of-segment zero padding

seg_a		ends

		end	start
