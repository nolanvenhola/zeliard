#!/usr/bin/env python3
import sys
import os
import tkinter as tk
from tkinter import filedialog

# ---------------------------------------------------------------------------
# Configuration & Descriptors
# ---------------------------------------------------------------------------

# Mode Definitions:
# 0: 20x18 MCGA Sprites (3 bit-planes, 15 byte stride)
# 1: 16x16 MCGA Sprites (3 bit-planes, 12 byte stride)
# 2: 8x8 Font Glyphs (1bpp, 8 bytes per tile)
# 3: 16x16 Magic Spells (3 planes, 48-byte block reassembly)
# 4: 32x32 Sword Macro-tiles (2bpp bit-plane assembly)
# 5: 16x24 NPC Sprites (mman.grp/cman.grp)
# 6: 16x24 Hero Sprites (tman.grp)
# 7: 8x8 Patterns (mpat.grp/dpat.grp/cpat.grp)
# 8: 24x24 Hero Sprites (fman.grp)
# 9: 28x18 tiles 8x8 each, 5 palette modes (roka.grp)
# 10; 8x8 static dungeon tiles (dchr.grp, mppX.grp)
# 11: 16x16 NPC Sprites (enpX.grp)
# 12: boss sprites (crab.grp)
GRP_DESCRIPTOR = [
    ("itemp.grp", [0, 1, 1, 1, 1, 1, 1]),
    ("font.grp",  [2, 2, 2]),
    ("magic.grp", [3, 3, 3, 3, 3, 3], {0: (0, 3), 4: (3, 1)}),
    ("sword.grp", [4, 4, 4]),
    ("mman.grp",  5), # NPC
    ("cman.grp",  5), # NPC
    ("tman.grp",  6), # Hero in the town
    ("mpat.grp",  7), # Patterns/Background Tiles
    ("dpat.grp",  7),
    ("cpat.grp",  7),
    ("fman.grp",  8, [13, 13, 4, 1, 18, 18, 12, 12]), # Hero in the dungeons
    ("roka.grp",  9), # decorations on entering the dungeon door
    ("dchr.grp",  10, [
        [3, 3, 3], [2, 2], [1, 1], [3], [3], [3], [1, 1], [1, 1], [3], [1, 1], [1, 1, 1, 1, 1, 1]
    ]), # doors and platforms components
    ("mpp1.grp",  10, [[1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1], [1, 1], [1, 1, 1, 5, 5]]), # cavern1 tiles:
        # 00 01 02 08 09 0A 0B 0C 0F 10 11 12 13 14 15 16 17 18 19 00 00 00 00 00 0B 00 00 00 0C 00 00 00 0F 0E 0D
    ("mpp2.grp",  10, [[1, 1, 1], [4, 9], [1, 1], [1, 1, 1, 5], [1, 1, 1, 1, 1, 1, 1, 1, 1]]),
        # 00 01 02 0E 0F 10 11 12 13 15 16 17 18 19 00 00 00 00 00 00 00 00 00 00 10 00 00 00 11 00 00 00 12 13 14
    ("mpp3.grp",  10, [[1, 1], [9], [16], [1, 1], [1, 1, 1, 1, 1], [5], [1, 1, 1, 1, 1]]),
        # 00 01 02 07 0B 0C 1B 1C 1D 20 21 22 23 24 25 26 00 00 00 00 00 00 00 00 1B 00 00 00 1C 00 00 00 1D 1E 1F
    ("mpp4.grp",  10, [[1, 1, 1], [10], [1, 1], [5], [1, 1]]),
        # 00 01 02 08 0B 0D 0E 0F 10 11 12 13 00 00 00 00 00 00 00 00 00 00 00 00 0D 00 00 00 0E 00 00 00 0B 0C 00
    ("mpp5.grp",  10, [[1, 1, 1], [10], [13], [4, 3], [1, 1], [4], [2], [4], [3], [1, 1, 1, 1, 1]]),
        # 00 01 02 18 19 1A 1B 1C 1D 21 22 23 24 25 26 27 28 29 2A 2D 2E 2F 00 00 21 00 00 00 22 00 00 00 1A 1B 1C 1D 00 00 00 00 25 26 00 00 23 24 00 00
    ("mpp6.grp",  10, [[1, 1, 1], [3], [1], [2], [5], [9], [1], [1, 1], [3], [6], [1, 1]]),
        # 00 01 02 06 0A 0B 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 21 22 00 19 00 00 00 18 00 00 00 16 21 22 00
    ("mpp7.grp",  10, [[1, 1, 1], [27], [1], [4], [1], [4, 3], [1, 1, 1], [1], [1, 1], [2], [11]]),
        # 00 01 02 14 17 18 19 1A 1B 1C 1D 1E 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 1E 00 00 00 23 00 00 00 2B 2C 2D 00 2A 00 00 00 29 00 00 00 28 00 00 00
    ("mpp8.grp",  10, [[1, 1, 1], [10], [2], [1, 1, 3], [1, 1, 1, 1, 1, 1, 1, 1, 1], [5], [3], [1, 1, 1, 1, 1, 1, 1]]),
        # 00 01 02 08 0F 10 11 12 13 17 18 19 1A 1B 1C 25 26 27 28 29 00 00 00 00 0F 00 00 00 10 00 00 00 25 26 27 28 13 14 15 16 12 1A 1B 1C 11 17 18 19
    ("mpp9.grp",  10, [[1, 8], [5, 3, 2], [20]]),
        # 00 01 02 03 04 05 06 07 08 09
    ("mppa.grp",  10, [[1, 2, 2, 4], [6], [1, 1], [3]]),
        # 00 09 0A 0B 0C 0D 0E 11 12 13
    ("mppb.grp",  10, [[1, 3], [1, 1]]), 
        # 00
    ("enp1.grp",  11),
    ("crab.grp",  12),
]

MODE_CFG = {
    0: {"w": 20, "h": 18, "stride": 15, "bytes": 270, "type": "sprite"},
    1: {"w": 16, "h": 16, "stride": 12, "bytes": 192, "type": "sprite"},
    2: {"w": 8,  "h": 8,  "stride": 1,  "bytes": 8,   "type": "font"},
    3: {"w": 16, "h": 16, "stride": 8,  "bytes": 192, "type": "sprite"},
    4: {"w": 32, "h": 32, "stride": 0,  "bytes": 0,   "type": "sword"}, # Variable
    5: {"w": 16, "h": 24, "stride": 0,  "bytes": 0,   "type": "npc"},   # NPC sprites
    6: {"w": 16, "h": 24, "stride": 0,  "bytes": 0,   "type": "npc"},   # Hero in town uses NPC logic
    7: {"w": 8,  "h": 8,  "stride": 6,  "bytes": 48,  "type": "pattern"},
    8: {"w": 16, "h": 8,  "stride": 4,  "bytes": 32,  "type": "fman"},
    9: {"w": 8,  "h": 8,  "stride": 6,  "bytes": 48,  "type": "roka"},
    10:{"w": 8,  "h": 8,  "stride": 6,  "bytes": 48,  "type": "dchr"},
    11:{"w": 16, "h": 8,  "stride": 4,  "bytes": 32,  "type": "enp"},
    12:{"w": 16, "h": 8,  "stride": 4,  "bytes": 32,  "type": "crab"},
}

SCALE = 4
CANVAS_BG = "#0f0f1a"
FG_COLOR = "#e0e0ff"
BG_COLOR = "#1a1a2e"

# Sword Color Tiers (High, Low) indices from VGA Palette
SWORD_COLORS = [
    # Mega-Group 0: Training, Wise Man's, Spirit Swords
    [(0x09, 0x01), (0x24, 0x04), (0x1B, 0x03)],
    # Mega-Group 1: Knight's, Illumination Swords
    [(0x09, 0x01), (0x24, 0x04)],
    # Mega-Group 2: Enchantment Sword
    [(0x36, 0x06)],
]

# Hardcoded indices for tman.grp (Hero sprites)
# Each block of 6 represents a 2x3 grid of 8x8 tiles
HERO_INDICES = [
    0x00, 0x02, 0x04, 0x01, 0x03, 0x05, # Faced Left 1
    0x06, 0x08, 0x0A, 0x07, 0x09, 0x0B, # Faced Left 2
    0x00, 0x0C, 0x0E, 0x01, 0x0D, 0x0F, # Faced Left 3
    0x06, 0x10, 0x12, 0x07, 0x11, 0x13, # Faced Left 4
    0x14, 0x16, 0x18, 0x15, 0x17, 0x19, # Faced Left 5
    0x1A, 0x1C, 0x1E, 0x1B, 0x1D, 0x1F, # Faced Right 1
    0x20, 0x22, 0x24, 0x21, 0x23, 0x25, # Faced Right 2
    0x1A, 0x26, 0x28, 0x1B, 0x27, 0x29, # Faced Right 3
    0x20, 0x2A, 0x2C, 0x21, 0x2B, 0x2D, # Faced Right 4
    0x14, 0x16, 0x18, 0x15, 0x17, 0x19  # Faced Right 5
]

