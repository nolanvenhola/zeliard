"""
Zeliard MDT Viewer - MDT file decoders.

Dungeon MDT runtime memory layout (segment base = 0xC000):
  +0x00  descriptor ptr
  +0x02  map width (WORD)
  +0x04  vertical platforms ptr     (3 bytes/entry, stop=FFFF)
  +0x06  collapsing platforms ptr   (3 bytes/entry, stop=FFFF)
  +0x08  horizontal platforms ptr   (7 bytes/entry, stop=FFFF)
  +0x0A  doors ptr                  (12 bytes/entry, stop=FFFF)
  +0x0C  accomplished items ptr     (stop=FFFF)
  +0x0E  cavern name renderer ptr
  +0x10  monsters ptr               (16 bytes/entry, stop=FFFF)
  +0x12  cavern level (BYTE)
  +0x13  tear X  (WORD — door-to-boss X tile coordinate)
  +0x15  tear Y  (BYTE)
  +0x17  signs ptr
  +0x19  packed_map_end ptr
  +0x1B  packed map data  ← RLE tile grid starts here (column-major)

Town MDT runtime memory layout (segment base = 0xC000):
  +0x02  map width (WORD); height is always 8 tiles
  +0x04  offset to town name rendering info; skip 3 bytes, then pascal string
  +0x09  offset to town doors array (3 bytes/entry, stop=FFFF)
  +0x0D  offset to NPC texts pointer array
  +0x0F  offset to NPC array (8 bytes/entry, stop=FFFF)
  +0x17  unpacked map data  — map_width * 8 bytes, column-major
"""

import struct
from typing import Tuple, Dict, List, Optional

from .constants import SEG_BASE, MAP_HEIGHT, TOWN_HEIGHT, is_town_mdt
from .models import (
    MdtData, TownMdtData, Door, TownDoor, Monster, Item, NPC
)


def _parse_doors(data: bytes, doors_ptr: int, n: int) -> List[Door]:
    """Parse dungeon door entries (12 bytes each, 0xFFFF-terminated)."""
    doors = []
    off = _ptr_off_safe(doors_ptr, n)
    if off is None:
        return doors
    idx = 1
    while off + 2 <= n:
        if data[off] == 0xFF and data[off + 1] == 0xFF:
            break
        if off + 12 > n:
            break
        doors.append(Door.from_bytes(data, off, f'D{idx}'))
        idx += 1
        off += 12
    return doors


def _parse_town_doors(data: bytes, doors_ptr: int, n: int) -> List[TownDoor]:
    """Parse town door entries (3 bytes each, 0xFFFF-terminated)."""
    doors = []
    off = _ptr_off_safe(doors_ptr, n)
    if off is None:
        return doors
    idx = 1
    while off + 2 <= n:
        if data[off] == 0xFF and data[off + 1] == 0xFF:
            break
        if off + 3 > n:
            break
        doors.append(TownDoor.from_bytes(data, off, f'D{idx}'))
        idx += 1
        off += 3
    return doors


def _parse_monsters(data: bytes, monsters_ptr: int, n: int) -> Tuple[List[Monster], List[Item]]:
    """Parse monster/item entries (16 bytes each, 0xFFFF-terminated)."""
    monsters = []
    items = []
    off = _ptr_off_safe(monsters_ptr, n)
    if off is None:
        return monsters, items

    mid = iid = 1
    while off + 2 <= n:
        if data[off] == 0xFF and data[off + 1] == 0xFF:
            break
        if off + 16 > n:
            break

        stype = data[off + 14]
        if stype == 0:  # spawn type 0 = item
            items.append(Item.from_bytes(data, off, f'I{iid}'))
            iid += 1
        else:  # spawn type != 0 = monster
            monsters.append(Monster.from_bytes(data, off, f'M{mid}'))
            mid += 1
        off += 16
    return monsters, items


