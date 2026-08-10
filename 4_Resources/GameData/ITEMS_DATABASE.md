# Zeliard Complete Items Database

All weapons, armor, magic items, consumables, and equipment with prices and locations.

---

## Weapons

### Training Sword
- **Base Damage**: 1 (+ level/2)
- **Description**: Standard beginner sword, maintenance-free
- **Strategy**: Can be kept throughout game if skilled - damage scales with level
- **Prices**: Muralla (400), Satono (800), Bosque (800), Helada (400), Pureza (100), Esco (10)

### Wise Man's Sword
- **Base Damage**: 2 (+ level/2)
- **Description**: Basic upgrade, easy to wield
- **Strategy**: Good for one-hit kills on early enemies
- **Prices**: Muralla/Satono/Bosque (1500), Helada (3000), Tumba (3000), Pureza (1000), Esco (100)

### Spirit Sword
- **Base Damage**: 4 (+ level/2)
- **Description**: High-grade product, big seller
- **Strategy**: Economical mid-game option
- **Prices**: Bosque (6800), Helada (5440), Tumba (4760), Dorado (3400), Llama/Pureza (1360), Esco (680)

### Knight's Sword
- **Base Damage**: 8 (+ level/2)
- **Description**: "Real man's sword", topples monsters quickly
- **Location**: Must trade **Crest of Glory** to Weapons Master
- **Required For**: Vista boss (Spirit Sword too short)
- **Strategy**: Long enough to reach Vista's height
- **Prices**: Helada (Elf Crest required), Dorado (7840), Llama (5880), Pureza (3920), Esco (1960)

### Illumination Sword
- **Base Damage**: 32 (+ level/2; release `200FIGHT` table value `0x20`)
- **Description**: Top-of-the-line sword with massive range
- **Strategy**: Best shop sword, very long reach
- **Prices**: Dorado (69800), Llama (34800), Pureza (32800), Esco (29800)

### Enchantment Sword (Sword of the Fairy Flame)
- **Base Table Value**: 127 (`0x7F` in release `200FIGHT`; the normal attack state doubles this to 254 before bonuses, saturating at 255)
- **Description**: **LEGENDARY** - strongest weapon in game
- **Location**: Hidden in Cavern of Arrugia (Gold Caverns)
- **Requires**: Lion Head's Key (found in Fruit Gardens, door in Gold Caverns)
- **Strategy**: One-hit kills everything, including "indestructible" red slime monsters
- **Special**: Longest sword in the game, never available in shops
- **Cannot Be Purchased**: Hidden treasure only

---

## Armor (Shields)

### Clay Shield
- **Power**: 30
- **Durability**: Very low - breaks in under a minute
- **Recommendation**: NOT RECOMMENDED - waste of money, go unshielded instead
- **Prices**: Muralla/Satono (50), Bosque (5), Esco (2)

### Wise Man's Shield
- **Power**: 80
- **Durability**: Low
- **Recommendation**: Basic shield for initial caverns
- **Prices**: Muralla/Satono/Bosque (150), Helada (50), Esco (10)

### Stone Shield
- **Power**: 180
- **Durability**: Medium
- **Recommendation**: Good upgrade for Pulpo/Pollo bosses
- **Prices**: Satono (2980), Bosque (2380), Helada/Tumba (1780), Dorado (890), Esco (298)

### Honor Shield
- **Power**: 300
- **Durability**: Medium-High
- **Recommendation**: Economical everyday shield for mid-game
- **Prices**: Helada (9800), Tumba (7840), Dorado/Llama (5880), Pureza (3920), Esco (1960)

### Light Shield ⭐
- **Power**: 300 (same as Honor Shield)
- **Material**: Magane (magic metal)
- **Special Property**: **Much more durable than Honor Shield despite same power rating**
- **Durability**: High (loses strength at much slower rate)
- **Recommendation**: **Essential upgrade for Gold Caverns** - Honor Shield breaks too easily there
- **Description**: "Unbreakable against ordinary weapons"
- **Prices**: Dorado (14800), Llama (10360), Pureza (7400), Esco (5920)

### Titanium Shield
- **Power**: 600
- **Durability**: Very High
- **Recommendation**: Best shield, "lasts a lifetime", keeps you protected until final boss
- **Prices**: Llama (39800), Pureza (31800), Esco (23800)

---

## Magic Items (Consumables)

### Ken'ko Potion
- **Effect**: Restores 11 HP (equivalent to small red potion)
- **Use**: Early game only (low health)
- **Strategy**: Too weak for later caverns
- **Prices**: Muralla/Satono (50), Esco (2)

