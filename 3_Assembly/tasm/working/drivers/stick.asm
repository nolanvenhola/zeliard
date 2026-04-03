
PAGE  59,132

;==========================================================================
;
;  STICK.BIN - Joystick & Keyboard Input Driver
;
;  Interrupt-driven multi-input driver supporting:
;  - Keyboard scanning with remappable scan codes
;  - Joystick support with dead zone calibration (port 201h)
;  - Pause/menu state management
;  - Save/load game file I/O with compression
;  - Game state machine (pause, exit dialogs)
;
;  Entry Points (jump table at offset 0):
;    +0x00  Keyboard IRQ handler (INT 09h replacement)
;    +0x03  Joystick/input polling (called from INT 08h timer)
;    +0x06  Game state handler (pause/exit dialogs)
;    +0x09  Input state query (returns current button/direction)
;
;  Code type: zero start
;  Created:   16-Feb-26
;  Passes:    9          Analysis Options on: none
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; External references - graphics/screen functions in loaded segments

gfx_screen_base	equ	2000h			; Screen buffer base
gfx_fn_setup	equ	2022h			; Screen setup function
gfx_fn_draw	equ	2026h			; Screen draw function
gfx_fn_restore	equ	2028h			; Screen restore function
gfx_fn_clear	equ	202Ah			; Screen clear function
save_file_magic	equ	444Dh			; Save file magic number 'DM'

; Game state variables (0xFF00+ shared with zeliad.exe and game.bin)

gvar_chunk_load_fn equ	0FF00h			; Chunk loader function
gvar_old_int08	equ	0FF04h			; Original INT 08h vector
gvar_key_released equ	0FF09h			; Key released flag
gvar_last_key	equ	0FF0Ah			; Last key scancode
gvar_input_fn	equ	0FF0Ch			; Input handler function ptr
gvar_gfx_fn	equ	0FF10h			; Graphics handler function ptr
gvar_timer_flag	equ	0FF16h			; Timer flag
gvar_timer_count equ	0FF17h			; Timer counter
gvar_skip_input	equ	0FF18h			; Input skip flag
gvar_frame_timer equ	0FF1Ah			; Frame timer
gvar_anim_timer	equ	0FF1Bh			; Animation timer
gvar_skip_flag	equ	0FF1Dh			; Skip/interrupt flag
gvar_state_a	equ	0FF1Eh			; Game state A
gvar_state_b	equ	0FF1Fh			; Game state B
gvar_sound_flag	equ	0FF27h			; Sound enabled flag
gvar_key_pressed equ	0FF28h			; Key pressed scancode
gvar_enter_key	equ	0FF29h			; Enter key scancode (0x0D)
gvar_save_name	equ	0FF33h			; Save filename (8 chars)
gvar_music_state equ	0FF3Bh			; Music state flag
gvar_joy_cal_x	equ	0FF48h			; Joystick X calibration
gvar_joy_cal_y	equ	0FF49h			; Joystick Y calibration
gvar_frame_count equ	0FF50h			; Frame counter
gvar_volume_a	equ	0FF74h			; Volume A
gvar_volume_b	equ	0FF75h			; Volume B
gvar_old_int09	equ	0FF78h			; Original INT 09h vector
gvar_old_int09_seg equ	0FF79h			; Original INT 09h segment
herc_video_seg	equ	0B000h			; Hercules video segment
zero_offset	equ	0			; Zero constant
dialog_text_ofs	equ	0E34h			; Dialog text offset

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

stick		proc	far

start:
		jmp	kbd_irq_handler
		jmp	timer_isr_entry
		jmp	game_state_handler
		jmp	query_input_state
			                        ; Driver config/init data embedded after jump table (offset 0x0C)

driver_init_data:
		test	cl,[bp+si]
		pop	ss
		db	0Fh			; pop cs (8088 only; alt-encoding: Fixup byte match)
		lodsb				; String [si] to al
		push	es
		and	ax,[bx]
		mov	dh,7
		or	word ptr [bx+si],8EFh
		sbb	[bx+di],cl
		db	0D6h, 09h, 2Dh, 09h, 9Eh, 08h

stick		endp

handle_pause_key		proc	near
		test	byte ptr cs:[2BEh],0FFh
		jz	hpk_pause_was_set			; Jump if zero
		test	byte ptr cs:gvar_timer_flag,1
		jz	hpk_pause_done			; Jump if zero
		mov	byte ptr cs:[2BEh],0
		mov	byte ptr cs:gvar_skip_flag,0FFh
		jmp	short hpk_pause_done

hpk_pause_was_set:
		test	byte ptr cs:gvar_timer_flag,1
		jnz	hpk_pause_done			; Jump if not zero
		mov	byte ptr cs:[2BEh],0FFh

hpk_pause_done:
		test	byte ptr cs:[2BFh],0FFh
		jz	hpk_btn_off			; Jump if zero
		test	byte ptr cs:gvar_timer_flag,2
		jnz	hpk_pause_set			; Jump if not zero
		retn

hpk_pause_set:
		mov	byte ptr cs:[2BFh],0
		mov	byte ptr cs:gvar_state_a,0FFh
		retn

hpk_btn_off:
		test	byte ptr cs:gvar_timer_flag,2
		jz	hpk_btn_set			; Jump if zero
		retn

hpk_btn_set:
		mov	byte ptr cs:[2BFh],0FFh
		retn

handle_pause_key		endp

poll_joystick_buttons		proc	near
		test	byte ptr cs:gvar_music_state,0FFh
		jnz	pjb_music_on			; Jump if not zero
		retn

pjb_music_on:
		test	byte ptr cs:gvar_last_key,0FFh
		jnz	pjb_joy_on			; Jump if not zero
		retn

pjb_joy_on:
		mov	dx,201h
		in	al,dx			; port 201h, start game 1-shots
		call	decode_joystick_bits
		jmp	short pjb_btnb_check

;���� External Entry into Subroutine ��������������������������������������

decode_joystick_bits:
		test	byte ptr cs:[2C0h],0FFh
		jz	pjb_btna_off			; Jump if zero
		test	al,10h
		jz	pjb_btna_released			; Jump if zero
		retn

pjb_btna_released:
		mov	byte ptr cs:[2C0h],0
		mov	byte ptr cs:gvar_skip_flag,0FFh
		retn

pjb_btna_off:
		test	al,10h
		jnz	pjb_btna_set			; Jump if not zero
		retn

pjb_btna_set:
		mov	byte ptr cs:[2C0h],0FFh
		retn

pjb_btnb_check:
		test	byte ptr cs:[2C1h],0FFh
		jz	pjb_btnb_off			; Jump if zero
		test	al,20h			; ' '
		jz	pjb_btnb_released			; Jump if zero
		retn