def _parse_town_npcs(data: bytes, npc_ptr: int, n: int) -> List[NPC]:
    """Parse town NPC entries (8 bytes each, 0xFFFF-terminated)."""
    npcs = []
    off = _ptr_off_safe(npc_ptr, n)
    if off is None:
        return npcs
    idx = 1
    while off + 2 <= n:
        if data[off] == 0xFF and data[off + 1] == 0xFF:
            break
        if off + 8 > n:
            break
        npcs.append(NPC.from_bytes(data, off, f'N{idx}'))
        idx += 1
        off += 8
    return npcs


def _parse_npc_texts(data: bytes, npc_texts_ptr: int, n: int) -> Dict[int, str]:
    """
    Read the NPC texts pointer array at npc_texts_ptr.

    The array holds one 2-byte LE runtime pointer per NPC id (0-based).
    The array has no explicit terminator — we stop when a pointer resolves
    outside the file. Each pointer points to a 0xFF-terminated string.
    Returns dict {npc_id (int): text (str)}.
    """
    texts: Dict[int, str] = {}
    base = _ptr_off_safe(npc_texts_ptr, n)
    if base is None:
        return texts

    idx = 0
    off = base
    while off + 2 <= n:
        ptr = struct.unpack_from('<H', data, off)[0]
        str_off = _ptr_off_safe(ptr, n)
        if str_off is None:
            break  # pointer out of range — end of array

        # Read 0xFF-terminated string
        end = str_off
        while end < n and data[end] != 0xFF:
            end += 1
        texts[idx] = data[str_off:end].decode('ascii', errors='replace')
        idx += 1
        off += 2
    return texts


def _ptr_off_safe(ptr: int, file_size: int) -> Optional[int]:
    """Safe wrapper for pointer to offset conversion."""
    if ptr == 0 or ptr == 0xFFFF:
        return None
    if ptr >= SEG_BASE:
        off = ptr - SEG_BASE
    else:
        off = ptr
    return off if off < file_size else None


def _decode_tile_grid(data: bytes, start_offset: int, map_width: int,
                      map_height: int, packed: bool = True) -> List[List[int]]:
    """Decode tile grid from MDT data."""
    n = len(data)
    grid = [[0] * map_width for _ in range(map_height)]

    if not packed:
        # Unpacked tiles (town maps) — column-major
        for col in range(map_width):
            col_off = start_offset + col * map_height
            if col_off + map_height > n:
                break
            for row in range(map_height):
                grid[row][col] = data[col_off + row]
        return grid

    # Packed RLE tiles (dungeon maps) — column-major 2-bit opcode RLE
    si = start_offset
    for col in range(map_width):
        row = 0
        dl = 0
        guard = 0
        while dl < 0x40:
            guard += 1
            if guard > 0xFFFF or si >= n:
                break
            b = data[si]
            op = (b >> 6) & 3

            if op == 0:  # 00: long run
                rep = b + 1
                si += 1
                if si >= n:
                    break
                tile = data[si]
            elif op == 1:  # 01: packed nibbles
                rep = ((b >> 4) & 3) + 2
                tile = (b & 0x0F) + 1
            elif op == 2:  # 10: empty run (tile 0)
                rep = b & 0x3F
                tile = 0
                if rep == 0:
                    si += 1
                    continue
            else:  # 11: single tile
                tile = b & 0x3F
                rep = 1

            si += 1
            dl += rep
            for _ in range(rep):
                if row < map_height:
                    grid[row][col] = tile
                    row += 1

    return grid, si  # type: ignore


