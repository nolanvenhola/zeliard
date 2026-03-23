# Zeliard - Working Disassembly

Organized, properly-named codebase from Sourcer disassembly (TASM 2.X + byte match).
Source of truth for the reverse-engineered game code. All 57 code modules compile
byte-perfect to their original binary outputs.

## Naming Convention

SAR code files use 8.3 format: **`X##PPPPP.asm`**
- `X` = zelres resource number (1, 2, or 3)
- `##` = zero-padded chunk number within that resource
- `PPPPP` = 5-character purpose abbreviation

Example: `202SPRTR.asm` = zelres **2**, chunk **02**, sprite renderer

## Directory Structure

```
working/
  core/          - Main executable (zeliad.exe) and game data loader
  drivers/       - Graphics and input drivers (7 total)
  zelres1/       - Opening/story scene system
    code/        - 14 code modules (chunks 0-11, 24, 30)
    data/        - 26 data files (images, music, font)
  zelres2/       - Gameplay engine
    code/        - 21 code modules (chunks 0-10, 12-17, 36, 38-39, 50)
    data/        - 37 data files (sprites, dialogue, extended chunks 40-57)
  zelres3/       - Level/world system
    code/        - 13 code modules (chunks 0, 14, 16, 20, 22, 26, 31-35, 37, 56)
    data/        - 83 data files (maps, dialogue, ending, extended chunks 40-95)
  srmacros.inc   - Shared TASM macro definitions (required by all .asm files)
```

## SAR Chunk Structure

Each SAR file has two offset tables:
- **Primary** (0x00–0x9F): 40 standard chunks (chunk_00 through chunk_39)
- **Extended** (0xA0–first_chunk): additional chunks beyond 40
  - zelres1: 40 chunks total (no extended)
  - zelres2: 58 chunks total (40 primary + 18 extended, chunks 40–57)
  - zelres3: 96 chunks total (40 primary + 56 extended, chunks 40–95)

---

## File Index

### core/

| File | Original | Output | Purpose |
|------|----------|--------|---------|
| `zeliad.asm` | ZELIAD.ASM | zeliad.exe | Main executable — reads RESOURCE.CFG, loads drivers, jumps to game.bin |
| `game.asm` | GAME.ASM | game.bin | Game initializer — loads all SAR code chunks, sets up segments |

### drivers/

| File | Original | Output | Purpose |
|------|----------|--------|---------|
| `gmmcga.asm` | GMMCGA.ASM | gmmcga.bin | MCGA 256-color graphics driver (primary VGA mode) |
| `gmcga.asm` | GMCGA.ASM | gmcga.bin | CGA graphics driver |
| `gmega.asm` | GMEGA.ASM | gmega.bin | EGA graphics driver |
| `gmhgc.asm` | GMHGC.ASM | gmhgc.bin | Hercules graphics driver |
| `gmtga.asm` | GMTGA.ASM | gmtga.bin | TGA graphics driver |
| `stdply.asm` | STDPLY.ASM | stdply.bin | Standard keyboard input driver |
| `stick.asm` | STICK.ASM | stick.bin | Joystick input driver |

---

### zelres1/code/ — Opening/Story Scene System

| File | Original | Chunk | Purpose |
|------|----------|-------|---------|
| `100OPSCN.asm` | ZR1_00 | chunk_00 | Opening story slideshow, text display, player init |
| `101IMGCT.asm` | ZR1_01 | chunk_01 | Image rendering pipeline, 4-plane decoder |
| `102EQUIP.asm` | ZR1_02 | chunk_02 | Equipment and inventory system |
| `103IMGDC.asm` | ZR1_03 | chunk_03 | Image decoding functions |
| `104PLSTS.asm` | ZR1_04 | chunk_04 | Player stat management |
| `105PALGT.asm` | ZR1_05 | chunk_05 | VGA DAC palette setup, driver interface |
| `106PLADV.asm` | ZR1_06 | chunk_06 | Advanced player mechanics (movement, combat) |
| `107VGADC.asm` | ZR1_07 | chunk_07 | Two-stage RLE + bitmap/XOR decompression |
| `108IMGDA.asm` | ZR1_08 | chunk_08 | Image decoder variant A |
| `109IMGDB.asm` | ZR1_09 | chunk_09 | Image decoder variant B |
| `110LIMGR.asm` | ZR1_10 | chunk_10 | 48×34 pixel 4-plane large image renderer |
| `111SIMGR.asm` | ZR1_11 | chunk_11 | 32×18 pixel small image renderer |
| `124UTILA.asm` | ZR1_24 | chunk_24 | Helper/utility functions A |
| `130UTILB.asm` | ZR1_30 | chunk_30 | Helper/utility functions B |

