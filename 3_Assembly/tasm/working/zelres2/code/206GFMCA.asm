
PAGE  59,132

;==========================================================================
;
;  206GFMCA.BIN - MCGA Graphics Fill Driver (zelres2 chunk 6)
;
;  MCGA (PS/2 Model 30) graphics variant of the battle/gameplay sprite-fill
;  driver. Renders sprites, tiles, scrolling backgrounds, and hero/enemy
;  graphics for MCGA 320x200x256 mode at A000h (chunky pixels, one byte
;  per pixel ?-- no bit-planes unlike EGA). Parallels 202GFEGA in structure
;  (same dispatch table layout, same drv_init_stub patchable byte, same
;  sprite-scan loop).
;
;  Key subsystems:
;    gfmca_main             - main per-frame entry: scan sprite slots, render rows
;    mca_sprite_blit        - sprite blit with plane-select cache
;    sprite_src_setup       - resolve sprite source address + palette_byte
;    mca_sprite_blit_ex     - expanded sprite blit
;    mca_sprite_render_solid- solid sprite render (no blend)
;    mca_blit_2bytes_8rows  - 8-row straight copy
;    frame_row_driver       - per-frame row dispatcher
;    draw_ui_tiles          - draw 5x28 UI tile grid from phase_offset_tbl
;    bg_tile_blit           - blit single background tile
;    hero_sprite_col_blit   - hero sprite columns from game_seg
;    anim_refresh_all       - full 8-pass animation refresh
;    mca_color_fade_init    - color-fade gradient init (3 radii)
;    fade_gradient_rect     - box fade with 3 concentric radii
;    projectile_spawn_check - check row position, spawn projectile
;    projectile_render_list - render & advance all active projectiles
;    mca_sprite_2block_render- 2-block sprite render w/ color xform dispatch
;    mca_pixel_lookup_tbls  - pixel index remap tables for shift renderers
;
;  Animation dispatch via dispatch_tbl (game DS): 5 handler procs
;  anim_cycle_2frame_1B/6frame_1D/2frame_2C/4frame_25 and the neg handler.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; External data references (outside this module's CS segment).

; --- Game-segment data pointers (in game_seg via DS) ---
sprite_gfx_base	equ	4000h			;* sprite graphics base offset in game_seg
game_data_base	equ	6000h			;* game segment data base offset
mca_sprite_src	equ	6333h			;* MCGA sprite source table (game_seg)
bg_copy_dst	equ	9350h			;* background copy destination offset
mca_sprite_src_b equ	0B000h			;* MCGA alternate sprite src base
mca_plane_alt	equ	0B17Eh			;* alternate plane/offset table
mca_pattern_base equ	0D000h			;* pattern/tile data base

; --- Internal driver tables (CS-relative) ---
init_xor_src	equ	2939h			;* init XOR source addr referenced in start header
dispatch_tbl	equ	3176h			;* function dispatch table (word array)
anim_frame_tbl	equ	3893h			;* animation frame offset table
pattern_ptr_tbl	equ	389Bh			;* pattern pointer table
init_tbl_59	equ	3963h			;* init table at 3963h (referenced in start header)
init_tbl_60	equ	3F38h			;* init table at 3F38h (referenced in start header)
color_map_tbl	equ	4086h			;* color map/pair word table
phase_offset_tbl equ	4588h			;* phase/shift offset table
bg_tile_src	equ	46D4h			;* background tile source pointer
copy_fn_tbl	equ	4A25h			;* copy function pointer table (word array)
hero_gfx_tbl	equ	4F8Ch			;* hero graphics data table

; --- Driver state variables (CS-segment scratch area) ---
cur_color_pair	equ	4FE9h			;* current color pair word (set from table)
vga_row_ptr	equ	4FEBh			;* current VGA row byte offset (word)
scroll_vga_ofs	equ	4FEDh			;* scroll destination VGA byte offset (word)
rle_tmp_a	equ	4FEFh			;* RLE temp word A (cs: scratch)
row_counter	equ	4FF1h			;* row countdown (0x12 rows per frame)
col_idx		equ	4FF2h			;* current column index (byte)
row_idx		equ	4FF3h			;* current row index (byte)
palette_byte	equ	4FF4h			;* palette byte for current sprite
rle_tmp_b	equ	4FF5h			;* RLE temp word B (cs: scratch)
scroll_src_ofs	equ	4FF7h			;* scroll source VGA byte offset (word)
scroll_gfx_ptr	equ	4FF9h			;* scroll graphics data pointer (word)
scroll_delta	equ	4FFBh			;* scroll delta (word: col byte + row byte)
rle_mask	equ	4FFDh			;* RLE mask word (cs: scratch)
anim_phase	equ	4FFFh			;* animation pass counter (0-7, decremented)
sprite_row_buf	equ	5000h			;* sprite row intermediate buffer base
sprite_state_a	equ	5010h			;* sprite slot state byte A (0xFF=empty, 0xFC=hidden)
sprite_state_b	equ	5011h			;* sprite slot state byte B
sprite_pos	equ	5014h			;* sprite position word (col/row packed)
sprite_cache_tbl equ	501Dh			;* sprite cache table (word array, indexed by slot*2)
sprite_tmp_buf	equ	511Dh			;* sprite temporary pixel buffer

; --- Game-segment lookup tables ---
sprite_lookup_base equ	625Ch			;* sprite graphics lookup base offset
sprite_src_base	equ	0A030h			;* sprite source graphics base offset (game_seg)
sprite_attr_base equ	0C010h			;* sprite attribute record base
sprite_attr_b	equ	0C012h			;* sprite attribute record +2 (sub-field)
pattern_base	equ	0E000h			;* background pattern data base
sprite_buf	equ	0E900h			;* sprite staging buffer base
sprite_buf_b	equ	0E91Bh			;* sprite staging buffer +0x1B
char_lookup	equ	0ED20h			;* character/tile lookup table
projectile_list	equ	0EDA0h			;* projectile slot list base

; --- Global variables (game_seg:0xFFxx) ---
mca_temp_buf	equ	0FA00h			;* MCGA temp intermediate buffer (game_seg)
frame_timer	equ	0FF1Ah			;* frame timer counter (increments each interrupt)
game_seg	equ	0FF2Ch			;* game segment selector word
flag_shadow	equ	0FF2Fh			;* shadow/invincibility flag byte
sprite_data_ptr	equ	0FF31h			;* sprite data table pointer (word)
anim_speed	equ	0FF33h			;* animation speed counter byte
flag_equip_b	equ	0FF34h			;* equipment state flag B
enemy_counter	equ	0FF35h			;* active enemy count byte
color_sel	equ	0FF36h			;* color selector byte
redraw_lock	equ	0FF37h			;* redraw lock/busy flag byte
flag_shield	equ	0FF38h			;* shield equipped flag byte
flag_climbing	equ	0FF39h			;* climbing/jump state flag byte
flag_riding	equ	0FF3Ah			;* riding/mount state flag byte
equip_byte	equ	0FF3Dh			;* equipment state byte (packed flags)
hero_frame	equ	0FF3Fh			;* hero animation frame index byte
flag_hero_state	equ	0FF40h			;* hero state flag byte
weapon_state	equ	0FF41h			;* weapon animation state byte
shield_sel	equ	0FF42h			;* shield type selector byte
scroll_active	equ	0FF43h			;* scrolling active flag byte
restore_pending	equ	0FF44h			;* restore-to-background pending flag byte
scroll_phase	equ	0FF45h			;* scroll animation phase byte
scroll_step	equ	0FF46h			;* scroll step counter byte

; --- Fixed MCGA layout constants ---
mca_row_stride	equ	138h			; MCGA bytes per row (312 dec) -- row advance in tight pixel loops
mca_2row_stride	equ	500h			; two-row stride used by blit routines
mca_vga_base_ofs equ	11B0h			; MCGA VGA framebuffer working offset base
mca_temp_buf_a	equ	0FA00h			; MCGA temp buffer A (dup of mca_temp_buf for literal form)
mca_temp_buf_b	equ	0FA40h			; MCGA temp buffer B

mca_seg		equ	0A000h			; MCGA framebuffer segment (same as VGA mode 13h)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

gfmca_main		proc	far

start:
; gfmca_main inline init block (0x0000-0x0045):
; The bytes in 0x0000-0x002F are a Sourcer mis-decode of an init-time data table
; (same pattern as EGA variant); they are not executed as the instructions shown.
; The real init code begins at 0x0030 with `push cs / pop es / ...`.
		pop	bp
		and	ax,[bx+si]
		add	[si],ch
		xor	ds:init_xor_src[bx+di],bh
		aas				; Ascii adjust
		xor	al,3Eh			; '>'
		das				; Decimal adjust
		inc	cx
		lodsw				; String [si] to ax
		inc	sp
		sar	byte ptr [bx],1		; Shift w/sign fill
		jc	loc_1			; Jump if carry Set
		db	 9Bh, 37h, 92h, 41h,0F0h, 40h
		db	0A3h, 39h,0F7h, 42h,0CEh, 44h
		db	 18h, 45h, 14h, 46h,0D7h, 40h
		db	 33h, 49h, 90h, 49h, 51h, 4Bh
		db	0DDh, 4Eh,0E8h, 4Fh		; init table tail (4 bytes)
; [0x0030] Real init code begins here (common to all GF* drivers):
		push	cs				; 0E
		pop	es				; 07
		mov	di,sprite_cache_tbl		; BF 1D 50
		xor	ax,ax				; 33 C0
		db	0B9h				; mov cx, imm16 opcode -- data_8 dw is the immediate
data_8		dw	80h				; word immediate for `mov cx, 80h`
		rep	stosw				; F3 AB -- zero sprite_cache_tbl (0x80 words)
; [0x003C] drv_init_stub: opcode byte (FEh) is a patch target ?-- callers may
; overwrite it to skip or alter init behavior.

drv_init_stub:
data_9		db	0FEh				; FE -- `inc byte ptr ...` opcode (patch target)
		db	06h, 0FFh, 4Fh			; 06 FF 4F -- operand: ds:[anim_phase]
		mov	word ptr ds:vga_row_ptr,mca_vga_base_ofs	; C7 06 EB 4F B0 11

loc_1:
		mov	si,ds:sprite_data_ptr
		sub	si,21h
; [0x004D-0x004F] call with mid-instruction label: mca_row_ofs labels the
; displacement bytes. Callers patch the displacement to redirect this call
; at runtime. Current target: 0x0050 + 0x14C0 = 0x1510 (si_wrap_lo).
		db	0E8h				; call near opcode
mca_row_ofs	db	0C0h, 14h			; displacement (patch target); initially calls 1510h
		xor	bx,bx			; Zero register
		test	byte ptr [si],80h
		jz	loc_2			; Jump if zero
		call	sprite_slot_remove

loc_2:
		inc	si
		mov	cx,6

init_scan_loop:
			push	cx
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
			pop	cx
			loop	init_scan_loop		; Loop if cx > 0

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
		test	byte ptr [si],80h
		jz	loc_10			; Jump if zero
		call	sprite_slot_init

loc_10:
		inc	si
		test	byte ptr [si],80h
		jz	loc_11			; Jump if zero
		call	sprite_blit_dispatch

loc_11:
		mov	si,ds:sprite_data_ptr
		mov	di,0E900h
		mov	byte ptr ds:row_counter,12h

loc_12:
			call	frame_row_dispatcher
			xor	bx,bx			; Zero register
			add	si,3
			lodsb				; String [si] to al
			or	al,al			; Zero ?
			jns	loc_13			; Jump if not sign
			call	sprite_wide_row_render

loc_13:
			mov	cx,6

col_scan_loop:
				push	cx
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
				pop	cx
				loop	col_scan_loop		; Loop if cx > 0

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
			cmpsb				; Cmp [si] to es:[di]
			jz	loc_21			; Jump if zero
			call	sprite_state_update

loc_21:
			inc	bx
			lodsb				; String [si] to al
			inc	di
			or	al,al			; Zero ?
			jns	loc_22			; Jump if not sign
			jmp	loc_62

loc_22:
			cmp	al,es:[di-1]
			je	loc_23			; Jump if equal
			call	sprite_state_update

loc_23:
			add	si,4
			call	si_wrap_hi
			add	word ptr ds:vga_row_ptr,0A00h
			dec	byte ptr ds:row_counter
			jnz	loc_12			; Jump if not zero
		retn

gfmca_main		endp

sprite_state_update		proc	near
		mov	al,[si-1]
		or	al,al			; Zero ?
		jns	loc_24			; Jump if not sign
		jmp	loc_60

loc_24:
		cmp	byte ptr es:[di-1],0FCh
		jne	loc_25			; Jump if not equal
		mov	byte ptr es:[di-1],0FFh
		jmp	short loc_26

loc_25:
		inc	byte ptr es:[di-1]
		mov	byte ptr es:[di-1],0FEh
		jz	loc_26			; Jump if zero
		mov	es:[di-1],al
		mov	dx,bx
		add	dx,dx
		add	dx,dx
		add	dx,dx
		add	dx,ds:vga_row_ptr
		shr	dx,1			; Shift w/zeros fill
		call	mca_sprite_blit

loc_26:
		mov	al,ds:sprite_attr_b
		sub	al,5
		jnc	loc_27			; Jump if carry=0
		retn

loc_27:
		cmp	al,4
		jb	loc_28			; Jump if below
		retn

loc_28:
		push	bx
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		call	word ptr ds:dispatch_tbl[bx]	;*
		pop	bx
		retn

sprite_state_update		endp

; Dispatch handler: 2-frame alternating animation (frame base 0x1B, 2 frames).
; Entry via dispatch_tbl[bx]. Prologue bytes decode as jle/sahf/xor via Sourcer;
; kept as db to preserve exact encoding (overlapping-instruction trick).

anim_cycle_2frame_1B:
		db	 7Eh, 31h		; jle +31h (fixup byte sequence)
		sahf				; 9Eh
		db	 31h,0D4h		; xor sp,dx (alt encoding)
		xor	[bp+si+32h],dx
		mov	al,[si-1]
		sub	al,1Bh
		cmp	al,2
		jb	loc_29			; Jump if below
		retn

loc_29:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_30			; Jump if not zero
		retn

loc_30:
		inc	al
		and	al,1
		add	al,1Bh
		mov	[si-1],al
		retn

; Dispatch handler: 6-frame bidirectional animation (frame base 0x1D, 6 frames).

anim_cycle_6frame_1D:
		mov	al,[si-1]
		sub	al,1Dh
		cmp	al,6
		jb	loc_31			; Jump if below
		retn

loc_31:
		mov	byte ptr [di-1],0FEh
		cmp	al,4
		jae	loc_34			; Jump if above or =
		or	al,al			; Zero ?
		jnz	loc_33			; Jump if not zero
		push	ax
		call	word ptr cs:[11Ah]
		and	al,3
		pop	ax
		jz	loc_33			; Jump if zero
		retn

loc_33:
		inc	al
		and	al,3
		add	al,1Dh
		mov	[si-1],al
		retn

loc_34:
		inc	al
		and	al,1
		add	al,21h			; '!'
		mov	[si-1],al
		retn
; Dispatch handler: 2-frame alternating animation (frame base 0x2C, 2 frames + lookup).

anim_cycle_2frame_2C:
		mov	al,[si-1]
		sub	al,2Ch			; ','
		cmp	al,2
		jae	loc_36			; Jump if above or =
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_35			; Jump if not zero
		retn

loc_35:
		inc	al
		and	al,1
		add	al,2Ch			; ','
		mov	[si-1],al
		retn

loc_36:
		mov	al,[si-1]
		cmp	al,3Eh			; '>'
		jb	loc_37			; Jump if below
		retn

loc_37:
		mov	bl,33h			; '3'
		cmp	al,0Eh
		je	loc_39			; Jump if equal
		mov	bl,36h			; '6'
		cmp	al,0Dh
		je	loc_39			; Jump if equal
		mov	bl,39h			; '9'
		cmp	al,0Fh
		je	loc_39			; Jump if equal
		mov	bl,3Ch			; '<'
		cmp	al,0Ch
		je	loc_39			; Jump if equal
		mov	bl,3Dh			; '='
		cmp	al,10h
		je	loc_39			; Jump if equal
		sub	al,33h			; '3'
		jnc	loc_38			; Jump if carry=0
		retn

loc_38:
		mov	bl,0Eh
		cmp	al,2
		je	loc_39			; Jump if equal
		mov	bl,0Dh
		cmp	al,5
		je	loc_39			; Jump if equal
		mov	bl,0Fh
		cmp	al,8
		je	loc_39			; Jump if equal
		mov	bl,0Ch
		cmp	al,9
		je	loc_39			; Jump if equal
		mov	bl,10h
		cmp	al,0Ah
		je	loc_39			; Jump if equal
		inc	al
		add	al,33h			; '3'
		mov	bl,al

loc_39:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_40			; Jump if not zero
		retn

loc_40:
		mov	[si-1],bl
		retn
; Dispatch handler: 4-frame cycling animation (frame base 0x25, 4 frames).

anim_cycle_4frame_25:
		mov	al,[si-1]
		sub	al,25h			; '%'
		cmp	al,4
		jb	loc_41			; Jump if below
		retn

loc_41:
		mov	byte ptr [di-1],0FEh
		test	byte ptr ds:anim_phase,1
		jnz	loc_42			; Jump if not zero
		retn

loc_42:
		inc	al
		and	al,3
		add	al,25h			; '%'
		mov	[si-1],al
		retn

mca_sprite_blit		proc	near
		push	es
		push	ds
		push	di
		push	si
		push	bx
		add	dx,dx
		mov	di,dx
		or	al,al			; Zero ?
		jnz	loc_43			; Jump if not zero
		jmp	loc_48

loc_43:
		mov	bl,al
		xor	bh,bh			; Zero register
		add	bx,bx
		test	word ptr ds:sprite_cache_tbl[bx],0FFFFh
		jnz	loc_46			; Jump if not zero
		dec	al
		mov	ds:sprite_cache_tbl[bx],di
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	cx,8

sprite_blit_8rows_loop:
			push	cx
			mov	cx,2

sprite_blit_inner_loop:
				lodsw				; String [si] to ax
				mov	dx,ax
				lodsb				; String [si] to al
				mov	bl,al
				mov	bh,dl
				shr	dx,1			; Shift w/zeros fill
				shr	dx,1			; Shift w/zeros fill
				mov	es:[di],dh
				shr	dl,1			; Shift w/zeros fill
				shr	dl,1			; Shift w/zeros fill
				mov	es:[di+1],dl
				add	bx,bx
				add	bx,bx
				and	bh,3Fh			; '?'
				mov	es:[di+2],bh
				and	al,3Fh			; '?'
				mov	es:[di+3],al
				add	di,4
				loop	sprite_blit_inner_loop		; Loop if cx > 0

			add	di,mca_row_stride
			pop	cx
			loop	sprite_blit_8rows_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_46:
		mov	si,ds:sprite_cache_tbl[bx]
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	cx,8

sprite_cache_8rows_loop:
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			add	di,mca_row_stride
			add	si,138h
			loop	sprite_cache_8rows_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

loc_48:
		mov	ax,0A000h
		mov	es,ax
		xor	ax,ax			; Zero register
		mov	cx,8

sprite_clear_8rows_loop:
			stosw				; Store ax to es:[di]
			stosw				; Store ax to es:[di]
			stosw				; Store ax to es:[di]
			stosw				; Store ax to es:[di]
			add	di,138h
			loop	sprite_clear_8rows_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn

mca_sprite_blit		endp

sprite_slot_remove		proc	near
		cmp	byte ptr ds:sprite_buf,0FFh
		jne	loc_50			; Jump if not equal
		retn

loc_50:
		cmp	byte ptr ds:sprite_buf,0FCh
		jne	loc_51			; Jump if not equal
		retn

loc_51:
		push	si
		push	bx
		mov	byte ptr ds:sprite_buf,0FFh
		mov	cl,[si]
		add	si,25h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_52			; Jump if not sign
		call	sprite_get_value

loc_52:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,3
		pop	ax
		mov	ah,[si]
		mov	dx,11B0h
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
		add	dx,dx
		add	dx,11B0h
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
		jne	loc_53			; Jump if not equal
		retn

loc_53:
		cmp	byte ptr ds:sprite_buf_b,0FCh
		jne	loc_54			; Jump if not equal
		retn

loc_54:
		mov	byte ptr ds:sprite_buf_b,0FFh
		mov	cl,[si]
		add	si,24h
		call	si_wrap_hi
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_55			; Jump if not sign
		call	sprite_get_value

loc_55:
		push	ax
		mov	al,cl
		call	sprite_src_setup
		add	si,2
		pop	ax
		mov	ah,[si]
		mov	dx,1288h
		jmp	loc_69

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
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_57			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_57			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_56			; Jump if not sign
		call	sprite_get_value

loc_56:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_57:
		add	dx,0A00h
		cmp	byte ptr ds:row_counter,1
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_59			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_59			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_58			; Jump if not sign
		call	sprite_get_value

loc_58:
		call	sprite_cell_render

loc_59:
		pop	bx
		pop	di
		pop	si
		retn

loc_60:
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
		add	dx,dx
		add	dx,ds:vga_row_ptr
		mov	al,cl
		call	sprite_src_setup
		mov	di,sprite_pos
		mov	[di],al
		mov	bp,sprite_state_a
		call	sprite_pos_pair_iter
		cmp	byte ptr ds:row_counter,1
		je	loc_61			; Jump if equal
		add	dx,9F0h
		call	sprite_pos_pair_iter
		test	byte ptr ds:flag_equip_b,0FFh
		jz	loc_61			; Jump if zero
		test	byte ptr ds:flag_shadow,0FFh
		jz	loc_61			; Jump if zero
		call	projectile_spawn_check

loc_61:
		pop	bx
		pop	di
		pop	si
		retn

loc_62:
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
		add	dx,dx
		add	dx,ds:vga_row_ptr
		cmp	byte ptr ds:sprite_state_a,0FFh
		je	loc_64			; Jump if equal
		cmp	byte ptr ds:sprite_state_a,0FCh
		je	loc_64			; Jump if equal
		mov	ah,[si]
		mov	al,bl
		push	bx
		push	si
		push	dx
		or	al,al			; Zero ?
		jns	loc_63			; Jump if not sign
		call	sprite_get_value

loc_63:
		call	sprite_cell_render
		pop	dx
		pop	si
		pop	bx

loc_64:
		add	dx,0A00h
		cmp	byte ptr ds:row_counter,1
		je	loc_66			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FFh
		je	loc_66			; Jump if equal
		cmp	byte ptr ds:sprite_state_b,0FCh
		je	loc_66			; Jump if equal
		inc	si
		inc	si
		lodsb				; String [si] to al
		mov	ah,al
		mov	al,bh
		or	al,al			; Zero ?
		jns	loc_65			; Jump if not sign
		call	sprite_get_value

loc_65:
		call	sprite_cell_render

loc_66:
		pop	bx
		pop	di
		pop	si
		jmp	loc_23

sprite_pos_pair_iter:
		call	sprite_pos_blit

sprite_pos_blit:
		cmp	byte ptr ds:[bp],0FFh
		je	loc_68			; Jump if equal
		cmp	byte ptr ds:[bp],0FCh
		je	loc_68			; Jump if equal
		mov	ah,[si]
		mov	al,[di]
		or	al,al			; Zero ?
		jns	loc_67			; Jump if not sign
		call	sprite_get_value

loc_67:
		push	bp
		push	si
		push	di
		push	dx
		call	sprite_cell_render
		pop	dx
		pop	di
		pop	si
		pop	bp

loc_68:
		inc	si
		inc	di
		inc	bp
		add	dx,8
		retn

sprite_cell_render:

loc_69:
		push	es
		push	ds
		mov	bl,ds:palette_byte
		or	al,al			; Zero ?
		jz	loc_70			; Jump if zero
		js	loc_70			; Jump if sign=1
		or	bl,80h

loc_70:
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
		mov	ax,0A000h
		mov	es,ax
		mov	ch,bl
		and	bl,7Fh
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,cs:hero_gfx_tbl[bx]
		mov	cs:cur_color_pair,ax
		mov	al,cl
		or	ch,ch			; Zero ?
		js	loc_71			; Jump if sign=1
		push	di
		mov	di,0FA00h
		call	mca_plane_copy_16rows
		pop	di
		mov	si,mca_temp_buf_a
		mov	ax,0A000h
		mov	ds,ax
		call	mca_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

loc_71:
		push	di
		mov	di,mca_temp_buf
		call	mca_sprite_blit_ex
		pop	di
		mov	si,mca_temp_buf_a
		mov	ax,0A000h
		mov	ds,ax
		call	mca_blit_2bytes_8rows
		pop	ds
		pop	es
		retn

sprite_blit_dispatch		endp

mca_sprite_blit_ex		proc	near
		push	bp
		push	si
		push	di
		dec	cl
		mov	al,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	mca_sprite_render_solid
		pop	di
		pop	si
		pop	bp
		jmp	short $+2		; delay for I/O

mca_plane_3_iter:
		mov	cx,8

ai_mul_8rows_loop:
			push	cx
			mov	dl,ds:[bp]
			lodsw				; String [si] to ax
			call	mca_plane_nibble_iter
			lodsw				; String [si] to ax
			call	mca_plane_nibble_iter
			inc	bp
			pop	cx
			loop	ai_mul_8rows_loop		; Loop if cx > 0

		retn

mca_sprite_blit_ex		endp

mca_plane_nibble_iter		proc	near
		mov	cx,4

nibble_4px_loop:
			add	dl,dl
			sbb	dh,dh
			and	dh,es:[di]
			call	mca_fetch_color_lut
			or	bl,dh
			mov	es:[di],bl
			inc	di
			loop	nibble_4px_loop		; Loop if cx > 0

		retn

mca_plane_nibble_iter		endp

mca_plane_copy_16rows		proc	near
		mov	cx,8

plane_copy_8rows_loop:
			push	cx
			lodsw				; String [si] to ax
			call	mca_plane_copy_4px
			lodsw				; String [si] to ax
			call	mca_plane_copy_4px
			pop	cx
			loop	plane_copy_8rows_loop		; Loop if cx > 0

		retn

mca_plane_copy_16rows		endp

mca_plane_copy_4px		proc	near
		mov	cx,4

plane_copy_4px_loop:
			call	mca_fetch_color_lut
			mov	es:[di],bl
			inc	di
			loop	plane_copy_4px_loop		; Loop if cx > 0

		retn

mca_plane_copy_4px		endp

mca_fetch_color_lut		proc	near
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		add	ax,ax
		adc	bx,bx
		and	bx,0Fh
		add	bx,cs:cur_color_pair
		mov	bl,cs:[bx]
		retn

mca_fetch_color_lut		endp

mca_blit_2bytes_8rows		proc	near
		mov	cx,8

blit_8rows_loop:
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			movsw				; Mov [si] to es:[di]
			add	di,138h
			loop	blit_8rows_loop		; Loop if cx > 0

		retn

mca_blit_2bytes_8rows		endp

mca_sprite_render_solid		proc	near
		mov	cx,10h

extract_bits_loop:
			lodsw				; String [si] to ax
			mov	dx,ax
			lodsb				; String [si] to al
			mov	bl,al
			mov	bh,dl
			shr	dx,1			; Shift w/zeros fill
			shr	dx,1			; Shift w/zeros fill
			mov	es:[di],dh
			shr	dl,1			; Shift w/zeros fill
			shr	dl,1			; Shift w/zeros fill
			mov	es:[di+1],dl
			add	bx,bx
			add	bx,bx
			and	bh,3Fh			; '?'
			mov	es:[di+2],bh
			and	al,3Fh			; '?'
			mov	es:[di+3],al
			add	di,4
			loop	extract_bits_loop		; Loop if cx > 0

		retn

mca_sprite_render_solid		endp

mca_sprite_clear_cell		proc	near
		xor	ax,ax			; Zero register
		mov	cx,20h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn

mca_sprite_clear_cell		endp

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
		jnz	loc_78			; Jump if not zero
		mov	si,sprite_src_base

loc_78:
		mov	bl,ds:[bp+4]
		and	bl,1Fh
		add	bl,bl
		xor	bh,bh			; Zero register
		add	ax,[bx+si]
		mov	si,ax
		lodsb				; String [si] to al
		test	byte ptr ds:flag_equip_b,0FFh
		jnz	loc_79			; Jump if not zero
		test	byte ptr ds:[bp+5],20h	; ' '
		jz	loc_79			; Jump if zero
		add	al,3

loc_79:
		mov	ds:palette_byte,al
		mov	al,cl
		retn

sprite_src_setup		endp

projectile_spawn_check		proc	near
		cmp	byte ptr ds:row_idx,10h
		jb	loc_80			; Jump if below
		retn

loc_80:
		push	cs
		pop	es
		call	word ptr cs:[11Ah]
		and	al,0Fh
		cmp	al,0Eh
		jae	loc_81			; Jump if above or =
		retn

loc_81:
		mov	di,projectile_list
		xor	cl,cl			; Zero register

loc_82:
			cmp	byte ptr [di],0FFh
			je	loc_83			; Jump if equal
			add	di,4
			inc	cl
			jmp	short loc_82

loc_83:
		cmp	cl,20h			; ' '
		jb	loc_84			; Jump if below
		retn

loc_84:
			call	word ptr cs:[11Ah]
			and	al,3
			cmp	al,3
			je	loc_84			; Jump if equal
		dec	al
		add	al,ds:col_idx
		cmp	al,0FFh
		jne	loc_85			; Jump if not equal
		mov	al,4

loc_85:
		cmp	al,1Bh
		jb	loc_86			; Jump if below
		mov	al,1Ah

loc_86:
		stosb				; Store al to es:[di]

loc_87:
			call	word ptr cs:[11Ah]
			and	al,3
			cmp	al,3
			je	loc_87			; Jump if equal
		dec	al
		add	al,ds:row_idx
		cmp	al,0FFh
		jne	loc_88			; Jump if not equal
		xor	al,al			; Zero register

loc_88:
		stosb				; Store al to es:[di]
		mov	al,3
		stosb				; Store al to es:[di]
		call	word ptr cs:[11Ah]
		and	al,3
		stosb				; Store al to es:[di]
		mov	al,0FFh
		stosb				; Store al to es:[di]
		retn

projectile_spawn_check		endp

; projectile_render_list -- walk the projectile_list, render each active
; projectile and advance its phase. Called indirectly; Sourcer missed it.

projectile_render_list:
		push	cs
		pop	es
		mov	di,projectile_list
		mov	si,di

loc_89:
		cmp	byte ptr [si],0FFh
		jne	loc_90			; Jump if not equal
		mov	byte ptr [di],0FFh
		retn

loc_90:
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
		mov	al,[si+1]
		xor	ah,ah			; Zero register
		mov	dx,0A00h
		mul	dx			; dx:ax = reg * ax
		mov	cl,[si]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,11B0h
		push	si
		push	di
		push	es
		push	ax
		mov	bl,[si+3]
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	ax,ds:anim_frame_tbl[bx]
		mov	ds:rle_tmp_b,ax
		mov	bl,[si+2]
		and	bl,3
		add	bl,bl
		xor	bh,bh			; Zero register
		mov	si,ds:pattern_ptr_tbl[bx]
		pop	di
		mov	ax,0A000h
		mov	es,ax
		mov	cx,10h

projectile_16rows_loop:
			lodsw				; String [si] to ax
			xchg	ah,al
			call	mca_expand_nibble
			not	bp
			and	es:[di],bp
			or	es:[di],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+2],bp
			or	es:[di+2],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+4],bp
			or	es:[di+4],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+6],bp
			or	es:[di+6],dx
			lodsw				; String [si] to ax
			xchg	ah,al
			call	mca_expand_nibble
			not	bp
			and	es:[di+8],bp
			or	es:[di+8],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Ah],bp
			or	es:[di+0Ah],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Ch],bp
			or	es:[di+0Ch],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Eh],bp
			or	es:[di+0Eh],dx
			add	di,140h
			loop	projectile_16rows_loop		; Loop if cx > 0

		pop	es
		pop	di
		pop	si
		dec	byte ptr [si+2]
		cmp	byte ptr [si+2],0FFh
		je	loc_92			; Jump if equal
		movsw				; Mov [si] to es:[di]
		movsw				; Mov [si] to es:[di]
		sub	si,4

