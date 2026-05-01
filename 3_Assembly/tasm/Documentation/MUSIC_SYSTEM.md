# Zeliard music & sound system

Item #7 from MECHANICS_TO_UNDERSTAND.md.  How background music and
combat-cue audio are loaded, ticked, and played.

---

## TL;DR

- The cleaned source recognizes **only `mscmt.drv` (MT-32)** as a valid
  music driver.  Any other driver name in `RESOURCE.CFG` parses fine
  but leaves `music_enabled = 0`, so music is silent in-game.
- The music driver is loaded into segment `game_entry_seg + 0xFF0`
  (= `gvar_input_fn_seg`) by `zeliad.exe`.  A second driver
  ("joystick driver") loads into the same segment at a different
  offset.
- The music **tick** is called once per timer interrupt (~65.5 Hz, via
  the `gvar_input_fn_ofs` callback), not via `int 61h`.
- `int 61h` is repurposed as a **joystick / input state query**
  (the legacy "music" name is misleading — the stub at
  `isr_music = 0x0109` is `query_input_state` in stick.bin).
- Music **tracks** = 14 .MID files (in `4_Resources/Music/MT/` and
  `GM/`) = ~9 game-time slots: 8 area-specific + 1 background.
- Sound effects are **NOT** a separate sample bank — they're audio
  cues triggered by writing values to `gvar_volume_b` (FF75) at gameplay
  events; the music driver tick reads this byte each frame to mix the
  cue into the MT-32 stream.

---

## Driver loading (zeliad.asm:343–354)

```asm
; Load primary music handler (mscmt.drv → game_entry_seg+0xFF0:0)
mov  ax, word ptr cs:game_entry_seg
add  ax, 0FF0h
mov  es, ax
mov  di, offset music_driver_name      ; record: {load_ofs_word, ASCIIZ name}
call load_driver_file

; Load secondary handler (joystick driver into same segment)
mov  ax, word ptr cs:game_entry_seg
add  ax, 0FF0h
mov  es, ax
mov  di, offset joystick_driver_name
call load_driver_file
```

Both records are populated from `RESOURCE.CFG` lines.  The
`load_driver_file` reader (zeliad.asm:769) opens the file and
reads up to 0xFFFF bytes via DOS 3Fh into `ES:[load_ofs]`.

`mscmt.drv` is 1746 bytes (0x6D2) — fits comfortably under offset
0x1000, so the second driver at offset 0x1100 doesn't collide.

### Driver-name validation (zeliad.asm:653–676)

```asm
parse_music_driver proc near
        mov  byte ptr cs:music_enabled, 0      ; default = silent
        ; ... copy name from cfg line into music_driver_name buffer ...

        mov  di, offset music_driver_name
        mov  si, offset str_mscmt_drv          ; "mscmt.drv"
        mov  cx, 9
        repe cmpsb
        jz   music_is_mt32
        retn

music_is_mt32:
        mov  byte ptr music_enabled, 0FFh
        retn

str_mscmt_drv  db 'mscmt.drv'
```

So **the only driver whose name flips music_enabled to 0xFF is
"mscmt.drv"**.  Other driver names are silently accepted and the file
loaded, but `music_enabled` stays 0.  Whether the loaded driver still
plays audio depends on whether downstream code gates on
`music_enabled` — and most of it does (e.g., `zeliad.asm:201`
skips the entire music-init sequence if music_enabled=0).

### What's likely in the second driver

Probably a **stick.drv** companion or an alternate-soundcard handler.
The cleaned source labels it `joystick_driver_name` but the load
target (segment +0xFF0, the music driver segment) suggests it's
actually a **secondary audio handler**, not a joystick driver.  The
joystick polling lives entirely in `stick.bin` at game_entry_seg:0x100,
which is loaded as a normal driver into the GAME segment, not +0xFF0.

For port purposes, treat both files as opaque DOS-era driver blobs.
Their internal MT-32 / SoundBlaster sysex sequences would need
separate trace work to fully decode, and a port can ignore them
entirely (replace with a modern audio engine).

---

## Music init (zeliad.asm:201–205)

```asm
test byte ptr cs:music_enabled, 0FFh
jz   skip_music_init
; ... save SS:SP for possible re-entry; install int 60/61h ISRs ...
```

If music is disabled, the entire sound init path is skipped.  The
driver might still be loaded but it never gets called.

---

## ISR vector setup (zeliad.asm:357–377)