### zelres1/data/ — Opening Scene Assets

| File | Chunk | Original Name | Purpose |
|------|-------|---------------|---------|
| font.bin | 12 | — | Bitmap font data |
| image_13.grp | 13 | — | Opening image |
| nec.grp | 14 | nec.grp | NEC logo |
| hou.grp | 15 | hou.grp | Opening scene image |
| sprites.bin | 16 | — | Player/NPC sprite data |
| dmaou.grp | 17 | dmaou.grp | Demon king Jashiin |
| zopn.msd | 18 | zopn.msd | Opening music |
| ttl1.grp | 19 | ttl1.grp | Title screen part 1 |
| ttl2.grp | 20 | ttl2.grp | Title screen part 2 |
| ttl3.grp | 21 | ttl3.grp | Title screen part 3 |
| image_22.grp | 22 | — | Opening image |
| waku.grp | 23 | waku.grp | Window frame graphics |
| ame.grp | 24 | ame.grp | Rain/weather effect |
| hime.grp | 25 | hime.grp | Princess Felicia portrait |
| isi.grp | 26 | isi.grp | Stone/rock graphics |
| oui.grp | 27 | oui.grp | King portrait |
| sei.grp | 28 | sei.grp | Fairy/spirit sprite |
| yuu1.grp | 29 | yuu1.grp | Hero animation frame 1 |
| yuu2.grp | 30 | yuu2.grp | Hero animation frame 2 |
| yuu3.grp | 31 | yuu3.grp | Hero animation frame 3 |
| yuu4.grp | 32 | yuu4.grp | Hero animation frame 4 |
| yuup.grp | 33 | yuup.grp | Hero portrait |
| oup.grp | 34 | oup.grp | Ending image |
| maop.grp | 35 | maop.grp | Map/ending scene |
| image_36.grp | 36 | — | Ending image |
| image_37.grp | 37 | — | Ending image |
| anim_table.bin | 38 | — | Animation frame data |
| zend.msd | 39 | zend.msd | Ending music |

---

### zelres2/code/ — Gameplay Engine

| File | Original | Chunk | Purpose |
|------|----------|-------|---------|
| `200MGAME.asm` | ZR2_00 | chunk_00 | Core game loop (largest module, 16KB) |
| `201CBTUI.asm` | ZR2_01 | chunk_01 | Combat interface and HUD |
| `202SPRTR.asm` | ZR2_02 | chunk_02 | Sprite rendering engine |
| `203PHYSS.asm` | ZR2_03 | chunk_03 | Physics helper subsystems |
| `204PHYSE.asm` | ZR2_04 | chunk_04 | Main physics engine |
| `205ANIMS.asm` | ZR2_05 | chunk_05 | Animation system |
| `206ENAIE.asm` | ZR2_06 | chunk_06 | Enemy AI behavior framework |
| `207SLIME.asm` | ZR2_07 | chunk_07 | Slime enemy type |
| `208ENBAT.asm` | ZR2_08 | chunk_08 | Bat enemy type |
| `209ESPDR.asm` | ZR2_09 | chunk_09 | Spider enemy type |
| `210ESKEL.asm` | ZR2_10 | chunk_10 | Skeleton enemy type |
| `212EGHST.asm` | ZR2_12 | chunk_12 | Ghost enemy type |
| `213EGOBL.asm` | ZR2_13 | chunk_13 | Goblin enemy type |
| `214ENORC.asm` | ZR2_14 | chunk_14 | Orc enemy type |
| `215EWZRD.asm` | ZR2_15 | chunk_15 | Wizard enemy type |
| `216BOSSB.asm` | ZR2_16 | chunk_16 | Boss behavior patterns |
| `217ESPCI.asm` | ZR2_17 | chunk_17 | Special enemy type |
| `236UTILA.asm` | ZR2_36 | chunk_36 | Utility functions A |
| `238UTILB.asm` | ZR2_38 | chunk_38 | Utility functions B |
| `239DTATB.asm` | ZR2_39 | chunk_39 | Data tables (raw db — Sourcer output was 7000+ errors) |
| `250GMENG.asm` | ZR2_50 | chunk_50 | **Extended** — Gameplay engine module; calls chunk loader CS:[10Ch] and driver fns CS:[3004h/3008h] |