# pal_decode_tbl has 6 entries (hero_tile_col_idx cycles 0–5);
# entry 5 is the same data as entry 3:
PAL_DECODE_TABLES = [
    bytes([0x00,0x01,0x02,0x03, 0x08,0x09,0x0A,0x0B,
           0x10,0x11,0x12,0x13, 0x18,0x19,0x1A,0x1B]),  # 0  pal_decode_data0
    bytes([0x00,0x02,0x04,0x06, 0x10,0x12,0x14,0x16,
           0x20,0x22,0x24,0x26, 0x30,0x32,0x34,0x36]),  # 1  pal_decode_data1
    bytes([0x00,0x01,0x04,0x05, 0x08,0x09,0x0C,0x0D,
           0x20,0x21,0x24,0x25, 0x28,0x29,0x2C,0x2D]),  # 2  pal_decode_data2
    bytes([0x00,0x05,0x06,0x07, 0x28,0x2D,0x2E,0x2F,
           0x30,0x35,0x36,0x37, 0x38,0x3D,0x3E,0x3F]),  # 3  pal_decode_data3
    bytes([0x00,0x06,0x05,0x07, 0x30,0x36,0x35,0x37,
           0x28,0x2E,0x2D,0x2F, 0x38,0x3E,0x3D,0x3F]),  # 4  pal_decode_data4
]
PAL_DECODE_TABLES.append(PAL_DECODE_TABLES[3])          # 5  aliases data3

# ---------------------------------------------------------------------------
# Roka Hardcoded Map (28x18 = 504 bytes)
# ---------------------------------------------------------------------------
ROKA_MAP = [
    0x07, 0x08, 0x09, 0x0A, 0x07, 0x08, 0x0B, 0x0C, 0x07, 0x08, 0x09, 0x0A, 0x19, 0x3D, 0x61, 0x27, 0x1D, 0x1E, 0x1D, 0x1E, 0x1F, 0x20, 0x1F, 0x20, 0x1D, 0x1E, 0x1F, 0x20,
    0x0D, 0x0E, 0x0F, 0x10, 0x0F, 0x10, 0x0D, 0x0E, 0x0F, 0x10, 0x17, 0x18, 0x3E, 0x5C, 0x62, 0x26, 0x2A, 0x25, 0x21, 0x22, 0x21, 0x22, 0x23, 0x24, 0x21, 0x22, 0x21, 0x22,
    0x09, 0x0A, 0x07, 0x08, 0x07, 0x08, 0x09, 0x0A, 0x07, 0x08, 0x19, 0x54, 0x59, 0x5D, 0x63, 0x32, 0x2F, 0x2E, 0x1F, 0x20, 0x1F, 0x20, 0x1D, 0x1E, 0x1F, 0x20, 0x1F, 0x20,
    0x0F, 0x10, 0x11, 0x12, 0x0F, 0x10, 0x0D, 0x0E, 0x17, 0x18, 0x50, 0x55, 0x5A, 0x5E, 0x64, 0x66, 0x28, 0x30, 0x23, 0x24, 0x21, 0x22, 0x23, 0x24, 0x21, 0x22, 0x23, 0x24,
    0x07, 0x08, 0x0A, 0x0C, 0x07, 0x08, 0x09, 0x0A, 0x1A, 0x34, 0x51, 0x56, 0x5B, 0x5F, 0x65, 0x67, 0x2F, 0x2D, 0x1D, 0x1E, 0x1F, 0x20, 0x1D, 0x1E, 0x1F, 0x20, 0x1D, 0x1E,
    0x0F, 0x10, 0x0D, 0x0E, 0x0D, 0x0E, 0x17, 0x18, 0x49, 0x4D, 0x52, 0x57, 0x00, 0x60, 0x69, 0x68, 0x6A, 0x6B, 0x28, 0x26, 0x21, 0x22, 0x2B, 0x26, 0x21, 0x22, 0x21, 0x22,
    0x07, 0x08, 0x09, 0x0A, 0x09, 0x0A, 0x1B, 0x46, 0x4A, 0x4E, 0x53, 0x58, 0x00, 0x00, 0x00, 0x00, 0x69, 0x6C, 0x31, 0x2D, 0x1F, 0x20, 0x2C, 0x2D, 0x1F, 0x20, 0x1F, 0x20,
    0x13, 0x14, 0x13, 0x14, 0x17, 0x18, 0x43, 0x47, 0x4B, 0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6D, 0x6E, 0x6F, 0x29, 0x26, 0x21, 0x22, 0x2A, 0x25, 0x21, 0x22,
    0x15, 0x16, 0x15, 0x16, 0x1C, 0x35, 0x44, 0x48, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x69, 0x71, 0x73, 0x74, 0x1F, 0x20, 0x2C, 0x27, 0x1F, 0x20,
    0x17, 0x18, 0x38, 0x3A, 0x3F, 0x42, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6D, 0x75, 0x77, 0x79, 0x6F, 0x2B, 0x26, 0x29, 0x26,
    0x1A, 0x34, 0x39, 0x3B, 0x40, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x76, 0x78, 0x7A, 0x7B, 0x31, 0x32, 0x2F, 0x2D,
    0x33, 0x36, 0x37, 0x3C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6D, 0x71, 0x70, 0x72, 0x70,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02,
    0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04, 0x03, 0x04,
    0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x05, 0x06, 0x06, 0x05, 0x05, 0x06, 0x05, 0x06,
]

