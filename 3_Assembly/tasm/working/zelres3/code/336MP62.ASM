
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_336MP62                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_1e		equ	8CC4h			;*
data_2e		equ	90C4h			;*
data_3e		equ	0FAC4h			;*
data_4e		equ	0FFFFh			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_336MP62	proc	far

start:
		db	0D6h, 06h, 00h, 00h, 0Fh,0C5h

locloop_1:
		dec	cx
		add	ss:data_1e[bp+si],cl
		les	cx,dword ptr ss:data_2e[bp]	; Load seg:offset ptr
		les	bp,dword ptr ss:data_3e[bp+si]	; Load seg:offset ptr
		les	dx,dword ptr [si]	; Load seg:offset ptr
		lds	ax,dword ptr ds:data_4e	; Load seg:offset ptr
		add	[bp+si],cl
		add	[bx+si],al
		mov	al,ah
		loopnz	$+31h			; Loop if zf=0, cx>0

		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 2Fh, 04h
		db	0E0h, 84h,0E0h, 63h,0E0h, 84h
		db	0E0h, 2Fh, 04h,0E0h, 84h,0E0h
		db	 63h,0E0h, 84h,0E0h, 2Fh, 04h
		db	0E0h, 84h,0E0h, 63h,0E0h, 84h
		db	0E0h, 2Fh, 04h,0E0h, 84h,0E0h
		db	 63h,0E0h, 84h,0E0h, 2Fh, 04h
		db	0E0h, 84h,0E0h, 63h,0E0h, 84h
		db	0E0h, 2Fh, 04h,0E0h, 84h

locloop_2:
;*		loopnz	locloop_11		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	$-7Ah			; Loop if zf=0, cx>0

;*		loopnz	locloop_5		;*Loop if zf=0, cx>0

		db	0E0h, 22h		;  Fixup - byte match
		add	al,0Dh
		and	byte ptr ds:[63E0h][si],al
		loopnz	$-7Ah			; Loop if zf=0, cx>0

;*		loopnz	locloop_4		;*Loop if zf=0, cx>0

		db	0E0h, 12h		;  Fixup - byte match
		add	al,0A2h
;*		loopnz	locloop_13		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	$-7Ah			; Loop if zf=0, cx>0

		add	sp,[bx+si]

locloop_3:
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		add	al,0A2h
;*		loopnz	locloop_14		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	$-7Ah			; Loop if zf=0, cx>0

;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match

locloop_4:
		add	al,0A2h
;*		loopnz	locloop_15		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_1		; Loop if zf=0, cx>0


locloop_5:
;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,0A2h
;*		loopnz	locloop_16		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	$-7Ah			; Loop if zf=0, cx>0

;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,84h
		or	ax,[si]
		or	al,20h			; ' '
		test	sp,ax
		db	 63h,0E0h, 84h, 83h,0E0h, 0Fh
		db	 04h, 84h,0C4h, 01h, 20h, 14h
		db	 04h,0E0h, 85h,0E0h, 63h, 03h
		db	 20h, 81h, 83h,0E0h, 0Fh, 04h

locloop_7:
		test	al,[bp+di]
		and	[bp+di],dl
		add	al,0E0h
		test	sp,ax
		push	es
		add	al,0E0h
		add	word ptr ss:[0FE0h][bp+di],8404h

locloop_11:
		add	sp,[bx+si]
		adc	ax,[si]
		loopnz	$-79h			; Loop if zf=0, cx>0

;*		loopnz	locloop_12		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,0E0h
		add	word ptr ss:[0FE0h][bp+di],8404h
		add	sp,[bx+si]

locloop_13:
		adc	ax,[si]
		loopnz	locloop_2		; Loop if zf=0, cx>0

		or	[bx+si],ah
		add	word ptr ss:[0FE0h][bp+di],8404h
		add	sp,[bx+si]
		adc	ax,[si]
		loopnz	locloop_3		; Loop if zf=0, cx>0