pjb_btnb_released:
		mov	byte ptr cs:[2C1h],0
		mov	byte ptr cs:gvar_state_a,0FFh
		retn

pjb_btnb_off:
		test	al,20h			; ' '
		jnz	pjb_btnb_set			; Jump if not zero
		retn

pjb_btnb_set:
		mov	byte ptr cs:[2C1h],0FFh
		retn

poll_joystick_buttons		endp

handle_special_keys		proc	near
		test	byte ptr cs:[2C2h],0FFh
		jz	hsk_skip_off			; Jump if zero
		cmp	word ptr cs:gvar_skip_input,1000h
		jne	hsk_chk_sound			; Jump if not equal
		mov	byte ptr cs:gvar_volume_b,1
		mov	byte ptr cs:[2C2h],0
		mov	cl,cs:gvar_key_pressed
		mov	ax,2
		int	60h			; ??INT Non-standard interrupt
		jmp	short hsk_chk_sound

hsk_skip_off:
		cmp	word ptr cs:gvar_skip_input,1000h
		je	hsk_chk_sound			; Jump if equal
		mov	byte ptr cs:[2C2h],0FFh

hsk_chk_sound:
		test	byte ptr cs:[2C3h],0FFh
		jz	hsk_sound_off			; Jump if zero
		cmp	word ptr cs:gvar_skip_input,2000h
		je	hsk_toggle_sound			; Jump if equal
		retn

hsk_toggle_sound:
		mov	byte ptr cs:[2C3h],0
		not	byte ptr cs:gvar_sound_flag
		mov	byte ptr cs:gvar_volume_b,1
		retn

hsk_sound_off:
		cmp	word ptr cs:gvar_skip_input,2000h
		jne	hsk_sound_set			; Jump if not equal
		retn

hsk_sound_set:
		mov	byte ptr cs:[2C3h],0FFh
		retn

handle_special_keys		endp

timer_isr_entry:
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
		call	dword ptr cs:gvar_gfx_fn
		call	dword ptr cs:gvar_input_fn
		dec	byte ptr cs:[2BCh]
		jnz	tis_subsample_done			; Jump if not zero
		mov	byte ptr cs:[2BCh],5
		call	handle_special_keys
		call	handle_pause_key
		call	poll_joystick_buttons

tis_subsample_done:
		inc	byte ptr cs:gvar_frame_timer
		inc	word ptr cs:gvar_frame_count
		inc	word ptr cs:gvar_anim_timer
		inc	byte ptr cs:[2C4h]
		test	byte ptr cs:gvar_state_b+1,0FFh
		jz	tis_no_callback			; Jump if zero
		call	word ptr cs:gvar_state_b

tis_no_callback:
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		dec	byte ptr cs:[2BDh]
		jz	tis_chain_int08			; Jump if zero
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		pop	ax
		iret				; Interrupt return

tis_chain_int08:
		mov	byte ptr cs:[2BDh],0Dh
		pop	ax
		jmp	dword ptr cs:gvar_old_int08
		db	 0Ah, 0Dh		; CRLF padding bytes
		db	7 dup (0)		; Alignment padding

kbd_irq_handler:
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
		je	kbd_bad_scancode			; Jump if equal
		cmp	al,0FEh
		je	kbd_bad_scancode			; Jump if equal
		call	process_scancode

kbd_flush_loop:
			mov	ah,1
			int	16h			; Keyboard i/o  ah=function 01h
							;  get status, if zf=0  al=char
			jz	kbd_done			; Jump if zero
			xor	ah,ah			; Zero register
			int	16h			; Keyboard i/o  ah=function 00h
							;  get keybd char in al, ah=scan
			jmp	short kbd_flush_loop

kbd_done:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	dword ptr cs:gvar_old_int09_seg

kbd_bad_scancode:
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

process_scancode		proc	near
		push	ax
		call	dispatch_extended_key
		pop	ax
		cmp	al,0E0h
		jb	ps_valid_scan			; Jump if below
		retn

ps_valid_scan:
		mov	ah,al
		and	al,7Fh
		mov	cl,8
		cmp	al,4Dh			; 'M'
		je	ps_dir_match			; Jump if equal
		cmp	al,4Eh			; 'N'
		je	ps_dir_match			; Jump if equal
		mov	cl,4
		cmp	al,4Bh			; 'K'
		je	ps_dir_match			; Jump if equal
		cmp	al,2Bh			; '+'
		je	ps_dir_match			; Jump if equal
		mov	cl,2
		cmp	al,50h			; 'P'
		je	ps_dir_match			; Jump if equal
		cmp	al,4Ah			; 'J'
		je	ps_dir_match			; Jump if equal
		mov	cl,1
		cmp	al,48h			; 'H'
		je	ps_dir_match			; Jump if equal
		cmp	al,29h			; ')'
		jne	ps_not_dir			; Jump if not equal

ps_dir_match:
		or	byte ptr ds:[5C1h],cl
		test	ah,80h
		jnz	ps_dir_release			; Jump if not zero
		jmp	ps_merge_input

ps_dir_release:
		xor	byte ptr ds:[5C1h],cl
		jmp	ps_merge_input

ps_not_dir:
		mov	cl,5
		cmp	al,47h			; 'G'
		je	ps_diag_match			; Jump if equal
		mov	cl,90h
		cmp	al,49h			; 'I'
		je	ps_diag_match			; Jump if equal
		mov	cl,60h			; '`'
		cmp	al,4Fh			; 'O'
		je	ps_diag_match			; Jump if equal
		mov	cl,0Ah
		cmp	al,51h			; 'Q'
		jne	ps_not_diag			; Jump if not equal

ps_diag_match:
		or	byte ptr ds:[5C2h],cl
		test	ah,80h
		jnz	ps_diag_release			; Jump if not zero
		jmp	ps_merge_input

ps_diag_release:
		xor	byte ptr ds:[5C2h],cl
		jmp	ps_merge_input

ps_not_diag:
		test	byte ptr ds:gvar_volume_a,0FFh
		jz	ps_kbd_layout			; Jump if zero
		mov	byte ptr ds:[5C3h],0
		mov	byte ptr ds:[5C4h],0
		jmp	short ps_btn_check

ps_kbd_layout:
		mov	cl,8
		cmp	al,25h			; '%'
		je	ps_kdir_match			; Jump if equal
		mov	cl,4
		cmp	al,23h			; '#'
		je	ps_kdir_match			; Jump if equal
		mov	cl,2
		cmp	al,32h			; '2'
		je	ps_kdir_match			; Jump if equal
		mov	cl,1
		cmp	al,16h
		jne	ps_kdiag_check			; Jump if not equal

ps_kdir_match:
		or	byte ptr ds:[5C3h],cl
		test	ah,80h
		jz	ps_extra_keys			; Jump if zero
		xor	byte ptr ds:[5C3h],cl
		jmp	short ps_extra_keys

