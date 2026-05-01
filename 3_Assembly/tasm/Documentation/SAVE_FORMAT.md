# Zeliard save-file format (.USR)

Item #6 from MECHANICS_TO_UNDERSTAND.md.  How saved games are written
to disk and read back at next startup.

---

## TL;DR

- **Filename**: `<player-name>.USR` — DOS 8.3, name set by player at the
  Sage's "Record Experience" dialog (joystick letter-picker, max 8 chars)
- **Size**: exactly **256 bytes (0x100)**
- **Content**: a verbatim **byte-for-byte snapshot of the player data
  segment area at DS:0x0000..0x00FF**
- **Loading**: zeliad.exe re-execs itself with the savefile name as a
  command-line argument; on boot the .USR file is loaded INSTEAD of
  `stdply.bin` at the same memory address (game_entry_seg:0x0000).
- **Format**: zero header, zero footer, zero validation.  The bytes
  ARE the in-memory player record at the moment of save.

---

## SAVE flow (in 217KENJP — Sage chunk)

The "Record Experience" menu option in the Sage's dialog runs this
inline x86 code (217KENJP.asm:1161-1196):

```asm
save_name_copy_loop:
        lodsb                          ; copy chars from input buffer...
        or  al, al
        jz  save_name_ext_usr
        stosb
        loop save_name_copy_loop

save_name_ext_usr:
        mov  byte ptr es:[di],   '.'
        mov  byte ptr es:[di+1], 'u'
        mov  byte ptr es:[di+2], 's'
        mov  byte ptr es:[di+3], 'r'
        mov  byte ptr es:[di+4], 0     ; ASCIIZ terminator

        mov  dx, state_name_buf        ; DS:DX = filename string
        mov  cx, 0                     ; (CX=0 here; reset before write)
        mov  ah, 3Ch
        int  21h                       ; DOS 3Ch: create / truncate
        jc   save_disk_error

        push ax                        ; save handle

        mov  dx, 0                     ; ── DS:0x0000 — write source ──
        mov  cx, 100h                  ; ── 256 bytes ──
        mov  bx, ax                    ; BX = file handle
        mov  ah, 40h
        int  21h                       ; DOS 40h: write CX bytes from DS:DX
        pop  ax
        pushf

        mov  bx, ax
        mov  ah, 3Eh
        int  21h                       ; DOS 3Eh: close file
        popf
        jc   save_disk_error
        retn
```

**Key facts**:
- `DS = game segment` (the player data segment) when this runs
- `DX = 0` and `CX = 0x100` → write 256 bytes starting at offset 0
- The save file is therefore the first 256 bytes of the DS segment

The Sage menu also shows "Record Experience" via row text containing
the file mask `*.usr` (line 757 of the chunk).

---

## LOAD flow (in zeliad.exe boot)

When zeliad.exe is invoked with a savefile name on the command line,
it:

1. **Parses the argument**: `parse_command_line` (zeliad.asm:137) reads
   the DOS PSP command-tail; the parser sets `has_savefile = 0xFF` if
   a name was found and stores the name (uppercased) at
   `cmdline_savefile`.
2. **At driver-load time** (zeliad.asm:315-322):

   ```asm
   ; Load player config (stdply.bin or save file) at game_entry_seg:0000h
   mov  di, offset entry_stdply_nosave
   test byte ptr has_savefile, 0FFh
   jz   load_gfx_driver
   mov  di, offset cmdline_savefile      ; <-- use savefile path instead
load_gfx_driver:
   call load_driver_file                 ; loads file at ES:[di] → ES:offset
   ```

   `entry_stdply_nosave` and `cmdline_savefile` are both
   `{offset_word, ASCIIZ_filename}` records.  The offset for both is
   `0x0000` (game_entry_seg's player record area).

3. **load_driver_file** (zeliad.asm:769-792) opens with DOS 3Dh, reads
   up to 0xFFFF bytes via DOS 3Fh, closes via 3Eh.  Whatever bytes are
   in the file overwrite the player record area.

4. **load_mode flag** is passed to game.bin via AX:
   - `AX = 0` for new game (stdply.bin loaded)
   - `AX = 0xFFFF` for load (.USR loaded)

   game.bin uses this flag to branch between
   `start_new_game` and the load path (which goes through opdemo /
   100OPDMO for the save-restore cinematic).

---

## What's persisted (DS:0x0000..0x00FF)

The full 256-byte player record.  Documented fields:

### 0x00..0x7F — pre-record area

This 128-byte region's content isn't in stdply.inc.  Likely:
- temporary scratch / 0-init at game start
- transient gameplay state that doesn't NEED to persist (gets
  re-populated on load)

For port purposes, treat this region as opaque — round-trip-save it
verbatim if you want bit-exact compat.

### 0x80..0x9F — core player fields

