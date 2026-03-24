
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR2_36	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_17e	equ	72C3h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_36		proc	far

start:
		mov	si,8
		add	ss:data_17e[bp+di],ch
		add	data_4[bx+si],dh
;*		mov	bl,0CAh
		db	0C6h,0C3h,0CAh		;  Fixup - byte match
		retn
		db	 00h, 00h,0F6h,0C3h, 9Ch,0C8h
		db	0A7h,0C3h, 22h, 00h,0D2h,0C3h
		db	26 dup (0)
		db	'<=====UX\ldeimVZ]aeflnWZ^bfgkoTX'
		db	'\`ddimUY]alejmVZ^bfglnW[_cghioVX'
		db	'X^\`imVY\_]aooVZ_`ddim', 0
		db	'WYbceln', 0
		db	'VZdgimo', 0
		db	'U`ceglm', 0
		db	'?B`ddhm'
		db	 00h, 00h, 46h, 49h, 60h, 49h
		db	 51h, 53h, 00h, 00h, 00h, 00h
		db	 4Dh, 4Ah
		db	11 dup (0)
		db	 38h, 06h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 39h, 07h, 13h, 13h
		db	 13h, 13h, 13h, 02h, 3Ah, 08h
		db	 14h, 14h, 14h, 14h, 14h, 00h
		db	 3Bh, 09h, 00h, 0Eh, 32h, 34h
		db	 36h, 00h, 00h, 00h, 0Dh, 0Eh
		db	 33h, 35h, 37h, 00h, 00h, 00h
		db	 0Eh, 11h, 33h, 34h, 36h, 00h
		db	 00h, 02h, 0Eh, 17h, 33h, 34h
		db	 37h, 00h, 00h, 00h, 0Fh, 15h
		db	 33h, 34h, 36h, 00h, 00h, 38h
		db	 00h, 0Eh, 33h, 34h, 37h, 00h
		db	 00h, 39h, 0Ah, 11h, 33h, 34h
		db	 36h, 00h, 02h, 3Ah, 0Bh, 11h
		db	 32h, 34h, 37h, 00h, 00h, 39h
		db	 0Bh, 11h, 32h, 34h, 36h, 00h
		db	 00h, 3Ah, 0Bh, 17h, 32h, 34h
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h
		db	 32h, 35h, 36h, 00h, 00h, 3Ah
		db	 0Bh, 11h, 33h, 35h, 37h, 00h
		db	 00h, 3Ah, 0Bh, 17h, 33h, 35h
		db	 36h, 00h, 02h, 39h, 0Bh, 11h
		db	 33h, 35h, 37h, 00h, 00h, 39h
		db	 0Bh, 17h, 33h, 35h, 36h, 00h
		db	 00h, 3Ah, 0Bh, 11h, 33h, 34h
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h
		db	 32h, 34h, 36h, 00h, 00h, 39h
		db	 0Bh, 17h, 32h, 34h, 37h, 00h
		db	 00h, 3Ah, 0Bh, 11h, 33h, 34h
		db	 36h, 00h, 02h, 39h, 0Ch, 11h
		db	 33h, 34h, 37h, 00h, 00h, 3Bh
		db	 00h, 15h, 33h, 35h, 36h, 00h
		db	 38h, 00h, 00h, 0Eh, 33h, 35h
		db	 37h, 00h, 39h, 0Ah, 10h, 17h
		db	 33h, 35h, 36h, 02h, 3Ah, 0Bh
		db	 11h, 18h, 18h, 18h, 19h, 00h
		db	 3Ah, 0Bh, 11h, 18h, 18h, 18h
		db	 19h, 00h, 3Ah, 0Bh, 11h, 18h
		db	 18h, 18h, 19h, 00h, 39h, 0Bh
		db	 11h, 1Bh, 20h, 26h, 2Ch, 00h
		db	 39h, 0Bh, 11h, 1Ch, 21h, 27h
		db	 2Dh, 00h, 3Ah, 0Bh, 11h, 1Dh
		db	 22h, 28h, 2Eh