### zelres2/data/ — Gameplay Sprites & Extended Data

| File | Chunk | Original Name | Purpose |
|------|-------|---------------|---------|
| driver_table.bin | 11 | — | Graphics driver filename list |
| sprites_18.bin | 18 | — | Gameplay sprite set |
| sprites_19.bin | 19 | — | Gameplay sprite set |
| sprites_20.bin | 20 | — | Gameplay sprite set |
| sprites_21.bin | 21 | — | Gameplay sprite set |
| sprites_22.bin | 22 | — | Gameplay sprite set |
| sprites_23.bin | 23 | — | Gameplay sprite set |
| sprites_24.bin | 24 | — | Gameplay sprite set |
| sprites_25.bin | 25 | — | Gameplay sprite set |
| sprites_26.bin | 26 | — | Enemy/projectile sprites |
| waku.grp | 27 | waku.grp | Window frame sprites |
| sei.grp | 28 | sei.grp | Player/fairy sprites |
| yuup.grp | 29 | yuup.grp | Jump animation |
| seip.grp | 30 | seip.grp | Player attack animation |
| himp.grp | 31 | himp.grp | Hit/impact effects |
| new1.grp | 32 | new1.grp | Enemy type 1 sprites |
| new2.grp | 33 | new2.grp | Enemy type 2 sprites |
| ne80.grp | 34 | ne80.grp | Unused enemy sprites |
| ne81.grp | 35 | ne81.grp | Unused enemy sprites |
| dialogue.bin | 37 | — | NPC dialogue data |
| **chunk_40.bin** | 40 | — | Extended — purpose unknown |
| **chunk_41.bin** | 41 | — | Extended — purpose unknown |
| **chunk_42.bin** | 42 | — | Extended — purpose unknown |
| **chunk_43.bin** | 43 | — | Extended — purpose unknown |
| **chunk_44.bin** | 44 | — | Extended — purpose unknown |
| **chunk_45.bin** | 45 | — | Extended — purpose unknown |
| **chunk_46.bin** | 46 | — | Extended — purpose unknown |
| **chunk_47.bin** | 47 | — | Extended — purpose unknown |
| **chunk_48.bin** | 48 | — | Extended — purpose unknown |
| **chunk_49.bin** | 49 | — | Extended — purpose unknown |
| *(chunk_50 = 250GMENG.asm — code)* | | | |
| **chunk_51.bin** | 51 | — | Extended — fill_buffer opcode-6 sprite tiles (10720B decompressed) |
| **chunk_52.bin** | 52 | — | Extended — purpose unknown |
| **chunk_53.bin** | 53 | — | Extended — purpose unknown |
| **chunk_54.bin** | 54 | — | Extended — purpose unknown |
| **chunk_55.bin** | 55 | — | Extended — purpose unknown |
| **chunk_56.bin** | 56 | — | Extended — purpose unknown |
| **chunk_57.bin** | 57 | — | Extended — purpose unknown |

---

### zelres3/code/ — Level/World System

