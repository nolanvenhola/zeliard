# Town NPC roster + dialog dump

For each town MDT: town name, door count, NPC positions + their
dialog text strings.  Generated via
`python dump_town_npcs.py` (uses `4_Resources/MdtViewer/decoder.py`).

Per-town MDT layout (after 4B SAR header strip):
- +0x02: map width WORD (height fixed at 8)
- +0x04: ptr to town name (pascal string at +3)
- +0x09: ptr to doors array (3B each, FFFF-term)
- +0x0D: ptr to NPC texts array (2B/entry, points to FF-term ASCII)
- +0x0F: ptr to NPC array (8B each, FFFF-term)
- +0x17: unpacked tile grid (map_width × 8, column-major)

---

## 236CMAP.mdt — "Felishika\s Castle"

- map width: 114 tiles (height fixed at 8)
- doors: 2
- NPCs: 4
- NPC text strings: 10

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 95 | 0x01 | shop/NPC building #1 |
| D2 | 52 | 0x00 | plain door |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 48 | 0 | 'If you are the brave warrior we have awaited, we have something to tell you: throughout the ages, many young men have entered the caverns, but few have returned...' |
| N2 | 56 | 1 | 'According to legend, there may still be underground places that have not been destroyed by Jashiin. People may still be living there, and will surely lend you a...' |
| N3 | 84 | 2 | 'I have been in the underground town. After I fled, they put a lock on the door. If the town is still there....' |
| N4 | 92 | 3 | 'This is the chamber of poor Princess Felicia, who has been turned to stone. You may enter, Duke Garland.' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 4 | 'Brave knight, you have awakened. When you fell at the hand of Jashiin, the Spirits brought you here. Now make haste to the aid of the Princess Felicia.' |
| 5 | 'Quickly, go to the Princess!' |
| 6 | 'Ah, the Nine Tears of Esmesanti. Jashiin exists no more and the light of peace shines once again on our land...' |
| 7 | 'This will benefit the people living underground, as well. Hurry to the Princess Felicia.' |
| 8 | 'The peace we dared not hope for has come. I\\ll get my things together and be on my way. I\\ve a family to attend to.' |
| 9 | 'Quickly, enter this chamber. The holy crystals will break the evil spell which has turned Princess Felicia to stone.' |

## 237MRMP.mdt — "Muralla Town"

- map width: 215 tiles (height fixed at 8)
- doors: 6
- NPCs: 9
- NPC text strings: 9

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 39 | 0x03 | shop/NPC building #3 |
| D2 | 59 | 0x05 | shop/NPC building #5 |
| D3 | 111 | 0x04 | shop/NPC building #4 |
| D4 | 138 | 0x06 | shop/NPC building #6 |
| D5 | 172 | 0x02 | shop/NPC building #2 |
| D6 | 205 | 0x08 | boss-area door (type 8) |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 130 | 6 | 'A moment, Duke Garland. If you listen closely in front of the underground door, you will hear a terrifying sound. That\\s the entrance to the inferno that is hom...' |
| N2 | 9 | 0 | 'Ah, you are the warrior I\\ve heard about. My son Michael was a courageous warrior. He went into the caverns and was never seen again. Please be careful.' |
| N3 | 21 | 1 | 'Sir, I dreamed that a demon created the underground caverns and filled them with monsters. Then the Spirits brought you to here to make things right again. Befo...' |
| N4 | 49 | 2 | 'You\\re on your way to the caverns, aren\\t you? I recently went in search of a powerful potion said to be hidden there. I didn\\t stay long enough to find it, but...' |
| N5 | 188 | 3 | 'You\\re going into the caverns? You are a brave man. They say there are many doors underground, but many are locked and the keys are scattered throughout the lab...' |
| N6 | 130 | 4 | 'Duke Garland, someone I know survived a journey to the underground town, Satono. According to him, the road back is short but the road out is long. It will be v...' |
| N7 | 144 | 5 | 'According to the legends, the name of the underground town is Satono.' |
| N8 | 160 | 7 | 'Alas, I fear there is no hope. You and I and all who inhabit this town will surely perish. Don\\t run off to some terrible place, stay and have a drink with me. ...' |
| N9 | 86 | 8 | 'When you kill a&monster you get a&thing called \\almas\\. It\\s worth a&lot of money. I\\d like to get some myself but I don\\t want to go down there.' |

