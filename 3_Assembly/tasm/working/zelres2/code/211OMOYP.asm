
PAGE  59,132

;==========================================================================
;
;  211OMOYP - Omoya (Souvenir Hut) Dialog Program + End-Demo Trigger
;             (zelres2 chunk 11 / OMOYPRO.BIN)
;
;  Tiny NPC program for the Omoya ("In the Hut") building in town. Loaded
;  at gvar_game_seg:loaded_code_a (0x3000) by town.bin when the player
;  enters the hut. Displays the OMOYA.GRP graphic and a dialog banner.
;
;  The module also contains a secondary entry point (end_demo_transition)
;  reached via the DS dispatch table at drv_return_to_caller (2040h). This
;  entry loads enddemo.bin and the currently-selected mode-specific
;  graphics driver (gdega/gdcga/gdhgc/gdmcga/gdtga) keyed off
;  gvar_gfx_mode (0FF14h), then jumps into the loaded demo.
;
;  Key subsystems:
;    omoya_main           - shop entry: load OMOYA.GRP, init UI, run
;                           script dispatch loop.
;    end_demo_transition  - load enddemo.bin + per-mode gfx driver,
;                           delay, jump into enddemo.
;    draw_hut_banner      - blit 16x17 tile banner from banner_tile_grid.
;
;  Connections:
;    Loads:        OMOYA.GRP   (zelres2 chunk 14h, AL=2 fill_buffer decode)
;                              via cs:[sar_loader_fn] -> game_seg:8000h
;                  enddemo.bin (zelres2 chunk 33h, AL=3 raw load)
;                              via cs:[sar_loader_fn] -> CS:6000h  (end-demo path)
;                  per-mode graphics driver (zelres1 chunks 02/03/04/06):
;                    gdega.bin / gdcga.bin / gdhgc.bin / gdmcga.bin /
;                    gdtga.bin -- selected by gvar_gfx_mode (0FF14h).
;    Calls into:   drv_screen_init_a/b, drv_load_msg_header, drv_ds_copy,
;                  drv_return_to_caller, drv_draw_glyph
;                    (graphics driver dispatch slots cs:[2000h..30xxh])
;                  omoyp_script_6016 (cs:[6016h]) -- script step
;                  cs:[loaded_gfx_dispatch_fn] -- gfx-driver fn after end-demo load
;                  ds:[game_data_base] -- jmp into loaded enddemo (after end_demo)
;    Called by:    106TOWN building dispatch when player enters the Hut
;                    (loaded as loaded_code_a at game_seg:3000h)
;                  drv_return_to_caller DS-dispatch slot (end_demo path,
;                    triggered when game finishes / credits roll begins).
;    Reads/writes: gvar_gfx_mode (DS:0FF14h)  -- selects gfx driver chunk
;                  gvar_timer_word (CS:0FF50h) -- 300-tick wait after load
;                  gvar_game_seg (CS:0FF2Ch)
;                  CS:0FF77h -- demo-active flag (set 0FFh on transition)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc
include  zr2com.inc

; ----------------------------------------------------------------------
; Section 3: Game-segment globals (gvar_*) not in zr2com.inc
; ----------------------------------------------------------------------
gvar_gfx_mode		equ	0FF14h			;* current graphics mode selector byte
gvar_script_skip	equ	0FF1Dh			;* script skip / cancel flag byte
gvar_game_seg		equ	0FF2Ch			;* game data segment selector word

; ----------------------------------------------------------------------
; Section 5: File-internal data table addresses
; ----------------------------------------------------------------------
omoyp_script_6016		equ	6016h			;* script step / read next byte -> al
loaded_gfx_dispatch_fn	equ	3006h			; CS-resident fn ptr — set by enddemo load (multi-purpose 0x3006 dispatch slot)
shop_entry_probe	equ	0A004h			;* init probe byte (file +0x08)
ref_enddemo_addr	equ	0A0ADh			;* ref_enddemo record (file +0xB1)
gfx_driver_ref_tbl	equ	0A0BBh			;* gfx-driver ref-ptr table (file +0xBF)
banner_tile_grid	equ	0A129h			;* 16x17 tile-id grid (file +0x12D)
ref_omoya_grp_addr	equ	0A239h			;* OMOYA.GRP ref record (file +0x23D)
banner_msg_addr		equ	0A245h			;* "In the Hut" msg hdr (file +0x249)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