# Frame definitions from enp_frames.asm
# Each frame is a 2x2 grid of 8x8 tiles: [Top-Left, Top-Right, Bottom-Left, Bottom-Right]
ENP1_FRAMES = {
    "Bat Fly Left": [
        [0, 0x19, 0x1A, 0x1B, 0x1C], 
        [0, 0x1D, 0x1E, 0x1F, 0x20], 
        [0, 0x21, 0x22, 0x23, 0x24],
        [0, 0x25, 0x26, 0x27, 0x28], 
        [0, 0x29, 0x2A, 0x2B, 0x2C], 
        [0, 0x2D, 0x2E, 0x2F, 0x30],
        [0, 0x31, 0x32, 0x33, 0x34]
    ],
    "Bat Fly Right": [
        [0, 0x19, 0x1A, 0x1B, 0x1C], 
        [0, 0x35, 0x36, 0x37, 0x38], 
        [0, 0x39, 0x3A, 0x3B, 0x3C],
        [0, 0x3D, 0x3E, 0x3F, 0x40], 
        [0, 0x41, 0x42, 0x43, 0x44], 
        [0, 0x45, 0x46, 0x47, 0x48],
        [0, 0x49, 0x4A, 0x4B, 0x4C]
    ],
    "Slug Walk Left": [
        [0, 0x4D, 0x00, 0x4F, 0x50], 
        [0, 0x51, 0x00, 0x52, 0x53],
        [0, 0x54, 0x55, 0x4F, 0x50], 
        [0, 0x56, 0x57, 0x58, 0x59]
    ],
    "Slug Walk Right": [
        [0, 0x00, 0x5B, 0x5C, 0x5D], 
        [0, 0x00, 0x5E, 0x5F, 0x60],
        [0, 0x61, 0x62, 0x5C, 0x5D], 
        [0, 0x63, 0x64, 0x65, 0x66]
    ],
    "Frog Jump Left": [
        [0, 0x75, 0x76, 0x77, 0x78], 
        [0, 0x75, 0x76, 0x79, 0x78], 
        [0, 0x7A, 0x7B, 0x7C, 0x7D],
        [0, 0x7E, 0x7B, 0x7F, 0x80], 
        [0, 0x81, 0x82, 0x83, 0x84], 
        [0, 0x85, 0x86, 0x87, 0x88],
        [0, 0x89, 0x8A, 0x8B, 0x8C]
    ],
    "Frog Jump Right": [
        [0, 0x8D, 0x8E, 0x8F, 0x90], 
        [0, 0x8D, 0x8E, 0x8F, 0x91], 
        [0, 0x92, 0x93, 0x94, 0x95],
        [0, 0x92, 0x96, 0x97, 0x98], 
        [0, 0x99, 0x9A, 0x9B, 0x9C], 
        [0, 0x9D, 0x9E, 0x9F, 0xA0],
        [0, 0xA1, 0xA2, 0xA3, 0xA4]
    ],
    "Rat Run Left": [
        [0, 0x67, 0x68, 0x69, 0x6A], 
        [0, 0x6B, 0x6C, 0x6D, 0x6E], 
        [0, 0x6F, 0x70, 0x71, 0x72],
        [0, 0x73, 0x74, 0xE0, 0xE1], 
        [0, 0xF2, 0xF3, 0xF4, 0xF5], 
        [0, 0xF6, 0xF7, 0xF4, 0xF5]
    ],
    "Rat Run Right": [
        [0, 0xE2, 0xE3, 0xE4, 0xE5], 
        [0, 0xE6, 0xE7, 0xE8, 0xE9], 
        [0, 0xEA, 0xEB, 0xEC, 0xED],
        [0, 0xEE, 0xEF, 0xF0, 0xF1], 
        [0, 0xF2, 0xF3, 0xF4, 0xF5], 
        [0, 0xF6, 0xF7, 0xF4, 0xF5]
    ],
    "Bat Death": [
        [0, 0xA5, 0xA6, 0xA7, 0xA8], 
        [0, 0xA9, 0xAA, 0xAB, 0xAC], 
        [0, 0xAD, 0xAE, 0xAF, 0xB0]
    ],
    "Slug Death": [
        [0, 0xB1, 0xB2, 0xB3, 0xB4], 
        [0, 0xB5, 0xB6, 0xB7, 0xB8], 
        [0, 0xB9, 0xBA, 0xBB, 0xBC]
    ],
    "Frog Death": [
        [0, 0xBD, 0xBE, 0xBF, 0xC0], 
        [0, 0xC1, 0xC2, 0xC3, 0xC4], 
        [0, 0x00, 0x00, 0xC7, 0xC8]
    ],
    "Rat Death": [
        [0, 0xF8, 0xF9, 0xFA, 0xFB], 
        [0, 0xFC, 0xFD, 0x5A, 0x4E], 
        [0, 0x00, 0x00, 0xC5, 0xC6]
    ],
    "Hit": [
        [1, 0x01, 0x02, 0x03, 0x04], 
        [1, 0x05, 0x06, 0x07, 0x08], 
        [1, 0x09, 0x0A, 0x0B, 0x0C],
    ],
    "Glow 0": [
        [0, 0x0D, 0x0E, 0x0F, 0x10], 
        [0, 0x11, 0x12, 0x13, 0x14], 
        [0, 0x15, 0x16, 0x17, 0x18]
    ],
    "Glow 2": [
        [2, 0x0D, 0x0E, 0x0F, 0x10], 
        [2, 0x11, 0x12, 0x13, 0x14], 
        [2, 0x15, 0x16, 0x17, 0x18]
    ],
    "Chest": [
        [0, 0x0C9, 0x0CA, 0x0CB, 0x0CC], 
    ],
    "Ordinary Key": [
        [1, 0x0CD, 0x0CE, 0x0CF, 0x0D0], 
    ],
    "Red Potion": [
        [0, 0x0D1, 0x0D2, 0x0D3, 0x0D4], 
    ],
    "Blue Potion": [
        [2, 0x0D1, 0x0D2, 0x0D3, 0x0D4]
    ],
    "Wall Destruction": [
        [1, 0xD5, 0xD5, 0xD5, 0xD5], 
        [1, 0xD6, 0xD7, 0xD8, 0xD9], 
        [1, 0xDA, 0xDB, 0xDC, 0xDD], 
        [1, 0x00, 0x00, 0xDE, 0xDF]
    ]
}

CRAB_FRAMES = {
    "Left Eye": [
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0x26, 0x27],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0x26, 0x27],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0x26, 0x27],
        [0, 0, 0, 0x26, 0x27],
        [0, 0, 0, 0x26, 0x27],
        [0, 0, 0, 0, 0],
        [0, 1, 2, 0x0A, 0x0B],
    ],

    "Right Eye": [
        [0, 0, 0, 2, 0],
        [0, 0, 0, 0x28, 0x29],
        [0, 0, 0, 2, 0],
        [0, 0, 0, 0x28, 0x29],
        [0, 0, 0, 2, 0],
        [0, 0, 0, 0x28, 0x29],
        [0, 0, 0, 0x28, 0x29],
        [0, 0, 0, 0x28, 0x29],
        [0, 0, 0, 0, 0],
    ],

    "Left Tibia": [
        [0, 3, 4, 0, 5],
        [0, 0x2A, 0x2B, 0x2C, 0x2D],
        [0, 3, 4, 0, 0x47],
        [0, 0x2A, 0x2B, 0x2C, 0x58],
        [0, 3, 4, 0, 0x69],
        [0, 0x2A, 0x2B, 0x2C, 0x72],
        [0, 3, 4, 0, 5],
        [0, 3, 4, 0, 5],
        [0, 0x8F, 0x90, 0, 0x91],
        [0, 0xAD, 0xAE, 0xAF, 0xB0],
    ],

    "Left Femur": [
        [0, 6, 7, 8, 9],
        [0, 6, 0x2F, 0x30, 0x31],
        [0, 6, 7, 0x48, 0x49],
        [0, 6, 0x2F, 0x59, 0x5A],
        [0, 6, 7, 0x59, 0x5A],
        [0, 6, 0x2F, 0x73, 0x74],
        [0, 6, 0x2F, 8, 9],
        [0, 6, 0x2F, 8, 9],
        [0, 0x92, 0x26, 0x93, 0x94],
        [0, 0xB1, 7, 0xB2, 0xB3],
    ],

    "Mouth": [
        [0, 0x0A, 0x0B, 0x0C, 0x0D],
        [0, 0x32, 0x33, 0x0C, 0x0D],
        [0, 0x0A, 0x0B, 0x0C, 0x0D],
        [0, 0x32, 0x33, 0x0C, 0x0D],
        [0, 0x0A, 0x0B, 0x0C, 0x0D],
        [0, 0x32, 0x33, 0x0C, 0x0D],
        [0, 0x32, 0x33, 0xC5, 0xC6],
        [0, 0x32, 0x33, 0x0C, 0x0D],
        [0, 0x27, 0x28, 0x32, 0x33],
    ],

    "Right Femur": [
        [0, 0x0E, 0x35, 0x10, 0x11],
        [0, 0x34, 0x35, 0x36, 0x37],
        [0, 0x0E, 0x35, 0x4A, 0x4B],
        [0, 0x34, 0x35, 0x5B, 0x5C],
        [0, 0x0E, 0x35, 0x5B, 0x5C],
        [0, 0x34, 0x35, 0x75, 0x76],
        [0, 0x34, 0x35, 0x84, 0x85],
        [0, 0x34, 0x35, 0x84, 0x85],
        [0, 0x29, 0x95, 0x96, 0x97],
        [0, 0x0E, 0xB4, 0xB5, 0xB6],
    ],

    "Right Tibia": [
        [0, 0x12, 0x13, 0x14, 0x15],
        [0, 0x38, 0x39, 0x3A, 0],
        [0, 0x12, 0x13, 0x4C, 0x15],
        [0, 0x38, 0x39, 0x5D, 0],
        [0, 0x12, 0x13, 0x5D, 0x15],
        [0, 0x38, 0x39, 0x77, 0],
        [0, 0x12, 0x13, 0x14, 0x15],
        [0, 0x12, 0x13, 0x14, 0x15],
        [0, 0x98, 0x99, 0x9A, 0],
        [0, 0xB7, 0xB8, 0xB9, 0xBA],
    ],

    "Left Bottom Legs": [
        [0, 0, 0x16, 0, 0x17],
        [0, 0, 0x3B, 0x3C, 0x3D],
        [0, 0, 0x4D, 0, 0x4E],
        [0, 0x5E, 0x5F, 0, 0x60],
        [0, 0x0F, 0x2E, 0x6A, 0x6B],
        [0, 0x78, 0x79, 0x7A, 0x7B],
        [0, 0x86, 0x87, 0, 0x88],
        [0, 0x86, 0x87, 0, 0x88],
        [0, 0x9B, 0x9C, 0x9D, 0x9E],
        [0, 0xBB, 0xBF, 0xBC, 0],
    ],

    "Left Claw": [
        [0, 0x18, 0x19, 0x1A, 0x1B],
        [0, 0x40, 0x19, 0x42, 0x43],
        [0, 0x4F, 0x19, 0x50, 0x51],
        [0, 0x61, 0x19, 0x62, 0x1B],
        [0, 0x6C, 0x19, 0x6D, 0x43],
        [0, 0x7C, 0x19, 0x7D, 0x43],
        [0, 0x18, 0x19, 0, 0x1B],
        [0, 0x18, 0x19, 0, 0x1B],
        [0, 0x9F, 0xA0, 0xA1, 0xA2],
        [0, 0xBD, 0x19, 0xBF, 0x43],
    ],

    "Maxilla": [
        [0, 0x1C, 0x1D, 0x1E, 0],
        [0, 0x1C, 0x1D, 0, 0x44],
        [0, 0x1C, 0x1D, 0x1E, 0x44],
        [0, 0x1C, 0x1D, 0x1E, 0],
        [0, 0x1C, 0x1D, 0, 0],
        [0, 0x1C, 0x1D, 0, 0x44],
        [0, 0x1C, 0x1D, 0x1E, 0],
        [0, 0x1C, 0x1D, 0x1E, 0],
        [0, 0x0C, 0x0D, 0xA3, 0xA4],
    ],

    "Right Claw": [
        [0, 0x1F, 0x20, 0x21, 0x22],
        [0, 0x1F, 0x41, 0x45, 0x46],
        [0, 0x1F, 0x52, 0x53, 0x54],
        [0, 0x1F, 0x63, 0x21, 0x64],
        [0, 0x1F, 0x63, 0x21, 0x6E],
        [0, 0x1F, 0x7E, 0x53, 0x7F],
        [0, 0x1F, 0x89, 0x21, 0x8A],
        [0, 0x1F, 0x89, 0x21, 0x8A],
        [0, 0xA5, 0xA6, 0xA7, 0xA8],
        [0, 0x1F, 0xBE, 0x21, 0xC0],
    ],

    "Right Bottom Legs": [
        [0, 0x23, 0x24, 0x25, 0],
        [0, 0x3E, 0, 0x3F, 0],
        [0, 0x55, 0, 0x56, 0x57],
        [0, 0x65, 0x66, 0x67, 0x68],
        [0, 0x6F, 0x70, 0x71, 0],
        [0, 0x80, 0x81, 0x82, 0x83],
        [0, 0x8B, 0x8C, 0x8D, 0x8E],
        [0, 0x8B, 0x8C, 0x8D, 0x8E],
        [0, 0xA9, 0xAA, 0xAB, 0xAC],
        [0, 0, 0xC1, 0, 0xC2],
    ],

    "Mouth Acid Frames": [
        [0, 0xC7, 0xC8, 0x1C, 0x1D],
        [0, 0xC9, 0xCA, 0x1C, 0x1D],
        [0, 0xCB, 0xCC, 0xCD, 0xCE],
        [0, 0xCF, 0xD0, 0xD1, 0xD2],
        [0, 0xD3, 0xD4, 0xD5, 0xD6],
        [0, 0xC3, 0xC4, 0x1C, 0x1D],
        [0, 0xC5, 0xC6, 0x1C, 0x1D],
        [0, 0x0C, 0x0D, 0x1C, 0x1D],
        [0, 0x0C, 0x0D, 0x1C, 0x1D],
        [0, 0x0C, 0x0D, 0x1C, 0x1D],
    ],

    "Acid Drops": [
        [0, 0xD7, 0xD8, 0xD9, 0],
        [0, 0xDA, 0xDB, 0xDC, 0xDD],
        [0, 0xDE, 0xDF, 0, 0],
        [0, 0xE0, 0xE1, 0, 0],
        [0, 0xE2, 0xE3, 0, 0],
    ],
}

