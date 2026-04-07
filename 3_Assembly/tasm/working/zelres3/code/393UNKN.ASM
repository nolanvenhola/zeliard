
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_393UNKN                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_11e	equ	1112h			;*
data_12e	equ	17E5h			;*
data_13e	equ	30E6h			;*
data_14e	equ	3235h			;*
data_15e	equ	48E6h			;*
data_16e	equ	0E90Fh			;*
data_17e	equ	0F000h			;*
data_18e	equ	17E5h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_393UNKN	proc	far

start:
		db	0C0h, 09h, 00h, 00h,0B5h, 04h
		db	 07h, 05h,0C1h, 03h, 97h, 04h
		db	 01h, 1Fh, 00h, 02h, 57h, 01h
		db	 03h, 0Ch, 02h, 09h,0A1h, 02h
		db	 05h,0A8h, 03h, 06h,0ADh, 03h
		db	 07h,0B2h, 03h, 08h,0B7h, 03h
		db	 09h,0BCh, 03h,0F0h, 00h,0E9h
		db	 00h,0E0h, 78h,0A0h,0E6h, 08h
		db	0E5h, 7Fh,0E2h, 40h, 00h, 01h
		db	 12h, 03h, 04h, 12h, 05h, 06h
		db	 12h, 01h, 00h, 12h, 27h, 38h
		db	 34h, 33h, 39h, 3Ah, 01h, 0Ah
		db	 03h, 04h, 07h, 0Bh, 0Bh, 0Ch
		db	 0Ch, 0Dh, 0Eh, 0Fh,0E9h, 01h
		db	 00h, 01h,0F0h, 00h,0E9h, 01h
		db	0E6h, 08h, 32h, 02h, 02h, 02h
		db	 02h, 32h, 33h, 04h, 05h, 06h
		db	 07h, 08h, 09h, 0Ah, 03h, 02h
		db	 03h, 04h, 0Bh, 0Ch, 0Dh, 03h
		db	 0Eh, 0Bh, 02h, 03h, 0Fh, 32h
		db	 33h, 04h, 05h, 06h, 07h, 08h
		db	 09h, 0Ah, 03h, 02h, 03h, 04h
		db	 0Fh, 03h, 0Eh, 45h, 45h, 32h
		db	 02h, 02h, 02h, 02h, 32h, 33h
		db	 04h, 05h, 06h, 07h, 08h, 09h
		db	 0Ah, 03h, 02h, 03h, 04h, 0Bh
		db	 0Ch, 0Dh, 04h,0E9h, 02h, 00h
		db	 01h, 02h, 03h, 04h, 05h, 06h
		db	 07h, 08h, 05h
		db	9, '8', 8, 8, 8, 8, '8:'
		db	 07h, 0Bh, 04h, 0Ch, 0Dh, 0Eh
		db	 0Fh, 0Ah, 08h, 0Ah, 07h,0E9h
		db	 03h, 00h, 01h, 02h, 03h
loc_1:
		add	al,0
		add	ax,603h
		xor	ax,733h
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		add	ax,[di]
		add	ax,[bx]
		push	es
		add	ax,[si]
		dec	ax
		dec	ax
		xor	ax,505h
		add	ax,3505h
		xor	ax,[bx]
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		add	ax,[di]
		add	ax,[bx]
		add	[bx+di],al
		add	cl,ds:data_16e
		add	al,0
		add	[bp+si],ax
		add	ax,[si]
		add	ax,706h
		add	al,8
		cmc				; Complement carry
		add	[bp+si],ax
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		add	al,37h			; '7'
		pop	es
		pop	es
		pop	es
		pop	es
		aaa				; Ascii adjust
		cmp	word ptr ds:[30Ah],ax
		or	cx,[si]
		or	ax,90Eh
		pop	es
		or	ds:data_16e,ax
		add	ax,100h
		add	al,[bp+di]
		add	al,5
		add	al,ds:data_14e
		pop	es
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		add	al,[di]
		add	al,[bx]
		add	al,[bp+si]
		add	cx,[bx+si+48h]
		xor	ax,505h
		add	ax,3505h
		xor	al,[bx]
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		add	al,[di]
		add	al,[bx]
		add	al,0
		add	[bx],ax
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
;*		jmpn	loc_2			;*
		db	0E9h, 06h, 00h		;  Fixup - byte match
			                        ;* No entry point to code
		add	[bp+si],ax
		add	ax,[si]
		add	ax,306h
		pop	es
		test	byte ptr [bx+di],0F9h
