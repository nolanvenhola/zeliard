
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				STICK	                                 €€
;€€					                                 €€
;€€      Created:   29-Mar-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_51e	equ	2000h			;*
data_52e	equ	2022h			;*
data_53e	equ	2026h			;*
data_54e	equ	2028h			;*
data_55e	equ	202Ah			;*
data_56e	equ	444Dh			;*
data_57e	equ	0FF00h			;*
data_58e	equ	0FF04h			;*
data_59e	equ	0FF09h			;*
data_60e	equ	0FF0Ah			;*
data_61e	equ	0FF0Ch			;*
data_62e	equ	0FF10h			;*
data_63e	equ	0FF16h			;*
data_64e	equ	0FF17h			;*
data_65e	equ	0FF18h			;*
data_66e	equ	0FF1Ah			;*
data_67e	equ	0FF1Bh			;*
data_68e	equ	0FF1Dh			;*
data_69e	equ	0FF1Eh			;*
data_70e	equ	0FF1Fh			;*
data_72e	equ	0FF27h			;*
data_73e	equ	0FF28h			;*
data_74e	equ	0FF29h			;*
data_75e	equ	0FF33h			;*
data_76e	equ	0FF3Bh			;*
data_77e	equ	0FF48h			;*
data_78e	equ	0FF49h			;*
data_79e	equ	0FF50h			;*
data_80e	equ	0FF74h			;*
data_81e	equ	0FF75h			;*
data_82e	equ	0FF78h			;*
data_83e	equ	0FF79h			;*
data_84e	equ	0B000h			;*
data_85e	equ	0			;*
data_86e	equ	0E34h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

stick		proc	far

start:
		jmp	loc_24
		jmp	loc_20
		jmp	loc_136
		jmp	loc_51
			                        ;* No entry point to code
		test	cl,[bp+si]
		pop	ss
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		lodsb				; String [si] to al
		push	es
		and	ax,[bx]
		mov	dh,7
		or	word ptr [bx+si],8EFh
		sbb	[bx+di],cl
		db	0D6h, 09h, 2Dh, 09h, 9Eh, 08h

stick		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		test	byte ptr cs:[2BEh],0FFh
		jz	loc_1			; Jump if zero
		test	byte ptr cs:data_63e,1
		jz	loc_2			; Jump if zero
		mov	byte ptr cs:[2BEh],0
		mov	byte ptr cs:data_68e,0FFh
		jmp	short loc_2
loc_1:
		test	byte ptr cs:data_63e,1
		jnz	loc_2			; Jump if not zero
		mov	byte ptr cs:[2BEh],0FFh
loc_2:
		test	byte ptr cs:[2BFh],0FFh
		jz	loc_4			; Jump if zero
		test	byte ptr cs:data_63e,2
		jnz	loc_3			; Jump if not zero
		retn
loc_3:
		mov	byte ptr cs:[2BFh],0
		mov	byte ptr cs:data_69e,0FFh
		retn
loc_4:
		test	byte ptr cs:data_63e,2
		jz	loc_5			; Jump if zero
		retn
loc_5:
		mov	byte ptr cs:[2BFh],0FFh
		retn
sub_1		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		test	byte ptr cs:data_76e,0FFh
		jnz	loc_6			; Jump if not zero
		retn
loc_6:
		test	byte ptr cs:data_60e,0FFh
		jnz	loc_7			; Jump if not zero
		retn
loc_7:
		mov	dx,201h
		in	al,dx			; port 201h, start game 1-shots
		call	sub_3
		jmp	short loc_11

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		test	byte ptr cs:[2C0h],0FFh
		jz	loc_9			; Jump if zero
		test	al,10h
		jz	loc_8			; Jump if zero
		retn
loc_8:
		mov	byte ptr cs:[2C0h],0
		mov	byte ptr cs:data_68e,0FFh
		retn
loc_9:
		test	al,10h
		jnz	loc_10			; Jump if not zero
		retn
loc_10:
		mov	byte ptr cs:[2C0h],0FFh
		retn
loc_11:
		test	byte ptr cs:[2C1h],0FFh
		jz	loc_13			; Jump if zero
		test	al,20h			; ' '
		jz	loc_12			; Jump if zero
		retn
loc_12:
		mov	byte ptr cs:[2C1h],0
		mov	byte ptr cs:data_69e,0FFh
		retn
loc_13:
		test	al,20h			; ' '
		jnz	loc_14			; Jump if not zero
		retn
loc_14:
		mov	byte ptr cs:[2C1h],0FFh
		retn
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_4		proc	near
		test	byte ptr cs:[2C2h],0FFh
		jz	loc_15			; Jump if zero
		cmp	word ptr cs:data_65e,1000h
		jne	loc_16			; Jump if not equal
		mov	byte ptr cs:data_81e,1
		mov	byte ptr cs:[2C2h],0
		mov	cl,cs:data_73e
		mov	ax,2
		int	60h			; ??INT Non-standard interrupt
		jmp	short loc_16
loc_15:
		cmp	word ptr cs:data_65e,1000h
		je	loc_16			; Jump if equal
		mov	byte ptr cs:[2C2h],0FFh
loc_16:
		test	byte ptr cs:[2C3h],0FFh
		jz	loc_18			; Jump if zero
		cmp	word ptr cs:data_65e,2000h
		je	loc_17			; Jump if equal
		retn
loc_17:
		mov	byte ptr cs:[2C3h],0
		not	byte ptr cs:data_72e
		mov	byte ptr cs:data_81e,1
		retn
loc_18:
		cmp	word ptr cs:data_65e,2000h
		jne	loc_19			; Jump if not equal
		retn
loc_19:
		mov	byte ptr cs:[2C3h],0FFh
		retn
sub_4		endp

loc_20:
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	bp
		push	ds
		push	es
		cld				; Clear direction
		call	dword ptr cs:data_62e
		call	dword ptr cs:data_61e
		dec	byte ptr cs:[2BCh]
		jnz	loc_21			; Jump if not zero
		mov	byte ptr cs:[2BCh],5
		call	sub_4
		call	sub_1
		call	sub_2
