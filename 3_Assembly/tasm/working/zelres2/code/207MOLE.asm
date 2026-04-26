
PAGE  59,132

;==========================================================================
;
;  207MOLE - Level/World Graphics Init Module (mole.bin, zelres2 chunk 8)
;
;  Loaded into CS+3000h by game.asm as the "level/world system" chunk.
;  Called via CALL FAR with AL = gvar_game_phase (graphics mode index).
;
;  Stores AL to cs:[0x499] (game_phase / mode index), then copies several
;  source graphics blocks into planar buffers at 0x2926 / 0x3286 and
;  dispatches to mode-specific planar decoders via two jump tables:
;
;    jmp_tbl_decode_a (offset 0xE2) - 6 entries, indexed by game_phase*2
;    jmp_tbl_decode_b (offset 0x360) - 6 entries, indexed by game_phase*2
;
;  The six dispatch targets select 4-plane EGA (A000h), 2-plane CGA
;  (B800h), or single-plane mono (B000h) write paths for each tile.
;
;  Key subsystems:
;    module_init         - offset 0: entry; stores phase, calls mode init,
;                          copies sprite data, invokes decoders, returns far
;    ega_init            - offset 0xAF: program EGA Graphics Controller regs
;                          (Set/Reset, Enable, Color Compare, Mode, BitMask)
;    dispatch_decode_a   - offset 0xD4: indexed jmp through jmp_tbl_decode_a
;    dispatch_decode_b   - offset 0x352: indexed jmp through jmp_tbl_decode_b
;    ega_plane_blit      - 0x0EA: mode-0 handler; EGA 4-plane via 3C4h/3C5h
;    cga_shift_blit      - 0x140: mode 1/2 handler; CGA B800h 2-field
;    hgc_blit            - 0x1BA: mode 3 handler; Hercules B000h
;    vga_blit            - 0x24B: mode 4 handler; VGA 320x200 linear
;    cga_hires_blit      - 0x2BE: mode 5 handler; CGA with 2-field interlace
;    ega_decode_b        - 0x36C: mode-0 for dispatch_b; EGA plane-2 copy
;    vga_chain4_decode   - 0x3CF: mode-5 for dispatch_b; VGA with sub-calls
;    unpack_nibble_stream- 0x458: compressed byte-stream sprite unpacker
;    extract_bits        - 0x40B: bitplane nibble -> 8-pixel byte merger
;
;  Decoders share three small scratch tables at offsets 0x1AA, 0x2AE, 0x33E
;  (4bpp pixel unpack LUT for the nibble-stream format used by the sprite
;  data). Remaining bulk of the file (0x498+) is raw sprite/tile image data.
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; External data references (all CS-relative; this chunk is loaded raw at CS+3000h).
;
; Variables in this chunk's own CS segment (indexed from 0x0499):

game_phase_var	equ	499h			; [byte] stored game_phase / mode index (set on entry)
dispatch_flag_1	equ	497h			; [byte] control flag A (written by init: 0x10, then 0x50)
dispatch_flag_2	equ	498h			; [byte] control flag B (written by init: 0xFF)

; Internal constants used by the planar decoders:

wrap_delta	equ	0C050h			; planar wraparound delta (added when di hits 4000h)
vga_limit	equ	6000h			; VGA framebuffer size limit (cmp against di)
mcga_wrap_b	equ	80A0h			; MCGA wraparound delta (after di >= 8000h)

; Non-instruction scratch buffers (referenced in decoded-but-not-taken branches):

cs_dispatch_178	equ	3BF0h			; post-blit di target used by decode_5col_blit_loop
cs_dispatch_179	equ	6778h			; post-blit di target used by mono_scan_loop

; The following EQUs are address constants that appear as disassembled
; operands on instructions that are actually misaligned -- i.e. inside
; raw sprite/bitmap data blocks that Sourcer attempted to decode. They
; are not real variables; the names are kept to preserve bit-perfect
; output after TASM re-encodes the misaligned mnemonics.
;
misdec_99A2	equ	99A2h			; operand in fake "add [99A2h],ch" at 0x0003
misdec_A000	equ	0A000h			; operand in fake "add [A000h+bx],ch" at 0x02CB
misdec_BAA0	equ	0BAA0h			; operand in fake "adc [BAA0h+bx+si],cx" at 0x1B45
misdec_EA41	equ	0EA41h			; operand in fake "or ch,[EA41h+bx+si]" at 0x1B54
misdec_822A	equ	822Ah			; operand in fake "mov al,[822Ah]" at 0x1B4F
misdec_41A2	equ	41A2h			; operand in fake "adc [41A2h+bp+si],cx" at 0x1B52
misdec_4B01	equ	4B01h			; operand in fake "add [4B01h+bp+si],di" at 0x00E7

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

module_init		proc	far

; --- Entry point at offset 0x0000 ---
; Called FAR from game.asm with:
;   DS = game segment, AL = gvar_game_phase
; The first 8 bytes (offsets 0-7) assemble as 3 mnemonics with benign
; side effects on ES:[bx+si] and DS:[99A2h]. Real initialization begins
; at offset 0x08 (mov ax,cs), but offsets 0-7 produce the required bit
; pattern and must be kept as-is for byte-identity.

start:
		sub	es:[bx+si],ax		; {26 29 00}  filler: pads to offset 3
		add	ds:misdec_99A2,ch	; {00 2E A2 99}  filler: pads to offset 7
		add	al,8Ch			; {04 8C}  filler: last byte doubles as "mov ax,cs" opcode
;
; Real init code below (offsets 0x08..0xA6) -- assembled as db to preserve
; alignment. Decoded manually, these bytes are:
;
;   08: mov  ax, cs                 {8C C8}           ; DS = ES = CS
;   0A: mov  ds, ax                 {8E D8}
;   0C: mov  es, ax                 {8E C0}
;   0E: cld                         {FC}
;   0F: call 00A7h                  {E8 95 00}        ; -> test game_phase, jz ega_init
;   12: mov  si, 04AEh              {BE AE 04}        ; src block 1
;   15: mov  di, 2926h              {BF 26 29}        ; dst buffer A
;   18: call 0458h                  {E8 3D 04}        ; -> unpack_nibble_stream
;   1B: mov  si, 073Dh              {BE 3D 07}        ; src block 2
;   1E: mov  di, 3286h              {BF 86 32}        ; dst buffer B
;   21: call 0458h                  {E8 34 04}        ; -> unpack_nibble_stream
;   24: mov  si, 2926h              {BE 26 29}        ; src = dst buffer A (unpacked)
;   27: mov  bp, 0960h              {BD 60 09}
;   2A: mov  bx, 0C00h              {BB 00 0C}        ; y=12, x=0
;   2D: mov  cx, 380Dh              {B9 0D 38}        ; 56 rows of 13 bytes (0x38/0x0D)
;   30: call 00D4h                  {E8 A1 00}        ; -> dispatch_decode_a
;   33: mov  byte ptr [0497h], 10h  {C6 06 97 04 10}  ; dispatch_flag_1 = 10h
;   38: mov  si, 08CDh              {BE CD 08}        ; src block 3
;   3B: mov  di, 2926h              {BF 26 29}        ; dst A
;   3E: call 0458h                  {E8 17 04}        ; -> unpack_nibble_stream
;   41: mov  si, 10DBh              {BE DB 10}        ; src block 4
;   44: mov  di, 3286h              {BF 86 32}        ; dst B
;   47: call 0458h                  {E8 0E 04}        ; -> unpack_nibble_stream
;   4A: mov  si, 2926h              {BE 26 29}
;   4D: mov  bp, 0960h              {BD 60 09}
;   50: mov  bx, 0000h              {BB 00 00}        ; y=0, x=0
;   53: mov  cx, 0CC8h              {B9 C8 0C}        ; 12 rows x 200 bytes
;   56: call 00D4h                  {E8 7B 00}        ; -> dispatch_decode_a
;   59: mov  si, 1861h              {BE 61 18}        ; src block 5
;   5C: mov  di, 2926h              {BF 26 29}
;   5F: call 0458h                  {E8 F6 03}        ; -> unpack_nibble_stream
;   62: mov  si, 2088h              {BE 88 20}        ; src block 6
;   65: mov  di, 3286h              {BF 86 32}
;   68: call 0458h                  {E8 ED 03}        ; -> unpack_nibble_stream
;   6B: mov  si, 2926h              {BE 26 29}
;   6E: mov  bp, 0960h              {BD 60 09}
;   71: mov  bx, 4400h              {BB 00 44}        ; y=68, x=0
;   74: mov  cx, 0CC8h              {B9 C8 0C}
;   77: call 00D4h                  {E8 5A 00}        ; -> dispatch_decode_a
;   7A: mov  byte ptr [0498h], FFh  {C6 06 98 04 FF}  ; dispatch_flag_2 = FFh
;   7F: mov  byte ptr [0497h], 50h  {C6 06 97 04 50}  ; dispatch_flag_1 = 50h
;   84: mov  si, 2799h              {BE 99 27}        ; src block 7 (last)
;   87: mov  di, 2926h              {BF 26 29}
;   8A: call 0458h                  {E8 CB 03}        ; -> unpack_nibble_stream
;   8D: mov  di, 3286h              {BF 86 32}        ; clear dst B
;   90: mov  cx, 04B0h              {B9 B0 04}        ; 0x4B0 words = 2400 bytes
;   93: xor  ax, ax                 {33 C0}
;   95: rep  stosw                  {F3 AB}
;   97: mov  bp, 0960h              {BD 60 09}
;   9A: mov  bx, 0C9Eh              {BB 9E 0C}        ; y=12, x=0x9E
;   9D: mov  cx, 382Ah              {B9 2A 38}        ; 56 rows x 42 bytes
;   A0: call 00D4h                  {E8 31 00}        ; -> dispatch_decode_a
;   A3: call 0352h                  {E8 AC 02}        ; -> dispatch_decode_b
;   A6: retf                        {CB}              ; far return to game.asm
;
; 00A7: test byte ptr [0499h], FFh  {F6 06 99 04 FF}  ; is game_phase set?
; 00AC: jz   00AF  (= ega_init)     {74 01}           ; first call: init EGA
; 00AE: retn                        {C3}              ; subsequent: skip init
;
		db	0C8h, 8Eh,0D8h, 8Eh,0C0h,0FCh	; 08-0D
		db	0E8h, 95h, 00h,0BEh,0AEh, 04h	; 0E-13
		db	0BFh, 26h, 29h,0E8h, 3Dh, 04h	; 14-19
		db	0BEh, 3Dh, 07h,0BFh, 86h, 32h	; 1A-1F
		db	0E8h, 34h, 04h,0BEh, 26h, 29h	; 20-25
		db	0BDh, 60h, 09h,0BBh, 00h, 0Ch	; 26-2B
		db	0B9h, 0Dh, 38h,0E8h,0A1h, 00h	; 2C-31
		db	0C6h, 06h, 97h, 04h, 10h,0BEh	; 32-37
		db	0CDh, 08h,0BFh, 26h, 29h,0E8h	; 38-3D
		db	 17h, 04h,0BEh,0DBh, 10h,0BFh	; 3E-43
		db	 86h, 32h,0E8h, 0Eh, 04h,0BEh	; 44-49
		db	 26h, 29h,0BDh, 60h, 09h,0BBh	; 4A-4F
		db	 00h, 00h,0B9h,0C8h, 0Ch,0E8h	; 50-55
		db	 7Bh, 00h,0BEh, 61h, 18h,0BFh	; 56-5B
		db	 26h, 29h,0E8h,0F6h, 03h,0BEh	; 5C-61
		db	 88h, 20h,0BFh, 86h, 32h,0E8h	; 62-67
		db	0EDh, 03h,0BEh, 26h, 29h,0BDh	; 68-6D
		db	 60h, 09h,0BBh, 00h, 44h,0B9h	; 6E-73
		db	0C8h, 0Ch,0E8h, 5Ah, 00h,0C6h	; 74-79
		db	 06h, 98h, 04h,0FFh,0C6h, 06h	; 7A-7F
		db	 97h, 04h, 50h,0BEh, 99h, 27h	; 80-85
		db	0BFh, 26h, 29h,0E8h,0CBh, 03h	; 86-8B
		db	0BFh, 86h, 32h,0B9h,0B0h, 04h	; 8C-91
		db	 33h,0C0h,0F3h,0ABh,0BDh, 60h	; 92-97
		db	 09h,0BBh, 9Eh, 0Ch,0B9h, 2Ah	; 98-9D
		db	 38h,0E8h, 31h, 00h,0E8h,0ACh	; 9E-A3
		db	 02h,0CBh,0F6h, 06h, 99h, 04h	; A4-A9
		db	0FFh, 74h, 01h,0C3h		; AA-AD
; ega_init: program EGA Graphics Controller registers for planar writes.
; Reached from offset 0x0F via "call 0A7h -> jz 0AFh" fall-through on first
; entry (when game_phase_var is still zero). Subsequent calls skip init.

ega_init:
		mov	dx,3CCh
		xor	al,al			; Zero register
		out	dx,al			; port 3CCh, EGA graphics 1 pos
		inc	dx
		inc	al
		out	dx,al			; port 3CDh ??I/O Non-standard
		mov	dx,3CEh
		mov	ax,0
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 0, set/reset bit
		inc	al
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 1, enable set/reset
		mov	ax,0F02h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 2, color compare bits
		mov	ax,3
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 3, data rotate
		mov	ax,5
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 5, mode
		mov	ax,0FF08h
		out	dx,ax			; port 3CEh, EGA graphic index
						;  al = 8, data bit mask
		retn

module_init		endp

dispatch_decode_a		proc	near
		xor	ax,ax			; Zero register
		mov	al,ds:game_phase_var
		add	ax,ax
		add	ax,0DEh
		mov	di,ax
		jmp	word ptr [di]		;*

dispatch_decode_a		endp

; --- jmp_tbl_decode_a: 6-entry dispatch table, indexed by game_phase*2 ---
; This 5-byte encoding resembles "jmp far ptr 4001h:4000h" but is actually
; the first 2.5 words of the jump table (targets 0xEA, 0x140, 0x140, ...).
; TASM cannot express this as a mnemonic because the far-jmp is absolute.

jmp_tbl_decode_a	label	word
		db	0EAh, 00h, 40h, 01h, 40h	; words at +0, +2, +4: 40EAh, 40h, 4001h (raw bytes)

; --- ega_plane_blit: dispatch target for mode 0 (EGA) at offset 0x00EA ---
; Reads sprite data via DS:[BP+SI] / DS:[SI], writes to EGA framebuffer A000h
; using Map Mask register (3C4h/3C5h) to select planes 1, 2, 4 per byte.
; Called via dispatch_decode_a when game_phase=2 (EGA). Stack on entry: ES saved.
; The "add ss:... / add bh,..." instructions decode the final 7 bytes of
; jmp_tbl_decode_a (dispatch entries at +6, +8, +10) as a fake side-effect
; prologue; execution resumes with "mov ax,50h" at offset 0x00F0.

ega_plane_blit:
		add	ss:misdec_4B01[bp+si],di	; {BA 4B01 BD}  dispatch entry 3 (1BAh) misaligned
		add	bh,ss:data_20[bp]		; {02 BE 0602}   dispatch entry 4 (24Bh) misaligned
		mov	ax,50h
		mul	bl			; ax = reg * al
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		inc	dx
		mov	bx,cx

ega_row_loop:
					push	di
					push	cx

ega_plane_byte_loop:
								mov	ah,ds:[bp+si]
								lodsb				; String [si] to al
								mov	cl,ah
								or	cl,al
								xor	cl,al
								mov	ch,cl
								or	al,ch
								not	ch
								and	ah,ch
								mov	ch,al
								mov	al,1
								out	dx,al			; port 3C5h, EGA sequencr func
								mov	es:[di],ch
								mov	al,2
								out	dx,al			; port 3C5h, EGA sequencr func
								mov	es:[di],ah
								mov	al,4
								out	dx,al			; port 3C5h, EGA sequencr func
								mov	es:[di],cl
								inc	di
								dec	bh
								jnz	ega_plane_byte_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,50h
					mov	bh,ch
					dec	bl
					jnz	ega_row_loop			; Jump if not zero
		pop	es
		retn
; --- cga_shift_blit: dispatch target for modes 1/2 (CGA) at offset 0x0140 ---
; Writes to CGA framebuffer B800h (with interleaved-line layout, 2000h stride).
; Wraps to B800h+4000h+C050h boundary for second field.
; Entered via dispatch_decode_a for modes 1/2 (or called directly at 0x0140).

cga_shift_blit:
		push	es
		mov	ax,50h
		shr	bl,1			; Shift w/zeros fill
		sbb	dx,dx
		mul	bl			; ax = reg * al
		and	dx,2000h
		add	ax,dx
		mov	bl,bh
		xor	bh,bh			; Zero register
		add	ax,bx
		mov	di,ax
		mov	ax,0B800h
		mov	es,ax
		mov	bx,cx

cga_row_loop:
					push	di
					push	cx

cga_byte_loop:
								push	bx
								mov	ah,ds:[bp+si]
								lodsb				; String [si] to al
								xor	dl,dl			; Zero register
								mov	cx,4

cga_bit_unpack_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,byte ptr ds:[1AAh][bx]   ; LUT at 0x01AA: 4bpp->CGA 2bpp
								loop	cga_bit_unpack_loop		; Loop if cx > 0

								mov	al,dl
								stosb				; Store al to es:[di]
								pop	bx
								dec	bh
								jnz	cga_byte_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,4000h
					jb	cga_row_continue			; Jump if below
					add	di,wrap_delta

cga_row_continue:
					mov	bh,ch
					dec	bl
					jnz	cga_row_loop			; Jump if not zero
		pop	es
		retn
; --- LUT at 0x01AA: 4-bit nibble -> 2-bit CGA/HGC pair unpacker ---
; Used by cga_bit_unpack_loop and hgc_bit_unpack_loop via "ds:[1AAh][bx]".
; 16 entries mapping 4bpp planar nibble to CGA-style color pair.

nibble_to_2bpp_lut	label	byte
		db	 00h, 03h, 02h, 01h, 01h, 03h
		db	 02h, 01h, 00h, 03h, 02h, 01h
		db	 01h, 03h, 02h, 01h

; --- hgc_blit: dispatch target for mode 3 (HGC) at offset 0x01BA ---
; Hercules graphics (720x348, 2-field interlace at B000h/B000h+2000h).
; Uses nibble_to_2bpp_lut for pixel unpacking. On di wrap (>= vga_limit),
; copies field A -> field B and applies A05Ah row stride.