;*		add	bl,bh
		db	 00h,0FBh		;  Fixup - byte match
		dec	si
;*		add	bh,bh
		db	 00h,0FFh		;  Fixup - byte match
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		push	es
		mov	al,ds:data_13e
		in	ax,78h			; port 78h ??I/O Non-standard
;*		loop	locloop_4		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match
		xor	[bx+si],bh
		cmp	[bp+si],di
		cmp	si,[bx+di]
		or	al,0Dh
		pop	sp
		pop	bp
		pop	sp
		pop	bp
		cmp	al,6Eh			; 'n'
		aas				; Ascii adjust
		push	cs
		jmpn	loc_3
			                        ;* No entry point to code
		add	[bp+si],ax
		xor	si,[bp+si+32h]
		add	[bx+si],ax
loc_3:
		add	al,5
		push	es
		pop	es
		or	[bx+di],cl
		or	cl,[bp+di]
		or	al,0Dh
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		pop	es
		in	ax,78h			; port 78h ??I/O Non-standard
		out	8,al			; port 8, DMA-1 command reg
		cmc				; Complement carry
		add	[bx+si],cx
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		pop	es
;*		jmpn	locloop_4		;*
		db	0E9h, 08h, 00h		;  Fixup - byte match
			                        ;* No entry point to code
		add	[bp+si],ax
		add	ax,[si]
		add	ax,106h
		add	al,[bp+di]
		add	al,5
		test	byte ptr [bx+di],93h
		add	[bx-0Bh],ax
		add	[bx+si],cx
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		or	[bx+si],al
		add	[bp+si],ax
		add	ax,[si]
		add	ax,106h
		add	al,[bp+di]
		add	al,5
		test	byte ptr [bx+di],0ADh
		add	[bx+si],cx
		add	[bx+di],cl
		add	byte ptr ds:[60Ah],al
		or	cx,[si]
		or	dx,[bx]
		cmc				; Complement carry
		add	[bx+si],cx
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		or	[di],cl
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		or	ch,cl
		or	[bx+si],ax
		add	[bp+si],ax
		add	ax,[si]
		add	ax,100h
		test	byte ptr [bx+di],0CFh
		add	[bp-0Bh],ax
		add	[bx+si],cx
;*                         lock	add	cl,ch
		db	0F0h, 00h,0E9h		;  Fixup - byte match
		or	[bp+si],ax
		add	ax,[si]
		add	ax,100h
		add	al,[bp+di]
		add	al,5
		add	[bx+di],al
		test	byte ptr [bx+di],0E9h
		add	[bx],ax
		or	[bx+di],cl
		or	[bp+si],cl
		add	ax,0B0Ah
		or	al,0Bh
		push	ss
		sti				; Enable interrupts
		mov	[bx+di],al
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match
;*		add	cl,ch
		db	 00h,0E9h		;  Fixup - byte match
		or	ds:data_15e[bx+si],sp
		in	ax,78h			; port 78h ??I/O Non-standard
		loop	locloop_5		; Loop if cx > 0

                           lock	add	[di],ax
		sbb	ax,1F1Eh
		jmp	$+100Dh
			                        ;* No entry point to code
		adc	[bp+si],dx
		adc	dx,[si]
		adc	ax,1716h
		sbb	[bx+di],bl
		sbb	bl,[bp+di]
		adc	[si],bl
		sbb	ax,1F1Eh
		jmp	$+100Eh
			                        ;* No entry point to code
		adc	[bp+si],dx
		adc	sp,bp
		db	 64h,0E6h, 6Ah,0E2h
		db	'@$'
		db	'%&', 27h, '()*+'
		db	0F0h, 01h,0E9h, 0Bh,0F5h, 01h
		db	 08h,0F0h, 01h,0E9h, 0Bh
		db	',(-+)*,(-+)*'
		db	0F6h, 01h, 4Bh, 02h
		db	'.(,+', 27h, '$'
		db	'/%.'
		db	0E9h, 0Ch, 20h, 21h, 22h,0F5h
		db	 01h, 03h,0F0h, 01h,0E9h, 0Ch
		db	0F5h, 02h, 08h,0F0h, 01h,0E9h
		db	0Ch, '#$'
		db	'%&', 27h, '(#$'
		db	'%&', 27h, '('
		db	0F6h, 02h, 77h, 02h
		db	 22h, 29h, 2Ah, 28h

locloop_5:
		sub	bp,[si]
		sub	ax,222Eh
		das				; Decimal adjust
		sub	ax,0DE9h
