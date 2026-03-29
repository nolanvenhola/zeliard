
PAGE  59,132

;��������������������������������������������������������������������������
;��					                                 ��
;��				ZELIAD	                                 ��
;��					                                 ��
;��      Created:   29-Mar-26		                                 ��
;��      Passes:    9          Analysis	Options on: none                 ��
;��					                                 ��
;��������������������������������������������������������������������������

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc
include  ZELIARD.INC


; The following equates show data references outside the range of the program.

data_1e		equ	0FF00h			;*
data_2e		equ	0FF02h			;*
data_3e		equ	0FF04h			;*
data_4e		equ	0FF06h			;*
data_5e		equ	0FF08h			;*
data_6e		equ	0FF09h			;*
data_7e		equ	0FF0Ah			;*
data_8e		equ	0FF0Bh			;*
data_9e		equ	0FF0Ch			;*
data_10e	equ	0FF0Eh			;*
data_11e	equ	0FF10h			;*
data_12e	equ	0FF12h			;*
data_13e	equ	0FF14h			;*
data_14e	equ	0FF15h			;*
data_15e	equ	0FF16h			;*
data_16e	equ	0FF17h			;*
data_17e	equ	0FF18h			;*
data_18e	equ	0FF1Dh			;*
data_19e	equ	0FF1Eh			;*
data_20e	equ	0FF1Fh			;*
data_21e	equ	0FF26h			;*
data_22e	equ	0FF27h			;*
data_23e	equ	0FF28h			;*
data_24e	equ	0FF2Ch			;*
data_25e	equ	0FF33h			;*
data_26e	equ	0FF34h			;*
data_27e	equ	0FF38h			;*
data_28e	equ	0FF39h			;*
data_29e	equ	0FF3Ah			;*
data_30e	equ	0FF3Bh			;*
data_31e	equ	0FF3Ch			;*
data_32e	equ	0FF40h			;*
data_33e	equ	0FF42h			;*
data_34e	equ	0FF43h			;*
data_35e	equ	0FF6Ch			;*
data_36e	equ	0FF74h			;*
data_37e	equ	0FF75h			;*
data_38e	equ	0FF78h			;*
data_39e	equ	0FF79h			;*
data_40e	equ	0FF7Bh			;*
PSP_cmd_size	equ	80h
data_41e	equ	81h
data_94e	equ	0

;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public
		assume cs:seg_a  , ds:seg_a , ss:stack_seg_b


;��������������������������������������������������������������������������
;
;                       Program	Entry Point
;
;��������������������������������������������������������������������������


zeliad		proc	far

start:
		cld				; Clear direction
		mov	ah,30h
		int	21h			; DOS Services  ah=function 30h
						;  get DOS version number ax
		cmp	al,2
		jae	loc_6			; Jump if above or =
		int	20h			; DOS program terminate
loc_6:
		mov	ax,seg_a
		mov	ds,ax
		call	sub_11
		mov	dx,offset data_64	; ('RESOURCE.CFG')
		mov	ax,3D00h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	loc_7			; Jump if carry=0
		call	sub_9
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_7:
		mov	bx,ax
		call	sub_2
		jnc	loc_8			; Jump if carry=0
		jmp	loc_41
loc_8:
		call	sub_3
		call	sub_2
		jnc	loc_9			; Jump if carry=0
		jmp	loc_41
loc_9:
		call	sub_4
		call	sub_2
		jnc	loc_10			; Jump if carry=0
		jmp	loc_41
loc_10:
		call	sub_5
		call	sub_2
		jnc	loc_11			; Jump if carry=0
		jmp	loc_41
loc_11:
		call	sub_6			; Sub does not return here
		db	0B4h, 3Eh,0CDh, 21h,0BBh, 00h
		db	 40h,0B4h, 48h,0CDh, 21h, 73h
		db	 1Dh, 3Dh, 08h, 00h, 75h, 0Ch
		db	0BAh,0FFh, 06h,0B4h, 09h,0CDh
		db	 21h,0B8h, 00h, 4Ch,0CDh
		db	21h