### Juu-en Fruit
- **Effect**: Full health restoration (equivalent to blue potion)
- **Description**: Fruit of Juu-en tree (bears fruit once per 10 years)
- **Use**: Excellent late-game healing
- **Strategy**: Keep for emergencies and boss fights
- **Prices**: Bosque (240), Helada (300), Tumba/Dorado (600), Llama (900), Esco (200)

### Elixir of Kashi
- **Effect**: Restores **1 spell** use only
- **Description**: Broth of mistletoe simmered on full moon
- **Limitation**: Must select which spell to restore
- **Strategy**: Cheap but limited, better to use Chikara Powder
- **Prices**: Satono/Bosque (60), Helada (120), Esco (40)

### Chikara Powder ⭐
- **Effect**: **Fully restores ALL magical powers**
- **Description**: Dragon scales + crushed Wise Man's Stone steamed 100 days
- **Strategy**: Essential for last 3 caverns, bring multiple
- **Recommendation**: Best magic restoration item
- **Prices**: Helada (320), Esco (200)

### Magia Stone ⭐⭐⭐
- **Effect**: Protective forcefield that damages enemies on contact
- **Duration**: Lasts until entering town OR extensive use
- **Strategy**: **BEST MAGIC ITEM**
  - Stand next to boss and let stone do all the work
  - Defeats early bosses in 2-3 seconds
  - Step away as boss dies to preserve duration
  - Less effective on airborne bosses (Vista, Alguien)
- **Prices**: Muralla (1000), Bosque (1500), Dorado (2000), Llama (2500), Esco (800)

### Holy Water of Acero
- **Effect**: Restores damaged shield to full strength
- **Description**: Liquified metal (mercury + iron)
- **Formula**: H₂Hg₃Fe₂O (fictional chemistry)
- **Strategy**: Mostly useless - shields don't wear out much, Weapons Master repairs free
- **Prices**: Satono/Helada (100), Dorado (200), Esco (80)

### Sabre Oil ⭐⭐⭐
- **Effect**: Increases sword offensive power by ~230%
- **Special**: **CUMULATIVE** - stacks with multiple uses
- **Strategy**: Essential for late-game bosses
  - Use all Sabre Oils before tough boss fights
  - Almost doubles (2.3x) sword strength
  - Critical for Dragon and Jashiin
- **Prices**: Muralla/Satono/Bosque (1200), Tumba (2000), Llama (2400), Esco (1000)

### Kioku Feather
- **Effect**: Returns you to last Sage you spoke to
- **Use Cases**:
  - Teleport from any cavern back to Muralla
  - Escape from boss encounter (chicken out)
  - Quick return after Alguien farming
- **Strategy**: Mostly useless - why chicken out or backtrack?
- **Prices**: Bosque/Helada/Llama/Pureza (350), Esco (150)

---

## Wearable Equipment (Shoes & Cape)

