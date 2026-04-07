
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_389UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	32Eh

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_389UNKN	proc	far

start:
		pop	ds
		or	[bx+si],ax
;*		add	ch,al
		db	 00h,0C5h		;  Fixup - byte match
		add	dx,[bp+5]
		inc	dx
		add	cx,ss:data_4[bp+di]
		pop	ds
		add	[bp+si],al
		inc	byte ptr [bx+si]
		add	di,[bp+si+1]
		add	al,0D8h
		add	[bx+di],cx
		pop	cx
		add	al,ds:data_1e
		pop	es
		xor	ax,[bp+di]
		or	[bx+si],bh
		add	cx,[bx+di]
		cmp	ax,0F003h
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
;*		add	al,ah
		db	 00h,0E0h		;  Fixup - byte match
		db	 69h,0F0h, 00h,0E9h, 00h,0A0h
		db	0E6h, 58h,0F5h, 01h, 04h,0F0h
		db	 00h,0E9h, 00h,0E5h, 78h,0E2h
		db	 40h, 00h, 01h, 02h, 03h,0E5h
		db	 71h, 00h, 01h, 02h, 03h,0E5h
		db	 69h, 00h, 01h, 02h, 03h,0E5h
		db	 62h, 00h, 01h, 02h, 03h,0E5h
		db	 5Ah, 00h, 01h, 02h, 03h,0E5h
		db	 50h, 00h, 01h, 02h, 03h,0E5h
		db	 46h, 00h, 01h, 02h, 03h,0E5h
		db	 3Ch, 00h, 01h, 02h, 03h,0F6h
		db	 01h, 2Fh, 00h,0E5h, 6Eh,0E6h
		db	 6Bh, 14h, 11h, 15h, 11h,0F5h
		db	 01h, 02h,0F0h, 00h,0E9h, 00h
		db	0E5h, 78h,0E6h
		db	 58h, 26h, 33h, 32h
		db	13 dup (32h)
		db	'767F&322222'
		db	2, 2
		db	'2222222276X7f9:616:9616:91V1111:'
		db	'9;v6;;;;:V'
		db	 0Bh, 0Bh
		db	';;;:V:::9<6<96<'
		db	0F0h, 01h, 09h, 16h, 26h,0F6h
		db	 01h, 74h, 00h,0F5h, 01h, 04h
		db	0F0h, 01h,0E9h, 00h, 3Dh, 3Dh
		db	 4Dh, 4Dh, 4Dh, 06h, 4Dh, 4Dh
		db	 4Dh, 4Dh, 26h, 4Eh, 4Fh,0E9h
		db	 01h, 40h,0F6h, 01h,0E0h, 00h
		db	 51h, 51h,0FBh