loc_92:
		add	si,4
		jmp	loc_89
; sprite_shape_tbl -- symmetric sprite/icon bitmap data used for shield/sparkle
; FX render. 275 bytes at 0x0897..0x09A9 (Sourcer mis-decoded these pixels as
; instructions). Contains small-to-large concentric symmetric shapes with
; zero-padding between entries.

sprite_shape_tbl	label	byte
		db	 10h,  12h,  30h,  36h,  38h,  3Fh,  30h,  36h,  63h,  39h,  23h,  39h	; 0x0897 header bytes
		db	0E3h,  38h, 0A3h,  38h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h
		db	 00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  0Bh, 0D0h,  00h
		db	 00h,  5Fh, 0FAh,  00h,  00h,  7Fh, 0FEh,  00h,  00h, 0FFh, 0FFh,  00h
		db	 00h, 0FFh, 0FFh,  00h,  00h,  7Fh, 0FEh,  00h,  00h,  5Fh, 0FAh,  00h
		db	 00h,  0Bh, 0D0h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h
		db	 00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h
		db	 00h,  00h,  00h,  00h,  00h,  2Fh, 0F4h,  00h,  00h, 0FFh, 0FFh,  00h
		db	 03h, 0FFh, 0FFh, 0C0h,  07h, 0FFh, 0FFh, 0E0h,  0Fh, 0FAh,  5Fh, 0F0h
		db	 0Fh, 0F0h,  0Fh, 0F0h,  0Fh, 0F0h,  0Fh, 0F0h,  0Fh, 0FAh,  5Fh, 0F0h
		db	 07h, 0FFh, 0FFh, 0E0h,  03h, 0FFh, 0FFh, 0C0h,  00h, 0FFh, 0FFh,  00h
		db	 00h,  2Fh, 0F4h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h,  00h
		db	 00h,  2Fh, 0F4h,  00h,  01h,  7Fh, 0FEh,  80h,  07h, 0FFh, 0FFh, 0E0h
		db	 0Fh, 0FFh, 0FFh, 0F0h,  3Fh, 0F4h,  2Fh, 0FCh,  7Fh, 0A0h,  05h, 0FEh
		db	 7Fh,  80h,  01h, 0FEh, 0FFh,  00h,  00h, 0FFh, 0FFh,  00h,  00h, 0FFh
		db	 7Fh,  80h,  01h, 0FEh,  7Fh, 0A0h,  05h, 0FEh,  3Fh, 0F4h,  2Fh, 0FCh
		db	 0Fh, 0FFh, 0FFh, 0F0h,  07h, 0FFh, 0FFh, 0E0h,  01h,  7Fh, 0FEh,  80h
		db	 00h,  2Fh, 0F4h,  00h,  00h,  2Fh, 0F4h,  00h,  01h,  7Fh, 0FEh,  80h
		db	 07h, 0D0h,  0Bh, 0E0h,  0Fh,  00h,  00h, 0F0h,  3Ch,  00h,  00h,  3Ch
		db	 78h,  00h,  00h,  1Eh,  70h,  00h,  00h,  0Eh, 0F0h,  00h,  00h,  0Fh
		db	0F0h,  00h,  00h,  0Fh,  70h,  00h,  00h,  0Eh,  78h,  00h,  00h,  1Eh
		db	 3Ch,  00h,  00h,  3Ch,  0Fh,  00h,  00h, 0F0h,  07h, 0D0h,  0Bh, 0E0h
		db	 01h,  7Fh, 0FEh,  80h,  00h,  2Fh, 0F4h,  00h, 0BFh,  14h,  50h		; 0x099F..0x09A9
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
		jmp	short loc_100