hgc_blit:
		push	es		; 06
		xor	ax,ax		; 33 C0
		mov	al,bl		; 8A C3
		add	ax,1Ch		; 05 1C 00
		mov	dl,3		; B2 03
		div	dl		; F6 F2
		mov	dh,ah		; 8A F4
		ror	dh,1		; D0 CE
		ror	dh,1		; D0 CE
		ror	dh,1		; D0 CE
		mov	ah,5Ah		; B4 5A
		mul	ah		; F6 E4
		and	dx,6000h	; 81 E2 00 60
		add	ax,dx		; 03 C2
		add	bh,5		; 80 C7 05
		mov	bl,bh		; 8A DF
		xor	bh,bh		; 32 FF
		add	ax,bx		; 03 C3
		mov	di,ax		; 8B F8
		mov	ax,0B000h	; B8 00 B0  -- HGC segment
		mov	es,ax		; 8E C0
		mov	bx,cx		; 8B D9

hgc_row_loop:
					push	di
					push	cx

hgc_byte_loop:
								push	bx
								mov	ah,ds:[bp+si]
								lodsb				; String [si] to al
								xor	dl,dl			; Zero register
								mov	cx,4

hgc_bit_unpack_loop:
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								add	ah,ah
								adc	bl,bl
								add	al,al
								adc	bl,bl
								and	bl,0Fh
								xor	bh,bh			; Zero register
								add	dl,dl
								add	dl,dl
								or	dl,byte ptr ds:[1AAh][bx]    ; LUT: nibble -> 2bpp
								loop	hgc_bit_unpack_loop		; Loop if cx > 0

								mov	al,dl
								stosb				; Store al to es:[di]
								pop	bx
								dec	bh
								jnz	hgc_byte_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,vga_limit
					jb	hgc_row_continue			; Jump if below
					; Wrap: copy row from field A to field B
					push	ds
					push	si
					push	cx
					push	di
					push	es
					pop	ds
					mov	si,di
					sub	si,2000h
					mov	cl,ch
					xor	ch,ch			; Zero register
					rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
					pop	di
					pop	cx
					pop	si
					pop	ds
					add	di,0A05Ah

hgc_row_continue:
					mov	bh,ch
					dec	bl
					jnz	hgc_row_loop			; Jump if not zero
		pop	es
		retn
; --- vga_blit: dispatch target for mode 4 (VGA/MCGA 320x200 linear) at 0x024B ---
; Writes 4 bytes per input nibble to VGA A000h with 140h stride (320 bytes/row).
; Uses vga_pixel_unpack (below) with ds:[2AEh][bx] = 16-entry VGA color LUT.

vga_blit:
		push	es
		xor	dx,dx			; Zero register
		mov	dl,bh
		mov	bh,dh
		push	dx
		mov	ax,140h
		mul	bx			; dx:ax = reg * ax
		pop	dx
		add	dx,dx
		add	dx,dx
		add	ax,dx
		mov	di,ax
		mov	ax,0A000h
		mov	es,ax
		mov	bx,cx

vga_row_loop:
					push	di
					push	cx

vga_byte_loop:
								push	bx
								mov	dh,ds:[bp+si]
								mov	dl,[si]
								call	vga_pixel_unpack
								stosb				; Store al to es:[di]
								call	vga_pixel_unpack
								stosb				; Store al to es:[di]
								call	vga_pixel_unpack
								stosb				; Store al to es:[di]
								call	vga_pixel_unpack
								stosb				; Store al to es:[di]
								inc	si
								pop	bx
								dec	bh
								jnz	vga_byte_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,140h
					mov	bh,ch
					dec	bl
					jnz	vga_row_loop			; Jump if not zero
		pop	es
		retn

vga_pixel_unpack		proc	near
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		add	dh,dh
		adc	bl,bl
		add	dl,dl
		adc	bl,bl
		and	bl,0Fh
		xor	bh,bh			; Zero register
		mov	al,byte ptr ds:[2AEh][bx]
		retn

vga_pixel_unpack		endp

; --- LUT at 0x02AE: 4-bit nibble -> VGA pixel pair (16 entries) ---
; Used by vga_pixel_unpack via "ds:[2AEh][bx]".

nibble_to_vga_lut	label	byte
		db	 00h, 01h, 05h, 03h, 08h, 09h
		db	 0Dh, 0Bh, 28h, 29h, 2Dh, 2Bh
		db	 18h, 19h, 1Dh, 1Bh

; --- cga_hires_blit: dispatch target for mode 5 at offset 0x02BE ---
; CGA-segment B800h blitter variant using the 2-field interlace layout
; (row*A0 + field_select via bl shifted into dx 6000h mask).

cga_hires_blit:
		push	es		; 06
		mov	dh,bl		; 8A F3
		ror	dh,1		; D0 CE
		ror	dh,1		; D0 CE
		ror	dh,1		; D0 CE
		and	dx,6000h	; 81 E2 00 60
		shr	bl,1		; D0 EB
		shr	bl,1		; D0 EB
		mov	ax,0A0h		; B8 A0 00
		mul	bl		; F6 E3
		add	ax,dx		; 03 C2
		mov	bl,bh		; 8A DF
		xor	bh,bh		; 32 FF
		add	bx,bx		; 03 DB
		add	ax,bx		; 03 C3
		mov	di,ax		; 8B F8
		mov	ax,0B800h	; B8 00 B8  -- CGA segment (field A)
		mov	es,ax		; 8E C0
		mov	bx,cx		; 8B D9

cga_hires_row_loop:
					push	di
					push	cx

cga_hires_byte_loop:
								push	bx
								mov	dh,ds:[bp+si]
								mov	dl,[si]
								call	mcga_pixel_unpack
								stosb				; Store al to es:[di]
								call	mcga_pixel_unpack
								stosb				; Store al to es:[di]
								inc	si
								pop	bx
								dec	bh
								jnz	cga_hires_byte_loop			; Jump if not zero
					pop	cx
					pop	di
					add	di,2000h
					cmp	di,8000h
					jb	cga_hires_row_continue			; Jump if below
					add	di,80A0h

cga_hires_row_continue:
					mov	bh,ch
					dec	bl
					jnz	cga_hires_row_loop			; Jump if not zero
		pop	es
		retn

mcga_pixel_unpack		proc	near
		xor	al,al			; Zero register
		mov	cx,2

mcga_nibble_loop:
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					add	dh,dh
					adc	bl,bl
					add	dl,dl
					adc	bl,bl
					and	bl,0Fh
					xor	bh,bh			; Zero register
					add	al,al
					add	al,al
					add	al,al
					add	al,al
					or	al,byte ptr ds:[33Eh][bx]
					loop	mcga_nibble_loop		; Loop if cx > 0

		retn

mcga_pixel_unpack		endp

; --- LUT at 0x033E: 4-bit -> MCGA pixel pair (16 entries) ---
; Used by mcga_pixel_unpack via "ds:[33Eh][bx]".

nibble_to_mcga_lut	label	byte
		db	 00h, 07h, 01h, 02h, 07h, 0Fh
		db	 03h, 0Ah, 01h, 03h, 09h, 0Bh
		db	 02h, 0Ah, 0Bh, 0Eh

dispatch_decode_b		proc	near
		xor	ax,ax			; Zero register
		mov	al,ds:game_phase_var
		add	ax,ax
		add	ax,35Ch
		mov	di,ax
		jmp	word ptr [di]		;*

dispatch_decode_b		endp

; --- jmp_tbl_decode_b: 6-entry dispatch table at 0x0360 ---
; Targets for game_phase 0..5:
;   phase 0 -> 0x0368 (EGA)
;   phase 1/2/3 -> 0x038B (retn stub; modes CGA/HGC/TGA do nothing)
;   phase 4 -> 0x038C (retn stub; MCGA also nothing)
;   phase 5 -> 0x03CF (VGA-chain4; copies 3ACBh block then does full scan)
; The bytes at 0x0368 overlap: they form both the last 2 dispatch entries
; AND the opening instructions of the EGA-mode handler.

jmp_tbl_decode_b	label	word
		db	 68h, 03h, 8Bh, 03h, 8Bh, 03h	; phase 0/1/2 -> 0368h, 038Bh, 038Bh
		db	 8Bh, 03h, 8Ch, 03h,0CFh, 03h	; phase 3/4/5 -> 038Bh, 038Ch, 03CFh

; --- ega_decode_b: mode-0 (EGA) handler at 0x036C ---
; Sets up EGA plane write (port 3C4/3C5, index 2 = Map Mask, value 4 = plane 2),
; copies 5 rows of 2 bytes each with 0x4E stride to planar destination.
; Runs THROUGH the dispatch entry bytes (0x368-0x36B are interpreted as code).

ega_decode_b:					; logical mode-0 entry = 0x036C
		mov	ax,0A000h		; B8 00 A0  -- VGA/EGA segment
		mov	es,ax			; 8E C0
		mov	dx,3C4h			; BA C4 03
		mov	ax,0402h		; B8 02 04  -- Map Mask reg, plane 2
		out	dx,ax			; EF
		mov	si,49Ah			; BE 9A 04
		mov	di,0EB2h		; BF B2 0E
		; The call+mov di below share overlapping bytes. The high byte
		; of the call rel16 (at 0x0380) doubles as the low byte of a word
		; "data_15 = 0BF00h" that is read elsewhere via "sub bp,data_15[bx]".
		db	0E8h, 03h		; call rel16 opcode + low byte (rel = 3)
data_15		dw	0BF00h			; rel16 high byte (00) | next instr opcode (BF)
		db	0FCh, 0Eh		; remainder of "mov di,0EFCh"

; --- copy_5_rows_2bytes: inline subroutine at 0x0384 ---
; Copies 5 sprite rows of 2 bytes each from DS:[si] to ES:[di] with 0x4E stride
; between rows (total row stride = 2+0x4E = 0x50 = 80 bytes = EGA planar row).

copy_5_rows_2bytes:
		mov	cx,5			; B9 05 00

row_copy_loop_23:
					movsb				; A4  -- Mov [si] to es:[di]
					movsb				; A4  -- Mov [si] to es:[di]
					add	di,4Eh			; 83 C7 4E
					loop	row_copy_loop_23	; E2 F9  -- Loop if cx > 0

		retn				; C3  -- at 038Eh; also phase 1-3 dispatch target -1
		                        ;* Unreachable retn at 0x038F (phase 4 dispatch target -1)
		retn				; C3  -- at 038Fh; phase 1-4 fall-through

; --- vga_chain4_decode: phase-5 handler at 0x03CF ---
; (Entry here reached via dispatch table target 0x03CF, falls into following block)

vga_chain4_decode:
		mov	ax,0A000h
		mov	es,ax
		mov	si,49Ah
		mov	di,3AC8h
		call	decode_5col_blit_loop
		mov	di,cs_dispatch_178

decode_5col_blit_loop		proc	near
		mov	cx,5

col_unpack_loop:
					push	cx
					push	di
					lodsb				; String [si] to al
					call	decode_4bit_unpack
					lodsb				; String [si] to al
					call	decode_4bit_unpack
					pop	di
					add	di,140h
					pop	cx
					loop	col_unpack_loop		; Loop if cx > 0

		retn

decode_5col_blit_loop		endp

decode_4bit_unpack		proc	near
		mov	cx,4

bit_spread_loop:
					xor	ah,ah			; Zero register
					add	al,al
					adc	ah,ah
					add	ah,ah
					add	ah,ah
					add	al,al
					adc	ah,ah
					add	ah,ah
					add	ah,ah
					or	es:[di],ah
					inc	di
					loop	bit_spread_loop		; Loop if cx > 0

		retn

decode_4bit_unpack		endp

; --- cga_scan_entry: alt entry; sets ES=B800h and calls mono_scan_loop ---
; Reached via dispatch (one of the jmp_tbl_decode_b targets lands here).

cga_scan_entry:
		mov	ax,0B800h
		mov	es,ax
		mov	di,66E4h
		mov	dh,0FFh
		call	mono_scan_loop
		mov	di,cs_dispatch_179
		xor	dh,dh			; Zero register

mono_scan_loop		proc	near
		mov	cx,5

mono_outer_loop:
					push	cx
					push	di
					xor	dl,dl			; Zero register
					mov	cx,4

mono_inner_loop:
								mov	al,es:[di]
								call	extract_bits
								stosb				; Store al to es:[di]
								loop	mono_inner_loop		; Loop if cx > 0

					pop	di
					add	di,2000h
					cmp	di,8000h
					jb	mono_row_continue			; Jump if below
					add	di,80A0h

mono_row_continue:
					pop	cx
					loop	mono_outer_loop		; Loop if cx > 0

		retn

mono_scan_loop		endp

; --- extract_bits: bitplane nibble merge ---
; Takes AL (packed byte), uses CS LUT at 0x0444 to map high/low nibbles
; to 4-pixel bytes.  DL = input mask (0xFF enables), DH = output-modify flag.
; Returns merged 8-pixel byte in AL; updates DL=0xFF if first write.

extract_bits		proc	near
		test	dl,0FFh
		jz	extract_do_merge		; Jump if zero
		retn

extract_do_merge:
		mov	ah,al
		mov	bl,ah
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		shr	bl,1			; Shift w/zeros fill
		xor	bh,bh			; Zero register
		mov	si,bx
		mov	al,byte ptr cs:[444h][bx]	; LUT: high nibble -> 4 pixels
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		mov	bl,ah
		and	bl,0Fh
		or	al,byte ptr cs:[444h][bx]	; LUT: low nibble -> 4 pixels
		or	si,si			; Zero ?
		jz	extract_check_dh		; Jump if zero
		retn

extract_check_dh:
		test	dh,0FFh
		jnz	extract_first_write		; Jump if not zero
		retn

extract_first_write:
		mov	al,ah
		mov	dl,0FFh
		retn

extract_bits		endp

; --- LUT at 0x0444: 4-bit nibble -> 4-pixel bitmap byte (16 entries) ---
; Used by extract_bits via "cs:[444h][bx]".

nibble_to_4px_lut	label	byte
		db	 00h, 04h, 05h, 05h, 04h, 05h
		db	 05h, 07h, 08h, 0Ch, 0Dh, 0Dh
		db	 0Ch, 0Dh, 0Dh, 0Fh

; --- unpack_nibble_stream: byte-stream decoder for compressed sprite data ---
; Reads a stream at DS:[SI], writes unpacked pixel runs to ES:[DI].
; Each byte has a high nibble (command) and low nibble (count-1):
;   hi == [0x497]  (dispatch_flag_1)   -> emit 0xAA (black/2bpp pattern)
;   hi == 0x40                         -> emit 0x00
;   hi == 0xD0 and [0x498] nonzero     -> emit 0xFF (all-on)
;   otherwise                          -> emit count 1 pixel
; Zero byte terminates the stream.

unpack_nibble_stream:
					lodsb				; String [si] to al
					or	al,al			; Zero ?
					jnz	unpack_dispatch		; Jump if not zero
					retn

unpack_dispatch:
					mov	ah,al
					and	ah,0F0h
					cmp	ah,byte ptr ds:[497h]	; dispatch_flag_1
					jne	unpack_check_40		; Jump if not equal
					and	al,0Fh
					mov	ah,al
					mov	al,0AAh			; emit 0xAA pattern
					jmp	short unpack_emit_run

unpack_check_40:
					cmp	ah,40h			; '@'
					jne	unpack_check_D0		; Jump if not equal
					and	al,0Fh
					mov	ah,al
					xor	al,al			; Zero register (emit zeros)
					jmp	short unpack_emit_run

unpack_check_D0:
					test	byte ptr ds:[498h],0FFh	; dispatch_flag_2 set?
					jz	unpack_single		; Jump if zero
					cmp	ah,0D0h
					jne	unpack_single		; Jump if not equal
					and	al,0Fh
					mov	ah,al
					mov	al,0FFh			; emit 0xFF (all-on)
					jmp	short unpack_emit_run

unpack_single:
					mov	ah,1			; default: single-pixel emit

unpack_emit_run:
								stosb				; Store al to es:[di]
								dec	ah
								jnz	unpack_emit_run		; Jump if not zero
					jmp	short unpack_nibble_stream
; --- Sprite graphics data block starting at 0x049B ---
; Compressed sprite/tilemap data read by unpack_nibble_stream above.
; Sourcer mis-decoded this as x86 instructions; actually it is pixel data.
;* No entry point to code -- data block (pixel runs)

sprite_data_start	label	byte
		db	 90h, 00h, 00h, 20h, 00h, 12h	; offsets 049B-04A0
		db	 00h,0ABh, 00h,0AFh, 00h,0A0h	; offsets 04A1-04A6
		db	 00h, 00h, 28h, 00h, 2Ah, 02h	; offsets 04A7-04AC
		db	0ABh, 02h,0BFh, 00h, 0Fh, 3Ah	; offsets 04AD-04B2
		db	 93h,0FFh,0FCh, 2Ah, 93h,0FFh	; offsets 04B3-04B8
		db	0FCh, 2Ah, 93h,0FFh,0FCh, 2Ah	; offsets 04B9-04BE
		db	 93h,0FFh,0FCh, 2Bh,0AFh, 80h	; offsets 04BF-04C4
		db	  3h,0E0h, 03h,0EBh,0FAh,0FFh	; offsets 04C5-04CA
		db	0FCh, 2Ah, 93h,0FFh,0FCh, 2Ah	; offsets 04CB-04D0
		db	 93h,0FFh,0FCh, 2Ah, 93h,0FFh	; offsets 04D1-04D6
		db	0FCh, 2Ah, 92h,0ACh,0EAh, 43h	; offsets 04D7-04DC
		db	0EAh,0A8h, 44h,0EAh,0A8h, 44h	; offsets 04DD-04E2
		db	0EAh,0A8h, 44h,0EAh,0A8h, 42h	; offsets 04E3-04E8
		db	0B0h, 28h, 0Ch, 0Eh, 42h,0EAh	; offsets 04E9-04EE
		db	0A8h, 44h				; offsets 04EF-04F0

; --- Sprite graphics data continues (was mis-labeled locloop_39) ---
; Sourcer placed a locloop_39 label here because it mis-decoded a nearby
; byte as a backward conditional jump. Actually this is pure sprite data.

