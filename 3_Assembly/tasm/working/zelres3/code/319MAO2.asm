
PAGE  59,132

;==========================================================================
;
;  319MAO2 / _319MAPA6 - Final Boss Arena Map Program (zelres3 chunk)
;
;  Map-program code module for the final boss (Boss 6 / Mao-2) arena.
;  Loaded together with the arena data file map_boss6_arena.bin
;  (319MAPA6.bin). This is the LAST map-program in the game - the
;  climactic demon-lord (Jp. "Mao") encounter.
;
;  Contains the 'ashiin' byte sequence near end (Jashiin speaker-name
;  fragment, shared with 318MAO1). The file has 8 helper subroutines
;  wiring up the final-boss behaviour state machine.
;
;  Structure:
;    - Header / dispatch pointer area (file 0x00..0x84) - 0x84 holds
;      'dw offset mao2_main_dispatch' (the function entry point)
;    - Large embedded tile / cell layout data (~file 0x80..0x100)
;    - mao2_main_dispatch: main NPC scan + phase dispatch (was sub_1)
;    - Helpers: mao2_pick_target_idx, mao2_target_inc/dec,
;      mao2_dlg_a_init, mao2_dlg_b_init, mao2_unpack_bp_to_buf,
;      mao2_pos_sub, mao2_pos_step (boss scroll/animation logic)
;    - Trailer orphan blocks (Sourcer-decoded data) + 'ashiin'
;      speaker-name + zero padding
;
;==========================================================================

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

; The following equates show data references outside the range of the program.
; Shared references across 312-319 map-program family:
;   200Ch..6038h  - game-segment dispatch callback fn ptrs
;   0C002h/0C010h - sprite attribute / entity record base
;   0ED20h        - char/tile lookup table
;   0FF2Eh..0FF75h - per-map global state flag bytes

; --- Driver dispatch / callback fn ptrs (CS-relative ptrs in driver/game DS) ---
mao2_drv_scroll_cb	equ	200Ch			; scroll/dispatch callback
mao2_drv_anim_cb	equ	2F2Eh			; driver callback (boss anim)
mao2_drv_misc_cb	equ	302Fh			; driver callback
mao2_cb_tile_dispatch	equ	6028h			; game-seg callback fn A (tile dispatch)
mao2_cb_tile_at_pos	equ	6036h			; game-seg callback fn B (tile-at-pos)
mao2_cb_emit_attr	equ	6038h			; game-seg callback fn C (emit attribute)

; --- Internal phase / dispatch / handler tables (DS, hard offsets) ---
mao2_phase_ofs_tbl	equ	0A46Fh			; per-phase substate offset xlat table
mao2_handler_step_tbl	equ	0A666h			; phase-handler 3-byte step table base
mao2_orphan_data_a	equ	0A8A9h			; orphan label refd from sourcer trailer
mao2_dialog_di_tbl_a	equ	0A957h			; DI per-dialog phase table (alt set A)
mao2_orphan_data_b	equ	0A98Ah			; orphan label refd from sourcer trailer
mao2_orphan_data_c	equ	0A9DBh			; orphan label refd from sourcer trailer
mao2_dialog_bp_tbl_a	equ	0AA71h			; BP per-dialog phase table (alt set A)
mao2_phase_handler_tbl	equ	0ABF9h			; secondary phase handler ptr table

; --- State / scratch (DS) ---
mao2_npc_target_idx	equ	0AC03h			; NPC scan target index byte
mao2_speech_dx_lo	equ	0AC05h			; speech dx low byte (data_28e equiv)
mao2_pos_word		equ	0AC06h			; render position word (data_29e)
mao2_phase_substate	equ	0AC1Bh			; phase substate (xlat result)
mao2_npc_idx		equ	0AC1Ch			; NPC scan index byte
mao2_attr_byte		equ	0AC1Dh			; attribute byte (active sprite attr)
mao2_phase_dir		equ	0AC1Eh			; phase direction byte (BL-saved)
mao2_attr_tmp		equ	0AC1Fh			; attribute scratch byte (data_34e)
mao2_anim_step		equ	0AC20h			; phase-end animation step
mao2_anim_active	equ	0AC21h			; phase-end animation active flag
mao2_attr_high_nib	equ	0AC22h			; attribute high-nibble OR mask
mao2_phase_active	equ	0AC23h			; phase-active flag
mao2_rng_bit		equ	0AC24h			; RNG bit (rotated from callback)
mao2_phase_step	equ	0AC25h			; phase step counter
mao2_attr_ptr_save	equ	0AC26h			; saved attribute ptr (sprite_attr_ptr)
mao2_dlg_a_active	equ	0AC28h			; dialog-A active flag
mao2_dlg_a_dx		equ	0AC29h			; dialog-A current dx (column)
mao2_dlg_a_cl		equ	0AC2Ah			; dialog-A current cl (column-2)
mao2_dlg_a_dir		equ	0AC2Bh			; dialog-A direction byte
mao2_dlg_a_step	equ	0AC2Ch			; dialog-A step counter
mao2_dlg_b_active	equ	0AC2Dh			; dialog-B active flag
mao2_dlg_b_dx		equ	0AC2Eh			; dialog-B current dx
mao2_dlg_b_cl		equ	0AC2Fh			; dialog-B current cl
mao2_dlg_b_dir		equ	0AC30h			; dialog-B direction byte
mao2_dlg_b_step	equ	0AC31h			; dialog-B step counter
mao2_anim_finished	equ	0AC32h			; anim-phase finished flag
mao2_handler_step	equ	0AC33h			; phase-handler step counter
mao2_phase_b_active	equ	0AC34h			; phase-B active flag
mao2_phase_b_step	equ	0AC35h			; phase-B step counter
mao2_phase_c_active	equ	0AC36h			; phase-C active flag
mao2_phase_c_step	equ	0AC37h			; phase-C step counter
mao2_phase_c_idx	equ	0AC38h			; phase-C frame index counter
mao2_clear_buf		equ	0AC39h			; clear-buffer (54 bytes of FFh)
mao2_clear_buf_p1	equ	0AC41h			; clear-buf+8 patch-target byte
mao2_clear_buf_p2	equ	0AC4Ah			; clear-buf+11h patch-target byte
mao2_clear_buf_p3	equ	0AC65h			; clear-buf+2Ch patch-target byte
mao2_clear_buf_p4	equ	0AC6Eh			; clear-buf+35h patch-target byte
mao2_alt_state_byte	equ	0AEADh			; alternate state byte (orphan-refd)

; --- Shared game-segment globals ---
mao2_sprite_attr_max	equ	0C002h			; sprite attribute max-index byte
mao2_sprite_attr_ptr	equ	0C010h			; sprite attribute record base ptr
mao2_sprite_xlat_tbl	equ	0ED20h			; char/tile xlat table (shared)
mao2_gvar_state_a	equ	0FF21h			; global state byte A
mao2_gvar_state_b	equ	0FF2Eh			; global state byte B (skip-frame flag)
mao2_gvar_state_c	equ	0FF2Fh			; global state byte C
mao2_gvar_state_d	equ	0FF30h			; global state byte D
mao2_gvar_phase_byte	equ	0FF75h			; global state byte (per-map phase)

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a

		org	0

_319MAPA6	proc	far

; ------------------------------------------------------------------
; start: header + embedded tile/cell layout data.
; Real executable entry is reached via dispatch from game DS. The
; first 8 bytes are header fields / pointer descriptors; 12 zero
; bytes reserved; then a 33-byte 'P' (0x50) descriptor fill row.
; ------------------------------------------------------------------

start:
		db	 6Fh, 0Ch, 00h, 00h	; header words
mao2_hdr_byte_5		db	0F2h			; header field byte
		db	0A2h, 03h,0ACh		; header field bytes
		db	12 dup (0)		; reserved / padding
