; debug.inc — Conditional trace output via DOSBox-X port 0E9h
;
; Port 0E9h is the DOSBox-X debug output port.  Writing a byte to it emits
; that character to the DOSBox-X log/console window in real time.
;
; USAGE
;   1. Set DEBUG_BUILD EQU 1 at the top of your .asm BEFORE including this
;      file.  Leave it at 0 (the default) for normal bit-perfect builds.
;   2. Add the line
;          include debug.inc
;      after srmacros.inc.
;   3. Place  DBG_PROCS  exactly once, somewhere in your code segment.
;      This emits the helper procedures.  Put it near the end of the file
;      (before any data) so forward references from macros resolve.
;
; MACROS (all expand to empty when DEBUG_BUILD EQU 0)
;   DBGC   char        — emit a single literal character byte
;   DBGNL              — emit newline (0Ah)
;   DBGBYTE val        — emit val as 2-digit hex  (val = register or mem byte)
;   DBGWORD val        — emit val as 4-digit hex  (val = register or mem word)
;   DBGSTR "text"      — emit a literal string (data is embedded inline, jmp
;                        skips it at runtime; OK in loops and branches)
;   DBGREGB name,val   — emit  name=XX    (byte)
;   DBGREGW name,val   — emit  name=XXXX  (word)
;
; All macros save and restore every register they touch.
; DBGSTR temporarily makes DS = CS to access the embedded string.

IFNDEF DEBUG_BUILD
DEBUG_BUILD EQU 0
ENDIF

; ---- conditional macro bodies -------------------------------------------- ;

IF DEBUG_BUILD

DBGC MACRO char_val
        push    ax
        mov     al, char_val
        out     0E9h, al
        pop     ax
ENDM

DBGNL MACRO
        push    ax
        mov     al, 0Ah
        out     0E9h, al
        pop     ax
ENDM

DBGBYTE MACRO val
        push    ax
        mov     al, val
        call    _dbg_byte
        pop     ax
ENDM

DBGWORD MACRO val
        push    ax
        mov     ax, val
        call    _dbg_word
        pop     ax
ENDM

; DBGSTR str_label
;   Emits a null-terminated string stored at str_label (defined in the debug
;   string pool at the END of the source file, so existing data labels don't
;   shift).  str_label must be a label visible at the call site.
DBGSTR MACRO str_label
        push    ax
        push    si
        push    ds
        cli
        push    cs
        pop     ds
        mov     si, DBG_CHUNK_BASE + offset str_label
        call    _dbg_str
        pop     ds
        sti
        pop     si
        pop     ax
ENDM

DBGREGB MACRO name, val
        DBGSTR  name
        DBGC    '='
        DBGBYTE val
        DBGC    ' '
ENDM

DBGREGW MACRO name, val
        DBGSTR  name
        DBGC    '='
        DBGWORD val
        DBGC    ' '
ENDM

; ---- Emit the helper procedures into the current code segment.
; Place  DBG_PROCS  exactly once in the .asm file, inside a code segment.

DBG_PROCS MACRO

_dbg_byte       proc    near    ; output AL as 2-digit hex; preserves AX, CX
        push    ax
        push    cx
        mov     ah, al
        mov     cl, 4
        shr     al, cl          ; high nibble in AL
        add     al, '0'
        cmp     al, '9'+1
        jb      _dbg_byte_hi
        add     al, 7           ; 'A'..'F'
_dbg_byte_hi:
        out     0E9h, al
        mov     al, ah
        and     al, 0Fh         ; low nibble
        add     al, '0'
        cmp     al, '9'+1
        jb      _dbg_byte_lo
        add     al, 7
_dbg_byte_lo:
        out     0E9h, al
        pop     cx
        pop     ax
        ret
_dbg_byte       endp

_dbg_word       proc    near    ; output AX as 4-digit hex; preserves AX
        push    ax
        xchg    ah, al          ; AL = high byte
        call    _dbg_byte
        pop     ax
        push    ax              ; AL = low byte
        call    _dbg_byte
        pop     ax
        ret
_dbg_word       endp

_dbg_str        proc    near    ; output null-terminated string at DS:SI; preserves AX, SI
        push    ax
        push    si
_dbg_str_loop:
        lodsb
        or      al, al
        jz      _dbg_str_done
        out     0E9h, al
        jmp     _dbg_str_loop
_dbg_str_done:
        pop     si
        pop     ax
        ret
_dbg_str        endp

ENDM    ; DBG_PROCS

; ---- null macro bodies when debug is disabled ---------------------------- ;

ELSE

DBGC    MACRO   char_val
ENDM
DBGNL   MACRO
ENDM
DBGBYTE MACRO   val
ENDM
DBGWORD MACRO   val
ENDM
DBGSTR  MACRO   text
ENDM
DBGREGB MACRO   name, val
ENDM
DBGREGW MACRO   name, val
ENDM
DBG_PROCS MACRO
ENDM

ENDIF