sprite_data_row_0	label	byte
		db	0EAh, 0A8h, 44h, 0EAh, 0A8h	; jmp far ptr A8EA:44A8
		db	 44h,0EAh,0A8h, 43h,0ABh,0E8h
		db	0AFh,0FAh,0EFh,0E8h, 28h, 2Bh
		db	0AFh,0FAh,0FFh,0E8h, 28h, 3Eh
		db	0FAh,0AEh,0BBh,0E8h, 28h, 2Ah
		db	0AFh,0FAh,0FFh,0E8h, 28h, 3Ah
		db	 91h,0ECh,0C0h, 03h, 3Bh, 91h
		db	0AEh,0E8h, 28h, 2Ah,0AFh,0FAh
		db	 91h,0E8h, 28h, 3Ah, 91h,0FFh
		db	0AFh,0E8h, 28h, 3Fh,0AFh,0FAh
		db	 91h,0E8h, 28h, 7Bh,0AFh,0FAh
		db	 2Bh,0A8h,0BAh,0AFh,0FAh,0E2h
		db	0B8h, 3Ah,0FAh,0AFh, 91h,0E2h
		db	0B8h, 3Bh,0ABh,0BBh,0BAh,0E2h
		db	0B8h, 3Ah,0FAh,0AFh,0EAh,0E2h
		db	0B8h, 2Ah,0EAh,0EBh, 05h, 50h
		db	0EBh,0ABh, 91h,0E2h,0B8h, 3Ah
		db	0FAh,0AFh,0AFh,0E2h,0B8h, 2Fh
		db	0AFh, 91h,0FAh,0E2h,0B8h, 2Ah
		db	0FAh,0AFh,0AFh,0E2h,0B8h, 2Fh
		db	0FAh,0AEh, 2Ah,0F8h,0EAh,0EFh
		db	 91h,0CAh,0ACh, 2Bh,0ABh, 91h
		db	0FAh,0CAh,0ACh, 2Ah,0FEh,0AFh
		db	0ABh,0CAh,0ACh, 2Fh,0ABh, 91h
		db	0EBh,0CAh,0ACh, 2Ah,0BEh,0EAh
		db	 10h, 04h, 6Bh,0BAh,0EAh,0CAh
		db	0ACh, 2Fh, 92h,0FAh,0CAh,0ACh
		db	 2Ah,0FAh,0AFh, 91h,0CAh,0ACh
		db	 2Fh, 92h,0FAh,0CAh,0ACh, 2Ah
		db	0FBh,0ABh, 2Fh,0E8h,0EAh,0FAh
		db	 91h,0C8h, 2Ch, 2Ah, 92h,0AFh
		db	0C8h, 2Ch, 2Ah, 93h,0C8h, 2Ch
		db	 3Ah, 92h,0AEh,0C8h, 2Ch, 0Ah
		db	0ABh,0ECh, 10h, 34h, 3Bh,0EAh
		db	0A0h,0C8h, 2Ch, 3Ah,0BAh, 91h
		db	0AFh,0C8h, 2Ch, 2Ah,0AFh,0FAh
		db	 91h,0C8h, 2Ch, 3Ah,0BAh, 91h
		db	0AFh,0C8h, 2Ch, 2Ah,0AFh,0ABh
		db	 2Bh,0A8h,0EFh,0ABh,0A0h,0C8h
		db	0ECh, 2Bh,0A0h, 0Ah,0EAh,0C8h
		db	0ECh, 0Ah,0EAh,0ABh,0A0h,0C8h
		db	0ECh, 2Bh,0A0h, 0Ah,0AEh,0C8h
		db	0ECh, 02h,0A8h,0ECh, 11h, 74h
		db	 3Bh, 2Ah, 80h,0C8h,0ECh, 2Ah
		db	0E0h, 0Ah, 91h,0C8h,0ECh, 0Ah
		db	 91h,0AEh,0A0h,0C8h
data_20		db	0ECh			; Data table (indexed access)
		db	 2Bh,0A0h, 0Ah,0EAh,0C8h,0ECh
		db	 0Ah,0EAh,0FBh, 2Ah,0A8h, 92h
		db	 0Ah,0CAh,0ACh, 3Ah, 0Ah,0A0h
		db	0ABh,0CAh,0ACh, 20h, 92h, 8Ah
		db	0CAh,0ACh, 2Ah, 0Bh,0A2h, 91h
		db	0CAh,0ACh, 2Ah, 83h,0EAh, 17h
		db	0F4h, 6Bh, 82h,0B8h,0CAh,0ACh
		db	 2Ah, 0Ah,0A0h,0AEh,0CAh,0ACh
		db	 20h, 92h, 0Ah,0CAh,0ACh, 2Ah
		db	 0Ah,0A0h, 91h,0CAh,0ACh, 20h
		db	 92h, 2Ah,0E8h,0CAh,0A0h, 91h
		db	0E2h,0B8h, 28h, 91h, 0Ah, 0Ah
		db	0E2h,0B8h, 0Ah, 0Ah,0A0h, 91h
		db	0E2h,0B8h, 20h,0BAh, 0Ah, 0Ah
		db	0E2h,0B8h, 20h, 2Eh,0EBh, 05h
		db	 50h,0EBh,0A8h, 0Ah,0E2h,0B8h
		db	 20h,0A0h, 91h, 0Ah,0E2h,0B8h
		db	 2Ah, 0Ah,0A0h,0A0h,0E2h,0B8h
		db	 20h,0A0h, 91h, 0Ah,0E2h,0B8h
		db	 2Ah, 0Ah,0A3h, 2Bh,0A8h,0A0h
		db	 0Ah, 41h,0EBh,0E8h, 0Ah, 41h
		db	 91h,0A0h,0EBh,0E8h, 2Eh,0A0h
		db	 0Ah, 41h,0EBh,0E8h, 0Ah, 28h
		db	 91h,0EAh,0EBh,0E8h, 0Ah,0EAh
		db	0E0h, 80h, 03h, 2Bh, 91h,0A0h
		db	0EBh,0E8h, 2Ah, 91h, 41h,0A0h
		db	0EBh,0E8h, 41h,0A0h, 0Ah, 91h
		db	0EBh,0E8h, 0Ah,0EEh, 41h,0A0h
		db	0EBh,0E8h, 41h,0A0h, 0Ah, 2Ah
		db	0EAh,0EEh,0EFh,0ABh,0EAh,0A8h
		db	 3Eh,0FFh,0EEh,0EBh,0EAh,0A8h
		db	 3Fh,0EFh,0FAh,0BBh,0EAh,0A8h
		db	 3Bh,0FFh,0FFh,0FFh,0EAh,0A8h
		db	 3Fh,0FFh, 80h, 28h, 0Ch, 0Ah
		db	0FAh,0BFh,0EAh,0A8h, 3Fh,0EFh
		db	0FFh, 91h,0EAh,0A8h, 3Bh,0EFh
		db	0BBh,0BFh,0EAh,0A8h, 2Eh,0FBh
		db	0FBh,0AFh,0EAh,0A8h, 6Ah,0FBh
		db	0BBh,0ABh, 94h, 42h, 2Ah, 93h
		db	 42h, 2Ah, 93h, 42h, 2Ah, 93h
		db	 42h, 2Ah, 91h, 41h, 02h,0E0h
		db	 02h, 92h, 42h, 2Ah, 93h, 42h
		db	 2Ah, 93h, 42h, 2Ah, 92h,0EAh
		db	 42h, 2Ah, 93h,0EEh,0AEh,0EAh
		db	0AEh,0BEh,0FAh,0FAh,0BEh,0EEh
		db	0AFh,0FAh,0BEh,0EEh,0AFh,0FAh
		db	0BEh,0EEh,0AFh,0FAh,0BEh,0EEh
		db	0AFh,0FAh,0AEh,0EEh,0AFh,0FAh
		db	0BEh,0BEh,0AFh,0FAh,0BBh,0BEh
		db	0ABh,0FAh,0BBh,0BEh,0ABh,0FAh
		db	0BBh,0BEh,0AFh,0FAh,0BBh,0BEh
		db	0AFh,0FAh,0BBh,0BEh,0AFh,0FAh
		db	0BBh, 3Ah,0ABh,0BAh,0BAh, 00h
		db	 80h,0A8h, 02h, 80h, 42h, 20h
		db	 80h, 28h, 02h, 42h, 02h, 08h
		db	 20h, 80h, 43h, 28h, 0Ah, 28h
		db	 43h, 83h, 91h,0A8h, 0Ah,0A8h
		db	 28h, 43h, 02h, 80h, 2Ah, 02h
		db	'B *', 0Ah, 8, 'C', 8, 0Ah
		db	 80h, 42h, 02h, 80h, 2Ah, 02h
		db	 4Fh, 4Bh, 0Ah, 80h, 02h,0A0h
		db	 4Fh, 4Bh, 08h,0A0h, 02h,0E0h
		db	 42h, 03h, 80h, 44h, 0Eh, 0Ah
		db	 2Eh,0B8h, 49h,0A8h, 02h, 42h
		db	 88h,0A0h, 02h, 42h, 2Ah, 46h
		db	0A0h, 45h, 20h, 44h, 0Bh, 80h
		db	 0Ah, 20h, 20h, 80h, 4Ah, 38h
		db	 23h, 8Bh, 80h, 45h,0C0h, 42h
		db	 0Ah, 20h, 20h, 42h, 20h, 83h
		db	0A8h, 42h, 30h, 4Bh, 08h, 47h
		db	 02h, 08h, 30h, 41h,0E0h, 08h
		db	 42h, 08h, 45h, 08h, 0Eh,0A0h
		db	 20h, 44h, 02h, 23h, 48h, 38h
		db	0E2h, 42h, 20h, 41h, 02h, 46h
		db	 02h, 42h, 20h, 45h, 20h, 0Bh
		db	'A', 0Ch, ' ', 0Ah, 'D(E', 8, 0Ah
		db	0A0h, 20h, 44h, 02h, 02h, 42h
		db	 02h, 20h, 45h, 80h, 43h, 3Ah
		db	 44h, 02h, 41h, 02h, 44h, 38h
		db	 20h, 45h,0A0h, 08h, 28h, 41h
		db	 03h, 80h, 42h, 20h, 46h, 08h
		db	 20h, 80h, 45h, 8Ch, 42h, 02h
		db	 80h, 48h, 08h,0E0h, 41h, 22h
		db	 44h, 2Eh, 80h, 42h, 03h, 80h
		db	 41h,0C0h, 42h, 02h,0C0h, 41h
		db	 28h, 08h, 80h, 08h, 43h, 38h
		db	 46h, 02h, 41h, 80h
		db	43h
data_21		db	0Bh			; Data table (indexed access)
		db	 02h, 08h, 42h, 2Ah, 03h, 44h
		db	 80h, 38h, 42h, 20h, 42h, 0Eh
		db	 44h, 02h, 44h, 02h, 41h, 02h
		db	 43h, 20h, 02h
		db	20h
data_22		db	8			; Data table (indexed access)
		db	0C2h, 80h, 28h, 42h, 08h, 46h
		db	 02h, 45h,0B0h, 41h, 0Ah, 43h
		db	 0Eh, 44h,0A0h, 0Ah, 42h, 20h
		db	 41h, 2Ah, 02h
		db	 48h, 20h, 20h
data_23		dw	2844h			; Data table (indexed access)
		db	2
data_25		db	83h			; Data table (indexed access)
		db	 20h, 20h,0A0h, 0Ah, 43h, 08h
		db	 45h, 0Eh, 45h, 0Ah, 28h, 41h
		db	0EAh, 42h, 02h,0EAh, 02h, 42h
		db	 80h,0A8h,0A0h, 42h, 2Ah,0A0h
		db	 4Ah, 02h,0EEh, 45h,0A0h, 0Ah
		db	 08h, 41h, 2Eh, 20h,0A8h, 42h
		db	 02h, 41h, 22h, 28h, 43h, 20h
		db	 0Ah, 88h, 42h, 08h, 41h, 0Ch
		db	 45h, 0Ah, 80h, 02h,0A0h, 0Ah
		db	 80h, 43h, 20h, 41h, 91h
data_26		db	42h			; Data table (indexed access)
		db	 08h, 20h, 8Bh, 80h, 42h, 2Eh
		db	 08h, 0Bh,0A0h, 42h, 2Ah, 08h
		db	0B8h, 41h, 08h, 0Ah, 20h, 20h
		db	 42h, 02h, 41h, 02h, 08h, 43h
		db	 20h, 02h, 43h, 08h, 41h, 08h
		db	 45h, 2Ah,0A8h
		db	0Ah
data_27		db	0A8h			; Data table (indexed access)
		db	2
		db	8, 'C A(C "C', 8, 'A'
		db	 02h,0C0h, 42h, 08h, 08h,0A0h
		db	 20h, 20h, 02h, 20h, 20h, 4Ah
		db	 02h
		db	'C', 8, 'D G', 8, 'A', 8, 'C', 8, 'D'
		db	 02h, 47h, 02h, 41h, 08h, 08h
		db	 80h, 08h, 00h, 4Dh,0A3h,0EEh
		db	 33h,0A8h, 38h,0E2h,0A8h, 38h
		db	0FEh, 8Eh, 0Ah, 03h,0BEh, 13h
		db	0ABh, 11h, 0Ah,0EEh,0E8h,0BBh
		db	 8Ah, 0Eh, 12h,0A2h,0A8h, 11h
		db	0A2h, 11h,0E8h,0E2h,0AEh,0A2h
		db	 0Ah,0A8h, 11h, 23h,0B8h, 11h
		db	 2Eh, 8Ah,0A8h,0A2h, 2Ah,0A2h
		db	 0Eh,0A2h,0A2h,0A3h,0B8h,0AEh
		db	 28h,0ABh, 22h,0E2h, 2Ah, 22h
		db	 0Ah,0A3h,0A2h,0A3h,0ACh,0EAh
		db	0ACh,0CAh, 8Ah, 8Ah, 2Ah,0A2h
		db	 03h,0ABh,0A2h,0A3h, 11h,0B2h
		db	 11h,0CAh,0EAh, 8Ah,0FAh, 8Ah
		db	 03h,0E8h,0A2h,0A3h, 11h,0A2h
		db	 11h,0CBh, 11h,0A8h,0A8h, 8Ah
		db	 02h,0AEh,0EAh,0A8h,0EBh,0A3h
		db	0A8h, 88h, 11h,0A8h,0E8h, 8Ch
		db	 02h,0ABh,0EBh,0A8h,0EEh,0A3h
		db	 11h, 8Bh, 11h,0A8h,0A8h, 8Ch
		db	 41h,0EAh, 2Bh,0A8h,0EAh,0A3h
		db	 11h,0ABh, 11h,0A2h, 11h, 32h
		db	 41h,0EAh, 2Ah,0A8h,0EEh,0A3h
		db	 11h,0A8h,0ABh,0A2h,0A2h, 0Ah
		db	 41h, 11h, 3Ah,0A8h,0EAh,0A0h
		db	0A2h,0A8h, 11h,0A2h,0A2h, 0Bh
		db	 41h, 11h, 3Ah,0E8h,0EAh,0A3h
		db	 11h,0A8h, 11h, 8Bh,0A3h, 33h
		db	 41h, 3Ah, 3Ah,0A8h,0EAh,0A3h
		db	 11h,0A8h, 11h, 8Eh, 88h,0AFh
		db	 41h, 3Ah, 8Eh,0A8h,0EAh, 83h
		db	 11h, 88h, 11h, 8Eh, 8Ch,0ACh
		db	 41h, 2Ah, 8Eh,0ACh,0EAh, 23h
		db	0A8h,0A2h, 11h, 02h, 0Ch,0B3h
		db	 41h, 2Ah, 8Eh, 88h,0EAh, 80h
		db	 11h, 82h,0A8h, 8Fh, 8Ch,0CBh
		db	 41h, 0Eh, 8Eh,0A0h,0EAh, 23h
		db	0ABh, 22h,0A2h, 3Ah, 32h,0CAh
		db	 41h, 0Eh,0A2h, 88h,0E8h, 80h
		db	0A0h, 8Eh,0A8h, 88h, 32h,0B2h
		db	 41h, 0Ah, 2Eh, 20h,0EBh, 23h
		db	0A2h, 02h, 23h, 0Ah, 32h,0ACh
		db	 41h, 08h, 83h, 80h,0E8h, 03h
		db	0A8h, 0Eh, 8Ah, 30h, 32h,0ACh
		db	 41h, 02h,0ACh,0FBh, 3Ah,0A8h
		db	0EBh,0A3h,0EEh,0CFh, 82h,0B2h
		db	 41h, 0Ah, 11h,0AEh, 12h,0BAh
		db	0A2h,0BAh,0ABh,0A0h,0CBh, 41h
		db	 3Ah,0A8h,0BAh, 2Ah, 11h,0A2h
		db	 8Ah,0A8h, 11h, 88h,0CBh, 41h
		db	 2Ah,0A2h,0A8h, 11h, 8Bh, 22h
		db	 8Ah,0A8h, 11h,0A8h, 33h, 41h
		db	0E2h,0A2h
data_28		db	13h
		db	 8Ah, 11h,0A8h, 11h,0A2h, 2Fh
		db	 41h, 8Ah
data_29		dw	128Ah			; Data table (indexed access)
		db	0A8h
data_31		dw	138Ah			; Data table (indexed access)
		db	0A2h, 2Fh, 41h, 13h,0A2h, 28h
		db	 13h, 20h, 82h
		db	33h
data_32		db	41h			; Data table (indexed access)
		db	 2Ah, 13h,0A8h, 88h, 88h, 88h
		db	 88h, 08h, 0Bh, 41h, 2Ah, 20h
		db	 20h,0A2h,0A2h, 22h, 20h, 02h
		db	 41h, 08h,0CBh, 41h, 0Ah, 80h
		db	 08h, 46h, 32h, 11h, 41h, 02h
		db	 11h,0BBh
data_33		dw	0A8FBh			; Data table (indexed access)
		db	0AEh,0FAh,0ABh,0ABh,0C2h,0CBh
		db	 42h, 2Ah, 11h,0EBh, 11h,0BAh
		db	 13h, 0Bh,0A3h, 41h, 02h,0A8h
		db	 22h,0BAh, 2Ah,0CEh,0A3h, 12h
		db	0A3h,0A3h, 41h, 0Eh,0A2h,0BAh
		db	 11h, 2Ah, 82h,0A2h, 11h,0A8h
		db	 22h,0CBh, 41h, 3Ah, 2Ah,0ABh
		db	 12h, 83h, 8Eh, 8Ah,0A2h,0A2h
		db	0BBh, 41h, 28h,0BAh,0ABh, 2Ah
		db	 88h,0E8h,0EAh, 88h,0A2h, 22h
		db	0CAh, 41h,0E2h
data_34		db	0FAh
		db	0A2h, 2Eh, 80h,0EAh, 0Eh
data_35		db	88h			; Data table (indexed access)
		db	 11h, 83h,0A2h, 41h,0E2h,0A2h
		db	 22h, 11h, 83h
data_36		db	11h			; Data table (indexed access)
		db	0A3h,0A8h, 11h, 23h,0A3h, 41h
		db	0EAh,0B8h,0A2h,0ACh, 83h, 11h
		db	0A3h
data_37		db	0A8h			; Data table (indexed access)
		db	 11h,0A2h,0CBh, 41h, 0Ah, 22h
		db	 11h
data_38		dw	83A8h			; Data table (indexed access)
		db	 11h,0E0h, 3Ah, 11h, 22h,0ABh
		db	 41h, 03h, 12h,0A8h,0A3h, 11h
		db	0A3h, 8Eh,0EAh, 82h,0CBh, 41h
		db	 22h,0C2h, 11h,0ABh, 83h,0ABh
		db	0A3h,0A0h,0A2h, 23h,0A3h, 41h
		db	 08h, 8Bh, 2Ah, 11h,0A3h,0ABh
		db	0A3h, 12h, 83h,0A3h, 42h, 02h
		db	 0Ah, 11h, 83h, 11h,0A2h, 11h
		db	 8Ah, 22h,0CBh, 41h, 02h,0A0h
		db	 8Eh, 11h, 83h, 11h, 8Eh, 12h
		db	 82h,0EBh, 41h, 0Eh,0D2h, 22h
		db	 11h, 83h, 14h,0A2h,0CBh, 41h
		db	 3Ah,0ABh, 8Bh, 11h, 83h, 8Ah
		db	 12h,0A8h,0A3h,0A2h, 41h,0EAh
		db	0AFh, 80h,0EAh, 23h,0BAh, 2Ah
		db	 12h, 03h,0A3h, 03h, 11h,0AFh
