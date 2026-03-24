
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ZR2_38	                                 лл
;лл					                                 лл
;лл      Created:   16-Feb-26		                                 лл
;лл      Code type: zero start		                                 лл
;лл      Passes:    9          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

zr2_38		proc	far

start:
		lodsb				; String [si] to al
		or	al,0
;*		add	bl,dl
		db	 00h,0D3h		;  Fixup - byte match
		db	0C6h,0D7h, 00h,0D8h,0C6h, 02h
		db	0E7h,0C6h,0EFh,0C6h, 00h,0C7h
		db	 0Ch,0C7h, 72h,0CCh,0CFh,0C6h
		db	 5Ch, 00h, 0Ah,0C7h, 00h, 00h
		db	 00h
		db	29 dup (0)
		db	 89h, 8Dh, 82h, 00h, 00h, 00h
		db	 00h, 00h, 8Ah, 8Eh, 83h, 00h
		db	 00h, 00h, 00h, 00h, 74h, 7Bh
		db	 82h, 00h, 00h, 00h, 00h, 00h
		db	 75h, 7Ch, 83h, 00h, 00h, 00h
		db	 00h, 00h, 74h, 7Bh, 82h, 00h
		db	 00h, 00h, 95h, 98h, 75h, 7Ch
		db	 83h, 00h, 00h, 00h, 00h, 00h
		db	 74h, 7Bh, 82h, 00h, 00h, 95h
		db	 97h, 99h, 75h, 7Ch, 83h, 00h
		db	 00h, 00h, 00h, 00h, 8Bh, 8Fh
		db	 82h, 00h, 95h, 97h, 96h, 99h
		db	 8Ch, 90h, 83h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 91h, 93h, 95h
		db	 96h, 96h, 96h, 99h, 00h, 92h
		db	 94h, 00h
		db	77 dup (0)
		db	 0Eh, 14h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h
		db	 01h, 07h, 1Ah, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h
		db	24 dup (0)
		db	 1Dh, 1Fh, 1Fh, 1Fh, 1Fh, 1Fh
		db	 1Fh, 1Dh, 1Eh, 21h, 21h, 21h
		db	 21h, 21h, 21h, 1Eh, 1Eh, 21h
		db	 6Ch, 2Fh, 31h, 31h, 31h, 1Eh
		db	 1Eh, 20h, 6Dh, 30h, 32h, 32h
		db	 32h, 1Eh, 1Eh, 1Fh, 6Eh, 30h
		db	 00h, 00h, 00h, 1Eh, 1Eh, 21h
		db	 6Fh, 2Fh, 31h, 31h, 31h, 1Eh
		db	 1Eh, 21h, 21h, 1Fh, 21h, 21h
		db	 21h, 1Eh, 1Eh, 21h, 21h, 1Fh
		db	 20h, 21h, 1Fh
		db	'cc""""""cc""#%""Pc""$'
		db	'&""'
		db	 00h, 50h, 22h, 22h, 22h, 22h
		db	 22h, 22h, 00h
		db	40 dup (0)
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 0Dh, 13h, 19h, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 01h, 07h
		db	 1Ah, 1Bh, 1Bh, 1Bh, 1Bh, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h
		db	 01h, 07h, 1Ah, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h
		db	17 dup (0)
		db	59h
		db	7 dup (0)
		db	'Z]____5;Z]____6<Z]____6<Z]_aaa6<'
		db	'Z]_'
		db	 00h, 00h, 00h, 36h, 3Ch, 5Ah
		db	']____6<Z]____6<Z]____8=Z]____9>['
		db	'^````9>[^````9>[^````:;[^````'
		db	 00h, 00h, 5Bh, 5Eh, 60h, 60h
		db	 60h, 60h, 00h, 00h
		db	5Ch
		db	38 dup (0)
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 0Dh, 13h
		db	 19h, 1Bh, 1Bh, 1Bh, 1Bh, 00h
		db	 01h, 07h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h
		db	24 dup (0)
		db	'F', 27h, 27h, 27h, 27h, 27h, 27h
		db	'?G(', 27h, 27h, 27h, 27h, 27h, '@'
		db	'H', 27h, 27h, '(', 27h, 27h, 27h
		db	'AG', 27h, 'pbbbb@H', 27h, 'qb222'
		db	'AG(rb'
		db	 00h, 00h, 00h, 40h, 48h
		db	27h, 'sbbbbAG', 27h, 27h, 27h, 27h
		db	27h, '(@H', 27h, 27h, '(', 27h, 27h
		db	27h, 'AG', 27h, 27h, 27h, 27h, 27h
		db	27h, '@I))))))AJ))*)*)DK))))))EL)'
		db	')))))'
		db	25 dup (0)
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h
		db	17 dup (0)
		db	'MNNRNN5;NNQQRS6<Nh/1116<Ri02226<'
		db	'Oj0'
		db	 00h, 00h, 00h, 36h, 3Ch, 52h
		db	'k/1116<OSRNNR7<NSRNRN8=TUTTTV9>V'
		db	'UTUTT:;TTTTVT'
		db	0, 0
		db	 58h, 54h, 56h, 54h, 54h, 56h
		db	25 dup (0)
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 00h, 00h, 00h, 1Ch, 1Ch, 1Ch
		db	 1Ch, 00h, 00h, 00h, 00h, 1Ch
		db	 1Ch, 1Ch, 1Ch, 00h, 00h, 00h
		db	 00h, 1Ch, 1Ch, 1Ch, 1Ch, 00h
		db	 0Dh, 13h, 19h, 1Bh, 1Bh, 1Bh
		db	 1Bh, 00h, 01h, 07h, 1Ah, 1Bh
		db	 1Bh, 1Bh, 1Bh, 00h
		db	17 dup (0)
		db	 46h, 9Ah, 9Ah, 9Ah, 9Bh, 9Ah
		db	 00h, 3Fh, 47h, 9Bh, 9Ah, 9Bh
		db	 9Bh, 9Bh, 00h, 40h, 48h, 64h
		db	 62h, 62h, 62h, 62h, 00h, 41h
		db	 47h, 65h, 62h, 61h, 61h, 61h
		db	 00h, 42h, 48h, 66h, 62h, 00h
		db	 00h, 00h, 00h, 41h, 47h, 67h
		db	 62h, 62h, 62h, 62h, 00h, 42h
		db	 48h, 9Bh, 9Ah, 9Ah, 9Bh, 9Ah
		db	 00h, 41h, 47h, 9Bh, 9Bh, 9Bh
		db	 9Bh, 9Bh, 00h, 42h, 49h, 9Dh
		db	 9Dh, 9Dh, 9Dh, 9Dh, 00h, 43h
		db	 4Ah, 9Dh, 9Dh, 9Dh, 9Dh, 9Dh
		db	 00h, 44h, 4Bh, 9Dh, 9Dh, 9Dh
		db	 9Dh, 9Dh, 00h, 45h, 4Ch, 9Dh
		db	 9Dh, 9Dh, 9Dh, 9Dh
		db	41 dup (0)
		db	 79h, 80h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 7Ah, 81h, 84h, 85h
		db	 85h, 85h, 87h, 74h, 7Bh, 82h
		db	 00h, 00h, 00h, 00h, 00h, 75h
		db	 7Ch, 83h, 00h, 84h, 86h, 85h
		db	 87h, 74h, 7Bh, 82h, 00h, 00h
		db	 00h, 00h, 00h, 75h, 7Ch, 83h
		db	 00h, 00h, 84h, 86h, 87h, 74h
		db	 7Bh, 82h, 00h, 00h, 00h, 00h
		db	 00h, 75h, 7Ch, 83h, 00h, 00h
		db	 00h, 84h, 88h, 74h, 7Dh, 82h
		db	 00h, 00h, 00h, 00h, 00h, 76h
		db	 7Eh, 83h, 00h, 00h, 00h, 00h
		db	 00h, 77h, 7Fh, 82h, 00h, 00h
		db	 00h, 00h, 00h, 78h, 7Fh, 83h
		db	 00h, 00h
		db	35 dup (0)
		db	 24h, 00h,0B4h, 00h, 02h, 01h
		db	0FFh, 01h, 02h, 19h,0AFh, 03h
		db	 0Bh
		db	'Satono Town'
		db	 81h, 00h,0FFh,0FFh, 80h, 01h
		db	0FFh,0FFh, 2Ch, 00h, 04h, 5Ch
		db	 00h, 02h, 80h, 00h, 07h, 94h
		db	 00h, 06h,0B9h, 00h, 03h,0FFh
		db	0FFh, 80h, 00h, 21h, 01h, 00h
		db	 06h, 00h, 3Eh, 00h, 02h,0FFh
		db	0FFh, 1Ah,0C7h,0FBh,0C7h,0C2h
		db	0C8h, 98h,0C9h, 6Fh,0CAh, 02h
		db	0CBh, 9Dh,0CBh
		db	'Welcome, stranger. You must have'
		db	' come through the labyrinths fro'
		db	'm the outside world. We have not'
		db	' encountered such a brave person'
		db	' in a very long time. You should'
		db	' visit the great sage Yasmin -- '
		db	'she will be anxious to meet you.'
		db	0FFh, 53h, 6Fh
		db	' you\re the brave one I\ve heard'
		db	' about. Well, if you\re going to'
		db	' go on from here, I\ll give you '
		db	'a tip.  When you come to a stopp'
		db	'ing place, dig a hole. The demon'
		db	's have hidden jewels in many pla'
		db	'ces.'
		db	0FFh, 41h, 72h
		db	'e you Duke Garland? Thank the Sp'
		db	'irits you\ve come. We escaped fr'
		db	'om Jashiin through the power of '
		db	'the Spirits. However, if his pow'
		db	'er should become so strong that '
		db	'the Spirits\ can\t protect us, t'
		db	'his town is doomed.'
		db	0FFh, 4Ch, 65h
		db	't me give you some advice, stran'
		db	'ger. If you fall down the stone '
		db	'slab in front of the blue door, '
		db	'you will see a green door nearby'
		db	'. Don\t go through that door und'
		db	'er any circumstances -- it is a '
		db	'doorway to the past.'
		db	0FFh, 42h, 65h
		db	'ware! I went into the caverns an'
		db	'd saw an awful creature -- a gia'
		db	'nt demon octopus. It was terrify'
		db	'ing, but I escaped. I hope you w'
		db	'ill be as lucky.'
		db	0FFh, 41h, 72h
		db	'e you the brave one? I&hope you '
		db	'have brought almas for us. The a'
		db	'lmas are part of Jashiin\s power'
		db	'. We use them to make medicine, '
		db	'and other useful things.'
		db	0FFh, 44h, 75h
		db	'ke Garland, when you go into the'
		db	' caverns again, please try to br'
		db	'ing back more almas. To suppleme'
		db	'nt the protective power of the S'
		db	'pirits we must build a wall of a'
		db	'lmas. Unless we get more, Satono'
		db	' Town is in peril.'
		db	0FFh, 25h, 00h, 03h, 1Ch, 00h
		db	 01h, 00h, 02h,0C4h, 00h, 00h
		db	 00h, 03h, 03h, 00h, 04h, 16h
		db	 00h, 01h, 00h, 03h, 03h, 00h
		db	 00h, 56h, 00h, 04h, 00h, 00h
		db	 01h, 00h, 01h, 79h, 00h, 82h
		db	 00h, 00h, 02h, 00h, 03h, 9Dh
		db	 00h, 02h, 00h, 00h, 01h, 00h
		db	 05h,0A3h, 00h, 83h, 1Ch, 00h
		db	 02h, 00h, 06h,0FFh,0FFh

zr2_38		endp

seg_a		ends



		end	start