; sprite_row_render_with_gfx -- alternate entry that first fetches hero gfx
; and sprite positions, then falls into the enemy counter-indexed render loop.

sprite_row_render_with_gfx:
		call	load_sprite_pos
		mov	di,sprite_row_buf
		mov	dl,ds:enemy_counter
		dec	dl
		mov	cx,4

bg_tile_fetch_outer_loop:
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

bg_tile_fetch_inner_loop:
				mov	al,[bx]
				or	al,al			; Zero ?
				js	loc_99			; Jump if sign=1
				xor	al,al			; Zero register

loc_99:
				mov	[di],al
				inc	bx
				inc	di
				loop	bg_tile_fetch_inner_loop		; Loop if cx > 0

			inc	dl
			pop	cx
			loop	bg_tile_fetch_outer_loop		; Loop if cx > 0

loc_100:
		mov	al,byte ptr ds:[84h]
		xor	ah,ah			; Zero register
		mov	cx,0A00h
		mul	cx			; dx:ax = reg * ax
		mov	cl,byte ptr ds:[83h]
		xor	ch,ch			; Zero register
		add	cx,cx
		add	cx,cx
		add	cx,cx
		add	ax,cx
		add	ax,11B0h
		mov	ds:scroll_vga_ofs,ax
		mov	byte ptr ds:col_idx,0
		mov	si,5014h
		mov	di,sprite_row_buf
		mov	cx,3