locloop_15:
;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
		db	 12h, 04h,0E0h

locloop_16:
		pop	word ptr ss:[0FE0h][bp+di]
		add	al,88h
		retn
		db	 12h, 04h,0E0h, 8Fh

locloop_17:
;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
			                        ;* No entry point to code
		adc	al,[si]
		loopnz	$-6Fh			; Loop if zf=0, cx>0

;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
			                        ;* No entry point to code
		adc	al,[si]
		loopnz	$-6Fh			; Loop if zf=0, cx>0

;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
		db	 12h, 04h,0E0h, 8Fh, 83h

locloop_19:
;*		loopnz	locloop_20		;*Loop if zf=0, cx>0

		db	0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
			                        ;* No entry point to code
		adc	al,[si]
		loopnz	locloop_7		; Loop if zf=0, cx>0

;*		and	ax,0Fh
		db	 83h,0E0h, 0Fh		;  Fixup - byte match
		add	al,88h
		retn
		db	 12h, 04h

locloop_20:
		loopnz	locloop_7		; Loop if zf=0, cx>0

		or	[bx+si],ah
		add	word ptr ss:[0FE0h][bp+di],8804h
		retn
			                        ;* No entry point to code
		adc	al,[si]
;*		loopnz	locloop_8		;*Loop if zf=0, cx>0

		db	0E0h, 85h		;  Fixup - byte match
;*		loopnz	locloop_21		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,0E0h
		add	word ptr ss:[0FE0h][bp+di],8804h
		retn
			                        ;* No entry point to code
		push	es
		add	al,0Ch
		and	byte ptr ds:[6E0h][di],al
		add	al,0E0h
		add	word ptr ss:[0FE0h][bp+di],8804h
		retn
			                        ;* No entry point to code
		push	es
		add	al,0E0h
		xchg	cx,ax
;*		loopnz	locloop_23		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		add	sp,[bx+si]
		add	word ptr ss:[0FE0h][bp+di],8804h
		retn
		db	 06h, 04h,0E0h,0C2h,0C1h, 51h
		db	 40h,0C2h,0C1h,0C2h,0C1h, 41h
		db	0C1h, 41h, 81h,0E0h, 63h,0E0h
		db	 84h, 83h,0E0h, 0Fh, 04h, 88h
		db	0C3h, 06h, 04h,0E0h, 91h,0E0h
		db	 63h,0E0h, 84h, 83h,0E0h, 0Fh
		db	 04h, 88h,0C3h, 06h, 04h,0E0h
		db	 84h, 08h, 20h, 84h,0E0h, 63h
		db	0E0h, 84h, 03h, 20h, 0Fh, 04h
		db	 88h,0C3h, 06h, 04h,0E0h, 84h
		db	0E0h, 06h, 04h,0E0h, 84h,0E0h
		db	 63h,0E0h, 84h,0E0h, 12h, 04h
		db	 88h,0C3h, 06h, 04h,0E0h, 84h
		db	0E0h

locloop_22:
		push	es
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 12h, 04h

locloop_23:
;*		mov	bl,al
		db	 88h,0C3h		;  Fixup - byte match
		push	es
		add	al,0E0h
		test	ah,al
		push	es
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h

locloop_24:
		test	ah,al
		adc	al,[si]
;*		mov	bl,al
		db	 88h,0C3h		;  Fixup - byte match
		push	es
		add	al,0E0h
		test	ah,al
		push	es
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 12h, 04h
		db	 88h,0C3h, 06h

locloop_25:
		add	al,0E0h
		test	ah,al
		push	es
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 0Bh, 04h
		db	 8Fh,0C3h, 06h, 04h,0E0h, 84h
		db	0E0h, 06h

locloop_27:
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 0Bh, 04h
		db	0C2h, 40h, 51h,0C1h
		db	41h

locloop_28:
		db	0C1h,0C2h,0C1h, 41h, 81h,0C3h
		db	 06h, 04h

