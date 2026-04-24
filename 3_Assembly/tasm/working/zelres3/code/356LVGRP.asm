
PAGE  59,132

;==========================================================================
;
;  356LVGRP.BIN - Level Graphics Data (zelres3 chunk 56)
;
;  Packed level-graphics data (tile patterns, tilemap layout bytes,
;  palette deltas) consumed by the map/tile renderer. 6265 bytes of
;  raw data; Sourcer defaulted to "zero start" code mode and decoded
;  scattered bytes as instructions (jc/mov/jmp far/etc.), but the file
;  contains no real executable code -- there are no proc/retn sites,
;  no INT 10h calls, and the "jmp far ptr" bytes at offsets ~319 / ~352
;  are data (0EAh is just a palette/attribute value here, not an opcode).
;  These data bytes are also why this file required compile-fix db
;  blocks for unassemblable "far ptr" and alt-encoding forms.
;
;  The 0x39 byte is the apparent tilemap run-length / section marker
;  (analogous to 0E6h in 351TILAN.BIN).
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; Data-reference equates retained from Sourcer's code-mode analysis.
; These are data values that happened to land inside mod-r/m byte
; positions during disassembly; most are not genuine references.

data_1e		equ	0CC0h			;*
data_2e		equ	5B01h			;*
data_3e		equ	5D01h			;*
data_4e		equ	5E15h			;*
data_5e		equ	80A9h			;*
data_6e		equ	5500h			;*
data_7e		equ	5515h			;*
data_21e	equ	2804h			;*
data_22e	equ	2B38h			;*
data_23e	equ	300Ch			;*
data_24e	equ	3903h			;*
data_25e	equ	3940h			;*
data_26e	equ	4600h			;*
data_27e	equ	4642h			;*
data_28e	equ	5000h			;*
data_29e	equ	5400h			;*
data_30e	equ	5D01h			;*
data_31e	equ	7E00h			;*
data_32e	equ	80A0h			;*
data_33e	equ	9E03h			;*
data_34e	equ	0A0E0h			;*
data_35e	equ	0A333h			;*
data_36e	equ	0A800h			;*
data_37e	equ	0A8AAh			;*
data_38e	equ	0AA00h			;*
data_39e	equ	0B7C0h			;*
data_40e	equ	0B808h			;*
data_41e	equ	0FA01h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

ZR356FUL	proc	far

start:
level_graphics_data	label	byte
;*		jc	loc_3			;*Jump if carry Set
		db	072h, 018h		; jc 1Ah (absolute)
		add	[bx+si],al
		add	byte ptr data_9,al
		dec	si
		add	ah,[bp+di-80h]
		xchg	cx,ax
		and	ds:data_33e[si],bl
		stosb				; Store al to es:[di]
		lahf				; Load ah from flags
		or	ss:data_39e[bp+di],dh
		inc	ax
		mov	cx,0BD01h
		test	al,0C5h
		add	al,0C7h
		mov	al,data_20
		db	0DBh, 30h,0E2h, 0Ah,0E5h, 0Ch
		db	0E6h,0EAh,0E7h, 2Ah,0F9h, 50h
		db	0FFh,0FFh
data_8		dw	2F39h			; Data table (indexed access)
		db	 0Ah, 39h, 01h, 2Bh, 39h, 01h
		db	0BFh
data_9		dw	200h			; Data table (indexed access)
		db	 2Ah,0FFh, 00h, 2Bh, 39h, 06h
		db	 80h, 39h, 01h, 80h, 39h, 01h
		db	0E8h, 00h, 80h, 00h,0FEh, 00h
		db	 80h, 00h,0FFh, 80h,0E0h, 00h
		db	0FFh,0EAh,0FAh, 39h, 00h,0BFh
		db	 00h, 02h, 00h, 2Fh, 39h, 01h
		db	 0Ah, 39h, 14h,0FFh, 80h,0E0h
		db	 00h,0FEh, 00h, 80h, 00h,0E8h
		db	 00h, 80h, 00h, 80h, 39h, 01h
		db	 80h, 39h, 01h, 80h, 39h, 0Ah
		db	 03h, 00h, 02h, 00h, 0Fh, 00h
		db	 02h, 9Ch, 00h
data_10		dw	2			; Data table (indexed access)
		db	 30h, 3Ch, 20h, 08h, 00h,0CCh
		db	 39h, 00h, 03h, 0Ch, 39h, 01h
		db	 03h, 00h, 02h
data_11		dw	3FF0h
		db	 80h, 28h, 39h, 02h,0C0h, 00h
		db	 80h, 00h, 0Ch, 00h, 08h, 39h
		db	 03h,0F0h, 30h,0A0h, 20h, 0Ch
		db	 00h, 08h, 39h, 03h,0C0h,0CFh
		db	 80h, 00h, 0Ch,0CFh, 39h, 01h
		db	 03h, 00h, 02h, 0Ch,0C0h, 39h
		db	 01h, 0Fh, 00h, 02h, 33h, 30h
		db	 20h, 39h, 04h,0C3h, 00h, 82h
		db	 00h, 03h, 39h, 00h,0CCh, 00h
		db	 80h, 00h, 03h,0C0h, 00h, 80h
		db	0CCh
data_12		dw	539h
		db	0DBh, 00h, 00h, 20h, 03h, 00h
		db	 02h, 00h,0F0h, 00h
data_13		dw	3920h			; Data table (indexed access)
		db	 07h, 03h, 00h, 02h, 39h, 03h
		db	0C0h, 00h, 80h, 39h, 00h, 03h
		db	 00h, 02h, 39h, 03h, 3Ch, 00h
		db	 20h,0DBh, 00h, 20h, 39h, 03h
		db	 03h, 0Ch, 02h, 08h, 39h, 06h
		db	 30h, 00h, 20h, 00h, 9Ch, 00h
		db	 4Eh, 00h,0C0h, 00h, 80h, 00h
		db	 03h, 39h, 02h, 0Ch, 00h, 08h
		db	 00h,0C0h, 00h, 80h, 00h, 03h
		db	 00h, 02h, 39h, 0Ah, 03h, 00h
		db	 02h, 00h,0C0h, 00h, 80h, 00h
		db	0F0h, 00h,0A0h, 00h,0F0h, 00h
		db	 80h, 00h, 03h, 00h, 02h, 39h
		db	 08h, 03h, 00h, 02h,0DBh, 00h
		db	 91h, 00h, 39h, 0Fh, 1Fh, 39h
		db	 01h
data_14		dw	39FDh			; Data table (indexed access)
		db	 00h, 03h,0FEh, 39h, 00h, 06h
		db	0F8h, 39h, 00h, 0Dh,0E8h, 00h
		db	 05h, 39h, 0Ah,0D0h, 39h, 01h
		db	 52h, 39h, 01h, 8Ah, 40h, 39h
		db	 01h, 20h, 39h, 01h, 10h,0A0h
		db	 00h, 0Dh, 90h, 00h, 03h, 0Dh
		db	 40h, 00h, 05h, 06h, 40h, 39h
		db	 00h, 03h, 39h, 02h,0A0h, 39h
		db	 01h, 15h, 39h, 09h, 10h,0C0h
		db	 39h, 00h, 10h,0A0h, 39h, 00h
		db	 20h, 39h, 01h, 40h, 39h, 00h
		db	 02h, 39h, 01h, 50h, 39h, 16h
		db	 1Fh, 39h, 01h,0FDh, 39h, 00h
		db	 03h,0FEh, 39h, 00h, 06h,0F8h
		db	 00h, 05h, 0Dh,0E8h, 00h, 13h
		db	 39h, 0Ah,0D0h, 39h, 01h, 52h
		db	 39h, 01h, 8Ah, 40h, 39h, 01h
		db	 20h, 50h, 39h, 00h, 10h,0A8h
		db	 00h, 0Dh, 90h, 00h, 2Fh, 0Dh
		db	 40h, 00h, 17h, 06h, 40h, 00h
		db	 0Ah, 03h, 39h, 02h,0A0h, 39h
		db	 01h, 15h, 39h, 09h, 10h,0D0h
		db	 39h, 00h, 10h,0A8h, 39h, 00h
		db	 20h, 40h, 39h, 00h, 40h, 39h
		db	 00h, 02h, 39h, 01h, 50h, 39h
		db	 16h, 1Fh, 39h, 01h,0FDh, 39h
		db	 00h, 03h,0FEh, 00h, 01h, 06h
		db	0F8h, 00h, 07h, 0Dh,0E9h, 00h
		db	 16h, 39h, 0Ah,0D0h, 39h, 01h
		db	 52h, 39h, 01h, 8Ah, 40h, 20h
		db	 39h, 00h, 20h,0F5h, 00h, 40h
		db	 10h,0BAh, 00h, 0Dh, 92h, 00h
		db	 2Dh, 0Dh, 45h, 00h, 3Ah, 06h
		db	 40h, 00h, 1Fh, 03h, 39h, 00h
		db	 0Ah, 00h,0A0h, 39h, 01h, 15h
		db	 39h, 08h, 80h, 10h, 7Dh, 00h
		db	 40h, 10h,0BAh, 39h, 00h, 20h
		db	0D4h, 39h, 00h, 40h,0A0h, 00h
		db	 02h, 39h, 01h, 50h, 39h, 0Ch
		db	 32h, 39h, 01h, 08h, 00h, 03h
		db	 00h, 03h, 00h, 08h, 00h, 06h
		db	 39h, 01h, 0Fh, 00h, 20h, 00h
		db	 1Fh, 00h, 20h, 00h, 1Fh, 39h
		db	 01h, 3Fh, 39h, 00h, 32h, 00h
		db	0C0h, 00h,0C8h, 00h,0A0h, 00h
		db	0A0h, 00h, 80h, 00h,0ACh, 39h
		db	 01h,0B8h, 39h, 01h,0BAh, 39h
		db	 01h,0AAh, 39h, 01h,0EAh, 39h
		db	 02h, 3Fh, 39h, 01h, 0Ah, 00h
		db	 03h, 00h, 03h, 00h, 02h, 00h
		db	 02h, 00h, 0Fh, 00h, 0Fh, 00h
		db	 0Ch, 00h, 0Ch, 39h, 08h,0AAh
		db	 00h,0C0h, 00h,0E8h, 00h,0B0h
		db	 00h,0B0h, 00h,0D0h, 00h,0D0h
		db	 00h,0BCh, 00h,0BCh, 00h, 0Ch
		db	 00h, 0Ch, 39h, 22h, 03h, 00h
		db	 08h, 00h, 07h, 39h, 0Ch, 03h
		db	 39h, 01h, 03h,0C0h, 39h, 00h
		db	 3Ch, 30h, 8Eh, 00h, 7Eh, 3Ch
		db	 02h, 00h,0EEh, 80h, 39h, 01h
		db	 3Fh, 39h, 01h, 3Eh, 39h, 01h
		db	 3Ah, 00h,0FCh, 00h,0FEh, 0Eh
		db	0ECh, 0Eh,0EEh, 08h,0B8h, 08h
		db	0B8h, 00h, 20h, 00h, 20h, 00h
		db	0E0h, 00h,0E0h, 39h, 00h,0BAh
		db	 80h, 39h, 00h,0EAh, 39h, 01h
		db	0AAh, 39h, 01h,0A8h, 39h, 01h
		db	0A0h, 39h, 20h, 08h, 00h, 07h
		db	 00h, 80h, 00h, 7Fh, 39h, 00h
		db	 03h,0EAh, 39h, 14h,0F0h, 30h
		db	 39h, 00h,0A8h,0C0h, 39h, 00h
		db	0AAh, 30h, 00h, 0Ah, 03h,0AAh
		db	 00h, 2Ah, 00h,0AAh, 30h,0ABh
		db	 30h,0ABh, 0Fh, 38h, 0Ch, 3Bh
		db	 02h, 20h, 02h, 2Eh, 3Ah,0A0h
		db	 3Ah,0AAh, 39h, 06h,0A0h, 00h
		db	0A2h, 00h,0A8h, 00h,0A8h,0F0h
		db	0A8h, 00h,0ABh, 39h, 01h,0FAh
		db	 39h, 01h,0A8h, 39h, 01h, 80h
		db	 39h, 0Fh, 0Ch, 30h, 0Ch, 30h
		db	 0Ch,0C0h, 0Ch,0C3h, 0Fh, 00h
		db	 2Ch, 00h, 0Ch, 20h, 3Ch, 22h
		db	 0Eh,0E8h, 3Eh,0EAh, 00h,0AEh
		db	 28h,0AEh, 39h, 0Ch,0E0h, 39h
		db	 01h,0BEh, 39h, 01h,0AFh, 80h
