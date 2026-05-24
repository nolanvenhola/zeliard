# zeliad.asm Full Pass

`working/core/zeliad.asm` is the executable loader and runtime handoff
contract. It is not a normal gameplay chunk. The web port does not need to
preserve DOS process mechanics literally, but it does need to preserve the
state that `zeliad.exe` creates before `game.bin` starts.

This pass treats the MASM source as the primary readable source because it also
builds bit-perfect output and carries the cleaner semantic labels. The emitted
bytes remain the behavioral oracle.

## Ownership

`zeliad.asm` owns:

- `RESOURCE.CFG` parsing: graphics mode, music driver, joystick driver, and
  joystick enable flag.
- PSP command-line parsing for optional `.USR` save-file startup.
- DOS memory allocation and load ordering for `stdply.bin` or a save file,
  `stick.bin`, `game.bin`, graphics driver, music driver, and joystick driver.
- Initial values for the `0xFF00+` shared runtime globals in the allocated game
  segment.
- Interrupt vector save/install/restore for `INT 08h`, `INT 09h`, `INT 23h`,
  `INT 24h`, `INT 60h`, and `INT 61h`.
- Timer programming: startup divisor `0x13B1`, cleanup divisor `0x0000`.
- Video-mode selection and the final far jump into `game.bin` at `A000h`.
- Exit-message selection and cleanup after `game.bin` returns.

`zeliad.asm` does not own gameplay rules, SAR chunk semantics, or rendering
internals after the driver entry points are installed.

## Procedure Map

| Proc | Source offset | Port relevance | Oracle strategy |
|---|---:|---|---|
| `run_zeliad_main` | `0010h` | Whole startup/shutdown choreography | Contract test, not isolated proc test |
| `flush_keyboard` | `037Bh` | DOS console drain only | Stub/service model or skip |
| `read_config_line` | `0390h` | Canonical line normalization before config parsers | Direct test once DOS read stub exists |
| `parse_graphics_mode` | `03CCh` | Maps config text to `graphics_mode` 0..5 | Direct runtime oracle |
| `parse_music_driver` | `0443h` | Copies driver name; sets MT-32-specific flag for `mscmt.drv` | Direct runtime oracle |
| `parse_joystick_name` | `047Ch` | Copies/clamps joystick driver name | Direct runtime oracle |
| `parse_joystick_enable` | `0493h` | Parses `yes`/`no` into `joystick_enabled` | Direct runtime oracle |
| `find_colon_in_line` | `04DAh` | Shared parser primitive | Covered through parser tests; add direct edge cases later |
| `load_driver_file` | `04EFh` | Loader entry format and binary read destination | Service-contract test |
| `display_file_error` | `052Eh` | DOS user-facing error reporting | Low port relevance |
| `set_video_mode` | `057Ah` | Graphics-mode to BIOS/port-I/O setup mapping | Service-contract test |
| `ctrl_c_handler` | `05F6h` | `IRET` Ctrl+C suppressor | Skip for web port |
| `parse_command_line` | `05F9h` | Optional save-file startup and `.USR` suffix | Direct test with PSP fixture |

## Boot Contract

The high-value web-port contract is the state immediately before:

```asm
jmp dword ptr cs:game_entry_ofs
```

At that checkpoint:

- `game_entry_ofs = A000h`.
- `game_entry_seg` is the allocated DOS memory segment.
- `stdply.bin` or the requested `.USR` has been loaded at offset `0000h`.
- `stick.bin` has been loaded at `0100h`.
- `game.bin` has been loaded at `A000h`.
- The selected `gm*.bin` graphics driver has been loaded at the offset selected
  by `driver_offset_table[graphics_mode]`.
- The music and joystick drivers have been loaded into `game_entry_seg + 0FF0h`.
- Shared globals in the game segment have been initialized, including:
  - `gvar_chunk_load_fn = zeliad_callback_ofs`
  - `gvar_chunk_load_seg = cs`
  - old interrupt vectors at `gvar_old_int08_*` and `gvar_old_int09_*`
  - `gvar_enable_all = FFh`
  - `gvar_key_released = FFh`
  - `gvar_save_flag` / `gvar_anim_speed = 05h`
  - `gvar_gfx_mode = graphics_mode`
  - `gvar_game_phase = mt32_enabled`
  - `gvar_last_key = joystick_enabled`
  - `gvar_game_seg = game_entry_seg + 1000h`
  - pose, scroll, palette, debug/hero-state, input-lock, and disk-swap bytes
    zeroed as written in `run_zeliad_main`.

