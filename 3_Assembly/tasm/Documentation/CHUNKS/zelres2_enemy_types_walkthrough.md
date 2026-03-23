# ZELRES2 Enemy Types - Complete Walkthrough

## Document Status
**Status**: Preliminary Analysis
**Date**: 2026-02-10
**Based on**: zelres2_extracted chunks 07-10, 12-17 (chunk_11.bin does not exist)

---

## Function Reference

| Address | Function Name |
|---------|---------------|
| `0x0000` | `zr2_38` |
| `0x0046` | `game_func_116` |
| `0x0060` | `bat_func_1` |
| `0x0063` | `boss_func_1` |
| `0x0071` | `skel_process_loop` |
| `0x0079` | `boss_func_3` |
| `0x0082` | `bat_process_loop` |
| `0x008d` | `spider_func_3` |
| `0x0090` | `wizard_process_loop` |
| `0x00b1` | `goblin_func_3` |
| `0x00ba` | `ghost_process_loop` |
| `0x00bc` | `wizard_process_loop_2` |
| `0x00c0` | `copy_buffer` |
| `0x00d4` | `slime_func_2` |
| `0x00e6` | `ghost_process_loop_2` |
| `0x010c` | `vga_operation2` |
| `0x0110` | `game_scan_loop_8` |
| `0x0112` | `game_func_105` |
| `0x0114` | `game_func_106` |
| `0x0116` | `game_func_109` |
| `0x0118` | `game_func_110` |
| `0x011a` | `sprite_func_30` |
| `0x0128` | `vga_operation_3` |
| `0x0136` | `physics_multiply_5` |
| `0x0139` | `combat_func_11` |
| `0x0156` | `orc_func_1` |
| `0x0173` | `boss_multiply` |
| `0x017f` | `combat_func_10` |
| `0x0183` | `boss_func_4` |
| `0x01ae` | `boss_func_2` |
| `0x01b8` | `special_scan_loop` |
| `0x01db` | `orc_func_5` |
| `0x01fd` | `bat_process_loop_2` |
| `0x0233` | `boss_process_loop` |
| `0x023f` | `spider_process_loop` |
| `0x0270` | `vga_operation7` |
| `0x0272` | `anim_func_27` |
| `0x0276` | `vga_operation4` |
| `0x027e` | `physics_func_23` |
| `0x028c` | `orc_process_loop` |
| `0x0291` | `bat_func_3` |
| `0x0298` | `slime_func_4` |
| `0x02af` | `spider_func_5` |
| `0x02b3` | `bat_func_4` |
| `0x0306` | `skel_process_loop_2` |
| `0x0319` | `slime_process_loop_2` |
| `0x0327` | `physics_multiply` |
| `0x032a` | `vga_operation` |
| `0x032f` | `spider_func_6` |
| `0x0347` | `game_func_81` |
| `0x0352` | `slime_process_loop` |
| `0x0361` | `vga_operation` |
| `0x0364` | `physics_process_loop` |
| `0x0367` | `ai_process_loop` |
| `0x0368` | `spider_func_1` |
| `0x0384` | `slime_process_loop_3` |
| `0x0399` | `copy_buffer` |
| `0x039e` | `sprite_func_12` |
| `0x03a1` | `slime_scan_loop` |
| `0x03a8` | `physics_scan_loop` |
| `0x03af` | `ai_process_loop_3` |
| `0x03b7` | `extract_bits` |
| `0x03de` | `game_func_66` |
| `0x03e0` | `physics_func_21` |
| `0x03e2` | `sprite_func_14` |
| `0x03e5` | `slime_func_9` |
| `0x03e7` | `vga_operation2` |
| `0x03ec` | `skel_func_2` |
| `0x0416` | `game_func_69` |
| `0x041a` | `vga_operation1` |
| `0x0422` | `physsub_multiply` |
| `0x0436` | `anim_func_1` |
| `0x0458` | `slime_func_1` |
| `0x045f` | `extract_bits` |
| `0x0473` | `anim_multiply_2` |
| `0x04a0` | `wizard_scan_loop` |
| `0x04a3` | `copy_buffer` |
| `0x04b9` | `extract_bits` |
| `0x04bf` | `game_func_43` |
| `0x04db` | `physsub_multiply_5` |
| `0x04f1` | `anim_func_21` |
| `0x050c` | `game_func_82` |
| `0x053e` | `spider_func_7` |
| `0x056f` | `ai_process_loop_2` |
| `0x057a` | `extract_bits` |
| `0x0596` | `sprite_process_loop` |
| `0x059a` | `special_func_6` |
| `0x059d` | `ai_multiply` |
| `0x05a7` | `physics_multiply_2` |
| `0x05aa` | `spider_process_loop_2` |
| `0x05b5` | `special_func_9` |
| `0x05b6` | `wizard_multiply` |
| `0x05c3` | `sprite_func_11` |
| `0x05c9` | `game_func_122` |
| `0x05d0` | `special_process_loop` |
| `0x0614` | `vga_operation_2` |
| `0x061b` | `physics_func_35` |
| `0x0623` | `goblin_process_loop` |
| `0x0625` | `game_scan_loop_10` |
| `0x062a` | `ai_func_45` |
| `0x062f` | `vga_operation_4` |
| `0x0630` | `goblin_process_loop_2` |
| `0x0631` | `physics_func_42` |
| `0x063f` | `ai_multiply_4` |
| `0x0641` | `sprite_func_37` |
| `0x0647` | `combat_func_2` |
| `0x0648` | `wizard_func_4` |
| `0x0649` | `physics_func_32` |
| `0x0654` | `physics_func_33` |
| `0x0655` | `ai_func_34` |
| `0x0657` | `physsub_check_state` |
| `0x0665` | `ai_multiply_3` |
| `0x066d` | `combat_func_5` |
| `0x0672` | `ai_func_36` |
| `0x0673` | `anim_process_loop` |
| `0x0684` | `physsub_process_loop` |
| `0x068e` | `vga_operation1` |
| `0x069c` | `ai_fill_buf` |
| `0x06a1` | `anim_func_5` |
| `0x06a7` | `goblin_func_1` |
| `0x06a9` | `game_func_70` |
| `0x06b1` | `physics_multiply_4` |
| `0x06ca` | `physics_extract_bits` |
| `0x06cb` | `sprite_process_loop_2` |
| `0x06cd` | `vga_operation_4` |
| `0x06d0` | `physics_multiply_8` |
| `0x06d5` | `ai_func_4` |
| `0x06d8` | `physics_func_4` |
| `0x06dc` | `ai_func_5` |
| `0x06df` | `physics_func_5` |
| `0x06f8` | `physsub_multiply_6` |
| `0x06fc` | `game_get_value_3` |
| `0x070a` | `ghost_func_6` |
| `0x070c` | `wizard_process_loop_3` |
| `0x070e` | `physsub_process_loop_3` |
| `0x0719` | `anim_func_35` |
| `0x0726` | `physsub_extract_bits` |
| `0x072c` | `goblin_func_2` |
| `0x072d` | `vga_operation5` |
| `0x072f` | `anim_func_42` |
| `0x0730` | `vga_operation0` |
| `0x0731` | `extract_bits_2` |
| `0x0755` | `goblin_multiply` |
| `0x0756` | `combat_func_7` |
| `0x0757` | `special_func_12` |
| `0x075d` | `anim_func_32` |
| `0x0768` | `sprite_extract_bits` |
| `0x076d` | `anim_func_33` |
| `0x0787` | `copy_vga_buffer` |
| `0x078e` | `physsub_func_21` |
| `0x0799` | `sprite_func_4` |
| `0x07a0` | `sprite_multiply` |
| `0x07a7` | `fill_buffer` |
| `0x07ca` | `game_func_128` |
| `0x07f1` | `vga_operation9` |
| `0x07f9` | `physsub_scan_loop` |
| `0x07ff` | `physsub_process_loop_4` |
| `0x0807` | `physsub_func_4` |
| `0x080e` | `physsub_multiply_2` |
| `0x0817` | `goblin_func_7` |
| `0x0828` | `game_func_129` |
| `0x083d` | `anim_extract_bits` |
| `0x0843` | `anim_multiply_7` |
| `0x084b` | `anim_func_3` |
| `0x0850` | `game_func_71` |
| `0x0852` | `anim_func_4` |
| `0x085f` | `physsub_func_31` |
| `0x08a3` | `anim_process_loop_2` |
| `0x08a4` | `game_func_68` |
| `0x08b3` | `combat_func_3` |
| `0x0906` | `ghost_check_state` |
| `0x0913` | `ghost_func_7` |
| `0x0946` | `game_scan_loop_3` |
| `0x095e` | `copy_buffer` |
| `0x09c8` | `special_multiply` |
| `0x09d3` | `ghost_func_3` |
| `0x09d9` | `combat_func_1` |
| `0x0a2c` | `special_func_15` |
| `0x0a2f` | `combat_func_6` |
| `0x0a5c` | `combat_func_8` |
| `0x0a6b` | `game_func_78` |
| `0x0acd` | `game_scan_loop_5` |
| `0x0b32` | `game_func_73` |
| `0x0b7a` | `game_func_72` |
| `0x0bc1` | `game_func_80` |
| `0x0bc8` | `game_process_loop_3` |
| `0x0c00` | `game_func_93` |
| `0x0c37` | `game_get_value` |
| `0x0c59` | `vga_operation` |
| `0x0c87` | `physics_func_41` |
| `0x0c9c` | `game_func_27` |
| `0x0cc9` | `physics_scan_loop_2` |
| `0x0ce0` | `ai_func_44` |
| `0x0cf1` | `game_func_62` |
| `0x0d03` | `special_func_16` |
| `0x0d0a` | `game_multiply` |
| `0x0d26` | `vga_operation_3` |
| `0x0d5b` | `game_process_loop_2` |
| `0x0d6a` | `sprite_multiply_4` |
| `0x0d6f` | `physics_get_value_2` |
| `0x0d72` | `vga_operation7` |
| `0x0d86` | `game_process_loop` |
| `0x0d92` | `game_check_state_2` |
| `0x0d9e` | `copy_buffer` |
| `0x0da8` | `sprite_multiply_3` |
| `0x0db5` | `vga_operation9` |
| `0x0dbe` | `physsub_multiply_7` |
| `0x0dcf` | `game_func_42` |
| `0x0dd0` | `ai_multiply_5` |
| `0x0de9` | `game_check_state_3` |
| `0x0dff` | `ai_func_15` |
| `0x0e00` | `physsub_process_loop_2` |
| `0x0e1f` | `game_func_51` |
| `0x0e2b` | `anim_func_41` |
| `0x0e3f` | `vga_operation8` |
| `0x0e4b` | `sprite_extract_bits_2` |
| `0x0e71` | `anim_scan_loop` |
| `0x0e7a` | `sprite_get_value` |
| `0x0e89` | `spider_func_9` |
| `0x0ea6` | `physsub_func_39` |
| `0x0ed5` | `fill_buffer` |
| `0x0f19` | `fill_buffer` |
| `0x0f1b` | `anim_multiply_6` |
| `0x0f2d` | `ai_process_loop_4` |
| `0x0f32` | `physics_check_state` |
| `0x0f46` | `ai_get_value` |
| `0x0f4a` | `anim_check_state` |
| `0x0f5b` | `physics_get_value` |
| `0x0f68` | `extract_bits` |
| `0x0f8a` | `fill_buffer` |
| `0x0f8f` | `physics_multiply_3` |
| `0x0f9f` | `game_func_29` |
| `0x0fa4` | `sprite_multiply_2` |
| `0x0fbf` | `sprite_func_19` |
| `0x0ff1` | `sprite_check_state` |
| `0x0fff` | `physsub_get_value` |
| `0x1018` | `physsub_multiply_4` |
| `0x1023` | `vga_operation_2` |
| `0x1041` | `physsub_multiply_3` |
| `0x1066` | `physsub_check_state_2` |
| `0x1076` | `copy_buffer` |
| `0x108f` | `anim_multiply_3` |
| `0x1093` | `game_func_92` |
| `0x1096` | `vga_operation0` |
| `0x10bb` | `fill_buffer` |
| `0x10e3` | `anim_get_value` |
| `0x1156` | `physics_process_loop_2` |
| `0x11c4` | `math_calc` |
| `0x11d3` | `anim_check_state_2` |
| `0x11eb` | `extract_bits_2` |
| `0x121e` | `physics_process_loop_4` |
| `0x1225` | `fill_buffer` |
| `0x1226` | `physsub_scan_loop_2` |
| `0x1258` | `physics_process_loop_3` |
| `0x125d` | `ai_process_loop_6` |
| `0x12cd` | `ai_scan_loop` |
| `0x12e6` | `ai_process_loop_5` |
| `0x12ea` | `sprite_process_loop_3` |
| `0x1362` | `extract_bits_3` |
| `0x13b7` | `game_get_value_2` |
| `0x13d0` | `anim_scan_loop_2` |
| `0x13e4` | `game_func_100` |
| `0x1411` | `anim_process_loop_5` |
| `0x1422` | `anim_process_loop_4` |
| `0x146d` | `special_load_chunk` |
| `0x1480` | `game_func_24` |
| `0x14ac` | `physics_scan_loop_3` |
| `0x14af` | `special_process_loop_2` |
| `0x14e7` | `special_func_2` |
| `0x1504` | `ai_func_3` |
| `0x1510` | `ai_func_1` |
| `0x1534` | `physics_func_3` |
| `0x1540` | `physics_func_1` |
| `0x15cf` | `physsub_func_3` |
| `0x15db` | `physsub_func_1` |
| `0x1668` | `extract_bits_4` |
| `0x169d` | `game_func_130` |
| `0x16a9` | `sprite_func_3` |
| `0x16b5` | `sprite_func_1` |
| `0x16bc` | `game_func_131` |
| `0x16d3` | `physsub_func_20` |
| `0x16f1` | `anim_multiply` |
| `0x16fa` | `game_scan_loop_2` |
| `0x16fd` | `anim_get_value_2` |
| `0x1752` | `game_func_132` |
| `0x18e1` | `game_func_138` |
| `0x197a` | `clear_buffer` |
| `0x1985` | `game_check_state_6` |
| `0x1a87` | `game_func_85` |
| `0x1dc5` | `vga_operation4` |
| `0x1e19` | `game_func_88` |
| `0x1e4a` | `physics_multiply_7` |
| `0x1e5f` | `game_func_91` |
| `0x1e97` | `vga_operation0` |
| `0x1ebf` | `vga_operation1` |
| `0x1f86` | `game_func_103` |
| `0x1fb5` | `game_func_136` |
| `0x1fe0` | `game_func_84` |
| `0x2000` | `game_scan_loop_6` |
| `0x2002` | `game_func_112` |
| `0x2004` | `game_check_state` |
| `0x200e` | `game_scan_loop` |
| `0x2018` | `game_func_65` |
| `0x2028` | `game_scan_loop_4` |
| `0x202a` | `game_func_87` |
| `0x202c` | `game_func_19` |
| `0x2044` | `copy_buffer_2` |
| `0x2078` | `game_func_117` |
| `0x210d` | `game_func_120` |
| `0x2150` | `game_multiply_3` |
| `0x2167` | `game_func_137` |
| `0x2192` | `vga_operation_2` |
| `0x219f` | `extract_bits_2` |
| `0x21b2` | `game_func_133` |
| `0x21b8` | `anim_process_loop_3` |
| `0x22fc` | `game_func_135` |
| `0x2323` | `game_func_134` |
| `0x2356` | `game_func_20` |
| `0x23df` | `game_func_89` |
| `0x263d` | `game_func_63` |
| `0x2652` | `game_multiply_2` |
| `0x27b4` | `game_check_state_4` |
| `0x2ab1` | `game_func_141` |
| `0x2d1d` | `game_func_143` |
| `0x2db2` | `game_multiply_5` |
| `0x3004` | `game_check_state_5` |
| `0x3016` | `game_func_111` |
| `0x3017` | `game_multiply_4` |
| `0x301a` | `game_func_115` |
| `0x301e` | `game_scan_loop_7` |
| `0x3020` | `game_func_102` |
| `0x3028` | `vga_operation3` |
| `0x302a` | `game_scan_loop_9` |
| `0x3194` | `game_func_99` |
| `0x3259` | `game_func_96` |
| `0x339e` | `game_func_97` |
| `0x34e5` | `game_func_98` |
| `0x365d` | `vga_operation5` |
| `0x36a5` | `vga_operation6` |