ps_kdiag_check:
		mov	cl,5
		cmp	al,15h
		je	ps_kdiag_match			; Jump if equal
		mov	cl,90h
		cmp	al,17h
		je	ps_kdiag_match			; Jump if equal
		mov	cl,60h			; '`'
		cmp	al,31h			; '1'
		je	ps_kdiag_match			; Jump if equal
		mov	cl,0Ah
		cmp	al,33h			; '3'
		jne	ps_btn_check			; Jump if not equal

ps_kdiag_match:
		or	byte ptr ds:[5C4h],cl
		test	ah,80h
		jz	ps_extra_keys			; Jump if zero
		xor	byte ptr ds:[5C4h],cl
		jmp	short ps_extra_keys

ps_btn_check:
		mov	cl,1
		cmp	al,39h			; '9'
		je	ps_btn_match			; Jump if equal
		mov	cl,2
		cmp	al,38h			; '8'
		jne	ps_extra_keys			; Jump if not equal

ps_btn_match:
		or	ds:gvar_timer_flag,cl
		test	ah,80h
		jz	ps_extra_keys			; Jump if zero
		xor	ds:gvar_timer_flag,cl
		jmp	short ps_extra_keys

ps_extra_keys:
		mov	cx,800h
		cmp	al,25h			; '%'
		je	ps_extra_match			; Jump if equal
		mov	cx,400h
		cmp	al,13h
		je	ps_extra_match			; Jump if equal
		mov	cx,200h
		cmp	al,12h
		je	ps_extra_match			; Jump if equal
		mov	cx,100h
		cmp	al,24h			; '$'
		je	ps_extra_match			; Jump if equal
		mov	cx,80h
		cmp	al,1Fh
		je	ps_extra_match			; Jump if equal
		mov	cx,40h
		cmp	al,31h			; '1'
		je	ps_extra_match			; Jump if equal
		mov	cx,20h
		cmp	al,15h
		je	ps_extra_match			; Jump if equal
		mov	cx,10h
		cmp	al,10h
		je	ps_extra_match			; Jump if equal
		mov	cx,8
		cmp	al,1
		je	ps_extra_match			; Jump if equal
		mov	cx,4
		cmp	al,1Dh
		je	ps_extra_match			; Jump if equal
		mov	cx,2
		cmp	al,36h			; '6'
		je	ps_extra_match			; Jump if equal
		cmp	al,2Ah			; '*'
		je	ps_extra_match			; Jump if equal
		mov	cx,1
		cmp	al,1Ch
		je	ps_extra_match			; Jump if equal
		mov	cx,1000h
		cmp	al,3Bh			; ';'
		je	ps_extra_match			; Jump if equal
		mov	cx,2000h
		cmp	al,3Ch			; '<'
		je	ps_extra_match			; Jump if equal
		mov	cx,4000h
		cmp	al,41h			; 'A'
		je	ps_extra_match			; Jump if equal
		mov	cx,8000h
		cmp	al,43h			; 'C'
		jne	ps_merge_input			; Jump if not equal

ps_extra_match:
		or	ds:gvar_skip_input,cx
		test	ah,80h
		jz	ps_merge_input			; Jump if zero
		xor	ds:gvar_skip_input,cx

ps_merge_input:
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
		mov	ds:gvar_timer_count,al
		retn

process_scancode		endp

dispatch_extended_key		proc	near
		cmp	al,0E0h
		jb	dek_not_ext			; Jump if below
		mov	byte ptr cs:[5C5h],0FFh
		retn

dek_not_ext:
		test	byte ptr cs:[5C5h],0FFh
		mov	byte ptr cs:[5C5h],0
		jz	dek_was_ext			; Jump if zero
		retn

dek_was_ext:
		or	al,al			; Zero ?
		jns	dek_sign_clear			; Jump if not sign
		retn

dek_sign_clear:
		cmp	al,54h			; 'T'
		jb	dek_below_54			; Jump if below
		retn

dek_below_54:
		dec	al
		xor	bx,bx			; Zero register
		mov	bl,al
		mov	di,511h
		test	word ptr cs:gvar_skip_input,2
		jz	dek_no_shift			; Jump if zero
		mov	di,569h

dek_no_shift:
		mov	al,cs:[bx+di]
		mov	cs:gvar_enter_key,al
		retn

dispatch_extended_key		endp

; Scancode-to-ASCII translation table (unshifted, offset 0x511 in file)
; Indexed by scancode-1 (scancodes 0x01..0x53)

scancode_unshifted:
		db	0			; scancode 01h = Esc (no printable)
		db	'1234567890'		; scancodes 02h-0Bh
		db	0, 0, 8, 0		; 0Ch=-, 0Dh==, 0Eh=BS, 0Fh=Tab (BS=8)
		db	'QWERTYUIOP'		; 10h-19h
		db	 00h, 00h, 0Dh, 00h	; 1Ah=[, 1Bh=], 1Ch=Enter(0Dh), 1Dh=Ctrl
		db	'ASDFGHJKL'		; 1Eh-26h
		db	0, 0, 0, 0, 0		; 27h=;, 28h=', 29h=`, 2Ah=Shift, 2Bh=Backslash
		db	'ZXCVBN'		; 2Ch-31h
		db	'M'			; 32h
		db	39 dup (0)		; 33h-59h padding/special keys
; Scancode-to-ASCII translation table (shifted, offset 0x569 in file)

scancode_shifted:
		db	'!', '@', 0, '$', '%', 0 ; shift 02h-07h: !@#$%
		db	 00h, 00h, 28h, 29h, 00h, 00h ; shift 08h-0Dh: ()
		db	 08h, 00h		; shift 0Eh=BS, 0Fh
		db	'QWERTYUIOP{}'		; 10h-1Bh
		db	0Dh			; 1Ch=Enter
		db	0			; 1Dh=Ctrl
		db	'ASDFGHJKL:'		; 1Eh-27h
		db	0, 0, 0, 0		; 28h-2Bh
		db	'ZXCVBN'		; 2Ch-31h
		db	'M'			; 32h
		db	47 dup (0)		; 33h-61h padding

calibrate_joystick		proc	near
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

joy_wait_start:
			in	al,dx			; port 201h, start game 1-shots
			xor	al,ah
			jz	joy_read_loop			; Jump if zero
			dec	bl
			jnz	joy_wait_start			; Jump if not zero

joy_read_loop:
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
			jnz	joy_read_loop			; Jump if not zero
		sti				; Enable interrupts
		retn

calibrate_joystick		endp

