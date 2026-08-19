# Zeliard Source Reconstruction — Known Issues & Fixes Needed

## 1. `db`-encoded instructions (Sourcer couldn't decode)

Sourcer output raw `db` bytes when it couldn't reliably decode an instruction.
Most need to be replaced with proper mnemonics.

### Relative jumps/calls — safe but ugly
These are position-independent so not a linkability risk, but should be
converted to proper assembler syntax for readability:

| File | Lines | Description |
|------|-------|-------------|
| `zelres1/code/106TOWN.asm` | 1822, 1851, 2000, 2103 | JMP NEAR (rel) encoded as `db 0E9h,...` |
| `zelres2/code/201SELCT.asm` | 245,357,362,490,495,549,562,728,911 + more | CALL/JMP NEAR as `db` |
| `zelres2/code/200FIGHT.asm` | 416, 2215, 4872, 4877, 5323 + more | CALL/JMP as `db` |
| `zelres3/code/356LVGRP.asm` | 84, 707 | CALL NEAR as `db` |
| Multiple driver files | Various | Scattered relative jumps |

### Absolute FAR jumps — need investigation before touching
These contain `0xEA` (JMP FAR opcode) at what appears to be instruction
boundaries. The low-count files are plausible real far jumps:

| File | Line | Decoded target | Notes |
|------|------|----------------|-------|
| `zelres1/code/124UTILA.asm` | 153 | incomplete (1 byte only) | Context needed |
| `zelres1/code/124UTILA.asm` | 286 | CC04:A8B8 | Suspicious — verify in binary |
| `zelres1/code/130UTILB.asm` | 435 | incomplete | Context needed |
| `zelres1/code/130UTILB.asm` | 583 | 00FF:ABAA | Suspicious |
| `zelres2/code/200FIGHT.asm` | 4903 | 4CFE:D885 | Possibly real |
| `zelres3/code/356LVGRP.asm` | 257,391,487,626,694,800,861,923 | Various | BIOS/boot calls? |
| `zelres3/code/356LVGRP.asm` | 750 | **000F:07C0** | Looks like BIOS warm boot vector |

### Town building programs — embedded sprite data (207MOLEB, 208SATNO, 209BOSQE)

These three files (mole.bin, YMPD.BIN, CKPD.BIN) are the town building programs
for specific towns. They are NOT town map data — the actual town overworld maps
are the `.mdt` files in zelres2 chunks 36-45 (STMP.MDT = Satono, BSMP.MDT = Bosque, etc.).

The high count of apparent `0xEA` "JMP FAR" patterns in these files is because
they contain **embedded sprite graphics** for shop/building interiors (NPC sprites,
counter graphics, etc.). The `0xAA`, `0xEE`, `0xBF` byte patterns are classic
Zeliard sprite bitplane values, not code.

To properly annotate these files the code/data sections need to be separated first:
- Use MASM function tests or pinned DOSBox-X traces to identify which bytes execute
- Annotate data sections with explicit `db` labels and section headers
- This is a prerequisite for understanding the building interaction logic

| File | Original name | Town | `0xEA` count | Status |
|------|--------------|------|-------------|--------|
| `207MOLEB.asm` | mole.bin | (underground movement) | 42 | Data — skip for now |
| `208SATNO.asm` | YMPD.BIN | Satono (town 2) | 57 | Data — skip for now |
| `209BOSQE.asm` | CKPD.BIN | Bosque (town 3) | 16 | Data — skip for now |

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

## 3. ~~zelres2 chunk_11 missing~~ ✓ DONE

zelres2 chunk_11 (OMOYPRO.BIN) was misclassified as data (211DRVTB.bin).
Fixed: Sourcer disassembly produced 211OMOYP.asm, verified bit-perfect,
moved from zelres2/data to zelres2/code. SAR rebuilds remain bit-perfect.

---

## 4. ~~zelres1 data file ordering~~ ✓ DONE

Confirmed by binary string refs in 100OPDMO.bin: all 28 data chunks had
correct bytes but wrong names. All 28 renamed to match original filenames
(ame.grp, dmaou.grp, hime.grp, etc.). zelres1.sar remains bit-perfect.

---

## 5. ~~zeliad.asm hardcoded interrupt handler offsets~~ ✓ DONE

zeliad.asm uses raw `db 0BAh, xx, xx` to encode `MOV DX, 0x0100/0x0103/0x0106/0x0109`
pointing at game.bin's interrupt handler stubs. These reference `stick.bin`'s
ISR code at fixed offsets in the game segment. If the game segment layout ever
changes, these break.

- Low priority — segment layout is stable
- Could be converted to `EXTRN` references if stick.asm exports them

---

## 6. Shared gvar_* EQU name conflicts across cleaned files (2026-04-23 audit)

During the bulk cleanup of zelres1/2/3, cleanup agents applied the same `gvar_*`
name to different addresses in different files. TASM doesn't see these as
conflicts (each `.asm` compiles independently) and all 98 files are bit-perfect,
but the inconsistency is misleading for human readers.

**Authoritative definitions** are in `working/core/zeliard.inc`:

| Name | Correct value (zeliard.inc) | Files that use wrong value |
|------|-----------------------------|-------------------------------|
| `gvar_timer_ticks` | `0FF08h` | 215DRUGP (0FF1Ah — should be `gvar_frame_timer`) |
| `gvar_key_state` | `0FF0Bh` | 100OPDMO, 106TOWN (0FF29h — should be `gvar_enter_key`) |
| `gvar_game_phase` | `0FF15h` | game.asm (0FF14h — should be `gvar_game_phase_flag` or similar) |
| `gvar_skip_input` | `0FF1Dh` | 250ENDMO (0FF21h — should be a different name) |
| `gvar_volume_b` | `0FF75h` | game.asm, gmega.asm, gmmcga.asm (0FF77h — should be `gvar_volume_c` or similar) |
| `gvar_menu_sel` | `0C006h` | 217KENJP (0FF50h — should be `gvar_frame_count`) |
| `gvar_timer_word` | `0FF50h` | 217KENJP (0FF18h — should be a different name) |

**Low priority**: doesn't break compilation or introduce semantic bugs (each file's
EQU value is correct FOR ITS LOCAL USAGE — only the NAME reuse is confusing).
Fix would be: rename each minority-value EQU to a unique descriptive name per
its actual address role. Safe to do file-by-file since there are no EXTRN
references (each `.asm` is self-contained).