locloop_29:
		loopnz	$-7Ah			; Loop if zf=0, cx>0

		loopnz	$+55h			; Loop if zf=0, cx>0

		add	al,20h			; ' '
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 0Bh, 04h
		db	 8Fh,0C3h, 06h, 04h,0E0h, 84h
		db	0E0h, 53h,0E0h, 88h,0E0h

locloop_30:
		db	 63h,0E0h, 84h,0E0h, 0Bh, 04h
		db	 84h,0C3h, 01h, 20h, 43h, 01h
		db	 20h, 43h, 01h
		db	20h

locloop_31:
		pop	es
		add	al,0E0h
		test	ah,al
		push	bx
		loopnz	locloop_24		; Loop if zf=0, cx>0

;*		loopnz	locloop_44		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_24		; Loop if zf=0, cx>0

;*		loopnz	locloop_34		;*Loop if zf=0, cx>0

		db	0E0h, 0Bh		;  Fixup - byte match
		add	al,84h
		retn
			                        ;* No entry point to code
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp

locloop_34:
		pop	es
		add	al,0E0h
		test	ah,al
		push	bx
		loopnz	locloop_25		; Loop if zf=0, cx>0

;*		loopnz	locloop_48		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_25		; Loop if zf=0, cx>0

;*		loopnz	locloop_37		;*Loop if zf=0, cx>0

		db	0E0h, 0Bh		;  Fixup - byte match
		add	al,84h
		retn
		db	 43h, 01h, 20h, 43h, 01h

locloop_36:
		and	[bx+di],cl
		add	al,0E0h
		test	ah,al
		push	bx
		loopnz	locloop_27		; Loop if zf=0, cx>0

;*		loopnz	locloop_52		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_27		; Loop if zf=0, cx>0

;*		loopnz	locloop_39		;*Loop if zf=0, cx>0

		db	0E0h, 0Bh		;  Fixup - byte match
		add	al,84h
		retn
			                        ;* No entry point to code
		inc	bx
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp
		or	[si],ax

locloop_39:
		loopnz	locloop_28		; Loop if zf=0, cx>0

;*		loopnz	locloop_53		;*Loop if zf=0, cx>0

		db	0E0h, 53h		;  Fixup - byte match
		loopnz	locloop_29		; Loop if zf=0, cx>0

;*		loopnz	locloop_57		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_29		; Loop if zf=0, cx>0

;*		loopnz	locloop_43		;*Loop if zf=0, cx>0

		db	0E0h, 0Bh		;  Fixup - byte match
		add	al,84h
		retn
		db	 01h, 20h, 43h

locloop_42:
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp

locloop_43:
		pop	es
		add	al,0E0h
		test	ah,al
		push	bx
		loopnz	locloop_30		; Loop if zf=0, cx>0

		loopnz	$+65h			; Loop if zf=0, cx>0

		loopnz	locloop_30		; Loop if zf=0, cx>0

;*		loopnz	locloop_46		;*Loop if zf=0, cx>0

		db	0E0h, 0Bh		;  Fixup - byte match
		add	al,84h
		retn

locloop_45:
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp
		inc	bx
		add	[bx+si],sp

locloop_46:
		pop	es
		add	al,0E0h
		test	ah,al
		push	bx
;*		loopnz	locloop_32		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_63		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_32		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_49		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	 43h, 01h, 20h

locloop_49:
		inc	bx
		add	[bx+si],sp
		or	[si],ax
;*		loopnz	locloop_33		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_64		;*Loop if zf=0, cx>0

		db	0E0h, 53h		;  Fixup - byte match

locloop_51:
;*		loopnz	locloop_35		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_66		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_35		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_54		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h

locloop_53:
		retn
		db	 43h, 01h, 20h

locloop_54:
		inc	bx

locloop_55:
		add	[bx+si],sp
		or	[si],ax
		loopnz	locloop_36		; Loop if zf=0, cx>0

