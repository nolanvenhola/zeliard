
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_376UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_5e		equ	1005h			;*
data_6e		equ	3600h			;*
data_7e		equ	5A80h			;*
data_8e		equ	0A7AEh			;*
data_9e		equ	0A802h			;*
data_10e	equ	0BC10h			;*
data_11e	equ	0BC80h			;*
data_12e	equ	0BE07h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_376UNKN	proc	far

start:
		xlat				; al=[al+[bx]] table
		push	es
		add	[bx+si],al
		add	[bx],al
		inc	byte ptr [bx+si]
		add	[bp+si],ax
		pop	es
		or	cx,[si]
		sbb	bx,[si]
		sbb	ax,2120h
		and	ah,[bp+di]
		and	al,25h			; '%'
		inc	byte ptr es:[bx+si]
		add	ax,0FE1Bh
		add	[bx+si],al
		sbb	al,0FEh
		add	[bx+si],al
		sbb	ax,1F1Eh
		inc	byte ptr [bx+si]
		or	cl,[si]
		and	[bx+si],cl
		xor	[si],al
		add	[bp+di],al
		add	[bx+si],al
		inc	ax
		add	ax,[bx+si]
		add	al,al
		add	al,[bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		or	[bx+si],dh
		or	al,0
		add	[bx+si],dh
		or	[bx+si],dh
		or	al,20h			; ' '
		add	[bx+si],dl
		add	[bx+si],dh
		or	al,20h			; ' '
		add	[bx+si],dl
		add	[bx+si+3],al
		add	[bx+si],al
		inc	ax
		add	al,[bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		add	al,[bx+si]
		or	al,20h			; ' '
		or	[bx+si],dh
		add	al,0
		add	al,[bx+si]
		add	[bx+si+2],al
		add	[bx+si],cl
		add	[bx+si],cl
		inc	byte ptr [bx+si]
		add	ds:data_6e,dh
		inc	byte ptr [bx+si]
		add	[bp+si+0Ch],bl
		pop	dx
		or	al,0
		add	[bx+si],ah
		and	byte ptr cs:data_3,ch
		add	[di],al
		add	[di],al
		add	[bx+si],al
		add	al,[bx+si]
;*		add	al,al
		db	 00h,0C0h		;  Fixup - byte match
		add	bh,dh
		add	[si],al
		push	ax
		add	dl,[bx+si+6]
		add	[si],al
		sub	al,[bp+si]
		sub	dh,[bp+di]
		add	[bx+di],dh
		adc	ds:data_10e[si],bl
		add	[bx+si],ah
		add	ch,ss:data_12e[bp]
		add	ax,0E10h
		stosb				; Store al to es:[di]
		push	ds
		stosb				; Store al to es:[di]
		adc	[bx+si],al
		xor	ax,3514h
		adc	al,0
		add	[bp+si],ch
		add	ch,[bp+si]
		add	al,[bx+si]
		add	[bx+di],cl
		push	ax
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		rol	byte ptr ds:data_7e,1	; Rotate
;*		cmp	byte ptr [bp+si-7Ah],20h	; ' '
		db	 82h, 7Ah, 86h, 20h	;  Fixup - byte match
		add	al,55h			; 'U'
		add	dl,[di+33h]
		add	[bx+di],dh
		sbb	byte ptr ds:data_11e[si],0
		and	ss:data_8e[bp+si],ah
		mov	si,data_5e
		dec	si
		stosb				; Store al to es:[di]
		pop	si
		stosb				; Store al to es:[di]
		adc	[bx+si],al
		mov	ch,14h
		mov	ch,14h
		add	[bx+si],al
		sub	al,[bp+si]
		sub	al,[bp+si]
		add	[bx+si],al
		add	ah,ds:data_9e[bx+si]
		add	[bx+si],al
		adc	[bp+di],ax
		db	0D9h, 1Bh,0FEh, 00h, 00h, 01h
		db	 7Ch, 61h, 30h, 20h, 00h, 00h
		db	 37h, 90h, 02h, 00h, 80h, 01h
data_3		dw	0E980h			; Data table (indexed access)
		db	 00h, 40h, 00h, 00h, 0Ah, 10h
		db	 00h, 00h, 80h, 44h,0A4h, 44h
		db	 00h, 00h, 50h,0B5h, 50h,0B5h
		db	0FEh, 00h, 05h, 01h, 00h, 01h
		db	0FEh, 00h, 00h, 08h, 20h, 08h
		db	 20h, 00h, 00h, 80h, 94h, 80h
		db	 94h, 00h, 00h,0A2h, 8Ah,0A7h
		db	 8Ah, 05h, 00h, 4Eh, 9Ch, 5Eh
		db	 9Ch, 10h, 00h,0B5h, 3Ah,0B5h
		db	 3Ah, 00h, 00h, 2Ah, 50h, 2Ah
		db	 50h, 00h, 00h, 05h, 50h, 05h
		db	 50h, 00h, 00h, 2Ah, 82h, 2Ah
		db	 82h, 00h, 00h, 55h, 11h, 55h
		db	 11h, 00h, 00h, 80h,0A8h, 80h
		db	0A8h, 00h, 00h,0A5h, 14h,0A5h
		db	 14h, 00h, 00h, 4Ah,0AAh, 4Ah
		db	0AAh, 00h, 00h, 95h, 14h, 95h
		db	 14h, 00h, 00h, 2Ah, 02h, 2Ah
		db	 02h, 00h, 00h, 09h, 50h, 0Fh
		db	0D0h, 06h, 80h, 5Ah, 82h, 7Ah
		db	 86h, 20h, 04h, 55h, 02h, 55h
		db	 33h, 00h, 31h, 00h, 9Ch, 00h
		db	0BCh, 00h, 20h, 02h,0AEh, 07h
		db	0BEh, 05h, 10h, 0Eh,0AAh, 1Eh
		db	0AAh, 10h, 00h, 34h, 14h, 34h
		db	 14h,0FEh, 00h, 00h, 02h, 00h
		db	 02h,0FEh, 00h, 01h, 40h, 00h
		db	 40h, 00h, 08h, 02h, 28h, 06h
		db	 20h, 04h, 54h, 02h, 54h, 33h
		db	 00h, 31h, 80h, 9Ch, 80h,0BCh
		db	 00h, 20h,0A2h,0AEh,0A7h,0BEh
		db	 05h, 10h, 4Eh,0AAh, 5Eh,0AAh
		db	 10h, 00h,0B5h, 14h,0B5h, 14h
		db	 00h, 00h, 2Ah, 02h, 2Ah, 02h
		db	 00h, 00h, 09h, 40h, 0Fh,0C0h
		db	 06h, 80h, 5Ah, 80h, 7Ah, 80h
		db	 20h, 00h, 55h, 00h, 55h, 30h
		db	 00h, 30h, 80h, 9Ch, 80h,0BCh
		db	 00h, 20h,0A2h, 8Eh,0A7h, 9Eh
		db	 05h, 10h, 4Eh, 8Ah, 5Eh, 8Ah
		db	 10h, 00h,0B5h, 00h,0B5h,0FEh
		db	 00h, 00h, 28h, 00h, 28h,0FEh
		db	 00h, 02h, 34h, 40h,0FEh, 00h
		db	 01h, 07h, 10h, 02h,0FEh, 00h
		db	 01h,0E0h, 00h, 40h, 00h, 00h
		db	 0Eh, 34h, 04h, 20h, 00h, 00h
		db	 34h, 0Dh, 20h,0FEh, 00h, 00h
		db	0D0h, 06h, 00h, 04h, 00h, 00h
		db	 40h, 03h,0FEh, 00h, 01h,0A0h
		db	 01h,0FEh, 00h, 01h, 1Dh,0FEh
		db	 00h, 02h, 0Ah,0FEh, 00h, 02h
		db	 14h,0FEh, 00h, 08h, 04h,0FEh
		db	 00h, 08h, 01h, 80h,0FEh, 00h
		db	 02h, 80h,0FEh, 00h, 01h, 40h
		db	 24h,0FEh, 00h, 01h, 01h, 20h
		db	0FEh, 00h, 02h, 04h,0FEh, 00h
		db	 01h, 20h, 20h,0FEh, 00h, 02h
		db	 04h,0FEh, 00h, 01h, 21h, 20h
		db	0FEh, 00h, 02h, 04h,0FEh, 00h
		db	 01h, 20h, 40h,0FEh, 00h, 01h
		db	 29h, 6Ch, 08h, 24h, 00h, 00h
		db	 24h, 8Eh, 00h, 02h, 00h, 00h
		db	 4Dh, 6Ch, 08h, 24h, 00h, 00h
		db	 20h, 86h, 00h, 02h, 00h, 00h
		db	 69h, 4Ch, 08h, 04h, 00h, 00h
		db	 64h,0CCh, 00h, 40h, 00h, 00h
		db	 21h, 6Dh, 00h, 21h, 00h, 00h
		db	 24h, 8Eh, 00h, 02h, 00h, 00h
		db	 4Fh, 72h, 03h, 40h, 00h, 00h
		db	0DAh,0DBh, 40h, 82h, 00h, 00h
		db	 4Eh, 72h, 02h, 40h, 00h, 00h
		db	0D6h,0FBh, 44h,0A2h, 00h, 00h
		db	 4Fh, 72h, 03h, 40h, 00h, 00h
		db	0DEh,0DBh, 44h, 82h, 00h, 00h
		db	 45h, 32h, 01h,0FEh, 00h, 00h
		db	0DEh,0FBh, 44h,0A2h, 00h, 00h
		db	 36h, 94h, 24h, 10h, 00h, 00h
		db	 71h, 24h, 40h,0FEh, 00h, 00h
		db	 36h,0B2h, 24h, 10h, 00h, 00h
		db	 61h, 04h, 40h,0FEh, 00h, 00h
		db	 32h, 96h, 20h, 10h, 00h, 00h
		db	 33h, 26h, 02h,0FEh, 00h, 00h
		db	0B6h, 84h, 84h,0FEh, 00h, 00h
		db	 71h, 24h, 40h,0FEh, 00h, 00h
		db	 24h, 02h,0FEh, 00h, 01h, 04h
		db	 80h,0FEh, 00h, 01h, 20h,0FEh
		db	 00h, 02h, 04h, 04h,0FEh, 00h
		db	 01h, 20h,0FEh, 00h, 02h, 04h
		db	 84h,0FEh, 00h, 01h, 20h,0FEh
		db	 00h, 02h, 02h, 04h,0FEh, 00h
		db	 01h,0B6h, 95h, 24h, 10h, 00h
		db	 00h,0A0h, 02h,0FEh, 00h, 01h
		db	 40h, 40h,0FEh, 00h, 02h, 24h
		db	0FEh, 00h, 01h, 40h, 22h, 00h
		db	 20h,0FEh, 00h, 00h, 26h,0FEh
		db	 00h, 01h, 41h, 26h, 00h, 04h
		db	 00h, 00h, 01h, 06h, 00h, 04h
		db	0FEh, 00h, 00h, 06h,0FEh, 00h
		db	 01h, 41h, 22h,0FEh, 00h, 01h
		db	 01h, 26h, 00h, 04h, 00h, 00h
		db	 42h, 22h, 00h, 20h, 00h, 00h
		db	 20h, 2Ch, 00h, 08h, 00h, 00h
		db	 11h, 51h, 01h, 10h, 00h, 00h
		db	 80h,0FEh, 00h, 02h, 36h, 95h
		db	 24h, 10h,0FEh, 00h, 05h,0ABh
		db	0EAh,0FEh, 00h, 0Eh,0D0h,0FEh
		db	 00h, 08h, 01h,0FEh, 00h, 0Dh
		db	 57h,0D5h,0FEh, 00h, 0Dh, 0Bh
		db	 2Ah,0FEh, 00h, 07h,0A8h, 8Bh
		db	0FEh, 00h, 08h, 01h,0FEh, 00h
		db	 01h, 45h, 3Fh,0FEh, 00h, 01h
		db	 69h, 8Ah,0FEh, 00h, 02h, 4Ch
		db	0FEh, 00h, 02h, 03h,0FEh, 00h
		db	 07h,0A5h, 30h,0FEh, 00h, 07h
		db	 50h, 24h,0FEh, 00h, 01h,0A0h
		db	 20h,0FEh, 00h, 01h, 48h, 04h
		db	0FEh, 00h, 01h, 94h, 20h,0FEh
		db	 00h, 01h, 44h, 04h,0FEh, 00h
		db	 01h, 24h, 20h,0FEh, 00h, 01h
		db	 14h, 04h,0FEh, 00h, 01h, 10h
		db	 40h,0FEh, 00h, 01h, 24h, 0Ah
		db	0FEh, 00h, 01h, 04h, 05h,0FEh
		db	 00h, 01h, 20h, 12h,0FEh, 00h
		db	 01h, 04h, 29h,0FEh, 00h, 01h
		db	 20h, 22h,0FEh, 00h, 01h, 04h
		db	 24h,0FEh, 00h, 01h, 20h, 28h
		db	0FEh, 00h, 01h, 02h, 08h,0FEh
		db	 00h, 01h, 80h,0FEh, 00h, 02h
data_4		dw	0A2FCh
		db	0FEh, 00h, 01h, 51h, 96h,0FEh
		db	 00h, 01h, 32h,0FEh, 00h, 02h
		db	0C0h,0FEh, 00h, 08h, 0Ch,0A5h
		db	0FEh, 00h, 0Dh, 57h,0D5h,0FEh
		db	 00h, 0Dh, 0Bh,0FEh, 00h, 08h
		db	 80h,0FEh, 00h, 09h, 03h, 00h
		db	 02h,0FEh, 00h, 00h, 0Dh, 00h
		db	 08h,0FEh, 00h, 00h, 36h, 00h
		db	 20h, 00h, 02h, 00h,0DAh, 00h
		db	 10h, 00h, 00h, 03h, 60h, 02h
		db	 00h, 00h, 10h, 0Dh, 92h, 01h
		db	0FEh, 00h, 00h, 36h, 08h, 24h
		db	 00h, 00h, 82h,0D0h,0A2h,0FEh
		db	 00h, 01h,0C0h, 00h, 40h,0FEh
		db	 00h, 00h,0B0h, 00h, 10h,0FEh
		db	 00h, 00h, 6Ch, 00h, 04h, 00h
		db	 40h, 00h, 5Bh, 00h, 08h,0FEh
		db	 00h, 00h, 06h,0C0h, 00h, 40h
		db	 08h, 00h, 49h,0B0h, 00h, 80h
		db	 00h, 00h, 10h, 6Ch, 00h, 24h
		db	 41h, 00h, 45h, 0Bh, 00h, 00h
		db	 20h,0FEh, 00h, 01h, 40h, 18h
		db	0FEh, 00h, 00h, 08h, 80h, 1Dh
		db	0FEh, 00h, 00h, 05h, 00h, 0Eh
		db	 40h, 00h, 40h, 02h, 40h, 07h
		db	 10h, 00h, 00h, 21h, 10h, 1Bh
		db	 80h, 01h, 00h, 58h, 88h,0F3h
		db	 94h, 10h, 10h,0F0h, 94h, 47h
		db	0FEh, 00h, 00h, 41h, 20h, 2Dh
		db	 18h, 00h, 08h, 21h, 58h, 18h
		db	 12h,0FEh, 00h, 00h, 92h, 15h
		db	 10h, 00h, 00h, 0Dh, 10h, 0Eh
		db	 44h, 04h, 40h, 06h, 44h, 05h
		db	 10h, 00h, 00h, 23h, 10h, 1Ah
		db	 80h, 00h, 00h, 59h, 88h,0F3h
		db	 94h, 12h, 10h,0F2h, 94h, 47h
		db	0C0h, 00h, 00h, 45h,0E0h, 2Dh
		db	 18h, 00h, 08h, 21h, 58h, 18h
		db	 12h,0FEh, 00h, 00h, 92h, 1Dh
		db	 10h, 00h, 00h, 05h, 10h,0CEh
		db	 44h,0C4h, 40h, 06h, 44h, 85h
		db	 52h, 80h, 42h, 23h, 10h, 1Ah
		db	 81h, 00h, 01h, 59h, 88h,0F3h
		db	 92h, 12h, 12h,0F2h, 90h, 4Dh
		db	0C7h, 0Ch, 07h, 41h,0E0h, 09h
		db	 50h, 0Fh,0D0h, 06h, 80h, 5Ah
		db	 82h, 7Ah, 86h, 20h, 04h, 55h
		db	 02h, 55h, 33h, 00h, 31h, 80h
		db	 9Ch, 80h,0BCh, 00h, 20h,0A2h
		db	0AEh,0A7h,0BEh, 05h, 10h, 4Eh
		db	0AAh, 5Eh,0AAh, 10h, 00h,0B5h
		db	 14h,0B5h, 14h, 00h, 00h, 2Ah
		db	 02h, 2Ah, 02h,0FEh, 00h, 05h
		db	 01h, 00h, 01h,0FEh, 00h, 00h
		db	 08h, 20h, 08h, 20h, 00h, 00h
		db	 80h, 94h, 80h, 94h, 00h, 00h
		db	0A2h, 8Ah,0A7h, 8Ah, 05h, 00h
		db	 4Eh, 9Ch, 5Eh, 9Ch, 10h, 00h
		db	0B5h, 3Ah,0B5h, 3Ah, 00h, 00h
		db	 2Ah, 50h, 2Ah, 50h,0FEh, 00h
		db	 01h,0CAh,0AAh,0C0h, 00h, 00h
		db	 08h,0F4h,0F0h,0D0h, 48h, 00h
		db	 04h,0FBh,0F9h,0A8h, 04h, 00h
		db	 04h,0E9h,0F8h,0C1h, 54h, 00h
		db	 04h,0F8h
		db	0F9h,0A8h,0ACh, 00h, 04h,0EBh
		db	0F9h,0C0h, 04h, 00h, 08h,0F3h
		db	0F0h,0A0h, 08h, 00h, 00h,0CAh
		db	0AAh,0C0h,0FEh, 00h, 00h,0AAh
		db	0AAh, 00h, 00h, 01h, 00h, 1Eh
		db	 07h, 01h, 00h, 22h, 08h,0CCh
		db	0F3h, 22h, 08h, 02h, 08h, 1Ch
		db	0F3h, 16h, 5Ah, 22h, 08h,0CCh
		db	0F3h, 2Ah,0A9h, 22h, 08h,0CCh
		db	0F3h, 22h, 08h, 01h, 00h, 1Eh
		db	 07h, 01h,0FEh, 00h, 00h,0AAh
		db	0AAh,0FEh, 00h, 01h,0AAh,0AAh
		db	 00h, 00h, 40h, 10h, 83h,0E0h
		db	 40h, 10h, 82h, 20h, 3Ch,0CFh
		db	 82h, 20h, 40h, 20h, 83h,0CFh
		db	0C2h,0AAh, 02h, 24h,0FCh,0C9h
		db	 56h, 65h, 82h, 21h, 3Ch,0CEh
		db	 82h, 21h, 40h, 10h, 81h,0E1h
		db	 40h, 10h, 00h, 00h,0AAh,0AAh
		db	0FEh, 00h, 01h,0AAh,0AAh, 00h
		db	 00h, 08h, 22h, 73h,0CCh, 08h
		db	 22h, 88h, 21h, 33h,0CEh, 88h
		db	 21h, 88h, 21h, 33h,0CEh,0AAh
		db	0ABh, 88h, 21h, 33h,0CEh, 99h
		db	 65h, 08h, 21h, 73h,0CEh, 08h
		db	 21h, 84h, 02h, 18h, 1Ch, 84h
		db	 02h, 00h, 00h,0AAh,0AAh,0FEh
		db	 00h, 01h,0AAh,0A3h, 00h, 02h
		db	 00h, 00h, 03h,0CFh, 00h, 04h
		db	 08h, 00h, 77h,0DFh, 08h, 0Ah
		db	 00h, 00h, 1Fh, 9Fh, 0Ah, 94h
		db	 00h, 00h, 7Fh, 9Fh, 55h, 0Ah
		db	 08h, 00h, 77h,0DFh, 08h, 14h
		db	 00h, 00h, 03h,0EFh, 00h, 8Ah
		db	 00h, 00h,0AAh,0A3h,0FEh, 00h
		db	 0Bh, 01h,0A4h, 00h, 58h, 00h
		db	 04h, 02h,0C1h, 05h, 3Eh, 00h
		db	 01h,0FFh,0FAh, 00h, 05h, 44h
		db	 02h, 02h,0D1h, 05h, 2Eh, 00h
		db	 01h, 00h,0A4h, 01h, 58h, 00h
		db	 04h,0FEh, 00h, 15h, 02h,0C2h
		db	 05h, 3Ch, 00h, 02h,0FDh, 55h
		db	 02h,0AAh, 44h, 55h, 02h,0AAh
		db	 05h, 54h, 02h,0AAh,0FEh, 00h
		db	 21h,0FFh, 1Ah, 00h,0E5h, 44h
		db	 02h,0FEh, 00h, 21h, 03h,0DAh
		db	 04h, 24h, 00h, 02h,0FDh, 75h
		db	 02h, 8Ah, 44h, 01h, 02h,0C2h
		db	 05h, 3Ch, 00h, 02h,0FEh, 00h
		db	 09h, 02h, 80h, 05h, 40h, 02h
		db	 80h, 00h,0A0h, 1Dh, 58h, 0Ah
		db	0A0h, 00h, 28h, 7Bh, 54h, 24h
		db	0A8h, 00h, 2Ah, 7Dh, 54h, 4Ah
		db	0AAh, 00h, 2Ah, 7Bh, 54h, 24h
		db	0AAh, 00h,0A8h, 7Dh, 54h, 32h
		db	0A8h, 03h, 40h, 14h, 90h, 07h
		db	 40h, 00h, 00h, 02h, 40h, 00h
		db	 00h

_376UNKN	endp

seg_a		ends



		end	start