;*		and	dh,dh
		db	 20h,0F6h		;  Fixup - byte match
		add	[bx+si+2],si
		sti				; Enable interrupts
		inc	sp
		add	bh,bh
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		or	ax,7FE5h
		out	0Ah,ax			; port 0Ah, DMA-1 mask reg bit
		add	[bx+di],ax
;*		xor	dx,sp
		db	 31h,0E2h		;  Fixup - byte match
		dec	si
		inc	dx
		push	bx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		or	ax,5344h
		adc	[si-1Eh],ax
		inc	ax
		push	bp
		loop	locloop_9		; Loop if cx > 0

		inc	dx
		loop	locloop_6		; Loop if cx > 0

		push	bp
		loop	locloop_12		; Loop if cx > 0

		inc	sp
		loop	locloop_8		; Loop if cx > 0

		push	bp
		loop	$+50h			; Loop if cx > 0

		push	bp
		inc	sp
		loop	locloop_10		; Loop if cx > 0

		push	bp
		loop	locloop_7		; Loop if cx > 0

		push	bp
		loop	locloop_14		; Loop if cx > 0

		inc	sp
		push	bp
		inc	dx
;*		loop	locloop_13		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match
		push	bp
		loop	locloop_15		; Loop if cx > 0

		inc	sp
		loop	locloop_11		; Loop if cx > 0

		push	bp
;*		loop	locloop_17		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	bp
		cmc				; Complement carry
		add	[bx],ax
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		or	ax,5445h
		loop	$+34h			; Loop if cx > 0

		push	bp
		loop	locloop_21		; Loop if cx > 0

		inc	bp
		push	sp
		inc	dx
;*		loop	locloop_19		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match
		push	bp
;*		loop	locloop_16		;*Loop if cx > 0

		db	0E2h, 32h		;  Fixup - byte match
		inc	bp
		loop	locloop_24		; Loop if cx > 0

		push	sp
		push	bp
		loop	locloop_18		; Loop if cx > 0

		inc	bp

locloop_6:
;*		loop	locloop_26		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_7:
		push	sp
		push	bp
;*		loop	locloop_20		;*Loop if cx > 0

		db	0E2h, 32h		;  Fixup - byte match

locloop_8:
		inc	bp
;*		loop	locloop_27		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	dx

locloop_9:
;*		loop	locloop_25		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match

locloop_10:
		push	bp
;*		loop	locloop_22		;*Loop if cx > 0

		db	0E2h, 32h		;  Fixup - byte match

locloop_11:
		inc	bp

locloop_12:
		loop	locloop_28		; Loop if cx > 0

		push	sp
		loop	locloop_23		; Loop if cx > 0

		push	bp
		test	byte ptr [bx+di],0ECh
		add	ah,dl
		db	 6Ah, 43h,0E2h, 4Eh, 62h

locloop_14:
		adc	[bp+si+52h],dx
		push	dx
		push	dx
		push	dx
		inc	sp
		push	bx

locloop_15:
		adc	[si-1Eh],ax
		inc	ax
		push	bp
		loop	locloop_32		; Loop if cx > 0

		inc	dx

locloop_18:
		loop	locloop_29		; Loop if cx > 0

		push	bp
		loop	locloop_35		; Loop if cx > 0

		inc	sp
		loop	locloop_31		; Loop if cx > 0

		push	bp
		loop	locloop_36		; Loop if cx > 0

		push	bp
		inc	sp

locloop_21:
		loop	locloop_33		; Loop if cx > 0

		push	bp
		loop	locloop_30		; Loop if cx > 0

		push	bp
		loop	locloop_39		; Loop if cx > 0

		inc	sp
		push	bp

locloop_23:
		inc	dx

locloop_24:
;*		loop	locloop_37		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match
		push	bp
		loop	locloop_40		; Loop if cx > 0

		inc	sp
		loop	locloop_34		; Loop if cx > 0

		push	bp
		loop	locloop_42		; Loop if cx > 0

		push	bp
		cmc				; Complement carry
		add	[bx],ax
;*                         lock	add	cx,bp
		db	0F0h, 01h,0E9h		;  Fixup - byte match
		or	ax,5445h
		loop	locloop_38		; Loop if cx > 0

		push	bp

locloop_28:
		loop	locloop_46		; Loop if cx > 0

		inc	bp
		push	sp
		inc	dx
;*		loop	locloop_44		;*Loop if cx > 0

		db	0E2h, 40h		;  Fixup - byte match
		push	bp
		loop	locloop_41		; Loop if cx > 0

		inc	bp
		loop	locloop_49		; Loop if cx > 0

		push	sp
		push	bp
		loop	locloop_43		; Loop if cx > 0

		inc	bp