;*		loopnz	locloop_67		;*Loop if zf=0, cx>0

		db	0E0h, 53h		;  Fixup - byte match
;*		loopnz	locloop_38		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_69		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_38		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_58		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	 63h, 01h, 20h

locloop_58:
		or	[si],al
		add	sp,[bx+si]
		test	ah,al
		push	bx
;*		loopnz	locloop_40		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_71		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_40		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_60		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h

locloop_59:
		retn
		db	 63h, 01h, 20h

locloop_60:
		or	[si],al
		loopnz	locloop_42		; Loop if zf=0, cx>0

;*		loopnz	locloop_71		;*Loop if zf=0, cx>0

		db	0E0h, 53h		;  Fixup - byte match
		loopnz	locloop_43		; Loop if zf=0, cx>0

;*		loopnz	locloop_73		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_43		; Loop if zf=0, cx>0

;*		loopnz	locloop_62		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	 0Eh, 04h,0E0h

locloop_62:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match

locloop_63:
		push	bx
		loopnz	locloop_45		; Loop if zf=0, cx>0


locloop_64:
;*		loopnz	locloop_76		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_45		; Loop if zf=0, cx>0

;*		loopnz	locloop_65		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	 0Eh, 04h,0E0h

locloop_65:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	bx
;*		loopnz	locloop_47		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_78		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_47		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_68		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match

locloop_67:
		add	al,89h
		retn
		db	 63h, 01h, 20h

locloop_68:
		or	[si],al
;*		loopnz	locloop_50		;*Loop if zf=0, cx>0

		db	0E0h, 87h		;  Fixup - byte match
;*		loopnz	locloop_78		;*Loop if zf=0, cx>0

		db	0E0h, 53h		;  Fixup - byte match
		loopnz	locloop_51		; Loop if zf=0, cx>0

		loopnz	$+65h			; Loop if zf=0, cx>0

		loopnz	locloop_51		; Loop if zf=0, cx>0

;*		loopnz	locloop_70		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match

locloop_69:
		add	al,89h
		retn
		db	 63h, 01h, 20h

locloop_70:
		or	[si],al
		loopnz	locloop_55		; Loop if zf=0, cx>0

		loopnz	$+55h			; Loop if zf=0, cx>0

;*		loopnz	locloop_56		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
		loopnz	$+65h			; Loop if zf=0, cx>0

;*		loopnz	locloop_56		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
;*		loopnz	locloop_72		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	 0Eh, 04h,0E0h

locloop_72:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	bx
		loopnz	locloop_58		; Loop if zf=0, cx>0

;*		loopnz	locloop_80		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_58		; Loop if zf=0, cx>0

;*		loopnz	locloop_74		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	0Eh

locloop_73:
		add	al,0E0h

locloop_74:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	bx
		loopnz	locloop_59		; Loop if zf=0, cx>0

;*		loopnz	locloop_82		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
		loopnz	locloop_59		; Loop if zf=0, cx>0

;*		loopnz	locloop_77		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match
		add	al,89h
		retn
		db	0Eh

locloop_76:
		add	al,0E0h

locloop_77:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	bx
;*		loopnz	locloop_61		;*Loop if zf=0, cx>0

		db	0E0h, 88h		;  Fixup - byte match
;*		loopnz	locloop_85		;*Loop if zf=0, cx>0

		db	0E0h, 63h		;  Fixup - byte match
;*		loopnz	locloop_61		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
		loopnz	$+8			; Loop if zf=0, cx>0

		add	al,89h
		retn
		db	0Eh

locloop_78:
		add	al,0E0h
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	bx
		add	al,20h			; ' '
		test	ah,al
		db	 63h,0E0h, 84h,0E0h, 06h, 04h
		db	 89h,0C3h, 0Eh, 04h,0E0h, 87h
		db	0E0h, 06h, 04h,0E0h, 84h,0E0h
		db	 63h,0E0h, 84h,0E0h, 06h, 04h
		db	 89h,0C3h, 0Eh, 04h,0E0h, 87h
		db	0E0h, 06h, 04h,0E0h, 84h,0E0h
		db	 63h,0E0h, 84h,0E0h, 06h, 04h
		db	 89h,0C3h

