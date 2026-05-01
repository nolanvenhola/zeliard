# Zeliard script-bytecode interpreter

How every NPC, shop, and king-dialog scene actually runs.

---

## TL;DR

Zeliard's town/shop/NPC interactions aren't hard-coded.  Each shop chunk
(210KINGP, 212ARMRP, 213BANKP, 214CHURP, 215DRUGP, 216INNAP, 217KENJP)
runs a **small bytecode VM**:

```asm
loop:
        call    word ptr cs:script_step       ; reads next opcode
        cmp     al, 0FFh                      ; FFh = end-of-script
        je      exit
        call    script_opcode_dispatch        ; jmp via dispatch_tbl[al*2]
        jmp     short loop
```

The VM's **runtime services** live in town.bin (loaded at CS:0x6000
during town phases — same segment as the shops themselves at runtime).
Town.bin's chunk header reserves the first ~24 bytes as a function-
pointer table that the shops far-call into.

The **opcode table** is per-shop.  Each shop chunk defines its own
dispatch table at a known DS-relative address; opcodes 2..N route to
shop-local handlers that do things like "wait N frames", "fill the
dialog rectangle", "show menu", "branch on selection".

The **bytecode itself** is a stream of bytes embedded in the shop
chunk's data section, pointed at by `gvar_script_ip` (DS:[FF4C]).

---

## Memory layout

```
DS-relative globals (game-state segment):
  FF4C    gvar_script_ip       current script byte ptr (advances with each step)
  FF4E    gvar_text_x          dialog cursor X (alias: gvar_init_flag_a)
  FF4F    gvar_text_y          dialog cursor Y (alias: gvar_init_flag_b)
  FF50    gvar_timer_word      dialog/menu timer
  FF52    gvar_dlg_cols        dialog window columns byte
  FF53    gvar_dlg_rows        dialog window rows byte
  FF54    gvar_dlg_pos         dialog window position word

CS-relative dispatch slots (filled by town.bin's header):
  6004h   script_step          (entry point of the VM core; rebuilt
                                 town.bin: stub that jge-skips probe)
  6006h   script_format_num    DL:AX -> decimal text at DI, then ASCIIZ
  6008h   script_display_page  display next dialog page; CF=user cancel
  600Ah   script_take_item     deduct item from inventory
  600Ch   script_give_item     add item to inventory
  600Eh   show_menu_items      display SI-pointed item list
  6010h   menu_show_list       show menu, return CF=cancel
                                 (BL=preselected idx)
  6012h   menu_init            init menu (BX=pos, DI=buffer, CL=count, AL=start)
  6014h   script_fn_menu_init  alt menu init (selection-list variant)
```

The CS slot values are **WORD POINTERS** at fixed file offsets in
town.bin's header (offsets 0x04..0x16).  When town.bin loads at
CS:0x6000, those file-offset words become CS:[6000+offset] pointers.
Shops do `call word ptr cs:script_step` which is `call word ptr cs:[6004]`
— it reads the word at CS:0x6004 and CALLS that address.

---

## Shop main loop

Every shop main proc looks like this:

```asm
shop_main:
        ; setup phase — load shop graphics, draw banner, position dialog
        call    cs:drv_screen_init_a
        call    cs:drv_screen_init_b
        ...
        call    select_script_branch   ; pick the welcome / item / goodbye sub-script
        mov     ds:gvar_script_ip, si  ; point script_ip at the chosen branch

script_loop:
        call    cs:script_step         ; AL = next opcode byte
        cmp     al, 0FFh
        je      script_exit            ; FF = end of script
        call    script_opcode_dispatch ; jmp via cs:opcode_dispatch_tbl[al*2]
        jmp     short script_loop

script_exit:
        jmp     cs:drv_return_to_caller
```

The pattern is identical across all 7 shop chunks.

---

## script_opcode_dispatch — the per-shop branch

```asm
script_opcode_dispatch  proc near
        mov     bl, al
        xor     bh, bh
        add     bx, bx                            ; bx = al * 2
        jmp     word ptr cs:opcode_dispatch_tbl[bx]
script_opcode_dispatch  endp
```

The `opcode_dispatch_tbl` lives in the shop's DS-resident data area
(typical address 0xA0B8 in BANKP, 0xA0C3 in DRUGP, etc.).  Each table
entry is a 2-byte word — the address of an opcode handler in the SAME
shop chunk.

**Opcode 0xFF is reserved** as end-of-script.  Other opcodes (typically
0x00..0x10 range) route to handlers that do shop-specific work.

---

## A representative opcode set (213BANKP)

The bank-shop's dispatch table at 0xA0B8 routes opcodes through a mix
of inline-asm handlers and direct calls to the runtime services:

| Opcode | Handler | Action |
|---:|---|---|
| 0 | A0C0 | (entry — likely wait or NOP) |
| 1 | A0D2 | (likely a dialog-step) |
| 2 | A5F3 | (sub-script entry) |
| 3 | A619 | (post-transaction state update) |
| ... | ... | ... |

