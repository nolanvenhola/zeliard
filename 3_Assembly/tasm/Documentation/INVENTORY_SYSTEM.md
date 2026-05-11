# Zeliard inventory / character-select screen

Item #3 from MECHANICS_TO_UNDERSTAND.md.  Documents 201SELCT (the
"select.bin" chunk) — the screen that opens when the player presses
ENTER to view/equip weapons / cast magic / use items.

> **⚠ Naming note (2026-05-05 TCRF unification):** The byte map below
> uses some **earlier (wrong) names** retained for narrative continuity.
> The authoritative names live in `working/drivers/stdply.inc`.  Major
> corrections: `0x9D` = `selected_spell` (not weapon idx), `0x9E` =
> `selected_accessory` (shoe/cape), `0xA1..A5` = `accessory_slot_*`
> (wearables, NOT magic), `0xAB..B1` = `spell_charge_*` (7 spell
> charges, NOT weapon durability), `0xB4..BA` = `spell_charge_max_*`,
> `0xBB..C1` = `spell_known_*` (NOT weapon flags), `0x98` =
> `keys_normal`, `0x99` = `keys_lion`, `0x9A..9C` = `crest_elf/glory/hero`.
> See `SAVE_FORMAT.md` for the canonical TCRF byte map.

---

## Storage layout (player record at DS:0x80–0xC1)

The persistent inventory is stored as **byte arrays of per-category
state + scalar equipped indices** in the 256-byte player record:

| Address | Size | TCRF canonical | Earlier (wrong) name | Contents |
|---|---:|---|---|---|
| `0x80` | 1 | `world_x_lo` | `town_player_col` | world X (lo byte) |
| `0x85..87` | 3 | `hero_gold_hi/lo/mid` | — | 24-bit gold |
| `0x88..8A` | 3 | `hero_bank_hi/lo/mid` | — | 24-bit bank balance |
| `0x8B..8C` | 2 | `hero_almas` | — | almas (16-bit, cap 0xFFFF) |
| `0x8D` | 1 | `hero_level` | `item_qty_count` | hero level (0..255) |
| `0x90..91` | 2 | `player_HP` | `char_hp` | current HP (16-bit) |
| `0x92` | 1 | `equipped_weapon` | — | weapon idx (1-based, 0=none) |
| `0x93` | 1 | `shield_type` | `equipped_magic` | shield type (drives damage absorb) |
| `0x94..95` | 2 | `shield_HP` | `char_exp` | shield current HP (16-bit) |
| `0x96..97` | 2 | `shield_max_HP` | `char_exp_cap` | shield max HP (16-bit cap) |
| `0x98` | 1 | `keys_normal` | `char_speed` | normal key count |
| `0x99` | 1 | `keys_lion` | `char_power` | Lion's Head Key count |
| `0x9A` | 1 | `crest_elf` | (part of) `char_abilities` | Elf Crest (0xFF=have) |
| `0x9B` | 1 | `crest_glory` | (part of) `char_abilities` | Glory Crest (0xFF=have) |
| `0x9C` | 1 | `crest_hero` | (part of) `char_abilities` | Hero's Crest (0xFF=have) |
| `0x9D` | 1 | `selected_spell` | `cur_weapon_idx` | currently chosen spell ID (0=none, 1..7) |
| `0x9E` | 1 | `selected_accessory` | `cur_magic_idx` | equipped wearable ID (0=none, 1=Feruza, 2=Pirika, 3=Silkarn, 4=Ruzeria, 5=Cape) |
| `0xA0` | 1 | `tears_of_esmesanti_count` | `music_track_count` | tears collected (0..9) |
| `0xA1..A5` | 5 | `accessory_slot_1..5` | `magic_flags` | wearable-acquisition slots (each holds ID 0..5 of Nth wearable obtained) |
| `0xA6..AA` | 5 | `item_slot_1..5` | `item_flags` | inventory slot N (item ID 1..8; 0=empty) |
| `0xAB..B1` | 7 | `spell_charge_*` | `weap_dur_cur` | per-spell current charges (espada/saeta/fuego/lanzar/rascar/agua/guerra) |
| `0xB2..B3` | 2 | `player_hp_max` | `char_hp_max` | max HP for current level (16-bit) |
| `0xB4..BA` | 7 | `spell_charge_max_*` | `weap_dur_max` | per-spell max charges |
| `0xBB..C1` | 7 | `spell_known_*` | `weapon_flags` / `boss_kill_*` | per-spell learned flag (0=not yet, FFh=learned from Sage) |
| `0xC2` | 1 | `facing_direction` | — | facing/anim flag bits |
| `0xC4` | 1 | `save_sage` | `current_area_id` | which sage saved this game |
| `0xC8` | 1 | `current_level_idx` | `player_tileset` | current cavern (0..31) |
| `0xE4` | 1 | (`key_count` per old INVENTORY_SYSTEM) | — | TCRF says `last_sage_visited` at 0xC5; per-context check needed |

**Inventory total** (TCRF authoritative): 5 accessory slots + 5 item
slots + 7 spell-known flags = 17 "have" indicators, plus equipped-idx
scalars and per-spell charge tables.  The earlier "5 magic + 5 items +
7 weapons" classification was a mis-mapping (slots A1..A5 are
WEARABLES, not magic spells).

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