query_input_state:
		push	bx
		push	cx
		push	dx
		mov	byte ptr cs:gvar_joy_cal_x,0
		mov	byte ptr cs:gvar_joy_cal_y,0
		mov	al,cs:gvar_music_state
		and	al,ds:gvar_last_key
		jz	qis_no_joystick			; Jump if zero
		call	calc_joystick_deadzone

qis_no_joystick:
		mov	al,cs:gvar_timer_count
		or	al,cs:gvar_joy_cal_x
		mov	ah,cs:gvar_timer_flag
		or	ah,cs:gvar_joy_cal_y
		pop	dx
		pop	cx
		pop	bx
		iret				; Interrupt return

calc_joystick_deadzone		proc	near
		push	si
		push	di
		push	cx
		call	calibrate_joystick
		mov	cx,word ptr cs:[5C6h]
		add	cx,8
		jnc	cdz_x_hi_ok			; Jump if carry=0
		mov	cx,0FFFFh

cdz_x_hi_ok:
		cmp	si,cx
		jb	cdz_x_hi_set			; Jump if below
		or	byte ptr cs:gvar_joy_cal_x,8

cdz_x_hi_set:
		mov	cx,word ptr cs:[5C6h]
		shr	cx,1			; Shift w/zeros fill
		sub	cx,8
		jnc	cdz_x_lo_ok			; Jump if carry=0
		xor	cx,cx			; Zero register

cdz_x_lo_ok:
		cmp	si,cx
		ja	cdz_x_lo_set			; Jump if above
		or	byte ptr cs:gvar_joy_cal_x,4

cdz_x_lo_set:
		mov	cx,word ptr cs:[5C8h]
		add	cx,8
		jnc	cdz_y_hi_ok			; Jump if carry=0
		mov	cx,0FFFFh

cdz_y_hi_ok:
		cmp	di,cx
		jb	cdz_y_hi_set			; Jump if below
		or	byte ptr cs:gvar_joy_cal_x,2

cdz_y_hi_set:
		mov	cx,word ptr cs:[5C8h]
		shr	cx,1			; Shift w/zeros fill
		sub	cx,8
		jnc	cdz_y_lo_ok			; Jump if carry=0
		xor	cx,cx			; Zero register

cdz_y_lo_ok:
		cmp	di,cx
		ja	cdz_y_lo_set			; Jump if above
		or	byte ptr cs:gvar_joy_cal_x,1

cdz_y_lo_set:
		mov	dx,201h
		in	al,dx			; port 201h, start game 1-shots
		not	al
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		and	al,3
		mov	cs:gvar_joy_cal_y,al
		pop	cx
		pop	di
		pop	si
		retn

calc_joystick_deadzone		endp

			                        ; Called via game_state dispatch: skip_input==0x14 → exit dialog

exit_dlg_handler:
		cmp	word ptr cs:gvar_skip_input,14h
		je	exit_dlg_active			; Jump if equal
		retn

exit_dlg_active:
		push	ds
		call	handle_pause_key2
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		push	cs
		pop	ds
		mov	si,70Ah
		mov	bx,74h
		mov	cl,52h			; 'R'
		call	word ptr cs:gfx_fn_clear
		pop	ds

exit_wait_input:
			mov	ax,cs:gvar_skip_input
			test	ax,60h
			jz	exit_wait_input			; Jump if zero
		test	ax,20h
		jnz	exit_confirm_wait			; Jump if not zero
		call	handle_pause_key4
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		mov	byte ptr cs:gvar_timer_count,0
		mov	byte ptr cs:gvar_skip_flag,0
		mov	byte ptr cs:gvar_state_a,0
		retn

exit_confirm_wait:
			test	byte ptr cs:gvar_key_released,0FFh
			jz	exit_confirm_wait			; Jump if zero
		xor	ax,ax			; Zero register
		jmp	dword ptr cs:gvar_chunk_load_fn
		db	'Exit to DOS.', 0Dh, ' Sure?(Y/N)'
		; Exit dialog machine-code body (unreachable via normal flow;
		; executed via far-call from game engine after the Exit text above)
		db	0FFh, 2Eh,0F7h, 06h, 18h,0FFh	; jmp word ptr [06F7h]; test gvar_skip_input,...
		db	 08h, 00h, 75h, 01h,0C3h, 1Eh	; and 8; jnz +1; retn; push ds
		db	 2Eh,0C6h, 06h, 75h,0FFh, 02h	; mov byte ptr cs:[0FF75h],2
		db	0B8h, 1Eh, 10h,0B9h, 10h, 08h	; mov ax,101Eh; mov cx,810h
		db	0BFh, 80h, 3Ch, 2Eh,0FFh, 16h	; mov di,3C80h; call word ptr cs:[...]
		db	 26h, 20h, 2Eh, 83h, 3Eh, 18h	; (continued)
		db	0FFh, 0Eh, 74h, 1Ch,0BBh, 1Eh	; (continued)
		db	 20h,0B9h, 10h, 10h,0B0h,0FFh	; (continued)
		db	 2Eh,0FFh, 16h, 00h, 20h, 0Eh	; (continued)
		db	 1Fh,0BEh,0B0h, 07h,0BBh, 8Ch	; (continued)
		db	 00h,0B1h, 22h, 2Eh,0FFh, 16h	; (continued)
		db	 2Ah, 20h			; (continued)

pause_menu_restore:
		mov	cl,0FFh
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		pop	ds

pause_menu_loop:
			cmp	word ptr cs:gvar_skip_input,0Eh
			jne	pause_no_redraw			; Jump if not equal
			call	draw_screen_element

pause_no_redraw:
			test	byte ptr cs:gvar_skip_flag,0FFh
			jnz	pause_done			; Jump if not zero
			test	byte ptr cs:gvar_state_a,0FFh
			jnz	pause_done			; Jump if not zero
			jmp	short pause_menu_loop

pause_done:
		call	draw_screen_element
		mov	byte ptr cs:gvar_skip_flag,0
		mov	byte ptr cs:gvar_state_a,0
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		retn

draw_screen_element		proc	near
		mov	ax,101Eh
		mov	cx,810h
		mov	di,3C80h
		jmp	word ptr cs:gfx_fn_restore

draw_screen_element		endp

			                        ; Called via function pointer (thunk); chains to ds:[6F7h]

draw_fn_thunk:
		push	ax
		inc	cx
		push	bp
		push	bx
		inc	bp
		jmp	dword ptr ds:[6F7h]
			                        ; Small helper: clear carry via sbb bh,bh

sbb_bh_helper:
		db	 18h,0FFh		; sbb bh,bh (alt-encoding: Fixup byte match)
		add	byte ptr ds:[175h][bx+si],al
		retn
			                        ; Called via game_state dispatch: speed change handler

speed_change_handler:
		call	handle_pause_key2
		push	cs
		pop	ds
		mov	si,845h
		mov	bx,74h
		mov	cl,52h			; 'R'
		call	word ptr cs:gfx_fn_clear