loc_21:
		inc	byte ptr cs:data_66e
		inc	word ptr cs:data_79e
		inc	word ptr cs:data_67e
		inc	byte ptr cs:[2C4h]
		test	byte ptr cs:data_70e+1,0FFh
		jz	loc_22			; Jump if zero
		call	word ptr cs:data_70e
loc_22:
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		dec	byte ptr cs:[2BDh]
		jz	loc_23			; Jump if zero
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		pop	ax
		iret				; Interrupt return
loc_23:
		mov	byte ptr cs:[2BDh],0Dh
		pop	ax
		jmp	dword ptr cs:data_58e
		db	 0Ah, 0Dh
		db	7 dup (0)
loc_24:
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		mov	ax,cs
		mov	ds,ax
		in	al,60h			; port 60h, keybd scan or sw1
		cmp	al,0FFh
		je	loc_27			; Jump if equal
		cmp	al,0FEh
		je	loc_27			; Jump if equal
		call	sub_5
loc_25:
		mov	ah,1
		int	16h			; Keyboard i/o  ah=function 01h
						;  get status, if zf=0  al=char
		jz	loc_26			; Jump if zero
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		jmp	short loc_25
loc_26:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	dword ptr cs:data_83e
loc_27:
		in	al,61h			; port 61h, 8255 port B, read
		or	al,80h
		out	61h,al			; port 61h, 8255 B - spkr, etc
		and	al,7Fh
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, speaker off
		mov	byte ptr cs:[5C1h],0
		mov	byte ptr cs:[5C2h],0
		mov	byte ptr cs:[5C3h],0
		mov	byte ptr cs:[5C4h],0
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		iret				; Interrupt return

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_5		proc	near
		push	ax
		call	sub_6
		pop	ax
		cmp	al,0E0h
		jb	loc_28			; Jump if below
		retn
loc_28:
		mov	ah,al
		and	al,7Fh
		mov	cl,8
		cmp	al,4Dh			; 'M'
		je	loc_29			; Jump if equal
		cmp	al,4Eh			; 'N'
		je	loc_29			; Jump if equal
		mov	cl,4
		cmp	al,4Bh			; 'K'
		je	loc_29			; Jump if equal
		cmp	al,2Bh			; '+'
		je	loc_29			; Jump if equal
		mov	cl,2
		cmp	al,50h			; 'P'
		je	loc_29			; Jump if equal
		cmp	al,4Ah			; 'J'
		je	loc_29			; Jump if equal
		mov	cl,1
		cmp	al,48h			; 'H'
		je	loc_29			; Jump if equal
		cmp	al,29h			; ')'
		jne	loc_31			; Jump if not equal
loc_29:
		or	byte ptr ds:[5C1h],cl
		test	ah,80h
		jnz	loc_30			; Jump if not zero
		jmp	loc_43
loc_30:
		xor	byte ptr ds:[5C1h],cl
		jmp	loc_43
loc_31:
		mov	cl,5
		cmp	al,47h			; 'G'
		je	loc_32			; Jump if equal
		mov	cl,90h
		cmp	al,49h			; 'I'
		je	loc_32			; Jump if equal
		mov	cl,60h			; '`'
		cmp	al,4Fh			; 'O'
		je	loc_32			; Jump if equal
		mov	cl,0Ah
		cmp	al,51h			; 'Q'
		jne	loc_34			; Jump if not equal
loc_32:
		or	byte ptr ds:[5C2h],cl
		test	ah,80h
		jnz	loc_33			; Jump if not zero
		jmp	loc_43
loc_33:
		xor	byte ptr ds:[5C2h],cl
		jmp	loc_43
loc_34:
		test	byte ptr ds:data_80e,0FFh
		jz	loc_35			; Jump if zero
		mov	byte ptr ds:[5C3h],0
		mov	byte ptr ds:[5C4h],0
		jmp	short loc_39
loc_35:
		mov	cl,8
		cmp	al,25h			; '%'
		je	loc_36			; Jump if equal
		mov	cl,4
		cmp	al,23h			; '#'
		je	loc_36			; Jump if equal
		mov	cl,2
		cmp	al,32h			; '2'
		je	loc_36			; Jump if equal
		mov	cl,1
		cmp	al,16h
		jne	loc_37			; Jump if not equal
loc_36:
		or	byte ptr ds:[5C3h],cl
		test	ah,80h
		jz	loc_41			; Jump if zero
		xor	byte ptr ds:[5C3h],cl
		jmp	short loc_41
loc_37:
		mov	cl,5
		cmp	al,15h
		je	loc_38			; Jump if equal
		mov	cl,90h
		cmp	al,17h
		je	loc_38			; Jump if equal
		mov	cl,60h			; '`'
		cmp	al,31h			; '1'
		je	loc_38			; Jump if equal
		mov	cl,0Ah
		cmp	al,33h			; '3'
		jne	loc_39			; Jump if not equal
loc_38:
		or	byte ptr ds:[5C4h],cl
		test	ah,80h
		jz	loc_41			; Jump if zero
		xor	byte ptr ds:[5C4h],cl
		jmp	short loc_41
loc_39:
		mov	cl,1
		cmp	al,39h			; '9'
		je	loc_40			; Jump if equal
		mov	cl,2
		cmp	al,38h			; '8'
		jne	loc_41			; Jump if not equal
loc_40:
		or	ds:data_63e,cl
		test	ah,80h
		jz	loc_41			; Jump if zero
		xor	ds:data_63e,cl
		jmp	short loc_41
