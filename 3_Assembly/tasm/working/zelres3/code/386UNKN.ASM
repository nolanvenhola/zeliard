
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_386UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	0E302h			;*
data_9e		equ	40E2h			;*
data_10e	equ	73E5h			;*
data_11e	equ	7AFCh			;*
data_12e	equ	0F541h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_386UNKN	proc	far

start:
		retf
			                        ;* No entry point to code
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	[bx+si],al
		rol	word ptr ds:[8F6h],1	; Rotate
		adc	data_7,ax
		add	[bx],bx
		add	[bp+si],al
		rol	byte ptr [bx+si],1	; Rotate
		add	di,data_6[si]
		db	 66h, 02h, 09h,0B6h, 03h, 06h
		db	0FDh, 05h, 07h, 02h, 06h, 08h
		db	 07h, 06h, 09h, 0Ch, 06h,0F0h
		db	 00h,0E9h, 00h,0E0h, 7Dh,0E5h
		db	 7Fh,0A0h,0E6h, 03h,0E2h, 40h
		db	 00h, 11h, 21h, 02h, 33h, 21h
		db	 04h, 15h, 25h, 36h, 47h, 48h
		db	 29h, 5Ah,0F0h, 00h,0E9h, 00h
		db	0F5h, 01h, 02h,0F0h, 00h,0E9h
		db	 00h,0E6h, 59h,0E5h, 7Fh,0A0h
		db	'(*+\+*k+*(Z(W', 8
		db	16h
		db	'&y(*+\+*k+*(Z(W', 0Ah, '+'
		db	 18h, 38h, 59h, 47h, 4Dh, 46h
		db	 4Eh,0F0h, 01h, 0Fh, 1Fh
		db	')4?>?DCUe'
		db	0E5h, 6Eh,0A0h,0E6h, 31h, 48h
		db	 7Ah, 79h, 77h, 79h,0F0h, 02h
		db	 08h, 18h, 2Ah, 2Bh, 1Ah, 17h
		db	 38h, 39h,0F6h, 01h, 41h, 00h
		db	0E6h, 59h,0E5h, 7Dh,0A0h, 4Bh
		db	 2Ch, 09h,0E9h, 01h, 40h, 21h
		db	 20h, 02h, 23h, 02h, 44h, 43h
		db	 00h, 50h, 30h, 44h, 23h, 02h
		db	 40h, 21h, 20h, 02h, 23h, 02h
		db	 44h, 45h, 15h, 60h, 70h,0F0h
		db	 03h, 06h, 07h, 04h, 06h, 14h
		db	 28h, 38h, 48h, 06h, 07h, 04h
		db	 06h, 13h, 55h, 60h, 40h, 52h
		db	0FBh, 3Ah, 00h,0FFh,0F0h, 03h
		db	0E9h, 01h, 98h,0E5h, 78h,0E6h
		db	 31h,0E2h
		db	'@', 9, 9, 'R', 9, 9, 'R', 9, 9, '2'
		db	0Ah, 0Ah, 'R', 0Ah, 0Ah, 'R', 0Ah
		db	0Ah, '2'
		db	 0Bh, 0Bh, 52h, 0Bh, 0Bh, 52h
		db	 0Bh, 0Bh
		db	'2', 0Ah, 0Ah, 'R', 0Ah, 0Ah, 'R', 0Ah
		db	0Ah, '2'
loc_1:
                           lock	add	bp,cx
;*		add	bp,si
		db	 01h,0F5h		;  Fixup - byte match
		add	[bp+si],ax
                           lock	add	bp,cx
		add	ds:data_10e[bx+si],bx
		out	31h,al			; port 31h ??I/O Non-standard
		cmc				; Complement carry
		add	al,[bp+di]
                           lock	add	bp,cx
		add	[bx+di],cx
		or	[bp+si],ax
		or	cx,[bp+di]

locloop_3:
		add	cl,[si]
		or	al,22h			; '"'
		or	ax,20Dh
		or	cx,[bp+di]
		add	cl,[si]
		jc	$+0Bh			; Jump if carry Set
		jc	loc_4			; Jump if carry Set
		test	byte ptr [bp+si],12h
		add	[bx+di],cx
		or	[bp+si],ax
		or	cx,[bp+di]
		add	cl,[si]
		or	al,22h			; '"'
		or	ax,20Dh
		or	cx,[bp+di]
		add	cl,[si]
		jc	$+0Bh			; Jump if carry Set
		add	cl,byte ptr ds:[0D0Fh]
		or	al,0F0h
		add	al,0Ch
		sbb	al,12h
		add	al,[bp+si]
		jmp	$+2005h
			                        ;* No entry point to code
		xor	[bp+si],si
		inc	bx
		inc	bx
		xor	dl,[bx+si+60h]
		xor	[si],si
		db	 61h, 63h, 74h, 02h
loc_4:
		test	byte ptr [bx+di],6
;*		add	bp,si
		db	 01h,0F5h		;  Fixup - byte match
		add	[bp+si],ax
                           lock	add	al,0E9h
		add	al,[bp+si]
		add	al,[bp+si]
		cbw				; Convrt byte to word
		in	ax,73h			; port 73h ??I/O Non-standard
		out	31h,al			; port 31h ??I/O Non-standard
		inc	sp
		inc	sp
		inc	sp
		inc	sp
		inc	sp
		inc	dx
		inc	bx
		inc	bx
		inc	bx
		inc	bx
		inc	bx
		inc	dx
		inc	bp
		inc	bp
		inc	bp
		inc	bp
		test	byte ptr [bx+di],63h	; 'c'
		add	[bp+46h],ax
		db	'FFFB@@@@@bB@@@@@BFFFFFbBGGGGGBGG'
		db	'GGGBGGGGCHCHCHCHC"B'
		db	0FBh,0FFh, 00h,0FFh,0F0h, 04h
		db	0E9h, 02h, 02h, 02h, 02h, 02h
		db	0F0h, 04h,0E9h