| File | Original | Chunk | Purpose |
|------|----------|-------|---------|
| `300LVLLD.asm` | ZR3_00 | chunk_00 | Level loading system |
| `314LVLRD.asm` | ZR3_14 | chunk_14 | Level tile renderer |
| `316TILCL.asm` | ZR3_16 | chunk_16 | Tile collision detection |
| `320TWNPC.asm` | ZR3_20 | chunk_20 | Town and NPC systems |
| `322ENBHV.asm` | ZR3_22 | chunk_22 | Enemy behavior in levels |
| `326NPCIT.asm` | ZR3_26 | chunk_26 | NPC interaction handler |
| `331TREVT.asm` | ZR3_31 | chunk_31 | Trigger and event system |
| `332ENMGR.asm` | ZR3_32 | chunk_32 | Enemy spawn/despawn manager |
| `333UTILS.asm` | ZR3_33 | chunk_33 | Small utility (623 bytes) |
| `334BOSAI.asm` | ZR3_34 | chunk_34 | Boss AI decision system |
| `335BOSPT.asm` | ZR3_35 | chunk_35 | Boss attack patterns |
| `337UTINY.asm` | ZR3_37 | chunk_37 | Tiny utility (770 bytes) |
| `356LVGRP.asm` | ZR3_56 | chunk_56 | **Extended** — Level graphics module; INT 10h BIOS video calls |

### zelres3/data/ — Maps, Dialogue, and Extended Data

