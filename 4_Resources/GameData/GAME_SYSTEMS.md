# Zeliard Game Systems & Mechanics

Complete technical specifications for all internal game systems.

---

## Leveling & Experience System

### Level Progression (0-255)
- **Starting Level**: 0 (80 HP)
- **Maximum Level**: 255 (800 HP at level 15, caps at 800)
- **Level Up Method**: Visit Sage after gaining required experience

### Health Points by Level

| Level | Health Points | Level | Health Points |
|-------|--------------|-------|--------------|
| 0     | 80           | 8     | 540          |
| 1     | 120          | 9     | 600          |
| 2     | 160          | 10    | 640          |
| 3     | 240          | 11    | 680          |
| 4     | 280          | 12    | 720          |
| 5     | 320          | 13    | 760          |
| 6     | 380          | 14    | 780          |
| 7     | 460          | 15    | 800 (max)    |

**Note**: Health increases are irregular, not linear!

### Experience Requirements

Experience required PER LEVEL (not cumulative):

| Level | Experience | Level | Experience |
|-------|-----------|-------|-----------|
| 1     | 50        | 9     | 6,000     |
| 2     | 150       | 10    | 8,000     |
| 3     | 300       | 11    | 10,000    |
| 4     | 420       | 12    | 15,000    |
| 5     | 1,000     | 13    | 20,000    |
| 6     | 1,500     | 14    | 40,000    |
| 7     | 3,000     | 15    | 50,000    |
| 8     | 5,000     | 16+   | 60,000    |

**Total XP to reach Level 16**: 220,420

**Important Experience Mechanics**:
1. When you level up, XP cost is subtracted from current XP
2. **XP Overflow Cap**: Game prevents holding enough XP to level twice
   - Example: At level 0 with 400 XP, need 50 to level up
   - After leveling, you'd expect 350 XP remaining
   - Game caps it at 149 XP (1 less than next level requirement of 150)
   - **This prevents double-leveling and wastes excess XP!**