# ---------------------------------------------------------------------------
# Decompression logic
# ---------------------------------------------------------------------------

def unpack(src: bytes, length_limit: int) -> bytes:
    if not src: return b""
    si = 0
    out = bytearray()
    dx = len(src)

    def lodsb(): nonlocal si; b = src[si]; si += 1; return b
    def lodsw(): nonlocal si; lo = src[si]; hi = src[si+1]; si += 2; return lo | (hi << 8)
    def stosb_rep(b, count): out.extend([b] * count)

    method = lodsb() & 0x07
    dx -= 1

    if method == 0:
        out.extend(src[si:si+dx])
    elif method == 1:
        bp = si
        while lodsb() != 0xFF: si += 1
        dx = len(src) - si
        while dx > 0:
            al = lodsb(); dx -= 1; ah = al & 0xF0; cx = 1; tbp = bp
            while True:
                entry_key = src[tbp]
                if (entry_key & 0x0F) != 0: break
                if ah == entry_key: cx = (al & 0x0F) + 2; al = src[tbp + 1]; break
                tbp += 2
            stosb_rep(al, cx)
    elif method == 2:
        marker = lodsb(); dx -= 1; ah = marker
        while dx > 0:
            al = lodsb(); dx -= 1; cx = 1
            if (al & 0xF0) == ah: cx = (al & 0x0F) + 3; al = lodsb(); dx -= 1
            stosb_rep(al, cx)
    elif method == 3:
        bp = si
        while lodsb() != 0xFF: si += 1
        dx = len(src) - si
        while dx > 0:
            al = lodsb(); dx -= 1; ah = al & 0x0F; cx = 1; tbp = bp
            while True:
                entry_key = src[tbp]
                if (entry_key & 0xF0) != 0: break
                if ah == entry_key: cx = (al >> 4) + 2; al = src[tbp + 1]; break
                tbp += 2
            stosb_rep(al, cx)
    elif method == 4:
        marker = lodsb(); dx -= 1; ah = marker
        while dx > 0:
            al = lodsb(); dx -= 1; cx = 1
            if (al & 0x0F) == ah: cx = (al >> 4) + 3; al = lodsb(); dx -= 1
            stosb_rep(al, cx)
    elif method == 5:
        while dx > 0:
            al = lodsb(); cx = 1
            if si < len(src) and src[si] == al:
                cx = src[si + 1] + 2; si += 2; dx -= 2
            stosb_rep(al, cx); dx -= 1
    elif method == 6:
        bp = si
        while lodsw() != 0xFFFF: pass
        dx = len(src) - si
        while dx > 0:
            al = lodsb(); dx -= 1; cx = 1; tbp = bp
            while True:
                tl = src[tbp]; th = src[tbp+1]
                if tl == 0xFF and th == 0xFF: break
                if tl == al: dx -= 1; cx = lodsb() + 2; al = th; break
                tbp += 2
            stosb_rep(al, cx)
    elif method == 7:
        ah = lodsb(); dx -= 1
        while dx > 0:
            al = lodsb(); cx = 1
            if al == ah: al = lodsb(); cx = lodsb() + 3; dx -= 2
            stosb_rep(al, cx); dx -= 1

    return bytes(out)

# ---------------------------------------------------------------------------
# Rendering Engines
# ---------------------------------------------------------------------------

def build_palette():
    # Original Zeliard/MCGA Palette Fragment
    raw = [
        (0,0,0),(31,31,31),(31,0,0),(0,31,0),(0,31,31),(0,0,31),(31,31,0),(31,0,31),
        (31,31,31),(62,62,62),(62,31,31),(31,62,31),(31,62,62),(31,31,62),(62,62,31),(62,31,62),
        (31,0,0),(62,31,31),(62,0,0),(31,31,0),(31,31,31),(31,0,31),(62,31,0),(62,0,31),
        (0,31,0),(31,62,31),(31,31,0),(0,62,0),(0,62,31),(0,31,31),(31,62,0),(31,31,31),
        (0,31,31),(31,62,62),(31,31,31),(0,62,31),(0,62,62),(0,31,62),(31,62,31),(31,31,62),
        (0,0,31),(31,31,62),(31,0,31),(0,31,31),(0,31,62),(0,0,62),(31,31,31),(31,0,62),
        (31,31,0),(62,62,31),(62,31,0),(31,62,0),(31,62,31),(31,31,31),(62,62,0),(62,31,31),
        (31,0,31),(62,31,62),(62,0,31),(31,31,31),(31,31,62),(31,0,62),(62,31,31),(62,0,62),
    ]
    return [f"#{r*4:02x}{g*4:02x}{b*4:02x}" for r, g, b in raw]

PALETTE_STRS = build_palette()

# ---------------------------------------------------------------------------
# Pixel decoding primitives
# ---------------------------------------------------------------------------

def rol16(word, count=1):
    """Rotate a 16-bit word left by `count` bits; return (new_word, last_carry)."""
    word &= 0xFFFF
    carry = 0
    for _ in range(count):
        carry = (word >> 15) & 1
        word = ((word << 1) | carry) & 0xFFFF
    return word, carry

def decode_4(p1, p2, p3):
    """Decode 4 pixels from three 16-bit plane words via rotating shifts.
    Returns updated (p1, p2, p3, [4 palette indices])."""
    pxs = []
    for _ in range(4):
        ax = 0
        p3, cf = rol16(p3); ax = (ax << 1) | cf
        p2, cf = rol16(p2); ax = (ax << 1) | cf
        p1, cf = rol16(p1); ax = (ax << 1) | cf
        p3, cf = rol16(p3); ax = (ax << 1) | cf
        p2, cf = rol16(p2); ax = (ax << 1) | cf
        p1, cf = rol16(p1); ax = (ax << 1) | cf
        pxs.append(ax & 0x3F)
    return p1, p2, p3, pxs