| File | Chunk | Purpose |
|------|-------|---------|
| map_caverns.bin | 01 | Area 1: The Caverns |
| map_boss1_crab.bin | 02 | Boss 1: Cangrejo Arena |
| map_deeper_caverns.bin | 03 | Area 2: Deeper Caverns |
| map_forest.bin | 04 | Area 3: The Forest |
| map_boss2_octopus.bin | 05 | Boss 2: Pulpo Arena |
| map_boss3_chicken.bin | 06 | Boss 3: Pollo Arena |
| map_ice_caverns.bin | 07 | Area 4: Ice Caverns |
| map_graveyard.bin | 08 | Area 5: Graveyard Caverns |
| map_gold_caverns.bin | 09 | Area 6: Gold Caverns |
| map_flame_caverns.bin | 10 | Area 7: Flame Caverns |
| map_muralla_town.bin | 11 | Muralla Town (Surface) |
| map_satono_town.bin | 12 | Satono Town |
| map_bosque_town.bin | 13 | Bosque Town |
| map_helada_town.bin | 15 | Helada Town |
| map_boss4_arena.bin | 17 | Boss 4 Arena |
| map_boss5_arena.bin | 18 | Boss 5 Arena |
| map_boss6_arena.bin | 19 | Boss 6 Arena |
| dialogue_area1.bin | 21 | Area 1 dialogue |
| dialogue_area2.bin | 23 | Area 2 dialogue |
| dialogue_area3.bin | 24 | Area 3 dialogue |
| dialogue_area4.bin | 25 | Area 4 dialogue |
| dialogue_area5.bin | 27 | Area 5 dialogue |
| dialogue_area6.bin | 28 | Area 6 dialogue |
| dialogue_area7.bin | 29 | Area 7 dialogue |
| dialogue_area8.bin | 30 | Area 8 dialogue |
| dialogue_merchant.bin | 36 | Merchant/shop text |
| dialogue_extra.bin | 38 | Additional dialogue |
| ending_sequence.bin | 39 | Ending sequence (217KB) |
| **chunk_40.bin** | 40 | Extended — purpose unknown |
| **chunk_41.bin** | 41 | Extended — purpose unknown |
| **chunk_42.bin** | 42 | Extended — purpose unknown |
| **chunk_43.bin** | 43 | Extended — purpose unknown |
| **chunk_44.bin** | 44 | Extended — purpose unknown |
| **chunk_45.bin** | 45 | Extended — purpose unknown |
| **chunk_46.bin** | 46 | Extended — purpose unknown |
| **chunk_47.bin** | 47 | Extended — purpose unknown |
| **chunk_48.bin** | 48 | Extended — purpose unknown |
| **chunk_49.bin** | 49 | Extended — purpose unknown |
| **chunk_50.bin** | 50 | Extended — purpose unknown |
| **chunk_51.bin** | 51 | Extended — purpose unknown |
| **chunk_52.bin** | 52 | Extended — purpose unknown |
| **chunk_53.bin** | 53 | Extended — purpose unknown |
| **chunk_54.bin** | 54 | Extended — purpose unknown |
| **chunk_55.bin** | 55 | Extended — purpose unknown |
| *(chunk_56 = 356LVGRP.asm — code)* | | |
| **chunk_57.bin** | 57 | Extended — purpose unknown |
| **chunk_58.bin** | 58 | Extended — purpose unknown |
| **chunk_59.bin** | 59 | Extended — purpose unknown |
| **chunk_60.bin** | 60 | Extended — purpose unknown |
| **chunk_61.bin** | 61 | Extended — purpose unknown |
| **chunk_62.bin** | 62 | Extended — purpose unknown |
| **chunk_63.bin** | 63 | Extended — purpose unknown |
| **chunk_64.bin** | 64 | Extended — purpose unknown |
| **chunk_65.bin** | 65 | Extended — purpose unknown |
| **chunk_66.bin** | 66 | Extended — purpose unknown |
| **chunk_67.bin** | 67 | Extended — purpose unknown |
| **chunk_68.bin** | 68 | Extended — purpose unknown |
| **chunk_69.bin** | 69 | Extended — purpose unknown |
| **chunk_70.bin** | 70 | Extended — purpose unknown |
| **chunk_71.bin** | 71 | Extended — purpose unknown |
| **chunk_72.bin** | 72 | Extended — purpose unknown |
| **chunk_73.bin** | 73 | Extended — purpose unknown |
| **chunk_74.bin** | 74 | Extended — purpose unknown |
| **chunk_75.bin** | 75 | Extended — purpose unknown |
| **chunk_76.bin** | 76 | Extended — purpose unknown |
| **chunk_77.bin** | 77 | Extended — purpose unknown |
| **chunk_78.bin** | 78 | Extended — purpose unknown |
| **chunk_79.bin** | 79 | Extended — purpose unknown |
| **chunk_80.bin** | 80 | Extended — purpose unknown |
| **chunk_81.bin** | 81 | Extended — purpose unknown |
| **chunk_82.bin** | 82 | Extended — purpose unknown |
| **chunk_83.bin** | 83 | Extended — purpose unknown |
| **chunk_84.bin** | 84 | Extended — purpose unknown |
| **chunk_85.bin** | 85 | Extended — purpose unknown |
| **chunk_86.bin** | 86 | Extended — purpose unknown |
| **chunk_87.bin** | 87 | Extended — purpose unknown |
| **chunk_88.bin** | 88 | Extended — purpose unknown |
| **chunk_89.bin** | 89 | Extended — purpose unknown |
| **chunk_90.bin** | 90 | Extended — purpose unknown |
| **chunk_91.bin** | 91 | Extended — purpose unknown |
| **chunk_92.bin** | 92 | Extended — purpose unknown |
| **chunk_93.bin** | 93 | Extended — purpose unknown |
| **chunk_94.bin** | 94 | Extended — purpose unknown |
| **chunk_95.bin** | 95 | Extended — purpose unknown |

---

## Statistics

| Category | Code Files | Data Files | Total Chunks |
|----------|-----------|------------|--------------|
| Core | 2 | — | 2 executables |
| Drivers | 7 | — | 7 binaries |
| ZELRES1 | 14 | 26 | 40 (primary only) |
| ZELRES2 | 21 | 37 | 58 (40 primary + 18 extended) |
| ZELRES3 | 13 | 83 | 96 (40 primary + 56 extended) |
| **Total** | **57** | **146** | **194 chunks + 9 exe/drv = 203 files** |

All 57 code `.asm` files compile byte-perfect to their original binary outputs.
All three SAR archives rebuild byte-perfect from compiled chunks.
Each code `.asm` file has a paired `.sdf` (Sourcer Definition File).