## 238STMP.mdt — "Satono Town"

- map width: 215 tiles (height fixed at 8)
- doors: 5
- NPCs: 7
- NPC text strings: 7

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 44 | 0x04 | shop/NPC building #4 |
| D2 | 92 | 0x02 | shop/NPC building #2 |
| D3 | 128 | 0x07 | shop/NPC building #7 |
| D4 | 148 | 0x06 | shop/NPC building #6 |
| D5 | 185 | 0x03 | shop/NPC building #3 |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 37 | 2 | 'Are you Duke Garland? Thank the Spirits you\\ve come. We escaped from Jashiin through the power of the Spirits. However, if his power should become so strong tha...' |
| N2 | 196 | 4 | 'Beware! I went into the caverns and saw an awful creature -- a giant demon octopus. It was terrifying, but I escaped. I hope you will be as lucky.' |
| N3 | 22 | 0 | 'Welcome, stranger. You must have come through the labyrinths from the outside world. We have not encountered such a brave person in a very long time. You should...' |
| N4 | 86 | 1 | 'So you\\re the brave one I\\ve heard about. Well, if you\\re going to go on from here, I\\ll give you a tip.  When you come to a stopping place, dig a hole. The dem...' |
| N5 | 121 | 3 | 'Let me give you some advice, stranger. If you fall down the stone slab in front of the blue door, you will see a green door nearby. Don\\t go through that door u...' |
| N6 | 157 | 5 | 'Are you the brave one? I&hope you have brought almas for us. The almas are part of Jashiin\\s power. We use them to make medicine, and other useful things.' |
| N7 | 163 | 6 | 'Duke Garland, when you go into the caverns again, please try to bring back more almas. To supplement the protective power of the Spirits we must build a wall of...' |

## 239BSMP.mdt — "Bosque village"

- map width: 152 tiles (height fixed at 8)
- doors: 7
- NPCs: 12
- NPC text strings: 15

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 7 | 0x09 | boss-area door (type 9) |
| D2 | 36 | 0x06 | shop/NPC building #6 |
| D3 | 61 | 0x02 | shop/NPC building #2 |
| D4 | 81 | 0x04 | shop/NPC building #4 |
| D5 | 96 | 0x03 | shop/NPC building #3 |
| D6 | 114 | 0x07 | shop/NPC building #7 |
| D7 | 142 | 0x08 | boss-area door (type 8) |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 9 | 11 | 'Hold on there! Do you have the Hero\\s Crest? �Don\\t lie, it won\\t do any good. Get out of here!' |
| N2 | 101 | 2 | 'The temple that once stood here had the crest of the Warrior God carved into it. Winners of the martial arts competitions held in front of the temple were award...' |
| N3 | 21 | 10 | 'That sentry must have sold his soul to Jashiin. Why else would he interfere with brave men such as yourself?' |
| N4 | 107 | 6 | 'A spirit appeared and told me to say this if I met a brave man: "If you go through the door to the right of the tree that forms a cross, you will be able to go ...' |
| N5 | 87 | 4 | 'The crest must be hidden somewhere in the forest, but I couldn\\t say where.' |
| N6 | 131 | 0 | 'Welcome to Bosque Village, brave warrior. This once was a forest surrounding a temple, but the temple was destroyed by Jashiin. Now the village of Bosque is des...' |
| N7 | 79 | 1 | 'Listen, stranger, a sentry is posted on the outskirts of the city. I\\m telling you this for your own good; it\\s best to stay away from there.' |
| N8 | 90 | 7 | 'I have some advice for you: Be careful if you come to a place where the leaves of the trees are thin. The ground there is not very strong.' |
| N9 | 44 | 8 | 'The sentry at the edge of town says the Spirits came to him in a dream, and told him not to allow anyone to pass unless they bear the Hero\\s Crest. I wonder if ...' |
| N10 | 68 | 5 | 'When the temple was destroyed I heard Jashiin ordering his underlings to hide the crest in the trunk of the biggest tree. That must be where it is hidden. I hop...' |
| N11 | 89 | 3 | 'When he destroyed the temple, Jashiin stole the Hero\\s Crest.  No one has any idea where to find it.' |
| N12 | 32 | 9 | 'A few have slipped by the sentry undetected, but none have returned. There must be some terrible monster out there.' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 12 | 'Don\\t lie, it won\\t do any good. Get out of here!' |
| 13 | 'You cannot pass here without the Hero\\s Crest. My orders are from the Spirits themselves!' |
| 14 | 'Hold on there! You have the Hero\\s Crest, I see. You may pass.' |