loc_41:
		mov	cx,800h
		cmp	al,25h			; '%'
		je	loc_42			; Jump if equal
		mov	cx,400h
		cmp	al,13h
		je	loc_42			; Jump if equal
		mov	cx,200h
		cmp	al,12h
		je	loc_42			; Jump if equal
		mov	cx,100h
		cmp	al,24h			; '$'
		je	loc_42			; Jump if equal
		mov	cx,80h
		cmp	al,1Fh
		je	loc_42			; Jump if equal
		mov	cx,40h
		cmp	al,31h			; '1'
		je	loc_42			; Jump if equal
		mov	cx,20h
		cmp	al,15h
		je	loc_42			; Jump if equal
		mov	cx,10h
		cmp	al,10h
		je	loc_42			; Jump if equal
		mov	cx,8
		cmp	al,1
		je	loc_42			; Jump if equal
		mov	cx,4
		cmp	al,1Dh
		je	loc_42			; Jump if equal
		mov	cx,2
		cmp	al,36h			; '6'
		je	loc_42			; Jump if equal
		cmp	al,2Ah			; '*'
		je	loc_42			; Jump if equal
		mov	cx,1
		cmp	al,1Ch
		je	loc_42			; Jump if equal
		mov	cx,1000h
		cmp	al,3Bh			; ';'
		je	loc_42			; Jump if equal
		mov	cx,2000h
		cmp	al,3Ch			; '<'
		je	loc_42			; Jump if equal
		mov	cx,4000h
		cmp	al,41h			; 'A'
		je	loc_42			; Jump if equal
		mov	cx,8000h
		cmp	al,43h			; 'C'
		jne	loc_43			; Jump if not equal
loc_42:
		or	ds:data_65e,cx
		test	ah,80h
		jz	loc_43			; Jump if zero
		xor	ds:data_65e,cx
loc_43:
		mov	al,byte ptr ds:[5C1h]
		or	al,byte ptr ds:[5C3h]
		mov	ah,byte ptr ds:[5C2h]
		and	ah,0Fh
		or	al,ah
		mov	ah,byte ptr ds:[5C2h]
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		or	al,ah
		mov	ah,byte ptr ds:[5C4h]
		and	ah,0Fh
		or	al,ah
		mov	ah,byte ptr ds:[5C4h]
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		shr	ah,1			; Shift w/zeros fill
		or	al,ah
		mov	ds:data_64e,al
		retn
sub_5		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		cmp	al,0E0h
		jb	loc_44			; Jump if below
		mov	byte ptr cs:[5C5h],0FFh
		retn
loc_44:
		test	byte ptr cs:[5C5h],0FFh
		mov	byte ptr cs:[5C5h],0
		jz	loc_45			; Jump if zero
		retn
loc_45:
		or	al,al			; Zero ?
		jns	loc_46			; Jump if not sign
		retn
loc_46:
		cmp	al,54h			; 'T'
		jb	loc_47			; Jump if below
		retn
loc_47:
		dec	al
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	di,511h
		test	word ptr cs:data_65e,2
		jz	loc_48			; Jump if zero
		mov	di,569h
loc_48:
		mov	al,cs:[bx+di]
		mov	cs:data_74e,al
		retn
sub_6		endp

		db	0
		db	'1234567890'
		db	0, 0, 8, 0
		db	'QWERTYUIOP'
		db	 00h, 00h, 0Dh, 00h
		db	'ASDFGHJKL'
		db	0, 0, 0, 0, 0
		db	 5Ah, 58h, 43h, 56h, 42h, 4Eh
		db	 4Dh
		db	39 dup (0)
		db	 21h, 40h, 00h, 24h, 25h, 00h
		db	 00h, 00h, 28h, 29h, 00h, 00h
		db	 08h, 00h
		db	'QWERTYUIOP{}', 0Dh
		db	0
		db	'ASDFGHJKL:'
		db	0, 0, 0, 0
		db	 5Ah, 58h, 43h, 56h, 42h, 4Eh
		db	 4Dh
		db	47 dup (0)

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		mov	dx,201h
		xor	si,si			; Zero register
		xor	di,di			; Zero register
		mov	cl,1
		mov	ch,2
		xor	bh,bh			; Zero register
		cli				; Disable interrupts
		mov	ah,3
		out	dx,al			; port 201h, start game 1-shots
		mov	bl,6
loc_49:
		in	al,dx			; port 201h, start game 1-shots
		xor	al,ah
		jz	loc_50			; Jump if zero
		dec	bl
		jnz	loc_49			; Jump if not zero
loc_50:
		in	al,dx			; port 201h, start game 1-shots
		mov	ah,al
		and	ah,ch
		shr	ah,1			; Shift w/zeros fill
		mov	bl,al
		and	bl,cl
		add	si,bx
		mov	bl,ah
		add	di,bx
		and	al,3
		jnz	loc_50			; Jump if not zero
		sti				; Enable interrupts
		retn
sub_7		endp

loc_51:
		push	bx
		push	cx
		push	dx
		mov	byte ptr cs:data_77e,0
		mov	byte ptr cs:data_78e,0
		mov	al,cs:data_76e
		and	al,ds:data_60e
		jz	loc_52			; Jump if zero
		call	sub_8
loc_52:
		mov	al,cs:data_64e
		or	al,cs:data_77e
		mov	ah,cs:data_63e
		or	ah,cs:data_78e
		pop	dx
		pop	cx
		pop	bx
		iret				; Interrupt return

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		push	si
		push	di
		push	cx
		call	sub_7
		mov	cx,word ptr cs:[5C6h]
		add	cx,8
		jnc	loc_53			; Jump if carry=0
		mov	cx,0FFFFh
loc_53:
		cmp	si,cx
		jb	loc_54			; Jump if below
		or	byte ptr cs:data_77e,8
loc_54:
		mov	cx,word ptr cs:[5C6h]
		shr	cx,1			; Shift w/zeros fill
		sub	cx,8
		jnc	loc_55			; Jump if carry=0
		xor	cx,cx			; Zero register
loc_55:
		cmp	si,cx
		ja	loc_56			; Jump if above
		or	byte ptr cs:data_77e,4