; 33-byte descriptor row: 0x50 ('P') fill (one tile row of the arena)
		db	'PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP'
		db	'|'			; row terminator
mao2_layout_extended		db	0A0h
mao2_layout_ptr_tbl_a	label	byte		; word ptrs into A0xx layout pages
		db	0CCh,0A0h, 1Ch,0A1h, 6Ch,0A1h	; layout-page word ptr
		db	 8Fh,0A1h,0A8h,0A1h	; layout-page word ptr
		db	52 dup (0)
mao2_layout_ptr_tbl_b	label	byte		; word ptrs into A1/A2xx layout pages
		db	0B7h,0A1h, 07h,0A2h, 57h,0A2h	; layout-page word ptr
		db	0A7h,0A2h,0CAh,0A2h,0E3h,0A2h	; layout-page word ptr
mao2_layout_count_a		db	1
		db	1, 2				; layout count pair
mao2_layout_count_b		db	3
mao2_layout_cells_a	label	byte		; per-row tile cell layout (5-byte rows w/01h sep)
		db	 04h, 01h, 05h, 06h, 08h, 09h	; tile cell run
		db	 01h, 00h, 07h, 0Ah, 0Bh, 01h	; tile cell run
		db	 0Ch, 0Dh, 0Fh, 10h, 01h, 0Eh	; tile cell run
		db	 0Fh, 11h, 12h, 01h, 12h, 13h	; tile cell run
		db	 15h, 16h, 01h, 00h, 14h, 18h	; tile cell run
		db	 19h, 01h, 16h, 17h, 18h, 1Bh	; tile cell run
		db	 01h, 0Ch, 0Dh, 1Ch, 1Dh, 01h	; tile cell run
		db	 1Eh, 1Fh, 20h, 21h, 01h, 20h	; tile cell run
		db	 21h, 18h, 22h, 01h, 21h, 00h	; tile cell run
		db	 22h, 23h, 01h, 05h, 06h,0F3h	; tile cell run
		db	0F4h, 01h,0F7h,0F8h, 25h, 26h	; tile cell run
		db	 01h, 27h, 28h, 2Ah, 2Bh, 01h	; tile cell run
		db	 2Bh, 2Ch, 18h, 2Eh, 01h,0F5h	; tile cell run
		db	0F6h, 00h, 24h, 01h, 11h, 27h	; tile cell run
		db	 29h, 2Ah, 01h, 00h, 29h, 18h	; tile cell run
		db	 2Dh, 01h,0F7h,0F8h, 30h, 31h	; tile cell run
		db	 01h, 33h, 34h, 35h, 36h, 01h	; tile cell run
		db	 35h, 36h, 37h, 38h, 01h, 00h	; tile cell run
		db	 00h,0F5h,0F6h, 01h, 2Fh, 30h	; tile cell run
		db	 32h, 33h, 01h, 0Ch, 70h, 72h	; tile cell run
		db	 73h, 01h, 75h, 76h, 78h, 79h	; tile cell run
		db	 01h, 71h, 72h, 74h, 75h, 01h	; tile cell run
		db	 74h, 75h, 18h, 78h, 01h, 76h	; tile cell run
		db	 00h, 79h, 7Ah, 01h, 0Ch, 0Dh	; tile cell run
		db	 0Fh, 10h, 01h, 12h, 13h		; row continues into dispatch_ptr below
mao2_layout_cells_a_tail	db	7Ch		; final row byte before dispatch ptr
mao2_dispatch_ptr		dw	offset mao2_main_dispatch
mao2_layout_cells_b	label	byte		; cell layout continued (post dispatch_ptr)
		db	 7Dh, 00h, 7Eh, 00h, 01h, 13h	; tile cell run
		db	 00h, 7Bh, 7Ch, 01h, 00h, 7Dh	; tile cell run
		db	 00h, 7Eh, 01h, 0Eh, 0Fh, 11h	; tile cell run
		db	 12h, 01h, 7Bh, 7Ch, 00h, 7Dh	; tile cell run
		db	 01h, 75h, 1Ah, 7Dh, 7Dh, 01h	; tile cell run
		db	 7Dh, 7Dh, 7Eh, 7Eh, 01h, 8Eh	; tile cell run
		db	 06h, 08h, 09h, 01h, 00h, 8Dh	; tile cell run
		db	 00h, 8Fh, 01h, 00h, 8Fh, 90h	; tile cell run
		db	 91h, 01h, 96h, 06h, 08h, 09h	; tile cell run
		db	 01h, 00h, 00h, 94h, 95h, 01h	; tile cell run
		db	 00h, 00h, 92h, 93h, 01h, 00h	; tile cell run
		db	 97h, 99h, 9Ah, 01h, 98h, 99h	; tile cell run
		db	 9Bh, 9Ch, 01h, 0Ch, 0Dh,0B1h	; tile cell run
		db	0B2h, 01h,0B1h,0B2h,0B4h,0B5h	; tile cell run
		db	 01h,0B2h, 00h,0B5h,0B6h, 01h	; tile cell run
		db	 00h, 07h,0ADh,0AEh, 01h	; tile cell run

_319MAPA6	endp

mao2_main_dispatch		proc	near
		scasw				; Scan es:[di] for ax
		mov	al,18h
		mov	bl,1
		add	ds:mao2_alt_state_byte[bx],cl
		add	[bx+si],ax
		add	mao2_layout_data_b[di],ch
		cwd				; Word to double word
;*		calls	far ptr sub_10		;*
		db	9Ah				; opcode 9Ah byte (call far prefix in sourcer view)
		dw	0AEB7h, 9801h		;  Fixup - byte match
		cwd				; Word to double word
mao2_layout_cells_c	label	byte		; cell layout continued (mid-block)
		db	 9Bh,0B7h, 01h,0C3h,0C4h,0C5h	; tile cell run
		db	0C6h, 01h,0CBh,0CCh,0CDh,0CEh	; tile cell run
		db	 01h,0CFh,0D0h,0D1h,0D2h, 01h	; tile cell run
		db	0D3h,0D4h,0D5h,0D6h, 01h,0D7h	; tile cell run
		db	0D8h,0D9h,0DAh, 00h,0DBh	; tile cell run