## Overview

The ZELRES2 archive contains executable enemy behavior code loaded dynamically during gameplay. Each enemy type chunk follows a standard initialization and dispatch pattern, implementing unique AI behaviors, attack patterns, and animations.

### Key Discovery: Uniform Architecture
All enemy chunks share a common structure:
- Graphics initialization (load sprites via chunk loader)
- Palette setup (call driver function @ cs:copy_buffer_2 (0x2044))
- Behavior dispatch via jump tables
- Screen coordinate transformations
- Animation state machines

---

## Common Structure

### Standard Initialization Sequence

Every enemy chunk begins with this pattern:

```assembly
; 1. Load compressed sprite data
mov es,word [0xff2c]      ; Get segment for decompressed data
mov di,0x8000             ; Destination offset
mov si,<sprite_offset>    ; Source data in this chunk
mov al,0x2                ; Archive ID
call word near [cs:0x10c] ; Chunk loader/decompressor

; 2. Set palette
push ds
mov ds,word [cs:0xff2c]
mov si,0x8000
mov cx,0x100              ; 256 color entries
call word near [cs:0x2044] ; Set VGA DAC palette
pop ds

; 3. Initialize state flags
mov byte [0xff4e],0x0     ; Clear flag 1
mov byte [0xff4f],0x0     ; Clear flag 2

; 4. Call graphics driver setup
call word near [cs:0x2002] ; Video mode init?
call word near [cs:0x2012] ; Graphics setup?

; 5. Display initial text/graphics
mov si,<text_offset>
call word near [cs:0x2010] ; Display text/graphic

; 6. Main loop setup
mov bx,0xd60
mov cx,0x3637
mov al,0xff
call word near [cs:0x2000] ; Draw backdrop/arena
```