data_39		db	0E2h			; Data table (indexed access)
		db	0A8h, 82h, 12h,0A2h,0A8h, 22h
		db	0CBh, 03h,0ABh,0FAh, 8Eh,0A8h
		db	 23h, 8Ah, 11h,0A2h, 8Ah, 22h
		db	0ABh, 0Eh,0ABh,0A0h,0FAh,0A2h
		db	 83h,0BAh,0ABh, 12h, 82h,0C8h
		db	 0Eh, 11h,0CFh, 8Ah,0A2h, 0Bh
		db	 11h, 2Ah, 2Ah, 11h, 23h,0A2h
		db	 0Eh, 11h, 3Ah, 2Ah, 11h, 83h
		db	 8Ah, 11h, 8Ah, 2Ah, 83h,0A3h
data_40		db	0Eh
		db	0A0h,0E8h, 11h,0A8h,0A3h, 12h
		db	0A2h, 11h, 02h,0CAh, 3Ah, 83h
		db	0C8h, 11h,0BAh, 83h, 8Ah,0A8h
		db	0A2h,0A2h,0A2h,0ABh, 3Ah,0A2h
		db	 82h, 2Ah, 88h,0A2h,0BAh,0ABh
		db	 8Ah, 11h, 22h,0CBh, 3Ah, 82h
		db	 2Eh, 3Ah, 2Ah, 02h, 11h, 8Ah
		db	 12h,0A3h,0A3h, 3Ah, 20h, 11h
		db	 2Ah, 11h, 83h, 11h,0BAh, 11h
		db	 22h, 03h,0A2h, 3Ah, 82h,0EEh
		db	0EAh, 8Eh,0A3h, 14h, 82h,0CBh
		db	 3Ah, 20h,0EAh,0BAh, 2Ah, 80h
		db	 13h, 2Ah, 22h,0ABh, 38h, 80h
		db	0BAh, 12h, 20h,0BAh, 12h, 88h
		db	 22h,0CBh, 3Ah,0C0h, 3Bh,0BAh
		db	 11h, 83h, 13h, 88h,0A3h,0A2h
		db	 41h, 08h, 3Eh, 12h, 83h,0BAh
		db	 12h,0A2h, 03h,0A3h, 41h, 22h
		db	 3Bh,0AEh,0EAh, 23h,0BAh,0EAh
		db	0AEh,0A8h, 22h,0CBh, 41h,0C8h
		db	 3Eh, 12h, 80h, 13h, 8Ah, 22h
		db	0ABh, 03h,0A2h, 0Bh,0AEh, 11h
		db	 20h,0BAh, 12h,0A8h, 02h,0C8h
		db	 02h,0A8h, 8Eh, 11h,0AEh, 83h
		db	0BAh, 13h, 23h,0A2h, 0Ah,0BAh
		db	 0Eh,0EAh, 11h, 0Bh,0BAh,0EAh
		db	 11h, 20h, 03h,0A3h, 41h, 11h
		db	 8Ah, 12h, 83h,0BAh, 12h, 8Ah
		db	 02h,0CAh, 41h, 0Ah, 0Eh,0BAh
		db	 11h, 20h, 13h,0A0h, 02h,0ABh
		db	 41h, 02h,0BAh, 11h,0BAh, 83h
		db	0BAh, 12h, 8Ah, 22h,0CBh, 03h
		db	0FAh,0CBh, 12h, 20h,0BAh,0ABh
		db	0ABh,0A8h, 23h,0A3h, 0Eh,0EAh
		db	0CEh, 12h, 41h, 13h, 22h, 03h
		db	0A2h, 0Eh,0BAh,0EEh,0EAh, 11h
		db	 83h,0BEh,0BAh, 11h, 88h, 02h
		db	0CBh, 03h, 11h,0EAh, 11h,0AEh
		db	 03h,0BAh, 11h,0BAh, 22h, 22h
		db	0ABh, 02h,0EBh, 2Eh, 11h,0EAh
		db	 80h,0BAh, 12h, 88h, 22h,0CBh
		db	 41h,0ABh, 2Ah, 12h, 41h,0BAh
		db	 12h, 22h, 22h,0CBh, 41h,0EBh
		db	 3Bh, 11h, 80h, 03h,0BAh, 12h
		db	 88h,0A3h,0A2h, 41h, 11h, 2Eh
		db	0BAh, 20h, 03h,0EAh, 12h,0A2h
		db	 03h,0A3h, 41h,0EBh, 3Bh,0A8h
		db	 41h, 08h, 12h,0A0h,0A8h, 22h
		db	0CBh, 41h,0ABh, 2Eh, 20h, 41h
		db	 23h,0EAh,0A0h,0FFh,0F0h, 11h
		db	0ABh, 41h,0A8h, 88h, 80h, 08h
		db	 88h, 11h, 0Fh,0FEh,0EEh,0F2h
		db	0ABh, 02h,0A0h, 20h, 41h, 22h
		db	 23h,0A8h,0FBh,0FAh,0BBh,0BBh
		db	 2Ah, 0Ah, 02h, 41h, 08h, 88h
		db	 8Bh,0ABh,0EEh,0EEh,0EAh,0AEh
		db	 8Bh, 08h, 41h, 22h, 02h, 22h
		db	 22h,0AFh,0BBh, 11h,0AEh,0ABh
		db	0A2h, 42h, 80h, 88h, 88h, 8Fh
		db	0EFh, 11h,0EAh,0BAh, 11h,0A3h
		db	 41h, 02h, 22h, 22h, 23h,0FAh
		db	 8Fh, 13h,0BAh,0A3h, 42h, 88h
		db	 88h,0FFh, 11h, 8Eh,0EAh, 13h
		db	 83h, 41h, 02h,0A2h, 3Fh,0BAh
		db	 11h, 8Fh, 13h,0BAh,0A3h, 41h
		db	 03h, 8Fh,0EAh,0BEh, 8Eh, 8Eh
		db	 13h,0EAh,0A2h, 41h, 03h, 3Ah
		db	 11h,0AEh,0A3h, 8Fh, 14h, 83h
		db	 41h, 03h,0BAh, 13h, 0Eh, 14h
		db	 82h, 41h, 02h, 3Ah, 12h,0A8h
		db	0CEh, 14h, 23h, 41h, 0Eh,0EAh
		db	 13h, 8Eh, 14h,0A3h, 41h, 3Ah
		db	0E0h, 12h,0A8h, 0Eh, 14h,0A3h
		db	 03h,0FFh,0ABh, 8Eh, 11h, 80h
		db	 2Eh, 14h,0A2h, 0Eh, 12h,0A0h
		db	0E8h, 02h, 2Eh,0A3h, 13h, 83h
		db	 0Eh, 11h,0EAh,0BAh, 80h, 22h
		db	 82h, 8Bh, 13h,0A3h, 0Eh, 13h
		db	 3Bh,0CAh, 2Ah, 8Bh, 13h, 83h
		db	 0Eh, 12h,0A8h,0EAh,0BCh,0AEh
		db	 8Eh, 11h,0AEh, 11h,0A3h, 0Eh
		db	 12h,0A0h, 11h,0ABh,0EEh, 14h
		db	0A3h, 0Eh, 11h,0BAh, 8Eh, 2Ah
		db	 11h, 8Eh, 14h,0B3h, 41h, 11h
		db	0A8h, 3Ah, 8Eh, 11h, 8Eh, 12h
		db	0ABh, 11h,0A2h, 0Ah, 2Ah, 11h
		db	0EEh, 8Eh, 11h, 82h,0BAh, 13h
		db	0A3h, 0Ah, 2Ah, 12h,0BAh, 11h
		db	 0Eh, 14h,0A3h, 02h, 8Ah, 14h
		db	 82h, 14h, 82h, 0Ah, 8Ah, 11h
		db	0EAh, 11h,0A2h, 8Eh, 14h, 82h
		db	 0Ah,0EAh,0BAh,0ABh, 11h, 08h
		db	 0Eh,0ABh, 13h,0A3h, 0Bh, 13h
		db	0A2h, 80h, 2Eh, 14h,0A3h, 0Eh
		db	 13h, 80h, 02h,0AEh, 13h, 2Ah
		db	 83h, 0Eh, 13h, 41h, 2Ah, 2Eh
		db	 14h,0A3h, 0Eh, 12h,0A2h,0ABh
		db	0C8h, 8Eh, 14h,0A2h, 0Eh, 11h
		db	0EAh,0AEh, 11h,0BEh, 2Ah, 14h
		db	 83h, 0Eh, 14h,0ABh,0CEh, 14h
		db	0A3h, 0Eh, 15h, 8Eh, 14h,0A3h
		db	 0Eh, 15h, 8Ah, 12h, 2Ah, 11h
		db	 83h, 0Eh, 11h,0BAh, 13h, 0Ah
		db	 12h,0EAh, 11h, 83h, 0Eh, 14h
		db	0A8h, 8Ah, 14h, 83h, 0Eh, 13h
		db	0A8h, 11h, 8Eh, 14h,0A2h, 41h
		db	0A0h,0A2h, 2Ah, 22h, 08h, 0Ah
		db	 14h, 83h, 46h, 0Eh, 14h, 83h
		db	 41h, 02h, 22h, 22h, 02h, 41h
		db	 0Eh, 13h,0A2h, 02h, 42h, 88h
		db	 88h, 88h, 41h, 0Eh, 12h,0A2h
		db	 88h, 82h, 42h, 11h,0A2h, 22h
		db	 20h, 0Eh, 13h, 22h, 0Fh, 41h
		db	 02h, 2Ah,0A8h, 88h, 88h, 0Ch
		db	 44h, 0Fh, 41h, 02h, 13h, 22h
		db	 03h,0FFh,0FEh,0FBh,0A8h, 0Bh
		db	 41h, 02h, 13h, 88h, 03h, 13h
		db	0A2h, 0Bh, 41h, 3Fh,0FFh,0F3h
		db	0FFh,0FFh,0CEh, 2Ah, 11h,0A8h
		db	 80h, 23h, 41h,0EAh, 11h, 8Eh
		db	 12h, 8Eh, 2Ah, 11h, 82h, 20h
		db	 23h, 03h, 12h, 8Eh,0BAh, 11h
		db	 8Fh, 44h, 83h, 03h, 12h, 8Fh
		db	0EAh, 11h,0BEh, 14h, 02h, 03h
		db	 8Ah, 11h, 8Eh, 12h,0EAh, 12h
		db	0ABh, 11h, 83h, 03h, 12h, 8Eh
		db	 11h,0ABh, 11h, 2Ah, 12h,0BAh
		db	 83h, 03h, 12h, 8Eh, 11h,0ABh
		db	0A8h, 14h,0A3h, 03h, 11h,0A3h
		db	 8Eh, 11h,0AEh,0A2h, 12h,0EAh
		db	 11h,0A3h, 03h, 11h,0AEh, 8Eh
		db	 11h,0AEh,0A3h, 11h, 2Ah, 11h
		db	0A2h,0A3h, 03h, 12h, 8Eh, 11h
		db	0AEh, 83h, 11h,0A8h, 12h,0E3h
		db	 03h, 12h, 8Eh, 11h,0AEh,0A3h
		db	0A8h,0EAh, 3Ah, 0Eh,0A3h, 03h
		db	 12h, 80h, 11h,0AEh, 83h,0A8h
		db	0EAh, 3Ah, 0Eh,0A2h, 03h,0A2h
		db	 11h, 82h,0EAh,0ACh,0A3h, 28h
		db	0EAh, 3Ah, 8Eh,0A2h, 03h, 12h
		db	 82h,0EAh,0AEh, 83h, 88h,0CAh
		db	 3Ah, 8Ch,0A3h, 03h, 12h, 82h
		db	0EAh,0ACh, 03h,0A8h,0E8h, 32h
		db	 8Eh, 83h, 03h, 12h, 8Fh, 11h
		db	 2Ah, 0Bh, 20h,0CAh, 3Ah, 0Ch
		db	0A2h, 03h, 11h,0A3h, 8Fh, 11h
		db	 8Ah,0ABh,0A0h,0E8h, 3Ah, 0Ch
		db	0A3h, 03h, 11h, 8Eh, 8Eh, 11h
		db	 8Eh, 8Fh, 28h,0E8h, 38h, 8Eh
		db	 83h, 03h,0A0h, 3Ah, 8Eh, 11h
		db	 30h, 0Fh,0A0h,0E2h, 3Ah, 0Eh
		db	 23h, 41h, 0Ch,0EAh, 8Eh,0A8h
		db	0A3h, 8Fh,0A0h,0E8h, 32h, 0Eh
		db	 82h, 03h, 11h, 0Eh, 8Eh,0A8h
		db	0CEh, 8Fh, 80h,0E0h, 30h, 8Eh
		db	 03h, 03h, 11h,0A3h, 8Eh,0A3h
		db	 11h, 0Eh,0C2h,0B0h, 8Ch, 2Bh
		db	 0Bh, 03h, 12h, 0Eh, 12h, 8Eh
		db	 12h, 8Eh, 11h,0A2h, 03h, 12h
		db	 8Eh, 12h, 0Eh, 12h
data_41		db	0Eh			; Data table (indexed access)
		db	11h
data_42		db	0A2h
		db	 03h, 12h, 8Eh, 12h, 0Eh, 12h
		db	 8Eh, 11h, 83h, 03h, 12h, 0Eh
		db	 12h, 8Eh, 12h, 0Eh, 11h,0A3h
		db	 03h, 11h,0A2h, 0Eh, 12h, 0Eh
		db	 12h, 0Eh, 11h, 83h, 03h, 12h
		db	 8Eh, 11h,0A8h, 0Eh, 12h, 8Eh
		db	 11h, 23h, 41h, 8Ah,0A2h, 0Eh
		db	 11h, 8Ah, 0Eh, 11h, 88h, 0Eh
		db	0A8h, 03h, 41h, 22h, 08h, 0Ah
		db	 82h, 20h, 0Eh, 88h, 20h, 0Eh
		db	 82h, 02h, 4Bh, 0Ah, 41h, 0Eh
		db	 17h,0A0h, 41h,0A2h, 41h,0FAh
		db	 18h, 20h,0CAh, 03h, 19h, 88h
		db	 3Ah, 0Eh, 15h,0A8h,0A0h,0A2h
		db	 22h, 20h, 0Eh, 0Fh,0FFh,0EAh
		db	0CBh,0EBh,0EEh,0EEh,0BAh,0BAh
		db	0BEh, 11h,0BEh, 0Eh, 12h,0A3h
		db	 11h,0BAh,0B8h,0A8h, 11h,0EAh
		db	 82h,0A2h, 0Eh, 12h,0A3h, 14h
		db	 22h,0AEh, 2Ah, 82h, 0Eh, 12h
		db	0A8h, 12h,0A3h, 88h,0E2h, 11h
		db	 3Ah,0A2h, 0Eh, 11h,0A8h,0A8h
		db	0EAh, 11h, 0Eh,0A8h,0EAh,0A8h
		db	 22h, 82h, 0Eh, 12h,0A8h,0EAh
		db	0A8h,0E3h,0A3h, 11h, 20h, 3Ah
		db	0A2h, 0Eh, 13h, 0Ah,0A8h,0E8h
		db	 8Eh,0A0h, 0Ah, 8Ah,0A2h, 0Eh
		db	 13h,0A0h,0E3h, 11h, 3Ah, 0Eh
		db	0A3h, 11h,0A2h, 0Eh, 12h, 2Ah
		db	 8Eh, 33h, 11h, 28h,0EAh, 83h
		db	0A8h, 02h, 0Eh, 12h, 38h, 2Ah
		db	 22h, 11h, 83h, 11h,0A2h,0A3h
		db	 82h, 02h, 11h,0ABh, 83h, 8Eh
		db	 8Ah, 13h, 8Eh,0A2h, 82h, 41h
		db	 12h, 3Ah,0A2h, 8Ah, 11h, 82h
		db	 11h, 8Eh, 11h, 22h, 03h, 11h
		db	0ABh, 11h,0A3h,0A3h,0A8h, 28h
		db	 11h, 23h, 11h, 82h, 02h, 13h
		db	 8Ch,0A3h, 03h, 8Bh,0A2h,0A8h
		db	0EAh, 22h, 0Eh, 12h, 8Ah, 2Ah
		db	0A8h,0EAh, 8Bh,0AEh, 11h, 3Ah
		db	 82h, 0Eh, 11h, 2Ah, 8Ah, 11h
		db	0A2h, 11h,0AEh, 12h, 3Ah, 02h
		db	 0Eh,0ACh, 28h, 8Ah, 11h,0A3h
		db	 11h,0ABh,0AEh, 2Ah, 2Ah, 82h
		db	 0Eh,0A8h,0A8h, 8Ah, 13h,0ABh
		db	0A2h, 2Ah, 8Eh, 22h, 03h,0A8h
		db	 11h, 2Ah, 13h,0AEh,0A2h, 2Ah
		db	 8Eh, 82h, 0Eh, 12h, 8Ah, 11h
		db	 2Ah, 11h,0BAh, 11h, 2Ah, 3Ah
		db	 02h, 0Eh, 11h,0A2h, 12h, 2Ah
		db	0AFh,0FAh,0AEh, 2Ah,0A8h, 82h
		db	 0Eh, 11h,0AEh, 2Ah, 11h, 2Eh
		db	0BAh, 12h, 8Ah,0A2h, 02h, 03h
		db	 12h, 2Ah,0ABh,0FBh,0EAh, 11h
		db	0AEh, 8Ah,0A8h, 02h, 03h,0A8h
		db	 11h, 8Ah, 13h, 82h, 8Ah, 0Ah
		db	 22h, 02h, 0Eh,0A8h, 2Bh, 8Ah
		db	0ABh, 8Ah, 8Ah, 88h,0BAh, 8Ah
		db	 88h, 02h, 0Eh,0B8h,0ABh, 8Ah
		db	0AEh, 0Ah,0EEh, 2Ah,0E2h, 02h
		db	 22h, 02h, 0Eh,0A8h,0BAh, 82h
		db	0A8h, 8Bh,0A2h,0A8h, 11h, 80h
		db	 08h, 02h, 0Eh,0B8h, 11h,0A2h
		db	 3Ah, 03h, 88h,0BAh,0A2h, 20h
		db	 22h, 02h, 0Eh,0A8h,0BAh, 82h
		db	 3Ah, 88h,0A0h,0CAh, 02h, 88h
		db	 41h, 02h, 0Eh,0ACh,0ABh, 28h
		db	 11h, 0Ah, 28h,0E2h, 02h, 88h
		db	 22h, 02h, 0Eh,0A8h, 2Bh, 88h
		db	0E8h, 82h, 82h,0CAh, 8Ah, 20h
		db	 80h, 02h, 0Eh,0B8h, 0Ah, 08h
		db	0EAh, 08h, 8Ah,0A8h,0A2h, 28h
		db	 02h, 02h, 0Eh,0EAh, 08h, 8Eh
		db	0A8h,0A3h, 08h, 82h, 88h, 08h
		db	 80h, 02h, 0Eh, 11h,0A2h, 22h
		db	 22h, 02h, 02h, 22h, 20h, 22h
		db	 41h, 02h, 0Eh, 08h, 88h, 0Ah
		db	 82h, 20h, 02h, 08h, 08h, 42h
		db	 02h, 00h, 1Dh,0ABh,0E2h,0BBh
		db	 11h,0BAh,0EAh,0A2h,0BAh,0FEh
		db	0AEh,0A0h,0ABh,0BEh, 13h,0ABh
		db	 11h, 08h,0EEh,0E8h,0BBh,0A0h
		db	0ACh, 12h,0A2h,0A8h, 11h,0A2h
		db	0A8h,0E8h,0E0h, 2Eh,0A0h, 11h
		db	0A8h