data_15		dw	39h			; Data table (indexed access)
		db	0AAh,0E0h, 39h, 00h,0A0h, 30h
		db	 00h,0BBh, 08h,0BBh, 00h, 2Ah
		db	 00h, 2Ah, 39h, 01h, 3Ah, 39h
		db	 00h, 0Ch,0E3h, 39h, 00h, 03h
		db	 0Ch, 39h, 01h, 82h, 39h, 06h
		db	 80h, 00h, 80h, 30h,0E0h, 00h
		db	0E0h, 00h,0AAh, 00h,0AAh, 39h
		db	 01h, 80h, 39h, 13h, 40h, 39h
		db	 00h

locloop_4:
		add	ds:data_28e[bx+si],ax
		add	al,ds:data_21e[bx+si]
;*		add	bx,ax
				db	001h,0C3h	; add bx,ax (alt encoding)
;*		add	bl,ch
				db	000h,0EBh	; add bl,ch (alt encoding)
		push	cs
		int	3			; Debug breakpoint
;*		add	dh,ch
				db	000h,0EEh	; add dh,ch (alt encoding)
		add	ax,0F0h
		retn
			                        ; (data -- Sourcer: no entry point)
		xor	ax,0C2h
		retn	0ACAh
		db	 00h, 15h,0EAh, 80h, 00h, 75h
		db	 50h, 39h, 00h,0AAh, 80h, 39h
		db	 00h, 54h, 39h, 01h, 08h, 39h
		db	 05h, 40h, 39h, 03h,0EEh, 80h
		db	0EEh,0ABh, 0Ah,0E0h, 0Ah,0E0h
		db	 0Bh,0B8h, 0Bh,0B8h, 02h,0AEh
		db	 02h,0AEh, 00h, 0Ah, 03h,0AAh
		db	 39h, 00h,0CEh, 38h, 39h, 00h
		db	 30h,0C0h, 39h, 00h, 08h, 20h
		db	 39h, 0Ah, 0Ch, 00h, 0Ch, 00h
		db	0A0h, 00h,0A0h, 39h, 17h, 0Ch
		db	 30h, 0Ch, 30h, 0Ch,0C0h, 0Ch
		db	0C0h, 0Fh, 00h, 0Ch, 02h, 0Ch
		db	 20h, 0Ch, 2Bh, 0Eh,0E8h, 2Eh
		db	0EAh, 39h, 14h,0A8h, 39h, 01h
		db	0AAh, 39h, 01h,0EAh, 80h, 00h
		db	0AEh, 2Eh,0AEh, 00h, 33h, 3Ah
		db	0FFh, 00h, 22h, 20h,0EEh, 39h
		db	 00h, 83h,0AEh, 39h, 00h, 03h
		db	 0Ch, 39h, 0Ch,0BEh,0A0h, 80h
		db	 00h, 83h,0A0h,0E0h, 00h,0E0h
		db	0E0h,0AAh, 00h,0AAh, 28h, 39h
		db	 0Fh,0C3h, 00h,0C3h, 00h,0CCh
		db	 00h,0CCh, 00h,0F0h, 00h,0C0h
		db	 00h,0C2h
data_16		db	0
		db	0C2h, 00h,0EEh, 00h,0EEh, 00h
		db	 08h, 02h, 8Bh, 39h, 00h, 06h
		db	 8Fh, 08h, 10h, 02h, 2Fh, 39h
		db	 0Ch,0C0h, 39h, 01h,0E0h, 39h
		db	 01h,0F0h, 00h, 08h, 00h,0B8h
		db	 00h, 0Eh, 00h, 5Eh, 39h, 00h
		db	 40h, 1Ah,0BAh, 39h, 00h, 1Ah
		db	0F5h, 39h, 00h, 28h,0E8h, 39h
		db	 00h, 2Bh,0D0h, 39h, 00h, 2Bh
		db	0C0h, 39h, 00h, 23h, 39h, 01h
		db	 0Ch, 39h, 03h, 0Ah, 80h,0AAh
		db	 80h, 00h, 20h, 38h, 20h, 00h
		; Graphics data table
		db	' 8 ', 0		; 0x0001
		db	'`', 0		; 0x0005
		db	'`9', 0		; 0x0007
		db	 39h, 1Eh,0C0h, 39h, 00h, 03h
		db	0C0h, 39h, 00h, 0Ch, 3Ch, 00h
		db	0E0h, 3Ch,0EFh, 00h, 80h, 03h
		db	0BAh, 39h, 18h, 80h, 39h, 01h
		db	0A0h, 39h, 01h, 03h,0AEh, 39h
		db	 01h,0EBh, 39h, 01h,0EAh, 39h
		db	 01h, 3Ah, 39h, 01h, 0Ah, 39h
		db	 0Ch,0A8h, 39h, 01h,0A8h, 39h
		db	 01h,0A8h, 00h, 3Fh, 00h,0BFh
		db	 00h, 3Bh,0B0h,0BBh,0B0h, 2Eh
		db	 20h, 2Eh, 20h, 08h, 00h, 08h
		db	 00h, 0Bh, 00h, 0Bh, 39h, 14h
		db	 08h, 0Ch, 07h, 00h, 20h, 03h
		db	 1Eh, 39h, 00h, 0Ch,0FAh, 39h
		db	 14h,0F0h, 39h, 01h,0AAh
		db	39h
loc_6:
		add	ss:data_10[bp+si],bp
		or	al,[bx+si]
		retf	2A00h
			                        ; (data -- Sourcer: no entry point)
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		sub	al,[bx+si]
		or	al,[bx+si]
		cli				; Disable interrupts
		cmp	[bx+di],ax
		scasw				; Scan es:[di] for ax
		cmp	[bx+di],ax
		sub	bh,[bx+di]
		add	[bp+si],ax
		cmp	data_10,ax
		stosb				; Store al to es:[di]
		sub	byte ptr ds:data_38e[bx+si],0
;*		jmp	far ptr loc_2		;*
		db	0EAh, 008h, 0EAh, 008h, 023h	; jmp far 2308:EA08
			                        ; (data -- Sourcer: no entry point)
		mov	al,ds:data_34e
		and	ds:data_32e[bx+si],al
		or	ch,ds:data_37e[bx+si]
		cmp	[bp+di],dx
		or	[bx+si],al
		pop	es
		add	ds:data_31e[bx+si],al
		cmp	[bx+si],ax
		add	di,dx
		or	[bx+si],al
		pop	es
		stosb				; Store al to es:[di]
		cmp	[bx+si],ax
		or	al,0Ah
		cmp	ds:data_23e,ax
		or	al,30h			; '0'
		add	si,[bx+si]
		retn
			                        ; (data -- Sourcer: no entry point)
		xor	[bp+di],al
		xor	[bx+si],al
		cmp	al,8
		xor	ds:data_22e[bx+si],cl
		mov	al,0ABh
		mov	ax,0BAh
		mov	dx,28h
		add	cl,[si]
		add	al,[bx+si]
		or	ax,[bx+si]
		or	ax,[bx+si]
;*		jmp	far ptr loc_1		;*
		db	0EAh, 000h, 0EAh, 039h, 001h	; jmp far 0139:EA00
			                        ; (data -- Sourcer: no entry point)
		add	bh,[bx+di]
		push	cs
		out	dx,al			; port 28h ??I/O Non-standard