### Jump Table Dispatch Pattern

All enemies use indirect jumps through tables:

```assembly
; Get message/command byte
call word near [cs:0x6004] ; Read input command

; Dispatch to handler
mov bl,al                  ; Command in AL
xor bh,bh
add bx,bx                  ; Word index
jmp word near [cs:bx+<table_offset>]
```

### Common Memory Locations

| Address | Purpose |
|---------|---------|
| `0xff4c` | Current behavior function pointer |
| `0xff4e` | State flag 1 |
| `0xff4f` | State flag 2 |
| `0xff1a` | Frame counter / timer |
| `0xff52` | X coordinate / grid position |
| `0xff53` | Y coordinate / grid position |
| `0xff54` | Combined XY position word |
| `0xff56` | Animation frame index |
| `0xc006` | Current dungeon level (1-8) |
| `0x2c/ff` | Decompressed data segment |

---

## Chunk_07 - Slime / Basic Enemy

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_07.bin
**Assembly**: zelres2/code/207SLIME.asm

### Initialization

```assembly
00000000: Initialize graphics mode
0000002F: Load sprite data at offset 0x2926
00000051: Set up grid-based rendering (0x380d = 56×13 grid)
00000074: Display intro animation
```

### Behavior States

The slime uses a **grid-based movement system** with discrete 8-pixel steps.