frame_row_outer_loop:
			push	cx
			mov	cx,3

frame_row_inner_loop:
				push	cx
				mov	ax,3A88h
				push	ax
				mov	al,[di]
				or	al,[di+1]
				or	al,[di+4]
				or	al,[di+5]
				jnz	loc_103			; Jump if not zero
				jmp	loc_140

loc_103:
				test	byte ptr [di],0FFh
				jz	loc_104			; Jump if zero
				mov	al,[di]
				push	si
				call	sprite_src_setup
				inc	si
				inc	si
				inc	si
				mov	al,[si]
				pop	si
				jmp	loc_142

loc_104:
				test	byte ptr [di+1],0FFh
				jz	loc_105			; Jump if zero
				mov	al,[di+1]
				push	si
				call	sprite_src_setup
				inc	si
				inc	si
				mov	al,[si]
				pop	si
				jmp	loc_142

loc_105:
				test	byte ptr [di+4],0FFh
				jz	loc_106			; Jump if zero
				mov	al,[di+4]
				push	si
				call	sprite_src_setup
				inc	si
				mov	al,[si]
				pop	si
				jmp	loc_142

loc_106:
				mov	al,[di+5]
				push	si
				call	sprite_src_setup
				mov	cl,[si]
				pop	si
				mov	[si],al
				mov	al,cl
				jmp	loc_142

; Fall-through target from loc_140's jmp path; continues the inner column loop.

cell_iter_next:
				inc	byte ptr ds:col_idx
				inc	di
				inc	si
				pop	cx
				loop	frame_row_inner_loop		; Loop if cx > 0

			pop	cx
			inc	di
			loop	frame_row_outer_loop		; Loop if cx > 0

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
		jz	loc_107			; Jump if zero
		jmp	loc_117

loc_107:
		mov	cl,0FFh
		mov	si,6117h
		test	byte ptr ds:[0C2h],1
		jz	loc_108			; Jump if zero
		xor	cl,cl			; Zero register
		mov	si,61B9h

loc_108:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_112			; Jump if zero
		inc	cl
		jnz	loc_109			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	shield_state_get
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,62C7h
		jmp	short loc_115

loc_109:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_110			; Jump if not zero
		add	ax,24h
		jmp	short loc_111

loc_110:
		dec	dl
		jnz	loc_111			; Jump if not zero
		mov	ax,63h

loc_111:
		add	si,ax
		jmp	short loc_115

loc_112:
		call	shield_state_get
		or	al,al			; Zero ?
		jz	loc_114			; Jump if zero
		dec	al
		mov	cl,al
		test	byte ptr ds:[0C2h],1
		jnz	loc_114			; Jump if not zero
		mov	ax,6Ch
		mov	dl,ds:flag_shield
		and	dl,9
		xor	dh,dh			; Zero register
		add	ax,dx
		or	cl,cl			; Zero ?
		jz	loc_113			; Jump if zero
		add	ax,1Bh

loc_113:
		add	si,ax
		jmp	short loc_115

loc_114:
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_117			; Jump if not zero
		mov	al,byte ptr ds:[0E7h]
		cmp	al,80h
		je	loc_117			; Jump if equal
		add	al,2
		and	al,3
		test	al,1
		jnz	loc_117			; Jump if not zero
		mov	cl,9
		mul	cl			; ax = reg * al
		add	si,ax
		jmp	short loc_116

loc_115:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_116			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		call	frame_row_driver
		jmp	short loc_117

loc_116:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	frame_row_driver

loc_117:
		mov	si,610Eh
		test	byte ptr ds:flag_riding,0FFh
		jnz	loc_122			; Jump if not zero
		mov	si,60EAh
		test	byte ptr ds:flag_climbing,0FFh
		jnz	loc_120			; Jump if not zero
		mov	si,6075h
		test	byte ptr ds:[0C2h],1
		jnz	loc_118			; Jump if not zero
		mov	si,game_data_base

loc_118:
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_119			; Jump if zero
		add	si,5Ah
		jmp	short loc_120

loc_119:
		mov	ax,2Dh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_121			; Jump if not zero
		mov	ax,3Fh
		test	byte ptr ds:equip_byte,80h
		jnz	loc_121			; Jump if not zero
		mov	cl,ds:shield_sel
		mov	ax,48h
		dec	cl
		jz	loc_121			; Jump if zero
		mov	ax,51h
		dec	cl
		jz	loc_121			; Jump if zero
		mov	ax,36h
		cmp	byte ptr ds:equip_byte,7Fh
		je	loc_121			; Jump if equal
		mov	ax,24h
		cmp	byte ptr ds:[0E7h],80h
		je	loc_121			; Jump if equal

loc_120:
		mov	al,byte ptr ds:[0E7h]
		and	al,3
		mov	cl,9
		mul	cl			; ax = reg * al

loc_121:
		add	si,ax

loc_122:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		call	frame_row_driver
		test	byte ptr ds:[0E8h],0FFh
		jz	loc_123			; Jump if zero
		retn

loc_123:
		mov	cl,0FFh
		mov	si,61B9h
		test	byte ptr ds:[0C2h],1
		jnz	loc_124			; Jump if not zero
		xor	cl,cl			; Zero register
		mov	si,6117h

loc_124:
		mov	al,ds:flag_climbing
		or	al,ds:flag_riding
		jz	loc_126			; Jump if zero
		call	shield_state_get
		or	al,al			; Zero ?
		jnz	loc_125			; Jump if not zero
		retn

loc_125:
		dec	al
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		and	al,1Bh
		add	al,7Eh			; '~'
		xor	ah,ah			; Zero register
		jmp	loc_133

loc_126:
		test	byte ptr ds:flag_hero_state,0FFh
		jz	loc_130			; Jump if zero
		inc	cl
		jnz	loc_127			; Jump if not zero
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		push	ax
		call	shield_state_get
		mov	cl,24h			; '$'
		mul	cl			; ax = reg * al
		pop	si
		add	si,ax
		add	si,625Bh
		jmp	short loc_134

loc_127:
		mov	al,ds:hero_frame
		shr	al,1			; Shift w/zeros fill
		mov	cl,9
		mul	cl			; ax = reg * al
		add	ax,24h
		mov	dl,ds:weapon_state
		dec	dl
		jnz	loc_128			; Jump if not zero
		add	ax,24h
		jmp	short loc_129

loc_128:
		dec	dl
		jnz	loc_129			; Jump if not zero
		mov	ax,63h

loc_129:
		add	si,ax
		jmp	short loc_134

loc_130:
		test	byte ptr ds:[0C2h],1
		jz	loc_132			; Jump if zero
		call	shield_state_get
		or	al,al			; Zero ?
		jz	loc_132			; Jump if zero
		dec	al
		mov	cl,al
		mov	al,ds:flag_shield
		and	al,9
		add	al,6Ch			; 'l'
		xor	ah,ah			; Zero register
		or	cl,cl			; Zero ?
		jz	loc_131			; Jump if zero
		add	ax,1Bh

loc_131:
		add	si,ax
		jmp	short loc_134

loc_132:
		mov	ax,1Bh
		test	byte ptr ds:flag_shield,0FFh
		jnz	loc_133			; Jump if not zero
		mov	cl,byte ptr ds:[0E7h]
		cmp	cl,80h
		je	loc_133			; Jump if equal
		and	cl,3
		mov	al,9
		mul	cl			; ax = reg * al

loc_133:
		add	si,ax

loc_134:
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_135			; Jump if zero
		mov	cx,6
		mov	byte ptr ds:col_idx,3
		jmp	short fade_dispatch_loop

loc_135:
		mov	cx,9
		mov	byte ptr ds:col_idx,0
		jmp	short fade_dispatch_loop

frame_row_driver		proc	near

fade_dispatch_loop:
			push	cx
			mov	al,es:[si]
			or	al,al			; Zero ?
			jz	loc_137			; Jump if zero
			push	es
			push	ds
			push	si
			push	di
			mov	ch,20h			; ' '
			mul	ch			; ax = reg * al
			mov	si,ax
			add	si,mca_sprite_src
			shr	ax,1			; Shift w/zeros fill
			shr	ax,1			; Shift w/zeros fill
			mov	bp,ax
			add	bp,mca_pattern_base
			mov	ds,cs:game_seg
			mov	di,dx
			push	cs
			pop	es
			mov	al,cs:col_idx
			mov	cl,40h			; '@'
			mul	cl			; ax = reg * al
			add	ax,511Dh
			mov	di,ax
			call	mca_plane_3_iter
			pop	di
			pop	si
			pop	ds
			pop	es

loc_137:
			inc	si
			inc	byte ptr ds:col_idx
			pop	cx
			loop	fade_dispatch_loop		; Loop if cx > 0

		retn

frame_row_driver		endp

shield_state_get		proc	near
		mov	al,byte ptr ds:[93h]
		or	al,al			; Zero ?
		jnz	loc_138			; Jump if not zero
		retn

loc_138:
		cmp	al,4
		mov	al,1
		jnc	loc_139			; Jump if carry=0
		retn

loc_139:
		mov	al,2
		retn

shield_state_get		endp

loc_140:
		mov	al,[si]
		push	ds
		push	si
		push	di
		push	ax
		mov	ds,cs:game_seg
		push	cs
		pop	es
		mov	al,cs:col_idx
		mov	cl,40h			; '@'
		mul	cl			; ax = reg * al
		add	ax,511Dh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_141			; Jump if zero
		dec	al
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		call	mca_sprite_render_solid
		pop	di
		pop	si
		pop	ds
		retn

loc_141:
		call	mca_sprite_clear_cell
		pop	di
		pop	si
		pop	ds
		retn

loc_142:
		push	ds
		push	si
		push	di
		mov	cl,al
		mov	al,[si]
		or	al,al			; Zero ?
		jns	loc_143			; Jump if not sign
		call	sprite_get_value

loc_143:
		push	ax
		mov	bl,ds:palette_byte
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	dx,cs:hero_gfx_tbl[bx]
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
		mov	cl,40h			; '@'
		mul	cl			; ax = reg * al
		add	ax,511Dh
		mov	di,ax
		pop	ax
		or	al,al			; Zero ?
		jz	loc_144			; Jump if zero
		mov	cl,al
		call	mca_sprite_blit_ex
		pop	di
		pop	si
		pop	ds
		retn

loc_144:
		call	mca_plane_copy_16rows
		pop	di
		pop	si
		pop	ds
		retn

load_sprite_pos		proc	near
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
			loop	sprite_pos_copy_loop		; Loop if cx > 0

		retn

load_sprite_pos		endp

frame_row_dispatcher		proc	near
		mov	al,ds:row_counter
		neg	al
		add	al,12h
		mov	cl,al
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_147			; Jump if not zero
		mov	al,byte ptr ds:[84h]
		sub	al,2
		cmp	al,cl
		jne	loc_ret_146		; Jump if not equal
		call	hero_sprite_col_blit

loc_ret_146:
		retn

loc_147:
		mov	al,byte ptr ds:[84h]
		sub	al,5
		cmp	cl,al
		jae	loc_148			; Jump if above or =
		retn

loc_148:
		jnz	loc_149			; Jump if not zero
		call	scroll_restore
		jmp	loc_175

loc_149:
		add	al,0Ah
		cmp	al,cl
		je	loc_150			; Jump if equal
		retn

loc_150:
		jmp	loc_165

; scroll_phase_update -- advance scroll phase, computes scroll_src_ofs and
; scroll_gfx_ptr from the current scroll phase. Called indirectly.

scroll_phase_update:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_151			; Jump if not zero
		retn

loc_151:
		push	es
		push	si
		push	di
		push	bx
		mov	es,cs:game_seg
		inc	byte ptr ds:scroll_step
		mov	al,ds:scroll_phase
		or	al,al			; Zero ?
		jz	loc_155			; Jump if zero
		dec	al
		jz	loc_153			; Jump if zero
		cmp	byte ptr ds:scroll_step,5
		jb	loc_152			; Jump if below
		jmp	loc_159

loc_152:
		xor	cl,cl			; Zero register
		mov	si,0B16Eh
		mov	word ptr ds:scroll_delta,0FF01h
		mov	dx,9F8h
		test	byte ptr ds:[0C2h],1
		jnz	loc_157			; Jump if not zero
		mov	si,0B0BEh
		mov	word ptr ds:scroll_delta,1
		mov	dx,0A00h
		jmp	short loc_157