def decode_8(p1, p2, p3):
    """Decode 8 pixels from three 16-bit plane words (two consecutive decode_4 calls)."""
    p1, p2, p3, px1 = decode_4(p1, p2, p3)
    _,   _,   _,  px2 = decode_4(p1, p2, p3)
    return px1 + px2

def read_be_words(row_bytes, count=3):
    """Read `count` big-endian 16-bit words from row_bytes.
    Matches lodsw (little-endian load) + xchg ah,al (byte-swap) = big-endian word."""
    return [(row_bytes[i*2] << 8) | row_bytes[i*2 + 1] for i in range(count)]

def draw_pixel(canvas, x, y, color_str, scale=SCALE):
    canvas.create_rectangle(x, y, x + scale, y + scale, fill=color_str, outline="")

def draw_tile_pixels(canvas, pixels, x0, y0, tile_w=8, scale=SCALE, transparent_idx=None):
    """Paint a flat list of palette indices (or None for transparent) onto the canvas."""
    for i, p_idx in enumerate(pixels):
        if p_idx is None or p_idx == transparent_idx:
            continue
        rx, ry = i % tile_w, i // tile_w
        draw_pixel(canvas, x0 + rx * scale, y0 + ry * scale, PALETTE_STRS[p_idx], scale)

# ---------------------------------------------------------------------------
# Sword rendering
# ---------------------------------------------------------------------------

def decode_sword_8x8(data, color_pair):
    """Decode a single 8x8 tile using 2-bit-per-pixel logic.
    Returns list of 64 palette indices (or None for transparent)."""
    c_high, c_low = color_pair
    pixels = []
    for row_idx in range(8):
        # Read 16-bit word, swap bytes (lodsw + xchg ah,al logic)
        word = (data[row_idx*2] << 8) | data[row_idx*2 + 1]
        for i in range(8):
            selector = (word >> ((7 - i) * 2)) & 0x03
            if selector == 0:
                pixels.append(None)     # Transparent
            elif selector == 3:
                pixels.append(c_high)
            else:
                pixels.append(c_low)
    return pixels

def render_sword_group(data, mega_idx, canvas, y_offset):
    """Render a sword mega-group including color variations and macro-tiles."""
    # Parse Mega-Group Header (15 LE Offsets = 30 bytes)
    header = [int.from_bytes(data[i*2:i*2+2], 'little') for i in range(15)]
    tile_bank = data[header[0]:]

    # Extract Macro-Tile Definitions (22 definitions, 16 bytes each)
    # Definitions start immediately after the 30-byte header (offset 0x1E)
    macro_defs = [data[0x1E + i*16 : 0x1E + (i+1)*16] for i in range(22)]

    current_y = y_offset
    scale = 3
    # Divide macro-tiles into visual subgroups
    subgroups = [(0,6), (6,10), (10,11), (11,17), (17,21), (21,22)]

    for c_pair in SWORD_COLORS[mega_idx]:
        x_cursor = 10
        for start, end in subgroups:
            for m_def in macro_defs[start:end]:
                # Each macro-tile is a 32x32 (4x4 grid of 8x8 tiles), column-major
                for col in range(4):
                    for row in range(4):
                        t_idx = m_def[col * 4 + row]
                        if t_idx == 0xFF: continue  # Full transparency
                        pixels = decode_sword_8x8(tile_bank[t_idx*16 : (t_idx+1)*16], c_pair)
                        for i, p_idx in enumerate(pixels):
                            if p_idx is None: continue
                            rx, ry = i % 8, i // 8
                            draw_pixel(canvas,
                                       x_cursor + (col*8 + rx) * scale,
                                       current_y + (row*8 + ry) * scale,
                                       PALETTE_STRS[p_idx], scale)
                x_cursor += 32 * scale + 2
            x_cursor += 8  # Extra gap between subgroups
        current_y += 32 * scale + 16

    return current_y - y_offset

# ---------------------------------------------------------------------------
# NPC / Hero rendering
# ---------------------------------------------------------------------------

def decode_npc_tile(tile_data):
    """Decode one 8x8 NPC tile from 48 raw bytes (8 rows x 6 bytes).

    The game's apply_sprite_mask reads each row as 3 little-endian words
    (R, G, B planes), then:
      1. Masks out pure-white pixels: plane &= ~(B&G&R)  [so all-ones -> 0]
      2. Byte-swaps each plane word before storing to plane_buffer
      3. Derives blit_mask_bitplane = ~(B|G|R) after byte-swapping B|G|R
      4. Calls build_48_bits_packed_from_rgb_planes  -> 6 packed color bytes
      5. Calls extract_blit_byte_from_mask_plane     -> 1 mask byte
         mask bit = 1 (draw) when both bits of the 2-bit pixel slot in the
         16-bit mask word are 1, which happens iff the decoded palette
         index for that pixel is non-zero.

    Returns list of 64 entries (row-major): palette index (int) or None.
    """
    pixels = []
    for ry in range(8):
        p1, p2, p3 = read_be_words(tile_data[ry*6 : ry*6+6])
        # White-pixel masking: plane &= ~(B&G&R)
        white = p1 & p2 & p3
        p1 &= ~white & 0xFFFF
        p2 &= ~white & 0xFFFF
        p3 &= ~white & 0xFFFF
        pixels.extend(decode_8(p1, p2, p3))
    # Mask: draw only when index != 0
    return [idx if idx != 0 else None for idx in pixels]