loc_56:
		mov	cx,word ptr cs:[5C8h]
		add	cx,8
		jnc	loc_57			; Jump if carry=0
		mov	cx,0FFFFh
loc_57:
		cmp	di,cx
		jb	loc_58			; Jump if below
		or	byte ptr cs:data_77e,2
loc_58:
		mov	cx,word ptr cs:[5C8h]
		shr	cx,1			; Shift w/zeros fill
		sub	cx,8
		jnc	loc_59			; Jump if carry=0
		xor	cx,cx			; Zero register
loc_59:
		cmp	di,cx
		ja	loc_60			; Jump if above
		or	byte ptr cs:data_77e,1
loc_60:
		mov	dx,201h
		in	al,dx			; port 201h, start game 1-shots
		not	al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,3
		mov	cs:data_78e,al
		pop	cx
		pop	di
		pop	si
		retn
sub_8		endp

			                        ;* No entry point to code
		cmp	word ptr cs:data_65e,14h
		je	loc_61			; Jump if equal
		retn
loc_61:
		push	ds
		call	sub_12
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		push	cs
		pop	ds
		mov	si,70Ah
		mov	bx,74h
		mov	cl,52h			; 'R'
		call	word ptr cs:data_55e
		pop	ds
loc_62:
		mov	ax,cs:data_65e
		test	ax,60h
		jz	loc_62			; Jump if zero
		test	ax,20h
		jnz	loc_63			; Jump if not zero
		call	sub_14
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr cs:data_64e,0
		mov	byte ptr cs:data_68e,0
		mov	byte ptr cs:data_69e,0
		retn
loc_63:
		test	byte ptr cs:data_59e,0FFh
		jz	loc_63			; Jump if zero
		xor	ax,ax			; Zero register
		jmp	dword ptr cs:data_57e
		db	'Exit to DOS.', 0Dh, ' Sure?(Y/N)'
		db	0FFh, 2Eh,0F7h, 06h, 18h,0FFh
		db	 08h, 00h, 75h, 01h,0C3h, 1Eh
		db	 2Eh,0C6h, 06h, 75h,0FFh, 02h
		db	0B8h, 1Eh, 10h,0B9h, 10h, 08h
		db	0BFh, 80h, 3Ch, 2Eh,0FFh, 16h
		db	 26h, 20h, 2Eh, 83h, 3Eh, 18h
		db	0FFh, 0Eh, 74h, 1Ch,0BBh, 1Eh
		db	 20h,0B9h, 10h, 10h,0B0h,0FFh
		db	 2Eh,0FFh, 16h, 00h, 20h, 0Eh
		db	 1Fh,0BEh,0B0h, 07h,0BBh, 8Ch
		db	 00h,0B1h, 22h, 2Eh,0FFh, 16h
		db	 2Ah, 20h
loc_64:
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		pop	ds
loc_65:
		cmp	word ptr cs:data_65e,0Eh
		jne	loc_66			; Jump if not equal
		call	sub_9
loc_66:
		test	byte ptr cs:data_68e,0FFh
		jnz	loc_67			; Jump if not zero
		test	byte ptr cs:data_69e,0FFh
		jnz	loc_67			; Jump if not zero
		jmp	short loc_65
loc_67:
		call	sub_9
		mov	byte ptr cs:data_68e,0
		mov	byte ptr cs:data_69e,0
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		mov	ax,101Eh
		mov	cx,810h
		mov	di,3C80h
		jmp	word ptr cs:data_54e
sub_9		endp

			                        ;* No entry point to code
		push	ax
		inc	cx
		push	bp
		push	bx
		inc	bp
		jmp	dword ptr ds:[6F7h]
			                        ;* No entry point to code
;*		sbb	bh,bh
		db	 18h,0FFh		;  Fixup - byte match
		add	byte ptr ds:[175h][bx+si],al
		retn
			                        ;* No entry point to code
		call	sub_12
		push	cs
		pop	ds
		mov	si,845h
		mov	bx,74h
		mov	cl,52h			; 'R'
		call	word ptr cs:data_55e
loc_68:
		test	word ptr cs:data_65e,8000h
		jnz	loc_68			; Jump if not zero
		mov	al,ds:data_75e
		neg	al
		add	al,0Ah
		call	sub_10
		push	ax
		add	al,30h			; '0'
		mov	ah,1
		mov	bx,0CCh
		mov	cl,5Ah			; 'Z'
		call	word ptr cs:data_52e
		pop	ax
		neg	al
		add	al,0Ah
		mov	ds:data_75e,al
		mov	byte ptr cs:data_81e,1
		call	sub_15
		mov	byte ptr cs:data_64e,0
		mov	byte ptr cs:data_68e,0
		mov	byte ptr cs:data_69e,0
loc_69:
		mov	dl,0FFh
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		jnz	loc_70			; Jump if not zero
		mov	al,cs:data_64e
		or	al,cs:data_68e
		or	al,cs:data_69e
		jz	loc_69			; Jump if zero
loc_70:
		call	sub_14
		mov	byte ptr cs:data_64e,0
		mov	byte ptr cs:data_68e,0
		mov	byte ptr cs:data_69e,0
		retn
		db	'Speed change', 0Dh, 'Select 0-9:'
		db	0FFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		mov	byte ptr ds:data_74e,0
loc_71:
		test	byte ptr ds:data_74e,0FFh
		jz	loc_71			; Jump if zero
		mov	ah,ds:data_74e
		cmp	ah,1Bh
		stc				; Set carry flag
		jnz	loc_72			; Jump if not zero
		retn
loc_72:
		sub	ah,30h			; '0'
		cmp	ah,0Ah
		jae	loc_71			; Jump if above or =
		clc				; Clear carry flag
		mov	al,ah
		retn
sub_10		endp

			                        ;* No entry point to code
		cmp	word ptr cs:data_65e,104h
		je	loc_73			; Jump if equal
		retn
loc_73:
		call	sub_11
		mov	byte ptr cs:data_64e,0