locloop_79:
		push	cs
		add	al,0E0h
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	es
		add	al,0E0h
		test	ah,al
		db	 63h,0E0h, 84h,0E0h

locloop_81:
		push	es
		add	al,89h
		retn
		db	 0Eh, 04h,0E0h

locloop_82:
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	es
		add	al,0E0h
		test	ah,al

locloop_83:
		db	 63h,0E0h, 84h,0E0h, 06h

locloop_84:
		add	al,89h
		retn
		db	 0Eh, 04h

locloop_85:
;*		loopnz	locloop_75		;*Loop if zf=0, cx>0

		db	0E0h, 87h		;  Fixup - byte match
;*		loopnz	locloop_87		;*Loop if zf=0, cx>0

		db	0E0h, 06h		;  Fixup - byte match

locloop_86:
		add	al,0E0h
		test	al,[di]
		and	byte ptr ds:[6E0h][si],al
		add	al,89h
		retn
			                        ;* No entry point to code
		push	cs
		add	al,0E0h
;*		xchg	sp,ax
		db	 87h,0E0h		;  Fixup - byte match
		push	es
		add	al,0E0h
		db	 8Eh,0E0h, 06h, 04h, 89h,0C3h
		db	 0Eh, 04h,0E0h, 87h,0E0h, 06h
		db	 04h,0E0h, 40h, 41h,0C1h, 41h
		db	0C1h, 41h,0C1h,0C2h,0C1h, 81h
		db	0E0h, 06h, 04h, 89h,0C3h, 0Eh
		db	 04h,0E0h, 87h,0E0h, 06h, 04h
		db	0E0h, 8Eh,0E0h, 06h, 04h, 89h
		db	0C3h, 0Eh, 04h, 03h, 20h, 84h
		db	0E0h, 06h, 04h, 0Ah, 20h, 84h
		db	0E0h, 06h, 04h, 89h,0C3h, 11h
		db	 04h,0E0h, 84h,0E0h, 10h, 04h
		db	0E0h, 84h,0E0h, 06h, 04h, 89h
		db	0C3h, 11h, 04h,0E0h, 84h,0E0h
		db	 10h, 04h,0E0h

locloop_89:
		test	ah,al
		push	es
		add	al,89h
		retn
			                        ;* No entry point to code
		adc	[si],ax
		loopnz	locloop_83		; Loop if zf=0, cx>0

		or	ax,6320h
		loopnz	locloop_84		; Loop if zf=0, cx>0

;*		loopnz	locloop_91		;*Loop if zf=0, cx>0

		db	0E0h, 22h		;  Fixup - byte match
		add	al,0E0h
		xchg	cx,ax
		loopnz	$+65h			; Loop if zf=0, cx>0

		loopnz	locloop_86		; Loop if zf=0, cx>0

		loopnz	$+24h			; Loop if zf=0, cx>0

		add	al,0E0h
		xchg	cx,ax
		loopnz	$+65h			; Loop if zf=0, cx>0