spd_wait_key:
			test	word ptr cs:gvar_skip_input,8000h
			jnz	spd_wait_key			; Jump if not zero
		mov	al,ds:gvar_save_name
		neg	al
		add	al,0Ah
		call	handle_pause_key0
		push	ax
		add	al,30h			; '0'
		mov	ah,1
		mov	bx,0CCh
		mov	cl,5Ah			; 'Z'
		call	word ptr cs:gfx_fn_setup
		pop	ax
		neg	al
		add	al,0Ah
		mov	ds:gvar_save_name,al
		mov	byte ptr cs:gvar_volume_b,1
		call	handle_pause_key5
		mov	byte ptr cs:gvar_timer_count,0
		mov	byte ptr cs:gvar_skip_flag,0
		mov	byte ptr cs:gvar_state_a,0

spd_poll_input:
			mov	dl,0FFh
			mov	ah,6
			int	21h			; DOS Services  ah=function 06h
							;  special char i/o, dl=subfunc
			jnz	spd_done			; Jump if not zero
			mov	al,cs:gvar_timer_count
			or	al,cs:gvar_skip_flag
			or	al,cs:gvar_state_a
			jz	spd_poll_input			; Jump if zero

spd_done:
		call	handle_pause_key4
		mov	byte ptr cs:gvar_timer_count,0
		mov	byte ptr cs:gvar_skip_flag,0
		mov	byte ptr cs:gvar_state_a,0
		retn
		db	'Speed change', 0Dh, 'Select 0-9:'
		db	0FFh			; String terminator

handle_pause_key0		proc	near
		mov	byte ptr ds:gvar_enter_key,0

hpk0_wait_key:
				test	byte ptr ds:gvar_enter_key,0FFh
				jz	hpk0_wait_key			; Jump if zero
			mov	ah,ds:gvar_enter_key
			cmp	ah,1Bh
			stc				; Set carry flag
			jnz	hpk0_check_digit			; Jump if not zero
			retn

hpk0_check_digit:
			sub	ah,30h			; '0'
			cmp	ah,0Ah
			jae	hpk0_wait_key			; Jump if above or =
		clc				; Clear carry flag
		mov	al,ah
		retn

handle_pause_key0		endp

			                        ; Called via game_state dispatch: skip_input==0x104 → joystick calibrate

joy_cal_handler:
		cmp	word ptr cs:gvar_skip_input,104h
		je	jcal_active			; Jump if equal
		retn

jcal_active:
		call	handle_pause_key1
		mov	byte ptr cs:gvar_timer_count,0

jcal_wait_release:
			cmp	word ptr cs:gvar_skip_input,104h
			je	jcal_wait_release			; Jump if equal
		retn

handle_pause_key1		proc	near
		test	byte ptr cs:gvar_music_state,0FFh
		jz	hpk1_no_joy			; Jump if zero
		retn

hpk1_no_joy:
		test	byte ptr cs:gvar_last_key,0FFh
		jnz	hpk1_have_joy			; Jump if not zero
		retn

hpk1_have_joy:
		mov	cx,103h
		shl	ch,cl			; Shift w/zeros fill
		xchg	cx,ax
		mov	cx,0FFFFh
		mov	dx,201h

locloop_joy_fire_wait:
			in	al,dx			; port 201h, start game 1-shots
			test	al,ah
			loopnz	locloop_joy_fire_wait		; Loop if zf=0, cx>0

		jcxz	loc_ret_78		; Jump if cx=0
		call	calibrate_joystick
		db	 83h,0FEh,0FFh		; cmp si,-1 (cmp si,0FFFFh; alt-encoding sign-extend: Fixup byte match)
		jz	loc_ret_78		; Jump if zero
		db	 83h,0FFh,0FFh		; cmp di,-1 (cmp di,0FFFFh; alt-encoding sign-extend: Fixup byte match)
		jz	loc_ret_78		; Jump if zero
		or	si,si			; Zero ?
		jz	loc_ret_78		; Jump if zero
		or	di,di			; Zero ?
		jz	loc_ret_78		; Jump if zero
		mov	word ptr cs:[5C6h],si
		mov	word ptr cs:[5C8h],di
		mov	byte ptr cs:gvar_music_state,0FFh
		mov	byte ptr cs:gvar_volume_b,1

loc_ret_78:
		retn

handle_pause_key1		endp

			                        ; Called via game_state dispatch: skip_input==0x804 → joystick detach

joy_det_handler:
		cmp	word ptr cs:gvar_skip_input,804h
		je	jdet_active			; Jump if equal
		retn

jdet_active:
		test	byte ptr cs:gvar_music_state,0FFh
		jnz	jdet_has_joy			; Jump if not zero
		retn

jdet_has_joy:
		mov	byte ptr cs:gvar_volume_b,1
		mov	byte ptr cs:gvar_music_state,0

jdet_wait_release:
			cmp	word ptr cs:gvar_skip_input,804h
			je	jdet_wait_release			; Jump if equal
		retn
			                        ; Called via game_state dispatch: accumulate anim_timer for frame sync

frame_sync_update:
		mov	ax,cs:gvar_anim_timer
		add	al,ah
		adc	ah,0
		add	ax,word ptr cs:[92Bh]
		mov	word ptr cs:[92Bh],ax
		retn
		; Game-state dispatch handler stub (save/restore menu; accessed via dispatch table)
		; Decodes to: add [bx+si],al×2; cs: cmp gvar_skip_input,4000h; clc; je +1; retn;
		;             push ds; call near +0x60; mov cl,0FFh; mov ax,3; int 60h;
		;             push cs; pop ds; mov si,983h; mov bx,74h; mov cl,52h; call gfx_fn_clear; pop ds
		db	 00h, 00h, 2Eh, 81h, 3Eh, 18h
		db	0FFh, 00h, 40h,0F8h, 74h, 01h
		db	0C3h, 1Eh,0E8h, 60h, 00h,0B1h
		db	0FFh,0B8h, 03h, 00h,0CDh, 60h
		db	 0Eh, 1Fh,0BEh, 83h, 09h,0BBh
		db	 74h, 00h,0B1h, 52h, 2Eh,0FFh
		db	 16h, 2Ah, 20h, 1Fh

sav_wait_input:
			mov	ax,cs:gvar_skip_input
			test	ax,60h
			jz	sav_wait_input			; Jump if zero
		test	ax,20h
		pushf				; Push flags
		call	handle_pause_key4
		mov	byte ptr cs:gvar_timer_count,0
		mov	byte ptr cs:gvar_skip_flag,0
		mov	byte ptr cs:gvar_state_a,0
		xor	cl,cl			; Zero register
		mov	ax,3
		int	60h			; ??INT Non-standard interrupt
		popf				; Pop flags
		stc				; Set carry flag
		jz	sav_ok			; Jump if zero
		retn