data_4		dw	25h			; Data table (indexed access)
		db	0FFh,0F0h, 01h,0E9h, 01h,0A0h
		db	0F0h, 01h,0E9h, 01h,0F5h, 01h
		db	 18h,0F0h, 01h,0E9h, 01h,0E5h
		db	 50h,0E6h, 15h,0E2h
		db	'@bcdefghiq'
		db	0E6h, 76h,0E5h, 64h, 3Ah, 3Ah
		db	 3Ah, 3Ah, 3Ah, 3Ah,0E5h, 50h
		db	0E6h, 15h, 66h, 64h,0F6h, 01h
		db	 0Ah, 01h,0E6h, 03h,0E5h, 6Eh
		db	0F5h, 01h, 04h,0F0h, 01h,0E9h
		db	 01h
		db	'ebkflkfbgkflkd'
		db	0F6h, 01h, 38h, 01h,0F5h, 01h
		db	 02h,0F0h, 01h,0E9h, 01h,0E5h
		db	 50h,0E6h, 15h
		db	'bcdefghiq'
		db	0E6h, 76h,0E5h, 64h, 3Ah, 3Ah
		db	 3Ah, 3Ah, 3Ah, 3Ah,0E5h, 50h
		db	0E6h, 15h, 66h, 64h,0F6h, 01h
		db	 51h, 01h,0FBh, 03h, 01h,0FFh
		db	0F0h, 01h,0E9h, 01h,0A0h,0F0h
		db	 01h,0E9h, 01h,0E5h, 6Eh,0E6h
		db	 1Ch,0F5h, 01h, 18h,0F0h, 01h
		db	0E9h, 01h,0E2h, 40h, 6Dh, 6Eh
		db	 6Fh,0E9h, 02h, 60h,0F0h, 02h
		db	 01h, 12h, 03h, 14h, 15h, 16h
		db	 07h, 11h, 11h,0F6h, 01h, 8Ah
		db	 01h,0F5h, 01h, 04h,0F0h, 02h
		db	0E9h, 02h, 18h, 18h, 18h, 01h
		db	 03h, 11h, 18h, 18h, 18h, 11h
		db	 13h, 11h,0F6h, 01h,0A8h, 01h
		db	0F5h, 01h, 02h,0F0h, 02h,0E9h
		db	 02h, 13h, 14h, 12h, 10h, 01h
		db	 12h, 03h, 14h, 15h, 16h, 07h
		db	 11h, 11h,0F6h, 01h,0BFh, 01h
		db	0FBh, 7Fh, 01h,0FFh,0F0h, 02h
		db	0E9h, 02h,0A0h,0E1h, 14h, 40h
		db	0F0h, 02h,0E9h, 02h,0F5h, 01h
		db	 18h,0F0h, 02h,0E9h, 02h,0E5h
		db	 50h,0E6h, 15h,0E2h, 40h, 19h
		db	 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
		db	0E9h, 03h, 10h, 21h,0E6h, 76h
		db	0E5h, 64h, 32h, 32h, 32h, 32h
		db	 32h, 32h,0E5h, 50h,0E6h, 15h
		db	 13h, 14h,0F6h, 01h,0E7h, 01h
		db	0E6h, 03h,0E5h, 6Eh,0F5h, 01h
		db	 04h,0F0h, 02h,0E9h, 03h, 15h
		db	 16h, 17h, 13h, 18h, 17h, 13h
		db	 16h, 19h, 17h, 13h, 18h, 17h
		db	 14h,0F6h, 01h, 17h, 02h,0F5h
		db	 01h, 02h,0F0h, 02h,0E9h, 03h
		db	0E5h, 50h,0E6h, 15h, 16h, 1Ah
		db	 14h, 15h, 13h, 19h, 1Bh, 10h
		db	 21h,0E6h, 76h,0E5h, 64h, 32h
		db	 32h, 32h, 32h, 32h, 32h,0E5h
		db	 50h,0E6h, 15h, 13h, 14h,0F6h
		db	 01h, 30h, 02h,0FBh,0E0h, 01h
		db	0FFh,0F0h, 02h,0E9h, 03h,0F0h
		db	 02h,0E9h, 03h,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 6Ah, 4Ch, 5Dh, 5Ch
		db	 5Eh, 5Eh, 4Fh,0E9h, 04h
		db	'`QrSSTTe'
		db	0F5h, 01h, 06h,0F0h, 02h,0E9h
		db	 04h,0E5h, 7Fh,0E7h
		db	0Ah, 'TTSSeQrSSTTe'
		db	0F6h, 01h, 7Ah, 02h,0E5h, 7Fh
		db	0E7h
		db	0Ah, 'TTSSeQr'
		db	0E2h, 4Eh, 50h,0E2h, 6Ah, 53h
		db	 55h, 55h, 55h, 55h,0F5h, 01h
		db	 02h,0F0h, 02h,0E9h, 04h,0E5h
		db	 7Fh,0E7h
		db	0Ah, 'DVTSSeQrSSTTe'
		db	0F5h, 02h, 06h,0F0h, 02h,0E9h
		db	 04h,0E5h, 7Fh,0E7h
		db	0Ah, 'TTSSeQrSSTTe'
		db	0F6h, 02h,0C2h, 02h,0E5h, 7Fh
		db	0E7h
		db	0Ah, 'TTSSeQrSS'
		db	0F0h, 03h, 05h, 05h, 15h, 15h
		db	 15h,0F6h, 01h,0AAh, 02h,0F5h
loc_1:
		add	[si],ax
                           lock	add	bp,cx
		add	al,5
		add	ax,1515h
		adc	ax,1524h
		daa				; Decimal adjust
		and	al,15h
		adc	ax,0F618h