loc_153:
		cmp	byte ptr ds:scroll_step,5
		jb	loc_154			; Jump if below
		jmp	loc_159

loc_154:
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B19Eh
		mov	si,0B12Eh
		test	byte ptr ds:[0C2h],1
		jnz	loc_156			; Jump if not zero
		mov	di,0B18Ah
		mov	si,0B07Eh
		jmp	short loc_156

loc_155:
		cmp	byte ptr ds:scroll_step,7
		jae	loc_159			; Jump if above or =
		mov	bl,ds:scroll_step
		dec	bl
		xor	bh,bh			; Zero register
		mov	cl,bl
		add	bx,bx
		mov	di,0B192h
		mov	si,0B0CEh
		test	byte ptr ds:[0C2h],1
		jnz	loc_156			; Jump if not zero
		mov	di,mca_plane_alt
		mov	si,0B01Eh

loc_156:
		mov	bx,es:[bx+di]
		mov	ds:scroll_delta,bx
		mov	al,bl
		cbw				; Convrt byte to word
		mov	dx,0A00h
		imul	dx			; dx:ax = reg * ax
		mov	dx,ax
		mov	al,bh
		cbw				; Convrt byte to word
		add	ax,ax
		add	ax,ax
		add	ax,ax
		add	dx,ax

loc_157:
		mov	di,ds:scroll_vga_ofs
		add	di,dx
		test	byte ptr ds:flag_shield,0FFh
		jz	loc_158			; Jump if zero
		add	di,0A00h

loc_158:
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
		jmp	loc_165

loc_159:
		mov	byte ptr ds:scroll_active,0
		mov	byte ptr ds:scroll_step,0
		pop	bx
		pop	di
		pop	si
		pop	es
		retn

scroll_restore:
		test	byte ptr ds:restore_pending,0FFh
		jnz	loc_160			; Jump if not zero
		retn

loc_160:
		push	es
		push	di
		push	si
		push	bx
		call	scroll_buf_save
		pop	bx
		pop	si
		pop	di
		pop	es
		mov	byte ptr ds:restore_pending,0
		retn

scroll_buf_restore:
		push	ds
		mov	si,cs:scroll_src_ofs
		mov	ax,0A000h
		mov	ds,ax
		mov	es,ax
		mov	di,mca_temp_buf_b
		mov	cx,20h

scroll_buf_restore_loop:
			push	cx
			mov	cx,10h
			rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
			add	si,120h
			pop	cx
			loop	scroll_buf_restore_loop		; Loop if cx > 0

		pop	ds
		retn

scroll_buf_save:
		push	ds
		mov	di,cs:scroll_src_ofs
		mov	ax,0A000h
		mov	es,ax
		mov	ds,ax
		mov	si,mca_temp_buf_b
		mov	cx,20h

scroll_buf_save_loop:
			push	cx
			mov	cx,10h
			rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
			add	di,120h
			pop	cx
			loop	scroll_buf_save_loop		; Loop if cx > 0

		pop	ds
		retn

scroll_clear_cache:
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

scroll_cache_outer_loop:
			push	cx
			mov	cx,4

scroll_cache_inner_loop:
				push	cx
				mov	bl,[si]
				inc	si
				and	bl,7Fh
				xor	bh,bh			; Zero register
				add	bx,bx
				mov	word ptr ds:sprite_cache_tbl[bx],0
				pop	cx
				loop	scroll_cache_inner_loop		; Loop if cx > 0

			add	si,20h
			call	si_wrap_hi
			pop	cx
			loop	scroll_cache_outer_loop		; Loop if cx > 0

		retn

loc_165:
		test	byte ptr ds:scroll_active,0FFh
		jnz	loc_166			; Jump if not zero
		retn

loc_166:
		mov	byte ptr ds:restore_pending,0FFh
		push	es
		push	ds
		push	di
		push	si
		push	bx
		call	scroll_clear_cache
		call	scroll_buf_restore
		xor	bx,bx			; Zero register
		mov	bl,byte ptr cs:[92h]
		dec	bl
		add	bx,bx
		mov	ax,cs:color_map_tbl[bx]
		mov	cs:rle_tmp_b,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:scroll_src_ofs
		mov	si,cs:scroll_gfx_ptr
		mov	cx,4

scroll_render_outer_loop:
			push	cx
			push	di
			mov	cx,4

scroll_render_mid_loop:
				push	cx
				lodsb				; String [si] to al
				cmp	al,0FFh
				jne	loc_169			; Jump if not equal
				add	di,0A00h
				jmp	short loc_171

loc_169:
				push	si
				xor	ah,ah			; Zero register
				add	ax,ax
				add	ax,ax
				add	ax,ax
				add	ax,ax
				mov	si,ax
				add	si,ds:mca_sprite_src_b
				mov	cx,8

scroll_render_8rows_loop:
				push	cx
				lodsw				; String [si] to ax
				xchg	ah,al
				call	mca_expand_nibble
				not	bp
				and	es:[di],bp
				or	es:[di],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+2],bp
				or	es:[di+2],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+4],bp
				or	es:[di+4],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+6],bp
				or	es:[di+6],dx
				add	di,140h
				pop	cx
				loop	scroll_render_8rows_loop		; Loop if cx > 0

				pop	si

loc_171:
				pop	cx
				loop	scroll_render_mid_loop		; Loop if cx > 0

			pop	di
			add	di,8
			pop	cx
			loop	scroll_render_outer_loop		; Loop if cx > 0

		pop	bx
		pop	si
		pop	di
		pop	ds
		pop	es
		retn
; 11-byte data/alignment table just before mca_expand_nibble entry.
; Mis-decoded as "add/push es" etc; bytes are unreferenced padding/fixup.
		db	 01h, 09h, 04h, 24h, 03h, 1Bh	; 0x108A padding/alignment
		db	 01h, 09h, 04h, 24h, 06h	; 0x1090 padding/alignment

		db	36h			; 0x1095 byte preceding mca_expand_nibble (SS: prefix)

mca_expand_nibble:
		xor	bp,bp			; Zero register
		xor	dx,dx			; Zero register
		xor	bl,bl			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jz	loc_172			; Jump if zero
		or	bp,0FFh
		mov	dl,byte ptr cs:rle_tmp_b+1
		cmp	bl,3
		je	loc_172			; Jump if equal
		mov	dl,cs:rle_tmp_b

loc_172:
		xor	bl,bl			; Zero register
		add	ax,ax
		adc	bl,bl
		add	ax,ax
		adc	bl,bl
		jnz	loc_173			; Jump if not zero
		retn

loc_173:
		or	bp,0FF00h
		mov	dh,byte ptr cs:rle_tmp_b+1
		cmp	bl,3
		jne	loc_174			; Jump if not equal
		retn

loc_174:
		mov	dh,cs:rle_tmp_b
		retn
; hero_sprite_col_blit_pos -- alt entry: compute scroll_vga_ofs from BX/BH/AX
; then fall into loc_177 to do the actual column blit.

hero_sprite_col_blit_pos:
		xor	ax,ax			; Zero register
		mov	al,bh
		mov	bh,ah
		push	ax
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	di
		add	di,di
		add	di,di
		add	di,ax
		mov	ds:scroll_vga_ofs,di
		jmp	short loc_177

hero_sprite_col_blit:

loc_175:
		test	byte ptr ds:redraw_lock,0FFh
		jz	loc_176			; Jump if zero
		retn

loc_176:
		mov	byte ptr ds:redraw_lock,0FFh

loc_177:
		push	es
		push	ds
		push	si
		push	di
		push	bx
		mov	ax,0A000h
		mov	es,ax
		mov	si,sprite_tmp_buf
		mov	di,cs:scroll_vga_ofs
		mov	cx,3

hero_col_outer_loop:
			push	cx
			mov	cx,3

hero_col_inner_loop:
				push	cx
				push	di
				call	mca_blit_2bytes_8rows
				pop	di
				add	di,8
				pop	cx
				loop	hero_col_inner_loop		; Loop if cx > 0

			add	di,9E8h
			pop	cx
			loop	hero_col_outer_loop		; Loop if cx > 0

		pop	bx
		pop	di
		pop	si
		pop	ds
		pop	es
		retn

frame_row_dispatcher		endp

; mca_sprite_render_xor -- sprite render with XOR/combine. Called indirectly.
; Reads 3 bytes per cell, writes 4 bytes per row, skips zero bytes (preserves
; background under transparent pixels).

mca_sprite_render_xor:
		push	ds
		push	si
		dec	al
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8030h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		add	di,di
		mov	cx,8

sprite_xor_outer_loop:
			push	cx
			mov	cx,2

sprite_xor_inner_loop:
				lodsw				; String [si] to ax
				mov	dx,ax
				lodsb				; String [si] to al
				mov	bl,al
				mov	bh,dl
				shr	dx,1			; Shift w/zeros fill
				shr	dx,1			; Shift w/zeros fill
				or	dh,dh			; Zero ?
				jz	loc_182			; Jump if zero
				mov	es:[di],dh

loc_182:
				shr	dl,1			; Shift w/zeros fill
				shr	dl,1			; Shift w/zeros fill
				or	dl,dl			; Zero ?
				jz	loc_183			; Jump if zero
				mov	es:[di+1],dl

loc_183:
				add	bx,bx
				add	bx,bx
				and	bh,3Fh			; '?'
				jz	loc_184			; Jump if zero
				mov	es:[di+2],bh

loc_184:
				and	al,3Fh			; '?'
				jz	loc_185			; Jump if zero
				mov	es:[di+3],al

loc_185:
				add	di,4
				loop	sprite_xor_inner_loop		; Loop if cx > 0

			add	di,138h
			pop	cx
			loop	sprite_xor_outer_loop		; Loop if cx > 0

		pop	si
		pop	ds
		retn

; anim_refresh_all -- full 8-pass animation refresh loop (parallels EGA fn).
; Iterates over all sprite entries 8 times, applying fade/blit per pass.

anim_refresh_all:
		mov	byte ptr ds:restore_pending,0
		mov	ax,0A000h
		mov	es,ax
		mov	byte ptr ds:anim_phase,8

loc_186:
			mov	word ptr ds:vga_row_ptr,11B0h
			mov	byte ptr ds:frame_timer,0
			mov	si,ds:sprite_data_ptr
			mov	di,sprite_buf
			mov	cx,12h

anim_refresh_outer_loop:
				push	cx
				add	si,4
				xor	bx,bx			; Zero register
				mov	cx,1Ch

anim_refresh_inner_loop:
				push	cx
				lodsb				; String [si] to al
				call	mca_tile_half_blit
				inc	di
				inc	bl
				pop	cx
				loop	anim_refresh_inner_loop		; Loop if cx > 0

				add	si,4
				call	si_wrap_hi
				add	word ptr ds:vga_row_ptr,0A00h
				pop	cx
				loop	anim_refresh_outer_loop		; Loop if cx > 0

loc_189:
				cmp	byte ptr ds:frame_timer,10h
				jb	loc_189			; Jump if below
			dec	byte ptr ds:anim_phase
			jnz	loc_186			; Jump if not zero
		retn

mca_tile_half_blit		proc	near
		cmp	byte ptr [di],0FFh
		jne	loc_190			; Jump if not equal
		retn

loc_190:
		cmp	byte ptr [di],0FCh
		jne	loc_191			; Jump if not equal
		retn

loc_191:
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
		xor	ax,0FF00h
		mov	ds:rle_mask,ax
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	bx,ds:vga_row_ptr
		mov	di,bx
		pop	ax
		test	al,0FFh
		jnz	loc_192			; Jump if not zero
		jmp	loc_194

loc_192:
		dec	al
		mov	cl,30h			; '0'
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
		call	mca_tile_addr_calc
		call	mca_tile_half_blit_rows
		pop	di
		pop	si
		mov	al,cs:anim_phase
		call	mca_tile_addr_calc
		add	di,4
		add	si,3
		call	mca_tile_half_blit_rows
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

mca_tile_half_blit_rows:
		mov	cx,2

tile_half_blit_loop:
			push	cx
			lodsw				; String [si] to ax
			mov	dx,ax
			lodsb				; String [si] to al
			mov	bl,al
			mov	bh,dl
			shr	dx,1			; Shift w/zeros fill
			shr	dx,1			; Shift w/zeros fill
			shr	dl,1			; Shift w/zeros fill
			shr	dl,1			; Shift w/zeros fill
			add	bx,bx
			add	bx,bx
			and	bh,3Fh			; '?'
			and	al,3Fh			; '?'
			mov	bl,al
			xchg	dh,dl
			xchg	bh,bl
			mov	ax,cs:rle_mask
			not	ax
			and	es:[di],ax
			and	es:[di+2],ax
			not	ax
			and	ax,dx
			or	es:[di],ax
			mov	ax,cs:rle_mask
			and	ax,bx
			or	es:[di+2],ax
			add	di,500h
			add	si,15h
			pop	cx
			loop	tile_half_blit_loop		; Loop if cx > 0

		retn