;*		add	dh,ch
				db	000h,0EEh	; add dh,ch (alt encoding)
		and	ds:data_36e[bx+si],ch
		cmp	[bx+di],ax
		lodsb				; String [si] to al
		cmp	[bx+di],ax
		retf
			                        ; (data -- Sourcer: no entry point)
		xor	[bx+di],bh
		add	[bx+si],dh
		db	0C0h, 39h, 00h, 82h, 39h, 07h
		db	 26h, 40h,0D9h,0B8h, 39h, 00h
		db	 0Ah,0AFh, 39h, 00h, 01h, 55h
		db	 39h, 01h, 2Ah, 39h, 01h, 10h
		db	 39h, 05h, 02h, 39h, 07h, 02h
		db	 80h, 39h, 00h, 01h, 40h, 0Eh
		db	 00h, 01h,0A0h, 1Ch, 00h,0C3h
		db	 70h,0D7h, 00h, 33h,0A0h, 77h
		db	 00h, 33h,0ACh,0C3h, 00h, 43h
		db	 53h, 43h, 39h, 0Bh, 30h, 00h
		db	 30h, 00h, 05h, 00h, 05h, 39h
		db	 0Ah, 01h, 77h,0D5h, 77h, 07h
		db	 50h, 07h, 50h, 1Dh,0D0h, 1Dh
		db	0D0h, 75h, 40h, 75h, 40h, 50h
		db	 00h, 55h,0C0h, 39h, 00h, 1Ch
		db	 73h, 39h, 00h, 03h, 0Ch, 39h
		db	 00h, 04h, 10h, 39h, 15h, 3Eh
		db	 39h, 01h,0EAh, 39h, 00h, 03h
		db	0AFh, 39h, 0Ah, 0Ch, 30h, 0Ch
		db	 30h, 03h, 30h, 03h, 30h, 03h
		db	 30h, 80h, 30h, 08h, 30h,0E8h
		db	 30h, 2Bh,0B0h,0ABh,0BCh, 39h
		db	 00h, 0Eh,0BAh, 00h, 02h, 0Eh
		db	 82h, 00h, 0Bh, 0Ah, 0Bh, 00h
		db	0EAh, 38h,0EAh, 39h, 0Eh,0BAh
		db	 00h,0BAh,0ACh,0CCh, 00h,0FFh
		db	0A8h, 88h, 00h,0BBh, 08h, 39h
		db	 00h,0BAh,0C2h, 39h, 00h, 30h
		db	0C0h, 39h, 17h, 01h, 00h, 02h
		db	 00h, 04h, 00h, 0Bh, 39h, 01h
		db	 0Fh, 00h, 30h, 00h, 1Dh, 00h
		db	0F0h, 00h, 7Ah,0C3h, 00h,0C3h
		db	 00h, 33h, 00h, 33h, 00h, 33h
		db	 00h, 03h, 00h, 43h, 00h
		db	43h

locloop_7:
;*		add	[bx+0],dh
				db	000h,077h,000h	; add [bx+0h],dh (alt encoding)
		db	 77h, 00h, 10h, 00h,0D1h, 40h
		db	 39h, 00h,0F1h
		db	 20h, 39h
loc_8:
;*		add	ah,bh
				db	000h,0FCh	; add ah,bh (alt encoding)
		push	ax
		add	dx,ax
		add	dx,bp
		add	al,0
		add	al,1Ch
		push	es
		add	ds:data_24e,al
		add	[si],ax
		cmp	[bx+si],dx
		pop	di
		push	ax
		cmp	[bx+si],ax
		scasw				; Scan es:[di] for ax
		dec	ax
		cmp	[bx+si],ax
		pop	ss
		xchg	sp,ax
		cmp	[bx+si],ax
		or	dx,sp
		cmp	[bx+si],ax
		add	dx,sp
		cmp	[bx+di],ax
		les	di,dword ptr [bx+di]	; Load seg:offset ptr
		add	[bx+si],si
		cmp	data_11,ax
		sbb	[bx+si],bl
		add	al,[bx+si]
		sub	ch,[bx+si]
		add	cl,[bx+si]
		add	cl,[bx+si]
;*		add	ah,cl
				db	000h,0CCh	; add ah,cl (alt encoding)
;*		add	ah,cl
				db	000h,0CCh	; add ah,cl (alt encoding)
		add	ds:data_29e[bx+si],ch
		add	bp,ss:data_6e[bp+si]
		push	cs
		mov	ds:data_30e,al
		sbb	data_13[bx+si],bp
		mov	cl,54h			; 'T'
		mov	sp,200h
		stosb				; Store al to es:[di]
		call	$-53FDh
;*		adc	bh,bh
				db	010h,0FFh	; adc bh,bh (alt encoding)
		inc	bp
		adc	[bx+si],cl
		jnp	loc_8			; Jump if not parity
		lds	ax,dword ptr [bx+si]	; Load seg:offset ptr
		loopnz	locloop_7		; Loop if zf=0, cx>0

		pop	word ptr [bx+si+60h]
		sbb	[bp+si],cl
		mov	al,ds:data_1e
		add	ch,byte ptr ds:[5702h][bx+si]
		add	ah,ds:data_2e[bx+si]
		push	cs
		mov	[di],al
		jbe	$+3Ch			; Jump if below or =
		mov	al,ds:data_4e
		cmp	ch,ss:data_7e[bp+si]
		cmp	ch,ss:data_7e[bp+si]
		db	 3Eh,0AAh, 15h, 55h, 0Fh,0FAh
		db	 05h,0FAh, 39h, 08h,0C0h, 00h
		db	 80h, 00h, 70h, 00h, 08h, 00h
		db	0B0h, 00h, 63h, 00h, 7Ah, 00h
		db	0A8h, 08h, 02h,0A0h, 9Eh, 00h
		db	0A2h,0A2h, 39h, 06h, 63h, 00h
		db	 60h, 60h, 0Ah, 08h,0AAh,0A8h
		db	 00h,0CCh, 00h,0CCh, 00h,0A8h
		db	 00h, 54h, 03h,0AAh, 00h, 55h
		db	 0Eh,0A2h, 01h, 5Dh, 02h,0A8h
		db	 02h, 57h, 0Ah,0A0h, 05h, 5Bh
		db	 3Ah, 88h, 15h, 76h,0EAh,0A2h
		db	 55h, 5Dh,0EAh,0A8h, 55h, 57h
		db	0EAh,0AAh, 55h, 55h,0FAh,0AAh
		db	 55h, 55h, 3Fh,0EAh, 17h,0EAh
		db	 39h, 08h,0C0h, 39h, 01h,0C0h
		db	 00h, 28h, 00h, 80h, 00h, 02h
		db	 00h,0F8h, 00h,0A0h, 20h, 0Ah
		db	 80h,0AAh,0A8h, 8Ah, 39h, 08h
		db	 80h, 00h, 60h, 00h, 02h, 00h
		db	0A2h, 00h,0CCh, 00h,0CCh, 00h
		db	0A8h, 00h, 54h, 03h,0AAh, 00h
		db	 55h, 0Eh,0A2h, 01h, 5Dh, 39h
		db	 06h, 80h, 00h, 60h, 39h, 01h
		db	0A0h, 39h, 13h, 4Eh, 00h, 01h
		db	 81h, 39h, 00h, 02h, 82h, 00h
		db	 82h, 00h, 82h, 03h, 0Ch, 03h
		db	 0Ch, 02h,0A0h, 01h, 50h, 0Eh
		db	0A8h, 01h, 54h, 3Ah, 88h, 05h
		db	 76h, 39h, 04h, 80h, 39h, 01h
		db	 80h, 39h, 13h, 02h,0A0h, 01h
		db	 5Eh, 0Ah, 88h, 09h, 67h, 0Eh
		db	 88h, 05h, 76h, 0Eh,0A0h, 05h
		db	 5Eh, 0Eh,0AAh, 05h, 55h, 0Eh
		db	0AAh, 05h, 55h, 0Fh,0AAh, 05h
		db	 55h, 03h,0FEh, 01h, 7Eh, 39h
		db	 08h,0C0h, 00h, 80h, 00h, 70h
		db	 00h, 08h, 00h,0B0h, 00h, 63h
		db	 00h, 7Ah, 00h,0A8h, 08h, 02h
		db	0A0h, 9Eh, 00h,0A8h,0A2h, 00h
		db	 07h, 4Ah,0CFh, 00h,0C4h, 23h
		db	0F7h, 0Ch, 1Bh, 03h,0DFh, 1Ah
		db	 9Dh,0E0h, 0Fh, 02h, 8Dh,0E0h
		db	 1Ah, 35h, 04h, 39h, 00h, 2Ah
		db	0C9h, 40h, 20h, 10h, 94h,0E0h
		db	 61h, 39h, 02h, 91h, 00h, 18h
		db	 18h, 00h, 80h, 28h,0A8h, 20h
		db	 80h, 20h, 80h, 33h, 00h, 33h
		db	 00h, 2Ah, 00h, 15h, 00h,0AAh
		db	 80h, 55h, 40h, 8Ah,0A0h, 75h
		db	 50h, 39h, 09h, 03h, 00h, 02h
		db	 00h, 0Dh, 00h, 20h, 00h, 1Eh
		db	 4Eh, 00h, 01h,0ADh, 20h, 2Ah
		db	 1Ah, 80h,0EAh,0AAh, 4Ah, 8Ah
		db	 2Ah, 80h,0D5h, 80h, 0Ah, 80h
		db	0E4h, 00h, 22h,0A0h, 9Dh, 20h
		db	 0Ah,0A8h,0B5h, 08h,0AAh,0A8h
		db	 54h, 08h,0AAh,0A8h, 40h, 08h
		db	0AAh,0A8h, 00h, 28h,0AAh,0A0h
		db	0AAh,0A0h, 39h, 06h, 9Fh, 00h
		db	 06h, 06h, 20h,0A0h, 2Ah,0AAh
		db	 33h, 00h, 33h, 00h, 2Ah, 00h
		db	 15h, 00h,0AAh, 80h, 55h, 40h
		db	 8Ah,0A0h
		db	 75h, 50h, 39h, 09h
