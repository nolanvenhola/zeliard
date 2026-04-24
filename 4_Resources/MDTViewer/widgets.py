"""
Zeliard MDT Viewer - Reusable UI widgets.
"""

import tkinter as tk
from typing import Optional, List, Tuple, Union


# Color tags shared between Tooltip and the info-panel Text widgets
# These must match the tag names configured in _build_info_panel.
TOOLTIP_COLORS = {
    'k':       '#89b4fa',   # key label   (blue)
    'v':       '#cdd6f4',   # plain value (fg)
    'd':       '#6c7086',   # dim
    'g':       '#a6e3a1',   # green
    'r':       '#f38ba8',   # red / monster
    'y':       '#f9e2af',   # yellow
    'c':       '#89dceb',   # cyan
    'p':       '#cba6f7',   # pink / entity label
    's':       '#313244',   # surface / sep
    'rb_x':    '#89b4fa',   # x coord (blue)
    'rb_y':    '#a6e3a1',   # y coord (green)
    'rb_w':    '#f9e2af',   # width/size (yellow)
    'rb_type': '#f38ba8',   # type (red)
    'rb_id':   '#cba6f7',   # id/map_id (purple)
    'rb_flag': '#fab387',   # flags (orange)
    'rb_act':  '#94e2d5',   # act (teal)
    # HP/VP/CP per-field colors
    'hp_xi':   '#f38ba8',   # x_init  (red)
    'hp_yf':   '#89b4fa',   # y_fix   (blue)
    'hp_xl':   '#f9e2af',   # x_left  (yellow)
    'hp_xr':   '#a6e3a1',   # x_right (green)
    'vp_xi':   '#f38ba8',
    'vp_yi':   '#89b4fa',
    'vp_yd':   '#a6e3a1',
}


class Tooltip:
    """Colored hover-tooltip using a Text widget (matches info-panel style)."""

    BG = '#12121e'
    BD = '#313244'

    def __init__(self, root: tk.Tk):
        self._root = root
        self._win:  Optional[tk.Toplevel] = None
        self._txt:  Optional[tk.Text]     = None

    def _ensure_window(self):
        if self._win:
            return
        self._win = tk.Toplevel(self._root)
        self._win.wm_overrideredirect(True)
        self._win.attributes('-topmost', True)

        outer = tk.Frame(self._win, bg=self.BD, bd=1, relief='solid')
        outer.pack()
        self._txt = tk.Text(
            outer,
            bg=self.BG, fg='#cdd6f4',
            font=('Consolas', 8),
            relief='flat', bd=0,
            padx=10, pady=7,
            state='disabled',
            wrap='none',
            width=48, height=1,
            cursor='arrow',
            exportselection=False,
        )
        self._txt.pack()
        for tag, color in TOOLTIP_COLORS.items():
            self._txt.tag_config(tag, foreground=color)
        self._txt.tag_config('sep', foreground='#313244')

    def show(self, rx: int, ry: int,
             segments: Union[str, List[Tuple[str, str]]]):
        """
        Show tooltip.
        segments: either a plain str OR a list of (text, tag) pairs.
        """
        self._ensure_window()
        T = self._txt
        T.config(state='normal')
        T.delete('1.0', 'end')

        if isinstance(segments, str):
            T.insert('end', segments)
        else:
            for text, tag in segments:
                T.insert('end', text, tag)

        # Auto-size height (max 30 lines) and width
        content = T.get('1.0', 'end-1c')
        lines   = content.split('\n')
        h = min(len(lines), 30)
        w = min(max((len(l) for l in lines), default=20) + 2, 60)
        T.config(height=h, width=w, state='disabled')

        self._win.wm_geometry(f'+{rx + 20}+{ry + 20}')
        self._win.deiconify()
        self._win.lift()

    def hide(self):
        if self._win:
            self._win.withdraw()


class InfoBox(tk.Frame):
    """Collapsible info panel with header and text content area."""

    def __init__(self, parent: tk.Widget, title: str,
                 bg_header: str, fg_header: str, **kwargs):
        super().__init__(parent, bg=parent.cget('bg'), **kwargs)
        self._bg_header = bg_header
        self._fg_header = fg_header
        self._txt: Optional[tk.Text] = None
        self._build_box(title)

    def _build_box(self, title: str):
        self._header = tk.Frame(self, bg=self._bg_header, relief='solid', bd=1)
        self._header.pack(fill='x')
        tk.Label(self._header, text=title, bg=self._bg_header,
                 fg=self._fg_header, font=('Consolas', 10, 'bold')
                 ).pack(side='left', padx=5, pady=3)
        self._content = tk.Frame(self, bg=self._bg_header)
        self._content.pack(fill='both', expand=True)

    def set_text_widget(self, txt: tk.Text):
        self._txt = txt
        self._txt.pack(in_=self._content, fill='both', expand=True)

    def hide(self): pass


class ScrollFrame(tk.Frame):
    """Scrollable container frame."""

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
        self.canvas.configure(scrollregion=self.canvas.bbox('all'))

    def _on_canvas_configure(self, event):
        self.canvas.itemconfig(self.canvas_window, width=event.width)


class CollapsibleSection(tk.Frame):
    """
    A self-contained collapsible box for use in info panels.

    Header bar is always visible. Clicking the title or the ▼/▶ button
    collapses/expands the content area. The box never disappears and never
    overlaps siblings — it simply shows/hides its content frame.

    Usage:
        sec = CollapsibleSection(parent, title='MAP INFO', color='#89b4fa')
        sec.pack(fill='x')
        # Add content:
        lbl = tk.Label(sec.content, text='hello')
        lbl.pack()
    """

    def __init__(self, parent, title: str = '', color: str = '#89b4fa',
                 bg_header: str = '#313244', bg_content: str = '#1e1e2e',
                 start_expanded: bool = True, **kwargs):
        super().__init__(parent, bg=bg_content, **kwargs)
        self._expanded = start_expanded
        self._bg_hdr   = bg_header
        self._bg_cnt   = bg_content

        # ── Header ──
        hdr = tk.Frame(self, bg=bg_header, relief='solid', bd=1)
        hdr.pack(fill='x')

        self._toggle_btn = tk.Button(
            hdr, text=('▼' if start_expanded else '▶'),
            command=self.toggle,
            bg=bg_header, fg=color, relief='flat', bd=0,
            cursor='hand2', font=('Consolas', 10), padx=4, pady=2,
            activebackground=bg_header, activeforeground=color)
        self._toggle_btn.pack(side='right', padx=2)

        title_lbl = tk.Label(hdr, text=title, bg=bg_header, fg=color,
                             font=('Consolas', 10, 'bold'), cursor='hand2',
                             padx=5, pady=3)
        title_lbl.pack(side='left')
        # Clicking the title label also toggles
        title_lbl.bind('<Button-1>', lambda e: self.toggle())

        # ── Content ──
        self.content = tk.Frame(self, bg=bg_content)
        if start_expanded:
            self.content.pack(fill='both', expand=True)

    # ── API ────────────────────────────────────────────────────────────────
    def toggle(self):
        if self._expanded:
            self.collapse()
        else:
            self.expand()

    def collapse(self):
        self.content.pack_forget()
        self._toggle_btn.config(text='▶')
        self._expanded = False

    def expand(self):
        self.content.pack(fill='both', expand=True)
        self._toggle_btn.config(text='▼')
        self._expanded = True

    @property
    def is_expanded(self) -> bool:
        return self._expanded