loc_194:
		push	di
		mov	al,cs:anim_phase
		and	al,3
		neg	al
		add	al,3
		call	mca_tile_addr_calc
		call	mca_tile_half_clear
		pop	di
		mov	al,cs:anim_phase
		call	mca_tile_addr_calc
		add	di,4
		call	mca_tile_half_clear
		pop	bx
		pop	si
		pop	di
		pop	ds
		retn

mca_tile_half_blit		endp

mca_tile_half_clear		proc	near
		mov	ax,cs:rle_mask
		not	ax
		and	es:[di],ax
		and	es:[di+2],ax
		add	di,mca_2row_stride
		and	es:[di],ax
		and	es:[di+2],ax
		retn

mca_tile_half_clear		endp

mca_tile_addr_calc		proc	near
		and	al,3
		xor	ah,ah			; Zero register
		push	ax
		mov	bx,6
		mul	bl			; ax = reg * al
		add	si,ax
		pop	ax
		mov	bx,140h
		mul	bx			; dx:ax = reg * ax
		add	di,ax
		retn

mca_tile_addr_calc		endp

; mca_color_fade_init -- inline proc body (no proc label in Sourcer output).
; Parallels ega_color_fade_init. Reads color coords from DS:[0x83]/[0x84],
; multiplies by 8 to get MCGA palette offsets, stores to cur_color_pair, then
; calls fade_xor_block and fade_gradient_rect twice at different phases.

mca_color_fade_init:
		mov	al,byte ptr ds:[83h]	; X coord (game_seg global)
		add	al,al			; X * 2
		add	al,al			; X * 4
		add	al,al			; X * 8 -> MCGA palette X offset
		mov	ah,byte ptr ds:[84h]	; Y coord (game_seg global)
		add	ah,ah			; Y * 2
		add	ah,ah			; Y * 4
		add	ah,ah			; Y * 8 -> MCGA palette Y offset
		mov	ds:cur_color_pair,al
		mov	byte ptr ds:cur_color_pair+1,ah
		call	fade_xor_block
		mov	byte ptr ds:anim_phase,36h	; '6'
		call	fade_gradient_rect
		mov	byte ptr ds:anim_phase,0
		call	fade_gradient_rect
		jmp	loc_212

fade_gradient_rect		proc	near
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

gradient_9pass_loop:
			push	cx
			push	dx
			push	bx
			call	fade_gradient_line
			pop	bx
			pop	dx
			sub	bl,0Ch
			jnc	loc_196			; Jump if carry=0
			xor	bl,bl			; Zero register

loc_196:
			sub	bh,0Ch
			jnc	loc_197			; Jump if carry=0
			xor	bh,bh			; Zero register

loc_197:
			add	dl,0Ch
			jnc	loc_198			; Jump if carry=0
			mov	dl,0FFh

loc_198:
			add	dh,0Ch
			jnc	loc_199			; Jump if carry=0
			mov	dh,0FFh

loc_199:
			push	dx
			push	bx
			call	anim_frame_wait
			pop	bx
			pop	dx
			pop	cx
			loop	gradient_9pass_loop		; Loop if cx > 0

		retn

fade_gradient_rect		endp

fade_gradient_line		proc	near
		mov	ax,0A000h
		mov	es,ax
		push	dx
		push	bx
		mov	dh,bh
		call	fade_horizontal_line
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	bh,dh
		call	fade_horizontal_line
		pop	bx
		pop	dx
		push	dx
		push	bx
		mov	dl,bl
		call	fade_vertical_line
		pop	bx
		pop	dx
		mov	bl,dl

fade_vertical_line:
		cmp	dh,bh
		jae	loc_200			; Jump if above or =
		xchg	dx,bx

loc_200:
		or	bl,bl			; Zero ?
		jnz	loc_201			; Jump if not zero
		retn

loc_201:
		cmp	bl,0DFh
		jb	loc_202			; Jump if below
		retn

loc_202:
		or	bh,bh			; Zero ?
		jnz	loc_203			; Jump if not zero
		mov	bh,1

loc_203:
		cmp	dh,8Fh
		jb	loc_204			; Jump if below
		mov	dh,8Eh

loc_204:
		mov	al,dh
		sub	al,bh
		inc	al
		push	ax
		mov	al,bh
		call	mca_vga_row_calc
		mov	al,bl
		xor	ah,ah			; Zero register
		add	di,ax
		pop	cx
		xor	ch,ch			; Zero register
		mov	ah,ds:anim_phase

vert_line_fill_loop:
			mov	es:[di],ah
			add	di,140h
			loop	vert_line_fill_loop		; Loop if cx > 0

		retn

fade_gradient_line		endp

fade_horizontal_line		proc	near
		cmp	dl,bl
		jae	loc_206			; Jump if above or =
		xchg	dx,bx

loc_206:
		or	bh,bh			; Zero ?
		jnz	loc_207			; Jump if not zero
		retn

loc_207:
		cmp	bh,8Fh
		jb	loc_208			; Jump if below
		retn

loc_208:
		or	bl,bl			; Zero ?
		jnz	loc_209			; Jump if not zero
		mov	bl,1

loc_209:
		cmp	dl,0DFh
		jb	loc_210			; Jump if below
		mov	dl,0DEh

loc_210:
		mov	al,bh
		call	mca_vga_row_calc
		mov	al,bl
		xor	ah,ah			; Zero register
		add	di,ax
		mov	ah,dl
		sub	ah,al
		mov	cl,ah
		xor	ch,ch			; Zero register
		mov	al,ds:anim_phase
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		retn

fade_horizontal_line		endp

mca_vga_row_calc		proc	near
		push	dx
		xor	ah,ah			; Zero register
		mov	di,140h
		mul	di			; dx:ax = reg * ax
		add	ax,11B0h
		mov	di,ax
		pop	dx
		retn

mca_vga_row_calc		endp

anim_frame_wait		proc	near
		mov	cl,ds:anim_speed
		shr	cl,1			; Shift w/zeros fill
		inc	cl
		mov	al,1
		mul	cl			; ax = reg * al

loc_211:
			push	ax
			call	word ptr cs:[110h]
			call	word ptr cs:[112h]
			call	word ptr cs:[114h]
			call	word ptr cs:[116h]
			call	word ptr cs:[118h]
			pop	ax
			cmp	ds:frame_timer,al
			jb	loc_211			; Jump if below
		mov	byte ptr ds:frame_timer,0
		retn

anim_frame_wait		endp

fade_xor_block		proc	near

loc_212:
		mov	ax,0A000h
		mov	es,ax
		mov	di,mca_vga_base_ofs
		mov	cx,8

xor_rect_outer_loop:
			push	cx
			push	di
			mov	cx,12h

xor_rect_mid_loop:
				push	cx
				push	di
				mov	ax,1212h
				mov	cx,70h

xor_rect_inner_loop:
				xor	es:[di],ax
				inc	di
				inc	di
				loop	xor_rect_inner_loop		; Loop if cx > 0

				pop	di
				add	di,0A00h
				pop	cx
				loop	xor_rect_mid_loop		; Loop if cx > 0

			pop	di
			add	di,140h
			pop	cx
			loop	xor_rect_outer_loop		; Loop if cx > 0

		retn

fade_xor_block		endp

; mca_vga_offset_calc -- compute VGA byte offset from packed AL position.
; AL[5:0] = col, AH = row. Returns DI = VGA offset into framebuffer.

mca_vga_offset_calc:
		and	al,3Fh			; '?'
		mov	bl,ah
		xor	ah,ah			; Zero register
		mov	dx,0A00h
		mul	dx			; dx:ax = reg * ax
		sub	bl,4
		xor	bh,bh			; Zero register
		add	bx,bx
		add	bx,bx
		add	bx,bx
		add	ax,bx
		mov	di,ax
		add	di,11B0h
		shr	di,1			; Shift w/zeros fill
		retn

; bg_restore_rect -- restore a 0x480-byte background from a CS+2000h segment
; table entry (indexed by [9Dh] byte). Used to repaint dirty rects behind sprites.

bg_restore_rect:
		mov	bl,byte ptr ds:[9Dh]
		or	bl,bl			; Zero ?
		jz	loc_216			; Jump if zero
		cmp	bl,7
		je	loc_216			; Jump if equal
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	es,cs:game_seg
		mov	ax,cs
		add	ax,2000h
		mov	ds,ax
		mov	si,[bx]
		mov	di,bg_copy_dst
		mov	cx,480h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]

loc_216:
		mov	ds,cs:game_seg
		mov	si,9350h
		retn

si_wrap_hi		proc	near
		cmp	si,0E900h
		jae	loc_217			; Jump if above or =
		retn

loc_217:
		sub	si,900h
		retn

si_wrap_hi		endp

si_wrap_lo		proc	near
		cmp	si,0E000h
		jb	loc_218			; Jump if below
		retn

loc_218:
		add	si,900h
		retn

si_wrap_lo		endp

; draw_ui_tiles -- draw 5 rows x 28 columns of UI tiles at top of screen
; (parallels EGA draw_ui_tiles). Reads tile indices from phase_offset_tbl,
; blits 8-row tile graphics from sprite_gfx_base via mca_expand_nibble.

draw_ui_tiles:
		push	si
		push	ds
		mov	word ptr cs:rle_tmp_b,1210h
		mov	si,phase_offset_tbl
		mov	di,3230h
		mov	ax,0A000h
		mov	es,ax
		mov	cx,5

ui_tile_outer_loop:
			push	cx
			mov	cx,1Ch

ui_tile_mid_loop:
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

ui_tile_blit_loop:
				push	cx
				lodsw				; String [si] to ax
				xchg	ah,al
				call	mca_expand_nibble
				mov	es:[di],dx
				call	mca_expand_nibble
				mov	es:[di+2],dx
				call	mca_expand_nibble
				mov	es:[di+4],dx
				call	mca_expand_nibble
				mov	es:[di+6],dx
				add	di,140h
				pop	cx
				loop	ui_tile_blit_loop		; Loop if cx > 0

				pop	di
				add	di,8
				pop	si
				pop	ds
				pop	cx
				loop	ui_tile_mid_loop		; Loop if cx > 0

			add	di,920h
			pop	cx
			loop	ui_tile_outer_loop		; Loop if cx > 0

		pop	ds
		pop	si
		retn

; ui_tile_index_tbl -- 5 rows x 28 tile indices, indexed by row/col for the
; draw_ui_tiles UI tile grid. Sourcer mixed ASCII quoted encoding with hex
; bytes; kept as-is to preserve exact byte layout.

ui_tile_index_tbl	label	byte
		db	 00h, 01h, 02h, 04h, 07h, 09h	; 0x15AA row 0
		db	 0Dh, 10h, 04h, 15h, 17h, 1Ch
		db	 1Eh, 04h, 07h, 09h, 22h, 02h
		db	 25h, 08h, 02h, 28h, 02h, 2Dh
		db	 31h, 36h, 3Bh, 40h, 00h, 01h
		db	 03h, 06h, 08h, 0Ah, 0Eh, 11h
		db	 06h, 08h, 18h, 0Eh, 1Eh, 04h
		db	8, 0Ah, '#$'
		db	'&', 8, 27h, ')*'
		db	 04h, 32h, 37h, 3Ch, 06h, 00h
		db	 01h, 02h, 05h, 08h, 02h, 0Eh
		db	 12h, 06h, 08h, 19h, 0Eh, 1Eh
		db	 04h, 08h, 02h, 23h, 24h, 26h
		db	 08h, 25h, 29h, 02h, 2Eh, 33h
		db	 38h, 3Dh, 06h, 00h, 01h, 03h
		db	 06h, 08h, 0Bh, 0Eh, 13h, 06h
		db	 08h, 1Ah, 0Eh, 1Fh, 04h, 08h
		db	 0Bh
		db	'#$'
		db	'&', 8, 27h, ')+/49>'
		db	 06h, 00h, 01h, 02h, 04h, 08h
		db	 0Ch, 0Fh, 14h, 04h, 16h, 1Bh
		db	 1Dh
		db	' !', 8, 0Ch, '#$'
		db	'&', 8
		db	 02h, 28h, 2Ch, 30h, 35h, 3Ah, 3Fh