loc_12:
		mov	dx,offset data_55	; ('Memory error !!!')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_13:
		mov	word ptr data_73+2,ax
		call	sub_1
		mov	dx,offset data_54	; ('The Fantasy Action Game ')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		test	byte ptr cs:data_89,0FFh
		jz	loc_14			; Jump if zero
		mov	cs:data_84,sp
		mov	cs:data_85,ss
		mov	di,7EDh
		mov	dx,offset data_65	; ('MTINIT.COM')
		mov	bx,offset data_86
		mov	ax,4B00h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		cli				; Disable interrupts
		mov	sp,cs:data_84
		mov	ss,cs:data_85
		sti				; Enable interrupts
		jnc	loc_14			; Jump if carry=0
		call	sub_9
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
loc_14:
		mov	ax,3508h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	data_75,bx
		mov	word ptr data_75+2,es
		mov	ax,3509h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	data_77,bx
		mov	word ptr data_77+2,es
		mov	ax,3560h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	data_79,bx
		mov	word ptr data_79+2,es
		mov	ax,3561h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	data_81,bx
		mov	data_82,es
		mov	es,word ptr cs:data_73+2
		mov	word ptr es:data_1e,2D9h
		mov	es:data_2e,cs
		lds	dx,dword ptr cs:data_75	; Load seg:offset ptr
		mov	es:data_3e,dx
		mov	es:data_4e,ds
		lds	dx,dword ptr cs:data_77	; Load seg:offset ptr
		mov	es:data_39e,dx
		mov	es:data_40e,ds
		mov	byte ptr es:data_15e,0
		mov	byte ptr es:data_16e,0
		mov	word ptr es:data_17e,0
		mov	byte ptr es:data_18e,0
		mov	byte ptr es:data_19e,0
		mov	word ptr es:data_20e,0
		mov	byte ptr es:data_21e,0FFh
		mov	byte ptr es:data_6e,0FFh
		mov	byte ptr es:data_22e,0
		mov	byte ptr es:data_23e,0
		mov	byte ptr es:data_8e,0
		mov	byte ptr es:data_5e,0
		mov	byte ptr es:data_37e,0
		mov	byte ptr es:data_25e,5
		mov	byte ptr es:data_26e,0
		mov	byte ptr es:data_27e,0
		mov	byte ptr es:data_28e,0
		mov	byte ptr es:data_29e,0
		mov	byte ptr es:data_34e,0
		mov	byte ptr es:data_31e,0
		mov	byte ptr es:data_30e,0
		mov	byte ptr es:data_36e,0
		mov	byte ptr es:data_32e,0
		mov	byte ptr es:data_33e,0
		mov	byte ptr es:data_38e,0
		mov	al,cs:data_90
		mov	es:data_7e,al
		mov	al,cs:data_89
		mov	es:data_14e,al
		mov	di,data_35e
		xor	al,al			; Zero register
		mov	cx,8
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		push	cs
		pop	ds
		mov	si,offset data_68
		mov	di,data_35e
		mov	cx,8

locloop_15:
		lodsb				; String [si] to al
		cmp	al,2Eh			; '.'
		je	loc_17			; Jump if equal
		cmp	al,61h			; 'a'
		jb	loc_16			; Jump if below
		cmp	al,7Bh			; '{'
		jae	loc_16			; Jump if above or =
		and	al,5Fh			; '_'
loc_16:
		stosb				; Store al to es:[di]
		loop	locloop_15		; Loop if cx > 0

loc_17:
		mov	al,cs:data_88
		mov	es:data_13e,al
		mov	ax,word ptr cs:data_73+2
		add	ax,1000h
		mov	es:data_24e,ax
		push	cs
		pop	ds
		mov	es,word ptr cs:data_73+2
		mov	di,85Ah
		test	byte ptr data_83,0FFh
		jz	loc_18			; Jump if zero
		mov	di,867h
