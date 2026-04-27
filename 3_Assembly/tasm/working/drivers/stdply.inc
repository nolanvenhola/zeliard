;==========================================================================
;
;  stdply.inc - Hero stat record + driver state shared with gm*.bin drivers
;
;  stdply.bin loads at game_entry_seg:0000h. All graphics drivers (gm*.bin)
;  run in the same segment and access these fields via CS-relative addresses.
;
;  CORRECTED 2026-04-26 against IDA decompilation evidence:
;  the 0x85-0x9D block was previously interpreted as driver state
;  (drv_timer_flag, drv_text_src, etc.), but the initial byte values are
;  consistent with the hero stat record:
;    0x90 init = 0x50 = 80  -> matches manual's max HP
;    0x92 init = 0x01       -> matches SWORD_TRAINING (starting weapon)
;    0x85/86 init = 0x00,00 -> consistent with starting gold = 0
;  See evidence_check.py / EVIDENCE_REPORT.md for the per-byte verdict.
;
;  Fields at 0x80, 0x83, 0xAB remain INCONCLUSIVE — left as-is until
;  more evidence emerges.
;
;==========================================================================

; Player config bytes  [0x0080-0x0084]  (NOT YET VALIDATED)
ply_walk_speed          equ     80h     ; init 0x1E = 30 (purpose inconclusive)
ply_accel               equ     83h     ; init 0x0A each (purpose inconclusive)

; Hero stat record  [0x0085-0x009D]  (validated against manual + IDA)
hero_gold_hi            equ     85h     ; gold high byte (init 0x00 = no gold)
hero_gold_lo            equ     86h     ; gold low byte
hero_almas              equ     8Bh     ; alternate currency (init 0x00)
hero_HP                 equ     90h     ; current HP (init 0x50 = 80, max)
sword_type              equ     92h     ; sword type (init 1 = SWORD_TRAINING)
shield_type             equ     93h     ; shield type (init 0 = no shield)
shield_HP               equ     94h     ; shield HP (init 0 = no shield equipped)
current_magic_spell     equ     9Dh     ; magic spell id (init 0 = no spell)

; Animation color LUT  [0x00AB-0x00C3]  (NOT YET VALIDATED)
; IDA names this 'spells_espada' (Spanish 'espada' = sword/magic spells list).
; Init byte = 0x0C; could be a color value or a spell-list start. Inconclusive.
drv_color_lut           equ     0ABh    ; (purpose inconclusive)