## 240HLMP.mdt — "Helada Town"

- map width: 227 tiles (height fixed at 8)
- doors: 5
- NPCs: 8
- NPC text strings: 11

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 44 | 0x02 | shop/NPC building #2 |
| D2 | 92 | 0x07 | shop/NPC building #7 |
| D3 | 111 | 0x03 | shop/NPC building #3 |
| D4 | 128 | 0x04 | shop/NPC building #4 |
| D5 | 148 | 0x06 | shop/NPC building #6 |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 177 | 0 | 'Welcome. You must be cold. Helada used to be a warm, prosperous place, but Jashiin has turned it into a cold ruin.' |
| N2 | 139 | 4 | 'I think you should know something: Percel the shoemaker said that without the Ruzeria shoes you could not go beyond the green door.' |
| N3 | 105 | 3 | 'Are you the brave one? My lover, Percel, was killed by Jashiin\\s underlings just after the Spirits asked him to make the Ruzeria shoes for a brave man. Return m...' |
| N4 | 166 | 2 | 'Have you been in the ice caverns? The shoemaker in this town was trying to make special shoes out of Ruzeria bark, to help a hero walk on the ice. Just as he ma...' |
| N5 | 72 | 5 | 'Ruzeria is the name of a tree that grows in the underground forest. The bark is very hard and is not slippery. Percel had good reason for choosing it.' |
| N6 | 158 | 6 | 'Someone I know said he had seen a pair of unusual shoes in the caverns. I\\m not sure whether those are the shoes that Percel made.' |
| N7 | 56 | 10 | 'I\\ll bet the green slime creatures have caused you a lot of trouble. Let me tell you a secret: they can\\t withstand heat. Burn them and they will vanish in a si...' |
| N8 | 80 | 1 | 'You may have noticed that there are two roads leading here. There is also a shortcut.' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 7 | 'I\\m sorry for what I said a short while ago. I don\\t know what came over me. Please defeat Jashiin and avenge the death of Percel.' |
| 8 | 'Ah, the shoes of Percel.... I see you are a brave man. I hope you will find Jashiin and defeat him quickly.' |
| 9 | 'This brave man with the Ruzeria shoes... With this the shoemaker\\s shop also floats up...' |

## 241TMMP.mdt — "Tumba Town"

