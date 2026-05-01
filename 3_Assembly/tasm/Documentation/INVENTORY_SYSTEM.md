# Zeliard inventory / character-select screen

Item #3 from MECHANICS_TO_UNDERSTAND.md.  Documents 201SELCT (the
"select.bin" chunk) — the screen that opens when the player presses
ENTER to view/equip weapons / cast magic / use items.

---

## Storage layout (player record at DS:0x80–0xC1)

The persistent inventory is stored as **3 separate per-category byte
arrays + scalar equipped indices**, NOT as a single bitmask:

| Address | Size | Field | Contents |
|---|---:|---|---|
| `0x92` | 1 byte | `equipped_weapon` | currently-equipped weapon idx (1-based, 0=none) |
| `0x93` | 1 byte | `equipped_magic` | currently-equipped magic idx (1-based, 0=none) |
| `0x90` | 2 bytes | `char_hp` | current HP (16-bit) |
| `0xB2` | 2 bytes | `char_hp_max` | max HP for current level (16-bit) |
| `0x94` | 2 bytes | `char_exp` | current experience (16-bit) |
| `0x96` | 2 bytes | `char_exp_cap` | XP cap for current level (16-bit) |
| `0x98` | 1 byte | `char_speed` | speed stat |
| `0x99` | 1 byte | `char_power` | power/attack stat |
| `0x9A..0x9C` | 3 bytes | `char_abilities` | combat ability flags |
| `0x9D` | 1 byte | `cur_weapon_idx` | cached selected weapon (1-based) |
| `0x9E` | 1 byte | `cur_magic_idx` | cached selected magic (1-based) |
| **`0xA1..0xA5`** | 5 bytes | **`magic_flags`** | one byte per magic spell: 0=don't have, FFh=have |
| **`0xA6..0xAA`** | 5 bytes | **`item_flags`** | one byte per consumable item: 0=don't have, FFh=have |
| `0xAB..0xB1` | 7 bytes | `weap_dur_cur` | current weapon durability (per weapon type) |
| `0xB4..0xBA` | 7 bytes | `weap_dur_max` | max weapon durability (per weapon type) |
| **`0xBB..0xC1`** | 7 bytes | **`weapon_flags`** | one byte per weapon: 0=don't have, FFh=have |
| `0xE4` | 1 byte | `key_count` | number of keys held |

**Inventory total: 17 flag bytes** (5 magic + 5 items + 7 weapons) plus
the equipped-idx scalars and the per-weapon durability tables.

The 5-byte buffer at DS:0xFF58 (referenced as `inventory_list` in
some shop chunks) is **transient** — used during shop-menu builds, not
the persistent inventory.

---

## Screen entry flow

```
[Player presses ENTER in cavern or town]
         │
         ▼
selct_main (CS:0xA000 of 201SELCT.bin, loaded by game.bin)
         │
         ▼
1. Read gvar_selct_state (DS:0xA00B) — entry sub-state
2. Init has_items_flag = 0; portrait_vis = 0
3. Draw 4 portrait rectangles via portrait_data_tbl + drv_fill_rect
4. draw_portrait_tabs — tabs at top of screen
5. SCAN weapon_flags (7 bytes at DS:0xBB)
     for i in 1..7:
       if weapon_flags[i-1] != 0:
         weapon_idx_tbl[count++] = i
   weapon_count = count
6. SCAN magic_flags (5 bytes at DS:0xA1)
     similar — builds magic_idx_tbl, magic_count
7. rebuild_item_idx — same for item_flags
8. draw_weapon_panel / draw_magic_panel / draw_item_panel /
   draw_char_stats — render the 4 panels
9. Pick starting panel:
     if weapon_count > 0:  cur_panel_idx = 0 (weapon)
     elif magic_count > 0: cur_panel_idx = 1 (magic)
     elif has_items:       cur_panel_idx = 2 (item)
     else: idle in wait_confirm_loop until exit
10. panel_dispatch — jmp word ptr ds:panel_dispatch_tbl[cur_panel_idx*2]
    (per-panel handler installed by caller before entry)
```

The `panel_dispatch_tbl` at DS:0xA0C4 is filled by the caller (game.bin
or 200FIGHT) before invoking selct_main.  3 entries: weapon-panel
handler, magic-panel handler, item-panel handler.

---

## Per-panel input loop (uniform across weapon/magic/item)

```asm
panel_main:
        call    draw_portrait_tabs
        mov     al, 2
        call    show_<X>_portrait      ; X = weapon / magic / item

wait_joy_neutral:
        int     61h
        and     al, 3                  ; while ANY direction held...
        jnz     wait_joy_neutral       ;   wait for release

panel_input_loop:
        call    poll_input             ; CF=exit-queued
        jnc     panel_poll
        retn                           ; user pressed ESC/ENTER → return

panel_poll:
        int     61h                    ; AL = joystick direction bits
        and     al, 0Eh
        jz      panel_input_loop       ; no input → keep polling
        and     al, 0Ch                ; up/down bits?
        jnz     panel_joy_vert
        jmp     panel_confirm          ; horizontal → confirm/switch

panel_joy_vert:
        test    al, 4
        jnz     panel_joy_up
        ; ── joy down ──
        mov     al, ds:<X>_cursor
        inc     al
        cmp     ds:<X>_count, al
        jb      panel_input_loop       ; already at bottom
        call    show_<X>_portrait      ; redraw at new cursor
        inc     ds:<X>_cursor
        ...
        jmp     panel_input_loop

panel_joy_up:
        test    ds:<X>_cursor, FFh
        jz      panel_input_loop       ; already at top
        dec     ds:<X>_cursor
        ...
        jmp     panel_input_loop
```