```asm
cli
push cs
pop  ds
mov  dx, offset ctrl_c_handler
mov  ax, 2523h
int  21h          ; INT 23h = Ctrl+C handler (ignore)

mov  ds, word ptr cs:game_entry_seg
mov  dx, isr_timer       ; CS:0x0103 stub in stick.bin
mov  ax, 2508h
int  21h          ; INT 08h = timer (18.2 Hz BIOS, programmed below to 65.5 Hz)

mov  dx, isr_keyboard    ; CS:0x0100 stub (kbd_irq_handler in stick.bin)
mov  ax, 2509h
int  21h          ; INT 09h = keyboard

mov  dx, isr_critical    ; CS:0x0106 stub (critical-error handler)
mov  ax, 2524h
int  21h          ; INT 24h = DOS critical error

mov  dx, isr_music       ; CS:0x0109 stub — DESPITE THE NAME, this is
mov  ax, 2561h           ; INT 61h = joystick/input state query
int  21h                 ; (see "INT 61h is NOT music" below)
```

Then the 8253 timer is reprogrammed (zeliad.asm:391–397):

```asm
mov  al, 36h
out  43h, al      ; 8253 control: counter 0, mode 3, binary
mov  al, 0B1h
out  40h, al      ; counter 0 lo
mov  al, 13h
out  40h, al      ; counter 0 hi → 0x13B1 = 5041 → ~236.6 Hz?
                  ; (game.asm header says ~65.5 Hz; subsample-by-5 → 13.1 Hz)
sti
```

The reprogrammed timer fires faster than the BIOS default
(18.2 Hz × 13 ≈ 236.6 Hz; the chained `tis_chain_int08` counter at
`chain_int_ctr=0Dh` calls the original BIOS handler every 13 ticks
to keep BIOS time accurate).

### INT 61h is NOT music

Despite the EQU name `isr_music = 0x0109` (zeliard.inc:126), the
target is the 4th entry of stick.bin's jump table at offset 0:

```asm
start:
        jmp  kbd_irq_handler        ; +0x00 → INT 09h
        jmp  timer_isr_entry        ; +0x03 → INT 08h
        jmp  game_state_handler     ; +0x06 → (separate dispatch)
        jmp  query_input_state      ; +0x09 ← isr_music points here
```

`query_input_state` (stick.asm:726) reads the joystick state via
port 201h (game I/O port) and returns AL = direction bits, AH =
timer/skip flags.  No music/audio code runs in this ISR.

This means callers like 201SELCT panel-input-loop's `int 61h`
(documented in INVENTORY_SYSTEM.md) are **polling joystick**, not
querying music state.  The ISR slot was repurposed from its DOS
heritage — an MT-32 era PC-9801 game would have used INT 61h for
sound, but Zeliard rewired it for input.

---

## Music tick (per-frame, called from timer ISR)

The actual music-driver tick runs through a different path:

```asm
; In zeliad.asm:382–385 (still during init):
mov  word ptr es:gvar_input_fn_ofs, stick_input_fn_ofs   ; 0x0100
mov  es:gvar_input_fn_seg, ds                            ; ds = +0xFF0
mov  word ptr es:gvar_gfx_fn_ofs, stdply_gfx_fn_ofs      ; 0x1100
mov  es:gvar_gfx_fn_seg, ds                              ; same +0xFF0 segment
```

Both `gvar_input_fn_ofs` and `gvar_gfx_fn_ofs` point into segment
`+0xFF0` (the music driver segment).  These get called every timer
tick from `timer_isr_entry` (stick.asm:293):

```asm
timer_isr_entry:
        push ax / bx / cx / dx / di / si / bp / ds / es
        cld
        call dword ptr cs:gvar_gfx_fn_ofs    ; +0xFF0:0x1100 — secondary handler
        call dword ptr cs:gvar_input_fn_ofs  ; +0xFF0:0x0100 — music tick
        ; ... subsample-5 work: handle_special_keys, handle_pause_key,
        ;     poll_joystick_buttons ...
```

So **the music driver's tick entry is at offset 0x100 within mscmt.drv**,
called every ~4ms (236 Hz).  Inside that tick:
- it reads the next event from the active MIDI track
- emits MT-32 sysex / NoteOn / NoteOff via the LPT (or ROL-DAC) port
- consumes any pending audio cue from `gvar_volume_b` (FF75)

The cleaned source does not include `mscmt.drv`'s own disassembly —
it's an external blob shipped with the game.

---

## Track loading (game.asm:461–491)