- map width: 270 tiles (height fixed at 8)
- doors: 5
- NPCs: 8
- NPC text strings: 12

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 44 | 0x03 | shop/NPC building #3 |
| D2 | 93 | 0x07 | shop/NPC building #7 |
| D3 | 128 | 0x02 | shop/NPC building #2 |
| D4 | 181 | 0x06 | shop/NPC building #6 |
| D5 | 231 | 0x04 | shop/NPC building #4 |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 26 | 0 | 'Brave sir, I hope you\\ve come to help this pitiful town. It was the site of a quiet graveyard before it was decimated by Jashiin.' |
| N2 | 206 | 6 | 'Have you seen the strange, bluish-white people in the caverns? They were infected by the Gelroid and now they wander the land like the living dead. To kill them...' |
| N3 | 53 | 1 | 'If you\\re going back into the caverns, beware the Gelroid. It\\s a blue gelatinous substance which will suck the life out of you.' |
| N4 | 71 | 4 | 'One third of this region is covered with deadly Gelroid. If you\\re going to continue through the labyrinths, ordinary shoes will not protect you.' |
| N5 | 86 | 2 | 'Have you heard of Percel the shoemaker from Herada Town? He made Ruzeria shoes for walking on ice and Pirika shoes for getting by Gelroid, thorns and fire. Thos...' |
| N6 | 122 | 3 | 'May I confide in you? I was once a spy for Jashiin. I can tell you that the Pirika shoes were put into a box and thrown away somewhere in the Rotten land. You m...' |
| N7 | 164 | 5 | 'There is a certain place in the caverns where you can pass through a wall, but only in one direction. My grandfather told me the place is near a green stone sla...' |
| N8 | 200 | 7 | 'It seems that Jashiin has stolen many things. The weapon maker is searching for his family crest, the Crest of Glory. If you find it in the caverns, he\\ll be mo...' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 8 | 'Those are the Pirika shoes. Go quickly to the abode of Jashiin and finish him off. We will pray for your success and swift return.' |
| 9 | 'Ah, the Pirika shoes! Forgive me, brave sir. I had no choice. I won\\t do that kind of thing again.' |
| 10 | 'Isn\\t that the Crest of Glory? Please take it quickly to the owner of the weapons store.' |
| 11 | '. . . . . .' |

## 242DRMP.mdt — "Dorado Town"

- map width: 215 tiles (height fixed at 8)
- doors: 5
- NPCs: 12
- NPC text strings: 14

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 47 | 0x03 | shop/NPC building #3 |
| D2 | 70 | 0x07 | shop/NPC building #7 |
| D3 | 92 | 0x02 | shop/NPC building #2 |
| D4 | 128 | 0x06 | shop/NPC building #6 |
| D5 | 184 | 0x04 | shop/NPC building #4 |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 190 | 0 | 'Welcome to Dorado./This was once a thriving merchant town where everyone lived a peaceful life. Jashiin has reduced it to a sad, desolate place.' |
| N2 | 180 | 1 | 'The Spirits say that Jashiin returned because the people, made soft by peace and prosperity, sank into corruption.' |
| N3 | 139 | 2 | 'Using the money and treasures of Dorado and other places, Jashiin built a place of his own. The Tesoro and Burata Caverns are his domain.' |
| N4 | 105 | 3 | 'A word to the wise: The door bearing the green symbol cannot be opened. There\\s no use trying to force it, it absolutely cannot be opened.' |
| N5 | 136 | 4 | 'Somewhere in the caverns are the Shirukaano shoes made by the shoemaker Percel. Try to find them; when you wear those shoes you can climb any slope.' |
| N6 | 102 | 5 | 'Someone who went into the caverns told me the Shirukaano shoes are hidden in Tesoro. Of the four rooms in the center, they are in the far right room.' |
| N7 | 85 | 6 | 'Of the four doors in Tesoro, three bear a blue symbol. What was the other one? For the life of me I can\\t remember.' |
| N8 | 154 | 7 | 'This building wasn\\t here before, was it? You can\\t put up a building like this overnight -- how did it get here?' |
| N9 | 56 | 8 | 'A peace statue called \\Taruso\\ stood here, but one night it disappeared. Where in the world can it have gone? The evil Jashiin must have taken a liking to it.' |
| N10 | 36 | 9 | 'I have a message from the Spirits: wait for the moving edge of the platform made of shining blocks.' |
| N11 | 122 | 10 | 'When you find green stone slabs that can be moved up and down, arrange them like a staircase so you can go up easily.' |
| N12 | 21 | 11 | 'The middle of the caverns is made of pure gold! But there is one fake gold wall that can be destroyed.' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 12 | 'Ah! You found the Shirukaano shoes! Now you can scale any slope.' |
| 13 | 'Brave lad! A message from the Spirits: Take great care when you enter the next world.' |