loc_74:
		cmp	word ptr cs:data_65e,104h
		je	loc_74			; Jump if equal
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11		proc	near
		test	byte ptr cs:data_76e,0FFh
		jz	loc_75			; Jump if zero
		retn
loc_75:
		test	byte ptr cs:data_60e,0FFh
		jnz	loc_76			; Jump if not zero
		retn
loc_76:
		mov	cx,103h
		shl	ch,cl			; Shift w/zeros fill
		xchg	cx,ax
		mov	cx,0FFFFh
		mov	dx,201h

locloop_77:
		in	al,dx			; port 201h, start game 1-shots
		test	al,ah
		loopnz	locloop_77		; Loop if zf=0, cx>0

		jcxz	loc_ret_78		; Jump if cx=0
		call	sub_7
		cmp	si,0FFFFh
		je	loc_ret_78		; Jump if equal
		cmp	di,0FFFFh
		je	loc_ret_78		; Jump if equal
		or	si,si			; Zero ?
		jz	loc_ret_78		; Jump if zero
		or	di,di			; Zero ?
		jz	loc_ret_78		; Jump if zero
		mov	word ptr cs:[5C6h],si
		mov	word ptr cs:[5C8h],di
		mov	byte ptr cs:data_76e,0FFh
		mov	byte ptr cs:data_81e,1

loc_ret_78:
		retn
sub_11		endp

			                        ;* No entry point to code
		cmp	word ptr cs:data_65e,804h
		je	loc_79			; Jump if equal
		retn
loc_79:
		test	byte ptr cs:data_76e,0FFh
		jnz	loc_80			; Jump if not zero
		retn
loc_80:
		mov	byte ptr cs:data_81e,1
		mov	byte ptr cs:data_76e,0
loc_81:
		cmp	word ptr cs:data_65e,804h
		je	loc_81			; Jump if equal
		retn
			                        ;* No entry point to code
		mov	ax,cs:data_67e
		add	al,ah
		adc	ah,0
		add	ax,word ptr cs:[92Bh]
		mov	word ptr cs:[92Bh],ax
		retn
		db	 00h, 00h, 2Eh, 81h, 3Eh, 18h
		db	0FFh, 00h, 40h,0F8h, 74h, 01h
		db	0C3h, 1Eh,0E8h, 60h, 00h,0B1h
		db	0FFh,0B8h, 03h, 00h,0CDh, 60h
		db	 0Eh, 1Fh,0BEh, 83h, 09h,0BBh
		db	 74h, 00h,0B1h, 52h, 2Eh,0FFh
		db	 16h, 2Ah, 20h, 1Fh
loc_82:
		mov	ax,cs:data_65e
		test	ax,60h
		jz	loc_82			; Jump if zero
		test	ax,20h
		pushf				; Push flags
		call	sub_14
		mov	byte ptr cs:data_64e,0
		mov	byte ptr cs:data_68e,0
		mov	byte ptr cs:data_69e,0
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		popf				; Pop flags
		stc				; Set carry flag
		jz	loc_83			; Jump if zero
		retn
loc_83:
		clc				; Clear carry flag
		retn
		db	'Restore Game', 0Dh, ' Sure?(Y/N)'
		db	0FFh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		mov	byte ptr cs:data_81e,2

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_13:
		mov	ax,0C46h
		mov	cx,1028h
		mov	di,3C80h
		call	word ptr cs:data_53e
		mov	bx,1A46h
		mov	cx,1E28h
		mov	al,0FFh
		jmp	word ptr cs:data_51e
sub_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		mov	ax,0C46h
		mov	cx,1028h
		mov	di,3C80h
		jmp	word ptr cs:data_54e
sub_14		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_15		proc	near
		push	dx
loc_84:
		mov	dl,0FFh
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		jnz	loc_84			; Jump if not zero
		pop	dx
		retn
sub_15		endp

			                        ;* No entry point to code
		push	ds
		mov	cs:data_25,di
		mov	word ptr cs:data_25+2,es
		mov	cs:data_27,dx
		mov	word ptr cs:data_27+2,ds
		mov	cx,0AF6h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	di,cs:data_25
		mov	ax,di
		inc	di
		add	ax,201h
		mov	cx,0FFh

locloop_85:
		stosw				; Store ax to es:[di]
		add	ax,9
		loop	locloop_85		; Loop if cx > 0

		push	cs
		pop	ds
		mov	dx,offset data_29
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		lds	dx,dword ptr cs:data_27	; Load seg:offset ptr
		mov	cx,dx
		mov	ah,4Eh
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	loc_89			; Jump if carry Set
		push	cs
		pop	ds
		les	di,dword ptr cs:data_25	; Load seg:offset ptr
		add	di,201h
		mov	cx,0FEh

locloop_86:
		push	cx
		push	di
		mov	bx,cs:data_25
		inc	byte ptr es:[bx]
		mov	si,0A77h
		mov	cx,8

locloop_87:
		lodsb				; String [si] to al
		cmp	al,2Eh			; '.'
		je	loc_88			; Jump if equal
		stosb				; Store al to es:[di]
		loop	locloop_87		; Loop if cx > 0

loc_88:
		pop	di
		pop	cx
		mov	ah,4Fh
		int	21h			; DOS Services  ah=function 4Fh
						;  find next filename match
		jc	loc_89			; Jump if carry Set
		add	di,9
		loop	locloop_86		; Loop if cx > 0

loc_89:
		pop	ds
		retn
		db	51 dup (0)
		db	 3Ch, 00h, 75h, 03h,0E9h, 76h
		db	 01h, 57h, 56h, 1Eh, 06h, 2Eh
		db	 89h, 36h, 5Ch, 0Fh, 2Eh, 8Ch
		db	 1Eh, 5Eh, 0Fh, 2Eh, 89h, 3Eh
		db	 60h, 0Fh, 2Eh, 8Ch, 06h, 62h
		db	 0Fh, 9Ch,0FCh, 3Ch, 07h, 73h
		db	 0Fh,0FEh,0C8h, 33h,0C9h, 8Ah
		db	0C8h, 8Bh,0E9h, 03h,0EDh, 2Eh
		db	0FFh, 96h,0CAh
		db	0Ah