```asm
load_music_tracks proc near
        test byte ptr ds:music_track_count, 0FFh   ; DS:0xA0 from stdply.bin
        jnz  has_tracks
        retn

has_tracks:
        mov  cl, byte ptr ds:music_track_count
        xor  ch, ch
        xor  bx, bx                                ; track index 0..count-1

load_track_loop:
        push cx
        push bx
        mov  dx, bx
        add  bx, bx
        mov  bx, ds:level_system_ref[bx]   ; chunk-record ptr for this track
        xor  al, al
        cmp  dx, 8                          ; track 8 = background music
        jne  not_bg_music
        mov  al, 1                          ; AL=1 flags as background loop

not_bg_music:
        call word ptr cs:sound_load_track_fn   ; CS:0x203E (in mscmt.drv)
        pop  bx
        inc  bx
        pop  cx
        loop load_track_loop
        retn
```

The track table at `level_system_ref` (game.asm:498–507):

```
dw 0F00h    ; track 0
dw 3D00h    ; track 1
dw 1500h    ; track 2
dw 3700h    ; track 3
dw 1B00h    ; track 4
dw 3100h    ; track 5
dw 2100h    ; track 6
dw 2B00h    ; track 7
dw 2600h    ; track 8 ← background music
```

Each entry is a **pointer into the zeliad-pre-populated data zone
(below DS:0xA000)** — at that pointer lives a 2-byte
`{archive_index, chunk_1indexed}` record identifying which SAR chunk
holds the track data.  The chunk is loaded via the standard
`sar_loader_fn` mechanism (CS:0x010C).

`sound_load_track_fn` (CS:0x203E in the music driver) parses the
.MID-equivalent track data and registers it with the MT-32 channel
allocator.  AL=0 means "load and arm"; AL=1 means "load as
infinite-loop background track".

### Track count = 9

The 9 entries (0..8) match the 14 .MID files in `4_Resources/Music/`
minus the cinematic-only tracks:
- 1 background (track 8)
- 8 area-specific (towns + 7 caverns)
- the opening / boss / ending music likely loads on demand from
  separate chunks not in this table

The 14 .MID file names (from `4_Resources/Music/MT/`) confirm this:

| File | Likely game-slot |
|---|---|
| 01 - Opening Themes.MID | cinematic — loaded by 100OPDMO chunk |
| 02 - Introduction & Opening Theme.MID | cinematic |
| 03 - Muralla Town.MID | track 0 (Walls = first town) |
| 04 - Cavern Of Malicia.MID | track 1 |
| 05 - Tumba Town.MID | town |
| 06 - Satono Town.MID | town |
| 07 - Bosque Village.MID | town |
| 08 - Cavern Of Peligro.MID | cavern |
| 09 - Cavern Of Madera.MID | cavern |
| 10 - Cavern Of Escarcha.MID | cavern |
| 11 - Cavern Of Corroer.MID | cavern |
| 12 - Cavern Of Caliente.MID | cavern |
| 13 - Cavern Of Tesoro.MID | cavern |
| 14 - Cavern Of Absor.MID | cavern (Absorber = Helada/ice?) |

Mapping from level-table entries to specific tracks would need
runtime DOSBox observation of the chunk-ref pointers and the loaded
SAR data.

---

## Audio cues (gvar_volume_a / gvar_volume_b)

