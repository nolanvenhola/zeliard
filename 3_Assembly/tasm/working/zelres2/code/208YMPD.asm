
PAGE  59,132

;==========================================================================
;
;  208YMPD - Satono Town Background Renderer (YMPD.BIN, zelres2 chunk 9)
;
;  Decodes and renders the mountain + ground scenery backdrop that is
;  drawn behind the Satono town building interior dialogs. Loaded by the
;  town program at CS:+3300h in the game segment.
;
;  Entry (AL = video_mode):
;    2 = EGA/VGA planar (A000h)     5 = Hercules   (B000h)
;    3 = CGA/Tandy      (B800h)     6 = MCGA 320x200 (A000h, byte-per-pixel)
;    4 = CGA/Tandy      (B800h)     7 = CGA alt    (B800h)
;  (Dispatch is via 'jmp [bx+0x338A]' with bx=video_mode*2; entries 0..1
;  alias the jmp instruction's own bytes and are never reached in practice.)
;
;  Pipeline per entry:
;    1. Zero decompression buffer at seg1:0000..seg1:4CFF (CS+1000h:0-0x4CFF)
;    2. RLE-decode mountains0 data -> seg1:0000 (88x56 byte tile bitmap)
;    3. RLE-decode mountains1 data -> seg1:1340h (second 88x56 tile bitmap)
;    4. Dispatch render_mountains via jpt_mountains_render[video_mode*2]
;    5. RLE-extract ground  -> seg1:0000  (16 rows x 28 bytes = 448 bytes)
;    6. RLE-extract ground1 -> seg1:01C0h (16 rows x 28 bytes)
;    7. Dispatch render_ground via jpt_ground_render[video_mode*2]
;
;  Key subsystems:
;    satono_bg_main            - main entry (far), decompresses + renders both layers
;    rle_decode_mountain_88x56 - 88x56 RLE decoder (opcode 06h = 2-byte fill)
;    rle_decode_ground_28      - 28-byte-per-row RLE (high-nibble 6 = zero-run)
;    render_mountains          - dispatch by video_mode -> mountains_*
;    render_ground             - dispatch by video_mode -> ground_*
;    mountains_ega             - EGA planar mountain render (map mask regs)
;    mountains_cga             - CGA mountain render via 4-plane LUT
;    mountains_hgc             - Hercules mountain render (B000h)
;    mountains_mcga            - MCGA mountain render (one byte per pixel)
;    mountains_cgaalt          - CGA alt mountain render (CS:357D LUT)
;    ground_ega                - EGA planar ground render
;    ground_cga                - CGA ground render
;    ground_hgc                - Hercules ground render
;    ground_mcga               - MCGA ground render (interleaved planes)
;    ground_cgaalt             - CGA alt ground render (cga_alt_lut_a / _b)
;    pixel_expand_mcga         - expand 2 source bytes -> 1 MCGA pixel byte
;    pixel_expand_cga          - expand 2 source bytes -> 2-bit CGA pixel pair
;    pixel_expand_cgaalt       - expand 2 source bytes -> 2-bit CGA alt pair
;    copy_28b_ega              - EGA plane copy helper (1Ch bytes per plane)
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; --- Internal CS-relative addresses (loaded at CS:+3300h in game_seg) ---
video_mode		equ	335Bh			; byte: rendering mode 0..5 (AL on entry)
jpt_mountains_render	equ	338Ah			; dw table [6] : mountain render per mode
cga_color_lut_mountains	equ	3432h			; db[16] : CGA 4-plane -> 2bpp LUT (mountains)
cga_color_lut_alt_mount	equ	357Dh			; db[16] : CGA alt 4-plane LUT (mountains)
jpt_ground_render	equ	35BBh			; dw table [6] : ground render per mode
cga_color_lut_ground	equ	36B6h			; db[16] : CGA 4-plane -> 2bpp LUT (ground)
ground1_src_ofs		equ	56F1h			; ground1 RLE-source offset (CS:56F1) loaded into SI

; --- Constants referenced only by Sourcer's commented-out mis-decoded bytes ---
data_15e		equ	3C30h			;* inside mountains1 data (mis-decoded ';*' fake instruction)
data_19e		equ	0FD57h			;* inside ground1 data    (mis-decoded ';*' fake instruction)

; --- Source/destination offsets into the CS+1000h decompression scratch segment ---
seg1_buf_base		equ	0			; seg1:0000 - mountains0 / ground decode destination
seg1_mountains1_buf	equ	1340h			; seg1:1340 - mountains1 decode destination
seg1_ground1_buf	equ	01C0h			; seg1:01C0 - ground1 decode destination (not referenced by name - 448 byte offset)

; --- External video-memory destination offsets (A000h / B000h / B800h) ---
ega_ground_dst_0	equ	2C6Ch			; EGA ground render base (A000:2C6C)
ega_ground_copy_dst	equ	2C88h			; EGA ground plane-copy destination (A000:2C88)
cga_ground_dst		equ	163Ch			; CGA ground start offset (B800:163C)
cga_mountain_dst	equ	23Ch			; CGA mountain start offset (B800:023C)
mcga_mountain_row_ptr	equ	0B1B0h			; MCGA row 14 col 48 (A000:B1B0)
mcga_mountain_dst_a	equ	0B220h			; MCGA mountain half A copy dest (A000:B220)
mcga_ground_dst		equ	0BBB0h			; MCGA ground destination (A000:BBB0)

; --- Video-mode dispatch state ---
ega_wrap_addend		equ	0C050h			; EGA wrap-around offset addend (used by modes 1,3,5)
cga_wrap_limit		equ	6000h			; CGA wrap limit (mode3_hgc)
ega_wrap_limit		equ	4000h			; EGA/CGA wrap limit

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

satono_bg_main	proc	far

start:
		db	 65h, 25h, 00h, 00h	; 'gs: and ax,0' (4-byte 286+ GS-override nop;
						;  keeps AL=video_mode unaffected)
		mov	cs:video_mode,al	; store video_mode byte (2E A2 5B 33)
		mov	dx,cs
		mov	ds,dx
		add	dx,1000h
		mov	es,dx			; ES = seg1 = CS+1000h (decompression scratch)
		cld
		mov	di,0
		mov	cx,2680h
		xor	ax,ax
		rep	stosw			; zero seg1:0000..seg1:4CFFh (9728 words)
		mov	dx,cs
		add	dx,1000h
		mov	es,dx			; restore ES = seg1
		mov	si,38E7h		; offset mountains0 (runtime CS:38E7)
		mov	di,0
		call	rle_decode_mountain_88x56	; unpack to seg1:0000
		mov	si,4759h		; offset mountains1
		mov	di,1340h
		call	rle_decode_mountain_88x56	; unpack to seg1:1340h
		call	render_mountains	; draw mountain layer for current video_mode
		mov	dx,cs
		add	dx,1000h
		mov	es,dx
		mov	di,0
		mov	si,559Eh		; offset ground (runtime CS:559E)
		mov	cx,10h			; 16 rows

gnd0_rle_loop:
				call	rle_decode_ground_28	; 16 rows x 28 bytes from ground0
				loop	gnd0_rle_loop

		mov	si,ground1_src_ofs
		mov	cx,10h

gnd1_rle_loop:
				call	rle_decode_ground_28	; 16 rows x 28 bytes from ground1
				loop	gnd1_rle_loop

		call	render_ground
		retf				; Return far
		db	 00h			; 1-byte padding after main proc retf

; --- rle_decode_mountain_88x56 ---
; 88x56 RLE decoder for mountain layer (opcode 6 = 2-byte fill).
; Called from main with SI=source, DI=dest (seg1:0 or seg1:1340h).

rle_decode_mountain_88x56:
		xor	cx,cx			; Zero register (CH=col, CL=row)

rle_mntn_loop:
				lodsb				; String [si] to al
				cmp	al,6
				mov	ah,1
				jnz	rle_mntn_store		; Jump if not zero
				lodsw				; String [si] to ax (AL=pixel, AH=count)

rle_mntn_store:
						stosb				; Store al to es:[di]
						inc	ch
						cmp	ch,38h			; 56 rows
						jne	rle_mntn_more		; Jump if not equal
						xor	ch,ch			; Zero register
						inc	cl
						cmp	cl,58h			; 88 cols
						jne	rle_mntn_more		; Jump if not equal
						retn

rle_mntn_more:
						dec	ah
						jnz	rle_mntn_store		; Jump if not zero
				jmp	short rle_mntn_loop

; --- render_mountains ---
; Dispatch by video_mode: jmp [bx + 0x338A] where bx=video_mode*2.
; Disp16 0x338A overlaps with the dispatch-table storage ?-- the first two
; table WORDs (at 0x338A/0x338C) are the jmp opcode/disp bytes themselves,
; so only entries 2..7 (video_mode values 2..7) are real handler pointers.

render_mountains:
		xor	bx,bx			; Zero register
		mov	bl,ds:video_mode
		add	bx,bx
		jmp	word ptr ds:jpt_mountains_render[bx]	;* jmp [bx+0x338A]

; --- jpt_mountains_render continuation (6 word entries starting at 0x338E) ---
; Bytes here are the handler-pointer words fetched by the jmp above.
; Each 'dw' value is the runtime CS-offset of the selected handler.
		dw	3396h			; entry 2: mountains_ega   (file 0x96)
		dw	33D1h			; entry 3: mountains_cga   (file 0xD1)
		dw	33D1h			; entry 4: mountains_cga   (duplicate)
		dw	3442h			; entry 5: mountains_hgc   (file 0x142)
		dw	34B8h			; entry 6: mountains_mcga  (file 0x1B8)
		dw	3510h			; entry 7: mountains_cgaalt(file 0x210)

; --- mountains_ega (video_mode 2): EGA planar mountain render to A000h ---
; Landing target for handler entry 2. The 6 bytes starting at file 0x96
; are *also* the last 3 dw entries of the dispatch table above, but they
; are never executed as code ?-- the jmp skips over them to here at 0x9A.

mountains_ega:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	ax,0A000h
		mov	es,ax
		mov	dx,3C4h			; EGA sequencer address port
		mov	al,2			; map-mask register
		out	dx,al
		inc	dx			; 3C5h sequencer data
		mov	al,1			; plane 0
		out	dx,al
		call	ega_mtn_blit_88_rows
		mov	al,4			; plane 2
		out	dx,al
		call	ega_mtn_blit_88_rows
		pop	ds
		retn

ega_mtn_blit_88_rows:
		mov	di,46Ch			; EGA starting VGA offset
		mov	cx,58h			; 88 rows

ega_mtn_row_loop:
				push	cx
				push	di
				mov	cx,38h			; 56 bytes per row
				rep	movsb			; copy row from seg1 to A000
				pop	di
				add	di,50h			; next EGA row (80 bytes)
				pop	cx
				loop	ega_mtn_row_loop

		retn

; --- mountains_cga (video_mode 3 or 4): CGA/Tandy 4-color mountain render ---

mountains_cga:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0B800h
		mov	es,ax
		mov	di,cga_mountain_dst	; B800:023C
		mov	cx,58h			; 88 scanlines

cga_mtn_row_loop:
				push	cx
				push	di
				mov	cx,38h			; 56 dest bytes per row

cga_mtn_col_loop:
						push	cx
						mov	ah,ds:seg1_mountains1_buf[si]	; plane B source
						lodsb				; plane A source
						xor	dl,dl			; Zero register
						mov	cx,4

cga_mtn_expand_loop:
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
						or	dl,cs:cga_color_lut_mountains[bx]
						loop	cga_mtn_expand_loop	; Loop if cx > 0

						mov	al,dl
						stosb				; Store al to es:[di]
						pop	cx
						loop	cga_mtn_col_loop	; Loop if cx > 0

				pop	di
				add	di,2000h		; next CGA interlaced bank
				cmp	di,ega_wrap_limit	; 0x4000
				jb	cga_mtn_no_wrap
				add	di,ega_wrap_addend	; wrap to next 4 scanlines

cga_mtn_no_wrap:
				pop	cx
				loop	cga_mtn_row_loop

		pop	ds
		retn
		db	 00h, 03h, 01h, 02h, 00h, 03h	; cga_color_lut_mountains bytes (4..15)
		db	 01h, 02h, 00h, 03h, 01h, 02h	; (first 4 bytes overlap with loop/retn above)
		db	 00h, 03h, 01h, 02h

; --- mountains_hgc (video_mode 5): Hercules 720x348 mono render at B000h ---

mountains_hgc:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	ax,0B000h
		mov	es,ax
		mov	di,4FDh			; Hercules destination offset
		mov	cx,58h			; 88 scanlines

hgc_mtn_row_loop:
				push	cx
				push	di
				mov	cx,38h			; 56 bytes per row

hgc_mtn_col_loop:
						push	cx
						mov	ah,ds:seg1_mountains1_buf[si]	; plane B source
						lodsb				; plane A source
						xor	dl,dl			; Zero register
						mov	cx,4

hgc_mtn_expand_loop:
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
						or	dl,cs:cga_color_lut_mountains[bx]
						loop	hgc_mtn_expand_loop	; Loop if cx > 0

						mov	al,dl
						stosb				; Store al to es:[di]
						pop	cx
						loop	hgc_mtn_col_loop	; Loop if cx > 0

				pop	di
				add	di,2000h		; next HGC bank
				cmp	di,cga_wrap_limit	; 0x6000
				jb	hgc_mtn_no_wrap		; below -> no wrap
				push	ds			; above limit: copy row forward and wrap
				push	si
				push	cx
				push	di
				push	es
				pop	ds
				mov	si,di
				sub	si,2000h
				mov	cx,38h
				rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
				pop	di
				pop	cx
				pop	si
				pop	ds
				add	di,0A05Ah		; HGC wrap addend

hgc_mtn_no_wrap:
				pop	cx
				loop	hgc_mtn_row_loop

		pop	ds
		retn

; --- mountains_mcga (video_mode 6): MCGA 320x200 byte-per-pixel at A000h ---

mountains_mcga:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0A000h
		mov	es,ax
		mov	di,11B0h		; MCGA destination (row 14, col 48)
		mov	cx,58h			; 88 scanlines

mcga_mtn_row_loop:
				push	cx
				push	di
				mov	cx,38h			; 56 pixel-pairs per row

mcga_mtn_col_loop:
						push	cx
						mov	dh,ds:seg1_mountains1_buf[si]
						mov	dl,[si]
						inc	si
						call	pixel_expand_mcga
						stosb				; Store al to es:[di]
						call	pixel_expand_mcga
						stosb				; Store al to es:[di]
						call	pixel_expand_mcga
						stosb				; Store al to es:[di]
						call	pixel_expand_mcga
						stosb				; Store al to es:[di]
						pop	cx
						loop	mcga_mtn_col_loop

				pop	di
				add	di,140h			; next MCGA scanline (320)
				pop	cx
				loop	mcga_mtn_row_loop

		pop	ds
		retn

satono_bg_main	endp

pixel_expand_mcga		proc	near
		xor	al,al			; Zero register
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		add	dh,dh
		adc	al,al
		add	al,al
		add	dl,dl
		adc	al,al
		retn

pixel_expand_mcga		endp

; --- mountains_cgaalt (video_mode 7): CGA alt-mode 4-color mountain render ---
; Uses cga_color_lut_alt_mount via pixel_expand_cga (reads from CS:357D).

mountains_cgaalt:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0B800h
		mov	es,ax
		mov	di,41F8h		; CGA alt destination offset
		mov	cx,58h			; 88 scanlines

cgaalt_mtn_row_loop:
				push	cx
				push	di
				mov	cx,38h

cgaalt_mtn_col_loop:
						push	cx
						mov	dh,ds:seg1_mountains1_buf[si]	; plane B source
						mov	dl,[si]				; plane A source
						inc	si
						call	pixel_expand_cga
						stosb				; Store al to es:[di]
						call	pixel_expand_cga
						stosb				; Store al to es:[di]
						pop	cx
						loop	cgaalt_mtn_col_loop

				pop	di
				add	di,2000h
				cmp	di,8000h
				jb	cgaalt_mtn_no_wrap
				add	di,80A0h

cgaalt_mtn_no_wrap:
				pop	cx
				loop	cgaalt_mtn_row_loop

		pop	ds
		retn

pixel_expand_cga		proc	near
		xor	al,al			; Zero register
		mov	cx,2

cga_expand_iter:
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
				or	al,cs:cga_color_lut_alt_mount[bx]
				loop	cga_expand_iter

		retn

pixel_expand_cga		endp

; --- cga_color_lut_alt_mount_lbl (CS:357D referenced with bx in 0-15) ---

cga_color_lut_alt_mount_lbl:
		db	 00h, 07h, 09h, 01h, 07h, 0Fh
		db	 0Bh, 07h, 09h, 0Bh, 0Bh, 03h
		db	 01h, 07h, 03h
		db	9			; last LUT byte (also serves as 'push cs' stall byte?)

; --- rle_decode_ground_28 (equiv IDA RLE_extract_28_bytes) ---
; 28-byte-per-row RLE decoder: high-nibble=6 means "emit low_nibble zeros",
; anything else emits the byte literally. Emits until 28 bytes written.

rle_decode_ground_28		proc	near
		xor	bl,bl			; Zero register (output count)

rle_gnd_next_byte:
				lodsb				; String [si] to al
				mov	ah,al
				and	ah,0F0h			; high nibble
				cmp	ah,60h			; '6' prefix = zero-run
				mov	ah,1
				jnz	rle_gnd_emit		; normal literal
				and	al,0Fh			; low nibble = count
				mov	ah,al
				xor	al,al			; emit zeros

rle_gnd_emit:
						stosb
						inc	bl
						dec	ah
						jnz	rle_gnd_emit		; repeat (count)
				cmp	bl,1Ch			; 28 bytes written?
				jne	rle_gnd_next_byte
		retn

rle_decode_ground_28		endp

; --- render_ground ---
; Dispatch by video_mode: jmp [bx + 0x35BB] where bx = video_mode*2.
; Same overlap pattern as render_mountains: first 4 table bytes are the jmp
; opcode/disp. Entries at 0x35BF onward select one of the ground_* handlers.

render_ground		proc	near
		xor	bx,bx
		mov	bl,ds:video_mode
		add	bx,bx
		jmp	word ptr ds:jpt_ground_render[bx]	;* jmp [bx+0x35BB]

render_ground		endp

; --- jpt_ground_render continuation (6 word entries at 0x35BF) ---
		dw	35C7h			; entry 2: ground_ega    (file 0x2C7)
		dw	3643h			; entry 3: ground_cga    (file 0x343)
		dw	3643h			; entry 4: ground_cga    (duplicate)
		dw	36C6h			; entry 5: ground_hgc    (file 0x3C6)
		dw	374Eh			; entry 6: ground_mcga   (file 0x44E)
		dw	3800h			; entry 7: ground_cgaalt (file 0x500)

; --- ground_ega (video_mode 2): EGA planar ground render to A000h ---
; Uses two write passes (plane 2 then plane 1) via the EGA map mask reg,
; then a GR mode-register switch to set up VGA odd-even mode for the final
; stride-adjusted copy pass.

ground_ega:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	ax,0A000h
		mov	es,ax
		mov	di,ega_ground_dst_0	; 0x2C6C
		mov	dx,3C4h			; EGA sequencer address port
		mov	al,2			; map-mask register
		out	dx,al
		inc	dx			; 3C5h sequencer data
		mov	cx,8			; 8 plane-selection iterations

ega_gnd_pass_a_loop:
				mov	al,4			; plane 2
				out	dx,al
				call	copy_28b_ega
				mov	al,2			; plane 1
				out	dx,al
				call	copy_28b_ega
				add	di,50h			; next EGA row (80 bytes)
				loop	ega_gnd_pass_a_loop

		mov	di,2EECh		; second pass destination
		mov	cx,8

ega_gnd_pass_b_loop:
				mov	al,1			; plane 0
				out	dx,al
				call	copy_28b_ega
				mov	al,2			; plane 1
				out	dx,al
				call	copy_28b_ega
				add	di,50h			; next EGA row
				loop	ega_gnd_pass_b_loop

		mov	al,7			; re-enable all planes
		out	dx,al
		mov	dx,3CEh			; EGA graphics controller index
		mov	ax,105h			; al=5 (GC mode reg), ah=1 (mode=1 odd-even)
		out	dx,ax
		push	es
		pop	ds
		mov	si,ega_ground_dst_0	; 0x2C6C
		mov	di,ega_ground_copy_dst	; 0x2C88
		mov	ah,10h			; 16 rows to duplicate

ega_gnd_dup_loop:
				mov	cx,1Ch
				rep	movsb			; copy 28 bytes
				add	di,34h			; next dest row stride
				add	si,34h			; next src row stride
				dec	ah
				jnz	ega_gnd_dup_loop
		mov	dx,3CEh
		mov	ax,5			; restore GC mode 0
		out	dx,ax
		pop	ds
		retn

copy_28b_ega		proc	near
		push	di
		push	cx
		mov	cx,1Ch
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		pop	cx
		pop	di
		retn

copy_28b_ega		endp

; --- ground_cga (video_mode 3 or 4): CGA/Tandy 4-color ground render to B800h ---

ground_cga:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0B800h
		mov	es,ax
		mov	di,cga_ground_dst	; B800:163C
		mov	cx,10h			; 16 scanlines

cga_gnd_row_loop:
				push	cx
				push	di
				mov	cx,1Ch			; 28 dest bytes per row

cga_gnd_col_loop:
						push	cx
						mov	ah,[si+1Ch]		; plane B (seg1_ground1_buf)
						lodsb				; plane A
						xor	dl,dl			; Zero register
						mov	cx,4

cga_gnd_expand_loop:
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
						or	dl,cs:cga_color_lut_ground[bx]
						loop	cga_gnd_expand_loop

						mov	al,dl
						stosb				; Store al to es:[di]
						pop	cx
						loop	cga_gnd_col_loop

				push	ds
				push	si
				push	es
				pop	ds
				mov	si,di
				sub	si,1Ch
				mov	cx,0Eh
				rep	movsw			; duplicate row forward (14 words)
				pop	si
				pop	ds
				add	si,1Ch
				pop	di
				add	di,2000h		; next CGA bank
				cmp	di,ega_wrap_limit
				jb	cga_gnd_no_wrap
				add	di,ega_wrap_addend

cga_gnd_no_wrap:
				pop	cx
				loop	cga_gnd_row_loop

		pop	ds
		retn
		db	 00h, 03h, 02h, 01h, 01h, 03h	; cga_color_lut_ground bytes (0..15)
		db	 03h, 03h, 02h, 03h, 01h, 02h
		db	 02h, 03h, 03h, 03h

; --- ground_hgc (video_mode 5): Hercules 720x348 mono ground render at B000h ---

ground_hgc:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,0
		mov	ax,0B000h
		mov	es,ax
		mov	di,53C1h
		mov	cx,16				; scanlines

hgc_gnd_row_loop:
				push	cx
				push	di
				mov	cx,1Ch			; 28 bytes per row

hgc_gnd_col_loop:
						push	cx
						mov	ah,[si+1Ch]		; plane B
						lodsb				; plane A
						xor	dl,dl			; Zero register
						mov	cx,4

hgc_gnd_expand_loop:
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
						or	dl,cs:cga_color_lut_ground[bx]
						loop	hgc_gnd_expand_loop

						mov	al,dl
						stosb
						pop	cx
						loop	hgc_gnd_col_loop

				push	ds
				push	si
				push	es
				pop	ds
				mov	si,di
				sub	si,1Ch
				mov	cx,0Eh
				rep	movsw			; duplicate row forward (14 words)
				pop	si
				pop	ds
				add	si,1Ch
				pop	di
				add	di,2000h		; next HGC bank
				cmp	di,cga_wrap_limit	; 0x6000
				jb	hgc_gnd_no_wrap
				push	ds
				push	si
				push	cx
				push	di
				push	es
				pop	ds
				mov	si,di
				sub	si,2000h
				mov	cx,38h
				rep	movsb			; wrap-copy 56 bytes
				pop	di
				pop	cx
				pop	si
				pop	ds
				add	di,0A05Ah		; HGC wrap addend

hgc_gnd_no_wrap:
				pop	cx
				loop	hgc_gnd_row_loop

		pop	ds
		retn

; --- ground_mcga (video_mode 6): MCGA 320x200 byte-per-pixel ground render ---
; Writes two horizontally-tiled ground bands, then duplicates to right half.

ground_mcga:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0A000h
		mov	es,ax
		mov	di,mcga_mountain_row_ptr	; 0xB1B0 (row 14+16*8, col 48)
		mov	cx,8			; 8 tile rows

mcga_gnd_a_row_loop:
				push	cx
				push	si
				push	di
				mov	cx,0Eh			; 14 tiles per row

mcga_gnd_a_tile_loop:
						push	cx
						mov	dx,[si]
						mov	bx,[si+1Ch]
						xchg	dl,dh
						xchg	bl,bh
						mov	cx,8

mcga_gnd_a_pix_loop:
						xor	al,al			; Zero register
						add	dx,dx
						adc	al,al
						add	bx,bx
						adc	al,al
						add	al,al
						add	dx,dx
						adc	al,al
						add	bx,bx
						adc	al,al
						add	al,al
						stosb
						loop	mcga_gnd_a_pix_loop

						inc	si
						inc	si
						pop	cx
						loop	mcga_gnd_a_tile_loop

				pop	di
				add	di,140h			; next MCGA scanline
				pop	si
				add	si,38h			; next tile-row source stride
				pop	cx
				loop	mcga_gnd_a_row_loop

		mov	di,mcga_ground_dst	; 0xBBB0 (second band)
		mov	cx,8

mcga_gnd_b_row_loop:
				push	cx
				push	si
				push	di
				mov	cx,0Eh

mcga_gnd_b_tile_loop:
						push	cx
						mov	bx,[si]
						mov	dx,[si+1Ch]
						xchg	dl,dh
						xchg	bl,bh
						mov	cx,8

mcga_gnd_b_pix_loop:
						xor	al,al
						add	dx,dx
						adc	al,al
						add	bx,bx
						adc	al,al
						add	al,al
						add	dx,dx
						adc	al,al
						add	bx,bx
						adc	al,al
						stosb
						loop	mcga_gnd_b_pix_loop

						inc	si
						inc	si
						pop	cx
						loop	mcga_gnd_b_tile_loop

				pop	di
				add	di,140h
				pop	si
				add	si,38h
				pop	cx
				loop	mcga_gnd_b_row_loop

		push	es
		pop	ds
		mov	si,mcga_mountain_row_ptr	; src = first band
		mov	di,mcga_mountain_dst_a		; dst = right half
		mov	ah,10h			; 16 rows

mcga_gnd_dup_loop:
				mov	cx,38h			; 56 words per row
				rep	movsw
				add	di,0D0h			; next row dst stride
				add	si,0D0h			; next row src stride
				dec	ah
				jnz	mcga_gnd_dup_loop
		pop	ds
		retn

; --- ground_cgaalt (video_mode 7): CGA alt 4-color ground render (B800h) ---
; Uses pixel_expand_cgaalt with LUT pointer in BP (byte_38C7 or byte_38D7).

ground_cgaalt:
		push	ds
		mov	dx,cs
		add	dx,1000h
		mov	ds,dx
		mov	si,seg1_buf_base
		mov	ax,0B800h
		mov	es,ax
		mov	di,55F8h		; CGA alt destination
		mov	cx,8			; 8 scanlines (first band)

cgaalt_gnd_a_row_loop:
				push	cx
				push	di
				mov	cx,1Ch

cgaalt_gnd_a_col_loop:
						push	cx
						mov	dh,[si+1Ch]
						mov	dl,[si]
						inc	si
						mov	bp,38C7h		; cga_alt_lut_a base
						call	pixel_expand_cgaalt
						stosb
						call	pixel_expand_cgaalt
						stosb
						pop	cx
						loop	cgaalt_gnd_a_col_loop

				push	ds
				push	si
				push	es
				pop	ds
				mov	si,di
				sub	si,38h
				mov	cx,1Ch
				rep	movsw			; duplicate row forward (28 words)
				pop	si
				pop	ds
				add	si,1Ch
				pop	di
				add	di,2000h
				cmp	di,8000h
				jb	cgaalt_gnd_a_no_wrap
				add	di,80A0h

cgaalt_gnd_a_no_wrap:
				pop	cx
				loop	cgaalt_gnd_a_row_loop

		mov	di,5738h		; second band destination
		mov	cx,8

cgaalt_gnd_b_row_loop:
				push	cx
				push	di
				mov	cx,1Ch

cgaalt_gnd_b_col_loop:
						push	cx
						mov	dh,[si+1Ch]
						mov	dl,[si]
						inc	si
						mov	bp,38D7h		; cga_alt_lut_b base
						call	pixel_expand_cgaalt
						stosb
						call	pixel_expand_cgaalt
						stosb
						pop	cx
						loop	cgaalt_gnd_b_col_loop

				push	ds
				push	si
				push	es
				pop	ds
				mov	si,di
				sub	si,38h
				mov	cx,1Ch
				rep	movsw			; duplicate row forward
				pop	si
				pop	ds
				add	si,1Ch
				pop	di
				add	di,2000h
				cmp	di,8000h
				jb	cgaalt_gnd_b_no_wrap
				add	di,80A0h

cgaalt_gnd_b_no_wrap:
				pop	cx
				loop	cgaalt_gnd_b_row_loop

		pop	ds
		retn

pixel_expand_cgaalt		proc	near
		xor	al,al			; Zero register
		mov	cx,2

cgaalt_expand_iter:
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
				add	bx,bp			; add LUT base (byte_38C7 or byte_38D7)
				or	al,cs:[bx]
				loop	cgaalt_expand_iter

		retn

pixel_expand_cgaalt		endp

; --- cga_alt_lut_a (byte_38C7 in IDA): ground_cgaalt primary LUT ---

cga_alt_lut_a:
		db	 00h, 03h, 04h, 07h, 03h, 0Bh
		db	 05h, 0Ah, 04h, 05h, 0Ch, 06h
		db	 07h, 0Ah, 06h, 0Eh
; --- cga_alt_lut_b (byte_38D7 in IDA): ground_cgaalt secondary LUT ---

cga_alt_lut_b:
		db	 00h, 07h, 04h, 02h, 07h, 0Fh
		db	 0Ch, 0Eh, 04h, 0Ch, 0Ch, 02h

; ==========================================================================
; mountains0: 88x56 RLE source bitmap for the 'distant' mountain layer.
; Decoded by rle_decode_mountain_88x56 into seg1:0000.
; Format: opcode 06h = 2-byte fill (length+pixel), else emit 1 literal byte.
; Note: cga_alt_lut_b's last byte 0x02 above acts as an initial literal here.
; ==========================================================================

mountains0:
		db	 02h, 0Eh, 02h, 0Ah		; initial literals before first 06h fill
		db	 06h,0AAh, 70h,0BBh		; 06h fill: 0xAA x 112
		db	0FBh,0BFh,0BBh,0BFh,0BBh,0BBh
		db	0FFh,0BBh,0BBh,0BFh, 06h,0BBh
		db	 08h,0FBh,0FFh,0FFh,0BBh,0BFh
		db	0FBh, 06h,0BBh, 10h,0FFh,0FFh
		db	0FBh, 06h,0BBh, 0Ch,0FEh,0FEh
		db	0FEh,0FFh,0FEh,0EFh,0FFh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0EEh,0EEh
		db	0EFh,0FEh,0EFh,0FFh,0FFh,0FEh
		db	0FFh,0EEh,0EFh,0FFh,0FFh,0FFh
		db	0EEh,0EFh,0EEh,0EFh,0FEh,0FFh
		db	0EFh,0FEh,0EFh,0EFh,0FFh,0FEh
		db	0FFh,0EFh,0FFh,0FFh,0FEh,0FFh
		db	0EEh, 06h,0EFh, 04h,0FEh,0FFh
		db	0FFh,0FEh,0EEh,0EEh,0EEh, 06h
		db	0FFh, 32h,0EFh,0FBh, 06h,0FFh
		db	 77h,0BBh,0BBh,0BBh, 06h,0FFh
		db	 0Dh,0FEh,0EAh,0BBh,0FFh,0FFh
		db	0FEh,0EAh,0EFh,0FFh,0FFh,0EEh
		db	0EEh,0EEh, 06h,0FFh, 10h,0FEh
		db	0EEh,0EEh, 06h,0FFh, 05h,0BBh
		db	0FBh,0AEh, 06h,0EEh, 04h,0EFh
		db	0FFh,0FFh,0FBh,0BAh,0BEh,0BEh
		db	0EFh,0FBh,0FBh,0BBh, 06h,0FFh
		db	 0Eh, 06h,0BBh, 0Bh,0BFh,0FFh
		db	0FFh,0BBh,0BBh,0BBh,0FBh,0BBh
		db	0BBh,0BFh,0BFh,0FFh,0BBh,0EEh
		db	0EEh,0EAh,0AAh,0AAh,0AAh,0EEh
		db	0FEh,0EEh,0EEh,0EFh,0FFh,0EAh
		db	0EAh,0ABh,0AAh,0BFh,0EEh,0EEh
		db	0AAh, 06h,0BBh, 04h,0BFh,0FFh
		db	0FEh, 06h,0EEh, 07h,0FEh,0AAh
		db	0AEh,0EEh,0AAh,0AAh,0AEh,0EEh
		db	0FFh,0FFh,0FFh, 06h,0EEh, 04h
		db	0EFh,0EEh,0FFh,0FFh,0FFh,0EEh
		db	0FFh,0BBh,0BBh,0BBh,0BAh,0ABh
		db	0ABh, 06h,0BBh, 05h,0BAh,0ABh
		db	0AAh,0AAh,0ABh,0ABh,0BBh, 06h
		db	0AAh, 06h,0ABh, 06h,0BBh, 07h
		db	0AAh,0ABh, 06h,0BBh, 13h,0BFh
		db	0FFh,0BFh, 06h,0EEh, 08h, 06h
		db	0AAh, 0Dh,0EEh,0AEh,0AAh,0EEh
		db	0EEh,0EAh,0AAh,0EEh,0AAh
		db	0AAh			; (Sourcer 'data_2' label removed; byte is mountain data)
		db	0EAh,0EEh,0EAh,0AAh,0EEh,0EEh
		db	0FEh,0AAh,0EAh,0AAh,0AEh,0EEh
		db	0EAh,0AAh,0EEh,0AAh,0EAh,0AEh
		db	 06h,0EEh, 06h,0EFh,0FBh, 06h
		db	0AAh, 2Dh,0BBh,0AAh,0BAh,0AAh
		db	0ABh, 06h,0BBh, 05h,0EAh,0EEh
		db	 06h,0AAh, 35h,0EEh,0ABh,0AAh
		db	0AAh,0AAh,0EAh,0EEh,0EAh,0AEh
		db	0ABh, 06h,0AAh, 2Fh,0EAh, 06h
		db	0AAh, 08h,0ABh,0AAh,0BAh,0EAh
		db	 06h,0AAh,0B6h,0AFh,0FEh,0EFh
		db	 06h,0AAh, 04h,0BFh,0EEh,0EFh
		db	0FAh, 06h,0AAh, 2Dh,0BEh,0AFh
		db	0FEh,0EEh,0BBh,0FAh,0AAh,0BAh
		db	0FBh,0BAh, 06h,0AAh, 1Fh, 3Fh
		db	0FEh,0EEh,0EAh,0BBh, 06h,0AAh
		db	 09h,0ABh,0FEh,0AEh,0EAh, 06h
		db	0AAh, 04h,0FAh,0BEh, 06h,0AAh
		db	 20h, 3Eh,0EAh, 06h,0AAh, 0Ch
		db	0AFh,0FEh,0ABh,0BBh,0BAh,0AAh
		db	0AAh,0AAh,0FAh,0BAh, 06h,0AAh
		db	 1Fh,0ABh,0BAh, 06h,0AAh, 0Dh
		db	0AFh,0FAh,0AAh,0EAh,0AAh,0AAh
		db	0AAh,0ABh,0FBh,0EEh, 06h,0AAh
		db	 10h,0BFh,0FFh,0FFh,0EFh, 06h
		db	0AAh, 0Bh,0AFh,0AEh,0EEh,0EFh
		db	0FEh,0BAh,0AAh,0EEh,0EEh,0FFh
		db	0FBh,0BBh,0AAh,0AAh,0AAh,0FFh
		db	0EAh,0AAh,0EAh,0AAh,0AAh,0AAh
		db	0ABh,0EEh,0BAh,0AAh,0AAh,0ABh
		db	0FFh,0FBh,0FFh,0BBh,0BBh,0AAh
		db	0EEh, 06h,0AAh, 05h,0BFh,0EEh
		db	0ABh,0FFh,0BAh, 06h,0AAh, 07h
		db	0FFh,0FEh,0EEh,0AAh,0AFh,0AFh
		db	0BBh,0BBh,0AAh,0AAh,0AEh,0EEh
		db	 06h,0AAh, 04h,0AEh,0EEh,0EFh
		db	0BFh,0EAh, 06h,0AAh, 05h,0AFh
		db	0ECh,0BAh,0AAh,0AAh,0AFh,0FFh
		db	0FFh,0BBh,0FFh,0EAh, 06h,0AAh
		db	 06h,0BFh,0FFh,0EEh,0AAh,0ABh
		db	0AAh,0BFh,0BFh,0EBh,0FBh,0BBh
		db	0BBh,0BBh, 06h,0AAh, 04h,0AFh
		db	 2Bh,0FAh,0AAh,0AAh,0AAh, 06h
		db	0BBh, 04h,0AAh,0AEh,0EAh,0AAh
		db	0FAh,0BFh,0EAh,0AAh,0BBh,0BFh
		db	0FBh,0BBh,0BFh,0E8h,0BAh,0AAh
		db	0AAh,0AFh,0FEh,0ABh,0EFh,0FEh
		db	0FFh,0FEh,0EAh,0AAh,0AFh, 06h
		db	0FFh, 04h,0EEh,0AAh,0AAh,0AAh
		db	0FFh,0AEh,0EEh,0FFh,0EAh,0AEh
		db	0EEh,0FBh,0BAh,0FFh,0FFh,0EEh
		db	0EAh,0BEh,0EEh,0EEh,0EEh,0BFh
		db	0FFh,0EBh,0FFh,0FEh,0BAh,0EAh
		db	0ABh,0EBh,0FFh, 06h,0AAh, 06h
		db	0FEh,0ECh, 8Eh,0AAh,0AAh,0BFh
		db	0FEh,0AFh,0BAh, 06h,0FFh, 05h
		db	0FAh,0BFh,0BEh,0FFh,0FFh,0EEh
		db	0AAh,0AAh,0AAh, 06h,0FFh, 05h
		db	0ABh, 06h,0FFh, 04h,0FEh,0BFh
		db	0AAh,0AFh, 06h,0FFh, 08h,0FBh
		db	0FFh,0EFh,0AFh,0FFh,0AAh,0A8h
		db	0BFh,0FFh,0FBh,0FFh,0BEh,0EEh
		db	 2Eh,0FFh,0FFh,0BFh,0FEh,0AFh
		db	0BBh,0FEh,0AAh,0EEh,0BEh,0FBh
		db	0AAh,0BFh,0EBh,0BFh,0FFh,0EEh
		db	 06h,0AAh, 07h,0AFh,0ABh,0EAh
		db	0AAh,0AAh,0AAh,0A8h,0BFh,0AAh
		db	0AEh,0EEh,0EBh,0AAh,0AEh,0EEh
		db	0ABh,0BBh,0AFh,0AFh,0EAh,0BFh
		db	0AFh,0FEh,0AAh,0A8h,0AAh,0AAh
		db	0AFh,0EEh,0EAh,0EEh, 22h,0AAh
		db	0AAh,0FFh,0FEh,0EBh,0BAh,0BEh
		db	0AAh,0EEh,0FEh,0FBh,0BAh,0AFh
		db	0AAh,0BFh,0FFh,0EEh,0AAh,0AAh
		db	0AAh,0FFh,0FFh,0FFh,0EBh,0FAh
		db	0AAh,0FFh,0FFh,0FFh,0FEh,0A2h
		db	0FDh,0E8h,0AFh,0FEh,0ABh, 06h
		db	0FFh, 06h,0EFh,0BFh,0BEh,0EFh
		db	0FAh,0AAh,0A8h, 2Bh,0FFh,0EFh
		db	0FFh,0EBh,0BEh, 8Ah,0BFh,0FEh
		db	0FFh,0FEh,0EBh,0BEh,0BAh,0AAh
		db	0FAh,0BEh,0FBh,0BAh,0BEh,0EAh
		db	0BFh,0FFh,0AEh,0AAh,0AAh,0AAh
		db	0AEh,0BAh,0AAh,0FAh,0AAh,0BBh
		db	0FEh,0AAh,0BFh,0FAh, 82h,0FBh
		db	0E8h,0ABh,0FEh,0ABh,0FFh,0EBh
		db	 06h,0FFh, 04h,0EFh,0BFh,0BFh
		db	0AFh,0FAh,0AAh,0AAh, 0Bh,0FFh
		db	0EEh,0FFh,0ABh,0BAh,0A8h,0BFh
		db	0FBh,0FFh,0FBh,0ABh,0FEh,0BAh
		db	0AAh,0FAh,0FEh,0FBh,0BAh,0BBh
		db	0AAh,0BFh,0FFh,0BAh,0AAh,0AAh
		db	0AAh,0BEh,0BFh,0EFh,0AAh,0AAh
		db	0AFh,0FFh,0AAh,0FFh,0FAh, 22h
		db	0FFh,0E8h,0AAh,0FAh,0ABh,0FFh
		db	0ABh, 06h,0FFh, 04h,0BEh,0FFh
		db	0BEh,0AFh,0EAh,0AAh,0AAh, 8Ah
		db	0FFh,0BFh,0FAh,0AEh,0AEh, 88h
		db	0ABh,0FBh,0FFh,0EBh,0AAh,0FAh
		db	0BAh,0AAh,0FAh,0EEh,0FBh,0AAh
		db	0BEh,0AAh,0BFh,0FFh,0BAh, 06h
		db	0AAh, 04h,0BEh,0AAh,0AAh,0AAh
		db	0AEh,0FFh,0EAh,0FEh,0FAh,0CBh
		db	0FFh,0A8h, 8Ah,0AAh,0AEh,0EEh
		db	0ABh,0FFh,0FFh,0FFh,0FEh,0FFh
		db	0AEh,0FFh,0BFh,0EAh,0AAh,0AAh
		db	 0Ah,0FEh,0FBh,0BAh,0EEh,0FEh
		db	 80h,0AAh,0FFh,0FFh,0EBh,0AAh
		db	0EAh,0AEh,0AAh,0EBh,0BEh,0EEh
		db	0BAh,0BEh,0AAh,0BFh,0FFh,0FAh
		db	 06h,0AAh, 04h,0FEh,0AAh,0AEh
		db	0AAh,0AFh,0BFh,0ABh,0FFh,0E8h
		db	0C3h,0FFh, 98h, 0Ah,0AAh,0ABh
		db	0FAh,0BBh,0FFh,0FFh,0FFh,0FEh
		db	0FFh,0ABh,0FAh,0BEh,0EAh,0AAh
		db	0AAh, 82h,0BEh,0EFh,0EBh,0BBh
		db	0EEh, 82h, 2Ah,0FFh,0FFh,0AFh
		db	0AAh,0EAh,0AAh,0ABh,0BBh,0FEh
		db	0EEh,0BAh,0BAh,0AAh,0BFh,0FFh
		db	0AEh, 06h,0AAh, 04h,0BEh,0AAh
		db	0BAh,0AAh,0ABh,0FEh,0BBh,0AFh
		db	0FBh,0CFh,0FEh, 98h, 08h, 88h
		db	0AAh,0FAh,0AFh,0FEh,0FFh,0FFh
		db	0FEh,0FEh,0ABh,0EEh,0FEh,0EAh
		db	0AAh,0AAh, 88h,0ABh,0FFh,0EAh
		db	0AFh,0BAh, 82h, 23h,0FFh,0FFh
		db	0AEh,0AAh,0BBh,0AEh,0ABh,0EBh
		db	0FFh,0AEh,0BAh,0AEh,0AAh,0BFh
		db	0FFh,0EEh,0AAh,0AAh,0AAh, 2Ah
		db	0FAh,0AAh,0EAh,0AAh,0ABh,0FAh
		db	0FBh,0FFh,0EFh,0CFh,0F9h,0A8h
		db	 20h,0A2h, 2Ah,0EAh,0BFh,0FFh
		db	0FFh,0FFh,0EBh,0FFh,0AFh,0BAh
		db	0FBh,0AAh,0AAh,0AAh,0A2h,0ABh
		db	0BEh,0EFh,0BFh,0BEh, 88h, 83h
		db	0FFh,0FFh,0BAh,0AAh,0FBh,0BAh
		db	0AEh,0EEh,0FFh,0AEh,0EAh,0BAh
		db	0AAh,0BFh,0FFh
		db	0EEh,0AAh,0AAh,0AAh, 2Bh,0FAh
		db	0ABh,0AAh,0AAh,0BBh,0FEh,0EFh
		db	0BBh,0EFh,0BFh,0F9h,0AAh, 08h
		db	 28h,0AAh,0ABh,0BFh,0FFh,0FFh
		db	0FFh,0FEh,0FAh,0EFh,0EBh,0FBh
		db	0AAh,0AAh,0AAh, 82h,0AAh,0FFh
		db	0AEh,0BEh,0BAh, 80h, 8Fh,0FFh
		db	0FFh,0BAh,0AAh,0EBh,0AAh,0FBh
		db	0ABh,0BFh,0AEh,0EAh,0BAh,0AAh
		db	0BFh,0FFh
		db	0AEh,0AAh,0AAh,0AAh,0EBh,0FAh
		db	0AFh,0AAh,0AAh
		db	0BEh,0EAh,0FBh,0BAh,0FFh, 3Fh
		db	0FAh,0AAh, 0Ah, 88h, 00h,0BFh
		db	 06h,0FFh, 04h,0FBh,0EFh,0ABh
		db	0ABh,0EBh,0AAh,0AAh,0AAh,0A0h
		db	0AAh,0FBh,0BEh,0EAh,0FAh,0A0h
		db	 0Fh,0FFh,0FEh,0BAh,0AAh,0EFh
		db	0BBh,0AEh,0AEh,0EEh,0EEh,0EAh
		db	0AEh,0AAh,0EFh,0FFh,0AEh,0AAh
		db	0AAh,0AAh, 0Bh,0EAh,0BBh,0AAh
		db	0AAh,0BFh,0FBh,0AEh,0FFh,0BCh
		db	0FFh,0FAh,0AAh, 82h,0A0h, 0Fh
		db	 06h,0FFh, 05h,0EFh,0ABh,0AEh
		db	0AFh,0EBh,0AAh,0AAh,0AAh,0A8h
		db	 2Ah,0BEh,0BBh,0BAh,0FAh,0A2h
		db	 3Fh,0FFh,0EFh,0BAh,0AAh,0EFh
		db	0AEh,0BAh,0ABh,0EFh,0AEh,0EAh
		db	0AEh,0AAh,0BFh,0FFh, 06h,0AAh
		db	 04h,0CFh,0BAh,0AEh,0AAh,0AAh
		db	0EFh,0ABh,0BAh,0BEh,0BFh,0FFh
		db	0FAh, 6Ah, 82h, 80h
		db	 06h,0FFh, 06h,0AFh,0BAh
		db	0BEh,0BFh,0AEh,0AAh,0AAh,0AAh
		db	0A2h, 0Ah,0AEh,0AFh,0AAh,0EEh
		db	0A0h, 3Fh,0FBh,0EBh,0EAh,0AAh
		db	0BBh,0AEh,0BAh,0AFh,0EFh,0EEh
		db	0EAh,0AEh,0AAh,0AFh,0FFh,0AEh
		db	0AAh,0AAh,0AAh, 8Fh,0EAh,0BAh
		db	0AAh,0ABh,0BFh,0AAh,0BAh,0FEh
		db	0BFh,0FFh,0EAh,0AAh,0A8h, 83h
		db	 06h,0FFh, 05h,0FEh,0AFh,0BAh
		db	0FAh,0FEh,0AEh,0AAh,0AAh,0AAh
		db	0A8h, 0Ah,0AAh,0BFh,0ABh,0EEh
		db	0A2h, 3Fh,0EFh,0AFh,0EAh,0AAh
		db	0AFh,0FAh,0EAh,0BFh,0FFh,0EEh
		db	0EAh,0AEh,0AAh,0AFh,0FEh,0AEh
		db	0AAh,0AAh,0AAh,0CEh,0EBh,0EAh
		db	0AAh,0ABh,0FAh,0AAh,0EAh,0EEh
		db	0B3h,0FFh,0A9h,0AAh, 22h, 87h
		db	 06h,0FFh, 05h,0FEh,0FFh,0BAh
		db	0BBh,0FEh,0AEh,0AAh,0AAh,0AAh
		db	0A8h, 82h,0AAh,0FFh,0AFh,0EEh
		db	 88h, 3Fh,0EEh,0BEh,0FAh,0AAh
		db	0BFh,0AFh,0AAh,0BFh,0BFh,0AAh
		db	0EAh,0AAh,0AAh,0AFh,0FEh,0AEh
		db	0AAh,0AAh,0AAh, 83h,0AEh,0EAh
		db	0AAh,0AFh,0AAh,0EFh,0AAh,0AEh
		db	0F3h,0FFh,0A9h,0AAh, 0Ah, 05h
		db	 7Fh,0FFh, 5Fh,0FFh,0FFh,0FBh
		db	0EEh,0FAh,0EBh,0FEh,0BAh, 06h
		db	0AAh, 04h, 00h,0AAh,0FEh,0BFh
		db	0BEh,0A0h,0FFh,0AEh,0EFh,0BAh
		db	0AAh,0FFh,0BAh,0AAh,0BFh,0BEh
		db	0BAh,0BAh,0AEh,0AAh,0AFh,0FEh
		db	0BAh,0AAh,0AAh,0AAh, 82h,0AFh
		db	0AAh,0AAh,0BEh,0AAh,0EFh,0AAh
		db	0AAh,0FFh,0FFh,0A6h,0AAh, 0Ah
		db	 07h,0D5h, 7Dh,0FFh,0FFh,0FFh
		db	0FEh,0FBh,0EBh,0AFh,0FEh,0BAh
		db	 06h,0AAh, 04h, 00h,0AAh,0FAh
		db	0EFh,0EEh, 88h,0FFh,0AAh,0BEh
		db	0BAh,0AAh,0FEh,0EAh,0AAh,0FEh
		db	0BEh,0BAh,0BAh,0ABh,0AAh,0ABh
		db	0FEh,0BAh,0AAh,0AAh,0AAh,0C3h
		db	0BAh,0EAh,0AAh,0FEh,0AAh,0BFh
		db	0AAh,0ABh,0FFh,0FEh,0A6h, 8Ah
		db	 0Ah, 87h, 75h,0D7h, 5Fh,0FFh
		db	0FFh,0EBh,0EFh,0AAh,0AFh,0FAh
		db	0BAh, 06h,0AAh, 04h, 08h, 2Bh
		db	0BEh,0EFh,0BFh,0A8h,0FFh,0BAh
		db	0EFh,0FAh,0AAh,0FBh,0AAh,0AEh
		db	0FEh,0BEh,0BAh,0BAh,0ABh,0EAh
		db	0ABh,0FEh,0BAh,0AAh,0AAh,0AAh
		db	0CEh,0AFh,0AAh,0AEh,0FAh,0AAh
		db	0BBh,0EBh,0ABh,0FFh,0FAh,0AAh
		db	 8Ah, 0Ah, 07h, 7Fh,0FDh,0FFh
		db	0FFh,0FEh,0AEh,0FBh,0ABh,0BFh
		db	0FAh,0EAh, 06h,0AAh, 04h, 0Ah
		db	0AFh,0EFh,0ABh,0FFh,0A8h,0FEh
		db	0AEh,0EEh,0FAh,0AAh,0FBh,0AAh
		db	0AEh,0FEh,0BAh,0BAh,0BAh,0ABh
		db	0EAh,0ABh,0FEh,0BAh,0AAh,0AAh
		db	0AAh, 20h,0BEh,0AAh,0BBh,0FAh
		db	0AAh,0BFh,0EBh,0BBh,0FEh,0AAh
		db	0AAh, 8Ah, 20h, 0Fh, 7Fh,0FFh
		db	0FFh,0FFh,0FEh,0BBh,0AFh,0AEh
		db	0FFh,0EAh, 06h,0AAh, 05h, 8Bh
		db	0AFh,0EAh,0EFh,0EFh,0A0h,0FEh
		db	0EAh,0FBh,0EAh,0ABh,0EEh,0AAh
		db	0BAh,0EEh,0BEh,0BAh,0BAh,0ABh
		db	0EAh,0ABh,0FEh,0FAh,0AAh,0AAh
		db	0AAh, 00h,0FAh,0AAh,0EFh,0FAh
		db	0ABh,0EEh,0EFh, 2Fh,0FEh,0A6h
		db	 9Ah, 2Ah, 0Ah, 3Dh,0FFh,0DDh
		db	0FFh,0FFh,0FEh,0AFh,0AEh,0AAh
		db	0FFh,0EAh, 06h,0AAh, 05h, 2Bh
		db	0FFh,0EAh,0BBh,0EFh,0A2h,0FEh
		db	0FBh,0FBh,0AAh,0ABh,0FBh,0AAh
		db	0BAh,0FEh,0EEh,0BAh,0BAh,0ABh
		db	0BAh,0ABh,0FEh,0EEh,0AAh,0AAh
		db	0AAh, 02h,0BAh,0AFh,0BFh,0EAh
		db	0ABh,0FEh,0ECh, 3Fh,0FEh, 6Ah
		db	0AAh, 2Ah, 20h, 1Dh,0FFh,0F7h
		db	0DFh,0F7h,0FAh,0EFh,0BAh,0AFh
		db	0FFh, 06h,0AAh, 06h, 2Ah,0BFh
		db	0AAh,0AFh,0BAh,0A2h,0FBh,0EFh
		db	0AFh,0EAh,0ABh,0FBh,0AEh,0EEh
		db	0FAh,0FAh,0AEh,0AEh,0BBh,0EAh
		db	0ABh,0FEh,0EEh,0AAh,0AAh,0AAh
		db	 08h,0AAh,0FAh,0FBh,0BAh,0AFh
		db	0EFh,0BCh,0FFh,0FAh, 69h,0AAh
		db	 28h,0A0h,0F5h,0F7h,0DFh,0DFh
		db	 5Fh,0EBh,0BEh,0FEh,0AEh,0FEh
		db	 06h,0AAh, 06h, 0Fh,0FFh,0AAh
		db	0ABh,0EEh,0BBh,0FBh,0AFh,0EFh
		db	0BAh,0AFh,0EBh,0AAh,0BBh,0BEh
		db	0EEh,0AEh,0AEh,0BBh,0AAh,0ABh
		db	0FEh,0EEh,0AAh,0AAh,0AAh,0C0h
		db	0AFh,0EBh,0FEh,0EAh,0AFh,0FFh
		db	0BCh,0FFh,0EAh,0A9h, 6Ah, 28h
		db	 88h,0D5h, 77h, 5Fh,0DDh, 5Fh
		db	0EBh,0FBh,0FAh,0EFh,0FEh, 06h
		db	0AAh, 06h, 3Fh,0FEh,0BAh,0ABh
		db	0EBh,0ABh,0EFh,0ABh,0FFh,0BAh
		db	0BFh,0EEh,0AEh,0BEh,0BEh,0EEh
		db	0AEh,0AEh,0AEh,0FEh,0AAh,0FBh
		db	 06h,0AAh, 04h, 08h, 3Bh,0BFh
		db	0EBh,0EAh,0AFh,0EEh,0F3h,0FFh
		db	0E9h,0A5h,0AAh,0A8h,0A1h,0F7h
		db	0F7h,0DFh, 55h, 7Fh,0AEh,0BEh
		db	0EAh,0BFh,0FEh, 06h,0AAh, 06h
		db	 3Fh,0EAh,0EAh,0AAh,0BBh,0EBh
		db	0BAh,0AEh,0FFh,0EAh,0AFh,0EEh
		db	0AEh,0BAh,0EEh,0FAh,0AEh,0AEh
		db	0ABh,0EBh,0AAh,0FBh,0AEh,0AAh
		db	0AAh,0AAh, 30h, 0Fh,0FFh,0AEh
		db	0AAh,0BFh,0FEh,0FFh,0FFh,0F9h
		db	0A5h,0A8h,0A0h, 89h, 77h,0DFh
		db	0DDh, 55h,0FAh,0BFh,0BAh,0EAh
		db	0FFh,0FAh, 06h,0AAh, 05h,0A8h
		db	0FFh,0AEh,0EAh,0AAh,0AAh,0BFh
		db	0FEh,0AAh,0FEh,0EAh,0BEh,0EEh
		db	0AEh,0AEh,0FAh,0EEh,0AAh,0ABh
		db	0AAh,0EFh,0AEh,0FBh,0AEh,0AAh
		db	0AAh,0AAh, 30h, 0Bh,0FEh,0FAh
		db	0AAh,0FFh,0FBh,0FCh,0FFh,0F9h
		db	0A6h,0A8h, 88h, 81h, 7Dh, 5Fh
		db	0FDh, 5Fh,0FAh,0FEh,0ABh,0EBh
		db	0BFh, 06h,0AAh, 07h,0FFh,0ABh
		db	0AAh,0AAh,0AAh,0ABh,0FFh,0EAh
		db	0FBh,0AAh,0BEh,0EBh,0ABh,0BBh
		db	0BAh,0FAh,0ABh,0ABh,0AAh,0EFh
		db	0ABh,0FBh,0AEh,0AAh,0AAh,0AAh
		db	 33h, 83h,0FFh,0EEh,0EFh,0FFh
		db	0FBh,0FFh,0FFh,0FAh,0AAh,0A2h
		db	 8Ah, 8Dh, 5Fh, 5Fh,0F5h, 5Fh
		db	0FAh,0EEh,0EBh,0AAh,0FAh, 06h
		db	0AAh, 04h,0AEh,0AAh,0BFh,0FFh
		db	0BAh,0AAh,0AAh,0A8h,0AAh,0AFh
		db	0FAh,0EEh,0FAh,0AEh,0FBh,0AAh
		db	0FEh,0FEh,0EAh,0AFh,0ABh,0AAh
		db	0EAh,0AEh,0FBh,0AEh,0AAh,0AAh
		db	0AAh, 30h, 23h,0FFh,0FBh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0FAh,0AAh
		db	0A2h, 88h, 8Fh, 75h,0FFh,0D5h
		db	 7Fh,0BBh,0ABh,0AFh,0ABh,0EAh
		db	 06h,0AAh, 04h,0BFh,0FFh,0EFh
		db	0FEh,0FAh,0AAh,0AAh,0A8h, 8Ah
		db	0ABh,0FEh,0BFh,0FEh,0AEh,0FBh
		db	0ABh,0EFh,0EEh,0FAh,0AFh,0ABh
		db	0AAh,0EBh,0AFh,0FEh,0AEh,0EAh
		db	0AAh,0AAh, 88h,0C0h, 06h,0FFh
		db	 04h,0E3h,0FFh,0FFh,0E6h,0AAh
		db	0AAh, 2Ah, 0Fh,0FFh,0FFh,0D5h
		db	0FFh,0EFh,0AAh,0BEh,0AFh,0EAh
		db	0AAh,0AAh,0AAh,0ABh,0BFh,0FFh
		db	0AFh,0FAh,0EAh,0AAh,0AAh,0AAh
		db	 22h,0AAh,0BFh,0EFh,0BAh,0ABh
		db	0EEh,0AFh,0BBh,0EEh,0FAh, 9Fh
		db	0ABh,0AAh,0EBh,0BBh,0FEh,0BAh
		db	0AAh,0AAh,0AAh, 8Ah, 38h, 3Fh
		db	0FFh,0FFh,0FFh,0ECh,0FFh,0FFh
		db	0E6h,0AAh,0AAh,0A8h, 0Fh,0FFh
		db	0FFh, 57h,0FFh,0BBh,0AAh,0EAh
		db	0AFh,0BAh,0AAh,0AAh,0AAh,0ABh
		db	0FFh,0FAh,0BFh,0ABh,0EAh,0AAh
		db	0AAh,0AAh, 22h,0AAh,0ABh,0FBh
		db	0EEh,0FBh,0AAh,0FBh,0FEh,0FAh
		db	0FAh,0ABh,0EBh,0AAh,0BBh,0BFh
		db	0FEh,0BBh,0AAh,0AAh,0AAh,0B3h
		db	 38h, 2Fh,0FEh,0FFh,0FBh,0E3h
		db	0FFh,0FFh,0AAh,0AAh,0A8h,0A0h
		db	 2Fh,0FFh,0FDh, 5Fh,0FAh,0AEh
		db	0AAh,0FAh,0AFh,0EAh,0AAh,0AAh
		db	0AAh,0AFh,0FEh,0ABh,0FFh,0ABh
		db	 06h,0AAh, 04h, 28h, 2Ah,0AAh
		db	0BBh,0FBh,0BEh,0FFh,0BEh,0FBh
		db	0BAh,0EAh, 7Bh,0EAh,0EAh,0BBh
		db	0BFh,0BAh,0BEh,0AAh,0AAh,0AAh
		db	0FCh, 8Eh, 0Ah,0FBh,0FFh,0FEh
		db	0ECh,0FFh,0FFh,0AAh,0AAh, 88h
		db	 89h, 7Fh,0FFh,0F5h, 5Fh,0EBh
		db	0BAh,0ABh,0EAh,0BEh,0FAh,0AAh
		db	0AAh,0AAh,0ABh,0FAh,0EEh,0FEh
		db	0AFh, 06h,0AAh, 04h, 0Ah, 00h
		db	0AAh,0AEh,0FFh,0EBh,0AFh,0FAh
		db	0FFh,0BBh,0BAh, 7Bh,0EAh,0EAh
		db	0BAh,0AFh,0FAh,0BEh,0AAh,0AAh
		db	0AAh,0BCh,0A2h, 03h,0FFh,0FFh
		db	0FAh,0F3h,0FFh,0FEh, 9Ah, 6Ah
		db	 82h, 17h,0FFh,0FFh,0F5h, 7Fh
		db	0AFh,0EEh,0ABh,0EAh,0FBh,0EAh
		db	 06h,0AAh, 04h,0FBh,0BBh,0FEh
		db	0AEh,0AAh,0EAh,0AAh,0AAh, 0Ah
		db	 80h, 00h,0ABh,0BEh,0BFh,0AFh
		db	0EBh,0BBh,0BBh,0EAh,0AFh,0EAh
		db	0EAh,0BBh,0AFh,0EEh,0BAh,0AAh
		db	0AAh,0AAh,0FAh, 2Ch, 83h,0FFh
		db	0FFh,0AEh,0F3h,0FFh,0FEh, 6Ah
		db	 6Ah, 28h, 5Fh,0FFh,0FFh,0D5h
		db	0FBh,0BEh,0EEh,0ABh,0ABh,0BFh
		db	0BAh, 06h,0AAh, 04h,0EAh,0EFh
		db	0FEh,0BEh,0ABh,0FAh,0AAh,0A8h
		db	 80h,0AAh, 80h, 2Ah,0ABh,0FAh
		db	0FEh,0BBh,0FEh,0EBh,0EAh, 6Fh
		db	0EAh,0EAh,0BBh,0ABh,0EEh,0BEh
		db	0AAh,0AAh,0AAh,0FEh, 8Ah,0E0h
		db	0EAh,0EAh,0EBh, 8Fh,0FFh,0FEh
		db	 6Ah,0AAh, 28h, 57h,0FFh,0FFh
		db	0D5h,0EEh,0BAh,0BAh,0AFh,0AAh
		db	0FBh,0EAh, 06h,0AAh, 04h,0ABh
		db	0AFh,0FAh,0BAh,0AFh,0FAh,0AAh
		db	0AAh, 22h, 02h,0AAh, 8Ah,0AFh
		db	0FEh,0EBh,0EBh,0BAh,0EBh,0A9h
		db	0AFh,0EAh,0EAh,0AFh,0AEh,0EEh
		db	0EEh,0AAh,0AAh,0AAh,0AFh,0F0h
		db	0B8h, 02h,0AAh,0EAh, 8Fh,0FFh
		db	0FEh,0AAh,0A8h,0A0h, 57h,0FFh
		db	0FFh, 57h,0EFh,0ABh,0EAh,0EFh
		db	0ABh,0FFh,0BAh,0AAh,0AAh,0AAh
		db	0FAh,0ABh,0BFh,0FAh,0BAh,0AFh
		db	0AEh,0AAh,0AAh,0A8h, 20h, 0Ah
		db	 2Ah, 8Fh,0FAh,0AFh,0AEh,0FEh
		db	0AEh,0AAh,0BBh,0EAh,0EAh,0AFh
		db	0ABh,0FAh,0FAh, 06h,0AAh, 04h
		db	0BFh, 0Ah, 20h, 3Bh,0ABh,0CFh
		db	0FBh,0FEh,0AAh, 68h,0A1h, 75h
		db	0FFh,0FDh, 76h,0BFh,0AFh,0ABh
		db	0FFh,0AFh,0FFh,0EAh,0AAh,0AAh
		db	0AAh,0EFh,0AEh,0FEh,0EAh,0BEh
		db	0BFh,0ABh,0AAh,0AAh, 0Ah, 00h
		db	 20h, 2Ah, 8Fh,0EEh,0AEh,0AFh
		db	0BAh,0AEh,0A9h,0BBh,0EAh,0EAh
		db	0AFh,0ABh,0FAh,0EEh,0AAh,0AAh
		db	0AAh, 2Ah,0AAh,0E0h, 2Ch, 0Ah
		db	0AFh, 3Fh,0FBh,0FEh,0AAh, 98h
		db	 01h,0F7h,0FFh,0FDh,0DAh,0EEh
		db	0BAh,0AEh,0FEh,0AFh,0FFh,0EAh
		db	0AAh,0AAh,0ABh,0FFh,0AFh,0FFh
		db	0ABh,0FAh,0FEh,0EBh,0AAh,0AAh
		db	0A2h, 80h, 80h,0AEh, 3Fh,0FAh
		db	0AEh,0AEh,0EAh,0EEh,0AAh,0BBh
		db	0EAh,0EAh,0AEh,0AAh,0FAh,0AEh
		db	0AAh,0AAh,0AAh, 8Ah,0AAh,0BAh
		db	 80h,0A8h, 0Bh, 3Fh,0FFh,0FEh
		db	0A9h,0A0h, 15h,0FFh,0FFh, 55h
		db	0DBh,0AEh,0BAh,0BBh,0FEh,0BFh
		db	0FFh,0EAh,0AAh,0AAh,0ABh,0EFh
		db	0AFh,0EEh,0FEh,0EFh,0FAh,0EAh
		db	0EBh,0EAh,0A8h, 2Ah, 8Ah,0FBh
		db	 3Fh,0AAh,0BEh,0ABh,0EAh,0AEh
		db	0A6h,0BBh,0EAh,0EAh,0ABh,0AEh
		db	0EAh,0FAh,0AAh,0AAh,0AAh, 80h
		db	0AAh,0ABh,0FBh, 0Ah,0ACh,0FFh
		db	0EFh,0FFh,0AAh, 81h, 7Fh,0FFh
		db	0F5h,0FDh, 5Bh,0EAh,0EAh,0BBh
		db	0EAh,0FBh,0FFh,0AAh,0AAh,0AAh
		db	0ABh,0BEh,0BFh,0FFh,0AFh,0BFh
		db	0EBh,0AAh,0EEh,0FFh,0AAh, 80h
		db	 0Ah,0BEh, 8Fh,0EAh,0BAh,0AEh
		db	0EAh,0BAh,0A6h,0BFh,0EAh,0EAh
		db	0AEh,0AFh,0BAh,0FAh,0AAh,0AAh
		db	0AAh,0A0h, 2Ah,0AAh,0AEh,0FAh
		db	0F0h,0FFh,0AFh,0FFh,0BFh, 95h
		db	 7Fh,0FFh,0F7h,0D6h,0EFh,0AAh
		db	0AAh,0EFh,0EBh,0FFh,0FBh,0EAh
		db	0AAh,0AAh,0AFh,0BEh,0BFh,0FAh
		db	0EEh,0EEh,0BEh,0A2h,0BAh,0BFh
		db	0FEh,0AAh, 0Bh,0FEh, 3Fh,0B6h
		db	0EEh,0AFh,0AAh,0BAh, 99h,0BFh
		db	0EAh,0EAh,0AEh,0AFh,0EAh,0FAh
		db	 06h,0AAh, 04h, 02h,0AAh,0AAh
		db	0ABh,0EFh,0FAh,0BFh,0FEh,0BAh
		db	0FFh,0FFh,0EEh,0FEh,0AFh,0EFh
		db	0AEh,0AAh,0AEh,0AAh,0EFh,0FAh
		db	0AAh,0AAh,0AAh,0BBh,0EEh,0ABh
		db	0EEh,0FBh,0BAh,0FAh,0A2h,0BBh
		db	0EEh,0FEh,0EAh, 8Ah,0FAh, 3Bh
		db	 5Ah,0EAh,0BBh,0AAh,0AAh,0AAh
		db	0AFh,0EAh,0BAh,0AAh,0AAh,0EAh
		db	0FAh,0AAh,0AAh,0AAh,0A8h,0A0h
		db	 02h,0AAh,0AEh,0FBh,0EEh,0BBh
		db	0FAh,0AEh,0FFh,0BFh,0EBh,0BEh
		db	0AFh,0FBh,0BBh,0AAh,0BEh,0AAh
		db	0BFh,0EBh,0AAh,0AAh,0AAh,0BFh
		db	0EAh,0AEh,0BFh,0AEh,0FAh,0EEh
		db	0A8h,0AFh,0BBh,0FBh,0AAh,0AAh
		db	0F8h, 3Eh,0B6h,0AAh,0BEh,0AAh
		db	0AAh,0AAh,0EFh,0EAh,0BAh,0AAh
		db	0AEh,0EAh,0EAh, 06h,0AAh, 04h
		db	 08h, 00h, 02h,0AFh,0AFh,0AEh
		db	0FEh,0FEh,0BAh,0FFh,0EEh,0AFh
		db	0FAh,0BBh,0FFh,0EBh,0AAh,0BAh
		db	0AAh,0BFh,0ABh,0AAh,0AAh,0AAh
		db	0BEh,0EAh,0AEh,0BEh, 3Fh,0E8h
		db	0FAh,0A8h,0BAh,0BEh,0BEh,0FFh
		db	0AAh,0A8h,0FFh, 5Ah,0EAh, 06h
		db	0AAh, 04h,0BFh,0EAh,0BAh,0AAh
		db	0BBh,0AAh,0BAh, 06h,0AAh, 04h
		db	0A0h, 0Ah,0AAh,0FEh,0FBh,0ABh
		db	0EAh,0BAh,0BBh,0FFh,0FAh,0AFh
		db	0EAh,0BFh,0BBh,0AAh,0AAh,0FEh
		db	0AAh,0BEh,0AEh,0AAh,0AAh,0AAh
		db	0FBh,0AAh,0AEh,0BAh, 3Fh,0F8h
		db	0FEh,0A2h, 2Fh,0BBh,0FAh,0BFh
		db	0FBh,0A8h,0EEh, 6Ah,0AAh,0BAh
		db	0AAh,0AAh,0AAh,0FFh,0EAh,0BAh
		db	0AAh,0BEh,0AAh,0FAh, 06h,0AAh
		db	 05h,0A0h, 2Fh,0EFh,0EAh,0AFh
		db	0ABh,0EAh,0ABh,0FBh,0AAh,0BFh

; ==========================================================================
; mountains1: 88x56 RLE source bitmap for the 'near' mountain layer.
; Decoded by rle_decode_mountain_88x56 into seg1:1340h.
; Same format as mountains0 (06h = 2-byte fill, else literal).
; ==========================================================================

mountains1:
		db	0EAh,0BFh,0BEh,0AAh,0AAh,0BAh
		db	0AAh,0BEh,0AEh,0AAh,0AAh,0AAh
		db	0EEh,0EAh,0BAh,0B8h, 3Fh,0B8h
		db	0BFh,0A8h, 8Bh,0AAh,0ABh,0EEh
		db	0BEh, 83h,0BFh, 06h,0AAh, 06h
		db	0EFh,0EAh,0BAh,0AAh,0BEh,0AAh
		db	0FAh, 06h,0AAh, 06h,0BEh,0EFh
		db	0AAh,0BAh,0AAh,0EAh,0ABh,0FEh
		db	0AAh,0BFh,0EAh,0EEh,0BFh,0AEh
		db	0AAh,0EAh,0AAh,0FAh,0BAh,0AAh
		db	0AAh,0AAh,0FBh,0AAh,0EAh,0A8h
		db	 2Ah,0E8h,0FAh,0A8h,0A0h,0BEh
		db	0AAh,0AAh,0A2h, 23h,0EFh,0AAh
		db	0EAh,0BAh,0AAh,0AAh,0AAh,0FAh
		db	0EAh,0BAh,0AAh,0BAh,0AAh,0EAh
		db	 06h,0AAh, 06h,0EFh,0BAh,0AAh
		db	0AAh,0ABh,0AAh,0ABh,0BBh,0AAh
		db	0FFh,0BAh,0BEh,0EEh,0AAh,0AAh
		db	0EAh,0AAh,0EAh, 06h,0AAh, 04h
		db	0FBh,0AAh,0BAh,0BAh, 3Ah,0E8h
		db	 3Eh,0A8h, 2Ah, 20h, 0Fh,0BAh
		db	 00h,0FFh,0BAh,0ABh, 06h,0AAh
		db	 05h,0EBh,0AAh,0BAh,0AAh,0EEh
		db	0AAh,0EAh, 06h,0AAh, 06h,0BFh
		db	0EAh, 06h,0AAh, 04h,0AFh,0FEh
		db	0ABh,0FFh,0EAh,0FEh,0FEh,0AAh
		db	0ABh,0AAh,0ABh,0EAh,0AAh,0AAh
		db	0AAh,0ABh,0BEh,0AAh,0EAh,0A8h
		db	 3Ah,0A0h,0FAh,0AAh, 0Ah,0AAh
		db	 2Ah,0A0h, 3Fh,0AFh,0EAh,0AEh
		db	 06h,0AAh, 04h,0ABh,0BBh,0AAh
		db	0BAh,0AAh,0FAh, 06h,0AAh, 07h
		db	0BAh,0FBh,0AAh,0EAh,0AAh,0BAh
		db	0AAh,0FFh,0EAh,0ABh,0FEh,0AAh
		db	0FAh,0FBh,0AAh,0AFh, 06h,0AAh
		db	 06h,0ABh,0EEh,0AAh,0EAh,0A2h
		db	 3Eh,0A8h,0FEh,0AAh,0A2h,0A0h
		db	 80h, 3Fh,0EFh,0AAh,0AAh,0AEh
		db	 06h,0AAh, 07h,0BAh,0AAh,0FAh
		db	 06h,0AAh, 07h,0BEh,0FEh,0AFh
		db	0AAh,0AAh,0BAh,0ABh,0FEh,0AEh
		db	0AFh,0FEh,0AAh,0EAh,0EBh,0AAh
		db	0AFh,0AAh,0ABh, 06h,0AAh, 04h
		db	0AEh,0EAh,0ABh,0AAh,0A8h,0AEh
		db	0A2h,0FAh,0AAh,0AAh, 08h, 0Ch
		db	0EFh,0BAh,0AAh,0AAh,0BAh, 06h
		db	0AAh, 05h,0AEh,0AAh,0EAh,0AAh
		db	0FAh, 06h,0AAh, 06h,0ABh,0EBh
		db	0AAh,0BAh,0AAh,0AAh,0BAh,0ABh
		db	0FAh,0BAh
		db	0BFh			; (Sourcer-generated 'data_3' label removed; byte is just mountain data)
		db	0FAh,0ABh,0AAh,0EAh,0AAh,0BEh
		db	 06h,0AAh, 06h,0AFh,0AAh,0ABh
		db	0AAh,0A2h,0EAh,0A0h,0FAh,0AAh
		db	0A0h, 20h,0FFh,0BAh, 06h,0AAh
		db	 0Bh,0EAh,0AAh,0EAh, 06h,0AAh
		db	 06h,0BEh,0AAh,0AAh,0BAh,0AAh
		db	0EAh,0EAh,0AAh,0EBh,0EAh,0BFh
		db	0BAh,0AAh,0AAh,0ABh,0AAh,0BBh
		db	0AAh,0AEh, 06h,0AAh, 04h,0AFh
		db	0AAh,0AAh,0AAh,0A8h,0EAh,0A2h
		db	0AAh,0AAh, 22h,0AEh,0EEh,0AAh
		db	0AAh,0AAh,0ABh, 06h,0AAh, 06h
		db	0AEh,0AAh,0AAh,0AAh,0FAh, 06h
		db	0AAh, 06h,0EEh,0AAh,0AAh,0EAh
		db	0ABh,0AAh,0EAh,0ABh,0BEh,0AAh
		db	0FEh,0EAh,0AAh,0AAh,0EBh,0AAh
		db	0AEh, 06h,0AAh, 06h,0BEh, 06h
		db	0AAh, 05h, 8Bh,0AAh,0AAh,0AAh
		db	0AFh,0BAh, 06h,0AAh, 0Bh,0ABh
		db	0AAh,0ABh,0BAh, 06h,0AAh, 05h
		db	0ABh, 06h,0AAh, 04h,0ABh,0ABh
		db	0AAh,0ABh,0EEh,0AAh,0FAh,0AAh
		db	0AAh,0ABh,0ABh,0AAh,0BAh,0AAh
		db	0BAh, 06h,0AAh, 04h,0BFh, 06h
		db	0AAh, 05h,0A3h,0AAh,0AAh,0AAh
		db	0BAh, 06h,0AAh, 0Bh,0AEh,0ABh
		db	0AAh,0ABh,0EAh, 06h,0AAh, 05h
		db	0BAh, 06h,0AAh, 04h,0AFh,0AAh
		db	0AAh,0ABh,0BAh,0ABh,0EEh,0AAh
		db	0AAh,0AAh,0AEh,0AAh,0BAh,0AAh
		db	0BAh, 06h,0AAh, 04h,0BBh,0AAh
		db	0AAh,0AAh,0AEh,0AAh,0ABh, 06h
		db	0AAh, 0Fh,0BAh,0AEh,0AAh,0ABh
		db	0EAh, 06h,0AAh, 05h,0EAh, 06h
		db	0AAh, 04h,0BEh,0AAh,0AAh,0ABh
		db	0BAh,0ABh,0EAh, 06h,0AAh, 07h
		db	0EAh, 06h,0AAh, 04h,0EEh, 06h
		db	0AAh, 09h,0BAh, 06h,0AAh, 0Eh
		db	0ABh,0EAh, 06h,0AAh, 09h,0AFh
		db	0EAh,0AAh,0AAh,0ABh,0AAh,0ABh
		db	 06h,0AAh, 0Dh,0FAh, 06h,0AAh
		db	 08h,0ABh,0EAh, 06h,0AAh, 0Ch
		db	0FAh, 06h,0AAh, 0Ch,0BAh,0AAh
		db	0AAh,0AAh,0AEh, 06h,0AAh, 0Fh
		db	0BAh, 06h,0AAh, 08h,0BEh, 06h
		db	0AAh, 0Fh,0ABh, 06h,0AAh, 1Eh
		db	0EAh, 06h,0AAh, 07h,0ABh, 06h
		db	0AAh, 17h, 06h,0AAh, 70h,0BBh
		db	0FBh,0BFh,0BBh,0BFh,0BBh,0BBh
		db	0FFh,0BBh,0BBh,0BFh, 06h,0BBh
		db	 08h,0FBh,0FFh,0FFh,0BBh,0BFh
		db	0FBh, 06h,0BBh, 10h,0FFh,0FFh
		db	0FBh, 06h,0BBh, 0Ch,0FEh,0FEh
		db	0FEh,0FFh,0FEh,0EFh,0FFh,0FFh
		db	0FFh,0EFh,0FFh,0FFh,0EEh,0EEh
		db	0EFh,0FEh,0EFh,0FFh,0FFh,0FEh
		db	0FFh,0EEh,0EFh,0FFh,0FFh,0FFh
		db	0EEh,0EFh,0EEh,0EFh,0FEh,0FFh
		db	0EFh,0FEh,0EFh,0EFh,0FFh,0FEh
		db	0FFh,0EFh,0FFh,0FFh,0FEh,0FFh
		db	0EEh, 06h,0EFh, 04h,0FEh,0FFh
		db	0FFh,0FEh,0EEh,0EEh,0EEh, 06h
		db	0FFh, 32h,0EFh,0FBh, 06h,0FFh
		db	0FFh, 06h,0FFh,0FFh, 06h,0FFh
		db	0F9h,0F0h, 2Bh,0BAh, 06h,0FFh
		db	 04h,0C2h,0BBh,0BAh,0AFh, 06h
		db	0FFh, 2Dh,0C3h,0EAh,0ABh,0BBh
		db	0EEh,0AFh,0FFh,0CEh,0AEh,0EFh
		db	 06h,0FFh, 1Eh,0FDh, 6Ah,0ABh
		db	0BBh,0BFh,0EEh, 06h,0FFh, 09h
		db	0FCh, 03h,0EBh,0BFh, 06h,0FFh
		db	 04h, 0Bh,0ABh, 06h,0FFh, 1Fh
		db	0FDh, 2Bh,0BFh, 06h,0FFh, 0Ch
		db	0F0h, 03h,0EAh,0EEh,0EFh,0FFh
		db	0FFh,0FFh, 0Eh,0AFh, 06h,0FFh
		db	 1Fh,0F4h,0AFh, 06h,0FFh, 0Dh
		db	0F0h, 0Fh,0EAh,0BFh,0FFh,0FFh
		db	0FFh,0FCh, 0Fh,0FBh, 06h,0FFh
		db	 10h,0C0h, 02h,0AAh,0BAh, 06h
		db	0FFh, 0Bh,0F4h, 2Bh,0BBh,0BAh
		db	0ABh,0EFh,0FFh,0BBh,0BBh,0AAh
		db	0AEh,0EEh,0FFh,0FFh,0FFh, 00h
		db	 3Fh,0EAh,0BFh,0FFh,0FFh,0FFh
		db	0FCh, 3Eh,0BFh,0FFh,0FFh,0FCh
		db	 02h,0AEh,0AAh,0EEh,0EEh,0FFh
		db	0BBh, 06h,0FFh, 05h,0C0h, 33h
		db	0FCh, 02h,0EFh, 06h,0FFh, 07h
		db	0AAh,0ABh,0BBh,0FFh,0F4h,0AAh
		db	0EEh,0EEh,0FFh,0FFh,0FBh,0BBh
		db	 06h,0FFh, 04h,0FBh,0BBh,0B0h
		db	0C0h, 3Eh,0EAh, 06h,0FFh, 04h
		db	0F0h, 3Ch,0BFh,0FFh,0FFh,0F0h
		db	 00h, 02h,0EEh,0AAh,0BFh, 06h
		db	0FFh, 06h,0C0h, 00h, 33h,0FBh
		db	0A8h,0AFh,0EAh,0EAh,0BEh,0AEh
		db	0EEh,0EEh,0EEh, 06h,0FFh, 04h
		db	0D8h, 2Ah,0AFh,0FFh,0FFh,0FFh
		db	 06h,0EEh, 04h,0FFh,0FBh,0BFh
		db	0FFh, 0Fh,0C0h, 3Fh,0EAh,0AEh
		db	0EAh,0AEh,0EEh,0C0h, 3Ch,0BFh
		db	0FFh,0FFh,0F0h, 03h,0FFh,0F0h
		db	0CFh,0AAh,0ABh,0BFh,0FFh,0F0h
		db	 06h, 00h, 04h, 33h,0FBh,0AAh
		db	0ABh,0AAh,0FBh,0BBh,0AAh,0BFh
		db	0FBh,0BBh,0AEh,0EFh,0AAh,0AAh
		db	 90h, 2Ah,0ABh,0BBh,0BBh,0BBh
		db	0EAh,0AAh,0BEh,0AAh,0ABh,0EFh
		db	0BFh,0FCh, 3Ch, 00h,0FEh,0FAh
		db	0BFh,0FFh,0FFh,0FFh, 03h, 3Ch
		db	 8Fh,0FFh,0FFh,0C0h, 03h,0FFh
		db	0CBh,0FFh, 00h, 00h,0F0h, 00h
		db	 0Fh,0C0h,0C3h, 00h, 00h, 33h
		db	0FFh,0AAh,0ABh, 06h,0AAh, 05h
		db	0D7h, 06h,0AAh, 04h,0ABh, 42h
		db	 06h,0AAh, 0Ah,0ACh,0AAh,0B0h
		db	0F0h, 00h,0FFh,0B8h,0AAh,0AAh
		db	0ACh, 00h,0C3h, 3Eh, 2Eh,0AAh
		db	0AAh,0C0h, 03h, 06h,0FFh, 04h
		db	 33h,0F3h, 0Ch,0FFh,0C0h, 3Ch
		db	0C0h, 00h, 33h,0FBh,0AAh,0ABh
		db	 06h,0FFh, 04h,0D0h, 57h, 06h
		db	0FFh, 05h, 42h,0AAh,0ABh,0BBh
		db	0B6h,0FFh,0FBh,0BBh,0FEh,0EEh
		db	0FAh,0F0h, 3Fh,0C0h,0F0h, 03h
		db	0FEh,0E8h,0AFh,0FFh,0F0h, 33h
		db	 3Fh, 3Eh, 22h,0FFh,0FFh, 00h
		db	 03h, 3Fh,0FFh,0FFh,0FFh, 33h
		db	0F3h, 0Ch,0CFh,0F0h,0FFh,0C0h
		db	 00h, 33h,0FBh,0BAh,0ABh,0AAh
		db	0AAh,0AAh,0B4h, 05h, 55h,0FAh
		db	0AAh,0AAh,0ABh, 7Dh, 04h, 28h
		db	0AAh,0ABh, 56h, 06h,0AAh, 06h
		db	0B0h,0CAh,0C3h, 30h, 0Fh,0FEh
		db	0E8h, 2Ah,0AAh,0B0h, 00h, 3Ch
		db	0FEh, 8Ah,0AAh,0ABh, 00h, 03h
		db	 3Fh,0FFh,0FFh,0FFh, 0Fh,0F3h
		db	 0Ch,0CFh,0C3h, 3Fh,0C0h, 00h
		db	0F3h,0FBh,0AAh,0ABh,0D1h, 7Fh
		db	0FDh, 05h, 5Dh, 77h,0FFh,0F5h
		db	0EAh,0ADh, 7Dh, 88h,0E8h,0AAh
		db	0ABh, 57h,0AAh,0B6h, 06h,0AAh
		db	 04h,0B0h,0CAh,0C0h,0F0h, 0Fh
		db	0FEh,0EAh, 0Ah,0AAh,0B3h, 00h
		db	0FCh,0FAh,0A8h,0AAh,0ACh, 00h
		db	 0Ch, 06h,0FFh, 04h, 0Fh,0F3h
		db	 0Ch,0CFh,0CCh,0FFh,0C0h, 00h
		db	0CFh,0FFh,0AAh,0EAh, 41h,0FFh
		db	0D0h, 5Fh, 75h, 5Fh,0FFh,0D7h
		db	0FAh,0ADh,0DDh, 8Bh, 28h,0AAh
		db	0ADh, 57h,0EAh,0D7h, 06h,0AAh
		db	 04h,0C3h, 0Ah,0C3h,0F0h, 3Fh
		db	0FFh,0AEh, 8Ah,0AAh,0C0h, 0Fh
		db	0F3h,0EEh, 88h,0AAh,0ACh, 00h
		db	 3Ch, 06h,0FFh, 04h, 0Fh,0F3h
		db	 0Ch,0FFh,0C3h,0FFh,0C0h, 00h
		db	0CFh,0FEh,0AAh,0AAh, 57h,0FFh
		db	 55h, 7Dh,0F7h, 7Fh,0FFh,0DFh
		db	0FFh,0ADh, 35h, 30h,0A8h, 8Ah
		db	0A9h, 5Dh,0FBh, 57h,0EAh,0AAh
		db	0AAh,0ABh, 00h,0F3h, 00h,0C0h
		db	 3Fh,0FBh,0AEh, 0Ah,0ABh, 0Ch
		db	0CFh, 33h,0FEh, 80h,0AAh,0A0h
		db	 00h, 3Ch, 06h,0FFh, 04h, 3Fh
		db	0C3h, 33h,0CFh,0C3h,0FFh,0C0h
		db	 00h, 0Fh,0FEh,0AAh,0AAh, 75h
		db	0FFh, 55h,0FDh,0D7h, 7Fh,0FFh
		db	0DFh,0FFh,0F7h, 7Dh, 00h,0B8h
; --- Misdecoded data block (ground bitmap): Sourcer tried to interpret these ---
; bytes as instructions. The mnemonics happen to roundtrip correctly through
; TASM's alt-encoded forms so we keep them here for bit-preservation.

loc_53:
				or	ch,ss:data_19e[bp+si]	; real bytes are ground bitmap
				ja	loc_53
		test	al,0AAh
		stosw				; Store ax to es:[di]
		add	ah,bh			; TASM alt-encodes to 02 E7
		db	 0Fh			; pop cs (8088-only opcode byte 0Fh)
		retn
		aas
		sti
		scasb
		sub	byte ptr [bp+di+3C30h],0CFh	; alt-encoded form
		out	dx,al
		sub	byte ptr [bp+si],0h
		add	al,dh			; TASM alt-encodes
		db	0FFh,0FFh,0FFh,0FCh,0CFh,0C3h
		db	 33h,0CFh,0CFh,0FFh,0C0h, 00h
		db	0F3h,0FFh,0AAh,0BAh,0D7h,0FFh
		db	 77h,0F5h, 5Dh, 06h,0FFh, 04h
		db	0C4h, 30h,0C2h,0B8h, 08h, 88h
		db	0A9h,0F5h, 5Fh,0FFh,0C0h, 0Ah
		db	0ABh, 03h,0FCh, 33h, 03h, 3Fh
		db	0FBh,0BEh, 88h,0ACh, 00h, 3Fh
		db	0FFh,0BAh, 82h, 20h, 00h, 00h
		db	0F3h,0FFh,0FFh,0FFh,0FCh, 3Fh
		db	0C0h,0F3h,0CFh,0F3h,0FFh,0C0h
		db	 00h, 33h,0FFh,0EAh,0EAh, 1Fh
		db	0FFh,0DFh,0D7h, 75h, 06h,0FFh
		db	 04h,0D0h, 30h, 4Bh,0A8h, 20h
		db	0A2h, 2Ah,0D5h, 7Fh,0F0h, 00h
		db	 00h, 3Ch, 00h,0F0h,0CFh, 0Ch
		db	0FFh,0FFh,0AEh,0A2h,0ACh,0C3h
		db	 30h,0FFh,0BEh, 88h, 80h, 00h
		db	 00h,0CFh,0FFh,0FFh,0FFh,0F3h
		db	 3Fh,0C0h,0F3h, 3Fh,0CFh,0FFh
		db	0C0h, 00h, 33h,0FEh,0EBh,0AEh
		db	 3Fh,0FFh,0DFh, 55h, 57h, 06h
		db	0FFh, 04h,0D0h,0C1h,0EBh,0AAh
		db	 08h, 28h,0AAh,0A8h,0B0h, 00h
		db	 00h, 00h, 03h, 0Fh, 30h, 3Ch
		db	 0Ch,0FFh,0EFh,0BBh, 82h,0AAh
		db	 00h,0F3h,0FEh,0BAh, 80h, 80h
		db	 00h, 00h,0CFh,0FFh,0FFh,0FFh
		db	 0Ch,0FFh,0C0h,0F3h, 3Fh,0CFh
		db	0FFh,0C0h, 00h,0F3h,0FEh,0EAh
		db	0AEh,0FFh,0FFh, 7Fh, 5Dh, 57h
		db	 06h,0FFh, 04h,0C1h,0C9h, 4Ah
		db	0AAh, 0Ah, 88h, 00h, 80h, 06h
		db	 00h, 04h, 0Ch, 30h,0FCh,0FCh
		db	 3Ch,0FFh,0FFh,0BBh,0A0h,0AAh
		db	 0Ch,0C3h,0EAh,0FAh,0A0h, 00h
		db	 00h, 03h,0CFh,0FFh,0FFh,0FCh
		db	0F3h,0FFh, 33h, 33h, 3Fh,0F3h
		db	0FFh, 30h, 00h,0F3h,0FEh,0EAh
		db	0AFh, 0Fh,0FDh,0FFh, 75h, 77h
		db	 06h,0FFh, 04h, 43h, 13h, 0Ah
		db	0AAh, 82h,0A0h, 06h, 00h, 06h
		db	 30h,0FCh,0F3h,0F0h, 3Ch,0FFh
		db	0EEh,0FAh,0A8h, 2Ah, 83h,0CFh
		db	0BAh,0FAh,0A2h, 00h, 00h, 30h
		db	0CFh,0FFh,0FFh,0F3h,0CFh,0FFh
		db	 30h,0F3h, 3Fh,0F3h,0FFh,0C0h
		db	 00h,0FFh,0FEh,0EBh,0AEh,0CFh
		db	0FFh,0FDh, 77h, 5Fh, 06h,0FFh
		db	 04h, 40h, 16h,0CAh,0EAh, 82h
		db	 80h, 06h, 00h, 04h, 0Ch, 00h
		db	0F0h,0CFh,0C3h,0C0h,0F3h,0FFh
		db	0BEh,0BBh,0E2h, 0Ah,0B3h,0FFh
		db	0AAh,0EEh,0A0h, 00h, 0Ch, 3Ch
		db	 3Fh,0FFh,0FFh,0F3h,0CFh,0FFh
		db	 30h, 33h, 3Fh,0F3h,0FFh,0F0h
		db	 00h,0F3h,0FEh,0EBh,0AEh, 8Fh
		db	0FFh,0F5h,0DDh,0DFh, 06h,0FFh
		db	 04h, 40h, 24h, 2Ah,0AAh,0A8h
		db	 80h, 00h, 00h, 00h,0C0h,0C0h
		db	 03h,0F0h,0CFh, 0Fh,0C3h,0F3h
		db	0FFh,0BEh,0BFh,0E8h, 0Ah,0AFh
		db	0FFh,0ABh,0EEh,0A2h, 00h, 30h
		db	0F0h, 3Fh,0FFh,0FFh, 0Fh, 3Fh
		db	0FFh, 00h, 33h, 3Fh,0F3h,0FFh
		db	0F0h, 03h,0F3h,0FEh,0EBh,0AAh
		db	0CFh,0FFh,0F5h, 7Fh,0FFh,0F5h
		db	 77h,0FFh,0FDh, 4Fh, 08h,0ABh
		db	0AAh, 22h, 88h, 00h, 00h, 0Fh
		db	 00h, 30h, 03h, 00h,0CFh,0CFh
		db	0C3h,0F3h,0FFh,0BAh,0FBh,0E8h
		db	 82h,0AFh,0FFh,0AFh,0EEh, 88h
		db	 00h, 33h,0C3h, 0Fh,0FFh,0FCh
		db	0F0h,0FFh,0FCh,0C0h,0FFh, 3Fh
		db	0FFh,0FFh,0F0h, 03h,0F3h,0FEh
		db	0EAh,0ABh, 83h,0FFh,0D7h,0DFh
		db	 7Fh, 57h,0FFh,0FFh,0FDh, 0Fh
		db	 33h,0ABh,0AAh, 0Ah, 0Ah, 80h
		db	 00h,0ACh, 33h, 30h, 0Ch, 33h
		db	 0Fh, 3Fh,0C3h,0CFh,0FFh,0FEh
		db	0BBh,0FAh, 00h,0AAh,0FEh,0BFh
		db	0BEh,0A0h, 00h,0F3h, 30h,0CFh
		db	0FFh,0C0h,0CFh,0FFh,0FCh,0C3h
		db	0CFh,0CFh,0F3h,0FFh,0F0h, 03h
		db	0CFh,0FEh,0EAh,0BAh, 83h,0FFh
		db	0D7h,0DFh,0FDh,0DDh,0FFh,0FFh
		db	0F5h, 0Ch, 3Ch,0AEh,0AAh, 0Ah
		db	 0Bh,0EAh, 82h,0F0h, 30h,0F0h
		db	 03h, 0Ch, 3Ch,0FFh, 03h,0CFh
		db	0FEh,0FAh,0BFh,0BAh, 00h,0AAh
		db	0FAh,0EFh,0EEh, 88h, 00h,0FFh
		db	0C3h,0CFh,0FFh,0C3h, 3Fh,0FFh
		db	0F3h,0C3h,0CFh,0CFh,0FCh,0FFh
		db	0FCh, 03h,0CFh,0FFh,0EBh,0EBh
		db	0C3h,0FFh,0DFh, 7Dh,0FDh, 77h
		db	0FFh,0FDh, 54h, 00h, 32h,0AEh
		db	 8Ah, 0Ah, 8Bh,0BAh,0EBh,0A3h
		db	 00h,0C0h, 3Ch, 30h,0FFh,0FFh
		db	 0Fh,0CFh,0FEh,0FAh,0EEh,0AEh
		db	 08h, 28h,0BEh,0EFh,0BFh,0A8h
		db	 00h,0FFh, 30h, 0Fh,0FFh, 0Ch
		db	0FFh,0FFh,0F3h,0C3h,0CFh,0CFh
		db	0FCh, 3Fh,0FCh, 03h,0CFh,0FFh
		db	0EEh,0ABh,0CFh,0FFh, 7Dh,0FFh
		db	0F5h,0FFh,0FFh,0F4h, 54h, 30h
		db	0CAh,0AAh, 8Ah, 0Ah, 0Bh,0BCh
		db	0CEh, 00h,0C3h,0CFh,0F3h, 0Ch
		db	0FCh,0FCh, 0Fh, 3Fh,0FEh,0EAh
		db	0EEh,0EEh, 0Ah,0ACh, 2Fh,0ABh
		db	0FFh,0A8h, 03h,0FFh, 33h, 0Fh
		db	0FFh, 0Ch,0FFh,0FFh,0F3h,0CFh
		db	0CFh,0CFh,0FCh, 3Fh,0FCh, 03h
		db	0CFh,0FFh,0BAh,0EBh, 20h,0FFh
		db	0FFh,0FFh,0F5h,0FFh,0FFh,0F4h
		db	 44h,0C2h,0AAh,0AAh, 8Ah, 20h
		db	 03h,0B0h,0F0h,0CCh,0C0h,0C3h
		db	0CCh,0F0h,0F3h,0FCh, 3Fh,0FFh
		db	0FEh,0FAh,0BEh,0EEh, 88h,0A0h
		db	 2Ah,0EFh,0EFh,0A0h, 03h, 3Fh
		db	 0Ch, 3Fh,0FCh, 33h,0FFh,0FFh
		db	0F3h,0C3h,0CFh,0CFh,0FCh, 3Fh
		db	0FCh, 03h, 0Fh,0FFh,0BAh,0EBh
		db	 00h,0FFh,0FDh,0FFh,0F7h,0FFh
		db	0FFh,0D0h,0D0h,0C2h,0AEh,0BAh
		db	 2Ah, 0Ah, 02h, 30h,0E2h, 00h
		db	 33h, 33h,0F0h,0F3h,0FFh,0F0h
		db	 3Fh,0FFh,0FEh,0EAh,0AFh,0EEh
		db	 28h, 30h, 2Ah,0BBh,0EFh,0A2h
		db	 03h, 3Ch, 0Ch,0FFh,0FCh, 0Ch
		db	0FFh,0FFh,0F3h, 33h,0CFh,0CFh
		db	0FCh,0CFh,0FCh, 03h, 33h,0FFh
		db	0BAh,0ABh, 02h,0FFh,0FFh,0FFh
		db	0D7h,0FFh,0FFh,0D3h,0C3h,0CEh
		db	0EAh,0AAh, 2Ah, 20h, 22h, 03h
		db	 38h,0E0h, 08h,0CFh, 30h,0CFh
		db	0F3h,0C0h,0FFh,0FFh,0FBh,0AAh
		db	0BBh,0EAh, 2Bh,0C0h,0AAh,0AFh
		db	0BAh,0A2h, 0Ch,0F0h,0F0h, 3Fh
		db	0FFh, 0Ch,0FFh,0FFh,0CFh, 0Fh
		db	0F3h,0F3h,0FCh, 3Fh,0FCh, 03h
		db	 33h,0FFh,0FBh,0AEh, 08h,0BFh
		db	0FFh,0FFh, 7Fh,0FFh,0FFh, 43h
		db	 0Fh, 3Ah,0EBh,0AAh, 28h,0A0h
		db	 0Ah,0CBh,0E0h,0E0h,0A3h, 3Ch
		db	0C3h, 03h,0FFh,0C3h,0EFh,0FFh
		db	0FBh,0AAh,0AFh,0BAh, 00h, 00h
		db	0BAh,0ABh,0EEh,0BBh, 0Ch,0F0h
		db	 30h,0CFh,0FFh, 3Ch,0FFh,0FFh
		db	 83h, 33h,0F3h,0F3h,0FCh,0FFh
		db	0FCh, 03h, 33h,0FFh,0FAh,0EEh
		db	0C0h,0BFh, 06h,0FFh, 05h, 43h
		db	 30h,0EAh,0ABh,0EAh, 28h, 88h
		db	 2Ah, 8Bh,0A3h,0E2h,0AFh, 3Ch
		db	 0Ch, 0Fh,0FFh,0C3h,0EFh,0FFh
		db	0FBh,0AEh,0AFh,0BAh, 00h, 02h
		db	0BAh,0ABh,0EBh,0A8h, 33h,0FCh
		db	 00h,0CFh,0F0h, 33h,0FFh,0FFh
		db	 83h, 33h,0F3h,0F3h,0FFh, 03h
		db	0FFh, 0Ch,0FFh,0FFh,0BAh,0EEh
		db	 08h, 3Fh, 06h,0FFh, 04h,0FDh
		db	 0Ch, 00h, 2Bh,0AFh,0AAh,0A8h
		db	0A2h, 0Bh, 0Bh,0EFh,0AAh, 83h
		db	0F3h,0C3h, 3Fh,0FFh, 03h,0BEh
		db	0FFh,0AEh,0AEh,0EFh,0BAh, 00h
		db	 3Eh,0EAh,0AAh,0BBh,0E8h, 8Fh
		db	0F3h, 00h, 3Fh,0FCh,0F3h,0FFh
		db	0FAh, 33h, 0Fh,0F3h,0F3h,0FFh
		db	0FCh,0FFh, 0Ch,0F3h,0FFh,0BAh
		db	0AEh, 30h, 0Fh, 06h,0FFh, 04h
		db	0FDh, 00h, 00h,0CBh,0AFh,0A8h
		db	0A0h, 8Ah, 88h, 2Ch,0EEh,0AAh
		db	 0Fh,0C0h,0CFh, 3Fh,0FFh, 0Fh
		db	0ABh,0FFh,0AAh,0AAh,0BFh,0ECh
		db	 00h,0FEh,0EAh,0AAh,0AAh,0B0h
		db	0CFh,0FFh, 03h, 3Fh,0F3h,0F3h
		db	0FFh,0EEh, 0Fh, 33h,0FFh,0FCh
		db	0FFh,0F0h,0FFh, 0Ch,0F3h,0FFh
		db	0FBh,0AFh, 30h, 0Bh, 06h,0FFh
		db	 04h,0F4h, 03h, 00h, 3Bh,0AEh
		db	0A8h, 88h, 82h, 82h,0AFh, 3Eh
		db	0A0h, 0Fh, 03h,0FCh, 3Fh,0FCh
		db	0FFh,0BAh,0FEh,0AAh,0AEh,0BEh
		db	0AAh, 00h,0FBh,0AAh,0ABh,0AAh
		db	0ABh,0FFh,0FFh, 0Ch,0FFh,0F3h
		db	0FCh,0FBh,0B8h,0CFh, 0Fh,0FCh
		db	0FCh,0FFh,0F0h,0FFh, 0Ch,0F3h
		db	0FFh,0BAh,0EBh, 33h, 83h, 06h
		db	0FFh, 04h,0F4h, 00h,0C0h,0CAh
		db	0AAh,0A2h, 8Ah, 82h,0A0h,0AFh
		db	0FAh,0A0h, 0Fh, 33h, 3Ch,0FFh
		db	0FFh,0FEh,0EFh,0FEh,0E9h, 52h
		db	0AAh, 80h, 00h,0FAh,0AAh,0AFh
		db	0E8h,0AAh,0AFh,0FFh, 33h, 0Fh
		db	0FFh,0FCh,0EEh, 03h, 03h, 3Fh
		db	0FCh,0FCh,0FFh,0FFh,0FFh, 0Ch
		db	0F3h,0FFh,0BAh,0AFh, 30h, 23h
		db	 06h,0FFh, 04h,0D0h, 00h, 03h
		db	 3Ah,0AAh,0A2h, 88h, 80h, 8Ah
		db	 3Fh, 2Ah, 80h,0CCh,0FCh,0F0h
		db	0FFh,0FFh,0FEh,0EBh,0FEh,0E5h
		db	 40h, 00h, 3Ch, 03h,0FAh,0EAh
		db	0AFh,0A8h, 8Ah,0ABh,0FFh,0C0h
		db	 03h,0FFh,0FBh,0A8h, 30h, 33h
		db	 0Fh,0FCh,0F8h,0FFh,0FCh,0FFh
		db	 03h,0F3h, 3Fh,0BAh,0BBh,0C8h
		db	0C0h, 06h,0FFh, 04h,0DCh, 03h
		db	 03h, 2Eh,0AAh,0AAh, 2Ah, 00h
		db	 03h, 3Ch,0EAh, 00h, 30h,0FFh
		db	0C3h,0FFh,0FFh,0EAh,0BFh,0FEh
		db	0A4h, 40h, 00h,0FFh, 0Fh,0EAh
		db	0AAh,0AEh,0BAh, 22h,0AAh,0BFh
		db	0FCh,0CFh,0FFh,0EEh,0A0h,0CCh
		db	 33h, 0Fh,0FCh,0F8h,0FFh,0FFh
		db	0FFh, 03h,0CFh,0FFh,0BAh,0BBh
		db	0CAh, 38h, 3Fh,0FFh,0FFh,0FFh
		db	0D3h, 0Ch, 0Ch,0EEh,0AAh,0AAh
		db	0A8h, 03h, 0Fh, 0Ch,0A8h, 00h
		db	0CCh,0FFh, 3Fh,0FFh,0FFh,0EBh
		db	0BFh,0BEh, 94h, 00h, 0Fh,0FCh
		db	0FFh,0EBh,0AAh,0BEh,0EAh, 22h
		db	0AAh,0ABh,0FCh, 33h, 0Fh,0AAh
		db	 0Ch, 03h, 0Fh, 0Fh,0FFh, 38h
		db	0FFh,0FFh,0FFh, 03h,0CCh,0FFh
		db	0BAh,0FBh,0F3h, 38h, 2Fh,0FDh
		db	0FFh,0F7h,0DCh, 0Ch, 03h,0AAh
		db	0AAh,0A8h,0A0h, 30h, 03h, 32h
		db	0A0h, 0Fh,0F3h,0FFh, 0Fh,0FFh
		db	0FFh,0EEh,0BFh,0BAh, 90h, 03h
		db	0FFh,0F0h,0FFh,0ABh,0AAh,0AAh
		db	0AAh, 28h, 2Ah,0AAh,0BBh, 0Ch
		db	0FEh, 0Ch,0C3h, 0Ch,0CFh, 3Fh
		db	0FFh, 3Ah, 3Fh,0FFh,0FCh,0CFh
		db	0C3h,0FFh,0BBh,0BBh,0FCh, 8Eh
		db	 0Ah, 86h, 83h, 01h,0D3h, 33h
		db	 0Fh,0AAh,0AAh, 88h, 8Ah, 80h
		db	 0Ch, 0Ah,0A0h, 3Ch,0CFh,0FCh
		db	 3Fh,0FFh,0FEh,0BEh,0BEh,0BAh
		db	 94h, 0Fh,0FFh,0C3h,0FFh,0AAh
		db	0AAh,0BAh,0EAh, 0Ah, 00h,0AAh
		db	0AEh,0FFh,0E8h,0F0h, 0Fh, 00h
		db	0CCh,0CFh,0FFh, 3Bh, 3Fh,0FFh
		db	0BCh, 0Fh,0C3h,0FFh,0FEh,0FBh
		db	0FCh,0A2h, 03h,0EBh,0A2h, 85h
		db	 8Ch,0F0h,0C2h,0BAh,0EAh, 82h
		db	 28h, 0Ch, 3Ch, 0Ah, 80h,0F0h
		db	 33h,0FCh, 3Fh,0FFh,0FEh,0EAh
		db	0FEh,0EAh, 55h, 0Fh,0FFh, 33h
		db	0FEh,0ABh, 2Ah,0AEh,0AAh, 0Ah
		db	 80h, 00h,0ABh,0BEh, 80h,0F0h
		db	 2Ch,0CCh,0CCh, 3Fh,0FFh, 3Eh
		db	 3Fh,0FFh,0B0h, 33h,0CFh,0FFh
		db	0EEh,0ABh,0FFh, 2Ch, 83h, 00h
		db	 00h, 53h,0CCh,0F0h,0CEh,0EAh
		db	0EAh, 28h,0A0h, 00h
		db	 3Fh, 2Ah, 0Ch

; Sourcer thought these data bytes formed a tiny 'retn' stub. Keeping as one
; mnemonic (retn = 0xC3) so the byte is preserved but labeling it data.

locloop_54:
		retn				; ground data byte 0xC3 (misdecode)

; Ground bitmap data continues (misdecoded as 'xor di, sp'...).
		xor	di,sp			; ground data bytes 0x33 0xFC (misdecode)
		db	0FFh,0FFh,0FAh,0BBh,0FAh,0EAh
		db	 55h, 3Fh,0FFh, 03h,0FEh,0A8h
		db	 0Ah,0BAh,0A8h, 80h,0AAh, 80h
		db	 2Ah,0A8h, 0Fh, 02h, 8Ch, 03h
		db	 3Ch, 3Fh,0FFh, 3Ah, 3Fh,0FFh
		db	0BCh, 33h,0C3h,0FFh,0EEh,0EBh
		db	0FFh,0CAh,0E0h,0D5h, 95h, 17h
		db	 70h,0F3h,0CEh,0EAh,0AAh, 28h
		db	0A8h, 0Ch,0CFh,0EAh, 33h,0CFh
		db	0CFh,0F0h,0FFh,0FFh,0FAh,0FBh
		db	0FBh,0A9h, 55h, 7Fh,0FCh, 0Fh
		db	0FAh,0A0h, 0Ah,0AAh,0EAh, 22h
		db	 02h,0AAh, 8Ah,0A0h, 03h, 28h
		db	 3Ch,0CFh, 3Ch,0FFh,0FFh, 3Ah
		db	 3Fh,0FFh,0B3h, 33h, 33h,0FFh
		db	0EEh,0EBh,0AFh,0F0h,0B8h, 03h
		db	 5Fh, 17h, 73h,0C3h,0FEh,0AAh
		db	0A8h,0A0h,0A8h,0C0h,0FFh,0A8h
		db	 30h,0FCh, 3Fh, 30h,0FFh,0FFh
		db	0FBh,0FAh,0FBh,0A9h, 05h, 7Fh
		db	0FCh, 0Fh,0FAh,0A0h,0F2h,0ABh
		db	0EAh,0A8h, 20h, 0Ah, 2Ah, 80h
		db	 0Fh,0A0h,0F3h, 03h,0F3h,0FFh
		db	0FFh, 3Eh, 3Fh,0FFh,0ECh, 0Fh
		db	 0Fh,0FFh,0EEh,0EBh,0AAh,0BFh
		db	 0Ah, 20h, 04h,0DFh, 33h,0C7h
		db	0CEh,0AAh,0E8h
; Another misdecoded data slice: A2 8A 33 bytes -> 'mov ds:[0x338A],al'.
; The label is kept data-only; real handler code elsewhere already references
; jpt_mountains_render as a CS:-relative constant.

loc_55:
		mov	ds:jpt_mountains_render,al	; misdecode of ground bitmap bytes
		db	 3Eh, 8Bh,0C0h,0F0h,0FCh, 00h
		db	0FFh,0FFh,0FBh,0EAh,0FBh,0A5h
		db	 10h,0FFh,0FFh, 3Fh,0FEh, 80h
		db	0F8h,0AAh,0FAh, 0Ah, 00h, 20h
		db	 2Ah, 80h, 32h,0E3h,0E0h,0CFh
		db	0F3h,0FFh,0FFh, 3Bh, 3Fh,0FFh
		db	0BCh, 0Fh, 33h,0FFh,0EEh,0EBh
		db	 2Eh,0AAh,0E0h, 2Ch, 0Bh, 7Ch
		db	0C3h,0C7h,0C2h,0AAh,0B8h, 02h
		db	 0Bh,0CFh,0C2h, 2Fh, 33h,0CFh
		db	0F3h, 03h,0FFh,0FFh,0EFh,0AFh
		db	0FAh,0A4h, 00h,0FFh,0C0h,0FCh
		db	 0Ah, 03h, 38h,0AAh,0AAh,0A2h
		db	 80h, 80h,0AAh, 00h, 0Fh,0A3h
		db	0F3h, 3Fh, 33h,0FFh,0FFh, 3Ah
		db	 3Fh,0FEh,0EFh, 0Fh,0F3h,0FFh
		db	0FAh,0AAh, 8Ah,0AAh,0BAh, 80h
		db	0A8h, 04h,0CFh,0CFh,0C2h,0ABh
		db	0A0h, 2Ah, 0Fh,0FCh,0AAh, 2Ch
		db	0F3h,0CFh,0CCh, 03h,0FFh,0FFh
		db	0EEh,0EBh,0EAh,0A4h, 10h,0FFh
		db	 33h, 03h, 30h, 0Fh, 2Ah, 28h
		db	0FAh,0A8h, 2Ah, 8Ah,0AAh, 00h
		db	0FEh, 83h,0E8h, 3Fh,0F3h,0FFh
		db	0FFh, 3Ah, 3Fh,0FFh,0A3h, 3Fh
		db	 0Fh,0FFh,0FAh,0EBh, 80h,0AAh
		db	0ABh,0FBh, 0Ah, 53h, 3Fh, 1Fh
		db	0C0h,0AAh, 82h, 80h, 3Fh, 3Ah
		db	 02h,0ACh, 3Fh, 3Fh,0CCh, 3Fh
		db	0FFh,0FFh,0AFh,0AAh,0EAh, 94h
		db	 43h,0FFh,0C0h,0F0h,0C0h, 3Ch
		db	0FAh, 23h,0FFh,0AAh, 80h, 0Ah
		db	 82h, 80h, 3Bh, 8Fh,0A3h, 3Fh
		db	0CFh,0FFh,0FFh, 3Ah, 3Fh,0FEh
		db	0E0h,0CFh, 0Fh,0FFh,0EEh,0EAh
		db	0A0h, 2Ah,0AAh,0AEh,0F5h, 0Fh
		db	0FCh, 5Fh,0CCh,0BFh,0AAh, 80h
		db	0FCh,0F8h, 2Bh, 30h,0FFh,0FFh
		db	 30h, 3Fh,0FFh,0FFh,0EEh,0AEh
		db	0EEh, 90h, 43h,0FCh, 0Fh, 33h
		db	 3Fh,0C3h,0A2h,0CFh,0FFh,0FEh
		db	0AAh, 0Ah, 2Ah, 00h,0CEh, 32h
		db	0E0h,0FFh,0CFh,0FFh,0FFh, 2Eh
		db	 3Fh,0FEh,0A0h, 3Fh, 0Fh,0FFh
		db	0EEh,0ABh,0AAh, 02h,0AAh,0AAh
		db	0A4h, 10h,0F9h,0BFh, 3Eh,0BAh
		db	 00h, 3Fh,0EEh, 01h, 60h, 23h
		db	0FFh,0FFh,0F2h,0FEh,0EFh,0FEh
		db	0AEh,0BBh,0EEh, 88h, 33h,0B8h
		db	 22h, 08h, 8Ah, 0Bh,0A2h, 8Bh
		db	0EEh,0FEh,0EAh, 8Ah, 2Ah, 08h
		db	0FEh, 3Fh, 88h,0EEh,0BFh,0FFh
		db	0FFh, 2Ah, 8Fh,0FEh,0EBh, 3Bh
		db	 0Fh,0EEh,0FAh,0EBh,0A8h,0A0h
		db	 02h,0AAh, 91h, 07h,0E2h, 7Bh
		db	 3Ah,0AEh, 00h,0BFh,0E8h, 81h
		db	 63h,0CBh,0FCh,0FFh,0C3h,0BAh
		db	0BFh,0FBh,0AAh,0ABh,0BAh, 80h
		db	 3Eh,0E2h, 80h,0A2h, 3Ah, 23h
		db	0A8h,0A3h,0BBh,0FBh,0AAh,0AAh
		db	0A8h, 02h,0CFh,0BEh, 83h,0FBh
		db	0BEh,0FBh,0FFh, 3Bh, 8Fh,0FAh
		db	0E3h, 3Ah, 2Fh,0BAh,0FEh,0AAh
		db	0AAh, 08h, 00h, 02h, 50h, 5Fh
		db	0A1h,0FEh, 3Eh,0BAh, 33h,0EEh
		db	0A0h, 09h, 88h,0CCh,0E8h,0FFh
		db	 8Eh,0FAh,0BFh,0FBh,0AEh,0BBh
		db	0EEh, 83h, 3Bh,0A2h, 82h, 00h
		db	0E8h, 0Eh,0A8h,0BAh,0BEh,0BEh
		db	0FFh,0AAh,0A8h, 00h,0FBh, 3Bh
		db	0AEh,0EEh,0BBh,0BFh,0FFh, 2Eh
		db	 8Fh,0BBh, 8Ch,0EEh, 8Fh,0BAh
		db	0FAh,0EAh,0AAh,0A0h, 0Ah,0A5h
		db	 01h,0FBh, 97h,0EAh,0BAh,0B8h
		db	 0Ch,0FAh,0A0h, 26h, 83h, 88h
		db	0EAh,0FEh, 03h,0AAh,0BFh,0AEh
		db	0BAh,0ABh,0EEh, 08h,0EBh,0A2h
		db	 8Ah, 03h,0F8h, 02h,0A2h, 2Fh
		db	0BBh,0FAh,0BFh,0FBh,0A8h, 22h
		db	0FAh,0FEh, 8Fh,0FAh,0BFh,0BEh
		db	0FFh, 3Fh, 8Fh,0BBh, 83h,0FEh
		db	 0Bh,0BAh,0EAh,0BEh,0AAh,0AAh
		db	0A0h, 10h, 1Fh,0EAh, 5Fh,0A8h
		db	0EAh,0A8h, 3Bh,0AAh, 83h, 26h
		db	 83h, 82h,0EAh,0FEh, 8Eh,0AEh
		db	0BFh,0AEh,0AAh,0AEh,0FAh, 23h
		db	 3Eh, 8Ah, 88h, 0Fh,0B8h, 8Ch
		db	0A8h, 8Bh,0AAh,0ABh,0EEh,0BEh
		db	 80h, 80h,0BBh,0EEh,0AEh,0EAh
		db	0EBh,0AEh,0EFh, 2Eh,0CEh,0EAh
		db	 83h,0FEh, 0Eh,0BAh,0ABh,0EEh
		db	0AAh,0AAh,0AAh, 41h,0EFh,0A9h
		db	0BAh,0AAh,0EAh,0A8h, 0Eh,0AAh
		db	 80h,0E6h, 2Eh, 83h,0E2h,0EEh
		db	 2Eh,0AAh,0FBh,0BAh,0BAh,0AFh
		db	0BAh, 08h,0FAh, 2Ah,0A8h, 2Ah
		db	0E8h, 0Ah,0A8h,0A0h,0BEh,0AAh
		db	0AAh,0A2h, 20h, 20h,0EEh, 3Eh
		db	 8Fh,0AFh,0ABh,0BAh,0FAh, 2Bh
		db	0CEh,0EAh, 8Eh,0EEh, 3Eh,0AAh
		db	0EAh,0EFh,0AAh,0AAh,0AAh, 1Fh
		db	0BAh,0A6h,0AAh,0A7h,0AAh,0A8h
		db	 8Bh,0AAh, 03h,0BAh, 8Eh, 23h
		db	0AAh,0BAh, 3Ah,0BAh,0EEh,0AAh
		db	0EEh,0AAh,0BAh, 08h,0EAh, 8Ah
		db	 8Ah, 0Ah,0E8h, 0Eh,0A8h, 2Ah
		db	 20h, 0Fh,0BAh, 00h, 00h, 8Bh
		db	0A8h,0FAh,0BBh,0BAh,0AEh,0AAh
		db	0E8h,0ABh, 8Fh,0EAh, 32h,0FAh
		db	 3Bh,0BAh,0AFh,0BAh,0AAh,0AAh
		db	0A9h, 7Fh,0EAh, 06h,0AAh, 04h
		db	0A3h, 3Eh,0A8h, 33h,0EAh, 3Eh
		db	 0Fh,0ABh,0E8h,0EAh,0EBh,0EEh
		db	0ABh,0FAh,0AEh,0E8h, 82h,0BAh
		db	 2Ah,0A8h, 0Ah,0A0h, 0Ah,0AAh
		db	 0Ah,0AAh, 2Ah,0A0h, 00h,0A0h
		db	 3Eh,0A3h,0EAh,0AEh,0EAh,0AAh
		db	0ABh,0B8h,0AEh,0CFh,0EAh, 0Eh
		db	0EEh,0BEh,0BAh,0ABh,0BAh,0AAh
		db	0AAh, 85h,0FBh,0AAh,0EAh,0AAh
		db	0BAh,0AAh, 03h,0EAh,0A8h, 0Eh
		db	0AAh, 3Ah, 3Bh,0AEh,0A0h,0FAh
		db	0EAh,0AAh,0ABh,0EAh,0BAh,0A8h
		db	 23h,0EAh, 2Ah,0A2h, 0Eh,0A8h
		db	 0Eh,0AAh,0A2h,0A0h, 80h, 00h
		db	 20h,0AFh,0EAh,0A3h,0AAh,0BAh
		db	0EAh,0AAh,0AAh,0AAh,0ABh, 8Eh
		db	0AEh, 0Eh,0FAh,0FAh,0AAh,0AEh
		db	0EAh,0AAh,0A9h, 7Eh,0FEh,0AFh
		db	0AAh,0AAh,0BAh,0A8h, 3Eh,0AEh
		db	0A0h, 3Eh,0AAh,0EAh,0EBh,0AEh
		db	0A0h,0EAh,0ABh,0AAh,0ABh,0AAh
		db	0BAh,0E2h, 2Eh,0B8h,0AAh,0A8h
		db	0AEh,0A2h, 3Ah,0AAh,0AAh, 08h
		db	 00h, 20h, 8Fh,0BAh,0AAh, 8Ah
		db	0AAh,0BBh,0AAh,0AAh,0AAh,0A2h
		db	0ABh, 2Fh,0AEh, 0Bh,0AAh,0EAh
		db	0EAh,0AEh,0EAh,0AAh,0A7h,0EBh
		db	0AAh,0BAh,0AAh,0AAh,0BAh,0A8h
		db	 3Ah,0BAh, 80h,0FAh,0A8h,0AAh
		db	0EAh,0AEh, 83h,0FAh,0AAh,0AAh
		db	0AEh,0AAh,0EBh,0A0h,0AEh,0E8h
		db	0AAh,0A2h, 2Ah,0A0h, 3Ah,0AAh
		db	0A0h, 20h, 00h, 8Fh,0AAh,0AAh
		db	0AAh,0AFh,0AAh,0BBh,0AAh,0AAh
		db	0BAh,0AAh,0ABh, 3Bh,0AEh, 3Fh
		db	0BAh,0BAh,0EAh,0BAh,0EAh,0AAh
		db	 7Eh,0AAh,0AAh,0BAh,0AAh,0EAh
		db	0EAh,0AAh,0EBh,0EAh, 8Fh,0BAh
		db	0AAh,0AAh,0ABh,0EEh, 8Ch,0EAh
		db	0AEh, 06h,0AAh, 04h,0A0h,0AFh
		db	0AAh,0AAh,0A8h, 2Ah,0A2h,0AAh
		db	0AAh, 22h,0A3h, 33h,0EAh,0AAh
		db	0AAh,0A8h,0BAh,0AAh,0BBh,0AAh
		db	0AAh,0FAh,0A2h,0AEh,0FBh,0AAh
		db	 0Fh,0EAh,0EAh,0EFh,0EAh,0EAh
		db	0AAh,0EEh,0AAh,0AAh,0EAh,0ABh
		db	0AAh,0EAh,0A8h,0BEh,0AAh, 3Eh
		db	0EAh,0AAh,0AAh,0EBh,0EAh,0A3h
		db	 06h,0AAh, 05h,0EBh, 82h,0BBh
		db	 06h,0AAh, 04h, 8Bh,0AAh,0AAh
		db	0AAh,0A0h,0CAh, 06h,0AAh, 04h
		db	0EAh,0AAh,0AEh,0AAh,0ABh,0BAh
		db	0AAh,0A8h,0FAh,0A8h, 8Bh,0AAh
		db	0EAh,0BAh,0ABh,0BAh,0A7h, 06h
		db	0AAh, 04h,0A7h,0ABh,0AAh,0ABh
		db	0EEh,0AAh, 3Ah,0AAh,0AAh,0ABh
		db	0ABh,0AEh, 8Eh,0EAh,0BAh,0AAh
		db	0AAh,0ABh,0AAh, 80h,0BEh, 06h
		db	0AAh, 04h,0A3h,0AAh,0AAh,0AAh
		db	 8Fh, 06h,0AAh, 04h,0BAh,0AAh
		db	0AAh,0AEh,0AAh,0AEh,0EAh,0A2h
		db	0A8h,0EAh,0E8h, 2Bh,0EAh,0EBh
		db	0AAh,0ABh,0AAh,0BAh, 06h,0AAh
		db	 04h, 9Fh,0AAh,0AAh,0ABh,0BAh
		db	0A8h,0EEh,0AAh,0AAh,0AAh,0AFh
		db	0AAh, 8Fh,0AAh,0BAh,0AAh,0AAh
		db	0ABh,0AEh, 88h,0BAh,0AAh,0AAh
		db	0A2h,0AAh,0ABh,0AAh,0AAh,0AAh
		db	0AEh,0EAh, 06h,0AAh, 08h,0FFh
		db	0AAh, 8Ah,0A2h,0EBh,0A8h, 2Bh
		db	0AAh,0EAh,0AAh,0AEh,0EAh,0EAh
		db	0AAh,0AAh,0AAh,0A5h, 7Eh,0AAh
		db	0AAh,0ABh,0BAh,0A8h,0EAh,0AAh
		db	0AAh,0AAh,0BEh,0AAh,0AFh,0AAh
		db	0EAh,0AAh,0AAh,0AAh,0AEh, 22h
		db	0BAh, 06h,0AAh, 08h, 8Fh, 06h
		db	0AAh, 08h,0ABh,0FAh,0AAh,0AAh
		db	0ABh,0ABh,0A8h, 2Bh,0AAh,0AAh
		db	0AAh,0FFh, 06h,0AAh, 05h, 9Fh
		db	0EAh,0AAh,0AAh,0ABh,0AAh,0A8h
		db	0AAh,0AAh,0AAh,0ABh,0EAh, 06h
		db	0AAh, 07h,0BAh, 0Ah,0EAh, 06h
		db	0AAh, 07h,0A8h, 3Ah, 06h,0AAh
		db	 0Ch, 0Ah,0AEh,0AAh,0AEh,0AAh
		db	0EAh,0ABh,0BAh, 06h,0AAh, 05h
		db	 7Ah,0AAh,0AAh,0AAh,0AEh, 06h
		db	0AAh, 08h,0AEh, 06h,0AAh, 05h
		db	0BAh, 8Ah, 06h,0AAh, 08h, 82h
		db	0EEh, 06h,0AAh, 0Dh,0AEh,0A8h
		db	0AAh,0AAh,0AAh,0AEh, 06h,0AAh
		db	 1Ah, 2Ah, 06h,0AAh, 07h,0A8h

; ==========================================================================
; ground: 16-row RLE source for foreground ground/grass layer.
; Decoded by rle_decode_ground_28 into seg1:0000 (16 rows x 28 bytes).
; Format: high-nibble 6 = 'emit low_nibble zeros', else emit byte as-is.
; ==========================================================================

ground:
		db	 06h,0AAh, 14h,0AEh		; 0Ah 'emit 6 zeros' style prefix
		db	0AAh,0AAh
		db	 7Dh, 17h,0DDh, 47h, 55h, 35h
		db	 54h, 7Dh, 1Fh, 45h,0F5h,0F4h
		db	 7Dh, 51h,0DFh,0D5h, 54h, 1Dh
		db	 54h, 53h,0CFh, 4Fh, 74h,0F7h
		db	 37h,0DFh, 4Fh, 4Fh, 7Dh, 17h
		db	0DDh, 47h, 55h, 35h, 54h, 7Dh
		db	 1Fh, 45h,0F5h,0F4h, 7Dh, 51h
		db	0DFh,0D5h, 54h, 1Dh, 54h, 53h
		db	0CFh, 4Fh, 74h,0F7h, 37h,0DFh
		db	 4Fh, 4Fh, 15h, 4Dh, 55h, 1Dh
		db	 55h, 43h, 41h,0D5h, 45h, 44h
		db	 01h, 51h,0D5h,0D1h,0D5h, 40h
		db	 01h,0F5h
		db	'U', 0Dh, 'EMSU5U54'
		db	 15h, 4Dh, 55h, 1Dh, 55h, 43h
		db	 41h,0D5h, 45h, 44h, 01h, 51h
		db	0D5h,0D1h,0D5h, 40h, 01h,0F5h
		db	'U', 0Dh, 'EMSU5U54'
		db	 05h, 4Dh, 54h, 00h, 05h, 54h
		db	 1Ch, 55h, 45h, 63h, 01h, 54h
		db	 55h, 3Dh,0F4h, 55h, 55h, 35h
		db	 01h, 4Dh, 51h, 55h, 4Dh, 40h
		db	 05h, 10h, 85h, 4Dh, 54h, 00h
		db	 05h, 54h, 1Ch, 55h, 45h, 01h
		db	0F4h, 00h, 01h, 54h, 55h, 3Dh
		db	0F4h, 55h, 55h, 35h, 11h, 4Dh
		db	 51h, 55h, 4Dh, 40h, 05h, 11h
		db	 65h, 05h, 35h, 15h, 67h, 01h
		db	 54h, 55h, 40h, 50h, 00h, 35h
		db	 54h,0D5h, 50h, 63h,0E0h, 62h
		db	0FFh,0A0h, 05h, 35h, 15h, 00h
		db	0BEh,0EBh,0EFh,0B8h, 62h, 01h
		db	 54h, 55h, 40h, 50h,0E8h, 35h
		db	 54h,0D5h, 50h, 3Fh,0A0h, 03h
		db	 66h, 75h, 14h, 69h, 05h, 3Dh
		db	 63h, 54h, 50h, 64h, 57h, 7Dh
		db	 7Fh,0D5h, 5Dh,0F0h, 75h, 14h
		db	 1Fh, 55h,0D5h,0D5h, 55h,0F5h
		db	0FDh,0FCh, 00h, 05h, 3Dh, 07h
		db	 5Dh, 40h, 54h, 50h, 07h,0F5h
		db	0D5h,0FDh, 66h, 15h, 40h, 68h
		db	 6Ch,0AEh,0AAh,0ABh,0AAh,0AAh
		db	0AEh, 15h, 43h,0BAh,0BAh,0ABh
		db	0AAh,0EAh,0BAh,0AAh,0ABh,0FEh
		db	0E0h, 00h,0FAh,0EEh,0AAh, 00h
		db	 0Fh,0BAh,0EAh,0EBh,0AAh
		db	'nnUUWUUU@'
		db	 1Dh, 75h, 55h, 55h, 55h, 55h
		db	 75h, 55h,0D5h,0DDh, 5Dh,0FDh
		db	 55h,0DDh, 55h, 75h, 5Dh, 75h
		db	0D5h, 57h, 55h, 6Eh, 6Eh,0AEh
		db	14 dup (0AAh)
		db	0ABh,0AAh,0AAh,0EAh,0ABh,0AAh
		db	0AAh,0AAh,0AAh			; last 3 AAh's of 'ground'

; ==========================================================================
; ground1: 16-row RLE source for the second (tiled) ground band.
; Referenced via 'mov si, ground1_src_ofs' (= 0x56F1).
; Same RLE format as 'ground' above.
; ==========================================================================

ground1:
		db	0AAh,0AAh,0AAh			; 3 literal AAh rows then 'i', 0Ch, 'oc...'
		db	0AAh
		db	'i', 0Ch, 'ocUUUUU'
		db	'UUUU]EUU]uU'
		db	12 dup (55h)
		db	 69h, 30h, 64h, 0Fh, 00h, 0Ch
		db	 65h,0C0h, 65h,0AEh,0AAh,0BAh
		db	0BAh,0AAh,0AAh,0AAh,0BAh,0BAh
		db	 80h, 2Bh,0AAh,0AEh,0AAh,0AFh
		db	0AAh,0AEh,0AAh,0AAh,0ABh,0AAh
		db	0AAh,0EBh,0AAh,0EAh,0EAh,0AAh
		db	0AAh, 69h,0C0h, 62h, 0Ch,0C0h
		db	0F0h, 00h,0FCh, 30h, 63h, 0Fh
		db	 66h, 55h, 55h,0D5h, 55h, 57h
		db	 55h,0D5h, 75h, 55h, 05h, 57h
		db	 55h, 5Dh,0D5h,0F0h, 75h,0CDh
		db	 75h, 75h, 57h, 55h, 5Fh, 1Dh
		db	 55h, 55h, 55h, 75h, 5Dh, 63h
		db	 10h, 64h, 03h, 30h,0F0h, 03h
		db	0CFh, 03h,0CCh, 0Fh,0F3h, 63h
		db	 0Fh, 50h, 00h, 30h, 62h, 03h
		db	 00h,0AAh,0AEh,0AAh, 9Ah,0EAh
		db	0ABh,0AAh,0EAh,0ABh, 3Ah,0F2h
		db	0A8h,0E3h, 2Bh, 0Eh,0ACh,0F3h
		db	0AAh,0AAh,0AAh,0A3h, 58h, 82h
		db	0BAh,0ABh,0AAh,0ABh, 2Ah, 63h
		db	0C0h, 64h, 3Fh, 0Fh, 00h,0FCh
		db	 30h,0CFh, 30h,0FDh,0C1h,0CCh
		db	 00h, 3Dh, 70h, 0Fh, 03h,0C0h
		db	 62h,0F0h, 3Ch, 55h, 55h,0D5h
		db	 55h,0D5h, 55h, 55h, 55h, 73h
		db	 13h, 05h,0CCh, 70h,0D3h, 31h
		db	0C1h,0C5h,0DDh, 5Dh, 4Dh, 70h
		db	 13h, 54h,0C5h, 55h, 55h,0F1h
		db	 7Dh, 33h, 00h, 03h, 40h, 63h
		db	 03h,0F5h,0F7h,0C0h, 03h,0D3h
		db	 3Dh, 3Fh,0FFh,0C4h, 0Fh, 01h
		db	0C0h, 0Fh,0FFh,0CCh, 03h, 30h
		db	 0Ch, 03h,0C0h,0A0h, 2Eh,0A9h
		db	 4Ah,0ABh,0AAh,0AAh,0EBh, 35h
		db	0F7h,0EAh, 0Bh,0D3h,0BDh, 0Fh
		db	0FFh,0C4h, 2Fh, 29h,0C0h, 8Fh
		db	 0Fh,0ECh, 28h, 32h,0ACh,0ABh
		db	0C2h,0FCh, 00h, 03h, 10h, 62h
		db	 0Ch, 3Bh, 5Fh, 5Fh,0FDh,0B0h
		db	0CCh,0DFh, 77h, 5Fh, 7Fh, 31h
		db	 34h, 3Fh,0FDh,0F5h, 30h, 3Dh
		db	 03h,0C0h,0FCh, 3Fh, 9Ch, 55h
		db	 57h, 15h,0D5h, 55h, 5Dh, 7Bh
		db	 5Ch, 5Fh,0F1h,0B1h,0CCh, 1Ch
		db	 77h, 5Fh, 70h, 31h, 75h, 70h
		db	0FDh,0F5h, 31h, 71h, 14h,0C1h
		db	 3Ch, 43h,0FFh,0A4h, 0Dh, 22h
		db	 00h, 45h,0BFh,0D5h, 7Dh,0FDh
		db	 5Fh, 5Fh, 5Fh, 55h,0DDh, 7Dh
		db	 7Fh,0FFh,0D7h,0FFh, 5Fh, 57h
		db	0FDh, 77h, 7Ch, 3Dh, 5Fh, 75h
		db	0FFh,0A4h,0ADh, 2Ah,0AAh,0EFh
		db	0BFh,0D5h, 71h,0FDh, 5Fh, 5Fh
		db	 5Fh, 55h,0DDh, 7Dh, 7Fh,0FFh
		db	0D7h,0FFh, 5Fh, 57h,0CDh, 77h
		db	 7Eh,0B1h
		db	 5Fh, 75h

seg_a		ends

		end	start