| Offset | Size | Field | Notes |
|---|---:|---|---|
| 0x80 | 2 | `map_scroll_col` | cavern X scroll column (init 30) |
| 0x82 | 1 | `map_scroll_row` | cavern Y scroll row |
| 0x83 | 1 | `town_player_col` | screen col in town |
| 0x84 | 1 | `fight_player_col` | screen col in fight |
| 0x85 | 1 | `hero_gold_hi` | 24-bit gold high byte |
| 0x86 | 2 | `hero_gold_lo` | 24-bit gold low word |
| 0x88 | 1 | `hero_bank_hi` | 24-bit banked-gold high byte |
| 0x89 | 2 | `hero_bank_lo` | 24-bit banked-gold low word |
| 0x8B | 2 | `hero_almas` | 16-bit (cap 0xFFFF) |
| 0x8D | 1 | `item_qty_count` | item-use quantity display cache |
| 0x8E | 2 | `item_effect_val` | item-effect-value display cache |
| 0x90 | 2 | `hero_HP` | current HP (16-bit; init 0x50=80) |
| 0x92 | 1 | `sword_type` | equipped sword (1=Training, 6=Enchantment) |
| 0x93 | 1 | `shield_type` | equipped shield (0=none) |
| 0x94 | 2 | `shield_HP` | current shield durability |
| 0x96 | 2 | `char_exp_cap` | XP threshold for current level |
| 0x98 | 1 | `char_speed` | speed stat (Sage-upgraded) |
| 0x99 | 1 | `char_power` | power stat (Sage-upgraded) |
| 0x9A | 1 | `char_abilities` | combat flags (crests?) |
| 0x9B | 1 | `trade_marker_flag` | trade-event marker |
| 0x9C | 1 | `stat_X9C` | VESTIGIAL — saved but unused |
| 0x9D | 1 | `current_magic_spell` | magic spell id |
| 0x9E | 1 | `cur_magic_idx` | currently-selected magic |
| 0x9F | 1 | `stat_X9F` | VESTIGIAL — per-frame zero-clear |

### 0xA0..0xC1 — inventory + per-weapon state

| Offset | Size | Field | Notes |
|---|---:|---|---|
| 0xA0 | 1 | `music_track_count` | tracks loaded for area |
| 0xA1 | 5 | `magic_flags` | one byte per spell (0=lack, FF=have) |
| 0xA6 | 5 | `item_flags` | one byte per consumable |
| 0xAB | 7 | `weap_dur_cur` | per-weapon current durability |
| 0xB2 | 2 | `char_hp_max` | max HP for current level |
| 0xB4 | 7 | `weap_dur_max` | per-weapon max durability |
| 0xBB | 7 | `weapon_flags` | one byte per weapon (0=lack, FF=have) |

### 0xC2..0xCF — combat / progression state

| Offset | Size | Field | Notes |
|---|---:|---|---|
| 0xC2 | 1 | `player_facing` | facing/orientation (87 byte tests in 200FIGHT) |
| 0xC3 | 1 | `boss_intro_flag` | boss intro side flag (bit 6 = boss data) |
| 0xC4 | 1 | `ply_level` | character level (0..15+) |
| 0xC6 | 2 | `heal_pulse_count` | 16-bit heal-pulse counter (+8 HP/tick) |
| 0xC8 | 1 | `ply_tileset` | current tileset index |
| 0xCE | 1 | `cur_magic_idx` | (alias of 0x9E) |
| 0xCF | 1 | `key_count` | normal keys held |

### 0xD0..0xE3 — undocumented / TBD

This region likely holds **area / progression state**: current cavern,
last-visited town, boss-defeat bitmap, Tear-of-Esmesanty count, etc.
Specific addresses haven't been fully traced but the .USR format
includes whatever is here.  For a port, dump and inspect the bytes
of an actual save at known progression points to map the fields.

### 0xE4..0xFF — additional state

| Offset | Size | Field | Notes |
|---|---:|---|---|
| 0xE4 | 1 | `key_count` (alt) | also referenced as key_count by 201SELCT |
| 0xE6 | 1 | `scene_trans_request` | scene-transition request flag |
| 0xE7 | 1 | `gvar_pose_idx` | player pose state (bit7=mode, low7=idx) |
| 0xE8 | 1 | `init_complete_flag` | post-init steady-state |

The remaining bytes (~0xE9..0xFF) are likely:
- More combat-state shadows
- Animation timers
- Music state cache

These get round-trip-saved verbatim so the game resumes mid-tick if
needed.

---

## stdply.bin vs save file

| | stdply.bin (new game) | .USR (save) |
|---|---|---|
| Size | 233 bytes | 256 bytes (0x100) |
| Source | shipped with game | written by Sage |
| Loaded at | `game_entry_seg:0x0000` | same — replaces stdply |
| Initial state | level 1, 80 HP, 30 col, default everything | snapshot of player at save time |
| Bytes 0x00..0x7F | mostly zero / boot defaults | whatever the live game had |
| Bytes 0xE9..0xFF | uninitialized (DOS read short) | whatever the live game had |

When LOADING, the 256-byte save file overwrites the entire 256-byte
player record area, regardless of stdply.bin's smaller footprint.

---

## What this gives a port

A port's save/load can be **literally a `memcpy`**:

```c
// SAVE
write_save_file(filename, player_record_bytes, 256);

// LOAD
read_save_file(filename, player_record_bytes, 256);
```

Provided the port stores its player state in the same 256-byte layout
as Zeliard, save files are interchangeable with the original game.
That's a strong porting-fidelity property — players can transfer
saves in either direction.

If the port chooses a DIFFERENT in-memory layout (cleaner C struct,
JSON, etc.), it can:
1. **Translate on load**: read 256 bytes, parse fields per the table
   above, populate the port's structures
2. **Translate on save**: serialize port structures back into the
   256-byte format on save

Either approach preserves player progress.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:

| Row | Was | Now |
|---|:---:|:---:|
| Save trigger (Sage) | ❌ | ✓ ("Record Experience" menu in 217KENJP) |
| Save filename | ⚠ | ✓ (.USR extension; 8 chars + ext via DOS 8.3) |
| .SAV file format | ❌ | ✓ (256 bytes verbatim from DS:0x0000) |
| What's persisted | ❌ | ✓ (full player record; field map above) |
| Save-state byte at FF33 | ⚠ | ✓ (gvar_save_flag — written separately, NOT part of .USR) |

The save-state byte at FF33 (`gvar_save_flag`) initialized to 5 by
zeliad.exe is in the GAME-STATE FF00-FF7B area, NOT in the player
record's first 256 bytes.  It's NOT persisted in the .USR file.
It's a runtime flag the engine uses to track save-related state.