loc_18:
		call	sub_8
		mov	es,word ptr cs:data_73+2
		mov	di,806h
		call	sub_8
		mov	es,word ptr cs:data_73+2
		mov	di,84Fh
		call	sub_8
		mov	es,word ptr cs:data_73+2
		xor	bx,bx			; Zero register
		mov	bl,data_88
		add	bx,bx
		mov	di,data_66[bx]
		call	sub_8
		mov	ax,word ptr cs:data_73+2
		add	ax,0FF0h
		mov	es,ax
		mov	di,889h
		call	sub_8
		mov	ax,word ptr cs:data_73+2
		add	ax,0FF0h
		mov	es,ax
		mov	di,89Bh
		call	sub_8
		cli				; Disable interrupts
		push	cs
		pop	ds
		mov	dx,offset int_23h_entry
		mov	ax,2523h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	ds,word ptr cs:data_73+2
		mov	dx,isr_timer			; stick.bin timer stub
		mov	ax,2508h
		int	21h			; Set INT 08h (timer handler)
		mov	dx,isr_keyboard			; stick.bin keyboard stub
		mov	ax,2509h
		int	21h			; Set INT 09h (keyboard handler)
		mov	dx,isr_critical			; stick.bin critical-error stub
		mov	ax,2524h
		int	21h			; Set INT 24h (critical error)
		mov	dx,isr_music			; stick.bin music stub
		mov	ax,2561h
		int	21h			; Set INT 61h (music handler)
		mov	ax,word ptr cs:data_73+2
		mov	es,ax
		add	ax,0FF0h
		mov	ds,ax
		mov	word ptr es:data_9e,100h
		mov	es:data_10e,ds
		mov	word ptr es:data_11e,1100h
		mov	es:data_12e,ds
;*		mov	dx,offset loc_5		;*
		mov	dx,isr_timer			; stick.bin game-services stub
		mov	ax,2560h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	al,36h			; '6'
		out	43h,al			; port 43h, 8253 timer control
		mov	al,0B1h
		out	40h,al			; port 40h, 8253 timer 0 clock
		mov	al,13h
		out	40h,al			; port 40h, 8253 timer 0 clock
		sti				; Enable interrupts
		call	sub_10
		mov	al,cs:data_83
		cbw				; Convrt byte to word
		jmp	dword ptr cs:data_73
			                        ;* No entry point to code
		push	ax
		mov	ax,2
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	ax,2
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		call	sub_1
		mov	ax,1
		int	60h			; ??INT Non-standard interrupt
		pop	ax
		or	ax,ax			; Zero ?
		jnz	loc_19			; Jump if not zero
		push	cs
		pop	ds
		mov	dx,offset data_56	; ('Thank you for playing.')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short loc_23
loc_19:
		cmp	ax,0FFFFh
		jne	loc_20			; Jump if not equal
		push	cs
		pop	ds
		mov	dx,offset data_60	; ('USER file nothing.')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short loc_23
loc_20:
		push	ds
		push	dx
		mov	dx,775h
		cmp	ax,2
		je	loc_21			; Jump if equal
		mov	dx,offset data_59	; ('DISK read Error!!')
loc_21:
		push	cs
		pop	ds
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	dl,20h			; ' '
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		mov	dl,3Ah			; ':'
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		mov	dl,20h			; ' '
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		pop	di
		pop	ds
loc_22:
		mov	dl,[di]
		or	dl,dl			; Zero ?
		jz	loc_23			; Jump if zero
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		inc	di
		jmp	short loc_22
loc_23:
		cli				; Disable interrupts
		lds	dx,dword ptr cs:data_75	; Load seg:offset ptr
		mov	ax,2508h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		lds	dx,dword ptr cs:data_77	; Load seg:offset ptr
		mov	ax,2509h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		lds	dx,dword ptr cs:data_79	; Load seg:offset ptr
		mov	ax,2560h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	al,36h			; '6'
		out	43h,al			; port 43h, 8253 timer control
		xor	al,al			; Zero register
		out	40h,al			; port 40h, 8253 timer 0 clock
		out	40h,al			; port 40h, 8253 timer 0 clock
		sti				; Enable interrupts
		mov	ax,seg_a
		mov	ds,ax
		mov	es,word ptr data_73+2
		mov	ah,49h
		int	21h			; DOS Services  ah=function 49h
						;  release memory block, es=seg
		jnc	loc_24			; Jump if carry=0
		mov	dx,offset data_55	; ('Memory error !!!')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
loc_24:
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code

zeliad		endp

;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_1		proc	near
		push	dx
loc_25:
		mov	dl,0FFh
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		jnz	loc_25			; Jump if not zero
		pop	dx
		retn
sub_1		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_2		proc	near
		push	cs
		pop	ds
		mov	dx,offset data_92
		mov	byte ptr data_91,0