data_18		db	3
		db	 39h, 01h, 03h, 00h, 28h, 00h
		db	 16h, 00h, 80h, 00h, 6Fh, 08h
		db	 0Ah, 06h,0A0h, 2Ah,0AAh, 10h
		db	0A2h, 2Ah, 80h,0D4h, 80h, 0Ah
		db	0A0h,0E4h, 00h, 22h,0A8h, 9Dh
		db	 08h, 8Ah,0AAh, 75h, 02h, 2Ah
		db	0AAh,0D4h, 02h, 9Eh, 00h, 50h
		db	 02h, 9Eh, 00h, 00h, 0Ah,0AAh
		db	0A8h,0AAh,0A8h, 39h, 07h, 08h
		db	 00h, 06h, 39h, 01h, 0Ah, 39h
		db	 16h, 08h, 00h, 06h, 00h, 80h
		db	 00h, 8Ah, 00h, 33h, 00h, 33h
		db	 00h, 2Ah, 00h, 15h, 00h,0AAh
		db	 80h, 55h, 40h, 8Ah,0A0h, 75h
		db	 50h, 39h, 03h, 02h, 00h, 01h
		db	 39h, 01h, 02h, 39h, 16h, 02h
		db	 00h, 81h, 80h, 39h, 00h, 82h
		db	 80h, 82h, 00h, 82h, 00h, 30h
		db	0C0h, 30h,0C0h, 0Ah, 80h, 05h
		db	 40h, 2Ah,0A0h, 15h, 50h, 22h
		db	0A8h, 5Dh, 54h, 39h, 09h, 03h
		db	 00h, 02h, 00h, 0Dh, 00h, 20h
		db	 00h, 1Eh, 4Eh, 00h, 01h,0ADh
		db	 20h, 2Ah, 1Ah, 80h,0EAh,0AAh
		db	 4Ah, 2Ah, 0Ah, 80h,0B5h, 00h
		db	 22h,0A0h,0D9h, 20h, 22h,0A0h
		db	 9Dh, 20h, 0Ah,0A0h,0B5h, 20h
		db	0AAh,0A0h, 54h, 20h,0AAh,0A0h
		db	 40h, 20h,0AAh,0A0h, 00h,0A0h
		db	0AAh, 80h,0AAh, 80h, 39h, 07h
		db	 06h, 00h, 09h, 00h, 20h, 00h
		db	 50h, 01h, 39h, 00h, 80h, 39h
		db	 02h, 01h, 20h, 39h, 00h, 02h
		db	 70h, 00h, 30h, 39h, 06h, 80h
		db	 00h, 70h, 00h, 04h, 00h, 0Bh
		db	 39h, 00h, 80h, 00h, 40h, 39h
		db	 01h, 30h, 00h, 10h, 00h, 08h
		db	 7Dh, 08h, 3Ch,0C5h, 00h,0D3h
		db	 00h, 50h, 1Dh, 55h, 39h, 00h
		db	 29h, 82h, 02h, 40h, 55h, 05h
		db	 02h,0C0h, 28h, 08h, 00h, 80h
		db	 01h, 54h, 39h, 01h, 18h, 00h
		db	 02h, 39h, 01h, 03h,0AAh,0A0h
		db	 0Ah, 06h, 55h, 50h, 05h, 03h
		db	0ABh,0A8h, 08h, 03h, 45h, 54h
		db	 00h, 02h, 8Eh,0A8h, 00h, 02h
		db	 05h, 40h, 39h, 00h, 1Ah, 39h
		db	 03h, 68h, 39h, 08h, 36h, 00h
		db	 49h, 39h, 06h, 01h, 20h, 39h
		db	 00h, 02h, 70h, 00h, 30h, 04h
		db	0D0h, 00h, 50h, 39h, 06h, 40h
		db	 00h,0A0h, 00h, 08h, 00h, 16h
		db	 00h, 01h, 00h, 02h, 80h, 39h
		db	 01h, 60h, 00h, 20h, 00h, 10h
		db	 7Dh, 00h, 1Ch, 08h, 1Dh, 55h
		db	 39h, 00h, 29h, 82h, 02h, 40h
		db	 55h, 05h, 02h,0C0h, 28h, 38h
		db	 00h, 80h, 00h,0D0h, 00h, 06h
		db	 00h, 20h, 00h, 08h, 39h, 06h
		db	0AAh,0A8h, 0Ah, 04h, 55h, 50h
		db	 05h, 06h,0ABh,0A8h, 08h, 02h
		db	 47h, 54h, 00h, 02h, 86h,0A8h
		db	 39h, 00h, 01h, 40h, 39h, 01h
		db	0A0h, 39h, 02h, 01h,0A0h, 39h
		db	 01h, 08h, 00h, 04h, 00h, 02h
		db	 00h, 01h, 39h, 04h, 01h, 20h
		db	 39h, 00h, 02h, 70h, 00h, 30h
		db	 04h,0D0h, 00h, 50h, 1Dh, 55h
		db	 39h, 0Ah,0C0h, 00h, 30h, 00h
		db	 08h, 00h, 06h, 00h, 01h, 80h
		db	 00h, 40h, 00h, 30h,0FDh, 10h
		db	 1Ch, 0Ch,0AAh,0A0h, 0Ah, 06h
		db	 29h, 82h, 02h, 40h, 55h, 05h
		db	 02h,0C0h, 28h, 0Ah, 00h, 80h
		db	 05h, 54h,0D0h, 39h, 0Fh, 55h
		db	 50h, 05h, 06h,0AAh,0A8h, 0Ah
		db	 03h, 1Dh, 54h, 04h, 02h, 3Ah
		db	0A8h, 39h, 00h, 1Dh, 50h, 39h
		db	 00h, 02h,0A8h, 00h, 02h, 39h
		db	 01h, 05h, 39h, 03h, 40h, 39h
		db	 01h, 20h, 00h, 10h, 00h, 0Ch
		db	 00h, 03h, 39h, 06h, 01h, 20h
		db	 39h, 00h, 02h, 70h, 00h, 30h
		db	 04h,0D3h, 00h, 50h, 39h, 0Ah
		db	 64h, 00h, 9Bh,0C0h, 00h, 10h
		db	 00h, 68h, 3Dh, 08h, 0Ch, 04h
		db	0EAh,0A0h, 0Ah, 06h, 55h, 50h
		db	 05h, 02h, 39h, 0Fh, 30h, 00h
		db	 10h, 02h, 3Ch, 01h,0B4h, 00h
		db	 2Eh, 02h, 2Eh, 3Ch, 2Ah, 1Ch
		db	 2Ah, 39h, 1Ah,0F0h, 00h,0D0h
		db	 00h,0FFh,0EFh, 7Fh,0EFh,0FFh
		db	0BAh, 04h,0BAh,0FFh,0EBh, 11h
		db	 2Bh, 3Fh,0FBh, 04h, 59h, 3Fh
		db	0FBh, 15h, 79h, 03h,0EBh, 01h
		db	 69h, 00h,0EAh, 00h,0EAh, 03h
		db	0ABh, 03h,0A9h,0AFh, 00h,0ADh
		db	 00h,0FAh,0C0h
		db	0FAh,0C0h
		db	0FFh,0B0h, 5Fh, 90h,0EBh,0F8h
		db	0EBh,0F8h,0EEh,0E8h,0EEh,0E8h
		db	0FBh,0AAh,0FBh,0AAh,0EAh,0A8h
		db	 6Ah,0A8h,0EAh, 80h,0EAh, 80h
		db	0FFh,0EFh, 7Fh,0EFh,0FFh,0BAh
		db	 04h,0BAh, 3Fh,0EBh, 11h, 2Bh
		db	 03h,0FBh, 00h, 59h, 00h,0FBh
		db	 00h, 79h, 00h, 2Bh, 00h, 29h
		db	 00h,0EAh, 00h,0EAh, 03h,0ABh
		db	 03h,0A9h, 00h, 30h, 00h, 10h
		db	 02h, 3Ch, 01h,0B4h, 00h, 2Eh
		db	 02h, 2Eh, 3Ch, 2Ah, 1Ch, 2Ah
		db	0FFh,0EFh, 7Fh,0EDh, 00h, 03h
		db	 02h,0ABh, 00h, 0Fh, 03h,0A3h
		db	0C0h, 3Eh,0C2h, 82h, 39h, 06h
		db	0C0h, 00h,0C0h, 00h,0FFh, 00h
		db	0DFh, 00h,0ABh,0C0h,0A9h,0C0h
		db	0FAh,0B0h,0FAh,0B0h,0AFh,0A8h
		db	0AFh,0A8h,0FAh,0EAh,0FAh,0EAh
		db	 3Fh,0FBh, 3Fh,0CBh,0CFh,0A0h
		db	0CFh,0A0h, 39h, 16h,0FFh,0BAh
		db	 55h,0BAh,0FFh,0FAh, 55h,0DAh
		db	 0Fh,0F8h, 05h, 78h, 00h,0E8h
		db	 00h,0E8h, 00h,0E0h, 00h,0E0h
		db	 00h,0B0h, 00h,0B0h, 00h, 2Ah
		db	 00h, 2Ah, 00h, 08h, 00h, 08h
		db	 00h, 30h, 00h, 10h, 02h, 3Ch
		db	 01h,0B4h, 00h, 2Eh, 02h, 2Eh
		db	 3Ch, 2Ah, 1Ch, 2Ah,0FFh,0EFh
		db	 7Fh,0EDh, 00h, 03h, 02h,0ABh
		db	 00h, 0Fh, 03h,0A3h, 00h, 3Eh
		db	 02h, 82h, 00h,0FAh, 0Fh, 0Ah
		db	 03h, 3Eh, 0Ch, 3Eh, 03h,0FCh
		db	 03h, 7Ch, 3Fh, 80h, 1Fh, 80h
		db	 0Eh, 00h, 0Eh, 39h, 0Bh,0EEh
		db	0FAh, 66h, 7Ah,0FFh,0EAh, 55h
		db	 6Ah, 03h,0E8h, 03h,0E8h, 0Fh
		db	0A0h, 0Fh,0A0h, 3Eh, 00h, 3Eh
		db	 00h, 38h, 00h, 38h, 00h, 0Eh
		db	 00h, 0Eh, 00h, 08h, 00h, 08h
		db	 39h, 04h, 30h, 00h, 10h, 02h
		db	 3Ch, 01h,0B4h, 00h, 2Eh, 02h
		db	 2Eh, 3Ch, 2Ah, 1Ch, 2Ah,0FFh
		db	0EFh, 7Fh,0EDh, 00h, 03h, 02h
		db	0ABh, 00h, 0Fh, 03h,0A3h, 39h
		db	 0Ah,0C0h, 00h,0C0h, 00h,0FFh
		db	 00h,0DFh, 00h,0ABh,0C0h,0A9h
		db	0C0h,0FAh,0B0h,0FAh,0B0h,0AFh
		db	0A8h,0AFh,0A8h, 00h, 3Eh, 02h
		db	 82h, 00h,0FAh, 0Fh, 0Ah, 03h
		db	 0Eh, 0Ch, 0Eh, 00h,0FAh, 00h
		db	 7Ah, 03h,0A8h, 03h,0A8h, 0Eh
		db	 83h, 0Eh, 83h, 08h, 80h, 08h
		db	 80h, 39h, 02h,0AAh,0FAh,0AAh
		db	0DAh,0EEh,0FAh, 62h, 7Ah,0FFh
		db	0EAh, 05h,0EAh, 32h,0A8h, 32h
		db	0A8h,0EAh, 80h, 6Ah, 80h, 20h
		db	 00h, 20h, 39h, 10h, 30h, 00h
		db	 10h, 02h, 3Ch, 01h,0B4h, 00h
		db	 2Eh, 02h, 2Eh, 3Ch, 2Ah, 1Ch
		db	 2Ah,0FFh,0EFh, 7Fh,0EDh, 00h
		db	 03h, 02h,0ABh, 39h, 0Eh,0C0h
		db	 00h,0C0h, 00h,0FFh, 00h,0DFh
		db	 00h,0ABh,0C0h,0A9h,0C0h,0FAh
		db	0B0h,0FAh,0B0h, 00h, 3Fh, 03h
		db	 83h, 03h,0FEh, 00h, 02h, 3Fh
		db	0FAh, 00h, 0Ah, 03h, 2Eh, 00h
		db	 2Eh, 00h, 3Ah, 00h, 3Ah, 00h
		db	0E8h, 00h,0E8h, 02h,0A0h, 02h
		db	0A0h, 08h, 80h, 08h, 80h,0AFh
		db	0A8h,0AFh,0A8h,0AAh,0FAh,0AAh
		db	0DAh,0EFh,0AAh, 25h,0AAh,0BFh
		db	0AAh, 83h,0AAh, 0Ch,0A8h, 04h
		db	0A8h, 0Eh, 80h, 0Eh, 80h, 3Ah
		db	 00h, 3Ah, 00h,0A0h, 00h,0A0h
		db	 39h, 0Ch, 30h, 00h, 10h, 02h
		db	 3Ch, 01h,0B4h, 00h, 2Eh, 02h
		db	 2Eh, 3Ch, 2Ah, 1Ch, 2Ah,0FFh
		db	0EFh, 7Fh,0EDh, 39h, 12h,0C0h
		db	 00h,0C0h, 00h,0FFh, 00h,0DFh
		db	 00h,0ABh,0C0h,0A9h,0C0h, 00h
		db	 9Ch, 00h,0ABh, 00h,0FFh, 3Ah
		db	 07h,0FFh,0FEh, 01h, 12h, 0Fh
		db	0FFh, 04h, 44h, 00h, 3Eh, 00h
		db	 16h, 00h, 0Eh, 00h, 0Eh, 00h
		db	0EAh, 00h,0EAh, 02h, 88h, 02h
		db	 88h,0FAh,0B0h,0FAh,0B0h,0AFh
		db	0A8h,0AFh,0A8h,0AAh,0FEh,0AAh
		db	0DEh,0EBh,0EAh,0E9h,0EAh,0BFh
		db	0AAh, 97h,0AAh, 8Eh,0A8h, 8Eh
		db	0A8h, 0Fh,0A0h, 0Fh,0A0h,0EAh
		db	 80h,0EAh, 80h, 39h, 1Bh, 0Fh
		db	 00h, 07h, 39h, 0Eh, 0Ch, 00h
		db	 04h, 00h, 3Ch, 80h, 1Eh, 40h
		db	0B8h, 00h,0B8h, 80h,0A8h, 3Ch
		db	0A8h, 34h, 00h,0FAh, 00h, 7Ah
		db	 03h,0EFh, 01h,0EFh, 0Fh,0BFh
		db	 07h, 95h, 3Eh,0FBh, 1Eh, 5Bh
		db	 3Fh,0BBh, 1Fh,0BBh,0FAh,0EFh
		db	 7Ah,0EFh, 2Ah,0ABh, 2Ah,0A9h
		db	 02h,0ABh, 02h,0A9h,0FBh,0FFh
		db	0FBh,0FDh,0AEh,0FFh,0AEh, 10h
		db	0ABh,0FFh,0A8h, 45h,0EFh,0FCh
		db	 65h, 10h,0EFh,0FCh, 6Dh, 44h
		db	0EBh,0F0h, 69h, 50h,0ABh, 00h
		db	0ABh, 00h,0EAh,0C0h,0EAh,0C0h
		db	0FBh,0FFh,0FBh,0FDh,0AEh,0FFh
		db	0AEh, 10h,0ABh,0FCh,0A8h, 44h
		db	0EFh,0C0h, 65h, 00h,0EFh, 00h
		db	 6Dh, 00h,0E8h, 00h, 68h, 00h
		db	0ABh, 00h,0ABh, 00h,0EAh,0C0h
		db	0EAh,0C0h, 39h, 07h, 0Fh, 00h
		db	 0Fh, 00h,0FFh, 00h, 5Fh, 03h
		db	0FAh, 01h,0FAh, 0Fh,0AFh, 07h
		db	0AFh, 3Eh,0FAh, 1Eh,0FAh,0FBh
		db	0AFh, 7Bh,0AFh, 0Ch, 00h, 04h
		db	 00h, 3Ch, 80h, 1Eh, 40h,0B8h
		db	 00h,0B8h, 80h,0A8h, 3Ch,0A8h
		db	 34h,0FBh,0FFh, 7Bh,0FDh,0C0h
		db	 00h,0EAh, 80h,0F0h, 00h,0CAh
		db	0C0h,0BCh, 03h, 82h, 83h,0EEh
		db	0FDh, 6Eh,0D4h,0AFh,0FFh,0A7h
		db	 55h, 2Fh,0F0h, 2Dh, 50h, 2Bh
		db	 00h, 2Bh, 00h, 0Bh, 00h, 0Bh
		db	 00h, 0Eh, 00h, 0Eh, 00h,0E8h
		db	 00h,0E8h, 00h, 20h, 00h, 20h
		db	 00h,0EFh,0FCh,0E3h,0FCh, 0Ah
		db	0F3h, 0Ah,0F3h, 39h, 16h, 0Ch
		db	 00h, 04h, 00h, 3Ch, 80h, 1Eh
		db	 40h,0B8h, 00h,0B8h, 80h,0A8h
		db	 3Ch,0A8h, 34h,0FBh,0FFh, 7Bh
		db	0FDh,0C0h, 00h,0EAh, 80h,0F0h
		db	 00h,0CAh,0C0h,0BCh, 00h, 82h
		db	 80h,0EFh,0BBh,0EDh, 99h,0ABh
		db	0FFh,0A9h, 55h, 2Bh,0C0h, 2Bh
		db	0C0h, 0Ah,0F0h, 0Ah,0F0h, 00h
		db	0BCh, 00h,0BCh, 00h, 2Ch, 00h
		db	 2Ch, 00h,0F0h, 00h, 70h, 00h
		db	 20h, 00h, 20h,0AFh, 00h,0A0h
		db	0F0h,0BCh,0C0h,0BCh, 30h, 3Fh
		db	0C0h, 3Dh,0C0h, 02h,0FCh, 02h
		db	0F4h, 00h,0B0h, 00h,0B0h, 39h
		db	 17h, 0Fh, 00h, 07h, 00h,0FFh
		db	 00h, 7Fh, 03h,0EAh, 01h,0EAh
		db	 0Fh,0AFh, 07h,0AFh, 3Eh,0FAh
		db	 1Eh,0FAh, 39h, 02h, 0Ch, 00h
		db	 04h, 00h, 3Ch, 80h, 1Eh, 40h
		db	0B8h, 00h,0B8h, 80h,0A8h, 3Ch
		db	0A8h, 34h,0FBh,0FFh, 7Bh,0FDh
		db	0C0h, 00h,0EAh, 80h,0F0h, 00h
		db	0CAh,0C0h,0FBh,0AAh, 7Bh,0AAh
		db	0EFh,0BBh,0EDh, 89h,0ABh,0FFh
		db	0ABh, 50h, 2Ah, 8Ch, 2Ah, 8Ch
		db	 02h,0ABh, 02h,0A9h, 00h, 08h
		db	 00h, 08h, 39h, 06h,0BCh, 00h
		db	 82h, 80h,0AFh, 00h,0A0h,0F0h
		db	0B0h,0C0h,0B0h, 30h,0AFh, 00h
		db	0ADh, 00h, 2Ah,0C0h, 2Ah,0C0h
		db	0C2h,0B0h,0C2h,0B0h, 02h, 20h
		db	 02h, 20h, 39h, 13h, 0Fh, 00h
		db	 05h, 00h,0FFh, 00h, 7Fh, 03h
		db	0EAh, 01h,0EAh, 0Fh,0AFh, 07h
		db	0AFh, 39h, 06h, 0Ch, 00h, 04h
		db	 00h, 3Ch, 80h, 1Eh, 40h,0B8h
		db	 00h,0B8h, 80h,0A8h, 3Ch,0A8h
		db	 34h,0FBh,0FFh, 7Bh,0FDh,0C0h
		db	 00h,0EAh, 80h, 3Eh,0FAh, 1Eh
		db	0FAh,0FBh,0AAh, 7Bh,0AAh,0FAh
		db	0FBh, 7Ah, 58h,0AAh,0FEh,0AAh
		db	0C2h, 2Ah, 30h, 2Ah, 10h, 02h
		db	0B0h, 02h,0B0h, 00h,0ACh, 00h
		db	0ACh, 00h, 0Ah, 00h, 0Ah,0FCh
		db	 00h,0C2h,0C0h,0BFh,0C0h, 80h
		db	 00h,0AFh,0FCh,0A0h, 00h,0B8h
		db	0C0h,0B8h, 00h,0ACh, 00h,0ACh
		db	 00h, 2Bh, 00h, 2Bh, 00h, 0Ah
		db	 80h, 0Ah, 80h, 02h, 20h, 02h
		db	 20h, 39h, 13h, 03h, 00h, 03h
		db	 00h,0FFh, 00h, 77h, 03h,0EAh
		db	 01h,0EAh, 39h, 0Ah, 0Ch, 00h
		db	 04h, 00h, 3Ch, 80h, 1Eh, 40h
		db	0B8h, 00h,0B8h, 80h,0A8h, 3Ch
		db	0A8h, 34h,0FBh,0FFh, 7Bh,0FDh
		db	 0Fh,0AFh, 07h,0AFh, 3Eh,0FAh
		db	 1Eh,0FAh,0FBh,0AAh, 7Bh,0AAh
		db	0FBh,0EBh, 7Bh, 6Bh,0EAh,0FEh
		db	0EAh,0D6h, 3Ah,0B2h, 3Ah,0B2h
		db	 0Ah,0F0h, 0Ah,0F0h, 02h,0ABh
		db	 02h,0ABh,0C0h, 00h,0EAh,0C0h
		db	0FFh, 00h,0D0h,0ACh,0BFh,0FFh
		db	 84h, 40h,0FFh,0F0h, 11h, 10h
		db	0BCh, 00h, 94h, 00h,0B0h, 00h
		db	0B0h, 00h,0ABh, 00h,0ABh, 00h
		db	 22h, 80h, 22h, 80h, 39h, 03h
		db	 28h, 00h, 28h, 39h, 03h, 03h
		db	 00h, 0Bh, 08h, 03h, 08h, 17h
		db	 00h,0C0h, 00h,0CAh, 00h,0F0h
		db	 00h,0F7h, 1Ah,0D4h, 25h,0D7h
		db	 39h, 03h, 80h, 00h, 40h,0C1h
		db	 00h,0C2h, 70h, 39h, 00h, 0Ah
		db	0B8h, 80h, 00h,0B5h, 54h,0D0h
		db	 00h,0DAh,0AAh, 20h, 00h, 65h
		db	 56h, 30h, 00h,0B0h, 2Ah, 00h
		db	 08h, 75h, 59h, 20h, 05h, 4Ah
		db	 85h, 39h, 00h,0D5h, 00h