loc_6:
		add	dh,ch
		add	[bp+si],ax
                           lock	add	al,0E9h
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		add	al,[bp+si]
		out	0Bh,al			; port 0Bh, DMA-1 mode reg
		in	ax,78h			; port 78h ??I/O Non-standard
		mov	al,ds:data_9e
		inc	cx
		inc	bp
		dec	cx
		dec	dx
		inc	cx
		inc	bp
		dec	cx
		dec	dx
		inc	cx
		inc	bp
		dec	cx
		dec	dx
		inc	cx
		dec	bx
		dec	cx
		dec	dx
		cmc				; Complement carry
		add	al,[bp+si]
                           lock	add	al,0E9h
		add	ah,ch
		jnc	$+45h			; Jump if carry=0
		dec	cx
		inc	cx
		inc	sp
		dec	sp
		inc	dx
		inc	bx
		dec	cx
		inc	cx
		inc	sp
		dec	sp
                           lock	add	ax,1202h
		test	byte ptr [bp+si],0F2h
		add	[bp+si],sp
		and	ah,dh
		or	sp,bp
;*		js	loc_5			;*Jump if sign=1
		db	 78h,0A0h		;  Fixup - byte match
		cmc				; Complement carry
		add	al,[bp+si]
                           lock	add	ax,2E9h
		xor	cx,[bx+di+41h]
		xor	al,41h			; 'A'
		dec	cx
		xor	cx,[bx+di+41h]
		xor	al,12h
		test	byte ptr [bp+si],15h
		add	dh,dh
;*		add	bx,cx
		db	 01h,0CBh		;  Fixup - byte match
;*		add	bp,sp
		db	 01h,0E5h		;  Fixup - byte match
		js	loc_6			; Jump if sign=1
		out	59h,al			; port 59h ??I/O Non-standard
		push	sp
		cmp	al,12h
		push	si
		aaa				; Ascii adjust
		adc	bh,ss:[si]
		adc	dl,[si+5Ch]
		db	 6Ch, 7Ch,0F0h, 06h, 0Ch, 14h
		db	 2Ch, 22h, 16h, 27h, 26h, 22h
		db	 2Ch, 22h, 14h, 1Ch, 3Ch, 4Ch
		db	 5Ch, 60h, 61h, 64h, 60h, 14h
		db	 34h, 44h, 54h, 60h, 61h, 64h
		db	 60h, 1Ch, 78h,0F0h, 07h, 08h
		db	 18h, 22h,0FBh,0C4h, 01h,0FFh
		db	0F0h, 07h,0E9h, 02h,0A0h,0E5h
		db	 7Dh,0E6h, 6Ah,0E2h, 40h, 3Dh
		db	 4Eh, 4Dh, 3Fh,0E9h, 03h
		db	40h
		db	'1BAA031BA4@1BAA301BA4@1BAA031BA4'
		db	'@1EAFAC@B'
		db	0F0h, 07h,0E9h, 03h,0F5h, 01h
		db	 02h,0F0h, 07h,0E9h, 03h,0F5h
		db	 02h, 02h,0F0h, 07h,0E9h, 03h
		db	31h
		db	'BA4@1BAA031BA4@1BAA301BA4@1BAA03'
		db	'1BA4@1EAFAC@B'
		db	0F6h, 02h,0AFh, 02h,0F5h, 02h
		db	 02h,0F0h, 07h,0E9h, 03h
		db	'7BG4@7GBG40'
		db	0F6h, 02h,0E8h, 02h
		db	'1BA4@1BAA031BA4@1BAA30'
		db	0F5h, 02h, 02h,0F0h, 07h,0E9h
		db	 03h
		db	'7BG4@7GBG40'
		db	0F6h, 02h, 14h, 03h
		db	'1BA4@1BAA031BA4@1EHFHC@B'
		db	0F6h, 01h,0A8h, 02h,0F5h, 01h
		db	 02h,0F0h, 07h,0E9h, 03h
		db	'7BG@DD7GBD@ID@7BG@DD7GBD@IDG'
		db	0F5h, 02h, 02h,0F0h, 07h,0E9h
		db	 03h
		db	':@I4I:J@IAIDA'
		db	0F6h, 02h, 69h, 03h,0F6h, 01h
		db	 46h, 03h,0F5h, 01h, 02h,0F0h
		db	 07h,0E9h, 03h
		db	';@K9D;K@K94'
		db	0F6h, 01h, 85h, 03h
		db	':BJ0D:JBJ00:BJ@@DIJBH@HDHI'
		db	0FBh,0A1h, 02h,0FFh,0F0h, 07h
		db	0E9h, 03h,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 4Eh, 5Ch, 5Ch,0E2h, 6Ah
		db	 5Dh, 6Eh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh,0E2h, 4Eh
		db	 6Ch, 5Ch,0E2h, 6Ah, 6Dh,0E2h
		db	 4Eh, 6Ch, 6Ch, 6Ch, 6Ch,0E2h
		db	 6Ah, 7Bh, 5Dh, 5Bh,0E2h, 5Ch
		db	 7Fh,0E2h, 4Eh, 5Ch,0E2h, 6Ah
		db	 6Dh,0E2h, 4Eh, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh,0E2h, 4Eh, 6Ch
		db	 5Ch,0E2h, 6Ah, 6Dh,0E2h
