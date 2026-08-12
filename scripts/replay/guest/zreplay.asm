; Test-only deterministic input hook appended to a private copy of stick.bin.
; The release driver is 1036h bytes and is loaded at CS:0100h, so this hook
; begins at runtime CS:1136h and remains below the graphics driver at 2000h.

target          equ     'T2'
hook_origin     equ     1136h
timer_resume    equ     025Fh
process_scan    equ     0326h
event_capacity  equ     512
event_size      equ     5

seg_a segment byte public
        assume cs:seg_a, ds:seg_a
        org 1136h

hook_entry:
        ; The patched near CALL contributes a return word that the original
        ; far graphics CALL did not leave behind. Discard it before entering
        ; the release callback so the ISR's final register pops stay aligned.
        pop     word ptr cs:[near_return_scratch]
        ; Preserve the release timer's graphics-present call at CS:025Ah.
        ; Replay then runs at the first stable frame boundary, before the
        ; input poll and frame counters advance.
        call    dword ptr cs:[0FF10h]
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        push    ds
        push    es
        push    cs
        pop     ds
        mov     ax,cs:[replay_tick]
        mov     si,cs:[replay_cursor]

event_loop:
        cmp     word ptr cs:[si],0FFFFh
        je      event_exhausted
        cmp     word ptr cs:[si],ax
        ja      resume_timer
        jb      event_missed
        mov     dl,cs:[si+2]
        cmp     dl,0FFh
        je      checkpoint_reached
        mov     al,dl
        call    word ptr cs:[process_scan_pointer]
        mov     al,cs:[si+3]
        mov     cs:[last_input_sequence],al
        add     si,event_size
        mov     cs:[replay_cursor],si
        jmp     event_loop

resume_timer:
        inc     word ptr cs:[replay_tick]
        pop     es
        pop     ds
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     word ptr cs:[timer_resume_pointer]

event_missed:
        mov     byte ptr cs:[result_status],2
        mov     al,cs:[si+3]
        mov     cs:[first_missed_sequence],al
        jmp     short write_result

event_exhausted:
        mov     byte ptr cs:[result_status],3
        jmp     short write_result

checkpoint_reached:
        mov     al,cs:[si+3]
        mov     cs:[checkpoint_id],al
        mov     al,cs:[si+4]
        mov     cs:[checkpoint_sequence],al
        mov     byte ptr cs:[result_status],1

write_result:
        mov     ax,cs:[replay_tick]
        mov     cs:[result_tick],ax
        mov     al,cs:[last_input_sequence]
        mov     cs:[last_result_sequence],al
        mov     al,cs:[first_missed_sequence]
        mov     cs:[first_result_sequence],al

        ; Hash the entire game segment, including input latches and timers.
        push    cs
        pop     ds
        xor     si,si
        mov     ax,0FFFFh
        mov     cx,8000h
        call    crc16
        mov     cx,8000h
        call    crc16
        mov     cs:[segment_crc],ax

        ; Hash the visible 320x200 MCGA framebuffer.
        mov     ax,0A000h
        mov     ds,ax
        xor     si,si
        mov     ax,0FFFFh
        mov     cx,0FA00h
        call    crc16
        mov     cs:[framebuffer_crc],ax

        ; Read and hash all 256 DAC entries.
        push    cs
        pop     es
        mov     di,offset palette_buffer
        mov     dx,03C7h
        xor     al,al
        out     dx,al
        add     dx,2
        mov     cx,0300h
palette_read:
        in      al,dx
        stosb
        loop    palette_read
        push    cs
        pop     ds
        mov     si,offset palette_buffer
        mov     ax,0FFFFh
        mov     cx,0300h
        call    crc16
        mov     cs:[palette_crc],ax

        ; DOSBox-X executes this only at an authored checkpoint, outside DOS
        ; file services. The tiny result makes completion observable without
        ; polling a host window or sleeping for a guessed duration.
        push    cs
        pop     ds
        mov     dx,offset result_filename
        xor     cx,cx
        mov     ah,3Ch
        int     21h
        jc      terminate
        mov     bx,ax
        mov     dx,offset result_record
        mov     cx,result_record_end-result_record
        mov     ah,40h
        int     21h
        mov     ah,3Eh
        int     21h

terminate:
        mov     ax,4C00h
        int     21h
        cli
halt_forever:
        hlt
        jmp     short halt_forever

; CRC-16/IBM. AX carries the CRC between chunks, DS:SI is input, CX length.
crc16:
        push    bx
        push    dx
crc_next_byte:
        mov     dl,[si]
        inc     si
        xor     al,dl
        mov     bl,8
crc_next_bit:
        shr     ax,1
        jnc     crc_no_xor
        xor     ax,0A001h
crc_no_xor:
        dec     bl
        jnz     crc_next_bit
        loop    crc_next_byte
        pop     dx
        pop     bx
        ret

replay_tick             dw      0
replay_cursor           dw      event_table
near_return_scratch     dw      0
process_scan_pointer    dw      process_scan
timer_resume_pointer    dw      timer_resume
last_input_sequence     db      0FFh
first_missed_sequence   db      0FFh

result_filename         db      'REPLAY.OUT',0
result_record:
                        db      'ZRP1'
result_tick             dw      0
checkpoint_id           db      0FFh
result_status           db      0
segment_crc             dw      0
framebuffer_crc         dw      0
palette_crc             dw      0
last_result_sequence    label   byte
                        db      0FFh
checkpoint_sequence     db      0FFh
first_result_sequence   label   byte
                        db      0FFh
                        db      0
result_record_end:

event_marker            db      'ZRPEVENT'
event_table             db      event_capacity*event_size dup (0FFh)
palette_buffer          db      0300h dup (0)

seg_a ends
        end