sav_ok:
		clc				; Clear carry flag
		retn
		db	'Restore Game', 0Dh, ' Sure?(Y/N)'
		db	0FFh		; String terminator

handle_pause_key2		proc	near
		mov	byte ptr cs:gvar_volume_b,2

;���� External Entry into Subroutine ��������������������������������������

handle_pause_key3:
		mov	ax,0C46h
		mov	cx,1028h
		mov	di,3C80h
		call	word ptr cs:gfx_fn_draw
		mov	bx,1A46h
		mov	cx,1E28h
		mov	al,0FFh
		jmp	word ptr cs:gfx_screen_base

handle_pause_key2		endp

handle_pause_key4		proc	near
		mov	ax,0C46h
		mov	cx,1028h
		mov	di,3C80h
		jmp	word ptr cs:gfx_fn_restore

handle_pause_key4		endp

handle_pause_key5		proc	near
		push	dx

hpk5_flush_loop:
			mov	dl,0FFh
			mov	ah,6
			int	21h			; DOS Services  ah=function 06h
							;  special char i/o, dl=subfunc
			jnz	hpk5_flush_loop			; Jump if not zero
		pop	dx
		retn

handle_pause_key5		endp

			                        ; Called via game_state dispatch: scan save-file directory into buffer

scan_savefile_dir:
		push	ds
		mov	cs:scan_buf_ptr,di
		mov	word ptr cs:scan_buf_ptr+2,es
		mov	cs:search_path_ptr,dx
		mov	word ptr cs:search_path_ptr+2,ds
		mov	cx,0AF6h
		xor	al,al			; Zero register
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	di,cs:scan_buf_ptr
		mov	ax,di
		inc	di
		add	ax,201h
		mov	cx,0FFh

locloop_build_table:
			stosw				; Store ax to es:[di]
			add	ax,9
			loop	locloop_build_table		; Loop if cx > 0

		push	cs
		pop	ds
		mov	dx,offset dta_buffer
		mov	ah,1Ah
		int	21h			; DOS Services  ah=function 1Ah
						;  set DTA(disk xfer area) ds:dx
		lds	dx,dword ptr cs:search_path_ptr	; Load seg:offset ptr
		mov	cx,dx
		mov	ah,4Eh
		int	21h			; DOS Services  ah=function 4Eh
						;  find 1st filenam match @ds:dx
		jc	scan_done			; Jump if carry Set
		push	cs
		pop	ds
		les	di,dword ptr cs:scan_buf_ptr	; Load seg:offset ptr
		add	di,201h
		mov	cx,0FEh

locloop_scan_files:
			push	cx
			push	di
			mov	bx,cs:scan_buf_ptr
			inc	byte ptr es:[bx]
			mov	si,0A77h
			mov	cx,8

locloop_copy_name:
				lodsb				; String [si] to al
				cmp	al,2Eh			; '.'
				je	scan_name_done			; Jump if equal
				stosb				; Store al to es:[di]
				loop	locloop_copy_name		; Loop if cx > 0

scan_name_done:
			pop	di
			pop	cx
			mov	ah,4Fh
			int	21h			; DOS Services  ah=function 4Fh
							;  find next filename match
			jc	scan_done			; Jump if carry Set
			add	di,9
			loop	locloop_scan_files		; Loop if cx > 0

scan_done:
		pop	ds
		retn
		db	51 dup (0)		; Save-file data buffer (51 bytes zeroed)
		; INT 60h sub-function dispatch body (accessed via handler table):
		; cmp al,0; jne +3; jmp near +0x176; push di,si,ds,es;
		; cs: mov [0F5Ch],si; cs: mov [0F5Eh],ds; cs: mov [0F60h],di; cs: mov [0F62h],es;
		; pushf; cld; cmp al,7; jae ...; dec al; xor cx,cx; mov cl,al; mov bp,cx;
		; add bp,bp; cs: call word ptr [0x0FCAh + bp]
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

adj_carry_flag:
		pop	bx
		pushf				; Push flags
		pop	ax
		db	 83h,0E3h,0FEh		; and bx,-2 (and bx,0FFFEh; alt-encoding sign-extend: Fixup byte match)
		and	ax,1
		or	ax,bx
		push	ax
		popf				; Pop flags
		pop	es
		pop	ds
		pop	si
		pop	di
		retn
		; INT 60h sub-function dispatch table (word offsets to handlers, accessed via [0FCAh+bp]):
		; Followed by save-game code body (accessed via table):
		; cs: mov [0F60h],0C000h; cs: mov [0F62h],es; mov ah,al; or al,al; jns +4;
		; and al,7Fh; shl al,cl(=11); add ax,0F68h; cs: mov [0F5Ch],ax; cs: mov [0F5Eh],es;
		; jmp near +0x130; cs: les di,[0F60h]; push di; push es;
		; cs: mov [0F60h],0; mov ax,cs; add ax,3000h; mov es,ax; cs: mov [0F62h],es;
		; call +0x127(=handle_pause_key7?); mov bx,ax; mov cx,1; call +0x261(fio_read_block);
		; cs: mov cx,[0F64h]; dec cx; es: cmp byte [0],0; je +0x2A;
		; cs: mov [0F60h],0; mov cx,4; call +0x246; es: mov cx,[0];
		; cs: cmp byte [0FF14h],0; je +0x10; mov dx,cx; mov al,1; mov cx,0; ... int 21h
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
scan_buf_ptr		dw	0B400h, 0CD42h
search_path_ptr		dw	2621h, 0E8Bh
dta_buffer		db	2
		db	0

save_clear_done:
		mov	cs:file_read_buf_ptr,0
		call	handle_pause_key7
		push	ax
		call	handle_pause_key8
		pop	dx
		pop	es
		pop	di
		jmp	fio_decomp_entry
			                        ; Called via dispatch: load Hercules graphics font/display data

herc_load_display:
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
		mov	di,herc_video_seg
		mov	cx,800h
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,herc_video_seg
		mov	cx,0Fh

locloop_herc_reloc:
			add	word ptr es:[di],0B000h
			inc	di
			inc	di
			loop	locloop_herc_reloc		; Loop if cx > 0

		retn
		; Hercules segment relocation table [0BA0h] and save/load code body:
		; 7 × word entries: {0x0018, 0x1800, 0x1800, 0x1802, 0x1802, 0x1804, ...} (Herc segment addresses)
		; Then: cs: les di,[0F60h]; push di; push es; cs: mov [0F60h],0; mov ax,cs;
		;       add ax,3000h; mov es,ax; cs: mov [0F62h],es; call +0x78
		db	 00h, 18h, 00h, 18h, 00h, 18h
		db	 00h, 18h, 02h, 18h, 02h, 18h
		db	 04h, 18h, 2Eh,0C4h, 3Eh, 60h
		db	 0Fh, 57h, 06h, 2Eh,0C7h, 06h
		db	 60h, 0Fh, 00h, 00h, 8Ch,0C8h
		db	 05h, 00h, 30h, 8Eh,0C0h, 2Eh
		db	0A3h, 62h, 0Fh,0E8h, 78h, 00h