mao2_layout_data_b		db	0DCh			; Data table (indexed access)
mao2_layout_cells_d	label	byte		; cell layout continued (3Xh tile range)
		db	0DDh,0DEh, 00h,0DFh,0E0h,0E1h	; tile cell run
		db	0E2h, 00h,0E3h,0E4h,0E5h,0E6h	; tile cell run
		db	 01h, 39h, 3Ah, 3Bh, 3Ch, 01h	; tile cell run
		db	 3Dh, 3Eh, 3Fh, 40h, 01h, 41h	; tile cell run
		db	 00h, 44h, 45h, 01h, 42h, 43h	; tile cell run
		db	 46h, 47h, 01h, 49h, 4Ah, 4Dh	; tile cell run
		db	 4Eh, 01h, 4Ch, 4Dh, 50h, 51h	; tile cell run
		db	 01h, 47h, 48h, 4Ah, 4Bh, 01h	; tile cell run
		db	 4Fh, 00h, 52h, 51h, 01h, 42h	; tile cell run
		db	 43h, 53h, 54h, 01h, 55h, 56h	; tile cell run
		db	 57h, 58h, 01h, 57h, 58h, 5Ah	; tile cell run
		db	 51h, 01h, 00h, 57h, 59h, 5Ah	; tile cell run
		db	 01h, 3Dh, 3Eh,0F9h,0FAh, 01h	; tile cell run
		db	0FBh,0FCh, 5Bh, 5Ch, 01h, 5Eh	; tile cell run
		db	 5Fh, 61h, 62h, 01h, 60h, 61h	; tile cell run
		db	 64h, 51h, 01h,0FDh,0FEh, 5Dh	; tile cell run
		db	 00h, 01h, 5Fh, 4Bh, 62h, 63h	; tile cell run
		db	 01h, 63h, 00h, 65h, 51h, 01h	; tile cell run
		db	0FBh,0FCh, 66h, 67h, 01h, 69h	; tile cell run
		db	 6Ah, 6Ch, 6Dh, 01h, 6Ch, 6Dh	; tile cell run
		db	 6Eh, 6Fh, 01h, 00h, 00h,0FDh	; tile cell run
		db	0FEh, 01h, 67h, 68h, 6Ah, 6Bh	; tile cell run
		db	 01h, 7Fh, 43h, 80h, 81h, 01h	; tile cell run
		db	 83h, 84h, 87h, 88h, 01h, 81h	; tile cell run
		db	 82h, 84h, 85h, 01h, 84h, 85h	; tile cell run
		db	 88h, 51h, 01h, 00h, 83h, 86h	; tile cell run
		db	 87h, 01h, 42h, 43h, 46h, 47h	; tile cell run
		db	 01h, 49h, 4Ah, 8Ah, 89h, 01h	; tile cell run
		db	 00h, 8Bh, 00h, 8Ch, 01h, 47h	; tile cell run
		db	 48h, 4Ah, 4Bh, 01h, 89h, 8Ah	; tile cell run
		db	 8Bh, 00h, 01h, 00h, 49h, 89h	; tile cell run
		db	 8Ah, 01h, 8Bh, 00h, 8Ch, 00h	; tile cell run
		db	 01h, 77h, 84h, 8Bh, 8Bh, 01h	; tile cell run
		db	 8Bh, 8Bh, 8Ch, 8Ch, 01h, 3Dh	; tile cell run
mao2_layout_cells_e	label	byte		; cell layout continued (9Dh-Cxh tile range)
		db	 9Dh, 3Fh, 40h, 01h, 9Eh, 00h	; tile cell run
		db	 9Fh, 00h, 01h, 9Fh, 00h,0A0h	; tile cell run
		db	0A1h, 01h, 3Dh,0A2h, 3Fh, 40h	; tile cell run
		db	 01h, 00h, 00h,0A3h,0A4h, 01h	; tile cell run
		db	 00h, 00h,0A5h,0A6h, 01h,0A7h	; tile cell run
		db	 00h,0A8h,0A9h, 01h,0A9h,0AAh	; tile cell run
		db	0ABh,0ACh, 01h, 42h, 43h,0BAh	; tile cell run
		db	0BBh, 01h,0BAh,0BBh,0BFh,0C0h	; tile cell run
		db	 01h, 00h,0BAh,0BEh,0BFh, 01h	; tile cell run
		db	 41h, 00h,0B8h,0B9h, 01h,0BCh	; tile cell run
		db	0BDh,0C1h, 51h, 01h, 9Fh, 00h	; tile cell run
		db	0B8h,0B9h, 01h, 00h, 00h,0B8h	; tile cell run
		db	0B9h, 01h,0A8h,0A9h,0B8h,0C2h	; tile cell run
		db	 01h,0A9h,0AAh,0C2h,0ACh, 01h	; tile cell run
mao2_layout_cells_f	label	byte		; cell layout final (C7h-F2h tile range)
		db	0C7h,0C8h,0C9h,0CAh, 01h,0CBh	; tile cell run
		db	0CCh,0CDh,0CEh, 01h,0CFh,0D0h	; tile cell run
		db	0D1h,0D2h, 01h,0D3h,0D4h,0D5h	; tile cell run
		db	0D6h, 01h,0D7h,0D8h,0D9h,0DAh	; tile cell run
		db	 00h,0E7h,0E8h,0E9h,0EAh, 00h	; tile cell run
		db	0EBh,0ECh,0EDh,0EEh, 00h,0EFh	; tile cell run
		db	0F0h,0F1h,0F2h				; final cell row
mao2_npc_scan_init	label	byte		; mov si,word ptr ds:[10C0h] - NPC scan loop init
		db	 8Bh, 36h, 10h			; mov si,[10C0h] (loaded sprite_attr_ptr)
		db	0C0h,0C6h, 06h, 1Dh,0ACh, 00h	; mov byte ptr ds:[mao2_attr_byte],0
		db	0C6h, 06h, 1Ch,0ACh, 00h	; mov byte ptr ds:[mao2_npc_idx],0

mao2_npc_scan_loop:
;*		cmp	word ptr [si],0FFFFh
			db	 83h, 3Ch,0FFh		;  Fixup - byte match
			jz	mao2_npc_scan_done			; Jump if zero
			mov	ax,[si]
			call	word ptr cs:mao2_cb_tile_at_pos
			jc	mao2_npc_scan_next			; Jump if carry Set
			mov	[si+3],bl
			mov	ax,[si+2]
			call	word ptr cs:mao2_cb_tile_dispatch
			mov	bl,ds:mao2_npc_idx
			xor	bh,bh			; Zero register
			mov	al,ds:mao2_sprite_xlat_tbl[bx]
			mov	[di],al
			test	byte ptr ds:mao2_attr_byte,80h
			jnz	mao2_npc_scan_next			; Jump if not zero
			test	byte ptr [si+5],40h	; '@'
			jz	mao2_npc_scan_next			; Jump if zero
			mov	al,[si+5]
			and	al,1Fh
			test	byte ptr [si+4],1Fh
			jnz	mao2_npc_attr_set			; Jump if not zero
			test	byte ptr [si+6],0Fh
			jnz	mao2_npc_attr_set			; Jump if not zero
			or	al,80h

mao2_npc_attr_set:
			mov	ds:mao2_attr_byte,al

mao2_npc_scan_next:
			inc	byte ptr ds:mao2_npc_idx
			add	si,10h
			jmp	short mao2_npc_scan_loop

mao2_npc_scan_done:
		mov	si,ds:mao2_sprite_attr_ptr
		mov	word ptr [si],0FFFFh
		mov	ds:mao2_attr_ptr_save,si
		mov	byte ptr ds:mao2_npc_idx,0
		test	byte ptr ds:mao2_attr_byte,0FFh
		jz	mao2_check_skip_frame			; Jump if zero
		mov	al,ds:mao2_attr_byte
		and	al,1Fh
		push	ax
		call	word ptr cs:mao2_cb_emit_attr
		mov	bl,ah
		pop	ax
		xor	bh,bh			; Zero register
		shr	bx,1			; Shift w/zeros fill
		cmp	al,1
		je	mao2_attr_shift_done			; Jump if equal
		shr	bx,1			; Shift w/zeros fill

mao2_attr_shift_done:
		call	mao2_pos_sub
		mov	byte ptr ds:mao2_gvar_phase_byte,39h	; '9'
		cmp	word ptr ds:mao2_pos_word,0C8h
		jae	mao2_check_skip_frame			; Jump if above or =
		mov	byte ptr ds:mao2_anim_finished,0FFh

mao2_check_skip_frame:
		test	byte ptr ds:mao2_gvar_state_b,0FFh
		jz	mao2_check_anim_active			; Jump if zero
		jmp	mao2_skip_anim_top

mao2_check_anim_active:
		test	byte ptr ds:mao2_anim_active,0FFh
		jnz	mao2_check_anim_finished			; Jump if not zero
		test	byte ptr ds:mao2_gvar_state_a,0FFh
		jnz	mao2_set_anim_active			; Jump if not zero
		retn

mao2_set_anim_active:
		mov	byte ptr ds:mao2_anim_active,0FFh
		retn

mao2_check_anim_finished:
		test	byte ptr ds:mao2_anim_finished,0FFh
		jz	mao2_check_phase_active			; Jump if zero
		jmp	mao2_anim_phase_top