data_43		db	2Ah			; Data table (indexed access)
data_44		dw	3820h			; Data table (indexed access)
		db	 0Ah, 0Eh, 8Ah,0A8h,0A0h
data_45		db	0Ah
		db	0A0h,0A0h, 20h, 22h, 41h, 38h
		db	 0Eh, 08h, 83h,0A0h,0E2h, 22h
		db	 20h,0A0h, 20h, 22h, 20h, 0Ch
		db	 0Ah, 0Ch,0C2h, 80h, 82h
data_46		db	28h			; Data table (indexed access)
		db	0A0h,0A8h, 80h, 20h,0A0h, 41h
		db	 30h, 08h,0C0h, 41h, 82h, 30h
		db	 80h,0A8h,0E0h, 20h,0A0h, 41h
		db	 20h, 41h,0C0h, 02h, 08h, 20h
		db	 80h,0A8h, 0Ch, 20h, 28h, 03h
data_47		dw	4120h
data_49		db	80h			; Data table (indexed access)
		db	 02h, 08h,0C0h, 80h,0A8h, 28h
		db	 03h, 08h, 0Eh, 80h, 41h, 80h
		db	 20h, 08h, 88h, 80h, 11h, 22h
		db	 23h, 08h, 02h, 41h, 20h, 80h
		db	 22h, 02h, 2Ah, 41h, 11h, 02h
		db	 22h, 42h, 20h, 42h, 03h, 02h
		db	 02h, 41h, 11h, 02h, 02h, 42h
		db	 20h, 42h, 02h, 41h, 22h, 41h
		db	 11h, 41h, 02h, 41h, 20h, 41h
		db	 20h, 20h, 20h, 43h, 11h, 80h
		db	 43h, 80h
		db	41h
data_50		dw	4280h			; Data table (indexed access)
		db	 08h, 41h, 11h, 80h, 44h
data_51		dw	820h			; Data table (indexed access)
		db	 08h, 41h
data_53		dw	4180h			; Data table (indexed access)
		db	 11h, 80h, 42h, 08h, 20h, 41h
		db	 20h, 20h, 02h, 41h, 30h, 11h
		db	 80h
		db	 42h, 08h, 42h
data_55		db	80h
		db	20h
data_56		dw	4103h			; Data table (indexed access)
		db	0C8h, 11h,0A0h, 43h
data_57		db	20h			; Data table (indexed access)
		db	 41h, 20h, 41h, 02h, 41h, 02h
		db	 11h,0A0h, 43h, 80h, 41h, 80h
		db	 08h, 80h, 41h, 30h, 11h
data_58		dw	42A0h			; Data table (indexed access)
		db	 03h, 20h, 02h, 41h, 23h, 0Ah
		db	 41h, 20h, 11h,0A0h, 42h, 08h
		db	 41h, 28h, 41h, 8Ah, 42h,0ACh
		db	 11h,0A8h,0A0h, 38h, 3Ah,0A8h
		db	 2Bh,0A0h, 2Eh, 41h, 82h, 80h
		db	 13h,0AEh, 12h,0BAh,0A2h,0BAh
		db	0A3h,0A0h, 08h, 11h,0BAh,0A8h
		db	0BAh, 2Ah, 11h,0A0h, 80h, 08h
		db	 41h, 88h, 41h, 12h,0A0h, 08h
		db	 02h, 8Bh, 20h, 80h, 08h, 41h
		db	 20h, 41h, 11h,0E2h,0A0h, 42h
		db	 0Ah, 80h, 80h, 08h, 43h, 11h
		db	 80h, 80h, 42h, 08h, 80h, 41h
		db	 08h, 42h, 20h, 11h, 41h, 80h
		db	 42h, 08h, 42h, 08h, 43h, 11h
		db	 80h, 46h, 08h, 43h, 11h, 80h
		db	 4Ah, 11h,0A0h
		db	4Ah
data_59		db	11h
		db	0A8h, 42h, 38h,0A8h,0AEh,0FAh
		db	0ABh,0A3h, 41h, 08h, 13h, 8Ah
		db	0EBh, 11h,0BAh, 13h, 42h, 12h
		db	0A8h, 22h,0B2h, 0Ah,0C2h,0A3h
		db	 11h, 2Ah, 42h, 11h,0AEh,0A0h
		db	 32h,0A2h, 02h, 80h,0A2h, 11h
		db	0A8h, 41h, 08h, 11h,0BAh, 20h
		db	 2Bh,0A0h, 0Ah, 80h, 8Eh, 8Ah
		db	0A0h, 80h,0B8h, 11h,0A8h, 32h
		db	 0Bh, 20h, 88h,0C8h, 0Ah, 88h
		db	 20h, 02h, 08h, 11h, 20h, 3Ah
		db	0A2h, 41h, 80h,0CAh, 41h, 88h
		db	 41h, 80h, 41h, 11h, 20h, 22h
		db	 22h, 02h, 80h, 88h, 41h, 08h
		db	 02h, 42h, 11h, 02h,0B8h, 41h
		db	 0Ch, 80h, 80h, 41h, 08h, 02h
		db	 02h, 41h, 11h, 82h, 22h, 41h
		db	 08h, 80h, 80h,0C0h, 41h, 02h
		db	 02h, 80h, 11h, 83h, 22h, 41h
		db	 08h, 80h, 02h,0A0h, 02h,0E0h
		db	 02h, 08h, 11h, 82h, 42h, 80h
		db	 80h, 03h, 80h, 41h,0A0h, 42h
		db	 11h,0A0h, 88h, 42h, 80h, 03h
data_60		dw	0A41h			; Data table (indexed access)
		db	0A8h, 41h, 20h, 11h,0A8h, 02h
		db	 41h, 80h, 41h, 02h, 41h, 0Ah
		db	 88h, 41h, 08h, 11h,0A8h,0A0h
		db	 80h, 80h, 42h, 80h, 02h, 20h
		db	 41h,0E0h, 11h,0A2h, 3Ah, 20h
		db	0A2h, 80h, 08h, 45h, 11h,0B8h
		db	0FBh, 88h, 02h, 80h, 0Ah, 80h
		db	 42h, 20h, 41h, 11h,0E0h,0EFh
		db	 80h, 08h, 41h, 3Ah, 45h,0A8h
		db	0A0h,0A0h, 02h, 28h, 41h, 2Ah
		db	 88h, 20h, 41h, 20h, 41h,0A8h
		db	 41h, 02h, 82h, 28h, 41h, 0Ah
		db	 80h, 20h, 41h, 20h, 41h,0A0h
		db	 41h, 20h,0FAh,0A0h, 41h, 3Ah
		db	 03h, 41h,0A0h, 42h,0A2h, 02h
		db	 0Fh, 80h,0A0h, 41h, 28h, 02h
		db	 41h,0A0h, 20h, 41h,0AEh, 0Ah
		db	 3Ah, 20h, 28h, 41h, 08h, 41h
		db	 80h, 43h,0ACh, 41h,0E8h, 20h
		db	 08h, 41h, 08h, 80h,0A0h, 0Ah
		db	 42h, 88h, 41h,0C8h, 20h, 08h
		db	 41h, 0Ah, 41h,0A0h, 43h, 88h
		db	 22h, 82h, 22h, 88h, 41h, 32h
		db	 41h, 80h, 02h, 20h, 41h, 80h
		db	 02h, 02h
		db	'A', 8, 'A"B  A'
		db	0B8h, 20h, 02h, 43h, 02h, 41h
		db	 0Ah, 02h, 42h,0B8h, 42h, 02h
		db	 80h, 41h, 08h, 41h, 0Ah, 43h
		db	 88h, 20h, 41h, 02h, 42h, 08h
		db	 0Ah, 02h, 41h, 20h, 41h, 80h
		db	 41h, 02h, 44h, 0Ah, 20h, 43h
		db	 82h, 42h, 0Ah, 28h, 42h, 20h
		db	 44h, 80h, 42h, 02h, 28h, 80h
		db	 41h, 20h, 44h, 11h, 02h, 43h
		db	 20h, 42h, 0Ch, 41h, 20h, 41h
		db	 11h, 42h, 20h, 42h, 02h, 20h
		db	 0Ah, 02h, 42h,0A8h, 02h, 41h
		db	 20h, 41h, 20h, 02h, 0Ah, 08h
		db	 28h, 42h, 11h, 43h, 02h, 42h
		db	 08h, 41h, 02h, 20h, 41h,0A8h
		db	 30h, 42h, 02h, 08h, 02h, 45h
		db	0A0h,0A0h, 41h, 0Ah, 08h, 41h
		db	 02h, 42h, 08h, 42h, 11h, 08h
		db	 41h, 0Ah, 0Ah, 20h, 02h, 08h
		db	0A0h, 43h, 11h,0A0h, 42h, 08h
		db	 80h, 42h,0A0h, 02h, 20h, 41h
		db	0A8h, 42h, 20h, 02h, 20h, 42h
		db	 03h, 08h, 20h, 41h,0A0h,0E2h
		db	 42h, 20h, 44h, 02h, 42h,0A0h
		db	 8Ah, 42h, 20h, 80h, 41h, 02h
		db	 41h, 08h, 42h,0A8h, 08h, 41h
		db	 08h, 44h, 30h, 02h, 20h, 41h
		db	0A8h, 43h, 02h, 42h, 20h, 41h
		db	 88h, 20h, 41h, 11h, 42h, 82h
		db	 02h, 41h, 02h, 42h, 02h, 20h
		db	 41h, 11h, 08h, 41h, 20h, 43h
		db	 22h, 44h, 11h, 02h, 02h, 02h
		db	 43h, 02h, 44h, 11h, 42h, 28h
		db	 41h, 08h, 0Ah, 08h, 44h, 11h
		db	 08h, 41h, 20h, 41h, 20h, 0Ah
		db	 45h, 11h, 28h, 80h, 80h, 41h
		db	 08h, 43h, 02h, 42h,0A8h,0A0h
		db	 20h, 41h, 20h, 20h, 41h,0F0h
		db	 41h, 08h, 88h, 41h,0A2h, 42h
		db	 08h, 08h, 88h, 23h, 42h, 02h
		db	 02h, 80h,0A0h, 41h, 22h, 41h
		db	 20h, 41h,0AFh, 42h, 0Eh, 41h
		db	 20h, 11h,0A8h, 80h, 41h, 80h
		db	 41h, 0Ch, 41h, 08h, 38h, 20h
		db	 20h, 11h,0A8h, 20h, 22h, 03h
		db	0C2h, 80h, 42h, 08h, 30h, 20h
		db	 11h,0A8h, 41h, 08h,0F3h, 80h
		db	 80h, 02h, 41h, 20h, 08h, 80h
		db	 11h,0A8h, 80h, 41h, 30h, 80h
		db	 41h, 08h, 20h, 20h, 38h, 20h
		db	 11h,0A8h, 42h, 3Ch, 42h, 28h
		db	 42h,0E0h, 41h, 11h,0A8h, 41h
		db	 20h, 0Ch, 42h, 20h, 41h, 80h
		db	0A0h, 41h, 11h,0A8h, 08h, 28h
		db	 0Ah, 42h, 20h, 41h, 80h, 20h
		db	 41h, 11h,0A8h, 41h, 20h, 02h
		db	 42h, 08h, 08h, 08h, 08h, 41h
		db	 11h,0A0h, 42h,0A0h, 22h, 80h
		db	 42h, 08h, 42h, 11h, 82h, 43h
		db	 28h, 46h,0A8h, 43h, 0Ah, 80h
		db	 02h, 80h, 41h, 82h, 02h, 41h
		db	0A0h, 43h, 28h, 41h, 22h, 80h
		db	 44h,0A0h, 44h, 02h, 80h, 43h
		db	 20h, 41h,0A0h, 20h, 02h, 42h
		db	 08h, 20h, 42h, 20h, 80h, 41h
		db	0A0h, 41h, 20h, 42h, 80h,0A2h
		db	 41h, 20h, 0Eh, 80h, 41h,0A0h
		db	 80h, 42h, 08h,0A8h, 20h, 42h
		db	 0Ah, 42h,0A0h, 80h, 43h, 2Ah
		db	 41h, 02h, 41h, 22h, 41h, 30h
		db	0A0h, 02h, 80h, 42h, 28h, 43h
		db	 03h, 80h, 20h,0A0h, 41h, 80h
		db	 42h, 02h, 41h, 02h, 42h, 80h
		db	 20h,0A0h, 44h, 08h, 42h, 20h
		db	 08h, 02h, 41h,0A0h, 42h, 20h
		db	 80h, 28h, 82h, 41h, 20h, 08h
		db	 42h,0A0h, 02h, 42h, 08h, 02h
		db	 82h, 80h, 44h,0A0h, 41h, 08h
		db	 80h, 41h, 08h, 02h, 42h, 02h
		db	 41h, 20h,0A0h, 41h, 08h, 20h
		db	 02h, 80h, 45h, 20h,0A0h, 08h
		db	 41h, 08h, 80h, 02h, 20h, 41h
		db	 80h, 42h, 80h,0A0h, 44h, 08h
		db	 20h, 41h, 20h, 42h,0A0h,0ACh
		db	 41h, 80h, 41h, 28h, 08h, 80h
		db	 42h, 80h, 02h, 80h,0ACh, 41h
		db	 20h, 41h, 02h, 82h, 20h, 43h
		db	 02h, 80h,0A0h, 41h, 02h, 42h
		db	0A8h, 42h, 08h, 42h,0A0h,0ACh
		db	 80h, 42h, 20h, 0Ah, 80h, 43h
		db	 22h, 20h,0A0h, 43h, 02h, 08h
		db	 80h, 44h, 80h,0A0h, 82h, 43h
		db	 02h, 43h, 02h, 41h, 80h,0A0h
		db	 08h, 41h, 08h, 20h, 88h, 80h
		db	 43h, 02h, 80h,0A0h, 41h, 0Ah
		db	 02h, 88h, 22h, 80h, 41h, 80h
		db	 08h, 41h, 20h,0A8h
		db	'A *"', 8, 'B ', 0Ah, 'A'
		db	 80h, 11h, 47h, 20h, 41h, 02h
		db	 80h, 11h,0A8h, 02h, 22h, 02h
		db	 47h, 11h,0A8h, 42h, 08h, 46h
		db	 80h, 12h, 08h, 41h, 20h, 20h
		db	 44h, 02h, 41h, 11h,0A8h, 41h
		db	 80h, 80h, 88h, 46h, 12h, 43h
		db	 02h, 46h, 11h,0A8h,0A8h, 8Ah
		db	 11h, 88h, 45h, 08h, 11h, 80h
		db	 49h, 20h, 11h, 2Ah, 02h, 80h
		db	 0Ah,0A8h, 45h, 20h,0A8h,0A8h
		db	 41h, 80h, 41h,0A0h, 80h, 44h
		db	 80h,0A8h, 80h, 08h, 80h, 20h
		db	 02h, 80h, 41h, 2Ah, 28h, 2Ah
		db	 41h,0A8h, 42h, 02h, 88h, 0Ah
		db	 42h, 08h, 41h, 0Ah, 80h,0A8h
		db	 41h, 80h, 02h, 41h, 08h, 44h
		db	 02h, 80h,0A8h, 41h, 80h, 42h
		db	 08h, 45h,0A0h,0A8h, 80h, 42h
		db	 02h, 42h, 20h, 43h, 80h,0A8h
		db	0A0h, 42h, 02h, 44h, 22h, 41h
		db	 80h,0A8h, 80h, 42h, 20h, 20h
		db	 43h,0A0h, 41h, 20h,0A8h, 43h
		db	 20h, 20h, 20h, 44h, 20h,0A8h
		db	 43h, 02h, 42h, 20h, 02h, 42h
		db	 20h,0A8h
		db	'A', 0Ah, 'C A', 0Ah, 8, 'A '
		db	0A8h, 41h, 0Ah, 43h, 80h, 08h
		db	 0Ah, 0Ah, 41h, 20h,0A8h, 80h
		db	 41h, 02h, 08h, 42h, 08h, 43h
		db	 80h,0A8h, 80h, 42h, 08h, 46h
		db	0A0h,0A8h, 08h, 44h, 28h, 44h
		db	 20h,0A8h, 45h, 80h, 08h, 42h
		db	 80h, 41h,0A8h, 42h, 80h, 20h
		db	 42h, 20h, 22h, 42h, 20h, 11h
		db	 42h, 80h, 43h, 20h, 28h, 02h
		db	 41h, 80h,0A8h, 43h, 80h, 45h
		db	 82h, 41h,0A8h, 46h, 02h, 80h
		db	 80h, 20h, 41h,0A8h, 0Ah, 42h
		db	 08h, 80h, 80h, 80h, 8Ah, 82h
		db	 80h, 41h,0A8h, 0Ah, 41h, 02h
		db	 20h, 80h, 41h, 80h, 02h, 02h
		db	 02h, 20h,0A8h, 41h, 08h, 41h
		db	0A0h, 28h, 41h, 02h, 41h, 82h
		db	 20h, 41h,0A8h, 08h, 42h, 20h
		db	0A0h, 80h, 42h, 02h, 08h, 20h
		db	0A8h, 08h, 43h, 88h, 41h, 08h
		db	 02h, 41h, 08h, 80h,0A8h, 44h
		db	 08h, 42h, 8Ah, 80h, 22h, 20h
		db	 11h, 43h,0A0h, 0Ah, 41h, 0Ah
		db	 88h, 41h, 28h, 41h, 11h, 80h
		db	 41h, 0Ah, 82h, 20h, 41h, 88h
		db	 20h, 41h, 82h, 41h, 11h,0A8h
		db	 49h, 08h, 11h,0A2h,0A8h, 28h
		db	 28h, 2Ah, 82h, 12h,0A0h, 41h
		db	0A0h, 11h, 0Ah, 80h, 42h, 0Ah
		db	 41h, 0Ah, 20h,0A8h, 41h, 08h
		db	0A8h,0A8h, 02h, 02h, 80h, 43h
		db	 80h, 42h, 08h,0A0h, 8Ah, 80h
		db	 2Ah, 02h,0A2h, 82h, 0Ah, 44h
		db	0A0h, 41h, 2Ah,0C8h, 2Bh,0E2h
		db	0EEh,0BAh,0BAh,0BEh, 11h, 80h
		db	0A0h,0A8h, 43h, 3Ah, 3Ah, 12h
		db	0EAh, 80h, 41h,0A2h, 80h, 42h
		db	 08h, 08h, 42h, 20h,0AEh, 82h
		db	 41h,0A0h, 02h, 80h, 41h,0A0h
		db	 43h, 20h, 0Ah, 02h, 20h,0A2h
		db	 02h, 80h, 41h, 20h, 44h, 0Ah
		db	 42h,0A2h, 41h, 02h, 42h, 20h
		db	 42h, 20h, 42h, 20h,0A2h, 45h
		db	 20h, 41h, 20h, 08h, 08h, 20h
		db	0A2h, 45h, 20h, 43h, 28h, 41h
		db	0A0h, 41h, 82h, 43h, 80h, 08h
		db	 20h, 43h,0A0h, 41h, 82h, 41h
		db	 08h, 41h, 80h, 41h, 82h, 02h
		db	 42h,0A8h, 41h, 03h, 80h, 42h
		db	0A0h, 08h, 80h, 43h, 11h, 41h
		db	 02h, 42h, 82h,0A8h, 43h, 80h
		db	 41h,0A8h, 41h, 23h, 42h, 80h
		db	0A0h, 20h, 80h, 43h,0A8h, 41h
		db	 02h, 45h, 8Eh, 08h, 41h, 20h
		db	0A0h, 02h, 02h, 80h, 41h, 20h
		db	 42h, 0Eh, 80h, 08h, 80h,0A0h
		db	 02h, 02h, 80h, 42h, 80h, 80h
		db	 02h, 80h, 08h, 41h,0A0h, 0Eh
		db	 02h, 80h, 80h, 41h, 80h, 41h
		db	 8Eh, 42h, 80h,0A0h, 08h, 02h
		db	 80h, 41h, 20h, 20h, 41h, 8Eh
		db	 41h, 82h, 20h,0A8h, 08h, 02h
		db	 41h, 22h, 20h, 42h, 0Eh, 41h
		db	 02h, 80h,0A0h, 08h, 02h, 80h
		db	 02h, 41h, 80h, 08h, 0Ah, 41h
		db	 02h, 41h,0A0h, 41h, 0Ah, 80h
		db	 02h, 42h, 08h, 0Eh,0C0h, 08h
		db	 80h,0A0h, 41h, 0Eh, 41h, 82h
		db	 42h, 28h, 0Ah, 80h, 02h, 41h
		db	0A8h, 08h, 0Ah, 41h, 0Bh, 43h
		db	 0Eh, 80h, 28h, 41h,0A8h, 0Ah
		db	 02h, 80h, 0Ah, 80h, 41h, 80h
		db	 3Ah, 41h, 22h, 41h,0A0h, 08h
		db	 8Bh, 80h, 0Bh, 82h, 80h
