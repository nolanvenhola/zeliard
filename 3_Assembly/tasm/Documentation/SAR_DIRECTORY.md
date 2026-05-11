# SAR archive directory (canonical file_id → filename map)

Cross-referenced from `c:\projects\zeliard-brox\tools\MDTViewer\sar_reader.py`
and validated against our `resource_name_table` extraction (200FIGHT.asm:8471).

SAR file format:
```
file_id (1-based) → info_offset = (file_id - 1) * 4
  DWORD at info_offset = data_offset
At data_offset:
  DWORD  file_length
  BYTES  file_content  (file_length bytes; may be fill_buffer-compressed)
```

The chunk loader (`call cs:[010Ch]`) takes `AL` = mode:
- `AL=2`: load + fill_buffer decompress → `ES:DI` (most data chunks)
- `AL=3`: load raw bytes → `ES:DI` (code chunks)
- `AL=5`: load music (.msd) → fixed music buffer

---

## zelres1.sar  (40 chunks)

| ID | Filename | Type | Purpose |
|---:|---|---|---|
| `0x01` | opdemo.bin | code | Opening cinematic + title sequence (100OPDMO) |
| `0x02` | gdega.bin | code | EGA gameplay-driver dispatch (101GDEGA) |
| `0x03` | gdcga.bin | code | CGA dispatch (102GDCGA) |
| `0x04` | gdhgc.bin | code | Hercules dispatch (103GDHGC) |
| `0x05` | gdtga.bin | code | TGA dispatch (104GDTGA) |
| `0x06` | gdmcga.bin | code | MCGA dispatch (105GDMCA) |
| `0x07` | town.bin | code | Town engine (106TOWN) |
| `0x08` | gtega.bin | code | EGA town-graphics driver (107GTEGA) |
| `0x09` | gtcga.bin | code | CGA town-graphics driver (108GTCGA) |
| `0x0A` | gthgc.bin | code | HGC town driver (109GTHGC) |
| `0x0B` | gttga.bin | code | TGA town driver (110GTTGA) |
| `0x0C` | gtmcga.bin | code | MCGA town driver (111GTMCA) |
| `0x0D` | font.grp | data | Bitmap font (loaded into CS:F500 by game.bin) |
| `0x0E` | ame.grp | data | Rain/weather effect |
| `0x0F` | dmaou.grp | data | Demon king Jashiin portrait |
| `0x10` | hime.grp | data | Princess Felicia portrait |
| `0x11` | himp.grp | data | Hit/impact effect sprite |
| `0x12` | hou.grp | data | Opening scene image |
| `0x13` | isi.grp | data | Stone/rock graphics |
| `0x14` | maop.grp | data | Map/ending scene |
| `0x15` | ne80.grp / `0x16` ne81.grp | data | Opening sub-images |
| `0x17` | nec.grp | data | NEC logo (title screen) |
| `0x18` | new1.grp / `0x19` new2.grp | data | Enemy type 1/2 sprites (zelres1) |
| `0x1A` | oui.grp | data | King portrait |
| `0x1B` | oup.grp | data | Ending image |
| `0x1C` | sei.grp | data | Fairy/spirit sprite |
| `0x1D` | seip.grp | data | Player attack animation |
| `0x1E` | ttl1.grp | data | Title screen part 1 |
| `0x1F` | ttl2.grp | data | Title screen part 2 |
| `0x20` | ttl3.grp | data | Title screen part 3 |
| `0x21` | waku.grp | data | Window frame graphics (cutscene corridor frame) |
| `0x22` | yuu1.grp | data | Hero animation frame 1 |
| `0x23` | yuu2.grp | data | Hero animation frame 2 |
| `0x24` | yuu3.grp | data | Hero animation frame 3 |
| `0x25` | yuu4.grp | data | Hero animation frame 4 |
| `0x26` | yuup.grp | data | Hero portrait |
| `0x27` | zend.msd | music | Ending music |
| `0x28` | zopn.msd | music | Opening music |

## zelres2.sar  (58 chunks)

