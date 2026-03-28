# Zeliard Source Reconstruction — Known Issues & Fixes Needed

## 1. `db`-encoded instructions (Sourcer couldn't decode)

Sourcer output raw `db` bytes when it couldn't reliably decode an instruction.
Most need to be replaced with proper mnemonics.

### Relative jumps/calls — safe but ugly
These are position-independent so not a linkability risk, but should be
converted to proper assembler syntax for readability:

| File | Lines | Description |
|------|-------|-------------|
| `zelres1/code/106TOWNB.asm` | 1822, 1851, 2000, 2103 | JMP NEAR (rel) encoded as `db 0E9h,...` |
| `zelres2/code/201SELCT.asm` | 245,357,362,490,495,549,562,728,911 + more | CALL/JMP NEAR as `db` |
| `zelres2/code/200FIGHT.asm` | 416, 2215, 4872, 4877, 5323 + more | CALL/JMP as `db` |
| `zelres3/code/356LVGRP.asm` | 84, 707 | CALL NEAR as `db` |
| Multiple driver files | Various | Scattered relative jumps |

### Absolute FAR jumps — need investigation before touching
These contain `0xEA` (JMP FAR opcode) at what appears to be instruction
boundaries. Most in the high-hit-count files (207MOLEB, 208SATNO, 209BOSQE)
are almost certainly **sprite/bitplane data** misread by Sourcer. The low-count
ones are plausible real far jumps:

| File | Line | Decoded target | Notes |
|------|------|----------------|-------|
| `zelres1/code/124UTILA.asm` | 153 | incomplete (1 byte only) | Context needed |
| `zelres1/code/124UTILA.asm` | 286 | CC04:A8B8 | Suspicious — verify in binary |
| `zelres1/code/130UTILB.asm` | 435 | incomplete | Context needed |
| `zelres1/code/130UTILB.asm` | 583 | 00FF:ABAA | Suspicious |
| `zelres2/code/200FIGHT.asm` | 4903 | 4CFE:D885 | Possibly real |
| `zelres3/code/356LVGRP.asm` | 257,391,487,626,694,800,861,923 | Various | BIOS/boot calls? |
| `zelres3/code/356LVGRP.asm` | 750 | **000F:07C0** | Looks like BIOS warm boot vector |

---

## 2. Graphics driver internal EQU linkability (deferred)

The 5 graphics drivers (`gmmcga`, `gmcga`, `gmega`, `gmhgc`, `gmtga`) all load
at 0x2000 in the game segment and have internal data EQUs using hardcoded
absolute addresses (e.g. `data_32e equ 2226h`). The same `DRIVER_BASE + (offset label)`
fix used for `game.asm` is blocked by TASM 2.01's type system: mixed byte/word
memory accesses conflict with typed segment-relative EQUs.

- `fix_drivers.py` exists but is incomplete
- Decision: leave for now — drivers are stable, rarely-edited code

---

## 3. zelres1/code missing chunk 11

zelres2 chunk_11 (OMOYPRO.BIN, souvenir shop program) has no corresponding
.asm file in zelres2/code/. No 211XXXXX.asm exists.

- Binary exists: `bin/zelres2/211XXXXX.bin` — **verify if it's present**
- Needs Sourcer disassembly pass

---

## 4. zelres1 data file ordering (unresolved)

The friend's filename list (alphabetical order: ame, dmaou, hime, himp, hou...)
differs from our byte-matched ordering. Needs verification against actual SAR
chunk content to confirm correct assignment.

---

## 5. zeliad.asm hardcoded interrupt handler offsets

zeliad.asm uses raw `db 0BAh, xx, xx` to encode `MOV DX, 0x0100/0x0103/0x0106/0x0109`
pointing at game.bin's interrupt handler stubs. These reference `stick.bin`'s
ISR code at fixed offsets in the game segment. If the game segment layout ever
changes, these break.

- Low priority — segment layout is stable
- Could be converted to `EXTRN` references if stick.asm exports them