; ui_tile_blit_init -- inline prologue for the ui tile blit loop below.
; Bytes stored as db with mnemonic decode because the entry point is via
; fall-through from the data above.

ui_tile_blit_init:
		db	 06h				; push es
		db	0A2h,0FFh, 4Fh			; mov ds:anim_phase,al  (4FFFh)
		db	0BEh, 3Bh, 47h			; mov si, 473Bh (phase_offset_tbl+1B3h)
		db	0C7h, 06h,0EBh, 4Fh,0B0h, 11h	; mov word ptr ds:vga_row_ptr, 11B0h
		db	0B9h, 12h, 00h			; mov cx, 12h

ui_tile_outer_loop_2:
			push	cx
			mov	cx,1Ch

ui_tile_blit_loop_2:
				push	cx
				lodsb				; String [si] to al
				push	si
				call	bg_tile_blit
				pop	si
				add	word ptr ds:vga_row_ptr,8
				pop	cx
				loop	ui_tile_blit_loop_2		; Loop if cx > 0

			add	word ptr ds:vga_row_ptr,920h
			pop	cx
			loop	ui_tile_outer_loop_2		; Loop if cx > 0

		retn

bg_tile_blit		proc	near
		push	ds
		mov	cl,30h			; '0'
		mul	cl			; ax = reg * al
		add	ax,8000h
		mov	si,ax
		mov	ds,cs:game_seg
		mov	ax,0A000h
		mov	es,ax
		mov	di,cs:vga_row_ptr
		mov	cx,8

ui_tile_blit_8rows:
			push	cx
			call	mca_sprite_2block_render
			add	di,138h
			pop	cx
			loop	ui_tile_blit_8rows		; Loop if cx > 0

		pop	ds
		retn

bg_tile_blit		endp

mca_sprite_2block_render		proc	near
		mov	cx,2

sprite_2block_outer_loop:
			push	cx
			lodsw				; String [si] to ax
			mov	dx,ax
			lodsb				; String [si] to al
			mov	bl,al
			mov	bh,dl
			shr	dx,1			; Shift w/zeros fill
			shr	dx,1			; Shift w/zeros fill
			mov	es:[di],dh
			shr	dl,1			; Shift w/zeros fill
			shr	dl,1			; Shift w/zeros fill
			mov	es:[di+1],dl
			add	bx,bx
			add	bx,bx
			and	bh,3Fh			; '?'
			mov	es:[di+2],bh
			and	al,3Fh			; '?'
			mov	es:[di+3],al
			mov	bl,cs:anim_phase
			xor	bh,bh			; Zero register
			add	bx,bx
			mov	cx,4

sprite_2block_xform_loop:
				mov	al,es:[di]
				or	al,al			; Zero ?
				jz	loc_227			; Jump if zero
				mov	ah,al
				shr	ah,1			; Shift w/zeros fill
				shr	ah,1			; Shift w/zeros fill
				shr	ah,1			; Shift w/zeros fill
				call	word ptr cs:bg_tile_src[bx]	;*
				add	ah,ah
				add	ah,ah
				add	ah,ah
				and	al,7
				or	al,ah
				mov	ah,al
				and	ah,7
				call	word ptr cs:bg_tile_src[bx]	;*
				and	al,38h			; '8'
				or	al,ah

loc_227:
				stosb				; Store al to es:[di]
				loop	sprite_2block_xform_loop		; Loop if cx > 0

			pop	cx
			loop	sprite_2block_outer_loop		; Loop if cx > 0

		retn

mca_sprite_2block_render		endp

; ah_xform_dispatch_tbl -- 5 word pointers to ah_xform mini-procs above.
; Referenced via cs:bg_tile_src[bx] style indexed call in mca_sprite_2block_render.

ah_xform_dispatch_tbl	label	word
		dw	46DEh			; 0x16D8: ah_xform entry 0
		dw	46EFh			; 0x16DA: ah_xform entry 1
		dw	46F8h			; 0x16DC: ah_xform entry 2
		dw	4709h			; 0x16DE: ah_xform entry 3
		dw	4722h			; 0x16E0: ah_xform entry 4

; ah_xform_6to3 -- entry 5 handler inlined after the dispatch table.

ah_xform_6to3:
		cmp	ah,6			; 80 FC 06
		jne	loc_xform_6_ret		; 75 03
		mov	ah,3			; B4 03
		retn				; C3

loc_xform_6_ret:
		cmp	ah,7			; 80 FC 07
		je	loc_228			; 74 01
		retn				; C3

loc_228:
		mov	ah,5
		retn

; ah_xform_4to2 -- entry 0 handler.

ah_xform_4to2:
		cmp	ah,4
		je	loc_229			; Jump if equal
		retn

loc_229:
		mov	ah,2
		retn
; Color xform mini-procs, dispatched via cs:bg_tile_src[bx] (word table).
; Each maps AH -> new AH for a specific color-swap path.

ah_xform_4to5_7to4:
		cmp	ah,4
		jne	loc_230			; Jump if not equal
		mov	ah,5
		retn

loc_230:
		cmp	ah,7
		je	loc_231			; Jump if equal
		retn

loc_231:
		mov	ah,4
		retn

ah_xform_4to3_7to5_6to7:
		cmp	ah,4
		jne	loc_232			; Jump if not equal
		mov	ah,3
		retn

loc_232:
		cmp	ah,7
		jne	loc_233			; Jump if not equal
		mov	ah,5
		retn

loc_233:
		cmp	ah,6
		je	loc_234			; Jump if equal
		retn

loc_234:
		mov	ah,7
		retn

ah_xform_7to5_4to7_6to4:
		cmp	ah,7
		jne	loc_235			; Jump if not equal
		mov	ah,5
		retn

loc_235:
		cmp	ah,4
		jne	loc_236			; Jump if not equal
		mov	ah,7
		retn

loc_236:
		cmp	ah,6
		je	loc_237			; Jump if equal
		retn

loc_237:
		mov	ah,4
		retn
; anim_seq_tbl -- frame index pair data for sprite animation cycles.
; Sourcer mis-decoded the leading 70 bytes as code; they are pure data accessed
; via CS-relative pointer from the animation dispatcher.

anim_seq_tbl	label	byte
		db	 07h,  08h,  09h,  0Ah,  07h,  08h,  0Bh,  0Ch,  07h,  08h,  09h,  0Ah	; 0x173F frame pairs
		db	 19h,  3Dh,  61h,  27h,  1Dh,  1Eh,  1Dh,  1Eh,  1Fh,  20h,  1Fh,  20h
		db	 1Dh,  1Eh,  1Fh,  20h,  0Dh,  0Eh,  0Fh,  10h,  0Fh,  10h,  0Dh,  0Eh
		db	 0Fh,  10h,  17h,  18h,  3Eh,  5Ch,  62h,  26h,  2Ah,  25h,  21h,  22h
		db	 21h,  22h,  23h,  24h,  21h,  22h,  21h,  22h,  09h,  0Ah,  07h,  08h
		db	 07h,  08h,  09h,  0Ah,  07h,  08h,  19h,  54h,  59h,  5Dh		; 0x1784 end of garbled header
		db	 63h, 32h, 2Fh, 2Eh, 1Fh, 20h
		db	 1Fh, 20h, 1Dh, 1Eh, 1Fh, 20h
		db	 1Fh, 20h, 0Fh, 10h, 11h, 12h
		db	 0Fh, 10h, 0Dh, 0Eh, 17h, 18h
		db	'PUZ^df(0#$'
		db	'!"#$'
		db	'!"#$'
		db	 07h, 08h, 0Ah, 0Ch, 07h, 08h
		db	 09h, 0Ah, 1Ah
		db	'4QV[_eg/-'
		db	 1Dh, 1Eh, 1Fh, 20h, 1Dh, 1Eh
		db	 1Fh, 20h, 1Dh, 1Eh, 0Fh, 10h
		db	 0Dh, 0Eh, 0Dh, 0Eh, 17h, 18h
		db	 49h, 4Dh, 52h, 57h, 00h
		db	'`ihjk(&!"+&!"!"'
		db	7
		db	8, 9, 0Ah, 9, 0Ah, 1Bh, 'FJNSX'
		db	 00h, 00h, 00h, 00h, 69h, 6Ch
		db	 31h, 2Dh, 1Fh, 20h, 2Ch, 2Dh
		db	 1Fh, 20h, 1Fh, 20h, 13h, 14h
		db	 13h, 14h, 17h, 18h
		db	 43h, 47h, 4Bh, 4Fh
		db	7 dup (0)
		db	'mno)&!"*%!"'
		db	 15h, 16h, 15h, 16h, 1Ch
		db	 35h, 44h, 48h, 4Ch
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
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 01h, 02h
		db	 01h, 02h, 01h, 02h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 03h, 04h, 03h, 04h
		db	 03h, 04h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 05h, 06h, 05h, 06h, 05h, 06h
		db	 06h, 05h, 05h, 06h, 05h, 06h
; mca_sprite_row_blit -- inline subroutine entry (called indirectly; Sourcer did
; not recognize the entry point). Sets up DS/ES/SI/DI/CX from BX/AX, then falls
; into sprite_blit_row_loop to blit 8 rows via mca_plane_4bit_scan.

mca_sprite_row_blit:
		push	ds				; 1E
		push	ax				; 50
		xor	ax,ax				; 33 C0
		mov	al,bh				; 8A C7
		mov	bh,ah				; 8A FC
		push	ax				; 50
		mov	ax,140h				; B8 40 01
		mul	bx				; F7 E3
		pop	di				; 5F
		add	di,di				; 03 FF
		add	di,di				; 03 FF
		add	di,ax				; 03 F8
		pop	ax				; 58
		mov	cl,20h				; B1 20
		mul	cl				; F6 E1
		add	ax,game_data_base		; 05 00 60
		mov	si,ax				; 8B F0
		mov	ds,cs:[game_seg]		; 2E 8E 1E 2C FF
		mov	ax,mca_seg			; B8 00 A0
		mov	es,ax				; 8E C0
		mov	cx,8				; B9 08 00

sprite_blit_row_loop:
			push	cx
			lodsw				; String [si] to ax
			mov	dx,ax
			call	mca_plane_4bit_scan
			lodsw				; String [si] to ax
			mov	dx,ax
			call	mca_plane_4bit_scan
			add	di,138h
			pop	cx
			loop	sprite_blit_row_loop		; Loop if cx > 0

		pop	ds
		retn

mca_plane_4bit_scan		proc	near
		mov	cx,4

plane_4bit_inner_loop:
			xor	ax,ax			; Zero register
			add	dx,dx
			adc	ax,ax
			add	dx,dx
			adc	ax,ax
			add	ax,ax
			add	dx,dx
			adc	ax,ax
			add	dx,dx
			adc	ax,ax
			stosb				; Store al to es:[di]
			loop	plane_4bit_inner_loop		; Loop if cx > 0

		retn

mca_plane_4bit_scan		endp

; hero_sprite_col_blit -- hero sprite column blit from game_seg via copy_fn_tbl.
; Called indirectly via driver entry function pointer table; Sourcer didn't trace it.

hero_sprite_col_blit_alt:
		push	ds
		mov	word ptr cs:rle_tmp_b,908h
		mov	bl,byte ptr ds:[92h]
		dec	bl
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,ds:copy_fn_tbl[bx]
		mov	di,6C10h
		mov	ax,0A000h
		mov	es,ax
		mov	cx,18h

hero_col_blit_loop:
			lodsw				; String [si] to ax
			xchg	ah,al
			call	mca_expand_nibble
			not	bp
			and	es:[di],bp
			or	es:[di],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+2],bp
			or	es:[di+2],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+4],bp
			or	es:[di+4],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+6],bp
			or	es:[di+6],dx
			lodsw				; String [si] to ax
			xchg	ah,al
			call	mca_expand_nibble
			not	bp
			and	es:[di+8],bp
			or	es:[di+8],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Ah],bp
			or	es:[di+0Ah],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Ch],bp
			or	es:[di+0Ch],dx
			call	mca_expand_nibble
			not	bp
			and	es:[di+0Eh],bp
			or	es:[di+0Eh],dx
			add	di,140h
			loop	hero_col_blit_loop		; Loop if cx > 0

		pop	ds
		retn
; shift_blit_data_a -- first data block for the shift-blit renderer.
; Sourcer mis-decoded the 12-byte header as xor/dec/xchg instructions; they are
; pure data bytes (possibly a mode/shift offset table).

