"""
Zeliard MDT Viewer - Reusable UI widgets.
"""

import tkinter as tk
from typing import Optional, List, Tuple


class Tooltip:
    """Hover tooltip window for displaying entity information."""

    def __init__(self, root: tk.Tk):
        self._root = root
        self._win: Optional[tk.Toplevel] = None
        self._lbl: Optional[tk.Label] = None

    def show(self, rx: int, ry: int, text: str):
        """Show tooltip at screen coordinates (rx, ry) with given text."""
        if not self._win:
            self._win = tk.Toplevel(self._root)
            self._win.wm_overrideredirect(True)
            self._win.attributes('-topmost', True)
            self._lbl = tk.Label(
                self._win, justify='left',
                bg='#12121e', fg='#e0e0f0',
                font=('Consolas', 8),
                relief='solid', bd=1, padx=10, pady=7)
            self._lbl.pack()
        self._lbl.config(text=text)
        self._win.wm_geometry(f'+{rx + 20}+{ry + 20}')
        self._win.deiconify()
        self._win.lift()

    def hide(self):
        """Hide the tooltip."""
        if self._win:
            self._win.withdraw()


class InfoBox(tk.Frame):
    """Collapsible info panel with header and text content area."""

    def __init__(self, parent: tk.Widget, title: str,
                 bg_header: str, fg_header: str, **kwargs):
        super().__init__(parent, bg=parent.cget('bg'), **kwargs)
        self._title = title
        self._bg_header = bg_header
        self._fg_header = fg_header
        self._txt: Optional[tk.Text] = None
        self._tags_configured = False
        self._build_box()

    def _build_box(self):
        """Build the header and content frames."""
        self._header = tk.Frame(self, bg=self._bg_header, relief='solid', bd=1)
        self._header.pack(fill='x')
        tk.Label(self._header, text=self._title, bg=self._bg_header,
                 fg=self._fg_header, font=('Consolas', 10, 'bold')
                 ).pack(side='left', padx=5, pady=3)
        self._content = tk.Frame(self, bg=self._bg_header)
        self._content.pack(fill='both', expand=True)

    def set_text_widget(self, txt: tk.Text):
        """Attach a Text widget to this info box."""
        self._txt = txt
        self._txt.pack(in_=self._content, fill='both', expand=True)

    def config_tags(self, tags: List[Tuple[str, str]]):
        """Configure text tags with foreground colors."""
        if self._txt and not self._tags_configured:
            for tag, color in tags:
                self._txt.tag_config(tag, foreground=color)
            self._tags_configured = True

    def hide(self):
        """Hide the info box (legacy method, kept for compatibility)."""
        pass


class ScrollFrame(tk.Frame):
    """A scrollable container frame for embedding other widgets."""

    def __init__(self, parent: tk.Widget, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.canvas = tk.Canvas(self, bg=self.cget('bg'), highlightthickness=0)
        self.scrollbar = tk.Scrollbar(
            self, orient='vertical', command=self.canvas.yview,
            bg=self.master.cget('bg'))
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.scrollbar.pack(side='right', fill='y')
        self.canvas.pack(side='left', fill='both', expand=True)

        self.interior = tk.Frame(self.canvas, bg=self.cget('bg'))
        self.canvas_window = self.canvas.create_window(
            (0, 0), window=self.interior, anchor='nw')

        self.interior.bind('<Configure>', self._on_configure)
        self.canvas.bind('<Configure>', self._on_canvas_configure)

    def _on_configure(self, event=None):
        """Update scroll region when interior changes size."""
        self.canvas.configure(scrollregion=self.canvas.bbox('all'))

    def _on_canvas_configure(self, event):
        """Adjust interior width to match canvas."""
        self.canvas.itemconfig(self.canvas_window, width=event.width)