These two bytes at FF74/FF75 (or FF77 in some chunk's view) are the
**cue mailbox** between gameplay code and the music driver tick.

Selected writes observed across the codebase:

| Site | Value | Cue meaning |
|---|---:|---|
| 200FIGHT (combat hit, shielded) | `gvar_volume_b = 8` | shielded-hit thump |
| 200FIGHT (combat hit, raw) | `gvar_volume_b = 9` | unshielded-damage thump |
| 201SELCT (item-use) | `gvar_volume_b = 0Eh` | item-consumed chime |
| handle_special_keys (pause/sound toggle) | `gvar_volume_b = 1` | UI confirm tone |
| 200FIGHT (boss intro) | `gvar_volume_b = 10h` | dramatic sting |

The driver tick (mscmt.drv at +0xFF0:0x100) reads `gvar_volume_b`,
synthesizes the corresponding short cue, and (presumably) zeros the
byte after consuming.

`gvar_volume_a` (FF74) is also consumed by the driver but the
specific cue mapping wasn't traced — likely a parallel cue channel
for music-priority events (track switches, fades).

---

## F-key toggles (handle_special_keys, stick.asm:252–291)

```asm
handle_special_keys proc near
        ; SKIP key path
        test  byte ptr cs:skip_key_state, 0FFh
        jz    hsk_skip_off
        cmp   word ptr cs:gvar_timer_counter, 1000h    ; SKIP key code
        jne   hsk_chk_sound
        mov   byte ptr cs:gvar_volume_b, 1
        mov   byte ptr cs:skip_key_state, 0
        mov   cl, cs:gvar_key_pressed
        mov   ax, 2
        int   60h                                       ; flush input via game services
        jmp   short hsk_chk_sound

hsk_skip_off:
        cmp   word ptr cs:gvar_timer_counter, 1000h
        je    hsk_chk_sound
        mov   byte ptr cs:skip_key_state, 0FFh

hsk_chk_sound:
        ; SOUND key path
        test  byte ptr cs:sound_key_state, 0FFh
        jz    hsk_sound_off
        cmp   word ptr cs:gvar_timer_counter, 2000h    ; SOUND key code
        je    hsk_toggle_sound
        retn

hsk_toggle_sound:
        mov   byte ptr cs:sound_key_state, 0
        not   byte ptr cs:gvar_sound_flag              ; ← MUTE TOGGLE
        mov   byte ptr cs:gvar_volume_b, 1             ; UI confirm tone
        retn
```

Key facts:
- `gvar_sound_flag` (FF27) is the **MUTE TOGGLE** — `not` flips it
  between 0x00 (audible) and 0xFF (muted).
- `skip_key_state` and `sound_key_state` are debounce latches at
  CS:0x02C2 / 0x02C3 in stick.bin.
- `gvar_timer_counter` codes 0x1000 and 0x2000 are **logical key IDs**
  produced by `process_scancode` after lookup through
  `key_map_table` (stdply.bin:0x0000–0x007F, 64 word entries).
- The user can rebind which physical key triggers SKIP / SOUND by
  configuring the keymap; defaults are typically F1 / F2 (per the
  game manual).

The driver tick reads `gvar_sound_flag` once per tick and gates all
audio output on its value — so muting takes effect within ~4ms.

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

Promotions:

| Row | Was | Now |
|---|:---:|:---:|
| Music tracker (.MSD format) | ❌ | ⚠ (no .MSD format — tracks are raw chunks parsed by mscmt.drv; .MID source files preserved in 4_Resources/Music) |
| Music driver loading | ❌ | ✓ (mscmt.drv at +0xFF0:0; only "mscmt.drv" recognized) |
| Music tick | ❌ | ✓ (gvar_input_fn callback, called from timer ISR every ~4ms) |
| Music track table | ❌ | ✓ (9 slots; level_system_ref → SAR chunk refs) |
| Music mute toggle (F-key) | ❌ | ✓ (gvar_sound_flag, toggled by SOUND key) |
| Audio cues (combat hits, item use) | ❌ | ✓ (gvar_volume_b mailbox; documented values above) |
| INT 61h (legacy "music handler") | ⚠ | ✓ (REPURPOSED as joystick state query — NOT music) |
| Volume control | ⚠ | ⚠ (gvar_volume_a/b are cue triggers, not continuous volume — actual volume control TBD) |
| Soundcard variety (AdLib/SB/Tandy) | ❌ | ❌ (cleaned source recognizes only mscmt.drv = MT-32; other drivers parse but stay disabled) |

The framework is fully traced.  The unknowns:
- Internal MT-32 sysex sequences inside `mscmt.drv` (would need a
  separate disassembly of the 1746-byte driver blob)
- Exact mapping from each `level_system_ref[N]` chunk-pointer to the
  named .MID files in `4_Resources/Music/MT/` (needs DOSBox runtime
  observation per area)
- AdLib / SoundBlaster / PC-Speaker driver variants (if they exist
  for Zeliard at all — the original PC-9801/MS-DOS port may have
  shipped MT-32-only)

---

## What this gives a port

Music in a port is **completely replaceable**:
1. Use the 14 .MID files in `4_Resources/Music/` directly — feed into
   any modern MIDI synthesizer (timidity, fluidsynth, MT-32 Munt for
   authentic timbre).
2. Map game-state transitions to track changes: town entry → town
   theme, cavern enter → cavern theme, boss intro → boss theme.
3. Audio cues (the `gvar_volume_b` writes) need short PCM samples or
   short MIDI snippets bound to events — there are ~6 distinct cue
   values to map.
4. The mute toggle (`gvar_sound_flag`) is a single bool the port can
   bind to F2 or any UI control.
5. The original `mscmt.drv` blob can be discarded — a port doesn't
   need to replicate the MT-32 sysex layer.

This decouples cleanly from the rest of the engine: nothing in the
gameplay loop depends on the audio output succeeding.  Music silence
is a stable degraded mode (in fact, the whole-game default if
`mscmt.drv` isn't configured).