data_19		dw	80h			; Data table (indexed access)
		db	 68h, 44h, 39h, 00h,0D4h, 30h
		db	 80h, 00h, 60h,0A0h, 39h, 00h
		db	0C0h, 39h, 01h,0C0h, 00h, 08h
		db	 00h, 48h, 15h, 39h, 01h, 0Bh
		db	0C0h, 00h,0C2h, 03h, 39h, 00h
		db	 01h, 81h, 39h, 01h,0B1h, 39h
		db	 01h, 40h, 39h, 08h, 01h, 39h
		db	 00h, 01h, 08h, 22h, 00h, 02h
		db	 00h, 05h, 00h, 9Fh, 00h, 87h
		db	 39h, 00h, 01h, 1Eh, 00h, 10h
		db	0C0h, 2Dh, 39h, 00h, 78h, 3Ah
		db	 00h, 01h, 3Ch, 35h, 14h, 00h
		db	 6Bh,0C4h, 80h, 00h, 57h,0F8h
		db	 39h, 00h,0BAh,0AAh, 39h, 00h
		db	0D5h, 56h, 39h, 00h,0A8h, 43h
		db	 1Dh, 00h, 5Dh, 21h, 6Ah, 00h
		db	0EAh, 11h,0A8h, 10h,0ABh, 20h
		db	 08h, 06h, 16h, 26h, 04h, 09h
		db	 0Bh, 15h, 04h, 00h, 0Bh, 49h
		db	 39h, 00h, 27h,0B2h, 01h, 00h
		db	 02h,0D4h, 39h, 00h, 09h,0AAh
		db	 39h, 00h, 20h, 55h, 39h, 00h
		db	 04h, 06h, 44h, 00h, 5Eh, 88h
		db	 10h, 00h, 4Dh, 68h, 41h, 04h
		db	 9Ah, 82h, 5Bh, 90h, 5Bh, 80h
		db	 02h,0A8h, 3Ah,0A8h, 00h, 10h
		db	 95h, 50h, 39h, 00h, 54h, 39h
		db	 01h,0AAh, 39h, 02h, 3Fh, 01h
		db	 00h, 02h,0D4h, 04h, 01h, 0Bh
		db	 82h, 39h, 00h, 1Eh, 05h, 00h
		db	 48h, 38h, 50h, 00h,0C0h, 32h
		db	0D0h, 02h, 41h, 24h, 49h, 04h
		db	 10h, 2Ah, 10h, 39h, 00h, 68h
		db	 39h, 03h, 40h, 00h,0B1h, 80h
		db	 39h, 00h, 04h, 60h, 39h, 00h
		db	 03h,0CDh, 00h, 00h, 20h, 80h
		db	 00h, 20h, 08h, 28h, 40h, 00h
		db	 41h, 0Ch, 05h, 04h, 0Bh, 44h
		db	 00h, 21h, 0Eh, 41h, 00h, 08h
		db	 03h, 36h, 00h, 01h, 40h, 8Eh
		db	 20h, 00h, 40h, 00h, 0Ah, 02h
		db	 35h, 05h, 00h,0A0h, 0Fh, 50h
		db	 39h, 00h, 01h,0FFh, 02h, 08h
		db	 05h, 04h, 10h, 48h, 6Ch, 40h
		db	 00h, 10h, 00h, 28h, 82h, 40h
		db	 72h,0A0h, 39h, 01h, 18h, 63h
		db	 00h, 55h, 60h, 39h, 00h, 7Fh
		db	 39h, 03h, 20h, 00h, 14h, 39h
		db	 01h, 14h, 00h, 06h, 00h, 06h
		db	 39h, 00h,0C0h, 00h,0C0h, 39h
		db	 07h, 3Eh, 00h, 01h, 04h,0EAh
		db	 08h, 15h, 39h, 06h, 02h, 00h
		db	 01h, 40h, 34h, 00h, 35h, 40h
		db	0C0h, 00h,0C0h, 39h, 07h, 81h
		db	 00h, 42h, 39h, 00h,0BAh, 00h
		db	 45h, 13h, 6Ah, 20h, 95h, 08h
		db	0AAh, 07h, 55h, 32h,0AAh, 0Dh
		db	 55h, 8Eh, 2Ah, 71h,0D5h,0AAh
		db	0BAh, 55h, 55h, 2Ah,0FEh, 15h
		db	 54h, 02h,0FFh, 01h, 55h, 20h
		db	 10h,0D0h, 20h, 80h, 00h, 70h
		db	 00h, 28h, 00h,0D4h, 00h, 22h
		db	 80h,0DDh, 70h,0A8h, 28h, 57h
		db	0D4h, 9Eh, 00h, 55h, 55h,0AAh
		db	0A8h, 15h, 54h,0D5h, 00h, 55h
		db	 40h, 39h, 12h, 10h, 00h, 20h
		db	 39h, 10h, 40h, 00h, 80h
		db	39h