### Ruzeria Shoes
- **Location**: Ice Caverns (4th Cavern)
- **Material**: Ruzeria bark (very hard, non-slippery)
- **Maker**: Percel the Shoemaker (murdered by Jashiin's minions)
- **Effect**: Prevents slipping on ice
- **Required For**:
  - Walking on icy surfaces
  - Balancing on thin ice pillars
  - Reaching Vista's Encounter Zone
- **Usefulness**: Ice Caverns only, obsolete afterward

### Pirika Shoes ⭐
- **Location**: Graveyard (5th Cavern)
- **Maker**: Percel the Shoemaker
- **Effect**: Protection from:
  - Gelroid (blue gelatinous substance that sucks life)
  - Thorns
  - Fire
  - Molten gold
  - Burning coals
- **Required For**: Getting through 1/3 of Graveyard (Gelroid sections)
- **Strategy**: Essential for Vista boss, wear in all hazard areas

### Silkarn Shoes
- **Location**: Gold Caverns (6th Cavern)
- **Maker**: Spirits (at Percel's request)
- **Effect**: Climb any slope
- **Required For**: Scaling slopes to reach next areas
- **Usefulness**: Gold Caverns and later levels

### Asbestos Cape
- **Location**: Llama Town (purchased from villager)
- **Cost**: 2500 almas
- **Effect**: Protection from heat in Burning Inferno
- **Required For**: Survival in Burning Inferno (7th Cavern)
- **Usefulness**: Burning Inferno only - without it, heat drains life constantly

### Feruza Shoes ⭐⭐⭐
- **Location**: Gold Caverns (hidden in Cavern of Arrugia with Enchantment Sword)
- **Maker**: Percel the Shoemaker (final masterpiece before death)
- **Material**: Rubbery material enabling super jumps
- **Effect**: Jump **twice as high** as normal
- **Required For**:
  - Reaching high vines
  - Jumping to higher ground
  - Scaling slopes without changing shoes
  - **Required to reach Jashiin**
- **Strategy**: BEST SHOES - enables platforming that's otherwise impossible
- **Usefulness**: Essential from Gold Caverns onward

---

## Special Items (Quest & Progression)

### Almas (Currency)
- **Almas I**: 1 alma - common enemy drops
- **Almas X**: 10 almas - deeper caverns
- **Almas C**: 100 almas - tough enemies
- **Use**: Exchange for Gold at bank

### Keys
- **Regular Keys**: Found in caverns, unlock specific doors
- **Lion Head's Key**: Special key
  - Given to woman in Pureza by Spirits
  - Stolen by Jashiin's underlings
  - Hidden in Fruit Gardens
  - Opens door in Gold Caverns
  - Unlocks: Cavern of Arrugia (Feruza Shoes + Enchantment Sword)

### Tears of Esmesanti (Crystals)
- **Small Tears** (x8): Obtained from defeating 8 main bosses
- **9th Tear** (Large): Obtained after defeating Jashiin
- **Purpose**: Required to destroy Jashiin permanently
- **Story**: Collect all 9 to complete the game

### Crests

#### Hero's Crest
- **Location**: Forest (hidden in biggest tree trunk)
- **History**: Symbol of Warrior God temple, awarded to martial arts winners
- **Story**: Stolen by Jashiin when he destroyed temple
- **Required For**: Getting past sentry in Bosque who blocks boss entrance

#### Crest of Glory
- **Location**: Hidden in chest somewhere in caverns
- **Owner**: Weapons Master's family crest
- **Required For**: Trading with Weapons Master for Knight's Sword
- **Strategy**: Weapons Master refuses to sell Knight's Sword without it

#### Elf Crest
- **Location**: Llama Town (given by lady after defeating Paguro)
- **Story**: Jashiin's henchmen posed as heroes, causing mistrust
- **Required For**: NPCs in Llama Town won't speak to you without it
- **How to Get**: Defeat Paguro (monster in lady's house)

---

## Potions Found in Caverns

### Red Potion
- **Effect**: Restores 11 HP
- **Location**: Common in chests throughout caverns
- **Use**: Early game only, too weak later

### Blue Potion
- **Effect**: Full health restoration (0 to 100%)
- **Location**: Hidden in specific locations, often near boss rooms
- **Strategy**:
  - Search dead-end walls near boss encounters
  - Essential for Blue Potion + Invulnerability exploit
  - Use before tough boss fights
- **Special Trick**: Drink while low health then enter boss room immediately for temporary immortality

---

## Chests
- **Contents**: Random treasure
  - Potions (red/blue)
  - Crests
  - Boots/Shoes
  - Gold
  - Swords
  - Empty (sometimes)
- **Special Enemy**: Magical Bat (255 XP, 5 damage, rare encounter when opening certain chests)

---

## Blue Rocks (Hint Stones)
- **Location**: Various points in caverns
- **Effect**: Displays helpful hint when touched
- **Use**: Provides clues and advice for navigation

---

## Town Pricing Comparison

Cheapest towns for each category:

**Weapons**: Esco (90% discount on everything)

**Armor**: Esco (90% discount)

**Magic Items**: Esco (best prices)

**Healing**:
- Esco Church (FREE)
- Muralla Church (FREE)

**Exchange Rate**: Bosque and Esco (1:8 almas to gold)

**Worst Prices**: Llama Town (4:2 exchange rate is terrible!)

---

## Recommended Loadouts by Stage

### Early Game (Caverns 1-2)
- Weapon: Wise Man's Sword
- Shield: Wise Man's Shield or Stone Shield
- Magic: Ken'ko Potion, Magia Stone
- Special: None yet

### Mid Game (Caverns 3-4)
- Weapon: Spirit Sword → Knight's Sword (for Vista)
- Shield: Honor Shield
- Magic: Magia Stone, Juu-en Fruit, Chikara Powder
- Special: Ruzeria Shoes (Ice Caverns)

### Late Game (Caverns 5-6)
- Weapon: Illumination Sword (or Knight's Sword if economical)
- Shield: Light Shield → Titanium Shield
- Magic: Magia Stone, Juu-en Fruit, Chikara Powder, Sabre Oil
- Special: Pirika Shoes, Silkarn Shoes

### End Game (Caverns 7-8)
- Weapon: Enchantment Sword (if found) or Illumination Sword
- Shield: Titanium Shield
- Magic: Multiple Chikara Powder, Multiple Sabre Oil, Juu-en Fruit
- Special: **Feruza Shoes** (required), Asbestos Cape (Burning Inferno)

---

*Complete item database compiled from in-game shops, hidden locations, and fan community research*
