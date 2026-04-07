
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_383UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_2e		equ	0FB2Ah			;*
data_3e		equ	0FBAAh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_383UNKN	proc	far

start:
		xor	ax,3
		add	[bx+si],al
		pop	es
		sti				; Enable interrupts
		add	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		push	cs
		adc	[bp+si],dx
		adc	di,bx
		add	[bx+di],dh
		push	sp
		add	ax,0FBh
		add	ss:data_3e[bp+si],bp
		add	[bx+di],al
		push	bp
		push	bp
		sti				; Enable interrupts
		add	[bx+di],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		sti				; Enable interrupts
		add	[bx+di],al
		push	bp
		push	bp
		sti				; Enable interrupts
		add	[bx+di],al
		mov	cl,data_1[bx+si]
		pop	es
		mov	al,ds:data_2e
		add	[bx+di],al
		push	bp
		push	bp
		sti				; Enable interrupts
		add	[bx+di],al
		stosw				; Store ax to es:[di]
		stosb				; Store al to es:[di]
		sti				; Enable interrupts
		add	[bx+di],al
		push	bp
		pop	bp
		sti				; Enable interrupts
		add	[bx+di],al
		stosb				; Store al to es:[di]
		stosb				; Store al to es:[di]
		sti				; Enable interrupts
		add	[bx+di],al
		adc	[bx+di-5],dx
		add	[bp+si],al
;*		or	bl,bh
		db	 08h,0FBh		;  Fixup - byte match
		add	[di],al
		db	 6Ch, 60h, 13h, 8Ch, 13h, 8Ch
		db	0D5h, 54h, 00h, 50h, 00h, 00h
		db	 2Ah,0A8h, 8Ah, 80h, 80h, 00h
		db	 95h, 54h, 55h, 00h, 40h, 00h
		db	 2Ah,0A8h,0AAh, 80h, 80h, 00h
		db	0D5h, 54h, 14h, 40h,0FBh, 00h
		db	 05h, 84h, 20h, 73h, 1Ch, 73h
		db	 1Ch, 95h, 54h, 40h, 10h, 40h
		db	 00h, 2Ah,0A8h, 80h, 08h, 80h
		db	 00h, 55h, 54h, 80h, 10h, 80h
		db	 00h,0AAh,0A8h, 02h, 80h, 00h
		db	 00h, 95h, 54h, 41h, 50h, 40h
		db	0FBh, 00h, 0Bh, 0Bh, 7Fh,0F4h
		db	 22h, 50h, 00h, 0Bh, 7Fh,0F4h
		db	 22h, 50h,0FBh, 00h, 09h, 1Dh
		db	 00h, 05h, 15h, 05h, 00h, 70h
		db	 40h, 10h, 4Bh, 10h, 40h,0C0h
		db	 20h,0CAh, 27h,0C0h, 20h, 80h
		db	 30h, 97h, 33h, 80h, 30h,0D0h
		db	 00h, 2Fh,0FEh, 0Ah, 44h,0D0h
		db	 00h, 2Fh,0FEh, 0Ah, 44h,0FBh
		db	 00h, 0Ah,0B8h, 50h,0A0h, 00h
		db	0A0h, 02h, 0Eh,0A2h, 08h, 02h
		db	 08h, 04h, 03h,0E4h, 53h, 04h
		db	 03h, 0Ch, 01h,0CCh,0E9h, 0Ch
		db	 01h, 00h, 30h, 03h,0A2h, 00h
		db	 20h, 00h, 18h, 02h, 90h, 00h
		db	 10h, 00h, 0Fh, 02h,0CCh