def render_npc_group(data, canvas, y_offset, is_hero=False):
    """Render mman.grp/cman.grp (NPC) or tman.grp (Hero) sprites.

    For mman/cman: bytes 0-255 are a tile-index table (40 NPCs x 6 indices),
                   byte 256+ are 48-byte tile definitions.
    For tman: no index table; HERO_INDICES provides the tile layout.
    """
    INDEX_TABLE_SIZE = 0 if is_hero else 256
    NPC_COUNT        = 10 if is_hero else 40
    TILE_SIZE        = 48   # 48 raw bytes per tile
    TILES_PER_NPC    = 6    # 2 columns x 3 rows

    tile_bank      = data[INDEX_TABLE_SIZE:]
    indices_source = HERO_INDICES if is_hero else data
    npc_per_row    = 5 if is_hero else 8
    GAP_X          = 16 * SCALE + 24
    GAP_Y          = 24 * SCALE + 16

    for npc_idx in range(NPC_COUNT):
        base    = npc_idx * TILES_PER_NPC
        indices = indices_source[base : base + TILES_PER_NPC]
        x0 = 10 + (npc_idx % npc_per_row) * GAP_X
        y0 = y_offset + (npc_idx // npc_per_row) * GAP_Y

        for col in range(2):
            for row in range(3):
                t_idx = indices[col * 3 + row]
                if not is_hero:
                    t_idx -= 1
                tile_offset = t_idx * TILE_SIZE
                if tile_offset + TILE_SIZE > len(tile_bank):
                    continue
                pixels = decode_npc_tile(tile_bank[tile_offset : tile_offset + TILE_SIZE])
                draw_tile_pixels(canvas, pixels, x0 + col*8*SCALE, y0 + row*8*SCALE)

    num_rows = (NPC_COUNT + npc_per_row - 1) // npc_per_row
    return num_rows * GAP_Y

# ---------------------------------------------------------------------------
# Sprite / Font rendering (modes 0, 1, 3)
# ---------------------------------------------------------------------------

def decode_sprite_row(mode, row_bytes):
    """Decode one row of pixels for sprite modes 0, 1, and 3.

    All modes share the same decode_8() kernel; they differ only in how
    the 3 plane words are assembled from the raw stride bytes.

    Mode 0 (20px wide): two full 16-bit triplets + one 8-bit stub → 8+8+4 = 20px
    Mode 1 (16px wide): two full 16-bit triplets                   → 8+8    = 16px
    Mode 3 (16px wide): three consecutive BE words from 6 bytes    → 8+8    = 8px per call
                        (caller loops over 4 sub-tiles of 8 rows each)
    """
    if mode == 3:
        # Called once per 6-byte row of a single 8x8 sub-tile
        p1, p2, p3 = read_be_words(row_bytes)
        return decode_8(p1, p2, p3)

    if mode == 0:  # stride=15, 20px wide
        p1a, p2a, p3a = (row_bytes[0]<<8)|row_bytes[1],  (row_bytes[9]<<8)|row_bytes[8],  (row_bytes[10]<<8)|row_bytes[11]
        p1b, p2b, p3b = (row_bytes[2]<<8)|row_bytes[3],  (row_bytes[7]<<8)|row_bytes[6],  (row_bytes[12]<<8)|row_bytes[13]
        p1c, p2c, p3c = row_bytes[4]<<8,                 row_bytes[5]<<8,                 row_bytes[14]<<8
        return decode_8(p1a, p2a, p3a) + decode_8(p1b, p2b, p3b) + decode_4(p1c, p2c, p3c)[3]

    # mode == 1, stride=12, 16px wide
    p1a, p2a, p3a = (row_bytes[0]<<8)|row_bytes[1],  (row_bytes[7]<<8)|row_bytes[6],  (row_bytes[8]<<8)|row_bytes[9]
    p1b, p2b, p3b = (row_bytes[2]<<8)|row_bytes[3],  (row_bytes[5]<<8)|row_bytes[4],  (row_bytes[10]<<8)|row_bytes[11]
    return decode_8(p1a, p2a, p3a) + decode_8(p1b, p2b, p3b)

def render_sprite_group(data, mode, canvas, y_offset):
    cfg = MODE_CFG[mode]
    num_tiles = len(data) // cfg['bytes']
    if num_tiles == 0: return 0

    ti_per_row = 16
    num_rows = (num_tiles + ti_per_row - 1) // ti_per_row
    pad, gap = 4, 16

    for idx in range(num_tiles):
        x0 = (idx % ti_per_row) * (cfg['w'] * SCALE + gap)
        y0 = y_offset + (idx // ti_per_row) * (cfg['h'] * SCALE + pad)
        tile_data = data[idx * cfg['bytes'] : (idx+1) * cfg['bytes']]

        if mode == 3:
            # 192 bytes = four 48-byte 8x8 sub-tiles (TL, TR, BL, BR)
            for sub_idx in range(4):
                quad_x, quad_y = (sub_idx % 2) * 8, (sub_idx // 2) * 8
                chunk = tile_data[sub_idx * 48 : (sub_idx+1) * 48]
                for ry in range(8):
                    pixels = decode_sprite_row(3, chunk[ry*6 : (ry+1)*6])
                    for rx, p_idx in enumerate(pixels):
                        draw_pixel(canvas,
                                   x0 + (quad_x + rx) * SCALE,
                                   y0 + (quad_y + ry) * SCALE,
                                   PALETTE_STRS[p_idx])
        else:
            # Modes 0 and 1: decode row by row, accumulate all pixels
            all_pixels = []
            for ry in range(cfg['h']):
                all_pixels.extend(decode_sprite_row(mode, tile_data[ry*cfg['stride'] : (ry+1)*cfg['stride']]))
            draw_tile_pixels(canvas, all_pixels, x0, y0, tile_w=cfg['w'])

    return num_rows * (cfg['h'] * SCALE + pad)

def render_font_group(data, mode, canvas, y_offset):
    cfg = MODE_CFG[mode]
    num_tiles = len(data) // cfg['bytes']
    ti_per_row = 16
    num_rows = (num_tiles + ti_per_row - 1) // ti_per_row

    for idx in range(num_tiles):
        x0 = (idx % ti_per_row) * (8 * SCALE + 2)
        y0 = y_offset + (idx // ti_per_row) * (8 * SCALE + 2)
        tile_bytes = data[idx * 8 : (idx+1) * 8]
        for ry, b in enumerate(tile_bytes):
            for rx in range(8):
                color = FG_COLOR if (b >> (7 - rx)) & 1 else BG_COLOR
                draw_pixel(canvas, x0 + rx * SCALE, y0 + ry * SCALE, color)

    return num_rows * (8 * SCALE + 2)

# ---------------------------------------------------------------------------
# Pattern rendering (mpat / dpat / cpat)
# ---------------------------------------------------------------------------

# Maps func_mode index to (p_r_src, p_g_src, p_b_src, p_mask_src)
# using symbolic slots: 'w0', 'w1', 'w2', or constants 0 / 0xFFFF
_PAT_PLANE_MAP = {
    0: ('w0', 'w1', 'w2', 0x0000),  # sprite_plane_decompressor_0
    1: ('w0', 'w1', 0,    'w2'  ),  # sprite_plane_decompressor_b
    2: ('w0', 0,    'w2', 'w1'  ),  # sprite_plane_decompressor_g
    3: (0,    'w1', 'w2', 'w0'  ),  # sprite_plane_decompressor_r
    4: ('w0', 'w1', 'w2', 0xFFFF),  # build_48_bytes_packed_tile
}

def render_pat_group(data, canvas, y_offset):
    """Implements decompress_patterns logic from assembly.
    - Bytes 0-5: Metadata/Pointers (ignored)
    - Bytes 6-255: Function indices (0-4) for each tile
    - Byte 256 onward: 48-byte tile data blocks
    """
    HEADER_SIZE = 256
    TILE_SIZE   = 48
    indices     = data[6:HEADER_SIZE]
    tile_bank   = data[HEADER_SIZE:]
    ti_per_row  = 16
    gap         = 8
    total_tiles = len(tile_bank) // TILE_SIZE

    for idx in range(min(total_tiles, len(indices))):
        func_mode = min(indices[idx], 4)  # Safety clamp per assembly loc_3B38
        x0 = 10 + (idx % ti_per_row) * (8 * SCALE + gap)
        y0 = y_offset + (idx // ti_per_row) * (8 * SCALE + gap)

        tile_data = tile_bank[idx * TILE_SIZE : (idx+1) * TILE_SIZE]
        pr_slot, pg_slot, pb_slot, mask_slot = _PAT_PLANE_MAP[func_mode]

        for ry in range(8):
            w0, w1, w2 = read_be_words(tile_data[ry*6 : (ry+1)*6])
            # Resolve symbolic slots to actual word values
            resolve = lambda s: (w0 if s=='w0' else w1 if s=='w1' else w2 if s=='w2' else s)
            p_r    = resolve(pr_slot)
            p_g    = resolve(pg_slot)
            p_b    = resolve(pb_slot)
            p_mask = resolve(mask_slot)

            pixels = decode_8(p_r, p_g, p_b)

            for rx in range(8):
                if func_mode in (0, 4):
                    visible = True
                else:
                    # extract_transparency_byte_from_mask_plane:
                    # pixel is transparent when both bits of its 2-bit slot are 1
                    sel = (p_mask >> (14 - rx * 2)) & 0x03
                    visible = sel != 0x03

                if visible:
                    draw_pixel(canvas, x0 + rx*SCALE, y0 + ry*SCALE, PALETTE_STRS[pixels[rx]])
                else:
                    draw_pixel(canvas, x0 + rx*SCALE, y0 + ry*SCALE, "#00007d")

    return ((total_tiles // ti_per_row) + 1) * (8 * SCALE + gap)

# ---------------------------------------------------------------------------
# Fman rendering (fman.grp hero dungeon sprites)
# ---------------------------------------------------------------------------

def decode_fman_tile(t_data, lut):
    """Decode one 8x8 fman tile from 32 bytes (8 rows x 4 bytes, interleaved nibbles).
    see Decompress_Tile_Data in assembly.
    """
    pixels = []
    for ry in range(8):
        p0 = (t_data[ry*4]   << 8) | t_data[ry*4 + 1]
        p1 = (t_data[ry*4+2] << 8) | t_data[ry*4 + 3]
        combined = p0 | p1
        row_mask = ~(combined | (combined >> 1) | (combined << 2)) & 0xFFFF
        for rx in range(8):
            s1, s2 = 15 - rx*2, 14 - rx*2
            nib = (((p1>>s1)&1) << 3) | (((p0>>s1)&1) << 2) | (((p1>>s2)&1) << 1) | ((p0>>s2)&1)
            is_trans = (row_mask >> s2) & 3 == 3
            pixels.append(None if is_trans else lut[nib])
    return pixels

def render_fman_group(data, canvas, y_offset, frame_counts=None):
    """Decode fman.grp using frame counts in each group to determine group slices."""
    if not frame_counts:
        # Default fallback if no list is provided
        frame_counts = [len(data) // 9] # single group of len/9 frames

    # 1. Calculate slices and total header size
    fman_groups = []
    current_idx = 0
    for count in frame_counts:
        byte_count = count * 9  # Each frame is a 3x3 (9 bytes in the header) grid
        fman_groups.append(data[current_idx : current_idx + byte_count])
        current_idx += byte_count
    
    header_size = current_idx  # Where the tile definitions begin
    TILE_SIZE   = 32  
    scale       = 3

    # 2. Pre-decode all 8x8 tiles from the bank
    tiles_raw = data[header_size:] + b'\x00\x00\x00'
    lut = PAL_DECODE_TABLES[0]
    decoded_tiles = [
        decode_fman_tile(tiles_raw[t*TILE_SIZE : (t+1)*TILE_SIZE], lut)
        for t in range(len(tiles_raw) // TILE_SIZE)
    ]

    # 3. Render the groups
    current_y  = y_offset
    gap        = 12
    sprite_px  = 24  

    for group_indices in fman_groups:
        num_frames = len(group_indices) // 9
        frames_per_row = 18

        for f_idx in range(num_frames):
            x0 = 10 + (f_idx % frames_per_row) * (sprite_px * scale + gap)
            y0 = current_y + (f_idx // frames_per_row) * (sprite_px * scale + gap)
            
            # Draw frame border
            canvas.create_rectangle(x0-1, y0-1, x0 + sprite_px*scale, 
                                     y0 + sprite_px*scale, outline="gray")

            frame_map = group_indices[f_idx*9 : (f_idx+1)*9]
            for row in range(3):
                for col in range(3):
                    t_idx = frame_map[row * 3 + col]
                    if t_idx == 0: continue
                    draw_tile_pixels(canvas, decoded_tiles[t_idx],
                                     x0 + col*8*scale, y0 + row*8*scale,
                                     scale=scale)

        group_rows = (num_frames + frames_per_row - 1) // frames_per_row
        current_y += group_rows * (sprite_px * scale + gap) + 20

    return current_y - y_offset

def draw_composed_16x16_frame(canvas, frame_data, tiles_raw, x_frame, y_frame, scale):
    """Draws a 16x16 frame composed of four 8x8 tiles [tl, tr, bl, br]."""
    TILE_SIZE = 32
    pal_idx = frame_data[0]
    tile_indices = frame_data[1:] # [tl, tr, bl, br]
    lut = PAL_DECODE_TABLES[pal_idx]
    
    for i, t_idx in enumerate(tile_indices):
        if t_idx == 0: continue
        # Slice the 32-byte raw data for the 8x8 tile
        tile_data = tiles_raw[t_idx * TILE_SIZE : (t_idx + 1) * TILE_SIZE]
        pixels = decode_fman_tile(tile_data, lut)
        
        # Calculate sub-tile position within the 16x16 block
        col_offset = (i % 2) * 8 * scale
        row_offset = (i // 2) * 8 * scale
        draw_tile_pixels(canvas, pixels, x_frame + col_offset, y_frame + row_offset, scale=scale)

def render_enp_group(data, canvas, y_offset):
    """
    Render enpX.grp sprites using the ENP_FRAMES animation map.
    The first byte of each frame chooses the palette (lut).
    """
    TILE_SIZE = 32
    scale = 3
    current_y = y_offset
    gap_x = 16
    gap_y = 24
    sprite_px = 16  # Total width/height of the 2x2 tile assembly
    frames_per_row = 10

    # Ensure the data buffer is padded to prevent index-out-of-range errors 
    # for high tile indices (e.g., 0xF8)
    tiles_raw = data + b'\x00' * (256 * TILE_SIZE)

    for anim_name, frames in ENP1_FRAMES.items():
        for f_idx, frame_data in enumerate(frames):
            # Calculate base position for the 16x16 sprite
            x_frame = 10 + (f_idx % frames_per_row) * (sprite_px * scale + gap_x)
            y_frame = current_y + (f_idx // frames_per_row) * (sprite_px * scale + gap_y)
            draw_composed_16x16_frame(canvas, frame_data, tiles_raw, x_frame, y_frame, scale)

        # Advance Y cursor to the next animation block
        num_rows = (len(frames) + frames_per_row - 1) // frames_per_row
        current_y += num_rows * (sprite_px * scale + gap_y)

    return current_y - y_offset

def render_boss_group(data, canvas, y_offset):
    TILE_SIZE = 32
    scale = 3
    current_y = y_offset
    gap_x, gap_y = 25, 35
    
    # Header size in crab.grp is 0; tiles start immediately after the descriptors
    tiles_raw = data + b'\x00' * (256 * TILE_SIZE)

    # -----------------------------------------------------------------------
    # Part 1: Render Composite Crab Body (Phases 0-9)
    # -----------------------------------------------------------------------

    # Normal layout for phases 0-8: (part_name, grid_x, grid_y)
    body_layout08 = [
        ("Left Eye", 24, 0), ("Right Eye", 40, 0),
        ("Left Tibia", 0, 16), ("Left Femur", 16, 16), ("Mouth", 32, 16), ("Right Femur", 48, 16), ("Right Tibia", 64, 16),
        ("Left Bottom Legs", 0, 32), ("Left Claw", 16, 32), ("Maxilla", 32, 32), ("Right Claw", 48, 32), ("Right Bottom Legs", 64, 32)
    ]
    body_layout9 = [
        ("Left Eye", 32, 0),
        ("Left Tibia", 0, 16), ("Left Femur", 16, 8), ("Right Femur", 48, 8), ("Right Tibia", 64, 16),
        ("Left Bottom Legs", 8, 32), ("Left Claw", 16, 24), ("Right Claw", 48, 24), ("Right Bottom Legs", 56, 32)
    ]

    frames_per_row = 3
    for phase in range(10):
        x_base = 10 + (phase % frames_per_row) * (80 * scale + gap_x)
        y_base = current_y + (phase // frames_per_row) * (48 * scale + gap_y)
        
        canvas.create_rectangle(x_base-1, y_base-1, x_base + 80*scale, y_base + 48*scale, outline="gray")

        if phase < 9:
            # Standard rendering for phases 0-8
            for name, gx, gy in body_layout08:
                draw_composed_16x16_frame(canvas, CRAB_FRAMES[name][phase], tiles_raw, x_base + gx*scale, y_base + gy*scale, scale)
        else:
            # Phase 9: Special placement
            for name, gx, gy in body_layout9:
                draw_composed_16x16_frame(canvas, CRAB_FRAMES[name][phase], tiles_raw, x_base + gx*scale, y_base + gy*scale, scale)

    # Advance y_cursor past the 2 rows of body phases
    current_y += 3 * (48 * scale + gap_y) + 36
    
    # -----------------------------------------------------------------------
    # Part 2: Render Remaining 16x16 frames
    # -----------------------------------------------------------------------
    for anim_name in ["Mouth Acid Frames", "Acid Drops"]:
        frames = CRAB_FRAMES[anim_name]
        f_per_row = 10
        for f_idx, frame_data in enumerate(frames):
            x_f = 276 + (f_idx % f_per_row) * (16 * scale + 12)
            y_f = current_y + (f_idx // f_per_row) * (16 * scale)
            
            draw_composed_16x16_frame(canvas, frame_data, tiles_raw, x_f, y_f, scale)
            canvas.create_rectangle(x_f-1, y_f-1, x_f + 16*scale, y_f + 16*scale, outline="gray")
        
        num_rows = (len(frames) + f_per_row - 1) // f_per_row
        current_y += num_rows * (16 * scale + 12)
        
    return current_y - y_offset

# ---------------------------------------------------------------------------
# Roka rendering (roka.grp dungeon entrance decorations)
# ---------------------------------------------------------------------------

def roca_transform(val, frame):
    """Transform a 6-bit color value using the PaletteTransform logic from ASM.
    Both the high 3 bits and low 3 bits are transformed independently."""
    if val == 0:
        return None  # Transparent

    # Substitution tables per frame for 3-bit sub-values
    _SUBS = [
        {6: 3, 7: 5},          # frame 0
        {4: 2},                # frame 1
        {4: 5, 7: 4},          # frame 2
        {4: 3, 7: 5, 6: 7},    # frame 3
        {7: 5, 4: 7, 6: 4},    # frame 4
    ]
    sub = _SUBS[frame]
    high = (val >> 3) & 0x07
    low  =  val       & 0x07
    return (sub.get(high, high) << 3) | sub.get(low, low)

def decode_48b_tile_planar(planar_data):
    """Convert one 48-byte planar tile to 8 rows of 8 decoded 6-bit pixel values.

    Implements Reassemble_3_Planes_To_Packed_Bitmap then immediately decodes,
    skipping the intermediate packed byte representation.
    Each row: 3 LE words → byte-swap (xchg) → big-endian → extract bits per pixel.
    """
    rows = []
    for ry in range(8):
        p1, p2, p3 = read_be_words(planar_data[ry*6 : ry*6+6])
        row_pixels = []
        for i in range(8):
            b_high, b_low = 15 - 2*i, 14 - 2*i
            h3 = (((p3>>b_high)&1) << 2) | (((p2>>b_high)&1) << 1) | ((p1>>b_high)&1)
            l3 = (((p3>>b_low )&1) << 2) | (((p2>>b_low )&1) << 1) | ((p1>>b_low )&1)
            row_pixels.append((h3 << 3) | l3)
        rows.append(row_pixels)
    return rows  # list of 8 lists of 8 values

def render_roka_group(tile_bank_raw, canvas, y_offset):
    """Render the hardcoded 28x18 roka map 5 times with palette animation."""
    TILE_SIZE = 48
    COLS, ROWS = 28, 18

    # Pre-decode all planar tiles into pixel rows (avoids re-decoding per frame)
    num_tiles = len(tile_bank_raw) // TILE_SIZE
    tile_pixel_rows = [
        decode_48b_tile_planar(tile_bank_raw[i*TILE_SIZE : (i+1)*TILE_SIZE])
        for i in range(num_tiles)
    ]

    current_y = y_offset
    gap = 20

    for frame in range(5):
        current_y += 25
        for row in range(ROWS):
            for col in range(COLS):
                tile_idx = ROKA_MAP[row * COLS + col]
                if tile_idx == 0 or tile_idx >= num_tiles:
                    continue
                x0 = 10 + col * (8 * SCALE)
                y0 = current_y + row * (8 * SCALE)
                for ry, row_pixels in enumerate(tile_pixel_rows[tile_idx]):
                    for rx, val in enumerate(row_pixels):
                        final_idx = roca_transform(val, frame)
                        if final_idx is not None:
                            draw_pixel(canvas, x0 + rx*SCALE, y0 + ry*SCALE, PALETTE_STRS[final_idx])
        current_y += ROWS * 8 * SCALE + gap

    return current_y - y_offset

def render_dchr_group(tile_bank_raw, canvas, y_offset, layout=None):
    TILE_SIZE = 48
    # Calculate total tiles first to determine dynamic layout
    num_tiles = len(tile_bank_raw) // TILE_SIZE

    # Fallback: Create as many rows of 13 as needed if no layout is provided
    if not layout or not isinstance(layout, list):
        num_rows = (num_tiles + 12) // 13
        layout = [[13] for _ in range(num_rows)]

    # Pre-decode all planar tiles into pixel rows (avoids re-decoding per frame)
    tile_pixel_rows = [
        decode_48b_tile_planar(tile_bank_raw[i*TILE_SIZE : (i+1)*TILE_SIZE])
        for i in range(num_tiles)
    ]

    current_y = y_offset
    tile_idx = 0
    group_gap = 12  # Space between groups
    row_gap = 16    # Space between vertical rows
    tile_dim = 8 * SCALE

    for row in layout:
        x_cursor = 10
        for group_size in row:
            for _ in range(group_size):
                if tile_idx >= num_tiles:
                    break
                
                # Draw the specific tile
                for ry, row_pixels in enumerate(tile_pixel_rows[tile_idx]):
                    for rx, val in enumerate(row_pixels):
                        if val != 0:
                            draw_pixel(canvas, x_cursor + rx*SCALE, current_y + ry*SCALE, PALETTE_STRS[val])
                
                # Move cursor for "glued" tiles (no gap)
                x_cursor += tile_dim
                tile_idx += 1
            
            # Add gap after finishing a group
            x_cursor += group_gap
            
        # Move to next line after finishing a layout row
        current_y += tile_dim + row_gap

    return current_y - y_offset

# ---------------------------------------------------------------------------
# Main Application
# ---------------------------------------------------------------------------

class GrpViewer:
    def __init__(self, root):
        self.root = root
        self.root.title("Zeliard GRP Viewer")
        self.root.configure(bg=CANVAS_BG)
        self.setup_ui()

        if len(sys.argv) > 1:
            self.load_file(sys.argv[1])

    def setup_ui(self):
        toolbar = tk.Frame(self.root, bg=CANVAS_BG)
        toolbar.pack(side=tk.TOP, fill=tk.X, padx=5, pady=5)

        tk.Button(toolbar, text="Open *.grp", command=self.on_open_click).pack(side=tk.LEFT)
        self.info_label = tk.Label(toolbar, text="No file loaded", bg=CANVAS_BG, fg="#aaaacc", font=("Courier", 10))
        self.info_label.pack(side=tk.LEFT, padx=10)

        # Scrollable Canvas
        frame = tk.Frame(self.root, bg=CANVAS_BG)
        frame.pack(fill=tk.BOTH, expand=True)

        self.canvas = tk.Canvas(frame, bg=CANVAS_BG, highlightthickness=0)
        vbar = tk.Scrollbar(frame, orient=tk.VERTICAL, command=self.canvas.yview)
        hbar = tk.Scrollbar(self.root, orient=tk.HORIZONTAL, command=self.canvas.xview)

        self.canvas.configure(yscrollcommand=vbar.set, xscrollcommand=hbar.set)
        vbar.pack(side=tk.RIGHT, fill=tk.Y)
        hbar.pack(side=tk.BOTTOM, fill=tk.X)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.canvas.bind("<MouseWheel>", lambda e: self.canvas.yview_scroll(int(-1*(e.delta/120)), "units"))

    def on_open_click(self):
        path = filedialog.askopenfilename(filetypes=[("Zeliard GRP", "*.grp"), ("All Files", "*.*")])
        if path:
            self.load_file(path)

    def load_file(self, path):
        try:
            raw = open(path, "rb").read()
        except Exception as e:
            self.info_label.config(text=f"Error: {e}")
            return

        # Simple Zeliard Header Handling
        if raw[0] == 0:
            skip, length, raw1 = 0, len(raw)-1, raw[1:]
        else:
            skip   = int.from_bytes(raw[1:3], "little")
            length = int.from_bytes(raw[3:5], "little")
            raw1   = raw[5+skip:]

        unpacked = unpack(raw1, length)
        filename = os.path.basename(path).lower()

        desc      = next((d for d in GRP_DESCRIPTOR if d[0] == filename), None)
        modes     = desc[1] if desc else [1]
        overrides = desc[2] if desc and len(desc) > 2 else {}

        self.render(unpacked, modes, filename, overrides)

    def render(self, data, modes, filename, overrides):
        self.canvas.delete("all")
        y_cursor = 10

        # Single-mode special cases
        if isinstance(modes, int):
            if modes == 7:
                consumed = render_pat_group(data, self.canvas, y_cursor)
                self.canvas.config(scrollregion=(0, 0, 1000, y_cursor + consumed + 20))
                self.info_label.config(text=f"File: {filename} | Pattern Tiles")
            elif modes == 10:
                consumed = render_dchr_group(data, self.canvas, y_cursor, layout=overrides)
                self.canvas.config(scrollregion=(0, 0, 1000, y_cursor + consumed + 20))
                self.info_label.config(text=f"File: {filename} | Doors & Platforms")
            elif modes == 9:
                consumed = render_roka_group(data, self.canvas, y_cursor)
                self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
                self.info_label.config(text=f"File: {filename} | 28x18 Map | 5 Palette Frames")
            elif modes == 8:
                consumed = render_fman_group(data, self.canvas, y_cursor, overrides)
                self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
                self.info_label.config(text=f"File: {filename} | Hero in Dungeon Sprites")
            elif modes == 11:
                consumed = render_enp_group(data, self.canvas, y_cursor)
                self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
                self.info_label.config(text=f"File: {filename} | Monsters/Items Sprites")
            elif modes == 12:
                consumed = render_boss_group(data, self.canvas, y_cursor)
                self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
                self.info_label.config(text=f"File: {filename} | Monsters/Items Sprites")
            else:  # 5 or 6
                consumed = render_npc_group(data, self.canvas, y_cursor, is_hero=(modes == 6))
                self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
                self.info_label.config(text=f"File: {filename} | NPC Sprites")
            return

        # Multi-group files: header holds one offset per group
        num_groups  = len(modes)
        offsets     = [int.from_bytes(data[i*2:(i+1)*2], "little") for i in range(num_groups)]
        unique_sorted = sorted(set(offsets))
        boundary_map  = {start: (unique_sorted[idx+1] if idx+1 < len(unique_sorted) else len(data))
                         for idx, start in enumerate(unique_sorted)}

        for i, mode in enumerate(modes):
            start_off  = offsets[i]
            group_data = data[start_off : boundary_map[start_off]]

            if MODE_CFG[mode]["type"] == "sword":
                consumed = render_sword_group(group_data, i, self.canvas, y_cursor)
            elif MODE_CFG[mode]["type"] == "sprite":
                tile_size = MODE_CFG[mode]["bytes"]
                if i in overrides:
                    s, c = overrides[i]
                    group_data = group_data[s*tile_size : (s+c)*tile_size]
                consumed = render_sprite_group(group_data, mode, self.canvas, y_cursor)
            else:
                consumed = render_font_group(group_data, mode, self.canvas, y_cursor)

            y_cursor += consumed + 20

        self.canvas.config(scrollregion=(0, 0, 1500, y_cursor))
        self.info_label.config(text=f"File: {filename} | Mega-Groups: {num_groups}")

if __name__ == "__main__":
    app = tk.Tk()
    app.geometry("1100x800")
    GrpViewer(app)
    app.mainloop()