loc_26:
		mov	cx,1
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		or	ax,ax			; Zero ?
		stc				; Set carry flag
		jnz	loc_27			; Jump if not zero
		retn
loc_27:
		mov	si,dx
		cmp	byte ptr [si],20h	; ' '
		jb	loc_26			; Jump if below
loc_28:
		inc	data_91
		or	byte ptr [si],20h	; ' '
		inc	dx
loc_29:
		mov	cx,1
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		or	ax,ax			; Zero ?
		jz	loc_30			; Jump if zero
		mov	si,dx
		cmp	byte ptr [si],20h	; ' '
		je	loc_29			; Jump if equal
		jnc	loc_28			; Jump if carry=0
loc_30:
		clc				; Clear carry flag
		retn
sub_2		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_3		proc	near
		push	cs
		pop	es
		call	sub_7
		dec	cx
		cmp	cx,3
		je	loc_34			; Jump if equal
		cmp	cx,4
		je	loc_31			; Jump if equal
		jmp	loc_41
loc_31:
		mov	di,offset data_42
		mov	cx,2

locloop_32:
		push	cx
		push	si
		push	di
		mov	cx,4
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop	di
		pop	si
		pop	cx
		jz	loc_33			; Jump if zero
		add	di,5
		loop	locloop_32		; Loop if cx > 0

		jmp	loc_41
loc_33:
		add	di,4
		mov	al,es:[di]
		mov	data_88,al
		retn
loc_34:
		mov	di,offset data_43
		mov	cx,4

locloop_35:
		push	cx
		push	si
		push	di
		mov	cx,3
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop	di
		pop	si
		pop	cx
		jz	loc_36			; Jump if zero
		add	di,4
		loop	locloop_35		; Loop if cx > 0

		jmp	loc_41
loc_36:
		add	di,3
		mov	al,es:[di]
		mov	data_88,al
		retn
data_42		db	63h
		db	 67h, 61h, 32h, 02h, 6Dh, 63h
		db	 67h, 61h, 04h
data_43		db	63h
		db	 67h, 61h, 01h, 65h, 67h, 61h
		db	 00h, 68h, 67h, 63h, 03h, 74h
		db	 67h, 61h, 05h

;���� External Entry into Subroutine ��������������������������������������

sub_4:
		mov	byte ptr cs:data_89,0
		push	cs
		pop	es
		call	sub_7
		dec	cx
		cmp	cx,0Fh
		jb	loc_37			; Jump if below
		mov	cx,0Fh
loc_37:
		mov	di,offset data_69
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		mov	di,offset data_69
		mov	si,offset data_44	; ('mscmt.drv')
		mov	cx,9
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_38			; Jump if zero
		retn
loc_38:
		mov	byte ptr data_89,0FFh
		retn
data_44		db	'mscmt.drv'

;���� External Entry into Subroutine ��������������������������������������

sub_5:
		push	cs
		pop	es
		call	sub_7
		dec	cx
		cmp	cx,0Fh
		jb	loc_39			; Jump if below
		mov	cx,0Fh
loc_39:
		mov	di,offset data_71
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		retn
;      Note: Subroutine does not return	to instruction after call


;���� External Entry into Subroutine ��������������������������������������

sub_6:
		push	cs
		pop	es
		call	sub_7
		dec	cx
		cmp	cx,2
		je	loc_40			; Jump if equal
		cmp	cx,3
		jne	loc_41			; Jump if not equal
		mov	di,offset data_45
		mov	cx,3
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_41			; Jump if not zero
		mov	byte ptr cs:data_90,0FFh
		retn
loc_40:
		mov	di,offset data_46
		mov	cx,2
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jnz	loc_41			; Jump if not zero
		mov	byte ptr cs:data_90,0
		retn
data_45		db	79h
		db	 65h, 73h
data_46		db	6Eh
		db	6Fh
loc_41:
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		mov	dx,offset data_61	; ('Error in RESOURCE.CFG')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
sub_3		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_7		proc	near
		push	cs
		pop	ds
		mov	si,offset data_92
		xor	cx,cx			; Zero register
		mov	cl,data_91

locloop_42:
		lodsb				; String [si] to al
		cmp	al,3Ah			; ':'
		jne	loc_43			; Jump if not equal
		retn
loc_43:
		loop	locloop_42		; Loop if cx > 0

		jmp	short loc_41