data_61		db	88h			; Data table (indexed access)
		db	 3Ah, 82h, 88h, 41h,0A0h, 38h
		db	 0Bh, 80h, 0Eh, 0Ah,0EEh, 0Ah
		db	0E2h, 02h, 22h, 41h,0A0h, 28h
		db	 3Ah, 80h,0A8h, 8Bh,0A2h,0A8h
		db	 11h, 80h, 08h, 41h,0A0h, 38h
		db	 22h,0A0h, 3Ah, 03h, 88h,0BAh
		db	0A2h, 20h, 22h, 41h,0A2h, 08h
		db	 3Ah, 80h,0BAh, 88h,0A0h,0CAh
		db	 82h, 88h, 08h, 41h,0A2h, 0Ch
		db	 2Bh, 2Ah, 11h, 0Ah, 2Ah,0E2h
		db	 22h, 88h, 22h, 41h,0A2h, 08h
		db	0ABh, 88h,0E8h, 82h,0A2h,0CAh
		db	 8Ah, 20h, 88h, 41h,0A2h, 38h
		db	 11h, 08h,0EAh, 08h, 11h,0A8h
		db	0A2h, 28h, 02h, 41h,0A0h,0EAh
		db	 28h, 8Eh,0A8h,0A3h,0A8h, 82h
		db	 88h, 88h, 80h, 41h,0A2h, 11h
		db	0A2h, 22h, 22h, 02h,0A2h, 22h
		db	 22h, 22h, 42h,0A2h, 08h, 88h
		db	 0Ah, 82h, 20h, 02h, 08h, 08h
		db	 43h, 00h, 4Ch,0A0h, 43h, 3Ah
		db	0EBh,0EEh,0A0h, 44h,0A0h, 42h
		db	 03h, 13h,0AEh, 44h,0A0h, 41h
		db	0EAh, 8Eh,0A8h, 8Ah,0EAh,0A8h
		db	 8Fh,0A8h, 42h,0A0h, 0Eh, 11h
		db	 3Eh, 22h, 88h,0A8h,0A8h, 3Ah
		db	0A2h, 80h, 41h,0A0h, 3Ah, 28h
		db	 3Ah, 8Eh, 8Ah,0A2h, 11h, 3Ah
		db	0BAh, 20h, 41h,0A0h,0EAh,0A2h
		db	 3Ah, 22h, 11h,0A2h,0A8h, 28h
		db	0ABh, 88h, 41h,0A3h,0A2h, 28h
		db	0E8h,0A3h, 11h,0A8h,0EAh, 08h
		db	 8Ah,0B2h, 41h,0A3h, 11h, 20h
		db	0EAh,0A8h,0EAh,0A3h,0A8h, 8Ah
		db	0ABh,0A2h, 41h,0AEh, 8Ah, 28h
		db	0EAh, 28h,0E8h, 0Eh, 11h, 0Eh
		db	 11h, 08h, 80h,0AEh, 2Eh,0A0h
		db	0EAh,0EAh, 03h,0A3h,0A8h, 8Eh
		db	 11h,0A0h, 80h,0ACh,0AEh,0A8h
		db	0EAh, 11h,0A8h,0EAh, 11h, 0Eh
		db	 8Ah, 88h, 80h,0ACh,0AEh,0A0h
		db	 3Ah, 11h,0A8h,0EAh,0A8h, 3Ah
		db	0BAh,0A8h, 80h,0A0h,0BAh,0A8h
		db	 3Ah, 11h, 23h, 11h,0A2h, 3Ah
		db	 11h, 82h, 41h,0A3h,0EAh, 11h
		db	 3Ah,0AEh, 83h,0A8h,0A8h, 3Ah
		db	 11h, 22h, 41h,0A3h, 11h,0A8h
		db	 8Eh,0BAh, 8Eh,0ABh,0A0h,0EAh
		db	 11h, 82h, 41h,0E2h,0EAh, 11h
		db	 0Eh, 11h, 2Ah, 11h,0A8h,0E8h
		db	 11h, 08h, 41h,0A0h,0EAh, 11h
		db	 8Eh,0A8h,0ABh, 11h, 20h,0EBh
		db	0A8h, 88h, 41h,0E2h, 3Ah, 11h
		db	 23h, 13h, 83h, 11h,0A2h, 20h
		db	 41h,0E0h,0BAh, 11h, 83h, 13h
		db	 23h, 11h,0A8h, 20h, 41h,0E2h
		db	 2Eh,0A2h, 23h, 12h, 88h, 83h
		db	0A8h, 80h, 80h, 41h,0E0h, 8Eh
		db	 88h, 80h,0EAh,0A2h, 22h, 0Eh
		db	0A2h, 20h, 80h, 41h,0A2h, 23h
		db	 42h,0C8h, 80h, 41h, 0Ch, 20h
		db	 02h, 42h,0E0h,0FEh,0BEh,0F3h
		db	0FBh,0EAh,0EEh,0EAh,0EBh,0FAh
		db	0E8h, 41h,0E2h,0FAh, 11h,0A3h
		db	 13h,0AEh, 12h, 88h, 41h,0A0h
		db	0EAh, 11h, 8Eh, 11h,0ABh, 14h
		db	 88h, 41h,0A2h,0EAh, 11h, 8Eh
		db	0A8h, 14h,0EAh,0A8h, 41h,0A0h
		db	0EAh, 11h, 3Ah,0ABh, 12h, 8Ah
		db	 12h, 88h, 41h,0E2h, 11h,0A8h
		db	0EAh, 13h,0BAh, 12h, 08h, 41h
		db	0E0h,0EAh,0A3h, 16h, 88h, 88h
		db	 41h,0E2h, 11h,0A3h, 11h,0A2h
		db	 8Ah, 28h, 22h, 22h, 22h, 08h
		db	 41h,0E2h, 11h, 03h, 80h, 08h
		db	 45h, 08h, 41h,0E2h, 49h, 20h
		db	 41h,0E0h, 88h,0FAh,0EAh,0AEh
		db	0BAh,0AEh,0AFh, 12h, 80h, 41h
		db	0E2h, 23h, 11h,0A8h,0BAh,0BAh
		db	 22h, 41h, 11h,0A8h, 42h,0E0h
		db	 8Eh,0AEh, 8Ah, 11h, 28h, 80h
		db	 2Ah,0A8h, 11h, 80h, 41h,0E2h
		db	 3Ah,0A8h, 82h, 11h,0A2h, 02h
		db	0A8h,0A8h, 11h, 30h, 41h,0A0h
		db	 11h,0A2h, 0Eh, 11h, 88h, 0Ah
		db	 12h,0EAh, 8Ch, 41h,0E2h,0E8h
		db	0A8h, 3Ah, 11h, 20h, 2Ah, 13h
		db	 08h, 41h,0E0h,0EEh, 80h,0EAh
		db	 11h, 80h, 12h,0BAh, 11h, 82h
		db	 41h,0E2h,0EAh, 88h,0EAh,0A8h
		db	 80h, 11h, 0Ah, 11h, 8Ah, 22h
		db	 41h,0A3h,0A2h, 83h, 11h,0A2h
		db	 02h,0A8h,0BAh, 11h,0A8h, 82h
		db	 41h,0E3h, 8Ah, 83h, 11h,0A8h
		db	 02h, 11h,0EAh, 11h, 22h, 02h
		db	 41h,0E3h, 8Bh, 23h, 11h,0A0h
		db	 0Ah, 12h,0A8h, 88h, 02h, 41h
		db	0E3h, 8Ah, 83h, 11h, 88h, 0Ah
		db	 12h,0A2h, 41h, 28h, 41h,0A3h
		db	0EAh,0A3h, 11h,0A0h, 0Ah, 12h
		db	0A8h, 3Eh, 88h, 41h,0A3h, 8Ah
		db	 83h, 11h, 88h, 2Ah,0ABh, 11h
		db	 83h, 80h, 08h, 41h,0E2h, 8Ah
		db	0A0h,0EAh,0A0h, 2Ah, 11h, 2Ah
		db	 0Ch, 28h, 20h, 41h,0E2h, 8Eh
		db	 88h,0EAh, 88h, 8Ah,0BAh, 2Ah
		db	 30h,0EAh, 20h, 41h,0E8h,0CAh
		db	0A0h,0EAh,0A0h, 2Ch,0EAh, 08h
		db	0C2h,0ABh, 20h, 41h,0E0h,0E2h
		db	0A8h, 3Ah,0A8h, 8Ah, 11h, 08h
		db	 82h,0BFh, 20h, 41h,0E8h,0A2h
		db	0A8h, 3Eh, 11h, 22h,0A0h, 0Ah
		db	 33h,0EFh, 08h, 41h,0A0h, 83h
		db	0A8h, 0Eh, 12h, 88h, 2Ah, 2Ah
		db	0AEh, 88h, 41h,0E8h, 3Eh,0EAh
		db	 0Bh, 2Ah, 22h, 20h, 2Ah, 8Eh
		db	0A2h, 82h, 41h,0E2h, 38h,0A8h
		db	 0Ah,0C8h, 88h, 80h, 11h,0A2h
		db	0A8h, 82h, 41h,0E0h,0E2h,0BAh
		db	 0Ah,0B0h, 20h, 02h, 11h,0A8h
		db	0F2h, 20h, 80h,0A3h, 8Ah, 2Ah
		db	 0Ah,0AFh, 41h, 0Ah, 11h,0BAh
		db	 08h, 88h, 80h,0E3h, 8Ch, 38h
		db	 8Ah, 83h,0FAh, 12h, 8Ah,0A2h
		db	 22h, 20h,0E2h,0A3h, 11h, 0Ah
		db	 0Eh, 08h, 13h, 88h,0C8h, 20h
		db	0E2h, 11h, 88h, 23h, 38h,0FAh
		db	 2Ah,0EAh, 11h,0A0h,0E2h, 08h
		db	0E0h,0A2h, 20h, 33h, 33h, 08h
		db	 2Ah, 12h, 88h,0A8h, 80h,0E2h
		db	 20h, 03h, 83h, 3Bh, 08h, 2Ah
		db	0EAh, 11h, 20h, 11h, 41h,0E8h
		db	 8Eh,0CAh, 80h,0F2h,0A0h, 2Ah
		db	 2Ah, 11h, 80h,0E8h, 80h,0E2h
		db	 2Ah,0A2h, 23h,0ECh, 41h, 13h
		db	 41h, 88h, 41h,0EAh,0EBh,0A3h
		db	0A3h, 2Eh,0A8h, 13h, 80h, 80h
		db	 41h,0EBh, 80h,0A0h,0E0h,0A8h
		db	 02h, 13h, 82h, 42h,0EEh, 82h
		db	0A0h,0A8h, 2Eh,0A8h, 13h,0A2h
		db	 88h, 41h,0EEh, 0Ah,0A8h,0A8h
		db	0BAh, 11h, 2Ah, 12h, 82h,0A0h
		db	41h

; --- misdec_port_stub: NOT CALLED; Sourcer-fabricated fake proc at 0x1B40 ---
; Dead code. Sourcer decoded the byte 0xEE (part of sprite data) as "out dx,al"
; and created a synthetic "proc". Verified: no call sites in the whole module.
; Kept as mnemonics because TASM re-encodes them to the same bytes via the
; misdec_* and data_29 EQUs. This section is truly sprite pixel data.

misdec_port_stub		proc	near
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		db	82h, 0A0h, 0A8h, 3Ah, 0A8h	; and byte ptr [bx+si+3AA8h],0A8h (alt encoding: 82/4 not 80/4)
		sub	ch,byte ptr data_29
		test	al,41h			; 'A'
		lodsb				; String [si] to al
		adc	ds:misdec_BAA0[bx+si],cx
		mov	al,ds:misdec_822A
		adc	ss:misdec_41A2[bp+si],cx
		jmp	short $+0Ch

misdec_port_stub		endp

; --- Sprite data continues at 0x1B5A (Sourcer decoded it as fake mnemonics) ---
;* No entry point to code -- data block (pixel runs)