loc_90:
		pop	bx
		pushf				; Push flags
		pop	ax
		and	bx,0FFFEh
		and	ax,1
		or	ax,bx
		push	ax
		popf				; Pop flags
		pop	es
		pop	ds
		pop	si
		pop	di
		retn
		db	0D6h, 0Ah,0FFh, 0Ah, 2Fh, 0Ch
		db	 6Fh, 0Bh,0AEh, 0Bh, 24h, 0Ch
		db	 2Eh,0C7h, 06h, 60h, 0Fh, 00h
		db	0C0h, 2Eh, 8Ch, 0Eh, 62h, 0Fh
		db	 8Ah,0C4h, 0Ah,0C0h, 79h, 04h
		db	 24h, 7Fh, 04h, 20h,0B1h, 0Bh
		db	0F6h,0E1h, 05h, 68h, 0Fh, 2Eh
		db	0A3h, 5Ch, 0Fh, 2Eh, 8Ch, 0Eh
		db	 5Eh, 0Fh,0E9h, 30h, 01h, 2Eh
		db	0C4h, 3Eh, 60h, 0Fh, 57h, 06h
		db	 2Eh,0C7h, 06h, 60h, 0Fh, 00h
		db	 00h, 8Ch,0C8h, 05h, 00h, 30h
		db	 8Eh,0C0h, 2Eh,0A3h, 62h, 0Fh
		db	0E8h, 27h, 01h, 8Bh,0D8h,0B9h
		db	 01h, 00h,0E8h, 61h, 02h, 2Eh
		db	 8Bh, 0Eh, 64h, 0Fh, 49h, 26h
		db	 80h, 3Eh, 00h, 00h, 00h, 74h
		db	 2Ah, 2Eh,0C7h, 06h, 60h, 0Fh
		db	 00h, 00h,0B9h, 04h, 00h,0E8h
		db	 46h, 02h, 26h, 8Bh, 0Eh, 00h
		db	 00h, 2Eh, 80h, 3Eh, 14h,0FFh
		db	 00h, 74h, 10h, 8Bh,0D1h,0B0h
		db	 01h,0B9h, 00h
data_25		dw	0B400h, 0CD42h
data_27		dw	2621h, 0E8Bh
data_29		db	2
		db	0
loc_91:
		mov	cs:data_46,0
		call	sub_17
		push	ax
		call	sub_18
		pop	dx
		pop	es
		pop	di
		jmp	loc_111
			                        ;* No entry point to code
		mov	bl,ah
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	si,word ptr cs:[0BA0h][bx]
		mov	ax,cs
		add	ax,1000h
		mov	es,ax
		add	ax,1000h
		mov	ds,ax
		mov	si,[si]
		mov	di,data_84e
		mov	cx,800h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,data_84e
		mov	cx,0Fh

locloop_92:
		add	word ptr es:[di],0B000h
		inc	di
		inc	di
		loop	locloop_92		; Loop if cx > 0

		retn
		db	 00h, 18h, 00h, 18h, 00h, 18h
		db	 00h, 18h, 02h, 18h, 02h, 18h
		db	 04h, 18h, 2Eh,0C4h, 3Eh, 60h
		db	 0Fh, 57h, 06h, 2Eh,0C7h, 06h
		db	 60h, 0Fh, 00h, 00h, 8Ch,0C8h
		db	 05h, 00h, 30h, 8Eh,0C0h, 2Eh
		db	0A3h, 62h, 0Fh,0E8h, 78h, 00h
data_31		dw	0D88Bh			; Data table (indexed access)
		db	0B9h, 04h, 00h,0E8h,0B2h, 01h
		db	 26h, 8Bh, 0Eh, 00h, 00h, 2Eh
		db	0F6h, 06h, 15h,0FFh,0FFh, 75h
		db	 10h, 8Bh,0D1h,0B0h, 01h,0B9h
		db	 00h, 00h,0B4h, 42h,0CDh, 21h
		db	 26h, 8Bh, 0Eh, 02h, 00h, 07h
		db	 5Fh, 2Eh, 89h, 3Eh, 60h, 0Fh
		db	 2Eh, 8Ch, 06h, 62h, 0Fh,0E8h
		db	 86h, 01h,0E9h, 92h, 01h, 1Eh
		db	 53h, 8Ch,0C8h, 05h, 00h, 20h
		db	 8Eh,0D8h, 0Eh, 07h,0BEh, 00h
		db	 90h,0BFh, 00h, 30h,0B9h, 00h
		db	38h

locloop_93:
		lodsw				; String [si] to ax
		mov	dx,es:[di]
		stosw				; Store ax to es:[di]
		mov	[si-2],dx
		loop	locloop_93		; Loop if cx > 0

		pop	bx
		pop	ds
		jmp	word ptr cs:[bx]	;*
			                        ;* No entry point to code
		call	sub_16
		jnc	loc_94			; Jump if carry=0
		retn
loc_94:
		mov	bx,ax
		jmp	loc_109
loc_95:
		call	sub_16
		jnc	loc_96			; Jump if carry=0
		retn
loc_96:
		mov	cx,cs:data_48
		mov	bx,ax
		call	sub_17
		jmp	loc_109

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
loc_97:
		mov	cs:data_48,0FFFFh
		mov	cs:data_49,0FFFFh
		lds	bx,dword ptr cs:data_44	; Load seg:offset ptr
		mov	al,[bx]
		add	al,31h			; '1'
		mov	byte ptr cs:[0D41h],al
		mov	byte ptr cs:[0D5Eh],al
		inc	bx
		mov	al,[bx]
		inc	bx
		mov	dx,bx
		mov	byte ptr cs:[0D79h],al
		or	al,al			; Zero ?
		jz	loc_98			; Jump if zero
		push	cs
		pop	ds
		mov	dx,0D3Bh