run_omoyp_main		proc	far

;--------------------------------------------------------------------------
; Module header (9 bytes). The first 5 bytes are module metadata bytes
; read by the loader; they are not executed. Sourcer decoded them as
; nonsense instructions. The 4 bytes at offset 0x05-0x08 form a tiny
; "probe" callable that returns the byte at gvar_game_seg:[0A004h] in AL
; (used by town.bin to read the module's entry-init byte).
;--------------------------------------------------------------------------

start:
		push	bx				; db 53h  -- header byte
		add	al,[bx+si]			; db 02h,00h  -- header bytes
		add	[di],al				; db 00h,05h  -- header bytes
		mov	al,ds:shop_entry_probe		; probe: read init byte
		retn					; return init byte to caller

;--------------------------------------------------------------------------
; omoya_main - shop entry point.
; Called by town.bin's shop dispatcher when the player enters the hut.
; Loads OMOYA.GRP, copies first 256 bytes into the gfx driver's buffer,
; runs init A/B, displays the banner text, and enters the dialog loop.
;--------------------------------------------------------------------------

omoya_main:					; entry from town dispatch
		mov	es,ds:gvar_game_seg
		mov	di,8000h
		mov	si,ref_omoya_grp_addr		; -> OMOYA.GRP ref record
		mov	al,2				; type 2 = load via fill_buffer
		call	word ptr cs:[sar_loader_fn]		; chunk loader
		push	ds
		mov	ds,cs:gvar_game_seg
		mov	si,8000h
		mov	cx,100h
		call	word ptr cs:drv_ds_copy
		pop	ds
		call	word ptr cs:drv_screen_init_a
		call	word ptr cs:drv_screen_init_b
		mov	si,banner_msg_addr		; -> "In the Hut" banner header
		call	word ptr cs:drv_load_msg_header
		call	draw_hut_banner
		test	byte ptr ds:[area_load_flag],0FFh
		jnz	short end_demo_transition	; skip dialog loop -> end demo
		mov	byte ptr ds:gvar_script_skip,0

omoya_main_loop:
				call	word ptr cs:omoyp_script_6016
				test	byte ptr ds:gvar_script_skip,0FFh
				jz	omoya_main_loop			; Jump if zero
		jmp	word ptr cs:drv_return_to_caller

;--------------------------------------------------------------------------
; end_demo_transition - secondary entry point.
; Reached via the DS-resident dispatch table at drv_return_to_caller. Loads
; enddemo.bin into CS:6000h and the mode-specific graphics driver keyed
; off gvar_gfx_mode into CS:3000h, waits 300 timer ticks, then jumps
; into the loaded enddemo.
;--------------------------------------------------------------------------

end_demo_transition:				; dispatch target (via drv_return_to_caller)
		pop	ax				; discard caller return addr
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	si,ref_enddemo_addr		; -> enddemo.bin ref record
		mov	di,6000h
		mov	al,3				; type 3 = raw load (code chunk)
		call	word ptr cs:[sar_loader_fn]
		mov	ax,cs
		mov	es,ax
		xor	bx,bx				; Zero register
		mov	bl,ds:gvar_gfx_mode
		add	bx,bx
		mov	si,ds:gfx_driver_ref_tbl[bx]	; per-mode gfx driver ref
		mov	di,3000h
		mov	al,3				; type 3 = raw load
		call	word ptr cs:[sar_loader_fn]
		mov	word ptr cs:gvar_timer_word,0
		cmp	word ptr cs:gvar_timer_word,12Ch
		jb	$-7				; wait 300 ticks
		mov	bx,0
		mov	cx,50C8h
		call	word ptr cs:[loaded_gfx_dispatch_fn]		; loaded gfx driver fn
		mov	byte ptr cs:[gvar_cinematic_active],0FFh	; set demo-active flag
		jmp	word ptr ds:[game_data_base]		; jump into loaded enddemo

;--------------------------------------------------------------------------
; Data tables: enddemo + graphics-driver file references.
;
; Each record is [archive_byte, chunk_byte, 'filename', 0]. The 16-bit
; pointer table gfx_driver_ref_tbl (at +0xBB) has 6 entries indexed by
; gvar_gfx_mode (0=EGA alt, 1=CGA, 2=CGA, 3=HGC, 4=MCGA, 5=TGA).
;
; The ref_enddemo record at file offset 0xB1 is pointed to by
; 0A0ADh (game-segment linear addr) in end_demo_transition above.
;--------------------------------------------------------------------------

ref_enddemo	db	 01h, 33h			; archive=1 (zelres2), chunk=33h
		db	'enddemo.bin'
		db	 00h				; filename terminator
;
; gfx_driver_ref_tbl: word array indexed by gvar_gfx_mode. Each entry is a
; pointer (game-segment addr) to an [archive, chunk, 'filename', 0] record.
; All driver binaries live in zelres1 (archive = 0).
;

gfx_driver_ref_tbl_lbl	label	word		; @ 0A0BBh (file +0xBF)
		dw	0A0C7h				; mode 0: -> ref_gdega
		dw	0A0D3h				; mode 1: -> ref_gdcga
		dw	0A0D3h				; mode 2: -> ref_gdcga (alias)
		dw	0A0DFh				; mode 3: -> ref_gdhgc
		dw	0A0EBh				; mode 4: -> ref_gdmcga
		dw	0A0F8h				; mode 5: -> ref_gdtga
;
; Driver ref records. Each record: archive=0 (zelres1), chunk, filename, 0.
; NOTE: trailing null of each record also serves as the archive-byte (0) of
; the next record, so records share boundary bytes -- don't add extra nulls.
;

ref_gdega_lbl	label	byte			; @ 0A0C7h (file +0xCB)
		db	 00h, 02h			; archive=0, chunk=02h
		db	'gdega.bin'
		db	 00h				; filename terminator

ref_gdcga_lbl	label	byte			; @ 0A0D3h (file +0xD7)
		db	 00h, 03h			; archive=0, chunk=03h
		db	'gdcga.bin'
		db	 00h				; filename terminator

ref_gdhgc_lbl	label	byte			; @ 0A0DFh (file +0xE3)
		db	 00h, 04h			; archive=0, chunk=04h
		db	'gdhgc.bin'
		db	 00h				; filename terminator

ref_gdmcga_lbl	label	byte			; @ 0A0EBh (file +0xEF)
		db	 00h, 06h			; archive=0, chunk=06h
		db	'gdmcga.bin'
		db	 00h				; filename terminator

ref_gdtga_lbl	label	byte			; @ 0A0F8h (file +0xFC)
		db	 00h, 05h			; archive=0, chunk=05h
		db	'gdtga.bin'
		db	 00h				; filename terminator

run_omoyp_main		endp

;==========================================================================
;
; draw_hut_banner
;
; Blit a 16-row by 17-column tile-id grid (banner_tile_grid at +0x129)
; to the screen starting at row/col 0x0C1E via drv_draw_glyph.
;
;==========================================================================

draw_hut_banner	proc	near
		mov	si,banner_tile_grid
		mov	bx,0C1Eh
		mov	cx,10h				; 16 rows

banner_row_loop:
				push	cx
				mov	cx,11h				; 17 cols per row

banner_col_loop:
						push	cx
						push	bx
						lodsb					; next tile id
						call	word ptr cs:drv_draw_glyph
						pop	bx
						inc	bh				; next col
						pop	cx
						loop	banner_col_loop			; Loop if cx > 0

				sub	bh,11h				; reset col
				add	bl,8				; advance row
				pop	cx
				loop	banner_row_loop			; Loop if cx > 0

		retn

draw_hut_banner	endp

;--------------------------------------------------------------------------
; banner_tile_grid (@ +0x129)
;
; 16 x 17 tile-id grid, padded with zero cells to form an irregular banner
; shape. Tile ids 0x01..0x86 reference glyph tiles in the OMOYA.GRP set;
; zero entries are blank / background cells.
;--------------------------------------------------------------------------

banner_tile_grid_lbl	label	byte		; @ +0x129
		db	7 dup (0)			; row 0a: 7 blank cells (left margin)
		db	1, 2				; row 0b: tile ids 1,2
		db	14 dup (0)			; row 0c: 14 blank cells
		db	3, 4, 5, 6, 0			; row 1a: tile ids 3-6 + blank
		db	12 dup (0)			; row 1b: 12 blank cells
		db	 07h, 08h, 09h, 0Ah, 00h	; row 2a: tile ids 7-10 + blank
		db	12 dup (0)			; row 2b: 12 blank cells
		db	 0Bh, 0Ch, 0Dh, 0Eh, 00h	; row 3a: tile ids 11-14 + blank
		db	12 dup (0)			; row 3b: 12 blank cells
		db	 0Fh, 10h, 11h, 12h, 00h	; row 4a: tile ids 15-18 + blank
		db	12 dup (0)			; row 4b: 12 blank cells
		db	 13h, 14h, 15h, 16h, 00h	; row 5a: tile ids 19-22 + blank
		db	12 dup (0)			; row 5b: 12 blank cells
		db	 17h, 18h, 19h, 1Ah, 00h	; row 6a: tile ids 23-26 + blank
		db	7 dup (0)			; row 6b: 7 blank cells
		db	 1Bh, 1Ch, 1Dh, 1Eh, 1Fh	; row 7a: tile ids 27-31
		db	 20h, 21h, 22h, 23h		; row 7b: tile ids 32-35
		db	7 dup (0)			; row 7c: 7 blank cells
		db	'$'				; row 8a: tile id 0x24
		db	'%&', 27h, '()*+,-'		; row 8b: tile ids 0x25-0x2D (ASCII)
		db	7 dup (0)			; row 8c: 7 blank cells
		db	'./012345678'			; row 9a: tile ids 0x2E-0x38
		db	0, 0, 0, 0, 0, 0		; row 9b: 6 blank cells
		db	'9:;<=>?@ABC'			; row 10a: tile ids 0x39-0x43
		db	 00h, 00h, 00h, 00h, 00h, 00h	; row 10b: 6 blank cells
		db	 44h, 45h, 46h, 47h, 00h, 48h	; row 11a: tile ids 0x44-0x48 with one blank
		db	 49h, 4Ah, 4Bh, 4Ch, 4Dh, 00h	; row 11b: tile ids 0x49-0x4D + blank
		db	 00h, 00h, 00h, 00h, 00h, 4Eh	; row 12a: 5 blanks then tile 0x4E
		db	 4Fh, 50h, 51h, 00h, 52h, 53h	; row 12b: tile ids 0x4F-0x53 with one blank
		db	 54h, 55h, 56h, 57h, 58h, 00h	; row 12c: tile ids 0x54-0x58 + blank
		db	 00h, 00h, 00h, 00h		; row 13a: 4 blank cells
		db	'YZ[\]^_`abcdef'		; row 13b: tile ids 0x59-0x66 (ASCII)
		db	0, 0, 0				; row 14a: 3 blank cells
		db	'ghijklmnopqrstu'		; row 14b: tile ids 0x67-0x75 (ASCII)
		db	0, 0				; row 15a: 2 blank cells
		db	'vwxyz{|}~'			; row 15b: tile ids 0x76-0x7E (ASCII)
		db	 7Fh, 80h, 81h, 82h, 83h, 84h	; row 15c: tile ids 0x7F-0x84
		db	 85h, 86h			; row 15d: tile ids 0x85,0x86 (last 2)
;--------------------------------------------------------------------------
; OMOYA.GRP chunk reference @ 0A239h:
;   [archive=1, chunk=14h, 'OMOYA.GRP', 0, header_fields...]
; banner_msg_header @ 0A245h (passed to drv_load_msg_header):
;   [16h, AFh, 02h, length=0Ah, 'In the Hut']
;--------------------------------------------------------------------------
ref_omoya_grp	db	 01h, 14h			; archive=1, chunk=14h
		db	'OMOYA.GRP'
		db	 00h				; filename terminator

banner_msg_header	label	byte		; @ 0A245h
		db	 16h,0AFh, 02h			; display flags / region hdr
		db	0Ah, 'In the Hut'		; length-prefixed banner text

seg_a		ends

		end	start