data_6		dw	6C4Eh			; Data table (indexed access)
		db	 6Ch, 6Ch, 6Ch,0E2h, 6Ah, 7Bh
		db	 5Dh, 6Bh, 6Bh,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 4Eh, 5Ch, 5Ch,0E2h
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh,0E2h, 4Eh
		db	 6Ch, 5Ch,0E2h, 6Ah, 6Dh,0E2h
		db	 4Eh, 6Ch, 6Ch, 6Ch, 6Ch,0E2h
		db	 6Ah, 7Bh, 5Dh, 5Bh,0E2h, 5Ch
		db	 7Fh,0E2h, 4Eh, 5Ch,0E2h, 6Ah
		db	 6Dh,0E2h, 4Eh, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh,0E2h, 4Eh, 6Ch
		db	 5Ch,0E2h, 6Ah, 6Dh,0E2h, 4Eh
		db	 6Ch, 6Ch, 6Ch, 6Ch,0E2h, 6Ah
		db	 7Bh, 5Dh, 6Bh, 6Bh,0F0h, 07h
		db	0E9h, 03h,0F5h, 01h, 08h,0F0h
		db	 07h,0E9h, 03h,0E5h, 7Fh,0E7h
		db	 0Ah,0E2h, 4Eh, 5Ch, 5Ch,0E2h
		db	 6Ah, 5Dh, 6Eh,0E2h, 4Eh, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh,0E2h
		db	 4Eh, 6Ch, 5Ch,0E2h, 6Ah, 6Dh
		db	0E2h, 4Eh, 6Ch, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh, 5Dh, 5Bh,0E2h
		db	 5Ch, 7Fh,0E2h, 4Eh, 5Ch,0E2h
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh,0E2h, 4Eh
		db	 6Ch, 5Ch,0E2h, 6Ah, 6Dh,0E2h
		db	 4Eh, 6Ch, 6Ch, 6Ch, 6Ch,0E2h
		db	 6Ah, 7Bh, 5Dh, 6Bh, 6Bh,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 4Eh, 5Ch
		db	 5Ch,0E2h, 6Ah, 6Dh,0E2h, 4Eh
		db	 6Ch, 6Ch, 6Ch,0E2h, 6Ah, 7Bh
		db	0E2h, 4Eh, 6Ch, 5Ch,0E2h, 6Ah
		db	 6Dh,0E2h, 4Eh, 6Ch, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh, 5Dh, 5Bh
		db	0E2h, 5Ch, 7Fh,0E2h, 4Eh, 5Ch
		db	0E2h, 6Ah, 6Dh,0E2h, 4Eh, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh,0E2h
		db	 4Eh, 6Ch, 5Ch,0E2h, 6Ah, 6Dh
		db	0E2h, 4Eh, 6Ch, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh, 5Dh, 6Bh, 6Bh
		db	0F6h, 01h, 54h, 04h,0F5h, 01h
		db	 02h,0F0h, 07h,0E9h, 03h,0E5h
		db	 7Fh,0E7h, 0Ah,0E2h, 4Eh, 5Ch
		db	 5Ch,0E2h, 6Ah, 5Dh, 6Eh,0E2h
		db	 4Eh, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh,0E2h
		db	 4Eh, 6Ch, 5Ch,0E2h
loc_7:
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch
loc_8:
		db	 6Ch, 6Ch, 6Ch,0E2h, 6Ah, 7Bh
		db	 5Dh, 5Bh,0E2h, 5Ch, 7Fh,0E2h
		db	 4Eh, 5Ch,0E2h, 6Ah, 6Dh,0E2h
		db	 4Eh, 6Ch, 6Ch, 6Ch,0E2h, 6Ah
		db	 7Bh,0E2h, 4Eh, 6Ch, 5Ch,0E2h
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh, 5Dh
		db	 6Bh, 6Bh,0E5h, 7Fh,0E7h, 0Ah
		db	0E2h, 4Eh, 5Ch, 5Ch,0E2h, 6Ah
		db	 6Dh,0E2h, 4Eh, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh,0E2h, 4Eh, 6Ch
		db	 5Ch,0E2h
		db	6Ah
loc_9:
		db	 6Dh,0E2h, 4Eh, 6Ch, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh, 5Dh, 5Bh
		db	0E2h, 5Ch, 7Fh,0E2h, 4Eh, 5Ch
		db	0E2h, 6Ah, 6Dh,0E2h, 4Eh, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh,0E2h
		db	 4Eh, 6Ch, 5Ch,0E2h, 6Ah, 6Dh
		db	0E2h, 4Eh, 6Ch, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 6Bh, 6Bh, 67h, 6Dh
		db	0F6h, 01h,0F2h, 04h,0E2h, 4Eh
		db	 5Ch,0E2h, 6Ah, 5Dh, 6Eh,0E2h
		db	 4Eh, 6Ch, 6Ch, 6Ch,0E2h, 6Ah
		db	 7Bh,0E2h, 4Eh, 6Ch, 5Ch,0E2h
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh, 5Dh
		db	 6Bh, 6Bh,0F5h, 01h, 02h,0F0h
		db	 07h,0E9h, 03h,0E2h, 4Eh, 5Ch
		db	0E2h, 6Ah, 6Dh,0E2h, 4Eh, 6Ch
		db	 6Ch, 6Ch,0E2h, 6Ah, 7Bh,0E2h
		db	 4Eh, 6Ch, 5Ch,0E2h, 6Ah, 6Dh
		db	0E2h, 4Eh, 6Ch, 6Ch, 6Ch, 6Ch
		db	0E2h, 6Ah, 7Bh, 5Dh, 6Bh, 6Bh
		db	0F6h, 01h,0B2h, 05h,0E2h, 4Eh
		db	 5Ch,0E2h

locloop_10:
		db	 6Ah, 6Dh,0E2h, 4Eh, 6Ch, 6Ch
		db	 6Ch,0E2h, 6Ah, 7Bh,0E2h, 4Eh
		db	 6Ch, 5Ch,0E2h
		db	'jmHk{[mk]gm'
		db	0FBh, 4Dh, 04h,0FFh,0F0h, 07h
		db	0E9h, 03h,0FFh,0F0h, 07h,0E9h
		db	 03h,0FFh,0F0h, 07h,0E9h, 03h
		db	0FFh

locloop_11:
                           lock	pop	es
		jmp	loc_8
			                        ;* No entry point to code
		cmp	di,word ptr ds:[4042h]
		inc	di
		inc	bp
		dec	sp
		dec	di
		push	cx
		adc	byte ptr [bp+di+54h],56h	; 'V'
		dec	si
		dec	dx
		dec	ax
		pop	ax
		pop	cx
		adc	byte ptr [bp+54h],5Bh	; '['
		push	cx
		push	bx
		dec	bp
		inc	ax
		inc	dx
		inc	bx

locloop_12:
		inc	bp
		inc	di
		dec	sp
		dec	dx
		inc	cx
		inc	bx
		add	byte ptr [bx+si+45h],3Ch	; '<'
		dec	ax
		dec	dx
		dec	sp
		inc	dx
		db	'>=G-402-46097)'