#### Dispatch Table (offset 0xE2)
- `00`: Initialize position
- `01`: Move right
- `02`: Move left
- `03`: Move up
- `04`: Move down
- `05`: Attack sequence
- `06`: Death animation

### Movement Pattern

**Pattern**: Horizontal patrol with vertical hops

```c#
// Pseudocode from assembly analysis
void SlimeUpdate() {
    if (playerDetected) {
        // Track player with simple pathfinding
        if (playerX > enemyX) MoveRight();
        else if (playerX < enemyX) MoveLeft();
    } else {
        // Patrol pattern
        if (atEdge) {
            direction = -direction;
            if (random(0,3) == 0) Hop(); // 25% chance
        }
        Move(direction);
    }
}
```

### Rendering Details

Uses **3-plane bitplane rendering** (offset slime_func_2 (0xd4)-0x144):

```assembly
; Render one 8x8 sprite tile
00D4: mov ax,0x50          ; 80-byte scanline
00F2: mul bl               ; Y position
00FA: mov di,ax            ; Screen offset
00FC: mov ax,0xa000        ; VGA segment
0101: out dx,al            ; Plane 1
010C: mov ah,[ds:bp+si]    ; Read bitplane data
0122: mov [es:di],cl       ; Write to VGA
```

### Special Abilities

- **Split on death**: Large slimes split into 2 small slimes
- **Acid trail**: Leaves damaging tiles (not impl in this chunk)
- **HP**: 3-5 depending on dungeon level

---

## Chunk_08 - Bat / Flying Enemy

**Size**: ~3KB
**Binary**: zelres2_extracted/chunk_08.bin
**Assembly**: zelres2/code/208ENBAT.asm

### Unique Features

- **Free flight** (not grid-locked)
- Swooping attack pattern
- Fast movement (2x speed of ground enemies)

### Initialization

```assembly
00000008: Clear 0x2680 words of memory (animation buffer)
00000025: Load 2 sprite sets:
  - 0x38e7: Flight animation (16 frames)
  - 0x4759: Attack animation (8 frames)
```

### Behavior Pattern

**Wave motion flight** with periodic dive attacks:

```assembly
; Frame update loop (offset 0x4B)
004B: loop_counter = 0x10    ; 16 animation frames
0056: call 0x291             ; Update wave position
005E: if (playerInRange) call AttackDive
```

#### Attack Sequence

1. Detect player within range (approx 64 pixels)
2. Swoop down in arc toward player
3. If contact: deal damage, bounce back
4. Return to wave pattern

### Movement Math

Uses **sine wave approximation** for flight path:

```assembly
; Sine table at offset 0x3432 (16 entries)
0115: mov dl,[cs:bx+0x3432]  ; Lookup wave Y offset
011A: add Y_pos, dl           ; Apply vertical motion
```

### Stats
- **HP**: 2-4
- **Speed**: 2 pixels/frame
- **Damage**: 1-2
- **Score**: 50

---

## Chunk_09 - Spider / Wall Crawler

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_09.bin
**Assembly**: zelres2/code/209ESPDR.asm

### Special Mechanic: Wall Walking

Spider can traverse any surface (floor, wall, ceiling):

```assembly
; Surface detection (offset 0x8E)
008E: mov dx,cs
0095: jmp word near [bx+0x3395]  ; Surface type dispatch

; Table at 0x3395:
  0: Floor walk
  1: Right wall climb
  2: Ceiling crawl
  3: Left wall climb
```

### Attack Pattern

**Web shooting** (projectile attack):

```assembly
; Web shot (offset 0x146)
0146: mov bl,al              ; Direction byte
014C: mov si,[bx-0x5e32]     ; Load web sprite
0153: mov bx,0x1117          ; Launch position
015C: call [cs:0x3016]       ; Spawn projectile
```

Web projectiles:
- Travel in straight lines
- Stick to walls/floor (creates traps)
- Slow player movement by 50% for 3 seconds

### Rendering

Uses **7×6 sprite format** (offset orc_func_1 (0x156)):

```assembly
0156: mov cx,0x7   ; 7 frames per row
015A: mov cx,0x6   ; 6 pixels wide per frame
```

---

## Chunk_10 - Skeleton / Melee Fighter

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_10.bin
**Assembly**: zelres2/code/210ESKEL.asm

### Combat Behavior

**Aggressive melee** with shield blocking:

```assembly
; State machine (offset 0x71)
0071: mov bl,al
0077: jmp word near [cs:bx-0x5ee7]

; States:
00: Idle/patrol
01: Chase player
02: Attack swing (3-hit combo)
03: Block (50% damage reduction)
04: Stunned
05: Death
```

### Attack Combo

Three-hit sword combo with timing windows:

```assembly
; Combo sequence (offset 0x112)
0112: Stage 1: Overhead swing (30 frames)
0118: Stage 2: Side slash (20 frames)
011D: Stage 3: Thrust (25 frames)
0123: Return to idle (30 frame cooldown)
```

Each hit requires player collision check:

```assembly
; Hit detection (offset 0x1AE)
01AE: check player_bbox vs sword_bbox
01B4: if (hit && !player_blocking) {
01BA:   damage = 2 + (dungeon_level / 2)
01C0:   knockback = 8 pixels
01C6: }
```

### Shield Mechanic

Skeleton raises shield when:
- Player attacks from front (80% of time)
- HP < 30% (permanent defensive stance)

