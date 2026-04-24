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
# 8: 24x24 Hero sprites (fman.grp)
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
    ("fman.grp",  8), # Hero in the gungeons
]

MODE_CFG = {
    0: {"w": 20, "h": 18, "stride": 15, "bytes": 270, "type": "sprite"},
    1: {"w": 16, "h": 16, "stride": 12, "bytes": 192, "type": "sprite"},
    2: {"w": 8,  "h": 8,  "stride": 1,  "bytes": 8,   "type": "font"},
    3: {"w": 16, "h": 16, "stride": 8,  "bytes": 192, "type": "sprite"},
    4: {"w": 32, "h": 32, "stride": 0,  "bytes": 0,   "type": "sword"}, # Variable
    5: {"w": 16, "h": 24, "stride": 0,  "bytes": 0,   "type": "npc"},   # mman.grp NPC sprites
    6: {"w": 16, "h": 24, "stride": 0,  "bytes": 0,   "type": "npc"},   # Hero uses NPC logic
    7: {"w": 8,  "h": 8,  "stride": 6,  "bytes": 48,  "type": "pattern"},
    8: {"w": 16, "h": 8,  "stride": 4,  "bytes": 32,  "type": "fman"},
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
PAL_DECODE_TABLES.append(PAL_DECODE_TABLES[3])           # 5  aliases data3

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

def rol16(word, count=1):
    word &= 0xFFFF
    carry = 0
    for _ in range(count):
        carry = (word >> 15) & 1
        word = ((word << 1) | carry) & 0xFFFF
    return word, carry

def decode_4(p1, p2, p3):
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

def decode_sword_8x8(data, color_pair):
    """Decodes a single 8x8 tile using 2-bit-per-pixel logic."""
    c_high, c_low = color_pair
    pixels = []
    for row_idx in range(8):
        # Read 16-bit word, swap bytes (lodsw + xchg ah, al logic)
        word = (data[row_idx*2] << 8) | data[row_idx*2 + 1]
        
        # Bits are MSB to LSB
        for i in range(8):
            shift = (7 - i) * 2
            selector = (word >> shift) & 0x03
            
            if selector == 0:
                pixels.append(None) # Transparent
            elif selector == 3:
                pixels.append(c_high)
            else:
                pixels.append(c_low)
    return pixels

def render_sword_group(data, mega_idx, canvas, y_offset):
    """Renders a sword mega-group including color variations and macro-tiles."""
    # 1. Parse Mega-Group Header (15 LE Offsets = 30 bytes) [cite: 2]
    header = [int.from_bytes(data[i*2:i*2+2], 'little') for i in range(15)]
    tile_bank_offset = header[0]
    tile_bank = data[tile_bank_offset:]
    
    # 2. Extract Macro-Tile Definitions (22 definitions, 16 bytes each) [cite: 1]
    # Definitions start immediately after the 30-byte header (offset 0x1E)
    macro_defs = []
    for i in range(22):
        start = 0x1E + (i * 16)
        macro_defs.append(data[start : start + 16])
    
    current_y = y_offset
    color_sets = SWORD_COLORS[mega_idx]
    scale = 3
    
    # Render each color variation (e.g. Wood, Steel, Magic) [cite: 1]
    for c_pair in color_sets:
        x_cursor = 10
        # Divide into subgroups logically [cite: 1]
        # Indices: 0-5, 6-9, 10, 11-16, 17-20, 21
        subgroups = [(0,6), (6,10), (10,11), (11,17), (17,21), (21,22)]
        
        for start, end in subgroups:
            for m_idx in range(start, end):
                m_def = macro_defs[m_idx]
                # Each macro-tile is 32x32 pixels (4x4 grid of 8x8 tiles)
                # Stored Column-Major: [C0R0, C0R1, C0R2, C0R3, C1R0...] [cite: 1, 2]
                for col in range(4):
                    for row in range(4):
                        t_idx = m_def[col * 4 + row]
                        if t_idx == 0xFF: continue # Full transparency [cite: 2]
                        
                        t_data = tile_bank[t_idx * 16 : (t_idx + 1) * 16]
                        pixels = decode_sword_8x8(t_data, c_pair)
                        
                        for i, p_idx in enumerate(pixels):
                            if p_idx is None: continue
                            rx, ry = i % 8, i // 8
                            px = x_cursor + (col * 8 + rx) * scale
                            py = current_y + (row * 8 + ry) * scale
                            canvas.create_rectangle(
                                px, py, px + scale, py + scale,
                                fill=PALETTE_STRS[p_idx], outline=""
                            )
                x_cursor += (32 * scale) + 2
            x_cursor += 8 # Extra gap between subgroups
            
        current_y += (32 * scale) + 16
        
    return current_y - y_offset

def decode_npc_tile(tile_data):
    """
    Decode one 8x8 NPC tile from 48 raw bytes (8 rows x 6 bytes).
 
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
 
    So we:
      - Read each row as 3 LE words, byte-swap them (matching xchg dh,dl etc.)
      - Feed into the same decode_4() rol-chain used by mode 3
      - Use index != 0 as the draw mask (exactly what the game precomputes)
 
    Returns list of 64 entries (row-major): palette index (int) or None.
    """
    pixels = []
    for ry in range(8):
        b = tile_data[ry * 6 : ry * 6 + 6]
        # lodsw is little-endian, then xchg byte-swaps -> big-endian word
        # raw bytes [lo, hi] -> lodsw gives lo|(hi<<8) -> xchg -> (lo<<8)|hi
        p1 = (b[0] << 8) | b[1]   # R plane, byte-swapped
        p2 = (b[2] << 8) | b[3]   # G plane, byte-swapped
        p3 = (b[4] << 8) | b[5]   # B plane, byte-swapped
 
        # White-pixel masking: plane &= ~(B&G&R)
        white = p1 & p2 & p3
        p1 &= ~white & 0xFFFF
        p2 &= ~white & 0xFFFF
        p3 &= ~white & 0xFFFF
 
        p1, p2, p3, px1 = decode_4(p1, p2, p3)
        _,  _,  _,  px2 = decode_4(p1, p2, p3)
        pixels.extend(px1 + px2)
 
    # Mask: draw pixel only when index != 0
    # (mirrors extract_blit_byte_from_mask_plane: fires when ~(B|G|R) both bits set,
    #  which is exactly when all plane bits for that pixel were 0 -> index 0)
    return [idx if idx != 0 else None for idx in pixels]
 
def render_npc_tile(tile_data, canvas, x0, y0):
    """
    Paint one 8x8 NPC tile onto canvas at pixel position (x0, y0).
    tile_data: 48 raw bytes as stored in the file.
    Pixels with decoded index 0 are left as background (AND-blit semantics).
    """
    pixels = decode_npc_tile(tile_data)
    for i, p_idx in enumerate(pixels):
        if p_idx is None:
            continue
        rx, ry = i % 8, i // 8
        px = x0 + rx * SCALE
        py = y0 + ry * SCALE
        canvas.create_rectangle(
            px, py, px + SCALE, py + SCALE,
            fill=PALETTE_STRS[p_idx], outline=""
        )
 
def render_npc_group(data, canvas, y_offset, is_hero=False):
    """
    Render mman.grp/cman.grp (NPC) or tman.grp (Hero) sprites. 
    For tman.grp: tile definitions start from the beginning of onpacked data.
    For mman.grp/cman.grp:
    Layout inside the unpacked data:
      Bytes 0-255: Tile-index table.
        240 bytes used (40 NPCs x 6 tile indices each);
        last 16 bytes are zeroes and ignored.
        Each NPC occupies 6 indices that form a 2-column x 3-row grid of 8x8 tiles:
            index[0]  index[1]   ← top row,    col0 | col1
            index[2]  index[3]   ← middle row
            index[4]  index[5]   ← bottom row
            (stored column-major: col0 top→bot, col1 top→bot)
            Actually stored as: [col0_r0, col0_r1, col0_r2,
                                col1_r0, col1_r1, col1_r2]
      Byte  256 onward: Tile definitions, each 48 bytes.
    """
    INDEX_TABLE_SIZE = 0 if is_hero else 256
    NPC_COUNT        = 10 if is_hero else 40    
    TILE_SIZE        = 48         # 48 raw bytes per tile as stored in file
    TILES_PER_NPC    = 6          # 2 columns x 3 rows
    NPC_PIX_W        = 16         # 2 tiles × 8 px
    NPC_PIX_H        = 24         # 3 tiles × 8 px
 
    tile_bank = data[INDEX_TABLE_SIZE:]
    indices_source = HERO_INDICES if is_hero else data

    npc_per_row = 5 if is_hero else 8
    GAP_X       = NPC_PIX_W * SCALE + 24
    GAP_Y       = NPC_PIX_H * SCALE + 16
 
    for npc_idx in range(NPC_COUNT):
        base  = npc_idx * TILES_PER_NPC
        # indices are stored column-major: col0[r0,r1,r2], col1[r0,r1,r2]
        indices = indices_source[base : base + TILES_PER_NPC]
 
        col_in_grid = npc_idx % npc_per_row
        row_in_grid = npc_idx // npc_per_row
        x0 = 10 + col_in_grid * GAP_X
        y0 = y_offset + row_in_grid * GAP_Y
 
        for col in range(2):
            for row in range(3):
                t_idx = indices[col * 3 + row] 
                if not is_hero:
                    t_idx -= 1

                tile_offset = t_idx * TILE_SIZE
                if tile_offset + TILE_SIZE > len(tile_bank):
                    continue
                tile_data = tile_bank[tile_offset : tile_offset + TILE_SIZE]
                tx = x0 + col * 8 * SCALE
                ty = y0 + row * 8 * SCALE
                render_npc_tile(tile_data, canvas, tx, ty)
  
    num_rows = (NPC_COUNT + npc_per_row - 1) // npc_per_row
    return num_rows * GAP_Y

def render_sprite_group(data, mode, canvas, y_offset):
    cfg = MODE_CFG[mode]
    num_tiles = len(data) // cfg['bytes']
    if num_tiles == 0: return 0
    
    ti_per_row = 16
    num_rows = (num_tiles + ti_per_row - 1) // ti_per_row
    pad, gap = 4, 16

    for idx in range(num_tiles):
        tx, ty = idx % ti_per_row, idx // ti_per_row
        x0 = tx * (cfg['w'] * SCALE + gap)
        y0 = y_offset + ty * (cfg['h'] * SCALE + pad)
        
        tile_data = data[idx * cfg['bytes'] : (idx+1) * cfg['bytes']]
        
        if mode == 3:
            # Process 192 bytes as four 48-byte chunks (8x8 each)
            for sub_idx in range(4):
                # Calculate quadrant offsets: 0=TL, 1=TR, 2=BL, 3=BR
                quad_x = (sub_idx % 2) * 8
                quad_y = (sub_idx // 2) * 8
                
                chunk = tile_data[sub_idx * 48 : (sub_idx + 1) * 48]
                
                # Each chunk is 8 rows of 8 pixels
                for ry in range(8):
                    # Each row is 6 bytes (3 planes as 16-bit words)
                    b = chunk[ry * 6 : (ry + 1) * 6]
                    p1, p2, p3 = (b[0]<<8)|b[1], (b[2]<<8)|b[3], (b[4]<<8)|b[5]
                    
                    # Get 8 pixels from the three 16-bit words
                    p1, p2, p3, px_batch1 = decode_4(p1, p2, p3)
                    p1, p2, p3, px_batch2 = decode_4(p1, p2, p3)
                    pixels = px_batch1 + px_batch2
                    
                    for rx, p_idx in enumerate(pixels):
                        px = x0 + (quad_x + rx) * SCALE
                        py = y0 + (quad_y + ry) * SCALE
                        canvas.create_rectangle(
                            px, py, px + SCALE, py + SCALE, 
                            fill=PALETTE_STRS[p_idx], outline=""
                        )
        else:
            # Original Mode 0/1 Logic
            all_pixels = []
            for ry in range(cfg['h']):
                row_b = tile_data[ry * cfg['stride'] : (ry+1) * cfg['stride']]
                if mode == 0: # 20px wide
                    p1a, p2a, p3a = (row_b[0]<<8)|row_b[1], (row_b[9]<<8)|row_b[8], (row_b[10]<<8)|row_b[11]
                    p1b, p2b, p3b = (row_b[2]<<8)|row_b[3], (row_b[7]<<8)|row_b[6], (row_b[12]<<8)|row_b[13]
                    p1c, p2c, p3c = row_b[4]<<8, row_b[5]<<8, row_b[14]<<8
                    
                    _,_,_,px1 = decode_4(p1a, p2a, p3a)
                    _,_,_,px2 = decode_4(*decode_4(p1a, p2a, p3a)[:3])
                    _,_,_,px3 = decode_4(p1b, p2b, p3b)
                    _,_,_,px4 = decode_4(*decode_4(p1b, p2b, p3b)[:3])
                    _,_,_,px5 = decode_4(p1c, p2c, p3c)
                    all_pixels.extend(px1 + px2 + px3 + px4 + px5)
                else: # 16px wide
                    p1a, p2a, p3a = (row_b[0]<<8)|row_b[1], (row_b[7]<<8)|row_b[6], (row_b[8]<<8)|row_b[9]
                    p1b, p2b, p3b = (row_b[2]<<8)|row_b[3], (row_b[5]<<8)|row_b[4], (row_b[10]<<8)|row_b[11]
                    
                    _,_,_,px1 = decode_4(p1a, p2a, p3a)
                    _,_,_,px2 = decode_4(*decode_4(p1a, p2a, p3a)[:3])
                    _,_,_,px3 = decode_4(p1b, p2b, p3b)
                    _,_,_,px4 = decode_4(*decode_4(p1b, p2b, p3b)[:3])
                    all_pixels.extend(px1 + px2 + px3 + px4)

            for i, p_idx in enumerate(all_pixels):
                rx, ry = i % cfg['w'], i // cfg['w']
                px, py = x0 + rx * SCALE, y0 + ry * SCALE
                canvas.create_rectangle(
                    px, py, px + SCALE, py + SCALE, 
                    fill=PALETTE_STRS[p_idx], outline=""
                )

    return num_rows * (cfg['h'] * SCALE + pad)

def render_font_group(data, mode, canvas, y_offset):
    cfg = MODE_CFG[mode]
    num_tiles = len(data) // cfg['bytes']
    ti_per_row = 16
    num_rows = (num_tiles + ti_per_row - 1) // ti_per_row
    
    for idx in range(num_tiles):
        tx, ty = idx % ti_per_row, idx // ti_per_row
        x0, y0 = tx * (8 * SCALE + 2), y_offset + ty * (8 * SCALE + 2)
        tile_bytes = data[idx * 8 : (idx+1) * 8]
        
        for ry, b in enumerate(tile_bytes):
            for rx in range(8):
                color = FG_COLOR if (b >> (7 - rx)) & 1 else BG_COLOR
                px, py = x0 + rx * SCALE, y0 + ry * SCALE
                canvas.create_rectangle(px, py, px+SCALE, py+SCALE, fill=color, outline="")
                
    return num_rows * (8 * SCALE + 2)

def render_pat_group(data, canvas, y_offset):
    """
    Implements decompress_patterns logic from assembly.
    - Bytes 0-5: Metadata/Pointers (ignored)
    - Bytes 6-255: Function indices (0-4) for each tile
    - Byte 256 onward: 48-byte tile data blocks
    """
    HEADER_SIZE = 256
    TILE_SIZE = 48
    indices = data[6:HEADER_SIZE]
    tile_bank = data[HEADER_SIZE:]
    
    ti_per_row = 16
    gap = 8
    total_tiles = len(tile_bank) // TILE_SIZE
    
    for idx in range(min(total_tiles, len(indices))):
        func_mode = indices[idx]
        if func_mode > 4: func_mode = 0 # Safety clamp per assembly loc_3B38
        
        tx, ty = idx % ti_per_row, idx // ti_per_row
        x0 = 10 + tx * (8 * SCALE + gap)
        y0 = y_offset + ty * (8 * SCALE + gap)
        
        tile_data = tile_bank[idx * TILE_SIZE : (idx + 1) * TILE_SIZE]
        
        for ry in range(8):
            row_bytes = tile_data[ry * 6 : (ry + 1) * 6]
            # lodsw + xchg ah, al = Big Endian word
            w0 = (row_bytes[0] << 8) | row_bytes[1]
            w1 = (row_bytes[2] << 8) | row_bytes[3]
            w2 = (row_bytes[4] << 8) | row_bytes[5]
            
            p_r, p_g, p_b, p_mask = 0, 0, 0, 0
            
            # Map words to planes based on func_mode index
            if func_mode == 0: # sprite_plane_decompressor_0
                p_r, p_g, p_b, p_mask = w0, w1, w2, 0x0000 
            elif func_mode == 1: # sprite_plane_decompressor_b
                p_r, p_g, p_b, p_mask = w0, w1, 0, w2
            elif func_mode == 2: # sprite_plane_decompressor_g
                p_r, p_g, p_b, p_mask = w0, 0, w2, w1
            elif func_mode == 3: # sprite_plane_decompressor_r
                p_r, p_g, p_b, p_mask = 0, w1, w2, w0
            elif func_mode == 4: # build_48_bytes_packed_tile...
                p_r, p_g, p_b, p_mask = w0, w1, w2, 0xFFFF

            # Decode pixels using existing rol16 logic
            _, _, _, px1 = decode_4(p_r, p_g, p_b)
            _, _, _, px2 = decode_4(*decode_4(p_r, p_g, p_b)[:3])
            pixels = px1 + px2
            
            # Transparency Logic: extract_transparency_byte_from_mask_plane
            # Check if mask bits are 11b (3) for each pixel
            for rx in range(8):
                # Mode 0/4 are overrides, others use the mask word
                if func_mode == 0:
                    visible = True 
                elif func_mode == 4:
                    visible = True
                else:
                    # Check bits (15-14), (13-12)... for each pixel
                    sel = (p_mask >> (14 - rx * 2)) & 0x03
                    visible = not (sel == 0x03) # "je short loc_3C8F" logic
                
                if visible:
                    p_idx = pixels[rx]
                    px, py = x0 + rx * SCALE, y0 + ry * SCALE
                    canvas.create_rectangle(
                        px, py, px + SCALE, py + SCALE,
                        fill=PALETTE_STRS[p_idx], outline=""
                    )
                else: # simulate blue background
                    canvas.create_rectangle(
                        x0 + rx * SCALE, y0 + ry * SCALE,
                        x0 + (rx + 1) * SCALE, y0 + (ry + 1) * SCALE,
                        fill="#00007d", outline=""
                    )
                    
    return ((total_tiles // ti_per_row) + 1) * (8 * SCALE + gap)

def render_fman_group(data, canvas, y_offset):
    """
    Decodes fman.grp hero sprites as 24x24 pixel frames.
    Groups are defined by slices in the 819-byte header.
    """
    HEADER_SIZE = 819
    TILE_SIZE = 32  # 8 rows x 4 bytes (interleaved nibbles)
    scale = 3
    
    # 1. Action Group Definitions from header slices
    fman_groups = [
        data[0:117],   # 13 frames
        data[117:234], # 13 frames
        data[234:270], # 4 frames
        data[270:279], # 1 frame
        data[279:441], # 18 frames
        data[441:603], # 18 frames
        data[603:711], # 12 frames
        data[711:819], # 12 frames
    ]

    # 2. Pre-decode all 8x8 tiles
    gfx_base = HEADER_SIZE
    tiles_raw = data[gfx_base:] + b'\x00\x00\x00' # original Zeliard data also lacks the last 3 bytes
    num_tiles = len(tiles_raw) // TILE_SIZE
    LUT = PAL_DECODE_TABLES[0]
    decoded_tiles = []

    for t_idx in range(num_tiles):
        t_data = tiles_raw[t_idx * TILE_SIZE : (t_idx + 1) * TILE_SIZE]
        pixels = []
        for ry in range(8):
            # Interleave 2 words into nibbles
            p0 = (t_data[ry*4] << 8) | t_data[ry*4 + 1]
            p1 = (t_data[ry*4 + 2] << 8) | t_data[ry*4 + 3]
            combined = p0 | p1
            row_mask = ~(combined | (combined>>1) | (combined<<2)) & 0xffff
            
            # 8 nibbles per each row and 8 transparency bits
            for rx in range(8):
                s1, s2 = 15 - (rx * 2), 14 - (rx * 2)
                nib = ((p1 >> s1) & 1) << 3 | \
                      ((p0 >> s1) & 1) << 2 | \
                      ((p1 >> s2) & 1) << 1 | \
                      ((p0 >> s2) & 1)
                
                is_trans = (row_mask >> s2) & 3 == 3
                pixels.append(None if is_trans else LUT[nib])
        decoded_tiles.append(pixels)

    # 3. Render by Action Groups
    current_y = y_offset
    gap = 12
    sprite_px = 24  # 3x3 tiles

    for g_idx, group_indices in enumerate(fman_groups):
        num_frames = len(group_indices) // 9
        frames_per_row = 18
        
        for f_idx in range(num_frames):
            fx = f_idx % frames_per_row
            fy = f_idx // frames_per_row
            
            x0 = 10 + fx * (sprite_px * scale + gap)
            y0 = current_y + fy * (sprite_px * scale + gap)
            canvas.create_rectangle(x0-1, y0-1, x0 + sprite_px * scale, y0 + sprite_px * scale, outline="gray")

            # Extract the 9 indices for this 24x24 frame
            frame_map = group_indices[f_idx * 9 : (f_idx + 1) * 9]
            
            for row in range(3):
                for col in range(3):
                    # Row-major index lookup
                    t_idx = frame_map[row * 3 + col]
                    
                    if t_idx == 0:
                        continue
                    
                    tile_pix = decoded_tiles[t_idx]
                    for i, p_idx in enumerate(tile_pix):
                        if p_idx is None: continue
                        rx, ry = i % 8, i // 8
                        px = x0 + (col * 8 + rx) * scale
                        py = y0 + (row * 8 + ry) * scale
                        canvas.create_rectangle(
                            px, py, px + scale, py + scale, 
                            fill=PALETTE_STRS[p_idx], outline=""
                        )
        
        # Move cursor down for next action group
        group_rows = (num_frames + frames_per_row - 1) // frames_per_row
        current_y += (group_rows * (sprite_px * scale + gap)) + 20

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
            skip = int.from_bytes(raw[1:3], "little")
            length = int.from_bytes(raw[3:5], "little")
            raw1 = raw[5+skip:]

        unpacked = unpack(raw1, length)
        filename = os.path.basename(path).lower()
        
        desc = next((d for d in GRP_DESCRIPTOR if d[0] == filename), None)
        modes = desc[1] if desc else [1]
        overrides = desc[2] if desc and len(desc) > 2 else {}
            
        self.render(unpacked, modes, filename, overrides)

    def render(self, data, modes, filename, overrides):
        self.canvas.delete("all")
        y_cursor = 10

        # Handle Patterns (pat.grp)
        if isinstance(modes, int) and modes == 7:
            consumed = render_pat_group(data, self.canvas, y_cursor)
            self.canvas.config(scrollregion=(0, 0, 1000, y_cursor + consumed + 20))
            self.info_label.config(text=f"File: {filename} | Pattern Tiles")
            return

        if isinstance(modes, int) and modes in [5, 6, 8]:
            if modes == 8:
                consumed = render_fman_group(data, self.canvas, y_cursor)
            else:
                consumed = render_npc_group(data, self.canvas, y_cursor, is_hero=(modes == 6))
            
            self.canvas.config(scrollregion=(0, 0, 1200, y_cursor + consumed + 40))
            self.info_label.config(text=f"File: {filename} | Hero/NPC Sprites")
            return

        # sword.grp main header: 3 offsets to mega-groups [cite: 2]
        num_groups = len(modes)
        offsets = [int.from_bytes(data[i*2:(i+1)*2], "little") for i in range(num_groups)]
        
        # Calculate bounds for slicing data
        unique_sorted = sorted(list(set(offsets)))
        boundary_map = {start: (unique_sorted[idx+1] if idx+1 < len(unique_sorted) else len(data)) 
                        for idx, start in enumerate(unique_sorted)}
        
        for i, mode in enumerate(modes):
            start_off = offsets[i]
            end_off = boundary_map[start_off]
            group_data = data[start_off:end_off]
            
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