herc_seg_table		dw	0D88Bh			; Data table (indexed access)
		; Save/load file I/O continuation (accessed via dispatch):
		; mov cx,4; call +0x1B2; es: mov cx,[0]; cs: test byte [0xFF15h],0FFh; jne +0x10;
		; mov dx,cx; mov al,1; mov cx,0; mov ah,42h; int 21h;
		; es: mov cx,[2]; pop es; pop di; cs: mov [0F60h],di; cs: mov [0F62h],es;
		; call +0x186; jmp near +0x192; push ds; push bx; mov ax,cs; add ax,2000h;
		; mov ds,ax; push cs; pop es; mov si,9000h; mov di,3000h; mov cx,3800h
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

locloop_swap_data:
			lodsw				; String [si] to ax
			mov	dx,es:[di]
			stosw				; Store ax to es:[di]
			mov	[si-2],dx
			loop	locloop_swap_data		; Loop if cx > 0

		pop	bx
		pop	ds
		jmp	word ptr cs:[bx]	;*
			                        ; Called via cs:[bx] dispatch table: load game file

fio_load_entry:
		call	handle_pause_key6
		jnc	fio_load_ok			; Jump if carry=0
		retn

fio_load_ok:
		mov	bx,ax
		jmp	fio_close

fio_save_entry:
		call	handle_pause_key6
		jnc	fio_save_ok			; Jump if carry=0
		retn

fio_save_ok:
		mov	cx,cs:file_read_count
		mov	bx,ax
		call	handle_pause_key7
		jmp	fio_close

handle_pause_key6		proc	near

fio_open_loop:
		mov	cs:file_read_count,0FFFFh
		mov	cs:file_sector_ptr,0FFFFh
		lds	bx,dword ptr cs:savefile_desc_ptr	; Load seg:offset ptr
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
		jz	fio_no_dirname			; Jump if zero
		push	cs
		pop	ds
		mov	dx,0D3Bh

fio_no_dirname:
		mov	ax,3D00h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		jnc	fio_file_opened			; Jump if carry=0
		cmp	ax,2
		je	fio_file_notfound			; Jump if equal
		jmp	fio_error

fio_file_notfound:
		test	byte ptr cs:gvar_old_int09,0FFh
		jnz	fio_disk_declined			; Jump if not zero
		push	es
		call	handle_pause_key3
		push	cs
		pop	ds
		mov	si,0D47h
		mov	bx,6Ch
		mov	cl,4Ah			; 'J'
		call	word ptr cs:gfx_fn_clear
		call	handle_pause_key5
		push	dx
		mov	byte ptr cs:gvar_skip_flag,0

fio_disk_prompt:
			mov	dl,0FFh
			mov	ah,6
			int	21h			; DOS Services  ah=function 06h
							;  special char i/o, dl=subfunc
			jnz	fio_disk_accepted			; Jump if not zero
			test	byte ptr cs:gvar_skip_flag,0FFh
			jz	fio_disk_prompt			; Jump if zero

fio_disk_accepted:
		pop	dx
		call	handle_pause_key4
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
		jmp	fio_open_loop

fio_disk_declined:
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

fio_file_opened:
		mov	byte ptr cs:gvar_skip_flag,0
		test	byte ptr cs:[0D79h],0FFh
		jnz	fio_seek_slot			; Jump if not zero
		retn

fio_seek_slot:
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
		jnc	fio_read_ptr			; Jump if carry=0
		jmp	fio_error

fio_read_ptr:
		push	cs
		pop	ds
		mov	dx,0D7Ah
		mov	cx,4
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	fio_seek_data			; Jump if carry=0
		jmp	fio_error

fio_seek_data:
		mov	dx,word ptr ds:[0D7Ah]
		mov	cx,word ptr ds:[0D7Ch]
		mov	al,0
		mov	ah,42h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		push	cs
		pop	ds
		mov	dx,offset file_read_count
		mov	cx,4
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	fio_read_done			; Jump if carry=0
		jmp	fio_error

fio_read_done:
		pop	ax
		retn
		db	'zelres1.sar', 0
		db	'    Please', 0Dh, ' insert DISK1'
		db	0Dh, '      and', 0Dh, ' press an'
		db	'y key'
		db	0FFh			; String terminator (0xFF)
		db	00h, 00h, 00h, 00h, 00h	; Padding
		db	'dummy', 0		; Default save filename placeholder

;���� External Entry into Subroutine ��������������������������������������

handle_pause_key7:
		lds	dx,dword ptr cs:file_read_buf_ptr	; Load seg:offset ptr
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	loc_ret_108		; Jump if carry=0
		jmp	fio_error

loc_ret_108:
		retn

;���� External Entry into Subroutine ��������������������������������������

handle_pause_key8:

fio_close:
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jnc	loc_ret_110		; Jump if carry=0
		jmp	fio_error

loc_ret_110:
		retn

fio_decomp_entry:
		push	ds
		mov	ax,cs
		add	ax,3000h
		mov	ds,ax
		mov	si,zero_offset
		call	handle_pause_key9
		pop	ds
		retn

;���� External Entry into Subroutine ��������������������������������������

handle_pause_key9:
		xor	bx,bx			; Zero register
		lodsb				; String [si] to al
		dec	dx
		and	al,7
		mov	bl,al
		add	bx,bx
		jmp	word ptr cs:[0DBCh][bx]	;*
			                        ; Dispatch table entry [0DBCh]: opcode 0 = raw/verbatim copy

dcmp_opcode0:
		int	3			; Debug breakpoint
		or	ax,0DD1h
		adc	cx,ds:dialog_text_ofs
		jnc	dcmp_opcode0_body			; Jump if carry=0
		pushf				; Push flags
		push	cs
		mov	dx,0F50Eh
		push	cs
		mov	cx,dx
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		retn
		db	 8Bh,0EEh,0E8h		; mov bp,si; start of call near (dispatch stub bytes)

dcmp_opcode0_body:
		xor	al,[bx+si]

dcmp_copy_loop:
			lodsb				; String [si] to al
			call	poll_joystick_buttons0
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_copy_loop			; Jump if not zero
		retn

;���� External Entry into Subroutine ��������������������������������������

poll_joystick_buttons0:
		push	bp
		mov	ah,al
		and	ah,0F0h
		mov	cx,1

