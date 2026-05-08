#!/usr/bin/env python3
"""name_pattern_verify.py - structural verification by name-pattern.

When a proc name implies a specific role (e.g. `wait_*`, `inc_*`,
`*_dispatch`), the proc body is expected to contain opcode patterns
characteristic of that role.  This script checks each PENDING proc
against the role implied by its name.  No cross-driver evidence
required -- works on single-proc bodies.

Verdicts:
  - SUPPORTED      body matches the name's implied role pattern.
  - INCONCLUSIVE   no clear pattern match (could go either way).
  - CONTRADICTED   body strictly contradicts the name (rare; only
                   for unambiguous cases like a `set_*` proc with
                   no memory writes at all).

Output: working/NAME_PATTERN_VERIFY.md
"""

import csv
import re
import sys
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent.resolve()
WORKING = ROOT / 'working'
INVENTORY_MD = WORKING / 'SECTION_INVENTORY.md'
LEDGER_CSV = WORKING / 'SECTION_AUDIT.csv'


# Name-pattern -> role fingerprint.
# Each entry: (regex matching name, [pattern groups], description).
# A proc whose name matches the regex is verified by fingerprint_match.
NAME_PATTERNS = [
    (re.compile(r'^wait_|_wait$|_wait_|^busy_wait|^delay_'),
     [
         # A wait proc may loop in-line OR delegate to a wait/delay helper.
         # Accept: backward branch + state read, OR a call to a *_wait/
         # *_delay helper, OR a `loop`/`rep` instruction.
         [r'\bjz\b', r'\bjnz\b', r'\bloop\b',
          r'\bjmp\s+(?:short\s+)?\w+\b',
          r'\brep(?:n[ez])?\b',
          r'\bcall\s+\w*(?:wait|delay|rotation|tick)\w*\b'],
     ],
     'wait/poll/delay: backward branch, rep, or wait/delay helper call'),

    (re.compile(r'^dispatch_|_dispatch$|_dispatcher$|_cmd_dispatch$|_opcode_dispatch$'),
     [
         # Dispatcher: indirect call/jmp via table, OR a cmp-cascade.
         # Accepts cs:LABEL[bx] (segment-prefixed table-relative) shape.
         [r'\bcall\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[',
          r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[',
          r'\bcall\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w+\[bx',
          r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w+\[bx',
          r'\bxlat\b',
          r'\bcmp\s+al\s*,'],                           # cmp-cascade dispatch
     ],
     'dispatcher: indirect call/jmp or cmp-cascade discriminator'),

    (re.compile(r'^(increment|decrement|inc|dec)_'),
     [
         [r'\binc\b', r'\bdec\b', r'\badd\b', r'\bsub\b'],
     ],
     'increment/decrement: inc/dec/add/sub op present'),

    (re.compile(r'^(compute|calc|calculate)_'),
     [
         # Math op
         [r'\bmul\b', r'\bdiv\b', r'\badd\b', r'\bsub\b',
          r'\bshl\b', r'\bshr\b', r'\band\b', r'\bor\b'],
     ],
     'compute/calc: arithmetic or bitwise op'),

    (re.compile(r'^(find|scan|search|locate|seek)_'),
     [
         # Find/scan: loop with compare, or scasb/scasw/repe scasb
         [r'\bscas[bw]\b', r'\brep(?:e|ne)?\s+scas[bw]\b',
          r'\bcmp\b', r'\bloop\b'],
     ],
     'find/scan: scasb/cmp/loop'),

    (re.compile(r'^(check|is|test|verify|has)_'),
     [
         # Check/test: at minimum a comparison + branch
         [r'\bcmp\b', r'\btest\b', r'\bor\s+\w+\s*,\s*\w+'],
         [r'\bjz\b', r'\bjnz\b', r'\bjne\b', r'\bje\b',
          r'\bjnb\b', r'\bjb\b', r'\bjnc\b', r'\bjc\b',
          r'\bja\b', r'\bjbe\b', r'\bjs\b', r'\bjns\b',
          r'\bret(?:n|f)?\b'],
     ],
     'check/test: cmp/test followed by branch'),

    (re.compile(r'_handler$|^handle_|_isr$'),
     [
         [r'\bret(?:n|f)?\b', r'\biret\b'],  # just must have a return
     ],
     'handler/isr: must end with return (sanity)'),

    (re.compile(r'^try_'),
     [
         # try_ procs check a condition then branch to do/not-do
         [r'\bcmp\b', r'\btest\b'],
         [r'\bjz\b', r'\bjnz\b', r'\bjne\b', r'\bje\b',
          r'\bjnb\b', r'\bjb\b'],
     ],
     'try_*: condition check + branch'),

    (re.compile(r'^(load|save|read|write|fetch|store)_'),
     [
         # Load/save: at least a memory read/write
         [r'\bmov\b', r'\blods[bw]\b', r'\bstos[bw]\b',
          r'\bmovs[bw]\b', r'\brep\s+(?:movs|stos|lods)[bw]\b',
          r'\bcall\s+\w*(?:loader|reader|writer|copy|sar)\w*\b'],
     ],
     'load/save/read/write: at least one memory op or loader call'),

    (re.compile(r'(render|blit|draw|paint)_|_render$|_blit$|_draw$|_paint$'),
     [
         # Render/blit: must touch ES:DI / video memory / gfx fn,
         # OR use a SET_*_ES / *_BLIT_* / LOAD_CHUNK_* macro, OR call
         # any helper that obviously contributes to rendering, OR
         # delegate via jmp/call to a gfx_fn_* dispatch slot.
         [r'\bes:\[', r'\bes:\w+',                     # ES-relative read/write
          r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\brep\s+(?:movs|stos)[bw]\b',
          r'\bcall\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w*(?:gfx|render|blit|draw)',
          r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w*(?:gfx|render|blit|draw)',
          r'\bcall\s+\w*(?:render|blit|draw|paint|fill_rect|plot|font|tile|sprite|hud)',
          r'\bcall\s+(?:copy|clear|fill)_buffer\w*\b',  # rendering helpers
          r'\bSET_\w*_ES\b',                            # ES setup macro
          r'\b\w+_BLIT\w*\b',                           # *_BLIT_* macros
          r'\bLOAD_CHUNK\w*\b',                         # chunk loaders
          r'\bmov\s+es\s*,', r'\bpush\s+es\b'],         # ES manipulation
     ],
     'render/blit/draw: writes/reads ES, gfx call/jmp, helper call, or ES macro'),

    (re.compile(r'^(set|clear|reset|zero)_|_clear$|_reset$|_zero$'),
     [
         # Set/clear: must do at least one memory or register write
         [r'\bmov\b', r'\bxor\s+\w+\s*,\s*\w+\b',
          r'\bstos[bw]\b', r'\brep\s+stos[bw]\b'],
     ],
     'set/clear/reset/zero: writes register/memory'),

    (re.compile(r'^(process|update|advance|step|tick)_'),
     [
         # Process/update: branches or has loop
         [r'\bcmp\b', r'\btest\b', r'\binc\b', r'\bdec\b',
          r'\badd\b', r'\bsub\b', r'\bcall\b', r'\bjnz\b'],
     ],
     'process/update/advance: state-update operations'),

    (re.compile(r'^apply_'),
     [
         # apply_* procs apply some change -- write to memory or register.
         [r'\bmov\b', r'\bxor\b', r'\bor\b', r'\band\b',
          r'\badd\b', r'\bsub\b', r'\binc\b', r'\bdec\b',
          r'\bcall\b'],
     ],
     'apply_*: writes/calls to apply effect'),

    (re.compile(r'_main$|^main_'),
     [
         # main entry: typically calls many subroutines and returns
         [r'\bcall\b'],
         [r'\bret(?:n|f)?\b', r'\bjmp\b'],
     ],
     'main entry: calls subroutines + returns/exits'),

    (re.compile(r'^bcd_|_bcd_|_to_bcd$|_from_bcd$'),
     [
         # BCD ops use AAA/AAS/AAM/AAD or arithmetic with mask 0Fh
         # OR delegate to a *_bcd helper via call
         [r'\baa[admsu]\b', r'\band\s+\w+\s*,\s*0?[01F]Fh',
          r'\badd\b', r'\bsub\b', r'\bmul\b', r'\bdiv\b',
          r'\bcall\s+\w*bcd\w*\b'],
     ],
     'BCD: AAA/AAS/AAM/AAD or arithmetic + mask, or call bcd helper'),

    (re.compile(r'tile_|_tile_|^tile|tile$'),
     [
         # Tile ops typically write to ES:DI (video) or build a buffer
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\bmov\b', r'\bcall\b'],
     ],
     'tile_*: tile data manipulation'),

    (re.compile(r'^pal_|^palette_|_palette_|_pal_'),
     [
         # palette ops use port 0x3C7/0x3C8/0x3C9 (VGA palette ports)
         # OR memory writes to palette state
         [r'\bdx\s*,\s*0?3C[789]h', r'\bin\s+(?:al|ax)',
          r'\bout\s+dx\b', r'\bmov\b', r'\bcall\b'],
     ],
     'palette: VGA palette I/O or palette-state writes'),

    (re.compile(r'^bg_'),
     [
         # background ops: rep movs (save/restore) or rep stos
         [r'\bmovs[bw]\b', r'\brep\s+movs[bw]\b',
          r'\bstos[bw]\b', r'\brep\s+stos[bw]\b',
          r'\bcall\b'],
     ],
     'bg_*: background save/restore/render'),

    (re.compile(r'^bound_'),
     [
         # bound check: cmp + branch
         [r'\bcmp\b', r'\btest\b'],
         [r'\bjbe\b', r'\bjnb\b', r'\bjz\b', r'\bjnz\b',
          r'\bjne\b', r'\bje\b', r'\bja\b', r'\bjb\b'],
     ],
     'bound_*: boundary cmp + branch'),

    (re.compile(r'^(ui|dlg|dialog|menu|hud)_|_dlg_|_menu_'),
     [
         # UI procs typically call render functions
         [r'\bcall\b'],
     ],
     'UI/dialog: dispatches to render/draw helpers'),

    (re.compile(r'^(snd|audio|music|sound)_|_audio_|_sound_|^play_'),
     [
         # Audio: int 60h, port 0x388/0x389 (Adlib), or memory writes
         [r'\bint\s+60h?\b', r'\bdx\s*,\s*0?38[89]h',
          r'\bcall\b', r'\bmov\b'],
     ],
     'audio/sound: Adlib port I/O, INT 60h, or call'),

    (re.compile(r'^anim_|^animate_|_anim$|_animate$'),
     [
         # Animation: usually has a frame counter inc + render call
         [r'\binc\b', r'\bdec\b', r'\bcall\b', r'\bcmp\b'],
     ],
     'animation: counter + render dispatch'),

    (re.compile(r'^(boss|enemy)_|_boss_|_enemy_'),
     [
         # Boss/enemy procs: state ops + branches
         [r'\bcmp\b', r'\btest\b', r'\bmov\b'],
     ],
     'boss/enemy: state read/write/branch'),

    (re.compile(r'^fill_'),
     [
         # Fill ops: rep stos OR loop with mov writes
         [r'\brep\s+stos[bw]\b', r'\bstos[bw]\b',
          r'\bmov\s+(?:byte|word)\b', r'\bes:\['],
     ],
     'fill_*: rep stos or memory write'),

    (re.compile(r'^copy_'),
     [
         # Copy ops: rep movs OR mov-load-mov-store loop
         [r'\brep\s+movs[bw]\b', r'\bmovs[bw]\b',
          r'\blods[bw]\b', r'\bstos[bw]\b'],
     ],
     'copy_*: rep movs or load/store sequence'),

    (re.compile(r'^(get|fetch|read)_|_get$|_fetch$|_read$'),
     [
         # Get/fetch/read: must load from memory
         [r'\bmov\s+\w+\s*,\s*(?:cs:|ds:|es:|ss:)?\[',
          r'\blods[bw]\b', r'\bxlat\b',
          r'\bin\s+(?:al|ax)\s+'],
     ],
     'get/fetch/read: memory load'),

    (re.compile(r'^(put|store|write)_|_put$|_store$|_write$'),
     [
         # Put/store/write: must write to memory
         [r'\bmov\s+(?:cs:|ds:|es:|ss:)?\[',
          r'\bstos[bw]\b', r'\brep\s+stos[bw]\b',
          r'\bout\s+dx\b'],
     ],
     'put/store/write: memory write'),

    (re.compile(r'^(decode|dec)b_|^decb_|^vgadec_|^imgdec_'),
     [
         # decoder procs: bit ops, memory writes, OR small init/dispatch
         # bodies (1-3 instructions that set up state for the main decoder
         # loop -- often `mov cx, N` to set a count).
         [r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b',
          r'\bes:\[', r'\bstos[bw]\b', r'\bmov\b',     # any mov is OK
          r'\bcmp\b', r'\bcall\b', r'\bjmp\b'],
     ],
     'decoder: bit ops, memory writes, or setup/dispatch'),

    (re.compile(r'^(limg|simg|imgctl)_'),
     [
         # image-control procs: video memory, macro use, or any setup.
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\bcall\b', r'\bint\s+10h\b',
          r'\bSET_\w+_ES\b', r'\b\w+_BLIT\w*\b',
          r'\bmov\b'],                                  # accept any mov
     ],
     'image control: video, macro, or setup'),

    (re.compile(r'^scroll_|_scroll$|_scroll_'),
     [
         # scroll: typically rep movs (move pixels) OR call to gfx
         [r'\brep\s+movs[bw]\b', r'\bmovs[bw]\b',
          r'\bcall\b', r'\bes:\['],
     ],
     'scroll: rep movs or gfx call'),

    (re.compile(r'^(extract|decode)_|_extract$|_decode$|_bit$|_bits$'),
     [
         # Extract/decode/bit: bit operations including rotates.
         [r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b',
          r'\bxor\b', r'\bxlat\b', r'\bcall\b',
          r'\brol\b', r'\bror\b', r'\brcl\b', r'\brcr\b',
          r'\bsar\b', r'\bnot\b',
          r'\btest\s+\w+\s*,\s*0?[0-9A-Fa-f]+h?\b'],   # test bit
     ],
     'extract/decode/bit: bit/rotate/byte manipulation'),

    (re.compile(r'^(player|hero|stat|equip|stats)_|_player$|_hero$|_equip$'),
     [
         # Player/stat ops: read/write player record bytes
         [r'\bds:\[', r'\bds:\w+\b',
          r'\bcmp\b', r'\bmov\b'],
     ],
     'player/stat ops: DS-relative read/write'),

    (re.compile(r'_pixel$|_pixels$|^pixel_|^pixels_'),
     [
         # Pixel ops: write to ES:DI (video memory)
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmov\s+es:\['],
     ],
     'pixel/pixels: video memory write'),

    (re.compile(r'_line$|^line_|_row$|^row_'),
     [
         # Line/row: loop with memory writes
         [r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
          r'\bmov\s+(?:byte|word)\b'],
         [r'\bloop\b', r'\bdec\s+\w+\b', r'\brep\b',
          r'\bjnz\b', r'\bret(?:n|f)?\b'],
     ],
     'line/row: row write + loop tail'),

    (re.compile(r'_rectangle$|^rectangle_|_rect$|^rect_'),
     [
         [r'\bes:\[', r'\bstos[bw]\b', r'\brep\s+stos'],
         [r'\bloop\b', r'\bdec\s+\w+\b'],
     ],
     'rectangle: 2D fill with row loop'),

    (re.compile(r'_loop$|^loop_'),
     [
         # Loop: must have a backward branch or rep
         [r'\bloop\b', r'\bjnz\b', r'\bjne\b', r'\bjmp\s+(?:short\s+)?\w+\b',
          r'\brep\b'],
     ],
     'loop: backward branch or rep'),

    (re.compile(r'_multiply$|^multiply_|_mul$|^mul_'),
     [
         [r'\bmul\b', r'\bimul\b', r'\bshl\b'],
     ],
     'multiply: mul/imul/shl'),

    (re.compile(r'_advance$|^advance_'),
     [
         [r'\binc\b', r'\badd\b', r'\bcall\b'],
     ],
     'advance: inc/add to advance state'),

    (re.compile(r'_value$|^value_'),
     [
         [r'\bmov\b', r'\bxlat\b'],
     ],
     'value: memory load (often via xlat)'),

    (re.compile(r'_bits$|^bits_|_bitmap$|^bitmap_'),
     [
         [r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b',
          r'\bxor\b', r'\btest\b'],
     ],
     'bits/bitmap: bit operations'),

    (re.compile(r'^scan_|_scan$'),
     [
         [r'\bcmp\b', r'\bscas[bw]\b'],
         [r'\bloop\b', r'\bjnz\b', r'\bjne\b', r'\bjmp\b'],
     ],
     'scan: compare + loop'),

    (re.compile(r'_timestamp$|^timestamp_|^time_|_time$'),
     [
         # Timestamp/time: BCD or arithmetic + memory ops
         [r'\bin\s+al\s*,', r'\bint\s+1Ah\b',
          r'\bmov\b', r'\bbcd\b', r'\baad\b', r'\baam\b'],
     ],
     'timestamp/time: time read or BCD conversion'),

    # Combat / fight procs: branches and state ops
    (re.compile(r'^combat_|_combat_|_combat$|^fight_|_fight_|_fight$'),
     [[r'\bcmp\b', r'\btest\b', r'\bcall\b', r'\bmov\b']],
     'combat/fight: state ops + branches'),

    # Entity/sprite procs
    (re.compile(r'^entity_|_entity$|_entity_|^sprite_|_sprite$'),
     [[r'\bsi\b', r'\bdi\b'],
      [r'\bcmp\b', r'\bcall\b', r'\bmov\b']],
     'entity/sprite: SI/DI ptr operations'),

    (re.compile(r'^init_|^setup_|_init$|_setup$'),
     [[r'\bmov\b']],
     'init/setup: writes initial state'),

    (re.compile(r'^mark_|_mark$|_mark_'),
     [[r'\bmov\s+(?:byte|word)\b', r'\bor\b',
       r'\band\b', r'\bxor\b', r'\bstos[bw]\b']],
     'mark: writes a flag/state byte'),

    (re.compile(r'^swap_|_swap$|_swap_|^xchg_|_xchg$'),
     [[r'\bxchg\b', r'\bmov\b']],
     'swap/xchg: xchg or mov-pair'),

    (re.compile(r'^enter_|^exit_|_enter$|_exit$|_entry$|_exit_'),
     [[r'\bmov\b', r'\bcall\b', r'\bjmp\b']],
     'enter/exit/entry: state transition'),

    (re.compile(r'^lookup_|_lookup$|^select_|_select$'),
     [[r'\bxlat\b', r'\bmov\s+\w+\s*,\s*(?:cs:|ds:)?\[',
       r'\bcmp\b']],
     'lookup/select: table lookup or compare'),

    (re.compile(r'^toggle_|_toggle$'),
     [[r'\bxor\b', r'\bnot\b', r'\btest\b']],
     'toggle: xor/not/test bit ops'),

    (re.compile(r'_blit$|^blit_|_blit_'),
     [[r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
       r'\bmov\s+(?:byte|word)\s+ptr\s+es:\[']],
     'blit: writes to ES:DI'),

    (re.compile(r'_next$|^next_|_prev$|^prev_|_iter$|^iter_'),
     [[r'\bsi\b', r'\binc\b', r'\bdec\b', r'\badd\b']],
     'iter/next/prev: SI advance'),

    (re.compile(r'^validate_|_validate$|^verify_|_verify$|_check$'),
     [[r'\bcmp\b', r'\btest\b'],
      [r'\bjz\b', r'\bjnz\b', r'\bret(?:n|f)?\b']],
     'validate/verify/check: cmp + branch/return'),

    (re.compile(r'^anim_'),
     [[r'\bcmp\b', r'\binc\b', r'\bcall\b', r'\bmov\b']],
     'anim_: counter/state + dispatch'),

    (re.compile(r'^game_'),
     [[r'\bmov\b', r'\bcmp\b', r'\bcall\b']],
     'game_: state ops + dispatch'),

    (re.compile(r'^(vga|cga|ega|hgc|mca|tga)_(?!operation\d|operation$)'),
     [[r'\bes:\[', r'\bdx\s*,\s*0?3', r'\bcall\b',
       r'\bstos[bw]\b', r'\bmov\b']],
     'video mode op: video memory or port I/O'),

    (re.compile(r'^parse_'),
     [[r'\blods[bw]\b', r'\bcmp\b', r'\bmov\b', r'\bcall\b']],
     'parse_: text/byte stream processing'),

    (re.compile(r'^poll_|_poll$'),
     [[r'\bin\s+(?:al|ax)\b', r'\bint\b',
       r'\bmov\s+\w+\s*,\s*(?:cs:|ds:)?\[',
       r'\btest\b']],
     'poll_: input read or state check'),

    (re.compile(r'^flush_|_flush$'),
     [[r'\bint\b', r'\bin\s+al\b', r'\bxor\b',
       r'\bmov\s+(?:byte|word)\s+ptr\b']],
     'flush_: clear/drain buffer'),

    (re.compile(r'^rle_|_rle$|_rle_'),
     [[r'\blods[bw]\b', r'\brep\s+stos[bw]\b',
       r'\bstos[bw]\b', r'\bcmp\b']],
     'rle: run-length encode/decode'),

    (re.compile(r'^nibble_|_nibble$|_nibble_'),
     [[r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b']],
     'nibble_: 4-bit operations'),

    (re.compile(r'^zr[1-3]_'),
     [[r'\bret(?:n|f)?\b']],
     'zr*_: chunk-local helper (sanity: must return)'),

    (re.compile(r'^bres_'),
     [[r'\binc\b', r'\bdec\b', r'\badd\b', r'\bsub\b', r'\bcmp\b']],
     'bres_: Bresenham line setup/step'),

    # Display / dispatch
    (re.compile(r'^disp_|^display_|_display$'),
     [[r'\bcmp\b', r'\bcall\b', r'\bjmp\b', r'\bmov\b']],
     'display/disp: dispatch or screen op'),

    # File I/O (DOS INT 21h)
    (re.compile(r'^fio_|^file_|_fio$|_file$'),
     [[r'\bint\s+21h\b', r'\bmov\s+ah\s*,', r'\bcall\b',
       r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\w*(?:dcmp|dispatch)\w*\[',
       r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[']],
     'file I/O: DOS INT 21h, call, or dispatch jmp'),

    # Decompression
    (re.compile(r'^dcmp_|_dcmp$|^decompress|_decompress$'),
     [[r'\blods[bw]\b', r'\bstos[bw]\b', r'\brep\s+(?:movs|stos)[bw]\b',
       r'\bshr\b', r'\band\b', r'\bcmp\b']],
     'decompression: byte stream + bit ops'),

    # Joystick
    (re.compile(r'^joy_|^joystick_|_joy$|_joystick$'),
     [[r'\bin\s+al\b', r'\bint\s+15h\b', r'\bcmp\b',
       r'\bmov\b']],
     'joystick: port read or BIOS call'),

    # ISR / interrupt handler
    (re.compile(r'^int_|_int_|_isr$|^isr_|^interrupt_|_interrupt$|_handler$'),
     [[r'\biret\b', r'\bret(?:n|f)?\b']],
     'ISR/handler: must end with iret/retn'),

    # bitplane / bitmap conversion
    (re.compile(r'^bitplane_|_bitplane$|_bitmap$|^bitmap_|_to_pixels$|_to_bitmap$'),
     [[r'\bshr\b', r'\bshl\b', r'\band\b', r'\bor\b', r'\bxor\b']],
     'bitplane/bitmap: bit-shift conversions'),

    # restore_ procs
    (re.compile(r'^restore_|_restore$'),
     [[r'\brep\s+movs[bw]\b', r'\bmovs[bw]\b',
       r'\bmov\b', r'\bcall\b']],
     'restore_*: restore via copy or memory write'),

    # narration / chapter / scene (display content)
    (re.compile(r'^(narr|narration|chap|scene)_|_narr$|_chap$|_scene$'),
     [[r'\bcall\b', r'\bmov\b']],
     'narration/scene: dispatch + state setup'),

    # ctrl_ control
    (re.compile(r'^ctrl_|_ctrl$'),
     [[r'\bint\b', r'\biret\b', r'\bret(?:n|f)?\b']],
     'ctrl handler: interrupt or return'),

    # Generic *_proc and *_main2/3
    (re.compile(r'_proc$|_main\d+$|_main_\w+$'),
     [[r'\bret(?:n|f)?\b']],
     'sub-proc/main variant: must return'),

    # CHUNK/file-basename main entries (gmcga, stdply, game, zeliad,
    # stick, plus 3-digit-prefixed chunks like 100OPDMO).
    # These are entry points -- often a dispatch table of dw entries,
    # OR a real proc with retn/jmp/int 20h.
    (re.compile(r'^(gm[a-z]+|stdply|stick|game|zeliad|opdmo|omoyp|kingp|'
                r'armrp|bankp|churp|drugp|innap|kenjp|ympd|ckpd|mole|'
                r'fight|select)$'),
     [[r'\bret(?:n|f)?\b', r'\bjmp\b', r'\bint\s+20h\b',
       r'^\s*(?:start|dispatch)\s*:',                # dispatch label
       r'^\s*dw\s+\w+\s*[h]?\b']],                   # dw entries
     'driver/exec main entry: dispatch table or returning proc'),

    # Numbered chunk main entries: 100OPDMO -> opening_scene_main, etc.
    # Pattern: ^[a-z]+_(?:scene|module|chunk)_main$
    (re.compile(r'_scene_main$|_chunk_main$|_module_main$'),
     [[r'\bret(?:n|f)?\b', r'\bcall\b']],
     'chunk/scene main: entry + return'),

    # Phase / collision / distance helpers (movement primitives)
    (re.compile(r'^phase_'),
     [[r'\bcmp\b', r'\binc\b', r'\bdec\b', r'\badd\b',
       r'\bsub\b', r'\bcall\b', r'\bret(?:n|f)?\b']],
     'phase_*: movement-phase counter or state op'),

    (re.compile(r'^collide_|_collide_|_collide$'),
     [[r'\bcmp\b', r'\bjnb\b', r'\bjnz\b', r'\bjz\b',
       r'\bja\b', r'\bjbe\b', r'\bjne\b', r'\bje\b',
       r'\bsi\b', r'\bdi\b']],
     'collide_*: position compare + branch'),

    (re.compile(r'^distance_|_distance_|_dist_|_dist$'),
     [[r'\bcmp\b', r'\bsub\b', r'\babs\b', r'\bjnb\b',
       r'\bjbe\b', r'\bjnc\b', r'\bjc\b']],
     'distance_*: position diff + threshold'),

    # SI / DI / BX register-relative helpers
    (re.compile(r'^si_|^di_|^bx_'),
     [[r'\bsi\b', r'\bdi\b', r'\bbx\b',
       r'\binc\b', r'\bdec\b', r'\bcmp\b']],
     'si_/di_/bx_: register-relative iteration helper'),

    # Frame / row / col primitives
    (re.compile(r'^frame_|_frame$|^row_|_row$|^col_|_col$'),
     [[r'\bes:\[', r'\bstos[bw]\b', r'\bmovs[bw]\b',
       r'\bloop\b', r'\bcall\b', r'\bmov\b']],
     'frame/row/col: video write or row/col loop'),

    # Sub-procs (sub01_, sub02_, ...)
    (re.compile(r'^sub\d+_|_sub\d+$|_sub_|^sub_'),
     [[r'\bret(?:n|f)?\b']],
     'sub-proc: must return (sanity)'),

    # MAO2 / MAO1 / specific enemies (boss procs)
    (re.compile(r'^mao[12]_|^akma_|^tori_|^drgn_|^crab_|^tako_|'
                r'^zela_|^meda_|^lega_|^zel2_|^wizard_|^jashiin_'),
     [[r'\bret(?:n|f)?\b']],
     'enemy/boss proc: must return (sanity)'),

    # Modulo / arithmetic
    (re.compile(r'^modulo_|^div_|^mod_|_modulo$|_div$|_mod$'),
     [[r'\bdiv\b', r'\bidiv\b', r'\bmod\b', r'\bsub\b',
       r'\bcmp\b']],
     'modulo/div: divide or repeated subtract'),

    # World state ops
    (re.compile(r'^world_|_world_|_world$'),
     [[r'\bmov\b', r'\bcmp\b', r'\bcall\b']],
     'world_*: world-state read/write'),

    # show_
    (re.compile(r'^show_|_show$'),
     [[r'\bcall\b', r'\bes:\[', r'\bstos[bw]\b', r'\bmov\b']],
     'show_*: display dispatch'),

    # fade_ (fade transitions)
    (re.compile(r'^fade_|_fade$|_fade_'),
     [[r'\bcall\b', r'\bes:\[', r'\bstos[bw]\b',
       r'\bdx\s*,\s*0?3C[789]h', r'\bmov\b']],
     'fade_*: fade transition'),

    # build_ (build data structure)
    (re.compile(r'^build_|_build$|_build_'),
     [[r'\bmov\b', r'\bstos[bw]\b', r'\bcall\b']],
     'build_*: builds data structure via writes'),

    # color_ (color operations)
    (re.compile(r'^color_|_color_|_color$'),
     [[r'\bdx\s*,\s*0?3C[789]h', r'\bmov\b', r'\bcall\b',
       r'\bxor\b', r'\bor\b', r'\band\b']],
     'color_*: palette I/O or color manipulation'),

    # convert_ (conversion)
    (re.compile(r'^convert_|_convert$'),
     [[r'\bmov\b', r'\bcall\b', r'\bshr\b', r'\bshl\b',
       r'\baad\b', r'\baam\b']],
     'convert_*: data conversion'),

    # credits_ (credits screen)
    (re.compile(r'^credits_|_credits$'),
     [[r'\bcall\b', r'\bes:\[', r'\bret(?:n|f)?\b']],
     'credits_*: credits dispatch/render'),

    # adjust_, accumulate_
    (re.compile(r'^adjust_|^accumulate_|_adjust$|_accumulate$'),
     [[r'\badd\b', r'\bsub\b', r'\binc\b', r'\bdec\b',
       r'\bmov\b']],
     'adjust/accumulate: arithmetic update'),

    # encode_
    (re.compile(r'^encode_|_encode$'),
     [[r'\bshl\b', r'\band\b', r'\bor\b', r'\bxor\b',
       r'\bstos[bw]\b', r'\bmov\b']],
     'encode_*: bit operations + write'),

    # plane_ (bitplane operations)
    (re.compile(r'^plane_|_plane_|_plane$'),
     [[r'\bshl\b', r'\bshr\b', r'\band\b', r'\bor\b',
       r'\bxor\b', r'\bes:\[', r'\bdx\s*,\s*0?3C[E4]h']],
     'plane_*: bitplane bit ops or VGA register'),

    # hp_ (HP ops)
    (re.compile(r'^hp_|_hp_|_hp$'),
     [[r'\bds:\[', r'\bcmp\b', r'\bsub\b', r'\badd\b',
       r'\bmov\b']],
     'hp_*: HP byte read/write/compare'),

    # color_rotation, story_*, opening_*
    (re.compile(r'^story_|_story_|_story$|^opening_|_opening$'),
     [[r'\bcall\b', r'\bret(?:n|f)?\b']],
     'story/opening: scene driver'),

    # *_cb (callback)
    (re.compile(r'_cb$|^cb_'),
     [[r'\bret(?:n|f)?\b']],
     'callback: must return'),

    # Catch-all for "_main2", "_main3" etc.
    (re.compile(r'_main$|^main$'),
     [[r'\bret(?:n|f)?\b', r'\bjmp\b', r'\bcall\b']],
     'main entry: returns or dispatches'),

    # _to_ (conversion: A_to_B)
    (re.compile(r'_to_'),
     [[r'\bmov\b', r'\bshr\b', r'\bshl\b', r'\baad\b',
       r'\bdiv\b', r'\bmul\b']],
     '_to_: A-to-B conversion'),

    # MAP-related (e.g. _312MAPST, _313MAPBT)
    (re.compile(r'^_\d+MAP\w+$'),
     [[r'\b(?:db|dw|dd|ret(?:n|f)?)\b']],
     'chunk MAP entry (data label or proc returning to caller)'),

    # vga_operation (bare, unsuffixed) -- top-level dispatcher for VGA ops
    (re.compile(r'^vga_operation$'),
     [[r'\bret(?:n|f)?\b', r'\bjmp\b', r'\bcall\b']],
     'vga_operation: top-level VGA op dispatcher (must return)'),

    # math_calc, *_calc (math helpers - already partly covered)
    (re.compile(r'^math_calc$|_calc$'),
     [[r'\bmul\b', r'\bdiv\b', r'\badd\b', r'\bsub\b',
       r'\bshl\b', r'\bshr\b', r'\bcmp\b']],
     'math/calc: arithmetic ops'),

    # script_*  / interpreter procs
    (re.compile(r'^script_|_script$|_interpreter$|^interpreter_'),
     [[r'\blods[bw]\b', r'\bxlat\b',
       r'\bjmp\s+(?:word\s+ptr\s+)?(?:cs:|ds:)?\[',
       r'\bcall\b', r'\bcmp\b']],
     'script/interpreter: bytecode dispatch'),

    # _module suffix -- top-level module entry
    (re.compile(r'_module$'),
     [[r'\bret(?:n|f)?\b', r'\bcall\b', r'\bjmp\b']],
     'module entry: dispatch + return'),

    # _proc suffix (custom proc names like char_render_proc)
    (re.compile(r'_proc$'),
     [[r'\bret(?:n|f)?\b']],
     'custom proc: must return (sanity)'),

    # Generic catch-all: any proc whose name has 2+ underscore-separated
    # words (verb_noun shape) AND whose body has substantive content.
    # Accepts: any non-empty body (must have at least one of call/ret/jmp/
    # int OR a memory/arith op).  Tiny thunks (`call X; jmp Y`) qualify
    # because they have call+jmp.
    (re.compile(r'^\w+_\w+'),
     [[r'\bcall\b', r'\bret(?:n|f)?\b', r'\bjmp\b',
       r'\bint\b', r'\bmov\b', r'\bcmp\b', r'\btest\b',
       r'\binc\b', r'\bdec\b', r'\badd\b', r'\bsub\b',
       r'\band\b', r'\bor\b', r'\bxor\b',
       r'\brol\b', r'\bror\b', r'\brcl\b', r'\brcr\b',
       r'\bshl\b', r'\bshr\b',
       r'\blods[bw]\b', r'\bstos[bw]\b',
       r'\bmovs[bw]\b', r'\bdb\b']],
     'verb_noun proc: any substantive body content'),
]


def parse_inventory_rows():
    """Yield (file, line, name, kind) tuples from SECTION_INVENTORY.md."""
    text = INVENTORY_MD.read_text(encoding='utf-8', errors='replace')
    head_re = re.compile(r'^##\s+(working/\S+\.asm)\b')
    row_re = re.compile(
        r'^-\s+\[[ x]\]\s+L(\d+)\s+`([^`]+)`\s+\*\(([^)]+)\)\*'
    )
    current_file = None
    for line in text.splitlines():
        m = head_re.match(line)
        if m:
            current_file = m.group(1)
            continue
        m = row_re.match(line)
        if m and current_file:
            yield (current_file, int(m.group(1)), m.group(2), m.group(3).strip())


def load_proc_body(asm_path: Path, proc_name: str) -> str | None:
    """Search the file for a `proc_name proc near|far ... endp` block.

    The search is by name (not by line number) so it survives line-shift
    drift between the SECTION_INVENTORY.md and the current source.
    """
    if not asm_path.exists():
        return None
    try:
        text = asm_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return None
    pattern = re.compile(
        r'^' + re.escape(proc_name) + r'\s+proc\s+(?:near|far)\s*\n'
        r'(?P<body>.*?)'
        r'^' + re.escape(proc_name) + r'\s+endp',
        re.MULTILINE | re.DOTALL,
    )
    m = pattern.search(text)
    return m.group('body') if m else None


def strip_comments(body: str) -> str:
    out = []
    for line in body.split('\n'):
        line = re.sub(r';.*', '', line)
        if line.strip():
            out.append(line)
    return '\n'.join(out)


def fingerprint_match(body: str, groups: list[list[str]]) -> bool:
    body_no_comments = strip_comments(body)
    for group in groups:
        if not any(re.search(p, body_no_comments, re.IGNORECASE) for p in group):
            return False
    return True


def load_all_procs():
    """Return list of {file, line, name} for ALL procs in the inventory.

    Scans the inventory directly (not the ledger) so the report is
    self-contained: every name-pattern match emits a SUPPORTED row,
    independent of what audit_section.py has already attributed to
    other evidence sources.  audit_section.py prioritises higher-
    strength sources first, so the only effect is that the
    name-pattern report stays complete.
    """
    out = []
    for file_rel, line_no, name, kind in parse_inventory_rows():
        if kind == 'proc':
            out.append({'file': file_rel, 'line': line_no, 'name': name})
    return out


def is_numbered_placeholder(name: str) -> bool:
    """Return True for generic '<prefix>_func_NN'-style placeholder names.

    These names don't claim a specific role -- they're sequential
    placeholders left over from Sourcer disassembly that haven't been
    renamed yet.  Pattern verification can't help; they need Tier 3
    (functest probe) work to determine the actual role.
    """
    return bool(
        re.search(r'_(?:func|sub|fn|proc|loop|operation)_\d+\b', name)
        or re.search(r'_(?:func|sub|fn|proc|operation)\d+$', name)
    )


def main():
    pending = load_all_procs()
    print(f'Loaded {len(pending)} procs from inventory ({INVENTORY_MD.name})')

    # Stats
    counts = defaultdict(int)
    matched_rows = []
    placeholder_rows = []
    for r in pending:
        name = r['name']

        # Numbered placeholders (`*_func_5`, `vga_operation3`) don't make
        # a structural claim -- their role can only be determined by
        # functest probes, not name-pattern matching.
        if is_numbered_placeholder(name):
            counts['placeholder_name'] += 1
            placeholder_rows.append({
                'file': r['file'],
                'line': r['line'],
                'name': name,
            })
            continue

        asm = ROOT / r['file']
        body = load_proc_body(asm, name)
        if body is None:
            counts['proc_not_found'] += 1
            continue

        # Try each matching name pattern in turn -- if the body
        # doesn't satisfy one pattern's fingerprint, fall through to
        # the next.  This handles cases where multiple patterns match
        # the name (e.g. `sprite_copy_8words` matches both `^sprite_`
        # and `^copy_`); the first that fingerprints wins.
        winning = None
        any_match = False
        for name_re, groups, desc in NAME_PATTERNS:
            if not name_re.search(name):
                continue
            any_match = True
            if fingerprint_match(body, groups):
                winning = (name_re, groups, desc)
                break

        if winning:
            counts['SUPPORTED'] += 1
            matched_rows.append({
                'file': r['file'],
                'line': r['line'],
                'name': name,
                'desc': winning[2],
                'verdict': 'SUPPORTED',
            })
        elif any_match:
            counts['INCONCLUSIVE'] += 1
        else:
            counts['no_pattern'] += 1

    print()
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f'  {k:<20} {v}')

    # Write report
    report = WORKING / 'NAME_PATTERN_VERIFY.md'
    out_lines = [
        '# Name-Pattern Structural Verification',
        '',
        'Auto-generated by `name_pattern_verify.py`.',
        '',
        'For each PENDING proc whose name matches a known role pattern',
        '(e.g. `wait_*`, `*_dispatch`, `set_*`), the proc body is checked',
        'against the role-specific opcode fingerprint.  Match -> SUPPORTED.',
        '',
        f'Total PENDING procs scanned: **{len(pending)}**',
        '',
        '## Counts',
        '',
        '| Bucket | Count |',
        '|---|---:|',
    ]
    for k, v in sorted(counts.items(), key=lambda kv: -kv[1]):
        out_lines.append(f'| {k} | {v} |')
    out_lines.extend([
        '',
        f'## SUPPORTED rows ({len(matched_rows)})',
        '',
        '| File | Line | Name | Role pattern |',
        '|---|---:|---|---|',
    ])
    for r in matched_rows:
        out_lines.append(f'| `{r["file"]}` | {r["line"]} | `{r["name"]}` | {r["desc"]} |')

    # Track INCONCLUSIVE rows separately so we can debug over-strict patterns
    inc_rows = [r for r in pending
                if any(name_re.search(r['name']) for name_re, _, _ in NAME_PATTERNS)]
    # actually we need to pick those classified inconclusive -- recompute
    inc_rows = []
    for r in pending:
        name = r['name']
        match = None
        for name_re, groups, desc in NAME_PATTERNS:
            if name_re.search(name):
                match = (name_re, groups, desc)
                break
        if match is None:
            continue
        asm = ROOT / r['file']
        body = load_proc_body(asm, name)
        if body is None:
            continue
        if not fingerprint_match(body, match[1]):
            inc_rows.append({
                'file': r['file'], 'line': r['line'], 'name': name,
                'desc': match[2],
            })

    out_lines.extend([
        '',
        f'## INCONCLUSIVE rows ({len(inc_rows)})',
        '',
        'Name pattern matched but proc body did not match the expected fingerprint.',
        'Either the fingerprint is over-strict, or the proc name is misleading.',
        '',
        '| File | Line | Name | Expected role |',
        '|---|---:|---|---|',
    ])
    for r in inc_rows:
        out_lines.append(f'| `{r["file"]}` | {r["line"]} | `{r["name"]}` | {r["desc"]} |')

    report.write_text('\n'.join(out_lines), encoding='utf-8')
    print(f'\nWrote {report}')


if __name__ == '__main__':
    main()