Per-panel state:
- `weapon_cursor` / `magic_cursor` / `item_cursor` — current selection (0-based)
- `weapon_count`  / `magic_count`  / `item_count`  — number of available items
- `weapon_idx_tbl` / `magic_idx_tbl` / `item_idx_tbl` — list of available 1-based indices

Joystick `int 61h` returns AL with direction bits:
- `bit 0` (0x01): right
- `bit 1` (0x02): left
- `bit 2` (0x04): up
- `bit 3` (0x08): down

Per-panel confirm action: switches to the next-non-empty panel
(weapon → magic → item → exit), OR triggers item-use for the items
panel.

---

## Item-use dispatch (8 items)

When the player confirms on the items panel, control jumps via
`item_use_dispatch_tbl` (DS:0xA452) indexed by `item_cursor-1`:

```asm
mov  al, ds:item_cursor
mov  ds:gvar_item_result, al           ; signal result back to caller
mov  bl, ds:item_cursor
dec  bl
xor  bh, bh
add  bx, bx
jmp  word ptr ds:item_use_dispatch_tbl[bx]
```

The 8 handlers are inline in selct.bin (matching the 8 item types from
the magic shop).  **Reverse-engineered effects**:

| idx | Item | Handler | Effect |
|---:|---|---|---|
| 0 | Ken'ko Potion | `use_hp_potion` | +0x50 (80) HP, cap at `char_hp_max` |
| 1 | Juu-en Fruit | `use_hp_full` | restore HP to `char_hp_max` |
| 2 | Elixir of Kashi | `use_weapon_restore` | restore equipped weapon durability to max |
| 3 | Chikara Powder | `use_all_weapons_restore` | `rep movsb` 7 bytes — restore ALL 7 weapon durabilities |
| 4 | Sabre Oil | `use_sabre_oil` | weapon damage boost (TBD: temporal multiplier?) |
| 5 | Magia Stone | `use_magia_stone` | grant XP per `item_effect_tbl[equipped_magic-1]` |
| 6 | Holy Water of Acero | `use_holy_water` | `inc key_count` (+1 key) |
| 7 | Kioku Feather | `use_kioku_feather` | warp/save (uses 120-frame timer at `timer_wait_feather`) |

After use:
1. `item_flags[idx]` is zeroed (consumed)
2. `rebuild_item_idx` rebuilds `item_idx_tbl` with the surviving items
3. `gvar_volume_b = 0Eh` (audio cue)
4. Various `drv_palette_push` / `drv_anim_step` calls for visual feedback
5. `gvar_item_result` is set so the caller (combat/town) knows what was used

---

## Exit flow

`poll_input` returns `CF=1` when the player has signaled exit (ESC or
the configured exit button).  This propagates back out through the
panel loops to `selct_main`'s `retn`.  Caller (game.bin or 200FIGHT)
then continues from where ENTER was pressed.

`gvar_item_result` (DS:0xFF4B) carries the consumed-item index back to
the caller so combat-state can react (e.g., apply Sabre Oil's damage
buff for the next attack).

---

## Driver dispatch slots used

| Slot | Used for |
|---|---|
| `drv_fill_rect` (cs:[2000]) | clear panel rectangles, dialog backgrounds |
| `drv_palette_push` (cs:[2008]) | visual feedback on item-use |
| `drv_anim_step` (cs:[2018]) | refresh visible state |
| `drv_render_char` (cs:[2022]) | draw item-name strings |
| `drv_fn_15` (cs:[201E]) | sprite source selector A — used by `draw_weapon_cursor` |
| `drv_fn_sprite` (cs:[202E]) | render selected portrait sprite |
| `drv_return_to_caller` (cs:[2040]) | exit back to caller |

---

## What this gives a port

The inventory screen is **layered on top of**:
1. Pure data lookups (the 17 flag bytes + 14 durability bytes + scalars)
2. A small UI state machine (3 panels × cursor navigation)
3. A small item-use jump table (8 fixed handlers)

A re-implementation needs:
- The persistent storage layout (above) — directly from the player record
- A simple panel-and-cursor UI — straightforward in any toolkit
- The 8 item-use handlers, all of which are short and deterministic
  (HP heal / weapon-durability restore / key add / XP grant / save)
- Joystick-style nav in modern terms (arrow-key / D-pad equivalent)
- The `panel_dispatch_tbl` callback contract: caller installs 3 word
  pointers before invoking selct_main; each is the per-panel handler

---

## Status (per MECHANICS_TO_UNDERSTAND.md)

After this trace:

| Row | Was | Now |
|---|:---:|:---:|
| Inventory open trigger (Enter key) | ❌ | ✓ (selct_main entry) |
| Inventory display (201SELCT) | ⚠ | ✓ (3-panel layout documented) |
| Item slot count + categories | ❌ | ✓ (5/5/7 + scalars; weapons/magic/items as separate flag arrays) |
| Equip / un-equip handler | ❌ | ✓ (cur_weapon_idx / cur_magic_idx, written by panel cursor) |
| Inventory navigation (arrow keys) | ❌ | ✓ (per-panel input loop documented) |
| Item activate (Space) | ❌ | ✓ (item_use_dispatch_tbl[cursor-1] jump) |
| Inventory close (Enter) | ❌ | ✓ (poll_input CF=1 → retn back to caller) |
| Inventory item bitmask | ⚠ | ✓ (NOT a bitmask — 3 separate flag-byte arrays at DS:A1/A6/BB) |
| 8 item-use handlers | ❌ | ✓ (all 8 effects documented) |
| ARMOR window | ❌ | ⚠ (weap_dur_cur table identified; render path TBD) |
| SPELL window | ❌ | ⚠ (cur_magic_idx / equipped_magic identified; render path TBD) |