mao2_check_phase_active:
		test	byte ptr ds:mao2_phase_active,0FFh
		jnz	mao2_phase_step_advance			; Jump if not zero
		test	byte ptr ds:mao2_dlg_a_active,0FFh
		jz	mao2_check_dlg_a			; Jump if zero
		jmp	mao2_dlg_a_check

mao2_check_dlg_a:
		test	byte ptr ds:mao2_dlg_b_active,0FFh
		jz	mao2_phase_init			; Jump if zero
		jmp	mao2_dlg_a_check

mao2_phase_init:
		call	mao2_pick_target_idx
		mov	byte ptr ds:mao2_phase_step,0
		mov	byte ptr ds:mao2_phase_active,0FFh
		call	word ptr cs:mao2_dispatch_ptr
		rol	al,1			; Rotate
		and	al,1
		mov	ds:mao2_rng_bit,al

mao2_phase_step_advance:
		inc	byte ptr ds:mao2_phase_step
		mov	al,ds:mao2_phase_step
		cmp	al,6
		jae	mao2_phase_step_mid			; Jump if above or =
		shr	al,1			; Shift w/zeros fill
		jnc	mao2_phase_substate_seed			; Jump if carry=0
		jmp	mao2_dlg_a_check

mao2_phase_substate_seed:
		mov	byte ptr ds:mao2_gvar_phase_byte,3Bh	; ';'
		mov	byte ptr ds:mao2_attr_high_nib,60h	; '`'
		mov	al,ds:mao2_rng_bit
		mov	cl,0Ah
		mul	cl			; ax = reg * al
		mov	ds:mao2_phase_substate,al
		jmp	mao2_render_emit_top

mao2_phase_step_mid:
		cmp	al,0Bh
		jae	mao2_phase_step_high			; Jump if above or =
		sub	al,6
		mov	bl,al
		xor	bh,bh			; Zero register
		mov	al,ds:mao2_rng_bit
		mov	ah,al
		add	al,al
		add	al,al
		add	al,ah
		add	bx,mao2_phase_ofs_tbl
		xlat				; al=[al+[bx]] table
		mov	ds:mao2_phase_substate,al
		mov	byte ptr ds:mao2_attr_high_nib,0
		cmp	al,9
		jne	mao2_phase_check_C			; Jump if not equal
		call	mao2_dlg_a_init

mao2_phase_check_C:
		cmp	al,0Ch
		jne	mao2_phase_jmp_dlg			; Jump if not equal
		call	mao2_dlg_b_init

mao2_phase_jmp_dlg:
		jmp	mao2_render_emit_top

mao2_phase_step_high:
		cmp	al,11h
		jae	mao2_phase_step_finish			; Jump if above or =
		shr	al,1			; Shift w/zeros fill
		jnc	mao2_phase_step_high2			; Jump if carry=0
		jmp	mao2_dlg_a_check

mao2_phase_step_high2:
		mov	byte ptr ds:mao2_gvar_phase_byte,3Bh	; ';'
		mov	byte ptr ds:mao2_attr_high_nib,60h	; '`'
		jmp	mao2_render_emit_top

mao2_phase_step_finish:
		mov	byte ptr ds:mao2_phase_active,0
		jmp	mao2_dlg_a_check
mao2_phase_ofs_data	label	byte		; phase substate offset xlat data (xlat tbl base)
		db	 00h, 00h, 07h, 07h, 09h, 0Ah	; phase substate xlat entry
		db	 0Ah, 0Bh, 0Bh	; phase substate xlat entry
mao2_phase_ofs_data_end	db	0Ch		; xlat table terminator/last entry

mao2_pick_target_idx:
		mov	byte ptr ds:mao2_speech_dx_lo,9
		call	word ptr cs:mao2_dispatch_ptr
		shr	al,1			; Shift w/zeros fill
		sbb	al,al
		mov	ds:mao2_phase_dir,al
		not	al
		and	al,14h
		add	al,mao2_layout_count_a
		add	al,4
		cmp	al,ds:mao2_sprite_attr_max
		jb	mao2_target_idx_set_a			; Jump if below
		sub	al,ds:mao2_sprite_attr_max

mao2_target_idx_set_a:
		mov	ds:mao2_npc_target_idx,al
		cmp	al,10h
		jb	mao2_target_idx_retry			; Jump if below
		cmp	al,35h			; '5'
		jae	mao2_target_idx_retry			; Jump if above or =
		retn

mao2_target_idx_retry:
		not	byte ptr ds:mao2_phase_dir
		mov	al,ds:mao2_phase_dir
		not	al
		and	al,14h
		add	al,mao2_layout_count_a
		add	al,4
		cmp	al,ds:mao2_sprite_attr_max
		jb	mao2_target_idx_set_b			; Jump if below
		sub	al,ds:mao2_sprite_attr_max

mao2_target_idx_set_b:
		mov	ds:mao2_npc_target_idx,al
		retn

mao2_anim_phase_top:
		inc	byte ptr ds:mao2_phase_c_idx
		test	byte ptr ds:mao2_phase_c_idx,1Fh
		jnz	mao2_check_handler_step			; Jump if not zero
		call	mao2_pos_step

mao2_check_handler_step:
		test	byte ptr ds:mao2_handler_step,0FFh
		jz	mao2_check_phase_c			; Jump if zero
		jmp	mao2_handler_step_top

mao2_check_phase_c:
		test	byte ptr ds:mao2_phase_c_active,0FFh
		jz	mao2_check_dlg_a_b			; Jump if zero
		jmp	mao2_phase_c_advance

mao2_check_dlg_a_b:
		test	byte ptr ds:mao2_dlg_a_active,0FFh
		jz	mao2_handler_calc_target			; Jump if zero
		jmp	mao2_render_emit_top

mao2_handler_calc_target:
		mov	al,mao2_layout_count_a
		add	al,mao2_layout_count_b
		add	al,3
		cmp	al,ds:mao2_sprite_attr_max
		jb	mao2_handler_set_dir			; Jump if below
		sub	al,ds:mao2_sprite_attr_max

mao2_handler_set_dir:
		xor	cl,cl			; Zero register
		cmp	ds:mao2_npc_target_idx,al
		jae	mao2_handler_dir_set			; Jump if above or =
		mov	cl,0FFh

mao2_handler_dir_set:
		mov	ds:mao2_phase_dir,cl
		or	cl,cl			; Zero ?
		jnz	mao2_handler_branch_c			; Jump if not zero
		mov	ah,ds:mao2_npc_target_idx
		sub	ah,al
		and	ah,0FEh
		cmp	ah,8
		jne	mao2_handler_branch_a			; Jump if not equal
		jmp	mao2_phase_b_check

mao2_handler_branch_a:
		jnc	mao2_handler_branch_b			; Jump if carry=0
		dec	byte ptr ds:mao2_phase_substate
		and	byte ptr ds:mao2_phase_substate,3
		test	byte ptr ds:mao2_phase_substate,1
		jnz	mao2_handler_call_inc_a			; Jump if not zero
		call	mao2_target_inc

mao2_handler_call_inc_a:
		call	mao2_target_inc
		jc	mao2_handler_inc_done			; Jump if carry Set
		jmp	mao2_phase_after_handler

mao2_handler_inc_done:
		mov	byte ptr ds:mao2_phase_b_active,0
		mov	byte ptr ds:mao2_handler_step,0FFh
		jmp	short mao2_phase_b_check

mao2_handler_branch_b:
		inc	byte ptr ds:mao2_phase_substate
		and	byte ptr ds:mao2_phase_substate,3
		test	byte ptr ds:mao2_phase_substate,1
		jz	mao2_handler_call_dec_a			; Jump if zero
		call	mao2_target_dec

