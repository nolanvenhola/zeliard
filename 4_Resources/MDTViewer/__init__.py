"""
Zeliard MDT Viewer
==================
A viewer for Zeliard (Game Arts / Sierra On-Line, 1987) MDT map files.

Modules:
  viewer        - Main tkinter application
  decoder       - MDT/GRP file parser
  models        - Data classes
  constants     - Palettes, lookup tables
  widgets       - UI helper widgets
  sar_reader    - SAR archive reader
  tile_graphics - Tile image decoder (requires STMP.MDT + CMAP.MDT)

Usage:
  python -m MDTViewer
"""

from .viewer import MDTViewer

__all__ = ['MDTViewer']

from .sidebar import Sidebar