sprite_data_row_2	label	byte
		inc	cx
		test	al,3Ah			; ':'
		test	al,11h
		mov	dl,[bx+di]
		or	ch,ds:misdec_EA41[bx+si]
		db	0C0h, 03h,0A0h,0BAh,0A0h, 2Ah
		db	 8Ah,0AEh, 8Ah,0A0h, 41h,0EAh
		db	0BEh,0BAh,0A8h, 3Ah,0A8h, 11h
		db	 2Ah,0A2h, 0Ah, 80h, 41h,0ABh
		db	0EAh, 11h,0A0h,0BAh,0A0h,0EEh
		db	 12h, 82h, 8Ah, 80h,0EEh,0A0h
		db	 2Ah, 88h, 3Ah, 88h,0A2h, 11h
		db	 2Ah,0A2h,0A8h, 20h,0FAh, 8Ah
		db	0CAh,0A0h,0BAh,0A0h,0EAh, 12h
		db	 82h,0A2h, 20h,0BAh, 2Ah,0BAh
		db	 80h, 3Ah, 88h, 13h,0A0h,0A8h
		db	 20h,0EAh, 3Ah,0EAh, 22h,0BAh
		db	 20h, 11h,0A2h, 11h,0A8h,0A0h
		db	 80h,0EAh, 8Fh,0A8h, 82h, 3Ah
		db	 80h, 8Ah, 13h, 28h, 80h,0EAh
		db	 11h,0A2h, 08h,0B2h, 20h, 88h
		db	 12h,0A2h, 20h, 80h,0B2h,0A8h
		db	 88h, 02h, 28h, 0Ah, 30h, 08h
		db	 11h, 8Ah, 82h, 41h,0FCh, 02h
		db	 41h, 08h, 12h, 8Eh, 80h, 22h
		db	0A2h, 02h, 41h,0E3h,0C0h, 03h
		db	 22h,0A2h, 11h,0A0h, 3Bh, 41h
		db	 88h, 82h, 41h, 88h, 88h, 88h
		db	 8Ah, 11h, 8Ah, 88h, 80h,0E8h
		db	 41h, 08h, 41h,0E2h, 2Fh,0FFh
		db	0FFh, 0Ah, 11h,0A2h, 22h, 03h
		db	0A0h, 08h, 41h,0C8h,0FAh, 12h
		db	0A0h,0A2h, 2Ah, 88h, 80h, 0Ah
		db	0A0h, 41h,0E3h,0AEh, 2Eh,0BAh
		db	 2Ah, 2Ah, 11h,0A2h, 20h, 43h
		db	0CEh,0EAh, 28h,0A8h,0A8h, 8Ah
		db	0BFh,0E8h, 88h, 43h, 2Ah,0A8h
		db	0A8h,0A8h, 11h, 0Ah,0EAh,0BAh
		db	 22h, 43h,0BAh, 8Ah,0A8h,0A8h
		db	 11h,0A3h, 11h, 20h, 88h, 43h
		db	0FAh, 2Ah,0A8h, 12h, 83h, 11h
		db	 82h, 2Fh, 03h,0F0h, 41h,0FAh
		db	 2Ah,0A8h, 12h,0A3h, 11h, 23h
		db	0BAh,0A2h,0A8h, 41h,0FAh, 2Ah
		db	 11h,0AEh, 11h, 03h,0A2h, 02h
		db	0EAh, 88h,0EAh, 41h,0FAh, 2Ch
		db	 11h,0A2h,0AEh, 22h, 28h, 0Ah
		db	 2Ah,0A0h, 88h, 41h,0FAh, 14h
		db	 03h, 80h, 28h, 2Ah, 80h, 8Ah
		db	 41h,0FAh, 11h,0A8h, 11h,0A8h
		db	0A2h,0C0h, 80h, 22h, 20h, 20h
		db	 41h,0BAh,0ABh, 11h,0A2h, 11h
		db	 82h,0B0h, 20h,0B8h, 02h, 42h
		db	0BAh,0A8h, 11h,0E2h, 11h, 82h
		db	0ACh, 08h,0A0h, 08h, 42h,0BAh
		db	 11h,0ABh, 11h,0A8h, 82h,0ABh
		db	0C0h, 22h, 22h, 42h,0BAh, 12h
		db	 8Ah,0A2h, 20h, 11h,0BFh, 44h
		db	0BAh, 13h,0A8h, 02h, 12h,0FFh
		db	0FFh,0FFh,0C0h,0BAh, 11h, 82h
		db	 20h, 22h, 41h, 11h,0A2h, 13h
		db	 20h,0BAh, 20h, 43h, 02h, 2Ah
		db	 8Ah, 2Ah, 12h, 20h,0BFh,0FFh
		db	0BFh,0EBh,0EEh,0B8h, 8Ah, 8Ah
		db	 11h,0A2h, 11h, 20h,0EAh,0BAh
		db	0BAh, 11h,0A8h,0E8h, 2Ah,0BAh
		db	 11h,0A2h, 11h, 20h,0EAh,0AFh
		db	0EAh, 8Ah,0A8h,0E0h, 8Ah, 12h
		db	 8Ah, 28h, 20h,0EAh, 11h, 2Ah
		db	 11h, 83h, 88h, 2Ah, 12h, 8Ah
		db	0EAh, 20h,0E2h, 8Ah, 2Bh, 11h
		db	 3Ah,0A0h, 8Ah, 13h,0A8h, 20h
		db	0E0h, 2Ah, 28h,0A8h,0EAh, 88h
		db	 2Ah, 8Ah,0A2h, 11h,0A2h, 20h
		db	0E3h, 11h, 2Ah, 80h,0EAh,0A0h
		db	 8Ah, 8Ah,0AEh, 11h,0A8h, 20h
		db	0EAh, 11h, 28h, 38h,0EAh, 88h
		db	 2Ah, 2Ah, 12h,0A2h, 20h,0EAh
		db	0A8h,0A3h, 12h,0A0h, 8Ah, 13h
		db	0A8h, 20h,0EAh, 14h,0A8h, 14h
		db	0A2h, 20h,0EAh, 14h,0A8h, 14h
		db	0A8h, 20h,0C0h, 44h, 02h, 14h
		db	0A2h, 20h,0EAh, 11h,0AEh, 12h
		db	0A2h, 12h, 2Ah, 11h,0A8h, 20h
		db	0B2h,0BAh, 2Ah, 2Bh, 8Ah,0A2h
		db	 12h, 2Ah, 8Ah,0A2h, 20h,0B8h
		db	 11h, 2Ah, 11h, 2Ah,0A2h, 14h
		db	 28h, 20h,0BCh,0AEh, 2Ah, 2Ah
		db	 11h,0A2h, 14h,0A2h, 20h,0B8h
		db	 11h, 2Ah,0EAh, 11h,0A2h,0A8h
		db	 11h,0A8h,0A2h,0A8h, 20h,0FAh
		db	0A8h, 13h,0A2h,0A2h, 11h,0A8h
		db	 11h,0A2h, 20h,0BAh,0A8h, 12h
		db	 8Ah,0A2h, 13h, 2Ah,0A8h, 20h
		db	0BAh,0ABh, 12h,0BAh,0A2h, 11h
		db	0A2h,0AEh, 2Ah, 22h, 20h,0EAh
		db	 14h, 02h, 11h,0A2h,0AEh, 2Ah
		db	 88h, 20h,0EAh, 13h,0A8h,0A2h
		db	 11h,0E2h, 11h, 2Ah, 20h, 20h
		db	 14h,0A8h,0B2h, 2Ah, 11h, 88h
		db	 88h, 88h, 20h,0EAh, 13h, 82h
		db	0B2h, 8Ah,0A8h, 43h, 20h,0EAh
		db	 13h, 2Bh,0C3h, 11h, 45h,0FEh
		db	0FBh,0AFh,0A8h, 41h, 02h,0A0h
		db	 02h, 02h, 43h,0EAh, 8Ah, 12h
		db	0A2h, 42h, 11h,0A8h, 88h, 42h
		db	 8Ah, 11h, 2Ah, 11h, 88h, 0Bh
		db	0FFh,0FFh, 0Fh,0FFh,0C0h, 41h
		db	0CAh,0A8h, 82h, 22h, 20h, 13h
		db	 8Eh, 11h,0A8h, 41h,0C2h, 80h
		db	 43h, 2Ah, 11h,0A2h, 8Eh, 12h
		db	 41h, 80h,0EAh, 13h, 82h, 11h
		db	0A8h, 0Eh, 12h, 41h,0C3h, 11h
		db	0EAh, 12h,0A8h, 12h, 8Eh, 11h
		db	0A2h, 41h,0C3h,0AEh, 12h,0ABh
		db	 11h, 2Ah, 11h, 8Eh, 12h, 41h
		db	0CEh, 13h,0A8h,0EAh, 2Ah, 11h
		db	 8Eh, 12h, 41h,0CAh, 11h,0ABh
		db	 12h, 3Ah, 8Ah, 11h, 8Eh,0CAh
		db	 11h, 41h,0FAh, 8Ah, 11h,0A8h
		db	 11h, 3Ah, 8Ah, 11h, 8Eh,0BAh
		db	 11h, 41h,0FBh,0A2h, 11h, 2Ah
		db	 11h, 32h, 8Ah, 11h, 8Eh, 12h
		db	 41h,0FAh, 8Ch,0A3h,0A8h,0EAh
		db	 3Ah, 8Ah, 11h, 8Eh, 12h, 41h
		db	0BAh, 8Ch,0A3h,0A8h,0EAh, 32h
		db	 8Ah, 11h, 0Eh, 12h, 41h,0BAh
		db	 8Eh,0A3h,0A8h,0E8h, 3Ah, 0Ah
		db	0ABh, 8Eh, 11h, 8Ah, 41h,0FAh
		db	 0Eh,0A3h,0A0h,0E2h, 0Eh, 8Ah
		db	0ABh, 8Eh, 12h, 41h,0F2h, 8Eh
		db	 83h, 28h,0EAh, 41h, 3Ah,0ABh
		db	 8Fh, 12h, 41h,0BAh, 0Ch,0A3h
		db	0A0h,0C8h, 20h,0A8h, 11h,0CEh
		db	0EAh, 11h, 41h,0FAh, 0Ch,0A3h
		db	 28h,0CAh, 2Ah,0A2h, 11h,0CEh
		db	0EAh, 11h, 41h,0F2h, 8Eh, 23h
		db	 28h,0E8h, 0Eh,0B2h, 11h, 8Eh
		db	0BAh, 11h, 41h,0F8h, 8Ch,0A3h
		db	 88h,0CAh, 0Ch, 0Ch, 11h, 8Eh
		db	0BAh, 11h, 41h,0B2h, 8Ch, 83h
		db	 28h,0CAh, 0Eh,0CAh, 2Ah, 8Eh
		db	0BAh, 11h, 41h,0F0h, 0Eh, 03h
		db	 08h,0C2h, 0Eh,0B3h, 2Ah, 8Eh
		db	0EAh, 11h, 41h,0FCh, 2Bh, 0Eh
		db	0C2h,0B0h, 8Ch, 11h,0CAh, 8Fh
		db	 12h, 41h,0BAh, 11h, 8Eh, 12h
		db	 8Eh, 12h, 8Ch, 12h, 41h,0BAh
		db	 11h, 8Ch, 12h, 8Ch, 12h, 8Eh
		db	 12h, 41h,0F2h, 11h, 8Eh, 12h
		db	 8Ch, 12h, 8Eh, 11h,0A8h, 41h
		db	0FAh, 11h, 8Ch, 12h, 8Eh, 12h
		db	 8Ch, 11h,0A8h, 41h,0F2h, 11h
		db	 8Ch, 12h, 8Ch, 12h, 8Ch, 8Ah
		db	0A8h, 41h,0F8h, 11h, 8Eh, 12h
		db	 8Ch, 2Ah, 11h, 8Eh, 11h,0A2h
		db	 41h,0F0h, 2Ah, 8Ch, 22h, 11h
		db	 8Ch,0A2h, 11h, 8Ch, 82h, 20h
		db	 41h,0F0h, 82h, 8Ch, 08h, 22h
		db	 8Ch, 08h, 82h,0BCh, 20h, 42h
		db	0C8h, 80h, 4Ah,0E2h, 3Ah, 17h
		db	 80h, 42h,0CBh,0EAh, 17h,0A8h
		db	 82h, 41h,0EEh, 19h, 20h, 80h
		db	0BAh, 15h,0A2h, 82h, 88h, 88h
		db	 80h, 41h,0FFh,0FFh,0EBh, 3Fh
		db	0FFh,0BBh,0BAh,0EBh,0EAh,0FAh
		db	 11h, 80h,0FAh, 11h,0BAh, 8Fh
		db	 11h,0E8h,0E2h,0A2h,0ABh, 12h
		db	 80h,0BAh,0BAh,0A8h, 8Ah, 11h
		db	0A2h, 12h, 8Ah,0B8h, 11h, 41h
		db	0BAh, 11h, 2Ah,0A2h,0E8h, 13h
		db	 8Ah, 11h,0EAh, 80h,0FBh, 8Ah
		db	 12h,0E2h, 14h,0A2h, 8Ah, 41h
		db	0FBh, 8Ah, 11h,0A6h,0A2h, 15h
		db	0EAh, 80h,0FEh, 8Ah, 11h,0AFh
		db	0A2h, 15h, 2Ah, 80h,0FAh, 8Ah
		db	 11h,0AEh,0E2h, 14h,0AEh, 11h
		db	 80h,0BEh, 11h,0A8h,0AEh,0A2h
		db	 14h,0AEh,0A0h, 41h,0FAh, 11h
		db	0A8h,0E6h, 16h, 8Eh, 41h,0EAh
		db	 11h,0AEh, 0Eh, 15h,0BAh, 8Ah
		db	 41h,0C2h, 11h,0A8h,0EAh, 15h
		db	 3Ah,0A8h, 80h,0CEh, 11h,0AEh
		db	 11h, 0Ah, 13h,0A8h, 8Eh, 11h
		db	 41h,0CAh, 12h,0A8h,0A2h, 11h
		db	0A0h,0ABh, 8Ah,0A3h,0A8h, 80h
		db	0BAh, 12h, 28h,0AEh, 11h, 0Bh
		db	 11h,0BAh,0A8h,0EAh, 41h,0BAh
		db	0A8h, 11h, 2Ah, 3Ah,0A8h,0ABh
		db	 12h,0A8h,0E8h, 41h,0BAh,0B0h
		db	0A2h, 2Ah, 11h,0A0h,0AEh, 11h
		db	0B8h,0A8h, 11h, 41h,0FAh,0A2h
		db	0A2h, 2Ah, 11h,0A2h,0AEh, 11h
		db	 88h, 11h, 38h, 80h,0CEh,0A2h
		db	0A8h, 12h,0A8h,0FAh, 11h, 88h
		db	 11h, 3Ah, 41h,0FAh, 12h, 2Ah
		db	 11h, 2Ah, 12h,0A8h,0A8h,0E8h
		db	 41h,0BAh, 11h, 8Ah, 12h, 2Ah
		db	 12h,0B8h, 11h,0A2h, 41h,0BAh
		db	 2Ah,0B8h, 12h, 2Ah, 13h, 2Ah
		db	 88h, 41h,0CAh, 2Ah,0A8h, 11h
		db	0ABh, 13h,0BAh, 2Ah,0A0h, 41h
		db	0CAh, 22h, 11h, 2Ah, 13h, 82h
		db	 28h, 28h, 88h, 41h,0BAh, 20h
		db	0AEh, 2Ah,0ABh, 8Ah, 8Ah, 88h
		db	0EAh, 2Ah, 20h, 41h,0FAh,0E2h
		db	0AEh, 2Ah,0AEh, 0Ah,0EEh
data_62		dw	882Ah			; Data table (indexed access)
data_63		dw	8808h			; Data table (indexed access)
		db	 41h,0FAh, 22h,0EAh, 0Ah,0A8h
		db	 8Bh,0A2h,0A8h, 11h, 41h, 20h
		db	 41h,0FAh,0E2h, 11h, 88h, 3Ah
		db	 03h, 88h,0BAh, 88h, 80h, 88h
		db	 41h,0FAh, 22h,0EAh
		db	8
data_64		dw	883Ah			; Data table (indexed access)
data_65		dw	0CAA0h			; Data table (indexed access)
data_66		db	0Ah			; Data table (indexed access)
		db	 20h, 42h,0BAh
data_67		dw	0ACB2h			; Data table (indexed access)
		db	0A0h, 11h, 0Ah, 28h,0E2h, 0Ah
		db	 20h, 88h, 41h,0BAh,0A0h,0AEh
		db	 20h,0E8h, 82h, 82h,0CAh, 28h
		db	 82h, 42h,0FAh,0E0h, 28h, 20h
		db	0EAh, 08h, 8Ah,0A8h, 88h,0A0h
		db	 08h, 41h,0BBh,0A8h, 22h, 38h
		db	0A8h,0A3h, 08h, 82h, 20h, 22h
		db	 42h,0BAh, 11h, 88h, 88h, 22h
		db	 02h, 02h, 22h, 80h, 88h
data_68		db	42h			; Data table (indexed access)
		db	0F8h, 22h, 20h, 28h, 82h, 20h
		db	 02h, 08h, 20h, 43h, 00h, 1Ch
		db	 0Ah, 13h,0BAh,0EBh,0EEh, 15h
		db	 0Ah, 12h,0ABh, 13h,0AEh, 14h
		db	 0Ah, 11h,0EAh,0AEh,0A8h, 8Ah
		db	0EAh,0A8h,0AFh
data_69		db	13h			; Data table (indexed access)
		db	 0Ah,0AEh, 11h, 3Eh, 20h, 88h
		db	0A8h, 41h, 3Ah,0A2h, 12h
data_70		db	0Ah
		db	0BAh, 28h, 3Ah, 80h, 80h, 20h
		db	 20h, 3Ah,0BAh, 2Ah, 11h, 0Ah
		db	0EAh,0A2h, 3Ah, 42h, 20h, 20h
		db	 28h,0ABh, 8Ah, 11h, 08h,0A2h
		db	 08h,0E8h, 42h, 20h, 41h, 08h
		db	 82h,0B2h, 11h, 08h,0A2h, 41h
		db	0E0h, 44h, 88h, 83h,0A2h, 11h
		db	 41h, 82h, 28h, 46h, 02h, 08h
		db	 11h, 42h, 20h, 45h, 80h, 02h
		db	 41h, 11h, 41h, 20h, 88h, 41h
		db	 20h, 42h, 82h, 42h, 08h, 11h
		db	 41h, 20h, 41h, 02h, 02h, 42h
		db	 88h, 08h, 02h, 08h, 11h, 08h
		db	 80h, 88h, 41h, 0Ah, 42h, 02h
		db	 08h, 41h, 02h, 11h, 08h, 02h
		db	 82h, 02h, 2Eh, 80h, 20h, 08h
		db	 08h,0A0h, 22h, 11h, 08h, 42h
		db	 80h, 3Ah, 80h, 41h, 20h, 20h
		db	0A0h, 02h, 11h, 41h, 02h, 88h
		db	 41h, 2Ah, 42h, 28h, 20h, 41h
		db	 0Ah, 11h, 41h, 20h, 80h, 41h
		db	 88h, 03h, 80h, 20h, 20h, 41h
		db	 8Ah, 11h, 41h, 08h, 20h, 20h
		db	 08h, 02h, 80h, 80h, 80h, 02h
		db	 2Ah, 11h, 41h, 88h, 41h, 80h
		db	 41h, 80h, 02h, 20h, 88h, 08h
		db	 2Ah, 11h, 02h, 22h, 80h, 20h
		db	 0Ah, 41h, 08h, 80h, 41h, 80h
		db	 12h, 41h, 82h, 88h, 80h, 41h
		db	 22h, 22h, 02h,0A2h, 20h, 12h
		db	 02h, 20h, 43h, 80h, 42h, 20h
		db	 02h, 12h, 41h,0FEh,0BEh,0F0h
		db	0FBh,0EAh,0EEh,0EAh,0EBh,0FAh
		db	0EAh, 11h, 02h, 0Ah, 11h,0A0h
		db	0A0h, 11h,0A0h, 2Eh, 41h, 2Ah
		db	 8Ah, 11h, 41h, 2Ah, 20h, 80h
		db	 80h, 0Bh, 80h, 28h, 41h, 0Ah
		db	 0Ah, 11h, 41h, 20h, 82h, 80h
		db	 80h, 02h, 41h, 08h, 41h, 08h
		db	 0Ah, 11h, 42h, 82h, 42h, 02h
		db	 44h, 0Ah, 11h, 45h, 02h, 44h
		db	 0Ah, 11h, 4Ah, 0Ah, 11h, 4Ah
		db	 0Ah, 11h, 02h, 49h, 0Ah, 11h
		db	 02h, 49h, 2Ah, 11h, 41h, 88h
		db	0FAh,0EAh,0AEh,0BAh,0AEh,0AFh
		db	 14h, 02h, 03h, 11h,0A8h, 3Ah
		db	0BAh, 22h, 41h,0A2h, 13h, 41h
		db	 0Eh,0AEh, 80h, 0Ah, 28h, 80h
		db	 41h, 08h, 02h, 12h, 02h, 3Ah
		db	0A8h, 41h, 0Ah, 43h, 08h, 41h
		db	 3Ah, 11h, 41h, 2Ah,0A0h, 41h
		db	 02h, 44h,0E0h, 0Eh, 11h, 41h
		db	0E8h,0A8h, 43h, 02h, 41h, 08h
		db	0A0h, 0Ah, 11h, 41h,0ECh, 80h
		db	 41h, 80h, 43h, 38h, 42h, 11h
		db	 41h,0EAh, 80h, 02h, 47h, 11h
		db	 03h,0A0h, 80h, 48h, 11h, 03h
		db	 80h, 80h, 45h, 80h, 42h, 11h
		db	 03h, 83h, 41h, 0Ah, 42h, 20h
		db	 44h, 11h, 03h, 82h, 41h, 8Ah
		db	 43h, 08h, 42h, 02h, 11h, 03h
		db	0C2h, 41h, 80h
data_71		dw	241h			; Data table (indexed access)
		db	 44h, 02h, 11h, 03h, 44h, 0Ah
		db	 80h, 43h, 02h, 11h, 43h, 0Ah
		db	 41h, 02h, 02h, 42h, 38h, 0Ah
		db	 11h, 45h, 80h
		db	3Ah
data_72		db	42h
		db	 3Ah, 0Ah, 11h, 45h, 2Ch,0E8h
		db	 41h, 03h
