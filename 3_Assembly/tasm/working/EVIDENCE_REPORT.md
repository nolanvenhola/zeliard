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

**Summary**: 7 supported / 1 contradicted / 3 inconclusive

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
