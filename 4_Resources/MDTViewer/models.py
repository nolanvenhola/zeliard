"""
Zeliard MDT Viewer - Data models for map entities.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any


@dataclass
class Door:
    """Dungeon/outdoor door (12-byte structure)."""
    label: str
    x: int
    y: int
    flags: int
    map_id: int
    x1: int
    y1: int
    unk: int
    flags2: int
    is_town: bool = False
    needs_key: bool = False
    dest: str = ''
    dtype: str = ''
    raw: str = ''

    @classmethod
    def from_bytes(cls, data: bytes, offset: int, label: str) -> 'Door':
        """Parse door from 12 bytes."""
        import struct
        x0 = struct.unpack_from('<H', data, offset)[0]
        y0 = data[offset + 2]
        flags = data[offset + 3]
        map_id = data[offset + 4]
        x1 = struct.unpack_from('<H', data, offset + 5)[0]
        y1 = struct.unpack_from('<H', data, offset + 7)[0]
        unk = struct.unpack_from('<H', data, offset + 9)[0]
        flags2 = data[offset + 11]

        is_town = (y1 == 0x00FF)
        key_req = bool(flags & 0x01)

        from .constants import _town_name, _dung_name
        dest = _town_name(map_id) if is_town else _dung_name(map_id)

        if is_town:
            dtype = 'Town Warp'
        elif key_req:
            dtype = 'Locked Door  (Lion Key required)'
        else:
            dtype = 'Regular Door'

        raw = ' '.join(f'{b:02X}' for b in data[offset:offset + 12])

        return cls(
            label=label, x=x0, y=y0, flags=flags, map_id=map_id,
            x1=x1, y1=y1, unk=unk, flags2=flags2,
            is_town=is_town, needs_key=key_req, dest=dest, dtype=dtype, raw=raw
        )


@dataclass
class TownDoor:
    """Town door (3-byte structure)."""
    label: str
    x: int
    y: int = 0
    door_type: int = 0
    dtype: str = ''
    raw: str = ''

    @classmethod
    def from_bytes(cls, data: bytes, offset: int, label: str) -> 'TownDoor':
        """Parse town door from 3 bytes."""
        import struct
        x = struct.unpack_from('<H', data, offset)[0]
        door_type = data[offset + 2]
        raw = ' '.join(f'{b:02X}' for b in data[offset:offset + 3])
        return cls(
            label=label, x=x, y=0, door_type=door_type,
            dtype='Town Door', raw=raw
        )


@dataclass
class Monster:
    """Monster entity (16-byte structure)."""
    label: str
    x: int
    y: int
    type: int
    unk3: int
    spwn_x: int
    spwn_y: int
    spwn_type: int
    act: int
    raw: str = ''

    @classmethod
    def from_bytes(cls, data: bytes, offset: int, label: str) -> 'Monster':
        """Parse monster from 16 bytes."""
        import struct
        cx = struct.unpack_from('<H', data, offset)[0]
        cy = data[offset + 2]
        unk3 = data[offset + 3]
        ttype = data[offset + 4]
        sx = struct.unpack_from('<H', data, offset + 11)[0]
        sy = data[offset + 13]
        stype = data[offset + 14]
        act = data[offset + 15]
        raw = ' '.join(f'{b:02X}' for b in data[offset:offset + 16])

        return cls(
            label=label, x=cx, y=cy, type=ttype, unk3=unk3,
            spwn_x=sx, spwn_y=sy, spwn_type=stype, act=act, raw=raw
        )


@dataclass
class Item:
    """Item entity (16-byte structure)."""
    label: str
    x: int
    y: int
    type: int
    unk3: int
    spwn_x: int
    spwn_y: int
    spwn_type: int
    act: int
    raw: str = ''

    @classmethod
    def from_bytes(cls, data: bytes, offset: int, label: str) -> 'Item':
        """Parse item from 16 bytes."""
        import struct
        cx = struct.unpack_from('<H', data, offset)[0]
        cy = data[offset + 2]
        unk3 = data[offset + 3]
        ttype = data[offset + 4]
        sx = struct.unpack_from('<H', data, offset + 11)[0]
        sy = data[offset + 13]
        stype = data[offset + 14]
        act = data[offset + 15]
        raw = ' '.join(f'{b:02X}' for b in data[offset:offset + 16])

        return cls(
            label=label, x=cx, y=cy, type=ttype, unk3=unk3,
            spwn_x=sx, spwn_y=sy, spwn_type=stype, act=act, raw=raw
        )


@dataclass
class NPC:
    """Town NPC entity (8-byte structure)."""
    label: str
    x: int
    y: int = 0
    npc_id: int = 0
    raw: str = ''

    @classmethod
    def from_bytes(cls, data: bytes, offset: int, label: str) -> 'NPC':
        """Parse NPC from 8 bytes."""
        import struct
        x = struct.unpack_from('<H', data, offset)[0]
        npc_id = data[offset + 7]
        raw = ' '.join(f'{b:02X}' for b in data[offset:offset + 8])
        return cls(label=label, x=x, y=0, npc_id=npc_id, raw=raw)


@dataclass
class Platform:
    """Platform entity (V/C: 3 bytes, H: 7 bytes)."""
    label: str
    ptype: str  # 'V-Platform', 'C-Platform', 'H-Platform'
    x: int
    y: int
    size: int = 1
    raw: str = ''
    left: int = 0       # HP travel left boundary (compat)
    right: int = 0      # HP travel right boundary (compat)
    x_left: int = 0     # HP left travel boundary
    x_right: int = 0    # HP right travel boundary
    x_init: int = 0     # VP/HP spawn x
    spawn: int = 0      # VP/CP spawn y (always 0)
    y_init: int = 0     # VP/CP destination y tile
    y_flag: int = 0     # HP y_flags byte
    y_fix: int = 0      # HP byte[2] encoded y: actual = y_fix & 0x7F
    y_end: int = 0      # VP/CP destination y (alias for y_init)

    @classmethod
    def from_bytes_vc(cls, data: bytes, offset: int, label: str, ptype: str) -> 'Platform':
        """
        Parse vertical/collapsing platform from 3 bytes.
        Structure:
          [0] x      BYTE  tile column
          [1] y      BYTE  spawn y (always 0 — top of map)
          [2] y_end  BYTE  destination y tile coordinate (NOT a travel count)
        """
        x_init = data[offset]         # byte[0] x_init
        spawn  = data[offset + 1]     # byte[1] spawn (y start, always 0)
        y_init = data[offset + 2]     # byte[2] y_init (destination y tile)
        raw    = ' '.join(f'{b:02X}' for b in data[offset:offset + 3])
        inst   = cls(label=label, ptype=ptype, x=x_init, y=spawn, size=y_init, raw=raw)
        inst.x_init = x_init
        inst.spawn  = spawn
        inst.y_init = y_init
        inst.y_end  = y_init   # alias kept for compat
        return inst

    @classmethod
    def from_bytes_h(cls, data: bytes, offset: int, label: str) -> 'Platform':
        """
        Parse horizontal platform from 8 bytes.
        Structure:
          [0..1] x_init   WORD   spawn column (2바이트)
          [2]    y_fix    BYTE   encoded y: actual_y = y_fix & 0x7F  (e.g. 0xAB & 0x7F = 43)
          [3..4] x_left   WORD   left travel boundary (inclusive)
          [5..6] x_right  WORD   right travel boundary (inclusive)
        Visual width: 2 tiles.
        """
        import struct as _struct
        raw_data = data[offset:offset + 8]
        x_init   = _struct.unpack_from('<H', bytes(raw_data), 0)[0] & 0x0FFF  # 2바이트, 0x0FFF 마스크 적용
        y_fix    = raw_data[2] & 0x7F       # byte[2] y encoded: high bit masked off
        y        = y_fix & 0x7F               # actual y row
        left     = _struct.unpack_from('<H', bytes(raw_data), 3)[0] & 0x0FFF
        right    = _struct.unpack_from('<H', bytes(raw_data), 5)[0] & 0x0FFF
        raw      = ' '.join(f'{b:02X}' for b in raw_data)
        inst     = cls(label=label, ptype='H-Platform', x=x_init, y=y, size=1, raw=raw)
        inst.x_init  = x_init
        inst.y_fix   = y_fix
        inst.x_left  = left
        inst.x_right = right
        inst.left    = left
        inst.right   = right
        return inst


@dataclass
class Sign:
    """In-map sign / notice board (variable-length structure in signs_ptr table)."""
    label: str
    x: int           # tile column
    y: int           # tile row
    x_screen: int    # screen X (in 8-pixel units)
    y_screen: int    # screen Y
    text: str        # cleaned display text (newlines preserved)
    raw: str = ''

@dataclass
class AchvItem:
    """Accomplished-items check entry (raw dump — format TBD)."""
    label: str
    raw: str         # hex dump of raw bytes

@dataclass
class MdtData:
    """Decoded dungeon/outdoor MDT data."""
    map_width: int
    map_height: int
    grid: List[List[int]]
    gfx: List[List[int]]
    desc_ptr: int
    vplat_ptr: int
    cplat_ptr: int
    hplat_ptr: int
    doors_ptr: int
    achv_ptr: int
    name_ptr: int
    monsters_ptr: int
    level: int
    tear_x: int
    tear_y: int
    signs_ptr: int
    map_end_ptr: int
    consumed_si: int
    doors: List[Door] = field(default_factory=list)
    monsters: List[Monster] = field(default_factory=list)
    items: List[Item] = field(default_factory=list)
    vplats: List[Platform] = field(default_factory=list)
    cplats: List[Platform] = field(default_factory=list)
    hplats: List[Platform] = field(default_factory=list)
    signs: List['Sign'] = field(default_factory=list)
    achv_items: List['AchvItem'] = field(default_factory=list)
    is_town: bool = False
    name: str = ''            # map/place name from name renderer structure
    cavern_name: str = ''      # name from name renderer structure
    name_disp_x: int = 0       # display X from name renderer
    name_color: int = 0        # palette color index from name renderer
    # Town fields (empty for dungeon maps)
    town_name: str = ''
    town_doors: List[TownDoor] = field(default_factory=list)
    npcs: List[NPC] = field(default_factory=list)
    npc_ptr: int = 0
    npc_texts: Dict[int, str] = field(default_factory=dict)
    npc_texts_ptr: int = 0


@dataclass
class TownMdtData:
    """Decoded town MDT data."""
    desc_ptr: int
    map_width: int
    map_height: int
    grid: List[List[int]]
    gfx: List[List[int]]
    town_name: str
    name_ptr: int
    doors_ptr: int
    npc_texts_ptr: int
    npc_ptr: int
    town_doors: List[TownDoor]
    npcs: List[NPC]
    npc_texts: Dict[int, str]
    is_town: bool = True
    # Dungeon fields (empty for town maps)
    doors: List[Door] = field(default_factory=list)
    monsters: List[Monster] = field(default_factory=list)
    items: List[Item] = field(default_factory=list)
    vplats: List[Platform] = field(default_factory=list)
    cplats: List[Platform] = field(default_factory=list)
    hplats: List[Platform] = field(default_factory=list)
    vplat_ptr: int = 0
    cplat_ptr: int = 0
    hplat_ptr: int = 0
    achv_ptr: int = 0
    monsters_ptr: int = 0
    level: int = 0
    tear_x: int = 0
    tear_y: int = 0
    signs_ptr: int = 0
    map_end_ptr: int = 0
    consumed_si: int = 0

    def to_mdt_data(self) -> MdtData:
        """Convert to MdtData for compatibility with viewer."""
        return MdtData(
            map_width=self.map_width,
            map_height=self.map_height,
            grid=self.grid,
            gfx=self.gfx,
            desc_ptr=self.desc_ptr,
            vplat_ptr=self.vplat_ptr,
            cplat_ptr=self.cplat_ptr,
            hplat_ptr=self.hplat_ptr,
            doors_ptr=self.doors_ptr,
            achv_ptr=self.achv_ptr,
            name_ptr=self.name_ptr,
            monsters_ptr=self.monsters_ptr,
            level=self.level,
            tear_x=self.tear_x,
            tear_y=self.tear_y,
            signs_ptr=self.signs_ptr,
            map_end_ptr=self.map_end_ptr,
            consumed_si=self.consumed_si,
            doors=self.doors,
            monsters=self.monsters,
            items=self.items,
            vplats=self.vplats,
            cplats=self.cplats,
            hplats=self.hplats,
            is_town=True,
            town_name=self.town_name,
            town_doors=self.town_doors,
            npcs=self.npcs,
            npc_ptr=self.npc_ptr,
            npc_texts=self.npc_texts,
            npc_texts_ptr=self.npc_texts_ptr,
        )