locloop_29:
;*		loop	locloop_51		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match

locloop_30:
		push	sp
		push	bp
;*		loop	locloop_45		;*Loop if cx > 0

		db	0E2h, 32h		;  Fixup - byte match

locloop_31:
		inc	bp
;*		loop	locloop_52		;*Loop if cx > 0

		db	0E2h, 4Eh		;  Fixup - byte match
		push	sp
		inc	dx

locloop_32:
		loop	locloop_50		; Loop if cx > 0


locloop_33:
		push	bp
;*		loop	locloop_47		;*Loop if cx > 0

		db	0E2h, 32h		;  Fixup - byte match

locloop_34:
		inc	bp

locloop_35:
		loop	$+50h			; Loop if cx > 0

		push	sp
		loop	locloop_48		; Loop if cx > 0

		push	bp

locloop_36:
		test	byte ptr [bx+di],5Fh	; '_'
		add	sp,dx
		dec	si
		inc	dx
		push	bx

locloop_38:
		push	dx
		push	dx

locloop_39:
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx
		push	dx

locloop_40:
		push	dx

locloop_41:
		sti				; Enable interrupts
		mov	bh,2
;*		push	ax
		db	0FFh,0F0h		;  Fixup - byte match

locloop_42:
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match

locloop_43:
		or	ax,0F0FFh
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		or	ax,0F0FFh
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		or	ax,0F0FFh

locloop_46:
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		or	ax,0F0FFh
;*		add	cx,bp
		db	 01h,0E9h		;  Fixup - byte match
		or	ax,44FFh

locloop_48:
		inc	bx

locloop_49:
		add	byte ptr [bx+si+3Fh],47h	; 'G'

locloop_50:
		inc	si
		cmp	ax,413Eh
		inc	dx
		xor	[si],bh
		cmp	[bx+si],di
		db	 36h, 34h, 31h, 44h, 3Fh, 38h
		db	 80h
		db	'9=GECIFBJ>3,-49@78D;?'
		db	80h
		db	'=GECIFB?JD>8'
		db	80h
		db	'9=GEC;6/07<C:;G>B'
		db	80h
		db	'@JHFLIEBMLGA;'
		db	 80h, 3Ch, 40h
		db	'JHF6/07<C:;G>134689DE@?=<BCEFHIJ'
		db	'LMOPR18=9D?3'
		db	80h
		db	'50<.-6;@GB6;@<'
		db	 80h, 35h, 31h
		db	'03.-9ED>BA=@?986532DPOMLJIF97643'
		db	'10-,28@D@;,32-106/7<C:G>'
		db	 80h, 26h, 22h, 24h, 2Ah, 06h
		db	 05h, 0Ch,0FFh, 30h, 2Eh, 0Ch
		db	 0Bh, 48h,0FFh, 03h, 03h, 18h
		db	 17h, 0Ch, 0Dh, 60h, 60h, 06h
		db	 06h, 06h, 05h, 30h,0FFh, 00h
		db	 01h, 06h, 01h, 24h, 01h, 04h
		db	 23h, 00h, 2Ch, 00h, 8Dh, 00h
		db	 37h, 01h, 43h, 01h, 76h, 01h
		db	 3Ah, 02h,0D9h, 02h, 3Ch, 03h
		db	0AEh, 01h, 76h, 04h,0B2h, 04h
		db	 6Bh, 04h, 07h, 05h, 0Ch,0B0h
		db	 01h, 05h, 01h, 01h,0F0h, 00h
		db	 80h,0D4h,0E5h, 0Fh,0FBh, 40h
		db	 02h,0F0h, 00h, 81h,0E5h, 1Fh
		db	0D3h, 01h, 02h, 04h, 05h, 07h
		db	 08h, 19h, 1Ah, 29h, 2Ah, 29h
		db	 2Ah, 09h,0E4h, 39h, 0Ah, 18h
		db	 15h, 14h, 12h, 01h, 32h, 14h
		db	 16h, 17h, 18h, 1Ah, 1Bh,0E4h
		db	 11h, 12h, 13h, 15h, 16h, 18h
		db	 19h, 1Bh,0E1h, 02h,0E5h, 17h
		db	0F0h, 00h, 80h,0FCh, 14h, 04h
		db	 40h,0FCh, 14h, 04h,0D3h, 16h
		db	 12h, 11h, 12h, 14h,0E4h, 11h
		db	0E3h, 14h,0E3h, 1Bh, 1Ah, 1Bh
		db	 00h,0FCh, 32h, 04h, 40h,0FCh
		db	 32h, 04h,0D3h, 16h, 12h, 11h
		db	 12h, 14h,0E4h, 11h