data_73		dw	0AEFh			; Data table (indexed access)
		db	 11h, 45h, 0Ah,0A0h, 41h, 02h
		db	0BFh, 0Ah, 11h, 08h, 41h, 08h
		db	 41h,0A0h, 44h, 0Fh, 02h, 11h
		db	 41h, 80h,0A8h, 41h, 20h, 45h
		db	 02h, 11h, 08h, 41h, 2Ah, 48h
		db	 11h, 02h, 41h, 88h, 44h, 0Ah
		db	 43h, 11h, 41h, 02h, 8Ah, 48h
		db	 2Ah, 41h, 0Ah, 02h, 02h, 47h
		db	 2Ah, 43h, 8Ah, 47h, 0Ah, 42h
		db	 0Ah, 08h, 42h, 08h, 02h
		db	 43h, 0Ah
data_74		db	42h			; Data table (indexed access)
		db	 08h, 20h, 43h,0E0h, 08h, 42h
		db	 02h, 47h,0A0h
data_75		dw	4208h			; Data table (indexed access)
		db	 82h, 02h, 49h, 02h, 41h, 08h
		db	 80h, 44h, 08h, 02h, 42h, 28h
		db	 80h, 02h, 49h, 88h, 02h, 41h
		db	 08h, 43h,0A8h, 41h, 80h, 20h
		db	 42h, 0Ah, 47h, 80h, 20h, 42h
		db	 11h, 41h, 82h, 20h, 42h,0A8h
		db	 45h, 11h, 41h, 0Ah, 28h, 42h
		db	 2Ah, 43h, 02h, 41h, 11h, 42h
		db	 20h, 41h, 02h, 08h, 02h, 42h
		db	 08h, 41h, 2Ah, 41h,0A0h, 88h
		db	 41h, 02h, 41h, 02h, 80h, 41h
		db	 08h, 41h, 2Ah, 41h, 0Ah, 43h
		db	 88h, 82h, 80h, 41h, 08h, 41h
		db	 2Ah, 08h, 44h, 80h, 41h, 80h
		db	 41h, 08h, 41h, 11h, 2Ah, 80h
		db	 44h, 80h, 42h, 08h, 02h, 11h
		db	 28h, 02h, 80h, 41h, 02h, 42h
		db	 02h, 80h, 02h, 02h, 11h, 20h
		db	 20h, 22h, 80h, 02h, 41h, 80h
		db	 02h, 41h, 02h, 41h, 0Ah, 41h
		db	 80h, 02h, 80h, 02h, 41h,0C0h
		db	 42h, 02h, 41h, 2Ah, 02h, 0Ah
		db	 80h, 41h, 02h, 41h, 80h, 44h
		db	 2Ah, 41h, 0Ah, 02h, 20h, 08h
		db	 20h, 80h, 44h, 11h, 42h, 08h
		db	 80h, 0Ah, 80h, 80h, 41h, 02h
		db	 41h, 20h, 11h, 02h, 41h, 02h
		db	 41h, 02h, 20h, 80h, 41h, 02h
		db	 41h, 20h, 11h, 41h,0A8h, 88h
		db	 41h, 08h, 0Ah, 42h, 8Ah, 02h
		db	 82h, 11h, 41h, 02h, 42h, 02h
		db	 11h, 80h, 41h, 22h,0A2h, 02h
		db	 11h, 46h,0A0h, 42h, 88h, 82h
		db	 11h, 08h, 88h, 88h, 8Ah,0A0h
		db	 41h, 08h, 80h, 42h, 0Ah, 11h
		db	 22h, 2Ch,0F0h,0FCh, 43h, 22h
		db	 41h,0A0h, 0Ah, 11h, 08h, 0Ah
		db	 12h,0A0h, 41h, 02h, 41h, 80h
		db	 2Ah, 12h, 23h,0AEh, 0Eh,0BAh
		db	 42h, 02h, 41h, 20h, 2Ah, 12h
		db	 0Eh,0EAh, 08h, 28h, 44h, 08h
		db	 2Ah, 12h, 2Ah,0A8h, 08h, 28h
		db	 44h, 22h, 2Ah, 12h, 8Ah, 80h
		db	 08h, 28h, 43h, 20h, 08h, 2Ah
		db	 12h, 0Ah, 41h, 08h, 44h, 80h
		db	 41h, 08h, 02h, 11h, 0Ah, 41h
		db	 08h, 43h, 02h, 20h, 43h, 11h
		db	 0Ah, 41h, 08h, 41h, 02h, 41h
		db	 22h, 43h, 02h, 2Ah, 0Ah, 0Ch
		db	 42h, 0Eh, 41h, 28h, 02h, 20h
		db	0A0h
		db	8, '*', 0Ah, 'C', 0Ah, 'B(', 0Ah
		db	 80h, 8Ah, 2Ah, 42h, 08h, 41h
		db	 08h, 02h
		db	'B"  *C A'
		db	 02h, 80h, 20h, 08h, 42h, 11h
		db	 41h, 20h, 41h,0E0h, 41h, 02h
		db	0A0h, 43h, 02h, 11h, 41h, 20h
		db	 03h,0A0h, 80h, 02h,0A8h, 43h
		db	 02h, 11h, 41h, 20h, 02h, 80h
		db	 42h, 11h, 80h, 43h, 11h, 45h
		db	 02h, 8Ah, 11h, 43h, 2Ah, 46h
		db	 80h,0A2h, 13h, 0Ah, 45h, 02h
		db	 20h, 82h, 2Ah, 8Ah, 11h, 0Ah
		db	 03h,0FFh,0BFh,0EBh,0EEh,0B8h
		db	 80h, 80h, 02h,0A2h, 8Ah, 0Ah
		db	 2Ah,0B2h,0B2h, 11h,0A8h, 28h
		db	 20h, 41h, 02h,0A0h, 82h, 0Ah
		db	 2Ah,0AFh,0EAh, 8Ah,0A8h, 41h
		db	 80h, 41h, 02h, 80h, 41h, 0Ah
		db	 2Ah, 11h, 41h, 02h, 80h, 43h
		db	 82h, 80h, 41h, 0Ah, 22h, 8Ah
		db	 41h, 02h, 42h, 80h, 41h, 80h
		db	 42h, 0Ah, 20h, 0Ah, 44h, 02h
		db	 80h, 43h, 0Ah, 20h, 0Ah, 44h
		db	 02h, 80h, 41h, 02h, 41h, 0Ah
		db	 20h, 0Ah, 47h, 80h, 41h, 0Ah
		db	 41h, 08h, 47h, 80h
		db	'A', 0Ah, 'K', 0Ah, 'K', 0Ah, 'K', 0Ah
		db	'*'
		db	 11h,0AEh, 12h,0A0h, 41h, 0Ah
		db	 43h, 0Ah, 02h,0BAh, 0Ah, 0Bh
		db	 82h,0A0h, 41h, 0Ah, 41h, 80h
		db	 02h, 0Ah, 08h, 2Ah, 41h, 02h
		db	 41h, 20h, 45h, 0Ah, 0Ch, 0Eh
		db	 43h, 20h, 08h, 43h, 02h
		db	0Ah, 8, 0Ah, 'C (A', 8, 'A(', 0Ah
		db	8, 8, 'D A', 8, 'A"', 0Ah, 8, 'G', 0Ah
		db	'A', 8, 0Ah, 8, 'F'
		db	0A0h, 0Eh, 41h, 02h, 0Ah, 20h
		db	 46h,0A0h, 0Eh, 41h, 88h, 0Ah
		db	 28h, 41h, 02h, 80h, 41h, 02h
		db	 41h,0E0h, 0Ah, 0Ah, 20h, 0Ah
		db	 28h, 08h, 02h, 80h, 28h, 02h
		db	 02h, 11h, 88h, 88h, 88h, 0Ah
		db	 28h, 42h, 0Ah, 80h, 02h, 8Ah
		db	0A8h, 43h, 0Ah, 2Ah, 80h, 12h
		db	 28h, 03h, 11h, 44h, 2Ah, 45h
		db	 02h,0A0h, 02h, 02h, 41h, 2Ah
		db	 11h, 20h, 41h, 0Ah, 11h,0A2h
		db	 42h, 11h,0A8h, 88h, 2Ah, 11h
		db	 08h, 43h, 88h, 45h, 02h, 11h
		db	 08h, 42h, 02h, 20h,0A0h, 2Ah
		db	0A0h, 02h, 80h,0A8h, 11h, 02h
		db	 44h, 02h, 0Ah, 41h, 02h, 41h
		db	 2Ah, 2Ah, 41h,0E8h, 28h,0A8h
		db	 41h, 02h, 80h, 08h, 02h, 20h
		db	 02h, 2Ah, 03h,0A0h, 41h, 20h
		db	 42h,0A0h, 22h, 80h, 42h, 2Ah
		db	 03h, 80h, 44h, 20h, 41h, 80h
		db	 02h, 41h, 2Ah, 0Eh, 45h, 20h
		db	 42h, 02h, 41h, 2Ah, 02h, 43h
		db	 08h, 42h, 80h, 42h, 02h, 2Ah
		db	 02h, 41h, 88h, 44h, 80h
		db	'B', 0Ah, '*', 8, 'A', 0Ah, 'C', 8
		db	8, 'B'
		db	2
		db	'*', 8, 'D', 8, 8, 8, 'C*', 8, 'B'
		db	 80h, 08h, 42h, 80h, 43h, 2Ah
		db	 08h, 41h, 20h,0A0h, 41h, 08h
		db	 43h,0A0h, 41h, 2Ah, 08h, 41h
		db	0A0h,0A0h, 20h, 02h, 43h,0A0h
		db	 41h, 2Ah, 02h, 43h, 20h, 42h
		db	 20h, 80h, 41h, 02h, 2Ah, 0Ah
		db	 46h, 20h, 42h, 02h
		db	'*', 8, 'D(D *A'
		db	 02h, 42h, 20h, 02h, 45h, 2Ah
		db	 08h, 42h, 88h, 08h, 42h, 08h
		db	 02h, 42h, 2Ah, 02h, 41h, 80h
		db	 28h, 08h, 43h, 02h, 42h, 11h
		db	 41h, 02h, 45h, 02h, 43h, 2Ah
		db	 41h, 08h, 02h, 02h, 80h, 46h
		db	 2Ah, 41h, 02h, 82h,0A2h, 02h
		db	 02h, 02h, 20h, 42h,0A0h, 2Ah
		db	 08h, 80h, 80h, 80h, 02h, 41h
		db	 02h, 08h, 80h, 41h,0A0h, 2Ah
		db	 41h, 08h, 82h, 41h, 80h
		db	'A(', 0Ah, 'A A*', 8, ' '
		db	 80h, 42h, 02h, 0Ah, 08h, 42h
		db	 20h, 2Ah, 02h, 20h, 41h, 80h
		db	 20h, 41h, 22h, 43h, 20h, 2Ah
		db	 08h, 88h, 02h,0A2h
		db	'B D*A(A"'
		db	0A0h, 41h,0A0h, 0Ah, 43h, 2Ah
		db	 41h, 82h, 41h, 08h, 22h, 41h
		db	 08h, 82h, 80h, 42h, 11h, 4Bh
		db	 11h, 41h, 0Ah,0A0h,0A0h,0A0h
		db	 11h, 0Ah,0A8h, 11h, 80h, 02h
		db	 11h, 41h, 2Ah, 43h, 28h, 41h
		db	 28h, 82h,0A0h, 41h, 11h, 02h
		db	0A0h, 08h, 0Ah, 43h, 02h, 43h
		db	 2Ah, 02h, 2Ah, 41h, 11h, 0Ah
		db	 8Ah, 08h, 28h, 43h, 0Ah, 03h
		db	 3Fh,0EBh, 3Fh,0FFh, 8Bh,0BAh
		db	0E8h,0EAh,0FAh, 11h, 0Ah, 0Ah
		db	 11h,0BAh, 8Fh, 11h,0E8h,0EAh
		db	0A8h,0ABh, 11h, 41h, 0Ah, 3Ah
		db	0BAh,0A8h, 0Ah, 11h,0A0h, 42h
		db	 82h,0BAh, 08h, 0Ah, 0Ah, 11h
		db	 41h, 02h,0E8h, 42h, 02h, 80h
		db	 28h, 08h, 8Ah, 3Bh, 80h, 41h
		db	 02h,0E0h, 44h, 28h, 41h, 0Ah
		db	 3Bh, 80h, 08h, 02h,0A0h, 80h
		db	 42h, 80h, 42h, 8Ah, 0Eh, 80h
		db	 41h, 03h,0A0h, 41h, 80h, 41h
		db	 80h, 20h, 20h, 8Ah, 3Ah, 80h
		db	 41h, 02h,0E0h, 41h, 80h, 43h
		db	0A0h, 0Ah, 3Eh, 82h, 08h, 02h
		db	0A0h, 02h, 41h, 20h, 80h, 42h
		db	 0Ah, 0Ah, 02h, 08h, 41h,0A0h
		db	 02h, 42h, 08h, 08h, 41h, 0Ah
		db	 28h, 41h, 0Eh, 42h, 02h, 80h
		db	 20h, 43h, 0Ah, 42h, 08h, 42h
		db	 82h,0A8h, 42h, 02h, 41h, 0Ah
		db	 42h, 8Ch, 42h, 80h,0A0h
		db	' C', 0Ah, 'B', 8, 'E8 A'
		db	8Ah
		db	'A', 8, 0Ah, 'B B:A"', 0Ah, 'A', 8
		db	0Ah, 'C'
		db	 80h, 80h
		db	0Ah, 'A ', 0Ah, 'A8', 0Ah, 'A'
		db	 80h, 41h, 80h, 41h, 38h, 41h
		db	 02h
		db	0Ah, 'A ', 0Ah, 'B  A8'
		db	 02h, 08h, 8Ah
		db	'A ', 8, 'A" B8A', 0Ah, 0Ah, 'A ', 0Ah
		db	'A'
		db	 02h, 41h, 80h, 08h, 28h, 41h
		db	 08h, 0Ah, 02h, 41h, 2Ah, 41h
		db	 02h, 42h, 08h, 3Bh, 41h, 22h
		db	 0Ah, 02h, 41h, 38h, 41h, 82h
		db	'B(*A', 8, 0Ah, 0Ah, ' (A'
		db	 0Bh, 43h, 3Ah, 41h,0A0h, 0Ah
		db	 0Ah, 28h, 0Ah, 41h, 0Ah, 80h
		db	 41h, 80h,0E8h, 41h, 88h, 0Ah
		db	 0Ah, 22h, 2Eh, 41h, 0Bh, 82h
		db	 80h, 88h,0EAh, 0Ah, 20h, 0Ah
		db	 0Ah,0E0h, 2Eh, 41h, 0Eh, 0Ah
		db	0EEh, 0Ah, 88h, 08h, 88h, 0Ah
		db	 0Ah, 20h,0EAh, 41h,0A8h, 8Bh
		db	0A2h,0A8h, 11h, 41h, 20h, 0Ah
		db	 0Ah,0E0h, 8Ah, 82h, 3Ah, 03h
		db	 88h,0BAh, 88h, 80h, 88h, 0Ah
		db	 0Ah, 20h,0EAh, 02h,0BAh, 88h
		db	0A0h,0CAh, 0Ah, 20h, 20h, 0Ah
		db	 0Ah,0B0h,0ACh, 12h, 0Ah, 2Ah
		db	0E2h, 8Ah, 20h, 88h, 0Ah, 0Ah
		db	0A2h,0AEh, 22h,0E8h, 82h,0A2h
		db	0CAh, 28h, 82h, 20h, 0Ah, 0Ah
		db	0E2h,0A8h, 22h,0EAh, 08h, 11h
		db	0A8h, 88h,0A0h, 08h, 0Ah, 0Bh
		db	0A8h,0A2h, 3Ah,0A8h,0A3h,0A8h
		db	 82h, 22h, 22h, 41h, 0Ah, 0Ah
		db	 11h, 88h, 8Ah, 22h, 02h,0A2h
		db	 22h, 88h, 88h, 41h, 0Ah, 08h
		db	 22h, 20h, 2Ah, 82h, 20h, 02h
		db	 08h, 20h, 42h, 0Ah, 00h,0DFh
		db	0DFh,0DFh,0DBh
		db	10 dup (5Fh)
		db	 54h,0AFh,0D5h,0F2h,0AFh,0D5h
		db	0F2h, 59h, 4Fh, 4Ah, 02h, 57h
		db	0AFh,0D5h,0F2h,0AFh,0D5h,0F2h
		db	 59h, 4Fh, 4Ah, 02h, 57h,0AFh
		db	 45h,0F2h,0AFh, 45h,0F2h, 59h
		db	 4Fh, 4Ah, 02h, 57h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 59h, 4Fh
		db	 4Ah, 02h, 57h,0AFh, 45h,0F2h
		db	0AFh, 45h,0F2h, 59h, 4Fh, 4Ah
		db	 02h, 57h,0AFh, 45h,0F2h,0AFh
		db	 45h,0F2h, 59h, 4Fh, 4Ah, 02h
		db	 57h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h, 4Fh, 4Ah, 02h, 57h
		db	0AFh, 45h,0F2h,0AFh, 45h,0F2h
		db	 59h,0C0h, 45h, 30h, 45h, 0Ch
		db	 45h, 03h, 46h,0C2h,0AFh,0D5h
		db	0F2h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h,0C0h, 30h, 0Ch, 03h
		db	 41h,0C0h, 30h, 0Ch, 03h, 41h
		db	0C0h, 30h, 0Ch, 03h, 41h,0C0h
		db	 30h, 0Ch, 03h, 41h,0C0h, 30h
		db	 0Ch, 03h, 41h,0C2h,0AFh,0D5h
		db	0F2h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h, 59h,0DFh,0DAh,0C2h,0AFh
		db	 45h,0F2h,0AFh, 45h,0F2h,0AFh
data_77		db	45h			; Data table (indexed access)
		db	0F2h
data_78		dw	5F5Fh			; Data table (indexed access)
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh, 45h,0F2h,0AFh, 45h
		db	0F2h,0AFh, 45h,0F2h, 5Fh, 5Fh
		db	 55h,0AFh
		db	45h
data_79		dw	0AFF2h			; Data table (indexed access)
		db	 45h,0F2h,0AFh, 45h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0AFh
		db	0D5h,0F2h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0AFh
		db	0D5h,0F2h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h,0A0h
		db	 45h, 02h,0A0h, 45h, 02h, 5Fh
		db	 5Fh, 55h,0AFh, 45h,0F2h, 5Fh
		db	 5Fh, 5Fh, 54h,0AFh, 45h,0F2h
		db	 5Fh, 5Fh, 5Fh, 54h,0AFh, 45h
		db	0F2h
		db	5Fh
data_80		dw	5F5Fh, 0AF54h		; Data table (indexed access)
		db	 45h,0F2h, 5Fh, 5Fh, 5Fh, 54h
		db	0AFh, 45h,0F2h, 5Fh, 5Fh, 5Fh
		db	 54h,0AFh,0D5h,0F2h, 5Fh, 5Fh
		db	 5Fh, 54h,0AFh,0D5h,0F2h, 5Fh
		db	 5Fh, 5Fh, 54h,0A0h, 45h, 02h
		db	30 dup (5Fh)
		db	 5Ch, 00h

seg_a		ends

		end	start
