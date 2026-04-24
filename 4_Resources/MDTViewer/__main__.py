"""
Entry point for running the MDT Viewer.

Run from any location:
  python MDTViewer/__main__.py
  python -m MDTViewer
  python C:\\full\\path\\to\\MDTViewer\\__main__.py
"""

import sys
import os
from pathlib import Path

# Add the parent directory of this module to sys.path
# so the viewer can be run from any directory
module_dir    = Path(__file__).parent   # MDTViewer folder
module_parent = module_dir.parent       # parent of MDTViewer folder
sys.path.insert(0, str(module_parent))

# Also add current working directory
sys.path.insert(0, os.getcwd())

from MDTViewer.viewer import MDTViewer

if __name__ == '__main__':
    MDTViewer().mainloop()