data_1		db	0			; Data table (indexed access)
		db	 0Ch,0FBh, 00h, 04h, 03h, 7Fh
		db	0FCh, 22h, 58h, 00h, 01h, 7Fh
		db	0FEh, 22h, 5Ah, 00h, 03h, 7Fh
		db	0FCh, 22h, 58h,0FBh, 00h, 03h
		db	 0Ch, 00h,0C5h,0C0h, 04h, 00h
		db	 18h, 00h, 09h, 40h, 08h, 00h
		db	0F0h, 00h, 33h, 40h, 30h,0FBh
		db	 00h, 04h,0C0h, 00h, 3Fh,0FEh
		db	 1Ah, 44h, 80h, 00h, 7Fh,0FEh
		db	 5Ah, 44h,0C0h, 00h, 3Fh,0FEh
		db	 1Ah, 44h,0FBh, 00h, 03h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h,0A5h
		db	 62h, 29h, 00h, 2Dh, 62h,0A1h
		db	 29h, 2Dh, 48h, 2Dh, 69h,0A5h
		db	 62h, 29h, 00h, 2Dh, 62h,0A1h
		db	 29h, 2Dh, 48h, 2Dh, 69h,0A5h
		db	 62h, 29h, 00h, 2Dh, 62h,0A1h
		db	 29h, 2Dh, 48h, 2Dh, 69h,0A5h
		db	 62h, 29h, 00h, 2Dh, 62h,0A1h
		db	 29h, 2Dh, 48h, 2Dh, 69h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 85h, 12h,0B4h, 96h,0B4h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h,0FBh
		db	 00h, 03h,0A5h, 62h, 29h, 00h
		db	 2Dh, 62h,0A1h, 29h, 2Dh, 48h
		db	 2Dh, 69h,0A5h, 62h, 29h, 00h
		db	 2Dh, 62h,0A1h, 29h, 2Dh, 48h
		db	 2Dh, 69h,0A5h, 62h, 29h, 00h
		db	 2Dh, 62h,0A1h, 29h, 2Dh, 48h
		db	 2Dh, 69h,0A5h, 62h, 29h, 00h
		db	 2Dh, 62h,0FBh, 00h, 03h, 46h
		db	0A5h, 00h, 94h, 46h,0B4h, 94h
		db	 84h, 12h,0B5h, 96h,0B5h, 46h
		db	 25h, 00h, 14h, 46h, 34h, 94h
		db	 84h, 12h,0B5h, 96h,0B5h, 46h
		db	0A4h, 00h, 95h, 46h,0B5h, 94h
		db	 00h, 12h, 31h, 96h, 31h, 46h
		db	0A5h, 00h, 95h, 46h,0B5h, 94h
		db	 00h, 12h, 00h, 96h, 00h,0A5h
		db	 62h, 29h, 00h, 2Dh, 62h,0A0h
		db	 29h, 2Ch, 48h, 2Ch, 69h, 25h
		db	 62h,0A9h, 00h,0ADh, 62h, 21h
		db	 28h,0ADh, 48h,0ADh, 68h, 84h
		db	 42h, 08h, 00h, 8Ch, 42h,0A9h
		db	 20h, 21h, 00h,0A9h, 20h, 00h
		db	 40h,0FBh, 00h, 00h, 40h, 88h
		db	0FBh, 00h, 00h, 88h, 00h, 4Dh
		db	 57h, 48h, 07h, 4Dh, 57h,0D2h
		db	0ABh,0D2h, 01h,0D2h,0ABh, 74h
		db	0D5h, 74h, 80h, 74h,0D5h, 1Dh
		db	 2Ah, 1Dh, 20h, 1Dh, 2Ah, 07h
		db	 4Dh, 07h, 48h, 07h, 4Dh, 01h
		db	0D2h, 01h,0D2h, 01h,0D2h, 80h
		db	 74h, 80h, 74h, 80h, 74h,0F5h
		db	 1Dh,0F5h, 1Dh,0F5h, 1Dh, 4Dh
		db	 57h, 48h, 07h, 4Dh, 57h, 52h
		db	0ABh,0D2h, 01h,0D2h,0ABh, 54h
		db	0D5h, 74h, 80h, 74h,0D5h, 15h
		db	 2Ah, 1Dh, 20h, 1Dh, 2Ah, 01h
		db	 4Dh, 07h, 48h, 07h, 4Dh, 00h
		db	 52h, 01h,0D2h, 01h,0D2h, 80h
		db	 54h, 80h, 74h, 80h, 74h, 15h
		db	 91h,0FDh, 99h,0FDh, 99h,0FFh
		db	0B9h, 00h, 00h,0FFh,0B9h,0EAh
		db	0AAh, 00h, 00h,0EAh,0AAh,0D5h
		db	 54h, 00h, 00h,0D5h, 54h,0AAh
		db	0A8h, 00h, 00h,0AAh,0A8h,0D5h
		db	0FBh, 00h, 00h,0D5h, 00h, 8Ah
		db	 2Ah, 00h, 00h, 8Ah, 2Ah, 40h
		db	 14h, 00h, 00h, 40h, 14h, 00h
		db	 08h,0FBh, 00h, 00h, 08h, 55h
		db	 55h, 00h, 00h, 55h, 55h, 22h
		db	 23h, 00h, 00h, 22h, 23h, 08h
		db	 89h, 00h, 00h, 08h, 89h, 20h
		db	 23h, 00h, 00h, 20h, 23h, 08h
		db	 09h, 00h, 00h, 08h, 09h, 20h
		db	 23h, 00h, 00h, 20h, 23h, 08h
		db	 89h, 00h, 00h, 08h, 89h,0FBh
		db	 00h, 09h, 10h,0FBh, 00h, 00h
		db	 10h, 00h, 00h, 04h,0FBh, 00h
		db	 00h, 04h,0FBh, 00h, 03h, 01h
		db	0FBh, 00h, 00h, 01h, 00h, 20h
		db	0FBh, 00h, 00h, 20h,0FBh, 00h
		db	 05h, 04h,0FBh, 00h, 00h, 04h
		db	0FBh, 00h
		db	2Dh

_383UNKN	endp

seg_a		ends



		end	start