loc_98:
		mov	ax,3D00h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_103			; Jump if carry=0
		cmp	ax,2
		je	loc_99			; Jump if equal
		jmp	loc_140
loc_99:
		test	byte ptr cs:data_82e,0FFh
		jnz	loc_102			; Jump if not zero
		push	es
		call	sub_13
		push	cs
		pop	ds
		mov	si,0D47h
		mov	bx,6Ch
		mov	cl,4Ah			; 'J'
		call	word ptr cs:data_55e
		call	sub_15
		push	dx
		mov	byte ptr cs:data_68e,0
loc_100:
		mov	dl,0FFh
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		jnz	loc_101			; Jump if not zero
		test	byte ptr cs:data_68e,0FFh
		jz	loc_100			; Jump if zero
loc_101:
		pop	dx
		call	sub_14
		pop	es
		push	cs
		pop	ds
		mov	ah,0Dh
		int	21h			; DOS Services  ah=function 0Dh
						;  flush disk buffers to disk
		mov	dx,0D7Eh
		mov	ah,10h
		int	21h			; DOS Services  ah=function 10h
						;  close file, FCB @ ds:dx
		jmp	loc_97
loc_102:
		push	cs
		pop	ds
		mov	ah,0Dh
		int	21h			; DOS Services  ah=function 0Dh
						;  flush disk buffers to disk
		mov	dx,0D7Eh
		mov	ah,10h
		int	21h			; DOS Services  ah=function 10h
						;  close file, FCB @ ds:dx
		stc				; Set carry flag
		retn
loc_103:
		mov	byte ptr cs:data_68e,0
		test	byte ptr cs:[0D79h],0FFh
		jnz	loc_104			; Jump if not zero
		retn
loc_104:
		push	ax
		mov	bx,ax
		mov	al,byte ptr cs:[0D79h]
		xor	ah,ah			; Zero register
		dec	ax
		add	ax,ax
		add	ax,ax
		mov	dx,ax
		mov	al,0
		mov	cx,0
		mov	ah,42h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		jnc	loc_105			; Jump if carry=0
		jmp	loc_140
loc_105:
		push	cs
		pop	ds
		mov	dx,0D7Ah
		mov	cx,4
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	loc_106			; Jump if carry=0
		jmp	loc_140
loc_106:
		mov	dx,word ptr ds:[0D7Ah]
		mov	cx,word ptr ds:[0D7Ch]
		mov	al,0
		mov	ah,42h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		push	cs
		pop	ds
		mov	dx,offset data_48
		mov	cx,4
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	loc_107			; Jump if carry=0
		jmp	loc_140
loc_107:
		pop	ax
		retn
		db	'zelres1.sar', 0
		db	'    Please', 0Dh, ' insert DISK1'
		db	0Dh, '      and', 0Dh, ' press an'
		db	'y key'
		db	0FFh, 00h, 00h, 00h, 00h, 00h
		db	 64h, 75h, 6Dh, 6Dh, 79h, 00h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_17:
		lds	dx,dword ptr cs:data_46	; Load seg:offset ptr
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	loc_ret_108		; Jump if carry=0
		jmp	loc_140

loc_ret_108:
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_18:
loc_109:
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jnc	loc_ret_110		; Jump if carry=0
		jmp	loc_140

loc_ret_110:
		retn
loc_111:
		push	ds
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,data_85e
		call	sub_19
		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_19:
		xor	bx,bx			; Zero register
		lodsb				; String [si] to al
		dec	dx
		and	al,7
		mov	bl,al
		add	bx,bx
		jmp	word ptr cs:[0DBCh][bx]	;*
			                        ;* No entry point to code
		int	3			; Debug breakpoint
		or	ax,0DD1h
		adc	cx,ds:data_86e
		jnc	loc_112			; Jump if carry=0
		pushf				; Push flags
		push	cs
		mov	dx,0F50Eh
		push	cs
		mov	cx,dx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
		db	 8Bh,0EEh,0E8h
loc_112:
		xor	al,[bx+si]
loc_113:
		lodsb				; String [si] to al
		call	sub_20
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_113			; Jump if not zero
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_20:
		push	bp
		mov	ah,al
		and	ah,0F0h
		mov	cx,1
loc_114:
		test	byte ptr ds:[bp],0Fh
		jnz	loc_116			; Jump if not zero
		cmp	ah,ds:[bp]
		je	loc_115			; Jump if equal
		inc	bp
		inc	bp
		jmp	short loc_114
loc_115:
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0Fh
		add	cx,2
loc_116:
		pop	bp
		retn
loc_117:
		lodsb				; String [si] to al
		dec	dx
		cmp	al,0FFh
		jne	loc_118			; Jump if not equal
		retn
loc_118:
		inc	si
		dec	dx
		jmp	short loc_117
		db	0ACh, 4Ah, 8Ah,0E0h
loc_119:
		lodsb				; String [si] to al
		mov	cx,1
		mov	bl,al
		and	bl,0F0h
		cmp	bl,ah
		jne	loc_120			; Jump if not equal
		mov	cl,al
		and	cx,0Fh
		add	cx,3
		lodsb				; String [si] to al
		dec	dx
loc_120:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_119			; Jump if not zero
		retn
		db	 8Bh,0EEh,0E8h,0CFh,0FFh
loc_121:
		lodsb				; String [si] to al
		call	sub_21
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_121			; Jump if not zero
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_21:
		push	bp
		mov	ah,al
		and	ah,0Fh
		mov	cx,1
loc_122:
		test	byte ptr ds:[bp],0F0h
		jnz	loc_124			; Jump if not zero
		cmp	ah,ds:[bp]
		je	loc_123			; Jump if equal
		inc	bp
		inc	bp
		jmp	short loc_122
loc_123:
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0Fh
		add	cx,2
