"""
Zeliard MDT Viewer v3.1
───────────────────────
A viewer for Zeliard (Game Arts / Sierra On-Line, 1987) MDT map files.

Features:
  - Full MDT header parsing for dungeon and town maps
  - Overlay labels: D1/D2 (doors), M1/M2 (monsters), I1/I2 (items), N1/N2 (NPCs)
  - Hover tooltips showing entity details
  - NPC dialogue panel for town maps
  - Export to PNG and TXT formats
  - Zoom controls (2-40px block size)
  - 16-tile alignment guides

Usage:
  python -m zeliard_mdt_viewer
  # or
  from zeliard_mdt_viewer import MDTViewer
  MDTViewer().mainloop()
"""

from .viewer import MDTViewer
from .decoder import decode_mdt, decode_town_mdt, decode_mdt_file
from .models import MdtData, TownMdtData, Door, TownDoor, Monster, Item, NPC
from .constants import (
    SEG_BASE, MAP_HEIGHT, TOWN_HEIGHT, PALETTE,
    _MONSTER_TYPE_NAMES, is_town_mdt, get_map_type_info
)

__version__ = '3.1'
__all__ = [
    'MDTViewer',
    'decode_mdt',
    'decode_town_mdt',
    'decode_mdt_file',
    'MdtData',
    'TownMdtData',
    'Door',
    'TownDoor',
    'Monster',
    'Item',
    'NPC',
    'SEG_BASE',
    'MAP_HEIGHT',
    'TOWN_HEIGHT',
    'PALETTE',
    '_MONSTER_TYPE_NAMES',
    'is_town_mdt',
    'get_map_type_info',
]