;*		loopnz	locloop_88		;*Loop if zf=0, cx>0

		db	0E0h, 84h		;  Fixup - byte match
		loopnz	$+24h			; Loop if zf=0, cx>0

		add	al,0E0h
		xchg	cx,ax
		loopnz	$+65h			; Loop if zf=0, cx>0

		loopnz	$-7Ah			; Loop if zf=0, cx>0

		loopnz	$+24h			; Loop if zf=0, cx>0

		add	al,0Dh
		and	byte ptr ds:[63E0h][si],al
		loopnz	$-7Ah			; Loop if zf=0, cx>0

		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 28h, 00h, 25h, 80h, 17h, 39h
		db	 00h, 39h, 00h,0FFh,0FFh,0FFh
		db	 3Eh, 00h, 0Dh, 83h, 0Eh, 1Fh
		db	 00h, 05h, 00h,0FFh,0FFh,0FFh
		db	0FFh,0FFh, 2Ch, 00h, 08h, 74h
		db	0C6h, 00h,0FFh, 7Fh,0C6h,0FFh
		db	0FFh,0FFh,0FFh, 2Ch, 00h, 04h
		db	 84h,0C6h, 00h,0FFh, 8Fh,0C6h
		db	0FFh,0FFh,0FFh,0FFh, 2Ch, 00h
		db	 02h, 94h,0C6h, 00h,0FFh, 9Fh
		db	0C6h,0FFh,0FFh,0FFh,0FFh, 2Ch
		db	 00h, 01h,0A4h,0C6h, 00h,0FFh
		db	0AFh,0C6h,0FFh,0FFh,0FFh,0FFh
		db	 2Dh, 00h, 80h,0B4h,0C6h, 00h
		db	0FFh,0BFh,0C6h,0FFh,0FFh,0FFh
		db	0FFh, 2Dh, 00h, 40h,0C4h,0C6h
		db	 00h,0FFh,0CFh,0C6h,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 16h,0AFh
		db	 00h, 11h
		db	'Cavern of Arrugia'
		db	 13h, 00h, 05h, 0Ah, 0Ah, 08h
		db	 00h, 14h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 08h, 00h, 16h
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 08h, 00h, 18h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 08h
		db	 00h, 1Ah,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 08h, 00h, 1Ch
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 08h, 00h, 1Eh,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 08h
		db	 00h, 20h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 08h, 00h, 22h
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 0Ah, 00h, 14h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 0Ah
		db	 00h, 16h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 0Ah, 00h, 18h
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 0Ah, 00h, 1Ah,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 0Ah
		db	 00h, 1Ch,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 0Ah, 00h, 1Eh
		db	0FFh,0F1h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 0Ah, 00h, 20h,0FFh,0F1h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 0Ah
		db	 00h, 22h,0FFh,0F1h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 0Ch, 00h, 14h
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 0Ch, 00h, 16h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 0Eh
		db	 00h, 14h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 0Eh, 00h, 16h
		db	0FFh,0D0h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0FFh,0FFh, 00h, 00h
		db	 00h, 10h, 00h, 14h,0FFh,0D0h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0FFh,0FFh, 00h, 00h, 00h, 10h
		db	 00h, 16h,0FFh,0D0h, 00h, 00h
		db	 00h, 00h, 00h, 00h,0FFh,0FFh
		db	 00h, 00h, 00h, 12h, 00h, 1Ah
		db	0FFh, 73h, 00h, 07h, 20h, 00h
		db	 00h, 00h, 2Ch, 00h, 08h, 00h
		db	 00h, 1Bh, 00h, 1Ah,0FFh, 73h
		db	 00h, 00h, 20h, 00h, 1Eh, 00h
		db	 2Ch, 00h, 04h, 00h, 00h, 2Ch
		db	 00h, 34h,0FFh, 73h, 00h, 05h
		db	 20h, 00h, 00h, 00h, 2Ch, 00h
		db	 02h, 00h, 00h, 2Eh, 00h, 34h
		db	0FFh, 73h, 00h, 05h, 20h, 00h
		db	 00h, 00h, 2Ch, 00h, 01h, 00h
		db	 00h, 30h, 00h, 34h,0FFh, 73h
		db	 00h, 05h, 20h, 00h, 00h, 00h
		db	 2Dh, 00h, 80h, 00h, 00h, 37h
		db	 00h, 27h,0FFh, 73h, 00h, 00h
		db	 20h, 00h, 19h, 00h, 2Dh, 00h
		db	 40h, 00h, 00h,0FFh,0FFh

_336MP62	endp

seg_a		ends



		end	start