;*		add	bp,si
		db	 01h,0F5h		;  Fixup - byte match
		add	ah,ch
		jg	loc_1			; Jump if >
		or	dh,[si]
		push	ss
		adc	al,13h
		adc	sp,[di]
		adc	[bp+si+13h],ax
		adc	dx,[si]
		adc	al,25h			; '%'
		in	ax,7Fh			; port 7Fh ??I/O Non-standard
		out	0Ah,ax			; port 0Ah, DMA-1 mask reg bit
		adc	al,14h
		adc	dx,[bp+di]
		and	ax,4211h
		adc	dx,[bp+di]
		adc	al,14h
		and	ax,5DFBh
		add	bh,bh
                           lock	add	bp,cx
		add	al,0FFh
                           lock	add	bp,cx
		add	al,0FFh
                           lock	add	bp,cx
		add	al,0FFh
                           lock	add	bp,cx
		add	al,0FFh
		inc	bp
		inc	si
		dec	dx
		dec	cx
		aas				; Ascii adjust
		dec	bx
		or	byte ptr [si+4Fh],40h	; '@'
		inc	bx
		cmp	ax,563Eh
		pop	si
		pop	ax
		pop	bp
		add	byte ptr [bp+3Dh],45h	; 'E'
		db	'>C@B<GIL-+&', 27h, '(&-+234.F=E>'
		db	'C@B<'
		db	80h
		db	'GCE>FIL@=B$'
		db	'"*&,0)*$'
		db	'&"-'
		db	 80h, 03h, 03h, 60h, 5Fh, 0Ch
		db	0FFh, 06h, 06h, 48h,0FFh, 12h
		db	 12h, 24h,0FFh, 30h,0FFh, 0Ch
		db	 0Ch, 24h,0FFh, 06h,0FFh, 03h
		db	 03h, 06h, 06h, 60h,0FFh, 06h
		db	 05h, 12h,0FFh, 0Ch, 0Bh, 06h
		db	 05h, 12h,0FFh, 03h, 03h, 00h
		db	 01h, 06h, 01h, 0Ch, 01h, 12h
		db	 01h, 03h, 01h, 06h, 01h, 0Ch
		db	 01h, 00h, 01h, 12h, 01h, 04h
		db	 23h, 00h,0EBh, 00h, 37h, 01h
		db	 6Dh, 01h, 77h, 01h,0DDh, 01h
		db	0BAh, 02h, 80h, 03h,0EAh, 03h
		db	0E6h, 01h, 65h, 04h,0CEh, 04h
		db	 57h, 04h, 56h, 05h, 0Ch,0B0h
		db	 01h, 05h, 01h, 01h,0F0h, 00h
		db	0E0h, 2Dh, 80h,0D4h,0F5h, 10h
		db	0F0h, 00h,0E5h, 17h,0F5h, 21h
		db	0F0h, 00h, 0Ah, 0Bh,0E4h, 03h
		db	 02h,0E3h,0CEh,0F6h, 31h, 40h
		db	0F6h, 2Bh, 00h, 83h,0E5h, 27h
		db	0D4h, 14h, 1Bh,0E4h, 14h,0E3h
		db	 1Bh,0F5h, 08h,0F0h, 00h, 20h
		db	 80h,0D5h,0E5h, 17h
		db	 32h, 33h
		db	13 dup (33h)
		db	'505@ 233333'
		db	 03h, 03h, 33h
		db	7 dup (33h)
		db	 35h, 30h, 58h, 35h, 60h,0E3h
		db	'580;0850;085;P;;;;852p22228P'
		db	2, 2
		db	'2228P8885303503%P'
		db	 84h,0D4h,0E5h, 07h, 08h, 08h
		db	 38h, 38h, 38h,0F6h, 4Ch, 00h
		db	 80h,0E5h, 17h,0F5h, 10h,0F0h
		db	 00h,0D6h, 03h, 03h
		db	'333 33330;5:'
		db	0F6h,0BDh, 00h, 84h,0E5h, 07h
		db	0D4h
		db	'8(p8(0(('
		db	0F0h, 01h, 00h, 18h, 18h, 20h
		db	 38h, 38h, 18h, 18h, 18h,0FBh
		db	 23h, 00h,0F0h, 00h,0F5h, 60h
		db	0F0h, 00h, 85h,0E5h, 1Fh,0D3h
		db	';2:38571P'
		db	 86h,0E5h, 1Fh,0D3h, 0Ch, 0Ch
		db	 0Ch, 0Ch, 0Ch, 0Ch, 85h,0E5h
		db	 1Fh,0D3h, 38h, 3Ah,0F6h,0EFh
		db	 00h, 82h,0E5h, 1Fh,0D4h,0F5h
		db	 10h,0F0h, 00h, 33h, 3Bh,0E4h
		db	 32h,0E3h, 38h,0E4h, 35h, 32h
		db	0E3h, 38h, 3Bh, 35h,0E4h, 32h
		db	0E3h, 38h,0E4h, 35h, 32h,0E3h
		db	 3Ah,0F6h, 17h, 01h,0F5h, 68h
		db	0FBh,0EFh, 00h,0F0h, 00h, 81h
		db	0E5h, 0Fh,0D2h,0F0h, 00h,0F5h
		db	 60h,0F0h, 00h
		db	':834%3*8'
		db	0E4h, 33h, 34h, 25h,0E3h, 35h
		db	 35h,0F6h, 41h, 01h,0F5h, 10h
		db	0F0h, 00h
		db	';;;%*5;;;5:5'
		db	0F6h, 57h, 01h,0F5h, 68h,0FBh
		db	 41h, 01h,0F0h, 00h,0E1h, 04h
		db	0F0h, 01h, 40h,0FBh, 23h, 00h
		db	0F0h, 00h,0E1h, 04h,0F0h, 01h
		db	 40h,0F5h, 60h,0F0h, 01h, 85h
		db	0E5h, 37h,0D3h, 1Bh, 12h, 1Ah
		db	 13h, 18h, 15h, 17h, 11h, 50h
		db	 86h,0E5h, 2Fh,0D3h, 3Ch, 3Ch
		db	 3Ch, 3Ch, 3Ch, 3Ch, 85h,0E5h
		db	 37h,0D3h, 18h, 1Ah,0F6h, 80h
		db	 01h, 82h,0E5h, 2Fh,0D4h, 10h
		db	0F5h, 0Ch,0F0h, 01h, 13h, 1Bh
		db	0E4h, 12h,0E3h, 18h,0E4h, 15h
		db	 12h,0E3h, 18h, 1Bh, 15h,0E4h
		db	 12h,0E3h, 18h,0E4h, 15h, 12h
		db	0E3h, 1Ah,0F6h,0A9h, 01h, 13h
		db	 1Bh,0E4h, 12h,0E3h, 18h,0E4h
		db	 15h, 12h,0E3h, 18h, 1Bh, 15h
		db	0E4h, 12h,0E3h, 18h,0E4h, 15h
		db	 12h,0F5h, 68h,0FBh, 80h, 01h
		db	0F0h, 00h, 81h,0E5h, 2Fh,0D2h
		db	0FBh, 3Dh, 01h,0F0h, 00h,0CDh
		db	 00h,0CFh, 02h,0D0h, 02h,0CEh
		db	 05h,0D1h, 0Ah,0C3h,0F5h, 1Ch
		db	0F0h, 00h, 10h, 10h, 01h, 01h
		db	 38h, 18h, 10h, 30h, 24h, 01h
		db	 01h, 10h, 10h, 38h, 18h,0F6h
		db	0F5h, 01h, 10h, 10h, 01h, 01h
		db	 38h, 18h, 10h, 30h, 24h, 01h
		db	 01h, 18h, 18h, 18h, 18h,0F5h
		db	 09h,0F0h, 00h,0F5h, 1Ch,0F0h
		db	 00h, 10h, 10h, 01h, 01h, 38h
		db	 18h, 10h, 30h, 24h, 01h, 01h
		db	 10h, 10h, 38h, 18h,0F6h, 1Eh
		db	 02h, 10h, 10h, 01h, 01h, 38h
		db	 18h, 10h, 30h, 24h, 01h, 01h
		db	 38h, 06h, 38h, 06h, 18h, 18h
		db	 18h,0F6h, 1Ah, 42h,0C0h, 18h
		db	 18h
		db	'8', 0Ch, '8', 0Ch, '8', 0Ch, ' T'
		db	'8', 0Ch, '8', 0Ch, '8', 0Ch
		db	 18h, 18h, 38h, 0Ch, 38h, 0Ch
		db	 38h, 0Ch, 30h, 18h, 30h, 0Ch
		db	 30h, 18h, 30h, 18h
		db	 38h, 0Ch, 38h