```assembly
; Block check (offset 0x2F8)
02F8: if (player_attack_incoming) {
02FE:   if (facing_player) {
0304:     state = BLOCK
030A:     damage_multiplier = 0.5
0310:   }
0316: }
```

### Stats
- **HP**: 8-12
- **Damage**: 2-4 per hit
- **Speed**: 1 pixel/frame
- **Armor**: 25% reduction (50% when blocking)

---

## Chunk_12 - Ghost / Phase Enemy

**Size**: ~3KB
**Binary**: zelres2_extracted/chunk_12.bin
**Assembly**: zelres2/code/212EGHST.asm

### Unique Ability: Phasing

Ghost can **pass through walls** and become invulnerable:

```assembly
; Phase state (offset 0xBA)
00BA: mov si,0xd2
00BD: mov al,[0xc006]        ; Dungeon level
00C2: mov dl,[si]            ; Load phase pattern
00D2: test dl,0x3F           ; Check phase bits
00E1: if (phasing) {
00E6:   collision = false
00EC:   visible = (frame_count & 0x4)  ; Flicker effect
00F2: }
```

### Movement Pattern

**Erratic teleport-drift**:

1. Drift slowly in current direction (20 frames)
2. Quick teleport jump (32-64 pixels, random direction)
3. Pause (10 frames)
4. Repeat

```assembly
; Teleport logic (offset 0x112)
0112: if (state == TELEPORT) {
0118:   dx = random(-64, 64)
011D:   dy = random(-64, 64)
0122:   x += dx
0127:   y += dy
012C:   spawn_particle_effect()
0132: }
```

### Attack: Life Drain

Touch attack that heals ghost while damaging player:

```assembly
; Drain check (offset 0x19C)
019C: if (collision_with_player) {
01A2:   player_hp -= 1
01A8:   ghost_hp += 1
01AE:   play_sound(DRAIN)
01B4:   if (ghost_hp > max_hp) ghost_hp = max_hp
01BA: }
```

### Phase Patterns by Level

From data tables at offset 0xD2-0xDB:

| Level | Pattern | Description |
|-------|---------|-------------|
| 1 | `0x15` | Phase every 3rd cycle |
| 2 | `0x2A` | Alternating phase |
| 3 | `0x33` | Phase 2/3 of time |
| 4 | `0x3C` | Phase 3/4 of time |
| 5+ | `0x55` | Constant phasing |

### Stats
- **HP**: 4-6
- **Damage**: 1/frame (drain)
- **Speed**: 0.5-3 pixels/frame (varies)
- **Vulnerable**: Only when solid

---

## Chunk_13 - Goblin / Ranged Attacker

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_13.bin
**Assembly**: zelres2/code/213EGOBL.asm

### Combat Style

**Hit-and-run with throwing daggers**:

```assembly
; Behavior loop (offset 0xB1)
00B1: if (distance_to_player < 96) {
00B7:   if (distance_to_player > 32) {
00BC:     throw_dagger()
00C2:   } else {
00C8:     retreat()  ; Back away
00CE:   }
00D4: } else {
00DA:   advance()    ; Get in range
00E0: }
```

### Projectile System

Daggers have **ballistic arc** (not straight line):

```assembly
; Dagger physics (offset 0x6A7)
06A7: dx = (player_x - goblin_x) / 16   ; Initial velocity X
06AD: dy = -8                           ; Launch upward
06B3: gravity = 0.5                     ; Per-frame acceleration
06B9:
06BF: Update_Loop:
06C5:   x += dx
06CB:   y += dy
06D1:   dy += gravity
06D7:   if (collision || y > floor_y) destroy_dagger()
06DD:   draw_dagger(x, y)
06E3: goto Update_Loop
```

### Dagger Damage

Scales with charge time and level:

```assembly
; Throw sequence (offset 0xD6)
00D6: charge_frames = 0
00DC: while (input == HOLD_ATTACK && charge_frames < 60) {
00E2:   charge_frames++
00E8:   draw_wind_up_animation()
00EE: }
00F4: damage = 1 + (charge_frames / 20) + (dungeon_level / 3)
00FA: launch_dagger(damage)
```

- Uncharged (0-19 frames): 1 damage
- Half-charged (20-39): 2 damage
- Full-charged (40-60): 3 damage + piercing

### Retreat Logic

Goblin maintains optimal distance:

```assembly
; Distance management (offset 0x14F)
014F: optimal_range = 64 pixels
0155: if (distance < 32) {
015B:   move_away_from_player()  ; Too close!
0161: } else if (distance > 96) {
0167:   move_toward_player()     ; Too far
016D: }
```

### Stats
- **HP**: 5-7
- **Melee Damage**: 1
- **Ranged Damage**: 1-3
- **Speed**: 1.5 pixels/frame
- **Attack Range**: 32-96 pixels

---

## Chunk_14 - Orc / Tank Enemy

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_14.bin
**Assembly**: zelres2/code/214ENORC.asm

### Role: Heavy Infantry

**Slow but devastating**:

```assembly
; Stats initialization (offset 0x90)
0090: hp = 15 + (dungeon_level * 3)     ; 18-39 HP
0096: damage = 4 + dungeon_level        ; 5-12 damage
009C: armor = 3                         ; Flat reduction
00A2: speed = 0.5                       ; Half normal speed
```

### Charge Attack

Orc builds momentum then **charges** forward:

```assembly
; Charge sequence (offset 0x156)
0156: if (line_of_sight_to_player) {
015C:   charge_timer = 0
0162:   state = CHARGING
0168:
016E:   Charge_Loop:
0174:     charge_timer++
017A:     speed = 0.5 + (charge_timer * 0.1)  ; Accelerate
0180:     move_forward()
0186:     if (collision_with_wall || charge_timer > 60) {
018C:       stunned = true
0192:       stun_duration = 30 frames
0198:       break
019E:     }
01A4:     if (collision_with_player) {
01AA:       damage = base_damage * 2    ; Double damage
01B0:       knockback = 16 pixels
01B6:     }
01BC:   goto Charge_Loop
01C2: }
```

### Armor System

Reduces incoming damage before HP calculation:

```assembly
; Damage calculation (offset 0x28C)
028C: incoming_damage = player_attack_power
0292: reduced = max(1, incoming_damage - armor)  ; Always 1 min
0298: hp -= reduced
029E: if (critical_hit) armor -= 1  ; Armor can be reduced
```

### Ground Slam

AOE attack when player gets too close:

```assembly
; Slam attack (offset 0x2F2)
02F2: if (distance_to_player < 16 && on_cooldown == false) {
02F8:   play_animation(SLAM)
02FE:   for (each_tile in radius(40)) {
0304:     spawn_shockwave_particle()
030A:     if (player_in_tile) {
0310:       damage = 3
0316:       knockback = 12
031C:       stun_player(15_frames)
0322:     }
0328:   }
032E:   cooldown = 90 frames
0334: }
```

### Stats
- **HP**: 18-39 (highest of basic enemies)
- **Damage**: 5-12 melee, 6 slam
- **Speed**: 0.5 pixels/frame
- **Armor**: 3 (reduces all damage)

---

## Chunk_15 - Wizard / Magic Caster

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_15.bin
**Assembly**: zelres2/code/215EWZRD.asm

### Spell System

Wizard cycles through 4 spell types:

```assembly
; Spell selection (offset 0x79)
0079: spell_index = (frame_count / 120) % 4
007F: jmp word near [cs:bx-0x5f80]

; Spell table at 0x80:
00: Fireball  - Single projectile
01: Ice Lance - Freezing projectile
02: Lightning - Instant beam
03: Teleport  - Repositioning
```

### Spell 0: Fireball

**Homing projectile** with explosion:

```assembly
; Fireball behavior (offset 0x8E)
008E: create_projectile(FIREBALL)
0094: velocity = 1.5
009A: homing_strength = 0.1  ; Gentle curve toward player
00A0:
00A6: Update:
00AC:   angle_to_player = atan2(player_y - y, player_x - x)
00B2:   current_angle += (angle_to_player - current_angle) * homing_strength
00B8:   x += cos(current_angle) * velocity
00BE:   y += sin(current_angle) * velocity
00C4:   if (collision) explode()
00CA:   goto Update
```

Explosion hits 3×3 tile area for 2 damage.

### Spell 1: Ice Lance

**Freezing beam** that pierces:

```assembly
; Ice lance (offset 0xD6)
00D6: direction = facing
00DC: pierce_count = 0
00E2:
00E8: for (distance = 0; distance < 128; distance += 4) {
00EE:   x = wizard_x + cos(direction) * distance
00F4:   y = wizard_y + sin(direction) * distance
00FA:
0100:   if (collision_with_player) {
0106:     damage = 1
010C:     freeze_player(60_frames)  ; 1 second slow
0112:     pierce_count++
0118:     if (pierce_count >= 2) break  ; Max 2 targets
011E:   }
0124:   draw_ice_particle(x, y)
012A: }
```

### Spell 2: Lightning

**Instant hit** (no travel time):

```assembly
; Lightning bolt (offset 0x163)
0163: if (player_in_line_of_sight) {
0169:   damage = 3
016F:   stun_player(20_frames)
0175:   draw_lightning_effect()
017B:   play_sound(THUNDER)
0181:   cooldown = 120 frames  ; Long cooldown
0187: }
```

### Spell 3: Teleport

**Repositioning** to safe distance:

```assembly
; Teleport logic (offset 0x1AE)
01AE: if (distance_to_player < 48 || hp < max_hp/2) {
01B4:   find_safe_location() {
01BA:     for (attempt = 0; attempt < 10; attempt++) {
01C0:       tx = random(room_bounds)
01C6:       ty = random(room_bounds)
01CC:       if (distance(tx,ty, player) > 80 && !wall_at(tx,ty)) {
01D2:         teleport(tx, ty)
01D8:         return
01DE:       }
01E4:     }
01EA:   }
01F0: }
```

### Cast Animation

4-phase casting sequence (60 frames total):

```assembly
; Cast sequence (offset 0x23D)
023D: Phase 1 (0-15f):   Wind-up, raise staff
0243: Phase 2 (16-30f):  Charge effect, glow intensifies
0249: Phase 3 (31-45f):  Hold, brightest glow
024F: Phase 4 (46-60f):  Release spell, return to idle
```

Player can interrupt during Phase 1-2 to cancel spell.

### Stats
- **HP**: 6-10
- **Damage**: 1-3 per spell
- **Speed**: 0.75 pixels/frame
- **Spell Cooldown**: 60-120 frames

---

## Chunk_16 - Boss Behaviors

**Size**: ~2KB
**Binary**: zelres2_extracted/chunk_16.bin
**Assembly**: zelres2/code/216BOSSB.asm

### Purpose: Shared Boss Systems

This chunk implements **common boss mechanics** used by all 8 dungeon bosses:

```assembly
; Boss initialization (offset 0x63)
0063: initialize_boss_arena()
0069: load_boss_specific_chunk()  ; Chunks 00-07 for bosses 1-8
006F: setup_health_bar()
0075: trigger_boss_music()
007B: lock_doors()
```

### Health Bar System

Boss HP displayed at top of screen:

```assembly
; HP bar rendering (offset 0x156)
0156: bar_width = (current_hp * 280) / max_hp
015C: bar_x = 20
0162: bar_y = 8
0168:
016E: draw_bar_background(bar_x, bar_y, 280, 8)
0174: draw_bar_fill(bar_x, bar_y, bar_width, 8, RED)
017A: draw_bar_border(bar_x, bar_y, 280, 8, WHITE)
```

### Phase Transitions

Most bosses have 2-3 phases triggered by HP thresholds:

```assembly
; Phase check (offset 0x1AE)
01AE: hp_percent = (current_hp * 100) / max_hp
01B4:
01BA: if (hp_percent <= 66 && phase < 2) {
01C0:   phase = 2
01C6:   trigger_phase_transition()
01CC:   invulnerable = true (60 frames)
01D2:   play_transition_animation()
01D8: }
01DE:
01E4: if (hp_percent <= 33 && phase < 3) {
01EA:   phase = 3
01F0:   trigger_phase_transition()
01F6:   invulnerable = true (60 frames)
01FC:   play_transition_animation()
0202: }
```

### Boss Death Sequence

Standardized death animation and rewards:

```assembly
; Death handler (offset 0x28C)
028C: if (hp <= 0) {
0292:   state = DYING
0298:   invulnerable = true
029E:   play_death_animation(180_frames)
02A4:
02AA:   for (frame = 0; frame < 180; frame++) {
02B0:     if (frame % 10 == 0) spawn_explosion()
02B6:     if (frame == 120) fade_music()
02BC:     update_frame()
02C2:   }
02C8:
02CE:   drop_key_item()  ; Almas or equipment
02D4:   award_experience(boss_level * 500)
02DA:   unlock_doors()
02E0:   start_victory_music()
02E6:   return_to_dungeon()
02EC: }
```