For the web port, this should become a native initialization fixture, not an
attempt to emulate DOS allocation.

## Driver And File Contracts

The driver table is intentionally compact and slightly overlapping:

| Mode | Config token | `graphics_mode` | Graphics driver entry |
|---|---:|---:|---|
| EGA | `ega` | `0` | `gmega.bin` at `2000h` |
| CGA | `cga` | `1` | `gmcga.bin` at `2000h` |
| CGA 2-color | `cga2` | `2` | `gmcga.bin` at `2000h` |
| HGC | `hgc` | `3` | `gmhgc.bin` at `2000h` |
| MCGA | `mcga` | `4` | `gmmcga.bin` at `2000h` |
| TGA | `tga` | `5` | `gmtga.bin` at `2000h` |

The source expresses these as offsets into a packed `[dw load_ofs][filename]`
blob. Any C model should preserve the observed resolved pairs, not the packed
layout trick unless we are testing loader-byte equivalence.

## First Oracle Set

These scenarios should gate any port of the loader/config layer:

- `zeliad_cfg_graphics_modes`: `ega`, `cga`, `cga2`, `hgc`, `mcga`, `tga`.
- `zeliad_cfg_music_mt32`: `mscmt.drv` copies the name and sets the MT-32 flag.
- `zeliad_cfg_music_non_mt32`: non-`mscmt.drv` drivers copy the name and leave
  the MT-32 flag clear.
- `zeliad_cfg_joystick_name_clamp`: joystick driver name copies at most 15
  bytes and writes a null terminator.
- `zeliad_cfg_joystick_enable`: `yes` sets `FFh`; `no` clears to `00h`.
- `zeliad_psp_save_arg`: non-space command-tail bytes are compacted, copied,
  and `.USR` appended.
- `zeliad_init_game_globals`: startup global bytes match the pre-jump contract.
- `zeliad_load_order`: the loader attempts the expected files in the expected
  order and at the expected offsets.
- `zeliad_video_mode_contract`: mode index selects the expected BIOS mode or
  HGC port-write sequence.

The first five are covered by
`functest/proc_equivalence/test_zeliad_config_parsers.py`.
The PSP save-argument cases are covered by
`functest/proc_equivalence/test_zeliad_command_line.py`.
The pre-`game.bin` global initialization contract is covered by
`functest/proc_equivalence/test_zeliad_init_game_globals.py`.
The file/driver load sequence is covered by
`functest/proc_equivalence/test_zeliad_load_order.py`.

The MASM tree has explicit `entry_cmdline_savefile`, `entry_music_driver`, and
`entry_joystick_driver` labels two bytes before the filename buffers. The
loader therefore resolves the dynamic entries as ordinary
`[dw load_ofs][filename]` records:

- save file: `game_entry_seg:0000h`
- music driver: `(game_entry_seg + 0FF0h):0100h`
- sound/joystick driver: `(game_entry_seg + 0FF0h):1100h`

Use these MASM records for the web-port contract.

## Web-Port Shape

Implement the web side as small, testable units:

- `zeliard_parse_resource_cfg_line(...)`
- `zeliard_parse_resource_cfg(...)`
- `zeliard_parse_startup_save_arg(...)`
- `zeliard_resolve_loader_plan(...)`
- `zeliard_init_game_globals(...)`
- `zeliard_select_video_contract(...)`

Browser startup should consume those results. It should not be the primary
truth source for these behaviors.

## Open Questions

- Whether command-line save-name space compaction matters in real player usage;
  the assembly skips spaces rather than stopping at the first separator.
- Whether bad `RESOURCE.CFG` lines should be modeled as fatal startup errors in
  the web port or surfaced as recoverable diagnostics.
- Whether `mt32_enabled` should be renamed in code to make clear it means
  "configured music driver is `mscmt.drv`", not "music globally enabled".