mao2_handler_call_dec_a:
		call	mao2_target_dec
		jc	mao2_handler_dec_done			; Jump if carry Set
		jmp	mao2_phase_after_handler

mao2_handler_dec_done:
		mov	byte ptr ds:mao2_phase_b_active,0
		mov	byte ptr ds:mao2_handler_step,0FFh
		jmp	short mao2_phase_b_check

mao2_handler_branch_c:
		sub	al,ds:mao2_npc_target_idx
		and	al,0FEh
		cmp	al,8
		je	mao2_phase_b_check			; Jump if equal
		jnc	mao2_handler_branch_d			; Jump if carry=0
		dec	byte ptr ds:mao2_phase_substate
		and	byte ptr ds:mao2_phase_substate,3
		test	byte ptr ds:mao2_phase_substate,1
		jnz	mao2_handler_call_dec_b			; Jump if not zero
		call	mao2_target_dec

mao2_handler_call_dec_b:
		call	mao2_target_dec
		jnc	mao2_phase_after_handler			; Jump if carry=0
		mov	byte ptr ds:mao2_phase_b_active,0
		mov	byte ptr ds:mao2_handler_step,0FFh
		jmp	short mao2_phase_b_check

mao2_handler_branch_d:
		inc	byte ptr ds:mao2_phase_substate
		and	byte ptr ds:mao2_phase_substate,3
		test	byte ptr ds:mao2_phase_substate,1
		jz	mao2_handler_call_inc_b			; Jump if zero
		call	mao2_target_inc

mao2_handler_call_inc_b:
		call	mao2_target_inc
		jnc	mao2_phase_after_handler			; Jump if carry=0
		mov	byte ptr ds:mao2_phase_b_active,0
		mov	byte ptr ds:mao2_handler_step,0FFh

mao2_phase_b_check:
		mov	al,ds:mao2_phase_b_step
		mov	byte ptr ds:mao2_phase_b_step,0FFh
		or	al,al			; Zero ?
		jnz	mao2_phase_b_advance			; Jump if not zero
		jmp	mao2_render_emit_top

mao2_phase_b_advance:
		and	byte ptr ds:mao2_phase_substate,0FEh
		call	word ptr cs:mao2_dispatch_ptr
		and	al,0Fh
		jnz	mao2_phase_after_handler			; Jump if not zero
		mov	byte ptr ds:mao2_phase_c_step,0
		mov	byte ptr ds:mao2_phase_c_active,0FFh

mao2_phase_after_handler:
		jmp	mao2_render_emit_top

mao2_phase_c_advance:
		mov	al,ds:mao2_phase_c_step
		inc	byte ptr ds:mao2_phase_c_step
		mov	bx,mao2_phase_ofs_tbl
		xlat				; al=[al+[bx]] table
		mov	ds:mao2_phase_substate,al
		cmp	al,9
		je	mao2_phase_c_done			; Jump if equal
		jmp	mao2_render_emit_top

mao2_phase_c_done:
		mov	byte ptr ds:mao2_phase_c_active,0
		call	mao2_dlg_a_init
		jmp	mao2_render_emit_top

mao2_handler_step_top:
		mov	bl,ds:mao2_phase_b_active
		add	bl,bl
		add	bl,ds:mao2_phase_b_active
		xor	bh,bh			; Zero register
		add	bx,mao2_handler_step_tbl
		mov	al,[bx]
		push	bx
		or	al,al			; Zero ?
		jz	mao2_handler_step_done			; Jump if zero
		test	byte ptr ds:mao2_phase_dir,0FFh
		jnz	mao2_handler_step_inc			; Jump if not zero
		call	mao2_target_dec
		call	mao2_target_dec
		jmp	short mao2_handler_step_done

mao2_handler_step_inc:
		call	mao2_target_inc
		call	mao2_target_inc

mao2_handler_step_done:
		pop	bx
		mov	al,ds:mao2_speech_dx_lo
		add	al,[bx+1]
		and	al,3Fh			; '?'
		mov	ds:mao2_speech_dx_lo,al
		mov	al,[bx+2]
		mov	ds:mao2_phase_substate,al
		inc	byte ptr ds:mao2_phase_b_active
		cmp	byte ptr [bx+3],80h
		jne	mao2_render_emit_top			; Jump if not equal
		mov	byte ptr ds:mao2_handler_step,0
		jmp	short mao2_render_emit_top
mao2_handler_step_data	label	byte	; phase-handler 3-byte step table (step,dx_delta,substate)
		db	 00h, 00h, 04h, 00h, 00h, 04h	; handler step (step,dx,sub)
		db	 00h,0FEh, 05h, 01h,0FEh, 05h	; handler step (step,dx,sub)
		db	 01h,0FEh, 05h, 01h, 00h, 06h	; handler step (step,dx,sub)
		db	 01h, 00h, 06h, 01h, 00h, 06h	; handler step (step,dx,sub)
		db	 01h, 02h, 06h, 01h, 02h, 06h	; handler step (step,dx,sub)
		db	 01h, 02h, 06h, 00h, 00h, 04h	; handler step (step,dx,sub)
		db	 00h, 00h, 04h, 00h, 00h, 00h	; handler step (step,dx,sub)
mao2_handler_step_data_end	db	80h	; step-table terminator (cmp [bx+3],80h)

mao2_target_dec:
		mov	ax,ds:mao2_npc_target_idx
		dec	ax
		mov	bx,0Eh
		sub	bx,ax
		cmc				; Complement carry
		jnc	mao2_target_dec_set			; Jump if carry=0
		retn

mao2_target_dec_set:
		mov	ds:mao2_npc_target_idx,ax
		mov	byte ptr ds:mao2_phase_b_step,0
		retn

mao2_target_inc:
		mov	ax,ds:mao2_npc_target_idx
		inc	ax
		mov	bx,offset mao2_layout_extended
		sub	bx,ax
		jnc	mao2_target_inc_set			; Jump if carry=0
		retn

mao2_target_inc_set:
		mov	ds:mao2_npc_target_idx,ax
		mov	byte ptr ds:mao2_phase_b_step,0
		retn

mao2_render_emit_top:
		push	cs
		pop	es
		mov	di,mao2_clear_buf
		mov	al,0FFh
		mov	cx,36h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	di,0A9E4h
		mov	si,0AAE1h
		test	byte ptr ds:mao2_phase_dir,0FFh
		jnz	mao2_render_resolve_tbl			; Jump if not zero
		mov	di,mao2_dialog_di_tbl_a
		mov	si,mao2_dialog_bp_tbl_a

mao2_render_resolve_tbl:
		mov	bl,ds:mao2_phase_substate
		xor	bh,bh			; Zero register
		add	bx,bx
		mov	di,[bx+di]
		mov	bp,[bx+si]
		call	mao2_unpack_bp_to_buf
		cmp	byte ptr ds:mao2_phase_substate,5
		jne	mao2_render_attr_loop_init			; Jump if not equal
		test	byte ptr ds:mao2_phase_dir,0FFh
		jz	mao2_render_set_alt_p			; Jump if zero
		mov	byte ptr ds:mao2_clear_buf_p1,23h	; '#'
		mov	byte ptr ds:mao2_clear_buf_p2,1Fh
		jmp	short mao2_render_attr_loop_init

mao2_render_set_alt_p:
		mov	byte ptr ds:mao2_clear_buf_p3,1Fh
		mov	byte ptr ds:mao2_clear_buf_p4,21h	; '!'

mao2_render_attr_loop_init:
		mov	ax,ds:mao2_npc_target_idx
		mov	si,ds:mao2_attr_ptr_save
		mov	di,mao2_clear_buf
		mov	cx,6

mao2_render_attr_loop:
		push	cx
		push	di
		push	ax
		call	word ptr cs:mao2_cb_tile_at_pos
		pop	ax
		mov	ds:mao2_attr_tmp,bl
		jc	mao2_render_outer_advance			; Jump if carry Set
		xor	cl,cl			; Zero register