data_7		dw	2F80h
		db	'(&*$'
		db	'".$'
		db	'"01', 0Ch
		db	 0Bh, 30h, 2Eh, 06h, 05h, 18h
		db	 17h, 0Ch, 0Dh, 60h,0FFh, 60h
		db	 61h, 30h, 2Eh, 18h,0FFh, 06h
		db	 05h, 24h, 22h, 18h, 19h, 60h
		db	 5Fh, 0Ch, 0Bh, 0Ch, 0Dh, 18h
		db	 17h, 0Ch, 0Bh
		db	'`_$'
		db	'"01$'
		db	'%HG'
		db	6, 5
		db	'$'
		db	'"01', 0Ch, 0Dh, 'HG'
		db	 18h, 17h, 24h, 25h, 12h,0FFh
		db	 60h, 61h, 30h, 2Eh, 24h, 22h
		db	 0Ch, 0Bh, 06h, 05h, 0Ch, 0Dh
		db	 18h, 17h, 60h, 5Fh, 12h,0FFh
		db	 0Ch,0FFh, 60h,0FFh, 0Ch, 0Bh
		db	 06h, 05h
		db	'$'
		db	'"01', 0Ch, 0Dh, '`_$'
		db	'"', 0Ch
		db	 0Bh, 30h, 31h, 0Ch, 0Dh, 48h
		db	 47h, 06h, 05h, 18h, 17h, 24h
		db	 25h, 48h, 47h, 18h,0FFh, 0Ch
		db	 0Bh, 06h, 05h, 00h, 01h, 06h
		db	 01h, 0Ch, 01h, 04h, 23h, 00h
		db	 4Bh, 00h, 78h, 01h,0EAh, 02h
		db	0F4h, 02h,0FEh, 02h,0DAh, 03h
		db	0D4h, 05h, 9Ch, 04h, 07h, 03h
		db	 34h, 08h, 7Fh, 08h, 10h, 08h
		db	0F6h, 08h, 0Ch,0B0h, 01h, 05h
		db	 01h, 01h,0F0h, 00h,0E0h, 82h
		db	0E5h, 17h,0F0h, 00h, 84h,0D3h
		db	0FCh, 06h, 04h,0F0h, 00h,0F5h
		db	 08h,0F0h, 00h, 80h,0D5h,0FCh
		db	 19h, 04h, 81h,0D5h,0FCh, 57h
		db	 04h,0F6h, 34h, 00h, 80h,0D6h
		db	0FCh, 68h, 04h,0FBh, 30h, 00h
		db	0F0h, 00h,0E5h, 17h,0F0h, 00h
		db	 81h,0D4h, 05h, 05h, 10h, 05h
		db	 05h, 10h, 05h, 05h, 20h, 07h
		db	 07h, 10h, 07h, 07h, 10h, 07h
		db	 07h, 20h, 08h, 08h, 10h, 08h
		db	 08h, 10h, 08h, 08h, 20h, 07h
		db	 07h, 10h, 07h, 07h, 10h, 07h
		db	 07h, 20h,0F0h, 00h,0F5h, 09h
		db	0F0h, 00h, 81h,0F5h, 0Ch,0F0h
		db	 00h,0D4h, 05h, 05h, 00h, 08h
		db	 08h, 00h, 0Ah, 0Ah, 30h, 0Ch
		db	 0Ch, 00h, 08h, 08h, 00h, 0Ah
		db	 40h, 05h, 50h,0F6h, 80h, 00h
		db	0D4h, 05h, 05h, 00h, 08h, 08h
		db	 00h, 0Ah, 0Ah, 30h, 0Ch, 0Ch
		db	 00h, 08h, 08h, 00h, 0Ah, 40h
		db	 05h, 00h,0E4h, 05h, 03h,0E3h
		db	 0Ch, 0Ah, 6Ah, 82h,0D4h,0C2h
		db	 08h, 01h, 07h, 03h, 08h, 01h
		db	 07h, 03h, 08h, 01h, 07h, 03h
		db	 08h, 01h, 07h, 03h, 05h, 07h
		db	 08h, 0Ah, 0Ch, 00h, 05h, 07h
		db	 08h, 0Ah, 0Ch, 00h, 10h, 05h
		db	 07h, 08h, 0Ah, 0Ch, 00h, 05h
		db	 07h, 08h, 0Ah, 0Ch, 00h, 10h
		db	0CDh, 81h,0D4h, 76h, 28h, 20h
		db	 05h, 05h, 20h, 76h, 28h, 2Ah
		db	 18h, 15h, 82h,0D4h,0C2h, 25h
		db	 07h, 08h, 2Ah, 08h, 07h, 25h
		db	 07h, 08h, 2Ah, 20h,0D4h, 25h
		db	 07h, 08h, 2Ah, 08h, 07h, 25h
		db	 07h, 08h, 2Ah, 20h,0CDh,0F6h
		db	 7Bh, 40h,0F5h, 08h,0F0h, 00h
		db	 80h,0D4h, 7Ah, 2Ch, 20h,0E4h
		db	 71h, 23h, 21h, 20h,0E3h, 2Ch
		db	 20h, 7Ah, 7Ch,0F0h, 01h, 0Ch
		db	 81h, 1Ah, 1Ah, 1Ah, 1Ah, 1Ah
		db	 10h, 15h, 15h, 15h, 15h, 15h
		db	 10h, 11h, 11h, 11h, 11h,0F6h
		db	 0Fh, 01h,0E4h, 11h, 11h, 11h
		db	 11h, 11h, 10h,0E3h, 16h, 16h
		db	 16h, 16h, 16h, 20h, 16h, 16h
		db	 16h, 16h, 16h, 10h,0E4h, 11h
		db	 11h, 11h, 11h, 11h, 20h, 13h
		db	 13h, 13h, 13h, 13h, 10h, 13h
		db	 13h, 13h, 13h, 13h, 10h, 13h
		db	 13h, 13h, 13h,0E3h, 15h,0E4h
		db	 15h,0E3h, 15h,0E4h, 15h,0E3h
		db	 15h,0E4h, 15h,0E3h, 15h,0E4h
		db	 15h,0E3h, 15h, 30h,0FBh, 77h
		db	 00h,0F0h, 00h,0E5h, 0Fh,0F0h
loc_13:
		add	ss:data_11e[bp+di],al
loc_14:
		add	dh,al
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
loc_15:
;*		or	ax,si
		db	 09h,0F0h		;  Fixup - byte match
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
loc_16:
;*		jp	loc_17			;*Jump if parity=1
		db	 7Ah, 02h		;  Fixup - byte match
		cld				; Clear direction
