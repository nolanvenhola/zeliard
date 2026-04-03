"""
Entry point for running the MDT Viewer as a module:
  python -m zeliard_mdt_viewer
"""

from .viewer import MDTViewer

if __name__ == '__main__':
    MDTViewer().mainloop()