mao2_render_emit_inner:
			push	cx
			push	ax
			cmp	byte ptr [di],0FFh
			je	mao2_render_inner_advance			; Jump if equal
			mov	[si],ax
			add	cl,ds:mao2_speech_dx_lo
			and	cl,3Fh			; '?'
			mov	[si+2],cl
			mov	al,ds:mao2_attr_tmp
			mov	[si+3],al
			mov	al,[di]
			mov	ah,al
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			shr	al,1			; Shift w/zeros fill
			or	al,ds:mao2_attr_high_nib
			mov	[si+4],al
			mov	[si+6],ah
			mov	al,ds:mao2_phase_dir
			and	al,80h
			mov	[si+5],al
			test	byte ptr ds:mao2_attr_byte,0FFh
			jz	mao2_render_attr_apply			; Jump if zero
			or	byte ptr [si+5],20h	; ' '

mao2_render_attr_apply:
			push	di
			mov	ax,[si+2]
			call	word ptr cs:mao2_cb_tile_dispatch
			mov	bl,ds:mao2_npc_idx
			xor	bh,bh			; Zero register
			mov	al,bl
			or	al,80h
			xchg	[di],al
			mov	ds:mao2_sprite_xlat_tbl[bx],al
			pop	di
			add	si,10h
			inc	byte ptr ds:mao2_npc_idx

mao2_render_inner_advance:
			inc	di
			pop	ax
			pop	cx
			inc	cl
			cmp	cl,9
			jne	mao2_render_emit_inner			; Jump if not equal

mao2_render_outer_advance:
		inc	ax
		pop	di
		add	di,9
		pop	cx
		loop	mao2_render_outer_loop		; Loop if cx > 0

		jmp	short mao2_render_terminate

mao2_render_outer_loop:
		jmp	mao2_render_attr_loop

mao2_render_terminate:
		mov	ds:mao2_attr_ptr_save,si
		mov	word ptr [si],0FFFFh

mao2_dlg_a_check:
		test	byte ptr ds:mao2_dlg_a_active,0FFh
		jnz	mao2_dlg_a_run			; Jump if not zero
		jmp	mao2_dlg_b_check

mao2_dlg_a_run:
		mov	si,ds:mao2_attr_ptr_save
		cmp	byte ptr ds:mao2_dlg_a_step,9
		jae	mao2_dlg_a_emit			; Jump if above or =
		cmp	byte ptr ds:mao2_dlg_a_step,3
		jae	mao2_dlg_a_dx_inc			; Jump if above or =
		inc	byte ptr ds:mao2_dlg_a_cl
		and	byte ptr ds:mao2_dlg_a_cl,3Fh	; '?'

mao2_dlg_a_dx_inc:
		mov	al,ds:mao2_dlg_a_dx
		inc	al
		test	byte ptr ds:mao2_dlg_a_dir,0FFh
		jnz	mao2_dlg_a_dx_set			; Jump if not zero
		dec	al
		dec	al

mao2_dlg_a_dx_set:
		mov	ds:mao2_dlg_a_dx,al

mao2_dlg_a_emit:
		mov	al,ds:mao2_dlg_a_dx
		xor	ah,ah			; Zero register
		push	ax
		call	word ptr cs:mao2_cb_tile_at_pos
		pop	ax
		jc	mao2_dlg_a_advance			; Jump if carry Set
		mov	[si],ax
		mov	al,ds:mao2_dlg_a_cl
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],24h	; '$'
		xor	al,al			; Zero register
		mov	ah,ds:mao2_dlg_a_step
		cmp	ah,3
		jb	mao2_dlg_a_set_pos			; Jump if below
		and	ah,3
		inc	ah
		mov	al,ah

mao2_dlg_a_set_pos:
		mov	[si+6],al
		mov	al,ds:mao2_dlg_a_dir
		and	al,80h
		mov	[si+5],al
		mov	ax,[si+2]
		call	word ptr cs:mao2_cb_tile_dispatch
		mov	bl,ds:mao2_npc_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:mao2_sprite_xlat_tbl[bx],al
		add	si,10h
		inc	byte ptr ds:mao2_npc_idx

mao2_dlg_a_advance:
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:mao2_dlg_a_step
		cmp	byte ptr ds:mao2_dlg_a_step,0Bh
		jb	mao2_dlg_b_check			; Jump if below
		mov	byte ptr ds:mao2_dlg_a_active,0

mao2_dlg_b_check:
		test	byte ptr ds:mao2_dlg_b_active,0FFh
		jnz	mao2_dlg_b_run			; Jump if not zero
		retn

mao2_dlg_b_run:
		xor	dl,dl			; Zero register
		cmp	byte ptr ds:mao2_dlg_b_step,3
		jae	mao2_dlg_b_dx_inc			; Jump if above or =
		inc	byte ptr ds:mao2_dlg_b_cl
		and	byte ptr ds:mao2_dlg_b_cl,3Fh	; '?'
		mov	dl,2

mao2_dlg_b_dx_inc:
		mov	al,ds:mao2_dlg_b_dx
		inc	al
		test	byte ptr ds:mao2_dlg_b_dir,0FFh
		jnz	mao2_dlg_b_dx_set			; Jump if not zero
		dec	al
		dec	al

mao2_dlg_b_dx_set:
		mov	ds:mao2_dlg_b_dx,al
		xor	ah,ah			; Zero register
		push	dx
		push	ax
		call	word ptr cs:mao2_cb_tile_at_pos
		pop	ax
		pop	dx
		jc	mao2_dlg_b_advance			; Jump if carry Set
		mov	[si],ax
		mov	al,ds:mao2_dlg_b_cl
		mov	[si+2],al
		mov	[si+3],bl
		mov	byte ptr [si+4],25h	; '%'
		mov	[si+6],dl
		mov	al,ds:mao2_dlg_b_dir
		and	al,80h
		mov	[si+5],al
		mov	ax,[si+2]
		call	word ptr cs:mao2_cb_tile_dispatch
		mov	bl,ds:mao2_npc_idx
		xor	bh,bh			; Zero register
		mov	al,bl
		or	al,80h
		xchg	[di],al
		mov	ds:mao2_sprite_xlat_tbl[bx],al
		add	si,10h
		inc	byte ptr ds:mao2_npc_idx

mao2_dlg_b_advance:
		mov	word ptr [si],0FFFFh
		inc	byte ptr ds:mao2_dlg_b_step
		cmp	byte ptr ds:mao2_dlg_b_dx,10h
		jb	mao2_dlg_b_finish			; Jump if below
		cmp	byte ptr ds:mao2_dlg_b_dx,39h	; '9'
		jae	mao2_dlg_b_finish			; Jump if above or =
		retn

mao2_dlg_b_finish:
		mov	byte ptr ds:mao2_dlg_b_active,0
		retn

mao2_main_dispatch		endp

mao2_dlg_a_init		proc	near
		mov	byte ptr ds:mao2_dlg_a_step,0
		mov	byte ptr ds:mao2_dlg_a_active,0FFh
		mov	al,ds:mao2_phase_dir
		mov	ds:mao2_dlg_a_dir,al
		and	al,5
		add	al,ds:mao2_npc_target_idx
		mov	ds:mao2_dlg_a_dx,al
		mov	al,ds:mao2_speech_dx_lo
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:mao2_dlg_a_cl,al
		mov	byte ptr ds:mao2_gvar_phase_byte,3Ah	; ':'
		retn

mao2_dlg_a_init		endp