data_4		db	2			; Data table (indexed access)
		db	 3Ah, 0Bh, 11h, 1Dh, 23h, 29h
		db	 2Fh, 00h, 3Ah, 0Bh, 11h, 1Eh
		db	 24h, 2Ah, 30h, 00h, 39h, 0Bh
		db	 11h, 1Fh, 25h, 2Bh, 31h, 00h
		db	 3Ah, 0Bh, 11h, 18h, 18h, 18h
		db	 1Ah, 00h, 3Ah, 0Bh, 11h, 18h
		db	 18h, 18h, 1Ah, 00h, 39h, 0Bh
		db	 11h, 18h, 18h, 18h, 1Ah, 02h
		db	 39h, 0Ch, 12h, 16h, 01h, 01h
		db	 01h, 00h, 3Bh, 00h, 00h, 0Eh
		db	 32h, 33h, 36h, 00h, 00h, 38h
		db	 00h, 0Eh, 33h, 35h, 37h, 00h
		db	 00h, 3Ah, 0Ah, 11h, 33h, 35h
		db	 36h, 00h, 02h, 3Ah, 0Bh, 17h
		db	 33h, 35h, 37h, 00h, 00h, 39h
		db	 0Bh, 11h, 33h, 35h, 36h, 00h
		db	 00h, 3Ah, 0Bh, 17h, 33h, 35h
		db	 37h, 00h, 00h, 39h, 0Bh, 11h
		db	 33h, 35h, 36h, 00h, 00h, 39h
		db	 0Bh, 17h, 33h, 35h, 37h, 00h
		db	 00h, 39h, 0Bh, 11h, 33h, 35h
		db	 36h, 00h, 02h, 3Ah, 0Bh, 17h
		db	 33h, 35h, 37h, 00h, 00h, 3Ah
		db	 0Bh, 11h, 33h, 35h, 36h, 00h
		db	 00h, 39h, 0Bh, 11h, 33h, 35h
		db	 37h, 00h, 00h, 3Ah, 0Bh, 11h
		db	 33h, 35h, 36h, 00h, 00h, 39h
		db	 0Bh, 11h, 33h, 35h, 37h, 00h
		db	 00h, 3Ah, 0Bh, 11h, 33h, 35h
		db	 36h, 00h, 02h, 3Ah, 0Ch, 11h
		db	 33h, 35h, 37h, 00h, 00h, 3Bh
		db	 00h, 0Eh, 33h, 35h, 36h, 00h
		db	 00h, 00h, 0Dh, 15h, 33h, 35h
		db	 37h, 00h, 00h, 00h, 0Eh, 11h
		db	 33h, 35h, 36h, 00h, 00h, 02h
		db	 15h, 11h, 32h, 34h, 37h, 00h
		db	 00h, 00h, 0Fh, 15h, 32h, 34h
		db	 36h, 00h, 38h, 06h, 00h, 0Eh
		db	 32h, 34h, 37h, 00h, 39h, 07h
		db	 13h, 13h, 13h, 13h, 13h, 02h
		db	 3Ah, 08h, 14h, 14h, 14h, 14h
		db	 14h, 00h, 3Bh, 09h, 00h, 00h
		db	 00h, 00h, 00h, 00h
		db	 40h, 43h
		db	'GKNO', 0
		db	'>ADHLLPRTX\``eimUY]aaflmVZ^bbgkm'
		db	'W[_ccfimTX^`dfi'
		db	 95h, 55h, 59h, 5Dh, 81h, 85h
		db	 86h, 87h, 99h, 56h, 5Ah, 71h
		db	 82h, 64h, 68h, 6Ch, 96h, 54h
		db	 71h, 79h, 81h, 01h, 88h, 8Fh
		db	 97h, 55h, 72h, 7Ah, 82h, 01h
		db	 89h, 90h, 98h, 56h, 73h, 7Bh
		db	 81h, 01h, 8Ah, 91h, 99h, 57h
		db	 74h, 7Ch, 82h, 01h, 8Bh, 92h
		db	 99h, 54h, 75h, 7Dh, 83h, 85h
		db	 86h, 87h, 9Ah, 55h, 76h, 7Eh
		db	 84h, 01h, 8Ch, 93h, 9Bh, 56h
		db	 77h, 7Fh, 83h, 01h, 8Dh, 8Dh
		db	 9Bh, 54h, 78h, 80h, 84h, 01h
		db	 8Eh, 94h, 9Bh, 55h, 59h, 78h
		db	 83h, 64h, 64h, 69h, 9Bh, 56h
		db	 5Ah, 5Ch, 84h, 85h, 86h, 87h
		db	 9Bh, 57h, 5Bh, 5Dh, 60h, 63h
		db	 68h, 6Ch, 9Ch
		db	'T\\`diimUY]adgimVZ^behkmW[_cfcln'
		db	'TX\`'
		db	 60h, 63h, 69h, 6Dh
		db	32 dup (0)
		db	 33h, 00h, 6Dh, 00h, 00h, 00h
		db	0FFh, 00h, 00h, 16h,0AFh, 00h
		db	 12h
		db	'Felishika\s Castle'
		db	 00h, 01h, 00h, 01h, 5Fh, 00h
		db	 01h, 34h, 00h, 00h,0FFh,0FFh
		db	 49h, 00h,0FFh, 0Fh,0C0h, 94h
		db	 10h,0C0h,0C8h, 8Eh,0C3h, 3Dh
		db	0A3h,0C8h, 06h,0ABh,0C8h, 07h
		db	0B3h,0C8h, 08h,0BBh,0C8h, 09h
		db	0FFh,0FFh, 04h, 00h,0FFh, 9Bh
		db	0C8h, 05h,0FFh,0FFh,0FFh,0FFh
		db	 0Ah,0C4h,0ACh,0C4h, 53h,0C5h
		db	0C3h,0C5h, 2Ch,0C6h,0C4h,0C6h
		db	0E1h,0C6h, 52h,0C7h,0ABh,0C7h
		db	 1Fh,0C8h
		db	'If you are the brave warrior we '
		db	'have awaited, we have something '
		db	'to tell you: throughout the ages'
		db	', many young men have entered th'
		db	'e caverns, but few have returned'
		db	'.'
		db	0FFh, 41h, 63h
		db	'cording to legend, there may sti'
		db	'll be underground places that ha'
		db	've not been destroyed by Jashiin'
		db	'. People may still be living the'
		db	're, and will surely lend you a h'
		db	'and.'
		db	0FFh, 49h, 20h
		db	'have been in the underground tow'
		db	'n. After I fled, they put a lock'
		db	' on the door. If the town is sti'
		db	'll there.... '
		db	0FFh, 54h, 68h
		db	'is is the chamber of poor Prince'
		db	'ss Felicia, who has been turned '
		db	'to stone. You may enter, Duke Ga'
		db	'rland.'
		db	0FFh, 42h, 72h
		db	'ave knight, you have awakened. W'
		db	'hen you fell at the hand of Jash'
		db	'iin, the Spirits brought you her'
		db	'e. Now make haste to the aid of '
		db	'the Princess Felicia.'
		db	0FFh
		db	'Quickly, go to the Princess!'
		db	0FFh
		db	'Ah, the Nine Tears of Esmesanti.'
		db	' Jashiin exists no more and the '
		db	'light of peace shines once again'
		db	' on our land... '
		db	0FFh, 54h, 68h
		db	'is will benefit the people livin'
		db	'g underground, as well. Hurry to'
		db	' the Princess Felicia.'
		db	0FFh, 54h, 68h
		db	'e peace we dared not hope for ha'
		db	's come. I\ll get my things toget'
		db	'her and be on my way. I\ve a fam'
		db	'ily to attend to.'
		db	0FFh, 51h, 75h
		db	'ickly, enter this chamber. The h'
		db	'oly crystals will break the evil'
		db	' spell which has turned Princess'
		db	' Felicia to stone.'
		db	0FFh, 24h, 00h, 82h, 00h, 03h
		db	 03h, 80h, 04h, 30h, 00h, 81h
		db	 18h, 00h, 00h, 00h, 00h, 38h
		db	 00h, 81h, 18h, 00h, 00h, 00h
		db	 01h, 54h, 00h, 80h, 00h, 01h
		db	 03h, 00h, 02h, 5Ch, 00h, 81h
		db	 18h, 00h, 00h, 00h, 03h,0FFh
		db	0FFh

zr2_36		endp

seg_a		ends



		end	start