;*		jp	loc_18			;*Jump if parity=1
		db	 7Ah, 02h		;  Fixup - byte match
		cld				; Clear direction
		int	2			; NMI (parity, video ticks, etc)
		jcxz	loc_21			; Jump if cx=0
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
;*		jcxz	loc_19			;*Jump if cx=0
		db	0E3h, 0Ah		;  Fixup - byte match
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		and	sp,[bx]
		jcxz	loc_23			; Jump if cx=0
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
;*		jcxz	loc_20			;*Jump if cx=0
		db	0E3h, 0Ah		;  Fixup - byte match
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		daa				; Decimal adjust
		and	sp,bx
		cld				; Clear direction
		int	2			; NMI (parity, video ticks, etc)
;*		jcxz	loc_25			;*Jump if cx=0
		db	0E3h, 2Ah		;  Fixup - byte match
loc_21:
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
;*		jcxz	loc_22			;*Jump if cx=0
		db	0E3h, 0Ah		;  Fixup - byte match
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		and	sp,[bx]
		jcxz	loc_26			; Jump if cx=0
loc_23:
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
		jcxz	loc_24			; Jump if cx=0
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		or	al,[bx+si]
		or	[bx+si],al
loc_24:
		pop	es
		add	ax,[di]
		test	byte ptr ss:data_12e[bp],9
;*                         lock	add	dl,dl
		db	0F0h, 00h,0D2h		;  Fixup - byte match
		db	 26h,0E4h, 05h,0E3h, 06h,0E4h
		db	 03h, 01h, 01h,0E3h, 26h, 06h
		db	0E4h, 05h, 01h, 03h,0E3h
loc_26:
		or	al,0E4h
		add	[bp+di],ax
;*		jcxz	loc_31			;*Jump if cx=0
		db	0E3h, 26h		;  Fixup - byte match
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
		jcxz	loc_28			; Jump if cx=0
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
		add	[bx+di],ax
		jcxz	loc_34			; Jump if cx=0
loc_28:
		push	es
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
		add	[bp+di],ax
;*		jcxz	loc_30			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
;*		jcxz	loc_29			;*Jump if cx=0
		db	0E3h, 06h		;  Fixup - byte match
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
		add	[di],ah
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
;*		jcxz	loc_32			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		in	al,21h			; port 21h, 8259-1 int IMR
;*		jcxz	loc_33			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		and	ax,0E405h
		add	sp,bx
		or	al,0Ah
		or	al,0E4h
;*		add	bx,sp
		db	 01h,0E3h		;  Fixup - byte match
		or	dh,dh			; Zero ?
		pop	ss
loc_34:
		add	dh,dh
		out	41h,al			; port 41h, 8253 timer 1 refsh
		cmc				; Complement carry
;*		or	al,dh
		db	 08h,0F0h		;  Fixup - byte match
;*		add	dl,dl
		db	 00h,0D2h		;  Fixup - byte match
		and	sp,sp
		add	sp,bx
		add	bp,[si]
		in	al,1			; port 1, DMA-1 bas&cnt ch 0
;*		jcxz	loc_36			;*Jump if cx=0
		db	0E3h, 23h		;  Fixup - byte match
		add	sp,sp
		add	sp,bx
		add	bp,[si]
		in	al,21h			; port 21h, 8259-1 int IMR
		div	byte ptr ds:data_1e	; al,ah rem = ax/data
		and	ax,5E4h
;*		jcxz	loc_35			;*Jump if cx=0
		db	0E3h, 05h		;  Fixup - byte match
		in	al,23h			; port 23h ??I/O Non-standard
;*		add	bx,sp
		db	 01h,0E3h		;  Fixup - byte match
		and	ax,0E405h
		add	ax,5E3h
		in	al,23h			; port 23h ??I/O Non-standard
		and	sp,bx
		and	ax,5E4h
;*		jcxz	loc_37			;*Jump if cx=0
		db	0E3h, 05h		;  Fixup - byte match
		in	al,3			; port 3, DMA-1 bas&cnt ch 1
		add	ax,[bx+di]
;*		jcxz	loc_38			;*Jump if cx=0
		db	0E3h, 0Ch		;  Fixup - byte match
		add	ax,5E4h
		add	[bp+di],al
		add	[bx+di],al
;*		add	bl,ah
		db	 00h,0E3h		;  Fixup - byte match
		or	al,0FBh
;*		add	byte ptr [bx+di],0F0h
		db	 82h, 01h,0F0h		;  Fixup - byte match
;*		add	dl,dl
		db	 00h,0D2h		;  Fixup - byte match
		sub	ah,ah
		add	ax,0AE3h
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		and	sp,[bx]
		jcxz	loc_40			; Jump if cx=0
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
;*		jcxz	loc_39			;*Jump if cx=0
		db	0E3h, 0Ah		;  Fixup - byte match
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		daa				; Decimal adjust
		and	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		add	ax,0AE3h
		or	ah,ah			; Zero ?
		and	sp,[bx]
		jcxz	loc_41			; Jump if cx=0
		in	al,5			; port 5, DMA-1 bas&cnt ch 2
		jcxz	$+0Ch			; Jump if cx=0
loc_40:
		in	al,21h			; port 21h, 8259-1 int IMR
		add	sp,bx
		sub	ah,ah
		or	ah,bl
		or	ah,ah			; Zero ?
;*		or	bl,ah
		db	 08h,0E3h		;  Fixup - byte match
		or	ah,ah			; Zero ?
		pop	es
		add	ax,[di]
		db	0FEh,0F0h, 00h,0F5h, 08h,0F0h
		db	 00h,0D2h, 26h,0E4h, 05h,0E3h
		db	 06h,0E4h, 21h, 03h,0E3h, 26h
		db	 06h,0E4h, 05h
