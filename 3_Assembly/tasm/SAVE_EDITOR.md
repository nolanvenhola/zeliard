# Zeliard Save Editor

Two front-ends sharing the same field map and codec:

- **`save_edit.py`** — CLI (great for batch edits / scripted tests).
- **`save_editor_gui.py`** — Tkinter GUI (great for free-form exploration).

Both edit a 256-byte .USR save file with named-field accessors.  Use
them to manipulate single state values and validate naming hypotheses
against actual gameplay (run the result with `bin/zelplay.bat`).

## GUI

```bash
python save_editor_gui.py                  # blank, use Open…
python save_editor_gui.py bin/Bosque.usr   # open immediately
```

What you get:
- Scrollable form grouped by section (Boss flags, Crests, Equipment,
  per-cavern bitmaps, etc.) — every named field is editable.
- **Booleans as checkboxes**.
- **Enumerated values as dropdowns** with human-readable labels — weapons
  (Training/WiseMan/Spirit/Knight/Illumination/Enchantment/Fairy Flame),
  shields (Clay/WiseMan/Stone/Honor/Light/Titanium), towns (Muralla
  through Esco), spells (Espada/Saeta/Fuego/Lanzar/Rascar/Agua/Guerra),
  items (Ken'ko/Juu-en/Elixir/Chikara/Magia/HolyWater/SabreOil/Kioku),
  spell slots, item slots, current_area_id, etc.  Dropdowns aren't
  read-only — you can still type any byte value if the enum doesn't
  cover it.
- Numbers and hex strings as text entries (decimal, `0x…`, or `…h`).
- **Live hex view** on the right, with bytes that differ from the on-disk
  baseline highlighted red.  Updates as you type — no need to press Enter.
- **Right-click any field's name or offset** to revert that single field
  to its on-disk value (handy when you want to undo just one tweak).
- **Open…** / **Save** (overwrite) / **Save As…** / **Reload** /
  **Revert all** in the toolbar.
- Invalid entries are rejected only on Enter / blur (not while typing) —
  so partial values during edits don't pop errors.

## CLI

## Quick reference

```bash
# List every known field
python save_edit.py --fields

# Inspect a save (decoded)
python save_edit.py bin/Bosque.usr --dump

# Read one field
python save_edit.py bin/Bosque.usr --get player_HP

# Edit (writes to <stem>_edit.usr by default; original untouched)
python save_edit.py bin/Bosque.usr --set player_HP=999
python save_edit.py bin/Bosque.usr --set crest_hero=1 -o bin/HeroTest.usr
python save_edit.py bin/Bosque.usr --set player_gold=50000 --set player_almas=65535

# Raw byte poke (for hypotheses about unnamed bytes)
python save_edit.py bin/Bosque.usr --set @47=ff   # set byte at offset 0x47 to 0xFF
```

Value formats: `123`, `0x7B`, `7Bh`, `true`/`false` (booleans).
Raw fields take a hex string: `--set "cavern_bits_riza=ff ff ff ff 00 00 00 00"`.

## Validation experiments

Pick a base save, edit ONE field, run the game with the edited save, observe.
Each experiment confirms or refutes one naming hypothesis.

### 1. Confirm `boss_kill_*` flags really skip boss fights

```bash
# Take Muralla (zero progress) and force all 7 main bosses defeated.
# Game should treat us as past Dragon (cavern 7).
python save_edit.py bin/Muralla.usr -o bin/AllBoss.usr \
    --set boss_kill_cangrejo=1 \
    --set boss_kill_pulpo=1 \
    --set boss_kill_pollo=1 \
    --set boss_kill_agar=1 \
    --set boss_kill_vista=1 \
    --set boss_kill_tarso=1 \
    --set boss_kill_dragon=1 \
    --set current_area_id=0x88     # in Pureza town

cd ../1_OriginalGame && ./zeliad.exe ALLBOSS.USR
# Expected: spawn in Pureza, Dragon-cavern bridges open, doors not blocked.
```

### 2. Test the Alguien / Jashiin special-flag hypothesis (offsets 0x47, 0x48)

```bash
# Hypothesis: 0x47 = Alguien-cleared, 0x48 = Jashiin-cleared.
# Take Pureza save (just arrived, before Alguien) and force Alguien-cleared.
python save_edit.py bin/Pureza.usr -o bin/AlguienTest.usr \
    --set alguien_cleared=1
# Run with this save → does the game let us into the Esco-village path
# without re-fighting Alguien?  If yes, hypothesis confirmed.

# Same for Jashiin:
python save_edit.py bin/Pureza.usr -o bin/JashiinTest.usr \
    --set alguien_cleared=1 \
    --set jashiin_cleared=1
# Should treat the player as having beaten the game.
```

### 3. Test the Crest mapping

```bash
# Hypothesis: crest_hero is required to encounter Pollo.
# Strip it from a Bosque save (which normally has it set) and try to
# fight Pollo — the guard should block us.
python save_edit.py bin/Bosque.usr -o bin/NoHeroCrest.usr \
    --set crest_hero=0
# Run, walk through Cavern of Riza — does the guard turn us away?

# Hypothesis: crest_glory triggers the Knight's Sword trade in Tumba.
# Set it on a Tumba save and visit the weapon shop.
python save_edit.py bin/Tumba.usr -o bin/GloryTest.usr \
    --set crest_glory=1
# Visit Tumba's weapon shop — does it offer the trade dialog?

# Hypothesis: crest_elf unlocks Llama Town villager dialog.
python save_edit.py bin/PAGURO.usr -o bin/ElfTest.usr \
    --set crest_elf=1
# Talk to Llama villagers — do they speak normally or refuse?
```

### 4. Test the equipped-shoe / cape hypothesis (player_speed, player_power)

```bash
# Hypothesis: player_speed (0/1) is "speed-shoes equipped".
python save_edit.py bin/Helada.usr -o bin/Speed1.usr --set player_speed=1
# Walk on ice — slip behaviour different vs Helada.usr unedited?

# Hypothesis: player_power is "cape equipped".
python save_edit.py bin/Llama.usr -o bin/Cape1.usr --set player_power=1
# Walk into Burning Inferno — does HP drain stop?
```

### 5. Test current_area_id as Kioku Feather destination

```bash
# Place player in town 8 (Pureza) but set last-sage to town 1 (Muralla).
# Then use Kioku Feather in-game → should warp to Muralla.
python save_edit.py bin/Pureza.usr -o bin/KiokuTest.usr \
    --set current_area_id=0x81
# Hmm — but current_area_id = where you are, not where you were.
# So this test changes spawn location.  A real test of Kioku
# destination would need a separate "last sage" byte (TBD).
```

### 6. Probe the always-zero slot 7 (save 0x38..0x3F)

```bash
# Force-set bits in slot 7 to see if game UI/state reacts:
python save_edit.py bin/ALMAS.usr -o bin/Slot7Test.usr \
    --set "cavern_bits_slot7=ff ff ff ff ff ff ff ff"
# If nothing visibly changes, slot 7 is genuinely unused.
# If something happens (item-collected indicator, dialog change),
# we've found what slot 7 represents.
```

## Field types

| Type | Description |
|------|-------------|
| `b`  | uint8 |
| `w`  | uint16 little-endian |
| `24` | 24-bit (hi, lo, mid) byte order — used by `player_gold` and `player_bank` |
| `bool` | stored as 0x00 (clear) or 0xFF (set) |
| `raw` | passthrough hex string for arbitrary multi-byte regions |

## Layout reference

The editor knows the entire 256-byte layout.  Bytes outside the named
fields (the BLK signature, sprite icon at 0xD0..0xE3, tail x86 code at
0xE9..0xFF) are preserved verbatim.

Run `python save_edit.py --fields` for the full field list.

## Test workflow

```bash
# 1. Make sure the original save is untouched.
sha256sum bin/Bosque.usr      # remember the hash

# 2. Edit:
python save_edit.py bin/Bosque.usr --set crest_hero=0 -o bin/Test.usr

# 3. Run game:
cd ../../1_OriginalGame && ./zeliad.exe TEST.USR  # or via DOSBox

# 4. Observe → confirm or refute.

# 5. Iterate: change one field, re-run.
```