## 243LLMP.mdt — "Llama Town"

- map width: 280 tiles (height fixed at 8)
- doors: 8
- NPCs: 9
- NPC text strings: 20

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 8 | 0x09 | boss-area door (type 9) |
| D2 | 39 | 0x03 | shop/NPC building #3 |
| D3 | 71 | 0x02 | shop/NPC building #2 |
| D4 | 104 | 0x04 | shop/NPC building #4 |
| D5 | 142 | 0x06 | shop/NPC building #6 |
| D6 | 176 | 0x07 | shop/NPC building #7 |
| D7 | 269 | 0x08 | boss-area door (type 8) |
| D8 | 222 | 0x0A | boss-area door (type 10) |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 220 | 0 | 'Help! A terrible creature is in our hut! Please get rid of it for us.' |
| N2 | 255 | 3 | '\x01/�The caverns in this region are burning hot; you won\\t be able to stand it long. I\\ve got something that will help you. It\\s an Asbestos cape that will protec...' |
| N3 | 24 | 18 | 'Sir, I can see that you don\\t have the Elf Crest. Recently some henchmen of Jashiin have been posing as heroes and wreaking havoc on this town. You\\re not one o...' |
| N4 | 14 | 10 | 'My name is Michael. No one here listens to a word I say. I wonder why that is?' |
| N5 | 50 | 19 | '. . . . . . . . . . . .' |
| N6 | 124 | 19 | '. . . . . . . . . . . .' |
| N7 | 91 | 19 | '. . . . . . . . . . . .' |
| N8 | 192 | 19 | '. . . . . . . . . . . .' |
| N9 | 159 | 19 | '. . . . . . . . . . . .' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 1 | 'Oh, thank you, sir. As a token of my gratitude I will give you the Elf Crest. I think you\\ll find it useful; without it, no one in town will help you.�' |
| 2 | 'Thanks again. Really.' |
| 4 | 'The caverns in this region are burning hot; you won\\t be able to stand it long. I\\ve got something that will help you. It\\s an Asbestos cape that will protect y...' |
| 5 | 'It\\s not free though. It will cost you 2500&almas.///�Oh, I&see... well, maybe next time.' |
| 6 | 'Oh, I&see... well, maybe next time.' |
| 7 | 'You say you don\\t have 2500&almas to give? Don\\t try to fool me.' |
| 8 | 'Here you are. That will be 2500&almas. Take good care of it.' |
| 9 | 'Are you taking good care of the Asbestos cape? It was my prized possession so I hope you\\ll treat it well.' |
| 11 | 'Oh! You\\ve got the Elf Crest. Great!' |
| 12 | 'Jashiin filled the caverns with a flaming inferno. Please help us, brave lad!' |
| 13 | 'Beware of the great heat currents. There are many whirlpools in the caverns, and once you get caught in one you\\ll never get out.' |
| 14 | 'There are countless one-way, invisible walls in Correr Cave. To find out more about them, ask Yozeras or Myuuza the elder.' |
| 15 | 'I am Yozeras. When you go into Correr Cave, watch out for an opening with no ivy. You\\ll fall if you go through there.' |
| 16 | 'I\\m  Myuuza, the town elder. If you go into the Correr Cave be sure to remember the color of the entrance door. The exit door is the same color.' |
| 17 | 'If you can\\t find your way, find an air current near the ceiling of the cave. You can transport yourself on those currents.' |

## 244PRMP.mdt — "Pureza Town"