mao2_dlg_b_init		proc	near
		mov	byte ptr ds:mao2_dlg_b_step,0
		mov	byte ptr ds:mao2_dlg_b_active,0FFh
		mov	al,ds:mao2_phase_dir
		mov	ds:mao2_dlg_b_dir,al
		and	al,8
		add	al,ds:mao2_npc_target_idx
		dec	al
		mov	ds:mao2_dlg_b_dx,al
		mov	al,ds:mao2_speech_dx_lo
		add	al,4
		and	al,3Fh			; '?'
		mov	ds:mao2_dlg_b_cl,al
		mov	byte ptr ds:mao2_gvar_phase_byte,3Ah	; ':'
		retn

mao2_dlg_b_init		endp

mao2_unpack_bp_to_buf		proc	near
		mov	si,mao2_clear_buf
		mov	cx,6

mao2_unpack_outer_loop:
			push	cx
			mov	cx,8

mao2_unpack_inner_loop:
				rol	byte ptr ds:[bp],1	; Rotate
				jnc	mao2_unpack_skip			; Jump if carry=0
				mov	al,[di]
				mov	[si],al
				inc	di

mao2_unpack_skip:
				inc	si
				loop	mao2_unpack_inner_loop		; Loop if cx > 0

			inc	bp
			inc	si
			pop	cx
			loop	mao2_unpack_outer_loop		; Loop if cx > 0

		retn

mao2_unpack_bp_to_buf		endp

; ------------------------------------------------------------------
; mao2_orphan_block_a: Sourcer-decoded mnemonics that sum to data
; bytes (handler-step / dialog table data referenced via DS at hard
; offsets 0xA8A9..0xABF9).  No-entry-point: the bytes are read as
; data via mao2_orphan_data_a/b/c + handler tables, never executed
; as instructions. Preserved verbatim since they assemble to the
; same byte stream as raw db hex would.
; ------------------------------------------------------------------

mao2_orphan_block_a	label	byte
;*		jnc	(unreached)		;*Jump if carry=0
		db	 73h,0A9h		;  Fixup - byte match
;*		jnp	(unreached)		;*Jump if not parity
		db	 7Bh,0A9h		;  Fixup - byte match
;*		sub	byte ptr ds:mao2_orphan_data_b[bx+di],91h
		db	 82h,0A9h, 8Ah,0A9h, 91h	;  Fixup - byte match
		test	ax,0A999h
		mov	ax,ds:mao2_orphan_data_a
		test	ax,0A9B1h
		mov	dx,0C3A9h
		test	ax,0A9CAh
		shr	byte ptr ds:mao2_orphan_data_c[bx+di],cl	; Shift w/zeros fill
		add	al,mao2_hdr_byte_5
		add	[bp+di],ax
		add	ax,207h
		add	[bx+di],al
		or	[bx+di],cl
		or	cl,[bp+di]
		adc	[bp+si],dl
		adc	[bx+si],ax
		or	al,0Dh
		push	cs
;*		pop	cs			; Dangerous-8088 only
		db	0Fh			;  Fixup - byte match
		push	ss
		pop	ss
		add	[si],cl
		adc	dx,[si]
		adc	ax,1A02h
		sbb	ax,[bx+si]
		add	[bx+si],bx
		sbb	[si],bx
		add	ah,[bp+si]
		and	ax,[bx+si]
		add	[di],bx
		push	ds
		and	[bp+si],al
		sbb	al,[bx+si]
		add	[bx+si],bx
		and	al,25h			; '%'
		daa				; Decimal adjust
		sub	mao2_hdr_byte_5,al
		add	ax,es:[di]
		pop	es
		sub	bp,[bp+si]
		push	es
		add	al,0
		sub	[bp+di],ax
		add	ax,2D07h
		sub	al,6
		add	al,0
		sub	[bp+di],ax
		add	ax,3107h
		xor	al,[bx+si]
		add	ds:mao2_drv_misc_cb,bp
		daa				; Decimal adjust
		xor	si,[bp+si]
		add	ds:mao2_drv_anim_cb,ah
		xor	[bp+di],ch
		sub	dh,[si]
		xor	al,[bx+si]
		sub	ds:mao2_drv_misc_cb,bp
mao2_orphan_trailer_a	label	byte		; orphan: dialog opcode/index byte stream
		db	 36h, 2Ch, 35h, 32h, 00h, 29h	; orphan: dialog opcode/index byte
		db	 2Eh, 2Fh, 30h, 00h	; orphan: dialog opcode/index byte
mao2_orphan_a_ptr_tbl	label	byte		; 0AAxxh word ptr table (12 entries into trailer)
		db	0AAh, 08h	; 0AAxxh word ptr entry
		db	0AAh, 0Fh,0AAh, 17h,0AAh, 1Eh	; 0AAxxh word ptr entry
		db	0AAh, 26h,0AAh, 2Eh,0AAh, 35h	; 0AAxxh word ptr entry
		db	0AAh, 3Eh,0AAh, 47h,0AAh, 50h	; 0AAxxh word ptr entry
		db	0AAh, 57h,0AAh, 5Fh,0AAh, 68h	; 0AAxxh word ptr entry
		db	0AAh	; 0AAxxh word ptr entry
mao2_orphan_a_xlat_tbl	label	byte		; xlat/dispatch byte table (small dialog-state ints)
		db	 05h, 00h, 01h, 03h, 04h	; xlat/dispatch byte
		db	 06h, 02h, 07h, 0Bh, 00h, 01h	; xlat/dispatch byte
		db	 08h, 09h, 0Ah, 02h, 0Fh, 00h	; xlat/dispatch byte
		db	 0Ch, 0Dh, 0Eh, 11h, 10h, 12h	; xlat/dispatch byte
		db	 00h, 0Ch, 13h, 14h, 15h, 17h	; xlat/dispatch byte
		db	 16h, 1Ch, 00h, 01h, 18h, 19h	; xlat/dispatch byte
		db	 1Ah, 1Bh, 02h, 22h, 00h, 01h	; xlat/dispatch byte
		db	 1Dh, 1Eh, 20h, 21h, 02h, 00h	; xlat/dispatch byte
		db	 01h, 18h, 24h, 25h, 1Ah, 02h	; xlat/dispatch byte
		db	 05h, 00h, 26h, 03h, 04h, 06h	; xlat/dispatch byte
		db	 27h, 28h, 07h, 05h, 00h, 29h	; xlat/dispatch byte
		db	 03h, 04h, 06h, 2Ah, 07h, 2Bh	; xlat/dispatch byte
		db	 05h, 00h, 29h, 03h, 04h, 06h	; xlat/dispatch byte
		db	 2Ch, 07h, 2Dh, 30h, 00h, 01h	; xlat/dispatch byte
		db	 2Eh, 2Fh, 31h, 32h, 30h, 00h	; xlat/dispatch byte
		db	 26h, 2Eh, 2Fh, 27h, 33h, 32h	; xlat/dispatch byte
		db	 30h, 00h	; xlat/dispatch byte
		db	')./*42+0'
mao2_orphan_a_xlat_tail	label	byte		; xlat-table tail (final 8 bytes 00h..36h)
		db	 00h, 29h, 2Eh, 2Fh, 2Ch, 35h	; xlat tail byte
		db	 32h, 36h	; xlat tail byte
mao2_orphan_a_ptr_tbl_b	label	byte		; 14 word ptrs (0AA8Dh..0AADBh) - dialog handler tbl
		db	 8Dh,0AAh, 93h,0AAh	; 0AAxxh word ptr entry
		db	 99h,0AAh, 9Fh,0AAh,0A5h,0AAh	; 0AAxxh word ptr entry
		db	0ABh,0AAh,0B1h,0AAh,0B7h,0AAh	; 0AAxxh word ptr entry
		db	0BDh,0AAh,0C3h,0AAh,0C9h,0AAh	; 0AAxxh word ptr entry
		db	0CFh,0AAh,0D5h,0AAh,0DBh,0AAh	; 0AAxxh word ptr entry