The handlers themselves are short asm fragments that call back into
the runtime via `call cs:script_step` (read more bytes), `call cs:drv_fill_rect`,
`call cs:script_display_page`, etc.  Common patterns observed:

- **Set frame timer**: `mov [FF1A], imm; cmp [FF1A], 3Ch; jb -7`  — wait until
  frame timer reaches 0x3C
- **Fill dialog rectangle**: `mov bx, posW; mov cx, sizeWxH; mov al, FFh;
  call cs:drv_fill_rect`
- **Position dialog**: `mov word [FF54], pos; mov byte [FF52], cols;
  mov byte [FF53], rows`
- **Show menu**: `mov cx, n; mov si, items_ptr; call cs:[600E]`
- **Branch on selection**: `mov bl, [selected_byte]; xor bh, bh; add bx, bx;
  jmp word ptr cs:[bx + branch_tbl]`
- **Set next sub-script**: `mov word ptr ds:gvar_script_ip, addr`

Each shop's exact opcode-set needs to be reverse-engineered chunk-by-
chunk, but the **architecture is uniform**.

---

## How a shop conversation flows

```
Player walks into shop tile in town
   │
   ▼
106TOWN building dispatch
   │   far-call into 21xSHOP main
   ▼
SHOP_MAIN sets up:
   - load banner ('Welcome to the bank' etc.)
   - render shop background
   - call select_script_branch — picks WELCOME / BUY-MENU / SELL-MENU /
     GOODBYE based on shop state
   - sets gvar_script_ip to the chosen sub-script's bytecode address
   │
   ▼
SCRIPT LOOP:
   ┌──── call cs:script_step (AL = next byte at gvar_script_ip)
   │     gvar_script_ip += 1
   │
   ├──── if AL == FF: exit (jmp drv_return_to_caller back to town)
   │
   └──── call cs:script_opcode_dispatch
         │
         ▼ (per-shop handler)
         either:
           - call cs:drv_*    (graphics: fill, draw, render char)
           - call cs:script_format_num  (output decimal at DI)
           - call cs:script_display_page (show dialog page; CF=cancel)
           - call cs:script_take_item   (deduct cost from gold/inventory)
           - call cs:script_give_item   (add purchase to inventory)
           - call cs:menu_show_list     (show menu; BL=pre-selection,
                                          CF=cancel)
           - inline-asm: read register, branch on selection, call back
             into script_step recursively
         then: retn → back to script-loop

   (loop continues until FF)
```

When the script returns, control flows back through
`drv_return_to_caller` → 106TOWN → frame_loop, and the player resumes
walking around town with whatever state the shop transaction modified
(gold, inventory, level, etc.).

---

## Why this design

**Compactness.**  Each shop's logic — including dialog text positioning,
menu options, item lookups, and conversation branching — fits into a
1-7 KB chunk because the bytecode is dense (many ops are 1 byte) and
the runtime services are shared.

**Per-shop customization without per-shop engine code.**  All shops
share the script_step/format_num/display_page runtime; each shop just
defines its own opcode dispatch table.  Adding a new shop is "write
the bytecode + the dispatch table + the handler bodies" — no engine
changes.

**Memory efficiency.**  Only one shop is loaded at a time (overlay-
style), and the runtime services in town.bin stay resident throughout
the town phase.

---

## Implications for a port

A reimplementation can either:

1. **Re-implement the bytecode VM** — build a `ScriptVM` class that
   reads from a byte stream, dispatches each opcode through a per-shop
   handler dict, and exposes services like `format_decimal`,
   `display_page`, `take_item`, `give_item`, `show_menu`.  Most
   faithful to the original architecture; reusable across all shops.

2. **Rewrite each shop as native code** — extract each shop's
   conversation tree (welcome / buy / sell / goodbye paragraphs +
   menu choices + post-purchase state updates) into hand-coded shop
   classes.  Lose the architectural symmetry but gain clarity per shop.

Option 1 needs the per-shop opcode handler bodies + the bytecode
streams decoded.  Option 2 needs each shop's conversation tree
extracted from runtime observation (DOSBox playthroughs).  Either
way, knowing the **runtime contract** (CS:[6004]-[6016] services +
the script_step / dispatch / FF-terminator pattern) is the foundation.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

After this trace:
- **Architecture**: ✓ understood (this doc)
- **Per-shop opcode tables**: ⚠ partial (BANKP entries 0-3 documented;
  full per-shop decode TBD per chunk)
- **Per-shop bytecode streams**: ❌ each shop's dialog tree still
  needs runtime extraction
- **Runtime services (CS:[6004]-[6016])**: ⚠ documented at the
  contract level (inputs/outputs); byte-level impl in town.bin
  could be probed but is largely a black box for porting purposes

The framework is sufficient for a port that re-implements the VM.
Per-shop opcode reverse-engineering becomes a separate workstream
(one chunk at a time, with DOSBox runtime observation pairing).