loc_53:
;*		jcxz	loc_55			;*Jump if cx=0
		db	0E3h, 14h		;  Fixup - byte match
		jcxz	loc_56			; Jump if cx=0
		sbb	bl,[bp+di]
;*		add	bl,bh
		db	 00h,0FBh		;  Fixup - byte match
		pop	bx
loc_54:
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
		add	ss:data_12e[bp+si],al
;*		aam	51h			; 'Q' undocumented inst
		db	0D4h, 51h		;  Fixup - byte match
		jcxz	loc_57			; Jump if cx=0
		in	al,1Ah			; port 1Ah ??I/O Non-standard
		sbb	[bp+di],dx
		pop	ss
		push	ss
		adc	dl,[di]
		adc	al,0E3h
		sbb	bl,[bx+di]
loc_56:
		pop	ss
		push	ss
		adc	al,13h
		in	al,13h			; port 13h ??I/O Non-standard
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
		sbb	[bx+si],bx
		push	ss
		adc	ax,1213h
loc_57:
;*		jcxz	loc_58			;*Jump if cx=0
		db	0E3h, 1Bh		;  Fixup - byte match
		and	bp,7
		rcr	word ptr [bp+si],cl	; Rotate thru carry
		sbb	[bx],dl
		adc	ax,1214h
;*		adc	bx,sp
		db	 11h,0E3h		;  Fixup - byte match
		sbb	dh,al
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		sbb	[bx+di],ax
		rcr	word ptr [bx+di],cl	; Rotate thru carry
		adc	al,0E3h
		sbb	[bp+si],bx
		in	al,15h			; port 15h ??I/O Non-standard
		sbb	ah,ah
		adc	ax,18E3h
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
		sbb	[di],dx
;*		jcxz	loc_59			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		cld				; Clear direction
		sbb	[bx+di],ax
		rcr	word ptr [si],cl	; Rotate thru carry
		pop	ss
;*		jcxz	loc_60			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		in	al,11h			; port 11h ??I/O Non-standard
;*		sbb	ah,ah
		db	 18h,0E4h		;  Fixup - byte match
		adc	[bx+si],bx
		jcxz	loc_61			; Jump if cx=0
		sbb	al,0E4h
		sbb	al,18h
		adc	di,sp
		sbb	[bx+di],ax
		rcr	word ptr [si],cl	; Rotate thru carry
		pop	ss
;*		jcxz	loc_62			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		in	al,11h			; port 11h ??I/O Non-standard
;*		sbb	ah,ah
		db	 18h,0E4h		;  Fixup - byte match
		adc	[bx+si],bx
		jcxz	loc_63			; Jump if cx=0
		sbb	al,0E4h
		sbb	al,18h
		adc	di,sp
loc_61:
		sbb	[bx+di],ax
		rcr	word ptr [si],cl	; Rotate thru carry
		pop	ss
;*		jcxz	loc_64			;*Jump if cx=0
		db	0E3h, 1Ch		;  Fixup - byte match
		in	al,11h			; port 11h ??I/O Non-standard
;*		sbb	ah,ah
		db	 18h,0E4h		;  Fixup - byte match
		adc	[bx+si],bx
		jcxz	loc_65			; Jump if cx=0
		sbb	al,0E4h
		sbb	al,18h
		adc	di,bx
loc_63:
		mov	di,data_17e
;*		add	ch,dh
		db	 00h,0F5h		;  Fixup - byte match
;*		and	al,dh
		db	 20h,0F0h		;  Fixup - byte match
;*		add	dl,dl
		db	 00h,0D2h		;  Fixup - byte match
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
		adc	al,13h
		jcxz	loc_66			; Jump if cx=0
		in	al,12h			; port 12h ??I/O Non-standard
;*		adc	bx,sp
		db	 11h,0E3h		;  Fixup - byte match
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
loc_65:
		adc	al,13h
		jcxz	loc_68			; Jump if cx=0
		in	al,12h			; port 12h ??I/O Non-standard
;*		adc	si,si
		db	 11h,0F6h		;  Fixup - byte match
		sbb	ax,0FE01h
                           lock	add	[bx+si],dl
		adc	ah,0E5h
		daa				; Decimal adjust
		loopz	locloop_67		; Loop if zf=1, cx>0

loc_66:
		sti				; Enable interrupts
		inc	ax
		add	dh,al
		add	[bx+si],dl

