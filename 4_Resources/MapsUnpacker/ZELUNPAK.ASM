code_seg_a      segment
                assume  cs:code_seg_a,ds:code_seg_a
                org     100h
start:          jmp     m0
_out:           db      'lv.txt',0          ; some weird name I chose for the output file
_size:          dw      ?
beg_out:        dw      ?
                db      ?, ?, ?
; Warning! This extractor assumes that .mdt file to extract is loaded at offset dta
; The simplest way to achieve this, is just paste *.mdt binary to the compiled *.com of this extractor
; COPY /B zelunpack.com + mp10.mdt unpack_mp10.com
; Then run unpack_mp10.com
m0:             mov     si,offset dta+1bh   ; packed map data always starts at 1Bh in mp??.mdt
                mov     di,offset dta
                add     di,word ptr _size
                mov     word ptr beg_out,di
                mov     cx,word ptr dta+2
                mov     ax,cx
locloop_4:      push    di
                dec     ax
                xor     dl,dl
loc_7:          call    step
                inc     si
                add     dl,bh
                add     bl,20h          ; add ' ' so binary map looks like text
loc_8:          mov     [di],bl
                inc     di
                or      ax,ax
                jnz     mid
                mov     byte ptr [di],0dh ; add CR
                inc     di
                mov     byte ptr [di],0ah ; add LF
                jmp     short mid0
mid:            inc     di
mid0:           add     di,word ptr dta+2
                dec     bh
                jnz     loc_8
                cmp     dl,40h
                jb      loc_7
                or      ax,ax
                jnz     over
                mov     ax,word ptr dta+2
over:           pop     di
                inc     di
                loop    locloop_4

                mov     dx,offset _out
                xor     cx,cx
                mov     ah,3ch
                int     21h             ;create "lv.txt"
                mov     bx,ax
                mov     cx,word ptr dta+2
                inc     cx
                inc     cx
                shl     cx,6
                mov     dx,word ptr beg_out
                mov     ah,40h
                int     21h             ;write cx bytes
                mov     ah,3eh          ;close file
                int     21h
                ret

step            proc    near
                mov     bl,[si]         ; 0,4,8,C x
                and     bl,0c0h
                rol     bl,1
                rol     bl,1
                xor     bh,bh
                add     bx,bx
                jmp     word ptr base[bx]
base:           dw      case0,case1,case2,case3
case0:          mov     bh,[si]         ; 00...... ........
                inc     bh              ; =bh      =bl
                inc     si
                mov     bl,[si]
                retn
case1:          mov     bl,[si]         ; 01......
                mov     bh,bl
                shr     bh,1            ;=bh-2
                shr     bh,1                 =bl-1
                shr     bh,1
                shr     bh,1
                and     bh,3
                add     bh,2
                and     bl,0fh
                inc     bl
                retn
case2:          mov     bh,[si]         ; 10......
                and     bh,3fh          ;    =bh
                xor     bl,bl           ; bl=0
                retn
case3:          mov     bl,[si]         ; 11......
                and     bl,3fh          ;    =bl
                mov     bh,1            ; bh=1
                retn
step            endp

dta:
code_seg_a      ends
                end     start