loc_41:
		jcxz	$+8			; Jump if cx=0
		in	al,21h			; port 21h, 8259-1 int IMR
		and	si,si
		rol	word ptr [bp+si],1	; Rotate
		db	0FEh,0F0h, 00h,0E5h, 27h,0E1h
		db	 04h, 00h,0FBh, 29h, 00h,0F0h
		db	 00h,0E5h, 2Fh,0E1h, 04h, 00h
		db	0FBh, 4Fh, 00h,0F0h, 00h,0E5h
		db	 1Fh,0E1h, 04h,0FBh, 7Ch, 01h
		db	0F0h, 00h,0D0h, 00h,0CDh, 00h
		db	0CFh, 02h,0CEh, 09h,0D1h, 09h
		db	0FCh,0B2h, 03h,0FCh,0C6h, 03h
		db	0FCh,0B2h, 03h,0FCh,0C6h, 03h
		db	0F0h, 00h,0F5h, 09h,0F0h, 00h
		db	0C0h, 13h, 01h, 01h, 01h, 19h
		db	 01h, 01h, 11h, 01h, 01h, 01h
		db	 01h, 19h, 00h, 18h, 00h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0FCh
		db	0C6h, 03h,0FCh,0B2h, 03h,0C0h
		db	 11h, 01h, 01h, 01h, 19h, 01h
		db	 01h, 11h, 01h, 01h, 08h, 00h
		db	 18h, 08h, 18h, 18h,0F6h, 23h
		db	 43h,0F5h, 08h,0F0h, 00h,0FCh
		db	0B2h, 03h,0FCh,0C6h, 03h,0FCh
		db	0B2h, 03h,0C0h, 11h, 01h, 01h
		db	 01h, 19h, 01h, 01h, 11h, 01h
		db	 01h, 01h, 01h, 18h, 08h, 18h
		db	 18h,0F6h, 76h, 03h,0FCh,0C6h
		db	 03h,0FCh,0C6h, 03h,0FCh,0C6h
		db	 03h,0C0h, 11h, 01h, 01h, 01h
		db	 19h, 01h, 01h, 11h, 00h, 08h
		db	 08h, 00h, 18h, 08h, 18h, 18h
		db	0FBh, 1Fh, 03h,0F0h, 00h,0C0h
		db	 11h, 01h, 01h, 01h, 19h, 01h
		db	 01h, 11h, 01h, 01h, 01h, 01h
		db	 19h, 00h, 18h, 00h,0FEh,0F0h
		db	 00h,0C0h, 11h, 01h, 01h, 01h
		db	 19h, 01h, 01h, 11h, 01h, 01h
		db	 01h, 01h, 19h, 00h, 18h, 18h
		db	0FEh,0F0h, 00h,0E0h, 82h, 80h
		db	0D2h,0E5h, 17h,0E1h, 10h,0FCh
		db	 06h, 04h,0E1h, 00h,0F0h, 00h
		db	0F5h, 08h,0F0h, 00h, 81h,0E5h
		db	 17h,0D4h,0FCh, 19h, 04h, 82h
		db	0D3h,0FCh, 57h, 04h,0F6h,0EDh
		db	 03h, 81h,0D5h,0FCh, 68h, 04h
		db	0FBh,0E9h, 03h,0F0h, 00h, 7Ch
		db	0E4h,0F0h, 01h, 03h, 47h, 55h
		db	 63h, 4Ch, 0Ah,0E4h, 55h, 18h
		db	 1Ah, 60h, 7Ch,0FEh,0F0h, 01h
		db	 6Ah, 6Ch,0E4h, 61h, 73h, 61h
		db	0E3h, 6Ch,0E4h, 71h,0E3h, 6Ch
		db	 6Ah, 7Ch, 6Ah, 78h, 4Ah, 05h
		db	0F0h, 02h, 00h, 1Ah, 1Ch,0E4h
		db	 11h, 23h, 11h,0E3h, 1Ch,0E4h
		db	 21h,0E3h, 1Ch, 1Ah, 2Ch, 1Ah
		db	 28h, 3Ch,0E4h, 11h,0E3h
		db	0Ah, ' HGECQ '
		db	0E3h, 4Ch,0E4h, 41h, 43h, 41h
		db	0E3h, 3Ch, 35h, 6Ah,0FEh,0F0h
		db	 02h, 3Ah, 1Ch, 10h, 18h, 10h
		db	 3Ah, 1Ch,0E4h, 11h,0E3h, 2Ch
		db	 28h, 0Ah, 00h,0FEh,0F0h, 02h
		db	 31h, 13h, 10h, 35h, 16h, 15h
		db	 10h, 13h, 10h, 31h, 33h, 75h
		db	 31h, 13h, 10h, 35h, 16h, 15h
		db	 10h, 13h, 10h, 31h, 38h, 28h
		db	0F0h, 03h, 05h,0E3h, 1Ah, 1Ch
		db	0E4h, 11h,0E3h, 1Ah,0E4h, 21h
		db	0E3h, 36h, 1Ah, 1Ch,0E4h, 11h
		db	0E3h, 1Ah,0E4h, 23h, 48h, 05h
		db	 40h,0FEh,0F0h, 00h,0E5h, 07h
		db	0F0h, 03h,0DDh,0FCh, 81h, 07h
		db	0F0h, 03h,0F5h, 09h,0F0h, 03h
		db	0FCh, 81h, 07h,0FCh, 81h, 07h
		db	0FCh,0ECh, 07h,0E3h, 83h, 6Ah
		db	0E4h, 84h, 15h,0E3h, 1Ah,0E4h
		db	 83h, 61h, 84h, 13h,0E3h, 83h
		db	 6Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	 1Ah,0E4h, 83h, 63h, 67h,0E3h
		db	 6Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	0E4h, 83h, 61h, 84h, 13h,0E3h
		db	 83h, 6Ah,0E4h, 84h, 15h,0E3h
		db	 1Ah, 1Ah,0E4h, 83h, 67h, 63h
		db	0E3h,0FCh,0ECh, 07h,0E3h, 6Ah
		db	0E4h, 84h, 15h,0E3h, 1Ah,0E4h
		db	 83h, 61h, 84h, 13h,0E3h, 83h
		db	 6Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	 1Ah,0E4h, 83h, 63h, 67h,0E3h
		db	 6Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	0E4h, 83h, 61h, 84h, 13h,0E3h
		db	 83h, 6Ah,0E4h, 84h, 1Ah, 10h
		db	 18h, 10h, 17h, 13h, 15h,0F6h
		db	0AAh, 44h,0F5h, 09h,0F0h, 03h
		db	0D1h, 83h, 66h,0E4h, 84h, 15h
		db	0E3h, 16h,0E4h, 13h, 11h, 11h
		db	0E3h, 83h, 66h, 84h, 16h,0E4h
		db	 15h, 11h, 13h,0E3h, 1Ch,0E4h
		db	 11h, 13h,0E3h, 83h, 66h,0E4h
		db	 84h, 15h,0E3h, 16h,0E4h, 13h
		db	 11h, 11h,0E3h, 83h, 66h, 84h
		db	 16h,0E4h, 15h, 11h, 13h,0E3h
		db	 1Ch,0E4h, 11h,0E3h, 16h,0F5h
		db	 08h,0F0h, 03h, 83h, 65h,0E4h
		db	 84h, 13h,0E3h, 1Ch,0E4h, 83h
		db	 61h,0E3h, 84h, 1Ch, 83h, 65h
		db	 84h, 15h,0E4h, 13h,0E3h, 1Ch
		db	 1Ah, 1Ch,0E4h, 11h,0E3h, 1Ah
		db	0F6h, 5Bh, 05h,0F6h, 22h, 45h
		db	0F5h, 08h,0F0h, 03h,0D1h, 83h
		db	 63h,0E4h, 84h, 13h,0E3h, 13h
		db	 83h, 6Ch,0E4h, 84h, 11h,0E3h
		db	 83h, 63h, 84h, 13h,0E4h, 13h
		db	0E3h, 13h, 83h, 6Ch,0E4h, 61h
		db	0F6h, 80h, 05h,0E3h, 83h, 65h
		db	0E4h, 84h, 15h,0E3h, 15h,0E4h
		db	 83h, 63h, 84h, 11h,0E3h, 83h
		db	 65h, 84h, 15h,0E4h, 15h,0E3h
		db	 15h,0E4h, 83h, 63h, 63h,0E3h
		db	 83h, 65h,0E4h, 84h, 15h,0E3h
		db	 15h,0E4h, 13h, 13h, 11h,0E3h
		db	 1Ch, 15h,0E4h, 15h, 10h, 13h
		db	 10h, 11h, 10h,0E3h, 1Ch,0FBh
		db	0A6h, 04h,0F0h, 00h,0E5h, 0Fh
		db	0D3h,0E1h,0F0h,0CCh, 82h, 05h
		db	 05h, 10h, 05h, 05h, 10h, 05h
		db	 05h,0C3h, 85h, 08h, 00h,0CCh
		db	 82h, 07h, 07h, 10h, 07h, 07h
		db	 10h, 07h, 07h,0C3h, 85h, 08h
		db	 08h,0CCh, 82h, 08h, 08h, 10h
		db	 08h, 08h, 10h, 08h, 08h,0C3h
		db	 85h, 08h, 00h,0CCh, 82h, 07h
		db	 07h, 10h, 07h, 07h, 10h, 07h
		db	 07h,0C3h, 85h, 08h, 08h,0E1h
		db	 10h,0F0h, 00h,0D3h,0F5h, 09h
		db	0F0h, 00h,0F5h, 0Ch,0F0h, 00h
		db	0CCh, 82h, 05h, 05h, 00h, 08h
		db	 08h, 00h, 0Ah, 0Ah, 20h, 10h
		db	0C3h, 85h, 08h, 00h,0CCh, 82h
		db	 0Ch, 0Ch, 00h
		db	8
		db	8
		db	 00h, 0Ah, 40h, 05h, 40h,0C3h
		db	 85h, 08h, 08h,0F6h, 1Eh, 06h
		db	0CCh, 82h, 05h, 05h, 00h, 08h
		db	 08h, 00h, 0Ah, 0Ah, 20h, 10h
		db	0C3h, 85h, 08h, 00h,0CCh, 82h
		db	 0Ch, 0Ch, 00h, 08h, 08h, 00h
		db	 0Ah, 00h, 20h, 05h, 00h,0E4h
		db	 05h, 03h,0E3h, 0Ch, 0Ah,0F0h
		db	 03h, 7Ah,0C3h, 85h, 18h, 10h
		db	0CAh, 86h,0E4h, 18h, 11h, 17h
		db	 13h, 18h, 11h, 17h, 13h, 18h
		db	 11h, 17h, 13h, 18h, 11h,0C5h
		db	 85h, 18h, 18h,0C8h, 86h, 15h
		db	 17h, 18h, 1Ah, 1Ch, 10h, 15h
		db	 17h, 18h, 1Ah, 1Ch, 10h, 60h
		db	0C7h, 85h, 18h, 10h,0C8h, 86h
		db	 15h, 17h, 18h, 1Ah, 1Ch, 10h
		db	 15h, 17h, 18h, 1Ah, 1Ch, 10h
		db	 60h,0C7h, 85h, 18h, 18h,0E3h
		db	0CCh, 82h, 26h, 68h, 60h, 15h
		db	 15h, 60h,0C3h, 85h, 18h, 10h
		db	0CCh, 82h, 46h, 68h, 6Ah, 48h
		db	 65h,0C3h, 85h, 18h, 18h,0CAh
		db	 86h,0E4h, 65h, 17h, 18h, 6Ah
		db	 18h, 17h, 65h, 17h, 18h, 6Ah
		db	0C5h, 85h, 18h, 10h,0CAh, 86h
		db	 65h, 17h, 18h, 6Ah, 18h, 17h
		db	 15h, 10h,0C5h, 85h, 18h, 10h
		db	 18h, 18h, 18h, 18h,0E3h,0F6h
		db	 1Ah, 46h,0F5h, 08h,0F0h, 03h
		db	0CEh, 81h,0D4h, 2Ah, 6Ch, 60h
		db	0E4h, 41h,0C1h, 85h, 18h, 10h
		db	0CEh, 81h, 63h, 61h, 60h,0E3h
		db	 6Ch, 60h, 4Ah,0C1h, 85h, 18h
		db	 18h,0CEh, 81h, 2Ch,0F0h, 04h
		db	 0Ch,0C1h, 85h, 18h, 10h,0CCh
		db	 82h,0E3h, 1Ah, 1Ah, 1Ah, 1Ah
		db	 1Ah, 10h, 15h, 15h, 15h, 15h
		db	 15h, 10h,0C3h, 85h, 18h, 18h
		db	 18h, 18h,0F6h,0E9h, 06h,0CCh
		db	 82h,0D4h, 11h, 11h, 11h, 11h
		db	 11h, 10h,0E3h, 16h, 16h, 16h
		db	 16h, 16h, 20h,0C3h, 85h, 18h
		db	 18h,0CCh, 82h, 16h, 16h, 16h
		db	 16h, 16h, 10h,0E4h, 11h, 11h
		db	 11h, 11h, 11h, 20h,0C3h, 85h
		db	 18h, 18h,0CCh, 82h, 13h, 13h
		db	 13h, 13h, 13h, 10h, 13h, 13h
		db	 13h, 13h, 13h, 10h, 13h, 13h
		db	0C3h, 85h, 18h, 18h,0CCh, 82h
		db	0E3h, 15h,0E4h, 15h,0E3h, 15h
		db	0E4h, 15h,0E3h, 15h,0E4h, 15h
		db	0E3h, 15h,0E4h, 15h,0E3h, 15h
		db	0C3h, 85h, 18h, 18h, 10h, 18h
		db	 18h, 18h, 18h,0FBh, 15h, 06h
		db	0F0h, 04h,0D1h, 83h, 3Ah,0E4h
		db	 84h, 15h,0E3h, 1Ah,0E4h, 83h
		db	 31h, 84h, 13h,0E3h, 83h, 3Ah
		db	0E4h, 84h, 15h,0E3h, 1Ah, 1Ah
		db	0E4h, 83h, 33h, 37h,0E3h, 3Ah
		db	0E4h, 84h, 15h,0E3h, 1Ah,0E4h
		db	 83h, 31h, 84h, 13h,0E3h, 83h
		db	 3Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	 1Ah,0E4h, 83h, 37h, 33h,0E3h
		db	 3Ah,0E4h, 84h, 15h,0E3h, 1Ah
		db	0E4h, 83h, 31h, 84h, 13h,0E3h
		db	 83h, 3Ah,0E4h, 84h, 15h,0E3h
		db	 1Ah, 1Ah