locloop_67:
		and	bp,0D327h
loc_68:
		add	[bp+si],ax
		add	al,5
		pop	es
		or	[bx+di],bl
		sbb	ch,[bx+di]
		sub	ch,[bx+di]
		sub	cl,[bx+di]
		in	al,39h			; port 39h ??I/O Non-standard
		or	bl,[bx+si]
		adc	ax,1214h
		add	[bp+si],si
		adc	al,16h
		pop	ss
		sbb	[bp+si],bl
		sbb	sp,sp
		adc	[bp+si],dx
		adc	dx,[di]
		push	ss
		sbb	[bx+di],bl
		sbb	sp,cx
		cli				; Disable interrupts
		in	ax,27h			; port 27h ??I/O Non-standard
		sti				; Enable interrupts
		pop	bx
;*		add	al,dh
		db	 00h,0F0h		;  Fixup - byte match
		add	[bx+si],dl
;*		and	ch,27h			; '''
		db	 82h,0E5h, 27h		;  Fixup - byte match
;*		aam	0E1h			; undocumented inst
		db	0D4h,0E1h		;  Fixup - byte match
		add	dl,[bx+di-1Dh]
		sbb	ah,ah
		sbb	bl,[bx+di]
		adc	dx,[bx]
		push	ss
		adc	dl,[di]
		adc	al,0E3h
		sbb	bl,[bx+di]
		pop	ss
		push	ss
		adc	al,13h
		in	al,13h			; port 13h ??I/O Non-standard
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
		sbb	[bx+si],bx
		push	ss
		adc	ax,1213h
		jcxz	$+1Dh			; Jump if cx=0
		and	bp,17h
		rcr	word ptr [bp+si],cl	; Rotate thru carry
		sbb	[bx],dl
		adc	ax,1214h
;*		adc	bx,sp
		db	 11h,0E3h		;  Fixup - byte match
		sbb	bh,bl
		mov	di,data_17e
;*		add	al,dl
		db	 00h,0D0h		;  Fixup - byte match
;*		add	ch,cl
		db	 00h,0CDh		;  Fixup - byte match
		add	cx,di
;*		or	si,cx
		db	 09h,0CEh		;  Fixup - byte match
		or	dl,cl
		or	ah,[bx+si]
		db	0C0h, 20h, 30h,0C1h,0CFh, 06h
		db	8 dup (18h)
		db	0F0h, 00h,0C0h,0CFh, 07h, 12h
		db	 18h, 30h, 06h, 18h, 30h, 06h
		db	 38h, 06h, 18h, 38h, 06h,0FCh
		db	 0Bh, 02h,0C1h,0CFh, 06h, 3Ah
		db	 2Ah, 18h, 18h, 18h, 18h, 18h
		db	0C0h,0CFh, 07h, 10h, 18h, 30h
		db	 06h, 18h, 30h, 06h, 38h, 06h
		db	 18h, 38h, 06h,0FCh, 0Bh, 02h
		db	0C1h,0CFh, 06h
		db	12 dup (18h)
		db	0FBh,0C9h, 01h,0F0h, 00h,0C0h
		db	0F5h, 0Ch,0F0h, 00h, 10h, 18h
		db	 30h, 06h, 18h, 30h, 06h, 38h
		db	 06h, 38h, 06h, 10h, 10h, 18h
		db	 30h, 06h, 18h, 30h, 06h, 38h
		db	 06h, 18h, 38h, 06h,0F6h, 10h
		db	 02h, 10h, 18h, 30h, 06h, 18h
		db	 30h, 06h, 38h, 06h, 38h, 06h
		db	 10h,0FEh,0F0h, 00h, 80h,0D4h
		db	0E5h, 17h,0F0h, 00h,0E0h, 87h
		db	 19h, 18h, 00h, 15h, 14h, 00h
		db	 1Ch, 1Bh, 00h, 18h, 19h, 00h
		db	 62h, 03h, 04h, 05h, 06h, 07h
		db	 18h, 17h, 15h, 14h, 12h,0E3h
		db	 11h, 11h,0E4h, 11h, 11h,0E3h
		db	 1Ah, 19h, 17h, 15h, 12h,0F0h
		db	 00h,0FCh, 8Eh, 03h,0FCh,0ADh
		db	 03h,0FCh, 8Eh, 03h,0E3h, 19h
		db	 14h,0E3h, 19h, 1Ah,0E4h, 15h
		db	 1Ah,0E4h, 15h,0E3h, 18h, 19h
		db	0E4h, 19h, 15h,0E3h, 1Ch,0FCh
		db	 8Eh, 03h,0FCh,0ADh, 03h,0FCh
		db	 8Eh, 03h,0E3h, 1Ch, 17h,0E3h
		db	 1Ch,0E4h, 11h, 18h,0E4h, 11h
		db	 18h,0E3h, 1Bh, 1Ch,0E4h, 1Ch
		db	 18h, 13h,0FCh,0D0h, 03h,0FCh
		db	0F1h, 03h,0FCh,0D0h, 03h,0E3h
		db	 1Ch, 17h,0E3h, 1Ch,0E4h, 11h
		db	 18h,0E4h, 11h, 18h,0E3h, 1Bh
		db	 1Ch,0E4h, 1Ch, 18h, 13h,0FCh
		db	0D0h, 03h,0FCh,0F1h, 03h,0FCh
		db	0D0h, 03h,0E3h, 1Ch, 17h,0E3h
		db	 1Ch,0E4h, 11h, 18h,0E4h, 11h
		db	 18h,0E3h, 1Bh, 1Ch,0E4h, 1Ch
		db	 18h, 13h,0FBh, 67h, 02h,0F0h
		db	 00h,0E1h, 20h, 81h,0E5h, 17h
		db	0D2h, 01h, 02h, 04h, 05h
loc_69:
		pop	es
		or	[bx+di],bl
		sbb	ch,[bx+di]
		sub	ch,[bx+di]
loc_70:
		sub	cl,[bx+di]
		in	al,39h			; port 39h ??I/O Non-standard
		or	bl,[bx+si]
		adc	ax,1214h
		add	[bp+si],si
		adc	al,16h
		pop	ss
		sbb	[bp+si],bl
		sbb	sp,sp
		adc	[bp+si],dx
		adc	dx,[di]
		push	ss
		sbb	[bx+di],bl
		sbb	sp,cx
;*		adc	al,dh
		db	 10h,0F0h		;  Fixup - byte match
		add	ds:data_12e[bx+si],al
		cld				; Clear direction
		adc	al,4
		inc	ax
		cld				; Clear direction
		adc	al,4
		rcl	word ptr ds:data_11e,cl	; Rotate thru carry
		adc	dl,[si]
		in	al,11h			; port 11h ??I/O Non-standard
		jcxz	loc_71			; Jump if cx=0
;*		jcxz	loc_72			;*Jump if cx=0
		db	0E3h, 1Bh		;  Fixup - byte match
		sbb	bl,[bp+di]
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		xor	al,[si]
		inc	ax
		cld				; Clear direction
		xor	al,[si]
		rcl	word ptr ds:data_11e,cl	; Rotate thru carry
		adc	dl,[si]
		in	al,11h			; port 11h ??I/O Non-standard
loc_71:
		jcxz	loc_73			; Jump if cx=0
		jcxz	loc_74			; Jump if cx=0
		sbb	bl,[bp+di]
;*		add	bl,bh
		db	 00h,0FBh		;  Fixup - byte match
		or	[bp+di],al
                           lock	add	ss:data_18e[bp+si],al
		rcl	word ptr [bx+di-1Dh],cl	; Rotate thru carry
		sbb	ah,ah
		sbb	bl,[bx+di]
loc_73:
		adc	dx,[bx]
		push	ss
		adc	dl,[di]
		adc	al,0E3h
		sbb	bl,[bx+di]
loc_74:
		pop	ss
		push	ss
		adc	al,13h
		in	al,13h			; port 13h ??I/O Non-standard
;*		sbb	sp,sp
		db	 19h,0E4h		;  Fixup - byte match
		sbb	[bx+si],bx
		push	ss
		adc	ax,1213h
		jcxz	$+1Dh			; Jump if cx=0
		and	bp,0Fh
		rcr	byte ptr [bp+si],cl	; Rotate thru carry
		sbb	[bx],dl
		adc	ax,1214h
;*		adc	bx,sp
		db	 11h,0E3h		;  Fixup - byte match
		sbb	dh,al
;*		add	ah,bh
		db	 00h,0FCh		;  Fixup - byte match
		dec	sp
		add	al,84h
		sbb	[bx+si+18h],dh
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		cld				; Clear direction
		dec	sp
		add	al,84h
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		sbb	[bx+si],bl
		sti				; Enable interrupts
		db	 6Eh, 03h,0F0h, 00h,0D4h, 09h
		db	 19h, 19h, 19h, 19h, 09h, 04h
		db	0E3h, 19h, 10h, 1Ah,0E4h, 12h
		db	 1Ch, 1Ah, 18h, 14h, 19h, 13h
		db	0E3h, 19h,0E4h,0E4h, 12h,0E3h
		db	 1Bh, 17h,0FEh,0F0h, 00h, 14h
		db	0E4h, 13h, 12h,0E3h, 19h, 14h
		db	 13h, 09h, 04h,0E3h, 19h, 10h
		db	 1Ah,0E4h, 12h, 1Ch, 1Ah, 18h
		db	 14h, 19h, 14h,0E3h, 19h,0E4h
		db	 13h, 14h,0E4h, 13h,0F0h, 01h
		db	 00h,0FEh,0F0h, 01h,0D4h, 1Ch
		db	 2Ch, 2Ch, 2Ch, 2Ch, 1Ch, 17h
		db	0E3h, 2Ch, 20h,0E4h, 21h, 25h
		db	0E4h, 23h, 21h,0E3h, 2Bh, 27h
		db	 2Ch, 27h,0E3h, 2Ch,0E4h,0E4h
		db	 25h, 22h,0E3h, 2Bh,0FEh,0F0h
		db	 01h, 27h,0E4h, 26h, 25h,0E3h
		db	 2Ch, 27h, 26h, 1Ch, 17h,0E3h
		db	 2Ch, 20h,0E4h, 21h, 25h,0E4h
		db	 23h, 21h,0E3h, 2Bh, 27h, 2Ch
		db	 27h,0E3h, 2Ch,0E4h, 26h, 27h
		db	0E4h, 26h, 00h,0FEh,0F0h, 01h
		db	0F5h, 20h,0F0h, 01h,0D3h, 24h
		db	 29h,0E4h, 22h,0E3h, 2Ah,0E4h
		db	 29h, 24h,0E3h, 24h, 29h,0E4h
		db	 22h,0E3h, 2Ah,0E4h, 29h, 24h
		db	0F6h, 18h, 04h,0FEh,0F0h, 01h
		db	0F5h, 20h,0F0h, 01h,0D3h, 27h
		db	 2Ch,0E4h, 25h, 21h, 2Ch, 27h
		db	0E3h, 27h, 2Ch,0E4h, 25h, 21h
		db	 2Ch, 27h,0F6h, 36h, 04h,0FEh
		db	0F0h, 01h, 83h,0F5h, 20h,0F0h
		db	 01h,0D1h, 29h,0E4h, 24h, 23h
		db	0E3h, 2Ah,0E4h, 22h, 21h,0E3h
		db	 29h,0E4h, 24h, 23h, 84h, 28h
		db	 83h, 22h, 21h,0F6h, 51h, 04h
		db	0FEh, 0Ch, 06h, 03h, 18h, 48h
		db	 60h, 30h, 24h, 90h, 0Ch, 06h
		db	 00h, 00h, 00h, 02h, 02h, 01h
		db	 34h, 31h, 40h, 40h,0F1h,0F1h
		db	 15h, 15h, 05h, 12h, 08h, 08h
		db	 05h, 05h, 01h, 21h, 22h, 12h
		db	 00h,0F8h, 55h, 35h, 36h, 0Eh
		db	 0Eh, 08h, 08h, 05h, 05h, 01h
		db	0B4h,0A1h, 61h, 00h, 47h,0F0h
		db	 25h, 04h, 04h, 00h, 00h, 00h
		db	 02h, 02h, 01h,0E0h, 21h, 8Eh
		db	 00h,0F4h,0F5h, 32h, 36h, 08h
		db	 01h, 06h, 06h, 07h, 07h, 01h
		db	 00h, 01h, 03h, 0Eh, 05h, 5Fh
		db	 31h, 1Fh, 38h, 00h, 04h, 00h
		db	 2Bh, 2Bh, 02h, 02h, 01h, 00h
		db	 01h, 05h, 17h, 03h, 5Fh, 11h
		db	 0Fh, 38h, 00h, 03h, 10h, 17h
		db	 17h, 03h, 03h, 01h, 00h, 01h
		db	 03h, 06h, 07h, 5Fh, 24h, 1Fh
		db	 38h, 00h, 04h, 00h, 00h, 00h
		db	 02h, 02h, 81h, 01h, 02h,0D0h
		db	 01h, 07h, 99h, 01h,0FFh, 38h
		db	 00h, 05h, 01h,0E5h, 47h, 06h
		db	 02h, 01h, 00h, 02h, 09h, 38h
		db	 09h, 5Fh, 01h, 2Fh, 87h, 00h
		db	8

_393UNKN	endp

seg_a		ends



		end	start
