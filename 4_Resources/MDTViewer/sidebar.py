"""
sidebar.py — Reusable collapsible sidebar with drag-resize.

Public API
----------
Sidebar(parent, title, side, collapsed_width, expand_width,
        resizable, min_width, title_color, bg, content_bg, on_toggle)

    .content         — tk.Frame  — place child widgets here
    .toggle()        — collapse or expand
    .collapse()
    .expand()
    .is_collapsed    — bool property
    .set_width(w)    — programmatic resize

Usage in another app
---------------------
    from .sidebar import Sidebar
    sb = Sidebar(root, title='Files', side='left', expand_width=240, resizable=True)
    sb.pack(side='left', fill='y')
    MyWidget(sb.content).pack(fill='both', expand=True)
"""

import tkinter as tk
from typing import Callable, Optional


class Sidebar(tk.Frame):
    """
    Collapsible, drag-resizable sidebar panel.

    Layout (side='left'):
        ┌──────────────────────┬───┐
        │  TITLE          ◀   │ ↔ │  ← header + grip strip
        ├──────────────────────┤   │
        │                      │   │
        │   content            │   │  ← content fills the rest
        │                      │   │
        └──────────────────────┴───┘

    The sidebar never leaves the layout — it just shrinks to
    `collapsed_width` when collapsed, so sibling widgets are not
    forced to redraw.
    """

    _ARROW = {
        ('left',  True):  '◀',
        ('left',  False): '▶',
        ('right', True):  '▶',
        ('right', False): '◀',
    }
    _GRIP_W  = 5    # px width of the drag handle strip
    _GRIP_BG = '#45475a'
    _GRIP_HI = '#89b4fa'

    def __init__(self,
                 parent,
                 title:           str                 = '',
                 side:            str                 = 'left',
                 collapsed_width: int                 = 28,
                 expand_width:    int                 = 240,
                 resizable:       bool                = True,
                 min_width:       int                 = 80,
                 title_color:     str                 = '#89dceb',
                 bg:              str                 = '#313244',
                 content_bg:      str                 = '#1e1e2e',
                 on_toggle:       Optional[Callable]  = None,
                 **kwargs):
        super().__init__(parent, bg=bg, **kwargs)
        self._side      = side
        self._col_w     = collapsed_width
        self._exp_w     = expand_width
        self._cur_w     = expand_width
        self._min_w     = min_width
        self._collapsed = False
        self._cb        = on_toggle
        self._bg        = bg
        self._fg        = title_color
        self._resizable = resizable

        self.pack_propagate(False)
        self.config(width=expand_width)
        self._build(title, bg, content_bg, title_color, resizable)

    # ── Construction ───────────────────────────────────────────────────────
    def _build(self, title, bg, content_bg, fg, resizable):
        """
        Pack order matters for tkinter pack geometry manager.
        We use a two-column layout:
          - A main_frame (fill='both', expand=True) holding header+content
          - A grip strip packed on the inner edge BEFORE main_frame so it
            gets its size request honoured before content expands
        """
        grip_side  = 'right' if self._side == 'left' else 'left'
        other_side = 'left'  if self._side == 'left' else 'right'

        # ── Grip strip (pack FIRST so it gets space before content) ────────
        if resizable:
            self._grip = tk.Frame(
                self, bg=self._GRIP_BG,
                width=self._GRIP_W, cursor='sb_h_double_arrow')
            self._grip.pack(side=grip_side, fill='y')
            self._grip.pack_propagate(False)
            self._grip.bind('<B1-Motion>', self._on_drag)
            self._grip.bind('<Enter>',
                            lambda e: self._grip.config(bg=self._GRIP_HI))
            self._grip.bind('<Leave>',
                            lambda e: self._grip.config(bg=self._GRIP_BG))
        else:
            self._grip = None

        # ── Main area (header + content) ────────────────────────────────────
        self._main = tk.Frame(self, bg=bg)
        self._main.pack(side=other_side, fill='both', expand=True)

        # Header
        self._hdr = tk.Frame(self._main, bg=bg, height=28)
        self._hdr.pack(fill='x', side='top')
        self._hdr.pack_propagate(False)

        self._lbl = tk.Label(
            self._hdr, text=title, bg=bg, fg=fg,
            font=('Consolas', 9, 'bold'), padx=6, pady=4)
        self._btn = tk.Button(
            self._hdr, text=self._arrow(expanded=True),
            command=self.toggle,
            bg=bg, fg=fg, relief='flat', bd=0, cursor='hand2',
            font=('Consolas', 11), padx=4, pady=2,
            activebackground=bg, activeforeground=fg)
        self._pack_header_widgets(expanded=True)

        # Content
        self.content = tk.Frame(self._main, bg=content_bg)
        self.content.pack(fill='both', expand=True, side='top')

    def _pack_header_widgets(self, expanded: bool):
        self._lbl.pack_forget()
        self._btn.pack_forget()
        if expanded:
            if self._side == 'left':
                self._lbl.pack(side='left')
                self._btn.pack(side='right')
            else:
                self._btn.pack(side='left')
                self._lbl.pack(side='left')
        else:
            self._btn.pack(fill='x')

    # ── Public API ─────────────────────────────────────────────────────────
    def toggle(self):
        self.expand() if self._collapsed else self.collapse()

    def collapse(self):
        if self._collapsed:
            return
        self._cur_w     = self.winfo_width() or self._exp_w
        self._collapsed = True
        # Hide content and label, show only arrow button
        self.content.pack_forget()
        self._pack_header_widgets(expanded=False)
        # Hide grip while collapsed
        if self._grip:
            self._grip.pack_forget()
        self.config(width=self._col_w)
        self._btn.config(text=self._arrow(expanded=False))
        if self._cb:
            self._cb(False)

    def expand(self):
        if not self._collapsed:
            return
        self._collapsed = False
        grip_side = 'right' if self._side == 'left' else 'left'
        # Restore grip first so it keeps its space
        if self._grip:
            self._grip.pack(side=grip_side, fill='y')
        self._pack_header_widgets(expanded=True)
        self.content.pack(fill='both', expand=True, side='top')
        self.config(width=self._cur_w)
        self._btn.config(text=self._arrow(expanded=True))
        if self._cb:
            self._cb(True)

    def set_width(self, w: int):
        """Resize programmatically (only when expanded)."""
        self._cur_w = max(w, self._min_w)
        if not self._collapsed:
            self.config(width=self._cur_w)

    @property
    def is_collapsed(self) -> bool:
        return self._collapsed

    # ── Drag resize ────────────────────────────────────────────────────────
    def _on_drag(self, event):
        if self._collapsed:
            return
        rx = event.x_root
        if self._side == 'left':
            new_w = rx - self.winfo_rootx()
        else:
            new_w = self.winfo_rootx() + self.winfo_width() - rx
        self.set_width(new_w)

    # ── Arrow ───────────────────────────────────────────────────────────────
    def _arrow(self, expanded: bool) -> str:
        return self._ARROW[(self._side, expanded)]
