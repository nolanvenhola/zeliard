
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				_342MP7D                                 лл
;лл					                                 лл
;лл      Created:   5-Apr-26		                                 лл
;лл      Code type: device drivr	                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_2e		equ	0CB08h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_342MP7D	proc	far


_342MP7D	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy_1	proc	far
		rol	byte ptr [bp+si],1	; Rotate
		add	[bx+si],al
attributes	dw	0C2B6h
pointers	dw	offset strategy
		dw	0C25Ch
char_dev	db	'^Т`ТzТ|Т'
		db	0A0h,0C2h,0CEh,0C2h, 07h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h, 5Ch
		db	0C2h, 83h,0CBh,0CCh, 05h, 0Eh
		db	0D0h,0D1h, 57h,0C9h, 57h,0CBh
		db	0ABh, 83h,0CBh,0CCh, 05h, 0Eh
		db	0D0h,0D1h, 57h,0D2h, 57h,0CBh
		db	0ABh, 83h,0CBh,0CCh, 05h, 0Eh
		db	0D0h,0D1h, 47h, 48h, 57h,0CBh
		db	0ABh, 83h,0CBh,0CCh
strategy_1	endp


;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;                       External Entry Point
;
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

strategy	proc	far
		add	ax,0D00Eh
		ror	ax,1			; Rotate
		db	0DFh,0CCh,0D0h,0D1h,0C8h,0E1h
		db	0CBh,0ABh, 83h,0CBh,0CCh, 05h
		db	 0Eh,0D0h,0D1h,0C8h,0CBh,0CCh
		db	0D0h,0D1h,0C8h,0D2h,0CBh,0ABh
		db	 83h,0CBh,0CCh, 05h, 0Eh,0D0h
		db	0D1h,0C8h,0CBh,0CCh,0D0h,0D1h
		db	 47h,0CBh,0ABh, 83h,0CBh,0CCh
		db	 05h, 0Eh,0D0h,0D1h,0C8h,0CBh
		db	0CCh,0D0h,0D1h, 47h,0CBh,0ABh
		db	 83h,0CBh,0CCh, 05h, 0Eh,0D0h
loc_1:
		ror	ax,1			; Rotate
		retf
strategy	endp

			                        ;* No entry point to code
		int	3			; Debug breakpoint
		rcl	cl,1			; Rotate thru carry
		inc	di
		retf
			                        ;* No entry point to code
		stosw				; Store ax to es:[di]
;*		or	bx,0FFCCh
		db	 83h,0CBh,0CCh		;  Fixup - byte match
		add	ax,0D00Eh
		rol	word ptr [bx+1],1	; Rotate
		adc	dl,[bx-35h]
		stosw				; Store ax to es:[di]
;*		and	ax,0FFCCh
		db	 83h,0E0h,0CCh		;  Fixup - byte match
		add	ax,0D00Eh
		rol	word ptr ds:data_2e,1	; Rotate
		stosw				; Store ax to es:[di]
;*		or	ax,0FFCBh
		db	 83h,0C8h,0CBh		;  Fixup - byte match
		pop	si
		pop	bp
		rcl	cl,1			; Rotate thru carry
		push	es
;*		or	bl,cl
		db	 08h,0CBh		;  Fixup - byte match
		stosw				; Store ax to es:[di]
;*		adc	word ptr [bx-2Eh],0FFE0h
		db	 83h, 57h,0D2h,0E0h	;  Fixup - byte match
		int	3			; Debug breakpoint
		into				; Int 4 on overflow
		rcl	cl,1			; Rotate thru carry
		ja	loc_1			; Jump if above
		inc	di
		retf
			                        ;* No entry point to code
		stosw				; Store ax to es:[di]