- map width: 320 tiles (height fixed at 8)
- doors: 6
- NPCs: 10
- NPC text strings: 13

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 49 | 0x04 | shop/NPC building #4 |
| D2 | 93 | 0x07 | shop/NPC building #7 |
| D3 | 128 | 0x02 | shop/NPC building #2 |
| D4 | 181 | 0x06 | shop/NPC building #6 |
| D5 | 231 | 0x03 | shop/NPC building #3 |
| D6 | 294 | 0xFF | cavern entry (special) |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 22 | 1 | 'Are you from the outside world? Welcome. You are certainly a courageous man guided by the Spirits.' |
| N2 | 44 | 3 | 'I think you should know that this town is very close to the fortress of Jashiin, and his henchmen are sure to be around. Be careful.' |
| N3 | 68 | 2 | 'A moment, sir. I have seen the fortress of Jashiin. It is at the edge of this world. The Spirits guided me back from there alive so I could tell you about it.' |
| N4 | 84 | 4 | 'YOU! The princess you struggle to rescue will lead you to your doom! The Spirits are just demons in disguise. What does this mean? You do the devil\\s work, you ...' |
| N5 | 121 | 5 | 'The Spirits gave me a lion\\s head key but it was stolen by one of Jashiin\\s underlings. I hope you will find it on your travels.' |
| N6 | 154 | 12 | 'Beware of Jashiin\\s last henchman, Algaien. It is said that Jashiin used his power to give him eternal life.' |
| N7 | 173 | 8 | 'The one weapon you\\ll need to defeat Jashiin is the Fairy Flame Sword. According to legend it gives off a peculiar light and can vanquish any foe with only one ...' |
| N8 | 199 | 9 | 'Nearby is a village called Esko, but I don\\t know what has happened to it recently. I once knew many people there.' |
| N9 | 247 | 10 | 'I\\ve heard that the lion\\s head key fell between two towers under a stone slab. It is supposedly near this town.' |
| N10 | 292 | 11 | 'Help!&.&.&.&.' |

### Unreferenced text strings
(These exist in the text-pointer array but no NPC record points to them — likely sign/cinematic text or unused.)

| idx | text |
|---:|---|
| 0 | 'Fooled again! Meddlesome fool! Taste the past and never return here again. /HA, HA, HA, HA...' |
| 6 | 'Ah, yes -- that\\s the key that was entrusted to me by the Spirits. Make good use of it.' |
| 7 | 'I pray for your safe return.' |

## 245ESMP.mdt — "Esco village"

- map width: 215 tiles (height fixed at 8)
- doors: 5
- NPCs: 7
- NPC text strings: 7

### Doors
| # | x | type | meaning |
|---|---:|---:|---|
| D1 | 57 | 0x03 | shop/NPC building #3 |
| D2 | 111 | 0x04 | shop/NPC building #4 |
| D3 | 138 | 0x06 | shop/NPC building #6 |
| D4 | 171 | 0x05 | shop/NPC building #5 |
| D5 | 205 | 0x08 | boss-area door (type 8) |

### NPCs + dialog
| NPC | x | id | dialog |
|---|---:|---:|---|
| N1 | 8 | 1 | 'If you fall from a stone and are blocked by a wall, thrust through it with your sword. If the wall crumbles away you\\ll be on the road leading to the abode of J...' |
| N2 | 38 | 3 | 'Look for another door with a blue symbol. If you see it, turn to the right.' |
| N3 | 82 | 2 | 'By jumping in front of the ivy rather than going down it, you can open a new road.' |
| N4 | 126 | 0 | 'Pay attention to the door with the blue symbol. It has turned three colors.' |
| N5 | 169 | 4 | 'Do you have doubts? Here there is only slaughter and destruction. What do you expect to accomplish?' |
| N6 | 173 | 5 | 'Why have the Spirits sent you on this journey of slaughter? Why does Jashiin await you in silence?' |
| N7 | 159 | 6 | 'Pay no heed to those two, they are in league with Jashiin. They are trying to weaken your will.' |