loc_42:
		in	al,83h			; port 83h, DMA page reg ch 1
		xor	si,[bx]
		jcxz	$+3Ch			; Jump if cx=0
		in	al,84h			; port 84h, POST checkpoint
		adc	ax,1AE3h
		in	al,83h			; port 83h, DMA page reg ch 1
		xor	word ptr ds:[0E313h][si],ax
;*		cmp	word ptr [bp+si],0FFE4h
		db	 83h, 3Ah,0E4h		;  Fixup - byte match
		test	bl,[bp+si]
		jcxz	$+1Ch			; Jump if cx=0
		in	al,18h			; port 18h ??I/O Non-standard
		jcxz	$+1Ch			; Jump if cx=0
		in	al,17h			; port 17h ??I/O Non-standard
		adc	dx,[di]
		db	0FEh,0F0h, 04h,0F5h, 08h,0F0h
		db	 04h,0D1h, 83h, 36h,0E4h, 84h
		db	 15h,0E3h, 16h,0E4h, 83h, 31h
		db	 84h, 13h,0E3h, 83h, 36h, 84h
		db	 16h,0E4h, 15h,0E3h, 16h,0E4h
		db	 83h, 31h, 33h,0F6h,0F0h, 07h
		db	0FEh, 06h, 18h, 0Ch, 30h, 12h
		db	 1Eh, 60h, 24h, 3Ch, 06h, 1Eh
		db	 2Ah, 24h, 30h, 0Ch, 18h, 60h
		db	 0Ch, 18h, 24h, 06h, 90h, 78h
		db	 9Ch, 6Ch, 06h, 24h, 84h, 18h
		db	 08h, 0Ch, 54h, 30h, 06h, 12h
		db	 0Ch, 20h, 10h, 10h, 07h, 07h
		db	 01h, 51h, 41h, 1Dh, 00h, 40h
		db	 81h,0F3h,0F5h, 0Eh, 12h, 08h
		db	 08h, 05h, 05h, 01h, 21h, 22h
		db	 12h, 00h,0F8h, 55h, 35h, 36h
		db	 0Eh, 00h, 00h, 00h, 02h, 02h
		db	 01h, 34h, 31h, 40h, 40h,0F1h
		db	0F1h, 15h, 15h, 05h, 00h, 00h
		db	 00h, 02h, 02h, 01h,0E0h, 21h
		db	 8Eh, 00h,0F4h,0F5h, 32h, 36h
		db	 08h, 00h, 00h, 00h, 02h, 02h
		db	 01h, 24h, 21h, 9Ch, 00h,0F3h
		db	0F3h, 38h, 88h, 00h, 00h, 00h
		db	 00h, 02h, 02h, 81h, 00h, 01h
		db	 17h, 03h, 05h, 6Eh, 32h, 1Fh
		db	 38h, 00h, 04h, 0Eh, 15h, 15h
		db	 05h, 05h, 01h, 00h, 01h, 03h
		db	 17h, 09h, 5Fh, 11h, 0Fh, 38h
		db	 00h, 05h, 00h, 2Bh, 2Bh, 02h
		db	 02h, 01h, 00h, 01h, 05h, 17h
		db	 03h, 5Fh, 11h, 0Fh, 38h, 00h
		db	 03h, 00h, 00h, 00h, 02h, 02h
		db	 81h, 01h, 02h,0D0h, 01h, 07h
		db	 99h, 01h,0FFh, 38h, 00h, 05h
		db	 00h, 00h, 00h, 02h, 02h, 81h
		db	 00h, 01h, 07h, 7Ch, 07h, 99h
		db	 01h, 0Dh, 38h, 00h, 05h, 01h
		db	0E5h, 47h, 06h, 02h, 01h, 00h
		db	 02h, 09h, 38h, 09h, 5Fh, 01h
		db	 2Fh, 87h, 00h, 04h, 00h, 0Eh
		db	 0Eh, 07h, 07h, 01h, 00h, 01h
		db	 01h, 01h, 05h, 5Fh, 61h, 0Fh
		db	 38h, 00h, 04h

_386UNKN	endp

seg_a		ends



		end	start