loc_124:
		pop	bp
		retn
		db	0ACh, 4Ah, 8Ah,0E0h
loc_125:
		lodsb				; String [si] to al
		mov	cx,1
		mov	bl,al
		and	bl,0Fh
		cmp	bl,ah
		jne	loc_126			; Jump if not equal
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	cl,al
		and	cx,0Fh
		add	cx,3
		lodsb				; String [si] to al
		dec	dx
loc_126:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_125			; Jump if not zero
		retn
loc_127:
		lodsb				; String [si] to al
		mov	cx,1
		cmp	[si],al
		jne	loc_128			; Jump if not equal
		mov	cl,[si+1]
		and	cx,0FFh
		add	cx,2
		add	si,2
		sub	dx,2
loc_128:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_127			; Jump if not zero
		retn
		db	 8Bh,0EEh
loc_129:
		lodsw				; String [si] to ax
		sub	dx,2
		cmp	ax,0FFFFh
		jne	loc_129			; Jump if not equal
loc_130:
		lodsb				; String [si] to al
		call	sub_22
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_130			; Jump if not zero
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_22:
		push	bp
		mov	cx,1
loc_131:
		cmp	word ptr ds:[bp],0FFFFh
		je	loc_133			; Jump if equal
		cmp	al,ds:[bp]
		je	loc_132			; Jump if equal
		inc	bp
		inc	bp
		jmp	short loc_131
loc_132:
		lodsb				; String [si] to al
		dec	dx
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0FFh
		add	cx,2
loc_133:
		pop	bp
		retn
		db	0ACh, 4Ah, 8Ah,0E0h
loc_134:
		lodsb				; String [si] to al
		mov	cx,1
		cmp	al,ah
		jne	loc_135			; Jump if not equal
		lodsb				; String [si] to al
		mov	cl,al
		lodsb				; String [si] to al
		xchg	al,cl
		and	cx,0FFh
		add	cx,3
		sub	dx,2
loc_135:
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		dec	dx
		jnz	loc_134			; Jump if not zero
		retn
		db	0C3h
loc_136:
		sti				; Enable interrupts
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	bp
		push	ds
		push	es
		push	di
		pop	ax
		or	al,al			; Zero ?
		js	loc_137			; Jump if sign=1
		cmp	al,2
		je	loc_138			; Jump if equal
loc_137:
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		xor	al,al			; Zero register
		iret				; Interrupt return
loc_138:
		mov	byte ptr cs:[2C4h],0
loc_139:
		cmp	byte ptr cs:[2C4h],0F0h
		jb	loc_139			; Jump if below
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		mov	al,1
		iret				; Interrupt return
loc_140:
		lds	dx,dword ptr cs:data_44	; Load seg:offset ptr
		jmp	dword ptr cs:data_57e
sub_16		endp

		db	12 dup (0)
		db	 02h, 15h
		db	'MP10.MDT'
		db	 00h, 02h, 16h
		db	'MP1D.MDT'
		db	 00h, 02h, 17h
		db	'MP20.MDT'
		db	 00h, 02h, 18h
		db	'MP21.MDT'
		db	 00h, 02h, 19h
		db	'MP2D.MDT'
		db	 00h, 02h, 1Ah
		db	'MP30.MDT'
		db	0, 2
		db	1Bh, 'MP31.MDT'
		db	 00h, 02h, 1Ch
		db	'MP3D.MDT'
		db	 00h, 02h, 1Dh
		db	'MP40.MDT'
		db	 00h, 02h, 1Eh
		db	'MP41.MDT'
		db	 00h, 02h, 1Fh
		db	'MP4D.MDT'
		db	0, 2
		db	' MP50.MDT'
		db	0, 2
		db	'!MP51.MD'

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_23		proc	near
		push	sp
		add	[bp+si],al
		and	cl,[di+50h]
		xor	ax,2E44h
		dec	bp
		inc	sp
		push	sp
		add	[bp+si],al
		and	cx,[di+50h]
		xor	ss:data_56e,ch
		push	sp
		add	[bp+si],al
		and	al,4Dh			; 'M'
		push	ax
		xor	ss:data_56e,bp
		push	sp
		add	[bp+si],al
		and	ax,504Dh
		xor	ch,ss:data_56e
		push	sp
		add	[bp+si],al
		db	'&MP6D.MDT'
		db	0, 2
		db	27h, 'MP70.MDT'
		db	0, 2
		db	'(MP71.MDT'
		db	0, 2
		db	')MP72.MDT'
		db	0, 2
		db	'*MP73.MDT'
		db	 00h, 02h, 2Bh
data_44		dw	504Dh, 4437h
data_46		dw	4D2Eh, 5444h
data_48		dw	200h
data_49		dw	4D2Ch
		db	 50h, 38h, 30h, 2Eh, 4Dh, 44h
		db	 54h, 00h, 02h
		db	'-MP81.MDT'
		db	0, 2
		db	'.MP82.MDT'
		db	0, 2
		db	'/MP83.MDT'
		db	0, 2
		db	'0MP84.MDT'
		db	0, 2
		db	'1MP8D.MDT'
		db	0, 2
		db	'2MP90.MDT'
		db	0, 2
		db	'3MPA0.MDT'
		db	 00h, 01h, 00h, 20h
		db	7 dup (20h)
		db	0, 1
		db	'%CMAP.MDT'
		db	0, 1
		db	'&MRMP.MDT'
		db	0, 1
		db	27h, 'STMP.MDT'
		db	0, 1
		db	'(BSMP.MDT'
		db	0, 1
		db	')HLMP.MDT'
		db	0, 1
		db	'*TMMP.MDT'
		db	0, 1
		db	'+DRMP.MDT'
		db	0, 1
		db	',LLMP.MDT'
		db	0, 1
		db	'-PRMP.MDT'
		db	0, 1
		db	'.ESMP.MDT'
		db	0
sub_23		endp


seg_a		ends



		end	start