shift_blit_data_a	label	byte
		db	 31h, 4Ah, 31h			; xor [bp+si+31h],cx (3 bytes)
		db	 4Ah				; dec dx
		db	 31h, 4Ah, 91h			; xor [bp+si-6Fh],cx (3 bytes)
		db	 4Ah				; dec dx
		db	 91h, 4Ah			; xchg cx,ax; dec dx
		db	0F1h, 4Ah			; (data table bytes — Sourcer flagged as undecodable)
		db	45 dup (0)
		db	 02h, 00h, 00h, 00h, 06h, 00h
		db	 00h, 00h, 06h, 00h, 00h, 00h
		db	 0Eh, 00h, 00h, 00h, 0Eh, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 0Eh, 00h, 00h, 00h, 1Ch, 00h
		db	 00h, 00h, 0Ch, 00h, 00h, 00h
		db	 1Ch, 00h, 00h, 00h, 1Ch, 00h
		db	 00h, 00h, 1Ch, 00h, 00h, 00h
		db	 1Ch
		db	16 dup (0)
		db	 80h, 00h, 00h, 01h, 80h, 00h
		db	 00h, 03h, 80h, 00h, 00h, 03h
		db	 00h, 00h, 00h, 07h, 80h, 00h
		db	 00h, 07h, 00h, 00h, 00h, 07h
		db	 00h, 00h, 00h, 0Fh, 00h, 00h
		db	 00h, 0Eh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 0Eh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 1Eh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Eh, 00h, 00h, 00h, 1Eh
		db	 00h, 00h, 00h, 1Ch, 00h, 00h
		db	 00h
		db	3Fh
		db	12 dup (0)
		db	 40h, 00h, 00h, 00h,0C0h, 00h
		db	 00h, 01h,0C0h, 00h, 00h, 03h
		db	 80h, 00h, 00h, 03h, 80h, 00h
		db	 00h, 07h, 80h, 00h, 00h, 07h
		db	 00h, 00h, 00h, 07h, 00h, 00h
		db	 00h, 0Fh, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 0Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 0Eh
		db	 00h, 00h, 00h, 1Fh, 00h, 00h
		db	 00h, 1Eh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 00h, 1Fh, 00h, 00h, 00h, 1Fh
		db	 00h, 00h, 00h, 1Eh, 00h, 00h
		db	 03h, 1Ch,0C0h, 00h, 00h,0FFh
		db	 00h, 00h, 1Eh, 0Ah,0C0h, 78h
		db	 10h, 24h, 03h,0B2h, 40h,0F6h
		db	0E2h, 05h,0DDh, 4Bh, 8Bh,0F0h
		db	0BDh, 01h, 00h,0EBh, 0Eh, 24h
		db	 01h, 8Ah,0E0h, 32h,0C0h, 05h
		db	0DDh, 4Ch, 8Bh,0F0h,0BDh, 04h
		db	 00h,0B8h, 40h, 01h, 32h,0EDh
		db	0F7h,0E1h, 03h,0C3h, 8Bh,0F8h
		db	0B8h, 00h,0A0h, 8Eh,0C0h, 8Bh
		db	0CDh

shift_blit_outer_loop:
			push	cx
			push	di
			mov	cx,10h

shift_blit_mid_loop:
				push	cx
				push	di
				mov	cx,2

shift_blit_inner_loop:
				push	cx
				lodsw				; String [si] to ax
				xchg	ah,al
				call	mca_expand_nibble
				not	bp
				and	es:[di],bp
				or	es:[di],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+2],bp
				or	es:[di+2],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+4],bp
				or	es:[di+4],dx
				call	mca_expand_nibble
				not	bp
				and	es:[di+6],bp
				or	es:[di+6],dx
				add	di,8
				pop	cx
				loop	shift_blit_inner_loop		; Loop if cx > 0

				pop	di
				add	di,140h
				pop	cx
				loop	shift_blit_mid_loop		; Loop if cx > 0

			pop	di
			add	di,10h
			pop	cx
			loop	shift_blit_outer_loop		; Loop if cx > 0

		pop	ds
		retn
		db	22 dup (0)
		db	 10h, 00h, 00h, 10h, 60h, 00h
		db	 00h, 07h,0C0h, 00h, 00h, 07h
		db	0C0h, 00h, 00h, 07h,0C0h, 00h
		db	 00h, 0Ch, 10h, 00h, 00h, 10h
		db	 00h
		db	26 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 40h, 04h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 09h, 20h
		db	 00h, 00h, 03h, 80h, 00h, 04h
		db	 57h,0D4h, 80h, 00h, 03h, 80h
		db	 00h, 00h, 09h, 20h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 40h, 04h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 01h
		db	7 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 02h, 80h, 00h, 00h, 83h, 80h
		db	 00h, 00h, 23h, 88h, 00h, 00h
		db	 0Dh,0B0h, 00h, 00h, 0Bh,0E8h
		db	 00h, 96h,0FFh,0FFh,0B9h, 00h
		db	 17h,0E8h, 00h, 00h, 0Bh, 58h
		db	 00h, 00h, 23h, 82h, 00h, 00h
		db	 02h, 80h, 80h, 02h, 01h, 00h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 01h, 00h
		db	8 dup (0)
		db	 10h, 10h, 00h, 00h, 00h, 04h
		db	 00h, 00h, 80h, 00h, 80h, 03h
		db	 00h, 00h, 71h, 0Ch, 00h, 00h
		db	 3Dh, 38h, 00h, 00h, 07h,0F0h
		db	 00h, 00h, 97h,0E5h, 00h, 00h
		db	 0Fh,0F0h, 00h, 00h, 1Fh, 38h
		db	 00h, 00h, 39h, 0Eh, 00h, 00h
		db	0E1h, 01h, 80h, 01h, 00h, 00h
		db	 40h, 04h, 00h, 00h, 08h, 10h
		db	35 dup (0)
		db	 92h, 4Ah,0AAh,0EBh, 00h
		db	34 dup (0)
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	 00h, 01h, 01h, 00h, 00h, 00h
		db	 82h, 00h, 00h, 00h,0ABh, 00h
		db	 00h, 01h, 5Dh, 04h, 24h,0AEh
		db	0EFh,0FFh,0FFh,0FFh,0FFh, 04h
		db	 24h,0ABh,0EFh, 00h, 00h, 01h
		db	 5Dh, 00h, 00h, 00h, 22h, 00h
		db	 00h, 00h, 81h, 00h, 00h, 00h
		db	 01h, 00h, 00h, 00h, 01h, 00h
		db	19 dup (0)
		db	 81h, 00h, 00h, 00h,0C4h, 00h
		db	 00h, 00h,0BCh, 00h, 00h, 00h
		db	0EEh,0EAh, 24h, 20h,0FFh,0FFh
		db	0FFh,0FFh,0FBh,0AAh, 24h, 20h
		db	0FDh, 40h, 00h, 00h,0E6h, 00h
		db	 00h, 00h, 40h, 80h, 00h, 00h
		db	 00h
		db	20h
		db	42 dup (0)
		db	0D7h, 55h, 52h, 49h
		db	60 dup (0)
		db	0A7h, 54h, 90h, 04h, 00h
		db	37 dup (0)
		db	 10h, 00h, 00h, 00h, 04h, 00h
		db	 00h, 00h, 00h, 80h, 00h, 00h
		db	 00h, 71h, 00h, 00h, 00h, 3Dh
		db	 00h, 00h, 00h, 07h, 10h, 04h
		db	 00h, 97h, 00h, 00h, 00h, 0Fh
		db	 00h, 00h, 00h, 1Fh, 00h, 00h
		db	 00h, 39h, 00h, 00h, 00h,0E1h
		db	 00h, 00h, 01h, 00h, 00h, 00h
		db	 04h, 00h, 00h, 00h, 10h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 10h
		db	7 dup (0)
		db	 80h, 00h, 00h, 03h, 00h, 00h
		db	 00h, 0Ch, 00h, 00h, 00h, 38h
		db	 00h, 00h, 00h,0F0h, 00h, 00h
		db	 00h,0E5h, 02h, 00h, 10h,0F0h
		db	 00h, 00h, 00h, 3Ch, 00h, 00h
		db	 00h, 07h, 00h, 00h, 00h, 00h
		db	0C0h, 00h, 00h, 00h, 20h, 00h
		db	 00h, 00h, 04h
		db	38 dup (0)
		db	 20h, 09h, 2Ah,0E5h
		db	28 dup (0)
		db	 51h, 1Eh, 56h, 8Ch,0C8h, 05h
		db	 00h, 30h, 8Eh,0C0h,0B8h, 20h
		db	 00h,0F7h,0E1h, 8Bh,0C8h,0BFh
		db	 00h, 00h,0F3h,0A4h, 5Fh, 07h
		db	 59h, 8Ch,0C8h, 05h, 00h, 30h
		db	 8Eh,0D8h,0BEh, 00h, 00h

bit_shift_outer_loop:
			push	cx
			mov	cx,8

bit_shift_inner_loop:
				push	cx
				lodsw				; String [si] to ax
				xchg	ah,al
				mov	dx,ax
				lodsw				; String [si] to ax
				xchg	ah,al
				mov	cx,ax
				mov	cs:vga_row_ptr,dx
				mov	cs:rle_tmp_a,cx
				or	ax,dx
				mov	bx,ax
				shr	bx,1			; Shift w/zeros fill
				or	ax,bx
				add	bx,bx
				add	bx,bx
				or	ax,bx
				not	ax
				mov	cs:rle_tmp_b,ax
				call	mca_word_shift_4
				mov	ax,dx
				stosw				; Store ax to es:[di]
				call	mca_word_shift_4
				mov	ax,dx
				stosw				; Store ax to es:[di]
				call	mca_bit_pair_scan
				mov	es:[bp],dl
				inc	bp
				pop	cx
				loop	bit_shift_inner_loop		; Loop if cx > 0

			pop	cx
			loop	bit_shift_outer_loop		; Loop if cx > 0

		retn

mca_word_shift_4		proc	near
		mov	cx,4

word_shift_loop:
			rol	word ptr cs:rle_tmp_a,1	; Rotate
			adc	dx,dx
			rol	word ptr cs:vga_row_ptr,1	; Rotate
			adc	dx,dx
			rol	word ptr cs:rle_tmp_a,1	; Rotate
			adc	dx,dx
			rol	word ptr cs:vga_row_ptr,1	; Rotate
			adc	dx,dx
			loop	word_shift_loop		; Loop if cx > 0

		retn

mca_word_shift_4		endp

mca_bit_pair_scan		proc	near
		mov	cx,8

bit_pair_loop:
			xor	al,al			; Zero register
			rol	word ptr cs:rle_tmp_b,1	; Rotate
			adc	al,al
			rol	word ptr cs:rle_tmp_b,1	; Rotate
			adc	al,al
			cmp	al,3
			je	loc_248			; Jump if equal
			xor	al,al			; Zero register

loc_248:
			and	al,1
			add	dl,dl
			or	dl,al
			loop	bit_pair_loop		; Loop if cx > 0

		retn

mca_bit_pair_scan		endp

; mca_pixel_lookup_tbls -- color/pixel mapping lookup tables used by the
; sprite shift/rotate renderers. Sourcer mis-decoded the 12-byte header as
; cbw/dec/test/mov; all bytes are pure data (6 word pointers to sub-tables,
; followed by pixel index remap tables).

mca_pixel_lookup_tbls	label	byte
		db	 98h, 4Fh, 0A8h, 4Fh, 0B8h, 4Fh			; 0x1F12 (6 word ptrs)
		db	0C8h, 4Fh, 0D8h, 4Fh, 0C8h, 4Fh			; 0x1F18 (cont.)
		db	 00h, 01h, 02h, 03h, 08h, 09h, 0Ah, 0Bh		; 0x1F1E 4-bit plane index table
		db	 10h, 11h, 12h, 13h, 18h, 19h, 1Ah, 1Bh
		db	 00h, 02h, 04h, 06h, 10h, 12h, 14h, 16h		; 0x1F2E even-position map
		db	' "$'
		db	'&0246'
		db	0, 1, 4, 5
		db	8, 9, 0Ch, 0Dh, ' !$'
		db	'%(),-'
		db	0, 5, 6, 7
		db	'(-./05678=>?'
		db	0, 6, 5, 7
		db	'0657(.-/8>=?'
		db	0C3h
		db	884 dup (0)

seg_a		ends

		end	start
