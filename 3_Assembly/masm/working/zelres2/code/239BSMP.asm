
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				_239BSMP                                 €€
;€€					                                 €€
;€€      Created:   29-Mar-26		                                 €€
;€€      Code type: zero start		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'M4'                      ; Target assembler: MASM-4.0

include  srmacros.inc


seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	0

_239BSMP	proc	far

start:
		push	si
		or	ax,0
		db	0DBh,0C4h, 98h, 00h,0E0h,0C4h
		db	 03h,0F2h,0C4h,0F2h,0C4h, 09h
		db	0C5h, 20h,0C5h,0F4h,0CCh,0D7h
		db	0C4h, 3Ch, 00h, 13h,0C5h, 00h
		db	23 dup (0)
		db	96h
		db	7 dup (97h)
		db	0A8h,0BCh,0BEh,0C0h,0C2h,0C4h
		db	0C6h,0C8h,0A9h,0BDh,0BFh,0C1h
		db	0C3h,0C5h,0C7h,0C9h,0AAh,0C9h
		db	0CBh,0BCh,0CCh,0CCh,0CCh,0CCh
		db	0B0h,0CAh,0CAh,0BCh,0CCh,0D3h
		db	0D4h,0D4h,0B1h,0A7h,0C1h,0BCh
		db	0CCh,0D1h,0D2h,0D2h, 00h,0B6h
		db	0C6h,0BDh,0CCh,0CCh,0CCh,0CCh
		db	 00h,0B7h,0AEh,0BEh,0C5h,0C6h
		db	0C0h,0C2h, 00h, 00h,0B1h,0BAh
		db	0C8h,0C3h,0C9h,0CAh, 00h, 00h
		db	 00h,0B5h,0C3h,0C9h,0BEh,0C5h
		db	 00h, 00h, 00h, 00h, 9Ch,0C9h
		db	0BFh,0C6h, 00h, 00h, 00h, 00h
		db	0B2h,0B4h,0C0h,0C7h, 00h, 00h
		db	 00h, 00h,0B3h,0B5h,0C1h,0C8h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Ch,0C9h, 00h, 00h, 00h, 00h
		db	 00h, 00h,0BBh,0BAh, 00h, 00h
		db	 00h, 00h, 00h, 00h, 00h,0B9h
		db	 00h, 65h, 68h, 6Ch, 6Ch, 70h
		db	 74h, 00h
		db	'cfimmquwd'
		db	 85h, 89h, 85h, 89h, 8Eh, 8Eh
		db	 92h, 79h, 7Dh, 81h, 85h, 8Ah
		db	 85h, 91h, 93h, 7Ah, 7Eh, 82h
		db	 86h, 8Bh, 8Fh, 8Eh, 94h, 7Bh
		db	 7Fh, 83h, 87h, 8Ch, 8Ch, 8Eh
		db	 92h, 7Ch, 80h, 84h, 88h, 8Dh
		db	 8Dh, 91h, 93h, 7Ah, 7Eh, 84h
		db	 85h, 89h, 8Dh, 8Eh, 94h, 7Bh
		db	 81h, 85h, 86h, 8Ah, 90h, 8Eh
		db	 92h, 64h, 6Ah, 86h, 87h, 8Bh
		db	 88h, 91h, 93h, 00h, 6Bh, 6Ah
		db	 88h, 8Ch, 8Bh, 76h, 78h, 00h
		db	 00h, 6Bh, 6Fh, 72h, 6Fh, 00h
		db	 00h, 00h, 00h, 0Bh, 14h, 14h
		db	 14h, 14h, 14h, 00h, 03h, 0Ch
		db	 15h, 15h, 15h, 15h, 15h, 00h
		db	 04h, 0Dh, 16h, 16h, 16h, 16h
		db	 16h, 00h, 05h, 0Dh, 16h, 16h
		db	 16h, 16h, 16h, 00h, 06h, 0Dh
		db	 16h, 51h, 16h, 16h, 16h, 00h
		db	 06h, 0Dh, 16h, 52h, 1Ch, 1Ch
		db	 1Ch, 00h, 06h, 0Dh, 16h, 53h
		db	 01h, 01h, 01h, 00h, 06h, 0Dh
		db	 16h, 54h, 16h, 16h, 16h, 00h
		db	 06h, 0Eh, 18h, 18h, 18h, 18h
		db	 18h, 00h, 07h, 0Fh, 19h, 19h
		db	 19h, 19h, 19h, 00h, 08h, 10h
		db	 19h, 19h, 19h, 19h, 19h, 00h
		db	 09h, 11h, 19h, 1Dh, 1Dh, 19h
		db	 19h, 00h, 5Eh, 5Dh, 19h, 19h
		db	 19h, 19h, 19h, 00h, 00h, 13h
		db	 1Bh, 1Bh, 1Bh, 1Bh, 1Bh, 00h
		db	 65h, 68h, 6Ch, 70h, 73h, 00h
		db	 00h, 63h, 66h, 69h, 6Dh, 71h
		db	 71h, 74h, 00h, 64h, 67h, 89h
		db	 89h, 89h, 6Eh, 75h, 77h, 79h
		db	 7Dh, 81h, 85h, 8Ah, 8Eh, 92h
		db	 92h, 7Ah, 7Eh, 82h, 86h, 8Bh
		db	 8Dh, 91h, 93h, 7Bh, 7Fh, 83h
		db	 87h, 8Ch, 8Eh, 8Eh, 92h, 7Ch
		db	 80h, 84h, 88h, 8Ch, 8Ah, 91h
		db	 92h, 00h, 80h, 85h, 81h, 86h
		db	 8Bh, 90h, 94h, 63h, 66h, 85h
		db	 84h, 88h, 8Dh, 91h, 95h
		db	'dgjnnnvx'
		db	 00h, 00h, 6Bh, 6Fh, 72h, 6Fh
		db	 72h, 00h, 00h, 00h,0D7h,0DDh
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	0D8h,0DEh,0E6h,0E6h,0E6h,0E4h
		db	 00h, 00h,0D8h,0DFh,0E6h,0E6h
		db	0E6h,0E5h, 00h, 00h,0D8h,0DEh
		db	0E4h,0E6h,0E6h,0E6h, 00h, 00h
		db	0D8h,0DFh,0E5h,0E8h,0E8h,0E8h
		db	 00h, 00h