| ID | Filename | Type | Purpose |
|---:|---|---|---|
| `0x01` | fight.bin | code | Cavern engine (200FIGHT) |
| `0x02` | select.bin | code | Inventory panel (201SELCT) |
| `0x03` | gfega.bin | code | EGA fight-graphics driver (202GFEGA) |
| `0x04` | gfcga.bin | code | CGA fight driver (203GFCGA) |
| `0x05` | gfhgc.bin | code | HGC fight driver (204GFHGC) |
| `0x06` | gftga.bin | code | TGA fight driver (205GFTGA) |
| `0x07` | gfmcga.bin | code | MCGA fight driver (206GFMCA) |
| `0x08` | mole.bin | code | Generic graphics init (207MOLE) |
| `0x09` | ympd.bin | code | YMP-D unknown shop (208YMPD) |
| `0x0A` | ckpd.bin | code | CKP-D unknown shop (209CKPD) |
| `0x0B` | kingpro.bin | code | King's Palace dialog (210KINGP) |
| `0x0C` | omoypro.bin | code | Omoya / souvenir hut + end-demo trigger (211OMOYP) |
| `0x0D` | armrpro.bin | code | Weapons/Armor shop (212ARMRP) |
| `0x0E` | bankpro.bin | code | Bank (213BANKP) |
| `0x0F` | churpro.bin | code | Church / Pope (214CHURP) |
| `0x10` | drugpro.bin | code | Magic Brewer / drug shop (215DRUGP) |
| `0x11` | innapro.bin | code | Inn (216INNAP) |
| `0x12` | kenjpro.bin | code | Sage / Kenja (217KENJP) |
| `0x13` | king.grp | data | King portrait sprites |
| `0x14` | omoya.grp | data | Omoya hut graphics |
| `0x15` | armor.grp | data | Weapons-shop graphics |
| `0x16` | bank.grp | data | Bank graphics |
| `0x17` | church.grp | data | Church graphics |
| `0x18` | drug.grp | data | Magic-brewer graphics |
| `0x1A` | kenjya.grp | data | Sage portrait sprites |
| `0x1B` | sword.grp | data | **Sword sprites** (3 mega-groups: training/wise/spirit, knight/illumination, enchantment) |
| `0x1C` | itemp.grp | data | Item-panel icons (7 items) |
| `0x1D` | magic.grp | data | Magic-effect sprites (6 16×16 sprites, 3-plane 48-B block reassembly) |
| `0x1E` | mman.grp | data | Town NPC sprites (16×24) |
| `0x1F` | cman.grp | data | Town NPC sprites |
| `0x20` | tman.grp | data | Hero-in-town sprites (16×24) |
| `0x22` | cpat.grp | data | Castle pattern tiles (8×8) |
| `0x23` | mpat.grp | data | Mountain pattern tiles |
| `0x24` | dpat.grp | data | Dungeon pattern tiles |
| `0x25` | cmap.mdt | data | **Felishika Castle** map |
| `0x26` | mrmp.mdt | data | **Muralla Town** map |
| `0x27` | stmp.mdt | data | **Satono Town** map |
| `0x28` | bsmp.mdt | data | **Bosque Village** map |
| `0x29` | hlmp.mdt | data | **Helada Town** map |
| `0x2A` | tmmp.mdt | data | **Tumba Town** map |
| `0x2B` | drmp.mdt | data | **Dorado Town** map |
| `0x2C` | llmp.mdt | data | **Llama Town** map |
| `0x2D` | prmp.mdt | data | **Pureza Town** map |
| `0x2E` | esmp.mdt | data | **Esco Village** map |
| `0x2F` | mgt1.msd | music | Town music (general 1) |
| `0x30` | mgt2.msd | music | Town music (general 2) |
| `0x31` | ugm1.msd | music | Underground music 1 |
| `0x32` | ugm2.msd | music | Underground music 2 |
| `0x33` | enddemo.bin | code | Ending cinematic (250ENDMO) |
| `0x34..38` | en72/end4/end5/end6/end7.grp | data | Ending cutscene frames |
| `0x39` | fin.grp | data | Final ending image |
| `0x3A` | roka.grp | data | Corridor/passage decoration (NOT the same as zelres3's roka.grp) |

## zelres3.sar  (96 chunks)

| ID | Filename | Type | Purpose |
|---:|---|---|---|
| `0x01` | rokademo.bin | code | Post-boss-victory cutscene (300ROKAD) |
| `0x02..09` | eai1..eai8.bin | code | Enemy AI per world (301..308) |
| `0x0A` | crab.bin | code | Cangrejo boss (309CRAB) |
| `0x0B` | tako.bin | code | Pulpo boss (310TAKO) |
| `0x0C` | tori.bin | code | Pollo boss (311TORI) |
| `0x0D` | zela.bin | code | Zela boss (312ZELA) |
| `0x0E` | meda.bin | code | Meda boss (313MEDA) |
| `0x0F` | lega.bin | code | Lega boss (314LEGA) |
| `0x10` | zel2.bin | code | Zela-2 boss (315ZEL2) |
| `0x11` | drgn.bin | code | Dragon boss (316DRGN) |
| `0x12` | akma.bin | code | Akma boss (317AKMA) |
| `0x13` | mao1.bin | code | Jashiin form 1 (318MAO1) |
| `0x14` | mao2.bin | code | Jashiin form 2 / final (319MAO2) |
| `0x15..33` | mp10..mpa0.mdt | data | **31 cavern maps** (see DUNG_MAPS below) |
| `0x34` | fman.grp | data | Hero-in-dungeon 24×24 sprites |
| `0x35` | roka.grp | data | **Boss roka background** (different from zelres2's roka.grp!) |
| `0x36` | dman.grp | data | Rokademo sprites |
| `0x37` | dchr.grp | data | Door / platform component sprites (mode 10) |
| `0x38` | encnt.grp | data | Encounter/intro frame graphics |
| `0x39..40` | enp1..enp8.grp | data | Per-world enemy sprites (16×16) |
| `0x41` | crab.grp | data | Cangrejo boss sprites |
| `0x42..4A` | tako/tori/zela/meda/lega/drgn/akma/mao1/mao2.grp | data | Boss sprites |
| `0x4B..55` | mpp1..mppb.grp | data | **Per-cavern tile-pattern sets** (11 caverns) |
| `0x56..5D` | mus1..mus8.msd | music | Per-area background music (8 tracks) |
| `0x5E` | mbos.msd | music | Boss music |
| `0x5F` | mfan.msd | music | Fanfare (post-boss victory) |
| `0x60` | mmao.msd | music | Final-boss (Jashiin) music |

---

## Dungeon map ID lookup (referenced from door records)

Per `brox/MDTViewer/constants.py`, dungeon map IDs are 0-based from MP10:

| map_id | File |
|---:|---|
| 0 | MP10.MDT |
| 1 | MP1D.MDT |
| 2 | MP20.MDT |
| 3 | MP21.MDT |
| 4 | MP2D.MDT |
| 5 | MP30.MDT |
| 6 | MP31.MDT |
| 7 | MP3D.MDT |
| 8 | MP40.MDT |
| 9 | MP41.MDT |
| 10 | MP4D.MDT |
| 11 | MP50.MDT |
| 12 | MP51.MDT |
| 13 | MP5D.MDT |
| 14 | MP60.MDT |
| 15 | MP60.MDT (duplicate per brox; verify) |
| 16 | MP61.MDT |
| 17 | MP62.MDT |
| 18 | MP6D.MDT |
| 19 | MP70.MDT |
| 20 | MP71.MDT |
| 21 | MP72.MDT |
| 22 | MP73.MDT |
| 23 | MP7D.MDT |
| 24 | MP80.MDT |
| 25 | MP81.MDT |
| 26 | MP82.MDT |
| 27 | MP83.MDT |
| 28 | MP84.MDT |
| 29 | MP8D.MDT |
| 30 | MP90.MDT |
| 31 | MPA0.MDT |

## Town map ID lookup

Doors with `y1 == 0x00FF` are town warps:

| map_id | File | Town |
|---:|---|---|
| 0x01 | MRMP.MDT | Muralla Town |
| 0x02 | STMP.MDT | Satono Town |
| 0x03 | BSMP.MDT | Bosque Village |
| 0x04 | CMAP.MDT | Felishika Castle |
| 0x05 | HLMP.MDT | Helada Town |
| 0x06 | DRMP.MDT | Dorado Town |
| 0x07 | LLMP.MDT | Llama Town |
| 0x08 | PRMP.MDT | Pureza Town |
| 0x09 | ESMP.MDT | Esco Village |

---

## File-name patterns

| Pattern | Meaning |
|---|---|
| `mpN.mdt` | Outdoor map for world N |
| `mpND.mdt` | Dungeon (with `D` suffix) for world N |
| `mppN.grp` | Per-cavern tile-pattern set for world N |
| `enpN.grp` | Per-world enemy sprites |
| `eaiN.bin` | Per-world enemy AI code |
| `musN.msd` | Per-area background music |

---

## Cross-reference: 200FIGHT's resource_name_table

The `resource_name_table` at 200FIGHT.asm:8471 contains a SUBSET of
these files referenced via `[archive_idx][chunk_1based]` records,
e.g. `0, 2` = zelres1 chunk 2 (gdega.bin).  Earlier doc notes
about chunk_id "0x1E starts ROKADEMO" map to this directory's
zelres3 `0x01` = rokademo.bin entry — the `0x1E` in 200FIGHT's table
is the LOAD-ID value, not the SAR chunk_id directly.
