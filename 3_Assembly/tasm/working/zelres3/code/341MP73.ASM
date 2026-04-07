
PAGE  59,132

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫ				_341MP73                                 ЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫ      Created:   5-Apr-26		                                 ЫЫ
;ЫЫ      Code type: device drivr	                                 ЫЫ
;ЫЫ      Passes:    5          Analysis	Options on: none                 ЫЫ
;ЫЫ					                                 ЫЫ
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_2e		equ	1183h			;*
data_3e		equ	49C1h			;*
data_4e		equ	5283h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_341MP73	proc	far


_341MP73	endp

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;
;                       External Entry Point
;
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

strategy_1	proc	far
		stosw				; Store ax to es:[di]
		add	[bx+si],ax
		add	ds:data_3e[bx+di],dl
		add	[di-3Fh],ch
char_dev	db	'oБqБ', 7Fh, 'БЃБ'
		db	 83h,0C1h,0A9h,0C1h, 01h,0FFh
		db	0FFh, 00h, 0Ch, 00h, 00h, 6Dh
		db	0C1h, 83h, 11h, 03h,0ABh, 83h
		db	 11h, 03h,0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h,0ABh, 83h
		db	 11h, 03h,0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h,0ABh, 83h
		db	 11h, 03h,0ABh, 83h, 11h, 03h
		db	0ABh, 83h, 11h, 03h,0ABh, 83h
		db	 11h
strategy_1	endp


;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
;
;                       External Entry Point
;
;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

strategy	proc	far
		add	bp,ss:data_2e[bp+di]
		add	bp,ss:data_2e[bp+di]
		add	bp,ss:data_2e[bp+di]
		add	bp,ss:data_2e[bp+di]
		add	bp,ss:data_2e[bp+di]
		add	bp,ss:data_4e[bp+di]
		or	ax,[bp+si]
		push	dx
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
;*		add	word ptr [bp+si-3Eh],0FF8Ch
		db	 83h, 42h,0C2h, 8Ch	;  Fixup - byte match
		push	dx
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
		add	word ptr [bp+si-73h],52h
		stosw				; Store ax to es:[di]
;*		add	word ptr [bp+si-3Fh],0FF8Ch
		db	 83h, 42h,0C1h, 8Ch	;  Fixup - byte match
		push	dx
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si-74h],52h
		stosw				; Store ax to es:[di]
		adc	word ptr [bp+si+0Bh],1
		push	dx
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		adc	word ptr [bx+di],3
		stosw				; Store ax to es:[di]
		db	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
		db	 1Bh, 00h, 0Eh,0C0h, 07h,0DEh
		db	 00h,0FFh, 00h,0FFh,0FFh,0FFh
		db	0FFh,0FFh,0FFh,0FFh, 19h,0AFh
		db	 02h
		db	0Ah, 'In the Hut'
		db	 99h, 00h, 0Ah, 12h,0FFh, 07h
		db	 00h, 00h, 10h,0C0h,0A7h,0C1h
		db	 0Ah,0C0h, 73h,0C1h, 30h, 00h
		db	0FFh,0FFh,0FFh,0FFh
header_1	dd	0FFFFFFFFh
strategy	endp


seg_a		ends



		end