def decode_mdt(data: bytes) -> MdtData:
    """
    Decode a Zeliard dungeon/outdoor MDT file.

    Returns MdtData with parsed grid, doors, monsters, items, and header info.
    """
    n = len(data)
    if n < 0x1D:
        raise ValueError(f'File too small: {n} bytes (need >= 29)')

    def word(o: int) -> int:
        return struct.unpack_from('<H', data, o)[0]

    def byte(o: int) -> int:
        return data[o] if o < n else 0

    mw = word(0x02)
    if not 1 <= mw <= 4096:
        raise ValueError(f'Invalid map width: {mw}')

    # Decode tile grid
    grid, consumed_si = _decode_tile_grid(data, 0x1B, mw, MAP_HEIGHT, packed=True)

    return MdtData(
        map_width=mw,
        map_height=MAP_HEIGHT,
        grid=grid,
        desc_ptr=word(0x00),
        vplat_ptr=word(0x04),
        cplat_ptr=word(0x06),
        hplat_ptr=word(0x08),
        doors_ptr=word(0x0A),
        achv_ptr=word(0x0C),
        name_ptr=word(0x0E),
        monsters_ptr=word(0x10),
        level=byte(0x12),
        tear_x=word(0x13) if n > 0x14 else 0,
        tear_y=byte(0x15),
        signs_ptr=word(0x17) if n > 0x18 else 0,
        map_end_ptr=word(0x19) if n > 0x1A else 0,
        consumed_si=consumed_si,
        doors=_parse_doors(data, word(0x0A), n),
        monsters=_parse_monsters(data, word(0x10), n)[0],
        items=_parse_monsters(data, word(0x10), n)[1],
    )


def decode_town_mdt(data: bytes) -> TownMdtData:
    """
    Decode a Zeliard town MDT file.

    Town memory layout (all offsets relative to file start / segment base 0xC000):
      +0x02  map width WORD (little endian); height is fixed at 8
      +0x04  ptr to town name info: skip 3 bytes, then pascal string (1-byte length)
      +0x09  ptr to doors array (3 bytes/entry, 0xFFFF-terminated)
      +0x0F  ptr to NPC array (8 bytes/entry, 0xFFFF-terminated)
      +0x17  unpacked map — map_width * 8 bytes, column-major
    """
    n = len(data)
    if n < 0x17 + 8:
        raise ValueError(f'File too small for a town MDT: {n} bytes')

    def word(o: int) -> int:
        return struct.unpack_from('<H', data, o)[0]

    def byte(o: int) -> int:
        return data[o] if o < n else 0

    mw = word(0x02)
    if not 1 <= mw <= 4096:
        raise ValueError(f'Invalid town map width: {mw}')

    # Town name (pascal string at name_ptr + 3)
    name_ptr = word(0x04)
    town_name = ''
    name_off = _ptr_off_safe(name_ptr, n)
    if name_off is not None:
        str_off = name_off + 3  # skip 3 bytes before pascal string
        if str_off < n:
            slen = byte(str_off)
            raw = data[str_off + 1: str_off + 1 + slen]
            town_name = raw.decode('ascii', errors='replace')

    # Pointers
    doors_ptr = word(0x09)
    npc_texts_ptr = word(0x0D)
    npc_ptr = word(0x0F)

    # Parse entities
    town_doors = _parse_town_doors(data, doors_ptr, n)
    npc_texts = _parse_npc_texts(data, npc_texts_ptr, n)
    npcs = _parse_town_npcs(data, npc_ptr, n)

    # Decode tile grid (unpacked, column-major)
    grid = _decode_tile_grid(data, 0x17, mw, TOWN_HEIGHT, packed=False)

    return TownMdtData(
        map_width=mw,
        map_height=TOWN_HEIGHT,
        grid=grid,  # type: ignore
        town_name=town_name,
        name_ptr=name_ptr,
        doors_ptr=doors_ptr,
        npc_texts_ptr=npc_texts_ptr,
        npc_ptr=npc_ptr,
        town_doors=town_doors,
        npcs=npcs,
        npc_texts=npc_texts,
    )


def decode_mdt_file(filepath: str) -> MdtData:
    """
    Decode an MDT file, auto-detecting town vs dungeon format.

    Returns MdtData suitable for the viewer (town data is converted).
    """
    with open(filepath, 'rb') as f:
        data = f.read()

    if is_town_mdt(filepath):
        town_data = decode_town_mdt(data)
        return town_data.to_mdt_data()
    else:
        return decode_mdt(data)