;*		or	dx,0FFC8h
		db	 83h,0CAh,0C8h		;  Fixup - byte match
		add	[bp+di],dx
		db	0C8h,0CBh,0CFh,0D0h,0D1h,0C8h
		db	0CBh,0D1h, 77h,0CBh,0ABh, 83h
		db	 47h,0DAh,0D7h,0C5h,0C8h, 02h
		db	 12h,0CAh, 47h,0CAh, 67h,0CBh
		db	0ABh, 83h,0CAh,0C8h,0DAh,0DCh
		db	0C6h,0C9h,0C8h, 49h,0C8h,0CAh
		db	 05h, 08h,0CBh,0ABh, 83h, 01h
		db	 13h,0DBh,0DDh, 81h,0C6h, 67h
		db	0CAh, 57h, 02h, 13h,0CBh,0ABh
		db	 89h,0C6h, 06h, 13h,0DBh,0C5h
		db	0D3h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C5h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h,0C4h,0D6h,0CBh,0ABh, 92h
		db	0C5h,0D6h,0CBh,0ABh, 92h,0C5h
		db	0D6h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C7h,0D6h,0CBh
		db	0ABh, 92h,0C4h,0D6h,0CBh,0ABh
		db	 92h,0C5h,0D6h,0CBh,0ABh, 92h
		db	0C5h,0D6h,0CBh,0ABh, 92h,0C5h
		db	0D6h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C5h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h, 01h, 16h,0CBh,0ABh, 92h
		db	0C7h,0D6h,0CBh,0ABh, 92h,0C5h
		db	0D6h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C5h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h,0C4h,0D6h,0CBh,0ABh, 92h
		db	0C5h,0D6h,0CBh,0ABh, 92h,0C4h
		db	0D6h,0CBh,0ABh, 92h,0C4h,0D6h
		db	0CBh,0ABh, 92h,0C4h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h,0C5h,0D6h,0CBh,0ABh, 92h
		db	0C4h,0D6h,0CBh,0ABh, 92h,0C5h
		db	0D6h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C5h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h,0C5h,0D6h,0CBh,0ABh, 92h
		db	0C4h,0D6h,0CBh,0ABh, 92h,0C5h
		db	0D6h,0CBh,0ABh, 92h,0C5h,0D6h
		db	0CBh,0ABh, 92h,0C5h,0D6h,0CBh
		db	0ABh, 92h,0C5h,0D6h,0CBh,0ABh
		db	 92h,0C5h,0D6h,0CBh,0ABh, 92h
		db	0C5h,0D6h,0CBh,0ABh, 8Ah,0C4h
		db	0C7h,0D4h,0D7h,0C4h, 66h,0D6h
		db	0CBh,0ABh, 85h,0C4h, 66h,0CAh
		db	0C8h, 46h, 67h,0CAh,0C7h,0CBh
		db	0ABh, 84h,0C4h,0C8h,0CAh, 07h
		db	 08h,0CAh,0C8h,0CAh, 47h,0CBh
		db	0ABh, 83h,0C4h, 57h, 58h, 67h
		db	 49h, 57h,0CAh,0CBh,0ABh, 83h
		db	 47h,0C9h,0CBh,0CCh,0CDh,0D0h
		db	0D1h, 47h, 49h, 47h,0C9h, 47h
		db	0CBh,0ABh, 83h,0C8h,0CBh,0CCh
		db	 6Dh,0D0h,0D1h, 47h,0CAh, 47h
		db	0D2h, 47h,0CBh,0ABh, 83h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h, 47h
		db	0CBh,0D1h, 57h,0CBh,0ABh, 83h
		db	0CBh,0CCh, 05h, 0Eh,0D0h,0D1h
		db	 06h, 08h,0CBh,0ABh, 83h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h, 77h
		db	0C9h,0C8h,0CBh,0ABh, 83h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h, 77h
		db	0D2h,0C8h,0CBh,0ABh, 83h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h,0C8h
		db	0CAh, 77h,0CBh,0ABh, 83h,0CBh
		db	0CCh, 05h, 0Eh,0D0h,0D1h, 06h
		db	 08h,0CBh,0ABh,0FFh,0FFh,0FFh
		db	0FFh,0FFh,0FFh, 15h, 00h, 0Eh
		db	0C1h, 12h,0C7h, 00h, 21h, 00h
		db	0FFh,0FFh,0FFh, 32h, 00h, 0Eh
		db	 82h, 17h, 39h, 00h, 05h, 80h
		db	 36h, 00h, 80h,0FFh,0FFh, 36h
		db	 00h, 80h, 76h,0C2h, 00h,0FFh
		db	 78h,0C2h,0FFh,0FFh,0FFh,0FFh
		db	 32h, 00h,0FFh, 10h,0C0h,0CCh
		db	0C2h, 0Ah,0C0h, 62h,0C2h,0B9h
		db	0C2h, 0Ch, 0Ch,0B6h,0C2h, 15h
		db	 00h,0FFh,0FFh,0FFh,0FFh, 15h
		db	0AFh, 02h, 12h
		db	'Cavern of Caliente'
		db	 99h, 00h, 06h, 0Dh,0FFh, 0Dh
		db	 0Ch, 0Ch, 10h,0C0h,0CCh,0C2h
		db	 0Ah,0C0h, 6Eh,0C2h, 32h, 00h
		db	0FFh,0FFh,0FFh,0FFh
header_1	dd	0FFFFFFFFh

seg_a		ends



		end
