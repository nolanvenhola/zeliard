; masm_compat.inc — MASM 5.1 compatibility macros for typed-EQU memory operands.
;
; MASM 5.1 rejects instructions of the form  cs:[BASE + offset label]  when the
; EQU carries the label's BYTE type.  These macros emit the identical instruction
; bytes symbolically via DW (which MASM accepts for typed expressions in data
; context), so the addresses remain fully symbolic and auto-update if layout
; changes.
;
; Each macro documents the instruction it replaces.

; ── game.asm helpers ─────────────────────────────────────────────────────────

; cmp word ptr cs:[addr16], -1
; Encodes: 2E 83 3E <addr_lo> <addr_hi> FF
MASM_CMP_CS_WORD_NEG1  MACRO  addr_equ
        DB      2Eh, 83h, 3Eh
        DW      addr_equ
        DB      0FFh
ENDM

; mov word ptr [addr16+2], ax   (DS: implicit — no prefix byte)
; Encodes: 89 06 <addr+2_lo> <addr+2_hi>
MASM_MOV_MEM16P2_AX  MACRO  addr_equ
        DB      89h, 06h
        DW      addr_equ + 2
ENDM

; call dword ptr [addr16]   (DS: implicit — no prefix byte)
; Encodes: FF 1E <addr_lo> <addr_hi>
MASM_CALL_FAR_MEM  MACRO  addr_equ
        DB      0FFh, 1Eh
        DW      addr_equ
ENDM

; ── stick.asm helpers ────────────────────────────────────────────────────────

; test byte ptr cs:[addr16], 0FFh
; Encodes: 2E F6 06 <addr_lo> <addr_hi> FF
MASM_TEST_CS_BYTE_FF  MACRO  addr_equ
        DB      2Eh, 0F6h, 06h
        DW      addr_equ
        DB      0FFh
ENDM

; mov byte ptr cs:[addr16], 0
; Encodes: 2E C6 06 <addr_lo> <addr_hi> 00
MASM_MOV_CS_BYTE_ZERO  MACRO  addr_equ
        DB      2Eh, 0C6h, 06h
        DW      addr_equ
        DB      0
ENDM

; cmp byte ptr cs:[addr16], imm8
; Encodes: 2E 80 3E <addr_lo> <addr_hi> <imm>
MASM_CMP_CS_BYTE_IMM  MACRO  addr_equ, imm_val
        DB      2Eh, 80h, 3Eh
        DW      addr_equ
        DB      imm_val
ENDM
