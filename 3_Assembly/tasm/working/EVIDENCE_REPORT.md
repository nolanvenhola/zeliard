# Deterministic Evidence Check — Contested Addresses

Evidence-supported verdicts on contested name claims. Each claim is
checked against deterministic evidence (initial byte values, nearby
strings, code references, hardware/DOS calls) — no LLM judgment.

| File | Address | IDA claim | Init byte | Verdict | Evidence |
|---|---|---|---|---|---|
| stdply | `0x80` | `proximity_map_left_col_x` | 0x1E | **INCONCLUSIVE** | no verdict heuristic for this claim |
| stdply | `0x83` | `hero_x_in_viewport` | 0x0A | **INCONCLUSIVE** | no verdict heuristic for this claim |
| stdply | `0x85` | `hero_gold_hi` | 0x00 | **SUPPORTED** | init byte = 0x00, consistent with starting with 0 gold |
| stdply | `0x86` | `hero_gold_lo` | 0x00 | **SUPPORTED** | init byte = 0x00, consistent with starting with 0 gold |
| stdply | `0x8B` | `hero_almas` | 0x00 | **SUPPORTED** | init byte = 0x00, consistent with starting with 0 gold |
| stdply | `0x90` | `hero_HP` | 0x50 | **SUPPORTED** | init byte 0x50=80 in HP range; matches manual's starting HP if 0x50=80 |
| stdply | `0x92` | `sword_type` | 0x01 | **SUPPORTED** | init byte = 1 = SWORD_TRAINING (matches manual's starting weapon) |
| stdply | `0x93` | `shield_type` | 0x00 | **SUPPORTED** | init byte = 0, consistent with no starting shield |
| stdply | `0x94` | `shield_HP` | 0x00 | **CONTRADICTED** | init byte 0x00=0 outside plausible HP range |
| stdply | `0x9D` | `current_magic_spell` | 0x00 | **SUPPORTED** | init byte = 0, consistent with no starting shield |
| stdply | `0xAB` | `spells_espada` | 0x0C | **INCONCLUSIVE** | no verdict heuristic for this claim |

**Phase 1 (data fields)**: 7 supported / 1 contradicted / 3 inconclusive

## Phase 2 — Code-Pointer Dispatch Slots

Validates that each dispatch slot in a binary holds the address
of the procedure IDA labels for it. Match is by byte signature
(deterministic) — no LLM judgment.

| File | Slot addr | IDA claim | Slot value | Verdict | Evidence |
|---|---|---|---|---|---|
| fight | `0x6008` | `move_monster_E` | 0x91E5 | **SUPPORTED** | slot 0x6008 -> 0x91E5; bytes match `80 7C 03 22 F5 73 01 C3` (cmp [si+3],22h / cmc / jnb +1 / ret) |
| fight | `0x600A` | `move_monster_NE` | 0x91F6 | **SUPPORTED** | slot 0x600A -> 0x91F6; bytes match `80 7C 03 22 F5 73 01 C3` (cmp [si+3],22h / cmc / jnb +1 / ret) |
| fight | `0x600C` | `move_monster_N` | 0x920A | **SUPPORTED** | slot 0x600C -> 0x920A; bytes match `8A 44 03 0A C0 F9 75 01 C3` (mov al,[si+3] / or al,al / stc / jnz +1 / ret) |
| fight | `0x600E` | `move_monster_NW` | 0x9222 | **SUPPORTED** | slot 0x600E -> 0x9222; bytes match `80 7C 03 02 73 01 C3` (cmp [si+3],02h / jnb +1 / ret) |
| fight | `0x6010` | `move_monster_W` | 0x9234 | **SUPPORTED** | slot 0x6010 -> 0x9234; bytes match `80 7C 03 02 73 01 C3` (cmp [si+3],02h / jnb +1 / ret) |
| fight | `0x6012` | `move_monster_SW` | 0x9243 | **SUPPORTED** | slot 0x6012 -> 0x9243; bytes match `80 7C 03 02 73 01 C3` (cmp [si+3],02h / jnb +1 / ret) |
| fight | `0x6014` | `move_monster_S` | 0x9255 | **SUPPORTED** | slot 0x6014 -> 0x9255; bytes match `8A 44 03 0A C0 F9 75 01 C3` (mov al,[si+3] / or al,al / stc / jnz +1 / ret) |
| fight | `0x6016` | `move_monster_SE` | 0x926C | **SUPPORTED** | slot 0x6016 -> 0x926C; bytes match `80 7C 03 22 F5 73 01 C3` (cmp [si+3],22h / cmc / jnb +1 / ret) |
| fight | `0x6018` | `check_collision_E2` | 0x92B4 | **SUPPORTED** | slot 0x6018 -> 0x92B4; bytes match `8B 44 02 E8 ?? ?? 47 47` (mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di) |
| fight | `0x601A` | `check_collision_W2` | 0x930A | **SUPPORTED** | slot 0x601A -> 0x930A; bytes match `8B 44 02 E8 ?? ?? 4F E8` (mov ax,[si+2] / call coords_to_addr / [..] / dec di / call) |
| fight | `0x601C` | `check_collision_N2` | 0x9362 | **SUPPORTED** | slot 0x601C -> 0x9362; bytes match `8B 44 02 E8 ?? ?? 87 F7 83 EE 24` (mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / sub si,36) |
| fight | `0x601E` | `check_collision_S2` | 0x939A | **SUPPORTED** | slot 0x601E -> 0x939A; bytes match `8B 44 02 E8 ?? ?? 87 F7 83 C6 48` (mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / add si,72) |
| fight | `0x6020` | `check_collision_NE2` | 0x93C5 | **SUPPORTED** | slot 0x6020 -> 0x93C5; bytes match `8B 44 02 E8 ?? ?? 47 47` (mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di) |
| fight | `0x6022` | `check_collision_SE2` | 0x940C | **SUPPORTED** | slot 0x6022 -> 0x940C; bytes match `8B 44 02 E8 ?? ?? 47 47` (mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di) |
| fight | `0x6024` | `check_collision_NW2` | 0x9452 | **SUPPORTED** | slot 0x6024 -> 0x9452; bytes match `8B 44 02 E8 ?? ?? 4F 8A 05` (mov ax,[si+2] / call coords_to_addr / [..] / dec di / mov al,[di]) |
| fight | `0x6026` | `check_collision_SW2` | 0x949A | **SUPPORTED** | slot 0x6026 -> 0x949A; bytes match `8B 44 02 E8 ?? ?? 4F 4F` (mov ax,[si+2] / call coords_to_addr / [..] / dec di / dec di) |
| town | `0x6000` | `town_entry_normal` | 0x6026 | **SUPPORTED** | slot 0x6000 -> 0x6026; bytes match `2E C6 06 43 7C 00` (mov cs:byte ptr [7C43h], 0  ; clear disable_edge_scroll) |
| town | `0x6002` | `town_entry_init` | 0x601E | **SUPPORTED** | slot 0x6002 -> 0x601E; bytes match `2E C6 06 43 7C FF EB 06` (mov cs:byte ptr [7C43h], 0FFh / jmp short town_entry_common) |
| town | `0x600A` | `check_gold_sufficient` | 0x7570 | **SUPPORTED** | slot 0x600A -> 0x7570; bytes match `8A 1E 85 00 2A DA 73 01 C3` (mov bl, ds:[85h] (hero_gold_hi) / sub bl,bl / jnb +1 / ret) |
| town | `0x600C` | `add_gold_to_hero` | 0x7589 | **SUPPORTED** | slot 0x600C -> 0x7589; bytes match `01 06 86 00 10 16 85 00 C3` (add ds:[86h],ax / adc ds:[85h],dx / ret  ; gold_lo += AX, gold_hi += DX+CF) |
| town | `0x601C` | `restore_game` | 0x7592 | **SUPPORTED** | slot 0x601C -> 0x7592; bytes match `?? ?? B8 03 00 CD 60` (mov ax, 3 / int 60h  ; mscadlib (audio driver) restore-state call) |

**Phase 2 (code pointers)**: 21 supported / 0 contradicted / 0 inconclusive

## Phase 3 — Structural Directional Grouping

Cross-claim consistency check: do the 8 dispatch targets cluster
into the directional families IDA's labels imply? If all 3 east
targets share one byte prefix, all 3 west targets share another,
and both vertical targets share a third, the labels are validated
STRUCTURALLY (independent of any single signature definition).

### Family `move_east_x` (3 member(s), prefix 8 bytes)
- **Cohesive**: all 3 share prefix `80 7c 03 22 f5 73 01 c3`
  - `move_monster_E` slot 0x6008 -> 0x91E5: `80 7c 03 22 f5 73 01 c3`
  - `move_monster_NE` slot 0x600A -> 0x91F6: `80 7c 03 22 f5 73 01 c3`
  - `move_monster_SE` slot 0x6016 -> 0x926C: `80 7c 03 22 f5 73 01 c3`

### Family `move_west_x` (3 member(s), prefix 7 bytes)
- **Cohesive**: all 3 share prefix `80 7c 03 02 73 01 c3`
  - `move_monster_W` slot 0x6010 -> 0x9234: `80 7c 03 02 73 01 c3`
  - `move_monster_NW` slot 0x600E -> 0x9222: `80 7c 03 02 73 01 c3`
  - `move_monster_SW` slot 0x6012 -> 0x9243: `80 7c 03 02 73 01 c3`

### Family `move_vertical` (2 member(s), prefix 9 bytes)
- **Cohesive**: all 2 share prefix `8a 44 03 0a c0 f9 75 01 c3`
  - `move_monster_N` slot 0x600C -> 0x920A: `8a 44 03 0a c0 f9 75 01 c3`
  - `move_monster_S` slot 0x6014 -> 0x9255: `8a 44 03 0a c0 f9 75 01 c3`

### Family `collision_universal` (8 member(s), prefix 4 bytes)
- **Cohesive**: all 8 share prefix `8b 44 02 e8`
  - `check_collision_E2` slot 0x6018 -> 0x92B4: `8b 44 02 e8`
  - `check_collision_W2` slot 0x601A -> 0x930A: `8b 44 02 e8`
  - `check_collision_N2` slot 0x601C -> 0x9362: `8b 44 02 e8`
  - `check_collision_S2` slot 0x601E -> 0x939A: `8b 44 02 e8`
  - `check_collision_NE2` slot 0x6020 -> 0x93C5: `8b 44 02 e8`
  - `check_collision_SE2` slot 0x6022 -> 0x940C: `8b 44 02 e8`
  - `check_collision_NW2` slot 0x6024 -> 0x9452: `8b 44 02 e8`
  - `check_collision_SW2` slot 0x6026 -> 0x949A: `8b 44 02 e8`

**Structural consistency**: PASS — all 3 families cohere

## Detailed evidence per address

### `stdply` @ `0x80` — claim: *proximity_map_left_col_x*

- **Initial byte:** `0x1E` = `30` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++75
- **Code references in stdply.asm:** 1
  - L133 *read* — `ply_level	db	80h		; [0C4h] level/area number (init 0x80)`
- **Referencing procs:** `start`

### `stdply` @ `0x83` — claim: *hero_x_in_viewport*

- **Initial byte:** `0x0A` = `10` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++72
- **Code references in stdply.asm:** 0

### `stdply` @ `0x85` — claim: *hero_gold_hi*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++70
- **Code references in stdply.asm:** 0

### `stdply` @ `0x86` — claim: *hero_gold_lo*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++69
- **Code references in stdply.asm:** 0

### `stdply` @ `0x8B` — claim: *hero_almas*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++64
- **Code references in stdply.asm:** 0

### `stdply` @ `0x90` — claim: *hero_HP*

- **Initial byte:** `0x50` = `80` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++59
- **Code references in stdply.asm:** 0

### `stdply` @ `0x92` — claim: *sword_type*

- **Initial byte:** `0x01` = `1` decimal
  - Matches enum: `SWORD_TRAINING`, `SHIELD_CLAY`, `LEFT`, `KEY_ENTER`
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++57
- **Code references in stdply.asm:** 0

### `stdply` @ `0x93` — claim: *shield_type*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++56
- **Code references in stdply.asm:** 0

### `stdply` @ `0x94` — claim: *shield_HP*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++55
- **Code references in stdply.asm:** 0

### `stdply` @ `0x9D` — claim: *current_magic_spell*

- **Initial byte:** `0x00` = `0` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++46
- **Code references in stdply.asm:** 0

### `stdply` @ `0xAB` — claim: *spells_espada*

- **Initial byte:** `0x0C` = `12` decimal
- **Strings within ±100 bytes** (1):
  - `kuBLK` @ ++32
- **Code references in stdply.asm:** 0

### `fight` slot `0x6008` -> claim *move_monster_E*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x91E5`
- First 24 bytes at target: `80 7c 03 22 f5 73 01 c3 e8 c4 00 73 01 c3 e9 89 00 80 7c 03 22 f5 73 01`
- Expected template: `80 7C 03 22 F5 73 01 C3`
- Mnemonic: cmp [si+3],22h / cmc / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x600A` -> claim *move_monster_NE*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x91F6`
- First 24 bytes at target: `80 7c 03 22 f5 73 01 c3 e8 c4 01 73 01 c3 e8 78 00 e9 a2 00 8a 44 03 0a`
- Expected template: `80 7C 03 22 F5 73 01 C3`
- Mnemonic: cmp [si+3],22h / cmc / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x600C` -> claim *move_monster_N*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x920A`
- First 24 bytes at target: `8a 44 03 0a c0 f9 75 01 c3 3c 23 f9 75 01 c3 e8 46 01 73 01 c3 e9 8a 00`
- Expected template: `8A 44 03 0A C0 F9 75 01 C3`
- Mnemonic: mov al,[si+3] / or al,al / stc / jnz +1 / ret
- Signature match: **True**

### `fight` slot `0x600E` -> claim *move_monster_NW*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9222`
- First 24 bytes at target: `80 7c 03 02 73 01 c3 e8 26 02 73 01 c3 e8 61 00 eb 78 80 7c 03 02 73 01`
- Expected template: `80 7C 03 02 73 01 C3`
- Mnemonic: cmp [si+3],02h / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x6010` -> claim *move_monster_W*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9234`
- First 24 bytes at target: `80 7c 03 02 73 01 c3 e8 cc 00 73 01 c3 eb 50 80 7c 03 02 73 01 c3 e8 4d`
- Expected template: `80 7C 03 02 73 01 C3`
- Mnemonic: cmp [si+3],02h / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x6012` -> claim *move_monster_SW*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9243`
- First 24 bytes at target: `80 7c 03 02 73 01 c3 e8 4d 02 73 01 c3 e8 40 00 eb 4f 8a 44 03 0a c0 f9`
- Expected template: `80 7C 03 02 73 01 C3`
- Mnemonic: cmp [si+3],02h / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x6014` -> claim *move_monster_S*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9255`
- First 24 bytes at target: `8a 44 03 0a c0 f9 75 01 c3 3c 23 f9 75 01 c3 e8 33 01 73 01 c3 eb 38 80`
- Expected template: `8A 44 03 0A C0 F9 75 01 C3`
- Mnemonic: mov al,[si+3] / or al,al / stc / jnz +1 / ret
- Signature match: **True**

### `fight` slot `0x6016` -> claim *move_monster_SE*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x926C`
- First 24 bytes at target: `80 7c 03 22 f5 73 01 c3 e8 95 01 73 01 c3 e8 02 00 eb 25 8b 04 40 8b d8`
- Expected template: `80 7C 03 22 F5 73 01 C3`
- Mnemonic: cmp [si+3],22h / cmc / jnb +1 / ret
- Signature match: **True**

### `fight` slot `0x6018` -> claim *check_collision_E2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x92B4`
- First 24 bytes at target: `8b 44 02 e8 b4 da 47 47 e8 2c 00 73 01 c3 87 f7 83 c6 24 e8 b8 da 87 f7`
- Expected template: `8B 44 02 E8 ?? ?? 47 47`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di
- Signature match: **True**

### `fight` slot `0x601A` -> claim *check_collision_W2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x930A`
- First 24 bytes at target: `8b 44 02 e8 5e da 4f e8 2d 00 73 01 c3 87 f7 83 c6 24 e8 63 da 87 f7 e8`
- Expected template: `8B 44 02 E8 ?? ?? 4F E8`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / dec di / call
- Signature match: **True**

### `fight` slot `0x601C` -> claim *check_collision_N2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9362`
- First 24 bytes at target: `8b 44 02 e8 06 da 87 f7 83 ee 24 e8 1e da 87 f7 8a 05 e8 6a 01 f9 74 01`
- Expected template: `8B 44 02 E8 ?? ?? 87 F7 83 EE 24`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / sub si,36
- Signature match: **True**

### `fight` slot `0x601E` -> claim *check_collision_S2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x939A`
- First 24 bytes at target: `8b 44 02 e8 ce d9 87 f7 83 c6 48 e8 da d9 87 f7 8a 05 e8 32 01 f9 74 01`
- Expected template: `8B 44 02 E8 ?? ?? 87 F7 83 C6 48`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / xchg si,di / add si,72
- Signature match: **True**

### `fight` slot `0x6020` -> claim *check_collision_NE2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x93C5`
- First 24 bytes at target: `8b 44 02 e8 a3 d9 47 47 8a 05 e8 0f 01 f9 74 01 c3 8a c8 87 f7 83 ee 24`
- Expected template: `8B 44 02 E8 ?? ?? 47 47`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di
- Signature match: **True**

### `fight` slot `0x6022` -> claim *check_collision_SE2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x940C`
- First 24 bytes at target: `8b 44 02 e8 5c d9 47 47 8a 0d 87 f7 83 c6 24 e8 64 d9 87 f7 8a 05 e8 bc`
- Expected template: `8B 44 02 E8 ?? ?? 47 47`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / inc di / inc di
- Signature match: **True**

### `fight` slot `0x6024` -> claim *check_collision_NW2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x9452`
- First 24 bytes at target: `8b 44 02 e8 16 d9 4f 8a 05 e8 83 00 f9 74 01 c3 4f 8a 0d 87 f7 83 ee 24`
- Expected template: `8B 44 02 E8 ?? ?? 4F 8A 05`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / dec di / mov al,[di]
- Signature match: **True**

### `fight` slot `0x6026` -> claim *check_collision_SW2*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES2\fight.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x949A`
- First 24 bytes at target: `8b 44 02 e8 ce d8 4f 4f 8a 0d 87 f7 83 c6 24 e8 d6 d8 87 f7 0a 0d 47 8a`
- Expected template: `8B 44 02 E8 ?? ?? 4F 4F`
- Mnemonic: mov ax,[si+2] / call coords_to_addr / [..] / dec di / dec di
- Signature match: **True**

### `town` slot `0x6000` -> claim *town_entry_normal*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES1\town.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x6026`
- First 24 bytes at target: `2e c6 06 43 7c 00 2e 8e 1e 2c ff be 00 41 8c c8 05 00 20 8e c0 bf 00 70`
- Expected template: `2E C6 06 43 7C 00`
- Mnemonic: mov cs:byte ptr [7C43h], 0  ; clear disable_edge_scroll
- Signature match: **True**

### `town` slot `0x6002` -> claim *town_entry_init*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES1\town.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x601E`
- First 24 bytes at target: `2e c6 06 43 7c ff eb 06 2e c6 06 43 7c 00 2e 8e 1e 2c ff be 00 41 8c c8`
- Expected template: `2E C6 06 43 7C FF EB 06`
- Mnemonic: mov cs:byte ptr [7C43h], 0FFh / jmp short town_entry_common
- Signature match: **True**

### `town` slot `0x600A` -> claim *check_gold_sufficient*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES1\town.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x7570`
- First 24 bytes at target: `8a 1e 85 00 2a da 73 01 c3 8a d3 8b 1e 86 00 93 2b c3 72 01 c3 80 ea 01`
- Expected template: `8A 1E 85 00 2A DA 73 01 C3`
- Mnemonic: mov bl, ds:[85h] (hero_gold_hi) / sub bl,bl / jnb +1 / ret
- Signature match: **True**

### `town` slot `0x600C` -> claim *add_gold_to_hero*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES1\town.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x7589`
- First 24 bytes at target: `01 06 86 00 10 16 85 00 c3 b1 ff b8 03 00 cd 60 0e 07 be 88 76 b0 06 2e`
- Expected template: `01 06 86 00 10 16 85 00 C3`
- Mnemonic: add ds:[86h],ax / adc ds:[85h],dx / ret  ; gold_lo += AX, gold_hi += DX+CF
- Signature match: **True**

### `town` slot `0x601C` -> claim *restore_game*

- Flat file: `C:\Projects\Zeliard\3_Assembly\tasm\research\flatfiles\ZELRES1\town.bin`
- Load base: `0x6000`
- Slot value (target addr): `0x7592`
- First 24 bytes at target: `b1 ff b8 03 00 cd 60 0e 07 be 88 76 b0 06 2e ff 16 0c 01 c6 06 57 ff 00`
- Expected template: `?? ?? B8 03 00 CD 60`
- Mnemonic: mov ax, 3 / int 60h  ; mscadlib (audio driver) restore-state call
- Signature match: **True**