sub_7		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_8		proc	near
		push	ds
		push	es
		push	di
		mov	dx,di
		add	dx,2
		mov	ax,3D00h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jc	loc_44			; Jump if carry Set
		mov	bx,ax
		mov	dx,[di]
		mov	cx,0FFFFh
		push	es
		pop	ds
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jc	loc_44			; Jump if carry Set
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jc	loc_44			; Jump if carry Set
		pop	di
		pop	es
		pop	ds
		retn
loc_44:
		pop	di
		pop	es
		pop	ds
		call	sub_9
		jmp	loc_23
sub_8		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_9		proc	near
		push	ds
		push	es
		push	di
		push	cs
		pop	ds
		push	ax
		mov	dx,offset data_57	; ('File Error from ')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		pop	ax
		pop	di
		pop	es
		pop	ds
		push	ax
		add	di,2
loc_45:
		mov	dl,[di]
		or	dl,dl			; Zero ?
		jz	loc_46			; Jump if zero
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		inc	di
		jmp	short loc_45
loc_46:
		pop	bx
		push	cs
		pop	ds
		mov	dx,offset data_58	; ('     Error Type : ')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	dx,775h
		cmp	bx,2
		je	loc_47			; Jump if equal
		mov	dx,785h
		cmp	bx,5
		je	loc_47			; Jump if equal
		shl	bx,1			; Shift w/zeros fill
		mov	dl,data_62[bx]
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		mov	dl,byte ptr data_63[bx]	; ('00102030405060708090A0B0')
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		mov	dl,48h			; 'H'
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		retn
loc_47:
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		retn
sub_9		endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_10		proc	near
		mov	bl,cs:data_88
		xor	bh,bh			; Zero register
		add	bx,bx
		jmp	word ptr cs:data_47[bx]	;*6 entries
data_47		dw	offset loc_48		; Data table (indexed access)
data_48		dw	offset loc_49
data_49		dw	offset loc_50
data_50		dw	offset loc_53
data_51		dw	offset loc_51
data_52		dw	offset loc_52

;����� Indexed Entry Point ������������������������������������������������

loc_48:
		mov	ax,0Eh
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;����� Indexed Entry Point ������������������������������������������������

loc_49:
		mov	ax,5
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;����� Indexed Entry Point ������������������������������������������������

loc_50:
		mov	ax,6
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;����� Indexed Entry Point ������������������������������������������������

loc_51:
		mov	ax,13h
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;����� Indexed Entry Point ������������������������������������������������

loc_52:
		mov	ax,9
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

;����� Indexed Entry Point ������������������������������������������������

loc_53:
		push	cs
		pop	ds
		mov	dx,3B8h
		mov	al,2
		out	dx,al			; port 3B8h, MDA video control
		mov	dx,3BFh
		mov	al,1
		out	dx,al			; port 3BFh, Hercules config
		mov	cx,0Ch
		mov	ah,0
		mov	si,offset data_53
		mov	dx,3B4h

locloop_54:
		mov	al,ah
		out	dx,al			; port 3B4h, MDA/EGA reg index
						;  al = 0, horiz char total
		lodsb				; String [si] to al
		inc	dx
		out	dx,al			; port 3B5h, MDA/EGA indxd data
		dec	dx
		inc	ah
		loop	locloop_54		; Loop if cx > 0

		mov	al,2Ah			; '*'
		mov	dx,3B8h
		out	dx,al			; port 3B8h, MDA video control
		mov	ax,0B000h
		mov	es,ax
		mov	di,data_94e
		xor	ax,ax			; Zero register
		mov	cx,4000h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
sub_10		endp

data_53		db	35h
		db	 2Dh, 2Eh, 07h, 5Bh, 02h, 57h
		db	 57h, 02h, 03h, 00h, 00h


;��������������������������������������������������������������������������
;
;                       External Entry Point
;
;��������������������������������������������������������������������������

int_23h_entry	proc	far
		iret				; Interrupt return
int_23h_entry	endp


;��������������������������������������������������������������������������
;                              SUBROUTINE
;��������������������������������������������������������������������������

sub_11		proc	near
		test	byte ptr es:PSP_cmd_size,0FFh
		jnz	loc_55			; Jump if not zero
		retn