data_7		db	0Ch
		db	 38h, 0Ch, 18h, 18h
		db	'8', 0Ch, '8', 0Ch, '8', 0Ch, ' T'
		db	'8', 0Ch, '8', 0Ch, '8', 0Ch
		db	 18h, 18h, 38h, 0Ch, 38h, 0Ch
		db	 38h, 0Ch, 30h, 18h, 30h, 0Ch
		db	 30h, 18h, 30h, 18h, 38h, 0Ch
		db	 38h, 0Ch, 38h, 0Ch,0C3h, 18h
		db	 18h, 01h, 01h, 38h, 18h, 10h
		db	 30h, 24h, 01h, 01h, 18h, 18h
		db	 38h, 18h, 18h, 10h, 19h, 01h
		db	 38h, 18h, 10h, 10h, 18h, 18h
		db	 01h, 01h, 38h, 06h, 38h, 06h
		db	 18h, 18h, 18h,0FBh,0E6h, 01h
		db	0F0h, 00h,0E0h, 2Dh, 80h,0D3h
		db	0F5h, 10h,0F0h, 00h,0E5h, 0Fh
		db	0F5h, 21h,0F0h, 00h, 0Ah, 0Bh
		db	0E4h, 03h, 02h,0E3h,0CDh,0F6h
		db	0C8h, 42h,0F6h,0C2h, 02h, 81h
		db	0E5h, 0Fh,0D4h, 14h, 1Bh,0E4h
		db	 14h,0E3h, 1Bh,0F5h, 08h,0F0h
		db	 00h, 20h, 80h,0D4h,0E5h, 17h
		db	 32h, 33h
		db	13 dup (33h)
		db	'505@ 233333'
		db	 03h, 03h, 33h
		db	7 dup (33h)
		db	 35h, 30h, 58h, 35h, 60h,0E3h
		db	'580;0850;085;P;;;;852p22228P'
		db	2, 2
		db	'2228P8885303503%P'
		db	 82h,0E5h, 07h, 08h, 08h, 38h
		db	 38h, 38h,0F6h,0E3h, 02h, 80h
		db	0E5h, 17h,0F5h, 10h,0F0h, 00h
		db	0D5h, 03h, 03h
		db	'333 33330;5:'
		db	0F6h, 53h, 03h, 82h,0E5h, 07h
		db	'8(p8(0(('
		db	0F0h, 01h, 00h, 18h, 18h, 20h
		db	 38h, 38h, 18h, 18h, 18h,0FBh
		db	0BAh, 02h,0F0h, 00h,0E1h, 10h
		db	0F5h, 1Ch,0F0h, 00h,0FCh, 19h
		db	 04h,0F6h, 86h, 03h, 83h,0E5h
		db	 17h,0D2h
		db	';2:38572'
		db	 82h,0E5h, 07h, 28h, 84h,0E5h
		db	 27h,0D5h, 0Ch, 0Ch, 0Ch, 0Ch
		db	 82h,0E5h, 07h, 38h, 38h, 38h
		db	 38h,0F5h, 40h,0F0h, 00h,0FCh
		db	 19h, 04h,0F6h,0AFh, 03h,0E1h
		db	 00h,0F5h, 10h,0F0h, 00h, 82h
		db	0E5h, 07h, 38h, 85h,0E5h, 17h
		db	0D4h, 3Bh,0E4h, 32h,0E3h, 38h
		db	0E4h, 35h, 32h,0E3h, 38h, 3Bh
		db	 35h,0E4h, 32h,0E3h, 38h,0E4h
		db	 35h, 32h, 82h,0E5h, 07h, 38h
		db	0F6h,0BBh, 03h,0E1h, 10h,0FCh
		db	 19h, 04h,0FCh, 19h, 04h,0FBh
		db	 80h, 03h,0F0h, 00h,0E5h, 07h
		db	0DBh,0F5h, 60h,0F0h, 00h,0FCh
		db	 3Dh, 04h,0F6h,0F1h, 03h,0F5h
		db	 10h,0F0h, 00h, 86h,0D1h, 3Bh
		db	 3Bh, 3Bh, 87h, 25h, 2Ah, 86h
		db	 35h, 3Bh, 3Bh, 3Bh, 35h, 3Ah
		db	 35h,0F6h,0FBh, 03h,0FCh, 3Dh
		db	 04h,0FCh, 3Dh, 04h,0FBh,0EAh
		db	 03h,0F0h, 00h, 83h,0E5h, 17h
		db	0D2h
		db	';2:38572'
		db	 82h,0E5h, 07h, 28h, 30h, 84h
		db	0E5h, 27h,0D5h, 0Ch, 0Ch, 0Ch
		db	 0Ch, 0Ch, 0Ch, 83h,0E5h, 17h
		db	0D2h, 38h, 3Ah,0FEh,0F0h, 00h
		db	 86h,0D1h, 3Ah, 38h, 33h, 34h
		db	 87h, 25h, 86h, 33h, 87h, 2Ah
		db	 86h, 38h,0E4h, 33h, 34h, 87h
		db	 25h,0E3h, 86h, 35h, 35h,0FEh
		db	 06h,0C0h, 18h, 0Ch, 90h, 24h
		db	 48h, 6Ch, 30h, 0Ch, 18h, 06h
		db	 01h, 24h, 20h, 10h, 10h, 07h
		db	 07h, 01h, 51h, 41h, 1Dh, 00h
		db	 40h, 81h,0F4h,0F6h, 0Eh, 00h
		db	 00h, 00h, 02h, 02h, 01h, 20h
		db	 21h, 10h, 00h,0F5h,0F4h, 54h
		db	 37h, 02h, 00h, 00h, 00h, 02h
		db	 02h, 01h, 24h, 21h, 9Ch, 00h
		db	0F3h,0F3h, 38h, 88h, 00h, 01h
		db	 1Fh, 1Fh, 09h, 09h, 01h,0A1h
		db	 64h, 00h, 00h,0F0h,0F0h, 08h
		db	 08h, 01h, 01h, 00h,0FFh,0FFh
		db	0FFh, 81h, 08h, 01h, 02h, 00h
		db	0F4h,0F8h, 38h, 58h, 0Eh, 00h
		db	 00h, 00h, 02h, 02h, 01h, 61h
		db	0A2h, 00h, 00h, 88h, 87h, 04h
		db	 0Ah, 00h, 00h, 00h,0FFh,0FFh
		db	0FFh, 81h, 0Fh, 0Fh, 0Fh, 00h
		db	0F8h,0F7h,0F8h,0F8h, 0Eh, 0Eh
		db	 15h, 15h, 05h, 05h, 01h, 00h
		db	 01h, 03h, 17h, 09h, 5Fh, 11h
		db	 0Fh, 38h, 00h, 05h, 01h, 50h
		db	 50h, 06h, 06h, 01h, 00h, 01h
		db	 05h, 09h, 01h, 01h,0F1h, 0Fh
		db	 38h, 00h, 04h, 01h,0E5h, 47h
		db	 06h, 02h, 01h, 00h, 02h, 09h
		db	 38h, 09h, 5Fh, 01h, 2Fh, 87h
		db	 00h, 04h, 00h, 00h, 00h, 02h
		db	 02h, 81h, 00h, 01h, 07h, 09h
		db	 07h, 46h, 51h, 0Fh, 38h, 00h
		db	 03h, 00h, 33h, 33h, 02h, 02h
		db	 01h, 00h, 01h, 19h, 29h, 07h
		db	 1Dh, 81h, 0Fh, 00h, 00h, 04h
		db	 00h, 00h, 00h, 02h, 02h, 81h
		db	 00h, 01h, 17h, 03h, 05h, 6Eh
		db	 32h, 1Fh, 38h, 00h, 04h, 00h
		db	 00h, 00h, 02h, 02h, 81h, 00h
		db	 01h, 01h, 01h, 07h, 99h, 01h
		db	 1Eh, 38h, 00h, 05h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 01h, 02h
		db	0D0h, 01h, 07h, 99h, 01h,0FFh
		db	 38h, 00h, 05h

_389UNKN	endp

seg_a		ends



		end	start