dcmp_tbl_search:
			test	byte ptr ds:[bp],0Fh
			jnz	dcmp_tbl_miss			; Jump if not zero
			cmp	ah,ds:[bp]
			je	dcmp_tbl_found			; Jump if equal
			inc	bp
			inc	bp
			jmp	short dcmp_tbl_search

dcmp_tbl_found:
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0Fh
		add	cx,2

dcmp_tbl_miss:
		pop	bp
		retn

dcmp_skip_loop:
			lodsb				; String [si] to al
			dec	dx
			cmp	al,0FFh
			jne	dcmp_skip_next			; Jump if not equal
			retn

dcmp_skip_next:
			inc	si
			dec	dx
			jmp	short dcmp_skip_loop
		db	0ACh, 4Ah, 8Ah,0E0h		; lodsb; dec dx; mov ah,al — load escape marker into AH (dispatch stub)

dcmp_rle3_loop:
			lodsb				; String [si] to al
			mov	cx,1
			mov	bl,al
			and	bl,0F0h
			cmp	bl,ah
			jne	dcmp_rle3_no_match			; Jump if not equal
			mov	cl,al
			and	cx,0Fh
			add	cx,3
			lodsb				; String [si] to al
			dec	dx

dcmp_rle3_no_match:
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle3_loop			; Jump if not zero
		retn
		db	 8Bh,0EEh,0E8h,0CFh,0FFh	; mov bp,si; call near -0x31 (dispatch entry stub for opcode 4)

dcmp_rle6_loop:
			lodsb				; String [si] to al
			call	poll_joystick_buttons1
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle6_loop			; Jump if not zero
		retn

;���� External Entry into Subroutine ��������������������������������������

poll_joystick_buttons1:
		push	bp
		mov	ah,al
		and	ah,0Fh
		mov	cx,1

dcmp_rle6_search:
			test	byte ptr ds:[bp],0F0h
			jnz	dcmp_rle6_miss			; Jump if not zero
			cmp	ah,ds:[bp]
			je	dcmp_rle6_found			; Jump if equal
			inc	bp
			inc	bp
			jmp	short dcmp_rle6_search

dcmp_rle6_found:
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0Fh
		add	cx,2

dcmp_rle6_miss:
		pop	bp
		retn
		db	0ACh, 4Ah, 8Ah,0E0h		; lodsb; dec dx; mov ah,al — load escape marker into AH (dispatch stub)

dcmp_rle4_loop:
			lodsb				; String [si] to al
			mov	cx,1
			mov	bl,al
			and	bl,0Fh
			cmp	bl,ah
			jne	dcmp_rle4_no_match			; Jump if not equal
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			mov	cl,al
			and	cx,0Fh
			add	cx,3
			lodsb				; String [si] to al
			dec	dx

dcmp_rle4_no_match:
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle4_loop			; Jump if not zero
		retn

dcmp_rle0_loop:
			lodsb				; String [si] to al
			mov	cx,1
			cmp	[si],al
			jne	dcmp_rle0_no_match			; Jump if not equal
			mov	cl,[si+1]
			and	cx,0FFh
			add	cx,2
			add	si,2
			sub	dx,2

dcmp_rle0_no_match:
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle0_loop			; Jump if not zero
		retn
		db	 8Bh,0EEh			; mov bp,si (dispatch entry stub prefix for opcode 6)

dcmp_skip16_loop:
			lodsw				; String [si] to ax
			sub	dx,2
			cmp	ax,0FFFFh
			jne	dcmp_skip16_loop			; Jump if not equal

dcmp_rle7_loop:
			lodsb				; String [si] to al
			call	poll_joystick_buttons2
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle7_loop			; Jump if not zero
		retn

;���� External Entry into Subroutine ��������������������������������������

poll_joystick_buttons2:
		push	bp
		mov	cx,1

dcmp_rle2_search:
			db	 3Eh, 83h, 7Eh, 00h,0FFh	; cmp word ptr ds:[bp+0],-1 (cmp [bp],0FFFFh; alt-encoding DS:+sign-extend: Fixup byte match)
			jz	dcmp_rle2_miss			; Jump if zero
			cmp	al,ds:[bp]
			je	dcmp_rle2_found			; Jump if equal
			inc	bp
			inc	bp
			jmp	short dcmp_rle2_search

dcmp_rle2_found:
		lodsb				; String [si] to al
		dec	dx
		mov	cl,al
		mov	al,ds:[bp+1]
		and	cx,0FFh
		add	cx,2

dcmp_rle2_miss:
		pop	bp
		retn
		db	0ACh, 4Ah, 8Ah,0E0h		; lodsb; dec dx; mov ah,al — load escape marker into AH (dispatch stub)

dcmp_rle1_loop:
			lodsb				; String [si] to al
			mov	cx,1
			cmp	al,ah
			jne	dcmp_rle1_no_match			; Jump if not equal
			lodsb				; String [si] to al
			mov	cl,al
			lodsb				; String [si] to al
			xchg	al,cl
			and	cx,0FFh
			add	cx,3
			sub	dx,2

dcmp_rle1_no_match:
			rep	stosb			; Rep when cx >0 Store al to es:[di]
			dec	dx
			jnz	dcmp_rle1_loop			; Jump if not zero
		retn
		db	0C3h			; retn (trailing byte from dcmp_rle1 entry stub)

game_state_handler:
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
		js	gsh_not_loader			; Jump if sign=1
		cmp	al,2
		je	gsh_loader_active			; Jump if equal

gsh_not_loader:
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

gsh_loader_active:
		mov	byte ptr cs:[2C4h],0

gsh_loader_wait:
			cmp	byte ptr cs:[2C4h],0F0h
			jb	gsh_loader_wait			; Jump if below
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

fio_error:
		lds	dx,dword ptr cs:savefile_desc_ptr	; Load seg:offset ptr
		jmp	dword ptr cs:gvar_chunk_load_fn

handle_pause_key6		endp

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

poll_joystick_buttons3		proc	near
		push	sp
		add	[bp+si],al
		and	cl,[di+50h]
		xor	ax,2E44h
		dec	bp
		inc	sp
		push	sp
		add	[bp+si],al
		and	cx,[di+50h]
		xor	ss:save_file_magic,ch
		push	sp
		add	[bp+si],al
		and	al,4Dh			; 'M'
		push	ax
		xor	ss:save_file_magic,bp
		push	sp
		add	[bp+si],al
		and	ax,504Dh
		xor	ch,ss:save_file_magic
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
savefile_desc_ptr		dw	504Dh, 4437h
file_read_buf_ptr		dw	4D2Eh, 5444h
file_read_count		dw	200h
file_sector_ptr		dw	4D2Ch
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

poll_joystick_buttons3		endp

seg_a		ends

		end	start