3. **Maximum XP**: 65,535 (can't hold more, excess is wasted)

### Sage Progress Messages
Based on current XP vs. required XP:

- **< 50%**: "You must persevere"
- **50-74%**: "You must accumulate more experience"
- **75-99%**: "I see the faint light of the spirits"
- **100%+**: Ready to level up

### Fast Leveling Strategy
In early levels (Muralla/Satono/Bosque):
- **Dying gives experience**
- Kill yourself once, level up, kill yourself twice, level up...
- Use F9 Speed 9 to speed up the process
- Effective until life meter is half full

---

## Damage System

### Sword Damage Formula

**Base Damage** = `Sword_Base + floor(Level / 2)`

Sword base damage values:

| Sword | Base Damage | With Sabre Oil (~230%) |
|-------|-------------|------------------------|
| Training Sword | 1 | ~2.3 |
| Wise Man's Sword | 2 | ~4.6 |
| Spirit Sword | 4 | ~9.2 |
| Knight's Sword | 8 | ~18.4 |
| Illumination Sword | 32 | ~73.6 |
| Enchantment Sword | 127 (`0x7F`; normal attack doubles to 254) | Saturates at 255 |

**Level Damage Bonus**:
- Applies every 2 levels (rounds down if odd)
- Level 0: +0
- Level 1: +0 (rounds down from 0.5)
- Level 2: +1
- Level 3: +1 (rounds down from 1.5)
- Level 4: +2
- Level 255: +127

**Example Calculations**:
- Level 4 Training Sword: 1 + 2 = 3 damage
- Level 4 Wise Man's Sword: 2 + 2 = 4 damage
  (Same as Level 2 Spirit Sword!)
- Level 255 Training Sword: 1 + 127 = 128 damage
  (The Enchantment Sword's release table value is 127 before attack-state processing.)

**Sabre Oil Effect**:
- Increases sword damage by approximately **230%**
- Effect is cumulative (stacks)
- Essential for late-game bosses

### Shield Mechanics

**Shield Power Values**:

| Shield | Power | Effective Durability |
|--------|-------|---------------------|
| Clay Shield | 30 | Very low |
| Wise Man's Shield | 80 | Low |
| Stone Shield | 180 | Medium |
| Honor Shield | 300 | Medium-High |
| **Light Shield** | 300 | **High** (special) |
| Titanium Shield | 600 | Very High |

**Special Case: Light Shield**
- Same power rating (300) as Honor Shield
- **Much more durable in practice**
- Made of magic metal "Magane"
- Loses strength at a MUCH slower rate
- Essential upgrade for Gold Caverns despite same stat value

**Shield Repair**:
- Visit Weapons Master in town for free repairs
- Holy Water of Acero restores shield (mostly useless)

---

## Magic System

### Spell Progression
Spells are granted by the Sage as you level up:

1. **Espada** - Throws swords (weak, short range)
2. **Saeta** - Throws arrows (good range, useful for breaking walls)
3. **Fuego** - Fire that burns on ground (short range, kills green slime)
4. **Lanzar** - Flame projectile (great range and damage)
5. **Rascar** - Rocks fall from ceiling (hard to aim, mostly useless)
6. **Agua** - Water projectile (powerful, kills most enemies in 1 hit)
7. **Guerra** - Lightning in all directions (ultimate spell, massive damage)

### Magic Items & Effects

**Elixir of Kashi**: Restores **1 spell** use (cheap, limited)

**Chikara Powder**: Restores **ALL spell** uses (expensive, essential)

**Magia Stone**: Best magic item
- Creates protective forcefield around player
- Damages all enemies that come near
- Lasts until: entering town OR extensive use
- Can defeat early bosses in seconds
- Strategy: Stand next to boss, let stone do the work
- **Pro tip**: Step away from boss as it dies to save duration

---

## Combat Mechanics

### Directional Attacks
1. **Horizontal Swing**: [Spacebar] while standing
2. **Upward Swing**: [Up Arrow] + [Spacebar] - hits airborne enemies
3. **Downward Thrust**: [Up] + [Down] + [Spacebar] - difficult, requires practice

### Alternative Attack Strategy
For enemies requiring head hits:
- Crouch and face AWAY from enemy
- Swing sword - back end of sword swings high enough to hit head
- Safer but more difficult than jumping

### Damage Types
- **Contact Damage**: Bumping into enemies (damages shield/health)
- **Projectile Damage**: Enemy ranged attacks (values vary)
- **Environmental Damage**: Fire, Gelroid, thorns (requires special shoes)

### Invulnerability Trick (Blue Potion Exploit)
**Setup**:
1. Get health low (let enemies hit you)
2. Open chest near boss room
3. Drink Blue Potion
4. **Immediately** enter boss room (don't wait for full heal)

**Effect**:
- Temporarily immortal during potion healing
- Health can drop to zero without dying
- Continuously regenerates during effect
- Allows aggressive close-range combat
- Must defeat boss before potion effect ends

**Works on**: Vista, Dragon, Alguien (all have hidden Blue Potions outside)

---

## Currency System

### Almas & Gold
**Almas Types**:
- Almas I: 1 alma (common drops)
- Almas X: 10 almas (deeper caverns)
- Almas C: 100 almas (tough enemies)

**Exchange Rates** (Almas to Gold):

| Town | Rate |
|------|------|
| Muralla | 1:6 |
| Satono | 1:6 |
| Bosque | 1:8 |
| Helada | 1:4 |
| Tumba | 1:2 |
| Dorado | 1:4 |
| Llama | 4:2 (worst rate!) |
| Pureza | 1:6 |
| Esco | 1:8 (best rate) |

### Banking System
- **Deposit/Withdraw**: Any amount in increments of 1 (left/right) or 10 (up/down)
- **Banker Mood**: Happy when depositing 1000+ gold, annoyed if no transaction
- Money is safe even after death

---

## Death & Resurrection

**Death Mechanics**:
- Always respawn at Muralla Sage's hut
- **Death gives experience points** (useful in early game)
- Keep all items, gold, and progress
- Lose current cavern position
- Must return to cavern entrance

**No Permanent Penalties**:
- No item loss
- No gold loss
- No level loss

---

## Speed Control

Press **F9** to adjust game speed:
- **0**: Slowest
- **9**: Fastest (recommended for farming/grinding)

Useful for:
- Fast leveling via suicide method
- Boss practice at slow speed
- Grinding through easy areas

---

## Technical Limits

| Limit | Value |
|-------|-------|
| Maximum Level | 255 |
| Maximum Health | 800 |
| Maximum XP (held) | 65,535 |
| Sword Damage (max) | 255 base + 127 level = 382 |
| Character Name Length | 8 characters (DOS 8.3) |
| Save File Size | 256 bytes |

---

## Boss Experience Values

For leveling calculations:

| Boss | Experience | Location |
|------|-----------|----------|
| Cangrejo | 120 | Caverns |
| Pulpo | 200 | Deeper Caverns |
| Pollo | 500 | Forest |
| Agar | 1,000 | Ice Caverns |
| Vista | 3,000 | Graveyard |
| Tarso | 6,000 | Gold Caverns |
| Paguro | 3,000 | Llama (mini-boss) |
| Dragon | 12,000 | Burning Inferno |
| Alguien | 30,000 | Fruit Gardens |
| Jashiin | 10,000 | Final Boss |

**Farming Strategy (Level 16+)**:
- Each level requires 60,000 XP
- Fight Alguien twice (30,000 × 2 = 60,000)
- Use teleport item after each fight
- OR: Alguien (30,000) + Jashiin (10,000) + 79 regular enemies (255 each)

---

*Technical specifications compiled from game code analysis by hacker Crystal and gameplay observations*