data_20		db	3
		db	 01h, 00h, 02h, 40h, 00h, 80h
		db	 39h, 03h, 01h, 00h, 02h, 39h
		db	 00h, 40h, 00h, 80h, 00h, 04h
		db	 00h, 08h,0B7h, 00h, 63h, 00h
		db	 00h, 14h, 00h, 28h, 00h, 02h
		db	 00h, 0Dh, 00h, 08h, 00h, 37h
		db	 02h,0AAh, 0Dh, 55h, 28h,0AAh
		db	 17h, 55h, 39h, 02h, 04h, 10h
		db	 08h, 20h, 3Eh, 00h, 01h, 00h
		db	0EAh, 81h, 15h, 42h, 2Ah, 40h
		db	0D5h, 40h,0AAh, 90h, 55h, 50h
		db	0AAh, 50h, 55h, 50h,0FDh, 40h
		db	 55h, 7Ch, 39h, 03h, 20h, 00h
		db	 10h, 20h, 00h, 10h, 00h, 08h
		db	 00h, 04h, 39h, 03h, 80h, 00h
		db	 40h, 39h, 03h, 08h, 00h, 04h
		db	 00h, 02h, 00h, 01h, 39h, 04h
		db	 82h, 00h, 41h, 20h, 00h, 10h
		db	 39h, 08h, 08h, 00h, 04h, 39h
		db	 17h,0A0h, 00h, 50h, 02h,0AAh
		db	 01h, 55h, 0Ah,0A2h, 05h, 5Dh
		db	 39h, 07h, 02h, 00h, 01h, 39h
		db	 0Ah, 20h, 00h,0D0h, 00h, 82h
		db	 00h, 7Dh,0C0h, 39h, 07h, 01h
		db	 00h, 40h, 00h, 02h, 0Ah, 10h
		db	 03h, 80h, 01h,0A5h, 1Ch, 64h
		db	 04h,0E1h,0E0h, 02h,0A7h,0F6h
		db	 7Eh, 08h, 72h, 79h, 39h, 02h
		db	 81h,0C0h, 01h
		db	40h
loc_9:
;*		add	byte ptr ds:data_5e[bx+si],0Ch
				db	082h,080h,0A9h,080h,00Ch	; add byte ptr [bx+si-7F57h],0Ch (alt encoding)
		or	cl,0A0h
		mov	cl,3
		rcl	word ptr [bx+di+41h],cl	; Rotate thru carry
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		iret				; Interrupt return
			                        ; (data -- Sourcer: no entry point)
		mov	ds:data_41e,ax
		call	dword ptr [bp+si]	;*
		or	dx,ax
		std				; Set direction flag
		ror	byte ptr [bx],1		; Rotate
;*		loopnz	locloop_10		;*Loop if zf=0, cx>0

		db	0E0h, 00Fh		; loopne 11A7h (absolute)
		cmpsw				; Cmp [si] to es:[di]
		add	[bx+si],bh
		add	[bp+di],ch
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			; data (Sourcer fake instr)
		dec	sp
		or	[di+3Fh],cx
		mov	ds:data_35e,ax
		pop	ds
;*		aam	1Fh			; undocumented inst
				db	0D4h,01Fh	; aam 1Fh (alt encoding)
		aam				; Ascii adjust
		cli				; Disable interrupts
		or	bh,dl
;*		add	[bx+0],bl
				db	000h,05Fh,000h	; add [bx+0h],bl (alt encoding)
		db	 5Fh, 3Eh,0A0h, 26h,0A0h, 3Ch
		db	 30h,0FCh, 30h,0CAh,0A0h,0CAh
		db	0A0h, 35h, 41h, 3Dh, 40h,0FFh
		db	0F3h, 38h,0B1h, 2Fh, 5Ah, 37h
		db	 5Ah,0FAh,0BCh,0FAh,0BCh,0B5h
		db	 18h,0F5h, 18h,0A8h, 08h,0A8h
		db	 08h, 39h, 00h, 40h, 90h, 39h
		db	 00h, 08h, 39h, 02h, 40h, 39h
		db	 01h, 09h, 39h, 00h, 04h, 56h
		db	 39h, 00h, 01h, 2Fh, 39h, 00h
		db	 40h, 7Fh, 39h, 00h
