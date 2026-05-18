; Simple test file for TasmRunner
; Assemble with: TasmRunner test.asm

.MODEL SMALL
.STACK 100h

.DATA
    msg DB 'Hello from TASM!$'

.CODE
main PROC
    mov ax, @data
    mov ds, ax

    ; Display message
    lea dx, msg
    mov ah, 09h
    int 21h

    ; Exit
    mov ax, 4C00h
    int 21h
main ENDP

END main