mao2_orphan_a_step_recs_a	label	byte	; 6-byte handler step records
		db	 00h, 00h, 11h, 04h,0AAh, 01h	; 6-byte handler step record
		db	 00h, 00h, 10h, 00h,0ABh, 01h	; 6-byte handler step record
		db	 00h, 00h, 09h, 02h,0AAh, 01h	; 6-byte handler step record
		db	 00h, 00h, 10h, 04h,0ABh, 00h	; 6-byte handler step record
		db	 00h, 00h, 08h, 03h, 55h, 01h	; 6-byte handler step record
		db	 00h, 00h, 10h, 05h,0AAh, 02h	; 6-byte handler step record
		db	 00h, 00h, 10h, 04h,0ABh, 00h	; 6-byte handler step record
		db	 00h, 00h, 31h, 04h,0AAh, 01h	; 6-byte handler step record
		db	 40h, 00h, 41h, 04h,0AAh, 01h	; 6-byte handler step record
		db	 00h, 10h, 21h, 04h,0AAh, 01h	; 6-byte handler step record
		db	 00h, 00h, 05h, 00h, 2Bh, 01h	; 6-byte handler step record
		db	 00h, 00h, 0Dh, 00h, 2Bh, 01h	; 6-byte handler step record
		db	 10h, 00h, 15h, 00h, 2Bh, 01h	; 6-byte handler step record
		db	 00h, 04h, 0Dh, 00h, 2Bh, 01h	; 6-byte handler step record
mao2_orphan_a_ptr_tbl_c	label	byte	; 14 word ptrs (0AAFDh..0AB4Bh) - alt dialog handlers
		db	0FDh,0AAh, 03h,0ABh, 09h,0ABh	; 0ABxxh word ptr entry
		db	 0Fh,0ABh, 15h,0ABh, 1Bh,0ABh	; 0ABxxh word ptr entry
		db	 21h,0ABh, 27h,0ABh, 2Dh,0ABh	; 0ABxxh word ptr entry
		db	 33h,0ABh, 39h,0ABh, 3Fh,0ABh	; 0ABxxh word ptr entry
		db	 45h,0ABh, 4Bh,0ABh	; 0ABxxh word ptr entry
mao2_orphan_a_step_recs_b	label	byte	; alt 6-byte handler step records
		db	 01h,0AAh	; 6-byte handler step record
		db	 04h, 11h, 00h, 00h, 01h,0ABh	; 6-byte handler step record
		db	 00h, 10h, 00h, 00h, 01h,0AAh	; 6-byte handler step record
		db	 02h, 09h, 00h, 00h, 00h,0ABh	; 6-byte handler step record
		db	 04h, 10h, 00h, 00h, 01h, 55h	; 6-byte handler step record
		db	 03h, 08h, 00h, 00h, 02h,0AAh	; 6-byte handler step record
		db	 05h, 10h, 00h, 00h, 00h,0ABh	; 6-byte handler step record
		db	 04h, 10h, 00h, 00h, 01h,0AAh	; 6-byte handler step record
		db	 04h, 31h, 00h, 00h, 01h,0AAh	; 6-byte handler step record
		db	 04h, 41h, 00h, 40h, 01h,0AAh	; 6-byte handler step record
		db	 04h, 21h, 10h, 00h, 01h, 2Bh	; 6-byte handler step record
		db	 00h, 05h, 00h, 00h, 01h, 2Bh	; 6-byte handler step record
		db	 00h, 0Dh, 00h, 00h, 01h, 2Bh	; 6-byte handler step record
		db	 00h, 15h, 00h, 10h, 01h, 2Bh	; 6-byte handler step record
		db	 00h, 0Dh, 04h, 00h	; 6-byte handler step record

mao2_pos_sub		proc	near
		mov	ax,ds:mao2_pos_word
		sub	ax,bx
		jnc	mao2_pos_sub_clamp			; Jump if carry=0
		xor	ax,ax			; Zero register

mao2_pos_sub_clamp:
		mov	ds:mao2_pos_word,ax
		mov	bx,ax
		push	ax
		call	word ptr cs:mao2_drv_scroll_cb
		pop	ax
		or	ax,ax			; Zero ?
		jz	mao2_pos_sub_check_b			; Jump if zero
		retn

mao2_pos_sub_check_b:
		test	byte ptr ds:mao2_gvar_state_b,0FFh
		jz	mao2_pos_sub_set_skip			; Jump if zero
		retn

mao2_pos_sub_set_skip:
		mov	byte ptr ds:mao2_anim_step,0
		mov	byte ptr ds:mao2_dlg_a_active,0
		mov	byte ptr ds:mao2_dlg_b_active,0
		mov	byte ptr ds:mao2_gvar_state_b,0FFh
		retn

mao2_pos_sub		endp

mao2_pos_step		proc	near
		cmp	word ptr ds:mao2_pos_word,320h
		jne	mao2_pos_step_advance			; Jump if not equal
		retn

mao2_pos_step_advance:
		mov	bx,ds:mao2_pos_word
		add	bx,50h
		mov	ax,320h
		cmp	ax,bx
		jae	mao2_pos_step_save			; Jump if above or =
		mov	bx,320h
		mov	byte ptr ds:mao2_anim_finished,0
		mov	byte ptr ds:mao2_phase_step,0Ah
		mov	byte ptr ds:mao2_phase_active,0FFh
		mov	byte ptr ds:mao2_attr_high_nib,60h	; '`'

mao2_pos_step_save:
		mov	ds:mao2_pos_word,bx
		mov	byte ptr ds:mao2_gvar_phase_byte,3Ch	; '<'
		jmp	word ptr cs:mao2_drv_scroll_cb

mao2_pos_step		endp

mao2_skip_anim_top:
		mov	al,ds:mao2_anim_step
		cmp	al,28h			; '('
		jae	mao2_skip_anim_done			; Jump if above or =
		test	byte ptr ds:mao2_anim_step,7
		jnz	mao2_skip_anim_step			; Jump if not zero
		mov	byte ptr ds:mao2_gvar_phase_byte,23h	; '#'

mao2_skip_anim_step:
		mov	byte ptr ds:mao2_gvar_state_c,0FFh
		inc	byte ptr ds:mao2_anim_step
		cmp	al,14h
		jb	mao2_skip_anim_xlat			; Jump if below
		jmp	mao2_render_emit_top

mao2_skip_anim_xlat:
		shr	al,1			; Shift w/zeros fill
		mov	bx,mao2_phase_handler_tbl
		xlat				; al=[al+[bx]] table
		mov	ds:mao2_phase_substate,al
		jmp	mao2_render_emit_top

mao2_skip_anim_done:
		mov	byte ptr ds:mao2_gvar_state_d,0FFh
		retn

; ------------------------------------------------------------------
; mao2_orphan_block_b: trailer-region data bytes (Sourcer-decoded as
; mnemonics).  No-entry-point: this block is the alternate-state
; byte / handler trailer referenced via mao2_alt_state_byte (0xAEAD)
; and adjacent hard-coded DS offsets.  Preserved verbatim.
; ------------------------------------------------------------------

mao2_orphan_block_b	label	byte
		or	[bx+si],cl
		or	[si],cl
		or	al,0Ch
		or	ax,0B0Dh
		or	si,[bx+si]
		add	[bx+di],cl
		and	[bp+di],al
		adc	[bx],ah
		or	al,0
;*		adc	byte ptr ds:[0][si],ch
		db	 10h,0ACh, 00h, 00h	;  Fixup - byte match
		adc	word ptr ss:[702h][bp+di],di
		dec	dx
; 'ashiin' - tail of 'Jashiin' speaker-name (first 'J' is preceding byte)
		db	'ashiin'
		db	84 dup (0)		; pad to module end

seg_a		ends

		end	start