loc_11:
		add	ax,397Fh
		add	[si+39h],al
		add	[bx+si],sp
		adc	bh,[bx+di]
		add	[bx+si],dh
		cmp	byte ptr [bx+di],0
loc_12:
		inc	bp
		adc	bh,[bx+di]
		add	ss:data_25e[bp+di],ch
;*		add	bl,dl
				db	000h,0D3h	; add bl,dl (alt encoding)
		retf	2B00h
			                        ; (data -- Sourcer: no entry point)
		out	dx,ax			; port 0, DMA-1 bas&add ch 0
		mov	di,data_27e
		jmp	short loc_12
		db	 00h, 01h, 12h,0EFh, 00h, 14h
		db	 0Ah, 7Fh, 06h, 40h, 17h,0CFh
		db	0D0h, 00h,0D7h,0FFh, 30h, 14h
		db	 31h,0F7h, 0Ah,0F8h, 0Ah,0FBh
		db	 00h, 5Eh, 00h, 5Fh, 3Eh,0A0h
		db	 26h,0A0h, 08h, 04h, 7Ch, 5Ch
		db	 04h, 0Eh
loc_13:
		jge	loc_13			; Jump if > or =
		add	[bx],cl
		jle	$+81h			; Jump if < or =
		add	cl,bh
		sti				; Enable interrupts
		jmp	dword ptr [bx]		;*
			                        ; (data -- Sourcer: no entry point)
		dec	dx
		neg	word ptr [bp+si-6Eh]
		mov	sp,0BCFAh
		test	bx,[bx+si]
		cmc				; Complement carry
		sbb	ds:data_40e[bx+si],cl
		or	[bx+di],bh
		add	al,10h
		add	al,39h			; '9'
		add	[bx+di+39h],sp
		add	[si],al
		add	ax,39h
		and	byte ptr data_9[bx],ch
		inc	dx
		pop	es
		add	ah,ds:data_26e[bx+di]
		add	ax,3050h
		cmp	word ptr [bx+di],1
		or	[bx+di],bh
		add	byte ptr data_14[bx+si],cl
		and	byte ptr data_9[bx+si],al
		xchg	sp,ax
		sub	[bx+di],bh
		add	[bx+52h],bh
		cmp	[bx+si],ax
		db	 36h, 50h, 80h, 50h, 15h, 02h
		db	 20h, 08h, 96h,0A3h, 39h, 01h
		db	 88h, 39h, 00h, 08h, 04h, 39h
		db	 00h, 11h, 1Dh, 00h, 3Ch, 07h
		db	0FDh, 33h, 03h, 33h,0FFh, 0Fh
		db	0F0h, 0Fh,0FFh,0F0h, 0Eh,0FFh
		db	0FEh, 0Eh,0A4h, 0Eh,0A4h, 39h
		db	 00h, 08h, 39h, 01h, 82h, 10h
		db	 39h, 00h,0F5h, 49h,0C0h, 00h
		db	0FEh,0F8h, 28h,0D8h,0EEh,0DAh
		db	 02h,0B4h,0FEh,0B4h,0A0h, 0Ch
		db	0AFh,0FCh, 0Dh, 52h, 0Dh, 52h
		db	 03h,0BFh, 02h,0AAh, 08h, 39h
		db	 01h, 18h, 00h, 02h,0FEh, 30h
		db	 00h, 20h, 00h, 20h, 00h, 0Bh
		db	0FAh, 20h, 00h, 20h, 39h, 01h
		db	 0Bh,0FAh, 20h, 00h, 20h, 00h
		db	0AAh,0F0h,0AAh, 30h, 03h, 08h
		db	 00h, 08h, 02h, 04h,0AAh,0C5h
		db	 00h, 02h, 04h, 22h, 39h, 00h
		db	0A0h, 48h, 04h, 02h, 04h, 92h
		db	 39h, 00h,0A1h, 20h, 04h, 02h
		db	 04h, 02h, 3Fh,0B6h, 23h,0A6h
		db	 20h, 34h, 00h, 24h, 10h, 1Ch
		db	 02h, 3Eh, 10h, 00h, 01h, 55h
		db	 10h, 00h, 10h, 00h, 10h, 00h
		db	 15h,0FDh, 10h, 00h, 12h,0AAh
		db	 1Dh, 50h, 1Dh, 50h,0EAh,0AAh
		db	 8Ah,0AAh, 04h, 02h, 04h, 02h
		db	 04h, 00h, 20h, 80h, 04h, 02h
		db	 44h, 22h, 04h, 02h, 05h, 02h
		db	 04h, 00h, 50h, 20h,0C5h, 00h
		db	0A2h, 44h, 6Dh, 6Ch, 45h, 6Ch
		db	 00h, 02h, 00h, 02h, 00h, 07h
		db	 00h, 06h, 00h, 07h, 00h, 06h
		db	 00h, 1Fh, 00h, 1Fh, 00h, 78h
		db	 00h, 70h, 00h,0E0h, 00h,0C0h
		db	 00h, 78h, 00h, 70h, 00h, 1Fh
		db	 00h, 1Bh, 39h, 0Ah,0C0h, 00h
		db	0C0h, 00h,0F0h, 00h,0E0h, 00h
		db	 38h, 00h, 20h, 00h,0F0h, 00h
		db	0C0h, 00h,0C0h, 39h, 02h, 0Fh
		db	 00h, 0Dh, 00h, 0Bh, 00h, 0Ah
		db	 00h, 0Bh, 00h, 09h, 00h, 0Bh
		db	 00h, 0Ah, 00h, 0Bh, 00h, 09h
		db	 00h, 0Bh, 00h, 0Ah, 00h, 0Bh
		db	 00h, 09h, 39h, 0Ah,0E0h, 00h
		db	0A0h, 39h, 03h, 90h, 00h, 90h
		db	 00h,0F0h, 00h,0C0h, 39h, 08h
		db	 07h, 39h, 01h, 0Fh, 39h, 01h
		db	 05h, 39h, 01h, 04h, 39h, 01h
		db	 3Fh, 39h, 01h, 0Fh, 39h, 01h
		db	 0Ah, 39h, 01h, 62h, 39h, 00h
		db	0E0h, 39h, 01h, 90h, 39h, 01h
		db	 20h, 39h, 01h, 20h, 39h, 01h
		db	 4Ch, 39h, 01h, 10h, 39h, 05h
		db	 02h, 39h, 01h, 01h, 95h, 39h
		db	 00h, 07h,0B8h, 00h, 47h, 0Fh
		db	 30h, 00h, 8Ah, 0Fh,0B0h, 00h
		db	 45h, 0Dh, 30h, 02h, 8Bh, 06h
		db	0D0h, 00h, 25h, 01h,0A8h, 00h
		db	 13h, 00h, 54h, 00h, 2Ah, 50h
		db	 80h, 39h, 01h, 20h,0FCh, 39h
		db	 00h, 10h,0AAh, 80h, 39h, 00h
		db	 55h, 39h, 00h, 10h,0FEh, 80h
		db	 00h, 20h,0FFh, 39h, 00h, 80h
		db	0FCh, 00h, 02h, 00h,0A8h, 00h
		db	 4Dh, 93h, 01h, 03h,0DEh,0C6h
		db	 4Ah, 86h, 3Dh, 76h, 18h, 64h
		db	0F3h,0E1h,0D2h,0A1h,0DFh, 3Fh
		db	 8Ah, 3Eh,0DEh,0FAh, 4Ch,0EAh
		db	 4Ch,0FCh, 08h,0D8h, 54h,0C9h
		db	 04h, 48h, 40h, 93h, 00h, 03h
		db	0D0h, 46h, 40h, 06h, 38h, 16h
		db	 18h, 04h,0F3h, 01h,0D2h, 01h
		db	0DFh, 01h, 8Ah, 00h,0DEh,0F0h
		db	 44h,0A0h, 4Ch,0F8h, 08h,0D8h
		db	 54h,0C0h, 04h, 40h, 4Dh, 93h
		db	 01h, 03h,0DEh,0C2h, 4Ah, 82h
		db	 3Dh, 42h, 18h, 40h,0F3h, 01h
		db	 82h, 01h,0DCh, 0Fh, 08h, 0Eh
		db	0C0h, 7Ah, 00h, 6Ah, 00h,0FCh
		db	 00h, 90h, 14h,0C9h, 04h, 48h
		db	 00h, 03h, 00h, 03h, 00h, 04h
		db	 00h, 04h, 3Dh, 60h, 10h, 60h
		db	0F3h,0C1h,0D2h, 81h,0DFh, 0Fh
		db	 8Ah, 0Ah,0DEh, 1Ah, 48h, 0Ah
		db	 48h, 3Ch, 08h, 18h, 50h, 09h
		db	 00h, 08h, 40h, 13h, 00h, 03h
		db	0C6h, 80h, 42h, 80h, 21h, 76h
		db	 00h, 64h,0F0h,0E1h,0D0h,0A1h
		db	0DCh, 3Fh, 88h, 26h,0DEh, 7Ah
		db	 40h, 6Ah, 4Ch, 3Ch, 39h, 00h
		db	 54h,0C9h, 04h, 48h, 39h, 0Ah
		db	 08h, 30h, 39h, 08h, 03h, 06h
		db	 02h, 00h, 60h, 10h, 60h, 39h
		db	 03h, 04h, 39h, 01h, 60h, 00h
		db	 40h, 39h, 03h, 10h, 60h, 39h
		db	 04h, 0Eh, 00h, 0Ch, 00h, 1Dh
		db	 06h, 10h, 04h,0F0h, 00h, 40h
		db	 00h, 70h,0C0h, 40h, 80h, 18h
		db	 20h, 39h, 00h, 01h, 80h, 39h
		db	 00h, 3Dh, 66h, 18h, 60h,0F3h
		db	0D1h, 92h, 01h,0D5h, 0Eh, 00h
		db	 0Ch,0DAh, 5Ah, 48h, 08h, 3Ch
		db	 80h, 04h, 00h, 74h, 10h, 20h
		db	 00h, 50h, 30h, 39h, 04h, 2Dh
		db	 76h, 00h, 64h,0B0h,0E1h, 10h
		db	0A0h,0DCh, 37h, 88h, 22h,0DEh
		db	 6Ah, 08h, 40h, 01h, 06h, 39h
		db	 01h, 10h, 39h, 00h, 20h, 00h
		db	 20h, 00h, 70h,0E0h, 20h, 80h
		db	 28h, 60h, 39h, 00h, 11h, 80h
		db	 39h, 00h, 35h, 62h, 10h, 00h
		db	0D3h, 55h, 80h, 01h, 39h, 02h
		db	 4Ch, 00h, 04h, 00h, 19h, 00h
		db	 10h, 00h, 34h, 10h, 39h, 00h
		db	 68h, 30h, 39h, 00h, 20h, 39h
		db	 01h, 28h, 56h, 00h, 04h, 50h
		db	0A1h, 00h, 01h, 1Dh, 55h, 39h
		db	 00h, 29h, 82h, 02h, 40h, 55h
		db	 05h, 02h,0C0h, 28h, 0Ah, 00h
		db	 80h, 01h, 54h, 39h, 01h,0A0h
		db	 39h, 02h, 01h, 40h, 39h, 00h
		db	 01h, 80h, 4Ah,0A8h, 0Ah, 02h
		db	 5Fh, 54h, 00h, 02h, 3Ah,0A8h
		db	 39h, 00h, 95h, 50h, 39h, 02h
		db	 07h, 39h, 01h, 0Ch, 39h, 10h
		db	 07h, 00h, 08h, 00h, 40h, 00h
		db	0B0h, 02h, 00h, 01h, 39h, 01h
		db	 0Ch, 00h, 10h, 00h, 08h, 00h
		db	 20h,0EEh, 10h, 2Ch, 39h, 06h
		db	 40h, 00h,0B0h, 00h, 04h, 00h
		db	 0Ah, 39h, 01h, 01h, 80h, 39h
		db	 02h, 04h, 80h, 39h, 00h, 0Eh
		db	 40h, 0Ch, 00h, 47h, 55h, 20h
		db	 50h, 9Ah,0AAh, 40h,0A0h, 35h
		db	 45h,0C0h, 00h, 3Ah,0A2h, 40h
		db	 00h, 15h, 51h, 40h, 00h, 02h
		db	 80h, 39h, 01h,0D0h, 39h, 03h
		db	 16h, 4Bh, 20h, 0Ah, 00h,0AAh
		db	0A8h, 39h, 00h, 41h, 94h, 02h
		db	 40h,0A1h, 2Ah, 02h,0C0h, 10h
		db	 14h, 01h, 00h, 2Ah, 80h, 39h
		db	 00h, 18h, 00h, 40h, 39h, 01h
		db	0C0h, 39h, 08h, 03h, 00h, 04h
		db	 00h, 20h, 00h, 58h, 01h, 39h
		db	 00h,0C0h, 39h, 00h, 06h, 00h
		db	 08h, 00h, 04h, 39h, 00h,0F6h
		db	 10h, 30h, 39h, 06h,0A8h, 00h
		db	 56h, 39h, 07h, 04h, 80h, 39h
		db	 00h, 0Eh, 40h, 0Ch, 00h, 0Bh
		db	 20h, 0Ah, 00h, 17h, 55h, 20h
		db	 50h, 1Ah,0AAh, 60h,0A0h, 35h
		db	 45h, 40h, 00h, 3Ah,0A2h, 40h
		db	 00h, 15h, 41h, 39h, 00h, 02h
		db	 80h, 39h, 00h, 05h, 39h, 03h
		db	 05h, 80h,0AAh,0A8h, 39h, 00h
		db	 41h, 94h, 02h, 40h, 21h, 2Ah
		db	 02h,0C0h, 5Ch, 14h, 01h, 00h
		db	 0Bh, 00h, 60h, 00h, 04h, 00h
		db	 10h, 39h, 10h, 02h, 00h, 01h
		db	 00h, 18h, 00h, 04h, 00h,0C0h
		db	 01h, 20h, 04h, 00h, 0Ah, 00h
		db	 10h,0FFh, 28h, 38h, 47h, 55h
		db	 20h, 50h, 39h, 00h, 10h, 00h
		db	 40h, 00h, 20h, 39h, 01h, 80h
		db	 39h, 03h, 04h, 80h, 39h, 00h
		db	 0Eh, 40h, 0Ch, 00h, 0Bh, 20h
		db	 0Ah, 00h,0AAh,0A8h, 39h, 00h
		db	 5Ah,0AAh, 20h,0A0h, 35h, 56h
		db	0C0h, 50h, 3Ah,0A8h, 40h, 20h
		db	 15h, 54h, 39h, 00h, 0Ah,0A8h
		db	 39h, 00h, 35h,0B7h, 00h, 39h
		db	 01h,0A0h, 39h, 03h, 41h, 94h
		db	 02h, 40h,0A1h, 2Ah, 02h,0C0h
		db	 50h, 14h, 01h, 00h,0AAh,0A0h
		db	 00h, 0Bh, 39h, 1Ah, 01h,0CAh
		db	 02h, 35h, 08h, 00h, 16h, 00h
		db	 11h,0FCh, 20h, 30h, 07h, 55h
		db	 60h, 50h, 1Ah,0AAh, 40h,0A0h
		db	 02h, 39h, 01h, 08h, 00h, 04h
		db	 00h,0C0h, 00h, 30h, 39h, 07h
		db	 04h, 80h, 39h, 00h, 0Eh, 40h
		db	 0Ch, 00h, 8Bh, 20h, 0Ah, 00h
		db	 35h, 52h, 40h, 50h, 2Bh,0A8h
		db	 40h, 00h, 17h, 50h, 39h, 00h
		db	 0Ah,0A9h, 39h, 03h,0E0h, 39h
		db	 01h, 30h, 39h, 06h,0AAh,0A8h
		db	 39h, 00h, 41h, 94h, 02h, 40h
		db	0A1h, 2Ah, 02h,0C0h, 50h, 14h
		db	 01h, 00h, 2Ah, 80h, 39h, 00h
		db	 05h, 39h, 03h, 02h, 80h, 39h
		db	 00h, 01h, 80h, 00h, 04h, 39h
		db	 01h, 0Ch, 39h, 01h, 13h, 39h
		db	 01h, 2Ah, 39h, 01h, 09h, 00h
		db	 60h, 00h, 09h, 00h, 60h, 00h
		db	 2Ah, 39h, 01h, 10h, 39h, 00h
		db	 60h, 08h, 39h, 00h,0B0h, 08h
		db	 20h, 00h, 30h, 10h, 20h, 08h
		db	0A8h, 39h, 00h, 10h, 88h, 20h
		db	 40h, 10h, 04h, 40h,0C0h, 20h
		db	 0Ah, 40h, 00h, 20h, 54h, 39h
		db	 00h, 30h, 00h, 1Ch, 39h, 01h
		db	 20h, 00h, 0Ah, 07h,0D1h, 00h
		db	 04h, 0Eh, 8Ah, 39h, 00h, 0Dh
		db	 44h, 39h, 00h, 02h, 82h, 39h
		db	 01h, 50h, 39h, 01h,0AAh, 6Ah
		db	 00h, 74h, 10h, 00h, 08h, 82h
		db	 00h, 28h, 0Ch, 47h,0C0h, 10h
		db	 1Ch,0AEh,0A0h, 00h, 08h, 55h
		db	 50h, 39h, 00h,0AAh,0A0h, 39h
		db	 00h, 14h, 39h, 01h, 2Ah, 80h
		db	 00h, 2Ah, 00h, 03h, 39h, 01h
		db	 06h, 00h, 02h, 00h, 06h, 00h
		db	 02h, 00h, 0Ah, 39h, 01h, 08h
		db	 00h, 01h, 00h, 10h, 00h, 01h
		db	 00h, 28h, 39h, 01h, 15h, 39h
		db	 00h, 10h, 08h, 39h, 00h, 98h
		db	 08h, 39h, 00h, 64h, 10h, 00h
		db	 08h,0AAh, 39h, 00h, 10h,0C8h
		db	 20h, 03h, 10h, 88h, 40h, 43h
		db	 20h, 2Ah, 40h, 00h, 20h, 04h
		db	 39h, 00h, 30h, 39h, 00h, 30h
		db	 39h, 00h, 03h, 0Eh, 04h, 00h
		db	 60h, 01h, 98h, 39h, 00h, 12h
		db	 39h, 00h, 01h, 03h, 48h, 0Ch
		db	 45h, 00h,0E8h, 2Ah, 22h, 05h
		db	0FCh, 15h, 24h,0C2h, 3Dh, 14h
		db	 00h, 2Bh, 00h, 01h, 00h,0B3h
		db	 00h, 06h, 00h, 01h, 80h, 30h
		db	 00h, 4Ch, 00h,0A1h,0E8h, 00h
		db	 07h, 4Dh, 50h, 39h, 00h, 9Ah
		db	 88h, 39h, 00h, 45h, 10h, 98h
		db	 00h, 02h, 8Ch,0C8h, 3Eh, 01h
		db	 02h, 00h, 8Fh, 0Dh, 08h, 10h
		db	 71h, 0Ah,0B5h, 60h, 00h, 15h
		db	 6Ah, 39h, 01h, 84h, 39h, 01h
		db	0C9h, 00h, 20h, 00h, 94h, 00h
		db	 61h, 82h, 20h, 30h, 00h, 10h
		db	 00h,0C0h, 00h, 82h, 00h,0E0h
		db	 08h, 39h, 00h, 2Ch, 40h, 80h
		db	 39h, 01h, 04h, 39h, 00h, 10h
		db	 8Fh,0B7h, 00h, 18h, 0Ah,0A0h
		db	0C0h, 0Ch, 39h, 01h, 98h, 00h
		db	 01h, 11h, 02h, 08h, 00h, 88h
		db	0A9h, 00h, 40h, 14h,0F2h, 39h
		db	 00h, 27h, 4Fh, 01h, 00h, 15h
		db	0D7h, 00h, 04h, 2Bh,0BEh, 01h
		db	 06h, 87h, 7Fh, 39h, 00h, 04h
		db	 00h, 80h, 00h, 62h, 40h, 18h
		db	 00h, 06h, 42h, 02h, 00h, 29h
		db	 50h, 39h, 00h, 50h,0CAh, 80h
		db	 40h,0D5h, 30h, 00h, 30h,0EBh
		db	 88h, 83h,0C0h,0C8h, 18h

ZR356FUL	endp

seg_a		ends



		end	start