loc_55:
		mov	di,offset data_68
		xor	cx,cx			; Zero register
		mov	cl,es:PSP_cmd_size
		mov	si,data_41e

locloop_56:
		cmp	byte ptr es:[si],20h	; ' '
		jne	loc_57			; Jump if not equal
		inc	si
		loop	locloop_56		; Loop if cx > 0

		retn
loc_57:
		xor	ah,ah			; Zero register

locloop_58:
		mov	al,es:[si]
		cmp	al,20h			; ' '
		je	loc_59			; Jump if equal
		cmp	al,0Dh
		je	loc_59			; Jump if equal
		mov	ah,0FFh
		mov	[di],al
		inc	di
loc_59:
		inc	si
		loop	locloop_58		; Loop if cx > 0

		or	ah,ah			; Zero ?
		jnz	loc_60			; Jump if not zero
		retn
loc_60:
		mov	byte ptr data_83,0FFh
		mov	byte ptr [di],2Eh	; '.'
		mov	byte ptr [di+1],55h	; 'U'
		mov	byte ptr [di+2],53h	; 'S'
		mov	byte ptr [di+3],52h	; 'R'
		mov	byte ptr [di+4],0
		retn
sub_11		endp

data_54		db	'The Fantasy Action Game ZELIARD '
		db	'Version 1.208', 0Dh, 0Ah, 'Copyr'
		db	'ight (C) 1987 ~ 1990 Game Arts C'
		db	'o.,Ltd.', 0Dh, 0Ah, 'Copyright ('
		db	'C) 1990 Sierra On-Line, Inc.', 0Dh
		db	0Ah, '$'
		db	'Not supported command !', 0Dh, 0Ah
		db	'$'
		db	'Special mode !!', 0Dh, 0Ah, '$'
		db	'Not enough memory to run ', 27h, 'Z'
		db	'ELIARD', 27h, '.', 0Dh, 0Ah, '$'
data_55		db	'Memory error !!!', 0Dh, 0Ah, '$'
data_56		db	'Thank you for playing.', 0Dh, 0Ah
		db	'$'
data_57		db	'File Error from $'
data_58		db	'     Error Type : $'
		db	'File not found.$'
data_59		db	'DISK read Error!!$'
data_60		db	'USER file nothing.$'
data_61		db	'Error in RESOURCE.CFG', 0Dh, 0Ah
		db	'$'
data_62		db	30h			; Data table (indexed access)
data_63		db	'00102030405060708090A0B0C0D0E0F'	; Data table (indexed access)
data_64		db	'RESOURCE.CFG', 0
data_65		db	'MTINIT.COM', 0
data_66		dw	812h			; Data table (indexed access)
		db	 1Eh, 08h, 1Eh, 08h, 2Ah, 08h
		db	 36h, 08h, 43h, 08h, 00h, 01h
		db	'stick.bin'
		db	0, 0
		db	' gmega.bin'
		db	0, 0
		db	' gmcga.bin'
		db	0, 0
		db	' gmhgc.bin'
		db	0, 0
		db	' gmmcga.bin'
		db	0, 0
		db	' gmtga.bin'
		db	 00h, 00h,0A0h
		db	'game.bin'
		db	0, 0, 0
		db	'stdply.bin'
		db	0, 0, 0
data_68		db	0
		db	32 dup (0)
		db	1
data_69		db	0
		db	16 dup (0)
		db	11h
data_71		db	0
		db	15 dup (0)
data_73		dw	0A000h, 0
data_75		dw	0, 0
data_77		dw	0, 0
data_79		dw	0, 0
data_81		dw	0
data_82		dw	0			; segment storage
data_83		db	0
data_84		dw	0
data_85		dw	0			; segment storage
data_86		db	0
		db	 00h,0D4h, 08h
		dw	seg_a
		db	0D7h, 08h
		dw	seg_a
		db	0D7h, 08h
		dw	seg_a
		db	 01h, 20h, 0Dh, 00h, 20h
		db	14 dup (0)
data_88		db	0
data_89		db	0
data_90		db	0
data_91		db	0
data_92		db	0
		db	260 dup (0)

seg_a		ends



;------------------------------------------------------  stack_seg_b   ----

stack_seg_b	segment	word stack 'STACK'

		db	8192 dup (0)

stack_seg_b	ends



		end	start