_239BSMP	endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		db	0D8h,0DEh,0E4h, 01h, 01h, 01h
		db	 00h, 00h,0D8h,0DFh,0E5h, 01h
		db	 01h, 01h, 00h, 00h,0D8h,0DEh
		db	0E4h,0E9h,0E9h,0E9h, 00h, 02h
		db	0D9h,0E0h,0E5h,0EAh,0EAh,0EAh
		db	 00h, 00h,0DAh,0E1h,0EFh,0EFh
		db	0EEh,0ECh, 00h, 00h,0DBh,0E1h
		db	0EFh,0EEh,0EFh,0EDh, 00h, 00h
		db	0DBh,0E1h,0EFh,0EFh,0EFh,0EEh
		db	 00h, 00h,0DCh,0E3h, 00h, 00h
		db	 00h, 00h, 00h, 65h, 68h, 00h
		db	 6Ch, 70h, 73h, 00h, 63h, 66h
		db	 69h, 70h, 6Dh, 8Dh, 75h, 77h
		db	 79h, 7Dh, 81h, 8Bh, 85h, 88h
		db	 8Eh, 94h, 7Ah, 7Eh, 82h, 86h
		db	 8Bh, 8Fh, 8Eh, 94h, 7Bh, 7Fh
		db	 83h, 87h, 8Ch, 90h, 91h, 95h
		db	 7Ch, 80h, 84h, 88h, 8Dh, 88h
		db	 8Eh, 92h, 64h, 81h, 85h, 6Eh
		db	 89h, 89h, 76h, 78h, 00h, 00h
		db	 6Bh, 6Fh, 72h, 72h, 00h, 00h
		db	 00h, 00h,0D7h, 23h, 23h, 23h
		db	 23h, 23h, 00h, 00h,0D8h, 22h
		db	 22h, 22h, 22h, 22h, 00h, 00h
		db	0D8h, 22h, 22h, 22h, 22h, 22h
		db	 00h, 00h,0D8h, 22h, 55h, 22h
		db	 22h, 22h, 00h, 00h,0D8h, 22h
		db	 56h, 1Ch, 1Ch, 1Ch, 00h, 00h
		db	0D8h, 22h, 57h, 01h, 01h, 01h
		db	 00h, 00h,0D9h, 22h, 58h, 22h
		db	 22h, 22h, 00h, 00h,0DAh, 24h
		db	 24h, 24h, 24h, 24h, 00h, 00h
		db	0DBh, 24h, 24h, 24h, 24h, 24h
		db	 00h, 00h,0DBh, 24h, 24h, 24h
		db	 24h, 24h, 00h, 00h,0DCh, 25h
		db	 25h, 25h, 25h, 25h, 00h, 00h
		db	 00h, 00h, 6Ch, 70h, 74h, 00h
		db	 00h, 00h, 63h, 6Dh, 6Dh, 71h
		db	 75h, 77h, 00h, 00h, 64h, 6Eh
		db	 6Eh, 89h, 76h, 78h, 00h, 00h
		db	 00h, 00h, 6Fh, 72h, 00h, 00h
		db	 00h, 00h, 00h, 5Fh, 14h, 14h
		db	 14h, 14h, 00h, 00h, 03h, 62h
		db	 1Fh, 1Fh, 1Fh, 20h, 00h, 00h
		db	 04h, 0Dh, 1Fh, 1Fh, 1Fh, 20h
		db	 00h, 00h, 05h, 0Dh, 4Dh, 1Fh
		db	 1Fh, 20h, 00h, 00h, 06h, 0Dh
		db	 4Eh, 1Ch, 1Ch, 1Ch, 00h, 00h
		db	 06h, 0Dh, 4Fh, 01h, 01h, 01h
		db	 00h, 00h, 06h, 0Dh, 50h, 1Fh
		db	 1Fh, 20h, 00h, 00h, 06h, 0Eh
		db	 18h, 18h, 18h, 18h, 00h, 00h
		db	 07h, 0Fh, 19h, 19h, 19h, 19h
		db	 00h, 00h, 08h, 10h, 19h, 19h
		db	 19h, 19h, 00h, 00h, 09h, 11h
		db	 19h, 19h, 19h, 19h, 00h, 00h
		db	 5Eh, 60h, 19h, 19h, 19h, 19h
		db	 00h, 00h, 00h, 61h, 1Bh, 1Bh
		db	 1Bh, 1Ah, 00h, 63h, 66h, 6Dh
		db	 6Dh, 71h, 75h, 77h, 00h, 64h
		db	 67h, 6Eh, 71h, 71h, 76h, 78h
		db	 00h, 00h, 00h, 6Fh, 72h, 6Fh
		db	 72h, 00h, 00h, 00h, 0Bh, 14h
		db	 14h, 14h, 14h, 14h, 00h, 03h
		db	 0Ch, 15h, 15h, 15h, 15h, 15h
		db	 00h, 04h, 0Dh, 16h, 16h, 16h
		db	 16h, 16h, 00h, 05h, 0Dh, 16h
		db	 16h, 16h, 16h, 16h, 00h, 06h
		db	 0Dh, 16h, 16h, 16h, 16h, 16h
		db	 00h, 06h, 0Dh, 16h, 59h, 17h
		db	 17h, 17h, 00h, 06h, 0Dh, 16h
		db	 5Ah, 1Ch, 1Ch, 1Ch, 00h, 06h
		db	 0Dh, 16h, 5Bh, 01h, 01h, 01h
		db	 00h, 06h, 0Dh, 16h, 5Ch, 16h
		db	 16h, 16h, 00h, 06h, 0Dh, 16h
		db	 16h, 16h, 16h, 16h, 00h, 06h
		db	 0Eh, 18h, 18h, 18h, 18h, 18h
		db	 00h, 07h, 0Fh, 19h, 19h, 19h
		db	 19h, 19h, 00h, 08h, 10h, 19h
		db	 1Ah, 1Ah, 19h, 19h, 00h, 09h
		db	 11h, 19h, 1Dh, 1Dh, 19h, 19h
		db	 02h, 0Ah, 12h, 19h, 19h, 19h
		db	 19h, 19h, 00h, 00h, 13h, 1Bh
		db	 1Bh, 1Bh, 1Bh, 1Bh, 00h, 00h
		db	 00h, 6Ch, 6Ch, 73h, 00h, 00h
		db	 00h, 65h, 69h, 6Dh, 6Dh, 8Dh
		db	 74h, 00h, 00h, 66h, 89h, 85h
		db	 8Dh, 8Dh, 75h, 77h, 7Ch, 80h
		db	 84h, 88h, 89h, 8Eh, 8Eh, 94h
		db	 00h, 64h, 6Ah, 8Ch, 89h, 87h
		db	 8Bh, 93h, 00h, 00h, 6Bh, 6Eh
		db	 8Ch, 6Eh, 76h, 78h, 00h, 00h
		db	 00h, 00h, 72h, 6Fh, 72h, 00h
		db	 00h, 00h, 00h, 00h, 00h, 00h
		db	 9Bh, 99h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 9Ch, 9Ah, 00h, 00h
		db	 00h, 00h, 00h, 99h,0BCh,0BEh
		db	 00h, 00h, 00h, 00h, 99h,0BCh
		db	0BDh,0BFh, 00h, 00h, 00h, 99h
		db	 9Ah,0BCh,0C0h,0C2h, 00h, 00h
		db	0A2h, 9Ah,0BCh,0BEh,0C1h,0C3h
		db	 00h, 00h,0A3h,0C0h,0BDh,0BFh
		db	0C1h,0C6h, 00h,0ACh,0ADh,0C1h
		db	0C2h,0C2h,0C5h,0C7h, 00h,0A9h
		db	0C8h,0C2h,0C6h,0C3h,0C8h,0BFh
		db	 00h,0A8h,0C9h,0CBh,0BFh,0C4h
		db	0C9h,0CBh, 00h,0A9h,0BCh,0BEh
		db	0CCh,0CCh,0CCh,0CCh, 00h,0A6h
		db	0BDh,0BFh,0CCh,0CDh,0CEh,0CEh
		db	0A5h,0A7h,0C0h,0C2h,0CCh,0CFh
		db	0D0h,0D0h, 00h,0A0h,0C1h,0C3h
		db	0CCh,0CCh,0CCh,0CCh,0A2h,0A4h
		db	0C4h,0C6h,0BFh,0CAh,0BFh,0C5h
		db	 9Fh,0A1h,0C5h,0C7h,0C6h,0C5h
		db	0C5h,0CAh,0A0h,0C4h,0C8h,0CAh
		db	0CAh,0BFh,0CAh,0CAh, 96h
		db	7 dup (97h)
		db	24 dup (0)
		db	 43h, 00h, 7Bh, 00h, 04h, 00h
		db	0FFh, 00h, 01h, 18h,0AFh, 00h
		db	 0Eh
		db	'Bosque village'
		db	 07h, 00h, 09h, 24h, 00h, 06h
		db	 3Dh, 00h, 02h, 51h, 00h, 04h
		db	 60h, 00h, 03h, 72h, 00h, 07h
		db	 8Eh, 00h, 08h,0FFh,0FFh,0B9h
		db	 00h, 13h, 00h, 05h, 95h, 00h
		db	 0Eh, 01h, 06h, 12h, 00h, 08h
		db	0FAh,0CCh, 80h,0FBh,0CCh, 0Eh
		db	0FFh,0FFh,0FFh,0FFh, 3Eh,0C5h
		db	 05h,0C6h, 93h,0C6h, 95h,0C7h
		db	0FAh,0C7h, 46h,0C8h,0F9h,0C8h
		db	0B3h,0C9h, 3Eh,0CAh, 19h,0CBh
		db	 8Dh,0CBh,0FAh,0CBh, 28h,0CCh
		db	 5Ah,0CCh,0B5h,0CCh
		db	'Welcome to Bosque Village, brave'
		db	' warrior. This once was a forest'
		db	' surrounding a temple, but the t'
		db	'emple was destroyed by Jashiin. '
		db	'Now the village of Bosque is des'
		db	'olate. I hope you are here to he'
		db	'lp us.'
		db	0FFh, 4Ch, 69h
		db	'sten, stranger, a sentry is post'
		db	'ed on the outskirts of the city.'
		db	' I\m telling you this for your o'
		db	'wn good; it\s best to stay away '
		db	'from there.'
		db	0FFh, 54h, 68h
		db	'e temple that once stood here ha'
		db	'd the crest of the Warrior God c'
		db	'arved into it. Winners of the ma'
		db	'rtial arts competitions held in '
		db	'front of the temple were awarded'
		db	' with such crests. Thus the cres'
		db	't, the symbol of a true hero, be'
		db	'came known as the Hero\s Crest.'
		db	0FFh, 57h, 68h
		db	'en he destroyed the temple, Jash'
		db	'iin stole the Hero\s Crest.  No '
		db	'one has any idea where to find i'
		db	't.'
		db	0FFh, 54h, 68h
		db	'e crest must be hidden somewhere'
		db	' in the forest, but I couldn\t s'
		db	'ay where.'
		db	0FFh, 57h, 68h
		db	'en the temple was destroyed I he'
		db	'ard Jashiin ordering his underli'
		db	'ngs to hide the crest in the tru'
		db	'nk of the biggest tree. That mus'
		db	't be where it is hidden. I hope '
		db	'you can find it.'
		db	0FFh, 41h, 20h
		db	'spirit appeared and told me to s'
		db	'ay this if I met a brave man: "I'
		db	'f you go through the door to the'
		db	' right of the tree that forms a '
		db	'cross, you will be able to go up'
		db	'."/I&hope it helps you.'
		db	0FFh, 49h, 20h
		db	'have some advice for you: Be car'
		db	'eful if you come to a place wher'
		db	'e the leaves of the trees are th'
		db	'in. The ground there is not very'
		db	' strong.'
		db	0FFh, 54h, 68h
		db	'e sentry at the edge of town say'
		db	's the Spirits came to him in a d'
		db	'ream, and told him not to allow '
		db	'anyone to pass unless they bear '
		db	'the Hero\s Crest. I wonder if th'
		db	'e Spirits really ordered such a '
		db	'thing? Perhaps he\s mad.'
		db	0FFh, 41h, 20h
		db	'few have slipped by the sentry u'
		db	'ndetected, but none have returne'
		db	'd. There must be some terrible m'
		db	'onster out there.'
		db	0FFh, 54h, 68h
		db	'at sentry must have sold his sou'
		db	'l to Jashiin. Why else would he '
		db	'interfere with brave men such as'
		db	' yourself?'
		db	0FFh, 48h, 6Fh
		db	'ld on there! Do you have the Her'
		db	'o\s Crest? '
		db	 81h, 44h, 6Fh, 6Eh, 5Ch
		db	't lie, it won\t do any good. Get'
		db	' out of here!'
		db	0FFh, 59h, 6Fh
		db	'u cannot pass here without the H'
		db	'ero\s Crest. My orders are from '
		db	'the Spirits themselves! '
		db	0FFh, 48h, 6Fh
		db	'ld on there! You have the Hero\s'
		db	' Crest, I see. You may pass.'
		db	0FFh, 09h, 00h, 01h,0CCh, 00h
		db	 04h,0C0h, 0Bh, 65h, 00h, 81h
		db	 19h, 00h, 00h, 00h, 02h, 15h
		db	 00h, 04h, 8Eh, 00h, 05h, 00h
		db	 0Ah, 6Bh, 00h, 04h, 6Fh, 00h
		db	 05h, 00h, 06h, 57h, 00h, 84h
		db	 25h, 00h, 06h, 00h, 04h, 83h
		db	 00h, 00h, 00h, 03h, 03h, 00h
		db	 00h, 4Fh, 00h, 00h, 22h, 00h
		db	 01h, 00h, 01h, 5Ah, 00h, 00h
		db	 89h, 00h, 02h, 00h, 07h, 2Ch
		db	 00h, 00h, 1Bh, 03h, 03h, 00h
		db	 08h, 44h, 00h, 00h, 00h, 00h
		db	 05h, 00h, 05h, 59h, 00h, 02h
		db	 8Bh, 03h, 03h, 00h, 03h, 20h
		db	 00h, 02h, 15h, 00h, 06h, 00h
		db	 09h,0FFh,0FFh
sub_1		endp


seg_a		ends



		end	start