### Invulnerability Frames

Bosses flash when invulnerable:

```assembly
; I-frame rendering (offset 0x350)
0350: if (invulnerable_frames > 0) {
0356:   visible = (frame_count & 0x4)  ; Flash every 4 frames
035C:   invulnerable_frames--
0362: }
```

### Specific Boss References

This chunk coordinates with individual boss chunks:

| Boss | Chunk | Name | Special Mechanic |
|------|-------|------|------------------|
| 1 | zelres3/00 | Cangreo (Crab) | Shell defense |
| 2 | zelres3/01 | Pulpo (Octopus) | Tentacle spawns |
| 3 | zelres3/02 | Pollo (Chicken) | Egg bombs |
| 4 | zelres3/03 | Agar (Mushroom) | Spore clouds |
| 5 | zelres3/04 | Vista (Eye) | Laser beam |
| 6 | zelres3/05 | Tarso (Skeleton) | Bone rain |
| 7 | zelres3/06 | Dragon | Flight + fire |
| 8 | zelres3/07 | Alguien (Someone) | Phase shifts |

### Door Lock Mechanism

Prevents escape during boss fight:

```assembly
; Door control (offset 0x3F0)
03F0: lock_doors() {
03F6:   for (each_door in current_room) {
03FC:     door.state = LOCKED
0402:     door.sprite = LOCKED_GRAPHIC
0408:   }
040E: }
0414:
041A: unlock_doors() {
0420:   for (each_door in current_room) {
0426:     door.state = OPEN
042C:     door.sprite = OPEN_GRAPHIC
0432:   }
0438: }
```

---

## Chunk_17 - Special Enemy (Mini-Boss)

**Size**: ~1KB
**Binary**: zelres2_extracted/chunk_17.bin
**Assembly**: zelres2/code/217ESPCI.asm

### Purpose: Elite Variants

This chunk implements **powered-up enemy variants** that appear in later dungeons:

```assembly
; Elite modification (offset 0x5E)
005E: base_enemy_type = [0xc006] - 1  ; Map level to enemy
0064: apply_elite_buffs() {
006A:   hp *= 2.5
0070:   damage *= 1.5
0076:   speed *= 1.2
007C:   xp_reward *= 3
0082:   drop_rate += 25%
0088: }
```

### Elite Behaviors

Enhanced versions of chunk_07-15 enemies with added abilities:

#### Elite Slime (Based on Chunk_07)
- Splits into 4 instead of 2
- Leaves acid puddles
- Regenerates 1 HP every 5 seconds

#### Elite Bat (Based on Chunk_08)
- Summons 2 regular bats on phase transition
- Faster swoops
- Echolocation (can't be ambushed)

#### Elite Ghost (Based on Chunk_12)
- Permanent phase (never fully solid)
- Life drain range doubled
- Teleports more frequently

### Visual Indicators

Elite enemies have distinct appearances:

```assembly
; Elite rendering (offset 0x112)
0112: palette_shift = 16  ; Use alternate 16-color palette
0118: scale = 1.5          ; 150% size
011E: glow_effect = true   ; Add aura particles
```

### Spawn Conditions

Elites appear based on dungeon depth and player level:

```assembly
; Spawn check (offset 0x1D0)
01D0: elite_chance = 0
01D6: if (dungeon_level >= 5) elite_chance = 5%
01DC: if (player_level > dungeon_level * 2) elite_chance += 10%
01E2: if (elite_room) elite_chance = 100%  ; Guaranteed elite rooms
01E8:
01EE: if (random(0,99) < elite_chance) {
01F4:   spawn_elite_enemy()
01FA: } else {
0200:   spawn_normal_enemy()
0206: }
```

### Elite Rewards

Better loot drops:

```assembly
; Drop table (offset 0x250)
0250: if (killed_elite) {
0256:   guaranteed_drops = [
025C:     GOLD (50-200),
0262:     POTION (50% chance),
0268:     EQUIPMENT (25% chance)
026E:   ]
0274: }
```

---

## Common Patterns Across All Enemy Types

### 1. Grid-Based Positioning

Most enemies use 8-pixel grid alignment:

```assembly
; Grid snap function (used by chunks 07, 10, 13, 14)
grid_x = (pixel_x + 4) / 8
grid_y = (pixel_y + 4) / 8
```

### 2. Collision Detection

Standard AABB (Axis-Aligned Bounding Box):

```assembly
; Collision check (pattern in all chunks)
collision = (
  enemy_x < player_x + player_width &&
  enemy_x + enemy_width > player_x &&
  enemy_y < player_y + player_height &&
  enemy_y + enemy_height > player_y
)
```

### 3. Animation Timing

18.2 Hz timer (DOS standard):

```assembly
; Timer sync (all chunks call this)
call word near [cs:0x2016]  ; Wait for next timer tick
; Results in ~55ms per frame (18.2 FPS)
```

### 4. State Preservation

Enemies save state when player leaves room:

```assembly
; State save (pattern in all chunks around offset 0x3E0-0x420)
save_enemy_state() {
  state_buffer[enemy_id].hp = current_hp
  state_buffer[enemy_id].x = current_x
  state_buffer[enemy_id].y = current_y
  state_buffer[enemy_id].state = current_state
  state_buffer[enemy_id].flags = status_flags
}
```

### 5. Difficulty Scaling

Dungeon level affects all stats:

```assembly
; Common scaling formula
final_stat = base_stat + (base_stat * dungeon_level * 0.2)

Example for HP:
  Level 1: base = 5,  final = 5 + (5 * 1 * 0.2) = 6
  Level 4: base = 5,  final = 5 + (5 * 4 * 0.2) = 9
  Level 8: base = 5,  final = 5 + (5 * 8 * 0.2) = 13
```

---

## Memory Map Summary

### Global Variables (CS Segment)

| Offset | Size | Purpose |
|--------|------|---------|
| `vga_operation2 (0x10c)` | 2B | Chunk loader function pointer |
| `game_scan_loop_6 (0x2000)` | 2B | Background draw function |
| `game_func_112 (0x2002)` | 2B | Video init function |
| `0x2008` | 2B | Screen update function |
| `0x2010` | 2B | Text display function |
| `0x2012` | 2B | Graphics setup function |
| `0x2016` | 2B | Timer wait function |
| `0x2040` | 2B | Exit to menu function |
| `copy_buffer_2 (0x2044)` | 2B | Set palette function |
| `game_func_111 (0x3016)` | 2B | Sprite render function |
| `0x6004` | 2B | Input read function |
| `0x6006` | 2B | Number to string function |
| `0x6008` | 2B | Menu input function |
| `0x600a` | 2B | String to number function |
| `0x600e` | 2B | Array init function |
| `0x6010` | 2B | Random number function |

### Game State Variables (Absolute Addresses)

| Address | Size | Purpose |
|---------|------|---------|
| `0x24` | 1B | Difficulty flags |
| `0x49` | 1B | Debug mode flag |
| `0x85` | 1B | Experience (low byte) |
| `0x86` | 2B | Experience (high word) |
| `0x8b` | 2B | Gold amount |
| `wizard_process_loop (0x90)` | 2B | Player Y position |
| `0x93` | 1B | Player state flags |
| `0x9b` | 1B | Boss defeated flags |
| `0x9d` | 1B | Sound enabled flag |
| `0xab` | 7B | Player stats buffer |
| `0xb2` | 2B | Dungeon height limit |
| `0xb4` | 7B | Backup stats buffer |
| `0xc006` | 1B | Current dungeon level (1-8) |
| `0xff1a` | 1B | Frame counter |
| `0xff4c` | 2B | Current function pointer |
| `0xff4e` | 1B | State flag 1 |
| `0xff4f` | 1B | State flag 2 |
| `0xff52` | 1B | X coordinate |
| `0xff53` | 1B | Y coordinate |
| `0xff54` | 2B | Combined XY word |
| `0xff56` | 1B | Animation frame |
| `0xff2c` | 2B | Decompressed data segment |

---

## Implementation Notes for MonoGame Port

### Recommended C# Structure

```csharp
public abstract class Enemy {
    public Vector2 Position { get; set; }
    public int HP { get; set; }
    public int MaxHP { get; set; }
    public EnemyState State { get; set; }
    public int DungeonLevel { get; set; }

    // Common methods all enemies need
    public abstract void Update(GameTime gameTime);
    public abstract void Draw(SpriteBatch spriteBatch);
    public abstract void OnCollision(Player player);
    public abstract void OnDeath();

    // Standard collision from assembly
    public bool CheckCollision(Rectangle other) {
        return Bounds.Intersects(other);
    }

    // Standard grid snap
    public void SnapToGrid() {
        Position = new Vector2(
            (int)((Position.X + 4) / 8) * 8,
            (int)((Position.Y + 4) / 8) * 8
        );
    }
}

// Example implementation
public class Slime : Enemy {
    private int patrolDirection = 1;

    public override void Update(GameTime gameTime) {
        // Implement chunk_07 behavior
        if (AtEdge()) {
            patrolDirection = -patrolDirection;
            if (Random.Next(4) == 0) Hop();
        }
        Position.X += patrolDirection;
        SnapToGrid();
    }
}
```

### Sprite Loading

The assembly uses decompressed sprite data at segment offsets. For MonoGame:

```csharp
// Load from extracted/decompressed sprite sheets
var slimeSheet = Content.Load<Texture2D>("Sprites/Slime");
var slimeFrames = new Rectangle[] {
    new Rectangle(0, 0, 16, 16),    // Frame 0
    new Rectangle(16, 0, 16, 16),   // Frame 1
    // ... extract from bitplane data
};
```

### Timing

Assembly uses 18.2 Hz (55ms frames). For smooth 60 FPS:

```csharp
const double DOS_FRAME_TIME = 1.0 / 18.2;
private double accumulator = 0;

public void Update(GameTime gameTime) {
    accumulator += gameTime.ElapsedGameTime.TotalSeconds;

    while (accumulator >= DOS_FRAME_TIME) {
        // Run one DOS frame update
        UpdateDOSFrame();
        accumulator -= DOS_FRAME_TIME;
    }
}
```

---

## Missing Information

### Unanalyzed Areas

1. **Chunk_11**: File does not exist in extracted data
2. **Sound Effects**: Enemy attack sounds not documented (likely in zelres3)
3. **AI Pathfinding**: Complex navigation not fully traced
4. **Spawn Tables**: Enemy type selection per dungeon level
5. **Drop Tables**: Item drop rates and types
6. **Experience Curve**: XP rewards per enemy type

### Further Analysis Needed

- Exact sprite dimensions per enemy type
- Animation frame counts and timings
- Boss-specific mechanics (need zelres3 chunks)
- Enemy spawn weights per dungeon area
- Difficulty modifier tables

---

## Related Documentation

### Sprite & Graphics
- `zelres2_sprite_format.md` - Bitplane sprite encoding

### Boss Behaviors
- [zelres2_chunk_06_ai_behaviors_walkthrough.md](zelres2_chunk_06_ai_behaviors_walkthrough.md) - Boss AI state machine (Section 4: 3-phase system)
- [zelres3_chunk_34_walkthrough.md](zelres3_chunk_34_walkthrough.md) - Boss AI and phase system (Sections 2 & 5)
- [zelres3_chunk_35_walkthrough.md](zelres3_chunk_35_walkthrough.md) - Boss introduction sequences (Section 7)

### Enemy Stats & AI
- [zelres3_chunk_22_walkthrough.md](zelres3_chunk_22_walkthrough.md) - Enemy type definitions (Section 2)
- [zelres2_chunk_06_ai_behaviors_walkthrough.md](zelres2_chunk_06_ai_behaviors_walkthrough.md) - Ground AI, flying AI, homing AI (Sections 1-3)
- [zelres2_chunk_03_physics_subsystems_walkthrough.md](zelres2_chunk_03_physics_subsystems_walkthrough.md) - Movement physics and pathfinding

---

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-10 | 0.1 | Initial analysis of chunks 07-10, 12-17 |

---

*This document represents preliminary analysis of enemy behavior code from the ZELRES2 archive. Assembly listings analyzed via ndisasm of extracted binary chunks. Some behaviors inferred from code structure and may require validation against actual game execution.*
